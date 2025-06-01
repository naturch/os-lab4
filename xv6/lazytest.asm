
_lazytest:     file format elf32-i386


Disassembly of section .text:

00000000 <sparse_memory>:

#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  char *i, *prev_end, *new_end;
  
  prev_end = sbrk(REGION_SZ);
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	68 00 00 00 40       	push   $0x40000000
   e:	e8 e3 05 00 00       	call   5f6 <sbrk>
  13:	83 c4 10             	add    $0x10,%esp
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  19:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  1d:	75 17                	jne    36 <sparse_memory+0x36>
    printf(1,"sbrk() failed\n");
  1f:	83 ec 08             	sub    $0x8,%esp
  22:	68 a4 0a 00 00       	push   $0xaa4
  27:	6a 01                	push   $0x1
  29:	e8 bc 06 00 00       	call   6ea <printf>
  2e:	83 c4 10             	add    $0x10,%esp
    exit();
  31:	e8 38 05 00 00       	call   56e <exit>
  }
  new_end = prev_end + REGION_SZ;
  36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  39:	05 00 00 00 40       	add    $0x40000000,%eax
  3e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  44:	05 00 10 00 00       	add    $0x1000,%eax
  49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  4c:	eb 0f                	jmp    5d <sparse_memory+0x5d>
    *(char **)i = i;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  54:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  56:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  60:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  63:	72 e9                	jb     4e <sparse_memory+0x4e>

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  68:	05 00 10 00 00       	add    $0x1000,%eax
  6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  70:	eb 28                	jmp    9a <sparse_memory+0x9a>
    if (*(char **)i != i) {
  72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  75:	8b 00                	mov    (%eax),%eax
  77:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7a:	74 17                	je     93 <sparse_memory+0x93>
      printf(1,"failed to read value from memory\n");
  7c:	83 ec 08             	sub    $0x8,%esp
  7f:	68 b4 0a 00 00       	push   $0xab4
  84:	6a 01                	push   $0x1
  86:	e8 5f 06 00 00       	call   6ea <printf>
  8b:	83 c4 10             	add    $0x10,%esp
      exit();
  8e:	e8 db 04 00 00       	call   56e <exit>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  93:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  a0:	72 d0                	jb     72 <sparse_memory+0x72>
    }
  }

  exit();
  a2:	e8 c7 04 00 00       	call   56e <exit>

000000a7 <sparse_memory_unmap>:
}

void
sparse_memory_unmap(char *s)
{
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  aa:	83 ec 18             	sub    $0x18,%esp
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  ad:	83 ec 0c             	sub    $0xc,%esp
  b0:	68 00 00 00 40       	push   $0x40000000
  b5:	e8 3c 05 00 00       	call   5f6 <sbrk>
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  c0:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  c4:	75 17                	jne    dd <sparse_memory_unmap+0x36>
    printf(1,"sbrk() failed\n");
  c6:	83 ec 08             	sub    $0x8,%esp
  c9:	68 a4 0a 00 00       	push   $0xaa4
  ce:	6a 01                	push   $0x1
  d0:	e8 15 06 00 00       	call   6ea <printf>
  d5:	83 c4 10             	add    $0x10,%esp
    exit();
  d8:	e8 91 04 00 00       	call   56e <exit>
  }
  new_end = prev_end + REGION_SZ;
  dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e0:	05 00 00 00 40       	add    $0x40000000,%eax
  e5:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  eb:	05 00 10 00 00       	add    $0x1000,%eax
  f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f3:	eb 0f                	jmp    104 <sparse_memory_unmap+0x5d>
    *(char **)i = i;
  f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  fb:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  fd:	81 45 f4 00 00 00 01 	addl   $0x1000000,-0xc(%ebp)
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 10a:	72 e9                	jb     f5 <sparse_memory_unmap+0x4e>

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
 10c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 10f:	05 00 10 00 00       	add    $0x1000,%eax
 114:	89 45 f4             	mov    %eax,-0xc(%ebp)
 117:	90                   	nop
 118:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 11e:	73 64                	jae    184 <sparse_memory_unmap+0xdd>
    pid = fork();
 120:	e8 41 04 00 00       	call   566 <fork>
 125:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 128:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 12c:	79 17                	jns    145 <sparse_memory_unmap+0x9e>
      printf(1,"error forking\n");
 12e:	83 ec 08             	sub    $0x8,%esp
 131:	68 d6 0a 00 00       	push   $0xad6
 136:	6a 01                	push   $0x1
 138:	e8 ad 05 00 00       	call   6ea <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      exit();
 140:	e8 29 04 00 00       	call   56e <exit>
    } else if (pid == 0) {
 145:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 149:	75 1d                	jne    168 <sparse_memory_unmap+0xc1>
      sbrk(-1L * REGION_SZ);
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	68 00 00 00 c0       	push   $0xc0000000
 153:	e8 9e 04 00 00       	call   5f6 <sbrk>
 158:	83 c4 10             	add    $0x10,%esp
      *(char **)i = i;
 15b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 161:	89 10                	mov    %edx,(%eax)
      exit();
 163:	e8 06 04 00 00       	call   56e <exit>
    } else {
      wait();
 168:	e8 09 04 00 00       	call   576 <wait>
      printf(1,"memory not unmapped\n");
 16d:	83 ec 08             	sub    $0x8,%esp
 170:	68 e5 0a 00 00       	push   $0xae5
 175:	6a 01                	push   $0x1
 177:	e8 6e 05 00 00       	call   6ea <printf>
 17c:	83 c4 10             	add    $0x10,%esp
      exit();
 17f:	e8 ea 03 00 00       	call   56e <exit>
    }
  }

  exit();
 184:	e8 e5 03 00 00       	call   56e <exit>

