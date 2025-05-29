
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  if(n == 0)
   6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   a:	75 07                	jne    13 <recurse+0x13>
    return 0;
   c:	b8 00 00 00 00       	mov    $0x0,%eax
  11:	eb 17                	jmp    2a <recurse+0x2a>
  return n + recurse(n - 1);
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	83 e8 01             	sub    $0x1,%eax
  19:	83 ec 0c             	sub    $0xc,%esp
  1c:	50                   	push   %eax
  1d:	e8 de ff ff ff       	call   0 <recurse>
  22:	83 c4 10             	add    $0x10,%esp
  25:	8b 55 08             	mov    0x8(%ebp),%edx
  28:	01 d0                	add    %edx,%eax
}
  2a:	c9                   	leave  
  2b:	c3                   	ret    

0000002c <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  2c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  30:	83 e4 f0             	and    $0xfffffff0,%esp
  33:	ff 71 fc             	push   -0x4(%ecx)
  36:	55                   	push   %ebp
  37:	89 e5                	mov    %esp,%ebp
  39:	53                   	push   %ebx
  3a:	51                   	push   %ecx
  3b:	83 ec 10             	sub    $0x10,%esp
  3e:	89 cb                	mov    %ecx,%ebx
  int n, m;

  if(argc != 2){
  40:	83 3b 02             	cmpl   $0x2,(%ebx)
  43:	74 1d                	je     62 <main+0x36>
    printf(1, "Usage: %s levels\n", argv[0]);
  45:	8b 43 04             	mov    0x4(%ebx),%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 04             	sub    $0x4,%esp
  4d:	50                   	push   %eax
  4e:	68 65 08 00 00       	push   $0x865
  53:	6a 01                	push   $0x1
  55:	e8 54 04 00 00       	call   4ae <printf>
  5a:	83 c4 10             	add    $0x10,%esp
    exit();
  5d:	e8 d0 02 00 00       	call   332 <exit>
  }
  printpt(getpid()); // Uncomment for the test.
  62:	e8 4b 03 00 00       	call   3b2 <getpid>
  67:	83 ec 0c             	sub    $0xc,%esp
  6a:	50                   	push   %eax
  6b:	e8 62 03 00 00       	call   3d2 <printpt>
  70:	83 c4 10             	add    $0x10,%esp
  n = atoi(argv[1]);
  73:	8b 43 04             	mov    0x4(%ebx),%eax
  76:	83 c0 04             	add    $0x4,%eax
  79:	8b 00                	mov    (%eax),%eax
  7b:	83 ec 0c             	sub    $0xc,%esp
  7e:	50                   	push   %eax
  7f:	e8 1c 02 00 00       	call   2a0 <atoi>
  84:	83 c4 10             	add    $0x10,%esp
  87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  8a:	83 ec 04             	sub    $0x4,%esp
  8d:	ff 75 f4             	push   -0xc(%ebp)
  90:	68 77 08 00 00       	push   $0x877
  95:	6a 01                	push   $0x1
  97:	e8 12 04 00 00       	call   4ae <printf>
  9c:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  9f:	83 ec 0c             	sub    $0xc,%esp
  a2:	ff 75 f4             	push   -0xc(%ebp)
  a5:	e8 56 ff ff ff       	call   0 <recurse>
  aa:	83 c4 10             	add    $0x10,%esp
  ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  b0:	83 ec 04             	sub    $0x4,%esp
  b3:	ff 75 f0             	push   -0x10(%ebp)
  b6:	68 8c 08 00 00       	push   $0x88c
  bb:	6a 01                	push   $0x1
  bd:	e8 ec 03 00 00       	call   4ae <printf>
  c2:	83 c4 10             	add    $0x10,%esp
  
  printpt(getpid()); // Uncomment for the test.
  c5:	e8 e8 02 00 00       	call   3b2 <getpid>
  ca:	83 ec 0c             	sub    $0xc,%esp
  cd:	50                   	push   %eax
  ce:	e8 ff 02 00 00       	call   3d2 <printpt>
  d3:	83 c4 10             	add    $0x10,%esp
  exit();
  d6:	e8 57 02 00 00       	call   332 <exit>

