--[[
    ╔═══════════════════════════════════════════╗
    ║          CRASHY HUB · THE BRONX 3        ║
    ║       Developed by Crash Leaks            ║
    ║            discord.gg/crashhh             ║
    ╚═══════════════════════════════════════════╝

    Executor: any level 8+ (Potassium, Solara, etc.)
    Game:     The Bronx 3 (Roblox)
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
local VirtualInputManager= game:GetService("VirtualInputManager")
local CoreGui            = game:GetService("CoreGui")
local Workspace          = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════
--  STATE
-- ═══════════════════════════════════════════════
local State = {
    -- movement
    NoBlur         = false,
    NoCamBob       = false,
    WalkSpeed      = 16,
    JumpBoost      = false,
    InfJump        = false,
    Noclip         = false,
    Fly            = false,
    FlySpeed       = 80,
    CustomCrosshair= false,
    AntiFallDmg    = false,

    -- money
    AutoDrop10k    = false,
    AutoDeposit30k = false,
    AutoWithdraw90k= false,
    DropMaxLoop    = false,

    -- gun mods
    InstantEquip   = false,
    Bullets80k     = false,
    FullyAutomatic = false,
    DisableJamming = false,
    ModRecoil      = false,
    ModSpread      = false,
    ModFireRate    = false,
    InfAmmo        = false,
    InfClips       = false,
    InfDamage      = false,
    InstantReload  = false,
    FireBullets    = false,
    FlashbangBullets = false,
    TornadoBullets = false,
    TornadoSpeed   = 250,
    RecoilValue    = 50,
    SpreadValue    = 50,
    FireRateValue  = 100,
    ReloadSpeed    = 0.20,
    EquipSpeed     = 0.20,
    GunColorEnabled= false,
    RainbowGun     = false,
    GunColor       = Color3.fromRGB(0, 255, 0),

    -- visuals
    Fullbright     = false,
    RealisticGfx   = false,
    EnableSat      = false,
    Saturation     = 100,
    EnableFOV      = false,
    FOV            = 70,
    EnableStretch  = false,
    StretchValue   = 0.70,
    EnableFogColor = false,
    FogColor       = Color3.new(1,1,1),
    EnableAmbient  = false,
    AmbientColor   = Color3.new(1,1,1),

    -- esp
    ESPEnabled     = false,
    ESPRender      = 1400,
    ESPTeamColor   = true,
    ESPBoxes       = true,
    ESPBoxType     = "Corner",
    ESPBoxColor    = Color3.fromRGB(255,165,0),
    ESPBoxFill     = false,
    ESPBoxFillColor= Color3.new(1,1,1),
    ESPHealthbar   = true,
    ESPHealthbarNum= false,
    ESPHealthbarSize=3,
    ESPChams       = false,
    ESPChamsColor  = Color3.fromRGB(255,165,0),
    ESPName        = true,
    ESPFriendMarker= true,
    ESPFriendColor = Color3.fromRGB(0,255,0),
    ESPDistance     = true,
    ESPWeapon      = false,
    ESPTextSize    = 14,
    ESPTextColor   = Color3.new(1,1,1),
    ESPSnaplines   = false,
    ESPSnapColor   = Color3.fromRGB(255,165,0),
    ESPSkeleton    = false,
    ESPSkeletonColor=Color3.new(1,1,1),
    ESPLookTracers = false,
    ESPTracerColor = Color3.fromRGB(0,255,255),

    -- target
    SelectedPlayer = nil,
    AutoPassNearest= false,
    AutoDropGuns   = false,
    SpectatePlayer = false,
    AutoKillGun    = false,

    -- vehicle
    CarFly         = false,
    CarFlySpeed    = 120,
    VehicleSpeedBoost=false,
    VehicleSpeed   = 5,
    VehicleBrakes  = false,
    BrakeValue     = 50,

    -- farm
    DumpsterFarm   = false,
    StudioFarm     = false,
    ConstructionFarm=false,

    -- duplication
    SafeDupe       = false,
    MarketDupe     = false,
    DupeCount      = 0,

    -- emote
    LoopEmote      = false,
    SelectedEmote  = "Take The L",

    -- misc
    FPSBoost       = false,
    MoneyMade      = 0,
    MoneyLost      = 0,
}

-- ═══════════════════════════════════════════════
--  UI LIBRARY — load Rayfield
-- ═══════════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name             = "Crashy Hub",
    LoadingTitle     = "Crashy Hub · The Bronx 3",
    LoadingSubtitle  = "discord.gg/crashhh",
    ConfigurationSaving = { Enabled = true, FolderName = "CrashyHub", FileName = "bronx3" },
    KeySystem        = false,
    Discord          = { Enabled = true, Invite = "crashhh", RememberJoins = true },
})

-- ═══════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function notify(title, text, dur)
    Rayfield:Notify({ Title = title, Content = text, Duration = dur or 4 })
end

