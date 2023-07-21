local DebugMode = class()

function DebugMode:enable()
  -- Settings for Debug Mode
  log.level = "trace"
end

function DebugMode:disable()
  log.level = "warn"
end

function DebugMode:update(dt)
  if (not luna.debugMode) then
    disableState("Debug")
  end
end

return DebugMode
