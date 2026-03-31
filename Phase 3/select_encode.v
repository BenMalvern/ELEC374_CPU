module select_encode (
    input  wire [31:0] IR,
	
    input wire GraA,
    input wire GrbA,
    input wire GrcA,

    input wire GraB,
    input wire GrbB,
    input wire GrcB,

    input wire GraC,
    input wire GrbC,
    input wire GrcC,

    input wire GraIn,
    input wire GrbIn,
    input wire GrcIn,

    input wire Rin,
    input  wire RoutA,
	input  wire RoutB,
	input  wire RoutC,
    input  wire BAout,

    output wire [15:0] Rin_sel, // Destination register write enables
    output wire [15:0] RoutA_sel, // Register output enables for A bus
    output wire [15:0] RoutB_sel, // Register output enables for B bus
	output wire [15:0] RoutC_sel, // Register output enables for C bus
    output wire [31:0] C_sign_extended
);

    // Register fields from IR
    wire [3:0] Ra, Rb, Rc;
    assign Ra = IR[26:23];
    assign Rb = IR[22:19];
    assign Rc = IR[18:15];

    // Individual decoded versions of each field
    wire [15:0] decRa, decRb, decRc;
    assign decRa = 16'b1 << Ra;
    assign decRb = 16'b1 << Rb;
    assign decRc = 16'b1 << Rc;

    // Destination register select
    // Whichever of Gra/Grb/Grc is asserted chooses the write destination
    assign Rin_sel = Rin ?
        (({16{GraIn}} & decRa) |
         ({16{GrbIn}} & decRb) |
         ({16{GrcIn}} & decRc)) : 16'b0;

    // A bus source register select
    // Usually Gra selects the register for A bus
    assign RoutA_sel = RoutA ?
        (({16{GraA}} & decRa) |
         ({16{GrbA}} & decRb) |
         ({16{GrcA}} & decRc)) : 16'b0;

    // B bus source register select
    // Usually Grb selects the register for B bus
    assign RoutB_sel = (RoutB | BAout) ?
        (({16{GraB}} & decRa) |
         ({16{GrbB}} & decRb) |
         ({16{GrcB}} & decRc)) : 16'b0;
	
	// C bus source register select
    assign RoutB_sel = (RoutB | BAout) ?
        (({16{GraB}} & decRa) |
         ({16{GrbB}} & decRb) |
         ({16{GrcB}} & decRc)) : 16'b0;
		 
    // Sign-extended constant from IR[18:0]
    assign C_sign_extended = {{13{IR[18]}}, IR[18:0]};

endmodule