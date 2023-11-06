import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/Utils'
import 'ui/Piece'

local gfx <const> = playdate.graphics
local abs <const> = math.abs
local DEBUG <const> = true
local BLACK_PIECES =   {["p"] = 0,["n"] = 0,["b"] = 0,["r"] = 0,["q"] = 0,}
local WHITE_PIECES =   {["P"] = 0,["N"] = 0,["B"] = 0,["R"] = 0,["Q"] = 0,}
local PIECE_VALUES =   {["p"] = 1,["P"] = 1,["n"] = 3,["N"] = 3,["b"] = 3,["B"] = 3,["r"] = 5,["R"] = 5,["q"] = 9,["Q"] = 9,}

class('CapturedPieces').extends()

function CapturedPieces:init(isUserWhite,x, y)
	CapturedPieces.super.init(self)
	self.isUserWhite = isUserWhite
	self.x = x
	self.y = y
	self.z = 0
	self.font = gfx.font.new("fonts/Roobert-11-Bold")
	self.pieceSprites =  {["p"] = {},["P"] = {},["n"] = {},["N"] = {},["b"] = {},["B"] = {},["r"] = {},["R"] = {},["q"] = {},["Q"] = {},["k"] = {},["K"] = {},}
	self.missingPieces = {["p"] = 0,["P"] = 0,["n"] = 0,["N"] = 0,["b"] = 0,["B"] = 0,["r"] = 0,["R"] = 0,["q"] = 0,["Q"] = 0,["k"] = 0,["K"] = 0,}
	self.textSpriteBlack = nil
	self.textSpriteWhite = nil
	self.prevBlackScore = -1
	self.prevWhiteScore = -1

	self:drawScores()
end

function CapturedPieces:clearPieceSprites()
	for _, sprites in pairs(self.pieceSprites) do
		for j = 1, #sprites do
			sprites[j]:remove()
		end
	end
	self.z = 0
end

function CapturedPieces:clear()
	self:clearPieceSprites()
	self.missingPieces = {["p"] = 0,["P"] = 0,["n"] = 0,["N"] = 0,["b"] = 0,["B"] = 0,["r"] = 0,["R"] = 0,["q"] = 0,["Q"] = 0,["k"] = 0,["K"] = 0,}
	self.prevBlackScore = -1
	self.prevWhiteScore = -1
	self:drawScores()
end

function CapturedPieces:changeColor(isUserWhite)
	self.isUserWhite = isUserWhite
end

function CapturedPieces:addPieces(missingPieces)
	printDebug("CapturedPieces: addPieces()", DEBUG)
	if deepcompare(self.missingPieces, missingPieces, false) == false then
		self.missingPieces = missingPieces
		self:clearPieceSprites()
		self:createMissingSprites()
		self:drawPieces()
		self:drawScores()
	end
end

function CapturedPieces:createMissingSprites()
	printDebug("CapturedPieces: createMissingSprites()", DEBUG)
	for missingPiece, missingPieceCount in pairs(self.missingPieces) do
		-- keep creating sprite for piece until it matches missing count
		local spriteCount = #self.pieceSprites[missingPiece]
		while spriteCount < missingPieceCount do
			table.insert(self.pieceSprites[missingPiece],  Piece(0,0,0,missingPiece))
			spriteCount += 1
		end
	end
end

function CapturedPieces:drawPieces()
	printDebug("CapturedPieces: drawPieces()", DEBUG)

	local whiteXOffset, whiteYOffset, whiteYincrement, blackXOffset, blackYOffset, blackYincrement
	if self.isUserWhite then
		whiteXOffset = 30
		whiteYOffset = -3
		whiteYincrement = 26
		blackXOffset = 30
		blackYOffset = 211
		blackYincrement = -22
	else
		whiteXOffset = 30
		whiteYOffset = 211
		whiteYincrement = -22
		blackXOffset = 30
		blackYOffset = -3
		blackYincrement = 26
	end

	-- draw blacks capture pieces, the white pieces
	-- local xOffset = 30
	-- local yOffset = -3
	local numberOfPiecesDrawn = 0
	local pieceOrder = {"P","N","B","R","Q"}
	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, self.missingPieces[pieceOrder[i]] do
			sprites[j]:setZIndex(self.z)
			sprites[j]:moveTo(self.x + whiteXOffset, self.y + whiteYOffset)
			sprites[j]:add()
			whiteXOffset += 12
			numberOfPiecesDrawn += 1
			self.z += 1
			-- first row filled, draw second row
			if numberOfPiecesDrawn == 8 then
				whiteYOffset += whiteYincrement
				whiteYOffset = -3
			end
		end
	end

	-- draw whites captured pieces, the black pieces
	-- xOffset = 30
	-- yOffset = 211
	numberOfPiecesDrawn = 0
	pieceOrder = {"p","n","b","r","q"}
	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, self.missingPieces[pieceOrder[i]] do
			sprites[j]:setZIndex(self.z)
			sprites[j]:moveTo(self.x + blackXOffset, self.y + blackYOffset)
			sprites[j]:add()
			blackXOffset += 12
			numberOfPiecesDrawn += 1
			self.z += 1

			-- first row filled, draw second row
			if numberOfPiecesDrawn == 8 then
				blackYOffset += blackYincrement
				blackXOffset = -3
			end
		end
	end
