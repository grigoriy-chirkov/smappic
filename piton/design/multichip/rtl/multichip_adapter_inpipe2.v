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


`include "axi_defines.vh"
`include "define.tmp.h"

module multichip_adapter_inpipe2 (
    input clk,
    input rst_n,
    input [`CEP_CHIPID_WIDTH-1:0]                  mychipid,

    // Noc interface
    output  wire                                   noc_val,
    output  wire [`NOC_DATA_WIDTH-1:0]             noc_data,
    input   wire                                   noc_rdy,

    // CEP interace
    input  wire                                    cep_val,
    input  wire  [`CEP_DATA_WIDTH-1:0]             cep_data,
    output wire                                    cep_rdy,

    output wire                                   mshr_out_write_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_out_write_index,
    output wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_out_write_data,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_out_read_index,
    input  wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_out_read_data,
    input  wire [`MA_MSHR_STATE_BITS-1:0]         mshr_out_read_state,

    input  wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_in_empty_index,
    input  wire [`MA_MSHR_INDEX_WIDTH:0]          mshr_in_empty_slots,
    output wire                                   mshr_in_write_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_in_write_index,
    output wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_in_write_data, 
    output wire [`MA_SHARER_BITS_WIDTH:0]         mshr_in_write_counter,
    input  wire                                   stall_mshr_in_from_p3,

    // Dir interface
    output wire                                   dir_rd_en,
    output wire [`MA_ADDR_WIDTH-1:0]              dir_rd_addr,
    input  wire                                   dir_rd_hit,
    input  wire [`MA_SET_WIDTH-1:0]               dir_rd_set,
    input  wire [`MA_WAY_WIDTH-1:0]               dir_rd_way,
    input  wire [`MA_TAG_WIDTH-1:0]               dir_rd_tag,
    input  wire [`MA_STATE_WIDTH-1:0]             dir_rd_state,
    input  wire                                   dir_rd_shared,
    input  wire [`MA_SHARER_SET_WIDTH-1:0]        dir_rd_sharer_set,
    input  wire [`MA_WAY_WIDTH:0]                 dir_num_empty_ways,
    input  wire [`MA_WAY_WIDTH-1:0]               dir_empty_way,

    output wire                                   dir_wr_en,
    output wire [`MA_SET_WIDTH-1:0]               dir_wr_set,
    output wire [`MA_WAY_WIDTH-1:0]               dir_wr_way,
    output wire [`MA_TAG_WIDTH-1:0]               dir_wr_tag,
    output wire [`MA_STATE_WIDTH-1:0]             dir_wr_state,
    output wire [`MA_SHARER_SET_WIDTH-1:0]        dir_wr_sharer_set
);


wire stall_S1;
wire stall_S2;
wire stall_S3;

wire val_S1;
reg val_S2;
reg val_S3;
wire recycle_S3;

// Stage 1

wire val_S2_next = val_S1 & ~stall_S1;

wire is_req_S1;
wire is_resp_S1;
wire is_int_S1;
wire [`CEP_MESI_WIDTH-1:0] mesi_S1;
wire [`CEP_MSHRID_WIDTH-1:0] mshrid_S1;
wire [`CEP_MSG_TYPE_WIDTH-1:0] msg_type_S1;
wire [`CEP_LENGTH_WIDTH-1:0] length_S1;
wire [`CEP_DATA_SIZE_WIDTH-1:0] data_size_S1;
wire [`CEP_CACHE_TYPE_WIDTH-1:0] cache_type_S1;
wire [`CEP_ADDR_WIDTH-1:0] addr_S1;
wire [`CEP_CHIPID_WIDTH-1:0] src_chipid_S1;
wire [7*`CEP_WORD_WIDTH-1:0] msg_data_S1;
wire [`CEP_INT_ID_WIDTH-1:0] int_id_S1;

cep_decoder cep_decoder(
    .cep_pkg(cep_data),

    .is_request(is_req_S1),
    .is_response(is_resp_S1),
    .is_int(is_int_S1),
    .last_subline(),
    .subline_id(),
    .mesi(mesi_S1),
    .mshrid(mshrid_S1),
    .msg_type(msg_type_S1),
    .length(length_S1),

    .data_size(data_size_S1),
    .cache_type(cache_type_S1),
    .addr(addr_S1),

    .src_chipid(src_chipid_S1),

    .data(msg_data_S1),
    .int_id(int_id_S1)
);

assign val_S1 = cep_val;
assign cep_rdy = ~stall_S1;


wire do_read_mshr_S1 = is_resp_S1;
assign mshr_out_write_en = val_S1 & ~stall_S1 & do_read_mshr_S1;
assign mshr_out_write_index = mshrid_S1[`MA_MSHR_INDEX_WIDTH-1:0];
assign mshr_out_write_data = `MA_MSHR_ARRAY_WIDTH'b0;
assign mshr_out_read_index = mshrid_S1[`MA_MSHR_INDEX_WIDTH-1:0];

