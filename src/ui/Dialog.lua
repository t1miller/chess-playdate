import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/Utils'


local gfx<const> = playdate.graphics

local DEBUG <const> = true
local DIALOG_Z <const> = 1000
local DIALOG_STATE <const> = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}

class('Dialog').extends(gfx.sprite)

function Dialog:init(x, y, title, description, buttonText)
    Dialog.super.init(self)

    self.x = x
    self.y = y

    self.state = DIALOG_STATE.NOT_SHOWING
    self.title = title or ""
    self.description = description or ""
    self.buttonText = buttonText or ""
    self.width = 260
    self.height = 170
    self.fontTitle = gfx.font.new("fonts/Roobert-24-Medium")
    self.fontButtons = gfx.font.new("fonts/Roobert-11-Bold")
    self.fontDescription = gfx.font.new("fonts/Roobert-10-Bold")

    self.dialogBoxInputHandler = {AButtonDown = function () end, BButtonDown = function () end}

    self:setSize(self.width, self.height)
    self:moveTo(x, y)
    self:setZIndex(DIALOG_Z)
end

function Dialog:setButtonCallbacks(aButtonCallback, bButtonCallback)
    self.dialogBoxInputHandler = {
        AButtonDown = function ()
            if aButtonCallback then
                aButtonCallback()
            end
        end,

		BButtonDown = function ()
            if bButtonCallback then
                bButtonCallback()
            end
		end,
	}
end

function Dialog:setTitleAndDescription(state)
    if state == GAME_STATE.COMPUTER_WON then
        self.title = "Checkmate!"
        self.description = "Black won"
    elseif state == GAME_STATE.USER_WON then
        self.title = "Checkmate"
        self.description = "White won"
    elseif state == GAME_STATE.DRAW_BY_REPITITION then
        self.title = "Draw!"
        self.description = "Threefold repitition"
    elseif state == GAME_STATE.DRAW then
        self.title = "Draw!"
        self.description = ""
    elseif state == GAME_STATE.INSUFFICIENT_MATERIAL then
        self.title = "Draw!"
        self.description = "Insufficient material"
    elseif state == GAME_STATE.STALEMATE then
        self.title = "Stalemate!"
        self.description = ""
    elseif state == GAME_STATE.RESIGN then
        self.title = "Black Resigned!"
        self.description = "White won"
    end
end

function Dialog:draw()

    gfx.pushContext()

        -- draw the box
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, self.width, self.height)

        -- border
        gfx.setLineWidth(4)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(0, 0, self.width, self.height)

        -- buttons
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(self.fontButtons)
        gfx.drawTextAligned(self.buttonText, 70, 115, kTextAlignment.left)

        -- title
        gfx.setFont(self.fontTitle)
        gfx.drawTextAligned(self.title, self.width/2, 10, kTextAlignment.center)

        -- description
        gfx.setFont(self.fontDescription)
        gfx.drawTextAligned(self.description,  self.width/2, 50, kTextAlignment.center)

    gfx.popContext()
end


function Dialog:show()
    if self:isShowing() then
        self:dismiss()
    end
    self.state = DIALOG_STATE.SHOWING
    self:add()

    playdate.inputHandlers.push(self.dialogBoxInputHandler)
    printDebug("Dialog: show() title="..self.title.." description="..self.description.." buttonText="..self.buttonText, DEBUG)
end

function Dialog:isShowing()
    return self.state == DIALOG_STATE.SHOWING
end

function Dialog:dismiss()
    if self:isShowing() == false then
        return
    end

    self.state = DIALOG_STATE.NOT_SHOWING
    self:remove()

    playdate.inputHandlers.pop()
    printDebug("Dialog Box: dismissing", DEBUG)
end
