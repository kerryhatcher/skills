# Z.ai (Zhipu AI)

## Provider overview

- **Who:** Z.ai, the international brand of **Zhipu AI**, a Beijing lab spun out of Tsinghua University. It makes the **GLM** family. Most GLM releases ship open weights under the **MIT licence** (GLM-4.5, 4.6, 4.7, 5.x), sometimes after a delay; GLM-5.3's weights were held back about two weeks for cybersecurity hardening.
- **Positioning:** agentic coding. Z.ai sells a **GLM Coding Plan** subscription aimed at Claude Code, opencode, pi and similar harnesses, and runs its own ZCode tool. "Flash" models are the cheap, fast tier.
- **OpenRouter presence:** GLM 5.3 and 5.3 Flash have **40+ hosts each**, many at fp4. GLM 4.7 Flash has a single host (Cloudflare).

### opencode / pi at the provider level
GLM is heavily used in both harnesses (Coding Plan, opencode Go, OpenRouter). Recurring themes:
- **Forced thinking:** GLM 5.3 and 5.3 Flash have **mandatory reasoning** (OpenRouter `reasoning.mandatory: true`; supported efforts `max/high/low`; **default `max`**).
  - pi's zai thinking handler sent `disabled` for forced-thinking models, **leaking reasoning into the output** (earendil-works/pi#8706, fixed).
  - opencode's `reasoningToggle()` returned `{}` for openai-compatible GLM (anomalyco/opencode#42793, fixed).
