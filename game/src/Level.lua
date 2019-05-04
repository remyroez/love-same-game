
local class = require 'middleclass'

-- レベル
local Level = class 'Level'

-- 初期化
function Level:initialize(spriteSheet)
    self.spriteSheet = spriteSheet
    self.debugMode = false
end

-- 読み込み
function Level:load()
end

-- 破棄
function Level:destroy()
end

-- 更新
function Level:update(dt)
end

-- 描画
function Level:draw()
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
