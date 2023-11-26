local ProjectModeView = class('ProjectModeView')

function ProjectModeView:update(dt, data)
end

function ProjectModeView:draw()
  local vp = imgui.GetMainViewport()

  imgui.SetNextWindowPos(vp.WorkPos)
  imgui.SetNextWindowSize(vp.WorkSize)
  imgui.SetNextWindowViewport(vp.ID)

  imgui.PushStyleVar_Float(imgui.ImGuiStyleVar_WindowRounding, 0)
  imgui.PushStyleVar_Float(imgui.ImGuiStyleVar_WindowBorderSize, 0)
  imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_WindowPadding, imgui.ImVec2_Float(0, 0))

  local wFlags = imgui.love.WindowFlags("MenuBarNoDocking", "NoTitleBar", "NoCollapse", "NoResize", "NoMove", "NoBringToFrontOnFocus", "NoNavFocus")
  local dFlags = imgui.love.DockNodeFlags("None")

  imgui.Begin("MainDockspaceWindow", nil, wFlags)
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
end

return ProjectModeView
