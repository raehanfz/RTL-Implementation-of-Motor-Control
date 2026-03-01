module controller (
    input clk,
    input start,
    input stop,
    input rst,

    //control mux input (external input vs BRAM input)
    output reg sel_mux_in,
    
    //control ROM
    output reg en_out,
    output reg [5:0] w_addr, //Accommodates weights 0 to 39
    output reg [5:0] b_addr, //40 to 48

    //control BRAM
    output reg en_store,
    output reg en_fetch,
    output reg [2:0] mem_store_addr,
    output reg [2:0] mem_fetch_addr,

    //control MAC
    output reg sel_mux_mac,
    output reg [1:0] state_accum,
    
    //control DeMux (BRAM vs system output)
    output reg sel_demux
);

    localparam BIAS_START = 6'd40;

    localparam MAC_HOLD  = 2'b00; 
    localparam MAC_ACCUM = 2'b01; 
    localparam MAC_OUT   = 2'b10; 
    localparam MAC_CLEAR = 2'b11; 

    reg [6:0] cycle;
    reg [2:0] step; 
    reg running;

    always @(posedge clk) begin
        if (rst) begin
            cycle          <= 1;
            step           <= 1;
            running        <= 0;
            
            sel_mux_in     <= 0;
            sel_mux_mac    <= 0;
            sel_demux      <= 0;
            
            en_out         <= 0;
            w_addr         <= 0;
            b_addr         <= BIAS_START;
            
            en_store       <= 0;
            en_fetch       <= 0;
            mem_store_addr <= 0;
            mem_fetch_addr <= 0;
            
            state_accum    <= MAC_CLEAR; 
        end else begin
            //active low logic
            if (~start) running <= 1'b1;
            if (~stop)  running <= 1'b0;

            if (running) begin
                if (cycle < 68) cycle <= cycle + 1; 
                en_store <= 0;
                en_fetch <= 0;
                en_out   <= 1; 

                // ==========================================
                // LAYER 1: Cycles 1 to 56 
                // ==========================================
                if (cycle >= 1 && cycle <= 56) begin 
                    sel_mux_in <= 1'b0; 
                    sel_demux  <= 1'b0; 

                    case (step)
                        1: begin
                            state_accum <= MAC_ACCUM; 
                            sel_mux_mac <= 1'b0; // Select Bias
                            step        <= step + 1;
                            if (cycle > 2) mem_store_addr <= mem_store_addr + 1;
                        end
                        2, 3, 4, 5: begin 
                            state_accum <= MAC_ACCUM;
                            sel_mux_mac <= 1'b1; // Select Product
                            w_addr      <= w_addr + 1;
                            step        <= step + 1;
                        end
                        6: begin 
                            state_accum <= MAC_OUT;
                            step        <= step + 1;
                        end
                        7: begin 
                            state_accum <= MAC_CLEAR; 
                            en_store    <= 1;
                            b_addr      <= b_addr + 1; 
                            step        <= 1;          
                        end
                    endcase
                end

                // ==========================================
                // LAYER 2: Cycles 57 to 67 
                // ==========================================
                else if (cycle >= 57 && cycle <= 67) begin
                    sel_mux_in <= 1'b1; 
                    sel_demux  <= 1'b1; 
                    
                    if (cycle == 57) begin // Prep Cycle 58: Load Bias 9
                        state_accum    <= MAC_ACCUM; 
                        sel_mux_mac    <= 1'b0; 
                        en_fetch       <= 1;
                        mem_fetch_addr <= 0;
                    end 
                    else if (cycle >= 58 && cycle <= 64) begin // Prep Cycles 59-65: MAC
                        state_accum    <= MAC_ACCUM;
                        sel_mux_mac    <= 1'b1; 
                        en_fetch       <= 1;
                        mem_fetch_addr <= mem_fetch_addr + 1;
                        w_addr         <= w_addr + 1;
                    end 
                    else if (cycle == 65) begin // Prep Cycle 66: Final MAC
                        state_accum    <= MAC_ACCUM;
                        sel_mux_mac    <= 1'b1; 
                        en_fetch       <= 0; 
                        w_addr         <= w_addr + 1;
                    end 
                    else if (cycle == 66) begin // Prep Cycle 67: Wait / Latch
                        state_accum    <= MAC_OUT;
                    end 
                    else if (cycle == 67) begin // Prep Cycle 68: Clear
                        state_accum    <= MAC_CLEAR; 
                    end
                end 

                // ==========================================
                // DONE / END
                // ==========================================
                else begin
                    state_accum <= MAC_HOLD;
                    sel_demux   <= 1'b1; // Keep demux open so sys_out holds the final value
                    en_out      <= 0;
                    running     <= 0; 
                end
            end
        end
    end

endmodule