{
  # Options for testing this config in a VM (nixos-rebuild build-vm)
  virtualisation.vmVariant = {
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
    
    virtualisation = {
      cores = 4;
      memorySize = 4096;

      # qemu options to get copy/paste and guest integrations working
      # https://discourse.nixos.org/t/get-qemu-guest-integration-when-running-nixos-rebuild-build-vm/22621
      qemu.options = [
        # vga changed to virtio so that auto resize resolution works
        "-vga virtio"
        "-spice port=5930,disable-ticketing=on"
        "-device virtio-serial-pci"
        "-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
        "-chardev spicevmc,id=spicechannel0,name=vdagent"
      ];
    };

    # For copy/paste to work
    services.spice-vdagentd.enable = true;
    services.xserver.xkb.layout = "us";
  };
}
