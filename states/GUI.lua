-- State controlling the bare minimum for the vis execution
local GUI = pl.class()

function GUI:enable()
  ffi = require 'ffi'
  local io = imgui.GetIO()

  options = {
    fullscreen = ffi.new("bool[1]", aroma.settings.video.fullscreen == true)
  }

  io.ConfigFlags = imgui.love.ConfigFlags("DockingEnable", "NavEnableKeyboard")
  io.ConfigWindowsMoveFromTitleBarOnly = true
end

function GUI:update(dt)
  imgui.love.Update(dt)
  imgui.NewFrame()
end

function GUI:draw()
  -- Main Menu Bar
  if imgui.BeginMainMenuBar() then
      if imgui.BeginMenu(_L("FILE")) then
          if imgui.MenuItem_Bool(_L("QUIT")) then love.event.quit() end
          imgui.EndMenu()
      end

      if imgui.BeginMenu(_L("VIEW") ) then
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

  local vp = imgui.GetMainViewport()

  imgui.SetNextWindowPos(vp.WorkPos)
  imgui.SetNextWindowSize(vp.WorkSize)
  imgui.SetNextWindowViewport(vp.ID)

  imgui.PushStyleVar_Float(imgui.ImGuiStyleVar_WindowRounding, 0)
  imgui.PushStyleVar_Float(imgui.ImGuiStyleVar_WindowBorderSize, 0)
  imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_WindowPadding, imgui.ImVec2_Float(0, 0))

  local wFlags = imgui.love.WindowFlags("MenuBarNoDocking", "NoTitleBar", "NoCollapse", "NoResize", "NoMove", "NoBringToFrontOnFocus", "NoNavFocus")
  local dFlags = imgui.love.DockNodeFlags("None")

  imgui.Begin("Main Dockspace Window", nil, wFlags)
    imgui.PopStyleVar(3)

    local dockspace_id = imgui.GetID_Str("MainDockspace")
    imgui.DockSpace(dockspace_id, imgui.ImVec2_Float(0, 0), dFlags)

    if imgui.Begin(_L("TEST_WINDOW")) then
      if imgui.CollapsingHeader_TreeNodeFlags(_L("OPTIONS")) then
        local fb = table.pack(love.graphics.getBackgroundColor())
        fb.n = nil
        fb = fb[1] == 1 and fb[2] == 1 and fb[3] == 1 and 1 or fb

        local p = ffi.new("bool[1]", fb == 1)
        if imgui.Checkbox(_L("FLASHBANG"), p) then
          local cb = p[0] and {1, 1, 1, 1} or (fb ~= 1 and fb or {0, 0, 0, 1})

          love.graphics.setBackgroundColor(table.unpack(cb))
        end
      end
    end
    imgui.End()

  imgui.End()

  imgui.Render()
  imgui.love.RenderDrawLists()
end

function GUI:keypressed(key, scancode)
  imgui.love.KeyPressed(key)

  if not imgui.love.GetWantCaptureKeyboard() then
    -- custom behaviour 
  end
end

function GUI:keyreleased(key, scancode)
  imgui.love.KeyReleased(key)

  if not imgui.love.GetWantCaptureKeyboard() then
    -- custom behaviour 
  end
end

function GUI:textinput(text)
  imgui.love.TextInput(text)

  if imgui.love.GetWantCaptureKeyboard() then
    -- custom behaviour 
  end
end

function GUI:mousemoved(x, y, dx, dy, istouch)
  imgui.love.MouseMoved(x, y)

  if not imgui.love.GetWantCaptureMouse() then
    -- custom behaviour
  end
end

function GUI:mousepressed(x, y, button)
  imgui.love.MousePressed(button)

  if not imgui.love.GetWantCaptureMouse() then
    -- custom behaviour 
  end
end

function GUI:mousereleased(x, y, button)
  imgui.love.MouseReleased(button)

  if not imgui.love.GetWantCaptureMouse() then
    -- custom behaviour 
  end
end

function GUI:wheelmoved(x, y)
  imgui.love.WheelMoved(x, y)

  if not imgui.love.GetWantCaptureMouse() then
    -- custom behaviour 
  end
end

function GUI:disable()
  ffi = nil
end

return GUI
