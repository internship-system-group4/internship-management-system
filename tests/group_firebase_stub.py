"""Small local Firebase REST stand-in for the group assignment smoke test."""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

state = {
    "users": {
        "a1": {"Id": "a1", "Role": 3, "IsActive": True, "FullName": "Supervisor One", "Email": "one@example.test", "GroupIds": []},
        "a2": {"Id": "a2", "Role": 3, "IsActive": True, "FullName": "Supervisor Two", "Email": "two@example.test", "GroupIds": []},
        "s1": {"Id": "s1", "Role": 1, "IsActive": True, "FullName": "Student One", "Email": "s1@example.test", "StudentNumber": "1001"},
        "s2": {"Id": "s2", "Role": 1, "IsActive": True, "FullName": "Student Two", "Email": "s2@example.test", "StudentNumber": "1002"},
    },
    "studentGroups": {},
    "placements": {
        "s1": {"Id": "s1", "StudentId": "s1", "AcademicSupervisorId": None},
        "s2": {"Id": "s2", "StudentId": "s2", "AcademicSupervisorId": None},
    },
}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        url = urlsplit(self.path)
        path = url.path.removesuffix(".json").strip("/")
        value = state
        for key in filter(None, path.split("/")):
            value = value.get(key) if isinstance(value, dict) else None
            if value is None:
                break
        query = parse_qs(url.query)
        if isinstance(value, dict) and "orderBy" in query and "equalTo" in query:
            field = json.loads(query["orderBy"][0])
            expected = json.loads(query["equalTo"][0])
            value = {key: item for key, item in value.items() if item.get(field) == expected}
        self.reply(value)

    def do_PATCH(self):
        assert self.path.split("?", 1)[0] == "/.json"
        changes = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        for path, value in changes.items():
            keys = path.split("/")
            node = state
            for key in keys[:-1]:
                node = node.setdefault(key, {})
            if value is None:
                node.pop(keys[-1], None)
            else:
                node[keys[-1]] = value
        self.reply(changes)

    def reply(self, value):
        body = json.dumps(value).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


ThreadingHTTPServer(("127.0.0.1", 18765), Handler).serve_forever()
