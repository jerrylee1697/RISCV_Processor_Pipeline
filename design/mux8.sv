`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:21:50 PM
// Design Name: 
// Module Name: mux2
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


module mux8
    #(parameter WIDTH = 32)
    (input logic [WIDTH-1:0] d0, d1, d2, d3, d4, d5, d6, d7,
     input logic [2:0] select,
     output logic [WIDTH-1:0] y);

//assign y = (s == 2'b00) ? d0 :
//           (s == 2'b01) ? d1 :
//           (s == 2'b10) ? d2 :
//           (s == 2'b11) ? d3 ;

    wire [WIDTH-1:0]  out1;
    wire [WIDTH-1:0]out2;

mux4 #(WIDTH) M1(
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .select(select[1:0]),
    .y(out1)
    );

mux4 #(WIDTH) M2(
    .d0(d4),
    .d1(d5),
    .d2(d6),
    .d3(d7),
    .select(select[1:0]),
    .y(out2)
    );
mux2 #(WIDTH) M3(
    .d0(out1),
    .d1(out2),
    .s(select[2]),
    .y(y)
    );
endmodule
