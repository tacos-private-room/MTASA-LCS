Stack = Core.class()
 
function Stack:init(list)
 
  if not list then
    -- create an empty stack
    self.stack = {}
  else
    -- initialise the stack
    self.stack = list
  end
end
 
function Stack:push(item)
  -- put an item on the stack
  self.stack[#self.stack+1] = item
end
 
function Stack:pop()
  -- make sure there's something to pop off the stack
  if #self.stack > 0 then
    -- remove item (pop) from stack and return item
    return table.remove(self.stack, #self.stack)
  end
end
 
function Stack:iterator()
  -- wrap the pop method in a function
  return function()
    -- call pop to iterate through all items on a stack
    return self:pop()
  end
end