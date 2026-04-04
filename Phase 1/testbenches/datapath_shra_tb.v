`timescale 1ns/10ps

module datapath_shra_tb;

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
	reg PCout, HIout, LOout, Zhighout, Zlowout;
	reg MDRout, InPortout, Cout;
	reg [15:0] Rout;
	wire [DATA_WIDTH-1:0] BusMuxOut;
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

		// Bus drivers
		.PCout(PCout),
		.HIout(HIout),
		.LOout(LOout),
		.Zhighout(Zhighout),
		.Zlowout(Zlowout),
		.MDRout(MDRout),
		.InPortout(InPortout),
		.Cout(Cout),
		.Rout(Rout),

		// Outputs
		.BusMuxOut(BusMuxOut),

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
			  LoadR0a = 4'd1,
			  LoadR0b = 4'd2,
			  LoadR4a = 4'd3,
			  LoadR4b = 4'd4,
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
			Default:  Present_state <= LoadR0a;
			LoadR0a:  Present_state <= LoadR0b;
			LoadR0b:  Present_state <= LoadR4a;
			LoadR4a:  Present_state <= LoadR4b;
			LoadR4b:  Present_state <= T0;
			T0:       Present_state <= T1;
			T1:       Present_state <= T2;
			T2:       Present_state <= T3;
			T3:       Present_state <= T4;
			T4:       Present_state <= T5;
			T5:       Present_state <= T5;
		endcase
	end
	
	integer i;
	// Control logic per state
	always @(Present_state) begin
		case (Present_state)
			Default: begin
				// Clear everything
				PCout <= 0; HIout <= 0; LOout <= 0;
				Zhighout <= 0; Zlowout <= 0; MDRout <= 0;
				InPortout <= 0; Cout <= 0; Rout <= 16'b0;

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
			LoadR0a: begin
				Mdatain <= 32'hF00000EF;
				Read <= 1; MDRin <= 1;
				#20 Read <= 0; MDRin <= 0; // Put 0xF00000EF in MDR
			end
			LoadR0b: begin
				MDRout <= 1; Rin[0] <= 1;
				#20 MDRout <= 0; Rin[0] <= 0; // Initialize R0 with 0xF00000EF
			end
			LoadR4a: begin
				Mdatain <= 32'h00000001;
				Read <= 1; MDRin <= 1;
				#20 Read <= 0; MDRin <= 0; // Put 0x1 in MDR
			end
			LoadR4b: begin
				MDRout <= 1; Rin[4] <= 1;
				#20 MDRout <= 0; Rin[4] <= 0; // Initialize R4 with 0x1
			end

			T0: begin
				PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
				#20 PCout <= 0; MARin <= 0; IncPC <= 0; Zin <= 0;
			end
			T1: begin
				Mdatain = 32'h2B820000;  // SHRA R7, R0, R4 opcode
				Zlowout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
				#20 Zlowout <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
			end
			T2: begin
				MDRout <= 1; IRin <= 1;
				#20 MDRout <= 0; IRin <= 0;
			end
			T3: begin
				Rout[0] <= 1; Yin <= 1;
				#20 Rout[0] <= 0; Yin <= 0;
			end
			T4: begin
				Rout[4] <= 1; SHRA_op <= 1; Zin <= 1;
				#20 Rout[4] <= 0; SHRA_op <= 0; Zin <= 0;
			end
			T5: begin
				Zlowout <= 1; Rin[7] <= 1;
				#20 Zlowout <= 0; Rin[7] <= 0;
			end
		endcase
	end

endmodule