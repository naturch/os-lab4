#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "memlayout.h"
#include "x86.h"
#include "mmu.h"

#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)
{
  char *i, *prev_end, *new_end;
  
  prev_end = sbrk(REGION_SZ);
  if (prev_end == (char*)0xffffffffffffffffL) {
    printf(1,"sbrk() failed\n");
    exit();
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    *(char **)i = i;

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    if (*(char **)i != i) {
      printf(1,"failed to read value from memory\n");
      exit();
    }
  }

  exit();
}

void
sparse_memory_unmap(char *s)
{
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  if (prev_end == (char*)0xffffffffffffffffL) {
    printf(1,"sbrk() failed\n");
    exit();
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    *(char **)i = i;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    pid = fork();
    if (pid < 0) {
      printf(1,"error forking\n");
      exit();
    } else if (pid == 0) {
      sbrk(-1L * REGION_SZ);
      *(char **)i = i;
      exit();
    } else {
      wait();
      printf(1,"memory not unmapped\n");
      exit();
    }
  }

  exit();
}

void
oom(char *s)
{
  void *m1, *m2;
  int pid;

  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(4096*4096)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    exit();
  } else {
    wait();
    exit();
  }
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
  int pid;
  
  printf(1,"running test %s\n", s);
  if((pid = fork()) < 0) {
    printf(1,"runtest: fork error\n");
    exit();
  }
  if(pid == 0) {
    f(s);
    exit();
  } else {
    wait();
    return 1;
  }
}

int
main(int argc, char *argv[])
{
  char *n = 0;
  if(argc > 1) {
    n = argv[1];
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    { sparse_memory, "lazy alloc"},
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf(1,"lazytests starting\n");

  for (struct test *t = tests; t->s != 0; t++) {
    if((n == 0) || strcmp(t->s, n) == 0) {
      run(t->f, t->s);
    }
  }
  printf(1,"ALL TESTS ENDED\n");
  exit();   // not reached.
}