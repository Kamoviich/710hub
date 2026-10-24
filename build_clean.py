"""Build the curated standalone hub, retiring the blanket source import."""
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parent
path=ROOT/'710Hub.lua'
source=path.read_text(encoding='utf-8')


def block(text,name,body,anchor=None):
    begin,end='-- BEGIN '+name,'-- END '+name
    content=begin+'\n'+body.rstrip()+'\n'+end
    if begin in text:
        left=text.index(begin);right=text.index(end)+len(end)
        return text[:left]+content+text[right:]
    assert anchor and text.count(anchor)==1, name
    return text.replace(anchor,content+'\n\n'+anchor,1)


if '-- BEGIN CLEAN UI' not in source:
    ROOT.joinpath('references/710Hub.before-clean.lua').write_text(source,encoding='utf-8')
    left=source.index('-- BEGIN SOURCE BRIDGE');right=source.index('-- END SOURCE BRIDGE')+len('-- END SOURCE BRIDGE')
    source=source[:left]+source[right:]
    source=re.sub(r'^    if HubRuntime\.SourceBridge[^\n]*\n','',source,flags=re.M)
    source=source.replace('    if S.BlockAllRebirths and remote and remote.Name == "rebirthRemote" then return false end\n','')
    source=source.replace('    if S.BlockEggEating and select(1, ...) == "proteinEgg" then return false end\n','')
    # Keep one field implementation and replace the complete old menu content.
    field_start=source.index('local function field(title, value, callback)')
    field_end=source.index('\nsection("PETS E CRISTAIS"',field_start)
    field=source[field_start:field_end]
    begin=source.index('-- conteúdo em português')
    end=source.index('-- Busca global: ignora acentos')
    source=source[:begin]+field+'\n\n-- BEGIN CLEAN UI\n-- populated below\n-- END CLEAN UI\n\n'+source[end:]
    # Remove event-specific Nova Phoenix workflow and superseded pet loops.
    a=source.index('local function detectNovaCrystalTitle()')
    b=source.index('local function allOwnedPets()',a)
    source=source[:a]+source[b:]
    a=source.index('task.spawn(function()\n    while SESSION.Alive and task.wait(.1) do\n        if M:canAct() and S.Hatch then')
    b=source.index('task.spawn(function()\n    while SESSION.Alive and task.wait(2) do\n        if M:canAct() and S.Brawl',a)
    source=source[:a]+source[b:]
    source=source.replace('    S.AutoNovaPhoenix = false\n','').replace('    HubRuntime.NovaStatus = "Parado pelo usuario"\n','')
    source=source.replace('    S.AutoEquipAfterHatch = false\n','').replace('    S.AutoEvolveAfterHatch = false\n','')
    a=source.index('    if key == "AutoNovaPhoenix" and S.AutoNovaPhoenix then')
    b=source.index('    local disabled = M:resolveConflicts(key)',a)
    source=source[:a]+source[b:]
    source=re.sub(r'^        if other == "AutoNovaPhoenix"[^\n]*\n','',source,flags=re.M)
    source=source.replace('2026.10-boss-hover.35','2026.10-clean.36')
    source=source.replace('    NovaAttempts = 0, NovaStatus = "Desligado", NovaCrystalVerified = false,\n','')
    source=source.replace('AutoNovaPhoenix=false, ','').replace('AutoEquipAfterHatch=false, AutoEvolveAfterHatch=false,\n','')
    source=source.replace('NovaCrystal="Charged Crystal", NovaMaxOpens=100, ','')
    source=source.replace('ShiftLock=false, BlockEggEating=false','ShiftLock=false')
    source=source.replace('local S = {','local S = {\n    FarmMode="Automático", PvpFilter="Todos", PetObjective="strength",\n    HatchMaxOpens=20, HatchTargetPet="",',1)
    # Cancellation and success flag for bounded crystal purchases.
    source=source.replace('local function stopAllAutomations()\n','local function stopAllAutomations()\n    if HubRuntime.Clean then HubRuntime.Clean:stopHatch() end\n',1)
    source=source.replace('    if ok then return a, b end\n    setHubError(a)\n    return nil',
        '    if ok then return a, b, true end\n    setHubError(a)\n    return nil, nil, false',1)
    source=source.replace('local function evolveReadyOwned()\n','local function evolveReadyOwned(allowed)\n',1)
    source=source.replace('    for _, entry in ipairs(allOwnedPets()) do\n        counts[entry.pet.Name]',
        '    local worn = equippedPets()\n    for _, entry in ipairs(allOwnedPets()) do\n        if not worn[entry.pet] and not entry.pet:GetAttribute("Locked") and not entry.pet:GetAttribute("Favorite") then\n        counts[entry.pet.Name]',1)
    source=source.replace('counts[entry.pet.Name] or 0) + 1\n    end\n    for name,count',
        'counts[entry.pet.Name] or 0) + 1\n        end\n    end\n    for name,count',1)
    source=source.replace('if not SESSION.Alive or not M:canAct() or (HubRuntime.Extras and HubRuntime.Extras.Token ~= token) then return false end',
        'if not SESSION.Alive or not M:canAct() or (allowed and not allowed()) or (HubRuntime.Extras and HubRuntime.Extras.Token ~= token) then return false end',1)
    # Update the pure controller schema; older removed fields are ignored.
    controller=ROOT/'Maintenance.lua'
    core=controller.read_text(encoding='utf-8')
    core=core.replace('"AutoNovaPhoenix", ','').replace('"AutoEquipAfterHatch", "AutoEvolveAfterHatch", ','')
    core=core.replace('"Spectate", "PlayerESP"','"Spectate", "ShiftLock"')
    core=core.replace('NovaMaxOpens = {1, 1000}, ','HatchMaxOpens = {1, 100}, ')
    core=core.replace('local choices = {','local choices = {\n        FarmMode={"Automático","Peso","Flexões","Abdominais","Parada de mãos","Máquina","Pedras","Esteira"},\n        PvpFilter={"Todos","Karma bom","Karma ruim","Selecionado"}, PetObjective={"strength","durability","agility"},',1)
    core=core.replace('"NovaCrystal", ','"HatchTargetPet", ')
    core=core.replace('    conflict("Hatch", "AutoNovaPhoenix")\n','')
    core=core.replace('    conflict("AutoBestPetObjective", "AutoEquipAfterHatch")\n','').replace('    conflict("AutoEvolveOwned", "AutoEvolveAfterHatch")\n','')
    core=core.replace('(key == "ShopCount" and value % 1 ~= 0)',
        '((key == "ShopCount" or key == "HatchMaxOpens") and value % 1 ~= 0)')
    # Profiles migrate removed modes before any automation can resume.
    core=core.replace('        self:normalizeConflicts()\n        self:pause("Manual", true)',
        '        settings.AutoNovaPhoenix, settings.AutoEquipAfterHatch, settings.AutoEvolveAfterHatch = false, false, false\n        self:normalizeConflicts()\n        self:pause("Manual", true)',1)
    controller.write_text(core,encoding='utf-8')

core=ROOT.joinpath('Maintenance.lua').read_text(encoding='utf-8')
source=block(source,'MAINTENANCE CORE','local M = (function()\n'+core+'\nend)()(S, os.clock)\nM:pause("Respawn", true)')
source=block(source,'EXTRA RUNTIME',ROOT.joinpath('EnhancementsRuntime.fragment.lua').read_text(encoding='utf-8'))
source=block(source,'CLEAN RUNTIME',ROOT.joinpath('CleanRuntime.fragment.lua').read_text(encoding='utf-8'),'local function initializeUI()')
source=block(source,'FAST REP RUNTIME',ROOT.joinpath('FastRepRuntime.fragment.lua').read_text(encoding='utf-8'),'local function initializeUI()')
source=block(source,'PVP RUNTIME',ROOT.joinpath('PvpRuntime.fragment.lua').read_text(encoding='utf-8'),'local function initializeUI()')
source=block(source,'CLEAN UI',ROOT.joinpath('CleanUI.fragment.lua').read_text(encoding='utf-8'))
source=block(source,'BOSS HOVER',ROOT.joinpath('BossHover.fragment.lua').read_text(encoding='utf-8'))
source=source.replace('-- Script único para Muscle Legends.','-- Menu selecionado, com rotinas nativas únicas para Muscle Legends.')
source=source.replace('-- Features: Auto Train, Auto Rebirth, Auto Chests, Auto Hatch, Pet Manager,\n-- Equip Best owned pets, teleport browser, Anti-AFK, Stop All.',
    '-- Features: treino por método, rebirth, boss invertido, PvP filtrado, pets,\n-- cristais limitados, roleta, consumíveis, perfis, navegação e Stop All.')
path.write_text(source,encoding='utf-8',newline='\n')
runtime=source.split('-- BEGIN MAINTENANCE RUNTIME\n',1)[1].split('-- END MAINTENANCE RUNTIME',1)[0]
ROOT.joinpath('MaintenanceRuntime.fragment.lua').write_text(runtime,encoding='utf-8')
print('Curated 710Hub built:',path.stat().st_size,'bytes')