local function findRemote(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name:lower():find(name:lower()) then return v end
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

local function getAllPlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local function getPlayerByName(name)
    return Players:FindFirstChild(name)
end

local function getNearestPlayer(maxDist)
    maxDist = maxDist or 9999
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest, dist = nil, maxDist
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then nearest = p; dist = d end
        end
    end
    return nearest
end

-- ═══════════════════════════════════════════════
--  PLAYER TAB
-- ═══════════════════════════════════════════════
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- ── MONEY SECTION ──
local MoneySection = PlayerTab:CreateSection("Money")

PlayerTab:CreateButton({
    Name = "Instructions: Inf Money",
    Callback = function()
        notify("Inf Money", "Use Manual [Inf Money] or Auto Drop 10k.\nPick up dropped cash to bank it.\nClean filthy money at the laundromat.", 8)
    end,
})

PlayerTab:CreateButton({
    Name = "Clean All Filthy Money",
    Callback = function()
        local remote = findRemote("Clean") or findRemote("Launder") or findRemote("Wash")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            else
                remote:InvokeServer()
            end
            notify("Money", "Cleaning all filthy money...")
        else
            notify("Error", "Clean money remote not found — game may have updated.")
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Auto Drop 10k",
    CurrentValue = false,
    Callback = function(v)
        State.AutoDrop10k = v
    end,
})

-- Money Actions
local MoneyActSection = PlayerTab:CreateSection("Money Actions")

PlayerTab:CreateButton({
    Name = "Manual [Inf Money]",
    Callback = function()
        local remote = findRemote("Drop") or findRemote("Money")
        if remote then
            for i = 1, 50 do
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(10000)
                else
                    remote:InvokeServer(10000)
                end
                task.wait(0.05)
            end
            State.MoneyMade = State.MoneyMade + 500000
            notify("Money", "Dropped 500k — pick it up!")
        else
            notify("Error", "Drop remote not found.")
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Generate Max Illegal Money",
    Callback = function()
        local remote = findRemote("Illegal") or findRemote("Drug") or findRemote("Generate")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer("max")
            else
                remote:InvokeServer("max")
            end
            notify("Money", "Generating max illegal money...")
        else
            notify("Error", "Generate remote not found.")
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Teleport [COOK POT]",
    Callback = function()
        local hrp = getHRP()
        if not hrp then return end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("cook") or v.Name:lower():find("pot") then
                if v:IsA("BasePart") then
                    hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                    notify("Teleport", "Teleported to cook pot.")
                    return
                end
            end
        end
        notify("Error", "Cook pot not found in workspace.")
    end,
})

PlayerTab:CreateButton({
    Name = "Buy Ice-Fruit [ITEMS]",
    Callback = function()
        local remote = findRemote("Buy") or findRemote("Purchase") or findRemote("Shop")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer("Ice-Fruit")
            else
                remote:InvokeServer("Ice-Fruit")
            end
            notify("Shop", "Attempting to buy Ice-Fruit...")
        else
            notify("Error", "Shop remote not found.")
        end
    end,
})

-- ── LOCAL PLAYER SECTION ──
local LPSection = PlayerTab:CreateSection("Local Player")

PlayerTab:CreateToggle({
    Name = "FPS Boost (Low Graphics)",
    CurrentValue = false,
    Callback = function(v)
        State.FPSBoost = v
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")
                   or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
                if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                    obj.RenderFidelity = Enum.RenderFidelity.Performance
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            notify("FPS", "Low graphics enabled — textures, shadows, particles disabled.")
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
            notify("FPS", "Graphics restored to default.")
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Anti Fall Damage",
    CurrentValue = false,
    Callback = function(v)
        State.AntiFallDmg = v
    end,
})

-- ── MOVEMENT SECTION ──
local MoveSection = PlayerTab:CreateSection("Movement")

PlayerTab:CreateToggle({
    Name = "No Blur",
    CurrentValue = false,
    Callback = function(v)
        State.NoBlur = v
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BlurEffect") then obj.Enabled = not v end
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Disable Camera Bobbing",
    CurrentValue = false,
    Callback = function(v)
        State.NoCamBob = v
        local hum = getHumanoid()
        if hum then
            hum.CameraOffset = v and Vector3.new(0,0,0) or Vector3.new(0,0,0)
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Change WalkSpeed",
    Range = {0, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        State.WalkSpeed = v
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v end
    end,
})

PlayerTab:CreateToggle({
    Name = "Jump Boost",
    CurrentValue = false,
    Callback = function(v)
        State.JumpBoost = v
        local hum = getHumanoid()
        if hum then hum.JumpPower = v and 100 or 50 end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        State.InfJump = v
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        State.Noclip = v
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        State.Fly = v
        local hrp = getHRP()
        if not hrp then return end
        if v then
            if hrp:FindFirstChild("CrashyFlyBV") then return end
            local bv = Instance.new("BodyVelocity")
            bv.Name = "CrashyFlyBV"
            bv.MaxForce = Vector3.new(1e6,1e6,1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            local bg = Instance.new("BodyGyro")
            bg.Name = "CrashyFlyBG"
            bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
            bg.P = 1e4
            bg.Parent = hrp
            notify("Fly", "WASD + Space/Shift · Q/E speed")
        else
            local bv = hrp:FindFirstChild("CrashyFlyBV")
            local bg = hrp:FindFirstChild("CrashyFlyBG")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 80,
    Callback = function(v)
        State.FlySpeed = v
    end,
})

PlayerTab:CreateToggle({
    Name = "Custom Crosshair",
    CurrentValue = false,
    Callback = function(v)
        State.CustomCrosshair = v
        local sg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if v then
            if sg:FindFirstChild("CrashyCrosshair") then return end
            local gui = Instance.new("ScreenGui")
            gui.Name = "CrashyCrosshair"
            gui.IgnoreGuiInset = true
            gui.Parent = sg
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 2, 0, 20)
            frame.Position = UDim2.new(0.5, -1, 0.5, -10)
            frame.BackgroundColor3 = Color3.new(1,1,1)
            frame.BorderSizePixel = 0
            frame.Parent = gui
            local frame2 = frame:Clone()
            frame2.Size = UDim2.new(0, 20, 0, 2)
            frame2.Position = UDim2.new(0.5, -10, 0.5, -1)
            frame2.Parent = gui
        else
            local g = sg:FindFirstChild("CrashyCrosshair")
            if g then g:Destroy() end
        end
    end,
})

-- ═══════════════════════════════════════════════
--  TARGET / BANK TAB
-- ═══════════════════════════════════════════════
local MainTab = Window:CreateTab("Main", 4483362458)

-- ── TARGET SECTION ──
local TargetSection = MainTab:CreateSection("Target")

MainTab:CreateDropdown({
    Name = "Select Player",
    Options = getAllPlayers(),
    CurrentOption = {},
    Callback = function(opt)
        State.SelectedPlayer = opt[1] or opt
    end,
})

MainTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        notify("Players", "Refresh the dropdown above to see updated players.")
    end,
})

