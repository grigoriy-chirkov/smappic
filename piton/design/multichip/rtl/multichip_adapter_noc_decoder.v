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


// `include "cep_defines.vh"
`include "define.tmp.h"

module multichip_adapter_noc_decoder(
    input wire [`PKG_DATA_WIDTH-1:0] pkg,

    output reg is_request,
    output reg is_response,
    output reg is_int,

    output reg [`MSG_LAST_SUBLINE_WIDTH-1:0] last_subline,
    output reg [`MSG_SUBLINE_ID_WIDTH-1:0] subline_id,
    output reg [`MSG_MESI_WIDTH-1:0] mesi,
    output reg [`MSG_MSHRID_WIDTH-1:0] mshrid,
    output reg [`MSG_TYPE_WIDTH-1:0] msg_type,
    output reg [`MSG_LENGTH_WIDTH-1:0] length,
    output reg [`NOC_FBITS_WIDTH-1:0] dst_fbits,
    output reg [`NOC_X_WIDTH-1:0] dst_x,
    output reg [`NOC_Y_WIDTH-1:0] dst_y,
    output reg [`NOC_CHIPID_WIDTH-1:0] dst_chipid,

    output reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size,
    output reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type,
    output reg [`MSG_SUBLINE_VECTOR_WIDTH-1:0] subline_vector,
    output reg [`MSG_ADDR_WIDTH-1:0] addr,

    output reg [`NOC_FBITS_WIDTH-1:0] src_fbits,
    output reg [`NOC_X_WIDTH-1:0] src_x,
    output reg [`NOC_Y_WIDTH-1:0] src_y,
    output reg [`NOC_CHIPID_WIDTH-1:0] src_chipid,

    output reg [7*`NOC_DATA_WIDTH-1:0] data,
    output reg [`MSG_INT_ID_WIDTH-1:0] int_id
);


