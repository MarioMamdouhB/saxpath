from __future__ import annotations

import sys
from pathlib import Path


def _pin_service_imports() -> None:
    service_root = Path(__file__).resolve().parents[2]
    service_root_str = str(service_root)

    if service_root_str in sys.path:
        sys.path.remove(service_root_str)
    sys.path.insert(0, service_root_str)

    for module_name in list(sys.modules):
        if module_name == "app" or module_name.startswith("app."):
            del sys.modules[module_name]


_pin_service_imports()
