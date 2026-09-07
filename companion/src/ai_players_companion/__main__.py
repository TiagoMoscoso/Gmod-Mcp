"""Companion process entry point: serves the MCP host over Streamable HTTP."""

from .mcp.server import build_server
from .protocol import PROTOCOL_VERSION


def main() -> None:
    app = build_server()
    print(
        f"ai-players-companion (protocol {PROTOCOL_VERSION}): "
        f"serving MCP at http://{app.settings.host}:{app.settings.port}{app.settings.streamable_http_path}"
    )
    app.run(transport="streamable-http")


if __name__ == "__main__":
    main()
