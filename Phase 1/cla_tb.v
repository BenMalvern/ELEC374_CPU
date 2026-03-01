`timescale 1ns/1ps

module cla_tb;

  localparam DATA_WIDTH = 32;

  reg  [DATA_WIDTH-1:0] A;
  reg  [DATA_WIDTH-1:0] B;
  wire [DATA_WIDTH-1:0] Z;

  // Instantiate DUT
  cla dut (Z, A, B);

  initial begin
    $monitor("t=%0t  A=%d  B=%d  Z=%d", $time, A, B, Z);

    A = 0;  B = 0;
    #10;

    A = 7;  B = 22;
    #10;

    A = 100;  B = 50;
    #10;

    A = 32'hFFFFFFFF;  B = 1;
    #10;
	 
	 A = 100;  B = -50;
    #10;
	 
	 A = 100;  B = -150;
    #10;

    $stop;
  end

endmodule