end

function CapturedPieces:drawScores()
	printDebug("CapturedPieces: drawScores()", DEBUG)
	local whitesScore, blacksScore = self:calculateScores()

	local whiteScoreYOffset, blackScoreYOffset
	if self.isUserWhite then
		whiteScoreYOffset = 220
		blackScoreYOffset = 2
	else
		whiteScoreYOffset = 2
		blackScoreYOffset = 220
	end

	if whiteScore ~= self.prevWhiteScore then
		local whitesScoreString = "+"..whitesScore

		if self.textSpriteWhite ~= nil then
			self.textSpriteWhite:remove()
			-- self.textSpriteWhite:update()
			-- self.textSpriteWhite = nil
		end

		-- draw whites score
		self.textSpriteWhite = gfx.sprite.spriteWithText(whitesScoreString, 75, 25, nil, nil, nil, kTextAlignment.left, self.font)
		self.textSpriteWhite:setCenter(0,0)
		self.textSpriteWhite:moveTo(self.x + 2, self.y + whiteScoreYOffset)
		self.textSpriteWhite:add()

		self.prevWhiteScore = whitesScore
		printDebug("CapturedPieces: drawScore() whiteScore drawing, score="..whitesScoreString, DEBUG)
	end

	if blacksScore ~= self.prevBlackScore then
		local blacksScoreString = "+"..blacksScore

		if self.textSpriteBlack ~= nil then
			self.textSpriteBlack:remove()
			-- self.textSpriteBlack:update()
			-- self.textSpriteBlack = nil
		end

		-- draw blacks score
		self.textSpriteBlack = gfx.sprite.spriteWithText(blacksScoreString, 75, 25, nil, nil, nil, kTextAlignment.left, self.font)
		self.textSpriteBlack:setCenter(0,0)
		self.textSpriteBlack:moveTo(self.x + 2, self.y + blackScoreYOffset)
		self.textSpriteBlack:add()
	
		self.prevBlackScore = blacksScore
		printDebug("CapturedPieces: drawScore() blackScore drawing, score="..blacksScoreString, DEBUG)
	end
end


-- add up the the score of the pieces you took
-- and subtract the score of what your opponent took
function CapturedPieces:calculateScores()
	local whitesScore = 0
	local blacksScore = 0
	for piece,count in pairs(self.missingPieces) do
		if count > 0 then
			if BLACK_PIECES[piece] then
				whitesScore += PIECE_VALUES[piece] * count
			elseif WHITE_PIECES[piece] then
				blacksScore += PIECE_VALUES[piece] * count
			end
		end
	end

	-- add extra queens
	if self.missingPieces["Q"] ~= nil and self.missingPieces["Q"] < 0 then
		whitesScore += PIECE_VALUES["Q"] * abs(self.missingPieces["Q"])
	end
	if self.missingPieces["q"] ~= nil and self.missingPieces["q"] < 0 then
		blacksScore += PIECE_VALUES["q"] * abs(self.missingPieces["q"])
	end

	local tmp = whitesScore
	whitesScore = whitesScore - blacksScore
	blacksScore = blacksScore - tmp

	whitesScore = iif(whitesScore > 0, whitesScore, 0)
	blacksScore = iif(blacksScore > 0, blacksScore, 0)

	printDebug("CapturedPieces: calculateScores() blacksScore = "..blacksScore.." whitesScore = "..whitesScore, DEBUG)
	return whitesScore, blacksScore
end

