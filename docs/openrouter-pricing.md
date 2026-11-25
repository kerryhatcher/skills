# OpenRouter pricing: requested models (snapshot 2026-11-25)

All prices are **USD per 1 million tokens**, taken from OpenRouter's public API (`GET /api/v1/models` and `/api/v1/models/{id}/endpoints`) on **2026-11-25**. OpenRouter prices change often (promotions, new hosts, preview discounts ending), so re-check before you commit to a budget. The regeneration commands are at the bottom of this file.

**How to read the columns**

- **Input / Output / Cache read**: the headline price OpenRouter shows for the model. For models with several hosts this is the default-routing price, not always the cheapest host. See the per-host range table below.
- **Blended**: (3 × input + output) / 4, the usual 3:1 input:output weighting.
- **$/1K agent turns**: the estimated cost of 1,000 coding-agent turns at 30K input + 1.5K output tokens each, with no cache. This is closer to how opencode and pi actually spend tokens, because those harnesses resend large system prompts, tool schemas and history every turn. Prompt caching can cut this a lot where the model supports it.
- **Tools**: whether OpenRouter advertises `tools` support, plus how many of the hosting endpoints actually accept tool calls. **A model needs working tool calls to function in opencode or pi.**
- `~` IDs are **router aliases** that always point at the newest model in a family. The alias target shown is the one in effect today.

## Main table (sorted by blended price)

