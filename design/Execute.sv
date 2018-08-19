`timescale 1ns / 1ps

import my_112l_pkg::*;

module execute #(
    parameter PC_W = 9, // Program Counter
    parameter DATA_W = 32, // Data WriteData
    parameter RF_ADDRESS = 5, // Register File Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
)(
    input logic clk, reset,
    input logic [PC_W-1:0] PC,
    input logic [PC_W-1:0] PCPlus4,
    input logic [DATA_W-1:0] reg1, reg2,
    input logic [DATA_W-1:0] imm,
    input logic [RF_ADDRESS-1:0] rd,
    input logic ALUSrc,
    input logic [1:0] memtoreg,
    input logic regwrite,
    input logic memread,
    input logic memwrite,
    input logic branch,
    input logic jalr,
    input logic jal,
    input logic lui,
    input logic load, store,
    input logic [1:0] ALUop,
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    input ID_EX id_ex_out,
    input EX_MEM ex_mem_out,
    input MEM_WB mem_wb_out,
    input logic [31:0] memwb_data,
    // input logic ControlMux,          // Hazard Control variable
    output EX_MEM exmem
);

    logic [DATA_W-1:0] srcA, srcB;
    logic [ALU_CC_W-1:0] operation;
    logic bge, blt, bgeu, bltu;
    logic [1:0] FwdA, FwdB;
    logic [31:0] fwdreg1, fwdreg2;

    assign exmem.pcplus4 = PCPlus4;
    assign exmem.memwritedata = reg2;
    assign exmem.rd = rd;
    assign exmem.branch = branch;
    assign exmem.jal = jal;
    assign exmem.jalr = jalr;
    assign exmem.regwrite = regwrite;
    assign exmem.memwrite = memwrite;
    assign exmem.memread = memread;
    assign exmem.memtoreg = memtoreg;

    // logic [ALU_CC_W-1:0] operation1;
    // logic bge1, blt1, bgeu1, bltu1;
    logic [2:0] readdataselect_out;
    logic [1:0] writedataselect_out;
    // ALUController aluc(ALUop, funct7, funct3, load, store, operation, bge, blt, bgeu, bltu, exmem.readdatasel, exmem.writedatasel);

    // ---- "Mux" For Hazard detection
    // always_comb begin
    //     if (ControlMux == 1'b1) begin
    //         operation = 4'b0000;
    //         bge = 1'b0;
    //         blt = 1'b0;
    //         bgeu = 1'b0;
    //         bltu = 1'b0;
    //         exmem.readdatasel = 3'b000;
    //         exmem.writedatasel = 2'b00;
    //         exmem.stall = 1'b1;
    //     end
    //     else begin
    //         operation = operation1;
    //         bge = bge1;
    //         blt = blt1;
    //         bgeu = bgeu1;
    //         bltu = bltu1;
    //         exmem.readdatasel = readdataselect_out;
    //         exmem.writedatasel = writedataselect_out;
    //         exmem.stall = 1'b0;
    //     end
    // end

    // ALUController aluc(ALUop, funct7, funct3, load, store, operation1, bge1, blt1, bgeu1, bltu1, readdataselect_out, writedataselect_out);

    ALUController aluc(ALUop, funct7, funct3, load, store, operation, bge, blt, bgeu, bltu, exmem.readdatasel, exmem.writedatasel);

    // ----

    forward FWDunit(id_ex_out.rs1, id_ex_out.rs2, ex_mem_out.rd, mem_wb_out.rd,
                    ex_mem_out.regwrite, mem_wb_out.regwrite, FwdA, FwdB);

    mux4 #(32) fwdamux(reg1, memwb_data, ex_mem_out.ALUResult, reg1, FwdA, fwdreg1);
    mux4 #(32) fwdbmux(reg2, memwb_data, ex_mem_out.ALUResult, reg2, FwdB, fwdreg2);

    mux2 #(32) srcamux(fwdreg1, 32'b0, lui, srcA);
    mux2 #(32) srcbmux(fwdreg2, imm, ALUSrc, srcB);

    // mux2 #(32) srcamux(reg1, 32'b0, lui, srcA);
    // mux2 #(32) srcbmux(reg2, imm, ALUSrc, srcB);

    alu alu_module(srcA, srcB, operation, bge, blt, bgeu, bltu, exmem.ALUResult);

    adder #(32) pcjump({23'b0, PC}, imm, exmem.PCJump);

endmodule
