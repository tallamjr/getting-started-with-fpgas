# Personal Notes


<!-- mtoc-start -->

* [Chapter 2: GO Board Set-up](#chapter-2-go-board-set-up)

<!-- mtoc-end -->

### Chapter 2: GO Board Set-up

I am working on a Mac with an M2 chip, so I need to install the main open source
FPGA tools via Homebrew. In general, you should ensure you have:

- **Yosys** – for Verilog synthesis.
- **icestorm** – which includes icepack (and iceprog for programming).
- **libftdi** – to use iceprog to flash your FPGA.
- **nextpnr-ice40** – for place-and-route for iCE40 devices (the [GO Board has a Lattice ICE40 HX1K FPGA](https://nandland.com/the-go-board/))
- Optionally, **graphviz** – for generating schematics (using the `show` command in Yosys).

```bash
brew install yosys libftdi graphviz libftdi0
```

This sorts our `yosys`, `libftdi` and `graphviz` but for the place-and-route
tool `nextpnr-ice40` as well as `icestorm` for programming, we need to do a
couple more steps...

1. Install the prerequisite for [`nextpnr-ice40`](https://github.com/YosysHQ/nextpnr?tab=readme-ov-file#prerequisites):

  ```bash
  brew install cmake python boost eigen
  ```

2. Install the [Open FPGA Toolchain by Clifford Wolf et al.](https://github.com/ddm/icetools) by running:

  ```bash
  git clone git@github.com:ddm/icetools.git && ./icetools.sh
  ```

  This will provide with the main tools command‑line tools and dependencies you need for your open
  source FPGA flow on Lattice chips. While in theory this should do the trick you may get errors
  like the ones below:

  ```bash

  ```

  In which case, these hotfixes should do the trick.

  Once that is run, we are now

3. Install `nextpnr-ice40` with:

  ```bash
  git@github.com:YosysHQ/nextpnr.git && cd nextpnr && git submodule update --init --recursive

  mkdir -p build && cd build
  cmake .. -DARCH=ice40
  make -j$(nproc)
  sudo make install

  ```
