from pathlib import Path
import subprocess, os
root=Path.cwd(); source=(root/'710Hub.lua').read_text(encoding='utf-8')
owned=source[source.index('local function ownsNovaPhoenix()'):source.index('local function allOwnedPets()',source.index('local function ownsNovaPhoenix()'))]
start=source.index('task.spawn(function()\n    while SESSION.Alive and task.wait(.2) do\n        if S.AutoNovaPhoenix')
loop=source[start:source.index('task.spawn(function()',start+1)]
fixture='''local count=0
local function check(v,m) count+=1; assert(v,m) end
local own=false
local LP={FindFirstChild=function(_,name)
    if name~="petsFolder" then return nil end
    return {GetDescendants=function() return own and {{Name="Nova Phoenix"}} or {{Name="Other Pet"}} end}
end}
''' + owned + '''
check(not ownsNovaPhoenix(),"other pets not mistaken for target")
own=true; check(ownsNovaPhoenix(),"detects exact owned pet")
own=false
local SESSION={Alive=true}
local S={AutoNovaPhoenix=true,NovaMaxOpens=2,NovaCrystal="Charged Crystal",HatchDelay=.45}
local HubRuntime={NovaAttempts=0,NovaStatus="",RemoteCalls=0}
local M={canAct=function() return true end,log=function() end}
local R={Crystal={}}
local opened={}
local function safeInvoke(_,action,name)
    check(action=="openCrystal","normal crystal action")
    opened[#opened+1]=name
    HubRuntime.RemoteCalls+=1
end
local waits=0
local task={spawn=function(fn) fn() end,wait=function()
    waits+=1
    return waits==1
end}
local function run()
    waits=0
''' + loop + '''
end
run()
check(#opened==1 and opened[1]=="Charged Crystal","opens only selected crystal")
check(HubRuntime.NovaAttempts==1 and S.AutoNovaPhoenix,"counts sent request")
run()
check(HubRuntime.NovaAttempts==2 and #opened==2,"second request at limit")
run()
check(not S.AutoNovaPhoenix and #opened==2,"stops at limit")
S.AutoNovaPhoenix=true; HubRuntime.NovaAttempts=0; own=true; run()
check(not S.AutoNovaPhoenix and #opened==2,"stops when pet owned")
own=false; S.AutoNovaPhoenix=true; S.NovaCrystal="  "; run()
check(not S.AutoNovaPhoenix and #opened==2,"blank crystal cannot spend")
print("PASS: "..count.." actual event pet checks")
'''
path=root/'_event_check.luau'
try:
    path.write_text(fixture,encoding='utf-8')
    subprocess.run([os.path.join(os.environ['TEMP'],'710hub-luau','luau.exe'),str(path)],check=True)
finally: path.unlink(missing_ok=True)
