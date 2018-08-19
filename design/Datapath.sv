`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:10:33 PM
// Design Name: 
// Module Name: Datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Datapath #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32, // Instruction Width
    parameter RF_ADDRESS = 5, // Register File Address
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
    )(
    input logic clk , reset , // global clock
    // reset , sets the PC to zero
    RegWrite , 
    input logic [1:0] MemtoReg , //R- file writing enable // Memory or ALU MUX
    input logic ALUsrc , MemWrite , //R- file or Immediate MUX // Memroy Writing Enable
    MemRead , // Memroy Reading Enable
    Branch , // Branch  
    jalr,
    AUIPC, 
    jal,
    BLT, BGE, BLTU, BGEU,
    input logic [2:0] ReadDataSelect,
    input logic [1:0] WriteDataSelect,
    input logic [ ALU_CC_W -1:0] ALU_CC, // ALU Control Code ( input of the ALU )
    output logic [6:0] opcode,
    output logic [6:0] Funct7,
    output logic [2:0] Funct3,
    output logic [31:0] ALU_Result
    );

logic [8:0] PC, PCPlus4;
logic [31:0] PC_Jump;
logic [31:0] Instr;
logic [31:0] Result;
logic [31:0] Reg1, Reg2;
logic [31:0] ReadData;
logic [31:0] SrcA, SrcB, ALUResult;
logic [31:0] ExtImm;
logic [8:0] next_pc;
logic [1:0] BranchMuxSelect;
logic [31:0] tempALU;
logic [31:0] ReadDataB, ReadDataHW, ReadDataBU, ReadDataHWU, StoreDataB, StoreDataHW, ActualReadData, ActualStoreData;

// next PC
    adder #(9) pcadd (PC, 9'b100, PCPlus4);
    flopr #(9) pcreg(clk, reset, next_pc, PC);

// Branch adder
    adder #(32) branchadd({23'b0, PC}, ExtImm, PC_Jump); 
    assign BranchMuxSelect =  {jalr, (((ALUResult==0) && Branch) || jal)};
    mux4 #(9) pc_mux(PCPlus4, PC_Jump[8:0], tempALU[8:0], PC, BranchMuxSelect, next_pc);

//Instruction memory
    instructionmemory instr_mem (PC, Instr);
    
    assign opcode = Instr[6:0];
    assign Funct7 = Instr[31:25];
    assign Funct3 = Instr[14:12];
      
// //Register File
    RegFile rf(clk, reset, RegWrite, Instr[11:7], Instr[19:15], Instr[24:20],
            Result, Reg1, Reg2);
            
    mux4 #(32) resmux(ALUResult, ActualReadData, {23'b0, PCPlus4}, PC_Jump, MemtoReg, Result);
           
//// sign extend
    imm_Gen Ext_Imm (Instr,ExtImm);

//// ALU
    mux2 #(32) srcamux(Reg1, 32'b0, AUIPC, SrcA);
    mux2 #(32) srcbmux(Reg2, ExtImm, ALUsrc, SrcB);
    alu alu_module(SrcA, SrcB, ALU_CC, BLT, BGE, BLTU, BGEU, ALUResult);
    assign tempALU = (ALUResult & -1);
    assign ALU_Result = ALUResult;//[15:0];
    
    assign StoreDataB = {{24{Reg2[7]}}, Reg2[7:0]};
    assign StoreDataHW = {{16{Reg2[15]}}, Reg2[15:0]};
    mux4 #(32) StoreDataMux(Reg2, StoreDataB, StoreDataHW, Reg2, WriteDataSelect, ActualStoreData);

////// Data memory
    datamemory data_mem (clk, MemRead, MemWrite, ALUResult[8:0], ActualStoreData, ReadData);   
    assign ReadDataB = {{24{ReadData[7]}}, ReadData[7:0]};
    assign ReadDataBU = {24'b0, ReadData[7:0]};
    assign ReadDataHW = {{16{ReadData[15]}}, ReadData[15:0]};
    assign ReadDataHWU = {{16'b0, ReadData[15:0]}};
    mux8 #(32) ReadDataMux(ReadData, ReadDataB, ReadDataBU, ReadDataHW, ReadDataHWU, ReadData, ReadData, ReadData, ReadDataSelect, ActualReadData);

endmodule
