import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import 'ui/imageCache'

local FILES <const> = {
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
local BOARD_WIDTH <const> = 228
local BORDER_OFFSET <const> = 2
local BORDER_X_THICKNESS <const> = 12
local BORDER_Y_THICKNESS <const> = 10

local imageCache = ImageCache()
local boards = {}
local boardIdx = 0
local clicked = {
	{ -1, -1, "", "" },
	{ -1, -1, "", "" }
}


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

class('BoardGridView').extends()

function BoardGridView:init(newBoard)
	BoardGridView.super.init(self)

	-- initialize gridview
	self.gridview = playdate.ui.gridview.new(27, 27)
	self.gridview:setNumberOfColumns(8)
	self.gridview:setNumberOfRows(8)
	self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
	self.gridview:setContentInset(6, 6, 6, 6)

	-- sprite that holds image
	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
	self.gridviewSprite:moveTo(0, 0)
	-- self.gridviewSprite:moveTo(17, 0)
	self.gridviewSprite:add()

	function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
		gfx.pushContext()
			-- draw the background square color
			if (row + column) % 2 == 0 then
				-- gfx.setColor(gfx.kColorClear)
				gfx.setColor(gfx.kColorWhite)
			else
				-- gfx.setColor(gfx.kColorBlack)
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
				local pieceImage = imageCache:getPieceImage(piece)
				if pieceImage then
					pieceImage:draw(x-2, y-2)
				end
				-- local piecePath = PIECES_IMG_PATHS[piece]
				-- if cachedPieceImages[piecePath] then
				-- 	cachedPieceImages[piecePath]:draw(x + 1, y + 1)
				-- end
			end
		gfx.popContext()
	end

	self:addBoard(newBoard)
	gfx.pushContext()
		gfx.setFont(gfx.font.new("fonts/Mini Mono"))
		self:drawFiles()
		self:drawRanks()
	gfx.popContext()
	print("Board Grid View: grid view initialized")
end

function BoardGridView:drawGridView()
	-- print("drawGridView()")
	local gridviewImage = gfx.image.new(BOARD_WIDTH+2*BORDER_X_THICKNESS+2, BOARD_WIDTH+BORDER_Y_THICKNESS)
	gfx.pushContext(gridviewImage)
		-- draw border
		gfx.drawRect(BORDER_OFFSET, 0, BOARD_WIDTH+2*BORDER_X_THICKNESS-1, BOARD_WIDTH+BORDER_Y_THICKNESS)
		-- draw chess board
		self.gridview:drawInRect(BORDER_OFFSET+BORDER_X_THICKNESS, 0, BOARD_WIDTH, BOARD_WIDTH)
		self.gridviewSprite:setImage(gridviewImage)
	gfx.popContext()
end

function BoardGridView:createTextSprite(text, x, y)
	gfx.pushContext()
		-- gfx.setImageDrawMode(gfx.kDrawModeInverted) -- draw text white instead of black
		local textSprite = gfx.sprite.spriteWithText(text, 20, 20)
		textSprite:moveTo(x, y)
		textSprite:add()
	gfx.popContext()
end

function BoardGridView:drawFiles()
	local files = { "a", "b", "c", "d", "e", "f", "g", "h" }
	for i = 1, #files do
		self:createTextSprite(files[i], 7 + i * 27, 232)
	end
end

function BoardGridView:drawRanks()
	local j = 8
	for i = 1, 8, 1 do
		self:createTextSprite(tostring(i), 11, j * 27 - 4)
		j -= 1
	end
end

function BoardGridView:addBoard(newBoard)
	table.insert(boards, newBoard)
	boardIdx += 1
	self:drawGridView()
end

function BoardGridView:removeBoard()
	if boardIdx == 0 then
		return
	end
	boardIdx -= 1
	table.remove(boards)
	self:drawGridView()
end

function BoardGridView:getVisibleBoard()
	if boardIdx == 0 then
		return nil
	end
	return boards[boardIdx]
end

function BoardGridView:previousPosition()
	boardIdx -= 1
	if boardIdx == 0 then
		boardIdx = 1
	end
	self:drawGridView()
end

function BoardGridView:nextPosition()
	boardIdx += 1
	if boardIdx >= #boards then
		boardIdx = #boards
	end
	self:drawGridView()
end

function BoardGridView:needsDisplay()
	return self.gridview.needsDisplay
end

function BoardGridView:clickCell()
	local _, r, c = self.gridview:getSelection()
	local position = FILES[c] .. tostring(9 - r)
	local piece = getPieceAt(boards[boardIdx], r, c)
	table.insert(clicked, { r, c, position, piece })
	local move = clicked[#clicked - 1][3] .. clicked[#clicked][3]
	print("Board Grid View: move: " .. move)
	self:drawGridView()
	return clicked[#clicked - 1][3], clicked[#clicked][3]
end

function BoardGridView:selectNextRow(select)
	self.gridview:selectNextRow(select)
	self:drawGridView()
end

function BoardGridView:selectPreviousRow(select)
	self.gridview:selectPreviousRow(select)
	self:drawGridView()
end

function BoardGridView:selectNextColumn(select)
	self.gridview:selectNextColumn(select)
	self:drawGridView()
end

function BoardGridView:selectPreviousColumn(select)
	self.gridview:selectPreviousColumn(select)
	self:drawGridView()
end

-- clear saved boards and tiles clicked
function BoardGridView:clearGameData()
	boards = {}
	boardIdx = 0
	clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
end
