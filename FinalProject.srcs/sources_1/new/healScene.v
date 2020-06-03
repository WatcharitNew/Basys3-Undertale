`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2020 07:26:40 PM
// Design Name: 
// Module Name: healScene
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


module healScene(
        input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		input wire isHealed,
		input wire onScene,
		input wire targetClk,
		output reg [11:0] rgb_reg,
		output reg heal
    );
    wire text_pixel_1,text_pixel_2,text_pixel_3,text_pixel_4;
    reg [1:0] state;
    reg healed;
    reg signed [9:0] potionNum;
    initial
    begin
        state = 0;
        heal = 0;
        potionNum = 2;
    end
    //init text
    Pixel_On_Text2 #(.displayText("you use a potion.")) m1(
                clk,
                280, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_1  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    //init text
    Pixel_On_Text2 #(.displayText("your HP is full,")) m2(
                clk,
                280, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_2  // result, 1 if current pixel is on text, 0 otherwise
            );
    
     Pixel_On_Text2 #(.displayText("you cannot use potion.")) m3(
                clk,
                280, // text position.x (top left)
                280, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_3  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("run out of potion")) m4(
                clk,
                280, // text position.x (top left)
                240, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_4  // result, 1 if current pixel is on text, 0 otherwise
            );
    // rgb buffer (color)
    always @(posedge p_tick)
    begin
        //text
        if(potionNum == 0)
        begin
            if (text_pixel_4)
                rgb_reg <= 12'hFFF;
            else
                rgb_reg <= 12'h000;
        end
        else if(healed)
        begin
            if (text_pixel_1)
                rgb_reg <= 12'hFFF;
            else
                rgb_reg <= 12'h000;
        end
        else
        begin
            if (text_pixel_2 || text_pixel_3)
                rgb_reg <= 12'hFFF;
            else
                rgb_reg <= 12'h000;
        end    
    end
    always @(posedge clk)
    begin
        if(onScene==0) begin 
            state <= 0;
            if(healed) begin healed<=0; potionNum<= $signed(potionNum)-1;end  
        end
        else if(onScene)
        begin
            if(state==0) begin state <= 1; heal <=0; end
            else if(state==1) begin 
                state <= 2; 
                if($signed(potionNum) >0 ) heal <=1; 
            end
            else if(state==2) begin heal<=0; end
            if(isHealed) begin 
                healed <=1 ;
            end
        end
    end
    /*always @(posedge stateCalPotion)
    begin
        if(stateCalPotion == 1) ;
    end
    */
endmodule
