import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import 'CoreLibs/animator'
import "CoreLibs/easing"

import 'library/AnimatedSprite'
import 'helper/Utils'
import 'helper/ResourceCache'

local geo = playdate.geometry
local Animator = playdate.graphics.animator
local gfx<const> = playdate.graphics

local DEBUG <const> = true
local DIALOG_Z <const> = 1000
local STICKMAN_Z <const> = 1001
local KING_Z <const> = 1001
local DIALOG_STATE <const> = {
    SHOWING = "0",
    NOT_SHOWING = "1"
}

class('DialogBox').extends(gfx.sprite)

function DialogBox:init(x, y, text)
    DialogBox.super.init(self)

    self.x = x
    self.y = y

    self.cache = ResourceCache()

    self.state = DIALOG_STATE.NOT_SHOWING
    self.title = ""
    self.description = ""
    self.fontTitle = gfx.font.new("fonts/Roobert-24-Medium")
    self.fontButtons = gfx.font.new("fonts/Roobert-11-Bold")
    self.fontDescription = gfx.font.new("fonts/Roobert-11-Medium")
    self.width = 260
    self.height = 170
    self.flyingAnimator = nil
    self.pieceSprite = nil
    self.walkingSprite = nil
    self.walkingSprite2 = nil


    self.dialogBoxInputHandler = {

		BButtonDown = function ()
            self:dismiss()
		end,
	}

    self:setSize(self.width, self.height)
    self:moveTo(x, y)
    self:setZIndex(DIALOG_Z)
end

-- this function will calculate the string to be used. 
-- it won't actually draw it; the following draw() function will.
function DialogBox:update()

    -- animation
    if self.flyingAnimator and self.flyingAnimator:ended() then
        self.walkingSprite:moveTo(self.x-self.width/2, self.walkingSprite.y)
        self.walkingSprite:stopAnimation()
        self.walkingSprite:playAnimation()

        self.pieceSprite:moveTo(self.x - 5, self.y)
        self.flyingAnimator:reset()
        self.pieceSprite:setAnimator(self.flyingAnimator)
    end
end

-- this function defines how this sprite is drawn
function DialogBox:draw()

    -- pushing context means, limit all the drawing config to JUST this block
    -- that way, the colors we set etc. won't be stuck
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
        gfx.drawTextAligned("Ⓐ New Game\nⒷ Dismiss", 70, 115, kTextAlignment.left)

        -- title
        gfx.setFont(self.fontTitle)
        gfx.drawTextAligned(self.title, self.width/2, 10, kTextAlignment.center)

        -- description
        gfx.setFont(self.fontDescription)
        gfx.drawTextAligned(self.description,  self.width/2, 50, kTextAlignment.center)

    gfx.popContext()
end

function DialogBox:setupShakeHandsAnimation()
    printDebug("DialogBox: setupShakeHandsAnimation()", DEBUG)
    local selfself = self
    self.walkingSprite = AnimatedSprite.new(
        self.cache:getAnimationImage("stickman-shakehands"),
        self.cache:getAnimationConfig("shakehands-config")
    )
    self.walkingSprite:setZIndex(STICKMAN_Z)
    self.walkingSprite:setCenter(0, 0)
    self.walkingSprite:moveTo(self.x-self.width/2, self.y-35)
    self.walkingSprite:setDefaultState("stickman_shakehands")

    self.walkingSprite.states.stickman_shakehands.onLoopFinishedEvent = function (self)
        selfself.walkingSprite:changeState("stickman_shakehands_reverse", true) 
        selfself.walkingSprite:moveTo(selfself.x-160, self.y)
    end

    self.walkingSprite.states.stickman_shakehands_reverse.onLoopFinishedEvent = function (self)
        selfself.walkingSprite:changeState("stickman_shakehands", true)
        selfself.walkingSprite:moveTo(selfself.x-self.width/2, self.y)
    end
    

    self.walkingSprite2 = AnimatedSprite.new(
        self.cache:getAnimationImage("robot-shakehands"),
        self.cache:getAnimationConfig("shakehands-config")
    )
    self.walkingSprite2:setZIndex(STICKMAN_Z)
    self.walkingSprite2:setCenter(0, 0)
    self.walkingSprite2:moveTo(self.x+75, self.y-30)
    self.walkingSprite2:setDefaultState("robot_shakehands")
    
    self.walkingSprite2.states.robot_shakehands.onLoopFinishedEvent = function (self)
        selfself.walkingSprite2:changeState("robot_shakehands_reverse", true)
        selfself.walkingSprite2:moveTo(selfself.x, selfself.y-30)
    end

    self.walkingSprite2.states.robot_shakehands_reverse.onLoopFinishedEvent = function (self) 
        selfself.walkingSprite2:changeState("robot_shakehands", true)
    end

    function self.walkingSprite2:update()
        if self.currentState == "robot_shakehands" then
            if selfself.walkingSprite2.x > selfself.x-10 then
                local newX = selfself.walkingSprite2.x - 1
                selfself.walkingSprite2:moveTo(newX, self.y)
            end
        elseif self.currentState == "robot_shakehands_reverse" then
            if selfself.walkingSprite2.x < selfself.x+100 then
                local newX = self.x + 1
                selfself.walkingSprite2:moveTo(newX, self.y)
            end
        end
        selfself.walkingSprite2:updateAnimation()
        selfself:update()
    end

end

