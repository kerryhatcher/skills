# Meta

## Provider overview

- **Who:** Meta Platforms. It published the open-weight **Llama** family (Llama 2/3/3.1/3.2/3.3/4) under the Llama Community License, then launched the **Muse** family in 2026 (Muse Spark, Muse Glimmer, Muse Ember, Muse Wonder). Muse models are mostly proprietary and served through Meta's own Model API, with a separate open-weight `muse-spark-open` release.
- **Two OpenRouter author slugs:** `meta-llama/*` for the Llama open-weight models, served by third-party hosts, and `meta/*` for the Muse models, served by Meta.
- **Muse "Contributor" tier:** a much cheaper tier in exchange for **Meta training on your prompts and outputs**. It is the default model in Meta's Muse Code tool.

### opencode / pi at the provider level
- Llama 3.x models are not used for agentic coding in practice. Issue hits are about Ollama/llama.cpp setup, not the models.
- **Muse Spark is used heavily** in both harnesses, partly because opencode Zen and Go offered a free Muse Spark Contributor tier. That also produced the most Muse-specific integration bugs (listed below).

---

## `meta-llama/llama-3.1-8b-instruct`: Llama 3.1 8B Instruct

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2024-07-23 |
| Architecture | Dense 8B, Llama 3.1 Community License |
| Context / max output | 131,072 / 117,964 |
| Price (in / out, $/M) | **0.05 / 0.08** (host range 0.02–0.22 / 0.04–0.22) |
| Tools | **3 of 4** hosts (Groq, Bedrock, CoreWeave). The cheapest host, DeepInfra at 0.02/0.04, has **no tools** |

**Advertised strengths:** fast, cheap, multilingual (8 languages), 128K context, and native tool-use format (`ipython` role and JSON function calling). It has a huge fine-tuning ecosystem.

**Benchmarks (vendor, 2024):** MMLU 69.4 (CoT 73.0), HumanEval 72.6, GSM8K 84.5, BFCL 76.1. These numbers are dated: Qwen3.5-9B and Nemotron 3 Nano beat it across the board.

**opencode / pi:** no model-specific issues. Users report that 8B-class models of this generation struggle with opencode/pi tool schemas: they hallucinate tool names, print JSON instead of calling tools, or return file contents in chat. Similar reports exist for other small models: anomalyco/opencode#29757 and earendil-works/pi#10540, #5387.

**Verdict:** a commodity cheap model for classification, extraction and simple chat. **Not suitable for coding agents.** On Groq it is extremely fast.

---

## `meta-llama/llama-3.2-3b-instruct`: Llama 3.2 3B Instruct

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2024-09-25 |
| Architecture | Dense 3.2B, Llama 3.2 Community License |
| Context / max output | 131,072 / 117,964 |
| Price (in / out, $/M) | **0.05 / 0.33** (single host: Parasail, bf16). The output price is unusually high for a 3B model |
| Tools | **None**: the only OpenRouter endpoint has no tool support |

**Advertised strengths:** on-device and edge use, summarization, instruction following and rewriting. Multilingual.

**Benchmarks (vendor, 2024):** MMLU 63.4, IFEval 77.4, GSM8K 77.7, BFCL v2 67.0.

**opencode / pi:** **cannot drive either harness** through OpenRouter, because there is no tool-calling endpoint. Even with tools, it is too small for multi-step agent work.

**Verdict:** you can find better 3B models (Qwen3.5 small models, Gemma 3/4) for less. Its output price makes it poor value even for chat.

---

## `meta/muse-spark-1.3-contributor`: Muse Spark 1.3 Contributor

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-09-02 (Muse Spark 1.3) |
| Architecture | Proprietary multimodal reasoning model. The Contributor tier is the same model family at a data-sharing price |
| Context / max output | 1,048,576 / 943,718 |
| Modalities | text + image + video + file → text |
| Price (in / out / cache read, $/M) | **0.10 / 0.20 / 0.002**, plus web search at $0.0025/request. The standard (non-contributor) `meta/muse-spark-1.3` is **1.25 / 4.25** |
| Features | tools, reasoning with effort levels (up to `max`), structured outputs |
| Hosts | Meta only |
| **Data use** | **The Contributor tier trains on your prompts and code.** Don't use it on proprietary code unless that is acceptable to you |

**Advertised strengths:** agentic, multi-agent and coding workflows, multimodal input (including video and files), and a 1M context window. Meta positions the Contributor tier for "experimentation, learning and early-stage" work.

