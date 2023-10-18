import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import 'helper/Utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = false
local WIDTH<const> = 147
local HEIGHT<const> = 73
local EMPTY_MOVE<const> = "   ..."
-- local MOVE_FONT<const> = gfx.font.new("fonts/font-Bitmore-Medieval-Bold")
local MOVE_FONT<const> = gfx.font.new("fonts/Roobert-10-Bold")
local MOVE_GRID_Z<const> = -150
local moveGridOffset = 0
local moveGrid = {
    {EMPTY_MOVE,EMPTY_MOVE},
    -- {"12.Ne2xe4#","12.Ne2xe4#"},
    -- {"2.e2-e4","c3-c4"},
    -- {"3.e2-e4","c3-c4"},
    -- {"4.e2-e4","c3-c4"},
    -- {"5.e2-e4","c3-c4"},
    -- {"6.e2-e4","c3-c4"},
    -- {"7.e2-e4","c3-c4"},
    -- {"8.e2-e4","c3-c4"},
    -- {"9.e2-e4","c3-c4"},
    -- {"10.e2-e4","c3-c4"},
    -- {"11.e2-e4","c3-c4"},
    -- {"12.e2-e4","c3-c4"},
    -- {"13.e2-e4","c3-c4"},
    -- {"14.e2-e4","c3-c4"},
    -- {"15.e2-e4","c3-c4"},
    -- {"16.e2-e4","c3-c4"},
}

class('MoveGrid').extends()

function MoveGrid:init(x, y)
    MoveGrid.super.init(self)

    self.x = x
    self.y = y

    self.highlightedMove = {}

    self.gridview = playdate.ui.gridview.new(65, 17)
	self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
    self.gridview:setNumberOfRows(3)
    self.gridview:setNumberOfColumns(2)
    self.gridview:setSectionHeaderHeight(1)
    self.gridview:setCellPadding(2, 2, 2, 2)
    self.gridview:setContentInset(4, 4, 4, 4)
    self.gridview:setHorizontalDividerHeight(1)
    self.gridview.changeRowOnColumnWrap = true

    -- sprite that holds image
	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:setZIndex(MOVE_GRID_Z)
	self.gridviewSprite:moveTo(x, y)
	self.gridviewSprite:add()

    local selfself = self
    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        gfx.pushContext()
            if row + moveGridOffset > #moveGrid or row + moveGridOffset < 1 then
                return
            end

            if selected then
                gfx.fillRoundRect(x, y, width, height, 4)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                selfself.highlightedMove = {row, column}
            else
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end

            local moveText = EMPTY_MOVE
            if column <= #moveGrid[row+moveGridOffset] then
                moveText = moveGrid[row+moveGridOffset][column]
            end

            gfx.drawTextInRect(moveText, x+2, y+1, width, height, nil, "...", nil, MOVE_FONT)
        gfx.popContext()
    end

    self:draw()
end

function MoveGrid:draw()
	local listviewImage = gfx.image.new(WIDTH, HEIGHT)
	gfx.pushContext(listviewImage)
        gfx.setFont(MOVE_FONT)
        self.gridview:drawInRect(0, 0, WIDTH, HEIGHT)
		self.gridviewSprite:setImage(listviewImage)
	gfx.popContext()
end

function MoveGrid:setMoveToActiveMove()
    printDebug("MoveGrid: setMoveToActiveMove()", DEBUG)
    if #moveGrid < 1 then
        return
    end

    moveGridOffset = 0
    if moveGrid[1][1] == EMPTY_MOVE then
        if self.highlightedMove[1] == 1 and self.highlightedMove[2] == 1 then
            return
        end
        self.gridview:setSelection(1,1,1)
    else
        if self.highlightedMove[1] == 1 and self.highlightedMove[2] == 2 then
            return
        end
        self.gridview:setSelection(1,1,2)
    end
    printDebug("MoveGrid: setMoveToActiveMove() drawing()", DEBUG)
    self:draw()
end

function MoveGrid:clear()
    printDebug("MoveGrid: clear()", DEBUG)
    moveGrid = {
        {EMPTY_MOVE,EMPTY_MOVE}
    }
    moveGridOffset = 0
    printDebug("MoveGrid: clear() drawing", DEBUG)
    self.gridview:setSelection(1,1,1)
    self:draw()
end

function MoveGrid:updateMoveGrid(moves, highlightLeft)
    printDebug("MoveGrid: updateMoveGrid()", DEBUG)
    moveGrid = moves
    if highlightLeft then
        self.gridview:setSelection(1,1,1)
    else
        self.gridview:setSelection(1,1,2)
    end
    printDebug("MoveGrid: updateMoveGrid() drawing", DEBUG)
    self:draw()
end

function MoveGrid:shiftMoveGrid(amount)
    printDebug("MoveGrid: shiftMoveGrid()", DEBUG)
    moveGridOffset += amount
end

function MoveGrid:removeLastTwoMoves()
    printDebug("MoveGrid: removeLastTwoMoves()", DEBUG)
    if #moveGrid < 1 then return end
    table.remove(moveGrid,1)
    if #moveGrid == 0 then
        -- reset movegrid, reset move idx, redraw view
        self:clear()
        return
    end
    printDebug("MoveGrid: removeLastTwoMoves() drawing", DEBUG)
    self:draw()
end

function MoveGrid:prevMove()
    printDebug("MoveGrid: prevMove()", DEBUG)
    local _, row, col = self.gridview:getSelection()
    if moveGridOffset + row >= #moveGrid and col == 1 then
        -- reached the end of the list, no prev moves
        return
    end

    if row == 3 and col == 1 then
        self:shiftMoveGrid(1)
        self.gridview:selectNextColumn(false)
    else
        if col == 2 then
            self.gridview:selectPreviousColumn(false)
        else
            self.gridview:selectNextRow(false)
            self.gridview:selectNextColumn(false)
        end
    end
    printDebug("MoveGrid: prevMove() drawing", DEBUG)
    self:draw()
end

function MoveGrid:nextMove()
    printDebug("MoveGrid: nextMove()", DEBUG)

    local _, row, col = self.gridview:getSelection()

    if row == 1 and col == 2 then
        if moveGridOffset + row <= 1 then
            return
        end
        self:shiftMoveGrid(-1)
        self.gridview:selectPreviousColumn(false)
    else
        if col == 1 then
            self.gridview:selectNextColumn(false)
        else
            self.gridview:selectPreviousRow(false)
            self.gridview:selectPreviousColumn(false)
        end
    end
    printDebug("MoveGrid: nextMove() drawing", DEBUG)
    self:draw()
end
