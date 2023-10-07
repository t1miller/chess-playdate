
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local PIECES_IMG_PATHS <const> = {
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
local cachedPieceImages = {}

class('ImageCache').extends(gfx.sprite)

function ImageCache:init()
	ImageCache.super.init(self)
end

function ImageCache:getPieceImage(piece)
    local pieceImagePath = PIECES_IMG_PATHS[piece]
    if pieceImagePath ~= nil then
        return cachedPieceImages[pieceImagePath]
    end
    print("Image Cache: piece does not exist")
    return nil
end

local function cachePieceImages()
	for _, pieceImagePath in pairs(PIECES_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedPieceImages[pieceImagePath] = pieceImage
	end
end

cachePieceImages()


