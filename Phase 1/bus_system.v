module bus_system (
    input  [31:0] control,
    
	input [31:0] BusIn0,
	input [31:0] BusIn1,
	input [31:0] BusIn2,
	input [31:0] BusIn3, 
	input [31:0] BusIn4,
	input [31:0] BusIn5,
	input [31:0] BusIn6,
	input [31:0] BusIn7,	
	input [31:0] BusIn8,
	input [31:0] BusIn9,
	input [31:0] BusIn10,
	input [31:0] BusIn11,
	input [31:0] BusIn12,
	input [31:0] BusIn13,
	input [31:0] BusIn14,
	input [31:0] BusIn15,
	input [31:0] BusIn16,
	input [31:0] BusIn17,
	input [31:0] BusIn18,
	input [31:0] BusIn19,
	input [31:0] BusIn20,
	input [31:0] BusIn21,	
	input [31:0] BusIn22,
	input [31:0] BusIn23,
	
    output [31:0] BusOut
);

    wire [4:0] sel;

    pe_32_5 ENC (
        .Data(control),
        .Code(sel)
    );

    mux_32_1 MUX (
		.BusMuxIn_R0(BusIn0),
		.BusMuxIn_R1(BusIn1),
		.BusMuxIn_R2(BusIn2),
		.BusMuxIn_R3(BusIn3),
		.BusMuxIn_R4(BusIn4),
		.BusMuxIn_R5(BusIn5),
		.BusMuxIn_R6(BusIn6),
		.BusMuxIn_R7(BusIn7),
		.BusMuxIn_R8(BusIn8),
		.BusMuxIn_R9(BusIn9),
		.BusMuxIn_R10(BusIn10),
		.BusMuxIn_R11(BusIn11),
		.BusMuxIn_R12(BusIn12),
		.BusMuxIn_R13(BusIn13),
		.BusMuxIn_R14(BusIn14),
		.BusMuxIn_R15(BusIn15),
		.BusMuxIn_HI(BusIn16),
		.BusMuxIn_LO(BusIn17),
		.BusMuxIn_Z_high(BusIn18),
		.BusMuxIn_Z_low(BusIn19),
		.BusMuxIn_PC(BusIn20),
		.BusMuxIn_MDR(BusIn21),
		.BusMuxIn_InPort(BusIn22),
		.C_sign_extended(BusIn23),
		.select(sel),
		.BusMuxOut(BusOut)
	);

endmodule