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

module multichip_adapter_mshr_decoder(

    input wire [`L2_MSHR_ARRAY_WIDTH-1:0] data,

    output reg [`L2_MSHR_ADDR_OUT_WIDTH-1:0] addr,
    output reg [`L2_WAYS_WIDTH-1:0] way,
    output reg [`MSG_MSHRID_WIDTH-1:0] mshrid,
    output reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type,
    output reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size,
    output reg [`MSG_TYPE_WIDTH-1:0] msg_type,
    output reg [`MSG_L2_MISS_BITS-1:0] msg_l2_miss,
    output reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid,
    output reg [`MSG_SRC_X_WIDTH-1:0] src_x,
    output reg [`MSG_SRC_Y_WIDTH-1:0] src_y,
    output reg [`MSG_SRC_FBITS_WIDTH-1:0] src_fbits,
    output reg [`MSG_SDID_WIDTH-1:0] sdid,
    output reg [`MSG_LSID_WIDTH-1:0] lsid,
    output reg [`MSG_LSID_WIDTH-1:0] miss_lsid,
    output reg smc_miss,
    output reg recycled,
    output reg inv_fwd_pending

);


always @ *
begin
    addr = data[`L2_MSHR_ADDR];
    way = data[`L2_MSHR_WAY];
    mshrid = data[`L2_MSHR_MSHRID];
    cache_type = data[`L2_MSHR_CACHE_TYPE];
    data_size = data[`L2_MSHR_DATA_SIZE];
    msg_type = data[`L2_MSHR_MSG_TYPE];
    msg_l2_miss = data[`L2_MSHR_L2_MISS];
    src_chipid = data[`L2_MSHR_SRC_CHIPID];
    src_x = data[`L2_MSHR_SRC_X];
    src_y = data[`L2_MSHR_SRC_Y];
    src_fbits = data[`L2_MSHR_SRC_FBITS];
    sdid = data[`L2_MSHR_SDID];
    lsid = data[`L2_MSHR_LSID];
    miss_lsid = data[`L2_MSHR_MISS_LSID];
    smc_miss = data[`L2_MSHR_SMC_MISS];
    recycled = data[`L2_MSHR_RECYCLED];
    inv_fwd_pending = data[`L2_MSHR_INV_FWD_PENDING];
end

endmodule
