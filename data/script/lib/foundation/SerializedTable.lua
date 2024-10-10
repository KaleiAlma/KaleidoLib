---@class foundation.SerializedTable
local M = {}

local JsonUtil = require('lib.foundation.JsonUtil')

local function safe_encode_json(t)
    local r, e = pcall(cjson.encode, t)
    if r then
        return e
    else
        lstg.Log(4, "failed to encode settings to json: " .. tostring(e))
        return cjson.encode(M.default)
    end
end

local function safe_decode_json(s)
    local r, e = pcall(cjson.decode, s)
    if r then
        return e
    else
        lstg.Log(4, "failed to decode settings from json: " .. tostring(e))
        return cjson.decode(cjson.encode(s)) -- copy
    end
end

---@return foundation.SerializedTable
function M.new(path,autosave,default,autoformat)
    ---@class foundation.SerializedTable
    local self = {}
    self.__data = {}
    self.__path = path
    self.__default = default or {}
    if autoformat == nil then
        self.__autoformat = true
    else
        self.__autoformat = autoformat
    end
    
    local nindex = self.data
    if autosave then
        function nindex(self, key, value)
            rawget(self,"data")[key] = value
            rawget(self,"save")(self)
        end
    end
    function self:save()
        local f, msg = io.open(self.__path, 'w')
        if f == nil then
            error(msg)
        else
            if self.__autoformat then
                f:write(JsonUtil.format_json(safe_encode_json(self.__data)))
            else
                f:write(safe_encode_json(self.__data))
            end
            f:close()
        end

    end
    function self:load()
        local f, msg = io.open(self.__path, 'r')
        if f == nil then
            self.__data = safe_decode_json(safe_encode_json(self.__default))
        else
            self.__data = safe_decode_json(f:read('*a'))
            f:close()
        end
    end

    setmetatable(self, {
        __index = self.__data,
        __newindex = nindex
    })
    return self
end

return M