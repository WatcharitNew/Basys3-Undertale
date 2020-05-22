`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2020 02:56:02 AM
// Design Name: 
// Module Name: menuScene
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


module menuScene
	(
		input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		input wire newpic,
		input wire [1:0] selectedMenu,
		input wire [9:0] maxHealth,
		input wire [9:0] newHealth,
		input wire [9:0] maxEnemyHealth,
		input wire [9:0] newEnemyHealth,
		output reg [11:0] rgb_reg
	);

    wire [9:0] healthBar = (maxHealth - newHealth)*36;
    wire [9:0] enemyHealthBar = (maxEnemyHealth - newEnemyHealth)*36;
    
    //multiplexed heart (current menu)
    reg currentHeart;
    
    //scene
    reg oldsceneMain;

    wire heart1, heart2, heart3, heart4,
        text_pixel_fight, text_pixel_act, text_pixel_spare, text_pixel_item;
    
    //init text
    Pixel_On_Text2 #(.displayText("fight")) fight(
                clk,
                80, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_fight  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    Pixel_On_Text2 #(.displayText("act")) act(
                clk,
                240, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_act  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("item")) item(
                clk,
                420, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_item  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("spare")) spare(
                clk,
                600, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_spare  // result, 1 if current pixel is on text, 0 otherwise
            );
       
    Pixel_On_Text2 #(.displayText("|")) h1(
                clk,
                70, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart1  // result, 1 if current pixel is on text, 0 otherwise
            );
       
     Pixel_On_Text2 #(.displayText("|")) h2(
                clk,
                230, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart2  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("|")) h3(
                clk,
                410, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart3  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("|")) h4(
                clk,
                590, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart4  // result, 1 if current pixel is on text, 0 otherwise
            );
     Pixel_On_Text2 #(.displayText("HP")) t1(
                clk,
                215, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_hp  // result, 1 if current pixel is on text, 0 otherwise
            );
    Pixel_On_Text2 #(.displayText("ENEMY HP")) t2(
                clk,
                165, // text position.x (top left)
                420, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_enemy  // result, 1 if current pixel is on text, 0 otherwise
            );
        // rgb buffer (color)
        always @(posedge p_tick)
        //main character
        begin
        
        if (selectedMenu == 0) currentHeart = heart1;
        else if (selectedMenu == 1) currentHeart = heart2;
        else if (selectedMenu == 2) currentHeart = heart3;
        else if (selectedMenu == 3) currentHeart = heart4;
        
        if (currentHeart == 1)
            rgb_reg <= 12'hF00;
        else if (text_pixel_fight == 1 | text_pixel_act == 1 | text_pixel_item == 1 | text_pixel_spare == 1 | text_pixel_hp == 1 | text_pixel_enemy == 1)
            rgb_reg <= 12'hFFF;
        //health
        else if (400 <= y && y <= 410 && 240 <= x && x <= 420 - healthBar)
            rgb_reg <= 12'hFF0;
        else if (400 <= y && y <= 410 && 420 - healthBar < x && x <= 420)
            rgb_reg <= 12'hF00;
        //enemy health
        else if (420 <= y && y <= 430 && 240 <= x && x <= 420 - enemyHealthBar)
            rgb_reg <= 12'h0F0;
        else if (420 <= y && y <= 430 && 420 - enemyHealthBar < x && x <= 420)
            rgb_reg <= 12'hF00;
        else
            rgb_reg <= 12'b0;
        end
            
endmodule
