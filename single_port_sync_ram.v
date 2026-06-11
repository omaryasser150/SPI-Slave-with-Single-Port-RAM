module single_port_sync_ram #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
) (
    input clk, rst_n, rx_valid,
    input [9:0]din,
    output reg tx_valid,
    output reg [7:0]dout
);
reg [7:0] mem [MEM_DEPTH-1:0];
reg [7:0] write_address;
reg [7:0] read_address;

always @(posedge clk) begin
    if (~rst_n)begin
        dout <=  8'b0;
        tx_valid <= 1'b0;
    end
    else begin
        if (rx_valid) begin
            case (din[9:8])
            2'b00 : begin
                write_address <= din[7:0];
                tx_valid <= 1'b0;
            end
            2'b01 : begin 
                mem [write_address] <= din[7:0];
                tx_valid <= 1'b0;
            end
            2'b10 : begin 
                read_address <= din[7:0];
                tx_valid <= 1'b0;
            end
            2'b11 : begin
                dout <= mem [read_address];
                tx_valid <= 1'b1;
            end
            endcase
        end
    end
end

endmodule