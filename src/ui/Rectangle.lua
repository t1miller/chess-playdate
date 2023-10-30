import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = false
RECT_TYPE = {
    BORDER = "0",
    FILLED = "1"
}

class('Rectangle').extends(gfx.sprite)

function Rectangle:init(x, y, z, width, height, rectType, color, alpha, dither)
    Rectangle.super.init(self)

    self.z = z
    self.width = width
    self.height = height
    self.rectType = rectType
    self.color = color or gfx.kColorClear
    self.alpha = alpha or .5
    self.dither = dither or gfx.image.kDitherTypeNone

    self:setSize(width, height)
    self:setCenter(0,0)
    self:moveTo(x, y)
    self:setZIndex(z)
    self:add()
end

function Rectangle:setColor(color)
    self.color = color
end

function Rectangle:setDither(alpha, dither)
    self.alpha = alpha
    self.dither = dither
end

function Rectangle:draw()
    printDebug("Rectangle: draw() ", DEBUG)
    gfx.pushContext()
        gfx.setColor(self.color)
        if self.rectType == RECT_TYPE.FILLED then
            if self.dither ~= gfx.image.kDitherTypeNone then
                gfx.setDitherPattern(self.alpha, self.dither)
            end
            gfx.fillRect(0, 0, self.width, self.height)
        elseif self.rectType == RECT_TYPE.BORDER then
            gfx.setLineWidth(self.borderThickness)
            gfx.drawRect(0, 0, self.width, self.height)
        end
    gfx.popContext()
end