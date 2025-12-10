def classify_question(q: str) -> str:
    """Heuristic router: simple vs reasoning."""
    lower = (q or "").lower()
    reasoning_keywords = ["why", "cause", "reason", "driver", "explain", "because"]

    if any(k in lower for k in reasoning_keywords):
        return "reasoning"

    return "simple"
