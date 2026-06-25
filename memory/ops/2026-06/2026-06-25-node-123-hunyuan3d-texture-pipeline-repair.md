# 2026-06-25 node-123 Hunyuan3D texture pipeline repair

## Background

node-123 Hunyuan3D-2.1 Gradio shape generation worked, but the full `/generation_all` path failed in texture generation. The first hard failure was `AttributeError: module 'custom_rasterizer' has no attribute 'rasterize'`; after the CUDA extension was repaired, the next blocker was CUDA OOM in the texture multiview VAE decode on the 24GB RTX 4090D.

## Changes

- Compiled `custom_rasterizer_kernel` under `/opt/hunyuan3d/Hunyuan3D-2.1/hy3dpaint/custom_rasterizer` with `CUDA_HOME=/usr/local/cuda`, CUDA headers on include paths, `CUDACXX=/usr/local/bin/nvcc`, GCC/G++, `FORCE_CUDA=1`, and `TORCH_CUDA_ARCH_LIST=8.9`.
- Installed the extension editable into `/opt/hunyuan3d/hunyuan3d21` using `python setup.py develop`.
- Updated `/opt/hunyuan3d/Hunyuan3D-2.1/hy3dpaint/custom_rasterizer/__init__.py` to export `rasterize` and `interpolate` from `.custom_rasterizer.render`.
- Updated `/opt/hunyuan3d/start_hunyuan3d_gradio.sh` to preserve existing `LD_LIBRARY_PATH` and `PYTHONPATH`, include PyTorch and CUDA libraries, and set `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`.
- Added low-VRAM texture defaults in the start script: `HUNYUAN3D_TEX_MAX_VIEWS=4` and `HUNYUAN3D_TEX_RESOLUTION=512`.
- Updated `/opt/hunyuan3d/Hunyuan3D-2.1/gradio_app.py` so texture config reads those two environment variables, defaulting to `4` and `512`, and clears CUDA cache before entering the texture pipeline in low-VRAM mode.
- Restarted and enabled the user service `hunyuan3d.service`.

## Why This Way

The rasterizer failure was a real missing/incorrect package export plus a compiled extension requirement; fixing that keeps the upstream texture renderer path intact. The later OOM was real memory pressure, not just fragmentation: with `8` views at `768`, the process needed another 3.38GB while already using roughly 21GB. Lowering texture views/resolution gives node-123 a stable default that fits the 4090D while preserving environment variables for future quality tuning.

## Alternatives Not Taken

- Did not disable texture generation; the user asked to cleanly fix the Hunyuan AI deployment.
- Did not keep the previous `8` views / `768` texture setting because repeat `/generation_all` tests OOMed on the 24GB card.
- Did not globally downgrade PyTorch or CUDA because the compiled extension smoke test and full Gradio smoke test pass with the current runtime.

## Validation

- Commands run:
  - `bash -n /opt/hunyuan3d/start_hunyuan3d_gradio.sh`.
  - `/opt/hunyuan3d/hunyuan3d21/bin/python -m py_compile /opt/hunyuan3d/Hunyuan3D-2.1/gradio_app.py`.
  - Minimal CUDA rasterizer smoke test imported `custom_rasterizer`, verified `rasterize`, and returned CUDA outputs with shapes `(16, 16)` and `(16, 16, 3)`.
  - `systemctl --user restart hunyuan3d.service`; then checked service state, API config endpoint, port 7860, and GPU process memory.
  - Gradio client `/generation_all` smoke test with a generated 512x512 image, 5 steps, guidance 5.0, seed 1234, octree resolution 128, `rembg=False`, and `num_chunks=8000`.
- Result:
  - `hunyuan3d.service` is active and enabled.
  - Gradio listens on `0.0.0.0:7860`.
  - `/generation_all` returned a textured GLB successfully.
  - Smoke stats: shape generation about 2.82s, face reduction about 0.04s, texture generation about 23.66s, OBJ-to-GLB conversion about 0.75s, total about 27.27s.
  - Generated smoke file path observed: `/tmp/gradio/d6e6d4ee31d19f03dcf8987a89039981b3b2de1128258fadbee3c64a7a2e1b55/textured_mesh.glb`, about 3.2MB.

## Risks

- Texture quality is intentionally lowered from the previous hardcoded `8` views / `768` resolution default to fit 24GB VRAM reliably. Increase `HUNYUAN3D_TEX_MAX_VIEWS` and `HUNYUAN3D_TEX_RESOLUTION` only after testing.
- `/var/log/hunyuan3d/gradio.log` still contains older pre-fix `custom_rasterizer` and OOM tracebacks. Use timestamps after the final restart around 2026-06-25 14:47 CST when judging current state.
- CUDA runtime remains mixed at system CUDA 13.2 / PyTorch cu124; smoke tests pass, but future extension rebuilds should continue to set include/library paths explicitly.

## Machine / Sync Impact

- [ ] Does not affect long-lived machine or sync documentation.
- [x] Updated `memory/machines/123.md`.
- [ ] Updated `memory/sync/...`:
- [ ] Updated relevant runbook:

## Handoff Notes

For future Hunyuan3D work on node-123, start with `ssh node-123-lan`, `systemctl --user status hunyuan3d.service`, `tail -n 120 /var/log/hunyuan3d/gradio.log`, and `nvidia-smi`. If full texture quality is needed, raise `HUNYUAN3D_TEX_MAX_VIEWS` / `HUNYUAN3D_TEX_RESOLUTION` incrementally and rerun `/generation_all` instead of returning directly to `8` / `768`.

## Related Files

- Remote start script: `/opt/hunyuan3d/start_hunyuan3d_gradio.sh`.
- Remote Gradio app: `/opt/hunyuan3d/Hunyuan3D-2.1/gradio_app.py`.
- Remote rasterizer package: `/opt/hunyuan3d/Hunyuan3D-2.1/hy3dpaint/custom_rasterizer/`.
- Remote service: `/home/sl123/.config/systemd/user/hunyuan3d.service`.
- Remote log: `/var/log/hunyuan3d/gradio.log`.
- Machine memory: `memory/machines/123.md`.
