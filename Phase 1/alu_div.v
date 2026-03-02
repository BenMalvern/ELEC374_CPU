module alu_div (output reg signed [31:0] LO, HI,
				input signed [31:0] Q, M
);
	reg signed [31:0] Q_cpy;
	reg signed [32:0] M_abs, A; // registers for remainder (1 bit larger than Q)
	integer i;
	
	always @(*) begin
		if (M == 0) begin
			LO = 32'b0;
			HI = 32'b0;
		end
		else begin
			A = 33'b0; // A starts as 0
			Q_cpy = (Q < 0) ? -Q : Q; // Get abs value of Q
			M_abs = {1'b0, (M < 0) ? -M : M}; // Get the abs value of M
			
			for (i = 0; i < 32; i = i + 1) begin
				{A, Q_cpy} = {A, Q_cpy} << 1; // Left shift 1 bit
				
				// Add or subtract M_abs
				if (A[32] == 0)
					A = A - M_abs;
				else
					A = A + M_abs;
				
				// Set q0
				Q_cpy[0] = (A[32] == 0);
			end
			
			// Last addition if necessary
			if (A[32] == 1)
				A = A + M_abs;
			
			// Sign correction
			LO = Q_cpy;
			if (Q[31] ^ M[31])
				LO = -LO;
			
			HI = A[31:0];
			if (Q[31])
				HI = -HI;
		end
	end
	
endmodule