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

module cep_decoder(
    input wire [`CEP_DATA_WIDTH-1:0] cep_pkg,

    output reg is_request,
    output reg [`CEP_LAST_SUBLINE_WIDTH-1:0] last_subline,
    output reg [`CEP_SUBLINE_ID_WIDTH-1:0] subline_id,
    output reg [`CEP_MESI_WIDTH-1:0] mesi,
    output reg [`CEP_MSHRID_WIDTH-1:0] mshrid,
    output reg [`CEP_MSG_TYPE_WIDTH-1:0] msg_type,
    output reg [`CEP_LENGTH_WIDTH-1:0] length,

    output reg [`CEP_DATA_SIZE_WIDTH-1:0] data_size,
    output reg [`CEP_CACHE_TYPE_WIDTH-1:0] cache_type,
    output reg [`CEP_ADDR_WIDTH-1:0] addr,
    output reg [`CEP_CHIPID_WIDTH-1:0] src_chipid,

    output reg [7*`CEP_WORD_WIDTH-1:0] data
);


always @ *
begin
    // fill out all fields in cep_pkg
    last_subline = cep_pkg[`CEP_LAST_SUBLINE];
    subline_id = cep_pkg[`CEP_SUBLINE_ID];
    mesi = cep_pkg[`CEP_MESI];
    mshrid = cep_pkg[`CEP_MSHRID];
    msg_type = cep_pkg[`CEP_MSG_TYPE];
    length = cep_pkg[`CEP_LENGTH];
    is_request = cep_pkg[`CEP_IS_REQ];

    data_size = cep_pkg[`CEP_DATA_SIZE];
    cache_type = cep_pkg[`CEP_CACHE_TYPE];
    addr = cep_pkg[`CEP_ADDR];
    src_chipid = cep_pkg[`CEP_SRC_CHIPID];

    data = {7*`CEP_WORD_WIDTH{1'b0}};
    if (is_request) begin
        data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH] = cep_pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH] = cep_pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
        data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH] = cep_pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH];
        data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = cep_pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH];
        data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = cep_pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH];
    end
    else begin
        data[1*`CEP_WORD_WIDTH-1:0*`CEP_WORD_WIDTH] = cep_pkg[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH];
        data[2*`CEP_WORD_WIDTH-1:1*`CEP_WORD_WIDTH] = cep_pkg[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH];
        data[3*`CEP_WORD_WIDTH-1:2*`CEP_WORD_WIDTH] = cep_pkg[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH];
        data[4*`CEP_WORD_WIDTH-1:3*`CEP_WORD_WIDTH] = cep_pkg[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH];
        data[5*`CEP_WORD_WIDTH-1:4*`CEP_WORD_WIDTH] = cep_pkg[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH];
        data[6*`CEP_WORD_WIDTH-1:5*`CEP_WORD_WIDTH] = cep_pkg[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH];
        data[7*`CEP_WORD_WIDTH-1:6*`CEP_WORD_WIDTH] = cep_pkg[8*`CEP_WORD_WIDTH-1:7*`CEP_WORD_WIDTH];
    end
end

endmodule
