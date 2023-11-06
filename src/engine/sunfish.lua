-- sunfish.lua, a human transpiler work of https://github.com/thomasahle/sunfish
-- embarassing and ugly translation done by Soumith Chintala
-- Code License: BSD
import 'helper/Utils'

-- Our board is represented as a 120 character string. The padding allows for
-- fast detection of moves that don't stay within the board.
local A1, H1, A8, H8 = 91, 98, 21, 28

local __1 = 1 -- 1-index correction

-- local initial = 
--     '         \n' .. --   0 -  9
--     '         \n' .. --  10 - 19
--     ' rnbqkbnr\n' .. --  20 - 29
--     ' pppppppp\n' .. --  30 - 39
--     ' ........\n' .. --  40 - 49
--     ' ........\n' .. --  50 - 59
--     ' ........\n' .. --  60 - 69
--     ' ........\n' .. --  70 - 79
--     ' PPPPPPPP\n' .. --  80 - 89
--     ' RNBQKBNR\n' .. --  90 - 99
--     '         \n' .. -- 100 -109
--     '          '     -- 110 -119

-------------------------------------------------------------------------------
-- Move and evaluation tables
-------------------------------------------------------------------------------
local N, E, S, W = -10, 1, 10, -1
local directions = {
    P = {N, 2 * N, N + W, N + E},
    N = {2 * N + E, N + 2 * E, S + 2 * E, 2 * S + E, 2 * S + W, S + 2 * W, N + 2 * W, 2 * N + W},
    B = {N + E, S + E, S + W, N + W},
    R = {N, E, S, W},
    Q = {N, E, S, W, N + E, S + E, S + W, N + W},
    K = {N, E, S, W, N + E, S + E, S + W, N + W}
}

-------------------------------------------------------------------------------
-- Utils
-------------------------------------------------------------------------------
local function isspace(s)
    if s == ' ' or s == '\n' then
        return true
    else
        return false
    end
end

local special = '. \n'

local function isupper(s)
    if special:find(s) then
        return false
    end
    return s:upper() == s
end

local function islower(s)
    if special:find(s) then
        return false
    end
    return s:lower() == s
end

local function parse(c)
    if not c then
        return nil
    end
    local p, v = c:sub(1, 1), c:sub(2, 2)
    if not (p and v and tonumber(v)) then
        return nil
    end

    local fil, rank = string.byte(p) - string.byte('a'), tonumber(v) - 1
    return A1 + fil - 10 * rank
end

-- super inefficient
local function swapcase(s)
   local s2 = ''
   for i=1,#s do
      local c = s:sub(i, i)
      if islower(c) then
	 s2 = s2 .. c:upper()
      else
	 s2 = s2 .. c:lower()
      end
   end
   return s2
end

-------------------------------------------------------------------------------
-- Chess logic
-------------------------------------------------------------------------------

local Position = {}

function Position.new(board, score, wc, bc, ep, kp)
    --[[  A state of a chess game
      board -- a 120 char representation of the board
      score -- the board evaluation
      wc -- the castling rights
      bc -- the opponent castling rights
      ep - the en passant square
      kp - the king passant square
   ]]
    --
    local self = {}
    self.board = board
    self.score = score
    self.wc = wc
    self.bc = bc
    self.ep = ep
    self.kp = kp
    for k, v in pairs(Position) do
        self[k] = v
    end
    return self
end

function Position:rotate()
   return self.new(
      swapcase(self.board:reverse()), -self.score,
      self.bc, self.wc, 119-self.ep, 119-self.kp)
end

function Position:idxToRowCol(isUserWhite, idx)
    local col = math.floor(idx % 10)
    local row = math.floor(idx / 10 - 1)
   --  if isUserWhite == false then
   --    col = 9 - col
   --    row = 9 - row
   --  end
    return row, col
end

function Position:genMoves(squareTxt)
    local moves = {}
    -- For each of our pieces, iterate through each possible 'ray' of moves,
    -- as defined in the 'directions' map. The rays are broken e.g. by
    -- captures or immediately in case of pieces such as knights.

    -- todo
    -- todo
    -- todo dont need to loop 64 squares, just need the square we're interested in
    local square = parse(squareTxt:sub(1, 2))
    for i = 1 - __1, #self.board - __1 do
        local p = self.board:sub(i + __1, i + __1)

        if isupper(p) and directions[p] and square == i then
            for _, d in ipairs(directions[p]) do
                local limit = (i + d) + (10000) * d -- fake limit
                for j = i + d, limit, d do
                    local q = self.board:sub(j + __1, j + __1)
                    -- Stay inside the board
                    if isspace(q) then
                        break
                    end
                    -- Castling
                    if i == A1 and q == 'K' and self.wc[0 + __1] then
                        table.insert(moves, {j, j - 2})
                    end
                    if i == H1 and q == 'K' and self.wc[1 + __1] then
                        table.insert(moves, {j, j + 2})
                    end
                    -- No friendly captures
                    if isupper(q) then
                        break
                    end
                    -- Special pawn stuff
                    if p == 'P' and (d == N + W or d == N + E) and q == '.' and j ~= self.ep and j ~= self.kp then
                        break
                    end
                    if p == 'P' and (d == N or d == 2 * N) and q ~= '.' then
                        break
                    end
                    if p == 'P' and d == 2 * N and (i < A1 + N or self.board:sub(i + N + __1, i + N + __1) ~= '.') then
                        break
                    end
                    -- Move it
                    table.insert(moves, {i, j})
                    -- Stop crawlers from sliding
                    if p == 'P' or p == 'N' or p == 'K' then
                        break
                    end
                    -- No sliding after captures
                    if islower(q) then
                        break
                    end
                end
            end
        end
    end
    return moves
end

-------------------------------------------------------------------------------
-- User interface
-------------------------------------------------------------------------------
local function getSunfishBoard(board)
    local boardTable = splitString(board, "\n")
    local sunfishBoard =
        "         \n" .. 
        "         \n" .. 
        " " .. boardTable[1] .. "\n" .. 
        " " .. boardTable[2] .. "\n" .. 
        " " .. boardTable[3] .. "\n" .. 
        " " .. boardTable[4] .. "\n" .. 
        " " .. boardTable[5] .. "\n" .. 
        " " .. boardTable[6] .. "\n" .. 
        " " .. boardTable[7] .. "\n" .. 
        " " .. boardTable[8] .. "\n" .. 
        "         \n" ..
        "         \n"
    return sunfishBoard
end

function getMoveOptions(isUserWhite, squareTxt, board)
    if squareTxt == "" then
        return nil
    end

    local squares = {}
    local board = getSunfishBoard(board)
    if isUserWhite == false then
      board = swapcase(board)
    end

    local pos = Position.new(board, 0, {true, true}, {true, true}, 0, 0)
    local moves = pos:genMoves(squareTxt)
    for i = 1, #moves do
        local row, col = pos:idxToRowCol(isUserWhite, moves[i][2])
        squares[row .. "," .. col] = true
    end
    return squares
end
