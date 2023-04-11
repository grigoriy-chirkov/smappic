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

`include "cep_defines.vh"
`include "define.tmp.h"
`include "multichip_adapter.vh"

module multichip_adapter_core (
    input clk,
    input rst_n,
    
    // Noc interface
    output wire                               noc1_val_out,
    output wire [`NOC_DATA_WIDTH-1:0]         noc1_data_out,
    input  wire                               noc1_rdy_out,
    input  wire                               noc1_val_in,
    input  wire [`NOC_DATA_WIDTH-1:0]         noc1_data_in,
    output wire                               noc1_rdy_in,
    output wire                               noc2_val_out,
    output wire [`NOC_DATA_WIDTH-1:0]         noc2_data_out,
    input  wire                               noc2_rdy_out,
    input  wire                               noc2_val_in,
    input  wire [`NOC_DATA_WIDTH-1:0]         noc2_data_in,
    output wire                               noc2_rdy_in,
    output wire                               noc3_val_out,
    output wire [`NOC_DATA_WIDTH-1:0]         noc3_data_out,
    input  wire                               noc3_rdy_out,
    input  wire                               noc3_val_in,
    input  wire [`NOC_DATA_WIDTH-1:0]         noc3_data_in,
    output wire                               noc3_rdy_in,

    // CEP interace
    output wire                               cep_queue1_val_out,
    output wire [`CEP_DATA_WIDTH-1:0]         cep_queue1_data_out,
    output wire [`CEP_CHIPID_WIDTH-1:0]       cep_queue1_chipid_out,
    input  wire                               cep_queue1_rdy_out,
    output wire                               cep_queue2_val_out,
    output wire [`CEP_DATA_WIDTH-1:0]         cep_queue2_data_out,
    output wire [`CEP_CHIPID_WIDTH-1:0]       cep_queue2_chipid_out,
    input  wire                               cep_queue2_rdy_out,
    output wire                               cep_queue3_val_out,
    output wire [`CEP_DATA_WIDTH-1:0]         cep_queue3_data_out,
    output wire [`CEP_CHIPID_WIDTH-1:0]       cep_queue3_chipid_out,
    input  wire                               cep_queue3_rdy_out,
    input  wire                               cep_queue1_val_in,
    input  wire  [`CEP_DATA_WIDTH-1:0]        cep_queue1_data_in,
    output wire                               cep_queue1_rdy_in,
    input  wire                               cep_queue2_val_in,
    input  wire  [`CEP_DATA_WIDTH-1:0]        cep_queue2_data_in,
    output wire                               cep_queue2_rdy_in,
    input  wire                               cep_queue3_val_in,
    input  wire  [`CEP_DATA_WIDTH-1:0]        cep_queue3_data_in,
    output wire                               cep_queue3_rdy_in
);

wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_empty_index;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_pending_index;
wire mshr_pending;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_empty_slots;
wire [`MA_OWNER_BITS-1:0] mshr_inv_counter;
wire mshr_hit;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_hit_index;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_rd_state;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_rd_data;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_cam_data;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_pending_data;
wire mshr_write_state_en;
wire mshr_write_data_en;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_write_data;

multichip_adapter_mshr mshr (
    .clk(clk),
    .rst_n(rst_n),
    .pipe_wr_sel(1'b0),

    .cam_en1(1'b1),
    .wr_state_en1(mshr_write_state_en),
    .wr_data_en1(mshr_write_data_en),
    .pending_ready1(1'b1),
    .state_in1(`MA_MSHR_STATE_WAIT),
    .data_in1(mshr_write_data),
    .data_mask_in1({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .inv_counter_rd_index_in1(`MA_MSHR_INDEX_WIDTH'b0),
    .wr_index_in1(mshr_empty_index),
    .addr_in1(`MA_MSHR_ADDR_IN_WIDTH'b0),

    .wr_state_en2(1'b0),
    .wr_data_en2(1'b0),
    .inc_counter_en2(1'b0),
    .state_in2(`MA_MSHR_STATE_BITS'b0),
    .data_in2(`MA_MSHR_ARRAY_WIDTH'b0),
    .data_mask_in2(`MA_MSHR_ARRAY_WIDTH'b0),
    .rd_index_in2(`MA_MSHR_INDEX_WIDTH'b0),
    .wr_index_in2(`MA_MSHR_INDEX_WIDTH'b0),

    .hit(mshr_hit),
    .hit_index(mshr_hit_index),
    .rd_state_out(mshr_rd_state),
    .rd_data_out(mshr_rd_data),
    .cam_data_out(mshr_cam_data),
    .pending_data_out(mshr_pending_data),

    .inv_counter_out(mshr_inv_counter),
    .empty_slots(mshr_empty_slots),
    .pending(mshr_pending),
    .pending_index(mshr_pending_index),
    .empty_index(mshr_empty_index)
);

multichip_adapter_outpipe1 outpipe1 (
    .clk(clk), 
    .rst_n(rst_n),
    
    .noc_val(noc1_val_in),
    .noc_data(noc1_data_in),
    .noc_rdy(noc1_rdy_in),

    .cep_val(cep_queue1_val_out),
    .cep_data(cep_queue1_data_out),
    .cep_chipid(cep_queue1_chipid_out),
    .cep_rdy(cep_queue1_rdy_out), 

    .mshr_write_state_en(mshr_write_state_en),
    .mshr_write_data_en(mshr_write_data_en),
    .mshr_write_data(mshr_write_data)
);

multichip_adapter_outpipe2 outpipe2 (
    .clk(clk), 
    .rst_n(rst_n),
    
    .noc_val(noc2_val_in),
    .noc_data(noc2_data_in),
    .noc_rdy(noc2_rdy_in),

    .cep_val(cep_queue2_val_out),
    .cep_data(cep_queue2_data_out),
    .cep_chipid(cep_queue2_chipid_out),
    .cep_rdy(cep_queue2_rdy_out)
);

multichip_adapter_outpipe3 outpipe3 (
    .clk(clk), 
    .rst_n(rst_n),
    
    .noc_val(noc3_val_in),
    .noc_data(noc3_data_in),
    .noc_rdy(noc3_rdy_in),

    .cep_val(cep_queue3_val_out),
    .cep_data(cep_queue3_data_out),
    .cep_chipid(cep_queue3_chipid_out),
    .cep_rdy(cep_queue3_rdy_out)
);

multichip_adapter_inpipe1 inpipe1 (
    .clk(clk), 
    .rst_n(rst_n),

    .noc_val(noc1_val_out),
    .noc_data(noc1_data_out),
    .noc_rdy(noc1_rdy_out),

    .cep_val(cep_queue1_val_in),
    .cep_data(cep_queue1_data_in),
    .cep_rdy(cep_queue1_rdy_in)
);

multichip_adapter_inpipe2 inpipe2 (
    .clk(clk), 
    .rst_n(rst_n),

    .noc_val(noc2_val_out),
    .noc_data(noc2_data_out),
    .noc_rdy(noc2_rdy_out),

    .cep_val(cep_queue2_val_in),
    .cep_data(cep_queue2_data_in),
    .cep_rdy(cep_queue2_rdy_in)
);

multichip_adapter_inpipe3 inpipe3 (
    .clk(clk), 
    .rst_n(rst_n),

    .noc_val(noc3_val_out),
    .noc_data(noc3_data_out),
    .noc_rdy(noc3_rdy_out),

    .cep_val(cep_queue3_val_in),
    .cep_data(cep_queue3_data_in),
    .cep_rdy(cep_queue3_rdy_in)
);

endmodule