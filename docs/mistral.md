# Mistral AI

## Provider overview

- **Who:** Mistral AI is a Paris-based company founded in 2023 by former DeepMind and Meta researchers. It publishes open-weight (mostly Apache 2.0) and commercial models, including Mistral Small/Medium/Large, Codestral, Devstral, Pixtral and Magistral.
- **Positioning:** efficient European models, strong multilingual support, permissive licences on the smaller models, and EU data residency through La Plateforme.
- **On OpenRouter:** the two requested models are **older-generation** (2024 and early 2025). Mistral has since shipped Mistral Small 3.1/3.2/4, Devstral and others, and those newer models are the ones built for agentic coding.

### opencode / pi at the provider level
- **Message-role strictness:** Mistral's API rejects some conversation shapes that coding agents produce, for example "conversation roles must alternate user and assistant" (Mistral Small 4 in opencode, anomalyco/opencode#18998). opencode applies a Mistral-specific tool-call transform, and some model families once skipped it (anomalyco/opencode#16636, fixed).
- **Tool-call ID format:** Mistral requires 9-character alphanumeric tool-call IDs. opencode's normalization for this has caused collisions when histories from other models are replayed (anomalyco/opencode#58323, open; GLM IDs collapsed to `chatcmplt`).
- **pi:** the Mistral SDK's stricter Zod validation once broke calls (earendil-works/pi#3361, fixed). There were also Mistral Small 4 reasoning-mode errors (earendil-works/pi#3096, #3338).
- These issues concern the **direct Mistral provider**. Through OpenRouter, the OpenAI-compatible path is used and most of them don't apply, but the role-alternation constraint can still surface when Mistral itself is the upstream host.

---

## `mistralai/mistral-nemo`: Mistral Nemo (12B)

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2024-07-18 (with NVIDIA) |
| Architecture | Dense 12B, Tekken tokenizer, Apache 2.0 (`mistralai/Mistral-Nemo-Instruct-2407`) |
| Context / max output | 131,072 / 16,384 |
| Modalities | text → text |
| Price (in / out, $/M) | **0.029 / 0.03** (host range 0.0166–0.15 / 0.0216–0.15) |
| Features | tools on **3 of 5** hosts (Io Net, DeepInfra (one of two), Mistral). Parasail and one DeepInfra endpoint have no tools. |
| Hosts | Io Net, DeepInfra ×2, Parasail, Mistral |

**Advertised strengths:** a drop-in replacement for Mistral 7B, with multilingual support (EN, FR, DE, ES, IT, PT, ZH, JA, KO, AR, HI), function calling, 128K context, and quantization-aware training for FP8.

**Benchmarks (vendor, 2024):** MMLU ≈ 68%, and it beat Gemma 2 9B and Llama 3 8B on most of Mistral's comparisons at launch. These numbers are badly outdated by 2026 standards. Modern 3B-active MoE models beat it easily.

**Reviews:** long popular for role-play, creative writing and cheap multilingual chat thanks to its permissive licence and low price. It is not regarded as a coding or agent model.

**opencode / pi:** no model-specific issues; it simply isn't used for agentic coding. If you try it, pin a tool-capable host, because default routing may pick Parasail, which has no tools.

**Verdict:** a very cheap text model for chat, translation or classification. **Not recommended for opencode or pi.**

---

## `mistralai/mistral-small-24b-instruct-2501`: Mistral Small 3

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-01-30 |
| Architecture | Dense 24B, Apache 2.0 |
| Context / max output | **32,768** / 16,384 |
| Modalities | text → text |
| Price (in / out, $/M) | **0.05 / 0.08** |
| Features | structured outputs, `response_format`. **No `tools` on either OpenRouter endpoint** (DeepInfra ×2) |

**Advertised strengths:** "latency-optimized" 24B model. Mistral claimed performance comparable to Llama 3.3 70B and Qwen 2.5 32B at roughly 3× the speed, MMLU > 81%, and about 150 tok/s. Fits on a single RTX 4090 when quantized. Good base for fine-tuning.

**Benchmarks (vendor, Jan 2025):** MMLU ~81%, HumanEval ~84.8%, MT-Bench ~8.35. Superseded by Small 3.1 (vision, 128K), 3.2 and 4.

**opencode / pi:**
- **Not usable through OpenRouter as an agent.** Neither OpenRouter host exposes tool calling, and the 32K context is smaller than opencode's baseline prompt (~42K tokens on a fresh session, anomalyco/opencode#38076).
- If you want Mistral Small in an agent, use a newer version (Small 3.2 or 4) through Mistral's own provider, and be aware of the role-alternation and reasoning-mode issues noted above.

**Verdict:** a cheap, decent general text model for short-context structured-output tasks. **Not suitable for opencode or pi via OpenRouter.**

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- Mistral AI launch posts: "Mistral NeMo" (2024-07-18) and "Mistral Small 3" (2025-01-30), mistral.ai/news
- opencode issues: [#18998](https://github.com/anomalyco/opencode/issues/18998), [#16636](https://github.com/anomalyco/opencode/issues/16636), [#58323](https://github.com/anomalyco/opencode/issues/58323), [#38076](https://github.com/anomalyco/opencode/issues/38076)
- pi issues: [#3361](https://github.com/earendil-works/pi/issues/3361), [#3096](https://github.com/earendil-works/pi/issues/3096), [#3338](https://github.com/earendil-works/pi/issues/3338)
