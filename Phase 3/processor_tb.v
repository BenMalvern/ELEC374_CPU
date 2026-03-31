`timescale 1ns/10ps

module processor_tb;

    reg clock;
    reg clear;
    reg [31:0] external_input;
    reg InPort_strobe;

    wire [31:0] out_port_data;
    wire stop;

    processor DUT (
        .clock(clock),
        .clear(clear),
        .external_input(external_input),
        .InPort_strobe(InPort_strobe),
        .out_port_data(out_port_data),
        .stop(stop)
    );

    task write_word;
        input [8:0] addr;
        input [31:0] data;
        integer base;
        begin
            base = addr << 2;
            DUT.DP.RAM.memory[base + 0] = data[7:0];
            DUT.DP.RAM.memory[base + 1] = data[15:8];
            DUT.DP.RAM.memory[base + 2] = data[23:16];
            DUT.DP.RAM.memory[base + 3] = data[31:24];
        end
    endtask

    function [31:0] read_word;
        input [8:0] addr;
        integer base;
        begin
            base = addr << 2;
            read_word = {
                DUT.DP.RAM.memory[base + 3],
                DUT.DP.RAM.memory[base + 2],
                DUT.DP.RAM.memory[base + 1],
                DUT.DP.RAM.memory[base + 0]
            };
        end
    endfunction

    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    initial begin : run_phase3
        integer i;

        clear = 1'b1;
        external_input = 32'd0;
        InPort_strobe = 1'b0;

        for (i = 0; i < 2048; i = i + 1)
            DUT.DP.RAM.memory[i] = 8'h00;

        write_word('h000, 32'h8A800043); // ldi   R5, 0x43
        write_word('h001, 32'h8AA80006); // ldi   R5, 6(R5)
        write_word('h002, 32'h82000089); // ld    R4, 0x89
        write_word('h003, 32'h8A200004); // ldi   R4, 4(R4)
        write_word('h004, 32'h8027FFF8); // ld    R0, -8(R4)
        write_word('h005, 32'h89000004); // ldi   R2, 4
        write_word('h006, 32'h8A800087); // ldi   R5, 0x87
        write_word('h007, 32'hAA980003); // brmi  R5, 3
        write_word('h008, 32'h8AA80005); // ldi   R5, 5(R5)
        write_word('h009, 32'h80AFFFFD); // ld    R1, -3(R5)
        write_word('h00A, 32'hD0000000); // nop
        write_word('h00B, 32'hA8900002); // brpl  R1, 2
        write_word('h00C, 32'h89A80007); // ldi   R3, 7(R5)
        write_word('h00D, 32'h8B9FFFFC); // ldi   R7, -4(R3)
        write_word('h00E, 32'h03A90000); // add   R7, R5, R2
        write_word('h00F, 32'h48880003); // addi  R1, R1, 3
        write_word('h010, 32'h70880000); // neg   R1, R1
        write_word('h011, 32'h78880000); // not   R1, R1
        write_word('h012, 32'h5088000F); // andi  R1, R1, 0xF
        write_word('h013, 32'h3A010000); // ror   R4, R0, R2
        write_word('h014, 32'h58A00005); // ori   R1, R4, 5
        write_word('h015, 32'h2A090000); // shra  R4, R1, R2
        write_word('h016, 32'h22A90000); // shr   R5, R5, R2
        write_word('h017, 32'h928000A3); // st    0xA3, R5
        write_word('h018, 32'h42810000); // rol   R5, R0, R2
        write_word('h019, 32'h1B900000); // or    R7, R2, R0
        write_word('h01A, 32'h12280000); // and   R4, R5, R0
        write_word('h01B, 32'h93A00089); // st    0x89(R4), R7
        write_word('h01C, 32'h082B8000); // sub   R0, R5, R7
        write_word('h01D, 32'h32290000); // shl   R4, R5, R2
        write_word('h01E, 32'h8B800007); // ldi   R7, 7
        write_word('h01F, 32'h89800019); // ldi   R3, 0x19
        write_word('h020, 32'h69B80000); // mul   R3, R7
        write_word('h021, 32'hC0800000); // mfhi  R1
        write_word('h022, 32'hCB000000); // mflo  R6
        write_word('h023, 32'h61B80000); // div   R3, R7
        write_word('h024, 32'h8C380002); // ldi   R8, 2(R7)
        write_word('h025, 32'h8C9FFFFC); // ldi   R9, -4(R3)
        write_word('h026, 32'h8D300003); // ldi   R10, 3(R6)
        write_word('h027, 32'h8D880005); // ldi   R11, 5(R1)
        write_word('h028, 32'h9D000000); // jal   R10
        write_word('h029, 32'hD8000000); // halt

        write_word('h089, 32'h000000A7);
        write_word('h0A3, 32'h00000068);

        write_word('h0B2, 32'h07450000); // add R14, R8, R10
        write_word('h0B3, 32'h0ECD8000); // sub R13, R9, R11
        write_word('h0B4, 32'h0F768000); // sub R14, R14, R13
        write_word('h0B5, 32'hA6000000); // jr R12

        #40;
        clear = 1'b0;

        wait (stop == 1'b1);
		  
        #1000;

        $display("==============================================");
        $display("PHASE 3 PROGRAM COMPLETE");
        $display("==============================================");
        $display("PC   = %h", DUT.DP.PC_Q);
        $display("IR   = %h", DUT.DP.IR_Q);
        $display("MAR  = %h", DUT.DP.MAR_Q);
        $display("MDR  = %h", DUT.DP.MDR_Q);
        $display("HI   = %h", DUT.DP.HI_Q);
        $display("LO   = %h", DUT.DP.LO_Q);
        $display("R0   = %h", DUT.DP.R0_Q);
        $display("R1   = %h", DUT.DP.R1_Q);
        $display("R2   = %h", DUT.DP.R2_Q);
        $display("R3   = %h", DUT.DP.R3_Q);
        $display("R4   = %h", DUT.DP.R4_Q);
        $display("R5   = %h", DUT.DP.R5_Q);
        $display("R6   = %h", DUT.DP.R6_Q);
        $display("R7   = %h", DUT.DP.R7_Q);
        $display("R8   = %h", DUT.DP.R8_Q);
        $display("R9   = %h", DUT.DP.R9_Q);
        $display("R10  = %h", DUT.DP.R10_Q);
        $display("R11  = %h", DUT.DP.R11_Q);
        $display("R12  = %h", DUT.DP.R12_Q);
        $display("R13  = %h", DUT.DP.R13_Q);
        $display("R14  = %h", DUT.DP.R14_Q);
        $display("R15  = %h", DUT.DP.R15_Q);			  
		  $display("MEM[89] = %h", read_word('h089));
        $display("MEM[A3] = %h", read_word('h0A3));
        $display("==============================================");
		  
        #100;
        $stop;
    end

endmodule