**Benchmarks**
- *Vendor (Meta), max effort:* DeepSWE v1.1 **75.4** (versus 73.0 GPT-5.6 Sol and 74.0 Claude Opus 5). It leads Meta's three coding benchmarks and ties GPT-5.6 Sol on Terminal-Bench 2.1. On agent benchmarks it lands between GPT-5.6 Sol and Opus 5: Opus 5 (max) wins GDPVal, JobBench, OSWorld and AutomationBench, and GPT-5.6 Sol wins DeepSearchQA and Agentic IF.
- *Independent:* Artificial Analysis ranked it **third** on its index at launch (2026-09-02 article).
- *Hands-on tests are mixed.* MindStudio found strong benchmark scores didn't translate into a game-building test. A VulcanBench-style test reported **14 of 23** tasks passed, with no effort setting matching the full-task completion of top proprietary models. TechRepublic's headline: "Independent Tests Are More Mixed". The max-effort scores rely on many more turns and reasoning tokens.

**opencode / pi: many integration reports, because Zen and Go offered it free**
- *pi:*
  - `thinking=max` on OpenRouter gave a **400 `invalid_request_error`** from Meta. It works at `high` (earendil-works/pi#9658, closed). **Use `high` via OpenRouter unless your pi version is recent.**
  - Its max think level was missing from pi's opencode catalog (#10155), and the xhigh/max `thinkingLevelMap` was missing for opencode-go (#9885). Both are fixed.
  - On the opencode free tier, same-model replay of `encrypted_content` was rejected on turn 2 (#9634).
  - Intermediate assistant text before a tool call was not displayed (#9451).
  - Cache misses on Muse Spark 1.2 Contributor (#8362).
- *opencode:*
  - "Critical errors on Muse Spark family when model receives an image / does a tool call" via Zen (anomalyco/opencode#48741, **open**).
  - Simultaneous `encrypted_content` 400s across sessions invalidated continuations server-side (#50411).
  - Meta's API requires recursive `$ref` tool schemas to be sanitized (#48151, open).
  - A RegionError on the free Contributor tier (#53069).
  - Providers that accept only `tool_choice: "auto"` fail when opencode forces tool choice (#45953, open; this affects Meta).

**Verdict:** very capable for the price (0.10/0.20 is among the lowest output prices for a frontier-adjacent model). The data-sharing condition and the list of reasoning-replay and image-handling bugs make it **good for open-source and experimental work, not for private code**. Use reasoning effort `high` rather than `max` through OpenRouter.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- Meta Llama 3.1 / 3.2 model cards (Hugging Face `meta-llama/*`)
- [eesel: Muse Spark 1.3 benchmarks](https://www.eesel.ai/blog/muse-spark-1-3) · [eesel review](https://www.eesel.ai/blog/meta-muse-spark-13-review) · [DataCamp](https://www.datacamp.com/blog/muse-spark-1-3) · [TechRepublic](https://techrepublic.com/article/news-meta-muse-spark-1-3-ai-coding-2026/) · [MindStudio: benchmark confusion](https://www.mindstudio.ai/blog/meta-muse-spark-1-3-benchmark-confusion) · [RuntimeWire 14/23](https://runtimewire.com/article/meta-s-muse-spark-1-3-gets-faster-when-pushed-harder-still-passes-just-14-of-23-) · [Artificial Analysis](https://artificialanalysis.ai/articles/muse-spark-1-3) · [Meta evaluation methodology](https://research.meta.ai/static/muse-spark-1-3-multimodal-evaluation-methodology)
- pi issues: [#9658](https://github.com/earendil-works/pi/issues/9658), [#10155](https://github.com/earendil-works/pi/issues/10155), [#9885](https://github.com/earendil-works/pi/issues/9885), [#9634](https://github.com/earendil-works/pi/issues/9634), [#9451](https://github.com/earendil-works/pi/issues/9451), [#8362](https://github.com/earendil-works/pi/issues/8362), [#10540](https://github.com/earendil-works/pi/issues/10540), [#5387](https://github.com/earendil-works/pi/issues/5387)
- opencode issues: [#48741](https://github.com/anomalyco/opencode/issues/48741), [#50411](https://github.com/anomalyco/opencode/issues/50411), [#48151](https://github.com/anomalyco/opencode/issues/48151), [#53069](https://github.com/anomalyco/opencode/issues/53069), [#45953](https://github.com/anomalyco/opencode/issues/45953), [#29757](https://github.com/anomalyco/opencode/issues/29757)
