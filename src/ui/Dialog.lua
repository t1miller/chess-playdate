import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import 'helper/Utils'


local gfx<const> = playdate.graphics

local DEBUG <const> = false
local DIALOG_Z <const> = 1000
local DIALOG_STATE <const> = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}

class('Dialog').extends(gfx.sprite)

function Dialog:init(x, y, width, height, title, description, buttonText)
    Dialog.super.init(self)

    self.x = x
    self.y = y

    self.state = DIALOG_STATE.NOT_SHOWING
    self.title = title or ""
    self.description = description or ""
    self.buttonText = buttonText or ""
    self.width = width or 260
    self.height = height or 170
    self.titleFont = gfx.font.new("fonts/Roobert-24-Medium")
    self.buttonFont =  gfx.font.new("fonts/Roobert-11-Bold")
    self.descriptionFont = gfx.font.new("fonts/Roobert-20-Medium")
    self.titleAlignment = kTextAlignment.center
    self.buttonAlignment = kTextAlignment.left
    self.descriptionAlignment = kTextAlignment.center
    self.titleX = self.width/2
    self.titleY = 10
    self.descriptionX = self.width/2
    self.descriptionY = 60
    self.buttonX = 70
    self.buttonY = 110


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

function Dialog:setTitleAndDescription(isUserWhite, state)
    if state == GAME_STATE.COMPUTER_WON then
        self.title = "Checkmate!"
        self.description = iif(isUserWhite,  "Black won", "White won")
    elseif state == GAME_STATE.USER_WON then
        self.title = "Checkmate"
        self.description = iif(isUserWhite, "White won", "Black won")
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
        self.title = iif(isUserWhite,"Black Resigned!", "White Resigned!")
        self.description = iif(isUserWhite, "White won", "Black won")
    end
end

function Dialog:setAlignments(titleAlignment, descriptionAlignment, buttonAlignment)
    self.titleAlignment = titleAlignment or self.titleAlignment
    self.descriptionAlignment = descriptionAlignment or self.descriptionAlignment
    self.buttonAlignment = buttonAlignment or self.buttonAlignment
end

function Dialog:setFonts(titleFont, descriptionFont, buttonFont)
    self.titleFont = titleFont or self.titleFont
    self.descriptionFont = descriptionFont or self.descriptionFont
    self.buttonFont = buttonFont or self.buttonFont
end

function Dialog:setOffsets(titleX, titleY, descriptionX, descriptionY, buttonX, buttonY)
    self.titleX = titleX or self.titleX
    self.titleY = titleY or self.titleY
    self.descriptionX = descriptionX or self.descriptionX
    self.descriptionY = descriptionY or self.descriptionY
    self.buttonX = buttonX or self.buttonX
    self.buttonY = buttonY or self.buttonY
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
        gfx.setFont(self.buttonFont)
        gfx.drawTextAligned(self.buttonText, self.buttonX, self.buttonY, self.buttonAlignment)

        -- title
        gfx.setFont(self.titleFont)
        gfx.drawTextAligned(self.title, self.titleX, self.titleY, self.titleAlignment)

        -- description
        gfx.setFont(self.descriptionFont)
        gfx.drawTextAligned(self.description,  self.descriptionX, self.descriptionY, self.descriptionAlignment)

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
