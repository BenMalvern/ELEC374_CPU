`timescale 1ns/10ps

module datapath_andi_tb;

    parameter DATA_WIDTH = 32;

    reg clock;
    reg clear;
    reg Read;
    reg Write;
    reg PCin, IRin, MARin, HIin, LOin, Zin, MDRin;
    reg InPort_strobe, OutPortin, Cin;
    reg [31:0] external_input;

    reg Gra, Grb, Grc;
    reg Rin, Rout, BAout;
    reg CONin;
    reg IncPC;
    reg ADD, SUB, AND_op, OR_op, SHR_op, SHRA_op;
    reg SHL_op, ROR_op, ROL_op, NEG_op, NOT_op;
    reg MUL_op, DIV_op;

    // A bus controls
    reg PCoutA, HIoutA, LOoutA, ZhighoutA, ZlowoutA;
    reg MDRoutA, InPortoutA, CoutA;

    // B bus controls
    reg PCoutB, HIoutB, LOoutB, ZhighoutB, ZlowoutB;
    reg MDRoutB, InPortoutB, CoutB;

    // C bus select
    reg ZlowoutC, ZhighoutC, MDRoutC, PCoutC, InPortoutC, CoutC;

    wire [DATA_WIDTH-1:0] BusMuxOut_A, BusMuxOut_B, BusMuxOut_C;

    wire [31:0] PC_Q, IR_Q, MAR_Q;
    wire [31:0] HI_Q, LO_Q;
    wire [31:0] Z_HI_Q, Z_LO_Q;
    wire [31:0] MDR_Q, InPort_Q, OutPort_Q;
    wire [31:0] R0_Q,  R1_Q,  R2_Q,  R3_Q;
    wire [31:0] R4_Q,  R5_Q,  R6_Q,  R7_Q;
    wire [31:0] R8_Q,  R9_Q,  R10_Q, R11_Q;
    wire [31:0] R12_Q, R13_Q, R14_Q, R15_Q;
    wire CON_FF_Q;

    datapath DUT (
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
        .InPort_strobe(InPort_strobe),
        .external_input(external_input),
        .OutPortin(OutPortin),
        .Cin(Cin),

        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin(Rin),
        .Rout(Rout),
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

        .ZlowoutC(ZlowoutC),
        .ZhighoutC(ZhighoutC),
        .MDRoutC(MDRoutC),
        .PCoutC(PCoutC),
        .InPortoutC(InPortoutC),
        .CoutC(CoutC),

        .PC_Q(PC_Q),
        .IR_Q(IR_Q),
        .MAR_Q(MAR_Q),
        .HI_Q(HI_Q),
        .LO_Q(LO_Q),
        .Z_HI_Q(Z_HI_Q),
        .Z_LO_Q(Z_LO_Q),
        .MDR_Q(MDR_Q),
        .InPort_Q(InPort_Q),
        .OutPort_Q(OutPort_Q),

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

    parameter Default = 4'd0,
              T0 = 4'd1,
              T1 = 4'd2,
              T2 = 4'd3,
              T3 = 4'd4,
              T4 = 4'd5;

    reg [3:0] Present_state;
    reg [31:0] andi_instr;

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        clear = 1'b1;
        #15 clear = 1'b0;

        // andi R7, R4, 0x71
        andi_instr[31:27] = 5'b01010;
        andi_instr[26:23] = 4'd7;    // Ra = R7
        andi_instr[22:19] = 4'd4;    // Rb = R4
        andi_instr[18:0]  = 19'h71;  // C = 0x71

        // preload R4 = 0x75 so the result should be 0x71
        force DUT.R4_REG.BUS_MUX_IN = 32'h00000075;

        // instruction memory
        force DUT.RAM.memory[0] = andi_instr[7:0];
        force DUT.RAM.memory[1] = andi_instr[15:8];
        force DUT.RAM.memory[2] = andi_instr[23:16];
        force DUT.RAM.memory[3] = andi_instr[31:24];

        Present_state = Default;
    end

    always @(posedge clock) begin
        case (Present_state)
            Default: Present_state <= T0;
            T0:      Present_state <= T1;
            T1:      Present_state <= T2;
            T2:      Present_state <= T3;
            T3:      Present_state <= T4;
            T4:      Present_state <= T4;
        endcase
    end

    always @(*) begin
        PCoutA = 0; HIoutA = 0; LOoutA = 0;
        ZhighoutA = 0; ZlowoutA = 0; MDRoutA = 0;
        InPortoutA = 0; CoutA = 0;

        PCoutB = 0; HIoutB = 0; LOoutB = 0;
        ZhighoutB = 0; ZlowoutB = 0; MDRoutB = 0;
        InPortoutB = 0; CoutB = 0;

        ZlowoutC = 0; ZhighoutC = 0; MDRoutC = 0;
        PCoutC = 0; InPortoutC = 0; CoutC = 0;

        PCin = 0; IRin = 0; MARin = 0;
        HIin = 0; LOin = 0;
        Zin = 0; MDRin = 0; InPort_strobe = 0;
        OutPortin = 0; Cin = 0; CONin = 0;
        external_input = 32'b0;

        Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0;

        IncPC = 0; Read = 0; Write = 0;

        ADD = 0; SUB = 0; AND_op = 0;
        OR_op = 0; SHR_op = 0; SHRA_op = 0;
        SHL_op = 0; ROR_op = 0; ROL_op = 0;
        NEG_op = 0; NOT_op = 0; MUL_op = 0;
        DIV_op = 0;

        case (Present_state)
            // T0-T2: instruction fetch
            T0: begin
                PCoutC = 1;
                MARin = 1;
                IncPC = 1;
                Zin = 1;
            end

            T1: begin
                ZlowoutC = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
            end

            T2: begin
                MDRoutC = 1;
                IRin = 1;
            end

            // T3: Grb, Rout, Cout, AND, Zin
            T3: begin
                Grb = 1;
                Rout = 1;
                CoutA = 1;
                AND_op = 1;
                Zin = 1;
            end

            // T4: Zlowout, Gra, Rin
            T4: begin
                ZlowoutC = 1;
                Gra = 1;
                Rin = 1;
            end
        endcase
    end

endmodule
