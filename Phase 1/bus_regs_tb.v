`timescale 1ns/1ps

module bus_regs_tb;

    reg clock;
    reg clear;

    reg R0_enable;
    reg R1_enable;

    reg R0out;
    reg R1out;

    wire [23:0] control;
    wire [31:0] BusOut;

    wire [31:0] R0_bus_in;
    wire [31:0] R1_bus_in;

    always #5 clock = ~clock;

    assign control = {
        22'b0,
        R1out,
        R0out
    };

	// Instantiate registers
    register R0 (
        .BUS_MUX_IN(R0_bus_in),
        .BUS_MUX_OUT(BusOut),
        .clear(clear),
        .clock(clock),
        .enable(R0_enable)
    );

    register R1 (
        .BUS_MUX_IN(R1_bus_in),
        .BUS_MUX_OUT(BusOut),
        .clear(clear),
        .clock(clock),
        .enable(R1_enable)
    );

    // Instantiate bus
    bus BUS0 (
		.BusOut(BusOut),
        .control(control),
        .BusIn0(R0_bus_in),
        .BusIn1(R1_bus_in),
        .BusIn2(32'b0),
        .BusIn3(32'b0),
        .BusIn4(32'b0),
        .BusIn5(32'b0),
        .BusIn6(32'b0),
        .BusIn7(32'b0),
        .BusIn8(32'b0),
        .BusIn9(32'b0),
        .BusIn10(32'b0),
        .BusIn11(32'b0),
        .BusIn12(32'b0),
        .BusIn13(32'b0),
        .BusIn14(32'b0),
        .BusIn15(32'b0),
        .BusIn16(32'b0),
        .BusIn17(32'b0),
        .BusIn18(32'b0),
        .BusIn19(32'b0),
        .BusIn20(32'b0),
        .BusIn21(32'b0),
        .BusIn22(32'b0),
        .BusIn23(32'b0)
    );

    // Test sequence
    initial begin
        clock = 0;
        clear = 1;

        R0_enable = 0;
        R1_enable = 0;

        R0out = 0;
        R1out = 0;

        #10;
        clear = 0;

        // Step 1: Load value into R0

        // Temporarily force bus to inject value
        force BusOut = 32'hFEEDBEEF;

        R0_enable = 1;
        #10;
        R0_enable = 0;

        release BusOut;

        // Step 2: Transfer R0 to bus to R1

        R0out = 1;      // Put R0 on bus
        #5;

        R1_enable = 1;  // Load R1 from bus
        #10;

        R1_enable = 0;
        R0out = 0;

        #20;

        $stop;
    end

endmodule