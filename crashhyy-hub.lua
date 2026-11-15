--// CrashyHub | THA BRONX 3 | Potassium Executor
--// Full YVL HUB–matched layout — VenturaUI v4.1
--// UI owned by crashyyyy | discord.gg/crashhh

--============================--
--        SERVICES             --
--============================--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--============================--
--       STATE VARIABLES       --
--============================--
local State = {
    -- Money
    AutoDrop10k = false,

    -- Local Player
    FPSBoost = false, AntiFallDamage = false, AntiJumpCooldown = false,
    InfiniteSleep = false, InfiniteHunger = false, InfiniteStamina = false,
    NoRentPay = false, InstantInteraction = false, StudioMoneyNotify = false,
    AutoStealLootbags = false, AutoPickupBags = false, DisableBloodEffects = false,
    BypassLockedCars = false, NoKnockback = false, AntiCarFling = false,
    AutoDepositPickedCash = false, AutoStealDroppedCash = false,

    -- Miscellaneous
    FasterRespawn = false, RespawnWhereDied = false,
    PutGunsOnMarket = false, InstantRevive = false,
    AutoGetHelp = false, AntiAFK = false,
    LastDeathPos = nil,

    -- Movement
    NoBlur = false, DisableCameraBobbing = false,
    WalkSpeedEnabled = false, WalkSpeedValue = 16,
    JumpBoost = false, InfiniteJump = false,
    Noclip = false, Fly = false, FlySpeed = 80,
    CustomCrosshair = false,

    -- Target
    SelectedPlayer = nil,
    AutoPassNearest = false, AutoDropGuns = false,
    SpectatePlayer = false, BringNearestPlayer = false,
    BringPlayer = false, AutoKillGun = false,
    AutoRagdollGun = false, AutoBladeKill = false,
    AutoBuyBladeKill = false,

    -- Bank / ATM
    BankAmount = 0, DropMaxLoop = false,
    AutoDeposit30K = false, AutoWithdraw90K = false,

    -- Vehicle Settings
    CarFly = false, CarFlySpeed = 120,
    VehicleSpeedBoost = false, SpeedMultiplier = 5,
    VehicleBrakes = false, BrakeMultiplier = 50,
    InstantStop = false,

    -- Autofarms
    DumpsterFarm = false, StudioFarm = false, ConstructionFarm = false,
    SelectedHouse = nil,

    -- Emotes
    SelectedEmote = "Take The L", LoopEmote = true, EmotePlaying = false,

    -- Outfits
    SelectedOutfit = "Blue Spider",
    FlashOutfit = false, FlashSwapSpeed = 0.2,

    -- Quick TPs
    SelectedLocation = "Gas Station",

    -- Weapon Modifications
    InfiniteAmmo = false, InfiniteClips = false, InfiniteDamage = false,
    InstantReload = false, InstantEquip = false,
    Bullets80k = true, FullyAutomatic = true,
    DisableJamming = false,
    ModifyRecoil = false, ModifySpread = false, ModifyFireRate = false,
    FireBullets = false, FlashbangBullets = false,
    TornadoBullets = false, TornadoSpeed = 250,

    -- Weapon Settings
    FireRatePercent = 100, SpreadPercent = 50,
    RecoilPercent = 50, ReloadSpeed = 0.20, EquipSpeed = 0.20,

    -- Gun Color
    EnableGunColor = false, RainbowGunColor = false, GunColorChoice = "Green",

    -- World Visuals
    Fullbright = false, RealisticGraphics = false,
    EnableSaturation = false, SaturationValue = 100,
    EnableFOV = false, FOVValue = 70,
    EnableStretch = false, StretchValue = 0.70,
    EnableFogColor = false, FogColorChoice = "White",
    EnableAmbientTint = false, AmbientColorChoice = "White",

    -- Player ESP
    ESPEnabled = false, ESPRenderDist = 1400,
    ESPTeamColor = true, ESPBoxes = true,
    ESPBoxType = "Corner", ESPBoxColor = "Orange",
    ESPBoxFill = false, ESPBoxFillColor = "White",
    ESPHealthbar = true, ESPHealthbarNumber = false, ESPHealthbarSize = 3,
    ESPChams = false, ESPChamsColor = "Orange",

    -- Hitbox
    EnableHitbox = false, HitboxPart = "Head",
    HitboxMultiplier = 5, HitboxTransparency = 0.45,
    HitboxMaterial = "ForceField", HitboxType = "Block",
    SkipTeammates = false,

    -- ESP Text / Lines
    ESPName = true, ESPFriendMarker = true, ESPFriendMarkerColor = "Green",
    ESPDistance = true, ESPWeapon = false, ESPTextSize = 14,
    ESPTextColor = "White", ESPSnaplines = false, ESPSnaplineColor = "Orange",
    ESPSkeleton = false, ESPSkeletonColor = "White",
    ESPLookTracers = false, ESPLookTracerColor = "Cyan",

    -- Safe / Dupe
    SelectedSafeItem = "ALL (RANDOM)", AutoDupe = false,
    DupeStatus = "Idle", DupeCount = 0,

    -- Settings
    MenuKey = "lctrl", KeyMode = "Toggle",
    OpenOnLoad = true, CloseWithEscape = false,
    RememberPage = true, MenuCursor = "System",
    UIButton = true, Tooltips = true,
    Animations = true, AnimationSpeed = 105,
    OnOffAlerts = "Keybinds Only", AskBeforeEject = true,

    -- Fly internals
    FlyBV = nil, FlyBG = nil, FlyActive = false,

    -- Connections
    _conns = {},
    _espObjs = {},
}

--============================--
--     UTILITY FUNCTIONS       --
--============================--
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function findRemote(keyword)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and string.find(v.Name:lower(), keyword:lower()) then
            return v
        end
    end
    return nil
end

local function fireRemote(remote, ...)
    if not remote then return end
    if remote:IsA("RemoteEvent") then remote:FireServer(...)
    elseif remote:IsA("RemoteFunction") then pcall(function() remote:InvokeServer(...) end) end
end

local function getNearestPlayer()
    local hrp = getHRP(); if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then closest = p; dist = d end
        end
    end
    return closest
end

local function tpTo(target)
    local hrp = getHRP()
    if hrp and target then hrp.CFrame = target.CFrame + Vector3.new(0,3,0) end
end

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title or "CrashyHub", Text=text or "", Duration=dur or 3})
    end)
end

local ColorMap = {
    White=Color3.new(1,1,1), Black=Color3.new(0,0,0), Red=Color3.new(1,0,0),
    Green=Color3.new(0,1,0), Blue=Color3.new(0,0,1), Orange=Color3.fromRGB(255,165,0),
    Yellow=Color3.new(1,1,0), Purple=Color3.fromRGB(128,0,128),
    Cyan=Color3.new(0,1,1), Pink=Color3.fromRGB(255,105,180),
}
local function getColor(name) return ColorMap[name] or Color3.new(1,1,1) end

local colorOptions = {"White","Black","Red","Green","Blue","Orange","Yellow","Purple","Cyan","Pink"}

local function getPlayersDropdown()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end
    if #list == 0 then table.insert(list, "None") end
    return list
end

local function findPart(kw)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name:lower(), kw:lower()) then return v end
    end
    return nil
end

local function findModel(kw)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(v.Name:lower(), kw:lower()) then
            return v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end

local function getHouses()
    local h = {}
    for _, p in pairs(Players:GetPlayers()) do table.insert(h, p.Name .. "'s House") end
    if #h == 0 then table.insert(h, "None") end
    return h
end

local function getSafeItems()
    local items = {"ALL (RANDOM)"}
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then for _, t in pairs(backpack:GetChildren()) do if t:IsA("Tool") then table.insert(items, t.Name) end end end
        local char = getChar()
        if char then for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(items, t.Name) end end end
    end)
    return items
end

local function getEmotes()
    return {"Take The L","Griddy","Sturdy","Woah","Shoot","Flex","Dab","Praise","Wave","Clap","Laugh","Point","Dance","Pushup","Sit","Lay Down"}
end

local function getQuickBuyItem(name)
    local r = findRemote("buy") or findRemote("shop") or findRemote("purchase")
    if r then fireRemote(r, name); notify("CrashyHub", "Bought: "..name) end
end

local function equipOutfit(name)
    local r = findRemote("outfit") or findRemote("equip") or findRemote("wear")
    if r then fireRemote(r, name); notify("CrashyHub", "Equipped: "..name) end
end

local Locations = {
    ["Gas Station"] = "gasstation",
    ["Cook Pot"] = "cookpot",
    ["Car Dealer"] = "cardealer",
    ["GunShop 1"] = "gunshop",
    ["Studio Robbery"] = "studio",
    ["Exotic Dealer"] = "exotic",
    ["Backpack Shop"] = "backpack",
    ["Pent House"] = "penthouse",
    ["GunShop 5"] = "gunshop5",
    ["Deli 2"] = "deli",
}
local locationList = {"Gas Station","Cook Pot","Car Dealer","GunShop 1","Studio Robbery","Exotic Dealer","Backpack Shop","Pent House","GunShop 5","Deli 2"}

local function tpToLocation(kw)
    local part = findPart(kw) or findModel(kw)
    if part then tpTo(part); notify("CrashyHub","Teleported to location")
    else notify("CrashyHub","Location not found") end
end

local function modGun(prop, val)
    pcall(function()
        local char = getChar()
        if not char then return end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local conf = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings") or tool
                for _, v in pairs(conf:GetDescendants()) do
                    if v.Name:lower():find(prop:lower()) and (v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("BoolValue")) then
                        if v:IsA("BoolValue") then v.Value = val
                        else v.Value = val end
                    end
                end
            end
        end
    end)
end

--============================--
--     LOAD VENTURA UI         --
--============================--
local Library = loadstring(game:HttpGet("https://codeberg.org/VenomVent/Ventura-UI/raw/branch/main/VenturaLibrary.lua"))()
local GUI = Library:new({ name = "CrashyHub", theme = "Dark" })

--========================================================================--
--                         PLAYER TAB                                      --
--========================================================================--
GUI:NavSection("CRASHYHUB")
local PlayerTab = GUI:CreateTab({ name = "Player", icon = "user" })

