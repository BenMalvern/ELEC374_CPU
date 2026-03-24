module ram(
    input clk,
    input Read,
    input Write,
    input [8:0] address, // word address
    input [31:0] data_in,
    output reg [31:0] data_out
);

    // Byte-addressable memory (2048 bytes)
	// Memory declared starting from index 0
    reg [7:0] memory [0:2047];

    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1)
            memory[i] = 8'b0;
    end

    // Convert word address to byte address (multiply by 4)
    wire [10:0] byte_address;
    assign byte_address = address << 2;

    // Little endian write
    always @(posedge clk) begin
        if (Write) begin
            memory[byte_address + 0] <= data_in[7:0];
            memory[byte_address + 1] <= data_in[15:8];
            memory[byte_address + 2] <= data_in[23:16];
            memory[byte_address + 3] <= data_in[31:24];
        end
    end

    // Read (assemble word)
    always @(*) begin
        if (Read) begin
            data_out = {
                memory[byte_address + 3],
                memory[byte_address + 2],
                memory[byte_address + 1],
                memory[byte_address + 0]
            };
        end else begin
            data_out = 32'b0;
        end
    end

endmodule