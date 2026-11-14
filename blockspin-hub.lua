--[[
    ╔═══════════════════════════════════════════╗
    ║      CRASHY HUB · BLOCKSPIN EDITION      ║
    ║        Developed by Crash Leaks           ║
    ║           discord.gg/crashhh              ║
    ╚═══════════════════════════════════════════╝

    Executor: any level 8+ (Potassium, Solara, etc.)
    Game:     BlockSpin (Roblox)
    UI:       Ventura UI v4 — sidebar layout
]]

-- ═══════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local StarterGui         = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService    = game:GetService("TeleportService")
local Workspace          = game:GetService("Workspace")
local HttpService        = game:GetService("HttpService")
local Stats              = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════
--  STATE
-- ═══════════════════════════════════════════════
local State = {
    -- Automation
    AutoShelfStock=false, AutoChef=false, AutoJanitor=false,
    AutoScavenger=false, AutoATM=false, AutoCrate=false,
    FastAutomation=false, AutomationDelay=0.5,
    -- Movement
    WalkSpeed=16, JumpPower=50, UnlimitedSprint=false,
    -- Player
    FOV=70, EnableFOV=false,
    AntiRagdoll=false, Incognito=false,
    InstantRespawn=false, CombatMonitor=false,
    NightVision=false, BrightnessValue=1,
    -- Fly / Noclip
    Fly=false, FlySpeed=80, Noclip=false,
    -- ESP / Tracker
    ItemTracker=false, TrackerRender=1200,
    ESPATMs=true, ESPCrates=true, ESPItems=true,
    -- Overlay
    StatusOverlay=false,
    -- Pathfinding
    AutoPathfind=false, PathTarget=nil,
    -- Config
    MenuKeybind=Enum.KeyCode.RightShift,
    SilentStart=false,
    -- Internal
    _pathAgent=nil, _overlayGui=nil,
    _connections={},
}

-- ═══════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHumanoid()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end

local function findRemote(keyword)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name:lower():find(keyword:lower()) then
            return v
        end
    end
    return nil
end

local function findRemoteExact(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name == name then
            return v
        end
    end
    return nil
end

local function fireRemote(remote, ...)
    if not remote then return end
    if remote:IsA("RemoteEvent") then remote:FireServer(...)
    elseif remote:IsA("RemoteFunction") then return remote:InvokeServer(...) end
end

local function getNearestOf(keyword, maxDist)
    maxDist = maxDist or 200
    local hrp = getHRP(); if not hrp then return nil end
    local best, bestDist = nil, maxDist
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find(keyword:lower()) then
            local d = (hrp.Position - v.Position).Magnitude
            if d < bestDist then best = v; bestDist = d end
        elseif v:IsA("Model") and v.Name:lower():find(keyword:lower()) then
            local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (hrp.Position - p.Position).Magnitude
                if d < bestDist then best = p; bestDist = d end
            end
        end
    end
    return best
end

local function tpTo(part)
    local hrp = getHRP(); if not hrp or not part then return end
    hrp.CFrame = part.CFrame + Vector3.new(0, 4, 0)
end

local function fireProx(obj)
    if not obj then return end
    local prox = obj:FindFirstChildOfClass("ProximityPrompt")
    if not prox then
        for _, d in pairs(obj:GetDescendants()) do
            if d:IsA("ProximityPrompt") then prox = d; break end
        end
    end
    if not prox then
        if obj.Parent then
            prox = obj.Parent:FindFirstChildOfClass("ProximityPrompt")
        end
    end
    if prox then
        local old = prox.MaxActivationDistance
        prox.MaxActivationDistance = 9999
        fireproximityprompt(prox)
        task.wait(0.1)
        prox.MaxActivationDistance = old
    end
end

local function clickDetect(obj)
    if not obj then return end
    local cd = obj:FindFirstChildOfClass("ClickDetector")
    if not cd then
        for _, d in pairs(obj:GetDescendants()) do
            if d:IsA("ClickDetector") then cd = d; break end
        end
    end
    if cd then fireclickdetector(cd) end
end

local function getDelay()
    return State.FastAutomation and 0.1 or State.AutomationDelay
end

-- ═══════════════════════════════════════════════
--  MAP LOCATIONS (for pathfinding / teleports)
-- ═══════════════════════════════════════════════
local MapLocations = {}

local function scanLocations()
    MapLocations = {}
    -- scan for named models, spawn locations, common landmarks
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.PrimaryPart and #v.Name > 2 then
            local n = v.Name
            if n:lower():find("atm") or n:lower():find("bank") or n:lower():find("shop") or
               n:lower():find("store") or n:lower():find("house") or n:lower():find("spawn") or
               n:lower():find("steak") or n:lower():find("grill") or n:lower():find("restaurant") or
               n:lower():find("gas") or n:lower():find("station") or n:lower():find("hospital") or
               n:lower():find("police") or n:lower():find("fire") or n:lower():find("gym") or
               n:lower():find("school") or n:lower():find("park") or n:lower():find("market") or
               n:lower():find("mall") or n:lower():find("apartment") or n:lower():find("crate") or
               n:lower():find("dumpster") or n:lower():find("trash") or n:lower():find("shelf") or
               n:lower():find("kitchen") or n:lower():find("mop") or n:lower():find("janitor") or
               n:lower():find("car") or n:lower():find("garage") then
                MapLocations[n] = v.PrimaryPart.Position
            end
        end
    end
    -- add spawn
    local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then MapLocations["Spawn"] = sp.Position end
    return MapLocations
end

local function getLocationNames()
    if next(MapLocations) == nil then scanLocations() end
    local names = {}
    for k, _ in pairs(MapLocations) do table.insert(names, k) end
    table.sort(names)
    if #names == 0 then table.insert(names, "None found — scan again in-game") end
    return names
end

-- ═══════════════════════════════════════════════
--  UI — Ventura (single panel, sidebar)
-- ═══════════════════════════════════════════════
local Library = loadstring(game:HttpGet(
    "https://codeberg.org/VenomVent/Ventura-UI/raw/branch/main/VenturaLibrary.lua"
))()

local GUI = Library:new({
    name  = "Crashy Hub — BlockSpin",
    theme = "Midnight",
})

local function notify(title, text, dur)
    pcall(function() GUI.notify(title, text, dur or 4, "success") end)
end

-- ═══════════════════════════════════════════════
--  TAB: AUTOMATION
-- ═══════════════════════════════════════════════
GUI:NavSection("AUTOMATION")

-- ── Auto Shelf Stocker ──
local ShelfTab = GUI:CreateTab({ name = "Shelf Stocker", icon = Library.Icons.box or nil })

ShelfTab:Toggle({ name = "Auto Shelf Stocker", default = false, flag = "autoshelf", callback = function(v)
    State.AutoShelfStock = v
    if v then
        notify("Automation", "Shelf stocker started — searching for shelves & supply boxes.")
        task.spawn(function()
            while State.AutoShelfStock do
                -- find supply boxes first, pick up
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoShelfStock then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("supply") or obj.Name:lower():find("box") or obj.Name:lower():find("crate")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        task.wait(getDelay())
                    end
                end
                -- find shelves, stock them
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoShelfStock then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("shelf") or obj.Name:lower():find("rack") or obj.Name:lower():find("stock")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        -- try remote
                        local r = findRemote("Stock") or findRemote("Shelf") or findRemote("Supply")
                        if r then fireRemote(r, obj) end
                        task.wait(getDelay())
                    end
                end
                task.wait(1)
            end
        end)
    else notify("Automation", "Shelf stocker stopped.") end
end })

ShelfTab:Button({ name = "Teleport to Nearest Shelf", callback = function()
    local s = getNearestOf("shelf") or getNearestOf("stock") or getNearestOf("rack")
    if s then tpTo(s); notify("TP", "At nearest shelf.") else notify("Error", "No shelf found.") end
end })

-- ── Auto Chef / Grill ──
local ChefTab = GUI:CreateTab({ name = "Chef / Grill", icon = Library.Icons.zap or nil })

ChefTab:Toggle({ name = "Auto Chef / Grill", default = false, flag = "autochef", callback = function(v)
    State.AutoChef = v
    if v then
        notify("Automation", "Auto chef started — cooking everything.")
        task.spawn(function()
            while State.AutoChef do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoChef then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("grill") or obj.Name:lower():find("stove") or
                       obj.Name:lower():find("cook") or obj.Name:lower():find("oven") or obj.Name:lower():find("fryer") or
                       obj.Name:lower():find("prep") or obj.Name:lower():find("food") or obj.Name:lower():find("ingredient")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        local r = findRemote("Cook") or findRemote("Grill") or findRemote("Prepare") or findRemote("Food")
                        if r then fireRemote(r, obj) end
                        task.wait(getDelay())
                    end
                end
                task.wait(1)
            end
        end)
    else notify("Automation", "Auto chef stopped.") end
end })

ChefTab:Button({ name = "TP to Kitchen / Steakhouse", callback = function()
    local k = getNearestOf("kitchen") or getNearestOf("steak") or getNearestOf("grill") or getNearestOf("restaurant")
    if k then tpTo(k); notify("TP", "At kitchen.") else notify("Error", "Kitchen not found.") end
end })

-- ── Auto Janitor ──
local JanitorTab = GUI:CreateTab({ name = "Janitor / Mop", icon = Library.Icons.droplet or nil })

JanitorTab:Toggle({ name = "Auto Janitor / Mop", default = false, flag = "autojanitor", callback = function(v)
    State.AutoJanitor = v
    if v then
        notify("Automation", "Auto janitor started — mopping floors.")
        task.spawn(function()
            while State.AutoJanitor do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoJanitor then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("puddle") or obj.Name:lower():find("mop") or
                       obj.Name:lower():find("spill") or obj.Name:lower():find("clean") or obj.Name:lower():find("mess") or
                       obj.Name:lower():find("dirt") or obj.Name:lower():find("trash")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        local r = findRemote("Clean") or findRemote("Mop") or findRemote("Janitor")
                        if r then fireRemote(r) end
                        task.wait(getDelay())
                    end
                end
                task.wait(1.5)
            end
        end)
    else notify("Automation", "Auto janitor stopped.") end
end })

-- ── Auto Scavenger ──
local ScavTab = GUI:CreateTab({ name = "Scavenger", icon = Library.Icons.search or nil })

ScavTab:Toggle({ name = "Auto Scavenger (Dumpsters)", default = false, flag = "autoscav", callback = function(v)
    State.AutoScavenger = v
    if v then
        notify("Automation", "Auto scavenger started — raiding dumpsters.")
        task.spawn(function()
            while State.AutoScavenger do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoScavenger then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("dumpster") or obj.Name:lower():find("trash") or obj.Name:lower():find("bin") or obj.Name:lower():find("loot")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        local r = findRemote("Scavenge") or findRemote("Search") or findRemote("Dumpster") or findRemote("Loot")
                        if r then fireRemote(r, obj) end
                        task.wait(getDelay())
                    end
                end
                task.wait(2)
            end
        end)
    else notify("Automation", "Auto scavenger stopped.") end
end })

-- ── Auto ATM Hacker ──
local ATMTab = GUI:CreateTab({ name = "ATM Hacker", icon = Library.Icons.dollar or nil })

ATMTab:Toggle({ name = "Auto ATM Hacker", default = false, flag = "autoatm", callback = function(v)
    State.AutoATM = v
    if v then
        notify("Automation", "Auto ATM started — hacking, depositing, withdrawing.")
        task.spawn(function()
            while State.AutoATM do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoATM then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("atm") or obj.Name:lower():find("bank")) then
                        tpTo(obj); task.wait(getDelay())
                        fireProx(obj); clickDetect(obj)
                        task.wait(0.3)
                        -- try multiple remote patterns
                        local hack = findRemote("Hack") or findRemote("ATM") or findRemote("Rob")
                        if hack then fireRemote(hack, "Hack"); task.wait(getDelay()) end
                        local dep = findRemote("Deposit") or findRemote("ATM")
                        if dep then fireRemote(dep, "Deposit", 99999); task.wait(getDelay()) end
                        local wd = findRemote("Withdraw") or findRemote("ATM")
                        if wd then fireRemote(wd, "Withdraw", 99999); task.wait(getDelay()) end
                        task.wait(getDelay())
                    end
                end
                task.wait(2)
            end
        end)
    else notify("Automation", "Auto ATM stopped.") end
end })

