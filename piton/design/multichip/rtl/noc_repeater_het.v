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

module noc_repeater_het (
    input piton_clk,
    input piton_rst_n,
    input axi_clk, 
    input axi_rst_n,
    
    input   wire                                   noc1_in0_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc1_in0_data,
    output  wire                                   noc1_in0_rdy,
    input   wire                                   noc2_in0_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc2_in0_data,
    output  wire                                   noc2_in0_rdy,
    input   wire                                   noc3_in0_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc3_in0_data,
    output  wire                                   noc3_in0_rdy,
    output  wire                                   noc1_out0_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc1_out0_data,
    input   wire                                   noc1_out0_rdy,
    output  wire                                   noc2_out0_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc2_out0_data,
    input   wire                                   noc2_out0_rdy,
    output  wire                                   noc3_out0_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc3_out0_data,
    input   wire                                   noc3_out0_rdy,

    input   wire                                   noc1_in1_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc1_in1_data,
    output  wire                                   noc1_in1_rdy,
    input   wire                                   noc2_in1_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc2_in1_data,
    output  wire                                   noc2_in1_rdy,
    input   wire                                   noc3_in1_val,
    input   wire [`NOC_DATA_WIDTH-1:0]             noc3_in1_data,
    output  wire                                   noc3_in1_rdy,
    output  wire                                   noc1_out1_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc1_out1_data,
    input   wire                                   noc1_out1_rdy,
    output  wire                                   noc2_out1_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc2_out1_data,
    input   wire                                   noc2_out1_rdy,
    output  wire                                   noc3_out1_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc3_out1_data,
    input   wire                                   noc3_out1_rdy
);


`ifndef REPEATER_BYPASS

wire [`AXI4_ID_WIDTH     -1:0]     axi_01_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     axi_01_awaddr;
wire [`AXI4_LEN_WIDTH    -1:0]     axi_01_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     axi_01_awsize;
wire [`AXI4_USER_WIDTH   -1:0]     axi_01_awuser;
wire                               axi_01_awvalid;
wire                               axi_01_awready;
wire  [`AXI4_DATA_WIDTH   -1:0]    axi_01_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    axi_01_wstrb;
wire                               axi_01_wlast;
wire                               axi_01_wvalid;
wire                               axi_01_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_01_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    axi_01_araddr;
wire  [`AXI4_LEN_WIDTH    -1:0]    axi_01_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    axi_01_arsize;
wire  [`AXI4_USER_WIDTH   -1:0]    axi_01_aruser;
wire                               axi_01_arvalid;
wire                               axi_01_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_01_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    axi_01_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    axi_01_rresp;
wire                               axi_01_rlast;
wire                               axi_01_rvalid;
wire                               axi_01_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_01_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    axi_01_bresp;
wire                               axi_01_bvalid;
wire                               axi_01_bready;
wire [`AXI4_ID_WIDTH     -1:0]     axi_10_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     axi_10_awaddr;
wire [`AXI4_LEN_WIDTH    -1:0]     axi_10_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     axi_10_awsize;
wire [`AXI4_USER_WIDTH   -1:0]     axi_10_awuser;
wire                               axi_10_awvalid;
wire                               axi_10_awready;
wire  [`AXI4_DATA_WIDTH   -1:0]    axi_10_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    axi_10_wstrb;
wire                               axi_10_wlast;
wire                               axi_10_wvalid;
wire                               axi_10_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_10_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    axi_10_araddr;
wire  [`AXI4_LEN_WIDTH    -1:0]    axi_10_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    axi_10_arsize;
wire  [`AXI4_USER_WIDTH   -1:0]    axi_10_aruser;
wire                               axi_10_arvalid;
wire                               axi_10_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_10_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    axi_10_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    axi_10_rresp;
wire                               axi_10_rlast;
wire                               axi_10_rvalid;
wire                               axi_10_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    axi_10_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    axi_10_bresp;
wire                               axi_10_bvalid;
wire                               axi_10_bready;

multichip_adapter multichip_adapter0(
    .sys_clk           (piton_clk),
    .sys_rst_n         (piton_rst_n),
    .axi_clk           (axi_clk),
    .axi_rst_n         (axi_rst_n),

    .noc1_val_out      (noc1_out0_val), 
    .noc1_data_out     (noc1_out0_data), 
    .noc1_rdy_out      (noc1_out0_rdy), 
    .noc2_val_out      (noc2_out0_val), 
    .noc2_data_out     (noc2_out0_data), 
    .noc2_rdy_out      (noc2_out0_rdy), 
    .noc3_val_out      (noc3_out0_val), 
    .noc3_data_out     (noc3_out0_data), 
    .noc3_rdy_out      (noc3_out0_rdy), 

    .noc1_data_in      (noc1_in0_data), 
    .noc1_rdy_in       (noc1_in0_rdy), 
    .noc1_val_in       (noc1_in0_val), 
    .noc2_data_in      (noc2_in0_data), 
    .noc2_rdy_in       (noc2_in0_rdy), 
    .noc2_val_in       (noc2_in0_val), 
    .noc3_data_in      (noc3_in0_data), 
    .noc3_rdy_in       (noc3_in0_rdy), 
    .noc3_val_in       (noc3_in0_val), 

    .m_axi_awid    (axi_01_awid), 
    .m_axi_awaddr  (axi_01_awaddr), 
    .m_axi_awlen   (axi_01_awlen), 
    .m_axi_awsize  (axi_01_awsize), 
    .m_axi_awuser  (axi_01_awuser), 
    .m_axi_awvalid (axi_01_awvalid), 
    .m_axi_awready (axi_01_awready), 
    .m_axi_wdata   (axi_01_wdata), 
    .m_axi_wstrb   (axi_01_wstrb), 
    .m_axi_wlast   (axi_01_wlast), 
    .m_axi_wvalid  (axi_01_wvalid), 
    .m_axi_wready  (axi_01_wready), 
    .m_axi_arid    (axi_01_arid), 
    .m_axi_araddr  (axi_01_araddr),
    .m_axi_arlen   (axi_01_arlen), 
    .m_axi_arsize  (axi_01_arsize),
    .m_axi_aruser  (axi_01_aruser), 
    .m_axi_arvalid (axi_01_arvalid), 
    .m_axi_arready (axi_01_arready), 
    .m_axi_rid     (axi_01_rid), 
    .m_axi_rdata   (axi_01_rdata), 
    .m_axi_rresp   (axi_01_rresp), 
    .m_axi_rlast   (axi_01_rlast), 
    .m_axi_rvalid  (axi_01_rvalid), 
    .m_axi_rready  (axi_01_rready), 
    .m_axi_bid     (axi_01_bid), 
    .m_axi_bresp   (axi_01_bresp), 
    .m_axi_bvalid  (axi_01_bvalid), 
    .m_axi_bready  (axi_01_bready), 

    .s_axi_awid    (axi_10_awid), 
    .s_axi_awaddr  (axi_10_awaddr), 
    .s_axi_awlen   (axi_10_awlen), 
    .s_axi_awsize  (axi_10_awsize), 
    .s_axi_awvalid (axi_10_awvalid), 
    .s_axi_awready (axi_10_awready), 
    .s_axi_wdata   (axi_10_wdata), 
    .s_axi_wstrb   (axi_10_wstrb), 
    .s_axi_wlast   (axi_10_wlast), 
    .s_axi_wvalid  (axi_10_wvalid), 
    .s_axi_wready  (axi_10_wready), 
    .s_axi_arid    (axi_10_arid), 
    .s_axi_araddr  (axi_10_araddr), 
    .s_axi_arlen   (axi_10_arlen), 
    .s_axi_arsize  (axi_10_arsize), 
    .s_axi_arvalid (axi_10_arvalid), 
    .s_axi_arready (axi_10_arready), 
    .s_axi_rid     (axi_10_rid), 
    .s_axi_rdata   (axi_10_rdata), 
    .s_axi_rresp   (axi_10_rresp), 
    .s_axi_rlast   (axi_10_rlast), 
    .s_axi_rvalid  (axi_10_rvalid), 
    .s_axi_rready  (axi_10_rready), 
    .s_axi_bid     (axi_10_bid), 
    .s_axi_bresp   (axi_10_bresp), 
    .s_axi_bvalid  (axi_10_bvalid), 
    .s_axi_bready  (axi_10_bready), 

    .chipid       (`NOC_CHIPID_WIDTH'd0),
    .chip0_base   (`AXI4_ADDR_WIDTH'h00000),
    .chip1_base   (`AXI4_ADDR_WIDTH'h10000),
    .host_base    (`AXI4_ADDR_WIDTH'h40000)
);

multichip_adapter multichip_adapter1(
    .sys_clk           (piton_clk),
    .sys_rst_n         (piton_rst_n),
    .axi_clk           (axi_clk),
    .axi_rst_n         (axi_rst_n),

    .noc1_val_out      (noc1_out1_val), 
    .noc1_data_out     (noc1_out1_data), 
    .noc1_rdy_out      (noc1_out1_rdy), 
    .noc2_val_out      (noc2_out1_val), 
    .noc2_data_out     (noc2_out1_data), 
    .noc2_rdy_out      (noc2_out1_rdy), 
    .noc3_val_out      (noc3_out1_val), 
    .noc3_data_out     (noc3_out1_data), 
    .noc3_rdy_out      (noc3_out1_rdy), 

    .noc1_data_in      (noc1_in1_data), 
    .noc1_rdy_in       (noc1_in1_rdy), 
    .noc1_val_in       (noc1_in1_val), 
    .noc2_data_in      (noc2_in1_data), 
    .noc2_rdy_in       (noc2_in1_rdy), 
    .noc2_val_in       (noc2_in1_val), 
    .noc3_data_in      (noc3_in1_data), 
    .noc3_rdy_in       (noc3_in1_rdy), 
    .noc3_val_in       (noc3_in1_val), 

    .m_axi_awid    (axi_10_awid), 
    .m_axi_awaddr  (axi_10_awaddr), 
    .m_axi_awlen   (axi_10_awlen), 
    .m_axi_awsize  (axi_10_awsize), 
    .m_axi_awuser  (axi_10_awuser), 
    .m_axi_awvalid (axi_10_awvalid), 
    .m_axi_awready (axi_10_awready), 
    .m_axi_wdata   (axi_10_wdata), 
    .m_axi_wstrb   (axi_10_wstrb), 
    .m_axi_wlast   (axi_10_wlast), 
    .m_axi_wvalid  (axi_10_wvalid), 
    .m_axi_wready  (axi_10_wready), 
    .m_axi_arid    (axi_10_arid), 
    .m_axi_araddr  (axi_10_araddr),
    .m_axi_arlen   (axi_10_arlen), 
    .m_axi_arsize  (axi_10_arsize),
    .m_axi_aruser  (axi_10_aruser), 
    .m_axi_arvalid (axi_10_arvalid), 
    .m_axi_arready (axi_10_arready), 
    .m_axi_rid     (axi_10_rid), 
    .m_axi_rdata   (axi_10_rdata), 
    .m_axi_rresp   (axi_10_rresp), 
    .m_axi_rlast   (axi_10_rlast), 
    .m_axi_rvalid  (axi_10_rvalid), 
    .m_axi_rready  (axi_10_rready), 
    .m_axi_bid     (axi_10_bid), 
    .m_axi_bresp   (axi_10_bresp), 
    .m_axi_bvalid  (axi_10_bvalid), 
    .m_axi_bready  (axi_10_bready), 

    .s_axi_awid    (axi_01_awid), 
    .s_axi_awaddr  (axi_01_awaddr), 
    .s_axi_awlen   (axi_01_awlen), 
    .s_axi_awsize  (axi_01_awsize), 
    .s_axi_awvalid (axi_01_awvalid), 
    .s_axi_awready (axi_01_awready), 
    .s_axi_wdata   (axi_01_wdata), 
    .s_axi_wstrb   (axi_01_wstrb), 
    .s_axi_wlast   (axi_01_wlast), 
    .s_axi_wvalid  (axi_01_wvalid), 
    .s_axi_wready  (axi_01_wready), 
    .s_axi_arid    (axi_01_arid), 
    .s_axi_araddr  (axi_01_araddr), 
    .s_axi_arlen   (axi_01_arlen), 
    .s_axi_arsize  (axi_01_arsize), 
    .s_axi_arvalid (axi_01_arvalid), 
    .s_axi_arready (axi_01_arready), 
    .s_axi_rid     (axi_01_rid), 
    .s_axi_rdata   (axi_01_rdata), 
    .s_axi_rresp   (axi_01_rresp), 
    .s_axi_rlast   (axi_01_rlast), 
    .s_axi_rvalid  (axi_01_rvalid), 
    .s_axi_rready  (axi_01_rready), 
    .s_axi_bid     (axi_01_bid), 
    .s_axi_bresp   (axi_01_bresp), 
    .s_axi_bvalid  (axi_01_bvalid), 
    .s_axi_bready  (axi_01_bready), 

    .chipid       (`NOC_CHIPID_WIDTH'd1),
    .chip0_base   (`AXI4_ADDR_WIDTH'h00000),
    .chip1_base   (`AXI4_ADDR_WIDTH'h10000),
    .host_base    (`AXI4_ADDR_WIDTH'h40000)
);

repeater_checker checker1_01(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc1_in0_val), 
    .rdy1 (noc1_in0_rdy), 
    .dat1 (noc1_in0_data), 

    .val2 (noc1_out1_val), 
    .rdy2 (noc1_out1_rdy), 
    .dat2 (noc1_out1_data)
);

repeater_checker checker1_10(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc1_in1_val), 
    .rdy1 (noc1_in1_rdy), 
    .dat1 (noc1_in1_data), 

    .val2 (noc1_out0_val), 
    .rdy2 (noc1_out0_rdy), 
    .dat2 (noc1_out0_data)
);

repeater_checker checker2_01(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc2_in0_val), 
    .rdy1 (noc2_in0_rdy), 
    .dat1 (noc2_in0_data), 

    .val2 (noc2_out1_val), 
    .rdy2 (noc2_out1_rdy), 
    .dat2 (noc2_out1_data)
);

repeater_checker checker2_10(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc2_in1_val), 
    .rdy1 (noc2_in1_rdy), 
    .dat1 (noc2_in1_data), 

    .val2 (noc2_out0_val), 
    .rdy2 (noc2_out0_rdy), 
    .dat2 (noc2_out0_data)
);


repeater_checker checker3_01(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc3_in0_val), 
    .rdy1 (noc3_in0_rdy), 
    .dat1 (noc3_in0_data), 

    .val2 (noc3_out1_val), 
    .rdy2 (noc3_out1_rdy), 
    .dat2 (noc3_out1_data)
);

repeater_checker checker3_10(
    .clk(piton_clk), 
    .rst_n(piton_rst_n), 

    .val1 (noc3_in1_val), 
    .rdy1 (noc3_in1_rdy), 
    .dat1 (noc3_in1_data), 

    .val2 (noc3_out0_val), 
    .rdy2 (noc3_out0_rdy), 
    .dat2 (noc3_out0_data)
);


`else 

assign noc1_out_val =  noc1_in_val;
assign noc1_out_data = noc1_in_data;
assign noc1_in_rdy =   noc1_out_rdy;

assign noc2_out_val =  noc2_in_val;
assign noc2_out_data = noc2_in_data;
assign noc2_in_rdy =   noc2_out_rdy;

assign noc3_out_val =  noc3_in_val;
assign noc3_out_data = noc3_in_data;
assign noc3_in_rdy =   noc3_out_rdy;

`endif

endmodule