`timescale 1ns/10ps

/* ============================================================
   ELEC 374 Phase 1
   Instruction Testbench: AND

   Student Name: _______________________
   Student Number: _____________________
   Date: _______________________________

   Instruction:
     and R2, R5, R6

   Expected behavior:
     R2 <- R5 AND R6

   Micro-ops used:
     T0: PCout, MARin, IncPC, Zin
     T1: Zlowout, PCin, Read, MDRin, Mdatain = instruction
     T2: MDRout, IRin
     T3: R5out, Yin
     T4: R6out, AND, Zin
     T5: Zlowout, R2in
   ============================================================ */

module and_instr_tb;

  localparam DATA_WIDTH = 32;

  // Clocking
  reg clock;
  reg clear;

  // Phase 1 "memory" inputs for MDR
  reg Read;
  reg [DATA_WIDTH-1:0] Mdatain;

  // Write enables
  reg PCin, IRin, MARin, Yin, HIin, LOin, Zin, MDRin, InPortin, Cin;
  reg [15:0] Rin;

  // Special control
  reg IncPC;

  // ALU control
  reg ADD, SUB, AND_op, OR_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op, MUL_op, DIV_op;

  // Bus drivers (one-hot)
  reg PCout, HIout, LOout, Zhighout, Zlowout, MDRout, InPortout, Cout;
  reg [15:0] Rout;

  // Observability
  wire [DATA_WIDTH-1:0] BusMuxOut;

  wire [DATA_WIDTH-1:0] PC_Q, IR_Q, MAR_Q, Y_Q, HI_Q, LO_Q, Z_HI_Q, Z_LO_Q, MDR_Q, InPort_Q, C_Q;
  wire [DATA_WIDTH-1:0] R0_Q, R1_Q, R2_Q, R3_Q, R4_Q, R5_Q, R6_Q, R7_Q, R8_Q, R9_Q, R10_Q, R11_Q, R12_Q, R13_Q, R14_Q, R15_Q;

  // DUT
  datapath #(DATA_WIDTH) dut (
    .clock(clock),
    .clear(clear),

    .Read(Read),
    .Mdatain(Mdatain),

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

    .PCout(PCout),
    .HIout(HIout),
    .LOout(LOout),
    .Zhighout(Zhighout),
    .Zlowout(Zlowout),
    .MDRout(MDRout),
    .InPortout(InPortout),
    .Cout(Cout),
    .Rout(Rout),

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
    .R0_Q(R0_Q), .R1_Q(R1_Q), .R2_Q(R2_Q), .R3_Q(R3_Q),
    .R4_Q(R4_Q), .R5_Q(R5_Q), .R6_Q(R6_Q), .R7_Q(R7_Q),
    .R8_Q(R8_Q), .R9_Q(R9_Q), .R10_Q(R10_Q), .R11_Q(R11_Q),
    .R12_Q(R12_Q), .R13_Q(R13_Q), .R14_Q(R14_Q), .R15_Q(R15_Q)
  );

  // Clock generation
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  task clr_controls;
    begin
      Read = 0;
      Mdatain = 0;

      PCin = 0; IRin = 0; MARin = 0; Yin = 0; HIin = 0; LOin = 0; Zin = 0; MDRin = 0; InPortin = 0; Cin = 0;
      Rin = 16'b0;

      IncPC = 0;

      ADD = 0; SUB = 0; AND_op = 0; OR_op = 0; SHR_op = 0; SHRA_op = 0; SHL_op = 0; ROR_op = 0; ROL_op = 0;
      NEG_op = 0; NOT_op = 0; MUL_op = 0; DIV_op = 0;

      PCout = 0; HIout = 0; LOout = 0; Zhighout = 0; Zlowout = 0; MDRout = 0; InPortout = 0; Cout = 0;
      Rout = 16'b0;
    end
  endtask

  task tick;
    begin
      @(negedge clock);
    end
  endtask

  function [31:0] enc_R(input [4:0] op, input [3:0] ra, rb, rc);
    begin
      enc_R = {op, ra, rb, rc, 15'b0};
    end
  endfunction

  localparam [4:0] OP_AND = 5'b00010;

  initial begin
    clr_controls;
    clear = 1;
    tick;
    clear = 0;

    // ------------------------------------------------------------
    // Preload registers:
    //   R5 = 0xF0F0_F0F0
    //   R6 = 0x0FF0_00FF
    // Expected R2 = R5 & R6 = 0x00F0_00F0
    // ------------------------------------------------------------

    // Load R5
    clr_controls;
    Mdatain = 32'hF0F0_F0F0;
    Read = 1;
    MDRin = 1;
    tick;

    clr_controls;
    MDRout = 1;
    Rin[5] = 1;     // R5in
    tick;

    // Load R6
    clr_controls;
    Mdatain = 32'h0FF0_00FF;
    Read = 1;
    MDRin = 1;
    tick;

    clr_controls;
    MDRout = 1;
    Rin[6] = 1;     // R6in
    tick;

    // ------------------------------------------------------------
    // Fetch: and R2, R5, R6
    // ------------------------------------------------------------
    // T0: PCout, MARin, IncPC, Zin
    clr_controls;
    PCout = 1;
    MARin = 1;
    IncPC = 1;
    Zin = 1;
    tick;

    // T1: Zlowout, PCin, Read, MDRin, Mdatain = instruction
    clr_controls;
    Zlowout = 1;
    PCin = 1;
    Read = 1;
    MDRin = 1;
    Mdatain = enc_R(OP_AND, 4'd2, 4'd5, 4'd6);  // and R2,R5,R6
    tick;

    // T2: MDRout, IRin
    clr_controls;
    MDRout = 1;
    IRin = 1;
    tick;

    // ------------------------------------------------------------
    // Execute AND
    // ------------------------------------------------------------
    // T3: R5out, Yin
    clr_controls;
    Rout[5] = 1;
    Yin = 1;
    tick;

    // T4: R6out, AND, Zin
    clr_controls;
    Rout[6] = 1;
    AND_op = 1;
    Zin = 1;
    tick;

    // T5: Zlowout, R2in
    clr_controls;
    Zlowout = 1;
    Rin[2] = 1;
    tick;

    // ------------------------------------------------------------
    // Check result
    // ------------------------------------------------------------
    #1;
    if (R2_Q !== 32'h00F0_00F0) begin
      $display("FAIL: R2 = %h, expected 00F000F0", R2_Q);
    end else begin
      $display("PASS: R2 = %h", R2_Q);
    end

    $stop;
  end

endmodule