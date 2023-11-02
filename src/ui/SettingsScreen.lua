import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx<const> = playdate.graphics
local DEBUG <const> = true

class('SettingsScreen').extends()

function SettingsScreen:init()
    SettingsScreen.super.init(self)

    self.width = 250
    self.height = 200
    self.x = 200
    self.y = 120
    self.backgroundSprite = nil
    self.fontDescription = gfx.font.new("fonts/Roobert-10-Bold")
    self.fontSubtitle = gfx.font.new("fonts/Roobert-11-Bold")
    self.fontTitle = gfx.font.new("fonts/Roobert-20-Medium")

    self:drawBackground()
end

function SettingsScreen:drawBackground()
    local backgroundImg = gfx.image.new(250, 200)
    gfx.pushContext(backgroundImg)
        -- draw the box
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, self.width, self.height)

        -- border
        gfx.setLineWidth(4)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(0, 0, self.width, self.height)

        -- title
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(self.fontTitle)
        gfx.drawTextAligned("Settings", self.width/2, 10, kTextAlignment.center)

        -- subtitle
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(self.fontSubtitle)
        gfx.drawTextAligned("Difficulty", 20, 40, kTextAlignment.left)

        -- description
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(self.fontDescription)
        gfx.drawTextAligned("Choose how many moves ahead\nand how much time the\ncomputer thinks", 20, 65, kTextAlignment.left)

    gfx.popContext()
    self.backgroundSprite = gfx.sprite.new(backgroundImg)
    self.backgroundSprite:moveTo(self.x, self.y)
    self.backgroundSprite:add()
end

function SettingsScreen:dismiss()
    self.backgroundSprite:remove()
end