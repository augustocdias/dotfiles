# Work-related system services (virtualization)
{...}: {
  # Enable libvirtd for QEMU/KVM virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # TPM emulation for Windows 11
      swtpm.enable = true;
    };
  };

  # Enable virt-manager GUI
  programs.virt-manager.enable = true;

  # USB redirection for VMs
  virtualisation.spiceUSBRedirection.enable = true;
}
