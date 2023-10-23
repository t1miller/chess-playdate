
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

local PIECE_IMG_NO_BORDER_PATHS <const> = {
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

local ANIMATION_IMG_PATHS = {
	["robot-kick"] = "animation/robot-kick",
	["robot-shakehands"] = "animation/robot-shakehands",
	["stickman-kick"] = "animation/stickman-kick",
	["stickman-shakehands"] = "animation/stickman-shakehands",
	["robot-progress"] = "animation/robot-progress-inverted"
}

local ANIMATION_CONFIG_PATHS = {
	["robot-progress-config"] = "animation/progress.json",
	["kick-config"] = "animation/kick.json",
	["shakehands-config"] = "animation/shakehands.json",
}

local cachedResources = {}

class('ResourceCache').extends(gfx.sprite)

function ResourceCache:init()
	ResourceCache.super.init(self)
end

function ResourceCache:getPieceImage(piece)
    local pieceImagePath = PIECE_IMG_PATHS[piece]
    if pieceImagePath ~= nil then
        return cachedResources[pieceImagePath]
    end
    printDebug("ResourceCache: piece does not exist", DEBUG)
    return nil
end

function ResourceCache:getAnimationImage(animation)
    local animationPath = ANIMATION_IMG_PATHS[animation]
    if animationPath ~= nil then
        return cachedResources[animationPath]
    end
    printDebug("ResourceCache: animation does not exist", DEBUG)
    return nil
end

function ResourceCache:getAnimationConfig(config)
    local configPath = ANIMATION_CONFIG_PATHS[config]
    if configPath ~= nil then
        return cachedResources[configPath]
    end
    printDebug("ResourceCache: animation config file does not exist", DEBUG)
    return nil
end

local function cacheResources()
	printDebug("ResourceCache: caching", DEBUG)
	-- cache piece images
	for _, pieceImagePath in pairs(PIECE_IMG_PATHS) do
		local pieceImage = gfx.image.new(pieceImagePath)
		cachedResources[pieceImagePath] = pieceImage
	end

	-- cache animation imagetables
	for _, animationPath in pairs(ANIMATION_IMG_PATHS) do
		local animationImages = gfx.imagetable.new(animationPath)
		cachedResources[animationPath] = animationImages
	end

	-- cache animation config files
	for _, configPath in pairs(ANIMATION_CONFIG_PATHS) do
		local configFile = AnimatedSprite.loadStates(configPath)
		cachedResources[configPath] = configFile
	end
	
	printDebug("ResourceCache: done caching", DEBUG)
end

cacheResources()
