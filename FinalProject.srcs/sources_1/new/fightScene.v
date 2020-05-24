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
        output reg [11:0] rgb_reg
    );
    /// line is vertical line
    reg [9:0] x_pos,y_pos,lineThick,speed_bar,lineHeight;
    /// 0 goRight , 1 goLeft
    reg direct,onSelect;
    initial
    begin
        x_pos = 300;
        y_pos = 240;
        lineThick = 5;
        lineHeight = 15;
        speed_bar = 1;
        direct = 0;
        onSelect = 0;
    end
    /// line_position_x = 350,400,450
    always @(posedge p_tick)
    begin
    /// bar movement
    if(x>=x_pos && x<=x_pos+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hF00;
    /// line1
    else if(x>=350 && x<=350+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hFF0;
    /// line2
    else if(x>=400 && x<=400+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hFF0;
    /// line3
    else if(x>=450 && x<=450+lineThick && y>=y_pos && y <= y_pos+lineHeight)
        rgb_reg <= 12'hFF0;
    else
        rgb_reg <= 0;
    end
    /// x_min = 300, x_max = 500
    always@(posedge targetClk)
    begin
        if(onScene == 0)
        begin
            x_pos <= 300;
            y_pos <= 240;
            onSelect <=0;
        end
        else
        begin
            if(!stop)
            begin    
                if(x_pos+speed_bar > 500 && direct == 0)
                    direct <=1;
                else if(x_pos-speed_bar < 300 && direct == 1)
                    direct <=0;
                if(direct==0)
                    x_pos = x_pos+speed_bar;
                else if(direct==1)
                    x_pos = x_pos-speed_bar;
            end
        end
    end
endmodule
