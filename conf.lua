-- Core libs
pl = require'lib.pl.import_into'() -- On-demand lib loading into pl
lip = require 'lib.LIP'
log = require 'lib.log'
require 'lib.stateManager'
require 'lib.lovelyMoon'

-- Direct access to some convenient functions
pd = require 'lib.pl.pretty'.dump
pw = require 'lib.pl.pretty'.write
pl.stringx.import() -- Bring the stringx methods into the standard string table

-- Init specific config
log.level = "warn"

function love.conf(t)
  t.identity = "aroma"
  t.version = "11.4"

  t.window.title = "Aroma Editor"
  t.window.resizable = true

  t.externalstorage = true
end
