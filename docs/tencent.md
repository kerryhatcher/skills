# Tencent (Hunyuan / Hy)

## Provider overview

- **Who:** Tencent's foundation-model team. The **Hunyuan** family was rebranded **Hy** for the 2026 generation: Hy3, Hy4 preview, Hy4 and Hy4 flash. Tencent also runs WorkBuddy and other agent products.
- **Positioning:** very low cost per task, aimed at code assistance, agents and office work. Tencent's internal **WorkIndex** benchmark is central to its marketing.
- **Weights:** Tencent has said it will open-source Hy4 flash weights later. The HF ID `tencent/Hy4-flash` is listed, but checkpoints and a licence were not yet released at the time of writing.
- **OpenRouter presence:** Tencent (first party, fp8), Fireworks and DeepInfra (fp4). The full `tencent/hy4` (0.417/1.25) and `tencent/hy4-preview` are also listed.

### opencode / pi at the provider level
- opencode Go offered Hy3 and Hy4 preview. Reported problems: "hy3 and hy4-preview return bare 403 Forbidden" on Go (anomalyco/opencode#50325), and "Tencent Hy3 reasoning selection is gone" (#36812). Go routing broke when `provider.only: tencent` was set (#45996).
- pi: a build failed when OpenRouter removed `tencent/hy3:free` on 2026-07-21 (earendil-works/pi#6891), which shows free variants can disappear without warning.
- An earlier community comparison (May 2026, OpenCode/OpenRouter focus) rated **Hy3 Preview** the cheapest "ultra-cheap bulk worker", with "the weakest full benchmark profile" of its set.

---

## `tencent/hy4-flash`: Hy4 flash

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | **2026-11-16** |
| Architecture | MoE, about **220B total** (some sources say 224B), roughly a quarter of the flagship Hy4's parameters |
| Context / max output | 1,048,576 (Fireworks: 524,288) / 65,536 |
| Modalities | text + image → text |
| Price (in / out / cache read, $/M) | **0.035 / 0.1405 / 0.0015** (Tencent fp8). Fireworks and DeepInfra 0.07/0.281 |
| Tools / reasoning | yes (3/3) / yes |

**Advertised strengths:** code assistance, agents, and low latency and cost. Tencent says cost per task is **about 1/8 of DeepSeek-V4.1-Flash-1017** (Max tier, peak-hour pricing).

**Benchmarks**
- *Vendor:* WorkIndex **42.1** (Hy4 preview 39.7, full Hy4 51.4); MMLU 88.7 (Hy4 Base 91.6); DeepSWE v1.1 **64.6**; OSWorld 2.1 68.1; MMMU-Pro 75.8.
- *Vendor-reported weakness:* Terminal-Bench 4.0 **19.2**, versus 30.0 or 44.4 for full Hy4 (sources disagree) and 40.0 for DeepSeek V4.1 Flash 1017. That is a clear gap on long-horizon terminal tasks.
- *Independent (Vals.ai):* Vals Index **49.16%**, #36 of 43. Terminal-Bench 4.0 **15.15%**; Vibe Code Bench v1.1.1 **61.58%**; best placement #45/100 on Legal Research Bench.

**Reviews:** coverage so far is launch analysis (MindStudio, goremy.ai, atomicagent.io blind test). The consensus is cheap and fast but weak on complex terminal and coding work.

**opencode / pi:** too new (9 days old) for model-specific reports. No Hy4-flash issues in either tracker.

**Verdict:** very cheap with 1M context and vision. A reasonable bulk or subagent worker for office and document tasks. **Not a good primary coding agent**: independent Terminal-Bench scores are low.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- [Vals.ai: Hy4 Flash](https://www.vals.ai/models/tencent_hy4-flash) · [MindStudio: Hy4 Flash specs & benchmarks](https://www.mindstudio.ai/blog/hunyuan-hy4-flash-moe-model) · [MindStudio: architecture](https://www.mindstudio.ai/blog/hy4-flash-model-architecture) · [MindStudio: vs DeepSeek V4 and Hy4](https://www.mindstudio.ai/blog/tencent-hy4-flash-benchmark-cost) · [goremy.ai](https://goremy.ai/blog/articles/tencent-hy4-flash-benchmarks-cost-per-task) · [atomicagent.io blind test](https://atomicagent.io/blog/tencent-hy4-flash/) · [BenchLM](https://benchlm.ai/models/hy4-flash)
- [inksh.in: Practical model evaluation for OpenCode and OpenRouter](https://www.inksh.in/blog/vscode/openrouter-models) (May 2026, covers Hy3 Preview)
- opencode issues: [#50325](https://github.com/anomalyco/opencode/issues/50325), [#36812](https://github.com/anomalyco/opencode/issues/36812), [#45996](https://github.com/anomalyco/opencode/issues/45996)
- pi issues: [#6891](https://github.com/earendil-works/pi/issues/6891)
