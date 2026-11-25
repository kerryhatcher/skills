# inclusionAI (Ant Group)

## Provider overview

- **Who:** inclusionAI is the open-model research arm of **Ant Group** (Alipay's parent). It publishes the **Ling** (non-reasoning / hybrid) and **Ring** (reasoning) families, plus multimodal variants (Ling-VL) and small models (Ling Tiny).
- **Positioning:** large sparse MoE models with very few active parameters, tuned for token efficiency and production-scale agentic inference. Weights are usually released on Hugging Face (`inclusionAI/*`), but licensing for 3.1 is reported inconsistently (MIT versus API-only at launch).
- **Hosting:** the first-party host on OpenRouter is **Ant Digital**. DeepInfra also serves Ling 3.0 Flash. A newer `inclusionai/ling-3.2-flash:free` already exists on OpenRouter.

### opencode / pi at the provider level
- **pi** has a built-in `ant-ling` provider. Open issues track migrating it to the Ling 3.x Flash models and switching to **DeepSeek-compatible reasoning** fields (earendil-works/pi#12201 **open**, #11999, #11116). Until that lands, Ling reasoning through pi's native provider may be mishandled. **Using Ling via OpenRouter avoids that provider.**
- **opencode:** Ling models were offered free through OpenCode Zen. Reports include "OpenCode Zen Ling models return 'Model is unavailable'" (anomalyco/opencode#54143), `opencode/ling-3.0-flash-fin-free` returning 404 (#51915), and free Zen models with `reasoning=true` showing zero thinking variants (#49013). These are Zen gateway issues, not OpenRouter issues.

---

## `inclusionai/ling-3.0-flash`: Ling 3.0 Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-07-23 (OpenRouter). Artificial Analysis lists 2026-08-04 |
| Architecture | MoE, **124B total / ~5.1B active** (`inclusionAI/Ling-3.0-flash`, open weights) |
| Context / max output | 262,144 / 32,768 (DeepInfra: 131K) |
| Price (in / out / cache, $/M) | **0.021 / 0.063 / 0.0042** (Ant Digital, fp8). DeepInfra (fp4) is 0.06/0.18 |
| Tools | yes (both hosts) |

**Advertised strengths:** "token efficiency and production-scale agentic inference"; matches or beats its predecessor (vendor claim).

**Benchmarks**
- *Independent (Artificial Analysis, via OpenRouter):* GPQA Diamond 85.5%, HLE 23.7%, AA-LCR 73.0%, Terminal-Bench 2.1 55.4%. The Intelligence Index is reported as **38** on one AA page and 20.1 on another, so check the current index version.
- *Speed:* about 332 tok/s (AA).
- **Verbosity counter-signal:** AA measured **240M output tokens** to run its index, against a 57M median. That makes it very wordy despite the "token efficient" marketing, so the low output price matters less than it looks.
- AA marks it **deprecated** in favour of Ling 3.1 Flash.

**opencode / pi:** issues relate only to Zen free-tier routing (above). No OpenRouter-specific failures found.

**Verdict:** extremely cheap with a respectable benchmark profile. It suits bulk and subagent tasks where verbosity doesn't matter. The 32K max output and deprecated status argue for Ling 3.1 Flash, or the free 3.2 Flash, instead.

---

## `inclusionai/ling-3.1-flash`: Ling 3.1 Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-10-02 (other sources say 2026-09-30 or 10-01) |
| Architecture | hybrid-linear-attention reasoning MoE, **560B total / 25B active** |
| Context / max output | 1,048,576 / 262,144. Some aggregators still list 262K |
| Price (in / out / cache, $/M) | **0.075 / 0.225 / 0.015** (Ant Digital only). AA lists 0.30/0.90 for the direct API |
| Tools | yes |
| Licence | conflicting reports: MIT (AA), proprietary (ApX), "API-only at launch, weights not yet on HF" (llm-stats) |

**Advertised strengths (vendor):** agentic and coding. inclusionAI reports strong results on Terminal-Bench 4.0, SWE-bench Pro, FrontierSWE, GDPVal-AA v2.1, AutomationBench, MCP-Atlas and SkillsBench, but secondary coverage didn't reproduce the actual numbers.

**Benchmarks**
- *Independent (Artificial Analysis):* Intelligence Index **41**, well above the median for its price class (19). About **219 tok/s**.
- No independent per-benchmark coding results found.

**Reviews:** MindStudio's overview is positive about capability per dollar. No hands-on agentic reviews found.

**opencode / pi:** no OpenRouter-specific reports. pi's native `ant-ling` provider is being migrated to Ling 3.x with DeepSeek-style reasoning (earendil-works/pi#12201, open). Use OpenRouter or a custom OpenAI-compatible entry in the meantime.

**Verdict:** one of the stronger cheap options here (AA 41 at 0.075/0.225, 1M context, 25B active). It's worth trialling as an opencode/pi workhorse. The thin independent evidence and single host are the main risks.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- [Artificial Analysis: Ling 3.0 Flash](https://artificialanalysis.ai/models/releases/ling-3-0-flash) · [AA (zh) verbosity note](https://artificialanalysis.ai/zh/models/ling-3-0-flash) · [AA: Ling 3.1 Flash](https://artificialanalysis.ai/models/ling-3-1-flash)
- [MindStudio: Ling 3.1 Flash](https://www.mindstudio.ai/blog/ling-3-1-flash-inclusionai/) · [llm-stats](https://llm-stats.com/models/ling-3.1-flash) · [ApX](https://apxml.com/models/ling-3-1-flash) · [Vercel AI Gateway: Ling 3.0 Flash](https://vercel.com/ai-gateway/models/ling-3.0-flash) · [DeepInfra](https://deepinfra.com/inclusionAI/Ling-3.0-flash)
- pi issues: [#12201](https://github.com/earendil-works/pi/issues/12201), [#11999](https://github.com/earendil-works/pi/issues/11999), [#11116](https://github.com/earendil-works/pi/issues/11116)
- opencode issues: [#54143](https://github.com/anomalyco/opencode/issues/54143), [#51915](https://github.com/anomalyco/opencode/issues/51915), [#49013](https://github.com/anomalyco/opencode/issues/49013)
