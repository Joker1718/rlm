---
name: RLM
description: Run a Recursive Language Model-style loop for long-context tasks. Uses a persistent local Python REPL and a sub-agent (llm_query) to process documents that exceed typical context window limits.
---

# RLM (Recursive Language Model) Workflow

**Description:** Run a Recursive Language Model-style loop for long-context tasks. Uses a persistent local Python REPL and a sub-agent (llm_query) to process documents that exceed typical context window limits.

## Overview
This skill implements the RLM pattern where a root language model orchestrates sub-LLM calls over chunks of a large document.

### Mental Model
- **Root LLM (Orchestrator):** The main model (e.g., Gemini) running this workflow.
- **External Environment:** Persistent Python REPL (`rlm_repl.py`) holding the large context.
- **Sub-LLM:** A secondary model used for chunk-level analysis.

## Usage
To trigger this skill, provide a query related to a large document.

**Input Parameters:**
- `context_file`: Path to the file containing the large context.
- `query`: The specific question or task.
- `chunk_size`: Optional (default ~200,000 chars).
- `overlap`: Optional (default 0).

## Workflow Procedure

### 1. Initialize the REPL
Run the Python script to load the context file into the persistent state.
```bash
python3 skillz/rlm/scripts/rlm_repl.py init <context_file>
python3 skillz/rlm/scripts/rlm_repl.py status
```

### 2. Scout the Context
Quickly inspect the beginning and end of the file to understand its structure.
```bash
python3 skillz/rlm/scripts/rlm_llm/scripts/rlm_repl.py exec -c "print(peek(0, 3000))"
```

### 3. Chunking Strategy
- **Semantic Chunking:** Preferred if the format allows (Markdown headers, JSON objects, log timestamps).
- **Fixed-Size Chunking:** Use character-based chunking if semantic boundaries aren't clear.

### 4. Materialize Chunks
Split the content into chunk files for parallel/serial processing.
```bash
python3 skillz/rlm/scripts/rlm_repl.py exec -c "paths = write_chunks('state/chunks', size=200000, overlap=0); print(len(paths))"
```

### 5. Sub-Agent Loop (llm_query)
For each chunk, invoke the sub-agent defined in `agents/sub_llm.md` to extract relevant information.
- **Pass:** The chunk file path + User Query.
- **Receive:** Structured JSON output.

### 6. Synthesis
Aggregate the results from the sub-agent calls into the final answer.

## Permissions
This skill requires:
- **File Read/Write:** To read context files and write state/chunks.
- **Execution:** To run the Python REPL script.

## Notes
- Ensure `rlm_repl.py` is executable (`chmod +x ...`).
- State is stored in `state/` by default (relative to where the script runs).
```
