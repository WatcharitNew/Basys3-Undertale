`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2020 07:15:13 PM
// Design Name: 
// Module Name: actScene
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


module actScene(
        input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		output reg [11:0] rgb_reg
    );
    
    //init text
    Pixel_On_Text2 #(.displayText("you acted on enemy.")) m1(
                clk,
                280, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_1  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    //init text
    Pixel_On_Text2 #(.displayText("you can now spare it")) m2(
                clk,
                280, // text position.x (top left)
                280, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_2  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    // rgb buffer (color)
    always @(posedge p_tick)
    begin
        //text
        if (text_pixel_1 | text_pixel_2 )
            rgb_reg <= 12'hFFF;
        else
            rgb_reg <= 12'b0;
    end 
endmodule
