`timescale 1ns/10ps

module datapath #(parameter DATA_WIDTH = 32)
(
    input wire clock,
    input wire clear,

    input wire Read,
    input wire Write,
	
    // Write enables
    input wire PCin,
    input wire IRin,
    input wire MARin,
    input wire Yin,
    input wire HIin,
    input wire LOin,
    input wire Zin, // enables both Z registers
    input wire MDRin,
    input wire InPortin,
    input wire Cin,
    input wire Gra, Grb, Grc, // Select and encode logic
	input wire Rin, Rout, BAout, 

    // Special control
    input wire IncPC,

    // ALU control signals (one-hot)
    input wire ADD,
    input wire SUB,
    input wire AND_op,
    input wire OR_op,
    input wire SHR_op,
    input wire SHRA_op,
    input wire SHL_op,
    input wire ROR_op,
    input wire ROL_op,
    input wire NEG_op,
    input wire NOT_op,
    input wire MUL_op,
    input wire DIV_op,

    // 3 bus system
    output wire [DATA_WIDTH-1:0] BusMuxOut_A,
	output wire [DATA_WIDTH-1:0] BusMuxOut_B,
	output wire [DATA_WIDTH-1:0] BusMuxOut_C,
	
	// A bus drivers
    input wire PCoutA,
    input wire HIoutA,
    input wire LOoutA,
    input wire ZhighoutA,
    input wire ZlowoutA,
    input wire MDRoutA,
    input wire InPortoutA,
    input wire CoutA,
	
	// B bus drivers
    input wire PCoutB,
    input wire HIoutB,
    input wire LOoutB,
    input wire ZhighoutB,
    input wire ZlowoutB,
    input wire MDRoutB,
    input wire InPortoutB,
    input wire CoutB,
	
	// C bus writeback source select
    input wire ZlowoutC,
	input wire ZhighoutC,
	input wire MDRoutC,
	input wire PCoutC,
	input wire InPortoutC,
	input wire CoutC,
	
    // Expose register values
    output wire [DATA_WIDTH-1:0] PC_Q,
    output wire [DATA_WIDTH-1:0] IR_Q,
    output wire [DATA_WIDTH-1:0] Y_Q,
    output wire [DATA_WIDTH-1:0] HI_Q,
    output wire [DATA_WIDTH-1:0] LO_Q,
    output wire [DATA_WIDTH-1:0] Z_HI_Q,
    output wire [DATA_WIDTH-1:0] Z_LO_Q,
    output wire [DATA_WIDTH-1:0] MDR_Q,
	output wire [DATA_WIDTH-1:0] MAR_Q,
    output wire [DATA_WIDTH-1:0] InPort_Q,
    output wire [DATA_WIDTH-1:0] R0_Q,
    output wire [DATA_WIDTH-1:0] R1_Q,
    output wire [DATA_WIDTH-1:0] R2_Q,
    output wire [DATA_WIDTH-1:0] R3_Q,
    output wire [DATA_WIDTH-1:0] R4_Q,
    output wire [DATA_WIDTH-1:0] R5_Q,
    output wire [DATA_WIDTH-1:0] R6_Q,
    output wire [DATA_WIDTH-1:0] R7_Q,
    output wire [DATA_WIDTH-1:0] R8_Q,
    output wire [DATA_WIDTH-1:0] R9_Q,
    output wire [DATA_WIDTH-1:0] R10_Q,
    output wire [DATA_WIDTH-1:0] R11_Q,
    output wire [DATA_WIDTH-1:0] R12_Q,
    output wire [DATA_WIDTH-1:0] R13_Q,
    output wire [DATA_WIDTH-1:0] R14_Q,
    output wire [DATA_WIDTH-1:0] R15_Q
);

    // Bus A control vector
    wire [23:0] bus_control_A;
    assign bus_control_A[15:0] = RoutA_sel;
    assign bus_control_A[16] = HIoutA;
    assign bus_control_A[17] = LOoutA;
    assign bus_control_A[18] = ZhighoutA;
    assign bus_control_A[19] = ZlowoutA;
    assign bus_control_A[20] = PCoutA;
    assign bus_control_A[21] = MDRoutA;
    assign bus_control_A[22] = InPortoutA;
    assign bus_control_A[23] = CoutA;
	
	// Bus B control vector
    wire [23:0] bus_control_B;
    assign bus_control_B[15:0] = RoutB_sel;
    assign bus_control_B[16] = HIoutB;
    assign bus_control_B[17] = LOoutB;
    assign bus_control_B[18] = ZhighoutB;
    assign bus_control_B[19] = ZlowoutB;
    assign bus_control_B[20] = PCoutB;
    assign bus_control_B[21] = MDRoutB;
    assign bus_control_B[22] = InPortoutB;
    assign bus_control_B[23] = CoutB;

	// Bus C writeback mux
	reg [DATA_WIDTH-1:0] C_bus_reg;
	assign BusMuxOut_C = C_bus_reg;
	
	always @(*) begin
		if (ZlowoutC) C_bus_reg = Z_LO_Q;
		else if (ZhighoutC) C_bus_reg = Z_HI_Q;
		else if (MDRoutC) C_bus_reg = MDR_Q;
		else if (PCoutC) C_bus_reg = PC_Q;
		else if (InPortoutC) C_bus_reg = InPort_Q;
		else if (CoutC) C_bus_reg = C_sign_extended;
		else C_bus_reg = {DATA_WIDTH{1'b0}};
	end
	
    // Standard registers (load from BusMuxOut unless otherwise stated)
    register PC_REG (
        .BUS_MUX_IN(PC_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(PCin)
    );

    register IR_REG (
        .BUS_MUX_IN(IR_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(IRin)
    );

    // Y register feeds ALU A input
    register Y_REG (
        .BUS_MUX_IN(Y_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(Yin)
    );

    register HI_REG (
        .BUS_MUX_IN(HI_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(HIin)
    );

    register LO_REG (
        .BUS_MUX_IN(LO_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(LOin)
    );

    register INPORT_REG (
        .BUS_MUX_IN(InPort_Q),
        .BUS_MUX_OUT(BusMuxOut_C),
        .clear(clear),
        .clock(clock),
        .enable(InPortin)
    );

	// Internal memory subsystem wires
    wire [DATA_WIDTH-1:0] BusMuxIn_MDR;	
	wire [DATA_WIDTH-1:0] Mdatain;
	wire [8:0] mem_address;
	assign mem_address = MAR_Q[8:0];

    mdr MDR_REG (
        .clk(clock),
        .clr(clear),
        .MDRin(MDRin),
        .Read(Read),
        .Mdatain(Mdatain),
        .BusMuxOut(BusMuxOut_C),
        .MDR_q(MDR_Q),
        .BusMuxIn_MDR(BusMuxIn_MDR)
    );
	
	mar MAR_REG (
        .clk(clock),
		.clr(clear),
		.MARin(MARin),
		.BusMuxOut(BusMuxOut_C),
		.MAR_q(MAR_Q)
    );
	
	ram RAM (
		.clk(clock),
		.Read(Read),
		.Write(Write),
		.address(mem_address),
		.data_in(MDR_Q),
		.data_out(Mdatain)
	);
	
    // General purpose registers R0 to R15
    register R0_REG(.BUS_MUX_IN(R0_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[0]));
    register R1_REG(.BUS_MUX_IN(R1_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[1]));
    register R2_REG(.BUS_MUX_IN(R2_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[2]));
    register R3_REG(.BUS_MUX_IN(R3_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[3]));
    register R4_REG(.BUS_MUX_IN(R4_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[4]));
    register R5_REG(.BUS_MUX_IN(R5_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[5]));
    register R6_REG(.BUS_MUX_IN(R6_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[6]));
    register R7_REG(.BUS_MUX_IN(R7_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[7]));
    register R8_REG(.BUS_MUX_IN(R8_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[8]));
    register R9_REG(.BUS_MUX_IN(R9_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[9]));
    register R10_REG(.BUS_MUX_IN(R10_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[10]));
    register R11_REG(.BUS_MUX_IN(R11_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[11]));
    register R12_REG(.BUS_MUX_IN(R12_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[12]));
    register R13_REG(.BUS_MUX_IN(R13_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[13]));
    register R14_REG(.BUS_MUX_IN(R14_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[14]));
    register R15_REG(.BUS_MUX_IN(R15_Q), .BUS_MUX_OUT(BusMuxOut_C), .clear(clear), .clock(clock), .enable(Rin_sel[15]));
	
	// Select and encode logic 
	wire [15:0] Rin_sel;
	wire [15:0] RoutA_sel;
	wire [15:0] RoutB_sel;
	wire [31:0] C_sign_extended;
	
	select_encode SELECT_ENCODE (
		.IR(IR_Q),
		.Gra(Gra),
		.Grb(Grb),
		.Grc(Grc),
		.Rin(Rin),
		.Rout(Rout),
		.BAout(BAout),
		.Rin_sel(Rin_sel),
		.RoutA_sel(RoutA_sel),
		.RoutB_sel(RoutB_sel),
		.C_sign_extended(C_sign_extended)
	);
	
	// BAout gates 0's on bus if R0 is selected
	wire [DATA_WIDTH-1:0] R0out_A;
	wire [DATA_WIDTH-1:0] R0out_B;
	assign R0out_A = (BAout && RoutA_sel[0]) ? {DATA_WIDTH{1'b0}} : R0_Q;
	assign R0out_B = (BAout && RoutB_sel[0]) ? {DATA_WIDTH{1'b0}} : R0_Q;
		
    // ALU instance
    wire [63:0] alu_result;

    alu U_ALU (
        .A(BusMuxOut_A),
        .B(BusMuxOut_B),
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
        .result(alu_result)
    );

    // Increment PC logic for fetch T0 (PC + 4)
    wire [DATA_WIDTH-1:0] pc_plus_4;
    cla #(DATA_WIDTH) U_PC_INC (
        .Z(pc_plus_4),
        .A(PC_Q),
        .Bin(32'd4),
        .sub(1'b0)
    );

    // What gets written into Z when Zin is asserted
    wire [63:0] Z_in64 = (IncPC) ? {32'b0, pc_plus_4} : alu_result;

    // Z registers load from internal Z_in64, not from BusMuxOut
    register Z_LO_REG (
        .BUS_MUX_IN(Z_LO_Q),
        .BUS_MUX_OUT(Z_in64[31:0]),
        .clear(clear),
        .clock(clock),
        .enable(Zin)
    );

    register Z_HI_REG (
        .BUS_MUX_IN(Z_HI_Q),
        .BUS_MUX_OUT(Z_in64[63:32]),
        .clear(clear),
        .clock(clock),
        .enable(Zin)
    );

    // Bus mux selects which Q drives BusMuxOut
    bus BusMuxA (
        .BusOut(BusMuxOut_A),
        .control(bus_control_A),
        .BusIn0(R0out_A),
        .BusIn1(R1_Q),
        .BusIn2(R2_Q),
        .BusIn3(R3_Q),
        .BusIn4(R4_Q),
        .BusIn5(R5_Q),
        .BusIn6(R6_Q),
        .BusIn7(R7_Q),
        .BusIn8(R8_Q),
        .BusIn9(R9_Q),
        .BusIn10(R10_Q),
        .BusIn11(R11_Q),
        .BusIn12(R12_Q),
        .BusIn13(R13_Q),
        .BusIn14(R14_Q),
        .BusIn15(R15_Q),
        .BusIn16(HI_Q),
        .BusIn17(LO_Q),
        .BusIn18(Z_HI_Q),
        .BusIn19(Z_LO_Q),
        .BusIn20(PC_Q),
        .BusIn21(BusMuxIn_MDR),
        .BusIn22(InPort_Q),
        .BusIn23(C_sign_extended)
    );
	
	bus BusMuxB (
        .BusOut(BusMuxOut_B),
        .control(bus_control_B),
        .BusIn0(R0out_B),
        .BusIn1(R1_Q),
        .BusIn2(R2_Q),
        .BusIn3(R3_Q),
        .BusIn4(R4_Q),
        .BusIn5(R5_Q),
        .BusIn6(R6_Q),
        .BusIn7(R7_Q),
        .BusIn8(R8_Q),
        .BusIn9(R9_Q),
        .BusIn10(R10_Q),
        .BusIn11(R11_Q),
        .BusIn12(R12_Q),
        .BusIn13(R13_Q),
        .BusIn14(R14_Q),
        .BusIn15(R15_Q),
        .BusIn16(HI_Q),
        .BusIn17(LO_Q),
        .BusIn18(Z_HI_Q),
        .BusIn19(Z_LO_Q),
        .BusIn20(PC_Q),
        .BusIn21(BusMuxIn_MDR),
        .BusIn22(InPort_Q),
        .BusIn23(C_sign_extended)
    );

endmodule