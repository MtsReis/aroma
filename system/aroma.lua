local Luna = class()

-- Default settings
local videoW, videoH = love.window.getDesktopDimensions()
Luna.settings = {
	sound = {
		_tweakable = {"sVolume", "mVolume"},
		sVolume = 70,
		mVolume = 80,
	},

	video = {
		_tweakable = {"w", "h", "vsync", "fullscreen"},
		w = videoW,
		h = videoH,
		vsync = true,
		fullscreen = true
	}
}

-- Update video settings with the values that player defined
function Luna:updateVideo()
	love.window.setMode(self.settings.video.w, self.settings.video.h, {
		fullscreen = self.settings.video.fullscreen,
		vsync = self.settings.video.vsync
	})
end

return Luna
