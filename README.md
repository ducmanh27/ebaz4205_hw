# EBAZ4205 – Zynq-7000 Hardware Project (Vivado)

Vivado hardware project for the **EBAZ4205** board (Xilinx Zynq-7000 **XC7Z010-1CLG400**).
It builds a minimal PS + PL design used to bring up and test the basic peripherals of the board:
DDR3, PS UART, SD card, and several AXI IP cores in the PL (Ethernet, UART16550, I2C, Quad SPI).

| Item | Value |
|---|---|
| Tool | Vivado **2023.2** |
| Part | `xc7z010clg400-1` |
| Project | `zynq7000.xpr` |
| Block design | `design_1` (wrapper: `design_1_wrapper`) |
| Constraints | `zynq7000.srcs/constrs_1/new/constrains.xdc` |
| Prebuilt hardware handoff | `design_1_wrapper.xsa` |

## Repository contents

```
.
├── zynq7000.xpr                      Vivado project
├── zynq7000.srcs/
│   ├── sources_1/bd/design_1/        Block design + IP (.xci)
│   └── constrs_1/new/constrains.xdc  Pin / timing constraints
├── design_1_wrapper.xsa              Exported hardware (for Vitis)
├── ebaz4205_schematic.pdf            Community schematic rebuild (KiCad)
└── xc7z010clg400pkg.txt              Package pin list for the device
```

> Generated folders (`*.runs`, `*.cache`, `*.gen`, ...) are ignored by `.gitignore`.
> They are recreated when you open the project and run synthesis / implementation.

## Block design overview

All AXI peripherals sit behind one AXI interconnect on `M_AXI_GP0` of the Zynq PS.
Everything in the PL runs from **FCLK_CLK0 = 50 MHz**.

| Block | IP | Purpose |
|---|---|---|
| `processing_system7_0` | ZYNQ7 Processing System | ARM cores, DDR3, MIO peripherals |
| `axi_interconnect_0` | AXI Interconnect | 1 slave (PS GP0) → 4 masters |
| `proc_sys_reset_0` | Processor System Reset | Synchronized resets for PL |
| `xlconcat_0` | Concat (4 inputs) | Collects PL interrupts into `IRQ_F2P[3:0]` |
| `axi_ethernetlite_0` | AXI EthernetLite | MII MAC + MDIO to the on-board PHY (IP101GA) |
| `axi_uart16550_0` | AXI UART16550 | Extra UART on the PL (header pins) |
| `axi_iic_0` | AXI IIC | I2C master on the PL (header pins) |
| `axi_quad_spi_0` | AXI Quad SPI | SPI master on the PL, standard mode, 1 slave select |

### Address map

| Peripheral | Base address | Range |
|---|---|---|
| `axi_ethernetlite_0` | `0x40E00000` | 64 KB |
| `axi_iic_0` | `0x41600000` | 64 KB |
| `axi_quad_spi_0` | `0x41E00000` | 64 KB |
| `axi_uart16550_0` | `0x43C00000` | 64 KB |

### Interrupt map (`IRQ_F2P`)

| `xlconcat_0` input | Source |
|---|---|
| `In0` | `axi_ethernetlite_0/ip2intc_irpt` |
| `In1` | `axi_uart16550_0/ip2intc_irpt` |
| `In2` | `axi_quad_spi_0/ip2intc_irpt` |
| `In3` | `axi_iic_0/iic2intc_irpt` |

## Processing System (PS7) configuration

| Setting | Value |
|---|---|
| Input clock | 33.333 MHz |
| CPU clock | 666.667 MHz |
| FCLK_CLK0 | 50 MHz (used by the whole PL) |
| AXI master | `M_AXI_GP0` enabled |
| Fabric interrupts | `IRQ_F2P` enabled |
| DDR | DDR3, 16-bit, 256 MB, 533.33 MHz (see *DDR configuration* below) |
| PS UART | **UART1** on MIO 24..25 (serial debug header) |
| SD card | **SD0** on MIO 40..45, card-detect on MIO 34, write-protect off |
| MIO bank voltages | Bank 0: 3.3 V, Bank 1: 1.8 V |
| Ethernet (PS GEM) | **Disabled** – the PHY is wired to the PL, not to the PS |

