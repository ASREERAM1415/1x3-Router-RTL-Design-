`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2024 13:50:31
// Design Name: 
// Module Name: router_top
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


module router_top(input clk,rst,pkt_valid,input [2:0] rd_en,input [7:0] data_in,
                  output [2:0]vld_out, output errr,busy,output [7:0] data_out_0,data_out_1,data_out_2);
    
    wire low_pkt_vld;
    wire [2:0] wr_en_out, sft_rst,full,empty;
    wire [7:0] d_out;
    
    router_fsm fsm_dut(clk,rst,pkt_valid,parity_done,data_in[1:0],sft_rst[0],sft_rst[1],
                        sft_rst[2],fifo_full,low_pkt_vld,empty[0],empty[1],empty[2],
                        detect_add,ld_state,laf_state,full_state,wr_en_reg,rst_int_reg,lfd_state,busy);

    synchroniser_router sync_dut(clk,rst,data_in[1:0],detect_add,wr_en_reg,full,empty,rd_en,
                                 wr_en_out,sft_rst,vld_out,fifo_full);
                                 
    register_router reg_dut(clk,rst,pkt_valid, fifo_full,rst_int_reg,detect_add,ld_state,laf_state,lfd_state,
                            full_state,data_in,low_pkt_vld, parity_done, errr, d_out);
                            
    fifo_router f0(clk,rst,wr_en_out[0],rd_en[0],d_out,lfd_state,sft_rst[0],full[0],empty[0],data_out_0);
    fifo_router f1(clk,rst,wr_en_out[1],rd_en[1],d_out,lfd_state,sft_rst[1],full[1],empty[1],data_out_1);
    fifo_router f2(clk,rst,wr_en_out[2],rd_en[2],d_out,lfd_state,sft_rst[2],full[2],empty[2],data_out_2);
endmodule