-- MONEY --
PlayerTab:Section("Money")
PlayerTab:Button({ text = "Instructions: Inf Money", callback = function()
    notify("CrashyHub", "Drop dirty $, clean it, deposit. Use Auto Drop 10k for loop.")
end })
PlayerTab:Button({ text = "Clean All Filthy Money", callback = function()
    local r = findRemote("clean") or findRemote("wash") or findRemote("launder")
    if r then fireRemote(r); notify("CrashyHub","Cleaning all filthy money") end
end })
PlayerTab:Toggle({ text = "Auto Drop 10k", default = false, callback = function(v) State.AutoDrop10k = v end })

-- MONEY ACTIONS --
PlayerTab:Section("Money Actions")
PlayerTab:Button({ text = "Manual [Inf Money]", callback = function()
    local r = findRemote("money") or findRemote("cash") or findRemote("drop")
    if r then for i = 1, 50 do fireRemote(r, 10000); task.wait(0.05) end; notify("CrashyHub","Manual inf money fired") end
end })
PlayerTab:Button({ text = "Generate Max Illegal Money", callback = function()
    local r = findRemote("illegal") or findRemote("dirty") or findRemote("generate")
    if r then fireRemote(r); notify("CrashyHub","Generating max illegal money") end
end })
PlayerTab:Button({ text = "Teleport [COOK POT]", callback = function()
    tpToLocation("cookpot"); tpToLocation("cook")
end })
PlayerTab:Button({ text = "Buy Ice-Fruit [ITEMS]", callback = function()
    getQuickBuyItem("Ice-Fruit")
end })

-- LOCAL PLAYER --
PlayerTab:Section("Local Player")
PlayerTab:Toggle({ text = "FPS Boost (Low Graphics)", default = false, desc = "Disables textures, shadows, particles, and post effects.", callback = function(v)
    State.FPSBoost = v
    if v then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam") then p.Enabled = false
            elseif p:IsA("MeshPart") or p:IsA("Part") then p.Material = Enum.Material.SmoothPlastic; p.Reflectance = 0 end
        end
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        end
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
    end
end })
PlayerTab:Toggle({ text = "Anti Fall Damage", default = false, callback = function(v) State.AntiFallDamage = v end })
PlayerTab:Toggle({ text = "Anti Jump Cooldown", default = false, callback = function(v) State.AntiJumpCooldown = v end })
PlayerTab:Toggle({ text = "Infinite Sleep", default = false, callback = function(v) State.InfiniteSleep = v end })
PlayerTab:Toggle({ text = "Infinite Hunger", default = false, callback = function(v) State.InfiniteHunger = v end })
PlayerTab:Toggle({ text = "Infinite Stamina", default = false, callback = function(v) State.InfiniteStamina = v end })
PlayerTab:Toggle({ text = "No Rent Pay", default = false, callback = function(v) State.NoRentPay = v end })
PlayerTab:Toggle({ text = "Instant Interaction", default = false, callback = function(v)
    State.InstantInteraction = v
    if v then
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then p.HoldDuration = 0 end
        end
    end
end })
PlayerTab:Toggle({ text = "Studio Money Notify", default = false, callback = function(v) State.StudioMoneyNotify = v end })
PlayerTab:Toggle({ text = "Auto Steal Lootbags", default = false, callback = function(v) State.AutoStealLootbags = v end })
PlayerTab:Toggle({ text = "Auto Pickup Bags", default = false, callback = function(v) State.AutoPickupBags = v end })
PlayerTab:Toggle({ text = "Disable Blood Effects", default = false, callback = function(v)
    State.DisableBloodEffects = v
    if v then
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ParticleEmitter") and string.find(p.Name:lower(),"blood") then p.Enabled = false end
        end
    end
end })
PlayerTab:Toggle({ text = "Bypass Locked Cars", default = false, callback = function(v) State.BypassLockedCars = v end })
PlayerTab:Toggle({ text = "No Knockback", default = false, callback = function(v) State.NoKnockback = v end })
PlayerTab:Toggle({ text = "Anti Car Fling", default = false, callback = function(v) State.AntiCarFling = v end })
PlayerTab:Toggle({ text = "Auto Deposit Picked Cash", default = false, callback = function(v) State.AutoDepositPickedCash = v end })
PlayerTab:Toggle({ text = "Auto Steal Dropped Cash", default = false, callback = function(v) State.AutoStealDroppedCash = v end })

-- MISCELLANEOUS --
PlayerTab:Section("Miscellaneous")
PlayerTab:Toggle({ text = "Faster Respawn", default = false, callback = function(v) State.FasterRespawn = v end })
PlayerTab:Toggle({ text = "Respawn Where You Died", default = false, callback = function(v) State.RespawnWhereDied = v end })
PlayerTab:Toggle({ text = "Put Guns On Market When I Die", default = false, desc = "On death, lists every eligible gun for $99,999.", callback = function(v) State.PutGunsOnMarket = v end })
PlayerTab:Toggle({ text = "Instant Revive (auto F on low HP)", default = false, callback = function(v) State.InstantRevive = v end })
PlayerTab:Button({ text = "Get Help - $2000", callback = function()
    local r = findRemote("help") or findRemote("gethelp") or findRemote("medic")
    if r then fireRemote(r); notify("CrashyHub","Getting help - $2000") end
end })
PlayerTab:Toggle({ text = "Auto Get Help", default = false, callback = function(v) State.AutoGetHelp = v end })
PlayerTab:Toggle({ text = "Anti-AFK (20 min)", default = false, callback = function(v)
    State.AntiAFK = v
    if v then
        local vu = game:GetService("VirtualUser")
        if State._conns.antiAFK then State._conns.antiAFK:Disconnect() end
        State._conns.antiAFK = LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    else
        if State._conns.antiAFK then State._conns.antiAFK:Disconnect(); State._conns.antiAFK = nil end
    end
end })

-- MOVEMENT --
PlayerTab:Section("Movement")
PlayerTab:Toggle({ text = "No Blur", default = false, callback = function(v)
    State.NoBlur = v
    for _, b in pairs(Lighting:GetChildren()) do if b:IsA("BlurEffect") then b.Enabled = not v end end
end })
PlayerTab:Toggle({ text = "Disable Camera Bobbing", default = false, callback = function(v) State.DisableCameraBobbing = v end })
PlayerTab:Toggle({ text = "WalkSpeed", default = false, callback = function(v) State.WalkSpeedEnabled = v end })
PlayerTab:Slider({ text = "Change Walk Speed", min = 1, max = 200, default = 16, callback = function(v) State.WalkSpeedValue = v end })
PlayerTab:Paragraph({ text = "Hold Left Shift for 2\195\151 speed." })
PlayerTab:Toggle({ text = "Jump Boost", default = false, callback = function(v) State.JumpBoost = v end })
PlayerTab:Toggle({ text = "Infinite Jump", default = false, callback = function(v) State.InfiniteJump = v end })
PlayerTab:Toggle({ text = "Noclip", default = false, callback = function(v) State.Noclip = v end })
PlayerTab:Toggle({ text = "Fly", default = false, callback = function(v)
    State.Fly = v
    if not v and State.FlyActive then
        State.FlyActive = false
        if State.FlyBV then State.FlyBV:Destroy(); State.FlyBV = nil end
        if State.FlyBG then State.FlyBG:Destroy(); State.FlyBG = nil end
        local hum = getHum(); if hum then hum.PlatformStand = false end
    end
end })
PlayerTab:Slider({ text = "Fly Speed", min = 10, max = 500, default = 80, callback = function(v) State.FlySpeed = v end })
PlayerTab:Paragraph({ text = "Fly controls: WASD + Space/Shift + Q/E speed" })
PlayerTab:Toggle({ text = "Custom Crosshair", default = false, callback = function(v)
    State.CustomCrosshair = v
    if v then
        local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = "CrashyCross"
        local h = Instance.new("Frame",sg); h.Size=UDim2.new(0,20,0,2); h.Position=UDim2.new(0.5,-10,0.5,-1); h.BackgroundColor3=Color3.new(1,0,0); h.BorderSizePixel=0
        local vl = Instance.new("Frame",sg); vl.Size=UDim2.new(0,2,0,20); vl.Position=UDim2.new(0.5,-1,0.5,-10); vl.BackgroundColor3=Color3.new(1,0,0); vl.BorderSizePixel=0
    else
        local sg = game.CoreGui:FindFirstChild("CrashyCross"); if sg then sg:Destroy() end
    end
end })

-- QUICK BUY --
PlayerTab:Section("Quick Buy")
PlayerTab:Button({ text = "BagElite", callback = function() getQuickBuyItem("BagElite") end })
PlayerTab:Button({ text = "Draco", callback = function() getQuickBuyItem("Draco") end })
PlayerTab:Button({ text = "Shiesty", callback = function() getQuickBuyItem("Shiesty") end })
PlayerTab:Button({ text = "Lemonade", callback = function() getQuickBuyItem("Lemonade") end })
PlayerTab:Button({ text = "Bandage", callback = function() getQuickBuyItem("Bandage") end })

--========================================================================--
--                          MAIN TAB                                       --
--========================================================================--
local MainTab = GUI:CreateTab({ name = "Main", icon = "home" })

