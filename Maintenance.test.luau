local create = require("./Maintenance")
local now = 0
local s = {Train = true, AutoBoss = true, ResumeAfterDeath = true, HealthGuard = true,
    HealthLow = 25, HealthResume = 75, StallAlerts = true, StallSeconds = 30,
    GoalStat = "Strength", SmartObjective = "Força", BossPreference = "Qualquer", BossDistance = 5,
    PerformanceMode = true, StabilityMode = false}
local m = create(s, function() return now end)
local count = 0
local function check(value, message)
    count += 1
    assert(value, message)
end

check(m:canAct(), "initial state")
m:pause("Manual", true)
check(not m:canAct() and s.Train and s.AutoBoss, "pause preserves configuration")
m:pause("Respawn", true)
m:pause("Manual", false)
check(not m:canAct(), "manual resume cannot bypass respawn")
m:pause("Vida baixa", true)
m:pause("Respawn", false)
check(not m:canAct(), "respawn cannot bypass low health")
m:pause("Vida baixa", false)
check(m:canAct(), "all reasons cleared")
local events = #m.History
m:pause("Vida baixa", false)
check(#m.History == events, "idempotent pause does not spam history")

local snapshot = m:automationSnapshot()
m:clearAutomation()
check(not s.Train and not s.AutoBoss, "clear all automation")
m:restoreAutomation(snapshot)
check(s.Train and s.AutoBoss, "restore choices")
local profile = m:profile()
profile.Settings.ArbitraryCode = "not a supported setting"
s.RebirthTarget, s.ProgressionTarget, s.GoalValue, s.StopAt = 100, 100, 1000, 90
local ok = m:applyProfile(profile)
check(ok and s.Train and not m:canAct(), "load paused")
check(s.PerformanceMode == true and s.StabilityMode == false, "performance preferences round trip")
check(s.RebirthTarget == nil and s.ProgressionTarget == nil and s.GoalValue == nil and s.StopAt == nil, "no stale goal or timer")
check(s.ArbitraryCode == nil, "unknown profile keys discarded")
for _, bad in ipairs({
    {Schema = 2, Settings = {}},
    {Schema = 1, Settings = {Train = "yes"}},
    {Schema = 1, Settings = {PerformanceMode = "yes"}},
    {Schema = 1, Settings = {BossDistance = math.huge}},
    {Schema = 1, Settings = {HealthLow = 0/0}},
    {Schema = 1, Settings = {HealthResume = 1}},
    {Schema = 1, Settings = {GoalStat = "Invalid"}},
    {Schema = 1, Settings = {BossPreference = string.rep("x", 151)}},
}) do
    local before = s.Train
    local accepted = m:applyProfile(bad)
    check(not accepted and s.Train == before, "invalid profile rejected atomically")
end
check(m:setGoal("12500") and s.GoalValue == 12500, "custom absolute goal")
for _, bad in ipairs({"", "0", "-5", "1.5", "1e309", "nan", "text"}) do
    check(not m:setGoal(bad) and s.GoalValue == 12500, "invalid goal preserves previous value")
end
m:pause("Manual", false)
check(not m:sample(100, 0, true), "first sample")
now = 10
check(not m:sample(200, 0, true), "strength progress")
now = 11
m:sample(0, 1, true)
check(m.Totals.Strength == 100 and m.Totals.Rebirths == 1, "rebirth reset not counted as negative gain")
now = 42
check(m:sample(0, 1, true), "stall alert after threshold")
check(not m:sample(0, 1, true), "stall alert rate limited")
m:pause("Manual", true)
now = 100
check(not m:sample(0, 1, true), "no stall while paused")
m:pause("Manual", false)
now = 105
check(not m:sample(0, 1, true), "grace period after resume")
now = 200
check(not m:sample(0, 1, false), "no alert without training")
now = 201
check(not m:sample(0, 1, true), "new training gets fresh window")
now = 202
m:sample(10, 1, true)
check(not m.Stalled, "gain clears persistent alert")
local before = #m.History
m:updateCapabilities({Treino = true})
check(#m.History == before, "initial capability snapshot is not a regression")
m:updateCapabilities({Treino = false})
check(#m.History == before + 1, "lost capability logged")
m:updateCapabilities({Treino = false})
check(#m.History == before + 1, "no repeated compatibility spam")
m:updateCapabilities({Treino = true})
check(#m.History == before + 2, "recovered capability logged")
m.Comparing = true
local token = m.BenchmarkToken
m:cancelComparison()
check(not m.Comparing and m.BenchmarkToken > token, "cancel invalidates stale comparison task")
for i = 1, 200 do m:log("Test", i) end
check(#m.History == 150, "history bounded")
check(string.find(m:report(), "Rebirths: 1", 1, true) ~= nil, "report contains totals")
print("PASS: " .. count .. " maintenance checks")
