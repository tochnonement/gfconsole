--[[

Author: tochonement
Email: tochonement@gmail.com

11.03.2021

--]]

PANEL = {}

function PANEL:Init()
    self.control = self:Add("DHorizontalScroller")
    self.control:SetTall(30)
    self.control:SetOverlap(-2)

    self.selector = self:Add("GFConsole.Selector")
    self.selector:SetWide(200)
    self.selector:AddConvar("cl_gfconsole_realm", {
        {"client", "CLIENT"},
        {"server", "SERVER"},
        {"both", "BOTH"}
    })

    self.richtext = self:Add("RichText")
    self.richtext.PerformLayout = function(panel)
        panel:SetFontInternal("gfconsole.Text")
        panel:SetUnderlineFont("gfconsole.Text.underline")
    end
    self.richtext.ActionSignal = function(panel, name, value)
        if name == "TextClicked" then
            local for_copy = string.match(value, "%b@@")
            if for_copy then
                for_copy = for_copy:Replace("@", "")

                SetClipboardText(for_copy)

                notification.AddLegacy("Copied to clipboard!", 0, 2)
            end
        end
    end
    self.richtext.Paint = function(panel, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    self.control:AddPanel(self.selector)

    self:AddIconButton("icon16/cog.png", gfconsole.show_settings)
    self:AddIconButton("icon16/page_white.png", function()
        self.richtext:SetText("")
    end)

    self:LoadButtons()
    self:LoadFilters()
end

function PANEL:PerformLayout(w, h)
    self.control:Dock(TOP)
    self.control:SetTall(25)
    self.control:DockMargin(0, 0, 0, 5)

    self.richtext:Dock(FILL)
end

function PANEL:Paint(w, h)
    -- surface.SetDrawColor(0, 0, 0, 100)
    -- surface.DrawRect(0, 0, w, h)
end

function PANEL:UpdateToolBarVisibility()
    local bool = gfconsole.holding
    local old = self.control:IsVisible()

    if not GetConVar("cl_gfconsole_hidetoolbar"):GetBool() then
        bool = true
    end

    self.control:SetVisible(bool)

    if old ~= bool then
        self:InvalidateLayout()
    end
end

function PANEL:Think()
    if not GetConVar("cl_gfconsole_hidetoolbar"):GetBool() then return end

    self:UpdateToolBarVisibility()
end

function PANEL:AddCheckbox(text, bool, func)
    local checkbox = vgui.Create("GFConsole.Checkbox")
    checkbox:SetText("Show: " .. text)
    checkbox:SetValue(bool)
    checkbox.OnChange = function(panel, bool)
        func(bool)
    end
    checkbox:SizeToContentsX(20)

    self.control:AddPanel(checkbox)

    return checkbox
end

function PANEL:AddRecord(...)
    for _, object in ipairs({...}) do
        if isstring(object) or isnumber(object) then
            object = tostring(object)
            if object:match("Vector") then
                self.richtext:InsertClickableTextStart("@" .. object.. "@")
                    self.richtext:AppendText(object)
                self.richtext:InsertClickableTextEnd()
            elseif object:match("Angle") then
                self.richtext:InsertClickableTextStart("@" .. object.. "@")
                    self.richtext:AppendText(object)
                self.richtext:InsertClickableTextEnd()
            else
                self.richtext:AppendText(object)
            end
        else
            self.richtext:InsertColorChange(object.r, object.g, object.b, object.a)
        end
    end
end

function PANEL:AddButton(name, func)
    local button = vgui.Create("gfconsole.Button")
    button:SetText(name)
    button:SizeToContentsX(20)
    button.DoClick = function()
        func()
    end

    self.control:AddPanel(button)
end

function PANEL:AddIconButton(matPath, func)
    local mat = Material(matPath)
    local button = vgui.Create("gfconsole.Button")
    button:SetWide(self.control:GetTall())
    button:SetText("")
    button.DoClick = function()
        func()
    end
    button.PaintOver = function(p, w, h)
        -- local iw, ih = h * .5, h * .5
        local iw, ih = 16, 16
        local ix, iy = w * .5 - iw * .5, h * .5 - ih * .5

        surface.SetMaterial(mat)
        surface.SetDrawColor(color_black)
        surface.DrawTexturedRect(ix, iy + 1, iw, ih)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(ix, iy, iw, ih)
    end

    self.control:AddPanel(button)
end

function PANEL:LoadButtons()
    for _, data in pairs(gfconsole.buttons.get()) do
        self:AddButton(data.name, data.func)
    end
end

function PANEL:LoadFilters()
    for _, data in ipairs(gfconsole.filter.get_all()) do
        local check = self:AddCheckbox(data.id, data.cv:GetBool(), function()
            gfconsole.filter.toggle(data.id)
        end)

        check.cv = data.cv
    end
end

vgui.Register("GFConsole.Container", PANEL)
