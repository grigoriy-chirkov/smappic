/*
Copyright (c) 2015 Princeton University
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

`include "l2.tmp.h"
`include "define.tmp.h"

module home_agent(

    input wire clk,
    input wire rst_n,

    input wire [`NOC_CHIPID_WIDTH-1:0] chipid,
    input wire [`NOC_X_WIDTH-1:0] coreid_x,
    input wire [`NOC_Y_WIDTH-1:0] coreid_y,

    input wire noc1_valid_in,
    input wire [`NOC_DATA_WIDTH-1:0] noc1_data_in,
    output wire noc1_ready_in,


    input wire noc3_valid_in,
    input wire [`NOC_DATA_WIDTH-1:0] noc3_data_in,
    output wire noc3_ready_in,

    output wire noc2_valid_out,
    output wire [`NOC_DATA_WIDTH-1:0] noc2_data_out,
    input wire noc2_ready_out
);

localparam y = 1'b1;
localparam n = 1'b0;


wire mshr_cam_en_p1;
wire mshr_wr_state_en_p1;
wire mshr_wr_data_en_p1;
wire mshr_pending_ready_p1;
wire [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_p1;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_in_p1;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_mask_in_p1;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_inv_counter_rd_index_in_p1;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_wr_index_in_p1;
wire [`L2_MSHR_ADDR_IN_WIDTH-1:0] mshr_addr_in_p1;

wire mshr_rd_en_p2;
wire mshr_wr_state_en_p2;
wire mshr_wr_data_en_p2;
wire mshr_inc_counter_en_p2;
wire [`L2_MSHR_STATE_BITS-1:0] mshr_state_in_p2;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_in_p2;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] mshr_data_mask_in_p2;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_rd_index_in_p2;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_wr_index_in_p2;

wire mshr_hit;
wire [`L2_MSHR_STATE_BITS-1:0] rd_mshr_state_out;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] rd_mshr_data_out;
wire [`L2_MSHR_ARRAY_WIDTH-1:0] pending_mshr_data_out;

wire [`L2_OWNER_BITS-1:0] mshr_inv_counter_out;
wire [`L2_MSHR_INDEX_WIDTH:0] mshr_empty_slots;
wire mshr_pending;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index;
wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index;

wire state_rd_en_p1;
wire state_wr_en_p1;
wire [`L2_STATE_INDEX_WIDTH-1:0] state_rd_addr_p1;
wire [`L2_STATE_INDEX_WIDTH-1:0] state_wr_addr_p1;
wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_p1;
wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_p1;

wire state_rd_en_p2;
wire state_wr_en_p2;
wire [`L2_STATE_INDEX_WIDTH-1:0] state_rd_addr_p2;
wire [`L2_STATE_INDEX_WIDTH-1:0] state_wr_addr_p2;
wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_in_p2;
wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_mask_in_p2;

wire [`L2_STATE_ARRAY_WIDTH-1:0] state_data_out;

wire tag_clk_en_p1;
wire tag_rdw_en_p1;
wire [`L2_TAG_INDEX_WIDTH-1:0] tag_addr_p1;
wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_in_p1;
wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_mask_in_p1;

wire tag_clk_en_p2;
wire tag_rdw_en_p2;
wire [`L2_TAG_INDEX_WIDTH-1:0] tag_addr_p2;
wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_in_p2;
wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_mask_in_p2;

wire [`L2_TAG_ARRAY_WIDTH-1:0] tag_data_out;

wire dir_clk_en_p1;
wire dir_rdw_en_p1;
wire [`L2_DIR_INDEX_WIDTH-1:0] dir_addr_p1;
wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_in_p1;
wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_mask_in_p1;

wire dir_clk_en_p2;
wire dir_rdw_en_p2;
wire [`L2_DIR_INDEX_WIDTH-1:0] dir_addr_p2;
wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_in_p2;
wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_mask_in_p2;

wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_out;

wire data_clk_en_p1;
wire data_rdw_en_p1;
wire [`L2_DATA_INDEX_WIDTH-1:0] data_addr_p1;
wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_in_p1;
wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_mask_in_p1;

wire data_clk_en_p2;
wire data_rdw_en_p2;
wire [`L2_DATA_INDEX_WIDTH-1:0] data_addr_p2;
wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_in_p2;
wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_mask_in_p2;
wire [`L2_DATA_ARRAY_WIDTH-1:0] data_data_out;

wire reg_rd_en;
wire reg_wr_en;
wire [`L2_ADDR_TYPE_WIDTH-1:0] reg_rd_addr_type;
wire [`L2_ADDR_TYPE_WIDTH-1:0] reg_wr_addr_type;
wire [`L2_REG_WIDTH-1:0] reg_data_out;
wire [`L2_REG_WIDTH-1:0] reg_data_in;
wire l2_access_valid;
wire l2_miss_valid;
wire data_ecc_corr_error;
wire data_ecc_uncorr_error;
wire [`L2_DATA_INDEX_WIDTH-1:0] data_ecc_addr;
wire [`PHY_ADDR_WIDTH-1:0] error_addr;
wire [`NOC_NODEID_WIDTH-1:0] my_nodeid;
wire [`L2_COREID_WIDTH-1:0] core_max;
wire [`L2_SMT_BASE_ADDR_WIDTH-1:0] smt_base_addr;


wire pipe2_valid_S1;
wire pipe2_valid_S2;
wire pipe2_valid_S3;



wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S1;
wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S2;
wire [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S3;

wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S1;
wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S2;
wire [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S3;

wire active_S1;
wire active_S2;
wire active_S3;





home_agent_config_regs config_regs(

    .clk                    (clk),
    .rst_n                  (rst_n),
    .chipid                 (chipid),
    .coreid_x               (coreid_x),
    .coreid_y               (coreid_y),
    .l2_access_valid        (l2_access_valid),
    .l2_miss_valid          (l2_miss_valid),
    .data_ecc_corr_error    (data_ecc_corr_error),
    .data_ecc_uncorr_error  (data_ecc_uncorr_error),
    .data_ecc_addr          (data_ecc_addr),
    .error_addr             (error_addr),
    .reg_rd_en              (reg_rd_en),
    .reg_wr_en              (reg_wr_en),
    .reg_rd_addr_type       (reg_rd_addr_type),
    .reg_wr_addr_type       (reg_wr_addr_type),
    .reg_data_in            (reg_data_in),

    .reg_data_out           (reg_data_out),
    .my_nodeid              (my_nodeid),
    .core_max               (core_max),
    .smt_base_addr          (smt_base_addr)

);




home_agent_mshr_wrap mshr_wrap(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pipe_wr_sel            (active_S3),

    .cam_en1                (mshr_cam_en_p1),
    .wr_state_en1           (mshr_wr_state_en_p1),
    .wr_data_en1            (mshr_wr_data_en_p1),
    .pending_ready1         (mshr_pending_ready_p1),
    .state_in1              (mshr_state_in_p1),
    .data_in1               (mshr_data_in_p1),
    .data_mask_in1          (mshr_data_mask_in_p1),
    .inv_counter_rd_index_in1(mshr_inv_counter_rd_index_in_p1),
    .wr_index_in1           (mshr_wr_index_in_p1),
    .addr_in1               (mshr_addr_in_p1),

    .wr_state_en2           (mshr_wr_state_en_p2),
    .wr_data_en2            (mshr_wr_data_en_p2),
    .inc_counter_en2        (mshr_inc_counter_en_p2),
    .state_in2              (mshr_state_in_p2),
    .data_in2               (mshr_data_in_p2),
    .data_mask_in2          (mshr_data_mask_in_p2),
    .rd_index_in2           (mshr_rd_index_in_p2),
    .wr_index_in2           (mshr_wr_index_in_p2),

    .hit                    (mshr_hit),
    .rd_state_out           (rd_mshr_state_out),
    .rd_data_out            (rd_mshr_data_out),
    .pending_data_out       (pending_mshr_data_out),
    .inv_counter_out        (mshr_inv_counter_out), 
    .empty_slots            (mshr_empty_slots),
    .pending                (mshr_pending),
    .pending_index          (mshr_pending_index),
    .empty_index            (mshr_empty_index)
);

home_agent_state_wrap state_wrap(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pdout_en               (1'b0),
    .deepsleep              (1'b0),
    .pipe_rd_sel            (active_S1),
    .pipe_wr_sel            (active_S3),

    .rd_en1                 (state_rd_en_p1),
    .wr_en1                 (state_wr_en_p1),
    .rd_addr1               (state_rd_addr_p1),
    .wr_addr1               (state_wr_addr_p1),
    .data_in1               (state_data_in_p1),
    .data_mask_in1          (state_data_mask_in_p1),

    .rd_en2                 (state_rd_en_p2),
    .wr_en2                 (state_wr_en_p2),
    .rd_addr2               (state_rd_addr_p2),
    .wr_addr2               (state_wr_addr_p2),
    .data_in2               (state_data_in_p2),
    .data_mask_in2          (state_data_mask_in_p2),

    .data_out               (state_data_out),
    .pdata_out              ()
);

home_agent_tag_wrap tag_wrap(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pdout_en               (1'b0),
    .deepsleep              (1'b0),
    .pipe_sel               (active_S1),

    .clk_en1                (tag_clk_en_p1),
    .rdw_en1                (tag_rdw_en_p1),
    .addr1                  (tag_addr_p1),
    .data_in1               (tag_data_in_p1),
    .data_mask_in1          (tag_data_mask_in_p1),

    .clk_en2                (tag_clk_en_p2),
    .rdw_en2                (tag_rdw_en_p2),
    .addr2                  (tag_addr_p2),
    .data_in2               (tag_data_in_p2),
    .data_mask_in2          (tag_data_mask_in_p2),


    .data_out               (tag_data_out),
    .pdata_out              ()
);

home_agent_dir_wrap dir_wrap(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pdout_en               (1'b0),
    .deepsleep              (1'b0),
    .pipe_sel               (active_S2),

    .clk_en1                (dir_clk_en_p1),
    .rdw_en1                (dir_rdw_en_p1),
    .addr1                  (dir_addr_p1),
    .data_in1               (dir_data_in_p1),
    .data_mask_in1          (dir_data_mask_in_p1),

    .clk_en2                (dir_clk_en_p2),
    .rdw_en2                (dir_rdw_en_p2),
    .addr2                  (dir_addr_p2),
    .data_in2               (dir_data_in_p2),
    .data_mask_in2          (dir_data_mask_in_p2),


    .data_out               (dir_data_out),
    .pdata_out              ()
);

home_agent_data_wrap data_wrap(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .pdout_en               (1'b0),
    .deepsleep              (1'b0),
    .pipe_sel               (active_S2),

    .clk_en1                (data_clk_en_p1),
    .rdw_en1                (data_rdw_en_p1),
    .addr1                  (data_addr_p1),
    .data_in1               (data_data_in_p1),
    .data_mask_in1          (data_data_mask_in_p1),

    .clk_en2                (data_clk_en_p2),
    .rdw_en2                (data_rdw_en_p2),
    .addr2                  (data_addr_p2),
    .data_in2               (data_data_in_p2),
    .data_mask_in2          (data_data_mask_in_p2),


    .data_out               (data_data_out),
    .pdata_out              ()
);


home_agent_pipe1 pipe1(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .my_nodeid              (my_nodeid),
    .smt_base_addr          (smt_base_addr),

    .noc_valid_in           (noc1_valid_in),
    .noc_data_in            (noc1_data_in),
    .noc_ready_in           (noc1_ready_in),

    .noc_valid_out          (noc2_valid_out),
    .noc_data_out           (noc2_data_out),
    .noc_ready_out          (noc2_ready_out),


    .pipe2_valid_S1         (pipe2_valid_S1),
    .pipe2_valid_S2         (pipe2_valid_S2),
    .pipe2_valid_S3         (pipe2_valid_S3),
    .pipe2_msg_type_S1      (pipe2_msg_type_S1),
    .pipe2_msg_type_S2      (pipe2_msg_type_S2),
    .pipe2_msg_type_S3      (pipe2_msg_type_S3),
    .pipe2_addr_S1          (pipe2_addr_S1),
    .pipe2_addr_S2          (pipe2_addr_S2),
    .pipe2_addr_S3          (pipe2_addr_S3),
    .global_stall_S1        (active_S1),
    .global_stall_S2        (active_S2),
    .global_stall_S4        (active_S3),

    .mshr_hit               (mshr_hit),
    .pending_mshr_data_out  (pending_mshr_data_out),
    .mshr_inv_counter_out   (mshr_inv_counter_out),
    .mshr_empty_slots       (mshr_empty_slots),
    .mshr_pending           (mshr_pending),
    .mshr_pending_index     (mshr_pending_index),
    .mshr_empty_index       (mshr_empty_index),

    .state_data_out         (state_data_out),
    .tag_data_out           (tag_data_out),
    .dir_data_out           (dir_data_out),
    .data_data_out          (data_data_out),

    .l2_access_valid        (l2_access_valid),
    .l2_miss_valid          (l2_miss_valid),
    .data_ecc_corr_error    (data_ecc_corr_error),
    .data_ecc_uncorr_error  (data_ecc_uncorr_error),
    .data_ecc_addr          (data_ecc_addr),
    .error_addr             (error_addr),

    .reg_rd_en              (reg_rd_en),
    .reg_wr_en              (reg_wr_en),
    .reg_rd_addr_type       (reg_rd_addr_type),
    .reg_wr_addr_type       (reg_wr_addr_type),

    .reg_data_out           (reg_data_out),
    .reg_data_in            (reg_data_in),

    .mshr_cam_en            (mshr_cam_en_p1),
    .mshr_wr_state_en       (mshr_wr_state_en_p1),
    .mshr_wr_data_en        (mshr_wr_data_en_p1),
    .mshr_pending_ready     (mshr_pending_ready_p1),
    .mshr_state_in          (mshr_state_in_p1),
    .mshr_data_in           (mshr_data_in_p1),
    .mshr_data_mask_in      (mshr_data_mask_in_p1),
    .mshr_inv_counter_rd_index_in(mshr_inv_counter_rd_index_in_p1),
    .mshr_wr_index_in       (mshr_wr_index_in_p1),

    .state_rd_en            (state_rd_en_p1),
    .state_wr_en            (state_wr_en_p1),
    .state_rd_addr          (state_rd_addr_p1),
    .state_wr_addr          (state_wr_addr_p1),
    .state_data_in          (state_data_in_p1),
    .state_data_mask_in     (state_data_mask_in_p1),

    .tag_clk_en             (tag_clk_en_p1),
    .tag_rdw_en             (tag_rdw_en_p1),
    .tag_addr               (tag_addr_p1),
    .tag_data_in            (tag_data_in_p1),
    .tag_data_mask_in       (tag_data_mask_in_p1),

    .dir_clk_en             (dir_clk_en_p1),
    .dir_rdw_en             (dir_rdw_en_p1),
    .dir_addr               (dir_addr_p1),
    .dir_data_in            (dir_data_in_p1),
    .dir_data_mask_in       (dir_data_mask_in_p1),

    .data_clk_en            (data_clk_en_p1),
    .data_rdw_en            (data_rdw_en_p1),
    .data_addr              (data_addr_p1),
    .data_data_in           (data_data_in_p1),
    .data_data_mask_in      (data_data_mask_in_p1)

);



home_agent_pipe2 pipe2(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .noc_valid_in           (noc3_valid_in),
    .noc_data_in            (noc3_data_in),
    .noc_ready_in           (noc3_ready_in),

    .mshr_state_out         (rd_mshr_state_out),
    .mshr_data_out          (rd_mshr_data_out),

    .state_data_out         (state_data_out),
    .tag_data_out           (tag_data_out),
    .dir_data_out           (dir_data_out),

    .mshr_rd_en             (mshr_rd_en_p2),
    .mshr_wr_state_en       (mshr_wr_state_en_p2),
    .mshr_wr_data_en        (mshr_wr_data_en_p2),
    .mshr_inc_counter_en    (mshr_inc_counter_en_p2),
    .mshr_state_in          (mshr_state_in_p2),
    .mshr_data_in           (mshr_data_in_p2),
    .mshr_data_mask_in      (mshr_data_mask_in_p2),
    .mshr_rd_index_in       (mshr_rd_index_in_p2),
    .mshr_wr_index_in       (mshr_wr_index_in_p2),

    .state_rd_en            (state_rd_en_p2),
    .state_wr_en            (state_wr_en_p2),
    .state_rd_addr          (state_rd_addr_p2),
    .state_wr_addr          (state_wr_addr_p2),
    .state_data_in          (state_data_in_p2),
    .state_data_mask_in     (state_data_mask_in_p2),

    .tag_clk_en             (tag_clk_en_p2),
    .tag_rdw_en             (tag_rdw_en_p2),
    .tag_addr               (tag_addr_p2),
    .tag_data_in            (tag_data_in_p2),
    .tag_data_mask_in       (tag_data_mask_in_p2),

    .dir_clk_en             (dir_clk_en_p2),
    .dir_rdw_en             (dir_rdw_en_p2),
    .dir_addr               (dir_addr_p2),
    .dir_data_in            (dir_data_in_p2),
    .dir_data_mask_in       (dir_data_mask_in_p2),

    .data_clk_en            (data_clk_en_p2),
    .data_rdw_en            (data_rdw_en_p2),
    .data_addr              (data_addr_p2),
    .data_data_in           (data_data_in_p2),
    .data_data_mask_in      (data_data_mask_in_p2),

    .valid_S1               (pipe2_valid_S1),
    .valid_S2               (pipe2_valid_S2),
    .valid_S3               (pipe2_valid_S3),
    .msg_type_S1            (pipe2_msg_type_S1),
    .msg_type_S2            (pipe2_msg_type_S2),
    .msg_type_S3            (pipe2_msg_type_S3),
    .addr_S1                (pipe2_addr_S1),
    .addr_S2                (pipe2_addr_S2),
    .addr_S3                (pipe2_addr_S3),
    .active_S1              (active_S1),
    .active_S2              (active_S2),
    .active_S3              (active_S3)
);

endmodule
