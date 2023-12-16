require("matcher_combinators.luassert")
local t = require("matcher_combinators.matchers.table")

local lovelyMoon = require "lib.lovelyMoon"
local StateManager = require "lib.stateManager"

local execState = function(self)
  table.insert(execOrder, self._id)
end

local methods = {
  update = { 1/60 }, -- dt
  draw = {},
  keypressed = { "space", "space", false }, -- key, scancode, isrepeat
  keyreleased = { "space", "space" }, -- key, scancode
  textinput = { "@" }, -- text
  mousemoved = { 20, 20, 10, 10, true }, -- x, y, dx, dy, istouch
  mousepressed = { 20, 20, 3, false, 2 }, -- x, y, button, istouch, presses
  mousereleased = { 20, 20, 3, false, 2 }, -- x, y, button, istouch, presses
  wheelmoved = { 5, 5 } -- x, y
}

local stateOne = {}
local stateThree = {}
local stateFour = {}

for method, _ in pairs(methods) do
  stateOne[method] = execState
  stateThree[method] = execState
  stateFour[method] = execState
end

describe("[#lib] lovelyMoon", function()
  setup(function()
    -- Dummies for dependencies
    _G.execOrder = {}

    _G.log = {
      trace = function() end,
      warn = function() end,
      info = function() end,
      error = function() end,
    }

    StateManager.add(stateOne, "1st")
    StateManager.add(stateFour, "4th", 4)
    StateManager.add(stateThree, "3rd", 3)

    StateManager.enable("1st")
    StateManager.enable("4th")
    StateManager.enable("3rd")
  end)

  for method, args in pairs(methods) do
    describe(string.format("by calling '%s'", method), function()
      setup(function()
        execOrder = {}

        sOne = spy.on(_slotState.states[1], method)
        sThree = spy.on(stateThree, method)
        sFour = spy.on(stateFour, method)

        lovelyMoon[method](unpack(args))
      end)

      it("should run the methods in order", function ()
        assert.combinators.match({"1st", "3rd", "4th"}, execOrder)
      end)

      it("should pass the right arguments", function()
        assert.spy(sOne).was.called_with(table.unpack({
          match.is_ref(stateOne), unpack(methods[method])
        }))
      end)

      teardown(function()
        stateOne[method]:revert()
        stateThree[method]:revert()
        stateFour[method]:revert()
      end)
    end)
  end
end)
