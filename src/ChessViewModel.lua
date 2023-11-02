import "CoreLibs/object"
import "CoreLibs/crank"

import 'ui/BoardGrid'
import 'ui/ProgressBar'
import 'ui/CapturedPieces'
import 'ui/MoveGrid'
import 'ui/Toast'
import 'ui/Dialog'
import 'helper/Utils'
import 'helper/SoundHelper'
import 'helper/Settings'
import 'helper/GameSave'
import 'engine/LuaJester'


local DEBUG <const> = true

class('ChessViewModel').extends()

function ChessViewModel:init()
    ChessViewModel.super.init(self)

    self:setupInputHandler()

    -- {time, depth}
    self.GAME_DIFFICULTY = {
        ["level 1"] = { 2, 4 },
        ["level 2"] = { 10, 4 },
        ["level 3"] = { 25, 5 },
        ["level 4"] = { 100, 6 },
        ["level 5"] = { 200, 6 },
        ["level 6"] = {300, 7 },
    }
    self.settings = Settings({[SettingKeys.difficulty] = "level 1"})
    self.boardGrid = BoardGrid()
    self.progressBar = ProgressBar(260, 160)
    self.capturedPieces = CapturedPieces(255, 0)
    self.moveGrid = MoveGrid(255, 55)
    self.toast = Toast()
    self.chessGame = ChessGame()
    self.chessGame:setDifficulty(
        self.GAME_DIFFICULTY[self.settings:get(SettingKeys.difficulty)]
    )

    self.toast:show("Loading chess engine", 300, true)
    self:newGame(true)

    -- self:showChangeDifficultyDialog("level 1", "level 2")
    -- self:showEndGameDialog(GAME_STATE.COMPUTER_WON)

    self:setupMenu()
    playSoundGameState(self.chessGame:getState())
end


function ChessViewModel:newGame(gameJustLaunched)
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
            self.capturedPieces:clear()
            self.moveGrid:clear()
            self.progressBar:hide()

            if gameJustLaunched then
                self.gameSave = GameSave()
                if self.gameSave:exists() then
                    self:loadPrevGame()
                    self.toast:show("Loaded previous game.", 60)
                end
            end
            -- self.progressBar:show()
            -- self.boardGrid:addBoard(self.chessGame:getBoard())
            -- self.capturedPieces:addPieces({
            --     ["p"] = 7,
            --     ["P"] = 7,
            --     ["n"] = 2,
            --     ["N"] = 2,
            --     ["b"] = 2,
            --     ["B"] = 2,
            --     ["r"] = 2,
            --     ["R"] = 2,
            --     ["q"] = 3,
            --     ["Q"] = 6,
            -- })
            playSoundGameState(self.chessGame:getState())
        end
    )
end

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
            self.boardGrid:setBoardToActivePos()
            self.boardGrid:addMove(self.chessGame:getComputersMove())
            self.boardGrid:addBoard(self.chessGame:getBoard())
            self.capturedPieces:addPieces(self.chessGame:getMissingPieces())
            self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), false)
            self.progressBar:hide()
            playSoundGameState(self.chessGame:getState())
            if self.chessGame:isGameOver() then
                self:showEndGameDialog(self.chessGame:getState())
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
    self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), true)
    return true
end

function ChessViewModel:gameStateMachine()
    self.boardGrid:setBoardToActivePos()
    self.moveGrid:setMoveToActiveMove()
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
    
    local didMove = self:getUsersMove()
    playSoundGameState(self.chessGame:getState())
    if didMove == false then
        return
    end
end

-- undo last 2 moves
function ChessViewModel:undoMove()
    local success = self.chessGame:undoLastTwoMoves()
    if success then
        self.toast:show("Undid 2 moves.", 50)
        self.boardGrid:setBoardToActivePos()
        self.boardGrid:removeBoard()
        self.boardGrid:removeBoard()
        self.boardGrid:clearAvailableMoves()
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        self.moveGrid:removeLastTwoMoves()
    else
        self.toast:show("Nothing to undo.",50)
    end
end

function ChessViewModel:loadPrevGame()
    self.boardGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.BoardGrid))
    self.moveGrid:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.MoveGrid))
    self.chessGame:initFromSavedTable(self.gameSave:get(GAME_SAVE_KEYS.ChessGame))
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces())

    self.gameSave:delete()
end

