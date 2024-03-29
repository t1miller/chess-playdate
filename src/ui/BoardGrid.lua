import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"

import 'engine/sunfish' -- for help highlighting squares piece can move to

import 'helper/Utils'
import 'helper/ImageCache'
import 'ui/Shape'
import 'ui/Piece'

local gfx <const> = playdate.graphics
local img <const> = gfx.image
local DEBUG <const> = false
local WOOD_BACKGROUND_Z <const> = -1000
local BORDERS_Z <const> = -990
local BOARD_SQUARES_Z <const> = -980
local CLICKED_SQUARE_Z <const> = -970
local PIECE_IMAGE_Z <const> = -960
local SELECT_SQUARE_Z <const> = -965
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
---------------
----Boards-----
---------------
-- user white board
-- rnbqkbnr\n
-- pppppppp\n
-- ........\n
-- ........\n
-- ........\n
-- ........\n
-- PPPPPPPP\n
-- RNBQKBNR\n
--
-- user black board
-- RNBQKBNR\n
-- PPPPPPPP\n
-- ........\n
-- ........\n
-- ........\n
-- ........\n
-- pppppppp\n
-- rnbqkbnr\n
class('BoardGrid').extends()

local selfself = nil
function BoardGrid:init(isUserWhite)
	BoardGrid.super.init(self)

	selfself = self
	self.isUserWhite = isUserWhite
	self.clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
	self.emptySquare = "."
	self.piecesSprites = {
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
		{{},{},{},{},{},{},{},{}},
	}
	self.rankAndFileSprites = {}
	self.buttonTimer = nil
	self.isReverseDirection = false
	self.boardList = {}
	self.boardListIdx = 0
	self.moveList  = {}
	self.availableMoves = {}
	self.availableMovesSprites = {}
	self.animationDoneCallback = nil
	self.selectedSquareSprite = Shape(-50, -50, SELECT_SQUARE_Z, 25, 25, SHAPE_TYPE.RECT_FILLED, nil, .5, img.kDitherTypeBayer8x8)
	self.clickedSquareSprite =  Shape(0, 0, CLICKED_SQUARE_Z, 27, 27, SHAPE_TYPE.RECT_FILLED)
	self.rankAndFileFont =  gfx.font.new("fonts/Roobert-10-Bold")
	self.borderOffset = 2
	self.boardWidth = 228
	self.borderXThickness = 12

	-- initialize gridview
	self.gridview = playdate.ui.gridview.new(27, 27)
	self.gridview:setNumberOfColumns(8)
	self.gridview:setNumberOfRows(8)
	self.gridview:setContentInset(6, 6, 6, 6)
	self.gridview.drawCell = self.drawCell
	self.gridview.changeRowOnColumnWrap = false

	self:drawWoodBackground()
	self:drawBoardBorders()
	self:drawBoardSquares()
	self:drawFiles()
	self:drawRanks()

	self:setupInputHandler()
end

function BoardGrid:addMove(move, callback)
	printDebug("BoardGrid: move added to the list",DEBUG)
	table.insert(self.moveList, move)
	self.animationDoneCallback = callback
end

function BoardGrid:addBoard(newBoard)
	table.insert(self.boardList, newBoard)
	self.boardListIdx += 1
	self:drawBoardGrid()
end

function BoardGrid:removeBoard()
	if self.boardListIdx <= 1 then
		return
	end
	self.isReverseDirection = true
	self.boardListIdx -= 1
	table.remove(self.boardList)
	-- the movelist needs the old move to do the animation
	-- after done drawing the move can be removed
	self:drawBoardGrid()
	table.remove(self.moveList)
end

function BoardGrid:setBoardToActivePos()
	if self.boardListIdx == #self.boardList then
		return
	end

	self.boardListIdx = #self.boardList
	self:drawBoardGrid()
end

function BoardGrid:getVisibleBoard()
	if self.boardListIdx == 0 then
		return nil
	end
	return self.boardList[self.boardListIdx]
end

function BoardGrid:previousPosition()
	printDebug("BaordGrid: previous positon idx="..self.boardListIdx, DEBUG)
	if self.boardListIdx > 1 then
		self.boardListIdx -= 1
		self.isReverseDirection = true
		self:drawBoardGrid()
	end
end

