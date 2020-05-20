`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2020 07:22:27 PM
// Design Name: 
// Module Name: blackScene
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


module loadingScene
	(
	    input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		output reg [11:0] rgb_reg
	);
	
    reg [9:0] loadingBar;

    reg oldscene;
    initial begin
        loadingBar = 0;
        oldscene = 0;
    end
    
    // rgb buffer (color)
    always @(posedge p_tick)
    //main character
    begin
        if (400 <= y && y <= 410 && 220 <= x && x <= 420)
            rgb_reg <= 12'h0F0;
        else
        rgb_reg <= 12'h000;
    end    
endmodule
