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
        
    wire atsClk;
    wire [28:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<28;c=c+1)
    begin 
        ClockDivider fdiv2(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget2(atsClk,tclk[28]);
    
    reg [2:0] changeScene;
    reg newScene_ats;
    
    reg [1:0] stateScene_ats;
    reg [1:0] stateScene_ls;
    reg [1:0] stateScene_cred;
    
    reg [1:0] nextStateScene_ats;
    reg [1:0] nextStateScene_ls;
    reg [1:0] nextStateScene_cred;
    
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
    reg menuGo, menuWent;
    
    initial begin
        changeScene = 0;
        newScene_ats = 1;
        stateScene_ats = 0;
        stateScene_ls = 0;
        rgb_reg = rgb_reg_ats;
        crdTime = 0;
        direc = 0;
        selectedMenu = 0;
        menuGo = 0;
        menuWent = 0;
    end
    
    
    
    
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
        if (menuGo == 1 && menuWent == 1) menuGo <= 0;
        if (newpic==1 && direc!=0) direc=0;
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin direc=1; TxData="W"; end
                "a": begin direc=2; selectedMenu <= selectedMenu+1;TxData="A"; end
                "s": begin direc=3; TxData="S"; end
                "d": begin direc=4; selectedMenu <= selectedMenu-1;TxData="D"; end
                " ": begin
                    TxData="z";
                    if (menuGo == 0) menuGo <= 1;
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
    
    
    
    afterTurnScene ats(clk, video_on, p_tick, x, y, newScene_ats, maxHealth, newpic, direc, rgb_reg_ats, newHealth);
    loadingScene ls(clk,video_on, p_tick, x, y, rgb_reg_ls);
    gameOver go(clk,video_on, p_tick, x, y, rgb_reg_go);
    creditScene cred(clk, video_on, p_tick, x, y, rgb_reg_cred);
    menuScene menu(clk, video_on, p_tick, x, y, newpic, selectedMenu, rgb_reg_menu);
    
    
    
    always @(posedge clk)
    begin
        if (changeScene == 0) rgb_reg = rgb_reg_cred;
        else if(changeScene == 1)  rgb_reg = rgb_reg_ls;
        else if (changeScene == 2)   rgb_reg = rgb_reg_ats;
        else if(changeScene == 3) rgb_reg = rgb_reg_go;
        else if (changeScene == 4) rgb_reg = rgb_reg_menu;
        
        
        
    end
    
    wire isDie = (newHealth <= 1);
    
    always @(posedge atsClk or posedge isDie or posedge menuGo)
    begin
        if(isDie) begin changeScene = 3; end 
//        else if(changeScene == 0) begin newScene_ats <= ~newScene_ats; changeScene = 1; end
        else if (changeScene == 0) 
        begin 
            crdTime <= crdTime + 1;
            if(crdTime == 2)
                changeScene = 4; 
        end
        else if (changeScene == 1) begin changeScene = 2; end
        else if (changeScene == 2) begin newScene_ats <= ~newScene_ats; changeScene = 4; end
        else if (changeScene == 4) begin
               if (menuGo == 1) begin 
                    if (menuWent == 1) menuWent <= 0;
                    case (selectedMenu)
                        0: changeScene <= 1;
                        1: changeScene <= 1;
                        2: changeScene <= 1;
                        3: changeScene <= 1;
                    endcase
                    menuWent <= 1;
               end
        end
    end
    
    // output
    assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
    assign RsTx = RsTx_reg;
endmodule
