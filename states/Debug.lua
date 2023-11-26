local DebugMode = class('DebugMode')

function DebugMode:load()
  lovebird = require "lib.lovebird"
end

function DebugMode:enable()
  -- Settings for Debug Mode
  log.level = "trace"
end

function DebugMode:update(dt)
  if (not aroma.debugMode) then
    disableState("Debug")
  end

  lovebird.update()
end

function DebugMode:disable()
  log.level = "warn"
end

function DebugMode:unload()
  lovebird = nil
end

return DebugMode
