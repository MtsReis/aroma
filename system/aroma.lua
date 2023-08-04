local Aroma = pl.class()

-- Default settings
local videoW, videoH = love.window.getDesktopDimensions()
Aroma.settings = {
	sound = {
		_tweakable = {"sVolume", "mVolume"},
		sVolume = 70,
		mVolume = 80,
	},

	video = {
		_tweakable = {"w", "h", "vsync", "fullscreen"},
		w = videoW * .9, -- Leave 10% of screen unused
		h = videoH * .9,
		vsync = true,
		fullscreen = false
	}
}

-- Update video settings with the values that user defined
function Aroma:updateVideo()
	love.window.setMode(self.settings.video.w, self.settings.video.h, {
		fullscreen = self.settings.video.fullscreen,
		vsync = self.settings.video.vsync,
    resizable = true,
    minwidth = 640,
    minheight = 420
	})
end

return Aroma
