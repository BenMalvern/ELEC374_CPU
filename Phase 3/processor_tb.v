`timescale 1ns/10ps

module processor_tb;

    parameter DATA_WIDTH = 32;

    reg clock;
    reg clear;
    reg stop;

    reg [31:0] external_input;
    reg InPort_strobe;
    reg OutPortin;

    wire Run;
    wire Clear;

    // Select / encode signals
    wire Gra;
    wire Grb;
    wire Grc;
    wire Rin;
    wire RoutA;
    wire RoutB;
    wire RoutC;
    wire BAout;

    // Datapath register control
    wire PCin;
    wire IRin;
    wire MARin;
    wire MDRin;
    wire Zin;
    wire HIin;
    wire LOin;
    wire Cin;

    // Memory control
    wire Read;
    wire Write;

    // Special control
    wire IncPC;
    wire CONin;

    // ALU control
    wire ADD;
    wire SUB;
    wire AND_op;
    wire OR_op;
    wire SHR_op;
    wire SHRA_op;
    wire SHL_op;
    wire ROR_op;
    wire ROL_op;
    wire NEG_op;
    wire NOT_op;
    wire MUL_op;
    wire DIV_op;

    // A bus drivers
    wire PCoutA;
    wire HIoutA;
    wire LOoutA;
    wire ZhighoutA;
    wire ZlowoutA;
    wire MDRoutA;
    wire InPortoutA;
    wire CoutA;

    // B bus drivers
    wire PCoutB;
    wire HIoutB;
    wire LOoutB;
    wire ZhighoutB;
    wire ZlowoutB;
    wire MDRoutB;
    wire InPortoutB;
    wire CoutB;

    // C bus drivers
    wire PCoutC;
    wire HIoutC;
    wire LOoutC;
    wire ZhighoutC;
    wire ZlowoutC;
    wire MDRoutC;
    wire InPortoutC;
    wire CoutC;

    wire [DATA_WIDTH-1:0] BusMuxOut_A;
    wire [DATA_WIDTH-1:0] BusMuxOut_B;
    wire [DATA_WIDTH-1:0] BusMuxOut_C;

    wire [31:0] PC_Q;
    wire [31:0] IR_Q;
    wire [31:0] MAR_Q;
    wire [31:0] HI_Q;
    wire [31:0] LO_Q;
    wire [31:0] Z_HI_Q;
    wire [31:0] Z_LO_Q;
    wire [31:0] MDR_Q;
    wire [31:0] InPort_Q;
    wire [31:0] OutPort_Q;
    wire [31:0] R0_Q;
    wire [31:0] R1_Q;
    wire [31:0] R2_Q;
    wire [31:0] R3_Q;
    wire [31:0] R4_Q;
    wire [31:0] R5_Q;
    wire [31:0] R6_Q;
    wire [31:0] R7_Q;
    wire [31:0] R8_Q;
    wire [31:0] R9_Q;
    wire [31:0] R10_Q;
    wire [31:0] R11_Q;
    wire [31:0] R12_Q;
    wire [31:0] R13_Q;
    wire [31:0] R14_Q;
    wire [31:0] R15_Q;
    wire CON_FF_Q;

    reg [31:0] add_instr;
    reg [31:0] halt_instr;

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    control_unit CU (
        .Clock(clock),
        .Reset(clear),
        .Stop(stop),
        .CON_FF(CON_FF_Q),
        .IR(IR_Q),

        .Run(Run),
        .Clear(Clear),

        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin(Rin),
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

    datapath DUT (
        .clock(clock),
        .clear(Clear),

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
        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin(Rin),
        .RoutA(RoutA),
        .RoutB(RoutB),
        .RoutC(RoutC),
        .BAout(BAout),
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
        .CoutC(CoutC),

        .external_input(external_input),
        .InPort_strobe(InPort_strobe),
        .OutPortin(OutPortin),
        .OutPort_Q(OutPort_Q),

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

    initial begin
        clear = 1'b1;
        stop = 1'b0;
        external_input = 32'b0;
        InPort_strobe = 1'b0;
        OutPortin = 1'b0;

        // add R1, R2, R3
        add_instr[31:27] = 5'b00000;
        add_instr[26:23] = 4'd1;
        add_instr[22:19] = 4'd2;
        add_instr[18:15] = 4'd3;
        add_instr[14:0] = 15'b0;

        // halt
        halt_instr[31:27] = 5'b11111;
        halt_instr[26:0] = 27'b0;

        // preload source registers
        force DUT.R2_REG.BUS_MUX_IN = 32'h00000005;
        force DUT.R3_REG.BUS_MUX_IN = 32'h00000007;

        // instruction memory
        force DUT.RAM.memory[0] = add_instr[7:0];
        force DUT.RAM.memory[1] = add_instr[15:8];
        force DUT.RAM.memory[2] = add_instr[23:16];
        force DUT.RAM.memory[3] = add_instr[31:24];

        force DUT.RAM.memory[4] = halt_instr[7:0];
        force DUT.RAM.memory[5] = halt_instr[15:8];
        force DUT.RAM.memory[6] = halt_instr[23:16];
        force DUT.RAM.memory[7] = halt_instr[31:24];

        #15 clear = 1'b0;

    end

endmodule