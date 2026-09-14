"""Tests for prose_lint. Run: python3 test_prose_lint.py"""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import prose_lint  # noqa: E402

WORDS = prose_lint.load_filler_words()
HERE = Path(__file__).resolve().parent
SCRIPT = HERE / "prose_lint.py"


def check(text):
    return prose_lint.check_text(text, WORDS)


def run_hook(event, stdin_override=None):
    payload = stdin_override if stdin_override is not None else json.dumps(event)
    proc = subprocess.run(
        [sys.executable, str(SCRIPT)],
        input=payload,
        capture_output=True,
        text=True,
    )
    return proc.returncode, proc.stderr


class Carveout(unittest.TestCase):
    """Task 2.2: regions that are not prose never produce a hit."""

    def test_command_with_double_hyphen(self):
        blocking, _ = check("Run `nixos-rebuild --flake .#host` to apply.")
        self.assertEqual(blocking, [])

    def test_fenced_block_with_spaced_double_hyphen(self):
        text = "Intro text.\n\n```\ngit log -- path/to/file\n```\n\nOutro text.\n"
        blocking, _ = check(text)
        self.assertEqual(blocking, [])

    def test_url_with_dashes(self):
        blocking, _ = check("See https://example.com/a--b/c-d for the details.\n")
        self.assertEqual(blocking, [])

    def test_absolute_path(self):
        blocking, _ = check("It lands in /nix/store/abc-name-1.0/bin/thing today.\n")
        self.assertEqual(blocking, [])

    def test_html_code_element(self):
        blocking, _ = check("<p>Text</p><code>a -- b</code>\n")
        self.assertEqual(blocking, [])

    def test_mask_preserves_line_numbers(self):
        text = "one\n```\ntwo\n```\nfour — here\n"
        blocking, _ = check(text)
        self.assertEqual(len(blocking), 1)
        self.assertEqual(blocking[0][0], 5)


class BlockingRules(unittest.TestCase):
    """Task 2.3: typography that no context calls for fails the write."""

    def test_em_dash(self):
        blocking, _ = check("The change — long overdue — landed.\n")
        self.assertEqual(len(blocking), 2)
        self.assertEqual(blocking[0][1], "em dash")

    def test_en_dash(self):
        blocking, _ = check("It took 3 – 4 hours.\n")
        self.assertEqual(blocking[0][1], "en dash")

    def test_spaced_double_hyphen_in_prose(self):
        blocking, _ = check("The policy -- announced late -- applies now.\n")
        self.assertEqual(len(blocking), 2)
        self.assertEqual(blocking[0][1], "double hyphen as dash")

    def test_curly_quotes(self):
        blocking, _ = check("He said “hello” and it’s fine.\n")
        self.assertEqual(len(blocking), 3)

    def test_clean_prose_passes(self):
        blocking, filler = check("A plain sentence, with a comma. And a second one.\n")
        self.assertEqual(blocking, [])
        self.assertEqual(filler, [])


class FillerWords(unittest.TestCase):
    """Task 2.4: reported with their sentence, never blocking."""

    def test_both_uses_are_reported(self):
        text = "Dat is eigenlijk niet waar. Dat is eigenlijk best goed.\n"
        blocking, filler = check(text)
        self.assertEqual(blocking, [])
        self.assertEqual(len(filler), 2)

    def test_sentence_is_carried(self):
        _, filler = check("Dat is eigenlijk niet waar. Iets anders.\n")
        self.assertIn("eigenlijk", filler[0][2])
        self.assertTrue(filler[0][2].startswith("Dat is"))

    def test_multiword_entry(self):
        _, filler = check("Het is in feite een andere zaak.\n")
        self.assertEqual(filler[0][1], "in feite")

    def test_english_words(self):
        _, filler = check("This is literally the same thing.\n")
        self.assertEqual(filler[0][1], "literally")

    def test_not_matched_inside_a_word(self):
        _, filler = check("Adjustment and justice are unrelated.\n")
        self.assertEqual(filler, [])

    def test_filler_in_code_is_ignored(self):
        _, filler = check("Use `just build` to compile.\n")
        self.assertEqual(filler, [])


