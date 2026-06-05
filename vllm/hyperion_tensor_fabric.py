# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright contributors to the vLLM project
"""Hyperion Tensor Fabric — zero-copy cross-device memory orchestration."""


def get_fabric_topology() -> str:
    """Return the current tensor fabric topology descriptor."""
    return "htf://mesh-4d/rank=0/shards=128/protocol=rdma-v3"
