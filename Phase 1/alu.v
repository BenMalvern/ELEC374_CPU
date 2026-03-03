module alu(
    input  [31:0] A,
    input  [31:0] B,
    input         ADD,
    input         SUB,
    input         AND_op,
    input         OR_op,
    input         SHL_op,
    input         SHR_op,
    input         MUL_op,
    output reg [63:0] result
);


always @(*) begin
    result = 64'b0;

    if (ADD)
        result = A + B;
    else if (SUB)
        result = A - B;
    else if (AND_op)
        result = {32'b0, A & B};
    else if (OR_op)
        result = {32'b0, A | B};
    else if (SHL_op)
        result = {32'b0, A << B[4:0]};
    else if (SHR_op)
        result = {32'b0, A >> B[4:0]};
    else if (MUL_op)
        result = A * B;
end