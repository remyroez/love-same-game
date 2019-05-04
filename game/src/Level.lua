
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
function Level:initialize(spriteSheet)
    -- スプライトシート
    self.spriteSheet = spriteSheet

    -- 駒
    self.pieces = {}

    -- デバッグモード
    self.debugMode = false
end

-- 読み込み
function Level:load(numHorizontal, numVertical)
    numHorizontal = numHorizontal or 20
    numVertical = numVertical or 10

    -- 駒のリセット
    self.pieces = {}

    -- 駒のランダム配置
    for i = 1, numHorizontal do
        local line = {}
        for j = 1, numVertical do
            local pieceType = pieceTypes[love.math.random(#pieceTypes)]
            table.insert(
                line,
                Piece {
                    x = i * 32,
                    y = j * 32,
                    width = 32,
                    height = 32,
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
    -- 駒の描画
    for i, line in ipairs(self.pieces) do
        for j, piece in ipairs(line) do
            piece:draw()
        end
    end
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

return Level
