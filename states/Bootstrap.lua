local Bootstrap = pl.class()

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

  imgui = require 'lib.cimgui'

  -----------------------------------------------
  --                  settings
  -----------------------------------------------
  -- Load the user .cfg files
  Persistence:loadSettings()

  -- Update video with the user settings
  aroma:updateVideo()

  -----------------------------------------------
  --                    i18n
  -----------------------------------------------
  i18n.loadFile('../i18n/en.lua')
  i18n.loadFile('../i18n/pt-BR.lua')

  i18n.setLocale('en')

  -----------------------------------------------
  --                   states
  -----------------------------------------------
  if aroma.debugMode then
    addState(require 'states.Debug', "Debug", 10)
  end

  addState(require 'states.Root', "Root", 1)
  addState(require 'states.GUI', "GUI")

  -----------------------------------------------
  --                  wrappers
  -----------------------------------------------
  --[[
    Return a name that only includes 'stringKey' in Dear_imgui's UID generator
    and use its localized string as the actual label.

    e.g.: 'Welcome###WELCOME_msg' (only 'WELCOME_msg' is pushed into the ID stack)
  ]]
  _L = function(stringKey)
    return i18n(stringKey) .. "###" .. stringKey
  end
end

function Bootstrap:enable()
  imgui.love.Init()

  if aroma.debugMode then
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
