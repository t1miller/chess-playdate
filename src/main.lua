import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ui/dialogBox'
import 'ui/boardGrid'
import 'ui/progressBar'
import 'ui/capturedPieces'
import 'ui/moveList'

-- import 'engine/garbochess' -- cant even get desktop version working
import 'engine/LuaJester' -- it works!
-- import 'engine/fruit21chess' --// freezes in init() when calling 
-- import 'engine/OwlChess'

-- playdate.setMinimumGCTime(.0001)
-- playdate.setCollectsGarbage(false)
local gfx<const> = playdate.graphics
local chessGame = ChessGame()
local boardGridView = BoardGridView(chessGame:getBoard())
local dialogBox = DialogBox(200, 120, "", "New Game", "Dismiss")
local progressBar = ProgressBar(328, 162)
local bCapturedPieces = CapturedPieces(270, 13, false)
local wCapturedPieces = CapturedPieces(270, 233, true)
local moveList = MoveList(254,70)
local GAME_DIFFICULTY <const> = {
    ["easy"] = {1,2},
    ["med"] = {10,6},
    ["hard"] = {15,6},
    ["expert"] = {60,6}
}
-- progressBar:show()

chessGame:setDifficulty(GAME_DIFFICULTY["easy"])

local function newGame()
    chessGame:newGame()
    boardGridView:clear()
    boardGridView:addBoard(chessGame:getBoard())
    wCapturedPieces:clear()
    bCapturedPieces:clear()
    moveList:clear()
end

local function getUsersMove()
    local from, to = boardGridView:clickCell()
    chessGame:move(from, to, true)
    if chessGame:getState() == GAME_STATE.INVALID_MOVE then
        return false
    end
    moveList:highlight(true)
    boardGridView:addBoard(chessGame:getBoard())
    wCapturedPieces:addPieces(chessGame:getMissingPieces())
    moveList:updateMoveList(chessGame:getMoves(), true)
    return true
end

local function getComputersMove()
    progressBar:show()
    chessGame:move("", "", false,
        function()
            boardGridView:addBoard(chessGame:getBoard())
            bCapturedPieces:addPieces(chessGame:getMissingPieces())
            moveList:updateMoveList(chessGame:getMoves(), false)
            moveList:highlight(false)

            -- hide progress bar after done thinking
            progressBar:hide()

            if chessGame:isGameOver() then
                dialogBox:show(chessGame:getState())
                return
            end

        end,
        function(progress)
            print("progress = " .. progress .. "%")
            progressBar:updateProgress(progress)
        end)
end

local function gameStateMachine()

    -- game ended dialog is showing and user
    -- clicked A, start a new game
    if dialogBox:isShowing() then
        dialogBox:dismiss()
        newGame()
        return
    end

    -- game ended and end game dialog isn't showing
    -- show game ended dialog
    if chessGame:isGameOver() then
        dialogBox:show(chessGame:getState())
        return
    end

    boardGridView:setBoardToActivePos()
    moveList:setMoveToActiveMove()
    -- game hasnt ended, get users move 
    local didMove = getUsersMove()
    if didMove == false then
        return
    end

    if chessGame:isGameOver() then
        dialogBox:show(chessGame:getState())
        return
    end

    -- game hasnt ended, get computers move
    -- show progress bar while computer is thinking
    getComputersMove()
end

function playdate.AButtonDown()
    -- computer is still thinking, cant go yet 
    if chessGame:isComputerThinking() then
        print("computer still thinking. you cant move yet.")
        return
    end

    gameStateMachine()
end

function playdate.BButtonDown()
    -- user wants to dismiss end game dialog
    if dialogBox:isShowing() then
        dialogBox:dismiss()
    end
end

function playdate.cranked(change, acceleratedChange)
    local crankTicks = playdate.getCrankTicks(1)
    if crankTicks == 1 then
        boardGridView:nextPosition()
        local missingPieces = chessGame:getMissingPieces(boardGridView:getVisibleBoard())
        bCapturedPieces:addPieces(missingPieces)
        wCapturedPieces:addPieces(missingPieces)
        moveList:nextMove()
    elseif crankTicks == -1 then
        boardGridView:previousPosition()
        local missingPieces = chessGame:getMissingPieces(boardGridView:getVisibleBoard())
        bCapturedPieces:addPieces(missingPieces)
        wCapturedPieces:addPieces(missingPieces)
        moveList:prevMove()
    end
end

function playdate.upButtonDown()
    boardGridView:selectPreviousRow(true)
end

function playdate.downButtonDown()
    boardGridView:selectNextRow(true)
end

function playdate.rightButtonDown()
    boardGridView:selectNextColumn(true)
end

function playdate.leftButtonDown()
    boardGridView:selectPreviousColumn(true)
end
    -- gfx.fillRect(0, 0, 400, 240)


-- sprite that is board background
-- local backgroundImg = gfx.image.new(400, 240, gfx.kColorBlack)
-- local backgroundSprite = gfx.sprite.new(backgroundImg)
-- backgroundSprite:setCenter(0, 0)
-- backgroundSprite:setZIndex(-10000)
-- backgroundSprite:moveTo(0, 0)
-- backgroundSprite:add()

-- playdate.display.setRefreshRate(50)
-- playdate.setMinimumGCTime(.0001)
-- playdate.setGCScaling(0,1)
function playdate.update()

    gfx.sprite.update()
    playdate.timer:updateTimers()
end


local function initMenu()
    local menu = playdate.getSystemMenu()
    local _, error1 = menu:addOptionsMenuItem("Difficulty", {"easy", "med", "hard", "expert"}, "easy", function(value)
        if chessGame:isComputerThinking() then
            print("cant change difficulty while computer is thinking")
            return
        end
        chessGame:setDifficulty(GAME_DIFFICULTY[value])
    end)

    local _, error2 = menu:addMenuItem("new game", function()
        newGame()
    end)

    local _, error3 = menu:addMenuItem("undo move", function()
        if chessGame:isComputerThinking() then
            print("cant undo move while computer is thinking")
            return
        end
        -- todo this has a bug
        local success = chessGame:undoLastTwoMoves()
        if success then
            boardGridView:removeBoard()
            boardGridView:removeBoard()
            local missingPieces = chessGame:getMissingPieces(boardGridView:getVisibleBoard())
            bCapturedPieces:addPieces(missingPieces)
            wCapturedPieces:addPieces(missingPieces)
            moveList:removeLastTwoMoves()
        end

    end)
    
end

initMenu()

-- TODO
-- let user choose promotion piece
-- only update squares that changed in the grid view, not the whole gridview
-- add animation to pieces moving
-- add menu option 
--      - change color

-- UI
-- - bishops should be slightly bigger