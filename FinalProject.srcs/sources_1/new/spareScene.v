`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2020 07:15:48 PM
// Design Name: 
// Module Name: spareScene
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


module spareScene(
        input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		output reg [11:0] rgb_reg_fail,
		output reg [11:0] rgb_reg_spared
    );
    
    //init text
    Pixel_On_Text2 #(.displayText("cannot spare, act first.")) m1(
                clk,
                240, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_1  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    //init text
    Pixel_On_Text2 #(.displayText("you spared the enemy")) m2(
                clk,
                240, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_2  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    // rgb buffer (color)
    always @(posedge p_tick)
    begin
        // not acted
        if (text_pixel_1 == 1)
            rgb_reg_fail <= 12'hFFF;
        else
            rgb_reg_fail <= 12'b0;
        
        // acted
        if (text_pixel_2 == 1)
            rgb_reg_spared <= 12'hFFF;
        else
            rgb_reg_spared <= 12'b0;
    end 
    
endmodule