always @ *
begin
    // fill out all fields in pkg
    last_subline = pkg[`MSG_LAST_SUBLINE];
    subline_id = pkg[`MSG_SUBLINE_ID];
    mesi = pkg[`MSG_MESI];
    mshrid = pkg[`MSG_MSHRID];
    msg_type = pkg[`MSG_TYPE];
    length = pkg[`MSG_LENGTH];
    dst_fbits = pkg[`MSG_DST_FBITS];
    dst_x = pkg[`MSG_DST_X];
    dst_y = pkg[`MSG_DST_Y];
    dst_chipid = pkg[`MSG_DST_CHIPID];

    data_size = pkg[`MSG_DATA_SIZE];
    cache_type = pkg[`MSG_CACHE_TYPE];
    subline_vector = pkg[`MSG_SUBLINE_VECTOR];
    addr = pkg[`MSG_ADDR_FULL];

    src_fbits = pkg[`MSG_SRC_FBITS];
    src_x = pkg[`MSG_SRC_X];
    src_y = pkg[`MSG_SRC_Y];
    src_chipid = pkg[`MSG_SRC_CHIPID];

    int_id = pkg[`MSG_INT_ID];

    is_response = (msg_type == `MSG_TYPE_NODATA_ACK)       |
                  (msg_type == `MSG_TYPE_DATA_ACK)         |
                  (msg_type == `MSG_TYPE_LOAD_FWDACK)      |
                  (msg_type == `MSG_TYPE_STORE_FWDACK)     |
                  (msg_type == `MSG_TYPE_LOAD_FWDDATAACK)  |
                  (msg_type == `MSG_TYPE_STORE_FWDDATAACK) |
                  (msg_type == `MSG_TYPE_INV_FWDACK)       |
                  (msg_type == `MSG_TYPE_LOAD_MEM_ACK)     |
                  (msg_type == `MSG_TYPE_STORE_MEM_ACK)    |
                  (msg_type == `MSG_TYPE_NC_LOAD_MEM_ACK)  |
                  (msg_type == `MSG_TYPE_NC_STORE_MEM_ACK) ;

    is_int = (msg_type == `MSG_TYPE_INTERRUPT_FWD) | (msg_type == `MSG_TYPE_INTERRUPT);
    
    is_request = (msg_type == `MSG_TYPE_LOAD_FWD)        |
                 (msg_type == `MSG_TYPE_STORE_FWD)       |
                 (msg_type == `MSG_TYPE_INV_FWD)         |
                 (msg_type == `MSG_TYPE_LOAD_MEM)        |
                 (msg_type == `MSG_TYPE_STORE_MEM)       |
                 (msg_type == `MSG_TYPE_NC_LOAD_MEM)     |
                 (msg_type == `MSG_TYPE_NC_STORE_MEM)    |
                 (msg_type == `MSG_TYPE_WB_REQ)          |
                 (msg_type == `MSG_TYPE_LOAD_REQ)        | 
                 (msg_type == `MSG_TYPE_PREFETCH_REQ)    | 
                 (msg_type == `MSG_TYPE_STORE_REQ)       | 
                 (msg_type == `MSG_TYPE_CAS_REQ)         | 
                 (msg_type == `MSG_TYPE_CAS_P1_REQ)      | 
                 (msg_type == `MSG_TYPE_CAS_P2Y_REQ)     | 
                 (msg_type == `MSG_TYPE_CAS_P2N_REQ)     | 
                 (msg_type == `MSG_TYPE_SWAP_REQ)        | 
                 (msg_type == `MSG_TYPE_SWAP_P1_REQ)     | 
                 (msg_type == `MSG_TYPE_SWAP_P2_REQ)     | 
                 (msg_type == `MSG_TYPE_WBGUARD_REQ)     | 
                 (msg_type == `MSG_TYPE_NC_LOAD_REQ)     | 
                 (msg_type == `MSG_TYPE_NC_STORE_REQ)    | 
                 (msg_type == `MSG_TYPE_AMO_ADD_REQ)     | 
                 (msg_type == `MSG_TYPE_AMO_AND_REQ)     | 
                 (msg_type == `MSG_TYPE_AMO_OR_REQ)      | 
                 (msg_type == `MSG_TYPE_AMO_XOR_REQ)     | 
                 (msg_type == `MSG_TYPE_AMO_MAX_REQ)     | 
                 (msg_type == `MSG_TYPE_AMO_MAXU_REQ)    | 
                 (msg_type == `MSG_TYPE_AMO_MIN_REQ)     | 
                 (msg_type == `MSG_TYPE_AMO_MINU_REQ)    | 
                 (msg_type == `MSG_TYPE_AMO_ADD_P1_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_AND_P1_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_OR_P1_REQ)   | 
                 (msg_type == `MSG_TYPE_AMO_XOR_P1_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MAX_P1_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MAXU_P1_REQ) | 
                 (msg_type == `MSG_TYPE_AMO_MIN_P1_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MINU_P1_REQ) | 
                 (msg_type == `MSG_TYPE_AMO_ADD_P2_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_AND_P2_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_OR_P2_REQ)   | 
                 (msg_type == `MSG_TYPE_AMO_XOR_P2_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MAX_P2_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MAXU_P2_REQ) | 
                 (msg_type == `MSG_TYPE_AMO_MIN_P2_REQ)  | 
                 (msg_type == `MSG_TYPE_AMO_MINU_P2_REQ) | 
                 (msg_type == `MSG_TYPE_LR_REQ)          ;

    data = {7*`NOC_DATA_WIDTH{1'b0}};

    if (is_request) begin
        data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH] = pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH] = pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
        data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH] = pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH];
        data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH];
        data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH];
    end
    else begin
        data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH] = pkg[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH];
        data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH] = pkg[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH];
        data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH] = pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
        data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH];
        data[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH] = pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH];
        data[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH] = pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH];
    end
end

endmodule
