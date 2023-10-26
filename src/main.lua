import "CoreLibs/crank"
import "CoreLibs/timer"

import 'helper/Utils'

import 'ChessViewModel'

-- playdate.setMinimumGCTime(.0001)
-- playdate.setCollectsGarbage(false)
playdate.setMinimumGCTime(10)
-- playdate.setGCScaling(0.4, 0.7)
local gfx <const> = playdate.graphics
local chessViewModel = ChessViewModel()

function playdate.gameWillTerminate()
    chessViewModel:saveGame()
end

function playdate.deviceWillSleep()
    chessViewModel:saveGame()
end

function playdate.update()
    gfx.sprite.update()
    playdate.drawFPS(0,0)
    playdate.frameTimer.updateTimers()
    playdate.timer:updateTimers()
end

-- TODO
-- let user choose promotion piece
-- add menu option
--      - change color
-- play as black
-- Settings Screen
-- change difficulty
-- change color
-- history of previous games
-- show what the computer is thinking
-- scroll available moves w/ the crank