-- TARGET --
MainTab:Section("Target")
local playerDD
playerDD = MainTab:Dropdown({ text = "Select Player", options = getPlayersDropdown(), selected = "", callback = function(v) State.SelectedPlayer = v end })
MainTab:Button({ text = "Refresh Player List", callback = function()
    if playerDD and playerDD.SetOptions then playerDD:SetOptions(getPlayersDropdown()) end
    notify("CrashyHub","Player list refreshed")
end })
MainTab:Button({ text = "Pass to Nearest Player", callback = function()
    local n = getNearestPlayer()
    if n then
        local r = findRemote("pass") or findRemote("throw")
        if r then fireRemote(r, n) end
        notify("CrashyHub","Passed to "..n.Name)
    end
end })
MainTab:Toggle({ text = "Auto Pass to Nearest (loop)", default = false, callback = function(v) State.AutoPassNearest = v end })
MainTab:Toggle({ text = "Auto Drop Guns", default = false, callback = function(v) State.AutoDropGuns = v end })
MainTab:Toggle({ text = "Spectate Player", default = false, callback = function(v)
    State.SpectatePlayer = v
    if v and State.SelectedPlayer then
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character then Camera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid") end
    else
        local h = getHum(); if h then Camera.CameraSubject = h end
    end
end })
MainTab:Toggle({ text = "Bring Nearest Player", default = false, callback = function(v) State.BringNearestPlayer = v end })
MainTab:Toggle({ text = "Bring Player", default = false, callback = function(v) State.BringPlayer = v end })
MainTab:Toggle({ text = "Auto Kill Player - Gun", default = false, desc = "Auto Kill: the person can't be too far for it to work.", callback = function(v) State.AutoKillGun = v end })
MainTab:Button({ text = "Car Fling Selected Player", callback = function()
    if State.SelectedPlayer then
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHRP()
            if hrp then
                local closest, dist = nil, math.huge
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("VehicleSeat") then
                        local d = (v.Position - hrp.Position).Magnitude
                        if d < dist then closest = v; dist = d end
                    end
                end
                if closest then
                    closest.CFrame = p.Character.HumanoidRootPart.CFrame
                    notify("CrashyHub","Car fling attempted on "..p.Name)
                end
            end
        end
    end
end })
MainTab:Toggle({ text = "Auto Ragdoll Player - Gun", default = false, callback = function(v) State.AutoRagdollGun = v end })
MainTab:Button({ text = "Teleport To Player", callback = function()
    if State.SelectedPlayer then
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            tpTo(p.Character.HumanoidRootPart)
            notify("CrashyHub","TP'd to "..p.Name)
        end
    end
end })
MainTab:Button({ text = "God Player - Hold Gun", callback = function()
    local r = findRemote("god") or findRemote("heal")
    if r then fireRemote(r); notify("CrashyHub","God mode attempted") end
end })
MainTab:Toggle({ text = "Auto Blade Kill", default = false, callback = function(v) State.AutoBladeKill = v end })
MainTab:Toggle({ text = "Auto Buy Blade + Kill Player", default = false, callback = function(v) State.AutoBuyBladeKill = v end })

-- BANK / ATM --
MainTab:Section("Bank / ATM")
local bankLabel = MainTab:Paragraph({ text = "Bank Amount: $0" })
MainTab:Input({ text = "Withdraw Amount", placeholder = "Max 90,000", callback = function(v)
    local amt = tonumber(v)
    if amt then
        local r = findRemote("withdraw") or findRemote("atm")
        if r then fireRemote(r, "withdraw", math.min(amt, 90000)); notify("CrashyHub","Withdrawing $"..tostring(math.min(amt, 90000))) end
    end
end })
MainTab:Input({ text = "Deposit Amount", placeholder = "Max 30,000", callback = function(v)
    local amt = tonumber(v)
    if amt then
        local r = findRemote("deposit") or findRemote("atm")
        if r then fireRemote(r, "deposit", math.min(amt, 30000)); notify("CrashyHub","Depositing $"..tostring(math.min(amt, 30000))) end
    end
end })
MainTab:Toggle({ text = "Drop Max ($10k loop)", default = false, callback = function(v) State.DropMaxLoop = v end })
MainTab:Toggle({ text = "Auto Deposit 30K", default = false, callback = function(v) State.AutoDeposit30K = v end })
MainTab:Toggle({ text = "Auto Withdraw 90K", default = false, callback = function(v) State.AutoWithdraw90K = v end })

-- VEHICLE SETTINGS --
MainTab:Section("Vehicle Settings")
MainTab:Toggle({ text = "Car Fly", default = false, callback = function(v) State.CarFly = v end })
MainTab:Slider({ text = "Car Fly Speed", min = 10, max = 500, default = 120, callback = function(v) State.CarFlySpeed = v end })
MainTab:Toggle({ text = "Vehicle Speed Boost", default = false, callback = function(v) State.VehicleSpeedBoost = v end })
MainTab:Slider({ text = "Speed Multiplier", min = 1, max = 50, default = 5, callback = function(v) State.SpeedMultiplier = v end })
MainTab:Toggle({ text = "Vehicle Brakes", default = false, callback = function(v) State.VehicleBrakes = v end })
MainTab:Slider({ text = "Brake Multiplier", min = 1, max = 200, default = 50, callback = function(v) State.BrakeMultiplier = v end })
MainTab:Toggle({ text = "Instant Stop (V)", default = false, callback = function(v) State.InstantStop = v end })
MainTab:Button({ text = "Bring Nearest Car", callback = function()
    local hrp = getHRP(); if not hrp then return end
    local closest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") then
            local d = (v.Position - hrp.Position).Magnitude
            if d < dist then closest = v; dist = d end
        end
    end
    if closest then closest.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10; notify("CrashyHub","Car brought") end
end })

--========================================================================--
--                          FARM TAB                                       --
--========================================================================--
local FarmTab = GUI:CreateTab({ name = "Farm", icon = "box" })

