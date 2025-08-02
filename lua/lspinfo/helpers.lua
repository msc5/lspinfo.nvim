local o = {}

--- Check if a table is an array
---@param t table
---@return boolean
function o.is_array(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

return o
