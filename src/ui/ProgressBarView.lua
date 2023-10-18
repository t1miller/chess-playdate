-- import "CoreLibs/animation"
-- import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'ui/AnimatedSprite'
import 'helper/Utils'
import 'helper/ResourceCache'

local gfx <const> = playdate.graphics
local DEBUG <const> = false
local PROGRESS_FONT<const> = gfx.font.new("fonts/Roobert-10-Bold")
local PROGRESS_BAR_Z <const> = 100
local PROGRESS_BAR_STATE <const> = {
    SHOWING = "SHOWING",
    NOT_SHOWING = "NOT_SHOWING"
}

class('ProgressBar').extends()

function ProgressBar:init(x, y)
    ProgressBar.super.init(self)

    self.x = x
    self.y = y
    self.state = PROGRESS_BAR_STATE.NOT_SHOWING
    self.percent = 0

    self.cache = ResourceCache()

    self:initTextSprite()
    self:initBackgroundSprite()
    self:initAnimationSprite()

    self:updateProgress(0.0)
end

function ProgressBar:initTextSprite()
    local textImage = gfx.imageWithText("Thinking...(0%)", 150, 20, nil, nil, nil, kTextAlignment.left, PROGRESS_FONT)
    self.textSprite = gfx.sprite.new(textImage)
    self.textSprite:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.textSprite:setZIndex(PROGRESS_BAR_Z)
    self.textSprite:setCenter(0, 0)
    self.textSprite:moveTo(self.x + 32,self.y + 8)
end

function ProgressBar:initBackgroundSprite()
    local backgroundImage = gfx.image.new(140, 32)
    gfx.pushContext(backgroundImage)
        -- gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        gfx.fillRoundRect(0, 0, 140, 32, 10)
    gfx.popContext()

    self.backgroundSprite = gfx.sprite.new(backgroundImage)
    self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:moveTo(self.x+1, self.y-2)
end

function ProgressBar:initAnimationSprite()
    self.animatedSprite = AnimatedSprite.new(
        self.cache:getAnimationImage("robot-progress"),
        self.cache:getAnimationConfig("robot-progress")
    )
    self.animatedSprite:setZIndex(PROGRESS_BAR_Z)
    self.animatedSprite:setCenter(0, 0)
    self.animatedSprite:moveTo(self.x+3, self.y)
end

function ProgressBar:hide()
    self.state = PROGRESS_BAR_STATE.NOT_SHOWING
    self.animatedSprite:stopAnimation()
    self.animatedSprite:remove()
    self.textSprite:remove()
    self.backgroundSprite:remove()
    printDebug("ProgressBar: hide()", DEBUG)
end

function ProgressBar:show()
    self.state = PROGRESS_BAR_STATE.SHOWING
    self.animatedSprite:add()
    self.animatedSprite:playAnimation()
    self.textSprite:add()
    self.backgroundSprite:add()
    self:updateProgress(0.0)
    printDebug("ProgressBar: show()", DEBUG)
end

function ProgressBar:isShowing()
    return self.state == PROGRESS_BAR_STATE.SHOWING
end

function ProgressBar:updateProgress(percent)
    self.percent = percent
    
    local percentString = string.format("%.0f", percent)
    local textImage = gfx.imageWithText("Thinking...("..percentString.."%)", 130, 150, nil, nil, nil, kTextAlignment.left, PROGRESS_FONT)
    self.textSprite:setImage(textImage)
    self.textSprite:markDirty()
    printDebug("ProgressBar: updateProgress() progress "..percentString, DEBUG)
    -- self.progressSprite:setClipRect(self.progressSprite.x - self.progressSprite.width / 2,
    --     self.progressSprite.y - self.progressSprite.height / 2, self.percent * 1.3, self.progressSprite.height)
end
