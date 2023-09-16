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

module multichip_adapter_noc_encoder(
    output reg [`PKG_DATA_WIDTH-1:0] pkg,

    input wire is_request,
    input wire is_response, 
    input wire is_int,

    input wire [`MSG_LAST_SUBLINE_WIDTH-1:0] last_subline,
    input wire [`MSG_SUBLINE_ID_WIDTH-1:0] subline_id,
    input wire [`MSG_MESI_WIDTH-1:0] mesi,
    input wire [`MSG_MSHRID_WIDTH-1:0] mshrid,
    input wire [`MSG_TYPE_WIDTH-1:0] msg_type,
    input wire [`NOC_FBITS_WIDTH-1:0] dst_fbits,
    input wire [`NOC_X_WIDTH-1:0] dst_x,
    input wire [`NOC_Y_WIDTH-1:0] dst_y,
    input wire [`NOC_CHIPID_WIDTH-1:0] dst_chipid,

    input wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size,
    input wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type,
    input wire [`MSG_SUBLINE_VECTOR_WIDTH-1:0] subline_vector,
    input wire [`MSG_ADDR_WIDTH-1:0] addr,

    input wire [`NOC_FBITS_WIDTH-1:0] src_fbits,
    input wire [`NOC_X_WIDTH-1:0] src_x,
    input wire [`NOC_Y_WIDTH-1:0] src_y,
    input wire [`NOC_CHIPID_WIDTH-1:0] src_chipid,

    input wire [7*`NOC_DATA_WIDTH-1:0] data,
    input wire [`MSG_INT_ID_WIDTH-1:0] int_id
);

