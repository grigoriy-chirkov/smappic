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

module noc_deserializer (
    input clk,
    input rst_n,
    
    // Noc interface
    input  wire                                   flit_val,
    input  wire [`NOC_DATA_WIDTH-1:0]             flit_data,
    output wire                                   flit_rdy,

    // deserialized noc packages
    output wire                                    pkg_val,
    output wire [`PKG_DATA_WIDTH-1:0]              pkg_data,
    input  wire                                    pkg_rdy
);


wire flit_go = flit_val & flit_rdy;
wire pkg_go = pkg_val & pkg_rdy;

reg [`PKG_DATA_WIDTH-1:0] data_buf;
reg [`PKG_DATA_WIDTH-1:0] data_buf_next;
reg [`MSG_LENGTH_WIDTH-1:0] flit_cnt;
reg [`MSG_LENGTH_WIDTH-1:0] flit_id;

assign pkg_val = (flit_cnt == flit_id) & (flit_cnt > `MSG_LENGTH_WIDTH'd0);
assign flit_rdy = (flit_cnt == `MSG_LENGTH_WIDTH'd0) | (flit_id < flit_cnt) | pkg_go;
assign pkg_data = data_buf;

always @(*) begin
    data_buf_next = data_buf;
    if (flit_id == flit_cnt) begin
        data_buf_next = `PKG_DATA_WIDTH'b0;
        data_buf_next[`NOC_DATA_WIDTH-1:0] = flit_data;
    end
    else begin
        data_buf_next = data_buf | (flit_data << (`NOC_DATA_WIDTH*flit_id));
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        flit_cnt <= `MSG_LENGTH_WIDTH'b0;
        flit_id <= `MSG_LENGTH_WIDTH'b0;
        data_buf <= `PKG_DATA_WIDTH'b0;
    end
    else if (flit_go) begin
        flit_cnt <= (flit_id == flit_cnt) ? flit_data[`MSG_LENGTH] + `MSG_LENGTH_WIDTH'd1 : flit_cnt;
        flit_id <=  (flit_id == flit_cnt) ? `MSG_LENGTH_WIDTH'd1 : flit_id + `MSG_LENGTH_WIDTH'd1;
        data_buf <= data_buf_next;
    end
    else if (pkg_go) begin
        flit_cnt <= `MSG_LENGTH_WIDTH'b0;
        flit_id <= `MSG_LENGTH_WIDTH'b0;
        data_buf <= `PKG_DATA_WIDTH'b0;
    end
end

endmodule