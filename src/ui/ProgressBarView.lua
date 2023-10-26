-- import "CoreLibs/animation"
-- import "CoreLibs/animator"
import "CoreLibs/object"
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

    self:initTextSprites()
    self:initBackgroundSprite()
    -- self:initAnimationSprite()
end

function ProgressBar:initTextSprites()
    -- local textImage = gfx.imageWithText("Thinking...(0%)", 150, 20, nil, nil, nil, kTextAlignment.left, self.font)
    -- self.textSprite = gfx.sprite.new(textImage)
    -- self.textSprite:setImageDrawMode(gfx.kDrawModeFillWhite)
    -- self.textSpritePercent:setImageDrawMode(gfx.kDrawModeNXOR)

    self.textSpritePercent = gfx.sprite.spriteWithText("0%", 50, 22, nil, nil, nil, kTextAlignment.right, self.font)
    self.textSpritePercent:setZIndex(TEXT_Z)
    self.textSpritePercent:setCenter(0,0)
    self.textSpritePercent:moveTo(self.x + 120, self.y + 14)
    -- self.textSpritePercent:moveTo(self.x + 127, self.y + 21)


    self.textSpriteLoading = gfx.sprite.spriteWithText("Thinking...", 100, 22, nil, nil, nil, kTextAlignment.left, self.font)
    self.textSpriteLoading:setZIndex(TEXT_Z)
    self.textSpriteLoading:setCenter(0,0)
    self.textSpriteLoading:moveTo(self.x+1, self.y + 14)
end

function ProgressBar:initBackgroundSprite()
    local backgroundImage = gfx.image.new(128, 11)
    gfx.pushContext(backgroundImage)
        gfx.fillRect(0, 0, 128, 11)
    gfx.popContext()
    self.backgroundSprite = gfx.sprite.new(backgroundImage)
    self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:moveTo(self.x+4, self.y+1)

    local borderImage = gfx.image.new(134,17)
    gfx.pushContext(borderImage)
        gfx.setLineWidth(4)
        gfx.drawRect(0, 0, 134, 17)
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
    self.textSpritePercent:remove()
    self.backgroundSprite:remove()
    self.borderSprite:remove()
    self.textSpriteLoading:remove()
    self.textSpritePercent:remove()

    printDebug("ProgressBar: hide()", DEBUG)
end

function ProgressBar:show()
    self.state = PROGRESS_BAR_STATE.SHOWING
    -- self.animatedSprite:add()
    -- self.animatedSprite:playAnimation()
    self.backgroundSprite:add()
    self.borderSprite:add()
    self.textSpriteLoading:add()
    self.textSpritePercent:add()

    self:updateProgress(0)
    printDebug("ProgressBar: show()", DEBUG)
end

function ProgressBar:isShowing()
    return self.state == PROGRESS_BAR_STATE.SHOWING
end

function ProgressBar:updateProgress(percent)
    self.percent = iif(percent <= 100, percent, 100)

    local percentString = string.format("%.0f", percent).."%"
    local width, _ = self.font:getTextWidth(percentString)
    local textImage = gfx.imageWithText(percentString, 130, 25, nil, nil, nil, kTextAlignment.left, self.font)
    self.textSpritePercent:setImage(textImage)
    -- kTextAlignment.right isnt doing anything, this manually doees it
    self.textSpritePercent:moveTo(self.x + 135 - width, self.y + 14)
    self.textSpritePercent:markDirty()

    self.backgroundSprite:setClipRect(
        self.backgroundSprite.x,
        self.backgroundSprite.y,
        self.percent * 1.28,
        self.backgroundSprite.height)
    self.backgroundSprite:markDirty()
end
