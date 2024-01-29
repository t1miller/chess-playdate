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


local DEBUG <const> = false
-- {time, depth}
local GAME_DIFFICULTY = {
    ["level 1"] = { 2, 4 },
    ["level 2"] = { 10, 4 },
    ["level 3"] = { 25, 5 },
    ["level 4"] = { 100, 6 },
    ["level 5"] = { 200, 6 },
    ["level 6"] = {300, 7 },
}

class('ChessViewModel').extends()

function ChessViewModel:init()
    ChessViewModel.super.init(self)

    self:setupInputHandler()
    -- get settings
    self.settings = Settings({
        [SettingKeys.difficulty] = "level 1",
        [SettingKeys.isUserWhite] = true
    })
    self.difficulty = self.settings:get(SettingKeys.difficulty)
    self.isUserWhite = self.settings:get(SettingKeys.isUserWhite)

    -- setup UI
    self.boardGrid = BoardGrid(self.isUserWhite)
    self.capturedPieces = CapturedPieces(self.isUserWhite, 255, 0)
    self.moveGrid = MoveGrid(255, 55)
    self.progressBar = ProgressBar(260, 160)
    self.toast = Toast()

    -- setup engine
    self.chessGame = ChessGame()
    self.chessGame:setDifficulty(
        GAME_DIFFICULTY[self.difficulty]
    )

    -- self:showChooseColorDialog()

    self:newGame(self.isUserWhite, true)
    self:setupMenu()
end

function ChessViewModel:changeColor()
    self.boardGrid:changeColor(self.isUserWhite)
    self.capturedPieces:changeColor(self.isUserWhite)
end

function ChessViewModel:newGame(isUserWhite, gameJustLaunched)

    if gameJustLaunched then
        self.toast:show("Loading chess engine", 300, true)
    else
        self.toast:show("Restarting chess engine", 60, true)
    end

    if isUserWhite ~= self.isUserWhite then
        self.isUserWhite = isUserWhite
        self:changeColor()
    end

    self.chessGame:newGame(isUserWhite,

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

            local loadedGame = false
            if gameJustLaunched then
                self.gameSave = GameSave()
                if self.gameSave:exists() then
                    -- todo handle case when color is black
                    self:loadPrevGame()
                    self.toast:show("Loaded previous game.", 60)
                    loadedGame = true
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
            -- self:showEndGameDialog(GAME_STATE.USER_WON)

            if not loadedGame and not self.isUserWhite then
                self:getComputersMove()
            end
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
            self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), not self.isUserWhite)
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
    if not result then
        return false
    end
    self.boardGrid:addMove(self.chessGame:getUsersMove(),
        function()
            self:getComputersMove()
        end
    )
    self.boardGrid:addBoard(self.chessGame:getBoard())
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces())
    self.moveGrid:updateMoveGrid(self.chessGame:getPGNMoves(), self.isUserWhite)
    return true
end

function ChessViewModel:gameStateMachine()
    self.boardGrid:setBoardToActivePos()
    self.moveGrid:setMoveToActiveMove()
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces(self.boardGrid:getVisibleBoard()))
    
    local didMove = self:getUsersMove()
    playSoundGameState(self.chessGame:getState())
    if not didMove then
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

    -- todo is this neccessary
    self.capturedPieces:addPieces(self.chessGame:getMissingPieces())

    self.gameSave:delete()
end

function ChessViewModel:saveGame()
    if self.chessGame:getState() ~= GAME_STATE.NEW_GAME
        and not self.chessGame:isComputerThinking() then

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
    
    self.difficultyMenuItem = menu:addOptionsMenuItem("Difficulty", { "level 1", "level 2", "level 3", "level 4", "level 5", "level 6" }, self.difficulty, function(value)

        local difficultyToast = Toast(200,25)
        difficultyToast:show("Difficulty: "..value.."\nComputer thinks "..GAME_DIFFICULTY[value][2].." moves ahead and\nspends up to "..GAME_DIFFICULTY[value][1].." seconds thinking.", 180)

        self.chessGame:setDifficulty(GAME_DIFFICULTY[value])
        self.settings:set(SettingKeys.difficulty, value)
        self.settings:save()
    end)

    menu:addMenuItem("new game", function()
        self:showChooseColorDialog()
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
    local endGameDialog = Dialog(200, 120, nil, nil, nil, nil, "Ⓐ New Game\nⒷ Dismiss")
    endGameDialog:setButtonCallbacks(
        -- a button clicked
        function ()
            self:newGame(self.isUserWhite, false)
            endGameDialog:dismiss()
        end,

        -- b button clicked
        function ()
            endGameDialog:dismiss()
        end
    )
    endGameDialog:setTitleAndDescription(self.isUserWhite, state)
    endGameDialog:show()
end

function ChessViewModel:showChooseColorDialog()
    local chooseColorDialog = Dialog(200, 120, nil, 130, "Choose Side", nil, "Ⓐ White Pieces\nⒷ Black Pieces")
    chooseColorDialog:setOffsets(nil, nil, 15, 45, 60, 70)
    chooseColorDialog:setButtonCallbacks(
        -- a button clicked
        function ()
            self.settings:set(SettingKeys.isUserWhite, true)
            self.settings:save()
            self:newGame(true, false)
            chooseColorDialog:dismiss()
        end,

        -- b button clicked
        function ()
            self.settings:set(SettingKeys.isUserWhite, false)
            self.settings:save()
            self:newGame(false, false)
            chooseColorDialog:dismiss()
        end
    )
    chooseColorDialog:show()
end

