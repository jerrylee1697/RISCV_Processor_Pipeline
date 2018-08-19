`timescale 1ns / 1ps

import my_112l_pkg::*;

module instructionfetch #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32 // Instruction Width
    )(
        // change input and output
        input logic clk, reset,
        input logic [PC_W-1:0] PCJump, ALUResultJALR,
        input logic [1:0] PCSrc,
        // input logic PC_Write,   // Hazard control flag
        output IF_ID if_id
    );

    logic [PC_W-1:0] PC, PCPlus4, NextPC;
    logic [INS_W-1:0] instruction;
    // logic [1:0] HazardPCSelect;

    // always_comb begin
    //     if (PC_Write == 1'b1) begin
    //         HazardPCSelect = 2'b11;
    //     end
    //     else begin
    //         HazardPCSelect = PCSrc;
    //     end
    // end

    adder #(9) pcadd (PC, 9'b100, PCPlus4);
    mux4 #(9) pcmux(PCPlus4, PCJump, ALUResultJALR, PC, PCSrc, NextPC);
    flopr #(9) pcreg(clk, reset, NextPC, PC);
    instructionmemory instr_mem(PC, instruction);

    assign if_id.instruction = instruction;
    assign if_id.pc = PC;
    assign if_id.pcplus4 = PCPlus4;

endmodule
