module SHR #(parameter DATA_WIDTH = 32) (output [DATA_WIDTH - 1:0] Z, input [DATA_WIDTH - 1:0] A, input [4:0] shiftAmount);
	assign Z = A >> shiftAmount[4:0];
endmodule

module SHRA #(parameter DATA_WIDTH = 32) (output signed [DATA_WIDTH - 1:0] Z, input signed [DATA_WIDTH - 1:0] A, input [4:0] shiftAmount);
	assign Z = $signed(A) >>> shiftAmount[4:0];
endmodule

module SHL #(parameter DATA_WIDTH = 32) (output [DATA_WIDTH - 1:0] Z, input [DATA_WIDTH - 1:0] A, input [4:0] shiftAmount);
	assign Z = A << shiftAmount[4:0];
endmodule

module ROR #(parameter DATA_WIDTH = 32) (output [DATA_WIDTH - 1:0] Z, input [DATA_WIDTH - 1:0] A, input [4:0] shiftAmount);
	assign Z = (A >> shiftAmount[4:0])|(A << ((DATA_WIDTH) - shiftAmount[4:0]));
endmodule

module ROL #(parameter DATA_WIDTH = 32) (output [DATA_WIDTH - 1:0] Z, input [DATA_WIDTH - 1:0] A, input [4:0] shiftAmount);
		assign Z = (A << shiftAmount[4:0])|(A >> ((DATA_WIDTH) - shiftAmount[4:0]));
endmodule