000000db <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  de:	57                   	push   %edi
  df:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e3:	8b 55 10             	mov    0x10(%ebp),%edx
  e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  e9:	89 cb                	mov    %ecx,%ebx
  eb:	89 df                	mov    %ebx,%edi
  ed:	89 d1                	mov    %edx,%ecx
  ef:	fc                   	cld    
  f0:	f3 aa                	rep stos %al,%es:(%edi)
  f2:	89 ca                	mov    %ecx,%edx
  f4:	89 fb                	mov    %edi,%ebx
  f6:	89 5d 08             	mov    %ebx,0x8(%ebp)
  f9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  fc:	90                   	nop
  fd:	5b                   	pop    %ebx
  fe:	5f                   	pop    %edi
  ff:	5d                   	pop    %ebp
 100:	c3                   	ret    

00000101 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 101:	55                   	push   %ebp
 102:	89 e5                	mov    %esp,%ebp
 104:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 107:	8b 45 08             	mov    0x8(%ebp),%eax
 10a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 10d:	90                   	nop
 10e:	8b 55 0c             	mov    0xc(%ebp),%edx
 111:	8d 42 01             	lea    0x1(%edx),%eax
 114:	89 45 0c             	mov    %eax,0xc(%ebp)
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	8d 48 01             	lea    0x1(%eax),%ecx
 11d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 120:	0f b6 12             	movzbl (%edx),%edx
 123:	88 10                	mov    %dl,(%eax)
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	75 e2                	jne    10e <strcpy+0xd>
    ;
  return os;
 12c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12f:	c9                   	leave  
 130:	c3                   	ret    

00000131 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 134:	eb 08                	jmp    13e <strcmp+0xd>
    p++, q++;
 136:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 13e:	8b 45 08             	mov    0x8(%ebp),%eax
 141:	0f b6 00             	movzbl (%eax),%eax
 144:	84 c0                	test   %al,%al
 146:	74 10                	je     158 <strcmp+0x27>
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	0f b6 10             	movzbl (%eax),%edx
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	38 c2                	cmp    %al,%dl
 156:	74 de                	je     136 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 00             	movzbl (%eax),%eax
 15e:	0f b6 d0             	movzbl %al,%edx
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	0f b6 c8             	movzbl %al,%ecx
 16a:	89 d0                	mov    %edx,%eax
 16c:	29 c8                	sub    %ecx,%eax
}
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    

00000170 <strlen>:

uint
strlen(char *s)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 176:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 17d:	eb 04                	jmp    183 <strlen+0x13>
 17f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 183:	8b 55 fc             	mov    -0x4(%ebp),%edx
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	01 d0                	add    %edx,%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	75 ed                	jne    17f <strlen+0xf>
    ;
  return n;
 192:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <memset>:

void*
memset(void *dst, int c, uint n)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 19a:	8b 45 10             	mov    0x10(%ebp),%eax
 19d:	50                   	push   %eax
 19e:	ff 75 0c             	push   0xc(%ebp)
 1a1:	ff 75 08             	push   0x8(%ebp)
 1a4:	e8 32 ff ff ff       	call   db <stosb>
 1a9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1af:	c9                   	leave  
 1b0:	c3                   	ret    

000001b1 <strchr>:

char*
strchr(const char *s, char c)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 04             	sub    $0x4,%esp
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1bd:	eb 14                	jmp    1d3 <strchr+0x22>
    if(*s == c)
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 00             	movzbl (%eax),%eax
 1c5:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1c8:	75 05                	jne    1cf <strchr+0x1e>
      return (char*)s;
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	eb 13                	jmp    1e2 <strchr+0x31>
  for(; *s; s++)
 1cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 e2                	jne    1bf <strchr+0xe>
  return 0;
 1dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <gets>:

