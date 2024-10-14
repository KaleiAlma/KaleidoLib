--- This is a general style guide and as well as a tutorial I think!

--- name of the file should be the same as the name of the class
--- in this case: Boss.lua
--- classes should be in ThisCase

local GameManager = require("game.GameManager") -- references to external classes MUST be stored in local variables defined at the start of the file

---@class game.Boss: foundation.object.class --ALWAYS put luadocs annotations whenever possible. unsure on modules vs classmod
---@field init fun(self: game.Boss) --also annotate the methods and fields, they are the same here
---@field method_with_name fun(self: game.Boss) 
---@field method_with_name fun(self: game.Boss) 
local M = ObjectClass() --classes should be defined right after requiring the classes

M.default_value = 4 --fields should be this_case.
M.__private_value = 5 --indicate private fields with __ at the start

function M:init() --self is the class instance. in the case of ObjectClass, it's a Game Object
    self.x = 0
    self.y = 0
    self.group = GameManager.groups.GROUP_ENEMY
end

function M:method_with_name() --unsure on whether methods should be this_case or thisCase

end

function M:__add(other) --in the case of metamethods, just define it with the same name it would have in the metatable
    return self.x + other
end

return M --returning the class at the end of a file is a MUST

---end of boss.lua

--ObjectClass is used whenever you want to make an object. You want to use objects when they're interacting with the game, player and stuff (eg. Bosses, Enemies)
--Class is used whenever you want to do a standard class. You want to do a standard class whenever you aren't actually interacting with the engine (eg. Tasks, UI)
--Singletons should be used as a module, like math and table

---To instantiate a class, just call it

local Boss = require("game.Boss")
local bossObj = Boss() --to store objects, use nameObj for better consistency

