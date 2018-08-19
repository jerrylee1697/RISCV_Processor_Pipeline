`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:10:33 PM
// Design Name: 
// Module Name: ALUController
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


module ALUController(
    
    //Inputs
    input logic [1:0] ALUOp,  //7-bit opcode field from the instruction
    input logic [6:0] Funct7, // bits 25 to 31 of the instruction
    input logic [2:0] Funct3, // bits 12 to 14 of the instruction
    input logic ReadFlag, WriteFlag,
    //Output
    output logic [3:0] Operation, //operation selection for ALU
    output logic BLT,
    output logic BGT,
    output logic BLTU,
    output logic BGEU,
    output logic [2:0]ReadDataSelect,
    output logic [1:0]WriteDataSelect
);
 
// assign Operation[0]= ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b110)) ||
//                      ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b100));
//
// assign Operation[1]= (ALUOp==2'b00) ||
//                     ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b000)) ||
//                     ((ALUOp[1]==1'b1) && (Funct7==7'b0100000) && (Funct3==3'b000)) ||
//                     ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b100));;                    
 
// assign Operation[2]= ((ALUOp[1]==1'b1) && (Funct7==7'b0100000) && (Funct3==3'b000)) ||
//                     ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b001)) ||
//                      ((ALUOp[1]==1'b1) && (Funct7==7'b0100000) && (Funct3==3'b101));
 
// assign Operation[3] = ((ALUOp[1]==1'b1) && (Funct7==7'b0100000) && (Funct3==3'b101)) ||
//                       ((ALUOp[1]==1'b1) && (Funct7==7'b0000000) && (Funct3==3'b001));

    always_comb
        begin
            case(ALUOp)
                2'b00:  // Load & Stores 
                    begin
                    Operation = 4'b0010;
                    if (ReadFlag==1'b1) begin
                        if(Funct3==3'b000) begin
                            ReadDataSelect = 3'b001;
                        end
                        else if (Funct3==3'b001) begin
                            ReadDataSelect = 3'b011;
                        end
                        else if (Funct3==3'b010) begin
                            ReadDataSelect = 3'b000;
                        end
                        else if (Funct3==3'b100) begin
                            ReadDataSelect = 3'b010;
                        end
                        else if (Funct3==3'b101) begin
                            ReadDataSelect = 3'b100;
                        end
                    end
                    else if (WriteFlag==1'b1) begin
                        if(Funct3==3'b000) begin
                            WriteDataSelect = 3'b001;
                        end
                        else if (Funct3==3'b001) begin
                            WriteDataSelect = 3'b010;
                        end
                        else if (Funct3==3'b010) begin
                            WriteDataSelect = 3'b000;
                        end 
                    end
                    end
                2'b01:  //Branches
                    if (Funct3==3'b000) begin
                        Operation = 4'b0110;    // BEQ                        
                    end
                    else begin
                        Operation = 4'b1001;    // BNE
                    end
                2'b10:
                    if (Funct3==3'b111) begin
                        Operation = 4'b0000;    // AND
                    end
                    else if (Funct3==3'b110) begin
                        Operation = 4'b0001;    //OR
                    end
                    else if (Funct3==3'b100) begin
                        Operation = 4'b0011;    // XOR
                    end
                    else if (Funct3==3'b000) begin
                        if (Funct7==7'b0000000) begin
                            Operation = 4'b0010;    // ADD
                        end
                        else if (Funct7==7'b0100000) begin
                            Operation = 4'b0110;    // SUB
                        end
                    end
                    else if (Funct3==3'b001) begin
                        Operation = 4'b0100;    // SLL & SLLI
                    end
                    else if (Funct3==3'b101) begin
                        if (Funct7==7'b0100000) begin
                            Operation = 4'b1100;    // SRA
                        end
                        else if (Funct7==7'b0000000) begin
                            Operation = 4'b0101;    // SRL
                        end
                    end
                    else if (Funct3==3'b010) begin
                        Operation = 4'b0111;    // SLT and SLTI
                    end
                    else if (Funct3==3'b011) begin
                        Operation = 4'b1000;
                    end
                2'b11:    
                        Operation = 4'b0010;
                default: 
                    Operation = 4'b0000;
            endcase
        end

endmodule

// ALU Controller

// ALUOp    Func7   Func3   Code    Operation
// 10       0000000 111     0000    AND
// 10       0000000 110     0001    OR
// 10       0000000 100     0011    XOR
// 10       0000000 000     0010    ADD
// 10       0100000 000     0110    SUB
// 10       0000000 001     0100    SLL
// 10       0100000 101     1100    SAR
// 10       0000000 001     1000    SLLI

