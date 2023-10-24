-- import "CoreLibs/animation"
-- import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'library/AnimatedSprite'
import 'helper/Utils'

local gfx <const> = playdate.graphics
local DEBUG <const> = true
-- local PROGRESS_BAR_Z <const> = 100
local TEXT_Z <const> = 105
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
    self.font = gfx.font.new("fonts/Roobert-10-Bold")

    self:initTextSprite()
    self:initBackgroundSprite()
    -- self:initAnimationSprite()
end

function ProgressBar:initTextSprite()
    local textImage = gfx.imageWithText("Thinking...(0%)", 150, 20, nil, nil, nil, kTextAlignment.left, self.font)
    self.textSprite = gfx.sprite.new(textImage)
    -- self.textSprite:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.textSprite:setImageDrawMode(gfx.kDrawModeNXOR)
    self.textSprite:setZIndex(TEXT_Z)
    self.textSprite:setCenter(0, 0)
    self.textSprite:moveTo(self.x + 32,self.y + 8)
end

function ProgressBar:initBackgroundSprite()
    local backgroundImage = gfx.image.new(140, 32)
    gfx.pushContext(backgroundImage)
        gfx.fillRoundRect(2, 3, 140, 26, 10)
    gfx.popContext()

    self.backgroundSprite = gfx.sprite.new(backgroundImage)
    self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:moveTo(self.x+1, self.y-2)

    local borderImage = gfx.image.new(140,32)
    gfx.pushContext(borderImage)
        gfx.setLineWidth(2)
        gfx.drawRoundRect(2, 2, 136, 28, 10)
    gfx.popContext()
    self.borderSprite = gfx.sprite.new(borderImage)
    self.borderSprite:setCenter(0, 0)
    self.borderSprite:moveTo(self.x+1, self.y-2)
end

-- function ProgressBar:initAnimationSprite()
--     self.animatedSprite = AnimatedSprite.new(
--         gfx.imagetable.new("animation/robot-progress-inverted"),
--         AnimatedSprite.loadStates("animation/progress.json")
--     )
--     self.animatedSprite:setZIndex(PROGRESS_BAR_Z)
--     self.animatedSprite:setCenter(0, 0)
--     self.animatedSprite:moveTo(self.x+3, self.y)

--     -- this animation shouldnt be started because the sprite isnt added
--     -- idk why it starts immediately
--     self.animatedSprite:stopAnimation()
--     self.animatedSprite:remove()
-- end

function ProgressBar:hide()
    self.state = PROGRESS_BAR_STATE.NOT_SHOWING
    self.percent = 0
    -- self.animatedSprite:stopAnimation()
    -- self.animatedSprite:remove()
    self.textSprite:remove()
    self.backgroundSprite:remove()
    self.borderSprite:remove()
    printDebug("ProgressBar: hide()", DEBUG)
end

function ProgressBar:show()
    self.state = PROGRESS_BAR_STATE.SHOWING
    -- self.animatedSprite:add()
    -- self.animatedSprite:playAnimation()
    self.textSprite:add()
    self.backgroundSprite:add()
    self.borderSprite:add()
    self:updateProgress(0.0)
    printDebug("ProgressBar: show()", DEBUG)
end

function ProgressBar:isShowing()
    return self.state == PROGRESS_BAR_STATE.SHOWING
end

function ProgressBar:updateProgress(percent)
    self.percent = iif(percent <= 100, percent, 100)

    local percentString = string.format("%.0f", percent)
    local textImage = gfx.imageWithText("Thinking...("..percentString.."%)", 130, 150, nil, nil, nil, kTextAlignment.left, self.font)
    self.textSprite:setImage(textImage)
    self.textSprite:markDirty()

    self.backgroundSprite:setClipRect(
        self.backgroundSprite.x,
        self.backgroundSprite.y,
        self.percent * 1.4,
        self.backgroundSprite.height)
    self.backgroundSprite:markDirty()
end
