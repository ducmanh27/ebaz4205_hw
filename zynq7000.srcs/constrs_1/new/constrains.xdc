## ===== Ethernet PHY IP101GA (MII, bank 34) =====
set_property PACKAGE_PIN U14 [get_ports phy_rx_clk_0]
set_property PACKAGE_PIN U15 [get_ports phy_tx_clk_0]
set_property PACKAGE_PIN W16 [get_ports phy_dv_0]
set_property PACKAGE_PIN W19 [get_ports phy_tx_en_0]

set_property PACKAGE_PIN Y16 [get_ports {phy_rx_data_0[0]}]
set_property PACKAGE_PIN V16 [get_ports {phy_rx_data_0[1]}]
set_property PACKAGE_PIN V17 [get_ports {phy_rx_data_0[2]}]
set_property PACKAGE_PIN Y17 [get_ports {phy_rx_data_0[3]}]

set_property PACKAGE_PIN W18 [get_ports {phy_tx_data_0[0]}]
set_property PACKAGE_PIN Y18 [get_ports {phy_tx_data_0[1]}]
set_property PACKAGE_PIN V18 [get_ports {phy_tx_data_0[2]}]
set_property PACKAGE_PIN Y19 [get_ports {phy_tx_data_0[3]}]

set_property PACKAGE_PIN W15 [get_ports mdio_rtl_1_mdc]
set_property PACKAGE_PIN Y14 [get_ports mdio_rtl_1_mdio_io]

set_property IOSTANDARD LVCMOS33 [get_ports phy_*]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_rtl_1_*]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {design_1_i/axi_ethernetlite_0/U0/o}]
## ===== I2C =====
set_property PACKAGE_PIN A20 [get_ports iic_rtl_0_scl_io]
set_property PACKAGE_PIN P19 [get_ports iic_rtl_0_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_rtl_0_*]

## ===== UART16550 =====
set_property PACKAGE_PIN C20 [get_ports sin_0]
set_property PACKAGE_PIN H17 [get_ports sout_0]
set_property IOSTANDARD LVCMOS33 [get_ports {sin_0 sout_0}]

## ===== Quad SPI (STARTUP_IO) =====
set_property PACKAGE_PIN D20 [get_ports {spi_rtl_0_ss_io[0]}]
set_property PACKAGE_PIN H18 [get_ports spi_rtl_0_io0_io]
set_property PACKAGE_PIN F20 [get_ports spi_rtl_0_io1_io]
set_property IOSTANDARD LVCMOS33 [get_ports spi_rtl_0_*]