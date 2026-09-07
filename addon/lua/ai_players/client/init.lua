-- Client-only module root.
AI_PLAYERS = AI_PLAYERS or {}

AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
AI_PLAYERS.CompanionMcpUrl = nil
AI_PLAYERS.CompanionPopup = nil
AI_PLAYERS.SetupGuideUrl = "https://github.com/TiagoMoscoso/Gmod-MCP#readme"

function AI_PLAYERS.BuildCompanionPopupModel(status, mcpUrl)
    local online = status == AI_PLAYERS.CompanionState.CONNECTED and mcpUrl ~= nil and mcpUrl ~= ""
    return {
        title = "AI Players",
        status_text = online and "MCP Server Online" or "Companion Not Ready",
        mcp_url = online and mcpUrl or nil,
        copy_enabled = online,
        setup_guide_url = AI_PLAYERS.SetupGuideUrl,
        setup_guide_enabled = not online,
    }
end

function AI_PLAYERS.SetCompanionPopupState(status, mcpUrl)
    AI_PLAYERS.CompanionStatus = status
    AI_PLAYERS.CompanionMcpUrl = mcpUrl ~= "" and mcpUrl or nil
end

function AI_PLAYERS.ShowCompanionPopup()
    local model = AI_PLAYERS.BuildCompanionPopupModel(AI_PLAYERS.CompanionStatus, AI_PLAYERS.CompanionMcpUrl)
    if not vgui then
        return model
    end

    if IsValid(AI_PLAYERS.CompanionPopup) then
        AI_PLAYERS.CompanionPopup:Remove()
    end

    local frame = vgui.Create("DFrame")
    AI_PLAYERS.CompanionPopup = frame
    frame:SetTitle(model.title)
    frame:SetSize(420, 180)
    frame:Center()
    frame:MakePopup()

    local statusLabel = vgui.Create("DLabel", frame)
    statusLabel:SetPos(16, 36)
    statusLabel:SetSize(388, 24)
    statusLabel:SetText(model.status_text)

    if model.copy_enabled then
        local urlEntry = vgui.Create("DTextEntry", frame)
        urlEntry:SetPos(16, 68)
        urlEntry:SetSize(388, 24)
        urlEntry:SetText(model.mcp_url)
        urlEntry:SetEditable(false)

        local copyButton = vgui.Create("DButton", frame)
        copyButton:SetPos(16, 104)
        copyButton:SetSize(160, 28)
        copyButton:SetText("Copy MCP URL")
        copyButton.DoClick = function()
            SetClipboardText(model.mcp_url)
        end
    else
        local helpLabel = vgui.Create("DLabel", frame)
        helpLabel:SetPos(16, 68)
        helpLabel:SetSize(388, 24)
        helpLabel:SetText("Companion required")

        local setupButton = vgui.Create("DButton", frame)
        setupButton:SetPos(16, 104)
        setupButton:SetSize(160, 28)
        setupButton:SetText("Setup Guide")
        setupButton.DoClick = function()
            gui.OpenURL(model.setup_guide_url)
        end
    end

    return model
end

if net then
    net.Receive("AIPlayersCompanionStatus", function()
        AI_PLAYERS.SetCompanionPopupState(net.ReadString(), net.ReadString())
        AI_PLAYERS.ShowCompanionPopup()
    end)
end
