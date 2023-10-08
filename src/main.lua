import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ui/dialogBox'
import 'ui/boardGrid'
import 'ui/progressBar'
import 'ui/capturedPieces'

-- import 'engine/garbochess' -- cant even get desktop version working
import 'engine/LuaJester' -- it works!
-- import 'engine/fruit21chess' --// freezes in init() when calling 
-- import 'engine/OwlChess'

local gfx<const> = playdate.graphics
local chessGame = ChessGame()
local boardGridView = BoardGridView(chessGame:getBoard())
local dialogBox = DialogBox(200, 120, "", "New Game", "Dismiss")
local progressBar = ProgressBar(330, 120)
local bCapturedPieces = CapturedPieces(269, 13, false)
local wCapturedPieces = CapturedPieces(269, 177, true)
local GAME_DIFFICULTY <const> = {
    ["easy"] = {3,6},
    ["med"] = {4,6},
    ["hard"] = {8,6},
    ["expert"] = {16,6}
}
chessGame:setDifficulty(GAME_DIFFICULTY["easy"])

local function newGame()
    chessGame:newGame()
    boardGridView:clearGameData()
    boardGridView:addBoard(chessGame:getBoard())
    wCapturedPieces:clear()
    bCapturedPieces:clear()
end

local function getUsersMove()
    local from, to = boardGridView:clickCell()
    chessGame:move(from, to, true)
    if chessGame:getState() == GAME_STATE.INVALID_MOVE then
        return false
    end
    boardGridView:addBoard(chessGame:getBoard())
    wCapturedPieces:addPieces(chessGame:getMissingPieces())
    return true
end

local function getComputersMove()
    progressBar:show()
    chessGame:move("", "", false,
        function()
            boardGridView:addBoard(chessGame:getBoard())
            bCapturedPieces:addPieces(chessGame:getMissingPieces())

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
    elseif crankTicks == -1 then
        boardGridView:previousPosition()
        local missingPieces = chessGame:getMissingPieces(boardGridView:getVisibleBoard())
        bCapturedPieces:addPieces(missingPieces)
        wCapturedPieces:addPieces(missingPieces)
    end
end

function playdate.upButtonDown()
    boardGridView:selectPreviousRow(true)
end

function playdate.downButtonDown()
    boardGridView:selectNextRow(true)
end

function playdate.rightButtonDown()
    boardGridView:selectNextColumn(false)
end

function playdate.leftButtonDown()
    boardGridView:selectPreviousColumn(false)
end

function playdate.update()

    gfx.sprite.update()
    playdate.timer:updateTimers()
end


local function initMenu()
    local menu = playdate.getSystemMenu()
    local _, error1 = menu:addOptionsMenuItem("Difficulty", {"easy", "med", "hard", "expert"}, "easy",
        function(value)
            -- change difficult clicked
            chessGame:setDifficulty(GAME_DIFFICULTY[value])
        end)

    local _, error2 = menu:addMenuItem("new game", function()
        -- new game clicked
        newGame()
    end)

    local _, error3 = menu:addMenuItem("undo move", function()
            -- undo move clicked
        if chessGame:isComputerThinking() then
            print("cant undo move while computer is thinking")
            return
        end
        chessGame:undoLastTwoMoves()
        boardGridView:removeBoard()
        boardGridView:removeBoard()
        local missingPieces = chessGame:getMissingPieces(boardGridView:getVisibleBoard())
        bCapturedPieces:addPieces(missingPieces)
        wCapturedPieces:addPieces(missingPieces)
    end)
    
end

initMenu()

-- TODO
-- let user choose promotion piece
-- only update squares that changed in the grid view, not the whole gridview
-- show algabraic notation of moves being made
-- add animation to pieces moving
-- add menu option 
--      - change difficulty
--      - restart game
--      - change color
--      - show hints to highlight the best move
-- when you select a piece
--      - show the possible squares the piece can go to
-- 
-- crank updates of board are much quicker than just moving selected square around the grid