| # | Model ID | Name | Input | Output | Cache read | Blended | $/1K agent turns | Context | Max out | Input modalities | Tools | Reasoning | Notes | Details |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|---|
| 1 | `upstage/solar-mini-4-5` | Upstage: Solar Mini 4.5 (Preview) | 0.01 | 0.04 | 0.001 | 0.0175 | 0.36 | 512K | 128K | text | yes (1/1 endpoints) | yes |  | [upstage.md](upstage.md) |
| 2 | `mistralai/mistral-nemo` | Mistral: Mistral Nemo | 0.029 | 0.03 | — | 0.0293 | 0.92 | 128K | 16K | text | yes (3/5 endpoints) | no |  | [mistral.md](mistral.md) |
| 3 | `inclusionai/ling-3.0-flash` | inclusionAI: Ling 3.0 Flash | 0.021 | 0.063 | 0.0042 | 0.0315 | 0.72 | 256K | 32K | text | yes (2/2 endpoints) | yes |  | [inclusionai.md](inclusionai.md) |
| 4 | `google/gemma-3-4b-it` | Google: Gemma 3 4B | 0.04 | 0.05 | 0.02 | 0.0425 | 1.28 | 128K | 115K | text+image | no (0/4 endpoints) | no |  | [google.md](google.md) |
| 5 | `~z-ai/glm-flash-latest` | Z.ai: GLM Flash Latest | 0.0356 | 0.0815 | 0.03 | 0.0471 | 1.19 | 1M | 128K | text+image+video | yes | yes | alias → `z-ai/glm-5.3-flash` | [z-ai.md](z-ai.md) |
| 6 | `openai/gpt-oss-20b` | OpenAI: gpt-oss-20b | 0.03 | 0.13 | 0.03 | 0.055 | 1.09 | 128K | 115K | text | yes (10/11 endpoints) | yes | `:batch` variant exists | [openai.md](openai.md) |
| 7 | `qwen/qwen3.7-flash` | Qwen: Qwen3.7 Flash | 0.03 | 0.13 | 0.006 | 0.055 | 1.09 | 1M | 64K | text+image+video | yes (1/1 endpoints) | yes | >32K prompt: $0.1/$0.4; >256K prompt: $0.2/$0.8 | [qwen.md](qwen.md) |
| 8 | `meta-llama/llama-3.1-8b-instruct` | Meta: Llama 3.1 8B Instruct | 0.05 | 0.08 | 0.025 | 0.0575 | 1.62 | 128K | 115K | text | yes (3/4 endpoints) | no |  | [meta.md](meta.md) |
| 9 | `mistralai/mistral-small-24b-instruct-2501` | Mistral: Mistral Small 3 | 0.05 | 0.08 | — | 0.0575 | 1.62 | 32K | 16K | text | no (0/2 endpoints) | no |  | [mistral.md](mistral.md) |
| 10 | `tencent/hy4-flash` | Tencent: Hy4 flash | 0.035 | 0.1405 | 0.0015 | 0.0614 | 1.26 | 1M | 64K | text+image | yes (3/3 endpoints) | yes |  | [tencent.md](tencent.md) |
| 11 | `cohere/command-r7b-12-2024` | Cohere: Command R7B (12-2024) | 0.0375 | 0.15 | — | 0.0656 | 1.35 | 125K | 4K | text | yes (1/1 endpoints) | no |  | [cohere.md](cohere.md) |
| 12 | `~deepseek/deepseek-v4-flash-latest` | DeepSeek: DeepSeek V4 Flash Latest | 0.0453 | 0.136 | 0.0014 | 0.068 | 1.56 | 1M | 128K | text | yes | yes | alias → `deepseek/deepseek-v4-flash-0731` | [deepseek.md](deepseek.md) |
| 13 | `google/gemma-3-12b-it` | Google: Gemma 3 12B | 0.05 | 0.15 | — | 0.075 | 1.72 | 128K | 16K | text+image | yes (1/4 endpoints) | no |  | [google.md](google.md) |
| 14 | `upstage/solar-mini4` | Upstage: Solar Mini 4 | 0.05 | 0.2 | 0.005 | 0.0875 | 1.80 | 512K | 128K | text | yes (2/2 endpoints) | yes |  | [upstage.md](upstage.md) |
| 15 | `deepseek/deepseek-v4.1-flash` | DeepSeek: DeepSeek V4.1 Flash | 0.0507 | 0.2028 | 0.001 | 0.0887 | 1.83 | 1M | 384K | text+image | yes (39/39 endpoints) | yes | `:batch` variant exists | [deepseek.md](deepseek.md) |
| 16 | `google/gemma-3-27b-it` | Google: Gemma 3 27B | 0.08 | 0.16 | — | 0.1 | 2.64 | 128K | 16K | text+image | yes (3/6 endpoints) | no |  | [google.md](google.md) |
| 17 | `openai/gpt-oss-120b` | OpenAI: gpt-oss-120b | 0.05 | 0.25 | 0.05 | 0.1 | 1.87 | 128K | 115K | text | yes (20/23 endpoints) | yes | `:batch` variant exists | [openai.md](openai.md) |
| 18 | `nvidia/nemotron-3.5-lightning` | NVIDIA: Nemotron 3.5 Lightning | 0.07 | 0.2 | 0.04 | 0.1025 | 2.40 | 1M | 230K | text | yes (5/5 endpoints) | yes | `:free` variant exists | [nvidia.md](nvidia.md) |
| 19 | `nvidia/nemotron-3-nano-30b-a3b` | NVIDIA: Nemotron 3 Nano 30B A3B | 0.06 | 0.24 | 0.012 | 0.105 | 2.16 | 256K | 230K | text | yes (1/1 endpoints) | yes |  | [nvidia.md](nvidia.md) |
| 20 | `inclusionai/ling-3.1-flash` | inclusionAI: Ling 3.1 Flash | 0.075 | 0.225 | 0.015 | 0.1125 | 2.59 | 1M | 256K | text | yes (1/1 endpoints) | yes |  | [inclusionai.md](inclusionai.md) |
| 21 | `qwen/qwen3.5-flash-02-23` | Qwen: Qwen3.5-Flash | 0.065 | 0.26 | — | 0.1138 | 2.34 | 1M | 64K | text+image+video | yes (1/1 endpoints) | yes |  | [qwen.md](qwen.md) |
| 22 | `meta-llama/llama-3.2-3b-instruct` | Meta: Llama 3.2 3B Instruct | 0.05 | 0.33 | — | 0.12 | 1.99 | 128K | 115K | text | no (0/1 endpoints) | no |  | [meta.md](meta.md) |
| 23 | `qwen/qwen3-coder-30b-a3b-instruct` | Qwen: Qwen3 Coder 30B A3B Instruct | 0.07 | 0.28 | — | 0.1225 | 2.52 | 256K | 230K | text | yes (2/2 endpoints) | no |  | [qwen.md](qwen.md) |
| 24 | `meta/muse-spark-1.3-contributor` | Meta: Muse Spark 1.3 Contributor | 0.1 | 0.2 | 0.002 | 0.125 | 3.30 | 1M | 922K | text+image+video+file | yes (1/1 endpoints) | yes |  | [meta.md](meta.md) |
| 25 | `qwen/qwen3-32b` | Qwen: Qwen3 32B | 0.08 | 0.28 | — | 0.13 | 2.82 | 128K | 16K | text | yes (3/5 endpoints) | yes |  | [qwen.md](qwen.md) |
| 26 | `openai/gpt-oss-safeguard-20b` | OpenAI: gpt-oss-safeguard-20b | 0.075 | 0.3 | 0.0375 | 0.1312 | 2.70 | 128K | 64K | text | yes (2/2 endpoints) | yes |  | [openai.md](openai.md) |
| 27 | `openai/gpt-5-nano` | OpenAI: GPT-5 Nano | 0.05 | 0.4 | 0.005 | 0.1375 | 2.10 | 391K | 125K | text+image+file | yes (3/3 endpoints) | yes | expires 2026-12-11; `:batch` variant exists | [openai.md](openai.md) |
| 28 | `z-ai/glm-4.7-flash` | Z.ai: GLM 4.7 Flash | 0.0605 | 0.4 | — | 0.1454 | 2.42 | 128K | 115K | text | yes (1/1 endpoints) | yes |  | [z-ai.md](z-ai.md) |
| 29 | `qwen/qwen3-30b-a3b-instruct-2507` | Qwen: Qwen3 30B A3B Instruct 2507 | 0.1 | 0.3 | 0.1 | 0.15 | 3.45 | 256K | 230K | text | yes (2/2 endpoints) | no |  | [qwen.md](qwen.md) |
| 30 | `~deepseek/deepseek-flash-latest` | DeepSeek: DeepSeek Flash Latest | 0.036 | 0.5 | 0.01 | 0.152 | 1.83 | 1M | 922K | text+image | yes | yes | alias → `deepseek/deepseek-v4.1-flash-1017` | [deepseek.md](deepseek.md) |
| 31 | `qwen/qwen3.5-9b` | Qwen: Qwen3.5-9B | 0.17 | 0.25 | — | 0.19 | 5.47 | 256K | 230K | text+image+video | yes (7/8 endpoints) | yes |  | [qwen.md](qwen.md) |
| 32 | `anthropic/claude-haiku-5.5` | Anthropic: Claude Haiku 5.5 | 0.1 | 0.5 | 0.01 | 0.2 | 3.75 | 1M | 125K | text+image+file | yes (5/5 endpoints) | yes | >100K prompt: $0.5/$2.50; `:batch` variant exists | [anthropic.md](anthropic.md) |
| 33 | `~openai/gpt-luna-latest` | OpenAI: GPT Luna Latest | 0.1 | 0.5 | 0.01 | 0.2 | 3.75 | 1M | 125K | file+image+text | yes | yes | >272K prompt: $0.2/$0.75; alias → `openai/gpt-6-luna` | [openai.md](openai.md) |
| 34 | `nvidia/nemotron-3.5-super-vl` | NVIDIA: Nemotron 3.5 Super VL | 0.15 | 0.47 | 0.02 | 0.23 | 5.21 | 1M | 922K | text+image+video | yes (11/11 endpoints) | yes | `:free` variant exists | [nvidia.md](nvidia.md) |
| 35 | `google/gemma-4-31b-it` | Google: Gemma 4 31B | 0.2 | 0.4 | — | 0.25 | 6.60 | 256K | 16K | image+text+video | yes (16/18 endpoints) | yes | `:free` variant exists | [google.md](google.md) |
| 36 | `~z-ai/glm-latest` | Z.ai: GLM Latest | 0.0699 | 1.40 | 0.0689 | 0.4024 | 4.20 | 1M | 922K | text | yes | yes | alias → `z-ai/glm-5.3` | [z-ai.md](z-ai.md) |