ATMTab:Button({ name = "TP to Nearest ATM", callback = function()
    local atm = getNearestOf("atm") or getNearestOf("bank")
    if atm then tpTo(atm); notify("TP","At ATM.") else notify("Error","No ATM found.") end
end })

ATMTab:Button({ name = "Manual Withdraw Max", callback = function()
    local r = findRemote("Withdraw") or findRemote("ATM") or findRemote("Bank")
    if r then fireRemote(r, "Withdraw", 99999); notify("ATM","Withdrew max.") else notify("Error","Withdraw remote not found.") end
end })

ATMTab:Button({ name = "Manual Deposit Max", callback = function()
    local r = findRemote("Deposit") or findRemote("ATM") or findRemote("Bank")
    if r then fireRemote(r, "Deposit", 99999); notify("ATM","Deposited max.") else notify("Error","Deposit remote not found.") end
end })

ATMTab:Button({ name = "Manual Hack ATM", callback = function()
    local r = findRemote("Hack") or findRemote("Rob") or findRemote("ATM")
    if r then fireRemote(r, "Hack"); notify("ATM","Hacking ATM...") else notify("Error","Hack remote not found.") end
end })

-- ── Auto Crate Collector ──
local CrateTab = GUI:CreateTab({ name = "Crate Collector", icon = Library.Icons.gift or nil })

