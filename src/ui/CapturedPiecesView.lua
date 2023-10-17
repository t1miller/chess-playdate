import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'ui/ImageCache'
import 'Utils'

local gfx <const> = playdate.graphics
local DEBUG <const> = false
local SCORE_FONT <const> = gfx.font.new("fonts/Roobert-11-Bold")
local BLACK_PIECES = {
	["p"] = 0,
	["n"] = 0,
	["b"] = 0,
	["r"] = 0,
	["q"] = 0,
}
local imageCache = ImageCache()
local PIECE_VALUE <const> = {
	["p"] = 1,
	["P"] = 1,
	["n"] = 3,
	["N"] = 3,
	["b"] = 3,
	["B"] = 3,
	["r"] = 5,
	["R"] = 5,
	["q"] = 9,
	["Q"] = 9,
}

class('CapturedPieces').extends()

function CapturedPieces:init(x, y, isWhite)
	CapturedPieces.super.init(self)
	self.x = x
	self.y = y
	self.isWhite = isWhite
	self.pieceSprites = {
		["p"] = {},
		["P"] = {},
		["n"] = {},
		["N"] = {},
		["b"] = {},
		["B"] = {},
		["r"] = {},
		["R"] = {},
		["q"] = {},
		["Q"] = {},
		["k"] = {},
		["K"] = {},
	}
	self.score = -1.0 --force drawing of initial score
	self.missingPieces = {
        ["p"] = 0,
        ["P"] = 0,
        ["n"] = 0,
        ["N"] = 0,
        ["b"] = 0,
        ["B"] = 0,
        ["r"] = 0,
        ["R"] = 0,
        ["q"] = 0,
        ["Q"] = 0,
        ["k"] = 0,
        ["K"] = 0,
	}
	self.textSprite = nil
	self:drawScore({})
end

function CapturedPieces:clearPieceSprites()
	for piece, sprites in pairs(self.pieceSprites) do
		for j = 1, #sprites do
			sprites[j]:remove()
		end
	end
	-- self.score = 0.0
	-- self:drawScore({})
end

function CapturedPieces:clear()
	self:clearPieceSprites()
	self.score = -1.0
	self.missingPieces = {
        ["p"] = 0,
        ["P"] = 0,
        ["n"] = 0,
        ["N"] = 0,
        ["b"] = 0,
        ["B"] = 0,
        ["r"] = 0,
        ["R"] = 0,
        ["q"] = 0,
        ["Q"] = 0,
        ["k"] = 0,
        ["K"] = 0,
	}
	self:drawScore()
end

function CapturedPieces:createPieceSprite(piece)
	printDebug("CapturedPieces: createPieceSprite()", DEBUG)
	-- create sprite
	local pieceImage = imageCache:getPieceImage(piece)
	local pieceSprite = gfx.sprite.new(pieceImage)

	-- add to sprite table
	table.insert(self.pieceSprites[piece],  pieceSprite)
end

function CapturedPieces:addPieces(missingPieces)
	printDebug("CapturedPieces: addPieces()", DEBUG)
	if deepcompare(self.missingPieces, missingPieces, false) == false then
		self.missingPieces = missingPieces
		self:clearPieceSprites()
		self:createMissingSprites()
		self:drawPieces()
		self:drawScore()
	end
end

function CapturedPieces:createMissingSprites()
	printDebug("CapturedPieces: createMissingSprites()", DEBUG)
	for missingPiece, missingPieceCount in pairs(self.missingPieces) do
		-- keep creating sprite for piece until it matches missing count
		local spriteCount = #self.pieceSprites[missingPiece]

		while spriteCount < missingPieceCount do
			self:createPieceSprite(missingPiece)
			spriteCount += 1
		end
	end
end

function CapturedPieces:drawPieces()
	printDebug("CapturedPieces: drawPieces()", DEBUG)
	local xOffset = 0
	local yOffset = 20
	local drawCount = 0
	local pieceOrder = {"P","N","B","R","Q"}
	if self.isWhite then
		pieceOrder = {"p","n","b","r","q"}
		yOffset = -24
	end

	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, self.missingPieces[pieceOrder[i]] do
			sprites[j]:add()
			sprites[j]:moveTo(self.x + xOffset, self.y + yOffset)
			xOffset += 12
			drawCount += 1

			-- draw on the next row
			if drawCount == 10 then
				if self.isWhite then
					yOffset -= 24 
				else
					yOffset += 24
				end
				xOffset = 0
			end
		end
	end
	printDebug("CapturedPieces: drawPieces() drawing", DEBUG)
end

function CapturedPieces:drawScore()
	printDebug("CapturedPieces: drawScore()", DEBUG)
	local score = self:calculateScore()
	if self.score == score then
		printDebug("CapturedPieces: drawScore() not drawing", DEBUG)
		return
	end
	self.score = score

	local scoreString = string.format("+%.0f",score)
	if self.textSprite ~= nil then
		self.textSprite:remove()
		self.textSprite = nil
	end

	gfx.pushContext()
		self.textSprite = gfx.sprite.spriteWithText(scoreString, 150, 25, nil, nil, nil, kTextAlignment.left, SCORE_FONT)
		self.textSprite:setCenter(0,0)
		self.textSprite:moveTo(self.x-10, self.y-12)
		self.textSprite:add()
	gfx.popContext()
	printDebug("CapturedPieces: drawScore() drawing", DEBUG)
end


-- add up the the score of the pieces you took
-- and subtract the score of what your opponent took
-- return abs(score, 0)
function CapturedPieces:calculateScore()
	printDebug("CapturedPieces: calculateScore()", DEBUG)
	local whitesScore = 0.0
	local blacksScore = 0.0
	for piece,count in pairs(self.missingPieces) do
		if count > 0 then
			if BLACK_PIECES[piece] then
				whitesScore += PIECE_VALUE[piece] * count
			else
				blacksScore += PIECE_VALUE[piece] * count
			end
		end
	end

	-- add extra queens
	if self.missingPieces["Q"] ~= nil and self.missingPieces["Q"] < 0 then
		whitesScore += PIECE_VALUE["Q"] * math.abs(self.missingPieces["Q"])
	end
	if self.missingPieces["q"] ~= nil and self.missingPieces["q"] < 0 then
		blacksScore += PIECE_VALUE["q"] * math.abs(self.missingPieces["q"])
	end

	local score = 0.0
	if self.isWhite then
		score = whitesScore - blacksScore
		if score < 0 then
			return 0.0
		else
			return score
		end
	else
		score = blacksScore - whitesScore
		if score < 0 then
			return 0.0
		else
			return score
		end
	end
end

