import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ChessViewModel'

local frameTimer <const> = playdate.frameTimer
local timer <const> = playdate.timer
local sprite <const> = gfx.sprite

local chessViewModel = ChessViewModel()

playdate.setMinimumGCTime(10)

function playdate.update()
    sprite.update()
    playdate.drawFPS(0,0)
    frameTimer:updateTimers()
    timer:updateTimers()
end

function playdate.gameWillTerminate()
    chessViewModel:saveGame()
end

function playdate.deviceWillSleep()
    chessViewModel:saveGame()
end

-- TODO
-- Intro Screen?
-- change color
-- history of previous games
-- show what the computer is thinking
-- make dialogs look better (font, alignment) verify all of them
