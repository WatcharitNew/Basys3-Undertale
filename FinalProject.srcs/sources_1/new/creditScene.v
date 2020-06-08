`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 06:00:04 PM
// Design Name: 
// Module Name: creditScene
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

module creditScene
	(
	    input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		output reg [11:0] rgb_reg
	);
	
	//init text
    Pixel_On_Text2 #(.displayText("CREDIT")) t1(
                clk,
                320, // text position.x (top left)
                120, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_1  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("6030124821 Chavin Chuangchaichatchavarn")) t2(
                clk,
                80, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_2  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    Pixel_On_Text2 #(.displayText("6031054721 Watcharit Tuntayakul")) t3(
                clk,
                80, // text position.x (top left)
                280, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_3  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("6031062721 Itthithee Leelachutipong")) t4(
                clk,
                80, // text position.x (top left)
                320, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_4  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("6031059921 Setthanan Nakaphan")) t5(
                clk,
                80, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_5  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("6031001421 Kanokphat Jinanarong")) t6(
                clk,
                80, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_6  // result, 1 if current pixel is on text, 0 otherwise
            );
	
    // rgb buffer (color)
    always @(posedge p_tick)
    //main character
    begin
        if (text_pixel_1 | text_pixel_2 | text_pixel_3 | text_pixel_4 | text_pixel_5 | text_pixel_6 )
            rgb_reg <= 12'hFFF;
        else
            rgb_reg <= 12'b0;
    end    
    
endmodule
