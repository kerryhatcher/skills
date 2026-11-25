# NVIDIA

## Provider overview

- **Who:** NVIDIA's **Nemotron** model family. It is released as open models, usually with open training data and recipes, under the NVIDIA Open Model License. The 2025–2026 generations (Nemotron 3, Nemotron 3.5) use a **hybrid Mamba-2 + Transformer MoE** design ("NemotronH"), tuned for throughput on NVIDIA hardware. Many are also published as NVFP4 checkpoints.
- **Positioning:** high-throughput models for agentic AI and for fine-tuning into domain-specific agents. NVIDIA openly says some of these models are *not* frontier reasoning engines.
- **OpenRouter presence:** many third-party hosts (Fireworks, DeepInfra, CoreWeave, Crusoe, Together, Nebius, BaseTen and others), several at fp4/int4. Several models have **`:free` variants** on OpenRouter.

### opencode / pi at the provider level
- **pi:** inline local tool-schema references for Nemotron and Qwen (earendil-works/pi#10270, fixed: Nemotron chat templates choked on `$ref`). pi's default NVIDIA model was updated for Nemotron 3.5 (#10907). A `thinkingLevelMap.off` type guard caused 400s on OpenRouter reasoning models (#11300, fixed).
- **opencode:** the NVIDIA NIM provider rejected the `prompt_cache_key` that opencode V2 sends (anomalyco/opencode#49240, fixed), and there was an older "NVIDIA connector is experiencing CRITICAL issues" report (#10885). Both concern NVIDIA's own build.nvidia.com endpoint, not OpenRouter.

---

## `nvidia/nemotron-3-nano-30b-a3b`: Nemotron 3 Nano 30B A3B

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2025-12-14 |
| Architecture | hybrid Mamba-Transformer MoE, **~31.6B total / ~3.2B active**, open weights and data |
| Context / max output | 262,144 (native model supports up to 1M) / 235,929 |
| Price (in / out / cache, $/M) | **0.06 / 0.24 / 0.012** (Nebius only, fp8) |
| Tools / reasoning | yes / yes (reasoning on/off with a thinking budget) |

**Advertised strengths:** "highest compute efficiency and accuracy for developers to build specialized agentic AI systems". Fully open (weights, data, recipes). NVIDIA claimed up to about 3–4× the throughput of similar-size dense or MoE models.

**Benchmarks (vendor, Dec 2025):** competitive with Qwen3-30B-A3B and gpt-oss-20b on reasoning (AIME, GPQA), coding (LiveCodeBench) and long context (RULER at 1M). *Independent:* Artificial Analysis rated it among the top small open models at launch, with very high speed. It is now superseded by Nemotron 3.5 Lightning.

**opencode / pi:** no model-specific issues. Generic Nemotron template issues apply (pi#10270, fixed).

**Verdict:** superseded. **Nemotron 3.5 Lightning is the same size class, cheaper on some hosts, newer, and has a free tier.**

---

## `nvidia/nemotron-3.5-lightning`: Nemotron 3.5 Lightning

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-08-11 |
| Architecture | hybrid MoE, **30B total / 3B active** (`nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-BF16`) |
| Context / max output | 1,048,576 on ModelRun; 262,144 on the other hosts / 235,929 |
| Price (in / out / cache, $/M) | **0.07 / 0.20 / 0.04** (host range 0.02–0.07 / 0.096–0.20). **`:free` variant available** |
| Tools | yes (5/5 hosts: Darkbloom int4, Fireworks, DeepInfra bf16, ModelRun fp4, CoreWeave bf16) |

**Advertised strengths:** high-throughput agentic workloads and fine-tuning into specialized agents. NVIDIA claims **up to 4× the output speed** of similar-sized models. OpenRouter reports it finishes 10,000 tasks **about 30% faster than Qwen3.6-35B at similar accuracy**. The model card says plainly that **it is not positioned as a reasoning engine**.

**Benchmarks (vendor, BF16 / NVFP4)**
- SWE-bench Verified **51.56 / 52.80**; PinchBench 85.37 / 83.43; Terminal-Bench 2.1 24.58; BrowseComp 36.97; IFBench (loose) 71.88
- MMLU-Pro 81.94; GPQA Diamond (no tools) 75.44; HLE 11.72; SciCode 32.60
- No independent reproduction was available at review time (DataCamp).

**Reviews / tests:** Thoughtworks fine-tuned it for legal and healthcare. Its legal adapter was preferred in **75%** of blind comparisons and more than doubled accuracy on a public legal benchmark. The healthcare adapter was preferred in 60%.

**opencode / pi**
- *opencode:* **"Nemotron 3.5 Lightning Free repeatedly corrupts Linux paths after correction"** (anomalyco/opencode#59602, closed). It kept mangling file paths even after the user corrected them, a typical weakness of 3B-active models in edit-heavy loops.
- *pi:* no Lightning-specific bugs. The Nemotron schema fix (#10270) applies.

**Verdict:** very fast and cheap (free tier). Good for subagents, search and exploration, and classification. Weak at long multi-step coding (Terminal-Bench 24.6). Not a primary agent model.

---

## `nvidia/nemotron-3.5-super-vl`: Nemotron 3.5 Super VL

| Field | Value (OpenRouter, 2026-11-25) |
|---|---|
| Released | 2026-10-15 |
| Architecture | NemotronH hybrid Mamba-2 + attention MoE, **120B total / 12B active**, plus a RADIO v2.5-H vision encoder (`nvidia/NVIDIA-Nemotron-3.5-Super-VL-120B-A12B-BF16`) |
| Context / max output | 1,048,576 on Crusoe, PrimeIntellect, CoreWeave, PrimaLabs, BaseTen and Nebius; 262,144 on the others / 943,718 |
| Modalities | text + image + video → text (documents, GUI screenshots) |
| Price (in / out / cache, $/M) | **0.15 / 0.47 / 0.02** (host range 0.06–1.00 / 0.35–3.00). **`:free` variant available** |
| Tools | yes (11/11 hosts) |

**Advertised strengths:** multimodal agentic tasks: document understanding, GUI and computer-use screenshots, video. NVIDIA claims "leading accuracy" on multimodal agentic tasks and up to **5× higher throughput** than comparable models. It also claims a post-trained version beats Claude Opus 5.5 and GPT-6.1 Sol on *specialized* benchmarks. That claim is unverified.

**Benchmarks**
- *Independent (BenchLM):* MMLongBench-Doc **62.8%**; overall 49.5/100 (#101 of 224); percentiles: agentic 52nd, knowledge 61st, instruction following 51st. BenchLM notes there isn't enough sourced coverage for a verified ranking.
- NVIDIA's full table is in the Nemotron 3.5 Super & Lightning technical report.

**opencode / pi:** no model-specific reports found (too new). Vision input in harnesses is still rough in general. For example, opencode V2 sends image parts without payload after compaction (anomalyco/opencode#60243, open), and pi stops when given too many input images (earendil-works/pi#10162, open).

**Verdict:** a solid open multimodal mid-size model with a free tier. Consider it for screenshot or document-heavy agent flows. For pure coding, DeepSeek V4.1 Flash or GLM 5.3 Flash give more per dollar.

---

## Sources
- OpenRouter API snapshot, 2026-11-25
- [NVIDIA Nemotron 3.5 Super and Lightning Technical Report](https://research.nvidia.com/labs/nemotron/files/NVIDIA-Nemotron-3.5-Super-and-Lightning-Technical-Report.pdf)
- [DataCamp: Nemotron 3.5 Lightning](https://www.datacamp.com/blog/nemotron-3-5-lightning) · [Thoughtworks: Putting Nemotron 3.5 Lightning to the test](https://www.thoughtworks.com/en-de/insights/blog/generative-ai/putting-nvidia-nemotron-3-5-lightning-test)
- [NVIDIA AutoModel docs: Nemotron 3.5 Super VL](https://docs.nvidia.com/nemo/automodel/model-coverage/omni/nvidia/nemotron-3-5-super-vl) · [Raschka LLM architecture gallery](https://sebastianraschka.com/llm-architecture-gallery/models/nemotron-3-5-super-vl-120b-a12b/) · [BenchLM](https://benchlm.ai/models/nemotron-3-5-super-vl-120b-a12b) · [Tech Insider](https://tech-insider.org/nvidia-nemotron-3-5-super-vl-2026/) · [llm-stats](https://llm-stats.com/models/nemotron-3.5-super-vl-120b-a12b)
- NVIDIA Nemotron 3 Nano model card / blog (Dec 2025)
- opencode issues: [#59602](https://github.com/anomalyco/opencode/issues/59602), [#49240](https://github.com/anomalyco/opencode/issues/49240), [#10885](https://github.com/anomalyco/opencode/issues/10885), [#60243](https://github.com/anomalyco/opencode/issues/60243)
- pi issues: [#10270](https://github.com/earendil-works/pi/issues/10270), [#10907](https://github.com/earendil-works/pi/issues/10907), [#11300](https://github.com/earendil-works/pi/issues/11300), [#10162](https://github.com/earendil-works/pi/issues/10162)
