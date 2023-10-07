import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'ui/imageCache'

local gfx <const> = playdate.graphics
local WIDTH <const> = 130
local HEIGHT <const> = 70
local imageCache = ImageCache()
-- local PIECE_VALUE <const> = {
-- 	["p"] = 1,
-- 	["P"] = 1,
-- 	["n"] = 3,
-- 	["N"] = 3,
-- 	["b"] = 3,
-- 	["B"] = 3,
-- 	["r"] = 5,
-- 	["R"] = 5,
-- 	["q"] = 9,
-- 	["Q"] = 9,
-- }

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
end

function CapturedPieces:clear()
	for piece, sprites in pairs(self.pieceSprites) do
		for j = 1, #sprites do
			sprites[j]:remove()
		end
	end
end

function CapturedPieces:createPieceSprite(piece)
	-- create sprite
	local pieceImage = imageCache:getPieceImage(piece)
	local pieceSprite = gfx.sprite.new(pieceImage)

	-- add to sprite table
	table.insert(self.pieceSprites[piece],  pieceSprite)
end

function CapturedPieces:addPieces(missingPieces)
	self:clear()
	self:createMissingSprites(missingPieces)
	self:draw(missingPieces)
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

function CapturedPieces:draw(missingPieces)
	local xOffset = 0
	local yOffset = 0
	local drawCount = 0
	local pieceOrder =  {"P","N","B","R","Q"}
	if self.isWhite then
		pieceOrder = {"p","n","b","r","q"}
	end

	print()
	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, missingPieces[pieceOrder[i]] do
			sprites[j]:add()
			sprites[j]:moveTo(self.x + xOffset, self.y + yOffset)
			xOffset += 23
			drawCount += 1

			-- draw on the next row
			if drawCount == 6 or drawCount == 12 then
				yOffset += 24
				xOffset = 0
			end
		end
	end
end

-- function CapturedPieces:calculateScore()
-- 	local score = 0
-- 	for i = 1, #self.pieces do
-- 		local piece = self.pieces[i]
-- 		score += PIECE_VALUE[piece]
-- 	end
-- 	return score
-- end

