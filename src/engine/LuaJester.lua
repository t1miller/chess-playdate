-- This is a Lua version of
-- Jester (http://www.ludochess.com/) - a strong java chess engine
-- A real treasure for the Chess society!
-- The author is Stephane N.B. Nguyen.
--
-- This chess engine is a state-machine.
-- Look auto-samples at the end to see it working.
-- Use chess logic before calling requests.
--
-- Lua (via javascript) work by http://chessforeva.blogspot.com
-- sorry for hack, just very good source for lua
import 'helper/Utils'

local DEBUG <const> = true
local abs <const> = math.abs
local floor <const> = math.floor

local iif<const> = iif
local getTime = playdate.getElapsedTime
local yield = coroutine.yield

local BoardCpy, WatchPosit, CalcKBNK, ChangeForce, Undo, ISqAgrs, Iwxy, XRayBR, ComputerMvt, InitMoves,
CheckMov, UnValidateMov, FJunk, ShowThink, ResetData, InChecking, ShowScore, MixBoard, InitGame, IColmn, IRaw, 
ShowStat, CalcKPK, CalcKg, IArrow, MoveTree, PrisePassant, copyValueOf, Agression, InitArrow, IfCheck, 
Anyagress, KnightPts, QueenPts, PositPts, PlayMov, IRepeat, ChoiceMov, MultiMov, XRayKg, DoCastle, DoCalc, Lalgb, 
UpdatePiecMap, getBoard, UpdateDisplay, AvailCaptur, InitStatus, MessageOut, Pagress, CheckMatrl, AttachMov, PawnPts, 
RookPts, KingPts, AvailMov, BishopPts, ValidateMov, Peek, Seek, SwitchSides, EnterMove, SetFen, ResetFlags, 
Jst_Play, UndoMov, ShowMov
-- GetAlgMvt

-- function _BTREE()
--     local b = {}
--     b.replay = 0
--     b.f = 0
--     b.t = 0
--     b.flags = 0
--     b.score = 0
--     return b
-- end
-- {replay = 0, f = 0, t = 0, flags = 0, score = 0}

-- function _GAMESTATS()
--     local g = {}
--     g.mate = false
--     g.timeout = false
--     g.recapture = false
--     return g
-- end
-- {mate =  false, timeout = false, recapture = false}

-- function _INT()
--     local x = {}
--     x.i = 0
--     return x
-- end
-- {i = 0}

-- function _MOVES()
--     local m = {}
--     m.gamMv = 0
--     m.score = 0
--     m.piece = 0
--     m.color = 0
--     return m
-- end
-- {gamMv = 0, score = 0, piece = 0, color = 0}

Js_maxDepth = 6         -- Search Depth setting for lua (no timeout option)

Js_searchTimeout = 12   -- 9 seconds for search allowed

Js_prevYieldTime = 0
-- Js_startTime = 0
-- used for ChessGame GAME_STATE
Js_castled = false
Js_captured = false
Js_userInCheck = false
Js_userMoved = false
Js_computerMoved = false
Js_userInvalidMove = false


Js_nMovesMade = 0
Js_computer = 0
Js_player = 0
Js_enemy = 0

Js_fUserWin_kc = false
Js_fInGame = false


Js_fGameOver = false

Js_fCheck_kc = false
Js_fMate_kc = false
Js_bDraw = 0
Js_fStalemate = false
Js_fSoonMate_kc = false   -- Algo detects soon checkmate
Js_fAbandon = false       -- Algo resigns, if game lost

Js_working = 0
Js_working2 = 0
Js_advX_pawn = 10
Js_isoX_pawn = 7
Js_pawnPlus = 0
Js_castle_pawn = 0
Js_bishopPlus = 0
Js_adv_knight = 0
Js_far_knight = 0
Js_far_bishop = 0
Js_king_agress = 0

Js_junk_pawn = -15
Js_stopped_pawn = -4
Js_doubled_pawn = -14
Js_bad_pawn = -4
Js_semiOpen_rook = 10
Js_semiOpen_rookOther = 4
Js_rookPlus = 0
Js_crossArrow = 8
Js_pinnedVal = 10
Js_semiOpen_king = 0
Js_semiOpen_kingOther = 0
Js_castle_K = 0
Js_moveAcross_K = 0
Js_safe_King = 0

Js_agress_across = -6
Js_pinned_p = -8
Js_pinned_other = -12

Js_nGameMoves = {}   --int[]
Js_depth_Seek = 0
Js_c1 = 0
Js_c2 = 0
Js_agress2 = {}   --int[]
Js_agress1 = {}   --int[]
Js_ptValue = 0
Js_flip = false
Js_fEat = false
Js_myPiece = ""
Js_Message = ""

Js_fiftyMoves = 0
Js_indenSqr = 0
Js_realBestDepth = 0
Js_realBestScore = 0
Js_realBestMove = 0
Js_lastDepth = 0
Js_lastScore = 0
Js_fKO = false


Js_fromMySquare = 0
Js_toMySquare = 0
Js_cNodes = 0
Js_scoreDither = 0
Js__alpha = 0
Js__beta = 0
Js_dxAlphaBeta = 0
Js_maxDepthSeek = 0
Js_specialScore = 0
Js_hint = 0

Js_currentScore = 0

Js_proPiece = 0
Js_pawc1 = {}
Js_pawc2 = {}
Js_origSquare = 0
Js_destSquare = 0

Js_cCompNodes = 0
Js_dxDither = 0
Js_scoreWin0 = 0
Js_scoreWin1 = 0
Js_scoreWin2 = 0
Js_scoreWin3 = 0
Js_scoreWin4 = 0

Js_USER_TOPLAY = 0
Js_JESTER_TOPLAY = 1

Js_hollow = 2
Js_empty = 0
Js_pawn = 1
Js_knight = 2
Js_bishop = 3
Js_rook = 4
Js_queen = 5
Js_king = 6

-- black == 1
-- white == 0
Js_white = 0
Js_black = 1

Js_N9 = 90

-- Js_szIdMvt = "ABCDEFGH" .. "IJKLMNOP" .. "QRSTUVWX" .. "abcdefgh" .. "ijklmnop" .. "qrstuvwx" .. "01234567" .. "89YZyz*+"
Js_szAlgMvt = { "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1", "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2", "a3",
    "b3", "c3", "d3", "e3", "f3", "g3", "h3", "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4", "a5", "b5", "c5", "d5",
    "e5", "f5", "g5", "h5", "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6", "a7", "b7", "c7", "d7", "e7", "f7", "g7",
    "h7", "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8" }

-- Js_color_sq = { 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0,
--     1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0 }

Js_bkPawn = 7
Js_pawn_msk = 7
Js_promote = 8
Js_castle_msk = 16
Js_enpassant_msk = 32
Js__idem = 64
Js_menace_pawn = 128
Js_check = 256
Js_capture = 512
Js_draw = 1024
Js_pawnVal = 100
Js_knightVal = 350
Js_bishopVal = 355
Js_rookVal = 550
Js_queenVal = 1050
Js_kingVal = 1200
Js_xltP = 16384
Js_xltN = 10240
Js_xltB = 6144
Js_xltR = 1024
Js_xltQ = 512
Js_xltK = 256
Js_xltBQ = 4608
Js_xltBN = 2048
Js_xltRQ = 1536
Js_xltNN = 8192

Js_movesList = {}        --new _MOVES[512]
Js_flag = {mate =  false, timeout = false, recapture = false}   --new _GAMESTATS()
Js_Tree = {}             --new _BTREE[2000]
Js_root = {replay = 0, f = 0, t = 0, flags = 0, score = 0}
Js_tmpTree = {replay = 0, f = 0, t = 0, flags = 0, score = 0}    --new _BTREE()
Js_treePoint = {}        --new int[Js_maxDepth]
Js_board = {}            --new int[64]
Js_color = {}            --new int[64]
Js_pieceMap = {}         --new int[2][16]
Js_pawnMap = {}          --new int[2][8]
Js_roquer = { 0, 0 }
Js_nMvtOnBoard = {}      --new int[64]
Js_scoreOnBoard = {}     --new int[64]
Js_gainScore = {i = 0}

Js_otherTroop = { 1, 0, 2 }
Js_variants = {}     --new int[Js_maxDepth]
Js_pieceIndex = {}   --new int[64]
Js_piecesCount = { 0, 0 }
Js_arrowData = {}    --new int[4200]
Js_crossData = {}    --new int[4200]
Js_agress = {}       --new int[2][64]
Js_matrl = { 0, 0 }
Js_pmatrl = { 0, 0 }
Js_ematrl = { 0, 0 }
Js_pinned = { 0, 0 }
Js_withPawn = { 0, 0 }
Js_withKnight = { 0, 0 }
Js_withBishop = { 0, 0 }
Js_withRook = { 0, 0 }
Js_withQueen = { 0, 0 }
Js_flagCheck = {}    --new int[Js_maxDepth]
Js_flagEat = {}      --new int[Js_maxDepth]
Js_menacePawn = {}   --new int[Js_maxDepth]
Js_scorePP = {}      --new int[Js_maxDepth]
Js_scoreTP = {}      --new int[Js_maxDepth]
Js_eliminate0 = {}   --new int[Js_maxDepth]
Js_eliminate1 = {}   --new int[Js_maxDepth]
Js_eliminate2 = {}   --new int[Js_maxDepth]
Js_eliminate3 = {}   --new int[Js_maxDepth]
Js_storage = {}      --new short[10000]
Js_wPawnMvt = {}     --new int[64]
Js_bPawnMvt = {}     --new int[64]
Js_knightMvt = {}    --new int[2][64]
Js_bishopMvt = {}    --new int[2][64]
Js_kingMvt = {}      --new int[2][64]
Js_killArea = {}     --new int[2][64]
Js_fDevl = { 0, 0 }
Js_nextCross = {}    --new char[40000]
Js_nextArrow = {}    --new char[40000]
Js_tmpCh = {}        --new char[20]
Js_movCh = {}        --new char[8]
Js_b_r = {}          --new int[64]

Js_upperNot = { " ", "P", "N", "B", "R", "Q", "K" }
Js_lowerNot = { " ", "p", "n", "b", "r", "q", "k" }
Js_rgszPiece = { "", "", "N", "B", "R", "Q", "K" }
Js_asciiMove = { { " ", " ", " ", " ", " ", " " }, { " ", " ", " ", " ", " ", " " }, { " ", " ", " ", " ", " ", " " },
    { " ", " ", " ", " ", " ", " " } }
Js_reguBoard = { Js_rook, Js_knight, Js_bishop, Js_queen, Js_king, Js_bishop, Js_knight, Js_rook, Js_pawn, Js_pawn,
    Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_rook,
    Js_knight, Js_bishop, Js_queen, Js_king, Js_bishop, Js_knight, Js_rook }
Js_reguColor = { Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white,
    Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black,
    Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black }
Js_pieceTyp = { { Js_empty, Js_pawn, Js_knight, Js_bishop, Js_rook, Js_queen, Js_king, Js_empty },
    { Js_empty, Js_bkPawn, Js_knight, Js_bishop, Js_rook, Js_queen, Js_king, Js_empty } }
Js_direction = { { 0, 0, 0, 0, 0, 0, 0, 0 }, { 10, 9, 11, 0, 0, 0, 0, 0 }, { 8, -8, 12, -12, 19, -19, 21, -21 },
    { 9, 11, -9, -11, 0, 0, 0, 0 }, { 1, 10, -1, -10, 0, 0, 0, 0 }, { 1, 10, -1, -10, 9, 11, -9, -11 },
    { 1, 10, -1, -10, 9, 11, -9, -11 }, { -10, -9, -11, 0, 0, 0, 0, 0 } }
Js_maxJobs = { 0, 2, 1, 7, 7, 7, 1, 2 }
Js_virtualBoard = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5,
    6, 7, -1, -1, 8, 9, 10, 11, 12, 13, 14, 15, -1, -1, 16, 17, 18, 19, 20, 21, 22, 23, -1, -1, 24, 25, 26, 27, 28, 29,
    30, 31, -1, -1, 32, 33, 34, 35, 36, 37, 38, 39, -1, -1, 40, 41, 42, 43, 44, 45, 46, 47, -1, -1, 48, 49, 50, 51, 52,
    53, 54, 55, -1, -1, 56, 57, 58, 59, 60, 61, 62, 63, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1 }
Js_start_K = { 0, 0, -4, -10, -10, -4, 0, 0, -4, -4, -8, -12, -12, -8, -4, -4, -12, -16, -20, -20, -20, -20, -16, -12,
    -16, -20, -24, -24, -24, -24, -20, -16, -16, -20, -24, -24, -24, -24, -20, -16, -12, -16, -20, -20, -20, -20, -16,
    -12, -4, -4, -8, -12, -12, -8, -4, -4, 0, 0, -4, -10, -10, -4, 0, 0 }
Js_end_K = { 0, 6, 12, 18, 18, 12, 6, 0, 6, 12, 18, 24, 24, 18, 12, 6, 12, 18, 24, 30, 30, 24, 18, 12, 18, 24, 30, 36,
    36, 30, 24, 18, 18, 24, 30, 36, 36, 30, 24, 18, 12, 18, 24, 30, 30, 24, 18, 12, 6, 12, 18, 24, 24, 18, 12, 6, 0, 6,
    12, 18, 18, 12, 6, 0 }
Js_vanish_K = { 0, 8, 16, 24, 24, 16, 8, 0, 8, 32, 40, 48, 48, 40, 32, 8, 16, 40, 56, 64, 64, 56, 40, 16, 24, 48, 64, 72,
    72, 64, 48, 24, 24, 48, 64, 72, 72, 64, 48, 24, 16, 40, 56, 64, 64, 56, 40, 16, 8, 32, 40, 48, 48, 40, 32, 8, 0, 8,
    16, 24, 24, 16, 8, 0 }
Js_end_KBNK = { 99, 90, 80, 70, 60, 50, 40, 40, 90, 80, 60, 50, 40, 30, 20, 40, 80, 60, 40, 30, 20, 10, 30, 50, 70, 50,
    30, 10, 0, 20, 40, 60, 60, 40, 20, 0, 10, 30, 50, 70, 50, 30, 10, 20, 30, 40, 60, 80, 40, 20, 30, 40, 50, 60, 80, 90,
    40, 40, 50, 60, 70, 80, 90, 99 }
Js_knight_pos = { 0, 4, 8, 10, 10, 8, 4, 0, 4, 8, 16, 20, 20, 16, 8, 4, 8, 16, 24, 28, 28, 24, 16, 8, 10, 20, 28, 32, 32,
    28, 20, 10, 10, 20, 28, 32, 32, 28, 20, 10, 8, 16, 24, 28, 28, 24, 16, 8, 4, 8, 16, 20, 20, 16, 8, 4, 0, 4, 8, 10,
    10, 8, 4, 0 }
Js_bishop_pos = { 14, 14, 14, 14, 14, 14, 14, 14, 14, 22, 18, 18, 18, 18, 22, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 18,
    22, 22, 22, 22, 18, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 22, 18, 18, 18, 18, 22,
    14, 14, 14, 14, 14, 14, 14, 14, 14 }
Js_pawn_pos = { 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 0, 0, 4, 4, 4, 6, 8, 2, 10, 10, 2, 8, 6, 6, 8, 12, 16, 16, 12, 8, 6, 8,
    12, 16, 24, 24, 16, 12, 8, 12, 16, 24, 32, 32, 24, 16, 12, 12, 16, 24, 32, 32, 24, 16, 12, 0, 0, 0, 0, 0, 0, 0, 0 }
Js_valueMap = { 0, Js_pawnVal, Js_knightVal, Js_bishopVal, Js_rookVal, Js_queenVal, Js_kingVal }
Js_xlat = { 0, Js_xltP, Js_xltN, Js_xltB, Js_xltR, Js_xltQ, Js_xltK }
Js_pss_pawn0 = { 0, 60, 80, 120, 200, 360, 600, 800 }
Js_pss_pawn1 = { 0, 30, 40, 60, 100, 180, 300, 800 }
Js_pss_pawn2 = { 0, 15, 25, 35, 50, 90, 140, 800 }
Js_pss_pawn3 = { 0, 5, 10, 15, 20, 30, 140, 800 }
Js_isol_pawn = { -12, -16, -20, -24, -24, -20, -16, -12 }
Js_takeBack = { -6, -10, -15, -21, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28 }
Js_mobBishop = { -2, 0, 2, 4, 6, 8, 10, 12, 13, 14, 15, 16, 16, 16 }
Js_mobRook = { 0, 2, 4, 6, 8, 10, 11, 12, 13, 14, 14, 14, 14, 14, 14 }
Js_menaceKing = { 0, -8, -20, -36, -52, -68, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80,
    -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80 }
Js_queenRook = { 0, 56, 0 }
Js_kingRook = { 7, 63, 0 }
Js_kingPawn = { 4, 60, 0 }
Js_raw7 = { 6, 1, 0 }
Js_heavy = { false, false, false, true, true, true, false, false }

Js_pgn = ""   -- save too

Js_AUTHOR = "Copyright � 1998-2002 - Stephane N.B. Nguyen - Vaureal, FRANCE"
Js_WEBSITE = "http://www.ludochess.com/"
Js_STR_COPY = "JESTER 1.10e by " .. Js_AUTHOR .. Js_WEBSITE

-- Some helping functions for Lua scripting

-- (if ? then : else) substitute
-- other syntax for binary operators a,b:  cond and a or b

-- function iif(ask, ontrue, onfalse)
--     if (ask) then
--         return ontrue
--     end
--     return onfalse
-- end

function BoardCpy(a, b)
    -- local sq = 0
    for sq = 0, 63, 1 do
        b[1 + sq] = a[1 + sq]
    end
end

