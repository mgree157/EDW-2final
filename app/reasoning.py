from __future__ import annotations
import json
import pandas as pd
from typing import Dict, Any

from .cortex_client import cortex_complete
from .evidence import build_evidence

def simple_answer(question: str, rev: pd.DataFrame, reg: pd.DataFrame, prod: pd.DataFrame) -> str:
    """Simple path: one-shot answer using analytics as context."""
    evidence = build_evidence(rev, reg, prod)
    evidence_json = json.dumps(evidence, default=str)

    prompt = f"""You are a business data assistant answering straightforward questions.

User question:
{question}

You are given precomputed analytics as JSON:
{evidence_json}

Instructions:
- If the user asks for a specific value (e.g., revenue for a quarter or product),
  answer with that number and one short explanatory sentence.
- Do NOT describe your internal reasoning steps.
- Do NOT list a multi-step plan.
- Base your answer only on the data provided.
"""
    return cortex_complete(prompt)


def reasoning_answer(question: str, plan: Dict[str, Any], rev: pd.DataFrame, reg: pd.DataFrame, prod: pd.DataFrame) -> str:
    """Full reasoning path: multi-paragraph explanation using plan + evidence."""
    evidence = build_evidence(rev, reg, prod)
    plan_json = json.dumps(plan, default=str)
    evidence_json = json.dumps(evidence, default=str)

    prompt = f"""You are a senior business analyst supporting Honeywell's Enterprise Data Warehouse.

User question:
{question}

Planned steps (JSON):
{plan_json}

Summarized evidence from analytics (JSON):
{evidence_json}

Write a professional, concise explanation that:
- Describes what happened (trends by quarter, region, and product).
- Highlights the main drivers of any revenue changes.
- Uses only the information in the evidence; do not hallucinate extra data.
- Avoids bullet points; answer in 1–3 paragraphs of plain text.
"""
    return cortex_complete(prompt)