00000189 <oom>:
}

void
oom(char *s)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	83 ec 18             	sub    $0x18,%esp
  void *m1, *m2;
  int pid;

  if((pid = fork()) == 0){
 18f:	e8 d2 03 00 00       	call   566 <fork>
 194:	89 45 f0             	mov    %eax,-0x10(%ebp)
 197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 19b:	75 35                	jne    1d2 <oom+0x49>
    m1 = 0;
 19d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(4096*4096)) != 0){
 1a4:	eb 0e                	jmp    1b4 <oom+0x2b>
      *(char**)m2 = m1;
 1a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ac:	89 10                	mov    %edx,(%eax)
      m1 = m2;
 1ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while((m2 = malloc(4096*4096)) != 0){
 1b4:	83 ec 0c             	sub    $0xc,%esp
 1b7:	68 00 00 00 01       	push   $0x1000000
 1bc:	e8 fd 07 00 00       	call   9be <malloc>
 1c1:	83 c4 10             	add    $0x10,%esp
 1c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 1c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1cb:	75 d9                	jne    1a6 <oom+0x1d>
    }
    exit();
 1cd:	e8 9c 03 00 00       	call   56e <exit>
  } else {
    wait();
 1d2:	e8 9f 03 00 00       	call   576 <wait>
    exit();
 1d7:	e8 92 03 00 00       	call   56e <exit>

000001dc <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
 1dc:	55                   	push   %ebp
 1dd:	89 e5                	mov    %esp,%ebp
 1df:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  printf(1,"running test %s\n", s);
 1e2:	83 ec 04             	sub    $0x4,%esp
 1e5:	ff 75 0c             	push   0xc(%ebp)
 1e8:	68 fa 0a 00 00       	push   $0xafa
 1ed:	6a 01                	push   $0x1
 1ef:	e8 f6 04 00 00       	call   6ea <printf>
 1f4:	83 c4 10             	add    $0x10,%esp
  if((pid = fork()) < 0) {
 1f7:	e8 6a 03 00 00       	call   566 <fork>
 1fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 1ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 203:	79 17                	jns    21c <run+0x40>
    printf(1,"runtest: fork error\n");
 205:	83 ec 08             	sub    $0x8,%esp
 208:	68 0b 0b 00 00       	push   $0xb0b
 20d:	6a 01                	push   $0x1
 20f:	e8 d6 04 00 00       	call   6ea <printf>
 214:	83 c4 10             	add    $0x10,%esp
    exit();
 217:	e8 52 03 00 00       	call   56e <exit>
  }
  if(pid == 0) {
 21c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 220:	75 13                	jne    235 <run+0x59>
    f(s);
 222:	83 ec 0c             	sub    $0xc,%esp
 225:	ff 75 0c             	push   0xc(%ebp)
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	ff d0                	call   *%eax
 22d:	83 c4 10             	add    $0x10,%esp
    exit();
 230:	e8 39 03 00 00       	call   56e <exit>
  } else {
    wait();
 235:	e8 3c 03 00 00       	call   576 <wait>
    return 1;
 23a:	b8 01 00 00 00       	mov    $0x1,%eax
  }
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <main>:

int
main(int argc, char *argv[])
{
 241:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 245:	83 e4 f0             	and    $0xfffffff0,%esp
 248:	ff 71 fc             	push   -0x4(%ecx)
 24b:	55                   	push   %ebp
 24c:	89 e5                	mov    %esp,%ebp
 24e:	51                   	push   %ecx
 24f:	83 ec 34             	sub    $0x34,%esp
 252:	89 c8                	mov    %ecx,%eax
  char *n = 0;
 254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(argc > 1) {
 25b:	83 38 01             	cmpl   $0x1,(%eax)
 25e:	7e 09                	jle    269 <main+0x28>
    n = argv[1];
 260:	8b 40 04             	mov    0x4(%eax),%eax
 263:	8b 40 04             	mov    0x4(%eax),%eax
 266:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
 269:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 270:	c7 45 d4 20 0b 00 00 	movl   $0xb20,-0x2c(%ebp)
 277:	c7 45 d8 a7 00 00 00 	movl   $0xa7,-0x28(%ebp)
 27e:	c7 45 dc 2b 0b 00 00 	movl   $0xb2b,-0x24(%ebp)
 285:	c7 45 e0 89 01 00 00 	movl   $0x189,-0x20(%ebp)
 28c:	c7 45 e4 36 0b 00 00 	movl   $0xb36,-0x1c(%ebp)
 293:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 29a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf(1,"lazytests starting\n");
 2a1:	83 ec 08             	sub    $0x8,%esp
 2a4:	68 44 0b 00 00       	push   $0xb44
 2a9:	6a 01                	push   $0x1
 2ab:	e8 3a 04 00 00       	call   6ea <printf>
 2b0:	83 c4 10             	add    $0x10,%esp

  for (struct test *t = tests; t->s != 0; t++) {
 2b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
 2b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 2b9:	eb 3b                	jmp    2f6 <main+0xb5>
    if((n == 0) || strcmp(t->s, n) == 0) {
 2bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2bf:	74 19                	je     2da <main+0x99>
 2c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2c4:	8b 40 04             	mov    0x4(%eax),%eax
 2c7:	83 ec 08             	sub    $0x8,%esp
 2ca:	ff 75 f4             	push   -0xc(%ebp)
 2cd:	50                   	push   %eax
 2ce:	e8 9a 00 00 00       	call   36d <strcmp>
 2d3:	83 c4 10             	add    $0x10,%esp
 2d6:	85 c0                	test   %eax,%eax
 2d8:	75 18                	jne    2f2 <main+0xb1>
      run(t->f, t->s);
 2da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2dd:	8b 50 04             	mov    0x4(%eax),%edx
 2e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2e3:	8b 00                	mov    (%eax),%eax
 2e5:	83 ec 08             	sub    $0x8,%esp
 2e8:	52                   	push   %edx
 2e9:	50                   	push   %eax
 2ea:	e8 ed fe ff ff       	call   1dc <run>
 2ef:	83 c4 10             	add    $0x10,%esp
  for (struct test *t = tests; t->s != 0; t++) {
 2f2:	83 45 f0 08          	addl   $0x8,-0x10(%ebp)
 2f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2f9:	8b 40 04             	mov    0x4(%eax),%eax
 2fc:	85 c0                	test   %eax,%eax
 2fe:	75 bb                	jne    2bb <main+0x7a>
    }
  }
  printf(1,"ALL TESTS ENDED\n");
 300:	83 ec 08             	sub    $0x8,%esp
 303:	68 58 0b 00 00       	push   $0xb58
 308:	6a 01                	push   $0x1
 30a:	e8 db 03 00 00       	call   6ea <printf>
 30f:	83 c4 10             	add    $0x10,%esp
  exit();   // not reached.
 312:	e8 57 02 00 00       	call   56e <exit>

00000317 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	57                   	push   %edi
 31b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 31c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 31f:	8b 55 10             	mov    0x10(%ebp),%edx
 322:	8b 45 0c             	mov    0xc(%ebp),%eax
 325:	89 cb                	mov    %ecx,%ebx
 327:	89 df                	mov    %ebx,%edi
 329:	89 d1                	mov    %edx,%ecx
 32b:	fc                   	cld    
 32c:	f3 aa                	rep stos %al,%es:(%edi)
 32e:	89 ca                	mov    %ecx,%edx
 330:	89 fb                	mov    %edi,%ebx
 332:	89 5d 08             	mov    %ebx,0x8(%ebp)
 335:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 338:	90                   	nop
 339:	5b                   	pop    %ebx
 33a:	5f                   	pop    %edi
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    

0000033d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 349:	90                   	nop
 34a:	8b 55 0c             	mov    0xc(%ebp),%edx
 34d:	8d 42 01             	lea    0x1(%edx),%eax
 350:	89 45 0c             	mov    %eax,0xc(%ebp)
 353:	8b 45 08             	mov    0x8(%ebp),%eax
 356:	8d 48 01             	lea    0x1(%eax),%ecx
 359:	89 4d 08             	mov    %ecx,0x8(%ebp)
 35c:	0f b6 12             	movzbl (%edx),%edx
 35f:	88 10                	mov    %dl,(%eax)
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	84 c0                	test   %al,%al
 366:	75 e2                	jne    34a <strcpy+0xd>
    ;
  return os;
 368:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 370:	eb 08                	jmp    37a <strcmp+0xd>
    p++, q++;
 372:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 376:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
 37d:	0f b6 00             	movzbl (%eax),%eax
 380:	84 c0                	test   %al,%al
 382:	74 10                	je     394 <strcmp+0x27>
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	0f b6 10             	movzbl (%eax),%edx
 38a:	8b 45 0c             	mov    0xc(%ebp),%eax
 38d:	0f b6 00             	movzbl (%eax),%eax
 390:	38 c2                	cmp    %al,%dl
 392:	74 de                	je     372 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	0f b6 00             	movzbl (%eax),%eax
 39a:	0f b6 d0             	movzbl %al,%edx
 39d:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a0:	0f b6 00             	movzbl (%eax),%eax
 3a3:	0f b6 c8             	movzbl %al,%ecx
 3a6:	89 d0                	mov    %edx,%eax
 3a8:	29 c8                	sub    %ecx,%eax
}
 3aa:	5d                   	pop    %ebp
 3ab:	c3                   	ret    

000003ac <strlen>:

uint
strlen(char *s)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3b9:	eb 04                	jmp    3bf <strlen+0x13>
 3bb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	01 d0                	add    %edx,%eax
 3c7:	0f b6 00             	movzbl (%eax),%eax
 3ca:	84 c0                	test   %al,%al
 3cc:	75 ed                	jne    3bb <strlen+0xf>
    ;
  return n;
 3ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d1:	c9                   	leave  
 3d2:	c3                   	ret    

000003d3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d3:	55                   	push   %ebp
 3d4:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3d6:	8b 45 10             	mov    0x10(%ebp),%eax
 3d9:	50                   	push   %eax
 3da:	ff 75 0c             	push   0xc(%ebp)
 3dd:	ff 75 08             	push   0x8(%ebp)
 3e0:	e8 32 ff ff ff       	call   317 <stosb>
 3e5:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3eb:	c9                   	leave  
 3ec:	c3                   	ret    

000003ed <strchr>:

char*
strchr(const char *s, char c)
{
 3ed:	55                   	push   %ebp
 3ee:	89 e5                	mov    %esp,%ebp
 3f0:	83 ec 04             	sub    $0x4,%esp
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3f9:	eb 14                	jmp    40f <strchr+0x22>
    if(*s == c)
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	0f b6 00             	movzbl (%eax),%eax
 401:	38 45 fc             	cmp    %al,-0x4(%ebp)
 404:	75 05                	jne    40b <strchr+0x1e>
      return (char*)s;
 406:	8b 45 08             	mov    0x8(%ebp),%eax
 409:	eb 13                	jmp    41e <strchr+0x31>
  for(; *s; s++)
 40b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	0f b6 00             	movzbl (%eax),%eax
 415:	84 c0                	test   %al,%al
 417:	75 e2                	jne    3fb <strchr+0xe>
  return 0;
 419:	b8 00 00 00 00       	mov    $0x0,%eax
}
 41e:	c9                   	leave  
 41f:	c3                   	ret    

00000420 <gets>:

char*
gets(char *buf, int max)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
 423:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 426:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 42d:	eb 42                	jmp    471 <gets+0x51>
    cc = read(0, &c, 1);
 42f:	83 ec 04             	sub    $0x4,%esp
 432:	6a 01                	push   $0x1
 434:	8d 45 ef             	lea    -0x11(%ebp),%eax
 437:	50                   	push   %eax
 438:	6a 00                	push   $0x0
 43a:	e8 47 01 00 00       	call   586 <read>
 43f:	83 c4 10             	add    $0x10,%esp
 442:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 445:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 449:	7e 33                	jle    47e <gets+0x5e>
      break;
    buf[i++] = c;
 44b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44e:	8d 50 01             	lea    0x1(%eax),%edx
 451:	89 55 f4             	mov    %edx,-0xc(%ebp)
 454:	89 c2                	mov    %eax,%edx
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	01 c2                	add    %eax,%edx
 45b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 45f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 461:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 465:	3c 0a                	cmp    $0xa,%al
 467:	74 16                	je     47f <gets+0x5f>
 469:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 46d:	3c 0d                	cmp    $0xd,%al
 46f:	74 0e                	je     47f <gets+0x5f>
  for(i=0; i+1 < max; ){
 471:	8b 45 f4             	mov    -0xc(%ebp),%eax
 474:	83 c0 01             	add    $0x1,%eax
 477:	39 45 0c             	cmp    %eax,0xc(%ebp)
 47a:	7f b3                	jg     42f <gets+0xf>
 47c:	eb 01                	jmp    47f <gets+0x5f>
      break;
 47e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 47f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	01 d0                	add    %edx,%eax
 487:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 48d:	c9                   	leave  
 48e:	c3                   	ret    

0000048f <stat>:

int
stat(char *n, struct stat *st)
{
 48f:	55                   	push   %ebp
 490:	89 e5                	mov    %esp,%ebp
 492:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 495:	83 ec 08             	sub    $0x8,%esp
 498:	6a 00                	push   $0x0
 49a:	ff 75 08             	push   0x8(%ebp)
 49d:	e8 0c 01 00 00       	call   5ae <open>
 4a2:	83 c4 10             	add    $0x10,%esp
 4a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ac:	79 07                	jns    4b5 <stat+0x26>
    return -1;
 4ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4b3:	eb 25                	jmp    4da <stat+0x4b>
  r = fstat(fd, st);
 4b5:	83 ec 08             	sub    $0x8,%esp
 4b8:	ff 75 0c             	push   0xc(%ebp)
 4bb:	ff 75 f4             	push   -0xc(%ebp)
 4be:	e8 03 01 00 00       	call   5c6 <fstat>
 4c3:	83 c4 10             	add    $0x10,%esp
 4c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4c9:	83 ec 0c             	sub    $0xc,%esp
 4cc:	ff 75 f4             	push   -0xc(%ebp)
 4cf:	e8 c2 00 00 00       	call   596 <close>
 4d4:	83 c4 10             	add    $0x10,%esp
  return r;
 4d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4da:	c9                   	leave  
 4db:	c3                   	ret    

000004dc <atoi>:

int
atoi(const char *s)
{
 4dc:	55                   	push   %ebp
 4dd:	89 e5                	mov    %esp,%ebp
 4df:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e9:	eb 25                	jmp    510 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ee:	89 d0                	mov    %edx,%eax
 4f0:	c1 e0 02             	shl    $0x2,%eax
 4f3:	01 d0                	add    %edx,%eax
 4f5:	01 c0                	add    %eax,%eax
 4f7:	89 c1                	mov    %eax,%ecx
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	8d 50 01             	lea    0x1(%eax),%edx
 4ff:	89 55 08             	mov    %edx,0x8(%ebp)
 502:	0f b6 00             	movzbl (%eax),%eax
 505:	0f be c0             	movsbl %al,%eax
 508:	01 c8                	add    %ecx,%eax
 50a:	83 e8 30             	sub    $0x30,%eax
 50d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	3c 2f                	cmp    $0x2f,%al
 518:	7e 0a                	jle    524 <atoi+0x48>
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
 51d:	0f b6 00             	movzbl (%eax),%eax
 520:	3c 39                	cmp    $0x39,%al
 522:	7e c7                	jle    4eb <atoi+0xf>
  return n;
 524:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 527:	c9                   	leave  
 528:	c3                   	ret    

00000529 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 535:	8b 45 0c             	mov    0xc(%ebp),%eax
 538:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 53b:	eb 17                	jmp    554 <memmove+0x2b>
    *dst++ = *src++;
 53d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 540:	8d 42 01             	lea    0x1(%edx),%eax
 543:	89 45 f8             	mov    %eax,-0x8(%ebp)
 546:	8b 45 fc             	mov    -0x4(%ebp),%eax
 549:	8d 48 01             	lea    0x1(%eax),%ecx
 54c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 54f:	0f b6 12             	movzbl (%edx),%edx
 552:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 554:	8b 45 10             	mov    0x10(%ebp),%eax
 557:	8d 50 ff             	lea    -0x1(%eax),%edx
 55a:	89 55 10             	mov    %edx,0x10(%ebp)
 55d:	85 c0                	test   %eax,%eax
 55f:	7f dc                	jg     53d <memmove+0x14>
  return vdst;
 561:	8b 45 08             	mov    0x8(%ebp),%eax
}
 564:	c9                   	leave  
 565:	c3                   	ret    

00000566 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 566:	b8 01 00 00 00       	mov    $0x1,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret    

0000056e <exit>:
SYSCALL(exit)
 56e:	b8 02 00 00 00       	mov    $0x2,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret    

00000576 <wait>:
SYSCALL(wait)
 576:	b8 03 00 00 00       	mov    $0x3,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret    

0000057e <pipe>:
SYSCALL(pipe)
 57e:	b8 04 00 00 00       	mov    $0x4,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret    

00000586 <read>:
SYSCALL(read)
 586:	b8 05 00 00 00       	mov    $0x5,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret    

0000058e <write>:
SYSCALL(write)
 58e:	b8 10 00 00 00       	mov    $0x10,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret    

00000596 <close>:
SYSCALL(close)
 596:	b8 15 00 00 00       	mov    $0x15,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret    

0000059e <kill>:
SYSCALL(kill)
 59e:	b8 06 00 00 00       	mov    $0x6,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret    

000005a6 <exec>:
SYSCALL(exec)
 5a6:	b8 07 00 00 00       	mov    $0x7,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret    

000005ae <open>:
SYSCALL(open)
 5ae:	b8 0f 00 00 00       	mov    $0xf,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret    

000005b6 <mknod>:
SYSCALL(mknod)
 5b6:	b8 11 00 00 00       	mov    $0x11,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret    

000005be <unlink>:
SYSCALL(unlink)
 5be:	b8 12 00 00 00       	mov    $0x12,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret    

000005c6 <fstat>:
SYSCALL(fstat)
 5c6:	b8 08 00 00 00       	mov    $0x8,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret    

000005ce <link>:
SYSCALL(link)
 5ce:	b8 13 00 00 00       	mov    $0x13,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret    

000005d6 <mkdir>:
SYSCALL(mkdir)
 5d6:	b8 14 00 00 00       	mov    $0x14,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret    

000005de <chdir>:
SYSCALL(chdir)
 5de:	b8 09 00 00 00       	mov    $0x9,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret    

000005e6 <dup>:
SYSCALL(dup)
 5e6:	b8 0a 00 00 00       	mov    $0xa,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret    

000005ee <getpid>:
SYSCALL(getpid)
 5ee:	b8 0b 00 00 00       	mov    $0xb,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret    

000005f6 <sbrk>:
SYSCALL(sbrk)
 5f6:	b8 0c 00 00 00       	mov    $0xc,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret    

000005fe <sleep>:
SYSCALL(sleep)
 5fe:	b8 0d 00 00 00       	mov    $0xd,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret    

00000606 <uptime>:
SYSCALL(uptime)
 606:	b8 0e 00 00 00       	mov    $0xe,%eax
 60b:	cd 40                	int    $0x40
 60d:	c3                   	ret    

0000060e <printpt>:

SYSCALL(printpt)
 60e:	b8 16 00 00 00       	mov    $0x16,%eax
 613:	cd 40                	int    $0x40
 615:	c3                   	ret    

00000616 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 616:	55                   	push   %ebp
 617:	89 e5                	mov    %esp,%ebp
 619:	83 ec 18             	sub    $0x18,%esp
 61c:	8b 45 0c             	mov    0xc(%ebp),%eax
 61f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 622:	83 ec 04             	sub    $0x4,%esp
 625:	6a 01                	push   $0x1
 627:	8d 45 f4             	lea    -0xc(%ebp),%eax
 62a:	50                   	push   %eax
 62b:	ff 75 08             	push   0x8(%ebp)
 62e:	e8 5b ff ff ff       	call   58e <write>
 633:	83 c4 10             	add    $0x10,%esp
}
 636:	90                   	nop
 637:	c9                   	leave  
 638:	c3                   	ret    

00000639 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 639:	55                   	push   %ebp
 63a:	89 e5                	mov    %esp,%ebp
 63c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 63f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 646:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 64a:	74 17                	je     663 <printint+0x2a>
 64c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 650:	79 11                	jns    663 <printint+0x2a>
    neg = 1;
 652:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 659:	8b 45 0c             	mov    0xc(%ebp),%eax
 65c:	f7 d8                	neg    %eax
 65e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 661:	eb 06                	jmp    669 <printint+0x30>
  } else {
    x = xx;
 663:	8b 45 0c             	mov    0xc(%ebp),%eax
 666:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 670:	8b 4d 10             	mov    0x10(%ebp),%ecx
 673:	8b 45 ec             	mov    -0x14(%ebp),%eax
 676:	ba 00 00 00 00       	mov    $0x0,%edx
 67b:	f7 f1                	div    %ecx
 67d:	89 d1                	mov    %edx,%ecx
 67f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 682:	8d 50 01             	lea    0x1(%eax),%edx
 685:	89 55 f4             	mov    %edx,-0xc(%ebp)
 688:	0f b6 91 28 0e 00 00 	movzbl 0xe28(%ecx),%edx
 68f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 693:	8b 4d 10             	mov    0x10(%ebp),%ecx
 696:	8b 45 ec             	mov    -0x14(%ebp),%eax
 699:	ba 00 00 00 00       	mov    $0x0,%edx
 69e:	f7 f1                	div    %ecx
 6a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a7:	75 c7                	jne    670 <printint+0x37>
  if(neg)
 6a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6ad:	74 2d                	je     6dc <printint+0xa3>
    buf[i++] = '-';
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	8d 50 01             	lea    0x1(%eax),%edx
 6b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6bd:	eb 1d                	jmp    6dc <printint+0xa3>
    putc(fd, buf[i]);
 6bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c5:	01 d0                	add    %edx,%eax
 6c7:	0f b6 00             	movzbl (%eax),%eax
 6ca:	0f be c0             	movsbl %al,%eax
 6cd:	83 ec 08             	sub    $0x8,%esp
 6d0:	50                   	push   %eax
 6d1:	ff 75 08             	push   0x8(%ebp)
 6d4:	e8 3d ff ff ff       	call   616 <putc>
 6d9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6dc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e4:	79 d9                	jns    6bf <printint+0x86>
}
 6e6:	90                   	nop
 6e7:	90                   	nop
 6e8:	c9                   	leave  
 6e9:	c3                   	ret    

000006ea <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ea:	55                   	push   %ebp
 6eb:	89 e5                	mov    %esp,%ebp
 6ed:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6f7:	8d 45 0c             	lea    0xc(%ebp),%eax
 6fa:	83 c0 04             	add    $0x4,%eax
 6fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 700:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 707:	e9 59 01 00 00       	jmp    865 <printf+0x17b>
    c = fmt[i] & 0xff;
 70c:	8b 55 0c             	mov    0xc(%ebp),%edx
 70f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 712:	01 d0                	add    %edx,%eax
 714:	0f b6 00             	movzbl (%eax),%eax
 717:	0f be c0             	movsbl %al,%eax
 71a:	25 ff 00 00 00       	and    $0xff,%eax
 71f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 722:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 726:	75 2c                	jne    754 <printf+0x6a>
      if(c == '%'){
 728:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 72c:	75 0c                	jne    73a <printf+0x50>
        state = '%';
 72e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 735:	e9 27 01 00 00       	jmp    861 <printf+0x177>
      } else {
        putc(fd, c);
 73a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73d:	0f be c0             	movsbl %al,%eax
 740:	83 ec 08             	sub    $0x8,%esp
 743:	50                   	push   %eax
 744:	ff 75 08             	push   0x8(%ebp)
 747:	e8 ca fe ff ff       	call   616 <putc>
 74c:	83 c4 10             	add    $0x10,%esp
 74f:	e9 0d 01 00 00       	jmp    861 <printf+0x177>
      }
    } else if(state == '%'){
 754:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 758:	0f 85 03 01 00 00    	jne    861 <printf+0x177>
      if(c == 'd'){
 75e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 762:	75 1e                	jne    782 <printf+0x98>
        printint(fd, *ap, 10, 1);
 764:	8b 45 e8             	mov    -0x18(%ebp),%eax
 767:	8b 00                	mov    (%eax),%eax
 769:	6a 01                	push   $0x1
 76b:	6a 0a                	push   $0xa
 76d:	50                   	push   %eax
 76e:	ff 75 08             	push   0x8(%ebp)
 771:	e8 c3 fe ff ff       	call   639 <printint>
 776:	83 c4 10             	add    $0x10,%esp
        ap++;
 779:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77d:	e9 d8 00 00 00       	jmp    85a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 782:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 786:	74 06                	je     78e <printf+0xa4>
 788:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 78c:	75 1e                	jne    7ac <printf+0xc2>
        printint(fd, *ap, 16, 0);
 78e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 791:	8b 00                	mov    (%eax),%eax
 793:	6a 00                	push   $0x0
 795:	6a 10                	push   $0x10
 797:	50                   	push   %eax
 798:	ff 75 08             	push   0x8(%ebp)
 79b:	e8 99 fe ff ff       	call   639 <printint>
 7a0:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a7:	e9 ae 00 00 00       	jmp    85a <printf+0x170>
      } else if(c == 's'){
 7ac:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7b0:	75 43                	jne    7f5 <printf+0x10b>
        s = (char*)*ap;
 7b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b5:	8b 00                	mov    (%eax),%eax
 7b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c2:	75 25                	jne    7e9 <printf+0xff>
          s = "(null)";
 7c4:	c7 45 f4 69 0b 00 00 	movl   $0xb69,-0xc(%ebp)
        while(*s != 0){
 7cb:	eb 1c                	jmp    7e9 <printf+0xff>
          putc(fd, *s);
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	0f b6 00             	movzbl (%eax),%eax
 7d3:	0f be c0             	movsbl %al,%eax
 7d6:	83 ec 08             	sub    $0x8,%esp
 7d9:	50                   	push   %eax
 7da:	ff 75 08             	push   0x8(%ebp)
 7dd:	e8 34 fe ff ff       	call   616 <putc>
 7e2:	83 c4 10             	add    $0x10,%esp
          s++;
 7e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	0f b6 00             	movzbl (%eax),%eax
 7ef:	84 c0                	test   %al,%al
 7f1:	75 da                	jne    7cd <printf+0xe3>
 7f3:	eb 65                	jmp    85a <printf+0x170>
        }
      } else if(c == 'c'){
 7f5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7f9:	75 1d                	jne    818 <printf+0x12e>
        putc(fd, *ap);
 7fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fe:	8b 00                	mov    (%eax),%eax
 800:	0f be c0             	movsbl %al,%eax
 803:	83 ec 08             	sub    $0x8,%esp
 806:	50                   	push   %eax
 807:	ff 75 08             	push   0x8(%ebp)
 80a:	e8 07 fe ff ff       	call   616 <putc>
 80f:	83 c4 10             	add    $0x10,%esp
        ap++;
 812:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 816:	eb 42                	jmp    85a <printf+0x170>
      } else if(c == '%'){
 818:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 81c:	75 17                	jne    835 <printf+0x14b>
        putc(fd, c);
 81e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 821:	0f be c0             	movsbl %al,%eax
 824:	83 ec 08             	sub    $0x8,%esp
 827:	50                   	push   %eax
 828:	ff 75 08             	push   0x8(%ebp)
 82b:	e8 e6 fd ff ff       	call   616 <putc>
 830:	83 c4 10             	add    $0x10,%esp
 833:	eb 25                	jmp    85a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 835:	83 ec 08             	sub    $0x8,%esp
 838:	6a 25                	push   $0x25
 83a:	ff 75 08             	push   0x8(%ebp)
 83d:	e8 d4 fd ff ff       	call   616 <putc>
 842:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 845:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 848:	0f be c0             	movsbl %al,%eax
 84b:	83 ec 08             	sub    $0x8,%esp
 84e:	50                   	push   %eax
 84f:	ff 75 08             	push   0x8(%ebp)
 852:	e8 bf fd ff ff       	call   616 <putc>
 857:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 85a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 861:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 865:	8b 55 0c             	mov    0xc(%ebp),%edx
 868:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86b:	01 d0                	add    %edx,%eax
 86d:	0f b6 00             	movzbl (%eax),%eax
 870:	84 c0                	test   %al,%al
 872:	0f 85 94 fe ff ff    	jne    70c <printf+0x22>
    }
  }
}
 878:	90                   	nop
 879:	90                   	nop
 87a:	c9                   	leave  
 87b:	c3                   	ret    

0000087c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87c:	55                   	push   %ebp
 87d:	89 e5                	mov    %esp,%ebp
 87f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 882:	8b 45 08             	mov    0x8(%ebp),%eax
 885:	83 e8 08             	sub    $0x8,%eax
 888:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88b:	a1 44 0e 00 00       	mov    0xe44,%eax
 890:	89 45 fc             	mov    %eax,-0x4(%ebp)
 893:	eb 24                	jmp    8b9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 89d:	72 12                	jb     8b1 <free+0x35>
 89f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a5:	77 24                	ja     8cb <free+0x4f>
 8a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8aa:	8b 00                	mov    (%eax),%eax
 8ac:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8af:	72 1a                	jb     8cb <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bf:	76 d4                	jbe    895 <free+0x19>
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c9:	73 ca                	jae    895 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	8b 40 04             	mov    0x4(%eax),%eax
 8d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8db:	01 c2                	add    %eax,%edx
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	39 c2                	cmp    %eax,%edx
 8e4:	75 24                	jne    90a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e9:	8b 50 04             	mov    0x4(%eax),%edx
 8ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ef:	8b 00                	mov    (%eax),%eax
 8f1:	8b 40 04             	mov    0x4(%eax),%eax
 8f4:	01 c2                	add    %eax,%edx
 8f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	8b 10                	mov    (%eax),%edx
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	89 10                	mov    %edx,(%eax)
 908:	eb 0a                	jmp    914 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 90a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90d:	8b 10                	mov    (%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 914:	8b 45 fc             	mov    -0x4(%ebp),%eax
 917:	8b 40 04             	mov    0x4(%eax),%eax
 91a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	01 d0                	add    %edx,%eax
 926:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 929:	75 20                	jne    94b <free+0xcf>
    p->s.size += bp->s.size;
 92b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92e:	8b 50 04             	mov    0x4(%eax),%edx
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	01 c2                	add    %eax,%edx
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	8b 10                	mov    (%eax),%edx
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	89 10                	mov    %edx,(%eax)
 949:	eb 08                	jmp    953 <free+0xd7>
  } else
    p->s.ptr = bp;
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 951:	89 10                	mov    %edx,(%eax)
  freep = p;
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	a3 44 0e 00 00       	mov    %eax,0xe44
}
 95b:	90                   	nop
 95c:	c9                   	leave  
 95d:	c3                   	ret    

