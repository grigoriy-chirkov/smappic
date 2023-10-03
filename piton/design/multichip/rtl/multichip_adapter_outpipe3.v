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


module multichip_adapter_outpipe3 (
    input clk,
    input rst_n,
    input wire [`CEP_CHIPID_WIDTH-1:0]            mychipid,
    
    // Noc interface
    input  wire                                   noc_val,
    input  wire [`NOC_DATA_WIDTH-1:0]             noc_data,
    output wire                                   noc_rdy,

    // CEP interace
    output wire                                   cep_val,
    output reg  [`CEP_DATA_WIDTH-1:0]             cep_data,
    output wire [`CEP_CHIPID_WIDTH-1:0]           cep_chipid,
    input  wire                                   cep_rdy,

    output wire                                   mshr_write_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_write_index,
    output reg  [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_write_data,
    output wire [`MA_MSHR_STATE_BITS-1:0]         mshr_write_state,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_read_index,
    input  wire [`MA_MSHR_ARRAY_WIDTH-1:0]        mshr_read_data,
    input  wire [`MA_MSHR_STATE_BITS-1:0]         mshr_read_state,
    output wire                                   mshr_read_dec_counter_en,
    output wire [`MA_MSHR_INDEX_WIDTH-1:0]        mshr_read_inv_counter_index,
    input wire  [`MA_SHARER_BITS_WIDTH:0]         mshr_read_inv_counter
);




wire stall_S1;
wire stall_S2;
wire stall_S3;

wire val_S1;
reg val_S2;
reg val_S3;

wire recycle_S3;

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
wire [`MSG_LAST_SUBLINE_WIDTH-1:0] last_subline_S1;
wire [`MSG_SUBLINE_ID_WIDTH-1:0] subline_id_S1;
wire is_resp_S1;
wire is_req_S1; // TODO: implement write-backs
wire [7*`CEP_WORD_WIDTH-1:0] msg_data_S1;

multichip_adapter_noc_decoder noc_decoder(
    .pkg(pkg_S1),

    .is_request(is_req_S1),
    .is_response(is_resp_S1),

    .last_subline(last_subline_S1),
    .subline_id(subline_id_S1),
    .mshrid(mshrid_S1),
    .msg_type(msg_type_S1),

    .data_size(data_size_S1),
    .addr(addr_S1),

    .src_fbits(src_fbits_S1),
    .src_x(src_x_S1),
    .src_y(src_y_S1),
    .src_chipid(src_chipid_S1),

    .data(msg_data_S1)
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
reg [`MSG_LAST_SUBLINE_WIDTH-1:0] last_subline_S2;
reg [`MSG_SUBLINE_ID_WIDTH-1:0] subline_id_S2;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S2;
reg is_resp_S2;
reg is_req_S2;

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
        last_subline_S2 <= `MSG_LAST_SUBLINE_WIDTH'b0;
        subline_id_S2 <= `MSG_SUBLINE_ID_WIDTH'b0;
        msg_data_S2 <= {7*`CEP_WORD_WIDTH{1'b0}};
        is_resp_S2 <= 1'b0;
        is_req_S2 <= 1'b0;
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
        last_subline_S2 <= last_subline_S1;
        subline_id_S2 <= subline_id_S1;
        msg_data_S2 <= msg_data_S1;
        is_resp_S2 <= is_resp_S1;
        is_req_S2 <= is_req_S1;
    end 
end

assign stall_S2 = (stall_S3 | recycle_S3) & val_S2;

// Stage 2

wire suppress_next_stage_S2;
wire val_S3_next = val_S2 & ~stall_S2 & ~suppress_next_stage_S2;
wire fwd_ack_S2 = is_resp_S2;
wire long_fwd_ack_S2 = (msg_type_S2 == `MSG_TYPE_STORE_FWDDATAACK) |
                       (msg_type_S2 == `MSG_TYPE_LOAD_FWDDATAACK ) ;
wire do_read_mshr = is_resp_S2;
assign mshr_write_en = val_S2 & ~stall_S2 & do_read_mshr;
assign mshr_write_index = mshrid_S2[`MA_MSHR_INDEX_WIDTH-1:0];
wire not_full_ack_S2 = (fwd_ack_S2 & ((~last_subline_S2 | mshr_read_inv_counter > {{`MA_SHARER_BITS_WIDTH{1'b0}}, 1'b1})));
assign mshr_write_state = not_full_ack_S2 ? mshr_read_state : `MA_MSHR_STATE_INVAL;
assign mshr_read_dec_counter_en = val_S2 & ~stall_S2 & fwd_ack_S2 & last_subline_S2;
assign mshr_read_index = mshrid_S2[`MA_MSHR_INDEX_WIDTH-1:0];
assign mshr_read_inv_counter_index = mshrid_S2[`MA_MSHR_INDEX_WIDTH-1:0];

reg [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] subline_data_S2 [3:0];
reg [3:0] subline_vals_S2;

always @(*) begin
    subline_vals_S2 = mshr_read_data[`MA_MSHR_DATA_VALS];
    subline_data_S2[3] = mshr_read_data[`MA_MSHR_DATA3];
    subline_data_S2[2] = mshr_read_data[`MA_MSHR_DATA2];
    subline_data_S2[1] = mshr_read_data[`MA_MSHR_DATA1];
    subline_data_S2[0] = mshr_read_data[`MA_MSHR_DATA0];
    if (long_fwd_ack_S2) begin
        subline_vals_S2 = subline_vals_S2 | (4'b1 << subline_id_S2);
        subline_data_S2[subline_id_S2] = msg_data_S2[`MA_MSHR_DATA_CHUNK_WIDTH-1:0];
    end
end

always @(*) begin
    if (~suppress_next_stage_S2) begin
        mshr_write_data = `MA_MSHR_ARRAY_WIDTH'b0;
    end
    else begin
        mshr_write_data = mshr_read_data;
        mshr_write_data[`MA_MSHR_DATA_VALS] = subline_vals_S2;
        mshr_write_data[`MA_MSHR_DATA3] = subline_data_S2[3];
        mshr_write_data[`MA_MSHR_DATA2] = subline_data_S2[2];
        mshr_write_data[`MA_MSHR_DATA1] = subline_data_S2[1];
        mshr_write_data[`MA_MSHR_DATA0] = subline_data_S2[0];
    end
end



wire [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S2;
wire [`NOC_CHIPID_WIDTH-1:0] resp_chipid_S2;
wire [`MSG_ADDR_WIDTH-1:0] resp_addr_S2;

multichip_adapter_mshr_decoder mshr_decoder(
    .data(mshr_read_data),

    .addr(resp_addr_S2),
    .mshrid(resp_mshrid_S2),
    .src_chipid(resp_chipid_S2)
);

wire internal_inv_ack_S2 = (resp_chipid_S2 == mychipid) & is_resp_S2;
assign suppress_next_stage_S2 = not_full_ack_S2;

assign stall_S2 = stall_S3 & val_S2;


// Stage 2 -> 3


reg [`MSG_TYPE_WIDTH-1:0] msg_type_S3;
reg [`MSG_ADDR_WIDTH-1:0] addr_S3;
reg [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S3;
reg [`MSG_LAST_SUBLINE_WIDTH-1:0] last_subline_S3;
reg [`MSG_SUBLINE_ID_WIDTH-1:0] subline_id_S3;
reg [7*`CEP_WORD_WIDTH-1:0] msg_data_S3;
reg [`MSG_MSHRID_WIDTH-1:0] resp_mshrid_S3;
reg [`NOC_CHIPID_WIDTH-1:0] resp_chipid_S3;
reg [`MSG_ADDR_WIDTH-1:0] resp_addr_S3;
reg is_resp_S3;
reg is_req_S3;

always @(posedge clk) begin
    if (~rst_n) begin
        val_S3 <= 1'b0;
        msg_type_S3 <= `MSG_TYPE_WIDTH'b0;
        addr_S3 <= `MSG_ADDR_WIDTH'b0;
        data_size_S3 <= `MSG_DATA_SIZE_WIDTH'b0;
        last_subline_S3 <= `MSG_LAST_SUBLINE_WIDTH'b0;
        subline_id_S3 <= `MSG_SUBLINE_ID_WIDTH'b0;
        msg_data_S3 <= {7*`CEP_WORD_WIDTH{1'b0}};
        resp_mshrid_S3 <= `MSG_MSHRID_WIDTH'b0;
        resp_chipid_S3 <= `NOC_CHIPID_WIDTH'b0;
        resp_addr_S3 <= `MSG_ADDR_WIDTH'b0;
        is_resp_S3 <= 1'b0;
        is_req_S3 <= 1'b0;
    end
    else if (~stall_S3 & ~recycle_S3) begin
        val_S3 <= val_S3_next;
        msg_type_S3 <= msg_type_S2;
        addr_S3 <= addr_S2;
        data_size_S3 <= data_size_S2;
        last_subline_S3 <= last_subline_S2;
        subline_id_S3 <= subline_id_S2;
        msg_data_S3 <= msg_data_S2;
        resp_mshrid_S3 <= resp_mshrid_S2;
        resp_chipid_S3 <= resp_chipid_S2;
        resp_addr_S3 <= resp_addr_S2;
        is_resp_S3 <= is_resp_S2;
        is_req_S3 <= is_req_S2;
    end
end

reg [`MA_MSHR_DATA_CHUNK_WIDTH-1:0] subline_data_S3 [3:0];
reg [3:0] subline_vals_S3;


wire [`MSG_SUBLINE_ID_WIDTH-1:0] new_subline_id_S3;
wire [3:0] subline_mask_S3;
wire subline_vals_nz_S3;
always @(posedge clk) begin
    if (~rst_n) begin
        subline_vals_S3 <= 4'b0;
        subline_data_S3[3] <= `MA_MSHR_DATA_CHUNK_WIDTH'b0;
        subline_data_S3[2] <= `MA_MSHR_DATA_CHUNK_WIDTH'b0;
        subline_data_S3[1] <= `MA_MSHR_DATA_CHUNK_WIDTH'b0;
        subline_data_S3[0] <= `MA_MSHR_DATA_CHUNK_WIDTH'b0;
    end
    else if (~stall_S3 & ~recycle_S3 & fwd_ack_S2) begin
        subline_vals_S3 <= subline_vals_S2;
        subline_data_S3[3] <= subline_data_S2[3];
        subline_data_S3[2] <= subline_data_S2[2];
        subline_data_S3[1] <= subline_data_S2[1];
        subline_data_S3[0] <= subline_data_S2[0];
    end
    else if (~stall_S3) begin
        subline_vals_S3 <= subline_vals_S3 & subline_mask_S3;
    end
end

// Stage 3

multichip_adapter_prio_encoder_2 prio_encoder(
    .data_in(subline_vals_S3),
    .data_out(new_subline_id_S3),
    .data_out_mask(subline_mask_S3),
    .nonzero_out(subline_vals_nz_S3)
);

wire internal_inv_ack_S3 = (resp_chipid_S3 == mychipid) & is_resp_S3;
wire fwd_ack_S3 = is_resp_S3;
wire new_last_subline_S3 = ((subline_vals_S3 & subline_mask_S3) == 4'b0);
wire [`CEP_SUBLINE_ID_WIDTH-1:0] send_subline_id_S3 = subline_vals_nz_S3 & fwd_ack_S3 ? new_subline_id_S3 : subline_id_S3;
wire [`CEP_LAST_SUBLINE_WIDTH-1:0] send_last_subline_S3 = subline_vals_nz_S3 & fwd_ack_S3 ? new_last_subline_S3 : last_subline_S3;
wire is_st_ack_S3 = (msg_type_S3 == `MSG_TYPE_STORE_FWDACK) | (msg_type_S3 == `MSG_TYPE_STORE_FWDDATAACK);
wire is_ld_ack_S3 = (msg_type_S3 == `MSG_TYPE_LOAD_FWDACK ) | (msg_type_S3 == `MSG_TYPE_LOAD_FWDDATAACK );
wire [`CEP_MSG_TYPE_WIDTH-1:0] dataaware_st_ack_type_S3 = subline_vals_nz_S3 ? `MSG_TYPE_STORE_FWDDATAACK : `MSG_TYPE_STORE_FWDACK;
wire [`CEP_MSG_TYPE_WIDTH-1:0] dataaware_ld_ack_type_S3 = subline_vals_nz_S3 ? `MSG_TYPE_LOAD_FWDDATAACK : `MSG_TYPE_LOAD_FWDACK;
wire [`CEP_MSG_TYPE_WIDTH-1:0] send_msg_type_S3 = internal_inv_ack_S3 ? `MSG_TYPE_WB_REQ   :
                                                  is_st_ack_S3  ? dataaware_st_ack_type_S3 : 
                                                  is_ld_ack_S3  ? dataaware_ld_ack_type_S3 : 
                                                  fwd_ack_S3    ? `MSG_TYPE_INV_FWDACK     :
                                                                  msg_type_S3              ;
wire [7*`CEP_WORD_WIDTH-1:0] send_data_S3 = is_req_S3 ? msg_data_S3 : {{7*`CEP_WORD_WIDTH-`MA_MSHR_DATA_CHUNK_WIDTH{1'b0}}, subline_data_S3[send_subline_id_S3]};
wire [`MSG_ADDR_WIDTH-1:0] wb_addr_S3 = resp_addr_S3 | ({{`CEP_ADDR_WIDTH-`CEP_SUBLINE_ID_WIDTH{1'b0}}, send_subline_id_S3} << 4);

wire [`CEP_DATA_WIDTH-1:0] cep_pkg_S3;
cep_encoder cep_encoder(
    .cep_pkg(cep_pkg_S3),
    
    .is_request(internal_inv_ack_S3 ? 1'b1 : is_req_S3),
    .is_response(internal_inv_ack_S3 ? 1'b0 : is_resp_S3),
    .is_int(1'b0),
    .last_subline(internal_inv_ack_S3 ? 1'b1 : send_last_subline_S3),
    .subline_id(internal_inv_ack_S3 ? `CEP_SUBLINE_ID_WIDTH'h0 : send_subline_id_S3),
    .mesi(`MSG_MESI_I),
    .mshrid(internal_inv_ack_S3 ? `CEP_MSHRID_WIDTH'h0 : resp_mshrid_S3),
    .msg_type(send_msg_type_S3),

    .data_size(internal_inv_ack_S3 ? `MSG_DATA_SIZE_16B : data_size_S3),
    .cache_type(`CEP_CACHE_TYPE_WIDTH'b0),
    .addr(internal_inv_ack_S3 ? wb_addr_S3 : addr_S3),

    .src_chipid(mychipid),

    .data(send_data_S3),
    .int_id(`CEP_INT_ID_WIDTH'b0)
);

wire [`CEP_CHIPID_WIDTH-1:0] wb_chipid;
multichip_adapter_numa_encoder numa_encoder(
    .addr_in(internal_inv_ack_S3 ? resp_addr_S3 : addr_S3),
    .chipid_out(wb_chipid)
);

wire internal_dataless_ack_S3 = (internal_inv_ack_S3 & ~subline_vals_nz_S3);
assign cep_val = val_S3 & ~internal_dataless_ack_S3;
assign cep_chipid = (send_msg_type_S3 == `MSG_TYPE_WB_REQ) ? wb_chipid : resp_chipid_S3[`CEP_CHIPID_WIDTH-1:0];
assign cep_data = cep_pkg_S3;

assign stall_S3 = ~cep_rdy & val_S3;
assign recycle_S3 = val_S3 & ~new_last_subline_S3;




// sanity checks 

reg mshr_err;
reg chipid_err;

always @(posedge clk) begin
    if (~rst_n) begin
        mshr_err <= 1'b0;
        chipid_err <= 1'b0;
    end
    else begin
        mshr_err <= mshr_err | (mshr_write_en & (mshr_read_state == `MA_MSHR_STATE_INVAL));
        chipid_err <= chipid_err | (cep_val & (cep_chipid == mychipid));
    end
end

endmodule