import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import 'CoreLibs/animator'
import "CoreLibs/easing"

import '../AnimatedSprite'
import 'Utils'

local geo = playdate.geometry
local Animator = playdate.graphics.animator
local gfx<const> = playdate.graphics

local DEBUG <const> = true
local WIDTH <const> = 260
local HEIGHT <const> = 170
local DIALOG_Z <const> = 1000
local STICKMAN_Z <const> = 1001
local KING_Z <const> = 1001
local FONT_TITLE <const> = gfx.font.new("fonts/Roobert-24-Medium")
local FONT_BUTTONS <const> = gfx.font.new("fonts/Roobert-11-Bold")
local FONT_DESCRIPTION <const> = gfx.font.new("fonts/Roobert-11-Medium")

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

    self.x = x
    self.y = y

    self.state = DIALOG_STATE.NOT_SHOWING
    self:setSize(WIDTH, HEIGHT)
    self:moveTo(x, y)
    self:setZIndex(DIALOG_Z)
    self.text = text
    self.title = "Checkmate!"
    self.description = "White wins"
    self.currentChar = 1 -- we'll use these for the animation
    self.currentText = ""
    self.typing = true
    
    self.flyingAnimator = nil
    self.flyingSprite = nil

    self.walkingSprite = nil

    self:setUpFlyingPieceAnimation("images/king1")
    -- self:setupStickManAnimation()
    self:setUpRobotAnimation()

end

-- this function will calculate the string to be used. 
-- it won't actually draw it; the following draw() function will.
function DialogBox:update()

    -- type writer text
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

    -- animation
    if self.flyingAnimator:ended() then
        self.walkingSprite:playAnimation()

        self.pieceSprite:moveTo(self.x + 20, self.y)
        self.flyingAnimator:reset()
        self.pieceSprite:setAnimator(self.flyingAnimator)
        print("restarting animation")
    end
end

-- this function defines how this sprite is drawn
function DialogBox:draw()

    -- pushing context means, limit all the drawing config to JUST this block
    -- that way, the colors we set etc. won't be stuck
    gfx.pushContext()

        -- draw the box
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, WIDTH, HEIGHT)

        -- border
        gfx.setLineWidth(4)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(0, 0, WIDTH, HEIGHT)

        -- buttons
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(FONT_BUTTONS)
        gfx.drawTextAligned("Ⓐ New Game\nⒷ Dismiss", 70, 115, kTextAlignment.left)

        -- title
        gfx.setFont(FONT_TITLE)
        gfx.drawTextAligned(self.title, WIDTH/2, 10, kTextAlignment.center)

        -- description
        gfx.setFont(FONT_DESCRIPTION)
        gfx.drawTextAligned(self.description,  WIDTH/2, 50, kTextAlignment.center)

    gfx.popContext()

end

function DialogBox:setUpRobotAnimation()
    local selfself = self
    local robotImg = gfx.imagetable.new("images/robot-run-cropped")
    self.walkingSprite = AnimatedSprite.new(robotImg,{
        name = "run",
        firstFrameIndex = 1,
        framesCount = 140,
        tickStep = 1,
        loop = false,
        onLoopFinishedEvent = function (self)
            print("Finished loops =", self._loopsFinished)
            -- selfself.kingSprite:setAnimator(selfself.kingAnimator)
            -- selfself.kingSprite:add()
            -- selfself.kingSprite:setAnimator(selfself.kingAnimator)
            -- selfself.kingSprite:add()
            -- self:pauseAnimation()
        end,
    })
    -- self.stickFigureSprite:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.walkingSprite:setZIndex(STICKMAN_Z)
    self.walkingSprite:setCenter(0, 0)
    self.walkingSprite:moveTo(self.x-WIDTH/2, self.y-35)
    function self.walkingSprite:update()
        local newX = self.walkingSprite.x + 5
        -- if newX > 400 then
        --     sprite:changeState("appear")
        --     newX -= 400
        -- end
        self.walkingSprite:moveTo(newX, sprite.y)
        self.walkingSprite:updateAnimation()
    end
end

function DialogBox:setupStickManAnimation()
    local selfself = self
    local stickmanImg = gfx.imagetable.new("images/stickman-walking-kick")
    self.walkingSprite = AnimatedSprite.new(stickmanImg,{
        name = "run",
        firstFrameIndex = 1,
        framesCount = 140,
        tickStep = 1,
        loop = false,
        onLoopFinishedEvent = function (self)
            print("Finished loops =", self._loopsFinished)
            -- selfself.kingSprite:setAnimator(selfself.kingAnimator)
            -- selfself.kingSprite:add()
            -- selfself.kingSprite:setAnimator(selfself.kingAnimator)
            -- selfself.kingSprite:add()
            -- self:pauseAnimation()
        end,
    })
    -- self.stickFigureSprite:setImageDrawMode(gfx.kDrawModeFillWhite)
    self.walkingSprite:setZIndex(STICKMAN_Z)
    self.walkingSprite:setCenter(0, 0)
    self.walkingSprite:moveTo(self.x-WIDTH/2, self.y-35)
end

function DialogBox:setUpFlyingPieceAnimation(imgPath)
    local points = self:calculateObjectInMotionPath(self.x + 20, self.y, 5)
    local polygon = geo.polygon.new(table.unpack(points))
    local image = gfx.image.new(imgPath)

    self.flyingAnimator = Animator.new(1500, polygon, playdate.easingFunctions.linear, 4500)--3700
    self.pieceSprite = gfx.sprite.new(image)
    self.pieceSprite:setCenter(0,0)
    self.pieceSprite:setZIndex(KING_Z)
    self.pieceSprite:moveTo(self.x + 15, self.y)
end

-- x(t) = vx(0)t + ½at²
-- y(t) = h(0) + vy(0)t − 16t²
-- h(x) = –0.06x² + 3.168x – 35.34
function DialogBox:calculateObjectInMotionPath(x,y,t)
    local path = {}
    local newT = 0
    local tStep = .15
    local velocityX = 50
    local velocityY = 50
    local accel = -5
    local i = 3

    path[1] = x
    path[2] = y
    while newT < t do
        path[i] = math.floor(x + velocityX*newT + (.5*accel*newT*newT))
        path[i+1] = y - math.floor(velocityY*newT - 9.8*newT*newT)
        -- printDebug("x="..path[i].." y="..path[i+1], DEBUG)
        i += 2
        newT += tStep
    end
    return path
end

function DialogBox:show(text)
    if self:isShowing() then
        return
    end
    self.state = DIALOG_STATE.SHOWING
    self.text = text
    self:add()

    self.walkingSprite:add()
    self.walkingSprite:playAnimation()

    self.pieceSprite:setAnimator(self.flyingAnimator)
    self.pieceSprite:add()
    printDebug("Dialog Box: showing", DEBUG)
end

function DialogBox:isShowing()
    return self.state == DIALOG_STATE.SHOWING
end

function DialogBox:dismiss()
    if self:isShowing() == false then
        return
    end
    -- reset text
    self.currentChar = 1 -- we'll use these for the animation
    self.currentText = ""
    self.typing = true
    self.state = DIALOG_STATE.NOT_SHOWING
    self:remove()

    -- reset animation
    self.walkingSprite:remove()
    self.pieceSprite:remove()
    printDebug("Dialog Box: dismissing", DEBUG)
end
