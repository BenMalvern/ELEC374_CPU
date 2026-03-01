`timescale 1ns/10ps

module pe_32_5 (
    output reg  [4:0]  Code,
    input  wire [24:0] Data
);

	always @(Data) begin
		if (Data[23]) Code = 5'd23; else
		if (Data[22]) Code = 5'd22; else
		if (Data[21]) Code = 5'd21; else
		if (Data[20]) Code = 5'd20; else
		if (Data[19]) Code = 5'd19; else
		if (Data[18]) Code = 5'd18; else
		if (Data[17]) Code = 5'd17; else
		if (Data[16]) Code = 5'd16; else
		if (Data[15]) Code = 5'd15; else
		if (Data[14]) Code = 5'd14; else
		if (Data[13]) Code = 5'd13; else
		if (Data[12]) Code = 5'd12; else
		if (Data[11]) Code = 5'd11; else
		if (Data[10]) Code = 5'd10; else
		if (Data[9])  Code = 5'd9;  else
		if (Data[8])  Code = 5'd8;  else
		if (Data[7])  Code = 5'd7;  else
		if (Data[6])  Code = 5'd6;  else
		if (Data[5])  Code = 5'd5;  else
		if (Data[4])  Code = 5'd4;  else
		if (Data[3])  Code = 5'd3;  else
		if (Data[2])  Code = 5'd2;  else
		if (Data[1])  Code = 5'd1;  else
		if (Data[0])  Code = 5'd0;  else           
					  Code = 5'bx;
	end

endmodule
