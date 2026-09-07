-- Protocol version this addon speaks.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS_PROTOCOL_VERSION = "1"

AI_PLAYERS_BRIDGE_MESSAGE = {
    HELLO = "hello",
    HELLO_OK = "hello_ok",
    HELLO_REJECT = "hello_reject",
}
