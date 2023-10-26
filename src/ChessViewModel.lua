import "CoreLibs/object"
import "CoreLibs/crank"

import 'ui/DialogBoxView'
import 'ui/BoardGridView'
import 'ui/ProgressBarView'
import 'ui/CapturedPiecesView'
import 'ui/MoveGridView'
import 'ui/SettingsScreenView'
import 'ui/Toast'
import 'helper/Utils'
import 'helper/SoundHelper'
import 'helper/Settings'
import 'helper/GameSave'
import 'engine/LuaJester'


local DEBUG <const> = true

class('ChessViewModel').extends()

function ChessViewModel:init()
    ChessViewModel.super.init(self)

    -- {time, depth}
    self.GAME_DIFFICULTY = {
        ["easy"] = { 2, 4 },
        ["med"] = { 10, 4 },
        ["hard"] = { 50, 4 },
        ["harder"] = { 100, 5 },
        ["expert"] = { 200, 5 },
        ["master"] = {500, 6 },
    }
    -- set default settings
    self.settings = Settings({
        [SettingKeys.difficulty] = "easy"
    })

    self.boardGrid = BoardGridView()
    self.dialogBox = DialogBox(200, 120)
    self.progressBar = ProgressBar(260, 155)
    -- self.bCapturedPieces = CapturedPieces(270, 13, false)
    -- self.wCapturedPieces = CapturedPieces(270, 233, true)
    self.capturedPieces = CapturedPieces(255, 0)
    self.moveGrid = MoveGrid(255, 55)
    self.toast = Toast()
    self.chessGame = ChessGame()

    self.chessGame:setDifficulty(
        self.GAME_DIFFICULTY[self.settings:get(SettingKeys.difficulty)]
    )
    
    self.toast:show("loading chess engine", 300, true)
    self.chessGame:newGame(

        -- onProgressCallback
        function(progress)
            self.toast:updateProgress(progress)
        end,

        -- onDoneCallback
        function ()
            self.toast:dismiss()
            self.boardGrid:addBoard(self.chessGame:getBoard())

            self.gameSave = GameSave()
            if self.gameSave:isEmpty() == false then
                self:loadGame()
                self.toast:show("loaded previous game", 60)
            end
        end
    )


    -- local settingsScreen = SettingsScreen()
    -- todo remove
    -- self.progressBar:show()
    -- self.dialogBox:show(GAME_STATE.COMPUTER_WON)
    -- self.chessGame:setUserHasMateInOne()
    -- self.boardGrid:addBoard(self.chessGame:getBoard())
    -- self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), true)
    -- self.wCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    -- self.bCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    -- self.capturedPieces:addPieces({
    --     ["p"] = 7,
    -- 	["P"] = 7,
    -- 	["n"] = 2,
    -- 	["N"] = 2,
    -- 	["b"] = 2,
    -- 	["B"] = 2,
    -- 	["r"] = 2,
    -- 	["R"] = 2,
    -- 	["q"] = 3,
    -- 	["Q"] = 6,
    -- })

    self:setupInputHandler()
    self:setupMenu()
    playSoundGameState(self.chessGame:getState())
end


function ChessViewModel:newGame()
    self.toast:show("restarting chess engine", 60, true)

    self.chessGame:newGame(

        -- onProgressCallback
        function (progress)
            self.toast:updateProgress(progress)
        end,

        -- onDoneCallback
        function ()
            self.toast:dismiss()
            self.boardGrid:clear()
            self.boardGrid:addBoard(self.chessGame:getBoard())
            -- self.wCapturedPieces:clear()
            -- self.bCapturedPieces:clear()
            self.capturedPieces:clear()
            self.moveGrid:clear()
            self.progressBar:hide()
            playSoundGameState(self.chessGame:getState())
        end
    )
end

-- function ChessViewModel:updateMissingPieces(board)
--     local missingPieces = self.chessGame:getMissingPieces(board)
--     self.wCapturedPieces:addPieces(missingPieces)
--     self.bCapturedPieces:addPieces(missingPieces)
-- end