char*
gets(char *buf, int max)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f1:	eb 42                	jmp    235 <gets+0x51>
    cc = read(0, &c, 1);
 1f3:	83 ec 04             	sub    $0x4,%esp
 1f6:	6a 01                	push   $0x1
 1f8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1fb:	50                   	push   %eax
 1fc:	6a 00                	push   $0x0
 1fe:	e8 47 01 00 00       	call   34a <read>
 203:	83 c4 10             	add    $0x10,%esp
 206:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20d:	7e 33                	jle    242 <gets+0x5e>
      break;
    buf[i++] = c;
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	8d 50 01             	lea    0x1(%eax),%edx
 215:	89 55 f4             	mov    %edx,-0xc(%ebp)
 218:	89 c2                	mov    %eax,%edx
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	01 c2                	add    %eax,%edx
 21f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 223:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 225:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 229:	3c 0a                	cmp    $0xa,%al
 22b:	74 16                	je     243 <gets+0x5f>
 22d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 231:	3c 0d                	cmp    $0xd,%al
 233:	74 0e                	je     243 <gets+0x5f>
  for(i=0; i+1 < max; ){
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	83 c0 01             	add    $0x1,%eax
 23b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 23e:	7f b3                	jg     1f3 <gets+0xf>
 240:	eb 01                	jmp    243 <gets+0x5f>
      break;
 242:	90                   	nop
      break;
  }
  buf[i] = '\0';
 243:	8b 55 f4             	mov    -0xc(%ebp),%edx
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	01 d0                	add    %edx,%eax
 24b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <stat>:

int
stat(char *n, struct stat *st)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 259:	83 ec 08             	sub    $0x8,%esp
 25c:	6a 00                	push   $0x0
 25e:	ff 75 08             	push   0x8(%ebp)
 261:	e8 0c 01 00 00       	call   372 <open>
 266:	83 c4 10             	add    $0x10,%esp
 269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 26c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 270:	79 07                	jns    279 <stat+0x26>
    return -1;
 272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 277:	eb 25                	jmp    29e <stat+0x4b>
  r = fstat(fd, st);
 279:	83 ec 08             	sub    $0x8,%esp
 27c:	ff 75 0c             	push   0xc(%ebp)
 27f:	ff 75 f4             	push   -0xc(%ebp)
 282:	e8 03 01 00 00       	call   38a <fstat>
 287:	83 c4 10             	add    $0x10,%esp
 28a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	ff 75 f4             	push   -0xc(%ebp)
 293:	e8 c2 00 00 00       	call   35a <close>
 298:	83 c4 10             	add    $0x10,%esp
  return r;
 29b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2ad:	eb 25                	jmp    2d4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2af:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2b2:	89 d0                	mov    %edx,%eax
 2b4:	c1 e0 02             	shl    $0x2,%eax
 2b7:	01 d0                	add    %edx,%eax
 2b9:	01 c0                	add    %eax,%eax
 2bb:	89 c1                	mov    %eax,%ecx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	8d 50 01             	lea    0x1(%eax),%edx
 2c3:	89 55 08             	mov    %edx,0x8(%ebp)
 2c6:	0f b6 00             	movzbl (%eax),%eax
 2c9:	0f be c0             	movsbl %al,%eax
 2cc:	01 c8                	add    %ecx,%eax
 2ce:	83 e8 30             	sub    $0x30,%eax
 2d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	0f b6 00             	movzbl (%eax),%eax
 2da:	3c 2f                	cmp    $0x2f,%al
 2dc:	7e 0a                	jle    2e8 <atoi+0x48>
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	0f b6 00             	movzbl (%eax),%eax
 2e4:	3c 39                	cmp    $0x39,%al
 2e6:	7e c7                	jle    2af <atoi+0xf>
  return n;
 2e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ff:	eb 17                	jmp    318 <memmove+0x2b>
    *dst++ = *src++;
 301:	8b 55 f8             	mov    -0x8(%ebp),%edx
 304:	8d 42 01             	lea    0x1(%edx),%eax
 307:	89 45 f8             	mov    %eax,-0x8(%ebp)
 30a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 30d:	8d 48 01             	lea    0x1(%eax),%ecx
 310:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 313:	0f b6 12             	movzbl (%edx),%edx
 316:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 318:	8b 45 10             	mov    0x10(%ebp),%eax
 31b:	8d 50 ff             	lea    -0x1(%eax),%edx
 31e:	89 55 10             	mov    %edx,0x10(%ebp)
 321:	85 c0                	test   %eax,%eax
 323:	7f dc                	jg     301 <memmove+0x14>
  return vdst;
 325:	8b 45 08             	mov    0x8(%ebp),%eax
}
 328:	c9                   	leave  
 329:	c3                   	ret    

