import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import 'helper/Utils'

local gfx<const> = playdate.graphics
local DEBUG <const> = true
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
    self.moveList = {
        {self.emptyMove,self.emptyMove},
    }
    self.moveListOffset = 0

    self:loadGridView()

    local selfself = self
    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)

        if column == 1 then
            selfself:drawVerticalDivider(x, y, width, height, row)
        end

        if row + selfself.moveListOffset > #selfself.moveList or row + selfself.moveListOffset < 1 then
            return
        end

        selfself:drawMoveAndHighlight(selected, row, column, x, y, width, height)
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

function MoveGrid:drawMoveAndHighlight(selected, row, column, x, y, width, height)
    gfx.pushContext()
        -- draw highlighted rectangle
        if selected then
            gfx.fillRoundRect(x, y+2, width, height+1, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end

        -- draw move text
        local moveText = iif(
            column <= #self.moveList[row+self.moveListOffset],
            self.moveList[row+self.moveListOffset][column],
            self.emptyMove
        )
        gfx.drawTextInRect(moveText, x+2, y+5, width, height, nil, "...", nil, self.moveFont)
    gfx.popContext()
end

function MoveGrid:drawVerticalDivider(x, y, width, height, row)
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

function MoveGrid:setMoveToActiveMove()
    if #self.moveList < 1 then
        return
    end

    self.moveListOffset = 0
    if self.moveList[1][1] == self.emptyMove then
        self.gridview:setSelection(1,1,1)
    else
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

function MoveGrid:updateMoveGrid(moves, whiteMoved)
    self.moveList = moves
    if whiteMoved then
        self.gridview:setSelection(1,1,1)
    else
        self.gridview:setSelection(1,1,2)
    end
    printDebug("MoveGrid: updateMoveGrid() drawing", DEBUG)
    self:draw()
end

function MoveGrid:removeLastTwoMoves()
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
    local _, row, col = self.gridview:getSelection()
    if self.moveListOffset + row >= #self.moveList and col == 1 then
        -- reached the end of the list, no prev moves
        return
    end

    local newRow = iif(col == 1, row + 1, row)
    local newCol = iif(col == 1, 2, 1)
    if newRow == 5 then
        newRow = 4
        self.moveListOffset += 1
    end

    printDebug("MoveGrid: prevMove() drawing", DEBUG)

    self.gridview:setSelection(1, newRow, newCol)
    self:draw()
end

function MoveGrid:nextMove()

    local _, row, col = self.gridview:getSelection()
    if self.moveListOffset == 0 and row == 1 and col == 2 then
        -- reached front of list, no next moves
        return
    end

    local newRow = iif(col == 2, row - 1, row)
    local newCol = iif(col == 1, 2, 1)
    if newRow == 0 then
        newRow = 1
        self.moveListOffset -= 1
    end

    printDebug("MoveGrid: nextMove() drawing", DEBUG)

    self.gridview:setSelection(1, newRow, newCol)
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
