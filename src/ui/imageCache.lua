
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local LARGE_PIECE_IMG_PATHS <const> = {
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
local SMALL_PIECE_IMG_PATHS <const> = {
	[" "] = "",
	["."] = "",
	["p"] = "images/small_pawn1",
	["P"] = "images/small_pawn",
	["b"] = "images/small_bishop1",
	["B"] = "images/small_bishop",
	["n"] = "images/small_knight1",
	["N"] = "images/small_knight",
	["r"] = "images/small_rook1",
	["R"] = "images/small_rook",
	["k"] = "images/small_king1",
	["K"] = "images/small_king",
	["q"] = "images/small_queen1",
	["Q"] = "images/small_queen"
}
local cachedPieceImages = {}

class('ImageCache').extends(gfx.sprite)

function ImageCache:init()
	ImageCache.super.init(self)
end

function ImageCache:getLargePieceImage(piece)
    local pieceImagePath = LARGE_PIECE_IMG_PATHS[piece]
    if pieceImagePath ~= nil then
        return cachedPieceImages[pieceImagePath]
    end
    print("Image Cache: piece does not exist")
    return nil
end

function ImageCache:getSmallPieceImage(piece)
    local pieceImagePath = SMALL_PIECE_IMG_PATHS[piece]
    if pieceImagePath ~= nil then
        return cachedPieceImages[pieceImagePath]
    end
    print("Image Cache: piece does not exist")
    return nil
end

local function cachePieceImages()
	print("ImageCache: caching images")
	for _, pieceImagePath in pairs(LARGE_PIECE_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedPieceImages[pieceImagePath] = pieceImage
	end

	for _, pieceImagePath in pairs(SMALL_PIECE_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedPieceImages[pieceImagePath] = pieceImage
	end
	print("ImageCache: done caching images")
end

cachePieceImages()


