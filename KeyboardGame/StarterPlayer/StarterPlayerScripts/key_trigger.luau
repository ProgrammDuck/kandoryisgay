local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Buttons = Workspace:WaitForChild("KeyBoard"):GetChildren()

local plr = Players.LocalPlayer
local Key_event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Key")

for i, v in pairs(Buttons) do
	local detector = v:WaitForChild("ClickDetector")

	detector.MouseClick:Connect(function()
		Key_event:FireServer(v)
	end)
end

local function _Turn(Value)
	for i, v in pairs(Buttons) do
		local ClickDetector = v:FindFirstChild("ClickDetector")
		ClickDetector.MaxActivationDistance = Value
	end
end

plr:GetPropertyChangedSignal("Team"):Connect(function()
	if plr.Team and plr.Team.Name == "KeyBoarder" then
		_Turn(999999)
	else
		_Turn(0)
	end
end)