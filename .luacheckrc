stds.aroma = {
  globals = {"aroma", "imgui", "_L"},
read_globals = {"pl", "pw", "pd", "class", "state"}}

std = "luajit+lua52+love+aroma"

include_files = {
  "main.lua", "conf.lua", "states/*", "system/*", "views/*", "lib/*"
}
exclude_files = {
  "lib/cimgui/*", "lib/i18n/*", "lib/pl/*", "lib/lovebird.lua", "lib/middleclass.lua",
  "output/", "spec/"
}

allow_defined_top = true
