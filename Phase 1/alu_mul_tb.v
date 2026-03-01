`timescale 1ns/1ps

module alu_mul_tb;

    reg signed [31:0] A, B;
    wire signed [31:0] LO, HI;

    alu_mul uut (
        .A(A),
        .B(B),
        .LO(LO),
        .HI(HI)
    );

    initial begin
        A = 0;
        B = 0;

        #10;
        // Test 1: 5 * 3
        A = 5;
        B = 3;
        #10;

        // Test 2: 5 * -2
        A = 5;
        B = -2;
        #10;

        // Test 3: -7 * 4
        A = -7;
        B = 4;
        #10;

        // Test 4: -6 * -3
        A = -6;
        B = -3;
        #10;

        // Test 5: multiplying by zero
        A = 0;
        B = 12345;
        #10;

        // Test 6: large numbers
        A = 32'h7FFFFFFF;  // max positive 32-bit
        B = 2;
        #10;

        $stop;
    end

endmodule