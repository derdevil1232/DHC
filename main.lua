local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local humanoid = game.Players.LocalPlayer.Character.Humanoid
local tool = game.Players.LocalPlayer.Backpack.Combat
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local money = game:GetService("Workspace").Ignored.Drop:GetChildren()
local targetPos = Vector3.new(-270, 0, -362)
local threshold = 20
local idleTime = 0
local lastPosition = hrp.Position
--// ======= Cash Dropper ======= \\--

local function dropcash()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

    pcall(function()
        MainEvent:FireServer("DropMoney", "15000")
    end)


end

local function homebase()
    hrp.CFrame = CFrame.new(-270, 0, -362)
    task.wait(1)
    while task.wait(5) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            player.CharacterAdded:Wait()
            hrp = player.Character:WaitForChild("HumanoidRootPart")
        end

        local distance = (hrp.Position - targetPos).Magnitude
        if distance > threshold then
            hrp.CFrame = CFrame.new(targetPos)
        else
            dropcash()
            break
        end
    end

end



--// ======= ATM Farming ======= \\--

local humanoid = game.Players.LocalPlayer.Character.Humanoid
local tool = game.Players.LocalPlayer.Backpack.Combat

local function getMoneyAroundMe() 
    wait(3)
    for i, money in ipairs(game.Workspace.Ignored.Drop:GetChildren()) do
        if money.Name == "MoneyDrop" and (money.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 20 then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = money.CFrame
            fireclickdetector(money.ClickDetector)
            wait(1)
        end  
    end
end


local function startAutoFarm() 
    humanoid:EquipTool(tool)

    for i, v in ipairs(game.Workspace.Cashiers:GetChildren()) do
        if v:FindFirstChild("Open") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Open.CFrame * CFrame.new(0, 0, 2)

            for i = 0, 15 do
                wait(1)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Open.CFrame * CFrame.new(0, 0, 2)
                tool:Activate()
            end

            getMoneyAroundMe()
            task.wait(2)
        end
    end

    task.wait(0.5)
end

task.spawn(function()
    while true do
        if (hrp.Position - lastPosition).magnitude < 0.1 then
            idleTime = idleTime + 1
        else
            idleTime = 0
        end

        lastPosition = hrp.Position

        if idleTime >= 30 then
            startAutoFarm()
            print("Detected idle, restarting auto farm...")
            idleTime = 0
        end

        task.wait(1) -- check every second
    end
end)

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local function crashgametoforcereconnect()
        while true do
            print("Crashing Game")
        end
end




--// Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

local farmingEnabled = true
local lastDrop = 0

--// UI
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
gui.Name = "FarmUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true

local startButton = Instance.new("TextButton", frame)
startButton.Size = UDim2.new(1, -20, 0, 40)
startButton.Position = UDim2.new(0, 10, 0, 10)
startButton.Text = "Start"
startButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
startButton.TextColor3 = Color3.new(1, 1, 1)

local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 60)
textbox.PlaceholderText = "Enter amount to drop"
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.new(1, 1, 1)

local dropButton = Instance.new("TextButton", frame)
dropButton.Size = UDim2.new(1, -20, 0, 30)
dropButton.Position = UDim2.new(0, 10, 0, 100)
dropButton.Text = "Drop Cash"
dropButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropButton.TextColor3 = Color3.new(1, 1, 1)

--// Drop function
local function dropCash(amount)
	if tick() - lastDrop < 16 then
		warn("Cooldown: wait " .. math.ceil(16 - (tick() - lastDrop)) .. "s")
		return
	end

	local desired = tonumber(amount)
	if not desired or desired <= 0 then
		warn("Invalid amount")
		return
	end

	-- compute raw amount before 15% tax, max 15000
	local raw = math.ceil(desired / 0.85)
	if raw > 15000 then
		raw = 15000
		warn("Capped at 15000 (12750 after tax)")
	end

	pcall(function()
		MainEvent:FireServer("DropMoney", tostring(raw))
	end)

	lastDrop = tick()
	print("Dropped " .. raw .. " (you receive " .. math.floor(raw * 0.85) .. ")")
end

--// Button logic
startButton.MouseButton1Click:Connect(function()
	farmingEnabled = not farmingEnabled
	startButton.Text = farmingEnabled and "Stop" or "Start"
	print("Farming Enabled:", farmingEnabled)
end)


local DEBOUNCE_TIME = 1 -- seconds between allowed calls
local lastCall = 0

local function should_trigger(msg)
    if not msg then return false end
    -- normalize to string
    local s = tostring(msg)
    -- look for the literal substring Tool:Activate()
    return string.find(s, "Tool:Activate%(%%)", 1, false) ~= nil
end

local function try_trigger()
        local now = tick()
        if now - lastCall < DEBOUNCE_TIME then return end
        lastCall = now
        -- call safely
        if type(crashgametoforcereconnect) == "function" then
            pcall(crashgametoforcereconnect)
        end
end


do
    local _warn = warn
    warn = function(...)
        local parts = table.pack(...)
        for i = 1, parts.n do
            if should_trigger(parts[i]) then
                try_trigger()
                break
            end
        end
        return _warn(...)
    end
end

-- wrap print
do
    local _print = print
    print = function(...)
        local parts = table.pack(...)
        for i = 1, parts.n do
            if should_trigger(parts[i]) then
                try_trigger()
                break
            end
        end
        return _print(...)
    end
end

-- wrap error (in case warnings are sent via error)
do
    local _error = error
    error = function(msg, level)
        if should_trigger(msg) then
            try_trigger()
        end
        return _error(msg, level)
    end
end

-- optional: monitor rconsoles if executor provides one
if rconsoleprint then
    local _rconsoleprint = rconsoleprint
    rconsoleprint = function(text)
        if should_trigger(text) then try_trigger() end
        return _rconsoleprint(text)
    end
end

task.spawn(function()
    while true do
        task.wait(1) -- check every 1 second
        if humanoid.Health <= 0 then
            -- Health is 0 or below, start printing endlessly
            while true do
                print("Force crashing client to reconnect...")
            end
        end
    end
end)




dropButton.MouseButton1Click:Connect(function()
	dropCash(textbox.Text)
end)

task.spawn(function()
    while true do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                obj:Destroy()
            end
        end
        task.wait(10)
    end
end)

task.spawn(function()
    local Light = game:GetService("Lighting")

    function dofullbright()
    Light.Ambient = Color3.new(1, 1, 1)
    Light.ColorShift_Bottom = Color3.new(1, 1, 1)
    Light.ColorShift_Top = Color3.new(1, 1, 1)
    end

    dofullbright()

    Light.LightingChanged:Connect(dofullbright)
    task.wait(1)
end)



while true do
	if farmingEnabled then
		print("Starting Auto Farm...")
		startAutoFarm()
	else
		-- paused, waiting until farmingEnabled becomes true
		repeat task.wait(0.5) until farmingEnabled
	end
	task.wait(1)
end
