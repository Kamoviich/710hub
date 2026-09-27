local now = 0
local settings = {BossDefense=true}
local m = require("./Maintenance")(settings, function() return now end)
local count = 0
local function check(value, text) count += 1; assert(value, text) end
check(not m:bossRetreat(100,100), "healthy initial attack")
now=1; check(m:bossRetreat(90,100), "damage triggers retreat")
now=3; check(m:bossRetreat(90,100), "retreat lasts at least 2.5 seconds")
now=3.6; check(not m:bossRetreat(90,100), "attack resumes after delay")
now=4; check(m:bossRetreat(55,100), "low health blocks attack")
now=30; check(m:bossRetreat(55,100), "low health keeps retreat active")
now=33; check(not m:bossRetreat(85,100), "recovered health allows attack")
settings.BossDefense=false
check(not m:bossRetreat(10,100), "disabled option preserves legacy combat")
print("PASS: " .. count .. " boss defense checks")
