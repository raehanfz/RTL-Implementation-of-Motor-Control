module mux_2to1_in #(
    parameter WIDTH = 16
)(
    input signed [WIDTH-1:0] in_ext,
    input signed [WIDTH-1:0] in_bram,
    input sel,
    output reg signed [WIDTH-1:0] out_mux
);
    always @(*) begin
        case (sel)
            1'b0: out_mux = in_ext; 
            1'b1: out_mux = in_bram; 
        endcase
    end
endmodule