`timescale 1ns/10ps

module alu_div_tb;

    reg signed [31:0] Q, M;
    wire signed [31:0] LO, HI;

    // Instantiate the ALU divider
    alu_div uut (
        .LO(LO),
        .HI(HI),
        .Q(Q),
        .M(M)
    );

    initial begin
        // Test 1: Positive / Positive
        Q = 32'd15; M = 32'd4; // 3 R3
        #10;

        // Test 2: Negative dividend / Positive divisor
        Q = -32'd15; M = 32'd4; // -3 R(-3)
        #10;

        // Test 3: Positive dividend / Negative divisor
        Q = 32'd15; M = -32'd4; // -3 R3
        #10;

        // Test 4: Negative / Negative
        Q = -32'd15; M = -32'd4; // 3 R(-3)
        #10;

        // Test 5: Dividend smaller than divisor
        Q = 32'd3; M = 32'd10; // 0 R3
        #10;

        // Test 6: Dividend = 0
        Q = 32'd0; M = 32'd7; // 0 R0
        #10;

        // Test 7: Divisor = 0 (should give 0 for both)
        Q = 32'd20; M = 32'd0; // 0 R0
        #10;

        // Test 8: Large numbers
        Q = 32'd123456789; M = 32'd12345; // 10000 R6789
        #10;

        $stop;
    end

endmodule