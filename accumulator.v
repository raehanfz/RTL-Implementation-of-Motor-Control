module accumulator #(
    parameter WIDTH = 16
)(
    input clk,
    input rst,
    input [1:0] state_accum,
    input signed [2*WIDTH-1:0] in_accum,
    output reg signed [2*WIDTH-1:0] out_accum
);
    reg signed [2*WIDTH-1:0] accum;

    always @(posedge clk) begin
        if (rst == 1) begin
            accum <= 0;
            out_accum <= 0;
        end else begin
            case (state_accum)
                2'b00: begin //hold values
                    accum <= accum;
                    out_accum <= out_accum;
                end
                2'b01: accum <= accum + in_accum; //accumulate
                2'b10: out_accum <= accum; //output
                2'b11: accum <= 0; //clear
            endcase
        end
    end
endmodule