`timescale 1ns/1ps
`include "MAC.v"

module tb_mac #(
    parameter WIDTH = 16
);
    reg clk;
    reg rst;

    reg signed [WIDTH-1:0] w_mac;
    reg signed [WIDTH-1:0] in_mac;
    reg signed [WIDTH-1:0] bias_mac;
    wire signed [WIDTH-1:0] out_mac;

    reg sel_mux;
    reg [1:0] state;

    MAC dut(
        .clk(clk),
        .rst(rst),
        .w_mac(w_mac),
        .in_mac(in_mac),
        .bias_mac(bias_mac),
        .out_mac(out_mac),
        .sel_mux(sel_mux),
        .state(state)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("mac_test.vcd");
        $dumpvars(0, tb_mac);

        w_mac = 0; in_mac = 0;  bias_mac = 0;
        sel_mux = 0; state = 2'b00; 
        rst = 1;

        repeat(5) @(posedge clk);
        #1; 
        rst = 0;

        w_mac = 16'd4096;  in_mac = 16'd2048;   
        bias_mac = 16'd4096;                    
        sel_mux = 1'b0;                         
        state = 2'b01;                          
        @(posedge clk); #1;

        w_mac = -16'd4096; in_mac = 16'd2048;   
        sel_mux = 1'b1;                         
        state = 2'b01;                          
        @(posedge clk); #1;

        w_mac = 16'd2048;  in_mac = 16'd2048;   
        sel_mux = 1'b1;
        state = 2'b01;                          
        @(posedge clk); #1;

        w_mac = 16'd4096;  in_mac = -16'd4096;  
        sel_mux = 1'b1;
        state = 2'b01;                          
        @(posedge clk); #1;

        w_mac = 16'd0;     in_mac = 16'd0;      
        sel_mux = 1'b1;
        state = 2'b01;                          
        @(posedge clk); #1;

        state = 2'b10;                          
        @(posedge clk); #1;

        state = 2'b11;                          
        @(posedge clk); #1;

        state = 2'b00;                          
        repeat(3) @(posedge clk);

        $display("final MAC Output: %d", out_mac);
        $finish;
    end

endmodule