function ChessViewModel:saveGame()
    if self.chessGame:getState() ~= GAME_STATE.NEW_GAME
        and self.chessGame:isComputerThinking() == false then

        -- if computer is mid move the entire game wont be saved
        -- its difficult to handle the case were computer is mid move
        self.gameSave:put(GAME_SAVE_KEYS.BoardGrid,self.boardGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.MoveGrid,self.moveGrid:toSavedTable())
        self.gameSave:put(GAME_SAVE_KEYS.ChessGame,self.chessGame:toSavedTable())
        self.gameSave:save()
    end
end

function ChessViewModel:cranked()
    local crankTicks = playdate.getCrankTicks(4)
    if crankTicks == 1 then
        self.boardGrid:nextPosition()
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        self.moveGrid:nextMove()
    elseif crankTicks == -1 then
        self.boardGrid:previousPosition()
        self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
        self.moveGrid:prevMove()
    end
end

function ChessViewModel:setupInputHandler()
    local chessViewModelInputHandler = {

		AButtonDown = function ()
            if self.chessGame:isComputerThinking() then
                self.toast:show("Wait for computers move.",30)
                return
            end
        
            if self.chessGame:isGameLoading() then
                self.toast:show("Wait for game to load.",30)
                return
            end
        
            if self.chessGame:isGameOver() then
                self:showEndGameDialog(self.chessGame:getState())
                return
            end
        
            self:gameStateMachine()
		end,

        cranked = function (change, acceleratedChange)
            if self.chessGame:isGameLoading() then
                self.toast:show("Wait for game to load.",30)
                return
            end

            if self.chessGame:isComputerThinking() then
                self.toast:show("Wait for computers move.",30)
                return
            end

            self:cranked()
        end
	}
    playdate.inputHandlers.push(chessViewModelInputHandler)
end

function ChessViewModel:setupMenu()
    local menu = playdate.getSystemMenu()
    
    self.difficultyMenuItem = menu:addOptionsMenuItem("Difficulty", { "level 1", "level 2", "level 3", "level 4", "level 5", "level 6" }, self.settings:get(SettingKeys.difficulty), function(value)
        local originalDifficulty = self.settings:get(SettingKeys.difficulty)
        local newDifficulty = value
        if originalDifficulty ~= newDifficulty then
            self:showChangeDifficultyDialog(originalDifficulty, newDifficulty)
        end
    end)

    menu:addMenuItem("new game", function()
        self.toast:show("Restarting chess engine", 60, true)
        self:newGame()
    end)

    menu:addMenuItem("undo move", function()
        if self.chessGame:isComputerThinking() then
            self.toast:show("Wait for computers move.",30)
            return
        end
        self:undoMove()
    end)
end

function ChessViewModel:showEndGameDialog(state)
    local endGameDialog = Dialog(200, 120, nil, nil, "Ⓐ New Game\nⒷ Dismiss")
    endGameDialog:setButtonCallbacks(
        -- a button clicked
        function ()
            self.toast:show("Restarting chess engine", 60, true)
            self:newGame()
            endGameDialog:dismiss()
        end,

        -- b button clicked
        function ()
            endGameDialog:dismiss()
        end
    )
    endGameDialog:setTitleAndDescription(state)
    endGameDialog:show()
end

function ChessViewModel:showChangeDifficultyDialog(originalDifficulty, newDifficulty)
    local confirmationDialog = Dialog(200, 120, "New Game", "Changing difficulty requires\nstarting a new game. Are \nyou sure?", "Ⓐ New Game\nⒷ Ignore Change")
    confirmationDialog:setFonts(nil, playdate.graphics.font.new("fonts/Roobert-11-Medium"), nil)
    confirmationDialog:setAlignments(kTextAlignment.center, kTextAlignment.left, nil)
    confirmationDialog:setOffsets(nil, 5, 15, 45, 50, 120)
    confirmationDialog:setButtonCallbacks(
        -- a button clicked
        function ()
            self.chessGame:setDifficulty(self.GAME_DIFFICULTY[newDifficulty])
            self.settings:set(SettingKeys.difficulty, newDifficulty)
            self.settings:save()
            confirmationDialog:dismiss()

            local difficultyToast = Toast(200,25)
            difficultyToast:show("Difficulty: "..newDifficulty.."\nComputer thinks "..self.GAME_DIFFICULTY[newDifficulty][2].." moves ahead and\nspends up to "..self.GAME_DIFFICULTY[newDifficulty][1].." seconds thinking.", 180)
            self.toast:show("Restarting chess engine.", 60, true)
            self:newGame()
        end,

        -- b button clicked
        function ()
            self.difficultyMenuItem:setValue(originalDifficulty)
            confirmationDialog:dismiss()
        end
    )
    confirmationDialog:show()
end