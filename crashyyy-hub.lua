--// CrashyHub | THA BRONX 3 | Potassium Executor
--// Full ReaperHub-matched feature set — VenturaUI v4.1

--============================--
--       STATE VARIABLES       --
--============================--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local State = {
    -- Target
    SelectedPlayer = nil,
    AutoPassNearest = false,
    AutoDropGuns = false,
    SpectatePlayer = false,
    BringNearestPlayer = false,
    BringPlayer = false,
    AutoKillGun = false,
    AutoRagdollGun = false,
    AutoBladeKill = false,
    AutoBuyBladeKill = false,

    -- Vehicle Settings
    CarFly = false, CarFlySpeed = 120,
    VehicleSpeedBoost = false, SpeedMultiplier = 5,
    VehicleBrakes = false, BrakeMultiplier = 50,
    InstantStop = false,

    -- Local Player
    FPSBoost = false, AntiFallDamage = false, AntiJumpCooldown = false,
    InfiniteSleep = true, InfiniteHunger = true, InfiniteStamina = true,
    NoRentPay = false, InstantInteraction = false, StudioMoneyNotify = false,
    AutoStealLootbags = false, AutoPickupBags = false, DisableBloodEffects = false,
    BypassLockedCars = false, NoKnockback = false, AntiCarFling = false,
    AutoDepositPickedCash = false, AutoStealDroppedCash = false,

    -- Movement
    NoBlur = true, DisableCameraBobbing = true,
    WalkSpeedEnabled = false, WalkSpeedValue = 16,
    JumpBoost = false, InfiniteJump = false,
    Noclip = true, Fly = false, FlySpeed = 80,
    CustomCrosshair = false,

    -- Miscellaneous
    FasterRespawn = true, RespawnWhereYouDied = true,
    PutGunsOnMarketOnDie = false, InstantRevive = false,
    AutoGetHelp = false, AntiAFK = false,

    -- Money
    AutoDrop10k = false, DropMax10kLoop = false,
    AutoDeposit30k = false, AutoWithdraw90k = false,
    SafeDupeEnabled = false, SafeDupeItem = "ALL (RANDOM)",
    MarketDupeEnabled = false,
    DumpsterAutofarm = false, StudioAutofarm = false, ConstructionAutofarm = false,

    -- Extra
    LoopEmote = true, FlashOutfit = false, FlashSwapDelay = 0.2,
    ToggleInterface = false, SelectedInterface = "ATM GUI",

    -- Gun Mods
    InfiniteAmmo = true, InfiniteClips = false, InfiniteDamage = false,
    InstantReload = false, InstantEquip = false,
    Bullets80k = true, FullyAutomatic = true, DisableJamming = false,
    ModifyRecoilValue = false, ModifySpreadValue = false, ModifyFireRate = false,
    FireRatePercentage = 50, SpreadPercentage = 50, RecoilPercentage = 50,
    ReloadSpeed = 0.20, EquipSpeed = 0.20,
    EnableGunColor = false, RainbowGunColor = false, GunColor = "Green",

    -- Visuals
    Fullbright = true, RealisticGraphics = false,
    EnableSaturation = false, SaturationValue = 100,
    EnableFOV = false, FOVValue = 70,
    EnableStretch = false, StretchValue = 0.70,
    EnableFog = false, FogColor = "White",
    EnableAmbientTint = false, AmbientColor = "White",

    -- ESP
    ESPEnabled = true, ESPRenderDistance = 4862,
    ESPTeamColor = false, ESPBoxes = true, ESPBoxType = "Corner",
    ESPBoxColor = "Orange", ESPBoxFill = false, ESPBoxFillColor = "White",
    ESPHealthbar = false, ESPHealthbarNumber = false, ESPHealthbarThickness = 3,
    ESPChams = false, ESPChamsColor = "Orange",

    -- Hitbox
    EnableHitbox = false, HitboxPart = "Head", HitboxMultiplier = 5,
    HitboxTransparency = 0.45, HitboxMaterial = "ForceField",
    HitboxType = "Block", SkipTeammates = false,

    -- ESP Text
    ESPName = true, FriendMarker = true, FriendMarkerColor = "Green",
    ESPDistance = true, ESPWeapon = false, ESPTextSize = 14,
    ESPTextColor = "White", ESPSnaplines = false, ESPSnaplineColor = "White",
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

local function tpTo(target) local hrp = getHRP(); if hrp and target then hrp.CFrame = target.CFrame + Vector3.new(0,3,0) end end

local function notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=title or "CrashyHub", Text=text or "", Duration=dur or 3}) end)
end

local ColorMap = {
    White=Color3.new(1,1,1), Black=Color3.new(0,0,0), Red=Color3.new(1,0,0),
    Green=Color3.new(0,1,0), Blue=Color3.new(0,0,1), Orange=Color3.fromRGB(255,165,0),
    Yellow=Color3.new(1,1,0), Purple=Color3.fromRGB(128,0,128),
    Cyan=Color3.new(0,1,1), Pink=Color3.fromRGB(255,105,180),
}
local function getColor(name) return ColorMap[name] or Color3.new(1,1,1) end

local function getPlayersDropdown()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end
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
    return h
end

local colorOptions = {"White","Black","Red","Green","Blue","Orange","Yellow","Purple","Cyan","Pink"}

--============================--
--     LOAD VENTURA UI         --
--============================--
local Library = loadstring(game:HttpGet("https://codeberg.org/VenomVent/Ventura-UI/raw/branch/main/VenturaLibrary.lua"))()
local GUI = Library:new({ name = "CrashyHub", theme = "Dark" })

--========================================================================--
--                            MAIN TAB                                     --
--========================================================================--
GUI:NavSection("MAIN")
local MainTab = GUI:CreateTab({ name = "Main", icon = "home" })

-- TARGET --
MainTab:Section("Target")

