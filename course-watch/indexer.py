#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests"]
# ///
"""Course Watch — WebDAV Indexer

Browse a WebDAV server interactively and generate courses.json.
Expects a 3-level hierarchy: root / course / section / video-files

Usage:
    uv run indexer.py <url> [--user USER] [--password PASS]
    python indexer.py http://nas/dav/ --user admin --password s3cr3t
"""

from __future__ import annotations

import argparse
import curses
import json
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse, unquote
from xml.etree import ElementTree as ET

import requests

# ── Constants ──────────────────────────────────────────────────────────────────

VIDEO_EXT = frozenset({".mp4", ".mkv", ".avi", ".mov", ".webm", ".m4v", ".ts"})
SUB_EXT   = frozenset({".srt", ".vtt", ".sub"})
DAV_NS    = "DAV:"

# Color pair IDs
_CH = 1   # header bar     (black on cyan)
_CC = 2   # cursor row      (black on yellow)
_CD = 3   # directory name  (cyan on default)
_CE = 4   # error           (red on default)
_CS = 5   # status/loading  (yellow on default)


# ── Data ───────────────────────────────────────────────────────────────────────

@dataclass
class Entry:
    name: str
    href: str
    is_dir: bool


# ── WebDAV client ──────────────────────────────────────────────────────────────

class WebDAVError(Exception):
    pass


class WebDAVClient:
    def __init__(self, base_url: str, user: str = "", password: str = "") -> None:
        self.base_url = base_url
        self.session  = requests.Session()
        if user:
            self.session.auth = (user, password)

    def list(self, url: str) -> list[Entry]:
        url = url.rstrip("/") + "/"
        headers = {
            "Depth": "1",
            "Content-Type": 'application/xml; charset="utf-8"',
        }
        body = (
            '<?xml version="1.0" encoding="utf-8"?>'
            '<D:propfind xmlns:D="DAV:">'
            "<D:prop><D:resourcetype/><D:displayname/></D:prop>"
            "</D:propfind>"
        )
        try:
            r = self.session.request("PROPFIND", url, headers=headers, data=body, timeout=15)
        except requests.RequestException as e:
            raise WebDAVError(str(e)) from e

        if r.status_code == 401:
            raise WebDAVError("Authentication failed (HTTP 401)")
        if r.status_code not in (207, 200):
            raise WebDAVError(f"HTTP {r.status_code}: {r.reason}")

        return self._parse(url, r.text)

    def _parse(self, base_url: str, xml_text: str) -> list[Entry]:
        try:
            root = ET.fromstring(xml_text)
        except ET.ParseError as e:
            raise WebDAVError(f"Malformed XML: {e}") from e

        base_path   = urlparse(base_url).path.rstrip("/")
        parsed_base = urlparse(base_url)
        entries: list[Entry] = []

        for resp in root.findall(f"{{{DAV_NS}}}response"):
            href_el = resp.find(f"{{{DAV_NS}}}href")
            if href_el is None or not href_el.text:
                continue

            raw_path = unquote(href_el.text).rstrip("/")
            if raw_path == base_path:
                continue  # skip the directory itself

            is_dir = resp.find(f".//{{{DAV_NS}}}collection") is not None

            full_url = (
                f"{parsed_base.scheme}://{parsed_base.netloc}"
                + href_el.text.rstrip("/")
            )
            if is_dir:
                full_url += "/"

            name = unquote(raw_path.split("/")[-1])
            entries.append(Entry(name=name, href=full_url, is_dir=is_dir))

        # Directories first, then files — each group alphabetically
        entries.sort(key=lambda e: (not e.is_dir, e.name.lower()))
        return entries


# ── courses.json builder ───────────────────────────────────────────────────────

def _humanise(stem: str) -> str:
    """'01_intro-to_python.extra' → '01 intro to python extra'"""
    return stem.replace("_", " ").replace("-", " ").replace(".", " ").strip()


def _relative(href: str, root_url: str) -> str:
    """Return the path of href relative to root_url.

    https://nas/dav/courses/Python/S1/video.mp4, root=https://nas/dav/courses/
    → Python/S1/video.mp4
    """
    root_path = urlparse(root_url).path.rstrip("/") + "/"
    file_path = unquote(urlparse(href).path)
    if file_path.startswith(root_path):
        return file_path[len(root_path):]
    return href  # fallback: return full URL if paths don't match


def _find_subtitle(video_stem: str, sub_files: list[Entry]) -> str | None:
    """Find the best subtitle file for a given video stem.

    Matches (in priority order):
      exact:   video.srt  / video.sub  / video.vtt
      prefixed: video.en.srt / video.en.us.srt / video.forced.srt
    """
    exact: str | None   = None
    prefix: str | None  = None
    for f in sub_files:
        if Path(f.name).suffix.lower() not in SUB_EXT:
            continue
        base = Path(f.name).stem   # "video.en.srt" → "video.en"
        if base == video_stem:
            exact = f.href
        elif prefix is None and base.startswith(video_stem + "."):
            prefix = f.href
    return exact or prefix


