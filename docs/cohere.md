# Cohere

## Provider overview

- **Who:** Cohere, an enterprise-focused AI company based in Toronto. It makes the **Command** family (Command R, R+, R7B, A), **Embed** and **Rerank** models, and the **Aya** multilingual research models (through Cohere Labs, formerly Cohere For AI).
- **Positioning:** enterprise RAG, tool use, grounded generation with citations, multilingual support, and private or on-prem deployment.
- **Weights:** Command R-series weights are on Hugging Face under **CC-BY-NC 4.0** (non-commercial). Commercial use requires Cohere's API or a licence.

### opencode / pi at the provider level
- Few Cohere-specific issues. In opencode, a Cohere *route* rejects image MIME types with uppercase letters (anomalyco/opencode#58937, open). Cohere also appears as an OpenRouter **host** for other models (DeepSeek V4.1 Flash, GLM 5.3), so some "Cohere" hits concern hosting, not Command models.
- pi has no built-in Cohere provider. Use it via OpenRouter.

---

## `cohere/command-r7b-12-2024`: Command R7B (12-2024)

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2024-12-13/14 |
| Architecture | dense 7B, CC-BY-NC weights (`CohereLabs/c4ai-command-r7b-12-2024`) |
| Context / max output | 128,000 / **4,000** |
| Modalities | text → text |
| Price (in / out, $/M) | **0.0375 / 0.15** (Cohere only) |
| Features | tools, structured outputs. **No reasoning parameter**, and no logprobs on OpenRouter |

**Advertised strengths:** the smallest and fastest Command R model, built for **RAG with inline citations**, tool use and agents on commodity GPUs or edge devices. Multilingual (23 languages). Cohere positioned it as best-in-class among roughly 7B open models on the Hugging Face Open LLM Leaderboard at release.

**Benchmarks (vendor, Dec 2024):** led similarly sized open models (Gemma 2 9B, Llama 3.1 8B, Ministral 8B) on Cohere's averaged Open LLM Leaderboard tasks. Strong on BFCL-style function calling and on RAG and citation evals. These figures are now 2 years old.

**opencode / pi:** no model-specific reports. Practical blockers:
- The **4K max output** is too small for agents that write files in one tool call.
- 7B dense, from 2024: too weak for multi-step coding loops.
- Command's tool-calling format is tuned for Cohere's RAG/agent API conventions and has seen little use with opencode/pi tool schemas.

**Verdict:** still a reasonable cheap **RAG and citation** model, for example in a retrieval pipeline. **Not suitable for opencode or pi.**

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- Cohere blog: "Introducing Command R7B" (2024-12) and HF model card `CohereLabs/c4ai-command-r7b-12-2024`
- opencode issue: [#58937](https://github.com/anomalyco/opencode/issues/58937)