reg dataless_req;
reg dataful_req;
reg dataless_resp;
reg dataful_resp;
reg [`MSG_LENGTH_WIDTH-1:0] req_size_to_len;
reg [`MSG_LENGTH_WIDTH-1:0] resp_size_to_len;
reg [`MSG_LENGTH_WIDTH-1:0] length;

always @* begin
    dataless_req = (msg_type == `MSG_TYPE_PREFETCH_REQ) | 
                   (msg_type == `MSG_TYPE_NC_LOAD_REQ ) | 
                   (msg_type == `MSG_TYPE_LOAD_REQ    ) | 
                   (msg_type == `MSG_TYPE_STORE_REQ   ) | 
                   (msg_type == `MSG_TYPE_LR_REQ      ) | 
                   (msg_type == `MSG_TYPE_LOAD_FWD    ) | 
                   (msg_type == `MSG_TYPE_STORE_FWD   ) | 
                   (msg_type == `MSG_TYPE_INV_FWD     ) |
                   (msg_type == `MSG_TYPE_WBGUARD_REQ ) ;
    dataful_req  = is_request & ~dataless_req;
    
    dataless_resp = (msg_type == `MSG_TYPE_INV_FWDACK)   | 
                    (msg_type == `MSG_TYPE_STORE_FWDACK) |
                    (msg_type == `MSG_TYPE_LOAD_FWDACK)  |
                    (msg_type == `MSG_TYPE_NODATA_ACK)   ;
    dataful_resp  = is_response & ~dataless_resp;    

    case (data_size)
        `MSG_DATA_SIZE_64B: begin
            req_size_to_len = `MSG_LENGTH_WIDTH'd10;
            resp_size_to_len = `MSG_LENGTH_WIDTH'd8;
        end
        `MSG_DATA_SIZE_32B: begin
            req_size_to_len = `MSG_LENGTH_WIDTH'd6;
            resp_size_to_len = `MSG_LENGTH_WIDTH'd4;
        end
        `MSG_DATA_SIZE_16B: begin
            req_size_to_len = `MSG_LENGTH_WIDTH'd4;
            resp_size_to_len = `MSG_LENGTH_WIDTH'd2;
        end
        default: begin
            req_size_to_len = `MSG_LENGTH_WIDTH'd3;
            resp_size_to_len = `MSG_LENGTH_WIDTH'd1;
        end
    endcase

    length = `MSG_LENGTH_WIDTH'd0;
    if (is_int)
        length = `MSG_LENGTH_WIDTH'd1;
    if (dataless_req)
        length = `MSG_LENGTH_WIDTH'd2;
    if (dataless_resp)
        length = `MSG_LENGTH_WIDTH'd0;
    if (dataful_req)
        length = req_size_to_len;
    if (dataful_resp)
        length = resp_size_to_len;
end

always @ *
begin
    pkg = `PKG_DATA_WIDTH'h0;

    // fill out all fields in pkg
    pkg[`MSG_LAST_SUBLINE] = last_subline;
    pkg[`MSG_SUBLINE_ID] = subline_id;
    pkg[`MSG_MESI] = mesi;
    pkg[`MSG_MSHRID] = mshrid;
    pkg[`MSG_TYPE] = msg_type;
    pkg[`MSG_LENGTH] = length;
    pkg[`MSG_DST_FBITS] = dst_fbits;
    pkg[`MSG_DST_X] = dst_x;
    pkg[`MSG_DST_Y] = dst_y;
    pkg[`MSG_DST_CHIPID] = dst_chipid;

    if (is_request) begin
        pkg[`MSG_DATA_SIZE] = data_size;
        pkg[`MSG_CACHE_TYPE] = cache_type;
        pkg[`MSG_SUBLINE_VECTOR] = subline_vector;
        pkg[`MSG_ADDR_FULL] = addr;

        pkg[`MSG_SRC_FBITS] = src_fbits;
        pkg[`MSG_SRC_X] = src_x;
        pkg[`MSG_SRC_Y] = src_y;
        pkg[`MSG_SRC_CHIPID] = src_chipid;

        pkg[4*`NOC_DATA_WIDTH-1:3*`NOC_DATA_WIDTH] = data[1*`NOC_DATA_WIDTH-1:0*`NOC_DATA_WIDTH];
        pkg[5*`NOC_DATA_WIDTH-1:4*`NOC_DATA_WIDTH] = data[2*`NOC_DATA_WIDTH-1:1*`NOC_DATA_WIDTH];
        pkg[6*`NOC_DATA_WIDTH-1:5*`NOC_DATA_WIDTH] = data[3*`NOC_DATA_WIDTH-1:2*`NOC_DATA_WIDTH];
        pkg[7*`NOC_DATA_WIDTH-1:6*`NOC_DATA_WIDTH] = data[4*`NOC_DATA_WIDTH-1:3*`NOC_DATA_WIDTH];
        pkg[8*`NOC_DATA_WIDTH-1:7*`NOC_DATA_WIDTH] = data[5*`NOC_DATA_WIDTH-1:4*`NOC_DATA_WIDTH];
    end
    else if (is_int) begin
        pkg[`MSG_INT_ID] = int_id;
        pkg[4*`NOC_DATA_WIDTH-1:3*`NOC_DATA_WIDTH] = int_id;
        pkg[5*`NOC_DATA_WIDTH-1:4*`NOC_DATA_WIDTH] = int_id;
        pkg[6*`NOC_DATA_WIDTH-1:5*`NOC_DATA_WIDTH] = int_id;
        pkg[7*`NOC_DATA_WIDTH-1:6*`NOC_DATA_WIDTH] = int_id;
        pkg[8*`NOC_DATA_WIDTH-1:7*`NOC_DATA_WIDTH] = int_id;
    end
    else if (is_response) begin
        pkg[2*`NOC_DATA_WIDTH-1:1*`NOC_DATA_WIDTH] = data[1*`NOC_DATA_WIDTH-1:0*`NOC_DATA_WIDTH];
        pkg[3*`NOC_DATA_WIDTH-1:2*`NOC_DATA_WIDTH] = data[2*`NOC_DATA_WIDTH-1:1*`NOC_DATA_WIDTH];
        pkg[4*`NOC_DATA_WIDTH-1:3*`NOC_DATA_WIDTH] = data[3*`NOC_DATA_WIDTH-1:2*`NOC_DATA_WIDTH];
        pkg[5*`NOC_DATA_WIDTH-1:4*`NOC_DATA_WIDTH] = data[4*`NOC_DATA_WIDTH-1:3*`NOC_DATA_WIDTH];
        pkg[6*`NOC_DATA_WIDTH-1:5*`NOC_DATA_WIDTH] = data[5*`NOC_DATA_WIDTH-1:4*`NOC_DATA_WIDTH];
        pkg[7*`NOC_DATA_WIDTH-1:6*`NOC_DATA_WIDTH] = data[6*`NOC_DATA_WIDTH-1:5*`NOC_DATA_WIDTH];
        pkg[8*`NOC_DATA_WIDTH-1:7*`NOC_DATA_WIDTH] = data[7*`NOC_DATA_WIDTH-1:6*`NOC_DATA_WIDTH];
    end
end

endmodule
