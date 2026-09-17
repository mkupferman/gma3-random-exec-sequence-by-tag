---@meta grandMA3
-- LuaLS stubs for host APIs this plugin uses. grandMA3 does not load this file.

---@class Gma3Handle
---@field Name string
---@field Tags string
---@field NO number
---@field INDEX number
---@field [integer] Gma3Handle
local Gma3Handle = {}

---@return string
function Gma3Handle:GetClass() end

---@return string
function Gma3Handle:ToAddr() end

---@param msg string
---@param ... any
function Echo(msg, ...) end

---@return Gma3Handle
function UserVars() end

---@param vars Gma3Handle
---@param name string
---@return string|number|nil
function GetVar(vars, name) end

---@param vars Gma3Handle
---@param name string
---@param value string|number
function SetVar(vars, name, value) end

---@param search string
---@param options? table
---@return Gma3Handle[]
function ObjectList(search, options) end

---@param cmd string
---@param undo? string
---@param handle? Gma3Handle
function CmdIndirectWait(cmd, undo, handle) end
