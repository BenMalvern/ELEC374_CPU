module alu_mul(output signed [31:0] LO, HI,
			   input signed [31:0] A, B
);

	reg signed [63:0] product, addend, A_ext;
	reg [33:0] B_ext;
	reg [2:0] cmp;
	integer i;
	
	always @(A, B) begin
		product = 64'b0;
		B_ext = {B[31], B, 1'b0}; // sign bit + 32-bit B + extra 0
		A_ext = {{32{A[31]}}, A}; // Explicitly extend A for clarity
		
		for (i = 0; i < 32; i = i + 2) begin
			cmp = ((B_ext >> i) & 3'b111);
			case (cmp)
				3'b000, 3'b111:
					addend = 64'b0; // 0
				3'b001, 3'b010:
					addend = A_ext; // +1
				3'b011:
					addend = A_ext << 1; // +2
				3'b100:
					addend = -(A_ext << 1); // -2
				3'b101, 3'b110:
					addend = -A_ext; // -1
			endcase
			
			product = product + (addend << i); // Left shift i bits
			
		end
	end
	
	assign LO = product[31:0];
	assign HI = product[63:32];

endmodule