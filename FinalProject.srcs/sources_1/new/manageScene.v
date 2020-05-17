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
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    
    //p_tick
    wire p_tick;
    vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
        
    wire atsClk;
    wire [28:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<28;c=c+1)
    begin 
        ClockDivider fdiv2(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget2(atsClk,tclk[28]);
    
    reg changeScene;
    reg newScene_ats;
    reg newScene_ls;
    
    reg [1:0] stateScene_ats;
    reg [1:0] stateScene_ls;
    
    reg [1:0] nextStateScene_ats;
    reg [1:0] nextStateScene_ls;
    
    afterTurnScene ats(clk, video_on, p_tick, x, y, RsRx, newScene_ats, rgb_reg_ats, RsTx);
    loadingScene ls(clk,video_on, p_tick, x, y, newScene_ls, rgb_reg_ls);
    
    // text generator
    wire text1;
    Pixel_On_Text2 #(.displayText("Pixel_On_Text2 -- test1 at (220,420)")) t1(
                clk,
                220, // text position.x (top left)
                420, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text1  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    initial begin
        changeScene = 0;
        newScene_ats = 0;
        newScene_ls = 0;
        stateScene_ats = 0;
        stateScene_ls = 0;
        rgb_reg = rgb_reg_ats;
    end
    
    always @*
    begin
//        primary -> after turn scene
//        secondary -> loading scene
//        rgb_reg = (rgb_reg_ats != 12'b0) ? rgb_reg_ats : rgb_reg_ls;
        rgb_reg = (text1 == 1) ? 12'hFFF : 12'b0;
    end
    
    always @(posedge atsClk)
    begin
        if(changeScene == 0) begin newScene_ats <= ~newScene_ats; changeScene = 1; end
        else begin newScene_ls <= ~newScene_ls; changeScene = 0; end
    end
    
    // output
    assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule
