
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics

-- クラス
local Piece = require 'Piece'
local Timer = require 'Timer'

-- タイトル
local Title = Scene:newState 'title'

-- 駒のタイプ
local spriteNames = {
    'rabbit.png',
    'duck.png',
    'pig.png',
    'monkey.png',
    'giraffe.png',
}

-- 次のステートへ
function Title:nextState(...)
    self:gotoState 'game'
end

-- 読み込み
function Title:load()
end

-- ステート開始
function Title:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    local state = self.state

    -- スプライトの配置
    state.w, state.h = self:getSpriteSize('rabbit.png')
    state.numX, state.numY = 7, 6
    state.sprites = {}
    for i = 1, state.numX do
        local line = {}
        for j = 1, state.numY do
            table.insert(line, spriteNames[love.math.random(#spriteNames)])
        end
        table.insert(state.sprites, line)
    end

    -- 開始演出
    state.alpha = 1
    state.timer = Timer()
    state.timer:tween(
        1,
        state,
        { alpha = 0 },
        'in-out-cubic',
        function()
            state.busy = false
        end
    )
    state.busy = true
end

-- ステート終了
function Title:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Title:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Title:draw()
    local state = self.state

    -- クリア
    lg.clear(.42, .75, .89)

    -- 駒の描画
    lg.setColor(1, 1, 1, 0.5)
    lg.push()
    lg.translate((self.width - state.w * state.numX) * 0.5, (self.height - state.h * state.numY) * 0.5)
    for i, line in ipairs(state.sprites) do
        for j, spriteName in ipairs(line) do
            self:drawPieceSprite(spriteName, (i - 1) * state.w, (j - 1) * state.h, state.w, state.h)
        end
    end
    lg.pop()

    -- フェード
    if state.alpha > 0 then
        lg.setColor(.42, .75, .89, state.alpha)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    if not self.state.busy then
        self.state.timer:tween(
            1,
            self.state,
            { alpha = 1 },
            'in-out-cubic',
            function()
                self:nextState()
            end
        )
        self.state.busy = true
    end
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    self:keypressed('space')
end

-- 駒スプライトのサイズ
function Title:getSpriteSize(spriteName)
    local _, __, sw, sh = self.spriteSheet.quad[spriteName]:getViewport()
    return sw, sh
end

-- 駒スプライトの描画
function Title:drawPieceSprite(spriteName, x, y, w, h)
    -- スプライトのサイズ
    local sw, sh = self:getSpriteSize(spriteName)
    if w ~= nil then
        h = w
    end
    w = w or sw
    h = h or sh

    -- スプライト描画
    lg.push()
    lg.translate(x, y)
    lg.scale(w / sw, h / sh)
    self.spriteSheet:draw(spriteName, 0, 0)
    lg.pop()
end

return Title