function WatchPosit()
    local PawnStorm = false
    local i = 0
    -- local side = 0
    local b = 0
    -- local sq = 0

    local fyle = 0
    local rank = 0
    local bstrong = 0
    local wstrong = 0
    local bpadv = 0
    local wpadv = 0

    local nwm = 0
    local nbm = 0
    local bwm = 0
    local bbm = 0

    local pMap2 = nil
    local Pd = 0
    local pp = 0
    local z = 0
    -- local j = 0
    -- local k = 0
    local val = 0

    Agression(Js_white, Js_agress[1 + Js_white])
    Agression(Js_black, Js_agress[1 + Js_black])

    ChangeForce()
    Js_withKnight[1 + Js_white] = 0
    Js_withKnight[1 + Js_black] = 0
    Js_withBishop[1 + Js_white] = 0
    Js_withBishop[1 + Js_black] = 0
    Js_withRook[1 + Js_white] = 0
    Js_withRook[1 + Js_black] = 0
    Js_withQueen[1 + Js_white] = 0
    Js_withQueen[1 + Js_black] = 0
    Js_withPawn[1 + Js_white] = 0
    Js_withPawn[1 + Js_black] = 0
    for side = Js_white, Js_black, 1 do
        for i = Js_piecesCount[1 + side], 0, -1 do
            b = Js_board[1 + Js_pieceMap[1 + side][1 + i]]
            if (b == Js_knight) then
                Js_withKnight[1 + side] = Js_withKnight[1 + side] + 1
            else
                if (b == Js_bishop) then
                    Js_withBishop[1 + side] = Js_withBishop[1 + side] + 1
                else
                    if (b == Js_rook) then
                        Js_withRook[1 + side] = Js_withRook[1 + side] + 1
                    else
                        if (b == Js_queen) then
                            Js_withQueen[1 + side] = Js_withQueen[1 + side] + 1
                        else
                            if (b == Js_pawn) then
                                Js_withPawn[1 + side] = Js_withPawn[1 + side] + 1
                            end
                        end
                    end
                end
            end
        end
    end

    if (Js_fDevl[1 + Js_white] == 0) then
        Js_fDevl[1 + Js_white] = iif(
        ((Js_board[2] == Js_knight) or (Js_board[3] == Js_bishop) or (Js_board[6] == Js_bishop) or (Js_board[7] == Js_knight)),
            0, 1)
    end

    if (Js_fDevl[1 + Js_black] == 0) then
        Js_fDevl[1 + Js_black] = iif(
        ((Js_board[58] == Js_knight) or (Js_board[59] == Js_bishop) or (Js_board[62] == Js_bishop) or (Js_board[63] == Js_knight)),
            0, 1)
    end

    if ((not (PawnStorm)) and (Js_working < 5)) then
        PawnStorm = ((IColmn(Js_pieceMap[1 + Js_white][1]) < 3) and (IColmn(Js_pieceMap[1 + Js_black][1]) > 4)) or
            ((IColmn(Js_pieceMap[1 + Js_white][1]) > 4) and (IColmn(Js_pieceMap[1 + Js_black][1]) < 3))
    end

    -- deep copy
    BoardCpy(Js_knight_pos, Js_knightMvt[1 + Js_white])
    BoardCpy(Js_knight_pos, Js_knightMvt[1 + Js_black])
    BoardCpy(Js_bishop_pos, Js_bishopMvt[1 + Js_white])
    BoardCpy(Js_bishop_pos, Js_bishopMvt[1 + Js_black])

    --slice is much faster, but copies references only
    --Js_knightMvt[1+Js_white] = Js_knight_pos.slice()
    --Js_knightMvt[1+Js_black] = Js_knight_pos.slice()
    --Js_bishopMvt[1+Js_white] = Js_bishop_pos.slice()
    --Js_bishopMvt[1+Js_black] = Js_bishop_pos.slice()

    MixBoard(Js_start_K, Js_end_K, Js_kingMvt[1 + Js_white])
    MixBoard(Js_start_K, Js_end_K, Js_kingMvt[1 + Js_black])

    for sq = 0, 63, 1 do
        fyle = IColmn(sq)
        rank = IRaw(sq)
        bstrong = 1
        wstrong = 1
        for i = sq, 63, 8 do
            if (Pagress(Js_black, i)) then
                wstrong = 0
                break
            end
        end
        for i = sq, 0, -8 do
            if (Pagress(Js_white, i)) then
                bstrong = 0
                break
            end
        end
        bpadv = Js_advX_pawn
        wpadv = Js_advX_pawn
        if ((((fyle == 0) or (Js_pawnMap[1 + Js_white][1 + (fyle - 1)] == 0))) and ((
                (fyle == 7) or (Js_pawnMap[1 + Js_white][1 + (fyle + 1)] == 0)))) then
            wpadv = Js_isoX_pawn
        end
        if ((((fyle == 0) or (Js_pawnMap[1 + Js_black][1 + (fyle - 1)] == 0))) and ((
                (fyle == 7) or (Js_pawnMap[1 + Js_black][1 + (fyle + 1)] == 0)))) then
            bpadv = Js_isoX_pawn
        end
        Js_wPawnMvt[1 + sq] = (wpadv * Js_pawn_pos[1 + sq] / 10)
        Js_bPawnMvt[1 + sq] = (bpadv * Js_pawn_pos[1 + (63 - sq)] / 10)
        Js_wPawnMvt[1 + sq] = Js_wPawnMvt[1 + sq] + Js_pawnPlus
        Js_bPawnMvt[1 + sq] = Js_bPawnMvt[1 + sq] + Js_pawnPlus
        if (Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_white]] ~= 0) then
            if ((((fyle < 3) or (fyle > 4))) and (IArrow(sq, Js_pieceMap[1 + Js_white][1]) < 3)) then
                Js_wPawnMvt[1 + sq] = Js_wPawnMvt[1 + sq] + Js_castle_pawn
            end
        else
            if ((rank < 3) and (((fyle < 2) or (fyle > 5)))) then
                Js_wPawnMvt[1 + sq] = Js_wPawnMvt[1 + sq] + (Js_castle_pawn / 2)
            end
        end

        if (Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_black]] ~= 0) then
            if ((((fyle < 3) or (fyle > 4))) and (IArrow(sq, Js_pieceMap[1 + Js_black][1]) < 3)) then
                Js_bPawnMvt[1 + sq] = Js_bPawnMvt[1 + sq] + Js_castle_pawn
            end
        else
            if ((rank > 4) and (((fyle < 2) or (fyle > 5)))) then
                Js_bPawnMvt[1 + sq] = Js_bPawnMvt[1 + sq] + (Js_castle_pawn / 2)
            end
        end

        if (PawnStorm) then
            if (((IColmn(Js_pieceMap[1 + Js_white][1]) < 4) and (fyle > 4)) or (
                    (IColmn(Js_pieceMap[1 + Js_white][1]) > 3) and (fyle < 3))) then
                Js_wPawnMvt[1 + sq] = Js_wPawnMvt[1 + sq] + ((3 * rank) - 21)
            end
            if (((IColmn(Js_pieceMap[1 + Js_black][1]) < 4) and (fyle > 4)) or (
                    (IColmn(Js_pieceMap[1 + Js_black][1]) > 3) and (fyle < 3))) then
                Js_bPawnMvt[1 + sq] = Js_bPawnMvt[1 + sq] - (3 * rank)
            end
        end

        -- put in locals

        nwm = Js_knightMvt[1 + Js_white][1 + sq]
        nbm = Js_knightMvt[1 + Js_black][1 + sq]
        bwm = Js_bishopMvt[1 + Js_white][1 + sq]
        bbm = Js_bishopMvt[1 + Js_black][1 + sq]

        nwm = nwm + (5 - IArrow(sq, Js_pieceMap[1 + Js_black][1]))
        nwm = nwm + (5 - IArrow(sq, Js_pieceMap[1 + Js_white][1]))
        nbm = nbm + (5 - IArrow(sq, Js_pieceMap[1 + Js_white][1]))
        nbm = nbm + (5 - IArrow(sq, Js_pieceMap[1 + Js_black][1]))
        bwm = bwm + Js_bishopPlus
        bbm = bbm + Js_bishopPlus

        for i = Js_piecesCount[1 + Js_black], 0, -1 do
            pMap2 = Js_pieceMap[1 + Js_black][1 + i]
            if (IArrow(sq, pMap2) < 3) then
                nwm = nwm + Js_adv_knight
            end
        end

        for i = Js_piecesCount[1 + Js_white], 0, -1 do
            pMap2 = Js_pieceMap[1 + Js_white][1 + i]
            if (IArrow(sq, pMap2) < 3) then
                nbm = nbm + Js_adv_knight
            end
        end

        if (wstrong ~= 0) then
            nwm = nwm + Js_far_knight
        end
        if (bstrong ~= 0) then
            nbm = nbm + Js_far_knight
        end
        if (wstrong ~= 0) then
            bwm = bwm + Js_far_bishop
        end
        if (bstrong ~= 0) then
            bbm = bbm + Js_far_bishop
        end

        if (Js_withBishop[1 + Js_white] == 2) then
            bwm = bwm + 8
        end
        if (Js_withBishop[1 + Js_black] == 2) then
            bbm = bbm + 8
        end
        if (Js_withKnight[1 + Js_white] == 2) then
            nwm = nwm + 5
        end
        if (Js_withKnight[1 + Js_black] == 2) then
            nbm = nbm + 5
        end

        -- restore back
        Js_knightMvt[1 + Js_white][1 + sq] = nwm
        Js_knightMvt[1 + Js_black][1 + sq] = nbm
        Js_bishopMvt[1 + Js_white][1 + sq] = bwm
        Js_bishopMvt[1 + Js_black][1 + sq] = bbm

        Js_killArea[1 + Js_white][1 + sq] = 0
        Js_killArea[1 + Js_black][1 + sq] = 0
        if (IArrow(sq, Js_pieceMap[1 + Js_white][1]) == 1) then
            Js_killArea[1 + Js_black][1 + sq] = Js_king_agress
        end
        if (IArrow(sq, Js_pieceMap[1 + Js_black][1]) == 1) then
            Js_killArea[1 + Js_white][1 + sq] = Js_king_agress
        end

        Pd = 0
        for k = 0, Js_piecesCount[1 + Js_white], 1 do
            i = Js_pieceMap[1 + Js_white][1 + k]
            if (Js_board[1 + i] == Js_pawn) then
                pp = 1
                if (IRaw(i) == 6) then
                    z = i + 8
                else
                    z = i + 16
                end
                for j = i + 8, 63, 8 do
                    if (Pagress(Js_black, j) or (Js_board[1 + j] == Js_pawn)) then
                        pp = 0
                        break
                    end
                end
                if (pp ~= 0) then
                    Pd = Pd + (5 * Js_crossData[1 + (sq * 64 + z)])
                else
                    Pd = Pd + Js_crossData[1 + (sq * 64 + z)]
                end
            end
        end

        for k = 0, Js_piecesCount[1 + Js_black], 1 do
            i = Js_pieceMap[1 + Js_black][1 + k]
            if (Js_board[1 + i] == Js_pawn) then
                pp = 1
                if (IRaw(i) == 1) then
                    z = i - 8
                else
                    z = i - 16
                end
                for j = i - 8, 0, -8 do
                    if (Pagress(Js_white, j) or (Js_board[1 + j] == Js_pawn)) then
                        pp = 0
                        break
                    end
                end
                if (pp ~= 0) then
                    Pd = Pd + (5 * Js_crossData[1 + (sq * 64 + z)])
                else
                    Pd = Pd + Js_crossData[1 + (sq * 64 + z)]
                end
            end
        end

        if (Pd ~= 0) then
            val = Pd * Js_working2 / 10
            local qw = Js_kingMvt[1 + Js_white]
            qw[1 + sq] = qw[1 + sq] - val
            local qb = Js_kingMvt[1 + Js_black]
            qb[1 + sq] = qb[1 + sq] - val
        end
    end
end

function CalcKBNK(winner, king1, king2)
    local end_KBNKsq = 0
    local s = 0
    -- local sq = 0
    for sq = 0, 63, 1 do
        if (Js_board[1 + sq] == Js_bishop) then
            if (IRaw(sq) % 2 == IColmn(sq) % 2) then
                end_KBNKsq = 0
            else
                end_KBNKsq = 7
            end
        end
    end

    s = Js_ematrl[1 + winner] - 300
    if (end_KBNKsq == 0) then
        s = s + Js_end_KBNK[1 + king2]
    else
        s = s + Js_end_KBNK[1 + Iwxy(IRaw(king2), 7 - IColmn(king2))]
    end
    s = s - Js_crossData[1 + (king1 * 64 + king2)]
    s = s - IArrow(Js_pieceMap[1 + winner][2], king2)
    s = s - IArrow(Js_pieceMap[1 + winner][3], king2)
    return s
end

function ChangeForce()
    local tmatrl = 0
    local s1 = 0

    Js_ematrl[1 + Js_white] = (Js_matrl[1 + Js_white] - Js_pmatrl[1 + Js_white] - Js_kingVal)
    Js_ematrl[1 + Js_black] = (Js_matrl[1 + Js_black] - Js_pmatrl[1 + Js_black] - Js_kingVal)
    tmatrl = Js_ematrl[1 + Js_white] + Js_ematrl[1 + Js_black]
    if (tmatrl < 1400) then
        s1 = 10
    else
        if (tmatrl > 6600) then
            s1 = 0
        else
            s1 = (6600 - tmatrl) / 520
        end
    end
    if (s1 == Js_working) then
        return
    end
    Js_working = s1

    if (tmatrl < 1400) then
        s1 = 10
    else
        if (tmatrl > 3600) then
            s1 = 0
        else
            s1 = (3600 - tmatrl) / 220
        end
    end
    Js_working2 = s1

    Js_castle_pawn = (10 - Js_working)

    Js_pawnPlus = Js_working

    Js_adv_knight = ((Js_working + 2) / 3)
    Js_far_knight = ((Js_working + 6) / 2)

    Js_far_bishop = ((Js_working + 6) / 2)
    Js_bishopPlus = (2 * Js_working)

    Js_rookPlus = (6 * Js_working)

    Js_semiOpen_king = ((3 * Js_working - 30) / 2)
    Js_semiOpen_kingOther = (Js_semiOpen_king / 2)
    Js_castle_K = (10 - Js_working)
    Js_moveAcross_K = ((-40) / (Js_working + 1))
    Js_king_agress = ((10 - Js_working) / 2)
    if (Js_working < 8) then
        Js_safe_King = (16 - (2 * Js_working))
    else
        Js_safe_King = 0
    end
end

function Undo()
    local f = Js_movesList[1 + Js_nGameMoves].gamMv >> 8
    local t = Js_movesList[1 + Js_nGameMoves].gamMv & 0xFF
    local from = 0
    -- local g = 0

    if ((Js_board[1 + t] == Js_king) and (IArrow(t, f) > 1)) then
        DoCastle(Js_movesList[1 + Js_nGameMoves].color, f, t, 2)
    else
        if (((Js_color[1 + t] == Js_white) and (IRaw(f) == 6) and (IRaw(t) == 7)) or (
                (Js_color[1 + t] == Js_black) and (IRaw(f) == 1) and (IRaw(t) == 0))) then
            from = f
            for g = Js_nGameMoves - 1, 1, -1 do
                if ((Js_movesList[1 + g].gamMv & 0xFF) == from) then
                    from = Js_movesList[1 + g].gamMv >> 8
                end
            end

            if (((Js_color[1 + t] == Js_white) and (IRaw(from) == 1)) or
                    ((Js_color[1 + t] == Js_black) and (IRaw(from) == 6))) then
                Js_board[1 + t] = Js_pawn
            end
        end
        Js_board[1 + f] = Js_board[1 + t]
        Js_color[1 + f] = Js_color[1 + t]
        Js_board[1 + t] = Js_movesList[1 + Js_nGameMoves].piece
        Js_color[1 + t] = Js_movesList[1 + Js_nGameMoves].color

        if (Js_color[1 + t] ~= Js_hollow) then
            Js_nMvtOnBoard[1 + t] = Js_nMvtOnBoard[1 + t] - 1
        end
        Js_nMvtOnBoard[1 + f] = Js_nMvtOnBoard[1 + f] - 1
    end

    Js_nGameMoves = Js_nGameMoves - 1
    if (Js_fiftyMoves < Js_nGameMoves) then
        Js_fiftyMoves = Js_nGameMoves
    end

    Js_computer = Js_otherTroop[1 + Js_computer]
    Js_enemy = Js_otherTroop[1 + Js_enemy]
    Js_flag.mate = false
    Js_depth_Seek = 0

    -- UpdateDisplay()

    InitStatus()
end

function ISqAgrs(sq, side)
    local xside = Js_otherTroop[1 + side]
    local idir = (Js_pieceTyp[1 + xside][1 + Js_pawn] * 4096) + (sq * 64)
    local u = Js_nextArrow[1 + (idir + sq)]
    local ipos = 0

    if (u ~= sq) then
        if ((Js_board[1 + u] == Js_pawn) and (Js_color[1 + u] == side)) then
            return 1
        end
        u = Js_nextArrow[1 + (idir + u)]
        if ((u ~= sq) and (Js_board[1 + u] == Js_pawn) and (Js_color[1 + u] == side)) then
            return 1
        end
    end
    if (IArrow(sq, Js_pieceMap[1 + side][1]) == 1) then
        return 1
    end

    ipos = (Js_bishop * 4096) + (sq * 64)
    idir = ipos

    u = Js_nextCross[1 + (ipos + sq)]

    repeat
        if (Js_color[1 + u] == Js_hollow) then
            u = Js_nextCross[1 + (ipos + u)]
        else
            if ((Js_color[1 + u] == side) and (((Js_board[1 + u] == Js_queen) or (Js_board[1 + u] == Js_bishop)))) then
                return 1
            end
            u = Js_nextArrow[1 + (idir + u)]
        end
    until (u == sq)

    ipos = (Js_rook * 4096) + (sq * 64)
    idir = ipos

    u = Js_nextCross[1 + (ipos + sq)]
    repeat
        if (Js_color[1 + u] == Js_hollow) then
            u = Js_nextCross[1 + (ipos + u)]
        else
            if ((Js_color[1 + u] == side) and (((Js_board[1 + u] == Js_queen) or (Js_board[1 + u] == Js_rook)))) then
                return 1
            end
            u = Js_nextArrow[1 + (idir + u)]
        end
    until (u == sq)

    idir = (Js_knight * 4096) + (sq * 64)

    u = Js_nextArrow[1 + (idir + sq)]
    repeat
        if ((Js_color[1 + u] == side) and (Js_board[1 + u] == Js_knight)) then
            return 1
        end
        u = Js_nextArrow[1 + (idir + u)]
    until (u == sq)
    return 0
end

function Iwxy(a, b)
    return ((a << 3) | b)
end

function XRayBR(sq, s, mob)
    local Kf = Js_killArea[1 + Js_c1]
    local piece = Js_board[1 + sq]

    local ipos = (piece * 4096) + (sq * 64)
    local idir = ipos

    local u = Js_nextCross[1 + (ipos + sq)]
    local pin = -1


    mob.i = 0

    repeat
        s.i = s.i + Kf[1 + u]

        if (Js_color[1 + u] == Js_hollow) then
            mob.i = mob.i + 1

            if (Js_nextCross[1 + (ipos + u)] == Js_nextArrow[1 + (idir + u)]) then
                pin = -1
            end
            u = Js_nextCross[1 + (ipos + u)]
        else
            if (pin < 0) then
                if ((Js_board[1 + u] == Js_pawn) or (Js_board[1 + u] == Js_king)) then
                    u = Js_nextArrow[1 + (idir + u)]
                else
                    if (Js_nextCross[1 + (ipos + u)] ~= Js_nextArrow[1 + (idir + u)]) then
                        pin = u
                    end
                    u = Js_nextCross[1 + (ipos + u)]
                end
            else
                if ((Js_color[1 + u] == Js_c2) and (((Js_board[1 + u] > piece) or (Js_agress2[1 + u] == 0)))) then
                    if (Js_color[1 + pin] == Js_c2) then
                        s.i = s.i + Js_pinnedVal
                        if ((Js_agress2[1 + pin] == 0) or (Js_agress1[1 + pin] > Js_xlat[1 + Js_board[1 + pin]] + 1)) then
                            Js_pinned[1 + Js_c2] = Js_pinned[1 + Js_c2] + 1
                        end
                    else
                        s.i = s.i + Js_crossArrow
                    end
                end
                pin = -1
                u = Js_nextArrow[1 + (idir + u)]
            end
        end
    until (u == sq)
end

function ComputerMvt()
    if (Js_flag.mate) then
        return
    end
    Js_computerMoved =  true
    -- Js_startTime = os.clock()
    -- playdate.resetElapsedTime()
    
    ChoiceMov(Js_computer, 1)
    IfCheck()
    if (not Js_fUserWin_kc) then
        ShowMov(Js_asciiMove[1])
    end
    if (not CheckMatrl()) then
        Js_bDraw = 1
    end
    ShowStat()
end

