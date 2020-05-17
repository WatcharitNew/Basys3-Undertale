`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2020 07:22:27 PM
// Design Name: 
// Module Name: blackScene
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


module loadingScene
	(
	    input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		input wire newscene,
		output reg [11:0] rgb_reg
	);
	
    //tell whether this is a new picture
    reg newpic;
    reg [9:0] loadingBar;
    //clock
    wire targetClk;
    wire [26:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<26;c=c+1)
    begin 
        ClockDivider fdiv(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget(targetClk,tclk[26]);

    reg oldscene;
    initial begin
        loadingBar = 0;
        oldscene = 0;
    end
    
    // rgb buffer (color)
    always @(posedge p_tick)
    //main character
    begin
        if (400 <= y && y <= 410 && 220 <= x && x <= 220 + loadingBar)
            rgb_reg <= 12'h0F0;
        else
        rgb_reg <= 12'h000;
    end    
    
    always @(posedge targetClk)
    begin
        if(oldscene != newscene)
        begin
            loadingBar <= 0;
            oldscene <= newscene;
        end
        if(loadingBar > 200)    loadingBar <= 0;
        else loadingBar <= loadingBar + 40;
    end
endmodule