0000032a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 32a:	b8 01 00 00 00       	mov    $0x1,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <exit>:
SYSCALL(exit)
 332:	b8 02 00 00 00       	mov    $0x2,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <wait>:
SYSCALL(wait)
 33a:	b8 03 00 00 00       	mov    $0x3,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <pipe>:
SYSCALL(pipe)
 342:	b8 04 00 00 00       	mov    $0x4,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <read>:
SYSCALL(read)
 34a:	b8 05 00 00 00       	mov    $0x5,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <write>:
SYSCALL(write)
 352:	b8 10 00 00 00       	mov    $0x10,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <close>:
SYSCALL(close)
 35a:	b8 15 00 00 00       	mov    $0x15,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <kill>:
SYSCALL(kill)
 362:	b8 06 00 00 00       	mov    $0x6,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <exec>:
SYSCALL(exec)
 36a:	b8 07 00 00 00       	mov    $0x7,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <open>:
SYSCALL(open)
 372:	b8 0f 00 00 00       	mov    $0xf,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <mknod>:
SYSCALL(mknod)
 37a:	b8 11 00 00 00       	mov    $0x11,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <unlink>:
SYSCALL(unlink)
 382:	b8 12 00 00 00       	mov    $0x12,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <fstat>:
SYSCALL(fstat)
 38a:	b8 08 00 00 00       	mov    $0x8,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <link>:
SYSCALL(link)
 392:	b8 13 00 00 00       	mov    $0x13,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <mkdir>:
SYSCALL(mkdir)
 39a:	b8 14 00 00 00       	mov    $0x14,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <chdir>:
SYSCALL(chdir)
 3a2:	b8 09 00 00 00       	mov    $0x9,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <dup>:
SYSCALL(dup)
 3aa:	b8 0a 00 00 00       	mov    $0xa,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <getpid>:
SYSCALL(getpid)
 3b2:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <sbrk>:
SYSCALL(sbrk)
 3ba:	b8 0c 00 00 00       	mov    $0xc,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <sleep>:
SYSCALL(sleep)
 3c2:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <uptime>:
SYSCALL(uptime)
 3ca:	b8 0e 00 00 00       	mov    $0xe,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <printpt>:

SYSCALL(printpt)
 3d2:	b8 16 00 00 00       	mov    $0x16,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
 3dd:	83 ec 18             	sub    $0x18,%esp
 3e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3e6:	83 ec 04             	sub    $0x4,%esp
 3e9:	6a 01                	push   $0x1
 3eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ee:	50                   	push   %eax
 3ef:	ff 75 08             	push   0x8(%ebp)
 3f2:	e8 5b ff ff ff       	call   352 <write>
 3f7:	83 c4 10             	add    $0x10,%esp
}
 3fa:	90                   	nop
 3fb:	c9                   	leave  
 3fc:	c3                   	ret    

