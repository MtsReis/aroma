-- Module responsible for saving and loading files
class.Persistence()

function Persistence:saveINI(data, dir, tweakableOnly)
	data = data or luna.settings
	dir = dir or 'settings.cfg'
	tweakableOnly = (tweakableOnly ~= false) or false -- True as default value

		success, message = lip.save(dir, data, tweakableOnly)

		if not success then
			log.warn(message)
		end
end

function Persistence:loadSettings(dir)
	dir = dir or 'settings.cfg'

	-- Check whether the specified file exists
	if love.filesystem.getInfo(dir) ~= nil then
		local userSettings = lip.load(dir) -- Load user settings

		-- Iterate over INI sections
		for section, sectionValue in pairs(userSettings) do
			if type(sectionValue) == "table" and luna.settings[section] ~= nil then
				-- Load fields in the section if it has tweakable values
				if luna.settings[section]['_tweakable'] ~= nil then
					for settingKey, settingValue in pairs(sectionValue) do
						-- Only load the key if it's tweakable
						if tablex.find(luna.settings[section]['_tweakable'], settingKey) ~= nil then
							luna.settings[section][settingKey] = settingValue
						end
					end
				end
			end
		end
	end
end

function Persistence:loadControls(dir)
	dir = dir or 'controls.cfg'

	-- Check whether the specified file exists
	if love.filesystem.getInfo(dir) ~= nil then
		local userControls = lip.load(dir)

		-- Iterate over INI sections
		for section, sectionValue in pairs(userControls) do
			if type(sectionValue) == "table" and InputVerify.commandList[section] ~= nil then
				-- Load fields in the section if it has tweakable values
				for controlKey, controlValue in pairs(sectionValue) do
					InputVerify.commandList[section][controlKey] = controlValue
				end
			end
		end
	end
end
