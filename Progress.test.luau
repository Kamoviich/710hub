local create = require("./Maintenance")
local now, count = 0, 0
local s = {StallAlerts = false, RebirthGuard = true, RebirthFloor = 100,
    RebirthInterval = 1, BreakEnabled = true, BreakEvery = 1, BreakMinutes = 1}
local m = create(s, function() return now end)
local function check(value, message)
    count += 1
    assert(value, message)
end
check(not m:canRequestRebirth(99, 0), "floor prevents early rebirth")
check(m:canRequestRebirth(100, 0), "floor boundary allowed")
m.LastRebirthRequest = now
check(not m:canRequestRebirth(100, 0), "cooldown shared")
now = 1
check(m:canRequestRebirth(100, 0), "cooldown expires")
m.RebirthInFlight = true
check(not m:canRequestRebirth(100, 0), "no overlapping requests")
m.RebirthInFlight = false
s.RebirthTarget = 10
check(not m:canRequestRebirth(100, 10), "target reached")
m:pause("Manual", true)
check(not m:canRequestRebirth(100, 0), "pause prevents rebirth")
m:pause("Manual", false)
m.Comparing = true
check(not m:canRequestRebirth(100, 0), "comparison prevents rebirth")
m.Comparing = false
for t = 0, 10 do now = t; m:sample(t * 10, 0, true) end
check(m:strengthRate() == 600, "rolling rate")
check(m:eta(100, 700) == 60, "eta in seconds")
check(m:eta(100, 100) == 0, "reached target")
now = 11; m:sample(0, 1, true)
check(m:strengthRate() == nil, "rebirth resets window")
for t = 12, 22 do now = t; m:sample((t - 11) * 10, 1, true) end
check(m:strengthRate() == 600, "rate recovers after rebirth")
m:pause("Manual", true)
check(m:strengthRate() == nil, "paused rate unavailable")
now = 23; m:sample(110, 1, true)
m:pause("Manual", false)
check(m:strengthRate() == nil, "paused sample discards history")
for t = 24, 34 do now = t; m:sample(110, 1, true) end
check(m:eta(110, 700) == nil, "zero gain has no eta")
now = 50; m:sample(500, 1, true)
check(m:strengthRate() == nil, "sampling gap resets rate")
for t = 51, 200 do now = t; m:sample(t * 10, 1, true) end
check(#m.Samples <= 61, "rolling history bounded")
now = 206
check(m:strengthRate() == nil, "stale samples ignored")
m:resetBreak()
for _ = 1, 29 do m:tickBreak(2, true) end
check(not m.Reasons.Descanso, "no break before threshold")
m:tickBreak(2, true)
check(m.Reasons.Descanso and m.BreakUntil == 266, "scheduled break starts")
m:pause("Manual", true)
now = 266; m:tickBreak(1, true)
check(not m.Reasons.Descanso and m.Reasons.Manual, "break cannot bypass manual pause")
m:tickBreak(2, true)
check(m.ActiveSeconds == 0, "manual pause not counted")
m:pause("Manual", false)
m:tickBreak(2, false)
check(m.ActiveSeconds == 0, "idle time not counted")
m:tickBreak(1000, true)
check(m.ActiveSeconds == 2, "long scheduler gap clamped")
s.BreakEnabled = false; m:tickBreak(2, true)
check(m.ActiveSeconds == 0, "disabled break clears counter")
local valid = m:validateProfile({Schema = 1, Settings = {RebirthInterval = .5, RebirthFloor = 0, BreakMinutes = 5}})
check(valid ~= nil, "new profile settings accepted")
for _, settings in ipairs({{RebirthInterval = 0}, {RebirthFloor = -1}, {BreakMinutes = math.huge}, {BreakEnabled = "yes"}}) do
    check(m:validateProfile({Schema = 1, Settings = settings}) == nil, "invalid new profile rejected")
end
print("PASS: " .. count .. " progress checks")
