from __future__ import annotations

import shutil
import sys
from collections.abc import Iterator
from pathlib import Path
from uuid import uuid4

import pytest


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


@pytest.fixture
def isolated_service_dir() -> Iterator[Path]:
    service_root = Path(__file__).resolve().parents[2]
    temp_root = service_root / ".tmp-tests"
    temp_root.mkdir(exist_ok=True)
    case_dir = temp_root / f"api-case-{uuid4().hex}"
    case_dir.mkdir()

    try:
        yield case_dir
    finally:
        shutil.rmtree(case_dir, ignore_errors=True)