000003fd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fd:	55                   	push   %ebp
 3fe:	89 e5                	mov    %esp,%ebp
 400:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 403:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 40a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 40e:	74 17                	je     427 <printint+0x2a>
 410:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 414:	79 11                	jns    427 <printint+0x2a>
    neg = 1;
 416:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 41d:	8b 45 0c             	mov    0xc(%ebp),%eax
 420:	f7 d8                	neg    %eax
 422:	89 45 ec             	mov    %eax,-0x14(%ebp)
 425:	eb 06                	jmp    42d <printint+0x30>
  } else {
    x = xx;
 427:	8b 45 0c             	mov    0xc(%ebp),%eax
 42a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 42d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 434:	8b 4d 10             	mov    0x10(%ebp),%ecx
 437:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43a:	ba 00 00 00 00       	mov    $0x0,%edx
 43f:	f7 f1                	div    %ecx
 441:	89 d1                	mov    %edx,%ecx
 443:	8b 45 f4             	mov    -0xc(%ebp),%eax
 446:	8d 50 01             	lea    0x1(%eax),%edx
 449:	89 55 f4             	mov    %edx,-0xc(%ebp)
 44c:	0f b6 91 14 0b 00 00 	movzbl 0xb14(%ecx),%edx
 453:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 457:	8b 4d 10             	mov    0x10(%ebp),%ecx
 45a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 45d:	ba 00 00 00 00       	mov    $0x0,%edx
 462:	f7 f1                	div    %ecx
 464:	89 45 ec             	mov    %eax,-0x14(%ebp)
 467:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46b:	75 c7                	jne    434 <printint+0x37>
  if(neg)
 46d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 471:	74 2d                	je     4a0 <printint+0xa3>
    buf[i++] = '-';
 473:	8b 45 f4             	mov    -0xc(%ebp),%eax
 476:	8d 50 01             	lea    0x1(%eax),%edx
 479:	89 55 f4             	mov    %edx,-0xc(%ebp)
 47c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 481:	eb 1d                	jmp    4a0 <printint+0xa3>
    putc(fd, buf[i]);
 483:	8d 55 dc             	lea    -0x24(%ebp),%edx
 486:	8b 45 f4             	mov    -0xc(%ebp),%eax
 489:	01 d0                	add    %edx,%eax
 48b:	0f b6 00             	movzbl (%eax),%eax
 48e:	0f be c0             	movsbl %al,%eax
 491:	83 ec 08             	sub    $0x8,%esp
 494:	50                   	push   %eax
 495:	ff 75 08             	push   0x8(%ebp)
 498:	e8 3d ff ff ff       	call   3da <putc>
 49d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4a0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a8:	79 d9                	jns    483 <printint+0x86>
}
 4aa:	90                   	nop
 4ab:	90                   	nop
 4ac:	c9                   	leave  
 4ad:	c3                   	ret    

