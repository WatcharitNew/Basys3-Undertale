`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2020 08:23:26 PM
// Design Name: 
// Module Name: manageScene
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


module manageScene(
        input wire clk, reset,
		input wire RsRx,
		output wire Hsync, Vsync,
		output wire [3:0] vgaRed,
		output wire [3:0] vgaGreen,
		output wire [3:0] vgaBlue,
		output wire RsTx
    );
    
    // register for Basys 2 8-bit RGB DAC {4R,4G,4B}
	reg [11:0] rgb_reg;
	wire [11:0] rgb_reg_ats;
	wire [11:0] rgb_reg_ls;
	wire [11:0] rgb_reg_go;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    
    //p_tick
    wire p_tick;
    vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
    
   /* //Receiver
    wire [7:0]RxData;
    wire state;
    wire nextstate;
    receiver receiver_unit(RxData, state, nextstate, clk, 0, RsRx);
    
    //Transmitter
    reg [7:0]TxData;
    reg transmit;
    reg [15:0]counter;
    transmitter(RsTx, clk, 0, transmit, TxData);*/
        
    wire atsClk;
    wire [28:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<28;c=c+1)
    begin 
        ClockDivider fdiv2(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget2(atsClk,tclk[28]);
    
    reg [1:0] changeScene;
    reg newScene_ats;
    reg newScene_ls;
    
    reg [1:0] stateScene_ats;
    reg [1:0] stateScene_ls;
    
    reg [1:0] nextStateScene_ats;
    reg [1:0] nextStateScene_ls;
    
    //health
    wire [9:0] maxHealth=6;
    wire [9:0] newHealth;
    
    initial begin
        changeScene = 0;
        newScene_ats = 1;
        newScene_ls = 1;
        stateScene_ats = 0;
        stateScene_ls = 0;
        rgb_reg = rgb_reg_ats;
    end
    
    afterTurnScene ats(clk, video_on, p_tick, x, y, RsRx, newScene_ats, maxHealth, rgb_reg_ats, RsTx, newHealth);
    loadingScene ls(clk,video_on, p_tick, x, y, newScene_ls, rgb_reg_ls);
    gameOver go(clk,video_on, p_tick, x, y, rgb_reg_go);
    
    always @*
    begin
        if (changeScene == 0)   rgb_reg = rgb_reg_ats;
        else if(changeScene == 1)  rgb_reg = rgb_reg_ls;
        else if(changeScene == 2) rgb_reg = rgb_reg_go;
    end
    
    wire isDie = (newHealth <= 1);
    always @(posedge atsClk or posedge isDie)
    begin
        if(isDie) begin changeScene = 2; end 
        else if(changeScene == 0) begin newScene_ats <= ~newScene_ats; changeScene = 1; end
        else begin newScene_ls <= ~newScene_ls; changeScene = 0; end
    end
    
    // output
    assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule
