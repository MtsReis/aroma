-- State controlling the bare minimum for the vis execution
local GUI = class()

function GUI:enable()
  ffi = require "ffi"
  io = imgui.GetIO()

  show = {
    demo = ffi.new("bool[1]", false),
    style = ffi.new("bool[1]", false),
    metrics = ffi.new("bool[1]", false)
  }

  io.ConfigFlags = imgui.love.ConfigFlags("DockingEnable")
end

function GUI:update(dt)
  imgui.love.Update(dt)
  imgui.NewFrame()
end

function GUI:draw()
  if imgui.BeginMainMenuBar() then
    if imgui.BeginMenu("File") then
      if imgui.MenuItem_Bool("Quit") then love.event.quit() end
      imgui.EndMenu()
    end
    if imgui.BeginMenu("View") then
      if imgui.BeginMenu("Dear ImGui windows") then
        imgui.MenuItem_BoolPtr("Show demo window", nil, show.demo)
        imgui.MenuItem_BoolPtr("Show style editor", nil, show.style)
        imgui.MenuItem_BoolPtr("Show metrics window", nil, show.metrics)
        imgui.EndMenu()
      end

      imgui.EndMenu()
    end

    imgui.EndMainMenuBar()
  end

    if imgui.Begin("Test window") then
      if imgui.CollapsingHeader_TreeNodeFlags("Options") then
        local fb = table.pack(love.graphics.getBackgroundColor())
        fb.n = nil
        fb = fb[1] == 1 and fb[2] == 1 and fb[3] == 1 and 1 or fb

        local p = ffi.new("bool[1]", fb == 1)
        if imgui.Checkbox("Flashbang", p) then
          local cb = p[0] and {1, 1, 1, 1} or (fb ~= 1 and fb or {0, 0, 0, 1})

          love.graphics.setBackgroundColor(table.unpack(cb))
        end
      end
      imgui.End()
    end

      if imgui.Begin("Container temp") then
        imgui.TextDisabled("Disabled text just to fill a bit of the window")
      end
      imgui.End()

    if show.demo[0] then imgui.ShowDemoWindow(show.demo) end
    if show.metrics[0] then imgui.ShowMetricsWindow(show.metrics) end
    if show.style[0] then
        if imgui.Begin("Style editor", show.style) then imgui.ShowStyleEditor() end
        imgui.End()
    end

  -- render imgui
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

return GUI
