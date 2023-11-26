local lovelyMoon = {}

function lovelyMoon.update(dt)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.update then
         local newState = state:update(dt)
         if newState then
            if state.close then
               state:close()
            end

            state = newState

            if state.load then
               state:load()
            end
         end
      end
   end
end

function lovelyMoon.draw()
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.draw then
         state:draw()
      end
   end
end

function lovelyMoon.keypressed(key, scancode)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.keypressed then
         state:keypressed(key, scancode)
      end
   end
end

function lovelyMoon.keyreleased(key, scancode)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.keyreleased then
         state:keyreleased(key, scancode)
      end
   end
end

function lovelyMoon.textinput(text)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.textinput then
         state:textinput(text)
      end
   end
end

function lovelyMoon.mousemoved(x, y, dx, dy, istouch)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.mousemoved then
         state:mousemoved(x, y, dx, dy, istouch)
      end
   end
end

function lovelyMoon.mousepressed(x, y, button)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.mousepressed then
         state:mousepressed(x, y, button)
      end
   end
end

function lovelyMoon.mousereleased(x, y, button)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.mousereleased then
         state:mousereleased(x, y, button)
      end
   end
end

function lovelyMoon.wheelmoved(x, y)
   for index, state in pairs(_slotState.states) do
      if state and state._enabled and state.wheelmoved then
         state:wheelmoved(x, y)
      end
   end
end

return lovelyMoon
