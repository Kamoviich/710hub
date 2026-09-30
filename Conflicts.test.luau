local settings = {}
local m = require("./Maintenance")(settings, function() return 0 end)
local count = 0
local function check(value, message) count += 1; assert(value, message) end
local function reset(values)
    table.clear(settings)
    for key, value in pairs(values) do settings[key] = value end
end
for a, others in pairs(m.Conflicts) do
    for b in pairs(others) do
        reset({[a]=true,[b]=true, Hatch=true, Chests=true, GoalEnabled=true})
        local disabled = m:resolveConflicts(a)
        check(settings[a] and not settings[b], a .. " must win over " .. b)
        check(m.Conflicts[b][a], "symmetric rule")
        check((a == "AutoNovaPhoenix" or b == "AutoNovaPhoenix" or settings.Hatch) and settings.Chests and settings.GoalEnabled, "preserve independent helpers")
        check(table.find(disabled,b) ~= nil, "report disabled option")
        settings[a] = false; m:resolveConflicts(a)
        check(not settings[b], "do not secretly restart old mode")
    end
end
for _, pair in ipairs({{"TrainWeight","Rebirth"},{"AutoMachine","AutoBestMachine"},{"AutoMachine","StrengthRebirth"},{"Train","StrengthRebirth"},{"SmartRock","AutoPunch"},{"TrainWeight","LockPosition"},{"TrainWeight","AutoBoss"},{"PvpGood","Hatch"},{"PvpGood","AutoBestMachine"},{"TurboStrength","LockPosition"}}) do
    reset({[pair[1]]=true,[pair[2]]=true})
    m:resolveConflicts(pair[1]); m:resolveConflicts(pair[2])
    check(settings[pair[1]] and settings[pair[2]], "compatible pair " .. table.concat(pair," + "))
end
reset({})
check(m:applyProfile({Schema=1,Settings={AutoMachine=true,AutoAgility=true,Hatch=true}}), "profile loads")
check(not (settings.AutoMachine and settings.AutoAgility) and settings.Hatch, "profile conflicts normalized")
reset({})
m:applyProfile({Schema=1,Settings={SmartFarm=true,AutoMachine=true,StrengthRebirth=true,Hatch=true}})
check(settings.SmartFarm and settings.Hatch and not settings.AutoMachine, "smart farm owns regenerated children")
print("PASS: " .. count .. " conflict checks")
