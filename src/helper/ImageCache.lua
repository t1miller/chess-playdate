
import "CoreLibs/graphics"
import 'library/AnimatedSprite'

local gfx <const> = playdate.graphics
local DEBUG <const> = false
local PIECE_IMG_PATHS <const> = {
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

local cachedImages = {}

class('ImageCache').extends(gfx.sprite)

function ImageCache:init()
	ImageCache.super.init(self)
end

function ImageCache:getPieceImage(piece)
    local pieceImagePath = PIECE_IMG_PATHS[piece]
    if pieceImagePath ~= nil then
        return cachedImages[pieceImagePath]
    end
    printDebug("ImageCache: piece does not exist", DEBUG)
    return nil
end

local function cacheImages()
	printDebug("ImageCache: caching", DEBUG)
	-- cache piece images
	for _, pieceImagePath in pairs(PIECE_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedImages[pieceImagePath] = pieceImage
	end

	printDebug("ImageCache: done caching", DEBUG)
end

cacheImages()
