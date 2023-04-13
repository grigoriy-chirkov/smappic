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

`define MA_WAYS                  4
`define MA_WAYS_WIDTH            2
`define MA_TAG_INDEX_WIDTH       8
`define MA_LINE_SIZE_WIDTH       6
`define MA_OWNER_BITS            6
`define MA_TAG_INDEX            `MA_LINE_SIZE_WIDTH+`MA_TAG_INDEX_WIDTH-1:`MA_LINE_SIZE_WIDTH


//MSHR array

`define MA_MSHR_ENTRIES         8
`define MA_MSHR_INDEX_WIDTH     3
`define MA_MSHR_ADDR_IN_WIDTH   `MA_TAG_INDEX_WIDTH
`define MA_MSHR_ADDR_OUT_WIDTH  `PHY_ADDR_WIDTH

`define MA_MSHR_STATE_BITS      2
`define MA_MSHR_STATE_INVAL     2'd0
`define MA_MSHR_STATE_WAIT      2'd1
`define MA_MSHR_STATE_PENDING   2'd2

`define MA_MSHR_ARRAY_WIDTH     122 // 120+`MA_WAYS_WIDTH

`define MA_MSHR_CMP_ADDR        `MA_TAG_INDEX
`define MA_MSHR_ADDR            39:0
`define MA_MSHR_WAY             39+`MA_WAYS_WIDTH:40
`define MA_MSHR_MSHRID          47+`MA_WAYS_WIDTH:40+`MA_WAYS_WIDTH
`define MA_MSHR_CACHE_TYPE      48+`MA_WAYS_WIDTH
`define MA_MSHR_DATA_SIZE       51+`MA_WAYS_WIDTH:49+`MA_WAYS_WIDTH
`define MA_MSHR_MSG_TYPE        59+`MA_WAYS_WIDTH:52+`MA_WAYS_WIDTH
`define MA_MSHR_L2_MISS         60+`MA_WAYS_WIDTH
`define MA_MSHR_SRC_CHIPID      74+`MA_WAYS_WIDTH:61+`MA_WAYS_WIDTH
`define MA_MSHR_SRC_X           82+`MA_WAYS_WIDTH:75+`MA_WAYS_WIDTH
`define MA_MSHR_SRC_Y           90+`MA_WAYS_WIDTH:83+`MA_WAYS_WIDTH
`define MA_MSHR_SRC_FBITS       94+`MA_WAYS_WIDTH:91+`MA_WAYS_WIDTH
`define MA_MSHR_SDID            104+`MA_WAYS_WIDTH:95+`MA_WAYS_WIDTH
`define MA_MSHR_LSID            110+`MA_WAYS_WIDTH:105+`MA_WAYS_WIDTH      
`define MA_MSHR_MISS_LSID       116+`MA_WAYS_WIDTH:111+`MA_WAYS_WIDTH
`define MA_MSHR_SMC_MISS        117+`MA_WAYS_WIDTH
`define MA_MSHR_RECYCLED        118+`MA_WAYS_WIDTH
`define MA_MSHR_INV_FWD_PENDING 119+`MA_WAYS_WIDTH

`endif // __MULTICHIP_ADAPTER_VH__