CrateTab:Toggle({ name = "Auto Crate Collector", default = false, flag = "autocrate", callback = function(v)
    State.AutoCrate = v
    if v then
        notify("Automation", "Auto crate collector started.")
        task.spawn(function()
            while State.AutoCrate do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not State.AutoCrate then break end
                    if (obj:IsA("BasePart") or obj:IsA("Model")) and (obj.Name:lower():find("crate") or obj.Name:lower():find("chest") or obj.Name:lower():find("lootbox") or obj.Name:lower():find("reward")) then
                        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        if part then
                            tpTo(part); task.wait(getDelay())
                            fireProx(part); fireProx(obj); clickDetect(part); clickDetect(obj)
                            local r = findRemote("Crate") or findRemote("Open") or findRemote("Collect")
                            if r then fireRemote(r, obj.Name) end
                            task.wait(getDelay())
                        end
                    end
                end
                task.wait(2)
            end
        end)
    else notify("Automation", "Crate collector stopped.") end
end })

-- ── Automation Settings ──
local AutoSettingsTab = GUI:CreateTab({ name = "Auto Settings", icon = Library.Icons.settings or nil })

AutoSettingsTab:Toggle({ name = "Fast Automation (low delay)", default = false, flag = "fastauto", callback = function(v)
    State.FastAutomation = v
    notify("Speed", v and "Fast mode ON — 0.1s delays." or "Normal delays restored.")
end })

AutoSettingsTab:Slider({ name = "Automation Delay", min = 10, max = 200, default = 50, step = 5, suffix = "ms", flag = "autodelay", callback = function(v)
    State.AutomationDelay = v / 100
end })

AutoSettingsTab:Button({ name = "Stop ALL Automation", callback = function()
    State.AutoShelfStock=false; State.AutoChef=false; State.AutoJanitor=false
    State.AutoScavenger=false; State.AutoATM=false; State.AutoCrate=false
    notify("Automation", "All automation stopped.")
end })

-- ═══════════════════════════════════════════════
--  TAB: PLAYER
-- ═══════════════════════════════════════════════
GUI:NavSection("PLAYER")
local PlayerTab = GUI:CreateTab({ name = "Movement", icon = Library.Icons.user or nil })

PlayerTab:Slider({ name = "Walk Speed", min = 8, max = 80, default = 16, step = 1, suffix = " ws", flag = "walkspeed", callback = function(v)
    State.WalkSpeed = v
    local hum = getHumanoid(); if hum then hum.WalkSpeed = v end
end })

PlayerTab:Slider({ name = "Jump Power", min = 23, max = 120, default = 50, step = 1, suffix = "", flag = "jumppower", callback = function(v)
    State.JumpPower = v
    local hum = getHumanoid(); if hum then hum.JumpPower = v end
end })

PlayerTab:Toggle({ name = "Unlimited Sprint", default = false, flag = "unisprint", callback = function(v)
    State.UnlimitedSprint = v
    if v then notify("Sprint","Stamina will never deplete.") end
end })

