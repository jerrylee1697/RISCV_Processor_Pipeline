`timescale 1ns / 1ps

import my_112l_pkg::*;

module memory #(
    parameter PC_W = 9, // Program Counter
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter RF_ADDRESS = 5
)(
    input logic clk, reset,
    input logic [PC_W-1:0] PCPlus4,
    input logic [31:0] PCJump,
    input logic [DATA_W-1:0] ALUResult,
    input logic [DATA_W-1:0] writedata,
    input logic [RF_ADDRESS-1:0] rd,
    input logic branch,
    input logic regwrite,
    input logic memwrite,
    input logic memread,
    input logic [2:0] readdatasel,
    input logic [1:0] writedatasel,
    input logic [1:0] memtoreg,
    output MEM_WB memwb
);

    logic [DATA_W-1:0] storebyte, storehalfword;
    logic [DATA_W-1:0] datatostore;

    assign memwb.PCJump = PCJump;
    assign memwb.pcplus4 = PCPlus4;
    assign memwb.ALUResult = ALUResult;
    assign memwb.memtoreg = memtoreg;
    assign memwb.readdatasel = readdatasel;
    assign memwb.rd = rd;
    assign memwb.regwrite = regwrite;

    assign storebyte = {{24{writedata[7]}}, writedata[7:0]};
    assign storehalfword = {{16{writedata[15]}}, writedata[15:0]};

    mux4 #(32) storedatamux(writedata, storebyte, storehalfword, writedata, writedatasel, datatostore);
    datamemory data_mem(clk, memread, memwrite, ALUResult[DM_ADDRESS-1:0], datatostore, memwb.readdata);

endmodule
