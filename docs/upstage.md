# Upstage

## Provider overview

- **Who:** Upstage is a South Korean AI company based in Seoul, known for the **Solar** LLM family and document AI (Document Parse, OCR). Its earlier Solar models (Solar 10.7B, Solar Pro) used "depth up-scaling". The 2026 Solar 4 generation uses proprietary mixture-of-experts (MoE) models.
- **Positioning:** compact, cheap models for agentic and enterprise work. Strong English, Korean and Japanese support. On-prem deployment is available through Upstage.
- **Weights:** Solar Mini 4 / 4.5 weights are **not published**. They are API and on-prem only.
- **API:** OpenAI-compatible at `https://api.upstage.ai/v1`. On OpenRouter the only host is Upstage itself.
- **Other OpenRouter models (not requested):** `upstage/solar-pro4`, `upstage/solar-pro-4-contributor`.

### opencode / pi at the provider level
- No opencode or pi GitHub issues mention Solar or Upstage specifically. The only hit was pi's routine "Update generated models" catalog refresh (earendil-works/pi#1049). pi.dev's model directory lists `openrouter/upstage-solar-mini4`, so pi's OpenRouter catalog includes it.
- No public user reviews of Solar inside either harness turned up. Treat it as **untested territory**: run a short trial session before relying on it.

---

## `upstage/solar-mini4`: Solar Mini 4

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-09-22/23 (dated slug `solar-mini4-20260922`) |
| Architecture | MoE, **35B total / 3B active** |
| Context / max output | 524,288 (512K) / 131,072 |
| Modalities | text → text |
| Price (in / out / cache read, $/M) | **0.05 / 0.20 / 0.005**. Third-party pages call this promotional; reported list price is 0.10 / 0.40 |
| Features | tools, `tool_choice`, `parallel_tool_calls`, structured outputs, reasoning + `reasoning_effort` |
| Hosts | Upstage only (2 endpoints, both tool-capable) |

**Advertised strengths:** built for agentic use where response speed and cost matter. Upstage says it "triples" the predecessor's benchmark score with only 3B active parameters (AlphaSignal coverage). Long 512K context. Multilingual (EN/KO/JA).

**Benchmarks**
- *Vendor-reported:* 24.1 on the Artificial Analysis Intelligence Index, and 83% on AA-LCR v1.1 (long-context reasoning).
- *Independent:* OpenRouter's Artificial Analysis panel shows a Strategy & Ops Index of 21.1. Other aggregator figures vary, and one OrcaRouter screenshot showed AA listing it as "N/A".
- *Independent test:* Plotly's data-analytics exam: **21/43 (49%)** correct, versus 28/43 for Solar Pro 4.

**Reviews and tests:** mostly launch coverage and aggregators. The consistent view is a cheap, fast mid-tier small model. It clearly trails Solar Pro 4 on analytical tasks.

**opencode / pi:** no issues or reports found. It supports tools and parallel tool calls on its only host, so it should work through the OpenRouter provider in both harnesses. With 3B active parameters, expect weaker multi-step planning than the 10–25B-active models in this list.

**Verdict:** a cheap, fast long-context model for simple agent subtasks, summarization and Korean/Japanese work. Unproven as a primary coding agent.

---

## `upstage/solar-mini-4-5`: Solar Mini 4.5 (Preview)

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | **Preview 2026-11-23** (on OpenRouter 2026-11-24). GA reported for 2026-12-01 |
| Architecture | Same as Solar Mini 4: MoE, 35B total / 3B active |
| Context / max output | 524,288 / 131,072 |
| Modalities | text → text |
| Price (in / out / cache read, $/M) | **0.01 / 0.04 / 0.001** (90% preview discount). Reported list price after preview: **0.10 / 0.40 / 0.01** |
| Features | tools, parallel tool calls, structured outputs, reasoning + effort |
| Hosts | Upstage only |

**Advertised strengths:** Upstage calls it "a major step up in agentic performance" over Solar Mini 4, with no number given. The only hard spec change is a newer training cutoff: **August 2026** versus February 2026 for Solar Mini 4.

**Important timing caveat (per OrcaRouter's write-up of Upstage's changelog):**
- The direct-API preview ID `solar-mini-4-5-preview` is **retired 2026-11-30**, and the 90% discount ends that day.
- Upstage warns that specs and behaviour may change before GA, and no successor model ID had been published.
- OpenRouter's slug is `upstage/solar-mini-4-5` (no `-preview`), so it may keep working after GA. **Expect the price to jump about 10× on or around 2026-12-01.** It is currently the cheapest model in this list.

**Benchmarks:** **none published**. There is no Upstage eval table, and Artificial Analysis had not listed the preview at the time of writing.

**opencode / pi:** too new for any reports (it was one day old on OpenRouter).

**Verdict:** fine to trial during the preview window because it costs almost nothing. Don't build workflows on it until GA pricing and behaviour are confirmed.

---

## Sources
- OpenRouter API snapshot (`/api/v1/models`, `/endpoints`), 2026-11-25
- [OpenRouter: Solar Mini 4](https://openrouter.ai/upstage/solar-mini4) · [Solar Mini 4.5 vs 4 compare](https://openrouter.ai/compare/upstage/solar-mini-4-5/upstage/solar-mini4)
- [OrcaRouter: Solar Mini 4.5 Preview: Specs, Price, and the Nov 30 Cutoff](https://www.orcarouter.ai/blog/solar-mini-4-5-release) · [Solar Mini 4.5 vs Solar Mini 4](https://www.orcarouter.ai/blog/solar-mini-4-5-vs-solar-mini-4) · [Solar Mini 4 release](https://www.orcarouter.ai/sv/blog/solar-mini-4-release)
- [Plotly: Solar Pro 4 and Solar Mini 4 data-analysis benchmark](https://plotly.com/blog/upstage-solar-pro-4-solar-mini-4-plotly-data-analytics-bench/)
- [AlphaSignal: Solar Mini 4 triples its benchmark score](https://alphasignal.ai/news/upstage-s-solar-mini-4-triples-its-benchmark-score-with-3b-active-parameters)
- [Benchable: Solar Mini 4](https://benchable.ai/models/upstage/solar-mini4-20260922) · [AnotherWrapper pricing](https://anotherwrapper.com/llm-pricing/solar-mini4)
- [pi.dev model page: openrouter/upstage-solar-mini4](https://pi.dev/models/openrouter/upstage-solar-mini4)
