local gfx <const> = playdate.graphics

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

    local progressImage = gfx.imagetable.new("images/progress-dither")

    self.infillSprite = gfx.sprite.new(progressImage[1])
    self.infillSprite:moveTo(x, y)
    -- self.infillSprite:setClipRect(x+50,y+50, 50, 50)
    -- self.infillSprite:add()

    self.progressSprite = gfx.sprite.new(progressImage[3])
    self.progressSprite:moveTo(x, y)
    -- self.progressSprite:add()

    self.surroundSprite = gfx.sprite.new(progressImage[2])
    self.surroundSprite:moveTo(x, y)
    -- self.surroundSprite:add()

    self:updateProgress(0)
end

function ProgressBar:hide()
    self.state = PROGRESS_BAR_STATE.NOT_SHOWING
    self.infillSprite:remove()
    self.progressSprite:remove()
    self.surroundSprite:remove()
    -- self.textSprite:remove()
end

function ProgressBar:show()
    self.state = PROGRESS_BAR_STATE.SHOWING
    self.infillSprite:add()
    self.progressSprite:add()
    self.surroundSprite:add()
    -- self.textSprite:add()
end

function ProgressBar:isShowing()
    return self.state == PROGRESS_BAR_STATE.SHOWING
end

function ProgressBar:updateProgress(percent)
    self.percent = percent
    self.progressSprite:setClipRect(self.progressSprite.x - self.progressSprite.width / 2,
        self.progressSprite.y - self.progressSprite.height / 2, self.percent * 2, self.progressSprite.height)
end
