-- Randomly selects a sequence that is tagged with the passed tag.
-- Assigns it to the passed executor and Temp-Ons it if the caller is still held.
local json = require('json')

local function usage()
    Echo("Usage: call plugin <num> '{<json args>}'")
    Echo("       Where args are 'exec', 'tag',")
    Echo("       'page'=1")
    Echo("Example: call plugin 1 '{\"exec\": 115, \"tag\": \"Bumps\"}'")
end

local function holdVarName(page, execNumber)
    return "randexecseqtag_held_" .. page .. "_" .. execNumber
end

local function isHeld(page, execNumber)
    local v = GetVar(UserVars(), holdVarName(page, execNumber))
    return v == "1" or v == 1
end

local function setHeld(page, execNumber, value)
    SetVar(UserVars(), holdVarName(page, execNumber), value)
end

-- IsRunningPlayback replaced HasActivePlayback in 2.4; keep a fallback for 2.2–2.3.
local function isRunningPlayback(obj)
    if obj == nil then
        return false
    end
    local ok, running = pcall(function()
        return obj:IsRunningPlayback()
    end)
    if ok then
        return running and true or false
    end
    ok, running = pcall(function()
        return obj:HasActivePlayback()
    end)
    if ok then
        return running and true or false
    end
    return false
end

local function getExecutor(page, execIndex)
    local pages = DataPool().Pages
    if pages == nil or pages[page] == nil then
        return nil
    end
    return pages[page][execIndex]
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

local function main(handle, params)
    if params then
        local args = json.decode(params)
        if args["exec"] and args["tag"] then
            local execNumber = args["exec"]
            local exec = execNumber - 100
            local tagName = args["tag"]
            local page = 1

            if args["page"] then
                page = args["page"]
            end

            -- Mark held before the tag scan so OffCue can cancel a late Temp On.
            setHeld(page, execNumber, "1")

            local taggedSeqs = getSeqsByTag(tagName)
            if #taggedSeqs == 0 then
                Echo("randexecseqtag: no sequences tagged '" .. tagName .. "'")
                return
            end

            local randomIndex = math.random(1, #taggedSeqs)
            local selectedSeq = taggedSeqs[randomIndex]
            local execAddr = "Page " .. page .. "." .. execNumber
            local executor = getExecutor(page, exec)
            if executor ~= nil then
                local assigned = executor.Object
                if assigned ~= nil and assigned:GetClass() == "Sequence" then
                    if isRunningPlayback(assigned) then
                        -- Off the sequence object so Assign cannot orphan it.
                        CmdIndirectWait("Off " .. assigned:ToAddr())
                    end
                end
            end

            CmdIndirectWait("Assign " .. selectedSeq:ToAddr() .. " At " .. execAddr)

            if isHeld(page, execNumber) then
                CmdIndirectWait("Temp On " .. execAddr)
                -- User released while Temp On was in flight.
                if not isHeld(page, execNumber) then
                    CmdIndirectWait("Off " .. execAddr)
                    CmdIndirectWait("Off " .. selectedSeq:ToAddr())
                end
            end

        else
            usage()
        end
    else
        usage()
    end
end
return main
