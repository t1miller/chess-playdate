import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ui/DialogBoxView'
import 'ui/BoardGridView'
import 'ui/ProgressBarView'
import 'ui/CapturedPiecesView'
import 'ui/MoveGridView'
import 'Utils'
import 'SoundHelper'
import 'engine/LuaJester'

-- playdate.setMinimumGCTime(.0001)
-- playdate.setCollectsGarbage(false)
local gfx <const> = playdate.graphics
local DEBUG <const> = false
local chessGame = ChessGame()
local boardGrid = BoardGridView(chessGame:getBoard())
local dialogBox = DialogBox(200, 120, "", "New Game", "Dismiss")
local progressBar = ProgressBar(255, 145)
local bCapturedPieces = CapturedPieces(270, 13, false)
local wCapturedPieces = CapturedPieces(270, 233, true)
local moveGrid = MoveGrid(254, 70)
local GAME_DIFFICULTY <const> = {
    ["easy"] = { 2, 3 },
    ["med"] = { 5, 6 },
    ["hard"] = { 10, 6 },
    ["expert"] = { 30, 6 },
    ["insane"] = { 60, 6 },
}

chessGame:setDifficulty(GAME_DIFFICULTY["easy"])
playSoundGameState(chessGame:getState())

-- todo remove
-- showToast("Computer still thinking..",90)
-- playdate.drawFPS()
-- progressBar:show()
dialogBox:show()
-- chessGame:setUserPromotePawn()
-- boardGrid:addBoard(chessGame:getBoard())
-- moveGrid:updateMoveGrid(chessGame:getPGNMoves(), true)
-- wCapturedPieces:addPieces(chessGame:getMissingPieces())
-- bCapturedPieces:addPieces(chessGame:getMissingPieces())
-- wCapturedPieces:addPieces({
--     ["p"] = 1,
-- 	["P"] = 1,
-- 	["n"] = 3,
-- 	["N"] = 3,
-- 	["b"] = 3,
-- 	["B"] = 3,
-- 	["r"] = 5,
-- 	["R"] = 5,
-- 	["q"] = 9,
-- 	["Q"] = 9,
-- })
-- bCapturedPieces:addPieces({
--     ["p"] = 1,
-- 	["P"] = 1,
-- 	["n"] = 3,
-- 	["N"] = 3,
-- 	["b"] = 3,
-- 	["B"] = 3,
-- 	["r"] = 5,
-- 	["R"] = 5,
-- 	["q"] = 9,
-- 	["Q"] = 9,
-- })

local function newGame()
    chessGame:newGame()
    boardGrid:clear()
    boardGrid:addBoard(chessGame:getBoard())
    wCapturedPieces:clear()
    bCapturedPieces:clear()
    moveGrid:clear()
    playSoundGameState(chessGame:getState())
end

local function updateMissingPieces(board)
    local missingPieces = chessGame:getMissingPieces(board)
    wCapturedPieces:addPieces(missingPieces)
    bCapturedPieces:addPieces(missingPieces)
end

local function getComputersMove()
    progressBar:show()
    chessGame:moveComputer(
        function()
            -- called when function starts
            boardGrid:addMove(chessGame:getComputersMove())
            boardGrid:addBoard(chessGame:getBoard())
            updateMissingPieces()
            moveGrid:updateMoveGrid(chessGame:getPGNMoves(), false)
            progressBar:hide()
            playSoundGameState(chessGame:getState())
            if chessGame:isGameOver() then
                dialogBox:show(chessGame:getState())
                return
            end
        end,
        function(progress)
            -- called when function ends
            -- if progressBar:isShowing() == false then
            --     progressBar:show()
            -- end
            printDebug("progress = " .. progress .. "%", DEBUG)
            progressBar:updateProgress(progress)
        end
    )
end

local function getUsersMove()
    local from, to = boardGrid:clickCell()
    local result = chessGame:moveUser(from, to)
    if result == false then
        return false
    end
    boardGrid:addMove(chessGame:getUsersMove(),
        function()
            getComputersMove()
        end
    )
    boardGrid:addBoard(chessGame:getBoard())
    updateMissingPieces()
    moveGrid:updateMoveGrid(chessGame:getPGNMoves(), true)
    return true
end

local function gameStateMachine()
    boardGrid:setBoardToActivePos()
    moveGrid:setMoveToActiveMove()
    updateMissingPieces(boardGrid:getVisibleBoard())
    
    local didMove = getUsersMove()
    playSoundGameState(chessGame:getState())
    if didMove == false then
        return
    end
    
    if chessGame:isGameOver() then
        dialogBox:show(chessGame:getState())
        return
    end
end

function playdate.AButtonDown()
    -- computer is still thinking, cant go yet
    if chessGame:isComputerThinking() then
        printDebug("computer still thinking. you cant move yet.", DEBUG)
        return
    end

    if dialogBox:isShowing() then
        dialogBox:dismiss()
        newGame()
        return
    end

    if chessGame:isGameOver() then
        dialogBox:show(chessGame:getState())
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
    local crankTicks = playdate.getCrankTicks(4)
    if crankTicks == 1 then
        boardGrid:nextPosition()
        updateMissingPieces(boardGrid:getVisibleBoard())
        moveGrid:nextMove()
    elseif crankTicks == -1 then
        boardGrid:previousPosition()
        updateMissingPieces(boardGrid:getVisibleBoard())
        moveGrid:prevMove()
    end
end

function playdate.upButtonDown()
    boardGrid:selectPreviousRow(true)
end

function playdate.downButtonDown()
    boardGrid:selectNextRow(true)
end

function playdate.rightButtonDown()
    boardGrid:selectNextColumn(true)
end

function playdate.leftButtonDown()
    boardGrid:selectPreviousColumn(true)
end

function playdate.update()
    gfx.sprite.update()
    playdate.frameTimer.updateTimers()
    playdate.timer:updateTimers()
end

local function initMenu()
    local menu = playdate.getSystemMenu()
    local _, error1 = menu:addOptionsMenuItem("Difficulty", { "easy", "med", "hard", "expert", "insane" }, "easy", function(value)
        -- if chessGame:isComputerThinking() then
        --     printDebug("cant change difficulty while computer is thinking")
        --     return
        -- end
        chessGame:setDifficulty(GAME_DIFFICULTY[value])
    end)

    local _, error2 = menu:addMenuItem("new game", function()
        newGame()
    end)

    local _, error3 = menu:addMenuItem("undo move", function()
        if chessGame:isComputerThinking() then
            showToast("Wait for computers move...",60)
            return
        end
        -- todo this has a bug
        local success = chessGame:undoLastTwoMoves()
        if success then
            boardGrid:setBoardToActivePos()
            boardGrid:removeBoard()
            boardGrid:removeBoard()
            updateMissingPieces(boardGrid:getVisibleBoard())
            moveGrid:removeLastTwoMoves()
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
-- clear selected square on a new game
-- add sound
