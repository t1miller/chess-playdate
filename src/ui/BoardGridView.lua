import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import 'CoreLibs/animator'

import 'helper/Utils'
import 'helper/ImageCache'
import 'ui/RectangleView'

local geo = playdate.geometry
local gfx <const> = playdate.graphics
local Animator <const> = gfx.animator
local img <const> = gfx.image
local DEBUG <const> = true
local TESTING <const> = false
local WOOD_BACKGROUND_Z <const> = -1000
local BORDERS_Z <const> = -990
local BOARD_SQUARES_Z <const> = -980
local CLICKED_SQUARE_Z <const> = -970
local PIECE_IMAGE_Z <const> = -960
local SELECT_SQUARE_Z <const> = -965

-- Board Representation
-- rnbqkbnr\n
-- pppppppp\n
-- ........\n
-- ........\n
-- ........\n
-- ........\n
-- PPPPPPPP\n
-- RNBQKBNR\n
class('BoardGridView').extends()

local selfself = nil
function BoardGridView:init(newBoard)
	BoardGridView.super.init(self)

	selfself = self

	self.imageCache = ImageCache()
	self.isWhite = true
	-- r, c, position, piece
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
	self.files = {
		[1] = "a",
		[2] = "b",
		[3] = "c",
		[4] = "d",
		[5] = "e",
		[6] = "f",
		[7] = "g",
		[8] = "h",
	}
	self.buttonTimer = nil
	self.isReverseDirection = false
	self.boardList = {}
	self.boardListIdx = 0
	self.moveList  = {}
	self.animationDoneCallback = false
	self.selectedSquareSprite = Rectangle(-50, -50, SELECT_SQUARE_Z, 25, 25, RECT_TYPE.FILLED, nil, .5, img.kDitherTypeBayer8x8)
	self.clickedSquareSprite =  Rectangle(0, 0, CLICKED_SQUARE_Z, 27, 27, RECT_TYPE.FILLED)
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

	-- self:addBoard(newBoard)
end

function BoardGridView:addMove(move, callback)
	printDebug("BoardGridView: move added to the list",DEBUG)
	table.insert(self.moveList, move)
	self.animationDoneCallback = callback
end

function BoardGridView:addBoard(newBoard)
	table.insert(self.boardList, newBoard)
	self.boardListIdx += 1
	self:draw()
end

function BoardGridView:removeBoard()
	if self.boardListIdx == 0 then
		return
	end
	self.isReverseDirection = true
	self.boardListIdx -= 1
	table.remove(self.boardList)
	-- the movelist needs the old move to do the animation
	-- after done drawing the move can be removed
	self:draw()
	table.remove(self.moveList)
end

function BoardGridView:setBoardToActivePos()
	if self.boardListIdx == #self.boardList then
		return
	end

	self.boardListIdx = #self.boardList
	-- self.isReverseDirection = false
	self:draw()
end

function BoardGridView:getVisibleBoard()
	if self.boardListIdx == 0 then
		return nil
	end
	return self.boardList[self.boardListIdx]
end

function BoardGridView:previousPosition()
	if self.boardListIdx == 1 then
		return
	end
	self.boardListIdx -= 1
	if self.boardListIdx == 0 then
		self.boardListIdx = 1
	end

	self.isReverseDirection = true
	self:draw()
end

function BoardGridView:nextPosition()
	self.boardListIdx += 1
	if self.boardListIdx >= #self.boardList then
		self.boardListIdx = #self.boardList
	end

	self.isReverseDirection = false
	self:draw()
end

function BoardGridView:isLightSquare(row, col)
	local remainder = iif(self.isWhite, 0, 1)
	return (row + col) % 2 == remainder
end

function BoardGridView:getPieceAt(row, col)
	local idx = (row - 1) * 9 + col
	local piece = string.sub(self.boardList[self.boardListIdx], idx, idx)
	return piece
end

function BoardGridView:clickCell()
	printDebug("BoardGridView: clickCell()", DEBUG)
	local _, r, c = self.gridview:getSelection()
	local position = self.files[c] .. tostring(9 - r)
	local piece = self:getPieceAt(r, c)
	self.clicked[1] = self.clicked[2]
	self.clicked[2] =  { r, c, position, piece }
	if self.clicked[1][3] ~= self.clicked[2][3] then
		printDebug("BoardGridView: clickCell() drawing", DEBUG)
		self:draw()
	else
		printDebug("BoardGridView: clickCell() not drawing", DEBUG)
	end
	return self.clicked[1][3], self.clicked[2][3]
end

function BoardGridView:startButtonTimer(callbackToRepeat)
	if self.buttonTimer then
		self.buttonTimer:remove()
		self.buttonTimer = nil
	end
	self.buttonTimer = playdate.timer.keyRepeatTimerWithDelay(200, 80, callbackToRepeat)
