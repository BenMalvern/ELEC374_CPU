`timescale 1ns/10ps

module mux_32_1_tb;

    // Inputs
    reg [31:0] BusMuxIn_R0;
    reg [31:0] BusMuxIn_R1;
    reg [31:0] BusMuxIn_R2;
    reg [31:0] BusMuxIn_R3;
    reg [31:0] BusMuxIn_R4;
    reg [31:0] BusMuxIn_R5;
    reg [31:0] BusMuxIn_R6;
    reg [31:0] BusMuxIn_R7;
    reg [31:0] BusMuxIn_R8;
    reg [31:0] BusMuxIn_R9;
    reg [31:0] BusMuxIn_R10;
    reg [31:0] BusMuxIn_R11;
    reg [31:0] BusMuxIn_R12;
    reg [31:0] BusMuxIn_R13;
    reg [31:0] BusMuxIn_R14;
    reg [31:0] BusMuxIn_R15;

    reg [31:0] BusMuxIn_HI;
    reg [31:0] BusMuxIn_LO;
    reg [31:0] BusMuxIn_Z_high;
    reg [31:0] BusMuxIn_Z_low;
    reg [31:0] BusMuxIn_PC;
    reg [31:0] BusMuxIn_MDR;
    reg [31:0] BusMuxIn_InPort;
    reg [31:0] C_sign_extended;

    reg [4:0] select;

    wire [31:0] BusMuxOut;

    // Instantiate DUT
    mux_32_1 DUT (
        BusMuxIn_R0, BusMuxIn_R1, BusMuxIn_R2, BusMuxIn_R3,
        BusMuxIn_R4, BusMuxIn_R5, BusMuxIn_R6, BusMuxIn_R7,
        BusMuxIn_R8, BusMuxIn_R9, BusMuxIn_R10, BusMuxIn_R11,
        BusMuxIn_R12, BusMuxIn_R13, BusMuxIn_R14, BusMuxIn_R15,
        BusMuxIn_HI, BusMuxIn_LO,
        BusMuxIn_Z_high, BusMuxIn_Z_low,
        BusMuxIn_PC, BusMuxIn_MDR,
        BusMuxIn_InPort,
        C_sign_extended,
        BusMuxOut,
        select
    );
	
	integer i;
	
    initial begin
        // Test with unique values
        BusMuxIn_R0  = 32'h00000000;
        BusMuxIn_R1  = 32'h11111111;
        BusMuxIn_R2  = 32'h22222222;
        BusMuxIn_R3  = 32'h33333333;
        BusMuxIn_R4  = 32'h44444444;
        BusMuxIn_R5  = 32'h55555555;
        BusMuxIn_R6  = 32'h66666666;
        BusMuxIn_R7  = 32'h77777777;
        BusMuxIn_R8  = 32'h88888888;
        BusMuxIn_R9  = 32'h99999999;
        BusMuxIn_R10 = 32'hAAAAAAAA;
        BusMuxIn_R11 = 32'hBBBBBBBB;
        BusMuxIn_R12 = 32'hCCCCCCCC;
        BusMuxIn_R13 = 32'hDDDDDDDD;
        BusMuxIn_R14 = 32'hEEEEEEEE;
        BusMuxIn_R15 = 32'hFFFFFFFF;

        BusMuxIn_HI      = 32'h12345678;
        BusMuxIn_LO      = 32'h87654321;
        BusMuxIn_Z_high  = 32'hABCDEF01;
        BusMuxIn_Z_low   = 32'h10FEDCBA;
        BusMuxIn_PC      = 32'hCAFEBABE;
        BusMuxIn_MDR     = 32'hDEADBEEF;
        BusMuxIn_InPort  = 32'h13572468;
        C_sign_extended  = 32'h24681357;

        // Test all valid select values
        for (i = 0; i <= 23; i = i + 1) begin
            select = i;
            #10;   // wait 10ns
            $display("Select = %d | Output = %h", select, BusMuxOut);
        end

        $stop;
    end

endmodule