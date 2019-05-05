
-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Level = require 'Level'

-- ゲーム
local Game = Scene:newState 'game'

-- 駒のタイプ
local pieceTypes = {
    { name = 'rabbit', spriteName = 'rabbit.png' },
    { name = 'duck', spriteName = 'duck.png' },
    { name = 'pig', spriteName = 'pig.png' },
    { name = 'monkey', spriteName = 'monkey.png' },
    { name = 'giraffe', spriteName = 'giraffe.png' },
}

-- 読み込み
function Game:load()
end

-- ステート開始
function Game:enteredState(path, ...)
    -- 親
    Scene.enteredState(self, ...)

    -- プライベート
    local state = self.state

    -- レベル
    state.level = Level(self.spriteSheet)
    state.level:load(20, 10, pieceTypes)
    state.level.y = (self.height - state.level:totalHeight()) * 0.5
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
    self.state.level:draw()

    lg.setColor(1, 1, 1, 1)
    lg.printf(self.state.level.score, 0, 0, self.width, 'center')

    local size = 32
    local range = 100
    lg.push()
    lg.translate((self.width - (#pieceTypes - 1) * range) * 0.5 - size, self.height - size - 8)
    for i, pieceType in ipairs(pieceTypes) do
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

-- マウス入力
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
