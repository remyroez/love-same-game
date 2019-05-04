
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
function Game:enteredState(path, ...)
    -- 親
    Scene.enteredState(self, ...)

    -- プライベート
    local state = self.state

    -- レベル
    state.level = Level(self.spriteSheet)
    state.level:load()
end

-- ステート終了
function Game:exitedState(...)
    self.state.level:destroy()
end

-- 更新
function Game:update(dt)
end

-- 描画
function Game:draw()
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end

-- デバッグモードの設定
function Game:setDebugMode(mode)
    -- シーン
    Scene.setDebugMode(self, mode)

    -- レベル
    self.state.level:setDebugMode(mode)
end

return Game
