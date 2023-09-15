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

module multichip_adapter_outpipe2 (
    input clk,
    input rst_n,
    input [`CEP_CHIPID_WIDTH-1:0]                 mychipid,
    
    // Noc interface
    input  wire                                   noc_val,
    input  wire [`NOC_DATA_WIDTH-1:0]             noc_data,
    output wire                                   noc_rdy,

    // CEP interace
    output wire                                   cep_val,
    output wire [`CEP_DATA_WIDTH-1:0]             cep_data,
    output wire [`CEP_CHIPID_WIDTH-1:0]           cep_chipid,
    input  wire                                   cep_rdy,

    input  wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_out_empty_index,
    input  wire [`MA_MSHR_INDEX_WIDTH:0]          mshr_out_empty_slots,
    output wire                                   mshr_out_write_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_out_write_index,
    output wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_out_write_data, 
    input  wire                                   stall_mshr_out_from_p3,

    output wire                                   mshr_in_write_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_in_write_index,
    output wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_in_write_data,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_in_read_index,
    input  wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_in_read_data,
    input  wire [`MA_MSHR_STATE_BITS-1:0]         mshr_in_read_state
);




wire stall_S1;
wire stall_S2;
wire stall_S3;

wire val_S1;
reg val_S2;
reg val_S3;

// Stage 1

wire [`PKG_DATA_WIDTH-1:0] pkg_S1;

noc_deserializer noc_deserializer(
    .clk(clk),
    .rst_n(rst_n),

    .flit_val(noc_val),
    .flit_data(noc_data),
    .flit_rdy(noc_rdy),

    .pkg_val(val_S1), 
    .pkg_data(pkg_S1),
    .pkg_rdy(~stall_S1)
);

wire val_S2_next = val_S1 & ~stall_S1;

wire [`MSG_ADDR_WIDTH-1:0] addr_S1;
wire [`MSG_TYPE_WIDTH-1:0] msg_type_S1;
wire [`NOC_X_WIDTH-1:0] src_x_S1;
wire [`NOC_Y_WIDTH-1:0] src_y_S1;
wire [`NOC_CHIPID_WIDTH-1:0] src_chipid_S1;
wire [`NOC_FBITS_WIDTH-1:0] src_fbits_S1;
wire [`MSG_MSHRID_WIDTH-1:0] mshrid_S1;
wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S1;
wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S1;
wire [`MSG_MESI_WIDTH-1:0] mesi_S1;
wire is_req_S1;
wire is_resp_S1;
wire is_int_S1;
wire [`MSG_INT_ID_WIDTH-1:0] int_id_S1;
wire [7*`CEP_WORD_WIDTH-1:0] msg_data_S1;

multichip_adapter_noc_decoder noc_decoder(
    .pkg(pkg_S1),

    .is_request(is_req_S1),
    .is_response(is_resp_S1),
    .is_int(is_int_S1),

    .mesi(mesi_S1),
    .mshrid(mshrid_S1),
    .msg_type(msg_type_S1),

    .data_size(data_size_S1),
    .cache_type(cache_type_S1),
    .addr(addr_S1),

    .src_fbits(src_fbits_S1),
    .src_x(src_x_S1),
    .src_y(src_y_S1),
    .src_chipid(src_chipid_S1),

    .data(msg_data_S1),
    .int_id(int_id_S1)
);

assign stall_S1 = stall_S2 & val_S1;

// Stage 1 -> 2

reg [`MSG_TYPE_WIDTH-1:0] msg_type_S2;
reg [`MSG_ADDR_WIDTH-1:0] addr_S2;
reg [`NOC_X_WIDTH-1:0] src_x_S2;
reg [`NOC_Y_WIDTH-1:0] src_y_S2;
reg [`NOC_FBITS_WIDTH-1:0] src_fbits_S2;
reg [`NOC_CHIPID_WIDTH-1:0] src_chipid_S2;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S2;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2;
reg [`MSG_MESI_WIDTH-1:0] mesi_S2;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S2;
reg is_req_S2;
reg is_resp_S2;
reg is_int_S2;
reg [`MSG_INT_ID_WIDTH-1:0] int_id_S2;

always @(posedge clk) begin
    if (~rst_n) begin
        val_S2 <= 1'b0;
        msg_type_S2 <= `MSG_TYPE_WIDTH'b0;
        addr_S2 <= `MSG_ADDR_WIDTH'b0;
        src_x_S2 <= `NOC_X_WIDTH'b0;
        src_y_S2 <= `NOC_Y_WIDTH'b0;
        src_fbits_S2 <= `NOC_FBITS_WIDTH'b0;
        src_chipid_S2 <= `NOC_CHIPID_WIDTH'b0;
        mshrid_S2 <= `MSG_MSHRID_WIDTH'b0;
        data_size_S2 <= `MSG_DATA_SIZE_WIDTH'b0;
        cache_type_S2 <= `MSG_CACHE_TYPE_WIDTH'b0;
        mesi_S2 <= `MSG_MESI_WIDTH'b0;
        msg_data_S2 <= {7*`CEP_WORD_WIDTH{1'b0}};
        int_id_S2 <= `MSG_INT_ID_WIDTH'b0;
        is_req_S2 <= 1'b0;
        is_resp_S2 <= 1'b0;
        is_int_S2 <= 1'b0;
    end
    else if (~stall_S2) begin
        val_S2 <= val_S2_next;
        msg_type_S2 <= msg_type_S1;
        addr_S2 <= addr_S1;
        src_x_S2 <= src_x_S1;
        src_y_S2 <= src_y_S1;
        src_fbits_S2 <= src_fbits_S1;
        src_chipid_S2 <= src_chipid_S1;
        mshrid_S2 <= mshrid_S1;
        data_size_S2 <= data_size_S1;
        cache_type_S2 <= cache_type_S1;
        mesi_S2 <= mesi_S1;
        msg_data_S2 <= msg_data_S1;
        int_id_S2 <= int_id_S1;
        is_req_S2 <= is_req_S1;
        is_resp_S2 <= is_resp_S1;
        is_int_S2 <= is_int_S1;
    end 
end

// Stage 2

wire val_S3_next = val_S2 & ~stall_S2;

wire do_read_mshr_S2 = is_resp_S2;
assign mshr_in_write_en = val_S2 & ~stall_S2 & do_read_mshr_S2;
assign mshr_in_write_index = mshrid_S2[`MA_MSHR_INDEX_WIDTH-1:0];
assign mshr_in_write_data = `MA_MSHR_ARRAY_WIDTH'b0;
assign mshr_in_read_index = mshrid_S2[`MA_MSHR_INDEX_WIDTH-1:0];

