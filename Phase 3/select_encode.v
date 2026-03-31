module select_encode (
    input  wire [31:0] IR,

    input  wire GraA,
    input  wire GrbA,
    input  wire GrcA,

    input  wire GraB,
    input  wire GrbB,
    input  wire GrcB,

    input  wire GraC,
    input  wire GrbC,
    input  wire GrcC,

    input  wire GraIn,
    input  wire GrbIn,
    input  wire GrcIn,

    input  wire Rin,
    input  wire R12in,
    input  wire RoutA,
    input  wire RoutB,
    input  wire RoutC,
    input  wire BAout,

    output wire [15:0] Rin_sel,
    output wire [15:0] RoutA_sel,
    output wire [15:0] RoutB_sel,
    output wire [15:0] RoutC_sel,
    output wire [31:0] C_sign_extended
);

    wire [3:0] Ra;
    wire [3:0] Rb;
    wire [3:0] Rc;

    assign Ra = IR[26:23];
    assign Rb = IR[22:19];
    assign Rc = IR[18:15];

    wire [15:0] decRa;
    wire [15:0] decRb;
    wire [15:0] decRc;

    assign decRa = 16'b1 << Ra;
    assign decRb = 16'b1 << Rb;
    assign decRc = 16'b1 << Rc;

    assign Rin_sel = ((Rin ?
        (({16{GraIn}} & decRa) |
         ({16{GrbIn}} & decRb) |
         ({16{GrcIn}} & decRc)) : 16'b0)
        | (R12in ? 16'h1000 : 16'h0000));

    assign RoutA_sel = RoutA ?
        (({16{GraA}} & decRa) |
         ({16{GrbA}} & decRb) |
         ({16{GrcA}} & decRc)) : 16'b0;

    // BAout uses the same register select path as RoutB.
    // The datapath can decide whether the selected register value or zero should appear.
    assign RoutB_sel = (RoutB | BAout) ?
        (({16{GraB}} & decRa) |
         ({16{GrbB}} & decRb) |
         ({16{GrcB}} & decRc)) : 16'b0;

    assign RoutC_sel = RoutC ?
        (({16{GraC}} & decRa) |
         ({16{GrbC}} & decRb) |
         ({16{GrcC}} & decRc)) : 16'b0;

    assign C_sign_extended = {{13{IR[18]}}, IR[18:0]};

endmodule
