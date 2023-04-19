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

module multichip_adapter_dir_encoder (
    output reg [`MA_WIDTH-1:0] data_out,
    output reg [`MA_WIDTH-1:0] mask_out,

    input wire [`MA_WAY_WIDTH-1:0] way,
    input wire [`MA_TAG_WIDTH-1:0] tag,
    input wire [`MA_STATE_WIDTH-1:0] state,
    input wire [`MA_OWNER_BITS_WIDTH-1:0] sharer_set
);

reg [`MA_ENTRY_WIDTH-1:0] entry;


always @(*) begin
  entry = `MA_ENTRY_WIDTH'h0;
  entry[`MA_ENTRY_STATE] = state;
  entry[`MA_ENTRY_TAG] = tag;
  entry[`MA_ENTRY_OWNER_BITS] = sharer_set;

  data_out = {{`MA_WIDTH-`MA_ENTRY_WIDTH{1'b0}}, entry} << (way * `MA_ENTRY_WIDTH);
  mask_out = {{`MA_WIDTH-`MA_ENTRY_WIDTH{1'b0}}, {`MA_ENTRY_WIDTH{1'b1}}} << (way * `MA_ENTRY_WIDTH);
end

endmodule
