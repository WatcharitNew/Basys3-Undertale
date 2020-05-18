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
		input wire RsRx,
		input wire newscene,
		input wire [9:0] maxHealth,
		output reg [11:0] rgb_reg,
		output wire RsTx,
		output reg [9:0] newHealth
	);
	
	reg [9:0] x_pos,y_pos,mainRadius,boxLeft,boxRight,boxTop,boxBottom,boxThick;
	
	wire [9:0] enemy1_x, enemy1_y, enemy2_x, enemy2_y;
    //wire [9:0] enemy_x, enemy_y;
    wire [9:0] enemyRadius = 5; 
    wire hitEnemy1, hitEnemy2;
    reg oldHitEnemy [2:0];
    // move
    reg [2:0]direc;
    
    //tell whether this is a new picture
    reg newpic;
    
    //Receiver
    wire [7:0]RxData;
    wire state;
    wire nextstate;
    receiver receiver_unit(RxData, state, nextstate, clk, 0, RsRx);
    
    //Transmitter
    reg [7:0]TxData;
    reg transmit;
    reg [15:0]counter;
    transmitter(RsTx, clk, 0, transmit, TxData);
        
    //initialize
    
    wire [9:0] healthBar = (maxHealth - newHealth)*36;
    
    //scene
    reg oldsceneMain;
    
    initial
    begin
        direc = 0;
        x_pos = 320;
        y_pos = 240;
        mainRadius = 8;
        boxLeft = 220;
        boxRight = 420;
        boxTop = 140;
        boxBottom = 340;
        boxThick = 5;
        oldsceneMain = 0;
        newHealth = 6;
        oldHitEnemy[0] = 0;
        oldHitEnemy[1] = 0;
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
    
    enemyCircle ec1(clk, init_enemy1_x, init_enemy1_y, enemyRadius, speed_enemy1_x, speed_enemy1_y, x_pos, y_pos, boxTop, boxRight, boxBottom, boxLeft, 
                    oldsceneMain, enemy1_x, enemy1_y, hitEnemy1);
    enemyCircle ec2(clk, init_enemy2_x, init_enemy2_y, enemyRadius, speed_enemy2_x, speed_enemy2_y, x_pos, y_pos, boxTop, boxRight, boxBottom, boxLeft, 
                    oldsceneMain, enemy2_x, enemy2_y, hitEnemy2);
    
        // rgb buffer (color)
        always @(posedge p_tick)
        //main character
        begin
        if (64 > (x-x_pos)**2 + (y-y_pos)**2)
            rgb_reg <= 12'hF00;
        //enemy1
        else if (25 > (x-enemy1_x)**2 + (y-enemy1_y)**2 && hitEnemy1 == 0)
            rgb_reg <= 12'hFFF;
        //enemy2
        else if (25 > (x-enemy2_x)**2 + (y-enemy2_y)**2 && hitEnemy2 == 0)
            rgb_reg <= 12'h0F0;
        
        //box
        else if (boxLeft <= x && x <= boxRight && boxTop <= y && y <= boxBottom)
            rgb_reg <= 12'h000;
        else if (boxLeft - boxThick <= x && x <= boxRight + boxThick && boxTop - boxThick <= y && y <= boxBottom + boxThick)
            rgb_reg <= 12'hFFF;
        //draw H
        else if (400 <= y && y <= 410 && boxLeft - boxThick <= x && x <= boxLeft - boxThick + 2)
            rgb_reg <= 12'hFFF;
        else if (400 <= y && y <= 410 && boxLeft - boxThick + 6 <= x && x <= boxLeft - boxThick + 8)
            rgb_reg <= 12'hFFF;
        else if (404 <= y && y <= 406 && boxLeft - boxThick <= x && x <= boxLeft - boxThick + 8)
            rgb_reg <= 12'hFFF;
        // draw P
        else if (400 <= y && y <= 410 && boxLeft - boxThick + 12 <= x && x <= boxLeft - boxThick + 14)
            rgb_reg <= 12'hFFF;
        else if (x>=boxLeft - boxThick + 14 && 4 >= ((x-(boxLeft - boxThick + 14))**2 + (y-403)**2))
            rgb_reg <= 12'h000;
        else if (x>=boxLeft - boxThick + 14 && 16 >= ((x-(boxLeft - boxThick + 14))**2 + (y-403)**2))
            rgb_reg <= 12'hFFF;
        // health bar    
        else if (400 <= y && y <= 410 && boxLeft - boxThick + 25 <= x && x <= boxRight - healthBar)
            rgb_reg <= 12'hFF0;
        else
            rgb_reg <= 0;
        end
        //newpic oscillator
        always @(posedge p_tick)
        if (x==0 && y==0)
            newpic=1;
        else
            newpic=0;
        
        
        //move
        always @(posedge newpic)
        begin
        if(oldsceneMain != newscene)
        begin
            x_pos <= 320;
            y_pos <= 240;
            oldsceneMain <= newscene;
        end
        if (direc==1 && y_pos>=boxTop + mainRadius)
            y_pos=y_pos-3;
        else if (direc==2 && x_pos>=boxLeft + mainRadius)
            x_pos=x_pos-3;
        else if (direc==3 && y_pos<=boxBottom - mainRadius)
            y_pos=y_pos+3;
        else if (direc==4 && x_pos<=boxRight - mainRadius)
            x_pos=x_pos+3;
        end
        
        //UART
        always @(posedge clk)
            begin
            if (newpic==1 && direc!=0) direc=0;
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin direc=1; TxData="W"; end
                "a": begin direc=2; TxData="A"; end
                "s": begin direc=3; TxData="S"; end
                "d": begin direc=4; TxData="D"; end
                default: begin TxData=""; end
                endcase 
                transmit = 1;
                counter = 0;
                end
            else if (transmit==1 && counter<=10415)
                counter=counter+1;
            else
                begin
                transmit = 0;
                end
            end
            
            always @(posedge hitEnemy2)
            begin
                newHealth <= newHealth-1;
            end       
            
endmodule