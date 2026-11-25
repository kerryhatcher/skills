# Anthropic

## Provider overview

- **Who:** Anthropic, a US AI safety company and maker of **Claude**. Current tiers: Opus (flagship), Fable, Sonnet and Haiku (small and fast). Models are proprietary and served through the Anthropic API, Amazon Bedrock, Google Vertex AI and Microsoft Azure / Foundry.
- **Positioning for Haiku:** high-volume, cost-sensitive work such as summarization, **subagents**, browser and computer use, and coding helpers.
- **OpenRouter presence:** five endpoints (Anthropic, Claude Platform on AWS, Bedrock, Google, Azure), all at the same price.

### opencode / pi at the provider level
Claude models are first-class in both harnesses: native Anthropic Messages API, prompt caching, and extended thinking. Recurring integration themes:
- **Thinking blocks and signatures:** replayed signed thinking blocks after compaction or tool-list changes cause persistent 400s (earendil-works/pi#11610, #10954, fixed). Effort switches can rewrite the cached conversation or send the wrong effort (anomalyco/opencode#62555, open). opencode injects `thinking.block_binding` unconditionally for anthropic-compatible providers (#55160, open).
- **Effort handling:** an `anthropic-beta` override makes managed-effort models fail with 400 (pi#10759, fixed). On Bedrock, the "none" variant keeps `reasoningConfig.display` and fails with 400 (opencode#59317, open).
- Prompt caching works well through OpenRouter for Anthropic models, and it matters a lot for agent cost (cache read is 10% of input).

---

## `anthropic/claude-haiku-5.5`: Claude Haiku 5.5

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-10-07, nine days after Claude Sonnet 5.5 |
| Architecture | proprietary |
| Context / max output | 1,000,000 / 128,000 |
| Modalities | text + image + file → text |
| Price ($/M) | **in 0.10 / out 0.50 / cache read 0.01 / cache write 0.125 (5-min) or 0.20 (1-h)**. **Prompts above 100K tokens: 0.50 / 2.50 / 0.05 / 0.625 / 1.00.** Web search $0.01/request. `:batch` 0.05/0.25 |
| Tools / reasoning | yes (5/5) / yes, efforts `none` → `max`, **default `medium`**, plus `verbosity` |

**Advertised strengths:** succeeds Haiku 4.5 (which cost 1.00 / 5.00, so 5.5 is **10× cheaper**), with stronger coding, computer use and professional-work skills. Positioned for subagents and high-volume pipelines.

**Benchmarks**
- *Vendor (Anthropic charts, mostly max effort):* outperforms GPT-6 Luna on several computer-use, coding and professional-work evals. APEX-SWE Pass@1 **55.1%** (secondary report).
- **Effort matters:** the API default is `medium`. One analysis notes GDPval-AA scores **1277 at medium versus 1620 at max**, so default-effort results are noticeably lower than the launch charts.
- *Independent:* early coverage disagrees. Apidog (2026-10-08) said no independent results had been published yet. DeepLearning.AI's The Batch said independent tests show marked improvement, and called Sonnet 5.5 the stronger coding option. A Towards AI user review: "earned a spot in my real-world workflows".

**opencode / pi**
- *pi:*
  - "Claude Haiku 5.5: thinking can't be turned off, though the API accepts `disabled`" (earendil-works/pi#10753, fixed).
  - opencode-go Haiku 5.5 hit thinking-signature interruption after editing in /context (#11316).
  - Haiku 5.5 was missing from the GitHub Copilot catalog after a refresh (#10630).
  - OpenRouter **tiered (long-context) pricing was missing** from pi's cost accounting (#10669, fixed).

  All closed: **update pi**.
- *opencode:*
  - **"Claude Haiku 5.5 via commandcode fails with 'Invalid discriminator value … messages.N.role' in a long v2 session"** (anomalyco/opencode#63318, **open**). This is a third-party provider route, not OpenRouter.
  - `claude-haiku-5-5` returned 403 on the opencode Go plan (#63148, closed).
  - Go's Anthropic endpoint defaults to dynamic reasoning when `thinking` is omitted (#56678, open).

**Cost behaviour in agents:** coding-agent prompts often pass **100K tokens**, and then the price is **5×** (0.50 / 2.50). Prompt caching (0.01 cache read below 100K, 0.05 above) offsets much of this in long sessions. Make sure caching is enabled; both harnesses do this by default for Anthropic models.

**Verdict:** **the most reliable tool-calling model in this list** and a natural opencode/pi subagent or main model for medium tasks. At 0.10 / 0.50 it is close to the open-weight Flash models in price, but the >100K price tier and `medium` default effort need watching. Set effort explicitly (`high` for coding) and keep context below 100K where you can.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- [Apidog: Claude Haiku 5.5 benchmarks](https://apidog.com/blog/claude-haiku-5-5-benchmarks/) · [DeepLearning.AI: Claude fills out its model family](https://www.deeplearning.ai/the-batch/claude-fills-out-its-model-family/) · [ComputingForGeeks](https://computingforgeeks.com/claude-haiku-5-5-released-features-benchmarks/) · [dev.to](https://dev.to/hassann/claude-haiku-55-benchmarks-4bm2) · [aiidelist](https://aiidelist.com/blog/claude-haiku-5-5-benchmarks) · [Towards AI user review](https://pub.towardsai.net/claude-haiku-5-5-earned-a-spot-in-my-real-world-workflows-b7461598640f) · [DataLearner](https://www.datalearner.com/en/ai-models/pretrained-models/claude-haiku-5-5/analysis)
- pi issues: [#10753](https://github.com/earendil-works/pi/issues/10753), [#11316](https://github.com/earendil-works/pi/issues/11316), [#10630](https://github.com/earendil-works/pi/issues/10630), [#10669](https://github.com/earendil-works/pi/issues/10669), [#11610](https://github.com/earendil-works/pi/issues/11610), [#10954](https://github.com/earendil-works/pi/issues/10954), [#10759](https://github.com/earendil-works/pi/issues/10759)
- opencode issues: [#63318](https://github.com/anomalyco/opencode/issues/63318), [#63148](https://github.com/anomalyco/opencode/issues/63148), [#56678](https://github.com/anomalyco/opencode/issues/56678), [#62555](https://github.com/anomalyco/opencode/issues/62555), [#55160](https://github.com/anomalyco/opencode/issues/55160), [#59317](https://github.com/anomalyco/opencode/issues/59317)