-- AUTOFARMS --
FarmTab:Section("Autofarms")
FarmTab:Button({ text = "Dumpster Autofarm", callback = function()
    State.DumpsterFarm = not State.DumpsterFarm
    notify("CrashyHub", "Dumpster Autofarm: "..(State.DumpsterFarm and "ON" or "OFF"))
    if State.DumpsterFarm then
        task.spawn(function()
            while State.DumpsterFarm do
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not State.DumpsterFarm then break end
                        if v:IsA("BasePart") and string.find(v.Name:lower(), "dumpster") then
                            tpTo(v); task.wait(1)
                            local r = findRemote("interact") or findRemote("loot") or findRemote("search")
                            if r then fireRemote(r, v) end
                            task.wait(1)
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end })
FarmTab:Button({ text = "Studio Autofarm", callback = function()
    State.StudioFarm = not State.StudioFarm
    notify("CrashyHub", "Studio Autofarm: "..(State.StudioFarm and "ON" or "OFF"))
    if State.StudioFarm then
        task.spawn(function()
            while State.StudioFarm do
                pcall(function()
                    local studio = findPart("studio") or findModel("studio")
                    if studio then tpTo(studio); task.wait(1)
                        local r = findRemote("rob") or findRemote("studio") or findRemote("interact")
                        if r then fireRemote(r) end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end })
FarmTab:Button({ text = "Construction Autofarm", callback = function()
    State.ConstructionFarm = not State.ConstructionFarm
    notify("CrashyHub", "Construction Autofarm: "..(State.ConstructionFarm and "ON" or "OFF"))
    if State.ConstructionFarm then
        task.spawn(function()
            while State.ConstructionFarm do
                pcall(function()
                    local site = findPart("construct") or findModel("construct")
                    if site then tpTo(site); task.wait(1)
                        local r = findRemote("construct") or findRemote("work") or findRemote("interact")
                        if r then fireRemote(r) end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end })

-- HOUSE TPS --
FarmTab:Section("House TPs")
local houseDD
houseDD = FarmTab:Dropdown({ text = "Select House", options = getHouses(), selected = "", callback = function(v) State.SelectedHouse = v end })
FarmTab:Button({ text = "Refresh Houses", callback = function()
    if houseDD and houseDD.SetOptions then houseDD:SetOptions(getHouses()) end
    notify("CrashyHub","House list refreshed")
end })
FarmTab:Button({ text = "Teleport To House", callback = function()
    if State.SelectedHouse then
        local owner = string.match(State.SelectedHouse, "(.+)'s House")
        if owner then
            local part = findPart(owner) or findModel(owner.."house") or findModel("house")
            if part then tpTo(part); notify("CrashyHub","TP'd to "..State.SelectedHouse)
            else notify("CrashyHub","House not found") end
        end
    end
end })

--========================================================================--
--                          EXTRA TAB                                      --
--========================================================================--
local ExtraTab = GUI:CreateTab({ name = "Extra", icon = "star" })

-- EMOTES --
ExtraTab:Section("Emotes")
ExtraTab:Dropdown({ text = "Select Emote", options = getEmotes(), selected = "Take The L", callback = function(v) State.SelectedEmote = v end })
ExtraTab:Button({ text = "Play Selected Emote", callback = function()
    State.EmotePlaying = true
    local r = findRemote("emote") or findRemote("animate")
    if r then fireRemote(r, State.SelectedEmote); notify("CrashyHub","Playing: "..State.SelectedEmote) end
end })
ExtraTab:Button({ text = "Stop Emote", callback = function()
    State.EmotePlaying = false
    local hum = getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
end })

-- EMOTE SETTINGS --
ExtraTab:Section("Emote Settings")
ExtraTab:Toggle({ text = "Loop Emote", default = true, callback = function(v) State.LoopEmote = v end })

-- QUICK OUTFITS --
ExtraTab:Section("Quick Outfits")
ExtraTab:Button({ text = "Spiderman", callback = function() equipOutfit("Spiderman") end })
ExtraTab:Button({ text = "All Black", callback = function() equipOutfit("All Black") end })
ExtraTab:Button({ text = "Blu Moncler Drip", callback = function() equipOutfit("Blu Moncler Drip") end })
ExtraTab:Button({ text = "Amiri Star Drip", callback = function() equipOutfit("Amiri Star Drip") end })
ExtraTab:Button({ text = "Red Sp5der Drip", callback = function() equipOutfit("Red Sp5der Drip") end })
ExtraTab:Button({ text = "Green Sp5der Drip", callback = function() equipOutfit("Green Sp5der Drip") end })
ExtraTab:Button({ text = "Blue Sp5der Drip", callback = function() equipOutfit("Blue Sp5der Drip") end })
ExtraTab:Button({ text = "Red Zipped Drip", callback = function() equipOutfit("Red Zipped Drip") end })
ExtraTab:Dropdown({ text = "Outfit Preset", options = {"Blue Spider","Spiderman","All Black","Blu Moncler Drip","Amiri Star Drip","Red Sp5der Drip","Green Sp5der Drip","Blue Sp5der Drip","Red Zipped Drip"}, selected = "Blue Spider", callback = function(v) State.SelectedOutfit = v end })
ExtraTab:Button({ text = "Equip Selected Outfit", callback = function() equipOutfit(State.SelectedOutfit) end })
ExtraTab:Toggle({ text = "Flash Outfit", default = false, callback = function(v) State.FlashOutfit = v end })
ExtraTab:Slider({ text = "Flash Swap Speed", min = 0.05, max = 2, default = 0.2, callback = function(v) State.FlashSwapSpeed = v end })

-- QUICK TPS --
ExtraTab:Section("Quick TPs")
ExtraTab:Dropdown({ text = "Location", options = locationList, selected = "Gas Station", callback = function(v) State.SelectedLocation = v end })
ExtraTab:Button({ text = "Teleport", callback = function()
    local kw = Locations[State.SelectedLocation]
    if kw then tpToLocation(kw) end
end })
ExtraTab:Button({ text = "Dynamic Cook Pot", callback = function() tpToLocation("cookpot"); tpToLocation("cook") end })
ExtraTab:Button({ text = "Car Dealer", callback = function() tpToLocation("cardealer"); tpToLocation("dealer") end })
ExtraTab:Button({ text = "GunShop 1", callback = function() tpToLocation("gunshop") end })
ExtraTab:Button({ text = "Studio Robbery", callback = function() tpToLocation("studio") end })
ExtraTab:Button({ text = "Exotic Dealer", callback = function() tpToLocation("exotic") end })
ExtraTab:Button({ text = "Backpack Shop", callback = function() tpToLocation("backpack") end })
ExtraTab:Button({ text = "Pent House", callback = function() tpToLocation("penthouse"); tpToLocation("pent") end })
ExtraTab:Button({ text = "GunShop 5", callback = function() tpToLocation("gunshop5"); tpToLocation("gunshop") end })
ExtraTab:Button({ text = "Deli 2", callback = function() tpToLocation("deli") end })

--========================================================================--
--                        GUN MODS TAB                                     --
--========================================================================--
local GunModsTab = GUI:CreateTab({ name = "Gun Mods", icon = "crosshair" })

-- WEAPON MODIFICATIONS --
GunModsTab:Section("Weapon Modifications")
GunModsTab:Toggle({ text = "Infinite Ammo", default = false, callback = function(v) State.InfiniteAmmo = v end })
GunModsTab:Toggle({ text = "Infinite Clips", default = false, callback = function(v) State.InfiniteClips = v end })
GunModsTab:Toggle({ text = "Infinite Damage", default = false, callback = function(v) State.InfiniteDamage = v end })
GunModsTab:Toggle({ text = "Instant Reload", default = false, callback = function(v) State.InstantReload = v end })
GunModsTab:Toggle({ text = "Instant Equip", default = false, callback = function(v) State.InstantEquip = v end })
GunModsTab:Toggle({ text = "80k Bullets", default = true, desc = "80k bullet guns cannot be passed to others", callback = function(v) State.Bullets80k = v end })
GunModsTab:Toggle({ text = "Fully Automatic", default = true, callback = function(v) State.FullyAutomatic = v end })
GunModsTab:Toggle({ text = "Disable Jamming", default = false, callback = function(v) State.DisableJamming = v end })
GunModsTab:Toggle({ text = "Modify Recoil Value", default = false, callback = function(v) State.ModifyRecoil = v end })
GunModsTab:Toggle({ text = "Modify Spread Value", default = false, callback = function(v) State.ModifySpread = v end })
GunModsTab:Toggle({ text = "Modify Fire Rate", default = false, callback = function(v) State.ModifyFireRate = v end })
GunModsTab:Button({ text = "Force 80k Bullets", callback = function()
    pcall(function()
        local char = getChar()
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then modGun("ammo", 80000); modGun("clip", 80000) end
            end
        end
    end)
    notify("CrashyHub","Forced 80k bullets")
end })
GunModsTab:Toggle({ text = "Fire Bullets", default = false, callback = function(v) State.FireBullets = v end })
GunModsTab:Toggle({ text = "Flashbang Bullets", default = false, callback = function(v) State.FlashbangBullets = v end })
GunModsTab:Toggle({ text = "Tornado Bullets", default = false, callback = function(v) State.TornadoBullets = v end })
GunModsTab:Slider({ text = "Tornado Speed", min = 10, max = 1000, default = 250, callback = function(v) State.TornadoSpeed = v end })

-- WEAPON SETTINGS --
GunModsTab:Section("Weapon Settings")
GunModsTab:Paragraph({ text = "100% is default percentage." })
GunModsTab:Slider({ text = "Fire-Rate", min = 1, max = 500, default = 100, callback = function(v) State.FireRatePercent = v end })
GunModsTab:Slider({ text = "Spread", min = 0, max = 200, default = 50, callback = function(v) State.SpreadPercent = v end })
GunModsTab:Slider({ text = "Recoil", min = 0, max = 200, default = 50, callback = function(v) State.RecoilPercent = v end })
GunModsTab:Slider({ text = "Reload Speed", min = 0.01, max = 5, default = 0.20, callback = function(v) State.ReloadSpeed = v end })
GunModsTab:Slider({ text = "Equip Speed", min = 0.01, max = 5, default = 0.20, callback = function(v) State.EquipSpeed = v end })

-- GUN COLOR --
GunModsTab:Section("Gun Color")
GunModsTab:Toggle({ text = "Enable Gun Color", default = false, callback = function(v) State.EnableGunColor = v end })
GunModsTab:Toggle({ text = "Rainbow Gun Color", default = false, callback = function(v) State.RainbowGunColor = v end })
GunModsTab:Dropdown({ text = "Gun Color", options = colorOptions, selected = "Green", callback = function(v) State.GunColorChoice = v end })

--========================================================================--
--                        VISUALS TAB                                      --
--========================================================================--
local VisualsTab = GUI:CreateTab({ name = "Visuals", icon = "eye" })

-- WORLD VISUALS --
VisualsTab:Section("World Visuals")
VisualsTab:Toggle({ text = "Fullbright", default = false, callback = function(v)
    State.Fullbright = v
    if v then
        Lighting.Brightness = 2; Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9; Lighting.GlobalShadows = false
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("Atmosphere") then e.Density = 0 end
        end
    else
        Lighting.Brightness = 1; Lighting.GlobalShadows = true
    end
end })
VisualsTab:Toggle({ text = "Realistic Graphics", default = false, callback = function(v)
    State.RealisticGraphics = v
    if v then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        Lighting.GlobalShadows = true; Lighting.Brightness = 1.5
        local bloom = Instance.new("BloomEffect", Lighting); bloom.Name = "CrashyBloom"; bloom.Intensity = 0.3
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        local b = Lighting:FindFirstChild("CrashyBloom"); if b then b:Destroy() end
    end
end })
VisualsTab:Toggle({ text = "Enable Saturation", default = false, callback = function(v)
    State.EnableSaturation = v
    if v then
        local cc = Lighting:FindFirstChild("CrashySat") or Instance.new("ColorCorrectionEffect", Lighting)
        cc.Name = "CrashySat"; cc.Saturation = State.SaturationValue / 100
    else
        local cc = Lighting:FindFirstChild("CrashySat"); if cc then cc:Destroy() end
    end
end })
VisualsTab:Slider({ text = "Saturation", min = 0, max = 200, default = 100, callback = function(v)
    State.SaturationValue = v
    local cc = Lighting:FindFirstChild("CrashySat")
    if cc then cc.Saturation = v / 100 end
end })
VisualsTab:Toggle({ text = "Enable FOV", default = false, callback = function(v)
    State.EnableFOV = v
    if v then Camera.FieldOfView = State.FOVValue
    else Camera.FieldOfView = 70 end
end })
VisualsTab:Slider({ text = "FOV Value", min = 30, max = 120, default = 70, callback = function(v)
    State.FOVValue = v
    if State.EnableFOV then Camera.FieldOfView = v end
end })
VisualsTab:Toggle({ text = "Enable Stretch", default = false, callback = function(v)
    State.EnableStretch = v
    if v then Camera.CFrame = Camera.CFrame * CFrame.new(0, State.StretchValue, 0)
    end
end })
VisualsTab:Slider({ text = "Stretch Value", min = 0.1, max = 3, default = 0.70, callback = function(v) State.StretchValue = v end })
VisualsTab:Toggle({ text = "Enable Fog Color", default = false, callback = function(v)
    State.EnableFogColor = v
    if v then Lighting.FogColor = getColor(State.FogColorChoice)
    else Lighting.FogColor = Color3.fromRGB(192,192,192) end
end })
VisualsTab:Dropdown({ text = "Fog Color", options = colorOptions, selected = "White", callback = function(v)
    State.FogColorChoice = v
    if State.EnableFogColor then Lighting.FogColor = getColor(v) end
end })
VisualsTab:Toggle({ text = "Enable Ambient Tint", default = false, callback = function(v)
    State.EnableAmbientTint = v
    if v then Lighting.Ambient = getColor(State.AmbientColorChoice)
    else Lighting.Ambient = Color3.fromRGB(128,128,128) end
end })
VisualsTab:Dropdown({ text = "Ambient Color", options = colorOptions, selected = "White", callback = function(v)
    State.AmbientColorChoice = v
    if State.EnableAmbientTint then Lighting.Ambient = getColor(v) end
end })

-- PLAYER ESP --
VisualsTab:Section("Player ESP")
VisualsTab:Toggle({ text = "ESP Enabled", default = false, callback = function(v) State.ESPEnabled = v end })
VisualsTab:Slider({ text = "Render Distance", min = 100, max = 5000, default = 1400, callback = function(v) State.ESPRenderDist = v end })
VisualsTab:Toggle({ text = "Team Color", default = true, callback = function(v) State.ESPTeamColor = v end })
VisualsTab:Toggle({ text = "Boxes", default = true, callback = function(v) State.ESPBoxes = v end })
VisualsTab:Dropdown({ text = "Box Type", options = {"Corner","Full","3D"}, selected = "Corner", callback = function(v) State.ESPBoxType = v end })
VisualsTab:Dropdown({ text = "Box Color", options = colorOptions, selected = "Orange", callback = function(v) State.ESPBoxColor = v end })
VisualsTab:Toggle({ text = "Box Fill", default = false, callback = function(v) State.ESPBoxFill = v end })
VisualsTab:Dropdown({ text = "Box Fill Color", options = colorOptions, selected = "White", callback = function(v) State.ESPBoxFillColor = v end })
VisualsTab:Toggle({ text = "Healthbar", default = true, callback = function(v) State.ESPHealthbar = v end })
VisualsTab:Toggle({ text = "Healthbar Number", default = false, callback = function(v) State.ESPHealthbarNumber = v end })
VisualsTab:Slider({ text = "Healthbar Size", min = 1, max = 10, default = 3, callback = function(v) State.ESPHealthbarSize = v end })
VisualsTab:Toggle({ text = "Chams", default = false, callback = function(v) State.ESPChams = v end })
VisualsTab:Dropdown({ text = "Chams Color", options = colorOptions, selected = "Orange", callback = function(v) State.ESPChamsColor = v end })

-- HITBOX --
VisualsTab:Section("Hitbox")
VisualsTab:Toggle({ text = "Enable Hitbox", default = false, callback = function(v) State.EnableHitbox = v end })
VisualsTab:Dropdown({ text = "Part", options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, selected = "Head", callback = function(v) State.HitboxPart = v end })
VisualsTab:Slider({ text = "Multiplier", min = 1, max = 20, default = 5, callback = function(v) State.HitboxMultiplier = v end })
VisualsTab:Slider({ text = "Transparency", min = 0, max = 1, default = 0.45, callback = function(v) State.HitboxTransparency = v end })
VisualsTab:Dropdown({ text = "Material", options = {"ForceField","Neon","Glass","SmoothPlastic"}, selected = "ForceField", callback = function(v) State.HitboxMaterial = v end })
VisualsTab:Dropdown({ text = "Type", options = {"Block","Ball","Cylinder"}, selected = "Block", callback = function(v) State.HitboxType = v end })
VisualsTab:Toggle({ text = "Skip Teammates", default = false, callback = function(v) State.SkipTeammates = v end })

-- ESP TEXT / LINES --
VisualsTab:Section("ESP Text / Lines")
VisualsTab:Toggle({ text = "Name", default = true, callback = function(v) State.ESPName = v end })
VisualsTab:Toggle({ text = "Friend Marker (F)", default = true, callback = function(v) State.ESPFriendMarker = v end })
VisualsTab:Dropdown({ text = "Friend Marker Color", options = colorOptions, selected = "Green", callback = function(v) State.ESPFriendMarkerColor = v end })
VisualsTab:Toggle({ text = "Distance", default = true, callback = function(v) State.ESPDistance = v end })
VisualsTab:Toggle({ text = "Weapon", default = false, callback = function(v) State.ESPWeapon = v end })
VisualsTab:Slider({ text = "Text Size", min = 8, max = 30, default = 14, callback = function(v) State.ESPTextSize = v end })
VisualsTab:Dropdown({ text = "Text Color", options = colorOptions, selected = "White", callback = function(v) State.ESPTextColor = v end })
VisualsTab:Toggle({ text = "Snaplines", default = false, callback = function(v) State.ESPSnaplines = v end })
VisualsTab:Dropdown({ text = "Snapline Color", options = colorOptions, selected = "Orange", callback = function(v) State.ESPSnaplineColor = v end })
VisualsTab:Toggle({ text = "Skeleton", default = false, callback = function(v) State.ESPSkeleton = v end })
VisualsTab:Dropdown({ text = "Skeleton Color", options = colorOptions, selected = "White", callback = function(v) State.ESPSkeletonColor = v end })
VisualsTab:Toggle({ text = "Look Tracers", default = false, callback = function(v) State.ESPLookTracers = v end })
VisualsTab:Dropdown({ text = "Look Tracer Color", options = colorOptions, selected = "Cyan", callback = function(v) State.ESPLookTracerColor = v end })

--========================================================================--
--                          SAFE TAB                                       --
--========================================================================--
local SafeTab = GUI:CreateTab({ name = "Safe", icon = "lock" })

-- ACE AUTO DUPE --
SafeTab:Section("Ace Auto Dupe")
local safeItemDD
safeItemDD = SafeTab:Dropdown({ text = "Item", options = getSafeItems(), selected = "ALL (RANDOM)", callback = function(v) State.SelectedSafeItem = v end })
SafeTab:Button({ text = "Refresh Items", callback = function()
    if safeItemDD and safeItemDD.SetOptions then safeItemDD:SetOptions(getSafeItems()) end
    notify("CrashyHub","Item list refreshed")
end })
SafeTab:Button({ text = "Safe TP", callback = function()
    local part = findPart("safe") or findModel("safe")
    if part then tpTo(part); notify("CrashyHub","TP'd to safe") end
end })
SafeTab:Button({ text = "Take Items Out Safe", callback = function()
    local r = findRemote("safe") or findRemote("take") or findRemote("withdraw")
    if r then fireRemote(r, "take"); notify("CrashyHub","Taking items out of safe") end
end })
SafeTab:Button({ text = "Stop Taking Items Out", callback = function()
    State.AutoDupe = false
    notify("CrashyHub","Stopped taking items out")
end })
local dupeStatusLabel = SafeTab:Paragraph({ text = "Status: Idle" })
local dupeCountLabel = SafeTab:Paragraph({ text = "Duped: 0" })
SafeTab:Toggle({ text = "Auto Dupe", default = false, callback = function(v)
    State.AutoDupe = v
    if v then
        State.DupeStatus = "Running"
        task.spawn(function()
            while State.AutoDupe do
                pcall(function()
                    local r = findRemote("safe") or findRemote("dupe") or findRemote("take")
                    if r then
                        if State.SelectedSafeItem == "ALL (RANDOM)" then
                            fireRemote(r, "take")
                        else
                            fireRemote(r, "take", State.SelectedSafeItem)
                        end
                        State.DupeCount = State.DupeCount + 1
                    end
                end)
                task.wait(0.5)
            end
            State.DupeStatus = "Idle"
        end)
    else
        State.DupeStatus = "Idle"
    end
end })
SafeTab:Paragraph({ text = "Select an item or use ALL (RANDOM). Toggle Auto Dupe to start." })

--========================================================================--
--                        SCRIPT TAB                                       --
--========================================================================--
local ScriptTab = GUI:CreateTab({ name = "Script", icon = "terminal" })

-- CRASHYHUB --
ScriptTab:Section("CrashyHub")
ScriptTab:Paragraph({ text = "Script: CrashyHub" })
ScriptTab:Paragraph({ text = "Discord: discord.gg/crashhh" })
ScriptTab:Button({ text = "Copy Discord", callback = function()
    pcall(function() setclipboard("https://discord.gg/crashhh") end)
    notify("CrashyHub","Discord copied to clipboard")
end })
ScriptTab:Button({ text = "Test Button", callback = function()
    notify("CrashyHub","Test successful — CrashyHub is running!")
end })

-- MY MONEY --
ScriptTab:Section("My Money")
local moneyCleanLabel = ScriptTab:Paragraph({ text = "Clean Money: $0" })
local moneyBankLabel = ScriptTab:Paragraph({ text = "Bank: $0" })
local moneyDirtyLabel = ScriptTab:Paragraph({ text = "Dirty Money: $0" })
local moneyMadeLabel = ScriptTab:Paragraph({ text = "Money Made: $0" })
local moneyLostLabel = ScriptTab:Paragraph({ text = "Money Lost: $0" })

-- MENU SETTINGS --
ScriptTab:Section("Menu Settings")
ScriptTab:Paragraph({ text = "Script: CrashyHub" })
ScriptTab:Paragraph({ text = "UI Library Owned by crashyyyy" })
ScriptTab:Paragraph({ text = "Game: THA BRONX 3" })
ScriptTab:Paragraph({ text = "Developed by crashyyyy" })
ScriptTab:Paragraph({ text = "Status: Working" })
ScriptTab:Button({ text = "Eject", callback = function()
    notify("CrashyHub","Ejecting...")
    task.wait(0.5)
    GUI:Destroy()
    for k, conn in pairs(State._conns) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    for _, obj in pairs(State._espObjs) do
        pcall(function() obj:Destroy() end)
    end
end })
ScriptTab:Button({ text = "Rejoin Server", callback = function()
    notify("CrashyHub","Rejoining server...")
    task.wait(1)
    TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })
ScriptTab:Button({ text = "Server Hop", callback = function()
    notify("CrashyHub","Server hopping...")
    task.wait(1)
    pcall(function()
        local ts = game:GetService("TeleportService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end })
ScriptTab:Button({ text = "Copy Discord", callback = function()
    pcall(function() setclipboard("https://discord.gg/crashhh") end)
    notify("CrashyHub","Discord copied to clipboard")
end })
ScriptTab:Paragraph({ text = "Executor: Potassium" })

--========================================================================--
--                       SETTINGS TABS                                     --
--========================================================================--
GUI:NavSection("SETTINGS")
local SettingsGeneral = GUI:CreateTab({ name = "General", icon = "settings" })
local SettingsAppearance = GUI:CreateTab({ name = "Appearance", icon = "palette" })

-- GENERAL > MENU --
SettingsGeneral:Section("Menu")
SettingsGeneral:Dropdown({ text = "Menu Key", options = {"lctrl","rctrl","lalt","ralt","f1","f2","f3","f4"}, selected = "lctrl", callback = function(v) State.MenuKey = v end })
SettingsGeneral:Dropdown({ text = "Key Mode", options = {"Toggle","Hold"}, selected = "Toggle", callback = function(v) State.KeyMode = v end })
SettingsGeneral:Toggle({ text = "Open On Load", default = true, callback = function(v) State.OpenOnLoad = v end })
SettingsGeneral:Toggle({ text = "Close With Escape", default = false, callback = function(v) State.CloseWithEscape = v end })
SettingsGeneral:Toggle({ text = "Remember Page", default = true, callback = function(v) State.RememberPage = v end })
SettingsGeneral:Dropdown({ text = "Menu Cursor", options = {"System","Custom","Hidden"}, selected = "System", callback = function(v) State.MenuCursor = v end })
SettingsGeneral:Toggle({ text = "UI Button", default = true, callback = function(v) State.UIButton = v end })

-- GENERAL > BEHAVIOR --
SettingsGeneral:Section("Behavior")
SettingsGeneral:Toggle({ text = "Tooltips", default = true, callback = function(v) State.Tooltips = v end })
SettingsGeneral:Toggle({ text = "Animations", default = true, callback = function(v) State.Animations = v end })
SettingsGeneral:Slider({ text = "Animation Speed", min = 50, max = 200, default = 105, callback = function(v) State.AnimationSpeed = v end })
SettingsGeneral:Dropdown({ text = "On/Off Alerts", options = {"All","Keybinds Only","None"}, selected = "Keybinds Only", callback = function(v) State.OnOffAlerts = v end })
SettingsGeneral:Toggle({ text = "Ask Before Eject", default = true, callback = function(v) State.AskBeforeEject = v end })

-- GENERAL > ABOUT --
SettingsGeneral:Section("About")
SettingsGeneral:Paragraph({ text = "Script \226\128\148 CrashyHub" })
SettingsGeneral:Paragraph({ text = "Made By \226\128\148 crashyyyy" })
SettingsGeneral:Paragraph({ text = "Executor \226\128\148 Potassium v2.6.0" })

-- GENERAL > WINDOW --
SettingsGeneral:Section("Window")
SettingsGeneral:Button({ text = "Center Window", callback = function()
    notify("CrashyHub","Window centered")
end })
SettingsGeneral:Button({ text = "Eject", callback = function()
    notify("CrashyHub","Ejecting...")
    task.wait(0.5)
    GUI:Destroy()
end })

-- APPEARANCE --
SettingsAppearance:Section("Theme")
SettingsAppearance:Dropdown({ text = "Theme", options = {"Dark","Light","Midnight","Crimson"}, selected = "Dark", callback = function(v)
    notify("CrashyHub","Theme set to "..v)
end })
SettingsAppearance:Toggle({ text = "Transparency", default = false, callback = function(v)
    notify("CrashyHub","Transparency: "..(v and "ON" or "OFF"))
end })
SettingsAppearance:Slider({ text = "Transparency Value", min = 0, max = 100, default = 0, callback = function(v)
    -- Would adjust UI transparency
end })
SettingsAppearance:Toggle({ text = "Blur Background", default = false, callback = function(v)
    notify("CrashyHub","Blur: "..(v and "ON" or "OFF"))
end })

--========================================================================--
--                       RUNTIME LOOPS                                     --
--========================================================================--

-- Stepped: Noclip --
RunService.Stepped:Connect(function()
    if State.Noclip then
        pcall(function()
            local char = getChar()
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end)

-- Heartbeat: gun mods, movement, fly, autofarms, misc loops --
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = getChar()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        -- WalkSpeed
        if State.WalkSpeedEnabled and hum then hum.WalkSpeed = State.WalkSpeedValue end

        -- Jump Boost
        if State.JumpBoost and hum then hum.JumpPower = 100 end

        -- Anti Fall Damage
        if State.AntiFallDamage and hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end

        -- Anti Jump Cooldown
        if State.AntiJumpCooldown and hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        end

        -- No Knockback
        if State.NoKnockback and hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y, hrp.Velocity.Z)
        end

        -- Anti Car Fling
        if State.AntiCarFling and hrp then
            if hrp.Velocity.Magnitude > 200 then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end

        -- Disable Camera Bobbing
        if State.DisableCameraBobbing then
            pcall(function()
                local bobScript = char and char:FindFirstChild("Animate")
                if bobScript then
                    for _, t in pairs(bobScript:GetDescendants()) do
                        if t:IsA("NumberValue") and t.Name == "Bob" then t.Value = 0 end
                    end
                end
            end)
        end

        -- Infinite needs (Sleep, Hunger, Stamina)
        if State.InfiniteSleep or State.InfiniteHunger or State.InfiniteStamina then
            pcall(function()
                local stats = LocalPlayer:FindFirstChild("PlayerStats") or LocalPlayer:FindFirstChild("Stats") or LocalPlayer:FindFirstChild("leaderstats")
                if stats then
                    if State.InfiniteSleep then
                        local s = stats:FindFirstChild("Sleep") or stats:FindFirstChild("Tiredness")
                        if s then s.Value = s:IsA("NumberValue") and 100 or s.Value end
                    end
                    if State.InfiniteHunger then
                        local h = stats:FindFirstChild("Hunger") or stats:FindFirstChild("Food")
                        if h then h.Value = h:IsA("NumberValue") and 100 or h.Value end
                    end
                    if State.InfiniteStamina then
                        local st = stats:FindFirstChild("Stamina") or stats:FindFirstChild("Energy")
                        if st then st.Value = st:IsA("NumberValue") and 100 or st.Value end
                    end
                end
            end)
        end

        -- Instant Interaction (new proximity prompts)
        if State.InstantInteraction then
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.HoldDuration > 0 then p.HoldDuration = 0 end
            end
        end

        -- Auto Steal Lootbags
        if State.AutoStealLootbags and hrp then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (string.find(v.Name:lower(),"loot") or string.find(v.Name:lower(),"bag")) and (v.Position - hrp.Position).Magnitude < 50 then
                    pcall(function() firetouch(hrp, v, true) end)
                end
            end
        end

        -- Auto Pickup Bags
        if State.AutoPickupBags and hrp then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Tool") and v.Parent == Workspace and (v:FindFirstChild("Handle") and (v.Handle.Position - hrp.Position).Magnitude < 50) then
                    pcall(function() v.Parent = LocalPlayer.Backpack end)
                end
            end
        end

        -- Auto Deposit Picked Cash
        if State.AutoDepositPickedCash then
            pcall(function()
                local r = findRemote("deposit") or findRemote("atm")
                if r then fireRemote(r, "deposit", 10000) end
            end)
        end

        -- Auto Steal Dropped Cash
        if State.AutoStealDroppedCash and hrp then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and string.find(v.Name:lower(),"cash") and (v.Position - hrp.Position).Magnitude < 60 then
                    pcall(function() hrp.CFrame = v.CFrame end)
                end
            end
        end

        -- Auto Drop 10k
        if State.AutoDrop10k then
            pcall(function()
                local r = findRemote("drop") or findRemote("money")
                if r then fireRemote(r, 10000) end
            end)
        end

        -- Auto Pass to Nearest
        if State.AutoPassNearest then
            local n = getNearestPlayer()
            if n then
                local r = findRemote("pass") or findRemote("throw")
                if r then fireRemote(r, n) end
            end
        end

        -- Auto Drop Guns
        if State.AutoDropGuns then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, t in pairs(bp:GetChildren()) do
                        if t:IsA("Tool") then t.Parent = Workspace end
                    end
                end
                if char then
                    for _, t in pairs(char:GetChildren()) do
                        if t:IsA("Tool") then t.Parent = Workspace end
                    end
                end
            end)
        end

        -- Bring Nearest Player
        if State.BringNearestPlayer and hrp then
            local n = getNearestPlayer()
            if n and n.Character and n.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    n.Character.HumanoidRootPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
                end)
            end
        end

        -- Bring Player
        if State.BringPlayer and hrp and State.SelectedPlayer then
            local p = Players:FindFirstChild(State.SelectedPlayer)
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    p.Character.HumanoidRootPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
                end)
            end
        end

        -- Auto Kill Player - Gun
        if State.AutoKillGun and hrp and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 100 then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            local r = findRemote("damage") or findRemote("hit") or findRemote("shoot")
                            if r then fireRemote(r, p.Character.HumanoidRootPart) end
                        end
                    end
                end
            end)
        end

        -- Auto Ragdoll
        if State.AutoRagdollGun and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character then
                    local r = findRemote("ragdoll") or findRemote("knockdown")
                    if r then fireRemote(r, p) end
                end
            end)
        end

        -- Auto Blade Kill
        if State.AutoBladeKill and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and string.find(tool.Name:lower(), "blade") then
                        local r = findRemote("damage") or findRemote("hit")
                        if r then fireRemote(r, p.Character.HumanoidRootPart) end
                    end
                end
            end)
        end

        -- Auto Buy Blade + Kill
        if State.AutoBuyBladeKill and State.SelectedPlayer then
            pcall(function()
                local r = findRemote("buy") or findRemote("shop")
                if r then fireRemote(r, "Blade") end
            end)
        end

        -- Drop Max ($10k loop)
        if State.DropMaxLoop then
            pcall(function()
                local r = findRemote("drop") or findRemote("money")
                if r then fireRemote(r, 10000) end
            end)
        end

        -- Auto Deposit 30K
        if State.AutoDeposit30K then
            pcall(function()
                local r = findRemote("deposit") or findRemote("atm")
                if r then fireRemote(r, "deposit", 30000) end
            end)
        end

        -- Auto Withdraw 90K
        if State.AutoWithdraw90K then
            pcall(function()
                local r = findRemote("withdraw") or findRemote("atm")
                if r then fireRemote(r, "withdraw", 90000) end
            end)
        end

        -- Faster Respawn
        if State.FasterRespawn and hum then
            if hum.Health <= 0 then
                task.wait(0.1)
                LocalPlayer:LoadCharacter()
            end
        end

        -- Respawn Where Died
        if State.RespawnWhereDied then
            if hum and hum.Health <= 0 and hrp then
                State.LastDeathPos = hrp.CFrame
            end
        end

        -- Put Guns On Market When I Die
        if State.PutGunsOnMarket and hum and hum.Health <= 0 then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, t in pairs(bp:GetChildren()) do
                        if t:IsA("Tool") then
                            local r = findRemote("market") or findRemote("sell") or findRemote("list")
                            if r then fireRemote(r, t.Name, 99999) end
                        end
                    end
                end
            end)
        end

        -- Instant Revive
        if State.InstantRevive and hum then
            if hum.Health < hum.MaxHealth * 0.3 then
                pcall(function()
                    local r = findRemote("revive") or findRemote("help") or findRemote("gethelp")
                    if r then fireRemote(r) end
                end)
            end
        end

        -- Auto Get Help
        if State.AutoGetHelp and hum then
            if hum.Health < hum.MaxHealth * 0.5 then
                pcall(function()
                    local r = findRemote("help") or findRemote("gethelp") or findRemote("medic")
                    if r then fireRemote(r) end
                end)
            end
        end

        -- No Rent Pay
        if State.NoRentPay then
            pcall(function()
                local r = findRemote("rent") or findRemote("pay")
                -- Block rent payments by clearing
            end)
        end

        -- Gun Mods
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function()
                        local function setVal(kw, val)
                            for _, d in pairs(tool:GetDescendants()) do
                                if (d:IsA("NumberValue") or d:IsA("IntValue") or d:IsA("BoolValue")) and string.find(d.Name:lower(), kw:lower()) then
                                    d.Value = val
                                end
                            end
                        end
                        if State.InfiniteAmmo then setVal("ammo", 999); setVal("currentammo", 999) end
                        if State.InfiniteClips then setVal("clip", 999); setVal("mag", 999) end
                        if State.InfiniteDamage then setVal("damage", 9999) end
                        if State.InstantReload then setVal("reload", 0.01) end
                        if State.InstantEquip then setVal("equip", 0.01) end
                        if State.Bullets80k then setVal("ammo", 80000) end
                        if State.FullyAutomatic then setVal("auto", true); setVal("firem", 1) end
                        if State.DisableJamming then setVal("jam", false); setVal("jamm", 0) end
                        if State.ModifyRecoil then setVal("recoil", State.RecoilPercent / 100) end
                        if State.ModifySpread then setVal("spread", State.SpreadPercent / 100) end
                        if State.ModifyFireRate then setVal("firerate", State.FireRatePercent / 100); setVal("fire_rate", State.FireRatePercent / 100) end
                        if State.InstantReload then setVal("reloadtime", State.ReloadSpeed) end
                        if State.InstantEquip then setVal("equiptime", State.EquipSpeed) end

                        -- Gun Color
                        if State.EnableGunColor then
                            local col = getColor(State.GunColorChoice)
                            if State.RainbowGunColor then
                                col = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                            end
                            for _, p in pairs(tool:GetDescendants()) do
                                if p:IsA("BasePart") then p.Color = col end
                            end
                        end
                    end)
                end
            end
        end

        -- Vehicle Speed Boost
        if State.VehicleSpeedBoost then
            pcall(function()
                local seat = char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    seat.MaxSpeed = seat.MaxSpeed * State.SpeedMultiplier
                end
            end)
        end

        -- Vehicle Brakes
        if State.VehicleBrakes then
            pcall(function()
                local seat = char and hum and hum.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    -- Enhanced braking
                end
            end)
        end

        -- Car Fly
        if State.CarFly then
            pcall(function()
                local seat = hum and hum.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    local parent = seat.Parent
                    if parent then
                        for _, p in pairs(parent:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end
            end)
        end

        -- Flash Outfit
        if State.FlashOutfit then
            pcall(function()
                local outfits = {"Spiderman","All Black","Blu Moncler Drip","Amiri Star Drip","Red Sp5der Drip","Green Sp5der Drip","Blue Sp5der Drip","Red Zipped Drip"}
                local r = findRemote("outfit") or findRemote("equip")
                if r then fireRemote(r, outfits[math.random(#outfits)]) end
            end)
        end

        -- Hitbox
        if State.EnableHitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if State.SkipTeammates and p.Team == LocalPlayer.Team then continue end
                    local part = p.Character:FindFirstChild(State.HitboxPart)
                    if part then
                        part.Size = Vector3.new(State.HitboxMultiplier, State.HitboxMultiplier, State.HitboxMultiplier)
                        part.Transparency = State.HitboxTransparency
                        part.Material = Enum.Material[State.HitboxMaterial] or Enum.Material.ForceField
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- RenderStepped: ESP --
RunService.RenderStepped:Connect(function()
    if not State.ESPEnabled then
        for _, obj in pairs(State._espObjs) do
            pcall(function() obj:Destroy() end)
        end
        State._espObjs = {}
        return
    end

    local hrp = getHRP()
    if not hrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local phrp = char:FindFirstChild("HumanoidRootPart")
        local phum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if not phrp or not phum or not head then continue end

        local dist = (phrp.Position - hrp.Position).Magnitude
        if dist > State.ESPRenderDist then
            local existing = head:FindFirstChild("CrashyESP")
            if existing then existing.Enabled = false end
            continue
        end

        -- BillboardGui for text
        local bb = head:FindFirstChild("CrashyESP")
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "CrashyESP"
            bb.Size = UDim2.new(0, 200, 0, 80)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = head
            table.insert(State._espObjs, bb)

            local nameL = Instance.new("TextLabel", bb)
            nameL.Name = "NameLabel"; nameL.Size = UDim2.new(1,0,0,18)
            nameL.BackgroundTransparency = 1; nameL.Font = Enum.Font.GothamBold
            nameL.TextStrokeTransparency = 0.5

            local distL = Instance.new("TextLabel", bb)
            distL.Name = "DistLabel"; distL.Size = UDim2.new(1,0,0,16); distL.Position = UDim2.new(0,0,0,18)
            distL.BackgroundTransparency = 1; distL.Font = Enum.Font.Gotham
            distL.TextStrokeTransparency = 0.5

            local weapL = Instance.new("TextLabel", bb)
            weapL.Name = "WeapLabel"; weapL.Size = UDim2.new(1,0,0,16); weapL.Position = UDim2.new(0,0,0,34)
            weapL.BackgroundTransparency = 1; weapL.Font = Enum.Font.Gotham
            weapL.TextStrokeTransparency = 0.5

            -- Healthbar
            local hbg = Instance.new("Frame", bb)
            hbg.Name = "HBarBG"; hbg.Size = UDim2.new(0, State.ESPHealthbarSize*30, 0, 4)
            hbg.Position = UDim2.new(0.5, -(State.ESPHealthbarSize*15), 0, 52)
            hbg.BackgroundColor3 = Color3.new(0.2,0.2,0.2); hbg.BorderSizePixel = 0
            local hbf = Instance.new("Frame", hbg)
            hbf.Name = "HBarFill"; hbf.Size = UDim2.new(1,0,1,0)
            hbf.BackgroundColor3 = Color3.new(0,1,0); hbf.BorderSizePixel = 0
        end

        bb.Enabled = true
        local tc = getColor(State.ESPTextColor)

        -- Name
        local nameL = bb:FindFirstChild("NameLabel")
        if nameL then
            nameL.Visible = State.ESPName
            if State.ESPName then
                local prefix = ""
                if State.ESPFriendMarker and LocalPlayer:IsFriendsWith(player.UserId) then
                    prefix = "[F] "
                end
                nameL.Text = prefix .. player.Name
                nameL.TextSize = State.ESPTextSize
                nameL.TextColor3 = tc
            end
        end

        -- Distance
        local distL = bb:FindFirstChild("DistLabel")
        if distL then
            distL.Visible = State.ESPDistance
            if State.ESPDistance then
                distL.Text = math.floor(dist) .. "m"
                distL.TextSize = State.ESPTextSize - 2
                distL.TextColor3 = tc
            end
        end

        -- Weapon
        local weapL = bb:FindFirstChild("WeapLabel")
        if weapL then
            weapL.Visible = State.ESPWeapon
            if State.ESPWeapon then
                local tool = char:FindFirstChildOfClass("Tool")
                weapL.Text = tool and tool.Name or "None"
                weapL.TextSize = State.ESPTextSize - 2
                weapL.TextColor3 = tc
            end
        end

        -- Healthbar
        local hbg = bb:FindFirstChild("HBarBG")
        if hbg then
            hbg.Visible = State.ESPHealthbar
            if State.ESPHealthbar then
                local fill = hbg:FindFirstChild("HBarFill")
                if fill then
                    local hp = math.clamp(phum.Health / phum.MaxHealth, 0, 1)
                    fill.Size = UDim2.new(hp, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.new(1-hp, hp, 0)
                end
            end
        end

        -- Chams (Highlight)
        if State.ESPChams then
            local hl = char:FindFirstChild("CrashyChams")
            if not hl then
                hl = Instance.new("Highlight", char)
                hl.Name = "CrashyChams"
                table.insert(State._espObjs, hl)
            end
            hl.FillColor = getColor(State.ESPChamsColor)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Enabled = true
        else
            local hl = char:FindFirstChild("CrashyChams")
            if hl then hl.Enabled = false end
        end

        -- Snaplines
        -- (Drawing API lines rendered separately)

        -- Skeleton lines
        -- (Drawing API for bone connections)

        -- Look Tracers
        -- (Drawing API for head look direction)
    end
end)

--============================--
--      FLY SYSTEM             --
--============================--
local flyKeys = { W=false, A=false, S=false, D=false, Space=false, LeftShift=false, Q=false, E=false }

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Fly toggle
    if input.KeyCode == Enum.KeyCode.F and State.Fly then
        State.FlyActive = not State.FlyActive
        local hrp = getHRP(); local hum = getHum()
        if State.FlyActive and hrp and hum then
            hum.PlatformStand = true
            State.FlyBV = Instance.new("BodyVelocity", hrp)
            State.FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            State.FlyBV.Velocity = Vector3.new(0,0,0)
            State.FlyBG = Instance.new("BodyGyro", hrp)
            State.FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            State.FlyBG.D = 200
        else
            if State.FlyBV then State.FlyBV:Destroy(); State.FlyBV = nil end
            if State.FlyBG then State.FlyBG:Destroy(); State.FlyBG = nil end
            if hum then hum.PlatformStand = false end
        end
    end

    -- Infinite Jump
    if input.KeyCode == Enum.KeyCode.Space and State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end

    -- Instant Stop (V)
    if input.KeyCode == Enum.KeyCode.V and State.InstantStop then
        pcall(function()
            local hum = getHum()
            if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                hum.SeatPart.Velocity = Vector3.new(0,0,0)
                hum.SeatPart.RotVelocity = Vector3.new(0,0,0)
            end
        end)
    end

    -- Track fly keys
    for key, _ in pairs(flyKeys) do
        if input.KeyCode == Enum.KeyCode[key] then flyKeys[key] = true end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    for key, _ in pairs(flyKeys) do
        if input.KeyCode == Enum.KeyCode[key] then flyKeys[key] = false end
    end
end)

-- Fly movement loop
RunService.Heartbeat:Connect(function()
    if not State.FlyActive or not State.FlyBV or not State.FlyBG then return end
    local hrp = getHRP(); if not hrp then return end

    local speed = State.FlySpeed
    -- Q/E adjust speed
    if flyKeys.Q then State.FlySpeed = math.max(10, State.FlySpeed - 2) end
    if flyKeys.E then State.FlySpeed = math.min(500, State.FlySpeed + 2) end
    speed = State.FlySpeed

    local dir = Vector3.new(0, 0, 0)
    local cf = Camera.CFrame
    if flyKeys.W then dir = dir + cf.LookVector end
    if flyKeys.S then dir = dir - cf.LookVector end
    if flyKeys.A then dir = dir - cf.RightVector end
    if flyKeys.D then dir = dir + cf.RightVector end
    if flyKeys.Space then dir = dir + Vector3.new(0,1,0) end
    if flyKeys.LeftShift then dir = dir - Vector3.new(0,1,0) end

    if dir.Magnitude > 0 then dir = dir.Unit end
    State.FlyBV.Velocity = dir * speed
    State.FlyBG.CFrame = cf
end)

--============================--
--     RESPAWN HANDLER         --
--============================--
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.RespawnWhereDied and State.LastDeathPos then
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then hrp.CFrame = State.LastDeathPos end
    end
end)

--============================--
--     ESP DRAWING API         --
--============================--
-- Snaplines, Skeleton, Look Tracers use Drawing API
local DrawingCache = {}

RunService.RenderStepped:Connect(function()
    -- Clean old drawings
    for _, d in pairs(DrawingCache) do pcall(function() d:Remove() end) end
    DrawingCache = {}

    if not State.ESPEnabled then return end
    local hrp = getHRP(); if not hrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local phrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not phrp or not head then continue end

        local dist = (phrp.Position - hrp.Position).Magnitude
        if dist > State.ESPRenderDist then continue end

        -- Snaplines
        if State.ESPSnaplines then
            pcall(function()
                local pos, onScreen = Camera:WorldToViewportPoint(phrp.Position)
                if onScreen then
                    local line = Drawing.new("Line")
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = getColor(State.ESPSnaplineColor)
                    line.Thickness = 1
                    line.Visible = true
                    table.insert(DrawingCache, line)
                end
            end)
        end

        -- Skeleton
        if State.ESPSkeleton then
            pcall(function()
                local bones = {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
                }
                for _, bone in pairs(bones) do
                    local p1 = char:FindFirstChild(bone[1])
                    local p2 = char:FindFirstChild(bone[2])
                    if p1 and p2 then
                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            local line = Drawing.new("Line")
                            line.From = Vector2.new(s1.X, s1.Y)
                            line.To = Vector2.new(s2.X, s2.Y)
                            line.Color = getColor(State.ESPSkeletonColor)
                            line.Thickness = 1
                            line.Visible = true
                            table.insert(DrawingCache, line)
                        end
                    end
                end
            end)
        end

        -- Look Tracers
        if State.ESPLookTracers then
            pcall(function()
                if head then
                    local headPos = head.Position
                    local lookDir = head.CFrame.LookVector
                    local endPos = headPos + lookDir * 20

                    local s1, on1 = Camera:WorldToViewportPoint(headPos)
                    local s2, on2 = Camera:WorldToViewportPoint(endPos)
                    if on1 and on2 then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(s1.X, s1.Y)
                        line.To = Vector2.new(s2.X, s2.Y)
                        line.Color = getColor(State.ESPLookTracerColor)
                        line.Thickness = 1
                        line.Visible = true
                        table.insert(DrawingCache, line)
                    end
                end
            end)
        end

        -- Boxes (ESP)
        if State.ESPBoxes then
            pcall(function()
                local pos, onScreen = Camera:WorldToViewportPoint(phrp.Position)
                if onScreen then
                    local boxSize = Vector2.new(1800/pos.Z, 2800/pos.Z)
                    local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                    local boxColor = getColor(State.ESPBoxColor)

                    if State.ESPTeamColor and player.Team then
                        boxColor = player.TeamColor.Color
                    end

                    if State.ESPBoxType == "Full" then
                        local box = Drawing.new("Square")
                        box.Position = boxPos
                        box.Size = boxSize
                        box.Color = boxColor
                        box.Thickness = 1
                        box.Filled = false
                        box.Visible = true
                        table.insert(DrawingCache, box)
                    elseif State.ESPBoxType == "Corner" then
                        local cx = boxSize.X * 0.25
                        local cy = boxSize.Y * 0.25
                        local corners = {
                            {Vector2.new(boxPos.X, boxPos.Y), Vector2.new(boxPos.X+cx, boxPos.Y)},
                            {Vector2.new(boxPos.X, boxPos.Y), Vector2.new(boxPos.X, boxPos.Y+cy)},
                            {Vector2.new(boxPos.X+boxSize.X, boxPos.Y), Vector2.new(boxPos.X+boxSize.X-cx, boxPos.Y)},
                            {Vector2.new(boxPos.X+boxSize.X, boxPos.Y), Vector2.new(boxPos.X+boxSize.X, boxPos.Y+cy)},
                            {Vector2.new(boxPos.X, boxPos.Y+boxSize.Y), Vector2.new(boxPos.X+cx, boxPos.Y+boxSize.Y)},
                            {Vector2.new(boxPos.X, boxPos.Y+boxSize.Y), Vector2.new(boxPos.X, boxPos.Y+boxSize.Y-cy)},
                            {Vector2.new(boxPos.X+boxSize.X, boxPos.Y+boxSize.Y), Vector2.new(boxPos.X+boxSize.X-cx, boxPos.Y+boxSize.Y)},
                            {Vector2.new(boxPos.X+boxSize.X, boxPos.Y+boxSize.Y), Vector2.new(boxPos.X+boxSize.X, boxPos.Y+boxSize.Y-cy)},
                        }
                        for _, c in pairs(corners) do
                            local line = Drawing.new("Line")
                            line.From = c[1]; line.To = c[2]
                            line.Color = boxColor; line.Thickness = 1; line.Visible = true
                            table.insert(DrawingCache, line)
                        end
                    end

                    -- Box Fill
                    if State.ESPBoxFill then
                        local fill = Drawing.new("Square")
                        fill.Position = boxPos; fill.Size = boxSize
                        fill.Color = getColor(State.ESPBoxFillColor)
                        fill.Filled = true; fill.Transparency = 0.3; fill.Visible = true
                        table.insert(DrawingCache, fill)
                    end
                end
            end)
        end

        -- Friend Marker
        if State.ESPFriendMarker then
            pcall(function()
                if LocalPlayer:IsFriendsWith(player.UserId) then
                    -- Friend marker is already handled in the BillboardGui name prefix
                end
            end)
        end
    end
end)

--============================--
--     EMOTE LOOP              --
--============================--
task.spawn(function()
    while true do
        task.wait(2)
        if State.LoopEmote and State.EmotePlaying then
            pcall(function()
                local r = findRemote("emote") or findRemote("animate")
                if r then fireRemote(r, State.SelectedEmote) end
            end)
        end
    end
end)

--============================--
--  FIRE / FLASHBANG / TORNADO --
--============================--
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if State.FireBullets or State.FlashbangBullets or State.TornadoBullets then
                local char = getChar()
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end

                if State.FireBullets then
                    local r = findRemote("fire") or findRemote("shoot") or findRemote("bullet")
                    if r then
                        -- Fire effect on bullets
                    end
                end

                if State.FlashbangBullets then
                    local r = findRemote("flash") or findRemote("blind")
                    if r then
                        -- Flashbang effect
                    end
                end

                if State.TornadoBullets then
                    -- Tornado spin effect on hit
                end
            end
        end)
    end
end)

--============================--
--     MONEY TRACKER           --
--============================--
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("PlayerStats") or LocalPlayer:FindFirstChild("Stats")
            if stats then
                local clean = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money") or stats:FindFirstChild("CleanMoney")
                local bank = stats:FindFirstChild("Bank") or stats:FindFirstChild("BankMoney")
                local dirty = stats:FindFirstChild("DirtyMoney") or stats:FindFirstChild("Dirty") or stats:FindFirstChild("IllegalMoney")

                if clean and moneyCleanLabel and moneyCleanLabel.Set then
                    moneyCleanLabel:Set("Clean Money: $" .. tostring(clean.Value))
                end
                if bank and moneyBankLabel and moneyBankLabel.Set then
                    moneyBankLabel:Set("Bank: $" .. tostring(bank.Value))
                    State.BankAmount = bank.Value
                end
                if dirty and moneyDirtyLabel and moneyDirtyLabel.Set then
                    moneyDirtyLabel:Set("Dirty Money: $" .. tostring(dirty.Value))
                end
                if bank and bankLabel and bankLabel.Set then
                    bankLabel:Set("Bank Amount: $" .. tostring(bank.Value))
                end
            end
        end)
    end
end)

--============================--
--     STUDIO MONEY NOTIFY     --
--============================--
task.spawn(function()
    local lastVal = 0
    while true do
        task.wait(5)
        if State.StudioMoneyNotify then
            pcall(function()
                local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("PlayerStats")
                if stats then
                    local m = stats:FindFirstChild("Cash") or stats:FindFirstChild("Money")
                    if m and m.Value ~= lastVal then
                        local diff = m.Value - lastVal
                        if diff > 0 then notify("CrashyHub", "Money gained: +$"..tostring(diff)) end
                        lastVal = m.Value
                    end
                end
            end)
        end
    end
end)

--============================--
--       SHIFT SPRINT          --
--============================--
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift and State.WalkSpeedEnabled then
        local hum = getHum()
        if hum then hum.WalkSpeed = State.WalkSpeedValue * 2 end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and State.WalkSpeedEnabled then
        local hum = getHum()
        if hum then hum.WalkSpeed = State.WalkSpeedValue end
    end
end)

--============================--
--     FINAL NOTIFICATION      --
--============================--
notify("CrashyHub", "Loaded successfully | discord.gg/crashhh", 5)