PlayerTab:Toggle({ name = "Fly", default = false, flag = "fly", callback = function(v)
    State.Fly = v
    local hrp = getHRP(); if not hrp then return end
    if v then
        if hrp:FindFirstChild("CrashyFlyBV") then return end
        local bv = Instance.new("BodyVelocity"); bv.Name="CrashyFlyBV"; bv.MaxForce=Vector3.new(1e6,1e6,1e6); bv.Velocity=Vector3.zero; bv.Parent=hrp
        local bg = Instance.new("BodyGyro"); bg.Name="CrashyFlyBG"; bg.MaxTorque=Vector3.new(1e6,1e6,1e6); bg.P=1e4; bg.Parent=hrp
        notify("Fly","Enabled — WASD + Space/Shift")
    else
        local bv = hrp:FindFirstChild("CrashyFlyBV"); if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("CrashyFlyBG"); if bg then bg:Destroy() end
    end
end })

PlayerTab:Slider({ name = "Fly Speed", min = 10, max = 500, default = 80, step = 5, suffix = "", flag = "flyspeed", callback = function(v) State.FlySpeed = v end })

PlayerTab:Toggle({ name = "Noclip", default = false, flag = "noclip", callback = function(v) State.Noclip = v end })

PlayerTab:Toggle({ name = "Anti-Ragdoll / Anti-Fall", default = false, flag = "antirag", callback = function(v) State.AntiRagdoll = v end })

PlayerTab:Toggle({ name = "Incognito Mode (hide name)", default = false, flag = "incognito", callback = function(v)
    State.Incognito = v
    local c = getChar(); if not c then return end
    local head = c:FindFirstChild("Head")
    if head then
        local bb = head:FindFirstChildOfClass("BillboardGui")
        if bb then bb.Enabled = not v end
    end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer end
    notify("Incognito", v and "Name hidden." or "Name visible.")
end })

PlayerTab:Toggle({ name = "Instant Respawn", default = false, flag = "instresp", callback = function(v) State.InstantRespawn = v end })

PlayerTab:Button({ name = "Panic / Safe Reset", callback = function()
    local hum = getHumanoid()
    if hum then hum.Health = 0 end
    notify("Reset","Character reset.")
end })

-- ═══════════════════════════════════════════════
--  TAB: VISUALS
-- ═══════════════════════════════════════════════
GUI:NavSection("VISUALS")
local VisTab = GUI:CreateTab({ name = "Visuals", icon = Library.Icons.eye or nil })

VisTab:Toggle({ name = "Night Vision / Fullbright", default = false, flag = "nightvision", callback = function(v)
    State.NightVision = v
    if v then
        Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(200,200,200)
    else
        Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.Ambient = Color3.new(0,0,0)
    end
end })

VisTab:Slider({ name = "Brightness", min = 0, max = 5, default = 1, step = 1, suffix = "", flag = "brightness", callback = function(v)
    State.BrightnessValue = v; Lighting.Brightness = v
end })

VisTab:Toggle({ name = "Enable FOV", default = false, flag = "enablefov", callback = function(v) State.EnableFOV = v end })
VisTab:Slider({ name = "FOV", min = 30, max = 120, default = 70, step = 1, suffix = "", flag = "fov", callback = function(v)
    State.FOV = v; if State.EnableFOV then Camera.FieldOfView = v end
end })

VisTab:Toggle({ name = "Combat Monitor", default = false, flag = "combatmon", callback = function(v)
    State.CombatMonitor = v
    if v then
        notify("Combat","Combat monitor enabled — alerts when players leave mid-fight.")
    end
end })

-- ── Item & Object Tracker (ESP) ──
local TrackerTab = GUI:CreateTab({ name = "Tracker / ESP", icon = Library.Icons.crosshair or nil })

TrackerTab:Toggle({ name = "Item & Object Tracker", default = false, flag = "itemtracker", callback = function(v)
    State.ItemTracker = v
    if not v then
        -- cleanup all ESP
        for _, obj in pairs(Workspace:GetDescendants()) do
            local bb = obj:FindFirstChild("CrashyTracker")
            if bb then bb:Destroy() end
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("CrashyChams")
                if h then h:Destroy() end
            end
        end
    else notify("ESP","Tracker ON — ATMs, crates, items highlighted.") end
end })

TrackerTab:Toggle({ name = "Show ATMs", default = true, flag = "espatm", callback = function(v) State.ESPATMs = v end })
TrackerTab:Toggle({ name = "Show Crates", default = true, flag = "espcrates", callback = function(v) State.ESPCrates = v end })
TrackerTab:Toggle({ name = "Show Dropped Items", default = true, flag = "espitems", callback = function(v) State.ESPItems = v end })
TrackerTab:Slider({ name = "Render Distance", min = 100, max = 5000, default = 1200, step = 50, suffix = "m", flag = "esprender", callback = function(v) State.TrackerRender = v end })