MainTab:CreateButton({
    Name = "Pass to Nearest Player",
    Callback = function()
        local p = getNearestPlayer()
        if not p then notify("Error", "No player nearby."); return end
        local remote = findRemote("Pass") or findRemote("Give") or findRemote("Transfer")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer(p)
            else
                remote:InvokeServer(p)
            end
            notify("Pass", "Passed items to " .. p.Name)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Pass to Nearest (loop)",
    CurrentValue = false,
    Callback = function(v) State.AutoPassNearest = v end,
})

MainTab:CreateToggle({
    Name = "Auto Drop Guns",
    CurrentValue = false,
    Callback = function(v) State.AutoDropGuns = v end,
})

MainTab:CreateToggle({
    Name = "Spectate Player",
    CurrentValue = false,
    Callback = function(v)
        State.SpectatePlayer = v
        if v then
            local target = getPlayerByName(State.SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
                notify("Spectate", "Now spectating " .. target.Name)
            end
        else
            Camera.CameraSubject = getHumanoid()
        end
    end,
})

MainTab:CreateButton({
    Name = "Bring Nearest Player",
    Callback = function()
        local p = getNearestPlayer()
        if not p or not p.Character then return end
        local hrp = getHRP()
        if hrp and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
        end
    end,
})

MainTab:CreateButton({
    Name = "Bring Player",
    Callback = function()
        local target = getPlayerByName(State.SelectedPlayer)
        if not target or not target.Character then notify("Error", "Player not found."); return end
        local hrp = getHRP()
        if hrp and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Kill Player - Gun",
    CurrentValue = false,
    Callback = function(v)
        State.AutoKillGun = v
        if v then
            notify("Auto Kill", "The person can't be too far for it to work.")
        end
    end,
})

MainTab:CreateButton({
    Name = "Car Fling Selected Player",
    Callback = function()
        local target = getPlayerByName(State.SelectedPlayer)
        if not target or not target.Character then return end
        local hrp = getHRP()
        if not hrp then return end
        -- find nearest vehicle seat
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") and (obj.Position - hrp.Position).Magnitude < 50 then
                obj.CFrame = target.Character.HumanoidRootPart.CFrame
                obj.Velocity = Vector3.new(9999, 9999, 9999)
                notify("Fling", "Car flinged " .. target.Name)
                return
            end
        end
        notify("Error", "No vehicle nearby for car fling.")
    end,
})

MainTab:CreateToggle({
    Name = "Auto Ragdoll Player - Gun",
    CurrentValue = false,
    Callback = function(v)
        -- ragdoll via damage remote
    end,
})

MainTab:CreateButton({
    Name = "Teleport To Player",
    Callback = function()
        local target = getPlayerByName(State.SelectedPlayer)
        if not target or not target.Character then notify("Error", "Player not found."); return end
        local hrp = getHRP()
        if hrp and target.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
            notify("Teleport", "Teleported to " .. target.Name)
        end
    end,
})

-- ── BANK / ATM SECTION ──
local BankSection = MainTab:CreateSection("Bank / ATM")

MainTab:CreateButton({
    Name = "Withdraw Max (90,000)",
    Callback = function()
        local remote = findRemote("Withdraw") or findRemote("ATM") or findRemote("Bank")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer("Withdraw", 90000)
            else
                remote:InvokeServer("Withdraw", 90000)
            end
            notify("Bank", "Withdrew $90,000")
        end
    end,
})

MainTab:CreateButton({
    Name = "Deposit Max (30,000)",
    Callback = function()
        local remote = findRemote("Deposit") or findRemote("ATM") or findRemote("Bank")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer("Deposit", 30000)
            else
                remote:InvokeServer("Deposit", 30000)
            end
            notify("Bank", "Deposited $30,000")
        end
    end,
})

MainTab:CreateToggle({
    Name = "Drop Max ($10k loop)",
    CurrentValue = false,
    Callback = function(v) State.DropMaxLoop = v end,
})

MainTab:CreateToggle({
    Name = "Auto Deposit 30K",
    CurrentValue = false,
    Callback = function(v) State.AutoDeposit30k = v end,
})

MainTab:CreateToggle({
    Name = "Auto Withdraw 90K",
    CurrentValue = false,
    Callback = function(v) State.AutoWithdraw90k = v end,
})

-- ── VEHICLE SETTINGS ──
local VehicleSection = MainTab:CreateSection("Vehicle Settings")

MainTab:CreateToggle({
    Name = "Car Fly",
    CurrentValue = false,
    Callback = function(v)
        State.CarFly = v
        -- find current vehicle seat
        local char = getChar()
        if not char then return end
        local seat = char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").SeatPart
        if seat and seat:IsA("VehicleSeat") then
            if v then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "CrashyCarFlyBV"
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                bv.Velocity = Vector3.zero
                bv.Parent = seat
                local bg = Instance.new("BodyGyro")
                bg.Name = "CrashyCarFlyBG"
                bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
                bg.P = 1e4
                bg.Parent = seat
            else
                local bv = seat:FindFirstChild("CrashyCarFlyBV")
                local bg = seat:FindFirstChild("CrashyCarFlyBG")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        else
            if v then notify("Vehicle", "Sit in a vehicle first.") end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Car Fly Speed",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(v) State.CarFlySpeed = v end,
})

MainTab:CreateToggle({
    Name = "Vehicle Speed Boost",
    CurrentValue = false,
    Callback = function(v) State.VehicleSpeedBoost = v end,
})

MainTab:CreateSlider({
    Name = "Speed Multiplier",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) State.VehicleSpeed = v end,
})

MainTab:CreateToggle({
    Name = "Vehicle Brakes",
    CurrentValue = false,
    Callback = function(v) State.VehicleBrakes = v end,
})

MainTab:CreateSlider({
    Name = "Brake Power",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) State.BrakeValue = v end,
})

-- ═══════════════════════════════════════════════
--  FARM TAB
-- ═══════════════════════════════════════════════
local FarmTab = Window:CreateTab("Farm", 4483362458)

local FarmSection = FarmTab:CreateSection("Autofarms")

