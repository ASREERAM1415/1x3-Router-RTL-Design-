`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2024 17:42:20
// Design Name: 
// Module Name: router_top_tb
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


module router_top_tb();
    reg clk,rst,pkt_valid;
    reg [2:0] rd_en;
    reg[7:0] data_in;
    wire [2:0]vld_out;
    wire errr,busy;
    wire [7:0] data_out_0,data_out_1,data_out_2;
    
    reg [7:0] headder,payload_data, payload_parity;
    reg [5:0] packet_len;
    reg [1:0] addr;
    
    integer i;
    
    router_top router_top_dut(clk,rst,pkt_valid,rd_en,data_in,vld_out,errr,busy,data_out_0,data_out_1,data_out_2);
    
    initial
    begin
        rst = 1'b0;
        pkt_valid = 1'b0;
        rd_en = 3'b0;
        data_in = 8'b0;
    end
    
    initial 
    begin
        clk = 1;
        forever
        #5 clk=~clk;
    end 
    
    task clr_rd_en;
        rd_en = 3'b0;
    endtask
    
    task rst_in;
    begin
        @(negedge clk) rst=1'b0;
        @(negedge clk) rst=1'b1;
    end
    endtask
    
    task p_8;
    begin
        payload_parity = 0;
        wait(!busy)
        begin
            packet_len = 6'd8;
            addr = 2'b00;
            headder = {packet_len,addr};
            @(negedge clk)
            data_in = headder;
            payload_parity = payload_parity ^ data_in;
            pkt_valid = 1;
        end
        @(negedge clk);
        for(i=0;i<packet_len;i=i+1)
        begin
            wait(!busy)
            @(negedge clk)
            payload_data={$random}%256;
            data_in=payload_data;
            payload_parity = payload_parity ^ data_in;
        end
        wait(!busy)
        @(negedge clk) data_in=payload_parity;
        pkt_valid=0;
        #10;
        rd_en[0] = 1'b1;
    end
    endtask
    
    task p_14;
    begin
        payload_parity = 0;
        wait(!busy)
        begin
            packet_len = 6'd14;
            addr = 2'b01;
            headder = {packet_len,addr};
            @(negedge clk)
            data_in = headder;
            payload_parity = payload_parity ^ data_in;
            pkt_valid = 1;
        end
        @(negedge clk);
        for(i=0;i<packet_len;i=i+1)
        begin
            wait(!busy)
            @(negedge clk)
            payload_data={$random}%256;
            data_in=payload_data;
            payload_parity = payload_parity ^ data_in;
        end
        wait(!busy)
        @(negedge clk) data_in=payload_parity;
        pkt_valid=0;
        #10;
        rd_en[1] = 1'b1;
    end
    endtask
    
    task p_17;
    begin
        payload_parity = 0;
        wait(!busy)
        begin
            packet_len = 6'd17;
            addr = 2'b10;
            headder = {packet_len,addr};
            @(negedge clk)
            data_in = headder;
            payload_parity = payload_parity ^ data_in;
            pkt_valid = 1;
        end
        @(negedge clk);
        for(i=0;i<packet_len;i=i+1)
        begin
            wait(!busy)
            @(negedge clk)
            payload_data={$random}%256;
            data_in=payload_data;
            payload_parity = payload_parity ^ data_in;
        end
        wait(!busy)
        @(negedge clk) data_in=payload_parity;
        pkt_valid=0;
        #10;
        rd_en[2] = 1'b1;
    end
    endtask
    
    initial
    begin
        rst_in;
        p_8;
        #200
        clr_rd_en;
        #20
        p_14;
        #200;
        clr_rd_en;
        #10;
        p_17;
        #200;
        clr_rd_en;
        #10 $finish;
    end    
endmodule