000004ae <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ae:	55                   	push   %ebp
 4af:	89 e5                	mov    %esp,%ebp
 4b1:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4b4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4bb:	8d 45 0c             	lea    0xc(%ebp),%eax
 4be:	83 c0 04             	add    $0x4,%eax
 4c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4cb:	e9 59 01 00 00       	jmp    629 <printf+0x17b>
    c = fmt[i] & 0xff;
 4d0:	8b 55 0c             	mov    0xc(%ebp),%edx
 4d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4d6:	01 d0                	add    %edx,%eax
 4d8:	0f b6 00             	movzbl (%eax),%eax
 4db:	0f be c0             	movsbl %al,%eax
 4de:	25 ff 00 00 00       	and    $0xff,%eax
 4e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ea:	75 2c                	jne    518 <printf+0x6a>
      if(c == '%'){
 4ec:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4f0:	75 0c                	jne    4fe <printf+0x50>
        state = '%';
 4f2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4f9:	e9 27 01 00 00       	jmp    625 <printf+0x177>
      } else {
        putc(fd, c);
 4fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 501:	0f be c0             	movsbl %al,%eax
 504:	83 ec 08             	sub    $0x8,%esp
 507:	50                   	push   %eax
 508:	ff 75 08             	push   0x8(%ebp)
 50b:	e8 ca fe ff ff       	call   3da <putc>
 510:	83 c4 10             	add    $0x10,%esp
 513:	e9 0d 01 00 00       	jmp    625 <printf+0x177>
      }
    } else if(state == '%'){
 518:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 51c:	0f 85 03 01 00 00    	jne    625 <printf+0x177>
      if(c == 'd'){
 522:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 526:	75 1e                	jne    546 <printf+0x98>
        printint(fd, *ap, 10, 1);
 528:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52b:	8b 00                	mov    (%eax),%eax
 52d:	6a 01                	push   $0x1
 52f:	6a 0a                	push   $0xa
 531:	50                   	push   %eax
 532:	ff 75 08             	push   0x8(%ebp)
 535:	e8 c3 fe ff ff       	call   3fd <printint>
 53a:	83 c4 10             	add    $0x10,%esp
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 541:	e9 d8 00 00 00       	jmp    61e <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 546:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 54a:	74 06                	je     552 <printf+0xa4>
 54c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 550:	75 1e                	jne    570 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 552:	8b 45 e8             	mov    -0x18(%ebp),%eax
 555:	8b 00                	mov    (%eax),%eax
 557:	6a 00                	push   $0x0
 559:	6a 10                	push   $0x10
 55b:	50                   	push   %eax
 55c:	ff 75 08             	push   0x8(%ebp)
 55f:	e8 99 fe ff ff       	call   3fd <printint>
 564:	83 c4 10             	add    $0x10,%esp
        ap++;
 567:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56b:	e9 ae 00 00 00       	jmp    61e <printf+0x170>
      } else if(c == 's'){
 570:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 574:	75 43                	jne    5b9 <printf+0x10b>
        s = (char*)*ap;
 576:	8b 45 e8             	mov    -0x18(%ebp),%eax
 579:	8b 00                	mov    (%eax),%eax
 57b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 57e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 582:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 586:	75 25                	jne    5ad <printf+0xff>
          s = "(null)";
 588:	c7 45 f4 a3 08 00 00 	movl   $0x8a3,-0xc(%ebp)
        while(*s != 0){
 58f:	eb 1c                	jmp    5ad <printf+0xff>
          putc(fd, *s);
 591:	8b 45 f4             	mov    -0xc(%ebp),%eax
 594:	0f b6 00             	movzbl (%eax),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	83 ec 08             	sub    $0x8,%esp
 59d:	50                   	push   %eax
 59e:	ff 75 08             	push   0x8(%ebp)
 5a1:	e8 34 fe ff ff       	call   3da <putc>
 5a6:	83 c4 10             	add    $0x10,%esp
          s++;
 5a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b0:	0f b6 00             	movzbl (%eax),%eax
 5b3:	84 c0                	test   %al,%al
 5b5:	75 da                	jne    591 <printf+0xe3>
 5b7:	eb 65                	jmp    61e <printf+0x170>
        }
      } else if(c == 'c'){
 5b9:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5bd:	75 1d                	jne    5dc <printf+0x12e>
        putc(fd, *ap);
 5bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c2:	8b 00                	mov    (%eax),%eax
 5c4:	0f be c0             	movsbl %al,%eax
 5c7:	83 ec 08             	sub    $0x8,%esp
 5ca:	50                   	push   %eax
 5cb:	ff 75 08             	push   0x8(%ebp)
 5ce:	e8 07 fe ff ff       	call   3da <putc>
 5d3:	83 c4 10             	add    $0x10,%esp
        ap++;
 5d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5da:	eb 42                	jmp    61e <printf+0x170>
      } else if(c == '%'){
 5dc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e0:	75 17                	jne    5f9 <printf+0x14b>
        putc(fd, c);
 5e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e5:	0f be c0             	movsbl %al,%eax
 5e8:	83 ec 08             	sub    $0x8,%esp
 5eb:	50                   	push   %eax
 5ec:	ff 75 08             	push   0x8(%ebp)
 5ef:	e8 e6 fd ff ff       	call   3da <putc>
 5f4:	83 c4 10             	add    $0x10,%esp
 5f7:	eb 25                	jmp    61e <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f9:	83 ec 08             	sub    $0x8,%esp
 5fc:	6a 25                	push   $0x25
 5fe:	ff 75 08             	push   0x8(%ebp)
 601:	e8 d4 fd ff ff       	call   3da <putc>
 606:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60c:	0f be c0             	movsbl %al,%eax
 60f:	83 ec 08             	sub    $0x8,%esp
 612:	50                   	push   %eax
 613:	ff 75 08             	push   0x8(%ebp)
 616:	e8 bf fd ff ff       	call   3da <putc>
 61b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 61e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 625:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 629:	8b 55 0c             	mov    0xc(%ebp),%edx
 62c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62f:	01 d0                	add    %edx,%eax
 631:	0f b6 00             	movzbl (%eax),%eax
 634:	84 c0                	test   %al,%al
 636:	0f 85 94 fe ff ff    	jne    4d0 <printf+0x22>
    }
  }
}
 63c:	90                   	nop
 63d:	90                   	nop
 63e:	c9                   	leave  
 63f:	c3                   	ret    

