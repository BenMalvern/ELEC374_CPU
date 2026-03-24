module out_port (
    input wire clk,
    input wire clear,
    input wire OutPortin,
    input wire [31:0] BusMuxOut,
    output reg [31:0] OutPort_Q
);

    always @(posedge clk or posedge clear) begin
        if (clear)
            OutPort_Q <= 32'b0;
        else if (OutPortin)
            OutPort_Q <= BusMuxOut;
    end

endmodule