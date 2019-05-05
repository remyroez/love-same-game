
local class = require 'middleclass'

-- クラス
local Piece = require 'Piece'
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- レベル
local Level = class 'Level'

-- 連結
local function concat(...)
    local result = {}
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t ~= nil then
            local iter = t[1] ~= nil and ipairs or pairs
            for _, v in iter(t) do
                result[#result + 1] = v
            end
        end
    end
    return result
end

-- 初期化
function Level:initialize(spriteSheet, x, y, width, height)
    -- 座標
    self.x = x or 0
    self.y = y or 0

    -- レベルのサイズ
    local w, h = lg.getDimensions()
    self.width = width or w
    self.height = height or h

    -- スプライトシート
    self.spriteSheet = spriteSheet

    -- 駒情報
    self.pieceTypes = nil
    self.pieces = {}
    self.lastEnviroments = {}
    self.numHorizontal = 20
    self.numVertical = 10
    self.pieceWidth = 0
    self.pieceHeight = 0
    self.score = 0
    self.lastScores = {}
    self.counts = {}
    self.offsetX = 0
    self.offsetY = 0

    -- タイマー
    self.timer = Timer()
    self.busy = false

    -- デバッグモード
    self.debugMode = false
end

-- 読み込み
function Level:load(numHorizontal, numVertical, pieceTypes)
    self.timer:destroy()

    -- 駒の数
    self.numHorizontal = math.max(numHorizontal or self.numHorizontal or 20, 1)
    self.numVertical = math.max(numVertical or self.numVertical or 10, 1)

    -- 駒のサイズ
    do
        local pw = math.ceil(self.width / self.numHorizontal)
        local ph = math.ceil(self.height / self.numVertical)
        if pw < ph then
            ph = pw
        elseif ph < pw then
            pw = ph
        end
        self.pieceWidth = pw
        self.pieceHeight = ph
    end

    -- 駒のリセット
    self.pieceTypes = self.pieceTypes or pieceTypes or {}
    self.pieces = {}
    self.vanishingPieces = {}
    self.lastEnviroments = {}
    self.score = 0
    self.lastScores = {}

    -- 駒タイプが空なら終了
    if #self.pieceTypes == 0 then
        return
    end

    -- 駒のランダム配置
    for i = 1, self.numHorizontal do
        local line = {}
        for j = 1, self.numVertical do
            local pieceType = self.pieceTypes[love.math.random(#self.pieceTypes)]
            table.insert(
                line,
                Piece {
                    x = (i - 1) * self.pieceWidth,
                    y = (self.numVertical - j) * self.pieceHeight,
                    width = self.pieceWidth,
                    height = self.pieceHeight,
                    type = pieceType.name,
                    spriteSheet = self.spriteSheet,
                    spriteName = pieceType.spriteName,
                }
            )
        end
        table.insert(self.pieces, line)
    end

    -- オフセット値
    if #self.pieces > 0 and #self.pieces[1] > 0 then
        local p = self.pieces[1][1]
        self.offsetX, self.offsetY = p.pivotX * p.scaleX, p.pivotY * p.scaleY
    end

    -- 駒のタイプのカウント
    self:countPieceTypes()
end

-- 破棄
function Level:destroy()
    self.timer:destroy()
end

-- 更新
function Level:update(dt)
    self.timer:update(dt)
end

-- 描画
function Level:draw()
    lg.push()
    lg.translate(self.x + self.offsetX, self.y + self.offsetY)

    -- 駒の描画
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            piece:draw()
        end
    end

    -- 消える駒の描画
    for _, piece in ipairs(self.vanishingPieces) do
        piece:draw()
    end

    lg.pop()
end

-- キー入力
function Level:keypressed(key, scancode, isrepeat)
    if self.busy then
        -- 動作中
    elseif key == 'backspace' then
        -- アンドゥ
        self:undo()
    elseif key == 'home' then
        -- 最初に戻す
        self:undoAll()
    elseif key == 'end' then
        -- リセット
        self:load()
    end
end

-- マウス入力
function Level:mousepressed(x, y, button, istouch, presses)
    if self.busy then
        -- 動作中
    elseif button == 1 then
        -- 駒を除外
        local px = math.ceil((x - self.x) / self.pieceWidth)
        local py = self.numVertical - math.ceil((y - self.y) / self.pieceHeight) + 1
        self:removeSamePieces(px, py)
    elseif button == 2 then
        -- アンドゥ
        self:undo()
    end
end

-- デバッグモードの設定
function Level:setDebugMode(mode)
    self.debugMode = mode or false
end

-- 合計幅
function Level:totalWidth()
    return self.pieceWidth * self.numHorizontal
end

-- 合計高さ
function Level:totalHeight()
    return self.pieceHeight * self.numVertical
end

-- 合計サイズ
function Level:totalSize()
    return self:totalWidth(), self:totalHeight()
end

-- 駒の取得
function Level:getPiece(x, y, type)
    local piece
    if x <= 0 or x > #self.pieces then
        -- 範囲外
    elseif y <= 0 then
        -- 範囲外
    else
        local line = self.pieces[x]
        if line == nil then
            -- 範囲外
        elseif y > #line then
            -- 範囲外
        elseif type and line[y].type ~= type then
            -- タイプ不一致
        else
            piece = line[y]
        end
    end
    return piece
end

-- 駒を取り除く
function Level:removePiece(x, y)
    local piece
    if x <= 0 or x > #self.pieces then
        -- 範囲外
    elseif y <= 0 then
        -- 範囲外
    else
        local line = self.pieces[x]
        if line == nil then
            -- 範囲外
        elseif y > #line then
            -- 範囲外
        else
            piece = table.remove(line, y)
        end
        if #line == 0 then
            table.remove(self.pieces, x)
        end
    end
    return piece
end

-- 駒のチェックを外す
function Level:uncheckPieces()
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            piece.checked = false
        end
    end
end

-- 同じタイプの駒の取得
function Level:pickSamePieceCoords(x, y, type, dirX, dirY)
    local coords = {}
    local piece = self:getPiece(x, y, type)
    if piece == nil then
        -- 範囲外
    elseif piece.checked then
        -- チェック済み
    else
        -- 駒のチェック
        piece.checked = true

        -- この駒の座標を登録
        table.insert(coords, { x, y })

        -- 上下左右に探索
        if dirX ~= (x - 1) then
            coords = concat(coords, self:pickSamePieceCoords(x - 1, y, piece.type, x, y))
        end
        if dirX ~= (x + 1) then
            coords = concat(coords, self:pickSamePieceCoords(x + 1, y, piece.type, x, y))
        end
        if dirY ~= (y - 1) then
            coords = concat(coords, self:pickSamePieceCoords(x, y - 1, piece.type, x, y))
        end
        if dirY ~= (y + 1) then
            coords = concat(coords, self:pickSamePieceCoords(x, y + 1, piece.type, x, y))
        end
    end
    return coords
end

-- 同じタイプの駒の除外
function Level:removeSamePieces(x, y, save)
    save = save == nil and true or save

    -- 同じタイプの駒を探す
    local coords = self:pickSamePieceCoords(x, y)

    -- チェックを外す
    self:uncheckPieces()

    -- １つ以上なら処理する
    if #coords > 1 then
        -- 直前の状態を保存
        if save then
            local clonePieces = {}
            for i, line in ipairs(self.pieces) do
                local cloneLine = {}
                for j, piece in ipairs(line) do
                    cloneLine[j] = piece
                end
                clonePieces[i] = cloneLine
            end
            table.insert(self.lastEnviroments, clonePieces)
        end

        -- 一番遠いところから消すためにソート
        table.sort(
            coords,
            function (a, b)
                if a[1] ~= b[1] then
                    return a[1] > b[1]
                else
                    return a[2] > b[2]
                end
            end
        )

        -- タイプのカウントを減らす
        local piece = self:getPiece(x, y)
        if piece then
            self.counts[piece.type] = self.counts[piece.type] - #coords
        end

        -- 駒の除外
        for _, coord in ipairs(coords) do
            self:tweenPieceVanish(self:removePiece(unpack(coord)), 0.5)
        end
        self.timer:after(
            0.25,
            function ()
                self:tweenPiecePosition(0.5)
            end
        )

        -- スコア獲得
        self:scorePieces(#coords)

        -- 駒のタイプのカウント
        self:countPieceTypes()
    end
end

-- スコア獲得
function Level:scorePieces(num)
    table.insert(self.lastScores, self.score)
    self.score = self.score + math.pow(num - 2, 2)
end

-- 直前の状態に戻す
function Level:undo()
    if #self.lastEnviroments == 0 then
        -- 初手
    elseif #self.lastScores == 0 then
        -- 初手
    else
        self.pieces = table.remove(self.lastEnviroments)
        self.score = table.remove(self.lastScores)
        self:tweenPiecePosition(0.5)

        -- 駒のタイプのカウント
        self:countPieceTypes()
    end
end

-- 最初の状態に戻す
function Level:undoAll()
    if #self.lastEnviroments == 0 then
        -- 初手
    elseif #self.lastScores == 0 then
        -- 初手
    else
        self.pieces = self.lastEnviroments[1]
        self.lastEnviroments = {}
        self.score = 0
        self.lastScores = {}
        self:tweenPiecePosition(0.5)

        -- 駒のタイプのカウント
        self:countPieceTypes()
    end
end

-- 駒のタイプをカウントする
function Level:countPieceTypes()
    self.counts = {}
    for i, pieceType in ipairs(self.pieceTypes) do
        self.counts[pieceType.name] = 0
    end
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            self.counts[piece.type] = self.counts[piece.type] + 1
        end
    end
end

-- 駒の位置を移動させる
function Level:tweenPiecePosition(delay)
    delay = delay or 0

    -- 各駒へ座標設定
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            local x = (i - 1) * self.pieceWidth
            local y = (self.numVertical - j) * self.pieceHeight
            if delay == 0 then
                -- 時間が未指定なら一瞬で戻す
                piece.x, piece.y = x, y
            else
                -- Ｘ方向
                if piece.x ~= x then
                    self:tween(
                        delay,
                        piece,
                        { x = x },
                        'in-out-cubic',
                        piece.uuid .. '_x'
                    )
                end
                -- Ｙ方向
                if piece.y ~= y then
                    self:tween(
                        delay,
                        piece,
                        { y = y },
                        (y > piece.y) and 'in-bounce' or 'out-back',
                        piece.uuid .. '_y'
                    )
                end
                -- アルファ値
                if piece.color[4] < 1 then
                    self:tween(
                        delay,
                        piece.color,
                        { [4] = 1 },
                        'out-elastic',
                        piece.uuid .. '_color'
                    )
                end
                -- スケール
                if piece.scaleX < piece.baseScaleX or piece.scaleY < piece.baseScaleY then
                    self:tween(
                        delay,
                        piece,
                        { scaleX = piece.baseScaleX, scaleY = piece.baseScaleY },
                        'out-elastic',
                        piece.uuid .. '_scale'
                    )
                end
            end
        end
    end

    -- 時間経過まで操作できないようにする
    if delay > 0 then
        --self.busy = true
        self.timer:after(
            delay,
            function ()
                self.busy = false
            end
        )
    end
end

-- 駒が消える演出
function Level:tweenPieceVanish(piece, delay)
    delay = delay or 0

    if piece and delay > 0 then
        -- 消える駒に入れる
        table.insert(self.vanishingPieces, piece)

        -- スケール
        self:tween(
            delay,
            piece,
            { scaleX = 0, scaleY = 0, rotation = math.pi * 2 },
            'in-back',
            function ()
                piece.rotation = 0
            end,
            piece.uuid .. '_scale'
        )

        -- アルファ値
        self:tween(
            delay,
            piece.color,
            { [4] = 0 },
            'in-back',
            function ()
                for i, vp in ipairs(self.vanishingPieces) do
                    if vp == piece then
                        table.remove(self.vanishingPieces, i)
                        break
                    end
                end
            end,
            piece.uuid .. '_color'
        )
    end
end

-- 駒が消える演出
function Level:tween(...)
    self.timer:tween(...)
end

return Level
