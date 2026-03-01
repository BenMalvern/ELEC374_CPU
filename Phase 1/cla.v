module cla #(parameter DATA_WIDTH = 32)(output [DATA_WIDTH-1:0] Z,input [DATA_WIDTH - 1:0] A, B);

	wire [8:0] connectBlk; // Extra Bit to hold 0 input
	assign connectBlk[0] = 1'b0;
	
	
	genvar i;
	generate
		for(i = 0; i < 8; i = i + 1) begin: genloop
			cla4 block (Z[4*i +: 4], connectBlk[i+1], A[4*i +: 4], B[4*i +: 4], connectBlk[i]);
		end
	endgenerate

		
endmodule


module cla4
(
    output wire [3:0] sum,
    output wire carry,
    input  wire [3:0] A,
    input  wire [3:0] B,
	 input  wire carryBlockIn

);

	 wire [3:0] G;
    wire [3:0] P;
	 wire [4:0] carry4;


    // Block carry-in fixed to 0
    assign carry4[0] = carryBlockIn;

    // Bit generate/propagate
    assign G[0] = A[0] & B[0];
    assign P[0] = A[0] ^ B[0];

    assign G[1] = A[1] & B[1];
    assign P[1] = A[1] ^ B[1];

    assign G[2] = A[2] & B[2];
    assign P[2] = A[2] ^ B[2];

    assign G[3] = A[3] & B[3];
    assign P[3] = A[3] ^ B[3];

    // Lookahead carries
    assign carry4[1] = G[0] | (P[0] & carry4[0]);

    assign carry4[2] = G[1]
                     | (P[1] & G[0])
                     | (P[1] & P[0] & carry4[0]);

    assign carry4[3] = G[2]
                     | (P[2] & G[1])
                     | (P[2] & P[1] & G[0])
                     | (P[2] & P[1] & P[0] & carry4[0]);

    assign carry4[4] = G[3]
                     | (P[3] & G[2])
                     | (P[3] & P[2] & G[1])
                     | (P[3] & P[2] & P[1] & G[0])
                     | (P[3] & P[2] & P[1] & P[0] & carry4[0]);

    // Sum uses carry into each bit
    assign sum[0] = A[0] ^ B[0] ^ carry4[0];
    assign sum[1] = A[1] ^ B[1] ^ carry4[1];
    assign sum[2] = A[2] ^ B[2] ^ carry4[2];
    assign sum[3] = A[3] ^ B[3] ^ carry4[3];
	 
	 assign carry = carry4[4];

endmodule