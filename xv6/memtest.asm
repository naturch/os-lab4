
_memtest:     file format elf32-i386


Disassembly of section .text:

00000000 <mem>:
int stdout = 1;
#define TOTAL_MEMORY (1 << 20) + (1 << 18)

void
mem(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
	void *m1 = 0, *m2, *start;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	uint cur = 0;
   d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	uint count = 0;
  14:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	uint total_count;
	int pid;

	printf(1, "mem test\n");
  1b:	83 ec 08             	sub    $0x8,%esp
  1e:	68 58 09 00 00       	push   $0x958
  23:	6a 01                	push   $0x1
  25:	e8 61 05 00 00       	call   58b <printf>
  2a:	83 c4 10             	add    $0x10,%esp

	m1 = malloc(4096);
  2d:	83 ec 0c             	sub    $0xc,%esp
  30:	68 00 10 00 00       	push   $0x1000
  35:	e8 25 08 00 00       	call   85f <malloc>
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (m1 == 0)
  40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  44:	0f 84 18 01 00 00    	je     162 <mem+0x162>
		goto failed;
	start = m1;
  4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4d:	89 45 e8             	mov    %eax,-0x18(%ebp)

	while (cur < TOTAL_MEMORY) {
  50:	eb 43                	jmp    95 <mem+0x95>
		m2 = malloc(4096);
  52:	83 ec 0c             	sub    $0xc,%esp
  55:	68 00 10 00 00       	push   $0x1000
  5a:	e8 00 08 00 00       	call   85f <malloc>
  5f:	83 c4 10             	add    $0x10,%esp
  62:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (m2 == 0)
  65:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  69:	0f 84 f6 00 00 00    	je     165 <mem+0x165>
			goto failed;
		*(char**)m1 = m2;
  6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  75:	89 10                	mov    %edx,(%eax)
		((int*)m1)[2] = count++;
  77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  7a:	8d 50 01             	lea    0x1(%eax),%edx
  7d:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  83:	83 c2 08             	add    $0x8,%edx
  86:	89 02                	mov    %eax,(%edx)
		m1 = m2;
  88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cur += 4096;
  8e:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
	while (cur < TOTAL_MEMORY) {
  95:	81 7d f0 ff ff 13 00 	cmpl   $0x13ffff,-0x10(%ebp)
  9c:	76 b4                	jbe    52 <mem+0x52>
	}
	((int*)m1)[2] = count;
  9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a1:	8d 50 08             	lea    0x8(%eax),%edx
  a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  a7:	89 02                	mov    %eax,(%edx)
	total_count = count;
  a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	count = 0;
  af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	m1 = start;
  b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  b9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while (count != total_count) {
  bc:	eb 1d                	jmp    db <mem+0xdb>
		if (((int*)m1)[2] != count)
  be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c1:	83 c0 08             	add    $0x8,%eax
  c4:	8b 00                	mov    (%eax),%eax
  c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  c9:	0f 85 99 00 00 00    	jne    168 <mem+0x168>
			goto failed;
		m1 = *(char**)m1;
  cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d2:	8b 00                	mov    (%eax),%eax
  d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
		count++;
  d7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
	while (count != total_count) {
  db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  de:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  e1:	75 db                	jne    be <mem+0xbe>
	}

	pid = fork();
  e3:	e8 1f 03 00 00       	call   407 <fork>
  e8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (pid == 0){
  eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  ef:	75 35                	jne    126 <mem+0x126>
		count = 0;
  f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		m1 = start;
  f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	
		while (count != total_count) {
  fe:	eb 19                	jmp    119 <mem+0x119>
			if (((int*)m1)[2] != count){
 100:	8b 45 f4             	mov    -0xc(%ebp),%eax
 103:	83 c0 08             	add    $0x8,%eax
 106:	8b 00                	mov    (%eax),%eax
 108:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 10b:	75 5e                	jne    16b <mem+0x16b>
				goto failed;
			}
			m1 = *(char**)m1;
 10d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 110:	8b 00                	mov    (%eax),%eax
 112:	89 45 f4             	mov    %eax,-0xc(%ebp)
			count++;
 115:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
		while (count != total_count) {
 119:	8b 45 ec             	mov    -0x14(%ebp),%eax
 11c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
 11f:	75 df                	jne    100 <mem+0x100>
		}
		exit();
 121:	e8 e9 02 00 00       	call   40f <exit>
	}
	else if (pid < 0)
 126:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 12a:	79 14                	jns    140 <mem+0x140>
	{
		printf(1, "fork failed\n");
 12c:	83 ec 08             	sub    $0x8,%esp
 12f:	68 62 09 00 00       	push   $0x962
 134:	6a 01                	push   $0x1
 136:	e8 50 04 00 00       	call   58b <printf>
 13b:	83 c4 10             	add    $0x10,%esp
 13e:	eb 0b                	jmp    14b <mem+0x14b>
	}
	else if (pid > 0)
 140:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 144:	7e 05                	jle    14b <mem+0x14b>
	{
		wait();
 146:	e8 cc 02 00 00       	call   417 <wait>
	}

	printf(1, "mem ok\n");
 14b:	83 ec 08             	sub    $0x8,%esp
 14e:	68 6f 09 00 00       	push   $0x96f
 153:	6a 01                	push   $0x1
 155:	e8 31 04 00 00       	call   58b <printf>
 15a:	83 c4 10             	add    $0x10,%esp
	exit();
 15d:	e8 ad 02 00 00       	call   40f <exit>
		goto failed;
 162:	90                   	nop
 163:	eb 07                	jmp    16c <mem+0x16c>
			goto failed;
 165:	90                   	nop
 166:	eb 04                	jmp    16c <mem+0x16c>
			goto failed;
 168:	90                   	nop
 169:	eb 01                	jmp    16c <mem+0x16c>
				goto failed;
 16b:	90                   	nop
failed:
	printf(1, "test failed!\n");
 16c:	83 ec 08             	sub    $0x8,%esp
 16f:	68 77 09 00 00       	push   $0x977
 174:	6a 01                	push   $0x1
 176:	e8 10 04 00 00       	call   58b <printf>
 17b:	83 c4 10             	add    $0x10,%esp
	exit();
 17e:	e8 8c 02 00 00       	call   40f <exit>

00000183 <main>:
}

int
main(int argc, char *argv[])
{
 183:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 187:	83 e4 f0             	and    $0xfffffff0,%esp
 18a:	ff 71 fc             	push   -0x4(%ecx)
 18d:	55                   	push   %ebp
 18e:	89 e5                	mov    %esp,%ebp
 190:	51                   	push   %ecx
 191:	83 ec 04             	sub    $0x4,%esp
	printf(1, "memtest starting\n");
 194:	83 ec 08             	sub    $0x8,%esp
 197:	68 85 09 00 00       	push   $0x985
 19c:	6a 01                	push   $0x1
 19e:	e8 e8 03 00 00       	call   58b <printf>
 1a3:	83 c4 10             	add    $0x10,%esp
	mem();
 1a6:	e8 55 fe ff ff       	call   0 <mem>
	return 0;
 1ab:	b8 00 00 00 00       	mov    $0x0,%eax
 1b0:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 1b3:	c9                   	leave  
 1b4:	8d 61 fc             	lea    -0x4(%ecx),%esp
 1b7:	c3                   	ret    

000001b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b8:	55                   	push   %ebp
 1b9:	89 e5                	mov    %esp,%ebp
 1bb:	57                   	push   %edi
 1bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c0:	8b 55 10             	mov    0x10(%ebp),%edx
 1c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c6:	89 cb                	mov    %ecx,%ebx
 1c8:	89 df                	mov    %ebx,%edi
 1ca:	89 d1                	mov    %edx,%ecx
 1cc:	fc                   	cld    
 1cd:	f3 aa                	rep stos %al,%es:(%edi)
 1cf:	89 ca                	mov    %ecx,%edx
 1d1:	89 fb                	mov    %edi,%ebx
 1d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1d9:	90                   	nop
 1da:	5b                   	pop    %ebx
 1db:	5f                   	pop    %edi
 1dc:	5d                   	pop    %ebp
 1dd:	c3                   	ret    

000001de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1de:	55                   	push   %ebp
 1df:	89 e5                	mov    %esp,%ebp
 1e1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1ea:	90                   	nop
 1eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 1ee:	8d 42 01             	lea    0x1(%edx),%eax
 1f1:	89 45 0c             	mov    %eax,0xc(%ebp)
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	8d 48 01             	lea    0x1(%eax),%ecx
 1fa:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1fd:	0f b6 12             	movzbl (%edx),%edx
 200:	88 10                	mov    %dl,(%eax)
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	84 c0                	test   %al,%al
 207:	75 e2                	jne    1eb <strcpy+0xd>
    ;
  return os;
 209:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 211:	eb 08                	jmp    21b <strcmp+0xd>
    p++, q++;
 213:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 217:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	74 10                	je     235 <strcmp+0x27>
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	0f b6 10             	movzbl (%eax),%edx
 22b:	8b 45 0c             	mov    0xc(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	38 c2                	cmp    %al,%dl
 233:	74 de                	je     213 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	0f b6 00             	movzbl (%eax),%eax
 23b:	0f b6 d0             	movzbl %al,%edx
 23e:	8b 45 0c             	mov    0xc(%ebp),%eax
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	0f b6 c8             	movzbl %al,%ecx
 247:	89 d0                	mov    %edx,%eax
 249:	29 c8                	sub    %ecx,%eax
}
 24b:	5d                   	pop    %ebp
 24c:	c3                   	ret    

0000024d <strlen>:

uint
strlen(char *s)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
 250:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 253:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25a:	eb 04                	jmp    260 <strlen+0x13>
 25c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 260:	8b 55 fc             	mov    -0x4(%ebp),%edx
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	01 d0                	add    %edx,%eax
 268:	0f b6 00             	movzbl (%eax),%eax
 26b:	84 c0                	test   %al,%al
 26d:	75 ed                	jne    25c <strlen+0xf>
    ;
  return n;
 26f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 272:	c9                   	leave  
 273:	c3                   	ret    

00000274 <memset>:

void*
memset(void *dst, int c, uint n)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 277:	8b 45 10             	mov    0x10(%ebp),%eax
 27a:	50                   	push   %eax
 27b:	ff 75 0c             	push   0xc(%ebp)
 27e:	ff 75 08             	push   0x8(%ebp)
 281:	e8 32 ff ff ff       	call   1b8 <stosb>
 286:	83 c4 0c             	add    $0xc,%esp
  return dst;
 289:	8b 45 08             	mov    0x8(%ebp),%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <strchr>:

char*
strchr(const char *s, char c)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 04             	sub    $0x4,%esp
 294:	8b 45 0c             	mov    0xc(%ebp),%eax
 297:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29a:	eb 14                	jmp    2b0 <strchr+0x22>
    if(*s == c)
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2a5:	75 05                	jne    2ac <strchr+0x1e>
      return (char*)s;
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	eb 13                	jmp    2bf <strchr+0x31>
  for(; *s; s++)
 2ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	0f b6 00             	movzbl (%eax),%eax
 2b6:	84 c0                	test   %al,%al
 2b8:	75 e2                	jne    29c <strchr+0xe>
  return 0;
 2ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <gets>:

char*
gets(char *buf, int max)
{
 2c1:	55                   	push   %ebp
 2c2:	89 e5                	mov    %esp,%ebp
 2c4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ce:	eb 42                	jmp    312 <gets+0x51>
    cc = read(0, &c, 1);
 2d0:	83 ec 04             	sub    $0x4,%esp
 2d3:	6a 01                	push   $0x1
 2d5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2d8:	50                   	push   %eax
 2d9:	6a 00                	push   $0x0
 2db:	e8 47 01 00 00       	call   427 <read>
 2e0:	83 c4 10             	add    $0x10,%esp
 2e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ea:	7e 33                	jle    31f <gets+0x5e>
      break;
    buf[i++] = c;
 2ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ef:	8d 50 01             	lea    0x1(%eax),%edx
 2f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2f5:	89 c2                	mov    %eax,%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	01 c2                	add    %eax,%edx
 2fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 300:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 302:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 306:	3c 0a                	cmp    $0xa,%al
 308:	74 16                	je     320 <gets+0x5f>
 30a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30e:	3c 0d                	cmp    $0xd,%al
 310:	74 0e                	je     320 <gets+0x5f>
  for(i=0; i+1 < max; ){
 312:	8b 45 f4             	mov    -0xc(%ebp),%eax
 315:	83 c0 01             	add    $0x1,%eax
 318:	39 45 0c             	cmp    %eax,0xc(%ebp)
 31b:	7f b3                	jg     2d0 <gets+0xf>
 31d:	eb 01                	jmp    320 <gets+0x5f>
      break;
 31f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 320:	8b 55 f4             	mov    -0xc(%ebp),%edx
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	01 d0                	add    %edx,%eax
 328:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 32e:	c9                   	leave  
 32f:	c3                   	ret    

00000330 <stat>:

int
stat(char *n, struct stat *st)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 336:	83 ec 08             	sub    $0x8,%esp
 339:	6a 00                	push   $0x0
 33b:	ff 75 08             	push   0x8(%ebp)
 33e:	e8 0c 01 00 00       	call   44f <open>
 343:	83 c4 10             	add    $0x10,%esp
 346:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 349:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 34d:	79 07                	jns    356 <stat+0x26>
    return -1;
 34f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 354:	eb 25                	jmp    37b <stat+0x4b>
  r = fstat(fd, st);
 356:	83 ec 08             	sub    $0x8,%esp
 359:	ff 75 0c             	push   0xc(%ebp)
 35c:	ff 75 f4             	push   -0xc(%ebp)
 35f:	e8 03 01 00 00       	call   467 <fstat>
 364:	83 c4 10             	add    $0x10,%esp
 367:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 36a:	83 ec 0c             	sub    $0xc,%esp
 36d:	ff 75 f4             	push   -0xc(%ebp)
 370:	e8 c2 00 00 00       	call   437 <close>
 375:	83 c4 10             	add    $0x10,%esp
  return r;
 378:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    

0000037d <atoi>:

int
atoi(const char *s)
{
 37d:	55                   	push   %ebp
 37e:	89 e5                	mov    %esp,%ebp
 380:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 383:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38a:	eb 25                	jmp    3b1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 38c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 38f:	89 d0                	mov    %edx,%eax
 391:	c1 e0 02             	shl    $0x2,%eax
 394:	01 d0                	add    %edx,%eax
 396:	01 c0                	add    %eax,%eax
 398:	89 c1                	mov    %eax,%ecx
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	8d 50 01             	lea    0x1(%eax),%edx
 3a0:	89 55 08             	mov    %edx,0x8(%ebp)
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	0f be c0             	movsbl %al,%eax
 3a9:	01 c8                	add    %ecx,%eax
 3ab:	83 e8 30             	sub    $0x30,%eax
 3ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	0f b6 00             	movzbl (%eax),%eax
 3b7:	3c 2f                	cmp    $0x2f,%al
 3b9:	7e 0a                	jle    3c5 <atoi+0x48>
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	3c 39                	cmp    $0x39,%al
 3c3:	7e c7                	jle    38c <atoi+0xf>
  return n;
 3c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c8:	c9                   	leave  
 3c9:	c3                   	ret    

000003ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3ca:	55                   	push   %ebp
 3cb:	89 e5                	mov    %esp,%ebp
 3cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3dc:	eb 17                	jmp    3f5 <memmove+0x2b>
    *dst++ = *src++;
 3de:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3e1:	8d 42 01             	lea    0x1(%edx),%eax
 3e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ea:	8d 48 01             	lea    0x1(%eax),%ecx
 3ed:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3f0:	0f b6 12             	movzbl (%edx),%edx
 3f3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3f5:	8b 45 10             	mov    0x10(%ebp),%eax
 3f8:	8d 50 ff             	lea    -0x1(%eax),%edx
 3fb:	89 55 10             	mov    %edx,0x10(%ebp)
 3fe:	85 c0                	test   %eax,%eax
 400:	7f dc                	jg     3de <memmove+0x14>
  return vdst;
 402:	8b 45 08             	mov    0x8(%ebp),%eax
}
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 407:	b8 01 00 00 00       	mov    $0x1,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <exit>:
SYSCALL(exit)
 40f:	b8 02 00 00 00       	mov    $0x2,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <wait>:
SYSCALL(wait)
 417:	b8 03 00 00 00       	mov    $0x3,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <pipe>:
SYSCALL(pipe)
 41f:	b8 04 00 00 00       	mov    $0x4,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <read>:
SYSCALL(read)
 427:	b8 05 00 00 00       	mov    $0x5,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <write>:
SYSCALL(write)
 42f:	b8 10 00 00 00       	mov    $0x10,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <close>:
SYSCALL(close)
 437:	b8 15 00 00 00       	mov    $0x15,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <kill>:
SYSCALL(kill)
 43f:	b8 06 00 00 00       	mov    $0x6,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <exec>:
SYSCALL(exec)
 447:	b8 07 00 00 00       	mov    $0x7,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <open>:
SYSCALL(open)
 44f:	b8 0f 00 00 00       	mov    $0xf,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <mknod>:
SYSCALL(mknod)
 457:	b8 11 00 00 00       	mov    $0x11,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <unlink>:
SYSCALL(unlink)
 45f:	b8 12 00 00 00       	mov    $0x12,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <fstat>:
SYSCALL(fstat)
 467:	b8 08 00 00 00       	mov    $0x8,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <link>:
SYSCALL(link)
 46f:	b8 13 00 00 00       	mov    $0x13,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <mkdir>:
SYSCALL(mkdir)
 477:	b8 14 00 00 00       	mov    $0x14,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <chdir>:
SYSCALL(chdir)
 47f:	b8 09 00 00 00       	mov    $0x9,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <dup>:
SYSCALL(dup)
 487:	b8 0a 00 00 00       	mov    $0xa,%eax
 48c:	cd 40                	int    $0x40
 48e:	c3                   	ret    

0000048f <getpid>:
SYSCALL(getpid)
 48f:	b8 0b 00 00 00       	mov    $0xb,%eax
 494:	cd 40                	int    $0x40
 496:	c3                   	ret    

00000497 <sbrk>:
SYSCALL(sbrk)
 497:	b8 0c 00 00 00       	mov    $0xc,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <sleep>:
SYSCALL(sleep)
 49f:	b8 0d 00 00 00       	mov    $0xd,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <uptime>:
SYSCALL(uptime)
 4a7:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <printpt>:

SYSCALL(printpt)
 4af:	b8 16 00 00 00       	mov    $0x16,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp
 4ba:	83 ec 18             	sub    $0x18,%esp
 4bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4c3:	83 ec 04             	sub    $0x4,%esp
 4c6:	6a 01                	push   $0x1
 4c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4cb:	50                   	push   %eax
 4cc:	ff 75 08             	push   0x8(%ebp)
 4cf:	e8 5b ff ff ff       	call   42f <write>
 4d4:	83 c4 10             	add    $0x10,%esp
}
 4d7:	90                   	nop
 4d8:	c9                   	leave  
 4d9:	c3                   	ret    

000004da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4da:	55                   	push   %ebp
 4db:	89 e5                	mov    %esp,%ebp
 4dd:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4eb:	74 17                	je     504 <printint+0x2a>
 4ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4f1:	79 11                	jns    504 <printint+0x2a>
    neg = 1;
 4f3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fd:	f7 d8                	neg    %eax
 4ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 502:	eb 06                	jmp    50a <printint+0x30>
  } else {
    x = xx;
 504:	8b 45 0c             	mov    0xc(%ebp),%eax
 507:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 50a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 511:	8b 4d 10             	mov    0x10(%ebp),%ecx
 514:	8b 45 ec             	mov    -0x14(%ebp),%eax
 517:	ba 00 00 00 00       	mov    $0x0,%edx
 51c:	f7 f1                	div    %ecx
 51e:	89 d1                	mov    %edx,%ecx
 520:	8b 45 f4             	mov    -0xc(%ebp),%eax
 523:	8d 50 01             	lea    0x1(%eax),%edx
 526:	89 55 f4             	mov    %edx,-0xc(%ebp)
 529:	0f b6 91 20 0c 00 00 	movzbl 0xc20(%ecx),%edx
 530:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 534:	8b 4d 10             	mov    0x10(%ebp),%ecx
 537:	8b 45 ec             	mov    -0x14(%ebp),%eax
 53a:	ba 00 00 00 00       	mov    $0x0,%edx
 53f:	f7 f1                	div    %ecx
 541:	89 45 ec             	mov    %eax,-0x14(%ebp)
 544:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 548:	75 c7                	jne    511 <printint+0x37>
  if(neg)
 54a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 54e:	74 2d                	je     57d <printint+0xa3>
    buf[i++] = '-';
 550:	8b 45 f4             	mov    -0xc(%ebp),%eax
 553:	8d 50 01             	lea    0x1(%eax),%edx
 556:	89 55 f4             	mov    %edx,-0xc(%ebp)
 559:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 55e:	eb 1d                	jmp    57d <printint+0xa3>
    putc(fd, buf[i]);
 560:	8d 55 dc             	lea    -0x24(%ebp),%edx
 563:	8b 45 f4             	mov    -0xc(%ebp),%eax
 566:	01 d0                	add    %edx,%eax
 568:	0f b6 00             	movzbl (%eax),%eax
 56b:	0f be c0             	movsbl %al,%eax
 56e:	83 ec 08             	sub    $0x8,%esp
 571:	50                   	push   %eax
 572:	ff 75 08             	push   0x8(%ebp)
 575:	e8 3d ff ff ff       	call   4b7 <putc>
 57a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 57d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 581:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 585:	79 d9                	jns    560 <printint+0x86>
}
 587:	90                   	nop
 588:	90                   	nop
 589:	c9                   	leave  
 58a:	c3                   	ret    

0000058b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 58b:	55                   	push   %ebp
 58c:	89 e5                	mov    %esp,%ebp
 58e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 591:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 598:	8d 45 0c             	lea    0xc(%ebp),%eax
 59b:	83 c0 04             	add    $0x4,%eax
 59e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5a8:	e9 59 01 00 00       	jmp    706 <printf+0x17b>
    c = fmt[i] & 0xff;
 5ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 5b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b3:	01 d0                	add    %edx,%eax
 5b5:	0f b6 00             	movzbl (%eax),%eax
 5b8:	0f be c0             	movsbl %al,%eax
 5bb:	25 ff 00 00 00       	and    $0xff,%eax
 5c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c7:	75 2c                	jne    5f5 <printf+0x6a>
      if(c == '%'){
 5c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5cd:	75 0c                	jne    5db <printf+0x50>
        state = '%';
 5cf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5d6:	e9 27 01 00 00       	jmp    702 <printf+0x177>
      } else {
        putc(fd, c);
 5db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5de:	0f be c0             	movsbl %al,%eax
 5e1:	83 ec 08             	sub    $0x8,%esp
 5e4:	50                   	push   %eax
 5e5:	ff 75 08             	push   0x8(%ebp)
 5e8:	e8 ca fe ff ff       	call   4b7 <putc>
 5ed:	83 c4 10             	add    $0x10,%esp
 5f0:	e9 0d 01 00 00       	jmp    702 <printf+0x177>
      }
    } else if(state == '%'){
 5f5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5f9:	0f 85 03 01 00 00    	jne    702 <printf+0x177>
      if(c == 'd'){
 5ff:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 603:	75 1e                	jne    623 <printf+0x98>
        printint(fd, *ap, 10, 1);
 605:	8b 45 e8             	mov    -0x18(%ebp),%eax
 608:	8b 00                	mov    (%eax),%eax
 60a:	6a 01                	push   $0x1
 60c:	6a 0a                	push   $0xa
 60e:	50                   	push   %eax
 60f:	ff 75 08             	push   0x8(%ebp)
 612:	e8 c3 fe ff ff       	call   4da <printint>
 617:	83 c4 10             	add    $0x10,%esp
        ap++;
 61a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61e:	e9 d8 00 00 00       	jmp    6fb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 623:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 627:	74 06                	je     62f <printf+0xa4>
 629:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 62d:	75 1e                	jne    64d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 62f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 632:	8b 00                	mov    (%eax),%eax
 634:	6a 00                	push   $0x0
 636:	6a 10                	push   $0x10
 638:	50                   	push   %eax
 639:	ff 75 08             	push   0x8(%ebp)
 63c:	e8 99 fe ff ff       	call   4da <printint>
 641:	83 c4 10             	add    $0x10,%esp
        ap++;
 644:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 648:	e9 ae 00 00 00       	jmp    6fb <printf+0x170>
      } else if(c == 's'){
 64d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 651:	75 43                	jne    696 <printf+0x10b>
        s = (char*)*ap;
 653:	8b 45 e8             	mov    -0x18(%ebp),%eax
 656:	8b 00                	mov    (%eax),%eax
 658:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 65b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 65f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 663:	75 25                	jne    68a <printf+0xff>
          s = "(null)";
 665:	c7 45 f4 97 09 00 00 	movl   $0x997,-0xc(%ebp)
        while(*s != 0){
 66c:	eb 1c                	jmp    68a <printf+0xff>
          putc(fd, *s);
 66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 671:	0f b6 00             	movzbl (%eax),%eax
 674:	0f be c0             	movsbl %al,%eax
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	50                   	push   %eax
 67b:	ff 75 08             	push   0x8(%ebp)
 67e:	e8 34 fe ff ff       	call   4b7 <putc>
 683:	83 c4 10             	add    $0x10,%esp
          s++;
 686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 68a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68d:	0f b6 00             	movzbl (%eax),%eax
 690:	84 c0                	test   %al,%al
 692:	75 da                	jne    66e <printf+0xe3>
 694:	eb 65                	jmp    6fb <printf+0x170>
        }
      } else if(c == 'c'){
 696:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 69a:	75 1d                	jne    6b9 <printf+0x12e>
        putc(fd, *ap);
 69c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	0f be c0             	movsbl %al,%eax
 6a4:	83 ec 08             	sub    $0x8,%esp
 6a7:	50                   	push   %eax
 6a8:	ff 75 08             	push   0x8(%ebp)
 6ab:	e8 07 fe ff ff       	call   4b7 <putc>
 6b0:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b7:	eb 42                	jmp    6fb <printf+0x170>
      } else if(c == '%'){
 6b9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6bd:	75 17                	jne    6d6 <printf+0x14b>
        putc(fd, c);
 6bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c2:	0f be c0             	movsbl %al,%eax
 6c5:	83 ec 08             	sub    $0x8,%esp
 6c8:	50                   	push   %eax
 6c9:	ff 75 08             	push   0x8(%ebp)
 6cc:	e8 e6 fd ff ff       	call   4b7 <putc>
 6d1:	83 c4 10             	add    $0x10,%esp
 6d4:	eb 25                	jmp    6fb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6d6:	83 ec 08             	sub    $0x8,%esp
 6d9:	6a 25                	push   $0x25
 6db:	ff 75 08             	push   0x8(%ebp)
 6de:	e8 d4 fd ff ff       	call   4b7 <putc>
 6e3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e9:	0f be c0             	movsbl %al,%eax
 6ec:	83 ec 08             	sub    $0x8,%esp
 6ef:	50                   	push   %eax
 6f0:	ff 75 08             	push   0x8(%ebp)
 6f3:	e8 bf fd ff ff       	call   4b7 <putc>
 6f8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 702:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 706:	8b 55 0c             	mov    0xc(%ebp),%edx
 709:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70c:	01 d0                	add    %edx,%eax
 70e:	0f b6 00             	movzbl (%eax),%eax
 711:	84 c0                	test   %al,%al
 713:	0f 85 94 fe ff ff    	jne    5ad <printf+0x22>
    }
  }
}
 719:	90                   	nop
 71a:	90                   	nop
 71b:	c9                   	leave  
 71c:	c3                   	ret    

0000071d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 71d:	55                   	push   %ebp
 71e:	89 e5                	mov    %esp,%ebp
 720:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 723:	8b 45 08             	mov    0x8(%ebp),%eax
 726:	83 e8 08             	sub    $0x8,%eax
 729:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	a1 4c 2c 00 00       	mov    0x2c4c,%eax
 731:	89 45 fc             	mov    %eax,-0x4(%ebp)
 734:	eb 24                	jmp    75a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 73e:	72 12                	jb     752 <free+0x35>
 740:	8b 45 f8             	mov    -0x8(%ebp),%eax
 743:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 746:	77 24                	ja     76c <free+0x4f>
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 750:	72 1a                	jb     76c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 752:	8b 45 fc             	mov    -0x4(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	89 45 fc             	mov    %eax,-0x4(%ebp)
 75a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 760:	76 d4                	jbe    736 <free+0x19>
 762:	8b 45 fc             	mov    -0x4(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 76a:	73 ca                	jae    736 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 76c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 779:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77c:	01 c2                	add    %eax,%edx
 77e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 781:	8b 00                	mov    (%eax),%eax
 783:	39 c2                	cmp    %eax,%edx
 785:	75 24                	jne    7ab <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	8b 50 04             	mov    0x4(%eax),%edx
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	01 c2                	add    %eax,%edx
 797:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	8b 10                	mov    (%eax),%edx
 7a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a7:	89 10                	mov    %edx,(%eax)
 7a9:	eb 0a                	jmp    7b5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ae:	8b 10                	mov    (%eax),%edx
 7b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c5:	01 d0                	add    %edx,%eax
 7c7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7ca:	75 20                	jne    7ec <free+0xcf>
    p->s.size += bp->s.size;
 7cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cf:	8b 50 04             	mov    0x4(%eax),%edx
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	8b 40 04             	mov    0x4(%eax),%eax
 7d8:	01 c2                	add    %eax,%edx
 7da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	8b 10                	mov    (%eax),%edx
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	89 10                	mov    %edx,(%eax)
 7ea:	eb 08                	jmp    7f4 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ef:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7f2:	89 10                	mov    %edx,(%eax)
  freep = p;
 7f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f7:	a3 4c 2c 00 00       	mov    %eax,0x2c4c
}
 7fc:	90                   	nop
 7fd:	c9                   	leave  
 7fe:	c3                   	ret    

000007ff <morecore>:

static Header*
morecore(uint nu)
{
 7ff:	55                   	push   %ebp
 800:	89 e5                	mov    %esp,%ebp
 802:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 805:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 80c:	77 07                	ja     815 <morecore+0x16>
    nu = 4096;
 80e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	c1 e0 03             	shl    $0x3,%eax
 81b:	83 ec 0c             	sub    $0xc,%esp
 81e:	50                   	push   %eax
 81f:	e8 73 fc ff ff       	call   497 <sbrk>
 824:	83 c4 10             	add    $0x10,%esp
 827:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 82a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 82e:	75 07                	jne    837 <morecore+0x38>
    return 0;
 830:	b8 00 00 00 00       	mov    $0x0,%eax
 835:	eb 26                	jmp    85d <morecore+0x5e>
  hp = (Header*)p;
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 83d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 840:	8b 55 08             	mov    0x8(%ebp),%edx
 843:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 846:	8b 45 f0             	mov    -0x10(%ebp),%eax
 849:	83 c0 08             	add    $0x8,%eax
 84c:	83 ec 0c             	sub    $0xc,%esp
 84f:	50                   	push   %eax
 850:	e8 c8 fe ff ff       	call   71d <free>
 855:	83 c4 10             	add    $0x10,%esp
  return freep;
 858:	a1 4c 2c 00 00       	mov    0x2c4c,%eax
}
 85d:	c9                   	leave  
 85e:	c3                   	ret    

0000085f <malloc>:

void*
malloc(uint nbytes)
{
 85f:	55                   	push   %ebp
 860:	89 e5                	mov    %esp,%ebp
 862:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 865:	8b 45 08             	mov    0x8(%ebp),%eax
 868:	83 c0 07             	add    $0x7,%eax
 86b:	c1 e8 03             	shr    $0x3,%eax
 86e:	83 c0 01             	add    $0x1,%eax
 871:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 874:	a1 4c 2c 00 00       	mov    0x2c4c,%eax
 879:	89 45 f0             	mov    %eax,-0x10(%ebp)
 87c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 880:	75 23                	jne    8a5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 882:	c7 45 f0 44 2c 00 00 	movl   $0x2c44,-0x10(%ebp)
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	a3 4c 2c 00 00       	mov    %eax,0x2c4c
 891:	a1 4c 2c 00 00       	mov    0x2c4c,%eax
 896:	a3 44 2c 00 00       	mov    %eax,0x2c44
    base.s.size = 0;
 89b:	c7 05 48 2c 00 00 00 	movl   $0x0,0x2c48
 8a2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b0:	8b 40 04             	mov    0x4(%eax),%eax
 8b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8b6:	77 4d                	ja     905 <malloc+0xa6>
      if(p->s.size == nunits)
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	8b 40 04             	mov    0x4(%eax),%eax
 8be:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8c1:	75 0c                	jne    8cf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c6:	8b 10                	mov    (%eax),%edx
 8c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cb:	89 10                	mov    %edx,(%eax)
 8cd:	eb 26                	jmp    8f5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	8b 40 04             	mov    0x4(%eax),%eax
 8d5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8d8:	89 c2                	mov    %eax,%edx
 8da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e3:	8b 40 04             	mov    0x4(%eax),%eax
 8e6:	c1 e0 03             	shl    $0x3,%eax
 8e9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8f2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f8:	a3 4c 2c 00 00       	mov    %eax,0x2c4c
      return (void*)(p + 1);
 8fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 900:	83 c0 08             	add    $0x8,%eax
 903:	eb 3b                	jmp    940 <malloc+0xe1>
    }
    if(p == freep)
 905:	a1 4c 2c 00 00       	mov    0x2c4c,%eax
 90a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 90d:	75 1e                	jne    92d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 90f:	83 ec 0c             	sub    $0xc,%esp
 912:	ff 75 ec             	push   -0x14(%ebp)
 915:	e8 e5 fe ff ff       	call   7ff <morecore>
 91a:	83 c4 10             	add    $0x10,%esp
 91d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 920:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 924:	75 07                	jne    92d <malloc+0xce>
        return 0;
 926:	b8 00 00 00 00       	mov    $0x0,%eax
 92b:	eb 13                	jmp    940 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 930:	89 45 f0             	mov    %eax,-0x10(%ebp)
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 00                	mov    (%eax),%eax
 938:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93b:	e9 6d ff ff ff       	jmp    8ad <malloc+0x4e>
  }
}
 940:	c9                   	leave  
 941:	c3                   	ret    
