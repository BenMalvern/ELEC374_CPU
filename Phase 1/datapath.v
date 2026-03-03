`timescale 1ns/10ps

module datapath #(parameter DATA_WIDTH = 32)
(
    input  wire                   clock,
    input  wire                   clear,

    // Phase 1 mock memory inputs for MDR
    input  wire                   Read,
    input  wire [DATA_WIDTH-1:0]  Mdatain,

    // Write enables
    input  wire                   PCin,
    input  wire                   IRin,
    input  wire                   HIin,
    input  wire                   LOin,
    input  wire                   Zin,        // enables both Z registers
    input  wire                   MDRin,
    input  wire                   InPortin,
    input  wire                   Cin,
    input  wire [15:0]            Rin,        // R0in..R15in

    // Bus drivers (one-hot)
    input  wire                   PCout,
    input  wire                   HIout,
    input  wire                   LOout,
    input  wire                   Zhighout,
    input  wire                   Zlowout,
    input  wire                   MDRout,
    input  wire                   InPortout,
    input  wire                   Cout,
    input  wire [15:0]            Rout,       // R0out..R15out

    // Main bus output
    output wire [DATA_WIDTH-1:0]  BusMuxOut,

    // Expose register values
    output wire [DATA_WIDTH-1:0]  PC_Q,
    output wire [DATA_WIDTH-1:0]  IR_Q,
    output wire [DATA_WIDTH-1:0]  HI_Q,
    output wire [DATA_WIDTH-1:0]  LO_Q,
    output wire [DATA_WIDTH-1:0]  Z_HI_Q,
    output wire [DATA_WIDTH-1:0]  Z_LO_Q,
    output wire [DATA_WIDTH-1:0]  MDR_Q,
    output wire [DATA_WIDTH-1:0]  InPort_Q,
    output wire [DATA_WIDTH-1:0]  C_Q,
    output wire [DATA_WIDTH-1:0]  R0_Q,
    output wire [DATA_WIDTH-1:0]  R1_Q,
    output wire [DATA_WIDTH-1:0]  R2_Q,
    output wire [DATA_WIDTH-1:0]  R3_Q,
    output wire [DATA_WIDTH-1:0]  R4_Q,
    output wire [DATA_WIDTH-1:0]  R5_Q,
    output wire [DATA_WIDTH-1:0]  R6_Q,
    output wire [DATA_WIDTH-1:0]  R7_Q,
    output wire [DATA_WIDTH-1:0]  R8_Q,
    output wire [DATA_WIDTH-1:0]  R9_Q,
    output wire [DATA_WIDTH-1:0]  R10_Q,
    output wire [DATA_WIDTH-1:0]  R11_Q,
    output wire [DATA_WIDTH-1:0]  R12_Q,
    output wire [DATA_WIDTH-1:0]  R13_Q,
    output wire [DATA_WIDTH-1:0]  R14_Q,
    output wire [DATA_WIDTH-1:0]  R15_Q
);

    // Bus control vector
    wire [23:0] bus_control;
    assign bus_control[15:0] = Rout;
    assign bus_control[16]   = HIout;
    assign bus_control[17]   = LOout;
    assign bus_control[18]   = Zhighout;
    assign bus_control[19]   = Zlowout;
    assign bus_control[20]   = PCout;
    assign bus_control[21]   = MDRout;
    assign bus_control[22]   = InPortout;
    assign bus_control[23]   = Cout;

    // Standard registers (D is BusMuxOut (input to register), Q feeds bus inputs (output from register))
    register PC_REG (
        .BUS_MUX_IN (PC_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (PCin)
    );

    register IR_REG (
        .BUS_MUX_IN (IR_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (IRin)
    );

    register HI_REG (
        .BUS_MUX_IN (HI_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (HIin)
    );

    register LO_REG (
        .BUS_MUX_IN (LO_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (LOin)
    );

    register Z_LO_REG (
        .BUS_MUX_IN (Z_LO_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (Zin)
    );

    register Z_HI_REG (
        .BUS_MUX_IN (Z_HI_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (Zin)
    );

    register INPORT_REG (
        .BUS_MUX_IN (InPort_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (InPortin)
    );

    register C_REG (
        .BUS_MUX_IN (C_Q),
        .BUS_MUX_OUT(BusMuxOut),
        .clear      (clear),
        .clock      (clock),
        .enable     (Cin)
    );

    // MDR wiring (uses Read/Mdatain/BusMuxOut)
    wire [DATA_WIDTH-1:0] BusMuxIn_MDR;

    mdr MDR_REG (
        .clk          (clock),
        .clr          (clear),
        .MDRin        (MDRin),
        .Read         (Read),
        .Mdatain      (Mdatain),
        .BusMuxOut    (BusMuxOut),
        .MDR_q        (MDR_Q),
        .BusMuxIn_MDR (BusMuxIn_MDR)
    );

    // General purpose registers R0 to R15
    register R0_REG  (.BUS_MUX_IN(R0_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[0]));
    register R1_REG  (.BUS_MUX_IN(R1_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[1]));
    register R2_REG  (.BUS_MUX_IN(R2_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[2]));
    register R3_REG  (.BUS_MUX_IN(R3_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[3]));
    register R4_REG  (.BUS_MUX_IN(R4_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[4]));
    register R5_REG  (.BUS_MUX_IN(R5_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[5]));
    register R6_REG  (.BUS_MUX_IN(R6_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[6]));
    register R7_REG  (.BUS_MUX_IN(R7_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[7]));
    register R8_REG  (.BUS_MUX_IN(R8_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[8]));
    register R9_REG  (.BUS_MUX_IN(R9_Q),  .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[9]));
    register R10_REG (.BUS_MUX_IN(R10_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[10]));
    register R11_REG (.BUS_MUX_IN(R11_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[11]));
    register R12_REG (.BUS_MUX_IN(R12_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[12]));
    register R13_REG (.BUS_MUX_IN(R13_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[13]));
    register R14_REG (.BUS_MUX_IN(R14_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[14]));
    register R15_REG (.BUS_MUX_IN(R15_Q), .BUS_MUX_OUT(BusMuxOut), .clear(clear), .clock(clock), .enable(Rin[15]));

    // Bus mux selects which Q drives BusMuxOut
    bus BusMux (
        .BusOut   (BusMuxOut),
        .control  (bus_control),

        .BusIn0   (R0_Q),
        .BusIn1   (R1_Q),
        .BusIn2   (R2_Q),
        .BusIn3   (R3_Q),
        .BusIn4   (R4_Q),
        .BusIn5   (R5_Q),
        .BusIn6   (R6_Q),
        .BusIn7   (R7_Q),
        .BusIn8   (R8_Q),
        .BusIn9   (R9_Q),
        .BusIn10  (R10_Q),
        .BusIn11  (R11_Q),
        .BusIn12  (R12_Q),
        .BusIn13  (R13_Q),
        .BusIn14  (R14_Q),
        .BusIn15  (R15_Q),
        .BusIn16  (HI_Q),
        .BusIn17  (LO_Q),
        .BusIn18  (Z_HI_Q),
        .BusIn19  (Z_LO_Q),
        .BusIn20  (PC_Q),
        .BusIn21  (BusMuxIn_MDR),
        .BusIn22  (InPort_Q),
        .BusIn23  (C_Q)
    );

endmodule