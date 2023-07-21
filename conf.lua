-- Include some necessary libs
require 'lib/pl'
require("lib/stateManager")
require("lib/lovelyMoon")
lip = require 'lib/LIP'
log = require("lib/log")
pd = pretty.dump
pw = pretty.write
stringx.import()

-- Init specific config
log.level = "warn"

function love.conf(t)
  t.identity = "aroma"
  t.version = "11.4"

  t.window.title = "Aroma Editor"
  t.window.resizable = true

  t.externalstorage = true
end