00000640 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	83 e8 08             	sub    $0x8,%eax
 64c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64f:	a1 30 0b 00 00       	mov    0xb30,%eax
 654:	89 45 fc             	mov    %eax,-0x4(%ebp)
 657:	eb 24                	jmp    67d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 661:	72 12                	jb     675 <free+0x35>
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 669:	77 24                	ja     68f <free+0x4f>
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 673:	72 1a                	jb     68f <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 683:	76 d4                	jbe    659 <free+0x19>
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 68d:	73 ca                	jae    659 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 68f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	01 c2                	add    %eax,%edx
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	39 c2                	cmp    %eax,%edx
 6a8:	75 24                	jne    6ce <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	8b 50 04             	mov    0x4(%eax),%edx
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 00                	mov    (%eax),%eax
 6b5:	8b 40 04             	mov    0x4(%eax),%eax
 6b8:	01 c2                	add    %eax,%edx
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	8b 00                	mov    (%eax),%eax
 6c5:	8b 10                	mov    (%eax),%edx
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	89 10                	mov    %edx,(%eax)
 6cc:	eb 0a                	jmp    6d8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8b 10                	mov    (%eax),%edx
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 40 04             	mov    0x4(%eax),%eax
 6de:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	01 d0                	add    %edx,%eax
 6ea:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ed:	75 20                	jne    70f <free+0xcf>
    p->s.size += bp->s.size;
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	8b 50 04             	mov    0x4(%eax),%edx
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	8b 40 04             	mov    0x4(%eax),%eax
 6fb:	01 c2                	add    %eax,%edx
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	8b 10                	mov    (%eax),%edx
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	89 10                	mov    %edx,(%eax)
 70d:	eb 08                	jmp    717 <free+0xd7>
  } else
    p->s.ptr = bp;
 70f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 712:	8b 55 f8             	mov    -0x8(%ebp),%edx
 715:	89 10                	mov    %edx,(%eax)
  freep = p;
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	a3 30 0b 00 00       	mov    %eax,0xb30
}
 71f:	90                   	nop
 720:	c9                   	leave  
 721:	c3                   	ret    

00000722 <morecore>:

static Header*
morecore(uint nu)
{
 722:	55                   	push   %ebp
 723:	89 e5                	mov    %esp,%ebp
 725:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 728:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 72f:	77 07                	ja     738 <morecore+0x16>
    nu = 4096;
 731:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 738:	8b 45 08             	mov    0x8(%ebp),%eax
 73b:	c1 e0 03             	shl    $0x3,%eax
 73e:	83 ec 0c             	sub    $0xc,%esp
 741:	50                   	push   %eax
 742:	e8 73 fc ff ff       	call   3ba <sbrk>
 747:	83 c4 10             	add    $0x10,%esp
 74a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 74d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 751:	75 07                	jne    75a <morecore+0x38>
    return 0;
 753:	b8 00 00 00 00       	mov    $0x0,%eax
 758:	eb 26                	jmp    780 <morecore+0x5e>
  hp = (Header*)p;
 75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 760:	8b 45 f0             	mov    -0x10(%ebp),%eax
 763:	8b 55 08             	mov    0x8(%ebp),%edx
 766:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	83 c0 08             	add    $0x8,%eax
 76f:	83 ec 0c             	sub    $0xc,%esp
 772:	50                   	push   %eax
 773:	e8 c8 fe ff ff       	call   640 <free>
 778:	83 c4 10             	add    $0x10,%esp
  return freep;
 77b:	a1 30 0b 00 00       	mov    0xb30,%eax
}
 780:	c9                   	leave  
 781:	c3                   	ret    

