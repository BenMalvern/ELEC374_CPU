`timescale 1ns/10ps

module encoder_tb();

    wire [4:0]  Code;
    reg  [31:0] Data;
	
    pe_32_5 dut (
        .Data(Data),
        .Code(Code)
    );

    initial begin
        // Monitor changes
        $monitor("T=%0t | Data=%h | Code=%d", $time, Data, Code);

        // Single bit tests
        Data = 32'h00000001; 	   // expect 0
        #10 Data = 32'h00000002; // expect 1
        #10 Data = 32'h00000004; // expect 2
        #10 Data = 32'h00000008; // expect 3
        #10 Data = 32'h00000010; // expect 4

        #10 Data = 32'h00000100; // expect 8
        #10 Data = 32'h00010000; // expect 16
        #10 Data = 32'h00100000; // expect 20
        #10 Data = 32'h01000000; // expect 24
        #10 Data = 32'h80000000; // expect 31

        // Priority tests
        #10 Data = 32'h00000003; // expect 1
        #10 Data = 32'h0000000F; // expect 3
        #10 Data = 32'h00000105; // expect 8
        #10 Data = 32'h00400021; // expect 22
        #10 Data = 32'hC0000001; // expect 31

        // Extra tests
        #10 Data = 32'h00000000; // expect X
        #10 Data = 32'hFFFFFFFF; // expect 31

        #10;
        $finish;
    end
	
endmodule
