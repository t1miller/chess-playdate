import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import 'ui/imageCache'
import 'ui/rectangle'

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
local img <const> = playdate.graphics.image
local BOARD_WIDTH <const> = 228
local BORDER_OFFSET <const> = 2
local BORDER_X_THICKNESS <const> = 12

local imageCache = ImageCache()
local boards = {}
local boardIdx = 0
local clicked = {
	{ -1, -1, "", "" },
	{ -1, -1, "", "" }
}
local borderSprite = nil


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

	borderSprite = Rectangle(0, 0, 25, 25, RECT_TYPE.FILLED, nil, img.kDitherTypeBayer8x8)

	-- initialize gridview
	self.gridview = playdate.ui.gridview.new(27, 27)
	self.gridview:setNumberOfColumns(8)
	self.gridview:setNumberOfRows(8)
	-- self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
	self.gridview:setContentInset(6, 6, 6, 6)

	-- sprite that holds image
	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
	self.gridviewSprite:moveTo(0, 0)
	self.gridviewSprite:add()

	-- sprite that is board background
	local backgroundImg = img.new("images/wood3")
	backgroundImg = backgroundImg:fadedImage(.5, img.kDitherTypeFloydSteinberg)
	self.backgroundSprite = gfx.sprite.new(backgroundImg)
	self.backgroundSprite:setCenter(0, 0)
	self.backgroundSprite:setZIndex(-1000)
	self.backgroundSprite:moveTo(BORDER_OFFSET, 0)
	self.backgroundSprite:add()

	function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
		gfx.pushContext()
			-- draw the board squares
			if (row + column) % 2 == 0 then
				gfx.setColor(gfx.kColorWhite)
			else
				gfx.setColor(gfx.kColorBlack)
			end
			gfx.fillRect(x, y, width, height)

			-- add background to selected cell
			if selected then
				if (row + column) % 2 == 0 then
					borderSprite:setColor(gfx.kColorBlack)
				else
					borderSprite:setColor(gfx.kColorWhite)
				end
				borderSprite:moveTo(x+1, y+1)
			end

			-- add background to clicked cell
			if clicked[#clicked][1] == row and clicked[#clicked][2] == column then
				if (row + column) % 2 == 0 then
					gfx.setColor(gfx.kColorBlack)
					gfx.setDitherPattern(.2, img.kDitherTypeBayer8x8)
				else
					gfx.setColor(gfx.kColorWhite)
					gfx.setDitherPattern(.6, img.kDitherTypeBayer8x8)
				end
				gfx.fillRect(x, y, width, height)
			end

			-- add hints to possible moves piece can make

			-- draw piece image
			if boards[boardIdx] then
				local piece = getPieceAt(boards[boardIdx], row, column)
				local pieceImage = imageCache:getLargePieceImage(piece)
				if pieceImage then
					pieceImage:draw(x-2, y-2)
				end
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

function BoardGridView:draw()
	-- print("draw()")
	local gridviewImage = img.new(BOARD_WIDTH+28, BOARD_WIDTH+12)
	gfx.pushContext(gridviewImage)
		-- draw outer border
		gfx.setLineWidth(2)
		gfx.drawRect(BORDER_OFFSET, 0, BOARD_WIDTH+25, BOARD_WIDTH+10)

		-- draw inner border
		gfx.setLineWidth(2)
		gfx.drawRect(19, 5, BOARD_WIDTH - 10, BOARD_WIDTH - 10)

		-- draw chess board
		self.gridview:drawInRect(BORDER_OFFSET+BORDER_X_THICKNESS, 0, BOARD_WIDTH, BOARD_WIDTH)
		self.gridviewSprite:setImage(gridviewImage)
	gfx.popContext()
end

function BoardGridView:drawText(text, x, y)
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
		self:drawText(files[i], 7 + i * 27, 232)
	end
end

function BoardGridView:drawRanks()
	local j = 8
	for i = 1, 8, 1 do
		self:drawText(tostring(i), 11, j * 27 - 4)
		j -= 1
	end
end

function BoardGridView:addBoard(newBoard)
	table.insert(boards, newBoard)
	boardIdx += 1
	self:draw()
end

function BoardGridView:removeBoard()
	if boardIdx == 0 then
		return
	end
	boardIdx -= 1
	table.remove(boards)
	self:draw()
end

function BoardGridView:setBoardToActivePos()
	if boardIdx == #boards then return end
	boardIdx = #boards
	self:draw()
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
	self:draw()
end

function BoardGridView:nextPosition()
	boardIdx += 1
	if boardIdx >= #boards then
		boardIdx = #boards
	end
	self:draw()
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
	self:draw()
	return clicked[#clicked - 1][3], clicked[#clicked][3]
end

function BoardGridView:selectNextRow(select)
	self.gridview:selectNextRow(select)
	self:draw()
end

function BoardGridView:selectPreviousRow(select)
	self.gridview:selectPreviousRow(select)
	self:draw()
end

function BoardGridView:selectNextColumn(select)
	self.gridview:selectNextColumn(select)
	self:draw()
end

function BoardGridView:selectPreviousColumn(select)
	self.gridview:selectPreviousColumn(select)
	self:draw()
end

-- clear saved boards and tiles clicked
function BoardGridView:clear()
	boards = {}
	boardIdx = 0
	clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
end