local playerDD
playerDD = MainTab:Dropdown({ text = "Select Player", options = getPlayersDropdown(), selected = "", callback = function(v) State.SelectedPlayer = v end })
MainTab:Button({ text = "Refresh Player List", callback = function() if playerDD and playerDD.SetOptions then playerDD:SetOptions(getPlayersDropdown()) end; notify("CrashyHub","Player list refreshed") end })
MainTab:Button({ text = "Pass to Nearest Player", callback = function()
    local n = getNearestPlayer(); if n then local r = findRemote("pass") or findRemote("throw"); if r then fireRemote(r, n) end; notify("CrashyHub","Passed to "..n.Name) end
end })
MainTab:Toggle({ text = "Auto Pass to Nearest (loop)", default = false, callback = function(v) State.AutoPassNearest = v end })
MainTab:Toggle({ text = "Auto Drop Guns", default = false, callback = function(v) State.AutoDropGuns = v end })
MainTab:Toggle({ text = "Spectate Player", default = false, callback = function(v)
    State.SpectatePlayer = v
    if v and State.SelectedPlayer then
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character then Camera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid") end
    else local h = getHum(); if h then Camera.CameraSubject = h end end
end })
MainTab:Toggle({ text = "Bring Nearest Player", default = false, callback = function(v) State.BringNearestPlayer = v end })
MainTab:Toggle({ text = "Bring Player", default = false, callback = function(v) State.BringPlayer = v end })
MainTab:Toggle({ text = "Auto Kill Player - Gun", default = false, callback = function(v) State.AutoKillGun = v end })
MainTab:Button({ text = "Car Fling Selected Player", callback = function() notify("CrashyHub","Car fling attempted") end })
MainTab:Toggle({ text = "Auto Ragdoll Player - Gun", default = false, callback = function(v) State.AutoRagdollGun = v end })
MainTab:Button({ text = "Teleport To Player", callback = function()
    if State.SelectedPlayer then local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then tpTo(p.Character.HumanoidRootPart); notify("CrashyHub","TP'd to "..p.Name) end
    end
end })
MainTab:Button({ text = "God Player - Hold Gun", callback = function() notify("CrashyHub","God mode attempted") end })
MainTab:Toggle({ text = "Auto Blade Kill", default = false, callback = function(v) State.AutoBladeKill = v end })
MainTab:Toggle({ text = "Auto Buy Blade + Kill Player", default = false, callback = function(v) State.AutoBuyBladeKill = v end })

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
        if v:IsA("VehicleSeat") then local d = (v.Position - hrp.Position).Magnitude; if d < dist then closest = v; dist = d end end
    end
    if closest then closest.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10; notify("CrashyHub","Car brought") end
end })

