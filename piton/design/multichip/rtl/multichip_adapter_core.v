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
    input wire [`CEP_CHIPID_WIDTH-1:0]        mychipid,

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





wire dir_rd_en1;
wire [`MA_ADDR_WIDTH-1:0] dir_rd_addr1;
wire dir_rd_hit1;
wire [`MA_SET_WIDTH-1:0] dir_rd_set1;
wire [`MA_WAY_WIDTH-1:0] dir_rd_way1;
wire [`MA_TAG_WIDTH-1:0] dir_rd_tag1;
wire [`MA_STATE_WIDTH-1:0] dir_rd_state1;
wire dir_rd_shared1;
wire [`MA_SHARER_SET_WIDTH-1:0] dir_rd_sharer_set1;
wire [`MA_WAY_WIDTH:0] dir_num_empty_ways1;
wire [`MA_WAY_WIDTH-1:0] dir_empty_way1;
wire dir_rd_en2;
wire [`MA_ADDR_WIDTH-1:0] dir_rd_addr2;
wire dir_rd_hit2;
wire [`MA_SET_WIDTH-1:0] dir_rd_set2;
wire [`MA_WAY_WIDTH-1:0] dir_rd_way2;
wire [`MA_TAG_WIDTH-1:0] dir_rd_tag2;
wire [`MA_STATE_WIDTH-1:0] dir_rd_state2;
wire dir_rd_shared2;
wire [`MA_SHARER_SET_WIDTH-1:0] dir_rd_sharer_set2;
wire [`MA_WAY_WIDTH:0] dir_num_empty_ways2;
wire [`MA_WAY_WIDTH-1:0] dir_empty_way2;
wire dir_wr_en2;
wire [`MA_SET_WIDTH-1:0] dir_wr_set2;
wire [`MA_WAY_WIDTH-1:0] dir_wr_way2;
wire [`MA_TAG_WIDTH-1:0] dir_wr_tag2;
wire [`MA_STATE_WIDTH-1:0] dir_wr_state2;
wire [`MA_SHARER_SET_WIDTH-1:0] dir_wr_sharer_set2;


