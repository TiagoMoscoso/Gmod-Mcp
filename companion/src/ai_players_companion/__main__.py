"""Companion process entry point.

This skeleton does not host MCP, bind a port, or serve /mcp. It only
confirms the package installs and runs; the MCP host lands in the
companion-mcp-host change.
"""

from .protocol import PROTOCOL_VERSION


def main() -> None:
    print(f"ai-players-companion (protocol {PROTOCOL_VERSION}): MCP is not hosted yet.")


if __name__ == "__main__":
    main()
