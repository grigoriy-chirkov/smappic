// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Michael Schaffner <schaffner@iis.ee.ethz.ch>, ETH Zurich
// Date: 26.11.2018
// Description: Simple hello world program that prints the core id.
// Also runs correctly on manycore configs.
//

#include <stdint.h>
#include <stdio.h>
#include "util.h"

int main(int argc, char** argv) {
  // synchronization variable
  volatile static uint32_t* amo_cnt1 = 0x90000000;
  volatile static uint32_t* amo_cnt2 = 0xa0000000;
  // volatile static uint32_t* amo_cnt3 = 0xb0000000;
  if (argv[0][0] == 0){
    *amo_cnt1 = 0;
    *amo_cnt2 = 0;
    // *amo_cnt3 = 0;
  }
  // synchronize with other cores and wait until it is this core's turn
  while(argv[0][0] != *amo_cnt1);
  while(argv[0][0] != *amo_cnt2);
  // while(argv[0][0] != *amo_cnt3);

  // assemble number and print
  printf("%d/%d\n", argv[0][0], argv[0][1]);

  // increment atomic counter
  ATOMIC_OP(*amo_cnt1, 1, add, w);
  ATOMIC_OP(*amo_cnt2, 1, add, w);
  // ATOMIC_OP(*amo_cnt3, 1, add, w);

  while(argv[0][1] != *amo_cnt1);
  while(argv[0][1] != *amo_cnt2);
  // while(argv[0][1] != *amo_cnt3);

  return 0;
}