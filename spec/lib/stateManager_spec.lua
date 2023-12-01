require("matcher_combinators.luassert")
local t = require("matcher_combinators.matchers.table")

describe("[#lib] stateManager", function()
  setup(function()
    State = require "lib.stateManager"

    -- Dummies for dependencies
    _G.log = {
      trace = function() end,
      warn = function() end
    }
  end)

  it("should create the _slotstate global", function()
    assert.is_not_nil(_slotState)
    assert.is_not_nil(_slotState.states)
    assert.is_table(_slotState.states)
  end)

  describe("by adding states", function()
    before_each(function()
      blankState = {
        load = function() end,
        enable = function() end
      }
    end)

    it("should insert a state to the 'states' table", function()
      State.add(blankState, "name")

      assert.combinators.match({t.contains(blankState)}, _slotState.states)
    end)

    it("should call the 'load' method of the added state", function()
      stub(blankState, "load")

      State.add(blankState, "stub")

      assert.stub(blankState.load).was.called()
      assert.stub(blankState.load).was.called_with(match.is_ref(blankState)) -- Called with self

      blankState.load:revert()
    end)

    describe("given a predefined index", function()
      differentState = {
        load = function() end
      }

      it("should complain if a non-numeric key is given, but proceed with the operation", function()
        stub(log, "warn")
        State.add(differentState, "non-numeric", "key")

        assert.are.equal(differentState, _slotState.states["key"])
        assert.stub(log.warn).was.called()
        assert.stub(log.warn).was.called("The usage of a non-numeric key for a state is NOT recommended!")

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
        local takenIndex = State.add({a = "a"}, "takenIndex", 20)

        assert.are_number(freeIndex, takenIndex)
        assert.are_equal(freeIndex, 20)
        assert.are_equal(takenIndex, #_slotState.states)
      end)
    end)
  end)
end)
