_G.class = require 'lib.middleclass'.class
local Bootstrap = require "states.Bootstrap"

local cpath = package.cpath

describe("[#state] Bootstrap", function()
  describe("when loading", function ()
    it("should initialize dear imgui", function()
      --Bootstrap:load()

      -- Check if Love's save dir was appended at the end of C loader path
      --newCPath = package.cpath:split("/")
    end)
  end)
end)
