
local class = require 'middleclass'

-- クラス
local Piece = require 'Piece'

-- エイリアス
local lg = love.graphics

-- レベル
local Level = class 'Level'

local pieceTypes = {
    { name = 'rabbit', spriteName = 'rabbit.png' },
    { name = 'duck', spriteName = 'duck.png' },
    { name = 'pig', spriteName = 'pig.png' },
    { name = 'monkey', spriteName = 'monkey.png' },
    { name = 'giraffe', spriteName = 'giraffe.png' },
}

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
    self.numHorizontal = numHorizontal or 20
    self.numVertical = numVertical or 10

    -- 駒のサイズ
    local pw = math.ceil(self.width / self.numHorizontal)
    local ph = math.ceil(self.height / self.numVertical)
    if pw < ph then
        ph = pw
    elseif ph < pw then
        pw = ph
    end
    self.pieceWidth = pw
    self.pieceHeight = ph

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
                    x = (i - 1) * pw,
                    y = (j - 1) * ph,
                    width = pw,
                    height = ph,
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

return Level
