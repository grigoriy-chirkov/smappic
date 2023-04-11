// ========== Copyright Header Begin ============================================
// Copyright (c) 2023 Princeton University
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Princeton University nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ========== Copyright Header End ============================================


`include "axi_defines.vh"
`include "define.tmp.h"

module axi2cep (
    input sys_clk,
    input sys_rst_n,
    input axi_clk, 
    input axi_rst_n,
    
    // CEP interace
    output wire                               cep_queue1_val,
    output wire   [`CEP_DATA_WIDTH-1:0]       cep_queue1_data,
    input  wire                               cep_queue1_rdy,
    output wire                               cep_queue2_val,
    output wire   [`CEP_DATA_WIDTH-1:0]       cep_queue2_data,
    input  wire                               cep_queue2_rdy,
    output wire                               cep_queue3_val,
    output wire   [`CEP_DATA_WIDTH-1:0]       cep_queue3_data,
    input  wire                               cep_queue3_rdy,

    // AXI interace
    input  wire [`AXI4_ID_WIDTH     -1:0]     s_axi_awid,
    input  wire [`AXI4_ADDR_WIDTH   -1:0]     s_axi_awaddr,
    input  wire [`AXI4_LEN_WIDTH    -1:0]     s_axi_awlen,
    input  wire [`AXI4_SIZE_WIDTH   -1:0]     s_axi_awsize,
    input  wire                               s_axi_awvalid,
    output wire                               s_axi_awready,
    input  wire  [`AXI4_DATA_WIDTH   -1:0]    s_axi_wdata,
    input  wire  [`AXI4_STRB_WIDTH   -1:0]    s_axi_wstrb,
    input  wire                               s_axi_wlast,
    input  wire                               s_axi_wvalid,
    output wire                               s_axi_wready,
    input  wire  [`AXI4_ID_WIDTH     -1:0]    s_axi_arid,
    input  wire  [`AXI4_ADDR_WIDTH   -1:0]    s_axi_araddr,
    input  wire  [`AXI4_LEN_WIDTH    -1:0]    s_axi_arlen,
    input  wire  [`AXI4_SIZE_WIDTH   -1:0]    s_axi_arsize,
    input  wire                               s_axi_arvalid,
    output wire                               s_axi_arready,
    output wire  [`AXI4_ID_WIDTH     -1:0]    s_axi_rid,
    output wire  [`AXI4_DATA_WIDTH   -1:0]    s_axi_rdata,
    output wire  [`AXI4_RESP_WIDTH   -1:0]    s_axi_rresp,
    output wire                               s_axi_rlast,
    output wire                               s_axi_rvalid,
    input  wire                               s_axi_rready,
    output wire  [`AXI4_ID_WIDTH     -1:0]    s_axi_bid,
    output wire  [`AXI4_RESP_WIDTH   -1:0]    s_axi_bresp,
    output wire                               s_axi_bvalid,
    input  wire                               s_axi_bready, 

    input wire   [`CEP_CHIPID_WIDTH-1:0]      chipid
);


wire axi_awgo = s_axi_awvalid & s_axi_awready;
wire axi_wgo = s_axi_wvalid & s_axi_wready;
wire axi_bgo = s_axi_bvalid & s_axi_bready;

reg aw_recvd;
reg w_recvd;
wire dispatch = aw_recvd & w_recvd;

// AXI part
// receive data from awaddr
reg [`CEP_CHIPID_WIDTH-1:0] wr_chipid;
reg [2:0] wr_queue_id;
reg [`AXI4_ID_WIDTH-1:0] axi_awid;
always @(posedge axi_clk) begin
    if(~axi_rst_n) begin
        wr_chipid <= `CEP_CHIPID_WIDTH'b0;
        wr_queue_id <= 3'b0;
        aw_recvd <= 1'b0;
        axi_awid <= `AXI4_ID_WIDTH'b0;
    end 
    else begin
        if (axi_awgo) begin
            wr_chipid <= {{`CEP_CHIPID_WIDTH-5 {1'b0}}, s_axi_awaddr[13:9]};
            wr_queue_id <= s_axi_awaddr[8:6];
            aw_recvd <= 1'b1;
            axi_awid <= s_axi_awid;
        end
        else if (dispatch) begin
            aw_recvd <= 1'b0;
        end
    end
end

// receive data from wdata
reg [`CEP_DATA_WIDTH-1:0] cep_indata;
always @(posedge axi_clk) begin
    if(~axi_rst_n) begin
        w_recvd <= 1'b0;
        cep_indata <= `CEP_DATA_WIDTH'b0;
    end 
    else begin
        if (axi_wgo) begin
            w_recvd <= 1'b1;
            cep_indata <= s_axi_wdata[`CEP_DATA_WIDTH-1:0];
        end
        else if (dispatch) begin
            w_recvd <= 1'b0;
        end
    end
end

assign s_axi_wready = dispatch | ~w_recvd;
assign s_axi_awready = dispatch | ~aw_recvd;


// send write acks
reg wr_resp_pending;
reg [`AXI4_ID_WIDTH-1:0] axi_bid;
always @(posedge axi_clk) begin
    if(~axi_rst_n) begin
        wr_resp_pending <= 1'b0;
        axi_bid <= `AXI4_ID_WIDTH'b0;
    end 
    else begin
        if (dispatch) begin
            wr_resp_pending <= 1'b1;
            axi_bid <= axi_awid;
        end
        else if (axi_bgo)
            wr_resp_pending <= 1'b0;
    end
end

// queues
wire [`PITON_NUM_CHIPS:0]  cep_queue1_credits_return;
axi2cep_queue queue1 (
    .axi_clk(axi_clk),
    .axi_rst_n(axi_rst_n),
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),

    //input
    .cep_val_in(dispatch & wr_queue_id[0]),
    .cep_data_in(cep_indata),
    .cep_chipid_in(wr_chipid),

    //output
    .cep_val_out(cep_queue1_val),
    .cep_data_out(cep_queue1_data),
    .cep_rdy_out(cep_queue1_rdy),
    .cep_credits(cep_queue1_credits_return)
);

wire [`PITON_NUM_CHIPS:0]  cep_queue2_credits_return;
axi2cep_queue queue2 (
    .axi_clk(axi_clk),
    .axi_rst_n(axi_rst_n),
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),

    //input
    .cep_val_in(dispatch & wr_queue_id[1]),
    .cep_data_in(cep_indata),
    .cep_chipid_in(wr_chipid),

    //output
    .cep_val_out(cep_queue2_val),
    .cep_data_out(cep_queue2_data),
    .cep_rdy_out(cep_queue2_rdy),
    .cep_credits(cep_queue2_credits_return)
);

wire [`PITON_NUM_CHIPS:0]  cep_queue3_credits_return;
axi2cep_queue queue3 (
    .axi_clk(axi_clk),
    .axi_rst_n(axi_rst_n),
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),

    //input
    .cep_val_in(dispatch & wr_queue_id[2]),
    .cep_data_in(cep_indata),
    .cep_chipid_in(wr_chipid),

    //output
    .cep_val_out(cep_queue3_val),
    .cep_data_out(cep_queue3_data),
    .cep_rdy_out(cep_queue3_rdy),
    .cep_credits(cep_queue3_credits_return)
);

assign s_axi_bvalid = wr_resp_pending;
assign s_axi_bid = axi_bid;//6'b100000;
assign s_axi_bresp = `AXI4_RESP_WIDTH'b0;

// count credits
axi2cep_credits axi2cep_credits(
    .axi_clk    (axi_clk), 
    .axi_rst_n  (axi_rst_n), 
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),

    .cep_queue1_credits_return(cep_queue1_credits_return),
    .cep_queue2_credits_return(cep_queue2_credits_return),
    .cep_queue3_credits_return(cep_queue3_credits_return),

    .s_axi_arid    (s_axi_arid), 
    .s_axi_araddr  (s_axi_araddr), 
    .s_axi_arlen   (s_axi_arlen), 
    .s_axi_arsize  (s_axi_arsize), 
    .s_axi_arvalid (s_axi_arvalid), 
    .s_axi_arready (s_axi_arready), 
    .s_axi_rid     (s_axi_rid), 
    .s_axi_rdata   (s_axi_rdata), 
    .s_axi_rresp   (s_axi_rresp), 
    .s_axi_rlast   (s_axi_rlast), 
    .s_axi_rvalid  (s_axi_rvalid), 
    .s_axi_rready  (s_axi_rready), 

    .chipid        (chipid)
);

endmodule