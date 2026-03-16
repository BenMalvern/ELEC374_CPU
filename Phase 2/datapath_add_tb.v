`timescale 1ns/10ps

module datapath_add_tb;

	parameter DATA_WIDTH = 32;

	reg clock;
	reg clear;
	reg Read;
	reg [DATA_WIDTH-1:0] Mdatain;
	reg PCin, IRin, MARin, Yin, HIin, LOin, Zin, MDRin;
	reg InPortin, Cin;
	reg [15:0] Rin;
	reg IncPC;
	reg ADD, SUB, AND_op, OR_op, SHR_op, SHRA_op;
	reg SHL_op, ROR_op, ROL_op, NEG_op, NOT_op;
	reg MUL_op, DIV_op;
	
	// A bus controls
	reg PCoutA, HIoutA, LOoutA, ZhighoutA, ZlowoutA;
	reg MDRoutA, InPortoutA, CoutA;
	reg [15:0] RoutA;

	// B bus controls
	reg PCoutB, HIoutB, LOoutB, ZhighoutB, ZlowoutB;
	reg MDRoutB, InPortoutB, CoutB;
	reg [15:0] RoutB;

	// C bus select
    reg ZlowoutC, ZhighoutC, MDRoutC, PCoutC, InPortoutC, CoutC;
	
	wire [DATA_WIDTH-1:0] BusMuxOut_A, BusMuxOut_B, BusMuxOut_C;
	
	wire [31:0] PC_Q, IR_Q, MAR_Q, Y_Q;
	wire [31:0] HI_Q, LO_Q;
	wire [31:0] Z_HI_Q, Z_LO_Q;
	wire [31:0] MDR_Q, InPort_Q, C_Q;

	wire [31:0] R0_Q,  R1_Q,  R2_Q,  R3_Q;
	wire [31:0] R4_Q,  R5_Q,  R6_Q,  R7_Q;
	wire [31:0] R8_Q,  R9_Q,  R10_Q, R11_Q;
	wire [31:0] R12_Q, R13_Q, R14_Q, R15_Q;

	datapath DUT (
		.clock(clock),
		.clear(clear),

		// Memory
		.Read(Read),
		.Mdatain(Mdatain),

		// Write enables
		.PCin(PCin),
		.IRin(IRin),
		.MARin(MARin),
		.Yin(Yin),
		.HIin(HIin),
		.LOin(LOin),
		.Zin(Zin),
		.MDRin(MDRin),
		.InPortin(InPortin),
		.Cin(Cin),
		.Rin(Rin),

		// Special
		.IncPC(IncPC),

		// ALU control
		.ADD(ADD),
		.SUB(SUB),
		.AND_op(AND_op),
		.OR_op(OR_op),
		.SHR_op(SHR_op),
		.SHRA_op(SHRA_op),
		.SHL_op(SHL_op),
		.ROR_op(ROR_op),
		.ROL_op(ROL_op),
		.NEG_op(NEG_op),
		.NOT_op(NOT_op),
		.MUL_op(MUL_op),
		.DIV_op(DIV_op),

		// A bus drivers
		.PCoutA(PCoutA),
		.HIoutA(HIoutA),
		.LOoutA(LOoutA),
		.ZhighoutA(ZhighoutA),
		.ZlowoutA(ZlowoutA),
		.MDRoutA(MDRoutA),
		.InPortoutA(InPortoutA),
		.CoutA(CoutA),
		.RoutA(RoutA),

		// B bus drivers
		.PCoutB(PCoutB),
		.HIoutB(HIoutB),
		.LOoutB(LOoutB),
		.ZhighoutB(ZhighoutB),
		.ZlowoutB(ZlowoutB),
		.MDRoutB(MDRoutB),
		.InPortoutB(InPortoutB),
		.CoutB(CoutB),
		.RoutB(RoutB),

		// C bus writeback source select
		.ZlowoutC(ZlowoutC),
		.ZhighoutC(ZhighoutC),
		.MDRoutC(MDRoutC),
		.PCoutC(PCoutC),
		.InPortoutC(InPortoutC),
		.CoutC(CoutC),

		// Outputs
		.BusMuxOut_A(BusMuxOut_A),
		.BusMuxOut_B(BusMuxOut_B),
		.BusMuxOut_C(BusMuxOut_C),

		.PC_Q(PC_Q),
		.IR_Q(IR_Q),
		.MAR_Q(MAR_Q),
		.Y_Q(Y_Q),
		.HI_Q(HI_Q),
		.LO_Q(LO_Q),
		.Z_HI_Q(Z_HI_Q),
		.Z_LO_Q(Z_LO_Q),
		.MDR_Q(MDR_Q),
		.InPort_Q(InPort_Q),
		.C_Q(C_Q),

		.R0_Q(R0_Q),
		.R1_Q(R1_Q),
		.R2_Q(R2_Q),
		.R3_Q(R3_Q),
		.R4_Q(R4_Q),
		.R5_Q(R5_Q),
		.R6_Q(R6_Q),
		.R7_Q(R7_Q),
		.R8_Q(R8_Q),
		.R9_Q(R9_Q),
		.R10_Q(R10_Q),
		.R11_Q(R11_Q),
		.R12_Q(R12_Q),
		.R13_Q(R13_Q),
		.R14_Q(R14_Q),
		.R15_Q(R15_Q)
	);

	parameter Default = 4'd0,
			  LoadR5a = 4'd1,
			  LoadR5b = 4'd2,
			  LoadR6a = 4'd3,
			  LoadR6b = 4'd4,
			  T0 = 4'd5,
			  T1 = 4'd6,
			  T2 = 4'd7,
			  T3 = 4'd8,
			  T4 = 4'd9,
			  T5 = 4'd10;

	reg [3:0] Present_state = Default;

	// Clock generation
	initial begin
		clock = 0;
		forever #10 clock = ~clock;
	end

	// State transitions
	always @(posedge clock) begin
		case (Present_state)
			Default:  Present_state <= LoadR5a;
			LoadR5a:  Present_state <= LoadR5b;
			LoadR5b:  Present_state <= LoadR6a;
			LoadR6a:  Present_state <= LoadR6b;
			LoadR6b:  Present_state <= T0;
			T0:       Present_state <= T1;
			T1:       Present_state <= T2;
			T2:       Present_state <= T3;
			T3:       Present_state <= T4;
			T4:       Present_state <= T5;
			T5:       Present_state <= T5;
		endcase
	end

	// Control logic per state
	always @(Present_state) begin
		case (Present_state)
			Default: begin
				// Clear everything
				PCoutA <= 0; HIoutA <= 0; LOoutA <= 0;
				ZhighoutA <= 0; ZlowoutA <= 0; MDRoutA <= 0;
				InPortoutA <= 0; CoutA <= 0; RoutA <= 16'b0;

				PCoutB <= 0; HIoutB <= 0; LOoutB <= 0;
				ZhighoutB <= 0; ZlowoutB <= 0; MDRoutB <= 0;
				InPortoutB <= 0; CoutB <= 0; RoutB <= 16'b0;

				ZlowoutC <= 0; ZhighoutC <= 0; MDRoutC <= 0;
				PCoutC <= 0; InPortoutC <= 0; CoutC <= 0;

				PCin <= 0; IRin <= 0; MARin <= 0;
				Yin <= 0; HIin <= 0; LOin <= 0;
				Zin <= 0; MDRin <= 0; InPortin <= 0;
				Cin <= 0; Rin <= 16'b0;

				IncPC <= 0; Read <= 0;

				ADD <= 0; SUB <= 0; AND_op <= 0;
				OR_op <= 0; SHR_op <= 0; SHRA_op <= 0;
				SHL_op <= 0; ROR_op <= 0; ROL_op <= 0;
				NEG_op <= 0; NOT_op <= 0; MUL_op <= 0;
				DIV_op <= 0;

				Mdatain <= 32'h00000000;
			end
			LoadR5a: begin
				Mdatain <= 32'h00000034;
				Read <= 1; MDRin <= 1;
				#20 Read <= 0; MDRin <= 0; // Put 0x34 in MDR
			end
			LoadR5b: begin
				MDRoutC <= 1; Rin[5] <= 1;
				#20 MDRoutC <= 0; Rin[5] <= 0; // Initialize R5 with 0x34
			end
			LoadR6a: begin
				Mdatain <= 32'h00000045;
				Read <= 1; MDRin <= 1;
				#20 Read <= 0; MDRin <= 0; // Put 0x45 in MDR
			end
			LoadR6b: begin
				MDRoutC <= 1; Rin[6] <= 1;
				#20 MDRoutC <= 0; Rin[6] <= 0; // Initialize R6 with 0x45
			end

			T0: begin
				PCoutC <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
				#20 PCoutC <= 0; MARin <= 0; IncPC <= 0; Zin <= 0;
			end
			T1: begin
				Mdatain = 32'h012B0000;  // ADD R2,R5,R6 opcode
				ZlowoutC <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
				#20 ZlowoutC <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
			end
			T2: begin
				MDRoutC <= 1; IRin <= 1;
				#20 MDRoutC <= 0; IRin <= 0;
			end
			T3: begin
				RoutA[5] <= 1; RoutB[6] <= 1; ADD <= 1; Zin <= 1;
				#20 RoutA[5] <= 0; RoutB[6] <= 0; ADD <= 0; Zin <= 0;
			end
			T4: begin
				ZlowoutC <= 1; Rin[2] <= 1;
				#20 ZlowoutC <= 0; Rin[2] <= 0;
			end
			T5: begin
			end
		endcase
	end

endmodule