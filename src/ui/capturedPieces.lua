import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'ui/imageCache'

local gfx <const> = playdate.graphics
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
	self.textSprite = nil
	self:drawScore({})
end

function CapturedPieces:clear()
	for piece, sprites in pairs(self.pieceSprites) do
		for j = 1, #sprites do
			sprites[j]:remove()
		end
	end
	self:drawScore({})
end

function CapturedPieces:createPieceSprite(piece)
	-- create sprite
	local pieceImage = imageCache:getLargePieceImage(piece)
	local pieceSprite = gfx.sprite.new(pieceImage)

	-- add to sprite table
	table.insert(self.pieceSprites[piece],  pieceSprite)
end

function CapturedPieces:addPieces(missingPieces)
	self:clear()
	self:createMissingSprites(missingPieces)
	self:drawPieces(missingPieces)
	self:drawScore(missingPieces)
end

function CapturedPieces:createMissingSprites(missingPieces)
	for missingPiece, missingPieceCount in pairs(missingPieces) do
		-- keep creating sprite for piece until it matches missing count
		local spriteCount = #self.pieceSprites[missingPiece]

		while spriteCount < missingPieceCount do
			self:createPieceSprite(missingPiece)
			spriteCount += 1
		end
	end
end

function CapturedPieces:drawPieces(missingPieces)
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
		for j = 1, missingPieces[pieceOrder[i]] do
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
end

function CapturedPieces:drawScore(missingPieces)
	-- draw score
	local score = self:calculateScore(missingPieces)
	local scoreString = string.format("+%.1f",score)
	if self.textSprite ~= nil then
		self.textSprite:remove()
		self.textSprite = nil
	end
	gfx.pushContext()
		-- gfx.setFont(gfx.font.new("fonts/Mini Mono 2X"))
		-- [backgroundColor, [leadingAdjustment, [truncationString, [alignment, [font]]]]]
		-- gfx.setFont(gfx.font.new("fonts/Roobert-10-Bold"))
		self.textSprite = gfx.sprite.spriteWithText(scoreString, 150, 25, nil, nil, nil, kTextAlignment.left, gfx.font.new("fonts/Roobert-10-Bold"))
		self.textSprite:setCenter(0,0)
		self.textSprite:moveTo(self.x-10, self.y-9)
		self.textSprite:add()
	gfx.popContext()
end


-- add up the the score of the pieces you took
-- and subtract the score of what your opponent took
-- return abs(score, 0)
function CapturedPieces:calculateScore(missingPieces)
	local whitesScore = 0.0
	local blacksScore = 0.0
	for piece,count in pairs(missingPieces) do
		if count > 0 then
			if BLACK_PIECES[piece] then
				whitesScore += PIECE_VALUE[piece] * count
			else
				blacksScore += PIECE_VALUE[piece] * count
			end
		end
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

