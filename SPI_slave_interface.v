module SPI_slave_interface #(
    parameter IDLE = 3'b000,
    parameter CHK_CMD = 3'b001,
    parameter WRITE = 3'b010,
    parameter READ_ADD = 3'b011,
    parameter READ_DATA = 3'b100
) (
    input clk, rst_n, MOSI, SS_n, tx_valid,
    input [7:0]tx_data,
    output reg rx_valid, MISO,
    output reg [9:0]rx_data
);
reg is_read_address_received;
reg [3:0]counter;
// (*fsm_encoding = "one_hot"*)
reg [2:0]cs,ns;

// Buffer intermediate signals to add delay
reg MOSI_buf;
reg SS_n_buf;
reg tx_valid_buf;
reg [7:0] tx_data_buf;

always @(posedge clk) begin
    if (~rst_n) begin
        MOSI_buf <= 1'b0;
        SS_n_buf <= 1'b1;
        tx_valid_buf <= 1'b0;
        tx_data_buf <= 8'b0;
    end
    else begin
        MOSI_buf <= MOSI;
        SS_n_buf <= SS_n;
        tx_valid_buf <= tx_valid;
        tx_data_buf <= tx_data;
    end
end

//State Memory always block
always @(posedge clk) begin
    if (~rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

//Next State Logic always block
always @(*) begin
    case (cs)
        IDLE : begin
            if (~SS_n_buf)
                ns = CHK_CMD;
            else
                ns = IDLE;
        end
        CHK_CMD : begin
            if (SS_n_buf == 0 && MOSI_buf == 0) 
                ns = WRITE;
            else if (SS_n_buf == 0 && MOSI_buf == 1 && is_read_address_received == 0)
                ns = READ_ADD;
            else if (SS_n_buf == 0 && MOSI_buf == 1 && is_read_address_received == 1)
                ns = READ_DATA;
            else if (SS_n_buf)
                ns = IDLE;
            else
                ns = CHK_CMD;
        end
        WRITE : begin
            if (SS_n_buf)
                ns = IDLE;
            else
                ns = WRITE;
        end
        READ_ADD : begin
            if (SS_n_buf) 
                ns = IDLE;
            else
                ns = READ_ADD;
        end
        READ_DATA : begin
            if (SS_n_buf) 
                ns = IDLE;
            else
                ns = READ_DATA;
        end
    endcase
end

// Output Logic always block
always @(posedge clk) begin
    if (~rst_n) begin
        rx_valid <= 1'b0;
        MISO <= 1'b0;
        rx_data <= 10'b0;
        counter <= 4'b0;
        is_read_address_received <= 1'b0;
    end
    else begin
        rx_valid <= 0;
        
        case (cs)
            IDLE: begin
                counter <= 4'b0;
                rx_data <= 10'b0;
            end
            WRITE: begin
                if (~SS_n_buf) begin
                    rx_data[9-counter] <= MOSI_buf;
                    counter <= counter + 1;
                    
                    if (counter == 4'd9) begin
                        counter <= 4'b0;
                        rx_valid <= 1'b1;
                    end
                end
            end
            
            READ_ADD: begin
                if (~SS_n_buf) begin
                    rx_data[9-counter] <= MOSI_buf;
                    counter <= counter + 1;
                    
                    if (counter == 4'd9) begin
                        counter <= 4'b0;
                        rx_valid <= 1'b1;
                        is_read_address_received <= 1'b1;
                    end
                end
            end
            
            READ_DATA: begin
                if (~SS_n_buf) begin
                    if (counter < 4'd2) begin
                        rx_data[9-counter] <= MOSI_buf;
                        counter <= counter + 1;
                        
                        if (counter == 4'd1) begin
                            rx_valid <= 1'b1;
                        end
                    end
                    else if (counter >= 4'd2 && counter <= 4'd10 && tx_valid_buf) begin
                        rx_data[9-counter] <= MOSI_buf;
                        MISO <= tx_data_buf[7-(counter-2)];
                        counter <= counter + 1;
                        
                        if (counter == 4'd10) begin
                            counter <= 4'b0;
                            is_read_address_received <= 1'b0;
                        end
                    end
                end
            end
        endcase
    end
end

endmodule