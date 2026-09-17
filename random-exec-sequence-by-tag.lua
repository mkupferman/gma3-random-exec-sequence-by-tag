-- Randomly selects a tagged sequence and Temp-Ons it (op on).
-- OffCue Call Plugin with op off offs the last sequence.
local json = require('json')

local function usage()
    Echo("Usage: call plugin <num> '{<json args>}'")
    Echo("       Where args are 'tag', optional 'op' (on|off, default on)")
    Echo("Example: call plugin 1 '{\"op\": \"on\", \"tag\": \"Bumps\"}'")
end

-- User-var suffix from the tag. Non-alphanumeric becomes '_'.
local function varKey(tagName)
    local key = string.gsub(tostring(tagName), "[^%w]", "_")
    key = string.gsub(key, "^_+", "")
    key = string.gsub(key, "_+$", "")
    key = string.gsub(key, "_+", "_")
    if key == "" then
        return nil
    end
    return key
end

local function holdVarName(key)
    return "randexecseqtag_held_" .. key
end

local function lastVarName(key)
    return "randexecseqtag_last_" .. key
end

local function isHeld(key)
    local v = GetVar(UserVars(), holdVarName(key))
    return v == "1" or v == 1
end

local function setHeld(key, value)
    SetVar(UserVars(), holdVarName(key), value)
end

local function lastSeq(key)
    return GetVar(UserVars(), lastVarName(key))
end

local function offLast(key)
    local prev = lastSeq(key)
    if prev ~= nil and tostring(prev) ~= "" then
        CmdIndirectWait("Off Sequence " .. tostring(prev))
    end
end

local function sequenceIndex(seq)
    if seq == nil then
        return nil
    end
    local n = seq.NO
    if type(n) == "number" then
        return n
    end
    n = seq.INDEX
    if type(n) == "number" then
        return n
    end
    local addr = seq:ToAddr()
    return tonumber((string.match(tostring(addr), "(%d+)$")))
end

local function hasTag(seqTags, tagName)
    -- until a better solution exists and works, such as
    -- ShowData().Tags or
    -- ShowData():Find("Tags"):Find(tagName):Children()
    -- ... these do not as of GMA3 v2.2.1.1
    if seqTags == nil or seqTags == "" then
        return false
    end
    local tags = string.gmatch(seqTags, "([^:]+):[^:,],?")
    for tag in tags do
        if tag == tagName then
            return true
        end
    end
    return false
end

local function getSeqsByTag(tagName)
    local seqMatches = {}
    local seqResult = ObjectList("Sequence", {
        selected_as_default = false
    })
    if seqResult ~= nil and #seqResult == 1 and seqResult[1].Name == "Sequences" then
        local seqAll = seqResult[1]
        for i = 1, #seqAll do
            if seqAll[i] ~= nil then
                local seq = seqAll[i]
                if seq:GetClass() == "Sequence" then
                    if hasTag(seq.Tags, tagName) then
                        table.insert(seqMatches, seq)
                    end
                end
            end
        end
    end
    return seqMatches
end

local function opOff(key)
    setHeld(key, "0")
    offLast(key)
end

local function opOn(tagName, key)
    setHeld(key, "1")

    local taggedSeqs = getSeqsByTag(tagName)
    if #taggedSeqs == 0 then
        Echo("randexecseqtag: no sequences tagged '" .. tagName .. "'")
        return
    end

    if not isHeld(key) then
        return
    end

    offLast(key)

    if not isHeld(key) then
        return
    end

    local selectedSeq = taggedSeqs[math.random(1, #taggedSeqs)]
    local seqNo = sequenceIndex(selectedSeq)
    if seqNo ~= nil then
        SetVar(UserVars(), lastVarName(key), seqNo)
    end

    CmdIndirectWait("Temp On " .. selectedSeq:ToAddr())
    if not isHeld(key) then
        CmdIndirectWait("Off " .. selectedSeq:ToAddr())
    end
end

local function main(handle, params)
    if not params then
        usage()
        return
    end

    local args = json.decode(params)
    if not args["tag"] then
        usage()
        return
    end

    local tagName = args["tag"]
    local key = varKey(tagName)
    if key == nil then
        Echo("randexecseqtag: tag does not yield a usable variable name")
        usage()
        return
    end

    local op = "on"
    if args["op"] ~= nil then
        op = string.lower(tostring(args["op"]))
    end

    if op == "off" then
        opOff(key)
    elseif op == "on" then
        opOn(tagName, key)
    else
        Echo("randexecseqtag: unknown op '" .. op .. "'")
        usage()
    end
end
return main
