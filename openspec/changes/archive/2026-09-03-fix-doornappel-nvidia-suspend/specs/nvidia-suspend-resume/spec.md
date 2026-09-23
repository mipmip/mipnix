## ADDED Requirements

### Requirement: Nvidia hosts preserve video memory across suspend
Hosts using the proprietary Nvidia driver SHALL enable Nvidia power management so the
driver saves and restores video memory across a suspend/resume cycle, and the graphical
session SHALL return without video-memory allocation failures.

#### Scenario: Resume after suspend
- **WHEN** an Nvidia host resumes from suspend (sleep)
- **THEN** the display SHALL restore correctly and the kernel log SHALL NOT show
  `[nvidia-drm] Failed to allocate NVKMS memory for GEM object` errors

#### Scenario: Suspend/resume services installed
- **WHEN** the Nvidia host is built
- **THEN** the `nvidia-suspend`, `nvidia-resume`, and `nvidia-hibernate` systemd services
  SHALL be present (via `hardware.nvidia.powerManagement.enable`)
