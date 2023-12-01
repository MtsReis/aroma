_slotState = {states = {}}
local State = {}

function State.add(class, id, index)
  class._enabled = false
  class._id = id

  log.trace(string.format("Loading %s state", id))
  local _ = class.load and class:load() -- Run if exists

  if index ~= nil and (type(index) ~= "number" or index ~= math.floor(index)) then -- Check if it's not nil/int
    log.warn("The usage of a non-numeric key for a state is NOT recommended!")
  end

  if index == nil or _slotState.states[index] ~= nil then
    if index ~= nil then
      log.warn(string.format("Key %s is already taken", id))
    end

    table.insert(_slotState.states, class)
    return #_slotState.states
  else -- an index was given and it was not taken yet
    _slotState.states[index] = class
    return index
  end
end

function State.isEnabled(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      return state._enabled
    end
  end
end

function State.get(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id then
      return state
    end
  end
end

function State.enable(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id and not state._enabled then
      log.trace(string.format("Starting %s state", id))
      local _ = state.enable and state:enable() -- Run if exists
      state._enabled = true
    end
  end
end

function State.disable(id)
  for _, state in pairs (_slotState.states) do
    if state._id == id and state._enabled then
      local disabled = true

      if state.disable and state:disable() == false then
        log.info(string.format("%s state isn't ready to be disabled", id))
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
  for _, state in pairs (_slotState.states) do
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
