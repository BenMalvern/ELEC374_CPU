module mar(
    input clk,
    input clr,
    input MARin,
    input [31:0] BusMuxOut,
    output reg [31:0] MAR_q
);
    always @(posedge clk or posedge clr) begin
        if (clr)
            MAR_q <= 32'b0;
        else if (MARin)
            MAR_q <= BusMuxOut;
    end
	
endmodule