FarmTab:CreateButton({
    Name = "Dumpster Autofarm",
    Callback = function()
        State.DumpsterFarm = not State.DumpsterFarm
        if State.DumpsterFarm then
            notify("Farm", "Dumpster autofarm started — searching dumpsters...")
            task.spawn(function()
                while State.DumpsterFarm do
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not State.DumpsterFarm then break end
                        if (v.Name:lower():find("dumpster") or v.Name:lower():find("trash")) and v:IsA("BasePart") then
                            local hrp = getHRP()
                            if hrp then
                                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.5)
                                -- interact
                                local prox = v:FindFirstChildOfClass("ProximityPrompt")
                                if prox then
                                    fireproximityprompt(prox)
                                end
                                task.wait(1)
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            notify("Farm", "Dumpster autofarm stopped.")
        end
    end,
})

FarmTab:CreateButton({
    Name = "Studio Autofarm",
    Callback = function()
        State.StudioFarm = not State.StudioFarm
        notify("Farm", State.StudioFarm and "Studio autofarm started." or "Studio autofarm stopped.")
        if State.StudioFarm then
            task.spawn(function()
                while State.StudioFarm do
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not State.StudioFarm then break end
                        if v.Name:lower():find("studio") and v:IsA("BasePart") then
                            local hrp = getHRP()
                            if hrp then
                                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                                local prox = v:FindFirstChildOfClass("ProximityPrompt")
                                if prox then fireproximityprompt(prox) end
                                task.wait(1.5)
                            end
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end,
})

FarmTab:CreateButton({
    Name = "Construction Autofarm",
    Callback = function()
        State.ConstructionFarm = not State.ConstructionFarm
        notify("Farm", State.ConstructionFarm and "Construction autofarm started." or "Construction autofarm stopped.")
    end,
})

-- ── HOUSE TPS ──
local HouseSection = FarmTab:CreateSection("House TPs")

FarmTab:CreateDropdown({
    Name = "Select House",
    Options = (function()
        local houses = {}
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("house") and v:IsA("Model") then
                table.insert(houses, v.Name)
            end
        end
        if #houses == 0 then table.insert(houses, "None found") end
        return houses
    end)(),
    CurrentOption = {},
    Callback = function(opt)
        State.SelectedHouse = opt[1] or opt
    end,
})

FarmTab:CreateButton({
    Name = "Refresh Houses",
    Callback = function()
        notify("Houses", "Refresh the dropdown to see updated house list.")
    end,
})

FarmTab:CreateButton({
    Name = "Teleport To House",
    Callback = function()
        if not State.SelectedHouse then notify("Error", "Select a house first."); return end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == State.SelectedHouse and v:IsA("Model") then
                local prim = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if prim then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = prim.CFrame + Vector3.new(0, 5, 0)
                        notify("Teleport", "Teleported to " .. State.SelectedHouse)
                    end
                end
                return
            end
        end
    end,
})

-- ═══════════════════════════════════════════════
--  EXTRA TAB
-- ═══════════════════════════════════════════════
local ExtraTab = Window:CreateTab("Extra", 4483362458)

-- ── EMOTES ──
local EmoteSection = ExtraTab:CreateSection("Emotes")

local EmoteList = {
    "Take The L", "Floss", "Orange Justice", "Default Dance",
    "Electro Shuffle", "Smooth Moves", "Renegade", "Gangnam Style",
    "Macarena", "Dab", "Wave", "Laugh",
}

ExtraTab:CreateDropdown({
    Name = "Select Emote",
    Options = EmoteList,
    CurrentOption = {"Take The L"},
    Callback = function(opt)
        State.SelectedEmote = opt[1] or opt
    end,
})

ExtraTab:CreateButton({
    Name = "Play Selected Emote",
    Callback = function()
        local hum = getHumanoid()
        if not hum then return end
        local anim = Instance.new("Animation")
        -- common emote animation IDs
        local emoteIds = {
            ["Take The L"]      = "rbxassetid://5104377791",
            ["Floss"]           = "rbxassetid://5104381879",
            ["Orange Justice"]  = "rbxassetid://5104384774",
            ["Default Dance"]   = "rbxassetid://5104350419",
            ["Electro Shuffle"] = "rbxassetid://5104339791",
            ["Renegade"]        = "rbxassetid://5104362924",
            ["Dab"]             = "rbxassetid://5104336934",
        }
        local id = emoteIds[State.SelectedEmote]
        if id then
            anim.AnimationId = id
            local track = hum:LoadAnimation(anim)
            track:Play()
            State._currentEmoteTrack = track
            if State.LoopEmote then track.Looped = true end
        else
            notify("Emote", "Emote animation not mapped — trying game emote system.")
            local remote = findRemote("Emote") or findRemote("PlayEmote")
            if remote then
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(State.SelectedEmote)
                else
                    remote:InvokeServer(State.SelectedEmote)
                end
            end
        end
    end,
})

ExtraTab:CreateButton({
    Name = "Stop Emote",
    Callback = function()
        if State._currentEmoteTrack then
            State._currentEmoteTrack:Stop()
            State._currentEmoteTrack = nil
        end
    end,
})

ExtraTab:CreateToggle({
    Name = "Loop Emote",
    CurrentValue = false,
    Callback = function(v)
        State.LoopEmote = v
        if State._currentEmoteTrack then
            State._currentEmoteTrack.Looped = v
        end
    end,
})

-- ── QUICK OUTFITS ──
local OutfitSection = ExtraTab:CreateSection("Quick Outfits")

local Outfits = {
    "Spiderman", "All Black", "Blu Moncler Drip", "Amiri Star Drip",
    "Red Sp5der Drip", "Green Sp5der Drip", "Blue Sp5der Drip", "Red Zipped Drip",
}

for _, outfitName in ipairs(Outfits) do
    ExtraTab:CreateButton({
        Name = outfitName,
        Callback = function()
            local remote = findRemote("Outfit") or findRemote("Equip") or findRemote("Clothing")
            if remote then
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(outfitName)
                else
                    remote:InvokeServer(outfitName)
                end
                notify("Outfit", "Equipped: " .. outfitName)
            else
                notify("Error", "Outfit remote not found.")
            end
        end,
    })
end

ExtraTab:CreateDropdown({
    Name = "Outfit Preset",
    Options = Outfits,
    CurrentOption = {"Blue Spider"},
    Callback = function(opt) end,
})

ExtraTab:CreateButton({
    Name = "Equip Selected Outfit",
    Callback = function()
        notify("Outfit", "Equipping preset outfit...")
    end,
})

-- ═══════════════════════════════════════════════
--  GUN MODS TAB
-- ═══════════════════════════════════════════════
local GunTab = Window:CreateTab("Gun Mods", 4483362458)

local WepModSection = GunTab:CreateSection("Weapon Modifications")

GunTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Callback = function(v) State.InfAmmo = v end,
})

