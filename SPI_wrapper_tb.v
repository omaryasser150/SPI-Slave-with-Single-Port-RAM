module SPI_wrapper_tb ();
reg clk, rst_n, MOSI, SS_n;
wire MISO;

SPI_wrapper DUT (.clk(clk), .rst_n(rst_n), .MOSI(MOSI), .SS_n(SS_n), .MISO(MISO));


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $readmemh("mem.dat",DUT.RAM.mem);
    // Initialize
    rst_n = 0; MOSI = 0; SS_n = 1;
    @(negedge clk);
    
    rst_n = 1;
    
    // Test Write Operation
    // First write operation: Set write address
    SS_n = 0;
    @(negedge clk);
    
    MOSI = 0; @(negedge clk);

    MOSI = 0; @(negedge clk);  // Command bit 1
    MOSI = 0; @(negedge clk);  // Command bit 0 (00 = write address)
    
    // Send 8-bit address
    MOSI = 0; @(negedge clk);  // Address bit 7
    MOSI = 0; @(negedge clk);  // Address bit 6
    MOSI = 0; @(negedge clk);  // Address bit 5
    MOSI = 0; @(negedge clk);  // Address bit 4
    MOSI = 0; @(negedge clk);  // Address bit 3
    MOSI = 1; @(negedge clk);  // Address bit 2
    MOSI = 0; @(negedge clk);  // Address bit 1
    MOSI = 1; @(negedge clk);  // Address bit 0 (0x05)
    
    SS_n = 1; 
    @(negedge clk);
    
    // Second write operation: Write data
    SS_n = 0;
    @(negedge clk);

    MOSI = 0; @(negedge clk);

    MOSI = 0; @(negedge clk);  // Command bit 1
    MOSI = 1; @(negedge clk);  // Command bit 0 (01 = write data)
    
    // Send 8-bit data
    MOSI = 1; @(negedge clk);  // Data bit 7
    MOSI = 0; @(negedge clk);  // Data bit 6
    MOSI = 1; @(negedge clk);  // Data bit 5
    MOSI = 0; @(negedge clk);  // Data bit 4
    MOSI = 1; @(negedge clk);  // Data bit 3
    MOSI = 0; @(negedge clk);  // Data bit 2
    MOSI = 1; @(negedge clk);  // Data bit 1
    MOSI = 0; @(negedge clk);  // Data bit 0 (0xAA)
    
    SS_n = 1;
    @(negedge clk);
    
    // Test Read Operation
    // First: Set read address
    SS_n = 0;
    @(negedge clk);

    MOSI = 1; @(negedge clk);

    MOSI = 1; @(negedge clk);  // Command bit 1
    MOSI = 0; @(negedge clk);  // Command bit 0 (10 = read address)
    
    // Send same address 0x05
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    
    SS_n = 1;
    @(negedge clk);
    
    // Second: Read data
    SS_n = 0;
    @(negedge clk);

    MOSI = 1; @(negedge clk);
    
    MOSI = 1; @(negedge clk);  // Command bit 1
    MOSI = 1; @(negedge clk);  // Command bit 0 (11 = read data)
    
    // Send dummy bits while reading
    repeat(10) begin
        MOSI = 0; @(negedge clk);
    end

    SS_n = 1;
    @(negedge clk);
    $stop;
end

endmodule