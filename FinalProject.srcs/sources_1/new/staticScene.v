`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2020 10:45:52 PM
// Design Name: 
// Module Name: staticScene
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


module staticScene(
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
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    reg [9:0] x_pos,y_pos,mainRadius,boxLeft,boxRight,boxTop,boxBottom,boxThick,health,maxHealth;
    // move
    reg [2:0]direc;
    //color
    reg [1:0]color;
    //p_tick
    wire p_tick;
    //tell whether this is a new picture
    reg newpic;
    
        // instantiate vga_sync
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
        
        //clock
        wire targetClk;
        wire [18:0] tclk;
        assign tclk[0]=clk;
        genvar c;
        generate for(c=0;c<18;c=c+1)
        begin 
            ClockDivider fdiv(tclk[c+1],tclk[c]);
        end endgenerate
        ClockDivider fdivTarget(targetClk,tclk[18]);
        
        //initialize
        wire [9:0] healthBar = (maxHealth - health)*36;
        initial
        begin
            transmit = 0;
            counter = 0;
            direc = 0;
            color = 3;
            x_pos = 320;
            y_pos = 240;      
            boxLeft = 220;
            boxRight = 420;
            boxTop = 140;
            boxBottom = 340;
            boxThick = 5;
        end
        // rgb buffer (color)
        always @(posedge p_tick, posedge reset)
        //main character
        begin
        if ( reset || (64 > (x-x_pos)**2 + (y-y_pos)**2))
            rgb_reg <= 12'hF00;
        //box
        else if (boxLeft <= x && x <= boxRight && boxTop <= y && y <= boxBottom)
            rgb_reg <= 12'h000;
        else if (boxLeft - boxThick <= x && x <= boxRight + boxThick && boxTop - boxThick <= y && y <= boxBottom + boxThick)
            rgb_reg <= 12'hFFF;
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
            
        // output
        assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule
