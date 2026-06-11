module SPI_wrapper (
    input clk, rst_n, MOSI, SS_n,
    output MISO
);
wire tx_valid,rx_valid;
wire [7:0]tx_data;
wire [9:0]rx_data;

single_port_sync_ram RAM (.clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), .din(rx_data), .tx_valid(tx_valid), .dout(tx_data));
SPI_slave_interface SPI_slave (.clk(clk), .rst_n(rst_n), .MOSI(MOSI), .SS_n(SS_n), .tx_valid(tx_valid), .tx_data(tx_data), .rx_valid(rx_valid), .MISO(MISO), .rx_data(rx_data));

endmodule