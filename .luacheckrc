stds.aroma = {
   globals = {"aroma", "lovelyMoon", "imgui", "_L"},
   read_globals = {"pl", "pw", "pd", "class", "state"}
}

std = "luajit+lua52+love+aroma"
exclude_files = {"lib/*", "examples/"}
allow_defined_top = true
