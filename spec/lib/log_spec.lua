local log = require "lib.log"
local match = require("luassert.match")

local levels = {"trace", "debug", "info", "warn", "error", "fatal"}
local tbLevel = 4 -- warn

local function in_text(state, arguments)
  local expected = arguments[1]

  return function(value)
    return value:find(expected) ~= nil
  end
end

assert:register("matcher", "in_text", in_text)

describe("[#lib] log.lua", function()
  setup(function()
    -- Dummies for dependencies
    _G.love = {
      filesystem = {
        append = function() end
      }
    }

    stub(_G, "print")
    stub(love.filesystem, "append")

    log.outfile = "fileName"
  end)

  describe("by calling a log level", function()
    before_each(function()
      love.filesystem.append:clear()
      print:clear()
    end)

    it("should print the message to the standard output", function()
      log[levels[1]]("Message")
      assert.stub(print).was.called_with(match.is.in_text("Message"))
    end)

    it("should append the message to the log file through love.filesystem", function()
      log[levels[1]]("Multiple messages", "messages count: ", 2)
      assert.stub(love.filesystem.append).was.called_with(match.is_equal("fileName"), match.is.in_text("Multiple messages"))
    end)

    it("should NOT log lower levels", function()
      log.level = levels[3]
      log[levels[2]]("New message")

      assert.stub(print).was.not_called()
    end)

    it("should include a traceback ONLY for levels equal or higher than the one defined in log.tbLevel", function()
      local s = spy.on(debug, "traceback")

      log.tbLevel = levels[tbLevel]
      log.level = levels[tbLevel]

      log[levels[tbLevel]]("Detailed message")
      log[levels[tbLevel + 1]]("Detailed message with higher level")

      assert.spy(s).was.called(2)
      debug.traceback:clear()

      log[levels[tbLevel - 1]]("Simple message")
      assert.spy(s).was.not_called()

      debug.traceback:revert()
    end)

    it("should NEVER include a traceback if log.tbLevel is false", function()
      local s = spy.on(debug, "traceback")

      log.tbLevel = false
      log.level = levels[#levels]

      log[levels[#levels]]("Highest level message")
      assert.spy(s).was.not_called()

      debug.traceback:revert()
    end)
  end)

  teardown(function()
    print:revert()
    love.filesystem.append:revert()
  end)
end)
