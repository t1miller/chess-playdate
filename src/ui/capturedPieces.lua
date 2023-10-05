import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"


local gfx <const> = playdate.graphics

class('CapturePieces').extends(gfx.sprite)

function CapturePieces:init()
	CapturePieces.super.init(self)

end	