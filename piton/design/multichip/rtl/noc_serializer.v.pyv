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


module noc_serializer(
    input clk,
    input rst_n,
    
    // Noc interface
    output  wire                                   flit_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             flit_data,
    input   wire                                   flit_rdy,

    // deserialized noc packages
    input  wire                                    pkg_val,
    input  wire [`PKG_DATA_WIDTH-1:0]              pkg_data,
    output wire                                    pkg_rdy
);

reg [`PKG_DATA_WIDTH-1:0] dbuf;
reg dbuf_val;
reg [`PAYLOAD_LEN-1:0] dbuf_size;
reg [`MSG_LENGTH_WIDTH-1:0] flit_id;

wire pkg_go = pkg_val & pkg_rdy;
wire flit_go = flit_val & flit_rdy;

always @(posedge clk) begin
    if (~rst_n) begin
        dbuf_val <= 1'b0;
        dbuf <= `PKG_DATA_WIDTH'h0;
        dbuf_size <= `PAYLOAD_LEN'h0;
    end
    else begin
        if (pkg_go) begin
            dbuf_val <= 1'b1;
            dbuf <= pkg_data;
            dbuf_size <= pkg_data[`MSG_LENGTH] + `MSG_LENGTH_WIDTH'd1;
        end
        else if ((flit_id == dbuf_size - `MSG_LENGTH_WIDTH'd1) & flit_go) begin
            dbuf_val <= 1'b0;
            dbuf_size <= `PAYLOAD_LEN'h0;
        end
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        flit_id <= `MSG_LENGTH_WIDTH'h0;
    end
    else begin
        if (pkg_go) begin
            flit_id <= `MSG_LENGTH_WIDTH'h0;
        end
        else if (flit_go) begin
            flit_id <= flit_id + `MSG_LENGTH_WIDTH'd1;
        end
    end
end

assign flit_data = (dbuf >> (`NOC_DATA_WIDTH*flit_id)) & {`NOC_DATA_WIDTH{1'b1}};
assign flit_val = dbuf_val & (flit_id < dbuf_size);
assign pkg_rdy = ~dbuf_val | ((flit_id == dbuf_size - `MSG_LENGTH_WIDTH'd1) & flit_go);

endmodule
