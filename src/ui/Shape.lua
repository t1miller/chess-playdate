import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = false

SHAPE_TYPE = {
    RECT_NOT_FILLED = 0,
    RECT_FILLED = 1,
    CIRCLE_NOT_FILLED = 2,
    CIRCLE_FILLED = 3
}

class('Shape').extends(gfx.sprite)

function Shape:init(x, y, z, width, height, shapeType, color, alpha, dither)
    Shape.super.init(self)

    self.z = z
    self.width = width
    self.height = height
    self.shapeType = shapeType
    self.color = color or gfx.kColorClear
    self.alpha = alpha or .5
    self.dither = dither or gfx.image.kDitherTypeNone

    self:setSize(width, height)
    self:setCenter(0,0)
    self:moveTo(x, y)
    self:setZIndex(z)
    self:add()
end

function Shape:setColor(color)
    self.color = color
end

function Shape:setDither(alpha, dither)
    self.alpha = alpha
    self.dither = dither
end

function Shape:draw()
    printDebug("Shape: draw() ", DEBUG)
    gfx.pushContext()
        -- set shape color
        gfx.setColor(self.color)

        -- set shape dither
        if self.dither ~= gfx.image.kDitherTypeNone then
            gfx.setDitherPattern(self.alpha, self.dither)
        end

        -- draw shape
        if self.shapeType == SHAPE_TYPE.RECT_FILLED then
            gfx.fillRect(0, 0, self.width, self.height)
        elseif self.shapeType == SHAPE_TYPE.RECT_NOT_FILLED then
            gfx.setLineWidth(self.borderThickness)
            gfx.drawRect(0, 0, self.width, self.height)
        elseif self.shapeType == SHAPE_TYPE.CIRCLE_FILLED then
            gfx.fillCircleInRect(0, 0, self.width, self.height)
        elseif self.shapeType == SHAPE_TYPE.CIRCLE_NOT_FILLED then
            gfx.drawCircleInRect(0, 0, self.width, self.height)
        end
    gfx.popContext()
end