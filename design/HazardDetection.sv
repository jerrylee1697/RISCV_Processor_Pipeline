`timescale 1ns / 1ps

import my_112l_pkg::*;

module HazardUnit #()
    (
        input logic idex_memread,
        input logic [4:0] idex_rd,
        input logic [4:0] ifid_rs1, ifid_rs2,
        output logic PC_Write, IFID_Write, ControlMux
    );

always_comb begin
    if (idex_memread && ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2))) begin
        // Stall pipeline
        IFID_Write = 1'b1;  // Stall IF/ID pipeline register
        PC_Write = 1'b1;     // Stall PC register
        ControlMux = 1'b1;
    end
end

endmodule
