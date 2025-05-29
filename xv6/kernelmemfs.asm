
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 7f 19 80       	mov    $0x80197f80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 73 33 10 80       	mov    $0x80103373,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 60 a1 10 80       	push   $0x8010a160
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 79 47 00 00       	call   801047f7 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 67 a1 10 80       	push   $0x8010a167
801000c2:	50                   	push   %eax
801000c3:	e8 d2 45 00 00       	call   8010469a <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 13 47 00 00       	call   80104819 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 42 47 00 00       	call   80104887 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 7f 45 00 00       	call   801046d6 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 c1 46 00 00       	call   80104887 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 fe 44 00 00       	call   801046d6 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 6e a1 10 80       	push   $0x8010a16e
801001fa:	e8 c2 03 00 00       	call   801005c1 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 21 9e 00 00       	call   8010a053 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 39 45 00 00       	call   80104788 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 7f a1 10 80       	push   $0x8010a17f
8010025e:	e8 5e 03 00 00       	call   801005c1 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 d6 9d 00 00       	call   8010a053 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 f0 44 00 00       	call   80104788 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 86 a1 10 80       	push   $0x8010a186
801002a7:	e8 15 03 00 00       	call   801005c1 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 7f 44 00 00       	call   8010473a <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 4e 45 00 00       	call   80104819 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 4c 45 00 00       	call   80104887 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 a4 03 00 00       	call   80100787 <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 04 44 00 00       	call   80104819 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 90 a1 10 80       	push   $0x8010a190
80100427:	e8 95 01 00 00       	call   801005c1 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 47 01 00 00       	jmp    80100585 <cprintf+0x191>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 38 03 00 00       	call   80100787 <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 2a 01 00 00       	jmp    80100581 <cprintf+0x18d>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 2c 01 00 00    	je     801005a7 <cprintf+0x1b3>
      break;
    switch(c){
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 d1 00 00 00    	je     80100556 <cprintf+0x162>
80100485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100489:	0f 8c d6 00 00 00    	jl     80100565 <cprintf+0x171>
8010048f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100493:	0f 8f cc 00 00 00    	jg     80100565 <cprintf+0x171>
80100499:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
8010049d:	0f 8c c2 00 00 00    	jl     80100565 <cprintf+0x171>
801004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004a6:	83 e8 63             	sub    $0x63,%eax
801004a9:	83 f8 15             	cmp    $0x15,%eax
801004ac:	0f 87 b3 00 00 00    	ja     80100565 <cprintf+0x171>
801004b2:	8b 04 85 a0 a1 10 80 	mov    -0x7fef5e60(,%eax,4),%eax
801004b9:	ff e0                	jmp    *%eax
    //추가
    case 'c':
      consputc(*argp++); //
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	83 ec 0c             	sub    $0xc,%esp
801004c9:	50                   	push   %eax
801004ca:	e8 b8 02 00 00       	call   80100787 <consputc>
801004cf:	83 c4 10             	add    $0x10,%esp
      break;
801004d2:	e9 aa 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 'd':
      printint(*argp++, 10, 1);
801004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004da:	8d 50 04             	lea    0x4(%eax),%edx
801004dd:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e0:	8b 00                	mov    (%eax),%eax
801004e2:	83 ec 04             	sub    $0x4,%esp
801004e5:	6a 01                	push   $0x1
801004e7:	6a 0a                	push   $0xa
801004e9:	50                   	push   %eax
801004ea:	e8 59 fe ff ff       	call   80100348 <printint>
801004ef:	83 c4 10             	add    $0x10,%esp
      break;
801004f2:	e9 8a 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fa:	8d 50 04             	lea    0x4(%eax),%edx
801004fd:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100500:	8b 00                	mov    (%eax),%eax
80100502:	83 ec 04             	sub    $0x4,%esp
80100505:	6a 00                	push   $0x0
80100507:	6a 10                	push   $0x10
80100509:	50                   	push   %eax
8010050a:	e8 39 fe ff ff       	call   80100348 <printint>
8010050f:	83 c4 10             	add    $0x10,%esp
      break;
80100512:	eb 6d                	jmp    80100581 <cprintf+0x18d>
    case 's':
      if((s = (char*)*argp++) == 0)
80100514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100517:	8d 50 04             	lea    0x4(%eax),%edx
8010051a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010051d:	8b 00                	mov    (%eax),%eax
8010051f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100522:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100526:	75 22                	jne    8010054a <cprintf+0x156>
        s = "(null)";
80100528:	c7 45 ec 99 a1 10 80 	movl   $0x8010a199,-0x14(%ebp)
      for(; *s; s++)
8010052f:	eb 19                	jmp    8010054a <cprintf+0x156>
        consputc(*s);
80100531:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100534:	0f b6 00             	movzbl (%eax),%eax
80100537:	0f be c0             	movsbl %al,%eax
8010053a:	83 ec 0c             	sub    $0xc,%esp
8010053d:	50                   	push   %eax
8010053e:	e8 44 02 00 00       	call   80100787 <consputc>
80100543:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
80100546:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010054d:	0f b6 00             	movzbl (%eax),%eax
80100550:	84 c0                	test   %al,%al
80100552:	75 dd                	jne    80100531 <cprintf+0x13d>
      break;
80100554:	eb 2b                	jmp    80100581 <cprintf+0x18d>
    case '%':
      consputc('%');
80100556:	83 ec 0c             	sub    $0xc,%esp
80100559:	6a 25                	push   $0x25
8010055b:	e8 27 02 00 00       	call   80100787 <consputc>
80100560:	83 c4 10             	add    $0x10,%esp
      break;
80100563:	eb 1c                	jmp    80100581 <cprintf+0x18d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100565:	83 ec 0c             	sub    $0xc,%esp
80100568:	6a 25                	push   $0x25
8010056a:	e8 18 02 00 00       	call   80100787 <consputc>
8010056f:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100572:	83 ec 0c             	sub    $0xc,%esp
80100575:	ff 75 e4             	push   -0x1c(%ebp)
80100578:	e8 0a 02 00 00       	call   80100787 <consputc>
8010057d:	83 c4 10             	add    $0x10,%esp
      break;
80100580:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100581:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100585:	8b 55 08             	mov    0x8(%ebp),%edx
80100588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058b:	01 d0                	add    %edx,%eax
8010058d:	0f b6 00             	movzbl (%eax),%eax
80100590:	0f be c0             	movsbl %al,%eax
80100593:	25 ff 00 00 00       	and    $0xff,%eax
80100598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010059f:	0f 85 99 fe ff ff    	jne    8010043e <cprintf+0x4a>
801005a5:	eb 01                	jmp    801005a8 <cprintf+0x1b4>
      break;
801005a7:	90                   	nop
    }
  }

  if(locking)
801005a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005ac:	74 10                	je     801005be <cprintf+0x1ca>
    release(&cons.lock);
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	68 00 1a 19 80       	push   $0x80191a00
801005b6:	e8 cc 42 00 00       	call   80104887 <release>
801005bb:	83 c4 10             	add    $0x10,%esp
}
801005be:	90                   	nop
801005bf:	c9                   	leave  
801005c0:	c3                   	ret    

801005c1 <panic>:

void
panic(char *s)
{
801005c1:	55                   	push   %ebp
801005c2:	89 e5                	mov    %esp,%ebp
801005c4:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005c7:	e8 75 fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005cc:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005d3:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005d6:	e8 2d 25 00 00       	call   80102b08 <lapicid>
801005db:	83 ec 08             	sub    $0x8,%esp
801005de:	50                   	push   %eax
801005df:	68 f8 a1 10 80       	push   $0x8010a1f8
801005e4:	e8 0b fe ff ff       	call   801003f4 <cprintf>
801005e9:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ec:	8b 45 08             	mov    0x8(%ebp),%eax
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	50                   	push   %eax
801005f3:	e8 fc fd ff ff       	call   801003f4 <cprintf>
801005f8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005fb:	83 ec 0c             	sub    $0xc,%esp
801005fe:	68 0c a2 10 80       	push   $0x8010a20c
80100603:	e8 ec fd ff ff       	call   801003f4 <cprintf>
80100608:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010060b:	83 ec 08             	sub    $0x8,%esp
8010060e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100611:	50                   	push   %eax
80100612:	8d 45 08             	lea    0x8(%ebp),%eax
80100615:	50                   	push   %eax
80100616:	e8 be 42 00 00       	call   801048d9 <getcallerpcs>
8010061b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010061e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100625:	eb 1c                	jmp    80100643 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010062a:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010062e:	83 ec 08             	sub    $0x8,%esp
80100631:	50                   	push   %eax
80100632:	68 0e a2 10 80       	push   $0x8010a20e
80100637:	e8 b8 fd ff ff       	call   801003f4 <cprintf>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100643:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100647:	7e de                	jle    80100627 <panic+0x66>
  panicked = 1; // freeze other CPU
80100649:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100650:	00 00 00 
  for(;;)
80100653:	eb fe                	jmp    80100653 <panic+0x92>

80100655 <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
80100655:	55                   	push   %ebp
80100656:	89 e5                	mov    %esp,%ebp
80100658:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
8010065b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010065f:	75 64                	jne    801006c5 <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100661:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100667:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010066c:	89 c8                	mov    %ecx,%eax
8010066e:	f7 ea                	imul   %edx
80100670:	89 d0                	mov    %edx,%eax
80100672:	c1 f8 04             	sar    $0x4,%eax
80100675:	89 ca                	mov    %ecx,%edx
80100677:	c1 fa 1f             	sar    $0x1f,%edx
8010067a:	29 d0                	sub    %edx,%eax
8010067c:	6b d0 35             	imul   $0x35,%eax,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	29 d0                	sub    %edx,%eax
80100683:	ba 35 00 00 00       	mov    $0x35,%edx
80100688:	29 c2                	sub    %eax,%edx
8010068a:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010068f:	01 d0                	add    %edx,%eax
80100691:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	3d 23 04 00 00       	cmp    $0x423,%eax
801006a0:	0f 8e de 00 00 00    	jle    80100784 <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006a6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ab:	83 e8 35             	sub    $0x35,%eax
801006ae:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006b3:	83 ec 0c             	sub    $0xc,%esp
801006b6:	6a 1e                	push   $0x1e
801006b8:	e8 ed 78 00 00       	call   80107faa <graphic_scroll_up>
801006bd:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006c0:	e9 bf 00 00 00       	jmp    80100784 <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006c5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006cc:	75 1f                	jne    801006ed <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006ce:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006d3:	85 c0                	test   %eax,%eax
801006d5:	0f 8e a9 00 00 00    	jle    80100784 <graphic_putc+0x12f>
801006db:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e0:	83 e8 01             	sub    $0x1,%eax
801006e3:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006e8:	e9 97 00 00 00       	jmp    80100784 <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006ed:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006f2:	3d 23 04 00 00       	cmp    $0x423,%eax
801006f7:	7e 1a                	jle    80100713 <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	83 e8 35             	sub    $0x35,%eax
80100701:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100706:	83 ec 0c             	sub    $0xc,%esp
80100709:	6a 1e                	push   $0x1e
8010070b:	e8 9a 78 00 00       	call   80107faa <graphic_scroll_up>
80100710:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
80100713:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100719:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010071e:	89 c8                	mov    %ecx,%eax
80100720:	f7 ea                	imul   %edx
80100722:	89 d0                	mov    %edx,%eax
80100724:	c1 f8 04             	sar    $0x4,%eax
80100727:	89 ca                	mov    %ecx,%edx
80100729:	c1 fa 1f             	sar    $0x1f,%edx
8010072c:	29 d0                	sub    %edx,%eax
8010072e:	6b d0 35             	imul   $0x35,%eax,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	29 d0                	sub    %edx,%eax
80100735:	89 c2                	mov    %eax,%edx
80100737:	c1 e2 04             	shl    $0x4,%edx
8010073a:	29 c2                	sub    %eax,%edx
8010073c:	8d 42 02             	lea    0x2(%edx),%eax
8010073f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100742:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100748:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010074d:	89 c8                	mov    %ecx,%eax
8010074f:	f7 ea                	imul   %edx
80100751:	89 d0                	mov    %edx,%eax
80100753:	c1 f8 04             	sar    $0x4,%eax
80100756:	c1 f9 1f             	sar    $0x1f,%ecx
80100759:	89 ca                	mov    %ecx,%edx
8010075b:	29 d0                	sub    %edx,%eax
8010075d:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100760:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100763:	83 ec 04             	sub    $0x4,%esp
80100766:	ff 75 08             	push   0x8(%ebp)
80100769:	ff 75 f0             	push   -0x10(%ebp)
8010076c:	ff 75 f4             	push   -0xc(%ebp)
8010076f:	e8 a1 78 00 00       	call   80108015 <font_render>
80100774:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100777:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010077c:	83 c0 01             	add    $0x1,%eax
8010077f:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100784:	90                   	nop
80100785:	c9                   	leave  
80100786:	c3                   	ret    

80100787 <consputc>:


void
consputc(int c)
{
80100787:	55                   	push   %ebp
80100788:	89 e5                	mov    %esp,%ebp
8010078a:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010078d:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100792:	85 c0                	test   %eax,%eax
80100794:	74 07                	je     8010079d <consputc+0x16>
    cli();
80100796:	e8 a6 fb ff ff       	call   80100341 <cli>
    for(;;)
8010079b:	eb fe                	jmp    8010079b <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
8010079d:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a4:	75 29                	jne    801007cf <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007a6:	83 ec 0c             	sub    $0xc,%esp
801007a9:	6a 08                	push   $0x8
801007ab:	e8 86 5c 00 00       	call   80106436 <uartputc>
801007b0:	83 c4 10             	add    $0x10,%esp
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	6a 20                	push   $0x20
801007b8:	e8 79 5c 00 00       	call   80106436 <uartputc>
801007bd:	83 c4 10             	add    $0x10,%esp
801007c0:	83 ec 0c             	sub    $0xc,%esp
801007c3:	6a 08                	push   $0x8
801007c5:	e8 6c 5c 00 00       	call   80106436 <uartputc>
801007ca:	83 c4 10             	add    $0x10,%esp
801007cd:	eb 0e                	jmp    801007dd <consputc+0x56>
  } else {
    uartputc(c);
801007cf:	83 ec 0c             	sub    $0xc,%esp
801007d2:	ff 75 08             	push   0x8(%ebp)
801007d5:	e8 5c 5c 00 00       	call   80106436 <uartputc>
801007da:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	ff 75 08             	push   0x8(%ebp)
801007e3:	e8 6d fe ff ff       	call   80100655 <graphic_putc>
801007e8:	83 c4 10             	add    $0x10,%esp
}
801007eb:	90                   	nop
801007ec:	c9                   	leave  
801007ed:	c3                   	ret    

801007ee <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ee:	55                   	push   %ebp
801007ef:	89 e5                	mov    %esp,%ebp
801007f1:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007fb:	83 ec 0c             	sub    $0xc,%esp
801007fe:	68 00 1a 19 80       	push   $0x80191a00
80100803:	e8 11 40 00 00       	call   80104819 <acquire>
80100808:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010080b:	e9 50 01 00 00       	jmp    80100960 <consoleintr+0x172>
    switch(c){
80100810:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100814:	0f 84 81 00 00 00    	je     8010089b <consoleintr+0xad>
8010081a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010081e:	0f 8f ac 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100824:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100828:	74 43                	je     8010086d <consoleintr+0x7f>
8010082a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010082e:	0f 8f 9c 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100834:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100838:	74 61                	je     8010089b <consoleintr+0xad>
8010083a:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010083e:	0f 85 8c 00 00 00    	jne    801008d0 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100844:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010084b:	e9 10 01 00 00       	jmp    80100960 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100850:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100855:	83 e8 01             	sub    $0x1,%eax
80100858:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
8010085d:	83 ec 0c             	sub    $0xc,%esp
80100860:	68 00 01 00 00       	push   $0x100
80100865:	e8 1d ff ff ff       	call   80100787 <consputc>
8010086a:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010086d:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100873:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100878:	39 c2                	cmp    %eax,%edx
8010087a:	0f 84 e0 00 00 00    	je     80100960 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100880:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	83 e0 7f             	and    $0x7f,%eax
8010088b:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
80100892:	3c 0a                	cmp    $0xa,%al
80100894:	75 ba                	jne    80100850 <consoleintr+0x62>
      }
      break;
80100896:	e9 c5 00 00 00       	jmp    80100960 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010089b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008a1:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 b2 00 00 00    	je     80100960 <consoleintr+0x172>
        input.e--;
801008ae:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008bb:	83 ec 0c             	sub    $0xc,%esp
801008be:	68 00 01 00 00       	push   $0x100
801008c3:	e8 bf fe ff ff       	call   80100787 <consputc>
801008c8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008cb:	e9 90 00 00 00       	jmp    80100960 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d4:	0f 84 85 00 00 00    	je     8010095f <consoleintr+0x171>
801008da:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008df:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008e5:	29 d0                	sub    %edx,%eax
801008e7:	83 f8 7f             	cmp    $0x7f,%eax
801008ea:	77 73                	ja     8010095f <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008ec:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008f0:	74 05                	je     801008f7 <consoleintr+0x109>
801008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f5:	eb 05                	jmp    801008fc <consoleintr+0x10e>
801008f7:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ff:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100904:	8d 50 01             	lea    0x1(%eax),%edx
80100907:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
8010090d:	83 e0 7f             	and    $0x7f,%eax
80100910:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100913:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	ff 75 f0             	push   -0x10(%ebp)
8010091f:	e8 63 fe ff ff       	call   80100787 <consputc>
80100924:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100927:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092b:	74 18                	je     80100945 <consoleintr+0x157>
8010092d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100931:	74 12                	je     80100945 <consoleintr+0x157>
80100933:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100938:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
8010093e:	83 ea 80             	sub    $0xffffff80,%edx
80100941:	39 d0                	cmp    %edx,%eax
80100943:	75 1a                	jne    8010095f <consoleintr+0x171>
          input.w = input.e;
80100945:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010094a:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e0 19 19 80       	push   $0x801919e0
80100957:	e8 72 3a 00 00       	call   801043ce <wakeup>
8010095c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095f:	90                   	nop
  while((c = getc()) >= 0){
80100960:	8b 45 08             	mov    0x8(%ebp),%eax
80100963:	ff d0                	call   *%eax
80100965:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100968:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096c:	0f 89 9e fe ff ff    	jns    80100810 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100972:	83 ec 0c             	sub    $0xc,%esp
80100975:	68 00 1a 19 80       	push   $0x80191a00
8010097a:	e8 08 3f 00 00       	call   80104887 <release>
8010097f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100982:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100986:	74 05                	je     8010098d <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100988:	e8 fc 3a 00 00       	call   80104489 <procdump>
  }
}
8010098d:	90                   	nop
8010098e:	c9                   	leave  
8010098f:	c3                   	ret    

80100990 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100990:	55                   	push   %ebp
80100991:	89 e5                	mov    %esp,%ebp
80100993:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100996:	83 ec 0c             	sub    $0xc,%esp
80100999:	ff 75 08             	push   0x8(%ebp)
8010099c:	e8 6a 11 00 00       	call   80101b0b <iunlock>
801009a1:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a4:	8b 45 10             	mov    0x10(%ebp),%eax
801009a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009aa:	83 ec 0c             	sub    $0xc,%esp
801009ad:	68 00 1a 19 80       	push   $0x80191a00
801009b2:	e8 62 3e 00 00       	call   80104819 <acquire>
801009b7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ba:	e9 ab 00 00 00       	jmp    80100a6a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009bf:	e8 7a 30 00 00       	call   80103a3e <myproc>
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x63>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 00 1a 19 80       	push   $0x80191a00
801009d3:	e8 af 3e 00 00       	call   80104887 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	push   0x8(%ebp)
801009e1:	e8 12 10 00 00       	call   801019f8 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 a9 00 00 00       	jmp    80100a9c <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 00 1a 19 80       	push   $0x80191a00
801009fb:	68 e0 19 19 80       	push   $0x801919e0
80100a00:	e8 e2 38 00 00       	call   801042e7 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a08:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100a0e:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a8                	je     801009bf <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc2>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a41:	76 2f                	jbe    80100a72 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe2>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe5>
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x78>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe6>
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe6>
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 00 1a 19 80       	push   $0x80191a00
80100a7e:	e8 04 3e 00 00       	call   80104887 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	push   0x8(%ebp)
80100a8c:	e8 67 0f 00 00       	call   801019f8 <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 55 10             	mov    0x10(%ebp),%edx
80100a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a9a:	29 d0                	sub    %edx,%eax
}
80100a9c:	c9                   	leave  
80100a9d:	c3                   	ret    

80100a9e <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a9e:	55                   	push   %ebp
80100a9f:	89 e5                	mov    %esp,%ebp
80100aa1:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	ff 75 08             	push   0x8(%ebp)
80100aaa:	e8 5c 10 00 00       	call   80101b0b <iunlock>
80100aaf:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab2:	83 ec 0c             	sub    $0xc,%esp
80100ab5:	68 00 1a 19 80       	push   $0x80191a00
80100aba:	e8 5a 3d 00 00       	call   80104819 <acquire>
80100abf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ac9:	eb 21                	jmp    80100aec <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ace:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad1:	01 d0                	add    %edx,%eax
80100ad3:	0f b6 00             	movzbl (%eax),%eax
80100ad6:	0f be c0             	movsbl %al,%eax
80100ad9:	0f b6 c0             	movzbl %al,%eax
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	50                   	push   %eax
80100ae0:	e8 a2 fc ff ff       	call   80100787 <consputc>
80100ae5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100aef:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af2:	7c d7                	jl     80100acb <consolewrite+0x2d>
  release(&cons.lock);
80100af4:	83 ec 0c             	sub    $0xc,%esp
80100af7:	68 00 1a 19 80       	push   $0x80191a00
80100afc:	e8 86 3d 00 00       	call   80104887 <release>
80100b01:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b04:	83 ec 0c             	sub    $0xc,%esp
80100b07:	ff 75 08             	push   0x8(%ebp)
80100b0a:	e8 e9 0e 00 00       	call   801019f8 <ilock>
80100b0f:	83 c4 10             	add    $0x10,%esp

  return n;
80100b12:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b15:	c9                   	leave  
80100b16:	c3                   	ret    

80100b17 <consoleinit>:

void
consoleinit(void)
{
80100b17:	55                   	push   %ebp
80100b18:	89 e5                	mov    %esp,%ebp
80100b1a:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b1d:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b24:	00 00 00 
  initlock(&cons.lock, "console");
80100b27:	83 ec 08             	sub    $0x8,%esp
80100b2a:	68 12 a2 10 80       	push   $0x8010a212
80100b2f:	68 00 1a 19 80       	push   $0x80191a00
80100b34:	e8 be 3c 00 00       	call   801047f7 <initlock>
80100b39:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b3c:	c7 05 4c 1a 19 80 9e 	movl   $0x80100a9e,0x80191a4c
80100b43:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b46:	c7 05 48 1a 19 80 90 	movl   $0x80100990,0x80191a48
80100b4d:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b50:	c7 45 f4 1a a2 10 80 	movl   $0x8010a21a,-0xc(%ebp)
80100b57:	eb 19                	jmp    80100b72 <consoleinit+0x5b>
    graphic_putc(*p);
80100b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5c:	0f b6 00             	movzbl (%eax),%eax
80100b5f:	0f be c0             	movsbl %al,%eax
80100b62:	83 ec 0c             	sub    $0xc,%esp
80100b65:	50                   	push   %eax
80100b66:	e8 ea fa ff ff       	call   80100655 <graphic_putc>
80100b6b:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b75:	0f b6 00             	movzbl (%eax),%eax
80100b78:	84 c0                	test   %al,%al
80100b7a:	75 dd                	jne    80100b59 <consoleinit+0x42>
  
  cons.locking = 1;
80100b7c:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b83:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b86:	83 ec 08             	sub    $0x8,%esp
80100b89:	6a 00                	push   $0x0
80100b8b:	6a 01                	push   $0x1
80100b8d:	e8 aa 1a 00 00       	call   8010263c <ioapicenable>
80100b92:	83 c4 10             	add    $0x10,%esp
}
80100b95:	90                   	nop
80100b96:	c9                   	leave  
80100b97:	c3                   	ret    

80100b98 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b98:	55                   	push   %ebp
80100b99:	89 e5                	mov    %esp,%ebp
80100b9b:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100ba1:	e8 98 2e 00 00       	call   80103a3e <myproc>
80100ba6:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba9:	e8 9c 24 00 00       	call   8010304a <begin_op>

  if((ip = namei(path)) == 0){
80100bae:	83 ec 0c             	sub    $0xc,%esp
80100bb1:	ff 75 08             	push   0x8(%ebp)
80100bb4:	e8 72 19 00 00       	call   8010252b <namei>
80100bb9:	83 c4 10             	add    $0x10,%esp
80100bbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc3:	75 1f                	jne    80100be4 <exec+0x4c>
    end_op();
80100bc5:	e8 0c 25 00 00       	call   801030d6 <end_op>
    cprintf("exec: fail\n");
80100bca:	83 ec 0c             	sub    $0xc,%esp
80100bcd:	68 30 a2 10 80       	push   $0x8010a230
80100bd2:	e8 1d f8 ff ff       	call   801003f4 <cprintf>
80100bd7:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdf:	e9 e7 03 00 00       	jmp    80100fcb <exec+0x433>
  }
  ilock(ip);
80100be4:	83 ec 0c             	sub    $0xc,%esp
80100be7:	ff 75 d8             	push   -0x28(%ebp)
80100bea:	e8 09 0e 00 00       	call   801019f8 <ilock>
80100bef:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bf2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bf9:	6a 34                	push   $0x34
80100bfb:	6a 00                	push   $0x0
80100bfd:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c03:	50                   	push   %eax
80100c04:	ff 75 d8             	push   -0x28(%ebp)
80100c07:	e8 d8 12 00 00       	call   80101ee4 <readi>
80100c0c:	83 c4 10             	add    $0x10,%esp
80100c0f:	83 f8 34             	cmp    $0x34,%eax
80100c12:	0f 85 5f 03 00 00    	jne    80100f77 <exec+0x3df>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c18:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c23:	0f 85 51 03 00 00    	jne    80100f7a <exec+0x3e2>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c29:	e8 04 68 00 00       	call   80107432 <setupkvm>
80100c2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c31:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c35:	0f 84 42 03 00 00    	je     80100f7d <exec+0x3e5>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c3b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c42:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c49:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c52:	e9 de 00 00 00       	jmp    80100d35 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c5a:	6a 20                	push   $0x20
80100c5c:	50                   	push   %eax
80100c5d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c63:	50                   	push   %eax
80100c64:	ff 75 d8             	push   -0x28(%ebp)
80100c67:	e8 78 12 00 00       	call   80101ee4 <readi>
80100c6c:	83 c4 10             	add    $0x10,%esp
80100c6f:	83 f8 20             	cmp    $0x20,%eax
80100c72:	0f 85 08 03 00 00    	jne    80100f80 <exec+0x3e8>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c78:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c7e:	83 f8 01             	cmp    $0x1,%eax
80100c81:	0f 85 a0 00 00 00    	jne    80100d27 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c87:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c93:	39 c2                	cmp    %eax,%edx
80100c95:	0f 82 e8 02 00 00    	jb     80100f83 <exec+0x3eb>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c9b:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca7:	01 c2                	add    %eax,%edx
80100ca9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100caf:	39 c2                	cmp    %eax,%edx
80100cb1:	0f 82 cf 02 00 00    	jb     80100f86 <exec+0x3ee>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb7:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc3:	01 d0                	add    %edx,%eax
80100cc5:	83 ec 04             	sub    $0x4,%esp
80100cc8:	50                   	push   %eax
80100cc9:	ff 75 e0             	push   -0x20(%ebp)
80100ccc:	ff 75 d4             	push   -0x2c(%ebp)
80100ccf:	e8 57 6b 00 00       	call   8010782b <allocuvm>
80100cd4:	83 c4 10             	add    $0x10,%esp
80100cd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cde:	0f 84 a5 02 00 00    	je     80100f89 <exec+0x3f1>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cea:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cef:	85 c0                	test   %eax,%eax
80100cf1:	0f 85 95 02 00 00    	jne    80100f8c <exec+0x3f4>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cf7:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cfd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d03:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d09:	83 ec 0c             	sub    $0xc,%esp
80100d0c:	52                   	push   %edx
80100d0d:	50                   	push   %eax
80100d0e:	ff 75 d8             	push   -0x28(%ebp)
80100d11:	51                   	push   %ecx
80100d12:	ff 75 d4             	push   -0x2c(%ebp)
80100d15:	e8 44 6a 00 00       	call   8010775e <loaduvm>
80100d1a:	83 c4 20             	add    $0x20,%esp
80100d1d:	85 c0                	test   %eax,%eax
80100d1f:	0f 88 6a 02 00 00    	js     80100f8f <exec+0x3f7>
80100d25:	eb 01                	jmp    80100d28 <exec+0x190>
      continue;
80100d27:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d28:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d2f:	83 c0 20             	add    $0x20,%eax
80100d32:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d35:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d3c:	0f b7 c0             	movzwl %ax,%eax
80100d3f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d42:	0f 8c 0f ff ff ff    	jl     80100c57 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d48:	83 ec 0c             	sub    $0xc,%esp
80100d4b:	ff 75 d8             	push   -0x28(%ebp)
80100d4e:	e8 d6 0e 00 00       	call   80101c29 <iunlockput>
80100d53:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d56:	e8 7b 23 00 00       	call   801030d6 <end_op>
  ip = 0;
80100d5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  //스택 한 페이지만 할당
  sz = KERNBASE-1; //가상 메모리 끝 아래
80100d62:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz - PGSIZE, sz )) == 0) 
80100d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6c:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d71:	83 ec 04             	sub    $0x4,%esp
80100d74:	ff 75 e0             	push   -0x20(%ebp)
80100d77:	50                   	push   %eax
80100d78:	ff 75 d4             	push   -0x2c(%ebp)
80100d7b:	e8 ab 6a 00 00       	call   8010782b <allocuvm>
80100d80:	83 c4 10             	add    $0x10,%esp
80100d83:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d86:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d8a:	0f 84 02 02 00 00    	je     80100f92 <exec+0x3fa>
    goto bad;

  sz=PGROUNDDOWN(0x3000);
80100d90:	c7 45 e0 00 30 00 00 	movl   $0x3000,-0x20(%ebp)
  sp = KERNBASE - 1;
80100d97:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2a8>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 e1 01 00 00    	ja     80100f95 <exec+0x3fd>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 0f 3f 00 00       	call   80104cdd <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 e2 3e 00 00       	call   80104cdd <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 f6 6d 00 00       	call   80107c17 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 6c 01 00 00    	js     80100f98 <exec+0x400>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x212>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0){
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 5a 6d 00 00       	call   80107c17 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	79 15                	jns    80100ed9 <exec+0x341>
    cprintf("[exec] copyout of ustack failed\n");
80100ec4:	83 ec 0c             	sub    $0xc,%esp
80100ec7:	68 3c a2 10 80       	push   $0x8010a23c
80100ecc:	e8 23 f5 ff ff       	call   801003f4 <cprintf>
80100ed1:	83 c4 10             	add    $0x10,%esp
    goto bad;
80100ed4:	e9 c0 00 00 00       	jmp    80100f99 <exec+0x401>

  }

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80100edc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ee5:	eb 17                	jmp    80100efe <exec+0x366>
    if(*s == '/')
80100ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eea:	0f b6 00             	movzbl (%eax),%eax
80100eed:	3c 2f                	cmp    $0x2f,%al
80100eef:	75 09                	jne    80100efa <exec+0x362>
      last = s+1;
80100ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef4:	83 c0 01             	add    $0x1,%eax
80100ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100efa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f01:	0f b6 00             	movzbl (%eax),%eax
80100f04:	84 c0                	test   %al,%al
80100f06:	75 df                	jne    80100ee7 <exec+0x34f>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0b:	83 c0 6c             	add    $0x6c,%eax
80100f0e:	83 ec 04             	sub    $0x4,%esp
80100f11:	6a 10                	push   $0x10
80100f13:	ff 75 f0             	push   -0x10(%ebp)
80100f16:	50                   	push   %eax
80100f17:	e8 76 3d 00 00       	call   80104c92 <safestrcpy>
80100f1c:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f22:	8b 40 04             	mov    0x4(%eax),%eax
80100f25:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f2e:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f31:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f34:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f37:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	8b 40 18             	mov    0x18(%eax),%eax
80100f3f:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f45:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f48:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f4b:	8b 40 18             	mov    0x18(%eax),%eax
80100f4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f51:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f54:	83 ec 0c             	sub    $0xc,%esp
80100f57:	ff 75 d0             	push   -0x30(%ebp)
80100f5a:	e8 f0 65 00 00       	call   8010754f <switchuvm>
80100f5f:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f62:	83 ec 0c             	sub    $0xc,%esp
80100f65:	ff 75 cc             	push   -0x34(%ebp)
80100f68:	e8 87 6a 00 00       	call   801079f4 <freevm>
80100f6d:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f70:	b8 00 00 00 00       	mov    $0x0,%eax
80100f75:	eb 54                	jmp    80100fcb <exec+0x433>
    goto bad;
80100f77:	90                   	nop
80100f78:	eb 1f                	jmp    80100f99 <exec+0x401>
    goto bad;
80100f7a:	90                   	nop
80100f7b:	eb 1c                	jmp    80100f99 <exec+0x401>
    goto bad;
80100f7d:	90                   	nop
80100f7e:	eb 19                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f80:	90                   	nop
80100f81:	eb 16                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f83:	90                   	nop
80100f84:	eb 13                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f86:	90                   	nop
80100f87:	eb 10                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f89:	90                   	nop
80100f8a:	eb 0d                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f8c:	90                   	nop
80100f8d:	eb 0a                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f8f:	90                   	nop
80100f90:	eb 07                	jmp    80100f99 <exec+0x401>
    goto bad;
80100f92:	90                   	nop
80100f93:	eb 04                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f95:	90                   	nop
80100f96:	eb 01                	jmp    80100f99 <exec+0x401>
      goto bad;
80100f98:	90                   	nop

 bad:
  if(pgdir)
80100f99:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f9d:	74 0e                	je     80100fad <exec+0x415>
    freevm(pgdir);
80100f9f:	83 ec 0c             	sub    $0xc,%esp
80100fa2:	ff 75 d4             	push   -0x2c(%ebp)
80100fa5:	e8 4a 6a 00 00       	call   801079f4 <freevm>
80100faa:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fb1:	74 13                	je     80100fc6 <exec+0x42e>
    iunlockput(ip);
80100fb3:	83 ec 0c             	sub    $0xc,%esp
80100fb6:	ff 75 d8             	push   -0x28(%ebp)
80100fb9:	e8 6b 0c 00 00       	call   80101c29 <iunlockput>
80100fbe:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fc1:	e8 10 21 00 00       	call   801030d6 <end_op>
  }
  return -1;
80100fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fcb:	c9                   	leave  
80100fcc:	c3                   	ret    

80100fcd <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fcd:	55                   	push   %ebp
80100fce:	89 e5                	mov    %esp,%ebp
80100fd0:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fd3:	83 ec 08             	sub    $0x8,%esp
80100fd6:	68 5d a2 10 80       	push   $0x8010a25d
80100fdb:	68 a0 1a 19 80       	push   $0x80191aa0
80100fe0:	e8 12 38 00 00       	call   801047f7 <initlock>
80100fe5:	83 c4 10             	add    $0x10,%esp
}
80100fe8:	90                   	nop
80100fe9:	c9                   	leave  
80100fea:	c3                   	ret    

80100feb <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100feb:	55                   	push   %ebp
80100fec:	89 e5                	mov    %esp,%ebp
80100fee:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100ff1:	83 ec 0c             	sub    $0xc,%esp
80100ff4:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff9:	e8 1b 38 00 00       	call   80104819 <acquire>
80100ffe:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101001:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101008:	eb 2d                	jmp    80101037 <filealloc+0x4c>
    if(f->ref == 0){
8010100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100d:	8b 40 04             	mov    0x4(%eax),%eax
80101010:	85 c0                	test   %eax,%eax
80101012:	75 1f                	jne    80101033 <filealloc+0x48>
      f->ref = 1;
80101014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101017:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101e:	83 ec 0c             	sub    $0xc,%esp
80101021:	68 a0 1a 19 80       	push   $0x80191aa0
80101026:	e8 5c 38 00 00       	call   80104887 <release>
8010102b:	83 c4 10             	add    $0x10,%esp
      return f;
8010102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101031:	eb 23                	jmp    80101056 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101033:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101037:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010103c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103f:	72 c9                	jb     8010100a <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	68 a0 1a 19 80       	push   $0x80191aa0
80101049:	e8 39 38 00 00       	call   80104887 <release>
8010104e:	83 c4 10             	add    $0x10,%esp
  return 0;
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101056:	c9                   	leave  
80101057:	c3                   	ret    

80101058 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101058:	55                   	push   %ebp
80101059:	89 e5                	mov    %esp,%ebp
8010105b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105e:	83 ec 0c             	sub    $0xc,%esp
80101061:	68 a0 1a 19 80       	push   $0x80191aa0
80101066:	e8 ae 37 00 00       	call   80104819 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 64 a2 10 80       	push   $0x8010a264
80101080:	e8 3c f5 ff ff       	call   801005c1 <panic>
  f->ref++;
80101085:	8b 45 08             	mov    0x8(%ebp),%eax
80101088:	8b 40 04             	mov    0x4(%eax),%eax
8010108b:	8d 50 01             	lea    0x1(%eax),%edx
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101094:	83 ec 0c             	sub    $0xc,%esp
80101097:	68 a0 1a 19 80       	push   $0x80191aa0
8010109c:	e8 e6 37 00 00       	call   80104887 <release>
801010a1:	83 c4 10             	add    $0x10,%esp
  return f;
801010a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a7:	c9                   	leave  
801010a8:	c3                   	ret    

801010a9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a9:	55                   	push   %ebp
801010aa:	89 e5                	mov    %esp,%ebp
801010ac:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 a0 1a 19 80       	push   $0x80191aa0
801010b7:	e8 5d 37 00 00       	call   80104819 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 6c a2 10 80       	push   $0x8010a26c
801010d1:	e8 eb f4 ff ff       	call   801005c1 <panic>
  if(--f->ref > 0){
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801010df:	8b 45 08             	mov    0x8(%ebp),%eax
801010e2:	89 50 04             	mov    %edx,0x4(%eax)
801010e5:	8b 45 08             	mov    0x8(%ebp),%eax
801010e8:	8b 40 04             	mov    0x4(%eax),%eax
801010eb:	85 c0                	test   %eax,%eax
801010ed:	7e 15                	jle    80101104 <fileclose+0x5b>
    release(&ftable.lock);
801010ef:	83 ec 0c             	sub    $0xc,%esp
801010f2:	68 a0 1a 19 80       	push   $0x80191aa0
801010f7:	e8 8b 37 00 00       	call   80104887 <release>
801010fc:	83 c4 10             	add    $0x10,%esp
801010ff:	e9 8b 00 00 00       	jmp    8010118f <fileclose+0xe6>
    return;
  }
  ff = *f;
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 10                	mov    (%eax),%edx
80101109:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010110c:	8b 50 04             	mov    0x4(%eax),%edx
8010110f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101112:	8b 50 08             	mov    0x8(%eax),%edx
80101115:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101118:	8b 50 0c             	mov    0xc(%eax),%edx
8010111b:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111e:	8b 50 10             	mov    0x10(%eax),%edx
80101121:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101124:	8b 40 14             	mov    0x14(%eax),%eax
80101127:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010112a:	8b 45 08             	mov    0x8(%ebp),%eax
8010112d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101134:	8b 45 08             	mov    0x8(%ebp),%eax
80101137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010113d:	83 ec 0c             	sub    $0xc,%esp
80101140:	68 a0 1a 19 80       	push   $0x80191aa0
80101145:	e8 3d 37 00 00       	call   80104887 <release>
8010114a:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010114d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101150:	83 f8 01             	cmp    $0x1,%eax
80101153:	75 19                	jne    8010116e <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101155:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101159:	0f be d0             	movsbl %al,%edx
8010115c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115f:	83 ec 08             	sub    $0x8,%esp
80101162:	52                   	push   %edx
80101163:	50                   	push   %eax
80101164:	e8 64 25 00 00       	call   801036cd <pipeclose>
80101169:	83 c4 10             	add    $0x10,%esp
8010116c:	eb 21                	jmp    8010118f <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101171:	83 f8 02             	cmp    $0x2,%eax
80101174:	75 19                	jne    8010118f <fileclose+0xe6>
    begin_op();
80101176:	e8 cf 1e 00 00       	call   8010304a <begin_op>
    iput(ff.ip);
8010117b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117e:	83 ec 0c             	sub    $0xc,%esp
80101181:	50                   	push   %eax
80101182:	e8 d2 09 00 00       	call   80101b59 <iput>
80101187:	83 c4 10             	add    $0x10,%esp
    end_op();
8010118a:	e8 47 1f 00 00       	call   801030d6 <end_op>
  }
}
8010118f:	c9                   	leave  
80101190:	c3                   	ret    

80101191 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101191:	55                   	push   %ebp
80101192:	89 e5                	mov    %esp,%ebp
80101194:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	8b 00                	mov    (%eax),%eax
8010119c:	83 f8 02             	cmp    $0x2,%eax
8010119f:	75 40                	jne    801011e1 <filestat+0x50>
    ilock(f->ip);
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 10             	mov    0x10(%eax),%eax
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	50                   	push   %eax
801011ab:	e8 48 08 00 00       	call   801019f8 <ilock>
801011b0:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011b3:	8b 45 08             	mov    0x8(%ebp),%eax
801011b6:	8b 40 10             	mov    0x10(%eax),%eax
801011b9:	83 ec 08             	sub    $0x8,%esp
801011bc:	ff 75 0c             	push   0xc(%ebp)
801011bf:	50                   	push   %eax
801011c0:	e8 d9 0c 00 00       	call   80101e9e <stati>
801011c5:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c8:	8b 45 08             	mov    0x8(%ebp),%eax
801011cb:	8b 40 10             	mov    0x10(%eax),%eax
801011ce:	83 ec 0c             	sub    $0xc,%esp
801011d1:	50                   	push   %eax
801011d2:	e8 34 09 00 00       	call   80101b0b <iunlock>
801011d7:	83 c4 10             	add    $0x10,%esp
    return 0;
801011da:	b8 00 00 00 00       	mov    $0x0,%eax
801011df:	eb 05                	jmp    801011e6 <filestat+0x55>
  }
  return -1;
801011e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e6:	c9                   	leave  
801011e7:	c3                   	ret    

801011e8 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e8:	55                   	push   %ebp
801011e9:	89 e5                	mov    %esp,%ebp
801011eb:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f5:	84 c0                	test   %al,%al
801011f7:	75 0a                	jne    80101203 <fileread+0x1b>
    return -1;
801011f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fe:	e9 9b 00 00 00       	jmp    8010129e <fileread+0xb6>
  if(f->type == FD_PIPE)
80101203:	8b 45 08             	mov    0x8(%ebp),%eax
80101206:	8b 00                	mov    (%eax),%eax
80101208:	83 f8 01             	cmp    $0x1,%eax
8010120b:	75 1a                	jne    80101227 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010120d:	8b 45 08             	mov    0x8(%ebp),%eax
80101210:	8b 40 0c             	mov    0xc(%eax),%eax
80101213:	83 ec 04             	sub    $0x4,%esp
80101216:	ff 75 10             	push   0x10(%ebp)
80101219:	ff 75 0c             	push   0xc(%ebp)
8010121c:	50                   	push   %eax
8010121d:	e8 58 26 00 00       	call   8010387a <piperead>
80101222:	83 c4 10             	add    $0x10,%esp
80101225:	eb 77                	jmp    8010129e <fileread+0xb6>
  if(f->type == FD_INODE){
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	8b 00                	mov    (%eax),%eax
8010122c:	83 f8 02             	cmp    $0x2,%eax
8010122f:	75 60                	jne    80101291 <fileread+0xa9>
    ilock(f->ip);
80101231:	8b 45 08             	mov    0x8(%ebp),%eax
80101234:	8b 40 10             	mov    0x10(%eax),%eax
80101237:	83 ec 0c             	sub    $0xc,%esp
8010123a:	50                   	push   %eax
8010123b:	e8 b8 07 00 00       	call   801019f8 <ilock>
80101240:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101243:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 50 14             	mov    0x14(%eax),%edx
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 40 10             	mov    0x10(%eax),%eax
80101252:	51                   	push   %ecx
80101253:	52                   	push   %edx
80101254:	ff 75 0c             	push   0xc(%ebp)
80101257:	50                   	push   %eax
80101258:	e8 87 0c 00 00       	call   80101ee4 <readi>
8010125d:	83 c4 10             	add    $0x10,%esp
80101260:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101263:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101267:	7e 11                	jle    8010127a <fileread+0x92>
      f->off += r;
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	8b 50 14             	mov    0x14(%eax),%edx
8010126f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101272:	01 c2                	add    %eax,%edx
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 40 10             	mov    0x10(%eax),%eax
80101280:	83 ec 0c             	sub    $0xc,%esp
80101283:	50                   	push   %eax
80101284:	e8 82 08 00 00       	call   80101b0b <iunlock>
80101289:	83 c4 10             	add    $0x10,%esp
    return r;
8010128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128f:	eb 0d                	jmp    8010129e <fileread+0xb6>
  }
  panic("fileread");
80101291:	83 ec 0c             	sub    $0xc,%esp
80101294:	68 76 a2 10 80       	push   $0x8010a276
80101299:	e8 23 f3 ff ff       	call   801005c1 <panic>
}
8010129e:	c9                   	leave  
8010129f:	c3                   	ret    

801012a0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	53                   	push   %ebx
801012a4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012ae:	84 c0                	test   %al,%al
801012b0:	75 0a                	jne    801012bc <filewrite+0x1c>
    return -1;
801012b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b7:	e9 1b 01 00 00       	jmp    801013d7 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 00                	mov    (%eax),%eax
801012c1:	83 f8 01             	cmp    $0x1,%eax
801012c4:	75 1d                	jne    801012e3 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 0c             	mov    0xc(%eax),%eax
801012cc:	83 ec 04             	sub    $0x4,%esp
801012cf:	ff 75 10             	push   0x10(%ebp)
801012d2:	ff 75 0c             	push   0xc(%ebp)
801012d5:	50                   	push   %eax
801012d6:	e8 9d 24 00 00       	call   80103778 <pipewrite>
801012db:	83 c4 10             	add    $0x10,%esp
801012de:	e9 f4 00 00 00       	jmp    801013d7 <filewrite+0x137>
  if(f->type == FD_INODE){
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	8b 00                	mov    (%eax),%eax
801012e8:	83 f8 02             	cmp    $0x2,%eax
801012eb:	0f 85 d9 00 00 00    	jne    801013ca <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012f1:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012ff:	e9 a3 00 00 00       	jmp    801013a7 <filewrite+0x107>
      int n1 = n - i;
80101304:	8b 45 10             	mov    0x10(%ebp),%eax
80101307:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101310:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101313:	7e 06                	jle    8010131b <filewrite+0x7b>
        n1 = max;
80101315:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101318:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010131b:	e8 2a 1d 00 00       	call   8010304a <begin_op>
      ilock(f->ip);
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 40 10             	mov    0x10(%eax),%eax
80101326:	83 ec 0c             	sub    $0xc,%esp
80101329:	50                   	push   %eax
8010132a:	e8 c9 06 00 00       	call   801019f8 <ilock>
8010132f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101332:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 50 14             	mov    0x14(%eax),%edx
8010133b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101341:	01 c3                	add    %eax,%ebx
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	8b 40 10             	mov    0x10(%eax),%eax
80101349:	51                   	push   %ecx
8010134a:	52                   	push   %edx
8010134b:	53                   	push   %ebx
8010134c:	50                   	push   %eax
8010134d:	e8 e7 0c 00 00       	call   80102039 <writei>
80101352:	83 c4 10             	add    $0x10,%esp
80101355:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101358:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010135c:	7e 11                	jle    8010136f <filewrite+0xcf>
        f->off += r;
8010135e:	8b 45 08             	mov    0x8(%ebp),%eax
80101361:	8b 50 14             	mov    0x14(%eax),%edx
80101364:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101367:	01 c2                	add    %eax,%edx
80101369:	8b 45 08             	mov    0x8(%ebp),%eax
8010136c:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	8b 40 10             	mov    0x10(%eax),%eax
80101375:	83 ec 0c             	sub    $0xc,%esp
80101378:	50                   	push   %eax
80101379:	e8 8d 07 00 00       	call   80101b0b <iunlock>
8010137e:	83 c4 10             	add    $0x10,%esp
      end_op();
80101381:	e8 50 1d 00 00       	call   801030d6 <end_op>

      if(r < 0)
80101386:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010138a:	78 29                	js     801013b5 <filewrite+0x115>
        break;
      if(r != n1)
8010138c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101392:	74 0d                	je     801013a1 <filewrite+0x101>
        panic("short filewrite");
80101394:	83 ec 0c             	sub    $0xc,%esp
80101397:	68 7f a2 10 80       	push   $0x8010a27f
8010139c:	e8 20 f2 ff ff       	call   801005c1 <panic>
      i += r;
801013a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013aa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ad:	0f 8c 51 ff ff ff    	jl     80101304 <filewrite+0x64>
801013b3:	eb 01                	jmp    801013b6 <filewrite+0x116>
        break;
801013b5:	90                   	nop
    }
    return i == n ? n : -1;
801013b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801013bc:	75 05                	jne    801013c3 <filewrite+0x123>
801013be:	8b 45 10             	mov    0x10(%ebp),%eax
801013c1:	eb 14                	jmp    801013d7 <filewrite+0x137>
801013c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c8:	eb 0d                	jmp    801013d7 <filewrite+0x137>
  }
  panic("filewrite");
801013ca:	83 ec 0c             	sub    $0xc,%esp
801013cd:	68 8f a2 10 80       	push   $0x8010a28f
801013d2:	e8 ea f1 ff ff       	call   801005c1 <panic>
}
801013d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013da:	c9                   	leave  
801013db:	c3                   	ret    

801013dc <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013dc:	55                   	push   %ebp
801013dd:	89 e5                	mov    %esp,%ebp
801013df:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013e2:	8b 45 08             	mov    0x8(%ebp),%eax
801013e5:	83 ec 08             	sub    $0x8,%esp
801013e8:	6a 01                	push   $0x1
801013ea:	50                   	push   %eax
801013eb:	e8 11 ee ff ff       	call   80100201 <bread>
801013f0:	83 c4 10             	add    $0x10,%esp
801013f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f9:	83 c0 5c             	add    $0x5c,%eax
801013fc:	83 ec 04             	sub    $0x4,%esp
801013ff:	6a 1c                	push   $0x1c
80101401:	50                   	push   %eax
80101402:	ff 75 0c             	push   0xc(%ebp)
80101405:	e8 44 37 00 00       	call   80104b4e <memmove>
8010140a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010140d:	83 ec 0c             	sub    $0xc,%esp
80101410:	ff 75 f4             	push   -0xc(%ebp)
80101413:	e8 6b ee ff ff       	call   80100283 <brelse>
80101418:	83 c4 10             	add    $0x10,%esp
}
8010141b:	90                   	nop
8010141c:	c9                   	leave  
8010141d:	c3                   	ret    

8010141e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141e:	55                   	push   %ebp
8010141f:	89 e5                	mov    %esp,%ebp
80101421:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101424:	8b 55 0c             	mov    0xc(%ebp),%edx
80101427:	8b 45 08             	mov    0x8(%ebp),%eax
8010142a:	83 ec 08             	sub    $0x8,%esp
8010142d:	52                   	push   %edx
8010142e:	50                   	push   %eax
8010142f:	e8 cd ed ff ff       	call   80100201 <bread>
80101434:	83 c4 10             	add    $0x10,%esp
80101437:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010143a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143d:	83 c0 5c             	add    $0x5c,%eax
80101440:	83 ec 04             	sub    $0x4,%esp
80101443:	68 00 02 00 00       	push   $0x200
80101448:	6a 00                	push   $0x0
8010144a:	50                   	push   %eax
8010144b:	e8 3f 36 00 00       	call   80104a8f <memset>
80101450:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 1e 00 00       	call   80103283 <log_write>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	push   -0xc(%ebp)
80101467:	e8 17 ee ff ff       	call   80100283 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave  
80101471:	c3                   	ret    

80101472 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101472:	55                   	push   %ebp
80101473:	89 e5                	mov    %esp,%ebp
80101475:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101478:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101486:	e9 0b 01 00 00       	jmp    80101596 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101494:	85 c0                	test   %eax,%eax
80101496:	0f 48 c2             	cmovs  %edx,%eax
80101499:	c1 f8 0c             	sar    $0xc,%eax
8010149c:	89 c2                	mov    %eax,%edx
8010149e:	a1 58 24 19 80       	mov    0x80192458,%eax
801014a3:	01 d0                	add    %edx,%eax
801014a5:	83 ec 08             	sub    $0x8,%esp
801014a8:	50                   	push   %eax
801014a9:	ff 75 08             	push   0x8(%ebp)
801014ac:	e8 50 ed ff ff       	call   80100201 <bread>
801014b1:	83 c4 10             	add    $0x10,%esp
801014b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014be:	e9 9e 00 00 00       	jmp    80101561 <balloc+0xef>
      m = 1 << (bi % 8);
801014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c6:	83 e0 07             	and    $0x7,%eax
801014c9:	ba 01 00 00 00       	mov    $0x1,%edx
801014ce:	89 c1                	mov    %eax,%ecx
801014d0:	d3 e2                	shl    %cl,%edx
801014d2:	89 d0                	mov    %edx,%eax
801014d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014da:	8d 50 07             	lea    0x7(%eax),%edx
801014dd:	85 c0                	test   %eax,%eax
801014df:	0f 48 c2             	cmovs  %edx,%eax
801014e2:	c1 f8 03             	sar    $0x3,%eax
801014e5:	89 c2                	mov    %eax,%edx
801014e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ea:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014ef:	0f b6 c0             	movzbl %al,%eax
801014f2:	23 45 e8             	and    -0x18(%ebp),%eax
801014f5:	85 c0                	test   %eax,%eax
801014f7:	75 64                	jne    8010155d <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fc:	8d 50 07             	lea    0x7(%eax),%edx
801014ff:	85 c0                	test   %eax,%eax
80101501:	0f 48 c2             	cmovs  %edx,%eax
80101504:	c1 f8 03             	sar    $0x3,%eax
80101507:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150a:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150f:	89 d1                	mov    %edx,%ecx
80101511:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101514:	09 ca                	or     %ecx,%edx
80101516:	89 d1                	mov    %edx,%ecx
80101518:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010151b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 1d 00 00       	call   80103283 <log_write>
8010152a:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010152d:	83 ec 0c             	sub    $0xc,%esp
80101530:	ff 75 ec             	push   -0x14(%ebp)
80101533:	e8 4b ed ff ff       	call   80100283 <brelse>
80101538:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010153b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101541:	01 c2                	add    %eax,%edx
80101543:	8b 45 08             	mov    0x8(%ebp),%eax
80101546:	83 ec 08             	sub    $0x8,%esp
80101549:	52                   	push   %edx
8010154a:	50                   	push   %eax
8010154b:	e8 ce fe ff ff       	call   8010141e <bzero>
80101550:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101553:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101559:	01 d0                	add    %edx,%eax
8010155b:	eb 57                	jmp    801015b4 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010155d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101561:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101568:	7f 17                	jg     80101581 <balloc+0x10f>
8010156a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101570:	01 d0                	add    %edx,%eax
80101572:	89 c2                	mov    %eax,%edx
80101574:	a1 40 24 19 80       	mov    0x80192440,%eax
80101579:	39 c2                	cmp    %eax,%edx
8010157b:	0f 82 42 ff ff ff    	jb     801014c3 <balloc+0x51>
      }
    }
    brelse(bp);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	ff 75 ec             	push   -0x14(%ebp)
80101587:	e8 f7 ec ff ff       	call   80100283 <brelse>
8010158c:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101596:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159f:	39 c2                	cmp    %eax,%edx
801015a1:	0f 87 e4 fe ff ff    	ja     8010148b <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a7:	83 ec 0c             	sub    $0xc,%esp
801015aa:	68 9c a2 10 80       	push   $0x8010a29c
801015af:	e8 0d f0 ff ff       	call   801005c1 <panic>
}
801015b4:	c9                   	leave  
801015b5:	c3                   	ret    

801015b6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b6:	55                   	push   %ebp
801015b7:	89 e5                	mov    %esp,%ebp
801015b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015bc:	83 ec 08             	sub    $0x8,%esp
801015bf:	68 40 24 19 80       	push   $0x80192440
801015c4:	ff 75 08             	push   0x8(%ebp)
801015c7:	e8 10 fe ff ff       	call   801013dc <readsb>
801015cc:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d2:	c1 e8 0c             	shr    $0xc,%eax
801015d5:	89 c2                	mov    %eax,%edx
801015d7:	a1 58 24 19 80       	mov    0x80192458,%eax
801015dc:	01 c2                	add    %eax,%edx
801015de:	8b 45 08             	mov    0x8(%ebp),%eax
801015e1:	83 ec 08             	sub    $0x8,%esp
801015e4:	52                   	push   %edx
801015e5:	50                   	push   %eax
801015e6:	e8 16 ec ff ff       	call   80100201 <bread>
801015eb:	83 c4 10             	add    $0x10,%esp
801015ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f4:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ff:	83 e0 07             	and    $0x7,%eax
80101602:	ba 01 00 00 00       	mov    $0x1,%edx
80101607:	89 c1                	mov    %eax,%ecx
80101609:	d3 e2                	shl    %cl,%edx
8010160b:	89 d0                	mov    %edx,%eax
8010160d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	8d 50 07             	lea    0x7(%eax),%edx
80101616:	85 c0                	test   %eax,%eax
80101618:	0f 48 c2             	cmovs  %edx,%eax
8010161b:	c1 f8 03             	sar    $0x3,%eax
8010161e:	89 c2                	mov    %eax,%edx
80101620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101623:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101628:	0f b6 c0             	movzbl %al,%eax
8010162b:	23 45 ec             	and    -0x14(%ebp),%eax
8010162e:	85 c0                	test   %eax,%eax
80101630:	75 0d                	jne    8010163f <bfree+0x89>
    panic("freeing free block");
80101632:	83 ec 0c             	sub    $0xc,%esp
80101635:	68 b2 a2 10 80       	push   $0x8010a2b2
8010163a:	e8 82 ef ff ff       	call   801005c1 <panic>
  bp->data[bi/8] &= ~m;
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	8d 50 07             	lea    0x7(%eax),%edx
80101645:	85 c0                	test   %eax,%eax
80101647:	0f 48 c2             	cmovs  %edx,%eax
8010164a:	c1 f8 03             	sar    $0x3,%eax
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101655:	89 d1                	mov    %edx,%ecx
80101657:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010165a:	f7 d2                	not    %edx
8010165c:	21 ca                	and    %ecx,%edx
8010165e:	89 d1                	mov    %edx,%ecx
80101660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101663:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 1c 00 00       	call   80103283 <log_write>
80101672:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101675:	83 ec 0c             	sub    $0xc,%esp
80101678:	ff 75 f4             	push   -0xc(%ebp)
8010167b:	e8 03 ec ff ff       	call   80100283 <brelse>
80101680:	83 c4 10             	add    $0x10,%esp
}
80101683:	90                   	nop
80101684:	c9                   	leave  
80101685:	c3                   	ret    

80101686 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101686:	55                   	push   %ebp
80101687:	89 e5                	mov    %esp,%ebp
80101689:	57                   	push   %edi
8010168a:	56                   	push   %esi
8010168b:	53                   	push   %ebx
8010168c:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101696:	83 ec 08             	sub    $0x8,%esp
80101699:	68 c5 a2 10 80       	push   $0x8010a2c5
8010169e:	68 60 24 19 80       	push   $0x80192460
801016a3:	e8 4f 31 00 00       	call   801047f7 <initlock>
801016a8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016b2:	eb 2d                	jmp    801016e1 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b7:	89 d0                	mov    %edx,%eax
801016b9:	c1 e0 03             	shl    $0x3,%eax
801016bc:	01 d0                	add    %edx,%eax
801016be:	c1 e0 04             	shl    $0x4,%eax
801016c1:	83 c0 30             	add    $0x30,%eax
801016c4:	05 60 24 19 80       	add    $0x80192460,%eax
801016c9:	83 c0 10             	add    $0x10,%eax
801016cc:	83 ec 08             	sub    $0x8,%esp
801016cf:	68 cc a2 10 80       	push   $0x8010a2cc
801016d4:	50                   	push   %eax
801016d5:	e8 c0 2f 00 00       	call   8010469a <initsleeplock>
801016da:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016dd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016e1:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e5:	7e cd                	jle    801016b4 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e7:	83 ec 08             	sub    $0x8,%esp
801016ea:	68 40 24 19 80       	push   $0x80192440
801016ef:	ff 75 08             	push   0x8(%ebp)
801016f2:	e8 e5 fc ff ff       	call   801013dc <readsb>
801016f7:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016fa:	a1 58 24 19 80       	mov    0x80192458,%eax
801016ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101702:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101708:	8b 35 50 24 19 80    	mov    0x80192450,%esi
8010170e:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101714:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010171a:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101720:	a1 40 24 19 80       	mov    0x80192440,%eax
80101725:	ff 75 d4             	push   -0x2c(%ebp)
80101728:	57                   	push   %edi
80101729:	56                   	push   %esi
8010172a:	53                   	push   %ebx
8010172b:	51                   	push   %ecx
8010172c:	52                   	push   %edx
8010172d:	50                   	push   %eax
8010172e:	68 d4 a2 10 80       	push   $0x8010a2d4
80101733:	e8 bc ec ff ff       	call   801003f4 <cprintf>
80101738:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010173b:	90                   	nop
8010173c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173f:	5b                   	pop    %ebx
80101740:	5e                   	pop    %esi
80101741:	5f                   	pop    %edi
80101742:	5d                   	pop    %ebp
80101743:	c3                   	ret    

80101744 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101744:	55                   	push   %ebp
80101745:	89 e5                	mov    %esp,%ebp
80101747:	83 ec 28             	sub    $0x28,%esp
8010174a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010174d:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101751:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101758:	e9 9e 00 00 00       	jmp    801017fb <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101760:	c1 e8 03             	shr    $0x3,%eax
80101763:	89 c2                	mov    %eax,%edx
80101765:	a1 54 24 19 80       	mov    0x80192454,%eax
8010176a:	01 d0                	add    %edx,%eax
8010176c:	83 ec 08             	sub    $0x8,%esp
8010176f:	50                   	push   %eax
80101770:	ff 75 08             	push   0x8(%ebp)
80101773:	e8 89 ea ff ff       	call   80100201 <bread>
80101778:	83 c4 10             	add    $0x10,%esp
8010177b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101781:	8d 50 5c             	lea    0x5c(%eax),%edx
80101784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101787:	83 e0 07             	and    $0x7,%eax
8010178a:	c1 e0 06             	shl    $0x6,%eax
8010178d:	01 d0                	add    %edx,%eax
8010178f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101792:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101795:	0f b7 00             	movzwl (%eax),%eax
80101798:	66 85 c0             	test   %ax,%ax
8010179b:	75 4c                	jne    801017e9 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010179d:	83 ec 04             	sub    $0x4,%esp
801017a0:	6a 40                	push   $0x40
801017a2:	6a 00                	push   $0x0
801017a4:	ff 75 ec             	push   -0x14(%ebp)
801017a7:	e8 e3 32 00 00       	call   80104a8f <memset>
801017ac:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b2:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b6:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf 1a 00 00       	call   80103283 <log_write>
801017c4:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c7:	83 ec 0c             	sub    $0xc,%esp
801017ca:	ff 75 f0             	push   -0x10(%ebp)
801017cd:	e8 b1 ea ff ff       	call   80100283 <brelse>
801017d2:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	83 ec 08             	sub    $0x8,%esp
801017db:	50                   	push   %eax
801017dc:	ff 75 08             	push   0x8(%ebp)
801017df:	e8 f8 00 00 00       	call   801018dc <iget>
801017e4:	83 c4 10             	add    $0x10,%esp
801017e7:	eb 30                	jmp    80101819 <ialloc+0xd5>
    }
    brelse(bp);
801017e9:	83 ec 0c             	sub    $0xc,%esp
801017ec:	ff 75 f0             	push   -0x10(%ebp)
801017ef:	e8 8f ea ff ff       	call   80100283 <brelse>
801017f4:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017fb:	8b 15 48 24 19 80    	mov    0x80192448,%edx
80101801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101804:	39 c2                	cmp    %eax,%edx
80101806:	0f 87 51 ff ff ff    	ja     8010175d <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010180c:	83 ec 0c             	sub    $0xc,%esp
8010180f:	68 27 a3 10 80       	push   $0x8010a327
80101814:	e8 a8 ed ff ff       	call   801005c1 <panic>
}
80101819:	c9                   	leave  
8010181a:	c3                   	ret    

8010181b <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010181b:	55                   	push   %ebp
8010181c:	89 e5                	mov    %esp,%ebp
8010181e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101821:	8b 45 08             	mov    0x8(%ebp),%eax
80101824:	8b 40 04             	mov    0x4(%eax),%eax
80101827:	c1 e8 03             	shr    $0x3,%eax
8010182a:	89 c2                	mov    %eax,%edx
8010182c:	a1 54 24 19 80       	mov    0x80192454,%eax
80101831:	01 c2                	add    %eax,%edx
80101833:	8b 45 08             	mov    0x8(%ebp),%eax
80101836:	8b 00                	mov    (%eax),%eax
80101838:	83 ec 08             	sub    $0x8,%esp
8010183b:	52                   	push   %edx
8010183c:	50                   	push   %eax
8010183d:	e8 bf e9 ff ff       	call   80100201 <bread>
80101842:	83 c4 10             	add    $0x10,%esp
80101845:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010184e:	8b 45 08             	mov    0x8(%ebp),%eax
80101851:	8b 40 04             	mov    0x4(%eax),%eax
80101854:	83 e0 07             	and    $0x7,%eax
80101857:	c1 e0 06             	shl    $0x6,%eax
8010185a:	01 d0                	add    %edx,%eax
8010185c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101892:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101896:	8b 45 08             	mov    0x8(%ebp),%eax
80101899:	8b 50 58             	mov    0x58(%eax),%edx
8010189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189f:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ab:	83 c0 0c             	add    $0xc,%eax
801018ae:	83 ec 04             	sub    $0x4,%esp
801018b1:	6a 34                	push   $0x34
801018b3:	52                   	push   %edx
801018b4:	50                   	push   %eax
801018b5:	e8 94 32 00 00       	call   80104b4e <memmove>
801018ba:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb 19 00 00       	call   80103283 <log_write>
801018c8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018cb:	83 ec 0c             	sub    $0xc,%esp
801018ce:	ff 75 f4             	push   -0xc(%ebp)
801018d1:	e8 ad e9 ff ff       	call   80100283 <brelse>
801018d6:	83 c4 10             	add    $0x10,%esp
}
801018d9:	90                   	nop
801018da:	c9                   	leave  
801018db:	c3                   	ret    

801018dc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018dc:	55                   	push   %ebp
801018dd:	89 e5                	mov    %esp,%ebp
801018df:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018e2:	83 ec 0c             	sub    $0xc,%esp
801018e5:	68 60 24 19 80       	push   $0x80192460
801018ea:	e8 2a 2f 00 00       	call   80104819 <acquire>
801018ef:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f9:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
80101900:	eb 60                	jmp    80101962 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101905:	8b 40 08             	mov    0x8(%eax),%eax
80101908:	85 c0                	test   %eax,%eax
8010190a:	7e 39                	jle    80101945 <iget+0x69>
8010190c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190f:	8b 00                	mov    (%eax),%eax
80101911:	39 45 08             	cmp    %eax,0x8(%ebp)
80101914:	75 2f                	jne    80101945 <iget+0x69>
80101916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101919:	8b 40 04             	mov    0x4(%eax),%eax
8010191c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010191f:	75 24                	jne    80101945 <iget+0x69>
      ip->ref++;
80101921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101924:	8b 40 08             	mov    0x8(%eax),%eax
80101927:	8d 50 01             	lea    0x1(%eax),%edx
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101930:	83 ec 0c             	sub    $0xc,%esp
80101933:	68 60 24 19 80       	push   $0x80192460
80101938:	e8 4a 2f 00 00       	call   80104887 <release>
8010193d:	83 c4 10             	add    $0x10,%esp
      return ip;
80101940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101943:	eb 77                	jmp    801019bc <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101945:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101949:	75 10                	jne    8010195b <iget+0x7f>
8010194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194e:	8b 40 08             	mov    0x8(%eax),%eax
80101951:	85 c0                	test   %eax,%eax
80101953:	75 06                	jne    8010195b <iget+0x7f>
      empty = ip;
80101955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101958:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010195b:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101962:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101969:	72 97                	jb     80101902 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010196b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010196f:	75 0d                	jne    8010197e <iget+0xa2>
    panic("iget: no inodes");
80101971:	83 ec 0c             	sub    $0xc,%esp
80101974:	68 39 a3 10 80       	push   $0x8010a339
80101979:	e8 43 ec ff ff       	call   801005c1 <panic>

  ip = empty;
8010197e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	8b 55 08             	mov    0x8(%ebp),%edx
8010198a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101992:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101998:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
8010199f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a2:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a9:	83 ec 0c             	sub    $0xc,%esp
801019ac:	68 60 24 19 80       	push   $0x80192460
801019b1:	e8 d1 2e 00 00       	call   80104887 <release>
801019b6:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019bc:	c9                   	leave  
801019bd:	c3                   	ret    

801019be <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019be:	55                   	push   %ebp
801019bf:	89 e5                	mov    %esp,%ebp
801019c1:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019c4:	83 ec 0c             	sub    $0xc,%esp
801019c7:	68 60 24 19 80       	push   $0x80192460
801019cc:	e8 48 2e 00 00       	call   80104819 <acquire>
801019d1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019d4:	8b 45 08             	mov    0x8(%ebp),%eax
801019d7:	8b 40 08             	mov    0x8(%eax),%eax
801019da:	8d 50 01             	lea    0x1(%eax),%edx
801019dd:	8b 45 08             	mov    0x8(%ebp),%eax
801019e0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019e3:	83 ec 0c             	sub    $0xc,%esp
801019e6:	68 60 24 19 80       	push   $0x80192460
801019eb:	e8 97 2e 00 00       	call   80104887 <release>
801019f0:	83 c4 10             	add    $0x10,%esp
  return ip;
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f6:	c9                   	leave  
801019f7:	c3                   	ret    

801019f8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f8:	55                   	push   %ebp
801019f9:	89 e5                	mov    %esp,%ebp
801019fb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a02:	74 0a                	je     80101a0e <ilock+0x16>
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	8b 40 08             	mov    0x8(%eax),%eax
80101a0a:	85 c0                	test   %eax,%eax
80101a0c:	7f 0d                	jg     80101a1b <ilock+0x23>
    panic("ilock");
80101a0e:	83 ec 0c             	sub    $0xc,%esp
80101a11:	68 49 a3 10 80       	push   $0x8010a349
80101a16:	e8 a6 eb ff ff       	call   801005c1 <panic>

  acquiresleep(&ip->lock);
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	83 c0 0c             	add    $0xc,%eax
80101a21:	83 ec 0c             	sub    $0xc,%esp
80101a24:	50                   	push   %eax
80101a25:	e8 ac 2c 00 00       	call   801046d6 <acquiresleep>
80101a2a:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a33:	85 c0                	test   %eax,%eax
80101a35:	0f 85 cd 00 00 00    	jne    80101b08 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3e:	8b 40 04             	mov    0x4(%eax),%eax
80101a41:	c1 e8 03             	shr    $0x3,%eax
80101a44:	89 c2                	mov    %eax,%edx
80101a46:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a4b:	01 c2                	add    %eax,%edx
80101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a50:	8b 00                	mov    (%eax),%eax
80101a52:	83 ec 08             	sub    $0x8,%esp
80101a55:	52                   	push   %edx
80101a56:	50                   	push   %eax
80101a57:	e8 a5 e7 ff ff       	call   80100201 <bread>
80101a5c:	83 c4 10             	add    $0x10,%esp
80101a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	8b 40 04             	mov    0x4(%eax),%eax
80101a6e:	83 e0 07             	and    $0x7,%eax
80101a71:	c1 e0 06             	shl    $0x6,%eax
80101a74:	01 d0                	add    %edx,%eax
80101a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7c:	0f b7 10             	movzwl (%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab3:	8b 50 08             	mov    0x8(%eax),%edx
80101ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab9:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abf:	8d 50 0c             	lea    0xc(%eax),%edx
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	83 c0 5c             	add    $0x5c,%eax
80101ac8:	83 ec 04             	sub    $0x4,%esp
80101acb:	6a 34                	push   $0x34
80101acd:	52                   	push   %edx
80101ace:	50                   	push   %eax
80101acf:	e8 7a 30 00 00       	call   80104b4e <memmove>
80101ad4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad7:	83 ec 0c             	sub    $0xc,%esp
80101ada:	ff 75 f4             	push   -0xc(%ebp)
80101add:	e8 a1 e7 ff ff       	call   80100283 <brelse>
80101ae2:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af6:	66 85 c0             	test   %ax,%ax
80101af9:	75 0d                	jne    80101b08 <ilock+0x110>
      panic("ilock: no type");
80101afb:	83 ec 0c             	sub    $0xc,%esp
80101afe:	68 4f a3 10 80       	push   $0x8010a34f
80101b03:	e8 b9 ea ff ff       	call   801005c1 <panic>
  }
}
80101b08:	90                   	nop
80101b09:	c9                   	leave  
80101b0a:	c3                   	ret    

80101b0b <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b0b:	55                   	push   %ebp
80101b0c:	89 e5                	mov    %esp,%ebp
80101b0e:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b11:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b15:	74 20                	je     80101b37 <iunlock+0x2c>
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	83 c0 0c             	add    $0xc,%eax
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	50                   	push   %eax
80101b21:	e8 62 2c 00 00       	call   80104788 <holdingsleep>
80101b26:	83 c4 10             	add    $0x10,%esp
80101b29:	85 c0                	test   %eax,%eax
80101b2b:	74 0a                	je     80101b37 <iunlock+0x2c>
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 40 08             	mov    0x8(%eax),%eax
80101b33:	85 c0                	test   %eax,%eax
80101b35:	7f 0d                	jg     80101b44 <iunlock+0x39>
    panic("iunlock");
80101b37:	83 ec 0c             	sub    $0xc,%esp
80101b3a:	68 5e a3 10 80       	push   $0x8010a35e
80101b3f:	e8 7d ea ff ff       	call   801005c1 <panic>

  releasesleep(&ip->lock);
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	83 c0 0c             	add    $0xc,%eax
80101b4a:	83 ec 0c             	sub    $0xc,%esp
80101b4d:	50                   	push   %eax
80101b4e:	e8 e7 2b 00 00       	call   8010473a <releasesleep>
80101b53:	83 c4 10             	add    $0x10,%esp
}
80101b56:	90                   	nop
80101b57:	c9                   	leave  
80101b58:	c3                   	ret    

80101b59 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b59:	55                   	push   %ebp
80101b5a:	89 e5                	mov    %esp,%ebp
80101b5c:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	83 c0 0c             	add    $0xc,%eax
80101b65:	83 ec 0c             	sub    $0xc,%esp
80101b68:	50                   	push   %eax
80101b69:	e8 68 2b 00 00       	call   801046d6 <acquiresleep>
80101b6e:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b71:	8b 45 08             	mov    0x8(%ebp),%eax
80101b74:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b77:	85 c0                	test   %eax,%eax
80101b79:	74 6a                	je     80101be5 <iput+0x8c>
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b82:	66 85 c0             	test   %ax,%ax
80101b85:	75 5e                	jne    80101be5 <iput+0x8c>
    acquire(&icache.lock);
80101b87:	83 ec 0c             	sub    $0xc,%esp
80101b8a:	68 60 24 19 80       	push   $0x80192460
80101b8f:	e8 85 2c 00 00       	call   80104819 <acquire>
80101b94:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	8b 40 08             	mov    0x8(%eax),%eax
80101b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	68 60 24 19 80       	push   $0x80192460
80101ba8:	e8 da 2c 00 00       	call   80104887 <release>
80101bad:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bb0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bb4:	75 2f                	jne    80101be5 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb6:	83 ec 0c             	sub    $0xc,%esp
80101bb9:	ff 75 08             	push   0x8(%ebp)
80101bbc:	e8 ad 01 00 00       	call   80101d6e <itrunc>
80101bc1:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bcd:	83 ec 0c             	sub    $0xc,%esp
80101bd0:	ff 75 08             	push   0x8(%ebp)
80101bd3:	e8 43 fc ff ff       	call   8010181b <iupdate>
80101bd8:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101be5:	8b 45 08             	mov    0x8(%ebp),%eax
80101be8:	83 c0 0c             	add    $0xc,%eax
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	50                   	push   %eax
80101bef:	e8 46 2b 00 00       	call   8010473a <releasesleep>
80101bf4:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf7:	83 ec 0c             	sub    $0xc,%esp
80101bfa:	68 60 24 19 80       	push   $0x80192460
80101bff:	e8 15 2c 00 00       	call   80104819 <acquire>
80101c04:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	8b 40 08             	mov    0x8(%eax),%eax
80101c0d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c16:	83 ec 0c             	sub    $0xc,%esp
80101c19:	68 60 24 19 80       	push   $0x80192460
80101c1e:	e8 64 2c 00 00       	call   80104887 <release>
80101c23:	83 c4 10             	add    $0x10,%esp
}
80101c26:	90                   	nop
80101c27:	c9                   	leave  
80101c28:	c3                   	ret    

80101c29 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c29:	55                   	push   %ebp
80101c2a:	89 e5                	mov    %esp,%ebp
80101c2c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 d1 fe ff ff       	call   80101b0b <iunlock>
80101c3a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3d:	83 ec 0c             	sub    $0xc,%esp
80101c40:	ff 75 08             	push   0x8(%ebp)
80101c43:	e8 11 ff ff ff       	call   80101b59 <iput>
80101c48:	83 c4 10             	add    $0x10,%esp
}
80101c4b:	90                   	nop
80101c4c:	c9                   	leave  
80101c4d:	c3                   	ret    

80101c4e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4e:	55                   	push   %ebp
80101c4f:	89 e5                	mov    %esp,%ebp
80101c51:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c54:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c58:	77 42                	ja     80101c9c <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c60:	83 c2 14             	add    $0x14,%edx
80101c63:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c6e:	75 24                	jne    80101c94 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 00                	mov    (%eax),%eax
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	50                   	push   %eax
80101c79:	e8 f4 f7 ff ff       	call   80101472 <balloc>
80101c7e:	83 c4 10             	add    $0x10,%esp
80101c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8a:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c90:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c97:	e9 d0 00 00 00       	jmp    80101d6c <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c9c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca4:	0f 87 b5 00 00 00    	ja     80101d5f <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cba:	75 20                	jne    80101cdc <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbf:	8b 00                	mov    (%eax),%eax
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	50                   	push   %eax
80101cc5:	e8 a8 f7 ff ff       	call   80101472 <balloc>
80101cca:	83 c4 10             	add    $0x10,%esp
80101ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd6:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdf:	8b 00                	mov    (%eax),%eax
80101ce1:	83 ec 08             	sub    $0x8,%esp
80101ce4:	ff 75 f4             	push   -0xc(%ebp)
80101ce7:	50                   	push   %eax
80101ce8:	e8 14 e5 ff ff       	call   80100201 <bread>
80101ced:	83 c4 10             	add    $0x10,%esp
80101cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf6:	83 c0 5c             	add    $0x5c,%eax
80101cf9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d09:	01 d0                	add    %edx,%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d14:	75 36                	jne    80101d4c <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	8b 00                	mov    (%eax),%eax
80101d1b:	83 ec 0c             	sub    $0xc,%esp
80101d1e:	50                   	push   %eax
80101d1f:	e8 4e f7 ff ff       	call   80101472 <balloc>
80101d24:	83 c4 10             	add    $0x10,%esp
80101d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d37:	01 c2                	add    %eax,%edx
80101d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3c:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a 15 00 00       	call   80103283 <log_write>
80101d49:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	ff 75 f0             	push   -0x10(%ebp)
80101d52:	e8 2c e5 ff ff       	call   80100283 <brelse>
80101d57:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5d:	eb 0d                	jmp    80101d6c <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d5f:	83 ec 0c             	sub    $0xc,%esp
80101d62:	68 66 a3 10 80       	push   $0x8010a366
80101d67:	e8 55 e8 ff ff       	call   801005c1 <panic>
}
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6e:	55                   	push   %ebp
80101d6f:	89 e5                	mov    %esp,%ebp
80101d71:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7b:	eb 45                	jmp    80101dc2 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	83 c2 14             	add    $0x14,%edx
80101d86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	74 30                	je     80101dbe <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d94:	83 c2 14             	add    $0x14,%edx
80101d97:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9e:	8b 12                	mov    (%edx),%edx
80101da0:	83 ec 08             	sub    $0x8,%esp
80101da3:	50                   	push   %eax
80101da4:	52                   	push   %edx
80101da5:	e8 0c f8 ff ff       	call   801015b6 <bfree>
80101daa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db3:	83 c2 14             	add    $0x14,%edx
80101db6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbd:	00 
  for(i = 0; i < NDIRECT; i++){
80101dbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc6:	7e b5                	jle    80101d7d <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dd1:	85 c0                	test   %eax,%eax
80101dd3:	0f 84 aa 00 00 00    	je     80101e83 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 00                	mov    (%eax),%eax
80101de7:	83 ec 08             	sub    $0x8,%esp
80101dea:	52                   	push   %edx
80101deb:	50                   	push   %eax
80101dec:	e8 10 e4 ff ff       	call   80100201 <bread>
80101df1:	83 c4 10             	add    $0x10,%esp
80101df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dfa:	83 c0 5c             	add    $0x5c,%eax
80101dfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e00:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e07:	eb 3c                	jmp    80101e45 <itrunc+0xd7>
      if(a[j])
80101e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e16:	01 d0                	add    %edx,%eax
80101e18:	8b 00                	mov    (%eax),%eax
80101e1a:	85 c0                	test   %eax,%eax
80101e1c:	74 23                	je     80101e41 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2b:	01 d0                	add    %edx,%eax
80101e2d:	8b 00                	mov    (%eax),%eax
80101e2f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e32:	8b 12                	mov    (%edx),%edx
80101e34:	83 ec 08             	sub    $0x8,%esp
80101e37:	50                   	push   %eax
80101e38:	52                   	push   %edx
80101e39:	e8 78 f7 ff ff       	call   801015b6 <bfree>
80101e3e:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e41:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e48:	83 f8 7f             	cmp    $0x7f,%eax
80101e4b:	76 bc                	jbe    80101e09 <itrunc+0x9b>
    }
    brelse(bp);
80101e4d:	83 ec 0c             	sub    $0xc,%esp
80101e50:	ff 75 ec             	push   -0x14(%ebp)
80101e53:	e8 2b e4 ff ff       	call   80100283 <brelse>
80101e58:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e64:	8b 55 08             	mov    0x8(%ebp),%edx
80101e67:	8b 12                	mov    (%edx),%edx
80101e69:	83 ec 08             	sub    $0x8,%esp
80101e6c:	50                   	push   %eax
80101e6d:	52                   	push   %edx
80101e6e:	e8 43 f7 ff ff       	call   801015b6 <bfree>
80101e73:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e80:	00 00 00 
  }

  ip->size = 0;
80101e83:	8b 45 08             	mov    0x8(%ebp),%eax
80101e86:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e8d:	83 ec 0c             	sub    $0xc,%esp
80101e90:	ff 75 08             	push   0x8(%ebp)
80101e93:	e8 83 f9 ff ff       	call   8010181b <iupdate>
80101e98:	83 c4 10             	add    $0x10,%esp
}
80101e9b:	90                   	nop
80101e9c:	c9                   	leave  
80101e9d:	c3                   	ret    

80101e9e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e9e:	55                   	push   %ebp
80101e9f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 00                	mov    (%eax),%eax
80101ea6:	89 c2                	mov    %eax,%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	8b 50 04             	mov    0x4(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec4:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ece:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed1:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	8b 50 58             	mov    0x58(%eax),%edx
80101edb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ede:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ee1:	90                   	nop
80101ee2:	5d                   	pop    %ebp
80101ee3:	c3                   	ret    

80101ee4 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ee4:	55                   	push   %ebp
80101ee5:	89 e5                	mov    %esp,%ebp
80101ee7:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ef1:	66 83 f8 03          	cmp    $0x3,%ax
80101ef5:	75 5c                	jne    80101f53 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efe:	66 85 c0             	test   %ax,%ax
80101f01:	78 20                	js     80101f23 <readi+0x3f>
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0a:	66 83 f8 09          	cmp    $0x9,%ax
80101f0e:	7f 13                	jg     80101f23 <readi+0x3f>
80101f10:	8b 45 08             	mov    0x8(%ebp),%eax
80101f13:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f17:	98                   	cwtl   
80101f18:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f1f:	85 c0                	test   %eax,%eax
80101f21:	75 0a                	jne    80101f2d <readi+0x49>
      return -1;
80101f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f28:	e9 0a 01 00 00       	jmp    80102037 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f34:	98                   	cwtl   
80101f35:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f3c:	8b 55 14             	mov    0x14(%ebp),%edx
80101f3f:	83 ec 04             	sub    $0x4,%esp
80101f42:	52                   	push   %edx
80101f43:	ff 75 0c             	push   0xc(%ebp)
80101f46:	ff 75 08             	push   0x8(%ebp)
80101f49:	ff d0                	call   *%eax
80101f4b:	83 c4 10             	add    $0x10,%esp
80101f4e:	e9 e4 00 00 00       	jmp    80102037 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	8b 40 58             	mov    0x58(%eax),%eax
80101f59:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5c:	77 0d                	ja     80101f6b <readi+0x87>
80101f5e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f61:	8b 45 14             	mov    0x14(%ebp),%eax
80101f64:	01 d0                	add    %edx,%eax
80101f66:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f69:	76 0a                	jbe    80101f75 <readi+0x91>
    return -1;
80101f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f70:	e9 c2 00 00 00       	jmp    80102037 <readi+0x153>
  if(off + n > ip->size)
80101f75:	8b 55 10             	mov    0x10(%ebp),%edx
80101f78:	8b 45 14             	mov    0x14(%ebp),%eax
80101f7b:	01 c2                	add    %eax,%edx
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 40 58             	mov    0x58(%eax),%eax
80101f83:	39 c2                	cmp    %eax,%edx
80101f85:	76 0c                	jbe    80101f93 <readi+0xaf>
    n = ip->size - off;
80101f87:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8a:	8b 40 58             	mov    0x58(%eax),%eax
80101f8d:	2b 45 10             	sub    0x10(%ebp),%eax
80101f90:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f9a:	e9 89 00 00 00       	jmp    80102028 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f9f:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa2:	c1 e8 09             	shr    $0x9,%eax
80101fa5:	83 ec 08             	sub    $0x8,%esp
80101fa8:	50                   	push   %eax
80101fa9:	ff 75 08             	push   0x8(%ebp)
80101fac:	e8 9d fc ff ff       	call   80101c4e <bmap>
80101fb1:	83 c4 10             	add    $0x10,%esp
80101fb4:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb7:	8b 12                	mov    (%edx),%edx
80101fb9:	83 ec 08             	sub    $0x8,%esp
80101fbc:	50                   	push   %eax
80101fbd:	52                   	push   %edx
80101fbe:	e8 3e e2 ff ff       	call   80100201 <bread>
80101fc3:	83 c4 10             	add    $0x10,%esp
80101fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fcc:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd1:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd6:	29 c2                	sub    %eax,%edx
80101fd8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fdb:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fde:	39 c2                	cmp    %eax,%edx
80101fe0:	0f 46 c2             	cmovbe %edx,%eax
80101fe3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe9:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fec:	8b 45 10             	mov    0x10(%ebp),%eax
80101fef:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff4:	01 d0                	add    %edx,%eax
80101ff6:	83 ec 04             	sub    $0x4,%esp
80101ff9:	ff 75 ec             	push   -0x14(%ebp)
80101ffc:	50                   	push   %eax
80101ffd:	ff 75 0c             	push   0xc(%ebp)
80102000:	e8 49 2b 00 00       	call   80104b4e <memmove>
80102005:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102008:	83 ec 0c             	sub    $0xc,%esp
8010200b:	ff 75 f0             	push   -0x10(%ebp)
8010200e:	e8 70 e2 ff ff       	call   80100283 <brelse>
80102013:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 f4             	add    %eax,-0xc(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 10             	add    %eax,0x10(%ebp)
80102022:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102025:	01 45 0c             	add    %eax,0xc(%ebp)
80102028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010202b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202e:	0f 82 6b ff ff ff    	jb     80101f9f <readi+0xbb>
  }
  return n;
80102034:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102037:	c9                   	leave  
80102038:	c3                   	ret    

80102039 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102039:	55                   	push   %ebp
8010203a:	89 e5                	mov    %esp,%ebp
8010203c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102046:	66 83 f8 03          	cmp    $0x3,%ax
8010204a:	75 5c                	jne    801020a8 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102053:	66 85 c0             	test   %ax,%ax
80102056:	78 20                	js     80102078 <writei+0x3f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	66 83 f8 09          	cmp    $0x9,%ax
80102063:	7f 13                	jg     80102078 <writei+0x3f>
80102065:	8b 45 08             	mov    0x8(%ebp),%eax
80102068:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206c:	98                   	cwtl   
8010206d:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102074:	85 c0                	test   %eax,%eax
80102076:	75 0a                	jne    80102082 <writei+0x49>
      return -1;
80102078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010207d:	e9 3b 01 00 00       	jmp    801021bd <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102089:	98                   	cwtl   
8010208a:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102091:	8b 55 14             	mov    0x14(%ebp),%edx
80102094:	83 ec 04             	sub    $0x4,%esp
80102097:	52                   	push   %edx
80102098:	ff 75 0c             	push   0xc(%ebp)
8010209b:	ff 75 08             	push   0x8(%ebp)
8010209e:	ff d0                	call   *%eax
801020a0:	83 c4 10             	add    $0x10,%esp
801020a3:	e9 15 01 00 00       	jmp    801021bd <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a8:	8b 45 08             	mov    0x8(%ebp),%eax
801020ab:	8b 40 58             	mov    0x58(%eax),%eax
801020ae:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b1:	77 0d                	ja     801020c0 <writei+0x87>
801020b3:	8b 55 10             	mov    0x10(%ebp),%edx
801020b6:	8b 45 14             	mov    0x14(%ebp),%eax
801020b9:	01 d0                	add    %edx,%eax
801020bb:	39 45 10             	cmp    %eax,0x10(%ebp)
801020be:	76 0a                	jbe    801020ca <writei+0x91>
    return -1;
801020c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c5:	e9 f3 00 00 00       	jmp    801021bd <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020ca:	8b 55 10             	mov    0x10(%ebp),%edx
801020cd:	8b 45 14             	mov    0x14(%ebp),%eax
801020d0:	01 d0                	add    %edx,%eax
801020d2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d7:	76 0a                	jbe    801020e3 <writei+0xaa>
    return -1;
801020d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020de:	e9 da 00 00 00       	jmp    801021bd <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ea:	e9 97 00 00 00       	jmp    80102186 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020ef:	8b 45 10             	mov    0x10(%ebp),%eax
801020f2:	c1 e8 09             	shr    $0x9,%eax
801020f5:	83 ec 08             	sub    $0x8,%esp
801020f8:	50                   	push   %eax
801020f9:	ff 75 08             	push   0x8(%ebp)
801020fc:	e8 4d fb ff ff       	call   80101c4e <bmap>
80102101:	83 c4 10             	add    $0x10,%esp
80102104:	8b 55 08             	mov    0x8(%ebp),%edx
80102107:	8b 12                	mov    (%edx),%edx
80102109:	83 ec 08             	sub    $0x8,%esp
8010210c:	50                   	push   %eax
8010210d:	52                   	push   %edx
8010210e:	e8 ee e0 ff ff       	call   80100201 <bread>
80102113:	83 c4 10             	add    $0x10,%esp
80102116:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102119:	8b 45 10             	mov    0x10(%ebp),%eax
8010211c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102121:	ba 00 02 00 00       	mov    $0x200,%edx
80102126:	29 c2                	sub    %eax,%edx
80102128:	8b 45 14             	mov    0x14(%ebp),%eax
8010212b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010212e:	39 c2                	cmp    %eax,%edx
80102130:	0f 46 c2             	cmovbe %edx,%eax
80102133:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102139:	8d 50 5c             	lea    0x5c(%eax),%edx
8010213c:	8b 45 10             	mov    0x10(%ebp),%eax
8010213f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102144:	01 d0                	add    %edx,%eax
80102146:	83 ec 04             	sub    $0x4,%esp
80102149:	ff 75 ec             	push   -0x14(%ebp)
8010214c:	ff 75 0c             	push   0xc(%ebp)
8010214f:	50                   	push   %eax
80102150:	e8 f9 29 00 00       	call   80104b4e <memmove>
80102155:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 11 00 00       	call   80103283 <log_write>
80102163:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	ff 75 f0             	push   -0x10(%ebp)
8010216c:	e8 12 e1 ff ff       	call   80100283 <brelse>
80102171:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 f4             	add    %eax,-0xc(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 10             	add    %eax,0x10(%ebp)
80102180:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102183:	01 45 0c             	add    %eax,0xc(%ebp)
80102186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102189:	3b 45 14             	cmp    0x14(%ebp),%eax
8010218c:	0f 82 5d ff ff ff    	jb     801020ef <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102192:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102196:	74 22                	je     801021ba <writei+0x181>
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
8010219b:	8b 40 58             	mov    0x58(%eax),%eax
8010219e:	39 45 10             	cmp    %eax,0x10(%ebp)
801021a1:	76 17                	jbe    801021ba <writei+0x181>
    ip->size = off;
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	8b 55 10             	mov    0x10(%ebp),%edx
801021a9:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021ac:	83 ec 0c             	sub    $0xc,%esp
801021af:	ff 75 08             	push   0x8(%ebp)
801021b2:	e8 64 f6 ff ff       	call   8010181b <iupdate>
801021b7:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ba:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021bd:	c9                   	leave  
801021be:	c3                   	ret    

801021bf <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021bf:	55                   	push   %ebp
801021c0:	89 e5                	mov    %esp,%ebp
801021c2:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021c5:	83 ec 04             	sub    $0x4,%esp
801021c8:	6a 0e                	push   $0xe
801021ca:	ff 75 0c             	push   0xc(%ebp)
801021cd:	ff 75 08             	push   0x8(%ebp)
801021d0:	e8 0f 2a 00 00       	call   80104be4 <strncmp>
801021d5:	83 c4 10             	add    $0x10,%esp
}
801021d8:	c9                   	leave  
801021d9:	c3                   	ret    

801021da <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021da:	55                   	push   %ebp
801021db:	89 e5                	mov    %esp,%ebp
801021dd:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021e0:	8b 45 08             	mov    0x8(%ebp),%eax
801021e3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e7:	66 83 f8 01          	cmp    $0x1,%ax
801021eb:	74 0d                	je     801021fa <dirlookup+0x20>
    panic("dirlookup not DIR");
801021ed:	83 ec 0c             	sub    $0xc,%esp
801021f0:	68 79 a3 10 80       	push   $0x8010a379
801021f5:	e8 c7 e3 ff ff       	call   801005c1 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102201:	eb 7b                	jmp    8010227e <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102203:	6a 10                	push   $0x10
80102205:	ff 75 f4             	push   -0xc(%ebp)
80102208:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010220b:	50                   	push   %eax
8010220c:	ff 75 08             	push   0x8(%ebp)
8010220f:	e8 d0 fc ff ff       	call   80101ee4 <readi>
80102214:	83 c4 10             	add    $0x10,%esp
80102217:	83 f8 10             	cmp    $0x10,%eax
8010221a:	74 0d                	je     80102229 <dirlookup+0x4f>
      panic("dirlookup read");
8010221c:	83 ec 0c             	sub    $0xc,%esp
8010221f:	68 8b a3 10 80       	push   $0x8010a38b
80102224:	e8 98 e3 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
80102229:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222d:	66 85 c0             	test   %ax,%ax
80102230:	74 47                	je     80102279 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102232:	83 ec 08             	sub    $0x8,%esp
80102235:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102238:	83 c0 02             	add    $0x2,%eax
8010223b:	50                   	push   %eax
8010223c:	ff 75 0c             	push   0xc(%ebp)
8010223f:	e8 7b ff ff ff       	call   801021bf <namecmp>
80102244:	83 c4 10             	add    $0x10,%esp
80102247:	85 c0                	test   %eax,%eax
80102249:	75 2f                	jne    8010227a <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010224b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010224f:	74 08                	je     80102259 <dirlookup+0x7f>
        *poff = off;
80102251:	8b 45 10             	mov    0x10(%ebp),%eax
80102254:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102257:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102259:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010225d:	0f b7 c0             	movzwl %ax,%eax
80102260:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	8b 00                	mov    (%eax),%eax
80102268:	83 ec 08             	sub    $0x8,%esp
8010226b:	ff 75 f0             	push   -0x10(%ebp)
8010226e:	50                   	push   %eax
8010226f:	e8 68 f6 ff ff       	call   801018dc <iget>
80102274:	83 c4 10             	add    $0x10,%esp
80102277:	eb 19                	jmp    80102292 <dirlookup+0xb8>
      continue;
80102279:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010227a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010227e:	8b 45 08             	mov    0x8(%ebp),%eax
80102281:	8b 40 58             	mov    0x58(%eax),%eax
80102284:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102287:	0f 82 76 ff ff ff    	jb     80102203 <dirlookup+0x29>
    }
  }

  return 0;
8010228d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102292:	c9                   	leave  
80102293:	c3                   	ret    

80102294 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102294:	55                   	push   %ebp
80102295:	89 e5                	mov    %esp,%ebp
80102297:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010229a:	83 ec 04             	sub    $0x4,%esp
8010229d:	6a 00                	push   $0x0
8010229f:	ff 75 0c             	push   0xc(%ebp)
801022a2:	ff 75 08             	push   0x8(%ebp)
801022a5:	e8 30 ff ff ff       	call   801021da <dirlookup>
801022aa:	83 c4 10             	add    $0x10,%esp
801022ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022b4:	74 18                	je     801022ce <dirlink+0x3a>
    iput(ip);
801022b6:	83 ec 0c             	sub    $0xc,%esp
801022b9:	ff 75 f0             	push   -0x10(%ebp)
801022bc:	e8 98 f8 ff ff       	call   80101b59 <iput>
801022c1:	83 c4 10             	add    $0x10,%esp
    return -1;
801022c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c9:	e9 9c 00 00 00       	jmp    8010236a <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d5:	eb 39                	jmp    80102310 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022da:	6a 10                	push   $0x10
801022dc:	50                   	push   %eax
801022dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e0:	50                   	push   %eax
801022e1:	ff 75 08             	push   0x8(%ebp)
801022e4:	e8 fb fb ff ff       	call   80101ee4 <readi>
801022e9:	83 c4 10             	add    $0x10,%esp
801022ec:	83 f8 10             	cmp    $0x10,%eax
801022ef:	74 0d                	je     801022fe <dirlink+0x6a>
      panic("dirlink read");
801022f1:	83 ec 0c             	sub    $0xc,%esp
801022f4:	68 9a a3 10 80       	push   $0x8010a39a
801022f9:	e8 c3 e2 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
801022fe:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102302:	66 85 c0             	test   %ax,%ax
80102305:	74 18                	je     8010231f <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230a:	83 c0 10             	add    $0x10,%eax
8010230d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102310:	8b 45 08             	mov    0x8(%ebp),%eax
80102313:	8b 50 58             	mov    0x58(%eax),%edx
80102316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102319:	39 c2                	cmp    %eax,%edx
8010231b:	77 ba                	ja     801022d7 <dirlink+0x43>
8010231d:	eb 01                	jmp    80102320 <dirlink+0x8c>
      break;
8010231f:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102320:	83 ec 04             	sub    $0x4,%esp
80102323:	6a 0e                	push   $0xe
80102325:	ff 75 0c             	push   0xc(%ebp)
80102328:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232b:	83 c0 02             	add    $0x2,%eax
8010232e:	50                   	push   %eax
8010232f:	e8 06 29 00 00       	call   80104c3a <strncpy>
80102334:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102337:	8b 45 10             	mov    0x10(%ebp),%eax
8010233a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010233e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102341:	6a 10                	push   $0x10
80102343:	50                   	push   %eax
80102344:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102347:	50                   	push   %eax
80102348:	ff 75 08             	push   0x8(%ebp)
8010234b:	e8 e9 fc ff ff       	call   80102039 <writei>
80102350:	83 c4 10             	add    $0x10,%esp
80102353:	83 f8 10             	cmp    $0x10,%eax
80102356:	74 0d                	je     80102365 <dirlink+0xd1>
    panic("dirlink");
80102358:	83 ec 0c             	sub    $0xc,%esp
8010235b:	68 a7 a3 10 80       	push   $0x8010a3a7
80102360:	e8 5c e2 ff ff       	call   801005c1 <panic>

  return 0;
80102365:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010236a:	c9                   	leave  
8010236b:	c3                   	ret    

8010236c <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010236c:	55                   	push   %ebp
8010236d:	89 e5                	mov    %esp,%ebp
8010236f:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102372:	eb 04                	jmp    80102378 <skipelem+0xc>
    path++;
80102374:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102378:	8b 45 08             	mov    0x8(%ebp),%eax
8010237b:	0f b6 00             	movzbl (%eax),%eax
8010237e:	3c 2f                	cmp    $0x2f,%al
80102380:	74 f2                	je     80102374 <skipelem+0x8>
  if(*path == 0)
80102382:	8b 45 08             	mov    0x8(%ebp),%eax
80102385:	0f b6 00             	movzbl (%eax),%eax
80102388:	84 c0                	test   %al,%al
8010238a:	75 07                	jne    80102393 <skipelem+0x27>
    return 0;
8010238c:	b8 00 00 00 00       	mov    $0x0,%eax
80102391:	eb 77                	jmp    8010240a <skipelem+0x9e>
  s = path;
80102393:	8b 45 08             	mov    0x8(%ebp),%eax
80102396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102399:	eb 04                	jmp    8010239f <skipelem+0x33>
    path++;
8010239b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	0f b6 00             	movzbl (%eax),%eax
801023a5:	3c 2f                	cmp    $0x2f,%al
801023a7:	74 0a                	je     801023b3 <skipelem+0x47>
801023a9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ac:	0f b6 00             	movzbl (%eax),%eax
801023af:	84 c0                	test   %al,%al
801023b1:	75 e8                	jne    8010239b <skipelem+0x2f>
  len = path - s;
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023bc:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023c0:	7e 15                	jle    801023d7 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	6a 0e                	push   $0xe
801023c7:	ff 75 f4             	push   -0xc(%ebp)
801023ca:	ff 75 0c             	push   0xc(%ebp)
801023cd:	e8 7c 27 00 00       	call   80104b4e <memmove>
801023d2:	83 c4 10             	add    $0x10,%esp
801023d5:	eb 26                	jmp    801023fd <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023da:	83 ec 04             	sub    $0x4,%esp
801023dd:	50                   	push   %eax
801023de:	ff 75 f4             	push   -0xc(%ebp)
801023e1:	ff 75 0c             	push   0xc(%ebp)
801023e4:	e8 65 27 00 00       	call   80104b4e <memmove>
801023e9:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f2:	01 d0                	add    %edx,%eax
801023f4:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f7:	eb 04                	jmp    801023fd <skipelem+0x91>
    path++;
801023f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	0f b6 00             	movzbl (%eax),%eax
80102403:	3c 2f                	cmp    $0x2f,%al
80102405:	74 f2                	je     801023f9 <skipelem+0x8d>
  return path;
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010240a:	c9                   	leave  
8010240b:	c3                   	ret    

8010240c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010240c:	55                   	push   %ebp
8010240d:	89 e5                	mov    %esp,%ebp
8010240f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102412:	8b 45 08             	mov    0x8(%ebp),%eax
80102415:	0f b6 00             	movzbl (%eax),%eax
80102418:	3c 2f                	cmp    $0x2f,%al
8010241a:	75 17                	jne    80102433 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010241c:	83 ec 08             	sub    $0x8,%esp
8010241f:	6a 01                	push   $0x1
80102421:	6a 01                	push   $0x1
80102423:	e8 b4 f4 ff ff       	call   801018dc <iget>
80102428:	83 c4 10             	add    $0x10,%esp
8010242b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242e:	e9 ba 00 00 00       	jmp    801024ed <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102433:	e8 06 16 00 00       	call   80103a3e <myproc>
80102438:	8b 40 68             	mov    0x68(%eax),%eax
8010243b:	83 ec 0c             	sub    $0xc,%esp
8010243e:	50                   	push   %eax
8010243f:	e8 7a f5 ff ff       	call   801019be <idup>
80102444:	83 c4 10             	add    $0x10,%esp
80102447:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010244a:	e9 9e 00 00 00       	jmp    801024ed <namex+0xe1>
    ilock(ip);
8010244f:	83 ec 0c             	sub    $0xc,%esp
80102452:	ff 75 f4             	push   -0xc(%ebp)
80102455:	e8 9e f5 ff ff       	call   801019f8 <ilock>
8010245a:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102460:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102464:	66 83 f8 01          	cmp    $0x1,%ax
80102468:	74 18                	je     80102482 <namex+0x76>
      iunlockput(ip);
8010246a:	83 ec 0c             	sub    $0xc,%esp
8010246d:	ff 75 f4             	push   -0xc(%ebp)
80102470:	e8 b4 f7 ff ff       	call   80101c29 <iunlockput>
80102475:	83 c4 10             	add    $0x10,%esp
      return 0;
80102478:	b8 00 00 00 00       	mov    $0x0,%eax
8010247d:	e9 a7 00 00 00       	jmp    80102529 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102482:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102486:	74 20                	je     801024a8 <namex+0x9c>
80102488:	8b 45 08             	mov    0x8(%ebp),%eax
8010248b:	0f b6 00             	movzbl (%eax),%eax
8010248e:	84 c0                	test   %al,%al
80102490:	75 16                	jne    801024a8 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102492:	83 ec 0c             	sub    $0xc,%esp
80102495:	ff 75 f4             	push   -0xc(%ebp)
80102498:	e8 6e f6 ff ff       	call   80101b0b <iunlock>
8010249d:	83 c4 10             	add    $0x10,%esp
      return ip;
801024a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a3:	e9 81 00 00 00       	jmp    80102529 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a8:	83 ec 04             	sub    $0x4,%esp
801024ab:	6a 00                	push   $0x0
801024ad:	ff 75 10             	push   0x10(%ebp)
801024b0:	ff 75 f4             	push   -0xc(%ebp)
801024b3:	e8 22 fd ff ff       	call   801021da <dirlookup>
801024b8:	83 c4 10             	add    $0x10,%esp
801024bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c2:	75 15                	jne    801024d9 <namex+0xcd>
      iunlockput(ip);
801024c4:	83 ec 0c             	sub    $0xc,%esp
801024c7:	ff 75 f4             	push   -0xc(%ebp)
801024ca:	e8 5a f7 ff ff       	call   80101c29 <iunlockput>
801024cf:	83 c4 10             	add    $0x10,%esp
      return 0;
801024d2:	b8 00 00 00 00       	mov    $0x0,%eax
801024d7:	eb 50                	jmp    80102529 <namex+0x11d>
    }
    iunlockput(ip);
801024d9:	83 ec 0c             	sub    $0xc,%esp
801024dc:	ff 75 f4             	push   -0xc(%ebp)
801024df:	e8 45 f7 ff ff       	call   80101c29 <iunlockput>
801024e4:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024ed:	83 ec 08             	sub    $0x8,%esp
801024f0:	ff 75 10             	push   0x10(%ebp)
801024f3:	ff 75 08             	push   0x8(%ebp)
801024f6:	e8 71 fe ff ff       	call   8010236c <skipelem>
801024fb:	83 c4 10             	add    $0x10,%esp
801024fe:	89 45 08             	mov    %eax,0x8(%ebp)
80102501:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102505:	0f 85 44 ff ff ff    	jne    8010244f <namex+0x43>
  }
  if(nameiparent){
8010250b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250f:	74 15                	je     80102526 <namex+0x11a>
    iput(ip);
80102511:	83 ec 0c             	sub    $0xc,%esp
80102514:	ff 75 f4             	push   -0xc(%ebp)
80102517:	e8 3d f6 ff ff       	call   80101b59 <iput>
8010251c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251f:	b8 00 00 00 00       	mov    $0x0,%eax
80102524:	eb 03                	jmp    80102529 <namex+0x11d>
  }
  return ip;
80102526:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102529:	c9                   	leave  
8010252a:	c3                   	ret    

8010252b <namei>:

struct inode*
namei(char *path)
{
8010252b:	55                   	push   %ebp
8010252c:	89 e5                	mov    %esp,%ebp
8010252e:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102531:	83 ec 04             	sub    $0x4,%esp
80102534:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102537:	50                   	push   %eax
80102538:	6a 00                	push   $0x0
8010253a:	ff 75 08             	push   0x8(%ebp)
8010253d:	e8 ca fe ff ff       	call   8010240c <namex>
80102542:	83 c4 10             	add    $0x10,%esp
}
80102545:	c9                   	leave  
80102546:	c3                   	ret    

80102547 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102547:	55                   	push   %ebp
80102548:	89 e5                	mov    %esp,%ebp
8010254a:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254d:	83 ec 04             	sub    $0x4,%esp
80102550:	ff 75 0c             	push   0xc(%ebp)
80102553:	6a 01                	push   $0x1
80102555:	ff 75 08             	push   0x8(%ebp)
80102558:	e8 af fe ff ff       	call   8010240c <namex>
8010255d:	83 c4 10             	add    $0x10,%esp
}
80102560:	c9                   	leave  
80102561:	c3                   	ret    

80102562 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102562:	55                   	push   %ebp
80102563:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102565:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256a:	8b 55 08             	mov    0x8(%ebp),%edx
8010256d:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010256f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102574:	8b 40 10             	mov    0x10(%eax),%eax
}
80102577:	5d                   	pop    %ebp
80102578:	c3                   	ret    

80102579 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102579:	55                   	push   %ebp
8010257a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010257c:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102581:	8b 55 08             	mov    0x8(%ebp),%edx
80102584:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102586:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010258b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010258e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102591:	90                   	nop
80102592:	5d                   	pop    %ebp
80102593:	c3                   	ret    

80102594 <ioapicinit>:

void
ioapicinit(void)
{
80102594:	55                   	push   %ebp
80102595:	89 e5                	mov    %esp,%ebp
80102597:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010259a:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
801025a1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801025a4:	6a 01                	push   $0x1
801025a6:	e8 b7 ff ff ff       	call   80102562 <ioapicread>
801025ab:	83 c4 04             	add    $0x4,%esp
801025ae:	c1 e8 10             	shr    $0x10,%eax
801025b1:	25 ff 00 00 00       	and    $0xff,%eax
801025b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b9:	6a 00                	push   $0x0
801025bb:	e8 a2 ff ff ff       	call   80102562 <ioapicread>
801025c0:	83 c4 04             	add    $0x4,%esp
801025c3:	c1 e8 18             	shr    $0x18,%eax
801025c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c9:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025d0:	0f b6 c0             	movzbl %al,%eax
801025d3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d6:	74 10                	je     801025e8 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d8:	83 ec 0c             	sub    $0xc,%esp
801025db:	68 b0 a3 10 80       	push   $0x8010a3b0
801025e0:	e8 0f de ff ff       	call   801003f4 <cprintf>
801025e5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025ef:	eb 3f                	jmp    80102630 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f4:	83 c0 20             	add    $0x20,%eax
801025f7:	0d 00 00 01 00       	or     $0x10000,%eax
801025fc:	89 c2                	mov    %eax,%edx
801025fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102601:	83 c0 08             	add    $0x8,%eax
80102604:	01 c0                	add    %eax,%eax
80102606:	83 ec 08             	sub    $0x8,%esp
80102609:	52                   	push   %edx
8010260a:	50                   	push   %eax
8010260b:	e8 69 ff ff ff       	call   80102579 <ioapicwrite>
80102610:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102616:	83 c0 08             	add    $0x8,%eax
80102619:	01 c0                	add    %eax,%eax
8010261b:	83 c0 01             	add    $0x1,%eax
8010261e:	83 ec 08             	sub    $0x8,%esp
80102621:	6a 00                	push   $0x0
80102623:	50                   	push   %eax
80102624:	e8 50 ff ff ff       	call   80102579 <ioapicwrite>
80102629:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010262c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102633:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102636:	7e b9                	jle    801025f1 <ioapicinit+0x5d>
  }
}
80102638:	90                   	nop
80102639:	90                   	nop
8010263a:	c9                   	leave  
8010263b:	c3                   	ret    

8010263c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010263c:	55                   	push   %ebp
8010263d:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010263f:	8b 45 08             	mov    0x8(%ebp),%eax
80102642:	83 c0 20             	add    $0x20,%eax
80102645:	89 c2                	mov    %eax,%edx
80102647:	8b 45 08             	mov    0x8(%ebp),%eax
8010264a:	83 c0 08             	add    $0x8,%eax
8010264d:	01 c0                	add    %eax,%eax
8010264f:	52                   	push   %edx
80102650:	50                   	push   %eax
80102651:	e8 23 ff ff ff       	call   80102579 <ioapicwrite>
80102656:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010265c:	c1 e0 18             	shl    $0x18,%eax
8010265f:	89 c2                	mov    %eax,%edx
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	83 c0 08             	add    $0x8,%eax
80102667:	01 c0                	add    %eax,%eax
80102669:	83 c0 01             	add    $0x1,%eax
8010266c:	52                   	push   %edx
8010266d:	50                   	push   %eax
8010266e:	e8 06 ff ff ff       	call   80102579 <ioapicwrite>
80102673:	83 c4 08             	add    $0x8,%esp
}
80102676:	90                   	nop
80102677:	c9                   	leave  
80102678:	c3                   	ret    

80102679 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102679:	55                   	push   %ebp
8010267a:	89 e5                	mov    %esp,%ebp
8010267c:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010267f:	83 ec 08             	sub    $0x8,%esp
80102682:	68 e2 a3 10 80       	push   $0x8010a3e2
80102687:	68 c0 40 19 80       	push   $0x801940c0
8010268c:	e8 66 21 00 00       	call   801047f7 <initlock>
80102691:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102694:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010269b:	00 00 00 
  freerange(vstart, vend);
8010269e:	83 ec 08             	sub    $0x8,%esp
801026a1:	ff 75 0c             	push   0xc(%ebp)
801026a4:	ff 75 08             	push   0x8(%ebp)
801026a7:	e8 2a 00 00 00       	call   801026d6 <freerange>
801026ac:	83 c4 10             	add    $0x10,%esp
}
801026af:	90                   	nop
801026b0:	c9                   	leave  
801026b1:	c3                   	ret    

801026b2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026b2:	55                   	push   %ebp
801026b3:	89 e5                	mov    %esp,%ebp
801026b5:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b8:	83 ec 08             	sub    $0x8,%esp
801026bb:	ff 75 0c             	push   0xc(%ebp)
801026be:	ff 75 08             	push   0x8(%ebp)
801026c1:	e8 10 00 00 00       	call   801026d6 <freerange>
801026c6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c9:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026d0:	00 00 00 
}
801026d3:	90                   	nop
801026d4:	c9                   	leave  
801026d5:	c3                   	ret    

801026d6 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d6:	55                   	push   %ebp
801026d7:	89 e5                	mov    %esp,%ebp
801026d9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026dc:	8b 45 08             	mov    0x8(%ebp),%eax
801026df:	05 ff 0f 00 00       	add    $0xfff,%eax
801026e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ec:	eb 15                	jmp    80102703 <freerange+0x2d>
    kfree(p);
801026ee:	83 ec 0c             	sub    $0xc,%esp
801026f1:	ff 75 f4             	push   -0xc(%ebp)
801026f4:	e8 1b 00 00 00       	call   80102714 <kfree>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026fc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102706:	05 00 10 00 00       	add    $0x1000,%eax
8010270b:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010270e:	73 de                	jae    801026ee <freerange+0x18>
}
80102710:	90                   	nop
80102711:	90                   	nop
80102712:	c9                   	leave  
80102713:	c3                   	ret    

80102714 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102714:	55                   	push   %ebp
80102715:	89 e5                	mov    %esp,%ebp
80102717:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010271a:	8b 45 08             	mov    0x8(%ebp),%eax
8010271d:	25 ff 0f 00 00       	and    $0xfff,%eax
80102722:	85 c0                	test   %eax,%eax
80102724:	75 18                	jne    8010273e <kfree+0x2a>
80102726:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
8010272d:	72 0f                	jb     8010273e <kfree+0x2a>
8010272f:	8b 45 08             	mov    0x8(%ebp),%eax
80102732:	05 00 00 00 80       	add    $0x80000000,%eax
80102737:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010273c:	76 0d                	jbe    8010274b <kfree+0x37>
    panic("kfree");
8010273e:	83 ec 0c             	sub    $0xc,%esp
80102741:	68 e7 a3 10 80       	push   $0x8010a3e7
80102746:	e8 76 de ff ff       	call   801005c1 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010274b:	83 ec 04             	sub    $0x4,%esp
8010274e:	68 00 10 00 00       	push   $0x1000
80102753:	6a 01                	push   $0x1
80102755:	ff 75 08             	push   0x8(%ebp)
80102758:	e8 32 23 00 00       	call   80104a8f <memset>
8010275d:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102760:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102765:	85 c0                	test   %eax,%eax
80102767:	74 10                	je     80102779 <kfree+0x65>
    acquire(&kmem.lock);
80102769:	83 ec 0c             	sub    $0xc,%esp
8010276c:	68 c0 40 19 80       	push   $0x801940c0
80102771:	e8 a3 20 00 00       	call   80104819 <acquire>
80102776:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102779:	8b 45 08             	mov    0x8(%ebp),%eax
8010277c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010277f:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102788:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010278a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278d:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102792:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102797:	85 c0                	test   %eax,%eax
80102799:	74 10                	je     801027ab <kfree+0x97>
    release(&kmem.lock);
8010279b:	83 ec 0c             	sub    $0xc,%esp
8010279e:	68 c0 40 19 80       	push   $0x801940c0
801027a3:	e8 df 20 00 00       	call   80104887 <release>
801027a8:	83 c4 10             	add    $0x10,%esp
}
801027ab:	90                   	nop
801027ac:	c9                   	leave  
801027ad:	c3                   	ret    

801027ae <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027ae:	55                   	push   %ebp
801027af:	89 e5                	mov    %esp,%ebp
801027b1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027b4:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b9:	85 c0                	test   %eax,%eax
801027bb:	74 10                	je     801027cd <kalloc+0x1f>
    acquire(&kmem.lock);
801027bd:	83 ec 0c             	sub    $0xc,%esp
801027c0:	68 c0 40 19 80       	push   $0x801940c0
801027c5:	e8 4f 20 00 00       	call   80104819 <acquire>
801027ca:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027cd:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d9:	74 0a                	je     801027e5 <kalloc+0x37>
    kmem.freelist = r->next;
801027db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027de:	8b 00                	mov    (%eax),%eax
801027e0:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027e5:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ea:	85 c0                	test   %eax,%eax
801027ec:	74 10                	je     801027fe <kalloc+0x50>
    release(&kmem.lock);
801027ee:	83 ec 0c             	sub    $0xc,%esp
801027f1:	68 c0 40 19 80       	push   $0x801940c0
801027f6:	e8 8c 20 00 00       	call   80104887 <release>
801027fb:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102801:	c9                   	leave  
80102802:	c3                   	ret    

80102803 <inb>:
{
80102803:	55                   	push   %ebp
80102804:	89 e5                	mov    %esp,%ebp
80102806:	83 ec 14             	sub    $0x14,%esp
80102809:	8b 45 08             	mov    0x8(%ebp),%eax
8010280c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102810:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102814:	89 c2                	mov    %eax,%edx
80102816:	ec                   	in     (%dx),%al
80102817:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010281a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010281e:	c9                   	leave  
8010281f:	c3                   	ret    

80102820 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102820:	55                   	push   %ebp
80102821:	89 e5                	mov    %esp,%ebp
80102823:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102826:	6a 64                	push   $0x64
80102828:	e8 d6 ff ff ff       	call   80102803 <inb>
8010282d:	83 c4 04             	add    $0x4,%esp
80102830:	0f b6 c0             	movzbl %al,%eax
80102833:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102839:	83 e0 01             	and    $0x1,%eax
8010283c:	85 c0                	test   %eax,%eax
8010283e:	75 0a                	jne    8010284a <kbdgetc+0x2a>
    return -1;
80102840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102845:	e9 23 01 00 00       	jmp    8010296d <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010284a:	6a 60                	push   $0x60
8010284c:	e8 b2 ff ff ff       	call   80102803 <inb>
80102851:	83 c4 04             	add    $0x4,%esp
80102854:	0f b6 c0             	movzbl %al,%eax
80102857:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010285a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102861:	75 17                	jne    8010287a <kbdgetc+0x5a>
    shift |= E0ESC;
80102863:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102868:	83 c8 40             	or     $0x40,%eax
8010286b:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102870:	b8 00 00 00 00       	mov    $0x0,%eax
80102875:	e9 f3 00 00 00       	jmp    8010296d <kbdgetc+0x14d>
  } else if(data & 0x80){
8010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287d:	25 80 00 00 00       	and    $0x80,%eax
80102882:	85 c0                	test   %eax,%eax
80102884:	74 45                	je     801028cb <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102886:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010288b:	83 e0 40             	and    $0x40,%eax
8010288e:	85 c0                	test   %eax,%eax
80102890:	75 08                	jne    8010289a <kbdgetc+0x7a>
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	83 e0 7f             	and    $0x7f,%eax
80102898:	eb 03                	jmp    8010289d <kbdgetc+0x7d>
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801028a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028a3:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a8:	0f b6 00             	movzbl (%eax),%eax
801028ab:	83 c8 40             	or     $0x40,%eax
801028ae:	0f b6 c0             	movzbl %al,%eax
801028b1:	f7 d0                	not    %eax
801028b3:	89 c2                	mov    %eax,%edx
801028b5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ba:	21 d0                	and    %edx,%eax
801028bc:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028c1:	b8 00 00 00 00       	mov    $0x0,%eax
801028c6:	e9 a2 00 00 00       	jmp    8010296d <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028cb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d0:	83 e0 40             	and    $0x40,%eax
801028d3:	85 c0                	test   %eax,%eax
801028d5:	74 14                	je     801028eb <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d7:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028de:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028e3:	83 e0 bf             	and    $0xffffffbf,%eax
801028e6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028ee:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028f3:	0f b6 00             	movzbl (%eax),%eax
801028f6:	0f b6 d0             	movzbl %al,%edx
801028f9:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028fe:	09 d0                	or     %edx,%eax
80102900:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
80102905:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102908:	05 20 d1 10 80       	add    $0x8010d120,%eax
8010290d:	0f b6 00             	movzbl (%eax),%eax
80102910:	0f b6 d0             	movzbl %al,%edx
80102913:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102918:	31 d0                	xor    %edx,%eax
8010291a:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
8010291f:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102924:	83 e0 03             	and    $0x3,%eax
80102927:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
8010292e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102931:	01 d0                	add    %edx,%eax
80102933:	0f b6 00             	movzbl (%eax),%eax
80102936:	0f b6 c0             	movzbl %al,%eax
80102939:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010293c:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102941:	83 e0 08             	and    $0x8,%eax
80102944:	85 c0                	test   %eax,%eax
80102946:	74 22                	je     8010296a <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102948:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010294c:	76 0c                	jbe    8010295a <kbdgetc+0x13a>
8010294e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102952:	77 06                	ja     8010295a <kbdgetc+0x13a>
      c += 'A' - 'a';
80102954:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102958:	eb 10                	jmp    8010296a <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010295a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010295e:	76 0a                	jbe    8010296a <kbdgetc+0x14a>
80102960:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102964:	77 04                	ja     8010296a <kbdgetc+0x14a>
      c += 'a' - 'A';
80102966:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010296a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010296d:	c9                   	leave  
8010296e:	c3                   	ret    

8010296f <kbdintr>:

void
kbdintr(void)
{
8010296f:	55                   	push   %ebp
80102970:	89 e5                	mov    %esp,%ebp
80102972:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102975:	83 ec 0c             	sub    $0xc,%esp
80102978:	68 20 28 10 80       	push   $0x80102820
8010297d:	e8 6c de ff ff       	call   801007ee <consoleintr>
80102982:	83 c4 10             	add    $0x10,%esp
}
80102985:	90                   	nop
80102986:	c9                   	leave  
80102987:	c3                   	ret    

80102988 <inb>:
{
80102988:	55                   	push   %ebp
80102989:	89 e5                	mov    %esp,%ebp
8010298b:	83 ec 14             	sub    $0x14,%esp
8010298e:	8b 45 08             	mov    0x8(%ebp),%eax
80102991:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102995:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102999:	89 c2                	mov    %eax,%edx
8010299b:	ec                   	in     (%dx),%al
8010299c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010299f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801029a3:	c9                   	leave  
801029a4:	c3                   	ret    

801029a5 <outb>:
{
801029a5:	55                   	push   %ebp
801029a6:	89 e5                	mov    %esp,%ebp
801029a8:	83 ec 08             	sub    $0x8,%esp
801029ab:	8b 45 08             	mov    0x8(%ebp),%eax
801029ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801029b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029b5:	89 d0                	mov    %edx,%eax
801029b7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029be:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029c2:	ee                   	out    %al,(%dx)
}
801029c3:	90                   	nop
801029c4:	c9                   	leave  
801029c5:	c3                   	ret    

801029c6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029c6:	55                   	push   %ebp
801029c7:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c9:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029cf:	8b 45 08             	mov    0x8(%ebp),%eax
801029d2:	c1 e0 02             	shl    $0x2,%eax
801029d5:	01 c2                	add    %eax,%edx
801029d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801029da:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029dc:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e1:	83 c0 20             	add    $0x20,%eax
801029e4:	8b 00                	mov    (%eax),%eax
}
801029e6:	90                   	nop
801029e7:	5d                   	pop    %ebp
801029e8:	c3                   	ret    

801029e9 <lapicinit>:

void
lapicinit(void)
{
801029e9:	55                   	push   %ebp
801029ea:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029ec:	a1 00 41 19 80       	mov    0x80194100,%eax
801029f1:	85 c0                	test   %eax,%eax
801029f3:	0f 84 0c 01 00 00    	je     80102b05 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f9:	68 3f 01 00 00       	push   $0x13f
801029fe:	6a 3c                	push   $0x3c
80102a00:	e8 c1 ff ff ff       	call   801029c6 <lapicw>
80102a05:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102a08:	6a 0b                	push   $0xb
80102a0a:	68 f8 00 00 00       	push   $0xf8
80102a0f:	e8 b2 ff ff ff       	call   801029c6 <lapicw>
80102a14:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a17:	68 20 00 02 00       	push   $0x20020
80102a1c:	68 c8 00 00 00       	push   $0xc8
80102a21:	e8 a0 ff ff ff       	call   801029c6 <lapicw>
80102a26:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a29:	68 80 96 98 00       	push   $0x989680
80102a2e:	68 e0 00 00 00       	push   $0xe0
80102a33:	e8 8e ff ff ff       	call   801029c6 <lapicw>
80102a38:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a3b:	68 00 00 01 00       	push   $0x10000
80102a40:	68 d4 00 00 00       	push   $0xd4
80102a45:	e8 7c ff ff ff       	call   801029c6 <lapicw>
80102a4a:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a4d:	68 00 00 01 00       	push   $0x10000
80102a52:	68 d8 00 00 00       	push   $0xd8
80102a57:	e8 6a ff ff ff       	call   801029c6 <lapicw>
80102a5c:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a5f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a64:	83 c0 30             	add    $0x30,%eax
80102a67:	8b 00                	mov    (%eax),%eax
80102a69:	c1 e8 10             	shr    $0x10,%eax
80102a6c:	25 fc 00 00 00       	and    $0xfc,%eax
80102a71:	85 c0                	test   %eax,%eax
80102a73:	74 12                	je     80102a87 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a75:	68 00 00 01 00       	push   $0x10000
80102a7a:	68 d0 00 00 00       	push   $0xd0
80102a7f:	e8 42 ff ff ff       	call   801029c6 <lapicw>
80102a84:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a87:	6a 33                	push   $0x33
80102a89:	68 dc 00 00 00       	push   $0xdc
80102a8e:	e8 33 ff ff ff       	call   801029c6 <lapicw>
80102a93:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a96:	6a 00                	push   $0x0
80102a98:	68 a0 00 00 00       	push   $0xa0
80102a9d:	e8 24 ff ff ff       	call   801029c6 <lapicw>
80102aa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102aa5:	6a 00                	push   $0x0
80102aa7:	68 a0 00 00 00       	push   $0xa0
80102aac:	e8 15 ff ff ff       	call   801029c6 <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	6a 2c                	push   $0x2c
80102ab8:	e8 09 ff ff ff       	call   801029c6 <lapicw>
80102abd:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ac0:	6a 00                	push   $0x0
80102ac2:	68 c4 00 00 00       	push   $0xc4
80102ac7:	e8 fa fe ff ff       	call   801029c6 <lapicw>
80102acc:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102acf:	68 00 85 08 00       	push   $0x88500
80102ad4:	68 c0 00 00 00       	push   $0xc0
80102ad9:	e8 e8 fe ff ff       	call   801029c6 <lapicw>
80102ade:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ae1:	90                   	nop
80102ae2:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ae7:	05 00 03 00 00       	add    $0x300,%eax
80102aec:	8b 00                	mov    (%eax),%eax
80102aee:	25 00 10 00 00       	and    $0x1000,%eax
80102af3:	85 c0                	test   %eax,%eax
80102af5:	75 eb                	jne    80102ae2 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102af7:	6a 00                	push   $0x0
80102af9:	6a 20                	push   $0x20
80102afb:	e8 c6 fe ff ff       	call   801029c6 <lapicw>
80102b00:	83 c4 08             	add    $0x8,%esp
80102b03:	eb 01                	jmp    80102b06 <lapicinit+0x11d>
    return;
80102b05:	90                   	nop
}
80102b06:	c9                   	leave  
80102b07:	c3                   	ret    

80102b08 <lapicid>:

int
lapicid(void)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102b0b:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b10:	85 c0                	test   %eax,%eax
80102b12:	75 07                	jne    80102b1b <lapicid+0x13>
    return 0;
80102b14:	b8 00 00 00 00       	mov    $0x0,%eax
80102b19:	eb 0d                	jmp    80102b28 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b1b:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b20:	83 c0 20             	add    $0x20,%eax
80102b23:	8b 00                	mov    (%eax),%eax
80102b25:	c1 e8 18             	shr    $0x18,%eax
}
80102b28:	5d                   	pop    %ebp
80102b29:	c3                   	ret    

80102b2a <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b2a:	55                   	push   %ebp
80102b2b:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b2d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b32:	85 c0                	test   %eax,%eax
80102b34:	74 0c                	je     80102b42 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b36:	6a 00                	push   $0x0
80102b38:	6a 2c                	push   $0x2c
80102b3a:	e8 87 fe ff ff       	call   801029c6 <lapicw>
80102b3f:	83 c4 08             	add    $0x8,%esp
}
80102b42:	90                   	nop
80102b43:	c9                   	leave  
80102b44:	c3                   	ret    

80102b45 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b45:	55                   	push   %ebp
80102b46:	89 e5                	mov    %esp,%ebp
}
80102b48:	90                   	nop
80102b49:	5d                   	pop    %ebp
80102b4a:	c3                   	ret    

80102b4b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b4b:	55                   	push   %ebp
80102b4c:	89 e5                	mov    %esp,%ebp
80102b4e:	83 ec 14             	sub    $0x14,%esp
80102b51:	8b 45 08             	mov    0x8(%ebp),%eax
80102b54:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b57:	6a 0f                	push   $0xf
80102b59:	6a 70                	push   $0x70
80102b5b:	e8 45 fe ff ff       	call   801029a5 <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b63:	6a 0a                	push   $0xa
80102b65:	6a 71                	push   $0x71
80102b67:	e8 39 fe ff ff       	call   801029a5 <outb>
80102b6c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b6f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b79:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b81:	c1 e8 04             	shr    $0x4,%eax
80102b84:	89 c2                	mov    %eax,%edx
80102b86:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b89:	83 c0 02             	add    $0x2,%eax
80102b8c:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b8f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b93:	c1 e0 18             	shl    $0x18,%eax
80102b96:	50                   	push   %eax
80102b97:	68 c4 00 00 00       	push   $0xc4
80102b9c:	e8 25 fe ff ff       	call   801029c6 <lapicw>
80102ba1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102ba4:	68 00 c5 00 00       	push   $0xc500
80102ba9:	68 c0 00 00 00       	push   $0xc0
80102bae:	e8 13 fe ff ff       	call   801029c6 <lapicw>
80102bb3:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102bb6:	68 c8 00 00 00       	push   $0xc8
80102bbb:	e8 85 ff ff ff       	call   80102b45 <microdelay>
80102bc0:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bc3:	68 00 85 00 00       	push   $0x8500
80102bc8:	68 c0 00 00 00       	push   $0xc0
80102bcd:	e8 f4 fd ff ff       	call   801029c6 <lapicw>
80102bd2:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bd5:	6a 64                	push   $0x64
80102bd7:	e8 69 ff ff ff       	call   80102b45 <microdelay>
80102bdc:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bdf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102be6:	eb 3d                	jmp    80102c25 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102be8:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bec:	c1 e0 18             	shl    $0x18,%eax
80102bef:	50                   	push   %eax
80102bf0:	68 c4 00 00 00       	push   $0xc4
80102bf5:	e8 cc fd ff ff       	call   801029c6 <lapicw>
80102bfa:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c00:	c1 e8 0c             	shr    $0xc,%eax
80102c03:	80 cc 06             	or     $0x6,%ah
80102c06:	50                   	push   %eax
80102c07:	68 c0 00 00 00       	push   $0xc0
80102c0c:	e8 b5 fd ff ff       	call   801029c6 <lapicw>
80102c11:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c14:	68 c8 00 00 00       	push   $0xc8
80102c19:	e8 27 ff ff ff       	call   80102b45 <microdelay>
80102c1e:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c25:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c29:	7e bd                	jle    80102be8 <lapicstartap+0x9d>
  }
}
80102c2b:	90                   	nop
80102c2c:	90                   	nop
80102c2d:	c9                   	leave  
80102c2e:	c3                   	ret    

80102c2f <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c2f:	55                   	push   %ebp
80102c30:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c32:	8b 45 08             	mov    0x8(%ebp),%eax
80102c35:	0f b6 c0             	movzbl %al,%eax
80102c38:	50                   	push   %eax
80102c39:	6a 70                	push   $0x70
80102c3b:	e8 65 fd ff ff       	call   801029a5 <outb>
80102c40:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c43:	68 c8 00 00 00       	push   $0xc8
80102c48:	e8 f8 fe ff ff       	call   80102b45 <microdelay>
80102c4d:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c50:	6a 71                	push   $0x71
80102c52:	e8 31 fd ff ff       	call   80102988 <inb>
80102c57:	83 c4 04             	add    $0x4,%esp
80102c5a:	0f b6 c0             	movzbl %al,%eax
}
80102c5d:	c9                   	leave  
80102c5e:	c3                   	ret    

80102c5f <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c5f:	55                   	push   %ebp
80102c60:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c62:	6a 00                	push   $0x0
80102c64:	e8 c6 ff ff ff       	call   80102c2f <cmos_read>
80102c69:	83 c4 04             	add    $0x4,%esp
80102c6c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c6f:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c71:	6a 02                	push   $0x2
80102c73:	e8 b7 ff ff ff       	call   80102c2f <cmos_read>
80102c78:	83 c4 04             	add    $0x4,%esp
80102c7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c7e:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c81:	6a 04                	push   $0x4
80102c83:	e8 a7 ff ff ff       	call   80102c2f <cmos_read>
80102c88:	83 c4 04             	add    $0x4,%esp
80102c8b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c8e:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c91:	6a 07                	push   $0x7
80102c93:	e8 97 ff ff ff       	call   80102c2f <cmos_read>
80102c98:	83 c4 04             	add    $0x4,%esp
80102c9b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9e:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102ca1:	6a 08                	push   $0x8
80102ca3:	e8 87 ff ff ff       	call   80102c2f <cmos_read>
80102ca8:	83 c4 04             	add    $0x4,%esp
80102cab:	8b 55 08             	mov    0x8(%ebp),%edx
80102cae:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102cb1:	6a 09                	push   $0x9
80102cb3:	e8 77 ff ff ff       	call   80102c2f <cmos_read>
80102cb8:	83 c4 04             	add    $0x4,%esp
80102cbb:	8b 55 08             	mov    0x8(%ebp),%edx
80102cbe:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cc1:	90                   	nop
80102cc2:	c9                   	leave  
80102cc3:	c3                   	ret    

80102cc4 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cc4:	55                   	push   %ebp
80102cc5:	89 e5                	mov    %esp,%ebp
80102cc7:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cca:	6a 0b                	push   $0xb
80102ccc:	e8 5e ff ff ff       	call   80102c2f <cmos_read>
80102cd1:	83 c4 04             	add    $0x4,%esp
80102cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cda:	83 e0 04             	and    $0x4,%eax
80102cdd:	85 c0                	test   %eax,%eax
80102cdf:	0f 94 c0             	sete   %al
80102ce2:	0f b6 c0             	movzbl %al,%eax
80102ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102ce8:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102ceb:	50                   	push   %eax
80102cec:	e8 6e ff ff ff       	call   80102c5f <fill_rtcdate>
80102cf1:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cf4:	6a 0a                	push   $0xa
80102cf6:	e8 34 ff ff ff       	call   80102c2f <cmos_read>
80102cfb:	83 c4 04             	add    $0x4,%esp
80102cfe:	25 80 00 00 00       	and    $0x80,%eax
80102d03:	85 c0                	test   %eax,%eax
80102d05:	75 27                	jne    80102d2e <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102d07:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0a:	50                   	push   %eax
80102d0b:	e8 4f ff ff ff       	call   80102c5f <fill_rtcdate>
80102d10:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d13:	83 ec 04             	sub    $0x4,%esp
80102d16:	6a 18                	push   $0x18
80102d18:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d1b:	50                   	push   %eax
80102d1c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d1f:	50                   	push   %eax
80102d20:	e8 d1 1d 00 00       	call   80104af6 <memcmp>
80102d25:	83 c4 10             	add    $0x10,%esp
80102d28:	85 c0                	test   %eax,%eax
80102d2a:	74 05                	je     80102d31 <cmostime+0x6d>
80102d2c:	eb ba                	jmp    80102ce8 <cmostime+0x24>
        continue;
80102d2e:	90                   	nop
    fill_rtcdate(&t1);
80102d2f:	eb b7                	jmp    80102ce8 <cmostime+0x24>
      break;
80102d31:	90                   	nop
  }

  // convert
  if(bcd) {
80102d32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d36:	0f 84 b4 00 00 00    	je     80102df0 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d3f:	c1 e8 04             	shr    $0x4,%eax
80102d42:	89 c2                	mov    %eax,%edx
80102d44:	89 d0                	mov    %edx,%eax
80102d46:	c1 e0 02             	shl    $0x2,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	01 c0                	add    %eax,%eax
80102d4d:	89 c2                	mov    %eax,%edx
80102d4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d52:	83 e0 0f             	and    $0xf,%eax
80102d55:	01 d0                	add    %edx,%eax
80102d57:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d5d:	c1 e8 04             	shr    $0x4,%eax
80102d60:	89 c2                	mov    %eax,%edx
80102d62:	89 d0                	mov    %edx,%eax
80102d64:	c1 e0 02             	shl    $0x2,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	01 c0                	add    %eax,%eax
80102d6b:	89 c2                	mov    %eax,%edx
80102d6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d70:	83 e0 0f             	and    $0xf,%eax
80102d73:	01 d0                	add    %edx,%eax
80102d75:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d7b:	c1 e8 04             	shr    $0x4,%eax
80102d7e:	89 c2                	mov    %eax,%edx
80102d80:	89 d0                	mov    %edx,%eax
80102d82:	c1 e0 02             	shl    $0x2,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	01 c0                	add    %eax,%eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d8e:	83 e0 0f             	and    $0xf,%eax
80102d91:	01 d0                	add    %edx,%eax
80102d93:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d99:	c1 e8 04             	shr    $0x4,%eax
80102d9c:	89 c2                	mov    %eax,%edx
80102d9e:	89 d0                	mov    %edx,%eax
80102da0:	c1 e0 02             	shl    $0x2,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	01 c0                	add    %eax,%eax
80102da7:	89 c2                	mov    %eax,%edx
80102da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dac:	83 e0 0f             	and    $0xf,%eax
80102daf:	01 d0                	add    %edx,%eax
80102db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102db4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102db7:	c1 e8 04             	shr    $0x4,%eax
80102dba:	89 c2                	mov    %eax,%edx
80102dbc:	89 d0                	mov    %edx,%eax
80102dbe:	c1 e0 02             	shl    $0x2,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	01 c0                	add    %eax,%eax
80102dc5:	89 c2                	mov    %eax,%edx
80102dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dca:	83 e0 0f             	and    $0xf,%eax
80102dcd:	01 d0                	add    %edx,%eax
80102dcf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dd5:	c1 e8 04             	shr    $0x4,%eax
80102dd8:	89 c2                	mov    %eax,%edx
80102dda:	89 d0                	mov    %edx,%eax
80102ddc:	c1 e0 02             	shl    $0x2,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	01 c0                	add    %eax,%eax
80102de3:	89 c2                	mov    %eax,%edx
80102de5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102de8:	83 e0 0f             	and    $0xf,%eax
80102deb:	01 d0                	add    %edx,%eax
80102ded:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102df0:	8b 45 08             	mov    0x8(%ebp),%eax
80102df3:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102df6:	89 10                	mov    %edx,(%eax)
80102df8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dfb:	89 50 04             	mov    %edx,0x4(%eax)
80102dfe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102e01:	89 50 08             	mov    %edx,0x8(%eax)
80102e04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102e07:	89 50 0c             	mov    %edx,0xc(%eax)
80102e0a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e0d:	89 50 10             	mov    %edx,0x10(%eax)
80102e10:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e13:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	8b 40 14             	mov    0x14(%eax),%eax
80102e1c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e22:	8b 45 08             	mov    0x8(%ebp),%eax
80102e25:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e28:	90                   	nop
80102e29:	c9                   	leave  
80102e2a:	c3                   	ret    

80102e2b <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e2b:	55                   	push   %ebp
80102e2c:	89 e5                	mov    %esp,%ebp
80102e2e:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e31:	83 ec 08             	sub    $0x8,%esp
80102e34:	68 ed a3 10 80       	push   $0x8010a3ed
80102e39:	68 20 41 19 80       	push   $0x80194120
80102e3e:	e8 b4 19 00 00       	call   801047f7 <initlock>
80102e43:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e46:	83 ec 08             	sub    $0x8,%esp
80102e49:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e4c:	50                   	push   %eax
80102e4d:	ff 75 08             	push   0x8(%ebp)
80102e50:	e8 87 e5 ff ff       	call   801013dc <readsb>
80102e55:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e5b:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e63:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e68:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6b:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e70:	e8 b3 01 00 00       	call   80103028 <recover_from_log>
}
80102e75:	90                   	nop
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e78:	55                   	push   %ebp
80102e79:	89 e5                	mov    %esp,%ebp
80102e7b:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e85:	e9 95 00 00 00       	jmp    80102f1f <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e8a:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e93:	01 d0                	add    %edx,%eax
80102e95:	83 c0 01             	add    $0x1,%eax
80102e98:	89 c2                	mov    %eax,%edx
80102e9a:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e9f:	83 ec 08             	sub    $0x8,%esp
80102ea2:	52                   	push   %edx
80102ea3:	50                   	push   %eax
80102ea4:	e8 58 d3 ff ff       	call   80100201 <bread>
80102ea9:	83 c4 10             	add    $0x10,%esp
80102eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb2:	83 c0 10             	add    $0x10,%eax
80102eb5:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102ebc:	89 c2                	mov    %eax,%edx
80102ebe:	a1 64 41 19 80       	mov    0x80194164,%eax
80102ec3:	83 ec 08             	sub    $0x8,%esp
80102ec6:	52                   	push   %edx
80102ec7:	50                   	push   %eax
80102ec8:	e8 34 d3 ff ff       	call   80100201 <bread>
80102ecd:	83 c4 10             	add    $0x10,%esp
80102ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ed6:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102edc:	83 c0 5c             	add    $0x5c,%eax
80102edf:	83 ec 04             	sub    $0x4,%esp
80102ee2:	68 00 02 00 00       	push   $0x200
80102ee7:	52                   	push   %edx
80102ee8:	50                   	push   %eax
80102ee9:	e8 60 1c 00 00       	call   80104b4e <memmove>
80102eee:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 ec             	push   -0x14(%ebp)
80102ef7:	e8 3e d3 ff ff       	call   8010023a <bwrite>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 f0             	push   -0x10(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f0d:	83 ec 0c             	sub    $0xc,%esp
80102f10:	ff 75 ec             	push   -0x14(%ebp)
80102f13:	e8 6b d3 ff ff       	call   80100283 <brelse>
80102f18:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f1f:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f24:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f27:	0f 8c 5d ff ff ff    	jl     80102e8a <install_trans+0x12>
  }
}
80102f2d:	90                   	nop
80102f2e:	90                   	nop
80102f2f:	c9                   	leave  
80102f30:	c3                   	ret    

80102f31 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f31:	55                   	push   %ebp
80102f32:	89 e5                	mov    %esp,%ebp
80102f34:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f37:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f3c:	89 c2                	mov    %eax,%edx
80102f3e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f43:	83 ec 08             	sub    $0x8,%esp
80102f46:	52                   	push   %edx
80102f47:	50                   	push   %eax
80102f48:	e8 b4 d2 ff ff       	call   80100201 <bread>
80102f4d:	83 c4 10             	add    $0x10,%esp
80102f50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f56:	83 c0 5c             	add    $0x5c,%eax
80102f59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f5f:	8b 00                	mov    (%eax),%eax
80102f61:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f6d:	eb 1b                	jmp    80102f8a <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f75:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f7c:	83 c2 10             	add    $0x10,%edx
80102f7f:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f8a:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f8f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f92:	7c db                	jl     80102f6f <read_head+0x3e>
  }
  brelse(buf);
80102f94:	83 ec 0c             	sub    $0xc,%esp
80102f97:	ff 75 f0             	push   -0x10(%ebp)
80102f9a:	e8 e4 d2 ff ff       	call   80100283 <brelse>
80102f9f:	83 c4 10             	add    $0x10,%esp
}
80102fa2:	90                   	nop
80102fa3:	c9                   	leave  
80102fa4:	c3                   	ret    

80102fa5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102fa5:	55                   	push   %ebp
80102fa6:	89 e5                	mov    %esp,%ebp
80102fa8:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102fab:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fb0:	89 c2                	mov    %eax,%edx
80102fb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fb7:	83 ec 08             	sub    $0x8,%esp
80102fba:	52                   	push   %edx
80102fbb:	50                   	push   %eax
80102fbc:	e8 40 d2 ff ff       	call   80100201 <bread>
80102fc1:	83 c4 10             	add    $0x10,%esp
80102fc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fca:	83 c0 5c             	add    $0x5c,%eax
80102fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fd0:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fd9:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fe2:	eb 1b                	jmp    80102fff <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe7:	83 c0 10             	add    $0x10,%eax
80102fea:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ff7:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102ffb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fff:	a1 68 41 19 80       	mov    0x80194168,%eax
80103004:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103007:	7c db                	jl     80102fe4 <write_head+0x3f>
  }
  bwrite(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 26 d2 ff ff       	call   8010023a <bwrite>
80103014:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103017:	83 ec 0c             	sub    $0xc,%esp
8010301a:	ff 75 f0             	push   -0x10(%ebp)
8010301d:	e8 61 d2 ff ff       	call   80100283 <brelse>
80103022:	83 c4 10             	add    $0x10,%esp
}
80103025:	90                   	nop
80103026:	c9                   	leave  
80103027:	c3                   	ret    

80103028 <recover_from_log>:

static void
recover_from_log(void)
{
80103028:	55                   	push   %ebp
80103029:	89 e5                	mov    %esp,%ebp
8010302b:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010302e:	e8 fe fe ff ff       	call   80102f31 <read_head>
  install_trans(); // if committed, copy from log to disk
80103033:	e8 40 fe ff ff       	call   80102e78 <install_trans>
  log.lh.n = 0;
80103038:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010303f:	00 00 00 
  write_head(); // clear the log
80103042:	e8 5e ff ff ff       	call   80102fa5 <write_head>
}
80103047:	90                   	nop
80103048:	c9                   	leave  
80103049:	c3                   	ret    

8010304a <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010304a:	55                   	push   %ebp
8010304b:	89 e5                	mov    %esp,%ebp
8010304d:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103050:	83 ec 0c             	sub    $0xc,%esp
80103053:	68 20 41 19 80       	push   $0x80194120
80103058:	e8 bc 17 00 00       	call   80104819 <acquire>
8010305d:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103060:	a1 60 41 19 80       	mov    0x80194160,%eax
80103065:	85 c0                	test   %eax,%eax
80103067:	74 17                	je     80103080 <begin_op+0x36>
      sleep(&log, &log.lock);
80103069:	83 ec 08             	sub    $0x8,%esp
8010306c:	68 20 41 19 80       	push   $0x80194120
80103071:	68 20 41 19 80       	push   $0x80194120
80103076:	e8 6c 12 00 00       	call   801042e7 <sleep>
8010307b:	83 c4 10             	add    $0x10,%esp
8010307e:	eb e0                	jmp    80103060 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103080:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103086:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010308b:	8d 50 01             	lea    0x1(%eax),%edx
8010308e:	89 d0                	mov    %edx,%eax
80103090:	c1 e0 02             	shl    $0x2,%eax
80103093:	01 d0                	add    %edx,%eax
80103095:	01 c0                	add    %eax,%eax
80103097:	01 c8                	add    %ecx,%eax
80103099:	83 f8 1e             	cmp    $0x1e,%eax
8010309c:	7e 17                	jle    801030b5 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010309e:	83 ec 08             	sub    $0x8,%esp
801030a1:	68 20 41 19 80       	push   $0x80194120
801030a6:	68 20 41 19 80       	push   $0x80194120
801030ab:	e8 37 12 00 00       	call   801042e7 <sleep>
801030b0:	83 c4 10             	add    $0x10,%esp
801030b3:	eb ab                	jmp    80103060 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030b5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ba:	83 c0 01             	add    $0x1,%eax
801030bd:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030c2:	83 ec 0c             	sub    $0xc,%esp
801030c5:	68 20 41 19 80       	push   $0x80194120
801030ca:	e8 b8 17 00 00       	call   80104887 <release>
801030cf:	83 c4 10             	add    $0x10,%esp
      break;
801030d2:	90                   	nop
    }
  }
}
801030d3:	90                   	nop
801030d4:	c9                   	leave  
801030d5:	c3                   	ret    

801030d6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030d6:	55                   	push   %ebp
801030d7:	89 e5                	mov    %esp,%ebp
801030d9:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030e3:	83 ec 0c             	sub    $0xc,%esp
801030e6:	68 20 41 19 80       	push   $0x80194120
801030eb:	e8 29 17 00 00       	call   80104819 <acquire>
801030f0:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030f3:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030f8:	83 e8 01             	sub    $0x1,%eax
801030fb:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
80103100:	a1 60 41 19 80       	mov    0x80194160,%eax
80103105:	85 c0                	test   %eax,%eax
80103107:	74 0d                	je     80103116 <end_op+0x40>
    panic("log.committing");
80103109:	83 ec 0c             	sub    $0xc,%esp
8010310c:	68 f1 a3 10 80       	push   $0x8010a3f1
80103111:	e8 ab d4 ff ff       	call   801005c1 <panic>
  if(log.outstanding == 0){
80103116:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010311b:	85 c0                	test   %eax,%eax
8010311d:	75 13                	jne    80103132 <end_op+0x5c>
    do_commit = 1;
8010311f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103126:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010312d:	00 00 00 
80103130:	eb 10                	jmp    80103142 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103132:	83 ec 0c             	sub    $0xc,%esp
80103135:	68 20 41 19 80       	push   $0x80194120
8010313a:	e8 8f 12 00 00       	call   801043ce <wakeup>
8010313f:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103142:	83 ec 0c             	sub    $0xc,%esp
80103145:	68 20 41 19 80       	push   $0x80194120
8010314a:	e8 38 17 00 00       	call   80104887 <release>
8010314f:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103152:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103156:	74 3f                	je     80103197 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103158:	e8 f6 00 00 00       	call   80103253 <commit>
    acquire(&log.lock);
8010315d:	83 ec 0c             	sub    $0xc,%esp
80103160:	68 20 41 19 80       	push   $0x80194120
80103165:	e8 af 16 00 00       	call   80104819 <acquire>
8010316a:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010316d:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103174:	00 00 00 
    wakeup(&log);
80103177:	83 ec 0c             	sub    $0xc,%esp
8010317a:	68 20 41 19 80       	push   $0x80194120
8010317f:	e8 4a 12 00 00       	call   801043ce <wakeup>
80103184:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103187:	83 ec 0c             	sub    $0xc,%esp
8010318a:	68 20 41 19 80       	push   $0x80194120
8010318f:	e8 f3 16 00 00       	call   80104887 <release>
80103194:	83 c4 10             	add    $0x10,%esp
  }
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801031a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031a7:	e9 95 00 00 00       	jmp    80103241 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031ac:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b5:	01 d0                	add    %edx,%eax
801031b7:	83 c0 01             	add    $0x1,%eax
801031ba:	89 c2                	mov    %eax,%edx
801031bc:	a1 64 41 19 80       	mov    0x80194164,%eax
801031c1:	83 ec 08             	sub    $0x8,%esp
801031c4:	52                   	push   %edx
801031c5:	50                   	push   %eax
801031c6:	e8 36 d0 ff ff       	call   80100201 <bread>
801031cb:	83 c4 10             	add    $0x10,%esp
801031ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031d4:	83 c0 10             	add    $0x10,%eax
801031d7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031de:	89 c2                	mov    %eax,%edx
801031e0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031e5:	83 ec 08             	sub    $0x8,%esp
801031e8:	52                   	push   %edx
801031e9:	50                   	push   %eax
801031ea:	e8 12 d0 ff ff       	call   80100201 <bread>
801031ef:	83 c4 10             	add    $0x10,%esp
801031f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031f8:	8d 50 5c             	lea    0x5c(%eax),%edx
801031fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031fe:	83 c0 5c             	add    $0x5c,%eax
80103201:	83 ec 04             	sub    $0x4,%esp
80103204:	68 00 02 00 00       	push   $0x200
80103209:	52                   	push   %edx
8010320a:	50                   	push   %eax
8010320b:	e8 3e 19 00 00       	call   80104b4e <memmove>
80103210:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 f0             	push   -0x10(%ebp)
80103219:	e8 1c d0 ff ff       	call   8010023a <bwrite>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 ec             	push   -0x14(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010322f:	83 ec 0c             	sub    $0xc,%esp
80103232:	ff 75 f0             	push   -0x10(%ebp)
80103235:	e8 49 d0 ff ff       	call   80100283 <brelse>
8010323a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010323d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103241:	a1 68 41 19 80       	mov    0x80194168,%eax
80103246:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103249:	0f 8c 5d ff ff ff    	jl     801031ac <write_log+0x12>
  }
}
8010324f:	90                   	nop
80103250:	90                   	nop
80103251:	c9                   	leave  
80103252:	c3                   	ret    

80103253 <commit>:

static void
commit()
{
80103253:	55                   	push   %ebp
80103254:	89 e5                	mov    %esp,%ebp
80103256:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103259:	a1 68 41 19 80       	mov    0x80194168,%eax
8010325e:	85 c0                	test   %eax,%eax
80103260:	7e 1e                	jle    80103280 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103262:	e8 33 ff ff ff       	call   8010319a <write_log>
    write_head();    // Write header to disk -- the real commit
80103267:	e8 39 fd ff ff       	call   80102fa5 <write_head>
    install_trans(); // Now install writes to home locations
8010326c:	e8 07 fc ff ff       	call   80102e78 <install_trans>
    log.lh.n = 0;
80103271:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103278:	00 00 00 
    write_head();    // Erase the transaction from the log
8010327b:	e8 25 fd ff ff       	call   80102fa5 <write_head>
  }
}
80103280:	90                   	nop
80103281:	c9                   	leave  
80103282:	c3                   	ret    

80103283 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103283:	55                   	push   %ebp
80103284:	89 e5                	mov    %esp,%ebp
80103286:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103289:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328e:	83 f8 1d             	cmp    $0x1d,%eax
80103291:	7f 12                	jg     801032a5 <log_write+0x22>
80103293:	a1 68 41 19 80       	mov    0x80194168,%eax
80103298:	8b 15 58 41 19 80    	mov    0x80194158,%edx
8010329e:	83 ea 01             	sub    $0x1,%edx
801032a1:	39 d0                	cmp    %edx,%eax
801032a3:	7c 0d                	jl     801032b2 <log_write+0x2f>
    panic("too big a transaction");
801032a5:	83 ec 0c             	sub    $0xc,%esp
801032a8:	68 00 a4 10 80       	push   $0x8010a400
801032ad:	e8 0f d3 ff ff       	call   801005c1 <panic>
  if (log.outstanding < 1)
801032b2:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032b7:	85 c0                	test   %eax,%eax
801032b9:	7f 0d                	jg     801032c8 <log_write+0x45>
    panic("log_write outside of trans");
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 16 a4 10 80       	push   $0x8010a416
801032c3:	e8 f9 d2 ff ff       	call   801005c1 <panic>

  acquire(&log.lock);
801032c8:	83 ec 0c             	sub    $0xc,%esp
801032cb:	68 20 41 19 80       	push   $0x80194120
801032d0:	e8 44 15 00 00       	call   80104819 <acquire>
801032d5:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032df:	eb 1d                	jmp    801032fe <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e4:	83 c0 10             	add    $0x10,%eax
801032e7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032ee:	89 c2                	mov    %eax,%edx
801032f0:	8b 45 08             	mov    0x8(%ebp),%eax
801032f3:	8b 40 08             	mov    0x8(%eax),%eax
801032f6:	39 c2                	cmp    %eax,%edx
801032f8:	74 10                	je     8010330a <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032fe:	a1 68 41 19 80       	mov    0x80194168,%eax
80103303:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103306:	7c d9                	jl     801032e1 <log_write+0x5e>
80103308:	eb 01                	jmp    8010330b <log_write+0x88>
      break;
8010330a:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010330b:	8b 45 08             	mov    0x8(%ebp),%eax
8010330e:	8b 40 08             	mov    0x8(%eax),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103316:	83 c0 10             	add    $0x10,%eax
80103319:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103320:	a1 68 41 19 80       	mov    0x80194168,%eax
80103325:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103328:	75 0d                	jne    80103337 <log_write+0xb4>
    log.lh.n++;
8010332a:	a1 68 41 19 80       	mov    0x80194168,%eax
8010332f:	83 c0 01             	add    $0x1,%eax
80103332:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103337:	8b 45 08             	mov    0x8(%ebp),%eax
8010333a:	8b 00                	mov    (%eax),%eax
8010333c:	83 c8 04             	or     $0x4,%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	68 20 41 19 80       	push   $0x80194120
8010334e:	e8 34 15 00 00       	call   80104887 <release>
80103353:	83 c4 10             	add    $0x10,%esp
}
80103356:	90                   	nop
80103357:	c9                   	leave  
80103358:	c3                   	ret    

80103359 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103359:	55                   	push   %ebp
8010335a:	89 e5                	mov    %esp,%ebp
8010335c:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010335f:	8b 55 08             	mov    0x8(%ebp),%edx
80103362:	8b 45 0c             	mov    0xc(%ebp),%eax
80103365:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103368:	f0 87 02             	lock xchg %eax,(%edx)
8010336b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010336e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103371:	c9                   	leave  
80103372:	c3                   	ret    

80103373 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103373:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103377:	83 e4 f0             	and    $0xfffffff0,%esp
8010337a:	ff 71 fc             	push   -0x4(%ecx)
8010337d:	55                   	push   %ebp
8010337e:	89 e5                	mov    %esp,%ebp
80103380:	51                   	push   %ecx
80103381:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103384:	e8 66 4b 00 00       	call   80107eef <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103389:	83 ec 08             	sub    $0x8,%esp
8010338c:	68 00 00 40 80       	push   $0x80400000
80103391:	68 00 80 19 80       	push   $0x80198000
80103396:	e8 de f2 ff ff       	call   80102679 <kinit1>
8010339b:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010339e:	e8 7b 41 00 00       	call   8010751e <kvmalloc>
  mpinit_uefi();
801033a3:	e8 0d 49 00 00       	call   80107cb5 <mpinit_uefi>
  lapicinit();     // interrupt controller
801033a8:	e8 3c f6 ff ff       	call   801029e9 <lapicinit>
  seginit();       // segment descriptors
801033ad:	e8 04 3c 00 00       	call   80106fb6 <seginit>
  picinit();    // disable pic
801033b2:	e8 9d 01 00 00       	call   80103554 <picinit>
  ioapicinit();    // another interrupt controller
801033b7:	e8 d8 f1 ff ff       	call   80102594 <ioapicinit>
  consoleinit();   // console hardware
801033bc:	e8 56 d7 ff ff       	call   80100b17 <consoleinit>
  uartinit();      // serial port
801033c1:	e8 89 2f 00 00       	call   8010634f <uartinit>
  pinit();         // process table
801033c6:	e8 c2 05 00 00       	call   8010398d <pinit>
  tvinit();        // trap vectors
801033cb:	e8 a7 2a 00 00       	call   80105e77 <tvinit>
  binit();         // buffer cache
801033d0:	e8 91 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033d5:	e8 f3 db ff ff       	call   80100fcd <fileinit>
  ideinit();       // disk 
801033da:	e8 51 6c 00 00       	call   8010a030 <ideinit>
  startothers();   // start other processors
801033df:	e8 8a 00 00 00       	call   8010346e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033e4:	83 ec 08             	sub    $0x8,%esp
801033e7:	68 00 00 00 a0       	push   $0xa0000000
801033ec:	68 00 00 40 80       	push   $0x80400000
801033f1:	e8 bc f2 ff ff       	call   801026b2 <kinit2>
801033f6:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033f9:	e8 4a 4d 00 00       	call   80108148 <pci_init>
  arp_scan();
801033fe:	e8 81 5a 00 00       	call   80108e84 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103403:	e8 63 07 00 00       	call   80103b6b <userinit>

  mpmain();        // finish this processor's setup
80103408:	e8 1a 00 00 00       	call   80103427 <mpmain>

8010340d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010340d:	55                   	push   %ebp
8010340e:	89 e5                	mov    %esp,%ebp
80103410:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103413:	e8 1e 41 00 00       	call   80107536 <switchkvm>
  seginit();
80103418:	e8 99 3b 00 00       	call   80106fb6 <seginit>
  lapicinit();
8010341d:	e8 c7 f5 ff ff       	call   801029e9 <lapicinit>
  mpmain();
80103422:	e8 00 00 00 00       	call   80103427 <mpmain>

80103427 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103427:	55                   	push   %ebp
80103428:	89 e5                	mov    %esp,%ebp
8010342a:	53                   	push   %ebx
8010342b:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010342e:	e8 78 05 00 00       	call   801039ab <cpuid>
80103433:	89 c3                	mov    %eax,%ebx
80103435:	e8 71 05 00 00       	call   801039ab <cpuid>
8010343a:	83 ec 04             	sub    $0x4,%esp
8010343d:	53                   	push   %ebx
8010343e:	50                   	push   %eax
8010343f:	68 31 a4 10 80       	push   $0x8010a431
80103444:	e8 ab cf ff ff       	call   801003f4 <cprintf>
80103449:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010344c:	e8 9c 2b 00 00       	call   80105fed <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103451:	e8 70 05 00 00       	call   801039c6 <mycpu>
80103456:	05 a0 00 00 00       	add    $0xa0,%eax
8010345b:	83 ec 08             	sub    $0x8,%esp
8010345e:	6a 01                	push   $0x1
80103460:	50                   	push   %eax
80103461:	e8 f3 fe ff ff       	call   80103359 <xchg>
80103466:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103469:	e8 88 0c 00 00       	call   801040f6 <scheduler>

8010346e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010346e:	55                   	push   %ebp
8010346f:	89 e5                	mov    %esp,%ebp
80103471:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103474:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010347b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103480:	83 ec 04             	sub    $0x4,%esp
80103483:	50                   	push   %eax
80103484:	68 18 f5 10 80       	push   $0x8010f518
80103489:	ff 75 f0             	push   -0x10(%ebp)
8010348c:	e8 bd 16 00 00       	call   80104b4e <memmove>
80103491:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103494:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010349b:	eb 79                	jmp    80103516 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010349d:	e8 24 05 00 00       	call   801039c6 <mycpu>
801034a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034a5:	74 67                	je     8010350e <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801034a7:	e8 02 f3 ff ff       	call   801027ae <kalloc>
801034ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b2:	83 e8 04             	sub    $0x4,%eax
801034b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034b8:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034be:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c3:	83 e8 08             	sub    $0x8,%eax
801034c6:	c7 00 0d 34 10 80    	movl   $0x8010340d,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034cc:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034d1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034da:	83 e8 0c             	sub    $0xc,%eax
801034dd:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034eb:	0f b6 00             	movzbl (%eax),%eax
801034ee:	0f b6 c0             	movzbl %al,%eax
801034f1:	83 ec 08             	sub    $0x8,%esp
801034f4:	52                   	push   %edx
801034f5:	50                   	push   %eax
801034f6:	e8 50 f6 ff ff       	call   80102b4b <lapicstartap>
801034fb:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034fe:	90                   	nop
801034ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103502:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103508:	85 c0                	test   %eax,%eax
8010350a:	74 f3                	je     801034ff <startothers+0x91>
8010350c:	eb 01                	jmp    8010350f <startothers+0xa1>
      continue;
8010350e:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010350f:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103516:	a1 40 6c 19 80       	mov    0x80196c40,%eax
8010351b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103521:	05 80 69 19 80       	add    $0x80196980,%eax
80103526:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103529:	0f 82 6e ff ff ff    	jb     8010349d <startothers+0x2f>
      ;
  }
}
8010352f:	90                   	nop
80103530:	90                   	nop
80103531:	c9                   	leave  
80103532:	c3                   	ret    

80103533 <outb>:
{
80103533:	55                   	push   %ebp
80103534:	89 e5                	mov    %esp,%ebp
80103536:	83 ec 08             	sub    $0x8,%esp
80103539:	8b 45 08             	mov    0x8(%ebp),%eax
8010353c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010353f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103543:	89 d0                	mov    %edx,%eax
80103545:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103548:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010354c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103550:	ee                   	out    %al,(%dx)
}
80103551:	90                   	nop
80103552:	c9                   	leave  
80103553:	c3                   	ret    

80103554 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103554:	55                   	push   %ebp
80103555:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103557:	68 ff 00 00 00       	push   $0xff
8010355c:	6a 21                	push   $0x21
8010355e:	e8 d0 ff ff ff       	call   80103533 <outb>
80103563:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103566:	68 ff 00 00 00       	push   $0xff
8010356b:	68 a1 00 00 00       	push   $0xa1
80103570:	e8 be ff ff ff       	call   80103533 <outb>
80103575:	83 c4 08             	add    $0x8,%esp
}
80103578:	90                   	nop
80103579:	c9                   	leave  
8010357a:	c3                   	ret    

8010357b <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010357b:	55                   	push   %ebp
8010357c:	89 e5                	mov    %esp,%ebp
8010357e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103588:	8b 45 0c             	mov    0xc(%ebp),%eax
8010358b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103591:	8b 45 0c             	mov    0xc(%ebp),%eax
80103594:	8b 10                	mov    (%eax),%edx
80103596:	8b 45 08             	mov    0x8(%ebp),%eax
80103599:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010359b:	e8 4b da ff ff       	call   80100feb <filealloc>
801035a0:	8b 55 08             	mov    0x8(%ebp),%edx
801035a3:	89 02                	mov    %eax,(%edx)
801035a5:	8b 45 08             	mov    0x8(%ebp),%eax
801035a8:	8b 00                	mov    (%eax),%eax
801035aa:	85 c0                	test   %eax,%eax
801035ac:	0f 84 c8 00 00 00    	je     8010367a <pipealloc+0xff>
801035b2:	e8 34 da ff ff       	call   80100feb <filealloc>
801035b7:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ba:	89 02                	mov    %eax,(%edx)
801035bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801035bf:	8b 00                	mov    (%eax),%eax
801035c1:	85 c0                	test   %eax,%eax
801035c3:	0f 84 b1 00 00 00    	je     8010367a <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035c9:	e8 e0 f1 ff ff       	call   801027ae <kalloc>
801035ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035d5:	0f 84 a2 00 00 00    	je     8010367d <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035de:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035e5:	00 00 00 
  p->writeopen = 1;
801035e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035eb:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035f2:	00 00 00 
  p->nwrite = 0;
801035f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035ff:	00 00 00 
  p->nread = 0;
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010360c:	00 00 00 
  initlock(&p->lock, "pipe");
8010360f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103612:	83 ec 08             	sub    $0x8,%esp
80103615:	68 45 a4 10 80       	push   $0x8010a445
8010361a:	50                   	push   %eax
8010361b:	e8 d7 11 00 00       	call   801047f7 <initlock>
80103620:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103623:	8b 45 08             	mov    0x8(%ebp),%eax
80103626:	8b 00                	mov    (%eax),%eax
80103628:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010362e:	8b 45 08             	mov    0x8(%ebp),%eax
80103631:	8b 00                	mov    (%eax),%eax
80103633:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103637:	8b 45 08             	mov    0x8(%ebp),%eax
8010363a:	8b 00                	mov    (%eax),%eax
8010363c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103640:	8b 45 08             	mov    0x8(%ebp),%eax
80103643:	8b 00                	mov    (%eax),%eax
80103645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103648:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010364b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364e:	8b 00                	mov    (%eax),%eax
80103650:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103656:	8b 45 0c             	mov    0xc(%ebp),%eax
80103659:	8b 00                	mov    (%eax),%eax
8010365b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010365f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103662:	8b 00                	mov    (%eax),%eax
80103664:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103668:	8b 45 0c             	mov    0xc(%ebp),%eax
8010366b:	8b 00                	mov    (%eax),%eax
8010366d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103670:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103673:	b8 00 00 00 00       	mov    $0x0,%eax
80103678:	eb 51                	jmp    801036cb <pipealloc+0x150>
    goto bad;
8010367a:	90                   	nop
8010367b:	eb 01                	jmp    8010367e <pipealloc+0x103>
    goto bad;
8010367d:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010367e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103682:	74 0e                	je     80103692 <pipealloc+0x117>
    kfree((char*)p);
80103684:	83 ec 0c             	sub    $0xc,%esp
80103687:	ff 75 f4             	push   -0xc(%ebp)
8010368a:	e8 85 f0 ff ff       	call   80102714 <kfree>
8010368f:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103692:	8b 45 08             	mov    0x8(%ebp),%eax
80103695:	8b 00                	mov    (%eax),%eax
80103697:	85 c0                	test   %eax,%eax
80103699:	74 11                	je     801036ac <pipealloc+0x131>
    fileclose(*f0);
8010369b:	8b 45 08             	mov    0x8(%ebp),%eax
8010369e:	8b 00                	mov    (%eax),%eax
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	50                   	push   %eax
801036a4:	e8 00 da ff ff       	call   801010a9 <fileclose>
801036a9:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801036ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801036af:	8b 00                	mov    (%eax),%eax
801036b1:	85 c0                	test   %eax,%eax
801036b3:	74 11                	je     801036c6 <pipealloc+0x14b>
    fileclose(*f1);
801036b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801036b8:	8b 00                	mov    (%eax),%eax
801036ba:	83 ec 0c             	sub    $0xc,%esp
801036bd:	50                   	push   %eax
801036be:	e8 e6 d9 ff ff       	call   801010a9 <fileclose>
801036c3:	83 c4 10             	add    $0x10,%esp
  return -1;
801036c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036cb:	c9                   	leave  
801036cc:	c3                   	ret    

801036cd <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036cd:	55                   	push   %ebp
801036ce:	89 e5                	mov    %esp,%ebp
801036d0:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036d3:	8b 45 08             	mov    0x8(%ebp),%eax
801036d6:	83 ec 0c             	sub    $0xc,%esp
801036d9:	50                   	push   %eax
801036da:	e8 3a 11 00 00       	call   80104819 <acquire>
801036df:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036e6:	74 23                	je     8010370b <pipeclose+0x3e>
    p->writeopen = 0;
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036f2:	00 00 00 
    wakeup(&p->nread);
801036f5:	8b 45 08             	mov    0x8(%ebp),%eax
801036f8:	05 34 02 00 00       	add    $0x234,%eax
801036fd:	83 ec 0c             	sub    $0xc,%esp
80103700:	50                   	push   %eax
80103701:	e8 c8 0c 00 00       	call   801043ce <wakeup>
80103706:	83 c4 10             	add    $0x10,%esp
80103709:	eb 21                	jmp    8010372c <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103715:	00 00 00 
    wakeup(&p->nwrite);
80103718:	8b 45 08             	mov    0x8(%ebp),%eax
8010371b:	05 38 02 00 00       	add    $0x238,%eax
80103720:	83 ec 0c             	sub    $0xc,%esp
80103723:	50                   	push   %eax
80103724:	e8 a5 0c 00 00       	call   801043ce <wakeup>
80103729:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	75 2c                	jne    80103765 <pipeclose+0x98>
80103739:	8b 45 08             	mov    0x8(%ebp),%eax
8010373c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103742:	85 c0                	test   %eax,%eax
80103744:	75 1f                	jne    80103765 <pipeclose+0x98>
    release(&p->lock);
80103746:	8b 45 08             	mov    0x8(%ebp),%eax
80103749:	83 ec 0c             	sub    $0xc,%esp
8010374c:	50                   	push   %eax
8010374d:	e8 35 11 00 00       	call   80104887 <release>
80103752:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	ff 75 08             	push   0x8(%ebp)
8010375b:	e8 b4 ef ff ff       	call   80102714 <kfree>
80103760:	83 c4 10             	add    $0x10,%esp
80103763:	eb 10                	jmp    80103775 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103765:	8b 45 08             	mov    0x8(%ebp),%eax
80103768:	83 ec 0c             	sub    $0xc,%esp
8010376b:	50                   	push   %eax
8010376c:	e8 16 11 00 00       	call   80104887 <release>
80103771:	83 c4 10             	add    $0x10,%esp
}
80103774:	90                   	nop
80103775:	90                   	nop
80103776:	c9                   	leave  
80103777:	c3                   	ret    

80103778 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103778:	55                   	push   %ebp
80103779:	89 e5                	mov    %esp,%ebp
8010377b:	53                   	push   %ebx
8010377c:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010377f:	8b 45 08             	mov    0x8(%ebp),%eax
80103782:	83 ec 0c             	sub    $0xc,%esp
80103785:	50                   	push   %eax
80103786:	e8 8e 10 00 00       	call   80104819 <acquire>
8010378b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010378e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103795:	e9 ad 00 00 00       	jmp    80103847 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010379a:	8b 45 08             	mov    0x8(%ebp),%eax
8010379d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801037a3:	85 c0                	test   %eax,%eax
801037a5:	74 0c                	je     801037b3 <pipewrite+0x3b>
801037a7:	e8 92 02 00 00       	call   80103a3e <myproc>
801037ac:	8b 40 24             	mov    0x24(%eax),%eax
801037af:	85 c0                	test   %eax,%eax
801037b1:	74 19                	je     801037cc <pipewrite+0x54>
        release(&p->lock);
801037b3:	8b 45 08             	mov    0x8(%ebp),%eax
801037b6:	83 ec 0c             	sub    $0xc,%esp
801037b9:	50                   	push   %eax
801037ba:	e8 c8 10 00 00       	call   80104887 <release>
801037bf:	83 c4 10             	add    $0x10,%esp
        return -1;
801037c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037c7:	e9 a9 00 00 00       	jmp    80103875 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037cc:	8b 45 08             	mov    0x8(%ebp),%eax
801037cf:	05 34 02 00 00       	add    $0x234,%eax
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	50                   	push   %eax
801037d8:	e8 f1 0b 00 00       	call   801043ce <wakeup>
801037dd:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037e0:	8b 45 08             	mov    0x8(%ebp),%eax
801037e3:	8b 55 08             	mov    0x8(%ebp),%edx
801037e6:	81 c2 38 02 00 00    	add    $0x238,%edx
801037ec:	83 ec 08             	sub    $0x8,%esp
801037ef:	50                   	push   %eax
801037f0:	52                   	push   %edx
801037f1:	e8 f1 0a 00 00       	call   801042e7 <sleep>
801037f6:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037f9:	8b 45 08             	mov    0x8(%ebp),%eax
801037fc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103802:	8b 45 08             	mov    0x8(%ebp),%eax
80103805:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010380b:	05 00 02 00 00       	add    $0x200,%eax
80103810:	39 c2                	cmp    %eax,%edx
80103812:	74 86                	je     8010379a <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010381a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010381d:	8b 45 08             	mov    0x8(%ebp),%eax
80103820:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103826:	8d 48 01             	lea    0x1(%eax),%ecx
80103829:	8b 55 08             	mov    0x8(%ebp),%edx
8010382c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103832:	25 ff 01 00 00       	and    $0x1ff,%eax
80103837:	89 c1                	mov    %eax,%ecx
80103839:	0f b6 13             	movzbl (%ebx),%edx
8010383c:	8b 45 08             	mov    0x8(%ebp),%eax
8010383f:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103843:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010384d:	7c aa                	jl     801037f9 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010384f:	8b 45 08             	mov    0x8(%ebp),%eax
80103852:	05 34 02 00 00       	add    $0x234,%eax
80103857:	83 ec 0c             	sub    $0xc,%esp
8010385a:	50                   	push   %eax
8010385b:	e8 6e 0b 00 00       	call   801043ce <wakeup>
80103860:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103863:	8b 45 08             	mov    0x8(%ebp),%eax
80103866:	83 ec 0c             	sub    $0xc,%esp
80103869:	50                   	push   %eax
8010386a:	e8 18 10 00 00       	call   80104887 <release>
8010386f:	83 c4 10             	add    $0x10,%esp
  return n;
80103872:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103878:	c9                   	leave  
80103879:	c3                   	ret    

8010387a <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010387a:	55                   	push   %ebp
8010387b:	89 e5                	mov    %esp,%ebp
8010387d:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103880:	8b 45 08             	mov    0x8(%ebp),%eax
80103883:	83 ec 0c             	sub    $0xc,%esp
80103886:	50                   	push   %eax
80103887:	e8 8d 0f 00 00       	call   80104819 <acquire>
8010388c:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010388f:	eb 3e                	jmp    801038cf <piperead+0x55>
    if(myproc()->killed){
80103891:	e8 a8 01 00 00       	call   80103a3e <myproc>
80103896:	8b 40 24             	mov    0x24(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	74 19                	je     801038b6 <piperead+0x3c>
      release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 de 0f 00 00       	call   80104887 <release>
801038a9:	83 c4 10             	add    $0x10,%esp
      return -1;
801038ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038b1:	e9 be 00 00 00       	jmp    80103974 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038b6:	8b 45 08             	mov    0x8(%ebp),%eax
801038b9:	8b 55 08             	mov    0x8(%ebp),%edx
801038bc:	81 c2 34 02 00 00    	add    $0x234,%edx
801038c2:	83 ec 08             	sub    $0x8,%esp
801038c5:	50                   	push   %eax
801038c6:	52                   	push   %edx
801038c7:	e8 1b 0a 00 00       	call   801042e7 <sleep>
801038cc:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038cf:	8b 45 08             	mov    0x8(%ebp),%eax
801038d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038d8:	8b 45 08             	mov    0x8(%ebp),%eax
801038db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038e1:	39 c2                	cmp    %eax,%edx
801038e3:	75 0d                	jne    801038f2 <piperead+0x78>
801038e5:	8b 45 08             	mov    0x8(%ebp),%eax
801038e8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038ee:	85 c0                	test   %eax,%eax
801038f0:	75 9f                	jne    80103891 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f9:	eb 48                	jmp    80103943 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038fb:	8b 45 08             	mov    0x8(%ebp),%eax
801038fe:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010390d:	39 c2                	cmp    %eax,%edx
8010390f:	74 3c                	je     8010394d <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103911:	8b 45 08             	mov    0x8(%ebp),%eax
80103914:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010391a:	8d 48 01             	lea    0x1(%eax),%ecx
8010391d:	8b 55 08             	mov    0x8(%ebp),%edx
80103920:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103926:	25 ff 01 00 00       	and    $0x1ff,%eax
8010392b:	89 c1                	mov    %eax,%ecx
8010392d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103930:	8b 45 0c             	mov    0xc(%ebp),%eax
80103933:	01 c2                	add    %eax,%edx
80103935:	8b 45 08             	mov    0x8(%ebp),%eax
80103938:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010393d:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010393f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103946:	3b 45 10             	cmp    0x10(%ebp),%eax
80103949:	7c b0                	jl     801038fb <piperead+0x81>
8010394b:	eb 01                	jmp    8010394e <piperead+0xd4>
      break;
8010394d:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010394e:	8b 45 08             	mov    0x8(%ebp),%eax
80103951:	05 38 02 00 00       	add    $0x238,%eax
80103956:	83 ec 0c             	sub    $0xc,%esp
80103959:	50                   	push   %eax
8010395a:	e8 6f 0a 00 00       	call   801043ce <wakeup>
8010395f:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103962:	8b 45 08             	mov    0x8(%ebp),%eax
80103965:	83 ec 0c             	sub    $0xc,%esp
80103968:	50                   	push   %eax
80103969:	e8 19 0f 00 00       	call   80104887 <release>
8010396e:	83 c4 10             	add    $0x10,%esp
  return i;
80103971:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103974:	c9                   	leave  
80103975:	c3                   	ret    

80103976 <readeflags>:
{
80103976:	55                   	push   %ebp
80103977:	89 e5                	mov    %esp,%ebp
80103979:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010397c:	9c                   	pushf  
8010397d:	58                   	pop    %eax
8010397e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103981:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103984:	c9                   	leave  
80103985:	c3                   	ret    

80103986 <sti>:
{
80103986:	55                   	push   %ebp
80103987:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103989:	fb                   	sti    
}
8010398a:	90                   	nop
8010398b:	5d                   	pop    %ebp
8010398c:	c3                   	ret    

8010398d <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010398d:	55                   	push   %ebp
8010398e:	89 e5                	mov    %esp,%ebp
80103990:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103993:	83 ec 08             	sub    $0x8,%esp
80103996:	68 4c a4 10 80       	push   $0x8010a44c
8010399b:	68 00 42 19 80       	push   $0x80194200
801039a0:	e8 52 0e 00 00       	call   801047f7 <initlock>
801039a5:	83 c4 10             	add    $0x10,%esp
}
801039a8:	90                   	nop
801039a9:	c9                   	leave  
801039aa:	c3                   	ret    

801039ab <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801039ab:	55                   	push   %ebp
801039ac:	89 e5                	mov    %esp,%ebp
801039ae:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039b1:	e8 10 00 00 00       	call   801039c6 <mycpu>
801039b6:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039bb:	c1 f8 04             	sar    $0x4,%eax
801039be:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039c4:	c9                   	leave  
801039c5:	c3                   	ret    

801039c6 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039c6:	55                   	push   %ebp
801039c7:	89 e5                	mov    %esp,%ebp
801039c9:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039cc:	e8 a5 ff ff ff       	call   80103976 <readeflags>
801039d1:	25 00 02 00 00       	and    $0x200,%eax
801039d6:	85 c0                	test   %eax,%eax
801039d8:	74 0d                	je     801039e7 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039da:	83 ec 0c             	sub    $0xc,%esp
801039dd:	68 54 a4 10 80       	push   $0x8010a454
801039e2:	e8 da cb ff ff       	call   801005c1 <panic>
  }

  apicid = lapicid();
801039e7:	e8 1c f1 ff ff       	call   80102b08 <lapicid>
801039ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039f6:	eb 2d                	jmp    80103a25 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a01:	05 80 69 19 80       	add    $0x80196980,%eax
80103a06:	0f b6 00             	movzbl (%eax),%eax
80103a09:	0f b6 c0             	movzbl %al,%eax
80103a0c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a0f:	75 10                	jne    80103a21 <mycpu+0x5b>
      return &cpus[i];
80103a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a14:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a1a:	05 80 69 19 80       	add    $0x80196980,%eax
80103a1f:	eb 1b                	jmp    80103a3c <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a25:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a2a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a2d:	7c c9                	jl     801039f8 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a2f:	83 ec 0c             	sub    $0xc,%esp
80103a32:	68 7a a4 10 80       	push   $0x8010a47a
80103a37:	e8 85 cb ff ff       	call   801005c1 <panic>
}
80103a3c:	c9                   	leave  
80103a3d:	c3                   	ret    

80103a3e <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a3e:	55                   	push   %ebp
80103a3f:	89 e5                	mov    %esp,%ebp
80103a41:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a44:	e8 3b 0f 00 00       	call   80104984 <pushcli>
  c = mycpu();
80103a49:	e8 78 ff ff ff       	call   801039c6 <mycpu>
80103a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a54:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a5d:	e8 6f 0f 00 00       	call   801049d1 <popcli>
  return p;
80103a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a65:	c9                   	leave  
80103a66:	c3                   	ret    

80103a67 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a67:	55                   	push   %ebp
80103a68:	89 e5                	mov    %esp,%ebp
80103a6a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a6d:	83 ec 0c             	sub    $0xc,%esp
80103a70:	68 00 42 19 80       	push   $0x80194200
80103a75:	e8 9f 0d 00 00       	call   80104819 <acquire>
80103a7a:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a7d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a84:	eb 0e                	jmp    80103a94 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	8b 40 0c             	mov    0xc(%eax),%eax
80103a8c:	85 c0                	test   %eax,%eax
80103a8e:	74 27                	je     80103ab7 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a90:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a94:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a9b:	72 e9                	jb     80103a86 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a9d:	83 ec 0c             	sub    $0xc,%esp
80103aa0:	68 00 42 19 80       	push   $0x80194200
80103aa5:	e8 dd 0d 00 00       	call   80104887 <release>
80103aaa:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aad:	b8 00 00 00 00       	mov    $0x0,%eax
80103ab2:	e9 b2 00 00 00       	jmp    80103b69 <allocproc+0x102>
      goto found;
80103ab7:	90                   	nop

found:
  p->state = EMBRYO;
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ac2:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ac7:	8d 50 01             	lea    0x1(%eax),%edx
80103aca:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ad3:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ad6:	83 ec 0c             	sub    $0xc,%esp
80103ad9:	68 00 42 19 80       	push   $0x80194200
80103ade:	e8 a4 0d 00 00       	call   80104887 <release>
80103ae3:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ae6:	e8 c3 ec ff ff       	call   801027ae <kalloc>
80103aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103aee:	89 42 08             	mov    %eax,0x8(%edx)
80103af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af4:	8b 40 08             	mov    0x8(%eax),%eax
80103af7:	85 c0                	test   %eax,%eax
80103af9:	75 11                	jne    80103b0c <allocproc+0xa5>
    p->state = UNUSED;
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b05:	b8 00 00 00 00       	mov    $0x0,%eax
80103b0a:	eb 5d                	jmp    80103b69 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	8b 40 08             	mov    0x8(%eax),%eax
80103b12:	05 00 10 00 00       	add    $0x1000,%eax
80103b17:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b1a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b24:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b27:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b2b:	ba 25 5e 10 80       	mov    $0x80105e25,%edx
80103b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b33:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b35:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b3f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b45:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b48:	83 ec 04             	sub    $0x4,%esp
80103b4b:	6a 14                	push   $0x14
80103b4d:	6a 00                	push   $0x0
80103b4f:	50                   	push   %eax
80103b50:	e8 3a 0f 00 00       	call   80104a8f <memset>
80103b55:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5b:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b5e:	ba a1 42 10 80       	mov    $0x801042a1,%edx
80103b63:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b69:	c9                   	leave  
80103b6a:	c3                   	ret    

80103b6b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b6b:	55                   	push   %ebp
80103b6c:	89 e5                	mov    %esp,%ebp
80103b6e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b71:	e8 f1 fe ff ff       	call   80103a67 <allocproc>
80103b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7c:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b81:	e8 ac 38 00 00       	call   80107432 <setupkvm>
80103b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b89:	89 42 04             	mov    %eax,0x4(%edx)
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	8b 40 04             	mov    0x4(%eax),%eax
80103b92:	85 c0                	test   %eax,%eax
80103b94:	75 0d                	jne    80103ba3 <userinit+0x38>
    panic("userinit: out of memory?");
80103b96:	83 ec 0c             	sub    $0xc,%esp
80103b99:	68 8a a4 10 80       	push   $0x8010a48a
80103b9e:	e8 1e ca ff ff       	call   801005c1 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103ba3:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	8b 40 04             	mov    0x4(%eax),%eax
80103bae:	83 ec 04             	sub    $0x4,%esp
80103bb1:	52                   	push   %edx
80103bb2:	68 ec f4 10 80       	push   $0x8010f4ec
80103bb7:	50                   	push   %eax
80103bb8:	e8 31 3b 00 00       	call   801076ee <inituvm>
80103bbd:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcc:	8b 40 18             	mov    0x18(%eax),%eax
80103bcf:	83 ec 04             	sub    $0x4,%esp
80103bd2:	6a 4c                	push   $0x4c
80103bd4:	6a 00                	push   $0x0
80103bd6:	50                   	push   %eax
80103bd7:	e8 b3 0e 00 00       	call   80104a8f <memset>
80103bdc:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be2:	8b 40 18             	mov    0x18(%eax),%eax
80103be5:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bee:	8b 40 18             	mov    0x18(%eax),%eax
80103bf1:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfa:	8b 50 18             	mov    0x18(%eax),%edx
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 40 18             	mov    0x18(%eax),%eax
80103c03:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c07:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0e:	8b 50 18             	mov    0x18(%eax),%edx
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c1b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c22:	8b 40 18             	mov    0x18(%eax),%eax
80103c25:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	8b 40 18             	mov    0x18(%eax),%eax
80103c32:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	8b 40 18             	mov    0x18(%eax),%eax
80103c3f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c49:	83 c0 6c             	add    $0x6c,%eax
80103c4c:	83 ec 04             	sub    $0x4,%esp
80103c4f:	6a 10                	push   $0x10
80103c51:	68 a3 a4 10 80       	push   $0x8010a4a3
80103c56:	50                   	push   %eax
80103c57:	e8 36 10 00 00       	call   80104c92 <safestrcpy>
80103c5c:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c5f:	83 ec 0c             	sub    $0xc,%esp
80103c62:	68 ac a4 10 80       	push   $0x8010a4ac
80103c67:	e8 bf e8 ff ff       	call   8010252b <namei>
80103c6c:	83 c4 10             	add    $0x10,%esp
80103c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c72:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c75:	83 ec 0c             	sub    $0xc,%esp
80103c78:	68 00 42 19 80       	push   $0x80194200
80103c7d:	e8 97 0b 00 00       	call   80104819 <acquire>
80103c82:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c88:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c8f:	83 ec 0c             	sub    $0xc,%esp
80103c92:	68 00 42 19 80       	push   $0x80194200
80103c97:	e8 eb 0b 00 00       	call   80104887 <release>
80103c9c:	83 c4 10             	add    $0x10,%esp
}
80103c9f:	90                   	nop
80103ca0:	c9                   	leave  
80103ca1:	c3                   	ret    

80103ca2 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ca2:	55                   	push   %ebp
80103ca3:	89 e5                	mov    %esp,%ebp
80103ca5:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ca8:	e8 91 fd ff ff       	call   80103a3e <myproc>
80103cad:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb3:	8b 00                	mov    (%eax),%eax
80103cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cb8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cbc:	7e 2e                	jle    80103cec <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cbe:	8b 55 08             	mov    0x8(%ebp),%edx
80103cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc4:	01 c2                	add    %eax,%edx
80103cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc9:	8b 40 04             	mov    0x4(%eax),%eax
80103ccc:	83 ec 04             	sub    $0x4,%esp
80103ccf:	52                   	push   %edx
80103cd0:	ff 75 f4             	push   -0xc(%ebp)
80103cd3:	50                   	push   %eax
80103cd4:	e8 52 3b 00 00       	call   8010782b <allocuvm>
80103cd9:	83 c4 10             	add    $0x10,%esp
80103cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ce3:	75 3b                	jne    80103d20 <growproc+0x7e>
      return -1;
80103ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cea:	eb 4f                	jmp    80103d3b <growproc+0x99>
  } else if(n < 0){
80103cec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cf0:	79 2e                	jns    80103d20 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cf2:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf8:	01 c2                	add    %eax,%edx
80103cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cfd:	8b 40 04             	mov    0x4(%eax),%eax
80103d00:	83 ec 04             	sub    $0x4,%esp
80103d03:	52                   	push   %edx
80103d04:	ff 75 f4             	push   -0xc(%ebp)
80103d07:	50                   	push   %eax
80103d08:	e8 23 3c 00 00       	call   80107930 <deallocuvm>
80103d0d:	83 c4 10             	add    $0x10,%esp
80103d10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d17:	75 07                	jne    80103d20 <growproc+0x7e>
      return -1;
80103d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d1e:	eb 1b                	jmp    80103d3b <growproc+0x99>
  }
  curproc->sz = sz;
80103d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d26:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d28:	83 ec 0c             	sub    $0xc,%esp
80103d2b:	ff 75 f0             	push   -0x10(%ebp)
80103d2e:	e8 1c 38 00 00       	call   8010754f <switchuvm>
80103d33:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d3b:	c9                   	leave  
80103d3c:	c3                   	ret    

80103d3d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d3d:	55                   	push   %ebp
80103d3e:	89 e5                	mov    %esp,%ebp
80103d40:	57                   	push   %edi
80103d41:	56                   	push   %esi
80103d42:	53                   	push   %ebx
80103d43:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d46:	e8 f3 fc ff ff       	call   80103a3e <myproc>
80103d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d4e:	e8 14 fd ff ff       	call   80103a67 <allocproc>
80103d53:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d56:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d5a:	75 0a                	jne    80103d66 <fork+0x29>
    return -1;
80103d5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d61:	e9 48 01 00 00       	jmp    80103eae <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d69:	8b 10                	mov    (%eax),%edx
80103d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d6e:	8b 40 04             	mov    0x4(%eax),%eax
80103d71:	83 ec 08             	sub    $0x8,%esp
80103d74:	52                   	push   %edx
80103d75:	50                   	push   %eax
80103d76:	e8 53 3d 00 00       	call   80107ace <copyuvm>
80103d7b:	83 c4 10             	add    $0x10,%esp
80103d7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d81:	89 42 04             	mov    %eax,0x4(%edx)
80103d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d87:	8b 40 04             	mov    0x4(%eax),%eax
80103d8a:	85 c0                	test   %eax,%eax
80103d8c:	75 30                	jne    80103dbe <fork+0x81>
    kfree(np->kstack);
80103d8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d91:	8b 40 08             	mov    0x8(%eax),%eax
80103d94:	83 ec 0c             	sub    $0xc,%esp
80103d97:	50                   	push   %eax
80103d98:	e8 77 e9 ff ff       	call   80102714 <kfree>
80103d9d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103da0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103daa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db9:	e9 f0 00 00 00       	jmp    80103eae <fork+0x171>
  }
  np->sz = curproc->sz;
80103dbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc1:	8b 10                	mov    (%eax),%edx
80103dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc6:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dce:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dd4:	8b 48 18             	mov    0x18(%eax),%ecx
80103dd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dda:	8b 40 18             	mov    0x18(%eax),%eax
80103ddd:	89 c2                	mov    %eax,%edx
80103ddf:	89 cb                	mov    %ecx,%ebx
80103de1:	b8 13 00 00 00       	mov    $0x13,%eax
80103de6:	89 d7                	mov    %edx,%edi
80103de8:	89 de                	mov    %ebx,%esi
80103dea:	89 c1                	mov    %eax,%ecx
80103dec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dee:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df1:	8b 40 18             	mov    0x18(%eax),%eax
80103df4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103dfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e02:	eb 3b                	jmp    80103e3f <fork+0x102>
    if(curproc->ofile[i])
80103e04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0a:	83 c2 08             	add    $0x8,%edx
80103e0d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e11:	85 c0                	test   %eax,%eax
80103e13:	74 26                	je     80103e3b <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e1b:	83 c2 08             	add    $0x8,%edx
80103e1e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	50                   	push   %eax
80103e26:	e8 2d d2 ff ff       	call   80101058 <filedup>
80103e2b:	83 c4 10             	add    $0x10,%esp
80103e2e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e31:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e34:	83 c1 08             	add    $0x8,%ecx
80103e37:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e3b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e3f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e43:	7e bf                	jle    80103e04 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e48:	8b 40 68             	mov    0x68(%eax),%eax
80103e4b:	83 ec 0c             	sub    $0xc,%esp
80103e4e:	50                   	push   %eax
80103e4f:	e8 6a db ff ff       	call   801019be <idup>
80103e54:	83 c4 10             	add    $0x10,%esp
80103e57:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e5a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e60:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e66:	83 c0 6c             	add    $0x6c,%eax
80103e69:	83 ec 04             	sub    $0x4,%esp
80103e6c:	6a 10                	push   $0x10
80103e6e:	52                   	push   %edx
80103e6f:	50                   	push   %eax
80103e70:	e8 1d 0e 00 00       	call   80104c92 <safestrcpy>
80103e75:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e78:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7b:	8b 40 10             	mov    0x10(%eax),%eax
80103e7e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e81:	83 ec 0c             	sub    $0xc,%esp
80103e84:	68 00 42 19 80       	push   $0x80194200
80103e89:	e8 8b 09 00 00       	call   80104819 <acquire>
80103e8e:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e94:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e9b:	83 ec 0c             	sub    $0xc,%esp
80103e9e:	68 00 42 19 80       	push   $0x80194200
80103ea3:	e8 df 09 00 00       	call   80104887 <release>
80103ea8:	83 c4 10             	add    $0x10,%esp

  return pid;
80103eab:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eb1:	5b                   	pop    %ebx
80103eb2:	5e                   	pop    %esi
80103eb3:	5f                   	pop    %edi
80103eb4:	5d                   	pop    %ebp
80103eb5:	c3                   	ret    

80103eb6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eb6:	55                   	push   %ebp
80103eb7:	89 e5                	mov    %esp,%ebp
80103eb9:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ebc:	e8 7d fb ff ff       	call   80103a3e <myproc>
80103ec1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ec4:	a1 34 61 19 80       	mov    0x80196134,%eax
80103ec9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ecc:	75 0d                	jne    80103edb <exit+0x25>
    panic("init exiting");
80103ece:	83 ec 0c             	sub    $0xc,%esp
80103ed1:	68 ae a4 10 80       	push   $0x8010a4ae
80103ed6:	e8 e6 c6 ff ff       	call   801005c1 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103edb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ee2:	eb 3f                	jmp    80103f23 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eea:	83 c2 08             	add    $0x8,%edx
80103eed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef1:	85 c0                	test   %eax,%eax
80103ef3:	74 2a                	je     80103f1f <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ef5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103efb:	83 c2 08             	add    $0x8,%edx
80103efe:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f02:	83 ec 0c             	sub    $0xc,%esp
80103f05:	50                   	push   %eax
80103f06:	e8 9e d1 ff ff       	call   801010a9 <fileclose>
80103f0b:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f14:	83 c2 08             	add    $0x8,%edx
80103f17:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f1e:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f1f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f23:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f27:	7e bb                	jle    80103ee4 <exit+0x2e>
    }
  }

  begin_op();
80103f29:	e8 1c f1 ff ff       	call   8010304a <begin_op>
  iput(curproc->cwd);
80103f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f31:	8b 40 68             	mov    0x68(%eax),%eax
80103f34:	83 ec 0c             	sub    $0xc,%esp
80103f37:	50                   	push   %eax
80103f38:	e8 1c dc ff ff       	call   80101b59 <iput>
80103f3d:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f40:	e8 91 f1 ff ff       	call   801030d6 <end_op>
  curproc->cwd = 0;
80103f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f48:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f4f:	83 ec 0c             	sub    $0xc,%esp
80103f52:	68 00 42 19 80       	push   $0x80194200
80103f57:	e8 bd 08 00 00       	call   80104819 <acquire>
80103f5c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f62:	8b 40 14             	mov    0x14(%eax),%eax
80103f65:	83 ec 0c             	sub    $0xc,%esp
80103f68:	50                   	push   %eax
80103f69:	e8 20 04 00 00       	call   8010438e <wakeup1>
80103f6e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f71:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f78:	eb 37                	jmp    80103fb1 <exit+0xfb>
    if(p->parent == curproc){
80103f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7d:	8b 40 14             	mov    0x14(%eax),%eax
80103f80:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f83:	75 28                	jne    80103fad <exit+0xf7>
      p->parent = initproc;
80103f85:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f94:	8b 40 0c             	mov    0xc(%eax),%eax
80103f97:	83 f8 05             	cmp    $0x5,%eax
80103f9a:	75 11                	jne    80103fad <exit+0xf7>
        wakeup1(initproc);
80103f9c:	a1 34 61 19 80       	mov    0x80196134,%eax
80103fa1:	83 ec 0c             	sub    $0xc,%esp
80103fa4:	50                   	push   %eax
80103fa5:	e8 e4 03 00 00       	call   8010438e <wakeup1>
80103faa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fad:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103fb1:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103fb8:	72 c0                	jb     80103f7a <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fbd:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fc4:	e8 e5 01 00 00       	call   801041ae <sched>
  panic("zombie exit");
80103fc9:	83 ec 0c             	sub    $0xc,%esp
80103fcc:	68 bb a4 10 80       	push   $0x8010a4bb
80103fd1:	e8 eb c5 ff ff       	call   801005c1 <panic>

80103fd6 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fd6:	55                   	push   %ebp
80103fd7:	89 e5                	mov    %esp,%ebp
80103fd9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fdc:	e8 5d fa ff ff       	call   80103a3e <myproc>
80103fe1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fe4:	83 ec 0c             	sub    $0xc,%esp
80103fe7:	68 00 42 19 80       	push   $0x80194200
80103fec:	e8 28 08 00 00       	call   80104819 <acquire>
80103ff1:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103ff4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ffb:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104002:	e9 a1 00 00 00       	jmp    801040a8 <wait+0xd2>
      if(p->parent != curproc)
80104007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400a:	8b 40 14             	mov    0x14(%eax),%eax
8010400d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104010:	0f 85 8d 00 00 00    	jne    801040a3 <wait+0xcd>
        continue;
      havekids = 1;
80104016:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010401d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104020:	8b 40 0c             	mov    0xc(%eax),%eax
80104023:	83 f8 05             	cmp    $0x5,%eax
80104026:	75 7c                	jne    801040a4 <wait+0xce>
        // Found one.
        pid = p->pid;
80104028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402b:	8b 40 10             	mov    0x10(%eax),%eax
8010402e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104034:	8b 40 08             	mov    0x8(%eax),%eax
80104037:	83 ec 0c             	sub    $0xc,%esp
8010403a:	50                   	push   %eax
8010403b:	e8 d4 e6 ff ff       	call   80102714 <kfree>
80104040:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	8b 40 04             	mov    0x4(%eax),%eax
80104053:	83 ec 0c             	sub    $0xc,%esp
80104056:	50                   	push   %eax
80104057:	e8 98 39 00 00       	call   801079f4 <freevm>
8010405c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010405f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104062:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104076:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010407a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104087:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010408e:	83 ec 0c             	sub    $0xc,%esp
80104091:	68 00 42 19 80       	push   $0x80194200
80104096:	e8 ec 07 00 00       	call   80104887 <release>
8010409b:	83 c4 10             	add    $0x10,%esp
        return pid;
8010409e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040a1:	eb 51                	jmp    801040f4 <wait+0x11e>
        continue;
801040a3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040a4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801040a8:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801040af:	0f 82 52 ff ff ff    	jb     80104007 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040b9:	74 0a                	je     801040c5 <wait+0xef>
801040bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040be:	8b 40 24             	mov    0x24(%eax),%eax
801040c1:	85 c0                	test   %eax,%eax
801040c3:	74 17                	je     801040dc <wait+0x106>
      release(&ptable.lock);
801040c5:	83 ec 0c             	sub    $0xc,%esp
801040c8:	68 00 42 19 80       	push   $0x80194200
801040cd:	e8 b5 07 00 00       	call   80104887 <release>
801040d2:	83 c4 10             	add    $0x10,%esp
      return -1;
801040d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040da:	eb 18                	jmp    801040f4 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040dc:	83 ec 08             	sub    $0x8,%esp
801040df:	68 00 42 19 80       	push   $0x80194200
801040e4:	ff 75 ec             	push   -0x14(%ebp)
801040e7:	e8 fb 01 00 00       	call   801042e7 <sleep>
801040ec:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040ef:	e9 00 ff ff ff       	jmp    80103ff4 <wait+0x1e>
  }
}
801040f4:	c9                   	leave  
801040f5:	c3                   	ret    

801040f6 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040f6:	55                   	push   %ebp
801040f7:	89 e5                	mov    %esp,%ebp
801040f9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040fc:	e8 c5 f8 ff ff       	call   801039c6 <mycpu>
80104101:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104107:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010410e:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104111:	e8 70 f8 ff ff       	call   80103986 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104116:	83 ec 0c             	sub    $0xc,%esp
80104119:	68 00 42 19 80       	push   $0x80194200
8010411e:	e8 f6 06 00 00       	call   80104819 <acquire>
80104123:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104126:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010412d:	eb 61                	jmp    80104190 <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010412f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104132:	8b 40 0c             	mov    0xc(%eax),%eax
80104135:	83 f8 03             	cmp    $0x3,%eax
80104138:	75 51                	jne    8010418b <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010413a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010413d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104140:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104146:	83 ec 0c             	sub    $0xc,%esp
80104149:	ff 75 f4             	push   -0xc(%ebp)
8010414c:	e8 fe 33 00 00       	call   8010754f <switchuvm>
80104151:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104157:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010415e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104161:	8b 40 1c             	mov    0x1c(%eax),%eax
80104164:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104167:	83 c2 04             	add    $0x4,%edx
8010416a:	83 ec 08             	sub    $0x8,%esp
8010416d:	50                   	push   %eax
8010416e:	52                   	push   %edx
8010416f:	e8 90 0b 00 00       	call   80104d04 <swtch>
80104174:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104177:	e8 ba 33 00 00       	call   80107536 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010417c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104186:	00 00 00 
80104189:	eb 01                	jmp    8010418c <scheduler+0x96>
        continue;
8010418b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010418c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104190:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104197:	72 96                	jb     8010412f <scheduler+0x39>
    }
    release(&ptable.lock);
80104199:	83 ec 0c             	sub    $0xc,%esp
8010419c:	68 00 42 19 80       	push   $0x80194200
801041a1:	e8 e1 06 00 00       	call   80104887 <release>
801041a6:	83 c4 10             	add    $0x10,%esp
    sti();
801041a9:	e9 63 ff ff ff       	jmp    80104111 <scheduler+0x1b>

801041ae <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041ae:	55                   	push   %ebp
801041af:	89 e5                	mov    %esp,%ebp
801041b1:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041b4:	e8 85 f8 ff ff       	call   80103a3e <myproc>
801041b9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041bc:	83 ec 0c             	sub    $0xc,%esp
801041bf:	68 00 42 19 80       	push   $0x80194200
801041c4:	e8 8b 07 00 00       	call   80104954 <holding>
801041c9:	83 c4 10             	add    $0x10,%esp
801041cc:	85 c0                	test   %eax,%eax
801041ce:	75 0d                	jne    801041dd <sched+0x2f>
    panic("sched ptable.lock");
801041d0:	83 ec 0c             	sub    $0xc,%esp
801041d3:	68 c7 a4 10 80       	push   $0x8010a4c7
801041d8:	e8 e4 c3 ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli != 1)
801041dd:	e8 e4 f7 ff ff       	call   801039c6 <mycpu>
801041e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041e8:	83 f8 01             	cmp    $0x1,%eax
801041eb:	74 0d                	je     801041fa <sched+0x4c>
    panic("sched locks");
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	68 d9 a4 10 80       	push   $0x8010a4d9
801041f5:	e8 c7 c3 ff ff       	call   801005c1 <panic>
  if(p->state == RUNNING)
801041fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fd:	8b 40 0c             	mov    0xc(%eax),%eax
80104200:	83 f8 04             	cmp    $0x4,%eax
80104203:	75 0d                	jne    80104212 <sched+0x64>
    panic("sched running");
80104205:	83 ec 0c             	sub    $0xc,%esp
80104208:	68 e5 a4 10 80       	push   $0x8010a4e5
8010420d:	e8 af c3 ff ff       	call   801005c1 <panic>
  if(readeflags()&FL_IF)
80104212:	e8 5f f7 ff ff       	call   80103976 <readeflags>
80104217:	25 00 02 00 00       	and    $0x200,%eax
8010421c:	85 c0                	test   %eax,%eax
8010421e:	74 0d                	je     8010422d <sched+0x7f>
    panic("sched interruptible");
80104220:	83 ec 0c             	sub    $0xc,%esp
80104223:	68 f3 a4 10 80       	push   $0x8010a4f3
80104228:	e8 94 c3 ff ff       	call   801005c1 <panic>
  intena = mycpu()->intena;
8010422d:	e8 94 f7 ff ff       	call   801039c6 <mycpu>
80104232:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104238:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010423b:	e8 86 f7 ff ff       	call   801039c6 <mycpu>
80104240:	8b 40 04             	mov    0x4(%eax),%eax
80104243:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104246:	83 c2 1c             	add    $0x1c,%edx
80104249:	83 ec 08             	sub    $0x8,%esp
8010424c:	50                   	push   %eax
8010424d:	52                   	push   %edx
8010424e:	e8 b1 0a 00 00       	call   80104d04 <swtch>
80104253:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104256:	e8 6b f7 ff ff       	call   801039c6 <mycpu>
8010425b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010425e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104264:	90                   	nop
80104265:	c9                   	leave  
80104266:	c3                   	ret    

80104267 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104267:	55                   	push   %ebp
80104268:	89 e5                	mov    %esp,%ebp
8010426a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010426d:	83 ec 0c             	sub    $0xc,%esp
80104270:	68 00 42 19 80       	push   $0x80194200
80104275:	e8 9f 05 00 00       	call   80104819 <acquire>
8010427a:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010427d:	e8 bc f7 ff ff       	call   80103a3e <myproc>
80104282:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104289:	e8 20 ff ff ff       	call   801041ae <sched>
  release(&ptable.lock);
8010428e:	83 ec 0c             	sub    $0xc,%esp
80104291:	68 00 42 19 80       	push   $0x80194200
80104296:	e8 ec 05 00 00       	call   80104887 <release>
8010429b:	83 c4 10             	add    $0x10,%esp
}
8010429e:	90                   	nop
8010429f:	c9                   	leave  
801042a0:	c3                   	ret    

801042a1 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801042a1:	55                   	push   %ebp
801042a2:	89 e5                	mov    %esp,%ebp
801042a4:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042a7:	83 ec 0c             	sub    $0xc,%esp
801042aa:	68 00 42 19 80       	push   $0x80194200
801042af:	e8 d3 05 00 00       	call   80104887 <release>
801042b4:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042b7:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042bc:	85 c0                	test   %eax,%eax
801042be:	74 24                	je     801042e4 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042c0:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042c7:	00 00 00 
    iinit(ROOTDEV);
801042ca:	83 ec 0c             	sub    $0xc,%esp
801042cd:	6a 01                	push   $0x1
801042cf:	e8 b2 d3 ff ff       	call   80101686 <iinit>
801042d4:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042d7:	83 ec 0c             	sub    $0xc,%esp
801042da:	6a 01                	push   $0x1
801042dc:	e8 4a eb ff ff       	call   80102e2b <initlog>
801042e1:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042e4:	90                   	nop
801042e5:	c9                   	leave  
801042e6:	c3                   	ret    

801042e7 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042e7:	55                   	push   %ebp
801042e8:	89 e5                	mov    %esp,%ebp
801042ea:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042ed:	e8 4c f7 ff ff       	call   80103a3e <myproc>
801042f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f9:	75 0d                	jne    80104308 <sleep+0x21>
    panic("sleep");
801042fb:	83 ec 0c             	sub    $0xc,%esp
801042fe:	68 07 a5 10 80       	push   $0x8010a507
80104303:	e8 b9 c2 ff ff       	call   801005c1 <panic>

  if(lk == 0)
80104308:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010430c:	75 0d                	jne    8010431b <sleep+0x34>
    panic("sleep without lk");
8010430e:	83 ec 0c             	sub    $0xc,%esp
80104311:	68 0d a5 10 80       	push   $0x8010a50d
80104316:	e8 a6 c2 ff ff       	call   801005c1 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010431b:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104322:	74 1e                	je     80104342 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104324:	83 ec 0c             	sub    $0xc,%esp
80104327:	68 00 42 19 80       	push   $0x80194200
8010432c:	e8 e8 04 00 00       	call   80104819 <acquire>
80104331:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104334:	83 ec 0c             	sub    $0xc,%esp
80104337:	ff 75 0c             	push   0xc(%ebp)
8010433a:	e8 48 05 00 00       	call   80104887 <release>
8010433f:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104345:	8b 55 08             	mov    0x8(%ebp),%edx
80104348:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104355:	e8 54 fe ff ff       	call   801041ae <sched>

  // Tidy up.
  p->chan = 0;
8010435a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104364:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010436b:	74 1e                	je     8010438b <sleep+0xa4>
    release(&ptable.lock);
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	68 00 42 19 80       	push   $0x80194200
80104375:	e8 0d 05 00 00       	call   80104887 <release>
8010437a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010437d:	83 ec 0c             	sub    $0xc,%esp
80104380:	ff 75 0c             	push   0xc(%ebp)
80104383:	e8 91 04 00 00       	call   80104819 <acquire>
80104388:	83 c4 10             	add    $0x10,%esp
  }
}
8010438b:	90                   	nop
8010438c:	c9                   	leave  
8010438d:	c3                   	ret    

8010438e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010438e:	55                   	push   %ebp
8010438f:	89 e5                	mov    %esp,%ebp
80104391:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104394:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010439b:	eb 24                	jmp    801043c1 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010439d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a0:	8b 40 0c             	mov    0xc(%eax),%eax
801043a3:	83 f8 02             	cmp    $0x2,%eax
801043a6:	75 15                	jne    801043bd <wakeup1+0x2f>
801043a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043ab:	8b 40 20             	mov    0x20(%eax),%eax
801043ae:	39 45 08             	cmp    %eax,0x8(%ebp)
801043b1:	75 0a                	jne    801043bd <wakeup1+0x2f>
      p->state = RUNNABLE;
801043b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bd:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043c1:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043c8:	72 d3                	jb     8010439d <wakeup1+0xf>
}
801043ca:	90                   	nop
801043cb:	90                   	nop
801043cc:	c9                   	leave  
801043cd:	c3                   	ret    

801043ce <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043ce:	55                   	push   %ebp
801043cf:	89 e5                	mov    %esp,%ebp
801043d1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043d4:	83 ec 0c             	sub    $0xc,%esp
801043d7:	68 00 42 19 80       	push   $0x80194200
801043dc:	e8 38 04 00 00       	call   80104819 <acquire>
801043e1:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	ff 75 08             	push   0x8(%ebp)
801043ea:	e8 9f ff ff ff       	call   8010438e <wakeup1>
801043ef:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043f2:	83 ec 0c             	sub    $0xc,%esp
801043f5:	68 00 42 19 80       	push   $0x80194200
801043fa:	e8 88 04 00 00       	call   80104887 <release>
801043ff:	83 c4 10             	add    $0x10,%esp
}
80104402:	90                   	nop
80104403:	c9                   	leave  
80104404:	c3                   	ret    

80104405 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104405:	55                   	push   %ebp
80104406:	89 e5                	mov    %esp,%ebp
80104408:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	68 00 42 19 80       	push   $0x80194200
80104413:	e8 01 04 00 00       	call   80104819 <acquire>
80104418:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010441b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104422:	eb 45                	jmp    80104469 <kill+0x64>
    if(p->pid == pid){
80104424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104427:	8b 40 10             	mov    0x10(%eax),%eax
8010442a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010442d:	75 36                	jne    80104465 <kill+0x60>
      p->killed = 1;
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443c:	8b 40 0c             	mov    0xc(%eax),%eax
8010443f:	83 f8 02             	cmp    $0x2,%eax
80104442:	75 0a                	jne    8010444e <kill+0x49>
        p->state = RUNNABLE;
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010444e:	83 ec 0c             	sub    $0xc,%esp
80104451:	68 00 42 19 80       	push   $0x80194200
80104456:	e8 2c 04 00 00       	call   80104887 <release>
8010445b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010445e:	b8 00 00 00 00       	mov    $0x0,%eax
80104463:	eb 22                	jmp    80104487 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104465:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104469:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104470:	72 b2                	jb     80104424 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104472:	83 ec 0c             	sub    $0xc,%esp
80104475:	68 00 42 19 80       	push   $0x80194200
8010447a:	e8 08 04 00 00       	call   80104887 <release>
8010447f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104487:	c9                   	leave  
80104488:	c3                   	ret    

80104489 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104489:	55                   	push   %ebp
8010448a:	89 e5                	mov    %esp,%ebp
8010448c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010448f:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104496:	e9 d7 00 00 00       	jmp    80104572 <procdump+0xe9>
    if(p->state == UNUSED)
8010449b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449e:	8b 40 0c             	mov    0xc(%eax),%eax
801044a1:	85 c0                	test   %eax,%eax
801044a3:	0f 84 c4 00 00 00    	je     8010456d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ac:	8b 40 0c             	mov    0xc(%eax),%eax
801044af:	83 f8 05             	cmp    $0x5,%eax
801044b2:	77 23                	ja     801044d7 <procdump+0x4e>
801044b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b7:	8b 40 0c             	mov    0xc(%eax),%eax
801044ba:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c1:	85 c0                	test   %eax,%eax
801044c3:	74 12                	je     801044d7 <procdump+0x4e>
      state = states[p->state];
801044c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c8:	8b 40 0c             	mov    0xc(%eax),%eax
801044cb:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044d5:	eb 07                	jmp    801044de <procdump+0x55>
    else
      state = "???";
801044d7:	c7 45 ec 1e a5 10 80 	movl   $0x8010a51e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e1:	8d 50 6c             	lea    0x6c(%eax),%edx
801044e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e7:	8b 40 10             	mov    0x10(%eax),%eax
801044ea:	52                   	push   %edx
801044eb:	ff 75 ec             	push   -0x14(%ebp)
801044ee:	50                   	push   %eax
801044ef:	68 22 a5 10 80       	push   $0x8010a522
801044f4:	e8 fb be ff ff       	call   801003f4 <cprintf>
801044f9:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104502:	83 f8 02             	cmp    $0x2,%eax
80104505:	75 54                	jne    8010455b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010450d:	8b 40 0c             	mov    0xc(%eax),%eax
80104510:	83 c0 08             	add    $0x8,%eax
80104513:	89 c2                	mov    %eax,%edx
80104515:	83 ec 08             	sub    $0x8,%esp
80104518:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010451b:	50                   	push   %eax
8010451c:	52                   	push   %edx
8010451d:	e8 b7 03 00 00       	call   801048d9 <getcallerpcs>
80104522:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104525:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010452c:	eb 1c                	jmp    8010454a <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010452e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104531:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104535:	83 ec 08             	sub    $0x8,%esp
80104538:	50                   	push   %eax
80104539:	68 2b a5 10 80       	push   $0x8010a52b
8010453e:	e8 b1 be ff ff       	call   801003f4 <cprintf>
80104543:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104546:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010454a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010454e:	7f 0b                	jg     8010455b <procdump+0xd2>
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104557:	85 c0                	test   %eax,%eax
80104559:	75 d3                	jne    8010452e <procdump+0xa5>
    }
    cprintf("\n");
8010455b:	83 ec 0c             	sub    $0xc,%esp
8010455e:	68 2f a5 10 80       	push   $0x8010a52f
80104563:	e8 8c be ff ff       	call   801003f4 <cprintf>
80104568:	83 c4 10             	add    $0x10,%esp
8010456b:	eb 01                	jmp    8010456e <procdump+0xe5>
      continue;
8010456d:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010456e:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104572:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
80104579:	0f 82 1c ff ff ff    	jb     8010449b <procdump+0x12>
  }
}
8010457f:	90                   	nop
80104580:	90                   	nop
80104581:	c9                   	leave  
80104582:	c3                   	ret    

80104583 <printpt>:
 //추가
int printpt(int pid) {
80104583:	55                   	push   %ebp
80104584:	89 e5                	mov    %esp,%ebp
80104586:	53                   	push   %ebx
80104587:	83 ec 14             	sub    $0x14,%esp
    struct proc *p;
    pde_t *pgdir;
    pte_t *pte;
    uint a;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010458a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104591:	eb 0f                	jmp    801045a2 <printpt+0x1f>
        if(p->pid == pid)
80104593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104596:	8b 40 10             	mov    0x10(%eax),%eax
80104599:	39 45 08             	cmp    %eax,0x8(%ebp)
8010459c:	74 0f                	je     801045ad <printpt+0x2a>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010459e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801045a2:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045a9:	72 e8                	jb     80104593 <printpt+0x10>
801045ab:	eb 01                	jmp    801045ae <printpt+0x2b>
            break;
801045ad:	90                   	nop
    }
    if(p == 0 || p->pid != pid)
801045ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045b2:	74 0b                	je     801045bf <printpt+0x3c>
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8b 40 10             	mov    0x10(%eax),%eax
801045ba:	39 45 08             	cmp    %eax,0x8(%ebp)
801045bd:	74 0a                	je     801045c9 <printpt+0x46>
        return -1;
801045bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c4:	e9 cc 00 00 00       	jmp    80104695 <printpt+0x112>
    pgdir = p->pgdir;
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	8b 40 04             	mov    0x4(%eax),%eax
801045cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    cprintf("START PAGE TABLE (pid %d)\n", pid);
801045d2:	83 ec 08             	sub    $0x8,%esp
801045d5:	ff 75 08             	push   0x8(%ebp)
801045d8:	68 31 a5 10 80       	push   $0x8010a531
801045dd:	e8 12 be ff ff       	call   801003f4 <cprintf>
801045e2:	83 c4 10             	add    $0x10,%esp
    for(a = 0; a < KERNBASE; a += PGSIZE) {
801045e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045ec:	e9 84 00 00 00       	jmp    80104675 <printpt+0xf2>
        pte = walkpgdir(pgdir, (void *)a, 0); 
801045f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045f4:	83 ec 04             	sub    $0x4,%esp
801045f7:	6a 00                	push   $0x0
801045f9:	50                   	push   %eax
801045fa:	ff 75 ec             	push   -0x14(%ebp)
801045fd:	e8 0a 2d 00 00       	call   8010730c <walkpgdir>
80104602:	83 c4 10             	add    $0x10,%esp
80104605:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(pte && (*pte & PTE_P)) {
80104608:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010460c:	74 60                	je     8010466e <printpt+0xeb>
8010460e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104611:	8b 00                	mov    (%eax),%eax
80104613:	83 e0 01             	and    $0x1,%eax
80104616:	85 c0                	test   %eax,%eax
80104618:	74 54                	je     8010466e <printpt+0xeb>
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
                (*pte & PTE_U) ? 'U' : 'K', //user or kernel
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
                PTE_ADDR(*pte)>>12); //프레임
8010461a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010461d:	8b 00                	mov    (%eax),%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
8010461f:	c1 e8 0c             	shr    $0xc,%eax
80104622:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
80104624:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104627:	8b 00                	mov    (%eax),%eax
80104629:	83 e0 02             	and    $0x2,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
8010462c:	85 c0                	test   %eax,%eax
8010462e:	74 07                	je     80104637 <printpt+0xb4>
80104630:	bb 57 00 00 00       	mov    $0x57,%ebx
80104635:	eb 05                	jmp    8010463c <printpt+0xb9>
80104637:	bb 2d 00 00 00       	mov    $0x2d,%ebx
                (*pte & PTE_U) ? 'U' : 'K', //user or kernel
8010463c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010463f:	8b 00                	mov    (%eax),%eax
80104641:	83 e0 04             	and    $0x4,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104644:	85 c0                	test   %eax,%eax
80104646:	74 07                	je     8010464f <printpt+0xcc>
80104648:	b9 55 00 00 00       	mov    $0x55,%ecx
8010464d:	eb 05                	jmp    80104654 <printpt+0xd1>
8010464f:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104657:	c1 e8 0c             	shr    $0xc,%eax
8010465a:	83 ec 0c             	sub    $0xc,%esp
8010465d:	52                   	push   %edx
8010465e:	53                   	push   %ebx
8010465f:	51                   	push   %ecx
80104660:	50                   	push   %eax
80104661:	68 4c a5 10 80       	push   $0x8010a54c
80104666:	e8 89 bd ff ff       	call   801003f4 <cprintf>
8010466b:	83 c4 20             	add    $0x20,%esp
    for(a = 0; a < KERNBASE; a += PGSIZE) {
8010466e:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104678:	85 c0                	test   %eax,%eax
8010467a:	0f 89 71 ff ff ff    	jns    801045f1 <printpt+0x6e>
        }
    }
    
    cprintf("END PAGE TABLE\n");
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	68 5b a5 10 80       	push   $0x8010a55b
80104688:	e8 67 bd ff ff       	call   801003f4 <cprintf>
8010468d:	83 c4 10             	add    $0x10,%esp
    return 0;
80104690:	b8 00 00 00 00       	mov    $0x0,%eax
80104695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104698:	c9                   	leave  
80104699:	c3                   	ret    

8010469a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010469a:	55                   	push   %ebp
8010469b:	89 e5                	mov    %esp,%ebp
8010469d:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046a0:	8b 45 08             	mov    0x8(%ebp),%eax
801046a3:	83 c0 04             	add    $0x4,%eax
801046a6:	83 ec 08             	sub    $0x8,%esp
801046a9:	68 95 a5 10 80       	push   $0x8010a595
801046ae:	50                   	push   %eax
801046af:	e8 43 01 00 00       	call   801047f7 <initlock>
801046b4:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046b7:	8b 45 08             	mov    0x8(%ebp),%eax
801046ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801046bd:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046c0:	8b 45 08             	mov    0x8(%ebp),%eax
801046c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046c9:	8b 45 08             	mov    0x8(%ebp),%eax
801046cc:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801046d3:	90                   	nop
801046d4:	c9                   	leave  
801046d5:	c3                   	ret    

801046d6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801046d6:	55                   	push   %ebp
801046d7:	89 e5                	mov    %esp,%ebp
801046d9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801046dc:	8b 45 08             	mov    0x8(%ebp),%eax
801046df:	83 c0 04             	add    $0x4,%eax
801046e2:	83 ec 0c             	sub    $0xc,%esp
801046e5:	50                   	push   %eax
801046e6:	e8 2e 01 00 00       	call   80104819 <acquire>
801046eb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801046ee:	eb 15                	jmp    80104705 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801046f0:	8b 45 08             	mov    0x8(%ebp),%eax
801046f3:	83 c0 04             	add    $0x4,%eax
801046f6:	83 ec 08             	sub    $0x8,%esp
801046f9:	50                   	push   %eax
801046fa:	ff 75 08             	push   0x8(%ebp)
801046fd:	e8 e5 fb ff ff       	call   801042e7 <sleep>
80104702:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104705:	8b 45 08             	mov    0x8(%ebp),%eax
80104708:	8b 00                	mov    (%eax),%eax
8010470a:	85 c0                	test   %eax,%eax
8010470c:	75 e2                	jne    801046f0 <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010470e:	8b 45 08             	mov    0x8(%ebp),%eax
80104711:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104717:	e8 22 f3 ff ff       	call   80103a3e <myproc>
8010471c:	8b 50 10             	mov    0x10(%eax),%edx
8010471f:	8b 45 08             	mov    0x8(%ebp),%eax
80104722:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104725:	8b 45 08             	mov    0x8(%ebp),%eax
80104728:	83 c0 04             	add    $0x4,%eax
8010472b:	83 ec 0c             	sub    $0xc,%esp
8010472e:	50                   	push   %eax
8010472f:	e8 53 01 00 00       	call   80104887 <release>
80104734:	83 c4 10             	add    $0x10,%esp
}
80104737:	90                   	nop
80104738:	c9                   	leave  
80104739:	c3                   	ret    

8010473a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010473a:	55                   	push   %ebp
8010473b:	89 e5                	mov    %esp,%ebp
8010473d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104740:	8b 45 08             	mov    0x8(%ebp),%eax
80104743:	83 c0 04             	add    $0x4,%eax
80104746:	83 ec 0c             	sub    $0xc,%esp
80104749:	50                   	push   %eax
8010474a:	e8 ca 00 00 00       	call   80104819 <acquire>
8010474f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104752:	8b 45 08             	mov    0x8(%ebp),%eax
80104755:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010475b:	8b 45 08             	mov    0x8(%ebp),%eax
8010475e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	ff 75 08             	push   0x8(%ebp)
8010476b:	e8 5e fc ff ff       	call   801043ce <wakeup>
80104770:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104773:	8b 45 08             	mov    0x8(%ebp),%eax
80104776:	83 c0 04             	add    $0x4,%eax
80104779:	83 ec 0c             	sub    $0xc,%esp
8010477c:	50                   	push   %eax
8010477d:	e8 05 01 00 00       	call   80104887 <release>
80104782:	83 c4 10             	add    $0x10,%esp
}
80104785:	90                   	nop
80104786:	c9                   	leave  
80104787:	c3                   	ret    

80104788 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104788:	55                   	push   %ebp
80104789:	89 e5                	mov    %esp,%ebp
8010478b:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010478e:	8b 45 08             	mov    0x8(%ebp),%eax
80104791:	83 c0 04             	add    $0x4,%eax
80104794:	83 ec 0c             	sub    $0xc,%esp
80104797:	50                   	push   %eax
80104798:	e8 7c 00 00 00       	call   80104819 <acquire>
8010479d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047a0:	8b 45 08             	mov    0x8(%ebp),%eax
801047a3:	8b 00                	mov    (%eax),%eax
801047a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047a8:	8b 45 08             	mov    0x8(%ebp),%eax
801047ab:	83 c0 04             	add    $0x4,%eax
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	50                   	push   %eax
801047b2:	e8 d0 00 00 00       	call   80104887 <release>
801047b7:	83 c4 10             	add    $0x10,%esp
  return r;
801047ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047bd:	c9                   	leave  
801047be:	c3                   	ret    

801047bf <readeflags>:
{
801047bf:	55                   	push   %ebp
801047c0:	89 e5                	mov    %esp,%ebp
801047c2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047c5:	9c                   	pushf  
801047c6:	58                   	pop    %eax
801047c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047cd:	c9                   	leave  
801047ce:	c3                   	ret    

801047cf <cli>:
{
801047cf:	55                   	push   %ebp
801047d0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801047d2:	fa                   	cli    
}
801047d3:	90                   	nop
801047d4:	5d                   	pop    %ebp
801047d5:	c3                   	ret    

801047d6 <sti>:
{
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047d9:	fb                   	sti    
}
801047da:	90                   	nop
801047db:	5d                   	pop    %ebp
801047dc:	c3                   	ret    

801047dd <xchg>:
{
801047dd:	55                   	push   %ebp
801047de:	89 e5                	mov    %esp,%ebp
801047e0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801047e3:	8b 55 08             	mov    0x8(%ebp),%edx
801047e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801047e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801047ec:	f0 87 02             	lock xchg %eax,(%edx)
801047ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801047f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047f5:	c9                   	leave  
801047f6:	c3                   	ret    

801047f7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801047f7:	55                   	push   %ebp
801047f8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801047fa:	8b 45 08             	mov    0x8(%ebp),%eax
801047fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80104800:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104803:	8b 45 08             	mov    0x8(%ebp),%eax
80104806:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010480c:	8b 45 08             	mov    0x8(%ebp),%eax
8010480f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104816:	90                   	nop
80104817:	5d                   	pop    %ebp
80104818:	c3                   	ret    

80104819 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104819:	55                   	push   %ebp
8010481a:	89 e5                	mov    %esp,%ebp
8010481c:	53                   	push   %ebx
8010481d:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104820:	e8 5f 01 00 00       	call   80104984 <pushcli>
  if(holding(lk)){
80104825:	8b 45 08             	mov    0x8(%ebp),%eax
80104828:	83 ec 0c             	sub    $0xc,%esp
8010482b:	50                   	push   %eax
8010482c:	e8 23 01 00 00       	call   80104954 <holding>
80104831:	83 c4 10             	add    $0x10,%esp
80104834:	85 c0                	test   %eax,%eax
80104836:	74 0d                	je     80104845 <acquire+0x2c>
    panic("acquire");
80104838:	83 ec 0c             	sub    $0xc,%esp
8010483b:	68 a0 a5 10 80       	push   $0x8010a5a0
80104840:	e8 7c bd ff ff       	call   801005c1 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104845:	90                   	nop
80104846:	8b 45 08             	mov    0x8(%ebp),%eax
80104849:	83 ec 08             	sub    $0x8,%esp
8010484c:	6a 01                	push   $0x1
8010484e:	50                   	push   %eax
8010484f:	e8 89 ff ff ff       	call   801047dd <xchg>
80104854:	83 c4 10             	add    $0x10,%esp
80104857:	85 c0                	test   %eax,%eax
80104859:	75 eb                	jne    80104846 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010485b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104860:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104863:	e8 5e f1 ff ff       	call   801039c6 <mycpu>
80104868:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010486b:	8b 45 08             	mov    0x8(%ebp),%eax
8010486e:	83 c0 0c             	add    $0xc,%eax
80104871:	83 ec 08             	sub    $0x8,%esp
80104874:	50                   	push   %eax
80104875:	8d 45 08             	lea    0x8(%ebp),%eax
80104878:	50                   	push   %eax
80104879:	e8 5b 00 00 00       	call   801048d9 <getcallerpcs>
8010487e:	83 c4 10             	add    $0x10,%esp
}
80104881:	90                   	nop
80104882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104885:	c9                   	leave  
80104886:	c3                   	ret    

80104887 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104887:	55                   	push   %ebp
80104888:	89 e5                	mov    %esp,%ebp
8010488a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010488d:	83 ec 0c             	sub    $0xc,%esp
80104890:	ff 75 08             	push   0x8(%ebp)
80104893:	e8 bc 00 00 00       	call   80104954 <holding>
80104898:	83 c4 10             	add    $0x10,%esp
8010489b:	85 c0                	test   %eax,%eax
8010489d:	75 0d                	jne    801048ac <release+0x25>
    panic("release");
8010489f:	83 ec 0c             	sub    $0xc,%esp
801048a2:	68 a8 a5 10 80       	push   $0x8010a5a8
801048a7:	e8 15 bd ff ff       	call   801005c1 <panic>

  lk->pcs[0] = 0;
801048ac:	8b 45 08             	mov    0x8(%ebp),%eax
801048af:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048b6:	8b 45 08             	mov    0x8(%ebp),%eax
801048b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048c0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048c5:	8b 45 08             	mov    0x8(%ebp),%eax
801048c8:	8b 55 08             	mov    0x8(%ebp),%edx
801048cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801048d1:	e8 fb 00 00 00       	call   801049d1 <popcli>
}
801048d6:	90                   	nop
801048d7:	c9                   	leave  
801048d8:	c3                   	ret    

801048d9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801048d9:	55                   	push   %ebp
801048da:	89 e5                	mov    %esp,%ebp
801048dc:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801048df:	8b 45 08             	mov    0x8(%ebp),%eax
801048e2:	83 e8 08             	sub    $0x8,%eax
801048e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801048e8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801048ef:	eb 38                	jmp    80104929 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801048f1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801048f5:	74 53                	je     8010494a <getcallerpcs+0x71>
801048f7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801048fe:	76 4a                	jbe    8010494a <getcallerpcs+0x71>
80104900:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104904:	74 44                	je     8010494a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104906:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104909:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104910:	8b 45 0c             	mov    0xc(%ebp),%eax
80104913:	01 c2                	add    %eax,%edx
80104915:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104918:	8b 40 04             	mov    0x4(%eax),%eax
8010491b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010491d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104920:	8b 00                	mov    (%eax),%eax
80104922:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104925:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104929:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010492d:	7e c2                	jle    801048f1 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010492f:	eb 19                	jmp    8010494a <getcallerpcs+0x71>
    pcs[i] = 0;
80104931:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104934:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010493b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010493e:	01 d0                	add    %edx,%eax
80104940:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104946:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010494a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010494e:	7e e1                	jle    80104931 <getcallerpcs+0x58>
}
80104950:	90                   	nop
80104951:	90                   	nop
80104952:	c9                   	leave  
80104953:	c3                   	ret    

80104954 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104954:	55                   	push   %ebp
80104955:	89 e5                	mov    %esp,%ebp
80104957:	53                   	push   %ebx
80104958:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010495b:	8b 45 08             	mov    0x8(%ebp),%eax
8010495e:	8b 00                	mov    (%eax),%eax
80104960:	85 c0                	test   %eax,%eax
80104962:	74 16                	je     8010497a <holding+0x26>
80104964:	8b 45 08             	mov    0x8(%ebp),%eax
80104967:	8b 58 08             	mov    0x8(%eax),%ebx
8010496a:	e8 57 f0 ff ff       	call   801039c6 <mycpu>
8010496f:	39 c3                	cmp    %eax,%ebx
80104971:	75 07                	jne    8010497a <holding+0x26>
80104973:	b8 01 00 00 00       	mov    $0x1,%eax
80104978:	eb 05                	jmp    8010497f <holding+0x2b>
8010497a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010497f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104982:	c9                   	leave  
80104983:	c3                   	ret    

80104984 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104984:	55                   	push   %ebp
80104985:	89 e5                	mov    %esp,%ebp
80104987:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010498a:	e8 30 fe ff ff       	call   801047bf <readeflags>
8010498f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104992:	e8 38 fe ff ff       	call   801047cf <cli>
  if(mycpu()->ncli == 0)
80104997:	e8 2a f0 ff ff       	call   801039c6 <mycpu>
8010499c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049a2:	85 c0                	test   %eax,%eax
801049a4:	75 14                	jne    801049ba <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049a6:	e8 1b f0 ff ff       	call   801039c6 <mycpu>
801049ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049ae:	81 e2 00 02 00 00    	and    $0x200,%edx
801049b4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049ba:	e8 07 f0 ff ff       	call   801039c6 <mycpu>
801049bf:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049c5:	83 c2 01             	add    $0x1,%edx
801049c8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801049ce:	90                   	nop
801049cf:	c9                   	leave  
801049d0:	c3                   	ret    

801049d1 <popcli>:

void
popcli(void)
{
801049d1:	55                   	push   %ebp
801049d2:	89 e5                	mov    %esp,%ebp
801049d4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801049d7:	e8 e3 fd ff ff       	call   801047bf <readeflags>
801049dc:	25 00 02 00 00       	and    $0x200,%eax
801049e1:	85 c0                	test   %eax,%eax
801049e3:	74 0d                	je     801049f2 <popcli+0x21>
    panic("popcli - interruptible");
801049e5:	83 ec 0c             	sub    $0xc,%esp
801049e8:	68 b0 a5 10 80       	push   $0x8010a5b0
801049ed:	e8 cf bb ff ff       	call   801005c1 <panic>
  if(--mycpu()->ncli < 0)
801049f2:	e8 cf ef ff ff       	call   801039c6 <mycpu>
801049f7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049fd:	83 ea 01             	sub    $0x1,%edx
80104a00:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a06:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a0c:	85 c0                	test   %eax,%eax
80104a0e:	79 0d                	jns    80104a1d <popcli+0x4c>
    panic("popcli");
80104a10:	83 ec 0c             	sub    $0xc,%esp
80104a13:	68 c7 a5 10 80       	push   $0x8010a5c7
80104a18:	e8 a4 bb ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a1d:	e8 a4 ef ff ff       	call   801039c6 <mycpu>
80104a22:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a28:	85 c0                	test   %eax,%eax
80104a2a:	75 14                	jne    80104a40 <popcli+0x6f>
80104a2c:	e8 95 ef ff ff       	call   801039c6 <mycpu>
80104a31:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a37:	85 c0                	test   %eax,%eax
80104a39:	74 05                	je     80104a40 <popcli+0x6f>
    sti();
80104a3b:	e8 96 fd ff ff       	call   801047d6 <sti>
}
80104a40:	90                   	nop
80104a41:	c9                   	leave  
80104a42:	c3                   	ret    

80104a43 <stosb>:
{
80104a43:	55                   	push   %ebp
80104a44:	89 e5                	mov    %esp,%ebp
80104a46:	57                   	push   %edi
80104a47:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a4b:	8b 55 10             	mov    0x10(%ebp),%edx
80104a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a51:	89 cb                	mov    %ecx,%ebx
80104a53:	89 df                	mov    %ebx,%edi
80104a55:	89 d1                	mov    %edx,%ecx
80104a57:	fc                   	cld    
80104a58:	f3 aa                	rep stos %al,%es:(%edi)
80104a5a:	89 ca                	mov    %ecx,%edx
80104a5c:	89 fb                	mov    %edi,%ebx
80104a5e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a61:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a64:	90                   	nop
80104a65:	5b                   	pop    %ebx
80104a66:	5f                   	pop    %edi
80104a67:	5d                   	pop    %ebp
80104a68:	c3                   	ret    

80104a69 <stosl>:
{
80104a69:	55                   	push   %ebp
80104a6a:	89 e5                	mov    %esp,%ebp
80104a6c:	57                   	push   %edi
80104a6d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a71:	8b 55 10             	mov    0x10(%ebp),%edx
80104a74:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a77:	89 cb                	mov    %ecx,%ebx
80104a79:	89 df                	mov    %ebx,%edi
80104a7b:	89 d1                	mov    %edx,%ecx
80104a7d:	fc                   	cld    
80104a7e:	f3 ab                	rep stos %eax,%es:(%edi)
80104a80:	89 ca                	mov    %ecx,%edx
80104a82:	89 fb                	mov    %edi,%ebx
80104a84:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a87:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a8a:	90                   	nop
80104a8b:	5b                   	pop    %ebx
80104a8c:	5f                   	pop    %edi
80104a8d:	5d                   	pop    %ebp
80104a8e:	c3                   	ret    

80104a8f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104a8f:	55                   	push   %ebp
80104a90:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104a92:	8b 45 08             	mov    0x8(%ebp),%eax
80104a95:	83 e0 03             	and    $0x3,%eax
80104a98:	85 c0                	test   %eax,%eax
80104a9a:	75 43                	jne    80104adf <memset+0x50>
80104a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80104a9f:	83 e0 03             	and    $0x3,%eax
80104aa2:	85 c0                	test   %eax,%eax
80104aa4:	75 39                	jne    80104adf <memset+0x50>
    c &= 0xFF;
80104aa6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104aad:	8b 45 10             	mov    0x10(%ebp),%eax
80104ab0:	c1 e8 02             	shr    $0x2,%eax
80104ab3:	89 c2                	mov    %eax,%edx
80104ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ab8:	c1 e0 18             	shl    $0x18,%eax
80104abb:	89 c1                	mov    %eax,%ecx
80104abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ac0:	c1 e0 10             	shl    $0x10,%eax
80104ac3:	09 c1                	or     %eax,%ecx
80104ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ac8:	c1 e0 08             	shl    $0x8,%eax
80104acb:	09 c8                	or     %ecx,%eax
80104acd:	0b 45 0c             	or     0xc(%ebp),%eax
80104ad0:	52                   	push   %edx
80104ad1:	50                   	push   %eax
80104ad2:	ff 75 08             	push   0x8(%ebp)
80104ad5:	e8 8f ff ff ff       	call   80104a69 <stosl>
80104ada:	83 c4 0c             	add    $0xc,%esp
80104add:	eb 12                	jmp    80104af1 <memset+0x62>
  } else
    stosb(dst, c, n);
80104adf:	8b 45 10             	mov    0x10(%ebp),%eax
80104ae2:	50                   	push   %eax
80104ae3:	ff 75 0c             	push   0xc(%ebp)
80104ae6:	ff 75 08             	push   0x8(%ebp)
80104ae9:	e8 55 ff ff ff       	call   80104a43 <stosb>
80104aee:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104af1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104af4:	c9                   	leave  
80104af5:	c3                   	ret    

80104af6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104af6:	55                   	push   %ebp
80104af7:	89 e5                	mov    %esp,%ebp
80104af9:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104afc:	8b 45 08             	mov    0x8(%ebp),%eax
80104aff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b05:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b08:	eb 30                	jmp    80104b3a <memcmp+0x44>
    if(*s1 != *s2)
80104b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b0d:	0f b6 10             	movzbl (%eax),%edx
80104b10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b13:	0f b6 00             	movzbl (%eax),%eax
80104b16:	38 c2                	cmp    %al,%dl
80104b18:	74 18                	je     80104b32 <memcmp+0x3c>
      return *s1 - *s2;
80104b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b1d:	0f b6 00             	movzbl (%eax),%eax
80104b20:	0f b6 d0             	movzbl %al,%edx
80104b23:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b26:	0f b6 00             	movzbl (%eax),%eax
80104b29:	0f b6 c8             	movzbl %al,%ecx
80104b2c:	89 d0                	mov    %edx,%eax
80104b2e:	29 c8                	sub    %ecx,%eax
80104b30:	eb 1a                	jmp    80104b4c <memcmp+0x56>
    s1++, s2++;
80104b32:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b36:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b3a:	8b 45 10             	mov    0x10(%ebp),%eax
80104b3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b40:	89 55 10             	mov    %edx,0x10(%ebp)
80104b43:	85 c0                	test   %eax,%eax
80104b45:	75 c3                	jne    80104b0a <memcmp+0x14>
  }

  return 0;
80104b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b4c:	c9                   	leave  
80104b4d:	c3                   	ret    

80104b4e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b4e:	55                   	push   %ebp
80104b4f:	89 e5                	mov    %esp,%ebp
80104b51:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b63:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b66:	73 54                	jae    80104bbc <memmove+0x6e>
80104b68:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b6b:	8b 45 10             	mov    0x10(%ebp),%eax
80104b6e:	01 d0                	add    %edx,%eax
80104b70:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104b73:	73 47                	jae    80104bbc <memmove+0x6e>
    s += n;
80104b75:	8b 45 10             	mov    0x10(%ebp),%eax
80104b78:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104b7b:	8b 45 10             	mov    0x10(%ebp),%eax
80104b7e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104b81:	eb 13                	jmp    80104b96 <memmove+0x48>
      *--d = *--s;
80104b83:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104b87:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b8e:	0f b6 10             	movzbl (%eax),%edx
80104b91:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b94:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104b96:	8b 45 10             	mov    0x10(%ebp),%eax
80104b99:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b9c:	89 55 10             	mov    %edx,0x10(%ebp)
80104b9f:	85 c0                	test   %eax,%eax
80104ba1:	75 e0                	jne    80104b83 <memmove+0x35>
  if(s < d && s + n > d){
80104ba3:	eb 24                	jmp    80104bc9 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104ba5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ba8:	8d 42 01             	lea    0x1(%edx),%eax
80104bab:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bae:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bb1:	8d 48 01             	lea    0x1(%eax),%ecx
80104bb4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bb7:	0f b6 12             	movzbl (%edx),%edx
80104bba:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bbc:	8b 45 10             	mov    0x10(%ebp),%eax
80104bbf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bc2:	89 55 10             	mov    %edx,0x10(%ebp)
80104bc5:	85 c0                	test   %eax,%eax
80104bc7:	75 dc                	jne    80104ba5 <memmove+0x57>

  return dst;
80104bc9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bcc:	c9                   	leave  
80104bcd:	c3                   	ret    

80104bce <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104bce:	55                   	push   %ebp
80104bcf:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104bd1:	ff 75 10             	push   0x10(%ebp)
80104bd4:	ff 75 0c             	push   0xc(%ebp)
80104bd7:	ff 75 08             	push   0x8(%ebp)
80104bda:	e8 6f ff ff ff       	call   80104b4e <memmove>
80104bdf:	83 c4 0c             	add    $0xc,%esp
}
80104be2:	c9                   	leave  
80104be3:	c3                   	ret    

80104be4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104be4:	55                   	push   %ebp
80104be5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104be7:	eb 0c                	jmp    80104bf5 <strncmp+0x11>
    n--, p++, q++;
80104be9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104bed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104bf1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104bf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bf9:	74 1a                	je     80104c15 <strncmp+0x31>
80104bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfe:	0f b6 00             	movzbl (%eax),%eax
80104c01:	84 c0                	test   %al,%al
80104c03:	74 10                	je     80104c15 <strncmp+0x31>
80104c05:	8b 45 08             	mov    0x8(%ebp),%eax
80104c08:	0f b6 10             	movzbl (%eax),%edx
80104c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c0e:	0f b6 00             	movzbl (%eax),%eax
80104c11:	38 c2                	cmp    %al,%dl
80104c13:	74 d4                	je     80104be9 <strncmp+0x5>
  if(n == 0)
80104c15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c19:	75 07                	jne    80104c22 <strncmp+0x3e>
    return 0;
80104c1b:	b8 00 00 00 00       	mov    $0x0,%eax
80104c20:	eb 16                	jmp    80104c38 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c22:	8b 45 08             	mov    0x8(%ebp),%eax
80104c25:	0f b6 00             	movzbl (%eax),%eax
80104c28:	0f b6 d0             	movzbl %al,%edx
80104c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2e:	0f b6 00             	movzbl (%eax),%eax
80104c31:	0f b6 c8             	movzbl %al,%ecx
80104c34:	89 d0                	mov    %edx,%eax
80104c36:	29 c8                	sub    %ecx,%eax
}
80104c38:	5d                   	pop    %ebp
80104c39:	c3                   	ret    

80104c3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c3a:	55                   	push   %ebp
80104c3b:	89 e5                	mov    %esp,%ebp
80104c3d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c46:	90                   	nop
80104c47:	8b 45 10             	mov    0x10(%ebp),%eax
80104c4a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c4d:	89 55 10             	mov    %edx,0x10(%ebp)
80104c50:	85 c0                	test   %eax,%eax
80104c52:	7e 2c                	jle    80104c80 <strncpy+0x46>
80104c54:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c57:	8d 42 01             	lea    0x1(%edx),%eax
80104c5a:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c60:	8d 48 01             	lea    0x1(%eax),%ecx
80104c63:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c66:	0f b6 12             	movzbl (%edx),%edx
80104c69:	88 10                	mov    %dl,(%eax)
80104c6b:	0f b6 00             	movzbl (%eax),%eax
80104c6e:	84 c0                	test   %al,%al
80104c70:	75 d5                	jne    80104c47 <strncpy+0xd>
    ;
  while(n-- > 0)
80104c72:	eb 0c                	jmp    80104c80 <strncpy+0x46>
    *s++ = 0;
80104c74:	8b 45 08             	mov    0x8(%ebp),%eax
80104c77:	8d 50 01             	lea    0x1(%eax),%edx
80104c7a:	89 55 08             	mov    %edx,0x8(%ebp)
80104c7d:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104c80:	8b 45 10             	mov    0x10(%ebp),%eax
80104c83:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c86:	89 55 10             	mov    %edx,0x10(%ebp)
80104c89:	85 c0                	test   %eax,%eax
80104c8b:	7f e7                	jg     80104c74 <strncpy+0x3a>
  return os;
80104c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c90:	c9                   	leave  
80104c91:	c3                   	ret    

80104c92 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104c92:	55                   	push   %ebp
80104c93:	89 e5                	mov    %esp,%ebp
80104c95:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c98:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104c9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ca2:	7f 05                	jg     80104ca9 <safestrcpy+0x17>
    return os;
80104ca4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca7:	eb 32                	jmp    80104cdb <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ca9:	90                   	nop
80104caa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cb2:	7e 1e                	jle    80104cd2 <safestrcpy+0x40>
80104cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cb7:	8d 42 01             	lea    0x1(%edx),%eax
80104cba:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc0:	8d 48 01             	lea    0x1(%eax),%ecx
80104cc3:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cc6:	0f b6 12             	movzbl (%edx),%edx
80104cc9:	88 10                	mov    %dl,(%eax)
80104ccb:	0f b6 00             	movzbl (%eax),%eax
80104cce:	84 c0                	test   %al,%al
80104cd0:	75 d8                	jne    80104caa <safestrcpy+0x18>
    ;
  *s = 0;
80104cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104cd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cdb:	c9                   	leave  
80104cdc:	c3                   	ret    

80104cdd <strlen>:

int
strlen(const char *s)
{
80104cdd:	55                   	push   %ebp
80104cde:	89 e5                	mov    %esp,%ebp
80104ce0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104ce3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104cea:	eb 04                	jmp    80104cf0 <strlen+0x13>
80104cec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104cf0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf6:	01 d0                	add    %edx,%eax
80104cf8:	0f b6 00             	movzbl (%eax),%eax
80104cfb:	84 c0                	test   %al,%al
80104cfd:	75 ed                	jne    80104cec <strlen+0xf>
    ;
  return n;
80104cff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d02:	c9                   	leave  
80104d03:	c3                   	ret    

80104d04 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d04:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d08:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d0c:	55                   	push   %ebp
  pushl %ebx
80104d0d:	53                   	push   %ebx
  pushl %esi
80104d0e:	56                   	push   %esi
  pushl %edi
80104d0f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d10:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d12:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d14:	5f                   	pop    %edi
  popl %esi
80104d15:	5e                   	pop    %esi
  popl %ebx
80104d16:	5b                   	pop    %ebx
  popl %ebp
80104d17:	5d                   	pop    %ebp
  ret
80104d18:	c3                   	ret    

80104d19 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d19:	55                   	push   %ebp
80104d1a:	89 e5                	mov    %esp,%ebp

  if(addr >=KERNBASE || addr+4 > KERNBASE)
80104d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1f:	85 c0                	test   %eax,%eax
80104d21:	78 0d                	js     80104d30 <fetchint+0x17>
80104d23:	8b 45 08             	mov    0x8(%ebp),%eax
80104d26:	83 c0 04             	add    $0x4,%eax
80104d29:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104d2e:	76 07                	jbe    80104d37 <fetchint+0x1e>
    return -1;
80104d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d35:	eb 0f                	jmp    80104d46 <fetchint+0x2d>
  *ip = *(int*)(addr);
80104d37:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3a:	8b 10                	mov    (%eax),%edx
80104d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3f:	89 10                	mov    %edx,(%eax)
  return 0;
80104d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d46:	5d                   	pop    %ebp
80104d47:	c3                   	ret    

80104d48 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
80104d4b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >=KERNBASE)
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	85 c0                	test   %eax,%eax
80104d53:	79 07                	jns    80104d5c <fetchstr+0x14>
    return -1;
80104d55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d5a:	eb 40                	jmp    80104d9c <fetchstr+0x54>
  *pp = (char*)addr;
80104d5c:	8b 55 08             	mov    0x8(%ebp),%edx
80104d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d62:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE;
80104d64:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6e:	8b 00                	mov    (%eax),%eax
80104d70:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104d73:	eb 1a                	jmp    80104d8f <fetchstr+0x47>
    if(*s == 0)
80104d75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d78:	0f b6 00             	movzbl (%eax),%eax
80104d7b:	84 c0                	test   %al,%al
80104d7d:	75 0c                	jne    80104d8b <fetchstr+0x43>
      return s - *pp;
80104d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d82:	8b 10                	mov    (%eax),%edx
80104d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d87:	29 d0                	sub    %edx,%eax
80104d89:	eb 11                	jmp    80104d9c <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104d8b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d92:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104d95:	72 de                	jb     80104d75 <fetchstr+0x2d>
  }
  return -1;
80104d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d9c:	c9                   	leave  
80104d9d:	c3                   	ret    

80104d9e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104d9e:	55                   	push   %ebp
80104d9f:	89 e5                	mov    %esp,%ebp
80104da1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104da4:	e8 95 ec ff ff       	call   80103a3e <myproc>
80104da9:	8b 40 18             	mov    0x18(%eax),%eax
80104dac:	8b 50 44             	mov    0x44(%eax),%edx
80104daf:	8b 45 08             	mov    0x8(%ebp),%eax
80104db2:	c1 e0 02             	shl    $0x2,%eax
80104db5:	01 d0                	add    %edx,%eax
80104db7:	83 c0 04             	add    $0x4,%eax
80104dba:	83 ec 08             	sub    $0x8,%esp
80104dbd:	ff 75 0c             	push   0xc(%ebp)
80104dc0:	50                   	push   %eax
80104dc1:	e8 53 ff ff ff       	call   80104d19 <fetchint>
80104dc6:	83 c4 10             	add    $0x10,%esp
}
80104dc9:	c9                   	leave  
80104dca:	c3                   	ret    

80104dcb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104dcb:	55                   	push   %ebp
80104dcc:	89 e5                	mov    %esp,%ebp
80104dce:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104dd1:	83 ec 08             	sub    $0x8,%esp
80104dd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd7:	50                   	push   %eax
80104dd8:	ff 75 08             	push   0x8(%ebp)
80104ddb:	e8 be ff ff ff       	call   80104d9e <argint>
80104de0:	83 c4 10             	add    $0x10,%esp
80104de3:	85 c0                	test   %eax,%eax
80104de5:	79 07                	jns    80104dee <argptr+0x23>
    return -1;
80104de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dec:	eb 34                	jmp    80104e22 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104dee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104df2:	78 18                	js     80104e0c <argptr+0x41>
80104df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df7:	85 c0                	test   %eax,%eax
80104df9:	78 11                	js     80104e0c <argptr+0x41>
80104dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfe:	89 c2                	mov    %eax,%edx
80104e00:	8b 45 10             	mov    0x10(%ebp),%eax
80104e03:	01 d0                	add    %edx,%eax
80104e05:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104e0a:	76 07                	jbe    80104e13 <argptr+0x48>
    return -1;
80104e0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e11:	eb 0f                	jmp    80104e22 <argptr+0x57>
  *pp = (char*)i;
80104e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e16:	89 c2                	mov    %eax,%edx
80104e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1b:	89 10                	mov    %edx,(%eax)
  return 0;
80104e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e22:	c9                   	leave  
80104e23:	c3                   	ret    

80104e24 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e24:	55                   	push   %ebp
80104e25:	89 e5                	mov    %esp,%ebp
80104e27:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e2a:	83 ec 08             	sub    $0x8,%esp
80104e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e30:	50                   	push   %eax
80104e31:	ff 75 08             	push   0x8(%ebp)
80104e34:	e8 65 ff ff ff       	call   80104d9e <argint>
80104e39:	83 c4 10             	add    $0x10,%esp
80104e3c:	85 c0                	test   %eax,%eax
80104e3e:	79 07                	jns    80104e47 <argstr+0x23>
    return -1;
80104e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e45:	eb 12                	jmp    80104e59 <argstr+0x35>
  return fetchstr(addr, pp);
80104e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4a:	83 ec 08             	sub    $0x8,%esp
80104e4d:	ff 75 0c             	push   0xc(%ebp)
80104e50:	50                   	push   %eax
80104e51:	e8 f2 fe ff ff       	call   80104d48 <fetchstr>
80104e56:	83 c4 10             	add    $0x10,%esp
}
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <syscall>:

};

void
syscall(void)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e61:	e8 d8 eb ff ff       	call   80103a3e <myproc>
80104e66:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6c:	8b 40 18             	mov    0x18(%eax),%eax
80104e6f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e79:	7e 2f                	jle    80104eaa <syscall+0x4f>
80104e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e7e:	83 f8 16             	cmp    $0x16,%eax
80104e81:	77 27                	ja     80104eaa <syscall+0x4f>
80104e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e86:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e8d:	85 c0                	test   %eax,%eax
80104e8f:	74 19                	je     80104eaa <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e94:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e9b:	ff d0                	call   *%eax
80104e9d:	89 c2                	mov    %eax,%edx
80104e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea2:	8b 40 18             	mov    0x18(%eax),%eax
80104ea5:	89 50 1c             	mov    %edx,0x1c(%eax)
80104ea8:	eb 2c                	jmp    80104ed6 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ead:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb3:	8b 40 10             	mov    0x10(%eax),%eax
80104eb6:	ff 75 f0             	push   -0x10(%ebp)
80104eb9:	52                   	push   %edx
80104eba:	50                   	push   %eax
80104ebb:	68 ce a5 10 80       	push   $0x8010a5ce
80104ec0:	e8 2f b5 ff ff       	call   801003f4 <cprintf>
80104ec5:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecb:	8b 40 18             	mov    0x18(%eax),%eax
80104ece:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104ed5:	90                   	nop
80104ed6:	90                   	nop
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104edf:	83 ec 08             	sub    $0x8,%esp
80104ee2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ee5:	50                   	push   %eax
80104ee6:	ff 75 08             	push   0x8(%ebp)
80104ee9:	e8 b0 fe ff ff       	call   80104d9e <argint>
80104eee:	83 c4 10             	add    $0x10,%esp
80104ef1:	85 c0                	test   %eax,%eax
80104ef3:	79 07                	jns    80104efc <argfd+0x23>
    return -1;
80104ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104efa:	eb 4f                	jmp    80104f4b <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eff:	85 c0                	test   %eax,%eax
80104f01:	78 20                	js     80104f23 <argfd+0x4a>
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	83 f8 0f             	cmp    $0xf,%eax
80104f09:	7f 18                	jg     80104f23 <argfd+0x4a>
80104f0b:	e8 2e eb ff ff       	call   80103a3e <myproc>
80104f10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f13:	83 c2 08             	add    $0x8,%edx
80104f16:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f21:	75 07                	jne    80104f2a <argfd+0x51>
    return -1;
80104f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f28:	eb 21                	jmp    80104f4b <argfd+0x72>
  if(pfd)
80104f2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f2e:	74 08                	je     80104f38 <argfd+0x5f>
    *pfd = fd;
80104f30:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f36:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f3c:	74 08                	je     80104f46 <argfd+0x6d>
    *pf = f;
80104f3e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f44:	89 10                	mov    %edx,(%eax)
  return 0;
80104f46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f4b:	c9                   	leave  
80104f4c:	c3                   	ret    

80104f4d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f4d:	55                   	push   %ebp
80104f4e:	89 e5                	mov    %esp,%ebp
80104f50:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f53:	e8 e6 ea ff ff       	call   80103a3e <myproc>
80104f58:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f62:	eb 2a                	jmp    80104f8e <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f6a:	83 c2 08             	add    $0x8,%edx
80104f6d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f71:	85 c0                	test   %eax,%eax
80104f73:	75 15                	jne    80104f8a <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f7b:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f7e:	8b 55 08             	mov    0x8(%ebp),%edx
80104f81:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f88:	eb 0f                	jmp    80104f99 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104f8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f8e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f92:	7e d0                	jle    80104f64 <fdalloc+0x17>
    }
  }
  return -1;
80104f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f99:	c9                   	leave  
80104f9a:	c3                   	ret    

80104f9b <sys_dup>:

int
sys_dup(void)
{
80104f9b:	55                   	push   %ebp
80104f9c:	89 e5                	mov    %esp,%ebp
80104f9e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104fa1:	83 ec 04             	sub    $0x4,%esp
80104fa4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fa7:	50                   	push   %eax
80104fa8:	6a 00                	push   $0x0
80104faa:	6a 00                	push   $0x0
80104fac:	e8 28 ff ff ff       	call   80104ed9 <argfd>
80104fb1:	83 c4 10             	add    $0x10,%esp
80104fb4:	85 c0                	test   %eax,%eax
80104fb6:	79 07                	jns    80104fbf <sys_dup+0x24>
    return -1;
80104fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fbd:	eb 31                	jmp    80104ff0 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc2:	83 ec 0c             	sub    $0xc,%esp
80104fc5:	50                   	push   %eax
80104fc6:	e8 82 ff ff ff       	call   80104f4d <fdalloc>
80104fcb:	83 c4 10             	add    $0x10,%esp
80104fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fd5:	79 07                	jns    80104fde <sys_dup+0x43>
    return -1;
80104fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fdc:	eb 12                	jmp    80104ff0 <sys_dup+0x55>
  filedup(f);
80104fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe1:	83 ec 0c             	sub    $0xc,%esp
80104fe4:	50                   	push   %eax
80104fe5:	e8 6e c0 ff ff       	call   80101058 <filedup>
80104fea:	83 c4 10             	add    $0x10,%esp
  return fd;
80104fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ff0:	c9                   	leave  
80104ff1:	c3                   	ret    

80104ff2 <sys_read>:

int
sys_read(void)
{
80104ff2:	55                   	push   %ebp
80104ff3:	89 e5                	mov    %esp,%ebp
80104ff5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104ff8:	83 ec 04             	sub    $0x4,%esp
80104ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ffe:	50                   	push   %eax
80104fff:	6a 00                	push   $0x0
80105001:	6a 00                	push   $0x0
80105003:	e8 d1 fe ff ff       	call   80104ed9 <argfd>
80105008:	83 c4 10             	add    $0x10,%esp
8010500b:	85 c0                	test   %eax,%eax
8010500d:	78 2e                	js     8010503d <sys_read+0x4b>
8010500f:	83 ec 08             	sub    $0x8,%esp
80105012:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105015:	50                   	push   %eax
80105016:	6a 02                	push   $0x2
80105018:	e8 81 fd ff ff       	call   80104d9e <argint>
8010501d:	83 c4 10             	add    $0x10,%esp
80105020:	85 c0                	test   %eax,%eax
80105022:	78 19                	js     8010503d <sys_read+0x4b>
80105024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105027:	83 ec 04             	sub    $0x4,%esp
8010502a:	50                   	push   %eax
8010502b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010502e:	50                   	push   %eax
8010502f:	6a 01                	push   $0x1
80105031:	e8 95 fd ff ff       	call   80104dcb <argptr>
80105036:	83 c4 10             	add    $0x10,%esp
80105039:	85 c0                	test   %eax,%eax
8010503b:	79 07                	jns    80105044 <sys_read+0x52>
    return -1;
8010503d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105042:	eb 17                	jmp    8010505b <sys_read+0x69>
  return fileread(f, p, n);
80105044:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105047:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010504a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504d:	83 ec 04             	sub    $0x4,%esp
80105050:	51                   	push   %ecx
80105051:	52                   	push   %edx
80105052:	50                   	push   %eax
80105053:	e8 90 c1 ff ff       	call   801011e8 <fileread>
80105058:	83 c4 10             	add    $0x10,%esp
}
8010505b:	c9                   	leave  
8010505c:	c3                   	ret    

8010505d <sys_write>:

int
sys_write(void)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
80105060:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105063:	83 ec 04             	sub    $0x4,%esp
80105066:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105069:	50                   	push   %eax
8010506a:	6a 00                	push   $0x0
8010506c:	6a 00                	push   $0x0
8010506e:	e8 66 fe ff ff       	call   80104ed9 <argfd>
80105073:	83 c4 10             	add    $0x10,%esp
80105076:	85 c0                	test   %eax,%eax
80105078:	78 2e                	js     801050a8 <sys_write+0x4b>
8010507a:	83 ec 08             	sub    $0x8,%esp
8010507d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105080:	50                   	push   %eax
80105081:	6a 02                	push   $0x2
80105083:	e8 16 fd ff ff       	call   80104d9e <argint>
80105088:	83 c4 10             	add    $0x10,%esp
8010508b:	85 c0                	test   %eax,%eax
8010508d:	78 19                	js     801050a8 <sys_write+0x4b>
8010508f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105092:	83 ec 04             	sub    $0x4,%esp
80105095:	50                   	push   %eax
80105096:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105099:	50                   	push   %eax
8010509a:	6a 01                	push   $0x1
8010509c:	e8 2a fd ff ff       	call   80104dcb <argptr>
801050a1:	83 c4 10             	add    $0x10,%esp
801050a4:	85 c0                	test   %eax,%eax
801050a6:	79 07                	jns    801050af <sys_write+0x52>
    return -1;
801050a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ad:	eb 17                	jmp    801050c6 <sys_write+0x69>
  return filewrite(f, p, n);
801050af:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	83 ec 04             	sub    $0x4,%esp
801050bb:	51                   	push   %ecx
801050bc:	52                   	push   %edx
801050bd:	50                   	push   %eax
801050be:	e8 dd c1 ff ff       	call   801012a0 <filewrite>
801050c3:	83 c4 10             	add    $0x10,%esp
}
801050c6:	c9                   	leave  
801050c7:	c3                   	ret    

801050c8 <sys_close>:

int
sys_close(void)
{
801050c8:	55                   	push   %ebp
801050c9:	89 e5                	mov    %esp,%ebp
801050cb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801050ce:	83 ec 04             	sub    $0x4,%esp
801050d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050d4:	50                   	push   %eax
801050d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050d8:	50                   	push   %eax
801050d9:	6a 00                	push   $0x0
801050db:	e8 f9 fd ff ff       	call   80104ed9 <argfd>
801050e0:	83 c4 10             	add    $0x10,%esp
801050e3:	85 c0                	test   %eax,%eax
801050e5:	79 07                	jns    801050ee <sys_close+0x26>
    return -1;
801050e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ec:	eb 27                	jmp    80105115 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801050ee:	e8 4b e9 ff ff       	call   80103a3e <myproc>
801050f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f6:	83 c2 08             	add    $0x8,%edx
801050f9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105100:	00 
  fileclose(f);
80105101:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105104:	83 ec 0c             	sub    $0xc,%esp
80105107:	50                   	push   %eax
80105108:	e8 9c bf ff ff       	call   801010a9 <fileclose>
8010510d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105110:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105115:	c9                   	leave  
80105116:	c3                   	ret    

80105117 <sys_fstat>:

int
sys_fstat(void)
{
80105117:	55                   	push   %ebp
80105118:	89 e5                	mov    %esp,%ebp
8010511a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010511d:	83 ec 04             	sub    $0x4,%esp
80105120:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105123:	50                   	push   %eax
80105124:	6a 00                	push   $0x0
80105126:	6a 00                	push   $0x0
80105128:	e8 ac fd ff ff       	call   80104ed9 <argfd>
8010512d:	83 c4 10             	add    $0x10,%esp
80105130:	85 c0                	test   %eax,%eax
80105132:	78 17                	js     8010514b <sys_fstat+0x34>
80105134:	83 ec 04             	sub    $0x4,%esp
80105137:	6a 14                	push   $0x14
80105139:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010513c:	50                   	push   %eax
8010513d:	6a 01                	push   $0x1
8010513f:	e8 87 fc ff ff       	call   80104dcb <argptr>
80105144:	83 c4 10             	add    $0x10,%esp
80105147:	85 c0                	test   %eax,%eax
80105149:	79 07                	jns    80105152 <sys_fstat+0x3b>
    return -1;
8010514b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105150:	eb 13                	jmp    80105165 <sys_fstat+0x4e>
  return filestat(f, st);
80105152:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105158:	83 ec 08             	sub    $0x8,%esp
8010515b:	52                   	push   %edx
8010515c:	50                   	push   %eax
8010515d:	e8 2f c0 ff ff       	call   80101191 <filestat>
80105162:	83 c4 10             	add    $0x10,%esp
}
80105165:	c9                   	leave  
80105166:	c3                   	ret    

80105167 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105167:	55                   	push   %ebp
80105168:	89 e5                	mov    %esp,%ebp
8010516a:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010516d:	83 ec 08             	sub    $0x8,%esp
80105170:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105173:	50                   	push   %eax
80105174:	6a 00                	push   $0x0
80105176:	e8 a9 fc ff ff       	call   80104e24 <argstr>
8010517b:	83 c4 10             	add    $0x10,%esp
8010517e:	85 c0                	test   %eax,%eax
80105180:	78 15                	js     80105197 <sys_link+0x30>
80105182:	83 ec 08             	sub    $0x8,%esp
80105185:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105188:	50                   	push   %eax
80105189:	6a 01                	push   $0x1
8010518b:	e8 94 fc ff ff       	call   80104e24 <argstr>
80105190:	83 c4 10             	add    $0x10,%esp
80105193:	85 c0                	test   %eax,%eax
80105195:	79 0a                	jns    801051a1 <sys_link+0x3a>
    return -1;
80105197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010519c:	e9 68 01 00 00       	jmp    80105309 <sys_link+0x1a2>

  begin_op();
801051a1:	e8 a4 de ff ff       	call   8010304a <begin_op>
  if((ip = namei(old)) == 0){
801051a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801051a9:	83 ec 0c             	sub    $0xc,%esp
801051ac:	50                   	push   %eax
801051ad:	e8 79 d3 ff ff       	call   8010252b <namei>
801051b2:	83 c4 10             	add    $0x10,%esp
801051b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051bc:	75 0f                	jne    801051cd <sys_link+0x66>
    end_op();
801051be:	e8 13 df ff ff       	call   801030d6 <end_op>
    return -1;
801051c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c8:	e9 3c 01 00 00       	jmp    80105309 <sys_link+0x1a2>
  }

  ilock(ip);
801051cd:	83 ec 0c             	sub    $0xc,%esp
801051d0:	ff 75 f4             	push   -0xc(%ebp)
801051d3:	e8 20 c8 ff ff       	call   801019f8 <ilock>
801051d8:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801051db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051de:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801051e2:	66 83 f8 01          	cmp    $0x1,%ax
801051e6:	75 1d                	jne    80105205 <sys_link+0x9e>
    iunlockput(ip);
801051e8:	83 ec 0c             	sub    $0xc,%esp
801051eb:	ff 75 f4             	push   -0xc(%ebp)
801051ee:	e8 36 ca ff ff       	call   80101c29 <iunlockput>
801051f3:	83 c4 10             	add    $0x10,%esp
    end_op();
801051f6:	e8 db de ff ff       	call   801030d6 <end_op>
    return -1;
801051fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105200:	e9 04 01 00 00       	jmp    80105309 <sys_link+0x1a2>
  }

  ip->nlink++;
80105205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105208:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010520c:	83 c0 01             	add    $0x1,%eax
8010520f:	89 c2                	mov    %eax,%edx
80105211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105214:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105218:	83 ec 0c             	sub    $0xc,%esp
8010521b:	ff 75 f4             	push   -0xc(%ebp)
8010521e:	e8 f8 c5 ff ff       	call   8010181b <iupdate>
80105223:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105226:	83 ec 0c             	sub    $0xc,%esp
80105229:	ff 75 f4             	push   -0xc(%ebp)
8010522c:	e8 da c8 ff ff       	call   80101b0b <iunlock>
80105231:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105234:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105237:	83 ec 08             	sub    $0x8,%esp
8010523a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010523d:	52                   	push   %edx
8010523e:	50                   	push   %eax
8010523f:	e8 03 d3 ff ff       	call   80102547 <nameiparent>
80105244:	83 c4 10             	add    $0x10,%esp
80105247:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010524a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010524e:	74 71                	je     801052c1 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105250:	83 ec 0c             	sub    $0xc,%esp
80105253:	ff 75 f0             	push   -0x10(%ebp)
80105256:	e8 9d c7 ff ff       	call   801019f8 <ilock>
8010525b:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010525e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105261:	8b 10                	mov    (%eax),%edx
80105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105266:	8b 00                	mov    (%eax),%eax
80105268:	39 c2                	cmp    %eax,%edx
8010526a:	75 1d                	jne    80105289 <sys_link+0x122>
8010526c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526f:	8b 40 04             	mov    0x4(%eax),%eax
80105272:	83 ec 04             	sub    $0x4,%esp
80105275:	50                   	push   %eax
80105276:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105279:	50                   	push   %eax
8010527a:	ff 75 f0             	push   -0x10(%ebp)
8010527d:	e8 12 d0 ff ff       	call   80102294 <dirlink>
80105282:	83 c4 10             	add    $0x10,%esp
80105285:	85 c0                	test   %eax,%eax
80105287:	79 10                	jns    80105299 <sys_link+0x132>
    iunlockput(dp);
80105289:	83 ec 0c             	sub    $0xc,%esp
8010528c:	ff 75 f0             	push   -0x10(%ebp)
8010528f:	e8 95 c9 ff ff       	call   80101c29 <iunlockput>
80105294:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105297:	eb 29                	jmp    801052c2 <sys_link+0x15b>
  }
  iunlockput(dp);
80105299:	83 ec 0c             	sub    $0xc,%esp
8010529c:	ff 75 f0             	push   -0x10(%ebp)
8010529f:	e8 85 c9 ff ff       	call   80101c29 <iunlockput>
801052a4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801052a7:	83 ec 0c             	sub    $0xc,%esp
801052aa:	ff 75 f4             	push   -0xc(%ebp)
801052ad:	e8 a7 c8 ff ff       	call   80101b59 <iput>
801052b2:	83 c4 10             	add    $0x10,%esp

  end_op();
801052b5:	e8 1c de ff ff       	call   801030d6 <end_op>

  return 0;
801052ba:	b8 00 00 00 00       	mov    $0x0,%eax
801052bf:	eb 48                	jmp    80105309 <sys_link+0x1a2>
    goto bad;
801052c1:	90                   	nop

bad:
  ilock(ip);
801052c2:	83 ec 0c             	sub    $0xc,%esp
801052c5:	ff 75 f4             	push   -0xc(%ebp)
801052c8:	e8 2b c7 ff ff       	call   801019f8 <ilock>
801052cd:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801052d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801052d7:	83 e8 01             	sub    $0x1,%eax
801052da:	89 c2                	mov    %eax,%edx
801052dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052df:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801052e3:	83 ec 0c             	sub    $0xc,%esp
801052e6:	ff 75 f4             	push   -0xc(%ebp)
801052e9:	e8 2d c5 ff ff       	call   8010181b <iupdate>
801052ee:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801052f1:	83 ec 0c             	sub    $0xc,%esp
801052f4:	ff 75 f4             	push   -0xc(%ebp)
801052f7:	e8 2d c9 ff ff       	call   80101c29 <iunlockput>
801052fc:	83 c4 10             	add    $0x10,%esp
  end_op();
801052ff:	e8 d2 dd ff ff       	call   801030d6 <end_op>
  return -1;
80105304:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105309:	c9                   	leave  
8010530a:	c3                   	ret    

8010530b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010530b:	55                   	push   %ebp
8010530c:	89 e5                	mov    %esp,%ebp
8010530e:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105311:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105318:	eb 40                	jmp    8010535a <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010531a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010531d:	6a 10                	push   $0x10
8010531f:	50                   	push   %eax
80105320:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105323:	50                   	push   %eax
80105324:	ff 75 08             	push   0x8(%ebp)
80105327:	e8 b8 cb ff ff       	call   80101ee4 <readi>
8010532c:	83 c4 10             	add    $0x10,%esp
8010532f:	83 f8 10             	cmp    $0x10,%eax
80105332:	74 0d                	je     80105341 <isdirempty+0x36>
      panic("isdirempty: readi");
80105334:	83 ec 0c             	sub    $0xc,%esp
80105337:	68 ea a5 10 80       	push   $0x8010a5ea
8010533c:	e8 80 b2 ff ff       	call   801005c1 <panic>
    if(de.inum != 0)
80105341:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105345:	66 85 c0             	test   %ax,%ax
80105348:	74 07                	je     80105351 <isdirempty+0x46>
      return 0;
8010534a:	b8 00 00 00 00       	mov    $0x0,%eax
8010534f:	eb 1b                	jmp    8010536c <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105354:	83 c0 10             	add    $0x10,%eax
80105357:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	8b 50 58             	mov    0x58(%eax),%edx
80105360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105363:	39 c2                	cmp    %eax,%edx
80105365:	77 b3                	ja     8010531a <isdirempty+0xf>
  }
  return 1;
80105367:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010536c:	c9                   	leave  
8010536d:	c3                   	ret    

8010536e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010536e:	55                   	push   %ebp
8010536f:	89 e5                	mov    %esp,%ebp
80105371:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105374:	83 ec 08             	sub    $0x8,%esp
80105377:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010537a:	50                   	push   %eax
8010537b:	6a 00                	push   $0x0
8010537d:	e8 a2 fa ff ff       	call   80104e24 <argstr>
80105382:	83 c4 10             	add    $0x10,%esp
80105385:	85 c0                	test   %eax,%eax
80105387:	79 0a                	jns    80105393 <sys_unlink+0x25>
    return -1;
80105389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010538e:	e9 bf 01 00 00       	jmp    80105552 <sys_unlink+0x1e4>

  begin_op();
80105393:	e8 b2 dc ff ff       	call   8010304a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105398:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010539b:	83 ec 08             	sub    $0x8,%esp
8010539e:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801053a1:	52                   	push   %edx
801053a2:	50                   	push   %eax
801053a3:	e8 9f d1 ff ff       	call   80102547 <nameiparent>
801053a8:	83 c4 10             	add    $0x10,%esp
801053ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053b2:	75 0f                	jne    801053c3 <sys_unlink+0x55>
    end_op();
801053b4:	e8 1d dd ff ff       	call   801030d6 <end_op>
    return -1;
801053b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053be:	e9 8f 01 00 00       	jmp    80105552 <sys_unlink+0x1e4>
  }

  ilock(dp);
801053c3:	83 ec 0c             	sub    $0xc,%esp
801053c6:	ff 75 f4             	push   -0xc(%ebp)
801053c9:	e8 2a c6 ff ff       	call   801019f8 <ilock>
801053ce:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053d1:	83 ec 08             	sub    $0x8,%esp
801053d4:	68 fc a5 10 80       	push   $0x8010a5fc
801053d9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053dc:	50                   	push   %eax
801053dd:	e8 dd cd ff ff       	call   801021bf <namecmp>
801053e2:	83 c4 10             	add    $0x10,%esp
801053e5:	85 c0                	test   %eax,%eax
801053e7:	0f 84 49 01 00 00    	je     80105536 <sys_unlink+0x1c8>
801053ed:	83 ec 08             	sub    $0x8,%esp
801053f0:	68 fe a5 10 80       	push   $0x8010a5fe
801053f5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053f8:	50                   	push   %eax
801053f9:	e8 c1 cd ff ff       	call   801021bf <namecmp>
801053fe:	83 c4 10             	add    $0x10,%esp
80105401:	85 c0                	test   %eax,%eax
80105403:	0f 84 2d 01 00 00    	je     80105536 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105409:	83 ec 04             	sub    $0x4,%esp
8010540c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010540f:	50                   	push   %eax
80105410:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105413:	50                   	push   %eax
80105414:	ff 75 f4             	push   -0xc(%ebp)
80105417:	e8 be cd ff ff       	call   801021da <dirlookup>
8010541c:	83 c4 10             	add    $0x10,%esp
8010541f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105422:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105426:	0f 84 0d 01 00 00    	je     80105539 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010542c:	83 ec 0c             	sub    $0xc,%esp
8010542f:	ff 75 f0             	push   -0x10(%ebp)
80105432:	e8 c1 c5 ff ff       	call   801019f8 <ilock>
80105437:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010543a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105441:	66 85 c0             	test   %ax,%ax
80105444:	7f 0d                	jg     80105453 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105446:	83 ec 0c             	sub    $0xc,%esp
80105449:	68 01 a6 10 80       	push   $0x8010a601
8010544e:	e8 6e b1 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105456:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010545a:	66 83 f8 01          	cmp    $0x1,%ax
8010545e:	75 25                	jne    80105485 <sys_unlink+0x117>
80105460:	83 ec 0c             	sub    $0xc,%esp
80105463:	ff 75 f0             	push   -0x10(%ebp)
80105466:	e8 a0 fe ff ff       	call   8010530b <isdirempty>
8010546b:	83 c4 10             	add    $0x10,%esp
8010546e:	85 c0                	test   %eax,%eax
80105470:	75 13                	jne    80105485 <sys_unlink+0x117>
    iunlockput(ip);
80105472:	83 ec 0c             	sub    $0xc,%esp
80105475:	ff 75 f0             	push   -0x10(%ebp)
80105478:	e8 ac c7 ff ff       	call   80101c29 <iunlockput>
8010547d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105480:	e9 b5 00 00 00       	jmp    8010553a <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105485:	83 ec 04             	sub    $0x4,%esp
80105488:	6a 10                	push   $0x10
8010548a:	6a 00                	push   $0x0
8010548c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010548f:	50                   	push   %eax
80105490:	e8 fa f5 ff ff       	call   80104a8f <memset>
80105495:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105498:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010549b:	6a 10                	push   $0x10
8010549d:	50                   	push   %eax
8010549e:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054a1:	50                   	push   %eax
801054a2:	ff 75 f4             	push   -0xc(%ebp)
801054a5:	e8 8f cb ff ff       	call   80102039 <writei>
801054aa:	83 c4 10             	add    $0x10,%esp
801054ad:	83 f8 10             	cmp    $0x10,%eax
801054b0:	74 0d                	je     801054bf <sys_unlink+0x151>
    panic("unlink: writei");
801054b2:	83 ec 0c             	sub    $0xc,%esp
801054b5:	68 13 a6 10 80       	push   $0x8010a613
801054ba:	e8 02 b1 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR){
801054bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054c6:	66 83 f8 01          	cmp    $0x1,%ax
801054ca:	75 21                	jne    801054ed <sys_unlink+0x17f>
    dp->nlink--;
801054cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054d3:	83 e8 01             	sub    $0x1,%eax
801054d6:	89 c2                	mov    %eax,%edx
801054d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054db:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	ff 75 f4             	push   -0xc(%ebp)
801054e5:	e8 31 c3 ff ff       	call   8010181b <iupdate>
801054ea:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801054ed:	83 ec 0c             	sub    $0xc,%esp
801054f0:	ff 75 f4             	push   -0xc(%ebp)
801054f3:	e8 31 c7 ff ff       	call   80101c29 <iunlockput>
801054f8:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801054fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fe:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105502:	83 e8 01             	sub    $0x1,%eax
80105505:	89 c2                	mov    %eax,%edx
80105507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010550e:	83 ec 0c             	sub    $0xc,%esp
80105511:	ff 75 f0             	push   -0x10(%ebp)
80105514:	e8 02 c3 ff ff       	call   8010181b <iupdate>
80105519:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010551c:	83 ec 0c             	sub    $0xc,%esp
8010551f:	ff 75 f0             	push   -0x10(%ebp)
80105522:	e8 02 c7 ff ff       	call   80101c29 <iunlockput>
80105527:	83 c4 10             	add    $0x10,%esp

  end_op();
8010552a:	e8 a7 db ff ff       	call   801030d6 <end_op>

  return 0;
8010552f:	b8 00 00 00 00       	mov    $0x0,%eax
80105534:	eb 1c                	jmp    80105552 <sys_unlink+0x1e4>
    goto bad;
80105536:	90                   	nop
80105537:	eb 01                	jmp    8010553a <sys_unlink+0x1cc>
    goto bad;
80105539:	90                   	nop

bad:
  iunlockput(dp);
8010553a:	83 ec 0c             	sub    $0xc,%esp
8010553d:	ff 75 f4             	push   -0xc(%ebp)
80105540:	e8 e4 c6 ff ff       	call   80101c29 <iunlockput>
80105545:	83 c4 10             	add    $0x10,%esp
  end_op();
80105548:	e8 89 db ff ff       	call   801030d6 <end_op>
  return -1;
8010554d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105552:	c9                   	leave  
80105553:	c3                   	ret    

80105554 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	83 ec 38             	sub    $0x38,%esp
8010555a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010555d:	8b 55 10             	mov    0x10(%ebp),%edx
80105560:	8b 45 14             	mov    0x14(%ebp),%eax
80105563:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105567:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010556b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010556f:	83 ec 08             	sub    $0x8,%esp
80105572:	8d 45 de             	lea    -0x22(%ebp),%eax
80105575:	50                   	push   %eax
80105576:	ff 75 08             	push   0x8(%ebp)
80105579:	e8 c9 cf ff ff       	call   80102547 <nameiparent>
8010557e:	83 c4 10             	add    $0x10,%esp
80105581:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105584:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105588:	75 0a                	jne    80105594 <create+0x40>
    return 0;
8010558a:	b8 00 00 00 00       	mov    $0x0,%eax
8010558f:	e9 90 01 00 00       	jmp    80105724 <create+0x1d0>
  ilock(dp);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 f4             	push   -0xc(%ebp)
8010559a:	e8 59 c4 ff ff       	call   801019f8 <ilock>
8010559f:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801055a2:	83 ec 04             	sub    $0x4,%esp
801055a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055a8:	50                   	push   %eax
801055a9:	8d 45 de             	lea    -0x22(%ebp),%eax
801055ac:	50                   	push   %eax
801055ad:	ff 75 f4             	push   -0xc(%ebp)
801055b0:	e8 25 cc ff ff       	call   801021da <dirlookup>
801055b5:	83 c4 10             	add    $0x10,%esp
801055b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055bf:	74 50                	je     80105611 <create+0xbd>
    iunlockput(dp);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f4             	push   -0xc(%ebp)
801055c7:	e8 5d c6 ff ff       	call   80101c29 <iunlockput>
801055cc:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801055cf:	83 ec 0c             	sub    $0xc,%esp
801055d2:	ff 75 f0             	push   -0x10(%ebp)
801055d5:	e8 1e c4 ff ff       	call   801019f8 <ilock>
801055da:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801055dd:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801055e2:	75 15                	jne    801055f9 <create+0xa5>
801055e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055eb:	66 83 f8 02          	cmp    $0x2,%ax
801055ef:	75 08                	jne    801055f9 <create+0xa5>
      return ip;
801055f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f4:	e9 2b 01 00 00       	jmp    80105724 <create+0x1d0>
    iunlockput(ip);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	ff 75 f0             	push   -0x10(%ebp)
801055ff:	e8 25 c6 ff ff       	call   80101c29 <iunlockput>
80105604:	83 c4 10             	add    $0x10,%esp
    return 0;
80105607:	b8 00 00 00 00       	mov    $0x0,%eax
8010560c:	e9 13 01 00 00       	jmp    80105724 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105611:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105618:	8b 00                	mov    (%eax),%eax
8010561a:	83 ec 08             	sub    $0x8,%esp
8010561d:	52                   	push   %edx
8010561e:	50                   	push   %eax
8010561f:	e8 20 c1 ff ff       	call   80101744 <ialloc>
80105624:	83 c4 10             	add    $0x10,%esp
80105627:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010562a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010562e:	75 0d                	jne    8010563d <create+0xe9>
    panic("create: ialloc");
80105630:	83 ec 0c             	sub    $0xc,%esp
80105633:	68 22 a6 10 80       	push   $0x8010a622
80105638:	e8 84 af ff ff       	call   801005c1 <panic>

  ilock(ip);
8010563d:	83 ec 0c             	sub    $0xc,%esp
80105640:	ff 75 f0             	push   -0x10(%ebp)
80105643:	e8 b0 c3 ff ff       	call   801019f8 <ilock>
80105648:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010564b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105652:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105659:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010565d:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105664:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010566a:	83 ec 0c             	sub    $0xc,%esp
8010566d:	ff 75 f0             	push   -0x10(%ebp)
80105670:	e8 a6 c1 ff ff       	call   8010181b <iupdate>
80105675:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105678:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010567d:	75 6a                	jne    801056e9 <create+0x195>
    dp->nlink++;  // for ".."
8010567f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105682:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105686:	83 c0 01             	add    $0x1,%eax
80105689:	89 c2                	mov    %eax,%edx
8010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105692:	83 ec 0c             	sub    $0xc,%esp
80105695:	ff 75 f4             	push   -0xc(%ebp)
80105698:	e8 7e c1 ff ff       	call   8010181b <iupdate>
8010569d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801056a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a3:	8b 40 04             	mov    0x4(%eax),%eax
801056a6:	83 ec 04             	sub    $0x4,%esp
801056a9:	50                   	push   %eax
801056aa:	68 fc a5 10 80       	push   $0x8010a5fc
801056af:	ff 75 f0             	push   -0x10(%ebp)
801056b2:	e8 dd cb ff ff       	call   80102294 <dirlink>
801056b7:	83 c4 10             	add    $0x10,%esp
801056ba:	85 c0                	test   %eax,%eax
801056bc:	78 1e                	js     801056dc <create+0x188>
801056be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c1:	8b 40 04             	mov    0x4(%eax),%eax
801056c4:	83 ec 04             	sub    $0x4,%esp
801056c7:	50                   	push   %eax
801056c8:	68 fe a5 10 80       	push   $0x8010a5fe
801056cd:	ff 75 f0             	push   -0x10(%ebp)
801056d0:	e8 bf cb ff ff       	call   80102294 <dirlink>
801056d5:	83 c4 10             	add    $0x10,%esp
801056d8:	85 c0                	test   %eax,%eax
801056da:	79 0d                	jns    801056e9 <create+0x195>
      panic("create dots");
801056dc:	83 ec 0c             	sub    $0xc,%esp
801056df:	68 31 a6 10 80       	push   $0x8010a631
801056e4:	e8 d8 ae ff ff       	call   801005c1 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801056e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ec:	8b 40 04             	mov    0x4(%eax),%eax
801056ef:	83 ec 04             	sub    $0x4,%esp
801056f2:	50                   	push   %eax
801056f3:	8d 45 de             	lea    -0x22(%ebp),%eax
801056f6:	50                   	push   %eax
801056f7:	ff 75 f4             	push   -0xc(%ebp)
801056fa:	e8 95 cb ff ff       	call   80102294 <dirlink>
801056ff:	83 c4 10             	add    $0x10,%esp
80105702:	85 c0                	test   %eax,%eax
80105704:	79 0d                	jns    80105713 <create+0x1bf>
    panic("create: dirlink");
80105706:	83 ec 0c             	sub    $0xc,%esp
80105709:	68 3d a6 10 80       	push   $0x8010a63d
8010570e:	e8 ae ae ff ff       	call   801005c1 <panic>

  iunlockput(dp);
80105713:	83 ec 0c             	sub    $0xc,%esp
80105716:	ff 75 f4             	push   -0xc(%ebp)
80105719:	e8 0b c5 ff ff       	call   80101c29 <iunlockput>
8010571e:	83 c4 10             	add    $0x10,%esp

  return ip;
80105721:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105724:	c9                   	leave  
80105725:	c3                   	ret    

80105726 <sys_open>:

int
sys_open(void)
{
80105726:	55                   	push   %ebp
80105727:	89 e5                	mov    %esp,%ebp
80105729:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010572c:	83 ec 08             	sub    $0x8,%esp
8010572f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105732:	50                   	push   %eax
80105733:	6a 00                	push   $0x0
80105735:	e8 ea f6 ff ff       	call   80104e24 <argstr>
8010573a:	83 c4 10             	add    $0x10,%esp
8010573d:	85 c0                	test   %eax,%eax
8010573f:	78 15                	js     80105756 <sys_open+0x30>
80105741:	83 ec 08             	sub    $0x8,%esp
80105744:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105747:	50                   	push   %eax
80105748:	6a 01                	push   $0x1
8010574a:	e8 4f f6 ff ff       	call   80104d9e <argint>
8010574f:	83 c4 10             	add    $0x10,%esp
80105752:	85 c0                	test   %eax,%eax
80105754:	79 0a                	jns    80105760 <sys_open+0x3a>
    return -1;
80105756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010575b:	e9 61 01 00 00       	jmp    801058c1 <sys_open+0x19b>

  begin_op();
80105760:	e8 e5 d8 ff ff       	call   8010304a <begin_op>

  if(omode & O_CREATE){
80105765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105768:	25 00 02 00 00       	and    $0x200,%eax
8010576d:	85 c0                	test   %eax,%eax
8010576f:	74 2a                	je     8010579b <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105771:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105774:	6a 00                	push   $0x0
80105776:	6a 00                	push   $0x0
80105778:	6a 02                	push   $0x2
8010577a:	50                   	push   %eax
8010577b:	e8 d4 fd ff ff       	call   80105554 <create>
80105780:	83 c4 10             	add    $0x10,%esp
80105783:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105786:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010578a:	75 75                	jne    80105801 <sys_open+0xdb>
      end_op();
8010578c:	e8 45 d9 ff ff       	call   801030d6 <end_op>
      return -1;
80105791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105796:	e9 26 01 00 00       	jmp    801058c1 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010579b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010579e:	83 ec 0c             	sub    $0xc,%esp
801057a1:	50                   	push   %eax
801057a2:	e8 84 cd ff ff       	call   8010252b <namei>
801057a7:	83 c4 10             	add    $0x10,%esp
801057aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b1:	75 0f                	jne    801057c2 <sys_open+0x9c>
      end_op();
801057b3:	e8 1e d9 ff ff       	call   801030d6 <end_op>
      return -1;
801057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bd:	e9 ff 00 00 00       	jmp    801058c1 <sys_open+0x19b>
    }
    ilock(ip);
801057c2:	83 ec 0c             	sub    $0xc,%esp
801057c5:	ff 75 f4             	push   -0xc(%ebp)
801057c8:	e8 2b c2 ff ff       	call   801019f8 <ilock>
801057cd:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801057d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057d7:	66 83 f8 01          	cmp    $0x1,%ax
801057db:	75 24                	jne    80105801 <sys_open+0xdb>
801057dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057e0:	85 c0                	test   %eax,%eax
801057e2:	74 1d                	je     80105801 <sys_open+0xdb>
      iunlockput(ip);
801057e4:	83 ec 0c             	sub    $0xc,%esp
801057e7:	ff 75 f4             	push   -0xc(%ebp)
801057ea:	e8 3a c4 ff ff       	call   80101c29 <iunlockput>
801057ef:	83 c4 10             	add    $0x10,%esp
      end_op();
801057f2:	e8 df d8 ff ff       	call   801030d6 <end_op>
      return -1;
801057f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057fc:	e9 c0 00 00 00       	jmp    801058c1 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105801:	e8 e5 b7 ff ff       	call   80100feb <filealloc>
80105806:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105809:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010580d:	74 17                	je     80105826 <sys_open+0x100>
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	ff 75 f0             	push   -0x10(%ebp)
80105815:	e8 33 f7 ff ff       	call   80104f4d <fdalloc>
8010581a:	83 c4 10             	add    $0x10,%esp
8010581d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105820:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105824:	79 2e                	jns    80105854 <sys_open+0x12e>
    if(f)
80105826:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010582a:	74 0e                	je     8010583a <sys_open+0x114>
      fileclose(f);
8010582c:	83 ec 0c             	sub    $0xc,%esp
8010582f:	ff 75 f0             	push   -0x10(%ebp)
80105832:	e8 72 b8 ff ff       	call   801010a9 <fileclose>
80105837:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010583a:	83 ec 0c             	sub    $0xc,%esp
8010583d:	ff 75 f4             	push   -0xc(%ebp)
80105840:	e8 e4 c3 ff ff       	call   80101c29 <iunlockput>
80105845:	83 c4 10             	add    $0x10,%esp
    end_op();
80105848:	e8 89 d8 ff ff       	call   801030d6 <end_op>
    return -1;
8010584d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105852:	eb 6d                	jmp    801058c1 <sys_open+0x19b>
  }
  iunlock(ip);
80105854:	83 ec 0c             	sub    $0xc,%esp
80105857:	ff 75 f4             	push   -0xc(%ebp)
8010585a:	e8 ac c2 ff ff       	call   80101b0b <iunlock>
8010585f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105862:	e8 6f d8 ff ff       	call   801030d6 <end_op>

  f->type = FD_INODE;
80105867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105873:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105876:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105886:	83 e0 01             	and    $0x1,%eax
80105889:	85 c0                	test   %eax,%eax
8010588b:	0f 94 c0             	sete   %al
8010588e:	89 c2                	mov    %eax,%edx
80105890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105893:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105899:	83 e0 01             	and    $0x1,%eax
8010589c:	85 c0                	test   %eax,%eax
8010589e:	75 0a                	jne    801058aa <sys_open+0x184>
801058a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058a3:	83 e0 02             	and    $0x2,%eax
801058a6:	85 c0                	test   %eax,%eax
801058a8:	74 07                	je     801058b1 <sys_open+0x18b>
801058aa:	b8 01 00 00 00       	mov    $0x1,%eax
801058af:	eb 05                	jmp    801058b6 <sys_open+0x190>
801058b1:	b8 00 00 00 00       	mov    $0x0,%eax
801058b6:	89 c2                	mov    %eax,%edx
801058b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058be:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058c1:	c9                   	leave  
801058c2:	c3                   	ret    

801058c3 <sys_mkdir>:

int
sys_mkdir(void)
{
801058c3:	55                   	push   %ebp
801058c4:	89 e5                	mov    %esp,%ebp
801058c6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058c9:	e8 7c d7 ff ff       	call   8010304a <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058ce:	83 ec 08             	sub    $0x8,%esp
801058d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058d4:	50                   	push   %eax
801058d5:	6a 00                	push   $0x0
801058d7:	e8 48 f5 ff ff       	call   80104e24 <argstr>
801058dc:	83 c4 10             	add    $0x10,%esp
801058df:	85 c0                	test   %eax,%eax
801058e1:	78 1b                	js     801058fe <sys_mkdir+0x3b>
801058e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e6:	6a 00                	push   $0x0
801058e8:	6a 00                	push   $0x0
801058ea:	6a 01                	push   $0x1
801058ec:	50                   	push   %eax
801058ed:	e8 62 fc ff ff       	call   80105554 <create>
801058f2:	83 c4 10             	add    $0x10,%esp
801058f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058fc:	75 0c                	jne    8010590a <sys_mkdir+0x47>
    end_op();
801058fe:	e8 d3 d7 ff ff       	call   801030d6 <end_op>
    return -1;
80105903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105908:	eb 18                	jmp    80105922 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010590a:	83 ec 0c             	sub    $0xc,%esp
8010590d:	ff 75 f4             	push   -0xc(%ebp)
80105910:	e8 14 c3 ff ff       	call   80101c29 <iunlockput>
80105915:	83 c4 10             	add    $0x10,%esp
  end_op();
80105918:	e8 b9 d7 ff ff       	call   801030d6 <end_op>
  return 0;
8010591d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105922:	c9                   	leave  
80105923:	c3                   	ret    

80105924 <sys_mknod>:

int
sys_mknod(void)
{
80105924:	55                   	push   %ebp
80105925:	89 e5                	mov    %esp,%ebp
80105927:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010592a:	e8 1b d7 ff ff       	call   8010304a <begin_op>
  if((argstr(0, &path)) < 0 ||
8010592f:	83 ec 08             	sub    $0x8,%esp
80105932:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105935:	50                   	push   %eax
80105936:	6a 00                	push   $0x0
80105938:	e8 e7 f4 ff ff       	call   80104e24 <argstr>
8010593d:	83 c4 10             	add    $0x10,%esp
80105940:	85 c0                	test   %eax,%eax
80105942:	78 4f                	js     80105993 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105944:	83 ec 08             	sub    $0x8,%esp
80105947:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010594a:	50                   	push   %eax
8010594b:	6a 01                	push   $0x1
8010594d:	e8 4c f4 ff ff       	call   80104d9e <argint>
80105952:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105955:	85 c0                	test   %eax,%eax
80105957:	78 3a                	js     80105993 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105959:	83 ec 08             	sub    $0x8,%esp
8010595c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010595f:	50                   	push   %eax
80105960:	6a 02                	push   $0x2
80105962:	e8 37 f4 ff ff       	call   80104d9e <argint>
80105967:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010596a:	85 c0                	test   %eax,%eax
8010596c:	78 25                	js     80105993 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010596e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105971:	0f bf c8             	movswl %ax,%ecx
80105974:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105977:	0f bf d0             	movswl %ax,%edx
8010597a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597d:	51                   	push   %ecx
8010597e:	52                   	push   %edx
8010597f:	6a 03                	push   $0x3
80105981:	50                   	push   %eax
80105982:	e8 cd fb ff ff       	call   80105554 <create>
80105987:	83 c4 10             	add    $0x10,%esp
8010598a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010598d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105991:	75 0c                	jne    8010599f <sys_mknod+0x7b>
    end_op();
80105993:	e8 3e d7 ff ff       	call   801030d6 <end_op>
    return -1;
80105998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599d:	eb 18                	jmp    801059b7 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010599f:	83 ec 0c             	sub    $0xc,%esp
801059a2:	ff 75 f4             	push   -0xc(%ebp)
801059a5:	e8 7f c2 ff ff       	call   80101c29 <iunlockput>
801059aa:	83 c4 10             	add    $0x10,%esp
  end_op();
801059ad:	e8 24 d7 ff ff       	call   801030d6 <end_op>
  return 0;
801059b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059b7:	c9                   	leave  
801059b8:	c3                   	ret    

801059b9 <sys_chdir>:

int
sys_chdir(void)
{
801059b9:	55                   	push   %ebp
801059ba:	89 e5                	mov    %esp,%ebp
801059bc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059bf:	e8 7a e0 ff ff       	call   80103a3e <myproc>
801059c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059c7:	e8 7e d6 ff ff       	call   8010304a <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801059cc:	83 ec 08             	sub    $0x8,%esp
801059cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059d2:	50                   	push   %eax
801059d3:	6a 00                	push   $0x0
801059d5:	e8 4a f4 ff ff       	call   80104e24 <argstr>
801059da:	83 c4 10             	add    $0x10,%esp
801059dd:	85 c0                	test   %eax,%eax
801059df:	78 18                	js     801059f9 <sys_chdir+0x40>
801059e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059e4:	83 ec 0c             	sub    $0xc,%esp
801059e7:	50                   	push   %eax
801059e8:	e8 3e cb ff ff       	call   8010252b <namei>
801059ed:	83 c4 10             	add    $0x10,%esp
801059f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059f7:	75 0c                	jne    80105a05 <sys_chdir+0x4c>
    end_op();
801059f9:	e8 d8 d6 ff ff       	call   801030d6 <end_op>
    return -1;
801059fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a03:	eb 68                	jmp    80105a6d <sys_chdir+0xb4>
  }
  ilock(ip);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	ff 75 f0             	push   -0x10(%ebp)
80105a0b:	e8 e8 bf ff ff       	call   801019f8 <ilock>
80105a10:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a16:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a1a:	66 83 f8 01          	cmp    $0x1,%ax
80105a1e:	74 1a                	je     80105a3a <sys_chdir+0x81>
    iunlockput(ip);
80105a20:	83 ec 0c             	sub    $0xc,%esp
80105a23:	ff 75 f0             	push   -0x10(%ebp)
80105a26:	e8 fe c1 ff ff       	call   80101c29 <iunlockput>
80105a2b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a2e:	e8 a3 d6 ff ff       	call   801030d6 <end_op>
    return -1;
80105a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a38:	eb 33                	jmp    80105a6d <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a3a:	83 ec 0c             	sub    $0xc,%esp
80105a3d:	ff 75 f0             	push   -0x10(%ebp)
80105a40:	e8 c6 c0 ff ff       	call   80101b0b <iunlock>
80105a45:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4b:	8b 40 68             	mov    0x68(%eax),%eax
80105a4e:	83 ec 0c             	sub    $0xc,%esp
80105a51:	50                   	push   %eax
80105a52:	e8 02 c1 ff ff       	call   80101b59 <iput>
80105a57:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a5a:	e8 77 d6 ff ff       	call   801030d6 <end_op>
  curproc->cwd = ip;
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a65:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a6d:	c9                   	leave  
80105a6e:	c3                   	ret    

80105a6f <sys_exec>:

int
sys_exec(void)
{
80105a6f:	55                   	push   %ebp
80105a70:	89 e5                	mov    %esp,%ebp
80105a72:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a78:	83 ec 08             	sub    $0x8,%esp
80105a7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a7e:	50                   	push   %eax
80105a7f:	6a 00                	push   $0x0
80105a81:	e8 9e f3 ff ff       	call   80104e24 <argstr>
80105a86:	83 c4 10             	add    $0x10,%esp
80105a89:	85 c0                	test   %eax,%eax
80105a8b:	78 18                	js     80105aa5 <sys_exec+0x36>
80105a8d:	83 ec 08             	sub    $0x8,%esp
80105a90:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105a96:	50                   	push   %eax
80105a97:	6a 01                	push   $0x1
80105a99:	e8 00 f3 ff ff       	call   80104d9e <argint>
80105a9e:	83 c4 10             	add    $0x10,%esp
80105aa1:	85 c0                	test   %eax,%eax
80105aa3:	79 0a                	jns    80105aaf <sys_exec+0x40>
    return -1;
80105aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aaa:	e9 c6 00 00 00       	jmp    80105b75 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105aaf:	83 ec 04             	sub    $0x4,%esp
80105ab2:	68 80 00 00 00       	push   $0x80
80105ab7:	6a 00                	push   $0x0
80105ab9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105abf:	50                   	push   %eax
80105ac0:	e8 ca ef ff ff       	call   80104a8f <memset>
80105ac5:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ac8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad2:	83 f8 1f             	cmp    $0x1f,%eax
80105ad5:	76 0a                	jbe    80105ae1 <sys_exec+0x72>
      return -1;
80105ad7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adc:	e9 94 00 00 00       	jmp    80105b75 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae4:	c1 e0 02             	shl    $0x2,%eax
80105ae7:	89 c2                	mov    %eax,%edx
80105ae9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105aef:	01 c2                	add    %eax,%edx
80105af1:	83 ec 08             	sub    $0x8,%esp
80105af4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105afa:	50                   	push   %eax
80105afb:	52                   	push   %edx
80105afc:	e8 18 f2 ff ff       	call   80104d19 <fetchint>
80105b01:	83 c4 10             	add    $0x10,%esp
80105b04:	85 c0                	test   %eax,%eax
80105b06:	79 07                	jns    80105b0f <sys_exec+0xa0>
      return -1;
80105b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0d:	eb 66                	jmp    80105b75 <sys_exec+0x106>
    if(uarg == 0){
80105b0f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b15:	85 c0                	test   %eax,%eax
80105b17:	75 27                	jne    80105b40 <sys_exec+0xd1>
      argv[i] = 0;
80105b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b23:	00 00 00 00 
      break;
80105b27:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2b:	83 ec 08             	sub    $0x8,%esp
80105b2e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b34:	52                   	push   %edx
80105b35:	50                   	push   %eax
80105b36:	e8 5d b0 ff ff       	call   80100b98 <exec>
80105b3b:	83 c4 10             	add    $0x10,%esp
80105b3e:	eb 35                	jmp    80105b75 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b40:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b49:	c1 e0 02             	shl    $0x2,%eax
80105b4c:	01 c2                	add    %eax,%edx
80105b4e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b54:	83 ec 08             	sub    $0x8,%esp
80105b57:	52                   	push   %edx
80105b58:	50                   	push   %eax
80105b59:	e8 ea f1 ff ff       	call   80104d48 <fetchstr>
80105b5e:	83 c4 10             	add    $0x10,%esp
80105b61:	85 c0                	test   %eax,%eax
80105b63:	79 07                	jns    80105b6c <sys_exec+0xfd>
      return -1;
80105b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6a:	eb 09                	jmp    80105b75 <sys_exec+0x106>
  for(i=0;; i++){
80105b6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b70:	e9 5a ff ff ff       	jmp    80105acf <sys_exec+0x60>
}
80105b75:	c9                   	leave  
80105b76:	c3                   	ret    

80105b77 <sys_pipe>:

int
sys_pipe(void)
{
80105b77:	55                   	push   %ebp
80105b78:	89 e5                	mov    %esp,%ebp
80105b7a:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b7d:	83 ec 04             	sub    $0x4,%esp
80105b80:	6a 08                	push   $0x8
80105b82:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b85:	50                   	push   %eax
80105b86:	6a 00                	push   $0x0
80105b88:	e8 3e f2 ff ff       	call   80104dcb <argptr>
80105b8d:	83 c4 10             	add    $0x10,%esp
80105b90:	85 c0                	test   %eax,%eax
80105b92:	79 0a                	jns    80105b9e <sys_pipe+0x27>
    return -1;
80105b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b99:	e9 ae 00 00 00       	jmp    80105c4c <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105b9e:	83 ec 08             	sub    $0x8,%esp
80105ba1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ba4:	50                   	push   %eax
80105ba5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ba8:	50                   	push   %eax
80105ba9:	e8 cd d9 ff ff       	call   8010357b <pipealloc>
80105bae:	83 c4 10             	add    $0x10,%esp
80105bb1:	85 c0                	test   %eax,%eax
80105bb3:	79 0a                	jns    80105bbf <sys_pipe+0x48>
    return -1;
80105bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bba:	e9 8d 00 00 00       	jmp    80105c4c <sys_pipe+0xd5>
  fd0 = -1;
80105bbf:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bc9:	83 ec 0c             	sub    $0xc,%esp
80105bcc:	50                   	push   %eax
80105bcd:	e8 7b f3 ff ff       	call   80104f4d <fdalloc>
80105bd2:	83 c4 10             	add    $0x10,%esp
80105bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bdc:	78 18                	js     80105bf6 <sys_pipe+0x7f>
80105bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105be1:	83 ec 0c             	sub    $0xc,%esp
80105be4:	50                   	push   %eax
80105be5:	e8 63 f3 ff ff       	call   80104f4d <fdalloc>
80105bea:	83 c4 10             	add    $0x10,%esp
80105bed:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bf0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf4:	79 3e                	jns    80105c34 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105bf6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bfa:	78 13                	js     80105c0f <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105bfc:	e8 3d de ff ff       	call   80103a3e <myproc>
80105c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c04:	83 c2 08             	add    $0x8,%edx
80105c07:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c0e:	00 
    fileclose(rf);
80105c0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c12:	83 ec 0c             	sub    $0xc,%esp
80105c15:	50                   	push   %eax
80105c16:	e8 8e b4 ff ff       	call   801010a9 <fileclose>
80105c1b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c21:	83 ec 0c             	sub    $0xc,%esp
80105c24:	50                   	push   %eax
80105c25:	e8 7f b4 ff ff       	call   801010a9 <fileclose>
80105c2a:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c32:	eb 18                	jmp    80105c4c <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c3a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c3f:	8d 50 04             	lea    0x4(%eax),%edx
80105c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c45:	89 02                	mov    %eax,(%edx)
  return 0;
80105c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c4c:	c9                   	leave  
80105c4d:	c3                   	ret    

80105c4e <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
80105c4e:	55                   	push   %ebp
80105c4f:	89 e5                	mov    %esp,%ebp
80105c51:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c54:	e8 e4 e0 ff ff       	call   80103d3d <fork>
}
80105c59:	c9                   	leave  
80105c5a:	c3                   	ret    

80105c5b <sys_exit>:

int
sys_exit(void)
{
80105c5b:	55                   	push   %ebp
80105c5c:	89 e5                	mov    %esp,%ebp
80105c5e:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c61:	e8 50 e2 ff ff       	call   80103eb6 <exit>
  return 0;  // not reached
80105c66:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c6b:	c9                   	leave  
80105c6c:	c3                   	ret    

80105c6d <sys_wait>:

int
sys_wait(void)
{
80105c6d:	55                   	push   %ebp
80105c6e:	89 e5                	mov    %esp,%ebp
80105c70:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105c73:	e8 5e e3 ff ff       	call   80103fd6 <wait>
}
80105c78:	c9                   	leave  
80105c79:	c3                   	ret    

80105c7a <sys_kill>:

int
sys_kill(void)
{
80105c7a:	55                   	push   %ebp
80105c7b:	89 e5                	mov    %esp,%ebp
80105c7d:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c80:	83 ec 08             	sub    $0x8,%esp
80105c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c86:	50                   	push   %eax
80105c87:	6a 00                	push   $0x0
80105c89:	e8 10 f1 ff ff       	call   80104d9e <argint>
80105c8e:	83 c4 10             	add    $0x10,%esp
80105c91:	85 c0                	test   %eax,%eax
80105c93:	79 07                	jns    80105c9c <sys_kill+0x22>
    return -1;
80105c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9a:	eb 0f                	jmp    80105cab <sys_kill+0x31>
  return kill(pid);
80105c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9f:	83 ec 0c             	sub    $0xc,%esp
80105ca2:	50                   	push   %eax
80105ca3:	e8 5d e7 ff ff       	call   80104405 <kill>
80105ca8:	83 c4 10             	add    $0x10,%esp
}
80105cab:	c9                   	leave  
80105cac:	c3                   	ret    

80105cad <sys_getpid>:

int
sys_getpid(void)
{
80105cad:	55                   	push   %ebp
80105cae:	89 e5                	mov    %esp,%ebp
80105cb0:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105cb3:	e8 86 dd ff ff       	call   80103a3e <myproc>
80105cb8:	8b 40 10             	mov    0x10(%eax),%eax
}
80105cbb:	c9                   	leave  
80105cbc:	c3                   	ret    

80105cbd <sys_printpt>:
 //추가
int
sys_printpt(void)
{
80105cbd:	55                   	push   %ebp
80105cbe:	89 e5                	mov    %esp,%ebp
80105cc0:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105cc3:	83 ec 08             	sub    $0x8,%esp
80105cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cc9:	50                   	push   %eax
80105cca:	6a 00                	push   $0x0
80105ccc:	e8 cd f0 ff ff       	call   80104d9e <argint>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	79 07                	jns    80105cdf <sys_printpt+0x22>
    return -1;
80105cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdd:	eb 14                	jmp    80105cf3 <sys_printpt+0x36>
  printpt(pid);
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	83 ec 0c             	sub    $0xc,%esp
80105ce5:	50                   	push   %eax
80105ce6:	e8 98 e8 ff ff       	call   80104583 <printpt>
80105ceb:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf3:	c9                   	leave  
80105cf4:	c3                   	ret    

80105cf5 <sys_sbrk>:


int
sys_sbrk(void)
{
80105cf5:	55                   	push   %ebp
80105cf6:	89 e5                	mov    %esp,%ebp
80105cf8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105cfb:	83 ec 08             	sub    $0x8,%esp
80105cfe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d01:	50                   	push   %eax
80105d02:	6a 00                	push   $0x0
80105d04:	e8 95 f0 ff ff       	call   80104d9e <argint>
80105d09:	83 c4 10             	add    $0x10,%esp
80105d0c:	85 c0                	test   %eax,%eax
80105d0e:	79 07                	jns    80105d17 <sys_sbrk+0x22>
    return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	eb 27                	jmp    80105d3e <sys_sbrk+0x49>
  addr = myproc()->sz;
80105d17:	e8 22 dd ff ff       	call   80103a3e <myproc>
80105d1c:	8b 00                	mov    (%eax),%eax
80105d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d24:	83 ec 0c             	sub    $0xc,%esp
80105d27:	50                   	push   %eax
80105d28:	e8 75 df ff ff       	call   80103ca2 <growproc>
80105d2d:	83 c4 10             	add    $0x10,%esp
80105d30:	85 c0                	test   %eax,%eax
80105d32:	79 07                	jns    80105d3b <sys_sbrk+0x46>
    return -1;
80105d34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d39:	eb 03                	jmp    80105d3e <sys_sbrk+0x49>
  return addr;
80105d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d3e:	c9                   	leave  
80105d3f:	c3                   	ret    

80105d40 <sys_sleep>:

int
sys_sleep(void)
{
80105d40:	55                   	push   %ebp
80105d41:	89 e5                	mov    %esp,%ebp
80105d43:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d46:	83 ec 08             	sub    $0x8,%esp
80105d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4c:	50                   	push   %eax
80105d4d:	6a 00                	push   $0x0
80105d4f:	e8 4a f0 ff ff       	call   80104d9e <argint>
80105d54:	83 c4 10             	add    $0x10,%esp
80105d57:	85 c0                	test   %eax,%eax
80105d59:	79 07                	jns    80105d62 <sys_sleep+0x22>
    return -1;
80105d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d60:	eb 76                	jmp    80105dd8 <sys_sleep+0x98>
  acquire(&tickslock);
80105d62:	83 ec 0c             	sub    $0xc,%esp
80105d65:	68 40 69 19 80       	push   $0x80196940
80105d6a:	e8 aa ea ff ff       	call   80104819 <acquire>
80105d6f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105d72:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105d7a:	eb 38                	jmp    80105db4 <sys_sleep+0x74>
    if(myproc()->killed){
80105d7c:	e8 bd dc ff ff       	call   80103a3e <myproc>
80105d81:	8b 40 24             	mov    0x24(%eax),%eax
80105d84:	85 c0                	test   %eax,%eax
80105d86:	74 17                	je     80105d9f <sys_sleep+0x5f>
      release(&tickslock);
80105d88:	83 ec 0c             	sub    $0xc,%esp
80105d8b:	68 40 69 19 80       	push   $0x80196940
80105d90:	e8 f2 ea ff ff       	call   80104887 <release>
80105d95:	83 c4 10             	add    $0x10,%esp
      return -1;
80105d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9d:	eb 39                	jmp    80105dd8 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105d9f:	83 ec 08             	sub    $0x8,%esp
80105da2:	68 40 69 19 80       	push   $0x80196940
80105da7:	68 74 69 19 80       	push   $0x80196974
80105dac:	e8 36 e5 ff ff       	call   801042e7 <sleep>
80105db1:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105db4:	a1 74 69 19 80       	mov    0x80196974,%eax
80105db9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105dbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dbf:	39 d0                	cmp    %edx,%eax
80105dc1:	72 b9                	jb     80105d7c <sys_sleep+0x3c>
  }
  release(&tickslock);
80105dc3:	83 ec 0c             	sub    $0xc,%esp
80105dc6:	68 40 69 19 80       	push   $0x80196940
80105dcb:	e8 b7 ea ff ff       	call   80104887 <release>
80105dd0:	83 c4 10             	add    $0x10,%esp
  return 0;
80105dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dd8:	c9                   	leave  
80105dd9:	c3                   	ret    

80105dda <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105dda:	55                   	push   %ebp
80105ddb:	89 e5                	mov    %esp,%ebp
80105ddd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	68 40 69 19 80       	push   $0x80196940
80105de8:	e8 2c ea ff ff       	call   80104819 <acquire>
80105ded:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105df0:	a1 74 69 19 80       	mov    0x80196974,%eax
80105df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	68 40 69 19 80       	push   $0x80196940
80105e00:	e8 82 ea ff ff       	call   80104887 <release>
80105e05:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e0b:	c9                   	leave  
80105e0c:	c3                   	ret    

80105e0d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e0d:	1e                   	push   %ds
  pushl %es
80105e0e:	06                   	push   %es
  pushl %fs
80105e0f:	0f a0                	push   %fs
  pushl %gs
80105e11:	0f a8                	push   %gs
  pushal
80105e13:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e14:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e18:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e1a:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e1c:	54                   	push   %esp
  call trap
80105e1d:	e8 e3 01 00 00       	call   80106005 <trap>
  addl $4, %esp
80105e22:	83 c4 04             	add    $0x4,%esp

80105e25 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e25:	61                   	popa   
  popl %gs
80105e26:	0f a9                	pop    %gs
  popl %fs
80105e28:	0f a1                	pop    %fs
  popl %es
80105e2a:	07                   	pop    %es
  popl %ds
80105e2b:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e2c:	83 c4 08             	add    $0x8,%esp
  iret
80105e2f:	cf                   	iret   

80105e30 <lidt>:
{
80105e30:	55                   	push   %ebp
80105e31:	89 e5                	mov    %esp,%ebp
80105e33:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e39:	83 e8 01             	sub    $0x1,%eax
80105e3c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e40:	8b 45 08             	mov    0x8(%ebp),%eax
80105e43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e47:	8b 45 08             	mov    0x8(%ebp),%eax
80105e4a:	c1 e8 10             	shr    $0x10,%eax
80105e4d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e51:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e54:	0f 01 18             	lidtl  (%eax)
}
80105e57:	90                   	nop
80105e58:	c9                   	leave  
80105e59:	c3                   	ret    

80105e5a <rcr2>:

static inline uint
rcr2(void)
{
80105e5a:	55                   	push   %ebp
80105e5b:	89 e5                	mov    %esp,%ebp
80105e5d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e60:	0f 20 d0             	mov    %cr2,%eax
80105e63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105e66:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e69:	c9                   	leave  
80105e6a:	c3                   	ret    

80105e6b <lcr3>:

static inline void
lcr3(uint val)
{
80105e6b:	55                   	push   %ebp
80105e6c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e71:	0f 22 d8             	mov    %eax,%cr3
}
80105e74:	90                   	nop
80105e75:	5d                   	pop    %ebp
80105e76:	c3                   	ret    

80105e77 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105e77:	55                   	push   %ebp
80105e78:	89 e5                	mov    %esp,%ebp
80105e7a:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105e7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105e84:	e9 c3 00 00 00       	jmp    80105f4c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8c:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e93:	89 c2                	mov    %eax,%edx
80105e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e98:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105e9f:	80 
80105ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea3:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105eaa:	80 08 00 
80105ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb0:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105eb7:	80 
80105eb8:	83 e2 e0             	and    $0xffffffe0,%edx
80105ebb:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec5:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105ecc:	80 
80105ecd:	83 e2 1f             	and    $0x1f,%edx
80105ed0:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eda:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105ee1:	80 
80105ee2:	83 e2 f0             	and    $0xfffffff0,%edx
80105ee5:	83 ca 0e             	or     $0xe,%edx
80105ee8:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef2:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105ef9:	80 
80105efa:	83 e2 ef             	and    $0xffffffef,%edx
80105efd:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f07:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f0e:	80 
80105f0f:	83 e2 9f             	and    $0xffffff9f,%edx
80105f12:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1c:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f23:	80 
80105f24:	83 ca 80             	or     $0xffffff80,%edx
80105f27:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f31:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f38:	c1 e8 10             	shr    $0x10,%eax
80105f3b:	89 c2                	mov    %eax,%edx
80105f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f40:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105f47:	80 
  for(i = 0; i < 256; i++)
80105f48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105f4c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105f53:	0f 8e 30 ff ff ff    	jle    80105e89 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f59:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105f5e:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105f64:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105f6b:	08 00 
80105f6d:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f74:	83 e0 e0             	and    $0xffffffe0,%eax
80105f77:	a2 44 63 19 80       	mov    %al,0x80196344
80105f7c:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f83:	83 e0 1f             	and    $0x1f,%eax
80105f86:	a2 44 63 19 80       	mov    %al,0x80196344
80105f8b:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f92:	83 c8 0f             	or     $0xf,%eax
80105f95:	a2 45 63 19 80       	mov    %al,0x80196345
80105f9a:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fa1:	83 e0 ef             	and    $0xffffffef,%eax
80105fa4:	a2 45 63 19 80       	mov    %al,0x80196345
80105fa9:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fb0:	83 c8 60             	or     $0x60,%eax
80105fb3:	a2 45 63 19 80       	mov    %al,0x80196345
80105fb8:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fbf:	83 c8 80             	or     $0xffffff80,%eax
80105fc2:	a2 45 63 19 80       	mov    %al,0x80196345
80105fc7:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fcc:	c1 e8 10             	shr    $0x10,%eax
80105fcf:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
80105fd5:	83 ec 08             	sub    $0x8,%esp
80105fd8:	68 50 a6 10 80       	push   $0x8010a650
80105fdd:	68 40 69 19 80       	push   $0x80196940
80105fe2:	e8 10 e8 ff ff       	call   801047f7 <initlock>
80105fe7:	83 c4 10             	add    $0x10,%esp
}
80105fea:	90                   	nop
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <idtinit>:

void
idtinit(void)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105ff0:	68 00 08 00 00       	push   $0x800
80105ff5:	68 40 61 19 80       	push   $0x80196140
80105ffa:	e8 31 fe ff ff       	call   80105e30 <lidt>
80105fff:	83 c4 08             	add    $0x8,%esp
}
80106002:	90                   	nop
80106003:	c9                   	leave  
80106004:	c3                   	ret    

80106005 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106005:	55                   	push   %ebp
80106006:	89 e5                	mov    %esp,%ebp
80106008:	57                   	push   %edi
80106009:	56                   	push   %esi
8010600a:	53                   	push   %ebx
8010600b:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010600e:	8b 45 08             	mov    0x8(%ebp),%eax
80106011:	8b 40 30             	mov    0x30(%eax),%eax
80106014:	83 f8 40             	cmp    $0x40,%eax
80106017:	75 3b                	jne    80106054 <trap+0x4f>
    if(myproc()->killed)
80106019:	e8 20 da ff ff       	call   80103a3e <myproc>
8010601e:	8b 40 24             	mov    0x24(%eax),%eax
80106021:	85 c0                	test   %eax,%eax
80106023:	74 05                	je     8010602a <trap+0x25>
      exit();
80106025:	e8 8c de ff ff       	call   80103eb6 <exit>
    myproc()->tf = tf;
8010602a:	e8 0f da ff ff       	call   80103a3e <myproc>
8010602f:	8b 55 08             	mov    0x8(%ebp),%edx
80106032:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106035:	e8 21 ee ff ff       	call   80104e5b <syscall>
    if(myproc()->killed)
8010603a:	e8 ff d9 ff ff       	call   80103a3e <myproc>
8010603f:	8b 40 24             	mov    0x24(%eax),%eax
80106042:	85 c0                	test   %eax,%eax
80106044:	0f 84 be 02 00 00    	je     80106308 <trap+0x303>
      exit();
8010604a:	e8 67 de ff ff       	call   80103eb6 <exit>
    return;
8010604f:	e9 b4 02 00 00       	jmp    80106308 <trap+0x303>
  }

  switch(tf->trapno){
80106054:	8b 45 08             	mov    0x8(%ebp),%eax
80106057:	8b 40 30             	mov    0x30(%eax),%eax
8010605a:	83 e8 0e             	sub    $0xe,%eax
8010605d:	83 f8 31             	cmp    $0x31,%eax
80106060:	0f 87 6d 01 00 00    	ja     801061d3 <trap+0x1ce>
80106066:	8b 04 85 18 a7 10 80 	mov    -0x7fef58e8(,%eax,4),%eax
8010606d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010606f:	e8 37 d9 ff ff       	call   801039ab <cpuid>
80106074:	85 c0                	test   %eax,%eax
80106076:	75 3d                	jne    801060b5 <trap+0xb0>
      acquire(&tickslock);
80106078:	83 ec 0c             	sub    $0xc,%esp
8010607b:	68 40 69 19 80       	push   $0x80196940
80106080:	e8 94 e7 ff ff       	call   80104819 <acquire>
80106085:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106088:	a1 74 69 19 80       	mov    0x80196974,%eax
8010608d:	83 c0 01             	add    $0x1,%eax
80106090:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	68 74 69 19 80       	push   $0x80196974
8010609d:	e8 2c e3 ff ff       	call   801043ce <wakeup>
801060a2:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801060a5:	83 ec 0c             	sub    $0xc,%esp
801060a8:	68 40 69 19 80       	push   $0x80196940
801060ad:	e8 d5 e7 ff ff       	call   80104887 <release>
801060b2:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801060b5:	e8 70 ca ff ff       	call   80102b2a <lapiceoi>
    break;
801060ba:	e9 c9 01 00 00       	jmp    80106288 <trap+0x283>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801060bf:	e8 89 3f 00 00       	call   8010a04d <ideintr>
    lapiceoi();
801060c4:	e8 61 ca ff ff       	call   80102b2a <lapiceoi>
    break;
801060c9:	e9 ba 01 00 00       	jmp    80106288 <trap+0x283>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801060ce:	e8 9c c8 ff ff       	call   8010296f <kbdintr>
    lapiceoi();
801060d3:	e8 52 ca ff ff       	call   80102b2a <lapiceoi>
    break;
801060d8:	e9 ab 01 00 00       	jmp    80106288 <trap+0x283>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801060dd:	e8 fc 03 00 00       	call   801064de <uartintr>
    lapiceoi();
801060e2:	e8 43 ca ff ff       	call   80102b2a <lapiceoi>
    break;
801060e7:	e9 9c 01 00 00       	jmp    80106288 <trap+0x283>
  case T_IRQ0 + 0xB:
    i8254_intr();
801060ec:	e8 0f 2c 00 00       	call   80108d00 <i8254_intr>
    lapiceoi();
801060f1:	e8 34 ca ff ff       	call   80102b2a <lapiceoi>
    break;
801060f6:	e9 8d 01 00 00       	jmp    80106288 <trap+0x283>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060fb:	8b 45 08             	mov    0x8(%ebp),%eax
801060fe:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106101:	8b 45 08             	mov    0x8(%ebp),%eax
80106104:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106108:	0f b7 d8             	movzwl %ax,%ebx
8010610b:	e8 9b d8 ff ff       	call   801039ab <cpuid>
80106110:	56                   	push   %esi
80106111:	53                   	push   %ebx
80106112:	50                   	push   %eax
80106113:	68 58 a6 10 80       	push   $0x8010a658
80106118:	e8 d7 a2 ff ff       	call   801003f4 <cprintf>
8010611d:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106120:	e8 05 ca ff ff       	call   80102b2a <lapiceoi>
    break;
80106125:	e9 5e 01 00 00       	jmp    80106288 <trap+0x283>

  //추가
  case T_PGFLT: 
      // 페이지 폴트 발생 → 접근한 주소 가져오기
      uint va = PGROUNDDOWN(rcr2());
8010612a:	e8 2b fd ff ff       	call   80105e5a <rcr2>
8010612f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     // 물리 메모리 한 페이지 할당
      char *mem = kalloc();
80106137:	e8 72 c6 ff ff       	call   801027ae <kalloc>
8010613c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(mem == 0){
8010613f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80106143:	75 18                	jne    8010615d <trap+0x158>
        cprintf("[trap] out of memory at 0x%x\n", va);
80106145:	83 ec 08             	sub    $0x8,%esp
80106148:	ff 75 e4             	push   -0x1c(%ebp)
8010614b:	68 7c a6 10 80       	push   $0x8010a67c
80106150:	e8 9f a2 ff ff       	call   801003f4 <cprintf>
80106155:	83 c4 10             	add    $0x10,%esp
        break;
80106158:	e9 2b 01 00 00       	jmp    80106288 <trap+0x283>
      }

      // 페이지 내용 초기화 후 매핑
      memset(mem, 0, PGSIZE);
8010615d:	83 ec 04             	sub    $0x4,%esp
80106160:	68 00 10 00 00       	push   $0x1000
80106165:	6a 00                	push   $0x0
80106167:	ff 75 e0             	push   -0x20(%ebp)
8010616a:	e8 20 e9 ff ff       	call   80104a8f <memset>
8010616f:	83 c4 10             	add    $0x10,%esp
      mappages(myproc()->pgdir, (char*)va, PGSIZE, V2P(mem), PTE_W | PTE_U | PTE_P);
80106172:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106175:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
8010617b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010617e:	e8 bb d8 ff ff       	call   80103a3e <myproc>
80106183:	8b 40 04             	mov    0x4(%eax),%eax
80106186:	83 ec 0c             	sub    $0xc,%esp
80106189:	6a 07                	push   $0x7
8010618b:	56                   	push   %esi
8010618c:	68 00 10 00 00       	push   $0x1000
80106191:	53                   	push   %ebx
80106192:	50                   	push   %eax
80106193:	e8 0a 12 00 00       	call   801073a2 <mappages>
80106198:	83 c4 20             	add    $0x20,%esp
      walkpgdir( myproc()->pgdir, (char*)va, 0);
8010619b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010619e:	e8 9b d8 ff ff       	call   80103a3e <myproc>
801061a3:	8b 40 04             	mov    0x4(%eax),%eax
801061a6:	83 ec 04             	sub    $0x4,%esp
801061a9:	6a 00                	push   $0x0
801061ab:	53                   	push   %ebx
801061ac:	50                   	push   %eax
801061ad:	e8 5a 11 00 00       	call   8010730c <walkpgdir>
801061b2:	83 c4 10             	add    $0x10,%esp

      // TLB flush (페이지 테이블 갱신 반영)
      lcr3(V2P(myproc()->pgdir));
801061b5:	e8 84 d8 ff ff       	call   80103a3e <myproc>
801061ba:	8b 40 04             	mov    0x4(%eax),%eax
801061bd:	05 00 00 00 80       	add    $0x80000000,%eax
801061c2:	83 ec 0c             	sub    $0xc,%esp
801061c5:	50                   	push   %eax
801061c6:	e8 a0 fc ff ff       	call   80105e6b <lcr3>
801061cb:	83 c4 10             	add    $0x10,%esp
      break;
801061ce:	e9 b5 00 00 00       	jmp    80106288 <trap+0x283>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801061d3:	e8 66 d8 ff ff       	call   80103a3e <myproc>
801061d8:	85 c0                	test   %eax,%eax
801061da:	74 11                	je     801061ed <trap+0x1e8>
801061dc:	8b 45 08             	mov    0x8(%ebp),%eax
801061df:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061e3:	0f b7 c0             	movzwl %ax,%eax
801061e6:	83 e0 03             	and    $0x3,%eax
801061e9:	85 c0                	test   %eax,%eax
801061eb:	75 39                	jne    80106226 <trap+0x221>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801061ed:	e8 68 fc ff ff       	call   80105e5a <rcr2>
801061f2:	89 c3                	mov    %eax,%ebx
801061f4:	8b 45 08             	mov    0x8(%ebp),%eax
801061f7:	8b 70 38             	mov    0x38(%eax),%esi
801061fa:	e8 ac d7 ff ff       	call   801039ab <cpuid>
801061ff:	8b 55 08             	mov    0x8(%ebp),%edx
80106202:	8b 52 30             	mov    0x30(%edx),%edx
80106205:	83 ec 0c             	sub    $0xc,%esp
80106208:	53                   	push   %ebx
80106209:	56                   	push   %esi
8010620a:	50                   	push   %eax
8010620b:	52                   	push   %edx
8010620c:	68 9c a6 10 80       	push   $0x8010a69c
80106211:	e8 de a1 ff ff       	call   801003f4 <cprintf>
80106216:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106219:	83 ec 0c             	sub    $0xc,%esp
8010621c:	68 ce a6 10 80       	push   $0x8010a6ce
80106221:	e8 9b a3 ff ff       	call   801005c1 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106226:	e8 2f fc ff ff       	call   80105e5a <rcr2>
8010622b:	89 c6                	mov    %eax,%esi
8010622d:	8b 45 08             	mov    0x8(%ebp),%eax
80106230:	8b 40 38             	mov    0x38(%eax),%eax
80106233:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106236:	e8 70 d7 ff ff       	call   801039ab <cpuid>
8010623b:	89 c3                	mov    %eax,%ebx
8010623d:	8b 45 08             	mov    0x8(%ebp),%eax
80106240:	8b 48 34             	mov    0x34(%eax),%ecx
80106243:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106246:	8b 45 08             	mov    0x8(%ebp),%eax
80106249:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010624c:	e8 ed d7 ff ff       	call   80103a3e <myproc>
80106251:	8d 50 6c             	lea    0x6c(%eax),%edx
80106254:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106257:	e8 e2 d7 ff ff       	call   80103a3e <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010625c:	8b 40 10             	mov    0x10(%eax),%eax
8010625f:	56                   	push   %esi
80106260:	ff 75 d4             	push   -0x2c(%ebp)
80106263:	53                   	push   %ebx
80106264:	ff 75 d0             	push   -0x30(%ebp)
80106267:	57                   	push   %edi
80106268:	ff 75 cc             	push   -0x34(%ebp)
8010626b:	50                   	push   %eax
8010626c:	68 d4 a6 10 80       	push   $0x8010a6d4
80106271:	e8 7e a1 ff ff       	call   801003f4 <cprintf>
80106276:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106279:	e8 c0 d7 ff ff       	call   80103a3e <myproc>
8010627e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106285:	eb 01                	jmp    80106288 <trap+0x283>
    break;
80106287:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106288:	e8 b1 d7 ff ff       	call   80103a3e <myproc>
8010628d:	85 c0                	test   %eax,%eax
8010628f:	74 23                	je     801062b4 <trap+0x2af>
80106291:	e8 a8 d7 ff ff       	call   80103a3e <myproc>
80106296:	8b 40 24             	mov    0x24(%eax),%eax
80106299:	85 c0                	test   %eax,%eax
8010629b:	74 17                	je     801062b4 <trap+0x2af>
8010629d:	8b 45 08             	mov    0x8(%ebp),%eax
801062a0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062a4:	0f b7 c0             	movzwl %ax,%eax
801062a7:	83 e0 03             	and    $0x3,%eax
801062aa:	83 f8 03             	cmp    $0x3,%eax
801062ad:	75 05                	jne    801062b4 <trap+0x2af>
    exit();
801062af:	e8 02 dc ff ff       	call   80103eb6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801062b4:	e8 85 d7 ff ff       	call   80103a3e <myproc>
801062b9:	85 c0                	test   %eax,%eax
801062bb:	74 1d                	je     801062da <trap+0x2d5>
801062bd:	e8 7c d7 ff ff       	call   80103a3e <myproc>
801062c2:	8b 40 0c             	mov    0xc(%eax),%eax
801062c5:	83 f8 04             	cmp    $0x4,%eax
801062c8:	75 10                	jne    801062da <trap+0x2d5>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801062ca:	8b 45 08             	mov    0x8(%ebp),%eax
801062cd:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801062d0:	83 f8 20             	cmp    $0x20,%eax
801062d3:	75 05                	jne    801062da <trap+0x2d5>
    yield();
801062d5:	e8 8d df ff ff       	call   80104267 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801062da:	e8 5f d7 ff ff       	call   80103a3e <myproc>
801062df:	85 c0                	test   %eax,%eax
801062e1:	74 26                	je     80106309 <trap+0x304>
801062e3:	e8 56 d7 ff ff       	call   80103a3e <myproc>
801062e8:	8b 40 24             	mov    0x24(%eax),%eax
801062eb:	85 c0                	test   %eax,%eax
801062ed:	74 1a                	je     80106309 <trap+0x304>
801062ef:	8b 45 08             	mov    0x8(%ebp),%eax
801062f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062f6:	0f b7 c0             	movzwl %ax,%eax
801062f9:	83 e0 03             	and    $0x3,%eax
801062fc:	83 f8 03             	cmp    $0x3,%eax
801062ff:	75 08                	jne    80106309 <trap+0x304>
    exit();
80106301:	e8 b0 db ff ff       	call   80103eb6 <exit>
80106306:	eb 01                	jmp    80106309 <trap+0x304>
    return;
80106308:	90                   	nop
}
80106309:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010630c:	5b                   	pop    %ebx
8010630d:	5e                   	pop    %esi
8010630e:	5f                   	pop    %edi
8010630f:	5d                   	pop    %ebp
80106310:	c3                   	ret    

80106311 <inb>:
{
80106311:	55                   	push   %ebp
80106312:	89 e5                	mov    %esp,%ebp
80106314:	83 ec 14             	sub    $0x14,%esp
80106317:	8b 45 08             	mov    0x8(%ebp),%eax
8010631a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010631e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106322:	89 c2                	mov    %eax,%edx
80106324:	ec                   	in     (%dx),%al
80106325:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106328:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010632c:	c9                   	leave  
8010632d:	c3                   	ret    

8010632e <outb>:
{
8010632e:	55                   	push   %ebp
8010632f:	89 e5                	mov    %esp,%ebp
80106331:	83 ec 08             	sub    $0x8,%esp
80106334:	8b 45 08             	mov    0x8(%ebp),%eax
80106337:	8b 55 0c             	mov    0xc(%ebp),%edx
8010633a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010633e:	89 d0                	mov    %edx,%eax
80106340:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106343:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106347:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010634b:	ee                   	out    %al,(%dx)
}
8010634c:	90                   	nop
8010634d:	c9                   	leave  
8010634e:	c3                   	ret    

8010634f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010634f:	55                   	push   %ebp
80106350:	89 e5                	mov    %esp,%ebp
80106352:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106355:	6a 00                	push   $0x0
80106357:	68 fa 03 00 00       	push   $0x3fa
8010635c:	e8 cd ff ff ff       	call   8010632e <outb>
80106361:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106364:	68 80 00 00 00       	push   $0x80
80106369:	68 fb 03 00 00       	push   $0x3fb
8010636e:	e8 bb ff ff ff       	call   8010632e <outb>
80106373:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106376:	6a 0c                	push   $0xc
80106378:	68 f8 03 00 00       	push   $0x3f8
8010637d:	e8 ac ff ff ff       	call   8010632e <outb>
80106382:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106385:	6a 00                	push   $0x0
80106387:	68 f9 03 00 00       	push   $0x3f9
8010638c:	e8 9d ff ff ff       	call   8010632e <outb>
80106391:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106394:	6a 03                	push   $0x3
80106396:	68 fb 03 00 00       	push   $0x3fb
8010639b:	e8 8e ff ff ff       	call   8010632e <outb>
801063a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801063a3:	6a 00                	push   $0x0
801063a5:	68 fc 03 00 00       	push   $0x3fc
801063aa:	e8 7f ff ff ff       	call   8010632e <outb>
801063af:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801063b2:	6a 01                	push   $0x1
801063b4:	68 f9 03 00 00       	push   $0x3f9
801063b9:	e8 70 ff ff ff       	call   8010632e <outb>
801063be:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801063c1:	68 fd 03 00 00       	push   $0x3fd
801063c6:	e8 46 ff ff ff       	call   80106311 <inb>
801063cb:	83 c4 04             	add    $0x4,%esp
801063ce:	3c ff                	cmp    $0xff,%al
801063d0:	74 61                	je     80106433 <uartinit+0xe4>
    return;
  uart = 1;
801063d2:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
801063d9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801063dc:	68 fa 03 00 00       	push   $0x3fa
801063e1:	e8 2b ff ff ff       	call   80106311 <inb>
801063e6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801063e9:	68 f8 03 00 00       	push   $0x3f8
801063ee:	e8 1e ff ff ff       	call   80106311 <inb>
801063f3:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801063f6:	83 ec 08             	sub    $0x8,%esp
801063f9:	6a 00                	push   $0x0
801063fb:	6a 04                	push   $0x4
801063fd:	e8 3a c2 ff ff       	call   8010263c <ioapicenable>
80106402:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106405:	c7 45 f4 e0 a7 10 80 	movl   $0x8010a7e0,-0xc(%ebp)
8010640c:	eb 19                	jmp    80106427 <uartinit+0xd8>
    uartputc(*p);
8010640e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106411:	0f b6 00             	movzbl (%eax),%eax
80106414:	0f be c0             	movsbl %al,%eax
80106417:	83 ec 0c             	sub    $0xc,%esp
8010641a:	50                   	push   %eax
8010641b:	e8 16 00 00 00       	call   80106436 <uartputc>
80106420:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106423:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642a:	0f b6 00             	movzbl (%eax),%eax
8010642d:	84 c0                	test   %al,%al
8010642f:	75 dd                	jne    8010640e <uartinit+0xbf>
80106431:	eb 01                	jmp    80106434 <uartinit+0xe5>
    return;
80106433:	90                   	nop
}
80106434:	c9                   	leave  
80106435:	c3                   	ret    

80106436 <uartputc>:

void
uartputc(int c)
{
80106436:	55                   	push   %ebp
80106437:	89 e5                	mov    %esp,%ebp
80106439:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010643c:	a1 78 69 19 80       	mov    0x80196978,%eax
80106441:	85 c0                	test   %eax,%eax
80106443:	74 53                	je     80106498 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010644c:	eb 11                	jmp    8010645f <uartputc+0x29>
    microdelay(10);
8010644e:	83 ec 0c             	sub    $0xc,%esp
80106451:	6a 0a                	push   $0xa
80106453:	e8 ed c6 ff ff       	call   80102b45 <microdelay>
80106458:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010645b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010645f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106463:	7f 1a                	jg     8010647f <uartputc+0x49>
80106465:	83 ec 0c             	sub    $0xc,%esp
80106468:	68 fd 03 00 00       	push   $0x3fd
8010646d:	e8 9f fe ff ff       	call   80106311 <inb>
80106472:	83 c4 10             	add    $0x10,%esp
80106475:	0f b6 c0             	movzbl %al,%eax
80106478:	83 e0 20             	and    $0x20,%eax
8010647b:	85 c0                	test   %eax,%eax
8010647d:	74 cf                	je     8010644e <uartputc+0x18>
  outb(COM1+0, c);
8010647f:	8b 45 08             	mov    0x8(%ebp),%eax
80106482:	0f b6 c0             	movzbl %al,%eax
80106485:	83 ec 08             	sub    $0x8,%esp
80106488:	50                   	push   %eax
80106489:	68 f8 03 00 00       	push   $0x3f8
8010648e:	e8 9b fe ff ff       	call   8010632e <outb>
80106493:	83 c4 10             	add    $0x10,%esp
80106496:	eb 01                	jmp    80106499 <uartputc+0x63>
    return;
80106498:	90                   	nop
}
80106499:	c9                   	leave  
8010649a:	c3                   	ret    

8010649b <uartgetc>:

static int
uartgetc(void)
{
8010649b:	55                   	push   %ebp
8010649c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010649e:	a1 78 69 19 80       	mov    0x80196978,%eax
801064a3:	85 c0                	test   %eax,%eax
801064a5:	75 07                	jne    801064ae <uartgetc+0x13>
    return -1;
801064a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ac:	eb 2e                	jmp    801064dc <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801064ae:	68 fd 03 00 00       	push   $0x3fd
801064b3:	e8 59 fe ff ff       	call   80106311 <inb>
801064b8:	83 c4 04             	add    $0x4,%esp
801064bb:	0f b6 c0             	movzbl %al,%eax
801064be:	83 e0 01             	and    $0x1,%eax
801064c1:	85 c0                	test   %eax,%eax
801064c3:	75 07                	jne    801064cc <uartgetc+0x31>
    return -1;
801064c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ca:	eb 10                	jmp    801064dc <uartgetc+0x41>
  return inb(COM1+0);
801064cc:	68 f8 03 00 00       	push   $0x3f8
801064d1:	e8 3b fe ff ff       	call   80106311 <inb>
801064d6:	83 c4 04             	add    $0x4,%esp
801064d9:	0f b6 c0             	movzbl %al,%eax
}
801064dc:	c9                   	leave  
801064dd:	c3                   	ret    

801064de <uartintr>:

void
uartintr(void)
{
801064de:	55                   	push   %ebp
801064df:	89 e5                	mov    %esp,%ebp
801064e1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801064e4:	83 ec 0c             	sub    $0xc,%esp
801064e7:	68 9b 64 10 80       	push   $0x8010649b
801064ec:	e8 fd a2 ff ff       	call   801007ee <consoleintr>
801064f1:	83 c4 10             	add    $0x10,%esp
}
801064f4:	90                   	nop
801064f5:	c9                   	leave  
801064f6:	c3                   	ret    

801064f7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $0
801064f9:	6a 00                	push   $0x0
  jmp alltraps
801064fb:	e9 0d f9 ff ff       	jmp    80105e0d <alltraps>

80106500 <vector1>:
.globl vector1
vector1:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $1
80106502:	6a 01                	push   $0x1
  jmp alltraps
80106504:	e9 04 f9 ff ff       	jmp    80105e0d <alltraps>

80106509 <vector2>:
.globl vector2
vector2:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $2
8010650b:	6a 02                	push   $0x2
  jmp alltraps
8010650d:	e9 fb f8 ff ff       	jmp    80105e0d <alltraps>

80106512 <vector3>:
.globl vector3
vector3:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $3
80106514:	6a 03                	push   $0x3
  jmp alltraps
80106516:	e9 f2 f8 ff ff       	jmp    80105e0d <alltraps>

8010651b <vector4>:
.globl vector4
vector4:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $4
8010651d:	6a 04                	push   $0x4
  jmp alltraps
8010651f:	e9 e9 f8 ff ff       	jmp    80105e0d <alltraps>

80106524 <vector5>:
.globl vector5
vector5:
  pushl $0
80106524:	6a 00                	push   $0x0
  pushl $5
80106526:	6a 05                	push   $0x5
  jmp alltraps
80106528:	e9 e0 f8 ff ff       	jmp    80105e0d <alltraps>

8010652d <vector6>:
.globl vector6
vector6:
  pushl $0
8010652d:	6a 00                	push   $0x0
  pushl $6
8010652f:	6a 06                	push   $0x6
  jmp alltraps
80106531:	e9 d7 f8 ff ff       	jmp    80105e0d <alltraps>

80106536 <vector7>:
.globl vector7
vector7:
  pushl $0
80106536:	6a 00                	push   $0x0
  pushl $7
80106538:	6a 07                	push   $0x7
  jmp alltraps
8010653a:	e9 ce f8 ff ff       	jmp    80105e0d <alltraps>

8010653f <vector8>:
.globl vector8
vector8:
  pushl $8
8010653f:	6a 08                	push   $0x8
  jmp alltraps
80106541:	e9 c7 f8 ff ff       	jmp    80105e0d <alltraps>

80106546 <vector9>:
.globl vector9
vector9:
  pushl $0
80106546:	6a 00                	push   $0x0
  pushl $9
80106548:	6a 09                	push   $0x9
  jmp alltraps
8010654a:	e9 be f8 ff ff       	jmp    80105e0d <alltraps>

8010654f <vector10>:
.globl vector10
vector10:
  pushl $10
8010654f:	6a 0a                	push   $0xa
  jmp alltraps
80106551:	e9 b7 f8 ff ff       	jmp    80105e0d <alltraps>

80106556 <vector11>:
.globl vector11
vector11:
  pushl $11
80106556:	6a 0b                	push   $0xb
  jmp alltraps
80106558:	e9 b0 f8 ff ff       	jmp    80105e0d <alltraps>

8010655d <vector12>:
.globl vector12
vector12:
  pushl $12
8010655d:	6a 0c                	push   $0xc
  jmp alltraps
8010655f:	e9 a9 f8 ff ff       	jmp    80105e0d <alltraps>

80106564 <vector13>:
.globl vector13
vector13:
  pushl $13
80106564:	6a 0d                	push   $0xd
  jmp alltraps
80106566:	e9 a2 f8 ff ff       	jmp    80105e0d <alltraps>

8010656b <vector14>:
.globl vector14
vector14:
  pushl $14
8010656b:	6a 0e                	push   $0xe
  jmp alltraps
8010656d:	e9 9b f8 ff ff       	jmp    80105e0d <alltraps>

80106572 <vector15>:
.globl vector15
vector15:
  pushl $0
80106572:	6a 00                	push   $0x0
  pushl $15
80106574:	6a 0f                	push   $0xf
  jmp alltraps
80106576:	e9 92 f8 ff ff       	jmp    80105e0d <alltraps>

8010657b <vector16>:
.globl vector16
vector16:
  pushl $0
8010657b:	6a 00                	push   $0x0
  pushl $16
8010657d:	6a 10                	push   $0x10
  jmp alltraps
8010657f:	e9 89 f8 ff ff       	jmp    80105e0d <alltraps>

80106584 <vector17>:
.globl vector17
vector17:
  pushl $17
80106584:	6a 11                	push   $0x11
  jmp alltraps
80106586:	e9 82 f8 ff ff       	jmp    80105e0d <alltraps>

8010658b <vector18>:
.globl vector18
vector18:
  pushl $0
8010658b:	6a 00                	push   $0x0
  pushl $18
8010658d:	6a 12                	push   $0x12
  jmp alltraps
8010658f:	e9 79 f8 ff ff       	jmp    80105e0d <alltraps>

80106594 <vector19>:
.globl vector19
vector19:
  pushl $0
80106594:	6a 00                	push   $0x0
  pushl $19
80106596:	6a 13                	push   $0x13
  jmp alltraps
80106598:	e9 70 f8 ff ff       	jmp    80105e0d <alltraps>

8010659d <vector20>:
.globl vector20
vector20:
  pushl $0
8010659d:	6a 00                	push   $0x0
  pushl $20
8010659f:	6a 14                	push   $0x14
  jmp alltraps
801065a1:	e9 67 f8 ff ff       	jmp    80105e0d <alltraps>

801065a6 <vector21>:
.globl vector21
vector21:
  pushl $0
801065a6:	6a 00                	push   $0x0
  pushl $21
801065a8:	6a 15                	push   $0x15
  jmp alltraps
801065aa:	e9 5e f8 ff ff       	jmp    80105e0d <alltraps>

801065af <vector22>:
.globl vector22
vector22:
  pushl $0
801065af:	6a 00                	push   $0x0
  pushl $22
801065b1:	6a 16                	push   $0x16
  jmp alltraps
801065b3:	e9 55 f8 ff ff       	jmp    80105e0d <alltraps>

801065b8 <vector23>:
.globl vector23
vector23:
  pushl $0
801065b8:	6a 00                	push   $0x0
  pushl $23
801065ba:	6a 17                	push   $0x17
  jmp alltraps
801065bc:	e9 4c f8 ff ff       	jmp    80105e0d <alltraps>

801065c1 <vector24>:
.globl vector24
vector24:
  pushl $0
801065c1:	6a 00                	push   $0x0
  pushl $24
801065c3:	6a 18                	push   $0x18
  jmp alltraps
801065c5:	e9 43 f8 ff ff       	jmp    80105e0d <alltraps>

801065ca <vector25>:
.globl vector25
vector25:
  pushl $0
801065ca:	6a 00                	push   $0x0
  pushl $25
801065cc:	6a 19                	push   $0x19
  jmp alltraps
801065ce:	e9 3a f8 ff ff       	jmp    80105e0d <alltraps>

801065d3 <vector26>:
.globl vector26
vector26:
  pushl $0
801065d3:	6a 00                	push   $0x0
  pushl $26
801065d5:	6a 1a                	push   $0x1a
  jmp alltraps
801065d7:	e9 31 f8 ff ff       	jmp    80105e0d <alltraps>

801065dc <vector27>:
.globl vector27
vector27:
  pushl $0
801065dc:	6a 00                	push   $0x0
  pushl $27
801065de:	6a 1b                	push   $0x1b
  jmp alltraps
801065e0:	e9 28 f8 ff ff       	jmp    80105e0d <alltraps>

801065e5 <vector28>:
.globl vector28
vector28:
  pushl $0
801065e5:	6a 00                	push   $0x0
  pushl $28
801065e7:	6a 1c                	push   $0x1c
  jmp alltraps
801065e9:	e9 1f f8 ff ff       	jmp    80105e0d <alltraps>

801065ee <vector29>:
.globl vector29
vector29:
  pushl $0
801065ee:	6a 00                	push   $0x0
  pushl $29
801065f0:	6a 1d                	push   $0x1d
  jmp alltraps
801065f2:	e9 16 f8 ff ff       	jmp    80105e0d <alltraps>

801065f7 <vector30>:
.globl vector30
vector30:
  pushl $0
801065f7:	6a 00                	push   $0x0
  pushl $30
801065f9:	6a 1e                	push   $0x1e
  jmp alltraps
801065fb:	e9 0d f8 ff ff       	jmp    80105e0d <alltraps>

80106600 <vector31>:
.globl vector31
vector31:
  pushl $0
80106600:	6a 00                	push   $0x0
  pushl $31
80106602:	6a 1f                	push   $0x1f
  jmp alltraps
80106604:	e9 04 f8 ff ff       	jmp    80105e0d <alltraps>

80106609 <vector32>:
.globl vector32
vector32:
  pushl $0
80106609:	6a 00                	push   $0x0
  pushl $32
8010660b:	6a 20                	push   $0x20
  jmp alltraps
8010660d:	e9 fb f7 ff ff       	jmp    80105e0d <alltraps>

80106612 <vector33>:
.globl vector33
vector33:
  pushl $0
80106612:	6a 00                	push   $0x0
  pushl $33
80106614:	6a 21                	push   $0x21
  jmp alltraps
80106616:	e9 f2 f7 ff ff       	jmp    80105e0d <alltraps>

8010661b <vector34>:
.globl vector34
vector34:
  pushl $0
8010661b:	6a 00                	push   $0x0
  pushl $34
8010661d:	6a 22                	push   $0x22
  jmp alltraps
8010661f:	e9 e9 f7 ff ff       	jmp    80105e0d <alltraps>

80106624 <vector35>:
.globl vector35
vector35:
  pushl $0
80106624:	6a 00                	push   $0x0
  pushl $35
80106626:	6a 23                	push   $0x23
  jmp alltraps
80106628:	e9 e0 f7 ff ff       	jmp    80105e0d <alltraps>

8010662d <vector36>:
.globl vector36
vector36:
  pushl $0
8010662d:	6a 00                	push   $0x0
  pushl $36
8010662f:	6a 24                	push   $0x24
  jmp alltraps
80106631:	e9 d7 f7 ff ff       	jmp    80105e0d <alltraps>

80106636 <vector37>:
.globl vector37
vector37:
  pushl $0
80106636:	6a 00                	push   $0x0
  pushl $37
80106638:	6a 25                	push   $0x25
  jmp alltraps
8010663a:	e9 ce f7 ff ff       	jmp    80105e0d <alltraps>

8010663f <vector38>:
.globl vector38
vector38:
  pushl $0
8010663f:	6a 00                	push   $0x0
  pushl $38
80106641:	6a 26                	push   $0x26
  jmp alltraps
80106643:	e9 c5 f7 ff ff       	jmp    80105e0d <alltraps>

80106648 <vector39>:
.globl vector39
vector39:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $39
8010664a:	6a 27                	push   $0x27
  jmp alltraps
8010664c:	e9 bc f7 ff ff       	jmp    80105e0d <alltraps>

80106651 <vector40>:
.globl vector40
vector40:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $40
80106653:	6a 28                	push   $0x28
  jmp alltraps
80106655:	e9 b3 f7 ff ff       	jmp    80105e0d <alltraps>

8010665a <vector41>:
.globl vector41
vector41:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $41
8010665c:	6a 29                	push   $0x29
  jmp alltraps
8010665e:	e9 aa f7 ff ff       	jmp    80105e0d <alltraps>

80106663 <vector42>:
.globl vector42
vector42:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $42
80106665:	6a 2a                	push   $0x2a
  jmp alltraps
80106667:	e9 a1 f7 ff ff       	jmp    80105e0d <alltraps>

8010666c <vector43>:
.globl vector43
vector43:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $43
8010666e:	6a 2b                	push   $0x2b
  jmp alltraps
80106670:	e9 98 f7 ff ff       	jmp    80105e0d <alltraps>

80106675 <vector44>:
.globl vector44
vector44:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $44
80106677:	6a 2c                	push   $0x2c
  jmp alltraps
80106679:	e9 8f f7 ff ff       	jmp    80105e0d <alltraps>

8010667e <vector45>:
.globl vector45
vector45:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $45
80106680:	6a 2d                	push   $0x2d
  jmp alltraps
80106682:	e9 86 f7 ff ff       	jmp    80105e0d <alltraps>

80106687 <vector46>:
.globl vector46
vector46:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $46
80106689:	6a 2e                	push   $0x2e
  jmp alltraps
8010668b:	e9 7d f7 ff ff       	jmp    80105e0d <alltraps>

80106690 <vector47>:
.globl vector47
vector47:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $47
80106692:	6a 2f                	push   $0x2f
  jmp alltraps
80106694:	e9 74 f7 ff ff       	jmp    80105e0d <alltraps>

80106699 <vector48>:
.globl vector48
vector48:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $48
8010669b:	6a 30                	push   $0x30
  jmp alltraps
8010669d:	e9 6b f7 ff ff       	jmp    80105e0d <alltraps>

801066a2 <vector49>:
.globl vector49
vector49:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $49
801066a4:	6a 31                	push   $0x31
  jmp alltraps
801066a6:	e9 62 f7 ff ff       	jmp    80105e0d <alltraps>

801066ab <vector50>:
.globl vector50
vector50:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $50
801066ad:	6a 32                	push   $0x32
  jmp alltraps
801066af:	e9 59 f7 ff ff       	jmp    80105e0d <alltraps>

801066b4 <vector51>:
.globl vector51
vector51:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $51
801066b6:	6a 33                	push   $0x33
  jmp alltraps
801066b8:	e9 50 f7 ff ff       	jmp    80105e0d <alltraps>

801066bd <vector52>:
.globl vector52
vector52:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $52
801066bf:	6a 34                	push   $0x34
  jmp alltraps
801066c1:	e9 47 f7 ff ff       	jmp    80105e0d <alltraps>

801066c6 <vector53>:
.globl vector53
vector53:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $53
801066c8:	6a 35                	push   $0x35
  jmp alltraps
801066ca:	e9 3e f7 ff ff       	jmp    80105e0d <alltraps>

801066cf <vector54>:
.globl vector54
vector54:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $54
801066d1:	6a 36                	push   $0x36
  jmp alltraps
801066d3:	e9 35 f7 ff ff       	jmp    80105e0d <alltraps>

801066d8 <vector55>:
.globl vector55
vector55:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $55
801066da:	6a 37                	push   $0x37
  jmp alltraps
801066dc:	e9 2c f7 ff ff       	jmp    80105e0d <alltraps>

801066e1 <vector56>:
.globl vector56
vector56:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $56
801066e3:	6a 38                	push   $0x38
  jmp alltraps
801066e5:	e9 23 f7 ff ff       	jmp    80105e0d <alltraps>

801066ea <vector57>:
.globl vector57
vector57:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $57
801066ec:	6a 39                	push   $0x39
  jmp alltraps
801066ee:	e9 1a f7 ff ff       	jmp    80105e0d <alltraps>

801066f3 <vector58>:
.globl vector58
vector58:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $58
801066f5:	6a 3a                	push   $0x3a
  jmp alltraps
801066f7:	e9 11 f7 ff ff       	jmp    80105e0d <alltraps>

801066fc <vector59>:
.globl vector59
vector59:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $59
801066fe:	6a 3b                	push   $0x3b
  jmp alltraps
80106700:	e9 08 f7 ff ff       	jmp    80105e0d <alltraps>

80106705 <vector60>:
.globl vector60
vector60:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $60
80106707:	6a 3c                	push   $0x3c
  jmp alltraps
80106709:	e9 ff f6 ff ff       	jmp    80105e0d <alltraps>

8010670e <vector61>:
.globl vector61
vector61:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $61
80106710:	6a 3d                	push   $0x3d
  jmp alltraps
80106712:	e9 f6 f6 ff ff       	jmp    80105e0d <alltraps>

80106717 <vector62>:
.globl vector62
vector62:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $62
80106719:	6a 3e                	push   $0x3e
  jmp alltraps
8010671b:	e9 ed f6 ff ff       	jmp    80105e0d <alltraps>

80106720 <vector63>:
.globl vector63
vector63:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $63
80106722:	6a 3f                	push   $0x3f
  jmp alltraps
80106724:	e9 e4 f6 ff ff       	jmp    80105e0d <alltraps>

80106729 <vector64>:
.globl vector64
vector64:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $64
8010672b:	6a 40                	push   $0x40
  jmp alltraps
8010672d:	e9 db f6 ff ff       	jmp    80105e0d <alltraps>

80106732 <vector65>:
.globl vector65
vector65:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $65
80106734:	6a 41                	push   $0x41
  jmp alltraps
80106736:	e9 d2 f6 ff ff       	jmp    80105e0d <alltraps>

8010673b <vector66>:
.globl vector66
vector66:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $66
8010673d:	6a 42                	push   $0x42
  jmp alltraps
8010673f:	e9 c9 f6 ff ff       	jmp    80105e0d <alltraps>

80106744 <vector67>:
.globl vector67
vector67:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $67
80106746:	6a 43                	push   $0x43
  jmp alltraps
80106748:	e9 c0 f6 ff ff       	jmp    80105e0d <alltraps>

8010674d <vector68>:
.globl vector68
vector68:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $68
8010674f:	6a 44                	push   $0x44
  jmp alltraps
80106751:	e9 b7 f6 ff ff       	jmp    80105e0d <alltraps>

80106756 <vector69>:
.globl vector69
vector69:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $69
80106758:	6a 45                	push   $0x45
  jmp alltraps
8010675a:	e9 ae f6 ff ff       	jmp    80105e0d <alltraps>

8010675f <vector70>:
.globl vector70
vector70:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $70
80106761:	6a 46                	push   $0x46
  jmp alltraps
80106763:	e9 a5 f6 ff ff       	jmp    80105e0d <alltraps>

80106768 <vector71>:
.globl vector71
vector71:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $71
8010676a:	6a 47                	push   $0x47
  jmp alltraps
8010676c:	e9 9c f6 ff ff       	jmp    80105e0d <alltraps>

80106771 <vector72>:
.globl vector72
vector72:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $72
80106773:	6a 48                	push   $0x48
  jmp alltraps
80106775:	e9 93 f6 ff ff       	jmp    80105e0d <alltraps>

8010677a <vector73>:
.globl vector73
vector73:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $73
8010677c:	6a 49                	push   $0x49
  jmp alltraps
8010677e:	e9 8a f6 ff ff       	jmp    80105e0d <alltraps>

80106783 <vector74>:
.globl vector74
vector74:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $74
80106785:	6a 4a                	push   $0x4a
  jmp alltraps
80106787:	e9 81 f6 ff ff       	jmp    80105e0d <alltraps>

8010678c <vector75>:
.globl vector75
vector75:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $75
8010678e:	6a 4b                	push   $0x4b
  jmp alltraps
80106790:	e9 78 f6 ff ff       	jmp    80105e0d <alltraps>

80106795 <vector76>:
.globl vector76
vector76:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $76
80106797:	6a 4c                	push   $0x4c
  jmp alltraps
80106799:	e9 6f f6 ff ff       	jmp    80105e0d <alltraps>

8010679e <vector77>:
.globl vector77
vector77:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $77
801067a0:	6a 4d                	push   $0x4d
  jmp alltraps
801067a2:	e9 66 f6 ff ff       	jmp    80105e0d <alltraps>

801067a7 <vector78>:
.globl vector78
vector78:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $78
801067a9:	6a 4e                	push   $0x4e
  jmp alltraps
801067ab:	e9 5d f6 ff ff       	jmp    80105e0d <alltraps>

801067b0 <vector79>:
.globl vector79
vector79:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $79
801067b2:	6a 4f                	push   $0x4f
  jmp alltraps
801067b4:	e9 54 f6 ff ff       	jmp    80105e0d <alltraps>

801067b9 <vector80>:
.globl vector80
vector80:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $80
801067bb:	6a 50                	push   $0x50
  jmp alltraps
801067bd:	e9 4b f6 ff ff       	jmp    80105e0d <alltraps>

801067c2 <vector81>:
.globl vector81
vector81:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $81
801067c4:	6a 51                	push   $0x51
  jmp alltraps
801067c6:	e9 42 f6 ff ff       	jmp    80105e0d <alltraps>

801067cb <vector82>:
.globl vector82
vector82:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $82
801067cd:	6a 52                	push   $0x52
  jmp alltraps
801067cf:	e9 39 f6 ff ff       	jmp    80105e0d <alltraps>

801067d4 <vector83>:
.globl vector83
vector83:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $83
801067d6:	6a 53                	push   $0x53
  jmp alltraps
801067d8:	e9 30 f6 ff ff       	jmp    80105e0d <alltraps>

801067dd <vector84>:
.globl vector84
vector84:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $84
801067df:	6a 54                	push   $0x54
  jmp alltraps
801067e1:	e9 27 f6 ff ff       	jmp    80105e0d <alltraps>

801067e6 <vector85>:
.globl vector85
vector85:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $85
801067e8:	6a 55                	push   $0x55
  jmp alltraps
801067ea:	e9 1e f6 ff ff       	jmp    80105e0d <alltraps>

801067ef <vector86>:
.globl vector86
vector86:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $86
801067f1:	6a 56                	push   $0x56
  jmp alltraps
801067f3:	e9 15 f6 ff ff       	jmp    80105e0d <alltraps>

801067f8 <vector87>:
.globl vector87
vector87:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $87
801067fa:	6a 57                	push   $0x57
  jmp alltraps
801067fc:	e9 0c f6 ff ff       	jmp    80105e0d <alltraps>

80106801 <vector88>:
.globl vector88
vector88:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $88
80106803:	6a 58                	push   $0x58
  jmp alltraps
80106805:	e9 03 f6 ff ff       	jmp    80105e0d <alltraps>

8010680a <vector89>:
.globl vector89
vector89:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $89
8010680c:	6a 59                	push   $0x59
  jmp alltraps
8010680e:	e9 fa f5 ff ff       	jmp    80105e0d <alltraps>

80106813 <vector90>:
.globl vector90
vector90:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $90
80106815:	6a 5a                	push   $0x5a
  jmp alltraps
80106817:	e9 f1 f5 ff ff       	jmp    80105e0d <alltraps>

8010681c <vector91>:
.globl vector91
vector91:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $91
8010681e:	6a 5b                	push   $0x5b
  jmp alltraps
80106820:	e9 e8 f5 ff ff       	jmp    80105e0d <alltraps>

80106825 <vector92>:
.globl vector92
vector92:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $92
80106827:	6a 5c                	push   $0x5c
  jmp alltraps
80106829:	e9 df f5 ff ff       	jmp    80105e0d <alltraps>

8010682e <vector93>:
.globl vector93
vector93:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $93
80106830:	6a 5d                	push   $0x5d
  jmp alltraps
80106832:	e9 d6 f5 ff ff       	jmp    80105e0d <alltraps>

80106837 <vector94>:
.globl vector94
vector94:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $94
80106839:	6a 5e                	push   $0x5e
  jmp alltraps
8010683b:	e9 cd f5 ff ff       	jmp    80105e0d <alltraps>

80106840 <vector95>:
.globl vector95
vector95:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $95
80106842:	6a 5f                	push   $0x5f
  jmp alltraps
80106844:	e9 c4 f5 ff ff       	jmp    80105e0d <alltraps>

80106849 <vector96>:
.globl vector96
vector96:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $96
8010684b:	6a 60                	push   $0x60
  jmp alltraps
8010684d:	e9 bb f5 ff ff       	jmp    80105e0d <alltraps>

80106852 <vector97>:
.globl vector97
vector97:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $97
80106854:	6a 61                	push   $0x61
  jmp alltraps
80106856:	e9 b2 f5 ff ff       	jmp    80105e0d <alltraps>

8010685b <vector98>:
.globl vector98
vector98:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $98
8010685d:	6a 62                	push   $0x62
  jmp alltraps
8010685f:	e9 a9 f5 ff ff       	jmp    80105e0d <alltraps>

80106864 <vector99>:
.globl vector99
vector99:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $99
80106866:	6a 63                	push   $0x63
  jmp alltraps
80106868:	e9 a0 f5 ff ff       	jmp    80105e0d <alltraps>

8010686d <vector100>:
.globl vector100
vector100:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $100
8010686f:	6a 64                	push   $0x64
  jmp alltraps
80106871:	e9 97 f5 ff ff       	jmp    80105e0d <alltraps>

80106876 <vector101>:
.globl vector101
vector101:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $101
80106878:	6a 65                	push   $0x65
  jmp alltraps
8010687a:	e9 8e f5 ff ff       	jmp    80105e0d <alltraps>

8010687f <vector102>:
.globl vector102
vector102:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $102
80106881:	6a 66                	push   $0x66
  jmp alltraps
80106883:	e9 85 f5 ff ff       	jmp    80105e0d <alltraps>

80106888 <vector103>:
.globl vector103
vector103:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $103
8010688a:	6a 67                	push   $0x67
  jmp alltraps
8010688c:	e9 7c f5 ff ff       	jmp    80105e0d <alltraps>

80106891 <vector104>:
.globl vector104
vector104:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $104
80106893:	6a 68                	push   $0x68
  jmp alltraps
80106895:	e9 73 f5 ff ff       	jmp    80105e0d <alltraps>

8010689a <vector105>:
.globl vector105
vector105:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $105
8010689c:	6a 69                	push   $0x69
  jmp alltraps
8010689e:	e9 6a f5 ff ff       	jmp    80105e0d <alltraps>

801068a3 <vector106>:
.globl vector106
vector106:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $106
801068a5:	6a 6a                	push   $0x6a
  jmp alltraps
801068a7:	e9 61 f5 ff ff       	jmp    80105e0d <alltraps>

801068ac <vector107>:
.globl vector107
vector107:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $107
801068ae:	6a 6b                	push   $0x6b
  jmp alltraps
801068b0:	e9 58 f5 ff ff       	jmp    80105e0d <alltraps>

801068b5 <vector108>:
.globl vector108
vector108:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $108
801068b7:	6a 6c                	push   $0x6c
  jmp alltraps
801068b9:	e9 4f f5 ff ff       	jmp    80105e0d <alltraps>

801068be <vector109>:
.globl vector109
vector109:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $109
801068c0:	6a 6d                	push   $0x6d
  jmp alltraps
801068c2:	e9 46 f5 ff ff       	jmp    80105e0d <alltraps>

801068c7 <vector110>:
.globl vector110
vector110:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $110
801068c9:	6a 6e                	push   $0x6e
  jmp alltraps
801068cb:	e9 3d f5 ff ff       	jmp    80105e0d <alltraps>

801068d0 <vector111>:
.globl vector111
vector111:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $111
801068d2:	6a 6f                	push   $0x6f
  jmp alltraps
801068d4:	e9 34 f5 ff ff       	jmp    80105e0d <alltraps>

801068d9 <vector112>:
.globl vector112
vector112:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $112
801068db:	6a 70                	push   $0x70
  jmp alltraps
801068dd:	e9 2b f5 ff ff       	jmp    80105e0d <alltraps>

801068e2 <vector113>:
.globl vector113
vector113:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $113
801068e4:	6a 71                	push   $0x71
  jmp alltraps
801068e6:	e9 22 f5 ff ff       	jmp    80105e0d <alltraps>

801068eb <vector114>:
.globl vector114
vector114:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $114
801068ed:	6a 72                	push   $0x72
  jmp alltraps
801068ef:	e9 19 f5 ff ff       	jmp    80105e0d <alltraps>

801068f4 <vector115>:
.globl vector115
vector115:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $115
801068f6:	6a 73                	push   $0x73
  jmp alltraps
801068f8:	e9 10 f5 ff ff       	jmp    80105e0d <alltraps>

801068fd <vector116>:
.globl vector116
vector116:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $116
801068ff:	6a 74                	push   $0x74
  jmp alltraps
80106901:	e9 07 f5 ff ff       	jmp    80105e0d <alltraps>

80106906 <vector117>:
.globl vector117
vector117:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $117
80106908:	6a 75                	push   $0x75
  jmp alltraps
8010690a:	e9 fe f4 ff ff       	jmp    80105e0d <alltraps>

8010690f <vector118>:
.globl vector118
vector118:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $118
80106911:	6a 76                	push   $0x76
  jmp alltraps
80106913:	e9 f5 f4 ff ff       	jmp    80105e0d <alltraps>

80106918 <vector119>:
.globl vector119
vector119:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $119
8010691a:	6a 77                	push   $0x77
  jmp alltraps
8010691c:	e9 ec f4 ff ff       	jmp    80105e0d <alltraps>

80106921 <vector120>:
.globl vector120
vector120:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $120
80106923:	6a 78                	push   $0x78
  jmp alltraps
80106925:	e9 e3 f4 ff ff       	jmp    80105e0d <alltraps>

8010692a <vector121>:
.globl vector121
vector121:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $121
8010692c:	6a 79                	push   $0x79
  jmp alltraps
8010692e:	e9 da f4 ff ff       	jmp    80105e0d <alltraps>

80106933 <vector122>:
.globl vector122
vector122:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $122
80106935:	6a 7a                	push   $0x7a
  jmp alltraps
80106937:	e9 d1 f4 ff ff       	jmp    80105e0d <alltraps>

8010693c <vector123>:
.globl vector123
vector123:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $123
8010693e:	6a 7b                	push   $0x7b
  jmp alltraps
80106940:	e9 c8 f4 ff ff       	jmp    80105e0d <alltraps>

80106945 <vector124>:
.globl vector124
vector124:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $124
80106947:	6a 7c                	push   $0x7c
  jmp alltraps
80106949:	e9 bf f4 ff ff       	jmp    80105e0d <alltraps>

8010694e <vector125>:
.globl vector125
vector125:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $125
80106950:	6a 7d                	push   $0x7d
  jmp alltraps
80106952:	e9 b6 f4 ff ff       	jmp    80105e0d <alltraps>

80106957 <vector126>:
.globl vector126
vector126:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $126
80106959:	6a 7e                	push   $0x7e
  jmp alltraps
8010695b:	e9 ad f4 ff ff       	jmp    80105e0d <alltraps>

80106960 <vector127>:
.globl vector127
vector127:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $127
80106962:	6a 7f                	push   $0x7f
  jmp alltraps
80106964:	e9 a4 f4 ff ff       	jmp    80105e0d <alltraps>

80106969 <vector128>:
.globl vector128
vector128:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $128
8010696b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106970:	e9 98 f4 ff ff       	jmp    80105e0d <alltraps>

80106975 <vector129>:
.globl vector129
vector129:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $129
80106977:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010697c:	e9 8c f4 ff ff       	jmp    80105e0d <alltraps>

80106981 <vector130>:
.globl vector130
vector130:
  pushl $0
80106981:	6a 00                	push   $0x0
  pushl $130
80106983:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106988:	e9 80 f4 ff ff       	jmp    80105e0d <alltraps>

8010698d <vector131>:
.globl vector131
vector131:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $131
8010698f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106994:	e9 74 f4 ff ff       	jmp    80105e0d <alltraps>

80106999 <vector132>:
.globl vector132
vector132:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $132
8010699b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801069a0:	e9 68 f4 ff ff       	jmp    80105e0d <alltraps>

801069a5 <vector133>:
.globl vector133
vector133:
  pushl $0
801069a5:	6a 00                	push   $0x0
  pushl $133
801069a7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801069ac:	e9 5c f4 ff ff       	jmp    80105e0d <alltraps>

801069b1 <vector134>:
.globl vector134
vector134:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $134
801069b3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801069b8:	e9 50 f4 ff ff       	jmp    80105e0d <alltraps>

801069bd <vector135>:
.globl vector135
vector135:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $135
801069bf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801069c4:	e9 44 f4 ff ff       	jmp    80105e0d <alltraps>

801069c9 <vector136>:
.globl vector136
vector136:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $136
801069cb:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801069d0:	e9 38 f4 ff ff       	jmp    80105e0d <alltraps>

801069d5 <vector137>:
.globl vector137
vector137:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $137
801069d7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801069dc:	e9 2c f4 ff ff       	jmp    80105e0d <alltraps>

801069e1 <vector138>:
.globl vector138
vector138:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $138
801069e3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069e8:	e9 20 f4 ff ff       	jmp    80105e0d <alltraps>

801069ed <vector139>:
.globl vector139
vector139:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $139
801069ef:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069f4:	e9 14 f4 ff ff       	jmp    80105e0d <alltraps>

801069f9 <vector140>:
.globl vector140
vector140:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $140
801069fb:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106a00:	e9 08 f4 ff ff       	jmp    80105e0d <alltraps>

80106a05 <vector141>:
.globl vector141
vector141:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $141
80106a07:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106a0c:	e9 fc f3 ff ff       	jmp    80105e0d <alltraps>

80106a11 <vector142>:
.globl vector142
vector142:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $142
80106a13:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106a18:	e9 f0 f3 ff ff       	jmp    80105e0d <alltraps>

80106a1d <vector143>:
.globl vector143
vector143:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $143
80106a1f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106a24:	e9 e4 f3 ff ff       	jmp    80105e0d <alltraps>

80106a29 <vector144>:
.globl vector144
vector144:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $144
80106a2b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106a30:	e9 d8 f3 ff ff       	jmp    80105e0d <alltraps>

80106a35 <vector145>:
.globl vector145
vector145:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $145
80106a37:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106a3c:	e9 cc f3 ff ff       	jmp    80105e0d <alltraps>

80106a41 <vector146>:
.globl vector146
vector146:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $146
80106a43:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a48:	e9 c0 f3 ff ff       	jmp    80105e0d <alltraps>

80106a4d <vector147>:
.globl vector147
vector147:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $147
80106a4f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a54:	e9 b4 f3 ff ff       	jmp    80105e0d <alltraps>

80106a59 <vector148>:
.globl vector148
vector148:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $148
80106a5b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a60:	e9 a8 f3 ff ff       	jmp    80105e0d <alltraps>

80106a65 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $149
80106a67:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a6c:	e9 9c f3 ff ff       	jmp    80105e0d <alltraps>

80106a71 <vector150>:
.globl vector150
vector150:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $150
80106a73:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a78:	e9 90 f3 ff ff       	jmp    80105e0d <alltraps>

80106a7d <vector151>:
.globl vector151
vector151:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $151
80106a7f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a84:	e9 84 f3 ff ff       	jmp    80105e0d <alltraps>

80106a89 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $152
80106a8b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a90:	e9 78 f3 ff ff       	jmp    80105e0d <alltraps>

80106a95 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $153
80106a97:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a9c:	e9 6c f3 ff ff       	jmp    80105e0d <alltraps>

80106aa1 <vector154>:
.globl vector154
vector154:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $154
80106aa3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106aa8:	e9 60 f3 ff ff       	jmp    80105e0d <alltraps>

80106aad <vector155>:
.globl vector155
vector155:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $155
80106aaf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ab4:	e9 54 f3 ff ff       	jmp    80105e0d <alltraps>

80106ab9 <vector156>:
.globl vector156
vector156:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $156
80106abb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ac0:	e9 48 f3 ff ff       	jmp    80105e0d <alltraps>

80106ac5 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $157
80106ac7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106acc:	e9 3c f3 ff ff       	jmp    80105e0d <alltraps>

80106ad1 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $158
80106ad3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ad8:	e9 30 f3 ff ff       	jmp    80105e0d <alltraps>

80106add <vector159>:
.globl vector159
vector159:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $159
80106adf:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ae4:	e9 24 f3 ff ff       	jmp    80105e0d <alltraps>

80106ae9 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $160
80106aeb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106af0:	e9 18 f3 ff ff       	jmp    80105e0d <alltraps>

80106af5 <vector161>:
.globl vector161
vector161:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $161
80106af7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106afc:	e9 0c f3 ff ff       	jmp    80105e0d <alltraps>

80106b01 <vector162>:
.globl vector162
vector162:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $162
80106b03:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106b08:	e9 00 f3 ff ff       	jmp    80105e0d <alltraps>

80106b0d <vector163>:
.globl vector163
vector163:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $163
80106b0f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106b14:	e9 f4 f2 ff ff       	jmp    80105e0d <alltraps>

80106b19 <vector164>:
.globl vector164
vector164:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $164
80106b1b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106b20:	e9 e8 f2 ff ff       	jmp    80105e0d <alltraps>

80106b25 <vector165>:
.globl vector165
vector165:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $165
80106b27:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106b2c:	e9 dc f2 ff ff       	jmp    80105e0d <alltraps>

80106b31 <vector166>:
.globl vector166
vector166:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $166
80106b33:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106b38:	e9 d0 f2 ff ff       	jmp    80105e0d <alltraps>

80106b3d <vector167>:
.globl vector167
vector167:
  pushl $0
80106b3d:	6a 00                	push   $0x0
  pushl $167
80106b3f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b44:	e9 c4 f2 ff ff       	jmp    80105e0d <alltraps>

80106b49 <vector168>:
.globl vector168
vector168:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $168
80106b4b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b50:	e9 b8 f2 ff ff       	jmp    80105e0d <alltraps>

80106b55 <vector169>:
.globl vector169
vector169:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $169
80106b57:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b5c:	e9 ac f2 ff ff       	jmp    80105e0d <alltraps>

80106b61 <vector170>:
.globl vector170
vector170:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $170
80106b63:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b68:	e9 a0 f2 ff ff       	jmp    80105e0d <alltraps>

80106b6d <vector171>:
.globl vector171
vector171:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $171
80106b6f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b74:	e9 94 f2 ff ff       	jmp    80105e0d <alltraps>

80106b79 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $172
80106b7b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b80:	e9 88 f2 ff ff       	jmp    80105e0d <alltraps>

80106b85 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $173
80106b87:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b8c:	e9 7c f2 ff ff       	jmp    80105e0d <alltraps>

80106b91 <vector174>:
.globl vector174
vector174:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $174
80106b93:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b98:	e9 70 f2 ff ff       	jmp    80105e0d <alltraps>

80106b9d <vector175>:
.globl vector175
vector175:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $175
80106b9f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106ba4:	e9 64 f2 ff ff       	jmp    80105e0d <alltraps>

80106ba9 <vector176>:
.globl vector176
vector176:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $176
80106bab:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106bb0:	e9 58 f2 ff ff       	jmp    80105e0d <alltraps>

80106bb5 <vector177>:
.globl vector177
vector177:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $177
80106bb7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106bbc:	e9 4c f2 ff ff       	jmp    80105e0d <alltraps>

80106bc1 <vector178>:
.globl vector178
vector178:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $178
80106bc3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106bc8:	e9 40 f2 ff ff       	jmp    80105e0d <alltraps>

80106bcd <vector179>:
.globl vector179
vector179:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $179
80106bcf:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106bd4:	e9 34 f2 ff ff       	jmp    80105e0d <alltraps>

80106bd9 <vector180>:
.globl vector180
vector180:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $180
80106bdb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106be0:	e9 28 f2 ff ff       	jmp    80105e0d <alltraps>

80106be5 <vector181>:
.globl vector181
vector181:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $181
80106be7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106bec:	e9 1c f2 ff ff       	jmp    80105e0d <alltraps>

80106bf1 <vector182>:
.globl vector182
vector182:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $182
80106bf3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106bf8:	e9 10 f2 ff ff       	jmp    80105e0d <alltraps>

80106bfd <vector183>:
.globl vector183
vector183:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $183
80106bff:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106c04:	e9 04 f2 ff ff       	jmp    80105e0d <alltraps>

80106c09 <vector184>:
.globl vector184
vector184:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $184
80106c0b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106c10:	e9 f8 f1 ff ff       	jmp    80105e0d <alltraps>

80106c15 <vector185>:
.globl vector185
vector185:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $185
80106c17:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106c1c:	e9 ec f1 ff ff       	jmp    80105e0d <alltraps>

80106c21 <vector186>:
.globl vector186
vector186:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $186
80106c23:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106c28:	e9 e0 f1 ff ff       	jmp    80105e0d <alltraps>

80106c2d <vector187>:
.globl vector187
vector187:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $187
80106c2f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106c34:	e9 d4 f1 ff ff       	jmp    80105e0d <alltraps>

80106c39 <vector188>:
.globl vector188
vector188:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $188
80106c3b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106c40:	e9 c8 f1 ff ff       	jmp    80105e0d <alltraps>

80106c45 <vector189>:
.globl vector189
vector189:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $189
80106c47:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c4c:	e9 bc f1 ff ff       	jmp    80105e0d <alltraps>

80106c51 <vector190>:
.globl vector190
vector190:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $190
80106c53:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c58:	e9 b0 f1 ff ff       	jmp    80105e0d <alltraps>

80106c5d <vector191>:
.globl vector191
vector191:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $191
80106c5f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c64:	e9 a4 f1 ff ff       	jmp    80105e0d <alltraps>

80106c69 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $192
80106c6b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c70:	e9 98 f1 ff ff       	jmp    80105e0d <alltraps>

80106c75 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $193
80106c77:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c7c:	e9 8c f1 ff ff       	jmp    80105e0d <alltraps>

80106c81 <vector194>:
.globl vector194
vector194:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $194
80106c83:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c88:	e9 80 f1 ff ff       	jmp    80105e0d <alltraps>

80106c8d <vector195>:
.globl vector195
vector195:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $195
80106c8f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c94:	e9 74 f1 ff ff       	jmp    80105e0d <alltraps>

80106c99 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $196
80106c9b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106ca0:	e9 68 f1 ff ff       	jmp    80105e0d <alltraps>

80106ca5 <vector197>:
.globl vector197
vector197:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $197
80106ca7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106cac:	e9 5c f1 ff ff       	jmp    80105e0d <alltraps>

80106cb1 <vector198>:
.globl vector198
vector198:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $198
80106cb3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106cb8:	e9 50 f1 ff ff       	jmp    80105e0d <alltraps>

80106cbd <vector199>:
.globl vector199
vector199:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $199
80106cbf:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106cc4:	e9 44 f1 ff ff       	jmp    80105e0d <alltraps>

80106cc9 <vector200>:
.globl vector200
vector200:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $200
80106ccb:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106cd0:	e9 38 f1 ff ff       	jmp    80105e0d <alltraps>

80106cd5 <vector201>:
.globl vector201
vector201:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $201
80106cd7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106cdc:	e9 2c f1 ff ff       	jmp    80105e0d <alltraps>

80106ce1 <vector202>:
.globl vector202
vector202:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $202
80106ce3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106ce8:	e9 20 f1 ff ff       	jmp    80105e0d <alltraps>

80106ced <vector203>:
.globl vector203
vector203:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $203
80106cef:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106cf4:	e9 14 f1 ff ff       	jmp    80105e0d <alltraps>

80106cf9 <vector204>:
.globl vector204
vector204:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $204
80106cfb:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106d00:	e9 08 f1 ff ff       	jmp    80105e0d <alltraps>

80106d05 <vector205>:
.globl vector205
vector205:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $205
80106d07:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106d0c:	e9 fc f0 ff ff       	jmp    80105e0d <alltraps>

80106d11 <vector206>:
.globl vector206
vector206:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $206
80106d13:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106d18:	e9 f0 f0 ff ff       	jmp    80105e0d <alltraps>

80106d1d <vector207>:
.globl vector207
vector207:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $207
80106d1f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106d24:	e9 e4 f0 ff ff       	jmp    80105e0d <alltraps>

80106d29 <vector208>:
.globl vector208
vector208:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $208
80106d2b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106d30:	e9 d8 f0 ff ff       	jmp    80105e0d <alltraps>

80106d35 <vector209>:
.globl vector209
vector209:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $209
80106d37:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106d3c:	e9 cc f0 ff ff       	jmp    80105e0d <alltraps>

80106d41 <vector210>:
.globl vector210
vector210:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $210
80106d43:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d48:	e9 c0 f0 ff ff       	jmp    80105e0d <alltraps>

80106d4d <vector211>:
.globl vector211
vector211:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $211
80106d4f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d54:	e9 b4 f0 ff ff       	jmp    80105e0d <alltraps>

80106d59 <vector212>:
.globl vector212
vector212:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $212
80106d5b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d60:	e9 a8 f0 ff ff       	jmp    80105e0d <alltraps>

80106d65 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $213
80106d67:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d6c:	e9 9c f0 ff ff       	jmp    80105e0d <alltraps>

80106d71 <vector214>:
.globl vector214
vector214:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $214
80106d73:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d78:	e9 90 f0 ff ff       	jmp    80105e0d <alltraps>

80106d7d <vector215>:
.globl vector215
vector215:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $215
80106d7f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d84:	e9 84 f0 ff ff       	jmp    80105e0d <alltraps>

80106d89 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $216
80106d8b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d90:	e9 78 f0 ff ff       	jmp    80105e0d <alltraps>

80106d95 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $217
80106d97:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d9c:	e9 6c f0 ff ff       	jmp    80105e0d <alltraps>

80106da1 <vector218>:
.globl vector218
vector218:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $218
80106da3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106da8:	e9 60 f0 ff ff       	jmp    80105e0d <alltraps>

80106dad <vector219>:
.globl vector219
vector219:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $219
80106daf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106db4:	e9 54 f0 ff ff       	jmp    80105e0d <alltraps>

80106db9 <vector220>:
.globl vector220
vector220:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $220
80106dbb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106dc0:	e9 48 f0 ff ff       	jmp    80105e0d <alltraps>

80106dc5 <vector221>:
.globl vector221
vector221:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $221
80106dc7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106dcc:	e9 3c f0 ff ff       	jmp    80105e0d <alltraps>

80106dd1 <vector222>:
.globl vector222
vector222:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $222
80106dd3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106dd8:	e9 30 f0 ff ff       	jmp    80105e0d <alltraps>

80106ddd <vector223>:
.globl vector223
vector223:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $223
80106ddf:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106de4:	e9 24 f0 ff ff       	jmp    80105e0d <alltraps>

80106de9 <vector224>:
.globl vector224
vector224:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $224
80106deb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106df0:	e9 18 f0 ff ff       	jmp    80105e0d <alltraps>

80106df5 <vector225>:
.globl vector225
vector225:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $225
80106df7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106dfc:	e9 0c f0 ff ff       	jmp    80105e0d <alltraps>

80106e01 <vector226>:
.globl vector226
vector226:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $226
80106e03:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106e08:	e9 00 f0 ff ff       	jmp    80105e0d <alltraps>

80106e0d <vector227>:
.globl vector227
vector227:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $227
80106e0f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106e14:	e9 f4 ef ff ff       	jmp    80105e0d <alltraps>

80106e19 <vector228>:
.globl vector228
vector228:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $228
80106e1b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106e20:	e9 e8 ef ff ff       	jmp    80105e0d <alltraps>

80106e25 <vector229>:
.globl vector229
vector229:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $229
80106e27:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106e2c:	e9 dc ef ff ff       	jmp    80105e0d <alltraps>

80106e31 <vector230>:
.globl vector230
vector230:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $230
80106e33:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106e38:	e9 d0 ef ff ff       	jmp    80105e0d <alltraps>

80106e3d <vector231>:
.globl vector231
vector231:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $231
80106e3f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e44:	e9 c4 ef ff ff       	jmp    80105e0d <alltraps>

80106e49 <vector232>:
.globl vector232
vector232:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $232
80106e4b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e50:	e9 b8 ef ff ff       	jmp    80105e0d <alltraps>

80106e55 <vector233>:
.globl vector233
vector233:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $233
80106e57:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e5c:	e9 ac ef ff ff       	jmp    80105e0d <alltraps>

80106e61 <vector234>:
.globl vector234
vector234:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $234
80106e63:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e68:	e9 a0 ef ff ff       	jmp    80105e0d <alltraps>

80106e6d <vector235>:
.globl vector235
vector235:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $235
80106e6f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e74:	e9 94 ef ff ff       	jmp    80105e0d <alltraps>

80106e79 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $236
80106e7b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e80:	e9 88 ef ff ff       	jmp    80105e0d <alltraps>

80106e85 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $237
80106e87:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e8c:	e9 7c ef ff ff       	jmp    80105e0d <alltraps>

80106e91 <vector238>:
.globl vector238
vector238:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $238
80106e93:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e98:	e9 70 ef ff ff       	jmp    80105e0d <alltraps>

80106e9d <vector239>:
.globl vector239
vector239:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $239
80106e9f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106ea4:	e9 64 ef ff ff       	jmp    80105e0d <alltraps>

80106ea9 <vector240>:
.globl vector240
vector240:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $240
80106eab:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106eb0:	e9 58 ef ff ff       	jmp    80105e0d <alltraps>

80106eb5 <vector241>:
.globl vector241
vector241:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $241
80106eb7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106ebc:	e9 4c ef ff ff       	jmp    80105e0d <alltraps>

80106ec1 <vector242>:
.globl vector242
vector242:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $242
80106ec3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106ec8:	e9 40 ef ff ff       	jmp    80105e0d <alltraps>

80106ecd <vector243>:
.globl vector243
vector243:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $243
80106ecf:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106ed4:	e9 34 ef ff ff       	jmp    80105e0d <alltraps>

80106ed9 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $244
80106edb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106ee0:	e9 28 ef ff ff       	jmp    80105e0d <alltraps>

80106ee5 <vector245>:
.globl vector245
vector245:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $245
80106ee7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106eec:	e9 1c ef ff ff       	jmp    80105e0d <alltraps>

80106ef1 <vector246>:
.globl vector246
vector246:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $246
80106ef3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106ef8:	e9 10 ef ff ff       	jmp    80105e0d <alltraps>

80106efd <vector247>:
.globl vector247
vector247:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $247
80106eff:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106f04:	e9 04 ef ff ff       	jmp    80105e0d <alltraps>

80106f09 <vector248>:
.globl vector248
vector248:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $248
80106f0b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106f10:	e9 f8 ee ff ff       	jmp    80105e0d <alltraps>

80106f15 <vector249>:
.globl vector249
vector249:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $249
80106f17:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106f1c:	e9 ec ee ff ff       	jmp    80105e0d <alltraps>

80106f21 <vector250>:
.globl vector250
vector250:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $250
80106f23:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106f28:	e9 e0 ee ff ff       	jmp    80105e0d <alltraps>

80106f2d <vector251>:
.globl vector251
vector251:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $251
80106f2f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106f34:	e9 d4 ee ff ff       	jmp    80105e0d <alltraps>

80106f39 <vector252>:
.globl vector252
vector252:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $252
80106f3b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106f40:	e9 c8 ee ff ff       	jmp    80105e0d <alltraps>

80106f45 <vector253>:
.globl vector253
vector253:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $253
80106f47:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f4c:	e9 bc ee ff ff       	jmp    80105e0d <alltraps>

80106f51 <vector254>:
.globl vector254
vector254:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $254
80106f53:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f58:	e9 b0 ee ff ff       	jmp    80105e0d <alltraps>

80106f5d <vector255>:
.globl vector255
vector255:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $255
80106f5f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f64:	e9 a4 ee ff ff       	jmp    80105e0d <alltraps>

80106f69 <lgdt>:
{
80106f69:	55                   	push   %ebp
80106f6a:	89 e5                	mov    %esp,%ebp
80106f6c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f72:	83 e8 01             	sub    $0x1,%eax
80106f75:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f79:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f80:	8b 45 08             	mov    0x8(%ebp),%eax
80106f83:	c1 e8 10             	shr    $0x10,%eax
80106f86:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f8a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f8d:	0f 01 10             	lgdtl  (%eax)
}
80106f90:	90                   	nop
80106f91:	c9                   	leave  
80106f92:	c3                   	ret    

80106f93 <ltr>:
{
80106f93:	55                   	push   %ebp
80106f94:	89 e5                	mov    %esp,%ebp
80106f96:	83 ec 04             	sub    $0x4,%esp
80106f99:	8b 45 08             	mov    0x8(%ebp),%eax
80106f9c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106fa0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106fa4:	0f 00 d8             	ltr    %ax
}
80106fa7:	90                   	nop
80106fa8:	c9                   	leave  
80106fa9:	c3                   	ret    

80106faa <lcr3>:
{
80106faa:	55                   	push   %ebp
80106fab:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106fad:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb0:	0f 22 d8             	mov    %eax,%cr3
}
80106fb3:	90                   	nop
80106fb4:	5d                   	pop    %ebp
80106fb5:	c3                   	ret    

80106fb6 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106fb6:	55                   	push   %ebp
80106fb7:	89 e5                	mov    %esp,%ebp
80106fb9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106fbc:	e8 ea c9 ff ff       	call   801039ab <cpuid>
80106fc1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106fc7:	05 80 69 19 80       	add    $0x80196980,%eax
80106fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106feb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fef:	83 e2 f0             	and    $0xfffffff0,%edx
80106ff2:	83 ca 0a             	or     $0xa,%edx
80106ff5:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ffb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fff:	83 ca 10             	or     $0x10,%edx
80107002:	88 50 7d             	mov    %dl,0x7d(%eax)
80107005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107008:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010700c:	83 e2 9f             	and    $0xffffff9f,%edx
8010700f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107015:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107019:	83 ca 80             	or     $0xffffff80,%edx
8010701c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010701f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107022:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107026:	83 ca 0f             	or     $0xf,%edx
80107029:	88 50 7e             	mov    %dl,0x7e(%eax)
8010702c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107033:	83 e2 ef             	and    $0xffffffef,%edx
80107036:	88 50 7e             	mov    %dl,0x7e(%eax)
80107039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107040:	83 e2 df             	and    $0xffffffdf,%edx
80107043:	88 50 7e             	mov    %dl,0x7e(%eax)
80107046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107049:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010704d:	83 ca 40             	or     $0x40,%edx
80107050:	88 50 7e             	mov    %dl,0x7e(%eax)
80107053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107056:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010705a:	83 ca 80             	or     $0xffffff80,%edx
8010705d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107063:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107071:	ff ff 
80107073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107076:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010707d:	00 00 
8010707f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107082:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107093:	83 e2 f0             	and    $0xfffffff0,%edx
80107096:	83 ca 02             	or     $0x2,%edx
80107099:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010709f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801070a9:	83 ca 10             	or     $0x10,%edx
801070ac:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801070b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801070bc:	83 e2 9f             	and    $0xffffff9f,%edx
801070bf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801070c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801070cf:	83 ca 80             	or     $0xffffff80,%edx
801070d2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801070d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070db:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070e2:	83 ca 0f             	or     $0xf,%edx
801070e5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ee:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070f5:	83 e2 ef             	and    $0xffffffef,%edx
801070f8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107101:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107108:	83 e2 df             	and    $0xffffffdf,%edx
8010710b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107114:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010711b:	83 ca 40             	or     $0x40,%edx
8010711e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107124:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107127:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010712e:	83 ca 80             	or     $0xffffff80,%edx
80107131:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107144:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010714b:	ff ff 
8010714d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107150:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107157:	00 00 
80107159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107166:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010716d:	83 e2 f0             	and    $0xfffffff0,%edx
80107170:	83 ca 0a             	or     $0xa,%edx
80107173:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107183:	83 ca 10             	or     $0x10,%edx
80107186:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010718c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107196:	83 ca 60             	or     $0x60,%edx
80107199:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010719f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801071a9:	83 ca 80             	or     $0xffffff80,%edx
801071ac:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801071b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071bc:	83 ca 0f             	or     $0xf,%edx
801071bf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071cf:	83 e2 ef             	and    $0xffffffef,%edx
801071d2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071db:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071e2:	83 e2 df             	and    $0xffffffdf,%edx
801071e5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ee:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071f5:	83 ca 40             	or     $0x40,%edx
801071f8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107201:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107208:	83 ca 80             	or     $0xffffff80,%edx
8010720b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107214:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010721b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107225:	ff ff 
80107227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107231:	00 00 
80107233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107236:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010723d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107240:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107247:	83 e2 f0             	and    $0xfffffff0,%edx
8010724a:	83 ca 02             	or     $0x2,%edx
8010724d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107256:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010725d:	83 ca 10             	or     $0x10,%edx
80107260:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107269:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107270:	83 ca 60             	or     $0x60,%edx
80107273:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107283:	83 ca 80             	or     $0xffffff80,%edx
80107286:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010728c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107296:	83 ca 0f             	or     $0xf,%edx
80107299:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010729f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072a9:	83 e2 ef             	and    $0xffffffef,%edx
801072ac:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072bc:	83 e2 df             	and    $0xffffffdf,%edx
801072bf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072cf:	83 ca 40             	or     $0x40,%edx
801072d2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072db:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072e2:	83 ca 80             	or     $0xffffff80,%edx
801072e5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ee:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801072f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f8:	83 c0 70             	add    $0x70,%eax
801072fb:	83 ec 08             	sub    $0x8,%esp
801072fe:	6a 30                	push   $0x30
80107300:	50                   	push   %eax
80107301:	e8 63 fc ff ff       	call   80106f69 <lgdt>
80107306:	83 c4 10             	add    $0x10,%esp
}
80107309:	90                   	nop
8010730a:	c9                   	leave  
8010730b:	c3                   	ret    

8010730c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010730c:	55                   	push   %ebp
8010730d:	89 e5                	mov    %esp,%ebp
8010730f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107312:	8b 45 0c             	mov    0xc(%ebp),%eax
80107315:	c1 e8 16             	shr    $0x16,%eax
80107318:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010731f:	8b 45 08             	mov    0x8(%ebp),%eax
80107322:	01 d0                	add    %edx,%eax
80107324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010732a:	8b 00                	mov    (%eax),%eax
8010732c:	83 e0 01             	and    $0x1,%eax
8010732f:	85 c0                	test   %eax,%eax
80107331:	74 14                	je     80107347 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107336:	8b 00                	mov    (%eax),%eax
80107338:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010733d:	05 00 00 00 80       	add    $0x80000000,%eax
80107342:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107345:	eb 42                	jmp    80107389 <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107347:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010734b:	74 0e                	je     8010735b <walkpgdir+0x4f>
8010734d:	e8 5c b4 ff ff       	call   801027ae <kalloc>
80107352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107359:	75 07                	jne    80107362 <walkpgdir+0x56>
      return 0;
8010735b:	b8 00 00 00 00       	mov    $0x0,%eax
80107360:	eb 3e                	jmp    801073a0 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107362:	83 ec 04             	sub    $0x4,%esp
80107365:	68 00 10 00 00       	push   $0x1000
8010736a:	6a 00                	push   $0x0
8010736c:	ff 75 f4             	push   -0xc(%ebp)
8010736f:	e8 1b d7 ff ff       	call   80104a8f <memset>
80107374:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737a:	05 00 00 00 80       	add    $0x80000000,%eax
8010737f:	83 c8 07             	or     $0x7,%eax
80107382:	89 c2                	mov    %eax,%edx
80107384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107387:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107389:	8b 45 0c             	mov    0xc(%ebp),%eax
8010738c:	c1 e8 0c             	shr    $0xc,%eax
8010738f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107394:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010739b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739e:	01 d0                	add    %edx,%eax
}
801073a0:	c9                   	leave  
801073a1:	c3                   	ret    

801073a2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801073a2:	55                   	push   %ebp
801073a3:	89 e5                	mov    %esp,%ebp
801073a5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801073a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801073ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801073b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801073b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801073b6:	8b 45 10             	mov    0x10(%ebp),%eax
801073b9:	01 d0                	add    %edx,%eax
801073bb:	83 e8 01             	sub    $0x1,%eax
801073be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801073c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073c6:	83 ec 04             	sub    $0x4,%esp
801073c9:	6a 01                	push   $0x1
801073cb:	ff 75 f4             	push   -0xc(%ebp)
801073ce:	ff 75 08             	push   0x8(%ebp)
801073d1:	e8 36 ff ff ff       	call   8010730c <walkpgdir>
801073d6:	83 c4 10             	add    $0x10,%esp
801073d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801073dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801073e0:	75 07                	jne    801073e9 <mappages+0x47>
      return -1;
801073e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073e7:	eb 47                	jmp    80107430 <mappages+0x8e>
    if(*pte & PTE_P)
801073e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073ec:	8b 00                	mov    (%eax),%eax
801073ee:	83 e0 01             	and    $0x1,%eax
801073f1:	85 c0                	test   %eax,%eax
801073f3:	74 0d                	je     80107402 <mappages+0x60>
      panic("remap");
801073f5:	83 ec 0c             	sub    $0xc,%esp
801073f8:	68 e8 a7 10 80       	push   $0x8010a7e8
801073fd:	e8 bf 91 ff ff       	call   801005c1 <panic>
    *pte = pa | perm | PTE_P;
80107402:	8b 45 18             	mov    0x18(%ebp),%eax
80107405:	0b 45 14             	or     0x14(%ebp),%eax
80107408:	83 c8 01             	or     $0x1,%eax
8010740b:	89 c2                	mov    %eax,%edx
8010740d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107410:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107415:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107418:	74 10                	je     8010742a <mappages+0x88>
      break;
    a += PGSIZE;
8010741a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107421:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107428:	eb 9c                	jmp    801073c6 <mappages+0x24>
      break;
8010742a:	90                   	nop
  }
  return 0;
8010742b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107430:	c9                   	leave  
80107431:	c3                   	ret    

80107432 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107432:	55                   	push   %ebp
80107433:	89 e5                	mov    %esp,%ebp
80107435:	53                   	push   %ebx
80107436:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107439:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107440:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107446:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010744b:	29 d0                	sub    %edx,%eax
8010744d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107450:	a1 48 6c 19 80       	mov    0x80196c48,%eax
80107455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107458:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
8010745e:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107463:	01 d0                	add    %edx,%eax
80107465:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107468:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010746f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107472:	83 c0 30             	add    $0x30,%eax
80107475:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107478:	89 10                	mov    %edx,(%eax)
8010747a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010747d:	89 50 04             	mov    %edx,0x4(%eax)
80107480:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107483:	89 50 08             	mov    %edx,0x8(%eax)
80107486:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107489:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010748c:	e8 1d b3 ff ff       	call   801027ae <kalloc>
80107491:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107498:	75 07                	jne    801074a1 <setupkvm+0x6f>
    return 0;
8010749a:	b8 00 00 00 00       	mov    $0x0,%eax
8010749f:	eb 78                	jmp    80107519 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801074a1:	83 ec 04             	sub    $0x4,%esp
801074a4:	68 00 10 00 00       	push   $0x1000
801074a9:	6a 00                	push   $0x0
801074ab:	ff 75 f0             	push   -0x10(%ebp)
801074ae:	e8 dc d5 ff ff       	call   80104a8f <memset>
801074b3:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074b6:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801074bd:	eb 4e                	jmp    8010750d <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801074bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801074cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ce:	8b 58 08             	mov    0x8(%eax),%ebx
801074d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d4:	8b 40 04             	mov    0x4(%eax),%eax
801074d7:	29 c3                	sub    %eax,%ebx
801074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dc:	8b 00                	mov    (%eax),%eax
801074de:	83 ec 0c             	sub    $0xc,%esp
801074e1:	51                   	push   %ecx
801074e2:	52                   	push   %edx
801074e3:	53                   	push   %ebx
801074e4:	50                   	push   %eax
801074e5:	ff 75 f0             	push   -0x10(%ebp)
801074e8:	e8 b5 fe ff ff       	call   801073a2 <mappages>
801074ed:	83 c4 20             	add    $0x20,%esp
801074f0:	85 c0                	test   %eax,%eax
801074f2:	79 15                	jns    80107509 <setupkvm+0xd7>
      freevm(pgdir);
801074f4:	83 ec 0c             	sub    $0xc,%esp
801074f7:	ff 75 f0             	push   -0x10(%ebp)
801074fa:	e8 f5 04 00 00       	call   801079f4 <freevm>
801074ff:	83 c4 10             	add    $0x10,%esp
      return 0;
80107502:	b8 00 00 00 00       	mov    $0x0,%eax
80107507:	eb 10                	jmp    80107519 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107509:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010750d:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107514:	72 a9                	jb     801074bf <setupkvm+0x8d>
    }
  return pgdir;
80107516:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010751c:	c9                   	leave  
8010751d:	c3                   	ret    

8010751e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010751e:	55                   	push   %ebp
8010751f:	89 e5                	mov    %esp,%ebp
80107521:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107524:	e8 09 ff ff ff       	call   80107432 <setupkvm>
80107529:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
8010752e:	e8 03 00 00 00       	call   80107536 <switchkvm>
}
80107533:	90                   	nop
80107534:	c9                   	leave  
80107535:	c3                   	ret    

80107536 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107536:	55                   	push   %ebp
80107537:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107539:	a1 7c 69 19 80       	mov    0x8019697c,%eax
8010753e:	05 00 00 00 80       	add    $0x80000000,%eax
80107543:	50                   	push   %eax
80107544:	e8 61 fa ff ff       	call   80106faa <lcr3>
80107549:	83 c4 04             	add    $0x4,%esp
}
8010754c:	90                   	nop
8010754d:	c9                   	leave  
8010754e:	c3                   	ret    

8010754f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010754f:	55                   	push   %ebp
80107550:	89 e5                	mov    %esp,%ebp
80107552:	56                   	push   %esi
80107553:	53                   	push   %ebx
80107554:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107557:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010755b:	75 0d                	jne    8010756a <switchuvm+0x1b>
    panic("switchuvm: no process");
8010755d:	83 ec 0c             	sub    $0xc,%esp
80107560:	68 ee a7 10 80       	push   $0x8010a7ee
80107565:	e8 57 90 ff ff       	call   801005c1 <panic>
  if(p->kstack == 0)
8010756a:	8b 45 08             	mov    0x8(%ebp),%eax
8010756d:	8b 40 08             	mov    0x8(%eax),%eax
80107570:	85 c0                	test   %eax,%eax
80107572:	75 0d                	jne    80107581 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107574:	83 ec 0c             	sub    $0xc,%esp
80107577:	68 04 a8 10 80       	push   $0x8010a804
8010757c:	e8 40 90 ff ff       	call   801005c1 <panic>
  if(p->pgdir == 0)
80107581:	8b 45 08             	mov    0x8(%ebp),%eax
80107584:	8b 40 04             	mov    0x4(%eax),%eax
80107587:	85 c0                	test   %eax,%eax
80107589:	75 0d                	jne    80107598 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010758b:	83 ec 0c             	sub    $0xc,%esp
8010758e:	68 19 a8 10 80       	push   $0x8010a819
80107593:	e8 29 90 ff ff       	call   801005c1 <panic>

  pushcli();
80107598:	e8 e7 d3 ff ff       	call   80104984 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010759d:	e8 24 c4 ff ff       	call   801039c6 <mycpu>
801075a2:	89 c3                	mov    %eax,%ebx
801075a4:	e8 1d c4 ff ff       	call   801039c6 <mycpu>
801075a9:	83 c0 08             	add    $0x8,%eax
801075ac:	89 c6                	mov    %eax,%esi
801075ae:	e8 13 c4 ff ff       	call   801039c6 <mycpu>
801075b3:	83 c0 08             	add    $0x8,%eax
801075b6:	c1 e8 10             	shr    $0x10,%eax
801075b9:	88 45 f7             	mov    %al,-0x9(%ebp)
801075bc:	e8 05 c4 ff ff       	call   801039c6 <mycpu>
801075c1:	83 c0 08             	add    $0x8,%eax
801075c4:	c1 e8 18             	shr    $0x18,%eax
801075c7:	89 c2                	mov    %eax,%edx
801075c9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801075d0:	67 00 
801075d2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801075d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801075dd:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801075e3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075ea:	83 e0 f0             	and    $0xfffffff0,%eax
801075ed:	83 c8 09             	or     $0x9,%eax
801075f0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075f6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075fd:	83 c8 10             	or     $0x10,%eax
80107600:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107606:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010760d:	83 e0 9f             	and    $0xffffff9f,%eax
80107610:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107616:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010761d:	83 c8 80             	or     $0xffffff80,%eax
80107620:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107626:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010762d:	83 e0 f0             	and    $0xfffffff0,%eax
80107630:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107636:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010763d:	83 e0 ef             	and    $0xffffffef,%eax
80107640:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107646:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010764d:	83 e0 df             	and    $0xffffffdf,%eax
80107650:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107656:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010765d:	83 c8 40             	or     $0x40,%eax
80107660:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107666:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010766d:	83 e0 7f             	and    $0x7f,%eax
80107670:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107676:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010767c:	e8 45 c3 ff ff       	call   801039c6 <mycpu>
80107681:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107688:	83 e2 ef             	and    $0xffffffef,%edx
8010768b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107691:	e8 30 c3 ff ff       	call   801039c6 <mycpu>
80107696:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010769c:	8b 45 08             	mov    0x8(%ebp),%eax
8010769f:	8b 40 08             	mov    0x8(%eax),%eax
801076a2:	89 c3                	mov    %eax,%ebx
801076a4:	e8 1d c3 ff ff       	call   801039c6 <mycpu>
801076a9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801076af:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801076b2:	e8 0f c3 ff ff       	call   801039c6 <mycpu>
801076b7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801076bd:	83 ec 0c             	sub    $0xc,%esp
801076c0:	6a 28                	push   $0x28
801076c2:	e8 cc f8 ff ff       	call   80106f93 <ltr>
801076c7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801076ca:	8b 45 08             	mov    0x8(%ebp),%eax
801076cd:	8b 40 04             	mov    0x4(%eax),%eax
801076d0:	05 00 00 00 80       	add    $0x80000000,%eax
801076d5:	83 ec 0c             	sub    $0xc,%esp
801076d8:	50                   	push   %eax
801076d9:	e8 cc f8 ff ff       	call   80106faa <lcr3>
801076de:	83 c4 10             	add    $0x10,%esp
  popcli();
801076e1:	e8 eb d2 ff ff       	call   801049d1 <popcli>
}
801076e6:	90                   	nop
801076e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801076ea:	5b                   	pop    %ebx
801076eb:	5e                   	pop    %esi
801076ec:	5d                   	pop    %ebp
801076ed:	c3                   	ret    

801076ee <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801076ee:	55                   	push   %ebp
801076ef:	89 e5                	mov    %esp,%ebp
801076f1:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801076f4:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801076fb:	76 0d                	jbe    8010770a <inituvm+0x1c>
    panic("inituvm: more than a page");
801076fd:	83 ec 0c             	sub    $0xc,%esp
80107700:	68 2d a8 10 80       	push   $0x8010a82d
80107705:	e8 b7 8e ff ff       	call   801005c1 <panic>
  mem = kalloc();
8010770a:	e8 9f b0 ff ff       	call   801027ae <kalloc>
8010770f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107712:	83 ec 04             	sub    $0x4,%esp
80107715:	68 00 10 00 00       	push   $0x1000
8010771a:	6a 00                	push   $0x0
8010771c:	ff 75 f4             	push   -0xc(%ebp)
8010771f:	e8 6b d3 ff ff       	call   80104a8f <memset>
80107724:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	05 00 00 00 80       	add    $0x80000000,%eax
8010772f:	83 ec 0c             	sub    $0xc,%esp
80107732:	6a 06                	push   $0x6
80107734:	50                   	push   %eax
80107735:	68 00 10 00 00       	push   $0x1000
8010773a:	6a 00                	push   $0x0
8010773c:	ff 75 08             	push   0x8(%ebp)
8010773f:	e8 5e fc ff ff       	call   801073a2 <mappages>
80107744:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107747:	83 ec 04             	sub    $0x4,%esp
8010774a:	ff 75 10             	push   0x10(%ebp)
8010774d:	ff 75 0c             	push   0xc(%ebp)
80107750:	ff 75 f4             	push   -0xc(%ebp)
80107753:	e8 f6 d3 ff ff       	call   80104b4e <memmove>
80107758:	83 c4 10             	add    $0x10,%esp
}
8010775b:	90                   	nop
8010775c:	c9                   	leave  
8010775d:	c3                   	ret    

8010775e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010775e:	55                   	push   %ebp
8010775f:	89 e5                	mov    %esp,%ebp
80107761:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107764:	8b 45 0c             	mov    0xc(%ebp),%eax
80107767:	25 ff 0f 00 00       	and    $0xfff,%eax
8010776c:	85 c0                	test   %eax,%eax
8010776e:	74 0d                	je     8010777d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107770:	83 ec 0c             	sub    $0xc,%esp
80107773:	68 48 a8 10 80       	push   $0x8010a848
80107778:	e8 44 8e ff ff       	call   801005c1 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010777d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107784:	e9 8f 00 00 00       	jmp    80107818 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107789:	8b 55 0c             	mov    0xc(%ebp),%edx
8010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778f:	01 d0                	add    %edx,%eax
80107791:	83 ec 04             	sub    $0x4,%esp
80107794:	6a 00                	push   $0x0
80107796:	50                   	push   %eax
80107797:	ff 75 08             	push   0x8(%ebp)
8010779a:	e8 6d fb ff ff       	call   8010730c <walkpgdir>
8010779f:	83 c4 10             	add    $0x10,%esp
801077a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801077a9:	75 0d                	jne    801077b8 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801077ab:	83 ec 0c             	sub    $0xc,%esp
801077ae:	68 6b a8 10 80       	push   $0x8010a86b
801077b3:	e8 09 8e ff ff       	call   801005c1 <panic>
    pa = PTE_ADDR(*pte);
801077b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077bb:	8b 00                	mov    (%eax),%eax
801077bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801077c5:	8b 45 18             	mov    0x18(%ebp),%eax
801077c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801077cb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801077d0:	77 0b                	ja     801077dd <loaduvm+0x7f>
      n = sz - i;
801077d2:	8b 45 18             	mov    0x18(%ebp),%eax
801077d5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801077d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801077db:	eb 07                	jmp    801077e4 <loaduvm+0x86>
    else
      n = PGSIZE;
801077dd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801077e4:	8b 55 14             	mov    0x14(%ebp),%edx
801077e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ea:	01 d0                	add    %edx,%eax
801077ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077ef:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077f5:	ff 75 f0             	push   -0x10(%ebp)
801077f8:	50                   	push   %eax
801077f9:	52                   	push   %edx
801077fa:	ff 75 10             	push   0x10(%ebp)
801077fd:	e8 e2 a6 ff ff       	call   80101ee4 <readi>
80107802:	83 c4 10             	add    $0x10,%esp
80107805:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107808:	74 07                	je     80107811 <loaduvm+0xb3>
      return -1;
8010780a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010780f:	eb 18                	jmp    80107829 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107811:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010781e:	0f 82 65 ff ff ff    	jb     80107789 <loaduvm+0x2b>
  }
  return 0;
80107824:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107829:	c9                   	leave  
8010782a:	c3                   	ret    

8010782b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010782b:	55                   	push   %ebp
8010782c:	89 e5                	mov    %esp,%ebp
8010782e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107831:	8b 45 10             	mov    0x10(%ebp),%eax
80107834:	85 c0                	test   %eax,%eax
80107836:	79 0a                	jns    80107842 <allocuvm+0x17>
    return 0;
80107838:	b8 00 00 00 00       	mov    $0x0,%eax
8010783d:	e9 ec 00 00 00       	jmp    8010792e <allocuvm+0x103>
  if(newsz < oldsz)
80107842:	8b 45 10             	mov    0x10(%ebp),%eax
80107845:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107848:	73 08                	jae    80107852 <allocuvm+0x27>
    return oldsz;
8010784a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010784d:	e9 dc 00 00 00       	jmp    8010792e <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107852:	8b 45 0c             	mov    0xc(%ebp),%eax
80107855:	05 ff 0f 00 00       	add    $0xfff,%eax
8010785a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010785f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107862:	e9 b8 00 00 00       	jmp    8010791f <allocuvm+0xf4>
    mem = kalloc();
80107867:	e8 42 af ff ff       	call   801027ae <kalloc>
8010786c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010786f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107873:	75 2e                	jne    801078a3 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107875:	83 ec 0c             	sub    $0xc,%esp
80107878:	68 89 a8 10 80       	push   $0x8010a889
8010787d:	e8 72 8b ff ff       	call   801003f4 <cprintf>
80107882:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107885:	83 ec 04             	sub    $0x4,%esp
80107888:	ff 75 0c             	push   0xc(%ebp)
8010788b:	ff 75 10             	push   0x10(%ebp)
8010788e:	ff 75 08             	push   0x8(%ebp)
80107891:	e8 9a 00 00 00       	call   80107930 <deallocuvm>
80107896:	83 c4 10             	add    $0x10,%esp
      return 0;
80107899:	b8 00 00 00 00       	mov    $0x0,%eax
8010789e:	e9 8b 00 00 00       	jmp    8010792e <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801078a3:	83 ec 04             	sub    $0x4,%esp
801078a6:	68 00 10 00 00       	push   $0x1000
801078ab:	6a 00                	push   $0x0
801078ad:	ff 75 f0             	push   -0x10(%ebp)
801078b0:	e8 da d1 ff ff       	call   80104a8f <memset>
801078b5:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801078b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078bb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801078c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c4:	83 ec 0c             	sub    $0xc,%esp
801078c7:	6a 06                	push   $0x6
801078c9:	52                   	push   %edx
801078ca:	68 00 10 00 00       	push   $0x1000
801078cf:	50                   	push   %eax
801078d0:	ff 75 08             	push   0x8(%ebp)
801078d3:	e8 ca fa ff ff       	call   801073a2 <mappages>
801078d8:	83 c4 20             	add    $0x20,%esp
801078db:	85 c0                	test   %eax,%eax
801078dd:	79 39                	jns    80107918 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801078df:	83 ec 0c             	sub    $0xc,%esp
801078e2:	68 a1 a8 10 80       	push   $0x8010a8a1
801078e7:	e8 08 8b ff ff       	call   801003f4 <cprintf>
801078ec:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078ef:	83 ec 04             	sub    $0x4,%esp
801078f2:	ff 75 0c             	push   0xc(%ebp)
801078f5:	ff 75 10             	push   0x10(%ebp)
801078f8:	ff 75 08             	push   0x8(%ebp)
801078fb:	e8 30 00 00 00       	call   80107930 <deallocuvm>
80107900:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107903:	83 ec 0c             	sub    $0xc,%esp
80107906:	ff 75 f0             	push   -0x10(%ebp)
80107909:	e8 06 ae ff ff       	call   80102714 <kfree>
8010790e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107911:	b8 00 00 00 00       	mov    $0x0,%eax
80107916:	eb 16                	jmp    8010792e <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107918:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010791f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107922:	3b 45 10             	cmp    0x10(%ebp),%eax
80107925:	0f 82 3c ff ff ff    	jb     80107867 <allocuvm+0x3c>
    }
  }
  return newsz;
8010792b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010792e:	c9                   	leave  
8010792f:	c3                   	ret    

80107930 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107930:	55                   	push   %ebp
80107931:	89 e5                	mov    %esp,%ebp
80107933:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107936:	8b 45 10             	mov    0x10(%ebp),%eax
80107939:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010793c:	72 08                	jb     80107946 <deallocuvm+0x16>
    return oldsz;
8010793e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107941:	e9 ac 00 00 00       	jmp    801079f2 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107946:	8b 45 10             	mov    0x10(%ebp),%eax
80107949:	05 ff 0f 00 00       	add    $0xfff,%eax
8010794e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107953:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107956:	e9 88 00 00 00       	jmp    801079e3 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010795b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795e:	83 ec 04             	sub    $0x4,%esp
80107961:	6a 00                	push   $0x0
80107963:	50                   	push   %eax
80107964:	ff 75 08             	push   0x8(%ebp)
80107967:	e8 a0 f9 ff ff       	call   8010730c <walkpgdir>
8010796c:	83 c4 10             	add    $0x10,%esp
8010796f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107972:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107976:	75 16                	jne    8010798e <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	c1 e8 16             	shr    $0x16,%eax
8010797e:	83 c0 01             	add    $0x1,%eax
80107981:	c1 e0 16             	shl    $0x16,%eax
80107984:	2d 00 10 00 00       	sub    $0x1000,%eax
80107989:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010798c:	eb 4e                	jmp    801079dc <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010798e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107991:	8b 00                	mov    (%eax),%eax
80107993:	83 e0 01             	and    $0x1,%eax
80107996:	85 c0                	test   %eax,%eax
80107998:	74 42                	je     801079dc <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010799a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010799d:	8b 00                	mov    (%eax),%eax
8010799f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801079a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079ab:	75 0d                	jne    801079ba <deallocuvm+0x8a>
        panic("kfree");
801079ad:	83 ec 0c             	sub    $0xc,%esp
801079b0:	68 bd a8 10 80       	push   $0x8010a8bd
801079b5:	e8 07 8c ff ff       	call   801005c1 <panic>
      char *v = P2V(pa);
801079ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079bd:	05 00 00 00 80       	add    $0x80000000,%eax
801079c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801079c5:	83 ec 0c             	sub    $0xc,%esp
801079c8:	ff 75 e8             	push   -0x18(%ebp)
801079cb:	e8 44 ad ff ff       	call   80102714 <kfree>
801079d0:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801079d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801079dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079e9:	0f 82 6c ff ff ff    	jb     8010795b <deallocuvm+0x2b>
    }
  }
  return newsz;
801079ef:	8b 45 10             	mov    0x10(%ebp),%eax
}
801079f2:	c9                   	leave  
801079f3:	c3                   	ret    

801079f4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801079f4:	55                   	push   %ebp
801079f5:	89 e5                	mov    %esp,%ebp
801079f7:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801079fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079fe:	75 0d                	jne    80107a0d <freevm+0x19>
    panic("freevm: no pgdir");
80107a00:	83 ec 0c             	sub    $0xc,%esp
80107a03:	68 c3 a8 10 80       	push   $0x8010a8c3
80107a08:	e8 b4 8b ff ff       	call   801005c1 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107a0d:	83 ec 04             	sub    $0x4,%esp
80107a10:	6a 00                	push   $0x0
80107a12:	68 00 00 00 80       	push   $0x80000000
80107a17:	ff 75 08             	push   0x8(%ebp)
80107a1a:	e8 11 ff ff ff       	call   80107930 <deallocuvm>
80107a1f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a29:	eb 48                	jmp    80107a73 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a35:	8b 45 08             	mov    0x8(%ebp),%eax
80107a38:	01 d0                	add    %edx,%eax
80107a3a:	8b 00                	mov    (%eax),%eax
80107a3c:	83 e0 01             	and    $0x1,%eax
80107a3f:	85 c0                	test   %eax,%eax
80107a41:	74 2c                	je     80107a6f <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a50:	01 d0                	add    %edx,%eax
80107a52:	8b 00                	mov    (%eax),%eax
80107a54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a59:	05 00 00 00 80       	add    $0x80000000,%eax
80107a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107a61:	83 ec 0c             	sub    $0xc,%esp
80107a64:	ff 75 f0             	push   -0x10(%ebp)
80107a67:	e8 a8 ac ff ff       	call   80102714 <kfree>
80107a6c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a73:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a7a:	76 af                	jbe    80107a2b <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a7c:	83 ec 0c             	sub    $0xc,%esp
80107a7f:	ff 75 08             	push   0x8(%ebp)
80107a82:	e8 8d ac ff ff       	call   80102714 <kfree>
80107a87:	83 c4 10             	add    $0x10,%esp
}
80107a8a:	90                   	nop
80107a8b:	c9                   	leave  
80107a8c:	c3                   	ret    

80107a8d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a8d:	55                   	push   %ebp
80107a8e:	89 e5                	mov    %esp,%ebp
80107a90:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a93:	83 ec 04             	sub    $0x4,%esp
80107a96:	6a 00                	push   $0x0
80107a98:	ff 75 0c             	push   0xc(%ebp)
80107a9b:	ff 75 08             	push   0x8(%ebp)
80107a9e:	e8 69 f8 ff ff       	call   8010730c <walkpgdir>
80107aa3:	83 c4 10             	add    $0x10,%esp
80107aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107aa9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107aad:	75 0d                	jne    80107abc <clearpteu+0x2f>
    panic("clearpteu");
80107aaf:	83 ec 0c             	sub    $0xc,%esp
80107ab2:	68 d4 a8 10 80       	push   $0x8010a8d4
80107ab7:	e8 05 8b ff ff       	call   801005c1 <panic>
  *pte &= ~PTE_U;
80107abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abf:	8b 00                	mov    (%eax),%eax
80107ac1:	83 e0 fb             	and    $0xfffffffb,%eax
80107ac4:	89 c2                	mov    %eax,%edx
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	89 10                	mov    %edx,(%eax)
}
80107acb:	90                   	nop
80107acc:	c9                   	leave  
80107acd:	c3                   	ret    

80107ace <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ace:	55                   	push   %ebp
80107acf:	89 e5                	mov    %esp,%ebp
80107ad1:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ad4:	e8 59 f9 ff ff       	call   80107432 <setupkvm>
80107ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107adc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ae0:	75 0a                	jne    80107aec <copyuvm+0x1e>
    return 0;
80107ae2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ae7:	e9 d6 00 00 00       	jmp    80107bc2 <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107aec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107af3:	e9 a3 00 00 00       	jmp    80107b9b <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	83 ec 04             	sub    $0x4,%esp
80107afe:	6a 00                	push   $0x0
80107b00:	50                   	push   %eax
80107b01:	ff 75 08             	push   0x8(%ebp)
80107b04:	e8 03 f8 ff ff       	call   8010730c <walkpgdir>
80107b09:	83 c4 10             	add    $0x10,%esp
80107b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b13:	74 7b                	je     80107b90 <copyuvm+0xc2>
      continue;
    }
    if(!(*pte & PTE_P)){
80107b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b18:	8b 00                	mov    (%eax),%eax
80107b1a:	83 e0 01             	and    $0x1,%eax
80107b1d:	85 c0                	test   %eax,%eax
80107b1f:	74 72                	je     80107b93 <copyuvm+0xc5>
      continue;
    }
    pa = PTE_ADDR(*pte);
80107b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b24:	8b 00                	mov    (%eax),%eax
80107b26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107b2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b31:	8b 00                	mov    (%eax),%eax
80107b33:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107b3b:	e8 6e ac ff ff       	call   801027ae <kalloc>
80107b40:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b43:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107b47:	74 62                	je     80107bab <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107b49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b4c:	05 00 00 00 80       	add    $0x80000000,%eax
80107b51:	83 ec 04             	sub    $0x4,%esp
80107b54:	68 00 10 00 00       	push   $0x1000
80107b59:	50                   	push   %eax
80107b5a:	ff 75 e0             	push   -0x20(%ebp)
80107b5d:	e8 ec cf ff ff       	call   80104b4e <memmove>
80107b62:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107b65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b6b:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	83 ec 0c             	sub    $0xc,%esp
80107b77:	52                   	push   %edx
80107b78:	51                   	push   %ecx
80107b79:	68 00 10 00 00       	push   $0x1000
80107b7e:	50                   	push   %eax
80107b7f:	ff 75 f0             	push   -0x10(%ebp)
80107b82:	e8 1b f8 ff ff       	call   801073a2 <mappages>
80107b87:	83 c4 20             	add    $0x20,%esp
80107b8a:	85 c0                	test   %eax,%eax
80107b8c:	78 20                	js     80107bae <copyuvm+0xe0>
80107b8e:	eb 04                	jmp    80107b94 <copyuvm+0xc6>
      continue;
80107b90:	90                   	nop
80107b91:	eb 01                	jmp    80107b94 <copyuvm+0xc6>
      continue;
80107b93:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107b94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	85 c0                	test   %eax,%eax
80107ba0:	0f 89 52 ff ff ff    	jns    80107af8 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ba9:	eb 17                	jmp    80107bc2 <copyuvm+0xf4>
      goto bad;
80107bab:	90                   	nop
80107bac:	eb 01                	jmp    80107baf <copyuvm+0xe1>
      goto bad;
80107bae:	90                   	nop

bad:
  freevm(d);
80107baf:	83 ec 0c             	sub    $0xc,%esp
80107bb2:	ff 75 f0             	push   -0x10(%ebp)
80107bb5:	e8 3a fe ff ff       	call   801079f4 <freevm>
80107bba:	83 c4 10             	add    $0x10,%esp
  return 0;
80107bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bc2:	c9                   	leave  
80107bc3:	c3                   	ret    

80107bc4 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107bc4:	55                   	push   %ebp
80107bc5:	89 e5                	mov    %esp,%ebp
80107bc7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107bca:	83 ec 04             	sub    $0x4,%esp
80107bcd:	6a 00                	push   $0x0
80107bcf:	ff 75 0c             	push   0xc(%ebp)
80107bd2:	ff 75 08             	push   0x8(%ebp)
80107bd5:	e8 32 f7 ff ff       	call   8010730c <walkpgdir>
80107bda:	83 c4 10             	add    $0x10,%esp
80107bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be3:	8b 00                	mov    (%eax),%eax
80107be5:	83 e0 01             	and    $0x1,%eax
80107be8:	85 c0                	test   %eax,%eax
80107bea:	75 07                	jne    80107bf3 <uva2ka+0x2f>
    return 0;
80107bec:	b8 00 00 00 00       	mov    $0x0,%eax
80107bf1:	eb 22                	jmp    80107c15 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf6:	8b 00                	mov    (%eax),%eax
80107bf8:	83 e0 04             	and    $0x4,%eax
80107bfb:	85 c0                	test   %eax,%eax
80107bfd:	75 07                	jne    80107c06 <uva2ka+0x42>
    return 0;
80107bff:	b8 00 00 00 00       	mov    $0x0,%eax
80107c04:	eb 0f                	jmp    80107c15 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c09:	8b 00                	mov    (%eax),%eax
80107c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c10:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107c15:	c9                   	leave  
80107c16:	c3                   	ret    

80107c17 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107c17:	55                   	push   %ebp
80107c18:	89 e5                	mov    %esp,%ebp
80107c1a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107c1d:	8b 45 10             	mov    0x10(%ebp),%eax
80107c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107c23:	eb 7f                	jmp    80107ca4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c33:	83 ec 08             	sub    $0x8,%esp
80107c36:	50                   	push   %eax
80107c37:	ff 75 08             	push   0x8(%ebp)
80107c3a:	e8 85 ff ff ff       	call   80107bc4 <uva2ka>
80107c3f:	83 c4 10             	add    $0x10,%esp
80107c42:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107c45:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107c49:	75 07                	jne    80107c52 <copyout+0x3b>
      return -1;
80107c4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c50:	eb 61                	jmp    80107cb3 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c55:	2b 45 0c             	sub    0xc(%ebp),%eax
80107c58:	05 00 10 00 00       	add    $0x1000,%eax
80107c5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c63:	3b 45 14             	cmp    0x14(%ebp),%eax
80107c66:	76 06                	jbe    80107c6e <copyout+0x57>
      n = len;
80107c68:	8b 45 14             	mov    0x14(%ebp),%eax
80107c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c71:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107c74:	89 c2                	mov    %eax,%edx
80107c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c79:	01 d0                	add    %edx,%eax
80107c7b:	83 ec 04             	sub    $0x4,%esp
80107c7e:	ff 75 f0             	push   -0x10(%ebp)
80107c81:	ff 75 f4             	push   -0xc(%ebp)
80107c84:	50                   	push   %eax
80107c85:	e8 c4 ce ff ff       	call   80104b4e <memmove>
80107c8a:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c90:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c96:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9c:	05 00 10 00 00       	add    $0x1000,%eax
80107ca1:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107ca4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107ca8:	0f 85 77 ff ff ff    	jne    80107c25 <copyout+0xe>
  }
  return 0;
80107cae:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cb3:	c9                   	leave  
80107cb4:	c3                   	ret    

80107cb5 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107cb5:	55                   	push   %ebp
80107cb6:	89 e5                	mov    %esp,%ebp
80107cb8:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107cbb:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107cc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107cc5:	8b 40 08             	mov    0x8(%eax),%eax
80107cc8:	05 00 00 00 80       	add    $0x80000000,%eax
80107ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107cd0:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cda:	8b 40 24             	mov    0x24(%eax),%eax
80107cdd:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107ce2:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107ce9:	00 00 00 

  while(i<madt->len){
80107cec:	90                   	nop
80107ced:	e9 bd 00 00 00       	jmp    80107daf <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107cf8:	01 d0                	add    %edx,%eax
80107cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d00:	0f b6 00             	movzbl (%eax),%eax
80107d03:	0f b6 c0             	movzbl %al,%eax
80107d06:	83 f8 05             	cmp    $0x5,%eax
80107d09:	0f 87 a0 00 00 00    	ja     80107daf <mpinit_uefi+0xfa>
80107d0f:	8b 04 85 e0 a8 10 80 	mov    -0x7fef5720(,%eax,4),%eax
80107d16:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107d1e:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d23:	83 f8 03             	cmp    $0x3,%eax
80107d26:	7f 28                	jg     80107d50 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107d28:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d31:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107d35:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107d3b:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107d41:	88 02                	mov    %al,(%edx)
          ncpu++;
80107d43:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d48:	83 c0 01             	add    $0x1,%eax
80107d4b:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107d50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d53:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d57:	0f b6 c0             	movzbl %al,%eax
80107d5a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d5d:	eb 50                	jmp    80107daf <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d68:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107d6c:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d74:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d78:	0f b6 c0             	movzbl %al,%eax
80107d7b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d7e:	eb 2f                	jmp    80107daf <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d83:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d89:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d8d:	0f b6 c0             	movzbl %al,%eax
80107d90:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d93:	eb 1a                	jmp    80107daf <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d98:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107da2:	0f b6 c0             	movzbl %al,%eax
80107da5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107da8:	eb 05                	jmp    80107daf <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107daa:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107dae:	90                   	nop
  while(i<madt->len){
80107daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db2:	8b 40 04             	mov    0x4(%eax),%eax
80107db5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107db8:	0f 82 34 ff ff ff    	jb     80107cf2 <mpinit_uefi+0x3d>
    }
  }

}
80107dbe:	90                   	nop
80107dbf:	90                   	nop
80107dc0:	c9                   	leave  
80107dc1:	c3                   	ret    

80107dc2 <inb>:
{
80107dc2:	55                   	push   %ebp
80107dc3:	89 e5                	mov    %esp,%ebp
80107dc5:	83 ec 14             	sub    $0x14,%esp
80107dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107dcb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107dcf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107dd3:	89 c2                	mov    %eax,%edx
80107dd5:	ec                   	in     (%dx),%al
80107dd6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107dd9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107ddd:	c9                   	leave  
80107dde:	c3                   	ret    

80107ddf <outb>:
{
80107ddf:	55                   	push   %ebp
80107de0:	89 e5                	mov    %esp,%ebp
80107de2:	83 ec 08             	sub    $0x8,%esp
80107de5:	8b 45 08             	mov    0x8(%ebp),%eax
80107de8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107deb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107def:	89 d0                	mov    %edx,%eax
80107df1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107df4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107df8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107dfc:	ee                   	out    %al,(%dx)
}
80107dfd:	90                   	nop
80107dfe:	c9                   	leave  
80107dff:	c3                   	ret    

80107e00 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107e00:	55                   	push   %ebp
80107e01:	89 e5                	mov    %esp,%ebp
80107e03:	83 ec 28             	sub    $0x28,%esp
80107e06:	8b 45 08             	mov    0x8(%ebp),%eax
80107e09:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107e0c:	6a 00                	push   $0x0
80107e0e:	68 fa 03 00 00       	push   $0x3fa
80107e13:	e8 c7 ff ff ff       	call   80107ddf <outb>
80107e18:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107e1b:	68 80 00 00 00       	push   $0x80
80107e20:	68 fb 03 00 00       	push   $0x3fb
80107e25:	e8 b5 ff ff ff       	call   80107ddf <outb>
80107e2a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107e2d:	6a 0c                	push   $0xc
80107e2f:	68 f8 03 00 00       	push   $0x3f8
80107e34:	e8 a6 ff ff ff       	call   80107ddf <outb>
80107e39:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107e3c:	6a 00                	push   $0x0
80107e3e:	68 f9 03 00 00       	push   $0x3f9
80107e43:	e8 97 ff ff ff       	call   80107ddf <outb>
80107e48:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107e4b:	6a 03                	push   $0x3
80107e4d:	68 fb 03 00 00       	push   $0x3fb
80107e52:	e8 88 ff ff ff       	call   80107ddf <outb>
80107e57:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107e5a:	6a 00                	push   $0x0
80107e5c:	68 fc 03 00 00       	push   $0x3fc
80107e61:	e8 79 ff ff ff       	call   80107ddf <outb>
80107e66:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107e69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e70:	eb 11                	jmp    80107e83 <uart_debug+0x83>
80107e72:	83 ec 0c             	sub    $0xc,%esp
80107e75:	6a 0a                	push   $0xa
80107e77:	e8 c9 ac ff ff       	call   80102b45 <microdelay>
80107e7c:	83 c4 10             	add    $0x10,%esp
80107e7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e83:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e87:	7f 1a                	jg     80107ea3 <uart_debug+0xa3>
80107e89:	83 ec 0c             	sub    $0xc,%esp
80107e8c:	68 fd 03 00 00       	push   $0x3fd
80107e91:	e8 2c ff ff ff       	call   80107dc2 <inb>
80107e96:	83 c4 10             	add    $0x10,%esp
80107e99:	0f b6 c0             	movzbl %al,%eax
80107e9c:	83 e0 20             	and    $0x20,%eax
80107e9f:	85 c0                	test   %eax,%eax
80107ea1:	74 cf                	je     80107e72 <uart_debug+0x72>
  outb(COM1+0, p);
80107ea3:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107ea7:	0f b6 c0             	movzbl %al,%eax
80107eaa:	83 ec 08             	sub    $0x8,%esp
80107ead:	50                   	push   %eax
80107eae:	68 f8 03 00 00       	push   $0x3f8
80107eb3:	e8 27 ff ff ff       	call   80107ddf <outb>
80107eb8:	83 c4 10             	add    $0x10,%esp
}
80107ebb:	90                   	nop
80107ebc:	c9                   	leave  
80107ebd:	c3                   	ret    

80107ebe <uart_debugs>:

void uart_debugs(char *p){
80107ebe:	55                   	push   %ebp
80107ebf:	89 e5                	mov    %esp,%ebp
80107ec1:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107ec4:	eb 1b                	jmp    80107ee1 <uart_debugs+0x23>
    uart_debug(*p++);
80107ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec9:	8d 50 01             	lea    0x1(%eax),%edx
80107ecc:	89 55 08             	mov    %edx,0x8(%ebp)
80107ecf:	0f b6 00             	movzbl (%eax),%eax
80107ed2:	0f be c0             	movsbl %al,%eax
80107ed5:	83 ec 0c             	sub    $0xc,%esp
80107ed8:	50                   	push   %eax
80107ed9:	e8 22 ff ff ff       	call   80107e00 <uart_debug>
80107ede:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ee4:	0f b6 00             	movzbl (%eax),%eax
80107ee7:	84 c0                	test   %al,%al
80107ee9:	75 db                	jne    80107ec6 <uart_debugs+0x8>
  }
}
80107eeb:	90                   	nop
80107eec:	90                   	nop
80107eed:	c9                   	leave  
80107eee:	c3                   	ret    

80107eef <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107eef:	55                   	push   %ebp
80107ef0:	89 e5                	mov    %esp,%ebp
80107ef2:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107ef5:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eff:	8b 50 14             	mov    0x14(%eax),%edx
80107f02:	8b 40 10             	mov    0x10(%eax),%eax
80107f05:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f0d:	8b 50 1c             	mov    0x1c(%eax),%edx
80107f10:	8b 40 18             	mov    0x18(%eax),%eax
80107f13:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107f18:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107f1e:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107f23:	29 d0                	sub    %edx,%eax
80107f25:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107f2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f2d:	8b 50 24             	mov    0x24(%eax),%edx
80107f30:	8b 40 20             	mov    0x20(%eax),%eax
80107f33:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107f38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f3b:	8b 50 2c             	mov    0x2c(%eax),%edx
80107f3e:	8b 40 28             	mov    0x28(%eax),%eax
80107f41:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f49:	8b 50 34             	mov    0x34(%eax),%edx
80107f4c:	8b 40 30             	mov    0x30(%eax),%eax
80107f4f:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107f54:	90                   	nop
80107f55:	c9                   	leave  
80107f56:	c3                   	ret    

80107f57 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107f57:	55                   	push   %ebp
80107f58:	89 e5                	mov    %esp,%ebp
80107f5a:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107f5d:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f66:	0f af d0             	imul   %eax,%edx
80107f69:	8b 45 08             	mov    0x8(%ebp),%eax
80107f6c:	01 d0                	add    %edx,%eax
80107f6e:	c1 e0 02             	shl    $0x2,%eax
80107f71:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f74:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f7d:	01 d0                	add    %edx,%eax
80107f7f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f82:	8b 45 10             	mov    0x10(%ebp),%eax
80107f85:	0f b6 10             	movzbl (%eax),%edx
80107f88:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f8b:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f90:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f94:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f97:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f9a:	8b 45 10             	mov    0x10(%ebp),%eax
80107f9d:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107fa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107fa4:	88 50 02             	mov    %dl,0x2(%eax)
}
80107fa7:	90                   	nop
80107fa8:	c9                   	leave  
80107fa9:	c3                   	ret    

80107faa <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107faa:	55                   	push   %ebp
80107fab:	89 e5                	mov    %esp,%ebp
80107fad:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107fb0:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb9:	0f af c2             	imul   %edx,%eax
80107fbc:	c1 e0 02             	shl    $0x2,%eax
80107fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107fc2:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fca:	29 d0                	sub    %edx,%eax
80107fcc:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fd5:	01 ca                	add    %ecx,%edx
80107fd7:	89 d1                	mov    %edx,%ecx
80107fd9:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107fdf:	83 ec 04             	sub    $0x4,%esp
80107fe2:	50                   	push   %eax
80107fe3:	51                   	push   %ecx
80107fe4:	52                   	push   %edx
80107fe5:	e8 64 cb ff ff       	call   80104b4e <memmove>
80107fea:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107ff6:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107ffc:	01 ca                	add    %ecx,%edx
80107ffe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108001:	29 ca                	sub    %ecx,%edx
80108003:	83 ec 04             	sub    $0x4,%esp
80108006:	50                   	push   %eax
80108007:	6a 00                	push   $0x0
80108009:	52                   	push   %edx
8010800a:	e8 80 ca ff ff       	call   80104a8f <memset>
8010800f:	83 c4 10             	add    $0x10,%esp
}
80108012:	90                   	nop
80108013:	c9                   	leave  
80108014:	c3                   	ret    

80108015 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108015:	55                   	push   %ebp
80108016:	89 e5                	mov    %esp,%ebp
80108018:	53                   	push   %ebx
80108019:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010801c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108023:	e9 b1 00 00 00       	jmp    801080d9 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108028:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010802f:	e9 97 00 00 00       	jmp    801080cb <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108034:	8b 45 10             	mov    0x10(%ebp),%eax
80108037:	83 e8 20             	sub    $0x20,%eax
8010803a:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010803d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108040:	01 d0                	add    %edx,%eax
80108042:	0f b7 84 00 00 a9 10 	movzwl -0x7fef5700(%eax,%eax,1),%eax
80108049:	80 
8010804a:	0f b7 d0             	movzwl %ax,%edx
8010804d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108050:	bb 01 00 00 00       	mov    $0x1,%ebx
80108055:	89 c1                	mov    %eax,%ecx
80108057:	d3 e3                	shl    %cl,%ebx
80108059:	89 d8                	mov    %ebx,%eax
8010805b:	21 d0                	and    %edx,%eax
8010805d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108060:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108063:	ba 01 00 00 00       	mov    $0x1,%edx
80108068:	89 c1                	mov    %eax,%ecx
8010806a:	d3 e2                	shl    %cl,%edx
8010806c:	89 d0                	mov    %edx,%eax
8010806e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108071:	75 2b                	jne    8010809e <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108073:	8b 55 0c             	mov    0xc(%ebp),%edx
80108076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108079:	01 c2                	add    %eax,%edx
8010807b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108080:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108083:	89 c1                	mov    %eax,%ecx
80108085:	8b 45 08             	mov    0x8(%ebp),%eax
80108088:	01 c8                	add    %ecx,%eax
8010808a:	83 ec 04             	sub    $0x4,%esp
8010808d:	68 e0 f4 10 80       	push   $0x8010f4e0
80108092:	52                   	push   %edx
80108093:	50                   	push   %eax
80108094:	e8 be fe ff ff       	call   80107f57 <graphic_draw_pixel>
80108099:	83 c4 10             	add    $0x10,%esp
8010809c:	eb 29                	jmp    801080c7 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010809e:	8b 55 0c             	mov    0xc(%ebp),%edx
801080a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a4:	01 c2                	add    %eax,%edx
801080a6:	b8 0e 00 00 00       	mov    $0xe,%eax
801080ab:	2b 45 f0             	sub    -0x10(%ebp),%eax
801080ae:	89 c1                	mov    %eax,%ecx
801080b0:	8b 45 08             	mov    0x8(%ebp),%eax
801080b3:	01 c8                	add    %ecx,%eax
801080b5:	83 ec 04             	sub    $0x4,%esp
801080b8:	68 60 6c 19 80       	push   $0x80196c60
801080bd:	52                   	push   %edx
801080be:	50                   	push   %eax
801080bf:	e8 93 fe ff ff       	call   80107f57 <graphic_draw_pixel>
801080c4:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801080c7:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801080cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080cf:	0f 89 5f ff ff ff    	jns    80108034 <font_render+0x1f>
  for(int i=0;i<30;i++){
801080d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080d9:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801080dd:	0f 8e 45 ff ff ff    	jle    80108028 <font_render+0x13>
      }
    }
  }
}
801080e3:	90                   	nop
801080e4:	90                   	nop
801080e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080e8:	c9                   	leave  
801080e9:	c3                   	ret    

801080ea <font_render_string>:

void font_render_string(char *string,int row){
801080ea:	55                   	push   %ebp
801080eb:	89 e5                	mov    %esp,%ebp
801080ed:	53                   	push   %ebx
801080ee:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801080f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801080f8:	eb 33                	jmp    8010812d <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801080fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108100:	01 d0                	add    %edx,%eax
80108102:	0f b6 00             	movzbl (%eax),%eax
80108105:	0f be c8             	movsbl %al,%ecx
80108108:	8b 45 0c             	mov    0xc(%ebp),%eax
8010810b:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010810e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108111:	89 d8                	mov    %ebx,%eax
80108113:	c1 e0 04             	shl    $0x4,%eax
80108116:	29 d8                	sub    %ebx,%eax
80108118:	83 c0 02             	add    $0x2,%eax
8010811b:	83 ec 04             	sub    $0x4,%esp
8010811e:	51                   	push   %ecx
8010811f:	52                   	push   %edx
80108120:	50                   	push   %eax
80108121:	e8 ef fe ff ff       	call   80108015 <font_render>
80108126:	83 c4 10             	add    $0x10,%esp
    i++;
80108129:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010812d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108130:	8b 45 08             	mov    0x8(%ebp),%eax
80108133:	01 d0                	add    %edx,%eax
80108135:	0f b6 00             	movzbl (%eax),%eax
80108138:	84 c0                	test   %al,%al
8010813a:	74 06                	je     80108142 <font_render_string+0x58>
8010813c:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108140:	7e b8                	jle    801080fa <font_render_string+0x10>
  }
}
80108142:	90                   	nop
80108143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108146:	c9                   	leave  
80108147:	c3                   	ret    

80108148 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108148:	55                   	push   %ebp
80108149:	89 e5                	mov    %esp,%ebp
8010814b:	53                   	push   %ebx
8010814c:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010814f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108156:	eb 6b                	jmp    801081c3 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108158:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010815f:	eb 58                	jmp    801081b9 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108161:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108168:	eb 45                	jmp    801081af <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010816a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010816d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108173:	83 ec 0c             	sub    $0xc,%esp
80108176:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108179:	53                   	push   %ebx
8010817a:	6a 00                	push   $0x0
8010817c:	51                   	push   %ecx
8010817d:	52                   	push   %edx
8010817e:	50                   	push   %eax
8010817f:	e8 b0 00 00 00       	call   80108234 <pci_access_config>
80108184:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108187:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010818a:	0f b7 c0             	movzwl %ax,%eax
8010818d:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108192:	74 17                	je     801081ab <pci_init+0x63>
        pci_init_device(i,j,k);
80108194:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108197:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010819a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819d:	83 ec 04             	sub    $0x4,%esp
801081a0:	51                   	push   %ecx
801081a1:	52                   	push   %edx
801081a2:	50                   	push   %eax
801081a3:	e8 37 01 00 00       	call   801082df <pci_init_device>
801081a8:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801081ab:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801081af:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801081b3:	7e b5                	jle    8010816a <pci_init+0x22>
    for(int j=0;j<32;j++){
801081b5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801081b9:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801081bd:	7e a2                	jle    80108161 <pci_init+0x19>
  for(int i=0;i<256;i++){
801081bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081c3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801081ca:	7e 8c                	jle    80108158 <pci_init+0x10>
      }
      }
    }
  }
}
801081cc:	90                   	nop
801081cd:	90                   	nop
801081ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081d1:	c9                   	leave  
801081d2:	c3                   	ret    

801081d3 <pci_write_config>:

void pci_write_config(uint config){
801081d3:	55                   	push   %ebp
801081d4:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801081d6:	8b 45 08             	mov    0x8(%ebp),%eax
801081d9:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801081de:	89 c0                	mov    %eax,%eax
801081e0:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081e1:	90                   	nop
801081e2:	5d                   	pop    %ebp
801081e3:	c3                   	ret    

801081e4 <pci_write_data>:

void pci_write_data(uint config){
801081e4:	55                   	push   %ebp
801081e5:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801081e7:	8b 45 08             	mov    0x8(%ebp),%eax
801081ea:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081ef:	89 c0                	mov    %eax,%eax
801081f1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081f2:	90                   	nop
801081f3:	5d                   	pop    %ebp
801081f4:	c3                   	ret    

801081f5 <pci_read_config>:
uint pci_read_config(){
801081f5:	55                   	push   %ebp
801081f6:	89 e5                	mov    %esp,%ebp
801081f8:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801081fb:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108200:	ed                   	in     (%dx),%eax
80108201:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108204:	83 ec 0c             	sub    $0xc,%esp
80108207:	68 c8 00 00 00       	push   $0xc8
8010820c:	e8 34 a9 ff ff       	call   80102b45 <microdelay>
80108211:	83 c4 10             	add    $0x10,%esp
  return data;
80108214:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108217:	c9                   	leave  
80108218:	c3                   	ret    

80108219 <pci_test>:


void pci_test(){
80108219:	55                   	push   %ebp
8010821a:	89 e5                	mov    %esp,%ebp
8010821c:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010821f:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108226:	ff 75 fc             	push   -0x4(%ebp)
80108229:	e8 a5 ff ff ff       	call   801081d3 <pci_write_config>
8010822e:	83 c4 04             	add    $0x4,%esp
}
80108231:	90                   	nop
80108232:	c9                   	leave  
80108233:	c3                   	ret    

80108234 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108234:	55                   	push   %ebp
80108235:	89 e5                	mov    %esp,%ebp
80108237:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010823a:	8b 45 08             	mov    0x8(%ebp),%eax
8010823d:	c1 e0 10             	shl    $0x10,%eax
80108240:	25 00 00 ff 00       	and    $0xff0000,%eax
80108245:	89 c2                	mov    %eax,%edx
80108247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010824a:	c1 e0 0b             	shl    $0xb,%eax
8010824d:	0f b7 c0             	movzwl %ax,%eax
80108250:	09 c2                	or     %eax,%edx
80108252:	8b 45 10             	mov    0x10(%ebp),%eax
80108255:	c1 e0 08             	shl    $0x8,%eax
80108258:	25 00 07 00 00       	and    $0x700,%eax
8010825d:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010825f:	8b 45 14             	mov    0x14(%ebp),%eax
80108262:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108267:	09 d0                	or     %edx,%eax
80108269:	0d 00 00 00 80       	or     $0x80000000,%eax
8010826e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108271:	ff 75 f4             	push   -0xc(%ebp)
80108274:	e8 5a ff ff ff       	call   801081d3 <pci_write_config>
80108279:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010827c:	e8 74 ff ff ff       	call   801081f5 <pci_read_config>
80108281:	8b 55 18             	mov    0x18(%ebp),%edx
80108284:	89 02                	mov    %eax,(%edx)
}
80108286:	90                   	nop
80108287:	c9                   	leave  
80108288:	c3                   	ret    

80108289 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108289:	55                   	push   %ebp
8010828a:	89 e5                	mov    %esp,%ebp
8010828c:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010828f:	8b 45 08             	mov    0x8(%ebp),%eax
80108292:	c1 e0 10             	shl    $0x10,%eax
80108295:	25 00 00 ff 00       	and    $0xff0000,%eax
8010829a:	89 c2                	mov    %eax,%edx
8010829c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010829f:	c1 e0 0b             	shl    $0xb,%eax
801082a2:	0f b7 c0             	movzwl %ax,%eax
801082a5:	09 c2                	or     %eax,%edx
801082a7:	8b 45 10             	mov    0x10(%ebp),%eax
801082aa:	c1 e0 08             	shl    $0x8,%eax
801082ad:	25 00 07 00 00       	and    $0x700,%eax
801082b2:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801082b4:	8b 45 14             	mov    0x14(%ebp),%eax
801082b7:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801082bc:	09 d0                	or     %edx,%eax
801082be:	0d 00 00 00 80       	or     $0x80000000,%eax
801082c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801082c6:	ff 75 fc             	push   -0x4(%ebp)
801082c9:	e8 05 ff ff ff       	call   801081d3 <pci_write_config>
801082ce:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801082d1:	ff 75 18             	push   0x18(%ebp)
801082d4:	e8 0b ff ff ff       	call   801081e4 <pci_write_data>
801082d9:	83 c4 04             	add    $0x4,%esp
}
801082dc:	90                   	nop
801082dd:	c9                   	leave  
801082de:	c3                   	ret    

801082df <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801082df:	55                   	push   %ebp
801082e0:	89 e5                	mov    %esp,%ebp
801082e2:	53                   	push   %ebx
801082e3:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801082e6:	8b 45 08             	mov    0x8(%ebp),%eax
801082e9:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
801082ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f1:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
801082f6:	8b 45 10             	mov    0x10(%ebp),%eax
801082f9:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082fe:	ff 75 10             	push   0x10(%ebp)
80108301:	ff 75 0c             	push   0xc(%ebp)
80108304:	ff 75 08             	push   0x8(%ebp)
80108307:	68 44 bf 10 80       	push   $0x8010bf44
8010830c:	e8 e3 80 ff ff       	call   801003f4 <cprintf>
80108311:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108314:	83 ec 0c             	sub    $0xc,%esp
80108317:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010831a:	50                   	push   %eax
8010831b:	6a 00                	push   $0x0
8010831d:	ff 75 10             	push   0x10(%ebp)
80108320:	ff 75 0c             	push   0xc(%ebp)
80108323:	ff 75 08             	push   0x8(%ebp)
80108326:	e8 09 ff ff ff       	call   80108234 <pci_access_config>
8010832b:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010832e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108331:	c1 e8 10             	shr    $0x10,%eax
80108334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833a:	25 ff ff 00 00       	and    $0xffff,%eax
8010833f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108345:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
8010834a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834d:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108352:	83 ec 04             	sub    $0x4,%esp
80108355:	ff 75 f0             	push   -0x10(%ebp)
80108358:	ff 75 f4             	push   -0xc(%ebp)
8010835b:	68 78 bf 10 80       	push   $0x8010bf78
80108360:	e8 8f 80 ff ff       	call   801003f4 <cprintf>
80108365:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108368:	83 ec 0c             	sub    $0xc,%esp
8010836b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010836e:	50                   	push   %eax
8010836f:	6a 08                	push   $0x8
80108371:	ff 75 10             	push   0x10(%ebp)
80108374:	ff 75 0c             	push   0xc(%ebp)
80108377:	ff 75 08             	push   0x8(%ebp)
8010837a:	e8 b5 fe ff ff       	call   80108234 <pci_access_config>
8010837f:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108382:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108385:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838b:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010838e:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108391:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108394:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108397:	0f b6 c0             	movzbl %al,%eax
8010839a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010839d:	c1 eb 18             	shr    $0x18,%ebx
801083a0:	83 ec 0c             	sub    $0xc,%esp
801083a3:	51                   	push   %ecx
801083a4:	52                   	push   %edx
801083a5:	50                   	push   %eax
801083a6:	53                   	push   %ebx
801083a7:	68 9c bf 10 80       	push   $0x8010bf9c
801083ac:	e8 43 80 ff ff       	call   801003f4 <cprintf>
801083b1:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801083b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083b7:	c1 e8 18             	shr    $0x18,%eax
801083ba:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
801083bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c2:	c1 e8 10             	shr    $0x10,%eax
801083c5:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
801083ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083cd:	c1 e8 08             	shr    $0x8,%eax
801083d0:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
801083d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d8:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801083dd:	83 ec 0c             	sub    $0xc,%esp
801083e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083e3:	50                   	push   %eax
801083e4:	6a 10                	push   $0x10
801083e6:	ff 75 10             	push   0x10(%ebp)
801083e9:	ff 75 0c             	push   0xc(%ebp)
801083ec:	ff 75 08             	push   0x8(%ebp)
801083ef:	e8 40 fe ff ff       	call   80108234 <pci_access_config>
801083f4:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801083f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083fa:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801083ff:	83 ec 0c             	sub    $0xc,%esp
80108402:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108405:	50                   	push   %eax
80108406:	6a 14                	push   $0x14
80108408:	ff 75 10             	push   0x10(%ebp)
8010840b:	ff 75 0c             	push   0xc(%ebp)
8010840e:	ff 75 08             	push   0x8(%ebp)
80108411:	e8 1e fe ff ff       	call   80108234 <pci_access_config>
80108416:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108419:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841c:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108421:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108428:	75 5a                	jne    80108484 <pci_init_device+0x1a5>
8010842a:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108431:	75 51                	jne    80108484 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108433:	83 ec 0c             	sub    $0xc,%esp
80108436:	68 e1 bf 10 80       	push   $0x8010bfe1
8010843b:	e8 b4 7f ff ff       	call   801003f4 <cprintf>
80108440:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108443:	83 ec 0c             	sub    $0xc,%esp
80108446:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108449:	50                   	push   %eax
8010844a:	68 f0 00 00 00       	push   $0xf0
8010844f:	ff 75 10             	push   0x10(%ebp)
80108452:	ff 75 0c             	push   0xc(%ebp)
80108455:	ff 75 08             	push   0x8(%ebp)
80108458:	e8 d7 fd ff ff       	call   80108234 <pci_access_config>
8010845d:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108463:	83 ec 08             	sub    $0x8,%esp
80108466:	50                   	push   %eax
80108467:	68 fb bf 10 80       	push   $0x8010bffb
8010846c:	e8 83 7f ff ff       	call   801003f4 <cprintf>
80108471:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108474:	83 ec 0c             	sub    $0xc,%esp
80108477:	68 64 6c 19 80       	push   $0x80196c64
8010847c:	e8 09 00 00 00       	call   8010848a <i8254_init>
80108481:	83 c4 10             	add    $0x10,%esp
  }
}
80108484:	90                   	nop
80108485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108488:	c9                   	leave  
80108489:	c3                   	ret    

8010848a <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010848a:	55                   	push   %ebp
8010848b:	89 e5                	mov    %esp,%ebp
8010848d:	53                   	push   %ebx
8010848e:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108491:	8b 45 08             	mov    0x8(%ebp),%eax
80108494:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108498:	0f b6 c8             	movzbl %al,%ecx
8010849b:	8b 45 08             	mov    0x8(%ebp),%eax
8010849e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084a2:	0f b6 d0             	movzbl %al,%edx
801084a5:	8b 45 08             	mov    0x8(%ebp),%eax
801084a8:	0f b6 00             	movzbl (%eax),%eax
801084ab:	0f b6 c0             	movzbl %al,%eax
801084ae:	83 ec 0c             	sub    $0xc,%esp
801084b1:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801084b4:	53                   	push   %ebx
801084b5:	6a 04                	push   $0x4
801084b7:	51                   	push   %ecx
801084b8:	52                   	push   %edx
801084b9:	50                   	push   %eax
801084ba:	e8 75 fd ff ff       	call   80108234 <pci_access_config>
801084bf:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801084c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c5:	83 c8 04             	or     $0x4,%eax
801084c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801084cb:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084ce:	8b 45 08             	mov    0x8(%ebp),%eax
801084d1:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801084d5:	0f b6 c8             	movzbl %al,%ecx
801084d8:	8b 45 08             	mov    0x8(%ebp),%eax
801084db:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084df:	0f b6 d0             	movzbl %al,%edx
801084e2:	8b 45 08             	mov    0x8(%ebp),%eax
801084e5:	0f b6 00             	movzbl (%eax),%eax
801084e8:	0f b6 c0             	movzbl %al,%eax
801084eb:	83 ec 0c             	sub    $0xc,%esp
801084ee:	53                   	push   %ebx
801084ef:	6a 04                	push   $0x4
801084f1:	51                   	push   %ecx
801084f2:	52                   	push   %edx
801084f3:	50                   	push   %eax
801084f4:	e8 90 fd ff ff       	call   80108289 <pci_write_config_register>
801084f9:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801084fc:	8b 45 08             	mov    0x8(%ebp),%eax
801084ff:	8b 40 10             	mov    0x10(%eax),%eax
80108502:	05 00 00 00 40       	add    $0x40000000,%eax
80108507:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
8010850c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108511:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108514:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108519:	05 d8 00 00 00       	add    $0xd8,%eax
8010851e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108524:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	8b 00                	mov    (%eax),%eax
8010852f:	0d 00 00 00 04       	or     $0x4000000,%eax
80108534:	89 c2                	mov    %eax,%edx
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
8010853b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108547:	8b 00                	mov    (%eax),%eax
80108549:	83 c8 40             	or     $0x40,%eax
8010854c:	89 c2                	mov    %eax,%edx
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108556:	8b 10                	mov    (%eax),%edx
80108558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010855d:	83 ec 0c             	sub    $0xc,%esp
80108560:	68 10 c0 10 80       	push   $0x8010c010
80108565:	e8 8a 7e ff ff       	call   801003f4 <cprintf>
8010856a:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010856d:	e8 3c a2 ff ff       	call   801027ae <kalloc>
80108572:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
80108577:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010857c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108582:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108587:	83 ec 08             	sub    $0x8,%esp
8010858a:	50                   	push   %eax
8010858b:	68 32 c0 10 80       	push   $0x8010c032
80108590:	e8 5f 7e ff ff       	call   801003f4 <cprintf>
80108595:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108598:	e8 50 00 00 00       	call   801085ed <i8254_init_recv>
  i8254_init_send();
8010859d:	e8 69 03 00 00       	call   8010890b <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801085a2:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801085a9:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801085ac:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801085b3:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801085b6:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801085bd:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801085c0:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801085c7:	0f b6 c0             	movzbl %al,%eax
801085ca:	83 ec 0c             	sub    $0xc,%esp
801085cd:	53                   	push   %ebx
801085ce:	51                   	push   %ecx
801085cf:	52                   	push   %edx
801085d0:	50                   	push   %eax
801085d1:	68 40 c0 10 80       	push   $0x8010c040
801085d6:	e8 19 7e ff ff       	call   801003f4 <cprintf>
801085db:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801085de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801085e7:	90                   	nop
801085e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085eb:	c9                   	leave  
801085ec:	c3                   	ret    

801085ed <i8254_init_recv>:

void i8254_init_recv(){
801085ed:	55                   	push   %ebp
801085ee:	89 e5                	mov    %esp,%ebp
801085f0:	57                   	push   %edi
801085f1:	56                   	push   %esi
801085f2:	53                   	push   %ebx
801085f3:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801085f6:	83 ec 0c             	sub    $0xc,%esp
801085f9:	6a 00                	push   $0x0
801085fb:	e8 e8 04 00 00       	call   80108ae8 <i8254_read_eeprom>
80108600:	83 c4 10             	add    $0x10,%esp
80108603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108606:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108609:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
8010860e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108611:	c1 e8 08             	shr    $0x8,%eax
80108614:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
80108619:	83 ec 0c             	sub    $0xc,%esp
8010861c:	6a 01                	push   $0x1
8010861e:	e8 c5 04 00 00       	call   80108ae8 <i8254_read_eeprom>
80108623:	83 c4 10             	add    $0x10,%esp
80108626:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108629:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010862c:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
80108631:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108634:	c1 e8 08             	shr    $0x8,%eax
80108637:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
8010863c:	83 ec 0c             	sub    $0xc,%esp
8010863f:	6a 02                	push   $0x2
80108641:	e8 a2 04 00 00       	call   80108ae8 <i8254_read_eeprom>
80108646:	83 c4 10             	add    $0x10,%esp
80108649:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010864c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010864f:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
80108654:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108657:	c1 e8 08             	shr    $0x8,%eax
8010865a:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010865f:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108666:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108669:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108670:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108673:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010867a:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010867d:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108684:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108687:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010868e:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108691:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108698:	0f b6 c0             	movzbl %al,%eax
8010869b:	83 ec 04             	sub    $0x4,%esp
8010869e:	57                   	push   %edi
8010869f:	56                   	push   %esi
801086a0:	53                   	push   %ebx
801086a1:	51                   	push   %ecx
801086a2:	52                   	push   %edx
801086a3:	50                   	push   %eax
801086a4:	68 58 c0 10 80       	push   $0x8010c058
801086a9:	e8 46 7d ff ff       	call   801003f4 <cprintf>
801086ae:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801086b1:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086b6:	05 00 54 00 00       	add    $0x5400,%eax
801086bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801086be:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086c3:	05 04 54 00 00       	add    $0x5404,%eax
801086c8:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801086cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801086ce:	c1 e0 10             	shl    $0x10,%eax
801086d1:	0b 45 d8             	or     -0x28(%ebp),%eax
801086d4:	89 c2                	mov    %eax,%edx
801086d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801086d9:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801086db:	8b 45 d0             	mov    -0x30(%ebp),%eax
801086de:	0d 00 00 00 80       	or     $0x80000000,%eax
801086e3:	89 c2                	mov    %eax,%edx
801086e5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801086e8:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801086ea:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086ef:	05 00 52 00 00       	add    $0x5200,%eax
801086f4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801086f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801086fe:	eb 19                	jmp    80108719 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108700:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108703:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010870a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010870d:	01 d0                	add    %edx,%eax
8010870f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108715:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108719:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010871d:	7e e1                	jle    80108700 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010871f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108724:	05 d0 00 00 00       	add    $0xd0,%eax
80108729:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010872c:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010872f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108735:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010873a:	05 c8 00 00 00       	add    $0xc8,%eax
8010873f:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108742:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108745:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010874b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108750:	05 28 28 00 00       	add    $0x2828,%eax
80108755:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108758:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010875b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108761:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108766:	05 00 01 00 00       	add    $0x100,%eax
8010876b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010876e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108771:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108777:	e8 32 a0 ff ff       	call   801027ae <kalloc>
8010877c:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010877f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108784:	05 00 28 00 00       	add    $0x2800,%eax
80108789:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010878c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108791:	05 04 28 00 00       	add    $0x2804,%eax
80108796:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108799:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010879e:	05 08 28 00 00       	add    $0x2808,%eax
801087a3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801087a6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087ab:	05 10 28 00 00       	add    $0x2810,%eax
801087b0:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801087b3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087b8:	05 18 28 00 00       	add    $0x2818,%eax
801087bd:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801087c0:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801087c9:	8b 45 ac             	mov    -0x54(%ebp),%eax
801087cc:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801087ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
801087d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801087d7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801087da:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801087e0:	8b 45 a0             	mov    -0x60(%ebp),%eax
801087e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801087e9:	8b 45 9c             	mov    -0x64(%ebp),%eax
801087ec:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801087f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087f5:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087f8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801087ff:	eb 73                	jmp    80108874 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108801:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108804:	c1 e0 04             	shl    $0x4,%eax
80108807:	89 c2                	mov    %eax,%edx
80108809:	8b 45 98             	mov    -0x68(%ebp),%eax
8010880c:	01 d0                	add    %edx,%eax
8010880e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108815:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108818:	c1 e0 04             	shl    $0x4,%eax
8010881b:	89 c2                	mov    %eax,%edx
8010881d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108820:	01 d0                	add    %edx,%eax
80108822:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010882b:	c1 e0 04             	shl    $0x4,%eax
8010882e:	89 c2                	mov    %eax,%edx
80108830:	8b 45 98             	mov    -0x68(%ebp),%eax
80108833:	01 d0                	add    %edx,%eax
80108835:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010883b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010883e:	c1 e0 04             	shl    $0x4,%eax
80108841:	89 c2                	mov    %eax,%edx
80108843:	8b 45 98             	mov    -0x68(%ebp),%eax
80108846:	01 d0                	add    %edx,%eax
80108848:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010884c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010884f:	c1 e0 04             	shl    $0x4,%eax
80108852:	89 c2                	mov    %eax,%edx
80108854:	8b 45 98             	mov    -0x68(%ebp),%eax
80108857:	01 d0                	add    %edx,%eax
80108859:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010885d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108860:	c1 e0 04             	shl    $0x4,%eax
80108863:	89 c2                	mov    %eax,%edx
80108865:	8b 45 98             	mov    -0x68(%ebp),%eax
80108868:	01 d0                	add    %edx,%eax
8010886a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108870:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108874:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010887b:	7e 84                	jle    80108801 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010887d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108884:	eb 57                	jmp    801088dd <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108886:	e8 23 9f ff ff       	call   801027ae <kalloc>
8010888b:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010888e:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108892:	75 12                	jne    801088a6 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108894:	83 ec 0c             	sub    $0xc,%esp
80108897:	68 78 c0 10 80       	push   $0x8010c078
8010889c:	e8 53 7b ff ff       	call   801003f4 <cprintf>
801088a1:	83 c4 10             	add    $0x10,%esp
      break;
801088a4:	eb 3d                	jmp    801088e3 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801088a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801088a9:	c1 e0 04             	shl    $0x4,%eax
801088ac:	89 c2                	mov    %eax,%edx
801088ae:	8b 45 98             	mov    -0x68(%ebp),%eax
801088b1:	01 d0                	add    %edx,%eax
801088b3:	8b 55 94             	mov    -0x6c(%ebp),%edx
801088b6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801088bc:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801088be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801088c1:	83 c0 01             	add    $0x1,%eax
801088c4:	c1 e0 04             	shl    $0x4,%eax
801088c7:	89 c2                	mov    %eax,%edx
801088c9:	8b 45 98             	mov    -0x68(%ebp),%eax
801088cc:	01 d0                	add    %edx,%eax
801088ce:	8b 55 94             	mov    -0x6c(%ebp),%edx
801088d1:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801088d7:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801088d9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801088dd:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801088e1:	7e a3                	jle    80108886 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801088e3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088e6:	8b 00                	mov    (%eax),%eax
801088e8:	83 c8 02             	or     $0x2,%eax
801088eb:	89 c2                	mov    %eax,%edx
801088ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088f0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801088f2:	83 ec 0c             	sub    $0xc,%esp
801088f5:	68 98 c0 10 80       	push   $0x8010c098
801088fa:	e8 f5 7a ff ff       	call   801003f4 <cprintf>
801088ff:	83 c4 10             	add    $0x10,%esp
}
80108902:	90                   	nop
80108903:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108906:	5b                   	pop    %ebx
80108907:	5e                   	pop    %esi
80108908:	5f                   	pop    %edi
80108909:	5d                   	pop    %ebp
8010890a:	c3                   	ret    

8010890b <i8254_init_send>:

void i8254_init_send(){
8010890b:	55                   	push   %ebp
8010890c:	89 e5                	mov    %esp,%ebp
8010890e:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108911:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108916:	05 28 38 00 00       	add    $0x3828,%eax
8010891b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010891e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108921:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108927:	e8 82 9e ff ff       	call   801027ae <kalloc>
8010892c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010892f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108934:	05 00 38 00 00       	add    $0x3800,%eax
80108939:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010893c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108941:	05 04 38 00 00       	add    $0x3804,%eax
80108946:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108949:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010894e:	05 08 38 00 00       	add    $0x3808,%eax
80108953:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108956:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108959:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010895f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108962:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108964:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108967:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010896d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108970:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108976:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010897b:	05 10 38 00 00       	add    $0x3810,%eax
80108980:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108983:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108988:	05 18 38 00 00       	add    $0x3818,%eax
8010898d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108990:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108993:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108999:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010899c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801089a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801089a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089af:	e9 82 00 00 00       	jmp    80108a36 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801089b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b7:	c1 e0 04             	shl    $0x4,%eax
801089ba:	89 c2                	mov    %eax,%edx
801089bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089bf:	01 d0                	add    %edx,%eax
801089c1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801089c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cb:	c1 e0 04             	shl    $0x4,%eax
801089ce:	89 c2                	mov    %eax,%edx
801089d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089d3:	01 d0                	add    %edx,%eax
801089d5:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801089db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089de:	c1 e0 04             	shl    $0x4,%eax
801089e1:	89 c2                	mov    %eax,%edx
801089e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089e6:	01 d0                	add    %edx,%eax
801089e8:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	c1 e0 04             	shl    $0x4,%eax
801089f2:	89 c2                	mov    %eax,%edx
801089f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089f7:	01 d0                	add    %edx,%eax
801089f9:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801089fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a00:	c1 e0 04             	shl    $0x4,%eax
80108a03:	89 c2                	mov    %eax,%edx
80108a05:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a08:	01 d0                	add    %edx,%eax
80108a0a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a11:	c1 e0 04             	shl    $0x4,%eax
80108a14:	89 c2                	mov    %eax,%edx
80108a16:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a19:	01 d0                	add    %edx,%eax
80108a1b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a22:	c1 e0 04             	shl    $0x4,%eax
80108a25:	89 c2                	mov    %eax,%edx
80108a27:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a2a:	01 d0                	add    %edx,%eax
80108a2c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a36:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108a3d:	0f 8e 71 ff ff ff    	jle    801089b4 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a4a:	eb 57                	jmp    80108aa3 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108a4c:	e8 5d 9d ff ff       	call   801027ae <kalloc>
80108a51:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a54:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a58:	75 12                	jne    80108a6c <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a5a:	83 ec 0c             	sub    $0xc,%esp
80108a5d:	68 78 c0 10 80       	push   $0x8010c078
80108a62:	e8 8d 79 ff ff       	call   801003f4 <cprintf>
80108a67:	83 c4 10             	add    $0x10,%esp
      break;
80108a6a:	eb 3d                	jmp    80108aa9 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a6f:	c1 e0 04             	shl    $0x4,%eax
80108a72:	89 c2                	mov    %eax,%edx
80108a74:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a77:	01 d0                	add    %edx,%eax
80108a79:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a7c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a82:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a87:	83 c0 01             	add    $0x1,%eax
80108a8a:	c1 e0 04             	shl    $0x4,%eax
80108a8d:	89 c2                	mov    %eax,%edx
80108a8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a92:	01 d0                	add    %edx,%eax
80108a94:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a97:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a9d:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a9f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108aa3:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108aa7:	7e a3                	jle    80108a4c <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108aa9:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108aae:	05 00 04 00 00       	add    $0x400,%eax
80108ab3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108ab6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ab9:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108abf:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ac4:	05 10 04 00 00       	add    $0x410,%eax
80108ac9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108acc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108acf:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108ad5:	83 ec 0c             	sub    $0xc,%esp
80108ad8:	68 b8 c0 10 80       	push   $0x8010c0b8
80108add:	e8 12 79 ff ff       	call   801003f4 <cprintf>
80108ae2:	83 c4 10             	add    $0x10,%esp

}
80108ae5:	90                   	nop
80108ae6:	c9                   	leave  
80108ae7:	c3                   	ret    

80108ae8 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108ae8:	55                   	push   %ebp
80108ae9:	89 e5                	mov    %esp,%ebp
80108aeb:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108aee:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108af3:	83 c0 14             	add    $0x14,%eax
80108af6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108af9:	8b 45 08             	mov    0x8(%ebp),%eax
80108afc:	c1 e0 08             	shl    $0x8,%eax
80108aff:	0f b7 c0             	movzwl %ax,%eax
80108b02:	83 c8 01             	or     $0x1,%eax
80108b05:	89 c2                	mov    %eax,%edx
80108b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0a:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108b0c:	83 ec 0c             	sub    $0xc,%esp
80108b0f:	68 d8 c0 10 80       	push   $0x8010c0d8
80108b14:	e8 db 78 ff ff       	call   801003f4 <cprintf>
80108b19:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1f:	8b 00                	mov    (%eax),%eax
80108b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b27:	83 e0 10             	and    $0x10,%eax
80108b2a:	85 c0                	test   %eax,%eax
80108b2c:	75 02                	jne    80108b30 <i8254_read_eeprom+0x48>
  while(1){
80108b2e:	eb dc                	jmp    80108b0c <i8254_read_eeprom+0x24>
      break;
80108b30:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b34:	8b 00                	mov    (%eax),%eax
80108b36:	c1 e8 10             	shr    $0x10,%eax
}
80108b39:	c9                   	leave  
80108b3a:	c3                   	ret    

80108b3b <i8254_recv>:
void i8254_recv(){
80108b3b:	55                   	push   %ebp
80108b3c:	89 e5                	mov    %esp,%ebp
80108b3e:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b41:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b46:	05 10 28 00 00       	add    $0x2810,%eax
80108b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b4e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b53:	05 18 28 00 00       	add    $0x2818,%eax
80108b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b5b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b60:	05 00 28 00 00       	add    $0x2800,%eax
80108b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b6b:	8b 00                	mov    (%eax),%eax
80108b6d:	05 00 00 00 80       	add    $0x80000000,%eax
80108b72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b78:	8b 10                	mov    (%eax),%edx
80108b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7d:	8b 08                	mov    (%eax),%ecx
80108b7f:	89 d0                	mov    %edx,%eax
80108b81:	29 c8                	sub    %ecx,%eax
80108b83:	25 ff 00 00 00       	and    $0xff,%eax
80108b88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b8b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b8f:	7e 37                	jle    80108bc8 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b94:	8b 00                	mov    (%eax),%eax
80108b96:	c1 e0 04             	shl    $0x4,%eax
80108b99:	89 c2                	mov    %eax,%edx
80108b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b9e:	01 d0                	add    %edx,%eax
80108ba0:	8b 00                	mov    (%eax),%eax
80108ba2:	05 00 00 00 80       	add    $0x80000000,%eax
80108ba7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bad:	8b 00                	mov    (%eax),%eax
80108baf:	83 c0 01             	add    $0x1,%eax
80108bb2:	0f b6 d0             	movzbl %al,%edx
80108bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb8:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108bba:	83 ec 0c             	sub    $0xc,%esp
80108bbd:	ff 75 e0             	push   -0x20(%ebp)
80108bc0:	e8 15 09 00 00       	call   801094da <eth_proc>
80108bc5:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bcb:	8b 10                	mov    (%eax),%edx
80108bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd0:	8b 00                	mov    (%eax),%eax
80108bd2:	39 c2                	cmp    %eax,%edx
80108bd4:	75 9f                	jne    80108b75 <i8254_recv+0x3a>
      (*rdt)--;
80108bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd9:	8b 00                	mov    (%eax),%eax
80108bdb:	8d 50 ff             	lea    -0x1(%eax),%edx
80108bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be1:	89 10                	mov    %edx,(%eax)
  while(1){
80108be3:	eb 90                	jmp    80108b75 <i8254_recv+0x3a>

80108be5 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108be5:	55                   	push   %ebp
80108be6:	89 e5                	mov    %esp,%ebp
80108be8:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108beb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bf0:	05 10 38 00 00       	add    $0x3810,%eax
80108bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bf8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bfd:	05 18 38 00 00       	add    $0x3818,%eax
80108c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108c05:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c0a:	05 00 38 00 00       	add    $0x3800,%eax
80108c0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c15:	8b 00                	mov    (%eax),%eax
80108c17:	05 00 00 00 80       	add    $0x80000000,%eax
80108c1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c22:	8b 10                	mov    (%eax),%edx
80108c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c27:	8b 08                	mov    (%eax),%ecx
80108c29:	89 d0                	mov    %edx,%eax
80108c2b:	29 c8                	sub    %ecx,%eax
80108c2d:	0f b6 d0             	movzbl %al,%edx
80108c30:	b8 00 01 00 00       	mov    $0x100,%eax
80108c35:	29 d0                	sub    %edx,%eax
80108c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c3d:	8b 00                	mov    (%eax),%eax
80108c3f:	25 ff 00 00 00       	and    $0xff,%eax
80108c44:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108c47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c4b:	0f 8e a8 00 00 00    	jle    80108cf9 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108c51:	8b 45 08             	mov    0x8(%ebp),%eax
80108c54:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108c57:	89 d1                	mov    %edx,%ecx
80108c59:	c1 e1 04             	shl    $0x4,%ecx
80108c5c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108c5f:	01 ca                	add    %ecx,%edx
80108c61:	8b 12                	mov    (%edx),%edx
80108c63:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c69:	83 ec 04             	sub    $0x4,%esp
80108c6c:	ff 75 0c             	push   0xc(%ebp)
80108c6f:	50                   	push   %eax
80108c70:	52                   	push   %edx
80108c71:	e8 d8 be ff ff       	call   80104b4e <memmove>
80108c76:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108c79:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c7c:	c1 e0 04             	shl    $0x4,%eax
80108c7f:	89 c2                	mov    %eax,%edx
80108c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c84:	01 d0                	add    %edx,%eax
80108c86:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c89:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c90:	c1 e0 04             	shl    $0x4,%eax
80108c93:	89 c2                	mov    %eax,%edx
80108c95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c98:	01 d0                	add    %edx,%eax
80108c9a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ca1:	c1 e0 04             	shl    $0x4,%eax
80108ca4:	89 c2                	mov    %eax,%edx
80108ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ca9:	01 d0                	add    %edx,%eax
80108cab:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108caf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cb2:	c1 e0 04             	shl    $0x4,%eax
80108cb5:	89 c2                	mov    %eax,%edx
80108cb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cba:	01 d0                	add    %edx,%eax
80108cbc:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cc3:	c1 e0 04             	shl    $0x4,%eax
80108cc6:	89 c2                	mov    %eax,%edx
80108cc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ccb:	01 d0                	add    %edx,%eax
80108ccd:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cd6:	c1 e0 04             	shl    $0x4,%eax
80108cd9:	89 c2                	mov    %eax,%edx
80108cdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cde:	01 d0                	add    %edx,%eax
80108ce0:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce7:	8b 00                	mov    (%eax),%eax
80108ce9:	83 c0 01             	add    $0x1,%eax
80108cec:	0f b6 d0             	movzbl %al,%edx
80108cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf2:	89 10                	mov    %edx,(%eax)
    return len;
80108cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cf7:	eb 05                	jmp    80108cfe <i8254_send+0x119>
  }else{
    return -1;
80108cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108cfe:	c9                   	leave  
80108cff:	c3                   	ret    

80108d00 <i8254_intr>:

void i8254_intr(){
80108d00:	55                   	push   %ebp
80108d01:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108d03:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108d08:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108d0e:	90                   	nop
80108d0f:	5d                   	pop    %ebp
80108d10:	c3                   	ret    

80108d11 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108d11:	55                   	push   %ebp
80108d12:	89 e5                	mov    %esp,%ebp
80108d14:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108d17:	8b 45 08             	mov    0x8(%ebp),%eax
80108d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d20:	0f b7 00             	movzwl (%eax),%eax
80108d23:	66 3d 00 01          	cmp    $0x100,%ax
80108d27:	74 0a                	je     80108d33 <arp_proc+0x22>
80108d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d2e:	e9 4f 01 00 00       	jmp    80108e82 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d36:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108d3a:	66 83 f8 08          	cmp    $0x8,%ax
80108d3e:	74 0a                	je     80108d4a <arp_proc+0x39>
80108d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d45:	e9 38 01 00 00       	jmp    80108e82 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108d51:	3c 06                	cmp    $0x6,%al
80108d53:	74 0a                	je     80108d5f <arp_proc+0x4e>
80108d55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d5a:	e9 23 01 00 00       	jmp    80108e82 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d62:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108d66:	3c 04                	cmp    $0x4,%al
80108d68:	74 0a                	je     80108d74 <arp_proc+0x63>
80108d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d6f:	e9 0e 01 00 00       	jmp    80108e82 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d77:	83 c0 18             	add    $0x18,%eax
80108d7a:	83 ec 04             	sub    $0x4,%esp
80108d7d:	6a 04                	push   $0x4
80108d7f:	50                   	push   %eax
80108d80:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d85:	e8 6c bd ff ff       	call   80104af6 <memcmp>
80108d8a:	83 c4 10             	add    $0x10,%esp
80108d8d:	85 c0                	test   %eax,%eax
80108d8f:	74 27                	je     80108db8 <arp_proc+0xa7>
80108d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d94:	83 c0 0e             	add    $0xe,%eax
80108d97:	83 ec 04             	sub    $0x4,%esp
80108d9a:	6a 04                	push   $0x4
80108d9c:	50                   	push   %eax
80108d9d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108da2:	e8 4f bd ff ff       	call   80104af6 <memcmp>
80108da7:	83 c4 10             	add    $0x10,%esp
80108daa:	85 c0                	test   %eax,%eax
80108dac:	74 0a                	je     80108db8 <arp_proc+0xa7>
80108dae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108db3:	e9 ca 00 00 00       	jmp    80108e82 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108dbf:	66 3d 00 01          	cmp    $0x100,%ax
80108dc3:	75 69                	jne    80108e2e <arp_proc+0x11d>
80108dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc8:	83 c0 18             	add    $0x18,%eax
80108dcb:	83 ec 04             	sub    $0x4,%esp
80108dce:	6a 04                	push   $0x4
80108dd0:	50                   	push   %eax
80108dd1:	68 e4 f4 10 80       	push   $0x8010f4e4
80108dd6:	e8 1b bd ff ff       	call   80104af6 <memcmp>
80108ddb:	83 c4 10             	add    $0x10,%esp
80108dde:	85 c0                	test   %eax,%eax
80108de0:	75 4c                	jne    80108e2e <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108de2:	e8 c7 99 ff ff       	call   801027ae <kalloc>
80108de7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108dea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108df1:	83 ec 04             	sub    $0x4,%esp
80108df4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108df7:	50                   	push   %eax
80108df8:	ff 75 f0             	push   -0x10(%ebp)
80108dfb:	ff 75 f4             	push   -0xc(%ebp)
80108dfe:	e8 1f 04 00 00       	call   80109222 <arp_reply_pkt_create>
80108e03:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108e06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e09:	83 ec 08             	sub    $0x8,%esp
80108e0c:	50                   	push   %eax
80108e0d:	ff 75 f0             	push   -0x10(%ebp)
80108e10:	e8 d0 fd ff ff       	call   80108be5 <i8254_send>
80108e15:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1b:	83 ec 0c             	sub    $0xc,%esp
80108e1e:	50                   	push   %eax
80108e1f:	e8 f0 98 ff ff       	call   80102714 <kfree>
80108e24:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108e27:	b8 02 00 00 00       	mov    $0x2,%eax
80108e2c:	eb 54                	jmp    80108e82 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e31:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108e35:	66 3d 00 02          	cmp    $0x200,%ax
80108e39:	75 42                	jne    80108e7d <arp_proc+0x16c>
80108e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3e:	83 c0 18             	add    $0x18,%eax
80108e41:	83 ec 04             	sub    $0x4,%esp
80108e44:	6a 04                	push   $0x4
80108e46:	50                   	push   %eax
80108e47:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e4c:	e8 a5 bc ff ff       	call   80104af6 <memcmp>
80108e51:	83 c4 10             	add    $0x10,%esp
80108e54:	85 c0                	test   %eax,%eax
80108e56:	75 25                	jne    80108e7d <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e58:	83 ec 0c             	sub    $0xc,%esp
80108e5b:	68 dc c0 10 80       	push   $0x8010c0dc
80108e60:	e8 8f 75 ff ff       	call   801003f4 <cprintf>
80108e65:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108e68:	83 ec 0c             	sub    $0xc,%esp
80108e6b:	ff 75 f4             	push   -0xc(%ebp)
80108e6e:	e8 af 01 00 00       	call   80109022 <arp_table_update>
80108e73:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108e76:	b8 01 00 00 00       	mov    $0x1,%eax
80108e7b:	eb 05                	jmp    80108e82 <arp_proc+0x171>
  }else{
    return -1;
80108e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e82:	c9                   	leave  
80108e83:	c3                   	ret    

80108e84 <arp_scan>:

void arp_scan(){
80108e84:	55                   	push   %ebp
80108e85:	89 e5                	mov    %esp,%ebp
80108e87:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e91:	eb 6f                	jmp    80108f02 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e93:	e8 16 99 ff ff       	call   801027ae <kalloc>
80108e98:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e9b:	83 ec 04             	sub    $0x4,%esp
80108e9e:	ff 75 f4             	push   -0xc(%ebp)
80108ea1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108ea4:	50                   	push   %eax
80108ea5:	ff 75 ec             	push   -0x14(%ebp)
80108ea8:	e8 62 00 00 00       	call   80108f0f <arp_broadcast>
80108ead:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108eb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eb3:	83 ec 08             	sub    $0x8,%esp
80108eb6:	50                   	push   %eax
80108eb7:	ff 75 ec             	push   -0x14(%ebp)
80108eba:	e8 26 fd ff ff       	call   80108be5 <i8254_send>
80108ebf:	83 c4 10             	add    $0x10,%esp
80108ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ec5:	eb 22                	jmp    80108ee9 <arp_scan+0x65>
      microdelay(1);
80108ec7:	83 ec 0c             	sub    $0xc,%esp
80108eca:	6a 01                	push   $0x1
80108ecc:	e8 74 9c ff ff       	call   80102b45 <microdelay>
80108ed1:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ed7:	83 ec 08             	sub    $0x8,%esp
80108eda:	50                   	push   %eax
80108edb:	ff 75 ec             	push   -0x14(%ebp)
80108ede:	e8 02 fd ff ff       	call   80108be5 <i8254_send>
80108ee3:	83 c4 10             	add    $0x10,%esp
80108ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ee9:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108eed:	74 d8                	je     80108ec7 <arp_scan+0x43>
    }
    kfree((char *)send);
80108eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ef2:	83 ec 0c             	sub    $0xc,%esp
80108ef5:	50                   	push   %eax
80108ef6:	e8 19 98 ff ff       	call   80102714 <kfree>
80108efb:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108efe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f02:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f09:	7e 88                	jle    80108e93 <arp_scan+0xf>
  }
}
80108f0b:	90                   	nop
80108f0c:	90                   	nop
80108f0d:	c9                   	leave  
80108f0e:	c3                   	ret    

80108f0f <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108f0f:	55                   	push   %ebp
80108f10:	89 e5                	mov    %esp,%ebp
80108f12:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108f15:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108f19:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108f1d:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108f21:	8b 45 10             	mov    0x10(%ebp),%eax
80108f24:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108f27:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108f2e:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108f34:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108f3b:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108f41:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f44:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108f50:	8b 45 08             	mov    0x8(%ebp),%eax
80108f53:	83 c0 0e             	add    $0xe,%eax
80108f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f63:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6a:	83 ec 04             	sub    $0x4,%esp
80108f6d:	6a 06                	push   $0x6
80108f6f:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108f72:	52                   	push   %edx
80108f73:	50                   	push   %eax
80108f74:	e8 d5 bb ff ff       	call   80104b4e <memmove>
80108f79:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7f:	83 c0 06             	add    $0x6,%eax
80108f82:	83 ec 04             	sub    $0x4,%esp
80108f85:	6a 06                	push   $0x6
80108f87:	68 80 6c 19 80       	push   $0x80196c80
80108f8c:	50                   	push   %eax
80108f8d:	e8 bc bb ff ff       	call   80104b4e <memmove>
80108f92:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f98:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa0:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa9:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb0:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb7:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc0:	8d 50 12             	lea    0x12(%eax),%edx
80108fc3:	83 ec 04             	sub    $0x4,%esp
80108fc6:	6a 06                	push   $0x6
80108fc8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108fcb:	50                   	push   %eax
80108fcc:	52                   	push   %edx
80108fcd:	e8 7c bb ff ff       	call   80104b4e <memmove>
80108fd2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd8:	8d 50 18             	lea    0x18(%eax),%edx
80108fdb:	83 ec 04             	sub    $0x4,%esp
80108fde:	6a 04                	push   $0x4
80108fe0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fe3:	50                   	push   %eax
80108fe4:	52                   	push   %edx
80108fe5:	e8 64 bb ff ff       	call   80104b4e <memmove>
80108fea:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff0:	83 c0 08             	add    $0x8,%eax
80108ff3:	83 ec 04             	sub    $0x4,%esp
80108ff6:	6a 06                	push   $0x6
80108ff8:	68 80 6c 19 80       	push   $0x80196c80
80108ffd:	50                   	push   %eax
80108ffe:	e8 4b bb ff ff       	call   80104b4e <memmove>
80109003:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109009:	83 c0 0e             	add    $0xe,%eax
8010900c:	83 ec 04             	sub    $0x4,%esp
8010900f:	6a 04                	push   $0x4
80109011:	68 e4 f4 10 80       	push   $0x8010f4e4
80109016:	50                   	push   %eax
80109017:	e8 32 bb ff ff       	call   80104b4e <memmove>
8010901c:	83 c4 10             	add    $0x10,%esp
}
8010901f:	90                   	nop
80109020:	c9                   	leave  
80109021:	c3                   	ret    

80109022 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109022:	55                   	push   %ebp
80109023:	89 e5                	mov    %esp,%ebp
80109025:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109028:	8b 45 08             	mov    0x8(%ebp),%eax
8010902b:	83 c0 0e             	add    $0xe,%eax
8010902e:	83 ec 0c             	sub    $0xc,%esp
80109031:	50                   	push   %eax
80109032:	e8 bc 00 00 00       	call   801090f3 <arp_table_search>
80109037:	83 c4 10             	add    $0x10,%esp
8010903a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010903d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109041:	78 2d                	js     80109070 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109043:	8b 45 08             	mov    0x8(%ebp),%eax
80109046:	8d 48 08             	lea    0x8(%eax),%ecx
80109049:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010904c:	89 d0                	mov    %edx,%eax
8010904e:	c1 e0 02             	shl    $0x2,%eax
80109051:	01 d0                	add    %edx,%eax
80109053:	01 c0                	add    %eax,%eax
80109055:	01 d0                	add    %edx,%eax
80109057:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010905c:	83 c0 04             	add    $0x4,%eax
8010905f:	83 ec 04             	sub    $0x4,%esp
80109062:	6a 06                	push   $0x6
80109064:	51                   	push   %ecx
80109065:	50                   	push   %eax
80109066:	e8 e3 ba ff ff       	call   80104b4e <memmove>
8010906b:	83 c4 10             	add    $0x10,%esp
8010906e:	eb 70                	jmp    801090e0 <arp_table_update+0xbe>
  }else{
    index += 1;
80109070:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109074:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109077:	8b 45 08             	mov    0x8(%ebp),%eax
8010907a:	8d 48 08             	lea    0x8(%eax),%ecx
8010907d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109080:	89 d0                	mov    %edx,%eax
80109082:	c1 e0 02             	shl    $0x2,%eax
80109085:	01 d0                	add    %edx,%eax
80109087:	01 c0                	add    %eax,%eax
80109089:	01 d0                	add    %edx,%eax
8010908b:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109090:	83 c0 04             	add    $0x4,%eax
80109093:	83 ec 04             	sub    $0x4,%esp
80109096:	6a 06                	push   $0x6
80109098:	51                   	push   %ecx
80109099:	50                   	push   %eax
8010909a:	e8 af ba ff ff       	call   80104b4e <memmove>
8010909f:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801090a2:	8b 45 08             	mov    0x8(%ebp),%eax
801090a5:	8d 48 0e             	lea    0xe(%eax),%ecx
801090a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090ab:	89 d0                	mov    %edx,%eax
801090ad:	c1 e0 02             	shl    $0x2,%eax
801090b0:	01 d0                	add    %edx,%eax
801090b2:	01 c0                	add    %eax,%eax
801090b4:	01 d0                	add    %edx,%eax
801090b6:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090bb:	83 ec 04             	sub    $0x4,%esp
801090be:	6a 04                	push   $0x4
801090c0:	51                   	push   %ecx
801090c1:	50                   	push   %eax
801090c2:	e8 87 ba ff ff       	call   80104b4e <memmove>
801090c7:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801090ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090cd:	89 d0                	mov    %edx,%eax
801090cf:	c1 e0 02             	shl    $0x2,%eax
801090d2:	01 d0                	add    %edx,%eax
801090d4:	01 c0                	add    %eax,%eax
801090d6:	01 d0                	add    %edx,%eax
801090d8:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801090dd:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801090e0:	83 ec 0c             	sub    $0xc,%esp
801090e3:	68 a0 6c 19 80       	push   $0x80196ca0
801090e8:	e8 83 00 00 00       	call   80109170 <print_arp_table>
801090ed:	83 c4 10             	add    $0x10,%esp
}
801090f0:	90                   	nop
801090f1:	c9                   	leave  
801090f2:	c3                   	ret    

801090f3 <arp_table_search>:

int arp_table_search(uchar *ip){
801090f3:	55                   	push   %ebp
801090f4:	89 e5                	mov    %esp,%ebp
801090f6:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801090f9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109100:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109107:	eb 59                	jmp    80109162 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109109:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010910c:	89 d0                	mov    %edx,%eax
8010910e:	c1 e0 02             	shl    $0x2,%eax
80109111:	01 d0                	add    %edx,%eax
80109113:	01 c0                	add    %eax,%eax
80109115:	01 d0                	add    %edx,%eax
80109117:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010911c:	83 ec 04             	sub    $0x4,%esp
8010911f:	6a 04                	push   $0x4
80109121:	ff 75 08             	push   0x8(%ebp)
80109124:	50                   	push   %eax
80109125:	e8 cc b9 ff ff       	call   80104af6 <memcmp>
8010912a:	83 c4 10             	add    $0x10,%esp
8010912d:	85 c0                	test   %eax,%eax
8010912f:	75 05                	jne    80109136 <arp_table_search+0x43>
      return i;
80109131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109134:	eb 38                	jmp    8010916e <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109136:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109139:	89 d0                	mov    %edx,%eax
8010913b:	c1 e0 02             	shl    $0x2,%eax
8010913e:	01 d0                	add    %edx,%eax
80109140:	01 c0                	add    %eax,%eax
80109142:	01 d0                	add    %edx,%eax
80109144:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109149:	0f b6 00             	movzbl (%eax),%eax
8010914c:	84 c0                	test   %al,%al
8010914e:	75 0e                	jne    8010915e <arp_table_search+0x6b>
80109150:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109154:	75 08                	jne    8010915e <arp_table_search+0x6b>
      empty = -i;
80109156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109159:	f7 d8                	neg    %eax
8010915b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010915e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109162:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109166:	7e a1                	jle    80109109 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916b:	83 e8 01             	sub    $0x1,%eax
}
8010916e:	c9                   	leave  
8010916f:	c3                   	ret    

80109170 <print_arp_table>:

void print_arp_table(){
80109170:	55                   	push   %ebp
80109171:	89 e5                	mov    %esp,%ebp
80109173:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109176:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010917d:	e9 92 00 00 00       	jmp    80109214 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109185:	89 d0                	mov    %edx,%eax
80109187:	c1 e0 02             	shl    $0x2,%eax
8010918a:	01 d0                	add    %edx,%eax
8010918c:	01 c0                	add    %eax,%eax
8010918e:	01 d0                	add    %edx,%eax
80109190:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109195:	0f b6 00             	movzbl (%eax),%eax
80109198:	84 c0                	test   %al,%al
8010919a:	74 74                	je     80109210 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010919c:	83 ec 08             	sub    $0x8,%esp
8010919f:	ff 75 f4             	push   -0xc(%ebp)
801091a2:	68 ef c0 10 80       	push   $0x8010c0ef
801091a7:	e8 48 72 ff ff       	call   801003f4 <cprintf>
801091ac:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801091af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091b2:	89 d0                	mov    %edx,%eax
801091b4:	c1 e0 02             	shl    $0x2,%eax
801091b7:	01 d0                	add    %edx,%eax
801091b9:	01 c0                	add    %eax,%eax
801091bb:	01 d0                	add    %edx,%eax
801091bd:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091c2:	83 ec 0c             	sub    $0xc,%esp
801091c5:	50                   	push   %eax
801091c6:	e8 54 02 00 00       	call   8010941f <print_ipv4>
801091cb:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801091ce:	83 ec 0c             	sub    $0xc,%esp
801091d1:	68 fe c0 10 80       	push   $0x8010c0fe
801091d6:	e8 19 72 ff ff       	call   801003f4 <cprintf>
801091db:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801091de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091e1:	89 d0                	mov    %edx,%eax
801091e3:	c1 e0 02             	shl    $0x2,%eax
801091e6:	01 d0                	add    %edx,%eax
801091e8:	01 c0                	add    %eax,%eax
801091ea:	01 d0                	add    %edx,%eax
801091ec:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091f1:	83 c0 04             	add    $0x4,%eax
801091f4:	83 ec 0c             	sub    $0xc,%esp
801091f7:	50                   	push   %eax
801091f8:	e8 70 02 00 00       	call   8010946d <print_mac>
801091fd:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109200:	83 ec 0c             	sub    $0xc,%esp
80109203:	68 00 c1 10 80       	push   $0x8010c100
80109208:	e8 e7 71 ff ff       	call   801003f4 <cprintf>
8010920d:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109210:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109214:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109218:	0f 8e 64 ff ff ff    	jle    80109182 <print_arp_table+0x12>
    }
  }
}
8010921e:	90                   	nop
8010921f:	90                   	nop
80109220:	c9                   	leave  
80109221:	c3                   	ret    

80109222 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109222:	55                   	push   %ebp
80109223:	89 e5                	mov    %esp,%ebp
80109225:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109228:	8b 45 10             	mov    0x10(%ebp),%eax
8010922b:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109231:	8b 45 0c             	mov    0xc(%ebp),%eax
80109234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109237:	8b 45 0c             	mov    0xc(%ebp),%eax
8010923a:	83 c0 0e             	add    $0xe,%eax
8010923d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109243:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924a:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010924e:	8b 45 08             	mov    0x8(%ebp),%eax
80109251:	8d 50 08             	lea    0x8(%eax),%edx
80109254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109257:	83 ec 04             	sub    $0x4,%esp
8010925a:	6a 06                	push   $0x6
8010925c:	52                   	push   %edx
8010925d:	50                   	push   %eax
8010925e:	e8 eb b8 ff ff       	call   80104b4e <memmove>
80109263:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109269:	83 c0 06             	add    $0x6,%eax
8010926c:	83 ec 04             	sub    $0x4,%esp
8010926f:	6a 06                	push   $0x6
80109271:	68 80 6c 19 80       	push   $0x80196c80
80109276:	50                   	push   %eax
80109277:	e8 d2 b8 ff ff       	call   80104b4e <memmove>
8010927c:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010927f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109282:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109293:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929a:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010929e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a1:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801092a7:	8b 45 08             	mov    0x8(%ebp),%eax
801092aa:	8d 50 08             	lea    0x8(%eax),%edx
801092ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b0:	83 c0 12             	add    $0x12,%eax
801092b3:	83 ec 04             	sub    $0x4,%esp
801092b6:	6a 06                	push   $0x6
801092b8:	52                   	push   %edx
801092b9:	50                   	push   %eax
801092ba:	e8 8f b8 ff ff       	call   80104b4e <memmove>
801092bf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801092c2:	8b 45 08             	mov    0x8(%ebp),%eax
801092c5:	8d 50 0e             	lea    0xe(%eax),%edx
801092c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092cb:	83 c0 18             	add    $0x18,%eax
801092ce:	83 ec 04             	sub    $0x4,%esp
801092d1:	6a 04                	push   $0x4
801092d3:	52                   	push   %edx
801092d4:	50                   	push   %eax
801092d5:	e8 74 b8 ff ff       	call   80104b4e <memmove>
801092da:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e0:	83 c0 08             	add    $0x8,%eax
801092e3:	83 ec 04             	sub    $0x4,%esp
801092e6:	6a 06                	push   $0x6
801092e8:	68 80 6c 19 80       	push   $0x80196c80
801092ed:	50                   	push   %eax
801092ee:	e8 5b b8 ff ff       	call   80104b4e <memmove>
801092f3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092f9:	83 c0 0e             	add    $0xe,%eax
801092fc:	83 ec 04             	sub    $0x4,%esp
801092ff:	6a 04                	push   $0x4
80109301:	68 e4 f4 10 80       	push   $0x8010f4e4
80109306:	50                   	push   %eax
80109307:	e8 42 b8 ff ff       	call   80104b4e <memmove>
8010930c:	83 c4 10             	add    $0x10,%esp
}
8010930f:	90                   	nop
80109310:	c9                   	leave  
80109311:	c3                   	ret    

80109312 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109312:	55                   	push   %ebp
80109313:	89 e5                	mov    %esp,%ebp
80109315:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109318:	83 ec 0c             	sub    $0xc,%esp
8010931b:	68 02 c1 10 80       	push   $0x8010c102
80109320:	e8 cf 70 ff ff       	call   801003f4 <cprintf>
80109325:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109328:	8b 45 08             	mov    0x8(%ebp),%eax
8010932b:	83 c0 0e             	add    $0xe,%eax
8010932e:	83 ec 0c             	sub    $0xc,%esp
80109331:	50                   	push   %eax
80109332:	e8 e8 00 00 00       	call   8010941f <print_ipv4>
80109337:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010933a:	83 ec 0c             	sub    $0xc,%esp
8010933d:	68 00 c1 10 80       	push   $0x8010c100
80109342:	e8 ad 70 ff ff       	call   801003f4 <cprintf>
80109347:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010934a:	8b 45 08             	mov    0x8(%ebp),%eax
8010934d:	83 c0 08             	add    $0x8,%eax
80109350:	83 ec 0c             	sub    $0xc,%esp
80109353:	50                   	push   %eax
80109354:	e8 14 01 00 00       	call   8010946d <print_mac>
80109359:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010935c:	83 ec 0c             	sub    $0xc,%esp
8010935f:	68 00 c1 10 80       	push   $0x8010c100
80109364:	e8 8b 70 ff ff       	call   801003f4 <cprintf>
80109369:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010936c:	83 ec 0c             	sub    $0xc,%esp
8010936f:	68 19 c1 10 80       	push   $0x8010c119
80109374:	e8 7b 70 ff ff       	call   801003f4 <cprintf>
80109379:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010937c:	8b 45 08             	mov    0x8(%ebp),%eax
8010937f:	83 c0 18             	add    $0x18,%eax
80109382:	83 ec 0c             	sub    $0xc,%esp
80109385:	50                   	push   %eax
80109386:	e8 94 00 00 00       	call   8010941f <print_ipv4>
8010938b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010938e:	83 ec 0c             	sub    $0xc,%esp
80109391:	68 00 c1 10 80       	push   $0x8010c100
80109396:	e8 59 70 ff ff       	call   801003f4 <cprintf>
8010939b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010939e:	8b 45 08             	mov    0x8(%ebp),%eax
801093a1:	83 c0 12             	add    $0x12,%eax
801093a4:	83 ec 0c             	sub    $0xc,%esp
801093a7:	50                   	push   %eax
801093a8:	e8 c0 00 00 00       	call   8010946d <print_mac>
801093ad:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801093b0:	83 ec 0c             	sub    $0xc,%esp
801093b3:	68 00 c1 10 80       	push   $0x8010c100
801093b8:	e8 37 70 ff ff       	call   801003f4 <cprintf>
801093bd:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801093c0:	83 ec 0c             	sub    $0xc,%esp
801093c3:	68 30 c1 10 80       	push   $0x8010c130
801093c8:	e8 27 70 ff ff       	call   801003f4 <cprintf>
801093cd:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801093d0:	8b 45 08             	mov    0x8(%ebp),%eax
801093d3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093d7:	66 3d 00 01          	cmp    $0x100,%ax
801093db:	75 12                	jne    801093ef <print_arp_info+0xdd>
801093dd:	83 ec 0c             	sub    $0xc,%esp
801093e0:	68 3c c1 10 80       	push   $0x8010c13c
801093e5:	e8 0a 70 ff ff       	call   801003f4 <cprintf>
801093ea:	83 c4 10             	add    $0x10,%esp
801093ed:	eb 1d                	jmp    8010940c <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801093ef:	8b 45 08             	mov    0x8(%ebp),%eax
801093f2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093f6:	66 3d 00 02          	cmp    $0x200,%ax
801093fa:	75 10                	jne    8010940c <print_arp_info+0xfa>
    cprintf("Reply\n");
801093fc:	83 ec 0c             	sub    $0xc,%esp
801093ff:	68 45 c1 10 80       	push   $0x8010c145
80109404:	e8 eb 6f ff ff       	call   801003f4 <cprintf>
80109409:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010940c:	83 ec 0c             	sub    $0xc,%esp
8010940f:	68 00 c1 10 80       	push   $0x8010c100
80109414:	e8 db 6f ff ff       	call   801003f4 <cprintf>
80109419:	83 c4 10             	add    $0x10,%esp
}
8010941c:	90                   	nop
8010941d:	c9                   	leave  
8010941e:	c3                   	ret    

8010941f <print_ipv4>:

void print_ipv4(uchar *ip){
8010941f:	55                   	push   %ebp
80109420:	89 e5                	mov    %esp,%ebp
80109422:	53                   	push   %ebx
80109423:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109426:	8b 45 08             	mov    0x8(%ebp),%eax
80109429:	83 c0 03             	add    $0x3,%eax
8010942c:	0f b6 00             	movzbl (%eax),%eax
8010942f:	0f b6 d8             	movzbl %al,%ebx
80109432:	8b 45 08             	mov    0x8(%ebp),%eax
80109435:	83 c0 02             	add    $0x2,%eax
80109438:	0f b6 00             	movzbl (%eax),%eax
8010943b:	0f b6 c8             	movzbl %al,%ecx
8010943e:	8b 45 08             	mov    0x8(%ebp),%eax
80109441:	83 c0 01             	add    $0x1,%eax
80109444:	0f b6 00             	movzbl (%eax),%eax
80109447:	0f b6 d0             	movzbl %al,%edx
8010944a:	8b 45 08             	mov    0x8(%ebp),%eax
8010944d:	0f b6 00             	movzbl (%eax),%eax
80109450:	0f b6 c0             	movzbl %al,%eax
80109453:	83 ec 0c             	sub    $0xc,%esp
80109456:	53                   	push   %ebx
80109457:	51                   	push   %ecx
80109458:	52                   	push   %edx
80109459:	50                   	push   %eax
8010945a:	68 4c c1 10 80       	push   $0x8010c14c
8010945f:	e8 90 6f ff ff       	call   801003f4 <cprintf>
80109464:	83 c4 20             	add    $0x20,%esp
}
80109467:	90                   	nop
80109468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010946b:	c9                   	leave  
8010946c:	c3                   	ret    

8010946d <print_mac>:

void print_mac(uchar *mac){
8010946d:	55                   	push   %ebp
8010946e:	89 e5                	mov    %esp,%ebp
80109470:	57                   	push   %edi
80109471:	56                   	push   %esi
80109472:	53                   	push   %ebx
80109473:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109476:	8b 45 08             	mov    0x8(%ebp),%eax
80109479:	83 c0 05             	add    $0x5,%eax
8010947c:	0f b6 00             	movzbl (%eax),%eax
8010947f:	0f b6 f8             	movzbl %al,%edi
80109482:	8b 45 08             	mov    0x8(%ebp),%eax
80109485:	83 c0 04             	add    $0x4,%eax
80109488:	0f b6 00             	movzbl (%eax),%eax
8010948b:	0f b6 f0             	movzbl %al,%esi
8010948e:	8b 45 08             	mov    0x8(%ebp),%eax
80109491:	83 c0 03             	add    $0x3,%eax
80109494:	0f b6 00             	movzbl (%eax),%eax
80109497:	0f b6 d8             	movzbl %al,%ebx
8010949a:	8b 45 08             	mov    0x8(%ebp),%eax
8010949d:	83 c0 02             	add    $0x2,%eax
801094a0:	0f b6 00             	movzbl (%eax),%eax
801094a3:	0f b6 c8             	movzbl %al,%ecx
801094a6:	8b 45 08             	mov    0x8(%ebp),%eax
801094a9:	83 c0 01             	add    $0x1,%eax
801094ac:	0f b6 00             	movzbl (%eax),%eax
801094af:	0f b6 d0             	movzbl %al,%edx
801094b2:	8b 45 08             	mov    0x8(%ebp),%eax
801094b5:	0f b6 00             	movzbl (%eax),%eax
801094b8:	0f b6 c0             	movzbl %al,%eax
801094bb:	83 ec 04             	sub    $0x4,%esp
801094be:	57                   	push   %edi
801094bf:	56                   	push   %esi
801094c0:	53                   	push   %ebx
801094c1:	51                   	push   %ecx
801094c2:	52                   	push   %edx
801094c3:	50                   	push   %eax
801094c4:	68 64 c1 10 80       	push   $0x8010c164
801094c9:	e8 26 6f ff ff       	call   801003f4 <cprintf>
801094ce:	83 c4 20             	add    $0x20,%esp
}
801094d1:	90                   	nop
801094d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801094d5:	5b                   	pop    %ebx
801094d6:	5e                   	pop    %esi
801094d7:	5f                   	pop    %edi
801094d8:	5d                   	pop    %ebp
801094d9:	c3                   	ret    

801094da <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801094da:	55                   	push   %ebp
801094db:	89 e5                	mov    %esp,%ebp
801094dd:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801094e0:	8b 45 08             	mov    0x8(%ebp),%eax
801094e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801094e6:	8b 45 08             	mov    0x8(%ebp),%eax
801094e9:	83 c0 0e             	add    $0xe,%eax
801094ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801094ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094f6:	3c 08                	cmp    $0x8,%al
801094f8:	75 1b                	jne    80109515 <eth_proc+0x3b>
801094fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fd:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109501:	3c 06                	cmp    $0x6,%al
80109503:	75 10                	jne    80109515 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109505:	83 ec 0c             	sub    $0xc,%esp
80109508:	ff 75 f0             	push   -0x10(%ebp)
8010950b:	e8 01 f8 ff ff       	call   80108d11 <arp_proc>
80109510:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109513:	eb 24                	jmp    80109539 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109518:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010951c:	3c 08                	cmp    $0x8,%al
8010951e:	75 19                	jne    80109539 <eth_proc+0x5f>
80109520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109523:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109527:	84 c0                	test   %al,%al
80109529:	75 0e                	jne    80109539 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
8010952b:	83 ec 0c             	sub    $0xc,%esp
8010952e:	ff 75 08             	push   0x8(%ebp)
80109531:	e8 a3 00 00 00       	call   801095d9 <ipv4_proc>
80109536:	83 c4 10             	add    $0x10,%esp
}
80109539:	90                   	nop
8010953a:	c9                   	leave  
8010953b:	c3                   	ret    

8010953c <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010953c:	55                   	push   %ebp
8010953d:	89 e5                	mov    %esp,%ebp
8010953f:	83 ec 04             	sub    $0x4,%esp
80109542:	8b 45 08             	mov    0x8(%ebp),%eax
80109545:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109549:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010954d:	c1 e0 08             	shl    $0x8,%eax
80109550:	89 c2                	mov    %eax,%edx
80109552:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109556:	66 c1 e8 08          	shr    $0x8,%ax
8010955a:	01 d0                	add    %edx,%eax
}
8010955c:	c9                   	leave  
8010955d:	c3                   	ret    

8010955e <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010955e:	55                   	push   %ebp
8010955f:	89 e5                	mov    %esp,%ebp
80109561:	83 ec 04             	sub    $0x4,%esp
80109564:	8b 45 08             	mov    0x8(%ebp),%eax
80109567:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010956b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010956f:	c1 e0 08             	shl    $0x8,%eax
80109572:	89 c2                	mov    %eax,%edx
80109574:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109578:	66 c1 e8 08          	shr    $0x8,%ax
8010957c:	01 d0                	add    %edx,%eax
}
8010957e:	c9                   	leave  
8010957f:	c3                   	ret    

80109580 <H2N_uint>:

uint H2N_uint(uint value){
80109580:	55                   	push   %ebp
80109581:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109583:	8b 45 08             	mov    0x8(%ebp),%eax
80109586:	c1 e0 18             	shl    $0x18,%eax
80109589:	25 00 00 00 0f       	and    $0xf000000,%eax
8010958e:	89 c2                	mov    %eax,%edx
80109590:	8b 45 08             	mov    0x8(%ebp),%eax
80109593:	c1 e0 08             	shl    $0x8,%eax
80109596:	25 00 f0 00 00       	and    $0xf000,%eax
8010959b:	09 c2                	or     %eax,%edx
8010959d:	8b 45 08             	mov    0x8(%ebp),%eax
801095a0:	c1 e8 08             	shr    $0x8,%eax
801095a3:	83 e0 0f             	and    $0xf,%eax
801095a6:	01 d0                	add    %edx,%eax
}
801095a8:	5d                   	pop    %ebp
801095a9:	c3                   	ret    

801095aa <N2H_uint>:

uint N2H_uint(uint value){
801095aa:	55                   	push   %ebp
801095ab:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801095ad:	8b 45 08             	mov    0x8(%ebp),%eax
801095b0:	c1 e0 18             	shl    $0x18,%eax
801095b3:	89 c2                	mov    %eax,%edx
801095b5:	8b 45 08             	mov    0x8(%ebp),%eax
801095b8:	c1 e0 08             	shl    $0x8,%eax
801095bb:	25 00 00 ff 00       	and    $0xff0000,%eax
801095c0:	01 c2                	add    %eax,%edx
801095c2:	8b 45 08             	mov    0x8(%ebp),%eax
801095c5:	c1 e8 08             	shr    $0x8,%eax
801095c8:	25 00 ff 00 00       	and    $0xff00,%eax
801095cd:	01 c2                	add    %eax,%edx
801095cf:	8b 45 08             	mov    0x8(%ebp),%eax
801095d2:	c1 e8 18             	shr    $0x18,%eax
801095d5:	01 d0                	add    %edx,%eax
}
801095d7:	5d                   	pop    %ebp
801095d8:	c3                   	ret    

801095d9 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801095d9:	55                   	push   %ebp
801095da:	89 e5                	mov    %esp,%ebp
801095dc:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801095df:	8b 45 08             	mov    0x8(%ebp),%eax
801095e2:	83 c0 0e             	add    $0xe,%eax
801095e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801095e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095eb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095ef:	0f b7 d0             	movzwl %ax,%edx
801095f2:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801095f7:	39 c2                	cmp    %eax,%edx
801095f9:	74 60                	je     8010965b <ipv4_proc+0x82>
801095fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fe:	83 c0 0c             	add    $0xc,%eax
80109601:	83 ec 04             	sub    $0x4,%esp
80109604:	6a 04                	push   $0x4
80109606:	50                   	push   %eax
80109607:	68 e4 f4 10 80       	push   $0x8010f4e4
8010960c:	e8 e5 b4 ff ff       	call   80104af6 <memcmp>
80109611:	83 c4 10             	add    $0x10,%esp
80109614:	85 c0                	test   %eax,%eax
80109616:	74 43                	je     8010965b <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010961f:	0f b7 c0             	movzwl %ax,%eax
80109622:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010962e:	3c 01                	cmp    $0x1,%al
80109630:	75 10                	jne    80109642 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109632:	83 ec 0c             	sub    $0xc,%esp
80109635:	ff 75 08             	push   0x8(%ebp)
80109638:	e8 a3 00 00 00       	call   801096e0 <icmp_proc>
8010963d:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109640:	eb 19                	jmp    8010965b <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109645:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109649:	3c 06                	cmp    $0x6,%al
8010964b:	75 0e                	jne    8010965b <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010964d:	83 ec 0c             	sub    $0xc,%esp
80109650:	ff 75 08             	push   0x8(%ebp)
80109653:	e8 b3 03 00 00       	call   80109a0b <tcp_proc>
80109658:	83 c4 10             	add    $0x10,%esp
}
8010965b:	90                   	nop
8010965c:	c9                   	leave  
8010965d:	c3                   	ret    

8010965e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010965e:	55                   	push   %ebp
8010965f:	89 e5                	mov    %esp,%ebp
80109661:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109664:	8b 45 08             	mov    0x8(%ebp),%eax
80109667:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010966a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966d:	0f b6 00             	movzbl (%eax),%eax
80109670:	83 e0 0f             	and    $0xf,%eax
80109673:	01 c0                	add    %eax,%eax
80109675:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109678:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010967f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109686:	eb 48                	jmp    801096d0 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109688:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010968b:	01 c0                	add    %eax,%eax
8010968d:	89 c2                	mov    %eax,%edx
8010968f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109692:	01 d0                	add    %edx,%eax
80109694:	0f b6 00             	movzbl (%eax),%eax
80109697:	0f b6 c0             	movzbl %al,%eax
8010969a:	c1 e0 08             	shl    $0x8,%eax
8010969d:	89 c2                	mov    %eax,%edx
8010969f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801096a2:	01 c0                	add    %eax,%eax
801096a4:	8d 48 01             	lea    0x1(%eax),%ecx
801096a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096aa:	01 c8                	add    %ecx,%eax
801096ac:	0f b6 00             	movzbl (%eax),%eax
801096af:	0f b6 c0             	movzbl %al,%eax
801096b2:	01 d0                	add    %edx,%eax
801096b4:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801096b7:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801096be:	76 0c                	jbe    801096cc <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
801096c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801096c3:	0f b7 c0             	movzwl %ax,%eax
801096c6:	83 c0 01             	add    $0x1,%eax
801096c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801096cc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801096d0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801096d4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801096d7:	7c af                	jl     80109688 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
801096d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801096dc:	f7 d0                	not    %eax
}
801096de:	c9                   	leave  
801096df:	c3                   	ret    

801096e0 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801096e0:	55                   	push   %ebp
801096e1:	89 e5                	mov    %esp,%ebp
801096e3:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801096e6:	8b 45 08             	mov    0x8(%ebp),%eax
801096e9:	83 c0 0e             	add    $0xe,%eax
801096ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801096ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f2:	0f b6 00             	movzbl (%eax),%eax
801096f5:	0f b6 c0             	movzbl %al,%eax
801096f8:	83 e0 0f             	and    $0xf,%eax
801096fb:	c1 e0 02             	shl    $0x2,%eax
801096fe:	89 c2                	mov    %eax,%edx
80109700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109703:	01 d0                	add    %edx,%eax
80109705:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010970b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010970f:	84 c0                	test   %al,%al
80109711:	75 4f                	jne    80109762 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109716:	0f b6 00             	movzbl (%eax),%eax
80109719:	3c 08                	cmp    $0x8,%al
8010971b:	75 45                	jne    80109762 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010971d:	e8 8c 90 ff ff       	call   801027ae <kalloc>
80109722:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109725:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010972c:	83 ec 04             	sub    $0x4,%esp
8010972f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109732:	50                   	push   %eax
80109733:	ff 75 ec             	push   -0x14(%ebp)
80109736:	ff 75 08             	push   0x8(%ebp)
80109739:	e8 78 00 00 00       	call   801097b6 <icmp_reply_pkt_create>
8010973e:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109741:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109744:	83 ec 08             	sub    $0x8,%esp
80109747:	50                   	push   %eax
80109748:	ff 75 ec             	push   -0x14(%ebp)
8010974b:	e8 95 f4 ff ff       	call   80108be5 <i8254_send>
80109750:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109753:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109756:	83 ec 0c             	sub    $0xc,%esp
80109759:	50                   	push   %eax
8010975a:	e8 b5 8f ff ff       	call   80102714 <kfree>
8010975f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109762:	90                   	nop
80109763:	c9                   	leave  
80109764:	c3                   	ret    

80109765 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109765:	55                   	push   %ebp
80109766:	89 e5                	mov    %esp,%ebp
80109768:	53                   	push   %ebx
80109769:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010976c:	8b 45 08             	mov    0x8(%ebp),%eax
8010976f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109773:	0f b7 c0             	movzwl %ax,%eax
80109776:	83 ec 0c             	sub    $0xc,%esp
80109779:	50                   	push   %eax
8010977a:	e8 bd fd ff ff       	call   8010953c <N2H_ushort>
8010977f:	83 c4 10             	add    $0x10,%esp
80109782:	0f b7 d8             	movzwl %ax,%ebx
80109785:	8b 45 08             	mov    0x8(%ebp),%eax
80109788:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010978c:	0f b7 c0             	movzwl %ax,%eax
8010978f:	83 ec 0c             	sub    $0xc,%esp
80109792:	50                   	push   %eax
80109793:	e8 a4 fd ff ff       	call   8010953c <N2H_ushort>
80109798:	83 c4 10             	add    $0x10,%esp
8010979b:	0f b7 c0             	movzwl %ax,%eax
8010979e:	83 ec 04             	sub    $0x4,%esp
801097a1:	53                   	push   %ebx
801097a2:	50                   	push   %eax
801097a3:	68 83 c1 10 80       	push   $0x8010c183
801097a8:	e8 47 6c ff ff       	call   801003f4 <cprintf>
801097ad:	83 c4 10             	add    $0x10,%esp
}
801097b0:	90                   	nop
801097b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801097b4:	c9                   	leave  
801097b5:	c3                   	ret    

801097b6 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
801097b6:	55                   	push   %ebp
801097b7:	89 e5                	mov    %esp,%ebp
801097b9:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
801097bc:	8b 45 08             	mov    0x8(%ebp),%eax
801097bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801097c2:	8b 45 08             	mov    0x8(%ebp),%eax
801097c5:	83 c0 0e             	add    $0xe,%eax
801097c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
801097cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ce:	0f b6 00             	movzbl (%eax),%eax
801097d1:	0f b6 c0             	movzbl %al,%eax
801097d4:	83 e0 0f             	and    $0xf,%eax
801097d7:	c1 e0 02             	shl    $0x2,%eax
801097da:	89 c2                	mov    %eax,%edx
801097dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097df:	01 d0                	add    %edx,%eax
801097e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801097e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801097e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801097ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801097ed:	83 c0 0e             	add    $0xe,%eax
801097f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801097f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097f6:	83 c0 14             	add    $0x14,%eax
801097f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801097fc:	8b 45 10             	mov    0x10(%ebp),%eax
801097ff:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109808:	8d 50 06             	lea    0x6(%eax),%edx
8010980b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010980e:	83 ec 04             	sub    $0x4,%esp
80109811:	6a 06                	push   $0x6
80109813:	52                   	push   %edx
80109814:	50                   	push   %eax
80109815:	e8 34 b3 ff ff       	call   80104b4e <memmove>
8010981a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010981d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109820:	83 c0 06             	add    $0x6,%eax
80109823:	83 ec 04             	sub    $0x4,%esp
80109826:	6a 06                	push   $0x6
80109828:	68 80 6c 19 80       	push   $0x80196c80
8010982d:	50                   	push   %eax
8010982e:	e8 1b b3 ff ff       	call   80104b4e <memmove>
80109833:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109836:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109839:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010983d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109840:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109847:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010984a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010984d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109851:	83 ec 0c             	sub    $0xc,%esp
80109854:	6a 54                	push   $0x54
80109856:	e8 03 fd ff ff       	call   8010955e <H2N_ushort>
8010985b:	83 c4 10             	add    $0x10,%esp
8010985e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109861:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109865:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
8010986c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010986f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109873:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
8010987a:	83 c0 01             	add    $0x1,%eax
8010987d:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109883:	83 ec 0c             	sub    $0xc,%esp
80109886:	68 00 40 00 00       	push   $0x4000
8010988b:	e8 ce fc ff ff       	call   8010955e <H2N_ushort>
80109890:	83 c4 10             	add    $0x10,%esp
80109893:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109896:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010989a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010989d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
801098a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098a4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
801098a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098ab:	83 c0 0c             	add    $0xc,%eax
801098ae:	83 ec 04             	sub    $0x4,%esp
801098b1:	6a 04                	push   $0x4
801098b3:	68 e4 f4 10 80       	push   $0x8010f4e4
801098b8:	50                   	push   %eax
801098b9:	e8 90 b2 ff ff       	call   80104b4e <memmove>
801098be:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
801098c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c4:	8d 50 0c             	lea    0xc(%eax),%edx
801098c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098ca:	83 c0 10             	add    $0x10,%eax
801098cd:	83 ec 04             	sub    $0x4,%esp
801098d0:	6a 04                	push   $0x4
801098d2:	52                   	push   %edx
801098d3:	50                   	push   %eax
801098d4:	e8 75 b2 ff ff       	call   80104b4e <memmove>
801098d9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
801098dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098df:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801098e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098e8:	83 ec 0c             	sub    $0xc,%esp
801098eb:	50                   	push   %eax
801098ec:	e8 6d fd ff ff       	call   8010965e <ipv4_chksum>
801098f1:	83 c4 10             	add    $0x10,%esp
801098f4:	0f b7 c0             	movzwl %ax,%eax
801098f7:	83 ec 0c             	sub    $0xc,%esp
801098fa:	50                   	push   %eax
801098fb:	e8 5e fc ff ff       	call   8010955e <H2N_ushort>
80109900:	83 c4 10             	add    $0x10,%esp
80109903:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109906:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010990a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010990d:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109913:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109917:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010991a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010991e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109921:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109928:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010992c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010992f:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109933:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109936:	8d 50 08             	lea    0x8(%eax),%edx
80109939:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010993c:	83 c0 08             	add    $0x8,%eax
8010993f:	83 ec 04             	sub    $0x4,%esp
80109942:	6a 08                	push   $0x8
80109944:	52                   	push   %edx
80109945:	50                   	push   %eax
80109946:	e8 03 b2 ff ff       	call   80104b4e <memmove>
8010994b:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010994e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109951:	8d 50 10             	lea    0x10(%eax),%edx
80109954:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109957:	83 c0 10             	add    $0x10,%eax
8010995a:	83 ec 04             	sub    $0x4,%esp
8010995d:	6a 30                	push   $0x30
8010995f:	52                   	push   %edx
80109960:	50                   	push   %eax
80109961:	e8 e8 b1 ff ff       	call   80104b4e <memmove>
80109966:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109969:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010996c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109972:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109975:	83 ec 0c             	sub    $0xc,%esp
80109978:	50                   	push   %eax
80109979:	e8 1c 00 00 00       	call   8010999a <icmp_chksum>
8010997e:	83 c4 10             	add    $0x10,%esp
80109981:	0f b7 c0             	movzwl %ax,%eax
80109984:	83 ec 0c             	sub    $0xc,%esp
80109987:	50                   	push   %eax
80109988:	e8 d1 fb ff ff       	call   8010955e <H2N_ushort>
8010998d:	83 c4 10             	add    $0x10,%esp
80109990:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109993:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109997:	90                   	nop
80109998:	c9                   	leave  
80109999:	c3                   	ret    

8010999a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010999a:	55                   	push   %ebp
8010999b:	89 e5                	mov    %esp,%ebp
8010999d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
801099a0:	8b 45 08             	mov    0x8(%ebp),%eax
801099a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
801099a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099ad:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801099b4:	eb 48                	jmp    801099fe <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801099b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099b9:	01 c0                	add    %eax,%eax
801099bb:	89 c2                	mov    %eax,%edx
801099bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c0:	01 d0                	add    %edx,%eax
801099c2:	0f b6 00             	movzbl (%eax),%eax
801099c5:	0f b6 c0             	movzbl %al,%eax
801099c8:	c1 e0 08             	shl    $0x8,%eax
801099cb:	89 c2                	mov    %eax,%edx
801099cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099d0:	01 c0                	add    %eax,%eax
801099d2:	8d 48 01             	lea    0x1(%eax),%ecx
801099d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d8:	01 c8                	add    %ecx,%eax
801099da:	0f b6 00             	movzbl (%eax),%eax
801099dd:	0f b6 c0             	movzbl %al,%eax
801099e0:	01 d0                	add    %edx,%eax
801099e2:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099e5:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099ec:	76 0c                	jbe    801099fa <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801099ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099f1:	0f b7 c0             	movzwl %ax,%eax
801099f4:	83 c0 01             	add    $0x1,%eax
801099f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099fa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099fe:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109a02:	7e b2                	jle    801099b6 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a07:	f7 d0                	not    %eax
}
80109a09:	c9                   	leave  
80109a0a:	c3                   	ret    

80109a0b <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109a0b:	55                   	push   %ebp
80109a0c:	89 e5                	mov    %esp,%ebp
80109a0e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109a11:	8b 45 08             	mov    0x8(%ebp),%eax
80109a14:	83 c0 0e             	add    $0xe,%eax
80109a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1d:	0f b6 00             	movzbl (%eax),%eax
80109a20:	0f b6 c0             	movzbl %al,%eax
80109a23:	83 e0 0f             	and    $0xf,%eax
80109a26:	c1 e0 02             	shl    $0x2,%eax
80109a29:	89 c2                	mov    %eax,%edx
80109a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a2e:	01 d0                	add    %edx,%eax
80109a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a36:	83 c0 14             	add    $0x14,%eax
80109a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109a3c:	e8 6d 8d ff ff       	call   801027ae <kalloc>
80109a41:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109a44:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a4e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a52:	0f b6 c0             	movzbl %al,%eax
80109a55:	83 e0 02             	and    $0x2,%eax
80109a58:	85 c0                	test   %eax,%eax
80109a5a:	74 3d                	je     80109a99 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109a5c:	83 ec 0c             	sub    $0xc,%esp
80109a5f:	6a 00                	push   $0x0
80109a61:	6a 12                	push   $0x12
80109a63:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a66:	50                   	push   %eax
80109a67:	ff 75 e8             	push   -0x18(%ebp)
80109a6a:	ff 75 08             	push   0x8(%ebp)
80109a6d:	e8 a2 01 00 00       	call   80109c14 <tcp_pkt_create>
80109a72:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109a75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a78:	83 ec 08             	sub    $0x8,%esp
80109a7b:	50                   	push   %eax
80109a7c:	ff 75 e8             	push   -0x18(%ebp)
80109a7f:	e8 61 f1 ff ff       	call   80108be5 <i8254_send>
80109a84:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a87:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109a8c:	83 c0 01             	add    $0x1,%eax
80109a8f:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109a94:	e9 69 01 00 00       	jmp    80109c02 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109aa0:	3c 18                	cmp    $0x18,%al
80109aa2:	0f 85 10 01 00 00    	jne    80109bb8 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109aa8:	83 ec 04             	sub    $0x4,%esp
80109aab:	6a 03                	push   $0x3
80109aad:	68 9e c1 10 80       	push   $0x8010c19e
80109ab2:	ff 75 ec             	push   -0x14(%ebp)
80109ab5:	e8 3c b0 ff ff       	call   80104af6 <memcmp>
80109aba:	83 c4 10             	add    $0x10,%esp
80109abd:	85 c0                	test   %eax,%eax
80109abf:	74 74                	je     80109b35 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109ac1:	83 ec 0c             	sub    $0xc,%esp
80109ac4:	68 a2 c1 10 80       	push   $0x8010c1a2
80109ac9:	e8 26 69 ff ff       	call   801003f4 <cprintf>
80109ace:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ad1:	83 ec 0c             	sub    $0xc,%esp
80109ad4:	6a 00                	push   $0x0
80109ad6:	6a 10                	push   $0x10
80109ad8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109adb:	50                   	push   %eax
80109adc:	ff 75 e8             	push   -0x18(%ebp)
80109adf:	ff 75 08             	push   0x8(%ebp)
80109ae2:	e8 2d 01 00 00       	call   80109c14 <tcp_pkt_create>
80109ae7:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109aea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109aed:	83 ec 08             	sub    $0x8,%esp
80109af0:	50                   	push   %eax
80109af1:	ff 75 e8             	push   -0x18(%ebp)
80109af4:	e8 ec f0 ff ff       	call   80108be5 <i8254_send>
80109af9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109afc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aff:	83 c0 36             	add    $0x36,%eax
80109b02:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b05:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109b08:	50                   	push   %eax
80109b09:	ff 75 e0             	push   -0x20(%ebp)
80109b0c:	6a 00                	push   $0x0
80109b0e:	6a 00                	push   $0x0
80109b10:	e8 5a 04 00 00       	call   80109f6f <http_proc>
80109b15:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b18:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109b1b:	83 ec 0c             	sub    $0xc,%esp
80109b1e:	50                   	push   %eax
80109b1f:	6a 18                	push   $0x18
80109b21:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b24:	50                   	push   %eax
80109b25:	ff 75 e8             	push   -0x18(%ebp)
80109b28:	ff 75 08             	push   0x8(%ebp)
80109b2b:	e8 e4 00 00 00       	call   80109c14 <tcp_pkt_create>
80109b30:	83 c4 20             	add    $0x20,%esp
80109b33:	eb 62                	jmp    80109b97 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109b35:	83 ec 0c             	sub    $0xc,%esp
80109b38:	6a 00                	push   $0x0
80109b3a:	6a 10                	push   $0x10
80109b3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b3f:	50                   	push   %eax
80109b40:	ff 75 e8             	push   -0x18(%ebp)
80109b43:	ff 75 08             	push   0x8(%ebp)
80109b46:	e8 c9 00 00 00       	call   80109c14 <tcp_pkt_create>
80109b4b:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109b4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b51:	83 ec 08             	sub    $0x8,%esp
80109b54:	50                   	push   %eax
80109b55:	ff 75 e8             	push   -0x18(%ebp)
80109b58:	e8 88 f0 ff ff       	call   80108be5 <i8254_send>
80109b5d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b63:	83 c0 36             	add    $0x36,%eax
80109b66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b69:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109b6c:	50                   	push   %eax
80109b6d:	ff 75 e4             	push   -0x1c(%ebp)
80109b70:	6a 00                	push   $0x0
80109b72:	6a 00                	push   $0x0
80109b74:	e8 f6 03 00 00       	call   80109f6f <http_proc>
80109b79:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b7f:	83 ec 0c             	sub    $0xc,%esp
80109b82:	50                   	push   %eax
80109b83:	6a 18                	push   $0x18
80109b85:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b88:	50                   	push   %eax
80109b89:	ff 75 e8             	push   -0x18(%ebp)
80109b8c:	ff 75 08             	push   0x8(%ebp)
80109b8f:	e8 80 00 00 00       	call   80109c14 <tcp_pkt_create>
80109b94:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b9a:	83 ec 08             	sub    $0x8,%esp
80109b9d:	50                   	push   %eax
80109b9e:	ff 75 e8             	push   -0x18(%ebp)
80109ba1:	e8 3f f0 ff ff       	call   80108be5 <i8254_send>
80109ba6:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ba9:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109bae:	83 c0 01             	add    $0x1,%eax
80109bb1:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109bb6:	eb 4a                	jmp    80109c02 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbb:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109bbf:	3c 10                	cmp    $0x10,%al
80109bc1:	75 3f                	jne    80109c02 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109bc3:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109bc8:	83 f8 01             	cmp    $0x1,%eax
80109bcb:	75 35                	jne    80109c02 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109bcd:	83 ec 0c             	sub    $0xc,%esp
80109bd0:	6a 00                	push   $0x0
80109bd2:	6a 01                	push   $0x1
80109bd4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bd7:	50                   	push   %eax
80109bd8:	ff 75 e8             	push   -0x18(%ebp)
80109bdb:	ff 75 08             	push   0x8(%ebp)
80109bde:	e8 31 00 00 00       	call   80109c14 <tcp_pkt_create>
80109be3:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109be6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109be9:	83 ec 08             	sub    $0x8,%esp
80109bec:	50                   	push   %eax
80109bed:	ff 75 e8             	push   -0x18(%ebp)
80109bf0:	e8 f0 ef ff ff       	call   80108be5 <i8254_send>
80109bf5:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109bf8:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109bff:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109c02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c05:	83 ec 0c             	sub    $0xc,%esp
80109c08:	50                   	push   %eax
80109c09:	e8 06 8b ff ff       	call   80102714 <kfree>
80109c0e:	83 c4 10             	add    $0x10,%esp
}
80109c11:	90                   	nop
80109c12:	c9                   	leave  
80109c13:	c3                   	ret    

80109c14 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109c14:	55                   	push   %ebp
80109c15:	89 e5                	mov    %esp,%ebp
80109c17:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c20:	8b 45 08             	mov    0x8(%ebp),%eax
80109c23:	83 c0 0e             	add    $0xe,%eax
80109c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c2c:	0f b6 00             	movzbl (%eax),%eax
80109c2f:	0f b6 c0             	movzbl %al,%eax
80109c32:	83 e0 0f             	and    $0xf,%eax
80109c35:	c1 e0 02             	shl    $0x2,%eax
80109c38:	89 c2                	mov    %eax,%edx
80109c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c3d:	01 d0                	add    %edx,%eax
80109c3f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c42:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c45:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109c48:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c4b:	83 c0 0e             	add    $0xe,%eax
80109c4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109c51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c54:	83 c0 14             	add    $0x14,%eax
80109c57:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109c5a:	8b 45 18             	mov    0x18(%ebp),%eax
80109c5d:	8d 50 36             	lea    0x36(%eax),%edx
80109c60:	8b 45 10             	mov    0x10(%ebp),%eax
80109c63:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c68:	8d 50 06             	lea    0x6(%eax),%edx
80109c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c6e:	83 ec 04             	sub    $0x4,%esp
80109c71:	6a 06                	push   $0x6
80109c73:	52                   	push   %edx
80109c74:	50                   	push   %eax
80109c75:	e8 d4 ae ff ff       	call   80104b4e <memmove>
80109c7a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c80:	83 c0 06             	add    $0x6,%eax
80109c83:	83 ec 04             	sub    $0x4,%esp
80109c86:	6a 06                	push   $0x6
80109c88:	68 80 6c 19 80       	push   $0x80196c80
80109c8d:	50                   	push   %eax
80109c8e:	e8 bb ae ff ff       	call   80104b4e <memmove>
80109c93:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c99:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ca0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ca7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109caa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cad:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109cb1:	8b 45 18             	mov    0x18(%ebp),%eax
80109cb4:	83 c0 28             	add    $0x28,%eax
80109cb7:	0f b7 c0             	movzwl %ax,%eax
80109cba:	83 ec 0c             	sub    $0xc,%esp
80109cbd:	50                   	push   %eax
80109cbe:	e8 9b f8 ff ff       	call   8010955e <H2N_ushort>
80109cc3:	83 c4 10             	add    $0x10,%esp
80109cc6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cc9:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109ccd:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109cd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd7:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109cdb:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109ce2:	83 c0 01             	add    $0x1,%eax
80109ce5:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109ceb:	83 ec 0c             	sub    $0xc,%esp
80109cee:	6a 00                	push   $0x0
80109cf0:	e8 69 f8 ff ff       	call   8010955e <H2N_ushort>
80109cf5:	83 c4 10             	add    $0x10,%esp
80109cf8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cfb:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d02:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d09:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d10:	83 c0 0c             	add    $0xc,%eax
80109d13:	83 ec 04             	sub    $0x4,%esp
80109d16:	6a 04                	push   $0x4
80109d18:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d1d:	50                   	push   %eax
80109d1e:	e8 2b ae ff ff       	call   80104b4e <memmove>
80109d23:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d29:	8d 50 0c             	lea    0xc(%eax),%edx
80109d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d2f:	83 c0 10             	add    $0x10,%eax
80109d32:	83 ec 04             	sub    $0x4,%esp
80109d35:	6a 04                	push   $0x4
80109d37:	52                   	push   %edx
80109d38:	50                   	push   %eax
80109d39:	e8 10 ae ff ff       	call   80104b4e <memmove>
80109d3e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d44:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d4d:	83 ec 0c             	sub    $0xc,%esp
80109d50:	50                   	push   %eax
80109d51:	e8 08 f9 ff ff       	call   8010965e <ipv4_chksum>
80109d56:	83 c4 10             	add    $0x10,%esp
80109d59:	0f b7 c0             	movzwl %ax,%eax
80109d5c:	83 ec 0c             	sub    $0xc,%esp
80109d5f:	50                   	push   %eax
80109d60:	e8 f9 f7 ff ff       	call   8010955e <H2N_ushort>
80109d65:	83 c4 10             	add    $0x10,%esp
80109d68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d6b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109d6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d72:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109d76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d79:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d7f:	0f b7 10             	movzwl (%eax),%edx
80109d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d85:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d89:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d8e:	83 ec 0c             	sub    $0xc,%esp
80109d91:	50                   	push   %eax
80109d92:	e8 e9 f7 ff ff       	call   80109580 <H2N_uint>
80109d97:	83 c4 10             	add    $0x10,%esp
80109d9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d9d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109da3:	8b 40 04             	mov    0x4(%eax),%eax
80109da6:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109daf:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dbc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109dc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc3:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109dc7:	8b 45 14             	mov    0x14(%ebp),%eax
80109dca:	89 c2                	mov    %eax,%edx
80109dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dcf:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109dd2:	83 ec 0c             	sub    $0xc,%esp
80109dd5:	68 90 38 00 00       	push   $0x3890
80109dda:	e8 7f f7 ff ff       	call   8010955e <H2N_ushort>
80109ddf:	83 c4 10             	add    $0x10,%esp
80109de2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109de5:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dec:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dfe:	83 ec 0c             	sub    $0xc,%esp
80109e01:	50                   	push   %eax
80109e02:	e8 1f 00 00 00       	call   80109e26 <tcp_chksum>
80109e07:	83 c4 10             	add    $0x10,%esp
80109e0a:	83 c0 08             	add    $0x8,%eax
80109e0d:	0f b7 c0             	movzwl %ax,%eax
80109e10:	83 ec 0c             	sub    $0xc,%esp
80109e13:	50                   	push   %eax
80109e14:	e8 45 f7 ff ff       	call   8010955e <H2N_ushort>
80109e19:	83 c4 10             	add    $0x10,%esp
80109e1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e1f:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109e23:	90                   	nop
80109e24:	c9                   	leave  
80109e25:	c3                   	ret    

80109e26 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109e26:	55                   	push   %ebp
80109e27:	89 e5                	mov    %esp,%ebp
80109e29:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109e32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e35:	83 c0 14             	add    $0x14,%eax
80109e38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109e3b:	83 ec 04             	sub    $0x4,%esp
80109e3e:	6a 04                	push   $0x4
80109e40:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e45:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e48:	50                   	push   %eax
80109e49:	e8 00 ad ff ff       	call   80104b4e <memmove>
80109e4e:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109e51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e54:	83 c0 0c             	add    $0xc,%eax
80109e57:	83 ec 04             	sub    $0x4,%esp
80109e5a:	6a 04                	push   $0x4
80109e5c:	50                   	push   %eax
80109e5d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e60:	83 c0 04             	add    $0x4,%eax
80109e63:	50                   	push   %eax
80109e64:	e8 e5 ac ff ff       	call   80104b4e <memmove>
80109e69:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109e6c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109e70:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e77:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e7b:	0f b7 c0             	movzwl %ax,%eax
80109e7e:	83 ec 0c             	sub    $0xc,%esp
80109e81:	50                   	push   %eax
80109e82:	e8 b5 f6 ff ff       	call   8010953c <N2H_ushort>
80109e87:	83 c4 10             	add    $0x10,%esp
80109e8a:	83 e8 14             	sub    $0x14,%eax
80109e8d:	0f b7 c0             	movzwl %ax,%eax
80109e90:	83 ec 0c             	sub    $0xc,%esp
80109e93:	50                   	push   %eax
80109e94:	e8 c5 f6 ff ff       	call   8010955e <H2N_ushort>
80109e99:	83 c4 10             	add    $0x10,%esp
80109e9c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109ea0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109ea7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109eaa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109ead:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109eb4:	eb 33                	jmp    80109ee9 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eb9:	01 c0                	add    %eax,%eax
80109ebb:	89 c2                	mov    %eax,%edx
80109ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec0:	01 d0                	add    %edx,%eax
80109ec2:	0f b6 00             	movzbl (%eax),%eax
80109ec5:	0f b6 c0             	movzbl %al,%eax
80109ec8:	c1 e0 08             	shl    $0x8,%eax
80109ecb:	89 c2                	mov    %eax,%edx
80109ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed0:	01 c0                	add    %eax,%eax
80109ed2:	8d 48 01             	lea    0x1(%eax),%ecx
80109ed5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ed8:	01 c8                	add    %ecx,%eax
80109eda:	0f b6 00             	movzbl (%eax),%eax
80109edd:	0f b6 c0             	movzbl %al,%eax
80109ee0:	01 d0                	add    %edx,%eax
80109ee2:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109ee5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ee9:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109eed:	7e c7                	jle    80109eb6 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ef5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109efc:	eb 33                	jmp    80109f31 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f01:	01 c0                	add    %eax,%eax
80109f03:	89 c2                	mov    %eax,%edx
80109f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f08:	01 d0                	add    %edx,%eax
80109f0a:	0f b6 00             	movzbl (%eax),%eax
80109f0d:	0f b6 c0             	movzbl %al,%eax
80109f10:	c1 e0 08             	shl    $0x8,%eax
80109f13:	89 c2                	mov    %eax,%edx
80109f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f18:	01 c0                	add    %eax,%eax
80109f1a:	8d 48 01             	lea    0x1(%eax),%ecx
80109f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f20:	01 c8                	add    %ecx,%eax
80109f22:	0f b6 00             	movzbl (%eax),%eax
80109f25:	0f b6 c0             	movzbl %al,%eax
80109f28:	01 d0                	add    %edx,%eax
80109f2a:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109f2d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109f31:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109f35:	0f b7 c0             	movzwl %ax,%eax
80109f38:	83 ec 0c             	sub    $0xc,%esp
80109f3b:	50                   	push   %eax
80109f3c:	e8 fb f5 ff ff       	call   8010953c <N2H_ushort>
80109f41:	83 c4 10             	add    $0x10,%esp
80109f44:	66 d1 e8             	shr    %ax
80109f47:	0f b7 c0             	movzwl %ax,%eax
80109f4a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109f4d:	7c af                	jl     80109efe <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f52:	c1 e8 10             	shr    $0x10,%eax
80109f55:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f5b:	f7 d0                	not    %eax
}
80109f5d:	c9                   	leave  
80109f5e:	c3                   	ret    

80109f5f <tcp_fin>:

void tcp_fin(){
80109f5f:	55                   	push   %ebp
80109f60:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109f62:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109f69:	00 00 00 
}
80109f6c:	90                   	nop
80109f6d:	5d                   	pop    %ebp
80109f6e:	c3                   	ret    

80109f6f <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109f6f:	55                   	push   %ebp
80109f70:	89 e5                	mov    %esp,%ebp
80109f72:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109f75:	8b 45 10             	mov    0x10(%ebp),%eax
80109f78:	83 ec 04             	sub    $0x4,%esp
80109f7b:	6a 00                	push   $0x0
80109f7d:	68 ab c1 10 80       	push   $0x8010c1ab
80109f82:	50                   	push   %eax
80109f83:	e8 65 00 00 00       	call   80109fed <http_strcpy>
80109f88:	83 c4 10             	add    $0x10,%esp
80109f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f8e:	8b 45 10             	mov    0x10(%ebp),%eax
80109f91:	83 ec 04             	sub    $0x4,%esp
80109f94:	ff 75 f4             	push   -0xc(%ebp)
80109f97:	68 be c1 10 80       	push   $0x8010c1be
80109f9c:	50                   	push   %eax
80109f9d:	e8 4b 00 00 00       	call   80109fed <http_strcpy>
80109fa2:	83 c4 10             	add    $0x10,%esp
80109fa5:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109fa8:	8b 45 10             	mov    0x10(%ebp),%eax
80109fab:	83 ec 04             	sub    $0x4,%esp
80109fae:	ff 75 f4             	push   -0xc(%ebp)
80109fb1:	68 d9 c1 10 80       	push   $0x8010c1d9
80109fb6:	50                   	push   %eax
80109fb7:	e8 31 00 00 00       	call   80109fed <http_strcpy>
80109fbc:	83 c4 10             	add    $0x10,%esp
80109fbf:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc5:	83 e0 01             	and    $0x1,%eax
80109fc8:	85 c0                	test   %eax,%eax
80109fca:	74 11                	je     80109fdd <http_proc+0x6e>
    char *payload = (char *)send;
80109fcc:	8b 45 10             	mov    0x10(%ebp),%eax
80109fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fd8:	01 d0                	add    %edx,%eax
80109fda:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fe0:	8b 45 14             	mov    0x14(%ebp),%eax
80109fe3:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109fe5:	e8 75 ff ff ff       	call   80109f5f <tcp_fin>
}
80109fea:	90                   	nop
80109feb:	c9                   	leave  
80109fec:	c3                   	ret    

80109fed <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109fed:	55                   	push   %ebp
80109fee:	89 e5                	mov    %esp,%ebp
80109ff0:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109ff3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109ffa:	eb 20                	jmp    8010a01c <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109ffc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fff:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a002:	01 d0                	add    %edx,%eax
8010a004:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a007:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a00a:	01 ca                	add    %ecx,%edx
8010a00c:	89 d1                	mov    %edx,%ecx
8010a00e:	8b 55 08             	mov    0x8(%ebp),%edx
8010a011:	01 ca                	add    %ecx,%edx
8010a013:	0f b6 00             	movzbl (%eax),%eax
8010a016:	88 02                	mov    %al,(%edx)
    i++;
8010a018:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a01c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a01f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a022:	01 d0                	add    %edx,%eax
8010a024:	0f b6 00             	movzbl (%eax),%eax
8010a027:	84 c0                	test   %al,%al
8010a029:	75 d1                	jne    80109ffc <http_strcpy+0xf>
  }
  return i;
8010a02b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a02e:	c9                   	leave  
8010a02f:	c3                   	ret    

8010a030 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a030:	55                   	push   %ebp
8010a031:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a033:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
8010a03a:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a03d:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a042:	c1 e8 09             	shr    $0x9,%eax
8010a045:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a04a:	90                   	nop
8010a04b:	5d                   	pop    %ebp
8010a04c:	c3                   	ret    

8010a04d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a04d:	55                   	push   %ebp
8010a04e:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a050:	90                   	nop
8010a051:	5d                   	pop    %ebp
8010a052:	c3                   	ret    

8010a053 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a053:	55                   	push   %ebp
8010a054:	89 e5                	mov    %esp,%ebp
8010a056:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a059:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05c:	83 c0 0c             	add    $0xc,%eax
8010a05f:	83 ec 0c             	sub    $0xc,%esp
8010a062:	50                   	push   %eax
8010a063:	e8 20 a7 ff ff       	call   80104788 <holdingsleep>
8010a068:	83 c4 10             	add    $0x10,%esp
8010a06b:	85 c0                	test   %eax,%eax
8010a06d:	75 0d                	jne    8010a07c <iderw+0x29>
    panic("iderw: buf not locked");
8010a06f:	83 ec 0c             	sub    $0xc,%esp
8010a072:	68 ea c1 10 80       	push   $0x8010c1ea
8010a077:	e8 45 65 ff ff       	call   801005c1 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a07c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07f:	8b 00                	mov    (%eax),%eax
8010a081:	83 e0 06             	and    $0x6,%eax
8010a084:	83 f8 02             	cmp    $0x2,%eax
8010a087:	75 0d                	jne    8010a096 <iderw+0x43>
    panic("iderw: nothing to do");
8010a089:	83 ec 0c             	sub    $0xc,%esp
8010a08c:	68 00 c2 10 80       	push   $0x8010c200
8010a091:	e8 2b 65 ff ff       	call   801005c1 <panic>
  if(b->dev != 1)
8010a096:	8b 45 08             	mov    0x8(%ebp),%eax
8010a099:	8b 40 04             	mov    0x4(%eax),%eax
8010a09c:	83 f8 01             	cmp    $0x1,%eax
8010a09f:	74 0d                	je     8010a0ae <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a0a1:	83 ec 0c             	sub    $0xc,%esp
8010a0a4:	68 15 c2 10 80       	push   $0x8010c215
8010a0a9:	e8 13 65 ff ff       	call   801005c1 <panic>
  if(b->blockno >= disksize)
8010a0ae:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b1:	8b 40 08             	mov    0x8(%eax),%eax
8010a0b4:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a0ba:	39 d0                	cmp    %edx,%eax
8010a0bc:	72 0d                	jb     8010a0cb <iderw+0x78>
    panic("iderw: block out of range");
8010a0be:	83 ec 0c             	sub    $0xc,%esp
8010a0c1:	68 33 c2 10 80       	push   $0x8010c233
8010a0c6:	e8 f6 64 ff ff       	call   801005c1 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a0cb:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a0d1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d4:	8b 40 08             	mov    0x8(%eax),%eax
8010a0d7:	c1 e0 09             	shl    $0x9,%eax
8010a0da:	01 d0                	add    %edx,%eax
8010a0dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a0df:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e2:	8b 00                	mov    (%eax),%eax
8010a0e4:	83 e0 04             	and    $0x4,%eax
8010a0e7:	85 c0                	test   %eax,%eax
8010a0e9:	74 2b                	je     8010a116 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a0eb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0ee:	8b 00                	mov    (%eax),%eax
8010a0f0:	83 e0 fb             	and    $0xfffffffb,%eax
8010a0f3:	89 c2                	mov    %eax,%edx
8010a0f5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0f8:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a0fa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0fd:	83 c0 5c             	add    $0x5c,%eax
8010a100:	83 ec 04             	sub    $0x4,%esp
8010a103:	68 00 02 00 00       	push   $0x200
8010a108:	50                   	push   %eax
8010a109:	ff 75 f4             	push   -0xc(%ebp)
8010a10c:	e8 3d aa ff ff       	call   80104b4e <memmove>
8010a111:	83 c4 10             	add    $0x10,%esp
8010a114:	eb 1a                	jmp    8010a130 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a116:	8b 45 08             	mov    0x8(%ebp),%eax
8010a119:	83 c0 5c             	add    $0x5c,%eax
8010a11c:	83 ec 04             	sub    $0x4,%esp
8010a11f:	68 00 02 00 00       	push   $0x200
8010a124:	ff 75 f4             	push   -0xc(%ebp)
8010a127:	50                   	push   %eax
8010a128:	e8 21 aa ff ff       	call   80104b4e <memmove>
8010a12d:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a130:	8b 45 08             	mov    0x8(%ebp),%eax
8010a133:	8b 00                	mov    (%eax),%eax
8010a135:	83 c8 02             	or     $0x2,%eax
8010a138:	89 c2                	mov    %eax,%edx
8010a13a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a13d:	89 10                	mov    %edx,(%eax)
}
8010a13f:	90                   	nop
8010a140:	c9                   	leave  
8010a141:	c3                   	ret    
