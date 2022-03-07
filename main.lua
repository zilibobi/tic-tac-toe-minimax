local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerGui = Players.LocalPlayer.PlayerGui
local label = PlayerGui:WaitForChild("TicTacToe").Board

local previousPlayer = "O"
local currentPlayer = "O"

local config = {
	empty = "-",
	ai = "X",
	player = "O"
}

local board = {}

local scores = {
	X = 1,
	O = -1,
	tie = 0
}

local function generate()
	board = {}

	for y = 1, 3 do
		board[y] = {}

		for x = 1, 3 do
			table.insert(board[y], config.empty)
		end
	end
end

local function equals(a, b, c)
	return a == b and b == c and a ~= config.empty
end

local function checkWinner()
	local winner = nil

	for x = 1, 3 do
		if equals(board[x][1], board[x][2], board[x][3]) then
			winner = board[x][1]
		end
	end

	for x = 1, 3 do
		if equals(board[1][x], board[2][x], board[3][x]) then
			winner = board[1][x]
		end
	end

	if equals(board[1][1], board[2][2], board[3][3]) then
		winner = board[1][1]
	end

	if equals(board[3][1], board[2][2], board[1][3]) then
		winner = board[3][1]
	end

	local spots = 0

	for x = 1, 3 do
		for y = 1, 3 do
			if board[x][y] == config.empty then
				spots += 1
			end
		end
	end

	if winner == nil and spots == 0 then
		return "tie"
	else
		return winner
	end
end

local function minimax(depth, isMax)
	local result = checkWinner()

	if result ~= nil then
		return scores[result]
	end

	if isMax then
		local bestScore = -math.huge

		for x = 1, 3 do
			for y = 1, 3 do
				if board[x][y] == config.empty then
					board[x][y] = config.ai

					local score = minimax(depth + 1, false)
					board[x][y] = config.empty

					bestScore = math.max(score, bestScore)
				end
			end

			if config.bewareOfCrashing then
				RunService.RenderStepped:Wait()
			end
		end

		return bestScore
	else
		local bestScore = math.huge

		for x = 1, 3 do
			for y = 1, 3 do
				if board[x][y] == config.empty then
					board[x][y] = config.player

					local score = minimax(depth + 1, true)
					board[x][y] = config.empty

					bestScore = math.min(score, bestScore)
				end
			end

			if config.bewareOfCrashing then
				RunService.RenderStepped:Wait()
			end
		end

		return bestScore
	end
end

local function bestMove()
	local winner = checkWinner()

	if winner then
		return
	end

	local bestScore = -math.huge
	local move

	for x = 1, 3 do
		for y = 1, 3 do
			if board[x][y] == config.empty then
				board[x][y] = config.ai

				local score = minimax(0, false)
				board[x][y] = config.empty

				if score > bestScore then
					bestScore = score
					move = { x = x, y = y }
				end
			end
		end
	end

	board[move.x][move.y] = config.ai
	currentPlayer = config.player
end

local function visualize(showMove)
	local final = ""

	for x = 1, 3 do
		local row = table.concat(board[x], " ")
		final = string.format("%s%s\n", final, row)
	end

	return showMove ~= false and final .. string.format("\n\%s turn, You are: %s", currentPlayer == config.ai and "AI's" or "Your", config.player) or final
end

generate()

label.Text = visualize()
label.Current.Text = "Type xNumber yNumber in the chat to make a move."

Players.LocalPlayer.Chatted:Connect(function(message)
	local text = message:lower()
	local x, y = text:match("x(%d) y(%d)")

	x, y = tonumber(x), tonumber(y)

	if x and y then
		if x <= 3 and y <= 3 then
			if board[y][x] == config.empty and currentPlayer == config.player then
				board[y][x] = config.player
				currentPlayer = config.ai
				bestMove()

				local winner = checkWinner()
				label.Text = visualize()

				if winner then
					local text = visualize(false)

					label.Text = text .. (winner ~= "tie" and string.format("\nThe winner is %s", winner) or "\nTie")
					task.wait(5)

					generate()

					if previousPlayer == config.ai then
						previousPlayer = config.player
						currentPlayer = config.player
					else
						previousPlayer = config.ai
						currentPlayer = config.ai
						bestMove()
					end

					label.Text = visualize()
				end
			end
		end
	end
end)