00000782 <malloc>:

void*
malloc(uint nbytes)
{
 782:	55                   	push   %ebp
 783:	89 e5                	mov    %esp,%ebp
 785:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 788:	8b 45 08             	mov    0x8(%ebp),%eax
 78b:	83 c0 07             	add    $0x7,%eax
 78e:	c1 e8 03             	shr    $0x3,%eax
 791:	83 c0 01             	add    $0x1,%eax
 794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 797:	a1 30 0b 00 00       	mov    0xb30,%eax
 79c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 79f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7a3:	75 23                	jne    7c8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7a5:	c7 45 f0 28 0b 00 00 	movl   $0xb28,-0x10(%ebp)
 7ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7af:	a3 30 0b 00 00       	mov    %eax,0xb30
 7b4:	a1 30 0b 00 00       	mov    0xb30,%eax
 7b9:	a3 28 0b 00 00       	mov    %eax,0xb28
    base.s.size = 0;
 7be:	c7 05 2c 0b 00 00 00 	movl   $0x0,0xb2c
 7c5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8b 40 04             	mov    0x4(%eax),%eax
 7d6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7d9:	77 4d                	ja     828 <malloc+0xa6>
      if(p->s.size == nunits)
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	8b 40 04             	mov    0x4(%eax),%eax
 7e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7e4:	75 0c                	jne    7f2 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	8b 10                	mov    (%eax),%edx
 7eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ee:	89 10                	mov    %edx,(%eax)
 7f0:	eb 26                	jmp    818 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	8b 40 04             	mov    0x4(%eax),%eax
 7f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7fb:	89 c2                	mov    %eax,%edx
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 803:	8b 45 f4             	mov    -0xc(%ebp),%eax
 806:	8b 40 04             	mov    0x4(%eax),%eax
 809:	c1 e0 03             	shl    $0x3,%eax
 80c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	8b 55 ec             	mov    -0x14(%ebp),%edx
 815:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	a3 30 0b 00 00       	mov    %eax,0xb30
      return (void*)(p + 1);
 820:	8b 45 f4             	mov    -0xc(%ebp),%eax
 823:	83 c0 08             	add    $0x8,%eax
 826:	eb 3b                	jmp    863 <malloc+0xe1>
    }
    if(p == freep)
 828:	a1 30 0b 00 00       	mov    0xb30,%eax
 82d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 830:	75 1e                	jne    850 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 832:	83 ec 0c             	sub    $0xc,%esp
 835:	ff 75 ec             	push   -0x14(%ebp)
 838:	e8 e5 fe ff ff       	call   722 <morecore>
 83d:	83 c4 10             	add    $0x10,%esp
 840:	89 45 f4             	mov    %eax,-0xc(%ebp)
 843:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 847:	75 07                	jne    850 <malloc+0xce>
        return 0;
 849:	b8 00 00 00 00       	mov    $0x0,%eax
 84e:	eb 13                	jmp    863 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	8b 45 f4             	mov    -0xc(%ebp),%eax
 853:	89 45 f0             	mov    %eax,-0x10(%ebp)
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	8b 00                	mov    (%eax),%eax
 85b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 85e:	e9 6d ff ff ff       	jmp    7d0 <malloc+0x4e>
  }
}
 863:	c9                   	leave  
 864:	c3                   	ret    
