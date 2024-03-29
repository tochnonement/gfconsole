--[[

Author: tochnonement
Email: tochnonement@gmail.com

14/11/2021

--]]

hook.Add("InitPostEntity", "gfconsole.AutoSubscribe", function()
    if GetConVar("cl_gfconsole_auto_open"):GetBool() then
        gfconsole.show()
    end

    if GetConVar("cl_gfconsole_auto_subscribe"):GetBool() then
        net.Start("gfconsole:Subscribe")
            net.WriteBool(true)
        net.SendToServer()
    end
end)

hook.Add("OnScreenSizeChanged", "gfconsole.Adapt", function()
    local frame = gfconsole.frame
    if IsValid(frame) then
        frame:LoadCookies()
    end
end)