module REGISTER 
#(
parameter DATA_WIDTH = 32,
INIT = 32'b0
)(
output wire [DATA_WIDTH-1:0] BUS_MUX_IN,
input wire [DATA_WIDTH-1:0] BUS_MUX_OUT,
input wire clear, clock, enable
);

	reg [DATA_WIDTH-1:0] q;
	initial q = INIT;

	always @ (posedge clock) begin
		if (clear) begin
			q <= {DATA_WIDTH{1'b0}};
		end
		else if (enable) begin
			q <= BUS_MUX_OUT;
		end
	end
	
	assign BUS_MUX_IN = q[DATA_WIDTH-1:0];
	
endmodule 