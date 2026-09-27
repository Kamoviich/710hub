local function object(class, name, parent)
    local o = {ClassName = class, Name = name, Parent = parent, Children = {}, Attributes = {}, Tags = {}}
    if parent then table.insert(parent.Children, o) end
    function o:IsA(kind) return self.ClassName == kind or (kind == "BasePart" and self.ClassName == "Part") end
    function o:GetDescendants()
        local result = {}
        for _, child in ipairs(self.Children) do
            table.insert(result, child)
            for _, nested in ipairs(child:GetDescendants()) do table.insert(result, nested) end
        end
        return result
    end
    function o:FindFirstChild(name)
        for _, child in ipairs(self.Children) do if child.Name == name then return child end end
    end
    function o:FindFirstChildWhichIsA(kind, recursive)
        for _, child in ipairs(recursive and self:GetDescendants() or self.Children) do if child:IsA(kind) then return child end end
    end
    function o:GetAttribute(key) return self.Attributes[key] end
    function o:GetTags() return self.Tags end
    function o:IsDescendantOf(ancestor)
        local parent = self.Parent
        while parent do if parent == ancestor then return true end; parent = parent.Parent end
        return false
    end
    return o
end
local world = object("Folder", "Workspace")
local people = {}
local players = {GetPlayers = function() return people end}
local settings = {BossPreference = "Qualquer"}
local detector = require("./BossDetection")(world, players, settings)
local count = 0
local function check(value, text) count += 1; assert(value, text) end
local function rig(name, parent)
    local model = object("Model", name, parent or world)
    local hum = object("Humanoid", "Humanoid", model)
    hum.Health, hum.MaxHealth, hum.DisplayName = 77, 77, ""
    object("Part", "HumanoidRootPart", model)
    return model, hum
end
local boss, hum = rig("RareBoss")
check(detector.matches(boss), "english marker")
boss.Name = "Chefe Raro"
check(detector.matches(boss), "portuguese marker")
boss.Name = "BlueGolem"; hum.DisplayName = "Rare Boss"
check(detector.matches(boss), "display name marker")
hum.DisplayName = ""; boss.Tags = {"BossNPC"}
check(detector.matches(boss), "tag marker")
boss.Tags = {}; boss.Attributes.IsBoss = true
check(detector.matches(boss), "attribute marker")
boss.Attributes = {}
check(not detector.matches(boss), "unmarked NPC rejected")
settings.BossPreference = "BlueGolem"
check(detector.matches(boss), "explicit name selection")
settings.BossPreference = "Qualquer"
hum.Health = 0; boss.Tags = {"Boss"}
check(not detector.matches(boss), "dead boss rejected")
local wrapper = object("Model", "EpicBoss", world)
local nested = rig("Rig", wrapper)
check(detector.matches(wrapper) and detector.matches(nested), "nested rig and ancestor marker")
people[1] = {Character = nested}
check(not detector.matches(wrapper) and not detector.matches(nested), "player and enclosing model excluded")
local child = object("Model", "BossAccessory", nested)
check(not detector.matches(child), "player descendant excluded")
people[1] = nil
local custom = object("Model", "MythicBoss", world)
custom.Attributes.Health = 100
object("Part", "Body", custom)
check(detector.matches(custom) and detector.health(custom).Health == 100, "custom health and mesh body")
custom.Attributes.Health = 0
check(not detector.matches(custom), "custom dead boss rejected")
local m = require("./Maintenance")({}, function() return 0 end)
for _, name in ipairs({"Common Boss", "Rare Boss", "Epic Boss", "Legendary Boss", "Mythic Boss", "Rainbow Boss"}) do
    check(m:bossRarity(name) ~= "Desconhecido", "classify category")
end
check(m:bossRarity("CHEFE ÉPICO") == "Epico", "accented category")
for i = 1, 35 do m:recordBoss("Raro", "RareBoss") end
check(m.BossObservations == 35 and #m.BossRecent == 30, "bounded observations")
check(m:bossOddsReport():find("64.2%%") ~= nil, "independent twenty-draw probability")
print("PASS: " .. count .. " boss checks")