function InitMoves()
    local dest = {}
    local steps = {}
    local sorted = {}

    local ptyp = 0
    local po = 0
    local p0 = 0
    local s = 0
    local i = 0
    local d = 0
    local di = 0

    local ipos = 0
    local idir = 0
    local delta = 0

    ptyp = 0
    while (ptyp < 8) do
        po = 0
        while (po < 64) do
            p0 = 0
            while (p0 < 64) do
                i = (ptyp * 4096) + (po * 64) + p0
                Js_nextCross[1 + i] = po --(char)
                Js_nextArrow[1 + i] = po --(char)
                p0 = p0 + 1
            end

            po = po + 1
        end

        ptyp = ptyp + 1
    end

    yield()
    ptyp = 1
    while (ptyp < 8) do
        po = 21
        while (po < 99) do
            if (Js_virtualBoard[1 + po] >= 0) then
                ipos = (ptyp * 4096) + (Js_virtualBoard[1 + po] * 64)
                idir = ipos

                di = 0
                d = 0
                while (d < 8) do
                    dest[1 + d] = {} -- creates object
                    dest[1 + d][1] = Js_virtualBoard[1 + po]
                    delta = Js_direction[1 + ptyp][1 + d]
                    if (delta ~= 0) then
                        p0 = po
                        s = 0
                        while (s < Js_maxJobs[1 + ptyp]) do
                            p0 = p0 + delta

                            if ((Js_virtualBoard[1 + p0] < 0) or (
                                    (((ptyp == Js_pawn) or (ptyp == Js_bkPawn))) and (s > 0) and
                                    (((d > 0) or (Js_reguBoard[1 + Js_virtualBoard[1 + po]] ~= Js_pawn))))) then
                                break
                            end
                            dest[1 + d][1 + s] = Js_virtualBoard[1 + p0]
                            s = s + 1
                        end
                    else
                        s = 0
                    end

                    steps[1 + d] = s

                    di = d
                    while ((s > 0) and (di > 0)) do
                        if (steps[1 + sorted[1 + (di - 1)]] == 0) then
                            sorted[1 + di] = sorted[1 + (di - 1)]
                        else
                            break
                        end
                        di = di - 1
                    end
                    sorted[1 + di] = d
                    d = d + 1
                end

                p0 = Js_virtualBoard[1 + po]
                if ((ptyp == Js_pawn) or (ptyp == Js_bkPawn)) then
                    s = 0
                    while (s < steps[1]) do
                        Js_nextCross[1 + (ipos + p0)] = dest[1][1 + s] --(char)
                        p0 = dest[1][1 + s]
                        s = s + 1
                    end
                    p0 = Js_virtualBoard[1 + po]

                    d = 1
                    while (d < 3) do
                        Js_nextArrow[1 + (idir + p0)] = dest[1 + d][1] --(char)
                        p0 = dest[1 + d][1]
                        d = d + 1
                    end
                else
                    Js_nextArrow[1 + (idir + p0)] = dest[1 + sorted[1]][1] --(char)
                    d = 0
                    while (d < 8) do
                        s = 0
                        while (s < steps[1 + sorted[1 + d]]) do
                            Js_nextCross[1 + (ipos + p0)] = dest[1 + sorted[1 + d]][1 + s] --(char)
                            p0 = dest[1 + sorted[1 + d]][1 + s]
                            if (d < 7) then
                                Js_nextArrow[1 + (idir + p0)] = dest[1 + sorted[1 + (d + 1)]][1] --(char)
                            end
                            s = s + 1
                        end
                        d = d + 1
                    end
                end
            end

            po = po + 1
        end

        ptyp = ptyp + 1
    end
end

function ShowMov(rgchMove)
    local fKcastle = false
    local fQcastle = false
    local szM = ""
    local waspromo = ""
    local mv2 = ""
    local mv22 = ""
    local i = 0

    for i = 0, 7, 1 do
        Js_movCh[1 + i] = " "
    end


    if (not Js_flip) then
        Js_nMovesMade = Js_nMovesMade + 1
        if (Js_nMovesMade < 10) then
            szM = " "
        end
        szM = szM .. string.format("%d", Js_nMovesMade) .. "."
    end

    Js_movCh[1] = rgchMove[1]
    Js_movCh[2] = rgchMove[2]
    Js_movCh[3] = "-"

    if (((Js_root.flags & Js_capture) ~= 0) or Js_fEat) then
        Js_movCh[3] = "x"
        Js_captured = true
    end

    Js_movCh[4] = rgchMove[3]
    Js_movCh[5] = rgchMove[4]

    if ((Js_root.flags & Js_promote) ~= 0) then
        waspromo = Js_upperNot[1 + Js_board[1 + Js_root.t]]
    end

    if (rgchMove[5] == "=") then
        waspromo = rgchMove[6]
    end

    i = 5
    if (string.len(waspromo) > 0) then
        Js_movCh[1 + (i + 0)] = "="
        Js_movCh[1 + (i + 1)] = waspromo
        i = i + 2
        -- promotion deostn work here
    end
    if (Js_bDraw ~= 0) then
        Js_movCh[1 + i] = "="
    end
    if (Js_fCheck_kc) then
        Js_movCh[1 + i] = "+"
    end
    if (Js_fMate_kc) then
        Js_movCh[1 + i] = "#"
    end

    mv2 = copyValueOf(Js_movCh)

    if (Js_myPiece == "K") then
        mv22 = string.sub(mv2, 1, 5)

        if ((mv22 == "e1-g1") or (mv22 == "e8-g8")) then
            fKcastle = true
        end
        if ((mv22 == "e1-c1") or (mv22 == "e8-c8")) then
            fQcastle = true
        end
    end

    if ((fKcastle) or (fQcastle)) then
        if (fKcastle) then
            szM = szM .. "O-O" .. Js_movCh[1 + i]
        end
        if (fQcastle) then
            szM = szM .. "O-O-O" .. Js_movCh[1 + i]
        end
        Js_castled = true
    else
        szM = szM .. Js_myPiece .. mv2
    end

    szM = szM .. "  "
    szM = string.sub(szM, 1, string.find(szM, "  "))


    if (Js_fAbandon) then
        szM = "resign"
    else
        Js_pgn = Js_pgn .. szM
    end

    Js_myPiece = ""
    MessageOut(szM, Js_flip)

    Js_flip = (not Js_flip)
end

function CheckMov(s, iop)
    local tempb = {i = 0}
    local tempc = {i = 0}
    local tempsf = {i = 0}
    local tempst = {i = 0}
    local xnode = {replay = 0, f = 0, t = 0, flags = 0, score = 0}
    local node = nil

    local cnt = 0
    local pnt = 0
    -- local s0 = ""
    -- local s1 = ""

    if (iop == 2) then
        UnValidateMov(Js_enemy, xnode, tempb, tempc, tempsf, tempst)
        return 0
    end

    cnt = 0
    AvailMov(Js_enemy, 2)
    pnt = Js_treePoint[3]
    -- s0 = copyValueOf(s)

    while (pnt < Js_treePoint[4]) do
        node = Js_Tree[1 + pnt] -- _BTREE
        pnt = pnt + 1

        Lalgb(node.f, node.t, node.flags)
        -- s1 = copyValueOf(Js_asciiMove[1])
        if (not ((((s[1] ~= Js_asciiMove[1][1]) or (s[2] ~= Js_asciiMove[1][2]) or (s[3] ~= Js_asciiMove[1][3]) or (s[4] ~= Js_asciiMove[1][4]))) and
                (((s[1] ~= Js_asciiMove[2][1]) or (s[2] ~= Js_asciiMove[2][2]) or (s[3] ~= Js_asciiMove[2][3]) or (s[4] ~= Js_asciiMove[2][4]))) and
                (((s[1] ~= Js_asciiMove[3][1]) or (s[2] ~= Js_asciiMove[3][2]) or (s[3] ~= Js_asciiMove[3][3]) or (s[4] ~= Js_asciiMove[3][4]))) and ((
                    (s[1] ~= Js_asciiMove[4][1]) or (s[2] ~= Js_asciiMove[4][2]) or (s[3] ~= Js_asciiMove[4][3]) or (s[4] ~= Js_asciiMove[4][4]))))) then
            cnt = cnt + 1
            xnode = node
            break
        end
    end

    if (cnt == 1) then
        ValidateMov(Js_enemy, xnode, tempb, tempc, tempsf, tempst, Js_gainScore)
        if (ISqAgrs(Js_pieceMap[1 + Js_enemy][1], Js_computer) ~= 0) then
            UnValidateMov(Js_enemy, xnode, tempb, tempc, tempsf, tempst)
            Js_userInCheck = true
            return 0
        end

        if (iop == 1) then
            return 1
        end
        -- UpdateDisplay()

        Js_fEat = ((xnode.flags & Js_capture) ~= 0)
        if ((Js_board[1 + xnode.t] == Js_pawn) or ((xnode.flags & Js_capture) ~= 0) or
                ((xnode.flags & Js_castle_msk) ~= 0)) then
            Js_fiftyMoves = Js_nGameMoves
        end

        Js_movesList[1 + Js_nGameMoves].score = 0

        Lalgb(xnode.f, xnode.t, 0)
        return 1
    end

    return 0
end

function UnValidateMov(side, node, tempb, tempc, tempsf, tempst)
    local xside = Js_otherTroop[1 + side]
    local f = node.f
    local t = node.t
    Js_indenSqr = -1
    Js_nGameMoves = Js_nGameMoves - 1
    if ((node.flags & Js_castle_msk) ~= 0) then
        DoCastle(side, f, t, 2)
    else
        Js_color[1 + f] = Js_color[1 + t]
        Js_board[1 + f] = Js_board[1 + t]
        Js_scoreOnBoard[1 + f] = tempsf.i
        Js_pieceIndex[1 + f] = Js_pieceIndex[1 + t]
        Js_pieceMap[1 + side][1 + Js_pieceIndex[1 + f]] = f
        Js_color[1 + t] = tempc.i
        Js_board[1 + t] = tempb.i
        Js_scoreOnBoard[1 + t] = tempst.i
        if ((node.flags & Js_promote) ~= 0) then
            Js_board[1 + f] = Js_pawn
            Js_pawnMap[1 + side][1 + IColmn(t)] = Js_pawnMap[1 + side][1 + IColmn(t)] + 1
            Js_matrl[1 + side] = Js_matrl[1 + side] + (Js_pawnVal - Js_valueMap[1 + (node.flags & Js_pawn_msk)])
            Js_pmatrl[1 + side] = Js_pmatrl[1 + side] + Js_pawnVal
        end

        if (tempc.i ~= Js_hollow) then
            UpdatePiecMap(tempc.i, t, 2)
            if (tempb.i == Js_pawn) then
                Js_pawnMap[1 + tempc.i][1 + IColmn(t)] = Js_pawnMap[1 + tempc.i][1 + IColmn(t)] + 1
            end
            if (Js_board[1 + f] == Js_pawn) then
                Js_pawnMap[1 + side][1 + IColmn(t)] = Js_pawnMap[1 + side][1 + IColmn(t)] - 1
                Js_pawnMap[1 + side][1 + IColmn(f)] = Js_pawnMap[1 + side][1 + IColmn(f)] + 1
            end
            Js_matrl[1 + xside] = Js_matrl[1 + xside] + Js_valueMap[1 + tempb.i]
            if (tempb.i == Js_pawn) then
                Js_pmatrl[1 + xside] = Js_pmatrl[1 + xside] + Js_pawnVal
            end

            Js_nMvtOnBoard[1 + t] = Js_nMvtOnBoard[1 + t] - 1
        end

        if ((node.flags & Js_enpassant_msk) ~= 0) then
            PrisePassant(xside, f, t, 2)
        end

        Js_nMvtOnBoard[1 + f] = Js_nMvtOnBoard[1 + f] - 1
    end
end

function FJunk(sq)
    local piece = Js_board[1 + sq]
    local ipos = (Js_pieceTyp[1 + Js_c1][1 + piece] * 4096) + (sq * 64)
    local idir = ipos
    local u = Js_nextCross[1 + (ipos + sq)]

    if (piece == Js_pawn) then
        if (Js_color[1 + u] == Js_hollow) then
            if (Js_agress1[1 + u] >= Js_agress2[1 + u]) then
                return false
            end
            if (Js_agress2[1 + u] < Js_xltP) then
                u = Js_nextCross[1 + (ipos + u)]
                if ((Js_color[1 + u] == Js_hollow) and (Js_agress1[1 + u] >= Js_agress2[1 + u])) then
                    return false
                end
            end
        end
        u = Js_nextArrow[1 + (idir + sq)]
        if (Js_color[1 + u] == Js_c2) then
            return false
        end
        u = Js_nextArrow[1 + (idir + u)]
        if (Js_color[1 + u] == Js_c2) then
            return false
        end
    else
        repeat
            if ((Js_color[1 + u] ~= Js_c1) and (((Js_agress2[1 + u] == 0) or (Js_board[1 + u] >= piece)))) then
                return false
            end
            if (Js_color[1 + u] == Js_hollow) then
                u = Js_nextCross[1 + (ipos + u)]
            else
                u = Js_nextArrow[1 + (idir + u)]
            end
        until (u == sq)
    end
    return true
end

function ShowThink(score4, best)
    local s = ""
    local i = 0

    if (Js_depth_Seek > Js_realBestDepth) then
        Js_realBestScore = -20000
    end

    if ((Js_depth_Seek >= Js_realBestDepth) and (score4 >= Js_realBestScore)) then
        Js_realBestDepth = Js_depth_Seek
        Js_realBestScore = score4
        Js_realBestMove = best[2]
    end

    if ((Js_depth_Seek == Js_lastDepth) and (score4 == Js_lastScore)) then
        return
    end
    Js_lastDepth = Js_depth_Seek
    Js_lastScore = score4

    i = 1
    while (best[1 + i] > 0) do
        Lalgb((best[1 + i] >> 8), (best[1 + i] & 0xFF), 0)

        Js_tmpCh[1] = Js_asciiMove[1][1]
        Js_tmpCh[2] = Js_asciiMove[1][2]
        Js_tmpCh[3] = "-"
        Js_tmpCh[4] = Js_asciiMove[1][3]
        Js_tmpCh[5] = Js_asciiMove[1][4]
        Js_tmpCh[6] = 0
        s = s .. copyValueOf(Js_tmpCh) .. " "
        i = i + 1
    end
    -- MessageOut("Thinking: "..s , true)
    -- ShowScore(score4)
end

function ResetData()
    -- local i = 0
    -- local j = 0

    yield()
    Js_movesList = {}
    for i = 0, 512, 1 do
        Js_movesList[1 + i] = {gamMv = 0, score = 0, piece = 0, color = 0}
    end

    yield()
    Js_Tree = {}
    for i = 0, 2000, 1 do
        Js_Tree[1 + i] = {replay = 0, f = 0, t = 0, flags = 0, score = 0}
    end

    yield()
    for i = 0, Js_maxDepth - 1, 1 do
        Js_treePoint[1 + i] = 0
        Js_variants[1 + i] = 0
        Js_flagCheck[1 + i] = 0
        Js_flagEat[1 + i] = 0
        Js_menacePawn[1 + i] = 0
        Js_scorePP[1 + i] = 0
        Js_scoreTP[1 + i] = 0
        Js_eliminate0[1 + i] = 0
        Js_eliminate1[1 + i] = 0
        Js_eliminate3[1 + i] = 0
    end

    for i = 0, 1, 1 do
        for j = 0, 15, 1 do
            Js_pieceMap[1 + i] = {} -- creates object
            Js_pieceMap[1 + i][1 + j] = 0
        end
    end

    for i = 0, 1, 1 do
        for j = 0, 7, 1 do
            Js_pawnMap[1 + i] = {} -- creates object
            Js_pawnMap[1 + i][1 + j] = 0
        end
    end

    for i = 0, 63, 1 do
        Js_nMvtOnBoard[1 + i] = 0
        Js_scoreOnBoard[1 + i] = 0
        Js_pieceIndex[1 + i] = 0
    end

    yield()
    for i = 0, 4200, 1 do
        Js_arrowData[1 + i] = 0
        Js_crossData[1 + i] = 0
    end

    yield()
    for i = 0, 1, 1 do
        for j = 0, 63, 1 do
            Js_agress[1 + i] = {} -- creates object
            Js_agress[1 + i][1 + j] = 0
        end
    end


    for i = 0, 63, 1 do
        Js_wPawnMvt[1 + i] = 0
        Js_bPawnMvt[1 + i] = 0
    end

    for i = 0, 1, 1 do
        Js_knightMvt[1 + i] = {} -- creates object
        Js_bishopMvt[1 + i] = {} -- creates object
        Js_kingMvt[1 + i] = {} -- creates object
        Js_killArea[1 + i] = {} -- creates object

        for j = 0, 63, 1 do
            Js_knightMvt[1 + i][1 + j] = 0
            Js_bishopMvt[1 + i][1 + j] = 0
            Js_kingMvt[1 + i][1 + j] = 0
            Js_killArea[1 + i][1 + j] = 0
        end
    end


    -- this takes longer, maybe it is possible to optimize via (undefined?0:value)

    yield()
    for i = 1, 10000, 1 do
        Js_storage[1 + i] = 0
    end

    yield()
    for i = 1, 40000, 1 do
        Js_nextCross[1 + i] = 0
        Js_nextArrow[1 + i] = 0
    end
    yield()
end

function InChecking(side)
    -- local i = 0
    for i = 0, 63, 1 do
        if ((Js_board[1 + i] == Js_king) and
                (Js_color[1 + i] == side) and
                (ISqAgrs(i, Js_otherTroop[1 + side]) ~= 0)) then
            return true
        end
    end

    return false
end

function ShowScore(score5)
    local fMinus = score5 < 0
    local sz = ""

    if (fMinus) then
        score5 = -score5
    end
    if (score5 ~= 0) then
        score5 = score5 + 1
    end

    if (score5 ~= 0) then
        sz = iif(fMinus, "-", "+")
    end

    sz = sz .. string.format("%.2f", score5 / 100)

    MessageOut("(" .. sz .. ")", false)
end

function MixBoard(a, b, c)
    -- local sq = 0
    for sq = 0, 63, 1 do
        c[1 + sq] = ((a[1 + sq] * (10 - Js_working) + b[1 + sq] * Js_working) / 10)
    end
end

function InitGame()
    -- local i = 0

    ResetData()

    Js_flip = false

    Js_fInGame = true
    Js_fGameOver = false

    Js_fCheck_kc = false
    Js_fMate_kc = false
    Js_fSoonMate_kc = false

    Js_bDraw = 0
    Js_fStalemate = false
    Js_fAbandon = false
    Js_fUserWin_kc = false

    yield()
    InitArrow()
    yield()
    InitMoves()

    Js_working = -1
    Js_working2 = -1

    Js_flag.mate = false
    Js_flag.recapture = true

    Js_cNodes = 0
    Js_indenSqr = 0
    Js_scoreDither = 0
    Js__alpha = Js_N9
    Js__beta = Js_N9
    Js_dxAlphaBeta = Js_N9
    Js_maxDepthSeek = (Js_maxDepth - 1)

    Js_nMovesMade = 0
    Js_specialScore = 0
    Js_nGameMoves = 0
    Js_fiftyMoves = 1
    Js_hint = 3092

    Js_fDevl[1 + Js_white] = 0
    Js_fDevl[1 + Js_black] = 0
    Js_roquer[1 + Js_white] = 0
    Js_roquer[1 + Js_black] = 0
    Js_menacePawn[1] = 0
    Js_flagEat[1] = 0
    Js_scorePP[1] = 12000
    Js_scoreTP[1] = 12000

    for i = 0, 63, 1 do
        Js_board[1 + i] = Js_reguBoard[1 + i]
        Js_color[1 + i] = Js_reguColor[1 + i]
        Js_nMvtOnBoard[1 + i] = 0
    end

    if (Js_nMovesMade == 0) then
        Js_computer = Js_white
        Js_player = Js_black
        Js_enemy = Js_player
    end

    Js_fUserWin_kc = false

    InitStatus()

    Js_pgn = ""
end

function IColmn(a)
    return (a & 7)
end

function IRaw(a)
    return (a >> 3)
end

function ShowStat()
    local sz = ""
    local tmpPgn = ""
    if ((Js_fMate_kc) and (not (Js_fCheck_kc))) then
        Js_fStalemate = true
    end

    if (Js_fCheck_kc) then
        sz = "Check+"
    end

    if (Js_fMate_kc) then
        sz = "Checkmate!"
    end

    if (Js_bDraw ~= 0) then
        sz = "Draw"
    end
    if (Js_fStalemate) then
        sz = "Stalemate!"
    end
    if (Js_fAbandon) then
        sz = "resign"
    end
    if (Js_bDraw == 3) then
        sz = sz .. "At least 3 times repeat-position !"
    else
        if (Js_bDraw == 1) then
            sz = sz .. "Can't checkmate !"
        end
    end

    if (Js_fMate_kc or Js_fAbandon) then
        tmpPgn = " " .. iif(Js_flip, "1-0", "0-1")
        sz = sz .. tmpPgn
    end
    if (Js_bDraw > 0 or Js_fStalemate) then
        tmpPgn = " 1/2-1/2"
        sz = sz .. tmpPgn
    end

    if ((not Js_fMate_kc) and (Js_bDraw == 0) and (not Js_fStalemate) and (not Js_fAbandon)) then
        return
    end

    -- when game is finished only, otherwise show status
    Js_fInGame = false

    if (string.len(sz) > 0) then
        MessageOut(sz, true)
        Js_pgn = Js_pgn .. tmpPgn
    end
end

