import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"


PIECES_IMG_PATHS = {
	[" "] = "",
	["."] = "",
	["p"] = "images/pawn1",
	["P"] = "images/pawn",
	["b"] = "images/bishop1",
	["B"] = "images/bishop",
	["n"] = "images/knight1",
	["N"] = "images/knight",
	["r"] = "images/rook1",
	["R"] = "images/rook",
	["k"] = "images/king1",
	["K"] = "images/king",
	["q"] = "images/queen1",
	["Q"] = "images/queen"
}
FILES = {
	[1] = "a",
	[2] = "b",
	[3] = "c",
	[4] = "d",
	[5] = "e",
	[6] = "f",
	[7] = "g",
	[8] = "h",
}

local gfx <const> = playdate.graphics
local cachedPieceImages = {}
local boards = {}
local boardIdx = 0
local clicked = {
	{ -1, -1, "", "" },
	{ -1, -1, "", "" }
}

gfx.setFont(gfx.font.new("fonts/Mini Mono 2X"))

-- Board Representation
-- rnbqkbnr\n
-- pppppppp\n
-- ........\n
-- ........\n
-- ........\n
-- ........\n
-- PPPPPPPP\n
-- RNBQKBNR\n
local function getPieceAt(board, row, col)
	local idx = (row - 1) * 9 + col
	local piece = string.sub(board, idx, idx)
	return piece
end

class('BoardGridLayout').extends()

function BoardGridLayout:init(newBoard)
	BoardGridLayout.super.init(self)

	-- initialize gridview
	self.gridview = playdate.ui.gridview.new(27, 27)
	self.gridview:setNumberOfColumns(8)
	self.gridview:setNumberOfRows(8)
	self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
	self.gridview:setContentInset(5, 5, 5, 5)

	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
	self.gridviewSprite:moveTo(17, 0)
	self.gridviewSprite:add()

	function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
		gfx.pushContext()
		-- draw the background square color
		if (row + column) % 2 == 0 then
			gfx.setColor(gfx.kColorClear)
		else
			gfx.setDitherPattern(.6, gfx.image.kDitherTypeBayer8x8)
		end
		gfx.fillRect(x, y, width, height)

		-- add border to selected cell
		if selected then
			gfx.setLineWidth(3)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawRect(x, y, width, height)
		end

		-- highlight last clicked cell
		if clicked[#clicked][1] == row and clicked[#clicked][2] == column then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(.2, gfx.image.kDitherTypeBayer8x8)
			gfx.fillRect(x, y, width, height)
		end

		-- add hints to possible moves piece can make

		-- draw piece image
		if boards[boardIdx] then
			local piece = getPieceAt(boards[boardIdx], row, column)
			local piecePath = PIECES_IMG_PATHS[piece]
			if cachedPieceImages[piecePath] then
				cachedPieceImages[piecePath]:draw(x + 1, y + 1)
			end
		end
		gfx.popContext()
	end

	self:addBoard(newBoard)
	self:drawFiles()
	self:drawRanks()
	print("board grid view initialized")
end

function BoardGridLayout:drawGridView()
	-- print("drawGridView()")
	local gridviewImage = gfx.image.new(226, 226)
	gfx.pushContext(gridviewImage)
	self.gridview:drawInRect(0, 0, 226, 226)
	gfx.popContext()
	self.gridviewSprite:setImage(gridviewImage)
end

function BoardGridLayout:createTextSprite(text, x, y)
	local textSprite = gfx.sprite.spriteWithText(text, 30, 30)
	textSprite:moveTo(x, y)
	textSprite:add()
end

function BoardGridLayout:drawFiles()
	local files = { "a", "b", "c", "d", "e", "f", "g", "h" }
	for i = 1, #files do
		self:createTextSprite(files[i], 9 + i * 27, 234)
	end
end

function BoardGridLayout:drawRanks()
	local j = 8
	for i = 1, 8, 1 do
		self:createTextSprite(tostring(i), 11, j * 27 - 4)
		j -= 1
	end
end

function BoardGridLayout:addBoard(newBoard)
	table.insert(boards, newBoard)
	boardIdx += 1
	self:drawGridView()
end

function BoardGridLayout:removeBoard()
	if boardIdx == 0 then
		return
	end
	boardIdx -= 1
	table.remove(boards)
	self:drawGridView()
end

function BoardGridLayout:previousPosition()
	boardIdx -= 1
	if boardIdx == 0 then
		boardIdx = 1
	end
	print("previousPosition() calling drawGridView()")
	self:drawGridView()
end

function BoardGridLayout:nextPosition()
	boardIdx += 1
	if boardIdx >= #boards then
		boardIdx = #boards
	end
	print("nextPosition() calling drawGridView()")
	self:drawGridView()
end

function BoardGridLayout:needsDisplay()
	return self.gridview.needsDisplay
end

function BoardGridLayout:clickCell()
	local _, r, c = self.gridview:getSelection()
	local position = FILES[c] .. tostring(9 - r)
	local piece = getPieceAt(boards[boardIdx], r, c)
	table.insert(clicked, { r, c, position, piece })
	local move = clicked[#clicked - 1][3] .. clicked[#clicked][3]
	print("move: " .. move)
	self:drawGridView()
	return clicked[#clicked - 1][3], clicked[#clicked][3]
end

-- function BoardGridLayout:getUsersMoveFromGrid()
-- 	local _, r, c = self.gridview:getSelection()
-- 	local position = FILES[c] .. tostring(9-r)
-- 	prevGridSelection = newGridSelection
-- 	newGridSelection = position
-- 	local moveText = prevGridSelection .. newGridSelection
-- 	print("selected ("..r..","..c..") move = "..moveText)
-- 	return moveText
-- end

function BoardGridLayout:selectNextRow(select)
	self.gridview:selectNextRow(select)
	self:drawGridView()
end

function BoardGridLayout:selectPreviousRow(select)
	self.gridview:selectPreviousRow(select)
	self:drawGridView()
end

function BoardGridLayout:selectNextColumn(select)
	self.gridview:selectNextColumn(select)
	self:drawGridView()
end

function BoardGridLayout:selectPreviousColumn(select)
	self.gridview:selectPreviousColumn(select)
	self:drawGridView()
end

-- clear all the history from the game
function BoardGridLayout:clearGameData()
	boards = {}
	boardIdx = 0
	clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
end

local function cachePieceImages()
	for _, pieceImagePath in pairs(PIECES_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedPieceImages[pieceImagePath] = pieceImage
	end
end

cachePieceImages()
