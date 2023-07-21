-- Include required modules
require("modules/mInputVerify")
require("modules/mPersistence")
luna = require("modules/mLuna")

luna.debugMode = tablex.find(arg, "-debug") -- True if '-debug' is present as an arg

function love.load()
  -- Load and enable the bootstrapper
  addState(require("states/Bootstrap"), "Bootstrap", 2)
  enableState("Bootstrap")
end

function love.update(dt)
  InputVerify:update(dt)
  lovelyMoon.update(dt)
end

function love.draw()
  lovelyMoon.draw()
end

function love.keypressed(key, scancode)
  InputVerify:keypressed(scancode)
  lovelyMoon.keypressed(key, scancode)
end

function love.keyreleased(key, scancode)
  InputVerify:keyreleased(scancode)
  lovelyMoon.keyreleased(key, scancode)
end

function love.textinput(text)
  lovelyMoon.textinput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
  lovelyMoon.mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button)
  lovelyMoon.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  lovelyMoon.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
  lovelyMoon.wheelmoved(x, y)
end

function love.quit()
  Persistence:saveINI() -- luna.settings -> settings.cfg
  Persistence:saveINI(InputVerify.commandList, 'controls.cfg', false)
  return false
end
