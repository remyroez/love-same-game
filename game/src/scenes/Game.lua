
-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Level = require 'Level'

-- ゲーム
local Game = Scene:newState 'game'

-- 読み込み
function Game:load()
end

-- ステート開始
function Game:enteredState(width, height, pieceTypes, ...)
    -- 親
    Scene.enteredState(self, ...)

    -- プライベート
    local state = self.state

    -- レベル
    state.pieceTypes = pieceTypes or {}
    state.level = Level(self.spriteSheet, 0, 0, nil, self.height - (32 + 32 + 8 * 2))
    state.level:load(width, height, state.pieceTypes)
    state.level.x = (state.level.width - state.level:totalWidth()) * 0.5
    state.level.y = (state.level.height - state.level:totalHeight()) * 0.5 + 32
end

-- ステート終了
function Game:exitedState(...)
    self.state.level:destroy()
end

-- 更新
function Game:update(dt)
    self.state.level:update(dt)
end

-- 描画
function Game:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    -- レベル描画
    self.state.level:draw()

    -- タイトル
    lg.setColor(1, 1, 1, 1)
    lg.printf(self.state.level.title, 0, 0, self.width, 'left')

    -- 得点
    lg.setColor(1, 1, 1, 1)
    lg.printf(self.state.level.score, 0, 0, self.width, 'center')

    -- 駒の種類別の残数
    local size = 32
    local range = 100
    lg.push()
    lg.translate((self.width - (#self.state.pieceTypes - 1) * range) * 0.5 - size, self.height - size - 8)
    for i, pieceType in ipairs(self.state.pieceTypes) do
        local x = (i - 1) * range
        self:drawPieceSprite(pieceType.spriteName, x, 0, size)
        lg.printf(self.state.level.counts[pieceType.name], x + size + 8, (size - 12) * 0.5, self.width, 'left')
    end
    lg.pop()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    self.state.level:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.state.level:mousepressed(x, y, button, istouch, presses)
end

-- デバッグモードの設定
function Game:setDebugMode(mode)
    -- シーン
    Scene.setDebugMode(self, mode)

    -- レベル
    self.state.level:setDebugMode(mode)
end

-- 駒スプライトの描画
function Game:drawPieceSprite(spriteName, x, y, w, h)
    -- スプライトのサイズ
    local _, __, sw, sh = self.spriteSheet.quad[spriteName]:getViewport()
    if w ~= nil then
        h = w
    end
    w = w or sw
    h = h or sh

    lg.push()
    lg.translate(x, y)
    lg.scale(w / sw, h / sh)
    self.spriteSheet:draw(spriteName, 0, 0)
    lg.pop()
end

return Game
