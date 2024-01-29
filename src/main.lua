import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ChessViewModel'

local frameTimer <const> = playdate.frameTimer
local timer <const> = playdate.timer
local sprite <const> = playdate.graphics.sprite

local chessViewModel = ChessViewModel()

playdate.setMinimumGCTime(10)

function playdate.update()
    sprite:update()
    frameTimer:updateTimers()
    timer:updateTimers()
end

function playdate.gameWillTerminate()
    chessViewModel:saveGame()
end

function playdate.deviceWillSleep()
    chessViewModel:saveGame()
end