import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/ImageCache'
import 'helper/Utils'

local gfx <const> = playdate.graphics
local DEBUG <const> = true

class('CapturedPieces').extends()

function CapturedPieces:init(x, y)
	CapturedPieces.super.init(self)
	self.x = x
	self.y = y
	self.imageCache = ImageCache()
	self.font = gfx.font.new("fonts/Roobert-11-Bold")
	self.pieceSprites =  {["p"] = {},["P"] = {},["n"] = {},["N"] = {},["b"] = {},["B"] = {},["r"] = {},["R"] = {},["q"] = {},["Q"] = {},["k"] = {},["K"] = {},}
	self.missingPieces = {["p"] = 0,["P"] = 0,["n"] = 0,["N"] = 0,["b"] = 0,["B"] = 0,["r"] = 0,["R"] = 0,["q"] = 0,["Q"] = 0,["k"] = 0,["K"] = 0,}
	self.blackPieces =   {["p"] = 0,["n"] = 0,["b"] = 0,["r"] = 0,["q"] = 0,}
	self.pieceValues =   {["p"] = 1,["P"] = 1,["n"] = 3,["N"] = 3,["b"] = 3,["B"] = 3,["r"] = 5,["R"] = 5,["q"] = 9,["Q"] = 9,}
	self.textSpriteBlack = nil
	self.textSpriteWhite = nil

	self:drawScores()
end

function CapturedPieces:clearPieceSprites()
	for piece, sprites in pairs(self.pieceSprites) do
		for j = 1, #sprites do
			sprites[j]:remove()
			sprites[j]:update()
			print("clearPieceSprites() removing: "..piece)
		end
	end

	printTable(self.pieceSprites)
end

function CapturedPieces:clear()
	self:clearPieceSprites()
	self.missingPieces = {["p"] = 0,["P"] = 0,["n"] = 0,["N"] = 0,["b"] = 0,["B"] = 0,["r"] = 0,["R"] = 0,["q"] = 0,["Q"] = 0,["k"] = 0,["K"] = 0,}
	self:drawScores()
end

function CapturedPieces:createPieceSprite(piece)
	printDebug("CapturedPieces: createPieceSprite()", DEBUG)
	-- create sprite
	local pieceImage = self.imageCache:getPieceImage(piece)
	local pieceSprite = gfx.sprite.new(pieceImage)

	-- add to sprite table
	table.insert(self.pieceSprites[piece],  pieceSprite)
end

function CapturedPieces:addPieces(missingPieces)
	printDebug("CapturedPieces: addPieces()", DEBUG)
	-- print("addPieces() comparing")
	-- printTable(self.missingPieces)
	-- print()
	-- printTable(missingPieces)
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
			self:createPieceSprite(missingPiece)
			print("createMissingSprites() creating sprite:"..missingPiece)
			spriteCount += 1
		end
	end
end

function CapturedPieces:drawPieces()
	printDebug("CapturedPieces: drawPieces()", DEBUG)

	-- draw blacks capture pieces, the white pieces
	local xOffset = 45
	local yOffset = 12
	local numberOfPiecesDrawn = 0
	local pieceOrder = {"P","N","B","R","Q"}
	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, self.missingPieces[pieceOrder[i]] do
			sprites[j]:add()
			sprites[j]:moveTo(self.x + xOffset, self.y + yOffset)
			xOffset += 12
			numberOfPiecesDrawn += 1

			-- first row filled, draw second row
			if numberOfPiecesDrawn == 8 then
				yOffset += 26
				xOffset = 10
			end
		end
	end

	-- draw whites captured pieces, the black pieces
	yOffset = 226
	xOffset = 45
	numberOfPiecesDrawn = 0
	pieceOrder = {"p","n","b","r","q"}
	for i = 1, #pieceOrder do
		local sprites = self.pieceSprites[pieceOrder[i]]
		for j = 1, self.missingPieces[pieceOrder[i]] do
			sprites[j]:add()
			sprites[j]:moveTo(self.x + xOffset, self.y + yOffset)
			xOffset += 12
			numberOfPiecesDrawn += 1

			-- first row filled, draw second row
			if numberOfPiecesDrawn == 8 then
				yOffset -= 22
				xOffset = 10
			end
		end
	end

	printDebug("CapturedPieces: drawPieces() drawing", DEBUG)
end

function CapturedPieces:drawScores()
	printDebug("CapturedPieces: drawScores()", DEBUG)
	local whitesScore, blacksScore = self:calculateScores()
	local whitesScoreString = "+"..whitesScore
	local blacksScoreString = "+"..blacksScore

	if self.textSpriteBlack ~= nil then
		self.textSpriteBlack:remove()
		self.textSpriteBlack:update()
		-- self.textSpriteBlack = nil
	end
	
	if self.textSpriteWhite ~= nil then
		self.textSpriteWhite:remove()
		self.textSpriteWhite:update()
		-- self.textSpriteWhite = nil
	end

	-- draw blacks score
	self.textSpriteBlack = gfx.sprite.spriteWithText(blacksScoreString, 75, 25, nil, nil, nil, kTextAlignment.left, self.font)
	self.textSpriteBlack:setCenter(0,0)
	self.textSpriteBlack:moveTo(self.x + 2, self.y + 2)
	self.textSpriteBlack:add()

	-- draw whites score
	self.textSpriteWhite = gfx.sprite.spriteWithText(whitesScoreString, 75, 25, nil, nil, nil, kTextAlignment.left, self.font)
	self.textSpriteWhite:setCenter(0,0)
	self.textSpriteWhite:moveTo(self.x + 2, self.y + 220)
	self.textSpriteWhite:add()
		
	printDebug("CapturedPieces: drawScore() drawing", DEBUG)
end


-- add up the the score of the pieces you took
-- and subtract the score of what your opponent took
-- return abs(score, 0)
function CapturedPieces:calculateScores()
	printDebug("CapturedPieces: calculateScores()", DEBUG)
	local whitesScore = 0
	local blacksScore = 0
	for piece,count in pairs(self.missingPieces) do
		if count > 0 then
			if self.blackPieces[piece] then
				whitesScore += self.pieceValues[piece] * count
			else
				blacksScore += self.pieceValues[piece] * count
			end
		end
	end

	-- add extra queens
	if self.missingPieces["Q"] ~= nil and self.missingPieces["Q"] < 0 then
		whitesScore += self.pieceValues["Q"] * math.abs(self.missingPieces["Q"])
	end
	if self.missingPieces["q"] ~= nil and self.missingPieces["q"] < 0 then
		blacksScore += self.pieceValues["q"] * math.abs(self.missingPieces["q"])
	end

	local tmp = whitesScore
	whitesScore = whitesScore - blacksScore
	blacksScore = blacksScore - tmp

	whitesScore = iif(whitesScore > 0, whitesScore, 0)
	blacksScore = iif(blacksScore > 0, blacksScore, 0)

	printDebug("CapturedPieces: calculateScores() blacksScore = "..blacksScore.." whitesScore = "..whitesScore, DEBUG)
	return whitesScore, blacksScore
end

