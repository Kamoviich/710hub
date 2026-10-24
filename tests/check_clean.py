"""Test every curated control through its actual UI and runtime effects."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import sys

sys.stdout.reconfigure(encoding='utf-8')
tests=Path(__file__).resolve().parent
root=tests.parent
cli=Path(os.environ['TEMP'])/'710hub-luau-check'
source=root.joinpath('710Hub.lua').read_text(encoding='utf-8')
subprocess.run([str(cli/'luau-compile.exe'),'--null',str(root/'710Hub.lua')],check=True)
assert '-- BEGIN SOURCE BRIDGE' not in source and 'setSourceEnvironment' not in source
source=source.replace('initializeUI()\n\nend, function(message)',
    'initializeUI()\nMock.Published={S=S,M=M,Runtime=HubRuntime,Stop=stopAllAutomations,Session=SESSION}\nend, function(message)')
source=source.replace('UI:refresh(true, false)\nend\ninitializeUI()',
    'UI:refresh(true, false)\nMock.FullUI={UI=UI,Entries=searchEntries,Main=main,Scroll=scroll,Gui=gui}\nend\ninitializeUI()')
script=tests.joinpath('roblox_mock.luau').read_text(encoding='utf-8')
script+='\n'+tests.joinpath('published_setup.luau').read_text(encoding='utf-8')
script+='\n'+tests.joinpath('clean_setup.luau').read_text(encoding='utf-8')
script+='\nlocal function startHub()\n'+source+'\nend\ntask.spawn(startHub)\n'
checks=tests.joinpath('clean_checks.luau').read_text(encoding='utf-8')
checks=checks.replace('local oldProfile=M:profile();',tests.joinpath('pvp_checks.luau').read_text(encoding='utf-8')+'\nlocal oldProfile=M:profile();',1)
script+=checks
with tempfile.TemporaryDirectory(prefix='710hub-clean-') as directory:
    target=Path(directory)/'checks.luau'; target.write_text(script,encoding='utf-8')
    run=subprocess.run([str(cli/'luau.exe'),str(target)],capture_output=True,timeout=30)
    output=(run.stdout+run.stderr).decode('utf-8',errors='replace')
    visible,_,catalog=output.partition('CLEAN_CATALOG:')
    tests.joinpath('clean-results.txt').write_text(visible,encoding='utf-8')
    if catalog.strip():
        tests.joinpath('clean-catalog.json').write_text(json.dumps(json.loads(catalog),ensure_ascii=False,indent=2),encoding='utf-8')
    print(visible); raise SystemExit(run.returncode)
