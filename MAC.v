`include "multiplier.v"
`include "mux_2to1_mac.v"
`include "accumulator.v"
`include "relu_truncate.v"

module MAC #(
    parameter WIDTH = 16
)(
    input clk,
    input rst,

    input signed [WIDTH-1:0] w_mac,
    input signed [WIDTH-1:0] in_mac,
    input signed [WIDTH-1:0] bias_mac,
    output signed [WIDTH-1:0] out_mac,

    input sel_mux,
    input [1:0] state
);
    wire signed [2*WIDTH-1:0] mult_mux;
    wire signed [2*WIDTH-1:0] mux_accum;
    wire signed [2*WIDTH-1:0] accum_relu;

    multiplier #( .WIDTH(WIDTH) ) u_mult(
        .clk(clk),
        .rst(rst),
        .w_mult(w_mac),
        .in_mult(in_mac),
        .out_mult(mult_mux)
    );

    mux_2to1_mac #( .WIDTH(WIDTH) ) u_mux(
        .in_bias(bias_mac),
        .in_prod(mult_mux),
        .sel(sel_mux),
        .out_mux(mux_accum)
    );

    accumulator #( .WIDTH(WIDTH) ) u_accum(
        .clk(clk),
        .rst(rst),
        .state_accum(state),
        .in_accum(mux_accum),
        .out_accum(accum_relu)
    );

    relu_truncate #( .WIDTH(WIDTH) ) u_relu(
        .accumulated(accum_relu), 
        .out_relu(out_mac)
    );
endmodule