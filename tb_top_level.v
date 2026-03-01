`timescale 1ns / 1ps
`include "top_level.v"

module tb_top_level();
    parameter WIDTH = 16;
    reg clk;
    reg rst;
    reg start;
    reg stop;
    reg signed [WIDTH-1:0] sys_in;

    wire signed [WIDTH-1:0] sys_out;

    integer i;
    reg signed [WIDTH-1:0] features [0:3]; // Array to hold the 4 input features
    integer cycle_count;

    // Instantiate the Unit Under Test (UUT)
    top_level #( .WIDTH(WIDTH) ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .sys_in(sys_in),
        .sys_out(sys_out)
    );

    // Clock Generation (10ns period / 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Cycle Counter for debugging
    initial begin
        cycle_count = 0;
        forever @(posedge clk) begin
            if (!rst && !start) cycle_count = 1;
            else if (cycle_count > 0 && cycle_count < 70) cycle_count = cycle_count + 1;
        end
    end

    // Main Stimulus Block
    initial begin
        $dumpfile("top_level.vcd");
        $dumpvars(0, tb_top_level);
        //initialize inputs
        rst = 1;
        start = 1; //active low
        stop = 1;  //active low
        sys_in = 0;

        //load data
        features[0] = 16'h0100;  //Speed_ref
        features[1] = 16'h03BA;  //Speed
        features[2] = 16'h0894;  //Current
        features[3] = 16'h09B0;  //Bus_voltage

        #20;
        rst = 0;
        #10;

        //trigger start
        @(posedge clk);
        start = 0; 
        @(posedge clk);
        start = 1; 

        //feed layer input 1
        for (i = 0; i < 8; i = i + 1) begin
            //cycle 2
            @(posedge clk); 
            sys_in = features[0];
            
            // xycle 2
            @(posedge clk); 
            sys_in = features[1];
            
            // cycle 3
            @(posedge clk); 
            sys_in = features[2]; // Set up Feature 3
            
            // cycle 4
            @(posedge clk); 
            sys_in = features[3]; // Set up Feature 4
            
            //cycle 5
            @(posedge clk); 
            sys_in = 16'h0000;    // Clear input
            
            //cycle 6
            @(posedge clk); 
            
            //cycle 7 
            @(posedge clk); 
        end

        //wait for Layer 2 to finish
        wait(cycle_count == 68); 

        // 6. Display Result
        $display("-------------------------------------------------");
        $display("Inference Complete at Cycle %0d", cycle_count);
        $display("Final System Output (sys_out): %h", sys_out);
        $display("-------------------------------------------------");

        //padding before ending the simulation
        #50;
        $finish;
    end

    //monitor key signals
    initial begin
        $monitor("Time=%0t | Cycle=%0d | MAC State=%b | W_Addr=%0d | B_Addr=%0d | sys_in=%h | sys_out=%h", 
                 $time, cycle_count, uut.u_controller.state_accum, uut.cntrl_rom_w_addr, uut.cntrl_rom_b_addr, sys_in, sys_out);
    end

endmodule