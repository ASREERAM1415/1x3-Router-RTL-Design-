`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2024 22:09:56
// Design Name: 
// Module Name: register_router
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


module register_router(input clk,rst,pkt_vld, fifo_full,rst_int_reg,detect_add,ld_state,laf_state,lfd_state,
                       full_state,input [7:0] data_in, output reg low_pkt_vld, parity_done, errr, 
                       output reg [7:0] d_out);
    reg [7:0] headder, full_state_data, int_parity, packet_parity;                           
    
    always @ (posedge clk)
    begin
        if(~rst)
        begin
            d_out <= 8'b0;
            headder <= 0;
            full_state_data <= 0;
        end
        else 
        begin
            if(pkt_vld && detect_add)
                headder <= data_in;
            else if(lfd_state)
                 d_out <= headder;
            else if(ld_state && ~fifo_full)
                d_out <= data_in;
            else if(ld_state && fifo_full)
                full_state_data <= data_in;
            else 
            begin
                if(laf_state)
                d_out <= full_state_data;
            end
        end
    end
    
    always @ (posedge clk)
    begin
        if(~rst)
            low_pkt_vld <= 0;
        else
        begin
            if(rst_int_reg)
                low_pkt_vld<=0;
            if(ld_state && ~pkt_vld)
                low_pkt_vld <=1'b1;
        end
    end
    
    always@(posedge clk)
    begin
        if(!rst)
            parity_done<=1'b0;
        else
        begin
            if(ld_state && !fifo_full && !pkt_vld)
                parity_done<=1'b1;
            else if(laf_state && low_pkt_vld && !parity_done)
                parity_done<=1'b1;
            else
            begin
                if(detect_add)
                parity_done<=1'b0;
            end
        end
    end
    
    always @ (posedge clk)
    begin
        if(!rst)
            int_parity <= 8'b0;
        else if(lfd_state)
            int_parity <= int_parity ^ headder;
        else if(ld_state && pkt_vld && !full_state)
            int_parity <= int_parity ^ data_in;
        else
        begin
            if (detect_add)
                int_parity <= 8'b0;
            else
                int_parity <= int_parity;
        end
    end
    
    always @ (posedge clk)
    begin
        if(!rst)
            packet_parity <= 8'b0;
        else if ((ld_state && ~pkt_vld && ~fifo_full) || (laf_state && low_pkt_vld && ~parity_done))
            packet_parity <= data_in;
        else if (~pkt_vld && rst_int_reg)
            packet_parity <= 0;
        else
        begin
            if (detect_add)
            packet_parity <= 0;
        end
    end
    
    always @ (posedge clk)
    begin
        if(!rst || detect_add)
            errr <= 1'b0;
        else
        begin
            if(parity_done)
            begin
                if(int_parity!=packet_parity)
                    errr <= 1'b1;
            end
            else
                errr <= 1'b0;
        end
    end

endmodule
