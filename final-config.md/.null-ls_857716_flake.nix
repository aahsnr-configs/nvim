{
  description = "A native-optimized Python data science environment using Clang/LLVM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # --- Configuration ---
      # Support common system architectures.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # --- Development Shell Definition ---
      devShells = forAllSystems (system:
        let
          # Use an overlay to force the entire package set to be built with Clang/LLVM.
          # This ensures maximum consistency and performance.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # For packages like MKL if ever needed.
            overlays = [(self: super: {
              stdenv = self.llvmPackages_latest.stdenv;
            })];
          };

          # --- Python Environment Configuration ---
          # Define Python package sets for better organization.
          pythonPackageSets = ps: with ps; {
            jupyter = [ jupyter jupyterlab notebook ipython ipykernel ipywidgets nbconvert nbformat jupytext ];
            scientific = [ numpy scipy pandas matplotlib seaborn plotly scikit-learn ];
            data = [ h5py openpyxl pyarrow polars ];
            dev = [ pip setuptools wheel pytest ruff bandit ];
            performance = [ numba cython ];
            utils = [ requests beautifulsoup4 lxml tqdm click pydantic rich networkx statsmodels sympy pillow imageio bokeh psycopg2 sqlalchemy ];
          };

          # Create the final Python environment derivation.
          # This is the most important part for performance. This entire block is built
          # once from source with full optimizations and then cached. Subsequent `nix develop`
          # loads will be fast because this derivation will already exist in the Nix store.
          optimizedPythonEnv = pkgs.python313.override {
            enableOptimizations = true; # Enables Profile Guided Optimization (-fprofile-use)
            enableLTO = true;         # Enables Link Time Optimization
            reproducibleBuild = false;  # Required for -march=native
          }.withPackages (ps:
            (pythonPackageSets ps).jupyter ++
            (pythonPackageSets ps).scientific ++
            (pythonPackageSets ps).data ++
            (pythonPackageSets ps).dev ++
            (pythonPackageSets ps).performance ++
            (pythonPackageSets ps).utils
          );

        in
        pkgs.mkShell {
          # --- Shell Packages ---
          # These are the packages made available directly in the shell's PATH.
          buildInputs = with pkgs; [
            # The fully-built Python environment is our primary input.
            optimizedPythonEnv

            # LLVM/Clang toolchain (for pip installs and inspection).
            llvmPackages_latest.clang
            llvmPackages_latest.lld

            # Essential system dependencies.
            pkg-config libffi openssl zlib git curl

            # Graphics libraries for plotting.
            cairo pango gdk-pixbuf gobject-introspection fontconfig freetype

            # Native-compiled mathematical libraries.
            blas lapack openblas gfortran

            # Database and compression libraries.
            postgresql sqlite
            bzip2 xz lz4 zstd

            # SSL certificates and high-performance memory allocator.
            cacert
            jemalloc
          ];

          # --- Native Compilation Flags ---
          # These flags instruct Nix to build all `buildInputs` with native optimizations.
          NIX_CFLAGS_COMPILE   = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer";
          NIX_CXXFLAGS_COMPILE = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer";
          NIX_LDFLAGS          = "-Wl,-O1 -Wl,--as-needed -fuse-ld=lld";

          # --- Shell Hook ---
          # This script runs every time you enter the shell (`nix develop`). It's designed to be fast.
          shellHook = ''
            # Welcome message
            echo ""
            echo "🚀 Entering Native-Optimized Python Environment (Clang)"
            echo "   Python:  $(python --version 2>/dev/null)"
            echo "   Compiler: Clang $(${pkgs.llvmPackages_latest.clang}/bin/clang --version | head -n 1 | cut -d' ' -f4)"
            echo "   CPU:     $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs || sysctl -n machdep.cpu.brand_string)"
            echo ""

            # --- Environment Variable Setup ---

            # Set thread count for parallelized libraries to all available cores.
            export NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
            export OPENBLAS_NUM_THREADS=$NPROC
            export MKL_NUM_THREADS=$NPROC
            export NUMEXPR_NUM_THREADS=$NPROC
            export OMP_NUM_THREADS=$NPROC

            # Use jemalloc for better memory allocation performance.
            if [[ -f "${pkgs.jemalloc}/lib/libjemalloc.so" ]]; then
                export LD_PRELOAD="''${LD_PRELOAD:+$LD_PRELOAD:}${pkgs.jemalloc}/lib/libjemalloc.so"
            fi

            # Python performance and path settings.
            export PYTHONDONTWRITEBYTECODE=1
            export PYTHONUNBUFFERED=1
            export PYTHONPATH="$PWD:$PYTHONPATH"

            # Ensure pip uses our Clang compiler when building packages.
            export CC="${pkgs.llvmPackages_latest.clang}/bin/clang"
            export CXX="${pkgs.llvmPackages_latest.clang}/bin/clang++"

            # Jupyter configuration.
            export JUPYTER_CONFIG_DIR="$PWD/.jupyter"
            mkdir -p "$JUPYTER_CONFIG_DIR"

            # Install a custom IPython kernel spec if it doesn't exist.
            if ! jupyter kernelspec list 2>/dev/null | grep -q "python3-native-clang"; then
                echo "🔧 Installing custom Jupyter kernel..."
                python -m ipykernel install --user --name=python3-native-clang --display-name="Python 3 (Native Clang)" >/dev/null 2>&1 || true
            fi

            # Final status display
            echo "✅ Environment ready!"
            echo "   Threads:  $NPROC cores"
            if [[ -n "''${LD_PRELOAD:-}" ]]; then
                echo "   Memory:   jemalloc enabled"
            fi
            echo ""
            echo "   Use 'jupyter-lab' or 'ipython'. Install more packages with 'pip install'."
            echo ""
          '';
        }
    );
}
