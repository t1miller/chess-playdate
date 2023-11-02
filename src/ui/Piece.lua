import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import 'CoreLibs/animator'

import 'helper/ImageCache'

local geo = playdate.geometry
local gfx<const> = playdate.graphics
local Animator <const> = gfx.animator

local DEBUG <const> = true

class('Piece').extends(gfx.sprite)

function Piece:init(x, y, z, pieceChar)
    Piece.super.init(self)

    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.pieceChar = pieceChar
    self.imageCache = ImageCache()
    
    local pieceImage = self.imageCache:getPieceImage(self.pieceChar)
    if pieceImage then
        self:setImage(pieceImage)
        self:setCenter(0,0)
        self:setZIndex(self.z)
        self:add()
    end
end

function Piece:update()

    if self.animator then
        -- animation ended() is called to early in the 
        -- SDK, the animation is done 2 frames after SDK says done
        if self.animator:ended() then
            self.animationDoneCount += 1
        end

        if self.animationDoneCount > 2 then
            if self.animationDoneCallback then
                self.animationDoneCallback()
                self.animationDoneCallback = nil
                printDebug("Piece: called animation done callback: ", DEBUG)
            end
            self:setUpdatesEnabled(false)
        end
    end

end

function Piece:animate(fromX, fromY, toX, toY, animationDoneCallback)
    local line = geo.lineSegment.new(fromX, fromY, toX, toY)
    self.animator = Animator.new(200, line, playdate.easingFunctions.linear, 0)
    self.animationDoneCallback = animationDoneCallback
    self.animationDoneCount = 0
    self:setAnimator(self.animator)
    printDebug("Piece: animating piece: "..self.pieceChar.." fronX:"..fromX.." fromY:"..fromY.." toX:"..toX.." toY:"..toY, DEBUG)
end
