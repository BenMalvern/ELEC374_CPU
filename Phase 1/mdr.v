module mdr(
    input  wire        clk,
    input  wire        clr,
    input  wire        MDRin,
    input  wire        Read,
    input  wire [31:0] Mdatain,
    input  wire [31:0] BusMuxOut,
    output reg  [31:0] MDR_q,
    output wire [31:0] BusMuxIn_MDR
);

always @(posedge clk or posedge clr) begin
    if (clr)
        MDR_q <= 32'b0;
    else if (MDRin) begin
        if (Read)
            MDR_q <= Mdatain;
        else
            MDR_q <= BusMuxOut;
    end
end

assign BusMuxIn_MDR = MDR_q;

endmodule
