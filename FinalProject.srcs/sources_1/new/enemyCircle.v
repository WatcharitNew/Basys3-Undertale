`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 08:44:14 PM
// Design Name: 
// Module Name: enemyCircle
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


module enemyCircle(
    input wire clk,
    input wire targetClk,
    input wire [9:0] enemy_x,
    input wire [9:0] enemy_y,
    input wire [9:0] radius,
    input wire [9:0] speed_x,
    input wire [9:0] speed_y,
    input wire text_pixel_heart,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] boxTop,
    input wire [9:0] boxRight,
    input wire [9:0] boxBottom,
    input wire [9:0] boxLeft,
    input wire newScene,
    output reg [9:0] newEnemy_x,
    output reg [9:0] newEnemy_y,
    output reg hitEnemy
    );
    
    reg oldScene;
    reg [9:0] newSpeed_x,newSpeed_y;
    
    
    
    initial begin
        oldScene = 0;
        hitEnemy = 0;
    end
    
        //enemy
        always @(posedge targetClk)
        begin
            if(oldScene != newScene)
            begin
                newEnemy_x = enemy_x;
                newEnemy_y = enemy_y;
                newSpeed_x = speed_x;
                newSpeed_y = speed_y;
                oldScene <= newScene;
            end
            
            if(hitEnemy == 0)
            begin
                newEnemy_x <= newEnemy_x + newSpeed_x;
                newEnemy_y <= newEnemy_y + newSpeed_y;
                if(newEnemy_x >= boxRight - radius)   newSpeed_x <= -speed_x;
                else if(newEnemy_x <= boxLeft + radius)   newSpeed_x <= speed_x;
                else if(newEnemy_y >= boxBottom - radius)   newSpeed_y <= -speed_y;
                else if(newEnemy_y <= boxTop + radius)   newSpeed_y <= speed_y;   
            end
        end
        
        always @(posedge clk)
        begin
            if(oldScene != newScene)
            begin
                hitEnemy = 0;
            end
            if(text_pixel_heart == 1 && 25 > (x-newEnemy_x)**2 + (y-newEnemy_y)**2 && hitEnemy == 0)
                hitEnemy <= 1;
        end
    
endmodule
