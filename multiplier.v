module multiplier #(
    parameter WIDTH = 16
)(
    input clk,
    input rst,
    input signed [WIDTH-1:0] w_mult,
    input signed [WIDTH-1:0] in_mult,
    output reg signed [2*WIDTH-1:0] out_mult
);
    always @(posedge clk) begin
        if (rst == 1) begin
            out_mult <= 0;
        end else begin
            out_mult <= in_mult*w_mult;
        end
    end
endmodule