function CalcKPK(side, winner, loser, king1, king2, sq)
    local s = iif((Js_piecesCount[1 + winner] == 1), 50, 120)
    local r = 0

    if (winner == Js_white) then
        if (side == loser) then
            r = IRaw(sq) - 1
        else
            r = IRaw(sq)
        end

        if ((IRaw(king2) >= r) and (IArrow(sq, king2) < 8 - r)) then
            s = s + (10 * IRaw(sq))
        else
            s = 500 + (50 * IRaw(sq))
        end

        if (IRaw(sq) < 6) then
            sq = sq + 16
        else
            if (IRaw(sq) == 6) then
                sq = sq + 8
            end
        end
    else
        if (side == loser) then
            r = IRaw(sq) + 1
        else
            r = IRaw(sq)
        end

        if ((IRaw(king2) <= r) and (IArrow(sq, king2) < r + 1)) then
            s = s + (10 * (7 - IRaw(sq)))
        else
            s = 500 + (50 * (7 - IRaw(sq)))
        end

        if (IRaw(sq) > 1) then
            sq = sq - 16
        else
            if (IRaw(sq) == 1) then
                sq = sq - 8
            end
        end
    end
    s = s + ((8 * Js_crossData[1 + ((king2 * 64) + sq)]) - Js_crossData[1 + ((king1 * 64) + sq)])
    return s
end

function CalcKg(side, score)
    local winner = 0
    local loser = 0
    local king1 = 0
    local king2 = 0
    local s = 0
    -- local i = 0

    ChangeForce()

    winner = iif((Js_matrl[1 + Js_white] > Js_matrl[1 + Js_black]), Js_white, Js_black)
    loser = Js_otherTroop[1 + winner]
    king1 = Js_pieceMap[1 + winner][1]
    king2 = Js_pieceMap[1 + loser][1]
    s = 0

    if (Js_pmatrl[1 + winner] > 0) then
        for i = 1, Js_piecesCount[1 + winner], 1 do
            s = s + CalcKPK(side, winner, loser, king1, king2, Js_pieceMap[1 + winner][1 + i])
        end
    else
        if (Js_ematrl[1 + winner] == Js_bishopVal + Js_knightVal) then
            s = CalcKBNK(winner, king1, king2)
        else
            if (Js_ematrl[1 + winner] > Js_bishopVal) then
                s = 500 + Js_ematrl[1 + winner] - Js_vanish_K[1 + king2] - (2 * IArrow(king1, king2))
            end
        end
    end

    score.i = iif((side == winner), s, -s)
end

function IArrow(a, b)
    return Js_arrowData[1 + ((a * 64) + b)]
end

function MoveTree(to, from)
    to.f = from.f
    to.t = from.t
    to.score = from.score
    to.replay = from.replay
    to.flags = from.flags
end

function PrisePassant(xside, f, t, iop)
    local l = iif((t > f), t - 8, t + 8)

    if (iop == 1) then
        Js_board[1 + l] = Js_empty
        Js_color[1 + l] = Js_hollow
    else
        Js_board[1 + l] = Js_pawn
        Js_color[1 + l] = xside
    end
    InitStatus()
end

-- function GetAlgMvt(ch)
--     -- local i = 0
--     for i = 0, 63, 1 do
--         if (ch == string.sub(Js_szIdMvt, i + 1, i + 1)) then
--             return Js_szAlgMvt[1 + i]
--         end
--     end

--     return "a1"
-- end

function copyValueOf(a)
    local str = ""
    -- local i = 0
    for i = 0, #a - 1, 1 do
        if (type(a[1 + i]) == "string") then
            str = str .. a[1 + i]
        else
            if (a[1 + i] ~= 0) then
                str = str .. string.format("%c", a[1 + i])
            end
        end
    end
    return str
end

function Agression(side, a)
    -- local i = 0
    local sq = 0
    local piece = 0
    local c = 0
    local idir = 0
    local ipos = 0
    local u = 0

    for i = 0, 63, 1 do
        a[1 + i] = 0
        Js_agress[1 + side][1 + i] = 0
    end

    for i = Js_piecesCount[1 + side], 0, -1 do
        sq = Js_pieceMap[1 + side][1 + i]
        piece = Js_board[1 + sq]
        c = Js_xlat[1 + piece]

        if (Js_heavy[1 + piece] ~= false) then
            ipos = (piece * 4096) + (sq * 64)
            idir = ipos

            u = Js_nextCross[1 + (ipos + sq)]
            repeat
                a[1 + u] = a[1 + u] + 1
                a[1 + u] = (a[1 + u] | c)

                Js_agress[1 + side][1 + u] = Js_agress[1 + side][1 + u] + 1
                Js_agress[1 + side][1 + u] = (Js_agress[1 + side][1 + u] | c)

                if (Js_color[1 + u] == Js_hollow) then
                    u = Js_nextCross[1 + (ipos + u)]
                else
                    u = Js_nextArrow[1 + (idir + u)]
                end
            until (u == sq)
        else
            idir = (Js_pieceTyp[1 + side][1 + piece] * 4096) + (sq * 64)

            u = Js_nextArrow[1 + (idir + sq)]
            repeat
                a[1 + u] = a[1 + u] + 1
                a[1 + u] = (a[1 + u] | c)

                Js_agress[1 + side][1 + u] = Js_agress[1 + side][1 + u] + 1
                Js_agress[1 + side][1 + u] = (Js_agress[1 + side][1 + u] | c)

                u = Js_nextArrow[1 + (idir + u)]
            until (u == sq)
        end
    end
end

function InitArrow()
    local a = 0
    local b = 0
    local d = 0
    local di = 0

    while (a < 64) do
        b = 0
        while (b < 64) do
            d = abs(IColmn(a) - IColmn(b))
            di = abs(IRaw(a) - IRaw(b))

            Js_crossData[1 + ((a * 64) + b)] = (d + di)
            Js_arrowData[1 + ((a * 64) + b)] = iif((d > di), d, di)
            b = b + 1
        end
        a = a + 1
    end
end

function IfCheck()
    -- local i = 0
    for i = 0, 63, 1 do
        if (Js_board[1 + i] == Js_king) then
            if (Js_color[1 + i] == Js_white) then
                if (ISqAgrs(i, Js_black) ~= 0) then
                    Js_fCheck_kc = true
                    return
                end
            else
                if (ISqAgrs(i, Js_white) ~= 0) then
                    Js_fCheck_kc = true
                    return
                end
            end
        end
    end

    Js_fCheck_kc = false
end

function Anyagress(c, u)
    return iif((Js_agress[1 + c][1 + u] > 0), 1, 0)
end

function KnightPts(sq, side)
    local s = Js_knightMvt[1 + Js_c1][1 + sq]
    local a1 = 0
    local a2 = (Js_agress2[1 + sq] & 0x4FFF)

    if (a2 > 0) then
        a1 = (Js_agress1[1 + sq] & 0x4FFF)
        if ((a1 == 0) or (a2 > Js_xltBN + 1)) then
            s = s + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1

            if (FJunk(sq)) then
                Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            end
        else
            if ((a2 >= Js_xltBN) or (a1 < Js_xltP)) then
                s = s + Js_agress_across
            end
        end
    end
    return s
end

function QueenPts(sq, side)
    local s = iif((IArrow(sq, Js_pieceMap[1 + Js_c2][1]) < 3), 12, 0)
    local a1 = 0
    local a2 = (Js_agress2[1 + sq] & 0x4FFF)

    if (Js_working > 2) then
        s = s + (14 - Js_crossData[1 + ((sq * 64) + Js_pieceMap[1 + Js_c2][1])])
    end

    if (a2 > 0) then
        a1 = (Js_agress1[1 + sq] & 0x4FFF)
        if ((a1 == 0) or (a2 > Js_xltQ + 1)) then
            s = s + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            if (FJunk(sq)) then
                Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            end
        else
            if ((a2 >= Js_xltQ) or (a1 < Js_xltP)) then
                s = s + Js_agress_across
            end
        end
    end
    return s
end

function PositPts(side, score)
    local pscore = { 0, 0 }
    local xside = 0
    -- local i = 0
    local sq = 0
    local s = 0

    ChangeForce()

    xside = Js_otherTroop[1 + side]
    pscore[1 + Js_black] = 0
    pscore[1 + Js_white] = 0

    for Js_c1 = Js_white, Js_black, 1 do
        Js_c2 = Js_otherTroop[1 + Js_c1]
        Js_agress1 = Js_agress[1 + Js_c1]
        Js_agress2 = Js_agress[1 + Js_c2]
        Js_pawc1 = Js_pawnMap[1 + Js_c1]
        Js_pawc2 = Js_pawnMap[1 + Js_c2]
        for i = Js_piecesCount[1 + Js_c1], 0, -1 do
            sq = Js_pieceMap[1 + Js_c1][1 + i]

            if (Js_board[1 + sq] == Js_pawn) then
                s = PawnPts(sq, side)
            else
                if (Js_board[1 + sq] == Js_knight) then
                    s = KnightPts(sq, side)
                else
                    if (Js_board[1 + sq] == Js_bishop) then
                        s = BishopPts(sq, side)
                    else
                        if (Js_board[1 + sq] == Js_rook) then
                            s = RookPts(sq, side)
                        else
                            if (Js_board[1 + sq] == Js_queen) then
                                s = QueenPts(sq, side)
                            else
                                if (Js_board[1 + sq] == Js_king) then
                                    s = KingPts(sq, side)
                                else
                                    s = 0
                                end
                            end
                        end
                    end
                end
            end

            pscore[1 + Js_c1] = pscore[1 + Js_c1] + s
            Js_scoreOnBoard[1 + sq] = s
        end
    end

    if (Js_pinned[1 + side] > 1) then
        pscore[1 + side] = pscore[1 + side] + Js_pinned_other
    end

    if (Js_pinned[1 + xside] > 1) then
        pscore[1 + xside] = pscore[1 + xside] + Js_pinned_other
    end

    score.i = (Js_matrl[1 + side] - Js_matrl[1 + xside] + pscore[1 + side] - pscore[1 + xside] + 10)

    if ((score.i > 0) and (Js_pmatrl[1 + side] == 0)) then
        if (Js_ematrl[1 + side] < Js_rookVal) then
            score.i = 0
        else
            if (score.i < Js_rookVal) then
                score.i = score.i / 2
            end
        end
    end

    if ((score.i < 0) and (Js_pmatrl[1 + xside] == 0)) then
        if (Js_ematrl[1 + xside] < Js_rookVal) then
            score.i = 0
        else
            if ((-score.i) < Js_rookVal) then
                score.i = score.i / 2
            end
        end
    end

    if ((Js_matrl[1 + xside] == Js_kingVal) and (Js_ematrl[1 + side] > Js_bishopVal)) then
        score.i = score.i + 200
    end
    if ((Js_matrl[1 + side] == Js_kingVal) and (Js_ematrl[1 + xside] > Js_bishopVal)) then
        score.i = score.i - 200
    end
end

function PlayMov()
    -- UpdateDisplay()

    Js_currentScore = Js_root.score
    Js_fSoonMate_kc = false
    if ((iif((Js_root.flags == 0), 0, 1) & iif((Js_draw == 0), 0, 1)) ~= 0) then
        -- Js_fGameOver = true
    else
        if (Js_currentScore == -9999) then
            Js_fGameOver = true
            Js_fMate_kc = true
            Js_fUserWin_kc = true
        else
            if (Js_currentScore == 9998) then
                Js_fGameOver = true
                Js_fMate_kc = true
                Js_fUserWin_kc = false
            else
                if (Js_currentScore < -9000) then
                    Js_fSoonMate_kc = true
                else
                    if (Js_currentScore > 9000) then
                        Js_fSoonMate_kc = true
                    end
                end
            end
        end
    end
    ShowScore(Js_currentScore)
end

function IRepeat(cnt)
    local c = 0
    -- local i = 0

    local m = 0
    local f = 0
    local t = 0

    cnt = 0
    if (Js_nGameMoves > Js_fiftyMoves + 3) then
        for i = 0, 63, 1 do
            Js_b_r[1 + i] = 0
        end

        for i = Js_nGameMoves, Js_fiftyMoves + 1, -1 do
            m = Js_movesList[1 + i].gamMv
            f = (m >> 8)
            t = (m & 0xFF)
            Js_b_r[1 + f] = Js_b_r[1 + f] + 1
            c = c + iif((Js_b_r[1 + f] == 0), -1, 1)
            Js_b_r[1 + t] = Js_b_r[1 + t] - 1
            c = c + iif((Js_b_r[1 + t] == 0), -1, 1)

            if (c == 0) then
                cnt = cnt + 1
            end
        end
    end

    if (cnt == 3) then
        Js_bDraw = 3
    end

    return cnt
end

function ChoiceMov(side, iop)
    local tempb = {i = 0}
    local tempc = {i = 0}
    local tempsf = {i = 0}
    local tempst = {i = 0}
    local rpt = {i = 0}
    local score = {i = 0}

    local alpha = 0
    local beta = 0
    -- local i = 0
    local xside = Js_otherTroop[1 + side]
    local m_f = 0
    local m_t = 0

    Js_flag.timeout = false

    if (iop ~= 2) then
        Js_player = side
    end

    WatchPosit()

    PositPts(side, score)

    if (Js_depth_Seek == 0) then
        for i = 0, 10000, 1 do
            Js_storage[1 + i] = 0
        end

        Js_origSquare = -1
        Js_destSquare = -1
        Js_ptValue = 0
        if (iop ~= 2) then
            Js_hint = 0
        end

        for i = 0, Js_maxDepth - 1, 1 do
            Js_variants[1 + i] = 0
            Js_eliminate0[1 + i] = 0
            Js_eliminate1[1 + i] = 0
            Js_eliminate2[1 + i] = 0
            Js_eliminate3[1 + i] = 0
        end

        alpha = score.i - Js_N9
        beta = score.i + Js_N9
        rpt.i = 0
        Js_treePoint[2] = 0
        Js_root = Js_Tree[1]
        AvailMov(side, 1)

        for i = Js_treePoint[2], Js_treePoint[3] - 1, 1 do
            Peek(i, Js_treePoint[3] - 1)
        end

        Js_cNodes = 0
        Js_cCompNodes = 0

        Js_scoreDither = 0
        Js_dxDither = 20
    end
   
    while ((not Js_flag.timeout) and (Js_depth_Seek < Js_maxDepthSeek)) do
        yield()
        Js_depth_Seek = Js_depth_Seek + 1

        score.i = Seek(side, 1, Js_depth_Seek, alpha, beta, Js_variants, rpt)
        for i = 1, Js_depth_Seek, 1 do
            Js_eliminate0[1 + i] = Js_variants[1 + i]
        end

        if (score.i < alpha) then
            score.i = Seek(side, 1, Js_depth_Seek, -9000, score.i, Js_variants, rpt)
        end

        if ((score.i > beta) and ((Js_root.flags & Js__idem) == 0)) then
            score.i = Seek(side, 1, Js_depth_Seek, score.i, 9000, Js_variants, rpt)
        end

        score.i = Js_root.score

        for i = Js_treePoint[2] + 1, Js_treePoint[3] - 1, 1 do
            Peek(i, Js_treePoint[3] - 1)
        end

        for i = 1, Js_depth_Seek, 1 do
            Js_eliminate0[1 + i] = Js_variants[1 + i]
        end

        if ((Js_root.flags & Js__idem) ~= 0) then
            Js_flag.timeout = true
        end

        if (Js_Tree[2].score < -9000) then
            Js_flag.timeout = true
        end

        if (not Js_flag.timeout) then
            Js_scoreTP[1] = score.i
            Js_scoreDither = iif((Js_scoreDither == 0), score.i, ((Js_scoreDither + score.i) / 2))
        end
        Js_dxDither = (20 + abs(Js_scoreDither / 12))
        beta = score.i + Js__beta
        if (Js_scoreDither < score.i) then
            alpha = Js_scoreDither - Js__alpha - Js_dxDither
        else
            alpha = score.i - Js__alpha - Js_dxDither
        end

    end

    score.i = Js_root.score

    if (iop == 2) then
        return
    end

    Js_hint = Js_variants[3]

    if ((score.i == -9999) or (score.i == 9998)) then
        Js_flag.mate = true
        Js_fMate_kc = true
    end

    if ((score.i > -9999) and (rpt.i <= 2)) then
        if (score.i < Js_realBestScore) then
            m_f = (Js_realBestMove >> 8)
            m_t = (Js_realBestMove & 0xFF)
            for i = 0, 2000, 1 do
                if ((m_f == Js_Tree[1 + i].f) and (m_t == Js_Tree[1 + i].t) and (Js_realBestScore == Js_Tree[1 + i].score)) then
                    Js_root = Js_Tree[1 + i]

                    break
                end
            end
        end

        Js_myPiece = Js_rgszPiece[1 + Js_board[1 + Js_root.f]]

        ValidateMov(side, Js_root, tempb, tempc, tempsf, tempst, Js_gainScore)

        if (InChecking(Js_computer)) then
            UnValidateMov(side, Js_root, tempb, tempc, tempsf, tempst)
            Js_fAbandon = true
        else
            Lalgb(Js_root.f, Js_root.t, Js_root.flags)
            PlayMov()
        end
    else
        if (Js_bDraw == 0) then
            Lalgb(0, 0, 0)
            if (not Js_flag.mate) then
                Js_fAbandon = true
            else
                Js_fUserWin_kc = true
            end
        end
    end

    if (Js_flag.mate) then
        Js_hint = 0
    end
    if ((Js_board[1 + Js_root.t] == Js_pawn) or ((Js_root.flags & Js_capture) ~= 0) or
            ((Js_root.flags & Js_castle_msk) ~= 0)) then
        Js_fiftyMoves = Js_nGameMoves
    end
    Js_movesList[1 + Js_nGameMoves].score = score.i

    if (Js_nGameMoves > 500) then
        Js_flag.mate = true
    end
    Js_player = xside
    Js_depth_Seek = 0
end

function MultiMov(ply, sq, side, xside)
    local piece = Js_board[1 + sq]

    local i = (Js_pieceTyp[1 + side][1 + piece] * 4096) + (sq * 64)
    local ipos = i
    local idir = i
    local u = Js_nextCross[1 + (ipos + sq)]
    if (piece == Js_pawn) then
        if (Js_color[1 + u] == Js_hollow) then
            AttachMov(ply, sq, u, 0, xside)

            u = Js_nextCross[1 + (ipos + u)]
            if (Js_color[1 + u] == Js_hollow) then
                AttachMov(ply, sq, u, 0, xside)
            end
        end
        u = Js_nextArrow[1 + (idir + sq)]
        if (Js_color[1 + u] == xside) then
            AttachMov(ply, sq, u, Js_capture, xside)
        else
            if (u == Js_indenSqr) then
                AttachMov(ply, sq, u, (Js_capture | Js_enpassant_msk), xside)
            end
        end
        u = Js_nextArrow[1 + (idir + u)]
        if (Js_color[1 + u] == xside) then
            AttachMov(ply, sq, u, Js_capture, xside)
        else
            if (u == Js_indenSqr) then
                AttachMov(ply, sq, u, (Js_capture | Js_enpassant_msk), xside)
            end
        end
    else
        repeat
            if (Js_color[1 + u] == Js_hollow) then
                AttachMov(ply, sq, u, 0, xside)
                u = Js_nextCross[1 + (ipos + u)]
            else
                if (Js_color[1 + u] == xside) then
                    AttachMov(ply, sq, u, Js_capture, xside)
                end
                u = Js_nextArrow[1 + (idir + u)]
            end
        until (u == sq)
    end
end

