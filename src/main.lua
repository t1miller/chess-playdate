import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/crank"

import 'ui/dialogBox'
import 'ui/boardGrid'
import 'ui/progressBar'
-- import 'sunfishChessGame'
-- import 'sunfish'
-- import 'ChessGame/example'
-- import 'sargonChessGame'

-- import 'Lua4chess/garbochess' -- cant even get desktop version working
import 'engine/LuaJester' -- it works!
-- import 'Lua4chess/fruit21chess' --// freezes in init() when calling 
-- import 'Lua4chess/OwlChess'

-- bit = import 'bitop/funcs'
-- bit = import 'Lua4chess/noBitOp'
-- printTable(bit)



local gfx <const> = playdate.graphics
local chessGame = ChessGame()
local boardGridView = BoardGridLayout(chessGame:getBoard())
local dialogBox = DialogBox("", "New Game", "Dismiss")
local progressBar = ProgressBar(320,15)


local function showDialog()
  local state = chessGame:getState()
  if state == GAME_STATE.USER_WON then
    dialogBox:updateText("Checkmate\nWhite Wins!")
  elseif state == GAME_STATE.COMPUTER_WON then
    dialogBox:updateText("Checkmate\nBlack Wins!")
  elseif state == GAME_STATE.DRAW then
    dialogBox:updateText("Draw!")
  elseif state == GAME_STATE.DRAW_BY_REPITION then
    dialogBox:updateText("Draw By Repetition!")
  elseif state == GAME_STATE.STALEMATE then
    dialogBox:updateText("Stalemate!")
  elseif state == GAME_STATE.INSUFFICIENT_MATERIAL then
    dialogBox:updateText("Insufficient Material\nDraw!")
  end
  dialogBox:show()
end

local function gameStateMachine()

  -- game ended dialog is showing and user
  -- clicked A, start a new game
  if dialogBox:isShowing() then
    dialogBox:dismiss()
    chessGame = ChessGame()
    boardGridView:clearGameData()
    boardGridView:addBoard(chessGame:getBoard())
    return
  end

  -- game ended and end game dialog isn't showing
  -- show game ended dialog
  if chessGame:isGameOver() then
    showDialog()
    return
  end

  -- game hasnt ended, get users move 
  local from, to = boardGridView:clickCell()
  chessGame:move(from, to, true)
  if chessGame:getState() == GAME_STATE.INVALID_MOVE then
    return
  end
  boardGridView:addBoard(chessGame:getBoard())


  -- the game just ended after a user move
  -- or a computer move, show game ended dialog
  if chessGame:isGameOver() then
    showDialog()
    return
  end

  -- game hasnt ended, get computers move
  if chessGame:isGameOver() == false then
    -- show progress bar while computer is thinking
    progressBar:show()
    chessGame:move("", "", false, 
      function()
        boardGridView:addBoard(chessGame:getBoard())
        if chessGame:isGameOver() then
          showDialog()
          return
        end
        -- hide progress bar after done thinking
        progressBar:hide()
      end,
      function (progress)
        print("progress = "..progress.."%")
        progressBar:updateProgress(progress)
      end
    )
  end

end

function playdate.AButtonDown()
  -- computer is still thinking, cant go yet 
  if progressBar:isShowing() then
    print("computer still thinking. you cant move yet.")
    return
  end

  gameStateMachine()
end

function playdate.BButtonDown()
  -- user wants to dismiss dialog end game dialog
  -- so they can review the game 
  if dialogBox:isShowing() then
    dialogBox:dismiss()
  end
end

function playdate.cranked(change, acceleratedChange)
  local crankTicks = playdate.getCrankTicks(4)
  if crankTicks == 1 then
    boardGridView:nextPosition()
  elseif crankTicks == -1 then
    boardGridView:previousPosition()
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

playdate.display.setRefreshRate(20)
function playdate.update()

  -- if boardGridView:needsDisplay() == true then
  --   boardGridView:drawGridView()
  --   print("playdate.update() calling drawGridView()")
  -- end
  -- check if move coroutine is still calculating after x amount of frames
  -- if it is yield 
  -- resume after x amount of frames

  gfx.sprite.update()
  playdate.timer:updateTimers()
end

-- easy - 2 second timeout
-- medium - 4 second timeout
-- hard - 8 second timeout
-- expert - 15 second timeout
GAME_DIFFICULTY = {
  ["Easy"] = 1,
  ["Med"] = 4,
  ["Hard"] = 8,
  ["Expert"] = 15,
}

local function setupMenu()
  local menu = playdate.getSystemMenu()

  local _, error = menu:addOptionsMenuItem("Difficulty", {"Easy","Med","Hard","Expert"}, "Med", function(value)
    print("difficulty menu item selected: "..value)
    chessGame:setDifficulty(GAME_DIFFICULTY[value])
  end)

  local _, error = menu:addMenuItem("New Game", function ()
    chessGame = ChessGame()
    boardGridView:clearGameData()
    boardGridView:addBoard(chessGame:getBoard())
  end)

  local _, error = menu:addMenuItem("undo move", function ()
    if chessGame:isComputerThinking() then
      print("cant undo move while computer is thinking")
      return
    end
    chessGame:undoLastTwoMoves()
    boardGridView:removeBoard()
    boardGridView:removeBoard()
  end)

end

setupMenu()

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
