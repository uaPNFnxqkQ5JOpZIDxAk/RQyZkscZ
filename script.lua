getgenv().settings = {
    map = "Frozen Depths",
    difficulty = "Easy",
    hardcore = true,
    start_delay = 1.5,
    fast_rejoin = true,
    move_speed = 120, --> change this number if you're having tp issues
    force_reset = 360, --> if you get stuck it'll reset after 360 seconds
    autosell = {
       enabled = true,

       sell_below_epic = true, --> won't sell epic or above
    },
    auto_add_skill = "Strength"
}

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui", true)

local client = {}
local s = 0
local p = game:service'Players'
local lp = p.LocalPlayer
local r = game:service'ReplicatedStorage'

local t_service = game:service'TweenService'
local r_service = game:service'RunService'

client.remote_key = function()
    return lp.Character:FindFirstChildOfClass("Model").Name
end

client._reset = function()
    wait(getgenv().settings.force_reset)
    p.Character.Humanoid.Health = 0
end

client.c_enemy = function()
    local c_mob = nil
    local c_dist = math.huge

    for i,v in next, workspace.Enemies:children() do
        if v:FindFirstChild("Humanoid", true) then
            if v:FindFirstChild'HumanoidRootPart' and v:FindFirstChild('Humanoid', true).Health ~= 0 then
                local magnitude = (v.HumanoidRootPart.Position - lp.Character.Head.Position).magnitude

                if magnitude < c_dist then
                    c_dist = magnitude
                    c_mob = v
                end
            end
        end
    end
    return c_mob
end

if not workspace:FindFirstChild("Lobby") then
    r_service.Heartbeat:Connect(function()
        pcall(function()
            lp.Character.Humanoid:ChangeState(11)

            if client.c_enemy().Name == "Frost Giant" then
                height = 12
            else
                height = -8
            end
            
			if workspace.Ignore:FindFirstChild("Circle") then
                height = 500
			end

            r.Modules.Network.RemoteEvent:FireServer("WeaponDamage", client.remote_key(), client.c_enemy().Humanoid)

            t_service:Create(lp.Character.HumanoidRootPart, TweenInfo.new((client.c_enemy().Head.Position - lp.Character.Head.Position).magnitude / getgenv().settings.move_speed or 120, Enum.EasingStyle.Quad), {CFrame = client.c_enemy().HumanoidRootPart.CFrame + Vector3.new(ax or 0, height or -8, 0)}):Play()
        end)
        if lp.PlayerGui.ScreenGui.Results.Visible and getgenv().settings.fast_rejoin then
            wait(2)
            game:GetService("TeleportService"):Teleport(4390380541, lp)
        end
    end)
else
    if getgenv().settings.autosell.enabled then

        lp.Character.HumanoidRootPart.CFrame = CFrame.new(-421.14, 25.20, 409.01)

        wait(1)

    for i,v in next, lp.PlayerGui.ScreenGui.Sell.Sell.Inner.Items.Frame.Items:children() do
        if v:IsA("ImageButton") and not v.RarityBackground.Visible and not v.Equipped.Visible then
            if getgenv().settings.autosell.sell_below_epic and not v.RarityStars.Star4.Visible and not v.RarityStars.Star5.Visible then
                r.Modules.Network.RemoteFunction:InvokeServer("SellItems",{{"Ability", v.Name}})
                r.Modules.Network.RemoteFunction:InvokeServer("SellItems",{{"Armor", v.Name}})
                r.Modules.Network.RemoteFunction:InvokeServer("SellItems",{{"Weapon", v.Name}})
                r.Modules.Network.RemoteFunction:InvokeServer("SellItems",{{"Cosmetic", v.Name}})
                end
            end
        end
    end

    wait(getgenv().settings.start_delay or 1)

    local points = lp.PlayerGui.ScreenGui.Inventory.Inventory.Inner.Skills.Info.PointsFrame.Points.Text:split(" ")
    
    if tonumber(points[3]) >= 1 then
        r.Modules.Network.RemoteEvent:FireServer("IncreaseSkill", getgenv().settings.auto_add_skill or "Strength")
    end
    
    r.Modules.Network.RemoteFunction:InvokeServer("CreateLobby", {
        ["Difficulty"] = getgenv().settings.difficulty or "Easy",
        ["PartyOnly"] = true,
        ["Hardcore"] = getgenv().settings.hardcore or true,
        ["Location"] = getgenv().settings.map or "Caves"
    })
    print("starting dungeon "..getgenv().settings.map.." with difficulty "..getgenv().settings.difficulty.."..")
    r.Modules.Network.RemoteEvent:FireServer("StartDungeon")
end

client._reset()
