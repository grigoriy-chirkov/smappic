// ========== Copyright Header Begin ============================================
// Copyright (c) 2015 Princeton University
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

`include "define.tmp.h"
`include "mc_define.h"
`include "axi_defines.vh"

module mc_top (
    input                           sys_clk,
    input                           sys_rst_n,


    input   [`NOC_DATA_WIDTH-1:0]   mc_flit_in_data,
    input                           mc_flit_in_val,
    output                          mc_flit_in_rdy,

    output  [`NOC_DATA_WIDTH-1:0]   mc_flit_out_data,
    output                          mc_flit_out_val,
    input                           mc_flit_out_rdy,

    input                           uart_boot_en,
    output                          init_calib_complete_out,


`ifdef PITONSYS_PCIE_DMA
    // axi interface from dma engine
    input                                pcie_dma_axi_clk,
    input                                pcie_dma_axi_resetn,
    input  [`AXI4_ID_WIDTH     -1:0]     pcie_dma_axi_awid,
    input  [`AXI4_ADDR_WIDTH   -1:0]     pcie_dma_axi_awaddr,
    input  [`AXI4_LEN_WIDTH    -1:0]     pcie_dma_axi_awlen,
    input  [`AXI4_SIZE_WIDTH   -1:0]     pcie_dma_axi_awsize,
    input  [`AXI4_BURST_WIDTH  -1:0]     pcie_dma_axi_awburst,
    input                                pcie_dma_axi_awlock,
    input  [`AXI4_CACHE_WIDTH  -1:0]     pcie_dma_axi_awcache,
    input  [`AXI4_PROT_WIDTH   -1:0]     pcie_dma_axi_awprot,
    input  [`AXI4_QOS_WIDTH    -1:0]     pcie_dma_axi_awqos,
    input  [`AXI4_REGION_WIDTH -1:0]     pcie_dma_axi_awregion,
    input  [`AXI4_USER_WIDTH   -1:0]     pcie_dma_axi_awuser,
    input                                pcie_dma_axi_awvalid,
    output                               pcie_dma_axi_awready,
    input   [`AXI4_ID_WIDTH     -1:0]    pcie_dma_axi_wid,
    input   [`AXI4_DATA_WIDTH   -1:0]    pcie_dma_axi_wdata,
    input   [`AXI4_STRB_WIDTH   -1:0]    pcie_dma_axi_wstrb,
    input                                pcie_dma_axi_wlast,
    input   [`AXI4_USER_WIDTH   -1:0]    pcie_dma_axi_wuser,
    input                                pcie_dma_axi_wvalid,
    output                               pcie_dma_axi_wready,
    input   [`AXI4_ID_WIDTH     -1:0]    pcie_dma_axi_arid,
    input   [`AXI4_ADDR_WIDTH   -1:0]    pcie_dma_axi_araddr,
    input   [`AXI4_LEN_WIDTH    -1:0]    pcie_dma_axi_arlen,
    input   [`AXI4_SIZE_WIDTH   -1:0]    pcie_dma_axi_arsize,
    input   [`AXI4_BURST_WIDTH  -1:0]    pcie_dma_axi_arburst,
    input                                pcie_dma_axi_arlock,
    input   [`AXI4_CACHE_WIDTH  -1:0]    pcie_dma_axi_arcache,
    input   [`AXI4_PROT_WIDTH   -1:0]    pcie_dma_axi_arprot,
    input   [`AXI4_QOS_WIDTH    -1:0]    pcie_dma_axi_arqos,
    input   [`AXI4_REGION_WIDTH -1:0]    pcie_dma_axi_arregion,
    input   [`AXI4_USER_WIDTH   -1:0]    pcie_dma_axi_aruser,
    input                                pcie_dma_axi_arvalid,
    output                               pcie_dma_axi_arready,
    output  [`AXI4_ID_WIDTH     -1:0]    pcie_dma_axi_rid,
    output  [`AXI4_DATA_WIDTH   -1:0]    pcie_dma_axi_rdata,
    output  [`AXI4_RESP_WIDTH   -1:0]    pcie_dma_axi_rresp,
    output                               pcie_dma_axi_rlast,
    output  [`AXI4_USER_WIDTH   -1:0]    pcie_dma_axi_ruser,
    output                               pcie_dma_axi_rvalid,
    input                                pcie_dma_axi_rready,
    output  [`AXI4_ID_WIDTH     -1:0]    pcie_dma_axi_bid,
    output  [`AXI4_RESP_WIDTH   -1:0]    pcie_dma_axi_bresp,
    output  [`AXI4_USER_WIDTH   -1:0]    pcie_dma_axi_buser,
    output                               pcie_dma_axi_bvalid,
    input                                pcie_dma_axi_bready,
`endif
    
`ifndef F1_BOARD
    `ifdef PITONSYS_DDR4
        // directly feed in 250MHz ref clock
        input                           mc_clk_p,
        input                           mc_clk_n,

        output                          ddr_act_n,
        output [`DDR_BG_WIDTH-1:0]     ddr_bg,
    `else // PITONSYS_DDR4
        input                           mc_clk,

        output                          ddr_cas_n,
        output                          ddr_ras_n,
        output                          ddr_we_n,
    `endif // PITONSYS_DDR4

        output [`DDR_ADDR_WIDTH-1:0]   ddr_addr,
        output [`DDR_BA_WIDTH-1:0]     ddr_ba,
        output [`DDR_CK_WIDTH-1:0]     ddr_ck_n,
        output [`DDR_CK_WIDTH-1:0]     ddr_ck_p,
        output [`DDR_CKE_WIDTH-1:0]    ddr_cke,
        output                          ddr_reset_n,
        inout  [`DDR_DQ_WIDTH-1:0]     ddr_dq,
        inout  [`DDR_DQS_WIDTH-1:0]    ddr_dqs_n,
        inout  [`DDR_DQS_WIDTH-1:0]    ddr_dqs_p,
    `ifndef NEXYSVIDEO_BOARD
        output [`DDR_CS_WIDTH-1:0]     ddr_cs_n,
    `endif // endif NEXYSVIDEO_BOARD
    `ifdef PITONSYS_DDR4
    `ifdef XUPP3R_BOARD
        output                          ddr_parity,
    `else
        inout [`DDR_DM_WIDTH-1:0]      ddr_dm,
    `endif // XUPP3R_BOARD
    `else // PITONSYS_DDR4
        output [`DDR_DM_WIDTH-1:0]     ddr_dm,
    `endif // PITONSYS_DDR4
        output [`DDR_ODT_WIDTH-1:0]    ddr_odt

`else // F1_BOARD
    input                                    ddr_axi_clk,
    input                                    ddr_axi_resetn,
    output wire [`AXI4_ID_WIDTH     -1:0]    ddr_axi_awid,
    output wire [`AXI4_ADDR_WIDTH   -1:0]    ddr_axi_awaddr,
    output wire [`AXI4_LEN_WIDTH    -1:0]    ddr_axi_awlen,
    output wire [`AXI4_SIZE_WIDTH   -1:0]    ddr_axi_awsize,
    output wire [`AXI4_BURST_WIDTH  -1:0]    ddr_axi_awburst,
    output wire                              ddr_axi_awlock,
    output wire [`AXI4_CACHE_WIDTH  -1:0]    ddr_axi_awcache,
    output wire [`AXI4_PROT_WIDTH   -1:0]    ddr_axi_awprot,
    output wire [`AXI4_QOS_WIDTH    -1:0]    ddr_axi_awqos,
    output wire [`AXI4_REGION_WIDTH -1:0]    ddr_axi_awregion,
    output wire [`AXI4_USER_WIDTH   -1:0]    ddr_axi_awuser,
    output wire                              ddr_axi_awvalid,
    input  wire                              ddr_axi_awready,
    output wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_wid,
    output wire  [`AXI4_DATA_WIDTH   -1:0]    ddr_axi_wdata,
    output wire  [`AXI4_STRB_WIDTH   -1:0]    ddr_axi_wstrb,
    output wire                               ddr_axi_wlast,
    output wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_wuser,
    output wire                               ddr_axi_wvalid,
    input  wire                               ddr_axi_wready,
    output wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_arid,
    output wire  [`AXI4_ADDR_WIDTH   -1:0]    ddr_axi_araddr,
    output wire  [`AXI4_LEN_WIDTH    -1:0]    ddr_axi_arlen,
    output wire  [`AXI4_SIZE_WIDTH   -1:0]    ddr_axi_arsize,
    output wire  [`AXI4_BURST_WIDTH  -1:0]    ddr_axi_arburst,
    output wire                               ddr_axi_arlock,
    output wire  [`AXI4_CACHE_WIDTH  -1:0]    ddr_axi_arcache,
    output wire  [`AXI4_PROT_WIDTH   -1:0]    ddr_axi_arprot,
    output wire  [`AXI4_QOS_WIDTH    -1:0]    ddr_axi_arqos,
    output wire  [`AXI4_REGION_WIDTH -1:0]    ddr_axi_arregion,
    output wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_aruser,
    output wire                               ddr_axi_arvalid,
    input  wire                               ddr_axi_arready,
    input  wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_rid,
    input  wire  [`AXI4_DATA_WIDTH   -1:0]    ddr_axi_rdata,
    input  wire  [`AXI4_RESP_WIDTH   -1:0]    ddr_axi_rresp,
    input  wire                               ddr_axi_rlast,
    input  wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_ruser,
    input  wire                               ddr_axi_rvalid,
    output wire                               ddr_axi_rready,
    input  wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_bid,
    input  wire  [`AXI4_RESP_WIDTH   -1:0]    ddr_axi_bresp,
    input  wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_buser,
    input  wire                               ddr_axi_bvalid,
    output wire                               ddr_axi_bready, 
    input wire                                init_calib_complete
`endif // F1_BOARD

);

// ila_1 mc_ila (
//     .clk(ddr_axi_clk),
//     .probe0(ddr_axi_wready),
//     .probe1( ddr_axi_awaddr),
//     .probe2( ddr_axi_bresp),
//     .probe3( ddr_axi_bvalid),
//     .probe4( ddr_axi_bready),
//     .probe5( ddr_axi_araddr),
//     .probe6( ddr_axi_rready),
//     .probe7( ddr_axi_wvalid),
//     .probe8( ddr_axi_arvalid),
//     .probe9( ddr_axi_arready),
//     .probe10( ddr_axi_rdata),
//     .probe11( ddr_axi_awvalid),
//     .probe12( ddr_axi_awready),
//     .probe13( ddr_axi_rresp),
//     .probe14( ddr_axi_wdata),
//     .probe15( ddr_axi_wstrb),
//     .probe16( ddr_axi_rvalid),
//     .probe19( ddr_axi_awid),
//     .probe20( ddr_axi_bid),
//     .probe25( ddr_axi_arid),
//     .probe38( ddr_axi_rid),
//     .probe41( ddr_axi_rlast),
//     .probe43( ddr_axi_wlast)
// );

reg init_calib_complete_f;
reg init_calib_complete_ff;
wire mc_rst_n;
reg sys_rst_n_f;
reg sys_rst_n_ff;
wire zeroer_rst_n;


`ifndef F1_BOARD
wire                                init_calib_complete;
`endif // F1_BOARD

`ifndef PITONSYS_AXI4_MEM
wire                                noc_mig_bridge_rst_n;

wire                               app_en;
wire    [`MIG_APP_CMD_WIDTH-1 :0]  app_cmd;
wire    [`MIG_APP_ADDR_WIDTH-1:0]  app_addr;
wire                               app_rdy;
wire                               app_wdf_wren;
wire    [`MIG_APP_DATA_WIDTH-1:0]  app_wdf_data;
wire    [`MIG_APP_MASK_WIDTH-1:0]  app_wdf_mask;
wire                               app_wdf_rdy;
wire                               app_wdf_end;
wire    [`MIG_APP_DATA_WIDTH-1:0]  app_rd_data;
wire                               app_rd_data_end;
wire                               app_rd_data_valid;

wire                               core_app_en;
wire    [`MIG_APP_CMD_WIDTH-1 :0]  core_app_cmd;
wire    [`MIG_APP_ADDR_WIDTH-1:0]  core_app_addr;
wire                               core_app_rdy;
wire                               core_app_wdf_wren;
wire    [`MIG_APP_DATA_WIDTH-1:0]  core_app_wdf_data;
wire    [`MIG_APP_MASK_WIDTH-1:0]  core_app_wdf_mask;
wire                               core_app_wdf_rdy;
wire                               core_app_wdf_end;
wire    [`MIG_APP_DATA_WIDTH-1:0]  core_app_rd_data;
wire                               core_app_rd_data_end;
wire                               core_app_rd_data_valid;

`ifdef PITONSYS_MEM_ZEROER
wire                                zero_app_en;
wire    [`MIG_APP_CMD_WIDTH-1 :0]   zero_app_cmd;
wire    [`MIG_APP_ADDR_WIDTH-1:0]   zero_app_addr;
wire                                zero_app_wdf_wren;
wire    [`MIG_APP_DATA_WIDTH-1:0]   zero_app_wdf_data;
wire    [`MIG_APP_MASK_WIDTH-1:0]   zero_app_wdf_mask;
wire                                zero_app_wdf_end;
wire                                init_calib_complete_zero;
`endif // PITONSYS_MEM_ZEROER


`else // PITONSYS_AXI4_MEM

wire                               noc_axi4_bridge_rst_n;

`ifndef F1_BOARD
// AXI4 interface to memory
wire [`AXI4_ID_WIDTH     -1:0]     ddr_axi_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     ddr_axi_awaddr;
wire [`AXI4_LEN_WIDTH    -1:0]     ddr_axi_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     ddr_axi_awsize;
wire [`AXI4_BURST_WIDTH  -1:0]     ddr_axi_awburst;
wire                               ddr_axi_awlock;
wire [`AXI4_CACHE_WIDTH  -1:0]     ddr_axi_awcache;
wire [`AXI4_PROT_WIDTH   -1:0]     ddr_axi_awprot;
wire [`AXI4_QOS_WIDTH    -1:0]     ddr_axi_awqos;
wire [`AXI4_REGION_WIDTH -1:0]     ddr_axi_awregion;
wire [`AXI4_USER_WIDTH   -1:0]     ddr_axi_awuser;
wire                               ddr_axi_awvalid;
wire                               ddr_axi_awready;
wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_wid;
wire  [`AXI4_DATA_WIDTH   -1:0]    ddr_axi_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    ddr_axi_wstrb;
wire                               ddr_axi_wlast;
wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_wuser;
wire                               ddr_axi_wvalid;
wire                               ddr_axi_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    ddr_axi_araddr;
wire  [`AXI4_LEN_WIDTH    -1:0]    ddr_axi_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    ddr_axi_arsize;
wire  [`AXI4_BURST_WIDTH  -1:0]    ddr_axi_arburst;
wire                               ddr_axi_arlock;
wire  [`AXI4_CACHE_WIDTH  -1:0]    ddr_axi_arcache;
wire  [`AXI4_PROT_WIDTH   -1:0]    ddr_axi_arprot;
wire  [`AXI4_QOS_WIDTH    -1:0]    ddr_axi_arqos;
wire  [`AXI4_REGION_WIDTH -1:0]    ddr_axi_arregion;
wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_aruser;
wire                               ddr_axi_arvalid;
wire                               ddr_axi_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    ddr_axi_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    ddr_axi_rresp;
wire                               ddr_axi_rlast;
wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_ruser;
wire                               ddr_axi_rvalid;
wire                               ddr_axi_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    ddr_axi_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    ddr_axi_bresp;
wire  [`AXI4_USER_WIDTH   -1:0]    ddr_axi_buser;
wire                               ddr_axi_bvalid;
wire                               ddr_axi_bready;
`endif // F1_BOARD

// axi4 interface from core + zeroer
wire [`AXI4_ID_WIDTH     -1:0]     sys_axi_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     sys_axi_awaddr;
wire [`AXI4_LEN_WIDTH    -1:0]     sys_axi_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     sys_axi_awsize;
wire [`AXI4_BURST_WIDTH  -1:0]     sys_axi_awburst;
wire                               sys_axi_awlock;
wire [`AXI4_CACHE_WIDTH  -1:0]     sys_axi_awcache;
wire [`AXI4_PROT_WIDTH   -1:0]     sys_axi_awprot;
wire [`AXI4_QOS_WIDTH    -1:0]     sys_axi_awqos;
wire [`AXI4_REGION_WIDTH -1:0]     sys_axi_awregion;
wire [`AXI4_USER_WIDTH   -1:0]     sys_axi_awuser;
wire                               sys_axi_awvalid;
wire                               sys_axi_awready;
wire  [`AXI4_ID_WIDTH     -1:0]    sys_axi_wid;
wire  [`AXI4_DATA_WIDTH   -1:0]    sys_axi_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    sys_axi_wstrb;
wire                               sys_axi_wlast;
wire  [`AXI4_USER_WIDTH   -1:0]    sys_axi_wuser;
wire                               sys_axi_wvalid;
wire                               sys_axi_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    sys_axi_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    sys_axi_araddr;
wire  [`AXI4_LEN_WIDTH    -1:0]    sys_axi_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    sys_axi_arsize;
wire  [`AXI4_BURST_WIDTH  -1:0]    sys_axi_arburst;
wire                               sys_axi_arlock;
wire  [`AXI4_CACHE_WIDTH  -1:0]    sys_axi_arcache;
wire  [`AXI4_PROT_WIDTH   -1:0]    sys_axi_arprot;
wire  [`AXI4_QOS_WIDTH    -1:0]    sys_axi_arqos;
wire  [`AXI4_REGION_WIDTH -1:0]    sys_axi_arregion;
wire  [`AXI4_USER_WIDTH   -1:0]    sys_axi_aruser;
wire                               sys_axi_arvalid;
wire                               sys_axi_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    sys_axi_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    sys_axi_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    sys_axi_rresp;
wire                               sys_axi_rlast;
wire  [`AXI4_USER_WIDTH   -1:0]    sys_axi_ruser;
wire                               sys_axi_rvalid;
wire                               sys_axi_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    sys_axi_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    sys_axi_bresp;
wire  [`AXI4_USER_WIDTH   -1:0]    sys_axi_buser;
wire                               sys_axi_bvalid;
wire                               sys_axi_bready;

// axi4 interface from core
wire [`AXI4_ID_WIDTH     -1:0]     core_axi_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     core_axi_awaddr;
wire [`AXI4_ADDR_WIDTH   -1:0]     core_axi_awaddr_not_translated;
wire [`AXI4_LEN_WIDTH    -1:0]     core_axi_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     core_axi_awsize;
wire [`AXI4_BURST_WIDTH  -1:0]     core_axi_awburst;
wire                               core_axi_awlock;
wire [`AXI4_CACHE_WIDTH  -1:0]     core_axi_awcache;
wire [`AXI4_PROT_WIDTH   -1:0]     core_axi_awprot;
wire [`AXI4_QOS_WIDTH    -1:0]     core_axi_awqos;
wire [`AXI4_REGION_WIDTH -1:0]     core_axi_awregion;
wire [`AXI4_USER_WIDTH   -1:0]     core_axi_awuser;
wire                               core_axi_awvalid;
wire                               core_axi_awready;
wire  [`AXI4_ID_WIDTH     -1:0]    core_axi_wid;
wire  [`AXI4_DATA_WIDTH   -1:0]    core_axi_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    core_axi_wstrb;
wire                               core_axi_wlast;
wire  [`AXI4_USER_WIDTH   -1:0]    core_axi_wuser;
wire                               core_axi_wvalid;
wire                               core_axi_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    core_axi_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    core_axi_araddr;
wire [`AXI4_ADDR_WIDTH   -1:0]     core_axi_araddr_not_translated;
wire  [`AXI4_LEN_WIDTH    -1:0]    core_axi_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    core_axi_arsize;
wire  [`AXI4_BURST_WIDTH  -1:0]    core_axi_arburst;
wire                               core_axi_arlock;
wire  [`AXI4_CACHE_WIDTH  -1:0]    core_axi_arcache;
wire  [`AXI4_PROT_WIDTH   -1:0]    core_axi_arprot;
wire  [`AXI4_QOS_WIDTH    -1:0]    core_axi_arqos;
wire  [`AXI4_REGION_WIDTH -1:0]    core_axi_arregion;
wire  [`AXI4_USER_WIDTH   -1:0]    core_axi_aruser;
wire                               core_axi_arvalid;
wire                               core_axi_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    core_axi_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    core_axi_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    core_axi_rresp;
wire                               core_axi_rlast;
wire  [`AXI4_USER_WIDTH   -1:0]    core_axi_ruser;
wire                               core_axi_rvalid;
wire                               core_axi_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    core_axi_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    core_axi_bresp;
wire  [`AXI4_USER_WIDTH   -1:0]    core_axi_buser;
wire                               core_axi_bvalid;
wire                               core_axi_bready;

`ifdef PITONSYS_MEM_ZEROER
// axi4 interface from zeroer
wire [`AXI4_ID_WIDTH     -1:0]     zeroer_axi_awid;
wire [`AXI4_ADDR_WIDTH   -1:0]     zeroer_axi_awaddr;
wire [`AXI4_LEN_WIDTH    -1:0]     zeroer_axi_awlen;
wire [`AXI4_SIZE_WIDTH   -1:0]     zeroer_axi_awsize;
wire [`AXI4_BURST_WIDTH  -1:0]     zeroer_axi_awburst;
wire                               zeroer_axi_awlock;
wire [`AXI4_CACHE_WIDTH  -1:0]     zeroer_axi_awcache;
wire [`AXI4_PROT_WIDTH   -1:0]     zeroer_axi_awprot;
wire [`AXI4_QOS_WIDTH    -1:0]     zeroer_axi_awqos;
wire [`AXI4_REGION_WIDTH -1:0]     zeroer_axi_awregion;
wire [`AXI4_USER_WIDTH   -1:0]     zeroer_axi_awuser;
wire                               zeroer_axi_awvalid;
wire                               zeroer_axi_awready;
wire  [`AXI4_ID_WIDTH     -1:0]    zeroer_axi_wid;
wire  [`AXI4_DATA_WIDTH   -1:0]    zeroer_axi_wdata;
wire  [`AXI4_STRB_WIDTH   -1:0]    zeroer_axi_wstrb;
wire                               zeroer_axi_wlast;
wire  [`AXI4_USER_WIDTH   -1:0]    zeroer_axi_wuser;
wire                               zeroer_axi_wvalid;
wire                               zeroer_axi_wready;
wire  [`AXI4_ID_WIDTH     -1:0]    zeroer_axi_arid;
wire  [`AXI4_ADDR_WIDTH   -1:0]    zeroer_axi_araddr;
wire  [`AXI4_LEN_WIDTH    -1:0]    zeroer_axi_arlen;
wire  [`AXI4_SIZE_WIDTH   -1:0]    zeroer_axi_arsize;
wire  [`AXI4_BURST_WIDTH  -1:0]    zeroer_axi_arburst;
wire                               zeroer_axi_arlock;
wire  [`AXI4_CACHE_WIDTH  -1:0]    zeroer_axi_arcache;
wire  [`AXI4_PROT_WIDTH   -1:0]    zeroer_axi_arprot;
wire  [`AXI4_QOS_WIDTH    -1:0]    zeroer_axi_arqos;
wire  [`AXI4_REGION_WIDTH -1:0]    zeroer_axi_arregion;
wire  [`AXI4_USER_WIDTH   -1:0]    zeroer_axi_aruser;
wire                               zeroer_axi_arvalid;
wire                               zeroer_axi_arready;
wire  [`AXI4_ID_WIDTH     -1:0]    zeroer_axi_rid;
wire  [`AXI4_DATA_WIDTH   -1:0]    zeroer_axi_rdata;
wire  [`AXI4_RESP_WIDTH   -1:0]    zeroer_axi_rresp;
wire                               zeroer_axi_rlast;
wire  [`AXI4_USER_WIDTH   -1:0]    zeroer_axi_ruser;
wire                               zeroer_axi_rvalid;
wire                               zeroer_axi_rready;
wire  [`AXI4_ID_WIDTH     -1:0]    zeroer_axi_bid;
wire  [`AXI4_RESP_WIDTH   -1:0]    zeroer_axi_bresp;
wire  [`AXI4_USER_WIDTH   -1:0]    zeroer_axi_buser;
wire                               zeroer_axi_bvalid;
wire                               zeroer_axi_bready;

wire                               init_calib_complete_zero;
`endif //PITONSYS_MEM_ZEROER

`endif // PITONSYS_AXI4_MEM

wire                                app_sr_req;
wire                                app_ref_req;
wire                                app_zq_req;
wire                                app_sr_active;
wire                                app_ref_ack;
wire                                app_zq_ack;
wire                                ui_clk;
wire                                ui_clk_sync_rst;


wire                                trans_fifo_val;
wire    [`NOC_DATA_WIDTH-1:0]       trans_fifo_data;
wire                                trans_fifo_rdy;

wire                                fifo_trans_val;
wire    [`NOC_DATA_WIDTH-1:0]       fifo_trans_data;
wire                                fifo_trans_rdy;


// TODO: zeroed based on example simulation of MIG7
// not used for DDR4 MIG
assign app_ref_req = 1'b0;
assign app_sr_req = 1'b0;
assign app_zq_req = 1'b0;

/*
 * If DMA is enabled, reset memory controller and axi_innterconnect 
 * with pcie reset signal, and memory zeroer with sys_rst_n. 
 * This allows loading image onto FPGA while holding all logic in rst state.
 */

`ifdef PITONSYS_PCIE_DMA
// route from PCI to MC is too long, add auxilary regs
reg pcie_dma_axi_resetn_f;
reg pcie_dma_axi_resetn_ff;
always @(posedge pcie_dma_axi_clk) begin
    pcie_dma_axi_resetn_f <= pcie_dma_axi_resetn;
    pcie_dma_axi_resetn_ff <= pcie_dma_axi_resetn_f;
end
assign mc_rst_n = pcie_dma_axi_resetn_ff;
`else 
assign mc_rst_n = sys_rst_n;
`endif

always @(posedge ui_clk) begin
    if(ui_clk_sync_rst) begin
        sys_rst_n_f <= 1'b0;
        sys_rst_n_ff <= 1'b0;
    end else begin
        sys_rst_n_f <= sys_rst_n;
        sys_rst_n_ff <= sys_rst_n_f;
    end
end

assign zeroer_rst_n = sys_rst_n_ff;



noc_bidir_afifo #(
`ifdef PITON_MC_TRAFFIC_SHAPER
    .ENABLE_TRAFFIC_SHAPER(1)
`else
    .ENABLE_TRAFFIC_SHAPER(0)
`endif
) mig_afifo  (
    .clk_1           (sys_clk           ),
    .rst_1           (~init_calib_complete_ff        ),

    .clk_2           (ui_clk                ),
    .rst_2           (~init_calib_complete   ),

    // CPU --> MIG
    .flit_in_val_1   (mc_flit_in_val    ),
    .flit_in_data_1  (mc_flit_in_data   ),
    .flit_in_rdy_1   (mc_flit_in_rdy    ),

    .flit_out_val_2  (fifo_trans_val    ),
    .flit_out_data_2 (fifo_trans_data   ),
    .flit_out_rdy_2  (fifo_trans_rdy    ),

    // MIG --> CPU
    .flit_in_val_2   (trans_fifo_val    ),
    .flit_in_data_2  (trans_fifo_data   ),
    .flit_in_rdy_2   (trans_fifo_rdy    ),

    .flit_out_val_1  (mc_flit_out_val   ),
    .flit_out_data_1 (mc_flit_out_data  ),
    .flit_out_rdy_1  (mc_flit_out_rdy   )
);


`ifndef PITONSYS_AXI4_MEM

`ifdef PITONSYS_MEM_ZEROER
assign app_en                   = zero_app_en;
assign app_cmd                  = zero_app_cmd;
assign app_addr                 = zero_app_addr;
assign app_wdf_wren             = zero_app_wdf_wren;
assign app_wdf_data             = zero_app_wdf_data;
assign app_wdf_mask             = zero_app_wdf_mask;
assign app_wdf_end              = zero_app_wdf_end;
assign noc_mig_bridge_rst_n     = init_calib_complete_zero;
`else
assign app_en                   = core_app_en;
assign app_cmd                  = core_app_cmd;
assign app_addr                 = core_app_addr;
assign app_wdf_wren             = core_app_wdf_wren;
assign app_wdf_data             = core_app_wdf_data;
assign app_wdf_mask             = core_app_wdf_mask;
assign app_wdf_end              = core_app_wdf_end;
assign noc_mig_bridge_rst_n     = init_calib_complete;
`endif
assign core_app_rdy             = app_rdy;
assign core_app_wdf_rdy         = app_wdf_rdy;
assign core_app_rd_data_valid   = app_rd_data_valid;
assign core_app_rd_data_end     = app_rd_data_end;
assign core_app_rd_data         = app_rd_data;

noc_mig_bridge    #  (
    .MIG_APP_ADDR_WIDTH (`MIG_APP_ADDR_WIDTH        ),
    .MIG_APP_DATA_WIDTH (`MIG_APP_DATA_WIDTH        )
)   noc_mig_bridge   (
    .clk                (ui_clk                     ),  // from MC
    .rst_n              (noc_mig_bridge_rst_n       ),  // from MC

    .uart_boot_en       (uart_boot_en               ),

    .flit_in            (fifo_trans_data            ),
    .flit_in_val        (fifo_trans_val             ),
    .flit_in_rdy        (fifo_trans_rdy             ),
    .flit_out           (trans_fifo_data            ),
    .flit_out_val       (trans_fifo_val             ),
    .flit_out_rdy       (trans_fifo_rdy             ),

    .app_rdy            (core_app_rdy               ),
    .app_wdf_rdy        (core_app_wdf_rdy           ),
    .app_rd_data        (core_app_rd_data           ),
    .app_rd_data_end    (core_app_rd_data_end       ),
    .app_rd_data_valid  (core_app_rd_data_valid     ),

    .app_wdf_wren_reg   (core_app_wdf_wren          ),
    .app_wdf_data_out   (core_app_wdf_data          ),
    .app_wdf_mask_out   (core_app_wdf_mask          ),
    .app_wdf_end_out    (core_app_wdf_end           ),
    .app_addr_out       (core_app_addr              ),
    .app_en_reg         (core_app_en                ),
    .app_cmd_reg        (core_app_cmd               )
);




`ifdef PITONSYS_MEM_ZEROER
memory_zeroer #(
    .MIG_APP_ADDR_WIDTH (`MIG_APP_ADDR_WIDTH        ),
    .MIG_APP_DATA_WIDTH (`MIG_APP_DATA_WIDTH        )
)    memory_zeroer (
    .clk                        (ui_clk                     ),
    .rst_n                      (zeroer_rst_n               ),

    .init_calib_complete_in     (init_calib_complete        ),
    .init_calib_complete_out    (init_calib_complete_zero   ),

    .app_rdy_in                 (core_app_rdy               ),
    .app_wdf_rdy_in             (core_app_wdf_rdy           ),
    
    .app_wdf_wren_in            (core_app_wdf_wren          ),
    .app_wdf_data_in            (core_app_wdf_data          ),
    .app_wdf_mask_in            (core_app_wdf_mask          ),
    .app_wdf_end_in             (core_app_wdf_end           ),
    .app_addr_in                (core_app_addr              ),
    .app_en_in                  (core_app_en                ),
    .app_cmd_in                 (core_app_cmd               ),

    .app_wdf_wren_out           (zero_app_wdf_wren          ),
    .app_wdf_data_out           (zero_app_wdf_data          ),
    .app_wdf_mask_out           (zero_app_wdf_mask          ),
    .app_wdf_end_out            (zero_app_wdf_end           ),
    .app_addr_out               (zero_app_addr              ),
    .app_en_out                 (zero_app_en                ),
    .app_cmd_out                (zero_app_cmd               )
);
`endif

`ifdef PITONSYS_DDR4

// reserved, tie to 0
wire app_hi_pri;
assign app_hi_pri = 1'b0;
  
ddr4_0 i_ddr4_0 (
  .sys_rst                   ( ~mc_rst_n                 ),
  .c0_sys_clk_p              ( mc_clk_p                  ),
  .c0_sys_clk_n              ( mc_clk_n                  ),
  .dbg_clk                   (                           ), // not used 
  .dbg_bus                   (                           ), // not used
  .c0_ddr4_ui_clk            ( ui_clk                    ),
  .c0_ddr4_ui_clk_sync_rst   ( ui_clk_sync_rst           ),
  
  .c0_ddr4_act_n             ( ddr_act_n                 ), // cas_n, ras_n and we_n are multiplexed in ddr4
  .c0_ddr4_adr               ( ddr_addr                  ),
  .c0_ddr4_ba                ( ddr_ba                    ),
  .c0_ddr4_bg                ( ddr_bg                    ), // bank group address
  .c0_ddr4_cke               ( ddr_cke                   ),
  .c0_ddr4_odt               ( ddr_odt                   ),
  .c0_ddr4_cs_n              ( ddr_cs_n                  ),
  .c0_ddr4_ck_t              ( ddr_ck_p                  ),
  .c0_ddr4_ck_c              ( ddr_ck_n                  ),
  .c0_ddr4_reset_n           ( ddr_reset_n               ),
`ifndef XUPP3R_BOARD
  .c0_ddr4_dm_dbi_n          ( ddr_dm                    ), // dbi_n is a data bus inversion feature that cannot be used simultaneously with dm
`endif
  .c0_ddr4_dq                ( ddr_dq                    ), 
  .c0_ddr4_dqs_c             ( ddr_dqs_n                 ), 
  .c0_ddr4_dqs_t             ( ddr_dqs_p                 ), 
  .c0_init_calib_complete    ( init_calib_complete       ),
  
  // Application interface ports
  .c0_ddr4_app_addr          ( app_addr                  ),
  .c0_ddr4_app_cmd           ( app_cmd                   ),
  .c0_ddr4_app_en            ( app_en                    ),

  .c0_ddr4_app_hi_pri        ( app_hi_pri                ), // reserved, tie to 0
  .c0_ddr4_app_wdf_data      ( app_wdf_data              ), 
  .c0_ddr4_app_wdf_end       ( app_wdf_end               ),
  .c0_ddr4_app_wdf_mask      ( app_wdf_mask              ), 
  .c0_ddr4_app_wdf_wren      ( app_wdf_wren              ),
  .c0_ddr4_app_rd_data       ( app_rd_data               ), 
  .c0_ddr4_app_rd_data_end   ( app_rd_data_end           ),
  .c0_ddr4_app_rd_data_valid ( app_rd_data_valid         ),
  .c0_ddr4_app_rdy           ( app_rdy                   ),
  .c0_ddr4_app_wdf_rdy       ( app_wdf_rdy               )
`ifdef XUPP3R_BOARD
,
  .c0_ddr4_ecc_err_addr      (                           ),            // output wire [51 : 0] c0_ddr4_ecc_err_addr
  .c0_ddr4_ecc_single        (                           ),                // output wire [7 : 0] c0_ddr4_ecc_single
  .c0_ddr4_ecc_multiple      (                           ),            // output wire [7 : 0] c0_ddr4_ecc_multiple
  .c0_ddr4_app_correct_en_i  ( 1'b1                      ),     // input wire c0_ddr4_app_correct_en_i
  .c0_ddr4_parity            ( ddr_parity                )                        // output wire c0_ddr4_parity
`endif
);

`else // PITONSYS_DDR4
mig_7series_0   mig_7series_0 (
    // Memory interface ports
`ifndef NEXYS4DDR_BOARD
    .ddr3_addr                      (ddr_addr),
    .ddr3_ba                        (ddr_ba),
    .ddr3_cas_n                     (ddr_cas_n),
    .ddr3_ck_n                      (ddr_ck_n),
    .ddr3_ck_p                      (ddr_ck_p),
    .ddr3_cke                       (ddr_cke),
    .ddr3_ras_n                     (ddr_ras_n),
    .ddr3_reset_n                   (ddr_reset_n),
    .ddr3_we_n                      (ddr_we_n),
    .ddr3_dq                        (ddr_dq),
    .ddr3_dqs_n                     (ddr_dqs_n),
    .ddr3_dqs_p                     (ddr_dqs_p),
`ifndef NEXYSVIDEO_BOARD
    .ddr3_cs_n                      (ddr_cs_n),
`endif // endif NEXYSVIDEO_BOARD
    .ddr3_dm                        (ddr_dm),
    .ddr3_odt                       (ddr_odt),
`else // ifdef NEXYS4DDR_BOARD
    .ddr2_addr                      (ddr_addr),
    .ddr2_ba                        (ddr_ba),
    .ddr2_cas_n                     (ddr_cas_n),
    .ddr2_ck_n                      (ddr_ck_n),
    .ddr2_ck_p                      (ddr_ck_p),
    .ddr2_cke                       (ddr_cke),
    .ddr2_ras_n                     (ddr_ras_n),
    .ddr2_we_n                      (ddr_we_n),
    .ddr2_dq                        (ddr_dq),
    .ddr2_dqs_n                     (ddr_dqs_n),
    .ddr2_dqs_p                     (ddr_dqs_p),
    .ddr2_cs_n                      (ddr_cs_n),
    .ddr2_dm                        (ddr_dm),
    .ddr2_odt                       (ddr_odt),
`endif // endif NEXYS4DDR_BOARD

    .init_calib_complete            (init_calib_complete),

    // Application interface ports
    .app_addr                       (app_addr),
    .app_cmd                        (app_cmd),
    .app_en                         (app_en),
    .app_wdf_data                   (app_wdf_data),
    .app_wdf_end                    (app_wdf_end),
    .app_wdf_wren                   (app_wdf_wren),
    .app_rd_data                    (app_rd_data),
    .app_rd_data_end                (app_rd_data_end),
    .app_rd_data_valid              (app_rd_data_valid),
    .app_rdy                        (app_rdy),
    .app_wdf_rdy                    (app_wdf_rdy),
    .app_sr_req                     (app_sr_req),
    .app_ref_req                    (app_ref_req),
    .app_zq_req                     (app_zq_req),
    .app_sr_active                  (app_sr_active),
    .app_ref_ack                    (app_ref_ack),
    .app_zq_ack                     (app_zq_ack),
    .ui_clk                         (ui_clk),
    .ui_clk_sync_rst                (ui_clk_sync_rst),
    .app_wdf_mask                   (app_wdf_mask),

    // System Clock Ports
    .sys_clk_i                      (mc_clk),
    .sys_rst                        (mc_rst_n)
);
`endif // PITONSYS_DDR4

`else // PITONSYS_AXI4_MEM

`ifdef PITONSYS_MEM_ZEROER
assign sys_axi_awid = zeroer_axi_awid;
assign sys_axi_awaddr = zeroer_axi_awaddr;
assign sys_axi_awlen = zeroer_axi_awlen;
assign sys_axi_awsize = zeroer_axi_awsize;
assign sys_axi_awburst = zeroer_axi_awburst;
assign sys_axi_awlock = zeroer_axi_awlock;
assign sys_axi_awcache = zeroer_axi_awcache;
assign sys_axi_awprot = zeroer_axi_awprot;
assign sys_axi_awqos = zeroer_axi_awqos;
assign sys_axi_awregion = zeroer_axi_awregion;
assign sys_axi_awuser = zeroer_axi_awuser;
assign sys_axi_awvalid = zeroer_axi_awvalid;
assign zeroer_axi_awready = sys_axi_awready;

assign sys_axi_wid = zeroer_axi_wid;
assign sys_axi_wdata = zeroer_axi_wdata;
assign sys_axi_wstrb = zeroer_axi_wstrb;
assign sys_axi_wlast = zeroer_axi_wlast;
assign sys_axi_wuser = zeroer_axi_wuser;
assign sys_axi_wvalid = zeroer_axi_wvalid;
assign zeroer_axi_wready = sys_axi_wready;

assign sys_axi_arid = zeroer_axi_arid;
assign sys_axi_araddr = zeroer_axi_araddr;
assign sys_axi_arlen = zeroer_axi_arlen;
assign sys_axi_arsize = zeroer_axi_arsize;
assign sys_axi_arburst = zeroer_axi_arburst;
assign sys_axi_arlock = zeroer_axi_arlock;
assign sys_axi_arcache = zeroer_axi_arcache;
assign sys_axi_arprot = zeroer_axi_arprot;
assign sys_axi_arqos = zeroer_axi_arqos;
assign sys_axi_arregion = zeroer_axi_arregion;
assign sys_axi_aruser = zeroer_axi_aruser;
assign sys_axi_arvalid = zeroer_axi_arvalid;
assign zeroer_axi_arready = sys_axi_arready;

assign zeroer_axi_rid = sys_axi_rid;
assign zeroer_axi_rdata = sys_axi_rdata;
assign zeroer_axi_rresp = sys_axi_rresp;
assign zeroer_axi_rlast = sys_axi_rlast;
assign zeroer_axi_ruser = sys_axi_ruser;
assign zeroer_axi_rvalid = sys_axi_rvalid;
assign sys_axi_rready = zeroer_axi_rready;

assign zeroer_axi_bid = sys_axi_bid;
assign zeroer_axi_bresp = sys_axi_bresp;
assign zeroer_axi_buser = sys_axi_buser;
assign zeroer_axi_bvalid = sys_axi_bvalid;
assign sys_axi_bready = zeroer_axi_bready;

assign noc_axi4_bridge_rst_n       = init_calib_complete_zero;
`else // PITONSYS_MEM_ZEROER

assign sys_axi_awid = core_axi_awid;
assign sys_axi_awaddr = core_axi_awaddr;
assign sys_axi_awlen = core_axi_awlen;
assign sys_axi_awsize = core_axi_awsize;
assign sys_axi_awburst = core_axi_awburst;
assign sys_axi_awlock = core_axi_awlock;
assign sys_axi_awcache = core_axi_awcache;
assign sys_axi_awprot = core_axi_awprot;
assign sys_axi_awqos = core_axi_awqos;
assign sys_axi_awregion = core_axi_awregion;
assign sys_axi_awuser = core_axi_awuser;
assign sys_axi_awvalid = core_axi_awvalid;
assign core_axi_awready = sys_axi_awready;

assign sys_axi_wid = core_axi_wid;
assign sys_axi_wdata = core_axi_wdata;
assign sys_axi_wstrb = core_axi_wstrb;
assign sys_axi_wlast = core_axi_wlast;
assign sys_axi_wuser = core_axi_wuser;
assign sys_axi_wvalid = core_axi_wvalid;
assign core_axi_wready = sys_axi_wready;

assign sys_axi_arid = core_axi_arid;
assign sys_axi_araddr = core_axi_araddr;
assign sys_axi_arlen = core_axi_arlen;
assign sys_axi_arsize = core_axi_arsize;
assign sys_axi_arburst = core_axi_arburst;
assign sys_axi_arlock = core_axi_arlock;
assign sys_axi_arcache = core_axi_arcache;
assign sys_axi_arprot = core_axi_arprot;
assign sys_axi_arqos = core_axi_arqos;
assign sys_axi_arregion = core_axi_arregion;
assign sys_axi_aruser = core_axi_aruser;
assign sys_axi_arvalid = core_axi_arvalid;
assign core_axi_arready = sys_axi_arready;

assign core_axi_rid = sys_axi_rid;
assign core_axi_rdata = sys_axi_rdata;
assign core_axi_rresp = sys_axi_rresp;
assign core_axi_rlast = sys_axi_rlast;
assign core_axi_ruser = sys_axi_ruser;
assign core_axi_rvalid = sys_axi_rvalid;
assign sys_axi_rready = core_axi_rready;

assign core_axi_bid = sys_axi_bid;
assign core_axi_bresp = sys_axi_bresp;
assign core_axi_buser = sys_axi_buser;
assign core_axi_bvalid = sys_axi_bvalid;
assign sys_axi_bready = core_axi_bready;

assign noc_axi4_bridge_rst_n    = init_calib_complete;
`endif // PITONSYS_MEM_ZEROER

noc_axi4_bridge noc_axi4_bridge  (
    .clk                (ui_clk                    ),  
    .rst_n              (noc_axi4_bridge_rst_n     ), 
    .uart_boot_en       (uart_boot_en              ),

    .src_bridge_vr_noc2_val(fifo_trans_val),
    .src_bridge_vr_noc2_dat(fifo_trans_data),
    .src_bridge_vr_noc2_rdy(fifo_trans_rdy),

    .bridge_dst_vr_noc3_val(trans_fifo_val),
    .bridge_dst_vr_noc3_dat(trans_fifo_data),
    .bridge_dst_vr_noc3_rdy(trans_fifo_rdy),

    .m_axi_awid(core_axi_awid),
    .m_axi_awaddr(core_axi_awaddr_not_translated),
    .m_axi_awlen(core_axi_awlen),
    .m_axi_awsize(core_axi_awsize),
    .m_axi_awburst(core_axi_awburst),
    .m_axi_awlock(core_axi_awlock),
    .m_axi_awcache(core_axi_awcache),
    .m_axi_awprot(core_axi_awprot),
    .m_axi_awqos(core_axi_awqos),
    .m_axi_awregion(core_axi_awregion),
    .m_axi_awuser(core_axi_awuser),
    .m_axi_awvalid(core_axi_awvalid),
    .m_axi_awready(core_axi_awready),

    .m_axi_wid(core_axi_wid),
    .m_axi_wdata(core_axi_wdata),
    .m_axi_wstrb(core_axi_wstrb),
    .m_axi_wlast(core_axi_wlast),
    .m_axi_wuser(core_axi_wuser),
    .m_axi_wvalid(core_axi_wvalid),
    .m_axi_wready(core_axi_wready),

    .m_axi_bid(core_axi_bid),
    .m_axi_bresp(core_axi_bresp),
    .m_axi_buser(core_axi_buser),
    .m_axi_bvalid(core_axi_bvalid),
    .m_axi_bready(core_axi_bready),

    .m_axi_arid(core_axi_arid),
    .m_axi_araddr(core_axi_araddr_not_translated),
    .m_axi_arlen(core_axi_arlen),
    .m_axi_arsize(core_axi_arsize),
    .m_axi_arburst(core_axi_arburst),
    .m_axi_arlock(core_axi_arlock),
    .m_axi_arcache(core_axi_arcache),
    .m_axi_arprot(core_axi_arprot),
    .m_axi_arqos(core_axi_arqos),
    .m_axi_arregion(core_axi_arregion),
    .m_axi_aruser(core_axi_aruser),
    .m_axi_arvalid(core_axi_arvalid),
    .m_axi_arready(core_axi_arready),

    .m_axi_rid(core_axi_rid),
    .m_axi_rdata(core_axi_rdata),
    .m_axi_rresp(core_axi_rresp),
    .m_axi_rlast(core_axi_rlast),
    .m_axi_ruser(core_axi_ruser),
    .m_axi_rvalid(core_axi_rvalid),
    .m_axi_rready(core_axi_rready)

);

virt_dev_translator read_translation(
    .in_address(core_axi_araddr_not_translated),
    .out_address(core_axi_araddr)
);

virt_dev_translator write_translation(
    .in_address(core_axi_awaddr_not_translated),
    .out_address(core_axi_awaddr)
);


`ifdef PITONSYS_MEM_ZEROER
axi4_zeroer axi4_zeroer(
  .clk                    (ui_clk),
  .rst_n                  (zeroer_rst_n),
  .init_calib_complete_in (init_calib_complete),
  .init_calib_complete_out(init_calib_complete_zero),

  .s_axi_awid             (core_axi_awid),
  .s_axi_awaddr           (core_axi_awaddr),
  .s_axi_awlen            (core_axi_awlen),
  .s_axi_awsize           (core_axi_awsize),
  .s_axi_awburst          (core_axi_awburst),
  .s_axi_awlock           (core_axi_awlock),
  .s_axi_awcache          (core_axi_awcache),
  .s_axi_awprot           (core_axi_awprot),
  .s_axi_awqos            (core_axi_awqos),
  .s_axi_awregion         (core_axi_awregion),
  .s_axi_awuser           (core_axi_awuser),
  .s_axi_awvalid          (core_axi_awvalid),
  .s_axi_awready          (core_axi_awready),

  .s_axi_wid              (core_axi_wid),
  .s_axi_wdata            (core_axi_wdata),
  .s_axi_wstrb            (core_axi_wstrb),
  .s_axi_wlast            (core_axi_wlast),
  .s_axi_wuser            (core_axi_wuser),
  .s_axi_wvalid           (core_axi_wvalid),
  .s_axi_wready           (core_axi_wready),

  .s_axi_arid             (core_axi_arid),
  .s_axi_araddr           (core_axi_araddr),
  .s_axi_arlen            (core_axi_arlen),
  .s_axi_arsize           (core_axi_arsize),
  .s_axi_arburst          (core_axi_arburst),
  .s_axi_arlock           (core_axi_arlock),
  .s_axi_arcache          (core_axi_arcache),
  .s_axi_arprot           (core_axi_arprot),
  .s_axi_arqos            (core_axi_arqos),
  .s_axi_arregion         (core_axi_arregion),
  .s_axi_aruser           (core_axi_aruser),
  .s_axi_arvalid          (core_axi_arvalid),
  .s_axi_arready          (core_axi_arready),

  .s_axi_rid              (core_axi_rid),
  .s_axi_rdata            (core_axi_rdata),
  .s_axi_rresp            (core_axi_rresp),
  .s_axi_rlast            (core_axi_rlast),
  .s_axi_ruser            (core_axi_ruser),
  .s_axi_rvalid           (core_axi_rvalid),
  .s_axi_rready           (core_axi_rready),

  .s_axi_bid              (core_axi_bid),
  .s_axi_bresp            (core_axi_bresp),
  .s_axi_buser            (core_axi_buser),
  .s_axi_bvalid           (core_axi_bvalid),
  .s_axi_bready           (core_axi_bready),


  .m_axi_awid             (zeroer_axi_awid),
  .m_axi_awaddr           (zeroer_axi_awaddr),
  .m_axi_awlen            (zeroer_axi_awlen),
  .m_axi_awsize           (zeroer_axi_awsize),
  .m_axi_awburst          (zeroer_axi_awburst),
  .m_axi_awlock           (zeroer_axi_awlock),
  .m_axi_awcache          (zeroer_axi_awcache),
  .m_axi_awprot           (zeroer_axi_awprot),
  .m_axi_awqos            (zeroer_axi_awqos),
  .m_axi_awregion         (zeroer_axi_awregion),
  .m_axi_awuser           (zeroer_axi_awuser),
  .m_axi_awvalid          (zeroer_axi_awvalid),
  .m_axi_awready          (zeroer_axi_awready),

  .m_axi_wid              (zeroer_axi_wid),
  .m_axi_wdata            (zeroer_axi_wdata),
  .m_axi_wstrb            (zeroer_axi_wstrb),
  .m_axi_wlast            (zeroer_axi_wlast),
  .m_axi_wuser            (zeroer_axi_wuser),
  .m_axi_wvalid           (zeroer_axi_wvalid),
  .m_axi_wready           (zeroer_axi_wready),

  .m_axi_arid             (zeroer_axi_arid),
  .m_axi_araddr           (zeroer_axi_araddr),
  .m_axi_arlen            (zeroer_axi_arlen),
  .m_axi_arsize           (zeroer_axi_arsize),
  .m_axi_arburst          (zeroer_axi_arburst),
  .m_axi_arlock           (zeroer_axi_arlock),
  .m_axi_arcache          (zeroer_axi_arcache),
  .m_axi_arprot           (zeroer_axi_arprot),
  .m_axi_arqos            (zeroer_axi_arqos),
  .m_axi_arregion         (zeroer_axi_arregion),
  .m_axi_aruser           (zeroer_axi_aruser),
  .m_axi_arvalid          (zeroer_axi_arvalid),
  .m_axi_arready          (zeroer_axi_arready),

  .m_axi_rid              (zeroer_axi_rid),
  .m_axi_rdata            (zeroer_axi_rdata),
  .m_axi_rresp            (zeroer_axi_rresp),
  .m_axi_rlast            (zeroer_axi_rlast),
  .m_axi_ruser            (zeroer_axi_ruser),
  .m_axi_rvalid           (zeroer_axi_rvalid),
  .m_axi_rready           (zeroer_axi_rready),

  .m_axi_bid              (zeroer_axi_bid),
  .m_axi_bresp            (zeroer_axi_bresp),
  .m_axi_buser            (zeroer_axi_buser),
  .m_axi_bvalid           (zeroer_axi_bvalid),
  .m_axi_bready           (zeroer_axi_bready)
);
`endif // PITONSYS_MEM_ZEROER

`ifdef PITONSYS_PCIE_DMA

axi_interconnect axi_interconnect (
  .INTERCONNECT_ACLK(ui_clk),        // input wire INTERCONNECT_ACLK
  .INTERCONNECT_ARESETN(~ui_clk_sync_rst),  // input wire INTERCONNECT_ARESETN
  
  .S00_AXI_ARESET_OUT_N(),  // output wire S00_AXI_ARESET_OUT_N
  .S00_AXI_ACLK(ui_clk),                        // input wire S00_AXI_ACLK
  .S00_AXI_AWID(sys_axi_awid),                  // input wire [7 : 0] S00_AXI_AWID
  .S00_AXI_AWADDR(sys_axi_awaddr),              // input wire [63 : 0] S00_AXI_AWADDR
  .S00_AXI_AWLEN(sys_axi_awlen),                // input wire [7 : 0] S00_AXI_AWLEN
  .S00_AXI_AWSIZE(sys_axi_awsize),              // input wire [2 : 0] S00_AXI_AWSIZE
  .S00_AXI_AWBURST(sys_axi_awburst),            // input wire [1 : 0] S00_AXI_AWBURST
  .S00_AXI_AWLOCK(sys_axi_awlock),              // input wire S00_AXI_AWLOCK
  .S00_AXI_AWCACHE(sys_axi_awcache),            // input wire [3 : 0] S00_AXI_AWCACHE
  .S00_AXI_AWPROT(sys_axi_awprot),              // input wire [2 : 0] S00_AXI_AWPROT
  .S00_AXI_AWQOS(sys_axi_awqos),                // input wire [3 : 0] S00_AXI_AWQOS
  .S00_AXI_AWVALID(sys_axi_awvalid),            // input wire S00_AXI_AWVALID
  .S00_AXI_AWREADY(sys_axi_awready),            // output wire S00_AXI_AWREADY
  .S00_AXI_WDATA(sys_axi_wdata),                // input wire [511 : 0] S00_AXI_WDATA
  .S00_AXI_WSTRB(sys_axi_wstrb),                // input wire [63 : 0] S00_AXI_WSTRB
  .S00_AXI_WLAST(sys_axi_wlast),                // input wire S00_AXI_WLAST
  .S00_AXI_WVALID(sys_axi_wvalid),              // input wire S00_AXI_WVALID
  .S00_AXI_WREADY(sys_axi_wready),              // output wire S00_AXI_WREADY
  .S00_AXI_BID(sys_axi_bid),                    // output wire [7 : 0] S00_AXI_BID
  .S00_AXI_BRESP(sys_axi_bresp),                // output wire [1 : 0] S00_AXI_BRESP
  .S00_AXI_BVALID(sys_axi_bvalid),              // output wire S00_AXI_BVALID
  .S00_AXI_BREADY(sys_axi_bready),              // input wire S00_AXI_BREADY
  .S00_AXI_ARID(sys_axi_arid),                  // input wire [7 : 0] S00_AXI_ARID
  .S00_AXI_ARADDR(sys_axi_araddr),              // input wire [63 : 0] S00_AXI_ARADDR
  .S00_AXI_ARLEN(sys_axi_arlen),                // input wire [7 : 0] S00_AXI_ARLEN
  .S00_AXI_ARSIZE(sys_axi_arsize),              // input wire [2 : 0] S00_AXI_ARSIZE
  .S00_AXI_ARBURST(sys_axi_arburst),            // input wire [1 : 0] S00_AXI_ARBURST
  .S00_AXI_ARLOCK(sys_axi_arlock),              // input wire S00_AXI_ARLOCK
  .S00_AXI_ARCACHE(sys_axi_arcache),            // input wire [3 : 0] S00_AXI_ARCACHE
  .S00_AXI_ARPROT(sys_axi_arprot),              // input wire [2 : 0] S00_AXI_ARPROT
  .S00_AXI_ARQOS(sys_axi_arqos),                // input wire [3 : 0] S00_AXI_ARQOS
  .S00_AXI_ARVALID(sys_axi_arvalid),            // input wire S00_AXI_ARVALID
  .S00_AXI_ARREADY(sys_axi_arready),            // output wire S00_AXI_ARREADY
  .S00_AXI_RID(sys_axi_rid),                    // output wire [7 : 0] S00_AXI_RID
  .S00_AXI_RDATA(sys_axi_rdata),                // output wire [511 : 0] S00_AXI_RDATA
  .S00_AXI_RRESP(sys_axi_rresp),                // output wire [1 : 0] S00_AXI_RRESP
  .S00_AXI_RLAST(sys_axi_rlast),                // output wire S00_AXI_RLAST
  .S00_AXI_RVALID(sys_axi_rvalid),              // output wire S00_AXI_RVALID
  .S00_AXI_RREADY(sys_axi_rready),              // input wire S00_AXI_RREADY

  .S01_AXI_ARESET_OUT_N(),  // output wire S01_AXI_ARESET_OUT_N
  .S01_AXI_ACLK(pcie_dma_axi_clk),                  // input wire S01_AXI_ACLK
  .S01_AXI_AWID(pcie_dma_axi_awid),                  // input wire [7 : 0] S01_AXI_AWID
  .S01_AXI_AWADDR(pcie_dma_axi_awaddr),              // input wire [63 : 0] S01_AXI_AWADDR
  .S01_AXI_AWLEN(pcie_dma_axi_awlen),                // input wire [7 : 0] S01_AXI_AWLEN
  .S01_AXI_AWSIZE(pcie_dma_axi_awsize),              // input wire [2 : 0] S01_AXI_AWSIZE
  .S01_AXI_AWBURST(pcie_dma_axi_awburst),            // input wire [1 : 0] S01_AXI_AWBURST
  .S01_AXI_AWLOCK(pcie_dma_axi_awlock),              // input wire S01_AXI_AWLOCK
  .S01_AXI_AWCACHE(pcie_dma_axi_awcache),            // input wire [3 : 0] S01_AXI_AWCACHE
  .S01_AXI_AWPROT(pcie_dma_axi_awprot),              // input wire [2 : 0] S01_AXI_AWPROT
  .S01_AXI_AWQOS(pcie_dma_axi_awqos),                // input wire [3 : 0] S01_AXI_AWQOS
  .S01_AXI_AWVALID(pcie_dma_axi_awvalid),            // input wire S01_AXI_AWVALID
  .S01_AXI_AWREADY(pcie_dma_axi_awready),            // output wire S01_AXI_AWREADY
  .S01_AXI_WDATA(pcie_dma_axi_wdata),                // input wire [511 : 0] S01_AXI_WDATA
  .S01_AXI_WSTRB(pcie_dma_axi_wstrb),                // input wire [63 : 0] S01_AXI_WSTRB
  .S01_AXI_WLAST(pcie_dma_axi_wlast),                // input wire S01_AXI_WLAST
  .S01_AXI_WVALID(pcie_dma_axi_wvalid),              // input wire S01_AXI_WVALID
  .S01_AXI_WREADY(pcie_dma_axi_wready),              // output wire S01_AXI_WREADY
  .S01_AXI_BID(pcie_dma_axi_bid),                    // output wire [7 : 0] S01_AXI_BID
  .S01_AXI_BRESP(pcie_dma_axi_bresp),                // output wire [1 : 0] S01_AXI_BRESP
  .S01_AXI_BVALID(pcie_dma_axi_bvalid),              // output wire S01_AXI_BVALID
  .S01_AXI_BREADY(pcie_dma_axi_bready),              // input wire S01_AXI_BREADY
  .S01_AXI_ARID(pcie_dma_axi_arid),                  // input wire [7 : 0] S01_AXI_ARID
  .S01_AXI_ARADDR(pcie_dma_axi_araddr),              // input wire [63 : 0] S01_AXI_ARADDR
  .S01_AXI_ARLEN(pcie_dma_axi_arlen),                // input wire [7 : 0] S01_AXI_ARLEN
  .S01_AXI_ARSIZE(pcie_dma_axi_arsize),              // input wire [2 : 0] S01_AXI_ARSIZE
  .S01_AXI_ARBURST(pcie_dma_axi_arburst),            // input wire [1 : 0] S01_AXI_ARBURST
  .S01_AXI_ARLOCK(pcie_dma_axi_arlock),              // input wire S01_AXI_ARLOCK
  .S01_AXI_ARCACHE(pcie_dma_axi_arcache),            // input wire [3 : 0] S01_AXI_ARCACHE
  .S01_AXI_ARPROT(pcie_dma_axi_arprot),              // input wire [2 : 0] S01_AXI_ARPROT
  .S01_AXI_ARQOS(pcie_dma_axi_arqos),                // input wire [3 : 0] S01_AXI_ARQOS
  .S01_AXI_ARVALID(pcie_dma_axi_arvalid),            // input wire S01_AXI_ARVALID
  .S01_AXI_ARREADY(pcie_dma_axi_arready),            // output wire S01_AXI_ARREADY
  .S01_AXI_RID(pcie_dma_axi_rid),                    // output wire [7 : 0] S01_AXI_RID
  .S01_AXI_RDATA(pcie_dma_axi_rdata),                // output wire [511 : 0] S01_AXI_RDATA
  .S01_AXI_RRESP(pcie_dma_axi_rresp),                // output wire [1 : 0] S01_AXI_RRESP
  .S01_AXI_RLAST(pcie_dma_axi_rlast),                // output wire S01_AXI_RLAST
  .S01_AXI_RVALID(pcie_dma_axi_rvalid),              // output wire S01_AXI_RVALID
  .S01_AXI_RREADY(pcie_dma_axi_rready),              // input wire S01_AXI_RREADY

  .M00_AXI_ARESET_OUT_N(),  // output wire M00_AXI_ARESET_OUT_N
  .M00_AXI_ACLK(ui_clk),                        // input wire M00_AXI_ACLK
  .M00_AXI_AWID(ddr_axi_awid),                  // input wire [7 : 0] M00_AXI_AWID
  .M00_AXI_AWADDR(ddr_axi_awaddr),              // input wire [63 : 0] M00_AXI_AWADDR
  .M00_AXI_AWLEN(ddr_axi_awlen),                // input wire [7 : 0] M00_AXI_AWLEN
  .M00_AXI_AWSIZE(ddr_axi_awsize),              // input wire [2 : 0] M00_AXI_AWSIZE
  .M00_AXI_AWBURST(ddr_axi_awburst),            // input wire [1 : 0] M00_AXI_AWBURST
  .M00_AXI_AWLOCK(ddr_axi_awlock),              // input wire M00_AXI_AWLOCK
  .M00_AXI_AWCACHE(ddr_axi_awcache),            // input wire [3 : 0] M00_AXI_AWCACHE
  .M00_AXI_AWPROT(ddr_axi_awprot),              // input wire [2 : 0] M00_AXI_AWPROT
  .M00_AXI_AWQOS(ddr_axi_awqos),                // input wire [3 : 0] M00_AXI_AWQOS
  .M00_AXI_AWVALID(ddr_axi_awvalid),            // input wire M00_AXI_AWVALID
  .M00_AXI_AWREADY(ddr_axi_awready),            // output wire M00_AXI_AWREADY
  .M00_AXI_WDATA(ddr_axi_wdata),                // input wire [511 : 0] M00_AXI_WDATA
  .M00_AXI_WSTRB(ddr_axi_wstrb),                // input wire [63 : 0] M00_AXI_WSTRB
  .M00_AXI_WLAST(ddr_axi_wlast),                // input wire M00_AXI_WLAST
  .M00_AXI_WVALID(ddr_axi_wvalid),              // input wire M00_AXI_WVALID
  .M00_AXI_WREADY(ddr_axi_wready),              // output wire M00_AXI_WREADY
  .M00_AXI_BID(ddr_axi_bid),                    // output wire [7 : 0] M00_AXI_BID
  .M00_AXI_BRESP(ddr_axi_bresp),                // output wire [1 : 0] M00_AXI_BRESP
  .M00_AXI_BVALID(ddr_axi_bvalid),              // output wire M00_AXI_BVALID
  .M00_AXI_BREADY(ddr_axi_bready),              // input wire M00_AXI_BREADY
  .M00_AXI_ARID(ddr_axi_arid),                  // input wire [7 : 0] M00_AXI_ARID
  .M00_AXI_ARADDR(ddr_axi_araddr),              // input wire [63 : 0] M00_AXI_ARADDR
  .M00_AXI_ARLEN(ddr_axi_arlen),                // input wire [7 : 0] M00_AXI_ARLEN
  .M00_AXI_ARSIZE(ddr_axi_arsize),              // input wire [2 : 0] M00_AXI_ARSIZE
  .M00_AXI_ARBURST(ddr_axi_arburst),            // input wire [1 : 0] M00_AXI_ARBURST
  .M00_AXI_ARLOCK(ddr_axi_arlock),              // input wire M00_AXI_ARLOCK
  .M00_AXI_ARCACHE(ddr_axi_arcache),            // input wire [3 : 0] M00_AXI_ARCACHE
  .M00_AXI_ARPROT(ddr_axi_arprot),              // input wire [2 : 0] M00_AXI_ARPROT
  .M00_AXI_ARQOS(ddr_axi_arqos),                // input wire [3 : 0] M00_AXI_ARQOS
  .M00_AXI_ARVALID(ddr_axi_arvalid),            // input wire M00_AXI_ARVALID
  .M00_AXI_ARREADY(ddr_axi_arready),            // output wire M00_AXI_ARREADY
  .M00_AXI_RID(ddr_axi_rid),                    // output wire [7 : 0] M00_AXI_RID
  .M00_AXI_RDATA(ddr_axi_rdata),                // output wire [511 : 0] M00_AXI_RDATA
  .M00_AXI_RRESP(ddr_axi_rresp),                // output wire [1 : 0] M00_AXI_RRESP
  .M00_AXI_RLAST(ddr_axi_rlast),                // output wire M00_AXI_RLAST
  .M00_AXI_RVALID(ddr_axi_rvalid),              // output wire M00_AXI_RVALID
  .M00_AXI_RREADY(ddr_axi_rready)               // input wire M00_AXI_RREADY
);

`else // PITONSYS_PCIE_DMA

assign ddr_axi_awid = sys_axi_awid;
assign ddr_axi_awaddr = sys_axi_awaddr;
assign ddr_axi_awlen = sys_axi_awlen;
assign ddr_axi_awsize = sys_axi_awsize;
assign ddr_axi_awburst = sys_axi_awburst;
assign ddr_axi_awlock = sys_axi_awlock;
assign ddr_axi_awcache = sys_axi_awcache;
assign ddr_axi_awprot = sys_axi_awprot;
assign ddr_axi_awqos = sys_axi_awqos;
assign ddr_axi_awregion = sys_axi_awregion;
assign ddr_axi_awuser = sys_axi_awuser;
assign ddr_axi_awvalid = sys_axi_awvalid;
assign sys_axi_awready = ddr_axi_awready;
assign ddr_axi_wid = sys_axi_wid;
assign ddr_axi_wdata = sys_axi_wdata;
assign ddr_axi_wstrb = sys_axi_wstrb;
assign ddr_axi_wlast = sys_axi_wlast;
assign ddr_axi_wuser = sys_axi_wuser;
assign ddr_axi_wvalid = sys_axi_wvalid;
assign sys_axi_wready = ddr_axi_wready;
assign ddr_axi_arid = sys_axi_arid;
assign ddr_axi_araddr = sys_axi_araddr;
assign ddr_axi_arlen = sys_axi_arlen;
assign ddr_axi_arsize = sys_axi_arsize;
assign ddr_axi_arburst = sys_axi_arburst;
assign ddr_axi_arlock = sys_axi_arlock;
assign ddr_axi_arcache = sys_axi_arcache;
assign ddr_axi_arprot = sys_axi_arprot;
assign ddr_axi_arqos = sys_axi_arqos;
assign ddr_axi_arregion = sys_axi_arregion;
assign ddr_axi_aruser = sys_axi_aruser;
assign ddr_axi_arvalid = sys_axi_arvalid;
assign sys_axi_arready = ddr_axi_arready;
assign sys_axi_rid = ddr_axi_rid;
assign sys_axi_rdata = ddr_axi_rdata;
assign sys_axi_rresp = ddr_axi_rresp;
assign sys_axi_rlast = ddr_axi_rlast;
assign sys_axi_ruser = ddr_axi_ruser;
assign sys_axi_rvalid = ddr_axi_rvalid;
assign ddr_axi_rready = sys_axi_rready;
assign sys_axi_bid = ddr_axi_bid;
assign sys_axi_bresp = ddr_axi_bresp;
assign sys_axi_buser = ddr_axi_buser;
assign sys_axi_bvalid = ddr_axi_bvalid;
assign ddr_axi_bready = sys_axi_bready;

`endif // PITONSYS_PCIE_DMA

`ifdef F1_BOARD
assign ui_clk = ddr_axi_clk;
assign ui_clk_sync_rst = ~ddr_axi_resetn;

`else // F1_BOARD

`ifdef PITONSYS_DDR4

ddr4_axi4 ddr_axi4 (
  .sys_rst                   ( ~mc_rst_n                  ),
  .c0_sys_clk_p              ( mc_clk_p                  ),
  .c0_sys_clk_n              ( mc_clk_n                  ),
  .dbg_clk                   (                           ), // not used 
  .dbg_bus                   (                           ), // not used
  .c0_ddr4_ui_clk            ( ui_clk                    ),
  .c0_ddr4_ui_clk_sync_rst   ( ui_clk_sync_rst           ),
  
  .c0_ddr4_act_n             ( ddr_act_n                 ), // cas_n, ras_n and we_n are multiplexed in ddr4
  .c0_ddr4_adr               ( ddr_addr                  ),
  .c0_ddr4_ba                ( ddr_ba                    ),
  .c0_ddr4_bg                ( ddr_bg                    ), // bank group address
  .c0_ddr4_cke               ( ddr_cke                   ),
  .c0_ddr4_odt               ( ddr_odt                   ),
  .c0_ddr4_cs_n              ( ddr_cs_n                  ),
  .c0_ddr4_ck_t              ( ddr_ck_p                  ),
  .c0_ddr4_ck_c              ( ddr_ck_n                  ),
  .c0_ddr4_reset_n           ( ddr_reset_n               ),
`ifndef XUPP3R_BOARD
  .c0_ddr4_dm_dbi_n          ( ddr_dm                    ), // dbi_n is a data bus inversion feature that cannot be used simultaneously with dm
`endif
  .c0_ddr4_dq                ( ddr_dq                    ), 
  .c0_ddr4_dqs_c             ( ddr_dqs_n                 ), 
  .c0_ddr4_dqs_t             ( ddr_dqs_p                 ), 
  .c0_init_calib_complete    ( init_calib_complete       ),
`ifdef XUPP3R_BOARD
  .c0_ddr4_parity            ( ddr_parity                ),                        // output wire c0_ddr4_parity
`endif
  .c0_ddr4_interrupt         (                           ),                    // output wire c0_ddr4_interrupt
  .c0_ddr4_aresetn           ( mc_rst_n                  ),                        // input wire c0_ddr4_aresetn
  
  .c0_ddr4_s_axi_ctrl_awvalid(1'b0                  ),  // input wire c0_ddr4_s_axi_ctrl_awvalid
  .c0_ddr4_s_axi_ctrl_awready(                      ),  // output wire c0_ddr4_s_axi_ctrl_awready
  .c0_ddr4_s_axi_ctrl_awaddr (32'b0                 ),    // input wire [31 : 0] c0_ddr4_s_axi_ctrl_awaddr
  .c0_ddr4_s_axi_ctrl_wvalid (1'b0                  ),    // input wire c0_ddr4_s_axi_ctrl_wvalid
  .c0_ddr4_s_axi_ctrl_wready (                      ),    // output wire c0_ddr4_s_axi_ctrl_wready
  .c0_ddr4_s_axi_ctrl_wdata  (32'b0                 ),      // input wire [31 : 0] c0_ddr4_s_axi_ctrl_wdata
  .c0_ddr4_s_axi_ctrl_bvalid (                      ),    // output wire c0_ddr4_s_axi_ctrl_bvalid
  .c0_ddr4_s_axi_ctrl_bready (1'b0                  ),    // input wire c0_ddr4_s_axi_ctrl_bready
  .c0_ddr4_s_axi_ctrl_bresp  (                      ),      // output wire [1 : 0] c0_ddr4_s_axi_ctrl_bresp
  .c0_ddr4_s_axi_ctrl_arvalid(1'b0                  ),  // input wire c0_ddr4_s_axi_ctrl_arvalid
  .c0_ddr4_s_axi_ctrl_arready(                      ),  // output wire c0_ddr4_s_axi_ctrl_arready
  .c0_ddr4_s_axi_ctrl_araddr (32'b0                 ),    // input wire [31 : 0] c0_ddr4_s_axi_ctrl_araddr
  .c0_ddr4_s_axi_ctrl_rvalid (                      ),    // output wire c0_ddr4_s_axi_ctrl_rvalid
  .c0_ddr4_s_axi_ctrl_rready (1'b0                  ),    // input wire c0_ddr4_s_axi_ctrl_rready
  .c0_ddr4_s_axi_ctrl_rdata  (                      ),      // output wire [31 : 0] c0_ddr4_s_axi_ctrl_rdata
  .c0_ddr4_s_axi_ctrl_rresp  (                      ),      // output wire [1 : 0] c0_ddr4_s_axi_ctrl_rresp
  
  .c0_ddr4_s_axi_awid(ddr_axi_awid),                  // input wire [15 : 0] c0_ddr4_s_axi_awid
  .c0_ddr4_s_axi_awaddr(ddr_axi_awaddr),              // input wire [34 : 0] c0_ddr4_s_axi_awaddr
  .c0_ddr4_s_axi_awlen(ddr_axi_awlen),                // input wire [7 : 0] c0_ddr4_s_axi_awlen
  .c0_ddr4_s_axi_awsize(ddr_axi_awsize),              // input wire [2 : 0] c0_ddr4_s_axi_awsize
  .c0_ddr4_s_axi_awburst(ddr_axi_awburst),            // input wire [1 : 0] c0_ddr4_s_axi_awburst
  .c0_ddr4_s_axi_awlock(ddr_axi_awlock),              // input wire [0 : 0] c0_ddr4_s_axi_awlock
  .c0_ddr4_s_axi_awcache(ddr_axi_awcache),            // input wire [3 : 0] c0_ddr4_s_axi_awcache
  .c0_ddr4_s_axi_awprot(ddr_axi_awprot),              // input wire [2 : 0] c0_ddr4_s_axi_awprot
  .c0_ddr4_s_axi_awqos(ddr_axi_awqos),                // input wire [3 : 0] c0_ddr4_s_axi_awqos
  .c0_ddr4_s_axi_awvalid(ddr_axi_awvalid),            // input wire c0_ddr4_s_axi_awvalid
  .c0_ddr4_s_axi_awready(ddr_axi_awready),            // output wire c0_ddr4_s_axi_awready
  .c0_ddr4_s_axi_wdata(ddr_axi_wdata),                // input wire [511 : 0] c0_ddr4_s_axi_wdata
  .c0_ddr4_s_axi_wstrb(ddr_axi_wstrb),                // input wire [63 : 0] c0_ddr4_s_axi_wstrb
  .c0_ddr4_s_axi_wlast(ddr_axi_wlast),                // input wire c0_ddr4_s_axi_wlast
  .c0_ddr4_s_axi_wvalid(ddr_axi_wvalid),              // input wire c0_ddr4_s_axi_wvalid
  .c0_ddr4_s_axi_wready(ddr_axi_wready),              // output wire c0_ddr4_s_axi_wready
  .c0_ddr4_s_axi_bready(ddr_axi_bready),              // input wire c0_ddr4_s_axi_bready
  .c0_ddr4_s_axi_bid(ddr_axi_bid),                    // output wire [15 : 0] c0_ddr4_s_axi_bid
  .c0_ddr4_s_axi_bresp(ddr_axi_bresp),                // output wire [1 : 0] c0_ddr4_s_axi_bresp
  .c0_ddr4_s_axi_bvalid(ddr_axi_bvalid),              // output wire c0_ddr4_s_axi_bvalid
  .c0_ddr4_s_axi_arid(ddr_axi_arid),                  // input wire [15 : 0] c0_ddr4_s_axi_arid
  .c0_ddr4_s_axi_araddr(ddr_axi_araddr),              // input wire [34 : 0] c0_ddr4_s_axi_araddr
  .c0_ddr4_s_axi_arlen(ddr_axi_arlen),                // input wire [7 : 0] c0_ddr4_s_axi_arlen
  .c0_ddr4_s_axi_arsize(ddr_axi_arsize),              // input wire [2 : 0] c0_ddr4_s_axi_arsize
  .c0_ddr4_s_axi_arburst(ddr_axi_arburst),            // input wire [1 : 0] c0_ddr4_s_axi_arburst
  .c0_ddr4_s_axi_arlock(ddr_axi_arlock),              // input wire [0 : 0] c0_ddr4_s_axi_arlock
  .c0_ddr4_s_axi_arcache(ddr_axi_arcache),            // input wire [3 : 0] c0_ddr4_s_axi_arcache
  .c0_ddr4_s_axi_arprot(ddr_axi_arprot),              // input wire [2 : 0] c0_ddr4_s_axi_arprot
  .c0_ddr4_s_axi_arqos(ddr_axi_arqos),                // input wire [3 : 0] c0_ddr4_s_axi_arqos
  .c0_ddr4_s_axi_arvalid(ddr_axi_arvalid),            // input wire c0_ddr4_s_axi_arvalid
  .c0_ddr4_s_axi_arready(ddr_axi_arready),            // output wire c0_ddr4_s_axi_arready
  .c0_ddr4_s_axi_rready(ddr_axi_rready),              // input wire c0_ddr4_s_axi_rready
  .c0_ddr4_s_axi_rlast(ddr_axi_rlast),                // output wire c0_ddr4_s_axi_rlast
  .c0_ddr4_s_axi_rvalid(ddr_axi_rvalid),              // output wire c0_ddr4_s_axi_rvalid
  .c0_ddr4_s_axi_rresp(ddr_axi_rresp),                // output wire [1 : 0] c0_ddr4_s_axi_rresp
  .c0_ddr4_s_axi_rid(ddr_axi_rid),                    // output wire [15 : 0] c0_ddr4_s_axi_rid
  .c0_ddr4_s_axi_rdata(ddr_axi_rdata)                 // output wire [511 : 0] c0_ddr4_s_axi_rdata
);

`else // PITONSYS_DDR4


mig_7series_axi4 u_mig_7series_axi4 (

    // Memory interface ports
    .ddr3_addr                      (ddr_addr),  // output [13:0]      DDR_addr
    .ddr3_ba                        (ddr_ba),  // output [2:0]     DDR_ba
    .ddr3_cas_n                     (ddr_cas_n),  // output            DDR_cas_n
    .ddr3_ck_n                      (ddr_ck_n),  // output [0:0]       DDR_ck_n
    .ddr3_ck_p                      (ddr_ck_p),  // output [0:0]       DDR_ck_p
    .ddr3_cke                       (ddr_cke),  // output [0:0]        DDR_cke
    .ddr3_ras_n                     (ddr_ras_n),  // output            DDR_ras_n
    .ddr3_reset_n                   (ddr_reset_n),  // output          DDR_reset_n
    .ddr3_we_n                      (ddr_we_n),  // output         DDR_we_n
    .ddr3_dq                        (ddr_dq),  // inout [63:0]     DDR_dq
    .ddr3_dqs_n                     (ddr_dqs_n),  // inout [7:0]       DDR_dqs_n
    .ddr3_dqs_p                     (ddr_dqs_p),  // inout [7:0]       DDR_dqs_p
    .init_calib_complete            (init_calib_complete),  // output           init_calib_complete
      
    .ddr3_cs_n                      (ddr_cs_n),  // output [0:0]       DDR_cs_n
    .ddr3_dm                        (ddr_dm),  // output [7:0]     DDR_dm
    .ddr3_odt                       (ddr_odt),  // output [0:0]        DDR_odt

    // Application interface ports
    .ui_clk                         (ui_clk),  // output            ui_clk
    .ui_clk_sync_rst                (ui_clk_sync_rst),  // output           ui_clk_sync_rst
    .mmcm_locked                    (),  // output           mmcm_locked
    .aresetn                        (mc_rst_n),  // input            aresetn
    .app_sr_req                     (app_sr_req),  // input         app_sr_req
    .app_ref_req                    (app_ref_req),  // input            app_ref_req
    .app_zq_req                     (app_zq_req),  // input         app_zq_req
    .app_sr_active                  (app_sr_active),  // output         app_sr_active
    .app_ref_ack                    (app_ref_ack),  // output           app_ref_ack
    .app_zq_ack                     (app_zq_ack),  // output            app_zq_ack

    // Slave Interface Write Address Ports
    .s_axi_awid                     (ddr_axi_awid),  // input [15:0]          s_axi_awid
    .s_axi_awaddr                   (ddr_axi_awaddr),  // input [29:0]            s_axi_awaddr
    .s_axi_awlen                    (ddr_axi_awlen),  // input [7:0]          s_axi_awlen
    .s_axi_awsize                   (ddr_axi_awsize),  // input [2:0]         s_axi_awsize
    .s_axi_awburst                  (ddr_axi_awburst),  // input [1:0]            s_axi_awburst
    .s_axi_awlock                   (ddr_axi_awlock),  // input [0:0]         s_axi_awlock
    .s_axi_awcache                  (ddr_axi_awcache),  // input [3:0]            s_axi_awcache
    .s_axi_awprot                   (ddr_axi_awprot),  // input [2:0]         s_axi_awprot
    .s_axi_awqos                    (ddr_axi_awqos),  // input [3:0]          s_axi_awqos
    .s_axi_awvalid                  (ddr_axi_awvalid),  // input          s_axi_awvalid
    .s_axi_awready                  (ddr_axi_awready),  // output         s_axi_awready
    // Slave Interface Write Data Ports
    .s_axi_wdata                    (ddr_axi_wdata),  // input [511:0]            s_axi_wdata
    .s_axi_wstrb                    (ddr_axi_wstrb),  // input [63:0]         s_axi_wstrb
    .s_axi_wlast                    (ddr_axi_wlast),  // input            s_axi_wlast
    .s_axi_wvalid                   (ddr_axi_wvalid),  // input           s_axi_wvalid
    .s_axi_wready                   (ddr_axi_wready),  // output          s_axi_wready
    // Slave Interface Write Response Ports
    .s_axi_bid                      (ddr_axi_bid),  // output [15:0]          s_axi_bid
    .s_axi_bresp                    (ddr_axi_bresp),  // output [1:0]         s_axi_bresp
    .s_axi_bvalid                   (ddr_axi_bvalid),  // output          s_axi_bvalid
    .s_axi_bready                   (ddr_axi_bready),  // input           s_axi_bready
    // Slave Interface Read Address Ports
    .s_axi_arid                     (ddr_axi_arid),  // input [15:0]          s_axi_arid
    .s_axi_araddr                   (ddr_axi_araddr),  // input [29:0]            s_axi_araddr
    .s_axi_arlen                    (ddr_axi_arlen),  // input [7:0]          s_axi_arlen
    .s_axi_arsize                   (ddr_axi_arsize),  // input [2:0]         s_axi_arsize
    .s_axi_arburst                  (ddr_axi_arburst),  // input [1:0]            s_axi_arburst
    .s_axi_arlock                   (ddr_axi_arlock),  // input [0:0]         s_axi_arlock
    .s_axi_arcache                  (ddr_axi_arcache),  // input [3:0]            s_axi_arcache
    .s_axi_arprot                   (ddr_axi_arprot),  // input [2:0]         s_axi_arprot
    .s_axi_arqos                    (ddr_axi_arqos),  // input [3:0]          s_axi_arqos
    .s_axi_arvalid                  (ddr_axi_arvalid),  // input          s_axi_arvalid
    .s_axi_arready                  (ddr_axi_arready),  // output         s_axi_arready
    // Slave Interface Read Data Ports
    .s_axi_rid                      (ddr_axi_rid),  // output [15:0]          s_axi_rid
    .s_axi_rdata                    (ddr_axi_rdata),  // output [511:0]           s_axi_rdata
    .s_axi_rresp                    (ddr_axi_rresp),  // output [1:0]         s_axi_rresp
    .s_axi_rlast                    (ddr_axi_rlast),  // output           s_axi_rlast
    .s_axi_rvalid                   (ddr_axi_rvalid),  // output          s_axi_rvalid
    .s_axi_rready                   (ddr_axi_rready),  // input           s_axi_rready

    // System Clock Ports
    .sys_clk_i                      (mc_clk),
    .sys_rst                        (mc_rst_n) // input sys_rst
);

`endif // PITONSYS_DDR4
`endif // F1_BOARD
`endif // PITONSYS_AXI4_MEM


always @(posedge sys_clk) begin
    if(~mc_rst_n) begin
        init_calib_complete_f <= 1'b0;
        init_calib_complete_ff <= 1'b0;
    end 
    else begin
        `ifdef PITONSYS_MEM_ZEROER
            init_calib_complete_f <= init_calib_complete_zero;
        `else 
            init_calib_complete_f <= init_calib_complete;
        `endif
        init_calib_complete_ff <= init_calib_complete_f;
    end
end

assign init_calib_complete_out = init_calib_complete_ff; 

`ifdef PITON_PROTO
`ifndef PITON_PROTO_NO_MON
`ifndef PITONSYS_AXI4_MEM

    always @(posedge ui_clk) begin
        if (app_en) begin
            $display("MC_TOP: command to MIG. Addr: 0x%x, cmd: 0x%x at", app_addr, app_cmd, $time);
        end

        if (app_wdf_wren) begin
            $display("MC_TOP: writing data 0x%x to memory at", app_wdf_data, $time);
        end

        if (app_rd_data_valid) begin
            $display("MC_TOP: read data 0x%x from memory at", app_rd_data, $time);
        end
    end

`endif  // PITONSYS_AXI4_MEM
`endif  // PITON_PROTO_NO_MON
`endif  // PITON_PROTO

endmodule 