-- ── Status Overlay ──
TrackerTab:Toggle({ name = "Status Overlay (HP/Speed/Ping/FPS)", default = false, flag = "overlay", callback = function(v)
    State.StatusOverlay = v
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if v then
        if pg:FindFirstChild("CrashyOverlay") then return end
        local sg = Instance.new("ScreenGui"); sg.Name="CrashyOverlay"; sg.IgnoreGuiInset=true; sg.Parent=pg
        local f = Instance.new("Frame"); f.Size=UDim2.new(0,220,0,80); f.Position=UDim2.new(0,10,0,10)
        f.BackgroundColor3=Color3.fromRGB(20,20,20); f.BackgroundTransparency=0.3; f.BorderSizePixel=0; f.Parent=sg
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
        local tl = Instance.new("TextLabel"); tl.Name="Info"; tl.Size=UDim2.new(1,-10,1,-10); tl.Position=UDim2.new(0,5,0,5)
        tl.BackgroundTransparency=1; tl.TextColor3=Color3.new(1,1,1); tl.TextSize=13; tl.Font=Enum.Font.RobotoMono
        tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextYAlignment=Enum.TextYAlignment.Top; tl.Parent=f
        State._overlayGui = sg
    else
        if pg:FindFirstChild("CrashyOverlay") then pg.CrashyOverlay:Destroy() end
        State._overlayGui = nil
    end
end })

-- ═══════════════════════════════════════════════
--  TAB: TELEPORT / PATHFINDING
-- ═══════════════════════════════════════════════
GUI:NavSection("NAVIGATION")
local NavTab = GUI:CreateTab({ name = "Pathfinding", icon = Library.Icons.map or nil })

