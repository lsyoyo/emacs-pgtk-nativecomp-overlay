let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixos-unstable";
  pkgs = import nixpkgs { };
  emacs-pgtk-nativecomp = sources."emacs-pgtk-nativecomp";
  emacs-nativecomp = sources."emacs-nativecomp";
  mkGitEmacs = attrs: builtins.foldl' (drv: fn: fn drv)
    pkgs.emacs
    [

      (drv: drv.override { srcRepo = true; })
      (
        drv:
        if attrs.usePgtk then
          drv.overrideAttrs
            (
              old: {
                pname = "emacsGccPgtk";
                version = "28.0.50";
                src = pkgs.fetchFromGitHub {
                  inherit (emacs-pgtk-nativecomp) owner repo rev sha256;
                };

                configureFlags = old.configureFlags
                  ++ [ "--with-pgtk" ];
              }
            ) else
          drv.overrideAttrs (
            _old: {
              pname = "emacsGcc";
              version = "28.0.50";
              src = pkgs.fetchFromGitHub {
                inherit (emacs-nativecomp) owner repo rev sha256;
              };
            }
          )
      )

      (
        drv: drv.overrideAttrs (
          old: {
            patches = [
              (
                pkgs.fetchpatch {
                  name = "clean-env.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/clean-env.patch";
                  sha256 = "0lx9062iinxccrqmmfvpb85r2kwfpzvpjq8wy8875hvpm15gp1s5";
                }
              )
              (
                pkgs.fetchpatch {
                  name = "tramp-detect-wrapped-gvfsd.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/tramp-detect-wrapped-gvfsd.patch";
                  sha256 = "19nywajnkxjabxnwyp8rgkialyhdpdpy26mxx6ryfl9ddx890rnc";
                }
              )
            ];

            postPatch = old.postPatch + ''
              substituteInPlace lisp/loadup.el \
              --replace '(emacs-repository-get-version)' '"${emacs-pgtk-nativecomp.rev}"' \
              --replace '(emacs-repository-get-branch)' '"master"'
            '';

            configureFlags = old.configureFlags ++ pkgs.stdenv.lib.optional pkgs.stdenv.isDarwin [ "--with-ns" ];

            postInstall = old.postInstall + pkgs.stdenv.lib.optionalString pkgs.stdenv.isDarwin ''
              ln -snf $out/lib/emacs/28.0.50/native-lisp $out/native-lisp
              ln -snf $out/lib/emacs/28.0.50/native-lisp $out/Applications/Emacs.app/Contents/native-lisp
              cat <<EOF> $out/bin/run-emacs.sh
              #!/usr/bin/env bash
              set -e
              exec $out/bin/emacs-28.0.50 "\$@"
              EOF
              chmod a+x $out/bin/run-emacs.sh
              ln -snf ./run-emacs.sh $out/bin/emacs
            '';
          }
        )
      )
      (
        drv: drv.override {
          nativeComp = true;
        }
      )
    ];
in
_: _:
{
  ci = (import ./nix { }).ci;

  emacsGccPgtk = (mkGitEmacs { usePgtk = true; });
  emacsGcc = (mkGitEmacs { usePgtk = false; });

}
