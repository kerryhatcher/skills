# DeepSeek

## Provider overview

- **Who:** DeepSeek, a Hangzhou AI lab funded by the quant fund High-Flyer. It is known for very cheap, high-quality open-weight MoE models (V3, R1, V3.1/3.2, V4, V4.1) under the **MIT licence**, and for aggressive API pricing.
- **2026 line-up:** V4 (Apr 2026 preview: Flash + Pro), **V4-Flash-0731** refresh, **V4-Pro-0813**, **V4.1-Flash** (2026-09-10; DeepSeek retired V4-Pro at the same time) and the **V4.1-Flash-1017** point update.
  - DeepSeek's own API now serves `deepseek-flash`. The legacy names `deepseek-v4-flash` and `deepseek-v4-flash-vision-exp` are routed internally to 1017.
- **OpenRouter presence:** very broad. V4.1 Flash has 39 endpoints and 1017 has 56, from fp4 to fp8, priced from about 0.035 to 1.5 per M input.

### opencode / pi at the provider level
DeepSeek Flash is a **community default for cheap agentic coding**. One OpenCode/OpenRouter evaluation (May 2026) called V4 Flash the "best default coding agent". A pi user's routing log used it for simple edits at an estimated $0.26 for 38 turns. It also has the most reasoning-format integration issues:
- **Reasoning field handling (`reasoning_content`):**
  - "v2.0.19 + opencode-go/deepseek-v4.1-flash: replies hidden inside reasoning, and CoT fragments leaked into text" (anomalyco/opencode#54861, **open**)
  - non-DeepSeek providers break when `reasoning_content` is replayed (#37475)
  - reasoning tokens consume the summary budget, so compaction fails with "reached the output token limit" (#59110, **open**)
- **Compaction degeneration:** "Manual /compact with DeepSeek V4 Flash degenerates into thousands of repeated lines" (anomalyco/opencode#41801, closed).
- **Images:** "go: deepseek-v4.1-flash image rejection bricks sessions ('image input is not available on this engine')" (#61827, **open**). Some hosts serve V4.1 Flash as text-only even though the model accepts images.
- **Malformed tool calls:** "Malformed XML/DSML tool-call output from Opencode Go models" (#50206, open).
- **Responses API:** opencode Go's `deepseek-flash` never returns `phase`, which breaks Codex desktop turn collapsing (#57372). That only matters for the Codex app.
- **pi catalog churn:** the official API is down to two models, but pi's generated catalog still shipped retired V4-Flash entries (earendil-works/pi#9617, fixed). `deepseek-flash` (V4.1) was added with refreshed pricing (#9423). The Together catalog was stale (#11530). QwenCloud V4.1 Flash 1017 compatibility (#11877).
- Effort levels were missing from opencode's DeepSeek harness setup (opencode#63131, open).

**Practical advice:** use the newest harness version, keep reasoning effort at `high` or `low` (not `max`) to limit verbosity, and if the session uses images, pin an image-capable host.

---

## `deepseek/deepseek-v4.1-flash`: DeepSeek V4.1 Flash (2026-09-10 checkpoint)

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-09-10 |
| Architecture | **Causal Encoder-Decoder (CED)** sparse MoE, DeepSeek's first: about 552B total, **8B active on input / 16B active on output**. MIT (`deepseek-ai/DeepSeek-V4.1-Flash`) |
| Context / max output | 1,048,576 (some hosts 262K–1.04M) / 393,216 |
| Modalities | text + image → text |
| Price (in / out / cache read, $/M) | **0.0507 / 0.2028 / 0.001** (Baidu fp8). Host range 0.0507–1.5 / 0.2028–6.0; **typical hosts 0.15–0.30 / 0.60–1.20**. `:batch` 0.05/0.15 |
| Tools / reasoning | yes (39/39) / yes, efforts `max/high/low/none`, default `high` |

**Advertised strengths:** frontier-level coding at Flash cost, lower memory and API costs, agentic tasks, and long context. DeepSeek claimed it beats its own flagship V4-Pro.

**Benchmarks**
- *Vendor:* DeepSWE v1.1 **74.2** (vs 74.0 Claude Opus 5, 73.0 GPT-5.6 Sol); Terminal-Bench 2.1 **90.6** (vs 88.8 GPT-5.6 Sol, 88.3 Kimi K3, 87.9 V4 Pro); AutomationBench-AA **69%** (first, tied with GPT-6 Astra).
- *Independent:* Artificial Analysis Intelligence Index **40**, up 4 points, but flagged as **"one of the most verbose models we've measured"** at 89K tokens per index task. Vals.ai found it cheaper per test on most agentic benchmarks because it finishes in fewer *turns*, and it splits 10–10 with Gemini 3.7 Flash across 20 shared benchmarks.
- *Hands-on:* MindStudio saw it fail some creative/visual tasks (a Rubik's cube sim, a Paint-style portrait) despite strong coding scores. TNW: "rivals Opus 5 on coding, but trails on hard reasoning".

**opencode / pi:** see the provider-level list above. Most V4.1 Flash reports come through opencode Go, but the reasoning-display and image issues also apply via OpenRouter.

**Verdict:** **the top value pick for opencode/pi coding in this list**, given its strong agentic coding scores and wide host choice. Pin a mid-priced fp8 host (DeepInfra, Fireworks, Novita, Together) rather than the cheapest fp4 one if quality varies. Budget for verbose reasoning.

---

## `~deepseek/deepseek-v4-flash-latest` → `deepseek/deepseek-v4-flash-0731`

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Alias target | `deepseek/deepseek-v4-flash-0731` (V4 Flash post-training refresh, 2026-07-31). This alias tracks only the **V4** Flash line, so it will **not** move to V4.1 |
| Architecture | MoE, about 284B total / 13B active (NVIDIA lists 304B). MIT |
| Context / max output | 1,048,576 / 131,072 |
| Modalities | text → text |
| Price (in / out / cache, $/M) | Alias headline **0.0453 / 0.136 / 0.0014**; host median ≈ 0.13 / 0.28 (25 hosts) |
| Tools / reasoning | yes / yes, default `high` |

**Benchmarks**
- *Vendor:* Terminal-Bench 2.1 **82.7** (April preview 61.8, V4-Pro preview 72.1); DeepSWE 54.4; Toolathlon-Verified 70.3.
- *Independent:* Artificial Analysis measured Terminal-Bench 2.1 at **79%**, lower than claimed. AA Intelligence Index **50** at max reasoning (April preview: 40). Epoch ECI 154, #30 of 249. GDPval-AA v2 **1,558 Elo**, second among open-weights models after Kimi K3. DeepLearning.AI: "DeepSeek pushes the frontier again".

**opencode / pi:** this is the "V4 Flash" most community posts refer to. The inksh.in evaluation (May 2026) rated **V4 Flash the "best default coding agent"** among cheap models, with the caveat: "if it starts making confident but wrong turns, repeated retries can become more expensive than switching models". Issues: compaction degeneration (opencode#41801), and retired-catalog confusion in pi (#9617, #10812: a saved default no longer in the catalog silently falls back to a different model).

**Verdict:** still a strong, cheap model, but **V4.1 Flash (or the `~deepseek-flash-latest` alias) is newer and better** on coding benchmarks. Use this alias only if you specifically want the V4 generation's behaviour.

---

## `~deepseek/deepseek-flash-latest` → `deepseek/deepseek-v4.1-flash-1017`

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Alias target | `deepseek/deepseek-v4.1-flash-1017` (released 2026-10-17). It tracks the **newest DeepSeek Flash of any generation**, matching DeepSeek's own `deepseek-flash` API name |
| Architecture | Same as V4.1 Flash (CED MoE). Same config, tokenizer and prompt encoding; only the weights changed. MIT |
| Context / max output | 1,048,576 / **943,718** |
| Modalities | text + image → text |
| Price (in / out / cache, $/M) | Alias headline **0.036 / 0.50 / 0.01**. The 1017 model's host range is 0.035–0.60 / 0.10–2.40 (56 hosts), median ≈ 0.15 / 0.67. **DeepSeek first-party 0.15 / 0.60.** `:batch` 0.035/0.149 |
| Tools / reasoning | yes / yes, default `high` |

**What changed versus the 0910 checkpoint (vendor):** gains in reasoning, coding, agentic and visual benchmarks, with **shorter outputs and faster task completion**, which addresses the verbosity criticism. Reported figures: DeepSWE v1.1 Pass@1 **77.0**; Terminal-Bench 4.0 31.2 → **42.3**; HLE 39.1 → **42.6**. No independent replication yet. Tencent cites it as the baseline (Terminal-Bench 4.0: 40.0) in its Hy4 flash comparisons.

**opencode / pi:** it is what opencode Go's `deepseek-flash` points to, so the opencode issues above (#54861 hidden replies, #61827 images, #57372 phase) mostly involve this checkpoint. pi added 1017 support across catalogs (#11530, #11877).

**Verdict:** **the recommended DeepSeek ID for opencode/pi**. It is the newest Flash, less verbose, and the alias updates automatically. The alias headline price only applies on the cheapest host, so expect about 0.15 / 0.60 in practice.

---

## Sources
- OpenRouter API snapshot, 2026-11-25 (alias targets from `alias_target` field)
- [DeepSeek API news: V4.1 Flash](https://api-docs.deepseek.com/news/news260910) · [deepseek.com news](https://deepseek.com/en/news/deepseek-v4-1-flash/) · [SCMP](https://scmp.com/tech/big-tech/article/3367051/deepseek-says-new-flash-ai-model-beats-kimi-k3-cyber-coding-benchmarks) · [TNW](https://thenextweb.com/news/deepseek-v4-1-flash-launch-v4-pro-retired-price-cut) · [SiliconANGLE](https://siliconangle.com/deepseek-releases-v4-1-flash-says-it-outperforms-flagship-v4-pro) · [Vals.ai V4.1 Flash](https://vals.ai/models/deepseek_deepseek-v4.1-flash) · [Vals.ai vs Gemini 3.7 Flash](https://www.vals.ai/comparisons/deepseek_deepseek-v4.1-flash-vs-google_gemini-3.7-flash) · [MindStudio hands-on](https://www.mindstudio.ai/blog/deepseek-v4-1-flash-hands-on-test)
- [TechNode: V4.1-Flash-1017](https://technode.com/2026/10/19/deepseek-releases-v4-1-flash-1017-with-stronger-coding-and-agent-capabilities/) · [Tech Insider: 1017](https://tech-insider.org/deepseek-v4-1-flash-1017-deepswe-search-api-2026/) · [SmartScope](https://smartscope.blog/en/blog/deepseek-v4-1-flash-1017-release-benchmarks-price-2026/) · [vLLM recipe](https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4.1-Flash)
- [DeepLearning.AI: V4 Flash 0731](https://www.deeplearning.ai/the-batch/deepseek-pushes-the-frontier-again-deepseek-refreshed-its-v4-flash-model-with-an-impressive-fine-tune) · [The New Stack: V4 Flash open weights](https://thenewstack.io/deepseek-v4-flash-open-weights/) · [Epoch AI](https://epoch.ai/models/deepseek-v4-flash-0731) · [NVIDIA NIM](https://docs.api.nvidia.com/nim/reference/deepseek-ai-deepseek-v4-flash-0731)
- Community: [inksh.in OpenCode/OpenRouter evaluation](https://www.inksh.in/blog/vscode/openrouter-models) · [Tyler Folkman: 2,415 agent turns across 6 models (pi router)](https://tylerfolkman.substack.com/p/i-tested-6-ai-models-across-3-providers)
- opencode issues: [#54861](https://github.com/anomalyco/opencode/issues/54861), [#37475](https://github.com/anomalyco/opencode/issues/37475), [#59110](https://github.com/anomalyco/opencode/issues/59110), [#41801](https://github.com/anomalyco/opencode/issues/41801), [#61827](https://github.com/anomalyco/opencode/issues/61827), [#50206](https://github.com/anomalyco/opencode/issues/50206), [#57372](https://github.com/anomalyco/opencode/issues/57372), [#63131](https://github.com/anomalyco/opencode/issues/63131)
- pi issues: [#9617](https://github.com/earendil-works/pi/issues/9617), [#9423](https://github.com/earendil-works/pi/issues/9423), [#11530](https://github.com/earendil-works/pi/issues/11530), [#11877](https://github.com/earendil-works/pi/issues/11877), [#10812](https://github.com/earendil-works/pi/issues/10812)
