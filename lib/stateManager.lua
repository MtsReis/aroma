_slotState = _slotState or {states = {}}
local StateManager = {}

function StateManager.add(class, id, index)
  class._enabled = false
  class._id = id

  log.trace(string.format("Loading state '%s'", id))
  local _ = class.load and class:load() -- Run if exists

  if index ~= nil and (type(index) ~= "number" or index ~= math.floor(index)) then -- Check if it's not nil/int
    log.warn("The usage of a non-numeric key for a state is NOT recommended!")
  end

  if index == nil or _slotState.states[index] ~= nil then
    if index ~= nil then
      log.warn(string.format("Key '%s' is already taken", id))
    end

    table.insert(_slotState.states, class)
    return #_slotState.states
  else -- an index was given and it was not taken yet
    _slotState.states[index] = class
    return index
  end
end

function StateManager.isEnabled(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      return state._enabled
    end
  end
end

function StateManager.get(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      return state
    end
  end
end

function StateManager.enable(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id and not state._enabled then
      log.trace(string.format("Starting state '%s'", id))
      local _ = state.enable and state:enable() -- Run if exists
      state._enabled = true
      return state._enabled
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

function StateManager.disable(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      if state._enabled then
        local disabled = true

        if state.disable and state:disable() == false then
          log.info(string.format("State '%s' isn't ready to be disabled", id))
          disabled = false
        end

        if disabled then
          log.trace(string.format("Disabling state '%s'", id))
          state._enabled = false
        end
      end

      return not state._enabled
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

function StateManager.toggle(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      if state._enabled then
        return StateManager.disable(id)
      else
        return StateManager.enable(id)
      end
    end
  end
end

function StateManager.destroy(id)
  for index, state in pairs (_slotState.states) do
    if state._id == id then
      if StateManager.disable(id) then -- Try to disable the state first
        log.trace(string.format("Destroying %s state", id))
        local _ = state.close and state:close() -- Run if exists
        _slotState.states[index] = nil
      end

      return _slotState.states[index] == nil
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

return StateManager
