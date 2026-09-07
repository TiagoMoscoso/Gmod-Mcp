-- Minimal Garry's Mod global stand-ins for boot-testing the AI Players
-- GLua module graph outside the engine. Extend as later tasks touch more
-- of the API surface; do not grow this into a full GMod re-implementation
-- (docs/architecture/components.md: "GLua tests are hard in-engine;
-- prefer a small mock").

local M = {}

function M.install(luaRoot, realm)
    SERVER = realm == "server"
    CLIENT = realm == "client"

    -- include() always resolves relative to the "lua/" folder, never to
    -- the caller's own directory. This mirrors real GMod behavior.
    function include(path)
        local chunk, err = loadfile(luaRoot .. path)
        if not chunk then
            error("include() failed to load " .. path .. ": " .. tostring(err), 2)
        end
        return chunk()
    end

    -- Real GMod networks the file to connected clients; boot tests only
    -- need the call to be a harmless no-op.
    function AddCSLuaFile(_path) end
end

return M
