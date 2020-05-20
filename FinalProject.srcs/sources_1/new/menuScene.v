`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2020 02:56:02 AM
// Design Name: 
// Module Name: menuScene
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


module menuScene
	(
		input wire clk,
		input wire video_on,
		input wire p_tick, 
		input wire [9:0] x,y,
		input wire RsRx,
		output reg [1:0] selectedMenu,
		output reg [11:0] rgb_reg,
		output wire RsTx
	);


    
    //multiplexed heart (current menu)
    reg currentHeart;
    
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
        



    //scene
    reg oldsceneMain;

    
    initial
    begin
        selectedMenu = 0;
    end

    
    wire heart1, heart2, heart3, heart4,
        text_pixel_fight, text_pixel_act, text_pixel_spare, text_pixel_item;
    
    //init text
    Pixel_On_Text2 #(.displayText("fight")) fight(
                clk,
                80, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_fight  // result, 1 if current pixel is on text, 0 otherwise
            );
    
    Pixel_On_Text2 #(.displayText("act")) act(
                clk,
                240, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_act  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("item")) item(
                clk,
                420, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_item  // result, 1 if current pixel is on text, 0 otherwise
            );
            
    Pixel_On_Text2 #(.displayText("spare")) spare(
                clk,
                600, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                text_pixel_spare  // result, 1 if current pixel is on text, 0 otherwise
            );
       
    Pixel_On_Text2 #(.displayText("|")) h1(
                clk,
                70, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart1  // result, 1 if current pixel is on text, 0 otherwise
            );
       
     Pixel_On_Text2 #(.displayText("|")) h2(
                clk,
                230, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart2  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("|")) h3(
                clk,
                410, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart3  // result, 1 if current pixel is on text, 0 otherwise
            );
            
     Pixel_On_Text2 #(.displayText("|")) h4(
                clk,
                590, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                heart4  // result, 1 if current pixel is on text, 0 otherwise
            );
    
        // rgb buffer (color)
        always @(posedge p_tick)
        //main character
        begin
        
        if (selectedMenu == 0) currentHeart = heart1;
        else if (selectedMenu == 1) currentHeart = heart2;
        else if (selectedMenu == 2) currentHeart = heart3;
        else if (selectedMenu == 3) currentHeart = heart4;
        
        if (currentHeart == 1)
            rgb_reg <= 12'hF00;
        else if (text_pixel_fight == 1 | text_pixel_act == 1 | text_pixel_item == 1 | text_pixel_spare == 1)
            rgb_reg <= 12'hFFF;
        else
            rgb_reg <= 12'b0;
        end
        


        //newpic oscillator
        always @(posedge p_tick)
        if (x==0 && y==0)
            newpic=1;
        else
            newpic=0;
        
        //UART
        always @(posedge clk)
            begin
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "a": begin selectedMenu = selectedMenu+1; TxData="A"; end
                "d": begin selectedMenu = selectedMenu-1; TxData="D"; end
                default: begin TxData=RxData; end
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
            
endmodule
