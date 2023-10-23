import "CoreLibs/object"
import "CoreLibs/crank"

import 'ui/DialogBoxView'
import 'ui/BoardGridView'
import 'ui/ProgressBarView'
import 'ui/CapturedPiecesView'
import 'ui/MoveGridView'
import 'ui/SettingsScreenView'
import 'helper/Utils'
import 'helper/SoundHelper'
import 'helper/Settings'
import 'helper/GameSave'
import 'engine/LuaJester'


local DEBUG <const> = true

class('ChessViewModel').extends()

function ChessViewModel:init()
    ChessViewModel.super.init(self)

    self.chessGame = ChessGame()
    self.boardGrid = BoardGridView(self.chessGame:getBoard())
    self.dialogBox = DialogBox(200, 120)
    self.progressBar = ProgressBar(255, 145)
    self.bCapturedPieces = CapturedPieces(270, 13, false)
    self.wCapturedPieces = CapturedPieces(270, 233, true)
    self.moveGrid = MoveGrid(254, 70)
    -- {time, depth}
    self.GAME_DIFFICULTY = {
        ["easy"] = { 2, 3 },
        ["med"] = { 5, 6 },
        ["hard"] = { 10, 9 },
        ["harder"] = { 30, 10 },
        ["expert"] = { 60, 14 },
        ["master"] = {180, 16 },
    }

    -- set default settings
    self.settings = Settings({
        [SettingKeys.difficulty] = "easy"
    })
    
    self.chessGame:setDifficulty(
        self.GAME_DIFFICULTY[self.settings:get(SettingKeys.difficulty)]
    )

    self.gameSave = GameSave()
    if self.gameSave:isEmpty() == false then
        self:loadGame()
        showToast("loaded previous game", 30)
    end

    -- local settingsScreen = SettingsScreen()

    -- todo remove
    -- playdate.drawFPS()
    -- self.progressBar:show()
    -- self.dialogBox:show(GAME_STATE.COMPUTER_WON)
    -- self.chessGame:setUserHasMateInOne()
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
    self:setupInputHandler()
    self:setupMenu()
    playSoundGameState(self.chessGame:getState())
end


function ChessViewModel:newGame()
    self.chessGame:newGame()
    self.boardGrid:clear()
    self.boardGrid:addBoard(self.chessGame:getBoard())
    self.wCapturedPieces:clear()
    self.bCapturedPieces:clear()
    self.moveGrid:clear()
    self.progressBar:hide()
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
            printDebug("ChessViewModel: progress = " .. progress .. "%", DEBUG)
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

-- undo last 2 moves
function ChessViewModel:undoMove()
    local success = self.chessGame:undoLastTwoMoves()
    if success then
        showToast("undid 2 moves", 30)
        self.boardGrid:setBoardToActivePos()
        self.boardGrid:removeBoard()
        self.boardGrid:removeBoard()
        self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.moveGrid:removeLastTwoMoves()
    else
        showToast("nothing to undo",30)
    end
end

function ChessViewModel:loadGame()
    self.boardGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.BoardGridView))
    self.moveGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.MoveGridView))
    self.chessGame:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.ChessGame))
    self.gameSave:delete()

    self.wCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    self.bCapturedPieces:addPieces(self.chessGame:getMissingPieces())
end

function ChessViewModel:saveGame()
    if self.chessGame:getState() ~= GAME_STATE.NEW_GAME and
        -- self.chessGame:isGameOver() == false and
        self.chessGame:isComputerThinking() == false then
        showToast("saving game",60)
        playdate.display.flush()
        playdate.update()
        -- if computer is mid move the entire game wont be saved
        -- its difficult to handle the case were computer is mid move
        self.gameSave:put(GAME_SAVE_KEYS.BoardGridView,self.boardGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.MoveGridView,self.moveGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.ChessGame,self.chessGame:toSavedTable())
        self.gameSave:save()
    end
end

function ChessViewModel:APressed()
    if self.chessGame:isComputerThinking() then
        printDebug("ChessViewModel: computer still thinking. you cant move yet.", DEBUG)
        showToast("wait for computers move...",30)
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

-- function ChessViewModel:BPressed()
--     -- user wants to dismiss end game dialog
--     if self.dialogBox:isShowing() then
--         self.dialogBox:dismiss()
--     end
-- end

-- function ChessViewModel:UpPressed()
--    self.boardGrid:selectPreviousRow(true)
-- end

-- function ChessViewModel:DownPressed()
--    self. boardGrid:selectNextRow(true)
-- end

-- function ChessViewModel:LeftPressed()
--     self.boardGrid:selectPreviousColumn(true)
-- end

-- function ChessViewModel:RightPressed()
--     self.boardGrid:selectNextColumn(true)
-- end

function ChessViewModel:cranked()
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

function ChessViewModel:setupInputHandler()
    local chessViewModelInputHandler = {

		AButtonDown = function ()
            self:APressed()
		end,

        cranked = function (change, acceleratedChange)
            self:cranked()
        end
	}
    playdate.inputHandlers.push(chessViewModelInputHandler)
end

function ChessViewModel:setupMenu()
    local menu = playdate.getSystemMenu()
    
    menu:addOptionsMenuItem("Difficulty", { "easy", "med", "hard", "harder", "expert", "master" }, self.settings:get(SettingKeys.difficulty), function(value)
        showToast("computer thinks "..self.GAME_DIFFICULTY[value][2].. " moves ahead and\nspends up to "..self.GAME_DIFFICULTY[value][1].." seconds thinking", 120)
        self.chessGame:setDifficulty(self.GAME_DIFFICULTY[value])
        self.settings:set(SettingKeys.difficulty, value)
        self.settings:save()
    end)

    menu:addMenuItem("new game", function()
        self:newGame()
    end)

    menu:addMenuItem("undo move", function()
        if self.chessGame:isComputerThinking() then
            showToast("wait for computers move...",30)
            return
        end
        -- todo this has a bug
        self:undoMove()
    end)
end
