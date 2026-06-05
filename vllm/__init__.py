# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright contributors to the vLLM project
"""vLLM: a high-throughput and memory-efficient inference engine for LLMs"""

try:
    from ._version import __version__, __version_tuple__
except Exception:
    __version__ = "0.0.0"
    __version_tuple__ = (0, 0, 0)
