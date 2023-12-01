_slotState = {states = {}}
local State = {}

function State.add(class, id, index)
  class._enabled = false
  class._id = id

  log.trace(string.format("Loading %s state", id))
  local _ = class.load and class:load() -- Run if exists

  if index == nil or _slotState.states[index] ~= nil then
    if index ~= nil then
      log.warn(string.format("Key %s is already taken", id))
    end

    table.insert(_slotState.states, class)
    return #_slotState.states
  else -- an index was given but it's already taken
    _slotState.states[index] = class
    return index
  end
end

function State.isEnabled(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      return state._enabled
    end
  end
end

function State.get(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      return state
    end
  end
end

function State.enable(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      log.trace(string.format("Starting %s state", id))
      local _ = state.enable and state:enable() -- Run if exists
      state._enabled = true
    end
  end
end

function State.disable(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      local disabled = true

      if state.disable and state:disable() == false then
        log.trace(string.format("%s state isn't ready to be disabled", id))
        disabled = false
      end

      if disabled then
        log.trace(string.format("Disabling %s state", id))
        state._enabled = false
      end
    end
  end
end

function State.toggle(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      if state._enabled then
        State.disable(id)
      else
        State.enable(id)
      end
    end
  end
end

function State.destroy(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      log.trace(string.format("Destroying %s state", id))
      local _ = state.close and state:close() -- Run if exists
      table.remove(_slotState.states, index)
    end
  end
end

return State
