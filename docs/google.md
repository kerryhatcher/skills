# Google (Gemma)

## Provider overview

- **Who:** Google DeepMind's **Gemma** family: open-weight models built from Gemini research, released under the Gemma Terms of Use. Gemma 3 (March 2025: 1B / 4B / 12B / 27B) added vision and 128K context. **Gemma 4** (April 2026: E2B/E4B, 26B-A4B MoE, 31B dense) added native function calling, configurable thinking, 256K context and video input.
- **Positioning:** strong, efficient open models for local and single-GPU deployment.
- **OpenRouter presence:** third-party hosts only. Google itself doesn't serve Gemma on OpenRouter. `google/gemma-4-31b-it:free` exists.

### opencode / pi at the provider level
- **Gemma 3 has no native tool-call tokens.** Function calling is prompt-based, so whether tools work depends on the host's chat template. On OpenRouter, most Gemma 3 endpoints don't advertise tools at all.
- **Gemma 4 is popular locally** (LM Studio, Ollama, llama.cpp). Most issues are local-provider issues:
  - LM Studio discovery drops reasoning capabilities (opencode#63921, open)
  - Gemma 4 thinking level on llama.cpp (pi#5721, #5917)
  - gemma-4-14b not reading `@image.jpg` (pi#5425)
- Google's *Gemini* (not Gemma) has many harness issues around thought signatures and thinking budgets (pi#10157, #10890, #10946). Those don't apply to Gemma.

---

## `google/gemma-3-4b-it`: Gemma 3 4B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-03-12/13 |
| Architecture | dense 4B, vision (SigLIP encoder), 140+ languages |
| Context / max output | 131,072 / 117,964 |
| Price (in / out / cache, $/M) | **0.04 / 0.05 / 0.02** (Parasail, DeepInfra ×3) |
| Tools | **none (0 of 4 hosts)** |

**Advertised strengths:** a small multimodal model that runs on phones and laptops, with a strong multilingual base.

**Benchmarks (vendor, 2025):** MMLU-Pro ~43.6, MATH ~75.6, LiveCodeBench ~12.6. Gemma 3 4B was reported to rival Gemma 2 27B on chat (LMArena).

**opencode / pi:** **cannot be used as an agent via OpenRouter** (no tools), and it is too small for agent loops anyway.

**Verdict:** a cheap image captioning, OCR-lite and multilingual text model. Not for coding agents.

---

## `google/gemma-3-12b-it`: Gemma 3 12B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-03-12/13 |
| Context / max output | 131,072 / **16,384** |
| Price (in / out, $/M) | **0.05 / 0.15** (host range 0.04–0.35 / 0.12–0.45) |
| Tools | **1 of 4 hosts** (a single DeepInfra endpoint) |

**Benchmarks (vendor, 2025):** MMLU-Pro ~60.6, MATH ~83.8, LiveCodeBench ~24.6, GPQA ~40.9.

**opencode / pi:** practically unusable as an agent: tool support exists only on one endpoint, and Gemma 3 tool-call reliability is low. No model-specific issues found.

**Verdict:** a cheap vision-plus-text model for classification and summarization. Not for agents.

---

## `google/gemma-3-27b-it`: Gemma 3 27B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-03-12 |
| Context / max output | 131,072 (Nebius 110K) / **16,384** |
| Price (in / out, $/M) | **0.08 / 0.16** (host range 0.064–0.12 / 0.128–0.45) |
| Tools | **3 of 6 hosts** (DeepInfra endpoints only) |

**Benchmarks (vendor, 2025):** LMArena Elo ~1338 at launch, top open non-reasoning model then. MMLU-Pro ~67.5, MATH ~89.0, LiveCodeBench ~29.7, GPQA ~42.4. **τ2-bench Retail: 6.6%**, per Google's Gemma 4 comparison, which shows how weak Gemma 3 is at agentic tool use.

**opencode / pi:** weak tool use, so a poor fit. No model-specific issues.

**Verdict:** good chat and vision quality for the price, but **not an agent model**. Use Gemma 4 31B instead.

---

## `google/gemma-4-31b-it`: Gemma 4 31B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-04-02 |
| Architecture | dense 30.7B, multimodal (text + image; video listed), configurable thinking, native function calling |
| Context / max output | 262,144 (some hosts 131K) / **16,384** |
| Modalities | image + text + video → text |
| Price (in / out, $/M) | **0.20 / 0.40** headline. **Cheaper hosts: KT and CoreWeave 0.10/0.34, Venice and Chutes 0.12/0.36.** **`:free` variant available** |
| Tools / reasoning | 16 of 18 hosts / yes |

**Advertised strengths:** frontier-class open model for its size, with native function calling, structured JSON output, system instructions and a thinking mode. Google claims it beats much larger open models.

**Benchmarks**
- *Vendor:* τ2-bench Retail **86.4%** (vs 6.6% for Gemma 3 27B); LiveCodeBench v6 **80.0%**; Codeforces Elo ~2,150 (blog-reported).
- *Independent (Artificial Analysis):* Intelligence Index **39**, trailing Qwen3.5 27B (Reasoning) at 42, "primarily due to weaker agentic performance". It leads on SciCode (43% vs 40%) and TerminalBench Hard (36% vs 33%).
- Reviewers note there is no measurement of multi-file or 30+ turn coding sessions.

**opencode / pi**
- *opencode:* **"'Code Mode' instructions are confusing Gemma-4-31B"** (anomalyco/opencode#53623, closed). opencode's codemode (MCP tools behind an `execute` meta-tool) confused the model. If you see it calling tools oddly, disable codemode for MCP servers (see also #58476, open). Tool calls fail when assistant content is null (#51661, open). Local models create files with trailing whitespace in names because filePath wasn't trimmed (#43112, fixed).
- *pi:* Gemma 4 reasoning-level and llama.cpp thinking toggles (pi#5721, #5917). Mostly local issues.
- **The 16K max output** is low for agents that write large files in one tool call.

**Verdict:** the best Google option for agents in this list. It handles tool use reasonably and costs nothing on the `:free` tier, but it is still mid-tier for long coding sessions. Pin a 0.10/0.34 host and disable opencode codemode if it misbehaves.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- Google: Gemma 3 technical report (2025-03); [Gemma 4 page](https://deepmind.google/models/gemma/gemma-4/); [Gemma 4 Technical Report](https://huggingface.co/papers/2607.02770.md)
- [Artificial Analysis: Gemma 4 everything you need to know](https://artificialanalysis.ai/ja/articles/gemma-4-everything-you-need-to-know) · [Verdent: Gemma 4 coding agent review](https://verdent.ai/guides/gemma-4-coding-agent-review) · [dev.to: Gemma 4 for AI agents](https://dev.to/max_quimby/gemma-4-for-ai-agents-googles-best-open-model-review-2026-4f0n) · [StartupHub review](https://www.startuphub.ai/news/google-gemma-4-review-2026)
- opencode issues: [#53623](https://github.com/anomalyco/opencode/issues/53623), [#58476](https://github.com/anomalyco/opencode/issues/58476), [#51661](https://github.com/anomalyco/opencode/issues/51661), [#43112](https://github.com/anomalyco/opencode/issues/43112), [#63921](https://github.com/anomalyco/opencode/issues/63921)
- pi issues: [#5721](https://github.com/earendil-works/pi/issues/5721), [#5917](https://github.com/earendil-works/pi/issues/5917), [#5425](https://github.com/earendil-works/pi/issues/5425), [#10157](https://github.com/earendil-works/pi/issues/10157)
