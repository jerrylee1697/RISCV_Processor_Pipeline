`timescale 1ns / 1ps

import my_112l_pkg::*;

module forward#()
    (
        input logic [4:0] rs1, rs2,                 //ID/EX Rs1, Rs2
        input logic [4:0] exmem_rd, memwb_rd,       // EX/MEM rd, MEM/WB rd
        input logic exmem_regwrite, memwb_regwrite, // EX/MEM regwrite, MEM/WB regwrite
        output logic [1:0] FwdA, FwdB
    );

// Forward A mux
always_comb begin
    if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == rs1)) begin
        FwdA = 2'b10;
    end
    else if (memwb_regwrite && (memwb_rd != 0) &&
    !(exmem_regwrite && (exmem_rd != 0) && (exmem_rd == rs1)) &&
    (memwb_rd == rs1)) begin
        FwdA = 2'b01;
    end
    else begin
        FwdA = 2'b00;
    end
end

// Forward B mux
always_comb begin
    if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == rs2)) begin
        FwdB = 2'b10;
    end
    else if (memwb_regwrite &&
    (memwb_rd != 0) &&
    !(exmem_regwrite && (exmem_rd != 0) && (exmem_rd == rs2)) &&
    (memwb_rd == rs2)) begin
        FwdB = 2'b01;
    end
    else begin
        FwdB = 2'b00;
    end
end

endmodule
