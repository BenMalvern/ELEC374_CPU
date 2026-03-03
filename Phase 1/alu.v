module alu (
    input  wire [31:0] A,   // Set to Y
    input  wire [31:0] B,   // set to BusMuxOut
    input  wire        ADD,
    input  wire        SUB,
    input  wire        AND_op,
    input  wire        OR_op,
    input  wire        SHR_op,
    input  wire        SHRA_op,
    input  wire        SHL_op,
    input  wire        ROR_op,
    input  wire        ROL_op,
    input  wire        NEG_op,
    input  wire        NOT_op,
    input  wire        MUL_op,
    input  wire        DIV_op,
    output reg  [63:0] result
);

    // ADD/SUB with CLA
    wire [31:0] addsub_out;
    cla #(32) U_CLA (
        .Z  (addsub_out),
        .A  (A),
        .Bin(B),
        .sub(SUB)        // ADD: SUB=0, SUB: SUB=1
    );

    // AND/OR/NOT bitwise ops
    wire [31:0] and_out = A & B;
    wire [31:0] or_out  = A | B;
    wire [31:0] not_out = ~B;      // unary uses B

    // NEG via CLA: 0 - B
    wire [31:0] neg_out;
    cla #(32) U_NEG (
        .Z  (neg_out),
        .A  (32'b0),
        .Bin(B),
        .sub(1'b1)
    );

    // Shifts/rotates
    wire [31:0] shr_out, shra_out, shl_out, ror_out, rol_out;

    SHR  #(32) U_SHR  (.Z(shr_out),  .A(A), .shiftAmount(B[4:0]));
    SHRA #(32) U_SHRA (.Z(shra_out), .A(A), .shiftAmount(B[4:0]));
    SHL  #(32) U_SHL  (.Z(shl_out),  .A(A), .shiftAmount(B[4:0]));
    ROR  #(32) U_ROR  (.Z(ror_out),  .A(A), .shiftAmount(B[4:0]));
    ROL  #(32) U_ROL  (.Z(rol_out),  .A(A), .shiftAmount(B[4:0]));

    // MUL/DIV
    wire signed [31:0] mul_lo, mul_hi;
    alu_mul U_MUL (.LO(mul_lo), .HI(mul_hi), .A(A), .B(B));

    wire signed [31:0] div_lo, div_hi;
    alu_div U_DIV (.LO(div_lo), .HI(div_hi), .Q(A), .M(B));

    always @(*) begin
        result = 64'b0;

        if (ADD || SUB)             result = {32'b0, addsub_out};
        else if (AND_op)            result = {32'b0, and_out};
        else if (OR_op)             result = {32'b0, or_out};
        else if (NOT_op)            result = {32'b0, not_out};
        else if (NEG_op)            result = {32'b0, neg_out};
        else if (SHR_op)            result = {32'b0, shr_out};
        else if (SHRA_op)           result = {32'b0, shra_out};
        else if (SHL_op)            result = {32'b0, shl_out};
        else if (ROR_op)            result = {32'b0, ror_out};
        else if (ROL_op)            result = {32'b0, rol_out};
        else if (MUL_op)            result = {mul_hi, mul_lo};
        else if (DIV_op)            result = {div_hi, div_lo}; // HI=remainder, LO=quotient
    end

endmodule