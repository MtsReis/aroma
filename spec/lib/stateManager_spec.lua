require("matcher_combinators.luassert")
local t = require("matcher_combinators.matchers.table")

local StateManager = require "lib.stateManager"

describe("[#lib] stateManager", function()
  setup(function()
    -- Dummies for dependencies
    _G.log = {
      trace = function() end,
      warn = function() end,
      info = function() end,
      error = function() end,
    }
  end)

  it("should create the _slotState global", function()
    assert.is_not_nil(_slotState)
    assert.is_not_nil(_slotState.states)
    assert.is_table(_slotState.states)
  end)

  --[[ StateManager.add ]]
  describe("adding states", function()
    before_each(function()
      blankState = {
        load = function() end,
        enable = function() end
      }
    end)

    it("should insert a state to the 'states' table", function()
      StateManager.add(blankState, "mainState")
      assert.combinators.match(t.contains({blankState}), _slotState.states)
    end)

    it("should call the 'load' method of the added state", function()
      stub(blankState, "load")

      StateManager.add(blankState, "stub")

      assert.stub(blankState.load).was.called()
      -- Called with self
      assert.stub(blankState.load).was.called_with(match.is_ref(blankState))

      blankState.load:revert()
    end)

    describe("given a predefined index", function()
      differentState = {
        load = function() end
      }

      it("should NOT allow non-integer keys", function()
        assert.has_no.errors(function() StateManager.add(blankState, "empty") end)
        assert.has_no.errors(function() StateManager.add(blankState, "numeric", 90) end)

        assert.has_error(function() StateManager.add(blankState, "string", "key") end)
        assert.has_error(function() StateManager.add(blankState, "decimal", 9.1) end)
        assert.has_error(function() StateManager.add(blankState, "boolean", true) end)
        assert.has_error(function() StateManager.add(blankState, "boolean", false) end)

        assert.are.equal(blankState, _slotState.states[90])
      end)

      it("should assign an index that's currently empty", function()
        StateManager.add(differentState, "index", 70)

        assert.are.equal(differentState, _slotState.states[70])
      end)

      it("should NOT override an index that's already taken", function()
        stub(log, "warn")
        StateManager.add(differentState, "takenIndex", 1)

        assert.are.not_equal(differentState, _slotState.states[1])
        assert.stub(log.warn).was.called()

        log.warn:revert()
      end)

      it("should return the assigned index", function()
        local freeIndex = StateManager.add(blankState, "freeIndex", 20)
        local takenIndex = StateManager.add({attr = "value"}, "takenIndex", 20)

        assert.are_number(freeIndex, takenIndex)
        assert.are_equal(freeIndex, 20)
        assert.are.not_equal(takenIndex, 20)
      end)
    end)
  end)

  --[[ StateManager.enable ]]
  describe("enabling a state by its id", function()
    assert.is_false(_slotState.states[1]._enabled)
    local success = StateManager.enable(_slotState.states[1]._id)
    assert.is_true(_slotState.states[1]._enabled)

    it("should call the 'enable' method of the state ONLY if it was NOT enabled already", function()
      stub(_slotState.states[1], "enable")

      StateManager.enable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.not_called()

      _slotState.states[1]._enabled = false
      StateManager.enable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(1)
      -- Called with self
      assert.stub(_slotState.states[1].enable).was.called_with(match.is_ref(_slotState.states[1]))

      _slotState.states[1].enable:revert()
    end)

    it("should return whether the operation failed or not", function()
      assert.is_true(success)
      success = StateManager.enable("Non-existent state")
      assert.is_false(success)
    end)
  end)

  --[[ StateManager.disable ]]
  describe("trying to disable a state", function()
    local success

    it("should call the 'disable' method of the state ONLY if it was NOT disabled already", function()
      stub(_slotState.states[1], "disable")

      _slotState.states[1]._enabled = false
      StateManager.disable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].disable).was.not_called()

      _slotState.states[1]._enabled = true
      StateManager.disable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].disable).was.called(1)

      _slotState.states[1].disable:revert()
    end)

    it("should give an info if the state is NOT ready to be disabled", function()
      stub(log, "info")

      -- Stub out the disable method of state ready to be disabled
      _slotState.states[1].disable = function() end
      _slotState.states[1]._enabled = true

      StateManager.disable(_slotState.states[1]._id)
      assert.stub(log.info).was.not_called()

      -- Stub out the disable method of state NOT ready to be disabled
      _slotState.states[1].disable = function() return false end
      _slotState.states[1]._enabled = true

      success = StateManager.disable(_slotState.states[1]._id)
      assert.stub(log.info).was.called(1)

      log.info:revert()
    end)

    it("should return whether the operation failed or not", function()
      assert.is_false(success)

      success = StateManager.disable("Non-existent state")
      assert.is_false(success)

      _slotState.states[1].disable = function() return true end
      success = StateManager.disable(_slotState.states[1]._id)

      assert.is_true(success)
    end)
  end)

  --[[ StateManager.toggle ]]
  describe("toggling a state by its id", function()
    _slotState.states[1].disable = nil -- Make sure it's ready to disable
    local wasEnabled = _slotState.states[1]._enabled

    local success = StateManager.toggle(_slotState.states[1]._id)
    assert.are.not_equal(_slotState.states[1]._enabled, wasEnabled)

    it("should call the 'disable'/'enable' method of the state, accordingly", function()
      stub(_slotState.states[1], "enable")
      stub(_slotState.states[1], "disable")
      _slotState.states[1]._enabled = false

      StateManager.toggle(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(1)
      assert.stub(_slotState.states[1].disable).was.called(0)

      _slotState.states[1].enable:clear()

      StateManager.toggle(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(0)
      assert.stub(_slotState.states[1].disable).was.called(1)

      _slotState.states[1].enable:revert()
      _slotState.states[1].disable:revert()
    end)

    it("should return if the operation failed or not", function()
      assert.is_boolean(success)
    end)
  end)

  --[[ StateManager.isEnabled ]]
  it("should inform if a state is enabled by its id", function()
    StateManager.add({}, "enabledState")
    assert.not_truthy(StateManager.isEnabled("enabledState"))

    StateManager.enable("enabledState")
    assert.truthy(StateManager.isEnabled("enabledState"))
  end)

  --[[ StateManager.get ]]
  it("should return a state by its id", function()
    local newState = {attr = "uniqueAttr"}
    StateManager.add(newState, "newState")

    assert.combinators.match(t.contains(newState), StateManager.get("newState"))
  end)

  --[[ StateManager.destroy ]]
  describe("destroying a state by its id", function()
    local destState = {temporary = true}
    StateManager.add(destState, "stateToDestroy", 100)
    assert.is.not_nil(_slotState.states[100])
    spy.on(StateManager, "disable")
    local success = StateManager.destroy("stateToDestroy")
    
    it("should try and disable the state before destroying it", function()
      assert.spy(StateManager.disable).was_called_with("stateToDestroy")
      StateManager.disable:revert()
    end)

    it("should be removed from the states table", function()
      assert.is_nil(_slotState.states[100])
    end)

    it("should return if the operation failed or not", function()
      assert.truthy(success)

      -- Try again now that the state does not exist anymore
      success = StateManager.destroy("stateToDestroy")
      assert.falsy(success)
    end)
  end)

  --[[ StateManager.states' metatable ]]
  it("should track the correct order of execution", function()
    -- Reset the Global
    package.loaded["lib.stateManager"] = false
    _G._slotState = nil
    require "lib.stateManager"

    StateManager.add({intendedIndex = 1}, "1st")
    StateManager.add({intendedIndex = 2}, "2nd")
    StateManager.add({intendedIndex = 5}, "5th", 5)
    StateManager.add({intendedIndex = 7}, "Last", 50)
    StateManager.add({intendedIndex = 3}, "3rd", 3)
    StateManager.add({intendedIndex = 4}, "4th")
    StateManager.add({intendedIndex = 6}, "6th", 3)

    for iSet, state in ipairs(_slotState.states) do
      assert.are_equal(iSet.i, state.intendedIndex)
    end

     StateManager.destroy("1st")
     StateManager.destroy("2nd")

     for iSet, state in ipairs(_slotState.states) do
       assert.are_equal(iSet.i, state.intendedIndex - 2)
     end

     StateManager.add({intendedIndex = 2}, "2nd again", 2)
     StateManager.add({intendedIndex = 1}, "1st again")

     for iSet, state in ipairs(_slotState.states) do
      assert.are_equal(iSet.i, state.intendedIndex)
    end
  end)

  it("should keep track of the amount of loaded states", function()
    assert.are_equal(7, #_slotState.states)
  end)
end)
