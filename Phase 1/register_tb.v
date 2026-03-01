`timescale 1ns/10ps

module register_tb;

  // -----------------------------
  // Parameters
  localparam DATA_WIDTH = 32;
  // -----------------------------


  // -----------------------------
  // Testbench Signals
  reg  clock;
  reg  clear;
  reg  enable;
  reg  [DATA_WIDTH-1:0] BUS_MUX_OUT;  // Input to register
  wire [DATA_WIDTH-1:0] BUS_MUX_IN;   // Output from register
  // -----------------------------


  // Instantiate DUT
  register #(
    .DATA_WIDTH(DATA_WIDTH),
    .INIT(32'd0)
  ) DUT (
    .BUS_MUX_IN(BUS_MUX_IN),
    .BUS_MUX_OUT(BUS_MUX_OUT),
    .clear(clear),
    .clock(clock),
    .enable(enable)
  );

  // Clock Generator (10ns period)
  initial begin
    clock = 0;
    forever #10 clock = ~clock;
  end

  // Stimulus
  initial begin

    $display("Register Test:");

    // Initialize inputs
    clear = 0;
    enable = 0;
    BUS_MUX_OUT = 0;


    // Test 1: Load value when enable = 1
    @(negedge clock);
    enable = 1;
    BUS_MUX_OUT = 32'd10;

    @(posedge clock); #1;
    if (BUS_MUX_IN !== 32'd10)
      $display("FAIL: Enable load failed");
    else
      $display("PASS: Enable load works");

    // Test 2: Load second value
    @(negedge clock);
    BUS_MUX_OUT = 32'd20;

    @(posedge clock); #1;
    if (BUS_MUX_IN !== 32'd20)
      $display("FAIL: Second load failed");
    else
      $display("PASS: Second load works");

    // Test 3: Hold when enable = 0
    @(negedge clock);
    enable = 0;
    BUS_MUX_OUT = 32'd30;

    @(posedge clock); #1;
    if (BUS_MUX_IN !== 32'd20)
      $display("FAIL: Register did not hold value");
    else
      $display("PASS: Hold works");

	 
    // Test 4: Clear
    @(negedge clock);
    clear = 1;

    @(posedge clock); #1;
    if (BUS_MUX_IN !== 0)
      $display("FAIL: Clear did not zero register");
    else
      $display("PASS: Clear works");

    clear = 0;
	 
	 
    $display("Register Test Complete.");
    $stop;

  end

endmodule