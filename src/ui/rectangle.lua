import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics
RECT_TYPE = {
    BORDER = "0",
    FILLED = "1"
}

class('Rectangle', {
    x = 0,
    y = 0,
    width = 30,
    height = 30,
    rectType = RECT_TYPE.FILLED,
}).extends(gfx.sprite)

function Rectangle:init(x, y, width, height, rectType, color, dither)
    Rectangle.super.init(self)

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.rectType = rectType
    self.color = color
    self.dither = dither
    self:setSize(width, height)
    self:setCenter(0,0)
    self:moveTo(x, y)
    self:setZIndex(100)
    self:add()
end

function Rectangle:setColor(color)
    self.color = color
    self:markDirty()
end

function Rectangle:draw()

    gfx.pushContext()

        gfx.setColor(self.color)
        if self.rectType == RECT_TYPE.FILLED then
            gfx.setDitherPattern(.5, self.dither)
            gfx.fillRect(0, 0, self.width, self.height)
        elseif self.rectType == RECT_TYPE.BORDER then
            gfx.setLineWidth(self.borderThickness)
            gfx.drawRect(0, 0, self.width, self.height)
        end

    gfx.popContext()

end