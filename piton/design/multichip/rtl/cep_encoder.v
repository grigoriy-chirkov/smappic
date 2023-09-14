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


`include "cep_defines.vh"

module cep_encoder(
    output reg [`CEP_DATA_WIDTH-1:0] cep_pkg,

    input wire is_request,
    input wire is_response,
    input wire is_int,

    input wire [`CEP_LAST_SUBLINE_WIDTH-1:0] last_subline,
    input wire [`CEP_SUBLINE_ID_WIDTH-1:0] subline_id,
    input wire [`CEP_MESI_WIDTH-1:0] mesi,
    input wire [`CEP_MSHRID_WIDTH-1:0] mshrid,
    input wire [`CEP_MSG_TYPE_WIDTH-1:0] msg_type,

    input wire [`CEP_DATA_SIZE_WIDTH-1:0] data_size,
    input wire [`CEP_CACHE_TYPE_WIDTH-1:0] cache_type,
    input wire [`CEP_ADDR_WIDTH-1:0] addr,
    input wire [`CEP_CHIPID_WIDTH-1:0] src_chipid,

    input wire [7*`CEP_WORD_WIDTH-1:0] data,
    input wire [`CEP_INT_ID_WIDTH-1:0] int_id
);


always @ *
begin
    cep_pkg = `CEP_DATA_WIDTH'h0;

    // fill out all fields in cep_pkg
    cep_pkg[`CEP_LAST_SUBLINE] = last_subline;
    cep_pkg[`CEP_SUBLINE_ID] = subline_id;
    cep_pkg[`CEP_MESI] = mesi;
    cep_pkg[`CEP_MSHRID] = mshrid;
    cep_pkg[`CEP_MSG_TYPE] = msg_type;
    cep_pkg[`CEP_IS_REQ] = is_request;
    cep_pkg[`CEP_IS_INT] = is_int;
    cep_pkg[`CEP_IS_RESP] = is_response;

    if (is_request) begin
        cep_pkg[`CEP_DATA_SIZE] = data_size;
        cep_pkg[`CEP_CACHE_TYPE] = cache_type;
        cep_pkg[`CEP_ADDR] = addr;
        cep_pkg[`CEP_SRC_CHIPID] = src_chipid;

        cep_pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH];
        cep_pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH];
        cep_pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH] = data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH];
        cep_pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH] = data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        cep_pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH] = data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
    end
    else if (is_int) begin
        cep_pkg[`CEP_INT_ID] = int_id;
    end
    else if (is_response) begin
        cep_pkg[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH] = data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH];
        cep_pkg[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH] = data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH];
        cep_pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH];
        cep_pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        cep_pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH] = data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
        cep_pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH] = data[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH];
        cep_pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH] = data[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH];
    end
end

endmodule
