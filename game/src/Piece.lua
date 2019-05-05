
local class = require 'middleclass'

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

    -- デバッグモード
    self.debugMode = args.debugMode or false
end

-- 破棄
function Piece:destroy()
end

-- 更新
function Piece:update(dt)
end

-- 描画
function Piece:draw()
    -- スプライトの描画
    love.graphics.setColor(self.color)
    self:pushTransform(self:left(), self:top())
    self:drawSprite(self.spriteName)
    self:popTransform()
end

-- デバッグモードの設定
function Piece:setDebugMode(mode)
    self.debugMode = mode or false
end

return Piece
