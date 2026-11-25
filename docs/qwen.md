# Qwen (Alibaba Cloud)

## Provider overview

- **Who:** the Qwen team at Alibaba Cloud. It ships both **open-weight** models (Apache 2.0, on Hugging Face `Qwen/*`) and **proprietary API models** (Plus / Max / Flash tiers on Alibaba Cloud Model Studio, also branded QwenCloud).
- **Generations in this list:** Qwen3 (Apr 2025), Qwen3-2507 refresh (Jul 2025), Qwen3-Coder (Jul 2025), Qwen3.5 (Feb–Mar 2026: hybrid linear attention + sparse MoE, native vision-language), and Qwen3.7 (Jul 2026). Qwen3.8 is already on OpenRouter.
- **Hosting:** the open models have several hosts. The **Flash API models are served only by Alibaba** and use **tiered context pricing**.

### opencode / pi at the provider level
Qwen is one of the most-used families in both trackers, mostly via local llama.cpp, vLLM and Ollama, and via opencode Go / Qwen Token Plan subscriptions.
- **Tool-call format:** Qwen3 / Qwen3-Coder emit XML-style tool calls (`<tool_call>` / `qwen3_coder` parser). Servers with the wrong parser leave **"naked" tool calls in the text**:
  - progress halts with a naked tool call (anomalyco/opencode#24316)
  - JSON output instead of writing to disk (#29757)
  - pi's default tool set breaks tool_use formatting on Qwen3 vLLM backends unless an explicit `--tools` allowlist is used (earendil-works/pi#4625)

  OpenRouter hosts normally parse these correctly.
- **System prompts:** "Multiple system prompts break Qwen3.5-* models" (anomalyco/opencode#15059, fixed).
- **Thinking templates:** a trailing-assistant 400 on llama.cpp/vLLM with Qwen3 thinking templates (anomalyco/opencode#27920). Cerebras rejected replayed `reasoning_content` and caused an infinite retry loop (#48774). Groq rejects `reasoning_content` (pi#6139).
- **vLLM:** opencode's openai-compatible provider omits `tool_choice: "auto"`, so tool calls are never parsed on vLLM gateways (anomalyco/opencode#60202, **open**). This matters if you self-host, not via OpenRouter.

---

## `qwen/qwen3-32b`: Qwen3 32B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-04-28 |
| Architecture | dense 32.8B, hybrid thinking / non-thinking, Apache 2.0 |
| Context / max output | 131,072 (**DeepInfra endpoints: 40,960; Tenstorrent: 20,000**) / 16,384 |
| Price (in / out, $/M) | **0.08 / 0.28** (host range 0.064–0.14 / 0.224–0.57) |
| Tools | 3 of 5 hosts |

**Advertised strengths:** switch between thinking and non-thinking modes with `/think` and `/no_think`, plus multilingual support (119 languages), agent and tool use, and strong maths and code for its size in 2025.

**Benchmarks (vendor, 2025):** ArenaHard ~93.8, AIME'24 ~81.4, LiveCodeBench ~65.7, BFCL ~70.3 (thinking mode). Superseded by Qwen3.5/3.6/3.8 27B-class models.

**opencode / pi:** generic Qwen3 template and parser issues (above). **Context trap:** default routing may land on a 40K or 20K host, which overflows opencode/pi quickly. Pin SiliconFlow (131K, tools) if you use it.

**Verdict:** dated. Use a newer Qwen instead.

---

## `qwen/qwen3-30b-a3b-instruct-2507`: Qwen3 30B A3B Instruct 2507

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-07-29 |
| Architecture | MoE, 30.5B total / 3.3B active, **non-thinking only**, Apache 2.0 |
| Context / max output | 262,144 / 235,929 |
| Price (in / out / cache, $/M) | **0.10 / 0.30 / 0.10** (SiliconFlow 0.09/0.30, Nebius 0.10/0.30) |
| Tools | yes (2/2) |

**Advertised strengths:** fast instruction following, multilingual, long context (256K), tool use, and no thinking overhead.

**Benchmarks (vendor, Jul 2025):** big jumps over the original Qwen3-30B-A3B non-thinking mode: MMLU-Pro ~78, GPQA ~70, AIME25 ~61, LiveCodeBench ~43, BFCL-v3 ~65, Arena-Hard v2 ~69.

**opencode / pi:** very popular **locally** (it fits on consumer GPUs), so there are many local-setup issues. Examples: Ollama reasoning models hang or loop through opencode (#43293), 60s+ delays with local Ollama (#52431), and pi 0.86+ crashed llama.cpp with some models (pi#9929, fixed). Via OpenRouter it works, but expect drift on long multi-file tasks.

**Verdict:** a cheap, fast, non-reasoning helper. For coding, the Coder variant below or Qwen3.5+ is better.

---

## `qwen/qwen3-coder-30b-a3b-instruct`: Qwen3 Coder 30B A3B ("Qwen3-Coder-Flash")

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-07-31 |
| Architecture | MoE, 30.5B total / 3.3B active (128 experts, 8 active), Apache 2.0 |
| Context / max output | 262,144 (up to 1M with YaRN) / 235,929 |
| Price (in / out, $/M) | **0.07 / 0.28** (SiliconFlow). Bedrock 0.15/0.60 |
| Tools | yes (2/2). **No `reasoning` parameter** (non-thinking) |

**Advertised strengths:** agentic coding, repository-scale understanding, and function calling tuned for Qwen Code, CLINE and similar agent harnesses. It is the small sibling of Qwen3-Coder-480B.

**Benchmarks (vendor, 2025):** strong among open models of its size on SWE-bench Verified (~50% with OpenHands, 500 turns), plus Aider and BFCL tool calling. By late 2026, GLM 5.3 Flash and DeepSeek V4.1 Flash are far ahead.

**opencode / pi:** the single most-reported Qwen model in local setups. The issues are mostly about the **parser**: naked or XML tool calls (opencode#24316, pi#4625), invalid JSON payloads from the Edit tool (pi#4934), and Ollama-provider breakage in opencode 2.x (#63058, #65805). The older proprietary `qwen3-coder-plus` "stops abruptly mid-execution" in pi (pi#1863). Via OpenRouter (SiliconFlow or Bedrock) tool parsing is server-side and generally works.

**Verdict:** a reasonable local coding model, but via OpenRouter it is beaten on price and quality by newer Flash models. Use it only if you need parity with a local setup.

---

## `qwen/qwen3.5-9b`: Qwen3.5-9B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-03-10 (Qwen3.5 small-model release: 0.8B / 2B / 4B / 9B) |
| Architecture | dense ~9B with vision encoder, unified vision-language, Apache 2.0 |
| Context / max output | 262,144 / 235,929 |
| Modalities | text + image + video → text |
| Price (in / out, $/M) | **0.17 / 0.25** headline (Together and PrimeIntellect). **Cheaper hosts: DeepInfra 0.08/0.12, Darkbloom 0.08/0.13** |
| Tools / reasoning | 7 of 8 hosts / yes |

**Advertised strengths (vendor):** "outperforms models 3–13× its size". Wins on GPQA Diamond and MathVista versus much larger models.

**Benchmarks:** *independent (Artificial Analysis)*: Intelligence Index **21** (reasoning mode), just behind Gemini 2.5 Flash Preview (Sep '25) at 24. That is impressive for 9B but nowhere near the 2026 MoE Flash models.

**opencode / pi:** local Qwen3.5 reports include "local models return file contents in chat instead of writing the file" (pi#10540), title generation running away on local thinking models (opencode#54401, open), and the multiple-system-prompt bug (#15059, fixed).

**Verdict:** a great **local** model for its size. On OpenRouter it's poor value at the headline price; pin DeepInfra if you use it. Too small to drive opencode/pi reliably on multi-step tasks.

---

## `qwen/qwen3.5-flash-02-23`: Qwen3.5-Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-02-23/25 |
| Architecture | proprietary. Hybrid linear attention + sparse MoE, native vision-language |
| Context / max output | 1,000,000 / 65,536 |
| Modalities | text + image + video → text |
| Price (in / out, $/M) | **0.065 / 0.26** (Alibaba only). Vals lists the direct price as 0.10/0.40 |
| Tools / reasoning | yes / yes |

**Benchmarks:** *independent (Vals.ai)*: Vals Index about **69.5%** accuracy; #36 of 151 on LegalBench. Few other independent numbers.

**opencode / pi:** opencode Go / Qwen Token Plan issues: Qwen3.5/3.6 Plus from OpenCode Go returning 404 or not working in pi (pi#3828, #4106), and a stale catalog (pi#8565). These are subscription-gateway issues, not OpenRouter.

**Verdict:** superseded by Qwen3.7 Flash, which is cheaper at short context. Keep it only if you need its flat (non-tiered) pricing for long prompts.

---

## `qwen/qwen3.7-flash`: Qwen3.7 Flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-07-27 |
| Architecture | proprietary vision-language reasoning model (closed weights) |
| Context / max output | 1,000,000 / 65,536 |
| Modalities | text + image + video → text |
| Price (in / out / cache read, $/M) | **0.03 / 0.13 / 0.006 up to 32K prompt**; **0.10 / 0.40 above 32K**; **0.20 / 0.80 above 256K** (Alibaba only) |
| Tools / reasoning | yes / yes |

**Advertised strengths:** multimodal agents, visual coding, search, and computer interaction (object recognition, spatial understanding). Alibaba calls it a "comprehensive upgrade" over Qwen3.6-Flash in multimodal understanding and agent execution, without numbers.

**Benchmarks (independent, sparse)**
- Epoch AI: ECI **145**, #77 of 247; "less expensive per token than similarly-capable models".
- Roboflow vision evals: **52.4%** average across 5 tasks (#57 of 67).
- BenchLM: not yet scored.

**opencode / pi:** no Flash-specific reports. Related Qwen3.7 Plus/Max issues on opencode Go: silently corrupted output where the leading paragraph is lost (anomalyco/opencode#47259), intermittent 500s (#30310), missing pricing metadata (#56377), and QwenCloud Qwen3.7 "not found" (#38285). Those are gateway issues.

**Pricing trap for agents:** opencode/pi prompts pass **32K** within the first few turns, so the effective price is **0.10 / 0.40**, not 0.03 / 0.13.

**Verdict:** a good multimodal Flash model. For text-only coding agents at real agent context sizes it costs about the same as DeepSeek V4.1 Flash or GLM 5.3 Flash, which score higher on coding benchmarks.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- Qwen blog / model cards: Qwen3 (2025-04), Qwen3-2507, Qwen3-Coder (2025-07), [Qwen3.5-9B HF card](https://huggingface.co/Qwen/Qwen3.5-9B), [Alibaba Model Studio: Qwen3.7 Flash](https://help.aliyun.com/en/model-studio/qwen3-7-flash)
- [Artificial Analysis: Qwen3.5 9B comparison](https://artificialanalysis.ai/models/comparisons/qwen3-5-9b-vs-gemini-2-5-flash-preview-09-2025-reasoning) · [NYU Shanghai RITS: Qwen 3.5 small models](https://rits.shanghai.nyu.edu/ai/qwen-3-5-small-models-9b-parameters-that-beat-120b/) · [Vals.ai: Qwen 3.5 Flash](https://www.vals.ai/models/alibaba_qwen3.5-flash) · [Epoch AI: Qwen3.7 Flash](https://epoch.ai/models/qwen3-7-flash) · [Roboflow compare](https://playground.roboflow.com/models/compare/qwen3-6-flash-vs-qwen3-7-flash) · [BenchLM](https://benchlm.ai/compare/qwen3-7-flash-vs-qwen3-7-plus)
- opencode issues: [#24316](https://github.com/anomalyco/opencode/issues/24316), [#29757](https://github.com/anomalyco/opencode/issues/29757), [#15059](https://github.com/anomalyco/opencode/issues/15059), [#27920](https://github.com/anomalyco/opencode/issues/27920), [#48774](https://github.com/anomalyco/opencode/issues/48774), [#60202](https://github.com/anomalyco/opencode/issues/60202), [#43293](https://github.com/anomalyco/opencode/issues/43293), [#52431](https://github.com/anomalyco/opencode/issues/52431), [#63058](https://github.com/anomalyco/opencode/issues/63058), [#65805](https://github.com/anomalyco/opencode/issues/65805), [#54401](https://github.com/anomalyco/opencode/issues/54401), [#47259](https://github.com/anomalyco/opencode/issues/47259), [#30310](https://github.com/anomalyco/opencode/issues/30310), [#56377](https://github.com/anomalyco/opencode/issues/56377), [#38285](https://github.com/anomalyco/opencode/issues/38285)
- pi issues: [#4625](https://github.com/earendil-works/pi/issues/4625), [#6139](https://github.com/earendil-works/pi/issues/6139), [#9929](https://github.com/earendil-works/pi/issues/9929), [#4934](https://github.com/earendil-works/pi/issues/4934), [#1863](https://github.com/earendil-works/pi/issues/1863), [#10540](https://github.com/earendil-works/pi/issues/10540), [#3828](https://github.com/earendil-works/pi/issues/3828), [#4106](https://github.com/earendil-works/pi/issues/4106), [#8565](https://github.com/earendil-works/pi/issues/8565)
