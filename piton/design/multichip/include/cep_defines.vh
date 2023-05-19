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

`ifndef CEP_DEFINES_VH
`define CEP_DEFINES_VH

`include "define.tmp.h"

`define CEP_DATA_WIDTH  512
`define PKG_DATA_WIDTH  `CEP_DATA_WIDTH
`define CEP_CHIPID_WIDTH 14

`define CEP_LAST_SUBLINE_WIDTH   1
`define CEP_SUBLINE_ID_WIDTH     2
`define CEP_MESI_WIDTH           2
`define CEP_MSHRID_WIDTH         8   
`define CEP_MSG_TYPE_WIDTH       8
`define CEP_LENGTH_WIDTH         8
`define CEP_DST_FBITS_WIDTH      4
`define CEP_DST_X_WIDTH          8
`define CEP_DST_Y_WIDTH          8
`define CEP_DST_CHIPID_WIDTH    14
`define CEP_DATA_SIZE_WIDTH      3
`define CEP_CACHE_TYPE_WIDTH     1
`define CEP_SUBLINE_VECTOR_WIDTH 4
`define CEP_ADDR_WIDTH          40
`define CEP_SRC_FBITS_WIDTH      4
`define CEP_SRC_X_WIDTH          8
`define CEP_SRC_Y_WIDTH          8
`define CEP_SRC_CHIPID_WIDTH    14
`define CEP_WORD_WIDTH          64

`define CEP_LAST_SUBLINE         0
`define CEP_SUBLINE_ID          2:1
`define CEP_IS_REQ               3
`define CEP_MESI                5:4
`define CEP_MSHRID             13:6
`define CEP_MSG_TYPE           21:14
`define CEP_LENGTH             29:22
`define CEP_DST_FBITS          33:30
`define CEP_DST_Y              41:34
`define CEP_DST_X              49:42
`define CEP_DST_CHIPID         63:50
`define CEP_DATA_SIZE          74:72
`define CEP_CACHE_TYPE          75
`define CEP_SUBLINE_VECTOR     79:76
`define CEP_ADDR              119:80
`define CEP_SRC_FBITS         161:158
`define CEP_SRC_Y             169:162
`define CEP_SRC_X             177:170
`define CEP_SRC_CHIPID        191:178

`endif