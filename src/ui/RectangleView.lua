import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics
local DEBUG <const> = false
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

function Rectangle:init(x, y, z, width, height, rectType, color, alpha, dither)
    Rectangle.super.init(self)

    -- self.initialX = x
    -- self.initialY = y
    -- self.drawn = {-1,-1,false}
    self.z = z
    self.width = width
    self.height = height
    self.rectType = rectType

    self.color = gfx.kColorClear
    if color ~= nil then
        self.color = color
    end

    self.alpha = .5
    if alpha ~= nil then
        self.alpha = alpha
    end

    self.dither = gfx.image.kDitherTypeNone 
    if dither ~= nil then
        self.dither = dither
    end

    -- self.dither = dither
    -- self.alpha = .5
    self:setSize(width, height)
    self:setCenter(0,0)
    self:moveTo(x, y)
    self:setZIndex(z)
    self:add()
end

function Rectangle:setColor(color)
    self.color = color
    -- self:markDirty()
end

function Rectangle:setDither(alpha, dither)
    self.alpha = alpha
    self.dither = dither
    -- self:markDirty()
end

function Rectangle:draw()
    printDebug("Rectangle: draw() ", DEBUG)
    -- if self.drawn[3] == true and self.drawn[1] == self.x and self.drawn[2] == self.y then
    --     printDebug("Rectangle: draw() not drawing", DEBUG)
    --     return
    -- end
    -- if self.x == self.initialX and self.y == self.initialY then
    --     printDebug("Rectangle: draw() not drawing", DEBUG)
    --     return
    -- end
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
    -- self.drawn = {self.x, self.y, true}
end