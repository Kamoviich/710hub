local now = 0
local settings = {BossDefense=true, HealthGuard=true, HealthLow=40, HealthResume=80}
local m = require("./Maintenance")(settings, function() return now end)
local count = 0
local function check(value, text) count += 1; assert(value, text) end
check(not m:bossRetreat(100,100), "healthy initial attack")
now=1; check(m:bossRetreat(90,100), "damage triggers retreat")
now=3; check(m:bossRetreat(90,100), "retreat lasts 2.5 seconds")
now=3.6; check(not m:bossRetreat(90,100), "attack resumes after delay")
now=4; check(m:bossRetreat(40,100) and m.BossRecovering, "configured threshold enters recovery")
now=8; check(m:bossRetreat(60,100), "hysteresis prevents early reentry")
now=9; check(not m:bossRetreat(80,100), "configured recovery threshold")
check(not m.Reasons["Vida baixa"], "own pause removed after recovery")
m:pause("Manual", true)
check(not m:bossMayMove(), "manual pause blocks retreat")
m:pause("Manual", false); m:pause("Vida baixa", true)
check(m:bossMayMove(), "own health pause permits retreat")
m:pause("Respawn", true)
check(not m:bossMayMove(), "respawn blocks movement")
m:resetBossDefense()
check(not m.Reasons["Vida baixa"] and m.Reasons.Respawn, "stop clears only own pause")
m:pause("Respawn", false)
settings.BossDefense=false; settings.HealthGuard=false
check(not m:bossRetreat(10,100), "both controls disabled preserves choice")
settings.HealthGuard=true
check(m:bossRetreat(10,100), "health guard works without reactive dodge")
m.BossRetreatCFrame = "fixed"
now=20; check(m:bossRetreat(20,100) and m.BossRetreatCFrame == "fixed", "recovery keeps retreat anchor")
now=30; m:bossRetreat(90,100)
check(m.BossRetreatCFrame == nil, "recovered state clears anchor")
settings.PvpGood=true
check(m:pvpEligible(10,20), "good mode targets evil")
check(not m:pvpEligible(20,10), "good mode excludes good")
check(not m:pvpEligible(10,10), "neutral excluded")
check(not m:pvpEligible(nil,20), "missing karma excluded")
check(not m:pvpEligible(0/0,20), "invalid karma excluded")
settings.PvpGood=false; settings.PvpEvil=true
check(m:pvpEligible(20,10), "evil mode targets good")
check(not m:pvpEligible(10,20), "evil mode excludes evil")
m:clearAutomation()
check(not settings.PvpGood and not settings.PvpEvil, "global stop clears pvp")
print("PASS: " .. count .. " combat checks")
