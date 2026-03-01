`include "MAC.v"
`include "rom.v"
`include "bram.v"
`include "mux_2to1_in.v"
`include "demux_1to2.v"
`include "controller.v"

module top_level#(
    parameter WIDTH = 16
)(
    input clk,
    input rst,
    input start,
    input stop,

    input signed [WIDTH-1:0] sys_in,
    output signed [WIDTH-1:0] sys_out
);
    //INERNAL WIRE
    wire signed [WIDTH-1:0] mux_mac, mac_demux; //IO MAC
    wire signed [WIDTH-1:0] rom_mac_w, rom_mac_b; //weight and bias MAC
    wire cntrl_mac_sel;
    wire [1:0] cntrl_mac_state;
    
    wire cntrl_rom_en_out;
    wire [5:0] cntrl_rom_w_addr;
    wire [5:0] cntrl_rom_b_addr;

    wire cntrl_bram_en_fetch;
    wire cntrl_bram_en_store;
    wire [2:0] cntrl_bram_store_addr;
    wire [2:0] cntrl_bram_fetch_addr;
    wire signed [WIDTH-1:0] bram_mux, demux_bram;

    wire cntrl_mux_in;
    wire cntrl_demux;
    
    //instantiate modules
    MAC #( .WIDTH(WIDTH) ) u_mac(
        .clk(clk),
        .rst(rst),

        .w_mac(rom_mac_w),
        .in_mac(mux_mac),
        .bias_mac(rom_mac_b),
        .out_mac(mac_demux),

        .sel_mux(cntrl_mac_sel),
        .state(cntrl_mac_state)
    );

    rom #( .WIDTH(WIDTH) ) u_rom(
        .clk(clk),
        .en_out(cntrl_rom_en_out),
        .w_addr(cntrl_rom_w_addr),
        .b_addr(cntrl_rom_b_addr),
        .w_val(rom_mac_w),
        .b_val(rom_mac_b)
    );

    bram #( .WIDTH(WIDTH) ) u_bram(
        .clk(clk),
        .rst(rst),
    
        .en_store(cntrl_bram_en_store),
        .en_fetch(cntrl_bram_en_fetch),
        .mem_store_addr(cntrl_bram_store_addr),
        .mem_fetch_addr(cntrl_bram_fetch_addr),

        .store(demux_bram),
        .fetch(bram_mux)
    );

    mux_2to1_in #( .WIDTH(WIDTH) ) u_mux_in(
        .in_ext(sys_in),
        .in_bram(bram_mux),
        .sel(cntrl_mux_in),
        .out_mux(mux_mac)
    );

    demux_1to2 #( .WIDTH(WIDTH) ) u_demux(
        .in_data(mac_demux),
        .sel(cntrl_demux), 
        .out_bram(demux_bram),
        .out_sys(sys_out)
    );

    controller u_controller(
        .clk(clk),
        .start(start),
        .stop(stop),
        .rst(rst),

        //control mux input (external input vs BRAM input)
        .sel_mux_in(cntrl_mux_in),
        
        //control ROM
        .en_out(cntrl_rom_en_out),
        .w_addr(cntrl_rom_w_addr), //Accommodates weights 0 to 39
        .b_addr(cntrl_rom_b_addr), //40 to 48

        //control BRAM
        .en_store(cntrl_bram_en_store),
        .en_fetch(cntrl_bram_en_fetch),
        .mem_store_addr(cntrl_bram_store_addr),
        .mem_fetch_addr(cntrl_bram_fetch_addr),

        //control MAC
        .sel_mux_mac(cntrl_mac_sel),
        .state_accum(cntrl_mac_state),
        
        //control DeMux (BRAM vs system output)
        .sel_demux(cntrl_demux)
    );
endmodule