def build_courses(
    client: WebDAVClient,
    root_url: str,
    on_progress: Callable[[str, int, int], None] | None = None,
) -> dict:
    """Traverse root → courses → sections → videos and build the JSON structure.

    on_progress(label, current, total) is called before each course is scanned.
    """
    # Pre-fetch course list so we know the total for the progress bar.
    all_course_entries = [e for e in client.list(root_url) if e.is_dir]
    total   = len(all_course_entries)
    courses = []

    for i, course_entry in enumerate(all_course_entries):
        if on_progress:
            on_progress(course_entry.name, i, total)

        sections = []
        for section_entry in client.list(course_entry.href):
            if not section_entry.is_dir:
                continue

            all_files = [f for f in client.list(section_entry.href) if not f.is_dir]
            sub_files = [f for f in all_files if Path(f.name).suffix.lower() in SUB_EXT]

            videos = []
            for f in all_files:
                if Path(f.name).suffix.lower() not in VIDEO_EXT:
                    continue
                stem       = Path(f.name).stem
                video_path = _relative(f.href, root_url)
                entry: dict = {"title": _humanise(stem), "video": video_path}
                sub_href = _find_subtitle(stem, sub_files)
                if sub_href:
                    entry["sub"] = _relative(sub_href, root_url)
                videos.append(entry)

            if videos:
                sections.append({"name": section_entry.name, "videos": videos})

        if sections:
            courses.append({"name": course_entry.name, "sections": sections})

    return {"courses": courses}


# ── TUI ────────────────────────────────────────────────────────────────────────

