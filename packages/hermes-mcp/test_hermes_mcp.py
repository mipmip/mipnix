import asyncio
import hashlib
import json

import httpx
from starlette.testclient import TestClient

import hermes_mcp

failures = 0
checks = 0


def eq(actual, expected, label):
    global failures, checks
    checks += 1
    if actual != expected:
        failures += 1
        print(f"  FAIL  {label}\n          expected {expected!r}\n          actual   {actual!r}")


def run(coro):
    return asyncio.run(coro)


def stub(handler):
    def client():
        return httpx.AsyncClient(
            base_url="http://hermes",
            headers={"Authorization": "Bearer key"},
            transport=httpx.MockTransport(handler),
        )
    hermes_mcp.hermes_client = client


requests = []


def hermes(request: httpx.Request) -> httpx.Response:
    requests.append((request.method, request.url.path, json.loads(request.content or b"null")))
    path = request.url.path
    if request.method == "POST" and path == "/v1/runs":
        return httpx.Response(202, json={"run_id": "run_1", "status": "queued", "replayed": False})
    if request.method == "GET" and path == "/v1/runs/run_1":
        return httpx.Response(200, json={
            "object": "hermes.run", "run_id": "run_1", "status": "completed",
            "session_id": "s1", "output": "backups ok", "usage": {"input_tokens": 3},
        })
    if request.method == "GET" and path == "/v1/runs/run_2":
        return httpx.Response(200, json={
            "run_id": "run_2", "status": "waiting_for_approval",
            "approval": {"description": "delete files", "command": "rm -rf /tmp/x"},
        })
    if path == "/v1/runs/run_2/approval":
        return httpx.Response(200, json={"run_id": "run_2", "choice": "once", "resolved": 1})
    if path == "/v1/runs/run_1/stop":
        return httpx.Response(200, json={"run_id": "run_1", "status": "stopping"})
    return httpx.Response(404, json={"error": {"message": "Run not found"}})


print("- tools")
stub(hermes)
started = run(hermes_mcp.start_task("check the backups"))
eq(started["run_id"], "run_1", "start_task returns run_id")
eq(started["session_id"].startswith("mcp-"), True, "start_task makes a session id")
eq(requests[-1][2]["input"], "check the backups", "prompt sent as input")
eq(requests[-1][2]["session_id"], started["session_id"], "session id sent")
run(hermes_mcp.start_task("and dapperehaan?", session_id="s1"))
eq(requests[-1][2]["session_id"], "s1", "follow-up keeps session id")

eq(run(hermes_mcp.task_status("run_1")),
   {"run_id": "run_1", "status": "completed", "session_id": "s1", "output": "backups ok"},
   "task_status summary drops internals")
eq(run(hermes_mcp.task_status("run_2", wait_seconds=25))["status"], "waiting_for_approval",
   "waiting returns at once on approval")
eq(run(hermes_mcp.task_status("run_2"))["approval"]["command"], "rm -rf /tmp/x", "approval exposed")

run(hermes_mcp.approve("run_2", True))
eq(requests[-1][1:], ("/v1/runs/run_2/approval", {"choice": "once"}), "approve true is once")
run(hermes_mcp.approve("run_2", False))
eq(requests[-1][2], {"choice": "deny"}, "approve false is deny")
eq(run(hermes_mcp.stop_task("run_1"))["status"], "stopping", "stop_task")
eq(run(hermes_mcp.task_status("run_9")), {"error": "Hermes answered 404: Run not found"}, "unknown run")

print("- Hermes unreachable")


def down(request):
    raise httpx.ConnectError("refused", request=request)


stub(down)
eq(run(hermes_mcp.start_task("x")), {"error": "Hermes is unreachable: ConnectError"}, "start_task")
eq(run(hermes_mcp.task_status("run_1")), {"error": "Hermes is unreachable: ConnectError"}, "task_status")

print("- tool list")
names = sorted(t.name for t in run(hermes_mcp.mcp.list_tools()))
eq(names, ["approve", "start_task", "stop_task", "task_status"], "four tools")

print("- bearer auth")
reached = []


async def inner(scope, receive, send):
    reached.append(scope["path"])
    await send({"type": "http.response.start", "status": 200, "headers": []})
    await send({"type": "http.response.body", "body": b"ok"})


guarded = TestClient(hermes_mcp.BearerAuth(inner, hashlib.sha256(b"s3cret").hexdigest()))
eq(guarded.post("/mcp").status_code, 401, "no token")
eq(guarded.post("/mcp", headers={"Authorization": "Bearer wrong"}).status_code, 401, "wrong token")
eq(guarded.post("/mcp", headers={"Authorization": "Basic s3cret"}).status_code, 401, "wrong scheme")
eq(reached, [], "rejected requests never reach the server")
eq(guarded.post("/mcp", headers={"Authorization": "Bearer s3cret"}).status_code, 200, "right token")
eq(reached, ["/mcp"], "accepted request reaches the server")

print(f"\n{checks - failures}/{checks} checks passed")
if failures:
    print(f"{failures} FAILED")
    raise SystemExit(1)
