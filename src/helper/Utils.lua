import "CoreLibs/frameTimer"

local gfx <const> = playdate.graphics
local DEBUG <const> = true

function reverseTable(x)
    local rev = {}
    for i=#x, 1, -1 do
        rev[#rev+1] = x[i]
    end
    return rev
end

function splitString (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end

    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end

    return true
end

function printDebug(msg, debug)
    if debug then
        if type(msg) == "table" then
            printTable(msg)
        else
            print(msg)
        end
    end
end

local TOAST_FONT <const> = gfx.font.new("fonts/Roobert-10-Bold")

function showToast(text, duration)
    printDebug("Utils: showing toast message: "..text.." for "..duration.." frames", DEBUG)
    local width <const> = TOAST_FONT:getTextWidth(text)
    local height <const> = TOAST_FONT:getHeight()
    local PADDING <const> = 20
    local X <const> = 140
    local Y <const> = 100
    print(width)
    print(height)
    local t = playdate.frameTimer.new(duration)
    t.updateCallback = function()
        gfx.pushContext()
            gfx.setFont(TOAST_FONT)
            gfx.fillRoundRect(X-width/2-PADDING/2, Y-PADDING/2, width+PADDING, height+PADDING, 9)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawRoundRect(X-width/2-PADDING/2, Y-PADDING/2, width+PADDING, height+PADDING, 9)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawTextAligned(text, X, Y, kTextAlignment.center)
        gfx.popContext()
    end
end
