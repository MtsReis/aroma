-- Translate Löve inputs into valid commands
class.InputVerify()

InputVerify.commandList = {
	keyboard = {
		["`"] = "console"
	}
}

InputVerify.holdingKeys = {}

function InputVerify:keypressed(key)
	if self.commandList.keyboard[key] ~= nil then
		self.holdingKeys[key] = self.commandList.keyboard[key]
		lovelyMoon.commandpressed(self.commandList.keyboard[key])
	end
end

function InputVerify:keyreleased(key)
	if self.commandList.keyboard[key] ~= nil then
		self.holdingKeys[key] = nil
		lovelyMoon.commandreleased(self.commandList.keyboard[key])
	end
end

function InputVerify:update(key)
	for key, command in pairs(self.holdingKeys) do
		lovelyMoon.commandhold(command)
	end
end
