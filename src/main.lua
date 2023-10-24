import "CoreLibs/crank"
import "CoreLibs/timer"

import 'helper/Utils'

import 'ChessViewModel'

-- playdate.setMinimumGCTime(.0001)
-- playdate.setCollectsGarbage(false)
-- playdate.setGCScaling(0, 0.9)
playdate.setMinimumGCTime(4)
local gfx <const> = playdate.graphics
local chessViewModel = ChessViewModel()

function playdate.gameWillTerminate()
    print("main saving game")
    chessViewModel:saveGame()
    print("main saving done")
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
-- only update squares that changed in the grid view, not the whole gridview
-- add menu option
--      - change color
-- clear selected square on a new game
-- save progress when game ends
-- play as black
-- Settings Screen
-- change difficulty
-- change color
-- history of previous games
-- show what the computer is thinking
-- scroll available moves w/ the crank
