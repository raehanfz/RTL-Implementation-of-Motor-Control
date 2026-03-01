module demux_1to2 #(
    parameter WIDTH = 16
)(
    input signed [WIDTH-1:0] in_data,
    input sel, // 0 = send to BRAM, 1 = send to System Output
    output reg signed [WIDTH-1:0] out_bram,
    output reg signed [WIDTH-1:0] out_sys
);
    always @(*) begin
        if (sel == 1'b0) begin
            out_bram = in_data;
            out_sys  = 0;
        end else begin
            out_bram = 0;
            out_sys  = in_data;
        end
    end
endmodule