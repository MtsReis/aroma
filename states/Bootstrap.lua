local Bootstrap = class()

function Bootstrap:load()
  -----------------------------------------------
  --                    imgui
  -----------------------------------------------
  -- Copy the shared library to the save directory
  local lib_folder = string.format("lib/cimgui/shared/%s-%s", jit.os, jit.arch)
  assert(
    love.filesystem.getRealDirectory(lib_folder),
    "The precompiled cimgui shared library is not available for your os/architecture. You can try compiling it yourself."
  )
  local dest_dir = string.format("libs/%s-%s", jit.os, jit.arch)

  love.filesystem.remove(dest_dir)
  love.filesystem.createDirectory(dest_dir)

  for _, v in ipairs(love.filesystem.getDirectoryItems(lib_folder)) do
    local src = string.format("%s/%s", lib_folder, v)
    local dest = string.format("%s/%s", dest_dir, v)
    assert(love.filesystem.write(dest, love.filesystem.read(src)))
  end

  -- Modify package.cpath so it can be found by ffi.load
  local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
  package.cpath = string.format("%s;%s/%s/?.%s", package.cpath, love.filesystem.getSaveDirectory(), dest_dir, extension)

  imgui = require "lib/cimgui"

  -----------------------------------------------
  --                  settings
  -----------------------------------------------
  -- Load the user .cfg files
  Persistence:loadSettings()
  Persistence:loadControls()

  -- Update video with the user settings
  luna:updateVideo()

  -----------------------------------------------
  --                   states
  -----------------------------------------------
  if luna.debugMode then
    addState(require("states/Debug"), "Debug", 10)
  end

  addState(require("states/Root"), "Root", 1)
  addState(require("states/GUI"), "GUI")
end

function Bootstrap:enable()
  imgui.love.Init()

  if luna.debugMode then
    enableState("Debug")
  end

  enableState("Root")
  enableState("GUI")
end

function Bootstrap:update()
  -- End of boot
  disableState("Bootstrap")
  destroyState("Bootstrap")
end

return Bootstrap
