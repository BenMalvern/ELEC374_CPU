`timescale 1ns/10ps

module processor (
    input  wire        clock,
    input  wire        clear,
    input  wire [31:0] external_input,
    input  wire        InPort_strobe,
    output wire [31:0] out_port_data,
    output wire        stop
);

    // =========================
    // Control <-> Datapath wires
    // =========================
    wire Read, Write;

    wire PCin, IRin, MARin, MDRin, Zin, HIin, LOin, Cin;
    wire GraA, GrbA, GrcA;
    wire GraB, GrbB, GrcB;
    wire GraC, GrbC, GrcC;
    wire GraIn, GrbIn, GrcIn;
    wire Rin, R12in, RoutA, RoutB, RoutC, BAout;
    wire CONin;

    wire IncPC;
    wire ADD, SUB, AND_op, OR_op;
    wire SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op;
    wire NEG_op, NOT_op, MUL_op, DIV_op;

    wire PCoutA, HIoutA, LOoutA, ZhighoutA, ZlowoutA, MDRoutA, InPortoutA, CoutA;
    wire PCoutB, HIoutB, LOoutB, ZhighoutB, ZlowoutB, MDRoutB, InPortoutB, CoutB;
    wire PCoutC, HIoutC, LOoutC, ZhighoutC, ZlowoutC, MDRoutC, InPortoutC, CoutC;

    wire OutPortin;
    wire Run;
    wire Clear_from_CU;

    // Datapath observable wires
    wire [31:0] BusMuxOut_A, BusMuxOut_B, BusMuxOut_C;
    wire [31:0] PC_Q, IR_Q, HI_Q, LO_Q, Z_HI_Q, Z_LO_Q, MDR_Q, MAR_Q, InPort_Q;
    wire [31:0] R0_Q, R1_Q, R2_Q, R3_Q, R4_Q, R5_Q, R6_Q, R7_Q;
    wire [31:0] R8_Q, R9_Q, R10_Q, R11_Q, R12_Q, R13_Q, R14_Q, R15_Q;
    wire CON_FF_Q;

    // control_unit uses active-high Stop to force halt.
    // The testbench does not drive an external stop, so tie it low here.
    wire Stop_in = 1'b0;
    wire Reset = clear;

    control_unit CU (
        .Clock(clock),
        .Reset(Reset),
        .Stop(Stop_in),
        .CON_FF(CON_FF_Q),
        .IR(IR_Q),

        .Run(Run),
        .Clear(Clear_from_CU),

        .GraA(GraA),
        .GrbA(GrbA),
        .GrcA(GrcA),
        .GraB(GraB),
        .GrbB(GrbB),
        .GrcB(GrcB),
        .GraC(GraC),
        .GrbC(GrbC),
        .GrcC(GrcC),
        .GraIn(GraIn),
        .GrbIn(GrbIn),
        .GrcIn(GrcIn),
        .Rin(Rin),
        .R12in(R12in),
        .RoutA(RoutA),
        .RoutB(RoutB),
        .RoutC(RoutC),
        .BAout(BAout),

        .PCin(PCin),
        .IRin(IRin),
        .MARin(MARin),
        .MDRin(MDRin),
        .Zin(Zin),
        .HIin(HIin),
        .LOin(LOin),
        .Cin(Cin),

        .Read(Read),
        .Write(Write),
        .OutPortin(OutPortin),

        .IncPC(IncPC),
        .CONin(CONin),

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

        .PCoutA(PCoutA),
        .HIoutA(HIoutA),
        .LOoutA(LOoutA),
        .ZhighoutA(ZhighoutA),
        .ZlowoutA(ZlowoutA),
        .MDRoutA(MDRoutA),
        .InPortoutA(InPortoutA),
        .CoutA(CoutA),

        .PCoutB(PCoutB),
        .HIoutB(HIoutB),
        .LOoutB(LOoutB),
        .ZhighoutB(ZhighoutB),
        .ZlowoutB(ZlowoutB),
        .MDRoutB(MDRoutB),
        .InPortoutB(InPortoutB),
        .CoutB(CoutB),

        .PCoutC(PCoutC),
        .HIoutC(HIoutC),
        .LOoutC(LOoutC),
        .ZhighoutC(ZhighoutC),
        .ZlowoutC(ZlowoutC),
        .MDRoutC(MDRoutC),
        .InPortoutC(InPortoutC),
        .CoutC(CoutC)
    );


    datapath DP (
        .clock(clock),
        .clear(clear),

        .Read(Read),
        .Write(Write),

        .PCin(PCin),
        .IRin(IRin),
        .MARin(MARin),
        .HIin(HIin),
        .LOin(LOin),
        .Zin(Zin),
        .MDRin(MDRin),
        .Cin(Cin),

        .GraA(GraA), .GrbA(GrbA), .GrcA(GrcA),
        .GraB(GraB), .GrbB(GrbB), .GrcB(GrcB),
        .GraC(GraC), .GrbC(GrbC), .GrcC(GrcC),
        .GraIn(GraIn), .GrbIn(GrbIn), .GrcIn(GrcIn),
        .Rin(Rin),
        .R12in(R12in),
        .RoutA(RoutA), .RoutB(RoutB), .RoutC(RoutC), .BAout(BAout),
        .CONin(CONin),

        .IncPC(IncPC),

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

        .BusMuxOut_A(BusMuxOut_A),
        .BusMuxOut_B(BusMuxOut_B),
        .BusMuxOut_C(BusMuxOut_C),

        .PCoutA(PCoutA), .HIoutA(HIoutA), .LOoutA(LOoutA), .ZhighoutA(ZhighoutA), .ZlowoutA(ZlowoutA), .MDRoutA(MDRoutA), .InPortoutA(InPortoutA), .CoutA(CoutA),
        .PCoutB(PCoutB), .HIoutB(HIoutB), .LOoutB(LOoutB), .ZhighoutB(ZhighoutB), .ZlowoutB(ZlowoutB), .MDRoutB(MDRoutB), .InPortoutB(InPortoutB), .CoutB(CoutB),
        .PCoutC(PCoutC), .HIoutC(HIoutC), .LOoutC(LOoutC), .ZhighoutC(ZhighoutC), .ZlowoutC(ZlowoutC), .MDRoutC(MDRoutC), .InPortoutC(InPortoutC), .CoutC(CoutC),

        .external_input(external_input),
        .InPort_strobe(InPort_strobe),
        .OutPortin(OutPortin),
        .OutPort_Q(out_port_data),

        .PC_Q(PC_Q),
        .IR_Q(IR_Q),
        .HI_Q(HI_Q),
        .LO_Q(LO_Q),
        .Z_HI_Q(Z_HI_Q),
        .Z_LO_Q(Z_LO_Q),
        .MDR_Q(MDR_Q),
        .MAR_Q(MAR_Q),
        .InPort_Q(InPort_Q),
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
        .R15_Q(R15_Q),
        .CON_FF_Q(CON_FF_Q)
    );

    // Testbench expects stop to go high on HALT.
    assign stop = ~Run;

endmodule
