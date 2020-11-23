# Notice:

As of [this commit](https://github.com/nix-community/emacs-overlay/commit/4629eb4142029522703cd8ee3247397ae038d047) emacsPgtk + native-comp is now part of the [nix-community emacs-overlay](https://github.com/nix-community/emacs-overlay). I will maintain this overlay for the sole purpose of providing builds for nativecomp for mac until such builds are available from the nix-community hydra.

# To get nix and set up the binary cache

Follow the instructions [here](https://app.cachix.org/cache/mjlbach) to set up nix and add my cachix cache which provides precompiled binaries, built against the nixos-unstable channel each night.

# To use the overlay

Add the following to your $HOME/.config/nixpkgs/overlays directory: (make a file $HOME/.config/nixpkgs/overlays/emacs.nix and paste the snippet below into that file)

```nix
import (builtins.fetchTarball {
      url = https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/master.tar.gz;
    })
```

Install emacsGccPgtk (only compatible with linux):
```
nix-env -iA nixpkgs.emacsGccPgtk
```

Install emacsGcc (compatible with linux and mac):
```
nix-env -iA nixpkgs.emacsGcc
```
or add to home-manager/configuration.nix.
