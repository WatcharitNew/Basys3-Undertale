`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2020 11:43:17 AM
// Design Name: 
// Module Name: Segment
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


module ClockDivider(
    output reg clkDiv,
    input clk
    );
initial
begin
    clkDiv = 0;
end

always @(posedge clk)
begin
    clkDiv = ~clkDiv;
end
endmodule
