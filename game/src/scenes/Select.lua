
local Scene = require 'Scene'

-- エイリアス
local lg = love.graphics

-- クラス
local Timer = require 'Timer'

-- レベル選択
local Select = Scene:newState 'select'

-- 駒のタイプ
local pieceTypes = {
    { name = 'rabbit', spriteName = 'rabbit.png' },
    { name = 'duck', spriteName = 'duck.png' },
    { name = 'pig', spriteName = 'pig.png' },
    { name = 'monkey', spriteName = 'monkey.png' },
    { name = 'giraffe', spriteName = 'giraffe.png' },
}

-- 次のステートへ
function Select:nextState(...)
    self:gotoState('game', ...)
end

-- 読み込み
function Select:load()
end

-- ステート開始
function Select:enteredState(width, height, pieceTypes, ...)
    -- 親
    Scene.enteredState(self, ...)

    local state = self.state

    -- スプライトの配置
    state.w, state.h = self:getSpriteSize('rabbit.png')
    state.w, state.h = state.w * 0.5, state.h * 0.5
    state.sprites = {}

    -- 開始演出
    state.offset = -self.height * 0.5
    state.offsetX = 0
    state.offsetY = 0
    state.offsetT = 0
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
    state.timer:tween(
        1,
        state,
        { offset = 0 },
        'in-bounce'
    )
    state.busy = true

    -- レベル設定
    state.levelWidth = width or 20
    state.levelHeight = height or 10
    state.levelTypes = pieceTypes or {}
    if pieceTypes == nil then
        self:randomTypes(5)
    end

    -- ＢＧＭ
    self.musics.outgame:play()
end

-- ステート終了
function Select:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Select:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Select:draw()
    local state = self.state

    -- クリア
    lg.clear(.42, .75, .89)

    -- レベル選択
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        'SELECT LEVEL',
        self.font32,
        0,
        self.height * 0.2 - self.font32:getHeight() * 0.5 + state.offset,
        self.width,
        'center'
    )

    -- タイプ
    local range = state.w * 1.5
    for i, pieceType in ipairs(state.levelTypes) do
        self:drawPieceSprite(
            pieceType.spriteName,
            (self.width - range * (#state.levelTypes - 1) - state.w) * 0.5 + range * (i - 1),
            self.height * 0.75 - state.h * 0.5 + state.offsetT,
            state.w,
            state.h
        )
    end
    lg.printf(
        '3/4/5',
        self.font16,
        0,
        self.height * 0.85 - self.font16:getHeight() * 0.5,
        self.width,
        'center'
    )

    -- レベルの横の数
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        state.levelWidth,
        self.font64,
        -32 + state.offsetX,
        self.height * 0.4 - self.font64:getHeight() * 0.5,
        self.width * 0.5,
        'right'
    )
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        'LEFT/RIGHT',
        self.font16,
        -32,
        self.height * 0.5 - self.font16:getHeight() * 0.5,
        self.width * 0.5,
        'right'
    )

    -- レベルの縦の数
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        state.levelHeight,
        self.font64,
        self.width * 0.5 + 32,
        self.height * 0.4 - self.font64:getHeight() * 0.5 + state.offsetY,
        self.width,
        'left'
    )
    lg.printf(
        'UP/DOWN',
        self.font16,
        self.width * 0.5 + 32,
        self.height * 0.5 - self.font16:getHeight() * 0.5,
        self.width,
        'left'
    )

    -- レベルの縦と高さ
    lg.setColor(1, 1, 1, 1)
    lg.printf(
        'x',
        self.font32,
        0,
        self.height * 0.4 - self.font32:getHeight() * 0.5,
        self.width,
        'center'
    )

    -- ベストスコア
    do--if self.best[self:getLevelTitle()] then
        lg.setColor(1, 1, 1, 1)
        lg.printf(
            'BEST',
            self.font16,
            -16,
            self.height * 0.6 - self.font16:getHeight() * 0.5,
            self.width * 0.5,
            'right'
        )
        lg.printf(
            self.best[self:getLevelTitle()] or 0,
            self.font32,
            self.width * 0.5 + 16,
            self.height * 0.6 - self.font32:getHeight() * 0.5,
            self.width,
            'left'
        )
    end

    -- フェード
    if state.alpha > 0 then
        lg.setColor(.42, .75, .89, state.alpha)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Select:keypressed(key, scancode, isrepeat)
    local state = self.state
    if state.busy then
        -- 演出中
    elseif key == '3' then
        self:randomTypes(3)
    elseif key == '4' then
        self:randomTypes(4)
    elseif key == '5' then
        self:randomTypes(5)
    elseif key == 'left' then
        -- レベルの幅
        state.levelWidth = state.levelWidth - 1
        if state.levelWidth < 1 then
            state.levelWidth = 100
        end

        -- 演出
        state.offsetX = 64
        state.timer:tween(
            0.2,
            state,
            { offsetX = 0 },
            'out-elastic',
            'width'
        )
    elseif key == 'right' then
        -- レベルの幅
        state.levelWidth = state.levelWidth + 1
        if state.levelWidth > 100 then
            state.levelWidth = 1
        end

        -- 演出
        state.offsetX = -64
        state.timer:tween(
            0.2,
            state,
            { offsetX = 0 },
            'out-elastic',
            'width'
        )
    elseif key == 'up' then
        -- レベルの高さを上げる
        state.levelHeight = state.levelHeight + 1
        if state.levelHeight > 100 then
            state.levelHeight = 1
        end

        -- 演出
        state.offsetY = 64
        state.timer:tween(
            0.2,
            state,
            { offsetY = 0 },
            'out-elastic',
            'height'
        )
    elseif key == 'down' then
        -- レベルの高さを下げる
        state.levelHeight = state.levelHeight - 1
        if state.levelHeight < 1 then
            state.levelHeight = 100
        end

        -- 演出
        state.offsetY = -64
        state.timer:tween(
            0.2,
            state,
            { offsetY = 0 },
            'out-elastic',
            'height'
        )
    elseif key == 'return' then
        state.timer:tween(
            1,
            state,
            { alpha = 1 },
            'in-out-cubic',
            function()
                self.musics.outgame:stop()
                self:nextState(state.levelWidth, state.levelHeight, state.levelTypes)
            end
        )
        state.busy = true
    end
end

-- マウス入力
function Select:mousepressed(x, y, button, istouch, presses)
    self:keypressed('return')
end

-- 駒スプライトのサイズ
function Select:getSpriteSize(spriteName)
    local _, __, sw, sh = self.spriteSheet.quad[spriteName]:getViewport()
    return sw, sh
end

-- 駒スプライトの描画
function Select:drawPieceSprite(spriteName, x, y, w, h)
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

-- タイプをランダムに選ぶ
function Select:randomTypes(num)
    num = num or #pieceTypes

    self.state.levelTypes = {}

    -- 全てのタイプを一旦コピー
    local types = {}
    for _, t in ipairs(pieceTypes) do
        table.insert(types, t)
    end

    -- ランダムに抜き出して選択
    for i = 1, num do
        table.insert(self.state.levelTypes, table.remove(types, love.math.random(#types)))
    end

    -- 演出
    self.state.offsetT = 64
    self.state.timer:tween(
        0.2,
        self.state,
        { offsetT = 0 },
        'out-elastic',
        'type'
    )
end

-- レベルタイトルの取得
function Select:getLevelTitle()
    return '' .. #self.state.levelTypes .. '-' .. self.state.levelWidth .. '-' .. self.state.levelHeight
end

return Select
