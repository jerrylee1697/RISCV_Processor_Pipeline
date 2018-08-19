`timescale 1ns / 1ps

import my_112l_pkg::*;

module IF_ID_Reg (
    input logic clk,reset,
    input IF_ID in,
    output IF_ID out
);
    // IF_ID data;
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            out.instruction = 0;
            out.pc = 0;
            out.pcplus4 = 0;
        end
        else begin
            out = in;
        end
    end
endmodule

module ID_EX_Reg (
    input logic clk, reset,
    input ID_EX in,
    output ID_EX out
);
    // ID_EX data;
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            out.pc = 0;
            out.pcplus4 = 0;
            out.reg1 = 0;
            out.reg2 = 0;
            out.imm = 0;
            out.rd = 0;
            out.funct7 = 0;
            out.funct3 = 0;

            out.ALUSrc = 0;
            out.memtoreg = 0;
            out.regwrite = 0;
            out.memread = 0;
            out.memwrite = 0;
            out.branch = 0;
            out.jalr = 0;
            out.jal = 0;
            out.lui = 0;
            out.load = 0;
            out.store = 0;
            out.ALUop = 0;
        end
        else begin
            out = in;
        end
    end
endmodule

module EX_MEM_Reg (
    input logic clk, reset,
    input EX_MEM in,
    output EX_MEM out
);
    // EX_MEM data;
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            out.pcplus4 = 0;
            out.PCJump = 0;
            out.ALUResult = 0;
            out.memwritedata = 0;
            out.rd = 0;

            // out.stall = 1'b1;
            out.branch = 0;
            out.jal = 0;
            out.jalr = 0;
            out.regwrite = 0;
            out.memwrite = 0;
            out.memread = 0;
            out.readdatasel = 0;
            out.writedatasel = 0;
            out.memtoreg = 0;
        end
        else begin
            out = in;
        end
    end
endmodule

module MEM_WB_Reg (
    input logic clk, reset,
    input MEM_WB in,
    output MEM_WB out
);
    // MEM_WB data;
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            out.pcplus4 = 0;
            out.PCJump = 0;
            out.readdata = 0;
            out.ALUResult = 0;
            out.rd = 0;

            // out.stall = 1'b1;
            out.memtoreg = 0;
            out.readdatasel = 0;
            out.regwrite = 0;
        end
        else begin
            out = in;
        end
    end
endmodule