wire [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S2;
wire [`NOC_CHIPID_WIDTH-1:0] resp_chipid_S2;

multichip_adapter_mshr_decoder mshr_decoder(
    .data(mshr_in_read_data),

    .mshrid(resp_mshrid_S2),
    .src_chipid(resp_chipid_S2)
);


wire do_write_mshr_S2 = is_req_S2;
assign mshr_out_write_en = val_S2 & ~stall_S2 & do_write_mshr_S2;
assign mshr_out_write_index = mshr_out_empty_index;

multichip_adapter_mshr_encoder mshr_encoder(
    .data(mshr_out_write_data),

    .addr(addr_S2),
    .way(`MA_WAY_WIDTH'd0),
    .mshrid(mshrid_S2),
    .cache_type(cache_type_S2),
    .data_size(data_size_S2),
    .msg_type(msg_type_S2),
    .src_chipid(src_chipid_S2),
    .src_x(src_x_S2),
    .src_y(src_y_S2),
    .src_fbits(src_fbits_S2),
    .smc_miss(1'b0),
    .recycled(1'b0),
    .inv_fwd_pending(1'b0),
    .data0(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data1(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data2(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data3(`MA_MSHR_DATA_CHUNK_WIDTH'b0)
);

wire stall_mshr_out_full_S2 = (mshr_out_empty_slots == {`MA_MSHR_INDEX_WIDTH+1{1'b0}});
wire stall_mshr_S2 = do_write_mshr_S2 & (stall_mshr_out_full_S2 | stall_mshr_out_from_p3);
assign stall_S2 = val_S2 & (stall_S3 | stall_mshr_S2);

// Stage 2 -> 3


reg [`MSG_TYPE_WIDTH-1:0] msg_type_S3;
reg [`MSG_ADDR_WIDTH-1:0] addr_S3;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S3;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S3;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S3;
reg [`MSG_MESI_WIDTH-1:0] mesi_S3;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S3;
reg [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S3;
reg [`NOC_CHIPID_WIDTH-1:0] resp_chipid_S3;
reg [`MSG_INT_ID_WIDTH-1:0] int_id_S3;
reg is_req_S3;
reg is_resp_S3;
reg is_int_S3;

always @(posedge clk) begin
    if (~rst_n) begin
        val_S3 <= 1'b0;
        msg_type_S3 <= `MSG_TYPE_WIDTH'b0;
        addr_S3 <= `MSG_ADDR_WIDTH'b0;
        mshrid_S3 <= `MSG_MSHRID_WIDTH'b0;
        data_size_S3 <= `MSG_DATA_SIZE_WIDTH'b0;
        cache_type_S3 <= `MSG_CACHE_TYPE_WIDTH'b0;
        mesi_S3 <= `MSG_MESI_WIDTH'b0;
        msg_data_S3 <= {7*`CEP_WORD_WIDTH{1'b0}};
        resp_mshrid_S3 <= `MSG_MSHRID_WIDTH'b0;
        resp_chipid_S3 <= `NOC_CHIPID_WIDTH'b0;
        int_id_S3 <= `MSG_INT_ID_WIDTH'b0;
        is_req_S3 <= 1'b0;
        is_resp_S3 <= 1'b0;
        is_int_S3 <= 1'b0;
    end
    else if (~stall_S3) begin
        val_S3 <= val_S3_next;
        msg_type_S3 <= msg_type_S2;
        addr_S3 <= addr_S2;
        mshrid_S3 <= {{`MSG_MSHRID_WIDTH-`MA_MSHR_INDEX_WIDTH{1'b0}}, mshr_out_empty_index};
        data_size_S3 <= data_size_S2;
        cache_type_S3 <= cache_type_S2;
        mesi_S3 <= mesi_S2;
        msg_data_S3 <= msg_data_S2;
        resp_mshrid_S3 <= resp_mshrid_S2;
        resp_chipid_S3 <= resp_chipid_S2;
        int_id_S3 <= int_id_S2;
        is_req_S3 <= is_req_S2;
        is_resp_S3 <= is_resp_S2;
        is_int_S3 <= is_int_S2;
    end
end

// Stage 3

wire [`CEP_DATA_WIDTH-1:0] cep_pkg_S3;
cep_encoder cep_encoder(
    .cep_pkg(cep_pkg_S3),
    
    .is_request(is_req_S3),
    .is_response(is_resp_S3),
    .is_int(is_int_S3),
    .last_subline(1'b0),
    .subline_id(`MSG_SUBLINE_ID_WIDTH'b0),
    .mesi(mesi_S3),
    .mshrid(is_req_S3 ? mshrid_S3 : resp_mshrid_S3),
    .msg_type(msg_type_S3),

    .data_size(data_size_S3),
    .cache_type(cache_type_S3),
    .addr(addr_S3),

    .src_chipid(mychipid),

    .data(msg_data_S3),
    .int_id(int_id_S3)
);

assign stall_S3 = ~cep_rdy & val_S3;

assign cep_val = val_S3;
assign cep_data = cep_pkg_S3;
// TODO: fix this hack
assign cep_chipid = is_req_S3 ? {{`CEP_CHIPID_WIDTH-1{1'b0}}, ~mychipid[0]} : resp_chipid_S3[`CEP_CHIPID_WIDTH-1:0];


// sanity checks 


reg mshr_err;
reg chipid_err;

always @(posedge clk) begin
    if (~rst_n) begin
        mshr_err <= 1'b0;
        chipid_err <= 1'b0;
    end
    else begin
        mshr_err <= mshr_err | (mshr_in_write_en & (mshr_in_read_state == `MA_MSHR_STATE_INVAL));
        chipid_err <= chipid_err | (cep_val & (cep_chipid == mychipid));
    end
end


endmodule