function ChessViewModel:getComputersMove()
    self.progressBar:show()
    self.chessGame:moveComputer(
        -- onProgressCallback
        function(progress)
            printDebug("ChessViewModel: progress = " .. progress .. "%".." time="..playdate.getElapsedTime(), DEBUG)
            self.progressBar:updateProgress(progress)
        end,

        -- onDoneCallback
        function()
            -- local board = self.chessGame:getBoard()
            self.boardGrid:setBoardToActivePos()
            self.boardGrid:addMove(self.chessGame:getComputersMove())
            self.boardGrid:addBoard(self.chessGame:getBoard())
            -- self:updateMissingPieces()
            self.capturedPieces:addPieces(self.chessGame:getMissingPieces())
            self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), false)
            self.progressBar:hide()
            playSoundGameState(self.chessGame:getState())
            if self.chessGame:isGameOver() then
                self.dialogBox:show(self.chessGame:getState())
                return
            end
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
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces())
    -- self:updateMissingPieces()
    self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), true)
    return true
end

function ChessViewModel:gameStateMachine()
    self.boardGrid:setBoardToActivePos()
    self.moveGrid:setMoveToActiveMove()
    -- self:updateMissingPieces(self.boardGrid:getVisibleBoard())
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
    
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
        self.toast:show("undid 2 moves", 50)
        self.boardGrid:setBoardToActivePos()
        self.boardGrid:removeBoard()
        self.boardGrid:removeBoard()
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        -- self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.moveGrid:removeLastTwoMoves()
    else
        self.toast:show("nothing to undo",50)
    end
end

function ChessViewModel:loadGame()
    self.boardGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.BoardGridView))
    self.moveGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.MoveGridView))
    self.chessGame:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.ChessGame))
    self.gameSave:delete()

    -- self.wCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    -- self.bCapturedPieces:addPieces(self.chessGame:getMissingPieces())
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces())
end

function ChessViewModel:saveGame()
    if self.chessGame:getState() ~= GAME_STATE.NEW_GAME and
        -- self.chessGame:isGameOver() == false and
        self.chessGame:isComputerThinking() == false then
        self.toast:show("saving game",60)
        -- if computer is mid move the entire game wont be saved
        -- its difficult to handle the case were computer is mid move
        self.gameSave:put(GAME_SAVE_KEYS.BoardGridView,self.boardGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.MoveGridView,self.moveGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.ChessGame,self.chessGame:toSavedTable())
        self.gameSave:save()
    end
end

-- function ChessViewModel:APressed()
--     if self.chessGame:isComputerThinking() then
--         self.toast:show("wait for computers move",30)
--         return
--     end

--     if self.chessGame:isGameLoading() then
--         self.toast:show("wait for game to load",30)
--         return
--     end

--     if self.dialogBox:isShowing() then
--         self.dialogBox:dismiss()
--         self:newGame()
--         return
--     end

--     if self.chessGame:isGameOver() then
--         self.dialogBox:show(self.chessGame:getState())
--         return
--     end

--     self:gameStateMachine()
-- end

function ChessViewModel:cranked()
    local crankTicks = playdate.getCrankTicks(4)
    if crankTicks == 1 then
        self.boardGrid:nextPosition()
        -- self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        self.moveGrid:nextMove()
    elseif crankTicks == -1 then
        self.boardGrid:previousPosition()
        -- self:updateMissingPieces(self.boardGrid:getVisibleBoard())
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        self.moveGrid:prevMove()
    end
end

function ChessViewModel:setupInputHandler()
    local chessViewModelInputHandler = {

		AButtonDown = function ()
            if self.chessGame:isComputerThinking() then
                self.toast:show("wait for computers move",30)
                return
            end
        
            if self.chessGame:isGameLoading() then
                self.toast:show("wait for game to load",30)
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
		end,

        cranked = function (change, acceleratedChange)
            if self.chessGame:isGameLoading() then
                self.toast:show("wait for game to load",30)
                return
            end
            self:cranked()
        end
	}
    playdate.inputHandlers.push(chessViewModelInputHandler)
end

function ChessViewModel:setupMenu()
    local menu = playdate.getSystemMenu()
    
    menu:addOptionsMenuItem("Difficulty", { "easy", "med", "hard", "harder", "expert", "master" }, self.settings:get(SettingKeys.difficulty), function(value)
        self.toast:show("computer thinks "..self.GAME_DIFFICULTY[value][2].. " moves ahead and\nspends up to "..self.GAME_DIFFICULTY[value][1].." seconds thinking", 120)
        self.chessGame:setDifficulty(self.GAME_DIFFICULTY[value])
        self.settings:set(SettingKeys.difficulty, value)
        self.settings:save()
    end)

    menu:addMenuItem("new game", function()
        self:newGame()
    end)

    menu:addMenuItem("undo move", function()
        if self.chessGame:isComputerThinking() then
            self.toast:show("wait for computers move",30)
            return
        end
        -- todo this has a bug
        self:undoMove()
    end)
end
