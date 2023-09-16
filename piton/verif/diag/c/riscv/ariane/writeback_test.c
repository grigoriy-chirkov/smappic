#include <stdint.h>
#include <stdio.h>
#include "util.h"

// for 2 cores only

#define FLUSH_ADDR 0xb300000000ULL

void flush() {
  for (int i = 0; i < 4; i++) {
    volatile int64_t* flush_addr = (uint64_t*)(FLUSH_ADDR + 0x1000000ULL * i);
    *(flush_addr) = 0ULL;
  }
}

int main(int argc, char** argv) {
  // synchronization variable
  volatile static int32_t* amo_cnt = 0xb0000110;
  volatile static int32_t* var = 0xa0000000;

  if (argv[0][0] == 0)
    *amo_cnt = 1;

  // synchronize with other cores and wait until it is this core's turn
  while(argv[0][0] != *amo_cnt);

  if (argv[0][0] == 1){
    *var = 42;
    printf("Core %d: wrote 42 to 0x%x\n", argv[0][0], var);
    flush();
  }
  else {
    printf("Core %d: read %d from 0x%x\n", argv[0][0], *var, var);
  }


  // decrement atomic counter
  ATOMIC_OP(*amo_cnt, -1, add, w);

  while(*amo_cnt >= 0);

  return 0;
}