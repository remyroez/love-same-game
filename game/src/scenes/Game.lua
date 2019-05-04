
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

    lg.printf('SCORE: ' .. self.state.level.score, 0, 0, self.width, 'left')
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

return Game
