local module = {}

local players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Teams = game:GetService('Teams')
local TS = game:GetService('TweenService')



local info = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local buttons = game.Workspace.KeyBoard:GetChildren()
module.animation_in = function(button)
	local tween = TS:Create(button, info, {
		Position = Vector3.new(button.Position.X, 101.53, button.Position.Z),
		Transparency = 1
	})
	tween:Play()
	wait(0.5)
	button.CanCollide = false
end

module.animation_out = function(button)
	local tween = TS:Create(button, info, {
		Position = Vector3.new(button.Position.X, 122.53, button.Position.Z),
		Transparency = 0
	})
	tween:Play()
	button.CanCollide = true
end



module.Timer = function(time:IntValue, leader:Player)
	--local IsLeaderWin = false
	--num.Value = time
	--local timer = tonumber(num.Value)
	--for i = time, 1, -1 do
	--		num.Value -= 1
	--		--if #Teams:WaitForChild('Player'):GetPlayers() == 0 and timer >= 1 then
	--		--	num.Value = 'Leader wins!'
	--		--	IsLeaderWin = true
	--		--	break
	--		--end
	--		if #Teams:WaitForChild('KeyBoarder'):GetPlayers() == 0 then
	--			num.Value = 'Leader leaved'
	--			IsLeaderWin = false
	--			task.wait(1)
	--			break
	--		end
	--		task.wait(1)
	--end
	--if #Teams:WaitForChild('Player'):GetPlayers() >= 1 and IsLeaderWin == false then
	--	num.Value = 'Players wins!'
	--end
	
	--wait(2)
	--num.Value = 'Didn\'t start'
	--return
end

module.TeleportAllIn = function(Leader:Player)
	for i,v:Player in pairs(players:GetPlayers()) do
		local character = v.Character or v.CharacterAdded:Wait()
		if v ~= Leader then 
			character:MoveTo(Vector3.new(-59.5, 169.203, 290))
		else -- leader
			local hum:Humanoid = character:WaitForChild('Humanoid')
			hum.WalkSpeed = 0
			hum.JumpPower = 0
			character:MoveTo(Vector3.new(-237.5, 245, 290))
		end
		
		--local hum:Humanoid = v.Character:WaitForChild('Humanoid')
		
		--hum.Died:Connect(function()
		--	v.Team = nil
		--end)
	end
end

module.TeleportAllOut = function()
	for i,v:Player in pairs(players:GetPlayers()) do
		local character = v.Character or v.CharacterAdded:Wait()
		local hum:Humanoid = character:WaitForChild('Humanoid')
		character:MoveTo(Vector3.new(-71.5, 293.703, 290))
		hum.WalkSpeed = 16
		hum.JumpPower = 50
	end
end


return module