- **Provider-dependent quality:** "GLM-5.3 degenerates and loops with Mistral as provider" (pi#11105). Mistral GLM streams `delta.content` as arrays, rendered as `[object Object]` spam (pi#11916, fixed). Mistral-family tool-call ID normalization collapses GLM IDs and causes duplicate-ID 400s (opencode#58323, open). **Through OpenRouter, avoid the Mistral host for GLM, or exclude it with `provider.ignore`.**
- **Stream termination:** with the Z.AI openai-compatible provider, `opencode run` streams end without `finish_reason` (#55124, open; interactive sessions are unaffected).
- **Attachments:** a PDF attachment bricks the session on GLM models (opencode#53809, open).
- **Language mixing:** stray CJK glyphs occasionally slip into non-English answers (opencode#57844).
- **Catalog churn:** the Coding Plan now only serves GLM-5.3 and 5.3-Flash, but pi's catalog listed legacy models (pi#9616), and the defaults referenced a removed model (pi#8096). Both are fixed.

---

## `z-ai/glm-4.7-flash`: GLM 4.7 Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-01-19 |
| Architecture | MoE, **~30B total / ~3B active**, MIT (`zai-org/GLM-4.7-Flash`) |
| Context / max output | 131,072 / 117,964 |
| Price (in / out, $/M) | **0.0605 / 0.40** (Cloudflare Workers AI only) |
| Tools / reasoning | yes / yes |

**Advertised strengths:** "30B-class SOTA", optimized for agentic coding, long-horizon task planning and tool collaboration. Easy to run locally.

**Benchmarks (vendor, Jan 2026):** SWE-bench Verified about 59, τ²-Bench about 79.5, BrowseComp about 42.8. At release it was the best in class against Qwen3-30B-A3B-Thinking and gpt-oss-20b on Z.ai's tables.

**opencode / pi**
- *pi:* "incorrect tool call arguments when using GLM-4.7-Flash hosted by LM Studio" (earendil-works/pi#918). `edit` tool validation failures where oldText/newText weren't strings (#1259). "Error: terminated" with glm-4.7 from z.ai (#845). All are from early 2026 and fixed.
- *opencode:* the reasoning toggle returned `{}` (#42793, fixed).
- Its only OpenRouter host is **Cloudflare Workers AI**, which has separate tool-call bugs: opencode#55936 (null content on tool turns, fixed), pi#12194 (intermittent 400s).

**Verdict:** superseded by GLM 5.3 Flash (`~z-ai/glm-flash-latest`), which is cheaper at the headline price, far stronger, and has 1M context. Only worth it to match a local GLM-4.7-Flash deployment.

---

## `~z-ai/glm-flash-latest` → `z-ai/glm-5.3-flash`: GLM 5.3 Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Alias target | `z-ai/glm-5.3-flash`, released 2026-08-26 (Epoch says 08-20). The alias always follows the newest GLM Flash |
| Architecture | multimodal MoE, **320B total / 18B active**, MIT weights on day one |
| Context / max output | 1,048,576 / 131,072 |
| Modalities | text + image + video → text |
| Price (in / out / cache, $/M) | Alias headline **0.0356 / 0.0815 / 0.03**. That is the cheapest host (Relace, fp4). Host median ≈ 0.13 / 0.50; Z.AI first-party 0.15 / 0.50. `:batch` 0.023/0.068 |
| Tools / reasoning | yes (42/42 hosts) / **mandatory**, default effort `max` |

**Advertised strengths:** a cheap sibling of GLM-5.3 for coding and agents. Z.ai claims flagship-like results at a fraction of the cost.

**Benchmarks**
- *Vendor:* DeepSWE v1.1 **63.4** (GLM-5.2: 46.2); Toolathlon Verified **78.4** (vs Claude Opus 4.8 76.2, GPT-5.6 Terra 74.9); Terminal-Bench 2.1 **84.3** (Opus 4.8 85.0, GPT-5.6 Terra 87.4).
- *Independent:* Artificial Analysis Intelligence Index **57** (GLM-5.3: 60). Epoch AI ECI rank #41 of 249. Statistically tied with GLM-5.3 on GDPval-AA v2 at about one-ninth of the eval cost.
- *Speed:* about 49 tok/s (vs about 86 for GLM-5.3), which is fairly slow.
- **The New Stack:** "benchmarks don't support early hype" comparing it to Anthropic's top model. It **uses far more tokens on hard tasks**, so the cost advantage depends on per-token price staying low.

**opencode / pi**
- Popular on the GLM Coding Plan and opencode Go. Issues include `glm-5.3-flash-free` listed as free on Zen but failing with "Endpoint is unavailable" (opencode#56796), being dropped from the ollama-cloud model cache because of an unmapped family (#45568), and a request for stable `glm-flash-latest` and `deepseek-flash-latest` routing aliases in opencode (#52403).
- *pi:* forced-thinking leak (pi#8706, fixed). `glm-5.3-flashx` was added to the catalog (#11884).
- **Practical tip:** with default effort `max`, reasoning tokens dominate output spend. Set reasoning effort to `low` or `high` in your harness, and sort by price or pin a good host. Hosts range from fp4 to fp8 and quality varies.

**Verdict:** **one of the two best value picks in this list for opencode/pi.** It is strong on agentic coding, has 1M context, and is extremely cheap on the right host. The costs are slow output and heavy reasoning tokens.

---

## `~z-ai/glm-latest` → `z-ai/glm-5.3`: GLM 5.3

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Alias target | `z-ai/glm-5.3`, released mid-August 2026 (TechNode: launch around 2026-08-14/17) |
| Architecture | MoE, reuses the GLM-5.2 base with gains from post-training. Parameter count reported inconsistently (355B per VentureBeat, 743B per Decrypt). Weights released after a two-week safety delay |
| Context / max output | 1,048,576 / 943,718 |
| Price (in / out / cache, $/M) | Alias headline **0.0699 / 1.40 / 0.0689** (Wafer fp4). **Host median ≈ 1.2 / 4.4; Z.AI first-party 1.40 / 4.40.** `:batch` 0.28/1.25 |
| Tools / reasoning | yes (48/48) / **mandatory**, default `max` |

**Advertised strengths:** Z.ai calls it "the top open-weight coding model", claiming a **50% gain on Z.ai Code Bench** over GLM-5.2. It also emphasizes cybersecurity capability.

**Benchmarks**
- *Vendor:* CyberGym **84.5%** (leads). Beats several frontier models on KingBench 3. Close on Terminal-Bench 2.1.
- *Independent:* roughly ties Kimi K3 (the open-weights leader) on the Artificial Analysis index, at **about 60**. GPT-5.6 Sol and Fable 5 remain stronger on hard long-horizon coding and exploitation. It trails Anthropic's flagship on two of three cyber benchmarks (DeepLearning.AI).

**opencode / pi:** shares the GLM issues listed above. In particular, it **degenerates and loops on the Mistral host** (pi#11105). Bedrock GLM-5.3 reasoning-effort support was added in pi (#11354). It is also available through Z.ai's Coding Plan in both harnesses.

**Price note:** this is the most expensive model in this list for output. The alias headline (0.07 / 1.40) only applies on the cheapest fp4 host, and typical routing costs about 3× more.

**Verdict:** frontier-adjacent open-weight coding model and the strongest coder here besides Haiku 5.5 / GPT-6 Luna. Pick it when quality matters more than cost. For subscription use, the GLM Coding Plan is usually cheaper than per-token OpenRouter.

---

## Sources
- OpenRouter API snapshot, 2026-11-25 (alias targets from `alias_target` field)
- [DataCamp: GLM-5.3 Flash](https://www.datacamp.com/blog/glm-5-3-flash) · [The New Stack: GLM Flash vs flagship benchmark](https://thenewstack.io/glm-flash-flagship-benchmark/) · [The New Stack: GLM-5.3 Flash on Chinese chips](https://thenewstack.io/glm-5-3-flash-chinese-chips/) · [NYU Shanghai RITS: GLM-5.3-Flash](https://rits.shanghai.nyu.edu/ai/glm-5-3-flash-320b-multimodal-moe/) · [Epoch AI](https://epoch.ai/models/glm-5-3-flash) · [Gadgety](https://www.gadgety.co.il/?p=368206)
- [VentureBeat: GLM-5.3](https://venturebeat.com/technology/glm-5-3-is-here-with-advanced-cyber-capabilities-and-reportedly-already-found-a-serious-vulnerability-in-cursor) · [Decrypt](https://decrypt.co/375684/china-z-ai-glm-5-3-top-open-weight-coding-model) · [TechNode](https://technode.com/2026/08/17/z-ai-launches-glm-5-3-with-claimed-50-gain-on-coding-benchmark/) · [DeepLearning.AI The Batch](https://www.deeplearning.ai/the-batch/glm-5-3-makes-cybersecurity-gains) · [Z.ai docs: GLM-5.3](https://docs.z.ai/guides/llm/glm-5.3.md)
- Z.ai GLM-4.7-Flash release / HF card `zai-org/GLM-4.7-Flash` (2026-01)
- pi issues: [#8706](https://github.com/earendil-works/pi/issues/8706), [#11105](https://github.com/earendil-works/pi/issues/11105), [#11916](https://github.com/earendil-works/pi/issues/11916), [#9616](https://github.com/earendil-works/pi/issues/9616), [#8096](https://github.com/earendil-works/pi/issues/8096), [#918](https://github.com/earendil-works/pi/issues/918), [#1259](https://github.com/earendil-works/pi/issues/1259), [#845](https://github.com/earendil-works/pi/issues/845), [#12194](https://github.com/earendil-works/pi/issues/12194), [#11884](https://github.com/earendil-works/pi/issues/11884), [#11354](https://github.com/earendil-works/pi/issues/11354)
- opencode issues: [#42793](https://github.com/anomalyco/opencode/issues/42793), [#58323](https://github.com/anomalyco/opencode/issues/58323), [#55124](https://github.com/anomalyco/opencode/issues/55124), [#53809](https://github.com/anomalyco/opencode/issues/53809), [#57844](https://github.com/anomalyco/opencode/issues/57844), [#55936](https://github.com/anomalyco/opencode/issues/55936), [#56796](https://github.com/anomalyco/opencode/issues/56796), [#45568](https://github.com/anomalyco/opencode/issues/45568), [#52403](https://github.com/anomalyco/opencode/issues/52403)
