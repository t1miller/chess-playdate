import "CoreLibs/object"
import "CoreLibs/crank"

import 'ui/DialogBoxView'
import 'ui/BoardGridView'
import 'ui/ProgressBarView'
import 'ui/CapturedPiecesView'
import 'ui/MoveGridView'
import 'helper/Utils'
import 'helper/SoundHelper'
import 'engine/LuaJester'


local DEBUG <const> = false

class('ChessViewModel', {}).extends()

function ChessViewModel:init()
    ChessViewModel.super.init(self)

    self.chessGame = ChessGame()
    self.boardGrid = BoardGridView(self.chessGame:getBoard())
    self.dialogBox = DialogBox(200, 120, "", "New Game", "Dismiss")
    self.progressBar = ProgressBar(255, 145)
    self.bCapturedPieces = CapturedPieces(270, 13, false)
    self.wCapturedPieces = CapturedPieces(270, 233, true)
    self.moveGrid = MoveGrid(254, 70)

    self.GAME_DIFFICULTY = {
        ["easy"] = { 2, 3 },
        ["med"] = { 5, 6 },
        ["hard"] = { 10, 6 },
        ["expert"] = { 30, 6 },
        ["insane"] = { 60, 6 },
    }

    playSoundGameState(self.chessGame:getState())

    self.chessGame:setDifficulty(self.GAME_DIFFICULTY["easy"])
    
    self:initMenu()
    -- todo remove
    -- showToast("Computer still thinking..",90)
    -- playdate.drawFPS()
    -- progressBar:show()
    -- self.dialogBox:show(GAME_STATE.DRAW)
    -- self.chessGame:setComputerPromotePawn()
    -- self.boardGrid:addBoard(self.chessGame:getBoard())
    -- self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), true)
    -- self.wCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    -- self.bCapturedPieces:addPieces(self.chessGame:getMissingPieces())
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
end


function ChessViewModel:newGame()
    self.chessGame:newGame()
    self.boardGrid:clear()
    self.boardGrid:addBoard(self.chessGame:getBoard())
    self.wCapturedPieces:clear()
    self.bCapturedPieces:clear()
    self.moveGrid:clear()
    playSoundGameState(self.chessGame:getState())
end

function ChessViewModel:updateMissingPieces(board)
    local missingPieces = self.chessGame:getMissingPieces(board)
    self.wCapturedPieces:addPieces(missingPieces)
    self.bCapturedPieces:addPieces(missingPieces)
end

function ChessViewModel:getComputersMove()
    self.progressBar:show()
    self.chessGame:moveComputer(
        function()
            -- called when function starts
            self.boardGrid:addMove(self.chessGame:getComputersMove())
            self.boardGrid:addBoard(self.chessGame:getBoard())
            self:updateMissingPieces()
            self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), false)
            self.progressBar:hide()
            playSoundGameState(self.chessGame:getState())
            if self.chessGame:isGameOver() then
                self.dialogBox:show(self.chessGame:getState())
                return
            end
        end,
        function(progress)
            -- called when function ends
            -- if progressBar:isShowing() == false then
            --     progressBar:show()
            -- end
            printDebug("progress = " .. progress .. "%", DEBUG)
            self.progressBar:updateProgress(progress)
        end
    )
end

function ChessViewModel:getUsersMove()
    local from, to = self.boardGrid:clickCell()
    local result = self.chessGame:moveUser(from, to)
    if result == false then
        return false
    end
    self.boardGrid:addMove(self.chessGame:getUsersMove(),
        function()
            self:getComputersMove()
        end
    )
    self.boardGrid:addBoard(self.chessGame:getBoard())
    self:updateMissingPieces()
    self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), true)
    return true
end

function ChessViewModel:gameStateMachine()
    self.boardGrid:setBoardToActivePos()
    self.moveGrid:setMoveToActiveMove()
    self:updateMissingPieces(self.boardGrid:getVisibleBoard())
    
    local didMove = self:getUsersMove()
    playSoundGameState(self.chessGame:getState())
    if didMove == false then
        return
    end
    
    if self.chessGame:isGameOver() then
        self.dialogBox:show(self.chessGame:getState())
        return
    end
end

function ChessViewModel:APressed()
    if self.chessGame:isComputerThinking() then
        printDebug("computer still thinking. you cant move yet.", DEBUG)
        return
    end

    if self.dialogBox:isShowing() then
        self.dialogBox:dismiss()
        self:newGame()
        return
    end

    if self.chessGame:isGameOver() then
        self.dialogBox:show(self.chessGame:getState())
        return
    end

    self:gameStateMachine()
end

function ChessViewModel:BPressed()
    -- user wants to dismiss end game dialog
    if self.dialogBox:isShowing() then
        self.dialogBox:dismiss()
    end
end

function ChessViewModel:UpPressed()
   self.boardGrid:selectPreviousRow(true)
end

function ChessViewModel:DownPressed()
   self. boardGrid:selectNextRow(true)
end

function ChessViewModel:LeftPressed()
    self.boardGrid:selectPreviousColumn(true)
end

function ChessViewModel:RightPressed()
    self.boardGrid:selectNextColumn(true)
end

function ChessViewModel:crankMoved()
    local crankTicks = playdate.getCrankTicks(4)
    if crankTicks == 1 then
        self.boardGrid:nextPosition()
        self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.moveGrid:nextMove()
    elseif crankTicks == -1 then
        self.boardGrid:previousPosition()
        self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.moveGrid:prevMove()
    end
end

function ChessViewModel:initMenu()
    local menu = playdate.getSystemMenu()
    
    menu:addOptionsMenuItem("Difficulty", { "easy", "med", "hard", "expert", "insane" }, "easy", function(value)
        self.chessGame:setDifficulty(self.GAME_DIFFICULTY[value])
    end)

    menu:addMenuItem("new game", function()
        self:newGame()
    end)

    menu:addMenuItem("undo move", function()
        if self.chessGame:isComputerThinking() then
            showToast("Wait for computers move...",60)
            return
        end
        -- todo this has a bug
        local success = self.chessGame:undoLastTwoMoves()
        if success then
            self.boardGrid:setBoardToActivePos()
            self.boardGrid:removeBoard()
            self.boardGrid:removeBoard()
            self:updateMissingPieces(self.boardGrid:getVisibleBoard())
            self.moveGrid:removeLastTwoMoves()
        end
    end)
end
