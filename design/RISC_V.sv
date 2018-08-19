`timescale 1ns / 1ps

// `include "my_112l_pkg.sv"
import my_112l_pkg::*;

module riscv #(
    parameter PC_W = 9,
    parameter INS_W = 32,
    parameter DATA_W = 32,
    parameter ALU_CC_W = 4,
    parameter RF_ADDRESS = 5,
    parameter DM_ADDRESS = 9
    )
    (
        input logic clk, reset,     // clock and reset signals
        output logic [31:0] WB_Data // The ALU_Result
    );

logic [6:0] opcode;
logic ALUSrc;
logic [1:0] MemtoReg;
logic RegWrite, MemRead, MemWrite, Branch, jalr, AUIPC, jal, BLT, BGE, BLTU, BGEU;

logic [1:0] ALUop;
logic [6:0] Funct7;
logic [2:0] Funct3;
logic [3:0] Operation;
logic ReadFlag;
logic WriteFlag;
logic [2:0] ReadDataSelect;
logic [1:0] WriteDataSelect;

    // Original Single Cycle
    // Controller c(opcode, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, jalr, AUIPC, jal, ReadFlag, WriteFlag, ALUop);
    //
    // ALUController ac(ALUop, Funct7, Funct3, ReadFlag, WriteFlag, Operation, BLT, BGE, BLTU, BGEU, ReadDataSelect, WriteDataSelect);
    //
    // Datapath dp(clk, reset, RegWrite , MemtoReg, ALUSrc , MemWrite, MemRead, Branch, jalr, AUIPC, jal, BLT, BGE, BLTU, BGEU, ReadDataSelect, WriteDataSelect, Operation, opcode, Funct7, Funct3, ALU_Result);

// ---- Instantiate Structs ---- //
IF_ID if_id_in;
IF_ID if_id_out;

ID_EX id_ex_in;
ID_EX id_ex_out;

EX_MEM ex_mem_in;
EX_MEM ex_mem_out;

MEM_WB mem_wb_in;
MEM_WB mem_wb_out;

// ---- Hazard Variables ---- //
// logic PC_Write, IFID_Write, ControlMux;

// ---- Instruction Fetch ---- //
logic [DATA_W-1:0] ALUResultJALR;
logic [1:0] PCSrc;

assign ALUResultJALR = -1 & ex_mem_out.ALUResult;  // Flag for JALR
assign PCSrc         = {ex_mem_out.jalr,
                       (ex_mem_out.jal ||
                       (ex_mem_out.ALUResult == 0 && ex_mem_out.branch))};

instructionfetch IF(clk, reset, ex_mem_out.PCJump[8:0], ALUResultJALR[8:0], PCSrc/*, PC_Write*/, if_id_in);
IF_ID_Reg if_id_reg(clk, IFID_Write, if_id_in, if_id_out);

// ---- Instruction Decode ---- //
logic regwrite;
logic [RF_ADDRESS-1:0] rd, rs1, rs2;
logic [DATA_W-1:0] regwritedata;

assign WB_Data = regwritedata;

assign regwrite     = mem_wb_out.regwrite;
// assign rd           = mem_wb_out.rd;
assign rs1          = if_id_out.instruction[19:15];
assign rs2          = if_id_out.instruction[24:20];
// assign regwritedata = 32'b0; // May need to include mux
assign opcode       = if_id_out.instruction[6:0];
assign funct7       = if_id_out.instruction[31:25];
assign funct3       = if_id_out.instruction[14:12];

instructiondecode ID(clk, reset, if_id_out.pc, if_id_out.pcplus4, regwrite, rd,
                     rs1, rs2, regwritedata, opcode, if_id_out.instruction[31:25],
                     if_id_out.instruction[14:12], if_id_out.instruction, /*PC_Write, IFID_Write, ControlMux,*/ id_ex_in);
ID_EX_Reg idexreg(clk, reset, id_ex_in, id_ex_out);

// ---- Execute ---- //
execute EX(clk, reset, id_ex_out.pc, id_ex_out.pcplus4, id_ex_out.reg1,
            id_ex_out.reg2, id_ex_out.imm, id_ex_out.rd, id_ex_out.ALUSrc,
            id_ex_out.memtoreg, id_ex_out.regwrite, id_ex_out.memread,
            id_ex_out.memwrite, id_ex_out.branch, id_ex_out.jalr,
            id_ex_out.jal, id_ex_out.lui, id_ex_out.load, id_ex_out.store,
            id_ex_out.ALUop, id_ex_out.funct7, id_ex_out.funct3, id_ex_out,
            ex_mem_out, mem_wb_out, regwritedata, /*ControlMux, */ex_mem_in);

EX_MEM_Reg exmemreg(clk, /*ex_mem_in.stall*/ reset, ex_mem_in, ex_mem_out);

// ---- Memory ---- //
memory MEM(clk, reset, ex_mem_out.pcplus4, ex_mem_out.PCJump,
            ex_mem_out.ALUResult, ex_mem_out.memwritedata, ex_mem_out.rd,
            ex_mem_out.branch, ex_mem_out.regwrite, ex_mem_out.memwrite,
            ex_mem_out.memread, ex_mem_out.readdatasel, ex_mem_out.writedatasel,
            ex_mem_out.memtoreg, mem_wb_in);

MEM_WB_Reg memwbreg(clk, /*ex_mem_out.stall*/ reset, mem_wb_in, mem_wb_out);

// ---- Memory Writeback ---- //
writeback WB(clk, reset, mem_wb_out.pcplus4[8:0], mem_wb_out.PCJump[8:0], mem_wb_out.readdata, mem_wb_out.ALUResult, mem_wb_out.memtoreg, mem_wb_out.readdatasel, mem_wb_out.regwrite, mem_wb_out.rd,  regwritedata, rd);

endmodule
