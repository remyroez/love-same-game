
-- エイリアス
local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse

-- クラス
local Scene = require 'Scene'
local Level = require 'Level'
local Timer = require 'Timer'

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

    local top = 64 + 8
    local bottom = 32 + 8 * 2

    -- レベル
    state.pieceTypes = pieceTypes or {}
    state.level = Level(self.spriteSheet, 0, 0, nil, self.height - (top + bottom))
    state.level:load(width, height, state.pieceTypes)
    state.level.x = (state.level.width - state.level:totalWidth()) * 0.5
    state.level.y = (state.level.height - state.level:totalHeight()) * 0.5 + top

    -- 一番大きいカウントを取る
    state.biggest = 0
    for _, count in pairs(state.level.counts) do
        if count > state.biggest then
            state.biggest = count
        end
    end

    -- 演出
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

    state.alpha2 = 0
    state.alpha3 = 0

    state.dialog = false
    state.clear = false
end

-- ステート終了
function Game:exitedState(...)
    self.state.level:destroy()
    self.state.timer:destroy()
end

-- 更新
function Game:update(dt)
    self.state.level:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Game:draw()
    local state = self.state

    -- クリア
    lg.clear(.42, .75, .89)

    -- レベル描画
    self.state.level:draw()

    -- フェード（レベル）
    if state.alpha2 > 0 then
        lg.setColor(.42, .75, .89, state.alpha2)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end

    -- メッセージ
    if state.alpha3 > 0 then
        lg.setColor(1, 1, 1, state.alpha3)
        if self.state.dialog then
            -- ダイアログ
            lg.printf('DO YOU FINISH THE GAME?', self.font32, 0, self.height * 0.45 - self.font32:getHeight() * 0.5, self.width, 'center')
            lg.printf('Y/N', self.font16, 0, self.height * 0.55 - self.font16:getHeight() * 0.5, self.width, 'center')
        elseif self.state.clear then
            -- クリア
            lg.printf('LEVEL CLEAR', self.font64, 0, self.height * 0.45 - self.font64:getHeight() * 0.5, self.width, 'center')
            lg.printf('PRESS ANY KEY', self.font16, 0, self.height * 0.6 - self.font16:getHeight() * 0.5, self.width, 'center')
        end
    end

    -- タイトル
    lg.setColor(1, 1, 1, 1)
    lg.printf('LEVEL', self.font16, 8, 0, self.width, 'left')
    lg.printf(self.state.level.title, self.font32, 8, self.font16:getHeight() * 0.5, self.width, 'left')

    -- 得点
    lg.setColor(1, 1, 1, 1)
    lg.printf(self.state.level.score, self.font64, 0, -self.font32:getHeight() * 0.5 + 8, self.width, 'center')

    -- 駒の種類別の残数
    local size = 32
    local range = size + 16 + self.font32:getWidth(self.state.biggest)
    lg.push()
    lg.translate((self.width - (#self.state.pieceTypes - 0) * range) * 0.5, self.height - size - 8)
    for i, pieceType in ipairs(self.state.pieceTypes) do
        local x = (i - 1) * range
        self:drawPieceSprite(pieceType.spriteName, x, 0, size)
        lg.printf(self.state.level.counts[pieceType.name], self.font32, x + size + 8, (size - self.font32:getHeight()) * 0.5, self.width, 'left')
    end
    lg.pop()

    -- フェード（全体）
    if state.alpha > 0 then
        lg.setColor(.42, .75, .89, state.alpha)
        lg.rectangle('fill', 0, 0, self.width, self.height)
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if self.state.busy then
        -- 演出中
    elseif self.state.clear then
        -- クリア
        self.state.timer:tween(
            1,
            self.state,
            { alpha = 1 },
            'in-out-cubic',
            function()
                self.best[self.state.level.title] = self.state.level.score
                self:gotoState('select')
            end
        )
        self.state.busy = true

    elseif not self.state.dialog and key == 'return' then
        -- 終了演出
        self.state.dialog = true
        self.state.busy = true
        self.state.level.busy = true
        self.state.level:uncheckPieces()
        self.state.timer:tween(
            1,
            self.state,
            { alpha2 = 0.5, alpha3 = 1 },
            'in-out-cubic',
            function()
                -- 操作可能
                self.state.busy = false
            end
        )
    elseif self.state.dialog then
        if key == 'y' then
            self.state.busy = true
            self.state.timer:tween(
                1,
                self.state,
                { alpha3 = 0 },
                'in-out-cubic',
                function()
                    -- ダイアログからクリア表示へ
                    self.state.dialog = false
                    self.state.clear = true
                    self.state.timer:tween(
                        1,
                        self.state,
                        { alpha3 = 1 },
                        'in-out-cubic',
                        function()
                            -- 操作可能
                            self.state.busy = false
                        end
                    )
                end
            )
        elseif key == 'n' then
            self.state.busy = true
            self.state.timer:tween(
                1,
                self.state,
                { alpha2 = 0, alpha3 = 0 },
                'in-out-cubic',
                function()
                    -- 操作可能
                    self.state.level.busy = false
                    self.state.dialog = false
                    self.state.busy = false
                end
            )
        end
    else
        self.state.level:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    if self.state.busy then
        -- 演出中
    elseif self.state.dialog then
        -- ダイアログ表示中
        if button == 1 then
            self:keypressed('y')
        elseif button == 2 then
            self:keypressed('n')
        end
    elseif self.state.clear then
        -- クリア
        self:keypressed('return')
    else
        self.state.level:mousepressed(x, y, button, istouch, presses)
    end
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