end

function BoardGridView:stopButtonTimer()
	if self.buttonTimer then
		self.buttonTimer:remove()
		self.buttonTimer = nil
	end
end

function BoardGridView:setupInputHandler()
	self.boardGridInputHandler = {

		leftButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectPreviousColumn(true)
				self:draw()
			end)
		end,

		leftButtonUp = function ()
			self:stopButtonTimer()
		end,

		rightButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectNextColumn(true)
				self:draw()
			end)
		end,

		rightButtonUp = function ()
			self:stopButtonTimer()
		end,

		downButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectNextRow(true)
				self:draw()
			end)
		end,

		downButtonUp = function ()
			self:stopButtonTimer()
		end,

		upButtonDown = function ()
			self:startButtonTimer(function ()
				self.gridview:selectPreviousRow(true)
				self:draw()
			end)
		end,

		upButtonUp = function ()
			self:stopButtonTimer()
		end,
	}
	playdate.inputHandlers.push(self.boardGridInputHandler)
end

function BoardGridView:drawCell(section, row, column, selected, x, y, width, height)
	gfx.pushContext()

		-- add background to selected cell
		if selected then
			if selfself:isLightSquare(row, column) then
				selfself.selectedSquareSprite:setColor(gfx.kColorBlack)
			else
				selfself.selectedSquareSprite:setColor(gfx.kColorWhite)
			end
			selfself.selectedSquareSprite:moveTo(x+1, y+1)
		end

		-- add background to clicked cell
		if selfself.clicked[#selfself.clicked][1] == row and selfself.clicked[#selfself.clicked][2] == column then
			if selfself:isLightSquare(row, column) then
				selfself.clickedSquareSprite:setColor(gfx.kColorBlack)
				selfself.clickedSquareSprite:setDither(.2, img.kDitherTypeBayer8x8)
			else
				selfself.clickedSquareSprite:setColor(gfx.kColorWhite)
				selfself.clickedSquareSprite:setDither(.6, img.kDitherTypeBayer8x8)
			end
			selfself.clickedSquareSprite:moveTo(x,y)
		end

		-- draw piece image
		if selfself.boardListIdx ~= 0 then
			-- if boardListIdx == 0, theres no board to draw yet
			-- this happens when the game is loading and the user
			-- starts clicking buttons
			selfself:drawPieceSprite(row, column)
			return
		end

	gfx.popContext()
end

-- clear saved boards and tiles clicked
function BoardGridView:clear()
	self.boardList = {}
	self.boardListIdx = 0
	self.moveList = {}
	self.clicked = {
		{ -1, -1, "", "" },
		{ -1, -1, "", "" }
	}
	-- self.isReverseDirection = false
end

function BoardGridView:draw()
	self.gridview:drawInRect(self.borderOffset+self.borderXThickness, 0, self.boardWidth, self.boardWidth)
end

function BoardGridView:drawText(text, x, y)
	gfx.pushContext()
		gfx.setFont(self.rankAndFileFont)
		local textSprite = gfx.sprite.spriteWithText(text, 20, 20)
		textSprite:moveTo(x, y)
		textSprite:add()
	gfx.popContext()
end

function BoardGridView:drawFiles()
	printDebug("BoardGridView: drawFiles()", DEBUG)
	local files = { "a", "b", "c", "d", "e", "f", "g", "h" }
	for i = 1, #files do
		self:drawText(files[i], 7 + i * 27, 230)
	end
end

function BoardGridView:drawRanks()
	printDebug("BoardGridView: drawRanks()", DEBUG)
	local j = 8
	for i = 1, 8, 1 do
		self:drawText(tostring(i), 11, j * 27 - 6)
		j -= 1
	end
end

function BoardGridView:drawBoardBorders()
	printDebug("BoardGridView: drawBoardBorders()", DEBUG)
	local outerBoardImage = img.new(self.boardWidth+25, self.boardWidth+10)
	gfx.pushContext(outerBoardImage)
		gfx.setDitherPattern(img.kDitherTypeNone)
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
		gfx.setDitherPattern(img.kDitherTypeNone)
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

function BoardGridView:drawWoodBackground()
	printDebug("BoardGridView: drawWoodBackground()", DEBUG)
	local backgroundImg = img.new("images/wood")
	backgroundImg = backgroundImg:fadedImage(.5, img.kDitherTypeFloydSteinberg)
	self.backgroundSprite = gfx.sprite.new(backgroundImg)
	self.backgroundSprite:setCenter(0, 0)
	self.backgroundSprite:setZIndex(WOOD_BACKGROUND_Z)
	self.backgroundSprite:moveTo(self.borderOffset, 0)
	self.backgroundSprite:add()
end

function BoardGridView:drawBoardSquares()
	printDebug("BoardGridView: drawBoardSquares()", DEBUG)
	for r = 1, 8 do
		for c = 1,8 do
			if self:isLightSquare(r, c) then
				Rectangle(20 + (r-1)*27, 6 + (c-1)*27, BOARD_SQUARES_Z, 27, 27, RECT_TYPE.FILLED, gfx.kColorWhite)
			else
				Rectangle(20 + (r-1)*27, 6 + (c-1)*27, BOARD_SQUARES_Z, 27, 27, RECT_TYPE.FILLED, gfx.kColorBlack)
			end
		end
	end
end

-- if sprite at r, c is the same piece then do nothing
-- if sprite at r, c is different remove sprite and draw new sprite
function BoardGridView:drawPieceSprite(r, c)
	
	local piece = self:getPieceAt(r, c)

	if self.piecesSprites[r][c][2] == piece then
		-- same piece already drawn at this board position
		return
	elseif self.piecesSprites[r][c][1] ~= nil then
		-- new piece is different than the existing piece
		self.piecesSprites[r][c][1]:remove()
		printDebug("BoardGridView: removing piece "..self.piecesSprites[r][c][2].." at r="..r.." c="..c, DEBUG)
		self.piecesSprites[r][c][2] = self.emptySquare
	end
	local pieceImage = self.imageCache:getPieceImage(piece)
	if pieceImage then
		self.piecesSprites[r][c] = {gfx.sprite.new(), piece}
		self.piecesSprites[r][c][1]:setImage(pieceImage)
		self.piecesSprites[r][c][1]:setCenter(0, 0)
		self.piecesSprites[r][c][1]:setZIndex(PIECE_IMAGE_Z)
		self.piecesSprites[r][c][1]:add()

		local newX, newY = self:calculateXYfromRowCol(r, c)

		if #self.moveList == 0 then
			-- this is a new game, draw all the pieces
			-- w/out animation
			self.piecesSprites[r][c][1]:moveTo(newX, newY)
			return
		end

		-- todo remove this eventually
		local oldX, oldY = 0,0
		if TESTING == false then
			oldX, oldY = self:calculatePieceOldXY()
		end
		-- if oldX == newX and oldY == newY then
		-- 	self.piecesSprites[r][c][1]:moveTo(newX, newY)
		-- 	return
		-- end

		------------------- Animation -----------------------------------
		local line = geo.lineSegment.new(oldX, oldY, newX, newY)
		local animator = Animator.new(200, line, playdate.easingFunctions.linear, 0)
		
		printDebug("BoardGridView: animating piece: "..self.piecesSprites[r][c][2].." oldX:"..oldX.." oldY:"..oldY.." newX:"..newX.." newY:"..newY)
		local pieceSprite = self.piecesSprites[r][c][1]
		local selfself = self
		local animationDoneCount = 0
		function pieceSprite:update()

			if animator:ended() then
				animationDoneCount += 1
			end

			if animationDoneCount > 2 then
				if selfself.animationDoneCallback then
					printDebug("BoardGridView: calling animation done callback: ", DEBUG)
					selfself:animationDoneCallback()
					selfself.animationDoneCallback = nil
				end
				pieceSprite:setUpdatesEnabled(false)
				animationDoneCount += 1
			end
		end

		self.piecesSprites[r][c][1]:setAnimator(animator)
	end
end

function BoardGridView:calculatePieceOldXY()
	local oldRow, oldColumn = 0,0
	printDebug("BoardGridView: indexing movelist: boardIdx="..self.boardListIdx.." movelist of length="..#self.moveList, DEBUG)

	if self.isReverseDirection == false then
		oldRow = self.moveList[self.boardListIdx-1][1]
		oldColumn = self.moveList[self.boardListIdx-1][2]
	else
		oldRow = self.moveList[self.boardListIdx][3]
		oldColumn = self.moveList[self.boardListIdx][4]
	end
	self.isReverseDirection = false
	printDebug("BoardGridView: from: oldRow:"..oldRow.." oldCol:"..oldColumn, DEBUG)
	return self:calculateXYfromRowCol(oldRow, oldColumn)
end

function BoardGridView:calculateXYfromRowCol(r,c)
	return 18 + (c-1)*27, 4 + (r-1)*27
end

function BoardGridView:removePieceSprite(r, c)
	if self.piecesSprites[r][c][1] ~= nil then
		self.piecesSprites[r][c][1]:remove()
	end
end

function BoardGridView:toSavedTable()
	return {
		boardList = self.boardList,
		boardListIdx = #self.boardList,
		moveList = self.moveList
	}
end

function BoardGridView:initFromSavedTable(data)
	self.boardList = data["boardList"]
	self.boardListIdx = data["boardListIdx"]
	self.moveList = data["moveList"]
	self:draw()
end