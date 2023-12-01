require("matcher_combinators.luassert")
local t = require("matcher_combinators.matchers.table")

describe("[#lib] stateManager", function()
  setup(function()
    State = require "lib.stateManager"

    -- Dummies for dependencies
    _G.log = {
      trace = function() end,
      warn = function() end,
      info = function() end
    }
  end)

  it("should create the _slotstate global", function()
    assert.is_not_nil(_slotState)
    assert.is_not_nil(_slotState.states)
    assert.is_table(_slotState.states)
  end)

  describe("adding states", function()
    before_each(function()
      blankState = {
        load = function() end,
        enable = function() end
      }
    end)

    it("should insert a state to the 'states' table", function()
      State.add(blankState, "mainState")

      assert.combinators.match({t.contains(blankState)}, _slotState.states)
    end)

    it("should call the 'load' method of the added state", function()
      stub(blankState, "load")

      State.add(blankState, "stub")

      assert.stub(blankState.load).was.called()
      -- Called with self
      assert.stub(blankState.load).was.called_with(match.is_ref(blankState))

      blankState.load:revert()
    end)

    describe("given a predefined index", function()
      differentState = {
        load = function() end
      }

      it("should complain if a non-numeric key is given, but proceed with the operation", function()
        stub(log, "warn")

        State.add(blankState, "empty")
        State.add(blankState, "numeric", 90)

        assert.stub(log.warn).was.not_called()

        State.add(blankState, "string", "key")
        State.add(blankState, "decimal", 9.1)
        State.add(blankState, "boolean", true)
        State.add(blankState, "boolean", false)

        assert.are.equal(blankState, _slotState.states["key"])
        assert.stub(log.warn).was.called(4)
        assert.stub(log.warn).was.called_with("The usage of a non-numeric key for a state is NOT recommended!")

        log.warn:revert()
      end)

      it("should assign an index that's currently empty", function()
        State.add(differentState, "index", 70)

        assert.are.equal(differentState, _slotState.states[70])
      end)

      it("should NOT override an index that's already taken", function()
        stub(log, "warn")
        State.add(differentState, "takenIndex", 1)

        assert.are.not_equal(differentState, _slotState.states[1])
        assert.stub(log.warn).was.called()

        log.warn:revert()
      end)

      it("should return the assigned index", function()
        local freeIndex = State.add(blankState, "freeIndex", 20)
        local takenIndex = State.add({attr = "value"}, "takenIndex", 20)

        assert.are_number(freeIndex, takenIndex)
        assert.are_equal(freeIndex, 20)
        assert.are_equal(takenIndex, #_slotState.states)
      end)
    end)
  end)

  describe("enabling a state by its id", function()
    assert.is_false(_slotState.states[1]._enabled)
    State.enable(_slotState.states[1]._id)
    assert.is_true(_slotState.states[1]._enabled)

    it("should call the 'enable' method of the state ONLY if it was NOT enabled already", function()
      stub(_slotState.states[1], "enable")

      State.enable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.not_called()

      _slotState.states[1]._enabled = false
      State.enable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(1)
      -- Called with self
      assert.stub(_slotState.states[1].enable).was.called_with(match.is_ref(_slotState.states[1]))

      _slotState.states[1].enable:revert()
    end)
  end)

  describe("trying to disable a state", function()
    it("should call the 'disable' method of the state ONLY if it was NOT disabled already", function()
      stub(_slotState.states[1], "disable")

      _slotState.states[1]._enabled = false
      State.disable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].disable).was.not_called()

      _slotState.states[1]._enabled = true
      State.disable(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].disable).was.called(1)

      _slotState.states[1].disable:revert()
    end)

    it("should give an info if the state is NOT ready to be disabled", function()
      stub(log, "info")

      -- Stub out the disable method of state ready to be disabled
      _slotState.states[1].disable = function() end
      _slotState.states[1]._enabled = true

      State.disable(_slotState.states[1]._id)
      assert.stub(log.info).was.not_called()

      -- Stub out the disable method of state NOT ready to be disabled
      _slotState.states[1].disable = function() return false end
      _slotState.states[1]._enabled = true

      State.disable(_slotState.states[1]._id)
      assert.stub(log.info).was.called(1)

      log.info:revert()
    end)
  end)

  describe("toggling a state by its id", function()
    _slotState.states[1].disable = nil -- Make sure it's ready to disable
    local wasEnabled = _slotState.states[1]._enabled

    State.toggle(_slotState.states[1]._id)
    assert.are.not_equal(_slotState.states[1]._enabled, wasEnabled)

    it("should call the 'disable'/'enable' method of the state, accordingly", function()
      stub(_slotState.states[1], "enable")
      stub(_slotState.states[1], "disable")
      _slotState.states[1]._enabled = false

      State.toggle(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(1)
      assert.stub(_slotState.states[1].disable).was.called(0)

      _slotState.states[1].enable:clear()

      State.toggle(_slotState.states[1]._id)
      assert.stub(_slotState.states[1].enable).was.called(0)
      assert.stub(_slotState.states[1].disable).was.called(1)

      _slotState.states[1].enable:revert()
      _slotState.states[1].disable:revert()
    end)
  end)

  it("should inform if a state is enabled by its id", function()
    State.add({}, "enabledState")
    assert.not_truthy(State.isEnabled("enabledState"))

    State.enable("enabledState")
    assert.truthy(State.isEnabled("enabledState"))
  end)

  it("should return a state by its id", function()
    local newState = {attr = "uniqueAttr"}
    State.add(newState, "newState")

    assert.combinators.match(t.contains(newState), State.get("newState"))
  end)

  pending("destroying a state by its id")

end)