wire [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S1;
wire [`MSG_SRC_X_WIDTH-1:0] resp_x_S1;
wire [`MSG_SRC_Y_WIDTH-1:0] resp_y_S1;
wire [`MSG_SRC_FBITS_WIDTH-1:0] resp_fbits_S1;
wire [`MSG_ADDR_WIDTH-1:0] resp_addr_S1;

multichip_adapter_mshr_decoder mshr_decoder(
    .data(mshr_out_read_data),

    .addr(resp_addr_S1),
    .way(),
    .mshrid(resp_mshrid_S1),
    .cache_type(),
    .data_size(),
    .msg_type(),
    .msg_l2_miss(),
    .src_chipid(),
    .src_x(resp_x_S1),
    .src_y(resp_y_S1),
    .src_fbits(resp_fbits_S1),
    .sdid(),
    .lsid(),
    .miss_lsid(),
    .smc_miss(),
    .recycled(),
    .inv_fwd_pending(),
    .data0(),
    .data1(), 
    .data2(), 
    .data3()
);

wire do_rd_tag_S1 = (msg_type_S1 != `MSG_TYPE_NC_LOAD_REQ) & (msg_type_S1 != `MSG_TYPE_NC_STORE_REQ) & (msg_type_S1 != `MSG_TYPE_INTERRUPT);
assign dir_rd_en = val_S1 & ~stall_S1 & do_rd_tag_S1;
assign dir_rd_addr = is_resp_S1 ? resp_addr_S1 : addr_S1;

assign stall_S1 = stall_S2 & val_S1;

// Stage 1-> 2

reg [`MSG_TYPE_WIDTH-1:0] msg_type_S2;
reg [`MSG_ADDR_WIDTH-1:0] addr_S2;
reg [`MSG_SRC_CHIPID_WIDTH-1:0] src_chipid_S2;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S2;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2;
reg [`MSG_MESI_WIDTH-1:0] mesi_S2;
reg [`MSG_LENGTH_WIDTH-1:0] length_S2;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S2;
reg [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S2;
reg [`MSG_SRC_X_WIDTH-1:0] resp_x_S2;
reg [`MSG_SRC_Y_WIDTH-1:0] resp_y_S2;
reg [`MSG_SRC_FBITS_WIDTH-1:0] resp_fbits_S2;
reg [`MSG_INT_ID_WIDTH-1:0] int_id_S2;
reg is_req_S2;
reg is_resp_S2;
reg is_int_S2;

always @(posedge clk) begin
    if (~rst_n) begin
        val_S2 <= 1'b0;
        msg_type_S2 <= `MSG_TYPE_WIDTH'b0;
        addr_S2 <= `MSG_ADDR_WIDTH'b0;
        src_chipid_S2 <= `MSG_SRC_CHIPID_WIDTH'b0;
        mshrid_S2 <= `MSG_MSHRID_WIDTH'b0;
        data_size_S2 <= `MSG_DATA_SIZE_WIDTH'b0;
        cache_type_S2 <= `MSG_CACHE_TYPE_WIDTH'b0;
        mesi_S2 <= `MSG_MESI_WIDTH'b0;
        length_S2 <= `MSG_LENGTH_WIDTH'b0;
        msg_data_S2 <= {7*`CEP_WORD_WIDTH{1'b0}};
        resp_mshrid_S2 <= `MSG_MSHRID_WIDTH'b0;
        resp_x_S2 <= `MSG_SRC_X_WIDTH'b0;
        resp_y_S2 <= `MSG_SRC_Y_WIDTH'b0;
        resp_fbits_S2 <= `MSG_SRC_FBITS_WIDTH'b0;
        int_id_S2 <= `MSG_INT_ID_WIDTH'b0;
        is_req_S2 <= 1'b0;
        is_resp_S2 <= 1'b0;
        is_int_S2 <= 1'b0;
    end
    else if (~stall_S2) begin
        val_S2 <= val_S2_next;
        msg_type_S2 <= msg_type_S1;
        addr_S2 <= addr_S1;
        src_chipid_S2 <= {{`MSG_SRC_CHIPID_WIDTH-`CEP_CHIPID_WIDTH{1'b0}}, src_chipid_S1};
        mshrid_S2 <= mshrid_S1;
        data_size_S2 <= data_size_S1;
        cache_type_S2 <= cache_type_S1;
        mesi_S2 <= mesi_S1;
        length_S2 <= length_S1;
        msg_data_S2 <= msg_data_S1;
        resp_mshrid_S2 <= resp_mshrid_S1;
        resp_x_S2 <= resp_x_S1;
        resp_y_S2 <= resp_y_S1;
        resp_fbits_S2 <= resp_fbits_S1;
        int_id_S2 <= int_id_S1;
        is_req_S2 <= is_req_S1;
        is_resp_S2 <= is_resp_S1;
        is_int_S2 <= is_int_S1;
    end
end


// Stage 2

wire val_S3_next = val_S2 & ~stall_S2;
wire inv_msg_S2 = (msg_type_S2 == `MSG_TYPE_STORE_FWD) |
                  (msg_type_S2 == `MSG_TYPE_INV_FWD  ) ;
wire fwd_msg_S2 = inv_msg_S2 | (msg_type_S2 == `MSG_TYPE_LOAD_FWD);

wire do_write_mshr_S2 = is_req_S2;
assign mshr_in_write_en = val_S2 & ~stall_S2 & do_write_mshr_S2;
assign mshr_in_write_index = mshr_in_empty_index;

multichip_adapter_bitsum_64 bitsum(
    .data_in(dir_rd_sharer_set),
    .bitsum_out(mshr_in_write_counter)
);

multichip_adapter_mshr_encoder mshr_encoder(
    .data(mshr_in_write_data),

    .addr(addr_S2),
    .way(`MA_WAY_WIDTH'd0),
    .mshrid(mshrid_S2),
    .cache_type(cache_type_S2),
    .data_size(data_size_S2),
    .msg_type(msg_type_S2),
    .msg_l2_miss(1'b0),
    .src_chipid(src_chipid_S2),
    .src_x({`MSG_SRC_X_WIDTH{1'b1}}),
    .src_y({`MSG_SRC_Y_WIDTH{1'b1}}),
    .src_fbits(`NOC_FBITS_L2),
    .sdid(`MSG_SDID_WIDTH'b0),
    .lsid(`MSG_LSID_WIDTH'b0),
    .miss_lsid(`MSG_LSID_WIDTH'd0),
    .smc_miss(1'b0),
    .recycled(1'b0),
    .inv_fwd_pending(1'b0),
    .data0(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data1(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data2(`MA_MSHR_DATA_CHUNK_WIDTH'b0),
    .data3(`MA_MSHR_DATA_CHUNK_WIDTH'b0)
);


wire do_write_tag_S2 = is_resp_S2 | inv_msg_S2;
assign dir_wr_en = val_S2 & ~stall_S2 & do_write_tag_S2;
assign dir_wr_set = dir_rd_set;
assign dir_wr_way = dir_rd_hit ? dir_rd_way : dir_empty_way;
assign dir_wr_tag = dir_rd_tag;

wire [`HOME_ID_WIDTH-1:0] resp_flat_id_S2;
xy_to_flat_id xy_to_flat_id(
    .x_coord(resp_x_S2),
    .y_coord(resp_y_S2),
    .flat_id(resp_flat_id_S2)
);

reg [`MA_SHARER_SET_WIDTH-1:0] new_sharer_set_S2;
always @(*) begin
    new_sharer_set_S2 = (`MA_SHARER_SET_WIDTH'b1 << resp_flat_id_S2);
    if (dir_rd_hit) 
        new_sharer_set_S2 = new_sharer_set_S2 | dir_rd_sharer_set;
end

assign dir_wr_sharer_set = inv_msg_S2 ? `MA_SHARER_SET_WIDTH'b0 : new_sharer_set_S2;
assign dir_wr_state = inv_msg_S2 ? `MA_STATE_INVALID : `MA_STATE_VALID;

wire stall_mshr_in_full_S2 = (mshr_in_empty_slots == {`MA_MSHR_INDEX_WIDTH+1{1'b0}});
wire stall_mshr_S2 = do_write_mshr_S2 & (stall_mshr_in_full_S2 | stall_mshr_in_from_p3);
assign stall_S2 = val_S2 & (stall_S3 | stall_mshr_S2 | recycle_S3);



// Stage 2-> 3

reg [`MSG_TYPE_WIDTH-1:0] msg_type_S3;
reg [`MSG_ADDR_WIDTH-1:0] addr_S3;
reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S3;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S3;
reg [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S3;
reg [`MSG_MESI_WIDTH-1:0] mesi_S3;
reg [`MSG_LENGTH_WIDTH-1:0] length_S3;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S3;
reg [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S3;
reg [`MSG_SRC_X_WIDTH-1:0] resp_x_S3;
reg [`MSG_SRC_Y_WIDTH-1:0] resp_y_S3;
reg [`MSG_SRC_FBITS_WIDTH-1:0] resp_fbits_S3;
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
        length_S3 <= `MSG_LENGTH_WIDTH'b0;
        msg_data_S3 <= {7*`CEP_WORD_WIDTH{1'b0}};
        resp_mshrid_S3 <= `MSG_MSHRID_WIDTH'b0;
        resp_x_S3 <= `MSG_SRC_X_WIDTH'b0;
        resp_y_S3 <= `MSG_SRC_Y_WIDTH'b0;
        resp_fbits_S3 <= `MSG_SRC_FBITS_WIDTH'b0;
        int_id_S3 <= `MSG_INT_ID_WIDTH'b0;
        is_req_S3 <= 1'b0;
        is_resp_S3 <= 1'b0;
        is_int_S3 <= 1'b0;
    end
    else if (~stall_S3 & ~recycle_S3) begin
        val_S3 <= val_S3_next;
        msg_type_S3 <= msg_type_S2;
        addr_S3 <= addr_S2;
        mshrid_S3 <= {{`MSG_MSHRID_WIDTH-`MA_MSHR_INDEX_WIDTH{1'b0}}, mshr_in_empty_index};
        data_size_S3 <= data_size_S2;
        cache_type_S3 <= cache_type_S2;
        mesi_S3 <= mesi_S2;
        length_S3 <= length_S2;
        msg_data_S3 <= msg_data_S2;
        resp_mshrid_S3 <= resp_mshrid_S2;
        resp_x_S3 <= resp_x_S2;
        resp_y_S3 <= resp_y_S2;
        resp_fbits_S3 <= resp_fbits_S2;
        int_id_S3 <= int_id_S2;
        is_req_S3 <= is_req_S2;
        is_resp_S3 <= is_resp_S2;
        is_int_S3 <= is_int_S2;
    end
end

reg [`MA_SHARER_SET_WIDTH-1:0] fwd_set_S3;
wire [`MA_SHARER_SET_WIDTH-1:0] fwd_set_mask_S3;

always @(posedge clk) begin
    if (~rst_n) begin
        fwd_set_S3 <= `MA_SHARER_SET_WIDTH'b0;
    end
    else if (~stall_S3 & ~recycle_S3 & fwd_msg_S2) begin
        fwd_set_S3 <= dir_rd_sharer_set;
    end
    else if (~stall_S3) begin
        fwd_set_S3 <= fwd_set_S3 & fwd_set_mask_S3;
    end
end


// Stage 3

wire fwd_routine_S3 = |fwd_set_S3;
wire [`MA_SHARER_BITS_WIDTH-1:0] fwd_target_id_S3;

multichip_adapter_prio_encoder_6 prio_encoder
(
    .data_in        (fwd_set_S3),
    .data_out       (fwd_target_id_S3),
    .data_out_mask  (fwd_set_mask_S3),
    .nonzero_out    ()
);
assign recycle_S3 = val_S3 & ((fwd_set_S3 & fwd_set_mask_S3) != `MA_SHARER_SET_WIDTH'b0);

wire [`NOC_X_WIDTH-1:0] fwd_target_x_S3;
wire [`NOC_Y_WIDTH-1:0] fwd_target_y_S3;
flat_id_to_xy flat_id_to_xy(
    .x_coord(fwd_target_x_S3),
    .y_coord(fwd_target_y_S3),
    .flat_id(fwd_target_id_S3)
);

wire [`MSG_DST_X_WIDTH-1:0] int_target_x_S3 = int_id_S3[25:18];
wire [`MSG_DST_Y_WIDTH-1:0] int_target_y_S3 = int_id_S3[33:26];
wire [`MSG_DST_FBITS_WIDTH-1:0] int_target_fbits_S3 = int_id_S3[51:48];

wire [`PKG_DATA_WIDTH-1:0] noc_pkg_S3;
wire [`MSG_DST_X_WIDTH-1:0] dst_x_S3 = is_resp_S3 ? resp_x_S3 : 
                                       is_int_S3 ? int_target_x_S3 :
                                       fwd_routine_S3 ? fwd_target_x_S3 :
                                       `MSG_DST_X_WIDTH'b0;
wire [`MSG_DST_Y_WIDTH-1:0] dst_y_S3 = is_resp_S3 ? resp_y_S3 :
                                       is_int_S3 ? int_target_y_S3 :
                                       fwd_routine_S3 ? fwd_target_y_S3 :
                                       `MSG_DST_Y_WIDTH'b0;
wire [`MSG_DST_FBITS_WIDTH-1:0] dst_fbits_S3 = is_resp_S3 ? resp_fbits_S3 :
                                               is_int_S3 ? int_target_fbits_S3 :
                                               fwd_routine_S3 ? `NOC_FBITS_L1 :
                                               `NOC_FBITS_MEM;
wire [`MSG_MSHRID_WIDTH-1:0] dst_mshrid_S3 = is_resp_S3 ? resp_mshrid_S3 : mshrid_S3;

multichip_adapter_noc_encoder noc_encoder(
    .pkg(noc_pkg_S3),
    .is_request(is_req_S3),
    .is_response(is_resp_S3),
    .is_int(is_int_S3),

    .last_subline(1'b0),
    .subline_id(`MSG_SUBLINE_ID_WIDTH'b0),
    .mesi(mesi_S3),
    .mshrid(dst_mshrid_S3),
    .msg_type(msg_type_S3),
    .length(length_S3),
    .dst_fbits(dst_fbits_S3),
    .dst_x(dst_x_S3),
    .dst_y(dst_y_S3),
    .dst_chipid({{`MSG_SRC_CHIPID_WIDTH-`CEP_CHIPID_WIDTH{1'b0}}, mychipid}),

    .data_size(data_size_S3),
    .cache_type(cache_type_S3),
    .subline_vector({`MSG_SUBLINE_VECTOR_WIDTH{1'b1}}),
    .addr(addr_S3),
    .int_id(int_id_S3),

    .src_fbits(`NOC_FBITS_L2),
    .src_x({`MSG_SRC_X_WIDTH{1'b1}}),
    .src_y({`MSG_SRC_Y_WIDTH{1'b1}}),
    .src_chipid({{`MSG_SRC_CHIPID_WIDTH-`CEP_CHIPID_WIDTH{1'b0}}, mychipid}),
    
    .data(msg_data_S3)
);

wire pkg_rdy;

noc_serializer noc_serializer(
    .clk(clk),
    .rst_n(rst_n),

    .flit_val(noc_val),
    .flit_data(noc_data),
    .flit_rdy(noc_rdy),

    .pkg_val(val_S3), 
    .pkg_data(noc_pkg_S3),
    .pkg_rdy(pkg_rdy)
);

assign stall_S3 = ~pkg_rdy & val_S3;


// some sanity checks 

reg mshr_err;
reg dir_miss_err;
reg dir_full_err;

always @(posedge clk) begin
    if (~rst_n) begin
        mshr_err <= 1'b0;
        dir_miss_err <= 1'b0;
        dir_full_err <= 1'b0;
    end
    else begin
        mshr_err <= mshr_err | (mshr_out_write_en & (mshr_out_read_state == `MA_MSHR_STATE_INVAL));
        dir_miss_err <= dir_miss_err | (inv_msg_S2 & dir_wr_en & (dir_rd_state == `MA_STATE_INVALID));
        dir_full_err <= dir_full_err | (dir_wr_en & ~dir_rd_hit & (dir_num_empty_ways == {`MA_WAY_WIDTH+1{1'b0}}));
    end
end



endmodule
