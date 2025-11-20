# hooks/cdn_rewrite.py
import os
import re
from pathlib import Path

def _read_version():
    root = Path(__file__).resolve().parent.parent
    version_file = root / "VERSION"
    try:
        return version_file.read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        return ""

def on_post_page(output, page, config):
    if os.getenv("MKDOCS_CDN_ENABLED", "1") == "0":
        return output

    extra = config.get("extra", {}) or {}
    base_url   = (extra.get("cdn_base_url") or "").rstrip("/")
    namespace  = (extra.get("cdn_namespace") or "").strip("/")
    app        = (extra.get("cdn_app") or "").strip("/")
    version    = _read_version().strip("/")

    if not base_url or not namespace or not app or not version:
        return output

    prefix = "/".join([namespace, app, version])

    pattern = re.compile(r'(href|src)="(?!https?://)([^"]*assets/[^"]*)"')

    def repl(m):
        attr = m.group(1)
        original = m.group(2)

        if "#" in original:
            path_part, fragment = original.split("#", 1)
            fragment = "#" + fragment
        else:
            path_part = original
            fragment = ""

        normalized = re.sub(r'^(\./|\.\./)+', '', path_part)
        new_url = f"{base_url}/{prefix}/{normalized}"
        return f'{attr}="{new_url}{fragment}"'

    return pattern.sub(repl, output)
