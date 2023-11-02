import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics
local DEBUG <const> = true

class('Toast').extends()

function Toast:init(x, y)
    Toast.super.init(self)

    self.text = ""
    self.progress = 0
    self.font = gfx.font.new("fonts/Roobert-11-Medium")
    self.x = x or 200
    self.y = y or 200
    self.padding = 20
    self.frameTimer = nil
end

function Toast:updateProgress(progress)
    self.progress = progress
end

function Toast:show(text, duration, enableProgress)
    printDebug("Utils: showing toast message: "..text.." for "..duration.." frames", DEBUG)

    self:dismiss()

    self.text = text
    self.frameTimer = playdate.frameTimer.new(duration)
    self.frameTimer.updateCallback = function()
        if enableProgress then
            local percentString = string.format("%.0f", self.progress)
            self.text = text.." ("..percentString.."%)"
        end
        gfx.pushContext()
            gfx.setFont(self.font)
            local width, height = gfx.getTextSize(self.text)
            gfx.fillRoundRect(self.x-width/2-self.padding/2, self.y-self.padding/2, width+self.padding, height+self.padding, 9)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawRoundRect(self.x-width/2-self.padding/2, self.y-self.padding/2, width+self.padding, height+self.padding, 9)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawTextAligned(self.text, self.x, self.y, kTextAlignment.center)
        gfx.popContext()
    end
end

function Toast:dismiss()
    if self.frameTimer then
        self.frameTimer:remove()
    end
end