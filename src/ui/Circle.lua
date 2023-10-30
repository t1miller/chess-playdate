import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = false
CIRCLE_TYPE = {
    BORDER = "0",
    FILLED = "1"
}

class('Circle').extends(gfx.sprite)

function Circle:init(x, y, z, width, height, rectType, color, alpha, dither)
    Circle.super.init(self)

    self.z = z
    self.width = width
    self.height = height
    self.rectType = rectType
    self.color = color or gfx.kColorClear
    self.alpha = alpha or .5
    self.dither = dither or gfx.image.kDitherTypeNone

    self:setSize(width, height)
    self:moveTo(x, y)
    self:setZIndex(z)
    self:add()
end

function Circle:setColor(color)
    self.color = color
end

function Circle:setDither(alpha, dither)
    self.alpha = alpha
    self.dither = dither
end

function Circle:draw()
    printDebug("Circle: draw() ", DEBUG)
    gfx.pushContext()
        gfx.setColor(self.color)
        if self.dither ~= gfx.image.kDitherTypeNone then
            gfx.setDitherPattern(self.alpha, self.dither)
        end
        if self.rectType == CIRCLE_TYPE.FILLED then
            gfx.fillCircleInRect(0, 0, self.width, self.height)
        elseif self.rectType == CIRCLE_TYPE.BORDER then
            gfx.drawCircleInRect(0, 0, self.width, self.height)
        end
    gfx.popContext()
end