## Price range across hosting providers

OpenRouter routes each request to one of several hosts. Prices, quantization (fp4/fp8/bf16) and tool support vary by host. Pin a host with `provider.order` / `provider.only`, or filter on `provider.quantizations`, if quality or tool-calling consistency matters.

| Model ID | # hosts | Hosts with tools | Input min–max | Output min–max | Quantizations seen |
|---|---:|---:|---|---|---|
| `upstage/solar-mini-4-5` | 1 | 1 | 0.01–0.01 | 0.04–0.04 | unknown |
| `mistralai/mistral-nemo` | 5 | 3 | 0.0166–0.15 | 0.0216–0.15 | fp8, unknown |
| `meta-llama/llama-3.1-8b-instruct` | 4 | 3 | 0.02–0.22 | 0.04–0.22 | bf16, fp8, unknown |
| `openai/gpt-oss-20b` | 11 | 10 | 0.017–0.169 | 0.085–0.3 | bf16, fp4, fp8, unknown |
| `inclusionai/ling-3.0-flash` | 2 | 2 | 0.021–0.06 | 0.063–0.18 | fp4, fp8 |
| `nvidia/nemotron-3.5-lightning` | 5 | 5 | 0.02–0.07 | 0.096–0.2 | bf16, fp4, int4, unknown |
| `qwen/qwen3.7-flash` | 1 | 1 | 0.03–0.03 | 0.13–0.13 | unknown |
| `~z-ai/glm-flash-latest` | router alias | — | — | — | see alias target |
| `google/gemma-3-4b-it` | 4 | 0 | 0.04–0.075 | 0.05–0.15 | bf16 |
| `openai/gpt-oss-120b` | 23 | 20 | 0.03–0.35 | 0.15–0.95 | bf16, fp16, fp4, fp8, int4, unknown |
| `tencent/hy4-flash` | 3 | 3 | 0.035–0.07 | 0.1405–0.281 | fp4, fp8, unknown |
| `cohere/command-r7b-12-2024` | 1 | 1 | 0.0375–0.0375 | 0.15–0.15 | unknown |
| `mistralai/mistral-small-24b-instruct-2501` | 2 | 0 | 0.04–0.05 | 0.064–0.08 | fp8 |
| `~deepseek/deepseek-v4-flash-latest` | router alias | — | — | — | see alias target |
| `google/gemma-3-12b-it` | 4 | 1 | 0.04–0.35 | 0.12–0.45 | bf16, int4 |
| `upstage/solar-mini4` | 2 | 2 | 0.05–0.05 | 0.2–0.2 | unknown |
| `deepseek/deepseek-v4.1-flash` | 39 | 39 | 0.0507–1.50 | 0.2028–6.00 | fp4, fp8, mxfp4, unknown |
| `meta-llama/llama-3.2-3b-instruct` | 1 | 0 | 0.05–0.05 | 0.33–0.33 | bf16 |
| `nvidia/nemotron-3-nano-30b-a3b` | 1 | 1 | 0.06–0.06 | 0.24–0.24 | fp8 |
| `~deepseek/deepseek-flash-latest` | router alias | — | — | — | see alias target |
| `openai/gpt-oss-safeguard-20b` | 2 | 2 | 0.07–0.075 | 0.2–0.3 | unknown |
| `openai/gpt-5-nano` | 3 | 3 | 0.025–0.05 | 0.2–0.4 | unknown |
| `qwen/qwen3.5-flash-02-23` | 1 | 1 | 0.065–0.065 | 0.26–0.26 | unknown |
| `qwen/qwen3.5-9b` | 8 | 7 | 0.08–0.17 | 0.12–0.25 | bf16, fp4, fp8, unknown |
| `nvidia/nemotron-3.5-super-vl` | 11 | 11 | 0.06–1.00 | 0.35–3.00 | bf16, fp4, nvfp4, unknown |
| `google/gemma-3-27b-it` | 6 | 3 | 0.064–0.12 | 0.128–0.45 | fp8 |
| `inclusionai/ling-3.1-flash` | 1 | 1 | 0.075–0.075 | 0.225–0.225 | fp8 |
| `qwen/qwen3-coder-30b-a3b-instruct` | 2 | 2 | 0.07–0.15 | 0.28–0.6 | fp8, unknown |
| `z-ai/glm-4.7-flash` | 1 | 1 | 0.0605–0.0605 | 0.4–0.4 | unknown |
| `qwen/qwen3-32b` | 5 | 3 | 0.064–0.14 | 0.224–0.57 | fp8 |
| `meta/muse-spark-1.3-contributor` | 1 | 1 | 0.1–0.1 | 0.2–0.2 | unknown |
| `qwen/qwen3-30b-a3b-instruct-2507` | 2 | 2 | 0.09–0.1 | 0.3–0.3 | fp8 |
| `google/gemma-4-31b-it` | 18 | 16 | 0.1–0.75 | 0.1–1.15 | bf16, fp4, fp8, unknown |
| `anthropic/claude-haiku-5.5` | 5 | 5 | 0.1–0.1 | 0.5–0.5 | unknown |
| `~openai/gpt-luna-latest` | router alias | — | — | — | see alias target |
| `~z-ai/glm-latest` | router alias | — | — | — | see alias target |

