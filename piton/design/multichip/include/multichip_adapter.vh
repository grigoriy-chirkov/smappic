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

`ifndef __MULTICHIP_ADAPTER_VH__
`define __MULTICHIP_ADAPTER_VH__

`include "define.tmp.h"

// Dir array

`define MA_WAYS              8
`define MA_WAY_WIDTH         3 // log2(`MA_WAYS)
`define MA_SETS              256
`define MA_SET_WIDTH         8 // log2(`MA_SETS)

`define MA_TAG_WIDTH         34
`define MA_STATE_WIDTH       1
`define MA_SHARER_BITS_WIDTH 6
`define MA_SHARER_SET_WIDTH  64
`define MA_ENTRY_WIDTH       99 // `MA_STATE_WIDTH + `MA_SHARER_SET_WIDTH + `MA_TAG_WIDTH


`define MA_WIDTH             792 // `MA_WAYS * `MA_ENTRY_WIDTH
`define MA_HEIGHT            `MA_SETS
`define MA_HEIGHT_LOG2       `MA_SET_WIDTH

`define MA_ADDR_WIDTH         `MSG_ADDR_WIDTH
`define MA_OFFSET_WIDTH       6
`define MA_ADDR_SET           `MA_OFFSET_WIDTH+`MA_SET_WIDTH-1:`MA_OFFSET_WIDTH
`define MA_ADDR_TAG           `MA_ADDR_WIDTH-1:`MA_OFFSET_WIDTH+`MA_SET_WIDTH
`define MA_ADDR_INDEX         `MA_ADDR_WIDTH-1:`MA_OFFSET_WIDTH
`define MA_ADDR_OFFSET        `MA_OFFSET_WIDTH-1:0
`define MA_INDEX_WIDTH        42 // `MSG_ADDR_WIDTH-`MA_OFFSET_WIDTH

`define MA_ENTRY_OWNER_BITS   `MA_SHARER_SET_WIDTH-1:0
`define MA_ENTRY_TAG          `MA_TAG_WIDTH+`MA_SHARER_SET_WIDTH-1:`MA_SHARER_SET_WIDTH
`define MA_ENTRY_STATE        `MA_ENTRY_WIDTH-1:`MA_TAG_WIDTH+`MA_SHARER_SET_WIDTH

`define MA_STATE_INVALID       1'b0
`define MA_STATE_VALID         1'b1

`define MA_SUBLINE_BITS        4

// MSHR array

`define MA_MSHR_ENTRIES         8
`define MA_MSHR_INDEX_WIDTH     3
`define MA_MSHR_ADDR_IN_WIDTH   `MA_INDEX_WIDTH
`define MA_MSHR_ADDR_OUT_WIDTH  `MSG_ADDR_WIDTH

`define MA_MSHR_STATE_BITS      2
`define MA_MSHR_STATE_INVAL     2'd0
`define MA_MSHR_STATE_WAIT      2'd1
`define MA_MSHR_STATE_PENDING   2'd2

`define MA_MSHR_DATA_CHUNK_WIDTH 128
`define MA_MSHR_ARRAY_WIDTH     647 // 128 +`MA_WAY_WIDTH + 4*`MA_MSHR_DATA_CHUNK_WIDTH + 4

`define MA_MSHR_CMP_ADDR        `MA_ADDR_INDEX
`define MA_MSHR_ADDR            47:0
`define MA_MSHR_WAY             47+`MA_WAY_WIDTH:48
`define MA_MSHR_MSHRID          55+`MA_WAY_WIDTH:48+`MA_WAY_WIDTH
`define MA_MSHR_CACHE_TYPE      56+`MA_WAY_WIDTH
`define MA_MSHR_DATA_SIZE       59+`MA_WAY_WIDTH:57+`MA_WAY_WIDTH
`define MA_MSHR_MSG_TYPE        67+`MA_WAY_WIDTH:60+`MA_WAY_WIDTH
`define MA_MSHR_L2_MISS         68+`MA_WAY_WIDTH
`define MA_MSHR_SRC_CHIPID      82+`MA_WAY_WIDTH:69+`MA_WAY_WIDTH
`define MA_MSHR_SRC_X           90+`MA_WAY_WIDTH:83+`MA_WAY_WIDTH
`define MA_MSHR_SRC_Y           98+`MA_WAY_WIDTH:91+`MA_WAY_WIDTH
`define MA_MSHR_SRC_FBITS       102+`MA_WAY_WIDTH:99+`MA_WAY_WIDTH
`define MA_MSHR_SDID            112+`MA_WAY_WIDTH:103+`MA_WAY_WIDTH
`define MA_MSHR_LSID            118+`MA_WAY_WIDTH:113+`MA_WAY_WIDTH      
`define MA_MSHR_MISS_LSID       124+`MA_WAY_WIDTH:119+`MA_WAY_WIDTH
`define MA_MSHR_SMC_MISS        125+`MA_WAY_WIDTH
`define MA_MSHR_RECYCLED        126+`MA_WAY_WIDTH
`define MA_MSHR_INV_FWD_PENDING 127+`MA_WAY_WIDTH
`define MA_MSHR_DATA_VALS       131+`MA_WAY_WIDTH:128+`MA_WAY_WIDTH
`define MA_MSHR_DATA0           `MA_MSHR_DATA_CHUNK_WIDTH*1+132+`MA_WAY_WIDTH-1:`MA_MSHR_DATA_CHUNK_WIDTH*0+132+`MA_WAY_WIDTH
`define MA_MSHR_DATA1           `MA_MSHR_DATA_CHUNK_WIDTH*2+132+`MA_WAY_WIDTH-1:`MA_MSHR_DATA_CHUNK_WIDTH*1+132+`MA_WAY_WIDTH
`define MA_MSHR_DATA2           `MA_MSHR_DATA_CHUNK_WIDTH*3+132+`MA_WAY_WIDTH-1:`MA_MSHR_DATA_CHUNK_WIDTH*2+132+`MA_WAY_WIDTH
`define MA_MSHR_DATA3           `MA_MSHR_DATA_CHUNK_WIDTH*4+132+`MA_WAY_WIDTH-1:`MA_MSHR_DATA_CHUNK_WIDTH*3+132+`MA_WAY_WIDTH


`endif // __MULTICHIP_ADAPTER_VH__