0000095e <morecore>:

static Header*
morecore(uint nu)
{
 95e:	55                   	push   %ebp
 95f:	89 e5                	mov    %esp,%ebp
 961:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 964:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 96b:	77 07                	ja     974 <morecore+0x16>
    nu = 4096;
 96d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 974:	8b 45 08             	mov    0x8(%ebp),%eax
 977:	c1 e0 03             	shl    $0x3,%eax
 97a:	83 ec 0c             	sub    $0xc,%esp
 97d:	50                   	push   %eax
 97e:	e8 73 fc ff ff       	call   5f6 <sbrk>
 983:	83 c4 10             	add    $0x10,%esp
 986:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 989:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 98d:	75 07                	jne    996 <morecore+0x38>
    return 0;
 98f:	b8 00 00 00 00       	mov    $0x0,%eax
 994:	eb 26                	jmp    9bc <morecore+0x5e>
  hp = (Header*)p;
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 99c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99f:	8b 55 08             	mov    0x8(%ebp),%edx
 9a2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a8:	83 c0 08             	add    $0x8,%eax
 9ab:	83 ec 0c             	sub    $0xc,%esp
 9ae:	50                   	push   %eax
 9af:	e8 c8 fe ff ff       	call   87c <free>
 9b4:	83 c4 10             	add    $0x10,%esp
  return freep;
 9b7:	a1 44 0e 00 00       	mov    0xe44,%eax
}
 9bc:	c9                   	leave  
 9bd:	c3                   	ret    

