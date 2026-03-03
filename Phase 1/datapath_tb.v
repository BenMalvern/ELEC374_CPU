`timescale 1ns/10ps

module datapath_tb;

  localparam DATA_WIDTH = 32;

  // Clocking
  reg clock;
  reg clear;

  // Phase 1 "memory" inputs for MDR
  reg Read;
  reg [DATA_WIDTH-1:0] Mdatain;

  // Write enables
  reg PCin, IRin, HIin, LOin, Zin, MDRin, InPortin, Cin;
  reg [15:0] Rin;

  // Bus drivers (one-hot)
  reg PCout, HIout, LOout, Zhighout, Zlowout, MDRout, InPortout, Cout;
  reg [15:0] Rout;

  // Observability
  wire [DATA_WIDTH-1:0] BusMuxOut;

  wire [DATA_WIDTH-1:0] PC_Q, IR_Q, HI_Q, LO_Q, Z_HI_Q, Z_LO_Q, MDR_Q, InPort_Q, C_Q;
  wire [DATA_WIDTH-1:0] R0_Q, R1_Q, R2_Q, R3_Q, R4_Q, R5_Q, R6_Q, R7_Q, R8_Q, R9_Q, R10_Q, R11_Q, R12_Q, R13_Q, R14_Q, R15_Q;

  // DUT
  datapath #(DATA_WIDTH) dut (
    .clock(clock),
    .clear(clear),

    .Read(Read),
    .Mdatain(Mdatain),

    .PCin(PCin),
    .IRin(IRin),
    .HIin(HIin),
    .LOin(LOin),
    .Zin(Zin),
    .MDRin(MDRin),
    .InPortin(InPortin),
    .Cin(Cin),
    .Rin(Rin),

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

  // Clock generator: 20ns period
  initial begin
    clock = 1'b0;
    forever #10 clock = ~clock;
  end

  // Helper: set everything to 0
  task automatic clr_controls;
    begin
      // memory
      Read    = 1'b0;
      Mdatain = 32'b0;

      // in signals
      PCin = 0; IRin = 0; HIin = 0; LOin = 0; Zin = 0; MDRin = 0; InPortin = 0; Cin = 0;
      Rin  = 16'b0;

      // out signals
      PCout = 0; HIout = 0; LOout = 0; Zhighout = 0; Zlowout = 0; MDRout = 0; InPortout = 0; Cout = 0;
      Rout  = 16'b0;
    end
  endtask

  // Helper: one clock tick with stable controls
  task automatic tick;
    begin
      @(negedge clock);
      @(posedge clock);
      #1;
    end
  endtask

  // Load MDR from Mdatain (Read=1), then write MDR to any register via bus
  task automatic load_reg_from_const(input integer reg_idx, input [31:0] value);
    begin
      // Put value on Mdatain and latch into MDR
      clr_controls();
      Mdatain = value;
      Read    = 1'b1;
      MDRin   = 1'b1;
      tick();

      // Drive MDR onto bus and write into target register
      clr_controls();
      MDRout = 1'b1;
      Rin[reg_idx] = 1'b1;
      tick();

      clr_controls();
    end
  endtask

  // Load PC from a constant using MDR -> bus -> PC
  task automatic load_pc_from_const(input [31:0] value);
    begin
      clr_controls();
      Mdatain = value;
      Read    = 1'b1;
      MDRin   = 1'b1;
      tick();

      clr_controls();
      MDRout = 1'b1;
      PCin   = 1'b1;
      tick();

      clr_controls();
    end
  endtask

  // Fetch sequence skeleton (Phase 1 style)
  // T0: PCout, (MARin would happen here if you have MAR), plus "IncPC -> Zin" in full CPU
  // T1: Read, MDRin, (Mdatain is instruction), then later move PC+1 back into PC
  // T2: MDRout, IRin
  // Since your current datapath code does not include MAR or IncPC logic, this TB only shows MDR->IR part.
  task automatic fetch_ir_from_const(input [31:0] instr);
    begin
      // T1 equivalent: Read instruction into MDR
      clr_controls();
      Mdatain = instr;
      Read    = 1'b1;
      MDRin   = 1'b1;
      tick();

      // T2: MDRout -> IRin
      clr_controls();
      MDRout = 1'b1;
      IRin   = 1'b1;
      tick();

      clr_controls();
    end
  endtask

  initial begin
    clr_controls();

    // Reset
    clear = 1'b1;
    #25;
    clear = 1'b0;

    // Preload a couple registers
    load_reg_from_const(5, 32'h0000_000F); // R5 = 15
    load_reg_from_const(6, 32'h0000_00F0); // R6 = 240
    load_reg_from_const(2, 32'hDEAD_BEEF); // R2 initial value, will be overwritten later if you implement ALU/Z path

    // Load a fake instruction into IR (you can put any pattern for now)
    fetch_ir_from_const(32'h1234_5678);

    // Simple bus sanity checks (no ALU required):
    // 1) Put R5 on bus and verify BusMuxOut
    clr_controls();
    Rout[5] = 1'b1;
    #2;
    if (BusMuxOut !== R5_Q) begin
      $display("FAIL: BusMuxOut != R5_Q. BusMuxOut=%h R5_Q=%h", BusMuxOut, R5_Q);
      $fatal;
    end

    // 2) Put R6 on bus and verify
    clr_controls();
    Rout[6] = 1'b1;
    #2;
    if (BusMuxOut !== R6_Q) begin
      $display("FAIL: BusMuxOut != R6_Q. BusMuxOut=%h R6_Q=%h", BusMuxOut, R6_Q);
      $fatal;
    end

    // 3) Put MDR on bus and verify it matches the last thing loaded (IR fetch used instr)
    clr_controls();
    MDRout = 1'b1;
    #2;
    if (BusMuxOut !== MDR_Q) begin
      $display("FAIL: BusMuxOut != MDR_Q. BusMuxOut=%h MDR_Q=%h", BusMuxOut, MDR_Q);
      $fatal;
    end

    $display("PASS: datapath_tb basic bus/register/MDR/IR tests completed");
    $finish;
  end

endmodule