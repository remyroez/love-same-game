
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics
local la = love.audio

-- ブート
local Boot = Scene:newState 'boot'

-- 次のステートへ
function Boot:nextState(...)
    self:gotoState 'splash'
end

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.spriteSheet = sbss:new('assets/round_nodetailsOutline.xml')

    -- フォント
    local fontName = 'assets/Kenney Blocks.ttf'
    self.font16 = lg.newFont(fontName, 16)
    self.font32 = lg.newFont(fontName, 32)
    self.font64 = lg.newFont(fontName, 64)
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot
