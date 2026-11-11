"""Read-only bridge: validate real Dart HTTP bodies using backend Pydantic models."""
import importlib.util
import json
import sys
import ast
from pathlib import Path
from typing import Literal, Any
from uuid import UUID
# Read the literal from the supplied backend source without importing its runtime.
if sys.argv[2] == 'client-events':
    source = ast.parse(Path(sys.argv[1]).read_text())
    declarations = [node.value for node in source.body
                    if isinstance(node, ast.Assign) and any(
                        isinstance(target, ast.Name) and target.id == 'CLIENT_EVENTS'
                        for target in node.targets)]
    if len(declarations) != 1:
        sys.exit('Expected one CLIENT_EVENTS declaration in the backend model')
    value = declarations[0]
    if not (isinstance(value, ast.Call) and isinstance(value.func, ast.Name)
            and value.func.id == 'frozenset' and len(value.args) == 1 and not value.keywords):
        sys.exit('Expected CLIENT_EVENTS = frozenset(...) in the backend model')
    events = ast.literal_eval(value.args[0])
    if not isinstance(events, (set, tuple, list)) or not all(isinstance(e, str) for e in events):
        sys.exit('Expected CLIENT_EVENTS to contain event name strings')
    print(json.dumps(sorted(events)))
    sys.exit(0)

from pydantic import BaseModel, Field, AliasChoices, AliasPath, ConfigDict

if len(sys.argv) == 4 and sys.argv[3] == 'payment':
    # Compile the actual request class, without importing route modules that
    # initialize Firebase/provider clients. No copied schema or backend writes.
    source = ast.parse(Path(sys.argv[1]).read_text())
    definition = next(node for node in source.body
                      if isinstance(node, ast.ClassDef) and node.name == sys.argv[2])
    namespace = dict(BaseModel=BaseModel, Field=Field, UUID=UUID, Literal=Literal,
                     AliasChoices=AliasChoices, AliasPath=AliasPath, Any=Any, ConfigDict=ConfigDict)
    for base in source.body:
        if isinstance(base, ast.ClassDef) and base.name == "AppleWireModel":
            exec(compile(ast.Module(body=[base], type_ignores=[]), sys.argv[1], "exec"), namespace)
    exec(compile(ast.Module(body=[definition], type_ignores=[]), sys.argv[1], 'exec'), namespace)
    body = json.load(sys.stdin)
    validated = namespace[sys.argv[2]].model_validate(body).model_dump(mode='json')
    assert validated['attempt_id'] == body['attempt_id'], 'attempt_id was discarded'
    print('valid')
    sys.exit(0)

spec = importlib.util.spec_from_file_location('gmkt22_backend_models', sys.argv[1])
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)
model = {
    'installations': module.RegistrationRequest,
    'identify': module.InstallationRequest,
    'events/batch': module.BatchRequest,
    'install-attribution': module.AttributionRequest,
}[sys.argv[2]]
model.model_validate(json.load(sys.stdin))
print('valid')
