"""Protocol version this Companion speaks.

Must match AI_PLAYERS_PROTOCOL_VERSION in
addon/lua/ai_players/shared/protocol.lua until the bridge handshake
change replaces the duplicated constant with a real negotiation.
"""

PROTOCOL_VERSION = "1"
