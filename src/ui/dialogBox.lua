import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics

local DIALOG_STATE = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}

class('DialogBox', {
    text = "",
    aButtonText = "",
    bButtonText = ""
}).extends(gfx.sprite)

function DialogBox:init(text, aButtonText, bButtonText)
    DialogBox.super.init(self)

    self.aButtonText = aButtonText
    self.bButtonText = bButtonText
    self.state = DIALOG_STATE.NOT_SHOWING
    self:setSize(220, 180)
    self:moveTo(200, 120)
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

    -- draw the box				
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 220, 180)

    -- border
    gfx.setLineWidth(4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 0, 220, 180)

    -- draw the text!
    -- gfx.drawTextInRect(self.currentText, 10, 10, 200, 160)
    gfx.drawTextInRect(self.currentText, 10, 10, 200, 100)

    -- draw A button
    gfx.drawCircleAtPoint(30, 100, 17)
    gfx.drawTextAligned("A", 31, 93, kTextAlignment.center)
    gfx.drawTextAligned(self.aButtonText, 65, 93, kTextAlignment.left)

    -- draw B button
    gfx.drawCircleAtPoint(30, 145, 17)
    gfx.drawTextAligned("B", 31, 138, kTextAlignment.center)
    gfx.drawTextAligned(self.bButtonText, 65, 138, kTextAlignment.left)

    gfx.popContext()

end

function DialogBox:updateText(text)
    self.text = text
end

function DialogBox:show()
    if self:isShowing() then
        return
    end
    self.state = DIALOG_STATE.SHOWING
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
