`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 11:16:35 AM
// Design Name: 
// Module Name: vga_test
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

module afterTurnScene
	(
		input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		input wire onScene,
		input wire [9:0] maxHealth,
		input wire newpic,
		input wire [2:0] direc,
		input wire targetClk,
		input wire [9:0] maxEnemyHealth,
		input wire [9:0] newEnemyHealth,
		input wire heal,
		output reg [11:0] rgb_reg,
		output reg signed [9:0] newHealth,
		output reg isHealed
	);
	
	reg [9:0] x_pos,y_pos,boxLeft,boxRight,boxTop,boxBottom,boxThick;
	
	wire [9:0] enemy1_x, enemy1_y, enemy2_x, enemy2_y;
    //wire [9:0] enemy_x, enemy_y;
    wire [9:0] enemyRadius = 5; 
    wire hitEnemy1, hitEnemy2;
    reg oldHitEnemy [2:0];
    
    //initialize
    wire [9:0] healthBar = (maxHealth - newHealth)*36;
    wire [9:0] enemyHealthBar = (maxEnemyHealth - newEnemyHealth)*36;
    
    reg canGoUp, canGoDown, canGoLeft, canGoRight;
    initial
    begin
        x_pos = 320;
        y_pos = 240;
        boxLeft = 220;
        boxRight = 420;
        boxTop = 140;
        boxBottom = 340;
        boxThick = 5;
        newHealth = 6;
        oldHitEnemy[0] = 0;
        oldHitEnemy[1] = 0;
        canGoUp = 1;
        canGoDown = 1;
        canGoLeft = 1;
        canGoRight = 1;
        isHealed = 0;
    end
    
    //enemy1
    wire [9:0] init_enemy1_x = 250;
    wire [9:0] init_enemy1_y = 190; 
    wire [9:0] speed_enemy1_x = 1;
    wire [9:0] speed_enemy1_y = 1;
    
    //enemy2
    wire [9:0] init_enemy2_x = 230;
    wire [9:0] init_enemy2_y = 150; 
    wire [9:0] speed_enemy2_x = 0;
    wire [9:0] speed_enemy2_y = 1;
    
    wire text_pixel_heart,text_pixel_hp;
    
    enemyCircle ec1(clk, targetClk, init_enemy1_x, init_enemy1_y, enemyRadius, speed_enemy1_x, speed_enemy1_y, text_pixel_heart, 
                    x, y, boxTop, boxRight, boxBottom, boxLeft, onScene, enemy1_x, enemy1_y, hitEnemy1);
    enemyCircle ec2(clk, targetClk, init_enemy2_x, init_enemy2_y, enemyRadius, speed_enemy2_x, speed_enemy2_y, text_pixel_heart, 
                    x, y, boxTop, boxRight, boxBottom, boxLeft, onScene, enemy2_x, enemy2_y, hitEnemy2);
    
    //init text
    Pixel_On_Text2 #(.displayText("HP")) t1(
                clk,
                215, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_hp  // result, 1 if current pixel is on text, 0 otherwise
            );
    Pixel_On_Text2 #(.displayText("|")) heart(
                clk,
                x_pos, // text position.x (top left)
                y_pos, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_heart  // result, 1 if current pixel is on text, 0 otherwise
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
        if (text_pixel_heart == 1)
            rgb_reg <= 12'hF00;
        //enemy1
        else if (25 > (x-enemy1_x)**2 + (y-enemy1_y)**2 && hitEnemy1 == 0)
            rgb_reg <= 12'hFFF;
        //enemy2
        else if (25 > (x-enemy2_x)**2 + (y-enemy2_y)**2 && hitEnemy2 == 0)
            rgb_reg <= 12'hFFF;
        
        //box
        else if (boxLeft <= x && x <= boxRight && boxTop <= y && y <= boxBottom)
            rgb_reg <= 12'h000;
        else if (boxLeft - boxThick <= x && x <= boxRight + boxThick && boxTop - boxThick <= y && y <= boxBottom + boxThick)
            rgb_reg <= 12'hFFF;
            
        // gentext HP
        else if (text_pixel_hp == 1)
            rgb_reg <= 12'hFFF;
        else if (text_pixel_enemy == 1)
            rgb_reg <= 12'hFFF;
        
        // health bar    
        else if (400 <= y && y <= 410 && boxLeft - boxThick + 25 <= x && x <= boxRight - healthBar)
            rgb_reg <= 12'hFF0;
        else if (400 <= y && y <= 410 && 420 - healthBar < x && x <= 420)
            rgb_reg <= 12'hF00;
        else if (420 <= y && y <= 430 && 240 <= x && x <= 420 - enemyHealthBar)
            rgb_reg <= 12'h0F0;
        else if (420 <= y && y <= 430 && 420 - enemyHealthBar < x && x <= 420)
            rgb_reg <= 12'hF00;
        else
            rgb_reg <= 0;
        end
        
        //move
        always @(posedge newpic)
        begin
        if(onScene == 0)
        begin
            x_pos <= 320;
            y_pos <= 240;
        end
        
        if (direc==1 && y_pos >= boxTop) y_pos=y_pos-3;
        else if (direc==2 && x_pos >= boxLeft+3) x_pos=x_pos-3;
        else if (direc==3 && y_pos <= boxBottom - 15) y_pos=y_pos+3;
        else if (direc==4 && x_pos <= boxRight - 10) x_pos=x_pos+3;
        end
        
        //UART
        always @(posedge clk)
            begin
            isHealed <=0 ;
            if(hitEnemy1 == 0) begin oldHitEnemy[0] = 0; end
            if(hitEnemy2 == 0) begin oldHitEnemy[1] = 0; end
            if(hitEnemy2 == 1 && oldHitEnemy[1] == 0) begin newHealth <= newHealth-1; oldHitEnemy[1] <=1; end
            else if(hitEnemy1 == 1 && oldHitEnemy[0] == 0) begin newHealth <= newHealth-1; oldHitEnemy[0] <=1; end
            if(heal)
                begin
                    if(newHealth <= 5) begin newHealth <= newHealth+1; isHealed <=1; end
                    else isHealed <=0;
                end
            end
endmodule