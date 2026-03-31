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
    output reg R12in,
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

    // Memory / I/O control
    output reg Read,
    output reg Write,
    output reg OutPortin,

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

    localparam [4:0]
        OP_ADD   = 5'b00000,
        OP_SUB   = 5'b00001,
        OP_AND   = 5'b00010,
        OP_OR    = 5'b00011,
        OP_SHR   = 5'b00100,
        OP_SHRA  = 5'b00101,
        OP_SHL   = 5'b00110,
        OP_ROR   = 5'b00111,
        OP_ROL   = 5'b01000,
        OP_ADDI  = 5'b01001,
        OP_ANDI  = 5'b01010,
        OP_ORI   = 5'b01011,
        OP_DIV   = 5'b01100,
        OP_MUL   = 5'b01101,
        OP_NEG   = 5'b01110,
        OP_NOT   = 5'b01111,
        OP_LD    = 5'b10000,
        OP_LDI   = 5'b10001,
        OP_ST    = 5'b10010,
        OP_JAL   = 5'b10011,
        OP_JR    = 5'b10100,
        OP_BR    = 5'b10101,
        OP_IN    = 5'b10110,
        OP_OUT   = 5'b10111,
        OP_MFHI  = 5'b11000,
        OP_MFLO  = 5'b11001,
        OP_NOP   = 5'b11010,
        OP_HALT  = 5'b11011;

    localparam [6:0]
        S_RESET   = 7'd0,
        S_FETCH0  = 7'd1,
        S_FETCH1  = 7'd2,
        S_FETCH2  = 7'd3,
        S_DECODE  = 7'd4,

        S_RR3     = 7'd5,
        S_RR4     = 7'd6,

        S_IMM3    = 7'd7,
        S_IMM4    = 7'd8,

        S_UN3     = 7'd9,
        S_UN4     = 7'd10,

        S_LD3     = 7'd11,
        S_LD4     = 7'd12,
        S_LD5     = 7'd13,
        S_LD6     = 7'd14,

        S_ST3     = 7'd15,
        S_ST4     = 7'd16,
        S_ST5     = 7'd17,
        S_ST6     = 7'd18,

        S_BRANCH3 = 7'd19,
        S_BRANCH4 = 7'd20,
        S_BRANCH5 = 7'd21,

        S_JR3     = 7'd22,

        S_JAL3    = 7'd23,
        S_JAL4    = 7'd24,

        S_MUL3    = 7'd25,
        S_MUL4    = 7'd26,
        S_MUL5    = 7'd27,

        S_DIV3    = 7'd28,
        S_DIV4    = 7'd29,
        S_DIV5    = 7'd30,

        S_MFHI3   = 7'd31,
        S_MFLO3   = 7'd32,

        S_IN3     = 7'd33,
        S_OUT3    = 7'd34,

        S_HALT    = 7'd63;

    reg [6:0] present_state, next_state;
    wire [4:0] opcode = IR[31:27];

    always @(posedge Clock or posedge Reset) begin
        if (Reset)
            present_state <= S_RESET;
        else
            present_state <= next_state;
    end

    always @(*) begin
        next_state = present_state;

        if (Stop) begin
            next_state = S_HALT;
        end else begin
            case (present_state)
                S_RESET:   next_state = S_FETCH0;
                S_FETCH0:  next_state = S_FETCH1;
                S_FETCH1:  next_state = S_FETCH2;
                S_FETCH2:  next_state = S_DECODE;

                S_DECODE: begin
                    case (opcode)
                        OP_ADD, OP_SUB, OP_AND, OP_OR, OP_SHR, OP_SHRA, OP_SHL, OP_ROR, OP_ROL:
                            next_state = S_RR3;

                        OP_ADDI, OP_ANDI, OP_ORI, OP_LDI:
                            next_state = S_IMM3;

                        OP_NEG, OP_NOT:
                            next_state = S_UN3;

                        OP_LD:
                            next_state = S_LD3;

                        OP_ST:
                            next_state = S_ST3;

                        OP_BR:
                            next_state = S_BRANCH3;

                        OP_JR:
                            next_state = S_JR3;

                        OP_JAL:
                            next_state = S_JAL3;

                        OP_MUL:
                            next_state = S_MUL3;

                        OP_DIV:
                            next_state = S_DIV3;

                        OP_MFHI:
                            next_state = S_MFHI3;

                        OP_MFLO:
                            next_state = S_MFLO3;

                        OP_IN:
                            next_state = S_IN3;

                        OP_OUT:
                            next_state = S_OUT3;

                        OP_NOP:
                            next_state = S_FETCH0;

                        OP_HALT:
                            next_state = S_HALT;

                        default:
                            next_state = S_FETCH0;
                    endcase
                end

                S_RR3:     next_state = S_RR4;
                S_RR4:     next_state = S_FETCH0;

                S_IMM3:    next_state = S_IMM4;
                S_IMM4:    next_state = S_FETCH0;

                S_UN3:     next_state = S_UN4;
                S_UN4:     next_state = S_FETCH0;

                S_LD3:     next_state = S_LD4;
                S_LD4:     next_state = S_LD5;
                S_LD5:     next_state = S_LD6;
                S_LD6:     next_state = S_FETCH0;

                S_ST3:     next_state = S_ST4;
                S_ST4:     next_state = S_ST5;
                S_ST5:     next_state = S_ST6;
                S_ST6:     next_state = S_FETCH0;

                S_BRANCH3: next_state = S_BRANCH4;
                S_BRANCH4: next_state = S_BRANCH5;
                S_BRANCH5: next_state = S_FETCH0;

                S_JR3:     next_state = S_FETCH0;

                S_JAL3:    next_state = S_JAL4;
                S_JAL4:    next_state = S_FETCH0;

                S_MUL3:    next_state = S_MUL4;
                S_MUL4:    next_state = S_MUL5;
                S_MUL5:    next_state = S_FETCH0;

                S_DIV3:    next_state = S_DIV4;
                S_DIV4:    next_state = S_DIV5;
                S_DIV5:    next_state = S_FETCH0;

                S_MFHI3:   next_state = S_FETCH0;
                S_MFLO3:   next_state = S_FETCH0;

                S_IN3:     next_state = S_FETCH0;
                S_OUT3:    next_state = S_FETCH0;

                S_HALT:    next_state = S_HALT;

                default:   next_state = S_FETCH0;
            endcase
        end
    end

    always @(*) begin
        Run   = 1'b1;
        Clear = 1'b0;

        GraA = 1'b0; GrbA = 1'b0; GrcA = 1'b0;
        GraB = 1'b0; GrbB = 1'b0; GrcB = 1'b0;
        GraC = 1'b0; GrbC = 1'b0; GrcC = 1'b0;
        GraIn = 1'b0; GrbIn = 1'b0; GrcIn = 1'b0;
        Rin = 1'b0; R12in = 1'b0;
        RoutA = 1'b0; RoutB = 1'b0; RoutC = 1'b0; BAout = 1'b0;

        PCin = 1'b0; IRin = 1'b0; MARin = 1'b0; MDRin = 1'b0; Zin = 1'b0;
        HIin = 1'b0; LOin = 1'b0; Cin = 1'b0;

        Read = 1'b0; Write = 1'b0; OutPortin = 1'b0;
        IncPC = 1'b0; CONin = 1'b0;

        ADD = 1'b0; SUB = 1'b0; AND_op = 1'b0; OR_op = 1'b0;
        SHR_op = 1'b0; SHRA_op = 1'b0; SHL_op = 1'b0; ROR_op = 1'b0; ROL_op = 1'b0;
        NEG_op = 1'b0; NOT_op = 1'b0; MUL_op = 1'b0; DIV_op = 1'b0;

        PCoutA = 1'b0; HIoutA = 1'b0; LOoutA = 1'b0; ZhighoutA = 1'b0;
        ZlowoutA = 1'b0; MDRoutA = 1'b0; InPortoutA = 1'b0; CoutA = 1'b0;

        PCoutB = 1'b0; HIoutB = 1'b0; LOoutB = 1'b0; ZhighoutB = 1'b0;
        ZlowoutB = 1'b0; MDRoutB = 1'b0; InPortoutB = 1'b0; CoutB = 1'b0;

        PCoutC = 1'b0; HIoutC = 1'b0; LOoutC = 1'b0; ZhighoutC = 1'b0;
        ZlowoutC = 1'b0; MDRoutC = 1'b0; InPortoutC = 1'b0; CoutC = 1'b0;

        case (present_state)
            S_RESET: begin
                Clear = 1'b1;
                Run   = 1'b1;
            end

            S_FETCH0: begin
                PCoutC = 1'b1;
                MARin  = 1'b1;
                IncPC  = 1'b1;
                Zin    = 1'b1;
            end

            S_FETCH1: begin
                ZlowoutC = 1'b1;
                PCin     = 1'b1;
                Read     = 1'b1;
                MDRin    = 1'b1;
            end

            S_FETCH2: begin
                MDRoutC = 1'b1;
                IRin    = 1'b1;
            end

            S_DECODE: begin
            end

            S_RR3: begin
                GrbA  = 1'b1;
                RoutA = 1'b1;
                GrcB  = 1'b1;
                RoutB = 1'b1;

                case (opcode)
                    OP_ADD:  ADD     = 1'b1;
                    OP_SUB:  SUB     = 1'b1;
                    OP_AND:  AND_op  = 1'b1;
                    OP_OR:   OR_op   = 1'b1;
                    OP_SHR:  SHR_op  = 1'b1;
                    OP_SHRA: SHRA_op = 1'b1;
                    OP_SHL:  SHL_op  = 1'b1;
                    OP_ROR:  ROR_op  = 1'b1;
                    OP_ROL:  ROL_op  = 1'b1;
                endcase

                Zin = 1'b1;
            end

            S_RR4: begin
                ZlowoutC = 1'b1;
                GraIn    = 1'b1;
                Rin      = 1'b1;
            end

            S_IMM3: begin
                CoutA = 1'b1;
                GrbB  = 1'b1;
                RoutB = 1'b1;
                BAout = 1'b1;

                case (opcode)
                    OP_LDI, OP_ADDI: ADD    = 1'b1;
                    OP_ANDI:         AND_op = 1'b1;
                    OP_ORI:          OR_op  = 1'b1;
                endcase

                Zin = 1'b1;
            end

            S_IMM4: begin
                ZlowoutC = 1'b1;
                GraIn    = 1'b1;
                Rin      = 1'b1;
            end

            S_UN3: begin
                GrbB  = 1'b1;
                RoutB = 1'b1;

                if (opcode == OP_NEG)
                    NEG_op = 1'b1;
                else
                    NOT_op = 1'b1;

                Zin = 1'b1;
            end

            S_UN4: begin
                ZlowoutC = 1'b1;
                GraIn    = 1'b1;
                Rin      = 1'b1;
            end

            S_LD3: begin
					 CoutA = 1'b1;
                GrbB  = 1'b1;
                RoutB = 1'b1;
					 BAout = 1'b1;
                ADD   = 1'b1;
                Zin   = 1'b1;
            end

            S_LD4: begin
                ZlowoutC = 1'b1;
                MARin    = 1'b1;
            end

            S_LD5: begin
                Read  = 1'b1;
                MDRin = 1'b1;
            end

            S_LD6: begin
                MDRoutC = 1'b1;
                GraIn   = 1'b1;
                Rin     = 1'b1;
            end

            S_ST3: begin
					 CoutA = 1'b1;
                GrbB  = 1'b1;
                RoutB = 1'b1;
					 BAout = 1'b1;
                ADD   = 1'b1;
                Zin   = 1'b1;
            end

            S_ST4: begin
                ZlowoutC = 1'b1;
                MARin    = 1'b1;
            end

            S_ST5: begin
                GraA  = 1'b1;
                RoutA = 1'b1;
                MDRin = 1'b1;
            end

            S_ST6: begin
                Write = 1'b1;
            end

            S_BRANCH3: begin
                GraA  = 1'b1;
                RoutA = 1'b1;
                CONin = 1'b1;
            end

            S_BRANCH4: begin
                PCoutA = 1'b1;
                CoutB  = 1'b1;
                ADD    = 1'b1;
                Zin    = 1'b1;
            end

            S_BRANCH5: begin
                if (CON_FF) begin
                    ZlowoutC = 1'b1;
                    PCin     = 1'b1;
                end
            end

            S_JR3: begin
                GraC  = 1'b1;
                RoutC = 1'b1;
                PCin  = 1'b1;
            end

            S_JAL3: begin
                PCoutC = 1'b1;
                R12in  = 1'b1;
            end

            S_JAL4: begin
                GraC  = 1'b1;
                RoutC = 1'b1;
                PCin  = 1'b1;
            end

            S_MUL3: begin
                GraA   = 1'b1;
                RoutA  = 1'b1;
                GrbB   = 1'b1;
                RoutB  = 1'b1;
                MUL_op = 1'b1;
                Zin    = 1'b1;
            end

            S_MUL4: begin
                ZhighoutC = 1'b1;
                HIin      = 1'b1;
            end

            S_MUL5: begin
                ZlowoutC = 1'b1;
                LOin     = 1'b1;
            end

            S_DIV3: begin
                GraA   = 1'b1;
                RoutA  = 1'b1;
                GrbB   = 1'b1;
                RoutB  = 1'b1;
                DIV_op = 1'b1;
                Zin    = 1'b1;
            end

            S_DIV4: begin
                ZhighoutC = 1'b1;
                HIin      = 1'b1;
            end

            S_DIV5: begin
                ZlowoutC = 1'b1;
                LOin     = 1'b1;
            end

            S_MFHI3: begin
                HIoutC = 1'b1;
                GraIn  = 1'b1;
                Rin    = 1'b1;
            end

            S_MFLO3: begin
                LOoutC = 1'b1;
                GraIn  = 1'b1;
                Rin    = 1'b1;
            end

            S_IN3: begin
                InPortoutC = 1'b1;
                GraIn      = 1'b1;
                Rin        = 1'b1;
            end

            S_OUT3: begin
                GraC      = 1'b1;
                RoutC     = 1'b1;
                OutPortin = 1'b1;
            end

            S_HALT: begin
                Run = 1'b0;
            end
        endcase
    end

endmodule
