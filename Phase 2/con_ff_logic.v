module con_ff_logic (
    input wire clk,
    input wire clear,
    input wire CONin,
    input wire [3:0] IR_c2,
    input wire [31:0] bus_data,
    output reg CON_FF
);

    reg con_result;

    always @(*) begin
        case (IR_c2[1:0])
            2'b00: con_result = (bus_data == 32'b0); // =
            2'b01: con_result = (bus_data != 32'b0); // !=
            2'b10: con_result = (~bus_data[31]); // >= 0
            2'b11: con_result = (bus_data[31]); // < 0
            default: con_result = 1'b0;
        endcase
    end

    always @(posedge clk or posedge clear) begin
        if (clear)
            CON_FF <= 1'b0;
        else if (CONin)
            CON_FF <= con_result;
    end

endmodule