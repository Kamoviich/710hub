from pathlib import Path
import subprocess, os
root=Path.cwd(); source=(root/'710Hub.lua').read_text(encoding='utf-8')
helpers=source[source.index('local function detectNovaCrystalTitle()'):source.index('local function allOwnedPets()',source.index('local function detectNovaCrystalTitle()'))]
start=source.index('task.spawn(function()\n    while SESSION.Alive and task.wait(.2) do\n        if S.AutoNovaPhoenix')
loop=source[start:source.index('task.spawn(function()',start+1)]
fixture='''local count=0
local function check(v,m) count+=1; assert(v,m) end
local own=false
local gems=10000
local success=true
local title={Text="Charged Crystal",IsA=function(_,c) return c=="TextLabel" end}
local popup={GetDescendants=function() return {title} end}
local petLabel={Text="Nova Phoenix",Parent=popup,IsA=function(_,c) return c=="TextLabel" end,FindFirstAncestor=function() return nil end}
local gui={GetDescendants=function() return {petLabel,title} end}
popup.Parent=gui
local showGui=false
local LP={}
function LP:FindFirstChildOfClass(name) if name=="PlayerGui" and showGui then return gui end end
function LP:FindFirstChild(name)
    if name=="petsFolder" then return {GetDescendants=function() return own and {{Name="Nova Phoenix"}} or {{Name="Other Pet"}} end,
        GetChildren=function() return {{GetChildren=function() return {} end}} end} end
    if name=="leaderstats" then return {FindFirstChild=function(_,key) if key=="Gems" then return {Value=gems,IsA=function(_,c) return c=="NumberValue" end} end end} end
end
''' + helpers + '''
check(not ownsNovaPhoenix(),"other pets not mistaken for target")
own=true; check(ownsNovaPhoenix(),"detects exact owned pet")
own=false
check(detectNovaCrystalTitle()==nil,"missing event window")
showGui=true; check(detectNovaCrystalTitle()=="Charged Crystal","reads title near Nova Phoenix")
showGui=false
local SESSION={Alive=true}
local S={AutoNovaPhoenix=true,NovaMaxOpens=2,NovaCrystal="Charged Crystal",HatchDelay=.45}
local HubRuntime={NovaAttempts=0,NovaStatus="",RemoteCalls=0,NovaCrystalVerified=false}
local M={canAct=function() return true end,log=function() end,reasonText=function() return "Manual" end}
local R={Crystal={}}
local opened={}
local function refreshRemotes() end
local function safeInvoke(_,action,name)
    check(action=="openCrystal","normal crystal action")
    opened[#opened+1]=name
    HubRuntime.RemoteCalls+=1
    if success then gems-=500 end
end
local waits=0
local task={spawn=function(fn) fn() end,wait=function(delay)
    if delay==.2 then waits+=1; return waits==1 end
    return true
end}
local function run()
    waits=0
''' + loop + '''
end
run()
check(#opened==0 and string.find(HubRuntime.NovaStatus,"Abra a janela",1,true),"waits for verified crystal")
showGui=true; run()
check(#opened==1 and opened[1]=="Charged Crystal","opens detected crystal")
check(HubRuntime.NovaAttempts==1 and HubRuntime.NovaCrystalVerified,"counts observed opening")
run(); run()
check(not S.AutoNovaPhoenix and #opened==2,"stops at limit")
S.AutoNovaPhoenix=true; HubRuntime.NovaAttempts=0; own=true; run()
check(not S.AutoNovaPhoenix and #opened==2,"stops when pet owned")
own=false; S.AutoNovaPhoenix=true; S.NovaCrystal="Wrong Crystal"; HubRuntime.NovaCrystalVerified=true
HubRuntime.NovaNoProgress=0; HubRuntime.NovaAttempts=0; S.NovaMaxOpens=100; success=false
for _=1,6 do run() end
check(not S.AutoNovaPhoenix and #opened==8,"stops unconfirmed requests")
print("PASS: "..count.." actual event pet checks")
'''
path=root/'_event_check.luau'
try:
    path.write_text(fixture,encoding='utf-8')
    subprocess.run([os.path.join(os.environ['TEMP'],'710hub-luau','luau.exe'),str(path)],check=True)
finally: path.unlink(missing_ok=True)
