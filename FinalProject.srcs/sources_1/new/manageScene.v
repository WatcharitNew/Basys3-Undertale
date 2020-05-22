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
	wire [11:0] rgb_reg_cred;
	wire [11:0] rgb_reg_menu;
	
	// for multiplexing RsTx from multiple scene
	reg RsTx_reg;
	wire RsTx_ats, RsTx_menu;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    
    //p_tick
    wire p_tick;
    vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
    
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
    
    reg [2:0] changeScene;
    reg newScene_ats;
    
    //scene
    reg onScene_ats;
    reg onScene_credit;
    reg onScene_menu;
    
    //health
    wire [9:0] maxHealth=6;
    wire [9:0] newHealth;
    reg [1:0] crdTime;
    // move
    reg [2:0]direc;
    //tell whether this is a new picture
    reg newpic;
    
    //menu scene state
    reg [1:0] selectedMenu;
    reg isSelect;
    
    initial begin
        changeScene = 0;
        newScene_ats = 0;
        rgb_reg = rgb_reg_ats;
        crdTime = 0;
        direc = 0;
        selectedMenu = 0;
        isSelect = 0;
        onScene_ats = 0;
        onScene_credit = 1;
        onScene_menu = 0;
    end
    
    //clk
    wire atsClk, targetClk, crdClk;
    wire [30:0] tclk;
    assign tclk[0] = (onScene_ats || onScene_credit==1)?clk:0;
    genvar c;
    generate for(c=0;c<30;c=c+1)
    begin 
        ClockDivider fdiv2(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget2(atsClk,tclk[28]);
    ClockDivider fdivTarget3(crdClk,tclk[30]);
    ClockDivider fdivTarget(targetClk,tclk[18]);
    
    //newpic oscillator
    always @(posedge p_tick)
    begin
        if (x==0 && y==0)
            newpic=1;
        else
            newpic=0;
    end
    
    always @(posedge clk)
    begin
        if (newpic==1 && direc!=0) begin
            direc=0;
            isSelect=0;
        end
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin if(onScene_ats) direc=1; TxData="W"; end
                "a": begin if(onScene_ats) direc=2; if(onScene_menu) selectedMenu <= selectedMenu+1;TxData="A"; end
                "s": begin if(onScene_ats) direc=3; TxData="S"; end
                "d": begin if(onScene_ats) direc=4; if(onScene_menu) selectedMenu <= selectedMenu-1;TxData="D"; end
                " ": begin
                    isSelect=1;
                    TxData = "z";
                end
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
    
    
    afterTurnScene ats(clk, video_on, p_tick, x, y, newScene_ats, maxHealth, newpic, direc, targetClk, rgb_reg_ats, newHealth);
    loadingScene ls(clk,video_on, p_tick, x, y, rgb_reg_ls);
    gameOver go(clk,video_on, p_tick, x, y, rgb_reg_go);
    creditScene cred(clk, video_on, p_tick, x, y, rgb_reg_cred);
    menuScene menu(clk, video_on, p_tick, x, y, newpic, selectedMenu, rgb_reg_menu);
    
    
    
    always @(posedge clk)
    begin
        if (onScene_credit) rgb_reg = rgb_reg_cred;
        else if(changeScene == 1)  rgb_reg = rgb_reg_ls;
        else if (onScene_ats)   rgb_reg = rgb_reg_ats;
        else if (onScene_menu) rgb_reg = rgb_reg_menu;
    end
    
    wire isDie = (newHealth <= 1);
    
    always @(posedge atsClk or posedge isDie or posedge isSelect or posedge crdClk)
    begin
        if(isDie) begin onScene_ats=0; onScene_menu=1; end 
        else if(isSelect && onScene_menu) begin onScene_ats = 1; onScene_menu=0;end
        else if (onScene_credit && crdClk) 
        begin 
            onScene_credit = 0;
            onScene_menu = 1;
            changeScene = 4; 
        end
        //else if (changeScene == 1) begin changeScene = 2; end
        else if (onScene_ats) begin onScene_ats = 0; onScene_menu=1; end
    end
    
    // output
    assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
    assign RsTx = RsTx_reg;
endmodule
