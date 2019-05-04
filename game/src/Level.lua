
local class = require 'middleclass'

-- クラス
local Piece = require 'Piece'

-- エイリアス
local lg = love.graphics

-- レベル
local Level = class 'Level'

-- 駒のタイプ
local pieceTypes = {
    { name = 'rabbit', spriteName = 'rabbit.png' },
    { name = 'duck', spriteName = 'duck.png' },
    { name = 'pig', spriteName = 'pig.png' },
    { name = 'monkey', spriteName = 'monkey.png' },
    { name = 'giraffe', spriteName = 'giraffe.png' },
}

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
    self.pieces = {}
    self.numHorizontal = 0
    self.numVertical = 0
    self.pieceWidth = 0
    self.pieceHeight = 0

    -- デバッグモード
    self.debugMode = false
end

-- 読み込み
function Level:load(numHorizontal, numVertical)
    -- 駒の数
    self.numHorizontal = math.max(numHorizontal or 20, 1)
    self.numVertical = math.max(numVertical or 10, 1)

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
    self.pieces = {}

    -- 駒のランダム配置
    for i = 1, self.numHorizontal do
        local line = {}
        for j = 1, self.numVertical do
            local pieceType = pieceTypes[love.math.random(#pieceTypes)]
            table.insert(
                line,
                Piece {
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
end

-- 破棄
function Level:destroy()
end

-- 更新
function Level:update(dt)
end

-- 描画
function Level:draw()
    lg.push()
    lg.translate(self.x, self.y)

    -- 駒の描画
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            piece.x = (i - 1) * self.pieceWidth
            piece.y = (self.numVertical - j) * self.pieceHeight
            piece:draw()
        end
    end

    lg.pop()
end

-- キー入力
function Level:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Level:mousepressed(x, y, button, istouch, presses)
    local px = math.ceil((x - self.x) / self.pieceWidth)
    local py = self.numVertical - math.ceil((y - self.y) / self.pieceHeight) + 1
    print('----------')
    self:removeSamePieces(px, py)
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
            table.remove(line, y)
        end
        if #line == 0 then
            table.remove(self.pieces, x)
        end
    end
end

-- 同じタイプの駒の取得
function Level:pickSamePieceCoords(x, y, type, dirX, dirY)
    --print('pickSamePieceCoords', x, y, type, dirX, dirY)
    local coords = {}
    local piece = self:getPiece(x, y, type)
    if piece == nil then
        -- 範囲外
    else
        table.insert(coords, { x, y })
        if dirX ~= 'left' then
            coords = concat(coords, self:pickSamePieceCoords(x - 1, y, piece.type, 'right', dirY))
        end
        if dirX ~= 'right' then
            coords = concat(coords, self:pickSamePieceCoords(x + 1, y, piece.type, 'left', dirY))
        end
        if dirY ~= 'up' then
            coords = concat(coords, self:pickSamePieceCoords(x, y - 1, piece.type, dirX, 'down'))
        end
        if dirY ~= 'down' then
            coords = concat(coords, self:pickSamePieceCoords(x, y + 1, piece.type, dirX, 'up'))
        end
    end
    return coords
end

-- 同じタイプの駒の除外
function Level:removeSamePieces(x, y)
    local coords = self:pickSamePieceCoords(x, y)
    if #coords > 1 then
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
        print('----------')
        for _, coord in ipairs(coords) do
            print(unpack(coord))
            self:removePiece(unpack(coord))
        end
    end
end

return Level