### Alias targets (as of 2026-11-25)

| Alias | Resolves to | Alias headline price (in/out) | Target's host range (in / out) | Target's first-party price |
|---|---|---|---|---|
| `~z-ai/glm-flash-latest` | `z-ai/glm-5.3-flash` | 0.0356 / 0.0815 | 0.0356–0.225 / 0.0815–0.75 (42 hosts) | Z.AI 0.15 / 0.50 |
| `~z-ai/glm-latest` | `z-ai/glm-5.3` | 0.0699 / 1.40 | 0.0699–2.10 / 1.40–6.60 (48 hosts) | Z.AI 1.40 / 4.40 |
| `~deepseek/deepseek-v4-flash-latest` | `deepseek/deepseek-v4-flash-0731` | 0.0453 / 0.136 | 0.0453–0.44 / 0.136–1.32 (25 hosts) | — (DeepSeek's API now routes old V4 Flash names to V4.1 Flash 1017) |
| `~deepseek/deepseek-flash-latest` | `deepseek/deepseek-v4.1-flash-1017` | 0.036 / 0.50 | 0.035–0.60 / 0.10–2.40 (56 hosts) | DeepSeek 0.15 / 0.60 |
| `~openai/gpt-luna-latest` | `openai/gpt-6-luna` | 0.10 / 0.50 | 0.05–0.20 / 0.25–1.00 (6 endpoints incl. flex/priority tiers) | OpenAI 0.10 / 0.50 |

> **Alias caveat:** the headline price of an alias is the cheapest host. With default load balancing, real spend usually lands nearer the median host price: GLM 5.3 Flash ≈ 0.13 / 0.50, DeepSeek V4.1 Flash 1017 ≈ 0.15 / 0.67, GLM 5.3 ≈ 1.2 / 4.4. To get the headline price, sort by price (`provider.sort: "price"`) or pin the cheap host. The alias can also move to a new model without warning, which changes both behaviour and price.

## Things that will change your bill

- **Tiered long-context pricing.** Three models charge more once the prompt passes a threshold, and coding agents reach those thresholds quickly:
  - `qwen/qwen3.7-flash`: 0.03/0.13 below 32K → **0.10/0.40 above 32K** → **0.20/0.80 above 256K**. Most opencode and pi turns are above 32K once a session gets going.
  - `anthropic/claude-haiku-5.5`: 0.10/0.50 → **0.50/2.50 above 100K prompt tokens**.
  - `~openai/gpt-luna-latest` (GPT-6 Luna): 0.10/0.50 → **0.20/0.75 above 272K**.
  - pi had a bug where OpenRouter tiered pricing was ignored in its cost display (earendil-works/pi#10669, since fixed). Treat a harness's cost meter as an estimate.
- **Preview and promo prices end.** `upstage/solar-mini-4-5` is at a 90% preview discount (0.01/0.04). Third-party reports say the preview ends **2026-11-30** and list price after the 2026-12-01 GA is 0.10/0.40. Solar Mini 4's 0.05/0.20 is also described as promotional (list 0.10/0.40).
- **Deprecation.** `openai/gpt-5-nano` has an OpenRouter expiration date of **2026-12-11**, matching OpenAI's API retirement. OpenAI's suggested replacement is in the GPT-5.6/GPT-6 Luna line.
- **Free and batch variants.** `:free` variants exist for `nvidia/nemotron-3.5-lightning`, `nvidia/nemotron-3.5-super-vl` and `google/gemma-4-31b-it`, with OpenRouter free-tier rate limits of roughly 20 req/min and a small daily cap. `:batch` (async, roughly half price) exists for `anthropic/claude-haiku-5.5`, `openai/gpt-6-luna` and `deepseek/deepseek-v4.1-flash`. Batch is not usable from an interactive agent.
- **Reasoning tokens bill as output.** Models whose reasoning is on by default (GLM 5.3 / 5.3 Flash default effort is `max`, DeepSeek V4.x Flash defaults to `high`) can spend many times more output tokens than the visible answer. For DeepSeek V4.1 Flash, Artificial Analysis calls it "one of the most verbose models we've measured". Ling 3.0 Flash showed similar verbosity.

## Regenerating this table

```bash
curl -s https://openrouter.ai/api/v1/models -o models.json
curl -s https://openrouter.ai/api/v1/models/<author>/<slug>/endpoints   # per-host prices, quantization, tool support
```
