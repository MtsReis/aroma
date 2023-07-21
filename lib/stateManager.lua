_slotState = { states = {} }

function addState(class, id, key)
  class._enabled = false
  class._id = id

  log.trace(string.format("Loading %s state", id))
  local _ = class.load and class:load() -- Run if exists

  if (key ~= nil and _slotState.states[key] == nil) then
    _slotState.states[key] = class
  else
    table.insert(_slotState.states, class)
  end

  return state
end

function isStateEnabled(id)
   for index, state in pairs (_slotState.states) do
      if state._id == id then
        return state._enabled
      end
   end
end

function getState(id)
   for index, state in pairs (_slotState.states) do
      if state._id == id then
        return state
      end
   end
end

function enableState(id)
   for index, state in pairs (_slotState.states) do
      if state._id == id then
        log.trace(string.format("Starting %s state", id))
        local _ = state.enable and state:enable() -- Run if exists
        state._enabled = true
      end
   end
end

function disableState(id)
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

function toggleState(id)
   for index, state in pairs (_slotState.states) do
      if state._id == id then
        if state._enabled then
          disableState(id)
        else
          enableState(id)
        end
      end
   end
end

function destroyState(id)
   for index, state in pairs (_slotState.states) do
      if state._id == id then
        log.trace(string.format("Destroying %s state", id))
        local _ = state.close and state:close() -- Run if exists
        table.remove(_slotState.states, index)
      end
   end
end