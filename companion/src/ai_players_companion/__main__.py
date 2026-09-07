"""Companion process entry point: serves the MCP host over Streamable HTTP."""

import argparse
import os
from pathlib import Path

from .mcp.server import build_server
from .protocol import PROTOCOL_VERSION
from .transport.file_ipc import BridgePaths, FileIpcBridge


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the GMod AI Players Companion.")
    parser.add_argument(
        "--gmod-data",
        default=os.environ.get("AI_PLAYERS_GMOD_DATA"),
        help="Path to Garry's Mod garrysmod/data for the file IPC bridge.",
    )
    args = parser.parse_args()

    bridge = None
    if args.gmod_data:
        bridge = FileIpcBridge(BridgePaths.from_gmod_data(Path(args.gmod_data)))
        bridge.start()

    app = build_server()
    print(
        f"ai-players-companion (protocol {PROTOCOL_VERSION}): "
        f"serving MCP at http://{app.settings.host}:{app.settings.port}{app.settings.streamable_http_path}"
    )
    if bridge is not None:
        print(f"ai-players-companion: file IPC bridge at {bridge.paths.root}")
    try:
        app.run(transport="streamable-http")
    finally:
        if bridge is not None:
            bridge.stop()


if __name__ == "__main__":
    main()
