module relu_truncate #(
    parameter WIDTH = 16
)(
    input signed [2*WIDTH-1:0] accumulated, 
    output reg signed [WIDTH-1:0] out_relu
);

    always @(*) begin
        //negative check
        if (accumulated[2*WIDTH-1] == 1'b1) begin
            out_relu = 16'd0; 
        end 
        
        // positive saturation check
        else if (|accumulated[2*WIDTH-1:2*WIDTH-5] == 1'b1) begin
            out_relu = 16'h7FFF;
        end 
        
        //safe trucan
        else begin
            out_relu = accumulated[27:12];
        end
    end

endmodule