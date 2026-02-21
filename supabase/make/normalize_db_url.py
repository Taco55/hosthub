#!/usr/bin/env python3
"""Normalize a Postgres DB URL for libpq/psql.

Some passwords contain reserved characters (notably '@'). If these are passed
unescaped inside postgresql:// URLs, psql may parse the host incorrectly.
This helper rewrites the URL with percent-encoded credentials.
"""

import sys
from urllib.parse import quote, urlsplit, urlunsplit


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    raw_url = sys.argv[1] if len(sys.argv) > 1 else ""
    fallback_password = sys.argv[2] if len(sys.argv) > 2 else ""

    if not raw_url:
        fail("Missing DB_URL.")

    parsed = urlsplit(raw_url)

    if parsed.scheme not in {"postgresql", "postgres"}:
        fail("DB_URL must start with postgresql:// or postgres://")
    if not parsed.username or not parsed.hostname:
        fail("DB_URL must include both username and host.")

    password = parsed.password if parsed.password is not None else fallback_password

    userinfo = quote(parsed.username, safe="-._~")
    if password:
        userinfo += ":" + quote(password, safe="-._~")

    host = parsed.hostname
    if ":" in host and not host.startswith("["):
        host = f"[{host}]"

    netloc = f"{userinfo}@{host}"
    if parsed.port:
        netloc += f":{parsed.port}"

    path = parsed.path or "/postgres"
    normalized = urlunsplit((parsed.scheme, netloc, path, parsed.query, ""))
    print(normalized)


if __name__ == "__main__":
    main()
