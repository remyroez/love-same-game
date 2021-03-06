
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

    -- 音楽
    local musics = {
        ingame = 'Alpha Dance.ogg',
        outgame = 'Flowing Rocks.ogg',
    }
    self.musics = {}
    for name, path in pairs(musics) do
        self.musics[name] = love.audio.newSource('assets/' .. path, 'static')
        self.musics[name]:setLooping(true)
        self.musics[name]:setVolume(0.5)
    end

    -- ＳＥ
    local sounds = {
        gameover = 'Beat ident.ogg',
        start = 'threeTone2.ogg',
        cursor = 'coin5.ogg',
        cancel = 'twoTone2.ogg',
        remove = 'upgrade1.ogg',
        undo = 'jump4.ogg',
    }
    self.sounds = {}
    for name, path in pairs(sounds) do
        self.sounds[name] = love.audio.newSource('assets/' .. path, 'static')
    end

    -- ベストスコア
    self.best = {}

    -- キーリピート有効
    love.keyboard.setKeyRepeat(true)
end

-- 更新
function Boot:update()
    self:nextState()
end

return Boot
