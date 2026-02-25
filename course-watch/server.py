#!/usr/bin/env python3
import base64
import http.server
import os
import urllib.error
import urllib.request

HOST = "0.0.0.0"
PORT = int(os.environ.get("PORT", "8099"))
WWW_ROOT = os.environ.get("WWW_ROOT", "/app/www")
COURSES_JSON_PATH = os.environ.get("COURSES_JSON", "/share/course-watch/courses.json")
MEDIA_URL = os.environ.get("MEDIA_URL", "").rstrip("/")

_user = os.environ.get("WEBDAV_USER", "")
_pass = os.environ.get("WEBDAV_PASS", "")
_auth = (
    "Basic " + base64.b64encode(f"{_user}:{_pass}".encode()).decode()
    if _user else ""
)

_PROXY_PREFIX = "/proxy/"
_FORWARD_REQ_HEADERS = ("Range",)
_FORWARD_RESP_HEADERS = ("Content-Type", "Content-Length", "Content-Range", "Accept-Ranges")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WWW_ROOT, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_HEAD(self):
        if self.path.startswith(_PROXY_PREFIX):
            self._proxy(head=True)
        else:
            super().do_HEAD()

    def do_GET(self):
        if self.path == "/courses.json" or self.path.startswith("/courses.json?"):
            self._serve_courses()
        elif self.path.startswith(_PROXY_PREFIX):
            self._proxy()
        else:
            super().do_GET()

    def _serve_courses(self):
        try:
            with open(COURSES_JSON_PATH, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self._cors()
            self.end_headers()
            self.wfile.write(data)
        except FileNotFoundError:
            self.send_error(404, f"courses.json not found at {COURSES_JSON_PATH}")
        except Exception as e:
            self.send_error(500, str(e))

    def _proxy(self, head: bool = False):
        raw = self.path[len(_PROXY_PREFIX):]
        # Absolute URL passes through; relative path gets MEDIA_URL prepended
        if raw.startswith("http://") or raw.startswith("https://"):
            target = raw
        else:
            target = f"{MEDIA_URL}/{raw.lstrip('/')}" if MEDIA_URL else raw
        req = urllib.request.Request(target, method="HEAD" if head else "GET")
        if _auth:
            req.add_header("Authorization", _auth)
        for h in _FORWARD_REQ_HEADERS:
            if v := self.headers.get(h):
                req.add_header(h, v)
        try:
            with urllib.request.urlopen(req) as resp:
                self.send_response(resp.status)
                for h in _FORWARD_RESP_HEADERS:
                    if v := resp.headers.get(h):
                        self.send_header(h, v)
                self._cors()
                self.end_headers()
                if not head:
                    while chunk := resp.read(65536):
                        self.wfile.write(chunk)
        except urllib.error.HTTPError as e:
            self.send_error(e.code, e.reason)
        except Exception as e:
            self.send_error(502, str(e))

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Range")
        self.send_header("Access-Control-Expose-Headers", "Content-Range, Accept-Ranges")

    def log_message(self, format: str, *args: object) -> None:  # noqa: A002
        print(f"  {self.address_string()} — {format % args}", flush=True)


if __name__ == "__main__":
    os.makedirs(os.path.dirname(COURSES_JSON_PATH), exist_ok=True)
    print(f"course-watch: WebDAV auth {'enabled' if _auth else 'disabled'}", flush=True)
    print(f"course-watch: serving {WWW_ROOT} on {HOST}:{PORT}", flush=True)
    print(f"course-watch: courses.json → {COURSES_JSON_PATH}", flush=True)
    print(f"course-watch: media base URL → {MEDIA_URL or '(none, absolute URLs only)'}", flush=True)
    with http.server.HTTPServer((HOST, PORT), Handler) as srv:
        srv.serve_forever()