### DDR configuration

The board carries a single 2 Gbit x16 DDR3 device (Etron `EM6GD16EWKG-12H` according to the
schematic), i.e. **256 MB** on a 16-bit bus. That exact part is not in the Vivado list, so the
closest preset with the same organization is used: Micron `MT41K128M16 JT-125`.

| Setting (PS7 → *DDR Configuration*) | Value |
|---|---|
| Enable DDR | Enabled |
| Memory type | DDR 3 |
| Memory part | `MT41K128M16 JT-125` (closest match) |
| Effective DRAM bus width | 16 bit |
| ECC | Disabled |
| Burst length | 8 |
| DDR clock | 533.333 MHz (DDR3-1066) |
| Internal Vref | Disabled (external Vref on the board) |
| Junction temperature | Normal (0–85 °C) |
| DRAM IC bus width | 16 bits |
| DRAM device capacity | 2048 Mbit (= 256 MB) |
| Speed bin | DDR3_1066F |
| Bank / row address bits | 3 / 14 |
| Training | Write leveling, read gate and data eye enabled |

533 MHz is the maximum DDR3 rate for the `-1` speed grade of the XC7Z010-1, so it is a safe
choice even if the memory chip itself is rated faster. The board-specific delay values (DQS to
clock delay, DQ board delay) are left at their defaults. If you ever see DDR instability, these
are the settings to revisit first.

## Pin mapping (constraints)

All PL pins are `LVCMOS33`.

### Ethernet PHY (IP101GA, MII, bank 34)

These pins were verified against the schematic (`Zynq_IO` sheet).

| Port | Pin | Schematic net |
|---|---|---|
| `phy_rx_clk_0` | U14 | RXCLK |
| `phy_tx_clk_0` | U15 | TXCLK |
| `phy_dv_0` | W16 | RXDV |
| `phy_tx_en_0` | W19 | TXEN |
| `phy_rx_data_0[0]` | Y16 | RXD0 |
| `phy_rx_data_0[1]` | V16 | RXD1 |
| `phy_rx_data_0[2]` | V17 | RXD2 |
| `phy_rx_data_0[3]` | Y17 | RXD3 |
| `phy_tx_data_0[0]` | W18 | TXD0 |
| `phy_tx_data_0[1]` | Y18 | TXD1 |
| `phy_tx_data_0[2]` | V18 | TXD2 |
| `phy_tx_data_0[3]` | Y19 | TXD3 |
| `mdio_rtl_1_mdc` | W15 | MDC |
| `mdio_rtl_1_mdio_io` | Y14 | MDIO (the schematic labels this net `REST.ON_0`, a typo) |

Important Ethernet notes:

- **`phy_col`, `phy_crs`, `phy_rx_er` and `phy_rst_n` are intentionally not connected to any
  FPGA pin.** On this board they are not routed to the PL (they are tied or reset on the PCB), so
  these four EthernetLite pins are left unconnected in the block design instead of being made
  external. If Vivado complains about the undriven inputs, tie `phy_col`, `phy_crs` and
  `phy_rx_er` to a constant `0`.
- **`CLOCK_DEDICATED_ROUTE FALSE`** is set on the TX clock net. `TXCLK` is wired to **U15**, the
  N side of a differential clock pair, which Vivado does not allow as a single-ended clock input
  on the dedicated clock route (error `Place 30-876`). At 25 MHz this is fine.
- **Do not add `create_clock` for `phy_rx_clk_0` / `phy_tx_clk_0`.** The EthernetLite IP already
  creates these 40 ns clocks in its own XDC. Declaring them again raises critical warning
  `Constraints 18-1056`.