NavTab:Button({ name = "Scan Map Locations", callback = function()
    scanLocations()
    notify("Scan","Found " .. tostring(#getLocationNames()) .. " locations.")
end })

NavTab:Dropdown({ name = "Destination", items = getLocationNames(), default = nil, multi = false, callback = function(v)
    State.PathTarget = v
end })

NavTab:Button({ name = "Teleport to Destination", callback = function()
    if not State.PathTarget or not MapLocations[State.PathTarget] then
        notify("Error","Select a destination first or scan locations."); return
    end
    local hrp = getHRP(); if not hrp then return end
    hrp.CFrame = CFrame.new(MapLocations[State.PathTarget] + Vector3.new(0,5,0))
    notify("TP","Teleported to " .. State.PathTarget)
end })

NavTab:Toggle({ name = "Auto Pathfind (walk to)", default = false, flag = "autopath", callback = function(v)
    State.AutoPathfind = v
    if v then
        if not State.PathTarget or not MapLocations[State.PathTarget] then
            notify("Error","Select a destination first."); State.AutoPathfind = false; return
        end
        task.spawn(function()
            local hrp = getHRP(); local hum = getHumanoid()
            if not hrp or not hum then return end
            local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
            path:ComputeAsync(hrp.Position, MapLocations[State.PathTarget])
            if path.Status == Enum.PathStatus.Success then
                for _, wp in ipairs(path:GetWaypoints()) do
                    if not State.AutoPathfind then break end
                    hum:MoveTo(wp.Position)
                    if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                    hum.MoveToFinished:Wait()
                end
                notify("Pathfind","Arrived at " .. State.PathTarget)
            else
                notify("Error","Path blocked — teleporting instead.")
                hrp.CFrame = CFrame.new(MapLocations[State.PathTarget] + Vector3.new(0,5,0))
            end
            State.AutoPathfind = false
        end)
    end
end })

-- quick teleports
NavTab:Button({ name = "TP to Nearest ATM", callback = function()
    local a = getNearestOf("atm"); if a then tpTo(a); notify("TP","At ATM.") else notify("Error","No ATM.") end
end })
NavTab:Button({ name = "TP to Nearest Dumpster", callback = function()
    local d = getNearestOf("dumpster") or getNearestOf("trash"); if d then tpTo(d); notify("TP","At dumpster.") else notify("Error","No dumpster.") end
end })
NavTab:Button({ name = "TP to Nearest Crate", callback = function()
    local c = getNearestOf("crate") or getNearestOf("chest"); if c then tpTo(c); notify("TP","At crate.") else notify("Error","No crate.") end
end })
NavTab:Button({ name = "TP to Steakhouse / Kitchen", callback = function()
    local k = getNearestOf("steak") or getNearestOf("kitchen") or getNearestOf("grill") or getNearestOf("restaurant")
    if k then tpTo(k); notify("TP","At steakhouse.") else notify("Error","Not found.") end
end })

-- ═══════════════════════════════════════════════
--  TAB: SCRIPT / SETTINGS
-- ═══════════════════════════════════════════════
GUI:NavSection("SETTINGS")
local ScriptTab = GUI:CreateTab({ name = "Script", icon = Library.Icons.settings or nil })

ScriptTab:Button({ name = "Script:  Crashy Hub — BlockSpin", callback = function() end })
ScriptTab:Button({ name = "Game:    BlockSpin (Roblox)", callback = function() end })
ScriptTab:Button({ name = "Dev:     Crash Leaks", callback = function() end })
ScriptTab:Button({ name = "discord.gg/crashhh", callback = function() end })

ScriptTab:Button({ name = "Copy Discord", callback = function()
    pcall(function() setclipboard("https://discord.gg/crashhh") end)
    notify("Copied","Discord invite copied.")
end })

ScriptTab:Button({ name = "Eject Script", callback = function()
    -- cleanup
    State.AutoShelfStock=false; State.AutoChef=false; State.AutoJanitor=false
    State.AutoScavenger=false; State.AutoATM=false; State.AutoCrate=false
    State.Fly=false; State.Noclip=false; State.ItemTracker=false
    local hrp = getHRP()
    if hrp then
        local bv = hrp:FindFirstChild("CrashyFlyBV"); if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("CrashyFlyBG"); if bg then bg:Destroy() end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        local t = obj:FindFirstChild("CrashyTracker"); if t then t:Destroy() end
    end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg:FindFirstChild("CrashyOverlay") then pg.CrashyOverlay:Destroy() end
    GUI:Destroy()
end })

ScriptTab:Button({ name = "Rejoin Server", callback = function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

ScriptTab:Button({ name = "Server Hop", callback = function()
    local ok, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and servers and servers.data then
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer); return
            end
        end
    end
    notify("Error","No available servers.")
end })

ScriptTab:Button({ name = "Join Smallest Server", callback = function()
    local ok, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and servers and servers.data then
        local smallest, minP = nil, 9999
        for _, s in pairs(servers.data) do
            if s.playing < minP and s.id ~= game.JobId then smallest = s; minP = s.playing end
        end
        if smallest then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, smallest.id, LocalPlayer)
        else notify("Error","No other servers found.") end
    end
end })

-- ═══════════════════════════════════════════════
--  MAIN LOOPS
-- ═══════════════════════════════════════════════

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip then
        local c = getChar(); if c then
            for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end
end)

-- Fly
RunService.RenderStepped:Connect(function()
    if State.Fly then
        local hrp = getHRP(); if not hrp then return end
        local bv = hrp:FindFirstChild("CrashyFlyBV"); local bg = hrp:FindFirstChild("CrashyFlyBG")
        if not bv or not bg then return end
        local spd = State.FlySpeed; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        bv.Velocity = dir * spd; bg.CFrame = Camera.CFrame
    end
end)

-- WalkSpeed + JumpPower + Anti-Ragdoll + Sprint
RunService.Heartbeat:Connect(function()
    local hum = getHumanoid(); if not hum then return end
    if State.WalkSpeed ~= 16 then hum.WalkSpeed = State.WalkSpeed end
    if State.JumpPower ~= 50 then hum.JumpPower = State.JumpPower end
    if State.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    end
    if State.UnlimitedSprint then
        -- look for stamina value
        local char = getChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("stamina") or v.Name:lower():find("sprint") or v.Name:lower():find("energy")) then
                    v.Value = v:IsA("NumberValue") and 100 or 100
                end
            end
        end
        -- also check PlayerGui / leaderstats
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            for _, v in pairs(ls:GetChildren()) do
                if v.Name:lower():find("stamina") then v.Value = 100 end
            end
        end
    end
end)

-- FOV
RunService.RenderStepped:Connect(function()
    if State.EnableFOV then Camera.FieldOfView = State.FOV end
end)

