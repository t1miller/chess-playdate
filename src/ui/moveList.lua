import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"


local gfx<const> = playdate.graphics
local WIDTH<const> = 147
local HEIGHT<const> = 80
local EMPTY_MOVE<const> = "   ..."
local font<const> = gfx.font.new("fonts/font-Bitmore-Medieval-Bold")
local moveListOffset = 0
local moveList = {
    {EMPTY_MOVE,EMPTY_MOVE},
    -- {"------------","------------"},
    -- {"------------","------------"},
    -- {"1.e2-e4","c3-c4"},
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

class('MoveList').extends()

function MoveList:init(x, y)
    MoveList.super.init(self)

    self.x = x
    self.y = y

    self.gridview = playdate.ui.gridview.new(65, 20)
	self.gridview.backgroundImage = gfx.nineSlice.new("images/gridBackground", 7, 7, 18, 18)
    self.gridview:setNumberOfRows(3)
    self.gridview:setNumberOfColumns(2)
    self.gridview:setSectionHeaderHeight(1)
    self.gridview:setCellPadding(2, 2, 2, 2)
    self.gridview:setContentInset(4, 4, 4, 4)
    self.gridview:setHorizontalDividerHeight(1)
    self.gridview.changeRowOnColumnWrap = true
    -- self.gridview:setSelectedRow(-1)

    -- sprite that holds image
	self.gridviewSprite = gfx.sprite.new()
	self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:setZIndex(32000)
	self.gridviewSprite:moveTo(x, y)
	self.gridviewSprite:add()


    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        gfx.pushContext()

            if row + moveListOffset > #moveList or row + moveListOffset < 1 then
                return
            end

            if selected then
                gfx.fillRoundRect(x, y, width, height, 4)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            else
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end

            local moveText = EMPTY_MOVE
            if column <= #moveList[row+moveListOffset] then
                moveText = moveList[row+moveListOffset][column]
            end

            print("row = "..row.." column = "..column)
            gfx.drawTextInRect(moveText, x+2, y+5, width, height, nil, "...", nil, nil)
        gfx.popContext()
    end


    self:draw()
end

function MoveList:draw()
    print("draw()")
	local listviewImage = gfx.image.new(WIDTH, HEIGHT)
	gfx.pushContext(listviewImage)
        gfx.setFont(font)
        self.gridview:drawInRect(0, 0, WIDTH, HEIGHT)
		self.gridviewSprite:setImage(listviewImage)
	gfx.popContext()
end

function MoveList:highlight(white)
    print("highlight()")
    if white then
        self.gridview:selectPreviousColumn(false)
    else
        self.gridview:selectNextColumn(false)
    end
    self:draw()
end

function MoveList:setMoveToActiveMove()
    print("setMoveToActiveMove()")
    moveListOffset = 0
    if moveList[1][1] == EMPTY_MOVE then
        self.gridview:setSelection(1,1,1)
    else
        self.gridview:setSelection(1,1,2)
    end
    self:draw()
end

function MoveList:clear()
    print("clear()")
    moveList = {
        {EMPTY_MOVE,EMPTY_MOVE}
    }
    moveListOffset = 0
    self:highlight(true)
end

function MoveList:updateMoveList(moves)
    print("updateMoveList()")
    moveList = moves
    self:draw()
end

function MoveList:shiftMoveList(amount)
    moveListOffset += amount
    self:draw()
end

function MoveList:removeLastTwoMoves()
    if #moveList < 1 then return end
    print("removeLastTwoMoves()")
    table.remove(moveList,1)
    if #moveList == 0 then
        -- reset movelist, reset move idx, redraw view
        self:clear()
        return
    end
    self:draw()
end

function MoveList:prevMove()
    print("preMove()")
    local _, row, col = self.gridview:getSelection()
    if moveListOffset + row >= #moveList and col == 1 then
        -- reached the end of the list, no prev moves
        return
    end

    if row == 3 and col == 1 then
        self:shiftMoveList(1)
        self.gridview:selectNextColumn(false)
    else
        if col == 2 then
            self.gridview:selectPreviousColumn(false)
        else
            self.gridview:selectNextRow(false)
            self.gridview:selectNextColumn(false)
        end
    end
    self:draw()
end

function MoveList:nextMove()
    print("nextMove()")
    local _, row, col = self.gridview:getSelection()

    if row == 1 and col == 2 then
        if moveListOffset + row <= 1 then
            return
        end
        print("shifting up")
        self:shiftMoveList(-1)
        self.gridview:selectPreviousColumn(false)
    else
        if col == 1 then
            self.gridview:selectNextColumn(false)
        else
            self.gridview:selectPreviousRow(false)
            self.gridview:selectPreviousColumn(false)
        end
    end
    self:draw()
end
