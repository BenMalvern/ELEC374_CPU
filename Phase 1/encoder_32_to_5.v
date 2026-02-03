`timescale 1ns/10ps

module encoder_32_to_5 (
    input wire [31:0] encoderInput,
    output reg  [4:0]  encoderOutput
);
	always @(*) begin
		encoderOutput <= 5'd31;
		for (int i = 0; i < 32; i++) begin
			if (encoderInput[i]) 
				// Check if any of the 32 bits is set to 1
				// Set the output value to that corresponding bit number (5 bits)
				encoderOutput = i[4:0]
		end
	end
endmodule