class Browser:
    def __init__(self, client: WebDAVClient, start_url: str) -> None:
        self.client    = client
        self.url       = start_url
        self.entries:  list[Entry] = []
        self.sel       = 0
        self._offset   = 0
        self.msg       = ""
        self.is_error  = False
        # Navigation stack: (url, entries, sel, offset)
        self._stack: list[tuple[str, list[Entry], int, int]] = []

    # ── Public ────────────────────────────────────────────────────────────────

    def run(self) -> Path | None:
        return curses.wrapper(self._loop)

    # ── Internals ─────────────────────────────────────────────────────────────

    def _loop(self, scr) -> Path | None:
        self._init_colors()
        curses.curs_set(0)
        self._load(self.url)

        while True:
            h, w = scr.getmaxyx()
            scr.erase()
            self._draw(scr, h, w)
            scr.refresh()

            key = scr.getch()

            # ── Navigation ───────────────────────────────────────────────────
            if key in (27, ord("q"), curses.KEY_LEFT, curses.KEY_BACKSPACE):
                if self._stack:
                    self.url, self.entries, self.sel, self._offset = self._stack.pop()
                    self.msg = ""
                    self.is_error = False
                else:
                    return None  # exit at root

            elif key == curses.KEY_UP:
                if self.sel > 0:
                    self.sel -= 1

            elif key == curses.KEY_DOWN:
                if self.sel < len(self.entries) - 1:
                    self.sel += 1

            elif key in (curses.KEY_ENTER, 10, 13, curses.KEY_RIGHT):
                if self.entries and self.entries[self.sel].is_dir:
                    self._stack.append((self.url, self.entries, self.sel, self._offset))
                    self._load(self.entries[self.sel].href)

            # ── Generate ─────────────────────────────────────────────────────
            elif key == ord("g"):
                result = self._generate(scr)
                if result is not None:
                    return result

    def _load(self, url: str) -> None:
        self.msg = "Loading…"
        self.is_error = False
        try:
            self.entries = self.client.list(url)
            self.url     = url
            self.sel     = 0
            self._offset = 0
            self.msg     = ""
        except WebDAVError as e:
            self.is_error = True
            self.msg      = str(e)

    def _generate(self, scr) -> Path | None:
        _, w = scr.getmaxyx()

        def redraw_header() -> None:
            scr.erase()
            scr.addstr(0, 0, " Generating courses.json ".center(w, "─"),
                       curses.color_pair(_CH) | curses.A_BOLD)
            scr.addstr(2, 2, f"Root : {self.url}"[:w - 3])

        def draw_progress(label: str, current: int, total: int) -> None:
            redraw_header()
            bar_w  = max(10, w - 16)
            filled = int(bar_w * current / total) if total else 0
            bar    = "█" * filled + "░" * (bar_w - filled)
            scr.addstr(4, 2, f"[{bar}] {current}/{total}",
                       curses.color_pair(_CS))
            if label:
                scr.addstr(5, 4, label[:w - 6], curses.A_DIM)
            scr.refresh()

        redraw_header()
        scr.addstr(4, 2, "Scanning…", curses.A_DIM)
        scr.refresh()

        try:
            data = build_courses(self.client, self.url, on_progress=draw_progress)
            out  = Path(__file__).with_name("courses.json")
            out.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")

            nc = len(data["courses"])
            ns = sum(len(c["sections"]) for c in data["courses"])
            nv = sum(len(s["videos"])   for c in data["courses"] for s in c["sections"])

            redraw_header()
            bar_w = max(10, w - 16)
            scr.addstr(4, 2, f"[{'█' * bar_w}] done", curses.color_pair(_CD))
            scr.addstr(6, 2, f"  Saved: {out}"[:w - 3],
                       curses.color_pair(_CD) | curses.A_BOLD)
            scr.addstr(7, 4, f"{nc} course{'s' if nc != 1 else ''}  "
                             f"{ns} section{'s' if ns != 1 else ''}  "
                             f"{nv} video{'s' if nv != 1 else ''}")
            scr.addstr(9, 2, "Press any key to exit.", curses.A_DIM)
            scr.refresh()
            scr.getch()
            return out

        except WebDAVError as e:
            redraw_header()
            scr.addstr(4, 2, f"Error: {e}"[:w - 4], curses.color_pair(_CE))
            scr.addstr(6, 2, "Press any key to continue.", curses.A_DIM)
            scr.refresh()
            scr.getch()
            return None

    def _draw(self, scr, h: int, w: int) -> None:
        # ── Header ───────────────────────────────────────────────────────────
        scr.addstr(0, 0, " Course Watch — WebDAV Indexer ".center(w, "─"),
                   curses.color_pair(_CH) | curses.A_BOLD)

        # ── Current URL ───────────────────────────────────────────────────────
        depth = len(self._stack)
        hint  = f"  [{depth} level{'s' if depth != 1 else ''} deep]" if depth else ""
        url_display = self.url
        max_url = w - len(hint) - 3
        if len(url_display) > max_url:
            url_display = "…" + url_display[-(max_url - 1):]
        scr.addstr(1, 1, f" {url_display}{hint}"[:w - 1], curses.A_DIM)

        scr.addstr(2, 0, "─" * w, curses.A_DIM)

        # ── Message / status ──────────────────────────────────────────────────
        list_top = 3
        if self.msg:
            attr = curses.color_pair(_CE) if self.is_error else curses.color_pair(_CS)
            scr.addstr(list_top, 2, self.msg[:w - 4], attr)
            list_top += 1

        # ── Entry list ────────────────────────────────────────────────────────
        list_h = h - 2 - list_top

        # Keep selection visible (update scroll offset)
        if self.sel < self._offset:
            self._offset = self.sel
        elif self.sel >= self._offset + list_h:
            self._offset = self.sel - list_h + 1
        self._offset = max(0, self._offset)

        for i in range(list_h):
            idx = self._offset + i
            if idx >= len(self.entries):
                break

            entry    = self.entries[idx]
            selected = idx == self.sel
            cursor   = "▶" if selected else " "
            suffix   = "/" if entry.is_dir else ""
            line     = f" {cursor} {entry.name}{suffix}"

            if selected:
                attr = curses.color_pair(_CC) | curses.A_BOLD
            elif entry.is_dir:
                attr = curses.color_pair(_CD)
            else:
                attr = curses.A_DIM

            try:
                scr.addstr(list_top + i, 0, line[:w], attr)
            except curses.error:
                pass

        if not self.entries and not self.msg:
            try:
                scr.addstr(list_top + 1, 4, "(empty directory)", curses.A_DIM)
            except curses.error:
                pass

        # ── Footer ────────────────────────────────────────────────────────────
        footer = (
            " ↑↓ move   →/Enter: open   ←/Esc: back   g: generate courses.json   q: quit "
        )
        try:
            scr.addstr(h - 1, 0, footer.ljust(w)[:w], curses.color_pair(_CH))
        except curses.error:
            pass

    @staticmethod
    def _init_colors() -> None:
        curses.use_default_colors()
        curses.init_pair(_CH, curses.COLOR_BLACK,  curses.COLOR_CYAN)    # header/footer
        curses.init_pair(_CC, curses.COLOR_BLACK,  curses.COLOR_YELLOW)  # selected row
        curses.init_pair(_CD, curses.COLOR_CYAN,   -1)                   # directory
        curses.init_pair(_CE, curses.COLOR_RED,    -1)                   # error
        curses.init_pair(_CS, curses.COLOR_YELLOW, -1)                   # status


# ── Entry point ────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        prog="indexer",
        description="Browse a WebDAV server and generate courses.json for Course Watch",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
examples:
  uv run indexer.py https://nas.local/dav/ --user admin --password secret
  python indexer.py http://localhost:8080/webdav/
  uv run indexer.py https://files.example.com/ -u bob -p hunter2
        """,
    )
    parser.add_argument("url",                        help="WebDAV base URL")
    parser.add_argument("--user",     "-u", default="", help="Username")
    parser.add_argument("--password", "-p", default="", help="Password")
    args = parser.parse_args()

    url    = args.url if args.url.endswith("/") else args.url + "/"
    client = WebDAVClient(url, args.user, args.password)

    print(f"Connecting to {url} … ", end="", flush=True)
    try:
        client.list(url)
        print("OK")
    except WebDAVError as e:
        print(f"failed\n{e}", file=sys.stderr)
        sys.exit(1)

    try:
        result = Browser(client, url).run()
    except KeyboardInterrupt:
        sys.exit(0)

    if result:
        print(f"\nSaved: {result}")


if __name__ == "__main__":
    main()