function BoardGrid:nextPosition()
	printDebug("BaordGrid: next positon idx="..self.boardListIdx, DEBUG)
	if self.boardListIdx < #self.boardList then
		self.boardListIdx += 1
		self.isReverseDirection = false
		self:drawBoardGrid()
	end
end

function BoardGrid:isLightSquare(row, col)
	return (row + col) % 2 == 0
end

function BoardGrid:getPieceAt(row, col)
	local idx = (row - 1) * 9 + col
	local piece = string.sub(self.boardList[self.boardListIdx], idx, idx)
	return piece
end

-- todo change this to support white and black
function BoardGrid:clickCell()
	printDebug("BoardGrid: clickCell()", DEBUG)
	local _, r, c = self.gridview:getSelection()
	local piece = self:getPieceAt(r, c)
	local position = iif(self.isUserWhite, FILES[c] .. tostring(9 - r),  FILES[9-c] .. tostring(r))

	self.clicked[1] = self.clicked[2]
	self.clicked[2] =  { r, c, position, piece }
	if self.clicked[1][3] ~= self.clicked[2][3] then
		printDebug("BoardGrid: clickCell() drawing", DEBUG)
		self:drawBoardGrid()
	end
	self:drawAvailableMoves(FILES[c] .. tostring(9 - r))
	return self.clicked[1][3], self.clicked[2][3]
end

function BoardGrid:startButtonTimer(callbackToRepeat)
	if self.buttonTimer then
		self.buttonTimer:remove()
		self.buttonTimer = nil
	end
	self.buttonTimer = playdate.timer.keyRepeatTimer(callbackToRepeat)
end

function BoardGrid:stopButtonTimer()
	if self.buttonTimer then
		self.buttonTimer:remove()
		self.buttonTimer = nil
	end
end

function BoardGrid:setupInputHandler()
	self.boardGridInputHandler = {

		leftButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectPreviousColumn(true)
				self:drawBoardGrid()
			end)
		end,

		leftButtonUp = function ()
			self:stopButtonTimer()
		end,

		rightButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectNextColumn(true)
				self:drawBoardGrid()
			end)
		end,

		rightButtonUp = function ()
			self:stopButtonTimer()
		end,

		downButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectNextRow(true)
				self:drawBoardGrid()
			end)
		end,

		downButtonUp = function ()
			self:stopButtonTimer()
		end,

		upButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectPreviousRow(true)
				self:drawBoardGrid()
			end)
		end,

		upButtonUp = function ()
			self:stopButtonTimer()
		end,
	}
	playdate.inputHandlers.push(self.boardGridInputHandler)
end