multichip_adapter_dir dir(
    .clk(clk),
    .rst_n(rst_n),
    .pipe_rd_sel(dir_rd_en2), 
    .pipe_wr_sel(dir_wr_en2),

    .rd_en1(dir_rd_en1),
    .rd_addr1(dir_rd_addr1),
    .rd_hit1(dir_rd_hit1),
    .rd_set1(dir_rd_set1),
    .rd_way1(dir_rd_way1),
    .rd_tag1(dir_rd_tag1),
    .rd_state1(dir_rd_state1),
    .rd_shared1(dir_rd_shared1),
    .rd_sharer_set1(dir_rd_sharer_set1),
    .num_empty_ways1(dir_num_empty_ways1),
    .empty_way1(dir_empty_way1),

    .wr_en1(1'b0),
    .wr_set1(`MA_SET_WIDTH'b0),
    .wr_way1(`MA_WAY_WIDTH'b0),
    .wr_tag1(`MA_TAG_WIDTH'b0),
    .wr_state1(`MA_STATE_INVALID),
    .wr_sharer_set1(`MA_SHARER_SET_WIDTH'b0),

    .rd_en2(dir_rd_en2),
    .rd_addr2(dir_rd_addr2),
    .rd_hit2(dir_rd_hit2),
    .rd_set2(dir_rd_set2),
    .rd_way2(dir_rd_way2),
    .rd_tag2(dir_rd_tag2),
    .rd_state2(dir_rd_state2),
    .rd_shared2(dir_rd_shared2),
    .rd_sharer_set2(dir_rd_sharer_set2),
    .num_empty_ways2(dir_num_empty_ways2),
    .empty_way2(dir_empty_way2),

    .wr_en2(dir_wr_en2),
    .wr_set2(dir_wr_set2),
    .wr_way2(dir_wr_way2),
    .wr_tag2(dir_wr_tag2),
    .wr_state2(dir_wr_state2),
    .wr_sharer_set2(dir_wr_sharer_set2)
);



////////////////////////////////////////////////////
// first triplet
////////////////////////////////////////////////////

wire mshr_out1_p1_write_en;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_p1_write_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out1_p1_write_data;
wire [`MA_MSHR_INDEX_WIDTH:0] mshr_out1_p1_empty_slots;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_p1_empty_index;

wire mshr_out1_p2_write_en;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out1_p2_write_data;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_p2_read_index;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_p2_write_index;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_out1_p2_rd_state;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out1_p2_rd_data;

// wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_pending_index;
// wire mshr_out1_pending;
wire [`MA_SHARER_BITS_WIDTH:0] mshr_out1_inv_counter;
wire mshr_out1_hit;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out1_hit_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out1_cam_data;
// wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out1_pending_data;

multichip_adapter_mshr mshr_out1 (
    .clk(clk),
    .rst_n(rst_n),
    .pipe_wr_sel(mshr_out1_p2_write_en),

    .wr_state_en1(mshr_out1_p1_write_en),
    .wr_data_en1(mshr_out1_p1_write_en),
    .wr_counter_en1(1'b0),
    .state_in1(`MA_MSHR_STATE_WAIT),
    .data_in1(mshr_out1_p1_write_data),
    .data_mask_in1({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in1({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .wr_index_in1(mshr_out1_p1_write_index),
    .addr_in1(`MA_MSHR_ADDR_IN_WIDTH'b0),
    .empty_slots(mshr_out1_p1_empty_slots),
    .empty_index(mshr_out1_p1_empty_index),

    .wr_state_en2(mshr_out1_p2_write_en),
    .wr_data_en2(mshr_out1_p2_write_en),
    .wr_counter_en2(1'b0),
    .dec_counter_en2(1'b0),
    .state_in2(`MA_MSHR_STATE_INVAL),
    .data_in2(mshr_out1_p2_write_data),
    .data_mask_in2({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in2({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .rd_index_in2(mshr_out1_p2_read_index),
    .wr_index_in2(mshr_out1_p2_write_index),
    .inv_counter_rd_index_in2(`MA_MSHR_INDEX_WIDTH'b0),
    .rd_state_out(mshr_out1_p2_rd_state),
    .rd_data_out(mshr_out1_p2_rd_data),

    .cam_en1(1'b0),
    .hit(mshr_out1_hit),
    .hit_index(mshr_out1_hit_index),
    .cam_data_out(mshr_out1_cam_data),
    // .pending_data_out(mshr_out1_pending_data),
    // .pending(mshr_out1_pending),
    // .pending_index(mshr_out1_pending_index),
    // .pending_ready1(1'b1), 
    .inv_counter_out(mshr_out1_inv_counter)
);

wire mshr_in2_p2_write_en;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_p2_write_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in2_p2_write_data;
wire [`MA_SHARER_BITS_WIDTH:0] mshr_in2_p2_write_counter;
wire [`MA_MSHR_INDEX_WIDTH:0] mshr_in2_p2_empty_slots;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_p2_empty_index;

wire mshr_in2_p3_write_en;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in2_p3_write_data;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_p3_read_index;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_p3_write_index;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_in2_p3_rd_state;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in2_p3_rd_data;
wire mshr_in2_p3_counter_dec_en;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_in2_p3_write_state;

// wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_pending_index;
// wire mshr_in2_pending;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_p3_inv_index;
wire [`MA_SHARER_BITS_WIDTH:0] mshr_in2_p3_inv_counter;
wire mshr_in2_hit;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in2_hit_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in2_cam_data;
// wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in2_pending_data;

multichip_adapter_mshr mshr_in2 (
    .clk(clk),
    .rst_n(rst_n),
    .pipe_wr_sel(mshr_in2_p3_write_en),

    .wr_state_en1(mshr_in2_p2_write_en),
    .wr_data_en1(mshr_in2_p2_write_en),
    .wr_counter_en1(mshr_in2_p2_write_en),
    .state_in1(`MA_MSHR_STATE_WAIT),
    .data_in1(mshr_in2_p2_write_data),
    .data_mask_in1({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in1(mshr_in2_p2_write_counter),
    .wr_index_in1(mshr_in2_p2_write_index),
    .addr_in1(`MA_MSHR_ADDR_IN_WIDTH'b0),
    .empty_slots(mshr_in2_p2_empty_slots),
    .empty_index(mshr_in2_p2_empty_index),

    .wr_state_en2(mshr_in2_p3_write_en),
    .wr_data_en2(mshr_in2_p3_write_en),
    .wr_counter_en2(1'b0),
    .dec_counter_en2(mshr_in2_p3_counter_dec_en),
    .state_in2(mshr_in2_p3_write_state),
    .data_in2(mshr_in2_p3_write_data),
    .data_mask_in2({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in2({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .rd_index_in2(mshr_in2_p3_read_index),
    .wr_index_in2(mshr_in2_p3_write_index),
    .inv_counter_rd_index_in2(mshr_in2_p3_inv_index),
    .rd_state_out(mshr_in2_p3_rd_state),
    .rd_data_out(mshr_in2_p3_rd_data),

    .cam_en1(1'b0),
    .hit(mshr_in2_hit),
    .hit_index(mshr_in2_hit_index),
    .cam_data_out(mshr_in2_cam_data),
    // .pending_data_out(mshr_in2_pending_data),
    // .pending(mshr_in2_pending),
    // .pending_index(mshr_in2_pending_index),
    // .pending_ready1(1'b1),
    .inv_counter_out(mshr_in2_p3_inv_counter)
);


multichip_adapter_outpipe1 outpipe1 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),
    
    .noc_val(noc1_val_in),
    .noc_data(noc1_data_in),
    .noc_rdy(noc1_rdy_in),

    .cep_val(cep_queue1_val_out),
    .cep_data(cep_queue1_data_out),
    .cep_chipid(cep_queue1_chipid_out),
    .cep_rdy(cep_queue1_rdy_out), 

    .mshr_empty_index(mshr_out1_p1_empty_index),
    .mshr_empty_slots(mshr_out1_p1_empty_slots),
    .mshr_write_en(mshr_out1_p1_write_en),
    .mshr_write_index(mshr_out1_p1_write_index),
    .mshr_write_data(mshr_out1_p1_write_data), 
    .stall_mshr_from_p2(mshr_out1_p2_write_en),

    .dir_rd_en(dir_rd_en1),
    .dir_rd_addr(dir_rd_addr1),
    .dir_rd_hit(dir_rd_hit1),
    .dir_rd_set(dir_rd_set1),
    .dir_rd_way(dir_rd_way1),
    .dir_rd_tag(dir_rd_tag1),
    .dir_rd_state(dir_rd_state1),
    .dir_rd_shared(dir_rd_shared1),
    .dir_rd_sharer_set(dir_rd_sharer_set1),
    .dir_num_empty_ways(dir_num_empty_ways1),
    .dir_empty_way(dir_empty_way1),
    .dir_rd_stall_from_p2(dir_rd_en2)
);

multichip_adapter_inpipe2 inpipe2 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),

    .noc_val(noc2_val_out),
    .noc_data(noc2_data_out),
    .noc_rdy(noc2_rdy_out),

    .cep_val(cep_queue2_val_in),
    .cep_data(cep_queue2_data_in),
    .cep_rdy(cep_queue2_rdy_in),

    .mshr_in_empty_index(mshr_in2_p2_empty_index),
    .mshr_in_empty_slots(mshr_in2_p2_empty_slots),
    .mshr_in_write_en(mshr_in2_p2_write_en),
    .mshr_in_write_index(mshr_in2_p2_write_index),
    .mshr_in_write_data(mshr_in2_p2_write_data),
    .mshr_in_write_counter(mshr_in2_p2_write_counter),
    .stall_mshr_in_from_p3(mshr_in2_p3_write_en),

    .mshr_out_write_en(mshr_out1_p2_write_en),
    .mshr_out_write_index(mshr_out1_p2_write_index),
    .mshr_out_write_data(mshr_out1_p2_write_data),
    .mshr_out_read_index(mshr_out1_p2_read_index),
    .mshr_out_read_data(mshr_out1_p2_rd_data),
    .mshr_out_read_state(mshr_out1_p2_rd_state),

    .dir_rd_en(dir_rd_en2),
    .dir_rd_addr(dir_rd_addr2),
    .dir_rd_hit(dir_rd_hit2),
    .dir_rd_set(dir_rd_set2),
    .dir_rd_way(dir_rd_way2),
    .dir_rd_tag(dir_rd_tag2),
    .dir_rd_state(dir_rd_state2),
    .dir_rd_shared(dir_rd_shared2),
    .dir_rd_sharer_set(dir_rd_sharer_set2),
    .dir_num_empty_ways(dir_num_empty_ways2),
    .dir_empty_way(dir_empty_way2),
    .dir_wr_en(dir_wr_en2),
    .dir_wr_set(dir_wr_set2),
    .dir_wr_way(dir_wr_way2),
    .dir_wr_tag(dir_wr_tag2),
    .dir_wr_state(dir_wr_state2),
    .dir_wr_sharer_set(dir_wr_sharer_set2)
);

multichip_adapter_outpipe3 outpipe3 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),
    
    .noc_val(noc3_val_in),
    .noc_data(noc3_data_in),
    .noc_rdy(noc3_rdy_in),

    .cep_val(cep_queue3_val_out),
    .cep_data(cep_queue3_data_out),
    .cep_chipid(cep_queue3_chipid_out),
    .cep_rdy(cep_queue3_rdy_out), 

    .mshr_write_en(mshr_in2_p3_write_en),
    .mshr_write_index(mshr_in2_p3_write_index),
    .mshr_write_data(mshr_in2_p3_write_data),
    .mshr_write_state(mshr_in2_p3_write_state),
    .mshr_read_index(mshr_in2_p3_read_index),
    .mshr_read_data(mshr_in2_p3_rd_data),
    .mshr_read_state(mshr_in2_p3_rd_state),
    .mshr_read_dec_counter_en(mshr_in2_p3_counter_dec_en),
    .mshr_read_inv_counter_index(mshr_in2_p3_inv_index),
    .mshr_read_inv_counter(mshr_in2_p3_inv_counter)
);

/////////////////////////////////
// second triplet
/////////////////////////////////

wire mshr_out2_p2_write_en;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_p2_write_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out2_p2_write_data;
wire [`MA_MSHR_INDEX_WIDTH:0] mshr_out2_p2_empty_slots;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_p2_empty_index;

wire mshr_out2_p3_write_en;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out2_p3_write_data;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_p3_read_index;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_p3_write_index;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_out2_p3_rd_state;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out2_p3_rd_data;

// wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_pending_index;
// wire mshr_out2_pending;
wire [`MA_SHARER_BITS_WIDTH:0] mshr_out2_inv_counter;
wire mshr_out2_hit;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_out2_hit_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out2_cam_data;
// wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_out2_pending_data;

multichip_adapter_mshr mshr_out2 (
    .clk(clk),
    .rst_n(rst_n),
    .pipe_wr_sel(mshr_out2_p3_write_en),

    .wr_state_en1(mshr_out2_p2_write_en),
    .wr_data_en1(mshr_out2_p2_write_en),
    .wr_counter_en1(1'b0),
    .state_in1(`MA_MSHR_STATE_WAIT),
    .data_in1(mshr_out2_p2_write_data),
    .data_mask_in1({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in1({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .wr_index_in1(mshr_out2_p2_write_index),
    .addr_in1(`MA_MSHR_ADDR_IN_WIDTH'b0),
    .empty_index(mshr_out2_p2_empty_index),
    .empty_slots(mshr_out2_p2_empty_slots),

    .wr_state_en2(mshr_out2_p3_write_en),
    .wr_data_en2(mshr_out2_p3_write_en),
    .wr_counter_en2(1'b0),
    .dec_counter_en2(1'b0),
    .state_in2(`MA_MSHR_STATE_INVAL),
    .data_in2(mshr_out2_p3_write_data),
    .data_mask_in2({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in2({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .rd_index_in2(mshr_out2_p3_read_index),
    .wr_index_in2(mshr_out2_p3_write_index),
    .inv_counter_rd_index_in2(`MA_MSHR_INDEX_WIDTH'b0),
    .rd_state_out(mshr_out2_p3_rd_state),
    .rd_data_out(mshr_out2_p3_rd_data),

    .cam_en1(1'b0),
    .hit(mshr_out2_hit),
    .hit_index(mshr_out2_hit_index),
    .cam_data_out(mshr_out2_cam_data),
    // .pending_data_out(mshr_out2_pending_data),
    // .pending(mshr_out2_pending),
    // .pending_index(mshr_out2_pending_index),
    // .pending_ready1(1'b1),
    .inv_counter_out(mshr_out2_inv_counter)
);

wire mshr_in1_p1_write_en;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_p1_write_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in1_p1_write_data;
wire [`MA_MSHR_INDEX_WIDTH:0] mshr_in1_p1_empty_slots;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_p1_empty_index;

wire mshr_in1_p2_write_en;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in1_p2_write_data;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_p2_read_index;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_p2_write_index;
wire [`MA_MSHR_STATE_BITS-1:0] mshr_in1_p2_rd_state;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in1_p2_rd_data;

// wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_pending_index;
// wire mshr_in1_pending;
wire [`MA_SHARER_BITS_WIDTH:0] mshr_in1_inv_counter;
wire mshr_in1_hit;
wire [`MA_MSHR_INDEX_WIDTH-1:0] mshr_in1_hit_index;
wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in1_cam_data;
// wire [`MA_MSHR_ARRAY_WIDTH-1:0] mshr_in1_pending_data;

multichip_adapter_mshr mshr_in1 (
    .clk(clk),
    .rst_n(rst_n),
    .pipe_wr_sel(mshr_in1_p2_write_en),

    .wr_state_en1(mshr_in1_p1_write_en),
    .wr_data_en1(mshr_in1_p1_write_en),
    .wr_counter_en1(1'b0),
    .state_in1(`MA_MSHR_STATE_WAIT),
    .data_in1(mshr_in1_p1_write_data),
    .data_mask_in1({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in1({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .wr_index_in1(mshr_in1_p1_write_index),
    .addr_in1(`MA_MSHR_ADDR_IN_WIDTH'b0),
    .empty_slots(mshr_in1_p1_empty_slots),
    .empty_index(mshr_in1_p1_empty_index),

    .wr_state_en2(mshr_in1_p2_write_en),
    .wr_data_en2(mshr_in1_p2_write_en),
    .wr_counter_en2(1'b0),
    .dec_counter_en2(1'b0),
    .state_in2(`MA_MSHR_STATE_INVAL),
    .data_in2(mshr_in1_p2_write_data),
    .data_mask_in2({`MA_MSHR_ARRAY_WIDTH{1'b1}}),
    .wr_counter_in2({`MA_SHARER_BITS_WIDTH+1{1'b0}}),
    .rd_index_in2(mshr_in1_p2_read_index),
    .wr_index_in2(mshr_in1_p2_write_index),
    .inv_counter_rd_index_in2(`MA_MSHR_INDEX_WIDTH'b0),
    .rd_state_out(mshr_in1_p2_rd_state),
    .rd_data_out(mshr_in1_p2_rd_data),

    .cam_en1(1'b0),
    .hit(mshr_in1_hit),
    .hit_index(mshr_in1_hit_index),
    .cam_data_out(mshr_in1_cam_data),
    // .pending_data_out(mshr_in1_pending_data),
    // .pending(mshr_in1_pending),
    // .pending_index(mshr_in1_pending_index),
    // .pending_ready1(1'b1),
    .inv_counter_out(mshr_in1_inv_counter)
);

multichip_adapter_inpipe1 inpipe1 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),

    .noc_val(noc1_val_out),
    .noc_data(noc1_data_out),
    .noc_rdy(noc1_rdy_out),

    .cep_val(cep_queue1_val_in),
    .cep_data(cep_queue1_data_in),
    .cep_rdy(cep_queue1_rdy_in), 

    .mshr_empty_index(mshr_in1_p1_empty_index),
    .mshr_empty_slots(mshr_in1_p1_empty_slots),
    .mshr_write_en(mshr_in1_p1_write_en),
    .mshr_write_index(mshr_in1_p1_write_index),
    .mshr_write_data(mshr_in1_p1_write_data), 
    .stall_mshr_from_p2(mshr_in1_p2_write_en)
);


multichip_adapter_outpipe2 outpipe2 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),
    
    .noc_val(noc2_val_in),
    .noc_data(noc2_data_in),
    .noc_rdy(noc2_rdy_in),

    .cep_val(cep_queue2_val_out),
    .cep_data(cep_queue2_data_out),
    .cep_chipid(cep_queue2_chipid_out),
    .cep_rdy(cep_queue2_rdy_out), 

    .mshr_out_empty_index(mshr_out2_p2_empty_index),
    .mshr_out_empty_slots(mshr_out2_p2_empty_slots),
    .mshr_out_write_en(mshr_out2_p2_write_en),
    .mshr_out_write_index(mshr_out2_p2_write_index),
    .mshr_out_write_data(mshr_out2_p2_write_data), 
    .stall_mshr_out_from_p3(mshr_out2_p3_write_en), 

    .mshr_in_write_en(mshr_in1_p2_write_en),
    .mshr_in_write_index(mshr_in1_p2_write_index),
    .mshr_in_write_data(mshr_in1_p2_write_data),
    .mshr_in_read_index(mshr_in1_p2_read_index),
    .mshr_in_read_data(mshr_in1_p2_rd_data),
    .mshr_in_read_state(mshr_in1_p2_rd_state)

);

multichip_adapter_inpipe3 inpipe3 (
    .clk(clk), 
    .rst_n(rst_n),
    .mychipid(mychipid),

    .noc_val(noc3_val_out),
    .noc_data(noc3_data_out),
    .noc_rdy(noc3_rdy_out),

    .cep_val(cep_queue3_val_in),
    .cep_data(cep_queue3_data_in),
    .cep_rdy(cep_queue3_rdy_in),

    .mshr_write_en(mshr_out2_p3_write_en),
    .mshr_write_index(mshr_out2_p3_write_index),
    .mshr_write_data(mshr_out2_p3_write_data),
    .mshr_read_index(mshr_out2_p3_read_index),
    .mshr_read_data(mshr_out2_p3_rd_data),
    .mshr_read_state(mshr_out2_p3_rd_state)
);

endmodule