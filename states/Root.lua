-- State controlling the bare minimum for the vis execution
local Root = class('Root')

function Root.disable()
  if imgui.love.Shutdown() then
    log.warn("Root state disabled. Shutting down.")
    love.event.quit()

    return true
  else
    return false
  end
end

return Root