- **PHY clock.** The 25 MHz PHY clock comes from the crystal on the board (Y3). Some board
  revisions omit the crystal and fit R1485 (0R) instead, to feed the clock from the FPGA
  (net `XOUT.0`, pin U18). This design assumes the crystal is fitted and R1485 is **not** fitted.

### Other PL peripherals (header pins)

| Port | Pin | Note |
|---|---|---|
| `iic_rtl_0_scl_io` | A20 | Needs external pull-up (or enable internal pull-up) |
| `iic_rtl_0_sda_io` | P19 | Routed to header DATA3 |
| `sin_0` | C20 | AXI UART16550 RX |
| `sout_0` | H17 | AXI UART16550 TX |
| `spi_rtl_0_ss_io[0]` | D20 | Quad SPI slave select |
| `spi_rtl_0_io0_io` | H18 | MOSI |
| `spi_rtl_0_io1_io` | F20 | MISO |

> **Not yet cross-checked against the schematic:** the bank 35 pins above (UART16550, I2C SCL,
> SPI) were carried over from earlier constraints. The Quad SPI IP uses *STARTUP_IO*, so SCK is
> driven through the dedicated configuration pin and has no entry in the XDC.

## How to build

1. Open `zynq7000.xpr` in **Vivado 2023.2**.
2. If the project asks about out-of-date IP, run *Report IP Status* and upgrade/regenerate.
3. In the Flow Navigator run **Generate Bitstream** (synthesis and implementation run first).
4. Export the hardware: **File → Export → Export Hardware**, choose **Include bitstream**, and save
   the XSA (the repository contains a prebuilt `design_1_wrapper.xsa`; re-export it whenever you
   change the block design).
5. In Vitis, create a platform from the XSA and build your test applications.

## Troubleshooting (issues hit while bringing this up)

| Message | Cause | Fix |
|---|---|---|
| `Constraints 18-1056` clock overrides clock | Duplicate `create_clock` for PHY clocks | Remove those lines from the XDC; the IP defines them |
| `Place 30-876` ... N side of a differential clock input | `TXCLK` wired to U15 (N pin) | `set_property CLOCK_DEDICATED_ROUTE FALSE` on the TX clock net (already in the XDC) |
| `Place 30-99` / `Common 17-69` | Follow-up of the error above | Disappear once the error above is fixed |
| Unconstrained ports / `UCIO`/`NSTD` DRC | Ports with no pin (PHY COL/CRS/RXER/RST) | Do not make them external |

## Verified so far

| Peripheral | Status |
|---|---|
| DDR3 / PS7 / PS UART1 | Working (applications run, serial output OK) |
| Ethernet (PL, MII, IP101GA) | Working: link at 100 Mbps, lwIP TCP echo server answers on the network |
| SD card (PS SD0) | Working: directory listing of the FAT partition via xilffs (read-only) |
| AXI UART16550, AXI IIC, AXI Quad SPI | IP self-tests only; not yet verified with external hardware |

## Board notes (from the schematic)

- The **JTAG header** and the **SD card socket** are not fitted on later board revisions.
- Boot mode straps on MIO5/MIO4 (as noted on the schematic): `00` = JTAG, `01` = NAND, `11` = SD.
- The board has 256 MB DDR3 and a 128 MB NAND flash (no QSPI flash).

## Known issues / TODO

- The PS7 configuration currently has the **PS QSPI controller enabled on MIO 1..6**, but the board
  has no QSPI flash (NAND is used, and MIO4/5 are boot-mode straps). Consider disabling it unless
  you really need it.
- Verify the **SD card-detect on MIO 34** against the schematic (the `DETECT` pin of the socket).
- Cross-check the bank 35 pin assignments (UART16550, I2C, SPI) with the schematic.
- Add an external test for UART16550 (loopback), I2C (bus scan) and SPI.

## Credits

`ebaz4205_schematic.pdf` is a community KiCad rebuild of the EBAZ4205 schematic (Rev V004).
It is not an official vendor document, so verify critical connections on your own board.