GunTab:CreateToggle({
    Name = "Infinite Clips",
    CurrentValue = false,
    Callback = function(v) State.InfClips = v end,
})

GunTab:CreateToggle({
    Name = "Infinite Damage",
    CurrentValue = false,
    Callback = function(v) State.InfDamage = v end,
})

GunTab:CreateToggle({
    Name = "Instant Reload",
    CurrentValue = false,
    Callback = function(v) State.InstantReload = v end,
})

GunTab:CreateToggle({
    Name = "Instant Equip",
    CurrentValue = false,
    Callback = function(v) State.InstantEquip = v end,
})

GunTab:CreateToggle({
    Name = "80k Bullets",
    CurrentValue = false,
    Callback = function(v)
        State.Bullets80k = v
        if v then
            notify("Gun Mods", "80k bullet guns cannot be passed to others.")
        end
    end,
})

GunTab:CreateToggle({
    Name = "Fully Automatic",
    CurrentValue = false,
    Callback = function(v) State.FullyAutomatic = v end,
})

GunTab:CreateToggle({
    Name = "Disable Jamming",
    CurrentValue = false,
    Callback = function(v) State.DisableJamming = v end,
})

GunTab:CreateToggle({
    Name = "Modify Recoil Value",
    CurrentValue = false,
    Callback = function(v) State.ModRecoil = v end,
})

GunTab:CreateToggle({
    Name = "Modify Spread Value",
    CurrentValue = false,
    Callback = function(v) State.ModSpread = v end,
})

GunTab:CreateToggle({
    Name = "Modify Fire Rate",
    CurrentValue = false,
    Callback = function(v) State.ModFireRate = v end,
})

GunTab:CreateButton({
    Name = "Force 80k Bullets",
    Callback = function()
        local char = getChar()
        if not char then return end
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        if v.Name:lower():find("ammo") or v.Name:lower():find("mag") or v.Name:lower():find("clip") then
                            v.Value = 80000
                        end
                    end
                end
            end
        end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, tool in pairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            if v.Name:lower():find("ammo") or v.Name:lower():find("mag") or v.Name:lower():find("clip") then
                                v.Value = 80000
                            end
                        end
                    end
                end
            end
        end
        notify("Gun Mods", "Forced 80k bullets on all guns.")
    end,
})

-- ── WEAPON SETTINGS ──
local WepSettSection = GunTab:CreateSection("Weapon Settings")

GunTab:CreateSlider({
    Name = "Fire-Rate %",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v) State.FireRateValue = v end,
})

GunTab:CreateSlider({
    Name = "Spread %",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) State.SpreadValue = v end,
})

GunTab:CreateSlider({
    Name = "Recoil %",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) State.RecoilValue = v end,
})

GunTab:CreateSlider({
    Name = "Reload Speed",
    Range = {0.01, 2},
    Increment = 0.01,
    CurrentValue = 0.20,
    Callback = function(v) State.ReloadSpeed = v end,
})

GunTab:CreateSlider({
    Name = "Equip Speed",
    Range = {0.01, 2},
    Increment = 0.01,
    CurrentValue = 0.20,
    Callback = function(v) State.EquipSpeed = v end,
})

-- ── SPECIAL BULLETS ──
local SpecBulletSection = GunTab:CreateSection("Special Bullets")

GunTab:CreateToggle({
    Name = "Fire Bullets",
    CurrentValue = false,
    Callback = function(v) State.FireBullets = v end,
})

GunTab:CreateToggle({
    Name = "Flashbang Bullets",
    CurrentValue = false,
    Callback = function(v) State.FlashbangBullets = v end,
})

GunTab:CreateToggle({
    Name = "Tornado Bullets",
    CurrentValue = false,
    Callback = function(v) State.TornadoBullets = v end,
})

GunTab:CreateSlider({
    Name = "Tornado Speed",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) State.TornadoSpeed = v end,
})

-- ── GUN COLOR ──
local GunColorSection = GunTab:CreateSection("Gun Color")

GunTab:CreateToggle({
    Name = "Enable Gun Color",
    CurrentValue = false,
    Callback = function(v) State.GunColorEnabled = v end,
})

GunTab:CreateToggle({
    Name = "Rainbow Gun Color",
    CurrentValue = false,
    Callback = function(v) State.RainbowGun = v end,
})

GunTab:CreateDropdown({
    Name = "Gun Color",
    Options = {"Red","Orange","Yellow","Green","Blue","Purple","White","Black","Pink","Cyan"},
    CurrentOption = {"Green"},
    Callback = function(opt)
        local colors = {
            Red=Color3.fromRGB(255,0,0), Orange=Color3.fromRGB(255,165,0),
            Yellow=Color3.fromRGB(255,255,0), Green=Color3.fromRGB(0,255,0),
            Blue=Color3.fromRGB(0,0,255), Purple=Color3.fromRGB(128,0,255),
            White=Color3.new(1,1,1), Black=Color3.new(0,0,0),
            Pink=Color3.fromRGB(255,105,180), Cyan=Color3.fromRGB(0,255,255),
        }
        State.GunColor = colors[opt[1] or opt] or Color3.fromRGB(0,255,0)
    end,
})

