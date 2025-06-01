
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
8010005f:	ba 5b 33 10 80       	mov    $0x8010335b,%edx
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
8010006f:	68 a0 a2 10 80       	push   $0x8010a2a0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 a3 47 00 00       	call   80104821 <initlock>
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
801000bd:	68 a7 a2 10 80       	push   $0x8010a2a7
801000c2:	50                   	push   %eax
801000c3:	e8 fc 45 00 00       	call   801046c4 <initsleeplock>
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
80100101:	e8 3d 47 00 00       	call   80104843 <acquire>
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
80100140:	e8 6c 47 00 00       	call   801048b1 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 a9 45 00 00       	call   80104700 <acquiresleep>
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
801001c1:	e8 eb 46 00 00       	call   801048b1 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 28 45 00 00       	call   80104700 <acquiresleep>
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
801001f5:	68 ae a2 10 80       	push   $0x8010a2ae
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
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
8010022d:	e8 6b 9f 00 00       	call   8010a19d <iderw>
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
8010024a:	e8 63 45 00 00       	call   801047b2 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 bf a2 10 80       	push   $0x8010a2bf
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
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
80100278:	e8 20 9f 00 00       	call   8010a19d <iderw>
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
80100293:	e8 1a 45 00 00       	call   801047b2 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 c6 a2 10 80       	push   $0x8010a2c6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 a9 44 00 00       	call   80104764 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 78 45 00 00       	call   80104843 <acquire>
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
80100336:	e8 76 45 00 00       	call   801048b1 <release>
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
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
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
80100410:	e8 2e 44 00 00       	call   80104843 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 cd a2 10 80       	push   $0x8010a2cd
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
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
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec d6 a2 10 80 	movl   $0x8010a2d6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 0e 43 00 00       	call   801048b1 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 2d 25 00 00       	call   80102af0 <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 dd a2 10 80       	push   $0x8010a2dd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 f1 a2 10 80       	push   $0x8010a2f1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 00 43 00 00       	call   80104903 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 f3 a2 10 80       	push   $0x8010a2f3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 4f 7a 00 00       	call   801080f4 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 fc 79 00 00       	call   801080f4 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 03 7a 00 00       	call   8010815f <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 b8 5d 00 00       	call   80106550 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 ab 5d 00 00       	call   80106550 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 9e 5d 00 00       	call   80106550 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 8e 5d 00 00       	call   80106550 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 53 40 00 00       	call   80104843 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 72 3a 00 00       	call   801043b6 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 4a 3f 00 00       	call   801048b1 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 fc 3a 00 00       	call   80104471 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 6a 11 00 00       	call   80101af3 <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 a4 3e 00 00       	call   80104843 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 7a 30 00 00       	call   80103a26 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 f1 3e 00 00       	call   801048b1 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 12 10 00 00       	call   801019e0 <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 e2 38 00 00       	call   801042cf <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 46 3e 00 00       	call   801048b1 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 67 0f 00 00       	call   801019e0 <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 5c 10 00 00       	call   80101af3 <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 9c 3d 00 00       	call   80104843 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 c8 3d 00 00       	call   801048b1 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 e9 0e 00 00       	call   801019e0 <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 f7 a2 10 80       	push   $0x8010a2f7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 00 3d 00 00       	call   80104821 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 ff a2 10 80 	movl   $0x8010a2ff,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 aa 1a 00 00       	call   80102624 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 98 2e 00 00       	call   80103a26 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 9c 24 00 00       	call   80103032 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 72 19 00 00       	call   80102513 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 0c 25 00 00       	call   801030be <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 18 a3 10 80       	push   $0x8010a318
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 e7 03 00 00       	jmp    80100fb3 <exec+0x433>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 09 0e 00 00       	call   801019e0 <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 d8 12 00 00       	call   80101ecc <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 5f 03 00 00    	jne    80100f5f <exec+0x3df>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 51 03 00 00    	jne    80100f62 <exec+0x3e2>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 36 69 00 00       	call   8010754c <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 42 03 00 00    	je     80100f65 <exec+0x3e5>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 78 12 00 00       	call   80101ecc <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 08 03 00 00    	jne    80100f68 <exec+0x3e8>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 e8 02 00 00    	jb     80100f6b <exec+0x3eb>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 cf 02 00 00    	jb     80100f6e <exec+0x3ee>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 89 6c 00 00       	call   80107945 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 a5 02 00 00    	je     80100f71 <exec+0x3f1>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 95 02 00 00    	jne    80100f74 <exec+0x3f4>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 76 6b 00 00       	call   80107878 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 6a 02 00 00    	js     80100f77 <exec+0x3f7>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 d6 0e 00 00       	call   80101c11 <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 7b 23 00 00       	call   801030be <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)



  //스택 한 페이지만 할당
  
  sz = KERNBASE-1; //가상 메모리 끝 아래
80100d4a:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz - PGSIZE, sz )) == 0) 
80100d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d54:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d59:	83 ec 04             	sub    $0x4,%esp
80100d5c:	ff 75 e0             	push   -0x20(%ebp)
80100d5f:	50                   	push   %eax
80100d60:	ff 75 d4             	push   -0x2c(%ebp)
80100d63:	e8 dd 6b 00 00       	call   80107945 <allocuvm>
80100d68:	83 c4 10             	add    $0x10,%esp
80100d6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d6e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d72:	0f 84 02 02 00 00    	je     80100f7a <exec+0x3fa>
    goto bad;

  sz=PGROUNDDOWN(0x3000);
80100d78:	c7 45 e0 00 30 00 00 	movl   $0x3000,-0x20(%ebp)
  sp = KERNBASE - 1;
80100d7f:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d86:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d8d:	e9 96 00 00 00       	jmp    80100e28 <exec+0x2a8>
    if(argc >= MAXARG)
80100d92:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d96:	0f 87 e1 01 00 00    	ja     80100f7d <exec+0x3fd>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	8b 00                	mov    (%eax),%eax
80100dad:	83 ec 0c             	sub    $0xc,%esp
80100db0:	50                   	push   %eax
80100db1:	e8 51 3f 00 00       	call   80104d07 <strlen>
80100db6:	83 c4 10             	add    $0x10,%esp
80100db9:	89 c2                	mov    %eax,%edx
80100dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbe:	29 d0                	sub    %edx,%eax
80100dc0:	83 e8 01             	sub    $0x1,%eax
80100dc3:	83 e0 fc             	and    $0xfffffffc,%eax
80100dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd6:	01 d0                	add    %edx,%eax
80100dd8:	8b 00                	mov    (%eax),%eax
80100dda:	83 ec 0c             	sub    $0xc,%esp
80100ddd:	50                   	push   %eax
80100dde:	e8 24 3f 00 00       	call   80104d07 <strlen>
80100de3:	83 c4 10             	add    $0x10,%esp
80100de6:	83 c0 01             	add    $0x1,%eax
80100de9:	89 c2                	mov    %eax,%edx
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 c8                	add    %ecx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	52                   	push   %edx
80100dfd:	50                   	push   %eax
80100dfe:	ff 75 dc             	push   -0x24(%ebp)
80100e01:	ff 75 d4             	push   -0x2c(%ebp)
80100e04:	e8 58 6f 00 00       	call   80107d61 <copyout>
80100e09:	83 c4 10             	add    $0x10,%esp
80100e0c:	85 c0                	test   %eax,%eax
80100e0e:	0f 88 6c 01 00 00    	js     80100f80 <exec+0x400>
      goto bad;
    ustack[3+argc] = sp;
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	8d 50 03             	lea    0x3(%eax),%edx
80100e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1d:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e24:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e35:	01 d0                	add    %edx,%eax
80100e37:	8b 00                	mov    (%eax),%eax
80100e39:	85 c0                	test   %eax,%eax
80100e3b:	0f 85 51 ff ff ff    	jne    80100d92 <exec+0x212>
  }
  ustack[3+argc] = 0;
80100e41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e44:	83 c0 03             	add    $0x3,%eax
80100e47:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e4e:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e52:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e59:	ff ff ff 
  ustack[1] = argc;
80100e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5f:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e68:	83 c0 01             	add    $0x1,%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e75:	29 d0                	sub    %edx,%eax
80100e77:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 04             	add    $0x4,%eax
80100e83:	c1 e0 02             	shl    $0x2,%eax
80100e86:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0){
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	83 c0 04             	add    $0x4,%eax
80100e8f:	c1 e0 02             	shl    $0x2,%eax
80100e92:	50                   	push   %eax
80100e93:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e99:	50                   	push   %eax
80100e9a:	ff 75 dc             	push   -0x24(%ebp)
80100e9d:	ff 75 d4             	push   -0x2c(%ebp)
80100ea0:	e8 bc 6e 00 00       	call   80107d61 <copyout>
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 c0                	test   %eax,%eax
80100eaa:	79 15                	jns    80100ec1 <exec+0x341>
    cprintf("[exec] copyout of ustack failed\n");
80100eac:	83 ec 0c             	sub    $0xc,%esp
80100eaf:	68 24 a3 10 80       	push   $0x8010a324
80100eb4:	e8 3b f5 ff ff       	call   801003f4 <cprintf>
80100eb9:	83 c4 10             	add    $0x10,%esp
    goto bad;
80100ebc:	e9 c0 00 00 00       	jmp    80100f81 <exec+0x401>

  }

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ecd:	eb 17                	jmp    80100ee6 <exec+0x366>
    if(*s == '/')
80100ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed2:	0f b6 00             	movzbl (%eax),%eax
80100ed5:	3c 2f                	cmp    $0x2f,%al
80100ed7:	75 09                	jne    80100ee2 <exec+0x362>
      last = s+1;
80100ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edc:	83 c0 01             	add    $0x1,%eax
80100edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee9:	0f b6 00             	movzbl (%eax),%eax
80100eec:	84 c0                	test   %al,%al
80100eee:	75 df                	jne    80100ecf <exec+0x34f>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef3:	83 c0 6c             	add    $0x6c,%eax
80100ef6:	83 ec 04             	sub    $0x4,%esp
80100ef9:	6a 10                	push   $0x10
80100efb:	ff 75 f0             	push   -0x10(%ebp)
80100efe:	50                   	push   %eax
80100eff:	e8 b8 3d 00 00       	call   80104cbc <safestrcpy>
80100f04:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f07:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0a:	8b 40 04             	mov    0x4(%eax),%eax
80100f0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f16:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f19:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f1f:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 40 18             	mov    0x18(%eax),%eax
80100f27:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f2d:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f33:	8b 40 18             	mov    0x18(%eax),%eax
80100f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f39:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f3c:	83 ec 0c             	sub    $0xc,%esp
80100f3f:	ff 75 d0             	push   -0x30(%ebp)
80100f42:	e8 22 67 00 00       	call   80107669 <switchuvm>
80100f47:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4a:	83 ec 0c             	sub    $0xc,%esp
80100f4d:	ff 75 cc             	push   -0x34(%ebp)
80100f50:	e8 b9 6b 00 00       	call   80107b0e <freevm>
80100f55:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f58:	b8 00 00 00 00       	mov    $0x0,%eax
80100f5d:	eb 54                	jmp    80100fb3 <exec+0x433>
    goto bad;
80100f5f:	90                   	nop
80100f60:	eb 1f                	jmp    80100f81 <exec+0x401>
    goto bad;
80100f62:	90                   	nop
80100f63:	eb 1c                	jmp    80100f81 <exec+0x401>
    goto bad;
80100f65:	90                   	nop
80100f66:	eb 19                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f68:	90                   	nop
80100f69:	eb 16                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 13                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 10                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f71:	90                   	nop
80100f72:	eb 0d                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f74:	90                   	nop
80100f75:	eb 0a                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f77:	90                   	nop
80100f78:	eb 07                	jmp    80100f81 <exec+0x401>
    goto bad;
80100f7a:	90                   	nop
80100f7b:	eb 04                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f7d:	90                   	nop
80100f7e:	eb 01                	jmp    80100f81 <exec+0x401>
      goto bad;
80100f80:	90                   	nop

 bad:
  if(pgdir)
80100f81:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f85:	74 0e                	je     80100f95 <exec+0x415>
    freevm(pgdir);
80100f87:	83 ec 0c             	sub    $0xc,%esp
80100f8a:	ff 75 d4             	push   -0x2c(%ebp)
80100f8d:	e8 7c 6b 00 00       	call   80107b0e <freevm>
80100f92:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f95:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f99:	74 13                	je     80100fae <exec+0x42e>
    iunlockput(ip);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d8             	push   -0x28(%ebp)
80100fa1:	e8 6b 0c 00 00       	call   80101c11 <iunlockput>
80100fa6:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fa9:	e8 10 21 00 00       	call   801030be <end_op>
  }
  return -1;
80100fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fb3:	c9                   	leave  
80100fb4:	c3                   	ret    

80100fb5 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fb5:	55                   	push   %ebp
80100fb6:	89 e5                	mov    %esp,%ebp
80100fb8:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fbb:	83 ec 08             	sub    $0x8,%esp
80100fbe:	68 45 a3 10 80       	push   $0x8010a345
80100fc3:	68 a0 1a 19 80       	push   $0x80191aa0
80100fc8:	e8 54 38 00 00       	call   80104821 <initlock>
80100fcd:	83 c4 10             	add    $0x10,%esp
}
80100fd0:	90                   	nop
80100fd1:	c9                   	leave  
80100fd2:	c3                   	ret    

80100fd3 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fd3:	55                   	push   %ebp
80100fd4:	89 e5                	mov    %esp,%ebp
80100fd6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fd9:	83 ec 0c             	sub    $0xc,%esp
80100fdc:	68 a0 1a 19 80       	push   $0x80191aa0
80100fe1:	e8 5d 38 00 00       	call   80104843 <acquire>
80100fe6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe9:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ff0:	eb 2d                	jmp    8010101f <filealloc+0x4c>
    if(f->ref == 0){
80100ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff5:	8b 40 04             	mov    0x4(%eax),%eax
80100ff8:	85 c0                	test   %eax,%eax
80100ffa:	75 1f                	jne    8010101b <filealloc+0x48>
      f->ref = 1;
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 a0 1a 19 80       	push   $0x80191aa0
8010100e:	e8 9e 38 00 00       	call   801048b1 <release>
80101013:	83 c4 10             	add    $0x10,%esp
      return f;
80101016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101019:	eb 23                	jmp    8010103e <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010101b:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010101f:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101024:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101027:	72 c9                	jb     80100ff2 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101029:	83 ec 0c             	sub    $0xc,%esp
8010102c:	68 a0 1a 19 80       	push   $0x80191aa0
80101031:	e8 7b 38 00 00       	call   801048b1 <release>
80101036:	83 c4 10             	add    $0x10,%esp
  return 0;
80101039:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010103e:	c9                   	leave  
8010103f:	c3                   	ret    

80101040 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101040:	55                   	push   %ebp
80101041:	89 e5                	mov    %esp,%ebp
80101043:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101046:	83 ec 0c             	sub    $0xc,%esp
80101049:	68 a0 1a 19 80       	push   $0x80191aa0
8010104e:	e8 f0 37 00 00       	call   80104843 <acquire>
80101053:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101056:	8b 45 08             	mov    0x8(%ebp),%eax
80101059:	8b 40 04             	mov    0x4(%eax),%eax
8010105c:	85 c0                	test   %eax,%eax
8010105e:	7f 0d                	jg     8010106d <filedup+0x2d>
    panic("filedup");
80101060:	83 ec 0c             	sub    $0xc,%esp
80101063:	68 4c a3 10 80       	push   $0x8010a34c
80101068:	e8 3c f5 ff ff       	call   801005a9 <panic>
  f->ref++;
8010106d:	8b 45 08             	mov    0x8(%ebp),%eax
80101070:	8b 40 04             	mov    0x4(%eax),%eax
80101073:	8d 50 01             	lea    0x1(%eax),%edx
80101076:	8b 45 08             	mov    0x8(%ebp),%eax
80101079:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 a0 1a 19 80       	push   $0x80191aa0
80101084:	e8 28 38 00 00       	call   801048b1 <release>
80101089:	83 c4 10             	add    $0x10,%esp
  return f;
8010108c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010108f:	c9                   	leave  
80101090:	c3                   	ret    

80101091 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101091:	55                   	push   %ebp
80101092:	89 e5                	mov    %esp,%ebp
80101094:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 a0 1a 19 80       	push   $0x80191aa0
8010109f:	e8 9f 37 00 00       	call   80104843 <acquire>
801010a4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a7:	8b 45 08             	mov    0x8(%ebp),%eax
801010aa:	8b 40 04             	mov    0x4(%eax),%eax
801010ad:	85 c0                	test   %eax,%eax
801010af:	7f 0d                	jg     801010be <fileclose+0x2d>
    panic("fileclose");
801010b1:	83 ec 0c             	sub    $0xc,%esp
801010b4:	68 54 a3 10 80       	push   $0x8010a354
801010b9:	e8 eb f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	8d 50 ff             	lea    -0x1(%eax),%edx
801010c7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ca:	89 50 04             	mov    %edx,0x4(%eax)
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	8b 40 04             	mov    0x4(%eax),%eax
801010d3:	85 c0                	test   %eax,%eax
801010d5:	7e 15                	jle    801010ec <fileclose+0x5b>
    release(&ftable.lock);
801010d7:	83 ec 0c             	sub    $0xc,%esp
801010da:	68 a0 1a 19 80       	push   $0x80191aa0
801010df:	e8 cd 37 00 00       	call   801048b1 <release>
801010e4:	83 c4 10             	add    $0x10,%esp
801010e7:	e9 8b 00 00 00       	jmp    80101177 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 10                	mov    (%eax),%edx
801010f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010f4:	8b 50 04             	mov    0x4(%eax),%edx
801010f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010fa:	8b 50 08             	mov    0x8(%eax),%edx
801010fd:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101100:	8b 50 0c             	mov    0xc(%eax),%edx
80101103:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101106:	8b 50 10             	mov    0x10(%eax),%edx
80101109:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010110c:	8b 40 14             	mov    0x14(%eax),%eax
8010110f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101112:	8b 45 08             	mov    0x8(%ebp),%eax
80101115:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101125:	83 ec 0c             	sub    $0xc,%esp
80101128:	68 a0 1a 19 80       	push   $0x80191aa0
8010112d:	e8 7f 37 00 00       	call   801048b1 <release>
80101132:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101135:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101138:	83 f8 01             	cmp    $0x1,%eax
8010113b:	75 19                	jne    80101156 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010113d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101141:	0f be d0             	movsbl %al,%edx
80101144:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101147:	83 ec 08             	sub    $0x8,%esp
8010114a:	52                   	push   %edx
8010114b:	50                   	push   %eax
8010114c:	e8 64 25 00 00       	call   801036b5 <pipeclose>
80101151:	83 c4 10             	add    $0x10,%esp
80101154:	eb 21                	jmp    80101177 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101156:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101159:	83 f8 02             	cmp    $0x2,%eax
8010115c:	75 19                	jne    80101177 <fileclose+0xe6>
    begin_op();
8010115e:	e8 cf 1e 00 00       	call   80103032 <begin_op>
    iput(ff.ip);
80101163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101166:	83 ec 0c             	sub    $0xc,%esp
80101169:	50                   	push   %eax
8010116a:	e8 d2 09 00 00       	call   80101b41 <iput>
8010116f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101172:	e8 47 1f 00 00       	call   801030be <end_op>
  }
}
80101177:	c9                   	leave  
80101178:	c3                   	ret    

80101179 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101179:	55                   	push   %ebp
8010117a:	89 e5                	mov    %esp,%ebp
8010117c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
80101182:	8b 00                	mov    (%eax),%eax
80101184:	83 f8 02             	cmp    $0x2,%eax
80101187:	75 40                	jne    801011c9 <filestat+0x50>
    ilock(f->ip);
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 40 10             	mov    0x10(%eax),%eax
8010118f:	83 ec 0c             	sub    $0xc,%esp
80101192:	50                   	push   %eax
80101193:	e8 48 08 00 00       	call   801019e0 <ilock>
80101198:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010119b:	8b 45 08             	mov    0x8(%ebp),%eax
8010119e:	8b 40 10             	mov    0x10(%eax),%eax
801011a1:	83 ec 08             	sub    $0x8,%esp
801011a4:	ff 75 0c             	push   0xc(%ebp)
801011a7:	50                   	push   %eax
801011a8:	e8 d9 0c 00 00       	call   80101e86 <stati>
801011ad:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011b0:	8b 45 08             	mov    0x8(%ebp),%eax
801011b3:	8b 40 10             	mov    0x10(%eax),%eax
801011b6:	83 ec 0c             	sub    $0xc,%esp
801011b9:	50                   	push   %eax
801011ba:	e8 34 09 00 00       	call   80101af3 <iunlock>
801011bf:	83 c4 10             	add    $0x10,%esp
    return 0;
801011c2:	b8 00 00 00 00       	mov    $0x0,%eax
801011c7:	eb 05                	jmp    801011ce <filestat+0x55>
  }
  return -1;
801011c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011ce:	c9                   	leave  
801011cf:	c3                   	ret    

801011d0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011d0:	55                   	push   %ebp
801011d1:	89 e5                	mov    %esp,%ebp
801011d3:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011dd:	84 c0                	test   %al,%al
801011df:	75 0a                	jne    801011eb <fileread+0x1b>
    return -1;
801011e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e6:	e9 9b 00 00 00       	jmp    80101286 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011eb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ee:	8b 00                	mov    (%eax),%eax
801011f0:	83 f8 01             	cmp    $0x1,%eax
801011f3:	75 1a                	jne    8010120f <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 40 0c             	mov    0xc(%eax),%eax
801011fb:	83 ec 04             	sub    $0x4,%esp
801011fe:	ff 75 10             	push   0x10(%ebp)
80101201:	ff 75 0c             	push   0xc(%ebp)
80101204:	50                   	push   %eax
80101205:	e8 58 26 00 00       	call   80103862 <piperead>
8010120a:	83 c4 10             	add    $0x10,%esp
8010120d:	eb 77                	jmp    80101286 <fileread+0xb6>
  if(f->type == FD_INODE){
8010120f:	8b 45 08             	mov    0x8(%ebp),%eax
80101212:	8b 00                	mov    (%eax),%eax
80101214:	83 f8 02             	cmp    $0x2,%eax
80101217:	75 60                	jne    80101279 <fileread+0xa9>
    ilock(f->ip);
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 40 10             	mov    0x10(%eax),%eax
8010121f:	83 ec 0c             	sub    $0xc,%esp
80101222:	50                   	push   %eax
80101223:	e8 b8 07 00 00       	call   801019e0 <ilock>
80101228:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010122b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010122e:	8b 45 08             	mov    0x8(%ebp),%eax
80101231:	8b 50 14             	mov    0x14(%eax),%edx
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 40 10             	mov    0x10(%eax),%eax
8010123a:	51                   	push   %ecx
8010123b:	52                   	push   %edx
8010123c:	ff 75 0c             	push   0xc(%ebp)
8010123f:	50                   	push   %eax
80101240:	e8 87 0c 00 00       	call   80101ecc <readi>
80101245:	83 c4 10             	add    $0x10,%esp
80101248:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010124b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010124f:	7e 11                	jle    80101262 <fileread+0x92>
      f->off += r;
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	8b 50 14             	mov    0x14(%eax),%edx
80101257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125a:	01 c2                	add    %eax,%edx
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101262:	8b 45 08             	mov    0x8(%ebp),%eax
80101265:	8b 40 10             	mov    0x10(%eax),%eax
80101268:	83 ec 0c             	sub    $0xc,%esp
8010126b:	50                   	push   %eax
8010126c:	e8 82 08 00 00       	call   80101af3 <iunlock>
80101271:	83 c4 10             	add    $0x10,%esp
    return r;
80101274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101277:	eb 0d                	jmp    80101286 <fileread+0xb6>
  }
  panic("fileread");
80101279:	83 ec 0c             	sub    $0xc,%esp
8010127c:	68 5e a3 10 80       	push   $0x8010a35e
80101281:	e8 23 f3 ff ff       	call   801005a9 <panic>
}
80101286:	c9                   	leave  
80101287:	c3                   	ret    

80101288 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101288:	55                   	push   %ebp
80101289:	89 e5                	mov    %esp,%ebp
8010128b:	53                   	push   %ebx
8010128c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010128f:	8b 45 08             	mov    0x8(%ebp),%eax
80101292:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101296:	84 c0                	test   %al,%al
80101298:	75 0a                	jne    801012a4 <filewrite+0x1c>
    return -1;
8010129a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010129f:	e9 1b 01 00 00       	jmp    801013bf <filewrite+0x137>
  if(f->type == FD_PIPE)
801012a4:	8b 45 08             	mov    0x8(%ebp),%eax
801012a7:	8b 00                	mov    (%eax),%eax
801012a9:	83 f8 01             	cmp    $0x1,%eax
801012ac:	75 1d                	jne    801012cb <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 40 0c             	mov    0xc(%eax),%eax
801012b4:	83 ec 04             	sub    $0x4,%esp
801012b7:	ff 75 10             	push   0x10(%ebp)
801012ba:	ff 75 0c             	push   0xc(%ebp)
801012bd:	50                   	push   %eax
801012be:	e8 9d 24 00 00       	call   80103760 <pipewrite>
801012c3:	83 c4 10             	add    $0x10,%esp
801012c6:	e9 f4 00 00 00       	jmp    801013bf <filewrite+0x137>
  if(f->type == FD_INODE){
801012cb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ce:	8b 00                	mov    (%eax),%eax
801012d0:	83 f8 02             	cmp    $0x2,%eax
801012d3:	0f 85 d9 00 00 00    	jne    801013b2 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012d9:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012e7:	e9 a3 00 00 00       	jmp    8010138f <filewrite+0x107>
      int n1 = n - i;
801012ec:	8b 45 10             	mov    0x10(%ebp),%eax
801012ef:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012fb:	7e 06                	jle    80101303 <filewrite+0x7b>
        n1 = max;
801012fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101300:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101303:	e8 2a 1d 00 00       	call   80103032 <begin_op>
      ilock(f->ip);
80101308:	8b 45 08             	mov    0x8(%ebp),%eax
8010130b:	8b 40 10             	mov    0x10(%eax),%eax
8010130e:	83 ec 0c             	sub    $0xc,%esp
80101311:	50                   	push   %eax
80101312:	e8 c9 06 00 00       	call   801019e0 <ilock>
80101317:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010131a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	8b 50 14             	mov    0x14(%eax),%edx
80101323:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101326:	8b 45 0c             	mov    0xc(%ebp),%eax
80101329:	01 c3                	add    %eax,%ebx
8010132b:	8b 45 08             	mov    0x8(%ebp),%eax
8010132e:	8b 40 10             	mov    0x10(%eax),%eax
80101331:	51                   	push   %ecx
80101332:	52                   	push   %edx
80101333:	53                   	push   %ebx
80101334:	50                   	push   %eax
80101335:	e8 e7 0c 00 00       	call   80102021 <writei>
8010133a:	83 c4 10             	add    $0x10,%esp
8010133d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101340:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101344:	7e 11                	jle    80101357 <filewrite+0xcf>
        f->off += r;
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 50 14             	mov    0x14(%eax),%edx
8010134c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134f:	01 c2                	add    %eax,%edx
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	8b 40 10             	mov    0x10(%eax),%eax
8010135d:	83 ec 0c             	sub    $0xc,%esp
80101360:	50                   	push   %eax
80101361:	e8 8d 07 00 00       	call   80101af3 <iunlock>
80101366:	83 c4 10             	add    $0x10,%esp
      end_op();
80101369:	e8 50 1d 00 00       	call   801030be <end_op>

      if(r < 0)
8010136e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101372:	78 29                	js     8010139d <filewrite+0x115>
        break;
      if(r != n1)
80101374:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101377:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010137a:	74 0d                	je     80101389 <filewrite+0x101>
        panic("short filewrite");
8010137c:	83 ec 0c             	sub    $0xc,%esp
8010137f:	68 67 a3 10 80       	push   $0x8010a367
80101384:	e8 20 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101389:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138c:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	3b 45 10             	cmp    0x10(%ebp),%eax
80101395:	0f 8c 51 ff ff ff    	jl     801012ec <filewrite+0x64>
8010139b:	eb 01                	jmp    8010139e <filewrite+0x116>
        break;
8010139d:	90                   	nop
    }
    return i == n ? n : -1;
8010139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a1:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a4:	75 05                	jne    801013ab <filewrite+0x123>
801013a6:	8b 45 10             	mov    0x10(%ebp),%eax
801013a9:	eb 14                	jmp    801013bf <filewrite+0x137>
801013ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013b0:	eb 0d                	jmp    801013bf <filewrite+0x137>
  }
  panic("filewrite");
801013b2:	83 ec 0c             	sub    $0xc,%esp
801013b5:	68 77 a3 10 80       	push   $0x8010a377
801013ba:	e8 ea f1 ff ff       	call   801005a9 <panic>
}
801013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013c2:	c9                   	leave  
801013c3:	c3                   	ret    

801013c4 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013c4:	55                   	push   %ebp
801013c5:	89 e5                	mov    %esp,%ebp
801013c7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013ca:	8b 45 08             	mov    0x8(%ebp),%eax
801013cd:	83 ec 08             	sub    $0x8,%esp
801013d0:	6a 01                	push   $0x1
801013d2:	50                   	push   %eax
801013d3:	e8 29 ee ff ff       	call   80100201 <bread>
801013d8:	83 c4 10             	add    $0x10,%esp
801013db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e1:	83 c0 5c             	add    $0x5c,%eax
801013e4:	83 ec 04             	sub    $0x4,%esp
801013e7:	6a 1c                	push   $0x1c
801013e9:	50                   	push   %eax
801013ea:	ff 75 0c             	push   0xc(%ebp)
801013ed:	e8 86 37 00 00       	call   80104b78 <memmove>
801013f2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013f5:	83 ec 0c             	sub    $0xc,%esp
801013f8:	ff 75 f4             	push   -0xc(%ebp)
801013fb:	e8 83 ee ff ff       	call   80100283 <brelse>
80101400:	83 c4 10             	add    $0x10,%esp
}
80101403:	90                   	nop
80101404:	c9                   	leave  
80101405:	c3                   	ret    

80101406 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101406:	55                   	push   %ebp
80101407:	89 e5                	mov    %esp,%ebp
80101409:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010140c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010140f:	8b 45 08             	mov    0x8(%ebp),%eax
80101412:	83 ec 08             	sub    $0x8,%esp
80101415:	52                   	push   %edx
80101416:	50                   	push   %eax
80101417:	e8 e5 ed ff ff       	call   80100201 <bread>
8010141c:	83 c4 10             	add    $0x10,%esp
8010141f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101425:	83 c0 5c             	add    $0x5c,%eax
80101428:	83 ec 04             	sub    $0x4,%esp
8010142b:	68 00 02 00 00       	push   $0x200
80101430:	6a 00                	push   $0x0
80101432:	50                   	push   %eax
80101433:	e8 81 36 00 00       	call   80104ab9 <memset>
80101438:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010143b:	83 ec 0c             	sub    $0xc,%esp
8010143e:	ff 75 f4             	push   -0xc(%ebp)
80101441:	e8 25 1e 00 00       	call   8010326b <log_write>
80101446:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101449:	83 ec 0c             	sub    $0xc,%esp
8010144c:	ff 75 f4             	push   -0xc(%ebp)
8010144f:	e8 2f ee ff ff       	call   80100283 <brelse>
80101454:	83 c4 10             	add    $0x10,%esp
}
80101457:	90                   	nop
80101458:	c9                   	leave  
80101459:	c3                   	ret    

8010145a <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010145a:	55                   	push   %ebp
8010145b:	89 e5                	mov    %esp,%ebp
8010145d:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101460:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101467:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010146e:	e9 0b 01 00 00       	jmp    8010157e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101476:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010147c:	85 c0                	test   %eax,%eax
8010147e:	0f 48 c2             	cmovs  %edx,%eax
80101481:	c1 f8 0c             	sar    $0xc,%eax
80101484:	89 c2                	mov    %eax,%edx
80101486:	a1 58 24 19 80       	mov    0x80192458,%eax
8010148b:	01 d0                	add    %edx,%eax
8010148d:	83 ec 08             	sub    $0x8,%esp
80101490:	50                   	push   %eax
80101491:	ff 75 08             	push   0x8(%ebp)
80101494:	e8 68 ed ff ff       	call   80100201 <bread>
80101499:	83 c4 10             	add    $0x10,%esp
8010149c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014a6:	e9 9e 00 00 00       	jmp    80101549 <balloc+0xef>
      m = 1 << (bi % 8);
801014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ae:	83 e0 07             	and    $0x7,%eax
801014b1:	ba 01 00 00 00       	mov    $0x1,%edx
801014b6:	89 c1                	mov    %eax,%ecx
801014b8:	d3 e2                	shl    %cl,%edx
801014ba:	89 d0                	mov    %edx,%eax
801014bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	8d 50 07             	lea    0x7(%eax),%edx
801014c5:	85 c0                	test   %eax,%eax
801014c7:	0f 48 c2             	cmovs  %edx,%eax
801014ca:	c1 f8 03             	sar    $0x3,%eax
801014cd:	89 c2                	mov    %eax,%edx
801014cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014d2:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014d7:	0f b6 c0             	movzbl %al,%eax
801014da:	23 45 e8             	and    -0x18(%ebp),%eax
801014dd:	85 c0                	test   %eax,%eax
801014df:	75 64                	jne    80101545 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e4:	8d 50 07             	lea    0x7(%eax),%edx
801014e7:	85 c0                	test   %eax,%eax
801014e9:	0f 48 c2             	cmovs  %edx,%eax
801014ec:	c1 f8 03             	sar    $0x3,%eax
801014ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f2:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014f7:	89 d1                	mov    %edx,%ecx
801014f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014fc:	09 ca                	or     %ecx,%edx
801014fe:	89 d1                	mov    %edx,%ecx
80101500:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101503:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101507:	83 ec 0c             	sub    $0xc,%esp
8010150a:	ff 75 ec             	push   -0x14(%ebp)
8010150d:	e8 59 1d 00 00       	call   8010326b <log_write>
80101512:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101515:	83 ec 0c             	sub    $0xc,%esp
80101518:	ff 75 ec             	push   -0x14(%ebp)
8010151b:	e8 63 ed ff ff       	call   80100283 <brelse>
80101520:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	01 c2                	add    %eax,%edx
8010152b:	8b 45 08             	mov    0x8(%ebp),%eax
8010152e:	83 ec 08             	sub    $0x8,%esp
80101531:	52                   	push   %edx
80101532:	50                   	push   %eax
80101533:	e8 ce fe ff ff       	call   80101406 <bzero>
80101538:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010153b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101541:	01 d0                	add    %edx,%eax
80101543:	eb 57                	jmp    8010159c <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101545:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101549:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101550:	7f 17                	jg     80101569 <balloc+0x10f>
80101552:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101558:	01 d0                	add    %edx,%eax
8010155a:	89 c2                	mov    %eax,%edx
8010155c:	a1 40 24 19 80       	mov    0x80192440,%eax
80101561:	39 c2                	cmp    %eax,%edx
80101563:	0f 82 42 ff ff ff    	jb     801014ab <balloc+0x51>
      }
    }
    brelse(bp);
80101569:	83 ec 0c             	sub    $0xc,%esp
8010156c:	ff 75 ec             	push   -0x14(%ebp)
8010156f:	e8 0f ed ff ff       	call   80100283 <brelse>
80101574:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101577:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010157e:	8b 15 40 24 19 80    	mov    0x80192440,%edx
80101584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101587:	39 c2                	cmp    %eax,%edx
80101589:	0f 87 e4 fe ff ff    	ja     80101473 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010158f:	83 ec 0c             	sub    $0xc,%esp
80101592:	68 84 a3 10 80       	push   $0x8010a384
80101597:	e8 0d f0 ff ff       	call   801005a9 <panic>
}
8010159c:	c9                   	leave  
8010159d:	c3                   	ret    

8010159e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010159e:	55                   	push   %ebp
8010159f:	89 e5                	mov    %esp,%ebp
801015a1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015a4:	83 ec 08             	sub    $0x8,%esp
801015a7:	68 40 24 19 80       	push   $0x80192440
801015ac:	ff 75 08             	push   0x8(%ebp)
801015af:	e8 10 fe ff ff       	call   801013c4 <readsb>
801015b4:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ba:	c1 e8 0c             	shr    $0xc,%eax
801015bd:	89 c2                	mov    %eax,%edx
801015bf:	a1 58 24 19 80       	mov    0x80192458,%eax
801015c4:	01 c2                	add    %eax,%edx
801015c6:	8b 45 08             	mov    0x8(%ebp),%eax
801015c9:	83 ec 08             	sub    $0x8,%esp
801015cc:	52                   	push   %edx
801015cd:	50                   	push   %eax
801015ce:	e8 2e ec ff ff       	call   80100201 <bread>
801015d3:	83 c4 10             	add    $0x10,%esp
801015d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015dc:	25 ff 0f 00 00       	and    $0xfff,%eax
801015e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e7:	83 e0 07             	and    $0x7,%eax
801015ea:	ba 01 00 00 00       	mov    $0x1,%edx
801015ef:	89 c1                	mov    %eax,%ecx
801015f1:	d3 e2                	shl    %cl,%edx
801015f3:	89 d0                	mov    %edx,%eax
801015f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fb:	8d 50 07             	lea    0x7(%eax),%edx
801015fe:	85 c0                	test   %eax,%eax
80101600:	0f 48 c2             	cmovs  %edx,%eax
80101603:	c1 f8 03             	sar    $0x3,%eax
80101606:	89 c2                	mov    %eax,%edx
80101608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160b:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101610:	0f b6 c0             	movzbl %al,%eax
80101613:	23 45 ec             	and    -0x14(%ebp),%eax
80101616:	85 c0                	test   %eax,%eax
80101618:	75 0d                	jne    80101627 <bfree+0x89>
    panic("freeing free block");
8010161a:	83 ec 0c             	sub    $0xc,%esp
8010161d:	68 9a a3 10 80       	push   $0x8010a39a
80101622:	e8 82 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162a:	8d 50 07             	lea    0x7(%eax),%edx
8010162d:	85 c0                	test   %eax,%eax
8010162f:	0f 48 c2             	cmovs  %edx,%eax
80101632:	c1 f8 03             	sar    $0x3,%eax
80101635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101638:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010163d:	89 d1                	mov    %edx,%ecx
8010163f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101642:	f7 d2                	not    %edx
80101644:	21 ca                	and    %ecx,%edx
80101646:	89 d1                	mov    %edx,%ecx
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010164f:	83 ec 0c             	sub    $0xc,%esp
80101652:	ff 75 f4             	push   -0xc(%ebp)
80101655:	e8 11 1c 00 00       	call   8010326b <log_write>
8010165a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010165d:	83 ec 0c             	sub    $0xc,%esp
80101660:	ff 75 f4             	push   -0xc(%ebp)
80101663:	e8 1b ec ff ff       	call   80100283 <brelse>
80101668:	83 c4 10             	add    $0x10,%esp
}
8010166b:	90                   	nop
8010166c:	c9                   	leave  
8010166d:	c3                   	ret    

8010166e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010166e:	55                   	push   %ebp
8010166f:	89 e5                	mov    %esp,%ebp
80101671:	57                   	push   %edi
80101672:	56                   	push   %esi
80101673:	53                   	push   %ebx
80101674:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101677:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010167e:	83 ec 08             	sub    $0x8,%esp
80101681:	68 ad a3 10 80       	push   $0x8010a3ad
80101686:	68 60 24 19 80       	push   $0x80192460
8010168b:	e8 91 31 00 00       	call   80104821 <initlock>
80101690:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101693:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010169a:	eb 2d                	jmp    801016c9 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
8010169c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010169f:	89 d0                	mov    %edx,%eax
801016a1:	c1 e0 03             	shl    $0x3,%eax
801016a4:	01 d0                	add    %edx,%eax
801016a6:	c1 e0 04             	shl    $0x4,%eax
801016a9:	83 c0 30             	add    $0x30,%eax
801016ac:	05 60 24 19 80       	add    $0x80192460,%eax
801016b1:	83 c0 10             	add    $0x10,%eax
801016b4:	83 ec 08             	sub    $0x8,%esp
801016b7:	68 b4 a3 10 80       	push   $0x8010a3b4
801016bc:	50                   	push   %eax
801016bd:	e8 02 30 00 00       	call   801046c4 <initsleeplock>
801016c2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016c5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016c9:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016cd:	7e cd                	jle    8010169c <iinit+0x2e>
  }

  readsb(dev, &sb);
801016cf:	83 ec 08             	sub    $0x8,%esp
801016d2:	68 40 24 19 80       	push   $0x80192440
801016d7:	ff 75 08             	push   0x8(%ebp)
801016da:	e8 e5 fc ff ff       	call   801013c4 <readsb>
801016df:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016e2:	a1 58 24 19 80       	mov    0x80192458,%eax
801016e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016ea:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016f0:	8b 35 50 24 19 80    	mov    0x80192450,%esi
801016f6:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
801016fc:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101702:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101708:	a1 40 24 19 80       	mov    0x80192440,%eax
8010170d:	ff 75 d4             	push   -0x2c(%ebp)
80101710:	57                   	push   %edi
80101711:	56                   	push   %esi
80101712:	53                   	push   %ebx
80101713:	51                   	push   %ecx
80101714:	52                   	push   %edx
80101715:	50                   	push   %eax
80101716:	68 bc a3 10 80       	push   $0x8010a3bc
8010171b:	e8 d4 ec ff ff       	call   801003f4 <cprintf>
80101720:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101723:	90                   	nop
80101724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101727:	5b                   	pop    %ebx
80101728:	5e                   	pop    %esi
80101729:	5f                   	pop    %edi
8010172a:	5d                   	pop    %ebp
8010172b:	c3                   	ret    

8010172c <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010172c:	55                   	push   %ebp
8010172d:	89 e5                	mov    %esp,%ebp
8010172f:	83 ec 28             	sub    $0x28,%esp
80101732:	8b 45 0c             	mov    0xc(%ebp),%eax
80101735:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101739:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101740:	e9 9e 00 00 00       	jmp    801017e3 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101748:	c1 e8 03             	shr    $0x3,%eax
8010174b:	89 c2                	mov    %eax,%edx
8010174d:	a1 54 24 19 80       	mov    0x80192454,%eax
80101752:	01 d0                	add    %edx,%eax
80101754:	83 ec 08             	sub    $0x8,%esp
80101757:	50                   	push   %eax
80101758:	ff 75 08             	push   0x8(%ebp)
8010175b:	e8 a1 ea ff ff       	call   80100201 <bread>
80101760:	83 c4 10             	add    $0x10,%esp
80101763:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101769:	8d 50 5c             	lea    0x5c(%eax),%edx
8010176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176f:	83 e0 07             	and    $0x7,%eax
80101772:	c1 e0 06             	shl    $0x6,%eax
80101775:	01 d0                	add    %edx,%eax
80101777:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010177a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010177d:	0f b7 00             	movzwl (%eax),%eax
80101780:	66 85 c0             	test   %ax,%ax
80101783:	75 4c                	jne    801017d1 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101785:	83 ec 04             	sub    $0x4,%esp
80101788:	6a 40                	push   $0x40
8010178a:	6a 00                	push   $0x0
8010178c:	ff 75 ec             	push   -0x14(%ebp)
8010178f:	e8 25 33 00 00       	call   80104ab9 <memset>
80101794:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010179a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010179e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017a1:	83 ec 0c             	sub    $0xc,%esp
801017a4:	ff 75 f0             	push   -0x10(%ebp)
801017a7:	e8 bf 1a 00 00       	call   8010326b <log_write>
801017ac:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017af:	83 ec 0c             	sub    $0xc,%esp
801017b2:	ff 75 f0             	push   -0x10(%ebp)
801017b5:	e8 c9 ea ff ff       	call   80100283 <brelse>
801017ba:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	83 ec 08             	sub    $0x8,%esp
801017c3:	50                   	push   %eax
801017c4:	ff 75 08             	push   0x8(%ebp)
801017c7:	e8 f8 00 00 00       	call   801018c4 <iget>
801017cc:	83 c4 10             	add    $0x10,%esp
801017cf:	eb 30                	jmp    80101801 <ialloc+0xd5>
    }
    brelse(bp);
801017d1:	83 ec 0c             	sub    $0xc,%esp
801017d4:	ff 75 f0             	push   -0x10(%ebp)
801017d7:	e8 a7 ea ff ff       	call   80100283 <brelse>
801017dc:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017e3:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ec:	39 c2                	cmp    %eax,%edx
801017ee:	0f 87 51 ff ff ff    	ja     80101745 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017f4:	83 ec 0c             	sub    $0xc,%esp
801017f7:	68 0f a4 10 80       	push   $0x8010a40f
801017fc:	e8 a8 ed ff ff       	call   801005a9 <panic>
}
80101801:	c9                   	leave  
80101802:	c3                   	ret    

80101803 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101803:	55                   	push   %ebp
80101804:	89 e5                	mov    %esp,%ebp
80101806:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101809:	8b 45 08             	mov    0x8(%ebp),%eax
8010180c:	8b 40 04             	mov    0x4(%eax),%eax
8010180f:	c1 e8 03             	shr    $0x3,%eax
80101812:	89 c2                	mov    %eax,%edx
80101814:	a1 54 24 19 80       	mov    0x80192454,%eax
80101819:	01 c2                	add    %eax,%edx
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 00                	mov    (%eax),%eax
80101820:	83 ec 08             	sub    $0x8,%esp
80101823:	52                   	push   %edx
80101824:	50                   	push   %eax
80101825:	e8 d7 e9 ff ff       	call   80100201 <bread>
8010182a:	83 c4 10             	add    $0x10,%esp
8010182d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101833:	8d 50 5c             	lea    0x5c(%eax),%edx
80101836:	8b 45 08             	mov    0x8(%ebp),%eax
80101839:	8b 40 04             	mov    0x4(%eax),%eax
8010183c:	83 e0 07             	and    $0x7,%eax
8010183f:	c1 e0 06             	shl    $0x6,%eax
80101842:	01 d0                	add    %edx,%eax
80101844:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101847:	8b 45 08             	mov    0x8(%ebp),%eax
8010184a:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010184e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101851:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010185b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101862:	8b 45 08             	mov    0x8(%ebp),%eax
80101865:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186c:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101870:	8b 45 08             	mov    0x8(%ebp),%eax
80101873:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187a:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010187e:	8b 45 08             	mov    0x8(%ebp),%eax
80101881:	8b 50 58             	mov    0x58(%eax),%edx
80101884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101887:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010188a:	8b 45 08             	mov    0x8(%ebp),%eax
8010188d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101893:	83 c0 0c             	add    $0xc,%eax
80101896:	83 ec 04             	sub    $0x4,%esp
80101899:	6a 34                	push   $0x34
8010189b:	52                   	push   %edx
8010189c:	50                   	push   %eax
8010189d:	e8 d6 32 00 00       	call   80104b78 <memmove>
801018a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	ff 75 f4             	push   -0xc(%ebp)
801018ab:	e8 bb 19 00 00       	call   8010326b <log_write>
801018b0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018b3:	83 ec 0c             	sub    $0xc,%esp
801018b6:	ff 75 f4             	push   -0xc(%ebp)
801018b9:	e8 c5 e9 ff ff       	call   80100283 <brelse>
801018be:	83 c4 10             	add    $0x10,%esp
}
801018c1:	90                   	nop
801018c2:	c9                   	leave  
801018c3:	c3                   	ret    

801018c4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018c4:	55                   	push   %ebp
801018c5:	89 e5                	mov    %esp,%ebp
801018c7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018ca:	83 ec 0c             	sub    $0xc,%esp
801018cd:	68 60 24 19 80       	push   $0x80192460
801018d2:	e8 6c 2f 00 00       	call   80104843 <acquire>
801018d7:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018e1:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018e8:	eb 60                	jmp    8010194a <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ed:	8b 40 08             	mov    0x8(%eax),%eax
801018f0:	85 c0                	test   %eax,%eax
801018f2:	7e 39                	jle    8010192d <iget+0x69>
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 00                	mov    (%eax),%eax
801018f9:	39 45 08             	cmp    %eax,0x8(%ebp)
801018fc:	75 2f                	jne    8010192d <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 40 04             	mov    0x4(%eax),%eax
80101904:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101907:	75 24                	jne    8010192d <iget+0x69>
      ip->ref++;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 40 08             	mov    0x8(%eax),%eax
8010190f:	8d 50 01             	lea    0x1(%eax),%edx
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101918:	83 ec 0c             	sub    $0xc,%esp
8010191b:	68 60 24 19 80       	push   $0x80192460
80101920:	e8 8c 2f 00 00       	call   801048b1 <release>
80101925:	83 c4 10             	add    $0x10,%esp
      return ip;
80101928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192b:	eb 77                	jmp    801019a4 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010192d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101931:	75 10                	jne    80101943 <iget+0x7f>
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	8b 40 08             	mov    0x8(%eax),%eax
80101939:	85 c0                	test   %eax,%eax
8010193b:	75 06                	jne    80101943 <iget+0x7f>
      empty = ip;
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101943:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010194a:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101951:	72 97                	jb     801018ea <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101953:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101957:	75 0d                	jne    80101966 <iget+0xa2>
    panic("iget: no inodes");
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	68 21 a4 10 80       	push   $0x8010a421
80101961:	e8 43 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101969:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196f:	8b 55 08             	mov    0x8(%ebp),%edx
80101972:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101977:	8b 55 0c             	mov    0xc(%ebp),%edx
8010197a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010197d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101980:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101991:	83 ec 0c             	sub    $0xc,%esp
80101994:	68 60 24 19 80       	push   $0x80192460
80101999:	e8 13 2f 00 00       	call   801048b1 <release>
8010199e:	83 c4 10             	add    $0x10,%esp

  return ip;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019a4:	c9                   	leave  
801019a5:	c3                   	ret    

801019a6 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019a6:	55                   	push   %ebp
801019a7:	89 e5                	mov    %esp,%ebp
801019a9:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019ac:	83 ec 0c             	sub    $0xc,%esp
801019af:	68 60 24 19 80       	push   $0x80192460
801019b4:	e8 8a 2e 00 00       	call   80104843 <acquire>
801019b9:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019bc:	8b 45 08             	mov    0x8(%ebp),%eax
801019bf:	8b 40 08             	mov    0x8(%eax),%eax
801019c2:	8d 50 01             	lea    0x1(%eax),%edx
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019cb:	83 ec 0c             	sub    $0xc,%esp
801019ce:	68 60 24 19 80       	push   $0x80192460
801019d3:	e8 d9 2e 00 00       	call   801048b1 <release>
801019d8:	83 c4 10             	add    $0x10,%esp
  return ip;
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019de:	c9                   	leave  
801019df:	c3                   	ret    

801019e0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019ea:	74 0a                	je     801019f6 <ilock+0x16>
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	8b 40 08             	mov    0x8(%eax),%eax
801019f2:	85 c0                	test   %eax,%eax
801019f4:	7f 0d                	jg     80101a03 <ilock+0x23>
    panic("ilock");
801019f6:	83 ec 0c             	sub    $0xc,%esp
801019f9:	68 31 a4 10 80       	push   $0x8010a431
801019fe:	e8 a6 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	83 c0 0c             	add    $0xc,%eax
80101a09:	83 ec 0c             	sub    $0xc,%esp
80101a0c:	50                   	push   %eax
80101a0d:	e8 ee 2c 00 00       	call   80104700 <acquiresleep>
80101a12:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a1b:	85 c0                	test   %eax,%eax
80101a1d:	0f 85 cd 00 00 00    	jne    80101af0 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a23:	8b 45 08             	mov    0x8(%ebp),%eax
80101a26:	8b 40 04             	mov    0x4(%eax),%eax
80101a29:	c1 e8 03             	shr    $0x3,%eax
80101a2c:	89 c2                	mov    %eax,%edx
80101a2e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a33:	01 c2                	add    %eax,%edx
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 00                	mov    (%eax),%eax
80101a3a:	83 ec 08             	sub    $0x8,%esp
80101a3d:	52                   	push   %edx
80101a3e:	50                   	push   %eax
80101a3f:	e8 bd e7 ff ff       	call   80100201 <bread>
80101a44:	83 c4 10             	add    $0x10,%esp
80101a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 04             	mov    0x4(%eax),%eax
80101a56:	83 e0 07             	and    $0x7,%eax
80101a59:	c1 e0 06             	shl    $0x6,%eax
80101a5c:	01 d0                	add    %edx,%eax
80101a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a64:	0f b7 10             	movzwl (%eax),%edx
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a71:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a83:	8b 45 08             	mov    0x8(%ebp),%eax
80101a86:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a91:	8b 45 08             	mov    0x8(%ebp),%eax
80101a94:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9b:	8b 50 08             	mov    0x8(%eax),%edx
80101a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa1:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa7:	8d 50 0c             	lea    0xc(%eax),%edx
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	83 c0 5c             	add    $0x5c,%eax
80101ab0:	83 ec 04             	sub    $0x4,%esp
80101ab3:	6a 34                	push   $0x34
80101ab5:	52                   	push   %edx
80101ab6:	50                   	push   %eax
80101ab7:	e8 bc 30 00 00       	call   80104b78 <memmove>
80101abc:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101abf:	83 ec 0c             	sub    $0xc,%esp
80101ac2:	ff 75 f4             	push   -0xc(%ebp)
80101ac5:	e8 b9 e7 ff ff       	call   80100283 <brelse>
80101aca:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101acd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad0:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ade:	66 85 c0             	test   %ax,%ax
80101ae1:	75 0d                	jne    80101af0 <ilock+0x110>
      panic("ilock: no type");
80101ae3:	83 ec 0c             	sub    $0xc,%esp
80101ae6:	68 37 a4 10 80       	push   $0x8010a437
80101aeb:	e8 b9 ea ff ff       	call   801005a9 <panic>
  }
}
80101af0:	90                   	nop
80101af1:	c9                   	leave  
80101af2:	c3                   	ret    

80101af3 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101af3:	55                   	push   %ebp
80101af4:	89 e5                	mov    %esp,%ebp
80101af6:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101af9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101afd:	74 20                	je     80101b1f <iunlock+0x2c>
80101aff:	8b 45 08             	mov    0x8(%ebp),%eax
80101b02:	83 c0 0c             	add    $0xc,%eax
80101b05:	83 ec 0c             	sub    $0xc,%esp
80101b08:	50                   	push   %eax
80101b09:	e8 a4 2c 00 00       	call   801047b2 <holdingsleep>
80101b0e:	83 c4 10             	add    $0x10,%esp
80101b11:	85 c0                	test   %eax,%eax
80101b13:	74 0a                	je     80101b1f <iunlock+0x2c>
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	8b 40 08             	mov    0x8(%eax),%eax
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	7f 0d                	jg     80101b2c <iunlock+0x39>
    panic("iunlock");
80101b1f:	83 ec 0c             	sub    $0xc,%esp
80101b22:	68 46 a4 10 80       	push   $0x8010a446
80101b27:	e8 7d ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	83 c0 0c             	add    $0xc,%eax
80101b32:	83 ec 0c             	sub    $0xc,%esp
80101b35:	50                   	push   %eax
80101b36:	e8 29 2c 00 00       	call   80104764 <releasesleep>
80101b3b:	83 c4 10             	add    $0x10,%esp
}
80101b3e:	90                   	nop
80101b3f:	c9                   	leave  
80101b40:	c3                   	ret    

80101b41 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b41:	55                   	push   %ebp
80101b42:	89 e5                	mov    %esp,%ebp
80101b44:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b47:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4a:	83 c0 0c             	add    $0xc,%eax
80101b4d:	83 ec 0c             	sub    $0xc,%esp
80101b50:	50                   	push   %eax
80101b51:	e8 aa 2b 00 00       	call   80104700 <acquiresleep>
80101b56:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5f:	85 c0                	test   %eax,%eax
80101b61:	74 6a                	je     80101bcd <iput+0x8c>
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b6a:	66 85 c0             	test   %ax,%ax
80101b6d:	75 5e                	jne    80101bcd <iput+0x8c>
    acquire(&icache.lock);
80101b6f:	83 ec 0c             	sub    $0xc,%esp
80101b72:	68 60 24 19 80       	push   $0x80192460
80101b77:	e8 c7 2c 00 00       	call   80104843 <acquire>
80101b7c:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 40 08             	mov    0x8(%eax),%eax
80101b85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	68 60 24 19 80       	push   $0x80192460
80101b90:	e8 1c 2d 00 00       	call   801048b1 <release>
80101b95:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b98:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b9c:	75 2f                	jne    80101bcd <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b9e:	83 ec 0c             	sub    $0xc,%esp
80101ba1:	ff 75 08             	push   0x8(%ebp)
80101ba4:	e8 ad 01 00 00       	call   80101d56 <itrunc>
80101ba9:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bac:	8b 45 08             	mov    0x8(%ebp),%eax
80101baf:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	ff 75 08             	push   0x8(%ebp)
80101bbb:	e8 43 fc ff ff       	call   80101803 <iupdate>
80101bc0:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	83 c0 0c             	add    $0xc,%eax
80101bd3:	83 ec 0c             	sub    $0xc,%esp
80101bd6:	50                   	push   %eax
80101bd7:	e8 88 2b 00 00       	call   80104764 <releasesleep>
80101bdc:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	68 60 24 19 80       	push   $0x80192460
80101be7:	e8 57 2c 00 00       	call   80104843 <acquire>
80101bec:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	8b 40 08             	mov    0x8(%eax),%eax
80101bf5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	68 60 24 19 80       	push   $0x80192460
80101c06:	e8 a6 2c 00 00       	call   801048b1 <release>
80101c0b:	83 c4 10             	add    $0x10,%esp
}
80101c0e:	90                   	nop
80101c0f:	c9                   	leave  
80101c10:	c3                   	ret    

80101c11 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	ff 75 08             	push   0x8(%ebp)
80101c1d:	e8 d1 fe ff ff       	call   80101af3 <iunlock>
80101c22:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c25:	83 ec 0c             	sub    $0xc,%esp
80101c28:	ff 75 08             	push   0x8(%ebp)
80101c2b:	e8 11 ff ff ff       	call   80101b41 <iput>
80101c30:	83 c4 10             	add    $0x10,%esp
}
80101c33:	90                   	nop
80101c34:	c9                   	leave  
80101c35:	c3                   	ret    

80101c36 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c36:	55                   	push   %ebp
80101c37:	89 e5                	mov    %esp,%ebp
80101c39:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c3c:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c40:	77 42                	ja     80101c84 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c48:	83 c2 14             	add    $0x14,%edx
80101c4b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c56:	75 24                	jne    80101c7c <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c58:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5b:	8b 00                	mov    (%eax),%eax
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	50                   	push   %eax
80101c61:	e8 f4 f7 ff ff       	call   8010145a <balloc>
80101c66:	83 c4 10             	add    $0x10,%esp
80101c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c72:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c78:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7f:	e9 d0 00 00 00       	jmp    80101d54 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c84:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c88:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c8c:	0f 87 b5 00 00 00    	ja     80101d47 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ca2:	75 20                	jne    80101cc4 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 00                	mov    (%eax),%eax
80101ca9:	83 ec 0c             	sub    $0xc,%esp
80101cac:	50                   	push   %eax
80101cad:	e8 a8 f7 ff ff       	call   8010145a <balloc>
80101cb2:	83 c4 10             	add    $0x10,%esp
80101cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cbe:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	8b 00                	mov    (%eax),%eax
80101cc9:	83 ec 08             	sub    $0x8,%esp
80101ccc:	ff 75 f4             	push   -0xc(%ebp)
80101ccf:	50                   	push   %eax
80101cd0:	e8 2c e5 ff ff       	call   80100201 <bread>
80101cd5:	83 c4 10             	add    $0x10,%esp
80101cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cde:	83 c0 5c             	add    $0x5c,%eax
80101ce1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ce7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf1:	01 d0                	add    %edx,%eax
80101cf3:	8b 00                	mov    (%eax),%eax
80101cf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cfc:	75 36                	jne    80101d34 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 00                	mov    (%eax),%eax
80101d03:	83 ec 0c             	sub    $0xc,%esp
80101d06:	50                   	push   %eax
80101d07:	e8 4e f7 ff ff       	call   8010145a <balloc>
80101d0c:	83 c4 10             	add    $0x10,%esp
80101d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1f:	01 c2                	add    %eax,%edx
80101d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d24:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d26:	83 ec 0c             	sub    $0xc,%esp
80101d29:	ff 75 f0             	push   -0x10(%ebp)
80101d2c:	e8 3a 15 00 00       	call   8010326b <log_write>
80101d31:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d34:	83 ec 0c             	sub    $0xc,%esp
80101d37:	ff 75 f0             	push   -0x10(%ebp)
80101d3a:	e8 44 e5 ff ff       	call   80100283 <brelse>
80101d3f:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d45:	eb 0d                	jmp    80101d54 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d47:	83 ec 0c             	sub    $0xc,%esp
80101d4a:	68 4e a4 10 80       	push   $0x8010a44e
80101d4f:	e8 55 e8 ff ff       	call   801005a9 <panic>
}
80101d54:	c9                   	leave  
80101d55:	c3                   	ret    

80101d56 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d56:	55                   	push   %ebp
80101d57:	89 e5                	mov    %esp,%ebp
80101d59:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d63:	eb 45                	jmp    80101daa <itrunc+0x54>
    if(ip->addrs[i]){
80101d65:	8b 45 08             	mov    0x8(%ebp),%eax
80101d68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6b:	83 c2 14             	add    $0x14,%edx
80101d6e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d72:	85 c0                	test   %eax,%eax
80101d74:	74 30                	je     80101da6 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7c:	83 c2 14             	add    $0x14,%edx
80101d7f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d83:	8b 55 08             	mov    0x8(%ebp),%edx
80101d86:	8b 12                	mov    (%edx),%edx
80101d88:	83 ec 08             	sub    $0x8,%esp
80101d8b:	50                   	push   %eax
80101d8c:	52                   	push   %edx
80101d8d:	e8 0c f8 ff ff       	call   8010159e <bfree>
80101d92:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9b:	83 c2 14             	add    $0x14,%edx
80101d9e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da5:	00 
  for(i = 0; i < NDIRECT; i++){
80101da6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101daa:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dae:	7e b5                	jle    80101d65 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db9:	85 c0                	test   %eax,%eax
80101dbb:	0f 84 aa 00 00 00    	je     80101e6b <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	8b 00                	mov    (%eax),%eax
80101dcf:	83 ec 08             	sub    $0x8,%esp
80101dd2:	52                   	push   %edx
80101dd3:	50                   	push   %eax
80101dd4:	e8 28 e4 ff ff       	call   80100201 <bread>
80101dd9:	83 c4 10             	add    $0x10,%esp
80101ddc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101de2:	83 c0 5c             	add    $0x5c,%eax
80101de5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101de8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101def:	eb 3c                	jmp    80101e2d <itrunc+0xd7>
      if(a[j])
80101df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dfe:	01 d0                	add    %edx,%eax
80101e00:	8b 00                	mov    (%eax),%eax
80101e02:	85 c0                	test   %eax,%eax
80101e04:	74 23                	je     80101e29 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e13:	01 d0                	add    %edx,%eax
80101e15:	8b 00                	mov    (%eax),%eax
80101e17:	8b 55 08             	mov    0x8(%ebp),%edx
80101e1a:	8b 12                	mov    (%edx),%edx
80101e1c:	83 ec 08             	sub    $0x8,%esp
80101e1f:	50                   	push   %eax
80101e20:	52                   	push   %edx
80101e21:	e8 78 f7 ff ff       	call   8010159e <bfree>
80101e26:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e29:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e30:	83 f8 7f             	cmp    $0x7f,%eax
80101e33:	76 bc                	jbe    80101df1 <itrunc+0x9b>
    }
    brelse(bp);
80101e35:	83 ec 0c             	sub    $0xc,%esp
80101e38:	ff 75 ec             	push   -0x14(%ebp)
80101e3b:	e8 43 e4 ff ff       	call   80100283 <brelse>
80101e40:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e43:	8b 45 08             	mov    0x8(%ebp),%eax
80101e46:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4f:	8b 12                	mov    (%edx),%edx
80101e51:	83 ec 08             	sub    $0x8,%esp
80101e54:	50                   	push   %eax
80101e55:	52                   	push   %edx
80101e56:	e8 43 f7 ff ff       	call   8010159e <bfree>
80101e5b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e68:	00 00 00 
  }

  ip->size = 0;
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e75:	83 ec 0c             	sub    $0xc,%esp
80101e78:	ff 75 08             	push   0x8(%ebp)
80101e7b:	e8 83 f9 ff ff       	call   80101803 <iupdate>
80101e80:	83 c4 10             	add    $0x10,%esp
}
80101e83:	90                   	nop
80101e84:	c9                   	leave  
80101e85:	c3                   	ret    

80101e86 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e86:	55                   	push   %ebp
80101e87:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e89:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8c:	8b 00                	mov    (%eax),%eax
80101e8e:	89 c2                	mov    %eax,%edx
80101e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e93:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e96:	8b 45 08             	mov    0x8(%ebp),%eax
80101e99:	8b 50 04             	mov    0x4(%eax),%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eac:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb9:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec0:	8b 50 58             	mov    0x58(%eax),%edx
80101ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ec9:	90                   	nop
80101eca:	5d                   	pop    %ebp
80101ecb:	c3                   	ret    

80101ecc <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ed9:	66 83 f8 03          	cmp    $0x3,%ax
80101edd:	75 5c                	jne    80101f3b <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee6:	66 85 c0             	test   %ax,%ax
80101ee9:	78 20                	js     80101f0b <readi+0x3f>
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef2:	66 83 f8 09          	cmp    $0x9,%ax
80101ef6:	7f 13                	jg     80101f0b <readi+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101eff:	98                   	cwtl   
80101f00:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <readi+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 0a 01 00 00       	jmp    8010201f <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f24:	8b 55 14             	mov    0x14(%ebp),%edx
80101f27:	83 ec 04             	sub    $0x4,%esp
80101f2a:	52                   	push   %edx
80101f2b:	ff 75 0c             	push   0xc(%ebp)
80101f2e:	ff 75 08             	push   0x8(%ebp)
80101f31:	ff d0                	call   *%eax
80101f33:	83 c4 10             	add    $0x10,%esp
80101f36:	e9 e4 00 00 00       	jmp    8010201f <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	8b 40 58             	mov    0x58(%eax),%eax
80101f41:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f44:	77 0d                	ja     80101f53 <readi+0x87>
80101f46:	8b 55 10             	mov    0x10(%ebp),%edx
80101f49:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4c:	01 d0                	add    %edx,%eax
80101f4e:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f51:	76 0a                	jbe    80101f5d <readi+0x91>
    return -1;
80101f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f58:	e9 c2 00 00 00       	jmp    8010201f <readi+0x153>
  if(off + n > ip->size)
80101f5d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f60:	8b 45 14             	mov    0x14(%ebp),%eax
80101f63:	01 c2                	add    %eax,%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	8b 40 58             	mov    0x58(%eax),%eax
80101f6b:	39 c2                	cmp    %eax,%edx
80101f6d:	76 0c                	jbe    80101f7b <readi+0xaf>
    n = ip->size - off;
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	2b 45 10             	sub    0x10(%ebp),%eax
80101f78:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f82:	e9 89 00 00 00       	jmp    80102010 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f87:	8b 45 10             	mov    0x10(%ebp),%eax
80101f8a:	c1 e8 09             	shr    $0x9,%eax
80101f8d:	83 ec 08             	sub    $0x8,%esp
80101f90:	50                   	push   %eax
80101f91:	ff 75 08             	push   0x8(%ebp)
80101f94:	e8 9d fc ff ff       	call   80101c36 <bmap>
80101f99:	83 c4 10             	add    $0x10,%esp
80101f9c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9f:	8b 12                	mov    (%edx),%edx
80101fa1:	83 ec 08             	sub    $0x8,%esp
80101fa4:	50                   	push   %eax
80101fa5:	52                   	push   %edx
80101fa6:	e8 56 e2 ff ff       	call   80100201 <bread>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fb1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb4:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb9:	ba 00 02 00 00       	mov    $0x200,%edx
80101fbe:	29 c2                	sub    %eax,%edx
80101fc0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc3:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fc6:	39 c2                	cmp    %eax,%edx
80101fc8:	0f 46 c2             	cmovbe %edx,%eax
80101fcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd1:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdc:	01 d0                	add    %edx,%eax
80101fde:	83 ec 04             	sub    $0x4,%esp
80101fe1:	ff 75 ec             	push   -0x14(%ebp)
80101fe4:	50                   	push   %eax
80101fe5:	ff 75 0c             	push   0xc(%ebp)
80101fe8:	e8 8b 2b 00 00       	call   80104b78 <memmove>
80101fed:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ff0:	83 ec 0c             	sub    $0xc,%esp
80101ff3:	ff 75 f0             	push   -0x10(%ebp)
80101ff6:	e8 88 e2 ff ff       	call   80100283 <brelse>
80101ffb:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ffe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102001:	01 45 f4             	add    %eax,-0xc(%ebp)
80102004:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102007:	01 45 10             	add    %eax,0x10(%ebp)
8010200a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200d:	01 45 0c             	add    %eax,0xc(%ebp)
80102010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102013:	3b 45 14             	cmp    0x14(%ebp),%eax
80102016:	0f 82 6b ff ff ff    	jb     80101f87 <readi+0xbb>
  }
  return n;
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010201f:	c9                   	leave  
80102020:	c3                   	ret    

80102021 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102021:	55                   	push   %ebp
80102022:	89 e5                	mov    %esp,%ebp
80102024:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010202e:	66 83 f8 03          	cmp    $0x3,%ax
80102032:	75 5c                	jne    80102090 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102034:	8b 45 08             	mov    0x8(%ebp),%eax
80102037:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010203b:	66 85 c0             	test   %ax,%ax
8010203e:	78 20                	js     80102060 <writei+0x3f>
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102047:	66 83 f8 09          	cmp    $0x9,%ax
8010204b:	7f 13                	jg     80102060 <writei+0x3f>
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102054:	98                   	cwtl   
80102055:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010205c:	85 c0                	test   %eax,%eax
8010205e:	75 0a                	jne    8010206a <writei+0x49>
      return -1;
80102060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102065:	e9 3b 01 00 00       	jmp    801021a5 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102071:	98                   	cwtl   
80102072:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102079:	8b 55 14             	mov    0x14(%ebp),%edx
8010207c:	83 ec 04             	sub    $0x4,%esp
8010207f:	52                   	push   %edx
80102080:	ff 75 0c             	push   0xc(%ebp)
80102083:	ff 75 08             	push   0x8(%ebp)
80102086:	ff d0                	call   *%eax
80102088:	83 c4 10             	add    $0x10,%esp
8010208b:	e9 15 01 00 00       	jmp    801021a5 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102090:	8b 45 08             	mov    0x8(%ebp),%eax
80102093:	8b 40 58             	mov    0x58(%eax),%eax
80102096:	39 45 10             	cmp    %eax,0x10(%ebp)
80102099:	77 0d                	ja     801020a8 <writei+0x87>
8010209b:	8b 55 10             	mov    0x10(%ebp),%edx
8010209e:	8b 45 14             	mov    0x14(%ebp),%eax
801020a1:	01 d0                	add    %edx,%eax
801020a3:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a6:	76 0a                	jbe    801020b2 <writei+0x91>
    return -1;
801020a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ad:	e9 f3 00 00 00       	jmp    801021a5 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020b2:	8b 55 10             	mov    0x10(%ebp),%edx
801020b5:	8b 45 14             	mov    0x14(%ebp),%eax
801020b8:	01 d0                	add    %edx,%eax
801020ba:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020bf:	76 0a                	jbe    801020cb <writei+0xaa>
    return -1;
801020c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c6:	e9 da 00 00 00       	jmp    801021a5 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020d2:	e9 97 00 00 00       	jmp    8010216e <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d7:	8b 45 10             	mov    0x10(%ebp),%eax
801020da:	c1 e8 09             	shr    $0x9,%eax
801020dd:	83 ec 08             	sub    $0x8,%esp
801020e0:	50                   	push   %eax
801020e1:	ff 75 08             	push   0x8(%ebp)
801020e4:	e8 4d fb ff ff       	call   80101c36 <bmap>
801020e9:	83 c4 10             	add    $0x10,%esp
801020ec:	8b 55 08             	mov    0x8(%ebp),%edx
801020ef:	8b 12                	mov    (%edx),%edx
801020f1:	83 ec 08             	sub    $0x8,%esp
801020f4:	50                   	push   %eax
801020f5:	52                   	push   %edx
801020f6:	e8 06 e1 ff ff       	call   80100201 <bread>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102101:	8b 45 10             	mov    0x10(%ebp),%eax
80102104:	25 ff 01 00 00       	and    $0x1ff,%eax
80102109:	ba 00 02 00 00       	mov    $0x200,%edx
8010210e:	29 c2                	sub    %eax,%edx
80102110:	8b 45 14             	mov    0x14(%ebp),%eax
80102113:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102116:	39 c2                	cmp    %eax,%edx
80102118:	0f 46 c2             	cmovbe %edx,%eax
8010211b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010211e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102121:	8d 50 5c             	lea    0x5c(%eax),%edx
80102124:	8b 45 10             	mov    0x10(%ebp),%eax
80102127:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212c:	01 d0                	add    %edx,%eax
8010212e:	83 ec 04             	sub    $0x4,%esp
80102131:	ff 75 ec             	push   -0x14(%ebp)
80102134:	ff 75 0c             	push   0xc(%ebp)
80102137:	50                   	push   %eax
80102138:	e8 3b 2a 00 00       	call   80104b78 <memmove>
8010213d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102140:	83 ec 0c             	sub    $0xc,%esp
80102143:	ff 75 f0             	push   -0x10(%ebp)
80102146:	e8 20 11 00 00       	call   8010326b <log_write>
8010214b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010214e:	83 ec 0c             	sub    $0xc,%esp
80102151:	ff 75 f0             	push   -0x10(%ebp)
80102154:	e8 2a e1 ff ff       	call   80100283 <brelse>
80102159:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010215c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102162:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102165:	01 45 10             	add    %eax,0x10(%ebp)
80102168:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216b:	01 45 0c             	add    %eax,0xc(%ebp)
8010216e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102171:	3b 45 14             	cmp    0x14(%ebp),%eax
80102174:	0f 82 5d ff ff ff    	jb     801020d7 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010217a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010217e:	74 22                	je     801021a2 <writei+0x181>
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	8b 40 58             	mov    0x58(%eax),%eax
80102186:	39 45 10             	cmp    %eax,0x10(%ebp)
80102189:	76 17                	jbe    801021a2 <writei+0x181>
    ip->size = off;
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	8b 55 10             	mov    0x10(%ebp),%edx
80102191:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102194:	83 ec 0c             	sub    $0xc,%esp
80102197:	ff 75 08             	push   0x8(%ebp)
8010219a:	e8 64 f6 ff ff       	call   80101803 <iupdate>
8010219f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021a2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021a5:	c9                   	leave  
801021a6:	c3                   	ret    

801021a7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021a7:	55                   	push   %ebp
801021a8:	89 e5                	mov    %esp,%ebp
801021aa:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021ad:	83 ec 04             	sub    $0x4,%esp
801021b0:	6a 0e                	push   $0xe
801021b2:	ff 75 0c             	push   0xc(%ebp)
801021b5:	ff 75 08             	push   0x8(%ebp)
801021b8:	e8 51 2a 00 00       	call   80104c0e <strncmp>
801021bd:	83 c4 10             	add    $0x10,%esp
}
801021c0:	c9                   	leave  
801021c1:	c3                   	ret    

801021c2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021c2:	55                   	push   %ebp
801021c3:	89 e5                	mov    %esp,%ebp
801021c5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021c8:	8b 45 08             	mov    0x8(%ebp),%eax
801021cb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021cf:	66 83 f8 01          	cmp    $0x1,%ax
801021d3:	74 0d                	je     801021e2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021d5:	83 ec 0c             	sub    $0xc,%esp
801021d8:	68 61 a4 10 80       	push   $0x8010a461
801021dd:	e8 c7 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021e9:	eb 7b                	jmp    80102266 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021eb:	6a 10                	push   $0x10
801021ed:	ff 75 f4             	push   -0xc(%ebp)
801021f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f3:	50                   	push   %eax
801021f4:	ff 75 08             	push   0x8(%ebp)
801021f7:	e8 d0 fc ff ff       	call   80101ecc <readi>
801021fc:	83 c4 10             	add    $0x10,%esp
801021ff:	83 f8 10             	cmp    $0x10,%eax
80102202:	74 0d                	je     80102211 <dirlookup+0x4f>
      panic("dirlookup read");
80102204:	83 ec 0c             	sub    $0xc,%esp
80102207:	68 73 a4 10 80       	push   $0x8010a473
8010220c:	e8 98 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102211:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102215:	66 85 c0             	test   %ax,%ax
80102218:	74 47                	je     80102261 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010221a:	83 ec 08             	sub    $0x8,%esp
8010221d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102220:	83 c0 02             	add    $0x2,%eax
80102223:	50                   	push   %eax
80102224:	ff 75 0c             	push   0xc(%ebp)
80102227:	e8 7b ff ff ff       	call   801021a7 <namecmp>
8010222c:	83 c4 10             	add    $0x10,%esp
8010222f:	85 c0                	test   %eax,%eax
80102231:	75 2f                	jne    80102262 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102233:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102237:	74 08                	je     80102241 <dirlookup+0x7f>
        *poff = off;
80102239:	8b 45 10             	mov    0x10(%ebp),%eax
8010223c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010223f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102241:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102245:	0f b7 c0             	movzwl %ax,%eax
80102248:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 00                	mov    (%eax),%eax
80102250:	83 ec 08             	sub    $0x8,%esp
80102253:	ff 75 f0             	push   -0x10(%ebp)
80102256:	50                   	push   %eax
80102257:	e8 68 f6 ff ff       	call   801018c4 <iget>
8010225c:	83 c4 10             	add    $0x10,%esp
8010225f:	eb 19                	jmp    8010227a <dirlookup+0xb8>
      continue;
80102261:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102262:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102266:	8b 45 08             	mov    0x8(%ebp),%eax
80102269:	8b 40 58             	mov    0x58(%eax),%eax
8010226c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010226f:	0f 82 76 ff ff ff    	jb     801021eb <dirlookup+0x29>
    }
  }

  return 0;
80102275:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010227a:	c9                   	leave  
8010227b:	c3                   	ret    

8010227c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010227c:	55                   	push   %ebp
8010227d:	89 e5                	mov    %esp,%ebp
8010227f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102282:	83 ec 04             	sub    $0x4,%esp
80102285:	6a 00                	push   $0x0
80102287:	ff 75 0c             	push   0xc(%ebp)
8010228a:	ff 75 08             	push   0x8(%ebp)
8010228d:	e8 30 ff ff ff       	call   801021c2 <dirlookup>
80102292:	83 c4 10             	add    $0x10,%esp
80102295:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102298:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010229c:	74 18                	je     801022b6 <dirlink+0x3a>
    iput(ip);
8010229e:	83 ec 0c             	sub    $0xc,%esp
801022a1:	ff 75 f0             	push   -0x10(%ebp)
801022a4:	e8 98 f8 ff ff       	call   80101b41 <iput>
801022a9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022b1:	e9 9c 00 00 00       	jmp    80102352 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022bd:	eb 39                	jmp    801022f8 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c2:	6a 10                	push   $0x10
801022c4:	50                   	push   %eax
801022c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c8:	50                   	push   %eax
801022c9:	ff 75 08             	push   0x8(%ebp)
801022cc:	e8 fb fb ff ff       	call   80101ecc <readi>
801022d1:	83 c4 10             	add    $0x10,%esp
801022d4:	83 f8 10             	cmp    $0x10,%eax
801022d7:	74 0d                	je     801022e6 <dirlink+0x6a>
      panic("dirlink read");
801022d9:	83 ec 0c             	sub    $0xc,%esp
801022dc:	68 82 a4 10 80       	push   $0x8010a482
801022e1:	e8 c3 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022e6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ea:	66 85 c0             	test   %ax,%ax
801022ed:	74 18                	je     80102307 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f2:	83 c0 10             	add    $0x10,%eax
801022f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022f8:	8b 45 08             	mov    0x8(%ebp),%eax
801022fb:	8b 50 58             	mov    0x58(%eax),%edx
801022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102301:	39 c2                	cmp    %eax,%edx
80102303:	77 ba                	ja     801022bf <dirlink+0x43>
80102305:	eb 01                	jmp    80102308 <dirlink+0x8c>
      break;
80102307:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102308:	83 ec 04             	sub    $0x4,%esp
8010230b:	6a 0e                	push   $0xe
8010230d:	ff 75 0c             	push   0xc(%ebp)
80102310:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102313:	83 c0 02             	add    $0x2,%eax
80102316:	50                   	push   %eax
80102317:	e8 48 29 00 00       	call   80104c64 <strncpy>
8010231c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010231f:	8b 45 10             	mov    0x10(%ebp),%eax
80102322:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102329:	6a 10                	push   $0x10
8010232b:	50                   	push   %eax
8010232c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232f:	50                   	push   %eax
80102330:	ff 75 08             	push   0x8(%ebp)
80102333:	e8 e9 fc ff ff       	call   80102021 <writei>
80102338:	83 c4 10             	add    $0x10,%esp
8010233b:	83 f8 10             	cmp    $0x10,%eax
8010233e:	74 0d                	je     8010234d <dirlink+0xd1>
    panic("dirlink");
80102340:	83 ec 0c             	sub    $0xc,%esp
80102343:	68 8f a4 10 80       	push   $0x8010a48f
80102348:	e8 5c e2 ff ff       	call   801005a9 <panic>

  return 0;
8010234d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102352:	c9                   	leave  
80102353:	c3                   	ret    

80102354 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102354:	55                   	push   %ebp
80102355:	89 e5                	mov    %esp,%ebp
80102357:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010235a:	eb 04                	jmp    80102360 <skipelem+0xc>
    path++;
8010235c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102360:	8b 45 08             	mov    0x8(%ebp),%eax
80102363:	0f b6 00             	movzbl (%eax),%eax
80102366:	3c 2f                	cmp    $0x2f,%al
80102368:	74 f2                	je     8010235c <skipelem+0x8>
  if(*path == 0)
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	84 c0                	test   %al,%al
80102372:	75 07                	jne    8010237b <skipelem+0x27>
    return 0;
80102374:	b8 00 00 00 00       	mov    $0x0,%eax
80102379:	eb 77                	jmp    801023f2 <skipelem+0x9e>
  s = path;
8010237b:	8b 45 08             	mov    0x8(%ebp),%eax
8010237e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102381:	eb 04                	jmp    80102387 <skipelem+0x33>
    path++;
80102383:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	0f b6 00             	movzbl (%eax),%eax
8010238d:	3c 2f                	cmp    $0x2f,%al
8010238f:	74 0a                	je     8010239b <skipelem+0x47>
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	84 c0                	test   %al,%al
80102399:	75 e8                	jne    80102383 <skipelem+0x2f>
  len = path - s;
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023a4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023a8:	7e 15                	jle    801023bf <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023aa:	83 ec 04             	sub    $0x4,%esp
801023ad:	6a 0e                	push   $0xe
801023af:	ff 75 f4             	push   -0xc(%ebp)
801023b2:	ff 75 0c             	push   0xc(%ebp)
801023b5:	e8 be 27 00 00       	call   80104b78 <memmove>
801023ba:	83 c4 10             	add    $0x10,%esp
801023bd:	eb 26                	jmp    801023e5 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	50                   	push   %eax
801023c6:	ff 75 f4             	push   -0xc(%ebp)
801023c9:	ff 75 0c             	push   0xc(%ebp)
801023cc:	e8 a7 27 00 00       	call   80104b78 <memmove>
801023d1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801023da:	01 d0                	add    %edx,%eax
801023dc:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023df:	eb 04                	jmp    801023e5 <skipelem+0x91>
    path++;
801023e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023e5:	8b 45 08             	mov    0x8(%ebp),%eax
801023e8:	0f b6 00             	movzbl (%eax),%eax
801023eb:	3c 2f                	cmp    $0x2f,%al
801023ed:	74 f2                	je     801023e1 <skipelem+0x8d>
  return path;
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023f2:	c9                   	leave  
801023f3:	c3                   	ret    

801023f4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023f4:	55                   	push   %ebp
801023f5:	89 e5                	mov    %esp,%ebp
801023f7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
801023fd:	0f b6 00             	movzbl (%eax),%eax
80102400:	3c 2f                	cmp    $0x2f,%al
80102402:	75 17                	jne    8010241b <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102404:	83 ec 08             	sub    $0x8,%esp
80102407:	6a 01                	push   $0x1
80102409:	6a 01                	push   $0x1
8010240b:	e8 b4 f4 ff ff       	call   801018c4 <iget>
80102410:	83 c4 10             	add    $0x10,%esp
80102413:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102416:	e9 ba 00 00 00       	jmp    801024d5 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010241b:	e8 06 16 00 00       	call   80103a26 <myproc>
80102420:	8b 40 68             	mov    0x68(%eax),%eax
80102423:	83 ec 0c             	sub    $0xc,%esp
80102426:	50                   	push   %eax
80102427:	e8 7a f5 ff ff       	call   801019a6 <idup>
8010242c:	83 c4 10             	add    $0x10,%esp
8010242f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102432:	e9 9e 00 00 00       	jmp    801024d5 <namex+0xe1>
    ilock(ip);
80102437:	83 ec 0c             	sub    $0xc,%esp
8010243a:	ff 75 f4             	push   -0xc(%ebp)
8010243d:	e8 9e f5 ff ff       	call   801019e0 <ilock>
80102442:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102448:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010244c:	66 83 f8 01          	cmp    $0x1,%ax
80102450:	74 18                	je     8010246a <namex+0x76>
      iunlockput(ip);
80102452:	83 ec 0c             	sub    $0xc,%esp
80102455:	ff 75 f4             	push   -0xc(%ebp)
80102458:	e8 b4 f7 ff ff       	call   80101c11 <iunlockput>
8010245d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102460:	b8 00 00 00 00       	mov    $0x0,%eax
80102465:	e9 a7 00 00 00       	jmp    80102511 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010246a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246e:	74 20                	je     80102490 <namex+0x9c>
80102470:	8b 45 08             	mov    0x8(%ebp),%eax
80102473:	0f b6 00             	movzbl (%eax),%eax
80102476:	84 c0                	test   %al,%al
80102478:	75 16                	jne    80102490 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010247a:	83 ec 0c             	sub    $0xc,%esp
8010247d:	ff 75 f4             	push   -0xc(%ebp)
80102480:	e8 6e f6 ff ff       	call   80101af3 <iunlock>
80102485:	83 c4 10             	add    $0x10,%esp
      return ip;
80102488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010248b:	e9 81 00 00 00       	jmp    80102511 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102490:	83 ec 04             	sub    $0x4,%esp
80102493:	6a 00                	push   $0x0
80102495:	ff 75 10             	push   0x10(%ebp)
80102498:	ff 75 f4             	push   -0xc(%ebp)
8010249b:	e8 22 fd ff ff       	call   801021c2 <dirlookup>
801024a0:	83 c4 10             	add    $0x10,%esp
801024a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024aa:	75 15                	jne    801024c1 <namex+0xcd>
      iunlockput(ip);
801024ac:	83 ec 0c             	sub    $0xc,%esp
801024af:	ff 75 f4             	push   -0xc(%ebp)
801024b2:	e8 5a f7 ff ff       	call   80101c11 <iunlockput>
801024b7:	83 c4 10             	add    $0x10,%esp
      return 0;
801024ba:	b8 00 00 00 00       	mov    $0x0,%eax
801024bf:	eb 50                	jmp    80102511 <namex+0x11d>
    }
    iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	push   -0xc(%ebp)
801024c7:	e8 45 f7 ff ff       	call   80101c11 <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024d5:	83 ec 08             	sub    $0x8,%esp
801024d8:	ff 75 10             	push   0x10(%ebp)
801024db:	ff 75 08             	push   0x8(%ebp)
801024de:	e8 71 fe ff ff       	call   80102354 <skipelem>
801024e3:	83 c4 10             	add    $0x10,%esp
801024e6:	89 45 08             	mov    %eax,0x8(%ebp)
801024e9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ed:	0f 85 44 ff ff ff    	jne    80102437 <namex+0x43>
  }
  if(nameiparent){
801024f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024f7:	74 15                	je     8010250e <namex+0x11a>
    iput(ip);
801024f9:	83 ec 0c             	sub    $0xc,%esp
801024fc:	ff 75 f4             	push   -0xc(%ebp)
801024ff:	e8 3d f6 ff ff       	call   80101b41 <iput>
80102504:	83 c4 10             	add    $0x10,%esp
    return 0;
80102507:	b8 00 00 00 00       	mov    $0x0,%eax
8010250c:	eb 03                	jmp    80102511 <namex+0x11d>
  }
  return ip;
8010250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102511:	c9                   	leave  
80102512:	c3                   	ret    

80102513 <namei>:

struct inode*
namei(char *path)
{
80102513:	55                   	push   %ebp
80102514:	89 e5                	mov    %esp,%ebp
80102516:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102519:	83 ec 04             	sub    $0x4,%esp
8010251c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010251f:	50                   	push   %eax
80102520:	6a 00                	push   $0x0
80102522:	ff 75 08             	push   0x8(%ebp)
80102525:	e8 ca fe ff ff       	call   801023f4 <namex>
8010252a:	83 c4 10             	add    $0x10,%esp
}
8010252d:	c9                   	leave  
8010252e:	c3                   	ret    

8010252f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010252f:	55                   	push   %ebp
80102530:	89 e5                	mov    %esp,%ebp
80102532:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102535:	83 ec 04             	sub    $0x4,%esp
80102538:	ff 75 0c             	push   0xc(%ebp)
8010253b:	6a 01                	push   $0x1
8010253d:	ff 75 08             	push   0x8(%ebp)
80102540:	e8 af fe ff ff       	call   801023f4 <namex>
80102545:	83 c4 10             	add    $0x10,%esp
}
80102548:	c9                   	leave  
80102549:	c3                   	ret    

8010254a <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010254d:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102552:	8b 55 08             	mov    0x8(%ebp),%edx
80102555:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010255f:	5d                   	pop    %ebp
80102560:	c3                   	ret    

80102561 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102564:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102569:	8b 55 08             	mov    0x8(%ebp),%edx
8010256c:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 0c             	mov    0xc(%ebp),%edx
80102576:	89 50 10             	mov    %edx,0x10(%eax)
}
80102579:	90                   	nop
8010257a:	5d                   	pop    %ebp
8010257b:	c3                   	ret    

8010257c <ioapicinit>:

void
ioapicinit(void)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102582:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102589:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010258c:	6a 01                	push   $0x1
8010258e:	e8 b7 ff ff ff       	call   8010254a <ioapicread>
80102593:	83 c4 04             	add    $0x4,%esp
80102596:	c1 e8 10             	shr    $0x10,%eax
80102599:	25 ff 00 00 00       	and    $0xff,%eax
8010259e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025a1:	6a 00                	push   $0x0
801025a3:	e8 a2 ff ff ff       	call   8010254a <ioapicread>
801025a8:	83 c4 04             	add    $0x4,%esp
801025ab:	c1 e8 18             	shr    $0x18,%eax
801025ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025b1:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025b8:	0f b6 c0             	movzbl %al,%eax
801025bb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025be:	74 10                	je     801025d0 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025c0:	83 ec 0c             	sub    $0xc,%esp
801025c3:	68 98 a4 10 80       	push   $0x8010a498
801025c8:	e8 27 de ff ff       	call   801003f4 <cprintf>
801025cd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025d7:	eb 3f                	jmp    80102618 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025dc:	83 c0 20             	add    $0x20,%eax
801025df:	0d 00 00 01 00       	or     $0x10000,%eax
801025e4:	89 c2                	mov    %eax,%edx
801025e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e9:	83 c0 08             	add    $0x8,%eax
801025ec:	01 c0                	add    %eax,%eax
801025ee:	83 ec 08             	sub    $0x8,%esp
801025f1:	52                   	push   %edx
801025f2:	50                   	push   %eax
801025f3:	e8 69 ff ff ff       	call   80102561 <ioapicwrite>
801025f8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fe:	83 c0 08             	add    $0x8,%eax
80102601:	01 c0                	add    %eax,%eax
80102603:	83 c0 01             	add    $0x1,%eax
80102606:	83 ec 08             	sub    $0x8,%esp
80102609:	6a 00                	push   $0x0
8010260b:	50                   	push   %eax
8010260c:	e8 50 ff ff ff       	call   80102561 <ioapicwrite>
80102611:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102614:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010261e:	7e b9                	jle    801025d9 <ioapicinit+0x5d>
  }
}
80102620:	90                   	nop
80102621:	90                   	nop
80102622:	c9                   	leave  
80102623:	c3                   	ret    

80102624 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102624:	55                   	push   %ebp
80102625:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102627:	8b 45 08             	mov    0x8(%ebp),%eax
8010262a:	83 c0 20             	add    $0x20,%eax
8010262d:	89 c2                	mov    %eax,%edx
8010262f:	8b 45 08             	mov    0x8(%ebp),%eax
80102632:	83 c0 08             	add    $0x8,%eax
80102635:	01 c0                	add    %eax,%eax
80102637:	52                   	push   %edx
80102638:	50                   	push   %eax
80102639:	e8 23 ff ff ff       	call   80102561 <ioapicwrite>
8010263e:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102641:	8b 45 0c             	mov    0xc(%ebp),%eax
80102644:	c1 e0 18             	shl    $0x18,%eax
80102647:	89 c2                	mov    %eax,%edx
80102649:	8b 45 08             	mov    0x8(%ebp),%eax
8010264c:	83 c0 08             	add    $0x8,%eax
8010264f:	01 c0                	add    %eax,%eax
80102651:	83 c0 01             	add    $0x1,%eax
80102654:	52                   	push   %edx
80102655:	50                   	push   %eax
80102656:	e8 06 ff ff ff       	call   80102561 <ioapicwrite>
8010265b:	83 c4 08             	add    $0x8,%esp
}
8010265e:	90                   	nop
8010265f:	c9                   	leave  
80102660:	c3                   	ret    

80102661 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102667:	83 ec 08             	sub    $0x8,%esp
8010266a:	68 ca a4 10 80       	push   $0x8010a4ca
8010266f:	68 c0 40 19 80       	push   $0x801940c0
80102674:	e8 a8 21 00 00       	call   80104821 <initlock>
80102679:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010267c:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102683:	00 00 00 
  freerange(vstart, vend);
80102686:	83 ec 08             	sub    $0x8,%esp
80102689:	ff 75 0c             	push   0xc(%ebp)
8010268c:	ff 75 08             	push   0x8(%ebp)
8010268f:	e8 2a 00 00 00       	call   801026be <freerange>
80102694:	83 c4 10             	add    $0x10,%esp
}
80102697:	90                   	nop
80102698:	c9                   	leave  
80102699:	c3                   	ret    

8010269a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010269a:	55                   	push   %ebp
8010269b:	89 e5                	mov    %esp,%ebp
8010269d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026a0:	83 ec 08             	sub    $0x8,%esp
801026a3:	ff 75 0c             	push   0xc(%ebp)
801026a6:	ff 75 08             	push   0x8(%ebp)
801026a9:	e8 10 00 00 00       	call   801026be <freerange>
801026ae:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026b1:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026b8:	00 00 00 
}
801026bb:	90                   	nop
801026bc:	c9                   	leave  
801026bd:	c3                   	ret    

801026be <freerange>:

void
freerange(void *vstart, void *vend)
{
801026be:	55                   	push   %ebp
801026bf:	89 e5                	mov    %esp,%ebp
801026c1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026c4:	8b 45 08             	mov    0x8(%ebp),%eax
801026c7:	05 ff 0f 00 00       	add    $0xfff,%eax
801026cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d4:	eb 15                	jmp    801026eb <freerange+0x2d>
    kfree(p);
801026d6:	83 ec 0c             	sub    $0xc,%esp
801026d9:	ff 75 f4             	push   -0xc(%ebp)
801026dc:	e8 1b 00 00 00       	call   801026fc <kfree>
801026e1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ee:	05 00 10 00 00       	add    $0x1000,%eax
801026f3:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026f6:	73 de                	jae    801026d6 <freerange+0x18>
}
801026f8:	90                   	nop
801026f9:	90                   	nop
801026fa:	c9                   	leave  
801026fb:	c3                   	ret    

801026fc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026fc:	55                   	push   %ebp
801026fd:	89 e5                	mov    %esp,%ebp
801026ff:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102702:	8b 45 08             	mov    0x8(%ebp),%eax
80102705:	25 ff 0f 00 00       	and    $0xfff,%eax
8010270a:	85 c0                	test   %eax,%eax
8010270c:	75 18                	jne    80102726 <kfree+0x2a>
8010270e:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102715:	72 0f                	jb     80102726 <kfree+0x2a>
80102717:	8b 45 08             	mov    0x8(%ebp),%eax
8010271a:	05 00 00 00 80       	add    $0x80000000,%eax
8010271f:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102724:	76 0d                	jbe    80102733 <kfree+0x37>
    panic("kfree");
80102726:	83 ec 0c             	sub    $0xc,%esp
80102729:	68 cf a4 10 80       	push   $0x8010a4cf
8010272e:	e8 76 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102733:	83 ec 04             	sub    $0x4,%esp
80102736:	68 00 10 00 00       	push   $0x1000
8010273b:	6a 01                	push   $0x1
8010273d:	ff 75 08             	push   0x8(%ebp)
80102740:	e8 74 23 00 00       	call   80104ab9 <memset>
80102745:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102748:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010274d:	85 c0                	test   %eax,%eax
8010274f:	74 10                	je     80102761 <kfree+0x65>
    acquire(&kmem.lock);
80102751:	83 ec 0c             	sub    $0xc,%esp
80102754:	68 c0 40 19 80       	push   $0x801940c0
80102759:	e8 e5 20 00 00       	call   80104843 <acquire>
8010275e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102761:	8b 45 08             	mov    0x8(%ebp),%eax
80102764:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102767:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010277a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010277f:	85 c0                	test   %eax,%eax
80102781:	74 10                	je     80102793 <kfree+0x97>
    release(&kmem.lock);
80102783:	83 ec 0c             	sub    $0xc,%esp
80102786:	68 c0 40 19 80       	push   $0x801940c0
8010278b:	e8 21 21 00 00       	call   801048b1 <release>
80102790:	83 c4 10             	add    $0x10,%esp
}
80102793:	90                   	nop
80102794:	c9                   	leave  
80102795:	c3                   	ret    

80102796 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102796:	55                   	push   %ebp
80102797:	89 e5                	mov    %esp,%ebp
80102799:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010279c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027a1:	85 c0                	test   %eax,%eax
801027a3:	74 10                	je     801027b5 <kalloc+0x1f>
    acquire(&kmem.lock);
801027a5:	83 ec 0c             	sub    $0xc,%esp
801027a8:	68 c0 40 19 80       	push   $0x801940c0
801027ad:	e8 91 20 00 00       	call   80104843 <acquire>
801027b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027b5:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c1:	74 0a                	je     801027cd <kalloc+0x37>
    kmem.freelist = r->next;
801027c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c6:	8b 00                	mov    (%eax),%eax
801027c8:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027cd:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027d2:	85 c0                	test   %eax,%eax
801027d4:	74 10                	je     801027e6 <kalloc+0x50>
    release(&kmem.lock);
801027d6:	83 ec 0c             	sub    $0xc,%esp
801027d9:	68 c0 40 19 80       	push   $0x801940c0
801027de:	e8 ce 20 00 00       	call   801048b1 <release>
801027e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027e9:	c9                   	leave  
801027ea:	c3                   	ret    

801027eb <inb>:
{
801027eb:	55                   	push   %ebp
801027ec:	89 e5                	mov    %esp,%ebp
801027ee:	83 ec 14             	sub    $0x14,%esp
801027f1:	8b 45 08             	mov    0x8(%ebp),%eax
801027f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027fc:	89 c2                	mov    %eax,%edx
801027fe:	ec                   	in     (%dx),%al
801027ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102802:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102806:	c9                   	leave  
80102807:	c3                   	ret    

80102808 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102808:	55                   	push   %ebp
80102809:	89 e5                	mov    %esp,%ebp
8010280b:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010280e:	6a 64                	push   $0x64
80102810:	e8 d6 ff ff ff       	call   801027eb <inb>
80102815:	83 c4 04             	add    $0x4,%esp
80102818:	0f b6 c0             	movzbl %al,%eax
8010281b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010281e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102821:	83 e0 01             	and    $0x1,%eax
80102824:	85 c0                	test   %eax,%eax
80102826:	75 0a                	jne    80102832 <kbdgetc+0x2a>
    return -1;
80102828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010282d:	e9 23 01 00 00       	jmp    80102955 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102832:	6a 60                	push   $0x60
80102834:	e8 b2 ff ff ff       	call   801027eb <inb>
80102839:	83 c4 04             	add    $0x4,%esp
8010283c:	0f b6 c0             	movzbl %al,%eax
8010283f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102842:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102849:	75 17                	jne    80102862 <kbdgetc+0x5a>
    shift |= E0ESC;
8010284b:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102850:	83 c8 40             	or     $0x40,%eax
80102853:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102858:	b8 00 00 00 00       	mov    $0x0,%eax
8010285d:	e9 f3 00 00 00       	jmp    80102955 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102862:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102865:	25 80 00 00 00       	and    $0x80,%eax
8010286a:	85 c0                	test   %eax,%eax
8010286c:	74 45                	je     801028b3 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010286e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102873:	83 e0 40             	and    $0x40,%eax
80102876:	85 c0                	test   %eax,%eax
80102878:	75 08                	jne    80102882 <kbdgetc+0x7a>
8010287a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287d:	83 e0 7f             	and    $0x7f,%eax
80102880:	eb 03                	jmp    80102885 <kbdgetc+0x7d>
80102882:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102885:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102888:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288b:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102890:	0f b6 00             	movzbl (%eax),%eax
80102893:	83 c8 40             	or     $0x40,%eax
80102896:	0f b6 c0             	movzbl %al,%eax
80102899:	f7 d0                	not    %eax
8010289b:	89 c2                	mov    %eax,%edx
8010289d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028a2:	21 d0                	and    %edx,%eax
801028a4:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028a9:	b8 00 00 00 00       	mov    $0x0,%eax
801028ae:	e9 a2 00 00 00       	jmp    80102955 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028b3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b8:	83 e0 40             	and    $0x40,%eax
801028bb:	85 c0                	test   %eax,%eax
801028bd:	74 14                	je     801028d3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028bf:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028c6:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028cb:	83 e0 bf             	and    $0xffffffbf,%eax
801028ce:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028d6:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028db:	0f b6 00             	movzbl (%eax),%eax
801028de:	0f b6 d0             	movzbl %al,%edx
801028e1:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028e6:	09 d0                	or     %edx,%eax
801028e8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028f0:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028f5:	0f b6 00             	movzbl (%eax),%eax
801028f8:	0f b6 d0             	movzbl %al,%edx
801028fb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102900:	31 d0                	xor    %edx,%eax
80102902:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102907:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290c:	83 e0 03             	and    $0x3,%eax
8010290f:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102916:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102919:	01 d0                	add    %edx,%eax
8010291b:	0f b6 00             	movzbl (%eax),%eax
8010291e:	0f b6 c0             	movzbl %al,%eax
80102921:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102924:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102929:	83 e0 08             	and    $0x8,%eax
8010292c:	85 c0                	test   %eax,%eax
8010292e:	74 22                	je     80102952 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102930:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102934:	76 0c                	jbe    80102942 <kbdgetc+0x13a>
80102936:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010293a:	77 06                	ja     80102942 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010293c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102940:	eb 10                	jmp    80102952 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102942:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102946:	76 0a                	jbe    80102952 <kbdgetc+0x14a>
80102948:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010294c:	77 04                	ja     80102952 <kbdgetc+0x14a>
      c += 'a' - 'A';
8010294e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102952:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102955:	c9                   	leave  
80102956:	c3                   	ret    

80102957 <kbdintr>:

void
kbdintr(void)
{
80102957:	55                   	push   %ebp
80102958:	89 e5                	mov    %esp,%ebp
8010295a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010295d:	83 ec 0c             	sub    $0xc,%esp
80102960:	68 08 28 10 80       	push   $0x80102808
80102965:	e8 6c de ff ff       	call   801007d6 <consoleintr>
8010296a:	83 c4 10             	add    $0x10,%esp
}
8010296d:	90                   	nop
8010296e:	c9                   	leave  
8010296f:	c3                   	ret    

80102970 <inb>:
{
80102970:	55                   	push   %ebp
80102971:	89 e5                	mov    %esp,%ebp
80102973:	83 ec 14             	sub    $0x14,%esp
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010297d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102981:	89 c2                	mov    %eax,%edx
80102983:	ec                   	in     (%dx),%al
80102984:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102987:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010298b:	c9                   	leave  
8010298c:	c3                   	ret    

8010298d <outb>:
{
8010298d:	55                   	push   %ebp
8010298e:	89 e5                	mov    %esp,%ebp
80102990:	83 ec 08             	sub    $0x8,%esp
80102993:	8b 45 08             	mov    0x8(%ebp),%eax
80102996:	8b 55 0c             	mov    0xc(%ebp),%edx
80102999:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010299d:	89 d0                	mov    %edx,%eax
8010299f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029a2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029a6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029aa:	ee                   	out    %al,(%dx)
}
801029ab:	90                   	nop
801029ac:	c9                   	leave  
801029ad:	c3                   	ret    

801029ae <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029ae:	55                   	push   %ebp
801029af:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029b1:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	c1 e0 02             	shl    $0x2,%eax
801029bd:	01 c2                	add    %eax,%edx
801029bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029c4:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c9:	83 c0 20             	add    $0x20,%eax
801029cc:	8b 00                	mov    (%eax),%eax
}
801029ce:	90                   	nop
801029cf:	5d                   	pop    %ebp
801029d0:	c3                   	ret    

801029d1 <lapicinit>:

void
lapicinit(void)
{
801029d1:	55                   	push   %ebp
801029d2:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029d4:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d9:	85 c0                	test   %eax,%eax
801029db:	0f 84 0c 01 00 00    	je     80102aed <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029e1:	68 3f 01 00 00       	push   $0x13f
801029e6:	6a 3c                	push   $0x3c
801029e8:	e8 c1 ff ff ff       	call   801029ae <lapicw>
801029ed:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029f0:	6a 0b                	push   $0xb
801029f2:	68 f8 00 00 00       	push   $0xf8
801029f7:	e8 b2 ff ff ff       	call   801029ae <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029ff:	68 20 00 02 00       	push   $0x20020
80102a04:	68 c8 00 00 00       	push   $0xc8
80102a09:	e8 a0 ff ff ff       	call   801029ae <lapicw>
80102a0e:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a11:	68 80 96 98 00       	push   $0x989680
80102a16:	68 e0 00 00 00       	push   $0xe0
80102a1b:	e8 8e ff ff ff       	call   801029ae <lapicw>
80102a20:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a23:	68 00 00 01 00       	push   $0x10000
80102a28:	68 d4 00 00 00       	push   $0xd4
80102a2d:	e8 7c ff ff ff       	call   801029ae <lapicw>
80102a32:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a35:	68 00 00 01 00       	push   $0x10000
80102a3a:	68 d8 00 00 00       	push   $0xd8
80102a3f:	e8 6a ff ff ff       	call   801029ae <lapicw>
80102a44:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a47:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a4c:	83 c0 30             	add    $0x30,%eax
80102a4f:	8b 00                	mov    (%eax),%eax
80102a51:	c1 e8 10             	shr    $0x10,%eax
80102a54:	25 fc 00 00 00       	and    $0xfc,%eax
80102a59:	85 c0                	test   %eax,%eax
80102a5b:	74 12                	je     80102a6f <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a5d:	68 00 00 01 00       	push   $0x10000
80102a62:	68 d0 00 00 00       	push   $0xd0
80102a67:	e8 42 ff ff ff       	call   801029ae <lapicw>
80102a6c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a6f:	6a 33                	push   $0x33
80102a71:	68 dc 00 00 00       	push   $0xdc
80102a76:	e8 33 ff ff ff       	call   801029ae <lapicw>
80102a7b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a7e:	6a 00                	push   $0x0
80102a80:	68 a0 00 00 00       	push   $0xa0
80102a85:	e8 24 ff ff ff       	call   801029ae <lapicw>
80102a8a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a8d:	6a 00                	push   $0x0
80102a8f:	68 a0 00 00 00       	push   $0xa0
80102a94:	e8 15 ff ff ff       	call   801029ae <lapicw>
80102a99:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a9c:	6a 00                	push   $0x0
80102a9e:	6a 2c                	push   $0x2c
80102aa0:	e8 09 ff ff ff       	call   801029ae <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	68 c4 00 00 00       	push   $0xc4
80102aaf:	e8 fa fe ff ff       	call   801029ae <lapicw>
80102ab4:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ab7:	68 00 85 08 00       	push   $0x88500
80102abc:	68 c0 00 00 00       	push   $0xc0
80102ac1:	e8 e8 fe ff ff       	call   801029ae <lapicw>
80102ac6:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ac9:	90                   	nop
80102aca:	a1 00 41 19 80       	mov    0x80194100,%eax
80102acf:	05 00 03 00 00       	add    $0x300,%eax
80102ad4:	8b 00                	mov    (%eax),%eax
80102ad6:	25 00 10 00 00       	and    $0x1000,%eax
80102adb:	85 c0                	test   %eax,%eax
80102add:	75 eb                	jne    80102aca <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102adf:	6a 00                	push   $0x0
80102ae1:	6a 20                	push   $0x20
80102ae3:	e8 c6 fe ff ff       	call   801029ae <lapicw>
80102ae8:	83 c4 08             	add    $0x8,%esp
80102aeb:	eb 01                	jmp    80102aee <lapicinit+0x11d>
    return;
80102aed:	90                   	nop
}
80102aee:	c9                   	leave  
80102aef:	c3                   	ret    

80102af0 <lapicid>:

int
lapicid(void)
{
80102af0:	55                   	push   %ebp
80102af1:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102af3:	a1 00 41 19 80       	mov    0x80194100,%eax
80102af8:	85 c0                	test   %eax,%eax
80102afa:	75 07                	jne    80102b03 <lapicid+0x13>
    return 0;
80102afc:	b8 00 00 00 00       	mov    $0x0,%eax
80102b01:	eb 0d                	jmp    80102b10 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b03:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b08:	83 c0 20             	add    $0x20,%eax
80102b0b:	8b 00                	mov    (%eax),%eax
80102b0d:	c1 e8 18             	shr    $0x18,%eax
}
80102b10:	5d                   	pop    %ebp
80102b11:	c3                   	ret    

80102b12 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b15:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b1e:	6a 00                	push   $0x0
80102b20:	6a 2c                	push   $0x2c
80102b22:	e8 87 fe ff ff       	call   801029ae <lapicw>
80102b27:	83 c4 08             	add    $0x8,%esp
}
80102b2a:	90                   	nop
80102b2b:	c9                   	leave  
80102b2c:	c3                   	ret    

80102b2d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b2d:	55                   	push   %ebp
80102b2e:	89 e5                	mov    %esp,%ebp
}
80102b30:	90                   	nop
80102b31:	5d                   	pop    %ebp
80102b32:	c3                   	ret    

80102b33 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b33:	55                   	push   %ebp
80102b34:	89 e5                	mov    %esp,%ebp
80102b36:	83 ec 14             	sub    $0x14,%esp
80102b39:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b3f:	6a 0f                	push   $0xf
80102b41:	6a 70                	push   $0x70
80102b43:	e8 45 fe ff ff       	call   8010298d <outb>
80102b48:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b4b:	6a 0a                	push   $0xa
80102b4d:	6a 71                	push   $0x71
80102b4f:	e8 39 fe ff ff       	call   8010298d <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b57:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b61:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b66:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b69:	c1 e8 04             	shr    $0x4,%eax
80102b6c:	89 c2                	mov    %eax,%edx
80102b6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b71:	83 c0 02             	add    $0x2,%eax
80102b74:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b77:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b7b:	c1 e0 18             	shl    $0x18,%eax
80102b7e:	50                   	push   %eax
80102b7f:	68 c4 00 00 00       	push   $0xc4
80102b84:	e8 25 fe ff ff       	call   801029ae <lapicw>
80102b89:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b8c:	68 00 c5 00 00       	push   $0xc500
80102b91:	68 c0 00 00 00       	push   $0xc0
80102b96:	e8 13 fe ff ff       	call   801029ae <lapicw>
80102b9b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b9e:	68 c8 00 00 00       	push   $0xc8
80102ba3:	e8 85 ff ff ff       	call   80102b2d <microdelay>
80102ba8:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bab:	68 00 85 00 00       	push   $0x8500
80102bb0:	68 c0 00 00 00       	push   $0xc0
80102bb5:	e8 f4 fd ff ff       	call   801029ae <lapicw>
80102bba:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bbd:	6a 64                	push   $0x64
80102bbf:	e8 69 ff ff ff       	call   80102b2d <microdelay>
80102bc4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bc7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bce:	eb 3d                	jmp    80102c0d <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bd0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bd4:	c1 e0 18             	shl    $0x18,%eax
80102bd7:	50                   	push   %eax
80102bd8:	68 c4 00 00 00       	push   $0xc4
80102bdd:	e8 cc fd ff ff       	call   801029ae <lapicw>
80102be2:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102be5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102be8:	c1 e8 0c             	shr    $0xc,%eax
80102beb:	80 cc 06             	or     $0x6,%ah
80102bee:	50                   	push   %eax
80102bef:	68 c0 00 00 00       	push   $0xc0
80102bf4:	e8 b5 fd ff ff       	call   801029ae <lapicw>
80102bf9:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bfc:	68 c8 00 00 00       	push   $0xc8
80102c01:	e8 27 ff ff ff       	call   80102b2d <microdelay>
80102c06:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c0d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c11:	7e bd                	jle    80102bd0 <lapicstartap+0x9d>
  }
}
80102c13:	90                   	nop
80102c14:	90                   	nop
80102c15:	c9                   	leave  
80102c16:	c3                   	ret    

80102c17 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c17:	55                   	push   %ebp
80102c18:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1d:	0f b6 c0             	movzbl %al,%eax
80102c20:	50                   	push   %eax
80102c21:	6a 70                	push   $0x70
80102c23:	e8 65 fd ff ff       	call   8010298d <outb>
80102c28:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c2b:	68 c8 00 00 00       	push   $0xc8
80102c30:	e8 f8 fe ff ff       	call   80102b2d <microdelay>
80102c35:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c38:	6a 71                	push   $0x71
80102c3a:	e8 31 fd ff ff       	call   80102970 <inb>
80102c3f:	83 c4 04             	add    $0x4,%esp
80102c42:	0f b6 c0             	movzbl %al,%eax
}
80102c45:	c9                   	leave  
80102c46:	c3                   	ret    

80102c47 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c47:	55                   	push   %ebp
80102c48:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c4a:	6a 00                	push   $0x0
80102c4c:	e8 c6 ff ff ff       	call   80102c17 <cmos_read>
80102c51:	83 c4 04             	add    $0x4,%esp
80102c54:	8b 55 08             	mov    0x8(%ebp),%edx
80102c57:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c59:	6a 02                	push   $0x2
80102c5b:	e8 b7 ff ff ff       	call   80102c17 <cmos_read>
80102c60:	83 c4 04             	add    $0x4,%esp
80102c63:	8b 55 08             	mov    0x8(%ebp),%edx
80102c66:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c69:	6a 04                	push   $0x4
80102c6b:	e8 a7 ff ff ff       	call   80102c17 <cmos_read>
80102c70:	83 c4 04             	add    $0x4,%esp
80102c73:	8b 55 08             	mov    0x8(%ebp),%edx
80102c76:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c79:	6a 07                	push   $0x7
80102c7b:	e8 97 ff ff ff       	call   80102c17 <cmos_read>
80102c80:	83 c4 04             	add    $0x4,%esp
80102c83:	8b 55 08             	mov    0x8(%ebp),%edx
80102c86:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c89:	6a 08                	push   $0x8
80102c8b:	e8 87 ff ff ff       	call   80102c17 <cmos_read>
80102c90:	83 c4 04             	add    $0x4,%esp
80102c93:	8b 55 08             	mov    0x8(%ebp),%edx
80102c96:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c99:	6a 09                	push   $0x9
80102c9b:	e8 77 ff ff ff       	call   80102c17 <cmos_read>
80102ca0:	83 c4 04             	add    $0x4,%esp
80102ca3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca6:	89 42 14             	mov    %eax,0x14(%edx)
}
80102ca9:	90                   	nop
80102caa:	c9                   	leave  
80102cab:	c3                   	ret    

80102cac <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cac:	55                   	push   %ebp
80102cad:	89 e5                	mov    %esp,%ebp
80102caf:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cb2:	6a 0b                	push   $0xb
80102cb4:	e8 5e ff ff ff       	call   80102c17 <cmos_read>
80102cb9:	83 c4 04             	add    $0x4,%esp
80102cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc2:	83 e0 04             	and    $0x4,%eax
80102cc5:	85 c0                	test   %eax,%eax
80102cc7:	0f 94 c0             	sete   %al
80102cca:	0f b6 c0             	movzbl %al,%eax
80102ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cd0:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cd3:	50                   	push   %eax
80102cd4:	e8 6e ff ff ff       	call   80102c47 <fill_rtcdate>
80102cd9:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cdc:	6a 0a                	push   $0xa
80102cde:	e8 34 ff ff ff       	call   80102c17 <cmos_read>
80102ce3:	83 c4 04             	add    $0x4,%esp
80102ce6:	25 80 00 00 00       	and    $0x80,%eax
80102ceb:	85 c0                	test   %eax,%eax
80102ced:	75 27                	jne    80102d16 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cef:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cf2:	50                   	push   %eax
80102cf3:	e8 4f ff ff ff       	call   80102c47 <fill_rtcdate>
80102cf8:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cfb:	83 ec 04             	sub    $0x4,%esp
80102cfe:	6a 18                	push   $0x18
80102d00:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d03:	50                   	push   %eax
80102d04:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d07:	50                   	push   %eax
80102d08:	e8 13 1e 00 00       	call   80104b20 <memcmp>
80102d0d:	83 c4 10             	add    $0x10,%esp
80102d10:	85 c0                	test   %eax,%eax
80102d12:	74 05                	je     80102d19 <cmostime+0x6d>
80102d14:	eb ba                	jmp    80102cd0 <cmostime+0x24>
        continue;
80102d16:	90                   	nop
    fill_rtcdate(&t1);
80102d17:	eb b7                	jmp    80102cd0 <cmostime+0x24>
      break;
80102d19:	90                   	nop
  }

  // convert
  if(bcd) {
80102d1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d1e:	0f 84 b4 00 00 00    	je     80102dd8 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d24:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d27:	c1 e8 04             	shr    $0x4,%eax
80102d2a:	89 c2                	mov    %eax,%edx
80102d2c:	89 d0                	mov    %edx,%eax
80102d2e:	c1 e0 02             	shl    $0x2,%eax
80102d31:	01 d0                	add    %edx,%eax
80102d33:	01 c0                	add    %eax,%eax
80102d35:	89 c2                	mov    %eax,%edx
80102d37:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d3a:	83 e0 0f             	and    $0xf,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d42:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d45:	c1 e8 04             	shr    $0x4,%eax
80102d48:	89 c2                	mov    %eax,%edx
80102d4a:	89 d0                	mov    %edx,%eax
80102d4c:	c1 e0 02             	shl    $0x2,%eax
80102d4f:	01 d0                	add    %edx,%eax
80102d51:	01 c0                	add    %eax,%eax
80102d53:	89 c2                	mov    %eax,%edx
80102d55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d58:	83 e0 0f             	and    $0xf,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d63:	c1 e8 04             	shr    $0x4,%eax
80102d66:	89 c2                	mov    %eax,%edx
80102d68:	89 d0                	mov    %edx,%eax
80102d6a:	c1 e0 02             	shl    $0x2,%eax
80102d6d:	01 d0                	add    %edx,%eax
80102d6f:	01 c0                	add    %eax,%eax
80102d71:	89 c2                	mov    %eax,%edx
80102d73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d76:	83 e0 0f             	and    $0xf,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d81:	c1 e8 04             	shr    $0x4,%eax
80102d84:	89 c2                	mov    %eax,%edx
80102d86:	89 d0                	mov    %edx,%eax
80102d88:	c1 e0 02             	shl    $0x2,%eax
80102d8b:	01 d0                	add    %edx,%eax
80102d8d:	01 c0                	add    %eax,%eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d94:	83 e0 0f             	and    $0xf,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d9f:	c1 e8 04             	shr    $0x4,%eax
80102da2:	89 c2                	mov    %eax,%edx
80102da4:	89 d0                	mov    %edx,%eax
80102da6:	c1 e0 02             	shl    $0x2,%eax
80102da9:	01 d0                	add    %edx,%eax
80102dab:	01 c0                	add    %eax,%eax
80102dad:	89 c2                	mov    %eax,%edx
80102daf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102db2:	83 e0 0f             	and    $0xf,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dbd:	c1 e8 04             	shr    $0x4,%eax
80102dc0:	89 c2                	mov    %eax,%edx
80102dc2:	89 d0                	mov    %edx,%eax
80102dc4:	c1 e0 02             	shl    $0x2,%eax
80102dc7:	01 d0                	add    %edx,%eax
80102dc9:	01 c0                	add    %eax,%eax
80102dcb:	89 c2                	mov    %eax,%edx
80102dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dd0:	83 e0 0f             	and    $0xf,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddb:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dde:	89 10                	mov    %edx,(%eax)
80102de0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102de3:	89 50 04             	mov    %edx,0x4(%eax)
80102de6:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102de9:	89 50 08             	mov    %edx,0x8(%eax)
80102dec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102def:	89 50 0c             	mov    %edx,0xc(%eax)
80102df2:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102df5:	89 50 10             	mov    %edx,0x10(%eax)
80102df8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102dfb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80102e01:	8b 40 14             	mov    0x14(%eax),%eax
80102e04:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e10:	90                   	nop
80102e11:	c9                   	leave  
80102e12:	c3                   	ret    

80102e13 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e13:	55                   	push   %ebp
80102e14:	89 e5                	mov    %esp,%ebp
80102e16:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e19:	83 ec 08             	sub    $0x8,%esp
80102e1c:	68 d5 a4 10 80       	push   $0x8010a4d5
80102e21:	68 20 41 19 80       	push   $0x80194120
80102e26:	e8 f6 19 00 00       	call   80104821 <initlock>
80102e2b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e2e:	83 ec 08             	sub    $0x8,%esp
80102e31:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e34:	50                   	push   %eax
80102e35:	ff 75 08             	push   0x8(%ebp)
80102e38:	e8 87 e5 ff ff       	call   801013c4 <readsb>
80102e3d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e43:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e4b:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e50:	8b 45 08             	mov    0x8(%ebp),%eax
80102e53:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e58:	e8 b3 01 00 00       	call   80103010 <recover_from_log>
}
80102e5d:	90                   	nop
80102e5e:	c9                   	leave  
80102e5f:	c3                   	ret    

80102e60 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e60:	55                   	push   %ebp
80102e61:	89 e5                	mov    %esp,%ebp
80102e63:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e6d:	e9 95 00 00 00       	jmp    80102f07 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e72:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7b:	01 d0                	add    %edx,%eax
80102e7d:	83 c0 01             	add    $0x1,%eax
80102e80:	89 c2                	mov    %eax,%edx
80102e82:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e87:	83 ec 08             	sub    $0x8,%esp
80102e8a:	52                   	push   %edx
80102e8b:	50                   	push   %eax
80102e8c:	e8 70 d3 ff ff       	call   80100201 <bread>
80102e91:	83 c4 10             	add    $0x10,%esp
80102e94:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9a:	83 c0 10             	add    $0x10,%eax
80102e9d:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102ea4:	89 c2                	mov    %eax,%edx
80102ea6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eab:	83 ec 08             	sub    $0x8,%esp
80102eae:	52                   	push   %edx
80102eaf:	50                   	push   %eax
80102eb0:	e8 4c d3 ff ff       	call   80100201 <bread>
80102eb5:	83 c4 10             	add    $0x10,%esp
80102eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ebe:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ec4:	83 c0 5c             	add    $0x5c,%eax
80102ec7:	83 ec 04             	sub    $0x4,%esp
80102eca:	68 00 02 00 00       	push   $0x200
80102ecf:	52                   	push   %edx
80102ed0:	50                   	push   %eax
80102ed1:	e8 a2 1c 00 00       	call   80104b78 <memmove>
80102ed6:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ed9:	83 ec 0c             	sub    $0xc,%esp
80102edc:	ff 75 ec             	push   -0x14(%ebp)
80102edf:	e8 56 d3 ff ff       	call   8010023a <bwrite>
80102ee4:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	ff 75 f0             	push   -0x10(%ebp)
80102eed:	e8 91 d3 ff ff       	call   80100283 <brelse>
80102ef2:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102ef5:	83 ec 0c             	sub    $0xc,%esp
80102ef8:	ff 75 ec             	push   -0x14(%ebp)
80102efb:	e8 83 d3 ff ff       	call   80100283 <brelse>
80102f00:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f07:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f0f:	0f 8c 5d ff ff ff    	jl     80102e72 <install_trans+0x12>
  }
}
80102f15:	90                   	nop
80102f16:	90                   	nop
80102f17:	c9                   	leave  
80102f18:	c3                   	ret    

80102f19 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f19:	55                   	push   %ebp
80102f1a:	89 e5                	mov    %esp,%ebp
80102f1c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f1f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f24:	89 c2                	mov    %eax,%edx
80102f26:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f2b:	83 ec 08             	sub    $0x8,%esp
80102f2e:	52                   	push   %edx
80102f2f:	50                   	push   %eax
80102f30:	e8 cc d2 ff ff       	call   80100201 <bread>
80102f35:	83 c4 10             	add    $0x10,%esp
80102f38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f3e:	83 c0 5c             	add    $0x5c,%eax
80102f41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f47:	8b 00                	mov    (%eax),%eax
80102f49:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f55:	eb 1b                	jmp    80102f72 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f5d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f64:	83 c2 10             	add    $0x10,%edx
80102f67:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f72:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f77:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f7a:	7c db                	jl     80102f57 <read_head+0x3e>
  }
  brelse(buf);
80102f7c:	83 ec 0c             	sub    $0xc,%esp
80102f7f:	ff 75 f0             	push   -0x10(%ebp)
80102f82:	e8 fc d2 ff ff       	call   80100283 <brelse>
80102f87:	83 c4 10             	add    $0x10,%esp
}
80102f8a:	90                   	nop
80102f8b:	c9                   	leave  
80102f8c:	c3                   	ret    

80102f8d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f8d:	55                   	push   %ebp
80102f8e:	89 e5                	mov    %esp,%ebp
80102f90:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f93:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f98:	89 c2                	mov    %eax,%edx
80102f9a:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f9f:	83 ec 08             	sub    $0x8,%esp
80102fa2:	52                   	push   %edx
80102fa3:	50                   	push   %eax
80102fa4:	e8 58 d2 ff ff       	call   80100201 <bread>
80102fa9:	83 c4 10             	add    $0x10,%esp
80102fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fb2:	83 c0 5c             	add    $0x5c,%eax
80102fb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fb8:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fca:	eb 1b                	jmp    80102fe7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcf:	83 c0 10             	add    $0x10,%eax
80102fd2:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fdf:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fe3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fe7:	a1 68 41 19 80       	mov    0x80194168,%eax
80102fec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fef:	7c db                	jl     80102fcc <write_head+0x3f>
  }
  bwrite(buf);
80102ff1:	83 ec 0c             	sub    $0xc,%esp
80102ff4:	ff 75 f0             	push   -0x10(%ebp)
80102ff7:	e8 3e d2 ff ff       	call   8010023a <bwrite>
80102ffc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102fff:	83 ec 0c             	sub    $0xc,%esp
80103002:	ff 75 f0             	push   -0x10(%ebp)
80103005:	e8 79 d2 ff ff       	call   80100283 <brelse>
8010300a:	83 c4 10             	add    $0x10,%esp
}
8010300d:	90                   	nop
8010300e:	c9                   	leave  
8010300f:	c3                   	ret    

80103010 <recover_from_log>:

static void
recover_from_log(void)
{
80103010:	55                   	push   %ebp
80103011:	89 e5                	mov    %esp,%ebp
80103013:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103016:	e8 fe fe ff ff       	call   80102f19 <read_head>
  install_trans(); // if committed, copy from log to disk
8010301b:	e8 40 fe ff ff       	call   80102e60 <install_trans>
  log.lh.n = 0;
80103020:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103027:	00 00 00 
  write_head(); // clear the log
8010302a:	e8 5e ff ff ff       	call   80102f8d <write_head>
}
8010302f:	90                   	nop
80103030:	c9                   	leave  
80103031:	c3                   	ret    

80103032 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103032:	55                   	push   %ebp
80103033:	89 e5                	mov    %esp,%ebp
80103035:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103038:	83 ec 0c             	sub    $0xc,%esp
8010303b:	68 20 41 19 80       	push   $0x80194120
80103040:	e8 fe 17 00 00       	call   80104843 <acquire>
80103045:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103048:	a1 60 41 19 80       	mov    0x80194160,%eax
8010304d:	85 c0                	test   %eax,%eax
8010304f:	74 17                	je     80103068 <begin_op+0x36>
      sleep(&log, &log.lock);
80103051:	83 ec 08             	sub    $0x8,%esp
80103054:	68 20 41 19 80       	push   $0x80194120
80103059:	68 20 41 19 80       	push   $0x80194120
8010305e:	e8 6c 12 00 00       	call   801042cf <sleep>
80103063:	83 c4 10             	add    $0x10,%esp
80103066:	eb e0                	jmp    80103048 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103068:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010306e:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103073:	8d 50 01             	lea    0x1(%eax),%edx
80103076:	89 d0                	mov    %edx,%eax
80103078:	c1 e0 02             	shl    $0x2,%eax
8010307b:	01 d0                	add    %edx,%eax
8010307d:	01 c0                	add    %eax,%eax
8010307f:	01 c8                	add    %ecx,%eax
80103081:	83 f8 1e             	cmp    $0x1e,%eax
80103084:	7e 17                	jle    8010309d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103086:	83 ec 08             	sub    $0x8,%esp
80103089:	68 20 41 19 80       	push   $0x80194120
8010308e:	68 20 41 19 80       	push   $0x80194120
80103093:	e8 37 12 00 00       	call   801042cf <sleep>
80103098:	83 c4 10             	add    $0x10,%esp
8010309b:	eb ab                	jmp    80103048 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010309d:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030a2:	83 c0 01             	add    $0x1,%eax
801030a5:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030aa:	83 ec 0c             	sub    $0xc,%esp
801030ad:	68 20 41 19 80       	push   $0x80194120
801030b2:	e8 fa 17 00 00       	call   801048b1 <release>
801030b7:	83 c4 10             	add    $0x10,%esp
      break;
801030ba:	90                   	nop
    }
  }
}
801030bb:	90                   	nop
801030bc:	c9                   	leave  
801030bd:	c3                   	ret    

801030be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030be:	55                   	push   %ebp
801030bf:	89 e5                	mov    %esp,%ebp
801030c1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030cb:	83 ec 0c             	sub    $0xc,%esp
801030ce:	68 20 41 19 80       	push   $0x80194120
801030d3:	e8 6b 17 00 00       	call   80104843 <acquire>
801030d8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030db:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030e0:	83 e8 01             	sub    $0x1,%eax
801030e3:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030e8:	a1 60 41 19 80       	mov    0x80194160,%eax
801030ed:	85 c0                	test   %eax,%eax
801030ef:	74 0d                	je     801030fe <end_op+0x40>
    panic("log.committing");
801030f1:	83 ec 0c             	sub    $0xc,%esp
801030f4:	68 d9 a4 10 80       	push   $0x8010a4d9
801030f9:	e8 ab d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030fe:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103103:	85 c0                	test   %eax,%eax
80103105:	75 13                	jne    8010311a <end_op+0x5c>
    do_commit = 1;
80103107:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010310e:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103115:	00 00 00 
80103118:	eb 10                	jmp    8010312a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010311a:	83 ec 0c             	sub    $0xc,%esp
8010311d:	68 20 41 19 80       	push   $0x80194120
80103122:	e8 8f 12 00 00       	call   801043b6 <wakeup>
80103127:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010312a:	83 ec 0c             	sub    $0xc,%esp
8010312d:	68 20 41 19 80       	push   $0x80194120
80103132:	e8 7a 17 00 00       	call   801048b1 <release>
80103137:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010313a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010313e:	74 3f                	je     8010317f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103140:	e8 f6 00 00 00       	call   8010323b <commit>
    acquire(&log.lock);
80103145:	83 ec 0c             	sub    $0xc,%esp
80103148:	68 20 41 19 80       	push   $0x80194120
8010314d:	e8 f1 16 00 00       	call   80104843 <acquire>
80103152:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103155:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
8010315c:	00 00 00 
    wakeup(&log);
8010315f:	83 ec 0c             	sub    $0xc,%esp
80103162:	68 20 41 19 80       	push   $0x80194120
80103167:	e8 4a 12 00 00       	call   801043b6 <wakeup>
8010316c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010316f:	83 ec 0c             	sub    $0xc,%esp
80103172:	68 20 41 19 80       	push   $0x80194120
80103177:	e8 35 17 00 00       	call   801048b1 <release>
8010317c:	83 c4 10             	add    $0x10,%esp
  }
}
8010317f:	90                   	nop
80103180:	c9                   	leave  
80103181:	c3                   	ret    

80103182 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103182:	55                   	push   %ebp
80103183:	89 e5                	mov    %esp,%ebp
80103185:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103188:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010318f:	e9 95 00 00 00       	jmp    80103229 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103194:	8b 15 54 41 19 80    	mov    0x80194154,%edx
8010319a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010319d:	01 d0                	add    %edx,%eax
8010319f:	83 c0 01             	add    $0x1,%eax
801031a2:	89 c2                	mov    %eax,%edx
801031a4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031a9:	83 ec 08             	sub    $0x8,%esp
801031ac:	52                   	push   %edx
801031ad:	50                   	push   %eax
801031ae:	e8 4e d0 ff ff       	call   80100201 <bread>
801031b3:	83 c4 10             	add    $0x10,%esp
801031b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031bc:	83 c0 10             	add    $0x10,%eax
801031bf:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031c6:	89 c2                	mov    %eax,%edx
801031c8:	a1 64 41 19 80       	mov    0x80194164,%eax
801031cd:	83 ec 08             	sub    $0x8,%esp
801031d0:	52                   	push   %edx
801031d1:	50                   	push   %eax
801031d2:	e8 2a d0 ff ff       	call   80100201 <bread>
801031d7:	83 c4 10             	add    $0x10,%esp
801031da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031e0:	8d 50 5c             	lea    0x5c(%eax),%edx
801031e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e6:	83 c0 5c             	add    $0x5c,%eax
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	68 00 02 00 00       	push   $0x200
801031f1:	52                   	push   %edx
801031f2:	50                   	push   %eax
801031f3:	e8 80 19 00 00       	call   80104b78 <memmove>
801031f8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031fb:	83 ec 0c             	sub    $0xc,%esp
801031fe:	ff 75 f0             	push   -0x10(%ebp)
80103201:	e8 34 d0 ff ff       	call   8010023a <bwrite>
80103206:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103209:	83 ec 0c             	sub    $0xc,%esp
8010320c:	ff 75 ec             	push   -0x14(%ebp)
8010320f:	e8 6f d0 ff ff       	call   80100283 <brelse>
80103214:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103217:	83 ec 0c             	sub    $0xc,%esp
8010321a:	ff 75 f0             	push   -0x10(%ebp)
8010321d:	e8 61 d0 ff ff       	call   80100283 <brelse>
80103222:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103225:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103229:	a1 68 41 19 80       	mov    0x80194168,%eax
8010322e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103231:	0f 8c 5d ff ff ff    	jl     80103194 <write_log+0x12>
  }
}
80103237:	90                   	nop
80103238:	90                   	nop
80103239:	c9                   	leave  
8010323a:	c3                   	ret    

8010323b <commit>:

static void
commit()
{
8010323b:	55                   	push   %ebp
8010323c:	89 e5                	mov    %esp,%ebp
8010323e:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103241:	a1 68 41 19 80       	mov    0x80194168,%eax
80103246:	85 c0                	test   %eax,%eax
80103248:	7e 1e                	jle    80103268 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010324a:	e8 33 ff ff ff       	call   80103182 <write_log>
    write_head();    // Write header to disk -- the real commit
8010324f:	e8 39 fd ff ff       	call   80102f8d <write_head>
    install_trans(); // Now install writes to home locations
80103254:	e8 07 fc ff ff       	call   80102e60 <install_trans>
    log.lh.n = 0;
80103259:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103260:	00 00 00 
    write_head();    // Erase the transaction from the log
80103263:	e8 25 fd ff ff       	call   80102f8d <write_head>
  }
}
80103268:	90                   	nop
80103269:	c9                   	leave  
8010326a:	c3                   	ret    

8010326b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010326b:	55                   	push   %ebp
8010326c:	89 e5                	mov    %esp,%ebp
8010326e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103271:	a1 68 41 19 80       	mov    0x80194168,%eax
80103276:	83 f8 1d             	cmp    $0x1d,%eax
80103279:	7f 12                	jg     8010328d <log_write+0x22>
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103286:	83 ea 01             	sub    $0x1,%edx
80103289:	39 d0                	cmp    %edx,%eax
8010328b:	7c 0d                	jl     8010329a <log_write+0x2f>
    panic("too big a transaction");
8010328d:	83 ec 0c             	sub    $0xc,%esp
80103290:	68 e8 a4 10 80       	push   $0x8010a4e8
80103295:	e8 0f d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
8010329a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010329f:	85 c0                	test   %eax,%eax
801032a1:	7f 0d                	jg     801032b0 <log_write+0x45>
    panic("log_write outside of trans");
801032a3:	83 ec 0c             	sub    $0xc,%esp
801032a6:	68 fe a4 10 80       	push   $0x8010a4fe
801032ab:	e8 f9 d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032b0:	83 ec 0c             	sub    $0xc,%esp
801032b3:	68 20 41 19 80       	push   $0x80194120
801032b8:	e8 86 15 00 00       	call   80104843 <acquire>
801032bd:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032c7:	eb 1d                	jmp    801032e6 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032cc:	83 c0 10             	add    $0x10,%eax
801032cf:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032d6:	89 c2                	mov    %eax,%edx
801032d8:	8b 45 08             	mov    0x8(%ebp),%eax
801032db:	8b 40 08             	mov    0x8(%eax),%eax
801032de:	39 c2                	cmp    %eax,%edx
801032e0:	74 10                	je     801032f2 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032e6:	a1 68 41 19 80       	mov    0x80194168,%eax
801032eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032ee:	7c d9                	jl     801032c9 <log_write+0x5e>
801032f0:	eb 01                	jmp    801032f3 <log_write+0x88>
      break;
801032f2:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032f3:	8b 45 08             	mov    0x8(%ebp),%eax
801032f6:	8b 40 08             	mov    0x8(%eax),%eax
801032f9:	89 c2                	mov    %eax,%edx
801032fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032fe:	83 c0 10             	add    $0x10,%eax
80103301:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103308:	a1 68 41 19 80       	mov    0x80194168,%eax
8010330d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103310:	75 0d                	jne    8010331f <log_write+0xb4>
    log.lh.n++;
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	83 c0 01             	add    $0x1,%eax
8010331a:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010331f:	8b 45 08             	mov    0x8(%ebp),%eax
80103322:	8b 00                	mov    (%eax),%eax
80103324:	83 c8 04             	or     $0x4,%eax
80103327:	89 c2                	mov    %eax,%edx
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010332e:	83 ec 0c             	sub    $0xc,%esp
80103331:	68 20 41 19 80       	push   $0x80194120
80103336:	e8 76 15 00 00       	call   801048b1 <release>
8010333b:	83 c4 10             	add    $0x10,%esp
}
8010333e:	90                   	nop
8010333f:	c9                   	leave  
80103340:	c3                   	ret    

80103341 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103341:	55                   	push   %ebp
80103342:	89 e5                	mov    %esp,%ebp
80103344:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103347:	8b 55 08             	mov    0x8(%ebp),%edx
8010334a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010334d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103350:	f0 87 02             	lock xchg %eax,(%edx)
80103353:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103356:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103359:	c9                   	leave  
8010335a:	c3                   	ret    

8010335b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010335b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010335f:	83 e4 f0             	and    $0xfffffff0,%esp
80103362:	ff 71 fc             	push   -0x4(%ecx)
80103365:	55                   	push   %ebp
80103366:	89 e5                	mov    %esp,%ebp
80103368:	51                   	push   %ecx
80103369:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010336c:	e8 c8 4c 00 00       	call   80108039 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103371:	83 ec 08             	sub    $0x8,%esp
80103374:	68 00 00 40 80       	push   $0x80400000
80103379:	68 00 80 19 80       	push   $0x80198000
8010337e:	e8 de f2 ff ff       	call   80102661 <kinit1>
80103383:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103386:	e8 ad 42 00 00       	call   80107638 <kvmalloc>
  mpinit_uefi();
8010338b:	e8 6f 4a 00 00       	call   80107dff <mpinit_uefi>
  lapicinit();     // interrupt controller
80103390:	e8 3c f6 ff ff       	call   801029d1 <lapicinit>
  seginit();       // segment descriptors
80103395:	e8 36 3d 00 00       	call   801070d0 <seginit>
  picinit();    // disable pic
8010339a:	e8 9d 01 00 00       	call   8010353c <picinit>
  ioapicinit();    // another interrupt controller
8010339f:	e8 d8 f1 ff ff       	call   8010257c <ioapicinit>
  consoleinit();   // console hardware
801033a4:	e8 56 d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033a9:	e8 bb 30 00 00       	call   80106469 <uartinit>
  pinit();         // process table
801033ae:	e8 c2 05 00 00       	call   80103975 <pinit>
  tvinit();        // trap vectors
801033b3:	e8 7a 2b 00 00       	call   80105f32 <tvinit>
  binit();         // buffer cache
801033b8:	e8 a9 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033bd:	e8 f3 db ff ff       	call   80100fb5 <fileinit>
  ideinit();       // disk 
801033c2:	e8 b3 6d 00 00       	call   8010a17a <ideinit>
  startothers();   // start other processors
801033c7:	e8 8a 00 00 00       	call   80103456 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033cc:	83 ec 08             	sub    $0x8,%esp
801033cf:	68 00 00 00 a0       	push   $0xa0000000
801033d4:	68 00 00 40 80       	push   $0x80400000
801033d9:	e8 bc f2 ff ff       	call   8010269a <kinit2>
801033de:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033e1:	e8 ac 4e 00 00       	call   80108292 <pci_init>
  arp_scan();
801033e6:	e8 e3 5b 00 00       	call   80108fce <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033eb:	e8 63 07 00 00       	call   80103b53 <userinit>

  mpmain();        // finish this processor's setup
801033f0:	e8 1a 00 00 00       	call   8010340f <mpmain>

801033f5 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033f5:	55                   	push   %ebp
801033f6:	89 e5                	mov    %esp,%ebp
801033f8:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033fb:	e8 50 42 00 00       	call   80107650 <switchkvm>
  seginit();
80103400:	e8 cb 3c 00 00       	call   801070d0 <seginit>
  lapicinit();
80103405:	e8 c7 f5 ff ff       	call   801029d1 <lapicinit>
  mpmain();
8010340a:	e8 00 00 00 00       	call   8010340f <mpmain>

8010340f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010340f:	55                   	push   %ebp
80103410:	89 e5                	mov    %esp,%ebp
80103412:	53                   	push   %ebx
80103413:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103416:	e8 78 05 00 00       	call   80103993 <cpuid>
8010341b:	89 c3                	mov    %eax,%ebx
8010341d:	e8 71 05 00 00       	call   80103993 <cpuid>
80103422:	83 ec 04             	sub    $0x4,%esp
80103425:	53                   	push   %ebx
80103426:	50                   	push   %eax
80103427:	68 19 a5 10 80       	push   $0x8010a519
8010342c:	e8 c3 cf ff ff       	call   801003f4 <cprintf>
80103431:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103434:	e8 6f 2c 00 00       	call   801060a8 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103439:	e8 70 05 00 00       	call   801039ae <mycpu>
8010343e:	05 a0 00 00 00       	add    $0xa0,%eax
80103443:	83 ec 08             	sub    $0x8,%esp
80103446:	6a 01                	push   $0x1
80103448:	50                   	push   %eax
80103449:	e8 f3 fe ff ff       	call   80103341 <xchg>
8010344e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103451:	e8 88 0c 00 00       	call   801040de <scheduler>

80103456 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103456:	55                   	push   %ebp
80103457:	89 e5                	mov    %esp,%ebp
80103459:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010345c:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103463:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103468:	83 ec 04             	sub    $0x4,%esp
8010346b:	50                   	push   %eax
8010346c:	68 18 f5 10 80       	push   $0x8010f518
80103471:	ff 75 f0             	push   -0x10(%ebp)
80103474:	e8 ff 16 00 00       	call   80104b78 <memmove>
80103479:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010347c:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
80103483:	eb 79                	jmp    801034fe <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103485:	e8 24 05 00 00       	call   801039ae <mycpu>
8010348a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010348d:	74 67                	je     801034f6 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010348f:	e8 02 f3 ff ff       	call   80102796 <kalloc>
80103494:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349a:	83 e8 04             	sub    $0x4,%eax
8010349d:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034a0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034a6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ab:	83 e8 08             	sub    $0x8,%eax
801034ae:	c7 00 f5 33 10 80    	movl   $0x801033f5,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034b4:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034b9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c2:	83 e8 0c             	sub    $0xc,%eax
801034c5:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ca:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034d3:	0f b6 00             	movzbl (%eax),%eax
801034d6:	0f b6 c0             	movzbl %al,%eax
801034d9:	83 ec 08             	sub    $0x8,%esp
801034dc:	52                   	push   %edx
801034dd:	50                   	push   %eax
801034de:	e8 50 f6 ff ff       	call   80102b33 <lapicstartap>
801034e3:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034e6:	90                   	nop
801034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ea:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034f0:	85 c0                	test   %eax,%eax
801034f2:	74 f3                	je     801034e7 <startothers+0x91>
801034f4:	eb 01                	jmp    801034f7 <startothers+0xa1>
      continue;
801034f6:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034f7:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801034fe:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103503:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103509:	05 80 69 19 80       	add    $0x80196980,%eax
8010350e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103511:	0f 82 6e ff ff ff    	jb     80103485 <startothers+0x2f>
      ;
  }
}
80103517:	90                   	nop
80103518:	90                   	nop
80103519:	c9                   	leave  
8010351a:	c3                   	ret    

8010351b <outb>:
{
8010351b:	55                   	push   %ebp
8010351c:	89 e5                	mov    %esp,%ebp
8010351e:	83 ec 08             	sub    $0x8,%esp
80103521:	8b 45 08             	mov    0x8(%ebp),%eax
80103524:	8b 55 0c             	mov    0xc(%ebp),%edx
80103527:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010352b:	89 d0                	mov    %edx,%eax
8010352d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103530:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103534:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103538:	ee                   	out    %al,(%dx)
}
80103539:	90                   	nop
8010353a:	c9                   	leave  
8010353b:	c3                   	ret    

8010353c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010353c:	55                   	push   %ebp
8010353d:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010353f:	68 ff 00 00 00       	push   $0xff
80103544:	6a 21                	push   $0x21
80103546:	e8 d0 ff ff ff       	call   8010351b <outb>
8010354b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010354e:	68 ff 00 00 00       	push   $0xff
80103553:	68 a1 00 00 00       	push   $0xa1
80103558:	e8 be ff ff ff       	call   8010351b <outb>
8010355d:	83 c4 08             	add    $0x8,%esp
}
80103560:	90                   	nop
80103561:	c9                   	leave  
80103562:	c3                   	ret    

80103563 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103563:	55                   	push   %ebp
80103564:	89 e5                	mov    %esp,%ebp
80103566:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103570:	8b 45 0c             	mov    0xc(%ebp),%eax
80103573:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357c:	8b 10                	mov    (%eax),%edx
8010357e:	8b 45 08             	mov    0x8(%ebp),%eax
80103581:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103583:	e8 4b da ff ff       	call   80100fd3 <filealloc>
80103588:	8b 55 08             	mov    0x8(%ebp),%edx
8010358b:	89 02                	mov    %eax,(%edx)
8010358d:	8b 45 08             	mov    0x8(%ebp),%eax
80103590:	8b 00                	mov    (%eax),%eax
80103592:	85 c0                	test   %eax,%eax
80103594:	0f 84 c8 00 00 00    	je     80103662 <pipealloc+0xff>
8010359a:	e8 34 da ff ff       	call   80100fd3 <filealloc>
8010359f:	8b 55 0c             	mov    0xc(%ebp),%edx
801035a2:	89 02                	mov    %eax,(%edx)
801035a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801035a7:	8b 00                	mov    (%eax),%eax
801035a9:	85 c0                	test   %eax,%eax
801035ab:	0f 84 b1 00 00 00    	je     80103662 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035b1:	e8 e0 f1 ff ff       	call   80102796 <kalloc>
801035b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035bd:	0f 84 a2 00 00 00    	je     80103665 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035cd:	00 00 00 
  p->writeopen = 1;
801035d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d3:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035da:	00 00 00 
  p->nwrite = 0;
801035dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035e7:	00 00 00 
  p->nread = 0;
801035ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ed:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035f4:	00 00 00 
  initlock(&p->lock, "pipe");
801035f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035fa:	83 ec 08             	sub    $0x8,%esp
801035fd:	68 2d a5 10 80       	push   $0x8010a52d
80103602:	50                   	push   %eax
80103603:	e8 19 12 00 00       	call   80104821 <initlock>
80103608:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010360b:	8b 45 08             	mov    0x8(%ebp),%eax
8010360e:	8b 00                	mov    (%eax),%eax
80103610:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103616:	8b 45 08             	mov    0x8(%ebp),%eax
80103619:	8b 00                	mov    (%eax),%eax
8010361b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010361f:	8b 45 08             	mov    0x8(%ebp),%eax
80103622:	8b 00                	mov    (%eax),%eax
80103624:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103628:	8b 45 08             	mov    0x8(%ebp),%eax
8010362b:	8b 00                	mov    (%eax),%eax
8010362d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103630:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103633:	8b 45 0c             	mov    0xc(%ebp),%eax
80103636:	8b 00                	mov    (%eax),%eax
80103638:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010363e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103641:	8b 00                	mov    (%eax),%eax
80103643:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364a:	8b 00                	mov    (%eax),%eax
8010364c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103650:	8b 45 0c             	mov    0xc(%ebp),%eax
80103653:	8b 00                	mov    (%eax),%eax
80103655:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103658:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010365b:	b8 00 00 00 00       	mov    $0x0,%eax
80103660:	eb 51                	jmp    801036b3 <pipealloc+0x150>
    goto bad;
80103662:	90                   	nop
80103663:	eb 01                	jmp    80103666 <pipealloc+0x103>
    goto bad;
80103665:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103666:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010366a:	74 0e                	je     8010367a <pipealloc+0x117>
    kfree((char*)p);
8010366c:	83 ec 0c             	sub    $0xc,%esp
8010366f:	ff 75 f4             	push   -0xc(%ebp)
80103672:	e8 85 f0 ff ff       	call   801026fc <kfree>
80103677:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010367a:	8b 45 08             	mov    0x8(%ebp),%eax
8010367d:	8b 00                	mov    (%eax),%eax
8010367f:	85 c0                	test   %eax,%eax
80103681:	74 11                	je     80103694 <pipealloc+0x131>
    fileclose(*f0);
80103683:	8b 45 08             	mov    0x8(%ebp),%eax
80103686:	8b 00                	mov    (%eax),%eax
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	50                   	push   %eax
8010368c:	e8 00 da ff ff       	call   80101091 <fileclose>
80103691:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103694:	8b 45 0c             	mov    0xc(%ebp),%eax
80103697:	8b 00                	mov    (%eax),%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	74 11                	je     801036ae <pipealloc+0x14b>
    fileclose(*f1);
8010369d:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a0:	8b 00                	mov    (%eax),%eax
801036a2:	83 ec 0c             	sub    $0xc,%esp
801036a5:	50                   	push   %eax
801036a6:	e8 e6 d9 ff ff       	call   80101091 <fileclose>
801036ab:	83 c4 10             	add    $0x10,%esp
  return -1;
801036ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036b3:	c9                   	leave  
801036b4:	c3                   	ret    

801036b5 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036b5:	55                   	push   %ebp
801036b6:	89 e5                	mov    %esp,%ebp
801036b8:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036bb:	8b 45 08             	mov    0x8(%ebp),%eax
801036be:	83 ec 0c             	sub    $0xc,%esp
801036c1:	50                   	push   %eax
801036c2:	e8 7c 11 00 00       	call   80104843 <acquire>
801036c7:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036ce:	74 23                	je     801036f3 <pipeclose+0x3e>
    p->writeopen = 0;
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036da:	00 00 00 
    wakeup(&p->nread);
801036dd:	8b 45 08             	mov    0x8(%ebp),%eax
801036e0:	05 34 02 00 00       	add    $0x234,%eax
801036e5:	83 ec 0c             	sub    $0xc,%esp
801036e8:	50                   	push   %eax
801036e9:	e8 c8 0c 00 00       	call   801043b6 <wakeup>
801036ee:	83 c4 10             	add    $0x10,%esp
801036f1:	eb 21                	jmp    80103714 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036fd:	00 00 00 
    wakeup(&p->nwrite);
80103700:	8b 45 08             	mov    0x8(%ebp),%eax
80103703:	05 38 02 00 00       	add    $0x238,%eax
80103708:	83 ec 0c             	sub    $0xc,%esp
8010370b:	50                   	push   %eax
8010370c:	e8 a5 0c 00 00       	call   801043b6 <wakeup>
80103711:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103714:	8b 45 08             	mov    0x8(%ebp),%eax
80103717:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010371d:	85 c0                	test   %eax,%eax
8010371f:	75 2c                	jne    8010374d <pipeclose+0x98>
80103721:	8b 45 08             	mov    0x8(%ebp),%eax
80103724:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010372a:	85 c0                	test   %eax,%eax
8010372c:	75 1f                	jne    8010374d <pipeclose+0x98>
    release(&p->lock);
8010372e:	8b 45 08             	mov    0x8(%ebp),%eax
80103731:	83 ec 0c             	sub    $0xc,%esp
80103734:	50                   	push   %eax
80103735:	e8 77 11 00 00       	call   801048b1 <release>
8010373a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010373d:	83 ec 0c             	sub    $0xc,%esp
80103740:	ff 75 08             	push   0x8(%ebp)
80103743:	e8 b4 ef ff ff       	call   801026fc <kfree>
80103748:	83 c4 10             	add    $0x10,%esp
8010374b:	eb 10                	jmp    8010375d <pipeclose+0xa8>
  } else
    release(&p->lock);
8010374d:	8b 45 08             	mov    0x8(%ebp),%eax
80103750:	83 ec 0c             	sub    $0xc,%esp
80103753:	50                   	push   %eax
80103754:	e8 58 11 00 00       	call   801048b1 <release>
80103759:	83 c4 10             	add    $0x10,%esp
}
8010375c:	90                   	nop
8010375d:	90                   	nop
8010375e:	c9                   	leave  
8010375f:	c3                   	ret    

80103760 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103760:	55                   	push   %ebp
80103761:	89 e5                	mov    %esp,%ebp
80103763:	53                   	push   %ebx
80103764:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103767:	8b 45 08             	mov    0x8(%ebp),%eax
8010376a:	83 ec 0c             	sub    $0xc,%esp
8010376d:	50                   	push   %eax
8010376e:	e8 d0 10 00 00       	call   80104843 <acquire>
80103773:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103776:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010377d:	e9 ad 00 00 00       	jmp    8010382f <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103782:	8b 45 08             	mov    0x8(%ebp),%eax
80103785:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010378b:	85 c0                	test   %eax,%eax
8010378d:	74 0c                	je     8010379b <pipewrite+0x3b>
8010378f:	e8 92 02 00 00       	call   80103a26 <myproc>
80103794:	8b 40 24             	mov    0x24(%eax),%eax
80103797:	85 c0                	test   %eax,%eax
80103799:	74 19                	je     801037b4 <pipewrite+0x54>
        release(&p->lock);
8010379b:	8b 45 08             	mov    0x8(%ebp),%eax
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	50                   	push   %eax
801037a2:	e8 0a 11 00 00       	call   801048b1 <release>
801037a7:	83 c4 10             	add    $0x10,%esp
        return -1;
801037aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037af:	e9 a9 00 00 00       	jmp    8010385d <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037b4:	8b 45 08             	mov    0x8(%ebp),%eax
801037b7:	05 34 02 00 00       	add    $0x234,%eax
801037bc:	83 ec 0c             	sub    $0xc,%esp
801037bf:	50                   	push   %eax
801037c0:	e8 f1 0b 00 00       	call   801043b6 <wakeup>
801037c5:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037c8:	8b 45 08             	mov    0x8(%ebp),%eax
801037cb:	8b 55 08             	mov    0x8(%ebp),%edx
801037ce:	81 c2 38 02 00 00    	add    $0x238,%edx
801037d4:	83 ec 08             	sub    $0x8,%esp
801037d7:	50                   	push   %eax
801037d8:	52                   	push   %edx
801037d9:	e8 f1 0a 00 00       	call   801042cf <sleep>
801037de:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037ea:	8b 45 08             	mov    0x8(%ebp),%eax
801037ed:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037f3:	05 00 02 00 00       	add    $0x200,%eax
801037f8:	39 c2                	cmp    %eax,%edx
801037fa:	74 86                	je     80103782 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103805:	8b 45 08             	mov    0x8(%ebp),%eax
80103808:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010380e:	8d 48 01             	lea    0x1(%eax),%ecx
80103811:	8b 55 08             	mov    0x8(%ebp),%edx
80103814:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010381a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010381f:	89 c1                	mov    %eax,%ecx
80103821:	0f b6 13             	movzbl (%ebx),%edx
80103824:	8b 45 08             	mov    0x8(%ebp),%eax
80103827:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010382b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010382f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103832:	3b 45 10             	cmp    0x10(%ebp),%eax
80103835:	7c aa                	jl     801037e1 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103837:	8b 45 08             	mov    0x8(%ebp),%eax
8010383a:	05 34 02 00 00       	add    $0x234,%eax
8010383f:	83 ec 0c             	sub    $0xc,%esp
80103842:	50                   	push   %eax
80103843:	e8 6e 0b 00 00       	call   801043b6 <wakeup>
80103848:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010384b:	8b 45 08             	mov    0x8(%ebp),%eax
8010384e:	83 ec 0c             	sub    $0xc,%esp
80103851:	50                   	push   %eax
80103852:	e8 5a 10 00 00       	call   801048b1 <release>
80103857:	83 c4 10             	add    $0x10,%esp
  return n;
8010385a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010385d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103860:	c9                   	leave  
80103861:	c3                   	ret    

80103862 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103862:	55                   	push   %ebp
80103863:	89 e5                	mov    %esp,%ebp
80103865:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103868:	8b 45 08             	mov    0x8(%ebp),%eax
8010386b:	83 ec 0c             	sub    $0xc,%esp
8010386e:	50                   	push   %eax
8010386f:	e8 cf 0f 00 00       	call   80104843 <acquire>
80103874:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103877:	eb 3e                	jmp    801038b7 <piperead+0x55>
    if(myproc()->killed){
80103879:	e8 a8 01 00 00       	call   80103a26 <myproc>
8010387e:	8b 40 24             	mov    0x24(%eax),%eax
80103881:	85 c0                	test   %eax,%eax
80103883:	74 19                	je     8010389e <piperead+0x3c>
      release(&p->lock);
80103885:	8b 45 08             	mov    0x8(%ebp),%eax
80103888:	83 ec 0c             	sub    $0xc,%esp
8010388b:	50                   	push   %eax
8010388c:	e8 20 10 00 00       	call   801048b1 <release>
80103891:	83 c4 10             	add    $0x10,%esp
      return -1;
80103894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103899:	e9 be 00 00 00       	jmp    8010395c <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010389e:	8b 45 08             	mov    0x8(%ebp),%eax
801038a1:	8b 55 08             	mov    0x8(%ebp),%edx
801038a4:	81 c2 34 02 00 00    	add    $0x234,%edx
801038aa:	83 ec 08             	sub    $0x8,%esp
801038ad:	50                   	push   %eax
801038ae:	52                   	push   %edx
801038af:	e8 1b 0a 00 00       	call   801042cf <sleep>
801038b4:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038b7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ba:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038c0:	8b 45 08             	mov    0x8(%ebp),%eax
801038c3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038c9:	39 c2                	cmp    %eax,%edx
801038cb:	75 0d                	jne    801038da <piperead+0x78>
801038cd:	8b 45 08             	mov    0x8(%ebp),%eax
801038d0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038d6:	85 c0                	test   %eax,%eax
801038d8:	75 9f                	jne    80103879 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038e1:	eb 48                	jmp    8010392b <piperead+0xc9>
    if(p->nread == p->nwrite)
801038e3:	8b 45 08             	mov    0x8(%ebp),%eax
801038e6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ec:	8b 45 08             	mov    0x8(%ebp),%eax
801038ef:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038f5:	39 c2                	cmp    %eax,%edx
801038f7:	74 3c                	je     80103935 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038f9:	8b 45 08             	mov    0x8(%ebp),%eax
801038fc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103902:	8d 48 01             	lea    0x1(%eax),%ecx
80103905:	8b 55 08             	mov    0x8(%ebp),%edx
80103908:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010390e:	25 ff 01 00 00       	and    $0x1ff,%eax
80103913:	89 c1                	mov    %eax,%ecx
80103915:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103918:	8b 45 0c             	mov    0xc(%ebp),%eax
8010391b:	01 c2                	add    %eax,%edx
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103925:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103927:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010392b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010392e:	3b 45 10             	cmp    0x10(%ebp),%eax
80103931:	7c b0                	jl     801038e3 <piperead+0x81>
80103933:	eb 01                	jmp    80103936 <piperead+0xd4>
      break;
80103935:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103936:	8b 45 08             	mov    0x8(%ebp),%eax
80103939:	05 38 02 00 00       	add    $0x238,%eax
8010393e:	83 ec 0c             	sub    $0xc,%esp
80103941:	50                   	push   %eax
80103942:	e8 6f 0a 00 00       	call   801043b6 <wakeup>
80103947:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010394a:	8b 45 08             	mov    0x8(%ebp),%eax
8010394d:	83 ec 0c             	sub    $0xc,%esp
80103950:	50                   	push   %eax
80103951:	e8 5b 0f 00 00       	call   801048b1 <release>
80103956:	83 c4 10             	add    $0x10,%esp
  return i;
80103959:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010395c:	c9                   	leave  
8010395d:	c3                   	ret    

8010395e <readeflags>:
{
8010395e:	55                   	push   %ebp
8010395f:	89 e5                	mov    %esp,%ebp
80103961:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103964:	9c                   	pushf  
80103965:	58                   	pop    %eax
80103966:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103969:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010396c:	c9                   	leave  
8010396d:	c3                   	ret    

8010396e <sti>:
{
8010396e:	55                   	push   %ebp
8010396f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103971:	fb                   	sti    
}
80103972:	90                   	nop
80103973:	5d                   	pop    %ebp
80103974:	c3                   	ret    

80103975 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103975:	55                   	push   %ebp
80103976:	89 e5                	mov    %esp,%ebp
80103978:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010397b:	83 ec 08             	sub    $0x8,%esp
8010397e:	68 34 a5 10 80       	push   $0x8010a534
80103983:	68 00 42 19 80       	push   $0x80194200
80103988:	e8 94 0e 00 00       	call   80104821 <initlock>
8010398d:	83 c4 10             	add    $0x10,%esp
}
80103990:	90                   	nop
80103991:	c9                   	leave  
80103992:	c3                   	ret    

80103993 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103993:	55                   	push   %ebp
80103994:	89 e5                	mov    %esp,%ebp
80103996:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103999:	e8 10 00 00 00       	call   801039ae <mycpu>
8010399e:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039a3:	c1 f8 04             	sar    $0x4,%eax
801039a6:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039ac:	c9                   	leave  
801039ad:	c3                   	ret    

801039ae <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039ae:	55                   	push   %ebp
801039af:	89 e5                	mov    %esp,%ebp
801039b1:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039b4:	e8 a5 ff ff ff       	call   8010395e <readeflags>
801039b9:	25 00 02 00 00       	and    $0x200,%eax
801039be:	85 c0                	test   %eax,%eax
801039c0:	74 0d                	je     801039cf <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039c2:	83 ec 0c             	sub    $0xc,%esp
801039c5:	68 3c a5 10 80       	push   $0x8010a53c
801039ca:	e8 da cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039cf:	e8 1c f1 ff ff       	call   80102af0 <lapicid>
801039d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039de:	eb 2d                	jmp    80103a0d <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039e9:	05 80 69 19 80       	add    $0x80196980,%eax
801039ee:	0f b6 00             	movzbl (%eax),%eax
801039f1:	0f b6 c0             	movzbl %al,%eax
801039f4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039f7:	75 10                	jne    80103a09 <mycpu+0x5b>
      return &cpus[i];
801039f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a02:	05 80 69 19 80       	add    $0x80196980,%eax
80103a07:	eb 1b                	jmp    80103a24 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a09:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a0d:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a12:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a15:	7c c9                	jl     801039e0 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a17:	83 ec 0c             	sub    $0xc,%esp
80103a1a:	68 62 a5 10 80       	push   $0x8010a562
80103a1f:	e8 85 cb ff ff       	call   801005a9 <panic>
}
80103a24:	c9                   	leave  
80103a25:	c3                   	ret    

80103a26 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a26:	55                   	push   %ebp
80103a27:	89 e5                	mov    %esp,%ebp
80103a29:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a2c:	e8 7d 0f 00 00       	call   801049ae <pushcli>
  c = mycpu();
80103a31:	e8 78 ff ff ff       	call   801039ae <mycpu>
80103a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a45:	e8 b1 0f 00 00       	call   801049fb <popcli>
  return p;
80103a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a4d:	c9                   	leave  
80103a4e:	c3                   	ret    

80103a4f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a55:	83 ec 0c             	sub    $0xc,%esp
80103a58:	68 00 42 19 80       	push   $0x80194200
80103a5d:	e8 e1 0d 00 00       	call   80104843 <acquire>
80103a62:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a65:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a6c:	eb 0e                	jmp    80103a7c <allocproc+0x2d>
    if(p->state == UNUSED){
80103a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a71:	8b 40 0c             	mov    0xc(%eax),%eax
80103a74:	85 c0                	test   %eax,%eax
80103a76:	74 27                	je     80103a9f <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a78:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a7c:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a83:	72 e9                	jb     80103a6e <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a85:	83 ec 0c             	sub    $0xc,%esp
80103a88:	68 00 42 19 80       	push   $0x80194200
80103a8d:	e8 1f 0e 00 00       	call   801048b1 <release>
80103a92:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a95:	b8 00 00 00 00       	mov    $0x0,%eax
80103a9a:	e9 b2 00 00 00       	jmp    80103b51 <allocproc+0x102>
      goto found;
80103a9f:	90                   	nop

found:
  p->state = EMBRYO;
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103aaa:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aaf:	8d 50 01             	lea    0x1(%eax),%edx
80103ab2:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103abb:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103abe:	83 ec 0c             	sub    $0xc,%esp
80103ac1:	68 00 42 19 80       	push   $0x80194200
80103ac6:	e8 e6 0d 00 00       	call   801048b1 <release>
80103acb:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ace:	e8 c3 ec ff ff       	call   80102796 <kalloc>
80103ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ad6:	89 42 08             	mov    %eax,0x8(%edx)
80103ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adc:	8b 40 08             	mov    0x8(%eax),%eax
80103adf:	85 c0                	test   %eax,%eax
80103ae1:	75 11                	jne    80103af4 <allocproc+0xa5>
    p->state = UNUSED;
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103aed:	b8 00 00 00 00       	mov    $0x0,%eax
80103af2:	eb 5d                	jmp    80103b51 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	8b 40 08             	mov    0x8(%eax),%eax
80103afa:	05 00 10 00 00       	add    $0x1000,%eax
80103aff:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b02:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b0c:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b0f:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b13:	ba e0 5e 10 80       	mov    $0x80105ee0,%edx
80103b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b1d:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b24:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b27:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b30:	83 ec 04             	sub    $0x4,%esp
80103b33:	6a 14                	push   $0x14
80103b35:	6a 00                	push   $0x0
80103b37:	50                   	push   %eax
80103b38:	e8 7c 0f 00 00       	call   80104ab9 <memset>
80103b3d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b43:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b46:	ba 89 42 10 80       	mov    $0x80104289,%edx
80103b4b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b51:	c9                   	leave  
80103b52:	c3                   	ret    

80103b53 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b53:	55                   	push   %ebp
80103b54:	89 e5                	mov    %esp,%ebp
80103b56:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b59:	e8 f1 fe ff ff       	call   80103a4f <allocproc>
80103b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b64:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b69:	e8 de 39 00 00       	call   8010754c <setupkvm>
80103b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b71:	89 42 04             	mov    %eax,0x4(%edx)
80103b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b77:	8b 40 04             	mov    0x4(%eax),%eax
80103b7a:	85 c0                	test   %eax,%eax
80103b7c:	75 0d                	jne    80103b8b <userinit+0x38>
    panic("userinit: out of memory?");
80103b7e:	83 ec 0c             	sub    $0xc,%esp
80103b81:	68 72 a5 10 80       	push   $0x8010a572
80103b86:	e8 1e ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b8b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b93:	8b 40 04             	mov    0x4(%eax),%eax
80103b96:	83 ec 04             	sub    $0x4,%esp
80103b99:	52                   	push   %edx
80103b9a:	68 ec f4 10 80       	push   $0x8010f4ec
80103b9f:	50                   	push   %eax
80103ba0:	e8 63 3c 00 00       	call   80107808 <inituvm>
80103ba5:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb4:	8b 40 18             	mov    0x18(%eax),%eax
80103bb7:	83 ec 04             	sub    $0x4,%esp
80103bba:	6a 4c                	push   $0x4c
80103bbc:	6a 00                	push   $0x0
80103bbe:	50                   	push   %eax
80103bbf:	e8 f5 0e 00 00       	call   80104ab9 <memset>
80103bc4:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bca:	8b 40 18             	mov    0x18(%eax),%eax
80103bcd:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd6:	8b 40 18             	mov    0x18(%eax),%eax
80103bd9:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be2:	8b 50 18             	mov    0x18(%eax),%edx
80103be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be8:	8b 40 18             	mov    0x18(%eax),%eax
80103beb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bef:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf6:	8b 50 18             	mov    0x18(%eax),%edx
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 18             	mov    0x18(%eax),%eax
80103bff:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c03:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	8b 40 18             	mov    0x18(%eax),%eax
80103c0d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	8b 40 18             	mov    0x18(%eax),%eax
80103c1a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8b 40 18             	mov    0x18(%eax),%eax
80103c27:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	83 c0 6c             	add    $0x6c,%eax
80103c34:	83 ec 04             	sub    $0x4,%esp
80103c37:	6a 10                	push   $0x10
80103c39:	68 8b a5 10 80       	push   $0x8010a58b
80103c3e:	50                   	push   %eax
80103c3f:	e8 78 10 00 00       	call   80104cbc <safestrcpy>
80103c44:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c47:	83 ec 0c             	sub    $0xc,%esp
80103c4a:	68 94 a5 10 80       	push   $0x8010a594
80103c4f:	e8 bf e8 ff ff       	call   80102513 <namei>
80103c54:	83 c4 10             	add    $0x10,%esp
80103c57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c5a:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c5d:	83 ec 0c             	sub    $0xc,%esp
80103c60:	68 00 42 19 80       	push   $0x80194200
80103c65:	e8 d9 0b 00 00       	call   80104843 <acquire>
80103c6a:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c70:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c77:	83 ec 0c             	sub    $0xc,%esp
80103c7a:	68 00 42 19 80       	push   $0x80194200
80103c7f:	e8 2d 0c 00 00       	call   801048b1 <release>
80103c84:	83 c4 10             	add    $0x10,%esp
}
80103c87:	90                   	nop
80103c88:	c9                   	leave  
80103c89:	c3                   	ret    

80103c8a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c8a:	55                   	push   %ebp
80103c8b:	89 e5                	mov    %esp,%ebp
80103c8d:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c90:	e8 91 fd ff ff       	call   80103a26 <myproc>
80103c95:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9b:	8b 00                	mov    (%eax),%eax
80103c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ca0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ca4:	7e 2e                	jle    80103cd4 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca6:	8b 55 08             	mov    0x8(%ebp),%edx
80103ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cac:	01 c2                	add    %eax,%edx
80103cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb1:	8b 40 04             	mov    0x4(%eax),%eax
80103cb4:	83 ec 04             	sub    $0x4,%esp
80103cb7:	52                   	push   %edx
80103cb8:	ff 75 f4             	push   -0xc(%ebp)
80103cbb:	50                   	push   %eax
80103cbc:	e8 84 3c 00 00       	call   80107945 <allocuvm>
80103cc1:	83 c4 10             	add    $0x10,%esp
80103cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ccb:	75 3b                	jne    80103d08 <growproc+0x7e>
      return -1;
80103ccd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cd2:	eb 4f                	jmp    80103d23 <growproc+0x99>
  } else if(n < 0){
80103cd4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cd8:	79 2e                	jns    80103d08 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cda:	8b 55 08             	mov    0x8(%ebp),%edx
80103cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce0:	01 c2                	add    %eax,%edx
80103ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce5:	8b 40 04             	mov    0x4(%eax),%eax
80103ce8:	83 ec 04             	sub    $0x4,%esp
80103ceb:	52                   	push   %edx
80103cec:	ff 75 f4             	push   -0xc(%ebp)
80103cef:	50                   	push   %eax
80103cf0:	e8 55 3d 00 00       	call   80107a4a <deallocuvm>
80103cf5:	83 c4 10             	add    $0x10,%esp
80103cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cff:	75 07                	jne    80103d08 <growproc+0x7e>
      return -1;
80103d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d06:	eb 1b                	jmp    80103d23 <growproc+0x99>
  }
  curproc->sz = sz;
80103d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d0e:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d10:	83 ec 0c             	sub    $0xc,%esp
80103d13:	ff 75 f0             	push   -0x10(%ebp)
80103d16:	e8 4e 39 00 00       	call   80107669 <switchuvm>
80103d1b:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d23:	c9                   	leave  
80103d24:	c3                   	ret    

80103d25 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d25:	55                   	push   %ebp
80103d26:	89 e5                	mov    %esp,%ebp
80103d28:	57                   	push   %edi
80103d29:	56                   	push   %esi
80103d2a:	53                   	push   %ebx
80103d2b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d2e:	e8 f3 fc ff ff       	call   80103a26 <myproc>
80103d33:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d36:	e8 14 fd ff ff       	call   80103a4f <allocproc>
80103d3b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d42:	75 0a                	jne    80103d4e <fork+0x29>
    return -1;
80103d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d49:	e9 48 01 00 00       	jmp    80103e96 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d51:	8b 10                	mov    (%eax),%edx
80103d53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d56:	8b 40 04             	mov    0x4(%eax),%eax
80103d59:	83 ec 08             	sub    $0x8,%esp
80103d5c:	52                   	push   %edx
80103d5d:	50                   	push   %eax
80103d5e:	e8 85 3e 00 00       	call   80107be8 <copyuvm>
80103d63:	83 c4 10             	add    $0x10,%esp
80103d66:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d69:	89 42 04             	mov    %eax,0x4(%edx)
80103d6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d6f:	8b 40 04             	mov    0x4(%eax),%eax
80103d72:	85 c0                	test   %eax,%eax
80103d74:	75 30                	jne    80103da6 <fork+0x81>
    kfree(np->kstack);
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 08             	mov    0x8(%eax),%eax
80103d7c:	83 ec 0c             	sub    $0xc,%esp
80103d7f:	50                   	push   %eax
80103d80:	e8 77 e9 ff ff       	call   801026fc <kfree>
80103d85:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103da1:	e9 f0 00 00 00       	jmp    80103e96 <fork+0x171>
  }
  np->sz = curproc->sz;
80103da6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da9:	8b 10                	mov    (%eax),%edx
80103dab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dae:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103db0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103db6:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbc:	8b 48 18             	mov    0x18(%eax),%ecx
80103dbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc2:	8b 40 18             	mov    0x18(%eax),%eax
80103dc5:	89 c2                	mov    %eax,%edx
80103dc7:	89 cb                	mov    %ecx,%ebx
80103dc9:	b8 13 00 00 00       	mov    $0x13,%eax
80103dce:	89 d7                	mov    %edx,%edi
80103dd0:	89 de                	mov    %ebx,%esi
80103dd2:	89 c1                	mov    %eax,%ecx
80103dd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd9:	8b 40 18             	mov    0x18(%eax),%eax
80103ddc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103de3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103dea:	eb 3b                	jmp    80103e27 <fork+0x102>
    if(curproc->ofile[i])
80103dec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103def:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103df2:	83 c2 08             	add    $0x8,%edx
80103df5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103df9:	85 c0                	test   %eax,%eax
80103dfb:	74 26                	je     80103e23 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e03:	83 c2 08             	add    $0x8,%edx
80103e06:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	50                   	push   %eax
80103e0e:	e8 2d d2 ff ff       	call   80101040 <filedup>
80103e13:	83 c4 10             	add    $0x10,%esp
80103e16:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e19:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e1c:	83 c1 08             	add    $0x8,%ecx
80103e1f:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e23:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e27:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e2b:	7e bf                	jle    80103dec <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e30:	8b 40 68             	mov    0x68(%eax),%eax
80103e33:	83 ec 0c             	sub    $0xc,%esp
80103e36:	50                   	push   %eax
80103e37:	e8 6a db ff ff       	call   801019a6 <idup>
80103e3c:	83 c4 10             	add    $0x10,%esp
80103e3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e42:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e48:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e4e:	83 c0 6c             	add    $0x6c,%eax
80103e51:	83 ec 04             	sub    $0x4,%esp
80103e54:	6a 10                	push   $0x10
80103e56:	52                   	push   %edx
80103e57:	50                   	push   %eax
80103e58:	e8 5f 0e 00 00       	call   80104cbc <safestrcpy>
80103e5d:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e63:	8b 40 10             	mov    0x10(%eax),%eax
80103e66:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e69:	83 ec 0c             	sub    $0xc,%esp
80103e6c:	68 00 42 19 80       	push   $0x80194200
80103e71:	e8 cd 09 00 00       	call   80104843 <acquire>
80103e76:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e83:	83 ec 0c             	sub    $0xc,%esp
80103e86:	68 00 42 19 80       	push   $0x80194200
80103e8b:	e8 21 0a 00 00       	call   801048b1 <release>
80103e90:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e93:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e99:	5b                   	pop    %ebx
80103e9a:	5e                   	pop    %esi
80103e9b:	5f                   	pop    %edi
80103e9c:	5d                   	pop    %ebp
80103e9d:	c3                   	ret    

80103e9e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103e9e:	55                   	push   %ebp
80103e9f:	89 e5                	mov    %esp,%ebp
80103ea1:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ea4:	e8 7d fb ff ff       	call   80103a26 <myproc>
80103ea9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eac:	a1 34 61 19 80       	mov    0x80196134,%eax
80103eb1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103eb4:	75 0d                	jne    80103ec3 <exit+0x25>
    panic("init exiting");
80103eb6:	83 ec 0c             	sub    $0xc,%esp
80103eb9:	68 96 a5 10 80       	push   $0x8010a596
80103ebe:	e8 e6 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ec3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103eca:	eb 3f                	jmp    80103f0b <exit+0x6d>
    if(curproc->ofile[fd]){
80103ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ecf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ed2:	83 c2 08             	add    $0x8,%edx
80103ed5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ed9:	85 c0                	test   %eax,%eax
80103edb:	74 2a                	je     80103f07 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee3:	83 c2 08             	add    $0x8,%edx
80103ee6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eea:	83 ec 0c             	sub    $0xc,%esp
80103eed:	50                   	push   %eax
80103eee:	e8 9e d1 ff ff       	call   80101091 <fileclose>
80103ef3:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103efc:	83 c2 08             	add    $0x8,%edx
80103eff:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f06:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f07:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f0b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f0f:	7e bb                	jle    80103ecc <exit+0x2e>
    }
  }

  begin_op();
80103f11:	e8 1c f1 ff ff       	call   80103032 <begin_op>
  iput(curproc->cwd);
80103f16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f19:	8b 40 68             	mov    0x68(%eax),%eax
80103f1c:	83 ec 0c             	sub    $0xc,%esp
80103f1f:	50                   	push   %eax
80103f20:	e8 1c dc ff ff       	call   80101b41 <iput>
80103f25:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f28:	e8 91 f1 ff ff       	call   801030be <end_op>
  curproc->cwd = 0;
80103f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f30:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f37:	83 ec 0c             	sub    $0xc,%esp
80103f3a:	68 00 42 19 80       	push   $0x80194200
80103f3f:	e8 ff 08 00 00       	call   80104843 <acquire>
80103f44:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4a:	8b 40 14             	mov    0x14(%eax),%eax
80103f4d:	83 ec 0c             	sub    $0xc,%esp
80103f50:	50                   	push   %eax
80103f51:	e8 20 04 00 00       	call   80104376 <wakeup1>
80103f56:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f59:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f60:	eb 37                	jmp    80103f99 <exit+0xfb>
    if(p->parent == curproc){
80103f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f65:	8b 40 14             	mov    0x14(%eax),%eax
80103f68:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f6b:	75 28                	jne    80103f95 <exit+0xf7>
      p->parent = initproc;
80103f6d:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f76:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7c:	8b 40 0c             	mov    0xc(%eax),%eax
80103f7f:	83 f8 05             	cmp    $0x5,%eax
80103f82:	75 11                	jne    80103f95 <exit+0xf7>
        wakeup1(initproc);
80103f84:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f89:	83 ec 0c             	sub    $0xc,%esp
80103f8c:	50                   	push   %eax
80103f8d:	e8 e4 03 00 00       	call   80104376 <wakeup1>
80103f92:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f95:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f99:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103fa0:	72 c0                	jb     80103f62 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fa2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fac:	e8 e5 01 00 00       	call   80104196 <sched>
  panic("zombie exit");
80103fb1:	83 ec 0c             	sub    $0xc,%esp
80103fb4:	68 a3 a5 10 80       	push   $0x8010a5a3
80103fb9:	e8 eb c5 ff ff       	call   801005a9 <panic>

80103fbe <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fbe:	55                   	push   %ebp
80103fbf:	89 e5                	mov    %esp,%ebp
80103fc1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fc4:	e8 5d fa ff ff       	call   80103a26 <myproc>
80103fc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fcc:	83 ec 0c             	sub    $0xc,%esp
80103fcf:	68 00 42 19 80       	push   $0x80194200
80103fd4:	e8 6a 08 00 00       	call   80104843 <acquire>
80103fd9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fdc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fe3:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fea:	e9 a1 00 00 00       	jmp    80104090 <wait+0xd2>
      if(p->parent != curproc)
80103fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff2:	8b 40 14             	mov    0x14(%eax),%eax
80103ff5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ff8:	0f 85 8d 00 00 00    	jne    8010408b <wait+0xcd>
        continue;
      havekids = 1;
80103ffe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104008:	8b 40 0c             	mov    0xc(%eax),%eax
8010400b:	83 f8 05             	cmp    $0x5,%eax
8010400e:	75 7c                	jne    8010408c <wait+0xce>
        // Found one.
        pid = p->pid;
80104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104013:	8b 40 10             	mov    0x10(%eax),%eax
80104016:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401c:	8b 40 08             	mov    0x8(%eax),%eax
8010401f:	83 ec 0c             	sub    $0xc,%esp
80104022:	50                   	push   %eax
80104023:	e8 d4 e6 ff ff       	call   801026fc <kfree>
80104028:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010402b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	8b 40 04             	mov    0x4(%eax),%eax
8010403b:	83 ec 0c             	sub    $0xc,%esp
8010403e:	50                   	push   %eax
8010403f:	e8 ca 3a 00 00       	call   80107b0e <freevm>
80104044:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104054:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104076:	83 ec 0c             	sub    $0xc,%esp
80104079:	68 00 42 19 80       	push   $0x80194200
8010407e:	e8 2e 08 00 00       	call   801048b1 <release>
80104083:	83 c4 10             	add    $0x10,%esp
        return pid;
80104086:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104089:	eb 51                	jmp    801040dc <wait+0x11e>
        continue;
8010408b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010408c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104090:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104097:	0f 82 52 ff ff ff    	jb     80103fef <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010409d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040a1:	74 0a                	je     801040ad <wait+0xef>
801040a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a6:	8b 40 24             	mov    0x24(%eax),%eax
801040a9:	85 c0                	test   %eax,%eax
801040ab:	74 17                	je     801040c4 <wait+0x106>
      release(&ptable.lock);
801040ad:	83 ec 0c             	sub    $0xc,%esp
801040b0:	68 00 42 19 80       	push   $0x80194200
801040b5:	e8 f7 07 00 00       	call   801048b1 <release>
801040ba:	83 c4 10             	add    $0x10,%esp
      return -1;
801040bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c2:	eb 18                	jmp    801040dc <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040c4:	83 ec 08             	sub    $0x8,%esp
801040c7:	68 00 42 19 80       	push   $0x80194200
801040cc:	ff 75 ec             	push   -0x14(%ebp)
801040cf:	e8 fb 01 00 00       	call   801042cf <sleep>
801040d4:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040d7:	e9 00 ff ff ff       	jmp    80103fdc <wait+0x1e>
  }
}
801040dc:	c9                   	leave  
801040dd:	c3                   	ret    

801040de <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040de:	55                   	push   %ebp
801040df:	89 e5                	mov    %esp,%ebp
801040e1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040e4:	e8 c5 f8 ff ff       	call   801039ae <mycpu>
801040e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ef:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801040f6:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801040f9:	e8 70 f8 ff ff       	call   8010396e <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801040fe:	83 ec 0c             	sub    $0xc,%esp
80104101:	68 00 42 19 80       	push   $0x80194200
80104106:	e8 38 07 00 00       	call   80104843 <acquire>
8010410b:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010410e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104115:	eb 61                	jmp    80104178 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411a:	8b 40 0c             	mov    0xc(%eax),%eax
8010411d:	83 f8 03             	cmp    $0x3,%eax
80104120:	75 51                	jne    80104173 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104125:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104128:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010412e:	83 ec 0c             	sub    $0xc,%esp
80104131:	ff 75 f4             	push   -0xc(%ebp)
80104134:	e8 30 35 00 00       	call   80107669 <switchuvm>
80104139:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010413c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	8b 40 1c             	mov    0x1c(%eax),%eax
8010414c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010414f:	83 c2 04             	add    $0x4,%edx
80104152:	83 ec 08             	sub    $0x8,%esp
80104155:	50                   	push   %eax
80104156:	52                   	push   %edx
80104157:	e8 d2 0b 00 00       	call   80104d2e <swtch>
8010415c:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010415f:	e8 ec 34 00 00       	call   80107650 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104167:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010416e:	00 00 00 
80104171:	eb 01                	jmp    80104174 <scheduler+0x96>
        continue;
80104173:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104174:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104178:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010417f:	72 96                	jb     80104117 <scheduler+0x39>
    }
    release(&ptable.lock);
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	68 00 42 19 80       	push   $0x80194200
80104189:	e8 23 07 00 00       	call   801048b1 <release>
8010418e:	83 c4 10             	add    $0x10,%esp
    sti();
80104191:	e9 63 ff ff ff       	jmp    801040f9 <scheduler+0x1b>

80104196 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104196:	55                   	push   %ebp
80104197:	89 e5                	mov    %esp,%ebp
80104199:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010419c:	e8 85 f8 ff ff       	call   80103a26 <myproc>
801041a1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041a4:	83 ec 0c             	sub    $0xc,%esp
801041a7:	68 00 42 19 80       	push   $0x80194200
801041ac:	e8 cd 07 00 00       	call   8010497e <holding>
801041b1:	83 c4 10             	add    $0x10,%esp
801041b4:	85 c0                	test   %eax,%eax
801041b6:	75 0d                	jne    801041c5 <sched+0x2f>
    panic("sched ptable.lock");
801041b8:	83 ec 0c             	sub    $0xc,%esp
801041bb:	68 af a5 10 80       	push   $0x8010a5af
801041c0:	e8 e4 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041c5:	e8 e4 f7 ff ff       	call   801039ae <mycpu>
801041ca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041d0:	83 f8 01             	cmp    $0x1,%eax
801041d3:	74 0d                	je     801041e2 <sched+0x4c>
    panic("sched locks");
801041d5:	83 ec 0c             	sub    $0xc,%esp
801041d8:	68 c1 a5 10 80       	push   $0x8010a5c1
801041dd:	e8 c7 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e5:	8b 40 0c             	mov    0xc(%eax),%eax
801041e8:	83 f8 04             	cmp    $0x4,%eax
801041eb:	75 0d                	jne    801041fa <sched+0x64>
    panic("sched running");
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	68 cd a5 10 80       	push   $0x8010a5cd
801041f5:	e8 af c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801041fa:	e8 5f f7 ff ff       	call   8010395e <readeflags>
801041ff:	25 00 02 00 00       	and    $0x200,%eax
80104204:	85 c0                	test   %eax,%eax
80104206:	74 0d                	je     80104215 <sched+0x7f>
    panic("sched interruptible");
80104208:	83 ec 0c             	sub    $0xc,%esp
8010420b:	68 db a5 10 80       	push   $0x8010a5db
80104210:	e8 94 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104215:	e8 94 f7 ff ff       	call   801039ae <mycpu>
8010421a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104220:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104223:	e8 86 f7 ff ff       	call   801039ae <mycpu>
80104228:	8b 40 04             	mov    0x4(%eax),%eax
8010422b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010422e:	83 c2 1c             	add    $0x1c,%edx
80104231:	83 ec 08             	sub    $0x8,%esp
80104234:	50                   	push   %eax
80104235:	52                   	push   %edx
80104236:	e8 f3 0a 00 00       	call   80104d2e <swtch>
8010423b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010423e:	e8 6b f7 ff ff       	call   801039ae <mycpu>
80104243:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104246:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010424c:	90                   	nop
8010424d:	c9                   	leave  
8010424e:	c3                   	ret    

8010424f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010424f:	55                   	push   %ebp
80104250:	89 e5                	mov    %esp,%ebp
80104252:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104255:	83 ec 0c             	sub    $0xc,%esp
80104258:	68 00 42 19 80       	push   $0x80194200
8010425d:	e8 e1 05 00 00       	call   80104843 <acquire>
80104262:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104265:	e8 bc f7 ff ff       	call   80103a26 <myproc>
8010426a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104271:	e8 20 ff ff ff       	call   80104196 <sched>
  release(&ptable.lock);
80104276:	83 ec 0c             	sub    $0xc,%esp
80104279:	68 00 42 19 80       	push   $0x80194200
8010427e:	e8 2e 06 00 00       	call   801048b1 <release>
80104283:	83 c4 10             	add    $0x10,%esp
}
80104286:	90                   	nop
80104287:	c9                   	leave  
80104288:	c3                   	ret    

80104289 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104289:	55                   	push   %ebp
8010428a:	89 e5                	mov    %esp,%ebp
8010428c:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010428f:	83 ec 0c             	sub    $0xc,%esp
80104292:	68 00 42 19 80       	push   $0x80194200
80104297:	e8 15 06 00 00       	call   801048b1 <release>
8010429c:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010429f:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042a4:	85 c0                	test   %eax,%eax
801042a6:	74 24                	je     801042cc <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042a8:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042af:	00 00 00 
    iinit(ROOTDEV);
801042b2:	83 ec 0c             	sub    $0xc,%esp
801042b5:	6a 01                	push   $0x1
801042b7:	e8 b2 d3 ff ff       	call   8010166e <iinit>
801042bc:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042bf:	83 ec 0c             	sub    $0xc,%esp
801042c2:	6a 01                	push   $0x1
801042c4:	e8 4a eb ff ff       	call   80102e13 <initlog>
801042c9:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042cc:	90                   	nop
801042cd:	c9                   	leave  
801042ce:	c3                   	ret    

801042cf <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042cf:	55                   	push   %ebp
801042d0:	89 e5                	mov    %esp,%ebp
801042d2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042d5:	e8 4c f7 ff ff       	call   80103a26 <myproc>
801042da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042e1:	75 0d                	jne    801042f0 <sleep+0x21>
    panic("sleep");
801042e3:	83 ec 0c             	sub    $0xc,%esp
801042e6:	68 ef a5 10 80       	push   $0x8010a5ef
801042eb:	e8 b9 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042f4:	75 0d                	jne    80104303 <sleep+0x34>
    panic("sleep without lk");
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	68 f5 a5 10 80       	push   $0x8010a5f5
801042fe:	e8 a6 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104303:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010430a:	74 1e                	je     8010432a <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010430c:	83 ec 0c             	sub    $0xc,%esp
8010430f:	68 00 42 19 80       	push   $0x80194200
80104314:	e8 2a 05 00 00       	call   80104843 <acquire>
80104319:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010431c:	83 ec 0c             	sub    $0xc,%esp
8010431f:	ff 75 0c             	push   0xc(%ebp)
80104322:	e8 8a 05 00 00       	call   801048b1 <release>
80104327:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010432a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432d:	8b 55 08             	mov    0x8(%ebp),%edx
80104330:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104336:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010433d:	e8 54 fe ff ff       	call   80104196 <sched>

  // Tidy up.
  p->chan = 0;
80104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104345:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010434c:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104353:	74 1e                	je     80104373 <sleep+0xa4>
    release(&ptable.lock);
80104355:	83 ec 0c             	sub    $0xc,%esp
80104358:	68 00 42 19 80       	push   $0x80194200
8010435d:	e8 4f 05 00 00       	call   801048b1 <release>
80104362:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104365:	83 ec 0c             	sub    $0xc,%esp
80104368:	ff 75 0c             	push   0xc(%ebp)
8010436b:	e8 d3 04 00 00       	call   80104843 <acquire>
80104370:	83 c4 10             	add    $0x10,%esp
  }
}
80104373:	90                   	nop
80104374:	c9                   	leave  
80104375:	c3                   	ret    

80104376 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104376:	55                   	push   %ebp
80104377:	89 e5                	mov    %esp,%ebp
80104379:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010437c:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104383:	eb 24                	jmp    801043a9 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104385:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104388:	8b 40 0c             	mov    0xc(%eax),%eax
8010438b:	83 f8 02             	cmp    $0x2,%eax
8010438e:	75 15                	jne    801043a5 <wakeup1+0x2f>
80104390:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104393:	8b 40 20             	mov    0x20(%eax),%eax
80104396:	39 45 08             	cmp    %eax,0x8(%ebp)
80104399:	75 0a                	jne    801043a5 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010439b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a5:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043a9:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043b0:	72 d3                	jb     80104385 <wakeup1+0xf>
}
801043b2:	90                   	nop
801043b3:	90                   	nop
801043b4:	c9                   	leave  
801043b5:	c3                   	ret    

801043b6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043b6:	55                   	push   %ebp
801043b7:	89 e5                	mov    %esp,%ebp
801043b9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043bc:	83 ec 0c             	sub    $0xc,%esp
801043bf:	68 00 42 19 80       	push   $0x80194200
801043c4:	e8 7a 04 00 00       	call   80104843 <acquire>
801043c9:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043cc:	83 ec 0c             	sub    $0xc,%esp
801043cf:	ff 75 08             	push   0x8(%ebp)
801043d2:	e8 9f ff ff ff       	call   80104376 <wakeup1>
801043d7:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	68 00 42 19 80       	push   $0x80194200
801043e2:	e8 ca 04 00 00       	call   801048b1 <release>
801043e7:	83 c4 10             	add    $0x10,%esp
}
801043ea:	90                   	nop
801043eb:	c9                   	leave  
801043ec:	c3                   	ret    

801043ed <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043ed:	55                   	push   %ebp
801043ee:	89 e5                	mov    %esp,%ebp
801043f0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	68 00 42 19 80       	push   $0x80194200
801043fb:	e8 43 04 00 00       	call   80104843 <acquire>
80104400:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104403:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010440a:	eb 45                	jmp    80104451 <kill+0x64>
    if(p->pid == pid){
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	8b 40 10             	mov    0x10(%eax),%eax
80104412:	39 45 08             	cmp    %eax,0x8(%ebp)
80104415:	75 36                	jne    8010444d <kill+0x60>
      p->killed = 1;
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	8b 40 0c             	mov    0xc(%eax),%eax
80104427:	83 f8 02             	cmp    $0x2,%eax
8010442a:	75 0a                	jne    80104436 <kill+0x49>
        p->state = RUNNABLE;
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104436:	83 ec 0c             	sub    $0xc,%esp
80104439:	68 00 42 19 80       	push   $0x80194200
8010443e:	e8 6e 04 00 00       	call   801048b1 <release>
80104443:	83 c4 10             	add    $0x10,%esp
      return 0;
80104446:	b8 00 00 00 00       	mov    $0x0,%eax
8010444b:	eb 22                	jmp    8010446f <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010444d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104451:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104458:	72 b2                	jb     8010440c <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010445a:	83 ec 0c             	sub    $0xc,%esp
8010445d:	68 00 42 19 80       	push   $0x80194200
80104462:	e8 4a 04 00 00       	call   801048b1 <release>
80104467:	83 c4 10             	add    $0x10,%esp
  return -1;
8010446a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010446f:	c9                   	leave  
80104470:	c3                   	ret    

80104471 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104471:	55                   	push   %ebp
80104472:	89 e5                	mov    %esp,%ebp
80104474:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104477:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010447e:	e9 d7 00 00 00       	jmp    8010455a <procdump+0xe9>
    if(p->state == UNUSED)
80104483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104486:	8b 40 0c             	mov    0xc(%eax),%eax
80104489:	85 c0                	test   %eax,%eax
8010448b:	0f 84 c4 00 00 00    	je     80104555 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104494:	8b 40 0c             	mov    0xc(%eax),%eax
80104497:	83 f8 05             	cmp    $0x5,%eax
8010449a:	77 23                	ja     801044bf <procdump+0x4e>
8010449c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449f:	8b 40 0c             	mov    0xc(%eax),%eax
801044a2:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044a9:	85 c0                	test   %eax,%eax
801044ab:	74 12                	je     801044bf <procdump+0x4e>
      state = states[p->state];
801044ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b0:	8b 40 0c             	mov    0xc(%eax),%eax
801044b3:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044bd:	eb 07                	jmp    801044c6 <procdump+0x55>
    else
      state = "???";
801044bf:	c7 45 ec 06 a6 10 80 	movl   $0x8010a606,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c9:	8d 50 6c             	lea    0x6c(%eax),%edx
801044cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cf:	8b 40 10             	mov    0x10(%eax),%eax
801044d2:	52                   	push   %edx
801044d3:	ff 75 ec             	push   -0x14(%ebp)
801044d6:	50                   	push   %eax
801044d7:	68 0a a6 10 80       	push   $0x8010a60a
801044dc:	e8 13 bf ff ff       	call   801003f4 <cprintf>
801044e1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e7:	8b 40 0c             	mov    0xc(%eax),%eax
801044ea:	83 f8 02             	cmp    $0x2,%eax
801044ed:	75 54                	jne    80104543 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f5:	8b 40 0c             	mov    0xc(%eax),%eax
801044f8:	83 c0 08             	add    $0x8,%eax
801044fb:	89 c2                	mov    %eax,%edx
801044fd:	83 ec 08             	sub    $0x8,%esp
80104500:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104503:	50                   	push   %eax
80104504:	52                   	push   %edx
80104505:	e8 f9 03 00 00       	call   80104903 <getcallerpcs>
8010450a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010450d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104514:	eb 1c                	jmp    80104532 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104519:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010451d:	83 ec 08             	sub    $0x8,%esp
80104520:	50                   	push   %eax
80104521:	68 13 a6 10 80       	push   $0x8010a613
80104526:	e8 c9 be ff ff       	call   801003f4 <cprintf>
8010452b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010452e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104532:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104536:	7f 0b                	jg     80104543 <procdump+0xd2>
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010453f:	85 c0                	test   %eax,%eax
80104541:	75 d3                	jne    80104516 <procdump+0xa5>
    }
    cprintf("\n");
80104543:	83 ec 0c             	sub    $0xc,%esp
80104546:	68 17 a6 10 80       	push   $0x8010a617
8010454b:	e8 a4 be ff ff       	call   801003f4 <cprintf>
80104550:	83 c4 10             	add    $0x10,%esp
80104553:	eb 01                	jmp    80104556 <procdump+0xe5>
      continue;
80104555:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104556:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010455a:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
80104561:	0f 82 1c ff ff ff    	jb     80104483 <procdump+0x12>
  }
}
80104567:	90                   	nop
80104568:	90                   	nop
80104569:	c9                   	leave  
8010456a:	c3                   	ret    

8010456b <printpt>:

int
printpt(int pid)
{
8010456b:	55                   	push   %ebp
8010456c:	89 e5                	mov    %esp,%ebp
8010456e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = 0;
80104571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t *pte;
  pde_t *pgdir;
  uint addr;

  acquire(&ptable.lock);
80104578:	83 ec 0c             	sub    $0xc,%esp
8010457b:	68 00 42 19 80       	push   $0x80194200
80104580:	e8 be 02 00 00       	call   80104843 <acquire>
80104585:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104588:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010458f:	eb 0f                	jmp    801045a0 <printpt+0x35>
    if (p->pid == pid)
80104591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104594:	8b 40 10             	mov    0x10(%eax),%eax
80104597:	39 45 08             	cmp    %eax,0x8(%ebp)
8010459a:	74 0f                	je     801045ab <printpt+0x40>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010459c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801045a0:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045a7:	72 e8                	jb     80104591 <printpt+0x26>
801045a9:	eb 01                	jmp    801045ac <printpt+0x41>
      break;
801045ab:	90                   	nop
  }
  if (p == &ptable.proc[NPROC] || p->state == UNUSED) {
801045ac:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045b3:	74 0a                	je     801045bf <printpt+0x54>
801045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b8:	8b 40 0c             	mov    0xc(%eax),%eax
801045bb:	85 c0                	test   %eax,%eax
801045bd:	75 1a                	jne    801045d9 <printpt+0x6e>
    release(&ptable.lock);
801045bf:	83 ec 0c             	sub    $0xc,%esp
801045c2:	68 00 42 19 80       	push   $0x80194200
801045c7:	e8 e5 02 00 00       	call   801048b1 <release>
801045cc:	83 c4 10             	add    $0x10,%esp
    return -1;
801045cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d4:	e9 e9 00 00 00       	jmp    801046c2 <printpt+0x157>
  }

  pgdir = p->pgdir;
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	8b 40 04             	mov    0x4(%eax),%eax
801045df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  release(&ptable.lock);
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	68 00 42 19 80       	push   $0x80194200
801045ea:	e8 c2 02 00 00       	call   801048b1 <release>
801045ef:	83 c4 10             	add    $0x10,%esp

  cprintf("START PAGE TABLE (pid %d)\n", pid);
801045f2:	83 ec 08             	sub    $0x8,%esp
801045f5:	ff 75 08             	push   0x8(%ebp)
801045f8:	68 19 a6 10 80       	push   $0x8010a619
801045fd:	e8 f2 bd ff ff       	call   801003f4 <cprintf>
80104602:	83 c4 10             	add    $0x10,%esp

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104605:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010460c:	e9 91 00 00 00       	jmp    801046a2 <printpt+0x137>
    pte = walkpgdir(pgdir, (void*)addr, 0);
80104611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104614:	83 ec 04             	sub    $0x4,%esp
80104617:	6a 00                	push   $0x0
80104619:	50                   	push   %eax
8010461a:	ff 75 ec             	push   -0x14(%ebp)
8010461d:	e8 04 2e 00 00       	call   80107426 <walkpgdir>
80104622:	83 c4 10             	add    $0x10,%esp
80104625:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (!pte || !(*pte & PTE_P)) continue;
80104628:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010462c:	74 6c                	je     8010469a <printpt+0x12f>
8010462e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104631:	8b 00                	mov    (%eax),%eax
80104633:	83 e0 01             	and    $0x1,%eax
80104636:	85 c0                	test   %eax,%eax
80104638:	74 60                	je     8010469a <printpt+0x12f>

    // 플래그 문자열 생성
    const char *access = (*pte & PTE_U) ? "U" : "K";
8010463a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010463d:	8b 00                	mov    (%eax),%eax
8010463f:	83 e0 04             	and    $0x4,%eax
80104642:	85 c0                	test   %eax,%eax
80104644:	74 07                	je     8010464d <printpt+0xe2>
80104646:	b8 34 a6 10 80       	mov    $0x8010a634,%eax
8010464b:	eb 05                	jmp    80104652 <printpt+0xe7>
8010464d:	b8 36 a6 10 80       	mov    $0x8010a636,%eax
80104652:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    const char *write = (*pte & PTE_W) ? "W" : "-";
80104655:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104658:	8b 00                	mov    (%eax),%eax
8010465a:	83 e0 02             	and    $0x2,%eax
8010465d:	85 c0                	test   %eax,%eax
8010465f:	74 07                	je     80104668 <printpt+0xfd>
80104661:	b8 38 a6 10 80       	mov    $0x8010a638,%eax
80104666:	eb 05                	jmp    8010466d <printpt+0x102>
80104668:	b8 3a a6 10 80       	mov    $0x8010a63a,%eax
8010466d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // 전체 문자열 조합 
    cprintf("%x P %s %s %x\n",
      addr >> 12,               // 가상 페이지 번호 (VA >> 12)
      access,                   // U or K
      write,                    // W or -
      PTE_ADDR(*pte) >> 12      // 물리 페이지 번호 (PA >> 12)
80104670:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104673:	8b 00                	mov    (%eax),%eax
    cprintf("%x P %s %s %x\n",
80104675:	c1 e8 0c             	shr    $0xc,%eax
80104678:	89 c2                	mov    %eax,%edx
8010467a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467d:	c1 e8 0c             	shr    $0xc,%eax
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	52                   	push   %edx
80104684:	ff 75 e0             	push   -0x20(%ebp)
80104687:	ff 75 e4             	push   -0x1c(%ebp)
8010468a:	50                   	push   %eax
8010468b:	68 3c a6 10 80       	push   $0x8010a63c
80104690:	e8 5f bd ff ff       	call   801003f4 <cprintf>
80104695:	83 c4 20             	add    $0x20,%esp
80104698:	eb 01                	jmp    8010469b <printpt+0x130>
    if (!pte || !(*pte & PTE_P)) continue;
8010469a:	90                   	nop
  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
8010469b:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801046a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a5:	85 c0                	test   %eax,%eax
801046a7:	0f 89 64 ff ff ff    	jns    80104611 <printpt+0xa6>
    );
  }

  cprintf("END PAGE TABLE\n");
801046ad:	83 ec 0c             	sub    $0xc,%esp
801046b0:	68 4b a6 10 80       	push   $0x8010a64b
801046b5:	e8 3a bd ff ff       	call   801003f4 <cprintf>
801046ba:	83 c4 10             	add    $0x10,%esp
  return 0;
801046bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046c2:	c9                   	leave  
801046c3:	c3                   	ret    

801046c4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046c4:	55                   	push   %ebp
801046c5:	89 e5                	mov    %esp,%ebp
801046c7:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046ca:	8b 45 08             	mov    0x8(%ebp),%eax
801046cd:	83 c0 04             	add    $0x4,%eax
801046d0:	83 ec 08             	sub    $0x8,%esp
801046d3:	68 85 a6 10 80       	push   $0x8010a685
801046d8:	50                   	push   %eax
801046d9:	e8 43 01 00 00       	call   80104821 <initlock>
801046de:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046e1:	8b 45 08             	mov    0x8(%ebp),%eax
801046e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801046e7:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046ea:	8b 45 08             	mov    0x8(%ebp),%eax
801046ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801046fd:	90                   	nop
801046fe:	c9                   	leave  
801046ff:	c3                   	ret    

80104700 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104706:	8b 45 08             	mov    0x8(%ebp),%eax
80104709:	83 c0 04             	add    $0x4,%eax
8010470c:	83 ec 0c             	sub    $0xc,%esp
8010470f:	50                   	push   %eax
80104710:	e8 2e 01 00 00       	call   80104843 <acquire>
80104715:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104718:	eb 15                	jmp    8010472f <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
8010471a:	8b 45 08             	mov    0x8(%ebp),%eax
8010471d:	83 c0 04             	add    $0x4,%eax
80104720:	83 ec 08             	sub    $0x8,%esp
80104723:	50                   	push   %eax
80104724:	ff 75 08             	push   0x8(%ebp)
80104727:	e8 a3 fb ff ff       	call   801042cf <sleep>
8010472c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010472f:	8b 45 08             	mov    0x8(%ebp),%eax
80104732:	8b 00                	mov    (%eax),%eax
80104734:	85 c0                	test   %eax,%eax
80104736:	75 e2                	jne    8010471a <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104738:	8b 45 08             	mov    0x8(%ebp),%eax
8010473b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104741:	e8 e0 f2 ff ff       	call   80103a26 <myproc>
80104746:	8b 50 10             	mov    0x10(%eax),%edx
80104749:	8b 45 08             	mov    0x8(%ebp),%eax
8010474c:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010474f:	8b 45 08             	mov    0x8(%ebp),%eax
80104752:	83 c0 04             	add    $0x4,%eax
80104755:	83 ec 0c             	sub    $0xc,%esp
80104758:	50                   	push   %eax
80104759:	e8 53 01 00 00       	call   801048b1 <release>
8010475e:	83 c4 10             	add    $0x10,%esp
}
80104761:	90                   	nop
80104762:	c9                   	leave  
80104763:	c3                   	ret    

80104764 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104764:	55                   	push   %ebp
80104765:	89 e5                	mov    %esp,%ebp
80104767:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010476a:	8b 45 08             	mov    0x8(%ebp),%eax
8010476d:	83 c0 04             	add    $0x4,%eax
80104770:	83 ec 0c             	sub    $0xc,%esp
80104773:	50                   	push   %eax
80104774:	e8 ca 00 00 00       	call   80104843 <acquire>
80104779:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010477c:	8b 45 08             	mov    0x8(%ebp),%eax
8010477f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104785:	8b 45 08             	mov    0x8(%ebp),%eax
80104788:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010478f:	83 ec 0c             	sub    $0xc,%esp
80104792:	ff 75 08             	push   0x8(%ebp)
80104795:	e8 1c fc ff ff       	call   801043b6 <wakeup>
8010479a:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010479d:	8b 45 08             	mov    0x8(%ebp),%eax
801047a0:	83 c0 04             	add    $0x4,%eax
801047a3:	83 ec 0c             	sub    $0xc,%esp
801047a6:	50                   	push   %eax
801047a7:	e8 05 01 00 00       	call   801048b1 <release>
801047ac:	83 c4 10             	add    $0x10,%esp
}
801047af:	90                   	nop
801047b0:	c9                   	leave  
801047b1:	c3                   	ret    

801047b2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047b2:	55                   	push   %ebp
801047b3:	89 e5                	mov    %esp,%ebp
801047b5:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	83 c0 04             	add    $0x4,%eax
801047be:	83 ec 0c             	sub    $0xc,%esp
801047c1:	50                   	push   %eax
801047c2:	e8 7c 00 00 00       	call   80104843 <acquire>
801047c7:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047ca:	8b 45 08             	mov    0x8(%ebp),%eax
801047cd:	8b 00                	mov    (%eax),%eax
801047cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047d2:	8b 45 08             	mov    0x8(%ebp),%eax
801047d5:	83 c0 04             	add    $0x4,%eax
801047d8:	83 ec 0c             	sub    $0xc,%esp
801047db:	50                   	push   %eax
801047dc:	e8 d0 00 00 00       	call   801048b1 <release>
801047e1:	83 c4 10             	add    $0x10,%esp
  return r;
801047e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047e7:	c9                   	leave  
801047e8:	c3                   	ret    

801047e9 <readeflags>:
{
801047e9:	55                   	push   %ebp
801047ea:	89 e5                	mov    %esp,%ebp
801047ec:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047ef:	9c                   	pushf  
801047f0:	58                   	pop    %eax
801047f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047f7:	c9                   	leave  
801047f8:	c3                   	ret    

801047f9 <cli>:
{
801047f9:	55                   	push   %ebp
801047fa:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801047fc:	fa                   	cli    
}
801047fd:	90                   	nop
801047fe:	5d                   	pop    %ebp
801047ff:	c3                   	ret    

80104800 <sti>:
{
80104800:	55                   	push   %ebp
80104801:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104803:	fb                   	sti    
}
80104804:	90                   	nop
80104805:	5d                   	pop    %ebp
80104806:	c3                   	ret    

80104807 <xchg>:
{
80104807:	55                   	push   %ebp
80104808:	89 e5                	mov    %esp,%ebp
8010480a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010480d:	8b 55 08             	mov    0x8(%ebp),%edx
80104810:	8b 45 0c             	mov    0xc(%ebp),%eax
80104813:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104816:	f0 87 02             	lock xchg %eax,(%edx)
80104819:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010481c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010481f:	c9                   	leave  
80104820:	c3                   	ret    

80104821 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104821:	55                   	push   %ebp
80104822:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104824:	8b 45 08             	mov    0x8(%ebp),%eax
80104827:	8b 55 0c             	mov    0xc(%ebp),%edx
8010482a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010482d:	8b 45 08             	mov    0x8(%ebp),%eax
80104830:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104836:	8b 45 08             	mov    0x8(%ebp),%eax
80104839:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104840:	90                   	nop
80104841:	5d                   	pop    %ebp
80104842:	c3                   	ret    

80104843 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104843:	55                   	push   %ebp
80104844:	89 e5                	mov    %esp,%ebp
80104846:	53                   	push   %ebx
80104847:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010484a:	e8 5f 01 00 00       	call   801049ae <pushcli>
  if(holding(lk)){
8010484f:	8b 45 08             	mov    0x8(%ebp),%eax
80104852:	83 ec 0c             	sub    $0xc,%esp
80104855:	50                   	push   %eax
80104856:	e8 23 01 00 00       	call   8010497e <holding>
8010485b:	83 c4 10             	add    $0x10,%esp
8010485e:	85 c0                	test   %eax,%eax
80104860:	74 0d                	je     8010486f <acquire+0x2c>
    panic("acquire");
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	68 90 a6 10 80       	push   $0x8010a690
8010486a:	e8 3a bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010486f:	90                   	nop
80104870:	8b 45 08             	mov    0x8(%ebp),%eax
80104873:	83 ec 08             	sub    $0x8,%esp
80104876:	6a 01                	push   $0x1
80104878:	50                   	push   %eax
80104879:	e8 89 ff ff ff       	call   80104807 <xchg>
8010487e:	83 c4 10             	add    $0x10,%esp
80104881:	85 c0                	test   %eax,%eax
80104883:	75 eb                	jne    80104870 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104885:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010488a:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010488d:	e8 1c f1 ff ff       	call   801039ae <mycpu>
80104892:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104895:	8b 45 08             	mov    0x8(%ebp),%eax
80104898:	83 c0 0c             	add    $0xc,%eax
8010489b:	83 ec 08             	sub    $0x8,%esp
8010489e:	50                   	push   %eax
8010489f:	8d 45 08             	lea    0x8(%ebp),%eax
801048a2:	50                   	push   %eax
801048a3:	e8 5b 00 00 00       	call   80104903 <getcallerpcs>
801048a8:	83 c4 10             	add    $0x10,%esp
}
801048ab:	90                   	nop
801048ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048af:	c9                   	leave  
801048b0:	c3                   	ret    

801048b1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048b1:	55                   	push   %ebp
801048b2:	89 e5                	mov    %esp,%ebp
801048b4:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048b7:	83 ec 0c             	sub    $0xc,%esp
801048ba:	ff 75 08             	push   0x8(%ebp)
801048bd:	e8 bc 00 00 00       	call   8010497e <holding>
801048c2:	83 c4 10             	add    $0x10,%esp
801048c5:	85 c0                	test   %eax,%eax
801048c7:	75 0d                	jne    801048d6 <release+0x25>
    panic("release");
801048c9:	83 ec 0c             	sub    $0xc,%esp
801048cc:	68 98 a6 10 80       	push   $0x8010a698
801048d1:	e8 d3 bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048d6:	8b 45 08             	mov    0x8(%ebp),%eax
801048d9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048e0:	8b 45 08             	mov    0x8(%ebp),%eax
801048e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048ea:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048ef:	8b 45 08             	mov    0x8(%ebp),%eax
801048f2:	8b 55 08             	mov    0x8(%ebp),%edx
801048f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801048fb:	e8 fb 00 00 00       	call   801049fb <popcli>
}
80104900:	90                   	nop
80104901:	c9                   	leave  
80104902:	c3                   	ret    

80104903 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104903:	55                   	push   %ebp
80104904:	89 e5                	mov    %esp,%ebp
80104906:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104909:	8b 45 08             	mov    0x8(%ebp),%eax
8010490c:	83 e8 08             	sub    $0x8,%eax
8010490f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104912:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104919:	eb 38                	jmp    80104953 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010491b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010491f:	74 53                	je     80104974 <getcallerpcs+0x71>
80104921:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104928:	76 4a                	jbe    80104974 <getcallerpcs+0x71>
8010492a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010492e:	74 44                	je     80104974 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104930:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104933:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010493a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010493d:	01 c2                	add    %eax,%edx
8010493f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104942:	8b 40 04             	mov    0x4(%eax),%eax
80104945:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104947:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010494a:	8b 00                	mov    (%eax),%eax
8010494c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010494f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104953:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104957:	7e c2                	jle    8010491b <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104959:	eb 19                	jmp    80104974 <getcallerpcs+0x71>
    pcs[i] = 0;
8010495b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010495e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104965:	8b 45 0c             	mov    0xc(%ebp),%eax
80104968:	01 d0                	add    %edx,%eax
8010496a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104970:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104974:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104978:	7e e1                	jle    8010495b <getcallerpcs+0x58>
}
8010497a:	90                   	nop
8010497b:	90                   	nop
8010497c:	c9                   	leave  
8010497d:	c3                   	ret    

8010497e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010497e:	55                   	push   %ebp
8010497f:	89 e5                	mov    %esp,%ebp
80104981:	53                   	push   %ebx
80104982:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104985:	8b 45 08             	mov    0x8(%ebp),%eax
80104988:	8b 00                	mov    (%eax),%eax
8010498a:	85 c0                	test   %eax,%eax
8010498c:	74 16                	je     801049a4 <holding+0x26>
8010498e:	8b 45 08             	mov    0x8(%ebp),%eax
80104991:	8b 58 08             	mov    0x8(%eax),%ebx
80104994:	e8 15 f0 ff ff       	call   801039ae <mycpu>
80104999:	39 c3                	cmp    %eax,%ebx
8010499b:	75 07                	jne    801049a4 <holding+0x26>
8010499d:	b8 01 00 00 00       	mov    $0x1,%eax
801049a2:	eb 05                	jmp    801049a9 <holding+0x2b>
801049a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049ac:	c9                   	leave  
801049ad:	c3                   	ret    

801049ae <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049ae:	55                   	push   %ebp
801049af:	89 e5                	mov    %esp,%ebp
801049b1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049b4:	e8 30 fe ff ff       	call   801047e9 <readeflags>
801049b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049bc:	e8 38 fe ff ff       	call   801047f9 <cli>
  if(mycpu()->ncli == 0)
801049c1:	e8 e8 ef ff ff       	call   801039ae <mycpu>
801049c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049cc:	85 c0                	test   %eax,%eax
801049ce:	75 14                	jne    801049e4 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049d0:	e8 d9 ef ff ff       	call   801039ae <mycpu>
801049d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d8:	81 e2 00 02 00 00    	and    $0x200,%edx
801049de:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049e4:	e8 c5 ef ff ff       	call   801039ae <mycpu>
801049e9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049ef:	83 c2 01             	add    $0x1,%edx
801049f2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801049f8:	90                   	nop
801049f9:	c9                   	leave  
801049fa:	c3                   	ret    

801049fb <popcli>:

void
popcli(void)
{
801049fb:	55                   	push   %ebp
801049fc:	89 e5                	mov    %esp,%ebp
801049fe:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a01:	e8 e3 fd ff ff       	call   801047e9 <readeflags>
80104a06:	25 00 02 00 00       	and    $0x200,%eax
80104a0b:	85 c0                	test   %eax,%eax
80104a0d:	74 0d                	je     80104a1c <popcli+0x21>
    panic("popcli - interruptible");
80104a0f:	83 ec 0c             	sub    $0xc,%esp
80104a12:	68 a0 a6 10 80       	push   $0x8010a6a0
80104a17:	e8 8d bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a1c:	e8 8d ef ff ff       	call   801039ae <mycpu>
80104a21:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a27:	83 ea 01             	sub    $0x1,%edx
80104a2a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a30:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a36:	85 c0                	test   %eax,%eax
80104a38:	79 0d                	jns    80104a47 <popcli+0x4c>
    panic("popcli");
80104a3a:	83 ec 0c             	sub    $0xc,%esp
80104a3d:	68 b7 a6 10 80       	push   $0x8010a6b7
80104a42:	e8 62 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a47:	e8 62 ef ff ff       	call   801039ae <mycpu>
80104a4c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a52:	85 c0                	test   %eax,%eax
80104a54:	75 14                	jne    80104a6a <popcli+0x6f>
80104a56:	e8 53 ef ff ff       	call   801039ae <mycpu>
80104a5b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a61:	85 c0                	test   %eax,%eax
80104a63:	74 05                	je     80104a6a <popcli+0x6f>
    sti();
80104a65:	e8 96 fd ff ff       	call   80104800 <sti>
}
80104a6a:	90                   	nop
80104a6b:	c9                   	leave  
80104a6c:	c3                   	ret    

80104a6d <stosb>:
{
80104a6d:	55                   	push   %ebp
80104a6e:	89 e5                	mov    %esp,%ebp
80104a70:	57                   	push   %edi
80104a71:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a72:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a75:	8b 55 10             	mov    0x10(%ebp),%edx
80104a78:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a7b:	89 cb                	mov    %ecx,%ebx
80104a7d:	89 df                	mov    %ebx,%edi
80104a7f:	89 d1                	mov    %edx,%ecx
80104a81:	fc                   	cld    
80104a82:	f3 aa                	rep stos %al,%es:(%edi)
80104a84:	89 ca                	mov    %ecx,%edx
80104a86:	89 fb                	mov    %edi,%ebx
80104a88:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a8b:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a8e:	90                   	nop
80104a8f:	5b                   	pop    %ebx
80104a90:	5f                   	pop    %edi
80104a91:	5d                   	pop    %ebp
80104a92:	c3                   	ret    

80104a93 <stosl>:
{
80104a93:	55                   	push   %ebp
80104a94:	89 e5                	mov    %esp,%ebp
80104a96:	57                   	push   %edi
80104a97:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104a98:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a9b:	8b 55 10             	mov    0x10(%ebp),%edx
80104a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa1:	89 cb                	mov    %ecx,%ebx
80104aa3:	89 df                	mov    %ebx,%edi
80104aa5:	89 d1                	mov    %edx,%ecx
80104aa7:	fc                   	cld    
80104aa8:	f3 ab                	rep stos %eax,%es:(%edi)
80104aaa:	89 ca                	mov    %ecx,%edx
80104aac:	89 fb                	mov    %edi,%ebx
80104aae:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ab1:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104ab4:	90                   	nop
80104ab5:	5b                   	pop    %ebx
80104ab6:	5f                   	pop    %edi
80104ab7:	5d                   	pop    %ebp
80104ab8:	c3                   	ret    

80104ab9 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ab9:	55                   	push   %ebp
80104aba:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104abc:	8b 45 08             	mov    0x8(%ebp),%eax
80104abf:	83 e0 03             	and    $0x3,%eax
80104ac2:	85 c0                	test   %eax,%eax
80104ac4:	75 43                	jne    80104b09 <memset+0x50>
80104ac6:	8b 45 10             	mov    0x10(%ebp),%eax
80104ac9:	83 e0 03             	and    $0x3,%eax
80104acc:	85 c0                	test   %eax,%eax
80104ace:	75 39                	jne    80104b09 <memset+0x50>
    c &= 0xFF;
80104ad0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ad7:	8b 45 10             	mov    0x10(%ebp),%eax
80104ada:	c1 e8 02             	shr    $0x2,%eax
80104add:	89 c2                	mov    %eax,%edx
80104adf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae2:	c1 e0 18             	shl    $0x18,%eax
80104ae5:	89 c1                	mov    %eax,%ecx
80104ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aea:	c1 e0 10             	shl    $0x10,%eax
80104aed:	09 c1                	or     %eax,%ecx
80104aef:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af2:	c1 e0 08             	shl    $0x8,%eax
80104af5:	09 c8                	or     %ecx,%eax
80104af7:	0b 45 0c             	or     0xc(%ebp),%eax
80104afa:	52                   	push   %edx
80104afb:	50                   	push   %eax
80104afc:	ff 75 08             	push   0x8(%ebp)
80104aff:	e8 8f ff ff ff       	call   80104a93 <stosl>
80104b04:	83 c4 0c             	add    $0xc,%esp
80104b07:	eb 12                	jmp    80104b1b <memset+0x62>
  } else
    stosb(dst, c, n);
80104b09:	8b 45 10             	mov    0x10(%ebp),%eax
80104b0c:	50                   	push   %eax
80104b0d:	ff 75 0c             	push   0xc(%ebp)
80104b10:	ff 75 08             	push   0x8(%ebp)
80104b13:	e8 55 ff ff ff       	call   80104a6d <stosb>
80104b18:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b1b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b1e:	c9                   	leave  
80104b1f:	c3                   	ret    

80104b20 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b20:	55                   	push   %ebp
80104b21:	89 e5                	mov    %esp,%ebp
80104b23:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b26:	8b 45 08             	mov    0x8(%ebp),%eax
80104b29:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b32:	eb 30                	jmp    80104b64 <memcmp+0x44>
    if(*s1 != *s2)
80104b34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b37:	0f b6 10             	movzbl (%eax),%edx
80104b3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b3d:	0f b6 00             	movzbl (%eax),%eax
80104b40:	38 c2                	cmp    %al,%dl
80104b42:	74 18                	je     80104b5c <memcmp+0x3c>
      return *s1 - *s2;
80104b44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b47:	0f b6 00             	movzbl (%eax),%eax
80104b4a:	0f b6 d0             	movzbl %al,%edx
80104b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b50:	0f b6 00             	movzbl (%eax),%eax
80104b53:	0f b6 c8             	movzbl %al,%ecx
80104b56:	89 d0                	mov    %edx,%eax
80104b58:	29 c8                	sub    %ecx,%eax
80104b5a:	eb 1a                	jmp    80104b76 <memcmp+0x56>
    s1++, s2++;
80104b5c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b60:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b64:	8b 45 10             	mov    0x10(%ebp),%eax
80104b67:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b6a:	89 55 10             	mov    %edx,0x10(%ebp)
80104b6d:	85 c0                	test   %eax,%eax
80104b6f:	75 c3                	jne    80104b34 <memcmp+0x14>
  }

  return 0;
80104b71:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b76:	c9                   	leave  
80104b77:	c3                   	ret    

80104b78 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
80104b7b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b81:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b84:	8b 45 08             	mov    0x8(%ebp),%eax
80104b87:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b8d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b90:	73 54                	jae    80104be6 <memmove+0x6e>
80104b92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b95:	8b 45 10             	mov    0x10(%ebp),%eax
80104b98:	01 d0                	add    %edx,%eax
80104b9a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104b9d:	73 47                	jae    80104be6 <memmove+0x6e>
    s += n;
80104b9f:	8b 45 10             	mov    0x10(%ebp),%eax
80104ba2:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104ba5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ba8:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104bab:	eb 13                	jmp    80104bc0 <memmove+0x48>
      *--d = *--s;
80104bad:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104bb1:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb8:	0f b6 10             	movzbl (%eax),%edx
80104bbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bbe:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bc0:	8b 45 10             	mov    0x10(%ebp),%eax
80104bc3:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bc6:	89 55 10             	mov    %edx,0x10(%ebp)
80104bc9:	85 c0                	test   %eax,%eax
80104bcb:	75 e0                	jne    80104bad <memmove+0x35>
  if(s < d && s + n > d){
80104bcd:	eb 24                	jmp    80104bf3 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104bcf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bd2:	8d 42 01             	lea    0x1(%edx),%eax
80104bd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bdb:	8d 48 01             	lea    0x1(%eax),%ecx
80104bde:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104be1:	0f b6 12             	movzbl (%edx),%edx
80104be4:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104be6:	8b 45 10             	mov    0x10(%ebp),%eax
80104be9:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bec:	89 55 10             	mov    %edx,0x10(%ebp)
80104bef:	85 c0                	test   %eax,%eax
80104bf1:	75 dc                	jne    80104bcf <memmove+0x57>

  return dst;
80104bf3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bf6:	c9                   	leave  
80104bf7:	c3                   	ret    

80104bf8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104bf8:	55                   	push   %ebp
80104bf9:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104bfb:	ff 75 10             	push   0x10(%ebp)
80104bfe:	ff 75 0c             	push   0xc(%ebp)
80104c01:	ff 75 08             	push   0x8(%ebp)
80104c04:	e8 6f ff ff ff       	call   80104b78 <memmove>
80104c09:	83 c4 0c             	add    $0xc,%esp
}
80104c0c:	c9                   	leave  
80104c0d:	c3                   	ret    

80104c0e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c0e:	55                   	push   %ebp
80104c0f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c11:	eb 0c                	jmp    80104c1f <strncmp+0x11>
    n--, p++, q++;
80104c13:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c1b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c23:	74 1a                	je     80104c3f <strncmp+0x31>
80104c25:	8b 45 08             	mov    0x8(%ebp),%eax
80104c28:	0f b6 00             	movzbl (%eax),%eax
80104c2b:	84 c0                	test   %al,%al
80104c2d:	74 10                	je     80104c3f <strncmp+0x31>
80104c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c32:	0f b6 10             	movzbl (%eax),%edx
80104c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c38:	0f b6 00             	movzbl (%eax),%eax
80104c3b:	38 c2                	cmp    %al,%dl
80104c3d:	74 d4                	je     80104c13 <strncmp+0x5>
  if(n == 0)
80104c3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c43:	75 07                	jne    80104c4c <strncmp+0x3e>
    return 0;
80104c45:	b8 00 00 00 00       	mov    $0x0,%eax
80104c4a:	eb 16                	jmp    80104c62 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4f:	0f b6 00             	movzbl (%eax),%eax
80104c52:	0f b6 d0             	movzbl %al,%edx
80104c55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c58:	0f b6 00             	movzbl (%eax),%eax
80104c5b:	0f b6 c8             	movzbl %al,%ecx
80104c5e:	89 d0                	mov    %edx,%eax
80104c60:	29 c8                	sub    %ecx,%eax
}
80104c62:	5d                   	pop    %ebp
80104c63:	c3                   	ret    

80104c64 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c64:	55                   	push   %ebp
80104c65:	89 e5                	mov    %esp,%ebp
80104c67:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c70:	90                   	nop
80104c71:	8b 45 10             	mov    0x10(%ebp),%eax
80104c74:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c77:	89 55 10             	mov    %edx,0x10(%ebp)
80104c7a:	85 c0                	test   %eax,%eax
80104c7c:	7e 2c                	jle    80104caa <strncpy+0x46>
80104c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c81:	8d 42 01             	lea    0x1(%edx),%eax
80104c84:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c87:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8a:	8d 48 01             	lea    0x1(%eax),%ecx
80104c8d:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c90:	0f b6 12             	movzbl (%edx),%edx
80104c93:	88 10                	mov    %dl,(%eax)
80104c95:	0f b6 00             	movzbl (%eax),%eax
80104c98:	84 c0                	test   %al,%al
80104c9a:	75 d5                	jne    80104c71 <strncpy+0xd>
    ;
  while(n-- > 0)
80104c9c:	eb 0c                	jmp    80104caa <strncpy+0x46>
    *s++ = 0;
80104c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca1:	8d 50 01             	lea    0x1(%eax),%edx
80104ca4:	89 55 08             	mov    %edx,0x8(%ebp)
80104ca7:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104caa:	8b 45 10             	mov    0x10(%ebp),%eax
80104cad:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cb0:	89 55 10             	mov    %edx,0x10(%ebp)
80104cb3:	85 c0                	test   %eax,%eax
80104cb5:	7f e7                	jg     80104c9e <strncpy+0x3a>
  return os;
80104cb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cba:	c9                   	leave  
80104cbb:	c3                   	ret    

80104cbc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cbc:	55                   	push   %ebp
80104cbd:	89 e5                	mov    %esp,%ebp
80104cbf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104cc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ccc:	7f 05                	jg     80104cd3 <safestrcpy+0x17>
    return os;
80104cce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd1:	eb 32                	jmp    80104d05 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cd3:	90                   	nop
80104cd4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cdc:	7e 1e                	jle    80104cfc <safestrcpy+0x40>
80104cde:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ce1:	8d 42 01             	lea    0x1(%edx),%eax
80104ce4:	89 45 0c             	mov    %eax,0xc(%ebp)
80104ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cea:	8d 48 01             	lea    0x1(%eax),%ecx
80104ced:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cf0:	0f b6 12             	movzbl (%edx),%edx
80104cf3:	88 10                	mov    %dl,(%eax)
80104cf5:	0f b6 00             	movzbl (%eax),%eax
80104cf8:	84 c0                	test   %al,%al
80104cfa:	75 d8                	jne    80104cd4 <safestrcpy+0x18>
    ;
  *s = 0;
80104cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cff:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d02:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d05:	c9                   	leave  
80104d06:	c3                   	ret    

80104d07 <strlen>:

int
strlen(const char *s)
{
80104d07:	55                   	push   %ebp
80104d08:	89 e5                	mov    %esp,%ebp
80104d0a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d0d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d14:	eb 04                	jmp    80104d1a <strlen+0x13>
80104d16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d1a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d20:	01 d0                	add    %edx,%eax
80104d22:	0f b6 00             	movzbl (%eax),%eax
80104d25:	84 c0                	test   %al,%al
80104d27:	75 ed                	jne    80104d16 <strlen+0xf>
    ;
  return n;
80104d29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d2c:	c9                   	leave  
80104d2d:	c3                   	ret    

80104d2e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d2e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d32:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d36:	55                   	push   %ebp
  pushl %ebx
80104d37:	53                   	push   %ebx
  pushl %esi
80104d38:	56                   	push   %esi
  pushl %edi
80104d39:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d3a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d3c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d3e:	5f                   	pop    %edi
  popl %esi
80104d3f:	5e                   	pop    %esi
  popl %ebx
80104d40:	5b                   	pop    %ebx
  popl %ebp
80104d41:	5d                   	pop    %ebp
  ret
80104d42:	c3                   	ret    

80104d43 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d43:	55                   	push   %ebp
80104d44:	89 e5                	mov    %esp,%ebp
  //커널 영역 침범 방지
  if(addr >=KERNBASE || addr+4 > KERNBASE)
80104d46:	8b 45 08             	mov    0x8(%ebp),%eax
80104d49:	85 c0                	test   %eax,%eax
80104d4b:	78 0d                	js     80104d5a <fetchint+0x17>
80104d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d50:	83 c0 04             	add    $0x4,%eax
80104d53:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104d58:	76 07                	jbe    80104d61 <fetchint+0x1e>
    return -1;
80104d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d5f:	eb 0f                	jmp    80104d70 <fetchint+0x2d>
  
  *ip = *(int*)(addr);
80104d61:	8b 45 08             	mov    0x8(%ebp),%eax
80104d64:	8b 10                	mov    (%eax),%edx
80104d66:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d69:	89 10                	mov    %edx,(%eax)
  return 0;
80104d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d70:	5d                   	pop    %ebp
80104d71:	c3                   	ret    

80104d72 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d72:	55                   	push   %ebp
80104d73:	89 e5                	mov    %esp,%ebp
80104d75:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  // 잘못된 접근 방지
  if(addr >=KERNBASE)
80104d78:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7b:	85 c0                	test   %eax,%eax
80104d7d:	79 07                	jns    80104d86 <fetchstr+0x14>
    return -1;
80104d7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d84:	eb 40                	jmp    80104dc6 <fetchstr+0x54>

  *pp = (char*)addr;
80104d86:	8b 55 08             	mov    0x8(%ebp),%edx
80104d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8c:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE; //상한선은 가상 메모리 한계로 설정
80104d8e:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104d95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d98:	8b 00                	mov    (%eax),%eax
80104d9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104d9d:	eb 1a                	jmp    80104db9 <fetchstr+0x47>
    if(*s == 0)
80104d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104da2:	0f b6 00             	movzbl (%eax),%eax
80104da5:	84 c0                	test   %al,%al
80104da7:	75 0c                	jne    80104db5 <fetchstr+0x43>
      return s - *pp;
80104da9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dac:	8b 10                	mov    (%eax),%edx
80104dae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104db1:	29 d0                	sub    %edx,%eax
80104db3:	eb 11                	jmp    80104dc6 <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104db5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104db9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104dbf:	72 de                	jb     80104d9f <fetchstr+0x2d>
  }
  return -1;
80104dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104dce:	e8 53 ec ff ff       	call   80103a26 <myproc>
80104dd3:	8b 40 18             	mov    0x18(%eax),%eax
80104dd6:	8b 50 44             	mov    0x44(%eax),%edx
80104dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddc:	c1 e0 02             	shl    $0x2,%eax
80104ddf:	01 d0                	add    %edx,%eax
80104de1:	83 c0 04             	add    $0x4,%eax
80104de4:	83 ec 08             	sub    $0x8,%esp
80104de7:	ff 75 0c             	push   0xc(%ebp)
80104dea:	50                   	push   %eax
80104deb:	e8 53 ff ff ff       	call   80104d43 <fetchint>
80104df0:	83 c4 10             	add    $0x10,%esp
}
80104df3:	c9                   	leave  
80104df4:	c3                   	ret    

80104df5 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104df5:	55                   	push   %ebp
80104df6:	89 e5                	mov    %esp,%ebp
80104df8:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104dfb:	83 ec 08             	sub    $0x8,%esp
80104dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e01:	50                   	push   %eax
80104e02:	ff 75 08             	push   0x8(%ebp)
80104e05:	e8 be ff ff ff       	call   80104dc8 <argint>
80104e0a:	83 c4 10             	add    $0x10,%esp
80104e0d:	85 c0                	test   %eax,%eax
80104e0f:	79 07                	jns    80104e18 <argptr+0x23>
    return -1;
80104e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e16:	eb 34                	jmp    80104e4c <argptr+0x57>
    
  //size만큼 공간 확보 + 커널 영역 접근 방지
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104e18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e1c:	78 18                	js     80104e36 <argptr+0x41>
80104e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e21:	85 c0                	test   %eax,%eax
80104e23:	78 11                	js     80104e36 <argptr+0x41>
80104e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e28:	89 c2                	mov    %eax,%edx
80104e2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e2d:	01 d0                	add    %edx,%eax
80104e2f:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104e34:	76 07                	jbe    80104e3d <argptr+0x48>
    return -1;
80104e36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e3b:	eb 0f                	jmp    80104e4c <argptr+0x57>
  *pp = (char*)i;
80104e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e40:	89 c2                	mov    %eax,%edx
80104e42:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e45:	89 10                	mov    %edx,(%eax)
  return 0;
80104e47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e4c:	c9                   	leave  
80104e4d:	c3                   	ret    

80104e4e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e4e:	55                   	push   %ebp
80104e4f:	89 e5                	mov    %esp,%ebp
80104e51:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e54:	83 ec 08             	sub    $0x8,%esp
80104e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e5a:	50                   	push   %eax
80104e5b:	ff 75 08             	push   0x8(%ebp)
80104e5e:	e8 65 ff ff ff       	call   80104dc8 <argint>
80104e63:	83 c4 10             	add    $0x10,%esp
80104e66:	85 c0                	test   %eax,%eax
80104e68:	79 07                	jns    80104e71 <argstr+0x23>
    return -1;
80104e6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e6f:	eb 12                	jmp    80104e83 <argstr+0x35>
  return fetchstr(addr, pp);
80104e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e74:	83 ec 08             	sub    $0x8,%esp
80104e77:	ff 75 0c             	push   0xc(%ebp)
80104e7a:	50                   	push   %eax
80104e7b:	e8 f2 fe ff ff       	call   80104d72 <fetchstr>
80104e80:	83 c4 10             	add    $0x10,%esp
}
80104e83:	c9                   	leave  
80104e84:	c3                   	ret    

80104e85 <syscall>:

};

void
syscall(void)
{
80104e85:	55                   	push   %ebp
80104e86:	89 e5                	mov    %esp,%ebp
80104e88:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e8b:	e8 96 eb ff ff       	call   80103a26 <myproc>
80104e90:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e96:	8b 40 18             	mov    0x18(%eax),%eax
80104e99:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ea3:	7e 2f                	jle    80104ed4 <syscall+0x4f>
80104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea8:	83 f8 16             	cmp    $0x16,%eax
80104eab:	77 27                	ja     80104ed4 <syscall+0x4f>
80104ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb0:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104eb7:	85 c0                	test   %eax,%eax
80104eb9:	74 19                	je     80104ed4 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebe:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ec5:	ff d0                	call   *%eax
80104ec7:	89 c2                	mov    %eax,%edx
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ecc:	8b 40 18             	mov    0x18(%eax),%eax
80104ecf:	89 50 1c             	mov    %edx,0x1c(%eax)
80104ed2:	eb 2c                	jmp    80104f00 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edd:	8b 40 10             	mov    0x10(%eax),%eax
80104ee0:	ff 75 f0             	push   -0x10(%ebp)
80104ee3:	52                   	push   %edx
80104ee4:	50                   	push   %eax
80104ee5:	68 be a6 10 80       	push   $0x8010a6be
80104eea:	e8 05 b5 ff ff       	call   801003f4 <cprintf>
80104eef:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef5:	8b 40 18             	mov    0x18(%eax),%eax
80104ef8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104eff:	90                   	nop
80104f00:	90                   	nop
80104f01:	c9                   	leave  
80104f02:	c3                   	ret    

80104f03 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f03:	55                   	push   %ebp
80104f04:	89 e5                	mov    %esp,%ebp
80104f06:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f09:	83 ec 08             	sub    $0x8,%esp
80104f0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f0f:	50                   	push   %eax
80104f10:	ff 75 08             	push   0x8(%ebp)
80104f13:	e8 b0 fe ff ff       	call   80104dc8 <argint>
80104f18:	83 c4 10             	add    $0x10,%esp
80104f1b:	85 c0                	test   %eax,%eax
80104f1d:	79 07                	jns    80104f26 <argfd+0x23>
    return -1;
80104f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f24:	eb 4f                	jmp    80104f75 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f29:	85 c0                	test   %eax,%eax
80104f2b:	78 20                	js     80104f4d <argfd+0x4a>
80104f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f30:	83 f8 0f             	cmp    $0xf,%eax
80104f33:	7f 18                	jg     80104f4d <argfd+0x4a>
80104f35:	e8 ec ea ff ff       	call   80103a26 <myproc>
80104f3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f3d:	83 c2 08             	add    $0x8,%edx
80104f40:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f4b:	75 07                	jne    80104f54 <argfd+0x51>
    return -1;
80104f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f52:	eb 21                	jmp    80104f75 <argfd+0x72>
  if(pfd)
80104f54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f58:	74 08                	je     80104f62 <argfd+0x5f>
    *pfd = fd;
80104f5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f60:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f66:	74 08                	je     80104f70 <argfd+0x6d>
    *pf = f;
80104f68:	8b 45 10             	mov    0x10(%ebp),%eax
80104f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f6e:	89 10                	mov    %edx,(%eax)
  return 0;
80104f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f75:	c9                   	leave  
80104f76:	c3                   	ret    

80104f77 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f77:	55                   	push   %ebp
80104f78:	89 e5                	mov    %esp,%ebp
80104f7a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f7d:	e8 a4 ea ff ff       	call   80103a26 <myproc>
80104f82:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f8c:	eb 2a                	jmp    80104fb8 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f94:	83 c2 08             	add    $0x8,%edx
80104f97:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f9b:	85 c0                	test   %eax,%eax
80104f9d:	75 15                	jne    80104fb4 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fa5:	8d 4a 08             	lea    0x8(%edx),%ecx
80104fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80104fab:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb2:	eb 0f                	jmp    80104fc3 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104fb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fb8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104fbc:	7e d0                	jle    80104f8e <fdalloc+0x17>
    }
  }
  return -1;
80104fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fc3:	c9                   	leave  
80104fc4:	c3                   	ret    

80104fc5 <sys_dup>:

int
sys_dup(void)
{
80104fc5:	55                   	push   %ebp
80104fc6:	89 e5                	mov    %esp,%ebp
80104fc8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104fcb:	83 ec 04             	sub    $0x4,%esp
80104fce:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fd1:	50                   	push   %eax
80104fd2:	6a 00                	push   $0x0
80104fd4:	6a 00                	push   $0x0
80104fd6:	e8 28 ff ff ff       	call   80104f03 <argfd>
80104fdb:	83 c4 10             	add    $0x10,%esp
80104fde:	85 c0                	test   %eax,%eax
80104fe0:	79 07                	jns    80104fe9 <sys_dup+0x24>
    return -1;
80104fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe7:	eb 31                	jmp    8010501a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fec:	83 ec 0c             	sub    $0xc,%esp
80104fef:	50                   	push   %eax
80104ff0:	e8 82 ff ff ff       	call   80104f77 <fdalloc>
80104ff5:	83 c4 10             	add    $0x10,%esp
80104ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ffb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fff:	79 07                	jns    80105008 <sys_dup+0x43>
    return -1;
80105001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105006:	eb 12                	jmp    8010501a <sys_dup+0x55>
  filedup(f);
80105008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500b:	83 ec 0c             	sub    $0xc,%esp
8010500e:	50                   	push   %eax
8010500f:	e8 2c c0 ff ff       	call   80101040 <filedup>
80105014:	83 c4 10             	add    $0x10,%esp
  return fd;
80105017:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010501a:	c9                   	leave  
8010501b:	c3                   	ret    

8010501c <sys_read>:

int
sys_read(void)
{
8010501c:	55                   	push   %ebp
8010501d:	89 e5                	mov    %esp,%ebp
8010501f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105022:	83 ec 04             	sub    $0x4,%esp
80105025:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105028:	50                   	push   %eax
80105029:	6a 00                	push   $0x0
8010502b:	6a 00                	push   $0x0
8010502d:	e8 d1 fe ff ff       	call   80104f03 <argfd>
80105032:	83 c4 10             	add    $0x10,%esp
80105035:	85 c0                	test   %eax,%eax
80105037:	78 2e                	js     80105067 <sys_read+0x4b>
80105039:	83 ec 08             	sub    $0x8,%esp
8010503c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010503f:	50                   	push   %eax
80105040:	6a 02                	push   $0x2
80105042:	e8 81 fd ff ff       	call   80104dc8 <argint>
80105047:	83 c4 10             	add    $0x10,%esp
8010504a:	85 c0                	test   %eax,%eax
8010504c:	78 19                	js     80105067 <sys_read+0x4b>
8010504e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105051:	83 ec 04             	sub    $0x4,%esp
80105054:	50                   	push   %eax
80105055:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105058:	50                   	push   %eax
80105059:	6a 01                	push   $0x1
8010505b:	e8 95 fd ff ff       	call   80104df5 <argptr>
80105060:	83 c4 10             	add    $0x10,%esp
80105063:	85 c0                	test   %eax,%eax
80105065:	79 07                	jns    8010506e <sys_read+0x52>
    return -1;
80105067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506c:	eb 17                	jmp    80105085 <sys_read+0x69>
  return fileread(f, p, n);
8010506e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105071:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105077:	83 ec 04             	sub    $0x4,%esp
8010507a:	51                   	push   %ecx
8010507b:	52                   	push   %edx
8010507c:	50                   	push   %eax
8010507d:	e8 4e c1 ff ff       	call   801011d0 <fileread>
80105082:	83 c4 10             	add    $0x10,%esp
}
80105085:	c9                   	leave  
80105086:	c3                   	ret    

80105087 <sys_write>:

int
sys_write(void)
{
80105087:	55                   	push   %ebp
80105088:	89 e5                	mov    %esp,%ebp
8010508a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010508d:	83 ec 04             	sub    $0x4,%esp
80105090:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105093:	50                   	push   %eax
80105094:	6a 00                	push   $0x0
80105096:	6a 00                	push   $0x0
80105098:	e8 66 fe ff ff       	call   80104f03 <argfd>
8010509d:	83 c4 10             	add    $0x10,%esp
801050a0:	85 c0                	test   %eax,%eax
801050a2:	78 2e                	js     801050d2 <sys_write+0x4b>
801050a4:	83 ec 08             	sub    $0x8,%esp
801050a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050aa:	50                   	push   %eax
801050ab:	6a 02                	push   $0x2
801050ad:	e8 16 fd ff ff       	call   80104dc8 <argint>
801050b2:	83 c4 10             	add    $0x10,%esp
801050b5:	85 c0                	test   %eax,%eax
801050b7:	78 19                	js     801050d2 <sys_write+0x4b>
801050b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bc:	83 ec 04             	sub    $0x4,%esp
801050bf:	50                   	push   %eax
801050c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050c3:	50                   	push   %eax
801050c4:	6a 01                	push   $0x1
801050c6:	e8 2a fd ff ff       	call   80104df5 <argptr>
801050cb:	83 c4 10             	add    $0x10,%esp
801050ce:	85 c0                	test   %eax,%eax
801050d0:	79 07                	jns    801050d9 <sys_write+0x52>
    return -1;
801050d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d7:	eb 17                	jmp    801050f0 <sys_write+0x69>
  return filewrite(f, p, n);
801050d9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e2:	83 ec 04             	sub    $0x4,%esp
801050e5:	51                   	push   %ecx
801050e6:	52                   	push   %edx
801050e7:	50                   	push   %eax
801050e8:	e8 9b c1 ff ff       	call   80101288 <filewrite>
801050ed:	83 c4 10             	add    $0x10,%esp
}
801050f0:	c9                   	leave  
801050f1:	c3                   	ret    

801050f2 <sys_close>:

int
sys_close(void)
{
801050f2:	55                   	push   %ebp
801050f3:	89 e5                	mov    %esp,%ebp
801050f5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801050f8:	83 ec 04             	sub    $0x4,%esp
801050fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050fe:	50                   	push   %eax
801050ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105102:	50                   	push   %eax
80105103:	6a 00                	push   $0x0
80105105:	e8 f9 fd ff ff       	call   80104f03 <argfd>
8010510a:	83 c4 10             	add    $0x10,%esp
8010510d:	85 c0                	test   %eax,%eax
8010510f:	79 07                	jns    80105118 <sys_close+0x26>
    return -1;
80105111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105116:	eb 27                	jmp    8010513f <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105118:	e8 09 e9 ff ff       	call   80103a26 <myproc>
8010511d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105120:	83 c2 08             	add    $0x8,%edx
80105123:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010512a:	00 
  fileclose(f);
8010512b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010512e:	83 ec 0c             	sub    $0xc,%esp
80105131:	50                   	push   %eax
80105132:	e8 5a bf ff ff       	call   80101091 <fileclose>
80105137:	83 c4 10             	add    $0x10,%esp
  return 0;
8010513a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010513f:	c9                   	leave  
80105140:	c3                   	ret    

80105141 <sys_fstat>:

int
sys_fstat(void)
{
80105141:	55                   	push   %ebp
80105142:	89 e5                	mov    %esp,%ebp
80105144:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105147:	83 ec 04             	sub    $0x4,%esp
8010514a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010514d:	50                   	push   %eax
8010514e:	6a 00                	push   $0x0
80105150:	6a 00                	push   $0x0
80105152:	e8 ac fd ff ff       	call   80104f03 <argfd>
80105157:	83 c4 10             	add    $0x10,%esp
8010515a:	85 c0                	test   %eax,%eax
8010515c:	78 17                	js     80105175 <sys_fstat+0x34>
8010515e:	83 ec 04             	sub    $0x4,%esp
80105161:	6a 14                	push   $0x14
80105163:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105166:	50                   	push   %eax
80105167:	6a 01                	push   $0x1
80105169:	e8 87 fc ff ff       	call   80104df5 <argptr>
8010516e:	83 c4 10             	add    $0x10,%esp
80105171:	85 c0                	test   %eax,%eax
80105173:	79 07                	jns    8010517c <sys_fstat+0x3b>
    return -1;
80105175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517a:	eb 13                	jmp    8010518f <sys_fstat+0x4e>
  return filestat(f, st);
8010517c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105182:	83 ec 08             	sub    $0x8,%esp
80105185:	52                   	push   %edx
80105186:	50                   	push   %eax
80105187:	e8 ed bf ff ff       	call   80101179 <filestat>
8010518c:	83 c4 10             	add    $0x10,%esp
}
8010518f:	c9                   	leave  
80105190:	c3                   	ret    

80105191 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105191:	55                   	push   %ebp
80105192:	89 e5                	mov    %esp,%ebp
80105194:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105197:	83 ec 08             	sub    $0x8,%esp
8010519a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010519d:	50                   	push   %eax
8010519e:	6a 00                	push   $0x0
801051a0:	e8 a9 fc ff ff       	call   80104e4e <argstr>
801051a5:	83 c4 10             	add    $0x10,%esp
801051a8:	85 c0                	test   %eax,%eax
801051aa:	78 15                	js     801051c1 <sys_link+0x30>
801051ac:	83 ec 08             	sub    $0x8,%esp
801051af:	8d 45 dc             	lea    -0x24(%ebp),%eax
801051b2:	50                   	push   %eax
801051b3:	6a 01                	push   $0x1
801051b5:	e8 94 fc ff ff       	call   80104e4e <argstr>
801051ba:	83 c4 10             	add    $0x10,%esp
801051bd:	85 c0                	test   %eax,%eax
801051bf:	79 0a                	jns    801051cb <sys_link+0x3a>
    return -1;
801051c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c6:	e9 68 01 00 00       	jmp    80105333 <sys_link+0x1a2>

  begin_op();
801051cb:	e8 62 de ff ff       	call   80103032 <begin_op>
  if((ip = namei(old)) == 0){
801051d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801051d3:	83 ec 0c             	sub    $0xc,%esp
801051d6:	50                   	push   %eax
801051d7:	e8 37 d3 ff ff       	call   80102513 <namei>
801051dc:	83 c4 10             	add    $0x10,%esp
801051df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051e6:	75 0f                	jne    801051f7 <sys_link+0x66>
    end_op();
801051e8:	e8 d1 de ff ff       	call   801030be <end_op>
    return -1;
801051ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f2:	e9 3c 01 00 00       	jmp    80105333 <sys_link+0x1a2>
  }

  ilock(ip);
801051f7:	83 ec 0c             	sub    $0xc,%esp
801051fa:	ff 75 f4             	push   -0xc(%ebp)
801051fd:	e8 de c7 ff ff       	call   801019e0 <ilock>
80105202:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105208:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010520c:	66 83 f8 01          	cmp    $0x1,%ax
80105210:	75 1d                	jne    8010522f <sys_link+0x9e>
    iunlockput(ip);
80105212:	83 ec 0c             	sub    $0xc,%esp
80105215:	ff 75 f4             	push   -0xc(%ebp)
80105218:	e8 f4 c9 ff ff       	call   80101c11 <iunlockput>
8010521d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105220:	e8 99 de ff ff       	call   801030be <end_op>
    return -1;
80105225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522a:	e9 04 01 00 00       	jmp    80105333 <sys_link+0x1a2>
  }

  ip->nlink++;
8010522f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105232:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105236:	83 c0 01             	add    $0x1,%eax
80105239:	89 c2                	mov    %eax,%edx
8010523b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105242:	83 ec 0c             	sub    $0xc,%esp
80105245:	ff 75 f4             	push   -0xc(%ebp)
80105248:	e8 b6 c5 ff ff       	call   80101803 <iupdate>
8010524d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105250:	83 ec 0c             	sub    $0xc,%esp
80105253:	ff 75 f4             	push   -0xc(%ebp)
80105256:	e8 98 c8 ff ff       	call   80101af3 <iunlock>
8010525b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010525e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105261:	83 ec 08             	sub    $0x8,%esp
80105264:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105267:	52                   	push   %edx
80105268:	50                   	push   %eax
80105269:	e8 c1 d2 ff ff       	call   8010252f <nameiparent>
8010526e:	83 c4 10             	add    $0x10,%esp
80105271:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105278:	74 71                	je     801052eb <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010527a:	83 ec 0c             	sub    $0xc,%esp
8010527d:	ff 75 f0             	push   -0x10(%ebp)
80105280:	e8 5b c7 ff ff       	call   801019e0 <ilock>
80105285:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528b:	8b 10                	mov    (%eax),%edx
8010528d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105290:	8b 00                	mov    (%eax),%eax
80105292:	39 c2                	cmp    %eax,%edx
80105294:	75 1d                	jne    801052b3 <sys_link+0x122>
80105296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105299:	8b 40 04             	mov    0x4(%eax),%eax
8010529c:	83 ec 04             	sub    $0x4,%esp
8010529f:	50                   	push   %eax
801052a0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052a3:	50                   	push   %eax
801052a4:	ff 75 f0             	push   -0x10(%ebp)
801052a7:	e8 d0 cf ff ff       	call   8010227c <dirlink>
801052ac:	83 c4 10             	add    $0x10,%esp
801052af:	85 c0                	test   %eax,%eax
801052b1:	79 10                	jns    801052c3 <sys_link+0x132>
    iunlockput(dp);
801052b3:	83 ec 0c             	sub    $0xc,%esp
801052b6:	ff 75 f0             	push   -0x10(%ebp)
801052b9:	e8 53 c9 ff ff       	call   80101c11 <iunlockput>
801052be:	83 c4 10             	add    $0x10,%esp
    goto bad;
801052c1:	eb 29                	jmp    801052ec <sys_link+0x15b>
  }
  iunlockput(dp);
801052c3:	83 ec 0c             	sub    $0xc,%esp
801052c6:	ff 75 f0             	push   -0x10(%ebp)
801052c9:	e8 43 c9 ff ff       	call   80101c11 <iunlockput>
801052ce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801052d1:	83 ec 0c             	sub    $0xc,%esp
801052d4:	ff 75 f4             	push   -0xc(%ebp)
801052d7:	e8 65 c8 ff ff       	call   80101b41 <iput>
801052dc:	83 c4 10             	add    $0x10,%esp

  end_op();
801052df:	e8 da dd ff ff       	call   801030be <end_op>

  return 0;
801052e4:	b8 00 00 00 00       	mov    $0x0,%eax
801052e9:	eb 48                	jmp    80105333 <sys_link+0x1a2>
    goto bad;
801052eb:	90                   	nop

bad:
  ilock(ip);
801052ec:	83 ec 0c             	sub    $0xc,%esp
801052ef:	ff 75 f4             	push   -0xc(%ebp)
801052f2:	e8 e9 c6 ff ff       	call   801019e0 <ilock>
801052f7:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801052fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105301:	83 e8 01             	sub    $0x1,%eax
80105304:	89 c2                	mov    %eax,%edx
80105306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105309:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010530d:	83 ec 0c             	sub    $0xc,%esp
80105310:	ff 75 f4             	push   -0xc(%ebp)
80105313:	e8 eb c4 ff ff       	call   80101803 <iupdate>
80105318:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010531b:	83 ec 0c             	sub    $0xc,%esp
8010531e:	ff 75 f4             	push   -0xc(%ebp)
80105321:	e8 eb c8 ff ff       	call   80101c11 <iunlockput>
80105326:	83 c4 10             	add    $0x10,%esp
  end_op();
80105329:	e8 90 dd ff ff       	call   801030be <end_op>
  return -1;
8010532e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105333:	c9                   	leave  
80105334:	c3                   	ret    

80105335 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105335:	55                   	push   %ebp
80105336:	89 e5                	mov    %esp,%ebp
80105338:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010533b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105342:	eb 40                	jmp    80105384 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105347:	6a 10                	push   $0x10
80105349:	50                   	push   %eax
8010534a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010534d:	50                   	push   %eax
8010534e:	ff 75 08             	push   0x8(%ebp)
80105351:	e8 76 cb ff ff       	call   80101ecc <readi>
80105356:	83 c4 10             	add    $0x10,%esp
80105359:	83 f8 10             	cmp    $0x10,%eax
8010535c:	74 0d                	je     8010536b <isdirempty+0x36>
      panic("isdirempty: readi");
8010535e:	83 ec 0c             	sub    $0xc,%esp
80105361:	68 da a6 10 80       	push   $0x8010a6da
80105366:	e8 3e b2 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010536b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010536f:	66 85 c0             	test   %ax,%ax
80105372:	74 07                	je     8010537b <isdirempty+0x46>
      return 0;
80105374:	b8 00 00 00 00       	mov    $0x0,%eax
80105379:	eb 1b                	jmp    80105396 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010537b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537e:	83 c0 10             	add    $0x10,%eax
80105381:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105384:	8b 45 08             	mov    0x8(%ebp),%eax
80105387:	8b 50 58             	mov    0x58(%eax),%edx
8010538a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538d:	39 c2                	cmp    %eax,%edx
8010538f:	77 b3                	ja     80105344 <isdirempty+0xf>
  }
  return 1;
80105391:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105396:	c9                   	leave  
80105397:	c3                   	ret    

80105398 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105398:	55                   	push   %ebp
80105399:	89 e5                	mov    %esp,%ebp
8010539b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010539e:	83 ec 08             	sub    $0x8,%esp
801053a1:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053a4:	50                   	push   %eax
801053a5:	6a 00                	push   $0x0
801053a7:	e8 a2 fa ff ff       	call   80104e4e <argstr>
801053ac:	83 c4 10             	add    $0x10,%esp
801053af:	85 c0                	test   %eax,%eax
801053b1:	79 0a                	jns    801053bd <sys_unlink+0x25>
    return -1;
801053b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b8:	e9 bf 01 00 00       	jmp    8010557c <sys_unlink+0x1e4>

  begin_op();
801053bd:	e8 70 dc ff ff       	call   80103032 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801053c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053c5:	83 ec 08             	sub    $0x8,%esp
801053c8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801053cb:	52                   	push   %edx
801053cc:	50                   	push   %eax
801053cd:	e8 5d d1 ff ff       	call   8010252f <nameiparent>
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053dc:	75 0f                	jne    801053ed <sys_unlink+0x55>
    end_op();
801053de:	e8 db dc ff ff       	call   801030be <end_op>
    return -1;
801053e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e8:	e9 8f 01 00 00       	jmp    8010557c <sys_unlink+0x1e4>
  }

  ilock(dp);
801053ed:	83 ec 0c             	sub    $0xc,%esp
801053f0:	ff 75 f4             	push   -0xc(%ebp)
801053f3:	e8 e8 c5 ff ff       	call   801019e0 <ilock>
801053f8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053fb:	83 ec 08             	sub    $0x8,%esp
801053fe:	68 ec a6 10 80       	push   $0x8010a6ec
80105403:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105406:	50                   	push   %eax
80105407:	e8 9b cd ff ff       	call   801021a7 <namecmp>
8010540c:	83 c4 10             	add    $0x10,%esp
8010540f:	85 c0                	test   %eax,%eax
80105411:	0f 84 49 01 00 00    	je     80105560 <sys_unlink+0x1c8>
80105417:	83 ec 08             	sub    $0x8,%esp
8010541a:	68 ee a6 10 80       	push   $0x8010a6ee
8010541f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105422:	50                   	push   %eax
80105423:	e8 7f cd ff ff       	call   801021a7 <namecmp>
80105428:	83 c4 10             	add    $0x10,%esp
8010542b:	85 c0                	test   %eax,%eax
8010542d:	0f 84 2d 01 00 00    	je     80105560 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105433:	83 ec 04             	sub    $0x4,%esp
80105436:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105439:	50                   	push   %eax
8010543a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010543d:	50                   	push   %eax
8010543e:	ff 75 f4             	push   -0xc(%ebp)
80105441:	e8 7c cd ff ff       	call   801021c2 <dirlookup>
80105446:	83 c4 10             	add    $0x10,%esp
80105449:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010544c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105450:	0f 84 0d 01 00 00    	je     80105563 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105456:	83 ec 0c             	sub    $0xc,%esp
80105459:	ff 75 f0             	push   -0x10(%ebp)
8010545c:	e8 7f c5 ff ff       	call   801019e0 <ilock>
80105461:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105467:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010546b:	66 85 c0             	test   %ax,%ax
8010546e:	7f 0d                	jg     8010547d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105470:	83 ec 0c             	sub    $0xc,%esp
80105473:	68 f1 a6 10 80       	push   $0x8010a6f1
80105478:	e8 2c b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010547d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105480:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105484:	66 83 f8 01          	cmp    $0x1,%ax
80105488:	75 25                	jne    801054af <sys_unlink+0x117>
8010548a:	83 ec 0c             	sub    $0xc,%esp
8010548d:	ff 75 f0             	push   -0x10(%ebp)
80105490:	e8 a0 fe ff ff       	call   80105335 <isdirempty>
80105495:	83 c4 10             	add    $0x10,%esp
80105498:	85 c0                	test   %eax,%eax
8010549a:	75 13                	jne    801054af <sys_unlink+0x117>
    iunlockput(ip);
8010549c:	83 ec 0c             	sub    $0xc,%esp
8010549f:	ff 75 f0             	push   -0x10(%ebp)
801054a2:	e8 6a c7 ff ff       	call   80101c11 <iunlockput>
801054a7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801054aa:	e9 b5 00 00 00       	jmp    80105564 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801054af:	83 ec 04             	sub    $0x4,%esp
801054b2:	6a 10                	push   $0x10
801054b4:	6a 00                	push   $0x0
801054b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054b9:	50                   	push   %eax
801054ba:	e8 fa f5 ff ff       	call   80104ab9 <memset>
801054bf:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054c2:	8b 45 c8             	mov    -0x38(%ebp),%eax
801054c5:	6a 10                	push   $0x10
801054c7:	50                   	push   %eax
801054c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054cb:	50                   	push   %eax
801054cc:	ff 75 f4             	push   -0xc(%ebp)
801054cf:	e8 4d cb ff ff       	call   80102021 <writei>
801054d4:	83 c4 10             	add    $0x10,%esp
801054d7:	83 f8 10             	cmp    $0x10,%eax
801054da:	74 0d                	je     801054e9 <sys_unlink+0x151>
    panic("unlink: writei");
801054dc:	83 ec 0c             	sub    $0xc,%esp
801054df:	68 03 a7 10 80       	push   $0x8010a703
801054e4:	e8 c0 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801054e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054f0:	66 83 f8 01          	cmp    $0x1,%ax
801054f4:	75 21                	jne    80105517 <sys_unlink+0x17f>
    dp->nlink--;
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054fd:	83 e8 01             	sub    $0x1,%eax
80105500:	89 c2                	mov    %eax,%edx
80105502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105505:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105509:	83 ec 0c             	sub    $0xc,%esp
8010550c:	ff 75 f4             	push   -0xc(%ebp)
8010550f:	e8 ef c2 ff ff       	call   80101803 <iupdate>
80105514:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	ff 75 f4             	push   -0xc(%ebp)
8010551d:	e8 ef c6 ff ff       	call   80101c11 <iunlockput>
80105522:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105528:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010552c:	83 e8 01             	sub    $0x1,%eax
8010552f:	89 c2                	mov    %eax,%edx
80105531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105534:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105538:	83 ec 0c             	sub    $0xc,%esp
8010553b:	ff 75 f0             	push   -0x10(%ebp)
8010553e:	e8 c0 c2 ff ff       	call   80101803 <iupdate>
80105543:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105546:	83 ec 0c             	sub    $0xc,%esp
80105549:	ff 75 f0             	push   -0x10(%ebp)
8010554c:	e8 c0 c6 ff ff       	call   80101c11 <iunlockput>
80105551:	83 c4 10             	add    $0x10,%esp

  end_op();
80105554:	e8 65 db ff ff       	call   801030be <end_op>

  return 0;
80105559:	b8 00 00 00 00       	mov    $0x0,%eax
8010555e:	eb 1c                	jmp    8010557c <sys_unlink+0x1e4>
    goto bad;
80105560:	90                   	nop
80105561:	eb 01                	jmp    80105564 <sys_unlink+0x1cc>
    goto bad;
80105563:	90                   	nop

bad:
  iunlockput(dp);
80105564:	83 ec 0c             	sub    $0xc,%esp
80105567:	ff 75 f4             	push   -0xc(%ebp)
8010556a:	e8 a2 c6 ff ff       	call   80101c11 <iunlockput>
8010556f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105572:	e8 47 db ff ff       	call   801030be <end_op>
  return -1;
80105577:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010557c:	c9                   	leave  
8010557d:	c3                   	ret    

8010557e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010557e:	55                   	push   %ebp
8010557f:	89 e5                	mov    %esp,%ebp
80105581:	83 ec 38             	sub    $0x38,%esp
80105584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105587:	8b 55 10             	mov    0x10(%ebp),%edx
8010558a:	8b 45 14             	mov    0x14(%ebp),%eax
8010558d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105591:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105595:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105599:	83 ec 08             	sub    $0x8,%esp
8010559c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010559f:	50                   	push   %eax
801055a0:	ff 75 08             	push   0x8(%ebp)
801055a3:	e8 87 cf ff ff       	call   8010252f <nameiparent>
801055a8:	83 c4 10             	add    $0x10,%esp
801055ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055b2:	75 0a                	jne    801055be <create+0x40>
    return 0;
801055b4:	b8 00 00 00 00       	mov    $0x0,%eax
801055b9:	e9 90 01 00 00       	jmp    8010574e <create+0x1d0>
  ilock(dp);
801055be:	83 ec 0c             	sub    $0xc,%esp
801055c1:	ff 75 f4             	push   -0xc(%ebp)
801055c4:	e8 17 c4 ff ff       	call   801019e0 <ilock>
801055c9:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801055cc:	83 ec 04             	sub    $0x4,%esp
801055cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055d2:	50                   	push   %eax
801055d3:	8d 45 de             	lea    -0x22(%ebp),%eax
801055d6:	50                   	push   %eax
801055d7:	ff 75 f4             	push   -0xc(%ebp)
801055da:	e8 e3 cb ff ff       	call   801021c2 <dirlookup>
801055df:	83 c4 10             	add    $0x10,%esp
801055e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055e9:	74 50                	je     8010563b <create+0xbd>
    iunlockput(dp);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	ff 75 f4             	push   -0xc(%ebp)
801055f1:	e8 1b c6 ff ff       	call   80101c11 <iunlockput>
801055f6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801055f9:	83 ec 0c             	sub    $0xc,%esp
801055fc:	ff 75 f0             	push   -0x10(%ebp)
801055ff:	e8 dc c3 ff ff       	call   801019e0 <ilock>
80105604:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105607:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010560c:	75 15                	jne    80105623 <create+0xa5>
8010560e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105611:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105615:	66 83 f8 02          	cmp    $0x2,%ax
80105619:	75 08                	jne    80105623 <create+0xa5>
      return ip;
8010561b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561e:	e9 2b 01 00 00       	jmp    8010574e <create+0x1d0>
    iunlockput(ip);
80105623:	83 ec 0c             	sub    $0xc,%esp
80105626:	ff 75 f0             	push   -0x10(%ebp)
80105629:	e8 e3 c5 ff ff       	call   80101c11 <iunlockput>
8010562e:	83 c4 10             	add    $0x10,%esp
    return 0;
80105631:	b8 00 00 00 00       	mov    $0x0,%eax
80105636:	e9 13 01 00 00       	jmp    8010574e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010563b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105642:	8b 00                	mov    (%eax),%eax
80105644:	83 ec 08             	sub    $0x8,%esp
80105647:	52                   	push   %edx
80105648:	50                   	push   %eax
80105649:	e8 de c0 ff ff       	call   8010172c <ialloc>
8010564e:	83 c4 10             	add    $0x10,%esp
80105651:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105654:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105658:	75 0d                	jne    80105667 <create+0xe9>
    panic("create: ialloc");
8010565a:	83 ec 0c             	sub    $0xc,%esp
8010565d:	68 12 a7 10 80       	push   $0x8010a712
80105662:	e8 42 af ff ff       	call   801005a9 <panic>

  ilock(ip);
80105667:	83 ec 0c             	sub    $0xc,%esp
8010566a:	ff 75 f0             	push   -0x10(%ebp)
8010566d:	e8 6e c3 ff ff       	call   801019e0 <ilock>
80105672:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105678:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010567c:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105683:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105687:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010568b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105694:	83 ec 0c             	sub    $0xc,%esp
80105697:	ff 75 f0             	push   -0x10(%ebp)
8010569a:	e8 64 c1 ff ff       	call   80101803 <iupdate>
8010569f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056a2:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056a7:	75 6a                	jne    80105713 <create+0x195>
    dp->nlink++;  // for ".."
801056a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ac:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056b0:	83 c0 01             	add    $0x1,%eax
801056b3:	89 c2                	mov    %eax,%edx
801056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b8:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801056bc:	83 ec 0c             	sub    $0xc,%esp
801056bf:	ff 75 f4             	push   -0xc(%ebp)
801056c2:	e8 3c c1 ff ff       	call   80101803 <iupdate>
801056c7:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801056ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cd:	8b 40 04             	mov    0x4(%eax),%eax
801056d0:	83 ec 04             	sub    $0x4,%esp
801056d3:	50                   	push   %eax
801056d4:	68 ec a6 10 80       	push   $0x8010a6ec
801056d9:	ff 75 f0             	push   -0x10(%ebp)
801056dc:	e8 9b cb ff ff       	call   8010227c <dirlink>
801056e1:	83 c4 10             	add    $0x10,%esp
801056e4:	85 c0                	test   %eax,%eax
801056e6:	78 1e                	js     80105706 <create+0x188>
801056e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056eb:	8b 40 04             	mov    0x4(%eax),%eax
801056ee:	83 ec 04             	sub    $0x4,%esp
801056f1:	50                   	push   %eax
801056f2:	68 ee a6 10 80       	push   $0x8010a6ee
801056f7:	ff 75 f0             	push   -0x10(%ebp)
801056fa:	e8 7d cb ff ff       	call   8010227c <dirlink>
801056ff:	83 c4 10             	add    $0x10,%esp
80105702:	85 c0                	test   %eax,%eax
80105704:	79 0d                	jns    80105713 <create+0x195>
      panic("create dots");
80105706:	83 ec 0c             	sub    $0xc,%esp
80105709:	68 21 a7 10 80       	push   $0x8010a721
8010570e:	e8 96 ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105716:	8b 40 04             	mov    0x4(%eax),%eax
80105719:	83 ec 04             	sub    $0x4,%esp
8010571c:	50                   	push   %eax
8010571d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105720:	50                   	push   %eax
80105721:	ff 75 f4             	push   -0xc(%ebp)
80105724:	e8 53 cb ff ff       	call   8010227c <dirlink>
80105729:	83 c4 10             	add    $0x10,%esp
8010572c:	85 c0                	test   %eax,%eax
8010572e:	79 0d                	jns    8010573d <create+0x1bf>
    panic("create: dirlink");
80105730:	83 ec 0c             	sub    $0xc,%esp
80105733:	68 2d a7 10 80       	push   $0x8010a72d
80105738:	e8 6c ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010573d:	83 ec 0c             	sub    $0xc,%esp
80105740:	ff 75 f4             	push   -0xc(%ebp)
80105743:	e8 c9 c4 ff ff       	call   80101c11 <iunlockput>
80105748:	83 c4 10             	add    $0x10,%esp

  return ip;
8010574b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010574e:	c9                   	leave  
8010574f:	c3                   	ret    

80105750 <sys_open>:

int
sys_open(void)
{
80105750:	55                   	push   %ebp
80105751:	89 e5                	mov    %esp,%ebp
80105753:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105756:	83 ec 08             	sub    $0x8,%esp
80105759:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010575c:	50                   	push   %eax
8010575d:	6a 00                	push   $0x0
8010575f:	e8 ea f6 ff ff       	call   80104e4e <argstr>
80105764:	83 c4 10             	add    $0x10,%esp
80105767:	85 c0                	test   %eax,%eax
80105769:	78 15                	js     80105780 <sys_open+0x30>
8010576b:	83 ec 08             	sub    $0x8,%esp
8010576e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105771:	50                   	push   %eax
80105772:	6a 01                	push   $0x1
80105774:	e8 4f f6 ff ff       	call   80104dc8 <argint>
80105779:	83 c4 10             	add    $0x10,%esp
8010577c:	85 c0                	test   %eax,%eax
8010577e:	79 0a                	jns    8010578a <sys_open+0x3a>
    return -1;
80105780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105785:	e9 61 01 00 00       	jmp    801058eb <sys_open+0x19b>

  begin_op();
8010578a:	e8 a3 d8 ff ff       	call   80103032 <begin_op>

  if(omode & O_CREATE){
8010578f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105792:	25 00 02 00 00       	and    $0x200,%eax
80105797:	85 c0                	test   %eax,%eax
80105799:	74 2a                	je     801057c5 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010579b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010579e:	6a 00                	push   $0x0
801057a0:	6a 00                	push   $0x0
801057a2:	6a 02                	push   $0x2
801057a4:	50                   	push   %eax
801057a5:	e8 d4 fd ff ff       	call   8010557e <create>
801057aa:	83 c4 10             	add    $0x10,%esp
801057ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801057b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b4:	75 75                	jne    8010582b <sys_open+0xdb>
      end_op();
801057b6:	e8 03 d9 ff ff       	call   801030be <end_op>
      return -1;
801057bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c0:	e9 26 01 00 00       	jmp    801058eb <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801057c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057c8:	83 ec 0c             	sub    $0xc,%esp
801057cb:	50                   	push   %eax
801057cc:	e8 42 cd ff ff       	call   80102513 <namei>
801057d1:	83 c4 10             	add    $0x10,%esp
801057d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057db:	75 0f                	jne    801057ec <sys_open+0x9c>
      end_op();
801057dd:	e8 dc d8 ff ff       	call   801030be <end_op>
      return -1;
801057e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e7:	e9 ff 00 00 00       	jmp    801058eb <sys_open+0x19b>
    }
    ilock(ip);
801057ec:	83 ec 0c             	sub    $0xc,%esp
801057ef:	ff 75 f4             	push   -0xc(%ebp)
801057f2:	e8 e9 c1 ff ff       	call   801019e0 <ilock>
801057f7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801057fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105801:	66 83 f8 01          	cmp    $0x1,%ax
80105805:	75 24                	jne    8010582b <sys_open+0xdb>
80105807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010580a:	85 c0                	test   %eax,%eax
8010580c:	74 1d                	je     8010582b <sys_open+0xdb>
      iunlockput(ip);
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	ff 75 f4             	push   -0xc(%ebp)
80105814:	e8 f8 c3 ff ff       	call   80101c11 <iunlockput>
80105819:	83 c4 10             	add    $0x10,%esp
      end_op();
8010581c:	e8 9d d8 ff ff       	call   801030be <end_op>
      return -1;
80105821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105826:	e9 c0 00 00 00       	jmp    801058eb <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010582b:	e8 a3 b7 ff ff       	call   80100fd3 <filealloc>
80105830:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105833:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105837:	74 17                	je     80105850 <sys_open+0x100>
80105839:	83 ec 0c             	sub    $0xc,%esp
8010583c:	ff 75 f0             	push   -0x10(%ebp)
8010583f:	e8 33 f7 ff ff       	call   80104f77 <fdalloc>
80105844:	83 c4 10             	add    $0x10,%esp
80105847:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010584a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010584e:	79 2e                	jns    8010587e <sys_open+0x12e>
    if(f)
80105850:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105854:	74 0e                	je     80105864 <sys_open+0x114>
      fileclose(f);
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	ff 75 f0             	push   -0x10(%ebp)
8010585c:	e8 30 b8 ff ff       	call   80101091 <fileclose>
80105861:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105864:	83 ec 0c             	sub    $0xc,%esp
80105867:	ff 75 f4             	push   -0xc(%ebp)
8010586a:	e8 a2 c3 ff ff       	call   80101c11 <iunlockput>
8010586f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105872:	e8 47 d8 ff ff       	call   801030be <end_op>
    return -1;
80105877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587c:	eb 6d                	jmp    801058eb <sys_open+0x19b>
  }
  iunlock(ip);
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	ff 75 f4             	push   -0xc(%ebp)
80105884:	e8 6a c2 ff ff       	call   80101af3 <iunlock>
80105889:	83 c4 10             	add    $0x10,%esp
  end_op();
8010588c:	e8 2d d8 ff ff       	call   801030be <end_op>

  f->type = FD_INODE;
80105891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105894:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010589a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058a0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801058ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058b0:	83 e0 01             	and    $0x1,%eax
801058b3:	85 c0                	test   %eax,%eax
801058b5:	0f 94 c0             	sete   %al
801058b8:	89 c2                	mov    %eax,%edx
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058c3:	83 e0 01             	and    $0x1,%eax
801058c6:	85 c0                	test   %eax,%eax
801058c8:	75 0a                	jne    801058d4 <sys_open+0x184>
801058ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058cd:	83 e0 02             	and    $0x2,%eax
801058d0:	85 c0                	test   %eax,%eax
801058d2:	74 07                	je     801058db <sys_open+0x18b>
801058d4:	b8 01 00 00 00       	mov    $0x1,%eax
801058d9:	eb 05                	jmp    801058e0 <sys_open+0x190>
801058db:	b8 00 00 00 00       	mov    $0x0,%eax
801058e0:	89 c2                	mov    %eax,%edx
801058e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058eb:	c9                   	leave  
801058ec:	c3                   	ret    

801058ed <sys_mkdir>:

int
sys_mkdir(void)
{
801058ed:	55                   	push   %ebp
801058ee:	89 e5                	mov    %esp,%ebp
801058f0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058f3:	e8 3a d7 ff ff       	call   80103032 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058f8:	83 ec 08             	sub    $0x8,%esp
801058fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058fe:	50                   	push   %eax
801058ff:	6a 00                	push   $0x0
80105901:	e8 48 f5 ff ff       	call   80104e4e <argstr>
80105906:	83 c4 10             	add    $0x10,%esp
80105909:	85 c0                	test   %eax,%eax
8010590b:	78 1b                	js     80105928 <sys_mkdir+0x3b>
8010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105910:	6a 00                	push   $0x0
80105912:	6a 00                	push   $0x0
80105914:	6a 01                	push   $0x1
80105916:	50                   	push   %eax
80105917:	e8 62 fc ff ff       	call   8010557e <create>
8010591c:	83 c4 10             	add    $0x10,%esp
8010591f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105922:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105926:	75 0c                	jne    80105934 <sys_mkdir+0x47>
    end_op();
80105928:	e8 91 d7 ff ff       	call   801030be <end_op>
    return -1;
8010592d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105932:	eb 18                	jmp    8010594c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105934:	83 ec 0c             	sub    $0xc,%esp
80105937:	ff 75 f4             	push   -0xc(%ebp)
8010593a:	e8 d2 c2 ff ff       	call   80101c11 <iunlockput>
8010593f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105942:	e8 77 d7 ff ff       	call   801030be <end_op>
  return 0;
80105947:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010594c:	c9                   	leave  
8010594d:	c3                   	ret    

8010594e <sys_mknod>:

int
sys_mknod(void)
{
8010594e:	55                   	push   %ebp
8010594f:	89 e5                	mov    %esp,%ebp
80105951:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105954:	e8 d9 d6 ff ff       	call   80103032 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105959:	83 ec 08             	sub    $0x8,%esp
8010595c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595f:	50                   	push   %eax
80105960:	6a 00                	push   $0x0
80105962:	e8 e7 f4 ff ff       	call   80104e4e <argstr>
80105967:	83 c4 10             	add    $0x10,%esp
8010596a:	85 c0                	test   %eax,%eax
8010596c:	78 4f                	js     801059bd <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010596e:	83 ec 08             	sub    $0x8,%esp
80105971:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105974:	50                   	push   %eax
80105975:	6a 01                	push   $0x1
80105977:	e8 4c f4 ff ff       	call   80104dc8 <argint>
8010597c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010597f:	85 c0                	test   %eax,%eax
80105981:	78 3a                	js     801059bd <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105983:	83 ec 08             	sub    $0x8,%esp
80105986:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105989:	50                   	push   %eax
8010598a:	6a 02                	push   $0x2
8010598c:	e8 37 f4 ff ff       	call   80104dc8 <argint>
80105991:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105994:	85 c0                	test   %eax,%eax
80105996:	78 25                	js     801059bd <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105998:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010599b:	0f bf c8             	movswl %ax,%ecx
8010599e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059a1:	0f bf d0             	movswl %ax,%edx
801059a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a7:	51                   	push   %ecx
801059a8:	52                   	push   %edx
801059a9:	6a 03                	push   $0x3
801059ab:	50                   	push   %eax
801059ac:	e8 cd fb ff ff       	call   8010557e <create>
801059b1:	83 c4 10             	add    $0x10,%esp
801059b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801059b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059bb:	75 0c                	jne    801059c9 <sys_mknod+0x7b>
    end_op();
801059bd:	e8 fc d6 ff ff       	call   801030be <end_op>
    return -1;
801059c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c7:	eb 18                	jmp    801059e1 <sys_mknod+0x93>
  }
  iunlockput(ip);
801059c9:	83 ec 0c             	sub    $0xc,%esp
801059cc:	ff 75 f4             	push   -0xc(%ebp)
801059cf:	e8 3d c2 ff ff       	call   80101c11 <iunlockput>
801059d4:	83 c4 10             	add    $0x10,%esp
  end_op();
801059d7:	e8 e2 d6 ff ff       	call   801030be <end_op>
  return 0;
801059dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059e1:	c9                   	leave  
801059e2:	c3                   	ret    

801059e3 <sys_chdir>:

int
sys_chdir(void)
{
801059e3:	55                   	push   %ebp
801059e4:	89 e5                	mov    %esp,%ebp
801059e6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059e9:	e8 38 e0 ff ff       	call   80103a26 <myproc>
801059ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059f1:	e8 3c d6 ff ff       	call   80103032 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801059f6:	83 ec 08             	sub    $0x8,%esp
801059f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059fc:	50                   	push   %eax
801059fd:	6a 00                	push   $0x0
801059ff:	e8 4a f4 ff ff       	call   80104e4e <argstr>
80105a04:	83 c4 10             	add    $0x10,%esp
80105a07:	85 c0                	test   %eax,%eax
80105a09:	78 18                	js     80105a23 <sys_chdir+0x40>
80105a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	50                   	push   %eax
80105a12:	e8 fc ca ff ff       	call   80102513 <namei>
80105a17:	83 c4 10             	add    $0x10,%esp
80105a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a21:	75 0c                	jne    80105a2f <sys_chdir+0x4c>
    end_op();
80105a23:	e8 96 d6 ff ff       	call   801030be <end_op>
    return -1;
80105a28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2d:	eb 68                	jmp    80105a97 <sys_chdir+0xb4>
  }
  ilock(ip);
80105a2f:	83 ec 0c             	sub    $0xc,%esp
80105a32:	ff 75 f0             	push   -0x10(%ebp)
80105a35:	e8 a6 bf ff ff       	call   801019e0 <ilock>
80105a3a:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a40:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a44:	66 83 f8 01          	cmp    $0x1,%ax
80105a48:	74 1a                	je     80105a64 <sys_chdir+0x81>
    iunlockput(ip);
80105a4a:	83 ec 0c             	sub    $0xc,%esp
80105a4d:	ff 75 f0             	push   -0x10(%ebp)
80105a50:	e8 bc c1 ff ff       	call   80101c11 <iunlockput>
80105a55:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a58:	e8 61 d6 ff ff       	call   801030be <end_op>
    return -1;
80105a5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a62:	eb 33                	jmp    80105a97 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a64:	83 ec 0c             	sub    $0xc,%esp
80105a67:	ff 75 f0             	push   -0x10(%ebp)
80105a6a:	e8 84 c0 ff ff       	call   80101af3 <iunlock>
80105a6f:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a75:	8b 40 68             	mov    0x68(%eax),%eax
80105a78:	83 ec 0c             	sub    $0xc,%esp
80105a7b:	50                   	push   %eax
80105a7c:	e8 c0 c0 ff ff       	call   80101b41 <iput>
80105a81:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a84:	e8 35 d6 ff ff       	call   801030be <end_op>
  curproc->cwd = ip;
80105a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a8f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a97:	c9                   	leave  
80105a98:	c3                   	ret    

80105a99 <sys_exec>:

int
sys_exec(void)
{
80105a99:	55                   	push   %ebp
80105a9a:	89 e5                	mov    %esp,%ebp
80105a9c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105aa2:	83 ec 08             	sub    $0x8,%esp
80105aa5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aa8:	50                   	push   %eax
80105aa9:	6a 00                	push   $0x0
80105aab:	e8 9e f3 ff ff       	call   80104e4e <argstr>
80105ab0:	83 c4 10             	add    $0x10,%esp
80105ab3:	85 c0                	test   %eax,%eax
80105ab5:	78 18                	js     80105acf <sys_exec+0x36>
80105ab7:	83 ec 08             	sub    $0x8,%esp
80105aba:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ac0:	50                   	push   %eax
80105ac1:	6a 01                	push   $0x1
80105ac3:	e8 00 f3 ff ff       	call   80104dc8 <argint>
80105ac8:	83 c4 10             	add    $0x10,%esp
80105acb:	85 c0                	test   %eax,%eax
80105acd:	79 0a                	jns    80105ad9 <sys_exec+0x40>
    return -1;
80105acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad4:	e9 c6 00 00 00       	jmp    80105b9f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ad9:	83 ec 04             	sub    $0x4,%esp
80105adc:	68 80 00 00 00       	push   $0x80
80105ae1:	6a 00                	push   $0x0
80105ae3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ae9:	50                   	push   %eax
80105aea:	e8 ca ef ff ff       	call   80104ab9 <memset>
80105aef:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	83 f8 1f             	cmp    $0x1f,%eax
80105aff:	76 0a                	jbe    80105b0b <sys_exec+0x72>
      return -1;
80105b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b06:	e9 94 00 00 00       	jmp    80105b9f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	c1 e0 02             	shl    $0x2,%eax
80105b11:	89 c2                	mov    %eax,%edx
80105b13:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b19:	01 c2                	add    %eax,%edx
80105b1b:	83 ec 08             	sub    $0x8,%esp
80105b1e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b24:	50                   	push   %eax
80105b25:	52                   	push   %edx
80105b26:	e8 18 f2 ff ff       	call   80104d43 <fetchint>
80105b2b:	83 c4 10             	add    $0x10,%esp
80105b2e:	85 c0                	test   %eax,%eax
80105b30:	79 07                	jns    80105b39 <sys_exec+0xa0>
      return -1;
80105b32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b37:	eb 66                	jmp    80105b9f <sys_exec+0x106>
    if(uarg == 0){
80105b39:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b3f:	85 c0                	test   %eax,%eax
80105b41:	75 27                	jne    80105b6a <sys_exec+0xd1>
      argv[i] = 0;
80105b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b46:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b4d:	00 00 00 00 
      break;
80105b51:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b55:	83 ec 08             	sub    $0x8,%esp
80105b58:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b5e:	52                   	push   %edx
80105b5f:	50                   	push   %eax
80105b60:	e8 1b b0 ff ff       	call   80100b80 <exec>
80105b65:	83 c4 10             	add    $0x10,%esp
80105b68:	eb 35                	jmp    80105b9f <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b6a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b73:	c1 e0 02             	shl    $0x2,%eax
80105b76:	01 c2                	add    %eax,%edx
80105b78:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b7e:	83 ec 08             	sub    $0x8,%esp
80105b81:	52                   	push   %edx
80105b82:	50                   	push   %eax
80105b83:	e8 ea f1 ff ff       	call   80104d72 <fetchstr>
80105b88:	83 c4 10             	add    $0x10,%esp
80105b8b:	85 c0                	test   %eax,%eax
80105b8d:	79 07                	jns    80105b96 <sys_exec+0xfd>
      return -1;
80105b8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b94:	eb 09                	jmp    80105b9f <sys_exec+0x106>
  for(i=0;; i++){
80105b96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b9a:	e9 5a ff ff ff       	jmp    80105af9 <sys_exec+0x60>
}
80105b9f:	c9                   	leave  
80105ba0:	c3                   	ret    

80105ba1 <sys_pipe>:

int
sys_pipe(void)
{
80105ba1:	55                   	push   %ebp
80105ba2:	89 e5                	mov    %esp,%ebp
80105ba4:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ba7:	83 ec 04             	sub    $0x4,%esp
80105baa:	6a 08                	push   $0x8
80105bac:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105baf:	50                   	push   %eax
80105bb0:	6a 00                	push   $0x0
80105bb2:	e8 3e f2 ff ff       	call   80104df5 <argptr>
80105bb7:	83 c4 10             	add    $0x10,%esp
80105bba:	85 c0                	test   %eax,%eax
80105bbc:	79 0a                	jns    80105bc8 <sys_pipe+0x27>
    return -1;
80105bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc3:	e9 ae 00 00 00       	jmp    80105c76 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105bc8:	83 ec 08             	sub    $0x8,%esp
80105bcb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bce:	50                   	push   %eax
80105bcf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105bd2:	50                   	push   %eax
80105bd3:	e8 8b d9 ff ff       	call   80103563 <pipealloc>
80105bd8:	83 c4 10             	add    $0x10,%esp
80105bdb:	85 c0                	test   %eax,%eax
80105bdd:	79 0a                	jns    80105be9 <sys_pipe+0x48>
    return -1;
80105bdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be4:	e9 8d 00 00 00       	jmp    80105c76 <sys_pipe+0xd5>
  fd0 = -1;
80105be9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bf3:	83 ec 0c             	sub    $0xc,%esp
80105bf6:	50                   	push   %eax
80105bf7:	e8 7b f3 ff ff       	call   80104f77 <fdalloc>
80105bfc:	83 c4 10             	add    $0x10,%esp
80105bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c06:	78 18                	js     80105c20 <sys_pipe+0x7f>
80105c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c0b:	83 ec 0c             	sub    $0xc,%esp
80105c0e:	50                   	push   %eax
80105c0f:	e8 63 f3 ff ff       	call   80104f77 <fdalloc>
80105c14:	83 c4 10             	add    $0x10,%esp
80105c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c1e:	79 3e                	jns    80105c5e <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c24:	78 13                	js     80105c39 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c26:	e8 fb dd ff ff       	call   80103a26 <myproc>
80105c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c2e:	83 c2 08             	add    $0x8,%edx
80105c31:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c38:	00 
    fileclose(rf);
80105c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	50                   	push   %eax
80105c40:	e8 4c b4 ff ff       	call   80101091 <fileclose>
80105c45:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c4b:	83 ec 0c             	sub    $0xc,%esp
80105c4e:	50                   	push   %eax
80105c4f:	e8 3d b4 ff ff       	call   80101091 <fileclose>
80105c54:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5c:	eb 18                	jmp    80105c76 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c64:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c69:	8d 50 04             	lea    0x4(%eax),%edx
80105c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6f:	89 02                	mov    %eax,(%edx)
  return 0;
80105c71:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c76:	c9                   	leave  
80105c77:	c3                   	ret    

80105c78 <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
80105c78:	55                   	push   %ebp
80105c79:	89 e5                	mov    %esp,%ebp
80105c7b:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c7e:	e8 a2 e0 ff ff       	call   80103d25 <fork>
}
80105c83:	c9                   	leave  
80105c84:	c3                   	ret    

80105c85 <sys_exit>:

int
sys_exit(void)
{
80105c85:	55                   	push   %ebp
80105c86:	89 e5                	mov    %esp,%ebp
80105c88:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c8b:	e8 0e e2 ff ff       	call   80103e9e <exit>
  return 0;  // not reached
80105c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c95:	c9                   	leave  
80105c96:	c3                   	ret    

80105c97 <sys_wait>:

int
sys_wait(void)
{
80105c97:	55                   	push   %ebp
80105c98:	89 e5                	mov    %esp,%ebp
80105c9a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105c9d:	e8 1c e3 ff ff       	call   80103fbe <wait>
}
80105ca2:	c9                   	leave  
80105ca3:	c3                   	ret    

80105ca4 <sys_kill>:

int
sys_kill(void)
{
80105ca4:	55                   	push   %ebp
80105ca5:	89 e5                	mov    %esp,%ebp
80105ca7:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105caa:	83 ec 08             	sub    $0x8,%esp
80105cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cb0:	50                   	push   %eax
80105cb1:	6a 00                	push   $0x0
80105cb3:	e8 10 f1 ff ff       	call   80104dc8 <argint>
80105cb8:	83 c4 10             	add    $0x10,%esp
80105cbb:	85 c0                	test   %eax,%eax
80105cbd:	79 07                	jns    80105cc6 <sys_kill+0x22>
    return -1;
80105cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc4:	eb 0f                	jmp    80105cd5 <sys_kill+0x31>
  return kill(pid);
80105cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc9:	83 ec 0c             	sub    $0xc,%esp
80105ccc:	50                   	push   %eax
80105ccd:	e8 1b e7 ff ff       	call   801043ed <kill>
80105cd2:	83 c4 10             	add    $0x10,%esp
}
80105cd5:	c9                   	leave  
80105cd6:	c3                   	ret    

80105cd7 <sys_getpid>:

int
sys_getpid(void)
{
80105cd7:	55                   	push   %ebp
80105cd8:	89 e5                	mov    %esp,%ebp
80105cda:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105cdd:	e8 44 dd ff ff       	call   80103a26 <myproc>
80105ce2:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ce5:	c9                   	leave  
80105ce6:	c3                   	ret    

80105ce7 <sys_printpt>:
 //추가
int
sys_printpt(void)
{
80105ce7:	55                   	push   %ebp
80105ce8:	89 e5                	mov    %esp,%ebp
80105cea:	83 ec 18             	sub    $0x18,%esp
  int pid =0;
80105ced:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (argint(0, &pid) < 0) //사용자에게 pid 넘겨받지 못하면 실패
80105cf4:	83 ec 08             	sub    $0x8,%esp
80105cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cfa:	50                   	push   %eax
80105cfb:	6a 00                	push   $0x0
80105cfd:	e8 c6 f0 ff ff       	call   80104dc8 <argint>
80105d02:	83 c4 10             	add    $0x10,%esp
80105d05:	85 c0                	test   %eax,%eax
80105d07:	79 07                	jns    80105d10 <sys_printpt+0x29>
    return -1;
80105d09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0e:	eb 0f                	jmp    80105d1f <sys_printpt+0x38>
  
  return printpt(pid);
80105d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d13:	83 ec 0c             	sub    $0xc,%esp
80105d16:	50                   	push   %eax
80105d17:	e8 4f e8 ff ff       	call   8010456b <printpt>
80105d1c:	83 c4 10             	add    $0x10,%esp
}
80105d1f:	c9                   	leave  
80105d20:	c3                   	ret    

80105d21 <sys_sbrk>:

//lazy allocation 수정
int
sys_sbrk(void)
{
80105d21:	55                   	push   %ebp
80105d22:	89 e5                	mov    %esp,%ebp
80105d24:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc *curproc = myproc ();
80105d27:	e8 fa dc ff ff       	call   80103a26 <myproc>
80105d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(argint(0, &n) < 0)
80105d2f:	83 ec 08             	sub    $0x8,%esp
80105d32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d35:	50                   	push   %eax
80105d36:	6a 00                	push   $0x0
80105d38:	e8 8b f0 ff ff       	call   80104dc8 <argint>
80105d3d:	83 c4 10             	add    $0x10,%esp
80105d40:	85 c0                	test   %eax,%eax
80105d42:	79 0a                	jns    80105d4e <sys_sbrk+0x2d>
    return -1;
80105d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d49:	e9 ab 00 00 00       	jmp    80105df9 <sys_sbrk+0xd8>

  addr = curproc->sz;
80105d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d51:	8b 00                	mov    (%eax),%eax
80105d53:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(n < 0) {
80105d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d59:	85 c0                	test   %eax,%eax
80105d5b:	79 6e                	jns    80105dcb <sys_sbrk+0xaa>

    uint oldsz = curproc->sz;
80105d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d60:	8b 00                	mov    (%eax),%eax
80105d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
    uint newsz = oldsz + n;
80105d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d68:	89 c2                	mov    %eax,%edx
80105d6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d6d:	01 d0                	add    %edx,%eax
80105d6f:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if (newsz > oldsz) //오버플로우 방지
80105d72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d75:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105d78:	76 07                	jbe    80105d81 <sys_sbrk+0x60>
    return -1;
80105d7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7f:	eb 78                	jmp    80105df9 <sys_sbrk+0xd8>

    //PGROUNDUP된 boundary 범위만 unmap
    if(deallocuvm(curproc->pgdir, PGROUNDUP(oldsz), PGROUNDUP(newsz)) == 0)
80105d81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d84:	05 ff 0f 00 00       	add    $0xfff,%eax
80105d89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105d8e:	89 c1                	mov    %eax,%ecx
80105d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d93:	05 ff 0f 00 00       	add    $0xfff,%eax
80105d98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105d9d:	89 c2                	mov    %eax,%edx
80105d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da2:	8b 40 04             	mov    0x4(%eax),%eax
80105da5:	83 ec 04             	sub    $0x4,%esp
80105da8:	51                   	push   %ecx
80105da9:	52                   	push   %edx
80105daa:	50                   	push   %eax
80105dab:	e8 9a 1c 00 00       	call   80107a4a <deallocuvm>
80105db0:	83 c4 10             	add    $0x10,%esp
80105db3:	85 c0                	test   %eax,%eax
80105db5:	75 07                	jne    80105dbe <sys_sbrk+0x9d>
      return -1;
80105db7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbc:	eb 3b                	jmp    80105df9 <sys_sbrk+0xd8>
    curproc -> sz = newsz;
80105dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105dc4:	89 10                	mov    %edx,(%eax)
    return addr;
80105dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc9:	eb 2e                	jmp    80105df9 <sys_sbrk+0xd8>
  }
  
  if (n > 0){ // sz+n이 커널 영역 넘어가면 안됨
80105dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dce:	85 c0                	test   %eax,%eax
80105dd0:	7e 15                	jle    80105de7 <sys_sbrk+0xc6>
    if (curproc ->sz + n >= KERNBASE) //lazy allocation -> 물리메모리 할당 안함함
80105dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd5:	8b 10                	mov    (%eax),%edx
80105dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dda:	01 d0                	add    %edx,%eax
80105ddc:	85 c0                	test   %eax,%eax
80105dde:	79 07                	jns    80105de7 <sys_sbrk+0xc6>
      return -1;
80105de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de5:	eb 12                	jmp    80105df9 <sys_sbrk+0xd8>
  }
  curproc ->sz +=n;
80105de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dea:	8b 10                	mov    (%eax),%edx
80105dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105def:	01 c2                	add    %eax,%edx
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	89 10                	mov    %edx,(%eax)
  return addr;
80105df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105df9:	c9                   	leave  
80105dfa:	c3                   	ret    

80105dfb <sys_sleep>:

int
sys_sleep(void)
{
80105dfb:	55                   	push   %ebp
80105dfc:	89 e5                	mov    %esp,%ebp
80105dfe:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e01:	83 ec 08             	sub    $0x8,%esp
80105e04:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e07:	50                   	push   %eax
80105e08:	6a 00                	push   $0x0
80105e0a:	e8 b9 ef ff ff       	call   80104dc8 <argint>
80105e0f:	83 c4 10             	add    $0x10,%esp
80105e12:	85 c0                	test   %eax,%eax
80105e14:	79 07                	jns    80105e1d <sys_sleep+0x22>
    return -1;
80105e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1b:	eb 76                	jmp    80105e93 <sys_sleep+0x98>
  acquire(&tickslock);
80105e1d:	83 ec 0c             	sub    $0xc,%esp
80105e20:	68 40 69 19 80       	push   $0x80196940
80105e25:	e8 19 ea ff ff       	call   80104843 <acquire>
80105e2a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105e2d:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105e35:	eb 38                	jmp    80105e6f <sys_sleep+0x74>
    if(myproc()->killed){
80105e37:	e8 ea db ff ff       	call   80103a26 <myproc>
80105e3c:	8b 40 24             	mov    0x24(%eax),%eax
80105e3f:	85 c0                	test   %eax,%eax
80105e41:	74 17                	je     80105e5a <sys_sleep+0x5f>
      release(&tickslock);
80105e43:	83 ec 0c             	sub    $0xc,%esp
80105e46:	68 40 69 19 80       	push   $0x80196940
80105e4b:	e8 61 ea ff ff       	call   801048b1 <release>
80105e50:	83 c4 10             	add    $0x10,%esp
      return -1;
80105e53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e58:	eb 39                	jmp    80105e93 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105e5a:	83 ec 08             	sub    $0x8,%esp
80105e5d:	68 40 69 19 80       	push   $0x80196940
80105e62:	68 74 69 19 80       	push   $0x80196974
80105e67:	e8 63 e4 ff ff       	call   801042cf <sleep>
80105e6c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105e6f:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e74:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105e77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e7a:	39 d0                	cmp    %edx,%eax
80105e7c:	72 b9                	jb     80105e37 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105e7e:	83 ec 0c             	sub    $0xc,%esp
80105e81:	68 40 69 19 80       	push   $0x80196940
80105e86:	e8 26 ea ff ff       	call   801048b1 <release>
80105e8b:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e93:	c9                   	leave  
80105e94:	c3                   	ret    

80105e95 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e95:	55                   	push   %ebp
80105e96:	89 e5                	mov    %esp,%ebp
80105e98:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e9b:	83 ec 0c             	sub    $0xc,%esp
80105e9e:	68 40 69 19 80       	push   $0x80196940
80105ea3:	e8 9b e9 ff ff       	call   80104843 <acquire>
80105ea8:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105eab:	a1 74 69 19 80       	mov    0x80196974,%eax
80105eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105eb3:	83 ec 0c             	sub    $0xc,%esp
80105eb6:	68 40 69 19 80       	push   $0x80196940
80105ebb:	e8 f1 e9 ff ff       	call   801048b1 <release>
80105ec0:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ec6:	c9                   	leave  
80105ec7:	c3                   	ret    

80105ec8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105ec8:	1e                   	push   %ds
  pushl %es
80105ec9:	06                   	push   %es
  pushl %fs
80105eca:	0f a0                	push   %fs
  pushl %gs
80105ecc:	0f a8                	push   %gs
  pushal
80105ece:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105ecf:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105ed3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105ed5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105ed7:	54                   	push   %esp
  call trap
80105ed8:	e8 e3 01 00 00       	call   801060c0 <trap>
  addl $4, %esp
80105edd:	83 c4 04             	add    $0x4,%esp

80105ee0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105ee0:	61                   	popa   
  popl %gs
80105ee1:	0f a9                	pop    %gs
  popl %fs
80105ee3:	0f a1                	pop    %fs
  popl %es
80105ee5:	07                   	pop    %es
  popl %ds
80105ee6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105ee7:	83 c4 08             	add    $0x8,%esp
  iret
80105eea:	cf                   	iret   

80105eeb <lidt>:
{
80105eeb:	55                   	push   %ebp
80105eec:	89 e5                	mov    %esp,%ebp
80105eee:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ef4:	83 e8 01             	sub    $0x1,%eax
80105ef7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105efb:	8b 45 08             	mov    0x8(%ebp),%eax
80105efe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105f02:	8b 45 08             	mov    0x8(%ebp),%eax
80105f05:	c1 e8 10             	shr    $0x10,%eax
80105f08:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105f0c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105f0f:	0f 01 18             	lidtl  (%eax)
}
80105f12:	90                   	nop
80105f13:	c9                   	leave  
80105f14:	c3                   	ret    

80105f15 <rcr2>:

static inline uint
rcr2(void)
{
80105f15:	55                   	push   %ebp
80105f16:	89 e5                	mov    %esp,%ebp
80105f18:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105f1b:	0f 20 d0             	mov    %cr2,%eax
80105f1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105f24:	c9                   	leave  
80105f25:	c3                   	ret    

80105f26 <lcr3>:

static inline void
lcr3(uint val)
{
80105f26:	55                   	push   %ebp
80105f27:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f29:	8b 45 08             	mov    0x8(%ebp),%eax
80105f2c:	0f 22 d8             	mov    %eax,%cr3
}
80105f2f:	90                   	nop
80105f30:	5d                   	pop    %ebp
80105f31:	c3                   	ret    

80105f32 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105f32:	55                   	push   %ebp
80105f33:	89 e5                	mov    %esp,%ebp
80105f35:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105f38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105f3f:	e9 c3 00 00 00       	jmp    80106007 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f47:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f4e:	89 c2                	mov    %eax,%edx
80105f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f53:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105f5a:	80 
80105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5e:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105f65:	80 08 00 
80105f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6b:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f72:	80 
80105f73:	83 e2 e0             	and    $0xffffffe0,%edx
80105f76:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f80:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f87:	80 
80105f88:	83 e2 1f             	and    $0x1f,%edx
80105f8b:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f95:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f9c:	80 
80105f9d:	83 e2 f0             	and    $0xfffffff0,%edx
80105fa0:	83 ca 0e             	or     $0xe,%edx
80105fa3:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fad:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105fb4:	80 
80105fb5:	83 e2 ef             	and    $0xffffffef,%edx
80105fb8:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc2:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105fc9:	80 
80105fca:	83 e2 9f             	and    $0xffffff9f,%edx
80105fcd:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd7:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105fde:	80 
80105fdf:	83 ca 80             	or     $0xffffff80,%edx
80105fe2:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fec:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105ff3:	c1 e8 10             	shr    $0x10,%eax
80105ff6:	89 c2                	mov    %eax,%edx
80105ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffb:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80106002:	80 
  for(i = 0; i < 256; i++)
80106003:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106007:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010600e:	0f 8e 30 ff ff ff    	jle    80105f44 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106014:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106019:	66 a3 40 63 19 80    	mov    %ax,0x80196340
8010601f:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80106026:	08 00 
80106028:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
8010602f:	83 e0 e0             	and    $0xffffffe0,%eax
80106032:	a2 44 63 19 80       	mov    %al,0x80196344
80106037:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
8010603e:	83 e0 1f             	and    $0x1f,%eax
80106041:	a2 44 63 19 80       	mov    %al,0x80196344
80106046:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
8010604d:	83 c8 0f             	or     $0xf,%eax
80106050:	a2 45 63 19 80       	mov    %al,0x80196345
80106055:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
8010605c:	83 e0 ef             	and    $0xffffffef,%eax
8010605f:	a2 45 63 19 80       	mov    %al,0x80196345
80106064:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
8010606b:	83 c8 60             	or     $0x60,%eax
8010606e:	a2 45 63 19 80       	mov    %al,0x80196345
80106073:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
8010607a:	83 c8 80             	or     $0xffffff80,%eax
8010607d:	a2 45 63 19 80       	mov    %al,0x80196345
80106082:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106087:	c1 e8 10             	shr    $0x10,%eax
8010608a:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
80106090:	83 ec 08             	sub    $0x8,%esp
80106093:	68 40 a7 10 80       	push   $0x8010a740
80106098:	68 40 69 19 80       	push   $0x80196940
8010609d:	e8 7f e7 ff ff       	call   80104821 <initlock>
801060a2:	83 c4 10             	add    $0x10,%esp
}
801060a5:	90                   	nop
801060a6:	c9                   	leave  
801060a7:	c3                   	ret    

801060a8 <idtinit>:

void
idtinit(void)
{
801060a8:	55                   	push   %ebp
801060a9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801060ab:	68 00 08 00 00       	push   $0x800
801060b0:	68 40 61 19 80       	push   $0x80196140
801060b5:	e8 31 fe ff ff       	call   80105eeb <lidt>
801060ba:	83 c4 08             	add    $0x8,%esp
}
801060bd:	90                   	nop
801060be:	c9                   	leave  
801060bf:	c3                   	ret    

801060c0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801060c0:	55                   	push   %ebp
801060c1:	89 e5                	mov    %esp,%ebp
801060c3:	57                   	push   %edi
801060c4:	56                   	push   %esi
801060c5:	53                   	push   %ebx
801060c6:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801060c9:	8b 45 08             	mov    0x8(%ebp),%eax
801060cc:	8b 40 30             	mov    0x30(%eax),%eax
801060cf:	83 f8 40             	cmp    $0x40,%eax
801060d2:	75 3b                	jne    8010610f <trap+0x4f>
    if(myproc()->killed)
801060d4:	e8 4d d9 ff ff       	call   80103a26 <myproc>
801060d9:	8b 40 24             	mov    0x24(%eax),%eax
801060dc:	85 c0                	test   %eax,%eax
801060de:	74 05                	je     801060e5 <trap+0x25>
      exit();
801060e0:	e8 b9 dd ff ff       	call   80103e9e <exit>
    myproc()->tf = tf;
801060e5:	e8 3c d9 ff ff       	call   80103a26 <myproc>
801060ea:	8b 55 08             	mov    0x8(%ebp),%edx
801060ed:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801060f0:	e8 90 ed ff ff       	call   80104e85 <syscall>
    if(myproc()->killed)
801060f5:	e8 2c d9 ff ff       	call   80103a26 <myproc>
801060fa:	8b 40 24             	mov    0x24(%eax),%eax
801060fd:	85 c0                	test   %eax,%eax
801060ff:	0f 84 1d 03 00 00    	je     80106422 <trap+0x362>
      exit();
80106105:	e8 94 dd ff ff       	call   80103e9e <exit>
    return;
8010610a:	e9 13 03 00 00       	jmp    80106422 <trap+0x362>
  }

  switch(tf->trapno){
8010610f:	8b 45 08             	mov    0x8(%ebp),%eax
80106112:	8b 40 30             	mov    0x30(%eax),%eax
80106115:	83 e8 0e             	sub    $0xe,%eax
80106118:	83 f8 31             	cmp    $0x31,%eax
8010611b:	0f 87 c9 01 00 00    	ja     801062ea <trap+0x22a>
80106121:	8b 04 85 00 a8 10 80 	mov    -0x7fef5800(,%eax,4),%eax
80106128:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010612a:	e8 64 d8 ff ff       	call   80103993 <cpuid>
8010612f:	85 c0                	test   %eax,%eax
80106131:	75 3d                	jne    80106170 <trap+0xb0>
      acquire(&tickslock);
80106133:	83 ec 0c             	sub    $0xc,%esp
80106136:	68 40 69 19 80       	push   $0x80196940
8010613b:	e8 03 e7 ff ff       	call   80104843 <acquire>
80106140:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106143:	a1 74 69 19 80       	mov    0x80196974,%eax
80106148:	83 c0 01             	add    $0x1,%eax
8010614b:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
80106150:	83 ec 0c             	sub    $0xc,%esp
80106153:	68 74 69 19 80       	push   $0x80196974
80106158:	e8 59 e2 ff ff       	call   801043b6 <wakeup>
8010615d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	68 40 69 19 80       	push   $0x80196940
80106168:	e8 44 e7 ff ff       	call   801048b1 <release>
8010616d:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106170:	e8 9d c9 ff ff       	call   80102b12 <lapiceoi>
    break;
80106175:	e9 28 02 00 00       	jmp    801063a2 <trap+0x2e2>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010617a:	e8 18 40 00 00       	call   8010a197 <ideintr>
    lapiceoi();
8010617f:	e8 8e c9 ff ff       	call   80102b12 <lapiceoi>
    break;
80106184:	e9 19 02 00 00       	jmp    801063a2 <trap+0x2e2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106189:	e8 c9 c7 ff ff       	call   80102957 <kbdintr>
    lapiceoi();
8010618e:	e8 7f c9 ff ff       	call   80102b12 <lapiceoi>
    break;
80106193:	e9 0a 02 00 00       	jmp    801063a2 <trap+0x2e2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106198:	e8 5b 04 00 00       	call   801065f8 <uartintr>
    lapiceoi();
8010619d:	e8 70 c9 ff ff       	call   80102b12 <lapiceoi>
    break;
801061a2:	e9 fb 01 00 00       	jmp    801063a2 <trap+0x2e2>
  case T_IRQ0 + 0xB:
    i8254_intr();
801061a7:	e8 9e 2c 00 00       	call   80108e4a <i8254_intr>
    lapiceoi();
801061ac:	e8 61 c9 ff ff       	call   80102b12 <lapiceoi>
    break;
801061b1:	e9 ec 01 00 00       	jmp    801063a2 <trap+0x2e2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801061b6:	8b 45 08             	mov    0x8(%ebp),%eax
801061b9:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801061bc:	8b 45 08             	mov    0x8(%ebp),%eax
801061bf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801061c3:	0f b7 d8             	movzwl %ax,%ebx
801061c6:	e8 c8 d7 ff ff       	call   80103993 <cpuid>
801061cb:	56                   	push   %esi
801061cc:	53                   	push   %ebx
801061cd:	50                   	push   %eax
801061ce:	68 48 a7 10 80       	push   $0x8010a748
801061d3:	e8 1c a2 ff ff       	call   801003f4 <cprintf>
801061d8:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801061db:	e8 32 c9 ff ff       	call   80102b12 <lapiceoi>
    break;
801061e0:	e9 bd 01 00 00       	jmp    801063a2 <trap+0x2e2>
  
  case T_PGFLT: {
    uint fault_addr = PGROUNDDOWN(rcr2());
801061e5:	e8 2b fd ff ff       	call   80105f15 <rcr2>
801061ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801061ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *p = myproc();
801061f2:	e8 2f d8 ff ff       	call   80103a26 <myproc>
801061f7:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // 커널 영역 접근 시 kill
    if ( fault_addr >= KERNBASE) {
801061fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061fd:	85 c0                	test   %eax,%eax
801061ff:	79 22                	jns    80106223 <trap+0x163>
      cprintf("Invalid access at %x\n", fault_addr);
80106201:	83 ec 08             	sub    $0x8,%esp
80106204:	ff 75 e4             	push   -0x1c(%ebp)
80106207:	68 6c a7 10 80       	push   $0x8010a76c
8010620c:	e8 e3 a1 ff ff       	call   801003f4 <cprintf>
80106211:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
80106214:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106217:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
8010621e:	e9 7f 01 00 00       	jmp    801063a2 <trap+0x2e2>
    }
    // 페이지가 이미 매핑되어 있으면 무시
    pte_t *pte = walkpgdir(p->pgdir, (void *)fault_addr, 0);
80106223:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106226:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106229:	8b 40 04             	mov    0x4(%eax),%eax
8010622c:	83 ec 04             	sub    $0x4,%esp
8010622f:	6a 00                	push   $0x0
80106231:	52                   	push   %edx
80106232:	50                   	push   %eax
80106233:	e8 ee 11 00 00       	call   80107426 <walkpgdir>
80106238:	83 c4 10             	add    $0x10,%esp
8010623b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pte && (*pte & PTE_P))
8010623e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106242:	74 10                	je     80106254 <trap+0x194>
80106244:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106247:	8b 00                	mov    (%eax),%eax
80106249:	83 e0 01             	and    $0x1,%eax
8010624c:	85 c0                	test   %eax,%eax
8010624e:	0f 85 4d 01 00 00    	jne    801063a1 <trap+0x2e1>
      break;

    // 새 물리 메모리 할당
    char *mem = kalloc();
80106254:	e8 3d c5 ff ff       	call   80102796 <kalloc>
80106259:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!mem) {
8010625c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80106260:	75 0f                	jne    80106271 <trap+0x1b1>
      p->killed = 1;
80106262:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106265:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
8010626c:	e9 31 01 00 00       	jmp    801063a2 <trap+0x2e2>
    }

    memset(mem, 0, PGSIZE);
80106271:	83 ec 04             	sub    $0x4,%esp
80106274:	68 00 10 00 00       	push   $0x1000
80106279:	6a 00                	push   $0x0
8010627b:	ff 75 d8             	push   -0x28(%ebp)
8010627e:	e8 36 e8 ff ff       	call   80104ab9 <memset>
80106283:	83 c4 10             	add    $0x10,%esp

    // 페이지 매핑
    if (mappages(p->pgdir, (void *)fault_addr, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
80106286:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106289:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010628f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106292:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106295:	8b 40 04             	mov    0x4(%eax),%eax
80106298:	83 ec 0c             	sub    $0xc,%esp
8010629b:	6a 06                	push   $0x6
8010629d:	51                   	push   %ecx
8010629e:	68 00 10 00 00       	push   $0x1000
801062a3:	52                   	push   %edx
801062a4:	50                   	push   %eax
801062a5:	e8 12 12 00 00       	call   801074bc <mappages>
801062aa:	83 c4 20             	add    $0x20,%esp
801062ad:	85 c0                	test   %eax,%eax
801062af:	79 1d                	jns    801062ce <trap+0x20e>
      kfree(mem);  // 실패했으면 할당 회수
801062b1:	83 ec 0c             	sub    $0xc,%esp
801062b4:	ff 75 d8             	push   -0x28(%ebp)
801062b7:	e8 40 c4 ff ff       	call   801026fc <kfree>
801062bc:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
801062bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801062c2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
801062c9:	e9 d4 00 00 00       	jmp    801063a2 <trap+0x2e2>
    }

    // TLB 플러싱
    lcr3(V2P(p->pgdir));
801062ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801062d1:	8b 40 04             	mov    0x4(%eax),%eax
801062d4:	05 00 00 00 80       	add    $0x80000000,%eax
801062d9:	83 ec 0c             	sub    $0xc,%esp
801062dc:	50                   	push   %eax
801062dd:	e8 44 fc ff ff       	call   80105f26 <lcr3>
801062e2:	83 c4 10             	add    $0x10,%esp
    break;
801062e5:	e9 b8 00 00 00       	jmp    801063a2 <trap+0x2e2>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801062ea:	e8 37 d7 ff ff       	call   80103a26 <myproc>
801062ef:	85 c0                	test   %eax,%eax
801062f1:	74 11                	je     80106304 <trap+0x244>
801062f3:	8b 45 08             	mov    0x8(%ebp),%eax
801062f6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062fa:	0f b7 c0             	movzwl %ax,%eax
801062fd:	83 e0 03             	and    $0x3,%eax
80106300:	85 c0                	test   %eax,%eax
80106302:	75 39                	jne    8010633d <trap+0x27d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106304:	e8 0c fc ff ff       	call   80105f15 <rcr2>
80106309:	89 c3                	mov    %eax,%ebx
8010630b:	8b 45 08             	mov    0x8(%ebp),%eax
8010630e:	8b 70 38             	mov    0x38(%eax),%esi
80106311:	e8 7d d6 ff ff       	call   80103993 <cpuid>
80106316:	8b 55 08             	mov    0x8(%ebp),%edx
80106319:	8b 52 30             	mov    0x30(%edx),%edx
8010631c:	83 ec 0c             	sub    $0xc,%esp
8010631f:	53                   	push   %ebx
80106320:	56                   	push   %esi
80106321:	50                   	push   %eax
80106322:	52                   	push   %edx
80106323:	68 84 a7 10 80       	push   $0x8010a784
80106328:	e8 c7 a0 ff ff       	call   801003f4 <cprintf>
8010632d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106330:	83 ec 0c             	sub    $0xc,%esp
80106333:	68 b6 a7 10 80       	push   $0x8010a7b6
80106338:	e8 6c a2 ff ff       	call   801005a9 <panic>
    }

    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010633d:	e8 d3 fb ff ff       	call   80105f15 <rcr2>
80106342:	89 c6                	mov    %eax,%esi
80106344:	8b 45 08             	mov    0x8(%ebp),%eax
80106347:	8b 40 38             	mov    0x38(%eax),%eax
8010634a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010634d:	e8 41 d6 ff ff       	call   80103993 <cpuid>
80106352:	89 c3                	mov    %eax,%ebx
80106354:	8b 45 08             	mov    0x8(%ebp),%eax
80106357:	8b 48 34             	mov    0x34(%eax),%ecx
8010635a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010635d:	8b 45 08             	mov    0x8(%ebp),%eax
80106360:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106363:	e8 be d6 ff ff       	call   80103a26 <myproc>
80106368:	8d 50 6c             	lea    0x6c(%eax),%edx
8010636b:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010636e:	e8 b3 d6 ff ff       	call   80103a26 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106373:	8b 40 10             	mov    0x10(%eax),%eax
80106376:	56                   	push   %esi
80106377:	ff 75 d4             	push   -0x2c(%ebp)
8010637a:	53                   	push   %ebx
8010637b:	ff 75 d0             	push   -0x30(%ebp)
8010637e:	57                   	push   %edi
8010637f:	ff 75 cc             	push   -0x34(%ebp)
80106382:	50                   	push   %eax
80106383:	68 bc a7 10 80       	push   $0x8010a7bc
80106388:	e8 67 a0 ff ff       	call   801003f4 <cprintf>
8010638d:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106390:	e8 91 d6 ff ff       	call   80103a26 <myproc>
80106395:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010639c:	eb 04                	jmp    801063a2 <trap+0x2e2>
    break;
8010639e:	90                   	nop
8010639f:	eb 01                	jmp    801063a2 <trap+0x2e2>
      break;
801063a1:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063a2:	e8 7f d6 ff ff       	call   80103a26 <myproc>
801063a7:	85 c0                	test   %eax,%eax
801063a9:	74 23                	je     801063ce <trap+0x30e>
801063ab:	e8 76 d6 ff ff       	call   80103a26 <myproc>
801063b0:	8b 40 24             	mov    0x24(%eax),%eax
801063b3:	85 c0                	test   %eax,%eax
801063b5:	74 17                	je     801063ce <trap+0x30e>
801063b7:	8b 45 08             	mov    0x8(%ebp),%eax
801063ba:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063be:	0f b7 c0             	movzwl %ax,%eax
801063c1:	83 e0 03             	and    $0x3,%eax
801063c4:	83 f8 03             	cmp    $0x3,%eax
801063c7:	75 05                	jne    801063ce <trap+0x30e>
    exit();
801063c9:	e8 d0 da ff ff       	call   80103e9e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801063ce:	e8 53 d6 ff ff       	call   80103a26 <myproc>
801063d3:	85 c0                	test   %eax,%eax
801063d5:	74 1d                	je     801063f4 <trap+0x334>
801063d7:	e8 4a d6 ff ff       	call   80103a26 <myproc>
801063dc:	8b 40 0c             	mov    0xc(%eax),%eax
801063df:	83 f8 04             	cmp    $0x4,%eax
801063e2:	75 10                	jne    801063f4 <trap+0x334>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801063e4:	8b 45 08             	mov    0x8(%ebp),%eax
801063e7:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801063ea:	83 f8 20             	cmp    $0x20,%eax
801063ed:	75 05                	jne    801063f4 <trap+0x334>
    yield();
801063ef:	e8 5b de ff ff       	call   8010424f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063f4:	e8 2d d6 ff ff       	call   80103a26 <myproc>
801063f9:	85 c0                	test   %eax,%eax
801063fb:	74 26                	je     80106423 <trap+0x363>
801063fd:	e8 24 d6 ff ff       	call   80103a26 <myproc>
80106402:	8b 40 24             	mov    0x24(%eax),%eax
80106405:	85 c0                	test   %eax,%eax
80106407:	74 1a                	je     80106423 <trap+0x363>
80106409:	8b 45 08             	mov    0x8(%ebp),%eax
8010640c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106410:	0f b7 c0             	movzwl %ax,%eax
80106413:	83 e0 03             	and    $0x3,%eax
80106416:	83 f8 03             	cmp    $0x3,%eax
80106419:	75 08                	jne    80106423 <trap+0x363>
    exit();
8010641b:	e8 7e da ff ff       	call   80103e9e <exit>
80106420:	eb 01                	jmp    80106423 <trap+0x363>
    return;
80106422:	90                   	nop
}
80106423:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106426:	5b                   	pop    %ebx
80106427:	5e                   	pop    %esi
80106428:	5f                   	pop    %edi
80106429:	5d                   	pop    %ebp
8010642a:	c3                   	ret    

8010642b <inb>:
{
8010642b:	55                   	push   %ebp
8010642c:	89 e5                	mov    %esp,%ebp
8010642e:	83 ec 14             	sub    $0x14,%esp
80106431:	8b 45 08             	mov    0x8(%ebp),%eax
80106434:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106438:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010643c:	89 c2                	mov    %eax,%edx
8010643e:	ec                   	in     (%dx),%al
8010643f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106442:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106446:	c9                   	leave  
80106447:	c3                   	ret    

80106448 <outb>:
{
80106448:	55                   	push   %ebp
80106449:	89 e5                	mov    %esp,%ebp
8010644b:	83 ec 08             	sub    $0x8,%esp
8010644e:	8b 45 08             	mov    0x8(%ebp),%eax
80106451:	8b 55 0c             	mov    0xc(%ebp),%edx
80106454:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106458:	89 d0                	mov    %edx,%eax
8010645a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010645d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106461:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106465:	ee                   	out    %al,(%dx)
}
80106466:	90                   	nop
80106467:	c9                   	leave  
80106468:	c3                   	ret    

80106469 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106469:	55                   	push   %ebp
8010646a:	89 e5                	mov    %esp,%ebp
8010646c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010646f:	6a 00                	push   $0x0
80106471:	68 fa 03 00 00       	push   $0x3fa
80106476:	e8 cd ff ff ff       	call   80106448 <outb>
8010647b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010647e:	68 80 00 00 00       	push   $0x80
80106483:	68 fb 03 00 00       	push   $0x3fb
80106488:	e8 bb ff ff ff       	call   80106448 <outb>
8010648d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106490:	6a 0c                	push   $0xc
80106492:	68 f8 03 00 00       	push   $0x3f8
80106497:	e8 ac ff ff ff       	call   80106448 <outb>
8010649c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010649f:	6a 00                	push   $0x0
801064a1:	68 f9 03 00 00       	push   $0x3f9
801064a6:	e8 9d ff ff ff       	call   80106448 <outb>
801064ab:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801064ae:	6a 03                	push   $0x3
801064b0:	68 fb 03 00 00       	push   $0x3fb
801064b5:	e8 8e ff ff ff       	call   80106448 <outb>
801064ba:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801064bd:	6a 00                	push   $0x0
801064bf:	68 fc 03 00 00       	push   $0x3fc
801064c4:	e8 7f ff ff ff       	call   80106448 <outb>
801064c9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801064cc:	6a 01                	push   $0x1
801064ce:	68 f9 03 00 00       	push   $0x3f9
801064d3:	e8 70 ff ff ff       	call   80106448 <outb>
801064d8:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801064db:	68 fd 03 00 00       	push   $0x3fd
801064e0:	e8 46 ff ff ff       	call   8010642b <inb>
801064e5:	83 c4 04             	add    $0x4,%esp
801064e8:	3c ff                	cmp    $0xff,%al
801064ea:	74 61                	je     8010654d <uartinit+0xe4>
    return;
  uart = 1;
801064ec:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
801064f3:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801064f6:	68 fa 03 00 00       	push   $0x3fa
801064fb:	e8 2b ff ff ff       	call   8010642b <inb>
80106500:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106503:	68 f8 03 00 00       	push   $0x3f8
80106508:	e8 1e ff ff ff       	call   8010642b <inb>
8010650d:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106510:	83 ec 08             	sub    $0x8,%esp
80106513:	6a 00                	push   $0x0
80106515:	6a 04                	push   $0x4
80106517:	e8 08 c1 ff ff       	call   80102624 <ioapicenable>
8010651c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010651f:	c7 45 f4 c8 a8 10 80 	movl   $0x8010a8c8,-0xc(%ebp)
80106526:	eb 19                	jmp    80106541 <uartinit+0xd8>
    uartputc(*p);
80106528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652b:	0f b6 00             	movzbl (%eax),%eax
8010652e:	0f be c0             	movsbl %al,%eax
80106531:	83 ec 0c             	sub    $0xc,%esp
80106534:	50                   	push   %eax
80106535:	e8 16 00 00 00       	call   80106550 <uartputc>
8010653a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010653d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106544:	0f b6 00             	movzbl (%eax),%eax
80106547:	84 c0                	test   %al,%al
80106549:	75 dd                	jne    80106528 <uartinit+0xbf>
8010654b:	eb 01                	jmp    8010654e <uartinit+0xe5>
    return;
8010654d:	90                   	nop
}
8010654e:	c9                   	leave  
8010654f:	c3                   	ret    

80106550 <uartputc>:

void
uartputc(int c)
{
80106550:	55                   	push   %ebp
80106551:	89 e5                	mov    %esp,%ebp
80106553:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106556:	a1 78 69 19 80       	mov    0x80196978,%eax
8010655b:	85 c0                	test   %eax,%eax
8010655d:	74 53                	je     801065b2 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010655f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106566:	eb 11                	jmp    80106579 <uartputc+0x29>
    microdelay(10);
80106568:	83 ec 0c             	sub    $0xc,%esp
8010656b:	6a 0a                	push   $0xa
8010656d:	e8 bb c5 ff ff       	call   80102b2d <microdelay>
80106572:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106579:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010657d:	7f 1a                	jg     80106599 <uartputc+0x49>
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	68 fd 03 00 00       	push   $0x3fd
80106587:	e8 9f fe ff ff       	call   8010642b <inb>
8010658c:	83 c4 10             	add    $0x10,%esp
8010658f:	0f b6 c0             	movzbl %al,%eax
80106592:	83 e0 20             	and    $0x20,%eax
80106595:	85 c0                	test   %eax,%eax
80106597:	74 cf                	je     80106568 <uartputc+0x18>
  outb(COM1+0, c);
80106599:	8b 45 08             	mov    0x8(%ebp),%eax
8010659c:	0f b6 c0             	movzbl %al,%eax
8010659f:	83 ec 08             	sub    $0x8,%esp
801065a2:	50                   	push   %eax
801065a3:	68 f8 03 00 00       	push   $0x3f8
801065a8:	e8 9b fe ff ff       	call   80106448 <outb>
801065ad:	83 c4 10             	add    $0x10,%esp
801065b0:	eb 01                	jmp    801065b3 <uartputc+0x63>
    return;
801065b2:	90                   	nop
}
801065b3:	c9                   	leave  
801065b4:	c3                   	ret    

801065b5 <uartgetc>:

static int
uartgetc(void)
{
801065b5:	55                   	push   %ebp
801065b6:	89 e5                	mov    %esp,%ebp
  if(!uart)
801065b8:	a1 78 69 19 80       	mov    0x80196978,%eax
801065bd:	85 c0                	test   %eax,%eax
801065bf:	75 07                	jne    801065c8 <uartgetc+0x13>
    return -1;
801065c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c6:	eb 2e                	jmp    801065f6 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801065c8:	68 fd 03 00 00       	push   $0x3fd
801065cd:	e8 59 fe ff ff       	call   8010642b <inb>
801065d2:	83 c4 04             	add    $0x4,%esp
801065d5:	0f b6 c0             	movzbl %al,%eax
801065d8:	83 e0 01             	and    $0x1,%eax
801065db:	85 c0                	test   %eax,%eax
801065dd:	75 07                	jne    801065e6 <uartgetc+0x31>
    return -1;
801065df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e4:	eb 10                	jmp    801065f6 <uartgetc+0x41>
  return inb(COM1+0);
801065e6:	68 f8 03 00 00       	push   $0x3f8
801065eb:	e8 3b fe ff ff       	call   8010642b <inb>
801065f0:	83 c4 04             	add    $0x4,%esp
801065f3:	0f b6 c0             	movzbl %al,%eax
}
801065f6:	c9                   	leave  
801065f7:	c3                   	ret    

801065f8 <uartintr>:

void
uartintr(void)
{
801065f8:	55                   	push   %ebp
801065f9:	89 e5                	mov    %esp,%ebp
801065fb:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801065fe:	83 ec 0c             	sub    $0xc,%esp
80106601:	68 b5 65 10 80       	push   $0x801065b5
80106606:	e8 cb a1 ff ff       	call   801007d6 <consoleintr>
8010660b:	83 c4 10             	add    $0x10,%esp
}
8010660e:	90                   	nop
8010660f:	c9                   	leave  
80106610:	c3                   	ret    

80106611 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106611:	6a 00                	push   $0x0
  pushl $0
80106613:	6a 00                	push   $0x0
  jmp alltraps
80106615:	e9 ae f8 ff ff       	jmp    80105ec8 <alltraps>

8010661a <vector1>:
.globl vector1
vector1:
  pushl $0
8010661a:	6a 00                	push   $0x0
  pushl $1
8010661c:	6a 01                	push   $0x1
  jmp alltraps
8010661e:	e9 a5 f8 ff ff       	jmp    80105ec8 <alltraps>

80106623 <vector2>:
.globl vector2
vector2:
  pushl $0
80106623:	6a 00                	push   $0x0
  pushl $2
80106625:	6a 02                	push   $0x2
  jmp alltraps
80106627:	e9 9c f8 ff ff       	jmp    80105ec8 <alltraps>

8010662c <vector3>:
.globl vector3
vector3:
  pushl $0
8010662c:	6a 00                	push   $0x0
  pushl $3
8010662e:	6a 03                	push   $0x3
  jmp alltraps
80106630:	e9 93 f8 ff ff       	jmp    80105ec8 <alltraps>

80106635 <vector4>:
.globl vector4
vector4:
  pushl $0
80106635:	6a 00                	push   $0x0
  pushl $4
80106637:	6a 04                	push   $0x4
  jmp alltraps
80106639:	e9 8a f8 ff ff       	jmp    80105ec8 <alltraps>

8010663e <vector5>:
.globl vector5
vector5:
  pushl $0
8010663e:	6a 00                	push   $0x0
  pushl $5
80106640:	6a 05                	push   $0x5
  jmp alltraps
80106642:	e9 81 f8 ff ff       	jmp    80105ec8 <alltraps>

80106647 <vector6>:
.globl vector6
vector6:
  pushl $0
80106647:	6a 00                	push   $0x0
  pushl $6
80106649:	6a 06                	push   $0x6
  jmp alltraps
8010664b:	e9 78 f8 ff ff       	jmp    80105ec8 <alltraps>

80106650 <vector7>:
.globl vector7
vector7:
  pushl $0
80106650:	6a 00                	push   $0x0
  pushl $7
80106652:	6a 07                	push   $0x7
  jmp alltraps
80106654:	e9 6f f8 ff ff       	jmp    80105ec8 <alltraps>

80106659 <vector8>:
.globl vector8
vector8:
  pushl $8
80106659:	6a 08                	push   $0x8
  jmp alltraps
8010665b:	e9 68 f8 ff ff       	jmp    80105ec8 <alltraps>

80106660 <vector9>:
.globl vector9
vector9:
  pushl $0
80106660:	6a 00                	push   $0x0
  pushl $9
80106662:	6a 09                	push   $0x9
  jmp alltraps
80106664:	e9 5f f8 ff ff       	jmp    80105ec8 <alltraps>

80106669 <vector10>:
.globl vector10
vector10:
  pushl $10
80106669:	6a 0a                	push   $0xa
  jmp alltraps
8010666b:	e9 58 f8 ff ff       	jmp    80105ec8 <alltraps>

80106670 <vector11>:
.globl vector11
vector11:
  pushl $11
80106670:	6a 0b                	push   $0xb
  jmp alltraps
80106672:	e9 51 f8 ff ff       	jmp    80105ec8 <alltraps>

80106677 <vector12>:
.globl vector12
vector12:
  pushl $12
80106677:	6a 0c                	push   $0xc
  jmp alltraps
80106679:	e9 4a f8 ff ff       	jmp    80105ec8 <alltraps>

8010667e <vector13>:
.globl vector13
vector13:
  pushl $13
8010667e:	6a 0d                	push   $0xd
  jmp alltraps
80106680:	e9 43 f8 ff ff       	jmp    80105ec8 <alltraps>

80106685 <vector14>:
.globl vector14
vector14:
  pushl $14
80106685:	6a 0e                	push   $0xe
  jmp alltraps
80106687:	e9 3c f8 ff ff       	jmp    80105ec8 <alltraps>

8010668c <vector15>:
.globl vector15
vector15:
  pushl $0
8010668c:	6a 00                	push   $0x0
  pushl $15
8010668e:	6a 0f                	push   $0xf
  jmp alltraps
80106690:	e9 33 f8 ff ff       	jmp    80105ec8 <alltraps>

80106695 <vector16>:
.globl vector16
vector16:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $16
80106697:	6a 10                	push   $0x10
  jmp alltraps
80106699:	e9 2a f8 ff ff       	jmp    80105ec8 <alltraps>

8010669e <vector17>:
.globl vector17
vector17:
  pushl $17
8010669e:	6a 11                	push   $0x11
  jmp alltraps
801066a0:	e9 23 f8 ff ff       	jmp    80105ec8 <alltraps>

801066a5 <vector18>:
.globl vector18
vector18:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $18
801066a7:	6a 12                	push   $0x12
  jmp alltraps
801066a9:	e9 1a f8 ff ff       	jmp    80105ec8 <alltraps>

801066ae <vector19>:
.globl vector19
vector19:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $19
801066b0:	6a 13                	push   $0x13
  jmp alltraps
801066b2:	e9 11 f8 ff ff       	jmp    80105ec8 <alltraps>

801066b7 <vector20>:
.globl vector20
vector20:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $20
801066b9:	6a 14                	push   $0x14
  jmp alltraps
801066bb:	e9 08 f8 ff ff       	jmp    80105ec8 <alltraps>

801066c0 <vector21>:
.globl vector21
vector21:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $21
801066c2:	6a 15                	push   $0x15
  jmp alltraps
801066c4:	e9 ff f7 ff ff       	jmp    80105ec8 <alltraps>

801066c9 <vector22>:
.globl vector22
vector22:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $22
801066cb:	6a 16                	push   $0x16
  jmp alltraps
801066cd:	e9 f6 f7 ff ff       	jmp    80105ec8 <alltraps>

801066d2 <vector23>:
.globl vector23
vector23:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $23
801066d4:	6a 17                	push   $0x17
  jmp alltraps
801066d6:	e9 ed f7 ff ff       	jmp    80105ec8 <alltraps>

801066db <vector24>:
.globl vector24
vector24:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $24
801066dd:	6a 18                	push   $0x18
  jmp alltraps
801066df:	e9 e4 f7 ff ff       	jmp    80105ec8 <alltraps>

801066e4 <vector25>:
.globl vector25
vector25:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $25
801066e6:	6a 19                	push   $0x19
  jmp alltraps
801066e8:	e9 db f7 ff ff       	jmp    80105ec8 <alltraps>

801066ed <vector26>:
.globl vector26
vector26:
  pushl $0
801066ed:	6a 00                	push   $0x0
  pushl $26
801066ef:	6a 1a                	push   $0x1a
  jmp alltraps
801066f1:	e9 d2 f7 ff ff       	jmp    80105ec8 <alltraps>

801066f6 <vector27>:
.globl vector27
vector27:
  pushl $0
801066f6:	6a 00                	push   $0x0
  pushl $27
801066f8:	6a 1b                	push   $0x1b
  jmp alltraps
801066fa:	e9 c9 f7 ff ff       	jmp    80105ec8 <alltraps>

801066ff <vector28>:
.globl vector28
vector28:
  pushl $0
801066ff:	6a 00                	push   $0x0
  pushl $28
80106701:	6a 1c                	push   $0x1c
  jmp alltraps
80106703:	e9 c0 f7 ff ff       	jmp    80105ec8 <alltraps>

80106708 <vector29>:
.globl vector29
vector29:
  pushl $0
80106708:	6a 00                	push   $0x0
  pushl $29
8010670a:	6a 1d                	push   $0x1d
  jmp alltraps
8010670c:	e9 b7 f7 ff ff       	jmp    80105ec8 <alltraps>

80106711 <vector30>:
.globl vector30
vector30:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $30
80106713:	6a 1e                	push   $0x1e
  jmp alltraps
80106715:	e9 ae f7 ff ff       	jmp    80105ec8 <alltraps>

8010671a <vector31>:
.globl vector31
vector31:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $31
8010671c:	6a 1f                	push   $0x1f
  jmp alltraps
8010671e:	e9 a5 f7 ff ff       	jmp    80105ec8 <alltraps>

80106723 <vector32>:
.globl vector32
vector32:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $32
80106725:	6a 20                	push   $0x20
  jmp alltraps
80106727:	e9 9c f7 ff ff       	jmp    80105ec8 <alltraps>

8010672c <vector33>:
.globl vector33
vector33:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $33
8010672e:	6a 21                	push   $0x21
  jmp alltraps
80106730:	e9 93 f7 ff ff       	jmp    80105ec8 <alltraps>

80106735 <vector34>:
.globl vector34
vector34:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $34
80106737:	6a 22                	push   $0x22
  jmp alltraps
80106739:	e9 8a f7 ff ff       	jmp    80105ec8 <alltraps>

8010673e <vector35>:
.globl vector35
vector35:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $35
80106740:	6a 23                	push   $0x23
  jmp alltraps
80106742:	e9 81 f7 ff ff       	jmp    80105ec8 <alltraps>

80106747 <vector36>:
.globl vector36
vector36:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $36
80106749:	6a 24                	push   $0x24
  jmp alltraps
8010674b:	e9 78 f7 ff ff       	jmp    80105ec8 <alltraps>

80106750 <vector37>:
.globl vector37
vector37:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $37
80106752:	6a 25                	push   $0x25
  jmp alltraps
80106754:	e9 6f f7 ff ff       	jmp    80105ec8 <alltraps>

80106759 <vector38>:
.globl vector38
vector38:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $38
8010675b:	6a 26                	push   $0x26
  jmp alltraps
8010675d:	e9 66 f7 ff ff       	jmp    80105ec8 <alltraps>

80106762 <vector39>:
.globl vector39
vector39:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $39
80106764:	6a 27                	push   $0x27
  jmp alltraps
80106766:	e9 5d f7 ff ff       	jmp    80105ec8 <alltraps>

8010676b <vector40>:
.globl vector40
vector40:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $40
8010676d:	6a 28                	push   $0x28
  jmp alltraps
8010676f:	e9 54 f7 ff ff       	jmp    80105ec8 <alltraps>

80106774 <vector41>:
.globl vector41
vector41:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $41
80106776:	6a 29                	push   $0x29
  jmp alltraps
80106778:	e9 4b f7 ff ff       	jmp    80105ec8 <alltraps>

8010677d <vector42>:
.globl vector42
vector42:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $42
8010677f:	6a 2a                	push   $0x2a
  jmp alltraps
80106781:	e9 42 f7 ff ff       	jmp    80105ec8 <alltraps>

80106786 <vector43>:
.globl vector43
vector43:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $43
80106788:	6a 2b                	push   $0x2b
  jmp alltraps
8010678a:	e9 39 f7 ff ff       	jmp    80105ec8 <alltraps>

8010678f <vector44>:
.globl vector44
vector44:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $44
80106791:	6a 2c                	push   $0x2c
  jmp alltraps
80106793:	e9 30 f7 ff ff       	jmp    80105ec8 <alltraps>

80106798 <vector45>:
.globl vector45
vector45:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $45
8010679a:	6a 2d                	push   $0x2d
  jmp alltraps
8010679c:	e9 27 f7 ff ff       	jmp    80105ec8 <alltraps>

801067a1 <vector46>:
.globl vector46
vector46:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $46
801067a3:	6a 2e                	push   $0x2e
  jmp alltraps
801067a5:	e9 1e f7 ff ff       	jmp    80105ec8 <alltraps>

801067aa <vector47>:
.globl vector47
vector47:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $47
801067ac:	6a 2f                	push   $0x2f
  jmp alltraps
801067ae:	e9 15 f7 ff ff       	jmp    80105ec8 <alltraps>

801067b3 <vector48>:
.globl vector48
vector48:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $48
801067b5:	6a 30                	push   $0x30
  jmp alltraps
801067b7:	e9 0c f7 ff ff       	jmp    80105ec8 <alltraps>

801067bc <vector49>:
.globl vector49
vector49:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $49
801067be:	6a 31                	push   $0x31
  jmp alltraps
801067c0:	e9 03 f7 ff ff       	jmp    80105ec8 <alltraps>

801067c5 <vector50>:
.globl vector50
vector50:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $50
801067c7:	6a 32                	push   $0x32
  jmp alltraps
801067c9:	e9 fa f6 ff ff       	jmp    80105ec8 <alltraps>

801067ce <vector51>:
.globl vector51
vector51:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $51
801067d0:	6a 33                	push   $0x33
  jmp alltraps
801067d2:	e9 f1 f6 ff ff       	jmp    80105ec8 <alltraps>

801067d7 <vector52>:
.globl vector52
vector52:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $52
801067d9:	6a 34                	push   $0x34
  jmp alltraps
801067db:	e9 e8 f6 ff ff       	jmp    80105ec8 <alltraps>

801067e0 <vector53>:
.globl vector53
vector53:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $53
801067e2:	6a 35                	push   $0x35
  jmp alltraps
801067e4:	e9 df f6 ff ff       	jmp    80105ec8 <alltraps>

801067e9 <vector54>:
.globl vector54
vector54:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $54
801067eb:	6a 36                	push   $0x36
  jmp alltraps
801067ed:	e9 d6 f6 ff ff       	jmp    80105ec8 <alltraps>

801067f2 <vector55>:
.globl vector55
vector55:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $55
801067f4:	6a 37                	push   $0x37
  jmp alltraps
801067f6:	e9 cd f6 ff ff       	jmp    80105ec8 <alltraps>

801067fb <vector56>:
.globl vector56
vector56:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $56
801067fd:	6a 38                	push   $0x38
  jmp alltraps
801067ff:	e9 c4 f6 ff ff       	jmp    80105ec8 <alltraps>

80106804 <vector57>:
.globl vector57
vector57:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $57
80106806:	6a 39                	push   $0x39
  jmp alltraps
80106808:	e9 bb f6 ff ff       	jmp    80105ec8 <alltraps>

8010680d <vector58>:
.globl vector58
vector58:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $58
8010680f:	6a 3a                	push   $0x3a
  jmp alltraps
80106811:	e9 b2 f6 ff ff       	jmp    80105ec8 <alltraps>

80106816 <vector59>:
.globl vector59
vector59:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $59
80106818:	6a 3b                	push   $0x3b
  jmp alltraps
8010681a:	e9 a9 f6 ff ff       	jmp    80105ec8 <alltraps>

8010681f <vector60>:
.globl vector60
vector60:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $60
80106821:	6a 3c                	push   $0x3c
  jmp alltraps
80106823:	e9 a0 f6 ff ff       	jmp    80105ec8 <alltraps>

80106828 <vector61>:
.globl vector61
vector61:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $61
8010682a:	6a 3d                	push   $0x3d
  jmp alltraps
8010682c:	e9 97 f6 ff ff       	jmp    80105ec8 <alltraps>

80106831 <vector62>:
.globl vector62
vector62:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $62
80106833:	6a 3e                	push   $0x3e
  jmp alltraps
80106835:	e9 8e f6 ff ff       	jmp    80105ec8 <alltraps>

8010683a <vector63>:
.globl vector63
vector63:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $63
8010683c:	6a 3f                	push   $0x3f
  jmp alltraps
8010683e:	e9 85 f6 ff ff       	jmp    80105ec8 <alltraps>

80106843 <vector64>:
.globl vector64
vector64:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $64
80106845:	6a 40                	push   $0x40
  jmp alltraps
80106847:	e9 7c f6 ff ff       	jmp    80105ec8 <alltraps>

8010684c <vector65>:
.globl vector65
vector65:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $65
8010684e:	6a 41                	push   $0x41
  jmp alltraps
80106850:	e9 73 f6 ff ff       	jmp    80105ec8 <alltraps>

80106855 <vector66>:
.globl vector66
vector66:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $66
80106857:	6a 42                	push   $0x42
  jmp alltraps
80106859:	e9 6a f6 ff ff       	jmp    80105ec8 <alltraps>

8010685e <vector67>:
.globl vector67
vector67:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $67
80106860:	6a 43                	push   $0x43
  jmp alltraps
80106862:	e9 61 f6 ff ff       	jmp    80105ec8 <alltraps>

80106867 <vector68>:
.globl vector68
vector68:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $68
80106869:	6a 44                	push   $0x44
  jmp alltraps
8010686b:	e9 58 f6 ff ff       	jmp    80105ec8 <alltraps>

80106870 <vector69>:
.globl vector69
vector69:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $69
80106872:	6a 45                	push   $0x45
  jmp alltraps
80106874:	e9 4f f6 ff ff       	jmp    80105ec8 <alltraps>

80106879 <vector70>:
.globl vector70
vector70:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $70
8010687b:	6a 46                	push   $0x46
  jmp alltraps
8010687d:	e9 46 f6 ff ff       	jmp    80105ec8 <alltraps>

80106882 <vector71>:
.globl vector71
vector71:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $71
80106884:	6a 47                	push   $0x47
  jmp alltraps
80106886:	e9 3d f6 ff ff       	jmp    80105ec8 <alltraps>

8010688b <vector72>:
.globl vector72
vector72:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $72
8010688d:	6a 48                	push   $0x48
  jmp alltraps
8010688f:	e9 34 f6 ff ff       	jmp    80105ec8 <alltraps>

80106894 <vector73>:
.globl vector73
vector73:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $73
80106896:	6a 49                	push   $0x49
  jmp alltraps
80106898:	e9 2b f6 ff ff       	jmp    80105ec8 <alltraps>

8010689d <vector74>:
.globl vector74
vector74:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $74
8010689f:	6a 4a                	push   $0x4a
  jmp alltraps
801068a1:	e9 22 f6 ff ff       	jmp    80105ec8 <alltraps>

801068a6 <vector75>:
.globl vector75
vector75:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $75
801068a8:	6a 4b                	push   $0x4b
  jmp alltraps
801068aa:	e9 19 f6 ff ff       	jmp    80105ec8 <alltraps>

801068af <vector76>:
.globl vector76
vector76:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $76
801068b1:	6a 4c                	push   $0x4c
  jmp alltraps
801068b3:	e9 10 f6 ff ff       	jmp    80105ec8 <alltraps>

801068b8 <vector77>:
.globl vector77
vector77:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $77
801068ba:	6a 4d                	push   $0x4d
  jmp alltraps
801068bc:	e9 07 f6 ff ff       	jmp    80105ec8 <alltraps>

801068c1 <vector78>:
.globl vector78
vector78:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $78
801068c3:	6a 4e                	push   $0x4e
  jmp alltraps
801068c5:	e9 fe f5 ff ff       	jmp    80105ec8 <alltraps>

801068ca <vector79>:
.globl vector79
vector79:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $79
801068cc:	6a 4f                	push   $0x4f
  jmp alltraps
801068ce:	e9 f5 f5 ff ff       	jmp    80105ec8 <alltraps>

801068d3 <vector80>:
.globl vector80
vector80:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $80
801068d5:	6a 50                	push   $0x50
  jmp alltraps
801068d7:	e9 ec f5 ff ff       	jmp    80105ec8 <alltraps>

801068dc <vector81>:
.globl vector81
vector81:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $81
801068de:	6a 51                	push   $0x51
  jmp alltraps
801068e0:	e9 e3 f5 ff ff       	jmp    80105ec8 <alltraps>

801068e5 <vector82>:
.globl vector82
vector82:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $82
801068e7:	6a 52                	push   $0x52
  jmp alltraps
801068e9:	e9 da f5 ff ff       	jmp    80105ec8 <alltraps>

801068ee <vector83>:
.globl vector83
vector83:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $83
801068f0:	6a 53                	push   $0x53
  jmp alltraps
801068f2:	e9 d1 f5 ff ff       	jmp    80105ec8 <alltraps>

801068f7 <vector84>:
.globl vector84
vector84:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $84
801068f9:	6a 54                	push   $0x54
  jmp alltraps
801068fb:	e9 c8 f5 ff ff       	jmp    80105ec8 <alltraps>

80106900 <vector85>:
.globl vector85
vector85:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $85
80106902:	6a 55                	push   $0x55
  jmp alltraps
80106904:	e9 bf f5 ff ff       	jmp    80105ec8 <alltraps>

80106909 <vector86>:
.globl vector86
vector86:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $86
8010690b:	6a 56                	push   $0x56
  jmp alltraps
8010690d:	e9 b6 f5 ff ff       	jmp    80105ec8 <alltraps>

80106912 <vector87>:
.globl vector87
vector87:
  pushl $0
80106912:	6a 00                	push   $0x0
  pushl $87
80106914:	6a 57                	push   $0x57
  jmp alltraps
80106916:	e9 ad f5 ff ff       	jmp    80105ec8 <alltraps>

8010691b <vector88>:
.globl vector88
vector88:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $88
8010691d:	6a 58                	push   $0x58
  jmp alltraps
8010691f:	e9 a4 f5 ff ff       	jmp    80105ec8 <alltraps>

80106924 <vector89>:
.globl vector89
vector89:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $89
80106926:	6a 59                	push   $0x59
  jmp alltraps
80106928:	e9 9b f5 ff ff       	jmp    80105ec8 <alltraps>

8010692d <vector90>:
.globl vector90
vector90:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $90
8010692f:	6a 5a                	push   $0x5a
  jmp alltraps
80106931:	e9 92 f5 ff ff       	jmp    80105ec8 <alltraps>

80106936 <vector91>:
.globl vector91
vector91:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $91
80106938:	6a 5b                	push   $0x5b
  jmp alltraps
8010693a:	e9 89 f5 ff ff       	jmp    80105ec8 <alltraps>

8010693f <vector92>:
.globl vector92
vector92:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $92
80106941:	6a 5c                	push   $0x5c
  jmp alltraps
80106943:	e9 80 f5 ff ff       	jmp    80105ec8 <alltraps>

80106948 <vector93>:
.globl vector93
vector93:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $93
8010694a:	6a 5d                	push   $0x5d
  jmp alltraps
8010694c:	e9 77 f5 ff ff       	jmp    80105ec8 <alltraps>

80106951 <vector94>:
.globl vector94
vector94:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $94
80106953:	6a 5e                	push   $0x5e
  jmp alltraps
80106955:	e9 6e f5 ff ff       	jmp    80105ec8 <alltraps>

8010695a <vector95>:
.globl vector95
vector95:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $95
8010695c:	6a 5f                	push   $0x5f
  jmp alltraps
8010695e:	e9 65 f5 ff ff       	jmp    80105ec8 <alltraps>

80106963 <vector96>:
.globl vector96
vector96:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $96
80106965:	6a 60                	push   $0x60
  jmp alltraps
80106967:	e9 5c f5 ff ff       	jmp    80105ec8 <alltraps>

8010696c <vector97>:
.globl vector97
vector97:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $97
8010696e:	6a 61                	push   $0x61
  jmp alltraps
80106970:	e9 53 f5 ff ff       	jmp    80105ec8 <alltraps>

80106975 <vector98>:
.globl vector98
vector98:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $98
80106977:	6a 62                	push   $0x62
  jmp alltraps
80106979:	e9 4a f5 ff ff       	jmp    80105ec8 <alltraps>

8010697e <vector99>:
.globl vector99
vector99:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $99
80106980:	6a 63                	push   $0x63
  jmp alltraps
80106982:	e9 41 f5 ff ff       	jmp    80105ec8 <alltraps>

80106987 <vector100>:
.globl vector100
vector100:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $100
80106989:	6a 64                	push   $0x64
  jmp alltraps
8010698b:	e9 38 f5 ff ff       	jmp    80105ec8 <alltraps>

80106990 <vector101>:
.globl vector101
vector101:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $101
80106992:	6a 65                	push   $0x65
  jmp alltraps
80106994:	e9 2f f5 ff ff       	jmp    80105ec8 <alltraps>

80106999 <vector102>:
.globl vector102
vector102:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $102
8010699b:	6a 66                	push   $0x66
  jmp alltraps
8010699d:	e9 26 f5 ff ff       	jmp    80105ec8 <alltraps>

801069a2 <vector103>:
.globl vector103
vector103:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $103
801069a4:	6a 67                	push   $0x67
  jmp alltraps
801069a6:	e9 1d f5 ff ff       	jmp    80105ec8 <alltraps>

801069ab <vector104>:
.globl vector104
vector104:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $104
801069ad:	6a 68                	push   $0x68
  jmp alltraps
801069af:	e9 14 f5 ff ff       	jmp    80105ec8 <alltraps>

801069b4 <vector105>:
.globl vector105
vector105:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $105
801069b6:	6a 69                	push   $0x69
  jmp alltraps
801069b8:	e9 0b f5 ff ff       	jmp    80105ec8 <alltraps>

801069bd <vector106>:
.globl vector106
vector106:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $106
801069bf:	6a 6a                	push   $0x6a
  jmp alltraps
801069c1:	e9 02 f5 ff ff       	jmp    80105ec8 <alltraps>

801069c6 <vector107>:
.globl vector107
vector107:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $107
801069c8:	6a 6b                	push   $0x6b
  jmp alltraps
801069ca:	e9 f9 f4 ff ff       	jmp    80105ec8 <alltraps>

801069cf <vector108>:
.globl vector108
vector108:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $108
801069d1:	6a 6c                	push   $0x6c
  jmp alltraps
801069d3:	e9 f0 f4 ff ff       	jmp    80105ec8 <alltraps>

801069d8 <vector109>:
.globl vector109
vector109:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $109
801069da:	6a 6d                	push   $0x6d
  jmp alltraps
801069dc:	e9 e7 f4 ff ff       	jmp    80105ec8 <alltraps>

801069e1 <vector110>:
.globl vector110
vector110:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $110
801069e3:	6a 6e                	push   $0x6e
  jmp alltraps
801069e5:	e9 de f4 ff ff       	jmp    80105ec8 <alltraps>

801069ea <vector111>:
.globl vector111
vector111:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $111
801069ec:	6a 6f                	push   $0x6f
  jmp alltraps
801069ee:	e9 d5 f4 ff ff       	jmp    80105ec8 <alltraps>

801069f3 <vector112>:
.globl vector112
vector112:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $112
801069f5:	6a 70                	push   $0x70
  jmp alltraps
801069f7:	e9 cc f4 ff ff       	jmp    80105ec8 <alltraps>

801069fc <vector113>:
.globl vector113
vector113:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $113
801069fe:	6a 71                	push   $0x71
  jmp alltraps
80106a00:	e9 c3 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a05 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $114
80106a07:	6a 72                	push   $0x72
  jmp alltraps
80106a09:	e9 ba f4 ff ff       	jmp    80105ec8 <alltraps>

80106a0e <vector115>:
.globl vector115
vector115:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $115
80106a10:	6a 73                	push   $0x73
  jmp alltraps
80106a12:	e9 b1 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a17 <vector116>:
.globl vector116
vector116:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $116
80106a19:	6a 74                	push   $0x74
  jmp alltraps
80106a1b:	e9 a8 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a20 <vector117>:
.globl vector117
vector117:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $117
80106a22:	6a 75                	push   $0x75
  jmp alltraps
80106a24:	e9 9f f4 ff ff       	jmp    80105ec8 <alltraps>

80106a29 <vector118>:
.globl vector118
vector118:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $118
80106a2b:	6a 76                	push   $0x76
  jmp alltraps
80106a2d:	e9 96 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a32 <vector119>:
.globl vector119
vector119:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $119
80106a34:	6a 77                	push   $0x77
  jmp alltraps
80106a36:	e9 8d f4 ff ff       	jmp    80105ec8 <alltraps>

80106a3b <vector120>:
.globl vector120
vector120:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $120
80106a3d:	6a 78                	push   $0x78
  jmp alltraps
80106a3f:	e9 84 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a44 <vector121>:
.globl vector121
vector121:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $121
80106a46:	6a 79                	push   $0x79
  jmp alltraps
80106a48:	e9 7b f4 ff ff       	jmp    80105ec8 <alltraps>

80106a4d <vector122>:
.globl vector122
vector122:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $122
80106a4f:	6a 7a                	push   $0x7a
  jmp alltraps
80106a51:	e9 72 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a56 <vector123>:
.globl vector123
vector123:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $123
80106a58:	6a 7b                	push   $0x7b
  jmp alltraps
80106a5a:	e9 69 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a5f <vector124>:
.globl vector124
vector124:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $124
80106a61:	6a 7c                	push   $0x7c
  jmp alltraps
80106a63:	e9 60 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a68 <vector125>:
.globl vector125
vector125:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $125
80106a6a:	6a 7d                	push   $0x7d
  jmp alltraps
80106a6c:	e9 57 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a71 <vector126>:
.globl vector126
vector126:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $126
80106a73:	6a 7e                	push   $0x7e
  jmp alltraps
80106a75:	e9 4e f4 ff ff       	jmp    80105ec8 <alltraps>

80106a7a <vector127>:
.globl vector127
vector127:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $127
80106a7c:	6a 7f                	push   $0x7f
  jmp alltraps
80106a7e:	e9 45 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a83 <vector128>:
.globl vector128
vector128:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $128
80106a85:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106a8a:	e9 39 f4 ff ff       	jmp    80105ec8 <alltraps>

80106a8f <vector129>:
.globl vector129
vector129:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $129
80106a91:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106a96:	e9 2d f4 ff ff       	jmp    80105ec8 <alltraps>

80106a9b <vector130>:
.globl vector130
vector130:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $130
80106a9d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106aa2:	e9 21 f4 ff ff       	jmp    80105ec8 <alltraps>

80106aa7 <vector131>:
.globl vector131
vector131:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $131
80106aa9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106aae:	e9 15 f4 ff ff       	jmp    80105ec8 <alltraps>

80106ab3 <vector132>:
.globl vector132
vector132:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $132
80106ab5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106aba:	e9 09 f4 ff ff       	jmp    80105ec8 <alltraps>

80106abf <vector133>:
.globl vector133
vector133:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $133
80106ac1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106ac6:	e9 fd f3 ff ff       	jmp    80105ec8 <alltraps>

80106acb <vector134>:
.globl vector134
vector134:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $134
80106acd:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106ad2:	e9 f1 f3 ff ff       	jmp    80105ec8 <alltraps>

80106ad7 <vector135>:
.globl vector135
vector135:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $135
80106ad9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ade:	e9 e5 f3 ff ff       	jmp    80105ec8 <alltraps>

80106ae3 <vector136>:
.globl vector136
vector136:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $136
80106ae5:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106aea:	e9 d9 f3 ff ff       	jmp    80105ec8 <alltraps>

80106aef <vector137>:
.globl vector137
vector137:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $137
80106af1:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106af6:	e9 cd f3 ff ff       	jmp    80105ec8 <alltraps>

80106afb <vector138>:
.globl vector138
vector138:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $138
80106afd:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b02:	e9 c1 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b07 <vector139>:
.globl vector139
vector139:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $139
80106b09:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106b0e:	e9 b5 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b13 <vector140>:
.globl vector140
vector140:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $140
80106b15:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106b1a:	e9 a9 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b1f <vector141>:
.globl vector141
vector141:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $141
80106b21:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106b26:	e9 9d f3 ff ff       	jmp    80105ec8 <alltraps>

80106b2b <vector142>:
.globl vector142
vector142:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $142
80106b2d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106b32:	e9 91 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b37 <vector143>:
.globl vector143
vector143:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $143
80106b39:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106b3e:	e9 85 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b43 <vector144>:
.globl vector144
vector144:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $144
80106b45:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106b4a:	e9 79 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b4f <vector145>:
.globl vector145
vector145:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $145
80106b51:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106b56:	e9 6d f3 ff ff       	jmp    80105ec8 <alltraps>

80106b5b <vector146>:
.globl vector146
vector146:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $146
80106b5d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106b62:	e9 61 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b67 <vector147>:
.globl vector147
vector147:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $147
80106b69:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106b6e:	e9 55 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b73 <vector148>:
.globl vector148
vector148:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $148
80106b75:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106b7a:	e9 49 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b7f <vector149>:
.globl vector149
vector149:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $149
80106b81:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106b86:	e9 3d f3 ff ff       	jmp    80105ec8 <alltraps>

80106b8b <vector150>:
.globl vector150
vector150:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $150
80106b8d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106b92:	e9 31 f3 ff ff       	jmp    80105ec8 <alltraps>

80106b97 <vector151>:
.globl vector151
vector151:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $151
80106b99:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106b9e:	e9 25 f3 ff ff       	jmp    80105ec8 <alltraps>

80106ba3 <vector152>:
.globl vector152
vector152:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $152
80106ba5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106baa:	e9 19 f3 ff ff       	jmp    80105ec8 <alltraps>

80106baf <vector153>:
.globl vector153
vector153:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $153
80106bb1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106bb6:	e9 0d f3 ff ff       	jmp    80105ec8 <alltraps>

80106bbb <vector154>:
.globl vector154
vector154:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $154
80106bbd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106bc2:	e9 01 f3 ff ff       	jmp    80105ec8 <alltraps>

80106bc7 <vector155>:
.globl vector155
vector155:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $155
80106bc9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106bce:	e9 f5 f2 ff ff       	jmp    80105ec8 <alltraps>

80106bd3 <vector156>:
.globl vector156
vector156:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $156
80106bd5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106bda:	e9 e9 f2 ff ff       	jmp    80105ec8 <alltraps>

80106bdf <vector157>:
.globl vector157
vector157:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $157
80106be1:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106be6:	e9 dd f2 ff ff       	jmp    80105ec8 <alltraps>

80106beb <vector158>:
.globl vector158
vector158:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $158
80106bed:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106bf2:	e9 d1 f2 ff ff       	jmp    80105ec8 <alltraps>

80106bf7 <vector159>:
.globl vector159
vector159:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $159
80106bf9:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106bfe:	e9 c5 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c03 <vector160>:
.globl vector160
vector160:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $160
80106c05:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c0a:	e9 b9 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c0f <vector161>:
.globl vector161
vector161:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $161
80106c11:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106c16:	e9 ad f2 ff ff       	jmp    80105ec8 <alltraps>

80106c1b <vector162>:
.globl vector162
vector162:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $162
80106c1d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106c22:	e9 a1 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c27 <vector163>:
.globl vector163
vector163:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $163
80106c29:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106c2e:	e9 95 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c33 <vector164>:
.globl vector164
vector164:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $164
80106c35:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106c3a:	e9 89 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c3f <vector165>:
.globl vector165
vector165:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $165
80106c41:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106c46:	e9 7d f2 ff ff       	jmp    80105ec8 <alltraps>

80106c4b <vector166>:
.globl vector166
vector166:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $166
80106c4d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106c52:	e9 71 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c57 <vector167>:
.globl vector167
vector167:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $167
80106c59:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106c5e:	e9 65 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c63 <vector168>:
.globl vector168
vector168:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $168
80106c65:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106c6a:	e9 59 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c6f <vector169>:
.globl vector169
vector169:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $169
80106c71:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106c76:	e9 4d f2 ff ff       	jmp    80105ec8 <alltraps>

80106c7b <vector170>:
.globl vector170
vector170:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $170
80106c7d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106c82:	e9 41 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c87 <vector171>:
.globl vector171
vector171:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $171
80106c89:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106c8e:	e9 35 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c93 <vector172>:
.globl vector172
vector172:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $172
80106c95:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106c9a:	e9 29 f2 ff ff       	jmp    80105ec8 <alltraps>

80106c9f <vector173>:
.globl vector173
vector173:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $173
80106ca1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106ca6:	e9 1d f2 ff ff       	jmp    80105ec8 <alltraps>

80106cab <vector174>:
.globl vector174
vector174:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $174
80106cad:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106cb2:	e9 11 f2 ff ff       	jmp    80105ec8 <alltraps>

80106cb7 <vector175>:
.globl vector175
vector175:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $175
80106cb9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106cbe:	e9 05 f2 ff ff       	jmp    80105ec8 <alltraps>

80106cc3 <vector176>:
.globl vector176
vector176:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $176
80106cc5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106cca:	e9 f9 f1 ff ff       	jmp    80105ec8 <alltraps>

80106ccf <vector177>:
.globl vector177
vector177:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $177
80106cd1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106cd6:	e9 ed f1 ff ff       	jmp    80105ec8 <alltraps>

80106cdb <vector178>:
.globl vector178
vector178:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $178
80106cdd:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106ce2:	e9 e1 f1 ff ff       	jmp    80105ec8 <alltraps>

80106ce7 <vector179>:
.globl vector179
vector179:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $179
80106ce9:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106cee:	e9 d5 f1 ff ff       	jmp    80105ec8 <alltraps>

80106cf3 <vector180>:
.globl vector180
vector180:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $180
80106cf5:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106cfa:	e9 c9 f1 ff ff       	jmp    80105ec8 <alltraps>

80106cff <vector181>:
.globl vector181
vector181:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $181
80106d01:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d06:	e9 bd f1 ff ff       	jmp    80105ec8 <alltraps>

80106d0b <vector182>:
.globl vector182
vector182:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $182
80106d0d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106d12:	e9 b1 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d17 <vector183>:
.globl vector183
vector183:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $183
80106d19:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106d1e:	e9 a5 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d23 <vector184>:
.globl vector184
vector184:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $184
80106d25:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106d2a:	e9 99 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d2f <vector185>:
.globl vector185
vector185:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $185
80106d31:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106d36:	e9 8d f1 ff ff       	jmp    80105ec8 <alltraps>

80106d3b <vector186>:
.globl vector186
vector186:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $186
80106d3d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106d42:	e9 81 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d47 <vector187>:
.globl vector187
vector187:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $187
80106d49:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106d4e:	e9 75 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d53 <vector188>:
.globl vector188
vector188:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $188
80106d55:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106d5a:	e9 69 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d5f <vector189>:
.globl vector189
vector189:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $189
80106d61:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106d66:	e9 5d f1 ff ff       	jmp    80105ec8 <alltraps>

80106d6b <vector190>:
.globl vector190
vector190:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $190
80106d6d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106d72:	e9 51 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d77 <vector191>:
.globl vector191
vector191:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $191
80106d79:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106d7e:	e9 45 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d83 <vector192>:
.globl vector192
vector192:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $192
80106d85:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106d8a:	e9 39 f1 ff ff       	jmp    80105ec8 <alltraps>

80106d8f <vector193>:
.globl vector193
vector193:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $193
80106d91:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106d96:	e9 2d f1 ff ff       	jmp    80105ec8 <alltraps>

80106d9b <vector194>:
.globl vector194
vector194:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $194
80106d9d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106da2:	e9 21 f1 ff ff       	jmp    80105ec8 <alltraps>

80106da7 <vector195>:
.globl vector195
vector195:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $195
80106da9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106dae:	e9 15 f1 ff ff       	jmp    80105ec8 <alltraps>

80106db3 <vector196>:
.globl vector196
vector196:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $196
80106db5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106dba:	e9 09 f1 ff ff       	jmp    80105ec8 <alltraps>

80106dbf <vector197>:
.globl vector197
vector197:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $197
80106dc1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106dc6:	e9 fd f0 ff ff       	jmp    80105ec8 <alltraps>

80106dcb <vector198>:
.globl vector198
vector198:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $198
80106dcd:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106dd2:	e9 f1 f0 ff ff       	jmp    80105ec8 <alltraps>

80106dd7 <vector199>:
.globl vector199
vector199:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $199
80106dd9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106dde:	e9 e5 f0 ff ff       	jmp    80105ec8 <alltraps>

80106de3 <vector200>:
.globl vector200
vector200:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $200
80106de5:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106dea:	e9 d9 f0 ff ff       	jmp    80105ec8 <alltraps>

80106def <vector201>:
.globl vector201
vector201:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $201
80106df1:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106df6:	e9 cd f0 ff ff       	jmp    80105ec8 <alltraps>

80106dfb <vector202>:
.globl vector202
vector202:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $202
80106dfd:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e02:	e9 c1 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e07 <vector203>:
.globl vector203
vector203:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $203
80106e09:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106e0e:	e9 b5 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e13 <vector204>:
.globl vector204
vector204:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $204
80106e15:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106e1a:	e9 a9 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e1f <vector205>:
.globl vector205
vector205:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $205
80106e21:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106e26:	e9 9d f0 ff ff       	jmp    80105ec8 <alltraps>

80106e2b <vector206>:
.globl vector206
vector206:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $206
80106e2d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106e32:	e9 91 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e37 <vector207>:
.globl vector207
vector207:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $207
80106e39:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106e3e:	e9 85 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e43 <vector208>:
.globl vector208
vector208:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $208
80106e45:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106e4a:	e9 79 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e4f <vector209>:
.globl vector209
vector209:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $209
80106e51:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106e56:	e9 6d f0 ff ff       	jmp    80105ec8 <alltraps>

80106e5b <vector210>:
.globl vector210
vector210:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $210
80106e5d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106e62:	e9 61 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e67 <vector211>:
.globl vector211
vector211:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $211
80106e69:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106e6e:	e9 55 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e73 <vector212>:
.globl vector212
vector212:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $212
80106e75:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106e7a:	e9 49 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e7f <vector213>:
.globl vector213
vector213:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $213
80106e81:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106e86:	e9 3d f0 ff ff       	jmp    80105ec8 <alltraps>

80106e8b <vector214>:
.globl vector214
vector214:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $214
80106e8d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106e92:	e9 31 f0 ff ff       	jmp    80105ec8 <alltraps>

80106e97 <vector215>:
.globl vector215
vector215:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $215
80106e99:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106e9e:	e9 25 f0 ff ff       	jmp    80105ec8 <alltraps>

80106ea3 <vector216>:
.globl vector216
vector216:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $216
80106ea5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106eaa:	e9 19 f0 ff ff       	jmp    80105ec8 <alltraps>

80106eaf <vector217>:
.globl vector217
vector217:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $217
80106eb1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106eb6:	e9 0d f0 ff ff       	jmp    80105ec8 <alltraps>

80106ebb <vector218>:
.globl vector218
vector218:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $218
80106ebd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106ec2:	e9 01 f0 ff ff       	jmp    80105ec8 <alltraps>

80106ec7 <vector219>:
.globl vector219
vector219:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $219
80106ec9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106ece:	e9 f5 ef ff ff       	jmp    80105ec8 <alltraps>

80106ed3 <vector220>:
.globl vector220
vector220:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $220
80106ed5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106eda:	e9 e9 ef ff ff       	jmp    80105ec8 <alltraps>

80106edf <vector221>:
.globl vector221
vector221:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $221
80106ee1:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106ee6:	e9 dd ef ff ff       	jmp    80105ec8 <alltraps>

80106eeb <vector222>:
.globl vector222
vector222:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $222
80106eed:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106ef2:	e9 d1 ef ff ff       	jmp    80105ec8 <alltraps>

80106ef7 <vector223>:
.globl vector223
vector223:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $223
80106ef9:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106efe:	e9 c5 ef ff ff       	jmp    80105ec8 <alltraps>

80106f03 <vector224>:
.globl vector224
vector224:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $224
80106f05:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f0a:	e9 b9 ef ff ff       	jmp    80105ec8 <alltraps>

80106f0f <vector225>:
.globl vector225
vector225:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $225
80106f11:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106f16:	e9 ad ef ff ff       	jmp    80105ec8 <alltraps>

80106f1b <vector226>:
.globl vector226
vector226:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $226
80106f1d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106f22:	e9 a1 ef ff ff       	jmp    80105ec8 <alltraps>

80106f27 <vector227>:
.globl vector227
vector227:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $227
80106f29:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106f2e:	e9 95 ef ff ff       	jmp    80105ec8 <alltraps>

80106f33 <vector228>:
.globl vector228
vector228:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $228
80106f35:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106f3a:	e9 89 ef ff ff       	jmp    80105ec8 <alltraps>

80106f3f <vector229>:
.globl vector229
vector229:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $229
80106f41:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106f46:	e9 7d ef ff ff       	jmp    80105ec8 <alltraps>

80106f4b <vector230>:
.globl vector230
vector230:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $230
80106f4d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106f52:	e9 71 ef ff ff       	jmp    80105ec8 <alltraps>

80106f57 <vector231>:
.globl vector231
vector231:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $231
80106f59:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106f5e:	e9 65 ef ff ff       	jmp    80105ec8 <alltraps>

80106f63 <vector232>:
.globl vector232
vector232:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $232
80106f65:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106f6a:	e9 59 ef ff ff       	jmp    80105ec8 <alltraps>

80106f6f <vector233>:
.globl vector233
vector233:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $233
80106f71:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106f76:	e9 4d ef ff ff       	jmp    80105ec8 <alltraps>

80106f7b <vector234>:
.globl vector234
vector234:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $234
80106f7d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106f82:	e9 41 ef ff ff       	jmp    80105ec8 <alltraps>

80106f87 <vector235>:
.globl vector235
vector235:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $235
80106f89:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106f8e:	e9 35 ef ff ff       	jmp    80105ec8 <alltraps>

80106f93 <vector236>:
.globl vector236
vector236:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $236
80106f95:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106f9a:	e9 29 ef ff ff       	jmp    80105ec8 <alltraps>

80106f9f <vector237>:
.globl vector237
vector237:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $237
80106fa1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106fa6:	e9 1d ef ff ff       	jmp    80105ec8 <alltraps>

80106fab <vector238>:
.globl vector238
vector238:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $238
80106fad:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106fb2:	e9 11 ef ff ff       	jmp    80105ec8 <alltraps>

80106fb7 <vector239>:
.globl vector239
vector239:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $239
80106fb9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106fbe:	e9 05 ef ff ff       	jmp    80105ec8 <alltraps>

80106fc3 <vector240>:
.globl vector240
vector240:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $240
80106fc5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106fca:	e9 f9 ee ff ff       	jmp    80105ec8 <alltraps>

80106fcf <vector241>:
.globl vector241
vector241:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $241
80106fd1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106fd6:	e9 ed ee ff ff       	jmp    80105ec8 <alltraps>

80106fdb <vector242>:
.globl vector242
vector242:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $242
80106fdd:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106fe2:	e9 e1 ee ff ff       	jmp    80105ec8 <alltraps>

80106fe7 <vector243>:
.globl vector243
vector243:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $243
80106fe9:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106fee:	e9 d5 ee ff ff       	jmp    80105ec8 <alltraps>

80106ff3 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $244
80106ff5:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106ffa:	e9 c9 ee ff ff       	jmp    80105ec8 <alltraps>

80106fff <vector245>:
.globl vector245
vector245:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $245
80107001:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107006:	e9 bd ee ff ff       	jmp    80105ec8 <alltraps>

8010700b <vector246>:
.globl vector246
vector246:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $246
8010700d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107012:	e9 b1 ee ff ff       	jmp    80105ec8 <alltraps>

80107017 <vector247>:
.globl vector247
vector247:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $247
80107019:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010701e:	e9 a5 ee ff ff       	jmp    80105ec8 <alltraps>

80107023 <vector248>:
.globl vector248
vector248:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $248
80107025:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010702a:	e9 99 ee ff ff       	jmp    80105ec8 <alltraps>

8010702f <vector249>:
.globl vector249
vector249:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $249
80107031:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107036:	e9 8d ee ff ff       	jmp    80105ec8 <alltraps>

8010703b <vector250>:
.globl vector250
vector250:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $250
8010703d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107042:	e9 81 ee ff ff       	jmp    80105ec8 <alltraps>

80107047 <vector251>:
.globl vector251
vector251:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $251
80107049:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010704e:	e9 75 ee ff ff       	jmp    80105ec8 <alltraps>

80107053 <vector252>:
.globl vector252
vector252:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $252
80107055:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010705a:	e9 69 ee ff ff       	jmp    80105ec8 <alltraps>

8010705f <vector253>:
.globl vector253
vector253:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $253
80107061:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107066:	e9 5d ee ff ff       	jmp    80105ec8 <alltraps>

8010706b <vector254>:
.globl vector254
vector254:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $254
8010706d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107072:	e9 51 ee ff ff       	jmp    80105ec8 <alltraps>

80107077 <vector255>:
.globl vector255
vector255:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $255
80107079:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010707e:	e9 45 ee ff ff       	jmp    80105ec8 <alltraps>

80107083 <lgdt>:
{
80107083:	55                   	push   %ebp
80107084:	89 e5                	mov    %esp,%ebp
80107086:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107089:	8b 45 0c             	mov    0xc(%ebp),%eax
8010708c:	83 e8 01             	sub    $0x1,%eax
8010708f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107093:	8b 45 08             	mov    0x8(%ebp),%eax
80107096:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010709a:	8b 45 08             	mov    0x8(%ebp),%eax
8010709d:	c1 e8 10             	shr    $0x10,%eax
801070a0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801070a4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801070a7:	0f 01 10             	lgdtl  (%eax)
}
801070aa:	90                   	nop
801070ab:	c9                   	leave  
801070ac:	c3                   	ret    

801070ad <ltr>:
{
801070ad:	55                   	push   %ebp
801070ae:	89 e5                	mov    %esp,%ebp
801070b0:	83 ec 04             	sub    $0x4,%esp
801070b3:	8b 45 08             	mov    0x8(%ebp),%eax
801070b6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801070ba:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801070be:	0f 00 d8             	ltr    %ax
}
801070c1:	90                   	nop
801070c2:	c9                   	leave  
801070c3:	c3                   	ret    

801070c4 <lcr3>:
{
801070c4:	55                   	push   %ebp
801070c5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801070c7:	8b 45 08             	mov    0x8(%ebp),%eax
801070ca:	0f 22 d8             	mov    %eax,%cr3
}
801070cd:	90                   	nop
801070ce:	5d                   	pop    %ebp
801070cf:	c3                   	ret    

801070d0 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801070d0:	55                   	push   %ebp
801070d1:	89 e5                	mov    %esp,%ebp
801070d3:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801070d6:	e8 b8 c8 ff ff       	call   80103993 <cpuid>
801070db:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801070e1:	05 80 69 19 80       	add    $0x80196980,%eax
801070e6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801070e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ec:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801070f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f5:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801070fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fe:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107105:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107109:	83 e2 f0             	and    $0xfffffff0,%edx
8010710c:	83 ca 0a             	or     $0xa,%edx
8010710f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107115:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107119:	83 ca 10             	or     $0x10,%edx
8010711c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010711f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107122:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107126:	83 e2 9f             	and    $0xffffff9f,%edx
80107129:	88 50 7d             	mov    %dl,0x7d(%eax)
8010712c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107133:	83 ca 80             	or     $0xffffff80,%edx
80107136:	88 50 7d             	mov    %dl,0x7d(%eax)
80107139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107140:	83 ca 0f             	or     $0xf,%edx
80107143:	88 50 7e             	mov    %dl,0x7e(%eax)
80107146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107149:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010714d:	83 e2 ef             	and    $0xffffffef,%edx
80107150:	88 50 7e             	mov    %dl,0x7e(%eax)
80107153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107156:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010715a:	83 e2 df             	and    $0xffffffdf,%edx
8010715d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107163:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107167:	83 ca 40             	or     $0x40,%edx
8010716a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010716d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107170:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107174:	83 ca 80             	or     $0xffffff80,%edx
80107177:	88 50 7e             	mov    %dl,0x7e(%eax)
8010717a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717d:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107184:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010718b:	ff ff 
8010718d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107190:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107197:	00 00 
80107199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719c:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801071a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071ad:	83 e2 f0             	and    $0xfffffff0,%edx
801071b0:	83 ca 02             	or     $0x2,%edx
801071b3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071c3:	83 ca 10             	or     $0x10,%edx
801071c6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071d6:	83 e2 9f             	and    $0xffffff9f,%edx
801071d9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071e9:	83 ca 80             	or     $0xffffff80,%edx
801071ec:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071fc:	83 ca 0f             	or     $0xf,%edx
801071ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107208:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010720f:	83 e2 ef             	and    $0xffffffef,%edx
80107212:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107222:	83 e2 df             	and    $0xffffffdf,%edx
80107225:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010722b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107235:	83 ca 40             	or     $0x40,%edx
80107238:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010723e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107241:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107248:	83 ca 80             	or     $0xffffff80,%edx
8010724b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107254:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107265:	ff ff 
80107267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726a:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107271:	00 00 
80107273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107276:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010727d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107280:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107287:	83 e2 f0             	and    $0xfffffff0,%edx
8010728a:	83 ca 0a             	or     $0xa,%edx
8010728d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107296:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010729d:	83 ca 10             	or     $0x10,%edx
801072a0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072b0:	83 ca 60             	or     $0x60,%edx
801072b3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072c3:	83 ca 80             	or     $0xffffff80,%edx
801072c6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072d6:	83 ca 0f             	or     $0xf,%edx
801072d9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072e9:	83 e2 ef             	and    $0xffffffef,%edx
801072ec:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072fc:	83 e2 df             	and    $0xffffffdf,%edx
801072ff:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107308:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010730f:	83 ca 40             	or     $0x40,%edx
80107312:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107322:	83 ca 80             	or     $0xffffff80,%edx
80107325:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010732b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107338:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010733f:	ff ff 
80107341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107344:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010734b:	00 00 
8010734d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107350:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107361:	83 e2 f0             	and    $0xfffffff0,%edx
80107364:	83 ca 02             	or     $0x2,%edx
80107367:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010736d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107370:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107377:	83 ca 10             	or     $0x10,%edx
8010737a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010738a:	83 ca 60             	or     $0x60,%edx
8010738d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010739d:	83 ca 80             	or     $0xffffff80,%edx
801073a0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073b0:	83 ca 0f             	or     $0xf,%edx
801073b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073c3:	83 e2 ef             	and    $0xffffffef,%edx
801073c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073d6:	83 e2 df             	and    $0xffffffdf,%edx
801073d9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073e9:	83 ca 40             	or     $0x40,%edx
801073ec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073fc:	83 ca 80             	or     $0xffffff80,%edx
801073ff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107408:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	83 c0 70             	add    $0x70,%eax
80107415:	83 ec 08             	sub    $0x8,%esp
80107418:	6a 30                	push   $0x30
8010741a:	50                   	push   %eax
8010741b:	e8 63 fc ff ff       	call   80107083 <lgdt>
80107420:	83 c4 10             	add    $0x10,%esp
}
80107423:	90                   	nop
80107424:	c9                   	leave  
80107425:	c3                   	ret    

80107426 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107426:	55                   	push   %ebp
80107427:	89 e5                	mov    %esp,%ebp
80107429:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010742c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010742f:	c1 e8 16             	shr    $0x16,%eax
80107432:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107439:	8b 45 08             	mov    0x8(%ebp),%eax
8010743c:	01 d0                	add    %edx,%eax
8010743e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107444:	8b 00                	mov    (%eax),%eax
80107446:	83 e0 01             	and    $0x1,%eax
80107449:	85 c0                	test   %eax,%eax
8010744b:	74 14                	je     80107461 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010744d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107450:	8b 00                	mov    (%eax),%eax
80107452:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107457:	05 00 00 00 80       	add    $0x80000000,%eax
8010745c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010745f:	eb 42                	jmp    801074a3 <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107461:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107465:	74 0e                	je     80107475 <walkpgdir+0x4f>
80107467:	e8 2a b3 ff ff       	call   80102796 <kalloc>
8010746c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010746f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107473:	75 07                	jne    8010747c <walkpgdir+0x56>
      return 0;
80107475:	b8 00 00 00 00       	mov    $0x0,%eax
8010747a:	eb 3e                	jmp    801074ba <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010747c:	83 ec 04             	sub    $0x4,%esp
8010747f:	68 00 10 00 00       	push   $0x1000
80107484:	6a 00                	push   $0x0
80107486:	ff 75 f4             	push   -0xc(%ebp)
80107489:	e8 2b d6 ff ff       	call   80104ab9 <memset>
8010748e:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107494:	05 00 00 00 80       	add    $0x80000000,%eax
80107499:	83 c8 07             	or     $0x7,%eax
8010749c:	89 c2                	mov    %eax,%edx
8010749e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074a1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801074a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801074a6:	c1 e8 0c             	shr    $0xc,%eax
801074a9:	25 ff 03 00 00       	and    $0x3ff,%eax
801074ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801074b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b8:	01 d0                	add    %edx,%eax
}
801074ba:	c9                   	leave  
801074bb:	c3                   	ret    

801074bc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801074bc:	55                   	push   %ebp
801074bd:	89 e5                	mov    %esp,%ebp
801074bf:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801074c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801074c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801074cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801074d0:	8b 45 10             	mov    0x10(%ebp),%eax
801074d3:	01 d0                	add    %edx,%eax
801074d5:	83 e8 01             	sub    $0x1,%eax
801074d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801074e0:	83 ec 04             	sub    $0x4,%esp
801074e3:	6a 01                	push   $0x1
801074e5:	ff 75 f4             	push   -0xc(%ebp)
801074e8:	ff 75 08             	push   0x8(%ebp)
801074eb:	e8 36 ff ff ff       	call   80107426 <walkpgdir>
801074f0:	83 c4 10             	add    $0x10,%esp
801074f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801074f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801074fa:	75 07                	jne    80107503 <mappages+0x47>
      return -1;
801074fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107501:	eb 47                	jmp    8010754a <mappages+0x8e>
    if(*pte & PTE_P)
80107503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107506:	8b 00                	mov    (%eax),%eax
80107508:	83 e0 01             	and    $0x1,%eax
8010750b:	85 c0                	test   %eax,%eax
8010750d:	74 0d                	je     8010751c <mappages+0x60>
      panic("remap");
8010750f:	83 ec 0c             	sub    $0xc,%esp
80107512:	68 d0 a8 10 80       	push   $0x8010a8d0
80107517:	e8 8d 90 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010751c:	8b 45 18             	mov    0x18(%ebp),%eax
8010751f:	0b 45 14             	or     0x14(%ebp),%eax
80107522:	83 c8 01             	or     $0x1,%eax
80107525:	89 c2                	mov    %eax,%edx
80107527:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010752a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107532:	74 10                	je     80107544 <mappages+0x88>
      break;
    a += PGSIZE;
80107534:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010753b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107542:	eb 9c                	jmp    801074e0 <mappages+0x24>
      break;
80107544:	90                   	nop
  }
  return 0;
80107545:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010754a:	c9                   	leave  
8010754b:	c3                   	ret    

8010754c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010754c:	55                   	push   %ebp
8010754d:	89 e5                	mov    %esp,%ebp
8010754f:	53                   	push   %ebx
80107550:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107553:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010755a:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107560:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107565:	29 d0                	sub    %edx,%eax
80107567:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010756a:	a1 48 6c 19 80       	mov    0x80196c48,%eax
8010756f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107572:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
80107578:	a1 50 6c 19 80       	mov    0x80196c50,%eax
8010757d:	01 d0                	add    %edx,%eax
8010757f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107582:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758c:	83 c0 30             	add    $0x30,%eax
8010758f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107592:	89 10                	mov    %edx,(%eax)
80107594:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107597:	89 50 04             	mov    %edx,0x4(%eax)
8010759a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010759d:	89 50 08             	mov    %edx,0x8(%eax)
801075a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801075a3:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801075a6:	e8 eb b1 ff ff       	call   80102796 <kalloc>
801075ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801075ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801075b2:	75 07                	jne    801075bb <setupkvm+0x6f>
    return 0;
801075b4:	b8 00 00 00 00       	mov    $0x0,%eax
801075b9:	eb 78                	jmp    80107633 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801075bb:	83 ec 04             	sub    $0x4,%esp
801075be:	68 00 10 00 00       	push   $0x1000
801075c3:	6a 00                	push   $0x0
801075c5:	ff 75 f0             	push   -0x10(%ebp)
801075c8:	e8 ec d4 ff ff       	call   80104ab9 <memset>
801075cd:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801075d0:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801075d7:	eb 4e                	jmp    80107627 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801075df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e2:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e8:	8b 58 08             	mov    0x8(%eax),%ebx
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	8b 40 04             	mov    0x4(%eax),%eax
801075f1:	29 c3                	sub    %eax,%ebx
801075f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f6:	8b 00                	mov    (%eax),%eax
801075f8:	83 ec 0c             	sub    $0xc,%esp
801075fb:	51                   	push   %ecx
801075fc:	52                   	push   %edx
801075fd:	53                   	push   %ebx
801075fe:	50                   	push   %eax
801075ff:	ff 75 f0             	push   -0x10(%ebp)
80107602:	e8 b5 fe ff ff       	call   801074bc <mappages>
80107607:	83 c4 20             	add    $0x20,%esp
8010760a:	85 c0                	test   %eax,%eax
8010760c:	79 15                	jns    80107623 <setupkvm+0xd7>
      freevm(pgdir);
8010760e:	83 ec 0c             	sub    $0xc,%esp
80107611:	ff 75 f0             	push   -0x10(%ebp)
80107614:	e8 f5 04 00 00       	call   80107b0e <freevm>
80107619:	83 c4 10             	add    $0x10,%esp
      return 0;
8010761c:	b8 00 00 00 00       	mov    $0x0,%eax
80107621:	eb 10                	jmp    80107633 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107623:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107627:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010762e:	72 a9                	jb     801075d9 <setupkvm+0x8d>
    }
  return pgdir;
80107630:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107636:	c9                   	leave  
80107637:	c3                   	ret    

80107638 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107638:	55                   	push   %ebp
80107639:	89 e5                	mov    %esp,%ebp
8010763b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010763e:	e8 09 ff ff ff       	call   8010754c <setupkvm>
80107643:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
80107648:	e8 03 00 00 00       	call   80107650 <switchkvm>
}
8010764d:	90                   	nop
8010764e:	c9                   	leave  
8010764f:	c3                   	ret    

80107650 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107650:	55                   	push   %ebp
80107651:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107653:	a1 7c 69 19 80       	mov    0x8019697c,%eax
80107658:	05 00 00 00 80       	add    $0x80000000,%eax
8010765d:	50                   	push   %eax
8010765e:	e8 61 fa ff ff       	call   801070c4 <lcr3>
80107663:	83 c4 04             	add    $0x4,%esp
}
80107666:	90                   	nop
80107667:	c9                   	leave  
80107668:	c3                   	ret    

80107669 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107669:	55                   	push   %ebp
8010766a:	89 e5                	mov    %esp,%ebp
8010766c:	56                   	push   %esi
8010766d:	53                   	push   %ebx
8010766e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107671:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107675:	75 0d                	jne    80107684 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107677:	83 ec 0c             	sub    $0xc,%esp
8010767a:	68 d6 a8 10 80       	push   $0x8010a8d6
8010767f:	e8 25 8f ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107684:	8b 45 08             	mov    0x8(%ebp),%eax
80107687:	8b 40 08             	mov    0x8(%eax),%eax
8010768a:	85 c0                	test   %eax,%eax
8010768c:	75 0d                	jne    8010769b <switchuvm+0x32>
    panic("switchuvm: no kstack");
8010768e:	83 ec 0c             	sub    $0xc,%esp
80107691:	68 ec a8 10 80       	push   $0x8010a8ec
80107696:	e8 0e 8f ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010769b:	8b 45 08             	mov    0x8(%ebp),%eax
8010769e:	8b 40 04             	mov    0x4(%eax),%eax
801076a1:	85 c0                	test   %eax,%eax
801076a3:	75 0d                	jne    801076b2 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801076a5:	83 ec 0c             	sub    $0xc,%esp
801076a8:	68 01 a9 10 80       	push   $0x8010a901
801076ad:	e8 f7 8e ff ff       	call   801005a9 <panic>

  pushcli();
801076b2:	e8 f7 d2 ff ff       	call   801049ae <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801076b7:	e8 f2 c2 ff ff       	call   801039ae <mycpu>
801076bc:	89 c3                	mov    %eax,%ebx
801076be:	e8 eb c2 ff ff       	call   801039ae <mycpu>
801076c3:	83 c0 08             	add    $0x8,%eax
801076c6:	89 c6                	mov    %eax,%esi
801076c8:	e8 e1 c2 ff ff       	call   801039ae <mycpu>
801076cd:	83 c0 08             	add    $0x8,%eax
801076d0:	c1 e8 10             	shr    $0x10,%eax
801076d3:	88 45 f7             	mov    %al,-0x9(%ebp)
801076d6:	e8 d3 c2 ff ff       	call   801039ae <mycpu>
801076db:	83 c0 08             	add    $0x8,%eax
801076de:	c1 e8 18             	shr    $0x18,%eax
801076e1:	89 c2                	mov    %eax,%edx
801076e3:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801076ea:	67 00 
801076ec:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801076f3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801076f7:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801076fd:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107704:	83 e0 f0             	and    $0xfffffff0,%eax
80107707:	83 c8 09             	or     $0x9,%eax
8010770a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107710:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107717:	83 c8 10             	or     $0x10,%eax
8010771a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107720:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107727:	83 e0 9f             	and    $0xffffff9f,%eax
8010772a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107730:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107737:	83 c8 80             	or     $0xffffff80,%eax
8010773a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107740:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107747:	83 e0 f0             	and    $0xfffffff0,%eax
8010774a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107750:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107757:	83 e0 ef             	and    $0xffffffef,%eax
8010775a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107760:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107767:	83 e0 df             	and    $0xffffffdf,%eax
8010776a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107770:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107777:	83 c8 40             	or     $0x40,%eax
8010777a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107780:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107787:	83 e0 7f             	and    $0x7f,%eax
8010778a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107790:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107796:	e8 13 c2 ff ff       	call   801039ae <mycpu>
8010779b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801077a2:	83 e2 ef             	and    $0xffffffef,%edx
801077a5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801077ab:	e8 fe c1 ff ff       	call   801039ae <mycpu>
801077b0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801077b6:	8b 45 08             	mov    0x8(%ebp),%eax
801077b9:	8b 40 08             	mov    0x8(%eax),%eax
801077bc:	89 c3                	mov    %eax,%ebx
801077be:	e8 eb c1 ff ff       	call   801039ae <mycpu>
801077c3:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801077c9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801077cc:	e8 dd c1 ff ff       	call   801039ae <mycpu>
801077d1:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801077d7:	83 ec 0c             	sub    $0xc,%esp
801077da:	6a 28                	push   $0x28
801077dc:	e8 cc f8 ff ff       	call   801070ad <ltr>
801077e1:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801077e4:	8b 45 08             	mov    0x8(%ebp),%eax
801077e7:	8b 40 04             	mov    0x4(%eax),%eax
801077ea:	05 00 00 00 80       	add    $0x80000000,%eax
801077ef:	83 ec 0c             	sub    $0xc,%esp
801077f2:	50                   	push   %eax
801077f3:	e8 cc f8 ff ff       	call   801070c4 <lcr3>
801077f8:	83 c4 10             	add    $0x10,%esp
  popcli();
801077fb:	e8 fb d1 ff ff       	call   801049fb <popcli>
}
80107800:	90                   	nop
80107801:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107804:	5b                   	pop    %ebx
80107805:	5e                   	pop    %esi
80107806:	5d                   	pop    %ebp
80107807:	c3                   	ret    

80107808 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107808:	55                   	push   %ebp
80107809:	89 e5                	mov    %esp,%ebp
8010780b:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010780e:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107815:	76 0d                	jbe    80107824 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107817:	83 ec 0c             	sub    $0xc,%esp
8010781a:	68 15 a9 10 80       	push   $0x8010a915
8010781f:	e8 85 8d ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107824:	e8 6d af ff ff       	call   80102796 <kalloc>
80107829:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010782c:	83 ec 04             	sub    $0x4,%esp
8010782f:	68 00 10 00 00       	push   $0x1000
80107834:	6a 00                	push   $0x0
80107836:	ff 75 f4             	push   -0xc(%ebp)
80107839:	e8 7b d2 ff ff       	call   80104ab9 <memset>
8010783e:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107844:	05 00 00 00 80       	add    $0x80000000,%eax
80107849:	83 ec 0c             	sub    $0xc,%esp
8010784c:	6a 06                	push   $0x6
8010784e:	50                   	push   %eax
8010784f:	68 00 10 00 00       	push   $0x1000
80107854:	6a 00                	push   $0x0
80107856:	ff 75 08             	push   0x8(%ebp)
80107859:	e8 5e fc ff ff       	call   801074bc <mappages>
8010785e:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107861:	83 ec 04             	sub    $0x4,%esp
80107864:	ff 75 10             	push   0x10(%ebp)
80107867:	ff 75 0c             	push   0xc(%ebp)
8010786a:	ff 75 f4             	push   -0xc(%ebp)
8010786d:	e8 06 d3 ff ff       	call   80104b78 <memmove>
80107872:	83 c4 10             	add    $0x10,%esp
}
80107875:	90                   	nop
80107876:	c9                   	leave  
80107877:	c3                   	ret    

80107878 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107878:	55                   	push   %ebp
80107879:	89 e5                	mov    %esp,%ebp
8010787b:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010787e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107881:	25 ff 0f 00 00       	and    $0xfff,%eax
80107886:	85 c0                	test   %eax,%eax
80107888:	74 0d                	je     80107897 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010788a:	83 ec 0c             	sub    $0xc,%esp
8010788d:	68 30 a9 10 80       	push   $0x8010a930
80107892:	e8 12 8d ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107897:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010789e:	e9 8f 00 00 00       	jmp    80107932 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801078a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801078a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a9:	01 d0                	add    %edx,%eax
801078ab:	83 ec 04             	sub    $0x4,%esp
801078ae:	6a 00                	push   $0x0
801078b0:	50                   	push   %eax
801078b1:	ff 75 08             	push   0x8(%ebp)
801078b4:	e8 6d fb ff ff       	call   80107426 <walkpgdir>
801078b9:	83 c4 10             	add    $0x10,%esp
801078bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078c3:	75 0d                	jne    801078d2 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801078c5:	83 ec 0c             	sub    $0xc,%esp
801078c8:	68 53 a9 10 80       	push   $0x8010a953
801078cd:	e8 d7 8c ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801078d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078d5:	8b 00                	mov    (%eax),%eax
801078d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801078df:	8b 45 18             	mov    0x18(%ebp),%eax
801078e2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078e5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801078ea:	77 0b                	ja     801078f7 <loaduvm+0x7f>
      n = sz - i;
801078ec:	8b 45 18             	mov    0x18(%ebp),%eax
801078ef:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078f5:	eb 07                	jmp    801078fe <loaduvm+0x86>
    else
      n = PGSIZE;
801078f7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801078fe:	8b 55 14             	mov    0x14(%ebp),%edx
80107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107904:	01 d0                	add    %edx,%eax
80107906:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107909:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010790f:	ff 75 f0             	push   -0x10(%ebp)
80107912:	50                   	push   %eax
80107913:	52                   	push   %edx
80107914:	ff 75 10             	push   0x10(%ebp)
80107917:	e8 b0 a5 ff ff       	call   80101ecc <readi>
8010791c:	83 c4 10             	add    $0x10,%esp
8010791f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107922:	74 07                	je     8010792b <loaduvm+0xb3>
      return -1;
80107924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107929:	eb 18                	jmp    80107943 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
8010792b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107935:	3b 45 18             	cmp    0x18(%ebp),%eax
80107938:	0f 82 65 ff ff ff    	jb     801078a3 <loaduvm+0x2b>
  }
  return 0;
8010793e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107943:	c9                   	leave  
80107944:	c3                   	ret    

80107945 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107945:	55                   	push   %ebp
80107946:	89 e5                	mov    %esp,%ebp
80107948:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010794b:	8b 45 10             	mov    0x10(%ebp),%eax
8010794e:	85 c0                	test   %eax,%eax
80107950:	79 0a                	jns    8010795c <allocuvm+0x17>
    return 0;
80107952:	b8 00 00 00 00       	mov    $0x0,%eax
80107957:	e9 ec 00 00 00       	jmp    80107a48 <allocuvm+0x103>
  if(newsz < oldsz)
8010795c:	8b 45 10             	mov    0x10(%ebp),%eax
8010795f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107962:	73 08                	jae    8010796c <allocuvm+0x27>
    return oldsz;
80107964:	8b 45 0c             	mov    0xc(%ebp),%eax
80107967:	e9 dc 00 00 00       	jmp    80107a48 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
8010796c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010796f:	05 ff 0f 00 00       	add    $0xfff,%eax
80107974:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107979:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010797c:	e9 b8 00 00 00       	jmp    80107a39 <allocuvm+0xf4>
    mem = kalloc();
80107981:	e8 10 ae ff ff       	call   80102796 <kalloc>
80107986:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107989:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010798d:	75 2e                	jne    801079bd <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010798f:	83 ec 0c             	sub    $0xc,%esp
80107992:	68 71 a9 10 80       	push   $0x8010a971
80107997:	e8 58 8a ff ff       	call   801003f4 <cprintf>
8010799c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010799f:	83 ec 04             	sub    $0x4,%esp
801079a2:	ff 75 0c             	push   0xc(%ebp)
801079a5:	ff 75 10             	push   0x10(%ebp)
801079a8:	ff 75 08             	push   0x8(%ebp)
801079ab:	e8 9a 00 00 00       	call   80107a4a <deallocuvm>
801079b0:	83 c4 10             	add    $0x10,%esp
      return 0;
801079b3:	b8 00 00 00 00       	mov    $0x0,%eax
801079b8:	e9 8b 00 00 00       	jmp    80107a48 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801079bd:	83 ec 04             	sub    $0x4,%esp
801079c0:	68 00 10 00 00       	push   $0x1000
801079c5:	6a 00                	push   $0x0
801079c7:	ff 75 f0             	push   -0x10(%ebp)
801079ca:	e8 ea d0 ff ff       	call   80104ab9 <memset>
801079cf:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801079d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079d5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	83 ec 0c             	sub    $0xc,%esp
801079e1:	6a 06                	push   $0x6
801079e3:	52                   	push   %edx
801079e4:	68 00 10 00 00       	push   $0x1000
801079e9:	50                   	push   %eax
801079ea:	ff 75 08             	push   0x8(%ebp)
801079ed:	e8 ca fa ff ff       	call   801074bc <mappages>
801079f2:	83 c4 20             	add    $0x20,%esp
801079f5:	85 c0                	test   %eax,%eax
801079f7:	79 39                	jns    80107a32 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801079f9:	83 ec 0c             	sub    $0xc,%esp
801079fc:	68 89 a9 10 80       	push   $0x8010a989
80107a01:	e8 ee 89 ff ff       	call   801003f4 <cprintf>
80107a06:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107a09:	83 ec 04             	sub    $0x4,%esp
80107a0c:	ff 75 0c             	push   0xc(%ebp)
80107a0f:	ff 75 10             	push   0x10(%ebp)
80107a12:	ff 75 08             	push   0x8(%ebp)
80107a15:	e8 30 00 00 00       	call   80107a4a <deallocuvm>
80107a1a:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107a1d:	83 ec 0c             	sub    $0xc,%esp
80107a20:	ff 75 f0             	push   -0x10(%ebp)
80107a23:	e8 d4 ac ff ff       	call   801026fc <kfree>
80107a28:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a2b:	b8 00 00 00 00       	mov    $0x0,%eax
80107a30:	eb 16                	jmp    80107a48 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107a32:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3c:	3b 45 10             	cmp    0x10(%ebp),%eax
80107a3f:	0f 82 3c ff ff ff    	jb     80107981 <allocuvm+0x3c>
    }
  }
  return newsz;
80107a45:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a48:	c9                   	leave  
80107a49:	c3                   	ret    

80107a4a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a4a:	55                   	push   %ebp
80107a4b:	89 e5                	mov    %esp,%ebp
80107a4d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107a50:	8b 45 10             	mov    0x10(%ebp),%eax
80107a53:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a56:	72 08                	jb     80107a60 <deallocuvm+0x16>
    return oldsz;
80107a58:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a5b:	e9 ac 00 00 00       	jmp    80107b0c <deallocuvm+0xc2>
  a = PGROUNDUP(newsz);
80107a60:	8b 45 10             	mov    0x10(%ebp),%eax
80107a63:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  for(; a  < oldsz; a += PGSIZE){
80107a70:	e9 88 00 00 00       	jmp    80107afd <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a78:	83 ec 04             	sub    $0x4,%esp
80107a7b:	6a 00                	push   $0x0
80107a7d:	50                   	push   %eax
80107a7e:	ff 75 08             	push   0x8(%ebp)
80107a81:	e8 a0 f9 ff ff       	call   80107426 <walkpgdir>
80107a86:	83 c4 10             	add    $0x10,%esp
80107a89:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107a8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a90:	75 16                	jne    80107aa8 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a95:	c1 e8 16             	shr    $0x16,%eax
80107a98:	83 c0 01             	add    $0x1,%eax
80107a9b:	c1 e0 16             	shl    $0x16,%eax
80107a9e:	2d 00 10 00 00       	sub    $0x1000,%eax
80107aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107aa6:	eb 4e                	jmp    80107af6 <deallocuvm+0xac>
    else{
      if(*pte & PTE_P){
80107aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aab:	8b 00                	mov    (%eax),%eax
80107aad:	83 e0 01             	and    $0x1,%eax
80107ab0:	85 c0                	test   %eax,%eax
80107ab2:	74 39                	je     80107aed <deallocuvm+0xa3>
        pa = PTE_ADDR(*pte);
80107ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab7:	8b 00                	mov    (%eax),%eax
80107ab9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107abe:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (pa ==0)
80107ac1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ac5:	75 0d                	jne    80107ad4 <deallocuvm+0x8a>
          panic("kfree");
80107ac7:	83 ec 0c             	sub    $0xc,%esp
80107aca:	68 a5 a9 10 80       	push   $0x8010a9a5
80107acf:	e8 d5 8a ff ff       	call   801005a9 <panic>
        char *v = P2V(pa);
80107ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ad7:	05 00 00 00 80       	add    $0x80000000,%eax
80107adc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(v);
80107adf:	83 ec 0c             	sub    $0xc,%esp
80107ae2:	ff 75 e8             	push   -0x18(%ebp)
80107ae5:	e8 12 ac ff ff       	call   801026fc <kfree>
80107aea:	83 c4 10             	add    $0x10,%esp
      }
      *pte = 0;
80107aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107af0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107af6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b03:	0f 82 6c ff ff ff    	jb     80107a75 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107b09:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b0c:	c9                   	leave  
80107b0d:	c3                   	ret    

80107b0e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107b0e:	55                   	push   %ebp
80107b0f:	89 e5                	mov    %esp,%ebp
80107b11:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107b14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b18:	75 0d                	jne    80107b27 <freevm+0x19>
    panic("freevm: no pgdir");
80107b1a:	83 ec 0c             	sub    $0xc,%esp
80107b1d:	68 ab a9 10 80       	push   $0x8010a9ab
80107b22:	e8 82 8a ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107b27:	83 ec 04             	sub    $0x4,%esp
80107b2a:	6a 00                	push   $0x0
80107b2c:	68 00 00 00 80       	push   $0x80000000
80107b31:	ff 75 08             	push   0x8(%ebp)
80107b34:	e8 11 ff ff ff       	call   80107a4a <deallocuvm>
80107b39:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b43:	eb 48                	jmp    80107b8d <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b52:	01 d0                	add    %edx,%eax
80107b54:	8b 00                	mov    (%eax),%eax
80107b56:	83 e0 01             	and    $0x1,%eax
80107b59:	85 c0                	test   %eax,%eax
80107b5b:	74 2c                	je     80107b89 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b67:	8b 45 08             	mov    0x8(%ebp),%eax
80107b6a:	01 d0                	add    %edx,%eax
80107b6c:	8b 00                	mov    (%eax),%eax
80107b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b73:	05 00 00 00 80       	add    $0x80000000,%eax
80107b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107b7b:	83 ec 0c             	sub    $0xc,%esp
80107b7e:	ff 75 f0             	push   -0x10(%ebp)
80107b81:	e8 76 ab ff ff       	call   801026fc <kfree>
80107b86:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b89:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b8d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107b94:	76 af                	jbe    80107b45 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107b96:	83 ec 0c             	sub    $0xc,%esp
80107b99:	ff 75 08             	push   0x8(%ebp)
80107b9c:	e8 5b ab ff ff       	call   801026fc <kfree>
80107ba1:	83 c4 10             	add    $0x10,%esp
}
80107ba4:	90                   	nop
80107ba5:	c9                   	leave  
80107ba6:	c3                   	ret    

80107ba7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107ba7:	55                   	push   %ebp
80107ba8:	89 e5                	mov    %esp,%ebp
80107baa:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107bad:	83 ec 04             	sub    $0x4,%esp
80107bb0:	6a 00                	push   $0x0
80107bb2:	ff 75 0c             	push   0xc(%ebp)
80107bb5:	ff 75 08             	push   0x8(%ebp)
80107bb8:	e8 69 f8 ff ff       	call   80107426 <walkpgdir>
80107bbd:	83 c4 10             	add    $0x10,%esp
80107bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107bc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bc7:	75 0d                	jne    80107bd6 <clearpteu+0x2f>
    panic("clearpteu");
80107bc9:	83 ec 0c             	sub    $0xc,%esp
80107bcc:	68 bc a9 10 80       	push   $0x8010a9bc
80107bd1:	e8 d3 89 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd9:	8b 00                	mov    (%eax),%eax
80107bdb:	83 e0 fb             	and    $0xfffffffb,%eax
80107bde:	89 c2                	mov    %eax,%edx
80107be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be3:	89 10                	mov    %edx,(%eax)
}
80107be5:	90                   	nop
80107be6:	c9                   	leave  
80107be7:	c3                   	ret    

80107be8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107be8:	55                   	push   %ebp
80107be9:	89 e5                	mov    %esp,%ebp
80107beb:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107bee:	e8 59 f9 ff ff       	call   8010754c <setupkvm>
80107bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bf6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bfa:	75 0a                	jne    80107c06 <copyuvm+0x1e>
    return 0;
80107bfc:	b8 00 00 00 00       	mov    $0x0,%eax
80107c01:	e9 06 01 00 00       	jmp    80107d0c <copyuvm+0x124>
    
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107c06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c0d:	e9 d0 00 00 00       	jmp    80107ce2 <copyuvm+0xfa>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	83 ec 04             	sub    $0x4,%esp
80107c18:	6a 00                	push   $0x0
80107c1a:	50                   	push   %eax
80107c1b:	ff 75 08             	push   0x8(%ebp)
80107c1e:	e8 03 f8 ff ff       	call   80107426 <walkpgdir>
80107c23:	83 c4 10             	add    $0x10,%esp
80107c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c2d:	0f 84 a7 00 00 00    	je     80107cda <copyuvm+0xf2>
      continue;
    }
    if(!(*pte & PTE_P)){
80107c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c36:	8b 00                	mov    (%eax),%eax
80107c38:	83 e0 01             	and    $0x1,%eax
80107c3b:	85 c0                	test   %eax,%eax
80107c3d:	75 2c                	jne    80107c6b <copyuvm+0x83>
      pte_t *child_pte = walkpgdir(d , (void *)i, 1);
80107c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c42:	83 ec 04             	sub    $0x4,%esp
80107c45:	6a 01                	push   $0x1
80107c47:	50                   	push   %eax
80107c48:	ff 75 f0             	push   -0x10(%ebp)
80107c4b:	e8 d6 f7 ff ff       	call   80107426 <walkpgdir>
80107c50:	83 c4 10             	add    $0x10,%esp
80107c53:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (child_pte ==0)
80107c56:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80107c5a:	0f 84 92 00 00 00    	je     80107cf2 <copyuvm+0x10a>
        goto bad;
      *child_pte = 0;
80107c60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107c63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      continue;
80107c69:	eb 70                	jmp    80107cdb <copyuvm+0xf3>
    }
    pa = PTE_ADDR(*pte);
80107c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c6e:	8b 00                	mov    (%eax),%eax
80107c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c75:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c7b:	8b 00                	mov    (%eax),%eax
80107c7d:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107c85:	e8 0c ab ff ff       	call   80102796 <kalloc>
80107c8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107c91:	74 62                	je     80107cf5 <copyuvm+0x10d>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107c93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c96:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9b:	83 ec 04             	sub    $0x4,%esp
80107c9e:	68 00 10 00 00       	push   $0x1000
80107ca3:	50                   	push   %eax
80107ca4:	ff 75 e0             	push   -0x20(%ebp)
80107ca7:	e8 cc ce ff ff       	call   80104b78 <memmove>
80107cac:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107caf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cb5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	83 ec 0c             	sub    $0xc,%esp
80107cc1:	52                   	push   %edx
80107cc2:	51                   	push   %ecx
80107cc3:	68 00 10 00 00       	push   $0x1000
80107cc8:	50                   	push   %eax
80107cc9:	ff 75 f0             	push   -0x10(%ebp)
80107ccc:	e8 eb f7 ff ff       	call   801074bc <mappages>
80107cd1:	83 c4 20             	add    $0x20,%esp
80107cd4:	85 c0                	test   %eax,%eax
80107cd6:	78 20                	js     80107cf8 <copyuvm+0x110>
80107cd8:	eb 01                	jmp    80107cdb <copyuvm+0xf3>
      continue;
80107cda:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107cdb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce5:	85 c0                	test   %eax,%eax
80107ce7:	0f 89 25 ff ff ff    	jns    80107c12 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf0:	eb 1a                	jmp    80107d0c <copyuvm+0x124>
        goto bad;
80107cf2:	90                   	nop
80107cf3:	eb 04                	jmp    80107cf9 <copyuvm+0x111>
      goto bad;
80107cf5:	90                   	nop
80107cf6:	eb 01                	jmp    80107cf9 <copyuvm+0x111>
      goto bad;
80107cf8:	90                   	nop

bad:
  freevm(d);
80107cf9:	83 ec 0c             	sub    $0xc,%esp
80107cfc:	ff 75 f0             	push   -0x10(%ebp)
80107cff:	e8 0a fe ff ff       	call   80107b0e <freevm>
80107d04:	83 c4 10             	add    $0x10,%esp
  return 0;
80107d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d0c:	c9                   	leave  
80107d0d:	c3                   	ret    

80107d0e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107d0e:	55                   	push   %ebp
80107d0f:	89 e5                	mov    %esp,%ebp
80107d11:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d14:	83 ec 04             	sub    $0x4,%esp
80107d17:	6a 00                	push   $0x0
80107d19:	ff 75 0c             	push   0xc(%ebp)
80107d1c:	ff 75 08             	push   0x8(%ebp)
80107d1f:	e8 02 f7 ff ff       	call   80107426 <walkpgdir>
80107d24:	83 c4 10             	add    $0x10,%esp
80107d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	8b 00                	mov    (%eax),%eax
80107d2f:	83 e0 01             	and    $0x1,%eax
80107d32:	85 c0                	test   %eax,%eax
80107d34:	75 07                	jne    80107d3d <uva2ka+0x2f>
    return 0;
80107d36:	b8 00 00 00 00       	mov    $0x0,%eax
80107d3b:	eb 22                	jmp    80107d5f <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d40:	8b 00                	mov    (%eax),%eax
80107d42:	83 e0 04             	and    $0x4,%eax
80107d45:	85 c0                	test   %eax,%eax
80107d47:	75 07                	jne    80107d50 <uva2ka+0x42>
    return 0;
80107d49:	b8 00 00 00 00       	mov    $0x0,%eax
80107d4e:	eb 0f                	jmp    80107d5f <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d53:	8b 00                	mov    (%eax),%eax
80107d55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d5a:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107d5f:	c9                   	leave  
80107d60:	c3                   	ret    

80107d61 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107d61:	55                   	push   %ebp
80107d62:	89 e5                	mov    %esp,%ebp
80107d64:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107d67:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107d6d:	eb 7f                	jmp    80107dee <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d77:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d7d:	83 ec 08             	sub    $0x8,%esp
80107d80:	50                   	push   %eax
80107d81:	ff 75 08             	push   0x8(%ebp)
80107d84:	e8 85 ff ff ff       	call   80107d0e <uva2ka>
80107d89:	83 c4 10             	add    $0x10,%esp
80107d8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107d8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107d93:	75 07                	jne    80107d9c <copyout+0x3b>
      return -1;
80107d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d9a:	eb 61                	jmp    80107dfd <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9f:	2b 45 0c             	sub    0xc(%ebp),%eax
80107da2:	05 00 10 00 00       	add    $0x1000,%eax
80107da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107daa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dad:	3b 45 14             	cmp    0x14(%ebp),%eax
80107db0:	76 06                	jbe    80107db8 <copyout+0x57>
      n = len;
80107db2:	8b 45 14             	mov    0x14(%ebp),%eax
80107db5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dbb:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107dbe:	89 c2                	mov    %eax,%edx
80107dc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107dc3:	01 d0                	add    %edx,%eax
80107dc5:	83 ec 04             	sub    $0x4,%esp
80107dc8:	ff 75 f0             	push   -0x10(%ebp)
80107dcb:	ff 75 f4             	push   -0xc(%ebp)
80107dce:	50                   	push   %eax
80107dcf:	e8 a4 cd ff ff       	call   80104b78 <memmove>
80107dd4:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dda:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107de6:	05 00 10 00 00       	add    $0x1000,%eax
80107deb:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107dee:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107df2:	0f 85 77 ff ff ff    	jne    80107d6f <copyout+0xe>
  }
  return 0;
80107df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dfd:	c9                   	leave  
80107dfe:	c3                   	ret    

80107dff <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107dff:	55                   	push   %ebp
80107e00:	89 e5                	mov    %esp,%ebp
80107e02:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e05:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107e0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e0f:	8b 40 08             	mov    0x8(%eax),%eax
80107e12:	05 00 00 00 80       	add    $0x80000000,%eax
80107e17:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107e1a:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e24:	8b 40 24             	mov    0x24(%eax),%eax
80107e27:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107e2c:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107e33:	00 00 00 

  while(i<madt->len){
80107e36:	90                   	nop
80107e37:	e9 bd 00 00 00       	jmp    80107ef9 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107e3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e42:	01 d0                	add    %edx,%eax
80107e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4a:	0f b6 00             	movzbl (%eax),%eax
80107e4d:	0f b6 c0             	movzbl %al,%eax
80107e50:	83 f8 05             	cmp    $0x5,%eax
80107e53:	0f 87 a0 00 00 00    	ja     80107ef9 <mpinit_uefi+0xfa>
80107e59:	8b 04 85 c8 a9 10 80 	mov    -0x7fef5638(,%eax,4),%eax
80107e60:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107e68:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107e6d:	83 f8 03             	cmp    $0x3,%eax
80107e70:	7f 28                	jg     80107e9a <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107e72:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e7b:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107e7f:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107e85:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107e8b:	88 02                	mov    %al,(%edx)
          ncpu++;
80107e8d:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107e92:	83 c0 01             	add    $0x1,%eax
80107e95:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107e9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e9d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ea1:	0f b6 c0             	movzbl %al,%eax
80107ea4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ea7:	eb 50                	jmp    80107ef9 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107eb2:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107eb6:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107ebb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ebe:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ec2:	0f b6 c0             	movzbl %al,%eax
80107ec5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ec8:	eb 2f                	jmp    80107ef9 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ecd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107ed0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ed3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ed7:	0f b6 c0             	movzbl %al,%eax
80107eda:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107edd:	eb 1a                	jmp    80107ef9 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107eec:	0f b6 c0             	movzbl %al,%eax
80107eef:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ef2:	eb 05                	jmp    80107ef9 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107ef4:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107ef8:	90                   	nop
  while(i<madt->len){
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	8b 40 04             	mov    0x4(%eax),%eax
80107eff:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107f02:	0f 82 34 ff ff ff    	jb     80107e3c <mpinit_uefi+0x3d>
    }
  }

}
80107f08:	90                   	nop
80107f09:	90                   	nop
80107f0a:	c9                   	leave  
80107f0b:	c3                   	ret    

80107f0c <inb>:
{
80107f0c:	55                   	push   %ebp
80107f0d:	89 e5                	mov    %esp,%ebp
80107f0f:	83 ec 14             	sub    $0x14,%esp
80107f12:	8b 45 08             	mov    0x8(%ebp),%eax
80107f15:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107f19:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107f1d:	89 c2                	mov    %eax,%edx
80107f1f:	ec                   	in     (%dx),%al
80107f20:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107f23:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107f27:	c9                   	leave  
80107f28:	c3                   	ret    

80107f29 <outb>:
{
80107f29:	55                   	push   %ebp
80107f2a:	89 e5                	mov    %esp,%ebp
80107f2c:	83 ec 08             	sub    $0x8,%esp
80107f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f32:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f35:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107f39:	89 d0                	mov    %edx,%eax
80107f3b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107f3e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107f42:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107f46:	ee                   	out    %al,(%dx)
}
80107f47:	90                   	nop
80107f48:	c9                   	leave  
80107f49:	c3                   	ret    

80107f4a <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107f4a:	55                   	push   %ebp
80107f4b:	89 e5                	mov    %esp,%ebp
80107f4d:	83 ec 28             	sub    $0x28,%esp
80107f50:	8b 45 08             	mov    0x8(%ebp),%eax
80107f53:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107f56:	6a 00                	push   $0x0
80107f58:	68 fa 03 00 00       	push   $0x3fa
80107f5d:	e8 c7 ff ff ff       	call   80107f29 <outb>
80107f62:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107f65:	68 80 00 00 00       	push   $0x80
80107f6a:	68 fb 03 00 00       	push   $0x3fb
80107f6f:	e8 b5 ff ff ff       	call   80107f29 <outb>
80107f74:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107f77:	6a 0c                	push   $0xc
80107f79:	68 f8 03 00 00       	push   $0x3f8
80107f7e:	e8 a6 ff ff ff       	call   80107f29 <outb>
80107f83:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107f86:	6a 00                	push   $0x0
80107f88:	68 f9 03 00 00       	push   $0x3f9
80107f8d:	e8 97 ff ff ff       	call   80107f29 <outb>
80107f92:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107f95:	6a 03                	push   $0x3
80107f97:	68 fb 03 00 00       	push   $0x3fb
80107f9c:	e8 88 ff ff ff       	call   80107f29 <outb>
80107fa1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107fa4:	6a 00                	push   $0x0
80107fa6:	68 fc 03 00 00       	push   $0x3fc
80107fab:	e8 79 ff ff ff       	call   80107f29 <outb>
80107fb0:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fba:	eb 11                	jmp    80107fcd <uart_debug+0x83>
80107fbc:	83 ec 0c             	sub    $0xc,%esp
80107fbf:	6a 0a                	push   $0xa
80107fc1:	e8 67 ab ff ff       	call   80102b2d <microdelay>
80107fc6:	83 c4 10             	add    $0x10,%esp
80107fc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fcd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107fd1:	7f 1a                	jg     80107fed <uart_debug+0xa3>
80107fd3:	83 ec 0c             	sub    $0xc,%esp
80107fd6:	68 fd 03 00 00       	push   $0x3fd
80107fdb:	e8 2c ff ff ff       	call   80107f0c <inb>
80107fe0:	83 c4 10             	add    $0x10,%esp
80107fe3:	0f b6 c0             	movzbl %al,%eax
80107fe6:	83 e0 20             	and    $0x20,%eax
80107fe9:	85 c0                	test   %eax,%eax
80107feb:	74 cf                	je     80107fbc <uart_debug+0x72>
  outb(COM1+0, p);
80107fed:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107ff1:	0f b6 c0             	movzbl %al,%eax
80107ff4:	83 ec 08             	sub    $0x8,%esp
80107ff7:	50                   	push   %eax
80107ff8:	68 f8 03 00 00       	push   $0x3f8
80107ffd:	e8 27 ff ff ff       	call   80107f29 <outb>
80108002:	83 c4 10             	add    $0x10,%esp
}
80108005:	90                   	nop
80108006:	c9                   	leave  
80108007:	c3                   	ret    

80108008 <uart_debugs>:

void uart_debugs(char *p){
80108008:	55                   	push   %ebp
80108009:	89 e5                	mov    %esp,%ebp
8010800b:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010800e:	eb 1b                	jmp    8010802b <uart_debugs+0x23>
    uart_debug(*p++);
80108010:	8b 45 08             	mov    0x8(%ebp),%eax
80108013:	8d 50 01             	lea    0x1(%eax),%edx
80108016:	89 55 08             	mov    %edx,0x8(%ebp)
80108019:	0f b6 00             	movzbl (%eax),%eax
8010801c:	0f be c0             	movsbl %al,%eax
8010801f:	83 ec 0c             	sub    $0xc,%esp
80108022:	50                   	push   %eax
80108023:	e8 22 ff ff ff       	call   80107f4a <uart_debug>
80108028:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010802b:	8b 45 08             	mov    0x8(%ebp),%eax
8010802e:	0f b6 00             	movzbl (%eax),%eax
80108031:	84 c0                	test   %al,%al
80108033:	75 db                	jne    80108010 <uart_debugs+0x8>
  }
}
80108035:	90                   	nop
80108036:	90                   	nop
80108037:	c9                   	leave  
80108038:	c3                   	ret    

80108039 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108039:	55                   	push   %ebp
8010803a:	89 e5                	mov    %esp,%ebp
8010803c:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010803f:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108046:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108049:	8b 50 14             	mov    0x14(%eax),%edx
8010804c:	8b 40 10             	mov    0x10(%eax),%eax
8010804f:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108054:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108057:	8b 50 1c             	mov    0x1c(%eax),%edx
8010805a:	8b 40 18             	mov    0x18(%eax),%eax
8010805d:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108062:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80108068:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010806d:	29 d0                	sub    %edx,%eax
8010806f:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108074:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108077:	8b 50 24             	mov    0x24(%eax),%edx
8010807a:	8b 40 20             	mov    0x20(%eax),%eax
8010807d:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108082:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108085:	8b 50 2c             	mov    0x2c(%eax),%edx
80108088:	8b 40 28             	mov    0x28(%eax),%eax
8010808b:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108090:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108093:	8b 50 34             	mov    0x34(%eax),%edx
80108096:	8b 40 30             	mov    0x30(%eax),%eax
80108099:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
8010809e:	90                   	nop
8010809f:	c9                   	leave  
801080a0:	c3                   	ret    

801080a1 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801080a1:	55                   	push   %ebp
801080a2:	89 e5                	mov    %esp,%ebp
801080a4:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801080a7:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
801080ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b0:	0f af d0             	imul   %eax,%edx
801080b3:	8b 45 08             	mov    0x8(%ebp),%eax
801080b6:	01 d0                	add    %edx,%eax
801080b8:	c1 e0 02             	shl    $0x2,%eax
801080bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801080be:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
801080c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c7:	01 d0                	add    %edx,%eax
801080c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801080cc:	8b 45 10             	mov    0x10(%ebp),%eax
801080cf:	0f b6 10             	movzbl (%eax),%edx
801080d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080d5:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801080d7:	8b 45 10             	mov    0x10(%ebp),%eax
801080da:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801080de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080e1:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801080e4:	8b 45 10             	mov    0x10(%ebp),%eax
801080e7:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801080eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080ee:	88 50 02             	mov    %dl,0x2(%eax)
}
801080f1:	90                   	nop
801080f2:	c9                   	leave  
801080f3:	c3                   	ret    

801080f4 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801080f4:	55                   	push   %ebp
801080f5:	89 e5                	mov    %esp,%ebp
801080f7:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801080fa:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80108100:	8b 45 08             	mov    0x8(%ebp),%eax
80108103:	0f af c2             	imul   %edx,%eax
80108106:	c1 e0 02             	shl    $0x2,%eax
80108109:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010810c:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80108111:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108114:	29 d0                	sub    %edx,%eax
80108116:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
8010811c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010811f:	01 ca                	add    %ecx,%edx
80108121:	89 d1                	mov    %edx,%ecx
80108123:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80108129:	83 ec 04             	sub    $0x4,%esp
8010812c:	50                   	push   %eax
8010812d:	51                   	push   %ecx
8010812e:	52                   	push   %edx
8010812f:	e8 44 ca ff ff       	call   80104b78 <memmove>
80108134:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813a:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80108140:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80108146:	01 ca                	add    %ecx,%edx
80108148:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010814b:	29 ca                	sub    %ecx,%edx
8010814d:	83 ec 04             	sub    $0x4,%esp
80108150:	50                   	push   %eax
80108151:	6a 00                	push   $0x0
80108153:	52                   	push   %edx
80108154:	e8 60 c9 ff ff       	call   80104ab9 <memset>
80108159:	83 c4 10             	add    $0x10,%esp
}
8010815c:	90                   	nop
8010815d:	c9                   	leave  
8010815e:	c3                   	ret    

8010815f <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010815f:	55                   	push   %ebp
80108160:	89 e5                	mov    %esp,%ebp
80108162:	53                   	push   %ebx
80108163:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010816d:	e9 b1 00 00 00       	jmp    80108223 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108172:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108179:	e9 97 00 00 00       	jmp    80108215 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010817e:	8b 45 10             	mov    0x10(%ebp),%eax
80108181:	83 e8 20             	sub    $0x20,%eax
80108184:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818a:	01 d0                	add    %edx,%eax
8010818c:	0f b7 84 00 e0 a9 10 	movzwl -0x7fef5620(%eax,%eax,1),%eax
80108193:	80 
80108194:	0f b7 d0             	movzwl %ax,%edx
80108197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010819a:	bb 01 00 00 00       	mov    $0x1,%ebx
8010819f:	89 c1                	mov    %eax,%ecx
801081a1:	d3 e3                	shl    %cl,%ebx
801081a3:	89 d8                	mov    %ebx,%eax
801081a5:	21 d0                	and    %edx,%eax
801081a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801081aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ad:	ba 01 00 00 00       	mov    $0x1,%edx
801081b2:	89 c1                	mov    %eax,%ecx
801081b4:	d3 e2                	shl    %cl,%edx
801081b6:	89 d0                	mov    %edx,%eax
801081b8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801081bb:	75 2b                	jne    801081e8 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801081bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801081c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c3:	01 c2                	add    %eax,%edx
801081c5:	b8 0e 00 00 00       	mov    $0xe,%eax
801081ca:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081cd:	89 c1                	mov    %eax,%ecx
801081cf:	8b 45 08             	mov    0x8(%ebp),%eax
801081d2:	01 c8                	add    %ecx,%eax
801081d4:	83 ec 04             	sub    $0x4,%esp
801081d7:	68 e0 f4 10 80       	push   $0x8010f4e0
801081dc:	52                   	push   %edx
801081dd:	50                   	push   %eax
801081de:	e8 be fe ff ff       	call   801080a1 <graphic_draw_pixel>
801081e3:	83 c4 10             	add    $0x10,%esp
801081e6:	eb 29                	jmp    80108211 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801081e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801081eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ee:	01 c2                	add    %eax,%edx
801081f0:	b8 0e 00 00 00       	mov    $0xe,%eax
801081f5:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081f8:	89 c1                	mov    %eax,%ecx
801081fa:	8b 45 08             	mov    0x8(%ebp),%eax
801081fd:	01 c8                	add    %ecx,%eax
801081ff:	83 ec 04             	sub    $0x4,%esp
80108202:	68 60 6c 19 80       	push   $0x80196c60
80108207:	52                   	push   %edx
80108208:	50                   	push   %eax
80108209:	e8 93 fe ff ff       	call   801080a1 <graphic_draw_pixel>
8010820e:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108211:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108219:	0f 89 5f ff ff ff    	jns    8010817e <font_render+0x1f>
  for(int i=0;i<30;i++){
8010821f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108223:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108227:	0f 8e 45 ff ff ff    	jle    80108172 <font_render+0x13>
      }
    }
  }
}
8010822d:	90                   	nop
8010822e:	90                   	nop
8010822f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108232:	c9                   	leave  
80108233:	c3                   	ret    

80108234 <font_render_string>:

void font_render_string(char *string,int row){
80108234:	55                   	push   %ebp
80108235:	89 e5                	mov    %esp,%ebp
80108237:	53                   	push   %ebx
80108238:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010823b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108242:	eb 33                	jmp    80108277 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108244:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108247:	8b 45 08             	mov    0x8(%ebp),%eax
8010824a:	01 d0                	add    %edx,%eax
8010824c:	0f b6 00             	movzbl (%eax),%eax
8010824f:	0f be c8             	movsbl %al,%ecx
80108252:	8b 45 0c             	mov    0xc(%ebp),%eax
80108255:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108258:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010825b:	89 d8                	mov    %ebx,%eax
8010825d:	c1 e0 04             	shl    $0x4,%eax
80108260:	29 d8                	sub    %ebx,%eax
80108262:	83 c0 02             	add    $0x2,%eax
80108265:	83 ec 04             	sub    $0x4,%esp
80108268:	51                   	push   %ecx
80108269:	52                   	push   %edx
8010826a:	50                   	push   %eax
8010826b:	e8 ef fe ff ff       	call   8010815f <font_render>
80108270:	83 c4 10             	add    $0x10,%esp
    i++;
80108273:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108277:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010827a:	8b 45 08             	mov    0x8(%ebp),%eax
8010827d:	01 d0                	add    %edx,%eax
8010827f:	0f b6 00             	movzbl (%eax),%eax
80108282:	84 c0                	test   %al,%al
80108284:	74 06                	je     8010828c <font_render_string+0x58>
80108286:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010828a:	7e b8                	jle    80108244 <font_render_string+0x10>
  }
}
8010828c:	90                   	nop
8010828d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108290:	c9                   	leave  
80108291:	c3                   	ret    

80108292 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108292:	55                   	push   %ebp
80108293:	89 e5                	mov    %esp,%ebp
80108295:	53                   	push   %ebx
80108296:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108299:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082a0:	eb 6b                	jmp    8010830d <pci_init+0x7b>
    for(int j=0;j<32;j++){
801082a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801082a9:	eb 58                	jmp    80108303 <pci_init+0x71>
      for(int k=0;k<8;k++){
801082ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801082b2:	eb 45                	jmp    801082f9 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801082b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bd:	83 ec 0c             	sub    $0xc,%esp
801082c0:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801082c3:	53                   	push   %ebx
801082c4:	6a 00                	push   $0x0
801082c6:	51                   	push   %ecx
801082c7:	52                   	push   %edx
801082c8:	50                   	push   %eax
801082c9:	e8 b0 00 00 00       	call   8010837e <pci_access_config>
801082ce:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801082d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082d4:	0f b7 c0             	movzwl %ax,%eax
801082d7:	3d ff ff 00 00       	cmp    $0xffff,%eax
801082dc:	74 17                	je     801082f5 <pci_init+0x63>
        pci_init_device(i,j,k);
801082de:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e7:	83 ec 04             	sub    $0x4,%esp
801082ea:	51                   	push   %ecx
801082eb:	52                   	push   %edx
801082ec:	50                   	push   %eax
801082ed:	e8 37 01 00 00       	call   80108429 <pci_init_device>
801082f2:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801082f5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801082f9:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801082fd:	7e b5                	jle    801082b4 <pci_init+0x22>
    for(int j=0;j<32;j++){
801082ff:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108303:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108307:	7e a2                	jle    801082ab <pci_init+0x19>
  for(int i=0;i<256;i++){
80108309:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010830d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108314:	7e 8c                	jle    801082a2 <pci_init+0x10>
      }
      }
    }
  }
}
80108316:	90                   	nop
80108317:	90                   	nop
80108318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010831b:	c9                   	leave  
8010831c:	c3                   	ret    

8010831d <pci_write_config>:

void pci_write_config(uint config){
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108320:	8b 45 08             	mov    0x8(%ebp),%eax
80108323:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108328:	89 c0                	mov    %eax,%eax
8010832a:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010832b:	90                   	nop
8010832c:	5d                   	pop    %ebp
8010832d:	c3                   	ret    

8010832e <pci_write_data>:

void pci_write_data(uint config){
8010832e:	55                   	push   %ebp
8010832f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108331:	8b 45 08             	mov    0x8(%ebp),%eax
80108334:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108339:	89 c0                	mov    %eax,%eax
8010833b:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010833c:	90                   	nop
8010833d:	5d                   	pop    %ebp
8010833e:	c3                   	ret    

8010833f <pci_read_config>:
uint pci_read_config(){
8010833f:	55                   	push   %ebp
80108340:	89 e5                	mov    %esp,%ebp
80108342:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108345:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010834a:	ed                   	in     (%dx),%eax
8010834b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010834e:	83 ec 0c             	sub    $0xc,%esp
80108351:	68 c8 00 00 00       	push   $0xc8
80108356:	e8 d2 a7 ff ff       	call   80102b2d <microdelay>
8010835b:	83 c4 10             	add    $0x10,%esp
  return data;
8010835e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108361:	c9                   	leave  
80108362:	c3                   	ret    

80108363 <pci_test>:


void pci_test(){
80108363:	55                   	push   %ebp
80108364:	89 e5                	mov    %esp,%ebp
80108366:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108369:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108370:	ff 75 fc             	push   -0x4(%ebp)
80108373:	e8 a5 ff ff ff       	call   8010831d <pci_write_config>
80108378:	83 c4 04             	add    $0x4,%esp
}
8010837b:	90                   	nop
8010837c:	c9                   	leave  
8010837d:	c3                   	ret    

8010837e <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010837e:	55                   	push   %ebp
8010837f:	89 e5                	mov    %esp,%ebp
80108381:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108384:	8b 45 08             	mov    0x8(%ebp),%eax
80108387:	c1 e0 10             	shl    $0x10,%eax
8010838a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010838f:	89 c2                	mov    %eax,%edx
80108391:	8b 45 0c             	mov    0xc(%ebp),%eax
80108394:	c1 e0 0b             	shl    $0xb,%eax
80108397:	0f b7 c0             	movzwl %ax,%eax
8010839a:	09 c2                	or     %eax,%edx
8010839c:	8b 45 10             	mov    0x10(%ebp),%eax
8010839f:	c1 e0 08             	shl    $0x8,%eax
801083a2:	25 00 07 00 00       	and    $0x700,%eax
801083a7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083a9:	8b 45 14             	mov    0x14(%ebp),%eax
801083ac:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083b1:	09 d0                	or     %edx,%eax
801083b3:	0d 00 00 00 80       	or     $0x80000000,%eax
801083b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801083bb:	ff 75 f4             	push   -0xc(%ebp)
801083be:	e8 5a ff ff ff       	call   8010831d <pci_write_config>
801083c3:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801083c6:	e8 74 ff ff ff       	call   8010833f <pci_read_config>
801083cb:	8b 55 18             	mov    0x18(%ebp),%edx
801083ce:	89 02                	mov    %eax,(%edx)
}
801083d0:	90                   	nop
801083d1:	c9                   	leave  
801083d2:	c3                   	ret    

801083d3 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801083d3:	55                   	push   %ebp
801083d4:	89 e5                	mov    %esp,%ebp
801083d6:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083d9:	8b 45 08             	mov    0x8(%ebp),%eax
801083dc:	c1 e0 10             	shl    $0x10,%eax
801083df:	25 00 00 ff 00       	and    $0xff0000,%eax
801083e4:	89 c2                	mov    %eax,%edx
801083e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e9:	c1 e0 0b             	shl    $0xb,%eax
801083ec:	0f b7 c0             	movzwl %ax,%eax
801083ef:	09 c2                	or     %eax,%edx
801083f1:	8b 45 10             	mov    0x10(%ebp),%eax
801083f4:	c1 e0 08             	shl    $0x8,%eax
801083f7:	25 00 07 00 00       	and    $0x700,%eax
801083fc:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083fe:	8b 45 14             	mov    0x14(%ebp),%eax
80108401:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108406:	09 d0                	or     %edx,%eax
80108408:	0d 00 00 00 80       	or     $0x80000000,%eax
8010840d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108410:	ff 75 fc             	push   -0x4(%ebp)
80108413:	e8 05 ff ff ff       	call   8010831d <pci_write_config>
80108418:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010841b:	ff 75 18             	push   0x18(%ebp)
8010841e:	e8 0b ff ff ff       	call   8010832e <pci_write_data>
80108423:	83 c4 04             	add    $0x4,%esp
}
80108426:	90                   	nop
80108427:	c9                   	leave  
80108428:	c3                   	ret    

80108429 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108429:	55                   	push   %ebp
8010842a:	89 e5                	mov    %esp,%ebp
8010842c:	53                   	push   %ebx
8010842d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108430:	8b 45 08             	mov    0x8(%ebp),%eax
80108433:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
80108438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010843b:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
80108440:	8b 45 10             	mov    0x10(%ebp),%eax
80108443:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108448:	ff 75 10             	push   0x10(%ebp)
8010844b:	ff 75 0c             	push   0xc(%ebp)
8010844e:	ff 75 08             	push   0x8(%ebp)
80108451:	68 24 c0 10 80       	push   $0x8010c024
80108456:	e8 99 7f ff ff       	call   801003f4 <cprintf>
8010845b:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010845e:	83 ec 0c             	sub    $0xc,%esp
80108461:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108464:	50                   	push   %eax
80108465:	6a 00                	push   $0x0
80108467:	ff 75 10             	push   0x10(%ebp)
8010846a:	ff 75 0c             	push   0xc(%ebp)
8010846d:	ff 75 08             	push   0x8(%ebp)
80108470:	e8 09 ff ff ff       	call   8010837e <pci_access_config>
80108475:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108478:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847b:	c1 e8 10             	shr    $0x10,%eax
8010847e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108481:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108484:	25 ff ff 00 00       	and    $0xffff,%eax
80108489:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
80108494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108497:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010849c:	83 ec 04             	sub    $0x4,%esp
8010849f:	ff 75 f0             	push   -0x10(%ebp)
801084a2:	ff 75 f4             	push   -0xc(%ebp)
801084a5:	68 58 c0 10 80       	push   $0x8010c058
801084aa:	e8 45 7f ff ff       	call   801003f4 <cprintf>
801084af:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801084b2:	83 ec 0c             	sub    $0xc,%esp
801084b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084b8:	50                   	push   %eax
801084b9:	6a 08                	push   $0x8
801084bb:	ff 75 10             	push   0x10(%ebp)
801084be:	ff 75 0c             	push   0xc(%ebp)
801084c1:	ff 75 08             	push   0x8(%ebp)
801084c4:	e8 b5 fe ff ff       	call   8010837e <pci_access_config>
801084c9:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084cf:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084d5:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084d8:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084de:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084e1:	0f b6 c0             	movzbl %al,%eax
801084e4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084e7:	c1 eb 18             	shr    $0x18,%ebx
801084ea:	83 ec 0c             	sub    $0xc,%esp
801084ed:	51                   	push   %ecx
801084ee:	52                   	push   %edx
801084ef:	50                   	push   %eax
801084f0:	53                   	push   %ebx
801084f1:	68 7c c0 10 80       	push   $0x8010c07c
801084f6:	e8 f9 7e ff ff       	call   801003f4 <cprintf>
801084fb:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801084fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108501:	c1 e8 18             	shr    $0x18,%eax
80108504:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
80108509:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850c:	c1 e8 10             	shr    $0x10,%eax
8010850f:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
80108514:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108517:	c1 e8 08             	shr    $0x8,%eax
8010851a:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
8010851f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108522:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108527:	83 ec 0c             	sub    $0xc,%esp
8010852a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010852d:	50                   	push   %eax
8010852e:	6a 10                	push   $0x10
80108530:	ff 75 10             	push   0x10(%ebp)
80108533:	ff 75 0c             	push   0xc(%ebp)
80108536:	ff 75 08             	push   0x8(%ebp)
80108539:	e8 40 fe ff ff       	call   8010837e <pci_access_config>
8010853e:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108541:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108544:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108549:	83 ec 0c             	sub    $0xc,%esp
8010854c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010854f:	50                   	push   %eax
80108550:	6a 14                	push   $0x14
80108552:	ff 75 10             	push   0x10(%ebp)
80108555:	ff 75 0c             	push   0xc(%ebp)
80108558:	ff 75 08             	push   0x8(%ebp)
8010855b:	e8 1e fe ff ff       	call   8010837e <pci_access_config>
80108560:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108563:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108566:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010856b:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108572:	75 5a                	jne    801085ce <pci_init_device+0x1a5>
80108574:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010857b:	75 51                	jne    801085ce <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
8010857d:	83 ec 0c             	sub    $0xc,%esp
80108580:	68 c1 c0 10 80       	push   $0x8010c0c1
80108585:	e8 6a 7e ff ff       	call   801003f4 <cprintf>
8010858a:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010858d:	83 ec 0c             	sub    $0xc,%esp
80108590:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108593:	50                   	push   %eax
80108594:	68 f0 00 00 00       	push   $0xf0
80108599:	ff 75 10             	push   0x10(%ebp)
8010859c:	ff 75 0c             	push   0xc(%ebp)
8010859f:	ff 75 08             	push   0x8(%ebp)
801085a2:	e8 d7 fd ff ff       	call   8010837e <pci_access_config>
801085a7:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801085aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ad:	83 ec 08             	sub    $0x8,%esp
801085b0:	50                   	push   %eax
801085b1:	68 db c0 10 80       	push   $0x8010c0db
801085b6:	e8 39 7e ff ff       	call   801003f4 <cprintf>
801085bb:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801085be:	83 ec 0c             	sub    $0xc,%esp
801085c1:	68 64 6c 19 80       	push   $0x80196c64
801085c6:	e8 09 00 00 00       	call   801085d4 <i8254_init>
801085cb:	83 c4 10             	add    $0x10,%esp
  }
}
801085ce:	90                   	nop
801085cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085d2:	c9                   	leave  
801085d3:	c3                   	ret    

801085d4 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801085d4:	55                   	push   %ebp
801085d5:	89 e5                	mov    %esp,%ebp
801085d7:	53                   	push   %ebx
801085d8:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801085db:	8b 45 08             	mov    0x8(%ebp),%eax
801085de:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801085e2:	0f b6 c8             	movzbl %al,%ecx
801085e5:	8b 45 08             	mov    0x8(%ebp),%eax
801085e8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085ec:	0f b6 d0             	movzbl %al,%edx
801085ef:	8b 45 08             	mov    0x8(%ebp),%eax
801085f2:	0f b6 00             	movzbl (%eax),%eax
801085f5:	0f b6 c0             	movzbl %al,%eax
801085f8:	83 ec 0c             	sub    $0xc,%esp
801085fb:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801085fe:	53                   	push   %ebx
801085ff:	6a 04                	push   $0x4
80108601:	51                   	push   %ecx
80108602:	52                   	push   %edx
80108603:	50                   	push   %eax
80108604:	e8 75 fd ff ff       	call   8010837e <pci_access_config>
80108609:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010860c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860f:	83 c8 04             	or     $0x4,%eax
80108612:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108615:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108618:	8b 45 08             	mov    0x8(%ebp),%eax
8010861b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010861f:	0f b6 c8             	movzbl %al,%ecx
80108622:	8b 45 08             	mov    0x8(%ebp),%eax
80108625:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108629:	0f b6 d0             	movzbl %al,%edx
8010862c:	8b 45 08             	mov    0x8(%ebp),%eax
8010862f:	0f b6 00             	movzbl (%eax),%eax
80108632:	0f b6 c0             	movzbl %al,%eax
80108635:	83 ec 0c             	sub    $0xc,%esp
80108638:	53                   	push   %ebx
80108639:	6a 04                	push   $0x4
8010863b:	51                   	push   %ecx
8010863c:	52                   	push   %edx
8010863d:	50                   	push   %eax
8010863e:	e8 90 fd ff ff       	call   801083d3 <pci_write_config_register>
80108643:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108646:	8b 45 08             	mov    0x8(%ebp),%eax
80108649:	8b 40 10             	mov    0x10(%eax),%eax
8010864c:	05 00 00 00 40       	add    $0x40000000,%eax
80108651:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
80108656:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010865b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010865e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108663:	05 d8 00 00 00       	add    $0xd8,%eax
80108668:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010866b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010866e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108677:	8b 00                	mov    (%eax),%eax
80108679:	0d 00 00 00 04       	or     $0x4000000,%eax
8010867e:	89 c2                	mov    %eax,%edx
80108680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108683:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108688:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010868e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108691:	8b 00                	mov    (%eax),%eax
80108693:	83 c8 40             	or     $0x40,%eax
80108696:	89 c2                	mov    %eax,%edx
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010869d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a0:	8b 10                	mov    (%eax),%edx
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801086a7:	83 ec 0c             	sub    $0xc,%esp
801086aa:	68 f0 c0 10 80       	push   $0x8010c0f0
801086af:	e8 40 7d ff ff       	call   801003f4 <cprintf>
801086b4:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801086b7:	e8 da a0 ff ff       	call   80102796 <kalloc>
801086bc:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
801086c1:	a1 88 6c 19 80       	mov    0x80196c88,%eax
801086c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801086cc:	a1 88 6c 19 80       	mov    0x80196c88,%eax
801086d1:	83 ec 08             	sub    $0x8,%esp
801086d4:	50                   	push   %eax
801086d5:	68 12 c1 10 80       	push   $0x8010c112
801086da:	e8 15 7d ff ff       	call   801003f4 <cprintf>
801086df:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801086e2:	e8 50 00 00 00       	call   80108737 <i8254_init_recv>
  i8254_init_send();
801086e7:	e8 69 03 00 00       	call   80108a55 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801086ec:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086f3:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801086f6:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086fd:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108700:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108707:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010870a:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108711:	0f b6 c0             	movzbl %al,%eax
80108714:	83 ec 0c             	sub    $0xc,%esp
80108717:	53                   	push   %ebx
80108718:	51                   	push   %ecx
80108719:	52                   	push   %edx
8010871a:	50                   	push   %eax
8010871b:	68 20 c1 10 80       	push   $0x8010c120
80108720:	e8 cf 7c ff ff       	call   801003f4 <cprintf>
80108725:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108728:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010872b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108731:	90                   	nop
80108732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108735:	c9                   	leave  
80108736:	c3                   	ret    

80108737 <i8254_init_recv>:

void i8254_init_recv(){
80108737:	55                   	push   %ebp
80108738:	89 e5                	mov    %esp,%ebp
8010873a:	57                   	push   %edi
8010873b:	56                   	push   %esi
8010873c:	53                   	push   %ebx
8010873d:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108740:	83 ec 0c             	sub    $0xc,%esp
80108743:	6a 00                	push   $0x0
80108745:	e8 e8 04 00 00       	call   80108c32 <i8254_read_eeprom>
8010874a:	83 c4 10             	add    $0x10,%esp
8010874d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108750:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108753:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
80108758:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010875b:	c1 e8 08             	shr    $0x8,%eax
8010875e:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
80108763:	83 ec 0c             	sub    $0xc,%esp
80108766:	6a 01                	push   $0x1
80108768:	e8 c5 04 00 00       	call   80108c32 <i8254_read_eeprom>
8010876d:	83 c4 10             	add    $0x10,%esp
80108770:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108776:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
8010877b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010877e:	c1 e8 08             	shr    $0x8,%eax
80108781:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
80108786:	83 ec 0c             	sub    $0xc,%esp
80108789:	6a 02                	push   $0x2
8010878b:	e8 a2 04 00 00       	call   80108c32 <i8254_read_eeprom>
80108790:	83 c4 10             	add    $0x10,%esp
80108793:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108796:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108799:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
8010879e:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087a1:	c1 e8 08             	shr    $0x8,%eax
801087a4:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801087a9:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087b0:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801087b3:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087ba:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801087bd:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087c4:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801087c7:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087ce:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801087d1:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087d8:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801087db:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087e2:	0f b6 c0             	movzbl %al,%eax
801087e5:	83 ec 04             	sub    $0x4,%esp
801087e8:	57                   	push   %edi
801087e9:	56                   	push   %esi
801087ea:	53                   	push   %ebx
801087eb:	51                   	push   %ecx
801087ec:	52                   	push   %edx
801087ed:	50                   	push   %eax
801087ee:	68 38 c1 10 80       	push   $0x8010c138
801087f3:	e8 fc 7b ff ff       	call   801003f4 <cprintf>
801087f8:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801087fb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108800:	05 00 54 00 00       	add    $0x5400,%eax
80108805:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108808:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010880d:	05 04 54 00 00       	add    $0x5404,%eax
80108812:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108818:	c1 e0 10             	shl    $0x10,%eax
8010881b:	0b 45 d8             	or     -0x28(%ebp),%eax
8010881e:	89 c2                	mov    %eax,%edx
80108820:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108823:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108825:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108828:	0d 00 00 00 80       	or     $0x80000000,%eax
8010882d:	89 c2                	mov    %eax,%edx
8010882f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108832:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108834:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108839:	05 00 52 00 00       	add    $0x5200,%eax
8010883e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108841:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108848:	eb 19                	jmp    80108863 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010884a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010884d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108854:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108857:	01 d0                	add    %edx,%eax
80108859:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010885f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108863:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108867:	7e e1                	jle    8010884a <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108869:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010886e:	05 d0 00 00 00       	add    $0xd0,%eax
80108873:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108876:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108879:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010887f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108884:	05 c8 00 00 00       	add    $0xc8,%eax
80108889:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010888c:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010888f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108895:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010889a:	05 28 28 00 00       	add    $0x2828,%eax
8010889f:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801088a2:	8b 45 b8             	mov    -0x48(%ebp),%eax
801088a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801088ab:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088b0:	05 00 01 00 00       	add    $0x100,%eax
801088b5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801088b8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088bb:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801088c1:	e8 d0 9e ff ff       	call   80102796 <kalloc>
801088c6:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801088c9:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088ce:	05 00 28 00 00       	add    $0x2800,%eax
801088d3:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801088d6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088db:	05 04 28 00 00       	add    $0x2804,%eax
801088e0:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801088e3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088e8:	05 08 28 00 00       	add    $0x2808,%eax
801088ed:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801088f0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088f5:	05 10 28 00 00       	add    $0x2810,%eax
801088fa:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801088fd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108902:	05 18 28 00 00       	add    $0x2818,%eax
80108907:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010890a:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010890d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108913:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108916:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108918:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010891b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108921:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108924:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010892a:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010892d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108933:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108936:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010893c:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010893f:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108942:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108949:	eb 73                	jmp    801089be <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
8010894b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010894e:	c1 e0 04             	shl    $0x4,%eax
80108951:	89 c2                	mov    %eax,%edx
80108953:	8b 45 98             	mov    -0x68(%ebp),%eax
80108956:	01 d0                	add    %edx,%eax
80108958:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010895f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108962:	c1 e0 04             	shl    $0x4,%eax
80108965:	89 c2                	mov    %eax,%edx
80108967:	8b 45 98             	mov    -0x68(%ebp),%eax
8010896a:	01 d0                	add    %edx,%eax
8010896c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108972:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108975:	c1 e0 04             	shl    $0x4,%eax
80108978:	89 c2                	mov    %eax,%edx
8010897a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010897d:	01 d0                	add    %edx,%eax
8010897f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108985:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108988:	c1 e0 04             	shl    $0x4,%eax
8010898b:	89 c2                	mov    %eax,%edx
8010898d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108990:	01 d0                	add    %edx,%eax
80108992:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108996:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108999:	c1 e0 04             	shl    $0x4,%eax
8010899c:	89 c2                	mov    %eax,%edx
8010899e:	8b 45 98             	mov    -0x68(%ebp),%eax
801089a1:	01 d0                	add    %edx,%eax
801089a3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801089a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089aa:	c1 e0 04             	shl    $0x4,%eax
801089ad:	89 c2                	mov    %eax,%edx
801089af:	8b 45 98             	mov    -0x68(%ebp),%eax
801089b2:	01 d0                	add    %edx,%eax
801089b4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801089ba:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801089be:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801089c5:	7e 84                	jle    8010894b <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801089c7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801089ce:	eb 57                	jmp    80108a27 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801089d0:	e8 c1 9d ff ff       	call   80102796 <kalloc>
801089d5:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801089d8:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801089dc:	75 12                	jne    801089f0 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
801089de:	83 ec 0c             	sub    $0xc,%esp
801089e1:	68 58 c1 10 80       	push   $0x8010c158
801089e6:	e8 09 7a ff ff       	call   801003f4 <cprintf>
801089eb:	83 c4 10             	add    $0x10,%esp
      break;
801089ee:	eb 3d                	jmp    80108a2d <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801089f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089f3:	c1 e0 04             	shl    $0x4,%eax
801089f6:	89 c2                	mov    %eax,%edx
801089f8:	8b 45 98             	mov    -0x68(%ebp),%eax
801089fb:	01 d0                	add    %edx,%eax
801089fd:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a00:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a06:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a0b:	83 c0 01             	add    $0x1,%eax
80108a0e:	c1 e0 04             	shl    $0x4,%eax
80108a11:	89 c2                	mov    %eax,%edx
80108a13:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a16:	01 d0                	add    %edx,%eax
80108a18:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a1b:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a21:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a23:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108a27:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108a2b:	7e a3                	jle    801089d0 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108a2d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a30:	8b 00                	mov    (%eax),%eax
80108a32:	83 c8 02             	or     $0x2,%eax
80108a35:	89 c2                	mov    %eax,%edx
80108a37:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a3a:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108a3c:	83 ec 0c             	sub    $0xc,%esp
80108a3f:	68 78 c1 10 80       	push   $0x8010c178
80108a44:	e8 ab 79 ff ff       	call   801003f4 <cprintf>
80108a49:	83 c4 10             	add    $0x10,%esp
}
80108a4c:	90                   	nop
80108a4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108a50:	5b                   	pop    %ebx
80108a51:	5e                   	pop    %esi
80108a52:	5f                   	pop    %edi
80108a53:	5d                   	pop    %ebp
80108a54:	c3                   	ret    

80108a55 <i8254_init_send>:

void i8254_init_send(){
80108a55:	55                   	push   %ebp
80108a56:	89 e5                	mov    %esp,%ebp
80108a58:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108a5b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a60:	05 28 38 00 00       	add    $0x3828,%eax
80108a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108a68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6b:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108a71:	e8 20 9d ff ff       	call   80102796 <kalloc>
80108a76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108a79:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a7e:	05 00 38 00 00       	add    $0x3800,%eax
80108a83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108a86:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a8b:	05 04 38 00 00       	add    $0x3804,%eax
80108a90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108a93:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a98:	05 08 38 00 00       	add    $0x3808,%eax
80108a9d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108aa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aa3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108aa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aac:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108aae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ab1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108ab7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108aba:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ac0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ac5:	05 10 38 00 00       	add    $0x3810,%eax
80108aca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108acd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ad2:	05 18 38 00 00       	add    $0x3818,%eax
80108ad7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108ada:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108add:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ae3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ae6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108aec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108aef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108af9:	e9 82 00 00 00       	jmp    80108b80 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b01:	c1 e0 04             	shl    $0x4,%eax
80108b04:	89 c2                	mov    %eax,%edx
80108b06:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b09:	01 d0                	add    %edx,%eax
80108b0b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b15:	c1 e0 04             	shl    $0x4,%eax
80108b18:	89 c2                	mov    %eax,%edx
80108b1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b1d:	01 d0                	add    %edx,%eax
80108b1f:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b28:	c1 e0 04             	shl    $0x4,%eax
80108b2b:	89 c2                	mov    %eax,%edx
80108b2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b30:	01 d0                	add    %edx,%eax
80108b32:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b39:	c1 e0 04             	shl    $0x4,%eax
80108b3c:	89 c2                	mov    %eax,%edx
80108b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b41:	01 d0                	add    %edx,%eax
80108b43:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4a:	c1 e0 04             	shl    $0x4,%eax
80108b4d:	89 c2                	mov    %eax,%edx
80108b4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b52:	01 d0                	add    %edx,%eax
80108b54:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5b:	c1 e0 04             	shl    $0x4,%eax
80108b5e:	89 c2                	mov    %eax,%edx
80108b60:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b63:	01 d0                	add    %edx,%eax
80108b65:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6c:	c1 e0 04             	shl    $0x4,%eax
80108b6f:	89 c2                	mov    %eax,%edx
80108b71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b74:	01 d0                	add    %edx,%eax
80108b76:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b80:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108b87:	0f 8e 71 ff ff ff    	jle    80108afe <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108b8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b94:	eb 57                	jmp    80108bed <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108b96:	e8 fb 9b ff ff       	call   80102796 <kalloc>
80108b9b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108b9e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ba2:	75 12                	jne    80108bb6 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108ba4:	83 ec 0c             	sub    $0xc,%esp
80108ba7:	68 58 c1 10 80       	push   $0x8010c158
80108bac:	e8 43 78 ff ff       	call   801003f4 <cprintf>
80108bb1:	83 c4 10             	add    $0x10,%esp
      break;
80108bb4:	eb 3d                	jmp    80108bf3 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb9:	c1 e0 04             	shl    $0x4,%eax
80108bbc:	89 c2                	mov    %eax,%edx
80108bbe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bc1:	01 d0                	add    %edx,%eax
80108bc3:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108bc6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108bcc:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd1:	83 c0 01             	add    $0x1,%eax
80108bd4:	c1 e0 04             	shl    $0x4,%eax
80108bd7:	89 c2                	mov    %eax,%edx
80108bd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bdc:	01 d0                	add    %edx,%eax
80108bde:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108be1:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108be7:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108be9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108bed:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108bf1:	7e a3                	jle    80108b96 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108bf3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bf8:	05 00 04 00 00       	add    $0x400,%eax
80108bfd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108c00:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c03:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108c09:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c0e:	05 10 04 00 00       	add    $0x410,%eax
80108c13:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108c16:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c19:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108c1f:	83 ec 0c             	sub    $0xc,%esp
80108c22:	68 98 c1 10 80       	push   $0x8010c198
80108c27:	e8 c8 77 ff ff       	call   801003f4 <cprintf>
80108c2c:	83 c4 10             	add    $0x10,%esp

}
80108c2f:	90                   	nop
80108c30:	c9                   	leave  
80108c31:	c3                   	ret    

80108c32 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108c32:	55                   	push   %ebp
80108c33:	89 e5                	mov    %esp,%ebp
80108c35:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108c38:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c3d:	83 c0 14             	add    $0x14,%eax
80108c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108c43:	8b 45 08             	mov    0x8(%ebp),%eax
80108c46:	c1 e0 08             	shl    $0x8,%eax
80108c49:	0f b7 c0             	movzwl %ax,%eax
80108c4c:	83 c8 01             	or     $0x1,%eax
80108c4f:	89 c2                	mov    %eax,%edx
80108c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c54:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108c56:	83 ec 0c             	sub    $0xc,%esp
80108c59:	68 b8 c1 10 80       	push   $0x8010c1b8
80108c5e:	e8 91 77 ff ff       	call   801003f4 <cprintf>
80108c63:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c69:	8b 00                	mov    (%eax),%eax
80108c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c71:	83 e0 10             	and    $0x10,%eax
80108c74:	85 c0                	test   %eax,%eax
80108c76:	75 02                	jne    80108c7a <i8254_read_eeprom+0x48>
  while(1){
80108c78:	eb dc                	jmp    80108c56 <i8254_read_eeprom+0x24>
      break;
80108c7a:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7e:	8b 00                	mov    (%eax),%eax
80108c80:	c1 e8 10             	shr    $0x10,%eax
}
80108c83:	c9                   	leave  
80108c84:	c3                   	ret    

80108c85 <i8254_recv>:
void i8254_recv(){
80108c85:	55                   	push   %ebp
80108c86:	89 e5                	mov    %esp,%ebp
80108c88:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c8b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c90:	05 10 28 00 00       	add    $0x2810,%eax
80108c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c98:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c9d:	05 18 28 00 00       	add    $0x2818,%eax
80108ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ca5:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108caa:	05 00 28 00 00       	add    $0x2800,%eax
80108caf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb5:	8b 00                	mov    (%eax),%eax
80108cb7:	05 00 00 00 80       	add    $0x80000000,%eax
80108cbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc2:	8b 10                	mov    (%eax),%edx
80108cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc7:	8b 08                	mov    (%eax),%ecx
80108cc9:	89 d0                	mov    %edx,%eax
80108ccb:	29 c8                	sub    %ecx,%eax
80108ccd:	25 ff 00 00 00       	and    $0xff,%eax
80108cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108cd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108cd9:	7e 37                	jle    80108d12 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cde:	8b 00                	mov    (%eax),%eax
80108ce0:	c1 e0 04             	shl    $0x4,%eax
80108ce3:	89 c2                	mov    %eax,%edx
80108ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ce8:	01 d0                	add    %edx,%eax
80108cea:	8b 00                	mov    (%eax),%eax
80108cec:	05 00 00 00 80       	add    $0x80000000,%eax
80108cf1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf7:	8b 00                	mov    (%eax),%eax
80108cf9:	83 c0 01             	add    $0x1,%eax
80108cfc:	0f b6 d0             	movzbl %al,%edx
80108cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d02:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108d04:	83 ec 0c             	sub    $0xc,%esp
80108d07:	ff 75 e0             	push   -0x20(%ebp)
80108d0a:	e8 15 09 00 00       	call   80109624 <eth_proc>
80108d0f:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d15:	8b 10                	mov    (%eax),%edx
80108d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1a:	8b 00                	mov    (%eax),%eax
80108d1c:	39 c2                	cmp    %eax,%edx
80108d1e:	75 9f                	jne    80108cbf <i8254_recv+0x3a>
      (*rdt)--;
80108d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d23:	8b 00                	mov    (%eax),%eax
80108d25:	8d 50 ff             	lea    -0x1(%eax),%edx
80108d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d2b:	89 10                	mov    %edx,(%eax)
  while(1){
80108d2d:	eb 90                	jmp    80108cbf <i8254_recv+0x3a>

80108d2f <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108d2f:	55                   	push   %ebp
80108d30:	89 e5                	mov    %esp,%ebp
80108d32:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d35:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d3a:	05 10 38 00 00       	add    $0x3810,%eax
80108d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d42:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d47:	05 18 38 00 00       	add    $0x3818,%eax
80108d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d4f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108d54:	05 00 38 00 00       	add    $0x3800,%eax
80108d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d5f:	8b 00                	mov    (%eax),%eax
80108d61:	05 00 00 00 80       	add    $0x80000000,%eax
80108d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d6c:	8b 10                	mov    (%eax),%edx
80108d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d71:	8b 08                	mov    (%eax),%ecx
80108d73:	89 d0                	mov    %edx,%eax
80108d75:	29 c8                	sub    %ecx,%eax
80108d77:	0f b6 d0             	movzbl %al,%edx
80108d7a:	b8 00 01 00 00       	mov    $0x100,%eax
80108d7f:	29 d0                	sub    %edx,%eax
80108d81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d87:	8b 00                	mov    (%eax),%eax
80108d89:	25 ff 00 00 00       	and    $0xff,%eax
80108d8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108d91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d95:	0f 8e a8 00 00 00    	jle    80108e43 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108da1:	89 d1                	mov    %edx,%ecx
80108da3:	c1 e1 04             	shl    $0x4,%ecx
80108da6:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108da9:	01 ca                	add    %ecx,%edx
80108dab:	8b 12                	mov    (%edx),%edx
80108dad:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108db3:	83 ec 04             	sub    $0x4,%esp
80108db6:	ff 75 0c             	push   0xc(%ebp)
80108db9:	50                   	push   %eax
80108dba:	52                   	push   %edx
80108dbb:	e8 b8 bd ff ff       	call   80104b78 <memmove>
80108dc0:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc6:	c1 e0 04             	shl    $0x4,%eax
80108dc9:	89 c2                	mov    %eax,%edx
80108dcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dce:	01 d0                	add    %edx,%eax
80108dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dd3:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dda:	c1 e0 04             	shl    $0x4,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de2:	01 d0                	add    %edx,%eax
80108de4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108deb:	c1 e0 04             	shl    $0x4,%eax
80108dee:	89 c2                	mov    %eax,%edx
80108df0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dfc:	c1 e0 04             	shl    $0x4,%eax
80108dff:	89 c2                	mov    %eax,%edx
80108e01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e04:	01 d0                	add    %edx,%eax
80108e06:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e0d:	c1 e0 04             	shl    $0x4,%eax
80108e10:	89 c2                	mov    %eax,%edx
80108e12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e15:	01 d0                	add    %edx,%eax
80108e17:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e20:	c1 e0 04             	shl    $0x4,%eax
80108e23:	89 c2                	mov    %eax,%edx
80108e25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e28:	01 d0                	add    %edx,%eax
80108e2a:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e31:	8b 00                	mov    (%eax),%eax
80108e33:	83 c0 01             	add    $0x1,%eax
80108e36:	0f b6 d0             	movzbl %al,%edx
80108e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e3c:	89 10                	mov    %edx,(%eax)
    return len;
80108e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e41:	eb 05                	jmp    80108e48 <i8254_send+0x119>
  }else{
    return -1;
80108e43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108e48:	c9                   	leave  
80108e49:	c3                   	ret    

80108e4a <i8254_intr>:

void i8254_intr(){
80108e4a:	55                   	push   %ebp
80108e4b:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108e4d:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108e52:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108e58:	90                   	nop
80108e59:	5d                   	pop    %ebp
80108e5a:	c3                   	ret    

80108e5b <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108e5b:	55                   	push   %ebp
80108e5c:	89 e5                	mov    %esp,%ebp
80108e5e:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108e61:	8b 45 08             	mov    0x8(%ebp),%eax
80108e64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6a:	0f b7 00             	movzwl (%eax),%eax
80108e6d:	66 3d 00 01          	cmp    $0x100,%ax
80108e71:	74 0a                	je     80108e7d <arp_proc+0x22>
80108e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e78:	e9 4f 01 00 00       	jmp    80108fcc <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e80:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108e84:	66 83 f8 08          	cmp    $0x8,%ax
80108e88:	74 0a                	je     80108e94 <arp_proc+0x39>
80108e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e8f:	e9 38 01 00 00       	jmp    80108fcc <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e97:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108e9b:	3c 06                	cmp    $0x6,%al
80108e9d:	74 0a                	je     80108ea9 <arp_proc+0x4e>
80108e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ea4:	e9 23 01 00 00       	jmp    80108fcc <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eac:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108eb0:	3c 04                	cmp    $0x4,%al
80108eb2:	74 0a                	je     80108ebe <arp_proc+0x63>
80108eb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eb9:	e9 0e 01 00 00       	jmp    80108fcc <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec1:	83 c0 18             	add    $0x18,%eax
80108ec4:	83 ec 04             	sub    $0x4,%esp
80108ec7:	6a 04                	push   $0x4
80108ec9:	50                   	push   %eax
80108eca:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ecf:	e8 4c bc ff ff       	call   80104b20 <memcmp>
80108ed4:	83 c4 10             	add    $0x10,%esp
80108ed7:	85 c0                	test   %eax,%eax
80108ed9:	74 27                	je     80108f02 <arp_proc+0xa7>
80108edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ede:	83 c0 0e             	add    $0xe,%eax
80108ee1:	83 ec 04             	sub    $0x4,%esp
80108ee4:	6a 04                	push   $0x4
80108ee6:	50                   	push   %eax
80108ee7:	68 e4 f4 10 80       	push   $0x8010f4e4
80108eec:	e8 2f bc ff ff       	call   80104b20 <memcmp>
80108ef1:	83 c4 10             	add    $0x10,%esp
80108ef4:	85 c0                	test   %eax,%eax
80108ef6:	74 0a                	je     80108f02 <arp_proc+0xa7>
80108ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108efd:	e9 ca 00 00 00       	jmp    80108fcc <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f05:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f09:	66 3d 00 01          	cmp    $0x100,%ax
80108f0d:	75 69                	jne    80108f78 <arp_proc+0x11d>
80108f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f12:	83 c0 18             	add    $0x18,%eax
80108f15:	83 ec 04             	sub    $0x4,%esp
80108f18:	6a 04                	push   $0x4
80108f1a:	50                   	push   %eax
80108f1b:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f20:	e8 fb bb ff ff       	call   80104b20 <memcmp>
80108f25:	83 c4 10             	add    $0x10,%esp
80108f28:	85 c0                	test   %eax,%eax
80108f2a:	75 4c                	jne    80108f78 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108f2c:	e8 65 98 ff ff       	call   80102796 <kalloc>
80108f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108f34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108f3b:	83 ec 04             	sub    $0x4,%esp
80108f3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f41:	50                   	push   %eax
80108f42:	ff 75 f0             	push   -0x10(%ebp)
80108f45:	ff 75 f4             	push   -0xc(%ebp)
80108f48:	e8 1f 04 00 00       	call   8010936c <arp_reply_pkt_create>
80108f4d:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f53:	83 ec 08             	sub    $0x8,%esp
80108f56:	50                   	push   %eax
80108f57:	ff 75 f0             	push   -0x10(%ebp)
80108f5a:	e8 d0 fd ff ff       	call   80108d2f <i8254_send>
80108f5f:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f65:	83 ec 0c             	sub    $0xc,%esp
80108f68:	50                   	push   %eax
80108f69:	e8 8e 97 ff ff       	call   801026fc <kfree>
80108f6e:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108f71:	b8 02 00 00 00       	mov    $0x2,%eax
80108f76:	eb 54                	jmp    80108fcc <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f7f:	66 3d 00 02          	cmp    $0x200,%ax
80108f83:	75 42                	jne    80108fc7 <arp_proc+0x16c>
80108f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f88:	83 c0 18             	add    $0x18,%eax
80108f8b:	83 ec 04             	sub    $0x4,%esp
80108f8e:	6a 04                	push   $0x4
80108f90:	50                   	push   %eax
80108f91:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f96:	e8 85 bb ff ff       	call   80104b20 <memcmp>
80108f9b:	83 c4 10             	add    $0x10,%esp
80108f9e:	85 c0                	test   %eax,%eax
80108fa0:	75 25                	jne    80108fc7 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108fa2:	83 ec 0c             	sub    $0xc,%esp
80108fa5:	68 bc c1 10 80       	push   $0x8010c1bc
80108faa:	e8 45 74 ff ff       	call   801003f4 <cprintf>
80108faf:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108fb2:	83 ec 0c             	sub    $0xc,%esp
80108fb5:	ff 75 f4             	push   -0xc(%ebp)
80108fb8:	e8 af 01 00 00       	call   8010916c <arp_table_update>
80108fbd:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108fc0:	b8 01 00 00 00       	mov    $0x1,%eax
80108fc5:	eb 05                	jmp    80108fcc <arp_proc+0x171>
  }else{
    return -1;
80108fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108fcc:	c9                   	leave  
80108fcd:	c3                   	ret    

80108fce <arp_scan>:

void arp_scan(){
80108fce:	55                   	push   %ebp
80108fcf:	89 e5                	mov    %esp,%ebp
80108fd1:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108fd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fdb:	eb 6f                	jmp    8010904c <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108fdd:	e8 b4 97 ff ff       	call   80102796 <kalloc>
80108fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108fe5:	83 ec 04             	sub    $0x4,%esp
80108fe8:	ff 75 f4             	push   -0xc(%ebp)
80108feb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108fee:	50                   	push   %eax
80108fef:	ff 75 ec             	push   -0x14(%ebp)
80108ff2:	e8 62 00 00 00       	call   80109059 <arp_broadcast>
80108ff7:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108ffa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ffd:	83 ec 08             	sub    $0x8,%esp
80109000:	50                   	push   %eax
80109001:	ff 75 ec             	push   -0x14(%ebp)
80109004:	e8 26 fd ff ff       	call   80108d2f <i8254_send>
80109009:	83 c4 10             	add    $0x10,%esp
8010900c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010900f:	eb 22                	jmp    80109033 <arp_scan+0x65>
      microdelay(1);
80109011:	83 ec 0c             	sub    $0xc,%esp
80109014:	6a 01                	push   $0x1
80109016:	e8 12 9b ff ff       	call   80102b2d <microdelay>
8010901b:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010901e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109021:	83 ec 08             	sub    $0x8,%esp
80109024:	50                   	push   %eax
80109025:	ff 75 ec             	push   -0x14(%ebp)
80109028:	e8 02 fd ff ff       	call   80108d2f <i8254_send>
8010902d:	83 c4 10             	add    $0x10,%esp
80109030:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109033:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109037:	74 d8                	je     80109011 <arp_scan+0x43>
    }
    kfree((char *)send);
80109039:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010903c:	83 ec 0c             	sub    $0xc,%esp
8010903f:	50                   	push   %eax
80109040:	e8 b7 96 ff ff       	call   801026fc <kfree>
80109045:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109048:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010904c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109053:	7e 88                	jle    80108fdd <arp_scan+0xf>
  }
}
80109055:	90                   	nop
80109056:	90                   	nop
80109057:	c9                   	leave  
80109058:	c3                   	ret    

80109059 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109059:	55                   	push   %ebp
8010905a:	89 e5                	mov    %esp,%ebp
8010905c:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010905f:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109063:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109067:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010906b:	8b 45 10             	mov    0x10(%ebp),%eax
8010906e:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109071:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109078:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010907e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109085:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010908b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010908e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109094:	8b 45 08             	mov    0x8(%ebp),%eax
80109097:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010909a:	8b 45 08             	mov    0x8(%ebp),%eax
8010909d:	83 c0 0e             	add    $0xe,%eax
801090a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801090a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801090aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ad:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801090b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b4:	83 ec 04             	sub    $0x4,%esp
801090b7:	6a 06                	push   $0x6
801090b9:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801090bc:	52                   	push   %edx
801090bd:	50                   	push   %eax
801090be:	e8 b5 ba ff ff       	call   80104b78 <memmove>
801090c3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801090c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c9:	83 c0 06             	add    $0x6,%eax
801090cc:	83 ec 04             	sub    $0x4,%esp
801090cf:	6a 06                	push   $0x6
801090d1:	68 80 6c 19 80       	push   $0x80196c80
801090d6:	50                   	push   %eax
801090d7:	e8 9c ba ff ff       	call   80104b78 <memmove>
801090dc:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801090df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e2:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801090e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ea:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801090f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f3:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801090f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fa:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801090fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109101:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109107:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010910a:	8d 50 12             	lea    0x12(%eax),%edx
8010910d:	83 ec 04             	sub    $0x4,%esp
80109110:	6a 06                	push   $0x6
80109112:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109115:	50                   	push   %eax
80109116:	52                   	push   %edx
80109117:	e8 5c ba ff ff       	call   80104b78 <memmove>
8010911c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010911f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109122:	8d 50 18             	lea    0x18(%eax),%edx
80109125:	83 ec 04             	sub    $0x4,%esp
80109128:	6a 04                	push   $0x4
8010912a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010912d:	50                   	push   %eax
8010912e:	52                   	push   %edx
8010912f:	e8 44 ba ff ff       	call   80104b78 <memmove>
80109134:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109137:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913a:	83 c0 08             	add    $0x8,%eax
8010913d:	83 ec 04             	sub    $0x4,%esp
80109140:	6a 06                	push   $0x6
80109142:	68 80 6c 19 80       	push   $0x80196c80
80109147:	50                   	push   %eax
80109148:	e8 2b ba ff ff       	call   80104b78 <memmove>
8010914d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109153:	83 c0 0e             	add    $0xe,%eax
80109156:	83 ec 04             	sub    $0x4,%esp
80109159:	6a 04                	push   $0x4
8010915b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109160:	50                   	push   %eax
80109161:	e8 12 ba ff ff       	call   80104b78 <memmove>
80109166:	83 c4 10             	add    $0x10,%esp
}
80109169:	90                   	nop
8010916a:	c9                   	leave  
8010916b:	c3                   	ret    

8010916c <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010916c:	55                   	push   %ebp
8010916d:	89 e5                	mov    %esp,%ebp
8010916f:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109172:	8b 45 08             	mov    0x8(%ebp),%eax
80109175:	83 c0 0e             	add    $0xe,%eax
80109178:	83 ec 0c             	sub    $0xc,%esp
8010917b:	50                   	push   %eax
8010917c:	e8 bc 00 00 00       	call   8010923d <arp_table_search>
80109181:	83 c4 10             	add    $0x10,%esp
80109184:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010918b:	78 2d                	js     801091ba <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010918d:	8b 45 08             	mov    0x8(%ebp),%eax
80109190:	8d 48 08             	lea    0x8(%eax),%ecx
80109193:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109196:	89 d0                	mov    %edx,%eax
80109198:	c1 e0 02             	shl    $0x2,%eax
8010919b:	01 d0                	add    %edx,%eax
8010919d:	01 c0                	add    %eax,%eax
8010919f:	01 d0                	add    %edx,%eax
801091a1:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091a6:	83 c0 04             	add    $0x4,%eax
801091a9:	83 ec 04             	sub    $0x4,%esp
801091ac:	6a 06                	push   $0x6
801091ae:	51                   	push   %ecx
801091af:	50                   	push   %eax
801091b0:	e8 c3 b9 ff ff       	call   80104b78 <memmove>
801091b5:	83 c4 10             	add    $0x10,%esp
801091b8:	eb 70                	jmp    8010922a <arp_table_update+0xbe>
  }else{
    index += 1;
801091ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801091be:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091c1:	8b 45 08             	mov    0x8(%ebp),%eax
801091c4:	8d 48 08             	lea    0x8(%eax),%ecx
801091c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091ca:	89 d0                	mov    %edx,%eax
801091cc:	c1 e0 02             	shl    $0x2,%eax
801091cf:	01 d0                	add    %edx,%eax
801091d1:	01 c0                	add    %eax,%eax
801091d3:	01 d0                	add    %edx,%eax
801091d5:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091da:	83 c0 04             	add    $0x4,%eax
801091dd:	83 ec 04             	sub    $0x4,%esp
801091e0:	6a 06                	push   $0x6
801091e2:	51                   	push   %ecx
801091e3:	50                   	push   %eax
801091e4:	e8 8f b9 ff ff       	call   80104b78 <memmove>
801091e9:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801091ec:	8b 45 08             	mov    0x8(%ebp),%eax
801091ef:	8d 48 0e             	lea    0xe(%eax),%ecx
801091f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091f5:	89 d0                	mov    %edx,%eax
801091f7:	c1 e0 02             	shl    $0x2,%eax
801091fa:	01 d0                	add    %edx,%eax
801091fc:	01 c0                	add    %eax,%eax
801091fe:	01 d0                	add    %edx,%eax
80109200:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109205:	83 ec 04             	sub    $0x4,%esp
80109208:	6a 04                	push   $0x4
8010920a:	51                   	push   %ecx
8010920b:	50                   	push   %eax
8010920c:	e8 67 b9 ff ff       	call   80104b78 <memmove>
80109211:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109214:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109217:	89 d0                	mov    %edx,%eax
80109219:	c1 e0 02             	shl    $0x2,%eax
8010921c:	01 d0                	add    %edx,%eax
8010921e:	01 c0                	add    %eax,%eax
80109220:	01 d0                	add    %edx,%eax
80109222:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109227:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010922a:	83 ec 0c             	sub    $0xc,%esp
8010922d:	68 a0 6c 19 80       	push   $0x80196ca0
80109232:	e8 83 00 00 00       	call   801092ba <print_arp_table>
80109237:	83 c4 10             	add    $0x10,%esp
}
8010923a:	90                   	nop
8010923b:	c9                   	leave  
8010923c:	c3                   	ret    

8010923d <arp_table_search>:

int arp_table_search(uchar *ip){
8010923d:	55                   	push   %ebp
8010923e:	89 e5                	mov    %esp,%ebp
80109240:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109243:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010924a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109251:	eb 59                	jmp    801092ac <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109253:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109256:	89 d0                	mov    %edx,%eax
80109258:	c1 e0 02             	shl    $0x2,%eax
8010925b:	01 d0                	add    %edx,%eax
8010925d:	01 c0                	add    %eax,%eax
8010925f:	01 d0                	add    %edx,%eax
80109261:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109266:	83 ec 04             	sub    $0x4,%esp
80109269:	6a 04                	push   $0x4
8010926b:	ff 75 08             	push   0x8(%ebp)
8010926e:	50                   	push   %eax
8010926f:	e8 ac b8 ff ff       	call   80104b20 <memcmp>
80109274:	83 c4 10             	add    $0x10,%esp
80109277:	85 c0                	test   %eax,%eax
80109279:	75 05                	jne    80109280 <arp_table_search+0x43>
      return i;
8010927b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927e:	eb 38                	jmp    801092b8 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109280:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109283:	89 d0                	mov    %edx,%eax
80109285:	c1 e0 02             	shl    $0x2,%eax
80109288:	01 d0                	add    %edx,%eax
8010928a:	01 c0                	add    %eax,%eax
8010928c:	01 d0                	add    %edx,%eax
8010928e:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109293:	0f b6 00             	movzbl (%eax),%eax
80109296:	84 c0                	test   %al,%al
80109298:	75 0e                	jne    801092a8 <arp_table_search+0x6b>
8010929a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010929e:	75 08                	jne    801092a8 <arp_table_search+0x6b>
      empty = -i;
801092a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a3:	f7 d8                	neg    %eax
801092a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801092a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801092ac:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801092b0:	7e a1                	jle    80109253 <arp_table_search+0x16>
    }
  }
  return empty-1;
801092b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b5:	83 e8 01             	sub    $0x1,%eax
}
801092b8:	c9                   	leave  
801092b9:	c3                   	ret    

801092ba <print_arp_table>:

void print_arp_table(){
801092ba:	55                   	push   %ebp
801092bb:	89 e5                	mov    %esp,%ebp
801092bd:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801092c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092c7:	e9 92 00 00 00       	jmp    8010935e <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801092cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092cf:	89 d0                	mov    %edx,%eax
801092d1:	c1 e0 02             	shl    $0x2,%eax
801092d4:	01 d0                	add    %edx,%eax
801092d6:	01 c0                	add    %eax,%eax
801092d8:	01 d0                	add    %edx,%eax
801092da:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801092df:	0f b6 00             	movzbl (%eax),%eax
801092e2:	84 c0                	test   %al,%al
801092e4:	74 74                	je     8010935a <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801092e6:	83 ec 08             	sub    $0x8,%esp
801092e9:	ff 75 f4             	push   -0xc(%ebp)
801092ec:	68 cf c1 10 80       	push   $0x8010c1cf
801092f1:	e8 fe 70 ff ff       	call   801003f4 <cprintf>
801092f6:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801092f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092fc:	89 d0                	mov    %edx,%eax
801092fe:	c1 e0 02             	shl    $0x2,%eax
80109301:	01 d0                	add    %edx,%eax
80109303:	01 c0                	add    %eax,%eax
80109305:	01 d0                	add    %edx,%eax
80109307:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010930c:	83 ec 0c             	sub    $0xc,%esp
8010930f:	50                   	push   %eax
80109310:	e8 54 02 00 00       	call   80109569 <print_ipv4>
80109315:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109318:	83 ec 0c             	sub    $0xc,%esp
8010931b:	68 de c1 10 80       	push   $0x8010c1de
80109320:	e8 cf 70 ff ff       	call   801003f4 <cprintf>
80109325:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109328:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010932b:	89 d0                	mov    %edx,%eax
8010932d:	c1 e0 02             	shl    $0x2,%eax
80109330:	01 d0                	add    %edx,%eax
80109332:	01 c0                	add    %eax,%eax
80109334:	01 d0                	add    %edx,%eax
80109336:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010933b:	83 c0 04             	add    $0x4,%eax
8010933e:	83 ec 0c             	sub    $0xc,%esp
80109341:	50                   	push   %eax
80109342:	e8 70 02 00 00       	call   801095b7 <print_mac>
80109347:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010934a:	83 ec 0c             	sub    $0xc,%esp
8010934d:	68 e0 c1 10 80       	push   $0x8010c1e0
80109352:	e8 9d 70 ff ff       	call   801003f4 <cprintf>
80109357:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010935a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010935e:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109362:	0f 8e 64 ff ff ff    	jle    801092cc <print_arp_table+0x12>
    }
  }
}
80109368:	90                   	nop
80109369:	90                   	nop
8010936a:	c9                   	leave  
8010936b:	c3                   	ret    

8010936c <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010936c:	55                   	push   %ebp
8010936d:	89 e5                	mov    %esp,%ebp
8010936f:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109372:	8b 45 10             	mov    0x10(%ebp),%eax
80109375:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010937b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010937e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109381:	8b 45 0c             	mov    0xc(%ebp),%eax
80109384:	83 c0 0e             	add    $0xe,%eax
80109387:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010938a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109394:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109398:	8b 45 08             	mov    0x8(%ebp),%eax
8010939b:	8d 50 08             	lea    0x8(%eax),%edx
8010939e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a1:	83 ec 04             	sub    $0x4,%esp
801093a4:	6a 06                	push   $0x6
801093a6:	52                   	push   %edx
801093a7:	50                   	push   %eax
801093a8:	e8 cb b7 ff ff       	call   80104b78 <memmove>
801093ad:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b3:	83 c0 06             	add    $0x6,%eax
801093b6:	83 ec 04             	sub    $0x4,%esp
801093b9:	6a 06                	push   $0x6
801093bb:	68 80 6c 19 80       	push   $0x80196c80
801093c0:	50                   	push   %eax
801093c1:	e8 b2 b7 ff ff       	call   80104b78 <memmove>
801093c6:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cc:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d4:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801093da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093dd:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e4:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801093e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093eb:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801093f1:	8b 45 08             	mov    0x8(%ebp),%eax
801093f4:	8d 50 08             	lea    0x8(%eax),%edx
801093f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fa:	83 c0 12             	add    $0x12,%eax
801093fd:	83 ec 04             	sub    $0x4,%esp
80109400:	6a 06                	push   $0x6
80109402:	52                   	push   %edx
80109403:	50                   	push   %eax
80109404:	e8 6f b7 ff ff       	call   80104b78 <memmove>
80109409:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010940c:	8b 45 08             	mov    0x8(%ebp),%eax
8010940f:	8d 50 0e             	lea    0xe(%eax),%edx
80109412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109415:	83 c0 18             	add    $0x18,%eax
80109418:	83 ec 04             	sub    $0x4,%esp
8010941b:	6a 04                	push   $0x4
8010941d:	52                   	push   %edx
8010941e:	50                   	push   %eax
8010941f:	e8 54 b7 ff ff       	call   80104b78 <memmove>
80109424:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109427:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942a:	83 c0 08             	add    $0x8,%eax
8010942d:	83 ec 04             	sub    $0x4,%esp
80109430:	6a 06                	push   $0x6
80109432:	68 80 6c 19 80       	push   $0x80196c80
80109437:	50                   	push   %eax
80109438:	e8 3b b7 ff ff       	call   80104b78 <memmove>
8010943d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109443:	83 c0 0e             	add    $0xe,%eax
80109446:	83 ec 04             	sub    $0x4,%esp
80109449:	6a 04                	push   $0x4
8010944b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109450:	50                   	push   %eax
80109451:	e8 22 b7 ff ff       	call   80104b78 <memmove>
80109456:	83 c4 10             	add    $0x10,%esp
}
80109459:	90                   	nop
8010945a:	c9                   	leave  
8010945b:	c3                   	ret    

8010945c <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010945c:	55                   	push   %ebp
8010945d:	89 e5                	mov    %esp,%ebp
8010945f:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109462:	83 ec 0c             	sub    $0xc,%esp
80109465:	68 e2 c1 10 80       	push   $0x8010c1e2
8010946a:	e8 85 6f ff ff       	call   801003f4 <cprintf>
8010946f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109472:	8b 45 08             	mov    0x8(%ebp),%eax
80109475:	83 c0 0e             	add    $0xe,%eax
80109478:	83 ec 0c             	sub    $0xc,%esp
8010947b:	50                   	push   %eax
8010947c:	e8 e8 00 00 00       	call   80109569 <print_ipv4>
80109481:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109484:	83 ec 0c             	sub    $0xc,%esp
80109487:	68 e0 c1 10 80       	push   $0x8010c1e0
8010948c:	e8 63 6f ff ff       	call   801003f4 <cprintf>
80109491:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109494:	8b 45 08             	mov    0x8(%ebp),%eax
80109497:	83 c0 08             	add    $0x8,%eax
8010949a:	83 ec 0c             	sub    $0xc,%esp
8010949d:	50                   	push   %eax
8010949e:	e8 14 01 00 00       	call   801095b7 <print_mac>
801094a3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094a6:	83 ec 0c             	sub    $0xc,%esp
801094a9:	68 e0 c1 10 80       	push   $0x8010c1e0
801094ae:	e8 41 6f ff ff       	call   801003f4 <cprintf>
801094b3:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801094b6:	83 ec 0c             	sub    $0xc,%esp
801094b9:	68 f9 c1 10 80       	push   $0x8010c1f9
801094be:	e8 31 6f ff ff       	call   801003f4 <cprintf>
801094c3:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801094c6:	8b 45 08             	mov    0x8(%ebp),%eax
801094c9:	83 c0 18             	add    $0x18,%eax
801094cc:	83 ec 0c             	sub    $0xc,%esp
801094cf:	50                   	push   %eax
801094d0:	e8 94 00 00 00       	call   80109569 <print_ipv4>
801094d5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094d8:	83 ec 0c             	sub    $0xc,%esp
801094db:	68 e0 c1 10 80       	push   $0x8010c1e0
801094e0:	e8 0f 6f ff ff       	call   801003f4 <cprintf>
801094e5:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801094e8:	8b 45 08             	mov    0x8(%ebp),%eax
801094eb:	83 c0 12             	add    $0x12,%eax
801094ee:	83 ec 0c             	sub    $0xc,%esp
801094f1:	50                   	push   %eax
801094f2:	e8 c0 00 00 00       	call   801095b7 <print_mac>
801094f7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094fa:	83 ec 0c             	sub    $0xc,%esp
801094fd:	68 e0 c1 10 80       	push   $0x8010c1e0
80109502:	e8 ed 6e ff ff       	call   801003f4 <cprintf>
80109507:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010950a:	83 ec 0c             	sub    $0xc,%esp
8010950d:	68 10 c2 10 80       	push   $0x8010c210
80109512:	e8 dd 6e ff ff       	call   801003f4 <cprintf>
80109517:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010951a:	8b 45 08             	mov    0x8(%ebp),%eax
8010951d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109521:	66 3d 00 01          	cmp    $0x100,%ax
80109525:	75 12                	jne    80109539 <print_arp_info+0xdd>
80109527:	83 ec 0c             	sub    $0xc,%esp
8010952a:	68 1c c2 10 80       	push   $0x8010c21c
8010952f:	e8 c0 6e ff ff       	call   801003f4 <cprintf>
80109534:	83 c4 10             	add    $0x10,%esp
80109537:	eb 1d                	jmp    80109556 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109539:	8b 45 08             	mov    0x8(%ebp),%eax
8010953c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109540:	66 3d 00 02          	cmp    $0x200,%ax
80109544:	75 10                	jne    80109556 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109546:	83 ec 0c             	sub    $0xc,%esp
80109549:	68 25 c2 10 80       	push   $0x8010c225
8010954e:	e8 a1 6e ff ff       	call   801003f4 <cprintf>
80109553:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109556:	83 ec 0c             	sub    $0xc,%esp
80109559:	68 e0 c1 10 80       	push   $0x8010c1e0
8010955e:	e8 91 6e ff ff       	call   801003f4 <cprintf>
80109563:	83 c4 10             	add    $0x10,%esp
}
80109566:	90                   	nop
80109567:	c9                   	leave  
80109568:	c3                   	ret    

80109569 <print_ipv4>:

void print_ipv4(uchar *ip){
80109569:	55                   	push   %ebp
8010956a:	89 e5                	mov    %esp,%ebp
8010956c:	53                   	push   %ebx
8010956d:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109570:	8b 45 08             	mov    0x8(%ebp),%eax
80109573:	83 c0 03             	add    $0x3,%eax
80109576:	0f b6 00             	movzbl (%eax),%eax
80109579:	0f b6 d8             	movzbl %al,%ebx
8010957c:	8b 45 08             	mov    0x8(%ebp),%eax
8010957f:	83 c0 02             	add    $0x2,%eax
80109582:	0f b6 00             	movzbl (%eax),%eax
80109585:	0f b6 c8             	movzbl %al,%ecx
80109588:	8b 45 08             	mov    0x8(%ebp),%eax
8010958b:	83 c0 01             	add    $0x1,%eax
8010958e:	0f b6 00             	movzbl (%eax),%eax
80109591:	0f b6 d0             	movzbl %al,%edx
80109594:	8b 45 08             	mov    0x8(%ebp),%eax
80109597:	0f b6 00             	movzbl (%eax),%eax
8010959a:	0f b6 c0             	movzbl %al,%eax
8010959d:	83 ec 0c             	sub    $0xc,%esp
801095a0:	53                   	push   %ebx
801095a1:	51                   	push   %ecx
801095a2:	52                   	push   %edx
801095a3:	50                   	push   %eax
801095a4:	68 2c c2 10 80       	push   $0x8010c22c
801095a9:	e8 46 6e ff ff       	call   801003f4 <cprintf>
801095ae:	83 c4 20             	add    $0x20,%esp
}
801095b1:	90                   	nop
801095b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095b5:	c9                   	leave  
801095b6:	c3                   	ret    

801095b7 <print_mac>:

void print_mac(uchar *mac){
801095b7:	55                   	push   %ebp
801095b8:	89 e5                	mov    %esp,%ebp
801095ba:	57                   	push   %edi
801095bb:	56                   	push   %esi
801095bc:	53                   	push   %ebx
801095bd:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801095c0:	8b 45 08             	mov    0x8(%ebp),%eax
801095c3:	83 c0 05             	add    $0x5,%eax
801095c6:	0f b6 00             	movzbl (%eax),%eax
801095c9:	0f b6 f8             	movzbl %al,%edi
801095cc:	8b 45 08             	mov    0x8(%ebp),%eax
801095cf:	83 c0 04             	add    $0x4,%eax
801095d2:	0f b6 00             	movzbl (%eax),%eax
801095d5:	0f b6 f0             	movzbl %al,%esi
801095d8:	8b 45 08             	mov    0x8(%ebp),%eax
801095db:	83 c0 03             	add    $0x3,%eax
801095de:	0f b6 00             	movzbl (%eax),%eax
801095e1:	0f b6 d8             	movzbl %al,%ebx
801095e4:	8b 45 08             	mov    0x8(%ebp),%eax
801095e7:	83 c0 02             	add    $0x2,%eax
801095ea:	0f b6 00             	movzbl (%eax),%eax
801095ed:	0f b6 c8             	movzbl %al,%ecx
801095f0:	8b 45 08             	mov    0x8(%ebp),%eax
801095f3:	83 c0 01             	add    $0x1,%eax
801095f6:	0f b6 00             	movzbl (%eax),%eax
801095f9:	0f b6 d0             	movzbl %al,%edx
801095fc:	8b 45 08             	mov    0x8(%ebp),%eax
801095ff:	0f b6 00             	movzbl (%eax),%eax
80109602:	0f b6 c0             	movzbl %al,%eax
80109605:	83 ec 04             	sub    $0x4,%esp
80109608:	57                   	push   %edi
80109609:	56                   	push   %esi
8010960a:	53                   	push   %ebx
8010960b:	51                   	push   %ecx
8010960c:	52                   	push   %edx
8010960d:	50                   	push   %eax
8010960e:	68 44 c2 10 80       	push   $0x8010c244
80109613:	e8 dc 6d ff ff       	call   801003f4 <cprintf>
80109618:	83 c4 20             	add    $0x20,%esp
}
8010961b:	90                   	nop
8010961c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010961f:	5b                   	pop    %ebx
80109620:	5e                   	pop    %esi
80109621:	5f                   	pop    %edi
80109622:	5d                   	pop    %ebp
80109623:	c3                   	ret    

80109624 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109624:	55                   	push   %ebp
80109625:	89 e5                	mov    %esp,%ebp
80109627:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010962a:	8b 45 08             	mov    0x8(%ebp),%eax
8010962d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109630:	8b 45 08             	mov    0x8(%ebp),%eax
80109633:	83 c0 0e             	add    $0xe,%eax
80109636:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109640:	3c 08                	cmp    $0x8,%al
80109642:	75 1b                	jne    8010965f <eth_proc+0x3b>
80109644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109647:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010964b:	3c 06                	cmp    $0x6,%al
8010964d:	75 10                	jne    8010965f <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010964f:	83 ec 0c             	sub    $0xc,%esp
80109652:	ff 75 f0             	push   -0x10(%ebp)
80109655:	e8 01 f8 ff ff       	call   80108e5b <arp_proc>
8010965a:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010965d:	eb 24                	jmp    80109683 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010965f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109662:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109666:	3c 08                	cmp    $0x8,%al
80109668:	75 19                	jne    80109683 <eth_proc+0x5f>
8010966a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109671:	84 c0                	test   %al,%al
80109673:	75 0e                	jne    80109683 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109675:	83 ec 0c             	sub    $0xc,%esp
80109678:	ff 75 08             	push   0x8(%ebp)
8010967b:	e8 a3 00 00 00       	call   80109723 <ipv4_proc>
80109680:	83 c4 10             	add    $0x10,%esp
}
80109683:	90                   	nop
80109684:	c9                   	leave  
80109685:	c3                   	ret    

80109686 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109686:	55                   	push   %ebp
80109687:	89 e5                	mov    %esp,%ebp
80109689:	83 ec 04             	sub    $0x4,%esp
8010968c:	8b 45 08             	mov    0x8(%ebp),%eax
8010968f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109693:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109697:	c1 e0 08             	shl    $0x8,%eax
8010969a:	89 c2                	mov    %eax,%edx
8010969c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096a0:	66 c1 e8 08          	shr    $0x8,%ax
801096a4:	01 d0                	add    %edx,%eax
}
801096a6:	c9                   	leave  
801096a7:	c3                   	ret    

801096a8 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801096a8:	55                   	push   %ebp
801096a9:	89 e5                	mov    %esp,%ebp
801096ab:	83 ec 04             	sub    $0x4,%esp
801096ae:	8b 45 08             	mov    0x8(%ebp),%eax
801096b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801096b5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096b9:	c1 e0 08             	shl    $0x8,%eax
801096bc:	89 c2                	mov    %eax,%edx
801096be:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096c2:	66 c1 e8 08          	shr    $0x8,%ax
801096c6:	01 d0                	add    %edx,%eax
}
801096c8:	c9                   	leave  
801096c9:	c3                   	ret    

801096ca <H2N_uint>:

uint H2N_uint(uint value){
801096ca:	55                   	push   %ebp
801096cb:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801096cd:	8b 45 08             	mov    0x8(%ebp),%eax
801096d0:	c1 e0 18             	shl    $0x18,%eax
801096d3:	25 00 00 00 0f       	and    $0xf000000,%eax
801096d8:	89 c2                	mov    %eax,%edx
801096da:	8b 45 08             	mov    0x8(%ebp),%eax
801096dd:	c1 e0 08             	shl    $0x8,%eax
801096e0:	25 00 f0 00 00       	and    $0xf000,%eax
801096e5:	09 c2                	or     %eax,%edx
801096e7:	8b 45 08             	mov    0x8(%ebp),%eax
801096ea:	c1 e8 08             	shr    $0x8,%eax
801096ed:	83 e0 0f             	and    $0xf,%eax
801096f0:	01 d0                	add    %edx,%eax
}
801096f2:	5d                   	pop    %ebp
801096f3:	c3                   	ret    

801096f4 <N2H_uint>:

uint N2H_uint(uint value){
801096f4:	55                   	push   %ebp
801096f5:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801096f7:	8b 45 08             	mov    0x8(%ebp),%eax
801096fa:	c1 e0 18             	shl    $0x18,%eax
801096fd:	89 c2                	mov    %eax,%edx
801096ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109702:	c1 e0 08             	shl    $0x8,%eax
80109705:	25 00 00 ff 00       	and    $0xff0000,%eax
8010970a:	01 c2                	add    %eax,%edx
8010970c:	8b 45 08             	mov    0x8(%ebp),%eax
8010970f:	c1 e8 08             	shr    $0x8,%eax
80109712:	25 00 ff 00 00       	and    $0xff00,%eax
80109717:	01 c2                	add    %eax,%edx
80109719:	8b 45 08             	mov    0x8(%ebp),%eax
8010971c:	c1 e8 18             	shr    $0x18,%eax
8010971f:	01 d0                	add    %edx,%eax
}
80109721:	5d                   	pop    %ebp
80109722:	c3                   	ret    

80109723 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109723:	55                   	push   %ebp
80109724:	89 e5                	mov    %esp,%ebp
80109726:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109729:	8b 45 08             	mov    0x8(%ebp),%eax
8010972c:	83 c0 0e             	add    $0xe,%eax
8010972f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109735:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109739:	0f b7 d0             	movzwl %ax,%edx
8010973c:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109741:	39 c2                	cmp    %eax,%edx
80109743:	74 60                	je     801097a5 <ipv4_proc+0x82>
80109745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109748:	83 c0 0c             	add    $0xc,%eax
8010974b:	83 ec 04             	sub    $0x4,%esp
8010974e:	6a 04                	push   $0x4
80109750:	50                   	push   %eax
80109751:	68 e4 f4 10 80       	push   $0x8010f4e4
80109756:	e8 c5 b3 ff ff       	call   80104b20 <memcmp>
8010975b:	83 c4 10             	add    $0x10,%esp
8010975e:	85 c0                	test   %eax,%eax
80109760:	74 43                	je     801097a5 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109765:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109769:	0f b7 c0             	movzwl %ax,%eax
8010976c:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109774:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109778:	3c 01                	cmp    $0x1,%al
8010977a:	75 10                	jne    8010978c <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010977c:	83 ec 0c             	sub    $0xc,%esp
8010977f:	ff 75 08             	push   0x8(%ebp)
80109782:	e8 a3 00 00 00       	call   8010982a <icmp_proc>
80109787:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010978a:	eb 19                	jmp    801097a5 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010978c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109793:	3c 06                	cmp    $0x6,%al
80109795:	75 0e                	jne    801097a5 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109797:	83 ec 0c             	sub    $0xc,%esp
8010979a:	ff 75 08             	push   0x8(%ebp)
8010979d:	e8 b3 03 00 00       	call   80109b55 <tcp_proc>
801097a2:	83 c4 10             	add    $0x10,%esp
}
801097a5:	90                   	nop
801097a6:	c9                   	leave  
801097a7:	c3                   	ret    

801097a8 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801097a8:	55                   	push   %ebp
801097a9:	89 e5                	mov    %esp,%ebp
801097ab:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801097ae:	8b 45 08             	mov    0x8(%ebp),%eax
801097b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801097b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b7:	0f b6 00             	movzbl (%eax),%eax
801097ba:	83 e0 0f             	and    $0xf,%eax
801097bd:	01 c0                	add    %eax,%eax
801097bf:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801097c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801097c9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801097d0:	eb 48                	jmp    8010981a <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801097d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801097d5:	01 c0                	add    %eax,%eax
801097d7:	89 c2                	mov    %eax,%edx
801097d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097dc:	01 d0                	add    %edx,%eax
801097de:	0f b6 00             	movzbl (%eax),%eax
801097e1:	0f b6 c0             	movzbl %al,%eax
801097e4:	c1 e0 08             	shl    $0x8,%eax
801097e7:	89 c2                	mov    %eax,%edx
801097e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801097ec:	01 c0                	add    %eax,%eax
801097ee:	8d 48 01             	lea    0x1(%eax),%ecx
801097f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f4:	01 c8                	add    %ecx,%eax
801097f6:	0f b6 00             	movzbl (%eax),%eax
801097f9:	0f b6 c0             	movzbl %al,%eax
801097fc:	01 d0                	add    %edx,%eax
801097fe:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109801:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109808:	76 0c                	jbe    80109816 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010980a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010980d:	0f b7 c0             	movzwl %ax,%eax
80109810:	83 c0 01             	add    $0x1,%eax
80109813:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109816:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010981a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010981e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109821:	7c af                	jl     801097d2 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109823:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109826:	f7 d0                	not    %eax
}
80109828:	c9                   	leave  
80109829:	c3                   	ret    

8010982a <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010982a:	55                   	push   %ebp
8010982b:	89 e5                	mov    %esp,%ebp
8010982d:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109830:	8b 45 08             	mov    0x8(%ebp),%eax
80109833:	83 c0 0e             	add    $0xe,%eax
80109836:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983c:	0f b6 00             	movzbl (%eax),%eax
8010983f:	0f b6 c0             	movzbl %al,%eax
80109842:	83 e0 0f             	and    $0xf,%eax
80109845:	c1 e0 02             	shl    $0x2,%eax
80109848:	89 c2                	mov    %eax,%edx
8010984a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984d:	01 d0                	add    %edx,%eax
8010984f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109855:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109859:	84 c0                	test   %al,%al
8010985b:	75 4f                	jne    801098ac <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010985d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109860:	0f b6 00             	movzbl (%eax),%eax
80109863:	3c 08                	cmp    $0x8,%al
80109865:	75 45                	jne    801098ac <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109867:	e8 2a 8f ff ff       	call   80102796 <kalloc>
8010986c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010986f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109876:	83 ec 04             	sub    $0x4,%esp
80109879:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010987c:	50                   	push   %eax
8010987d:	ff 75 ec             	push   -0x14(%ebp)
80109880:	ff 75 08             	push   0x8(%ebp)
80109883:	e8 78 00 00 00       	call   80109900 <icmp_reply_pkt_create>
80109888:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010988b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010988e:	83 ec 08             	sub    $0x8,%esp
80109891:	50                   	push   %eax
80109892:	ff 75 ec             	push   -0x14(%ebp)
80109895:	e8 95 f4 ff ff       	call   80108d2f <i8254_send>
8010989a:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010989d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098a0:	83 ec 0c             	sub    $0xc,%esp
801098a3:	50                   	push   %eax
801098a4:	e8 53 8e ff ff       	call   801026fc <kfree>
801098a9:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801098ac:	90                   	nop
801098ad:	c9                   	leave  
801098ae:	c3                   	ret    

801098af <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801098af:	55                   	push   %ebp
801098b0:	89 e5                	mov    %esp,%ebp
801098b2:	53                   	push   %ebx
801098b3:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801098b6:	8b 45 08             	mov    0x8(%ebp),%eax
801098b9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098bd:	0f b7 c0             	movzwl %ax,%eax
801098c0:	83 ec 0c             	sub    $0xc,%esp
801098c3:	50                   	push   %eax
801098c4:	e8 bd fd ff ff       	call   80109686 <N2H_ushort>
801098c9:	83 c4 10             	add    $0x10,%esp
801098cc:	0f b7 d8             	movzwl %ax,%ebx
801098cf:	8b 45 08             	mov    0x8(%ebp),%eax
801098d2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801098d6:	0f b7 c0             	movzwl %ax,%eax
801098d9:	83 ec 0c             	sub    $0xc,%esp
801098dc:	50                   	push   %eax
801098dd:	e8 a4 fd ff ff       	call   80109686 <N2H_ushort>
801098e2:	83 c4 10             	add    $0x10,%esp
801098e5:	0f b7 c0             	movzwl %ax,%eax
801098e8:	83 ec 04             	sub    $0x4,%esp
801098eb:	53                   	push   %ebx
801098ec:	50                   	push   %eax
801098ed:	68 63 c2 10 80       	push   $0x8010c263
801098f2:	e8 fd 6a ff ff       	call   801003f4 <cprintf>
801098f7:	83 c4 10             	add    $0x10,%esp
}
801098fa:	90                   	nop
801098fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098fe:	c9                   	leave  
801098ff:	c3                   	ret    

80109900 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109900:	55                   	push   %ebp
80109901:	89 e5                	mov    %esp,%ebp
80109903:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109906:	8b 45 08             	mov    0x8(%ebp),%eax
80109909:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010990c:	8b 45 08             	mov    0x8(%ebp),%eax
8010990f:	83 c0 0e             	add    $0xe,%eax
80109912:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109918:	0f b6 00             	movzbl (%eax),%eax
8010991b:	0f b6 c0             	movzbl %al,%eax
8010991e:	83 e0 0f             	and    $0xf,%eax
80109921:	c1 e0 02             	shl    $0x2,%eax
80109924:	89 c2                	mov    %eax,%edx
80109926:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109929:	01 d0                	add    %edx,%eax
8010992b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010992e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109931:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109934:	8b 45 0c             	mov    0xc(%ebp),%eax
80109937:	83 c0 0e             	add    $0xe,%eax
8010993a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010993d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109940:	83 c0 14             	add    $0x14,%eax
80109943:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109946:	8b 45 10             	mov    0x10(%ebp),%eax
80109949:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010994f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109952:	8d 50 06             	lea    0x6(%eax),%edx
80109955:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109958:	83 ec 04             	sub    $0x4,%esp
8010995b:	6a 06                	push   $0x6
8010995d:	52                   	push   %edx
8010995e:	50                   	push   %eax
8010995f:	e8 14 b2 ff ff       	call   80104b78 <memmove>
80109964:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109967:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010996a:	83 c0 06             	add    $0x6,%eax
8010996d:	83 ec 04             	sub    $0x4,%esp
80109970:	6a 06                	push   $0x6
80109972:	68 80 6c 19 80       	push   $0x80196c80
80109977:	50                   	push   %eax
80109978:	e8 fb b1 ff ff       	call   80104b78 <memmove>
8010997d:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109980:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109983:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109987:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010998a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010998e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109991:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109997:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010999b:	83 ec 0c             	sub    $0xc,%esp
8010999e:	6a 54                	push   $0x54
801099a0:	e8 03 fd ff ff       	call   801096a8 <H2N_ushort>
801099a5:	83 c4 10             	add    $0x10,%esp
801099a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099ab:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
801099af:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
801099b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099b9:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801099bd:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
801099c4:	83 c0 01             	add    $0x1,%eax
801099c7:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
801099cd:	83 ec 0c             	sub    $0xc,%esp
801099d0:	68 00 40 00 00       	push   $0x4000
801099d5:	e8 ce fc ff ff       	call   801096a8 <H2N_ushort>
801099da:	83 c4 10             	add    $0x10,%esp
801099dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099e0:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
801099e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099e7:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
801099eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099ee:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
801099f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099f5:	83 c0 0c             	add    $0xc,%eax
801099f8:	83 ec 04             	sub    $0x4,%esp
801099fb:	6a 04                	push   $0x4
801099fd:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a02:	50                   	push   %eax
80109a03:	e8 70 b1 ff ff       	call   80104b78 <memmove>
80109a08:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0e:	8d 50 0c             	lea    0xc(%eax),%edx
80109a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a14:	83 c0 10             	add    $0x10,%eax
80109a17:	83 ec 04             	sub    $0x4,%esp
80109a1a:	6a 04                	push   $0x4
80109a1c:	52                   	push   %edx
80109a1d:	50                   	push   %eax
80109a1e:	e8 55 b1 ff ff       	call   80104b78 <memmove>
80109a23:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109a26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a29:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109a2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a32:	83 ec 0c             	sub    $0xc,%esp
80109a35:	50                   	push   %eax
80109a36:	e8 6d fd ff ff       	call   801097a8 <ipv4_chksum>
80109a3b:	83 c4 10             	add    $0x10,%esp
80109a3e:	0f b7 c0             	movzwl %ax,%eax
80109a41:	83 ec 0c             	sub    $0xc,%esp
80109a44:	50                   	push   %eax
80109a45:	e8 5e fc ff ff       	call   801096a8 <H2N_ushort>
80109a4a:	83 c4 10             	add    $0x10,%esp
80109a4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a50:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a57:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a5d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a64:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109a68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a6b:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a72:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a79:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a80:	8d 50 08             	lea    0x8(%eax),%edx
80109a83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a86:	83 c0 08             	add    $0x8,%eax
80109a89:	83 ec 04             	sub    $0x4,%esp
80109a8c:	6a 08                	push   $0x8
80109a8e:	52                   	push   %edx
80109a8f:	50                   	push   %eax
80109a90:	e8 e3 b0 ff ff       	call   80104b78 <memmove>
80109a95:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109a98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a9b:	8d 50 10             	lea    0x10(%eax),%edx
80109a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aa1:	83 c0 10             	add    $0x10,%eax
80109aa4:	83 ec 04             	sub    $0x4,%esp
80109aa7:	6a 30                	push   $0x30
80109aa9:	52                   	push   %edx
80109aaa:	50                   	push   %eax
80109aab:	e8 c8 b0 ff ff       	call   80104b78 <memmove>
80109ab0:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ab6:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109abf:	83 ec 0c             	sub    $0xc,%esp
80109ac2:	50                   	push   %eax
80109ac3:	e8 1c 00 00 00       	call   80109ae4 <icmp_chksum>
80109ac8:	83 c4 10             	add    $0x10,%esp
80109acb:	0f b7 c0             	movzwl %ax,%eax
80109ace:	83 ec 0c             	sub    $0xc,%esp
80109ad1:	50                   	push   %eax
80109ad2:	e8 d1 fb ff ff       	call   801096a8 <H2N_ushort>
80109ad7:	83 c4 10             	add    $0x10,%esp
80109ada:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109add:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109ae1:	90                   	nop
80109ae2:	c9                   	leave  
80109ae3:	c3                   	ret    

80109ae4 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109ae4:	55                   	push   %ebp
80109ae5:	89 e5                	mov    %esp,%ebp
80109ae7:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109aea:	8b 45 08             	mov    0x8(%ebp),%eax
80109aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109af0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109af7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109afe:	eb 48                	jmp    80109b48 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b03:	01 c0                	add    %eax,%eax
80109b05:	89 c2                	mov    %eax,%edx
80109b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b0a:	01 d0                	add    %edx,%eax
80109b0c:	0f b6 00             	movzbl (%eax),%eax
80109b0f:	0f b6 c0             	movzbl %al,%eax
80109b12:	c1 e0 08             	shl    $0x8,%eax
80109b15:	89 c2                	mov    %eax,%edx
80109b17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b1a:	01 c0                	add    %eax,%eax
80109b1c:	8d 48 01             	lea    0x1(%eax),%ecx
80109b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b22:	01 c8                	add    %ecx,%eax
80109b24:	0f b6 00             	movzbl (%eax),%eax
80109b27:	0f b6 c0             	movzbl %al,%eax
80109b2a:	01 d0                	add    %edx,%eax
80109b2c:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b2f:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b36:	76 0c                	jbe    80109b44 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b3b:	0f b7 c0             	movzwl %ax,%eax
80109b3e:	83 c0 01             	add    $0x1,%eax
80109b41:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b44:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b48:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109b4c:	7e b2                	jle    80109b00 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b51:	f7 d0                	not    %eax
}
80109b53:	c9                   	leave  
80109b54:	c3                   	ret    

80109b55 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109b55:	55                   	push   %ebp
80109b56:	89 e5                	mov    %esp,%ebp
80109b58:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b5e:	83 c0 0e             	add    $0xe,%eax
80109b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b67:	0f b6 00             	movzbl (%eax),%eax
80109b6a:	0f b6 c0             	movzbl %al,%eax
80109b6d:	83 e0 0f             	and    $0xf,%eax
80109b70:	c1 e0 02             	shl    $0x2,%eax
80109b73:	89 c2                	mov    %eax,%edx
80109b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b78:	01 d0                	add    %edx,%eax
80109b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b80:	83 c0 14             	add    $0x14,%eax
80109b83:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109b86:	e8 0b 8c ff ff       	call   80102796 <kalloc>
80109b8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109b8e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b98:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b9c:	0f b6 c0             	movzbl %al,%eax
80109b9f:	83 e0 02             	and    $0x2,%eax
80109ba2:	85 c0                	test   %eax,%eax
80109ba4:	74 3d                	je     80109be3 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109ba6:	83 ec 0c             	sub    $0xc,%esp
80109ba9:	6a 00                	push   $0x0
80109bab:	6a 12                	push   $0x12
80109bad:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bb0:	50                   	push   %eax
80109bb1:	ff 75 e8             	push   -0x18(%ebp)
80109bb4:	ff 75 08             	push   0x8(%ebp)
80109bb7:	e8 a2 01 00 00       	call   80109d5e <tcp_pkt_create>
80109bbc:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109bbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bc2:	83 ec 08             	sub    $0x8,%esp
80109bc5:	50                   	push   %eax
80109bc6:	ff 75 e8             	push   -0x18(%ebp)
80109bc9:	e8 61 f1 ff ff       	call   80108d2f <i8254_send>
80109bce:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109bd1:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109bd6:	83 c0 01             	add    $0x1,%eax
80109bd9:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109bde:	e9 69 01 00 00       	jmp    80109d4c <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109bea:	3c 18                	cmp    $0x18,%al
80109bec:	0f 85 10 01 00 00    	jne    80109d02 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109bf2:	83 ec 04             	sub    $0x4,%esp
80109bf5:	6a 03                	push   $0x3
80109bf7:	68 7e c2 10 80       	push   $0x8010c27e
80109bfc:	ff 75 ec             	push   -0x14(%ebp)
80109bff:	e8 1c af ff ff       	call   80104b20 <memcmp>
80109c04:	83 c4 10             	add    $0x10,%esp
80109c07:	85 c0                	test   %eax,%eax
80109c09:	74 74                	je     80109c7f <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109c0b:	83 ec 0c             	sub    $0xc,%esp
80109c0e:	68 82 c2 10 80       	push   $0x8010c282
80109c13:	e8 dc 67 ff ff       	call   801003f4 <cprintf>
80109c18:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c1b:	83 ec 0c             	sub    $0xc,%esp
80109c1e:	6a 00                	push   $0x0
80109c20:	6a 10                	push   $0x10
80109c22:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c25:	50                   	push   %eax
80109c26:	ff 75 e8             	push   -0x18(%ebp)
80109c29:	ff 75 08             	push   0x8(%ebp)
80109c2c:	e8 2d 01 00 00       	call   80109d5e <tcp_pkt_create>
80109c31:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109c34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c37:	83 ec 08             	sub    $0x8,%esp
80109c3a:	50                   	push   %eax
80109c3b:	ff 75 e8             	push   -0x18(%ebp)
80109c3e:	e8 ec f0 ff ff       	call   80108d2f <i8254_send>
80109c43:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109c46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c49:	83 c0 36             	add    $0x36,%eax
80109c4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109c4f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109c52:	50                   	push   %eax
80109c53:	ff 75 e0             	push   -0x20(%ebp)
80109c56:	6a 00                	push   $0x0
80109c58:	6a 00                	push   $0x0
80109c5a:	e8 5a 04 00 00       	call   8010a0b9 <http_proc>
80109c5f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109c62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109c65:	83 ec 0c             	sub    $0xc,%esp
80109c68:	50                   	push   %eax
80109c69:	6a 18                	push   $0x18
80109c6b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c6e:	50                   	push   %eax
80109c6f:	ff 75 e8             	push   -0x18(%ebp)
80109c72:	ff 75 08             	push   0x8(%ebp)
80109c75:	e8 e4 00 00 00       	call   80109d5e <tcp_pkt_create>
80109c7a:	83 c4 20             	add    $0x20,%esp
80109c7d:	eb 62                	jmp    80109ce1 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c7f:	83 ec 0c             	sub    $0xc,%esp
80109c82:	6a 00                	push   $0x0
80109c84:	6a 10                	push   $0x10
80109c86:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c89:	50                   	push   %eax
80109c8a:	ff 75 e8             	push   -0x18(%ebp)
80109c8d:	ff 75 08             	push   0x8(%ebp)
80109c90:	e8 c9 00 00 00       	call   80109d5e <tcp_pkt_create>
80109c95:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109c98:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c9b:	83 ec 08             	sub    $0x8,%esp
80109c9e:	50                   	push   %eax
80109c9f:	ff 75 e8             	push   -0x18(%ebp)
80109ca2:	e8 88 f0 ff ff       	call   80108d2f <i8254_send>
80109ca7:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109caa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cad:	83 c0 36             	add    $0x36,%eax
80109cb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109cb3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109cb6:	50                   	push   %eax
80109cb7:	ff 75 e4             	push   -0x1c(%ebp)
80109cba:	6a 00                	push   $0x0
80109cbc:	6a 00                	push   $0x0
80109cbe:	e8 f6 03 00 00       	call   8010a0b9 <http_proc>
80109cc3:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109cc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109cc9:	83 ec 0c             	sub    $0xc,%esp
80109ccc:	50                   	push   %eax
80109ccd:	6a 18                	push   $0x18
80109ccf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cd2:	50                   	push   %eax
80109cd3:	ff 75 e8             	push   -0x18(%ebp)
80109cd6:	ff 75 08             	push   0x8(%ebp)
80109cd9:	e8 80 00 00 00       	call   80109d5e <tcp_pkt_create>
80109cde:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ce1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ce4:	83 ec 08             	sub    $0x8,%esp
80109ce7:	50                   	push   %eax
80109ce8:	ff 75 e8             	push   -0x18(%ebp)
80109ceb:	e8 3f f0 ff ff       	call   80108d2f <i8254_send>
80109cf0:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109cf3:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109cf8:	83 c0 01             	add    $0x1,%eax
80109cfb:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109d00:	eb 4a                	jmp    80109d4c <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d05:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d09:	3c 10                	cmp    $0x10,%al
80109d0b:	75 3f                	jne    80109d4c <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109d0d:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109d12:	83 f8 01             	cmp    $0x1,%eax
80109d15:	75 35                	jne    80109d4c <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109d17:	83 ec 0c             	sub    $0xc,%esp
80109d1a:	6a 00                	push   $0x0
80109d1c:	6a 01                	push   $0x1
80109d1e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d21:	50                   	push   %eax
80109d22:	ff 75 e8             	push   -0x18(%ebp)
80109d25:	ff 75 08             	push   0x8(%ebp)
80109d28:	e8 31 00 00 00       	call   80109d5e <tcp_pkt_create>
80109d2d:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d33:	83 ec 08             	sub    $0x8,%esp
80109d36:	50                   	push   %eax
80109d37:	ff 75 e8             	push   -0x18(%ebp)
80109d3a:	e8 f0 ef ff ff       	call   80108d2f <i8254_send>
80109d3f:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109d42:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109d49:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109d4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d4f:	83 ec 0c             	sub    $0xc,%esp
80109d52:	50                   	push   %eax
80109d53:	e8 a4 89 ff ff       	call   801026fc <kfree>
80109d58:	83 c4 10             	add    $0x10,%esp
}
80109d5b:	90                   	nop
80109d5c:	c9                   	leave  
80109d5d:	c3                   	ret    

80109d5e <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109d5e:	55                   	push   %ebp
80109d5f:	89 e5                	mov    %esp,%ebp
80109d61:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d64:	8b 45 08             	mov    0x8(%ebp),%eax
80109d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6d:	83 c0 0e             	add    $0xe,%eax
80109d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d76:	0f b6 00             	movzbl (%eax),%eax
80109d79:	0f b6 c0             	movzbl %al,%eax
80109d7c:	83 e0 0f             	and    $0xf,%eax
80109d7f:	c1 e0 02             	shl    $0x2,%eax
80109d82:	89 c2                	mov    %eax,%edx
80109d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d87:	01 d0                	add    %edx,%eax
80109d89:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109d92:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d95:	83 c0 0e             	add    $0xe,%eax
80109d98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9e:	83 c0 14             	add    $0x14,%eax
80109da1:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109da4:	8b 45 18             	mov    0x18(%ebp),%eax
80109da7:	8d 50 36             	lea    0x36(%eax),%edx
80109daa:	8b 45 10             	mov    0x10(%ebp),%eax
80109dad:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db2:	8d 50 06             	lea    0x6(%eax),%edx
80109db5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109db8:	83 ec 04             	sub    $0x4,%esp
80109dbb:	6a 06                	push   $0x6
80109dbd:	52                   	push   %edx
80109dbe:	50                   	push   %eax
80109dbf:	e8 b4 ad ff ff       	call   80104b78 <memmove>
80109dc4:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dca:	83 c0 06             	add    $0x6,%eax
80109dcd:	83 ec 04             	sub    $0x4,%esp
80109dd0:	6a 06                	push   $0x6
80109dd2:	68 80 6c 19 80       	push   $0x80196c80
80109dd7:	50                   	push   %eax
80109dd8:	e8 9b ad ff ff       	call   80104b78 <memmove>
80109ddd:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109de0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109de3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109de7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dea:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df1:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df7:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109dfb:	8b 45 18             	mov    0x18(%ebp),%eax
80109dfe:	83 c0 28             	add    $0x28,%eax
80109e01:	0f b7 c0             	movzwl %ax,%eax
80109e04:	83 ec 0c             	sub    $0xc,%esp
80109e07:	50                   	push   %eax
80109e08:	e8 9b f8 ff ff       	call   801096a8 <H2N_ushort>
80109e0d:	83 c4 10             	add    $0x10,%esp
80109e10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e13:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e17:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e21:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e25:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109e2c:	83 c0 01             	add    $0x1,%eax
80109e2f:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109e35:	83 ec 0c             	sub    $0xc,%esp
80109e38:	6a 00                	push   $0x0
80109e3a:	e8 69 f8 ff ff       	call   801096a8 <H2N_ushort>
80109e3f:	83 c4 10             	add    $0x10,%esp
80109e42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e45:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e4c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e53:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e5a:	83 c0 0c             	add    $0xc,%eax
80109e5d:	83 ec 04             	sub    $0x4,%esp
80109e60:	6a 04                	push   $0x4
80109e62:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e67:	50                   	push   %eax
80109e68:	e8 0b ad ff ff       	call   80104b78 <memmove>
80109e6d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e73:	8d 50 0c             	lea    0xc(%eax),%edx
80109e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e79:	83 c0 10             	add    $0x10,%eax
80109e7c:	83 ec 04             	sub    $0x4,%esp
80109e7f:	6a 04                	push   $0x4
80109e81:	52                   	push   %edx
80109e82:	50                   	push   %eax
80109e83:	e8 f0 ac ff ff       	call   80104b78 <memmove>
80109e88:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e8e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e97:	83 ec 0c             	sub    $0xc,%esp
80109e9a:	50                   	push   %eax
80109e9b:	e8 08 f9 ff ff       	call   801097a8 <ipv4_chksum>
80109ea0:	83 c4 10             	add    $0x10,%esp
80109ea3:	0f b7 c0             	movzwl %ax,%eax
80109ea6:	83 ec 0c             	sub    $0xc,%esp
80109ea9:	50                   	push   %eax
80109eaa:	e8 f9 f7 ff ff       	call   801096a8 <H2N_ushort>
80109eaf:	83 c4 10             	add    $0x10,%esp
80109eb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109eb5:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ebc:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109ec0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec3:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109ec6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec9:	0f b7 10             	movzwl (%eax),%edx
80109ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ecf:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109ed3:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109ed8:	83 ec 0c             	sub    $0xc,%esp
80109edb:	50                   	push   %eax
80109edc:	e8 e9 f7 ff ff       	call   801096ca <H2N_uint>
80109ee1:	83 c4 10             	add    $0x10,%esp
80109ee4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ee7:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eed:	8b 40 04             	mov    0x4(%eax),%eax
80109ef0:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109ef6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ef9:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eff:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109f03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f06:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f0d:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109f11:	8b 45 14             	mov    0x14(%ebp),%eax
80109f14:	89 c2                	mov    %eax,%edx
80109f16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f19:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109f1c:	83 ec 0c             	sub    $0xc,%esp
80109f1f:	68 90 38 00 00       	push   $0x3890
80109f24:	e8 7f f7 ff ff       	call   801096a8 <H2N_ushort>
80109f29:	83 c4 10             	add    $0x10,%esp
80109f2c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f2f:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f36:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f3f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f48:	83 ec 0c             	sub    $0xc,%esp
80109f4b:	50                   	push   %eax
80109f4c:	e8 1f 00 00 00       	call   80109f70 <tcp_chksum>
80109f51:	83 c4 10             	add    $0x10,%esp
80109f54:	83 c0 08             	add    $0x8,%eax
80109f57:	0f b7 c0             	movzwl %ax,%eax
80109f5a:	83 ec 0c             	sub    $0xc,%esp
80109f5d:	50                   	push   %eax
80109f5e:	e8 45 f7 ff ff       	call   801096a8 <H2N_ushort>
80109f63:	83 c4 10             	add    $0x10,%esp
80109f66:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f69:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109f6d:	90                   	nop
80109f6e:	c9                   	leave  
80109f6f:	c3                   	ret    

80109f70 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109f70:	55                   	push   %ebp
80109f71:	89 e5                	mov    %esp,%ebp
80109f73:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109f76:	8b 45 08             	mov    0x8(%ebp),%eax
80109f79:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109f7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f7f:	83 c0 14             	add    $0x14,%eax
80109f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109f85:	83 ec 04             	sub    $0x4,%esp
80109f88:	6a 04                	push   $0x4
80109f8a:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f8f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f92:	50                   	push   %eax
80109f93:	e8 e0 ab ff ff       	call   80104b78 <memmove>
80109f98:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109f9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f9e:	83 c0 0c             	add    $0xc,%eax
80109fa1:	83 ec 04             	sub    $0x4,%esp
80109fa4:	6a 04                	push   $0x4
80109fa6:	50                   	push   %eax
80109fa7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109faa:	83 c0 04             	add    $0x4,%eax
80109fad:	50                   	push   %eax
80109fae:	e8 c5 ab ff ff       	call   80104b78 <memmove>
80109fb3:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109fb6:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109fba:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109fbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fc1:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109fc5:	0f b7 c0             	movzwl %ax,%eax
80109fc8:	83 ec 0c             	sub    $0xc,%esp
80109fcb:	50                   	push   %eax
80109fcc:	e8 b5 f6 ff ff       	call   80109686 <N2H_ushort>
80109fd1:	83 c4 10             	add    $0x10,%esp
80109fd4:	83 e8 14             	sub    $0x14,%eax
80109fd7:	0f b7 c0             	movzwl %ax,%eax
80109fda:	83 ec 0c             	sub    $0xc,%esp
80109fdd:	50                   	push   %eax
80109fde:	e8 c5 f6 ff ff       	call   801096a8 <H2N_ushort>
80109fe3:	83 c4 10             	add    $0x10,%esp
80109fe6:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109fea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109ff1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ff4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109ff7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109ffe:	eb 33                	jmp    8010a033 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a000:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a003:	01 c0                	add    %eax,%eax
8010a005:	89 c2                	mov    %eax,%edx
8010a007:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a00a:	01 d0                	add    %edx,%eax
8010a00c:	0f b6 00             	movzbl (%eax),%eax
8010a00f:	0f b6 c0             	movzbl %al,%eax
8010a012:	c1 e0 08             	shl    $0x8,%eax
8010a015:	89 c2                	mov    %eax,%edx
8010a017:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a01a:	01 c0                	add    %eax,%eax
8010a01c:	8d 48 01             	lea    0x1(%eax),%ecx
8010a01f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a022:	01 c8                	add    %ecx,%eax
8010a024:	0f b6 00             	movzbl (%eax),%eax
8010a027:	0f b6 c0             	movzbl %al,%eax
8010a02a:	01 d0                	add    %edx,%eax
8010a02c:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a02f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a033:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a037:	7e c7                	jle    8010a000 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a03f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a046:	eb 33                	jmp    8010a07b <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a048:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a04b:	01 c0                	add    %eax,%eax
8010a04d:	89 c2                	mov    %eax,%edx
8010a04f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a052:	01 d0                	add    %edx,%eax
8010a054:	0f b6 00             	movzbl (%eax),%eax
8010a057:	0f b6 c0             	movzbl %al,%eax
8010a05a:	c1 e0 08             	shl    $0x8,%eax
8010a05d:	89 c2                	mov    %eax,%edx
8010a05f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a062:	01 c0                	add    %eax,%eax
8010a064:	8d 48 01             	lea    0x1(%eax),%ecx
8010a067:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a06a:	01 c8                	add    %ecx,%eax
8010a06c:	0f b6 00             	movzbl (%eax),%eax
8010a06f:	0f b6 c0             	movzbl %al,%eax
8010a072:	01 d0                	add    %edx,%eax
8010a074:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a077:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a07b:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a07f:	0f b7 c0             	movzwl %ax,%eax
8010a082:	83 ec 0c             	sub    $0xc,%esp
8010a085:	50                   	push   %eax
8010a086:	e8 fb f5 ff ff       	call   80109686 <N2H_ushort>
8010a08b:	83 c4 10             	add    $0x10,%esp
8010a08e:	66 d1 e8             	shr    %ax
8010a091:	0f b7 c0             	movzwl %ax,%eax
8010a094:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a097:	7c af                	jl     8010a048 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a09c:	c1 e8 10             	shr    $0x10,%eax
8010a09f:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a0a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a5:	f7 d0                	not    %eax
}
8010a0a7:	c9                   	leave  
8010a0a8:	c3                   	ret    

8010a0a9 <tcp_fin>:

void tcp_fin(){
8010a0a9:	55                   	push   %ebp
8010a0aa:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a0ac:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
8010a0b3:	00 00 00 
}
8010a0b6:	90                   	nop
8010a0b7:	5d                   	pop    %ebp
8010a0b8:	c3                   	ret    

8010a0b9 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a0b9:	55                   	push   %ebp
8010a0ba:	89 e5                	mov    %esp,%ebp
8010a0bc:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a0bf:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0c2:	83 ec 04             	sub    $0x4,%esp
8010a0c5:	6a 00                	push   $0x0
8010a0c7:	68 8b c2 10 80       	push   $0x8010c28b
8010a0cc:	50                   	push   %eax
8010a0cd:	e8 65 00 00 00       	call   8010a137 <http_strcpy>
8010a0d2:	83 c4 10             	add    $0x10,%esp
8010a0d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a0d8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0db:	83 ec 04             	sub    $0x4,%esp
8010a0de:	ff 75 f4             	push   -0xc(%ebp)
8010a0e1:	68 9e c2 10 80       	push   $0x8010c29e
8010a0e6:	50                   	push   %eax
8010a0e7:	e8 4b 00 00 00       	call   8010a137 <http_strcpy>
8010a0ec:	83 c4 10             	add    $0x10,%esp
8010a0ef:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a0f2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0f5:	83 ec 04             	sub    $0x4,%esp
8010a0f8:	ff 75 f4             	push   -0xc(%ebp)
8010a0fb:	68 b9 c2 10 80       	push   $0x8010c2b9
8010a100:	50                   	push   %eax
8010a101:	e8 31 00 00 00       	call   8010a137 <http_strcpy>
8010a106:	83 c4 10             	add    $0x10,%esp
8010a109:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a10c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a10f:	83 e0 01             	and    $0x1,%eax
8010a112:	85 c0                	test   %eax,%eax
8010a114:	74 11                	je     8010a127 <http_proc+0x6e>
    char *payload = (char *)send;
8010a116:	8b 45 10             	mov    0x10(%ebp),%eax
8010a119:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a11c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a11f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a122:	01 d0                	add    %edx,%eax
8010a124:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a127:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a12a:	8b 45 14             	mov    0x14(%ebp),%eax
8010a12d:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a12f:	e8 75 ff ff ff       	call   8010a0a9 <tcp_fin>
}
8010a134:	90                   	nop
8010a135:	c9                   	leave  
8010a136:	c3                   	ret    

8010a137 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a137:	55                   	push   %ebp
8010a138:	89 e5                	mov    %esp,%ebp
8010a13a:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a13d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a144:	eb 20                	jmp    8010a166 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a146:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a14c:	01 d0                	add    %edx,%eax
8010a14e:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a151:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a154:	01 ca                	add    %ecx,%edx
8010a156:	89 d1                	mov    %edx,%ecx
8010a158:	8b 55 08             	mov    0x8(%ebp),%edx
8010a15b:	01 ca                	add    %ecx,%edx
8010a15d:	0f b6 00             	movzbl (%eax),%eax
8010a160:	88 02                	mov    %al,(%edx)
    i++;
8010a162:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a166:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a16c:	01 d0                	add    %edx,%eax
8010a16e:	0f b6 00             	movzbl (%eax),%eax
8010a171:	84 c0                	test   %al,%al
8010a173:	75 d1                	jne    8010a146 <http_strcpy+0xf>
  }
  return i;
8010a175:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a178:	c9                   	leave  
8010a179:	c3                   	ret    

8010a17a <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a17a:	55                   	push   %ebp
8010a17b:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a17d:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
8010a184:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a187:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a18c:	c1 e8 09             	shr    $0x9,%eax
8010a18f:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a194:	90                   	nop
8010a195:	5d                   	pop    %ebp
8010a196:	c3                   	ret    

8010a197 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a197:	55                   	push   %ebp
8010a198:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a19a:	90                   	nop
8010a19b:	5d                   	pop    %ebp
8010a19c:	c3                   	ret    

8010a19d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a19d:	55                   	push   %ebp
8010a19e:	89 e5                	mov    %esp,%ebp
8010a1a0:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a1a3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a6:	83 c0 0c             	add    $0xc,%eax
8010a1a9:	83 ec 0c             	sub    $0xc,%esp
8010a1ac:	50                   	push   %eax
8010a1ad:	e8 00 a6 ff ff       	call   801047b2 <holdingsleep>
8010a1b2:	83 c4 10             	add    $0x10,%esp
8010a1b5:	85 c0                	test   %eax,%eax
8010a1b7:	75 0d                	jne    8010a1c6 <iderw+0x29>
    panic("iderw: buf not locked");
8010a1b9:	83 ec 0c             	sub    $0xc,%esp
8010a1bc:	68 ca c2 10 80       	push   $0x8010c2ca
8010a1c1:	e8 e3 63 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a1c6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1c9:	8b 00                	mov    (%eax),%eax
8010a1cb:	83 e0 06             	and    $0x6,%eax
8010a1ce:	83 f8 02             	cmp    $0x2,%eax
8010a1d1:	75 0d                	jne    8010a1e0 <iderw+0x43>
    panic("iderw: nothing to do");
8010a1d3:	83 ec 0c             	sub    $0xc,%esp
8010a1d6:	68 e0 c2 10 80       	push   $0x8010c2e0
8010a1db:	e8 c9 63 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a1e0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e3:	8b 40 04             	mov    0x4(%eax),%eax
8010a1e6:	83 f8 01             	cmp    $0x1,%eax
8010a1e9:	74 0d                	je     8010a1f8 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a1eb:	83 ec 0c             	sub    $0xc,%esp
8010a1ee:	68 f5 c2 10 80       	push   $0x8010c2f5
8010a1f3:	e8 b1 63 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a1f8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1fb:	8b 40 08             	mov    0x8(%eax),%eax
8010a1fe:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a204:	39 d0                	cmp    %edx,%eax
8010a206:	72 0d                	jb     8010a215 <iderw+0x78>
    panic("iderw: block out of range");
8010a208:	83 ec 0c             	sub    $0xc,%esp
8010a20b:	68 13 c3 10 80       	push   $0x8010c313
8010a210:	e8 94 63 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a215:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a21b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a21e:	8b 40 08             	mov    0x8(%eax),%eax
8010a221:	c1 e0 09             	shl    $0x9,%eax
8010a224:	01 d0                	add    %edx,%eax
8010a226:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a229:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22c:	8b 00                	mov    (%eax),%eax
8010a22e:	83 e0 04             	and    $0x4,%eax
8010a231:	85 c0                	test   %eax,%eax
8010a233:	74 2b                	je     8010a260 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a235:	8b 45 08             	mov    0x8(%ebp),%eax
8010a238:	8b 00                	mov    (%eax),%eax
8010a23a:	83 e0 fb             	and    $0xfffffffb,%eax
8010a23d:	89 c2                	mov    %eax,%edx
8010a23f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a242:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a244:	8b 45 08             	mov    0x8(%ebp),%eax
8010a247:	83 c0 5c             	add    $0x5c,%eax
8010a24a:	83 ec 04             	sub    $0x4,%esp
8010a24d:	68 00 02 00 00       	push   $0x200
8010a252:	50                   	push   %eax
8010a253:	ff 75 f4             	push   -0xc(%ebp)
8010a256:	e8 1d a9 ff ff       	call   80104b78 <memmove>
8010a25b:	83 c4 10             	add    $0x10,%esp
8010a25e:	eb 1a                	jmp    8010a27a <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a260:	8b 45 08             	mov    0x8(%ebp),%eax
8010a263:	83 c0 5c             	add    $0x5c,%eax
8010a266:	83 ec 04             	sub    $0x4,%esp
8010a269:	68 00 02 00 00       	push   $0x200
8010a26e:	ff 75 f4             	push   -0xc(%ebp)
8010a271:	50                   	push   %eax
8010a272:	e8 01 a9 ff ff       	call   80104b78 <memmove>
8010a277:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a27a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a27d:	8b 00                	mov    (%eax),%eax
8010a27f:	83 c8 02             	or     $0x2,%eax
8010a282:	89 c2                	mov    %eax,%edx
8010a284:	8b 45 08             	mov    0x8(%ebp),%eax
8010a287:	89 10                	mov    %edx,(%eax)
}
8010a289:	90                   	nop
8010a28a:	c9                   	leave  
8010a28b:	c3                   	ret    
