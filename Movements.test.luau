local settings = {Train = true, AutoPunch = true, AutoBoss = true, Rebirth = true, SmartFarm = true}
local m = require("./Maintenance")(settings, function() return 0 end)
local count = 0
local function check(value, message) count += 1; assert(value, message) end
settings.TrainWeight = true; m:resolveMovement("TrainWeight")
check(m:trainingMovement() == "Weight", "weight selected")
check(not settings.Train and not settings.AutoPunch and not settings.SmartFarm, "competing tools disabled")
check(settings.AutoBoss and settings.Rebirth, "independent boss and rebirth preserved")
for _, pair in ipairs(m.Movements) do
    settings[pair[1]] = true; m:resolveMovement(pair[1])
    check(m:trainingMovement() == pair[2], "chosen movement fixed")
    local enabled = 0
    for _, candidate in ipairs(m.Movements) do if settings[candidate[1]] then enabled += 1 end end
    check(enabled == 1, "only one movement enabled")
end
local snapshot = m:automationSnapshot()
m:clearAutomation()
check(m:trainingMovement() == nil, "global stop clears movements")
m:restoreAutomation(snapshot)
check(m:trainingMovement() == "Handstands", "comparison restores selected movement")
settings.TurboStrength = true; m:resolveMovement("TurboStrength")
check(m:trainingMovement() == nil, "other training clears fixed movement")
check(m:applyProfile({Schema=1, Settings={TrainWeight=true, TrainPushups=true, AutoPunch=true}}), "load movement profile")
check(m:trainingMovement() == "Weight" and not settings.TrainPushups and not settings.AutoPunch, "normalize conflicting profile")
check(not m:canAct(), "loaded profile remains paused")
print("PASS: " .. count .. " movement checks")
