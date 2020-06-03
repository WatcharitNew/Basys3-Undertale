`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2020 09:07:54 PM
// Design Name: 
// Module Name: fightScene
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


module fightScene(
        input wire clk,
        input wire video_on,
        input wire p_tick, 
        input wire [9:0] x,y,
        input wire stop,
        input wire newpic,
        input wire onScene,
        input wire targetClk,
        input wire [9:0] maxHealth,
        input wire [9:0] maxEnemyHealth,
		input wire [9:0] newHealth,
        output reg [11:0] rgb_reg,
        output reg signed [9:0] newEnemyHealth,
        output reg [1:0] onHitEnemy
    );
    /// line is vertical line
    reg [9:0] x_pos,y_pos,lineThick,speed_bar,lineHeight,boxLeft,boxRight,boxTop,boxBottom,boxThick;
    
     //initialize
    wire [9:0] healthBar = (maxHealth - newHealth)*36;
    wire [9:0] enemyHealthBar = (maxEnemyHealth - newEnemyHealth)*36;
    /// 0 goRight , 1 goLeft
    reg direct;
    initial
    begin
        x_pos = 200;
        y_pos = 240;
        lineThick = 5;
        lineHeight = 15;
        speed_bar = 1;
        direct = 0;
        boxLeft = 220;
        boxRight = 420;
        boxTop = 140;
        boxBottom = 340;
        boxThick = 5;
        newEnemyHealth = 6;
        onHitEnemy = 0;
    end
    
    wire text_pixel_heart,text_pixel_hp;
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
            
    /// line_position_x = 350,400,450
    always @(posedge p_tick)
    begin
    /// bar movement
    if(x>=x_pos && x<=x_pos+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hF00;
    
    /// start line
    else if(x>=195 && x<=195+lineThick && y>=y_pos-30 && y <= y_pos+lineHeight+30)
        rgb_reg <= 12'h00F;
    /// end line
    else if(x>=410 && x<=410+lineThick && y>=y_pos-30 && y <= y_pos+lineHeight+30)
        rgb_reg <= 12'h00F;
    /// top line
    else if(x>=195 && x<=410+lineThick && y>=y_pos-30 && y <= y_pos-25)
        rgb_reg <= 12'h00F;
    /// bottom line
    else if(x>=195 && x<=410+lineThick && y>=y_pos+lineHeight+30 && y <= y_pos+lineHeight+35)
        rgb_reg <= 12'h00F;
        
    /// line1
    else if(x>=250 && x<=250+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hFFF;
    /// line2
    else if(x>=300 && x<=300+lineThick && y>=y_pos-10 && y <= y_pos+lineHeight+10)
        rgb_reg <= 12'hFF0;
    /// line3
    else if(x>=350 && x<=350+lineThick && y>=y_pos && y <= y_pos+lineHeight)
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
    /// x_min = 200, x_max = 400
    always@(posedge targetClk)
    begin
        if(onScene == 0)
        begin
            x_pos <= 200;
            y_pos <= 240;
            onHitEnemy <=0;
            direct <=0 ;
        end
        else
        begin
            if(!stop)
            begin    
                if(x_pos+speed_bar > 400 && direct == 0)
                    direct <=1;
               // else if(x_pos-speed_bar < 300 && direct == 1)
               //     direct <=0;
                if(direct==0)
                    x_pos = x_pos+speed_bar;
                else if(direct==1)
                    onHitEnemy=2;
            end
            else
            begin
                if(onHitEnemy == 0) onHitEnemy=1;
                else if(onHitEnemy == 1) onHitEnemy=2;
            end
        end
    end
    /// damage depend on distance ,0 will get 2 damage, 10 will get 1 damage, other will get none
    /// distance is not measured from the center of line or bar
    always@(posedge onHitEnemy)
    begin
        if(onHitEnemy==1)
        begin
           if(x_pos >= 290 && x_pos <= 310) newEnemyHealth <= $signed(newEnemyHealth)-3;
           else if((x_pos < 290 && x_pos >= 250) || (x_pos > 310 && x_pos <= 350)) newEnemyHealth <= $signed(newEnemyHealth)-2;
           else newEnemyHealth <= $signed(newEnemyHealth)-1;  
                ///else newEnemyHealth <= newEnemyHealth-1;
        end
    end
endmodule
