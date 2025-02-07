-- Randomly selects a sequence that is tagged with the passed tag.
-- Assigns the sequence to the passed executor.
local json = require('json')
local function usage()
    Echo("Usage: call plugin <num> '{<json args>}'")
    Echo("       Where args are 'exec', 'tag',")
    Echo("       'page'=1")
    Echo("Example: call plugin 1 '{\"exec\": 115, \"tag\": \"Bumps\"}'")
end

local function hasTag(seqTags, tagName)
    -- until a better solution exists and works, such as
    -- ShowData().Tags or
    -- ShowData():Find("Tags"):Find(tagName):Children()
    -- ... these do not as of GMA3 v2.2.1.1
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
        seqAll = seqResult[1]
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
            local exec = args["exec"] - 100
            local tagName = args["tag"]
            local page = 1

            if args["page"] then
                page = args["page"]
            end

            -- Find all sequences with the tag
            taggedSeqs = getSeqsByTag(tagName)

            -- Randomly select one of the tagged sequences
            local randomIndex = math.random(1, #taggedSeqs)
            local selectedSeq = taggedSeqs[randomIndex]
            Cmd("assign " .. selectedSeq:ToAddr() .. " at page " .. page .. "." .. exec + 100)

        else
            usage()
        end
    else
        usage()
    end
end
return main