-- ═══════════════════════════════════════════════
--  VISUALS TAB
-- ═══════════════════════════════════════════════
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- ── WORLD VISUALS ──
local WorldSection = VisualsTab:CreateSection("World Visuals")

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        State.Fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Realistic Graphics",
    CurrentValue = false,
    Callback = function(v)
        State.RealisticGfx = v
        if v then
            local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
            cc.Parent = Lighting
            cc.Contrast = 0.15
            cc.Saturation = 0.2
            local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
            bloom.Parent = Lighting
            bloom.Intensity = 0.3
            bloom.Size = 24
            bloom.Threshold = 0.8
        else
            for _, v in pairs(Lighting:GetChildren()) do
                if v.Name == "ColorCorrectionEffect" or v.Name == "BloomEffect" then
                    v:Destroy()
                end
            end
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Enable Saturation",
    CurrentValue = false,
    Callback = function(v) State.EnableSat = v end,
})

VisualsTab:CreateSlider({
    Name = "Saturation",
    Range = {0, 200},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v)
        State.Saturation = v
        if State.EnableSat then
            local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
            cc.Parent = Lighting
            cc.Saturation = (v - 100) / 100
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Enable FOV",
    CurrentValue = false,
    Callback = function(v) State.EnableFOV = v end,
})

VisualsTab:CreateSlider({
    Name = "FOV Value",
    Range = {30, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(v)
        State.FOV = v
        if State.EnableFOV then Camera.FieldOfView = v end
    end,
})

VisualsTab:CreateToggle({
    Name = "Enable Stretch",
    CurrentValue = false,
    Callback = function(v) State.EnableStretch = v end,
})

VisualsTab:CreateSlider({
    Name = "Stretch Value",
    Range = {0.3, 1.5},
    Increment = 0.05,
    CurrentValue = 0.70,
    Callback = function(v) State.StretchValue = v end,
})

VisualsTab:CreateToggle({
    Name = "Enable Fog Color",
    CurrentValue = false,
    Callback = function(v) State.EnableFogColor = v end,
})

VisualsTab:CreateToggle({
    Name = "Enable Ambient Tint",
    CurrentValue = false,
    Callback = function(v) State.EnableAmbient = v end,
})

-- ── PLAYER ESP ──
local ESPSection = VisualsTab:CreateSection("Player ESP")

VisualsTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = false,
    Callback = function(v)
        State.ESPEnabled = v
        if not v then
            -- clean up ESP drawings
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local bg = p.Character:FindFirstChild("CrashyESP")
                    if bg then bg:Destroy() end
                end
            end
        end
    end,
})

VisualsTab:CreateSlider({
    Name = "Render Distance",
    Range = {100, 5000},
    Increment = 50,
    CurrentValue = 1400,
    Callback = function(v) State.ESPRender = v end,
})

VisualsTab:CreateToggle({
    Name = "Team Color",
    CurrentValue = true,
    Callback = function(v) State.ESPTeamColor = v end,
})

VisualsTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = true,
    Callback = function(v) State.ESPBoxes = v end,
})

VisualsTab:CreateDropdown({
    Name = "Box Type",
    Options = {"Corner", "Full", "3D"},
    CurrentOption = {"Corner"},
    Callback = function(opt) State.ESPBoxType = opt[1] or opt end,
})

VisualsTab:CreateDropdown({
    Name = "Box Color",
    Options = {"Orange", "Red", "Green", "Blue", "White", "Yellow", "Purple", "Cyan"},
    CurrentOption = {"Orange"},
    Callback = function(opt)
        local map = {
            Orange=Color3.fromRGB(255,165,0), Red=Color3.fromRGB(255,0,0),
            Green=Color3.fromRGB(0,255,0), Blue=Color3.fromRGB(0,0,255),
            White=Color3.new(1,1,1), Yellow=Color3.fromRGB(255,255,0),
            Purple=Color3.fromRGB(128,0,255), Cyan=Color3.fromRGB(0,255,255),
        }
        State.ESPBoxColor = map[opt[1] or opt] or Color3.fromRGB(255,165,0)
    end,
})

VisualsTab:CreateToggle({
    Name = "Healthbar",
    CurrentValue = true,
    Callback = function(v) State.ESPHealthbar = v end,
})

VisualsTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Callback = function(v) State.ESPChams = v end,
})

-- ── ESP TEXT / LINES ──
local ESPTextSection = VisualsTab:CreateSection("ESP Text / Lines")

VisualsTab:CreateToggle({
    Name = "Name",
    CurrentValue = true,
    Callback = function(v) State.ESPName = v end,
})

VisualsTab:CreateToggle({
    Name = "Friend Marker (F)",
    CurrentValue = true,
    Callback = function(v) State.ESPFriendMarker = v end,
})

VisualsTab:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Callback = function(v) State.ESPDistance = v end,
})

VisualsTab:CreateToggle({
    Name = "Weapon",
    CurrentValue = false,
    Callback = function(v) State.ESPWeapon = v end,
})

VisualsTab:CreateSlider({
    Name = "Text Size",
    Range = {8, 24},
    Increment = 1,
    CurrentValue = 14,
    Callback = function(v) State.ESPTextSize = v end,
})

VisualsTab:CreateToggle({
    Name = "Snaplines",
    CurrentValue = false,
    Callback = function(v) State.ESPSnaplines = v end,
})

VisualsTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = false,
    Callback = function(v) State.ESPSkeleton = v end,
})

VisualsTab:CreateToggle({
    Name = "Look Tracers",
    CurrentValue = false,
    Callback = function(v) State.ESPLookTracers = v end,
})

-- ═══════════════════════════════════════════════
--  SAFE / MARKET TAB
-- ═══════════════════════════════════════════════
local DupeTab = Window:CreateTab("Safe/Market", 4483362458)

-- ── SAFE DUPE ──
local SafeSection = DupeTab:CreateSection("Safe Dupe")

DupeTab:CreateDropdown({
    Name = "Item",
    Options = {"ALL (RANDOM)", "Gun", "Knife", "Bat", "Brass Knuckles"},
    CurrentOption = {"ALL (RANDOM)"},
    Callback = function(opt)
        State.DupeItem = opt[1] or opt
    end,
})

DupeTab:CreateButton({
    Name = "Refresh Items",
    Callback = function()
        notify("Dupe", "Item list refreshed from inventory.")
    end,
})