class HookProtocol(unittest.TestCase):
    """Tasks 2.5 and 2.6: file scope, and never break a session."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, name, text):
        path = self.dir / name
        path.write_text(text, encoding="utf-8")
        return path

    def event_for(self, path):
        return {
            "hook_event_name": "PostToolUse",
            "cwd": str(self.dir),
            "tool_input": {"file_path": str(path)},
        }

    def test_markdown_with_em_dash_fails(self):
        path = self.write("doc.md", "A sentence — with a dash.\n")
        code, err = run_hook(self.event_for(path))
        self.assertEqual(code, 2)
        self.assertIn("line 1", err)
        self.assertIn("em dash", err)

    def test_nix_file_is_skipped(self):
        path = self.write("mod.nix", "# a comment — with a dash\n")
        code, err = run_hook(self.event_for(path))
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_filler_only_does_not_fail(self):
        path = self.write("doc.md", "Dat is eigenlijk best goed.\n")
        code, err = run_hook(self.event_for(path))
        self.assertEqual(code, 0)
        self.assertIn("filler", err)

    def test_clean_markdown_is_silent(self):
        path = self.write("doc.md", "A clean sentence, nothing wrong here.\n")
        code, err = run_hook(self.event_for(path))
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_relative_path_resolves_against_cwd(self):
        self.write("rel.md", "A sentence — here.\n")
        event = {
            "hook_event_name": "PostToolUse",
            "cwd": str(self.dir),
            "tool_input": {"file_path": "rel.md"},
        }
        code, _ = run_hook(event)
        self.assertEqual(code, 2)

    def test_malformed_json(self):
        code, err = run_hook(None, stdin_override="{not json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_empty_stdin(self):
        code, err = run_hook(None, stdin_override="")
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_missing_file(self):
        event = self.event_for(self.dir / "does-not-exist.md")
        code, err = run_hook(event)
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_no_file_path(self):
        code, err = run_hook({"hook_event_name": "PostToolUse", "tool_input": {}})
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_non_dict_event(self):
        code, err = run_hook(None, stdin_override="[1,2,3]")
        self.assertEqual(code, 0)
        self.assertEqual(err, "")


class CommandLineMode(unittest.TestCase):
    """Task 1.1 and 1.2: runnable by hand, and not filtered by file type."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, name, text):
        path = self.dir / name
        path.write_text(text, encoding="utf-8")
        return path

    def run_cli(self, *args):
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            input="",
            capture_output=True,
            text=True,
        )
        return proc.returncode, proc.stderr

    def test_file_with_violation_exits_nonzero(self):
        path = self.write("a.md", "A sentence \u2014 with a dash.\n")
        code, err = self.run_cli(str(path))
        self.assertEqual(code, 1)
        self.assertIn("em dash", err)

    def test_clean_file_exits_zero(self):
        path = self.write("a.md", "A clean sentence, nothing wrong.\n")
        code, err = self.run_cli(str(path))
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_several_files_each_reported(self):
        a = self.write("a.md", "One \u2014 here.\n")
        b = self.write("b.md", "Two \u2014 there.\n")
        code, err = self.run_cli(str(a), str(b))
        self.assertEqual(code, 1)
        self.assertIn("a.md", err)
        self.assertIn("b.md", err)

    def test_one_bad_among_good_still_fails(self):
        a = self.write("a.md", "Clean enough.\n")
        b = self.write("b.md", "Bad \u2014 here.\n")
        code, _ = self.run_cli(str(a), str(b))
        self.assertEqual(code, 1)

    def test_named_source_file_is_checked(self):
        path = self.write("mod.nix", "# a comment \u2014 with a dash\n")
        code, err = self.run_cli(str(path))
        self.assertEqual(code, 1)
        self.assertIn("em dash", err)

    def test_same_source_file_via_hook_is_still_skipped(self):
        path = self.write("mod.nix", "# a comment \u2014 with a dash\n")
        event = {"hook_event_name": "PostToolUse",
                 "tool_input": {"file_path": str(path)}}
        code, err = run_hook(event)
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_filler_alone_does_not_fail_cli(self):
        path = self.write("a.md", "Dat is eigenlijk best goed.\n")
        code, err = self.run_cli(str(path))
        self.assertEqual(code, 0)
        self.assertIn("filler", err)

    def test_unreadable_file_fails_with_a_message(self):
        code, err = self.run_cli(str(self.dir / "nope.md"))
        self.assertEqual(code, 1)
        self.assertIn("cannot read", err)

    def test_no_args_with_empty_stdin_still_exits_zero(self):
        code, err = self.run_cli()
        self.assertEqual(code, 0)
        self.assertEqual(err, "")

    def test_help(self):
        code, err = self.run_cli("--help")
        self.assertEqual(code, 0)
        self.assertIn("usage", err)


class WordList(unittest.TestCase):
    def test_list_loads_and_is_not_empty(self):
        self.assertGreater(len(WORDS), 5)
        self.assertIn("letterlijk", WORDS)

    def test_longest_first(self):
        lengths = [len(w) for w in WORDS]
        self.assertEqual(lengths, sorted(lengths, reverse=True))


if __name__ == "__main__":
    unittest.main(verbosity=2)
