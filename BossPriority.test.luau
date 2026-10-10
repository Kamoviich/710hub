local function object(class,name,parent)
    local obj = {ClassName=class,Name=name,Parent=parent,Children={},Attributes={},Tags={}}
    if parent then parent.Children[#parent.Children+1] = obj end
    function obj:IsA(kind) return self.ClassName==kind or kind=="BasePart" and self.ClassName=="Part" end
    function obj:GetDescendants()
        local children = {}
        for _, child in ipairs(self.Children) do
            children[#children+1] = child
            for _, item in ipairs(child:GetDescendants()) do children[#children+1] = item end
        end
        return children
    end
    function obj:FindFirstChild(name) for _, child in ipairs(self.Children) do if child.Name==name then return child end end end
    function obj:FindFirstChildWhichIsA(class,recursive)
        for _, child in ipairs(recursive and self:GetDescendants() or self.Children) do if child:IsA(class) then return child end end
    end
    function obj:GetAttribute(name) return self.Attributes[name] end
    function obj:GetTags() return self.Tags end
    function obj:IsDescendantOf(parent)
        local node=self.Parent
        while node do if node==parent then return true end; node=node.Parent end
        return false
    end
    return obj
end
local world=object("Folder","Workspace")
local settings={BossPreference="Qualquer"}
local classifier=require("./Maintenance")(settings,function() return 0 end)
local detector=require("./BossDetection")(world,{GetPlayers=function() return {} end},settings)
local function classify(text) return classifier:bossRarity(text) end
local count=0
local function check(value,text) count+=1; assert(value,text) end
local function boss(name,rarity,distance)
    local model=object("Model",name,world)
    model.Attributes.IsBoss=true
    if rarity then model.Attributes.Rarity=rarity end
    model.Distance=distance or 10
    local hum=object("Humanoid","Humanoid",model)
    hum.Health,hum.MaxHealth,hum.DisplayName=100,100,""
    object("Part","HumanoidRootPart",model)
    return model
end
local function choose(list,current) return detector.choose(list,classify,function(model) return model.Distance end,current) end
local common=boss("Common Boss","Comum",1)
local rare=boss("Rare Boss","Raro",2)
local epic=boss("Epic Boss","Épico",3)
local legendary=boss("Legendary Boss","Lendário",4)
local mythic=boss("Mythic Boss","Mítico",5)
local rainbow=boss("Rainbow Boss","Rainbow",1000)
check(choose({common,rare,epic,legendary,mythic,rainbow})==rainbow,"rainbow beats distance")
check(choose({common,rare,epic,legendary,mythic})==mythic,"mythic before legendary")
check(choose({common,rare,epic,legendary})==legendary,"legendary before epic")
check(choose({common,rare,epic})==epic,"epic before rare")
check(choose({common,rare})==rare,"rare before common")
settings.BossPreference=common.Name
check(choose({common,mythic})==mythic,"preferred common cannot override rarity")
local other=boss("Other Mythic","Mítico",100)
settings.BossPreference=other.Name
check(choose({mythic,other})==other,"preferred name breaks rarity tie")
settings.BossPreference="Qualquer"
check(choose({mythic,other})==mythic,"distance breaks tie when no current target")
check(choose({mythic,other},other)==other,"keeps current same-rarity target")
check(detector.shouldSwitch(common,mythic,classify),"preempts lower-rarity target")
check(not detector.shouldSwitch(mythic,common,classify),"never downgrades a living target")
check(not detector.shouldSwitch(mythic,other,classify),"equal rarity does not oscillate")
rainbow:FindFirstChild("Humanoid").Health=0
check(choose({mythic,rainbow})==mythic,"dead rainbow excluded")
rainbow:FindFirstChild("Humanoid").Health=100
rainbow.Parent=nil
check(choose({mythic,rainbow})==mythic,"removed rainbow excluded")
local structured=boss("Common Boss","Mitico")
check(detector.info(structured,classify)=="Mitico","metadata overrides name")
local labelled=boss("Guardian")
local label=object("TextLabel","BossRarity",labelled); label.Text="CHEFE LENDÁRIO"
check(detector.info(labelled,classify)=="Lendario","reads billboard rarity")
local field=boss("Guardian")
local value=object("StringValue","Rarity",field); value.Value="Arco-Íris"
check(detector.info(field,classify)=="Arco-iris","reads StringValue rarity")
local lower=boss("Guardian")
lower.Attributes.rarity="Epic"
check(detector.info(lower,classify)=="Epico","reads lowercase attribute")
local nested=boss("Guardian")
local stats=object("Folder","Stats",nested)
local tier=object("StringValue","Tier",stats); tier.Value="Legendary"
check(detector.info(nested,classify)=="Lendario","reads nested rarity data")
local display=boss("Guardian"); display:FindFirstChild("Humanoid").DisplayName="Mythical Boss"
check(detector.info(display,classify)=="Mitico","reads Humanoid display name")
local loot=boss("Guardian")
local petModel=object("Model","BossPet",loot); petModel.Attributes.Rarity="Mitico"
local reward=object("TextLabel","DropReward",loot); reward.Text="Mythic Pet"
check(detector.info(loot,classify)=="Desconhecido","reward rarity cannot classify boss")
check(classify("Arco Sombrio")=="Desconhecido","plain arco is not rainbow")
check(classify("ARCO ÍRIS")=="Arco-iris","rainbow handles spaces and accents")
check(choose({})==nil,"empty spawn list")
print("PASS: "..count.." boss priority checks")
