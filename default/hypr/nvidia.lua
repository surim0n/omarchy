local paths = require("default.hypr.paths")

local nvidia = paths.omarchy_path .. "/bin/omarchy-hw-nvidia"
local nvidia_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-gsp"
local nvidia_without_gsp = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-without-gsp"
local nvidia_primary = paths.omarchy_path .. "/bin/omarchy-hw-nvidia-primary"

-- These detectors read cached sysfs IDs rather than shelling out to lspci.
-- lspci reads PCI config space, which resumes a runtime-suspended GPU, and on a
-- hybrid laptop that wake alone outlasts Hyprland's 1.5s config reload budget.
if o.shell_succeeds(o.shell_quote(nvidia)) then
  if o.shell_succeeds(o.shell_quote(nvidia_gsp)) then
    hl.env("NVD_BACKEND", "direct")
    -- The vendor variables reach every session process, so they are only
    -- correct when the NVIDIA GPU is the one compositing. On a hybrid laptop
    -- the iGPU composites while the dGPU merely exists, and exporting them
    -- makes Chromium decode video through NVDEC it cannot import.
    if o.shell_succeeds(o.shell_quote(nvidia_primary)) then
      hl.env("LIBVA_DRIVER_NAME", "nvidia")
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
  elseif o.shell_succeeds(o.shell_quote(nvidia_without_gsp)) then
    hl.env("NVD_BACKEND", "egl")
    if o.shell_succeeds(o.shell_quote(nvidia_primary)) then
      hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
  end
end