000009be <malloc>:

void*
malloc(uint nbytes)
{
 9be:	55                   	push   %ebp
 9bf:	89 e5                	mov    %esp,%ebp
 9c1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c4:	8b 45 08             	mov    0x8(%ebp),%eax
 9c7:	83 c0 07             	add    $0x7,%eax
 9ca:	c1 e8 03             	shr    $0x3,%eax
 9cd:	83 c0 01             	add    $0x1,%eax
 9d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9d3:	a1 44 0e 00 00       	mov    0xe44,%eax
 9d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9df:	75 23                	jne    a04 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9e1:	c7 45 f0 3c 0e 00 00 	movl   $0xe3c,-0x10(%ebp)
 9e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9eb:	a3 44 0e 00 00       	mov    %eax,0xe44
 9f0:	a1 44 0e 00 00       	mov    0xe44,%eax
 9f5:	a3 3c 0e 00 00       	mov    %eax,0xe3c
    base.s.size = 0;
 9fa:	c7 05 40 0e 00 00 00 	movl   $0x0,0xe40
 a01:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a07:	8b 00                	mov    (%eax),%eax
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0f:	8b 40 04             	mov    0x4(%eax),%eax
 a12:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a15:	77 4d                	ja     a64 <malloc+0xa6>
      if(p->s.size == nunits)
 a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1a:	8b 40 04             	mov    0x4(%eax),%eax
 a1d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a20:	75 0c                	jne    a2e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a25:	8b 10                	mov    (%eax),%edx
 a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2a:	89 10                	mov    %edx,(%eax)
 a2c:	eb 26                	jmp    a54 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	8b 40 04             	mov    0x4(%eax),%eax
 a34:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a37:	89 c2                	mov    %eax,%edx
 a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 40 04             	mov    0x4(%eax),%eax
 a45:	c1 e0 03             	shl    $0x3,%eax
 a48:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a51:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a57:	a3 44 0e 00 00       	mov    %eax,0xe44
      return (void*)(p + 1);
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	83 c0 08             	add    $0x8,%eax
 a62:	eb 3b                	jmp    a9f <malloc+0xe1>
    }
    if(p == freep)
 a64:	a1 44 0e 00 00       	mov    0xe44,%eax
 a69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a6c:	75 1e                	jne    a8c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a6e:	83 ec 0c             	sub    $0xc,%esp
 a71:	ff 75 ec             	push   -0x14(%ebp)
 a74:	e8 e5 fe ff ff       	call   95e <morecore>
 a79:	83 c4 10             	add    $0x10,%esp
 a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a83:	75 07                	jne    a8c <malloc+0xce>
        return 0;
 a85:	b8 00 00 00 00       	mov    $0x0,%eax
 a8a:	eb 13                	jmp    a9f <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 00                	mov    (%eax),%eax
 a97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a9a:	e9 6d ff ff ff       	jmp    a0c <malloc+0x4e>
  }
}
 a9f:	c9                   	leave  
 aa0:	c3                   	ret    
