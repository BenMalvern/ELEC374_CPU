module ram(
    input clk,
    input Read,
    input Write,
    input [8:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out
);
    reg [31:0] memory [0:511]; // 512 32-bit words
	
	// Initialize to zero
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1)
            memory[i] = 32'b0;
    end
	
	// Synchronous write
    always @(posedge clk) begin
        if (Write)
            memory[address] <= data_in;
    end

	// Asynchronous read
    always @(*) begin
        if (Read)
            data_out = memory[address];
        else
            data_out = 32'b0;
    end
endmodule