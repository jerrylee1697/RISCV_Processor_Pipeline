`timescale 1ns / 1ps

import my_112l_pkg::*;

module instructiondecode #(
    parameter PC_W = 9,     // Program Counter
    parameter INS_W = 32,   // Instruction Width
    parameter RF_ADDRESS = 5, // Register File Address
    parameter DATA_W = 32  // Data WriteData
    )(
    input logic clk, reset,
    input logic [PC_W-1:0] PC,
    input logic [PC_W-1:0] PCPlus4,
    input logic regwrite,
    input logic [RF_ADDRESS-1:0] rd,
    input logic [RF_ADDRESS-1:0] rs1, rs2,
    input logic [DATA_W-1:0] regwritedata,
    input logic [6:0] opcode,
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    input logic [31:0] instruction,
    // output logic PC_Write, IFID_Write, ControlMux,
    output ID_EX idex
);

    // HazardUnit Hazard_Unit(idex.memread, idex.rd, rs1, rs2, PC_Write, IFID_Write, ControlMux);

    RegFile rf(clk, reset, regwrite, rd, rs1, rs2, regwritedata, idex.reg1, idex.reg2);

    imm_Gen Ext_Imm(instruction, idex.imm);

    Controller c(opcode, idex.ALUSrc, idex.memtoreg, idex.regwrite, idex.memread, idex.memwrite, idex.branch, idex.jalr, idex.jal, idex.lui, idex.load, idex.store, idex.ALUop);

    assign idex.rs1 = rs1;
    assign idex.rs2 = rs2;
    assign idex.pc = PC;
    assign idex.pcplus4 = PCPlus4;
    assign idex.funct7 = funct7;
    assign idex.funct3 = funct3;
    assign idex.rd = instruction[11:7];

endmodule
