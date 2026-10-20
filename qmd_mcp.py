#!/usr/bin/env python3
"""Small MCP bridge exposing QMD's lexical search when embeddings are unavailable."""
from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

from mcp.server.mcpserver import MCPServer

COLLECTION = os.environ.get("QMD_COLLECTION", "sand-transcricoes")
QMD_BIN = os.environ.get("QMD_BIN", "qmd")

server = MCPServer(
    name="sand-qmd-lexical",
    version="0.1.0",
    description="Safe lexical QMD search over Sand's transcript corpus.",
    instructions="Use search_transcripts before answering questions about Sand's corpus.",
)


def run_qmd(*args: str) -> str:
    command = [QMD_BIN, *args]
    completed = subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
        timeout=60,
        env=os.environ.copy(),
    )
    if completed.returncode != 0:
        detail = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"QMD failed ({completed.returncode}): {detail}")
    return completed.stdout


@server.tool(
    name="search_transcripts",
    description=(
        "Search Sand's authorized Markdown transcripts by exact words or phrases. "
        "Returns JSON results with source file, line, title and literal snippet."
    ),
)
def search_transcripts(query: str, limit: int = 8) -> str:
    """Search the transcript collection using QMD BM25 lexical search."""
    limit = max(1, min(int(limit), 20))
    raw = run_qmd(
        "search",
        query,
        "--collection",
        COLLECTION,
        "--format",
        "json",
        "--line-numbers",
        "-n",
        str(limit),
    )
    return raw


@server.tool(
    name="get_transcript",
    description="Retrieve a transcript document or a QMD document ID with line numbers.",
)
def get_transcript(document: str) -> str:
    """Retrieve a source document after search_transcripts identifies it."""
    return run_qmd("get", document, "--line-numbers")


@server.tool(
    name="qmd_status",
    description="Return the QMD index status for the Sand transcript collection.",
)
def qmd_status() -> str:
    """Return QMD health information."""
    return run_qmd("status")


if __name__ == "__main__":
    server.run("stdio")
