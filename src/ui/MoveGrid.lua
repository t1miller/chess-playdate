import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import 'helper/Utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = false
local MOVE_GRID_Z<const> = -150

class('MoveGrid').extends()

function MoveGrid:init(x, y)
    MoveGrid.super.init(self)

    self.x = x
    self.y = y
    self.height = 100
    self.width = 145
    self.emptyMove = "   ..."
    self.moveFont = gfx.font.new("fonts/Roobert-10-Bold")
    self.highlightedMove = {}
    self.moveList = {
        {self.emptyMove,self.emptyMove},
    }
    self.moveListOffset = 0

    self:loadGridView()

    local selfself = self
    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)

        -- draw vertical dividers
        if column == 1 then
            gfx.pushContext()
                gfx.setLineWidth(2)
                if row == 1 then
                    gfx.drawLine(x+width+2, y+3, x+width+2, y+height+4)
                elseif row == 2 or row == 3 then
                    gfx.drawLine(x+width+2, y, x+width+2, y+height+7)
                else
                    gfx.drawLine(x+width+2, y, x+width+2, y+height+2)
                end
            gfx.popContext()
        end

        if row + selfself.moveListOffset > #selfself.moveList or row + selfself.moveListOffset < 1 then
            return
        end
        
        gfx.pushContext()
            if selected then
                gfx.fillRoundRect(x, y+2, width, height+1, 4)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                selfself.highlightedMove = {row, column}
            else
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end

            local moveText = iif(
                column <= #selfself.moveList[row+selfself.moveListOffset],
                selfself.moveList[row+selfself.moveListOffset][column],
                selfself.emptyMove
            )
            gfx.drawTextInRect(moveText, x+2, y+5, width, height, nil, "...", nil, selfself.moveFont)
        gfx.popContext()
    end

    self:draw()
end

function MoveGrid:loadGridView()
    self.gridview = playdate.ui.gridview.new(64, 18)
	self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
    self.gridview:setNumberOfRows(4)
    self.gridview:setNumberOfColumns(2)
    self.gridview:setCellPadding(2, 2, 2, 2)
    -- self.gridview:setContentInset(4, 4, 4, 0)
    self.gridview:setContentInset(4, 2, 2, 2)
    self.gridview:setHorizontalDividerHeight(1)
    self.gridview:addHorizontalDividerAbove(1,2)
    self.gridview:addHorizontalDividerAbove(1,3)
    self.gridview:addHorizontalDividerAbove(1,4)
    self.gridview.changeRowOnColumnWrap = true

    -- sprite that holds image
	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:setZIndex(MOVE_GRID_Z)
	self.gridviewSprite:moveTo(self.x,self.y)
	self.gridviewSprite:add()
end

function MoveGrid:draw()
	local listviewImage = gfx.image.new(self.width, self.height)
	gfx.pushContext(listviewImage)
        self.gridview:drawInRect(0, 0, self.width, self.height)
		self.gridviewSprite:setImage(listviewImage)
	gfx.popContext()
end

function MoveGrid:setMoveToActiveMove()
    -- todo this can probably be simplified
    printDebug("MoveGrid: setMoveToActiveMove()", DEBUG)
    if #self.moveList < 1 then
        return
    end

    self.moveListOffset = 0
    if self.moveList[1][1] == self.emptyMove then
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
    self.moveList = {
        {self.emptyMove,self.emptyMove}
    }
    self.moveListOffset = 0
    self.gridview:setSelection(1,1,1)
    self:draw()
end

function MoveGrid:updateMoveGrid(moves, highlightLeft)
    printDebug("MoveGrid: updateMoveGrid()", DEBUG)
    self.moveList = moves
    if highlightLeft then
        self.gridview:setSelection(1,1,1)
    else
        self.gridview:setSelection(1,1,2)
    end
    printDebug("MoveGrid: updateMoveGrid() drawing", DEBUG)
    self:draw()
end

function MoveGrid:shiftMoveGrid(amount)
    self.moveListOffset += amount
end

function MoveGrid:removeLastTwoMoves()
    printDebug("MoveGrid: removeLastTwoMoves()", DEBUG)
    if #self.moveList < 1 then return end
    table.remove(self.moveList,1)
    if #self.moveList == 0 then
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
    if self.moveListOffset + row >= #self.moveList and col == 1 then
        -- reached the end of the list, no prev moves
        return
    end

    if row == 4 and col == 1 then
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
        if self.moveListOffset + row <= 1 then
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

-- todo might need to add higlighted move
function MoveGrid:toSavedTable()
    return {
        moveList = self.moveList,
    }
end

function MoveGrid:initFromSavedTable(data)
    self.moveListOffset = 0
    self:updateMoveGrid(data["moveList"], false)
end
