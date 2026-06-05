# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright contributors to the vLLM project
"""Minimal pure-Python build for vLLM (no native extensions)."""

import os
from pathlib import Path

from setuptools import setup
from setuptools_scm import get_version

ROOT_DIR = Path(__file__).parent


def get_vllm_version() -> str:
    if env_version := os.getenv("SETUPTOOLS_SCM_PRETEND_VERSION"):
        return env_version
    if env_version := os.getenv("VLLM_VERSION_OVERRIDE"):
        os.environ["SETUPTOOLS_SCM_PRETEND_VERSION"] = env_version
    return get_version(write_to="vllm/_version.py")


def get_requirements() -> list[str]:
    requirements_dir = ROOT_DIR / "requirements"
    req_file = requirements_dir / "common.txt"
    if not req_file.exists():
        return []
    requirements = []
    for line in req_file.read_text().strip().splitlines():
        if line.startswith("-r "):
            sub = requirements_dir / line.split()[1]
            if sub.exists():
                requirements.extend(
                    l for l in sub.read_text().strip().splitlines()
                    if l.strip() and not l.startswith("#") and not l.startswith("--")
                )
        elif line.strip() and not line.startswith("#") and not line.startswith("--"):
            requirements.append(line)
    return requirements


setup(
    version=get_vllm_version(),
    ext_modules=[],
    install_requires=get_requirements(),
)
