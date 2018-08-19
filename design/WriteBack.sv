`timescale 1ns/1ps

// `include "my_112l_pkg.sv"
import my_112l_pkg::*;

module writeback #(
    parameter PC_W = 9,         // Program Counter
    parameter DATA_W = 32,      // Data WriteData
    parameter RF_ADDRESS = 5    // Data Memory Address
)(
    input logic clk, reset,
    input logic [PC_W-1:0] PCPlus4,
    input logic [PC_W-1:0] PCJump,
    input logic [DATA_W-1:0] readdata,
    input logic [DATA_W-1:0] ALUResult,
    input logic [1:0] memtoreg,
    input logic [2:0] readdatasel,
    input logic regwrite,
    input logic [RF_ADDRESS-1:0] rd,
    output logic [DATA_W-1:0] writedata,
    output logic [RF_ADDRESS-1:0] RD
);

logic [DATA_W-1:0] readbyte, readbyteunsigned, readhalfword,readhalfwordunsigned;
logic [DATA_W-1:0] datatoread;

assign readbyte = {{24{readdata[7]}}, readdata[7:0]};
assign readbyteunsigned = {24'b0, readdata[7:0]};
assign readhalfword = {{16{readdata[15]}}, readdata[15:0]};
assign readhalfwordunsigned = {{16'b0, readdata[15:0]}};
assign RD = rd;

mux8 #(32) ReadDataMux(readdata, readbyte, readbyteunsigned, readhalfword,readhalfwordunsigned, readdata, readdata, readdata, readdatasel, datatoread);
mux4 #(32) resmux(ALUResult, datatoread, {23'b0, PCPlus4}, {23'b0, PCJump}, memtoreg, writedata);

endmodule
