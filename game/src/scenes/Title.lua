
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
    self:gotoState 'select'
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
    state.offsets = {}
    local tweenOffsets = {}
    for i = 1, state.numX do
        local line = {}
        for j = 1, state.numY do
            table.insert(line, spriteNames[love.math.random(#spriteNames)])
        end
        table.insert(state.sprites, line)
        table.insert(state.offsets, love.math.randomNormal() * (-self.height * 0.5) + -self.height * 0.5)
        table.insert(tweenOffsets, 0)
    end

    -- 開始演出
    state.offset = -self.height * 0.5
    state.alpha = 1
    state.timer = Timer()
    state.timer:tween(
        1,
        state,
        { alpha = 0 },
        'in-out-cubic',
        function()
            state.timer:every(
                0.5,
                function ()
                    state.visiblePressAnyKey = not state.visiblePressAnyKey
                end
            )
            state.busy = false
        end
    )
    state.timer:tween(
        1,
        state,
        { offset = 0, offsets = tweenOffsets },
        'in-bounce'
    )
    state.busy = true
    state.visiblePressAnyKey = true

    -- ＢＧＭ
    self.musics.outgame:play()
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
            self:drawPieceSprite(spriteName, (i - 1) * state.w, (j - 1) * state.h + state.offsets[i], state.w, state.h)
        end
    end
    lg.pop()

    -- タイトル
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        'SAME GAME',
        self.font64,
        0,
        self.height * 0.3 - self.font64:getHeight() * 0.5 + state.offset,
        self.width,
        'center'
    )

    -- キー入力表示
    if state.visiblePressAnyKey and not state.busy then
        lg.printf('PRESS ANY KEY', self.font32, 0, self.height * 0.75 - self.font32:getHeight() * 0.5, self.width, 'center')
    end

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

        -- ＳＥ
        self.sounds.start:seek(0)
        self.sounds.start:play()
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
