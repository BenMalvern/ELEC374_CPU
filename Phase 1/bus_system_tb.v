`timescale 1ns/10ps

module bus_system_tb;

    reg [31:0] control;
    reg [31:0] inputs [31:0];
    wire [31:0] BusOut;

    integer i;

    bus_system DUT (
        control,
        inputs[0], inputs[1], inputs[2], inputs[3],
        inputs[4], inputs[5], inputs[6], inputs[7],
        inputs[8], inputs[9], inputs[10], inputs[11],
        inputs[12], inputs[13], inputs[14], inputs[15],
        inputs[16], inputs[17], inputs[18], inputs[19],
        inputs[20], inputs[21], inputs[22], inputs[23],
        BusOut
    );

    initial begin

        // Give each input a unique value
        for (i = 0; i < 24; i = i + 1)
            inputs[i] = i;

        // Test each encoding control
        for (i = 0; i < 24; i = i + 1) begin
            control = 32'b0;
            control[i] = 1;   // flip next bit
            #10;

            if (BusOut !== inputs[i])
                $display("ERROR at index %d", i);
            else
                $display("PASS at index %d | Output = %h", i, BusOut);
        end

        $stop;
    end

endmodule