import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics
local WIDTH <const> = 220
local HEIGHT <const> = 120
local DIALOG_STATE <const> = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}


class('DialogBox', {
    text = "",
    aButtonText = "",
    bButtonText = ""
}).extends(gfx.sprite)

function DialogBox:init(x, y, text)
    DialogBox.super.init(self)

    self.state = DIALOG_STATE.NOT_SHOWING
    self:setSize(WIDTH, HEIGHT)
    self:moveTo(x, y)
    self:setZIndex(900)
    self.text = text
    self.currentChar = 1 -- we'll use these for the animation
    self.currentText = ""
    self.typing = true
end

-- this function will calculate the string to be used. 
-- it won't actually draw it; the following draw() function will.
function DialogBox:update()

    self.currentChar = self.currentChar + 1
    if self.currentChar > #self.text then
        self.currentChar = #self.text
    end

    if self.typing and self.currentChar <= #self.text then
        self.currentText = string.sub(self.text, 1, self.currentChar)
        self:markDirty() -- this tells the sprite that it needs to redraw
    end

    -- end typing
    if self.currentChar == #self.text then
        self.currentChar = 1
        self.typing = false
    end
end

-- this function defines how this sprite is drawn
function DialogBox:draw()

    -- pushing context means, limit all the drawing config to JUST this block
    -- that way, the colors we set etc. won't be stuck
    gfx.pushContext()

        gfx.setFont(gfx.getSystemFont())

        -- draw the box				
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, WIDTH, HEIGHT)

        -- border
        gfx.setLineWidth(4)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(0, 0, WIDTH, HEIGHT)

        -- draw the text!
        -- gfx.drawTextInRect(self.currentText, 10, 10, 200, 160)
        gfx.drawTextInRect(self.currentText.."\n\nⒶ New Game\nⒷ Dismiss\n", 10, 10, 200, 100)

    gfx.popContext()

end

function DialogBox:show(text)
    if self:isShowing() then
        return
    end
    self.state = DIALOG_STATE.SHOWING
    self.text = text
    self:add()
    print("showing dialog box")
end

function DialogBox:isShowing()
    return self.state == DIALOG_STATE.SHOWING
end

function DialogBox:dismiss()
    if self:isShowing() == false then
        return
    end
    self.currentChar = 1 -- we'll use these for the animation
    self.currentText = ""
    self.typing = true
    self.state = DIALOG_STATE.NOT_SHOWING
    self:remove()
    print("dismissing dialog box")
end
