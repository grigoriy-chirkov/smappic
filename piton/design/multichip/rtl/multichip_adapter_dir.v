/*
Copyright (c) 2023 Princeton University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Princeton University nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


`include "multichip_adapter.vh"
`include "define.tmp.h"

module multichip_adapter_dir (
    input wire clk,
    input wire rst_n,
    input wire pipe_rd_sel,
    input wire pipe_wr_sel,

    input wire rd_en1,
    input wire [`MA_ADDR_WIDTH-1:0] rd_addr1,
    output wire rd_hit1,
    output wire [`MA_SET_WIDTH-1:0] rd_set1,
    output wire [`MA_WAY_WIDTH-1:0] rd_way1,
    output wire [`MA_TAG_WIDTH-1:0] rd_tag1,
    output wire [`MA_STATE_WIDTH-1:0] rd_state1,
    output wire rd_shared1,
    output wire [`MA_OWNER_BITS_WIDTH-1:0] rd_sharer_set1,
    output wire [`MA_WAY_WIDTH:0] num_empty_ways1,
    output wire [`MA_WAY_WIDTH-1:0] empty_way1,

    input wire wr_en1,
    input wire [`MA_SET_WIDTH-1:0] wr_set1,
    input wire [`MA_WAY_WIDTH-1:0] wr_way1,
    input wire [`MA_TAG_WIDTH-1:0] wr_tag1,
    input wire [`MA_STATE_WIDTH-1:0] wr_state1,
    input wire [`MA_OWNER_BITS_WIDTH-1:0] wr_sharer_set1,

    input wire rd_en2,
    input wire [`MA_ADDR_WIDTH-1:0] rd_addr2,
    output wire rd_hit2,
    output wire [`MA_SET_WIDTH-1:0] rd_set2,
    output wire [`MA_WAY_WIDTH-1:0] rd_way2,
    output wire [`MA_TAG_WIDTH-1:0] rd_tag2,
    output wire [`MA_STATE_WIDTH-1:0] rd_state2,
    output wire rd_shared2,
    output wire [`MA_OWNER_BITS_WIDTH-1:0] rd_sharer_set2,
    output wire [`MA_WAY_WIDTH:0] num_empty_ways2,
    output wire [`MA_WAY_WIDTH-1:0] empty_way2,

    input wire wr_en2,
    input wire [`MA_SET_WIDTH-1:0] wr_set2,
    input wire [`MA_WAY_WIDTH-1:0] wr_way2,
    input wire [`MA_TAG_WIDTH-1:0] wr_tag2,
    input wire [`MA_STATE_WIDTH-1:0] wr_state2,
    input wire [`MA_OWNER_BITS_WIDTH-1:0] wr_sharer_set2
);

wire rd_en = pipe_rd_sel ? rd_en2 : rd_en1;
wire [`MA_ADDR_WIDTH-1:0] rd_addr = pipe_rd_sel ? rd_addr2 : rd_addr1;
wire wr_en = pipe_wr_sel ? wr_en2 : wr_en1;
wire [`MA_SET_WIDTH-1:0] wr_set = pipe_wr_sel ? wr_set2 : wr_set1;
wire [`MA_WAY_WIDTH-1:0] wr_way = pipe_wr_sel ? wr_way2 : wr_way1;
wire [`MA_TAG_WIDTH-1:0] wr_tag = pipe_wr_sel ? wr_tag2 : wr_tag1;
wire [`MA_STATE_WIDTH-1:0] wr_state = pipe_wr_sel ? wr_state2 : wr_state1;
wire [`MA_OWNER_BITS_WIDTH-1:0] wr_sharer_set = pipe_wr_sel ? wr_sharer_set2 : wr_sharer_set1;



wire [`MA_WIDTH-1:0] read_data_out;
wire [`MA_WIDTH-1:0] write_data_in;
wire [`MA_WIDTH-1:0] write_mask_in;


multichip_adapter_dir_decoder decoder1(
  .clk(clk),
  .rst_n(rst_n),

  .rd_en(rd_en1 & ~pipe_rd_sel),
  .data_in(read_data_out),
  .addr_in(rd_addr1),

  .hit(rd_hit1),
  .set(rd_set1),
  .way(rd_way1),
  .tag(rd_tag1),
  .state(rd_state1),
  .shared(rd_shared1),
  .sharer_set(rd_sharer_set1),
  .num_empty_ways(num_empty_ways1),
  .empty_way(empty_way1)
);

multichip_adapter_dir_decoder decoder2(
  .clk(clk),
  .rst_n(rst_n),

  .rd_en(rd_en2 & pipe_rd_sel),
  .data_in(read_data_out),
  .addr_in(rd_addr2),

  .hit(rd_hit2),
  .set(rd_set2),
  .way(rd_way2),
  .tag(rd_tag2),
  .state(rd_state2),
  .shared(rd_shared2),
  .sharer_set(rd_sharer_set2),
  .num_empty_ways(num_empty_ways2),
  .empty_way(empty_way2)
);

multichip_adapter_dir_encoder encoder(
  .data_out(write_data_in),
  .mask_out(write_mask_in),

  .way(wr_way),
  .tag(wr_tag),
  .state(wr_state),
  .sharer_set(wr_sharer_set)
);

multichip_adapter_dir_sram sram (
    .RESET_N        (rst_n),
    .MEMCLK         (clk),

    .CEA            (rd_en),
    .RDWENA         (1'b1),
    .AA             (rd_addr[`MA_ADDR_SET]),
    .BWA            (`MA_WIDTH'h0),
    .DINA           (`MA_WIDTH'h0),
    .DOUTA          (read_data_out),

    .CEB            (wr_en),
    .RDWENB         (1'b0),
    .AB             (wr_set),
    .BWB            (write_mask_in),
    .DINB           (write_data_in),
    .DOUTB          ()
);

endmodule
