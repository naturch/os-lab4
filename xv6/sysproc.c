#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int printpt(int pid);  // 추가

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}
 //추가
int
sys_printpt(void)
{
  int pid =0;
  if (argint(0, &pid) < 0) //사용자에게 pid 넘겨받지 못하면 실패
    return -1;
  
  return printpt(pid);
}

//lazy allocation 수정
int
sys_sbrk(void)
{
  int addr;
  int n;
  struct proc *curproc = myproc ();

  if(argint(0, &n) < 0)
    return -1;

  addr = curproc->sz;

  if(n < 0) {

    uint oldsz = curproc->sz;
    uint newsz = oldsz + n;

    if (newsz > oldsz) //오버플로우 방지
    return -1;

    //PGROUNDUP된 boundary 범위만 unmap
    if(deallocuvm(curproc->pgdir, PGROUNDUP(oldsz), PGROUNDUP(newsz)) == 0)
      return -1;
    curproc -> sz = newsz;
    return addr;
  }
  
  if (n > 0){ // sz+n이 커널 영역 넘어가면 안됨
    if (curproc ->sz + n >= KERNBASE) //lazy allocation -> 물리메모리 할당 안함함
      return -1;
  }
  curproc ->sz +=n;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
