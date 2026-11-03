import asyncio
import hashlib
import hmac
import os
import uuid
from typing import Any

import httpx
from mcp.server.fastmcp import FastMCP
from mcp.server.transport_security import TransportSecuritySettings

TERMINAL = {"completed", "failed", "cancelled"}
WAITING = {"waiting_for_approval", "waiting_for_clarification"}
MAX_WAIT = 25


def env(name: str, default: str = "") -> str:
    return os.environ.get(name, default)


def load_token_hash(path: str) -> str:
    with open(path) as f:
        return f.read().strip().lower()


class BearerAuth:
    def __init__(self, app, token_hash: str):
        self.app = app
        self.token_hash = token_hash

    def authenticate(self, headers: list[tuple[bytes, bytes]]) -> bool:
        for name, value in headers:
            if name.lower() == b"authorization":
                scheme, _, token = value.decode("latin-1").partition(" ")
                if scheme.lower() != "bearer" or not token.strip():
                    return False
                digest = hashlib.sha256(token.strip().encode()).hexdigest()
                return hmac.compare_digest(digest, self.token_hash)
        return False

    async def __call__(self, scope, receive, send):
        if scope["type"] == "http" and not self.authenticate(scope.get("headers", [])):
            await send({
                "type": "http.response.start",
                "status": 401,
                "headers": [(b"content-type", b"text/plain"), (b"www-authenticate", b"Bearer")],
            })
            await send({"type": "http.response.body", "body": b"unauthorized"})
            return
        await self.app(scope, receive, send)


def hermes_client() -> httpx.AsyncClient:
    return httpx.AsyncClient(
        base_url=env("HERMES_API_URL", "http://127.0.0.1:8642"),
        headers={"Authorization": f"Bearer {env('API_SERVER_KEY')}"},
        timeout=httpx.Timeout(20.0),
    )


def summary(status: dict[str, Any]) -> dict[str, Any]:
    keys = ("run_id", "status", "session_id", "output", "error", "approval", "last_event", "turn_exit_reason")
    return {k: status[k] for k in keys if status.get(k) not in (None, "", {})}


def unreachable(exc: Exception) -> dict[str, Any]:
    return {"error": f"Hermes is unreachable: {exc.__class__.__name__}"}


async def call(method: str, path: str, **kwargs) -> dict[str, Any]:
    try:
        async with hermes_client() as client:
            response = await client.request(method, path, **kwargs)
    except httpx.HTTPError as exc:
        return unreachable(exc)
    try:
        body = response.json()
    except ValueError:
        body = {"error": response.text}
    if response.status_code >= 400:
        message = body.get("error", body)
        if isinstance(message, dict):
            message = message.get("message", message)
        return {"error": f"Hermes answered {response.status_code}: {message}"}
    return body


mcp = FastMCP(
    "hermes",
    instructions=(
        "Hermes is an agent on the computer peterspav with a terminal, files and web tools. "
        "Start a task with start_task, then call task_status until the status is completed, "
        "failed or cancelled. When the status is waiting_for_approval, read the approval to the "
        "user and call approve with their answer. Reuse session_id for follow-up tasks."
    ),
    host=env("HERMES_MCP_HOST", "127.0.0.1"),
    port=int(env("HERMES_MCP_PORT", "8766")),
    stateless_http=True,
    transport_security=TransportSecuritySettings(
        enable_dns_rebinding_protection=True,
        allowed_hosts=[h for h in env("HERMES_MCP_ALLOWED_HOSTS", "127.0.0.1:*").split(",") if h],
        allowed_origins=[],
    ),
)


@mcp.tool()
async def start_task(prompt: str, session_id: str | None = None) -> dict[str, Any]:
    """Give Hermes a task. Pass the session_id of an earlier task to continue that conversation."""
    session = session_id or f"mcp-{uuid.uuid4().hex}"
    result = await call("POST", "/v1/runs", json={"input": prompt, "session_id": session})
    if "error" in result:
        return result
    return {"run_id": result.get("run_id"), "status": result.get("status"), "session_id": session}


@mcp.tool()
async def task_status(run_id: str, wait_seconds: int = 0) -> dict[str, Any]:
    """Get the state and output of a task. wait_seconds (max 25) waits for the task to finish or need approval."""
    deadline = asyncio.get_running_loop().time() + max(0, min(wait_seconds, MAX_WAIT))
    while True:
        status = await call("GET", f"/v1/runs/{run_id}")
        if "error" in status and "status" not in status:
            return status
        state = status.get("status")
        if state in TERMINAL or state in WAITING or asyncio.get_running_loop().time() >= deadline:
            return summary(status)
        await asyncio.sleep(1)


@mcp.tool()
async def approve(run_id: str, approved: bool) -> dict[str, Any]:
    """Answer a pending approval: approved=true runs the command once, false denies it."""
    return await call("POST", f"/v1/runs/{run_id}/approval", json={"choice": "once" if approved else "deny"})


@mcp.tool()
async def stop_task(run_id: str) -> dict[str, Any]:
    """Stop a running task."""
    return await call("POST", f"/v1/runs/{run_id}/stop")


def app():
    path = env("HERMES_MCP_TOKEN_HASH_FILE") or os.path.join(env("CREDENTIALS_DIRECTORY"), "token-hash")
    return BearerAuth(mcp.streamable_http_app(), load_token_hash(path))


def main():
    import uvicorn

    uvicorn.run(
        app(),
        host=mcp.settings.host,
        port=mcp.settings.port,
        proxy_headers=True,
        forwarded_allow_ips=env("HERMES_MCP_FORWARDED_ALLOW_IPS", "127.0.0.1"),
    )


if __name__ == "__main__":
    main()
