# OpenRouter low-cost model research (2026-11-25)

Research on 36 OpenRouter model IDs: provider background, advertised strengths, benchmarks and reviews, price, and how each model behaves in the **opencode** (`anomalyco/opencode`, formerly `sst/opencode`) and **pi** (`earendil-works/pi`, formerly `badlogic/pi-mono`, pi.dev) coding-agent harnesses.

- Pricing table: [openrouter-pricing.md](openrouter-pricing.md)
- Provider reports:

| Provider | File | Models covered |
|---|---|---|
| Anthropic | [anthropic.md](anthropic.md) | claude-haiku-5.5 |
| Cohere | [cohere.md](cohere.md) | command-r7b-12-2024 |
| DeepSeek | [deepseek.md](deepseek.md) | deepseek-v4.1-flash, ~deepseek-v4-flash-latest, ~deepseek-flash-latest |
| Google | [google.md](google.md) | gemma-3-4b-it, gemma-3-12b-it, gemma-3-27b-it, gemma-4-31b-it |
| inclusionAI (Ant Group) | [inclusionai.md](inclusionai.md) | ling-3.0-flash, ling-3.1-flash |
| Meta | [meta.md](meta.md) | llama-3.1-8b-instruct, llama-3.2-3b-instruct, muse-spark-1.3-contributor |
| Mistral AI | [mistral.md](mistral.md) | mistral-nemo, mistral-small-24b-instruct-2501 |
| NVIDIA | [nvidia.md](nvidia.md) | nemotron-3-nano-30b-a3b, nemotron-3.5-lightning, nemotron-3.5-super-vl |
| OpenAI | [openai.md](openai.md) | gpt-oss-20b, gpt-oss-120b, gpt-oss-safeguard-20b, gpt-5-nano, ~gpt-luna-latest |
| Qwen (Alibaba) | [qwen.md](qwen.md) | qwen3-32b, qwen3-30b-a3b-instruct-2507, qwen3-coder-30b-a3b-instruct, qwen3.5-9b, qwen3.5-flash-02-23, qwen3.7-flash |
| Tencent | [tencent.md](tencent.md) | hy4-flash |
| Upstage | [upstage.md](upstage.md) | solar-mini4, solar-mini-4-5 |
| Z.ai (Zhipu) | [z-ai.md](z-ai.md) | glm-4.7-flash, ~glm-flash-latest, ~glm-latest |

## Method and confidence

- **Prices, context, modalities, hosts, quantization and tool support** come straight from OpenRouter's public API on 2026-11-25. These are the most reliable facts in this research.
- **Benchmarks** are labelled *vendor-reported* or *independent* (Artificial Analysis, Vals.ai, Epoch AI, BenchLM, Roboflow and similar). Many 2026 models were weeks old when these notes were written, so independent data is thin and secondary blogs often disagree on parameter counts, dates and scores. Those disagreements are recorded where they came up.
- **opencode / pi findings** come from searching each project's GitHub issue tracker for every model family. Issue numbers are cited so you can check current status. *Closed* usually means fixed in a later release, but some issues were closed as duplicates or "won't fix". Very few public, quantitative user reviews of these specific models inside opencode or pi exist. Where none were found, the file says so.

## Picking a model for opencode / pi: quick guide

Both harnesses are tool-call-heavy agents with large system prompts. In practice:

1. **The model must support tool calls on the host OpenRouter picks.** These models have **no tool-capable endpoint on OpenRouter today**: `google/gemma-3-4b-it`, `meta-llama/llama-3.2-3b-instruct` and `mistralai/mistral-small-24b-instruct-2501`. They can't drive either harness. Several others have tools on only some hosts (Gemma 3 12B: 1/4, Gemma 3 27B: 3/6, Mistral Nemo: 3/5, Qwen3 32B: 3/5). Pin a tool-capable host with `provider.only`, or set `require_parameters: true`.
2. **Context is spent quickly.** A fresh opencode session has been measured sending about 42K input tokens before the user types anything (anomalyco/opencode#38076). Models capped at 32K (Mistral Small 3) or 40K on some hosts (Qwen3 32B on DeepInfra) will overflow.
3. **Tiered pricing applies to most real agent turns** (Qwen3.7 Flash above 32K, Haiku 5.5 above 100K). See the pricing file.
4. **Reasoning-field handling is the most common integration bug.** Both trackers have many issues about `reasoning` / `reasoning_content` being dropped, leaked into text, or replayed to hosts that reject it. These affect DeepSeek, GLM, gpt-oss, Qwen and Muse Spark. Keep both harnesses updated.

| Tier | Candidates (from this list) | Why |
|---|---|---|
| Best value for agentic coding | `deepseek/deepseek-v4.1-flash` (or `~deepseek/deepseek-flash-latest`), `~z-ai/glm-flash-latest` (GLM 5.3 Flash) | Strongest benchmark profiles at under $0.25/M blended, 1M context, wide host support. Both have known reasoning-display quirks in opencode. |
| Strong small proprietary | `anthropic/claude-haiku-5.5`, `~openai/gpt-luna-latest` (GPT-6 Luna) | First-party quality and tool-call reliability. Watch tiered pricing. |
| Cheap and capable open MoE | `nvidia/nemotron-3.5-lightning`, `openai/gpt-oss-120b`, `tencent/hy4-flash`, `inclusionai/ling-3.1-flash`, `google/gemma-4-31b-it` | Good for subagents, bulk edits and exploration. Mixed reports on long multi-step sessions. |
| Experimental / caveated | `upstage/solar-mini-4-5` (preview ends 2026-11-30), `meta/muse-spark-1.3-contributor` (trains on your data), `~z-ai/glm-latest` (output-heavy price) | See the provider files. |
| Not suitable for agent harnesses | Gemma 3 (all), Llama 3.1 8B / 3.2 3B, Mistral Nemo / Small 3, Command R7B, gpt-oss-safeguard-20b | Weak or absent tool calling, short output caps, or built for another purpose (classification, RAG). |
