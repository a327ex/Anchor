-- The base State class.  
-- The general way of creating an object that implements these functions goes like this:
--[[
MyState = Object:extend()
MyState:implement(State)
function MyState:init(name)
  self:init_state(name)
end

function MyState:on_enter(from)

end

function MyState:update(dt)

end


function MyState:draw()

end
]]--

-- This creates a new MyState class which you can then use to start writing your code.
-- Use the init function for things you need to do when the state object is created.
-- Use the on_enter function for things you need to do whenever the state gets activated.
-- By default, whenever a state gets deactivated it's not deleted from memory, so if you want to restart a level, for instance, whenever you switch states,
-- then you need to destroy everything that needs to be destroyed in an on_exit function and then recreate it again in the on_enter function.
--
-- You'd add a state to the game like this:
--   state.add(MyState'level_1')
-- You'd move to that state like so:
--   state.go_to'level_1'
-- state.go_to automatically calls on_exit for the currently active state and on_enter for the new one.
-- You can access the currently active state with state.current.
State = Object:extend()
function State:init_state(name)
  self.name = name or random:uid()
  self.active = false
end


function State:enter(from)
  self.active = true
  if self.on_enter then self:on_enter(from) end
end


function State:exit(to)
  self.active = false
  if self.on_exit then self:on_exit(to) end
end



-- The main state. This is a global state that is always active and contains all other states.
Main = Object:extend()
Main:implement(State)
function Main:init(name)
  self:init_state(name)
  self.states = {}
  self.transitions = Group():no_camera()
end


function Main:update(dt)
  for _, state in pairs(self.states) do
    if state.active or state.persistent_update then
      state:update(dt)
    end
  end
  self.transitions:update(dt)
end


function Main:draw()
  for _, state in pairs(self.states) do
    if state.active or state.persistent_draw then
      state:draw()
    end
  end
  self.transitions:draw()
end


function Main:add(state)
  self.states[state.name] = state
end


function Main:get(state_name)
  return self.states[state_name]
end


-- Deactivates the current active state and activates the target one.
-- Calls on_exit for the deactivated state and on_enter for the activated one.
function Main:go_to(state, ...)
  if type(state) == 'string' then state = self:get(state) end

  if self.current then
    if self.current.active then
      self.current:exit(state)
    end
  end

  local last_state = self.current
  self.current = state
  state:enter(last_state, ...)
end
