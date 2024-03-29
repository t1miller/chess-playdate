import "CoreLibs/frameTimer"

local DEBUG <const> = false

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

function iif(statement, arg1, arg2)
    if statement then
        return arg1
    else
        return arg2
    end
end

function sleep(delayMs)
    playdate.resetElapsedTime()
    while playdate.getElapsedTime()*100 < delayMs do end
end

local resetElapsedTime<const> = playdate.resetElapsedTime
local getElapsedTime<const> = playdate.getElapsedTime
local coroutineStatus<const> = coroutine.status
local coroutineResume<const> = coroutine.resume
function longRunningTask(co, estimatedTotalTime, interval, onProgressCallback, onDoneCallback)

    resetElapsedTime()
    local timer = nil
    timer = playdate.timer.keyRepeatTimerWithDelay(0, interval, function()
        if onProgressCallback then
            onProgressCallback((getElapsedTime() / estimatedTotalTime) * 100)
        end

        if coroutineStatus(co) == "suspended" then
            coroutineResume(co)
        elseif coroutineStatus(co) == "dead" then
            -- user might click new game while computer is thinking
            if timer then
                printDebug("Utils: longRunningTask() timer removed", DEBUG)
                timer:remove()
            end

            if onDoneCallback then
                printDebug("Utils: longRunningTask() onDoneCallback called", DEBUG)
                onDoneCallback()
            end
        end
    end)
    return timer
end

function reverseItemsInRows(board)
    for r = 1, #board do
        board[r] = string.reverse(board[r])
    end
end

function reverseRows(board)
    local left = 1
    local right = #board
    while left < right do
        local tmp = board[left]
        board[left] = board[right]
        board[right] = tmp
        left += 1
        right -= 1
    end
end