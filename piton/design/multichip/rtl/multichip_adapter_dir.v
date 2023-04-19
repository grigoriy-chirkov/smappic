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

    input wire rd_en,
    input wire [`MA_ADDR_WIDTH-1:0] rd_addr,
    output wire rd_hit,
    output wire [`MA_SET_WIDTH-1:0] rd_set,
    output wire [`MA_WAY_WIDTH-1:0] rd_way,
    output wire [`MA_TAG_WIDTH-1:0] rd_tag,
    output wire [`MA_STATE_WIDTH-1:0] rd_state,
    output wire rd_shared,
    output wire [`MA_OWNER_BITS_WIDTH-1:0] rd_sharer_set,
    output wire [`MA_WAY_WIDTH:0] num_empty_ways,
    output wire [`MA_WAY_WIDTH-1:0] empty_way,

    input wire wr_en,
    input wire [`MA_SET_WIDTH-1:0] wr_set,
    input wire [`MA_WAY_WIDTH-1:0] wr_way,
    input wire [`MA_TAG_WIDTH-1:0] wr_tag,
    input wire [`MA_STATE_WIDTH-1:0] wr_state,
    input wire [`MA_OWNER_BITS_WIDTH-1:0] wr_sharer_set
);

reg [`MA_ADDR_WIDTH-1:0] rd_addr_f;

always @(posedge clk) begin
  if (~rst_n) begin
    rd_addr_f <= `MA_ADDR_WIDTH'h0;
  end
  else begin
    if (rd_en) 
      rd_addr_f <= rd_addr;
  end
end

wire [`MA_WIDTH-1:0] read_data_out;
wire [`MA_WIDTH-1:0] write_data_in;
wire [`MA_WIDTH-1:0] write_mask_in;


multichip_adapter_dir_decoder decoder(
  .data_in(read_data_out),
  .addr_in(rd_addr_f),

  .hit(rd_hit),
  .set(rd_set), 
  .way(rd_way), 
  .tag(rd_tag),
  .state(rd_state), 
  .shared(rd_shared),
  .sharer_set(rd_sharer_set),
  .num_empty_ways(num_empty_ways),
  .empty_way(empty_way)
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
    .BWA            (`MA_ENTRY_WIDTH'h0),
    .DINA           (`MA_ENTRY_WIDTH'h0),
    .DOUTA          (read_data_out),

    .CEB            (wr_en),
    .RDWENB         (1'b0),
    .AB             (wr_set),
    .BWB            (write_mask_in),
    .DINB           (write_data_in),
    .DOUTB          ()
);

endmodule