function DialogBox:setUpRobotAnimation()
    printDebug("DialogBox: setUpRobotAnimation()", DEBUG)
    local selfself = self
    -- local robotImg = gfx.imagetable.new("animation/robot-run-kick")
    -- local robotImg = self.cache:getAnimationImage("robot-kick")
    self.walkingSprite = AnimatedSprite.new(
        self.cache:getAnimationImage("robot-kick"),
        self.cache:getAnimationConfig("kick-config")
    )
    self.walkingSprite:setZIndex(STICKMAN_Z)
    self.walkingSprite:setCenter(0, 0)
    self.walkingSprite:moveTo(self.x-self.width/2, self.y-30)
    self.walkingSprite:setDefaultState("robot_kick_run")

    function self.walkingSprite:update()
        if selfself.walkingSprite.x < selfself.x - 5 then
            local newX = selfself.walkingSprite.x + 1
            selfself.walkingSprite:moveTo(newX, selfself.walkingSprite.y)
        end
        selfself.walkingSprite:updateAnimation()
        selfself:update()
    end
end

function DialogBox:setupStickManAnimation()
    printDebug("DialogBox: setupStickManAnimation()", DEBUG)
    -- local stickmanImg = gfx.imagetable.new("animation/stickman-walking-kick")
    self.walkingSprite = AnimatedSprite.new(
        self.cache:getAnimationImage("stickman-kick"),
        self.cache:getAnimationConfig("kick-config")
    )
    self.walkingSprite:setDefaultState("stickman_kick_run")
    self.walkingSprite:setZIndex(STICKMAN_Z)
    self.walkingSprite:setCenter(0, 0)
    self.walkingSprite:moveTo(self.x-self.width/2+5, self.y-35)
end

function DialogBox:setUpFlyingPieceAnimation(imgPath, delay)
    printDebug("DialogBox: setUpFlyingPieceAnimation()", DEBUG)
    local points = self:calculateObjectInMotionPath(self.x + 20, self.y, 5)
    local polygon = geo.polygon.new(table.unpack(points))
    local image = gfx.image.new(imgPath)

    self.flyingAnimator = Animator.new(1500, polygon, playdate.easingFunctions.linear, delay)
    self.pieceSprite = gfx.sprite.new(image)
    self.pieceSprite:setCenter(0,0)
    self.pieceSprite:setZIndex(KING_Z)
    self.pieceSprite:moveTo(self.x - 5, self.y)
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
        i += 2
        newT += tStep
    end
    return path
end

function DialogBox:show(state)
    if self:isShowing() then
        self:dismiss()
    end

    self.state = DIALOG_STATE.SHOWING

    if state == GAME_STATE.COMPUTER_WON then
        self.title = "Checkmate!"
        self.description = "Black won"
        self:setUpFlyingPieceAnimation("images/king", 4250)
        self:setUpRobotAnimation()
    elseif state == GAME_STATE.USER_WON then
        self.title = "Checkmate"
        self.description = "White won"
        self:setUpFlyingPieceAnimation("images/king1", 4500)
        self:setupStickManAnimation()
    elseif state == GAME_STATE.DRAW_BY_REPITITION then
        self.title = "Draw!"
        self.description = "Threefold repitition"
        self:setupShakeHandsAnimation()
    elseif state == GAME_STATE.DRAW then
        self.title = "Draw!"
        self.description = ""
        self:setupShakeHandsAnimation()
    elseif state == GAME_STATE.INSUFFICIENT_MATERIAL then
        self.title = "Draw!"
        self.description = "Insufficient material"
        self:setupShakeHandsAnimation()
    elseif state == GAME_STATE.STALEMATE then
        self.title = "Stalemate!"
        self.description = ""
        self:setupShakeHandsAnimation()
    elseif state == GAME_STATE.RESIGN then
        self.title = "Black Resigned!"
        self.description = "White won"
        self:setUpFlyingPieceAnimation("images/king1", 4500)
        self:setupStickManAnimation()
    end

    printDebug("DialogBox: show()\nstate="..state.."\ndescription="..self.description.."\ntitle="..self.title, DEBUG)

    self:add()

    if self.walkingSprite then
        self.walkingSprite:add()
        self.walkingSprite:playAnimation()
    end

    if self.walkingSprite2 then
        self.walkingSprite2:add()
        self.walkingSprite2:playAnimation()
    end

    if self.pieceSprite then
        self.pieceSprite:setAnimator(self.flyingAnimator)
        self.pieceSprite:add()
    end

    playdate.inputHandlers.push(self.dialogBoxInputHandler)
    printDebug("Dialog Box: showing", DEBUG)
end

function DialogBox:isShowing()
    return self.state == DIALOG_STATE.SHOWING
end

function DialogBox:dismiss()
    if self:isShowing() == false then
        return
    end
    
    self.state = DIALOG_STATE.NOT_SHOWING
    self:remove()

    -- stop animation
    if self.walkingSprite then
        self.walkingSprite:remove()
        self.walkingSprite = nil
    end

    if self.walkingSprite2 then
        self.walkingSprite2:remove()
        self.walkingSprite2 = nil
    end

    if self.pieceSprite then
        self.pieceSprite:remove()
        self.pieceSprite = nil
    end

    if self.flyingAnimator then
        self.flyingAnimator = nil
    end

    playdate.inputHandlers.pop()
    printDebug("Dialog Box: dismissing", DEBUG)
end