function XRayKg(sq, s)
    local cnt = 0
    local u = 0
    local ipos = 0
    local idir = 0
    local ok = false

    if ((Js_withBishop[1 + Js_c2] ~= 0) or (Js_withQueen[1 + Js_c2] ~= 0)) then
        ipos = (Js_bishop * 4096) + (sq * 64)
        idir = ipos

        u = Js_nextCross[1 + (ipos + sq)]
        repeat
            if (((Js_agress2[1 + u] & Js_xltBQ) ~= 0) and
                    (Js_color[1 + u] ~= Js_c2)) then
                if ((Js_agress1[1 + u] == 0) or ((Js_agress2[1 + u] & 0xFF) > 1)) then
                    cnt = cnt + 1
                else
                    s.i = s.i - 3
                end
            end
            if (Js_color[1 + u] == Js_hollow) then
                u = Js_nextCross[1 + (ipos + u)]
            else
                u = Js_nextArrow[1 + (idir + u)]
            end
        until (u == sq)
    end

    if ((Js_withRook[1 + Js_c2] ~= 0) or (Js_withQueen[1 + Js_c2] ~= 0)) then
        ipos = (Js_rook * 4096) + (sq * 64)
        idir = ipos

        u = Js_nextCross[1 + (ipos + sq)]
        repeat
            if (((Js_agress2[1 + u] & Js_xltRQ) ~= 0) and
                    (Js_color[1 + u] ~= Js_c2)) then
                if ((Js_agress1[1 + u] == 0) or ((Js_agress2[1 + u] & 0xFF) > 1)) then
                    cnt = cnt + 1
                else
                    s.i = s.i - 3
                end
            end
            if (Js_color[1 + u] == Js_hollow) then
                u = Js_nextCross[1 + (ipos + u)]
            else
                u = Js_nextArrow[1 + (idir + u)]
            end
        until (u == sq)
    end

    if (Js_withKnight[1 + Js_c2] ~= 0) then
        idir = (Js_knight * 4096) + (sq * 64)

        u = Js_nextArrow[1 + (idir + sq)]
        repeat
            if (((Js_agress2[1 + u] & Js_xltNN) ~= 0) and
                    (Js_color[1 + u] ~= Js_c2)) then
                if ((Js_agress1[1 + u] == 0) or ((Js_agress2[1 + u] & 0xFF) > 1)) then
                    cnt = cnt + 1
                else
                    s.i = s.i - 3
                end
            end
            u = Js_nextArrow[1 + (idir + u)]
        until (u == sq)
    end

    s.i = s.i + (Js_safe_King * Js_menaceKing[1 + cnt] / 16)

    cnt = 0

    idir = (Js_king * 4096) + (sq * 64)

    u = Js_nextCross[1 + (idir + sq)]
    repeat
        if (Js_board[1 + u] == Js_pawn) then
            ok = true
        end

        if (Js_agress2[1 + u] > Js_agress1[1 + u]) then
            cnt = cnt + 1
            if (((Js_agress2[1 + u] & Js_xltQ) ~= 0) and
                    (Js_agress2[1 + u] > Js_xltQ + 1) and (Js_agress1[1 + u] < Js_xltQ)) then
                s.i = s.i - (4 * Js_safe_King)
            end
        end
        u = Js_nextCross[1 + (idir + u)]
    until (u == sq)

    if (not ok) then
        s.i = s.i - Js_safe_King
    end
    if (cnt > 1) then
        s.i = s.i - Js_safe_King
    end
end

function DoCastle(side, kf, kt, iop)
    local xside = Js_otherTroop[1 + side]
    local rf = 0
    local rt = 0
    local t0 = 0

    if (kt > kf) then
        rf = kf + 3
        rt = kt - 1
    else
        rf = kf - 4
        rt = kt + 1
    end

    if (iop == 0) then
        if ((kf ~= Js_kingPawn[1 + side]) or (Js_board[1 + kf] ~= Js_king) or
                (Js_board[1 + rf] ~= Js_rook) or (Js_nMvtOnBoard[1 + kf] ~= 0) or
                (Js_nMvtOnBoard[1 + rf] ~= 0) or (Js_color[1 + kt] ~= Js_hollow) or
                (Js_color[1 + rt] ~= Js_hollow) or (Js_color[1 + (kt - 1)] ~= Js_hollow) or
                (ISqAgrs(kf, xside) ~= 0) or (ISqAgrs(kt, xside) ~= 0) or (ISqAgrs(rt, xside) ~= 0)) then
            return 0
        end
    else
        if (iop == 1) then
            Js_roquer[1 + side] = 1
            Js_nMvtOnBoard[1 + kf] = Js_nMvtOnBoard[1 + kf] + 1
            Js_nMvtOnBoard[1 + rf] = Js_nMvtOnBoard[1 + rf] + 1
        else
            Js_roquer[1 + side] = 0
            Js_nMvtOnBoard[1 + kf] = Js_nMvtOnBoard[1 + kf] - 1
            Js_nMvtOnBoard[1 + rf] = Js_nMvtOnBoard[1 + rf] - 1
            t0 = kt
            kt = kf
            kf = t0
            t0 = rt
            rt = rf
            rf = t0
        end
        Js_board[1 + kt] = Js_king
        Js_color[1 + kt] = side
        Js_pieceIndex[1 + kt] = 0
        Js_board[1 + kf] = Js_empty
        Js_color[1 + kf] = Js_hollow
        Js_board[1 + rt] = Js_rook
        Js_color[1 + rt] = side
        Js_pieceIndex[1 + rt] = Js_pieceIndex[1 + rf]
        Js_board[1 + rf] = Js_empty
        Js_color[1 + rf] = Js_hollow
        Js_pieceMap[1 + side][1 + Js_pieceIndex[1 + kt]] = kt
        Js_pieceMap[1 + side][1 + Js_pieceIndex[1 + rt]] = rt
    end

    return 1
end

function DoCalc(side, ply, alpha, beta, gainScore, slk, InChk)
    local s = {i = 0}
    local xside = Js_otherTroop[1 + side]
    local evflag = false

    s.i = (-Js_scorePP[1 + (ply - 1)] + Js_matrl[1 + side] - Js_matrl[1 + xside] - gainScore)
    Js_pinned[1 + Js_black] = 0
    Js_pinned[1 + Js_white] = 0

    if (((Js_matrl[1 + Js_white] == Js_kingVal) and (((Js_pmatrl[1 + Js_black] == 0) or
                (Js_ematrl[1 + Js_black] == 0)))) or
            ((Js_matrl[1 + Js_black] == Js_kingVal) and (((Js_pmatrl[1 + Js_white] == 0) or
                (Js_ematrl[1 + Js_white] == 0))))) then
        slk.i = 1
    else
        slk.i = 0
    end

    if (slk.i == 0) then
        evflag = (ply == 1) or (ply < Js_depth_Seek) or (
            (((ply == Js_depth_Seek + 1) or (ply == Js_depth_Seek + 2))) and ((
                ((s.i > alpha - Js_dxAlphaBeta) and (s.i < beta + Js_dxAlphaBeta)) or (
                    (ply > Js_depth_Seek + 2) and (s.i >= alpha - 25) and (s.i <= beta + 25)))))
    end

    if (evflag) then
        Js_cCompNodes = Js_cCompNodes + 1
        -- if (Js_cCompNodes % 200 == 0) then
        local currTime = getTime() --.4
        if (Js_cCompNodes % 40 == 0 or currTime - Js_prevYieldTime > .5) then
        -- if (currTime - Js_prevYieldTime > .3) then
            Js_prevYieldTime = currTime
            yield()
        end
        Agression(side, Js_agress[1 + side])

        if (Anyagress(side, Js_pieceMap[1 + xside][1]) == 1) then
            return (10001 - ply)
        end

        Agression(xside, Js_agress[1 + xside])

        InChk.i = Anyagress(xside, Js_pieceMap[1 + side][1])
        PositPts(side, s)
    else
        if (ISqAgrs(Js_pieceMap[1 + xside][1], side) ~= 0) then
            return (10001 - ply)
        end
        InChk.i = ISqAgrs(Js_pieceMap[1 + side][1], xside)

        if (slk.i ~= 0) then
            CalcKg(side, s)
        end
    end
    Js_scorePP[1 + ply] = (s.i - Js_matrl[1 + side] + Js_matrl[1 + xside])
    if (InChk.i ~= 0) then
        if (Js_destSquare == -1) then
            Js_destSquare = Js_root.t
        end
        Js_flagCheck[1 + (ply - 1)] = Js_pieceIndex[1 + Js_destSquare]
    else
        Js_flagCheck[1 + (ply - 1)] = 0
    end
    return s.i
end

function Lalgb(f, t, flag)
    -- local i = 0
    -- local y = 0
    local m3p = 0

    if (f ~= t) then
        local a0 = Js_asciiMove[1]
        local a1 = Js_asciiMove[2]
        local a2 = Js_asciiMove[3]
        local a3 = Js_asciiMove[4]
        a0[1] = (97 + IColmn(f)) --(char)
        a0[2] = (49 + IRaw(f)) --(char)
        a0[3] = (97 + IColmn(t)) --(char)
        a0[4] = (49 + IRaw(t)) --(char)
        a0[5] = 0

        a3[1] = 0
        a1[1] = Js_upperNot[1 + Js_board[1 + f]]

        if (a1[1] == "P") then
            if (a0[1] == a0[3]) then
                a1[1] = a0[3]
                a2[1] = a1[1]
                a1[2] = a0[4]
                a2[2] = a1[2]
                m3p = 2
            else
                a1[1] = a0[1]
                a2[1] = a1[1]
                a1[2] = a0[3]
                a2[2] = a1[2]
                a2[3] = a0[4]
                m3p = 3
            end

            a1[3] = 0
            a2[1 + m3p] = 0
            if ((flag & Js_promote) ~= 0) then
                a1[3] = Js_lowerNot[1 + (flag & Js_pawn_msk)]
                a2[1 + m3p] = a1[3]
                a0[5] = a1[3]
                a0[6] = 0
                a2[1 + (m3p + 1)] = 0
                a1[4] = 0
            end
        else
            a2[1] = a1[1]
            a2[2] = a0[2]
            a1[2] = a0[3]
            a2[3] = a1[2]
            a1[3] = a0[4]
            a2[4] = a1[3]
            a1[4] = 0
            a2[5] = 0
            for i = 0, 5, 1 do
                a3[1 + i] = a2[1 + i]
            end

            a3[2] = a0[1]
            if ((flag & Js_castle_msk) ~= 0) then
                if (t > f) then
                    a1[1] = 111
                    a1[2] = 45
                    a1[3] = 111
                    a1[4] = 0

                    a2[1] = 111
                    a2[2] = 45
                    a2[3] = 111
                    a2[4] = 0
                else
                    a1[1] = 111
                    a1[2] = 45
                    a1[3] = 111
                    a1[4] = 45
                    a1[5] = 111
                    a1[6] = 0

                    a2[1] = 111
                    a2[2] = 45
                    a2[3] = 111
                    a2[4] = 45
                    a2[5] = 111
                    a2[6] = 0
                end
            end
        end
    else
        for i = 0, 3, 1 do
            Js_asciiMove[1 + i][1] = 0
        end
    end
end

function UpdatePiecMap(side, sq, iop)
    -- local i = 0
    if (iop == 1) then
        Js_piecesCount[1 + side] = Js_piecesCount[1 + side] - 1
        for i = Js_pieceIndex[1 + sq], Js_piecesCount[1 + side], 1 do
            Js_pieceMap[1 + side][1 + i] = Js_pieceMap[1 + side][1 + (i + 1)]
            Js_pieceIndex[1 + Js_pieceMap[1 + side][1 + i]] = i
        end
    else
        Js_piecesCount[1 + side] = Js_piecesCount[1 + side] + 1
        Js_pieceMap[1 + side][1 + Js_piecesCount[1 + side]] = sq
        Js_pieceIndex[1 + sq] = Js_piecesCount[1 + side]
    end
end

function getBoard()

    local BB = {} -- 8x8
    local iCol = 0
    local iLine = 0
    -- local i = 0
    local s = ""
    local ch = ""

    for i = 0, 7, 1 do
        BB[1 + i] = {} -- create object
    end

    for i = 0, 63, 1 do
        iCol = i % 8
        iLine = (i - iCol) / 8
        if (Js_board[1 + i] == Js_empty) then
            ch = "."
        else
            ch = iif((Js_color[1 + i] == Js_black), Js_lowerNot[1 + Js_board[1 + i]], Js_upperNot[1 + Js_board[1 + i]])
        end
        BB[1 + iLine][1 + iCol] = ch
    end
    s = ""
    for iLine = 7, 0, -1 do
        --  s = ""
        for iCol = 0, 7, 1 do
            s = s .. BB[1 + iLine][1 + iCol]
        end
        s = s .. '\n'
    end
    return s
end

function UpdateDisplay()
    local BB = {} -- 8x8
    local iCol = 0
    local iLine = 0
    -- local i = 0
    local s = ""
    local ch = ""

    for i = 0, 7, 1 do
        BB[1 + i] = {} -- create object
    end


    for i = 0, 63, 1 do
        iCol = i % 8
        iLine = (i - iCol) / 8
        if (Js_board[1 + i] == Js_empty) then
            ch = "."
        else
            ch = iif((Js_color[1 + i] == Js_black), Js_lowerNot[1 + Js_board[1 + i]], Js_upperNot[1 + Js_board[1 + i]])
        end
        BB[1 + iLine][1 + iCol] = ch
    end

    printDebug("", DEBUG)
    for iLine = 7, 0, -1 do
        s = ""
        for iCol = 0, 7, 1 do
            s = s .. BB[1 + iLine][1 + iCol]
        end
        printDebug(s, DEBUG)
    end
end

function AvailCaptur(side, ply)
    local xside = Js_otherTroop[1 + side]
    local Tpt = Js_treePoint[1 + ply]
    local Tpt1 = Tpt

    local node = Js_Tree[1 + Tpt] --_BTREE
    local inext = Tpt + 1
    local r7 = Js_raw7[1 + side]
    -- local ipl = side
    -- local i = 0

    local sq = 0
    local piece = 0
    local ipos = 0
    local idir = 0
    local u = 0
    local fl = 0

    for i = 0, Js_piecesCount[1 + side], 1 do
        sq = Js_pieceMap[1 + side][1 + i]
        piece = Js_board[1 + sq]

        if (Js_heavy[1 + piece] ~= false) then
            ipos = (piece * 4096) + (sq * 64)
            idir = ipos

            u = Js_nextCross[1 + (ipos + sq)]
            repeat
                if (Js_color[1 + u] == Js_hollow) then
                    u = Js_nextCross[1 + (ipos + u)]
                else
                    if (Js_color[1 + u] == xside) then
                        node.f = sq
                        node.t = u
                        node.replay = 0
                        node.flags = Js_capture
                        node.score = (Js_valueMap[1 + Js_board[1 + u]] + Js_scoreOnBoard[1 + Js_board[1 + u]] - piece)
                        node = Js_Tree[1 + inext]
                        inext = inext + 1
                        Tpt1 = Tpt1 + 1
                    end
                    u = Js_nextArrow[1 + (idir + u)]
                end
            until (u == sq)
        else
            idir = (Js_pieceTyp[1 + side][1 + piece] * 4096) + (sq * 64)
            if ((piece == Js_pawn) and (IRaw(sq) == r7)) then
                fl = ((Js_capture | Js_promote) | Js_queen)

                u = Js_nextArrow[1 + (idir + sq)]
                if (Js_color[1 + u] == xside) then
                    node.f = sq
                    node.t = u
                    node.replay = 0
                    node.flags = fl
                    node.score = Js_queenVal
                    node = Js_Tree[1 + inext]
                    inext = inext + 1
                    Tpt1 = Tpt1 + 1
                end

                u = Js_nextArrow[1 + (idir + u)]
                if (Js_color[1 + u] == xside) then
                    node.f = sq
                    node.t = u
                    node.replay = 0
                    node.flags = fl
                    node.score = Js_queenVal
                    node = Js_Tree[1 + inext]
                    inext = inext + 1
                    Tpt1 = Tpt1 + 1
                end

                ipos = (Js_pieceTyp[1 + side][1 + piece] * 4096) + (sq * 64)

                fl = (Js_promote | Js_queen)

                u = Js_nextCross[1 + (ipos + sq)]
                if (Js_color[1 + u] == Js_hollow) then
                    node.f = sq
                    node.t = u
                    node.replay = 0
                    node.flags = fl
                    node.score = Js_queenVal
                    node = Js_Tree[1 + inext]
                    inext = inext + 1
                    Tpt1 = Tpt1 + 1
                end
            else
                u = Js_nextArrow[1 + (idir + sq)]
                repeat
                    if (Js_color[1 + u] == xside) then
                        node.f = sq
                        node.t = u
                        node.replay = 0
                        node.flags = Js_capture
                        node.score = (Js_valueMap[1 + Js_board[1 + u]] + Js_scoreOnBoard[1 + Js_board[1 + u]] - piece)
                        node = Js_Tree[1 + inext]
                        inext = inext + 1
                        Tpt1 = Tpt1 + 1
                    end

                    u = Js_nextArrow[1 + (idir + u)]
                until (u == sq)
            end
        end
    end

    Js_treePoint[1 + (ply + 1)] = Tpt1
end

function InitStatus()
    -- local i = 0
    -- local sq = 0
    local c = 0
    local c2 = 0

    Js_indenSqr = -1

    for i = 0, 7, 1 do
        Js_pawnMap[1 + Js_white][1 + i] = 0
        Js_pawnMap[1 + Js_black][1 + i] = 0
    end

    Js_pmatrl[1 + Js_black] = 0
    Js_pmatrl[1 + Js_white] = 0
    Js_matrl[1 + Js_black] = 0
    Js_matrl[1 + Js_white] = 0
    Js_piecesCount[1 + Js_black] = 0
    Js_piecesCount[1 + Js_white] = 0

    for sq = 0, 63, 1 do
        if (Js_color[1 + sq] ~= Js_hollow) then
            c = Js_color[1 + sq]

            Js_matrl[1 + c] = Js_matrl[1 + c] + Js_valueMap[1 + Js_board[1 + sq]]
            if (Js_board[1 + sq] == Js_pawn) then
                Js_pmatrl[1 + c] = Js_pmatrl[1 + c] + Js_pawnVal
                c2 = IColmn(sq)
                Js_pawnMap[1 + c][1 + c2] = Js_pawnMap[1 + c][1 + c2] + 1
            end

            if (Js_board[1 + sq] == Js_king) then
                Js_pieceIndex[1 + sq] = 0
            else
                Js_piecesCount[1 + c] = Js_piecesCount[1 + c] + 1
                Js_pieceIndex[1 + sq] = Js_piecesCount[1 + c]
            end
            Js_pieceMap[1 + c][1 + Js_pieceIndex[1 + sq]] = sq
        end
    end
end

function MessageOut(msg, fNL)
    Js_Message = Js_Message .. msg

    -- fNL means new line
    if (fNL) then
        printDebug(Js_Message, DEBUG) -- prints buffer
        Js_Message = ""
    end
end

function Pagress(c, u)
    return (Js_agress[1 + c][1 + u] > Js_xltP)
end

function CheckMatrl()
    -- local flag = true

    local nP = 0
    local nK = 0
    local nB = 0
    local nR = 0
    local nQ = 0

    local nK1 = 0
    local nK2 = 0
    local nB1 = 0
    local nB2 = 0

    -- local i = 0

    for i = 0, 63, 1 do
        if (Js_board[1 + i] == Js_pawn) then
            nP = nP + 1
        else
            if (Js_board[1 + i] == Js_queen) then
                nQ = nQ + 1
            else
                if (Js_board[1 + i] == Js_rook) then
                    nR = nR + 1
                else
                    if (Js_board[1 + i] == Js_bishop) then
                        if (Js_color[1 + i] == Js_white) then
                            nB1 = nB1 + 1
                        else
                            nB2 = nB2 + 1
                        end
                    else
                        if (Js_board[1 + i] == Js_knight) then
                            if (Js_color[1 + i] == Js_white) then
                                nK1 = nK1 + 1
                            else
                                nK2 = nK2 + 1
                            end
                        end
                    end
                end
            end
        end
    end

    if (nP ~= 0) then
        return true
    end

    if ((nQ ~= 0) or (nR ~= 0)) then
        return true
    end

    nK = nK1 + nK2
    nB = nB1 + nB2

    if ((nK == 0) and (nB == 0)) then
        return false
    end
    if ((nK == 1) and (nB == 0)) then
        return false
    end
    return ((nK ~= 0) or (nB ~= 1))
end

function AttachMov(ply, f, t, flag, xside)
    local Tpt1 = Js_treePoint[1 + (ply + 1)]
    local node = Js_Tree[1 + Tpt1] --_BTREE

    local inext = Tpt1 + 1

    local mv = ((f << 8) | t)
    local s = 0
    local z = ((f << 6) | t)


    if (mv == Js_scoreWin0) then
        s = 2000
    else
        if (mv == Js_scoreWin1) then
            s = 60
        else
            if (mv == Js_scoreWin2) then
                s = 50
            else
                if (mv == Js_scoreWin3) then
                    s = 40
                else
                    if (mv == Js_scoreWin4) then
                        s = 30
                    end
                end
            end
        end
    end

    if (xside == Js_white) then
        z = (z | 4096)
    end

    s = s + Js_storage[1 + z]

    if (Js_color[1 + t] ~= Js_hollow) then
        if (t == Js_destSquare) then
            s = s + 500
        end
        s = s + (Js_valueMap[1 + Js_board[1 + t]] - Js_board[1 + f])
    end

    if (Js_board[1 + f] == Js_pawn) then
        if ((IRaw(t) == 0) or (IRaw(t) == 7)) then
            flag = (flag | Js_promote)

            s = s + 800

            node.f = f
            node.t = t
            node.replay = 0
            node.flags = (flag | Js_queen)
            node.score = (s - 20000)
            node = Js_Tree[1 + inext]
            inext = inext + 1
            Tpt1 = Tpt1 + 1

            s = s - 200

            node.f = f
            node.t = t
            node.replay = 0
            node.flags = (flag | Js_knight)
            node.score = (s - 20000)
            node = Js_Tree[1 + inext]
            inext = inext + 1
            Tpt1 = Tpt1 + 1

            s = s - 50

            node.f = f
            node.t = t
            node.replay = 0
            node.flags = (flag | Js_rook)
            node.score = (s - 20000)
            node = Js_Tree[1 + inext]
            inext = inext + 1
            Tpt1 = Tpt1 + 1

            flag = (flag | Js_bishop)
            s = s - 50
        else
            if ((IRaw(t) == 1) or (IRaw(t) == 6)) then
                flag = (flag | Js_menace_pawn)
                s = s + 600
            end
        end
    end

    node.f = f
    node.t = t
    node.replay = 0
    node.flags = flag
    node.score = (s - 20000)
    node = Js_Tree[1 + inext]
    inext = inext + 1
    Tpt1 = Tpt1 + 1

    Js_treePoint[1 + (ply + 1)] = Tpt1
end

function PawnPts(sq, side)
    local a1 = (Js_agress1[1 + sq] & 0x4FFF)
    local a2 = (Js_agress2[1 + sq] & 0x4FFF)
    local rank = IRaw(sq)
    local fyle = IColmn(sq)
    local s = 0
    local r = 0
    local in_square = false
    local e = 0
    -- local j = 0

    if (Js_c1 == Js_white) then
        s = Js_wPawnMvt[1 + sq]
        if (((sq == 11) and (Js_color[20] ~= Js_hollow)) or (
                (sq == 12) and (Js_color[21] ~= Js_hollow))) then
            s = s + Js_junk_pawn
        end

        if ((((fyle == 0) or (Js_pawc1[1 + (fyle - 1)] == 0))) and ((
                (fyle == 7) or (Js_pawc1[1 + (fyle + 1)] == 0)))) then
            s = s + Js_isol_pawn[1 + fyle]
        else
            if (Js_pawc1[1 + fyle] > 1) then
                s = s + Js_doubled_pawn
            end
        end

        if ((a1 < Js_xltP) and (Js_agress1[1 + (sq + 8)] < Js_xltP)) then
            s = s + Js_takeBack[1 + (a2 & 0xFF)]
            if (Js_pawc2[1 + fyle] == 0) then
                s = s + Js_bad_pawn
            end
            if (Js_color[1 + (sq + 8)] ~= Js_hollow) then
                s = s + Js_stopped_pawn
            end
        end

        if (Js_pawc2[1 + fyle] == 0) then
            r = rank + iif((side == Js_black), -1, 0)

            in_square = (IRaw(Js_pieceMap[1 + Js_black][1]) >= r) and
            (IArrow(sq, Js_pieceMap[1 + Js_black][1]) < (8 - r))

            e = iif(((a2 == 0) or (side == Js_white)), 0, 1)

            for j = sq + 8, 63, 8 do
                if (Js_agress2[1 + j] >= Js_xltP) then
                    e = 2
                    break
                end
                if ((Js_agress2[1 + j] > 0) or (Js_color[1 + j] ~= Js_hollow)) then
                    e = 1
                end
            end

            if (e == 2) then
                s = s + (Js_working * Js_pss_pawn3[1 + rank] / 10)
            else
                if ((in_square) or (e == 1)) then
                    s = s + (Js_working * Js_pss_pawn2[1 + rank] / 10)
                else
                    if (Js_ematrl[1 + Js_black] > 0) then
                        s = s + (Js_working * Js_pss_pawn1[1 + rank] / 10)
                    else
                        s = s + Js_pss_pawn0[1 + rank]
                    end
                end
            end
        end
    else
        if (Js_c1 == Js_black) then
            s = Js_bPawnMvt[1 + sq]
            if (((sq == 51) and (Js_color[44] ~= Js_hollow)) or (
                    (sq == 52) and (Js_color[45] ~= Js_hollow))) then
                s = s + Js_junk_pawn
            end

            if ((((fyle == 0) or (Js_pawc1[1 + (fyle - 1)] == 0))) and ((
                    (fyle == 7) or (Js_pawc1[1 + (fyle + 1)] == 0)))) then
                s = s + Js_isol_pawn[1 + fyle]
            else
                if (Js_pawc1[1 + fyle] > 1) then
                    s = s + Js_doubled_pawn
                end
            end


            if ((a1 < Js_xltP) and (Js_agress1[1 + (sq - 8)] < Js_xltP)) then
                s = s + Js_takeBack[1 + (a2 & 0xFF)]
                if (Js_pawc2[1 + fyle] == 0) then
                    s = s + Js_bad_pawn
                end
                if (Js_color[1 + (sq - 8)] ~= Js_hollow) then
                    s = s + Js_stopped_pawn
                end
            end

            if (Js_pawc2[1 + fyle] == 0) then
                r = rank + iif((side == Js_white), 1, 0)

                in_square = (IRaw(Js_pieceMap[1 + Js_white][1]) <= r) and
                (IArrow(sq, Js_pieceMap[1 + Js_white][1]) < (r + 1))

                e = iif(((a2 == 0) or (side == Js_black)), 0, 1)

                for j = sq - 8, 0, -8 do
                    if (Js_agress2[1 + j] >= Js_xltP) then
                        e = 2
                        break
                    end
                    if ((Js_agress2[1 + j] > 0) or (Js_color[1 + j] ~= Js_hollow)) then
                        e = 1
                    end
                end

                if (e == 2) then
                    s = s + (Js_working * Js_pss_pawn3[1 + (7 - rank)] / 10)
                else
                    if ((in_square) or (e == 1)) then
                        s = s + (Js_working * Js_pss_pawn2[1 + (7 - rank)] / 10)
                    else
                        if (Js_ematrl[1 + Js_white] > 0) then
                            s = s + (Js_working * Js_pss_pawn1[1 + (7 - rank)] / 10)
                        else
                            s = s + Js_pss_pawn0[1 + (7 - rank)]
                        end
                    end
                end
            end
        end
    end

    if (a2 > 0) then
        if ((a1 == 0) or (a2 > Js_xltP + 1)) then
            s = s + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            if (FJunk(sq)) then
                Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            end
        else
            if (a2 > a1) then
                s = s + Js_agress_across
            end
        end
    end

    return s
end

function RookPts(sq, side)
    local s = {i = 0}
    local mob = {i = 0}
    local fyle = IColmn(sq)
    local a1 = 0
    local a2 = 0

    s.i = Js_rookPlus
    XRayBR(sq, s, mob)
    s.i = s.i + Js_mobRook[1 + mob.i]

    if (Js_pawc1[1 + fyle] == 0) then
        s.i = s.i + Js_semiOpen_rook
    end
    if (Js_pawc2[1 + fyle] == 0) then
        s.i = s.i + Js_semiOpen_rookOther
    end
    if ((Js_pmatrl[1 + Js_c2] > 100) and (IRaw(sq) == Js_raw7[1 + Js_c1])) then
        s.i = s.i + 10
    end

    if (Js_working > 2) then
        s.i = s.i + (14 - Js_crossData[1 + (sq * 64 + Js_pieceMap[1 + Js_c2][1])])
    end

    a2 = (Js_agress2[1 + sq] & 0x4FFF)
    if (a2 > 0) then
        a1 = (Js_agress1[1 + sq] & 0x4FFF)
        if ((a1 == 0) or (a2 > Js_xltR + 1)) then
            s.i = s.i + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            if (FJunk(sq)) then
                Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            end
        else
            if ((a2 >= Js_xltR) or (a1 < Js_xltP)) then
                s.i = s.i + Js_agress_across
            end
        end
    end
    return s.i
end

function KingPts(sq, side)
    local s = {i = 0}
    local fyle = IColmn(sq)
    local a1 = 0
    local a2 = 0

    s.i = Js_kingMvt[1 + Js_c1][1 + sq]
    if ((Js_safe_King > 0) and ((
            (Js_fDevl[1 + Js_c2] ~= 0) or (Js_working > 0)))) then
        XRayKg(sq, s)
    end

    if (Js_roquer[1 + Js_c1] ~= 0) then
        s.i = s.i + Js_castle_K
    else
        if (Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_c1]] ~= 0) then
            s.i = s.i + Js_moveAcross_K
        end
    end

    if (Js_pawc1[1 + fyle] == 0) then
        s.i = s.i + Js_semiOpen_king
    end

    if (Js_pawc2[1 + fyle] == 0) then
        s.i = s.i + Js_semiOpen_kingOther
    end

    if (fyle == 5) then
        if (Js_pawc1[8] == 0) then
            s.i = s.i + Js_semiOpen_king
        end
        if (Js_pawc2[8] == 0) then
            s.i = s.i + Js_semiOpen_kingOther
        end
    else
        if (fyle == 6) then
            if (Js_pawc1[1 + (fyle + 1)] == 0) then
                s.i = s.i + Js_semiOpen_king
            end
            if (Js_pawc2[1 + (fyle + 1)] == 0) then
                s.i = s.i + Js_semiOpen_kingOther
            end
        else
            if (fyle == 2) then
                if (Js_pawc1[1] == 0) then
                    s.i = s.i + Js_semiOpen_king
                end
                if (Js_pawc2[1] == 0) then
                    s.i = s.i + Js_semiOpen_kingOther
                end
            else
                if (fyle == 7) then
                    if (Js_pawc1[1 + (fyle - 1)] == 0) then
                        s.i = s.i + Js_semiOpen_king
                    end
                    if (Js_pawc2[1 + (fyle - 1)] == 0) then
                        s.i = s.i + Js_semiOpen_kingOther
                    end
                end
            end
        end
    end


    a2 = (Js_agress2[1 + sq] & 0x4FFF)
    if (a2 > 0) then
        a1 = (Js_agress1[1 + sq] & 0x4FFF)
        if ((a1 == 0) or (a2 > Js_xltK + 1)) then
            s.i = s.i + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
        else
            s.i = s.i + Js_agress_across
        end
    end
    return s.i
end

function AvailMov(side, ply)
    local xside = Js_otherTroop[1 + side]
    -- local i = 0
    local square = 0
    local f = 0

    Js_treePoint[1 + (ply + 1)] = Js_treePoint[1 + ply]

    Js_scoreWin0 = iif((Js_ptValue == 0), Js_eliminate0[1 + ply], Js_ptValue)
    Js_scoreWin1 = Js_eliminate1[1 + ply]
    Js_scoreWin2 = Js_eliminate2[1 + ply]
    Js_scoreWin3 = Js_eliminate3[1 + ply]
    Js_scoreWin4 = iif((ply > 2), Js_eliminate1[1 + (ply - 2)], 0)

    for i = Js_piecesCount[1 + side], 0, -1 do
        square = Js_pieceMap[1 + side][1 + i]
        MultiMov(ply, square, side, xside)
    end

    if (Js_roquer[1 + side] ~= 0) then
        return
    end

    f = Js_pieceMap[1 + side][1]
    if (DoCastle(side, f, f + 2, 0) ~= 0) then
        AttachMov(ply, f, f + 2, Js_castle_msk, xside)
    end
    if (DoCastle(side, f, f - 2, 0) == 0) then
        return
    end
    AttachMov(ply, f, f - 2, Js_castle_msk, xside)
end

function BishopPts(sq, side)
    local s = {i = 0}
    local mob = {i = 0}
    local a1 = 0
    local a2 = 0

    s.i = Js_bishopMvt[1 + Js_c1][1 + sq]
    XRayBR(sq, s, mob)
    s.i = s.i + Js_mobBishop[1 + mob.i]

    a2 = (Js_agress2[1 + sq] & 0x4FFF)
    if (a2 > 0) then
        a1 = (Js_agress1[1 + sq] & 0x4FFF)
        if ((a1 == 0) or (a2 > Js_xltBN + 1)) then
            s.i = s.i + Js_pinned_p
            Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            if (FJunk(sq)) then
                Js_pinned[1 + Js_c1] = Js_pinned[1 + Js_c1] + 1
            end
        else
            if ((a2 >= Js_xltBN) or (a1 < Js_xltP)) then
                s.i = s.i + Js_agress_across
            end
        end
    end
    return s.i
end

function ValidateMov(side, node, tempb, tempc, tempsf, tempst, gainScore)
    local xside = Js_otherTroop[1 + side]
    local f = node.f
    local t = node.t
    local cf = 0
    local ct = 0

    Js_nGameMoves = Js_nGameMoves + 1

    Js_indenSqr = -1
    Js_origSquare = f
    Js_destSquare = t
    gainScore.i = 0
    Js_movesList[1 + Js_nGameMoves].gamMv = ((f << 8) | t)
    if ((node.flags & Js_castle_msk) ~= 0) then
        Js_movesList[1 + Js_nGameMoves].piece = Js_empty
        Js_movesList[1 + Js_nGameMoves].color = side
        DoCastle(side, f, t, 1)
    else
        cf = IColmn(f)
        ct = IColmn(t)

        tempc.i = Js_color[1 + t]
        tempb.i = Js_board[1 + t]
        tempsf.i = Js_scoreOnBoard[1 + f]
        tempst.i = Js_scoreOnBoard[1 + t]
        Js_movesList[1 + Js_nGameMoves].piece = tempb.i
        Js_movesList[1 + Js_nGameMoves].color = tempc.i
        if (tempc.i ~= Js_hollow) then
            UpdatePiecMap(tempc.i, t, 1)
            if (tempb.i == Js_pawn) then
                Js_pawnMap[1 + tempc.i][1 + ct] = Js_pawnMap[1 + tempc.i][1 + ct] - 1
            end

            if (Js_board[1 + f] == Js_pawn) then
                Js_pawnMap[1 + side][1 + cf] = Js_pawnMap[1 + side][1 + cf] - 1
                Js_pawnMap[1 + side][1 + ct] = Js_pawnMap[1 + side][1 + ct] + 1

                if (Js_pawnMap[1 + side][1 + ct] > 1 + Js_pawnMap[1 + side][1 + cf]) then
                    gainScore.i = gainScore.i - 15
                else
                    if (Js_pawnMap[1 + side][1 + ct] < 1 + Js_pawnMap[1 + side][1 + cf]) then
                        gainScore.i = gainScore.i + 15
                    else
                        if ((ct == 0) or (ct == 7) or (Js_pawnMap[1 + side][1 + (ct + ct - cf)] == 0)) then
                            gainScore.i = gainScore.i - 15
                        end
                    end
                end
            end

            Js_matrl[1 + xside] = Js_matrl[1 + xside] - Js_valueMap[1 + tempb.i]

            if (tempb.i == Js_pawn) then
                Js_pmatrl[1 + xside] = Js_pmatrl[1 + xside] - Js_pawnVal
            end

            gainScore.i = gainScore.i + tempst.i
            Js_nMvtOnBoard[1 + t] = Js_nMvtOnBoard[1 + t] + 1
        end

        Js_color[1 + t] = Js_color[1 + f]
        Js_board[1 + t] = Js_board[1 + f]
        Js_scoreOnBoard[1 + t] = Js_scoreOnBoard[1 + f]
        Js_pieceIndex[1 + t] = Js_pieceIndex[1 + f]
        Js_pieceMap[1 + side][1 + Js_pieceIndex[1 + t]] = t
        Js_color[1 + f] = Js_hollow
        Js_board[1 + f] = Js_empty
        if (Js_board[1 + t] == Js_pawn) then
            if (t - f == 16) then
                Js_indenSqr = (f + 8)
            else
                if (f - t == 16) then
                    Js_indenSqr = (f - 8)
                end
            end
        end

        if ((node.flags & Js_promote) ~= 0) then
            if (Js_proPiece ~= 0) then
                Js_board[1 + t] = Js_proPiece
            else
                Js_board[1 + t] = (node.flags & Js_pawn_msk)
            end

            if (Js_board[1 + t] == Js_queen) then
                Js_withQueen[1 + side] = Js_withQueen[1 + side] + 1
            else
                if (Js_board[1 + t] == Js_rook) then
                    Js_withRook[1 + side] = Js_withRook[1 + side] + 1
                else
                    if (Js_board[1 + t] == Js_bishop) then
                        Js_withBishop[1 + side] = Js_withBishop[1 + side] + 1
                    else
                        if (Js_board[1 + t] == Js_knight) then
                            Js_withKnight[1 + side] = Js_withKnight[1 + side] + 1
                        end
                    end
                end
            end
            -- promot might work her idk buba
            Js_pawnMap[1 + side][1 + ct] = Js_pawnMap[1 + side][1 + ct] - 1
            Js_matrl[1 + side] = Js_matrl[1 + side] + Js_valueMap[1 + Js_board[1 + t]] - Js_pawnVal
            Js_pmatrl[1 + side] = Js_pmatrl[1 + side] - Js_pawnVal

            gainScore.i = gainScore.i - tempsf.i
        end

        if ((node.flags & Js_enpassant_msk) ~= 0) then
            PrisePassant(xside, f, t, 1)
        end

        Js_nMvtOnBoard[1 + f] = Js_nMvtOnBoard[1 + f] + 1
    end
end

function Peek(p1, p2)
    local s0 = Js_Tree[1 + p1].score
    local p0 = p1
    -- local p = 0
    local s = 0

    for p = p1 + 1, p2, 1 do
        s = Js_Tree[1 + p].score
        if (s > s0) then
            s0 = s
            p0 = p
        end
    end

    if (p0 == p1) then
        return
    end

    MoveTree(Js_tmpTree, Js_Tree[1 + p1])
    MoveTree(Js_Tree[1 + p1], Js_Tree[1 + p0])
    MoveTree(Js_Tree[1 + p0], Js_tmpTree)
end

