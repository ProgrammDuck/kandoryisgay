local plrs = game:GetService("Players")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Teams = game:GetService('Teams')

local Key_event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Key")
local module = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Main"))

--------------------------------------------
local game_duration = 300
local players_needed = 3
--------------------------------------------

local playingPlayers = {}
local current_time = game_duration 
local isGameRunning = false
local isRestarting = false
local timerThread = nil
local gameConnections = {}


local _StartGame
local _GameRestart
local _PlayersWin
local _LeaderWin

--------------------------------------------

local function formatTime(totalSeconds)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60
	return string.format("%02d:%02d", minutes, seconds)
end

local function _Send(message: string)
	for _, player in pairs(plrs:GetPlayers()) do
		local playerGui = player:FindFirstChild("PlayerGui")
		local timer = playerGui and playerGui:FindFirstChild("Timer")
		local textLabel = timer and timer:FindFirstChild("TextLabel")
		if textLabel then
			textLabel.Text = message
		end
	end
end

local function _Timer()
	for s = game_duration, 0, -1 do
		current_time = s
		_Send(formatTime(current_time))
		task.wait(1)
	end
	_PlayersWin()
end

-----------------------------------------------------------------


local function cleanupConnections()
	for _, connection in ipairs(gameConnections) do
		if connection then
			connection:Disconnect()
		end
	end
	gameConnections = {}
end

local function removePlayingPlayer(player)
	local index = table.find(playingPlayers, player)
	if index then
		table.remove(playingPlayers, index)
		print("Player out: " .. player.Name)

		if #playingPlayers == 0 and isGameRunning then
			_LeaderWin()
		end
	end
end

-----------------------------------------------------------------

local function _ChooseLeader()
	local players = plrs:GetPlayers()
	if #players == 0 then return nil end

	local leader = players[math.random(1, #players)]
	leader.Team = Teams:WaitForChild('KeyBoarder')
	return leader
end

function _GameRestart()
	if isRestarting then return end
	isRestarting = true
	isGameRunning = false

	cleanupConnections()
	if timerThread then task.cancel(timerThread) end

	task.wait(1)
	playingPlayers = {}
	current_time = game_duration

	local Team = Teams:WaitForChild("Player")
	for _, player in pairs(plrs:GetPlayers()) do
		player.Team = Team
	end

	module.TeleportAllOut()

	task.wait(6)

	isRestarting = false
	_StartGame()
end

-----------------------------------------------------------------

function _PlayersWin()
	if not isGameRunning then return end
	_Send("Game Over | Players Win!")
	_GameRestart()
end

function _LeaderWin()
	if not isGameRunning then return end
	_Send("Game Over | KeyBoarder Win!")
	_GameRestart()
end

local function _CheckingWin(leader: Player)
	cleanupConnections()

	local leader_char = leader.Character or leader.CharacterAdded:Wait()
	local leader_hum = leader_char:WaitForChild('Humanoid', 5)

	if leader_hum then
		local leaderConnection = leader_hum.Died:Connect(function()
			_PlayersWin()
		end)
		table.insert(gameConnections, leaderConnection)
	end

	local leaveConnection = plrs.PlayerRemoving:Connect(function(player)
		if player == leader then
			_PlayersWin()
		else
			removePlayingPlayer(player)
		end
	end)
	table.insert(gameConnections, leaveConnection)

	for _, player in pairs(playingPlayers) do
		local function listenToDeath(char)
			local hum = char:WaitForChild("Humanoid", 5)
			if hum then
				local dieConn = hum.Died:Connect(function()
					removePlayingPlayer(player)
				end)
				table.insert(gameConnections, dieConn)
			end
		end

		if player.Character then
			listenToDeath(player.Character)
		end

		local charAddedConn = player.CharacterAdded:Connect(listenToDeath)
		table.insert(gameConnections, charAddedConn)
	end
end

-----------------------------------------------------------------

function _StartGame()
	if isGameRunning or isRestarting then return end

	if #plrs:GetPlayers() < players_needed then 
		_Send("Waiting for players... (" .. #plrs:GetPlayers() .. "/" .. players_needed .. ")")
		return 
	end

	isGameRunning = true

	local players = plrs:GetPlayers()
	playingPlayers = {}
	for _, player in pairs(players) do
		table.insert(playingPlayers, player)
	end

	local leader = _ChooseLeader()
	if not leader then isGameRunning = false return end

	removePlayingPlayer(leader)
	module.TeleportAllIn(leader)

	timerThread = task.spawn(_Timer)
	_CheckingWin(leader)
end

------------------------------------------------------------

local function updatePlayerCount()
	_StartGame()
end

plrs.PlayerAdded:Connect(updatePlayerCount)
plrs.PlayerRemoving:Connect(function(player)
	if isGameRunning then
		removePlayingPlayer(player)
	end
	updatePlayerCount()
end)

-------------------------------------------TESTING-----------------------------------------------
local e = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild('RemoteEvent')
e.OnServerEvent:Connect(_StartGame)
-------------------------------------------------------------------------------------------------