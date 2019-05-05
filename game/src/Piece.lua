
local class = require 'middleclass'

-- クラス
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- 駒
local Piece = class 'Piece'
Piece:include(require 'Transform')
Piece:include(require 'Rectangle')
Piece:include(require 'SpriteRenderer')

local function uuid()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

-- 初期化
function Piece:initialize(args)
    args = args or {}

    -- タイプ
    self.type = args.type or 'none'
    self.color = args.color or { 1, 1, 1, 1 }
    self.checked = false
    self.uuid = uuid()
    self.timer = Timer()

    -- SpriteRenderer 初期化
    self:initializeSpriteRenderer(args.spriteSheet)

    -- スプライト
    self.spriteName = args.spriteName or 'snake.png'
    local spriteWidth, spriteHeight = self:getSpriteSize(self.spriteName)

    local w = args.width or spriteWidth
    local h = args.height or spriteHeight

    -- Rectangle 初期化
    self:initializeRectangle(args.x, args.y, spriteWidth, spriteHeight, 'center')

    -- Transform 初期化
    self:initializeTransform(self.x, self.y, args.rotation, w / spriteWidth, h / spriteHeight)

    -- 今のスケールを保存
    self.baseScaleX = self.scaleX
    self.baseScaleY = self.scaleY
    self.offsetScaleX = 0
    self.offsetScaleY = 0

    -- デバッグモード
    self.debugMode = args.debugMode or false
end

-- 破棄
function Piece:destroy()
    self.timer:destroy()
end

-- 更新
function Piece:update(dt)
    self.timer:update(dt)
end

-- 描画
function Piece:draw()
    -- チェック背景の描画
    self:pushTransform(self:left(), self:top())
    if self.checked then
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.rectangle('fill', 0, 0, self.width, self.height)
    end
    self:popTransform()

    -- スプライトの描画
    local sx, sy = self.scaleX, self.scaleY
    self.scaleX = self.scaleX + self.offsetScaleX
    self.scaleY = self.scaleY + self.offsetScaleY
    self:pushTransform(self:left(), self:top())
    love.graphics.setColor(self.color)
    self:drawSprite(self.spriteName)
    self:popTransform()
    self.scaleX, self.scaleY = sx, sy
end

-- デバッグモードの設定
function Piece:setDebugMode(mode)
    self.debugMode = mode or false
end

-- 演出
function Piece:tween(...)
    return self.timer:tween(...)
end

-- タイマーを返す
function Piece:getTimer(tag)
    return self.timer.timers[tag]
end

-- タイマーがあるかどうか
function Piece:hasTimer(tag)
    return self:getTimer(tag) ~= nil
end

-- チェック演出
function Piece:tweenCheck(delay, c)
    c = c == nil and true or c
    self:tween(
        delay,
        self,
        { offsetScaleX = c and self.baseScaleX * 0.25 or 0, offsetScaleY = c and self.baseScaleY * 0.25 or 0 },
        c and 'out-quint' or 'in-quint',
        function ()
            self:tweenCheck(delay, not c)
        end,
        c and 'in' or 'out'
    )
    return thisTag
end

-- チェック演出キャンセル
function Piece:cancelCheck()
    self.timer:cancel('in')
    self.timer:cancel('out')
    self.offsetScaleX = 0
    self.offsetScaleY = 0
end

return Piece
