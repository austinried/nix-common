{ pkgs }:

pkgs.writeShellApplication {
  name = "run-nixos-vm";
  runtimeInputs = with pkgs; [
    virt-viewer
  ];

  text = ''
    "./result/bin/run-$1-vm" & PID_QEMU="$!"
    sleep 1 # I think some tools have an option to wait like -w
    remote-viewer spice://127.0.0.1:5930
    kill $PID_QEMU
  '';
}