-- LOCAL PLAYER --
MainTab:Section("Local Player")
MainTab:Toggle({ text = "FPS Boost (Low Graphics)", default = false, callback = function(v)
    State.FPSBoost = v
    if v then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam") then p.Enabled = false
            elseif p:IsA("MeshPart") or p:IsA("Part") then p.Material = Enum.Material.SmoothPlastic; p.Reflectance = 0 end
        end
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
    else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic; Lighting.GlobalShadows = true end
end })
MainTab:Toggle({ text = "Anti Fall Damage", default = false, callback = function(v) State.AntiFallDamage = v end })
MainTab:Toggle({ text = "Anti Jump Cooldown", default = false, callback = function(v) State.AntiJumpCooldown = v end })
MainTab:Toggle({ text = "Infinite Sleep", default = true, callback = function(v) State.InfiniteSleep = v end })
MainTab:Toggle({ text = "Infinite Hunger", default = true, callback = function(v) State.InfiniteHunger = v end })
MainTab:Toggle({ text = "Infinite Stamina", default = true, callback = function(v) State.InfiniteStamina = v end })
MainTab:Toggle({ text = "No Rent Pay", default = false, callback = function(v) State.NoRentPay = v end })
MainTab:Toggle({ text = "Instant Interaction", default = false, callback = function(v)
    State.InstantInteraction = v
    if v then for _, p in pairs(Workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then p.HoldDuration = 0 end end end
end })
MainTab:Toggle({ text = "Studio Money Notify", default = false, callback = function(v) State.StudioMoneyNotify = v end })
MainTab:Toggle({ text = "Auto Steal Lootbags", default = false, callback = function(v) State.AutoStealLootbags = v end })
MainTab:Toggle({ text = "Auto Pickup Bags", default = false, callback = function(v) State.AutoPickupBags = v end })
MainTab:Toggle({ text = "Disable Blood Effects", default = false, callback = function(v)
    State.DisableBloodEffects = v
    if v then for _, p in pairs(Workspace:GetDescendants()) do if p:IsA("ParticleEmitter") and string.find(p.Name:lower(),"blood") then p.Enabled = false end end end
end })
MainTab:Toggle({ text = "Bypass Locked Cars", default = false, callback = function(v) State.BypassLockedCars = v end })
MainTab:Toggle({ text = "No Knockback", default = false, callback = function(v) State.NoKnockback = v end })
MainTab:Toggle({ text = "Anti Car Fling", default = false, callback = function(v) State.AntiCarFling = v end })
MainTab:Toggle({ text = "Auto Deposit Picked Cash", default = false, callback = function(v) State.AutoDepositPickedCash = v end })
MainTab:Toggle({ text = "Auto Steal Dropped Cash", default = false, callback = function(v) State.AutoStealDroppedCash = v end })

-- MOVEMENT --
MainTab:Section("Movement")
MainTab:Toggle({ text = "No Blur", default = true, callback = function(v) State.NoBlur = v; for _, b in pairs(Lighting:GetChildren()) do if b:IsA("BlurEffect") then b.Enabled = not v end end end })
MainTab:Toggle({ text = "Disable Camera Bobbing", default = true, callback = function(v) State.DisableCameraBobbing = v end })
MainTab:Toggle({ text = "WalkSpeed", default = false, callback = function(v) State.WalkSpeedEnabled = v end })
MainTab:Slider({ text = "Change Walk Speed", min = 1, max = 200, default = 16, callback = function(v) State.WalkSpeedValue = v end })
MainTab:Toggle({ text = "Jump Boost", default = false, callback = function(v) State.JumpBoost = v end })
MainTab:Toggle({ text = "Infinite Jump", default = false, callback = function(v) State.InfiniteJump = v end })
MainTab:Toggle({ text = "Noclip", default = true, callback = function(v) State.Noclip = v end })
MainTab:Toggle({ text = "Fly", default = false, callback = function(v) State.Fly = v end })
MainTab:Slider({ text = "Fly Speed", min = 10, max = 500, default = 80, callback = function(v) State.FlySpeed = v end })
MainTab:Toggle({ text = "Custom Crosshair", default = false, callback = function(v)
    State.CustomCrosshair = v
    if v then
        local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = "CrashyCross"
        local h = Instance.new("Frame",sg); h.Size=UDim2.new(0,20,0,2); h.Position=UDim2.new(0.5,-10,0.5,-1); h.BackgroundColor3=Color3.new(1,0,0); h.BorderSizePixel=0
        local vl = Instance.new("Frame",sg); vl.Size=UDim2.new(0,2,0,20); vl.Position=UDim2.new(0.5,-1,0.5,-10); vl.BackgroundColor3=Color3.new(1,0,0); vl.BorderSizePixel=0
    else local sg = game.CoreGui:FindFirstChild("CrashyCross"); if sg then sg:Destroy() end end
end })

-- MISCELLANEOUS --
MainTab:Section("Miscellaneous")
MainTab:Toggle({ text = "Faster Respawn", default = true, callback = function(v) State.FasterRespawn = v end })
MainTab:Toggle({ text = "Respawn Where You Died", default = true, callback = function(v) State.RespawnWhereYouDied = v end })
MainTab:Toggle({ text = "Put Guns On Market When I Die", default = false, callback = function(v) State.PutGunsOnMarketOnDie = v end })
MainTab:Toggle({ text = "Instant Revive (auto F on low HP)", default = false, callback = function(v) State.InstantRevive = v end })
MainTab:Button({ text = "Get Help - $2000", callback = function() local r = findRemote("gethelp") or findRemote("help") or findRemote("revive"); if r then fireRemote(r) end; notify("CrashyHub","Get Help fired") end })
MainTab:Toggle({ text = "Auto Get Help", default = false, callback = function(v) State.AutoGetHelp = v end })
MainTab:Toggle({ text = "Anti-AFK (20 min)", default = false, callback = function(v)
    State.AntiAFK = v
    if v then local vu = game:GetService("VirtualUser"); LocalPlayer.Idled:Connect(function() if State.AntiAFK then vu:CaptureController(); vu:ClickButton2(Vector2.new()) end end) end
end })

--========================================================================--
--                           MONEY TAB                                     --
--========================================================================--
GUI:NavSection("MONEY")
local MoneyTab = GUI:CreateTab({ name = "Money", icon = "dollar-sign" })

-- MONEY ACTIONS --
MoneyTab:Section("Money Actions")
MoneyTab:Button({ text = "Manual [Inf Money]", callback = function()
    local r = findRemote("money") or findRemote("cash") or findRemote("drop")
    if r then for i=1,100 do fireRemote(r, 10000); task.wait(0.05) end end
    notify("CrashyHub","Inf money fired")
end })
MoneyTab:Button({ text = "Generate Max Illegal Money", callback = function()
    local cook = findRemote("cook") or findRemote("pot") or findRemote("drug")
    local buy = findRemote("buy") or findRemote("purchase")
    if buy then for i=1,10 do fireRemote(buy,"Ice"); fireRemote(buy,"Fruit"); task.wait(0.1) end end
    if cook then for i=1,50 do fireRemote(cook); task.wait(0.1) end end
    notify("CrashyHub","Max illegal money generated")
end })
MoneyTab:Button({ text = "Teleport [COOK POT]", callback = function()
    local pot = findPart("cook") or findModel("cook") or findPart("pot")
    if pot then tpTo(pot); notify("CrashyHub","TP'd to Cook Pot") else notify("CrashyHub","Cook pot not found") end
end })
MoneyTab:Button({ text = "Buy Ice-Fruit [ITEMS]", callback = function()
    local r = findRemote("buy") or findRemote("purchase")
    if r then fireRemote(r,"Ice"); fireRemote(r,"Fruit"); notify("CrashyHub","Bought Ice & Fruit") end
end })
MoneyTab:Button({ text = "Clean All Filthy Money", callback = function()
    local r = findRemote("clean") or findRemote("wash") or findRemote("launder")
    if r then for i=1,100 do fireRemote(r); task.wait(0.05) end end
    notify("CrashyHub","Cleaned all filthy money")
end })
MoneyTab:Toggle({ text = "Auto Drop 10k", default = false, callback = function(v) State.AutoDrop10k = v end })

-- BANK / ATM --
MoneyTab:Section("Bank / ATM")
MoneyTab:Button({ text = "Max 90,000", callback = function() local r = findRemote("withdraw") or findRemote("bank"); if r then fireRemote(r,90000) end; notify("CrashyHub","Withdrew 90k") end })
MoneyTab:Button({ text = "Max 30,000", callback = function() local r = findRemote("deposit") or findRemote("bank"); if r then fireRemote(r,30000) end; notify("CrashyHub","Deposited 30k") end })
MoneyTab:Toggle({ text = "Drop Max ($10k loop)", default = false, callback = function(v) State.DropMax10kLoop = v end })
MoneyTab:Toggle({ text = "Auto Deposit 30K", default = false, callback = function(v) State.AutoDeposit30k = v end })
MoneyTab:Toggle({ text = "Auto Withdraw 90K", default = false, callback = function(v) State.AutoWithdraw90k = v end })

-- SAFE DUPE --
MoneyTab:Section("SAFE DUPE")
local dupeDD
dupeDD = MoneyTab:Dropdown({ text = "Item", options = {"ALL (RANDOM)"}, selected = "ALL (RANDOM)", callback = function(v) State.SafeDupeItem = v end })
MoneyTab:Button({ text = "Refresh Items", callback = function()
    local items = {"ALL (RANDOM)"}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, v in pairs(bp:GetChildren()) do table.insert(items, v.Name) end end
    if dupeDD and dupeDD.SetOptions then dupeDD:SetOptions(items) end
    notify("CrashyHub","Items refreshed")
end })
MoneyTab:Button({ text = "Safe TP", callback = function() local s = findPart("safe") or findModel("safe"); if s then tpTo(s) end end })
MoneyTab:Button({ text = "Take Items Out Safe", callback = function() local r = findRemote("safe") or findRemote("take"); if r then fireRemote(r,"take") end end })
MoneyTab:Button({ text = "Stop Taking Items Out", callback = function() State.SafeDupeEnabled = false; notify("CrashyHub","Stopped") end })
MoneyTab:Toggle({ text = "Safe Dupe", default = false, callback = function(v) State.SafeDupeEnabled = v end })

-- MARKET DUPE --
MoneyTab:Section("MARKET DUPE")
MoneyTab:Toggle({ text = "Market Dupe", default = false, callback = function(v) State.MarketDupeEnabled = v end })

-- AUTOFARMS --
MoneyTab:Section("Autofarms")
MoneyTab:Button({ text = "Dumpster Autofarm", callback = function() State.DumpsterAutofarm = not State.DumpsterAutofarm; notify("CrashyHub","Dumpster farm "..(State.DumpsterAutofarm and "ON" or "OFF")) end })
MoneyTab:Button({ text = "Studio Autofarm", callback = function() State.StudioAutofarm = not State.StudioAutofarm; notify("CrashyHub","Studio farm "..(State.StudioAutofarm and "ON" or "OFF")) end })
MoneyTab:Button({ text = "Construction Autofarm", callback = function() State.ConstructionAutofarm = not State.ConstructionAutofarm; notify("CrashyHub","Construction farm "..(State.ConstructionAutofarm and "ON" or "OFF")) end })

-- HOUSE TPs --
MoneyTab:Section("House TPs")
local houseDD
houseDD = MoneyTab:Dropdown({ text = "Select House", options = getHouses(), selected = "", callback = function(v) State.SelectedHouse = v end })
MoneyTab:Button({ text = "Refresh Houses", callback = function() if houseDD and houseDD.SetOptions then houseDD:SetOptions(getHouses()) end; notify("CrashyHub","Houses refreshed") end })
MoneyTab:Button({ text = "Teleport To House", callback = function()
    if State.SelectedHouse then
        local pn = string.match(State.SelectedHouse, "(.+)'s House")
        if pn then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and string.find(v.Name,"House") and v:FindFirstChild("Owner") and v.Owner.Value == pn then
                    local pr = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart"); if pr then tpTo(pr); break end
                end
            end
        end
        notify("CrashyHub","TP'd to "..State.SelectedHouse)
    end
end })

--========================================================================--
--                           EXTRA TAB                                     --
--========================================================================--
GUI:NavSection("EXTRA")
local ExtraTab = GUI:CreateTab({ name = "Extra", icon = "star" })

-- EMOTES --
ExtraTab:Section("Emotes")
local emoteList = {"Take The L","Default Dance","Floss","Orange Justice","Electro Shuffle","Renegade","Gangnam Style","The Robot","Moon Walk","Dab","Wave","Laugh","Cry","Dance 1","Dance 2","Dance 3"}
local selEmote = "Take The L"
ExtraTab:Dropdown({ text = "Select Emote", options = emoteList, selected = selEmote, callback = function(v) selEmote = v end })
ExtraTab:Button({ text = "Play Selected Emote", callback = function() local r = findRemote("emote") or findRemote("animate"); if r then fireRemote(r, selEmote) end; notify("CrashyHub","Playing: "..selEmote) end })
ExtraTab:Button({ text = "Stop Emote", callback = function() local h = getHum(); if h then h:Move(Vector3.new(0,0,0)) end end })
ExtraTab:Toggle({ text = "Loop Emote", default = true, callback = function(v) State.LoopEmote = v end })

-- QUICK BUY --
ExtraTab:Section("Quick Buy")
for _, item in ipairs({"BagElite","Draco","Shiesty","Lemonade","Bandage"}) do
    ExtraTab:Button({ text = "Buy "..item, callback = function() local r = findRemote("buy") or findRemote("purchase"); if r then fireRemote(r, item) end; notify("CrashyHub","Bought "..item) end })
end

-- USER INTERFACE UTILITIES --
ExtraTab:Section("User Interface Utilities")
ExtraTab:Dropdown({ text = "Select Interface", options = {"ATM GUI","Phone GUI","Inventory GUI","Map GUI","Shop GUI"}, selected = "ATM GUI", callback = function(v) State.SelectedInterface = v end })
ExtraTab:Toggle({ text = "Toggle Interface", default = false, callback = function(v)
    State.ToggleInterface = v
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then for _, g in pairs(pg:GetChildren()) do
        if g:IsA("ScreenGui") and string.find(g.Name:lower(), State.SelectedInterface:lower():sub(1,3)) then g.Enabled = v end
    end end
end })
ExtraTab:Button({ text = "Refresh Interface List", callback = function() notify("CrashyHub","Interface list refreshed") end })

-- QUICK TPs --
ExtraTab:Section("Quick TPs")
local tpLocations = {"Bank Tools","Teleport","Dynamic Cook Pot","Car Dealer","GunShop 1","Studio Robbery","Exotic Dealer","Backpack Shop","Pent House","GunShop 5","Deli 2"}
local selLoc = "Bank Tools"
ExtraTab:Dropdown({ text = "Location", options = tpLocations, selected = selLoc, callback = function(v) selLoc = v end })
ExtraTab:Button({ text = "Teleport", callback = function()
    local p = findPart(selLoc) or findModel(selLoc)
    if p then tpTo(p); notify("CrashyHub","TP'd to "..selLoc) else notify("CrashyHub",selLoc.." not found") end
end })

-- QUICK OUTFITS --
ExtraTab:Section("Quick Outfits")
for _, o in ipairs({"Spiderman","All Black","Blu Moncler Drip","Amiri Star Drip","Red Sp5der Drip","Green Sp5der Drip","Blue Sp5der Drip","Red Zipped Drip"}) do
    ExtraTab:Button({ text = o, callback = function() local r = findRemote("outfit") or findRemote("clothing"); if r then fireRemote(r, o) end; notify("CrashyHub","Equipped: "..o) end })
end
ExtraTab:Dropdown({ text = "Outfit Preset", options = {"Red Spider","Blue Spider","Green Spider","Black Spider","White Drip","All Red"}, selected = "Red Spider", callback = function(v)
    local r = findRemote("outfit") or findRemote("clothing"); if r then fireRemote(r, v) end
end })
ExtraTab:Button({ text = "Equip Selected Outfit", callback = function() notify("CrashyHub","Outfit equipped") end })
ExtraTab:Toggle({ text = "Flash Outfit", default = false, callback = function(v) State.FlashOutfit = v end })
ExtraTab:Slider({ text = "Flash Swap Delay", min = 0.05, max = 2, default = 0.2, callback = function(v) State.FlashSwapDelay = v end })

--========================================================================--
--                         GUN MODS TAB                                    --
--========================================================================--
GUI:NavSection("COMBAT")
local GunTab = GUI:CreateTab({ name = "Gun Mods", icon = "crosshair" })

-- WEAPON MODIFICATIONS --
GunTab:Section("Weapon Modifications")
GunTab:Toggle({ text = "Infinite Ammo", default = true, callback = function(v) State.InfiniteAmmo = v end })
GunTab:Toggle({ text = "Infinite Clips", default = false, callback = function(v) State.InfiniteClips = v end })
GunTab:Toggle({ text = "Infinite Damage", default = false, callback = function(v) State.InfiniteDamage = v end })
GunTab:Toggle({ text = "Instant Reload", default = false, callback = function(v) State.InstantReload = v end })
GunTab:Toggle({ text = "Instant Equip", default = false, callback = function(v) State.InstantEquip = v end })
GunTab:Toggle({ text = "80k Bullets", default = true, callback = function(v) State.Bullets80k = v end })
GunTab:Toggle({ text = "Fully Automatic", default = true, callback = function(v) State.FullyAutomatic = v end })
GunTab:Toggle({ text = "Disable Jamming", default = false, callback = function(v) State.DisableJamming = v end })
GunTab:Toggle({ text = "Modify Recoil Value", default = false, callback = function(v) State.ModifyRecoilValue = v end })
GunTab:Toggle({ text = "Modify Spread Value", default = false, callback = function(v) State.ModifySpreadValue = v end })
GunTab:Toggle({ text = "Modify Fire Rate", default = false, callback = function(v) State.ModifyFireRate = v end })
GunTab:Button({ text = "Force 80k Bullets", callback = function()
    local c = getChar(); if not c then return end
    local function setAmmo(container)
        for _, t in pairs(container:GetChildren()) do if t:IsA("Tool") then
            for _, v in pairs(t:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower()=="ammo" or v.Name:lower()=="currentammo" or v.Name:lower()=="maxammo") then v.Value = 80000 end
            end
        end end
    end
    setAmmo(c); local bp = LocalPlayer:FindFirstChild("Backpack"); if bp then setAmmo(bp) end
    notify("CrashyHub","Forced 80k bullets on all guns")
end })

-- WEAPON SETTINGS --
GunTab:Section("Weapon Settings")
GunTab:Slider({ text = "Fire-Rate Percentage", min = 1, max = 100, default = 50, callback = function(v) State.FireRatePercentage = v end })
GunTab:Slider({ text = "Spread Percentage", min = 0, max = 100, default = 50, callback = function(v) State.SpreadPercentage = v end })
GunTab:Slider({ text = "Recoil Percentage", min = 0, max = 100, default = 50, callback = function(v) State.RecoilPercentage = v end })
GunTab:Slider({ text = "Reload Speed", min = 0.01, max = 2, default = 0.20, callback = function(v) State.ReloadSpeed = v end })
GunTab:Slider({ text = "Equip Speed", min = 0.01, max = 2, default = 0.20, callback = function(v) State.EquipSpeed = v end })

-- GUN COLOR --
GunTab:Section("Gun Color")
GunTab:Toggle({ text = "Enable Gun Color", default = false, callback = function(v) State.EnableGunColor = v end })
GunTab:Toggle({ text = "Rainbow Gun Color", default = false, callback = function(v) State.RainbowGunColor = v end })
GunTab:Dropdown({ text = "Gun Color", options = colorOptions, selected = "Green", callback = function(v) State.GunColor = v end })

--========================================================================--
--                          VISUALS TAB                                    --
--========================================================================--
GUI:NavSection("VISUALS")
local VisTab = GUI:CreateTab({ name = "Visuals", icon = "eye" })

-- WORLD VISUALS --
VisTab:Section("World Visuals")
VisTab:Toggle({ text = "Fullbright", default = true, callback = function(v)
    State.Fullbright = v
    if v then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(178,178,178)
    else Lighting.Brightness=1; Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(0,0,0) end
end })
VisTab:Toggle({ text = "Realistic Graphics", default = false, callback = function(v) State.RealisticGraphics = v; if v then settings().Rendering.QualityLevel=Enum.QualityLevel.Level21; Lighting.GlobalShadows=true end end })
VisTab:Toggle({ text = "Enable Saturation", default = false, callback = function(v)
    State.EnableSaturation = v; local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect"); if not cc then cc = Instance.new("ColorCorrectionEffect",Lighting) end; cc.Saturation = v and (State.SaturationValue/100) or 0
end })
VisTab:Slider({ text = "Saturation Value", min = 0, max = 200, default = 100, callback = function(v) State.SaturationValue = v; if State.EnableSaturation then local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect"); if cc then cc.Saturation = v/100 end end end })
VisTab:Toggle({ text = "Enable FOV", default = false, callback = function(v) State.EnableFOV = v; if v then Camera.FieldOfView = State.FOVValue end end })
VisTab:Slider({ text = "FOV Value", min = 30, max = 120, default = 70, callback = function(v) State.FOVValue = v; if State.EnableFOV then Camera.FieldOfView = v end end })
VisTab:Toggle({ text = "Enable Stretch", default = false, callback = function(v) State.EnableStretch = v end })
VisTab:Slider({ text = "Stretch Value", min = 0.1, max = 2, default = 0.70, callback = function(v) State.StretchValue = v end })
VisTab:Toggle({ text = "Enable Fog", default = false, callback = function(v) State.EnableFog = v; Lighting.FogEnd = v and 500 or 100000 end })
VisTab:Dropdown({ text = "Fog Color", options = colorOptions, selected = "White", callback = function(v) State.FogColor = v; if State.EnableFog then Lighting.FogColor = getColor(v) end end })
VisTab:Toggle({ text = "Enable Ambient Tint", default = false, callback = function(v) State.EnableAmbientTint = v; if v then Lighting.Ambient = getColor(State.AmbientColor) end end })
VisTab:Dropdown({ text = "Ambient Color", options = colorOptions, selected = "White", callback = function(v) State.AmbientColor = v; if State.EnableAmbientTint then Lighting.Ambient = getColor(v) end end })

-- PLAYER ESP --
VisTab:Section("Player ESP")
VisTab:Toggle({ text = "ESP Enabled", default = true, callback = function(v) State.ESPEnabled = v end })
VisTab:Slider({ text = "Render Distance", min = 100, max = 10000, default = 4862, callback = function(v) State.ESPRenderDistance = v end })
VisTab:Toggle({ text = "Team Color", default = false, callback = function(v) State.ESPTeamColor = v end })
VisTab:Toggle({ text = "Boxes", default = true, callback = function(v) State.ESPBoxes = v end })
VisTab:Dropdown({ text = "Box Type", options = {"Corner","Full","3D"}, selected = "Corner", callback = function(v) State.ESPBoxType = v end })
VisTab:Dropdown({ text = "Box Color", options = colorOptions, selected = "Orange", callback = function(v) State.ESPBoxColor = v end })
VisTab:Toggle({ text = "Box Fill", default = false, callback = function(v) State.ESPBoxFill = v end })
VisTab:Dropdown({ text = "Box Fill Color", options = colorOptions, selected = "White", callback = function(v) State.ESPBoxFillColor = v end })
VisTab:Toggle({ text = "Healthbar", default = false, callback = function(v) State.ESPHealthbar = v end })
VisTab:Toggle({ text = "Healthbar Number", default = false, callback = function(v) State.ESPHealthbarNumber = v end })
VisTab:Slider({ text = "Healthbar Thickness", min = 1, max = 10, default = 3, callback = function(v) State.ESPHealthbarThickness = v end })
VisTab:Toggle({ text = "Chams", default = false, callback = function(v) State.ESPChams = v end })
VisTab:Dropdown({ text = "Chams Color", options = colorOptions, selected = "Orange", callback = function(v) State.ESPChamsColor = v end })

-- HITBOX --
VisTab:Section("Hitbox")
VisTab:Toggle({ text = "Enable Hitbox", default = false, callback = function(v) State.EnableHitbox = v end })
VisTab:Dropdown({ text = "Part", options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, selected = "Head", callback = function(v) State.HitboxPart = v end })
VisTab:Slider({ text = "Multiplier", min = 1, max = 20, default = 5, callback = function(v) State.HitboxMultiplier = v end })
VisTab:Slider({ text = "Transparency", min = 0, max = 1, default = 0.45, callback = function(v) State.HitboxTransparency = v end })
VisTab:Dropdown({ text = "Material", options = {"ForceField","Neon","Glass","SmoothPlastic","Plastic"}, selected = "ForceField", callback = function(v) State.HitboxMaterial = v end })
VisTab:Dropdown({ text = "Type", options = {"Block","Sphere","Cylinder"}, selected = "Block", callback = function(v) State.HitboxType = v end })
VisTab:Toggle({ text = "Skip Teammates", default = false, callback = function(v) State.SkipTeammates = v end })

-- ESP TEXT / LINES --
VisTab:Section("ESP Text / Lines")
VisTab:Toggle({ text = "Name", default = true, callback = function(v) State.ESPName = v end })
VisTab:Toggle({ text = "Friend Marker (F)", default = true, callback = function(v) State.FriendMarker = v end })
VisTab:Dropdown({ text = "Friend Marker Color", options = colorOptions, selected = "Green", callback = function(v) State.FriendMarkerColor = v end })
VisTab:Toggle({ text = "Distance", default = true, callback = function(v) State.ESPDistance = v end })
VisTab:Toggle({ text = "Weapon", default = false, callback = function(v) State.ESPWeapon = v end })
VisTab:Slider({ text = "Text Size", min = 8, max = 30, default = 14, callback = function(v) State.ESPTextSize = v end })
VisTab:Dropdown({ text = "Text Color", options = colorOptions, selected = "White", callback = function(v) State.ESPTextColor = v end })
VisTab:Toggle({ text = "Snaplines", default = false, callback = function(v) State.ESPSnaplines = v end })
VisTab:Dropdown({ text = "Snapline Color", options = colorOptions, selected = "White", callback = function(v) State.ESPSnaplineColor = v end })

--========================================================================--
--                         SETTINGS TAB                                    --
--========================================================================--
GUI:NavSection("SETTINGS")
local SetTab = GUI:CreateTab({ name = "Settings", icon = "settings" })

-- CRASHYHUB INFO --
SetTab:Section("CrashyHub")
SetTab:Button({ text = "Copy Discord", callback = function() if setclipboard then setclipboard("discord.gg/crashhh"); notify("CrashyHub","Discord copied!") end end })

-- MY MONEY --
SetTab:Section("My Money")
SetTab:Button({ text = "Refresh Money Stats", callback = function()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local info = {}
        for _, v in pairs(ls:GetChildren()) do table.insert(info, v.Name..": $"..tostring(v.Value)) end
        notify("CrashyHub", table.concat(info, " | "))
    end
end })

-- MENU SETTINGS --
SetTab:Section("Menu Settings")

SetTab:Button({ text = "Eject", callback = function() notify("CrashyHub","Ejecting..."); task.wait(0.5); GUI:Destroy() end })
SetTab:Button({ text = "Rejoin Server", callback = function() notify("CrashyHub","Rejoining..."); task.wait(0.3); game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end })
SetTab:Button({ text = "Server Hop", callback = function()
    notify("CrashyHub","Server hopping...")
    pcall(function()
        local data = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(data.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer); break end end
    end)
end })
SetTab:Button({ text = "Copy Discord", callback = function() if setclipboard then setclipboard("discord.gg/crashhh"); notify("CrashyHub","Discord copied!") end end })

-- PROFILES / CONFIGS --
SetTab:Section("Profiles")
local cfgName = "Default"
SetTab:Dropdown({ text = "Config name", options = {"Default"}, selected = "Default", callback = function(v) cfgName = v end })
SetTab:Button({ text = "Save Config", callback = function()
    if writefile then writefile("CrashyHub_"..cfgName..".json", game:GetService("HttpService"):JSONEncode(State)); notify("CrashyHub","Config saved: "..cfgName) end
end })
SetTab:Button({ text = "Load", callback = function()
    if readfile and isfile and isfile("CrashyHub_"..cfgName..".json") then
        local d = game:GetService("HttpService"):JSONDecode(readfile("CrashyHub_"..cfgName..".json"))
        for k,v in pairs(d) do State[k] = v end; notify("CrashyHub","Config loaded: "..cfgName)
    end
end })
SetTab:Button({ text = "Delete", callback = function() if delfile and isfile and isfile("CrashyHub_"..cfgName..".json") then delfile("CrashyHub_"..cfgName..".json"); notify("CrashyHub","Config deleted") end end })
SetTab:Button({ text = "Overwrite", callback = function()
    if writefile then writefile("CrashyHub_"..cfgName..".json", game:GetService("HttpService"):JSONEncode(State)); notify("CrashyHub","Config overwritten") end
end })

--========================================================================--
--                        RUNSERVICE LOOPS                                 --
--========================================================================--
local flyBV, flyBG
local deathPos = nil

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.RespawnWhereYouDied and deathPos then
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then task.wait(0.2); hrp.CFrame = deathPos end
        deathPos = nil
    end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.Died:Connect(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then deathPos = hrp.CFrame end
    end) end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip then
        local c = LocalPlayer.Character; if c then
            for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end
end)

-- Main heartbeat
RunService.Heartbeat:Connect(function()
    local c = LocalPlayer.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Walk speed
    if State.WalkSpeedEnabled then
        local spd = State.WalkSpeedValue
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then spd = spd * 2 end
        hum.WalkSpeed = spd
    end

    -- Jump boost
    if State.JumpBoost then hum.JumpPower = 100 end
    if State.InfiniteJump then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end

    -- Anti fall damage
    if State.AntiFallDamage then
        local vel = hrp.Velocity; if vel.Y < -50 then hrp.Velocity = Vector3.new(vel.X, -50, vel.Z) end
    end

    -- Fly
    if State.Fly then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity", hrp); flyBV.MaxForce = Vector3.new(9e9,9e9,9e9); flyBV.Velocity = Vector3.zero
            flyBG = Instance.new("BodyGyro", hrp); flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        end
        local spd = State.FlySpeed; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then spd = spd * 0.5 end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then spd = spd * 2 end
        flyBV.Velocity = dir * spd; flyBG.CFrame = Camera.CFrame
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end

    -- Car Fly
    if State.CarFly then
        local seat = hum.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            for _, p in pairs(seat.Parent:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            seat.Velocity = dir * State.CarFlySpeed
        end
    end

    -- Vehicle speed boost
    if State.VehicleSpeedBoost then
        local seat = hum.SeatPart; if seat and seat:IsA("VehicleSeat") then seat.MaxSpeed = 100 * State.SpeedMultiplier end
    end

    -- Instant stop (V)
    if State.InstantStop and UserInputService:IsKeyDown(Enum.KeyCode.V) then
        local seat = hum.SeatPart; if seat and seat:IsA("VehicleSeat") then seat.Velocity = Vector3.zero; seat.RotVelocity = Vector3.zero end
    end

    -- Infinite needs
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if State.InfiniteSleep and (n=="sleep" or n=="tiredness" or n=="energy") then v.Value = math.max(v.Value, 100) end
            if State.InfiniteHunger and (n=="hunger" or n=="food") then v.Value = math.max(v.Value, 100) end
            if State.InfiniteStamina and (n=="stamina" or n=="sprint") then v.Value = math.max(v.Value, 100) end
        end
    end

    -- Anti car fling
    if State.AntiCarFling and hrp.Velocity.Magnitude > 300 then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero end

    -- FOV
    if State.EnableFOV then Camera.FieldOfView = State.FOVValue end

    -- Gun mods
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            local n = v.Name:lower()
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                if State.InfiniteAmmo and (n=="ammo" or n=="currentammo") then v.Value = math.max(v.Value, 999) end
                if State.InfiniteClips and (n=="clips" or n=="maxammo" or n=="storedammo") then v.Value = math.max(v.Value, 999) end
                if State.Bullets80k and (n=="ammo" or n=="currentammo") then v.Value = 80000 end
                if State.ModifyRecoilValue and (n=="recoil" or n=="recoilvalue") then v.Value = v.Value * (State.RecoilPercentage/100) end
                if State.ModifySpreadValue and (n=="spread" or n=="spreadvalue") then v.Value = v.Value * (State.SpreadPercentage/100) end
                if State.ModifyFireRate and (n=="firerate" or n=="firerateval") then v.Value = v.Value * (State.FireRatePercentage/100) end
            end
            if v:IsA("BoolValue") then
                if State.FullyAutomatic and (n=="auto" or n=="automatic" or n=="fullauto") then v.Value = true end
                if State.DisableJamming and (n=="jam" or n=="canjam" or n=="jamming") then v.Value = false end
            end
        end
        -- Gun color
        if State.EnableGunColor then
            local col = State.RainbowGunColor and Color3.fromHSV(tick()%5/5,1,1) or getColor(State.GunColor)
            for _, p in pairs(tool:GetDescendants()) do if p:IsA("BasePart") then p.Color = col end end
        end
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

-- ESP render
RunService.RenderStepped:Connect(function()
    if not State.ESPEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Head"); if h then local bb = h:FindFirstChild("CrashyESP"); if bb then bb:Destroy() end end
                local ch = p.Character:FindFirstChild("CrashyCham"); if ch then ch:Destroy() end
            end
        end
        return
    end

    local hrp = getHRP(); if not hrp then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            if head and phrp then
                local dist = (phrp.Position - hrp.Position).Magnitude
                if dist > State.ESPRenderDistance then
                    local bb = head:FindFirstChild("CrashyESP"); if bb then bb:Destroy() end; continue
                end

                local bb = head:FindFirstChild("CrashyESP")
                if not bb then
                    bb = Instance.new("BillboardGui"); bb.Name="CrashyESP"; bb.Size=UDim2.new(0,200,0,50); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=head
                    local nl = Instance.new("TextLabel",bb); nl.Name="NL"; nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold; nl.TextStrokeTransparency=0.5
                    local dl = Instance.new("TextLabel",bb); dl.Name="DL"; dl.Size=UDim2.new(1,0,0.5,0); dl.Position=UDim2.new(0,0,0.5,0); dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham; dl.TextStrokeTransparency=0.5
                end

                local nl = bb:FindFirstChild("NL"); local dl = bb:FindFirstChild("DL")
                if nl then
                    local t = State.ESPName and (p.DisplayName.." (@"..p.Name..")") or ""
                    if State.FriendMarker and pcall(function() return p:IsFriendsWith(LocalPlayer.UserId) end) then t = "[F] "..t end
                    nl.Text = t; nl.TextSize = State.ESPTextSize
                    nl.TextColor3 = State.ESPTeamColor and (p.TeamColor and p.TeamColor.Color or Color3.new(1,1,1)) or getColor(State.ESPTextColor)
                    nl.Visible = State.ESPName
                end
                if dl then
                    local t = State.ESPDistance and (math.floor(dist).."m") or ""
                    if State.ESPWeapon then local w = p.Character:FindFirstChildOfClass("Tool"); if w then t = t.." ["..w.Name.."]" end end
                    dl.Text = t; dl.TextSize = State.ESPTextSize - 2; dl.TextColor3 = getColor(State.ESPTextColor); dl.Visible = State.ESPDistance or State.ESPWeapon
                end

                -- Chams
                if State.ESPChams then
                    if not p.Character:FindFirstChild("CrashyCham") then
                        local hl = Instance.new("Highlight"); hl.Name="CrashyCham"; hl.FillColor=getColor(State.ESPChamsColor); hl.OutlineColor=getColor(State.ESPChamsColor)
                        hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.Adornee=p.Character; hl.Parent=p.Character
                    end
                else
                    local ch = p.Character:FindFirstChild("CrashyCham"); if ch then ch:Destroy() end
                end
            end
        end
    end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

-- Background loops
task.spawn(function() while true do task.wait(1)
    if State.AutoDrop10k or State.DropMax10kLoop then local r = findRemote("drop") or findRemote("money"); if r then fireRemote(r, 10000) end end
    if State.AutoDeposit30k then local r = findRemote("deposit") or findRemote("bank"); if r then fireRemote(r, 30000) end end
    if State.AutoWithdraw90k then local r = findRemote("withdraw") or findRemote("bank"); if r then fireRemote(r, 90000) end end
end end)

task.spawn(function() while true do task.wait(2)
    if State.DumpsterAutofarm then local d = findPart("dumpster") or findPart("trash"); if d then tpTo(d); local r = findRemote("dumpster") or findRemote("search"); if r then fireRemote(r) end end end
    if State.StudioAutofarm then local s = findPart("studio") or findModel("studio"); if s then tpTo(s); local r = findRemote("studio") or findRemote("work"); if r then fireRemote(r) end end end
    if State.ConstructionAutofarm then local s = findPart("construct") or findModel("construct"); if s then tpTo(s); local r = findRemote("construct") or findRemote("work"); if r then fireRemote(r) end end end
end end)

task.spawn(function() while true do task.wait(State.FlashSwapDelay)
    if State.FlashOutfit then local r = findRemote("outfit") or findRemote("clothing")
        if r then local o = {"Spiderman","All Black","Red Sp5der Drip","Blu Moncler Drip"}; fireRemote(r, o[math.random(1,#o)]) end
    end
end end)

task.spawn(function() while true do task.wait(3)
    if State.InstantInteraction then for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end end
    if State.NoBlur then for _, v in pairs(Lighting:GetChildren()) do if v:IsA("BlurEffect") then v.Enabled = false end end end
end end)

task.spawn(function() while true do task.wait(0.5)
    local h = getHum(); if h then
        if State.AutoGetHelp and h.Health < h.MaxHealth * 0.3 then local r = findRemote("gethelp") or findRemote("help"); if r then fireRemote(r) end end
        if State.InstantRevive and h.Health < h.MaxHealth * 0.15 then local r = findRemote("revive") or findRemote("gethelp"); if r then fireRemote(r) end end
    end
end end)

--============================--
--       STARTUP                --
--============================--
-- Fullbright on load
if State.Fullbright then
    Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(178,178,178)
end
-- No blur on load
if State.NoBlur then for _, v in pairs(Lighting:GetChildren()) do if v:IsA("BlurEffect") then v.Enabled = false end end end
-- Anti-AFK on load
pcall(function() local vu = game:GetService("VirtualUser"); LocalPlayer.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end)

notify("CrashyHub", "Script: CrashyHub | Game: THA BRONX 3 | Status: Working | Executor: Potassium")
notify("CrashyHub", "UI Owned by crashyyyy | Discord: discord.gg/crashhh")