function Seek(side, ply, depth, alpha, beta, bstline, rpt)
    local tempb = {i = 0}
    local tempc = {i = 0}
    local tempsf = {i = 0}
    local tempst = {i = 0}
    local rcnt = {i = 0}

    local slk = {i = 0}
    local InChk = {i = 0}
    local nxtline = {} -- new int[1+Js_maxDepth]

    local node = {replay = 0, f = 0, t = 0, flags = 0, score = 0}
    local xside = Js_otherTroop[1 + side]
    local score3 = 0
    local d = 0
    local cf = 0
    local best = 0
    local pbst = 0
    local pnt = 0
    local j = 0
    local mv = 0

    Js_cNodes = Js_cNodes + 1

    if (ply <= Js_depth_Seek + 3) then
        rpt.i = IRepeat(rpt.i)
    else
        rpt.i = 0
    end

    if ((rpt.i == 1) and (ply > 1)) then
        if (Js_nMovesMade <= 11) then
            return 100
        end
        return 0
    end

    score3 = DoCalc(side, ply, alpha, beta, Js_gainScore.i, slk, InChk)
    if (score3 > 9000) then
        bstline[1 + ply] = 0
        return score3
    end

    if (depth > 0) then
        if (InChk.i ~= 0) then
            if (depth < 2) then
                depth = 2
            end
        else
            if ((Js_menacePawn[1 + (ply - 1)] ~= 0) or (
                    (Js_flag.recapture) and (score3 > alpha) and (score3 < beta) and
                    (ply > 2) and (Js_flagEat[1 + (ply - 1)] ~= 0) and (Js_flagEat[1 + (ply - 2)] ~= 0))) then
                depth = depth + 1
            end
        end
    else
        if ((score3 >= alpha) and ((
                (InChk.i ~= 0) or (Js_menacePawn[1 + (ply - 1)] ~= 0) or (
                    (Js_pinned[1 + side] > 1) and (ply == Js_depth_Seek + 1))))) then
            depth = depth + 1
        else
            if ((score3 <= beta) and
                    (ply < Js_depth_Seek + 4) and (ply > 4) and (Js_flagCheck[1 + (ply - 2)] ~= 0) and
                    (Js_flagCheck[1 + (ply - 4)] ~= 0) and (Js_flagCheck[1 + (ply - 2)] ~= Js_flagCheck[1 + (ply - 4)])) then
                depth = depth + 1
            end
        end
    end

    d = iif((Js_depth_Seek == 1), 7, 11)

    if ((ply > Js_depth_Seek + d) or ((depth < 1) and (score3 > beta))) then
        return score3
    end

    if (ply > 1) then
        if (depth > 0) then
            AvailMov(side, ply)
        else
            AvailCaptur(side, ply)
        end
    end

    if (Js_treePoint[1 + ply] == Js_treePoint[1 + (ply + 1)]) then
        return score3
    end

    cf = iif(((depth < 1) and (ply > Js_depth_Seek + 1) and (Js_flagCheck[1 + (ply - 2)] == 0) and (slk.i == 0)), 1, 0)

    best = iif((depth > 0), -12000, score3)

    if (best > alpha) then
        alpha = best
    end

    pbst = Js_treePoint[1 + ply]
    pnt = pbst
    while ((pnt < Js_treePoint[1 + (ply + 1)]) and (best <= beta)) do
        if (ply > 1) then
            Peek(pnt, Js_treePoint[1 + (ply + 1)] - 1)
        end

        node = Js_Tree[1 + pnt] --_BTREE

        mv = ((node.f << 8) | node.t)
        nxtline[1 + (ply + 1)] = 0

        if ((cf ~= 0) and (score3 + node.score < alpha)) then
            break
        end

        if ((node.flags & Js__idem) == 0) then
            ValidateMov(side, node, tempb, tempc, tempsf, tempst, Js_gainScore)
            Js_flagEat[1 + ply] = (node.flags & Js_capture)
            Js_menacePawn[1 + ply] = (node.flags & Js_menace_pawn)
            Js_scoreTP[1 + ply] = node.score
            Js_ptValue = node.replay

            node.score = (-Seek(xside, ply + 1, iif((depth > 0), depth - 1, 0), -beta, -alpha, nxtline, rcnt))

            if (abs(node.score) > 9000) then
                node.flags = (node.flags | Js__idem)
            else
                if (rcnt.i == 1) then
                    node.score = node.score / 2
                end
            end

            if ((rcnt.i >= 2) or (Js_nGameMoves - Js_fiftyMoves > 99) or (
                    (node.score == 9999 - ply) and (Js_flagCheck[1 + ply] == 0))) then
                node.flags = (node.flags | Js__idem)
                if (side == Js_computer) then
                    node.score = Js_specialScore
                else
                    node.score = (-Js_specialScore)
                end
            end
            node.replay = nxtline[1 + (ply + 1)]

            UnValidateMov(side, node, tempb, tempc, tempsf, tempst)
        end

        if ((node.score > best) and (not Js_flag.timeout)) then
            if ((depth > 0) and
                    (node.score > alpha) and ((node.flags & Js__idem) == 0)) then
                node.score = node.score + depth
            end
            best = node.score
            pbst = pnt
            if (best > alpha) then
                alpha = best
            end
            j = (ply + 1) + 1
            while ((#nxtline > j) and (nxtline[1 + j] > 0)) do
                bstline[1 + j] = nxtline[1 + j]
                j = j + 1
            end
            bstline[1 + j] = 0
            bstline[1 + ply] = mv
            if (ply == 1) then
                if (best > Js_root.score) then
                    MoveTree(Js_tmpTree, Js_Tree[1 + pnt])
                    for j = pnt - 1, 0, -1 do
                        MoveTree(Js_Tree[1 + (j + 1)], Js_Tree[1 + j])
                    end
                    MoveTree(Js_Tree[1], Js_tmpTree)
                    pbst = 0
                end

                -- removed to optimize performance
                if (Js_depth_Seek > 2) then
                    ShowThink(best, bstline)
                end
            end
        end

        if (Js_flag.timeout) then
            return (-Js_scoreTP[1 + (ply - 1)])
        end

        pnt = pnt + 1
    end

    node = Js_Tree[1 + pbst] --_BTREE

    mv = ((node.f << 8) | node.t)


    if (depth > 0) then
        j = ((node.f << 6) | node.t)
        if (side == Js_black) then
            j = (j | 4096)
        end

        if (Js_storage[1 + j] < 150) then
            Js_storage[1 + j] = (Js_storage[1 + j] + (depth * 2)) --(short)
        end

        if (node.t ~= (Js_movesList[1 + Js_nGameMoves].gamMv & 0xFF)) then
            if (best <= beta) then
                Js_eliminate3[1 + ply] = mv
            else
                if (mv ~= Js_eliminate1[1 + ply]) then
                    Js_eliminate2[1 + ply] = Js_eliminate1[1 + ply]
                    Js_eliminate1[1 + ply] = mv
                end
            end
        end

        Js_eliminate0[1 + ply] = iif((best > 9000), mv, 0)
    end

    -- if (os.clock() - Js_startTime > Js_searchTimeout) then
    if (getTime() > Js_searchTimeout) then
        Js_flag.timeout = true
    end

    return best
end

-- This sets active side
function SwitchSides(oposit)
    local whitemove = (Js_nGameMoves % 2 == 0)
    local whitecomp = (Js_computer == Js_white)
    if (oposit == (whitemove == whitecomp)) then
        Js_player = Js_otherTroop[1 + Js_player]
        Js_computer = Js_otherTroop[1 + Js_computer]
        Js_enemy = Js_otherTroop[1 + Js_enemy]

        Js_JESTER_TOPLAY = Js_otherTroop[1 + Js_JESTER_TOPLAY]
    end
    Js_fUserWin_kc = false
end

function GetFen()
    local fen = ""
    local piece = ""
    local i = 64 - 8
    local pt = 0

    local wKm = ((Js_roquer[1 + Js_white] > 0) or (Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_white]] > 0))
    local wLRm = (Js_nMvtOnBoard[1 + Js_queenRook[1 + Js_white]] > 0)
    local wRRm = (Js_nMvtOnBoard[1 + Js_kingRook[1 + Js_white]] > 0)

    local bKm = ((Js_roquer[1 + Js_black] > 0) or (Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_black]] > 0))
    local bLRm = (Js_nMvtOnBoard[1 + Js_queenRook[1 + Js_black]] > 0)
    local bRRm = (Js_nMvtOnBoard[1 + Js_kingRook[1 + Js_black]] > 0)
    local mv50 = Js_nGameMoves - Js_fiftyMoves
    local mvNum = (Js_nMovesMade + iif((Js_nGameMoves % 2 == 0), 1, 0))

    repeat
        piece = iif(Js_color[1 + i] == Js_white, Js_upperNot[1 + Js_board[1 + i]], Js_lowerNot[1 + Js_board[1 + i]])
        if (piece == " ") then
            pt = pt + 1
        else
            if (pt > 0) then
                fen = fen .. string.format("%d", pt)
                pt = 0
            end
            fen = fen .. piece
        end
        i = i + 1
        if (i % 8 == 0) then
            i = i - 16
        end
        if ((i >= 0) and (i % 8 == 0)) then
            if (pt > 0) then
                fen = fen .. string.format("%d", pt)
                pt = 0
            end
            fen = fen .. "/"
        end
    until (i < 0)

    if (pt > 0) then
        fen = fen .. string.format("%d", pt)
        pt = 0
    end

    fen = fen .. " " .. iif((Js_nGameMoves % 2 == 0), "w", "b") .. " "

    if ((wKm or wLRm or wRRm) and (bKm or bLRm or bRRm)) then
        fen = fen .. "-"
    else
        if ((not wKm) and (not wRRm)) then
            fen = fen .. "K"
        end
        if ((not wKm) and (not wLRm)) then
            fen = fen .. "Q"
        end
        if ((not bKm) and (not bRRm)) then
            fen = fen .. "k"
        end
        if ((not bKm) and (not bLRm)) then
            fen = fen .. "q"
        end
    end

    fen = fen .. " "

    if ((Js_root.flags & Js_enpassant_msk) ~= 0) then
        fen = fen .. Js_szAlgMvt[1 + Js_root.t - iif(Js_color[1 + Js_root.t] == Js_white, 8, -8)] .. " "
    else
        fen = fen .. "- "
    end

    if (mv50 < 0) then
        mv50 = 0
    end
    fen = fen .. string.format("%d", mv50) .. " " .. string.format("%d", mvNum)

    return fen
end

-- for Js_enemy move only
-- use SwitchSides before if oposit movement required
-- ignores checkmate status flag

function EnterMove(from_sq, to_sq, promo)
    -- local mvt = 0
    local fsq_mvt = 0
    local tsq_mvt = 0
    local i = 0
    local rgch = {} --new char[1+8]
    local iflag = 0
    local iMvt = 0

    -- added by trent
    Js_castled = false
    Js_captured = false
    Js_userInCheck = false
    Js_userMoved = false
    Js_computerMoved = false
    Js_userInvalidMove = false

    SwitchSides(true)

    -- convert string move to a 0-63 square number
    for i = 0, 63, 1 do
        if (Js_szAlgMvt[1 + i] == from_sq) then
            fsq_mvt = i
        end
        if (Js_szAlgMvt[1 + i] == to_sq) then
            tsq_mvt = i
        end
    end

    -- get promotion piece, just in case this move promotes a piece
    Js_proPiece = 0
    for i = 2, 5, 1 do
        if (Js_upperNot[1 + i] == promo) then
            Js_proPiece = i
            -- promote might work here idk
        end
    end

    Js_root.f = 0
    Js_root.t = 0
    Js_root.flags = 0

    Js_myPiece = Js_rgszPiece[1 + Js_board[1 + fsq_mvt]]

    if (Js_board[1 + fsq_mvt] == Js_pawn) then
        if ((tsq_mvt < 8) or (tsq_mvt > 55)) then
            iflag = (Js_promote | Js_proPiece)
            -- promote might work her idk
        end
        Lalgb(fsq_mvt, tsq_mvt, iflag)
    end

    rgch[1] = string.byte(from_sq, 1) --(char)
    rgch[2] = string.byte(from_sq, 2)
    rgch[3] = string.byte(to_sq, 1)  --(char)
    rgch[4] = string.byte(to_sq, 2)
    i = 4

    if (string.len(promo) > 0) then
        rgch[5] = "="
        rgch[6] = promo
        i = 6
        -- promote might work her idk
    end

    rgch[1 + i] = 0

    Js_flag.timeout = true

    iMvt = CheckMov(rgch, 0)

    if (iMvt ~= 0) then
        WatchPosit()
        -- UpdateDisplay()
        IfCheck()
        if (not CheckMatrl()) then
            Js_bDraw = 1
        end
        ShowStat()

        ShowMov(rgch)

        Js_depth_Seek = 0
        Js_userMoved = true
        return true
    end
    Js_userInvalidMove = true
    return false
end

-- ignores flags...
-- use after InitGame

function SetFen(fen)
    local fen2 = ""
    local ch = ""

    local l = string.len(fen)
    local i = 0
    local pt = 0
    local i2 = 0
    local piece = 0
    -- local j = 1

    local side = ""
    local enp = ""
    local mcnt = ""
    local mv50s = ""
    local st = 0

    for i = 0, l - 1, 1 do
        ch = string.sub(fen, i + 1, i + 1)
        pt = string.byte(ch, 1) - 48
        if (pt > 0 and pt < 8) then
            repeat
                fen2 = fen2 .. " "
                pt = pt - 1
            until (pt <= 0)
        else
            if (ch == " ") then
                break
            end
            if (ch ~= "/") then
                fen2 = fen2 .. ch
            end
        end
    end

    i = 64 - 8
    i2 = 0
    repeat
        Js_board[1 + i] = Js_empty
        Js_color[1 + i] = Js_hollow
        i2 = i2 + 1
        piece = string.sub(fen2, i2, i2)

        for j = 1, 6, 1 do
            if ((Js_upperNot[1 + j] == piece) or (Js_lowerNot[1 + j] == piece)) then
                Js_board[1 + i] = j
                Js_color[1 + i] = iif((Js_upperNot[1 + j] == piece), Js_white, Js_black)
            end
        end

        Js_nMvtOnBoard[1 + i] = 1

        i = i + 1
        if (i % 8 == 0) then
            i = i - 16
        end
    until (i < 0)

    Js_roquer[1 + Js_white] = 1
    Js_roquer[1 + Js_black] = 1

    Js_root.f = 0
    Js_root.t = 0
    Js_root.flags = 0

    for i = 0, l - 1, 1 do
        ch = string.sub(fen, i + 1, i + 1)
        if (ch == " ") then
            st = st + 1
        else
            if (st == 1) then
                side = ch
            else
                if (st == 2) then
                    if (ch == "k" or ch == "q") then
                        Js_roquer[1 + Js_black] = 0
                        Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_black]] = 0

                        if (ch == "q") then
                            Js_nMvtOnBoard[1 + Js_queenRook[1 + Js_black]] = 0
                        end
                        if (ch == "k") then
                            Js_nMvtOnBoard[1 + Js_kingRook[1 + Js_black]] = 0
                        end
                    end

                    if (ch == "K" or ch == "Q") then
                        Js_roquer[1 + Js_white] = 0
                        Js_nMvtOnBoard[1 + Js_kingPawn[1 + Js_white]] = 0

                        if (ch == "Q") then
                            Js_nMvtOnBoard[1 + Js_queenRook[1 + Js_white]] = 0
                        end
                        if (ch == "K") then
                            Js_nMvtOnBoard[1 + Js_kingRook[1 + Js_white]] = 0
                        end
                    end
                else
                    if (st == 3) then
                        enp = enp .. ch
                    else
                        if (st == 4) then
                            mv50s = mv50s .. ch
                        else
                            if (st == 5) then
                                mcnt = mcnt .. ch
                            end
                        end
                    end
                end
            end
        end
    end

    if (string.len(enp) > 0) then
        for i = 0, 63, 1 do
            if (Js_szAlgMvt[1 + i] == enp) then
                Js_root.f = iif((i < 32), i - 8, i + 8)
                Js_root.t = iif((i < 32), i + 8, i - 8)
                Js_root.flags = (Js_root.flags | Js_enpassant_msk)
            end
        end
    end

    Js_nGameMoves = (tonumber(mcnt) * 2) - iif((side == "w"), 2, 1)
    Js_nMovesMade = tonumber(mcnt) - iif((Js_nGameMoves % 2 == 0), 1, 0)
    Js_fiftyMoves = Js_nGameMoves - tonumber(mv50s)

    Js_flip = (Js_nGameMoves % 2 > 0)

    MessageOut("(FEN)", true)
    UpdateDisplay()
    InitStatus()

    ResetFlags()

    Js_flag.mate = false
    Js_flag.recapture = true

    IfCheck()
    if (not CheckMatrl()) then
        Js_bDraw = 1
    end
    ShowStat()
end

function ResetFlags()
    Js_fInGame = true
    Js_fCheck_kc = false
    Js_fMate_kc = false
    Js_fAbandon = false
    Js_bDraw = 0
    Js_fStalemate = false
    Js_fUserWin_kc = false
end

function Jst_Play()

    SwitchSides(false)

    -- added by me
    Js_userInvalidMove = false
    Js_userMoved = false
    Js_computerMoved = true
    Js_captured = false
    Js_castled = false

    Js_fEat = false

    ResetFlags()

    Js_realBestScore = -20000
    Js_realBestDepth = 0
    Js_realBestMove = 0

    ComputerMvt()
    -- UpdateDisplay()
end

function UndoMov()
    if (Js_nGameMoves > 0) then
        SwitchSides(false)

        Undo()

        -- added by me
        Js_userInvalidMove = false
        Js_userMoved = false
        Js_computerMoved = true
        Js_captured = false
        Js_castled = false
        -- UpdateDisplay()

        ResetFlags()

        ShowStat()
        MessageOut("(undo)", true)

        Js_flip = false
        if (Js_nGameMoves % 2 == 0) then
            Js_nMovesMade = Js_nMovesMade - 1
        else
            Js_flip = true
        end
    end
end

function nonZeroTableSize(t)
    if #t < 1 then return 0 end
    for i = #t, 1, -1 do
        if t[i] ~= 0 then
            return i
        end
    end
    return #t
end

function nonZeroNestedTableSize(t)
    if #t < 1 then return 0 end
    for i = #t, 1, -1 do
        for k, v in pairs(t[i]) do
            if v ~= 0 then
                return i
            end
        end
    end
    return #t
end

local function removeLastTwoMovesPgn()
    local movesFlattened = splitString(Js_pgn, " ")
    table.remove(movesFlattened)
    table.remove(movesFlattened)
    Js_pgn = ""
    for i = 1, #movesFlattened do
        Js_pgn = Js_pgn..movesFlattened[i].." "
    end
end

local function rotateBoard(boardStr)
    local board = splitString(boardStr,"\n")
    reverseItemsInRows(board)
    reverseRows(board)
    return board[1].."\n"..
           board[2].."\n"..
           board[3].."\n"..
           board[4].."\n"..
           board[5].."\n"..
           board[6].."\n"..
           board[7].."\n"..
           board[8].."\n"
end



GAME_STATE = {
    NEW_GAME = "NEW_GAME",
    USER_WON = "USER_WON",
    COMPUTER_WON = "COMPUTER_WON",
    RESIGN = "RESIGN",
    DRAW_BY_REPITITION = "DRAW_BY_REPITITION",
    DRAW = "DRAW",
    CHECK = "CHECK",
    INSUFFICIENT_MATERIAL = "INSUFFICIENT_MATERIAL",
    STALEMATE = "STALEMATE",
    USER_IN_CHECK = "USER_IN_CHECK",
    CASTLED = "CASTLED",
    PROMOTED = "PROMOTED",
    CAPTURED = "CAPTURED",
    USER_MOVED = "USER_MOVED",
    COMPUTER_MOVED = "COMPUTER_MOVED",
    NOP = "NOP",
}

class('ChessGame').extends()

function ChessGame:init()
    ChessGame.super.init(self)
    printDebug("ChessGame: initialized jester engine", DEBUG)
end

function ChessGame:newGame(isUserWhite, onProgressCallback, onDoneCallback)
    printDebug("ChessGame: newGame() search depth = " .. Js_maxDepth .. " search timeout = " .. (Js_searchTimeout) .. " seconds", DEBUG)
    playdate.resetElapsedTime()
    self.state = GAME_STATE.NEW_GAME
    self.computerThinking = false
    if self.timer then
        self.timer:remove()
        self.timer = nil
    end
    self.isUserWhite = isUserWhite
    self.computersMove = {}
    self.usersMove = {}
    self.gameLoading = true
    local newGameCoroutine = coroutine.create(function()
        InitGame()
        UpdateDisplay()
        -- onDoneCallback()
        self.gameLoading = false
        printDebug("ChessGame: newGame() took "..getTime().." seconds", DEBUG)
    end)

    self.timer = longRunningTask(newGameCoroutine, 2.3, 10, onProgressCallback, onDoneCallback)
end

function ChessGame:moveUser(from, to)
    printDebug("ChessGame: moveUser() move="..from..to, DEBUG)
    self.state = GAME_STATE.NOP
    if from == "" or to == "" then
        printDebug("ChessGame: moveUser() move empty", DEBUG)
        return false
    end

    local isValid = EnterMove(from, to, "")
    if isValid == false then
        printDebug("ChessGame: moveUser() move is invalid", DEBUG)
        self:updateState()
        return false
    end

    local oldRow, oldCol = self:squareToRowCol(Js_origSquare)
    local newRow, newCol = self:squareToRowCol(Js_destSquare)
    self.usersMove = {oldRow,
                      oldCol,
                      newRow,
                      newCol}

    self.state = GAME_STATE.USER_MOVED
    self:updateState()
    return true
