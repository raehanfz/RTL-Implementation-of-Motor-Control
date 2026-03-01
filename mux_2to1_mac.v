//a 2to1 mux with bias width adjustor
module mux_2to1_mac #(
    parameter WIDTH = 16
)(
    input signed [WIDTH-1:0] in_bias,
    input signed [2*WIDTH-1:0] in_prod,
    input sel,
    output reg signed [2*WIDTH-1:0] out_mux
);
    always @(*) begin
        case (sel)
            1'b0: out_mux = { {4{in_bias[15]}}, in_bias, 12'd0 };
            1'b1: out_mux = in_prod;
        endcase
    end
endmodule