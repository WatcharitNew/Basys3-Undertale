`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 03:57:25 PM
// Design Name: 
// Module Name: gameOver
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


module gameOver
	(
	    input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		output reg [11:0] rgb_reg
	);
	
	Pixel_On_Text2 #(.displayText("Game Over")) t1(
                clk,
                280, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel  // result, 1 if current pixel is on text, 0 otherwise
            );
	
    // rgb buffer (color)
    always @(posedge p_tick)
    //main character
    begin
        if (text_pixel) 
            rgb_reg <= 12'hF00;
        else
            rgb_reg <= 12'hFFF;
    end    
    
endmodule
