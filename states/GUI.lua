-- State controlling the bare minimum for the vis execution
local GUI = class('GUI')
local projectMode = require 'states.gui.project'
local options = {}

ffi = nil

function GUI.enable()
  ffi = require 'ffi'
  local io = imgui.GetIO()

  options = {
    fullscreen = ffi.new("bool[1]", aroma.settings.video.fullscreen == true)
  }

  io.ConfigFlags = imgui.love.ConfigFlags("DockingEnable", "NavEnableKeyboard")
  io.ConfigWindowsMoveFromTitleBarOnly = true
end

function GUI.update(_, dt)
  imgui.love.Update(dt)
  imgui.NewFrame()
end

function GUI.draw()
  --[[ Main Menu Bar ]]
  if imgui.BeginMainMenuBar() then
    if imgui.BeginMenu(_L("FILE"):shorten(20)) then
        if imgui.MenuItem_Bool(_L("QUIT")) then love.event.quit() end
        imgui.EndMenu()
    end

    if imgui.BeginMenu(_L("VIEW"):shorten(20)) then
      if imgui.BeginMenu(_L("LANGUAGE")) then
        if imgui.MenuItem_Bool("English", nil, i18n.getLocale() == 'en') then
          aroma:setLocale('en')
        end

        if imgui.MenuItem_Bool("Português brasileiro", nil, i18n.getLocale() == 'pt-BR') then
          aroma:setLocale('pt-BR')
        end

        imgui.EndMenu()
      end

      if imgui.MenuItem_BoolPtr(_L("FULLSCREEN"), nil, options.fullscreen) then
        if aroma.settings.video.fullscreen ~= options.fullscreen[0] then
          aroma.settings.video.fullscreen = options.fullscreen[0]
          aroma:updateVideo()
        end
      end

      imgui.EndMenu()
    end
    imgui.EndMainMenuBar()
  end

  love.graphics.rectangle("fill", 100, 100, 50, 50)

  projectMode:draw()

  imgui.Render()
  imgui.love.RenderDrawLists()
end

function GUI.keypressed(_, key)
  imgui.love.KeyPressed(key)

  if not imgui.love.GetWantCaptureKeyboard() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.keyreleased(_, key)
  imgui.love.KeyReleased(key)

  if not imgui.love.GetWantCaptureKeyboard() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.textinput(_, text)
  imgui.love.TextInput(text)

  if imgui.love.GetWantCaptureKeyboard() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.mousemoved(_, x, y)
  imgui.love.MouseMoved(x, y)

  if not imgui.love.GetWantCaptureMouse() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.mousepressed(_, _, _, button)
  imgui.love.MousePressed(button)

  if not imgui.love.GetWantCaptureMouse() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.mousereleased(_, _, _, button)
  imgui.love.MouseReleased(button)

  if not imgui.love.GetWantCaptureMouse() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.wheelmoved(_, x, y)
  imgui.love.WheelMoved(x, y)

  if not imgui.love.GetWantCaptureMouse() then -- luacheck: ignore
    -- custom behaviour
  end
end

function GUI.disable()
  ffi = nil
end

return GUI
