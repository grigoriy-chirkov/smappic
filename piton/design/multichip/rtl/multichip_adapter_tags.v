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

module multichip_adapter_tags(

    input wire clk,
    input wire rst_n,
    input wire clk_en1,
    input wire clk_en2,
    input wire rdw_en1,
    input wire rdw_en2,
    input wire pdout_en,
    input wire deepsleep,
    input wire pipe_sel,

    input wire [`MA_TAG_INDEX_WIDTH-1:0] addr1,
    input wire [`MA_TAG_ARRAY_WIDTH-1:0] data_in1,
    input wire [`MA_TAG_ARRAY_WIDTH-1:0] data_mask_in1,


    input wire [`MA_TAG_INDEX_WIDTH-1:0] addr2,
    input wire [`MA_TAG_ARRAY_WIDTH-1:0] data_in2,
    input wire [`MA_TAG_ARRAY_WIDTH-1:0] data_mask_in2,

    output wire [`MA_TAG_ARRAY_WIDTH-1:0] data_out,
    output wire [`MA_TAG_ARRAY_WIDTH-1:0] pdata_out

);

reg clk_en;
reg rdw_en;
reg [`MA_TAG_INDEX_WIDTH-1:0] addr;
reg [`MA_TAG_ARRAY_WIDTH-1:0] data_in;
reg [`MA_TAG_ARRAY_WIDTH-1:0] data_mask_in;

always @ *
begin
    if (pipe_sel)
    begin
        clk_en = clk_en2;
        rdw_en = rdw_en2;
        addr = addr2;
        data_in = data_in2;
        data_mask_in = data_mask_in2;
    end
    else
    begin
        clk_en = clk_en1;
        rdw_en = rdw_en1;
        addr = addr1;
        data_in = data_in1;
        data_mask_in = data_mask_in1;
    end
end

multichip_adapter_tags_sram sram(

    .clk            (clk),
    .rst_n          (rst_n),
    .clk_en         (clk_en),
    .rdw_en         (rdw_en),
    .pdout_en       (pdout_en),
    .deepsleep      (deepsleep),
    .addr           (addr),
    .data_in        (data_in),
    .data_mask_in   (data_mask_in),
    .data_out       (data_out),
    .pdata_out      (pdata_out)
);



endmodule

