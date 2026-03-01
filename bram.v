//bram that stores mac output
module bram #(
    parameter WIDTH = 16
)(
    input clk,
    input rst,
    
    input en_store,
    input en_fetch,
    input [2:0] mem_store_addr, //can store up to 8 data
    input [2:0] mem_fetch_addr,

    input signed [WIDTH-1:0] store,
    output reg signed [WIDTH-1:0] fetch
);
    //memory array
    reg signed [WIDTH-1:0] bram_memory [0:8];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<8 ; i=i+1) begin
                bram_memory[i] <= 0;
            end
            fetch <= 0;
        end else begin
            if (en_store) begin
                bram_memory[mem_store_addr] <= store;
            end

            if (en_fetch) begin
                fetch <= bram_memory[mem_fetch_addr];
            end
        end
    end
endmodule