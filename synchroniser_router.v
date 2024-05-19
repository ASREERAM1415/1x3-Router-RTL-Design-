`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2024 21:53:39
// Design Name: 
// Module Name: synchroniser_router
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


module synchroniser_router(
    input clk,
    input rst,
    input [1:0] data_in,
    input detect_add,
    input wr_en_reg,
    input [2:0] full,
    input [2:0] empty,
    input [2:0] rd_en,
    output reg [2:0] wr_en_out,
    output reg [2:0] sft_rst,
    output [2:0] vld_out,
    output reg fifo_full
    );
    reg [4:0]timer[2:0];
    reg [1:0]int_addr_reg;
    integer i;
    always @(posedge clk)
    begin
        for(i=0;i<=2;i=i+1)
        begin
            if(!rst)
            begin
                timer[i] <= 5'b0;
                sft_rst[i] <= 1'b0;
            end
            else if(vld_out[i] ==1'b1)
            begin
                if(rd_en[i] != 1'b1)
                begin
                    if(timer[i] == 29)
                    begin
                        sft_rst[i] <= 1'b1;
                        timer[i] <= 5'b0;
                    end
                    else
                    begin
                        sft_rst[i] <= 1'b0;
                        timer[i] <= timer[i] + 1;
                    end
                end
            end
        end
    end
    
    always @(posedge clk)
    begin
        if(!rst)
            int_addr_reg <= 2'b11;
        else if (detect_add)
            int_addr_reg <= data_in;
    end
    
    always @(posedge clk)
    begin
        wr_en_out <= 3'b0;
        if(!rst)
            wr_en_out <= 3'b0;
        else if (wr_en_reg)
        begin
            case(int_addr_reg)
                2'b00 : wr_en_out <= 3'b001;
                2'b01 : wr_en_out <= 3'b010;
                2'b10 : wr_en_out <= 3'b100;
                default : wr_en_out <= 3'b000;
            endcase
        end
    end
    
    always @(posedge clk)
    begin
        if(!rst)
            fifo_full <= 1'b0;
        else
        begin
            case(int_addr_reg)
                2'b00 : fifo_full <= full[0];
                2'b01 : fifo_full <= full[1];
                2'b10 : fifo_full <= full[2];
                default : fifo_full <= 1'b0;
            endcase
        end
    end
    
    assign vld_out = ~ empty;
endmodule