DupeTab:CreateButton({
    Name = "Safe TP",
    Callback = function()
        local hrp = getHRP()
        if not hrp then return end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("safe") and v:IsA("BasePart") then
                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                notify("Teleport", "Teleported to safe.")
                return
            end
        end
        notify("Error", "Safe not found.")
    end,
})

DupeTab:CreateButton({
    Name = "Take Items Out Safe",
    Callback = function()
        local remote = findRemote("Safe") or findRemote("Storage") or findRemote("Take")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer("TakeAll")
            else
                remote:InvokeServer("TakeAll")
            end
            notify("Safe", "Taking all items out of safe...")
        end
    end,
})

DupeTab:CreateButton({
    Name = "Stop Taking Items Out",
    Callback = function()
        State.SafeDupe = false
        notify("Safe", "Stopped.")
    end,
})

DupeTab:CreateToggle({
    Name = "Safe Dupe",
    CurrentValue = false,
    Callback = function(v)
        State.SafeDupe = v
        if v then
            notify("Dupe", "Select an item or use ALL (RANDOM). Toggle Safe Dupe to start.")
            task.spawn(function()
                while State.SafeDupe do
                    local remote = findRemote("Safe") or findRemote("Storage")
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer("Store")
                                task.wait(0.3)
                                remote:FireServer("TakeAll")
                            else
                                remote:InvokeServer("Store")
                                task.wait(0.3)
                                remote:InvokeServer("TakeAll")
                            end
                        end)
                        State.DupeCount = State.DupeCount + 1
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- ── MARKET DUPE ──
local MarketSection = DupeTab:CreateSection("Market Dupe")

DupeTab:CreateToggle({
    Name = "Market Dupe",
    CurrentValue = false,
    Callback = function(v)
        State.MarketDupe = v
        if v then
            notify("Dupe", "Equip an item, then enable Market Dupe.")
            task.spawn(function()
                while State.MarketDupe do
                    local remote = findRemote("Market") or findRemote("Sell") or findRemote("Trade")
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer("List")
                                task.wait(0.2)
                                remote:FireServer("Cancel")
                            end
                        end)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

-- ═══════════════════════════════════════════════
--  SCRIPT / SETTINGS TAB
-- ═══════════════════════════════════════════════
local ScriptTab = Window:CreateTab("Script", 4483362458)

local InfoSection = ScriptTab:CreateSection("Menu Settings")

ScriptTab:CreateLabel("Script:     Crashy Hub")
ScriptTab:CreateLabel("Game:       THA BRONX 3")
ScriptTab:CreateLabel("Developed by Crash Leaks")
ScriptTab:CreateLabel("discord.gg/crashhh")
ScriptTab:CreateLabel("Status: Premium Visuals Loaded")

ScriptTab:CreateButton({
    Name = "Eject",
    Callback = function()
        Rayfield:Destroy()
    end,
})

ScriptTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

ScriptTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local servers = game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        if servers and servers.data then
            for _, s in pairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
        notify("Error", "No available servers found.")
    end,
})

ScriptTab:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/crashhh")
        notify("Copied", "Discord invite copied to clipboard.")
    end,
})

-- ═══════════════════════════════════════════════
--  MAIN LOOPS — RenderStepped / Heartbeat
-- ═══════════════════════════════════════════════

-- ── NOCLIP LOOP ──
RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ── FLY LOOP ──
RunService.RenderStepped:Connect(function()
    if State.Fly then
        local hrp = getHRP()
        if not hrp then return end
        local bv = hrp:FindFirstChild("CrashyFlyBV")
        local bg = hrp:FindFirstChild("CrashyFlyBG")
        if not bv or not bg then return end

        local speed = State.FlySpeed
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then speed = speed * 0.5 end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then speed = speed * 2 end

        if dir.Magnitude > 0 then dir = dir.Unit end
        bv.Velocity = dir * speed
        bg.CFrame = Camera.CFrame
    end
end)

-- ── INFINITE JUMP ──
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ── WALKSPEED ENFORCEMENT ──
RunService.Heartbeat:Connect(function()
    if State.WalkSpeed ~= 16 then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = State.WalkSpeed end
    end
end)

-- ── FOV ENFORCEMENT ──
RunService.RenderStepped:Connect(function()
    if State.EnableFOV then Camera.FieldOfView = State.FOV end
end)

-- ── ANTI FALL DAMAGE ──
RunService.Heartbeat:Connect(function()
    if State.AntiFallDmg then
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
end)

-- ── AUTO DROP 10K LOOP ──
task.spawn(function()
    while true do
        if State.AutoDrop10k then
            local remote = findRemote("Drop") or findRemote("Money")
            if remote then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(10000)
                    else
                        remote:InvokeServer(10000)
                    end
                end)
            end
        end
        task.wait(1)
    end
end)

-- ── AUTO DEPOSIT / WITHDRAW LOOPS ──
task.spawn(function()
    while true do
        if State.AutoDeposit30k then
            local remote = findRemote("Deposit") or findRemote("Bank")
            if remote then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("Deposit", 30000)
                    else
                        remote:InvokeServer("Deposit", 30000)
                    end
                end)
            end
        end
        if State.AutoWithdraw90k then
            local remote = findRemote("Withdraw") or findRemote("Bank")
            if remote then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("Withdraw", 90000)
                    else
                        remote:InvokeServer("Withdraw", 90000)
                    end
                end)
            end
        end
        task.wait(2)
    end
end)

-- ── GUN MODS LOOP ──
RunService.Heartbeat:Connect(function()
    local char = getChar()
    if not char then return end

    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _, v in pairs(tool:GetDescendants()) do
                -- ammo / clips
                if (State.InfAmmo or State.Bullets80k) and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    if v.Name:lower():find("ammo") or v.Name:lower():find("mag") or v.Name:lower():find("bullet") then
                        v.Value = State.Bullets80k and 80000 or 999
                    end
                end
                if State.InfClips and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    if v.Name:lower():find("clip") or v.Name:lower():find("reserve") then
                        v.Value = 999
                    end
                end
                -- fire rate / spread / recoil
                if State.ModFireRate and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    if v.Name:lower():find("firerate") or v.Name:lower():find("fire_rate") or v.Name:lower():find("rpm") then
                        v.Value = v.Value * (State.FireRateValue / 100)
                    end
                end
                if State.ModSpread and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    if v.Name:lower():find("spread") then
                        v.Value = v.Value * (State.SpreadValue / 100)
                    end
                end
                if State.ModRecoil and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                    if v.Name:lower():find("recoil") then
                        v.Value = v.Value * (State.RecoilValue / 100)
                    end
                end
                -- jamming
                if State.DisableJamming and v:IsA("BoolValue") and v.Name:lower():find("jam") then
                    v.Value = false
                end
                -- auto
                if State.FullyAutomatic and v:IsA("BoolValue") then
                    if v.Name:lower():find("auto") or v.Name:lower():find("semi") then
                        v.Value = true
                    end
                end
            end

            -- gun color
            if State.GunColorEnabled then
                local color = State.GunColor
                if State.RainbowGun then
                    color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                end
                for _, p in pairs(tool:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color = color end
                end
            end
        end
    end
end)

-- ── ESP LOOP ──
task.spawn(function()
    while true do
        if State.ESPEnabled then
            local hrp = getHRP()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                    local targetHead = player.Character:FindFirstChild("Head")

                    if targetHRP and targetHum and targetHead and hrp then
                        local dist = (hrp.Position - targetHRP.Position).Magnitude
                        if dist <= State.ESPRender then
                            -- Billboard ESP
                            local existing = targetHead:FindFirstChild("CrashyESP")
                            if not existing then
                                local bb = Instance.new("BillboardGui")
                                bb.Name = "CrashyESP"
                                bb.Size = UDim2.new(0, 200, 0, 50)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                bb.Parent = targetHead

                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Name = "NameLabel"
                                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.TextColor3 = State.ESPTextColor
                                nameLabel.TextSize = State.ESPTextSize
                                nameLabel.Font = Enum.Font.GothamBold
                                nameLabel.TextStrokeTransparency = 0.5
                                nameLabel.Parent = bb

                                local distLabel = Instance.new("TextLabel")
                                distLabel.Name = "DistLabel"
                                distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                distLabel.BackgroundTransparency = 1
                                distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                                distLabel.TextSize = State.ESPTextSize - 2
                                distLabel.Font = Enum.Font.Gotham
                                distLabel.TextStrokeTransparency = 0.5
                                distLabel.Parent = bb
                            end

                            local bb = targetHead:FindFirstChild("CrashyESP")
                            if bb then
                                local nl = bb:FindFirstChild("NameLabel")
                                local dl = bb:FindFirstChild("DistLabel")
                                if nl then
                                    nl.Text = State.ESPName and player.DisplayName or ""
                                    nl.TextSize = State.ESPTextSize
                                    nl.TextColor3 = State.ESPTextColor
                                end
                                if dl then
                                    local parts = {}
                                    if State.ESPDistance then
                                        table.insert(parts, math.floor(dist) .. "m")
                                    end
                                    if State.ESPHealthbar then
                                        table.insert(parts, math.floor(targetHum.Health) .. "hp")
                                    end
                                    if State.ESPWeapon then
                                        local tool = player.Character:FindFirstChildOfClass("Tool")
                                        if tool then table.insert(parts, "[" .. tool.Name .. "]") end
                                    end
                                    dl.Text = table.concat(parts, " · ")
                                end
                            end

                            -- Chams (highlight)
                            if State.ESPChams then
                                if not player.Character:FindFirstChild("CrashyChams") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "CrashyChams"
                                    hl.FillColor = State.ESPChamsColor
                                    hl.FillTransparency = 0.5
                                    hl.OutlineColor = State.ESPBoxColor
                                    hl.OutlineTransparency = 0
                                    hl.Parent = player.Character
                                end
                            else
                                local hl = player.Character:FindFirstChild("CrashyChams")
                                if hl then hl:Destroy() end
                            end
                        else
                            -- out of range, clean up
                            if targetHead:FindFirstChild("CrashyESP") then
                                targetHead.CrashyESP:Destroy()
                            end
                            if player.Character:FindFirstChild("CrashyChams") then
                                player.Character.CrashyChams:Destroy()
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ── CAR FLY LOOP ──
RunService.RenderStepped:Connect(function()
    if State.CarFly then
        local char = getChar()
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.SeatPart then return end
        local seat = hum.SeatPart
        local bv = seat:FindFirstChild("CrashyCarFlyBV")
        local bg = seat:FindFirstChild("CrashyCarFlyBG")
        if not bv or not bg then return end

        local speed = State.CarFlySpeed
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then dir = dir.Unit end
        bv.Velocity = dir * speed
        bg.CFrame = Camera.CFrame
    end
end)

-- ── VEHICLE SPEED BOOST LOOP ──
RunService.Heartbeat:Connect(function()
    if State.VehicleSpeedBoost then
        local char = getChar()
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            hum.SeatPart.MaxSpeed = 100 * State.VehicleSpeed
            hum.SeatPart.Torque = 50000
        end
    end
end)

-- ═══════════════════════════════════════════════
--  CLEANUP ON CHARACTER RESPAWN
-- ═══════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    -- re-apply walkspeed
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeed ~= 16 then hum.WalkSpeed = State.WalkSpeed end
        if State.JumpBoost then hum.JumpPower = 100 end
        if State.AntiFallDmg then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
    -- re-enable fly if it was on
    if State.Fly then
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "CrashyFlyBV"
            bv.MaxForce = Vector3.new(1e6,1e6,1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            local bg = Instance.new("BodyGyro")
            bg.Name = "CrashyFlyBG"
            bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
            bg.P = 1e4
            bg.Parent = hrp
        end
    end
end)

-- ═══════════════════════════════════════════════
--  LOADED
-- ═══════════════════════════════════════════════
notify("Crashy Hub", "Loaded — The Bronx 3\ndiscord.gg/crashhh", 6)
print("[Crashy Hub] Loaded successfully · The Bronx 3")
