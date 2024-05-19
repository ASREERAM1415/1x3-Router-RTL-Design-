`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2024 08:06:27
// Design Name: 
// Module Name: fifo_router
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


module fifo_router(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [7:0] wr_data,
    input lfd_stat,
    input sft_rst,
    output full,
    output empty,
    output reg [7:0] data_out
    );
    integer i;
    reg lfd_temp;
    reg [4:0]wr_ptr;
    reg [4:0]rd_ptr;
    reg [8:0]mem[15:0];
    reg [7:0]fifo_cntr;
    
    always@(posedge clk)
    begin
    if(!rst)
        lfd_temp <= 0;
    else
        lfd_temp <= lfd_stat;
    end
    
        
    
    always@(posedge clk)
    begin
        if(!rst || sft_rst)
        begin
        for(i=0;i<=15;i=i+1)
            mem[i] <= 8'b0;
        end
        else
        begin
            if(wr_en && !full)
            begin
                mem[wr_ptr[3:0]] <= {lfd_temp,wr_data};
            end
        end
    end
    
    always@(posedge clk)
    begin
        if(!rst || sft_rst)
            fifo_cntr <= 8'b0;
        else if(rd_en && ! empty)
        begin
            if(mem[rd_ptr][8] == 1'b1)           
                fifo_cntr <= mem[rd_ptr][7:2] + 1'b1;
            else if(fifo_cntr != 0)
                fifo_cntr <= fifo_cntr - 1'b1;
        end
    end
    
    always@(posedge clk)
    begin
        if(!rst)
            data_out <= 8'b0;
        else if(sft_rst)
            data_out <= 8'bz;  
        else
        begin
            if(fifo_cntr == 0 && data_out != 0)
                data_out <= 8'bz;
            else if(rd_en && !empty)
                data_out <= mem[rd_ptr[3:0]];
        end
    end
    
    always@(posedge clk)
    begin
        if(!rst || sft_rst)
        begin    
            wr_ptr <= 5'b0;
            rd_ptr <= 5'b0;
        end
        else
        begin
            if(!full && wr_en)
                wr_ptr <= wr_ptr + 1'b1;
            else
                wr_ptr <= wr_ptr;
            if(!empty && rd_en)
                rd_ptr <= rd_ptr + 1'b1;
            else
                rd_ptr <= rd_ptr;
        end
    end  
        
        assign  full = (wr_ptr[4:0] == {~rd_ptr[4],rd_ptr[3:0]})?1'b1:1'b0;
        assign  empty = (wr_ptr[4:0] == rd_ptr[4:0])?1'b1:1'b0;   
endmodule
