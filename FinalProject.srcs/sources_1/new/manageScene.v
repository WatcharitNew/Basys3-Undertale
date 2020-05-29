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
	wire [11:0] rgb_reg_act;
	wire [11:0] rgb_reg_spare;
	wire [11:0] rgb_reg_fight;
	
	wire [11:0] rgb_reg_spare_fail;
	wire [11:0] rgb_reg_spare_complete;
	
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
    
    reg newScene_ats;
    
    //scene
    reg onScene_ats;
    reg onScene_credit;
    reg onScene_menu;
    reg onScene_act;
    reg onScene_spare;
    reg onScene_fight;
    reg onScene_go;
    
    //health
    wire [9:0] maxHealth=6;
    wire [9:0] newHealth;
    
    //enemy health
    wire [9:0] maxEnemyHealth=6;
    wire [9:0] newEnemyHealth;
    
    // move
    reg [2:0]direc;
    //tell whether this is a new picture
    reg newpic;
    
    //menu scene state
    reg [1:0] selectedMenu;
    reg isSelect;
    reg [1:0] crdClk;
    
    //act-spare state
    reg acted;
    
    //stop gauge button
    reg stop;
    
    initial begin
        newScene_ats = 0;
        rgb_reg = rgb_reg_ats;
        direc = 0;
        selectedMenu = 0;
        isSelect = 0;
        onScene_ats = 0;
        onScene_credit = 1;
        onScene_menu = 0;
        onScene_act = 0;
        onScene_spare = 0;
        onScene_fight = 0;
        acted = 0;
        stop = 0;
        crdClk = 0;
        //newEnemyHealth = 6;
    end
    
    //clk
    wire atsClk, targetClk;
    wire [30:0] tclk;
    assign tclk[0] = ((onScene_ats || onScene_credit || onScene_act || onScene_spare || onScene_fight)==1)?clk:0;
    genvar c;
    generate for(c=0;c<30;c=c+1)
    begin 
        ClockDivider fdiv2(tclk[c+1],tclk[c]);
    end endgenerate
    ClockDivider fdivTarget2(atsClk,tclk[28]);
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
        if (newpic==1) begin
            if (direc!=0) direc=0;
            if (isSelect==1 && onScene_menu)
            begin
                case (selectedMenu)
                    0: begin
                        //if (newEnemyHealth > 1) newEnemyHealth <= newEnemyHealth -1;
                    end
                endcase
            end
            isSelect = 0;
        end
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin if(onScene_ats) direc=1; if(onScene_fight) stop<=1; TxData="W"; end
                "a": begin if(onScene_ats) direc=2; if(onScene_menu) selectedMenu <= selectedMenu+1;TxData="A"; end
                "s": begin if(onScene_ats) direc=3; TxData="S"; end
                "d": begin if(onScene_ats) direc=4; if(onScene_menu) selectedMenu <= selectedMenu-1;TxData="D"; end
                " ": begin
                    if(onScene_menu) isSelect=1;
                    if (selectedMenu != 2) isSelect=1;
                    if (selectedMenu == 1) acted = 1;
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
    
    
    afterTurnScene ats(clk, video_on, p_tick, x, y, onScene_ats, maxHealth, newpic, direc, targetClk, maxEnemyHealth, newEnemyHealth, rgb_reg_ats, newHealth);
    loadingScene ls(clk,video_on, p_tick, x, y, rgb_reg_ls);
    gameOver go(clk,video_on, p_tick, x, y, rgb_reg_go);
    creditScene cred(clk, video_on, p_tick, x, y, rgb_reg_cred);
    menuScene menu(clk, video_on, p_tick, x, y, newpic, selectedMenu, maxHealth,newHealth, maxEnemyHealth, newEnemyHealth,rgb_reg_menu);
    actScene act(clk, video_on, p_tick, x, y, rgb_reg_act);
    fightScene fight(clk, video_on, p_tick, x, y, stop, newpic, onScene_fight, targetClk, maxHealth, maxEnemyHealth, newHealth, rgb_reg_fight, newEnemyHealth);
    spareScene spare(clk, video_on, p_tick, x, y, rgb_reg_spare_fail, rgb_reg_spare_complete);
    
    always @(posedge clk)
    begin
        if (onScene_credit) rgb_reg = rgb_reg_cred;
        else if (onScene_menu) rgb_reg = rgb_reg_menu;
        else if (onScene_ats) rgb_reg = rgb_reg_ats;
        else if (onScene_act) rgb_reg = rgb_reg_act;
        else if (onScene_spare) rgb_reg = rgb_reg_spare;
        //else if (onScene_fight) rgb_reg = rgb_reg_fight;
        else if (onScene_spare && !acted) rgb_reg = rgb_reg_spare_fail;
        else if (onScene_spare && acted) rgb_reg = rgb_reg_spare_complete;
        else if (onScene_go) rgb_reg = rgb_reg_go;
    end
    
    wire isDie = (newHealth <= 1);
    wire isWon = (newEnemyHealth <= 1);
    
    always @(posedge atsClk or posedge isDie or posedge isSelect or posedge isWon)
    begin
        if (isDie) begin onScene_ats=0; onScene_menu=0; onScene_go=1; end
        else if (isWon) begin onScene_ats=0; onScene_menu=0; onScene_go=1; end 
        else if (isSelect) 
        begin 
            if(onScene_menu) 
            begin
                onScene_menu=0;
                case (selectedMenu)
                    0: begin
                        onScene_fight <= 1;
                        onScene_spare <= 0;
                        onScene_ats <= 0;
                        onScene_act <= 0;
                    end
                    1: begin
                        onScene_fight <= 0;
                        onScene_spare <= 0;
                        onScene_ats <= 0;
                        onScene_act <= 1;
                    end
                    2: begin
                        onScene_fight <= 0;
                        onScene_spare <= 0;
                        onScene_ats <= 1;
                        onScene_act <= 0;
                    end
                    3: begin
                        onScene_fight <= 0;
                        onScene_spare <= 1;
                        onScene_ats <= 0;
                        onScene_act <= 0;
                    end
                endcase
            end 
        end
        else if (onScene_credit) 
        begin 
            crdClk <= crdClk + 1;
            if(crdClk == 2)
            begin
                onScene_credit = 0;
                onScene_menu = 1;
            end 
        end
        else if (onScene_ats) begin
            onScene_ats = 0;
            onScene_menu=1;
        end
        else if (onScene_spare) begin
            onScene_spare <= 0;
            if (!acted) onScene_ats <= 1;
            else onScene_go <= 1;
        end
        else if (onScene_act) begin
            onScene_act <= 0;
            onScene_ats <= 1;
        end
    end
    
    // output
    assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
    assign RsTx = RsTx_reg;
endmodule
