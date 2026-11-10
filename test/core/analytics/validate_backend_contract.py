"""Read-only bridge: validate real Dart HTTP bodies using backend Pydantic models."""
import importlib.util
import json
import sys
import ast
from pathlib import Path
from typing import Literal, Any
from uuid import UUID
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