end

function ChessGame:moveComputer(onProgressCallback, onDoneCallback)
    self.state = GAME_STATE.NOP
    local computersMoveCoroutine = coroutine.create(function()
        self.computerThinking = true
        printDebug("ChessGame: Jst_Play start", DEBUG)
        Jst_Play()
        printDebug("ChessGame: Jst_Play done", DEBUG)

        local oldRow, oldCol = self:squareToRowCol(Js_origSquare)
        local newRow, newCol = self:squareToRowCol(Js_destSquare)
        self.computersMove = {oldRow,
                              oldCol,
                              newRow,
                              newCol}

        printDebug("ChessGame: nodes searched= " .. Js_cCompNodes .. " time=" .. getTime().." depth="..Js_maxDepth, DEBUG)     -- to see performance
        self:updateState()
        self.computerThinking = false
    end)

    self.timer = longRunningTask(computersMoveCoroutine, Js_searchTimeout, 25, onProgressCallback, onDoneCallback)
end

function ChessGame:isGameOver()
    return
        self.state == GAME_STATE.COMPUTER_WON or
        self.state == GAME_STATE.USER_WON or
        self.state == GAME_STATE.DRAW or
        self.state == GAME_STATE.DRAW_BY_REPITITION or
        self.state == GAME_STATE.INSUFFICIENT_MATERIAL or
        self.state == GAME_STATE.STALEMATE or
        self.state == GAME_STATE.RESIGN
end

function ChessGame:updateState()
    -- ShowStat()
    printDebug("ChessGame: Js_castled = "..tostring(Js_castled).." Js_captured = "..tostring(Js_captured).." Js_userInCheck = "..tostring(Js_userInCheck).." Js_userMoved = "..tostring(Js_userMoved).." Js_computerMoved = "..tostring(Js_computerMoved).." Js_userInvalidMove = "..tostring(Js_userInvalidMove), DEBUG)

    if Js_userMoved then
        self.state = GAME_STATE.USER_MOVED
    end

    if Js_computerMoved then
        self.state = GAME_STATE.COMPUTER_MOVED
    end

    if ((Js_fMate_kc) and (not (Js_fCheck_kc))) then
        Js_fStalemate = true
    end

    if Js_captured then
        self.state = GAME_STATE.CAPTURED
    end

    if Js_castled then
        self.state = GAME_STATE.CASTLED
    end

    if Js_fCheck_kc and Js_userInvalidMove ~= true then
        self.state = GAME_STATE.CHECK
    end

    if Js_userInCheck then
        self.state = GAME_STATE.USER_IN_CHECK
    end

    if Js_fMate_kc then
        if Js_fUserWin_kc then
            self.state = GAME_STATE.USER_WON
        else
            self.state = GAME_STATE.COMPUTER_WON
        end
    end

    if Js_bDraw ~= 0 then
        self.state = GAME_STATE.DRAW
    end

    if Js_fStalemate then
        self.state = GAME_STATE.STALEMATE
    end

    if Js_fAbandon then
        self.state = GAME_STATE.RESIGN
    end

    if Js_bDraw == 3 then
        self.state = GAME_STATE.DRAW_BY_REPITITION
    else
        if (Js_bDraw == 1) then
            self.state = GAME_STATE.INSUFFICIENT_MATERIAL
        end
    end
    printDebug("ChessGame: state = " .. self.state, DEBUG)
end

function ChessGame:undoLastTwoMoves()
    if Js_nGameMoves < 2 then
        return false
    end
    UndoMov()
    UndoMov()
    removeLastTwoMovesPgn()
    self:updateState()
    if Js_nGameMoves == 0 then
        self.state = GAME_STATE.NEW_GAME
    end
    return true
end

function ChessGame:isGameLoading()
    return self.gameLoading
end

function ChessGame:isComputerThinking()
    return self.computerThinking
end

function ChessGame:setDifficulty(params)
    Js_searchTimeout = params[1]
    Js_maxDepth = params[2]
    Js_maxDepthSeek = (Js_maxDepth - 1)
    -- todo variables need to be reinitialized because they
    -- depend on maxDepth
    printDebug("ChessGame: difficulty set: timeout = " .. Js_searchTimeout .. " seconds, depth = " .. Js_maxDepth, DEBUG)
end

-- start will all the pieces then remove pieces you see
function ChessGame:getMissingPieces(board)
    local pieceCount = {
        ["p"] = 8,
        ["P"] = 8,
        ["n"] = 2,
        ["N"] = 2,
        ["b"] = 2,
        ["B"] = 2,
        ["r"] = 2,
        ["R"] = 2,
        ["q"] = 1,
        ["Q"] = 1,
        ["k"] = 1,
        ["K"] = 1,
    }

    local boardToUse = board or self:getBoard()
    local boardPieces = boardToUse:gsub("[%c%p%s]", "")
    for i = 1, boardPieces:len() do
        local piece = boardPieces:sub(i, i)
        pieceCount[piece] -= 1
    end

    return pieceCount
end

function ChessGame:getState()
    return self.state
end

function ChessGame:getBoard()
    local boardStr = getBoard()
    if self.isUserWhite then
        return boardStr
    else
        return rotateBoard(boardStr)
    end
end

function ChessGame:getPGNMoves()
    printDebug("ChessGame: getMoves() pgn: "..Js_pgn, DEBUG)
    local movesFlattened = splitString(Js_pgn, " ")
    local moves = {}
    local j = 1
    for i = 1, #movesFlattened, 2 do
        if i + 1 <= #movesFlattened then
            moves[j] = {movesFlattened[i],movesFlattened[i+1]}
        else
            moves[j] = {movesFlattened[i]}
        end
        j += 1
    end
    return reverseTable(moves)
end

function ChessGame:getComputersMove()
    return self.computersMove
end

function ChessGame:getUsersMove()
    return self.usersMove
end

-- 56,57,58,59,60,61,62,63
-- ...
-- 7,6,5,4,3,2,1,0
function ChessGame:squareToRowCol(square)
    local row = floor(8 - (square+1)/8 + 1)
    local col = square % 8 + 1
    if self.isUserWhite == false then
        row = 9 - row
        col = 9 - col
    end
    return row, col
end

function ChessGame:setUserHasFiveQueens()
    SetFen("7k/QQQQQ3/2P3K1/8/8/8/8/8 w - - 0 40")
end

function ChessGame:setUserHasMateInOne()
    SetFen("7k/4Q3/2P3K1/8/8/8/8/8 w - - 0 40")
end

function ChessGame:setComputerHasFiveQueens()
    SetFen("7K/qqqqq3/2p3k1/8/8/8/8/8 w - - 0 40")
end

function ChessGame:setComputerHasMateInOne()
    SetFen("7K/4q3/2p3k1/8/8/8/8/8 w - - 0 40")
end

function ChessGame:setUserPromotePawn()
    SetFen("7b/P7/K7/8/8/8/7k/8 w - - 0 40")
end

function ChessGame:setComputerPromotePawn()
    SetFen("7K/8/k7/8/8/8/p7/8 w - - 0 40")
end

function ChessGame:setCapturedPieceScoreChanges()
    SetFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 40")
end

function ChessGame:toSavedTable()
    if self:isComputerThinking() then
        -- user quit in the middle of computers move
        -- undo users move before saving
        self:undoLastTwoMoves()
    end

    -- only save non empty values
    local Js_movesListSize = nonZeroNestedTableSize(Js_movesList)
    local Js_movesListCopy = {}
    for i=1, Js_movesListSize, 1 do
        Js_movesListCopy[i] = Js_movesList[i]
    end

    -- only save non empty values
    local Js_TreeSize = nonZeroNestedTableSize(Js_Tree)
    local Js_TreeCopy = {}
    for i=1, Js_TreeSize, 1 do
        Js_TreeCopy[i] = Js_Tree[i]
    end

    return {
        -- start of ResetData() variables
        ["Js_movesListCopy"] = Js_movesListCopy, --compress this w/ Js_movesListCopy
        ["Js_TreeCopy"] = Js_TreeCopy, --compress this w/ Js_TreeCopy
        -- ["Js_movesList"] = Js_movesList,
        -- ["Js_Tree"] = Js_Tree,
        ["Js_treePoint"] = Js_treePoint,
        ["Js_variants"] = Js_variants,
        ["Js_flagCheck"] = Js_flagCheck,
        ["Js_flagEat"] = Js_flagEat,
        ["Js_menacePawn"] = Js_menacePawn,
        ["Js_scorePP"] = Js_scorePP,
        ["Js_scoreTP"] = Js_scoreTP,
        ["Js_eliminate0"] = Js_eliminate0,
        ["Js_eliminate1"] = Js_eliminate1,
        ["Js_eliminate3"] = Js_eliminate3,
        ["Js_pieceMap"] = Js_pieceMap,
        ["Js_pawnMap"] = Js_pawnMap,
        ["Js_nMvtOnBoard"] = Js_nMvtOnBoard,
        ["Js_scoreOnBoard"] = Js_scoreOnBoard,
        ["Js_pieceIndex"] = Js_pieceIndex,

        -- ["Js_arrowData"] = Js_arrowData, -- not going to save, let ResetData initialize
        -- ["Js_crossData"] = Js_crossData, -- not going to save, let ResetData initialize
        
        ["Js_agress"] = Js_agress,
        ["Js_wPawnMvt"] = Js_wPawnMvt,
        ["Js_bPawnMvt"] = Js_bPawnMvt,
        ["Js_knightMvt"] = Js_knightMvt,
        ["Js_bishopMvt"] = Js_bishopMvt,
        ["Js_kingMvt"] = Js_kingMvt,
        ["Js_killArea"] = Js_killArea,

        ["Js_storage"] = Js_storage, -- not going to save, let ResetData initialize
        -- ["Js_nextCross"] = Js_nextCross, -- not going to save, let ResetData initialize
        -- ["Js_nextArrow"] = Js_nextArrow, -- not going to save, let ResetData initialize

        -- done w/ ResetData() variables
        -- start of InitGame
        ["Js_flip"] = Js_flip,
        ["Js_fInGame"] = Js_fInGame,
        ["Js_fGameOver"] = Js_fGameOver,
        ["Js_fCheck_kc"] = Js_fCheck_kc,
        ["Js_fMate_kc"] = Js_fMate_kc,
        ["Js_fSoonMate_kc"] = Js_fSoonMate_kc,
        ["Js_bDraw"] = Js_bDraw,
        ["Js_fStalemate"] = Js_fStalemate,
        ["Js_fAbandon"] = Js_fAbandon,
        ["Js_fUserWin_kc"] = Js_fUserWin_kc,
        -- start of InitArrow()
        -- done w/ InitArrow()
        -- start of InitMoves()
        -- ["Js_virtualBoard"] = Js_virtualBoard, not neccessary
        -- ["Js_direction"] = Js_direction, not neccessary
        -- ["Js_maxJobs"] = Js_maxJobs, not neccessary
        -- ["Js_pawn"] = Js_pawn, not neccessary
        -- ["Js_bkPawn"] = Js_bkPawn, not neccessary
        -- ["Js_reguBoard"] = Js_reguBoard, not neccessary
        -- done w/ InitMoves()
        ["Js_working"] = Js_working,
        ["Js_working2"] = Js_working2,
        ["Js_flag"] = Js_flag,
        ["Js_cNodes"] = Js_cNodes,
        ["Js_indenSqr"] = Js_indenSqr,
        ["Js_scoreDither"] = Js_scoreDither,
        ["Js__alpha"] = Js__alpha,
        ["Js__beta"] = Js__beta,
        ["Js_dxAlphaBeta"] = Js_dxAlphaBeta,
        ["Js_maxDepthSeek"] = Js_maxDepthSeek,
        ["Js_nMovesMade"] = Js_nMovesMade,
        ["Js_specialScore"] = Js_specialScore,
        ["Js_nGameMoves"] = Js_nGameMoves,
        ["Js_fiftyMoves"] = Js_fiftyMoves,
        ["Js_hint"] = Js_hint,
        ["Js_fDevl"] = Js_fDevl,
        ["Js_roquer"] = Js_roquer,
        ["Js_board"] = Js_board,
        ["Js_color"] = Js_color,
        ["Js_computer"] = Js_computer,
        ["Js_player"] = Js_player,
        ["Js_enemy"] = Js_enemy,
        -- start of InitStatus()
        -- ["Js_black"] = Js_black, not neccessary
        -- ["Js_white"] = Js_white, not neccessary
        ["Js_pmatrl"] = Js_pmatrl,
        ["Js_matrl"] = Js_matrl,
        ["Js_piecesCount"] = Js_piecesCount,
        -- ["Js_hollow"] = Js_hollow, not neccessary
        -- end of InitStatus()
        ["Js_pgn"] = Js_pgn,
        -- end of InitGame()
        -- start of ChessGame
        ["state"] = self.state,
        ["computersMove"] = self.computersMove,
        ["usersMove"] = self.usersMove,
        -- ["computerThinking"] = self.computerThinking
        -- end of ChessGame
    }
end

function ChessGame:initFromSavedTable(data)
            -- start of ResetData() variables
        local Js_movesListCopy = data["Js_movesListCopy"] --compress this w/ Js_movesListCopy
        local Js_TreeCopy = data["Js_TreeCopy"] --compress this w/ Js_TreeCopy
        -- Js_movesList = data["Js_movesList"]
        -- Js_Tree = data["Js_Tree"]

        Js_treePoint = data["Js_treePoint"]
        Js_variants = data["Js_variants"]
        Js_flagCheck = data["Js_flagCheck"]
        Js_flagEat = data["Js_flagEat"]
        Js_menacePawn = data["Js_menacePawn"]
        Js_scorePP = data["Js_scorePP"]
        Js_scoreTP = data["Js_scoreTP"]
        Js_eliminate0 = data["Js_eliminate0"]
        Js_eliminate1 = data["Js_eliminate1"]
        Js_eliminate3 = data["Js_eliminate3"]
        Js_pieceMap = data["Js_pieceMap"]
        Js_pawnMap = data["Js_pawnMap"]
        Js_nMvtOnBoard = data["Js_nMvtOnBoard"]
        Js_scoreOnBoard = data["Js_scoreOnBoard"]
        Js_pieceIndex = data["Js_pieceIndex"]

        -- Js_arrowData = data["Js_arrowData"] -- not going to save, let ResetData initialize
        -- Js_crossData = data["Js_crossData"] -- not going to save, let ResetData initialize

        Js_agress = data["Js_agress"]
        Js_wPawnMvt = data["Js_wPawnMvt"]
        Js_bPawnMvt = data["Js_bPawnMvt"]
        Js_knightMvt = data["Js_knightMvt"]
        Js_bishopMvt = data["Js_bishopMvt"]
        Js_kingMvt = data["Js_kingMvt"]
        Js_killArea = data["Js_killArea"]

        Js_storage = data["Js_storage"] -- not going to save, let ResetData initialize
        -- Js_nextCross = data["Js_nextCross"] -- not going to save, let ResetData initialize
        -- Js_nextArrow = data["Js_nextArrow"] -- not going to save, let ResetData initialize

        -- done w/ ResetData() variables
        -- start of InitGame
        Js_flip = data["Js_flip"]
        Js_fInGame = data["Js_fInGame"]
        Js_fGameOver = data["Js_fGameOver"]
        Js_fCheck_kc = data["Js_fCheck_kc"]
        Js_fMate_kc = data["Js_fMate_kc"]
        Js_fSoonMate_kc = data["Js_fSoonMate_kc"]
        Js_bDraw = data["Js_bDraw"]
        Js_fStalemate = data["Js_fStalemate"]
        Js_fAbandon = data["Js_fAbandon"]
        Js_fUserWin_kc = data["Js_fUserWin_kc"]
        -- start of InitArrow()
        -- done w/ InitArrow()
        -- start of InitMoves()
        -- Js_virtualBoard = data["Js_virtualBoard"] not neccessary
        -- Js_direction = data["Js_direction"] not neccessary
        -- Js_maxJobs = data["Js_maxJobs"] not neccessary
        -- Js_pawn = data["Js_pawn"]
        -- Js_bkPawn = data["Js_bkPawn"] not neccessary
        -- Js_reguBoard = data["Js_reguBoard"] not neccessary
        -- done w/ InitMoves()
        Js_working = data["Js_working"]
        Js_working2 = data["Js_working2"]
        Js_flag = data["Js_flag"]
        Js_cNodes = data["Js_cNodes"]
        Js_indenSqr = data["Js_indenSqr"]
        Js_scoreDither = data["Js_scoreDither"]
        Js__alpha = data["Js__alpha"]
        Js__beta = data["Js__beta"]
        Js_dxAlphaBeta = data["Js_dxAlphaBeta"]
        Js_maxDepthSeek = data["Js_maxDepthSeek"]
        Js_nMovesMade = data["Js_nMovesMade"]
        Js_specialScore = data["Js_specialScore"]
        Js_nGameMoves = data["Js_nGameMoves"]
        Js_fiftyMoves = data["Js_fiftyMoves"]
        Js_hint = data["Js_hint"]
        Js_fDevl = data["Js_fDevl"]
        Js_roquer = data["Js_roquer"]
        Js_board = data["Js_board"]
        Js_color = data["Js_color"]
        Js_computer = data["Js_computer"]
        Js_player = data["Js_player"]
        Js_enemy = data["Js_enemy"]
        -- start of InitStatus() here
        -- Js_black = data["Js_black"], not neccessary
        -- Js_white = data["Js_white"], not neccessary
        Js_pmatrl = data["Js_pmatrl"]
        Js_matrl = data["Js_matrl"]
        Js_piecesCount = data["Js_piecesCount"]
        -- Js_hollow = data["Js_hollow"], not neccessary
        -- end of InitStatus()
        Js_pgn = data["Js_pgn"]
        -- end of InitGame()
        -- start of ChessGame
        self.state = data["state"]
        self.computersMove = data["computersMove"]
        self.usersMove = data["usersMove"]
        -- self.computerThinking = data["computerThinking"]
        -- end of ChessGame

        for i = 1, 512, 1 do
            if i <= #Js_movesListCopy then
                Js_movesList[i] = Js_movesListCopy[i]
            else
                Js_movesList[i] = {gamMv = 0, score = 0, piece = 0, color = 0}
            end
        end

        for i = 1, 2000, 1 do
            if i <= #Js_TreeCopy then
                Js_Tree[i] = Js_TreeCopy[i]
            else
                Js_Tree[i] = {replay = 0, f = 0, t = 0, flags = 0, score = 0}
            end
        end

end


-------------------------------------------
-- SAMPLES...
-------------------------------------------

-- -- moves entering
-- function autosample1()
--     EnterMove("e2", "e4", "")
--     EnterMove("c7", "c5", "")
--     EnterMove("f1", "e2", "")
--     EnterMove("c5", "c4", "")
--     EnterMove("b2", "b4", "")
--     EnterMove("c4", "b3", "")
--     EnterMove("g1", "f3", "")
--     EnterMove("b3", "b2", "")
--     EnterMove("e1", "g1", "")
--     EnterMove("b2", "a1", "R") -- promote rook
--     MessageOut("FEN:" .. GetFen(), true)
-- end

-- -- automatic game
-- function autosample2()
--     print("Thinking, autogame...")
--     while ((not Js_fGameOver) and (not Js_fAbandon) and (not Js_fMate_kc) and (not Js_fStalemate)) do
--         Jst_Play()                  -- next move
--         print("nodes " .. Js_cCompNodes) -- to see performance
--     end
--     print(Js_pgn)
-- end

-- -- undo cases
-- function autosample3()
--     EnterMove("e2", "e4", "")
--     UndoMov()
--     EnterMove("a2", "a4", "")
--     EnterMove("c7", "c5", "")
--     UndoMov()
--     Jst_Play()
--     UndoMov()
--     MessageOut(GetFen(), true)
-- end

-- -- set FEN case
-- function autosample4()
--     SetFen("7k/Q7/2P2K2/8/8/8/8/8 w - - 0 40") -- set given FEN
--     MessageOut(GetFen(), true)

--     Jst_Play()
--     MessageOut(GetFen(), true)
-- end

-- InitGame()  -- Also to start a new game again


-- UpdateDisplay()

--autosample1()

-- autosample2()
--autosample3()
--autosample4()