module in_port (
    input wire clk,
    input wire clear,
    input wire strobe,
    input wire [31:0] external_input,
    output reg [31:0] InPort_Q
);

    always @(posedge clk or posedge clear) begin
        if (clear)
            InPort_Q <= 32'b0;
        else if (strobe)
            InPort_Q <= external_input;
    end

endmodule