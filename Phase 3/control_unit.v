`timescale 1ns/10ps

module control_unit (
    input wire Clock,
    input wire Reset,
    input wire Stop,
    input wire CON_FF,
    input wire [31:0] IR,

    output reg Run,
    output reg Clear,

    // Select / encode signals
    output reg GraA,
	output reg GrbA,
	output reg GrcA,
	output reg GraB,
	output reg GrbB,
	output reg GrcB,
	output reg GraC,
	output reg GrbC,
	output reg GrcC,
	output reg GraIn,
	output reg GrbIn,
	output reg GrcIn,
    output reg Rin,
    output reg RoutA,
    output reg RoutB,
    output reg RoutC,
    output reg BAout,

    // Datapath register control
    output reg PCin,
    output reg IRin,
    output reg MARin,
    output reg MDRin,
    output reg Zin,
    output reg HIin,
    output reg LOin,
    output reg Cin,

    // Memory control
    output reg Read,
    output reg Write,

    // Special control
    output reg IncPC,
    output reg CONin,

    // ALU control
    output reg ADD,
    output reg SUB,
    output reg AND_op,
    output reg OR_op,
    output reg SHR_op,
    output reg SHRA_op,
    output reg SHL_op,
    output reg ROR_op,
    output reg ROL_op,
    output reg NEG_op,
    output reg NOT_op,
    output reg MUL_op,
    output reg DIV_op,

    // A bus drivers
    output reg PCoutA,
    output reg HIoutA,
    output reg LOoutA,
    output reg ZhighoutA,
    output reg ZlowoutA,
    output reg MDRoutA,
    output reg InPortoutA,
    output reg CoutA,

    // B bus drivers
    output reg PCoutB,
    output reg HIoutB,
    output reg LOoutB,
    output reg ZhighoutB,
    output reg ZlowoutB,
    output reg MDRoutB,
    output reg InPortoutB,
    output reg CoutB,

    // C bus drivers
    output reg PCoutC,
    output reg HIoutC,
    output reg LOoutC,
    output reg ZhighoutC,
    output reg ZlowoutC,
    output reg MDRoutC,
    output reg InPortoutC, 
    output reg CoutC
);

    // opcode definitions
    parameter OP_ADD = 5'b00000, OP_SUB = 5'b00001, OP_AND = 5'b00010,
              OP_OR = 5'b00011, OP_JR = 5'b10010, OP_JAL = 5'b10011,
              OP_HALT = 5'b11111;

    // State definitions
    parameter reset_state = 6'd0, fetch0 = 6'd1, fetch1 = 6'd2, fetch2 = 6'd3,
              add3 = 6'd4, add4 = 6'd5,
              halt_state = 6'd63;

    reg [5:0] present_state, next_state;

    // State register
    always @(posedge Clock or posedge Reset) begin
        if (Reset)
            present_state <= reset_state;
        else
            present_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = present_state;

        if (Stop) begin
            next_state = halt_state;
        end
        else begin
            case (present_state)
                reset_state: next_state = fetch0;
                fetch0: next_state = fetch1;
                fetch1: next_state = fetch2;

                fetch2: begin
                    case (IR[31:27])
                        OP_ADD: next_state = add3;
                        OP_HALT: next_state = halt_state;
                        default: next_state = fetch0;
                    endcase
                end

                add3: next_state = add4;
                add4: next_state = fetch0;

                halt_state: next_state = halt_state;

                default: next_state = fetch0;
            endcase
        end
    end

    // Output logic
    always @(*) begin
        // Default all outputs low
        Run = 1'b1; Clear = 1'b0;

		GraA = 1'b0; GrbA = 1'b0; GrcA = 1'b0; GraB = 1'b0;
		GrbB = 1'b0; GrcB = 1'b0; GraC = 1'b0; GrbC = 1'b0;
		GrcC = 1'b0; GraIn = 1'b0; GrbIn = 1'b0; GrcIn = 1'b0;
		Rin = 1'b0; RoutA = 1'b0; RoutB = 1'b0; RoutC = 1'b0;
		BAout = 1'b0;

		PCin = 1'b0; IRin = 1'b0; MARin = 1'b0; MDRin = 1'b0;
		Zin = 1'b0; HIin = 1'b0; LOin = 1'b0; Cin = 1'b0;

		Read = 1'b0; Write = 1'b0; IncPC = 1'b0; CONin = 1'b0;

		ADD = 1'b0; SUB = 1'b0; AND_op = 1'b0; OR_op = 1'b0;
		SHR_op = 1'b0; SHRA_op = 1'b0; SHL_op = 1'b0; ROR_op = 1'b0;
		ROL_op = 1'b0; NEG_op = 1'b0; NOT_op = 1'b0; MUL_op = 1'b0;
		DIV_op = 1'b0;

		PCoutA = 1'b0; HIoutA = 1'b0; LOoutA = 1'b0; ZhighoutA = 1'b0;
		ZlowoutA = 1'b0; MDRoutA = 1'b0; InPortoutA = 1'b0; CoutA = 1'b0;

		PCoutB = 1'b0; HIoutB = 1'b0; LOoutB = 1'b0; ZhighoutB = 1'b0;
		ZlowoutB = 1'b0; MDRoutB = 1'b0; InPortoutB = 1'b0; CoutB = 1'b0;

		PCoutC = 1'b0; HIoutC = 1'b0; LOoutC = 1'b0; ZhighoutC = 1'b0;
		ZlowoutC = 1'b0; MDRoutC = 1'b0; InPortoutC = 1'b0; CoutC = 1'b0;

        case (present_state)
            reset_state: begin
                Clear = 1'b1;
                Run = 1'b1;
            end

            fetch0: begin
                PCoutC = 1'b1;
                MARin = 1'b1;
                IncPC = 1'b1;
                Zin = 1'b1;
            end

            fetch1: begin
                ZlowoutC = 1'b1;
                PCin = 1'b1;
                Read = 1'b1;
                MDRin = 1'b1;
            end

            fetch2: begin
                MDRoutC = 1'b1;
                IRin = 1'b1;
            end

            add3: begin
                GrbA = 1'b1;
                RoutA = 1'b1; // Rb on A bus
                GrcB = 1'b1;
                RoutB = 1'b1; // Rc on B bus
                ADD = 1'b1;
                Zin = 1'b1; // ALU result in Z
            end

            add4: begin
                ZlowoutC = 1'b1;
                GraIn = 1'b1;
                Rin = 1'b1; // Write result to Ra
            end

            halt_state: begin
                Run = 1'b0;
            end
        endcase
    end

endmodule