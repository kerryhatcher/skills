# OpenAI

## Provider overview

- **Who:** OpenAI, maker of the GPT models. In August 2025 it released its first open-weight models since GPT-2: **gpt-oss-20b / gpt-oss-120b** (Apache 2.0). In 2026 it moved the proprietary line to named tiers: **GPT-6 Astra / Sol / Terra / Luna**, with Luna the cheapest and fastest.
- **OpenRouter presence:** open-weight gpt-oss models are served by many third-party hosts (11–23 endpoints). Proprietary models are served by OpenAI and Azure only.
- **Harmony format:** the gpt-oss models are trained on OpenAI's "harmony" chat format, with separate `analysis` (reasoning), `commentary` (tool calls) and `final` channels. Hosts that implement harmony parsing badly are the main cause of gpt-oss tool-call problems.

### opencode / pi at the provider level
- opencode's own tooling runs on OpenAI small models: title generation hard-coded `gpt-5.4-nano` (anomalyco/opencode#54692), and triage used `gpt-5.4-mini`. OpenAI models are very well tested in opencode.
- pi has first-class `openai-responses`, `openai-codex` and `openai-completions` backends, plus many GPT-6 reasoning-effort fixes (#12361, #12464: effort silently forced to `medium`).

---

## `openai/gpt-oss-20b`

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-08-05 |
| Architecture | MoE, 21B total / **3.6B active**, MXFP4 native, Apache 2.0 |
| Context / max output | 131,072 / 117,964 |
| Price (in / out / cache, $/M) | **0.03 / 0.13 / 0.03** (host range 0.017–0.169 / 0.085–0.30) |
| Tools | 10 of 11 hosts (SiliconFlow lacks tools) |
| Reasoning | configurable effort (low / medium / high), full chain of thought exposed |

**Advertised strengths:** runs on 16 GB devices, low latency, native tool use (browsing, Python), structured outputs, adjustable reasoning, and fine-tunable.

**Benchmarks (vendor, high effort):** MMLU ~85, GPQA Diamond ~71.5, AIME 2025 (with tools) ~98, SWE-bench Verified ~60.7, τ-bench retail ~54.8. *Independent:* Artificial Analysis rated it well above the open small models of late 2025, but by late 2026 it sits in the lower-middle of the field.

**Reviews:** praised as the best "runs on a laptop" reasoning model of its era. Common complaints: hallucinated facts (weak world knowledge), and quality that varies sharply by host because of harmony parsing and quantization.

**opencode / pi**
- *pi:* "Harmony response format corrupts tool calls" (earendil-works/pi#4439, closed). Declaring a `contextWindow` above the served limit caused repeated overflow after compaction (#11387).
- *opencode:* reasoning from Ollama's OpenAI-compatible `reasoning` field was not rendered as thinking (anomalyco/opencode#45547), and streamed `reasoning` fields were dropped (#35283). Local subagents received no tool definitions (#51268), and MCP tools were not sent to local OpenAI-compatible models (#39164). Most hits involve **local** deployments (llama.cpp, LM Studio, Ollama), not OpenRouter.
- Community consensus: usable for light agent tasks and subagents. Multi-file refactors drift.

**Verdict:** one of the best price-to-capability ratios for **simple** agent work and subagents. Pin a host with good harmony support (Groq, Fireworks, DeepInfra, CoreWeave, Bedrock).

---

## `openai/gpt-oss-120b`

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-08-05 |
| Architecture | MoE, 117B total / **5.1B active**, MXFP4 native, Apache 2.0; fits one 80 GB GPU |
| Context / max output | 131,072 / 117,964 |
| Price (in / out / cache, $/M) | **0.05 / 0.25 / 0.05** (host range 0.03–0.35 / 0.15–0.95; Cerebras and SambaNova are the fast, expensive hosts) |
| Tools | 20 of 23 hosts (DigitalOcean, Google and SiliconFlow lack tools) |

**Advertised strengths:** near o4-mini reasoning on a single GPU, agentic tool use, configurable effort, and very fast on Cerebras/Groq (1,000+ tok/s).

**Benchmarks (vendor, high effort):** MMLU ~90, GPQA Diamond ~80, AIME 2025 (with tools) ~97.9, SWE-bench Verified ~62.4, τ-bench retail ~67.8, HealthBench ~57.6. *Independent:* in late 2025 it was the top US open-weight model on Artificial Analysis's index. In late 2026 it is a solid mid-tier budget model.

**opencode / pi**
- *opencode:* "GPT OSS 120B subagent stops mid-reasoning and returns empty result after several tool calls" (anomalyco/opencode#27210, closed). Tool calls fail when assistant `content` is null (#51661, **open**), and Cloudflare Workers AI returned 400 on tool-call turns (#55936). Non-DeepSeek custom providers fail when `reasoning_content` is replayed (#37475).
- *pi:* "gpt-oss-120b (openai-completions) degrades to reasoning-only turns in subagent harness at large agentic context" (earendil-works/pi#8916, closed). Cerebras gpt-oss-120b errors (#4940), and intermittent 400s via Cloudflare Workers AI (#12194).
- **Pattern:** at long agentic context, gpt-oss-120b tends to emit reasoning with no final answer or tool call. Keep sessions short, compact early, or use it for subagents.

**Verdict:** a good budget workhorse with the widest host choice. Tool calling is reliable on good hosts, but long-context agent loops can stall. It suits subagents and quick edits better than long autonomous sessions.

---

## `openai/gpt-oss-safeguard-20b`

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-10-29 |
| Architecture | gpt-oss-20b fine-tuned for safety reasoning, Apache 2.0 |
| Context / max output | 131,072 / 65,536 |
| Price (in / out, $/M) | **0.075 / 0.30** (Bedrock 0.07/0.20, Groq 0.075/0.30) |
| Tools | yes (both hosts) |

**Advertised purpose:** a **policy-following classifier**. You supply your own written safety policy at inference time, and the model reasons about whether content violates it, returning a label and its reasoning. Uses: content moderation, LLM input/output filtering, and trust & safety labelling. It was released with ROOST as part of an open safety-tooling effort.

**Benchmarks (vendor):** beats gpt-oss base models and was competitive with OpenAI's internal Safety Reasoner on multi-policy accuracy. It is *not* tuned or evaluated as a general assistant.

**opencode / pi:** no issues found, and it is **not meant for coding agents**. It could serve as a guard model in a custom pi extension or opencode plugin, for example to classify tool outputs.

**Verdict:** use it for moderation and classification pipelines. **Do not use it as an opencode/pi main model.**

---

## `openai/gpt-5-nano`: GPT-5 Nano

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-08-07 |
| Architecture | proprietary, smallest GPT-5 variant |
| Context / max output | 400,000 / 128,000 |
| Modalities | text + image + file → text |
| Price (in / out / cache, $/M) | **0.05 / 0.40 / 0.005**. OpenAI also lists a flex-tier endpoint at 0.025/0.20 |
| **Expiration** | **2026-12-11**: OpenRouter's expiration date matches OpenAI's API retirement of `gpt-5-nano-2025-08-07`. OpenAI's deprecation table points to the GPT-5.6 Luna line as the replacement; third-party trackers also mention gpt-5.4-nano |

**Advertised strengths:** ultra-low latency, classification, summarization and simple tool use. Supports reasoning effort and `verbosity`.

**Benchmarks (vendor, 2025):** around o4-mini-low level on many tasks. Weak at long-horizon coding, where SWE-bench Verified was far below GPT-5 and GPT-5 mini.

**opencode / pi:** compaction failed with GPT-5 models (earendil-works/pi#3060, #3342, fixed). OpenCode Zen GPT-5.x returned 500 on unsupported session headers (#6625). opencode used the nano tier for titles. No nano-specific failure reports as a main agent, because few people use it that way.

**Verdict:** **don't adopt it now**: it retires in about two weeks. Move to `~openai/gpt-luna-latest` (GPT-6 Luna) at 0.10/0.50, which is far more capable.

---

## `~openai/gpt-luna-latest` → `openai/gpt-6-luna`: GPT-6 Luna

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Alias target | `openai/gpt-6-luna`, released 2026-09-22. The alias always tracks the newest Luna |
| Architecture | proprietary. A GPT-6 Luna Pro variant is the same model with `pro` reasoning mode |
| Context / max output | 1,050,000 / 128,000 |
| Modalities | text + image + file → text |
| Price (in / out / cache read / cache write, $/M) | **0.10 / 0.50 / 0.01 / 0.125**. **Above 272K prompt: 0.20 / 0.75.** OpenAI flex 0.05/0.25 and priority 0.20/1.00 endpoints also exist |
| Reasoning | effort `none` → `max`, default `medium` |

**Advertised strengths:** OpenAI's "most efficient model for focused, high-volume work". About 50% cheaper than GPT-5.6 Luna (0.20/1.20). Strong tool use.

**Benchmarks**
- *Independent (Artificial Analysis):* about 37–38 on the Intelligence Index for the top reasoning variant, falling to about 18 with no reasoning. About 157 tok/s. One regional AA page shows 28, probably a different index version.
- *OpenRouter (AA data), max variant:* HLE 38.5%, AA-LCR 83.3%.
- Anthropic's launch materials claim Haiku 5.5 beats GPT-6 Luna on several computer-use, coding and professional-work evals. That is a competitor-reported comparison.

**opencode / pi**
- *pi:* GPT-6 reasoning-effort bugs where `--thinking high/xhigh` was silently sent as `medium` (earendil-works/pi#12361, follow-up #12464). `additional_tools` suppressed reasoning on tool turns (#12464). Prompt cache was lost when changing thinking level (#12269). A stale opencode-go catalog was missing gpt-6-luna (#10010). All are closed, so **update pi to the latest release.**
- *opencode:* the Zen model-disable toggle wasn't enforced and kept auto-using gpt-5.6-luna (anomalyco/opencode#41697, open). A `gpt-5.6-luna` 500 on the Go gateway (#46124). A serious **open** report: title generation sent a first message under another account via the Codex provider (#66400). That concerns the ChatGPT/Codex OAuth path, not OpenRouter.
- OpenRouter route suffixes (`:nitro`, `:floor`, …) can't be used in opencode 2.x model IDs (#63132, open).

**Verdict:** a strong, reliable small proprietary model with excellent tool calling at 0.10/0.50. It is the natural replacement for GPT-5 Nano. Watch the price step above 272K prompt tokens, and update pi so reasoning effort is actually applied.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- OpenAI: "Introducing gpt-oss" (2025-08-05) and model card; "gpt-oss-safeguard" (2025-10-29); [GPT-6 Luna docs](https://developers.openai.com/api/docs/models/gpt-6-luna); [Deprecations](https://developers.openai.com/api/docs/deprecations.md)
- [Artificial Analysis: GPT-6 Luna](https://artificialanalysis.ai/models/releases/gpt-6-luna) · [ProPakistani: GPT-6 Sol & Luna launch](https://propakistani.pk/2026/09/24/openai-launches-gpt-6-sol-and-luna-with-50-lower-api-costs/) · [aiengineerguide: GPT-5 Nano retirement](https://aiengineerguide.com/tools/model-retirements/gpt-5-nano/) · [endoflife.ai](https://endoflife.ai/openai-api/gpt-5-nano)
- opencode issues: [#27210](https://github.com/anomalyco/opencode/issues/27210), [#51661](https://github.com/anomalyco/opencode/issues/51661), [#55936](https://github.com/anomalyco/opencode/issues/55936), [#37475](https://github.com/anomalyco/opencode/issues/37475), [#45547](https://github.com/anomalyco/opencode/issues/45547), [#35283](https://github.com/anomalyco/opencode/issues/35283), [#51268](https://github.com/anomalyco/opencode/issues/51268), [#39164](https://github.com/anomalyco/opencode/issues/39164), [#54692](https://github.com/anomalyco/opencode/issues/54692), [#41697](https://github.com/anomalyco/opencode/issues/41697), [#46124](https://github.com/anomalyco/opencode/issues/46124), [#66400](https://github.com/anomalyco/opencode/issues/66400), [#63132](https://github.com/anomalyco/opencode/issues/63132)
- pi issues: [#4439](https://github.com/earendil-works/pi/issues/4439), [#11387](https://github.com/earendil-works/pi/issues/11387), [#8916](https://github.com/earendil-works/pi/issues/8916), [#4940](https://github.com/earendil-works/pi/issues/4940), [#12194](https://github.com/earendil-works/pi/issues/12194), [#3060](https://github.com/earendil-works/pi/issues/3060), [#3342](https://github.com/earendil-works/pi/issues/3342), [#6625](https://github.com/earendil-works/pi/issues/6625), [#12361](https://github.com/earendil-works/pi/issues/12361), [#12464](https://github.com/earendil-works/pi/issues/12464), [#12269](https://github.com/earendil-works/pi/issues/12269), [#10010](https://github.com/earendil-works/pi/issues/10010)
