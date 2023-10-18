import "CoreLibs/crank"
import "CoreLibs/timer"

import 'ChessViewModel'

-- playdate.setMinimumGCTime(.0001)
-- playdate.setCollectsGarbage(false)
local gfx <const> = playdate.graphics
local DEBUG <const> = false
local chessViewModel = ChessViewModel()

function playdate.AButtonDown()
    chessViewModel:APressed()
end

function playdate.BButtonDown()
    chessViewModel:BPressed()
end

function playdate.cranked(change, acceleratedChange)
    chessViewModel:crankMoved()
end

function playdate.upButtonDown()
    chessViewModel:UpPressed()
end

function playdate.downButtonDown()
    chessViewModel:DownPressed()
end

function playdate.rightButtonDown()
    chessViewModel:RightPressed()
end

function playdate.leftButtonDown()
    chessViewModel:LeftPressed()
end

function playdate.update()
    gfx.sprite.update()
    playdate.frameTimer.updateTimers()
    playdate.timer:updateTimers()
end

-- TODO
-- let user choose promotion piece
-- only update squares that changed in the grid view, not the whole gridview
-- add menu option
--      - change color
-- clear selected square on a new game
