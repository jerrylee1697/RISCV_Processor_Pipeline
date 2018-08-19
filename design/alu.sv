`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:23:43 PM
// Design Name: 
// Module Name: alu
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


module alu#(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )(
        input logic [DATA_WIDTH-1:0]    SrcA,
        input logic [DATA_WIDTH-1:0]    SrcB,

        input logic [OPCODE_LENGTH-1:0]    Operation,
        input logic BLT, BGT, BLTU, BGEU, 
        output logic[DATA_WIDTH-1:0] ALUResult
        );
    
        always_comb
        begin
            case(Operation)
            4'b0000:        //AND
                    ALUResult = SrcA & SrcB;
            4'b0001:        //OR
                    ALUResult = SrcA | SrcB;
            4'b0011:        //XOR
                    ALUResult = SrcA ^ SrcB;
            4'b0010:        //ADD
                    ALUResult = SrcA + SrcB;
            4'b0110:        //Subtract & BEQ
                    ALUResult = $signed(SrcA) - $signed(SrcB);
            4'b0100:        //Shift Logic Left
                    ALUResult = SrcA << SrcB[4:0];
            4'b1100:        //Shift Arithmetic Right
                    ALUResult = $signed(SrcA) >>> SrcB[4:0];           
            4'b0101:        //Shift Logic Right
                    ALUResult = SrcA >> SrcB[4:0];
            4'b0111:        // SLT
                    ALUResult = ($signed(SrcA) < $signed(SrcB)) ? (32'b1) : (32'b0);
            4'b1000:        // SLTU and SLTUI
                    ALUResult = (SrcA < SrcB) ? (32'b1) : (32'b0);
            4'b1001:        // BNE
                    if (BLT == 1'b1) begin
                        ALUResult = (($signed(SrcA)) < ($signed(SrcB))) ? (32'b0) : (32'b1);
                    end
                    else if (BGT == 1'b1) begin
                        ALUResult = ($signed(SrcA) > $signed(SrcB)) ? (32'b0) : (32'b1);
                    end
                    else if (BLTU == 1'b1) begin
                        ALUResult = (SrcA < SrcB) ? (32'b0) : (32'b1);
                    end
                    else if (BGEU == 1'b1) begin
                        ALUResult = (SrcA >= SrcB) ? (32'b0) : (32'b1);
                    end
                    else begin    
                        ALUResult = (($signed(SrcA) - $signed(SrcB)) == 0) ? (32'b1) : (32'b0);
                    end
            4'b1010:
                    ALUResult = SrcA;
            default:
                    ALUResult = 32'b0;
            endcase
        end
endmodule

