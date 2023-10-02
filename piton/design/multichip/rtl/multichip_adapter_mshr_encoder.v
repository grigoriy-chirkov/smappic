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

module multichip_adapter_mshr_encoder(

    output reg [`MA_MSHR_ARRAY_WIDTH-1:0] data,

    input wire [`MA_MSHR_ADDR_OUT_WIDTH-1:0] addr,
    input wire [`MSG_MSHRID_WIDTH-1:0] mshrid,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type,
    input wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type,
    input wire nc,
    input wire [`NOC_CHIPID_WIDTH-1:0] src_chipid,
    input wire [`NOC_X_WIDTH-1:0] src_x,
    input wire [`NOC_Y_WIDTH-1:0] src_y,
    input wire [`NOC_FBITS_WIDTH-1:0] src_fbits,
    input wire smc_miss,
    input wire recycled,
    input wire inv_fwd_pending,
    input wire [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] data0,
    input wire [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] data1,
    input wire [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] data2,
    input wire [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] data3
);


always @ *
begin
    data = `MA_MSHR_ARRAY_WIDTH'b0;
    data[`MA_MSHR_ADDR] = addr;
    data[`MA_MSHR_MSHRID] = mshrid;
    data[`MA_MSHR_CACHE_TYPE] = cache_type;
    data[`MA_MSHR_DATA_SIZE] = data_size;
    data[`MA_MSHR_MSG_TYPE] = msg_type;
    data[`MA_MSHR_NC] = nc;
    data[`MA_MSHR_SRC_CHIPID] = src_chipid;
    data[`MA_MSHR_SRC_X] = src_x;
    data[`MA_MSHR_SRC_Y] = src_y;
    data[`MA_MSHR_SRC_FBITS] = src_fbits;
    data[`MA_MSHR_SMC_MISS] = smc_miss;
    data[`MA_MSHR_RECYCLED] = recycled;
    data[`MA_MSHR_INV_FWD_PENDING] = inv_fwd_pending;
    data[`MA_MSHR_DATA0] = data0;
    data[`MA_MSHR_DATA1] = data1;
    data[`MA_MSHR_DATA2] = data2;
    data[`MA_MSHR_DATA3] = data3;
end

endmodule