-- Instant Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeed ~= 16 then hum.WalkSpeed = State.WalkSpeed end
        if State.JumpPower ~= 50 then hum.JumpPower = State.JumpPower end
        if State.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
        if State.Incognito then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        if State.Fly then
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local bv = Instance.new("BodyVelocity"); bv.Name="CrashyFlyBV"; bv.MaxForce=Vector3.new(1e6,1e6,1e6); bv.Velocity=Vector3.zero; bv.Parent=hrp
                local bg = Instance.new("BodyGyro"); bg.Name="CrashyFlyBG"; bg.MaxTorque=Vector3.new(1e6,1e6,1e6); bg.P=1e4; bg.Parent=hrp
            end
        end
    end
end)

-- Instant Respawn trigger
task.spawn(function()
    while true do
        if State.InstantRespawn then
            local hum = getHumanoid()
            if hum and hum.Health <= 0 then
                task.wait(0.2)
                local r = findRemote("Respawn") or findRemote("LoadCharacter") or findRemote("Reset")
                if r then fireRemote(r)
                else pcall(function() LocalPlayer:LoadCharacter() end) end
            end
        end
        task.wait(0.5)
    end
end)

-- Item Tracker ESP
task.spawn(function()
    while true do
        if State.ItemTracker then
            local hrp = getHRP()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and hrp then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    local isATM = obj.Name:lower():find("atm") or obj.Name:lower():find("bank")
                    local isCrate = obj.Name:lower():find("crate") or obj.Name:lower():find("chest") or obj.Name:lower():find("loot")
                    local isItem = obj.Name:lower():find("drop") or obj.Name:lower():find("pickup") or obj.Name:lower():find("cash") or obj.Name:lower():find("money")

                    local show = (isATM and State.ESPATMs) or (isCrate and State.ESPCrates) or (isItem and State.ESPItems)

                    if show and dist <= State.TrackerRender then
                        if not obj:FindFirstChild("CrashyTracker") then
                            local bb = Instance.new("BillboardGui"); bb.Name="CrashyTracker"; bb.Size=UDim2.new(0,120,0,30)
                            bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Parent=obj
                            local tl = Instance.new("TextLabel"); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1
                            tl.TextColor3 = isATM and Color3.fromRGB(0,255,100) or isCrate and Color3.fromRGB(255,200,0) or Color3.fromRGB(0,200,255)
                            tl.TextSize=12; tl.Font=Enum.Font.GothamBold; tl.TextStrokeTransparency=0.3; tl.Parent=bb
                            tl.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                        else
                            local bb = obj:FindFirstChild("CrashyTracker")
                            local tl = bb:FindFirstChildOfClass("TextLabel")
                            if tl then tl.Text = obj.Name .. " [" .. math.floor(dist) .. "m]" end
                        end
                    elseif not show or dist > State.TrackerRender then
                        local bb = obj:FindFirstChild("CrashyTracker"); if bb then bb:Destroy() end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- Status Overlay updater
task.spawn(function()
    while true do
        if State.StatusOverlay and State._overlayGui then
            local hum = getHumanoid()
            local hp = hum and math.floor(hum.Health) or 0
            local maxHp = hum and math.floor(hum.MaxHealth) or 100
            local ws = hum and math.floor(hum.WalkSpeed) or 0
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local f = State._overlayGui:FindFirstChild("Frame")
            if not f then f = State._overlayGui:FindFirstChildOfClass("Frame") end
            if f then
                local tl = f:FindFirstChild("Info")
                if tl then
                    tl.Text = string.format("HP: %d/%d\nSpeed: %d\nPing: %dms\nFPS: %d", hp, maxHp, ws, ping, fps)
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Combat Monitor
task.spawn(function()
    if not State.CombatMonitor then task.wait(1) end
    Players.PlayerRemoving:Connect(function(player)
        if State.CombatMonitor then
            notify("Combat Alert", player.DisplayName .. " left the server!", 5)
        end
    end)
end)

-- ═══════════════════════════════════════════════
--  LOADED
-- ═══════════════════════════════════════════════
if not State.SilentStart then
    notify("Crashy Hub", "BlockSpin Edition loaded\ndiscord.gg/crashhh", 6)
end
print("[Crashy Hub] BlockSpin Edition — loaded successfully")
