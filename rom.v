//ROM that stores weight and bias
module rom#(
    parameter WIDTH = 16
)(
    input clk,
    input en_out,
    input [5:0] w_addr,
    input [5:0] b_addr,
    output reg signed [WIDTH-1:0] w_val,
    output reg signed [WIDTH-1:0] b_val
);
    //memory array
    reg signed [WIDTH-1:0] rom_memory [0:48];
    
    initial begin
        $readmemh("weight_bias.mem", rom_memory);
    end

    always @(posedge clk) begin
        if (en_out) begin
            w_val <= rom_memory[w_addr];
            b_val <= rom_memory[b_addr];
        end else begin
            w_val <= 0;
            b_val <= 0;
        end
    end
endmodule