
import 'Utils'

local sampler <const> = playdate.sound.sampleplayer

local DEBUG <const> = false
local SOUND_NAMES = {
    GAME_START = "GAME_START",
    GAME_END = "GAME_END",
    MOVE_USER = "MOVE_USER",
    MOVE_OPPONENT = "MOVE_OPPONENT",
    CAPTURE = "CAPTURE",
    CASTLE = "CASTLE",
    CHECK = "CHECK",
    PROMOTE = "PROMOTE",
    USER_IN_CHECK = "USER_IN_CHECK"
}
local SOUND_FILE_PATHS <const>  = {
    ["sounds/capture"] = SOUND_NAMES.CAPTURE,
    ["sounds/castle"] = SOUND_NAMES.CASTLE,
    ["sounds/check"] = SOUND_NAMES.CHECK,
    ["sounds/move"] = SOUND_NAMES.MOVE_USER,
    ["sounds/promote"] = SOUND_NAMES.PROMOTE,
    ["sounds/game-end"] = SOUND_NAMES.GAME_END,
    ["sounds/game-start"] = SOUND_NAMES.GAME_START,
    ["sounds/illegal"] = SOUND_NAMES.USER_IN_CHECK,
    ["sounds/move-opponent"] = SOUND_NAMES.MOVE_OPPONENT,
}

local samplePlayers = {}

local function loadSounds()
    for path, name in pairs(SOUND_FILE_PATHS) do
        local player = sampler.new(path)
        assert(player)
        samplePlayers[name] = player
        -- samplePlayers[name]:setVolume(1.0)
    end
    printDebug(samplePlayers, DEBUG)
end

local function playSound(name)
    if samplePlayers[name] then
        printDebug("SoundHelper: playing sound "..name, DEBUG)
        samplePlayers[name]:play()
    else
        printDebug("SoundHelper: sound w/ name: "..name.." doesnt exist",DEBUG)
    end
end

function playSoundGameState(state)
    if state == GAME_STATE.CHECK then
        playSound(SOUND_NAMES.CHECK)
    elseif state == GAME_STATE.NEW_GAME then
        playSound(SOUND_NAMES.GAME_START)
    elseif state == GAME_STATE.USER_MOVED then
        playSound(SOUND_NAMES.MOVE_USER)
    elseif state == GAME_STATE.COMPUTER_MOVED then
        playSound(SOUND_NAMES.MOVE_OPPONENT)
    elseif state == GAME_STATE.CASTLED then
        playSound(SOUND_NAMES.CASTLE)
    elseif state == GAME_STATE.CAPTURED then
        playSound(SOUND_NAMES.CAPTURE)
    elseif state == GAME_STATE.PROMOTED then
        playSound(SOUND_NAMES.PROMOTE)
    elseif state == GAME_STATE.USER_IN_CHECK then
        playSound(SOUND_NAMES.USER_IN_CHECK)
    elseif state == GAME_STATE.COMPUTER_WON or 
           state == GAME_STATE.USER_WON or 
           state == GAME_STATE.DRAW or
           state == GAME_STATE.DRAW_BY_REPITITION or 
           state == GAME_STATE.INSUFFICIENT_MATERIAL or 
           state == GAME_STATE.STALEMATE or 
           state == GAME_STATE.RESIGN then
        playSound(SOUND_NAMES.GAME_END)
    end
    
end

loadSounds()