function BoardGrid:drawCell(section, row, column, selected, x, y, width, height)

	-- add background to selected cell
	if selected then
		selfself:drawHighlightedCell(row, column, x, y)
	end

	-- add background to clicked cell
	if selfself.clicked[#selfself.clicked][1] == row and selfself.clicked[#selfself.clicked][2] == column then
		selfself:drawClickedCell(row, column, x, y)
	end

	-- draw piece image
	if selfself.boardListIdx ~= 0 then
		-- if boardListIdx == 0, theres no board to draw yet
		-- this happens when the game is loading and the user
		-- starts clicking buttons
		selfself:drawPieceSprite(row, column)
		return
	end
end

function BoardGrid:changeColor(isUserWhite)
	self.isUserWhite = isUserWhite
	self:clearRankAndFiles()
	self:drawRanks()
	self:drawFiles()
end

function BoardGrid:clearRankAndFiles()
	for i=1, #self.rankAndFileSprites do
		self.rankAndFileSprites[i]:remove()
	end
	self.rankAndFileSprites = {}
end

-- clear saved boards and tiles clicked
function BoardGrid:clear()
	self.boardList = {}
	self.boardListIdx = 0
	self.moveList = {}
	self.clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
	self:clearAvailableMoves()
end

function BoardGrid:drawBoardGrid()
	self.gridview:drawInRect(self.borderOffset+self.borderXThickness, 0, self.boardWidth, self.boardWidth)
end

function BoardGrid:drawClickedCell(row, column, x, y)
	if self:isLightSquare(row, column) then
		self.clickedSquareSprite:setColor(gfx.kColorBlack)
		self.clickedSquareSprite:setDither(.2, img.kDitherTypeBayer8x8)
	else
		self.clickedSquareSprite:setColor(gfx.kColorWhite)
		self.clickedSquareSprite:setDither(.6, img.kDitherTypeBayer8x8)
	end
	self.clickedSquareSprite:moveTo(x,y)
end

function BoardGrid:drawHighlightedCell(row, column, x, y)
	if self:isLightSquare(row, column) then
		self.selectedSquareSprite:setColor(gfx.kColorBlack)
	else
		self.selectedSquareSprite:setColor(gfx.kColorWhite)
	end
	self.selectedSquareSprite:moveTo(x+1, y+1)
end

function BoardGrid:clearAvailableMoves()
	for i=1, #self.availableMovesSprites do
		self.availableMovesSprites[i]:remove()
	end
	self.availableMovesSprites = {}
end

function BoardGrid:drawAvailableMoves(position)
	self.availableMoves = {}
	self.availableMoves = getMoveOptions(self.isUserWhite, position, self.boardList[self.boardListIdx])

	self:clearAvailableMoves()

	for key, _ in pairs(self.availableMoves) do
		local rowCol = splitString(key,",")
		local r = tonumber(rowCol[1])
		local c = tonumber(rowCol[2])
		local x, y = self:calculateXYfromRowCol(r, c)

		local circleSprite
		if self:getPieceAt(r, c) == '.' then
			if self:isLightSquare(r, c) then
				circleSprite = Shape(x+12, y+12, BOARD_SQUARES_Z, 7, 7, SHAPE_TYPE.CIRCLE_FILLED, gfx.kColorBlack, .5, img.kDitherTypeBayer8x8)
			else
				circleSprite = Shape(x+12, y+12, BOARD_SQUARES_Z, 7, 7, SHAPE_TYPE.CIRCLE_FILLED, gfx.kColorWhite, .5, img.kDitherTypeBayer8x8)
			end
		else
			if self:isLightSquare(r, c) then
				circleSprite = Shape(x+3, y+3, BOARD_SQUARES_Z, 25, 25, SHAPE_TYPE.CIRCLE_NOT_FILLED, gfx.kColorBlack)
			else
				circleSprite = Shape(x+3, y+3, BOARD_SQUARES_Z, 25, 25, SHAPE_TYPE.CIRCLE_NOT_FILLED, gfx.kColorWhite)
			end
		end

		table.insert(self.availableMovesSprites, circleSprite)
	end
end

function BoardGrid:drawText(text, x, y)
	local textSprite = gfx.sprite.spriteWithText(text, 20, 20, nil, nil, nil, nil, self.rankAndFileFont)
	textSprite:moveTo(x, y)
	textSprite:add()
	return textSprite
end

function BoardGrid:drawFiles()
	printDebug("BoardGrid: drawFiles()", DEBUG)
	for i = 1, #FILES do
		local textSprite
		if self.isUserWhite then
			textSprite = self:drawText(FILES[i], 7 + i * 27, 230)
		else
			textSprite = self:drawText(FILES[i], 7 + (9-i) * 27, 230)
		end
		table.insert(self.rankAndFileSprites, textSprite)
	end
end

function BoardGrid:drawRanks()
	printDebug("BoardGrid: drawRanks()", DEBUG)
	for i = 1, 8 do
		local textSprite
		if self.isUserWhite then
			textSprite = self:drawText(tostring(i), 11, (9-i) * 27 - 6)
		else
			textSprite = self:drawText(tostring(i), 11, i * 27 - 6)
		end
		table.insert(self.rankAndFileSprites, textSprite)
	end
end

function BoardGrid:drawBoardBorders()
	printDebug("BoardGrid: drawBoardBorders()", DEBUG)
	local outerBoardImage = img.new(self.boardWidth+25, self.boardWidth+10)
	gfx.pushContext(outerBoardImage)
		gfx.setLineWidth(4)
		gfx.drawRect(0, 0, self.boardWidth+25, self.boardWidth+10)
	gfx.popContext()
	local outerBorder = gfx.sprite.new(outerBoardImage)
	outerBorder:setCenter(0, 0)
	outerBorder:setZIndex(BORDERS_Z)
	outerBorder:moveTo(self.borderOffset, 0)
	outerBorder:add()

	local innerBoardImage = img.new(self.boardWidth-8, self.boardWidth-8)
	gfx.pushContext(innerBoardImage)
		gfx.setLineWidth(4)
		gfx.drawRect(0, 0, self.boardWidth-8, self.boardWidth-8)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(2, 2, self.boardWidth-12, self.boardWidth-12)
	gfx.popContext()
	local innerBorder = gfx.sprite.new(innerBoardImage)
	innerBorder:setCenter(0, 0)
	innerBorder:setZIndex(BORDERS_Z)
	innerBorder:moveTo(18, 4)
	innerBorder:add()
end

function BoardGrid:drawWoodBackground()
	printDebug("BoardGrid: drawWoodBackground()", DEBUG)
	local backgroundImg = img.new("images/wood")
	backgroundImg = backgroundImg:fadedImage(.5, img.kDitherTypeFloydSteinberg)
	self.backgroundSprite = gfx.sprite.new(backgroundImg)
	self.backgroundSprite:setCenter(0, 0)
	self.backgroundSprite:setZIndex(WOOD_BACKGROUND_Z)
	self.backgroundSprite:moveTo(self.borderOffset, 0)
	self.backgroundSprite:add()
end

function BoardGrid:drawBoardSquares()
	printDebug("BoardGrid: drawBoardSquares()", DEBUG)
	for r = 1, 8 do
		for c = 1,8 do
			if self:isLightSquare(r, c) then
				Shape(20 + (r-1)*27, 6 + (c-1)*27, BOARD_SQUARES_Z, 27, 27, SHAPE_TYPE.RECT_FILLED, gfx.kColorWhite)
			else
				Shape(20 + (r-1)*27, 6 + (c-1)*27, BOARD_SQUARES_Z, 27, 27, SHAPE_TYPE.RECT_FILLED, gfx.kColorBlack)
			end
		end
	end
end

function BoardGrid:drawPieceSprite(r, c)
	local pieceChar = self:getPieceAt(r, c)

	-- same piece already drawn at this location
	if self.piecesSprites[r][c][2] == pieceChar then
		return
	end

	-- new piece at this location is different than the existing piece
	if self.piecesSprites[r][c][1] ~= nil then
		self.piecesSprites[r][c][1]:remove()
		self.piecesSprites[r][c][2] = self.emptySquare
	end

	-- nothing to draw
	if pieceChar == self.emptySquare then
		return
	end

	self.piecesSprites[r][c] = {Piece(0, 0, PIECE_IMAGE_Z, pieceChar), pieceChar}
	local newX, newY = self:calculateXYfromRowCol(r, c)

	-- this is a new game, draw all the pieces w/out animation
	if #self.moveList == 0 then
		self.piecesSprites[r][c][1]:moveTo(newX, newY)
		return
	end

	local oldX, oldY = self:calculatePieceOldXY()
	self.piecesSprites[r][c][1]:animate(oldX, oldY, newX, newY, self.animationDoneCallback)
	self.animationDoneCallback = nil
end

function BoardGrid:calculatePieceOldXY()
	local oldRow, oldColumn = 0,0
	if self.isReverseDirection == false and self.moveList[self.boardListIdx-1] then
		oldRow = self.moveList[self.boardListIdx-1][1]
		oldColumn = self.moveList[self.boardListIdx-1][2]
	elseif self.moveList[self.boardListIdx] then
		oldRow = self.moveList[self.boardListIdx][3]
		oldColumn = self.moveList[self.boardListIdx][4]
	end
	self.isReverseDirection = false
	return self:calculateXYfromRowCol(oldRow, oldColumn)
end

function BoardGrid:calculateXYfromRowCol(r,c)
	return 18 + (c-1)*27, 4 + (r-1)*27
end

function BoardGrid:removePieceSprite(r, c)
	if self.piecesSprites[r][c][1] ~= nil then
		self.piecesSprites[r][c][1]:remove()
	end
end

function BoardGrid:toSavedTable()
	return {
		boardList = self.boardList,
		boardListIdx = #self.boardList,
		moveList = self.moveList
	}
end

function BoardGrid:initFromSavedTable(data)
	self.boardList = data["boardList"]
	self.boardListIdx = data["boardListIdx"]
	self.moveList = data["moveList"]
	self:drawBoardGrid()
end
