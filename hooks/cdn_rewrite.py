import os
import re

def on_post_page(output, page, config):
    """
    Rewrite asset URLs to CDN.
    CDN is enabled by default.
    Disable with MKDOCS_CDN_ENABLED=0 for local dev.
    """
    if os.getenv("MKDOCS_CDN_ENABLED", "1") == "0":
        return output  # local dev: no rewrite

    extra = config.get("extra", {}) or {}

    base_url   = (extra.get("cdn_base_url") or "").rstrip("/")
    namespace  = (extra.get("cdn_namespace") or "").strip("/")
    app        = (extra.get("cdn_app") or "").strip("/")
    version    = (extra.get("cdn_version") or "").strip("/")

    # bcit-ltc/infrastructure-documentation/1.1.11
    prefix = "/".join([namespace, app, version])

    if not base_url or not prefix:
        return output

    # Match any href/src pointing to an asset (relative URLs only)
    pattern = re.compile(r'(href|src)="(?!https?://)([^"]*assets/[^"]*)"')

    def repl(m):
        attr = m.group(1)
        original = m.group(2)

        # Preserve fragments (#only-light)
        if "#" in original:
            path_part, fragment = original.split("#", 1)
            fragment = "#" + fragment
        else:
            path_part = original
            fragment = ""

        # Remove ../ or ./ prefixes
        normalized = re.sub(r'^(\./|\.\./)+', '', path_part)

        new_url = f"{base_url}/{prefix}/{normalized}"
        return f'{attr}="{new_url}{fragment}"'

    return pattern.sub(repl, output)
