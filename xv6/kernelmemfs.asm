
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
8010005f:	ba 66 33 10 80       	mov    $0x80103366,%edx
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
8010006f:	68 c0 a1 10 80       	push   $0x8010a1c0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 ae 47 00 00       	call   8010482c <initlock>
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
801000bd:	68 c7 a1 10 80       	push   $0x8010a1c7
801000c2:	50                   	push   %eax
801000c3:	e8 07 46 00 00       	call   801046cf <initsleeplock>
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
80100101:	e8 48 47 00 00       	call   8010484e <acquire>
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
80100140:	e8 77 47 00 00       	call   801048bc <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 b4 45 00 00       	call   8010470b <acquiresleep>
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
801001c1:	e8 f6 46 00 00       	call   801048bc <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 33 45 00 00       	call   8010470b <acquiresleep>
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
801001f5:	68 ce a1 10 80       	push   $0x8010a1ce
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
8010022d:	e8 8d 9e 00 00       	call   8010a0bf <iderw>
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
8010024a:	e8 6e 45 00 00       	call   801047bd <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 df a1 10 80       	push   $0x8010a1df
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
80100278:	e8 42 9e 00 00       	call   8010a0bf <iderw>
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
80100293:	e8 25 45 00 00       	call   801047bd <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 e6 a1 10 80       	push   $0x8010a1e6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 b4 44 00 00       	call   8010476f <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 83 45 00 00       	call   8010484e <acquire>
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
80100336:	e8 81 45 00 00       	call   801048bc <release>
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
80100410:	e8 39 44 00 00       	call   8010484e <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ed a1 10 80       	push   $0x8010a1ed
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
80100510:	c7 45 ec f6 a1 10 80 	movl   $0x8010a1f6,-0x14(%ebp)
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
8010059e:	e8 19 43 00 00       	call   801048bc <release>
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
801005be:	e8 38 25 00 00       	call   80102afb <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 fd a1 10 80       	push   $0x8010a1fd
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
801005e6:	68 11 a2 10 80       	push   $0x8010a211
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 0b 43 00 00       	call   8010490e <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 13 a2 10 80       	push   $0x8010a213
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
801006a0:	e8 71 79 00 00       	call   80108016 <graphic_scroll_up>
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
801006f3:	e8 1e 79 00 00       	call   80108016 <graphic_scroll_up>
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
80100757:	e8 25 79 00 00       	call   80108081 <font_render>
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
80100793:	e8 0a 5d 00 00       	call   801064a2 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 fd 5c 00 00       	call   801064a2 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 f0 5c 00 00       	call   801064a2 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 e0 5c 00 00       	call   801064a2 <uartputc>
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
801007eb:	e8 5e 40 00 00       	call   8010484e <acquire>
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
8010093f:	e8 7d 3a 00 00       	call   801043c1 <wakeup>
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
80100962:	e8 55 3f 00 00       	call   801048bc <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 07 3b 00 00       	call   8010447c <procdump>
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
80100984:	e8 75 11 00 00       	call   80101afe <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 af 3e 00 00       	call   8010484e <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 85 30 00 00       	call   80103a31 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 fc 3e 00 00       	call   801048bc <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1d 10 00 00       	call   801019eb <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 ed 38 00 00       	call   801042da <sleep>
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
80100a66:	e8 51 3e 00 00       	call   801048bc <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 72 0f 00 00       	call   801019eb <ilock>
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
80100a92:	e8 67 10 00 00       	call   80101afe <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 a7 3d 00 00       	call   8010484e <acquire>
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
80100ae4:	e8 d3 3d 00 00       	call   801048bc <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f4 0e 00 00       	call   801019eb <ilock>
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
80100b12:	68 17 a2 10 80       	push   $0x8010a217
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 0b 3d 00 00       	call   8010482c <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 1f a2 10 80 	movl   $0x8010a21f,-0xc(%ebp)
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
80100b75:	e8 b5 1a 00 00       	call   8010262f <ioapicenable>
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
80100b83:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a3 2e 00 00       	call   80103a31 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a7 24 00 00       	call   8010303d <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7d 19 00 00       	call   8010251e <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 17 25 00 00       	call   801030c9 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 38 a2 10 80       	push   $0x8010a238
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f2 03 00 00       	jmp    80100fbe <exec+0x43e>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 14 0e 00 00       	call   801019eb <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e3 12 00 00       	call   80101ed7 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 6a 03 00 00    	jne    80100f6a <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 5c 03 00 00    	jne    80100f6d <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 88 68 00 00       	call   8010749e <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 4d 03 00 00    	je     80100f70 <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e0 fe ff ff    	lea    -0x120(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 83 12 00 00       	call   80101ed7 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 13 03 00 00    	jne    80100f73 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c75:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 f3 02 00 00    	jb     80100f76 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100c89:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 da 02 00 00    	jb     80100f79 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100ca5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 db 6b 00 00       	call   80107897 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 b0 02 00 00    	je     80100f7c <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 a0 02 00 00    	jne    80100f7f <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce5:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100ceb:	8b 8d e8 fe ff ff    	mov    -0x118(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 c8 6a 00 00       	call   801077ca <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 75 02 00 00    	js     80100f82 <exec+0x402>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 2c ff ff ff 	movzwl -0xd4(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e1 0e 00 00       	call   80101c1c <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 86 23 00 00       	call   801030c9 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // 스택 시작 위치를 커널 경계 직전으로 설정
uint stktop = KERNBASE - 1;
80100d4a:	c7 45 cc ff ff ff 7f 	movl   $0x7fffffff,-0x34(%ebp)
uint stkbase = stktop - PGSIZE;  // 한 페이지만 할당
80100d51:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100d54:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d59:	89 45 c8             	mov    %eax,-0x38(%ebp)

sz = stkbase;
80100d5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100d5f:	89 45 e0             	mov    %eax,-0x20(%ebp)

if ((sz = allocuvm(pgdir, sz, stktop)) == 0)
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	ff 75 cc             	push   -0x34(%ebp)
80100d68:	ff 75 e0             	push   -0x20(%ebp)
80100d6b:	ff 75 d4             	push   -0x2c(%ebp)
80100d6e:	e8 24 6b 00 00       	call   80107897 <allocuvm>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d79:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7d:	0f 84 02 02 00 00    	je     80100f85 <exec+0x405>
  goto bad;

// 스택 포인터는 스택 최상단에서 시작
sp = stktop;
80100d83:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100d86:	89 45 dc             	mov    %eax,-0x24(%ebp)

// 사이즈 기록
curproc->sz = stktop;
80100d89:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d8c:	8b 55 cc             	mov    -0x34(%ebp),%edx
80100d8f:	89 10                	mov    %edx,(%eax)

  sz=PGROUNDDOWN(0x3000);
  sp = KERNBASE - 1;*/

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d91:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d98:	e9 96 00 00 00       	jmp    80100e33 <exec+0x2b3>
    if(argc >= MAXARG)
80100d9d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100da1:	0f 87 e1 01 00 00    	ja     80100f88 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db4:	01 d0                	add    %edx,%eax
80100db6:	8b 00                	mov    (%eax),%eax
80100db8:	83 ec 0c             	sub    $0xc,%esp
80100dbb:	50                   	push   %eax
80100dbc:	e8 51 3f 00 00       	call   80104d12 <strlen>
80100dc1:	83 c4 10             	add    $0x10,%esp
80100dc4:	89 c2                	mov    %eax,%edx
80100dc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc9:	29 d0                	sub    %edx,%eax
80100dcb:	83 e8 01             	sub    $0x1,%eax
80100dce:	83 e0 fc             	and    $0xfffffffc,%eax
80100dd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de1:	01 d0                	add    %edx,%eax
80100de3:	8b 00                	mov    (%eax),%eax
80100de5:	83 ec 0c             	sub    $0xc,%esp
80100de8:	50                   	push   %eax
80100de9:	e8 24 3f 00 00       	call   80104d12 <strlen>
80100dee:	83 c4 10             	add    $0x10,%esp
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	89 c2                	mov    %eax,%edx
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 c8                	add    %ecx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	52                   	push   %edx
80100e08:	50                   	push   %eax
80100e09:	ff 75 dc             	push   -0x24(%ebp)
80100e0c:	ff 75 d4             	push   -0x2c(%ebp)
80100e0f:	e8 6f 6e 00 00       	call   80107c83 <copyout>
80100e14:	83 c4 10             	add    $0x10,%esp
80100e17:	85 c0                	test   %eax,%eax
80100e19:	0f 88 6c 01 00 00    	js     80100f8b <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e22:	8d 50 03             	lea    0x3(%eax),%edx
80100e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e28:	89 84 95 34 ff ff ff 	mov    %eax,-0xcc(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e2f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e40:	01 d0                	add    %edx,%eax
80100e42:	8b 00                	mov    (%eax),%eax
80100e44:	85 c0                	test   %eax,%eax
80100e46:	0f 85 51 ff ff ff    	jne    80100d9d <exec+0x21d>
  }
  ustack[3+argc] = 0;
80100e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4f:	83 c0 03             	add    $0x3,%eax
80100e52:	c7 84 85 34 ff ff ff 	movl   $0x0,-0xcc(%ebp,%eax,4)
80100e59:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e5d:	c7 85 34 ff ff ff ff 	movl   $0xffffffff,-0xcc(%ebp)
80100e64:	ff ff ff 
  ustack[1] = argc;
80100e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6a:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e73:	83 c0 01             	add    $0x1,%eax
80100e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e80:	29 d0                	sub    %edx,%eax
80100e82:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)

  sp -= (3+argc+1) * 4;
80100e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8b:	83 c0 04             	add    $0x4,%eax
80100e8e:	c1 e0 02             	shl    $0x2,%eax
80100e91:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0){
80100e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e97:	83 c0 04             	add    $0x4,%eax
80100e9a:	c1 e0 02             	shl    $0x2,%eax
80100e9d:	50                   	push   %eax
80100e9e:	8d 85 34 ff ff ff    	lea    -0xcc(%ebp),%eax
80100ea4:	50                   	push   %eax
80100ea5:	ff 75 dc             	push   -0x24(%ebp)
80100ea8:	ff 75 d4             	push   -0x2c(%ebp)
80100eab:	e8 d3 6d 00 00       	call   80107c83 <copyout>
80100eb0:	83 c4 10             	add    $0x10,%esp
80100eb3:	85 c0                	test   %eax,%eax
80100eb5:	79 15                	jns    80100ecc <exec+0x34c>
    cprintf("[exec] copyout of ustack failed\n");
80100eb7:	83 ec 0c             	sub    $0xc,%esp
80100eba:	68 44 a2 10 80       	push   $0x8010a244
80100ebf:	e8 30 f5 ff ff       	call   801003f4 <cprintf>
80100ec4:	83 c4 10             	add    $0x10,%esp
    goto bad;
80100ec7:	e9 c0 00 00 00       	jmp    80100f8c <exec+0x40c>

  }

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed8:	eb 17                	jmp    80100ef1 <exec+0x371>
    if(*s == '/')
80100eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edd:	0f b6 00             	movzbl (%eax),%eax
80100ee0:	3c 2f                	cmp    $0x2f,%al
80100ee2:	75 09                	jne    80100eed <exec+0x36d>
      last = s+1;
80100ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee7:	83 c0 01             	add    $0x1,%eax
80100eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100eed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef4:	0f b6 00             	movzbl (%eax),%eax
80100ef7:	84 c0                	test   %al,%al
80100ef9:	75 df                	jne    80100eda <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100efb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efe:	83 c0 6c             	add    $0x6c,%eax
80100f01:	83 ec 04             	sub    $0x4,%esp
80100f04:	6a 10                	push   $0x10
80100f06:	ff 75 f0             	push   -0x10(%ebp)
80100f09:	50                   	push   %eax
80100f0a:	e8 b8 3d 00 00       	call   80104cc7 <safestrcpy>
80100f0f:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f12:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f15:	8b 40 04             	mov    0x4(%eax),%eax
80100f18:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  curproc->pgdir = pgdir;
80100f1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f21:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f24:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f27:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f2a:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2f:	8b 40 18             	mov    0x18(%eax),%eax
80100f32:	8b 95 18 ff ff ff    	mov    -0xe8(%ebp),%edx
80100f38:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3e:	8b 40 18             	mov    0x18(%eax),%eax
80100f41:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f44:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d0             	push   -0x30(%ebp)
80100f4d:	e8 69 66 00 00       	call   801075bb <switchuvm>
80100f52:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f55:	83 ec 0c             	sub    $0xc,%esp
80100f58:	ff 75 c4             	push   -0x3c(%ebp)
80100f5b:	e8 00 6b 00 00       	call   80107a60 <freevm>
80100f60:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f63:	b8 00 00 00 00       	mov    $0x0,%eax
80100f68:	eb 54                	jmp    80100fbe <exec+0x43e>
    goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 1f                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f6d:	90                   	nop
80100f6e:	eb 1c                	jmp    80100f8c <exec+0x40c>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 19                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f73:	90                   	nop
80100f74:	eb 16                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f76:	90                   	nop
80100f77:	eb 13                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 10                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 0d                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 0a                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 07                	jmp    80100f8c <exec+0x40c>
  goto bad;
80100f85:	90                   	nop
80100f86:	eb 04                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 01                	jmp    80100f8c <exec+0x40c>
      goto bad;
80100f8b:	90                   	nop

 bad:
  if(pgdir)
80100f8c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f90:	74 0e                	je     80100fa0 <exec+0x420>
    freevm(pgdir);
80100f92:	83 ec 0c             	sub    $0xc,%esp
80100f95:	ff 75 d4             	push   -0x2c(%ebp)
80100f98:	e8 c3 6a 00 00       	call   80107a60 <freevm>
80100f9d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa4:	74 13                	je     80100fb9 <exec+0x439>
    iunlockput(ip);
80100fa6:	83 ec 0c             	sub    $0xc,%esp
80100fa9:	ff 75 d8             	push   -0x28(%ebp)
80100fac:	e8 6b 0c 00 00       	call   80101c1c <iunlockput>
80100fb1:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb4:	e8 10 21 00 00       	call   801030c9 <end_op>
  }
  return -1;
80100fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbe:	c9                   	leave  
80100fbf:	c3                   	ret    

80100fc0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc6:	83 ec 08             	sub    $0x8,%esp
80100fc9:	68 65 a2 10 80       	push   $0x8010a265
80100fce:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd3:	e8 54 38 00 00       	call   8010482c <initlock>
80100fd8:	83 c4 10             	add    $0x10,%esp
}
80100fdb:	90                   	nop
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe4:	83 ec 0c             	sub    $0xc,%esp
80100fe7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fec:	e8 5d 38 00 00       	call   8010484e <acquire>
80100ff1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff4:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffb:	eb 2d                	jmp    8010102a <filealloc+0x4c>
    if(f->ref == 0){
80100ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	85 c0                	test   %eax,%eax
80101005:	75 1f                	jne    80101026 <filealloc+0x48>
      f->ref = 1;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101011:	83 ec 0c             	sub    $0xc,%esp
80101014:	68 a0 1a 19 80       	push   $0x80191aa0
80101019:	e8 9e 38 00 00       	call   801048bc <release>
8010101e:	83 c4 10             	add    $0x10,%esp
      return f;
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	eb 23                	jmp    80101049 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101026:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010102a:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101032:	72 c9                	jb     80100ffd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101034:	83 ec 0c             	sub    $0xc,%esp
80101037:	68 a0 1a 19 80       	push   $0x80191aa0
8010103c:	e8 7b 38 00 00       	call   801048bc <release>
80101041:	83 c4 10             	add    $0x10,%esp
  return 0;
80101044:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101049:	c9                   	leave  
8010104a:	c3                   	ret    

8010104b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104b:	55                   	push   %ebp
8010104c:	89 e5                	mov    %esp,%ebp
8010104e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 a0 1a 19 80       	push   $0x80191aa0
80101059:	e8 f0 37 00 00       	call   8010484e <acquire>
8010105e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	8b 40 04             	mov    0x4(%eax),%eax
80101067:	85 c0                	test   %eax,%eax
80101069:	7f 0d                	jg     80101078 <filedup+0x2d>
    panic("filedup");
8010106b:	83 ec 0c             	sub    $0xc,%esp
8010106e:	68 6c a2 10 80       	push   $0x8010a26c
80101073:	e8 31 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101078:	8b 45 08             	mov    0x8(%ebp),%eax
8010107b:	8b 40 04             	mov    0x4(%eax),%eax
8010107e:	8d 50 01             	lea    0x1(%eax),%edx
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 a0 1a 19 80       	push   $0x80191aa0
8010108f:	e8 28 38 00 00       	call   801048bc <release>
80101094:	83 c4 10             	add    $0x10,%esp
  return f;
80101097:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010109a:	c9                   	leave  
8010109b:	c3                   	ret    

8010109c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109c:	55                   	push   %ebp
8010109d:	89 e5                	mov    %esp,%ebp
8010109f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 a0 1a 19 80       	push   $0x80191aa0
801010aa:	e8 9f 37 00 00       	call   8010484e <acquire>
801010af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b2:	8b 45 08             	mov    0x8(%ebp),%eax
801010b5:	8b 40 04             	mov    0x4(%eax),%eax
801010b8:	85 c0                	test   %eax,%eax
801010ba:	7f 0d                	jg     801010c9 <fileclose+0x2d>
    panic("fileclose");
801010bc:	83 ec 0c             	sub    $0xc,%esp
801010bf:	68 74 a2 10 80       	push   $0x8010a274
801010c4:	e8 e0 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	8b 40 04             	mov    0x4(%eax),%eax
801010cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	89 50 04             	mov    %edx,0x4(%eax)
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 40 04             	mov    0x4(%eax),%eax
801010de:	85 c0                	test   %eax,%eax
801010e0:	7e 15                	jle    801010f7 <fileclose+0x5b>
    release(&ftable.lock);
801010e2:	83 ec 0c             	sub    $0xc,%esp
801010e5:	68 a0 1a 19 80       	push   $0x80191aa0
801010ea:	e8 cd 37 00 00       	call   801048bc <release>
801010ef:	83 c4 10             	add    $0x10,%esp
801010f2:	e9 8b 00 00 00       	jmp    80101182 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f7:	8b 45 08             	mov    0x8(%ebp),%eax
801010fa:	8b 10                	mov    (%eax),%edx
801010fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010ff:	8b 50 04             	mov    0x4(%eax),%edx
80101102:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101105:	8b 50 08             	mov    0x8(%eax),%edx
80101108:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110b:	8b 50 0c             	mov    0xc(%eax),%edx
8010110e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101111:	8b 50 10             	mov    0x10(%eax),%edx
80101114:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101117:	8b 40 14             	mov    0x14(%eax),%eax
8010111a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111d:	8b 45 08             	mov    0x8(%ebp),%eax
80101120:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101127:	8b 45 08             	mov    0x8(%ebp),%eax
8010112a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101130:	83 ec 0c             	sub    $0xc,%esp
80101133:	68 a0 1a 19 80       	push   $0x80191aa0
80101138:	e8 7f 37 00 00       	call   801048bc <release>
8010113d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101140:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101143:	83 f8 01             	cmp    $0x1,%eax
80101146:	75 19                	jne    80101161 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101148:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114c:	0f be d0             	movsbl %al,%edx
8010114f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101152:	83 ec 08             	sub    $0x8,%esp
80101155:	52                   	push   %edx
80101156:	50                   	push   %eax
80101157:	e8 64 25 00 00       	call   801036c0 <pipeclose>
8010115c:	83 c4 10             	add    $0x10,%esp
8010115f:	eb 21                	jmp    80101182 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101161:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 19                	jne    80101182 <fileclose+0xe6>
    begin_op();
80101169:	e8 cf 1e 00 00       	call   8010303d <begin_op>
    iput(ff.ip);
8010116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	50                   	push   %eax
80101175:	e8 d2 09 00 00       	call   80101b4c <iput>
8010117a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117d:	e8 47 1f 00 00       	call   801030c9 <end_op>
  }
}
80101182:	c9                   	leave  
80101183:	c3                   	ret    

80101184 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101184:	55                   	push   %ebp
80101185:	89 e5                	mov    %esp,%ebp
80101187:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 00                	mov    (%eax),%eax
8010118f:	83 f8 02             	cmp    $0x2,%eax
80101192:	75 40                	jne    801011d4 <filestat+0x50>
    ilock(f->ip);
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 40 10             	mov    0x10(%eax),%eax
8010119a:	83 ec 0c             	sub    $0xc,%esp
8010119d:	50                   	push   %eax
8010119e:	e8 48 08 00 00       	call   801019eb <ilock>
801011a3:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	8b 40 10             	mov    0x10(%eax),%eax
801011ac:	83 ec 08             	sub    $0x8,%esp
801011af:	ff 75 0c             	push   0xc(%ebp)
801011b2:	50                   	push   %eax
801011b3:	e8 d9 0c 00 00       	call   80101e91 <stati>
801011b8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011bb:	8b 45 08             	mov    0x8(%ebp),%eax
801011be:	8b 40 10             	mov    0x10(%eax),%eax
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	50                   	push   %eax
801011c5:	e8 34 09 00 00       	call   80101afe <iunlock>
801011ca:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cd:	b8 00 00 00 00       	mov    $0x0,%eax
801011d2:	eb 05                	jmp    801011d9 <filestat+0x55>
  }
  return -1;
801011d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    

801011db <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011db:	55                   	push   %ebp
801011dc:	89 e5                	mov    %esp,%ebp
801011de:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e8:	84 c0                	test   %al,%al
801011ea:	75 0a                	jne    801011f6 <fileread+0x1b>
    return -1;
801011ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f1:	e9 9b 00 00 00       	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 01             	cmp    $0x1,%eax
801011fe:	75 1a                	jne    8010121a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 40 0c             	mov    0xc(%eax),%eax
80101206:	83 ec 04             	sub    $0x4,%esp
80101209:	ff 75 10             	push   0x10(%ebp)
8010120c:	ff 75 0c             	push   0xc(%ebp)
8010120f:	50                   	push   %eax
80101210:	e8 58 26 00 00       	call   8010386d <piperead>
80101215:	83 c4 10             	add    $0x10,%esp
80101218:	eb 77                	jmp    80101291 <fileread+0xb6>
  if(f->type == FD_INODE){
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 00                	mov    (%eax),%eax
8010121f:	83 f8 02             	cmp    $0x2,%eax
80101222:	75 60                	jne    80101284 <fileread+0xa9>
    ilock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 10             	mov    0x10(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 b8 07 00 00       	call   801019eb <ilock>
80101233:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101236:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	8b 50 14             	mov    0x14(%eax),%edx
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 10             	mov    0x10(%eax),%eax
80101245:	51                   	push   %ecx
80101246:	52                   	push   %edx
80101247:	ff 75 0c             	push   0xc(%ebp)
8010124a:	50                   	push   %eax
8010124b:	e8 87 0c 00 00       	call   80101ed7 <readi>
80101250:	83 c4 10             	add    $0x10,%esp
80101253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010125a:	7e 11                	jle    8010126d <fileread+0x92>
      f->off += r;
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 50 14             	mov    0x14(%eax),%edx
80101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101265:	01 c2                	add    %eax,%edx
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 40 10             	mov    0x10(%eax),%eax
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	50                   	push   %eax
80101277:	e8 82 08 00 00       	call   80101afe <iunlock>
8010127c:	83 c4 10             	add    $0x10,%esp
    return r;
8010127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101282:	eb 0d                	jmp    80101291 <fileread+0xb6>
  }
  panic("fileread");
80101284:	83 ec 0c             	sub    $0xc,%esp
80101287:	68 7e a2 10 80       	push   $0x8010a27e
8010128c:	e8 18 f3 ff ff       	call   801005a9 <panic>
}
80101291:	c9                   	leave  
80101292:	c3                   	ret    

80101293 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101293:	55                   	push   %ebp
80101294:	89 e5                	mov    %esp,%ebp
80101296:	53                   	push   %ebx
80101297:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010129a:	8b 45 08             	mov    0x8(%ebp),%eax
8010129d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a1:	84 c0                	test   %al,%al
801012a3:	75 0a                	jne    801012af <filewrite+0x1c>
    return -1;
801012a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012aa:	e9 1b 01 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_PIPE)
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 00                	mov    (%eax),%eax
801012b4:	83 f8 01             	cmp    $0x1,%eax
801012b7:	75 1d                	jne    801012d6 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 40 0c             	mov    0xc(%eax),%eax
801012bf:	83 ec 04             	sub    $0x4,%esp
801012c2:	ff 75 10             	push   0x10(%ebp)
801012c5:	ff 75 0c             	push   0xc(%ebp)
801012c8:	50                   	push   %eax
801012c9:	e8 9d 24 00 00       	call   8010376b <pipewrite>
801012ce:	83 c4 10             	add    $0x10,%esp
801012d1:	e9 f4 00 00 00       	jmp    801013ca <filewrite+0x137>
  if(f->type == FD_INODE){
801012d6:	8b 45 08             	mov    0x8(%ebp),%eax
801012d9:	8b 00                	mov    (%eax),%eax
801012db:	83 f8 02             	cmp    $0x2,%eax
801012de:	0f 85 d9 00 00 00    	jne    801013bd <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f2:	e9 a3 00 00 00       	jmp    8010139a <filewrite+0x107>
      int n1 = n - i;
801012f7:	8b 45 10             	mov    0x10(%ebp),%eax
801012fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101303:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101306:	7e 06                	jle    8010130e <filewrite+0x7b>
        n1 = max;
80101308:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130e:	e8 2a 1d 00 00       	call   8010303d <begin_op>
      ilock(f->ip);
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	8b 40 10             	mov    0x10(%eax),%eax
80101319:	83 ec 0c             	sub    $0xc,%esp
8010131c:	50                   	push   %eax
8010131d:	e8 c9 06 00 00       	call   801019eb <ilock>
80101322:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101325:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101328:	8b 45 08             	mov    0x8(%ebp),%eax
8010132b:	8b 50 14             	mov    0x14(%eax),%edx
8010132e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101331:	8b 45 0c             	mov    0xc(%ebp),%eax
80101334:	01 c3                	add    %eax,%ebx
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 40 10             	mov    0x10(%eax),%eax
8010133c:	51                   	push   %ecx
8010133d:	52                   	push   %edx
8010133e:	53                   	push   %ebx
8010133f:	50                   	push   %eax
80101340:	e8 e7 0c 00 00       	call   8010202c <writei>
80101345:	83 c4 10             	add    $0x10,%esp
80101348:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134f:	7e 11                	jle    80101362 <filewrite+0xcf>
        f->off += r;
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	8b 50 14             	mov    0x14(%eax),%edx
80101357:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135a:	01 c2                	add    %eax,%edx
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 40 10             	mov    0x10(%eax),%eax
80101368:	83 ec 0c             	sub    $0xc,%esp
8010136b:	50                   	push   %eax
8010136c:	e8 8d 07 00 00       	call   80101afe <iunlock>
80101371:	83 c4 10             	add    $0x10,%esp
      end_op();
80101374:	e8 50 1d 00 00       	call   801030c9 <end_op>

      if(r < 0)
80101379:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137d:	78 29                	js     801013a8 <filewrite+0x115>
        break;
      if(r != n1)
8010137f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101382:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101385:	74 0d                	je     80101394 <filewrite+0x101>
        panic("short filewrite");
80101387:	83 ec 0c             	sub    $0xc,%esp
8010138a:	68 87 a2 10 80       	push   $0x8010a287
8010138f:	e8 15 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101394:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101397:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a0:	0f 8c 51 ff ff ff    	jl     801012f7 <filewrite+0x64>
801013a6:	eb 01                	jmp    801013a9 <filewrite+0x116>
        break;
801013a8:	90                   	nop
    }
    return i == n ? n : -1;
801013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801013af:	75 05                	jne    801013b6 <filewrite+0x123>
801013b1:	8b 45 10             	mov    0x10(%ebp),%eax
801013b4:	eb 14                	jmp    801013ca <filewrite+0x137>
801013b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013bb:	eb 0d                	jmp    801013ca <filewrite+0x137>
  }
  panic("filewrite");
801013bd:	83 ec 0c             	sub    $0xc,%esp
801013c0:	68 97 a2 10 80       	push   $0x8010a297
801013c5:	e8 df f1 ff ff       	call   801005a9 <panic>
}
801013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cd:	c9                   	leave  
801013ce:	c3                   	ret    

801013cf <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013cf:	55                   	push   %ebp
801013d0:	89 e5                	mov    %esp,%ebp
801013d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	83 ec 08             	sub    $0x8,%esp
801013db:	6a 01                	push   $0x1
801013dd:	50                   	push   %eax
801013de:	e8 1e ee ff ff       	call   80100201 <bread>
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ec:	83 c0 5c             	add    $0x5c,%eax
801013ef:	83 ec 04             	sub    $0x4,%esp
801013f2:	6a 1c                	push   $0x1c
801013f4:	50                   	push   %eax
801013f5:	ff 75 0c             	push   0xc(%ebp)
801013f8:	e8 86 37 00 00       	call   80104b83 <memmove>
801013fd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	ff 75 f4             	push   -0xc(%ebp)
80101406:	e8 78 ee ff ff       	call   80100283 <brelse>
8010140b:	83 c4 10             	add    $0x10,%esp
}
8010140e:	90                   	nop
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101417:	8b 55 0c             	mov    0xc(%ebp),%edx
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	52                   	push   %edx
80101421:	50                   	push   %eax
80101422:	e8 da ed ff ff       	call   80100201 <bread>
80101427:	83 c4 10             	add    $0x10,%esp
8010142a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101430:	83 c0 5c             	add    $0x5c,%eax
80101433:	83 ec 04             	sub    $0x4,%esp
80101436:	68 00 02 00 00       	push   $0x200
8010143b:	6a 00                	push   $0x0
8010143d:	50                   	push   %eax
8010143e:	e8 81 36 00 00       	call   80104ac4 <memset>
80101443:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101446:	83 ec 0c             	sub    $0xc,%esp
80101449:	ff 75 f4             	push   -0xc(%ebp)
8010144c:	e8 25 1e 00 00       	call   80103276 <log_write>
80101451:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101454:	83 ec 0c             	sub    $0xc,%esp
80101457:	ff 75 f4             	push   -0xc(%ebp)
8010145a:	e8 24 ee ff ff       	call   80100283 <brelse>
8010145f:	83 c4 10             	add    $0x10,%esp
}
80101462:	90                   	nop
80101463:	c9                   	leave  
80101464:	c3                   	ret    

80101465 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101465:	55                   	push   %ebp
80101466:	89 e5                	mov    %esp,%ebp
80101468:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101479:	e9 0b 01 00 00       	jmp    80101589 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101481:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101487:	85 c0                	test   %eax,%eax
80101489:	0f 48 c2             	cmovs  %edx,%eax
8010148c:	c1 f8 0c             	sar    $0xc,%eax
8010148f:	89 c2                	mov    %eax,%edx
80101491:	a1 58 24 19 80       	mov    0x80192458,%eax
80101496:	01 d0                	add    %edx,%eax
80101498:	83 ec 08             	sub    $0x8,%esp
8010149b:	50                   	push   %eax
8010149c:	ff 75 08             	push   0x8(%ebp)
8010149f:	e8 5d ed ff ff       	call   80100201 <bread>
801014a4:	83 c4 10             	add    $0x10,%esp
801014a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b1:	e9 9e 00 00 00       	jmp    80101554 <balloc+0xef>
      m = 1 << (bi % 8);
801014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b9:	83 e0 07             	and    $0x7,%eax
801014bc:	ba 01 00 00 00       	mov    $0x1,%edx
801014c1:	89 c1                	mov    %eax,%ecx
801014c3:	d3 e2                	shl    %cl,%edx
801014c5:	89 d0                	mov    %edx,%eax
801014c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cd:	8d 50 07             	lea    0x7(%eax),%edx
801014d0:	85 c0                	test   %eax,%eax
801014d2:	0f 48 c2             	cmovs  %edx,%eax
801014d5:	c1 f8 03             	sar    $0x3,%eax
801014d8:	89 c2                	mov    %eax,%edx
801014da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e2:	0f b6 c0             	movzbl %al,%eax
801014e5:	23 45 e8             	and    -0x18(%ebp),%eax
801014e8:	85 c0                	test   %eax,%eax
801014ea:	75 64                	jne    80101550 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ef:	8d 50 07             	lea    0x7(%eax),%edx
801014f2:	85 c0                	test   %eax,%eax
801014f4:	0f 48 c2             	cmovs  %edx,%eax
801014f7:	c1 f8 03             	sar    $0x3,%eax
801014fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fd:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101502:	89 d1                	mov    %edx,%ecx
80101504:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101507:	09 ca                	or     %ecx,%edx
80101509:	89 d1                	mov    %edx,%ecx
8010150b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101512:	83 ec 0c             	sub    $0xc,%esp
80101515:	ff 75 ec             	push   -0x14(%ebp)
80101518:	e8 59 1d 00 00       	call   80103276 <log_write>
8010151d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101520:	83 ec 0c             	sub    $0xc,%esp
80101523:	ff 75 ec             	push   -0x14(%ebp)
80101526:	e8 58 ed ff ff       	call   80100283 <brelse>
8010152b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101534:	01 c2                	add    %eax,%edx
80101536:	8b 45 08             	mov    0x8(%ebp),%eax
80101539:	83 ec 08             	sub    $0x8,%esp
8010153c:	52                   	push   %edx
8010153d:	50                   	push   %eax
8010153e:	e8 ce fe ff ff       	call   80101411 <bzero>
80101543:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154c:	01 d0                	add    %edx,%eax
8010154e:	eb 57                	jmp    801015a7 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101550:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101554:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155b:	7f 17                	jg     80101574 <balloc+0x10f>
8010155d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101560:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101563:	01 d0                	add    %edx,%eax
80101565:	89 c2                	mov    %eax,%edx
80101567:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156c:	39 c2                	cmp    %eax,%edx
8010156e:	0f 82 42 ff ff ff    	jb     801014b6 <balloc+0x51>
      }
    }
    brelse(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 ec             	push   -0x14(%ebp)
8010157a:	e8 04 ed ff ff       	call   80100283 <brelse>
8010157f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101582:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101589:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101592:	39 c2                	cmp    %eax,%edx
80101594:	0f 87 e4 fe ff ff    	ja     8010147e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010159a:	83 ec 0c             	sub    $0xc,%esp
8010159d:	68 a4 a2 10 80       	push   $0x8010a2a4
801015a2:	e8 02 f0 ff ff       	call   801005a9 <panic>
}
801015a7:	c9                   	leave  
801015a8:	c3                   	ret    

801015a9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a9:	55                   	push   %ebp
801015aa:	89 e5                	mov    %esp,%ebp
801015ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015af:	83 ec 08             	sub    $0x8,%esp
801015b2:	68 40 24 19 80       	push   $0x80192440
801015b7:	ff 75 08             	push   0x8(%ebp)
801015ba:	e8 10 fe ff ff       	call   801013cf <readsb>
801015bf:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c5:	c1 e8 0c             	shr    $0xc,%eax
801015c8:	89 c2                	mov    %eax,%edx
801015ca:	a1 58 24 19 80       	mov    0x80192458,%eax
801015cf:	01 c2                	add    %eax,%edx
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	52                   	push   %edx
801015d8:	50                   	push   %eax
801015d9:	e8 23 ec ff ff       	call   80100201 <bread>
801015de:	83 c4 10             	add    $0x10,%esp
801015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e7:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f2:	83 e0 07             	and    $0x7,%eax
801015f5:	ba 01 00 00 00       	mov    $0x1,%edx
801015fa:	89 c1                	mov    %eax,%ecx
801015fc:	d3 e2                	shl    %cl,%edx
801015fe:	89 d0                	mov    %edx,%eax
80101600:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101606:	8d 50 07             	lea    0x7(%eax),%edx
80101609:	85 c0                	test   %eax,%eax
8010160b:	0f 48 c2             	cmovs  %edx,%eax
8010160e:	c1 f8 03             	sar    $0x3,%eax
80101611:	89 c2                	mov    %eax,%edx
80101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101616:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161b:	0f b6 c0             	movzbl %al,%eax
8010161e:	23 45 ec             	and    -0x14(%ebp),%eax
80101621:	85 c0                	test   %eax,%eax
80101623:	75 0d                	jne    80101632 <bfree+0x89>
    panic("freeing free block");
80101625:	83 ec 0c             	sub    $0xc,%esp
80101628:	68 ba a2 10 80       	push   $0x8010a2ba
8010162d:	e8 77 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	8d 50 07             	lea    0x7(%eax),%edx
80101638:	85 c0                	test   %eax,%eax
8010163a:	0f 48 c2             	cmovs  %edx,%eax
8010163d:	c1 f8 03             	sar    $0x3,%eax
80101640:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101643:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101648:	89 d1                	mov    %edx,%ecx
8010164a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164d:	f7 d2                	not    %edx
8010164f:	21 ca                	and    %ecx,%edx
80101651:	89 d1                	mov    %edx,%ecx
80101653:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101656:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 f4             	push   -0xc(%ebp)
80101660:	e8 11 1c 00 00       	call   80103276 <log_write>
80101665:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	ff 75 f4             	push   -0xc(%ebp)
8010166e:	e8 10 ec ff ff       	call   80100283 <brelse>
80101673:	83 c4 10             	add    $0x10,%esp
}
80101676:	90                   	nop
80101677:	c9                   	leave  
80101678:	c3                   	ret    

80101679 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101679:	55                   	push   %ebp
8010167a:	89 e5                	mov    %esp,%ebp
8010167c:	57                   	push   %edi
8010167d:	56                   	push   %esi
8010167e:	53                   	push   %ebx
8010167f:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101682:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101689:	83 ec 08             	sub    $0x8,%esp
8010168c:	68 cd a2 10 80       	push   $0x8010a2cd
80101691:	68 60 24 19 80       	push   $0x80192460
80101696:	e8 91 31 00 00       	call   8010482c <initlock>
8010169b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a5:	eb 2d                	jmp    801016d4 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016aa:	89 d0                	mov    %edx,%eax
801016ac:	c1 e0 03             	shl    $0x3,%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	c1 e0 04             	shl    $0x4,%eax
801016b4:	83 c0 30             	add    $0x30,%eax
801016b7:	05 60 24 19 80       	add    $0x80192460,%eax
801016bc:	83 c0 10             	add    $0x10,%eax
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	68 d4 a2 10 80       	push   $0x8010a2d4
801016c7:	50                   	push   %eax
801016c8:	e8 02 30 00 00       	call   801046cf <initsleeplock>
801016cd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d4:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d8:	7e cd                	jle    801016a7 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016da:	83 ec 08             	sub    $0x8,%esp
801016dd:	68 40 24 19 80       	push   $0x80192440
801016e2:	ff 75 08             	push   0x8(%ebp)
801016e5:	e8 e5 fc ff ff       	call   801013cf <readsb>
801016ea:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ed:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f5:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fb:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101701:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101707:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170d:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101713:	a1 40 24 19 80       	mov    0x80192440,%eax
80101718:	ff 75 d4             	push   -0x2c(%ebp)
8010171b:	57                   	push   %edi
8010171c:	56                   	push   %esi
8010171d:	53                   	push   %ebx
8010171e:	51                   	push   %ecx
8010171f:	52                   	push   %edx
80101720:	50                   	push   %eax
80101721:	68 dc a2 10 80       	push   $0x8010a2dc
80101726:	e8 c9 ec ff ff       	call   801003f4 <cprintf>
8010172b:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172e:	90                   	nop
8010172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101732:	5b                   	pop    %ebx
80101733:	5e                   	pop    %esi
80101734:	5f                   	pop    %edi
80101735:	5d                   	pop    %ebp
80101736:	c3                   	ret    

80101737 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	83 ec 28             	sub    $0x28,%esp
8010173d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101740:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101744:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174b:	e9 9e 00 00 00       	jmp    801017ee <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101753:	c1 e8 03             	shr    $0x3,%eax
80101756:	89 c2                	mov    %eax,%edx
80101758:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175d:	01 d0                	add    %edx,%eax
8010175f:	83 ec 08             	sub    $0x8,%esp
80101762:	50                   	push   %eax
80101763:	ff 75 08             	push   0x8(%ebp)
80101766:	e8 96 ea ff ff       	call   80100201 <bread>
8010176b:	83 c4 10             	add    $0x10,%esp
8010176e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101774:	8d 50 5c             	lea    0x5c(%eax),%edx
80101777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177a:	83 e0 07             	and    $0x7,%eax
8010177d:	c1 e0 06             	shl    $0x6,%eax
80101780:	01 d0                	add    %edx,%eax
80101782:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101785:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101788:	0f b7 00             	movzwl (%eax),%eax
8010178b:	66 85 c0             	test   %ax,%ax
8010178e:	75 4c                	jne    801017dc <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101790:	83 ec 04             	sub    $0x4,%esp
80101793:	6a 40                	push   $0x40
80101795:	6a 00                	push   $0x0
80101797:	ff 75 ec             	push   -0x14(%ebp)
8010179a:	e8 25 33 00 00       	call   80104ac4 <memset>
8010179f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a5:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a9:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ac:	83 ec 0c             	sub    $0xc,%esp
801017af:	ff 75 f0             	push   -0x10(%ebp)
801017b2:	e8 bf 1a 00 00       	call   80103276 <log_write>
801017b7:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017ba:	83 ec 0c             	sub    $0xc,%esp
801017bd:	ff 75 f0             	push   -0x10(%ebp)
801017c0:	e8 be ea ff ff       	call   80100283 <brelse>
801017c5:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	83 ec 08             	sub    $0x8,%esp
801017ce:	50                   	push   %eax
801017cf:	ff 75 08             	push   0x8(%ebp)
801017d2:	e8 f8 00 00 00       	call   801018cf <iget>
801017d7:	83 c4 10             	add    $0x10,%esp
801017da:	eb 30                	jmp    8010180c <ialloc+0xd5>
    }
    brelse(bp);
801017dc:	83 ec 0c             	sub    $0xc,%esp
801017df:	ff 75 f0             	push   -0x10(%ebp)
801017e2:	e8 9c ea ff ff       	call   80100283 <brelse>
801017e7:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ee:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	39 c2                	cmp    %eax,%edx
801017f9:	0f 87 51 ff ff ff    	ja     80101750 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ff:	83 ec 0c             	sub    $0xc,%esp
80101802:	68 2f a3 10 80       	push   $0x8010a32f
80101807:	e8 9d ed ff ff       	call   801005a9 <panic>
}
8010180c:	c9                   	leave  
8010180d:	c3                   	ret    

8010180e <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180e:	55                   	push   %ebp
8010180f:	89 e5                	mov    %esp,%ebp
80101811:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101814:	8b 45 08             	mov    0x8(%ebp),%eax
80101817:	8b 40 04             	mov    0x4(%eax),%eax
8010181a:	c1 e8 03             	shr    $0x3,%eax
8010181d:	89 c2                	mov    %eax,%edx
8010181f:	a1 54 24 19 80       	mov    0x80192454,%eax
80101824:	01 c2                	add    %eax,%edx
80101826:	8b 45 08             	mov    0x8(%ebp),%eax
80101829:	8b 00                	mov    (%eax),%eax
8010182b:	83 ec 08             	sub    $0x8,%esp
8010182e:	52                   	push   %edx
8010182f:	50                   	push   %eax
80101830:	e8 cc e9 ff ff       	call   80100201 <bread>
80101835:	83 c4 10             	add    $0x10,%esp
80101838:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101841:	8b 45 08             	mov    0x8(%ebp),%eax
80101844:	8b 40 04             	mov    0x4(%eax),%eax
80101847:	83 e0 07             	and    $0x7,%eax
8010184a:	c1 e0 06             	shl    $0x6,%eax
8010184d:	01 d0                	add    %edx,%eax
8010184f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101852:	8b 45 08             	mov    0x8(%ebp),%eax
80101855:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186d:	8b 45 08             	mov    0x8(%ebp),%eax
80101870:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101877:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101885:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101889:	8b 45 08             	mov    0x8(%ebp),%eax
8010188c:	8b 50 58             	mov    0x58(%eax),%edx
8010188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101892:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101895:	8b 45 08             	mov    0x8(%ebp),%eax
80101898:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189e:	83 c0 0c             	add    $0xc,%eax
801018a1:	83 ec 04             	sub    $0x4,%esp
801018a4:	6a 34                	push   $0x34
801018a6:	52                   	push   %edx
801018a7:	50                   	push   %eax
801018a8:	e8 d6 32 00 00       	call   80104b83 <memmove>
801018ad:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	ff 75 f4             	push   -0xc(%ebp)
801018b6:	e8 bb 19 00 00       	call   80103276 <log_write>
801018bb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018be:	83 ec 0c             	sub    $0xc,%esp
801018c1:	ff 75 f4             	push   -0xc(%ebp)
801018c4:	e8 ba e9 ff ff       	call   80100283 <brelse>
801018c9:	83 c4 10             	add    $0x10,%esp
}
801018cc:	90                   	nop
801018cd:	c9                   	leave  
801018ce:	c3                   	ret    

801018cf <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018cf:	55                   	push   %ebp
801018d0:	89 e5                	mov    %esp,%ebp
801018d2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d5:	83 ec 0c             	sub    $0xc,%esp
801018d8:	68 60 24 19 80       	push   $0x80192460
801018dd:	e8 6c 2f 00 00       	call   8010484e <acquire>
801018e2:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ec:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f3:	eb 60                	jmp    80101955 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f8:	8b 40 08             	mov    0x8(%eax),%eax
801018fb:	85 c0                	test   %eax,%eax
801018fd:	7e 39                	jle    80101938 <iget+0x69>
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	8b 00                	mov    (%eax),%eax
80101904:	39 45 08             	cmp    %eax,0x8(%ebp)
80101907:	75 2f                	jne    80101938 <iget+0x69>
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 40 04             	mov    0x4(%eax),%eax
8010190f:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101912:	75 24                	jne    80101938 <iget+0x69>
      ip->ref++;
80101914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101917:	8b 40 08             	mov    0x8(%eax),%eax
8010191a:	8d 50 01             	lea    0x1(%eax),%edx
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101923:	83 ec 0c             	sub    $0xc,%esp
80101926:	68 60 24 19 80       	push   $0x80192460
8010192b:	e8 8c 2f 00 00       	call   801048bc <release>
80101930:	83 c4 10             	add    $0x10,%esp
      return ip;
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	eb 77                	jmp    801019af <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193c:	75 10                	jne    8010194e <iget+0x7f>
8010193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101941:	8b 40 08             	mov    0x8(%eax),%eax
80101944:	85 c0                	test   %eax,%eax
80101946:	75 06                	jne    8010194e <iget+0x7f>
      empty = ip;
80101948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101955:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195c:	72 97                	jb     801018f5 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101962:	75 0d                	jne    80101971 <iget+0xa2>
    panic("iget: no inodes");
80101964:	83 ec 0c             	sub    $0xc,%esp
80101967:	68 41 a3 10 80       	push   $0x8010a341
8010196c:	e8 38 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	8b 55 08             	mov    0x8(%ebp),%edx
8010197d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	8b 55 0c             	mov    0xc(%ebp),%edx
80101985:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199c:	83 ec 0c             	sub    $0xc,%esp
8010199f:	68 60 24 19 80       	push   $0x80192460
801019a4:	e8 13 2f 00 00       	call   801048bc <release>
801019a9:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019af:	c9                   	leave  
801019b0:	c3                   	ret    

801019b1 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b1:	55                   	push   %ebp
801019b2:	89 e5                	mov    %esp,%ebp
801019b4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b7:	83 ec 0c             	sub    $0xc,%esp
801019ba:	68 60 24 19 80       	push   $0x80192460
801019bf:	e8 8a 2e 00 00       	call   8010484e <acquire>
801019c4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	8d 50 01             	lea    0x1(%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	68 60 24 19 80       	push   $0x80192460
801019de:	e8 d9 2e 00 00       	call   801048bc <release>
801019e3:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e9:	c9                   	leave  
801019ea:	c3                   	ret    

801019eb <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019eb:	55                   	push   %ebp
801019ec:	89 e5                	mov    %esp,%ebp
801019ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f5:	74 0a                	je     80101a01 <ilock+0x16>
801019f7:	8b 45 08             	mov    0x8(%ebp),%eax
801019fa:	8b 40 08             	mov    0x8(%eax),%eax
801019fd:	85 c0                	test   %eax,%eax
801019ff:	7f 0d                	jg     80101a0e <ilock+0x23>
    panic("ilock");
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	68 51 a3 10 80       	push   $0x8010a351
80101a09:	e8 9b eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	50                   	push   %eax
80101a18:	e8 ee 2c 00 00       	call   8010470b <acquiresleep>
80101a1d:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a26:	85 c0                	test   %eax,%eax
80101a28:	0f 85 cd 00 00 00    	jne    80101afb <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a31:	8b 40 04             	mov    0x4(%eax),%eax
80101a34:	c1 e8 03             	shr    $0x3,%eax
80101a37:	89 c2                	mov    %eax,%edx
80101a39:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3e:	01 c2                	add    %eax,%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 00                	mov    (%eax),%eax
80101a45:	83 ec 08             	sub    $0x8,%esp
80101a48:	52                   	push   %edx
80101a49:	50                   	push   %eax
80101a4a:	e8 b2 e7 ff ff       	call   80100201 <bread>
80101a4f:	83 c4 10             	add    $0x10,%esp
80101a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a58:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 04             	mov    0x4(%eax),%eax
80101a61:	83 e0 07             	and    $0x7,%eax
80101a64:	c1 e0 06             	shl    $0x6,%eax
80101a67:	01 d0                	add    %edx,%eax
80101a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6f:	0f b7 10             	movzwl (%eax),%edx
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a98:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa6:	8b 50 08             	mov    0x8(%eax),%edx
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab2:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	83 c0 5c             	add    $0x5c,%eax
80101abb:	83 ec 04             	sub    $0x4,%esp
80101abe:	6a 34                	push   $0x34
80101ac0:	52                   	push   %edx
80101ac1:	50                   	push   %eax
80101ac2:	e8 bc 30 00 00       	call   80104b83 <memmove>
80101ac7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aca:	83 ec 0c             	sub    $0xc,%esp
80101acd:	ff 75 f4             	push   -0xc(%ebp)
80101ad0:	e8 ae e7 ff ff       	call   80100283 <brelse>
80101ad5:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae9:	66 85 c0             	test   %ax,%ax
80101aec:	75 0d                	jne    80101afb <ilock+0x110>
      panic("ilock: no type");
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	68 57 a3 10 80       	push   $0x8010a357
80101af6:	e8 ae ea ff ff       	call   801005a9 <panic>
  }
}
80101afb:	90                   	nop
80101afc:	c9                   	leave  
80101afd:	c3                   	ret    

80101afe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afe:	55                   	push   %ebp
80101aff:	89 e5                	mov    %esp,%ebp
80101b01:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b08:	74 20                	je     80101b2a <iunlock+0x2c>
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	83 c0 0c             	add    $0xc,%eax
80101b10:	83 ec 0c             	sub    $0xc,%esp
80101b13:	50                   	push   %eax
80101b14:	e8 a4 2c 00 00       	call   801047bd <holdingsleep>
80101b19:	83 c4 10             	add    $0x10,%esp
80101b1c:	85 c0                	test   %eax,%eax
80101b1e:	74 0a                	je     80101b2a <iunlock+0x2c>
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 40 08             	mov    0x8(%eax),%eax
80101b26:	85 c0                	test   %eax,%eax
80101b28:	7f 0d                	jg     80101b37 <iunlock+0x39>
    panic("iunlock");
80101b2a:	83 ec 0c             	sub    $0xc,%esp
80101b2d:	68 66 a3 10 80       	push   $0x8010a366
80101b32:	e8 72 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	83 c0 0c             	add    $0xc,%eax
80101b3d:	83 ec 0c             	sub    $0xc,%esp
80101b40:	50                   	push   %eax
80101b41:	e8 29 2c 00 00       	call   8010476f <releasesleep>
80101b46:	83 c4 10             	add    $0x10,%esp
}
80101b49:	90                   	nop
80101b4a:	c9                   	leave  
80101b4b:	c3                   	ret    

80101b4c <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4c:	55                   	push   %ebp
80101b4d:	89 e5                	mov    %esp,%ebp
80101b4f:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b52:	8b 45 08             	mov    0x8(%ebp),%eax
80101b55:	83 c0 0c             	add    $0xc,%eax
80101b58:	83 ec 0c             	sub    $0xc,%esp
80101b5b:	50                   	push   %eax
80101b5c:	e8 aa 2b 00 00       	call   8010470b <acquiresleep>
80101b61:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b6a:	85 c0                	test   %eax,%eax
80101b6c:	74 6a                	je     80101bd8 <iput+0x8c>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b75:	66 85 c0             	test   %ax,%ax
80101b78:	75 5e                	jne    80101bd8 <iput+0x8c>
    acquire(&icache.lock);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	68 60 24 19 80       	push   $0x80192460
80101b82:	e8 c7 2c 00 00       	call   8010484e <acquire>
80101b87:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	8b 40 08             	mov    0x8(%eax),%eax
80101b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b93:	83 ec 0c             	sub    $0xc,%esp
80101b96:	68 60 24 19 80       	push   $0x80192460
80101b9b:	e8 1c 2d 00 00       	call   801048bc <release>
80101ba0:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba7:	75 2f                	jne    80101bd8 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	ff 75 08             	push   0x8(%ebp)
80101baf:	e8 ad 01 00 00       	call   80101d61 <itrunc>
80101bb4:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	ff 75 08             	push   0x8(%ebp)
80101bc6:	e8 43 fc ff ff       	call   8010180e <iupdate>
80101bcb:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	83 c0 0c             	add    $0xc,%eax
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	50                   	push   %eax
80101be2:	e8 88 2b 00 00       	call   8010476f <releasesleep>
80101be7:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	68 60 24 19 80       	push   $0x80192460
80101bf2:	e8 57 2c 00 00       	call   8010484e <acquire>
80101bf7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	68 60 24 19 80       	push   $0x80192460
80101c11:	e8 a6 2c 00 00       	call   801048bc <release>
80101c16:	83 c4 10             	add    $0x10,%esp
}
80101c19:	90                   	nop
80101c1a:	c9                   	leave  
80101c1b:	c3                   	ret    

80101c1c <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1c:	55                   	push   %ebp
80101c1d:	89 e5                	mov    %esp,%ebp
80101c1f:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	ff 75 08             	push   0x8(%ebp)
80101c28:	e8 d1 fe ff ff       	call   80101afe <iunlock>
80101c2d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	push   0x8(%ebp)
80101c36:	e8 11 ff ff ff       	call   80101b4c <iput>
80101c3b:	83 c4 10             	add    $0x10,%esp
}
80101c3e:	90                   	nop
80101c3f:	c9                   	leave  
80101c40:	c3                   	ret    

80101c41 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c41:	55                   	push   %ebp
80101c42:	89 e5                	mov    %esp,%ebp
80101c44:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c47:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4b:	77 42                	ja     80101c8f <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c53:	83 c2 14             	add    $0x14,%edx
80101c56:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c61:	75 24                	jne    80101c87 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 00                	mov    (%eax),%eax
80101c68:	83 ec 0c             	sub    $0xc,%esp
80101c6b:	50                   	push   %eax
80101c6c:	e8 f4 f7 ff ff       	call   80101465 <balloc>
80101c71:	83 c4 10             	add    $0x10,%esp
80101c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8a:	e9 d0 00 00 00       	jmp    80101d5f <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c97:	0f 87 b5 00 00 00    	ja     80101d52 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cad:	75 20                	jne    80101ccf <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 00                	mov    (%eax),%eax
80101cb4:	83 ec 0c             	sub    $0xc,%esp
80101cb7:	50                   	push   %eax
80101cb8:	e8 a8 f7 ff ff       	call   80101465 <balloc>
80101cbd:	83 c4 10             	add    $0x10,%esp
80101cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 00                	mov    (%eax),%eax
80101cd4:	83 ec 08             	sub    $0x8,%esp
80101cd7:	ff 75 f4             	push   -0xc(%ebp)
80101cda:	50                   	push   %eax
80101cdb:	e8 21 e5 ff ff       	call   80100201 <bread>
80101ce0:	83 c4 10             	add    $0x10,%esp
80101ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce9:	83 c0 5c             	add    $0x5c,%eax
80101cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfc:	01 d0                	add    %edx,%eax
80101cfe:	8b 00                	mov    (%eax),%eax
80101d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d07:	75 36                	jne    80101d3f <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 00                	mov    (%eax),%eax
80101d0e:	83 ec 0c             	sub    $0xc,%esp
80101d11:	50                   	push   %eax
80101d12:	e8 4e f7 ff ff       	call   80101465 <balloc>
80101d17:	83 c4 10             	add    $0x10,%esp
80101d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d2a:	01 c2                	add    %eax,%edx
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	ff 75 f0             	push   -0x10(%ebp)
80101d37:	e8 3a 15 00 00       	call   80103276 <log_write>
80101d3c:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3f:	83 ec 0c             	sub    $0xc,%esp
80101d42:	ff 75 f0             	push   -0x10(%ebp)
80101d45:	e8 39 e5 ff ff       	call   80100283 <brelse>
80101d4a:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d50:	eb 0d                	jmp    80101d5f <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d52:	83 ec 0c             	sub    $0xc,%esp
80101d55:	68 6e a3 10 80       	push   $0x8010a36e
80101d5a:	e8 4a e8 ff ff       	call   801005a9 <panic>
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6e:	eb 45                	jmp    80101db5 <itrunc+0x54>
    if(ip->addrs[i]){
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d76:	83 c2 14             	add    $0x14,%edx
80101d79:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7d:	85 c0                	test   %eax,%eax
80101d7f:	74 30                	je     80101db1 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d87:	83 c2 14             	add    $0x14,%edx
80101d8a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d91:	8b 12                	mov    (%edx),%edx
80101d93:	83 ec 08             	sub    $0x8,%esp
80101d96:	50                   	push   %eax
80101d97:	52                   	push   %edx
80101d98:	e8 0c f8 ff ff       	call   801015a9 <bfree>
80101d9d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da6:	83 c2 14             	add    $0x14,%edx
80101da9:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db0:	00 
  for(i = 0; i < NDIRECT; i++){
80101db1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db5:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db9:	7e b5                	jle    80101d70 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc4:	85 c0                	test   %eax,%eax
80101dc6:	0f 84 aa 00 00 00    	je     80101e76 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 00                	mov    (%eax),%eax
80101dda:	83 ec 08             	sub    $0x8,%esp
80101ddd:	52                   	push   %edx
80101dde:	50                   	push   %eax
80101ddf:	e8 1d e4 ff ff       	call   80100201 <bread>
80101de4:	83 c4 10             	add    $0x10,%esp
80101de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ded:	83 c0 5c             	add    $0x5c,%eax
80101df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dfa:	eb 3c                	jmp    80101e38 <itrunc+0xd7>
      if(a[j])
80101dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e09:	01 d0                	add    %edx,%eax
80101e0b:	8b 00                	mov    (%eax),%eax
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 23                	je     80101e34 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1e:	01 d0                	add    %edx,%eax
80101e20:	8b 00                	mov    (%eax),%eax
80101e22:	8b 55 08             	mov    0x8(%ebp),%edx
80101e25:	8b 12                	mov    (%edx),%edx
80101e27:	83 ec 08             	sub    $0x8,%esp
80101e2a:	50                   	push   %eax
80101e2b:	52                   	push   %edx
80101e2c:	e8 78 f7 ff ff       	call   801015a9 <bfree>
80101e31:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e34:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3b:	83 f8 7f             	cmp    $0x7f,%eax
80101e3e:	76 bc                	jbe    80101dfc <itrunc+0x9b>
    }
    brelse(bp);
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	ff 75 ec             	push   -0x14(%ebp)
80101e46:	e8 38 e4 ff ff       	call   80100283 <brelse>
80101e4b:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e57:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5a:	8b 12                	mov    (%edx),%edx
80101e5c:	83 ec 08             	sub    $0x8,%esp
80101e5f:	50                   	push   %eax
80101e60:	52                   	push   %edx
80101e61:	e8 43 f7 ff ff       	call   801015a9 <bfree>
80101e66:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e69:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e73:	00 00 00 
  }

  ip->size = 0;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e80:	83 ec 0c             	sub    $0xc,%esp
80101e83:	ff 75 08             	push   0x8(%ebp)
80101e86:	e8 83 f9 ff ff       	call   8010180e <iupdate>
80101e8b:	83 c4 10             	add    $0x10,%esp
}
80101e8e:	90                   	nop
80101e8f:	c9                   	leave  
80101e90:	c3                   	ret    

80101e91 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e91:	55                   	push   %ebp
80101e92:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 00                	mov    (%eax),%eax
80101e99:	89 c2                	mov    %eax,%edx
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 50 04             	mov    0x4(%eax),%edx
80101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaa:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	8b 50 58             	mov    0x58(%eax),%edx
80101ece:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed4:	90                   	nop
80101ed5:	5d                   	pop    %ebp
80101ed6:	c3                   	ret    

80101ed7 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed7:	55                   	push   %ebp
80101ed8:	89 e5                	mov    %esp,%ebp
80101eda:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee4:	66 83 f8 03          	cmp    $0x3,%ax
80101ee8:	75 5c                	jne    80101f46 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef1:	66 85 c0             	test   %ax,%ax
80101ef4:	78 20                	js     80101f16 <readi+0x3f>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efd:	66 83 f8 09          	cmp    $0x9,%ax
80101f01:	7f 13                	jg     80101f16 <readi+0x3f>
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f0a:	98                   	cwtl   
80101f0b:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f12:	85 c0                	test   %eax,%eax
80101f14:	75 0a                	jne    80101f20 <readi+0x49>
      return -1;
80101f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1b:	e9 0a 01 00 00       	jmp    8010202a <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f20:	8b 45 08             	mov    0x8(%ebp),%eax
80101f23:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f27:	98                   	cwtl   
80101f28:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2f:	8b 55 14             	mov    0x14(%ebp),%edx
80101f32:	83 ec 04             	sub    $0x4,%esp
80101f35:	52                   	push   %edx
80101f36:	ff 75 0c             	push   0xc(%ebp)
80101f39:	ff 75 08             	push   0x8(%ebp)
80101f3c:	ff d0                	call   *%eax
80101f3e:	83 c4 10             	add    $0x10,%esp
80101f41:	e9 e4 00 00 00       	jmp    8010202a <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f46:	8b 45 08             	mov    0x8(%ebp),%eax
80101f49:	8b 40 58             	mov    0x58(%eax),%eax
80101f4c:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4f:	77 0d                	ja     80101f5e <readi+0x87>
80101f51:	8b 55 10             	mov    0x10(%ebp),%edx
80101f54:	8b 45 14             	mov    0x14(%ebp),%eax
80101f57:	01 d0                	add    %edx,%eax
80101f59:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5c:	76 0a                	jbe    80101f68 <readi+0x91>
    return -1;
80101f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f63:	e9 c2 00 00 00       	jmp    8010202a <readi+0x153>
  if(off + n > ip->size)
80101f68:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	01 c2                	add    %eax,%edx
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	8b 40 58             	mov    0x58(%eax),%eax
80101f76:	39 c2                	cmp    %eax,%edx
80101f78:	76 0c                	jbe    80101f86 <readi+0xaf>
    n = ip->size - off;
80101f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7d:	8b 40 58             	mov    0x58(%eax),%eax
80101f80:	2b 45 10             	sub    0x10(%ebp),%eax
80101f83:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8d:	e9 89 00 00 00       	jmp    8010201b <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f92:	8b 45 10             	mov    0x10(%ebp),%eax
80101f95:	c1 e8 09             	shr    $0x9,%eax
80101f98:	83 ec 08             	sub    $0x8,%esp
80101f9b:	50                   	push   %eax
80101f9c:	ff 75 08             	push   0x8(%ebp)
80101f9f:	e8 9d fc ff ff       	call   80101c41 <bmap>
80101fa4:	83 c4 10             	add    $0x10,%esp
80101fa7:	8b 55 08             	mov    0x8(%ebp),%edx
80101faa:	8b 12                	mov    (%edx),%edx
80101fac:	83 ec 08             	sub    $0x8,%esp
80101faf:	50                   	push   %eax
80101fb0:	52                   	push   %edx
80101fb1:	e8 4b e2 ff ff       	call   80100201 <bread>
80101fb6:	83 c4 10             	add    $0x10,%esp
80101fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc4:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc9:	29 c2                	sub    %eax,%edx
80101fcb:	8b 45 14             	mov    0x14(%ebp),%eax
80101fce:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd1:	39 c2                	cmp    %eax,%edx
80101fd3:	0f 46 c2             	cmovbe %edx,%eax
80101fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fdf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe7:	01 d0                	add    %edx,%eax
80101fe9:	83 ec 04             	sub    $0x4,%esp
80101fec:	ff 75 ec             	push   -0x14(%ebp)
80101fef:	50                   	push   %eax
80101ff0:	ff 75 0c             	push   0xc(%ebp)
80101ff3:	e8 8b 2b 00 00       	call   80104b83 <memmove>
80101ff8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffb:	83 ec 0c             	sub    $0xc,%esp
80101ffe:	ff 75 f0             	push   -0x10(%ebp)
80102001:	e8 7d e2 ff ff       	call   80100283 <brelse>
80102006:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102009:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102012:	01 45 10             	add    %eax,0x10(%ebp)
80102015:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102018:	01 45 0c             	add    %eax,0xc(%ebp)
8010201b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102021:	0f 82 6b ff ff ff    	jb     80101f92 <readi+0xbb>
  }
  return n;
80102027:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202a:	c9                   	leave  
8010202b:	c3                   	ret    

8010202c <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202c:	55                   	push   %ebp
8010202d:	89 e5                	mov    %esp,%ebp
8010202f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102039:	66 83 f8 03          	cmp    $0x3,%ax
8010203d:	75 5c                	jne    8010209b <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102046:	66 85 c0             	test   %ax,%ax
80102049:	78 20                	js     8010206b <writei+0x3f>
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102052:	66 83 f8 09          	cmp    $0x9,%ax
80102056:	7f 13                	jg     8010206b <writei+0x3f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	98                   	cwtl   
80102060:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <writei+0x49>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 3b 01 00 00       	jmp    801021b0 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102084:	8b 55 14             	mov    0x14(%ebp),%edx
80102087:	83 ec 04             	sub    $0x4,%esp
8010208a:	52                   	push   %edx
8010208b:	ff 75 0c             	push   0xc(%ebp)
8010208e:	ff 75 08             	push   0x8(%ebp)
80102091:	ff d0                	call   *%eax
80102093:	83 c4 10             	add    $0x10,%esp
80102096:	e9 15 01 00 00       	jmp    801021b0 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	8b 40 58             	mov    0x58(%eax),%eax
801020a1:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a4:	77 0d                	ja     801020b3 <writei+0x87>
801020a6:	8b 55 10             	mov    0x10(%ebp),%edx
801020a9:	8b 45 14             	mov    0x14(%ebp),%eax
801020ac:	01 d0                	add    %edx,%eax
801020ae:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b1:	76 0a                	jbe    801020bd <writei+0x91>
    return -1;
801020b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b8:	e9 f3 00 00 00       	jmp    801021b0 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bd:	8b 55 10             	mov    0x10(%ebp),%edx
801020c0:	8b 45 14             	mov    0x14(%ebp),%eax
801020c3:	01 d0                	add    %edx,%eax
801020c5:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ca:	76 0a                	jbe    801020d6 <writei+0xaa>
    return -1;
801020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d1:	e9 da 00 00 00       	jmp    801021b0 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dd:	e9 97 00 00 00       	jmp    80102179 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e2:	8b 45 10             	mov    0x10(%ebp),%eax
801020e5:	c1 e8 09             	shr    $0x9,%eax
801020e8:	83 ec 08             	sub    $0x8,%esp
801020eb:	50                   	push   %eax
801020ec:	ff 75 08             	push   0x8(%ebp)
801020ef:	e8 4d fb ff ff       	call   80101c41 <bmap>
801020f4:	83 c4 10             	add    $0x10,%esp
801020f7:	8b 55 08             	mov    0x8(%ebp),%edx
801020fa:	8b 12                	mov    (%edx),%edx
801020fc:	83 ec 08             	sub    $0x8,%esp
801020ff:	50                   	push   %eax
80102100:	52                   	push   %edx
80102101:	e8 fb e0 ff ff       	call   80100201 <bread>
80102106:	83 c4 10             	add    $0x10,%esp
80102109:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210c:	8b 45 10             	mov    0x10(%ebp),%eax
8010210f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102114:	ba 00 02 00 00       	mov    $0x200,%edx
80102119:	29 c2                	sub    %eax,%edx
8010211b:	8b 45 14             	mov    0x14(%ebp),%eax
8010211e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102121:	39 c2                	cmp    %eax,%edx
80102123:	0f 46 c2             	cmovbe %edx,%eax
80102126:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212f:	8b 45 10             	mov    0x10(%ebp),%eax
80102132:	25 ff 01 00 00       	and    $0x1ff,%eax
80102137:	01 d0                	add    %edx,%eax
80102139:	83 ec 04             	sub    $0x4,%esp
8010213c:	ff 75 ec             	push   -0x14(%ebp)
8010213f:	ff 75 0c             	push   0xc(%ebp)
80102142:	50                   	push   %eax
80102143:	e8 3b 2a 00 00       	call   80104b83 <memmove>
80102148:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	ff 75 f0             	push   -0x10(%ebp)
80102151:	e8 20 11 00 00       	call   80103276 <log_write>
80102156:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102159:	83 ec 0c             	sub    $0xc,%esp
8010215c:	ff 75 f0             	push   -0x10(%ebp)
8010215f:	e8 1f e1 ff ff       	call   80100283 <brelse>
80102164:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102170:	01 45 10             	add    %eax,0x10(%ebp)
80102173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102176:	01 45 0c             	add    %eax,0xc(%ebp)
80102179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217f:	0f 82 5d ff ff ff    	jb     801020e2 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102185:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102189:	74 22                	je     801021ad <writei+0x181>
8010218b:	8b 45 08             	mov    0x8(%ebp),%eax
8010218e:	8b 40 58             	mov    0x58(%eax),%eax
80102191:	39 45 10             	cmp    %eax,0x10(%ebp)
80102194:	76 17                	jbe    801021ad <writei+0x181>
    ip->size = off;
80102196:	8b 45 08             	mov    0x8(%ebp),%eax
80102199:	8b 55 10             	mov    0x10(%ebp),%edx
8010219c:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219f:	83 ec 0c             	sub    $0xc,%esp
801021a2:	ff 75 08             	push   0x8(%ebp)
801021a5:	e8 64 f6 ff ff       	call   8010180e <iupdate>
801021aa:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ad:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b0:	c9                   	leave  
801021b1:	c3                   	ret    

801021b2 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b2:	55                   	push   %ebp
801021b3:	89 e5                	mov    %esp,%ebp
801021b5:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b8:	83 ec 04             	sub    $0x4,%esp
801021bb:	6a 0e                	push   $0xe
801021bd:	ff 75 0c             	push   0xc(%ebp)
801021c0:	ff 75 08             	push   0x8(%ebp)
801021c3:	e8 51 2a 00 00       	call   80104c19 <strncmp>
801021c8:	83 c4 10             	add    $0x10,%esp
}
801021cb:	c9                   	leave  
801021cc:	c3                   	ret    

801021cd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d3:	8b 45 08             	mov    0x8(%ebp),%eax
801021d6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021da:	66 83 f8 01          	cmp    $0x1,%ax
801021de:	74 0d                	je     801021ed <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e0:	83 ec 0c             	sub    $0xc,%esp
801021e3:	68 81 a3 10 80       	push   $0x8010a381
801021e8:	e8 bc e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f4:	eb 7b                	jmp    80102271 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f6:	6a 10                	push   $0x10
801021f8:	ff 75 f4             	push   -0xc(%ebp)
801021fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fe:	50                   	push   %eax
801021ff:	ff 75 08             	push   0x8(%ebp)
80102202:	e8 d0 fc ff ff       	call   80101ed7 <readi>
80102207:	83 c4 10             	add    $0x10,%esp
8010220a:	83 f8 10             	cmp    $0x10,%eax
8010220d:	74 0d                	je     8010221c <dirlookup+0x4f>
      panic("dirlookup read");
8010220f:	83 ec 0c             	sub    $0xc,%esp
80102212:	68 93 a3 10 80       	push   $0x8010a393
80102217:	e8 8d e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102220:	66 85 c0             	test   %ax,%ax
80102223:	74 47                	je     8010226c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102225:	83 ec 08             	sub    $0x8,%esp
80102228:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222b:	83 c0 02             	add    $0x2,%eax
8010222e:	50                   	push   %eax
8010222f:	ff 75 0c             	push   0xc(%ebp)
80102232:	e8 7b ff ff ff       	call   801021b2 <namecmp>
80102237:	83 c4 10             	add    $0x10,%esp
8010223a:	85 c0                	test   %eax,%eax
8010223c:	75 2f                	jne    8010226d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102242:	74 08                	je     8010224c <dirlookup+0x7f>
        *poff = off;
80102244:	8b 45 10             	mov    0x10(%ebp),%eax
80102247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102250:	0f b7 c0             	movzwl %ax,%eax
80102253:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
80102259:	8b 00                	mov    (%eax),%eax
8010225b:	83 ec 08             	sub    $0x8,%esp
8010225e:	ff 75 f0             	push   -0x10(%ebp)
80102261:	50                   	push   %eax
80102262:	e8 68 f6 ff ff       	call   801018cf <iget>
80102267:	83 c4 10             	add    $0x10,%esp
8010226a:	eb 19                	jmp    80102285 <dirlookup+0xb8>
      continue;
8010226c:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 40 58             	mov    0x58(%eax),%eax
80102277:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010227a:	0f 82 76 ff ff ff    	jb     801021f6 <dirlookup+0x29>
    }
  }

  return 0;
80102280:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102285:	c9                   	leave  
80102286:	c3                   	ret    

80102287 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102287:	55                   	push   %ebp
80102288:	89 e5                	mov    %esp,%ebp
8010228a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228d:	83 ec 04             	sub    $0x4,%esp
80102290:	6a 00                	push   $0x0
80102292:	ff 75 0c             	push   0xc(%ebp)
80102295:	ff 75 08             	push   0x8(%ebp)
80102298:	e8 30 ff ff ff       	call   801021cd <dirlookup>
8010229d:	83 c4 10             	add    $0x10,%esp
801022a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a7:	74 18                	je     801022c1 <dirlink+0x3a>
    iput(ip);
801022a9:	83 ec 0c             	sub    $0xc,%esp
801022ac:	ff 75 f0             	push   -0x10(%ebp)
801022af:	e8 98 f8 ff ff       	call   80101b4c <iput>
801022b4:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bc:	e9 9c 00 00 00       	jmp    8010235d <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c8:	eb 39                	jmp    80102303 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cd:	6a 10                	push   $0x10
801022cf:	50                   	push   %eax
801022d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d3:	50                   	push   %eax
801022d4:	ff 75 08             	push   0x8(%ebp)
801022d7:	e8 fb fb ff ff       	call   80101ed7 <readi>
801022dc:	83 c4 10             	add    $0x10,%esp
801022df:	83 f8 10             	cmp    $0x10,%eax
801022e2:	74 0d                	je     801022f1 <dirlink+0x6a>
      panic("dirlink read");
801022e4:	83 ec 0c             	sub    $0xc,%esp
801022e7:	68 a2 a3 10 80       	push   $0x8010a3a2
801022ec:	e8 b8 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f5:	66 85 c0             	test   %ax,%ax
801022f8:	74 18                	je     80102312 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fd:	83 c0 10             	add    $0x10,%eax
80102300:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 50 58             	mov    0x58(%eax),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	39 c2                	cmp    %eax,%edx
8010230e:	77 ba                	ja     801022ca <dirlink+0x43>
80102310:	eb 01                	jmp    80102313 <dirlink+0x8c>
      break;
80102312:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102313:	83 ec 04             	sub    $0x4,%esp
80102316:	6a 0e                	push   $0xe
80102318:	ff 75 0c             	push   0xc(%ebp)
8010231b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231e:	83 c0 02             	add    $0x2,%eax
80102321:	50                   	push   %eax
80102322:	e8 48 29 00 00       	call   80104c6f <strncpy>
80102327:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232a:	8b 45 10             	mov    0x10(%ebp),%eax
8010232d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102334:	6a 10                	push   $0x10
80102336:	50                   	push   %eax
80102337:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233a:	50                   	push   %eax
8010233b:	ff 75 08             	push   0x8(%ebp)
8010233e:	e8 e9 fc ff ff       	call   8010202c <writei>
80102343:	83 c4 10             	add    $0x10,%esp
80102346:	83 f8 10             	cmp    $0x10,%eax
80102349:	74 0d                	je     80102358 <dirlink+0xd1>
    panic("dirlink");
8010234b:	83 ec 0c             	sub    $0xc,%esp
8010234e:	68 af a3 10 80       	push   $0x8010a3af
80102353:	e8 51 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235d:	c9                   	leave  
8010235e:	c3                   	ret    

8010235f <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235f:	55                   	push   %ebp
80102360:	89 e5                	mov    %esp,%ebp
80102362:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102365:	eb 04                	jmp    8010236b <skipelem+0xc>
    path++;
80102367:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	0f b6 00             	movzbl (%eax),%eax
80102371:	3c 2f                	cmp    $0x2f,%al
80102373:	74 f2                	je     80102367 <skipelem+0x8>
  if(*path == 0)
80102375:	8b 45 08             	mov    0x8(%ebp),%eax
80102378:	0f b6 00             	movzbl (%eax),%eax
8010237b:	84 c0                	test   %al,%al
8010237d:	75 07                	jne    80102386 <skipelem+0x27>
    return 0;
8010237f:	b8 00 00 00 00       	mov    $0x0,%eax
80102384:	eb 77                	jmp    801023fd <skipelem+0x9e>
  s = path;
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238c:	eb 04                	jmp    80102392 <skipelem+0x33>
    path++;
8010238e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102392:	8b 45 08             	mov    0x8(%ebp),%eax
80102395:	0f b6 00             	movzbl (%eax),%eax
80102398:	3c 2f                	cmp    $0x2f,%al
8010239a:	74 0a                	je     801023a6 <skipelem+0x47>
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	0f b6 00             	movzbl (%eax),%eax
801023a2:	84 c0                	test   %al,%al
801023a4:	75 e8                	jne    8010238e <skipelem+0x2f>
  len = path - s;
801023a6:	8b 45 08             	mov    0x8(%ebp),%eax
801023a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023af:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b3:	7e 15                	jle    801023ca <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b5:	83 ec 04             	sub    $0x4,%esp
801023b8:	6a 0e                	push   $0xe
801023ba:	ff 75 f4             	push   -0xc(%ebp)
801023bd:	ff 75 0c             	push   0xc(%ebp)
801023c0:	e8 be 27 00 00       	call   80104b83 <memmove>
801023c5:	83 c4 10             	add    $0x10,%esp
801023c8:	eb 26                	jmp    801023f0 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cd:	83 ec 04             	sub    $0x4,%esp
801023d0:	50                   	push   %eax
801023d1:	ff 75 f4             	push   -0xc(%ebp)
801023d4:	ff 75 0c             	push   0xc(%ebp)
801023d7:	e8 a7 27 00 00       	call   80104b83 <memmove>
801023dc:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e5:	01 d0                	add    %edx,%eax
801023e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023ea:	eb 04                	jmp    801023f0 <skipelem+0x91>
    path++;
801023ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	0f b6 00             	movzbl (%eax),%eax
801023f6:	3c 2f                	cmp    $0x2f,%al
801023f8:	74 f2                	je     801023ec <skipelem+0x8d>
  return path;
801023fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fd:	c9                   	leave  
801023fe:	c3                   	ret    

801023ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ff:	55                   	push   %ebp
80102400:	89 e5                	mov    %esp,%ebp
80102402:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	0f b6 00             	movzbl (%eax),%eax
8010240b:	3c 2f                	cmp    $0x2f,%al
8010240d:	75 17                	jne    80102426 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240f:	83 ec 08             	sub    $0x8,%esp
80102412:	6a 01                	push   $0x1
80102414:	6a 01                	push   $0x1
80102416:	e8 b4 f4 ff ff       	call   801018cf <iget>
8010241b:	83 c4 10             	add    $0x10,%esp
8010241e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102421:	e9 ba 00 00 00       	jmp    801024e0 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102426:	e8 06 16 00 00       	call   80103a31 <myproc>
8010242b:	8b 40 68             	mov    0x68(%eax),%eax
8010242e:	83 ec 0c             	sub    $0xc,%esp
80102431:	50                   	push   %eax
80102432:	e8 7a f5 ff ff       	call   801019b1 <idup>
80102437:	83 c4 10             	add    $0x10,%esp
8010243a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243d:	e9 9e 00 00 00       	jmp    801024e0 <namex+0xe1>
    ilock(ip);
80102442:	83 ec 0c             	sub    $0xc,%esp
80102445:	ff 75 f4             	push   -0xc(%ebp)
80102448:	e8 9e f5 ff ff       	call   801019eb <ilock>
8010244d:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102457:	66 83 f8 01          	cmp    $0x1,%ax
8010245b:	74 18                	je     80102475 <namex+0x76>
      iunlockput(ip);
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	ff 75 f4             	push   -0xc(%ebp)
80102463:	e8 b4 f7 ff ff       	call   80101c1c <iunlockput>
80102468:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246b:	b8 00 00 00 00       	mov    $0x0,%eax
80102470:	e9 a7 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102479:	74 20                	je     8010249b <namex+0x9c>
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	0f b6 00             	movzbl (%eax),%eax
80102481:	84 c0                	test   %al,%al
80102483:	75 16                	jne    8010249b <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102485:	83 ec 0c             	sub    $0xc,%esp
80102488:	ff 75 f4             	push   -0xc(%ebp)
8010248b:	e8 6e f6 ff ff       	call   80101afe <iunlock>
80102490:	83 c4 10             	add    $0x10,%esp
      return ip;
80102493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102496:	e9 81 00 00 00       	jmp    8010251c <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249b:	83 ec 04             	sub    $0x4,%esp
8010249e:	6a 00                	push   $0x0
801024a0:	ff 75 10             	push   0x10(%ebp)
801024a3:	ff 75 f4             	push   -0xc(%ebp)
801024a6:	e8 22 fd ff ff       	call   801021cd <dirlookup>
801024ab:	83 c4 10             	add    $0x10,%esp
801024ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b5:	75 15                	jne    801024cc <namex+0xcd>
      iunlockput(ip);
801024b7:	83 ec 0c             	sub    $0xc,%esp
801024ba:	ff 75 f4             	push   -0xc(%ebp)
801024bd:	e8 5a f7 ff ff       	call   80101c1c <iunlockput>
801024c2:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c5:	b8 00 00 00 00       	mov    $0x0,%eax
801024ca:	eb 50                	jmp    8010251c <namex+0x11d>
    }
    iunlockput(ip);
801024cc:	83 ec 0c             	sub    $0xc,%esp
801024cf:	ff 75 f4             	push   -0xc(%ebp)
801024d2:	e8 45 f7 ff ff       	call   80101c1c <iunlockput>
801024d7:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e0:	83 ec 08             	sub    $0x8,%esp
801024e3:	ff 75 10             	push   0x10(%ebp)
801024e6:	ff 75 08             	push   0x8(%ebp)
801024e9:	e8 71 fe ff ff       	call   8010235f <skipelem>
801024ee:	83 c4 10             	add    $0x10,%esp
801024f1:	89 45 08             	mov    %eax,0x8(%ebp)
801024f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f8:	0f 85 44 ff ff ff    	jne    80102442 <namex+0x43>
  }
  if(nameiparent){
801024fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102502:	74 15                	je     80102519 <namex+0x11a>
    iput(ip);
80102504:	83 ec 0c             	sub    $0xc,%esp
80102507:	ff 75 f4             	push   -0xc(%ebp)
8010250a:	e8 3d f6 ff ff       	call   80101b4c <iput>
8010250f:	83 c4 10             	add    $0x10,%esp
    return 0;
80102512:	b8 00 00 00 00       	mov    $0x0,%eax
80102517:	eb 03                	jmp    8010251c <namex+0x11d>
  }
  return ip;
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <namei>:

struct inode*
namei(char *path)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102524:	83 ec 04             	sub    $0x4,%esp
80102527:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010252a:	50                   	push   %eax
8010252b:	6a 00                	push   $0x0
8010252d:	ff 75 08             	push   0x8(%ebp)
80102530:	e8 ca fe ff ff       	call   801023ff <namex>
80102535:	83 c4 10             	add    $0x10,%esp
}
80102538:	c9                   	leave  
80102539:	c3                   	ret    

8010253a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	ff 75 0c             	push   0xc(%ebp)
80102546:	6a 01                	push   $0x1
80102548:	ff 75 08             	push   0x8(%ebp)
8010254b:	e8 af fe ff ff       	call   801023ff <namex>
80102550:	83 c4 10             	add    $0x10,%esp
}
80102553:	c9                   	leave  
80102554:	c3                   	ret    

80102555 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102558:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255d:	8b 55 08             	mov    0x8(%ebp),%edx
80102560:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102562:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102567:	8b 40 10             	mov    0x10(%eax),%eax
}
8010256a:	5d                   	pop    %ebp
8010256b:	c3                   	ret    

8010256c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256c:	55                   	push   %ebp
8010256d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102574:	8b 55 08             	mov    0x8(%ebp),%edx
80102577:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102579:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102581:	89 50 10             	mov    %edx,0x10(%eax)
}
80102584:	90                   	nop
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <ioapicinit>:

void
ioapicinit(void)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258d:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102594:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102597:	6a 01                	push   $0x1
80102599:	e8 b7 ff ff ff       	call   80102555 <ioapicread>
8010259e:	83 c4 04             	add    $0x4,%esp
801025a1:	c1 e8 10             	shr    $0x10,%eax
801025a4:	25 ff 00 00 00       	and    $0xff,%eax
801025a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ac:	6a 00                	push   $0x0
801025ae:	e8 a2 ff ff ff       	call   80102555 <ioapicread>
801025b3:	83 c4 04             	add    $0x4,%esp
801025b6:	c1 e8 18             	shr    $0x18,%eax
801025b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bc:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025c3:	0f b6 c0             	movzbl %al,%eax
801025c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c9:	74 10                	je     801025db <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025cb:	83 ec 0c             	sub    $0xc,%esp
801025ce:	68 b8 a3 10 80       	push   $0x8010a3b8
801025d3:	e8 1c de ff ff       	call   801003f4 <cprintf>
801025d8:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e2:	eb 3f                	jmp    80102623 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e7:	83 c0 20             	add    $0x20,%eax
801025ea:	0d 00 00 01 00       	or     $0x10000,%eax
801025ef:	89 c2                	mov    %eax,%edx
801025f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f4:	83 c0 08             	add    $0x8,%eax
801025f7:	01 c0                	add    %eax,%eax
801025f9:	83 ec 08             	sub    $0x8,%esp
801025fc:	52                   	push   %edx
801025fd:	50                   	push   %eax
801025fe:	e8 69 ff ff ff       	call   8010256c <ioapicwrite>
80102603:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102609:	83 c0 08             	add    $0x8,%eax
8010260c:	01 c0                	add    %eax,%eax
8010260e:	83 c0 01             	add    $0x1,%eax
80102611:	83 ec 08             	sub    $0x8,%esp
80102614:	6a 00                	push   $0x0
80102616:	50                   	push   %eax
80102617:	e8 50 ff ff ff       	call   8010256c <ioapicwrite>
8010261c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102626:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102629:	7e b9                	jle    801025e4 <ioapicinit+0x5d>
  }
}
8010262b:	90                   	nop
8010262c:	90                   	nop
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102632:	8b 45 08             	mov    0x8(%ebp),%eax
80102635:	83 c0 20             	add    $0x20,%eax
80102638:	89 c2                	mov    %eax,%edx
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	83 c0 08             	add    $0x8,%eax
80102640:	01 c0                	add    %eax,%eax
80102642:	52                   	push   %edx
80102643:	50                   	push   %eax
80102644:	e8 23 ff ff ff       	call   8010256c <ioapicwrite>
80102649:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264f:	c1 e0 18             	shl    $0x18,%eax
80102652:	89 c2                	mov    %eax,%edx
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	83 c0 08             	add    $0x8,%eax
8010265a:	01 c0                	add    %eax,%eax
8010265c:	83 c0 01             	add    $0x1,%eax
8010265f:	52                   	push   %edx
80102660:	50                   	push   %eax
80102661:	e8 06 ff ff ff       	call   8010256c <ioapicwrite>
80102666:	83 c4 08             	add    $0x8,%esp
}
80102669:	90                   	nop
8010266a:	c9                   	leave  
8010266b:	c3                   	ret    

8010266c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266c:	55                   	push   %ebp
8010266d:	89 e5                	mov    %esp,%ebp
8010266f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102672:	83 ec 08             	sub    $0x8,%esp
80102675:	68 ea a3 10 80       	push   $0x8010a3ea
8010267a:	68 c0 40 19 80       	push   $0x801940c0
8010267f:	e8 a8 21 00 00       	call   8010482c <initlock>
80102684:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102687:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268e:	00 00 00 
  freerange(vstart, vend);
80102691:	83 ec 08             	sub    $0x8,%esp
80102694:	ff 75 0c             	push   0xc(%ebp)
80102697:	ff 75 08             	push   0x8(%ebp)
8010269a:	e8 2a 00 00 00       	call   801026c9 <freerange>
8010269f:	83 c4 10             	add    $0x10,%esp
}
801026a2:	90                   	nop
801026a3:	c9                   	leave  
801026a4:	c3                   	ret    

801026a5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a5:	55                   	push   %ebp
801026a6:	89 e5                	mov    %esp,%ebp
801026a8:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026ab:	83 ec 08             	sub    $0x8,%esp
801026ae:	ff 75 0c             	push   0xc(%ebp)
801026b1:	ff 75 08             	push   0x8(%ebp)
801026b4:	e8 10 00 00 00       	call   801026c9 <freerange>
801026b9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bc:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c3:	00 00 00 
}
801026c6:	90                   	nop
801026c7:	c9                   	leave  
801026c8:	c3                   	ret    

801026c9 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c9:	55                   	push   %ebp
801026ca:	89 e5                	mov    %esp,%ebp
801026cc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026cf:	8b 45 08             	mov    0x8(%ebp),%eax
801026d2:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026df:	eb 15                	jmp    801026f6 <freerange+0x2d>
    kfree(p);
801026e1:	83 ec 0c             	sub    $0xc,%esp
801026e4:	ff 75 f4             	push   -0xc(%ebp)
801026e7:	e8 1b 00 00 00       	call   80102707 <kfree>
801026ec:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f9:	05 00 10 00 00       	add    $0x1000,%eax
801026fe:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102701:	73 de                	jae    801026e1 <freerange+0x18>
}
80102703:	90                   	nop
80102704:	90                   	nop
80102705:	c9                   	leave  
80102706:	c3                   	ret    

80102707 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102707:	55                   	push   %ebp
80102708:	89 e5                	mov    %esp,%ebp
8010270a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	25 ff 0f 00 00       	and    $0xfff,%eax
80102715:	85 c0                	test   %eax,%eax
80102717:	75 18                	jne    80102731 <kfree+0x2a>
80102719:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102720:	72 0f                	jb     80102731 <kfree+0x2a>
80102722:	8b 45 08             	mov    0x8(%ebp),%eax
80102725:	05 00 00 00 80       	add    $0x80000000,%eax
8010272a:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272f:	76 0d                	jbe    8010273e <kfree+0x37>
    panic("kfree");
80102731:	83 ec 0c             	sub    $0xc,%esp
80102734:	68 ef a3 10 80       	push   $0x8010a3ef
80102739:	e8 6b de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273e:	83 ec 04             	sub    $0x4,%esp
80102741:	68 00 10 00 00       	push   $0x1000
80102746:	6a 01                	push   $0x1
80102748:	ff 75 08             	push   0x8(%ebp)
8010274b:	e8 74 23 00 00       	call   80104ac4 <memset>
80102750:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102753:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102758:	85 c0                	test   %eax,%eax
8010275a:	74 10                	je     8010276c <kfree+0x65>
    acquire(&kmem.lock);
8010275c:	83 ec 0c             	sub    $0xc,%esp
8010275f:	68 c0 40 19 80       	push   $0x801940c0
80102764:	e8 e5 20 00 00       	call   8010484e <acquire>
80102769:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276c:	8b 45 08             	mov    0x8(%ebp),%eax
8010276f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102772:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102785:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010278a:	85 c0                	test   %eax,%eax
8010278c:	74 10                	je     8010279e <kfree+0x97>
    release(&kmem.lock);
8010278e:	83 ec 0c             	sub    $0xc,%esp
80102791:	68 c0 40 19 80       	push   $0x801940c0
80102796:	e8 21 21 00 00       	call   801048bc <release>
8010279b:	83 c4 10             	add    $0x10,%esp
}
8010279e:	90                   	nop
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ac:	85 c0                	test   %eax,%eax
801027ae:	74 10                	je     801027c0 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	68 c0 40 19 80       	push   $0x801940c0
801027b8:	e8 91 20 00 00       	call   8010484e <acquire>
801027bd:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c0:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cc:	74 0a                	je     801027d8 <kalloc+0x37>
    kmem.freelist = r->next;
801027ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d1:	8b 00                	mov    (%eax),%eax
801027d3:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d8:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dd:	85 c0                	test   %eax,%eax
801027df:	74 10                	je     801027f1 <kalloc+0x50>
    release(&kmem.lock);
801027e1:	83 ec 0c             	sub    $0xc,%esp
801027e4:	68 c0 40 19 80       	push   $0x801940c0
801027e9:	e8 ce 20 00 00       	call   801048bc <release>
801027ee:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f4:	c9                   	leave  
801027f5:	c3                   	ret    

801027f6 <inb>:
{
801027f6:	55                   	push   %ebp
801027f7:	89 e5                	mov    %esp,%ebp
801027f9:	83 ec 14             	sub    $0x14,%esp
801027fc:	8b 45 08             	mov    0x8(%ebp),%eax
801027ff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102803:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102807:	89 c2                	mov    %eax,%edx
80102809:	ec                   	in     (%dx),%al
8010280a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102811:	c9                   	leave  
80102812:	c3                   	ret    

80102813 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102813:	55                   	push   %ebp
80102814:	89 e5                	mov    %esp,%ebp
80102816:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102819:	6a 64                	push   $0x64
8010281b:	e8 d6 ff ff ff       	call   801027f6 <inb>
80102820:	83 c4 04             	add    $0x4,%esp
80102823:	0f b6 c0             	movzbl %al,%eax
80102826:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282c:	83 e0 01             	and    $0x1,%eax
8010282f:	85 c0                	test   %eax,%eax
80102831:	75 0a                	jne    8010283d <kbdgetc+0x2a>
    return -1;
80102833:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102838:	e9 23 01 00 00       	jmp    80102960 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283d:	6a 60                	push   $0x60
8010283f:	e8 b2 ff ff ff       	call   801027f6 <inb>
80102844:	83 c4 04             	add    $0x4,%esp
80102847:	0f b6 c0             	movzbl %al,%eax
8010284a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102854:	75 17                	jne    8010286d <kbdgetc+0x5a>
    shift |= E0ESC;
80102856:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285b:	83 c8 40             	or     $0x40,%eax
8010285e:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102863:	b8 00 00 00 00       	mov    $0x0,%eax
80102868:	e9 f3 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102870:	25 80 00 00 00       	and    $0x80,%eax
80102875:	85 c0                	test   %eax,%eax
80102877:	74 45                	je     801028be <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102879:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287e:	83 e0 40             	and    $0x40,%eax
80102881:	85 c0                	test   %eax,%eax
80102883:	75 08                	jne    8010288d <kbdgetc+0x7a>
80102885:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102888:	83 e0 7f             	and    $0x7f,%eax
8010288b:	eb 03                	jmp    80102890 <kbdgetc+0x7d>
8010288d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102890:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102893:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102896:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289b:	0f b6 00             	movzbl (%eax),%eax
8010289e:	83 c8 40             	or     $0x40,%eax
801028a1:	0f b6 c0             	movzbl %al,%eax
801028a4:	f7 d0                	not    %eax
801028a6:	89 c2                	mov    %eax,%edx
801028a8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ad:	21 d0                	and    %edx,%eax
801028af:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b4:	b8 00 00 00 00       	mov    $0x0,%eax
801028b9:	e9 a2 00 00 00       	jmp    80102960 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028be:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c3:	83 e0 40             	and    $0x40,%eax
801028c6:	85 c0                	test   %eax,%eax
801028c8:	74 14                	je     801028de <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028ca:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d1:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d6:	83 e0 bf             	and    $0xffffffbf,%eax
801028d9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e1:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e6:	0f b6 00             	movzbl (%eax),%eax
801028e9:	0f b6 d0             	movzbl %al,%edx
801028ec:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f1:	09 d0                	or     %edx,%eax
801028f3:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fb:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102900:	0f b6 00             	movzbl (%eax),%eax
80102903:	0f b6 d0             	movzbl %al,%edx
80102906:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290b:	31 d0                	xor    %edx,%eax
8010290d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102912:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102917:	83 e0 03             	and    $0x3,%eax
8010291a:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102921:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102924:	01 d0                	add    %edx,%eax
80102926:	0f b6 00             	movzbl (%eax),%eax
80102929:	0f b6 c0             	movzbl %al,%eax
8010292c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292f:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102934:	83 e0 08             	and    $0x8,%eax
80102937:	85 c0                	test   %eax,%eax
80102939:	74 22                	je     8010295d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293f:	76 0c                	jbe    8010294d <kbdgetc+0x13a>
80102941:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102945:	77 06                	ja     8010294d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102947:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294b:	eb 10                	jmp    8010295d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102951:	76 0a                	jbe    8010295d <kbdgetc+0x14a>
80102953:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102957:	77 04                	ja     8010295d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102959:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102960:	c9                   	leave  
80102961:	c3                   	ret    

80102962 <kbdintr>:

void
kbdintr(void)
{
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 13 28 10 80       	push   $0x80102813
80102970:	e8 61 de ff ff       	call   801007d6 <consoleintr>
80102975:	83 c4 10             	add    $0x10,%esp
}
80102978:	90                   	nop
80102979:	c9                   	leave  
8010297a:	c3                   	ret    

8010297b <inb>:
{
8010297b:	55                   	push   %ebp
8010297c:	89 e5                	mov    %esp,%ebp
8010297e:	83 ec 14             	sub    $0x14,%esp
80102981:	8b 45 08             	mov    0x8(%ebp),%eax
80102984:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102988:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298c:	89 c2                	mov    %eax,%edx
8010298e:	ec                   	in     (%dx),%al
8010298f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102992:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102996:	c9                   	leave  
80102997:	c3                   	ret    

80102998 <outb>:
{
80102998:	55                   	push   %ebp
80102999:	89 e5                	mov    %esp,%ebp
8010299b:	83 ec 08             	sub    $0x8,%esp
8010299e:	8b 45 08             	mov    0x8(%ebp),%eax
801029a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a8:	89 d0                	mov    %edx,%eax
801029aa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ad:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b5:	ee                   	out    %al,(%dx)
}
801029b6:	90                   	nop
801029b7:	c9                   	leave  
801029b8:	c3                   	ret    

801029b9 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b9:	55                   	push   %ebp
801029ba:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bc:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	c1 e0 02             	shl    $0x2,%eax
801029c8:	01 c2                	add    %eax,%edx
801029ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029cf:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d4:	83 c0 20             	add    $0x20,%eax
801029d7:	8b 00                	mov    (%eax),%eax
}
801029d9:	90                   	nop
801029da:	5d                   	pop    %ebp
801029db:	c3                   	ret    

801029dc <lapicinit>:

void
lapicinit(void)
{
801029dc:	55                   	push   %ebp
801029dd:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029df:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e4:	85 c0                	test   %eax,%eax
801029e6:	0f 84 0c 01 00 00    	je     80102af8 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029ec:	68 3f 01 00 00       	push   $0x13f
801029f1:	6a 3c                	push   $0x3c
801029f3:	e8 c1 ff ff ff       	call   801029b9 <lapicw>
801029f8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fb:	6a 0b                	push   $0xb
801029fd:	68 f8 00 00 00       	push   $0xf8
80102a02:	e8 b2 ff ff ff       	call   801029b9 <lapicw>
80102a07:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0a:	68 20 00 02 00       	push   $0x20020
80102a0f:	68 c8 00 00 00       	push   $0xc8
80102a14:	e8 a0 ff ff ff       	call   801029b9 <lapicw>
80102a19:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1c:	68 80 96 98 00       	push   $0x989680
80102a21:	68 e0 00 00 00       	push   $0xe0
80102a26:	e8 8e ff ff ff       	call   801029b9 <lapicw>
80102a2b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2e:	68 00 00 01 00       	push   $0x10000
80102a33:	68 d4 00 00 00       	push   $0xd4
80102a38:	e8 7c ff ff ff       	call   801029b9 <lapicw>
80102a3d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a40:	68 00 00 01 00       	push   $0x10000
80102a45:	68 d8 00 00 00       	push   $0xd8
80102a4a:	e8 6a ff ff ff       	call   801029b9 <lapicw>
80102a4f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a52:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a57:	83 c0 30             	add    $0x30,%eax
80102a5a:	8b 00                	mov    (%eax),%eax
80102a5c:	c1 e8 10             	shr    $0x10,%eax
80102a5f:	25 fc 00 00 00       	and    $0xfc,%eax
80102a64:	85 c0                	test   %eax,%eax
80102a66:	74 12                	je     80102a7a <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a68:	68 00 00 01 00       	push   $0x10000
80102a6d:	68 d0 00 00 00       	push   $0xd0
80102a72:	e8 42 ff ff ff       	call   801029b9 <lapicw>
80102a77:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7a:	6a 33                	push   $0x33
80102a7c:	68 dc 00 00 00       	push   $0xdc
80102a81:	e8 33 ff ff ff       	call   801029b9 <lapicw>
80102a86:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a89:	6a 00                	push   $0x0
80102a8b:	68 a0 00 00 00       	push   $0xa0
80102a90:	e8 24 ff ff ff       	call   801029b9 <lapicw>
80102a95:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a98:	6a 00                	push   $0x0
80102a9a:	68 a0 00 00 00       	push   $0xa0
80102a9f:	e8 15 ff ff ff       	call   801029b9 <lapicw>
80102aa4:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa7:	6a 00                	push   $0x0
80102aa9:	6a 2c                	push   $0x2c
80102aab:	e8 09 ff ff ff       	call   801029b9 <lapicw>
80102ab0:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab3:	6a 00                	push   $0x0
80102ab5:	68 c4 00 00 00       	push   $0xc4
80102aba:	e8 fa fe ff ff       	call   801029b9 <lapicw>
80102abf:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac2:	68 00 85 08 00       	push   $0x88500
80102ac7:	68 c0 00 00 00       	push   $0xc0
80102acc:	e8 e8 fe ff ff       	call   801029b9 <lapicw>
80102ad1:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad4:	90                   	nop
80102ad5:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ada:	05 00 03 00 00       	add    $0x300,%eax
80102adf:	8b 00                	mov    (%eax),%eax
80102ae1:	25 00 10 00 00       	and    $0x1000,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	75 eb                	jne    80102ad5 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aea:	6a 00                	push   $0x0
80102aec:	6a 20                	push   $0x20
80102aee:	e8 c6 fe ff ff       	call   801029b9 <lapicw>
80102af3:	83 c4 08             	add    $0x8,%esp
80102af6:	eb 01                	jmp    80102af9 <lapicinit+0x11d>
    return;
80102af8:	90                   	nop
}
80102af9:	c9                   	leave  
80102afa:	c3                   	ret    

80102afb <lapicid>:

int
lapicid(void)
{
80102afb:	55                   	push   %ebp
80102afc:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afe:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	75 07                	jne    80102b0e <lapicid+0x13>
    return 0;
80102b07:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0c:	eb 0d                	jmp    80102b1b <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b13:	83 c0 20             	add    $0x20,%eax
80102b16:	8b 00                	mov    (%eax),%eax
80102b18:	c1 e8 18             	shr    $0x18,%eax
}
80102b1b:	5d                   	pop    %ebp
80102b1c:	c3                   	ret    

80102b1d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b20:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b25:	85 c0                	test   %eax,%eax
80102b27:	74 0c                	je     80102b35 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b29:	6a 00                	push   $0x0
80102b2b:	6a 2c                	push   $0x2c
80102b2d:	e8 87 fe ff ff       	call   801029b9 <lapicw>
80102b32:	83 c4 08             	add    $0x8,%esp
}
80102b35:	90                   	nop
80102b36:	c9                   	leave  
80102b37:	c3                   	ret    

80102b38 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
}
80102b3b:	90                   	nop
80102b3c:	5d                   	pop    %ebp
80102b3d:	c3                   	ret    

80102b3e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3e:	55                   	push   %ebp
80102b3f:	89 e5                	mov    %esp,%ebp
80102b41:	83 ec 14             	sub    $0x14,%esp
80102b44:	8b 45 08             	mov    0x8(%ebp),%eax
80102b47:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4a:	6a 0f                	push   $0xf
80102b4c:	6a 70                	push   $0x70
80102b4e:	e8 45 fe ff ff       	call   80102998 <outb>
80102b53:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b56:	6a 0a                	push   $0xa
80102b58:	6a 71                	push   $0x71
80102b5a:	e8 39 fe ff ff       	call   80102998 <outb>
80102b5f:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b62:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b74:	c1 e8 04             	shr    $0x4,%eax
80102b77:	89 c2                	mov    %eax,%edx
80102b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7c:	83 c0 02             	add    $0x2,%eax
80102b7f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b82:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b86:	c1 e0 18             	shl    $0x18,%eax
80102b89:	50                   	push   %eax
80102b8a:	68 c4 00 00 00       	push   $0xc4
80102b8f:	e8 25 fe ff ff       	call   801029b9 <lapicw>
80102b94:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b97:	68 00 c5 00 00       	push   $0xc500
80102b9c:	68 c0 00 00 00       	push   $0xc0
80102ba1:	e8 13 fe ff ff       	call   801029b9 <lapicw>
80102ba6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba9:	68 c8 00 00 00       	push   $0xc8
80102bae:	e8 85 ff ff ff       	call   80102b38 <microdelay>
80102bb3:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb6:	68 00 85 00 00       	push   $0x8500
80102bbb:	68 c0 00 00 00       	push   $0xc0
80102bc0:	e8 f4 fd ff ff       	call   801029b9 <lapicw>
80102bc5:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc8:	6a 64                	push   $0x64
80102bca:	e8 69 ff ff ff       	call   80102b38 <microdelay>
80102bcf:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd9:	eb 3d                	jmp    80102c18 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bdf:	c1 e0 18             	shl    $0x18,%eax
80102be2:	50                   	push   %eax
80102be3:	68 c4 00 00 00       	push   $0xc4
80102be8:	e8 cc fd ff ff       	call   801029b9 <lapicw>
80102bed:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf3:	c1 e8 0c             	shr    $0xc,%eax
80102bf6:	80 cc 06             	or     $0x6,%ah
80102bf9:	50                   	push   %eax
80102bfa:	68 c0 00 00 00       	push   $0xc0
80102bff:	e8 b5 fd ff ff       	call   801029b9 <lapicw>
80102c04:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c07:	68 c8 00 00 00       	push   $0xc8
80102c0c:	e8 27 ff ff ff       	call   80102b38 <microdelay>
80102c11:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c14:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c18:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1c:	7e bd                	jle    80102bdb <lapicstartap+0x9d>
  }
}
80102c1e:	90                   	nop
80102c1f:	90                   	nop
80102c20:	c9                   	leave  
80102c21:	c3                   	ret    

80102c22 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c22:	55                   	push   %ebp
80102c23:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c25:	8b 45 08             	mov    0x8(%ebp),%eax
80102c28:	0f b6 c0             	movzbl %al,%eax
80102c2b:	50                   	push   %eax
80102c2c:	6a 70                	push   $0x70
80102c2e:	e8 65 fd ff ff       	call   80102998 <outb>
80102c33:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c36:	68 c8 00 00 00       	push   $0xc8
80102c3b:	e8 f8 fe ff ff       	call   80102b38 <microdelay>
80102c40:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c43:	6a 71                	push   $0x71
80102c45:	e8 31 fd ff ff       	call   8010297b <inb>
80102c4a:	83 c4 04             	add    $0x4,%esp
80102c4d:	0f b6 c0             	movzbl %al,%eax
}
80102c50:	c9                   	leave  
80102c51:	c3                   	ret    

80102c52 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c55:	6a 00                	push   $0x0
80102c57:	e8 c6 ff ff ff       	call   80102c22 <cmos_read>
80102c5c:	83 c4 04             	add    $0x4,%esp
80102c5f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c62:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c64:	6a 02                	push   $0x2
80102c66:	e8 b7 ff ff ff       	call   80102c22 <cmos_read>
80102c6b:	83 c4 04             	add    $0x4,%esp
80102c6e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c71:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c74:	6a 04                	push   $0x4
80102c76:	e8 a7 ff ff ff       	call   80102c22 <cmos_read>
80102c7b:	83 c4 04             	add    $0x4,%esp
80102c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c81:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c84:	6a 07                	push   $0x7
80102c86:	e8 97 ff ff ff       	call   80102c22 <cmos_read>
80102c8b:	83 c4 04             	add    $0x4,%esp
80102c8e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c91:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c94:	6a 08                	push   $0x8
80102c96:	e8 87 ff ff ff       	call   80102c22 <cmos_read>
80102c9b:	83 c4 04             	add    $0x4,%esp
80102c9e:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca1:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca4:	6a 09                	push   $0x9
80102ca6:	e8 77 ff ff ff       	call   80102c22 <cmos_read>
80102cab:	83 c4 04             	add    $0x4,%esp
80102cae:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb1:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb4:	90                   	nop
80102cb5:	c9                   	leave  
80102cb6:	c3                   	ret    

80102cb7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb7:	55                   	push   %ebp
80102cb8:	89 e5                	mov    %esp,%ebp
80102cba:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbd:	6a 0b                	push   $0xb
80102cbf:	e8 5e ff ff ff       	call   80102c22 <cmos_read>
80102cc4:	83 c4 04             	add    $0x4,%esp
80102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccd:	83 e0 04             	and    $0x4,%eax
80102cd0:	85 c0                	test   %eax,%eax
80102cd2:	0f 94 c0             	sete   %al
80102cd5:	0f b6 c0             	movzbl %al,%eax
80102cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cde:	50                   	push   %eax
80102cdf:	e8 6e ff ff ff       	call   80102c52 <fill_rtcdate>
80102ce4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce7:	6a 0a                	push   $0xa
80102ce9:	e8 34 ff ff ff       	call   80102c22 <cmos_read>
80102cee:	83 c4 04             	add    $0x4,%esp
80102cf1:	25 80 00 00 00       	and    $0x80,%eax
80102cf6:	85 c0                	test   %eax,%eax
80102cf8:	75 27                	jne    80102d21 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfa:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfd:	50                   	push   %eax
80102cfe:	e8 4f ff ff ff       	call   80102c52 <fill_rtcdate>
80102d03:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d06:	83 ec 04             	sub    $0x4,%esp
80102d09:	6a 18                	push   $0x18
80102d0b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0e:	50                   	push   %eax
80102d0f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d12:	50                   	push   %eax
80102d13:	e8 13 1e 00 00       	call   80104b2b <memcmp>
80102d18:	83 c4 10             	add    $0x10,%esp
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 05                	je     80102d24 <cmostime+0x6d>
80102d1f:	eb ba                	jmp    80102cdb <cmostime+0x24>
        continue;
80102d21:	90                   	nop
    fill_rtcdate(&t1);
80102d22:	eb b7                	jmp    80102cdb <cmostime+0x24>
      break;
80102d24:	90                   	nop
  }

  // convert
  if(bcd) {
80102d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d29:	0f 84 b4 00 00 00    	je     80102de3 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d32:	c1 e8 04             	shr    $0x4,%eax
80102d35:	89 c2                	mov    %eax,%edx
80102d37:	89 d0                	mov    %edx,%eax
80102d39:	c1 e0 02             	shl    $0x2,%eax
80102d3c:	01 d0                	add    %edx,%eax
80102d3e:	01 c0                	add    %eax,%eax
80102d40:	89 c2                	mov    %eax,%edx
80102d42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d45:	83 e0 0f             	and    $0xf,%eax
80102d48:	01 d0                	add    %edx,%eax
80102d4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d50:	c1 e8 04             	shr    $0x4,%eax
80102d53:	89 c2                	mov    %eax,%edx
80102d55:	89 d0                	mov    %edx,%eax
80102d57:	c1 e0 02             	shl    $0x2,%eax
80102d5a:	01 d0                	add    %edx,%eax
80102d5c:	01 c0                	add    %eax,%eax
80102d5e:	89 c2                	mov    %eax,%edx
80102d60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d63:	83 e0 0f             	and    $0xf,%eax
80102d66:	01 d0                	add    %edx,%eax
80102d68:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6e:	c1 e8 04             	shr    $0x4,%eax
80102d71:	89 c2                	mov    %eax,%edx
80102d73:	89 d0                	mov    %edx,%eax
80102d75:	c1 e0 02             	shl    $0x2,%eax
80102d78:	01 d0                	add    %edx,%eax
80102d7a:	01 c0                	add    %eax,%eax
80102d7c:	89 c2                	mov    %eax,%edx
80102d7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d81:	83 e0 0f             	and    $0xf,%eax
80102d84:	01 d0                	add    %edx,%eax
80102d86:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8c:	c1 e8 04             	shr    $0x4,%eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	89 d0                	mov    %edx,%eax
80102d93:	c1 e0 02             	shl    $0x2,%eax
80102d96:	01 d0                	add    %edx,%eax
80102d98:	01 c0                	add    %eax,%eax
80102d9a:	89 c2                	mov    %eax,%edx
80102d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9f:	83 e0 0f             	and    $0xf,%eax
80102da2:	01 d0                	add    %edx,%eax
80102da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102daa:	c1 e8 04             	shr    $0x4,%eax
80102dad:	89 c2                	mov    %eax,%edx
80102daf:	89 d0                	mov    %edx,%eax
80102db1:	c1 e0 02             	shl    $0x2,%eax
80102db4:	01 d0                	add    %edx,%eax
80102db6:	01 c0                	add    %eax,%eax
80102db8:	89 c2                	mov    %eax,%edx
80102dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbd:	83 e0 0f             	and    $0xf,%eax
80102dc0:	01 d0                	add    %edx,%eax
80102dc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc8:	c1 e8 04             	shr    $0x4,%eax
80102dcb:	89 c2                	mov    %eax,%edx
80102dcd:	89 d0                	mov    %edx,%eax
80102dcf:	c1 e0 02             	shl    $0x2,%eax
80102dd2:	01 d0                	add    %edx,%eax
80102dd4:	01 c0                	add    %eax,%eax
80102dd6:	89 c2                	mov    %eax,%edx
80102dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddb:	83 e0 0f             	and    $0xf,%eax
80102dde:	01 d0                	add    %edx,%eax
80102de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de3:	8b 45 08             	mov    0x8(%ebp),%eax
80102de6:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de9:	89 10                	mov    %edx,(%eax)
80102deb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dee:	89 50 04             	mov    %edx,0x4(%eax)
80102df1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df4:	89 50 08             	mov    %edx,0x8(%eax)
80102df7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfa:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e00:	89 50 10             	mov    %edx,0x10(%eax)
80102e03:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e06:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e09:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0c:	8b 40 14             	mov    0x14(%eax),%eax
80102e0f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e15:	8b 45 08             	mov    0x8(%ebp),%eax
80102e18:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1b:	90                   	nop
80102e1c:	c9                   	leave  
80102e1d:	c3                   	ret    

80102e1e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1e:	55                   	push   %ebp
80102e1f:	89 e5                	mov    %esp,%ebp
80102e21:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e24:	83 ec 08             	sub    $0x8,%esp
80102e27:	68 f5 a3 10 80       	push   $0x8010a3f5
80102e2c:	68 20 41 19 80       	push   $0x80194120
80102e31:	e8 f6 19 00 00       	call   8010482c <initlock>
80102e36:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e39:	83 ec 08             	sub    $0x8,%esp
80102e3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3f:	50                   	push   %eax
80102e40:	ff 75 08             	push   0x8(%ebp)
80102e43:	e8 87 e5 ff ff       	call   801013cf <readsb>
80102e48:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4e:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e53:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e56:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5e:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e63:	e8 b3 01 00 00       	call   8010301b <recover_from_log>
}
80102e68:	90                   	nop
80102e69:	c9                   	leave  
80102e6a:	c3                   	ret    

80102e6b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6b:	55                   	push   %ebp
80102e6c:	89 e5                	mov    %esp,%ebp
80102e6e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e78:	e9 95 00 00 00       	jmp    80102f12 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7d:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	83 c0 01             	add    $0x1,%eax
80102e8b:	89 c2                	mov    %eax,%edx
80102e8d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e92:	83 ec 08             	sub    $0x8,%esp
80102e95:	52                   	push   %edx
80102e96:	50                   	push   %eax
80102e97:	e8 65 d3 ff ff       	call   80100201 <bread>
80102e9c:	83 c4 10             	add    $0x10,%esp
80102e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea5:	83 c0 10             	add    $0x10,%eax
80102ea8:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb6:	83 ec 08             	sub    $0x8,%esp
80102eb9:	52                   	push   %edx
80102eba:	50                   	push   %eax
80102ebb:	e8 41 d3 ff ff       	call   80100201 <bread>
80102ec0:	83 c4 10             	add    $0x10,%esp
80102ec3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec9:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ecf:	83 c0 5c             	add    $0x5c,%eax
80102ed2:	83 ec 04             	sub    $0x4,%esp
80102ed5:	68 00 02 00 00       	push   $0x200
80102eda:	52                   	push   %edx
80102edb:	50                   	push   %eax
80102edc:	e8 a2 1c 00 00       	call   80104b83 <memmove>
80102ee1:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee4:	83 ec 0c             	sub    $0xc,%esp
80102ee7:	ff 75 ec             	push   -0x14(%ebp)
80102eea:	e8 4b d3 ff ff       	call   8010023a <bwrite>
80102eef:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	ff 75 f0             	push   -0x10(%ebp)
80102ef8:	e8 86 d3 ff ff       	call   80100283 <brelse>
80102efd:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f00:	83 ec 0c             	sub    $0xc,%esp
80102f03:	ff 75 ec             	push   -0x14(%ebp)
80102f06:	e8 78 d3 ff ff       	call   80100283 <brelse>
80102f0b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f12:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1a:	0f 8c 5d ff ff ff    	jl     80102e7d <install_trans+0x12>
  }
}
80102f20:	90                   	nop
80102f21:	90                   	nop
80102f22:	c9                   	leave  
80102f23:	c3                   	ret    

80102f24 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f24:	55                   	push   %ebp
80102f25:	89 e5                	mov    %esp,%ebp
80102f27:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2a:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2f:	89 c2                	mov    %eax,%edx
80102f31:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f36:	83 ec 08             	sub    $0x8,%esp
80102f39:	52                   	push   %edx
80102f3a:	50                   	push   %eax
80102f3b:	e8 c1 d2 ff ff       	call   80100201 <bread>
80102f40:	83 c4 10             	add    $0x10,%esp
80102f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f49:	83 c0 5c             	add    $0x5c,%eax
80102f4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f52:	8b 00                	mov    (%eax),%eax
80102f54:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f60:	eb 1b                	jmp    80102f7d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f68:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6f:	83 c2 10             	add    $0x10,%edx
80102f72:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7d:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f85:	7c db                	jl     80102f62 <read_head+0x3e>
  }
  brelse(buf);
80102f87:	83 ec 0c             	sub    $0xc,%esp
80102f8a:	ff 75 f0             	push   -0x10(%ebp)
80102f8d:	e8 f1 d2 ff ff       	call   80100283 <brelse>
80102f92:	83 c4 10             	add    $0x10,%esp
}
80102f95:	90                   	nop
80102f96:	c9                   	leave  
80102f97:	c3                   	ret    

80102f98 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f98:	55                   	push   %ebp
80102f99:	89 e5                	mov    %esp,%ebp
80102f9b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9e:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa3:	89 c2                	mov    %eax,%edx
80102fa5:	a1 64 41 19 80       	mov    0x80194164,%eax
80102faa:	83 ec 08             	sub    $0x8,%esp
80102fad:	52                   	push   %edx
80102fae:	50                   	push   %eax
80102faf:	e8 4d d2 ff ff       	call   80100201 <bread>
80102fb4:	83 c4 10             	add    $0x10,%esp
80102fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbd:	83 c0 5c             	add    $0x5c,%eax
80102fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc3:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd5:	eb 1b                	jmp    80102ff2 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fda:	83 c0 10             	add    $0x10,%eax
80102fdd:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fea:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff2:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffa:	7c db                	jl     80102fd7 <write_head+0x3f>
  }
  bwrite(buf);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	ff 75 f0             	push   -0x10(%ebp)
80103002:	e8 33 d2 ff ff       	call   8010023a <bwrite>
80103007:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300a:	83 ec 0c             	sub    $0xc,%esp
8010300d:	ff 75 f0             	push   -0x10(%ebp)
80103010:	e8 6e d2 ff ff       	call   80100283 <brelse>
80103015:	83 c4 10             	add    $0x10,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <recover_from_log>:

static void
recover_from_log(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103021:	e8 fe fe ff ff       	call   80102f24 <read_head>
  install_trans(); // if committed, copy from log to disk
80103026:	e8 40 fe ff ff       	call   80102e6b <install_trans>
  log.lh.n = 0;
8010302b:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103032:	00 00 00 
  write_head(); // clear the log
80103035:	e8 5e ff ff ff       	call   80102f98 <write_head>
}
8010303a:	90                   	nop
8010303b:	c9                   	leave  
8010303c:	c3                   	ret    

8010303d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103043:	83 ec 0c             	sub    $0xc,%esp
80103046:	68 20 41 19 80       	push   $0x80194120
8010304b:	e8 fe 17 00 00       	call   8010484e <acquire>
80103050:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103053:	a1 60 41 19 80       	mov    0x80194160,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 17                	je     80103073 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305c:	83 ec 08             	sub    $0x8,%esp
8010305f:	68 20 41 19 80       	push   $0x80194120
80103064:	68 20 41 19 80       	push   $0x80194120
80103069:	e8 6c 12 00 00       	call   801042da <sleep>
8010306e:	83 c4 10             	add    $0x10,%esp
80103071:	eb e0                	jmp    80103053 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103073:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103079:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307e:	8d 50 01             	lea    0x1(%eax),%edx
80103081:	89 d0                	mov    %edx,%eax
80103083:	c1 e0 02             	shl    $0x2,%eax
80103086:	01 d0                	add    %edx,%eax
80103088:	01 c0                	add    %eax,%eax
8010308a:	01 c8                	add    %ecx,%eax
8010308c:	83 f8 1e             	cmp    $0x1e,%eax
8010308f:	7e 17                	jle    801030a8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103091:	83 ec 08             	sub    $0x8,%esp
80103094:	68 20 41 19 80       	push   $0x80194120
80103099:	68 20 41 19 80       	push   $0x80194120
8010309e:	e8 37 12 00 00       	call   801042da <sleep>
801030a3:	83 c4 10             	add    $0x10,%esp
801030a6:	eb ab                	jmp    80103053 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a8:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ad:	83 c0 01             	add    $0x1,%eax
801030b0:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b5:	83 ec 0c             	sub    $0xc,%esp
801030b8:	68 20 41 19 80       	push   $0x80194120
801030bd:	e8 fa 17 00 00       	call   801048bc <release>
801030c2:	83 c4 10             	add    $0x10,%esp
      break;
801030c5:	90                   	nop
    }
  }
}
801030c6:	90                   	nop
801030c7:	c9                   	leave  
801030c8:	c3                   	ret    

801030c9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c9:	55                   	push   %ebp
801030ca:	89 e5                	mov    %esp,%ebp
801030cc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d6:	83 ec 0c             	sub    $0xc,%esp
801030d9:	68 20 41 19 80       	push   $0x80194120
801030de:	e8 6b 17 00 00       	call   8010484e <acquire>
801030e3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030eb:	83 e8 01             	sub    $0x1,%eax
801030ee:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f3:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f8:	85 c0                	test   %eax,%eax
801030fa:	74 0d                	je     80103109 <end_op+0x40>
    panic("log.committing");
801030fc:	83 ec 0c             	sub    $0xc,%esp
801030ff:	68 f9 a3 10 80       	push   $0x8010a3f9
80103104:	e8 a0 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103109:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310e:	85 c0                	test   %eax,%eax
80103110:	75 13                	jne    80103125 <end_op+0x5c>
    do_commit = 1;
80103112:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103119:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103120:	00 00 00 
80103123:	eb 10                	jmp    80103135 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103125:	83 ec 0c             	sub    $0xc,%esp
80103128:	68 20 41 19 80       	push   $0x80194120
8010312d:	e8 8f 12 00 00       	call   801043c1 <wakeup>
80103132:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103135:	83 ec 0c             	sub    $0xc,%esp
80103138:	68 20 41 19 80       	push   $0x80194120
8010313d:	e8 7a 17 00 00       	call   801048bc <release>
80103142:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103149:	74 3f                	je     8010318a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314b:	e8 f6 00 00 00       	call   80103246 <commit>
    acquire(&log.lock);
80103150:	83 ec 0c             	sub    $0xc,%esp
80103153:	68 20 41 19 80       	push   $0x80194120
80103158:	e8 f1 16 00 00       	call   8010484e <acquire>
8010315d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103160:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103167:	00 00 00 
    wakeup(&log);
8010316a:	83 ec 0c             	sub    $0xc,%esp
8010316d:	68 20 41 19 80       	push   $0x80194120
80103172:	e8 4a 12 00 00       	call   801043c1 <wakeup>
80103177:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317a:	83 ec 0c             	sub    $0xc,%esp
8010317d:	68 20 41 19 80       	push   $0x80194120
80103182:	e8 35 17 00 00       	call   801048bc <release>
80103187:	83 c4 10             	add    $0x10,%esp
  }
}
8010318a:	90                   	nop
8010318b:	c9                   	leave  
8010318c:	c3                   	ret    

8010318d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318d:	55                   	push   %ebp
8010318e:	89 e5                	mov    %esp,%ebp
80103190:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319a:	e9 95 00 00 00       	jmp    80103234 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319f:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a8:	01 d0                	add    %edx,%eax
801031aa:	83 c0 01             	add    $0x1,%eax
801031ad:	89 c2                	mov    %eax,%edx
801031af:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b4:	83 ec 08             	sub    $0x8,%esp
801031b7:	52                   	push   %edx
801031b8:	50                   	push   %eax
801031b9:	e8 43 d0 ff ff       	call   80100201 <bread>
801031be:	83 c4 10             	add    $0x10,%esp
801031c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c7:	83 c0 10             	add    $0x10,%eax
801031ca:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d1:	89 c2                	mov    %eax,%edx
801031d3:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d8:	83 ec 08             	sub    $0x8,%esp
801031db:	52                   	push   %edx
801031dc:	50                   	push   %eax
801031dd:	e8 1f d0 ff ff       	call   80100201 <bread>
801031e2:	83 c4 10             	add    $0x10,%esp
801031e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f1:	83 c0 5c             	add    $0x5c,%eax
801031f4:	83 ec 04             	sub    $0x4,%esp
801031f7:	68 00 02 00 00       	push   $0x200
801031fc:	52                   	push   %edx
801031fd:	50                   	push   %eax
801031fe:	e8 80 19 00 00       	call   80104b83 <memmove>
80103203:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	ff 75 f0             	push   -0x10(%ebp)
8010320c:	e8 29 d0 ff ff       	call   8010023a <bwrite>
80103211:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103214:	83 ec 0c             	sub    $0xc,%esp
80103217:	ff 75 ec             	push   -0x14(%ebp)
8010321a:	e8 64 d0 ff ff       	call   80100283 <brelse>
8010321f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	ff 75 f0             	push   -0x10(%ebp)
80103228:	e8 56 d0 ff ff       	call   80100283 <brelse>
8010322d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103230:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103234:	a1 68 41 19 80       	mov    0x80194168,%eax
80103239:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323c:	0f 8c 5d ff ff ff    	jl     8010319f <write_log+0x12>
  }
}
80103242:	90                   	nop
80103243:	90                   	nop
80103244:	c9                   	leave  
80103245:	c3                   	ret    

80103246 <commit>:

static void
commit()
{
80103246:	55                   	push   %ebp
80103247:	89 e5                	mov    %esp,%ebp
80103249:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103251:	85 c0                	test   %eax,%eax
80103253:	7e 1e                	jle    80103273 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103255:	e8 33 ff ff ff       	call   8010318d <write_log>
    write_head();    // Write header to disk -- the real commit
8010325a:	e8 39 fd ff ff       	call   80102f98 <write_head>
    install_trans(); // Now install writes to home locations
8010325f:	e8 07 fc ff ff       	call   80102e6b <install_trans>
    log.lh.n = 0;
80103264:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326e:	e8 25 fd ff ff       	call   80102f98 <write_head>
  }
}
80103273:	90                   	nop
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
80103279:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103281:	83 f8 1d             	cmp    $0x1d,%eax
80103284:	7f 12                	jg     80103298 <log_write+0x22>
80103286:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328b:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103291:	83 ea 01             	sub    $0x1,%edx
80103294:	39 d0                	cmp    %edx,%eax
80103296:	7c 0d                	jl     801032a5 <log_write+0x2f>
    panic("too big a transaction");
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	68 08 a4 10 80       	push   $0x8010a408
801032a0:	e8 04 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032aa:	85 c0                	test   %eax,%eax
801032ac:	7f 0d                	jg     801032bb <log_write+0x45>
    panic("log_write outside of trans");
801032ae:	83 ec 0c             	sub    $0xc,%esp
801032b1:	68 1e a4 10 80       	push   $0x8010a41e
801032b6:	e8 ee d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 20 41 19 80       	push   $0x80194120
801032c3:	e8 86 15 00 00       	call   8010484e <acquire>
801032c8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d2:	eb 1d                	jmp    801032f1 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d7:	83 c0 10             	add    $0x10,%eax
801032da:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e1:	89 c2                	mov    %eax,%edx
801032e3:	8b 45 08             	mov    0x8(%ebp),%eax
801032e6:	8b 40 08             	mov    0x8(%eax),%eax
801032e9:	39 c2                	cmp    %eax,%edx
801032eb:	74 10                	je     801032fd <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f1:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f9:	7c d9                	jl     801032d4 <log_write+0x5e>
801032fb:	eb 01                	jmp    801032fe <log_write+0x88>
      break;
801032fd:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103301:	8b 40 08             	mov    0x8(%eax),%eax
80103304:	89 c2                	mov    %eax,%edx
80103306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103309:	83 c0 10             	add    $0x10,%eax
8010330c:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103313:	a1 68 41 19 80       	mov    0x80194168,%eax
80103318:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331b:	75 0d                	jne    8010332a <log_write+0xb4>
    log.lh.n++;
8010331d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103322:	83 c0 01             	add    $0x1,%eax
80103325:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332a:	8b 45 08             	mov    0x8(%ebp),%eax
8010332d:	8b 00                	mov    (%eax),%eax
8010332f:	83 c8 04             	or     $0x4,%eax
80103332:	89 c2                	mov    %eax,%edx
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103339:	83 ec 0c             	sub    $0xc,%esp
8010333c:	68 20 41 19 80       	push   $0x80194120
80103341:	e8 76 15 00 00       	call   801048bc <release>
80103346:	83 c4 10             	add    $0x10,%esp
}
80103349:	90                   	nop
8010334a:	c9                   	leave  
8010334b:	c3                   	ret    

8010334c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334c:	55                   	push   %ebp
8010334d:	89 e5                	mov    %esp,%ebp
8010334f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103352:	8b 55 08             	mov    0x8(%ebp),%edx
80103355:	8b 45 0c             	mov    0xc(%ebp),%eax
80103358:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335b:	f0 87 02             	lock xchg %eax,(%edx)
8010335e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103361:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103364:	c9                   	leave  
80103365:	c3                   	ret    

80103366 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103366:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336a:	83 e4 f0             	and    $0xfffffff0,%esp
8010336d:	ff 71 fc             	push   -0x4(%ecx)
80103370:	55                   	push   %ebp
80103371:	89 e5                	mov    %esp,%ebp
80103373:	51                   	push   %ecx
80103374:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103377:	e8 df 4b 00 00       	call   80107f5b <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337c:	83 ec 08             	sub    $0x8,%esp
8010337f:	68 00 00 40 80       	push   $0x80400000
80103384:	68 00 80 19 80       	push   $0x80198000
80103389:	e8 de f2 ff ff       	call   8010266c <kinit1>
8010338e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103391:	e8 f4 41 00 00       	call   8010758a <kvmalloc>
  mpinit_uefi();
80103396:	e8 86 49 00 00       	call   80107d21 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339b:	e8 3c f6 ff ff       	call   801029dc <lapicinit>
  seginit();       // segment descriptors
801033a0:	e8 7d 3c 00 00       	call   80107022 <seginit>
  picinit();    // disable pic
801033a5:	e8 9d 01 00 00       	call   80103547 <picinit>
  ioapicinit();    // another interrupt controller
801033aa:	e8 d8 f1 ff ff       	call   80102587 <ioapicinit>
  consoleinit();   // console hardware
801033af:	e8 4b d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b4:	e8 02 30 00 00       	call   801063bb <uartinit>
  pinit();         // process table
801033b9:	e8 c2 05 00 00       	call   80103980 <pinit>
  tvinit();        // trap vectors
801033be:	e8 eb 2a 00 00       	call   80105eae <tvinit>
  binit();         // buffer cache
801033c3:	e8 9e cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c8:	e8 f3 db ff ff       	call   80100fc0 <fileinit>
  ideinit();       // disk 
801033cd:	e8 ca 6c 00 00       	call   8010a09c <ideinit>
  startothers();   // start other processors
801033d2:	e8 8a 00 00 00       	call   80103461 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	68 00 00 00 a0       	push   $0xa0000000
801033df:	68 00 00 40 80       	push   $0x80400000
801033e4:	e8 bc f2 ff ff       	call   801026a5 <kinit2>
801033e9:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ec:	e8 c3 4d 00 00       	call   801081b4 <pci_init>
  arp_scan();
801033f1:	e8 fa 5a 00 00       	call   80108ef0 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f6:	e8 63 07 00 00       	call   80103b5e <userinit>

  mpmain();        // finish this processor's setup
801033fb:	e8 1a 00 00 00       	call   8010341a <mpmain>

80103400 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103406:	e8 97 41 00 00       	call   801075a2 <switchkvm>
  seginit();
8010340b:	e8 12 3c 00 00       	call   80107022 <seginit>
  lapicinit();
80103410:	e8 c7 f5 ff ff       	call   801029dc <lapicinit>
  mpmain();
80103415:	e8 00 00 00 00       	call   8010341a <mpmain>

8010341a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	53                   	push   %ebx
8010341e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103421:	e8 78 05 00 00       	call   8010399e <cpuid>
80103426:	89 c3                	mov    %eax,%ebx
80103428:	e8 71 05 00 00       	call   8010399e <cpuid>
8010342d:	83 ec 04             	sub    $0x4,%esp
80103430:	53                   	push   %ebx
80103431:	50                   	push   %eax
80103432:	68 39 a4 10 80       	push   $0x8010a439
80103437:	e8 b8 cf ff ff       	call   801003f4 <cprintf>
8010343c:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343f:	e8 e0 2b 00 00       	call   80106024 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103444:	e8 70 05 00 00       	call   801039b9 <mycpu>
80103449:	05 a0 00 00 00       	add    $0xa0,%eax
8010344e:	83 ec 08             	sub    $0x8,%esp
80103451:	6a 01                	push   $0x1
80103453:	50                   	push   %eax
80103454:	e8 f3 fe ff ff       	call   8010334c <xchg>
80103459:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345c:	e8 88 0c 00 00       	call   801040e9 <scheduler>

80103461 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103467:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103473:	83 ec 04             	sub    $0x4,%esp
80103476:	50                   	push   %eax
80103477:	68 18 f5 10 80       	push   $0x8010f518
8010347c:	ff 75 f0             	push   -0x10(%ebp)
8010347f:	e8 ff 16 00 00       	call   80104b83 <memmove>
80103484:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103487:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010348e:	eb 79                	jmp    80103509 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103490:	e8 24 05 00 00       	call   801039b9 <mycpu>
80103495:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103498:	74 67                	je     80103501 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349a:	e8 02 f3 ff ff       	call   801027a1 <kalloc>
8010349f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a5:	83 e8 04             	sub    $0x4,%eax
801034a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ab:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b6:	83 e8 08             	sub    $0x8,%eax
801034b9:	c7 00 00 34 10 80    	movl   $0x80103400,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034bf:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 e8 0c             	sub    $0xc,%eax
801034d0:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034de:	0f b6 00             	movzbl (%eax),%eax
801034e1:	0f b6 c0             	movzbl %al,%eax
801034e4:	83 ec 08             	sub    $0x8,%esp
801034e7:	52                   	push   %edx
801034e8:	50                   	push   %eax
801034e9:	e8 50 f6 ff ff       	call   80102b3e <lapicstartap>
801034ee:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f1:	90                   	nop
801034f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fb:	85 c0                	test   %eax,%eax
801034fd:	74 f3                	je     801034f2 <startothers+0x91>
801034ff:	eb 01                	jmp    80103502 <startothers+0xa1>
      continue;
80103501:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103502:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103509:	a1 40 6c 19 80       	mov    0x80196c40,%eax
8010350e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103514:	05 80 69 19 80       	add    $0x80196980,%eax
80103519:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351c:	0f 82 6e ff ff ff    	jb     80103490 <startothers+0x2f>
      ;
  }
}
80103522:	90                   	nop
80103523:	90                   	nop
80103524:	c9                   	leave  
80103525:	c3                   	ret    

80103526 <outb>:
{
80103526:	55                   	push   %ebp
80103527:	89 e5                	mov    %esp,%ebp
80103529:	83 ec 08             	sub    $0x8,%esp
8010352c:	8b 45 08             	mov    0x8(%ebp),%eax
8010352f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103532:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103536:	89 d0                	mov    %edx,%eax
80103538:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103543:	ee                   	out    %al,(%dx)
}
80103544:	90                   	nop
80103545:	c9                   	leave  
80103546:	c3                   	ret    

80103547 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103547:	55                   	push   %ebp
80103548:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010354a:	68 ff 00 00 00       	push   $0xff
8010354f:	6a 21                	push   $0x21
80103551:	e8 d0 ff ff ff       	call   80103526 <outb>
80103556:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103559:	68 ff 00 00 00       	push   $0xff
8010355e:	68 a1 00 00 00       	push   $0xa1
80103563:	e8 be ff ff ff       	call   80103526 <outb>
80103568:	83 c4 08             	add    $0x8,%esp
}
8010356b:	90                   	nop
8010356c:	c9                   	leave  
8010356d:	c3                   	ret    

8010356e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103584:	8b 45 0c             	mov    0xc(%ebp),%eax
80103587:	8b 10                	mov    (%eax),%edx
80103589:	8b 45 08             	mov    0x8(%ebp),%eax
8010358c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358e:	e8 4b da ff ff       	call   80100fde <filealloc>
80103593:	8b 55 08             	mov    0x8(%ebp),%edx
80103596:	89 02                	mov    %eax,(%edx)
80103598:	8b 45 08             	mov    0x8(%ebp),%eax
8010359b:	8b 00                	mov    (%eax),%eax
8010359d:	85 c0                	test   %eax,%eax
8010359f:	0f 84 c8 00 00 00    	je     8010366d <pipealloc+0xff>
801035a5:	e8 34 da ff ff       	call   80100fde <filealloc>
801035aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ad:	89 02                	mov    %eax,(%edx)
801035af:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b2:	8b 00                	mov    (%eax),%eax
801035b4:	85 c0                	test   %eax,%eax
801035b6:	0f 84 b1 00 00 00    	je     8010366d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bc:	e8 e0 f1 ff ff       	call   801027a1 <kalloc>
801035c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c8:	0f 84 a2 00 00 00    	je     80103670 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d8:	00 00 00 
  p->writeopen = 1;
801035db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035de:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e5:	00 00 00 
  p->nwrite = 0;
801035e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035eb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f2:	00 00 00 
  p->nread = 0;
801035f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035ff:	00 00 00 
  initlock(&p->lock, "pipe");
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	83 ec 08             	sub    $0x8,%esp
80103608:	68 4d a4 10 80       	push   $0x8010a44d
8010360d:	50                   	push   %eax
8010360e:	e8 19 12 00 00       	call   8010482c <initlock>
80103613:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103616:	8b 45 08             	mov    0x8(%ebp),%eax
80103619:	8b 00                	mov    (%eax),%eax
8010361b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103621:	8b 45 08             	mov    0x8(%ebp),%eax
80103624:	8b 00                	mov    (%eax),%eax
80103626:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010362a:	8b 45 08             	mov    0x8(%ebp),%eax
8010362d:	8b 00                	mov    (%eax),%eax
8010362f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103633:	8b 45 08             	mov    0x8(%ebp),%eax
80103636:	8b 00                	mov    (%eax),%eax
80103638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103641:	8b 00                	mov    (%eax),%eax
80103643:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364c:	8b 00                	mov    (%eax),%eax
8010364e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103652:	8b 45 0c             	mov    0xc(%ebp),%eax
80103655:	8b 00                	mov    (%eax),%eax
80103657:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365e:	8b 00                	mov    (%eax),%eax
80103660:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103663:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103666:	b8 00 00 00 00       	mov    $0x0,%eax
8010366b:	eb 51                	jmp    801036be <pipealloc+0x150>
    goto bad;
8010366d:	90                   	nop
8010366e:	eb 01                	jmp    80103671 <pipealloc+0x103>
    goto bad;
80103670:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103675:	74 0e                	je     80103685 <pipealloc+0x117>
    kfree((char*)p);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	ff 75 f4             	push   -0xc(%ebp)
8010367d:	e8 85 f0 ff ff       	call   80102707 <kfree>
80103682:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103685:	8b 45 08             	mov    0x8(%ebp),%eax
80103688:	8b 00                	mov    (%eax),%eax
8010368a:	85 c0                	test   %eax,%eax
8010368c:	74 11                	je     8010369f <pipealloc+0x131>
    fileclose(*f0);
8010368e:	8b 45 08             	mov    0x8(%ebp),%eax
80103691:	8b 00                	mov    (%eax),%eax
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	50                   	push   %eax
80103697:	e8 00 da ff ff       	call   8010109c <fileclose>
8010369c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369f:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a2:	8b 00                	mov    (%eax),%eax
801036a4:	85 c0                	test   %eax,%eax
801036a6:	74 11                	je     801036b9 <pipealloc+0x14b>
    fileclose(*f1);
801036a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ab:	8b 00                	mov    (%eax),%eax
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	50                   	push   %eax
801036b1:	e8 e6 d9 ff ff       	call   8010109c <fileclose>
801036b6:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036be:	c9                   	leave  
801036bf:	c3                   	ret    

801036c0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	83 ec 0c             	sub    $0xc,%esp
801036cc:	50                   	push   %eax
801036cd:	e8 7c 11 00 00       	call   8010484e <acquire>
801036d2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d9:	74 23                	je     801036fe <pipeclose+0x3e>
    p->writeopen = 0;
801036db:	8b 45 08             	mov    0x8(%ebp),%eax
801036de:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e5:	00 00 00 
    wakeup(&p->nread);
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	05 34 02 00 00       	add    $0x234,%eax
801036f0:	83 ec 0c             	sub    $0xc,%esp
801036f3:	50                   	push   %eax
801036f4:	e8 c8 0c 00 00       	call   801043c1 <wakeup>
801036f9:	83 c4 10             	add    $0x10,%esp
801036fc:	eb 21                	jmp    8010371f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103701:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103708:	00 00 00 
    wakeup(&p->nwrite);
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	05 38 02 00 00       	add    $0x238,%eax
80103713:	83 ec 0c             	sub    $0xc,%esp
80103716:	50                   	push   %eax
80103717:	e8 a5 0c 00 00       	call   801043c1 <wakeup>
8010371c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371f:	8b 45 08             	mov    0x8(%ebp),%eax
80103722:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103728:	85 c0                	test   %eax,%eax
8010372a:	75 2c                	jne    80103758 <pipeclose+0x98>
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	75 1f                	jne    80103758 <pipeclose+0x98>
    release(&p->lock);
80103739:	8b 45 08             	mov    0x8(%ebp),%eax
8010373c:	83 ec 0c             	sub    $0xc,%esp
8010373f:	50                   	push   %eax
80103740:	e8 77 11 00 00       	call   801048bc <release>
80103745:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103748:	83 ec 0c             	sub    $0xc,%esp
8010374b:	ff 75 08             	push   0x8(%ebp)
8010374e:	e8 b4 ef ff ff       	call   80102707 <kfree>
80103753:	83 c4 10             	add    $0x10,%esp
80103756:	eb 10                	jmp    80103768 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103758:	8b 45 08             	mov    0x8(%ebp),%eax
8010375b:	83 ec 0c             	sub    $0xc,%esp
8010375e:	50                   	push   %eax
8010375f:	e8 58 11 00 00       	call   801048bc <release>
80103764:	83 c4 10             	add    $0x10,%esp
}
80103767:	90                   	nop
80103768:	90                   	nop
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	53                   	push   %ebx
8010376f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	83 ec 0c             	sub    $0xc,%esp
80103778:	50                   	push   %eax
80103779:	e8 d0 10 00 00       	call   8010484e <acquire>
8010377e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103788:	e9 ad 00 00 00       	jmp    8010383a <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378d:	8b 45 08             	mov    0x8(%ebp),%eax
80103790:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103796:	85 c0                	test   %eax,%eax
80103798:	74 0c                	je     801037a6 <pipewrite+0x3b>
8010379a:	e8 92 02 00 00       	call   80103a31 <myproc>
8010379f:	8b 40 24             	mov    0x24(%eax),%eax
801037a2:	85 c0                	test   %eax,%eax
801037a4:	74 19                	je     801037bf <pipewrite+0x54>
        release(&p->lock);
801037a6:	8b 45 08             	mov    0x8(%ebp),%eax
801037a9:	83 ec 0c             	sub    $0xc,%esp
801037ac:	50                   	push   %eax
801037ad:	e8 0a 11 00 00       	call   801048bc <release>
801037b2:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037ba:	e9 a9 00 00 00       	jmp    80103868 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037bf:	8b 45 08             	mov    0x8(%ebp),%eax
801037c2:	05 34 02 00 00       	add    $0x234,%eax
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	50                   	push   %eax
801037cb:	e8 f1 0b 00 00       	call   801043c1 <wakeup>
801037d0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	8b 55 08             	mov    0x8(%ebp),%edx
801037d9:	81 c2 38 02 00 00    	add    $0x238,%edx
801037df:	83 ec 08             	sub    $0x8,%esp
801037e2:	50                   	push   %eax
801037e3:	52                   	push   %edx
801037e4:	e8 f1 0a 00 00       	call   801042da <sleep>
801037e9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037ec:	8b 45 08             	mov    0x8(%ebp),%eax
801037ef:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f5:	8b 45 08             	mov    0x8(%ebp),%eax
801037f8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fe:	05 00 02 00 00       	add    $0x200,%eax
80103803:	39 c2                	cmp    %eax,%edx
80103805:	74 86                	je     8010378d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103807:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010380a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103810:	8b 45 08             	mov    0x8(%ebp),%eax
80103813:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103819:	8d 48 01             	lea    0x1(%eax),%ecx
8010381c:	8b 55 08             	mov    0x8(%ebp),%edx
8010381f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103825:	25 ff 01 00 00       	and    $0x1ff,%eax
8010382a:	89 c1                	mov    %eax,%ecx
8010382c:	0f b6 13             	movzbl (%ebx),%edx
8010382f:	8b 45 08             	mov    0x8(%ebp),%eax
80103832:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103836:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010383a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103840:	7c aa                	jl     801037ec <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103842:	8b 45 08             	mov    0x8(%ebp),%eax
80103845:	05 34 02 00 00       	add    $0x234,%eax
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	50                   	push   %eax
8010384e:	e8 6e 0b 00 00       	call   801043c1 <wakeup>
80103853:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103856:	8b 45 08             	mov    0x8(%ebp),%eax
80103859:	83 ec 0c             	sub    $0xc,%esp
8010385c:	50                   	push   %eax
8010385d:	e8 5a 10 00 00       	call   801048bc <release>
80103862:	83 c4 10             	add    $0x10,%esp
  return n;
80103865:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386b:	c9                   	leave  
8010386c:	c3                   	ret    

8010386d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386d:	55                   	push   %ebp
8010386e:	89 e5                	mov    %esp,%ebp
80103870:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103873:	8b 45 08             	mov    0x8(%ebp),%eax
80103876:	83 ec 0c             	sub    $0xc,%esp
80103879:	50                   	push   %eax
8010387a:	e8 cf 0f 00 00       	call   8010484e <acquire>
8010387f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103882:	eb 3e                	jmp    801038c2 <piperead+0x55>
    if(myproc()->killed){
80103884:	e8 a8 01 00 00       	call   80103a31 <myproc>
80103889:	8b 40 24             	mov    0x24(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	74 19                	je     801038a9 <piperead+0x3c>
      release(&p->lock);
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	50                   	push   %eax
80103897:	e8 20 10 00 00       	call   801048bc <release>
8010389c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a4:	e9 be 00 00 00       	jmp    80103967 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ac:	8b 55 08             	mov    0x8(%ebp),%edx
801038af:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b5:	83 ec 08             	sub    $0x8,%esp
801038b8:	50                   	push   %eax
801038b9:	52                   	push   %edx
801038ba:	e8 1b 0a 00 00       	call   801042da <sleep>
801038bf:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c2:	8b 45 08             	mov    0x8(%ebp),%eax
801038c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038cb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d4:	39 c2                	cmp    %eax,%edx
801038d6:	75 0d                	jne    801038e5 <piperead+0x78>
801038d8:	8b 45 08             	mov    0x8(%ebp),%eax
801038db:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e1:	85 c0                	test   %eax,%eax
801038e3:	75 9f                	jne    80103884 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038ec:	eb 48                	jmp    80103936 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ee:	8b 45 08             	mov    0x8(%ebp),%eax
801038f1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f7:	8b 45 08             	mov    0x8(%ebp),%eax
801038fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103900:	39 c2                	cmp    %eax,%edx
80103902:	74 3c                	je     80103940 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390d:	8d 48 01             	lea    0x1(%eax),%ecx
80103910:	8b 55 08             	mov    0x8(%ebp),%edx
80103913:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103919:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391e:	89 c1                	mov    %eax,%ecx
80103920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103923:	8b 45 0c             	mov    0xc(%ebp),%eax
80103926:	01 c2                	add    %eax,%edx
80103928:	8b 45 08             	mov    0x8(%ebp),%eax
8010392b:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103930:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103932:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103939:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393c:	7c b0                	jl     801038ee <piperead+0x81>
8010393e:	eb 01                	jmp    80103941 <piperead+0xd4>
      break;
80103940:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103941:	8b 45 08             	mov    0x8(%ebp),%eax
80103944:	05 38 02 00 00       	add    $0x238,%eax
80103949:	83 ec 0c             	sub    $0xc,%esp
8010394c:	50                   	push   %eax
8010394d:	e8 6f 0a 00 00       	call   801043c1 <wakeup>
80103952:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103955:	8b 45 08             	mov    0x8(%ebp),%eax
80103958:	83 ec 0c             	sub    $0xc,%esp
8010395b:	50                   	push   %eax
8010395c:	e8 5b 0f 00 00       	call   801048bc <release>
80103961:	83 c4 10             	add    $0x10,%esp
  return i;
80103964:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103967:	c9                   	leave  
80103968:	c3                   	ret    

80103969 <readeflags>:
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396f:	9c                   	pushf  
80103970:	58                   	pop    %eax
80103971:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103974:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103977:	c9                   	leave  
80103978:	c3                   	ret    

80103979 <sti>:
{
80103979:	55                   	push   %ebp
8010397a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397c:	fb                   	sti    
}
8010397d:	90                   	nop
8010397e:	5d                   	pop    %ebp
8010397f:	c3                   	ret    

80103980 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103986:	83 ec 08             	sub    $0x8,%esp
80103989:	68 54 a4 10 80       	push   $0x8010a454
8010398e:	68 00 42 19 80       	push   $0x80194200
80103993:	e8 94 0e 00 00       	call   8010482c <initlock>
80103998:	83 c4 10             	add    $0x10,%esp
}
8010399b:	90                   	nop
8010399c:	c9                   	leave  
8010399d:	c3                   	ret    

8010399e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399e:	55                   	push   %ebp
8010399f:	89 e5                	mov    %esp,%ebp
801039a1:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a4:	e8 10 00 00 00       	call   801039b9 <mycpu>
801039a9:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039ae:	c1 f8 04             	sar    $0x4,%eax
801039b1:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
801039bc:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039bf:	e8 a5 ff ff ff       	call   80103969 <readeflags>
801039c4:	25 00 02 00 00       	and    $0x200,%eax
801039c9:	85 c0                	test   %eax,%eax
801039cb:	74 0d                	je     801039da <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cd:	83 ec 0c             	sub    $0xc,%esp
801039d0:	68 5c a4 10 80       	push   $0x8010a45c
801039d5:	e8 cf cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039da:	e8 1c f1 ff ff       	call   80102afb <lapicid>
801039df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e9:	eb 2d                	jmp    80103a18 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ee:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f4:	05 80 69 19 80       	add    $0x80196980,%eax
801039f9:	0f b6 00             	movzbl (%eax),%eax
801039fc:	0f b6 c0             	movzbl %al,%eax
801039ff:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a02:	75 10                	jne    80103a14 <mycpu+0x5b>
      return &cpus[i];
80103a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a07:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0d:	05 80 69 19 80       	add    $0x80196980,%eax
80103a12:	eb 1b                	jmp    80103a2f <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a18:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a1d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a20:	7c c9                	jl     801039eb <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a22:	83 ec 0c             	sub    $0xc,%esp
80103a25:	68 82 a4 10 80       	push   $0x8010a482
80103a2a:	e8 7a cb ff ff       	call   801005a9 <panic>
}
80103a2f:	c9                   	leave  
80103a30:	c3                   	ret    

80103a31 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a31:	55                   	push   %ebp
80103a32:	89 e5                	mov    %esp,%ebp
80103a34:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a37:	e8 7d 0f 00 00       	call   801049b9 <pushcli>
  c = mycpu();
80103a3c:	e8 78 ff ff ff       	call   801039b9 <mycpu>
80103a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a50:	e8 b1 0f 00 00       	call   80104a06 <popcli>
  return p;
80103a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a58:	c9                   	leave  
80103a59:	c3                   	ret    

80103a5a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a5a:	55                   	push   %ebp
80103a5b:	89 e5                	mov    %esp,%ebp
80103a5d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a60:	83 ec 0c             	sub    $0xc,%esp
80103a63:	68 00 42 19 80       	push   $0x80194200
80103a68:	e8 e1 0d 00 00       	call   8010484e <acquire>
80103a6d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a70:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a77:	eb 0e                	jmp    80103a87 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7f:	85 c0                	test   %eax,%eax
80103a81:	74 27                	je     80103aaa <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a83:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a87:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a8e:	72 e9                	jb     80103a79 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a90:	83 ec 0c             	sub    $0xc,%esp
80103a93:	68 00 42 19 80       	push   $0x80194200
80103a98:	e8 1f 0e 00 00       	call   801048bc <release>
80103a9d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa0:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa5:	e9 b2 00 00 00       	jmp    80103b5c <allocproc+0x102>
      goto found;
80103aaa:	90                   	nop

found:
  p->state = EMBRYO;
80103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aae:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab5:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aba:	8d 50 01             	lea    0x1(%eax),%edx
80103abd:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac6:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac9:	83 ec 0c             	sub    $0xc,%esp
80103acc:	68 00 42 19 80       	push   $0x80194200
80103ad1:	e8 e6 0d 00 00       	call   801048bc <release>
80103ad6:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad9:	e8 c3 ec ff ff       	call   801027a1 <kalloc>
80103ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae1:	89 42 08             	mov    %eax,0x8(%edx)
80103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae7:	8b 40 08             	mov    0x8(%eax),%eax
80103aea:	85 c0                	test   %eax,%eax
80103aec:	75 11                	jne    80103aff <allocproc+0xa5>
    p->state = UNUSED;
80103aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af8:	b8 00 00 00 00       	mov    $0x0,%eax
80103afd:	eb 5d                	jmp    80103b5c <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b02:	8b 40 08             	mov    0x8(%eax),%eax
80103b05:	05 00 10 00 00       	add    $0x1000,%eax
80103b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b17:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1e:	ba 5c 5e 10 80       	mov    $0x80105e5c,%edx
80103b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b26:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b28:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b32:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b38:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3b:	83 ec 04             	sub    $0x4,%esp
80103b3e:	6a 14                	push   $0x14
80103b40:	6a 00                	push   $0x0
80103b42:	50                   	push   %eax
80103b43:	e8 7c 0f 00 00       	call   80104ac4 <memset>
80103b48:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4e:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b51:	ba 94 42 10 80       	mov    $0x80104294,%edx
80103b56:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5c:	c9                   	leave  
80103b5d:	c3                   	ret    

80103b5e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5e:	55                   	push   %ebp
80103b5f:	89 e5                	mov    %esp,%ebp
80103b61:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b64:	e8 f1 fe ff ff       	call   80103a5a <allocproc>
80103b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6f:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b74:	e8 25 39 00 00       	call   8010749e <setupkvm>
80103b79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7c:	89 42 04             	mov    %eax,0x4(%edx)
80103b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b82:	8b 40 04             	mov    0x4(%eax),%eax
80103b85:	85 c0                	test   %eax,%eax
80103b87:	75 0d                	jne    80103b96 <userinit+0x38>
    panic("userinit: out of memory?");
80103b89:	83 ec 0c             	sub    $0xc,%esp
80103b8c:	68 92 a4 10 80       	push   $0x8010a492
80103b91:	e8 13 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b96:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9e:	8b 40 04             	mov    0x4(%eax),%eax
80103ba1:	83 ec 04             	sub    $0x4,%esp
80103ba4:	52                   	push   %edx
80103ba5:	68 ec f4 10 80       	push   $0x8010f4ec
80103baa:	50                   	push   %eax
80103bab:	e8 aa 3b 00 00       	call   8010775a <inituvm>
80103bb0:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbf:	8b 40 18             	mov    0x18(%eax),%eax
80103bc2:	83 ec 04             	sub    $0x4,%esp
80103bc5:	6a 4c                	push   $0x4c
80103bc7:	6a 00                	push   $0x0
80103bc9:	50                   	push   %eax
80103bca:	e8 f5 0e 00 00       	call   80104ac4 <memset>
80103bcf:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	8b 40 18             	mov    0x18(%eax),%eax
80103bd8:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be1:	8b 40 18             	mov    0x18(%eax),%eax
80103be4:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	8b 50 18             	mov    0x18(%eax),%edx
80103bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf3:	8b 40 18             	mov    0x18(%eax),%eax
80103bf6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfa:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 50 18             	mov    0x18(%eax),%edx
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	8b 40 18             	mov    0x18(%eax),%eax
80103c0a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c15:	8b 40 18             	mov    0x18(%eax),%eax
80103c18:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c22:	8b 40 18             	mov    0x18(%eax),%eax
80103c25:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	8b 40 18             	mov    0x18(%eax),%eax
80103c32:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	83 c0 6c             	add    $0x6c,%eax
80103c3f:	83 ec 04             	sub    $0x4,%esp
80103c42:	6a 10                	push   $0x10
80103c44:	68 ab a4 10 80       	push   $0x8010a4ab
80103c49:	50                   	push   %eax
80103c4a:	e8 78 10 00 00       	call   80104cc7 <safestrcpy>
80103c4f:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c52:	83 ec 0c             	sub    $0xc,%esp
80103c55:	68 b4 a4 10 80       	push   $0x8010a4b4
80103c5a:	e8 bf e8 ff ff       	call   8010251e <namei>
80103c5f:	83 c4 10             	add    $0x10,%esp
80103c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c65:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c68:	83 ec 0c             	sub    $0xc,%esp
80103c6b:	68 00 42 19 80       	push   $0x80194200
80103c70:	e8 d9 0b 00 00       	call   8010484e <acquire>
80103c75:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c82:	83 ec 0c             	sub    $0xc,%esp
80103c85:	68 00 42 19 80       	push   $0x80194200
80103c8a:	e8 2d 0c 00 00       	call   801048bc <release>
80103c8f:	83 c4 10             	add    $0x10,%esp
}
80103c92:	90                   	nop
80103c93:	c9                   	leave  
80103c94:	c3                   	ret    

80103c95 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c95:	55                   	push   %ebp
80103c96:	89 e5                	mov    %esp,%ebp
80103c98:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9b:	e8 91 fd ff ff       	call   80103a31 <myproc>
80103ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca6:	8b 00                	mov    (%eax),%eax
80103ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103caf:	7e 2e                	jle    80103cdf <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb1:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb7:	01 c2                	add    %eax,%edx
80103cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbc:	8b 40 04             	mov    0x4(%eax),%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	52                   	push   %edx
80103cc3:	ff 75 f4             	push   -0xc(%ebp)
80103cc6:	50                   	push   %eax
80103cc7:	e8 cb 3b 00 00       	call   80107897 <allocuvm>
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd6:	75 3b                	jne    80103d13 <growproc+0x7e>
      return -1;
80103cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdd:	eb 4f                	jmp    80103d2e <growproc+0x99>
  } else if(n < 0){
80103cdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce3:	79 2e                	jns    80103d13 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce5:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	01 c2                	add    %eax,%edx
80103ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf0:	8b 40 04             	mov    0x4(%eax),%eax
80103cf3:	83 ec 04             	sub    $0x4,%esp
80103cf6:	52                   	push   %edx
80103cf7:	ff 75 f4             	push   -0xc(%ebp)
80103cfa:	50                   	push   %eax
80103cfb:	e8 9c 3c 00 00       	call   8010799c <deallocuvm>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0a:	75 07                	jne    80103d13 <growproc+0x7e>
      return -1;
80103d0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d11:	eb 1b                	jmp    80103d2e <growproc+0x99>
  }
  curproc->sz = sz;
80103d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d19:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1b:	83 ec 0c             	sub    $0xc,%esp
80103d1e:	ff 75 f0             	push   -0x10(%ebp)
80103d21:	e8 95 38 00 00       	call   801075bb <switchuvm>
80103d26:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2e:	c9                   	leave  
80103d2f:	c3                   	ret    

80103d30 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d30:	55                   	push   %ebp
80103d31:	89 e5                	mov    %esp,%ebp
80103d33:	57                   	push   %edi
80103d34:	56                   	push   %esi
80103d35:	53                   	push   %ebx
80103d36:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d39:	e8 f3 fc ff ff       	call   80103a31 <myproc>
80103d3e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d41:	e8 14 fd ff ff       	call   80103a5a <allocproc>
80103d46:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d49:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4d:	75 0a                	jne    80103d59 <fork+0x29>
    return -1;
80103d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d54:	e9 48 01 00 00       	jmp    80103ea1 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5c:	8b 10                	mov    (%eax),%edx
80103d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d61:	8b 40 04             	mov    0x4(%eax),%eax
80103d64:	83 ec 08             	sub    $0x8,%esp
80103d67:	52                   	push   %edx
80103d68:	50                   	push   %eax
80103d69:	e8 cc 3d 00 00       	call   80107b3a <copyuvm>
80103d6e:	83 c4 10             	add    $0x10,%esp
80103d71:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d74:	89 42 04             	mov    %eax,0x4(%edx)
80103d77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7a:	8b 40 04             	mov    0x4(%eax),%eax
80103d7d:	85 c0                	test   %eax,%eax
80103d7f:	75 30                	jne    80103db1 <fork+0x81>
    kfree(np->kstack);
80103d81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d84:	8b 40 08             	mov    0x8(%eax),%eax
80103d87:	83 ec 0c             	sub    $0xc,%esp
80103d8a:	50                   	push   %eax
80103d8b:	e8 77 e9 ff ff       	call   80102707 <kfree>
80103d90:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d93:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dac:	e9 f0 00 00 00       	jmp    80103ea1 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db4:	8b 10                	mov    (%eax),%edx
80103db6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db9:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc7:	8b 48 18             	mov    0x18(%eax),%ecx
80103dca:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcd:	8b 40 18             	mov    0x18(%eax),%eax
80103dd0:	89 c2                	mov    %eax,%edx
80103dd2:	89 cb                	mov    %ecx,%ebx
80103dd4:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd9:	89 d7                	mov    %edx,%edi
80103ddb:	89 de                	mov    %ebx,%esi
80103ddd:	89 c1                	mov    %eax,%ecx
80103ddf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de4:	8b 40 18             	mov    0x18(%eax),%eax
80103de7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103dee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df5:	eb 3b                	jmp    80103e32 <fork+0x102>
    if(curproc->ofile[i])
80103df7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfd:	83 c2 08             	add    $0x8,%edx
80103e00:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e04:	85 c0                	test   %eax,%eax
80103e06:	74 26                	je     80103e2e <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0e:	83 c2 08             	add    $0x8,%edx
80103e11:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e15:	83 ec 0c             	sub    $0xc,%esp
80103e18:	50                   	push   %eax
80103e19:	e8 2d d2 ff ff       	call   8010104b <filedup>
80103e1e:	83 c4 10             	add    $0x10,%esp
80103e21:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e24:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e27:	83 c1 08             	add    $0x8,%ecx
80103e2a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e32:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e36:	7e bf                	jle    80103df7 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3b:	8b 40 68             	mov    0x68(%eax),%eax
80103e3e:	83 ec 0c             	sub    $0xc,%esp
80103e41:	50                   	push   %eax
80103e42:	e8 6a db ff ff       	call   801019b1 <idup>
80103e47:	83 c4 10             	add    $0x10,%esp
80103e4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4d:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e53:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e59:	83 c0 6c             	add    $0x6c,%eax
80103e5c:	83 ec 04             	sub    $0x4,%esp
80103e5f:	6a 10                	push   $0x10
80103e61:	52                   	push   %edx
80103e62:	50                   	push   %eax
80103e63:	e8 5f 0e 00 00       	call   80104cc7 <safestrcpy>
80103e68:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6e:	8b 40 10             	mov    0x10(%eax),%eax
80103e71:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e74:	83 ec 0c             	sub    $0xc,%esp
80103e77:	68 00 42 19 80       	push   $0x80194200
80103e7c:	e8 cd 09 00 00       	call   8010484e <acquire>
80103e81:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e87:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8e:	83 ec 0c             	sub    $0xc,%esp
80103e91:	68 00 42 19 80       	push   $0x80194200
80103e96:	e8 21 0a 00 00       	call   801048bc <release>
80103e9b:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea4:	5b                   	pop    %ebx
80103ea5:	5e                   	pop    %esi
80103ea6:	5f                   	pop    %edi
80103ea7:	5d                   	pop    %ebp
80103ea8:	c3                   	ret    

80103ea9 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea9:	55                   	push   %ebp
80103eaa:	89 e5                	mov    %esp,%ebp
80103eac:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eaf:	e8 7d fb ff ff       	call   80103a31 <myproc>
80103eb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb7:	a1 34 61 19 80       	mov    0x80196134,%eax
80103ebc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebf:	75 0d                	jne    80103ece <exit+0x25>
    panic("init exiting");
80103ec1:	83 ec 0c             	sub    $0xc,%esp
80103ec4:	68 b6 a4 10 80       	push   $0x8010a4b6
80103ec9:	e8 db c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ece:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed5:	eb 3f                	jmp    80103f16 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eda:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edd:	83 c2 08             	add    $0x8,%edx
80103ee0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee4:	85 c0                	test   %eax,%eax
80103ee6:	74 2a                	je     80103f12 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eee:	83 c2 08             	add    $0x8,%edx
80103ef1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef5:	83 ec 0c             	sub    $0xc,%esp
80103ef8:	50                   	push   %eax
80103ef9:	e8 9e d1 ff ff       	call   8010109c <fileclose>
80103efe:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f07:	83 c2 08             	add    $0x8,%edx
80103f0a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f11:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f12:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f16:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f1a:	7e bb                	jle    80103ed7 <exit+0x2e>
    }
  }

  begin_op();
80103f1c:	e8 1c f1 ff ff       	call   8010303d <begin_op>
  iput(curproc->cwd);
80103f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f24:	8b 40 68             	mov    0x68(%eax),%eax
80103f27:	83 ec 0c             	sub    $0xc,%esp
80103f2a:	50                   	push   %eax
80103f2b:	e8 1c dc ff ff       	call   80101b4c <iput>
80103f30:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f33:	e8 91 f1 ff ff       	call   801030c9 <end_op>
  curproc->cwd = 0;
80103f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f42:	83 ec 0c             	sub    $0xc,%esp
80103f45:	68 00 42 19 80       	push   $0x80194200
80103f4a:	e8 ff 08 00 00       	call   8010484e <acquire>
80103f4f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f55:	8b 40 14             	mov    0x14(%eax),%eax
80103f58:	83 ec 0c             	sub    $0xc,%esp
80103f5b:	50                   	push   %eax
80103f5c:	e8 20 04 00 00       	call   80104381 <wakeup1>
80103f61:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f64:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6b:	eb 37                	jmp    80103fa4 <exit+0xfb>
    if(p->parent == curproc){
80103f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f70:	8b 40 14             	mov    0x14(%eax),%eax
80103f73:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f76:	75 28                	jne    80103fa0 <exit+0xf7>
      p->parent = initproc;
80103f78:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f81:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f87:	8b 40 0c             	mov    0xc(%eax),%eax
80103f8a:	83 f8 05             	cmp    $0x5,%eax
80103f8d:	75 11                	jne    80103fa0 <exit+0xf7>
        wakeup1(initproc);
80103f8f:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f94:	83 ec 0c             	sub    $0xc,%esp
80103f97:	50                   	push   %eax
80103f98:	e8 e4 03 00 00       	call   80104381 <wakeup1>
80103f9d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103fa4:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103fab:	72 c0                	jb     80103f6d <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb7:	e8 e5 01 00 00       	call   801041a1 <sched>
  panic("zombie exit");
80103fbc:	83 ec 0c             	sub    $0xc,%esp
80103fbf:	68 c3 a4 10 80       	push   $0x8010a4c3
80103fc4:	e8 e0 c5 ff ff       	call   801005a9 <panic>

80103fc9 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
80103fcc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fcf:	e8 5d fa ff ff       	call   80103a31 <myproc>
80103fd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd7:	83 ec 0c             	sub    $0xc,%esp
80103fda:	68 00 42 19 80       	push   $0x80194200
80103fdf:	e8 6a 08 00 00       	call   8010484e <acquire>
80103fe4:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fee:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ff5:	e9 a1 00 00 00       	jmp    8010409b <wait+0xd2>
      if(p->parent != curproc)
80103ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffd:	8b 40 14             	mov    0x14(%eax),%eax
80104000:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104003:	0f 85 8d 00 00 00    	jne    80104096 <wait+0xcd>
        continue;
      havekids = 1;
80104009:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104013:	8b 40 0c             	mov    0xc(%eax),%eax
80104016:	83 f8 05             	cmp    $0x5,%eax
80104019:	75 7c                	jne    80104097 <wait+0xce>
        // Found one.
        pid = p->pid;
8010401b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401e:	8b 40 10             	mov    0x10(%eax),%eax
80104021:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	8b 40 08             	mov    0x8(%eax),%eax
8010402a:	83 ec 0c             	sub    $0xc,%esp
8010402d:	50                   	push   %eax
8010402e:	e8 d4 e6 ff ff       	call   80102707 <kfree>
80104033:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104043:	8b 40 04             	mov    0x4(%eax),%eax
80104046:	83 ec 0c             	sub    $0xc,%esp
80104049:	50                   	push   %eax
8010404a:	e8 11 3a 00 00       	call   80107a60 <freevm>
8010404f:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104055:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010405c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104069:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010406d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104070:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104081:	83 ec 0c             	sub    $0xc,%esp
80104084:	68 00 42 19 80       	push   $0x80194200
80104089:	e8 2e 08 00 00       	call   801048bc <release>
8010408e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104091:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104094:	eb 51                	jmp    801040e7 <wait+0x11e>
        continue;
80104096:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104097:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010409b:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801040a2:	0f 82 52 ff ff ff    	jb     80103ffa <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ac:	74 0a                	je     801040b8 <wait+0xef>
801040ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b1:	8b 40 24             	mov    0x24(%eax),%eax
801040b4:	85 c0                	test   %eax,%eax
801040b6:	74 17                	je     801040cf <wait+0x106>
      release(&ptable.lock);
801040b8:	83 ec 0c             	sub    $0xc,%esp
801040bb:	68 00 42 19 80       	push   $0x80194200
801040c0:	e8 f7 07 00 00       	call   801048bc <release>
801040c5:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cd:	eb 18                	jmp    801040e7 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040cf:	83 ec 08             	sub    $0x8,%esp
801040d2:	68 00 42 19 80       	push   $0x80194200
801040d7:	ff 75 ec             	push   -0x14(%ebp)
801040da:	e8 fb 01 00 00       	call   801042da <sleep>
801040df:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040e2:	e9 00 ff ff ff       	jmp    80103fe7 <wait+0x1e>
  }
}
801040e7:	c9                   	leave  
801040e8:	c3                   	ret    

801040e9 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e9:	55                   	push   %ebp
801040ea:	89 e5                	mov    %esp,%ebp
801040ec:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040ef:	e8 c5 f8 ff ff       	call   801039b9 <mycpu>
801040f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040fa:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104101:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104104:	e8 70 f8 ff ff       	call   80103979 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104109:	83 ec 0c             	sub    $0xc,%esp
8010410c:	68 00 42 19 80       	push   $0x80194200
80104111:	e8 38 07 00 00       	call   8010484e <acquire>
80104116:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104119:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104120:	eb 61                	jmp    80104183 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104125:	8b 40 0c             	mov    0xc(%eax),%eax
80104128:	83 f8 03             	cmp    $0x3,%eax
8010412b:	75 51                	jne    8010417e <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010412d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104130:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104133:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104139:	83 ec 0c             	sub    $0xc,%esp
8010413c:	ff 75 f4             	push   -0xc(%ebp)
8010413f:	e8 77 34 00 00       	call   801075bb <switchuvm>
80104144:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104154:	8b 40 1c             	mov    0x1c(%eax),%eax
80104157:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010415a:	83 c2 04             	add    $0x4,%edx
8010415d:	83 ec 08             	sub    $0x8,%esp
80104160:	50                   	push   %eax
80104161:	52                   	push   %edx
80104162:	e8 d2 0b 00 00       	call   80104d39 <swtch>
80104167:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010416a:	e8 33 34 00 00       	call   801075a2 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010416f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104172:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104179:	00 00 00 
8010417c:	eb 01                	jmp    8010417f <scheduler+0x96>
        continue;
8010417e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010417f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104183:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010418a:	72 96                	jb     80104122 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418c:	83 ec 0c             	sub    $0xc,%esp
8010418f:	68 00 42 19 80       	push   $0x80194200
80104194:	e8 23 07 00 00       	call   801048bc <release>
80104199:	83 c4 10             	add    $0x10,%esp
    sti();
8010419c:	e9 63 ff ff ff       	jmp    80104104 <scheduler+0x1b>

801041a1 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041a1:	55                   	push   %ebp
801041a2:	89 e5                	mov    %esp,%ebp
801041a4:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041a7:	e8 85 f8 ff ff       	call   80103a31 <myproc>
801041ac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041af:	83 ec 0c             	sub    $0xc,%esp
801041b2:	68 00 42 19 80       	push   $0x80194200
801041b7:	e8 cd 07 00 00       	call   80104989 <holding>
801041bc:	83 c4 10             	add    $0x10,%esp
801041bf:	85 c0                	test   %eax,%eax
801041c1:	75 0d                	jne    801041d0 <sched+0x2f>
    panic("sched ptable.lock");
801041c3:	83 ec 0c             	sub    $0xc,%esp
801041c6:	68 cf a4 10 80       	push   $0x8010a4cf
801041cb:	e8 d9 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041d0:	e8 e4 f7 ff ff       	call   801039b9 <mycpu>
801041d5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041db:	83 f8 01             	cmp    $0x1,%eax
801041de:	74 0d                	je     801041ed <sched+0x4c>
    panic("sched locks");
801041e0:	83 ec 0c             	sub    $0xc,%esp
801041e3:	68 e1 a4 10 80       	push   $0x8010a4e1
801041e8:	e8 bc c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f0:	8b 40 0c             	mov    0xc(%eax),%eax
801041f3:	83 f8 04             	cmp    $0x4,%eax
801041f6:	75 0d                	jne    80104205 <sched+0x64>
    panic("sched running");
801041f8:	83 ec 0c             	sub    $0xc,%esp
801041fb:	68 ed a4 10 80       	push   $0x8010a4ed
80104200:	e8 a4 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104205:	e8 5f f7 ff ff       	call   80103969 <readeflags>
8010420a:	25 00 02 00 00       	and    $0x200,%eax
8010420f:	85 c0                	test   %eax,%eax
80104211:	74 0d                	je     80104220 <sched+0x7f>
    panic("sched interruptible");
80104213:	83 ec 0c             	sub    $0xc,%esp
80104216:	68 fb a4 10 80       	push   $0x8010a4fb
8010421b:	e8 89 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104220:	e8 94 f7 ff ff       	call   801039b9 <mycpu>
80104225:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010422b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010422e:	e8 86 f7 ff ff       	call   801039b9 <mycpu>
80104233:	8b 40 04             	mov    0x4(%eax),%eax
80104236:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104239:	83 c2 1c             	add    $0x1c,%edx
8010423c:	83 ec 08             	sub    $0x8,%esp
8010423f:	50                   	push   %eax
80104240:	52                   	push   %edx
80104241:	e8 f3 0a 00 00       	call   80104d39 <swtch>
80104246:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104249:	e8 6b f7 ff ff       	call   801039b9 <mycpu>
8010424e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104251:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104257:	90                   	nop
80104258:	c9                   	leave  
80104259:	c3                   	ret    

8010425a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010425a:	55                   	push   %ebp
8010425b:	89 e5                	mov    %esp,%ebp
8010425d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104260:	83 ec 0c             	sub    $0xc,%esp
80104263:	68 00 42 19 80       	push   $0x80194200
80104268:	e8 e1 05 00 00       	call   8010484e <acquire>
8010426d:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104270:	e8 bc f7 ff ff       	call   80103a31 <myproc>
80104275:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010427c:	e8 20 ff ff ff       	call   801041a1 <sched>
  release(&ptable.lock);
80104281:	83 ec 0c             	sub    $0xc,%esp
80104284:	68 00 42 19 80       	push   $0x80194200
80104289:	e8 2e 06 00 00       	call   801048bc <release>
8010428e:	83 c4 10             	add    $0x10,%esp
}
80104291:	90                   	nop
80104292:	c9                   	leave  
80104293:	c3                   	ret    

80104294 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104294:	55                   	push   %ebp
80104295:	89 e5                	mov    %esp,%ebp
80104297:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010429a:	83 ec 0c             	sub    $0xc,%esp
8010429d:	68 00 42 19 80       	push   $0x80194200
801042a2:	e8 15 06 00 00       	call   801048bc <release>
801042a7:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042aa:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042af:	85 c0                	test   %eax,%eax
801042b1:	74 24                	je     801042d7 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042b3:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042ba:	00 00 00 
    iinit(ROOTDEV);
801042bd:	83 ec 0c             	sub    $0xc,%esp
801042c0:	6a 01                	push   $0x1
801042c2:	e8 b2 d3 ff ff       	call   80101679 <iinit>
801042c7:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042ca:	83 ec 0c             	sub    $0xc,%esp
801042cd:	6a 01                	push   $0x1
801042cf:	e8 4a eb ff ff       	call   80102e1e <initlog>
801042d4:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042d7:	90                   	nop
801042d8:	c9                   	leave  
801042d9:	c3                   	ret    

801042da <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042da:	55                   	push   %ebp
801042db:	89 e5                	mov    %esp,%ebp
801042dd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042e0:	e8 4c f7 ff ff       	call   80103a31 <myproc>
801042e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042ec:	75 0d                	jne    801042fb <sleep+0x21>
    panic("sleep");
801042ee:	83 ec 0c             	sub    $0xc,%esp
801042f1:	68 0f a5 10 80       	push   $0x8010a50f
801042f6:	e8 ae c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042ff:	75 0d                	jne    8010430e <sleep+0x34>
    panic("sleep without lk");
80104301:	83 ec 0c             	sub    $0xc,%esp
80104304:	68 15 a5 10 80       	push   $0x8010a515
80104309:	e8 9b c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010430e:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104315:	74 1e                	je     80104335 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	68 00 42 19 80       	push   $0x80194200
8010431f:	e8 2a 05 00 00       	call   8010484e <acquire>
80104324:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104327:	83 ec 0c             	sub    $0xc,%esp
8010432a:	ff 75 0c             	push   0xc(%ebp)
8010432d:	e8 8a 05 00 00       	call   801048bc <release>
80104332:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104338:	8b 55 08             	mov    0x8(%ebp),%edx
8010433b:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104348:	e8 54 fe ff ff       	call   801041a1 <sched>

  // Tidy up.
  p->chan = 0;
8010434d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104350:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104357:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010435e:	74 1e                	je     8010437e <sleep+0xa4>
    release(&ptable.lock);
80104360:	83 ec 0c             	sub    $0xc,%esp
80104363:	68 00 42 19 80       	push   $0x80194200
80104368:	e8 4f 05 00 00       	call   801048bc <release>
8010436d:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104370:	83 ec 0c             	sub    $0xc,%esp
80104373:	ff 75 0c             	push   0xc(%ebp)
80104376:	e8 d3 04 00 00       	call   8010484e <acquire>
8010437b:	83 c4 10             	add    $0x10,%esp
  }
}
8010437e:	90                   	nop
8010437f:	c9                   	leave  
80104380:	c3                   	ret    

80104381 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104381:	55                   	push   %ebp
80104382:	89 e5                	mov    %esp,%ebp
80104384:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104387:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010438e:	eb 24                	jmp    801043b4 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104390:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104393:	8b 40 0c             	mov    0xc(%eax),%eax
80104396:	83 f8 02             	cmp    $0x2,%eax
80104399:	75 15                	jne    801043b0 <wakeup1+0x2f>
8010439b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439e:	8b 40 20             	mov    0x20(%eax),%eax
801043a1:	39 45 08             	cmp    %eax,0x8(%ebp)
801043a4:	75 0a                	jne    801043b0 <wakeup1+0x2f>
      p->state = RUNNABLE;
801043a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b0:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043b4:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043bb:	72 d3                	jb     80104390 <wakeup1+0xf>
}
801043bd:	90                   	nop
801043be:	90                   	nop
801043bf:	c9                   	leave  
801043c0:	c3                   	ret    

801043c1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043c1:	55                   	push   %ebp
801043c2:	89 e5                	mov    %esp,%ebp
801043c4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043c7:	83 ec 0c             	sub    $0xc,%esp
801043ca:	68 00 42 19 80       	push   $0x80194200
801043cf:	e8 7a 04 00 00       	call   8010484e <acquire>
801043d4:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d7:	83 ec 0c             	sub    $0xc,%esp
801043da:	ff 75 08             	push   0x8(%ebp)
801043dd:	e8 9f ff ff ff       	call   80104381 <wakeup1>
801043e2:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043e5:	83 ec 0c             	sub    $0xc,%esp
801043e8:	68 00 42 19 80       	push   $0x80194200
801043ed:	e8 ca 04 00 00       	call   801048bc <release>
801043f2:	83 c4 10             	add    $0x10,%esp
}
801043f5:	90                   	nop
801043f6:	c9                   	leave  
801043f7:	c3                   	ret    

801043f8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f8:	55                   	push   %ebp
801043f9:	89 e5                	mov    %esp,%ebp
801043fb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043fe:	83 ec 0c             	sub    $0xc,%esp
80104401:	68 00 42 19 80       	push   $0x80194200
80104406:	e8 43 04 00 00       	call   8010484e <acquire>
8010440b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010440e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104415:	eb 45                	jmp    8010445c <kill+0x64>
    if(p->pid == pid){
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	8b 40 10             	mov    0x10(%eax),%eax
8010441d:	39 45 08             	cmp    %eax,0x8(%ebp)
80104420:	75 36                	jne    80104458 <kill+0x60>
      p->killed = 1;
80104422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104425:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442f:	8b 40 0c             	mov    0xc(%eax),%eax
80104432:	83 f8 02             	cmp    $0x2,%eax
80104435:	75 0a                	jne    80104441 <kill+0x49>
        p->state = RUNNABLE;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104441:	83 ec 0c             	sub    $0xc,%esp
80104444:	68 00 42 19 80       	push   $0x80194200
80104449:	e8 6e 04 00 00       	call   801048bc <release>
8010444e:	83 c4 10             	add    $0x10,%esp
      return 0;
80104451:	b8 00 00 00 00       	mov    $0x0,%eax
80104456:	eb 22                	jmp    8010447a <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104458:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010445c:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104463:	72 b2                	jb     80104417 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104465:	83 ec 0c             	sub    $0xc,%esp
80104468:	68 00 42 19 80       	push   $0x80194200
8010446d:	e8 4a 04 00 00       	call   801048bc <release>
80104472:	83 c4 10             	add    $0x10,%esp
  return -1;
80104475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010447a:	c9                   	leave  
8010447b:	c3                   	ret    

8010447c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010447c:	55                   	push   %ebp
8010447d:	89 e5                	mov    %esp,%ebp
8010447f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104482:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104489:	e9 d7 00 00 00       	jmp    80104565 <procdump+0xe9>
    if(p->state == UNUSED)
8010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104491:	8b 40 0c             	mov    0xc(%eax),%eax
80104494:	85 c0                	test   %eax,%eax
80104496:	0f 84 c4 00 00 00    	je     80104560 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010449c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449f:	8b 40 0c             	mov    0xc(%eax),%eax
801044a2:	83 f8 05             	cmp    $0x5,%eax
801044a5:	77 23                	ja     801044ca <procdump+0x4e>
801044a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044aa:	8b 40 0c             	mov    0xc(%eax),%eax
801044ad:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b4:	85 c0                	test   %eax,%eax
801044b6:	74 12                	je     801044ca <procdump+0x4e>
      state = states[p->state];
801044b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bb:	8b 40 0c             	mov    0xc(%eax),%eax
801044be:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c8:	eb 07                	jmp    801044d1 <procdump+0x55>
    else
      state = "???";
801044ca:	c7 45 ec 26 a5 10 80 	movl   $0x8010a526,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d4:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044da:	8b 40 10             	mov    0x10(%eax),%eax
801044dd:	52                   	push   %edx
801044de:	ff 75 ec             	push   -0x14(%ebp)
801044e1:	50                   	push   %eax
801044e2:	68 2a a5 10 80       	push   $0x8010a52a
801044e7:	e8 08 bf ff ff       	call   801003f4 <cprintf>
801044ec:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f2:	8b 40 0c             	mov    0xc(%eax),%eax
801044f5:	83 f8 02             	cmp    $0x2,%eax
801044f8:	75 54                	jne    8010454e <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104500:	8b 40 0c             	mov    0xc(%eax),%eax
80104503:	83 c0 08             	add    $0x8,%eax
80104506:	89 c2                	mov    %eax,%edx
80104508:	83 ec 08             	sub    $0x8,%esp
8010450b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010450e:	50                   	push   %eax
8010450f:	52                   	push   %edx
80104510:	e8 f9 03 00 00       	call   8010490e <getcallerpcs>
80104515:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104518:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010451f:	eb 1c                	jmp    8010453d <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104528:	83 ec 08             	sub    $0x8,%esp
8010452b:	50                   	push   %eax
8010452c:	68 33 a5 10 80       	push   $0x8010a533
80104531:	e8 be be ff ff       	call   801003f4 <cprintf>
80104536:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104539:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010453d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104541:	7f 0b                	jg     8010454e <procdump+0xd2>
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010454a:	85 c0                	test   %eax,%eax
8010454c:	75 d3                	jne    80104521 <procdump+0xa5>
    }
    cprintf("\n");
8010454e:	83 ec 0c             	sub    $0xc,%esp
80104551:	68 37 a5 10 80       	push   $0x8010a537
80104556:	e8 99 be ff ff       	call   801003f4 <cprintf>
8010455b:	83 c4 10             	add    $0x10,%esp
8010455e:	eb 01                	jmp    80104561 <procdump+0xe5>
      continue;
80104560:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104561:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104565:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
8010456c:	0f 82 1c ff ff ff    	jb     8010448e <procdump+0x12>
  }
}
80104572:	90                   	nop
80104573:	90                   	nop
80104574:	c9                   	leave  
80104575:	c3                   	ret    

80104576 <printpt>:

int
printpt(int pid)
{
80104576:	55                   	push   %ebp
80104577:	89 e5                	mov    %esp,%ebp
80104579:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = 0;
8010457c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t *pte;
  pde_t *pgdir;
  uint addr;

  acquire(&ptable.lock);
80104583:	83 ec 0c             	sub    $0xc,%esp
80104586:	68 00 42 19 80       	push   $0x80194200
8010458b:	e8 be 02 00 00       	call   8010484e <acquire>
80104590:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104593:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010459a:	eb 0f                	jmp    801045ab <printpt+0x35>
    if (p->pid == pid)
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	8b 40 10             	mov    0x10(%eax),%eax
801045a2:	39 45 08             	cmp    %eax,0x8(%ebp)
801045a5:	74 0f                	je     801045b6 <printpt+0x40>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801045a7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801045ab:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045b2:	72 e8                	jb     8010459c <printpt+0x26>
801045b4:	eb 01                	jmp    801045b7 <printpt+0x41>
      break;
801045b6:	90                   	nop
  }
  if (p == &ptable.proc[NPROC] || p->state == UNUSED) {
801045b7:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801045be:	74 0a                	je     801045ca <printpt+0x54>
801045c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c3:	8b 40 0c             	mov    0xc(%eax),%eax
801045c6:	85 c0                	test   %eax,%eax
801045c8:	75 1a                	jne    801045e4 <printpt+0x6e>
    release(&ptable.lock);
801045ca:	83 ec 0c             	sub    $0xc,%esp
801045cd:	68 00 42 19 80       	push   $0x80194200
801045d2:	e8 e5 02 00 00       	call   801048bc <release>
801045d7:	83 c4 10             	add    $0x10,%esp
    return -1;
801045da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045df:	e9 e9 00 00 00       	jmp    801046cd <printpt+0x157>
  }

  pgdir = p->pgdir;
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	8b 40 04             	mov    0x4(%eax),%eax
801045ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  release(&ptable.lock);
801045ed:	83 ec 0c             	sub    $0xc,%esp
801045f0:	68 00 42 19 80       	push   $0x80194200
801045f5:	e8 c2 02 00 00       	call   801048bc <release>
801045fa:	83 c4 10             	add    $0x10,%esp

  cprintf("START PAGE TABLE (pid %d)\n", pid);
801045fd:	83 ec 08             	sub    $0x8,%esp
80104600:	ff 75 08             	push   0x8(%ebp)
80104603:	68 39 a5 10 80       	push   $0x8010a539
80104608:	e8 e7 bd ff ff       	call   801003f4 <cprintf>
8010460d:	83 c4 10             	add    $0x10,%esp

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104610:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104617:	e9 91 00 00 00       	jmp    801046ad <printpt+0x137>
    pte = walkpgdir(pgdir, (void*)addr, 0);
8010461c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461f:	83 ec 04             	sub    $0x4,%esp
80104622:	6a 00                	push   $0x0
80104624:	50                   	push   %eax
80104625:	ff 75 ec             	push   -0x14(%ebp)
80104628:	e8 4b 2d 00 00       	call   80107378 <walkpgdir>
8010462d:	83 c4 10             	add    $0x10,%esp
80104630:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (!pte || !(*pte & PTE_P)) continue;
80104633:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104637:	74 6c                	je     801046a5 <printpt+0x12f>
80104639:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010463c:	8b 00                	mov    (%eax),%eax
8010463e:	83 e0 01             	and    $0x1,%eax
80104641:	85 c0                	test   %eax,%eax
80104643:	74 60                	je     801046a5 <printpt+0x12f>

    // 플래그 문자열 생성
    const char *access = (*pte & PTE_U) ? "U" : "K";
80104645:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104648:	8b 00                	mov    (%eax),%eax
8010464a:	83 e0 04             	and    $0x4,%eax
8010464d:	85 c0                	test   %eax,%eax
8010464f:	74 07                	je     80104658 <printpt+0xe2>
80104651:	b8 54 a5 10 80       	mov    $0x8010a554,%eax
80104656:	eb 05                	jmp    8010465d <printpt+0xe7>
80104658:	b8 56 a5 10 80       	mov    $0x8010a556,%eax
8010465d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    const char *write = (*pte & PTE_W) ? "W" : "-";
80104660:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104663:	8b 00                	mov    (%eax),%eax
80104665:	83 e0 02             	and    $0x2,%eax
80104668:	85 c0                	test   %eax,%eax
8010466a:	74 07                	je     80104673 <printpt+0xfd>
8010466c:	b8 58 a5 10 80       	mov    $0x8010a558,%eax
80104671:	eb 05                	jmp    80104678 <printpt+0x102>
80104673:	b8 5a a5 10 80       	mov    $0x8010a55a,%eax
80104678:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // 전체 문자열 조합 
    cprintf("%x P %s %s %x\n",
      addr >> 12,               // 가상 페이지 번호 (VA >> 12)
      access,                   // U or K
      write,                    // W or -
      PTE_ADDR(*pte) >> 12      // 물리 페이지 번호 (PA >> 12)
8010467b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010467e:	8b 00                	mov    (%eax),%eax
    cprintf("%x P %s %s %x\n",
80104680:	c1 e8 0c             	shr    $0xc,%eax
80104683:	89 c2                	mov    %eax,%edx
80104685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104688:	c1 e8 0c             	shr    $0xc,%eax
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	52                   	push   %edx
8010468f:	ff 75 e0             	push   -0x20(%ebp)
80104692:	ff 75 e4             	push   -0x1c(%ebp)
80104695:	50                   	push   %eax
80104696:	68 5c a5 10 80       	push   $0x8010a55c
8010469b:	e8 54 bd ff ff       	call   801003f4 <cprintf>
801046a0:	83 c4 20             	add    $0x20,%esp
801046a3:	eb 01                	jmp    801046a6 <printpt+0x130>
    if (!pte || !(*pte & PTE_P)) continue;
801046a5:	90                   	nop
  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
801046a6:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801046ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b0:	85 c0                	test   %eax,%eax
801046b2:	0f 89 64 ff ff ff    	jns    8010461c <printpt+0xa6>
    );
  }

  cprintf("END PAGE TABLE\n");
801046b8:	83 ec 0c             	sub    $0xc,%esp
801046bb:	68 6b a5 10 80       	push   $0x8010a56b
801046c0:	e8 2f bd ff ff       	call   801003f4 <cprintf>
801046c5:	83 c4 10             	add    $0x10,%esp
  return 0;
801046c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046cd:	c9                   	leave  
801046ce:	c3                   	ret    

801046cf <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046cf:	55                   	push   %ebp
801046d0:	89 e5                	mov    %esp,%ebp
801046d2:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046d5:	8b 45 08             	mov    0x8(%ebp),%eax
801046d8:	83 c0 04             	add    $0x4,%eax
801046db:	83 ec 08             	sub    $0x8,%esp
801046de:	68 a5 a5 10 80       	push   $0x8010a5a5
801046e3:	50                   	push   %eax
801046e4:	e8 43 01 00 00       	call   8010482c <initlock>
801046e9:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046ec:	8b 45 08             	mov    0x8(%ebp),%eax
801046ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801046f2:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046f5:	8b 45 08             	mov    0x8(%ebp),%eax
801046f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104701:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104708:	90                   	nop
80104709:	c9                   	leave  
8010470a:	c3                   	ret    

8010470b <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010470b:	55                   	push   %ebp
8010470c:	89 e5                	mov    %esp,%ebp
8010470e:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104711:	8b 45 08             	mov    0x8(%ebp),%eax
80104714:	83 c0 04             	add    $0x4,%eax
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	50                   	push   %eax
8010471b:	e8 2e 01 00 00       	call   8010484e <acquire>
80104720:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104723:	eb 15                	jmp    8010473a <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104725:	8b 45 08             	mov    0x8(%ebp),%eax
80104728:	83 c0 04             	add    $0x4,%eax
8010472b:	83 ec 08             	sub    $0x8,%esp
8010472e:	50                   	push   %eax
8010472f:	ff 75 08             	push   0x8(%ebp)
80104732:	e8 a3 fb ff ff       	call   801042da <sleep>
80104737:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010473a:	8b 45 08             	mov    0x8(%ebp),%eax
8010473d:	8b 00                	mov    (%eax),%eax
8010473f:	85 c0                	test   %eax,%eax
80104741:	75 e2                	jne    80104725 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104743:	8b 45 08             	mov    0x8(%ebp),%eax
80104746:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010474c:	e8 e0 f2 ff ff       	call   80103a31 <myproc>
80104751:	8b 50 10             	mov    0x10(%eax),%edx
80104754:	8b 45 08             	mov    0x8(%ebp),%eax
80104757:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010475a:	8b 45 08             	mov    0x8(%ebp),%eax
8010475d:	83 c0 04             	add    $0x4,%eax
80104760:	83 ec 0c             	sub    $0xc,%esp
80104763:	50                   	push   %eax
80104764:	e8 53 01 00 00       	call   801048bc <release>
80104769:	83 c4 10             	add    $0x10,%esp
}
8010476c:	90                   	nop
8010476d:	c9                   	leave  
8010476e:	c3                   	ret    

8010476f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010476f:	55                   	push   %ebp
80104770:	89 e5                	mov    %esp,%ebp
80104772:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104775:	8b 45 08             	mov    0x8(%ebp),%eax
80104778:	83 c0 04             	add    $0x4,%eax
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	50                   	push   %eax
8010477f:	e8 ca 00 00 00       	call   8010484e <acquire>
80104784:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104787:	8b 45 08             	mov    0x8(%ebp),%eax
8010478a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104790:	8b 45 08             	mov    0x8(%ebp),%eax
80104793:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010479a:	83 ec 0c             	sub    $0xc,%esp
8010479d:	ff 75 08             	push   0x8(%ebp)
801047a0:	e8 1c fc ff ff       	call   801043c1 <wakeup>
801047a5:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801047a8:	8b 45 08             	mov    0x8(%ebp),%eax
801047ab:	83 c0 04             	add    $0x4,%eax
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	50                   	push   %eax
801047b2:	e8 05 01 00 00       	call   801048bc <release>
801047b7:	83 c4 10             	add    $0x10,%esp
}
801047ba:	90                   	nop
801047bb:	c9                   	leave  
801047bc:	c3                   	ret    

801047bd <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047bd:	55                   	push   %ebp
801047be:	89 e5                	mov    %esp,%ebp
801047c0:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047c3:	8b 45 08             	mov    0x8(%ebp),%eax
801047c6:	83 c0 04             	add    $0x4,%eax
801047c9:	83 ec 0c             	sub    $0xc,%esp
801047cc:	50                   	push   %eax
801047cd:	e8 7c 00 00 00       	call   8010484e <acquire>
801047d2:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047d5:	8b 45 08             	mov    0x8(%ebp),%eax
801047d8:	8b 00                	mov    (%eax),%eax
801047da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047dd:	8b 45 08             	mov    0x8(%ebp),%eax
801047e0:	83 c0 04             	add    $0x4,%eax
801047e3:	83 ec 0c             	sub    $0xc,%esp
801047e6:	50                   	push   %eax
801047e7:	e8 d0 00 00 00       	call   801048bc <release>
801047ec:	83 c4 10             	add    $0x10,%esp
  return r;
801047ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047f2:	c9                   	leave  
801047f3:	c3                   	ret    

801047f4 <readeflags>:
{
801047f4:	55                   	push   %ebp
801047f5:	89 e5                	mov    %esp,%ebp
801047f7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047fa:	9c                   	pushf  
801047fb:	58                   	pop    %eax
801047fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104802:	c9                   	leave  
80104803:	c3                   	ret    

80104804 <cli>:
{
80104804:	55                   	push   %ebp
80104805:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104807:	fa                   	cli    
}
80104808:	90                   	nop
80104809:	5d                   	pop    %ebp
8010480a:	c3                   	ret    

8010480b <sti>:
{
8010480b:	55                   	push   %ebp
8010480c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010480e:	fb                   	sti    
}
8010480f:	90                   	nop
80104810:	5d                   	pop    %ebp
80104811:	c3                   	ret    

80104812 <xchg>:
{
80104812:	55                   	push   %ebp
80104813:	89 e5                	mov    %esp,%ebp
80104815:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104818:	8b 55 08             	mov    0x8(%ebp),%edx
8010481b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010481e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104821:	f0 87 02             	lock xchg %eax,(%edx)
80104824:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104827:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010482a:	c9                   	leave  
8010482b:	c3                   	ret    

8010482c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010482c:	55                   	push   %ebp
8010482d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010482f:	8b 45 08             	mov    0x8(%ebp),%eax
80104832:	8b 55 0c             	mov    0xc(%ebp),%edx
80104835:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104838:	8b 45 08             	mov    0x8(%ebp),%eax
8010483b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104841:	8b 45 08             	mov    0x8(%ebp),%eax
80104844:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010484b:	90                   	nop
8010484c:	5d                   	pop    %ebp
8010484d:	c3                   	ret    

8010484e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010484e:	55                   	push   %ebp
8010484f:	89 e5                	mov    %esp,%ebp
80104851:	53                   	push   %ebx
80104852:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104855:	e8 5f 01 00 00       	call   801049b9 <pushcli>
  if(holding(lk)){
8010485a:	8b 45 08             	mov    0x8(%ebp),%eax
8010485d:	83 ec 0c             	sub    $0xc,%esp
80104860:	50                   	push   %eax
80104861:	e8 23 01 00 00       	call   80104989 <holding>
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	85 c0                	test   %eax,%eax
8010486b:	74 0d                	je     8010487a <acquire+0x2c>
    panic("acquire");
8010486d:	83 ec 0c             	sub    $0xc,%esp
80104870:	68 b0 a5 10 80       	push   $0x8010a5b0
80104875:	e8 2f bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010487a:	90                   	nop
8010487b:	8b 45 08             	mov    0x8(%ebp),%eax
8010487e:	83 ec 08             	sub    $0x8,%esp
80104881:	6a 01                	push   $0x1
80104883:	50                   	push   %eax
80104884:	e8 89 ff ff ff       	call   80104812 <xchg>
80104889:	83 c4 10             	add    $0x10,%esp
8010488c:	85 c0                	test   %eax,%eax
8010488e:	75 eb                	jne    8010487b <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104890:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104895:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104898:	e8 1c f1 ff ff       	call   801039b9 <mycpu>
8010489d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801048a0:	8b 45 08             	mov    0x8(%ebp),%eax
801048a3:	83 c0 0c             	add    $0xc,%eax
801048a6:	83 ec 08             	sub    $0x8,%esp
801048a9:	50                   	push   %eax
801048aa:	8d 45 08             	lea    0x8(%ebp),%eax
801048ad:	50                   	push   %eax
801048ae:	e8 5b 00 00 00       	call   8010490e <getcallerpcs>
801048b3:	83 c4 10             	add    $0x10,%esp
}
801048b6:	90                   	nop
801048b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048ba:	c9                   	leave  
801048bb:	c3                   	ret    

801048bc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048bc:	55                   	push   %ebp
801048bd:	89 e5                	mov    %esp,%ebp
801048bf:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048c2:	83 ec 0c             	sub    $0xc,%esp
801048c5:	ff 75 08             	push   0x8(%ebp)
801048c8:	e8 bc 00 00 00       	call   80104989 <holding>
801048cd:	83 c4 10             	add    $0x10,%esp
801048d0:	85 c0                	test   %eax,%eax
801048d2:	75 0d                	jne    801048e1 <release+0x25>
    panic("release");
801048d4:	83 ec 0c             	sub    $0xc,%esp
801048d7:	68 b8 a5 10 80       	push   $0x8010a5b8
801048dc:	e8 c8 bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048e1:	8b 45 08             	mov    0x8(%ebp),%eax
801048e4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048eb:	8b 45 08             	mov    0x8(%ebp),%eax
801048ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048f5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048fa:	8b 45 08             	mov    0x8(%ebp),%eax
801048fd:	8b 55 08             	mov    0x8(%ebp),%edx
80104900:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104906:	e8 fb 00 00 00       	call   80104a06 <popcli>
}
8010490b:	90                   	nop
8010490c:	c9                   	leave  
8010490d:	c3                   	ret    

8010490e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010490e:	55                   	push   %ebp
8010490f:	89 e5                	mov    %esp,%ebp
80104911:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104914:	8b 45 08             	mov    0x8(%ebp),%eax
80104917:	83 e8 08             	sub    $0x8,%eax
8010491a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010491d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104924:	eb 38                	jmp    8010495e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104926:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010492a:	74 53                	je     8010497f <getcallerpcs+0x71>
8010492c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104933:	76 4a                	jbe    8010497f <getcallerpcs+0x71>
80104935:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104939:	74 44                	je     8010497f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010493b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010493e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104945:	8b 45 0c             	mov    0xc(%ebp),%eax
80104948:	01 c2                	add    %eax,%edx
8010494a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010494d:	8b 40 04             	mov    0x4(%eax),%eax
80104950:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104952:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104955:	8b 00                	mov    (%eax),%eax
80104957:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010495a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010495e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104962:	7e c2                	jle    80104926 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104964:	eb 19                	jmp    8010497f <getcallerpcs+0x71>
    pcs[i] = 0;
80104966:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104969:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104970:	8b 45 0c             	mov    0xc(%ebp),%eax
80104973:	01 d0                	add    %edx,%eax
80104975:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010497b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010497f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104983:	7e e1                	jle    80104966 <getcallerpcs+0x58>
}
80104985:	90                   	nop
80104986:	90                   	nop
80104987:	c9                   	leave  
80104988:	c3                   	ret    

80104989 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104989:	55                   	push   %ebp
8010498a:	89 e5                	mov    %esp,%ebp
8010498c:	53                   	push   %ebx
8010498d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104990:	8b 45 08             	mov    0x8(%ebp),%eax
80104993:	8b 00                	mov    (%eax),%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	74 16                	je     801049af <holding+0x26>
80104999:	8b 45 08             	mov    0x8(%ebp),%eax
8010499c:	8b 58 08             	mov    0x8(%eax),%ebx
8010499f:	e8 15 f0 ff ff       	call   801039b9 <mycpu>
801049a4:	39 c3                	cmp    %eax,%ebx
801049a6:	75 07                	jne    801049af <holding+0x26>
801049a8:	b8 01 00 00 00       	mov    $0x1,%eax
801049ad:	eb 05                	jmp    801049b4 <holding+0x2b>
801049af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049b7:	c9                   	leave  
801049b8:	c3                   	ret    

801049b9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049b9:	55                   	push   %ebp
801049ba:	89 e5                	mov    %esp,%ebp
801049bc:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049bf:	e8 30 fe ff ff       	call   801047f4 <readeflags>
801049c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049c7:	e8 38 fe ff ff       	call   80104804 <cli>
  if(mycpu()->ncli == 0)
801049cc:	e8 e8 ef ff ff       	call   801039b9 <mycpu>
801049d1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049d7:	85 c0                	test   %eax,%eax
801049d9:	75 14                	jne    801049ef <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049db:	e8 d9 ef ff ff       	call   801039b9 <mycpu>
801049e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049e3:	81 e2 00 02 00 00    	and    $0x200,%edx
801049e9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049ef:	e8 c5 ef ff ff       	call   801039b9 <mycpu>
801049f4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049fa:	83 c2 01             	add    $0x1,%edx
801049fd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a03:	90                   	nop
80104a04:	c9                   	leave  
80104a05:	c3                   	ret    

80104a06 <popcli>:

void
popcli(void)
{
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a0c:	e8 e3 fd ff ff       	call   801047f4 <readeflags>
80104a11:	25 00 02 00 00       	and    $0x200,%eax
80104a16:	85 c0                	test   %eax,%eax
80104a18:	74 0d                	je     80104a27 <popcli+0x21>
    panic("popcli - interruptible");
80104a1a:	83 ec 0c             	sub    $0xc,%esp
80104a1d:	68 c0 a5 10 80       	push   $0x8010a5c0
80104a22:	e8 82 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a27:	e8 8d ef ff ff       	call   801039b9 <mycpu>
80104a2c:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a32:	83 ea 01             	sub    $0x1,%edx
80104a35:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a3b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a41:	85 c0                	test   %eax,%eax
80104a43:	79 0d                	jns    80104a52 <popcli+0x4c>
    panic("popcli");
80104a45:	83 ec 0c             	sub    $0xc,%esp
80104a48:	68 d7 a5 10 80       	push   $0x8010a5d7
80104a4d:	e8 57 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a52:	e8 62 ef ff ff       	call   801039b9 <mycpu>
80104a57:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a5d:	85 c0                	test   %eax,%eax
80104a5f:	75 14                	jne    80104a75 <popcli+0x6f>
80104a61:	e8 53 ef ff ff       	call   801039b9 <mycpu>
80104a66:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a6c:	85 c0                	test   %eax,%eax
80104a6e:	74 05                	je     80104a75 <popcli+0x6f>
    sti();
80104a70:	e8 96 fd ff ff       	call   8010480b <sti>
}
80104a75:	90                   	nop
80104a76:	c9                   	leave  
80104a77:	c3                   	ret    

80104a78 <stosb>:
{
80104a78:	55                   	push   %ebp
80104a79:	89 e5                	mov    %esp,%ebp
80104a7b:	57                   	push   %edi
80104a7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a80:	8b 55 10             	mov    0x10(%ebp),%edx
80104a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a86:	89 cb                	mov    %ecx,%ebx
80104a88:	89 df                	mov    %ebx,%edi
80104a8a:	89 d1                	mov    %edx,%ecx
80104a8c:	fc                   	cld    
80104a8d:	f3 aa                	rep stos %al,%es:(%edi)
80104a8f:	89 ca                	mov    %ecx,%edx
80104a91:	89 fb                	mov    %edi,%ebx
80104a93:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a96:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a99:	90                   	nop
80104a9a:	5b                   	pop    %ebx
80104a9b:	5f                   	pop    %edi
80104a9c:	5d                   	pop    %ebp
80104a9d:	c3                   	ret    

80104a9e <stosl>:
{
80104a9e:	55                   	push   %ebp
80104a9f:	89 e5                	mov    %esp,%ebp
80104aa1:	57                   	push   %edi
80104aa2:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104aa6:	8b 55 10             	mov    0x10(%ebp),%edx
80104aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aac:	89 cb                	mov    %ecx,%ebx
80104aae:	89 df                	mov    %ebx,%edi
80104ab0:	89 d1                	mov    %edx,%ecx
80104ab2:	fc                   	cld    
80104ab3:	f3 ab                	rep stos %eax,%es:(%edi)
80104ab5:	89 ca                	mov    %ecx,%edx
80104ab7:	89 fb                	mov    %edi,%ebx
80104ab9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104abc:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104abf:	90                   	nop
80104ac0:	5b                   	pop    %ebx
80104ac1:	5f                   	pop    %edi
80104ac2:	5d                   	pop    %ebp
80104ac3:	c3                   	ret    

80104ac4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ac4:	55                   	push   %ebp
80104ac5:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80104aca:	83 e0 03             	and    $0x3,%eax
80104acd:	85 c0                	test   %eax,%eax
80104acf:	75 43                	jne    80104b14 <memset+0x50>
80104ad1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ad4:	83 e0 03             	and    $0x3,%eax
80104ad7:	85 c0                	test   %eax,%eax
80104ad9:	75 39                	jne    80104b14 <memset+0x50>
    c &= 0xFF;
80104adb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ae2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ae5:	c1 e8 02             	shr    $0x2,%eax
80104ae8:	89 c2                	mov    %eax,%edx
80104aea:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aed:	c1 e0 18             	shl    $0x18,%eax
80104af0:	89 c1                	mov    %eax,%ecx
80104af2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af5:	c1 e0 10             	shl    $0x10,%eax
80104af8:	09 c1                	or     %eax,%ecx
80104afa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afd:	c1 e0 08             	shl    $0x8,%eax
80104b00:	09 c8                	or     %ecx,%eax
80104b02:	0b 45 0c             	or     0xc(%ebp),%eax
80104b05:	52                   	push   %edx
80104b06:	50                   	push   %eax
80104b07:	ff 75 08             	push   0x8(%ebp)
80104b0a:	e8 8f ff ff ff       	call   80104a9e <stosl>
80104b0f:	83 c4 0c             	add    $0xc,%esp
80104b12:	eb 12                	jmp    80104b26 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b14:	8b 45 10             	mov    0x10(%ebp),%eax
80104b17:	50                   	push   %eax
80104b18:	ff 75 0c             	push   0xc(%ebp)
80104b1b:	ff 75 08             	push   0x8(%ebp)
80104b1e:	e8 55 ff ff ff       	call   80104a78 <stosb>
80104b23:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b26:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b29:	c9                   	leave  
80104b2a:	c3                   	ret    

80104b2b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b2b:	55                   	push   %ebp
80104b2c:	89 e5                	mov    %esp,%ebp
80104b2e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b31:	8b 45 08             	mov    0x8(%ebp),%eax
80104b34:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b3a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b3d:	eb 30                	jmp    80104b6f <memcmp+0x44>
    if(*s1 != *s2)
80104b3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b42:	0f b6 10             	movzbl (%eax),%edx
80104b45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b48:	0f b6 00             	movzbl (%eax),%eax
80104b4b:	38 c2                	cmp    %al,%dl
80104b4d:	74 18                	je     80104b67 <memcmp+0x3c>
      return *s1 - *s2;
80104b4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b52:	0f b6 00             	movzbl (%eax),%eax
80104b55:	0f b6 d0             	movzbl %al,%edx
80104b58:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b5b:	0f b6 00             	movzbl (%eax),%eax
80104b5e:	0f b6 c8             	movzbl %al,%ecx
80104b61:	89 d0                	mov    %edx,%eax
80104b63:	29 c8                	sub    %ecx,%eax
80104b65:	eb 1a                	jmp    80104b81 <memcmp+0x56>
    s1++, s2++;
80104b67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b6b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104b72:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b75:	89 55 10             	mov    %edx,0x10(%ebp)
80104b78:	85 c0                	test   %eax,%eax
80104b7a:	75 c3                	jne    80104b3f <memcmp+0x14>
  }

  return 0;
80104b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b81:	c9                   	leave  
80104b82:	c3                   	ret    

80104b83 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b83:	55                   	push   %ebp
80104b84:	89 e5                	mov    %esp,%ebp
80104b86:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b92:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b98:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b9b:	73 54                	jae    80104bf1 <memmove+0x6e>
80104b9d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ba0:	8b 45 10             	mov    0x10(%ebp),%eax
80104ba3:	01 d0                	add    %edx,%eax
80104ba5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104ba8:	73 47                	jae    80104bf1 <memmove+0x6e>
    s += n;
80104baa:	8b 45 10             	mov    0x10(%ebp),%eax
80104bad:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104bb0:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb3:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104bb6:	eb 13                	jmp    80104bcb <memmove+0x48>
      *--d = *--s;
80104bb8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104bbc:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bc3:	0f b6 10             	movzbl (%eax),%edx
80104bc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bc9:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bcb:	8b 45 10             	mov    0x10(%ebp),%eax
80104bce:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bd1:	89 55 10             	mov    %edx,0x10(%ebp)
80104bd4:	85 c0                	test   %eax,%eax
80104bd6:	75 e0                	jne    80104bb8 <memmove+0x35>
  if(s < d && s + n > d){
80104bd8:	eb 24                	jmp    80104bfe <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104bda:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bdd:	8d 42 01             	lea    0x1(%edx),%eax
80104be0:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104be3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104be6:	8d 48 01             	lea    0x1(%eax),%ecx
80104be9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bec:	0f b6 12             	movzbl (%edx),%edx
80104bef:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bf1:	8b 45 10             	mov    0x10(%ebp),%eax
80104bf4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bf7:	89 55 10             	mov    %edx,0x10(%ebp)
80104bfa:	85 c0                	test   %eax,%eax
80104bfc:	75 dc                	jne    80104bda <memmove+0x57>

  return dst;
80104bfe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c01:	c9                   	leave  
80104c02:	c3                   	ret    

80104c03 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c03:	55                   	push   %ebp
80104c04:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c06:	ff 75 10             	push   0x10(%ebp)
80104c09:	ff 75 0c             	push   0xc(%ebp)
80104c0c:	ff 75 08             	push   0x8(%ebp)
80104c0f:	e8 6f ff ff ff       	call   80104b83 <memmove>
80104c14:	83 c4 0c             	add    $0xc,%esp
}
80104c17:	c9                   	leave  
80104c18:	c3                   	ret    

80104c19 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c19:	55                   	push   %ebp
80104c1a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c1c:	eb 0c                	jmp    80104c2a <strncmp+0x11>
    n--, p++, q++;
80104c1e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c26:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c2e:	74 1a                	je     80104c4a <strncmp+0x31>
80104c30:	8b 45 08             	mov    0x8(%ebp),%eax
80104c33:	0f b6 00             	movzbl (%eax),%eax
80104c36:	84 c0                	test   %al,%al
80104c38:	74 10                	je     80104c4a <strncmp+0x31>
80104c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3d:	0f b6 10             	movzbl (%eax),%edx
80104c40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c43:	0f b6 00             	movzbl (%eax),%eax
80104c46:	38 c2                	cmp    %al,%dl
80104c48:	74 d4                	je     80104c1e <strncmp+0x5>
  if(n == 0)
80104c4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c4e:	75 07                	jne    80104c57 <strncmp+0x3e>
    return 0;
80104c50:	b8 00 00 00 00       	mov    $0x0,%eax
80104c55:	eb 16                	jmp    80104c6d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c57:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5a:	0f b6 00             	movzbl (%eax),%eax
80104c5d:	0f b6 d0             	movzbl %al,%edx
80104c60:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c63:	0f b6 00             	movzbl (%eax),%eax
80104c66:	0f b6 c8             	movzbl %al,%ecx
80104c69:	89 d0                	mov    %edx,%eax
80104c6b:	29 c8                	sub    %ecx,%eax
}
80104c6d:	5d                   	pop    %ebp
80104c6e:	c3                   	ret    

80104c6f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c6f:	55                   	push   %ebp
80104c70:	89 e5                	mov    %esp,%ebp
80104c72:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c7b:	90                   	nop
80104c7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104c7f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c82:	89 55 10             	mov    %edx,0x10(%ebp)
80104c85:	85 c0                	test   %eax,%eax
80104c87:	7e 2c                	jle    80104cb5 <strncpy+0x46>
80104c89:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c8c:	8d 42 01             	lea    0x1(%edx),%eax
80104c8f:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c92:	8b 45 08             	mov    0x8(%ebp),%eax
80104c95:	8d 48 01             	lea    0x1(%eax),%ecx
80104c98:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c9b:	0f b6 12             	movzbl (%edx),%edx
80104c9e:	88 10                	mov    %dl,(%eax)
80104ca0:	0f b6 00             	movzbl (%eax),%eax
80104ca3:	84 c0                	test   %al,%al
80104ca5:	75 d5                	jne    80104c7c <strncpy+0xd>
    ;
  while(n-- > 0)
80104ca7:	eb 0c                	jmp    80104cb5 <strncpy+0x46>
    *s++ = 0;
80104ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cac:	8d 50 01             	lea    0x1(%eax),%edx
80104caf:	89 55 08             	mov    %edx,0x8(%ebp)
80104cb2:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104cb5:	8b 45 10             	mov    0x10(%ebp),%eax
80104cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cbb:	89 55 10             	mov    %edx,0x10(%ebp)
80104cbe:	85 c0                	test   %eax,%eax
80104cc0:	7f e7                	jg     80104ca9 <strncpy+0x3a>
  return os;
80104cc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cc5:	c9                   	leave  
80104cc6:	c3                   	ret    

80104cc7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
80104cca:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104cd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cd7:	7f 05                	jg     80104cde <safestrcpy+0x17>
    return os;
80104cd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cdc:	eb 32                	jmp    80104d10 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cde:	90                   	nop
80104cdf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ce3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ce7:	7e 1e                	jle    80104d07 <safestrcpy+0x40>
80104ce9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cec:	8d 42 01             	lea    0x1(%edx),%eax
80104cef:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf5:	8d 48 01             	lea    0x1(%eax),%ecx
80104cf8:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cfb:	0f b6 12             	movzbl (%edx),%edx
80104cfe:	88 10                	mov    %dl,(%eax)
80104d00:	0f b6 00             	movzbl (%eax),%eax
80104d03:	84 c0                	test   %al,%al
80104d05:	75 d8                	jne    80104cdf <safestrcpy+0x18>
    ;
  *s = 0;
80104d07:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0a:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d10:	c9                   	leave  
80104d11:	c3                   	ret    

80104d12 <strlen>:

int
strlen(const char *s)
{
80104d12:	55                   	push   %ebp
80104d13:	89 e5                	mov    %esp,%ebp
80104d15:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d1f:	eb 04                	jmp    80104d25 <strlen+0x13>
80104d21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d25:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d28:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2b:	01 d0                	add    %edx,%eax
80104d2d:	0f b6 00             	movzbl (%eax),%eax
80104d30:	84 c0                	test   %al,%al
80104d32:	75 ed                	jne    80104d21 <strlen+0xf>
    ;
  return n;
80104d34:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d37:	c9                   	leave  
80104d38:	c3                   	ret    

80104d39 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d39:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d3d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d41:	55                   	push   %ebp
  pushl %ebx
80104d42:	53                   	push   %ebx
  pushl %esi
80104d43:	56                   	push   %esi
  pushl %edi
80104d44:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d45:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d47:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d49:	5f                   	pop    %edi
  popl %esi
80104d4a:	5e                   	pop    %esi
  popl %ebx
80104d4b:	5b                   	pop    %ebx
  popl %ebp
80104d4c:	5d                   	pop    %ebp
  ret
80104d4d:	c3                   	ret    

80104d4e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d4e:	55                   	push   %ebp
80104d4f:	89 e5                	mov    %esp,%ebp
  //커널 영역 침범 방지
  if(addr >=KERNBASE || addr+4 > KERNBASE)
80104d51:	8b 45 08             	mov    0x8(%ebp),%eax
80104d54:	85 c0                	test   %eax,%eax
80104d56:	78 0d                	js     80104d65 <fetchint+0x17>
80104d58:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5b:	83 c0 04             	add    $0x4,%eax
80104d5e:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104d63:	76 07                	jbe    80104d6c <fetchint+0x1e>
    return -1;
80104d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6a:	eb 0f                	jmp    80104d7b <fetchint+0x2d>
  
  *ip = *(int*)(addr);
80104d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d6f:	8b 10                	mov    (%eax),%edx
80104d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d74:	89 10                	mov    %edx,(%eax)
  return 0;
80104d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d7b:	5d                   	pop    %ebp
80104d7c:	c3                   	ret    

80104d7d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d7d:	55                   	push   %ebp
80104d7e:	89 e5                	mov    %esp,%ebp
80104d80:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  // 잘못된 접근 방지
  if(addr >=KERNBASE)
80104d83:	8b 45 08             	mov    0x8(%ebp),%eax
80104d86:	85 c0                	test   %eax,%eax
80104d88:	79 07                	jns    80104d91 <fetchstr+0x14>
    return -1;
80104d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8f:	eb 40                	jmp    80104dd1 <fetchstr+0x54>

  *pp = (char*)addr;
80104d91:	8b 55 08             	mov    0x8(%ebp),%edx
80104d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d97:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE; //상한선은 가상 메모리 한계로 설정
80104d99:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da3:	8b 00                	mov    (%eax),%eax
80104da5:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104da8:	eb 1a                	jmp    80104dc4 <fetchstr+0x47>
    if(*s == 0)
80104daa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dad:	0f b6 00             	movzbl (%eax),%eax
80104db0:	84 c0                	test   %al,%al
80104db2:	75 0c                	jne    80104dc0 <fetchstr+0x43>
      return s - *pp;
80104db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db7:	8b 10                	mov    (%eax),%edx
80104db9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbc:	29 d0                	sub    %edx,%eax
80104dbe:	eb 11                	jmp    80104dd1 <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104dc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104dc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dc7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104dca:	72 de                	jb     80104daa <fetchstr+0x2d>
  }
  return -1;
80104dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dd1:	c9                   	leave  
80104dd2:	c3                   	ret    

80104dd3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104dd3:	55                   	push   %ebp
80104dd4:	89 e5                	mov    %esp,%ebp
80104dd6:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104dd9:	e8 53 ec ff ff       	call   80103a31 <myproc>
80104dde:	8b 40 18             	mov    0x18(%eax),%eax
80104de1:	8b 50 44             	mov    0x44(%eax),%edx
80104de4:	8b 45 08             	mov    0x8(%ebp),%eax
80104de7:	c1 e0 02             	shl    $0x2,%eax
80104dea:	01 d0                	add    %edx,%eax
80104dec:	83 c0 04             	add    $0x4,%eax
80104def:	83 ec 08             	sub    $0x8,%esp
80104df2:	ff 75 0c             	push   0xc(%ebp)
80104df5:	50                   	push   %eax
80104df6:	e8 53 ff ff ff       	call   80104d4e <fetchint>
80104dfb:	83 c4 10             	add    $0x10,%esp
}
80104dfe:	c9                   	leave  
80104dff:	c3                   	ret    

80104e00 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104e06:	83 ec 08             	sub    $0x8,%esp
80104e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e0c:	50                   	push   %eax
80104e0d:	ff 75 08             	push   0x8(%ebp)
80104e10:	e8 be ff ff ff       	call   80104dd3 <argint>
80104e15:	83 c4 10             	add    $0x10,%esp
80104e18:	85 c0                	test   %eax,%eax
80104e1a:	79 07                	jns    80104e23 <argptr+0x23>
    return -1;
80104e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e21:	eb 34                	jmp    80104e57 <argptr+0x57>
    
  //size만큼 공간 확보 + 커널 영역 접근 방지
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104e23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e27:	78 18                	js     80104e41 <argptr+0x41>
80104e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2c:	85 c0                	test   %eax,%eax
80104e2e:	78 11                	js     80104e41 <argptr+0x41>
80104e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e33:	89 c2                	mov    %eax,%edx
80104e35:	8b 45 10             	mov    0x10(%ebp),%eax
80104e38:	01 d0                	add    %edx,%eax
80104e3a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104e3f:	76 07                	jbe    80104e48 <argptr+0x48>
    return -1;
80104e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e46:	eb 0f                	jmp    80104e57 <argptr+0x57>
  *pp = (char*)i;
80104e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4b:	89 c2                	mov    %eax,%edx
80104e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e50:	89 10                	mov    %edx,(%eax)
  return 0;
80104e52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e57:	c9                   	leave  
80104e58:	c3                   	ret    

80104e59 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e59:	55                   	push   %ebp
80104e5a:	89 e5                	mov    %esp,%ebp
80104e5c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e5f:	83 ec 08             	sub    $0x8,%esp
80104e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e65:	50                   	push   %eax
80104e66:	ff 75 08             	push   0x8(%ebp)
80104e69:	e8 65 ff ff ff       	call   80104dd3 <argint>
80104e6e:	83 c4 10             	add    $0x10,%esp
80104e71:	85 c0                	test   %eax,%eax
80104e73:	79 07                	jns    80104e7c <argstr+0x23>
    return -1;
80104e75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e7a:	eb 12                	jmp    80104e8e <argstr+0x35>
  return fetchstr(addr, pp);
80104e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7f:	83 ec 08             	sub    $0x8,%esp
80104e82:	ff 75 0c             	push   0xc(%ebp)
80104e85:	50                   	push   %eax
80104e86:	e8 f2 fe ff ff       	call   80104d7d <fetchstr>
80104e8b:	83 c4 10             	add    $0x10,%esp
}
80104e8e:	c9                   	leave  
80104e8f:	c3                   	ret    

80104e90 <syscall>:

};

void
syscall(void)
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e96:	e8 96 eb ff ff       	call   80103a31 <myproc>
80104e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea1:	8b 40 18             	mov    0x18(%eax),%eax
80104ea4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ea7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104eaa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104eae:	7e 2f                	jle    80104edf <syscall+0x4f>
80104eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb3:	83 f8 16             	cmp    $0x16,%eax
80104eb6:	77 27                	ja     80104edf <syscall+0x4f>
80104eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebb:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ec2:	85 c0                	test   %eax,%eax
80104ec4:	74 19                	je     80104edf <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ed0:	ff d0                	call   *%eax
80104ed2:	89 c2                	mov    %eax,%edx
80104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed7:	8b 40 18             	mov    0x18(%eax),%eax
80104eda:	89 50 1c             	mov    %edx,0x1c(%eax)
80104edd:	eb 2c                	jmp    80104f0b <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee2:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee8:	8b 40 10             	mov    0x10(%eax),%eax
80104eeb:	ff 75 f0             	push   -0x10(%ebp)
80104eee:	52                   	push   %edx
80104eef:	50                   	push   %eax
80104ef0:	68 de a5 10 80       	push   $0x8010a5de
80104ef5:	e8 fa b4 ff ff       	call   801003f4 <cprintf>
80104efa:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f00:	8b 40 18             	mov    0x18(%eax),%eax
80104f03:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104f0a:	90                   	nop
80104f0b:	90                   	nop
80104f0c:	c9                   	leave  
80104f0d:	c3                   	ret    

80104f0e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f0e:	55                   	push   %ebp
80104f0f:	89 e5                	mov    %esp,%ebp
80104f11:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f14:	83 ec 08             	sub    $0x8,%esp
80104f17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f1a:	50                   	push   %eax
80104f1b:	ff 75 08             	push   0x8(%ebp)
80104f1e:	e8 b0 fe ff ff       	call   80104dd3 <argint>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	85 c0                	test   %eax,%eax
80104f28:	79 07                	jns    80104f31 <argfd+0x23>
    return -1;
80104f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2f:	eb 4f                	jmp    80104f80 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f34:	85 c0                	test   %eax,%eax
80104f36:	78 20                	js     80104f58 <argfd+0x4a>
80104f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3b:	83 f8 0f             	cmp    $0xf,%eax
80104f3e:	7f 18                	jg     80104f58 <argfd+0x4a>
80104f40:	e8 ec ea ff ff       	call   80103a31 <myproc>
80104f45:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f48:	83 c2 08             	add    $0x8,%edx
80104f4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f56:	75 07                	jne    80104f5f <argfd+0x51>
    return -1;
80104f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f5d:	eb 21                	jmp    80104f80 <argfd+0x72>
  if(pfd)
80104f5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f63:	74 08                	je     80104f6d <argfd+0x5f>
    *pfd = fd;
80104f65:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f68:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6b:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f71:	74 08                	je     80104f7b <argfd+0x6d>
    *pf = f;
80104f73:	8b 45 10             	mov    0x10(%ebp),%eax
80104f76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f79:	89 10                	mov    %edx,(%eax)
  return 0;
80104f7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f80:	c9                   	leave  
80104f81:	c3                   	ret    

80104f82 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f82:	55                   	push   %ebp
80104f83:	89 e5                	mov    %esp,%ebp
80104f85:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f88:	e8 a4 ea ff ff       	call   80103a31 <myproc>
80104f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f97:	eb 2a                	jmp    80104fc3 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f9f:	83 c2 08             	add    $0x8,%edx
80104fa2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fa6:	85 c0                	test   %eax,%eax
80104fa8:	75 15                	jne    80104fbf <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fb0:	8d 4a 08             	lea    0x8(%edx),%ecx
80104fb3:	8b 55 08             	mov    0x8(%ebp),%edx
80104fb6:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbd:	eb 0f                	jmp    80104fce <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104fbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fc3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104fc7:	7e d0                	jle    80104f99 <fdalloc+0x17>
    }
  }
  return -1;
80104fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fce:	c9                   	leave  
80104fcf:	c3                   	ret    

80104fd0 <sys_dup>:

int
sys_dup(void)
{
80104fd0:	55                   	push   %ebp
80104fd1:	89 e5                	mov    %esp,%ebp
80104fd3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104fd6:	83 ec 04             	sub    $0x4,%esp
80104fd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fdc:	50                   	push   %eax
80104fdd:	6a 00                	push   $0x0
80104fdf:	6a 00                	push   $0x0
80104fe1:	e8 28 ff ff ff       	call   80104f0e <argfd>
80104fe6:	83 c4 10             	add    $0x10,%esp
80104fe9:	85 c0                	test   %eax,%eax
80104feb:	79 07                	jns    80104ff4 <sys_dup+0x24>
    return -1;
80104fed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff2:	eb 31                	jmp    80105025 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff7:	83 ec 0c             	sub    $0xc,%esp
80104ffa:	50                   	push   %eax
80104ffb:	e8 82 ff ff ff       	call   80104f82 <fdalloc>
80105000:	83 c4 10             	add    $0x10,%esp
80105003:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105006:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010500a:	79 07                	jns    80105013 <sys_dup+0x43>
    return -1;
8010500c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105011:	eb 12                	jmp    80105025 <sys_dup+0x55>
  filedup(f);
80105013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105016:	83 ec 0c             	sub    $0xc,%esp
80105019:	50                   	push   %eax
8010501a:	e8 2c c0 ff ff       	call   8010104b <filedup>
8010501f:	83 c4 10             	add    $0x10,%esp
  return fd;
80105022:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105025:	c9                   	leave  
80105026:	c3                   	ret    

80105027 <sys_read>:

int
sys_read(void)
{
80105027:	55                   	push   %ebp
80105028:	89 e5                	mov    %esp,%ebp
8010502a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010502d:	83 ec 04             	sub    $0x4,%esp
80105030:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105033:	50                   	push   %eax
80105034:	6a 00                	push   $0x0
80105036:	6a 00                	push   $0x0
80105038:	e8 d1 fe ff ff       	call   80104f0e <argfd>
8010503d:	83 c4 10             	add    $0x10,%esp
80105040:	85 c0                	test   %eax,%eax
80105042:	78 2e                	js     80105072 <sys_read+0x4b>
80105044:	83 ec 08             	sub    $0x8,%esp
80105047:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010504a:	50                   	push   %eax
8010504b:	6a 02                	push   $0x2
8010504d:	e8 81 fd ff ff       	call   80104dd3 <argint>
80105052:	83 c4 10             	add    $0x10,%esp
80105055:	85 c0                	test   %eax,%eax
80105057:	78 19                	js     80105072 <sys_read+0x4b>
80105059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505c:	83 ec 04             	sub    $0x4,%esp
8010505f:	50                   	push   %eax
80105060:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105063:	50                   	push   %eax
80105064:	6a 01                	push   $0x1
80105066:	e8 95 fd ff ff       	call   80104e00 <argptr>
8010506b:	83 c4 10             	add    $0x10,%esp
8010506e:	85 c0                	test   %eax,%eax
80105070:	79 07                	jns    80105079 <sys_read+0x52>
    return -1;
80105072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105077:	eb 17                	jmp    80105090 <sys_read+0x69>
  return fileread(f, p, n);
80105079:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010507c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	83 ec 04             	sub    $0x4,%esp
80105085:	51                   	push   %ecx
80105086:	52                   	push   %edx
80105087:	50                   	push   %eax
80105088:	e8 4e c1 ff ff       	call   801011db <fileread>
8010508d:	83 c4 10             	add    $0x10,%esp
}
80105090:	c9                   	leave  
80105091:	c3                   	ret    

80105092 <sys_write>:

int
sys_write(void)
{
80105092:	55                   	push   %ebp
80105093:	89 e5                	mov    %esp,%ebp
80105095:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105098:	83 ec 04             	sub    $0x4,%esp
8010509b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010509e:	50                   	push   %eax
8010509f:	6a 00                	push   $0x0
801050a1:	6a 00                	push   $0x0
801050a3:	e8 66 fe ff ff       	call   80104f0e <argfd>
801050a8:	83 c4 10             	add    $0x10,%esp
801050ab:	85 c0                	test   %eax,%eax
801050ad:	78 2e                	js     801050dd <sys_write+0x4b>
801050af:	83 ec 08             	sub    $0x8,%esp
801050b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050b5:	50                   	push   %eax
801050b6:	6a 02                	push   $0x2
801050b8:	e8 16 fd ff ff       	call   80104dd3 <argint>
801050bd:	83 c4 10             	add    $0x10,%esp
801050c0:	85 c0                	test   %eax,%eax
801050c2:	78 19                	js     801050dd <sys_write+0x4b>
801050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c7:	83 ec 04             	sub    $0x4,%esp
801050ca:	50                   	push   %eax
801050cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050ce:	50                   	push   %eax
801050cf:	6a 01                	push   $0x1
801050d1:	e8 2a fd ff ff       	call   80104e00 <argptr>
801050d6:	83 c4 10             	add    $0x10,%esp
801050d9:	85 c0                	test   %eax,%eax
801050db:	79 07                	jns    801050e4 <sys_write+0x52>
    return -1;
801050dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e2:	eb 17                	jmp    801050fb <sys_write+0x69>
  return filewrite(f, p, n);
801050e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ed:	83 ec 04             	sub    $0x4,%esp
801050f0:	51                   	push   %ecx
801050f1:	52                   	push   %edx
801050f2:	50                   	push   %eax
801050f3:	e8 9b c1 ff ff       	call   80101293 <filewrite>
801050f8:	83 c4 10             	add    $0x10,%esp
}
801050fb:	c9                   	leave  
801050fc:	c3                   	ret    

801050fd <sys_close>:

int
sys_close(void)
{
801050fd:	55                   	push   %ebp
801050fe:	89 e5                	mov    %esp,%ebp
80105100:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105103:	83 ec 04             	sub    $0x4,%esp
80105106:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105109:	50                   	push   %eax
8010510a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010510d:	50                   	push   %eax
8010510e:	6a 00                	push   $0x0
80105110:	e8 f9 fd ff ff       	call   80104f0e <argfd>
80105115:	83 c4 10             	add    $0x10,%esp
80105118:	85 c0                	test   %eax,%eax
8010511a:	79 07                	jns    80105123 <sys_close+0x26>
    return -1;
8010511c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105121:	eb 27                	jmp    8010514a <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105123:	e8 09 e9 ff ff       	call   80103a31 <myproc>
80105128:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010512b:	83 c2 08             	add    $0x8,%edx
8010512e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105135:	00 
  fileclose(f);
80105136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105139:	83 ec 0c             	sub    $0xc,%esp
8010513c:	50                   	push   %eax
8010513d:	e8 5a bf ff ff       	call   8010109c <fileclose>
80105142:	83 c4 10             	add    $0x10,%esp
  return 0;
80105145:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010514a:	c9                   	leave  
8010514b:	c3                   	ret    

8010514c <sys_fstat>:

int
sys_fstat(void)
{
8010514c:	55                   	push   %ebp
8010514d:	89 e5                	mov    %esp,%ebp
8010514f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105152:	83 ec 04             	sub    $0x4,%esp
80105155:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105158:	50                   	push   %eax
80105159:	6a 00                	push   $0x0
8010515b:	6a 00                	push   $0x0
8010515d:	e8 ac fd ff ff       	call   80104f0e <argfd>
80105162:	83 c4 10             	add    $0x10,%esp
80105165:	85 c0                	test   %eax,%eax
80105167:	78 17                	js     80105180 <sys_fstat+0x34>
80105169:	83 ec 04             	sub    $0x4,%esp
8010516c:	6a 14                	push   $0x14
8010516e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105171:	50                   	push   %eax
80105172:	6a 01                	push   $0x1
80105174:	e8 87 fc ff ff       	call   80104e00 <argptr>
80105179:	83 c4 10             	add    $0x10,%esp
8010517c:	85 c0                	test   %eax,%eax
8010517e:	79 07                	jns    80105187 <sys_fstat+0x3b>
    return -1;
80105180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105185:	eb 13                	jmp    8010519a <sys_fstat+0x4e>
  return filestat(f, st);
80105187:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	83 ec 08             	sub    $0x8,%esp
80105190:	52                   	push   %edx
80105191:	50                   	push   %eax
80105192:	e8 ed bf ff ff       	call   80101184 <filestat>
80105197:	83 c4 10             	add    $0x10,%esp
}
8010519a:	c9                   	leave  
8010519b:	c3                   	ret    

8010519c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010519c:	55                   	push   %ebp
8010519d:	89 e5                	mov    %esp,%ebp
8010519f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801051a2:	83 ec 08             	sub    $0x8,%esp
801051a5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801051a8:	50                   	push   %eax
801051a9:	6a 00                	push   $0x0
801051ab:	e8 a9 fc ff ff       	call   80104e59 <argstr>
801051b0:	83 c4 10             	add    $0x10,%esp
801051b3:	85 c0                	test   %eax,%eax
801051b5:	78 15                	js     801051cc <sys_link+0x30>
801051b7:	83 ec 08             	sub    $0x8,%esp
801051ba:	8d 45 dc             	lea    -0x24(%ebp),%eax
801051bd:	50                   	push   %eax
801051be:	6a 01                	push   $0x1
801051c0:	e8 94 fc ff ff       	call   80104e59 <argstr>
801051c5:	83 c4 10             	add    $0x10,%esp
801051c8:	85 c0                	test   %eax,%eax
801051ca:	79 0a                	jns    801051d6 <sys_link+0x3a>
    return -1;
801051cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d1:	e9 68 01 00 00       	jmp    8010533e <sys_link+0x1a2>

  begin_op();
801051d6:	e8 62 de ff ff       	call   8010303d <begin_op>
  if((ip = namei(old)) == 0){
801051db:	8b 45 d8             	mov    -0x28(%ebp),%eax
801051de:	83 ec 0c             	sub    $0xc,%esp
801051e1:	50                   	push   %eax
801051e2:	e8 37 d3 ff ff       	call   8010251e <namei>
801051e7:	83 c4 10             	add    $0x10,%esp
801051ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051f1:	75 0f                	jne    80105202 <sys_link+0x66>
    end_op();
801051f3:	e8 d1 de ff ff       	call   801030c9 <end_op>
    return -1;
801051f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051fd:	e9 3c 01 00 00       	jmp    8010533e <sys_link+0x1a2>
  }

  ilock(ip);
80105202:	83 ec 0c             	sub    $0xc,%esp
80105205:	ff 75 f4             	push   -0xc(%ebp)
80105208:	e8 de c7 ff ff       	call   801019eb <ilock>
8010520d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105217:	66 83 f8 01          	cmp    $0x1,%ax
8010521b:	75 1d                	jne    8010523a <sys_link+0x9e>
    iunlockput(ip);
8010521d:	83 ec 0c             	sub    $0xc,%esp
80105220:	ff 75 f4             	push   -0xc(%ebp)
80105223:	e8 f4 c9 ff ff       	call   80101c1c <iunlockput>
80105228:	83 c4 10             	add    $0x10,%esp
    end_op();
8010522b:	e8 99 de ff ff       	call   801030c9 <end_op>
    return -1;
80105230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105235:	e9 04 01 00 00       	jmp    8010533e <sys_link+0x1a2>
  }

  ip->nlink++;
8010523a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105241:	83 c0 01             	add    $0x1,%eax
80105244:	89 c2                	mov    %eax,%edx
80105246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105249:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010524d:	83 ec 0c             	sub    $0xc,%esp
80105250:	ff 75 f4             	push   -0xc(%ebp)
80105253:	e8 b6 c5 ff ff       	call   8010180e <iupdate>
80105258:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	ff 75 f4             	push   -0xc(%ebp)
80105261:	e8 98 c8 ff ff       	call   80101afe <iunlock>
80105266:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105269:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010526c:	83 ec 08             	sub    $0x8,%esp
8010526f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105272:	52                   	push   %edx
80105273:	50                   	push   %eax
80105274:	e8 c1 d2 ff ff       	call   8010253a <nameiparent>
80105279:	83 c4 10             	add    $0x10,%esp
8010527c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010527f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105283:	74 71                	je     801052f6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105285:	83 ec 0c             	sub    $0xc,%esp
80105288:	ff 75 f0             	push   -0x10(%ebp)
8010528b:	e8 5b c7 ff ff       	call   801019eb <ilock>
80105290:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105293:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105296:	8b 10                	mov    (%eax),%edx
80105298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529b:	8b 00                	mov    (%eax),%eax
8010529d:	39 c2                	cmp    %eax,%edx
8010529f:	75 1d                	jne    801052be <sys_link+0x122>
801052a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a4:	8b 40 04             	mov    0x4(%eax),%eax
801052a7:	83 ec 04             	sub    $0x4,%esp
801052aa:	50                   	push   %eax
801052ab:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052ae:	50                   	push   %eax
801052af:	ff 75 f0             	push   -0x10(%ebp)
801052b2:	e8 d0 cf ff ff       	call   80102287 <dirlink>
801052b7:	83 c4 10             	add    $0x10,%esp
801052ba:	85 c0                	test   %eax,%eax
801052bc:	79 10                	jns    801052ce <sys_link+0x132>
    iunlockput(dp);
801052be:	83 ec 0c             	sub    $0xc,%esp
801052c1:	ff 75 f0             	push   -0x10(%ebp)
801052c4:	e8 53 c9 ff ff       	call   80101c1c <iunlockput>
801052c9:	83 c4 10             	add    $0x10,%esp
    goto bad;
801052cc:	eb 29                	jmp    801052f7 <sys_link+0x15b>
  }
  iunlockput(dp);
801052ce:	83 ec 0c             	sub    $0xc,%esp
801052d1:	ff 75 f0             	push   -0x10(%ebp)
801052d4:	e8 43 c9 ff ff       	call   80101c1c <iunlockput>
801052d9:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801052dc:	83 ec 0c             	sub    $0xc,%esp
801052df:	ff 75 f4             	push   -0xc(%ebp)
801052e2:	e8 65 c8 ff ff       	call   80101b4c <iput>
801052e7:	83 c4 10             	add    $0x10,%esp

  end_op();
801052ea:	e8 da dd ff ff       	call   801030c9 <end_op>

  return 0;
801052ef:	b8 00 00 00 00       	mov    $0x0,%eax
801052f4:	eb 48                	jmp    8010533e <sys_link+0x1a2>
    goto bad;
801052f6:	90                   	nop

bad:
  ilock(ip);
801052f7:	83 ec 0c             	sub    $0xc,%esp
801052fa:	ff 75 f4             	push   -0xc(%ebp)
801052fd:	e8 e9 c6 ff ff       	call   801019eb <ilock>
80105302:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105308:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010530c:	83 e8 01             	sub    $0x1,%eax
8010530f:	89 c2                	mov    %eax,%edx
80105311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105314:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105318:	83 ec 0c             	sub    $0xc,%esp
8010531b:	ff 75 f4             	push   -0xc(%ebp)
8010531e:	e8 eb c4 ff ff       	call   8010180e <iupdate>
80105323:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105326:	83 ec 0c             	sub    $0xc,%esp
80105329:	ff 75 f4             	push   -0xc(%ebp)
8010532c:	e8 eb c8 ff ff       	call   80101c1c <iunlockput>
80105331:	83 c4 10             	add    $0x10,%esp
  end_op();
80105334:	e8 90 dd ff ff       	call   801030c9 <end_op>
  return -1;
80105339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010533e:	c9                   	leave  
8010533f:	c3                   	ret    

80105340 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105346:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010534d:	eb 40                	jmp    8010538f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010534f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105352:	6a 10                	push   $0x10
80105354:	50                   	push   %eax
80105355:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105358:	50                   	push   %eax
80105359:	ff 75 08             	push   0x8(%ebp)
8010535c:	e8 76 cb ff ff       	call   80101ed7 <readi>
80105361:	83 c4 10             	add    $0x10,%esp
80105364:	83 f8 10             	cmp    $0x10,%eax
80105367:	74 0d                	je     80105376 <isdirempty+0x36>
      panic("isdirempty: readi");
80105369:	83 ec 0c             	sub    $0xc,%esp
8010536c:	68 fa a5 10 80       	push   $0x8010a5fa
80105371:	e8 33 b2 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105376:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010537a:	66 85 c0             	test   %ax,%ax
8010537d:	74 07                	je     80105386 <isdirempty+0x46>
      return 0;
8010537f:	b8 00 00 00 00       	mov    $0x0,%eax
80105384:	eb 1b                	jmp    801053a1 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105389:	83 c0 10             	add    $0x10,%eax
8010538c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010538f:	8b 45 08             	mov    0x8(%ebp),%eax
80105392:	8b 50 58             	mov    0x58(%eax),%edx
80105395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105398:	39 c2                	cmp    %eax,%edx
8010539a:	77 b3                	ja     8010534f <isdirempty+0xf>
  }
  return 1;
8010539c:	b8 01 00 00 00       	mov    $0x1,%eax
}
801053a1:	c9                   	leave  
801053a2:	c3                   	ret    

801053a3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801053a3:	55                   	push   %ebp
801053a4:	89 e5                	mov    %esp,%ebp
801053a6:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801053a9:	83 ec 08             	sub    $0x8,%esp
801053ac:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053af:	50                   	push   %eax
801053b0:	6a 00                	push   $0x0
801053b2:	e8 a2 fa ff ff       	call   80104e59 <argstr>
801053b7:	83 c4 10             	add    $0x10,%esp
801053ba:	85 c0                	test   %eax,%eax
801053bc:	79 0a                	jns    801053c8 <sys_unlink+0x25>
    return -1;
801053be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053c3:	e9 bf 01 00 00       	jmp    80105587 <sys_unlink+0x1e4>

  begin_op();
801053c8:	e8 70 dc ff ff       	call   8010303d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801053cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
801053d0:	83 ec 08             	sub    $0x8,%esp
801053d3:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801053d6:	52                   	push   %edx
801053d7:	50                   	push   %eax
801053d8:	e8 5d d1 ff ff       	call   8010253a <nameiparent>
801053dd:	83 c4 10             	add    $0x10,%esp
801053e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053e7:	75 0f                	jne    801053f8 <sys_unlink+0x55>
    end_op();
801053e9:	e8 db dc ff ff       	call   801030c9 <end_op>
    return -1;
801053ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f3:	e9 8f 01 00 00       	jmp    80105587 <sys_unlink+0x1e4>
  }

  ilock(dp);
801053f8:	83 ec 0c             	sub    $0xc,%esp
801053fb:	ff 75 f4             	push   -0xc(%ebp)
801053fe:	e8 e8 c5 ff ff       	call   801019eb <ilock>
80105403:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105406:	83 ec 08             	sub    $0x8,%esp
80105409:	68 0c a6 10 80       	push   $0x8010a60c
8010540e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105411:	50                   	push   %eax
80105412:	e8 9b cd ff ff       	call   801021b2 <namecmp>
80105417:	83 c4 10             	add    $0x10,%esp
8010541a:	85 c0                	test   %eax,%eax
8010541c:	0f 84 49 01 00 00    	je     8010556b <sys_unlink+0x1c8>
80105422:	83 ec 08             	sub    $0x8,%esp
80105425:	68 0e a6 10 80       	push   $0x8010a60e
8010542a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010542d:	50                   	push   %eax
8010542e:	e8 7f cd ff ff       	call   801021b2 <namecmp>
80105433:	83 c4 10             	add    $0x10,%esp
80105436:	85 c0                	test   %eax,%eax
80105438:	0f 84 2d 01 00 00    	je     8010556b <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010543e:	83 ec 04             	sub    $0x4,%esp
80105441:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105444:	50                   	push   %eax
80105445:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105448:	50                   	push   %eax
80105449:	ff 75 f4             	push   -0xc(%ebp)
8010544c:	e8 7c cd ff ff       	call   801021cd <dirlookup>
80105451:	83 c4 10             	add    $0x10,%esp
80105454:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105457:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010545b:	0f 84 0d 01 00 00    	je     8010556e <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105461:	83 ec 0c             	sub    $0xc,%esp
80105464:	ff 75 f0             	push   -0x10(%ebp)
80105467:	e8 7f c5 ff ff       	call   801019eb <ilock>
8010546c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010546f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105472:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105476:	66 85 c0             	test   %ax,%ax
80105479:	7f 0d                	jg     80105488 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010547b:	83 ec 0c             	sub    $0xc,%esp
8010547e:	68 11 a6 10 80       	push   $0x8010a611
80105483:	e8 21 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010548b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010548f:	66 83 f8 01          	cmp    $0x1,%ax
80105493:	75 25                	jne    801054ba <sys_unlink+0x117>
80105495:	83 ec 0c             	sub    $0xc,%esp
80105498:	ff 75 f0             	push   -0x10(%ebp)
8010549b:	e8 a0 fe ff ff       	call   80105340 <isdirempty>
801054a0:	83 c4 10             	add    $0x10,%esp
801054a3:	85 c0                	test   %eax,%eax
801054a5:	75 13                	jne    801054ba <sys_unlink+0x117>
    iunlockput(ip);
801054a7:	83 ec 0c             	sub    $0xc,%esp
801054aa:	ff 75 f0             	push   -0x10(%ebp)
801054ad:	e8 6a c7 ff ff       	call   80101c1c <iunlockput>
801054b2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801054b5:	e9 b5 00 00 00       	jmp    8010556f <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801054ba:	83 ec 04             	sub    $0x4,%esp
801054bd:	6a 10                	push   $0x10
801054bf:	6a 00                	push   $0x0
801054c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054c4:	50                   	push   %eax
801054c5:	e8 fa f5 ff ff       	call   80104ac4 <memset>
801054ca:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801054d0:	6a 10                	push   $0x10
801054d2:	50                   	push   %eax
801054d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054d6:	50                   	push   %eax
801054d7:	ff 75 f4             	push   -0xc(%ebp)
801054da:	e8 4d cb ff ff       	call   8010202c <writei>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	83 f8 10             	cmp    $0x10,%eax
801054e5:	74 0d                	je     801054f4 <sys_unlink+0x151>
    panic("unlink: writei");
801054e7:	83 ec 0c             	sub    $0xc,%esp
801054ea:	68 23 a6 10 80       	push   $0x8010a623
801054ef:	e8 b5 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801054f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054fb:	66 83 f8 01          	cmp    $0x1,%ax
801054ff:	75 21                	jne    80105522 <sys_unlink+0x17f>
    dp->nlink--;
80105501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105504:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105508:	83 e8 01             	sub    $0x1,%eax
8010550b:	89 c2                	mov    %eax,%edx
8010550d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105510:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105514:	83 ec 0c             	sub    $0xc,%esp
80105517:	ff 75 f4             	push   -0xc(%ebp)
8010551a:	e8 ef c2 ff ff       	call   8010180e <iupdate>
8010551f:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105522:	83 ec 0c             	sub    $0xc,%esp
80105525:	ff 75 f4             	push   -0xc(%ebp)
80105528:	e8 ef c6 ff ff       	call   80101c1c <iunlockput>
8010552d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105533:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105537:	83 e8 01             	sub    $0x1,%eax
8010553a:	89 c2                	mov    %eax,%edx
8010553c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010553f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105543:	83 ec 0c             	sub    $0xc,%esp
80105546:	ff 75 f0             	push   -0x10(%ebp)
80105549:	e8 c0 c2 ff ff       	call   8010180e <iupdate>
8010554e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	ff 75 f0             	push   -0x10(%ebp)
80105557:	e8 c0 c6 ff ff       	call   80101c1c <iunlockput>
8010555c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010555f:	e8 65 db ff ff       	call   801030c9 <end_op>

  return 0;
80105564:	b8 00 00 00 00       	mov    $0x0,%eax
80105569:	eb 1c                	jmp    80105587 <sys_unlink+0x1e4>
    goto bad;
8010556b:	90                   	nop
8010556c:	eb 01                	jmp    8010556f <sys_unlink+0x1cc>
    goto bad;
8010556e:	90                   	nop

bad:
  iunlockput(dp);
8010556f:	83 ec 0c             	sub    $0xc,%esp
80105572:	ff 75 f4             	push   -0xc(%ebp)
80105575:	e8 a2 c6 ff ff       	call   80101c1c <iunlockput>
8010557a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010557d:	e8 47 db ff ff       	call   801030c9 <end_op>
  return -1;
80105582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105587:	c9                   	leave  
80105588:	c3                   	ret    

80105589 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105589:	55                   	push   %ebp
8010558a:	89 e5                	mov    %esp,%ebp
8010558c:	83 ec 38             	sub    $0x38,%esp
8010558f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105592:	8b 55 10             	mov    0x10(%ebp),%edx
80105595:	8b 45 14             	mov    0x14(%ebp),%eax
80105598:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010559c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801055a0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801055a4:	83 ec 08             	sub    $0x8,%esp
801055a7:	8d 45 de             	lea    -0x22(%ebp),%eax
801055aa:	50                   	push   %eax
801055ab:	ff 75 08             	push   0x8(%ebp)
801055ae:	e8 87 cf ff ff       	call   8010253a <nameiparent>
801055b3:	83 c4 10             	add    $0x10,%esp
801055b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055bd:	75 0a                	jne    801055c9 <create+0x40>
    return 0;
801055bf:	b8 00 00 00 00       	mov    $0x0,%eax
801055c4:	e9 90 01 00 00       	jmp    80105759 <create+0x1d0>
  ilock(dp);
801055c9:	83 ec 0c             	sub    $0xc,%esp
801055cc:	ff 75 f4             	push   -0xc(%ebp)
801055cf:	e8 17 c4 ff ff       	call   801019eb <ilock>
801055d4:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801055d7:	83 ec 04             	sub    $0x4,%esp
801055da:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055dd:	50                   	push   %eax
801055de:	8d 45 de             	lea    -0x22(%ebp),%eax
801055e1:	50                   	push   %eax
801055e2:	ff 75 f4             	push   -0xc(%ebp)
801055e5:	e8 e3 cb ff ff       	call   801021cd <dirlookup>
801055ea:	83 c4 10             	add    $0x10,%esp
801055ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055f4:	74 50                	je     80105646 <create+0xbd>
    iunlockput(dp);
801055f6:	83 ec 0c             	sub    $0xc,%esp
801055f9:	ff 75 f4             	push   -0xc(%ebp)
801055fc:	e8 1b c6 ff ff       	call   80101c1c <iunlockput>
80105601:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105604:	83 ec 0c             	sub    $0xc,%esp
80105607:	ff 75 f0             	push   -0x10(%ebp)
8010560a:	e8 dc c3 ff ff       	call   801019eb <ilock>
8010560f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105612:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105617:	75 15                	jne    8010562e <create+0xa5>
80105619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105620:	66 83 f8 02          	cmp    $0x2,%ax
80105624:	75 08                	jne    8010562e <create+0xa5>
      return ip;
80105626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105629:	e9 2b 01 00 00       	jmp    80105759 <create+0x1d0>
    iunlockput(ip);
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	ff 75 f0             	push   -0x10(%ebp)
80105634:	e8 e3 c5 ff ff       	call   80101c1c <iunlockput>
80105639:	83 c4 10             	add    $0x10,%esp
    return 0;
8010563c:	b8 00 00 00 00       	mov    $0x0,%eax
80105641:	e9 13 01 00 00       	jmp    80105759 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105646:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010564a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564d:	8b 00                	mov    (%eax),%eax
8010564f:	83 ec 08             	sub    $0x8,%esp
80105652:	52                   	push   %edx
80105653:	50                   	push   %eax
80105654:	e8 de c0 ff ff       	call   80101737 <ialloc>
80105659:	83 c4 10             	add    $0x10,%esp
8010565c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010565f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105663:	75 0d                	jne    80105672 <create+0xe9>
    panic("create: ialloc");
80105665:	83 ec 0c             	sub    $0xc,%esp
80105668:	68 32 a6 10 80       	push   $0x8010a632
8010566d:	e8 37 af ff ff       	call   801005a9 <panic>

  ilock(ip);
80105672:	83 ec 0c             	sub    $0xc,%esp
80105675:	ff 75 f0             	push   -0x10(%ebp)
80105678:	e8 6e c3 ff ff       	call   801019eb <ilock>
8010567d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105683:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105687:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010568b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105692:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105699:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010569f:	83 ec 0c             	sub    $0xc,%esp
801056a2:	ff 75 f0             	push   -0x10(%ebp)
801056a5:	e8 64 c1 ff ff       	call   8010180e <iupdate>
801056aa:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056ad:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056b2:	75 6a                	jne    8010571e <create+0x195>
    dp->nlink++;  // for ".."
801056b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056bb:	83 c0 01             	add    $0x1,%eax
801056be:	89 c2                	mov    %eax,%edx
801056c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801056c7:	83 ec 0c             	sub    $0xc,%esp
801056ca:	ff 75 f4             	push   -0xc(%ebp)
801056cd:	e8 3c c1 ff ff       	call   8010180e <iupdate>
801056d2:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	8b 40 04             	mov    0x4(%eax),%eax
801056db:	83 ec 04             	sub    $0x4,%esp
801056de:	50                   	push   %eax
801056df:	68 0c a6 10 80       	push   $0x8010a60c
801056e4:	ff 75 f0             	push   -0x10(%ebp)
801056e7:	e8 9b cb ff ff       	call   80102287 <dirlink>
801056ec:	83 c4 10             	add    $0x10,%esp
801056ef:	85 c0                	test   %eax,%eax
801056f1:	78 1e                	js     80105711 <create+0x188>
801056f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f6:	8b 40 04             	mov    0x4(%eax),%eax
801056f9:	83 ec 04             	sub    $0x4,%esp
801056fc:	50                   	push   %eax
801056fd:	68 0e a6 10 80       	push   $0x8010a60e
80105702:	ff 75 f0             	push   -0x10(%ebp)
80105705:	e8 7d cb ff ff       	call   80102287 <dirlink>
8010570a:	83 c4 10             	add    $0x10,%esp
8010570d:	85 c0                	test   %eax,%eax
8010570f:	79 0d                	jns    8010571e <create+0x195>
      panic("create dots");
80105711:	83 ec 0c             	sub    $0xc,%esp
80105714:	68 41 a6 10 80       	push   $0x8010a641
80105719:	e8 8b ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010571e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105721:	8b 40 04             	mov    0x4(%eax),%eax
80105724:	83 ec 04             	sub    $0x4,%esp
80105727:	50                   	push   %eax
80105728:	8d 45 de             	lea    -0x22(%ebp),%eax
8010572b:	50                   	push   %eax
8010572c:	ff 75 f4             	push   -0xc(%ebp)
8010572f:	e8 53 cb ff ff       	call   80102287 <dirlink>
80105734:	83 c4 10             	add    $0x10,%esp
80105737:	85 c0                	test   %eax,%eax
80105739:	79 0d                	jns    80105748 <create+0x1bf>
    panic("create: dirlink");
8010573b:	83 ec 0c             	sub    $0xc,%esp
8010573e:	68 4d a6 10 80       	push   $0x8010a64d
80105743:	e8 61 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	ff 75 f4             	push   -0xc(%ebp)
8010574e:	e8 c9 c4 ff ff       	call   80101c1c <iunlockput>
80105753:	83 c4 10             	add    $0x10,%esp

  return ip;
80105756:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105759:	c9                   	leave  
8010575a:	c3                   	ret    

8010575b <sys_open>:

int
sys_open(void)
{
8010575b:	55                   	push   %ebp
8010575c:	89 e5                	mov    %esp,%ebp
8010575e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105761:	83 ec 08             	sub    $0x8,%esp
80105764:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105767:	50                   	push   %eax
80105768:	6a 00                	push   $0x0
8010576a:	e8 ea f6 ff ff       	call   80104e59 <argstr>
8010576f:	83 c4 10             	add    $0x10,%esp
80105772:	85 c0                	test   %eax,%eax
80105774:	78 15                	js     8010578b <sys_open+0x30>
80105776:	83 ec 08             	sub    $0x8,%esp
80105779:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010577c:	50                   	push   %eax
8010577d:	6a 01                	push   $0x1
8010577f:	e8 4f f6 ff ff       	call   80104dd3 <argint>
80105784:	83 c4 10             	add    $0x10,%esp
80105787:	85 c0                	test   %eax,%eax
80105789:	79 0a                	jns    80105795 <sys_open+0x3a>
    return -1;
8010578b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105790:	e9 61 01 00 00       	jmp    801058f6 <sys_open+0x19b>

  begin_op();
80105795:	e8 a3 d8 ff ff       	call   8010303d <begin_op>

  if(omode & O_CREATE){
8010579a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010579d:	25 00 02 00 00       	and    $0x200,%eax
801057a2:	85 c0                	test   %eax,%eax
801057a4:	74 2a                	je     801057d0 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801057a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057a9:	6a 00                	push   $0x0
801057ab:	6a 00                	push   $0x0
801057ad:	6a 02                	push   $0x2
801057af:	50                   	push   %eax
801057b0:	e8 d4 fd ff ff       	call   80105589 <create>
801057b5:	83 c4 10             	add    $0x10,%esp
801057b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801057bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057bf:	75 75                	jne    80105836 <sys_open+0xdb>
      end_op();
801057c1:	e8 03 d9 ff ff       	call   801030c9 <end_op>
      return -1;
801057c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cb:	e9 26 01 00 00       	jmp    801058f6 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801057d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057d3:	83 ec 0c             	sub    $0xc,%esp
801057d6:	50                   	push   %eax
801057d7:	e8 42 cd ff ff       	call   8010251e <namei>
801057dc:	83 c4 10             	add    $0x10,%esp
801057df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057e6:	75 0f                	jne    801057f7 <sys_open+0x9c>
      end_op();
801057e8:	e8 dc d8 ff ff       	call   801030c9 <end_op>
      return -1;
801057ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f2:	e9 ff 00 00 00       	jmp    801058f6 <sys_open+0x19b>
    }
    ilock(ip);
801057f7:	83 ec 0c             	sub    $0xc,%esp
801057fa:	ff 75 f4             	push   -0xc(%ebp)
801057fd:	e8 e9 c1 ff ff       	call   801019eb <ilock>
80105802:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105808:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010580c:	66 83 f8 01          	cmp    $0x1,%ax
80105810:	75 24                	jne    80105836 <sys_open+0xdb>
80105812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105815:	85 c0                	test   %eax,%eax
80105817:	74 1d                	je     80105836 <sys_open+0xdb>
      iunlockput(ip);
80105819:	83 ec 0c             	sub    $0xc,%esp
8010581c:	ff 75 f4             	push   -0xc(%ebp)
8010581f:	e8 f8 c3 ff ff       	call   80101c1c <iunlockput>
80105824:	83 c4 10             	add    $0x10,%esp
      end_op();
80105827:	e8 9d d8 ff ff       	call   801030c9 <end_op>
      return -1;
8010582c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105831:	e9 c0 00 00 00       	jmp    801058f6 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105836:	e8 a3 b7 ff ff       	call   80100fde <filealloc>
8010583b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010583e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105842:	74 17                	je     8010585b <sys_open+0x100>
80105844:	83 ec 0c             	sub    $0xc,%esp
80105847:	ff 75 f0             	push   -0x10(%ebp)
8010584a:	e8 33 f7 ff ff       	call   80104f82 <fdalloc>
8010584f:	83 c4 10             	add    $0x10,%esp
80105852:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105855:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105859:	79 2e                	jns    80105889 <sys_open+0x12e>
    if(f)
8010585b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010585f:	74 0e                	je     8010586f <sys_open+0x114>
      fileclose(f);
80105861:	83 ec 0c             	sub    $0xc,%esp
80105864:	ff 75 f0             	push   -0x10(%ebp)
80105867:	e8 30 b8 ff ff       	call   8010109c <fileclose>
8010586c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010586f:	83 ec 0c             	sub    $0xc,%esp
80105872:	ff 75 f4             	push   -0xc(%ebp)
80105875:	e8 a2 c3 ff ff       	call   80101c1c <iunlockput>
8010587a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010587d:	e8 47 d8 ff ff       	call   801030c9 <end_op>
    return -1;
80105882:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105887:	eb 6d                	jmp    801058f6 <sys_open+0x19b>
  }
  iunlock(ip);
80105889:	83 ec 0c             	sub    $0xc,%esp
8010588c:	ff 75 f4             	push   -0xc(%ebp)
8010588f:	e8 6a c2 ff ff       	call   80101afe <iunlock>
80105894:	83 c4 10             	add    $0x10,%esp
  end_op();
80105897:	e8 2d d8 ff ff       	call   801030c9 <end_op>

  f->type = FD_INODE;
8010589c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801058a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058ab:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801058b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058bb:	83 e0 01             	and    $0x1,%eax
801058be:	85 c0                	test   %eax,%eax
801058c0:	0f 94 c0             	sete   %al
801058c3:	89 c2                	mov    %eax,%edx
801058c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c8:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058ce:	83 e0 01             	and    $0x1,%eax
801058d1:	85 c0                	test   %eax,%eax
801058d3:	75 0a                	jne    801058df <sys_open+0x184>
801058d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058d8:	83 e0 02             	and    $0x2,%eax
801058db:	85 c0                	test   %eax,%eax
801058dd:	74 07                	je     801058e6 <sys_open+0x18b>
801058df:	b8 01 00 00 00       	mov    $0x1,%eax
801058e4:	eb 05                	jmp    801058eb <sys_open+0x190>
801058e6:	b8 00 00 00 00       	mov    $0x0,%eax
801058eb:	89 c2                	mov    %eax,%edx
801058ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f0:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058f6:	c9                   	leave  
801058f7:	c3                   	ret    

801058f8 <sys_mkdir>:

int
sys_mkdir(void)
{
801058f8:	55                   	push   %ebp
801058f9:	89 e5                	mov    %esp,%ebp
801058fb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058fe:	e8 3a d7 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105903:	83 ec 08             	sub    $0x8,%esp
80105906:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105909:	50                   	push   %eax
8010590a:	6a 00                	push   $0x0
8010590c:	e8 48 f5 ff ff       	call   80104e59 <argstr>
80105911:	83 c4 10             	add    $0x10,%esp
80105914:	85 c0                	test   %eax,%eax
80105916:	78 1b                	js     80105933 <sys_mkdir+0x3b>
80105918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591b:	6a 00                	push   $0x0
8010591d:	6a 00                	push   $0x0
8010591f:	6a 01                	push   $0x1
80105921:	50                   	push   %eax
80105922:	e8 62 fc ff ff       	call   80105589 <create>
80105927:	83 c4 10             	add    $0x10,%esp
8010592a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010592d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105931:	75 0c                	jne    8010593f <sys_mkdir+0x47>
    end_op();
80105933:	e8 91 d7 ff ff       	call   801030c9 <end_op>
    return -1;
80105938:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593d:	eb 18                	jmp    80105957 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010593f:	83 ec 0c             	sub    $0xc,%esp
80105942:	ff 75 f4             	push   -0xc(%ebp)
80105945:	e8 d2 c2 ff ff       	call   80101c1c <iunlockput>
8010594a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010594d:	e8 77 d7 ff ff       	call   801030c9 <end_op>
  return 0;
80105952:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105957:	c9                   	leave  
80105958:	c3                   	ret    

80105959 <sys_mknod>:

int
sys_mknod(void)
{
80105959:	55                   	push   %ebp
8010595a:	89 e5                	mov    %esp,%ebp
8010595c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010595f:	e8 d9 d6 ff ff       	call   8010303d <begin_op>
  if((argstr(0, &path)) < 0 ||
80105964:	83 ec 08             	sub    $0x8,%esp
80105967:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010596a:	50                   	push   %eax
8010596b:	6a 00                	push   $0x0
8010596d:	e8 e7 f4 ff ff       	call   80104e59 <argstr>
80105972:	83 c4 10             	add    $0x10,%esp
80105975:	85 c0                	test   %eax,%eax
80105977:	78 4f                	js     801059c8 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105979:	83 ec 08             	sub    $0x8,%esp
8010597c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010597f:	50                   	push   %eax
80105980:	6a 01                	push   $0x1
80105982:	e8 4c f4 ff ff       	call   80104dd3 <argint>
80105987:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010598a:	85 c0                	test   %eax,%eax
8010598c:	78 3a                	js     801059c8 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010598e:	83 ec 08             	sub    $0x8,%esp
80105991:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105994:	50                   	push   %eax
80105995:	6a 02                	push   $0x2
80105997:	e8 37 f4 ff ff       	call   80104dd3 <argint>
8010599c:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010599f:	85 c0                	test   %eax,%eax
801059a1:	78 25                	js     801059c8 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059a6:	0f bf c8             	movswl %ax,%ecx
801059a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059ac:	0f bf d0             	movswl %ax,%edx
801059af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b2:	51                   	push   %ecx
801059b3:	52                   	push   %edx
801059b4:	6a 03                	push   $0x3
801059b6:	50                   	push   %eax
801059b7:	e8 cd fb ff ff       	call   80105589 <create>
801059bc:	83 c4 10             	add    $0x10,%esp
801059bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801059c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059c6:	75 0c                	jne    801059d4 <sys_mknod+0x7b>
    end_op();
801059c8:	e8 fc d6 ff ff       	call   801030c9 <end_op>
    return -1;
801059cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d2:	eb 18                	jmp    801059ec <sys_mknod+0x93>
  }
  iunlockput(ip);
801059d4:	83 ec 0c             	sub    $0xc,%esp
801059d7:	ff 75 f4             	push   -0xc(%ebp)
801059da:	e8 3d c2 ff ff       	call   80101c1c <iunlockput>
801059df:	83 c4 10             	add    $0x10,%esp
  end_op();
801059e2:	e8 e2 d6 ff ff       	call   801030c9 <end_op>
  return 0;
801059e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059ec:	c9                   	leave  
801059ed:	c3                   	ret    

801059ee <sys_chdir>:

int
sys_chdir(void)
{
801059ee:	55                   	push   %ebp
801059ef:	89 e5                	mov    %esp,%ebp
801059f1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059f4:	e8 38 e0 ff ff       	call   80103a31 <myproc>
801059f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059fc:	e8 3c d6 ff ff       	call   8010303d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a01:	83 ec 08             	sub    $0x8,%esp
80105a04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a07:	50                   	push   %eax
80105a08:	6a 00                	push   $0x0
80105a0a:	e8 4a f4 ff ff       	call   80104e59 <argstr>
80105a0f:	83 c4 10             	add    $0x10,%esp
80105a12:	85 c0                	test   %eax,%eax
80105a14:	78 18                	js     80105a2e <sys_chdir+0x40>
80105a16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a19:	83 ec 0c             	sub    $0xc,%esp
80105a1c:	50                   	push   %eax
80105a1d:	e8 fc ca ff ff       	call   8010251e <namei>
80105a22:	83 c4 10             	add    $0x10,%esp
80105a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a2c:	75 0c                	jne    80105a3a <sys_chdir+0x4c>
    end_op();
80105a2e:	e8 96 d6 ff ff       	call   801030c9 <end_op>
    return -1;
80105a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a38:	eb 68                	jmp    80105aa2 <sys_chdir+0xb4>
  }
  ilock(ip);
80105a3a:	83 ec 0c             	sub    $0xc,%esp
80105a3d:	ff 75 f0             	push   -0x10(%ebp)
80105a40:	e8 a6 bf ff ff       	call   801019eb <ilock>
80105a45:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a4f:	66 83 f8 01          	cmp    $0x1,%ax
80105a53:	74 1a                	je     80105a6f <sys_chdir+0x81>
    iunlockput(ip);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	ff 75 f0             	push   -0x10(%ebp)
80105a5b:	e8 bc c1 ff ff       	call   80101c1c <iunlockput>
80105a60:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a63:	e8 61 d6 ff ff       	call   801030c9 <end_op>
    return -1;
80105a68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6d:	eb 33                	jmp    80105aa2 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a6f:	83 ec 0c             	sub    $0xc,%esp
80105a72:	ff 75 f0             	push   -0x10(%ebp)
80105a75:	e8 84 c0 ff ff       	call   80101afe <iunlock>
80105a7a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	8b 40 68             	mov    0x68(%eax),%eax
80105a83:	83 ec 0c             	sub    $0xc,%esp
80105a86:	50                   	push   %eax
80105a87:	e8 c0 c0 ff ff       	call   80101b4c <iput>
80105a8c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a8f:	e8 35 d6 ff ff       	call   801030c9 <end_op>
  curproc->cwd = ip;
80105a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a9a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa2:	c9                   	leave  
80105aa3:	c3                   	ret    

80105aa4 <sys_exec>:

int
sys_exec(void)
{
80105aa4:	55                   	push   %ebp
80105aa5:	89 e5                	mov    %esp,%ebp
80105aa7:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105aad:	83 ec 08             	sub    $0x8,%esp
80105ab0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab3:	50                   	push   %eax
80105ab4:	6a 00                	push   $0x0
80105ab6:	e8 9e f3 ff ff       	call   80104e59 <argstr>
80105abb:	83 c4 10             	add    $0x10,%esp
80105abe:	85 c0                	test   %eax,%eax
80105ac0:	78 18                	js     80105ada <sys_exec+0x36>
80105ac2:	83 ec 08             	sub    $0x8,%esp
80105ac5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105acb:	50                   	push   %eax
80105acc:	6a 01                	push   $0x1
80105ace:	e8 00 f3 ff ff       	call   80104dd3 <argint>
80105ad3:	83 c4 10             	add    $0x10,%esp
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	79 0a                	jns    80105ae4 <sys_exec+0x40>
    return -1;
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	e9 c6 00 00 00       	jmp    80105baa <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ae4:	83 ec 04             	sub    $0x4,%esp
80105ae7:	68 80 00 00 00       	push   $0x80
80105aec:	6a 00                	push   $0x0
80105aee:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105af4:	50                   	push   %eax
80105af5:	e8 ca ef ff ff       	call   80104ac4 <memset>
80105afa:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b07:	83 f8 1f             	cmp    $0x1f,%eax
80105b0a:	76 0a                	jbe    80105b16 <sys_exec+0x72>
      return -1;
80105b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b11:	e9 94 00 00 00       	jmp    80105baa <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b19:	c1 e0 02             	shl    $0x2,%eax
80105b1c:	89 c2                	mov    %eax,%edx
80105b1e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b24:	01 c2                	add    %eax,%edx
80105b26:	83 ec 08             	sub    $0x8,%esp
80105b29:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b2f:	50                   	push   %eax
80105b30:	52                   	push   %edx
80105b31:	e8 18 f2 ff ff       	call   80104d4e <fetchint>
80105b36:	83 c4 10             	add    $0x10,%esp
80105b39:	85 c0                	test   %eax,%eax
80105b3b:	79 07                	jns    80105b44 <sys_exec+0xa0>
      return -1;
80105b3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b42:	eb 66                	jmp    80105baa <sys_exec+0x106>
    if(uarg == 0){
80105b44:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b4a:	85 c0                	test   %eax,%eax
80105b4c:	75 27                	jne    80105b75 <sys_exec+0xd1>
      argv[i] = 0;
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b58:	00 00 00 00 
      break;
80105b5c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b60:	83 ec 08             	sub    $0x8,%esp
80105b63:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b69:	52                   	push   %edx
80105b6a:	50                   	push   %eax
80105b6b:	e8 10 b0 ff ff       	call   80100b80 <exec>
80105b70:	83 c4 10             	add    $0x10,%esp
80105b73:	eb 35                	jmp    80105baa <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b75:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7e:	c1 e0 02             	shl    $0x2,%eax
80105b81:	01 c2                	add    %eax,%edx
80105b83:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b89:	83 ec 08             	sub    $0x8,%esp
80105b8c:	52                   	push   %edx
80105b8d:	50                   	push   %eax
80105b8e:	e8 ea f1 ff ff       	call   80104d7d <fetchstr>
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	79 07                	jns    80105ba1 <sys_exec+0xfd>
      return -1;
80105b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9f:	eb 09                	jmp    80105baa <sys_exec+0x106>
  for(i=0;; i++){
80105ba1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ba5:	e9 5a ff ff ff       	jmp    80105b04 <sys_exec+0x60>
}
80105baa:	c9                   	leave  
80105bab:	c3                   	ret    

80105bac <sys_pipe>:

int
sys_pipe(void)
{
80105bac:	55                   	push   %ebp
80105bad:	89 e5                	mov    %esp,%ebp
80105baf:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bb2:	83 ec 04             	sub    $0x4,%esp
80105bb5:	6a 08                	push   $0x8
80105bb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bba:	50                   	push   %eax
80105bbb:	6a 00                	push   $0x0
80105bbd:	e8 3e f2 ff ff       	call   80104e00 <argptr>
80105bc2:	83 c4 10             	add    $0x10,%esp
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	79 0a                	jns    80105bd3 <sys_pipe+0x27>
    return -1;
80105bc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bce:	e9 ae 00 00 00       	jmp    80105c81 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105bd3:	83 ec 08             	sub    $0x8,%esp
80105bd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bd9:	50                   	push   %eax
80105bda:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105bdd:	50                   	push   %eax
80105bde:	e8 8b d9 ff ff       	call   8010356e <pipealloc>
80105be3:	83 c4 10             	add    $0x10,%esp
80105be6:	85 c0                	test   %eax,%eax
80105be8:	79 0a                	jns    80105bf4 <sys_pipe+0x48>
    return -1;
80105bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bef:	e9 8d 00 00 00       	jmp    80105c81 <sys_pipe+0xd5>
  fd0 = -1;
80105bf4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bfe:	83 ec 0c             	sub    $0xc,%esp
80105c01:	50                   	push   %eax
80105c02:	e8 7b f3 ff ff       	call   80104f82 <fdalloc>
80105c07:	83 c4 10             	add    $0x10,%esp
80105c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c11:	78 18                	js     80105c2b <sys_pipe+0x7f>
80105c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c16:	83 ec 0c             	sub    $0xc,%esp
80105c19:	50                   	push   %eax
80105c1a:	e8 63 f3 ff ff       	call   80104f82 <fdalloc>
80105c1f:	83 c4 10             	add    $0x10,%esp
80105c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c29:	79 3e                	jns    80105c69 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c2f:	78 13                	js     80105c44 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c31:	e8 fb dd ff ff       	call   80103a31 <myproc>
80105c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c39:	83 c2 08             	add    $0x8,%edx
80105c3c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c43:	00 
    fileclose(rf);
80105c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c47:	83 ec 0c             	sub    $0xc,%esp
80105c4a:	50                   	push   %eax
80105c4b:	e8 4c b4 ff ff       	call   8010109c <fileclose>
80105c50:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c56:	83 ec 0c             	sub    $0xc,%esp
80105c59:	50                   	push   %eax
80105c5a:	e8 3d b4 ff ff       	call   8010109c <fileclose>
80105c5f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c67:	eb 18                	jmp    80105c81 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c74:	8d 50 04             	lea    0x4(%eax),%edx
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	89 02                	mov    %eax,(%edx)
  return 0;
80105c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c81:	c9                   	leave  
80105c82:	c3                   	ret    

80105c83 <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
80105c83:	55                   	push   %ebp
80105c84:	89 e5                	mov    %esp,%ebp
80105c86:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c89:	e8 a2 e0 ff ff       	call   80103d30 <fork>
}
80105c8e:	c9                   	leave  
80105c8f:	c3                   	ret    

80105c90 <sys_exit>:

int
sys_exit(void)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c96:	e8 0e e2 ff ff       	call   80103ea9 <exit>
  return 0;  // not reached
80105c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ca0:	c9                   	leave  
80105ca1:	c3                   	ret    

80105ca2 <sys_wait>:

int
sys_wait(void)
{
80105ca2:	55                   	push   %ebp
80105ca3:	89 e5                	mov    %esp,%ebp
80105ca5:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105ca8:	e8 1c e3 ff ff       	call   80103fc9 <wait>
}
80105cad:	c9                   	leave  
80105cae:	c3                   	ret    

80105caf <sys_kill>:

int
sys_kill(void)
{
80105caf:	55                   	push   %ebp
80105cb0:	89 e5                	mov    %esp,%ebp
80105cb2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105cb5:	83 ec 08             	sub    $0x8,%esp
80105cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cbb:	50                   	push   %eax
80105cbc:	6a 00                	push   $0x0
80105cbe:	e8 10 f1 ff ff       	call   80104dd3 <argint>
80105cc3:	83 c4 10             	add    $0x10,%esp
80105cc6:	85 c0                	test   %eax,%eax
80105cc8:	79 07                	jns    80105cd1 <sys_kill+0x22>
    return -1;
80105cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccf:	eb 0f                	jmp    80105ce0 <sys_kill+0x31>
  return kill(pid);
80105cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd4:	83 ec 0c             	sub    $0xc,%esp
80105cd7:	50                   	push   %eax
80105cd8:	e8 1b e7 ff ff       	call   801043f8 <kill>
80105cdd:	83 c4 10             	add    $0x10,%esp
}
80105ce0:	c9                   	leave  
80105ce1:	c3                   	ret    

80105ce2 <sys_getpid>:

int
sys_getpid(void)
{
80105ce2:	55                   	push   %ebp
80105ce3:	89 e5                	mov    %esp,%ebp
80105ce5:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ce8:	e8 44 dd ff ff       	call   80103a31 <myproc>
80105ced:	8b 40 10             	mov    0x10(%eax),%eax
}
80105cf0:	c9                   	leave  
80105cf1:	c3                   	ret    

80105cf2 <sys_printpt>:
 //추가
int
sys_printpt(void)
{
80105cf2:	55                   	push   %ebp
80105cf3:	89 e5                	mov    %esp,%ebp
80105cf5:	83 ec 18             	sub    $0x18,%esp
  int pid =0;
80105cf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (argint(0, &pid) < 0) //사용자에게 pid 넘겨받지 못하면 실패
80105cff:	83 ec 08             	sub    $0x8,%esp
80105d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d05:	50                   	push   %eax
80105d06:	6a 00                	push   $0x0
80105d08:	e8 c6 f0 ff ff       	call   80104dd3 <argint>
80105d0d:	83 c4 10             	add    $0x10,%esp
80105d10:	85 c0                	test   %eax,%eax
80105d12:	79 07                	jns    80105d1b <sys_printpt+0x29>
    return -1;
80105d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d19:	eb 0f                	jmp    80105d2a <sys_printpt+0x38>
  
  return printpt(pid);
80105d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1e:	83 ec 0c             	sub    $0xc,%esp
80105d21:	50                   	push   %eax
80105d22:	e8 4f e8 ff ff       	call   80104576 <printpt>
80105d27:	83 c4 10             	add    $0x10,%esp
}
80105d2a:	c9                   	leave  
80105d2b:	c3                   	ret    

80105d2c <sys_sbrk>:


int
sys_sbrk(void)
{
80105d2c:	55                   	push   %ebp
80105d2d:	89 e5                	mov    %esp,%ebp
80105d2f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d32:	83 ec 08             	sub    $0x8,%esp
80105d35:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d38:	50                   	push   %eax
80105d39:	6a 00                	push   $0x0
80105d3b:	e8 93 f0 ff ff       	call   80104dd3 <argint>
80105d40:	83 c4 10             	add    $0x10,%esp
80105d43:	85 c0                	test   %eax,%eax
80105d45:	79 07                	jns    80105d4e <sys_sbrk+0x22>
    return -1;
80105d47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4c:	eb 27                	jmp    80105d75 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105d4e:	e8 de dc ff ff       	call   80103a31 <myproc>
80105d53:	8b 00                	mov    (%eax),%eax
80105d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5b:	83 ec 0c             	sub    $0xc,%esp
80105d5e:	50                   	push   %eax
80105d5f:	e8 31 df ff ff       	call   80103c95 <growproc>
80105d64:	83 c4 10             	add    $0x10,%esp
80105d67:	85 c0                	test   %eax,%eax
80105d69:	79 07                	jns    80105d72 <sys_sbrk+0x46>
    return -1;
80105d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d70:	eb 03                	jmp    80105d75 <sys_sbrk+0x49>
  return addr;
80105d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d75:	c9                   	leave  
80105d76:	c3                   	ret    

80105d77 <sys_sleep>:

int
sys_sleep(void)
{
80105d77:	55                   	push   %ebp
80105d78:	89 e5                	mov    %esp,%ebp
80105d7a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d7d:	83 ec 08             	sub    $0x8,%esp
80105d80:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d83:	50                   	push   %eax
80105d84:	6a 00                	push   $0x0
80105d86:	e8 48 f0 ff ff       	call   80104dd3 <argint>
80105d8b:	83 c4 10             	add    $0x10,%esp
80105d8e:	85 c0                	test   %eax,%eax
80105d90:	79 07                	jns    80105d99 <sys_sleep+0x22>
    return -1;
80105d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d97:	eb 76                	jmp    80105e0f <sys_sleep+0x98>
  acquire(&tickslock);
80105d99:	83 ec 0c             	sub    $0xc,%esp
80105d9c:	68 40 69 19 80       	push   $0x80196940
80105da1:	e8 a8 ea ff ff       	call   8010484e <acquire>
80105da6:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105da9:	a1 74 69 19 80       	mov    0x80196974,%eax
80105dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105db1:	eb 38                	jmp    80105deb <sys_sleep+0x74>
    if(myproc()->killed){
80105db3:	e8 79 dc ff ff       	call   80103a31 <myproc>
80105db8:	8b 40 24             	mov    0x24(%eax),%eax
80105dbb:	85 c0                	test   %eax,%eax
80105dbd:	74 17                	je     80105dd6 <sys_sleep+0x5f>
      release(&tickslock);
80105dbf:	83 ec 0c             	sub    $0xc,%esp
80105dc2:	68 40 69 19 80       	push   $0x80196940
80105dc7:	e8 f0 ea ff ff       	call   801048bc <release>
80105dcc:	83 c4 10             	add    $0x10,%esp
      return -1;
80105dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd4:	eb 39                	jmp    80105e0f <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105dd6:	83 ec 08             	sub    $0x8,%esp
80105dd9:	68 40 69 19 80       	push   $0x80196940
80105dde:	68 74 69 19 80       	push   $0x80196974
80105de3:	e8 f2 e4 ff ff       	call   801042da <sleep>
80105de8:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105deb:	a1 74 69 19 80       	mov    0x80196974,%eax
80105df0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105df3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105df6:	39 d0                	cmp    %edx,%eax
80105df8:	72 b9                	jb     80105db3 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105dfa:	83 ec 0c             	sub    $0xc,%esp
80105dfd:	68 40 69 19 80       	push   $0x80196940
80105e02:	e8 b5 ea ff ff       	call   801048bc <release>
80105e07:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e0f:	c9                   	leave  
80105e10:	c3                   	ret    

80105e11 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e11:	55                   	push   %ebp
80105e12:	89 e5                	mov    %esp,%ebp
80105e14:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e17:	83 ec 0c             	sub    $0xc,%esp
80105e1a:	68 40 69 19 80       	push   $0x80196940
80105e1f:	e8 2a ea ff ff       	call   8010484e <acquire>
80105e24:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105e27:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105e2f:	83 ec 0c             	sub    $0xc,%esp
80105e32:	68 40 69 19 80       	push   $0x80196940
80105e37:	e8 80 ea ff ff       	call   801048bc <release>
80105e3c:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e42:	c9                   	leave  
80105e43:	c3                   	ret    

80105e44 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e44:	1e                   	push   %ds
  pushl %es
80105e45:	06                   	push   %es
  pushl %fs
80105e46:	0f a0                	push   %fs
  pushl %gs
80105e48:	0f a8                	push   %gs
  pushal
80105e4a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e4b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e4f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e51:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e53:	54                   	push   %esp
  call trap
80105e54:	e8 e3 01 00 00       	call   8010603c <trap>
  addl $4, %esp
80105e59:	83 c4 04             	add    $0x4,%esp

80105e5c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e5c:	61                   	popa   
  popl %gs
80105e5d:	0f a9                	pop    %gs
  popl %fs
80105e5f:	0f a1                	pop    %fs
  popl %es
80105e61:	07                   	pop    %es
  popl %ds
80105e62:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e63:	83 c4 08             	add    $0x8,%esp
  iret
80105e66:	cf                   	iret   

80105e67 <lidt>:
{
80105e67:	55                   	push   %ebp
80105e68:	89 e5                	mov    %esp,%ebp
80105e6a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e70:	83 e8 01             	sub    $0x1,%eax
80105e73:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e77:	8b 45 08             	mov    0x8(%ebp),%eax
80105e7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e81:	c1 e8 10             	shr    $0x10,%eax
80105e84:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e88:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e8b:	0f 01 18             	lidtl  (%eax)
}
80105e8e:	90                   	nop
80105e8f:	c9                   	leave  
80105e90:	c3                   	ret    

80105e91 <rcr2>:

static inline uint
rcr2(void)
{
80105e91:	55                   	push   %ebp
80105e92:	89 e5                	mov    %esp,%ebp
80105e94:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e97:	0f 20 d0             	mov    %cr2,%eax
80105e9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105e9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ea0:	c9                   	leave  
80105ea1:	c3                   	ret    

80105ea2 <lcr3>:

static inline void
lcr3(uint val)
{
80105ea2:	55                   	push   %ebp
80105ea3:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea8:	0f 22 d8             	mov    %eax,%cr3
}
80105eab:	90                   	nop
80105eac:	5d                   	pop    %ebp
80105ead:	c3                   	ret    

80105eae <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105eae:	55                   	push   %ebp
80105eaf:	89 e5                	mov    %esp,%ebp
80105eb1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105eb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ebb:	e9 c3 00 00 00       	jmp    80105f83 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec3:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105eca:	89 c2                	mov    %eax,%edx
80105ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecf:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105ed6:	80 
80105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eda:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105ee1:	80 08 00 
80105ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee7:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105eee:	80 
80105eef:	83 e2 e0             	and    $0xffffffe0,%edx
80105ef2:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efc:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f03:	80 
80105f04:	83 e2 1f             	and    $0x1f,%edx
80105f07:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f11:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f18:	80 
80105f19:	83 e2 f0             	and    $0xfffffff0,%edx
80105f1c:	83 ca 0e             	or     $0xe,%edx
80105f1f:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f29:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f30:	80 
80105f31:	83 e2 ef             	and    $0xffffffef,%edx
80105f34:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f45:	80 
80105f46:	83 e2 9f             	and    $0xffffff9f,%edx
80105f49:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f53:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f5a:	80 
80105f5b:	83 ca 80             	or     $0xffffff80,%edx
80105f5e:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f68:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f6f:	c1 e8 10             	shr    $0x10,%eax
80105f72:	89 c2                	mov    %eax,%edx
80105f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f77:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105f7e:	80 
  for(i = 0; i < 256; i++)
80105f7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105f83:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105f8a:	0f 8e 30 ff ff ff    	jle    80105ec0 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f90:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105f95:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105f9b:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105fa2:	08 00 
80105fa4:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fab:	83 e0 e0             	and    $0xffffffe0,%eax
80105fae:	a2 44 63 19 80       	mov    %al,0x80196344
80105fb3:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fba:	83 e0 1f             	and    $0x1f,%eax
80105fbd:	a2 44 63 19 80       	mov    %al,0x80196344
80105fc2:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fc9:	83 c8 0f             	or     $0xf,%eax
80105fcc:	a2 45 63 19 80       	mov    %al,0x80196345
80105fd1:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fd8:	83 e0 ef             	and    $0xffffffef,%eax
80105fdb:	a2 45 63 19 80       	mov    %al,0x80196345
80105fe0:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fe7:	83 c8 60             	or     $0x60,%eax
80105fea:	a2 45 63 19 80       	mov    %al,0x80196345
80105fef:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105ff6:	83 c8 80             	or     $0xffffff80,%eax
80105ff9:	a2 45 63 19 80       	mov    %al,0x80196345
80105ffe:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106003:	c1 e8 10             	shr    $0x10,%eax
80106006:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
8010600c:	83 ec 08             	sub    $0x8,%esp
8010600f:	68 60 a6 10 80       	push   $0x8010a660
80106014:	68 40 69 19 80       	push   $0x80196940
80106019:	e8 0e e8 ff ff       	call   8010482c <initlock>
8010601e:	83 c4 10             	add    $0x10,%esp
}
80106021:	90                   	nop
80106022:	c9                   	leave  
80106023:	c3                   	ret    

80106024 <idtinit>:

void
idtinit(void)
{
80106024:	55                   	push   %ebp
80106025:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106027:	68 00 08 00 00       	push   $0x800
8010602c:	68 40 61 19 80       	push   $0x80196140
80106031:	e8 31 fe ff ff       	call   80105e67 <lidt>
80106036:	83 c4 08             	add    $0x8,%esp
}
80106039:	90                   	nop
8010603a:	c9                   	leave  
8010603b:	c3                   	ret    

8010603c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010603c:	55                   	push   %ebp
8010603d:	89 e5                	mov    %esp,%ebp
8010603f:	57                   	push   %edi
80106040:	56                   	push   %esi
80106041:	53                   	push   %ebx
80106042:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106045:	8b 45 08             	mov    0x8(%ebp),%eax
80106048:	8b 40 30             	mov    0x30(%eax),%eax
8010604b:	83 f8 40             	cmp    $0x40,%eax
8010604e:	75 3b                	jne    8010608b <trap+0x4f>
    if(myproc()->killed)
80106050:	e8 dc d9 ff ff       	call   80103a31 <myproc>
80106055:	8b 40 24             	mov    0x24(%eax),%eax
80106058:	85 c0                	test   %eax,%eax
8010605a:	74 05                	je     80106061 <trap+0x25>
      exit();
8010605c:	e8 48 de ff ff       	call   80103ea9 <exit>
    myproc()->tf = tf;
80106061:	e8 cb d9 ff ff       	call   80103a31 <myproc>
80106066:	8b 55 08             	mov    0x8(%ebp),%edx
80106069:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010606c:	e8 1f ee ff ff       	call   80104e90 <syscall>
    if(myproc()->killed)
80106071:	e8 bb d9 ff ff       	call   80103a31 <myproc>
80106076:	8b 40 24             	mov    0x24(%eax),%eax
80106079:	85 c0                	test   %eax,%eax
8010607b:	0f 84 f3 02 00 00    	je     80106374 <trap+0x338>
      exit();
80106081:	e8 23 de ff ff       	call   80103ea9 <exit>
    return;
80106086:	e9 e9 02 00 00       	jmp    80106374 <trap+0x338>
  }

  switch(tf->trapno){
8010608b:	8b 45 08             	mov    0x8(%ebp),%eax
8010608e:	8b 40 30             	mov    0x30(%eax),%eax
80106091:	83 e8 0e             	sub    $0xe,%eax
80106094:	83 f8 31             	cmp    $0x31,%eax
80106097:	0f 87 9f 01 00 00    	ja     8010623c <trap+0x200>
8010609d:	8b 04 85 20 a7 10 80 	mov    -0x7fef58e0(,%eax,4),%eax
801060a4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060a6:	e8 f3 d8 ff ff       	call   8010399e <cpuid>
801060ab:	85 c0                	test   %eax,%eax
801060ad:	75 3d                	jne    801060ec <trap+0xb0>
      acquire(&tickslock);
801060af:	83 ec 0c             	sub    $0xc,%esp
801060b2:	68 40 69 19 80       	push   $0x80196940
801060b7:	e8 92 e7 ff ff       	call   8010484e <acquire>
801060bc:	83 c4 10             	add    $0x10,%esp
      ticks++;
801060bf:	a1 74 69 19 80       	mov    0x80196974,%eax
801060c4:	83 c0 01             	add    $0x1,%eax
801060c7:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
801060cc:	83 ec 0c             	sub    $0xc,%esp
801060cf:	68 74 69 19 80       	push   $0x80196974
801060d4:	e8 e8 e2 ff ff       	call   801043c1 <wakeup>
801060d9:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801060dc:	83 ec 0c             	sub    $0xc,%esp
801060df:	68 40 69 19 80       	push   $0x80196940
801060e4:	e8 d3 e7 ff ff       	call   801048bc <release>
801060e9:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801060ec:	e8 2c ca ff ff       	call   80102b1d <lapiceoi>
    break;
801060f1:	e9 fe 01 00 00       	jmp    801062f4 <trap+0x2b8>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801060f6:	e8 be 3f 00 00       	call   8010a0b9 <ideintr>
    lapiceoi();
801060fb:	e8 1d ca ff ff       	call   80102b1d <lapiceoi>
    break;
80106100:	e9 ef 01 00 00       	jmp    801062f4 <trap+0x2b8>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106105:	e8 58 c8 ff ff       	call   80102962 <kbdintr>
    lapiceoi();
8010610a:	e8 0e ca ff ff       	call   80102b1d <lapiceoi>
    break;
8010610f:	e9 e0 01 00 00       	jmp    801062f4 <trap+0x2b8>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106114:	e8 31 04 00 00       	call   8010654a <uartintr>
    lapiceoi();
80106119:	e8 ff c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010611e:	e9 d1 01 00 00       	jmp    801062f4 <trap+0x2b8>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106123:	e8 44 2c 00 00       	call   80108d6c <i8254_intr>
    lapiceoi();
80106128:	e8 f0 c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010612d:	e9 c2 01 00 00       	jmp    801062f4 <trap+0x2b8>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106132:	8b 45 08             	mov    0x8(%ebp),%eax
80106135:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106138:	8b 45 08             	mov    0x8(%ebp),%eax
8010613b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010613f:	0f b7 d8             	movzwl %ax,%ebx
80106142:	e8 57 d8 ff ff       	call   8010399e <cpuid>
80106147:	56                   	push   %esi
80106148:	53                   	push   %ebx
80106149:	50                   	push   %eax
8010614a:	68 68 a6 10 80       	push   $0x8010a668
8010614f:	e8 a0 a2 ff ff       	call   801003f4 <cprintf>
80106154:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106157:	e8 c1 c9 ff ff       	call   80102b1d <lapiceoi>
    break;
8010615c:	e9 93 01 00 00       	jmp    801062f4 <trap+0x2b8>
  
  case T_PGFLT: {
    uint fault_addr = PGROUNDDOWN(rcr2());
80106161:	e8 2b fd ff ff       	call   80105e91 <rcr2>
80106166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010616b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *p = myproc();
8010616e:	e8 be d8 ff ff       	call   80103a31 <myproc>
80106173:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // 페이지가 이미 매핑되어 있으면 무시
    pte_t *pte = walkpgdir(p->pgdir, (void *)fault_addr, 0);
80106176:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106179:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010617c:	8b 40 04             	mov    0x4(%eax),%eax
8010617f:	83 ec 04             	sub    $0x4,%esp
80106182:	6a 00                	push   $0x0
80106184:	52                   	push   %edx
80106185:	50                   	push   %eax
80106186:	e8 ed 11 00 00       	call   80107378 <walkpgdir>
8010618b:	83 c4 10             	add    $0x10,%esp
8010618e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pte && (*pte & PTE_P))
80106191:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106195:	74 10                	je     801061a7 <trap+0x16b>
80106197:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010619a:	8b 00                	mov    (%eax),%eax
8010619c:	83 e0 01             	and    $0x1,%eax
8010619f:	85 c0                	test   %eax,%eax
801061a1:	0f 85 4c 01 00 00    	jne    801062f3 <trap+0x2b7>
      break;

    // 새 물리 메모리 할당
    char *new_mem = kalloc();
801061a7:	e8 f5 c5 ff ff       	call   801027a1 <kalloc>
801061ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!new_mem) {
801061af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801061b3:	75 18                	jne    801061cd <trap+0x191>
      cprintf("page alloc fail at %x\n", fault_addr);
801061b5:	83 ec 08             	sub    $0x8,%esp
801061b8:	ff 75 e4             	push   -0x1c(%ebp)
801061bb:	68 8c a6 10 80       	push   $0x8010a68c
801061c0:	e8 2f a2 ff ff       	call   801003f4 <cprintf>
801061c5:	83 c4 10             	add    $0x10,%esp
      break;
801061c8:	e9 27 01 00 00       	jmp    801062f4 <trap+0x2b8>
    }

    memset(new_mem, 0, PGSIZE);
801061cd:	83 ec 04             	sub    $0x4,%esp
801061d0:	68 00 10 00 00       	push   $0x1000
801061d5:	6a 00                	push   $0x0
801061d7:	ff 75 d8             	push   -0x28(%ebp)
801061da:	e8 e5 e8 ff ff       	call   80104ac4 <memset>
801061df:	83 c4 10             	add    $0x10,%esp

    // 페이지 매핑
    if (mappages(p->pgdir, (void *)fault_addr, PGSIZE, V2P(new_mem), PTE_W | PTE_U) < 0) {
801061e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801061e5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801061eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801061ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061f1:	8b 40 04             	mov    0x4(%eax),%eax
801061f4:	83 ec 0c             	sub    $0xc,%esp
801061f7:	6a 06                	push   $0x6
801061f9:	51                   	push   %ecx
801061fa:	68 00 10 00 00       	push   $0x1000
801061ff:	52                   	push   %edx
80106200:	50                   	push   %eax
80106201:	e8 08 12 00 00       	call   8010740e <mappages>
80106206:	83 c4 20             	add    $0x20,%esp
80106209:	85 c0                	test   %eax,%eax
8010620b:	79 13                	jns    80106220 <trap+0x1e4>
      kfree(new_mem);  // 실패했으면 할당 회수
8010620d:	83 ec 0c             	sub    $0xc,%esp
80106210:	ff 75 d8             	push   -0x28(%ebp)
80106213:	e8 ef c4 ff ff       	call   80102707 <kfree>
80106218:	83 c4 10             	add    $0x10,%esp
      break;
8010621b:	e9 d4 00 00 00       	jmp    801062f4 <trap+0x2b8>
    }

    // TLB 플러싱
    lcr3(V2P(p->pgdir));
80106220:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106223:	8b 40 04             	mov    0x4(%eax),%eax
80106226:	05 00 00 00 80       	add    $0x80000000,%eax
8010622b:	83 ec 0c             	sub    $0xc,%esp
8010622e:	50                   	push   %eax
8010622f:	e8 6e fc ff ff       	call   80105ea2 <lcr3>
80106234:	83 c4 10             	add    $0x10,%esp
    break;
80106237:	e9 b8 00 00 00       	jmp    801062f4 <trap+0x2b8>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010623c:	e8 f0 d7 ff ff       	call   80103a31 <myproc>
80106241:	85 c0                	test   %eax,%eax
80106243:	74 11                	je     80106256 <trap+0x21a>
80106245:	8b 45 08             	mov    0x8(%ebp),%eax
80106248:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010624c:	0f b7 c0             	movzwl %ax,%eax
8010624f:	83 e0 03             	and    $0x3,%eax
80106252:	85 c0                	test   %eax,%eax
80106254:	75 39                	jne    8010628f <trap+0x253>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106256:	e8 36 fc ff ff       	call   80105e91 <rcr2>
8010625b:	89 c3                	mov    %eax,%ebx
8010625d:	8b 45 08             	mov    0x8(%ebp),%eax
80106260:	8b 70 38             	mov    0x38(%eax),%esi
80106263:	e8 36 d7 ff ff       	call   8010399e <cpuid>
80106268:	8b 55 08             	mov    0x8(%ebp),%edx
8010626b:	8b 52 30             	mov    0x30(%edx),%edx
8010626e:	83 ec 0c             	sub    $0xc,%esp
80106271:	53                   	push   %ebx
80106272:	56                   	push   %esi
80106273:	50                   	push   %eax
80106274:	52                   	push   %edx
80106275:	68 a4 a6 10 80       	push   $0x8010a6a4
8010627a:	e8 75 a1 ff ff       	call   801003f4 <cprintf>
8010627f:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106282:	83 ec 0c             	sub    $0xc,%esp
80106285:	68 d6 a6 10 80       	push   $0x8010a6d6
8010628a:	e8 1a a3 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010628f:	e8 fd fb ff ff       	call   80105e91 <rcr2>
80106294:	89 c6                	mov    %eax,%esi
80106296:	8b 45 08             	mov    0x8(%ebp),%eax
80106299:	8b 40 38             	mov    0x38(%eax),%eax
8010629c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010629f:	e8 fa d6 ff ff       	call   8010399e <cpuid>
801062a4:	89 c3                	mov    %eax,%ebx
801062a6:	8b 45 08             	mov    0x8(%ebp),%eax
801062a9:	8b 48 34             	mov    0x34(%eax),%ecx
801062ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801062af:	8b 45 08             	mov    0x8(%ebp),%eax
801062b2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801062b5:	e8 77 d7 ff ff       	call   80103a31 <myproc>
801062ba:	8d 50 6c             	lea    0x6c(%eax),%edx
801062bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
801062c0:	e8 6c d7 ff ff       	call   80103a31 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801062c5:	8b 40 10             	mov    0x10(%eax),%eax
801062c8:	56                   	push   %esi
801062c9:	ff 75 d4             	push   -0x2c(%ebp)
801062cc:	53                   	push   %ebx
801062cd:	ff 75 d0             	push   -0x30(%ebp)
801062d0:	57                   	push   %edi
801062d1:	ff 75 cc             	push   -0x34(%ebp)
801062d4:	50                   	push   %eax
801062d5:	68 dc a6 10 80       	push   $0x8010a6dc
801062da:	e8 15 a1 ff ff       	call   801003f4 <cprintf>
801062df:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801062e2:	e8 4a d7 ff ff       	call   80103a31 <myproc>
801062e7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801062ee:	eb 04                	jmp    801062f4 <trap+0x2b8>
    break;
801062f0:	90                   	nop
801062f1:	eb 01                	jmp    801062f4 <trap+0x2b8>
      break;
801062f3:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801062f4:	e8 38 d7 ff ff       	call   80103a31 <myproc>
801062f9:	85 c0                	test   %eax,%eax
801062fb:	74 23                	je     80106320 <trap+0x2e4>
801062fd:	e8 2f d7 ff ff       	call   80103a31 <myproc>
80106302:	8b 40 24             	mov    0x24(%eax),%eax
80106305:	85 c0                	test   %eax,%eax
80106307:	74 17                	je     80106320 <trap+0x2e4>
80106309:	8b 45 08             	mov    0x8(%ebp),%eax
8010630c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106310:	0f b7 c0             	movzwl %ax,%eax
80106313:	83 e0 03             	and    $0x3,%eax
80106316:	83 f8 03             	cmp    $0x3,%eax
80106319:	75 05                	jne    80106320 <trap+0x2e4>
    exit();
8010631b:	e8 89 db ff ff       	call   80103ea9 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106320:	e8 0c d7 ff ff       	call   80103a31 <myproc>
80106325:	85 c0                	test   %eax,%eax
80106327:	74 1d                	je     80106346 <trap+0x30a>
80106329:	e8 03 d7 ff ff       	call   80103a31 <myproc>
8010632e:	8b 40 0c             	mov    0xc(%eax),%eax
80106331:	83 f8 04             	cmp    $0x4,%eax
80106334:	75 10                	jne    80106346 <trap+0x30a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106336:	8b 45 08             	mov    0x8(%ebp),%eax
80106339:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010633c:	83 f8 20             	cmp    $0x20,%eax
8010633f:	75 05                	jne    80106346 <trap+0x30a>
    yield();
80106341:	e8 14 df ff ff       	call   8010425a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106346:	e8 e6 d6 ff ff       	call   80103a31 <myproc>
8010634b:	85 c0                	test   %eax,%eax
8010634d:	74 26                	je     80106375 <trap+0x339>
8010634f:	e8 dd d6 ff ff       	call   80103a31 <myproc>
80106354:	8b 40 24             	mov    0x24(%eax),%eax
80106357:	85 c0                	test   %eax,%eax
80106359:	74 1a                	je     80106375 <trap+0x339>
8010635b:	8b 45 08             	mov    0x8(%ebp),%eax
8010635e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106362:	0f b7 c0             	movzwl %ax,%eax
80106365:	83 e0 03             	and    $0x3,%eax
80106368:	83 f8 03             	cmp    $0x3,%eax
8010636b:	75 08                	jne    80106375 <trap+0x339>
    exit();
8010636d:	e8 37 db ff ff       	call   80103ea9 <exit>
80106372:	eb 01                	jmp    80106375 <trap+0x339>
    return;
80106374:	90                   	nop
}
80106375:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106378:	5b                   	pop    %ebx
80106379:	5e                   	pop    %esi
8010637a:	5f                   	pop    %edi
8010637b:	5d                   	pop    %ebp
8010637c:	c3                   	ret    

8010637d <inb>:
{
8010637d:	55                   	push   %ebp
8010637e:	89 e5                	mov    %esp,%ebp
80106380:	83 ec 14             	sub    $0x14,%esp
80106383:	8b 45 08             	mov    0x8(%ebp),%eax
80106386:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010638a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010638e:	89 c2                	mov    %eax,%edx
80106390:	ec                   	in     (%dx),%al
80106391:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106394:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106398:	c9                   	leave  
80106399:	c3                   	ret    

8010639a <outb>:
{
8010639a:	55                   	push   %ebp
8010639b:	89 e5                	mov    %esp,%ebp
8010639d:	83 ec 08             	sub    $0x8,%esp
801063a0:	8b 45 08             	mov    0x8(%ebp),%eax
801063a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801063a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801063aa:	89 d0                	mov    %edx,%eax
801063ac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063af:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801063b3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801063b7:	ee                   	out    %al,(%dx)
}
801063b8:	90                   	nop
801063b9:	c9                   	leave  
801063ba:	c3                   	ret    

801063bb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801063bb:	55                   	push   %ebp
801063bc:	89 e5                	mov    %esp,%ebp
801063be:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801063c1:	6a 00                	push   $0x0
801063c3:	68 fa 03 00 00       	push   $0x3fa
801063c8:	e8 cd ff ff ff       	call   8010639a <outb>
801063cd:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801063d0:	68 80 00 00 00       	push   $0x80
801063d5:	68 fb 03 00 00       	push   $0x3fb
801063da:	e8 bb ff ff ff       	call   8010639a <outb>
801063df:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801063e2:	6a 0c                	push   $0xc
801063e4:	68 f8 03 00 00       	push   $0x3f8
801063e9:	e8 ac ff ff ff       	call   8010639a <outb>
801063ee:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801063f1:	6a 00                	push   $0x0
801063f3:	68 f9 03 00 00       	push   $0x3f9
801063f8:	e8 9d ff ff ff       	call   8010639a <outb>
801063fd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106400:	6a 03                	push   $0x3
80106402:	68 fb 03 00 00       	push   $0x3fb
80106407:	e8 8e ff ff ff       	call   8010639a <outb>
8010640c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010640f:	6a 00                	push   $0x0
80106411:	68 fc 03 00 00       	push   $0x3fc
80106416:	e8 7f ff ff ff       	call   8010639a <outb>
8010641b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010641e:	6a 01                	push   $0x1
80106420:	68 f9 03 00 00       	push   $0x3f9
80106425:	e8 70 ff ff ff       	call   8010639a <outb>
8010642a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010642d:	68 fd 03 00 00       	push   $0x3fd
80106432:	e8 46 ff ff ff       	call   8010637d <inb>
80106437:	83 c4 04             	add    $0x4,%esp
8010643a:	3c ff                	cmp    $0xff,%al
8010643c:	74 61                	je     8010649f <uartinit+0xe4>
    return;
  uart = 1;
8010643e:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
80106445:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106448:	68 fa 03 00 00       	push   $0x3fa
8010644d:	e8 2b ff ff ff       	call   8010637d <inb>
80106452:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106455:	68 f8 03 00 00       	push   $0x3f8
8010645a:	e8 1e ff ff ff       	call   8010637d <inb>
8010645f:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106462:	83 ec 08             	sub    $0x8,%esp
80106465:	6a 00                	push   $0x0
80106467:	6a 04                	push   $0x4
80106469:	e8 c1 c1 ff ff       	call   8010262f <ioapicenable>
8010646e:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106471:	c7 45 f4 e8 a7 10 80 	movl   $0x8010a7e8,-0xc(%ebp)
80106478:	eb 19                	jmp    80106493 <uartinit+0xd8>
    uartputc(*p);
8010647a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647d:	0f b6 00             	movzbl (%eax),%eax
80106480:	0f be c0             	movsbl %al,%eax
80106483:	83 ec 0c             	sub    $0xc,%esp
80106486:	50                   	push   %eax
80106487:	e8 16 00 00 00       	call   801064a2 <uartputc>
8010648c:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010648f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106496:	0f b6 00             	movzbl (%eax),%eax
80106499:	84 c0                	test   %al,%al
8010649b:	75 dd                	jne    8010647a <uartinit+0xbf>
8010649d:	eb 01                	jmp    801064a0 <uartinit+0xe5>
    return;
8010649f:	90                   	nop
}
801064a0:	c9                   	leave  
801064a1:	c3                   	ret    

801064a2 <uartputc>:

void
uartputc(int c)
{
801064a2:	55                   	push   %ebp
801064a3:	89 e5                	mov    %esp,%ebp
801064a5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801064a8:	a1 78 69 19 80       	mov    0x80196978,%eax
801064ad:	85 c0                	test   %eax,%eax
801064af:	74 53                	je     80106504 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801064b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064b8:	eb 11                	jmp    801064cb <uartputc+0x29>
    microdelay(10);
801064ba:	83 ec 0c             	sub    $0xc,%esp
801064bd:	6a 0a                	push   $0xa
801064bf:	e8 74 c6 ff ff       	call   80102b38 <microdelay>
801064c4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801064c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064cb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801064cf:	7f 1a                	jg     801064eb <uartputc+0x49>
801064d1:	83 ec 0c             	sub    $0xc,%esp
801064d4:	68 fd 03 00 00       	push   $0x3fd
801064d9:	e8 9f fe ff ff       	call   8010637d <inb>
801064de:	83 c4 10             	add    $0x10,%esp
801064e1:	0f b6 c0             	movzbl %al,%eax
801064e4:	83 e0 20             	and    $0x20,%eax
801064e7:	85 c0                	test   %eax,%eax
801064e9:	74 cf                	je     801064ba <uartputc+0x18>
  outb(COM1+0, c);
801064eb:	8b 45 08             	mov    0x8(%ebp),%eax
801064ee:	0f b6 c0             	movzbl %al,%eax
801064f1:	83 ec 08             	sub    $0x8,%esp
801064f4:	50                   	push   %eax
801064f5:	68 f8 03 00 00       	push   $0x3f8
801064fa:	e8 9b fe ff ff       	call   8010639a <outb>
801064ff:	83 c4 10             	add    $0x10,%esp
80106502:	eb 01                	jmp    80106505 <uartputc+0x63>
    return;
80106504:	90                   	nop
}
80106505:	c9                   	leave  
80106506:	c3                   	ret    

80106507 <uartgetc>:

static int
uartgetc(void)
{
80106507:	55                   	push   %ebp
80106508:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010650a:	a1 78 69 19 80       	mov    0x80196978,%eax
8010650f:	85 c0                	test   %eax,%eax
80106511:	75 07                	jne    8010651a <uartgetc+0x13>
    return -1;
80106513:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106518:	eb 2e                	jmp    80106548 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010651a:	68 fd 03 00 00       	push   $0x3fd
8010651f:	e8 59 fe ff ff       	call   8010637d <inb>
80106524:	83 c4 04             	add    $0x4,%esp
80106527:	0f b6 c0             	movzbl %al,%eax
8010652a:	83 e0 01             	and    $0x1,%eax
8010652d:	85 c0                	test   %eax,%eax
8010652f:	75 07                	jne    80106538 <uartgetc+0x31>
    return -1;
80106531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106536:	eb 10                	jmp    80106548 <uartgetc+0x41>
  return inb(COM1+0);
80106538:	68 f8 03 00 00       	push   $0x3f8
8010653d:	e8 3b fe ff ff       	call   8010637d <inb>
80106542:	83 c4 04             	add    $0x4,%esp
80106545:	0f b6 c0             	movzbl %al,%eax
}
80106548:	c9                   	leave  
80106549:	c3                   	ret    

8010654a <uartintr>:

void
uartintr(void)
{
8010654a:	55                   	push   %ebp
8010654b:	89 e5                	mov    %esp,%ebp
8010654d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106550:	83 ec 0c             	sub    $0xc,%esp
80106553:	68 07 65 10 80       	push   $0x80106507
80106558:	e8 79 a2 ff ff       	call   801007d6 <consoleintr>
8010655d:	83 c4 10             	add    $0x10,%esp
}
80106560:	90                   	nop
80106561:	c9                   	leave  
80106562:	c3                   	ret    

80106563 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $0
80106565:	6a 00                	push   $0x0
  jmp alltraps
80106567:	e9 d8 f8 ff ff       	jmp    80105e44 <alltraps>

8010656c <vector1>:
.globl vector1
vector1:
  pushl $0
8010656c:	6a 00                	push   $0x0
  pushl $1
8010656e:	6a 01                	push   $0x1
  jmp alltraps
80106570:	e9 cf f8 ff ff       	jmp    80105e44 <alltraps>

80106575 <vector2>:
.globl vector2
vector2:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $2
80106577:	6a 02                	push   $0x2
  jmp alltraps
80106579:	e9 c6 f8 ff ff       	jmp    80105e44 <alltraps>

8010657e <vector3>:
.globl vector3
vector3:
  pushl $0
8010657e:	6a 00                	push   $0x0
  pushl $3
80106580:	6a 03                	push   $0x3
  jmp alltraps
80106582:	e9 bd f8 ff ff       	jmp    80105e44 <alltraps>

80106587 <vector4>:
.globl vector4
vector4:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $4
80106589:	6a 04                	push   $0x4
  jmp alltraps
8010658b:	e9 b4 f8 ff ff       	jmp    80105e44 <alltraps>

80106590 <vector5>:
.globl vector5
vector5:
  pushl $0
80106590:	6a 00                	push   $0x0
  pushl $5
80106592:	6a 05                	push   $0x5
  jmp alltraps
80106594:	e9 ab f8 ff ff       	jmp    80105e44 <alltraps>

80106599 <vector6>:
.globl vector6
vector6:
  pushl $0
80106599:	6a 00                	push   $0x0
  pushl $6
8010659b:	6a 06                	push   $0x6
  jmp alltraps
8010659d:	e9 a2 f8 ff ff       	jmp    80105e44 <alltraps>

801065a2 <vector7>:
.globl vector7
vector7:
  pushl $0
801065a2:	6a 00                	push   $0x0
  pushl $7
801065a4:	6a 07                	push   $0x7
  jmp alltraps
801065a6:	e9 99 f8 ff ff       	jmp    80105e44 <alltraps>

801065ab <vector8>:
.globl vector8
vector8:
  pushl $8
801065ab:	6a 08                	push   $0x8
  jmp alltraps
801065ad:	e9 92 f8 ff ff       	jmp    80105e44 <alltraps>

801065b2 <vector9>:
.globl vector9
vector9:
  pushl $0
801065b2:	6a 00                	push   $0x0
  pushl $9
801065b4:	6a 09                	push   $0x9
  jmp alltraps
801065b6:	e9 89 f8 ff ff       	jmp    80105e44 <alltraps>

801065bb <vector10>:
.globl vector10
vector10:
  pushl $10
801065bb:	6a 0a                	push   $0xa
  jmp alltraps
801065bd:	e9 82 f8 ff ff       	jmp    80105e44 <alltraps>

801065c2 <vector11>:
.globl vector11
vector11:
  pushl $11
801065c2:	6a 0b                	push   $0xb
  jmp alltraps
801065c4:	e9 7b f8 ff ff       	jmp    80105e44 <alltraps>

801065c9 <vector12>:
.globl vector12
vector12:
  pushl $12
801065c9:	6a 0c                	push   $0xc
  jmp alltraps
801065cb:	e9 74 f8 ff ff       	jmp    80105e44 <alltraps>

801065d0 <vector13>:
.globl vector13
vector13:
  pushl $13
801065d0:	6a 0d                	push   $0xd
  jmp alltraps
801065d2:	e9 6d f8 ff ff       	jmp    80105e44 <alltraps>

801065d7 <vector14>:
.globl vector14
vector14:
  pushl $14
801065d7:	6a 0e                	push   $0xe
  jmp alltraps
801065d9:	e9 66 f8 ff ff       	jmp    80105e44 <alltraps>

801065de <vector15>:
.globl vector15
vector15:
  pushl $0
801065de:	6a 00                	push   $0x0
  pushl $15
801065e0:	6a 0f                	push   $0xf
  jmp alltraps
801065e2:	e9 5d f8 ff ff       	jmp    80105e44 <alltraps>

801065e7 <vector16>:
.globl vector16
vector16:
  pushl $0
801065e7:	6a 00                	push   $0x0
  pushl $16
801065e9:	6a 10                	push   $0x10
  jmp alltraps
801065eb:	e9 54 f8 ff ff       	jmp    80105e44 <alltraps>

801065f0 <vector17>:
.globl vector17
vector17:
  pushl $17
801065f0:	6a 11                	push   $0x11
  jmp alltraps
801065f2:	e9 4d f8 ff ff       	jmp    80105e44 <alltraps>

801065f7 <vector18>:
.globl vector18
vector18:
  pushl $0
801065f7:	6a 00                	push   $0x0
  pushl $18
801065f9:	6a 12                	push   $0x12
  jmp alltraps
801065fb:	e9 44 f8 ff ff       	jmp    80105e44 <alltraps>

80106600 <vector19>:
.globl vector19
vector19:
  pushl $0
80106600:	6a 00                	push   $0x0
  pushl $19
80106602:	6a 13                	push   $0x13
  jmp alltraps
80106604:	e9 3b f8 ff ff       	jmp    80105e44 <alltraps>

80106609 <vector20>:
.globl vector20
vector20:
  pushl $0
80106609:	6a 00                	push   $0x0
  pushl $20
8010660b:	6a 14                	push   $0x14
  jmp alltraps
8010660d:	e9 32 f8 ff ff       	jmp    80105e44 <alltraps>

80106612 <vector21>:
.globl vector21
vector21:
  pushl $0
80106612:	6a 00                	push   $0x0
  pushl $21
80106614:	6a 15                	push   $0x15
  jmp alltraps
80106616:	e9 29 f8 ff ff       	jmp    80105e44 <alltraps>

8010661b <vector22>:
.globl vector22
vector22:
  pushl $0
8010661b:	6a 00                	push   $0x0
  pushl $22
8010661d:	6a 16                	push   $0x16
  jmp alltraps
8010661f:	e9 20 f8 ff ff       	jmp    80105e44 <alltraps>

80106624 <vector23>:
.globl vector23
vector23:
  pushl $0
80106624:	6a 00                	push   $0x0
  pushl $23
80106626:	6a 17                	push   $0x17
  jmp alltraps
80106628:	e9 17 f8 ff ff       	jmp    80105e44 <alltraps>

8010662d <vector24>:
.globl vector24
vector24:
  pushl $0
8010662d:	6a 00                	push   $0x0
  pushl $24
8010662f:	6a 18                	push   $0x18
  jmp alltraps
80106631:	e9 0e f8 ff ff       	jmp    80105e44 <alltraps>

80106636 <vector25>:
.globl vector25
vector25:
  pushl $0
80106636:	6a 00                	push   $0x0
  pushl $25
80106638:	6a 19                	push   $0x19
  jmp alltraps
8010663a:	e9 05 f8 ff ff       	jmp    80105e44 <alltraps>

8010663f <vector26>:
.globl vector26
vector26:
  pushl $0
8010663f:	6a 00                	push   $0x0
  pushl $26
80106641:	6a 1a                	push   $0x1a
  jmp alltraps
80106643:	e9 fc f7 ff ff       	jmp    80105e44 <alltraps>

80106648 <vector27>:
.globl vector27
vector27:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $27
8010664a:	6a 1b                	push   $0x1b
  jmp alltraps
8010664c:	e9 f3 f7 ff ff       	jmp    80105e44 <alltraps>

80106651 <vector28>:
.globl vector28
vector28:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $28
80106653:	6a 1c                	push   $0x1c
  jmp alltraps
80106655:	e9 ea f7 ff ff       	jmp    80105e44 <alltraps>

8010665a <vector29>:
.globl vector29
vector29:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $29
8010665c:	6a 1d                	push   $0x1d
  jmp alltraps
8010665e:	e9 e1 f7 ff ff       	jmp    80105e44 <alltraps>

80106663 <vector30>:
.globl vector30
vector30:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $30
80106665:	6a 1e                	push   $0x1e
  jmp alltraps
80106667:	e9 d8 f7 ff ff       	jmp    80105e44 <alltraps>

8010666c <vector31>:
.globl vector31
vector31:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $31
8010666e:	6a 1f                	push   $0x1f
  jmp alltraps
80106670:	e9 cf f7 ff ff       	jmp    80105e44 <alltraps>

80106675 <vector32>:
.globl vector32
vector32:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $32
80106677:	6a 20                	push   $0x20
  jmp alltraps
80106679:	e9 c6 f7 ff ff       	jmp    80105e44 <alltraps>

8010667e <vector33>:
.globl vector33
vector33:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $33
80106680:	6a 21                	push   $0x21
  jmp alltraps
80106682:	e9 bd f7 ff ff       	jmp    80105e44 <alltraps>

80106687 <vector34>:
.globl vector34
vector34:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $34
80106689:	6a 22                	push   $0x22
  jmp alltraps
8010668b:	e9 b4 f7 ff ff       	jmp    80105e44 <alltraps>

80106690 <vector35>:
.globl vector35
vector35:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $35
80106692:	6a 23                	push   $0x23
  jmp alltraps
80106694:	e9 ab f7 ff ff       	jmp    80105e44 <alltraps>

80106699 <vector36>:
.globl vector36
vector36:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $36
8010669b:	6a 24                	push   $0x24
  jmp alltraps
8010669d:	e9 a2 f7 ff ff       	jmp    80105e44 <alltraps>

801066a2 <vector37>:
.globl vector37
vector37:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $37
801066a4:	6a 25                	push   $0x25
  jmp alltraps
801066a6:	e9 99 f7 ff ff       	jmp    80105e44 <alltraps>

801066ab <vector38>:
.globl vector38
vector38:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $38
801066ad:	6a 26                	push   $0x26
  jmp alltraps
801066af:	e9 90 f7 ff ff       	jmp    80105e44 <alltraps>

801066b4 <vector39>:
.globl vector39
vector39:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $39
801066b6:	6a 27                	push   $0x27
  jmp alltraps
801066b8:	e9 87 f7 ff ff       	jmp    80105e44 <alltraps>

801066bd <vector40>:
.globl vector40
vector40:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $40
801066bf:	6a 28                	push   $0x28
  jmp alltraps
801066c1:	e9 7e f7 ff ff       	jmp    80105e44 <alltraps>

801066c6 <vector41>:
.globl vector41
vector41:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $41
801066c8:	6a 29                	push   $0x29
  jmp alltraps
801066ca:	e9 75 f7 ff ff       	jmp    80105e44 <alltraps>

801066cf <vector42>:
.globl vector42
vector42:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $42
801066d1:	6a 2a                	push   $0x2a
  jmp alltraps
801066d3:	e9 6c f7 ff ff       	jmp    80105e44 <alltraps>

801066d8 <vector43>:
.globl vector43
vector43:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $43
801066da:	6a 2b                	push   $0x2b
  jmp alltraps
801066dc:	e9 63 f7 ff ff       	jmp    80105e44 <alltraps>

801066e1 <vector44>:
.globl vector44
vector44:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $44
801066e3:	6a 2c                	push   $0x2c
  jmp alltraps
801066e5:	e9 5a f7 ff ff       	jmp    80105e44 <alltraps>

801066ea <vector45>:
.globl vector45
vector45:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $45
801066ec:	6a 2d                	push   $0x2d
  jmp alltraps
801066ee:	e9 51 f7 ff ff       	jmp    80105e44 <alltraps>

801066f3 <vector46>:
.globl vector46
vector46:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $46
801066f5:	6a 2e                	push   $0x2e
  jmp alltraps
801066f7:	e9 48 f7 ff ff       	jmp    80105e44 <alltraps>

801066fc <vector47>:
.globl vector47
vector47:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $47
801066fe:	6a 2f                	push   $0x2f
  jmp alltraps
80106700:	e9 3f f7 ff ff       	jmp    80105e44 <alltraps>

80106705 <vector48>:
.globl vector48
vector48:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $48
80106707:	6a 30                	push   $0x30
  jmp alltraps
80106709:	e9 36 f7 ff ff       	jmp    80105e44 <alltraps>

8010670e <vector49>:
.globl vector49
vector49:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $49
80106710:	6a 31                	push   $0x31
  jmp alltraps
80106712:	e9 2d f7 ff ff       	jmp    80105e44 <alltraps>

80106717 <vector50>:
.globl vector50
vector50:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $50
80106719:	6a 32                	push   $0x32
  jmp alltraps
8010671b:	e9 24 f7 ff ff       	jmp    80105e44 <alltraps>

80106720 <vector51>:
.globl vector51
vector51:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $51
80106722:	6a 33                	push   $0x33
  jmp alltraps
80106724:	e9 1b f7 ff ff       	jmp    80105e44 <alltraps>

80106729 <vector52>:
.globl vector52
vector52:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $52
8010672b:	6a 34                	push   $0x34
  jmp alltraps
8010672d:	e9 12 f7 ff ff       	jmp    80105e44 <alltraps>

80106732 <vector53>:
.globl vector53
vector53:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $53
80106734:	6a 35                	push   $0x35
  jmp alltraps
80106736:	e9 09 f7 ff ff       	jmp    80105e44 <alltraps>

8010673b <vector54>:
.globl vector54
vector54:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $54
8010673d:	6a 36                	push   $0x36
  jmp alltraps
8010673f:	e9 00 f7 ff ff       	jmp    80105e44 <alltraps>

80106744 <vector55>:
.globl vector55
vector55:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $55
80106746:	6a 37                	push   $0x37
  jmp alltraps
80106748:	e9 f7 f6 ff ff       	jmp    80105e44 <alltraps>

8010674d <vector56>:
.globl vector56
vector56:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $56
8010674f:	6a 38                	push   $0x38
  jmp alltraps
80106751:	e9 ee f6 ff ff       	jmp    80105e44 <alltraps>

80106756 <vector57>:
.globl vector57
vector57:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $57
80106758:	6a 39                	push   $0x39
  jmp alltraps
8010675a:	e9 e5 f6 ff ff       	jmp    80105e44 <alltraps>

8010675f <vector58>:
.globl vector58
vector58:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $58
80106761:	6a 3a                	push   $0x3a
  jmp alltraps
80106763:	e9 dc f6 ff ff       	jmp    80105e44 <alltraps>

80106768 <vector59>:
.globl vector59
vector59:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $59
8010676a:	6a 3b                	push   $0x3b
  jmp alltraps
8010676c:	e9 d3 f6 ff ff       	jmp    80105e44 <alltraps>

80106771 <vector60>:
.globl vector60
vector60:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $60
80106773:	6a 3c                	push   $0x3c
  jmp alltraps
80106775:	e9 ca f6 ff ff       	jmp    80105e44 <alltraps>

8010677a <vector61>:
.globl vector61
vector61:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $61
8010677c:	6a 3d                	push   $0x3d
  jmp alltraps
8010677e:	e9 c1 f6 ff ff       	jmp    80105e44 <alltraps>

80106783 <vector62>:
.globl vector62
vector62:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $62
80106785:	6a 3e                	push   $0x3e
  jmp alltraps
80106787:	e9 b8 f6 ff ff       	jmp    80105e44 <alltraps>

8010678c <vector63>:
.globl vector63
vector63:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $63
8010678e:	6a 3f                	push   $0x3f
  jmp alltraps
80106790:	e9 af f6 ff ff       	jmp    80105e44 <alltraps>

80106795 <vector64>:
.globl vector64
vector64:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $64
80106797:	6a 40                	push   $0x40
  jmp alltraps
80106799:	e9 a6 f6 ff ff       	jmp    80105e44 <alltraps>

8010679e <vector65>:
.globl vector65
vector65:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $65
801067a0:	6a 41                	push   $0x41
  jmp alltraps
801067a2:	e9 9d f6 ff ff       	jmp    80105e44 <alltraps>

801067a7 <vector66>:
.globl vector66
vector66:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $66
801067a9:	6a 42                	push   $0x42
  jmp alltraps
801067ab:	e9 94 f6 ff ff       	jmp    80105e44 <alltraps>

801067b0 <vector67>:
.globl vector67
vector67:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $67
801067b2:	6a 43                	push   $0x43
  jmp alltraps
801067b4:	e9 8b f6 ff ff       	jmp    80105e44 <alltraps>

801067b9 <vector68>:
.globl vector68
vector68:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $68
801067bb:	6a 44                	push   $0x44
  jmp alltraps
801067bd:	e9 82 f6 ff ff       	jmp    80105e44 <alltraps>

801067c2 <vector69>:
.globl vector69
vector69:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $69
801067c4:	6a 45                	push   $0x45
  jmp alltraps
801067c6:	e9 79 f6 ff ff       	jmp    80105e44 <alltraps>

801067cb <vector70>:
.globl vector70
vector70:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $70
801067cd:	6a 46                	push   $0x46
  jmp alltraps
801067cf:	e9 70 f6 ff ff       	jmp    80105e44 <alltraps>

801067d4 <vector71>:
.globl vector71
vector71:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $71
801067d6:	6a 47                	push   $0x47
  jmp alltraps
801067d8:	e9 67 f6 ff ff       	jmp    80105e44 <alltraps>

801067dd <vector72>:
.globl vector72
vector72:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $72
801067df:	6a 48                	push   $0x48
  jmp alltraps
801067e1:	e9 5e f6 ff ff       	jmp    80105e44 <alltraps>

801067e6 <vector73>:
.globl vector73
vector73:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $73
801067e8:	6a 49                	push   $0x49
  jmp alltraps
801067ea:	e9 55 f6 ff ff       	jmp    80105e44 <alltraps>

801067ef <vector74>:
.globl vector74
vector74:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $74
801067f1:	6a 4a                	push   $0x4a
  jmp alltraps
801067f3:	e9 4c f6 ff ff       	jmp    80105e44 <alltraps>

801067f8 <vector75>:
.globl vector75
vector75:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $75
801067fa:	6a 4b                	push   $0x4b
  jmp alltraps
801067fc:	e9 43 f6 ff ff       	jmp    80105e44 <alltraps>

80106801 <vector76>:
.globl vector76
vector76:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $76
80106803:	6a 4c                	push   $0x4c
  jmp alltraps
80106805:	e9 3a f6 ff ff       	jmp    80105e44 <alltraps>

8010680a <vector77>:
.globl vector77
vector77:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $77
8010680c:	6a 4d                	push   $0x4d
  jmp alltraps
8010680e:	e9 31 f6 ff ff       	jmp    80105e44 <alltraps>

80106813 <vector78>:
.globl vector78
vector78:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $78
80106815:	6a 4e                	push   $0x4e
  jmp alltraps
80106817:	e9 28 f6 ff ff       	jmp    80105e44 <alltraps>

8010681c <vector79>:
.globl vector79
vector79:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $79
8010681e:	6a 4f                	push   $0x4f
  jmp alltraps
80106820:	e9 1f f6 ff ff       	jmp    80105e44 <alltraps>

80106825 <vector80>:
.globl vector80
vector80:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $80
80106827:	6a 50                	push   $0x50
  jmp alltraps
80106829:	e9 16 f6 ff ff       	jmp    80105e44 <alltraps>

8010682e <vector81>:
.globl vector81
vector81:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $81
80106830:	6a 51                	push   $0x51
  jmp alltraps
80106832:	e9 0d f6 ff ff       	jmp    80105e44 <alltraps>

80106837 <vector82>:
.globl vector82
vector82:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $82
80106839:	6a 52                	push   $0x52
  jmp alltraps
8010683b:	e9 04 f6 ff ff       	jmp    80105e44 <alltraps>

80106840 <vector83>:
.globl vector83
vector83:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $83
80106842:	6a 53                	push   $0x53
  jmp alltraps
80106844:	e9 fb f5 ff ff       	jmp    80105e44 <alltraps>

80106849 <vector84>:
.globl vector84
vector84:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $84
8010684b:	6a 54                	push   $0x54
  jmp alltraps
8010684d:	e9 f2 f5 ff ff       	jmp    80105e44 <alltraps>

80106852 <vector85>:
.globl vector85
vector85:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $85
80106854:	6a 55                	push   $0x55
  jmp alltraps
80106856:	e9 e9 f5 ff ff       	jmp    80105e44 <alltraps>

8010685b <vector86>:
.globl vector86
vector86:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $86
8010685d:	6a 56                	push   $0x56
  jmp alltraps
8010685f:	e9 e0 f5 ff ff       	jmp    80105e44 <alltraps>

80106864 <vector87>:
.globl vector87
vector87:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $87
80106866:	6a 57                	push   $0x57
  jmp alltraps
80106868:	e9 d7 f5 ff ff       	jmp    80105e44 <alltraps>

8010686d <vector88>:
.globl vector88
vector88:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $88
8010686f:	6a 58                	push   $0x58
  jmp alltraps
80106871:	e9 ce f5 ff ff       	jmp    80105e44 <alltraps>

80106876 <vector89>:
.globl vector89
vector89:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $89
80106878:	6a 59                	push   $0x59
  jmp alltraps
8010687a:	e9 c5 f5 ff ff       	jmp    80105e44 <alltraps>

8010687f <vector90>:
.globl vector90
vector90:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $90
80106881:	6a 5a                	push   $0x5a
  jmp alltraps
80106883:	e9 bc f5 ff ff       	jmp    80105e44 <alltraps>

80106888 <vector91>:
.globl vector91
vector91:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $91
8010688a:	6a 5b                	push   $0x5b
  jmp alltraps
8010688c:	e9 b3 f5 ff ff       	jmp    80105e44 <alltraps>

80106891 <vector92>:
.globl vector92
vector92:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $92
80106893:	6a 5c                	push   $0x5c
  jmp alltraps
80106895:	e9 aa f5 ff ff       	jmp    80105e44 <alltraps>

8010689a <vector93>:
.globl vector93
vector93:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $93
8010689c:	6a 5d                	push   $0x5d
  jmp alltraps
8010689e:	e9 a1 f5 ff ff       	jmp    80105e44 <alltraps>

801068a3 <vector94>:
.globl vector94
vector94:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $94
801068a5:	6a 5e                	push   $0x5e
  jmp alltraps
801068a7:	e9 98 f5 ff ff       	jmp    80105e44 <alltraps>

801068ac <vector95>:
.globl vector95
vector95:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $95
801068ae:	6a 5f                	push   $0x5f
  jmp alltraps
801068b0:	e9 8f f5 ff ff       	jmp    80105e44 <alltraps>

801068b5 <vector96>:
.globl vector96
vector96:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $96
801068b7:	6a 60                	push   $0x60
  jmp alltraps
801068b9:	e9 86 f5 ff ff       	jmp    80105e44 <alltraps>

801068be <vector97>:
.globl vector97
vector97:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $97
801068c0:	6a 61                	push   $0x61
  jmp alltraps
801068c2:	e9 7d f5 ff ff       	jmp    80105e44 <alltraps>

801068c7 <vector98>:
.globl vector98
vector98:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $98
801068c9:	6a 62                	push   $0x62
  jmp alltraps
801068cb:	e9 74 f5 ff ff       	jmp    80105e44 <alltraps>

801068d0 <vector99>:
.globl vector99
vector99:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $99
801068d2:	6a 63                	push   $0x63
  jmp alltraps
801068d4:	e9 6b f5 ff ff       	jmp    80105e44 <alltraps>

801068d9 <vector100>:
.globl vector100
vector100:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $100
801068db:	6a 64                	push   $0x64
  jmp alltraps
801068dd:	e9 62 f5 ff ff       	jmp    80105e44 <alltraps>

801068e2 <vector101>:
.globl vector101
vector101:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $101
801068e4:	6a 65                	push   $0x65
  jmp alltraps
801068e6:	e9 59 f5 ff ff       	jmp    80105e44 <alltraps>

801068eb <vector102>:
.globl vector102
vector102:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $102
801068ed:	6a 66                	push   $0x66
  jmp alltraps
801068ef:	e9 50 f5 ff ff       	jmp    80105e44 <alltraps>

801068f4 <vector103>:
.globl vector103
vector103:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $103
801068f6:	6a 67                	push   $0x67
  jmp alltraps
801068f8:	e9 47 f5 ff ff       	jmp    80105e44 <alltraps>

801068fd <vector104>:
.globl vector104
vector104:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $104
801068ff:	6a 68                	push   $0x68
  jmp alltraps
80106901:	e9 3e f5 ff ff       	jmp    80105e44 <alltraps>

80106906 <vector105>:
.globl vector105
vector105:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $105
80106908:	6a 69                	push   $0x69
  jmp alltraps
8010690a:	e9 35 f5 ff ff       	jmp    80105e44 <alltraps>

8010690f <vector106>:
.globl vector106
vector106:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $106
80106911:	6a 6a                	push   $0x6a
  jmp alltraps
80106913:	e9 2c f5 ff ff       	jmp    80105e44 <alltraps>

80106918 <vector107>:
.globl vector107
vector107:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $107
8010691a:	6a 6b                	push   $0x6b
  jmp alltraps
8010691c:	e9 23 f5 ff ff       	jmp    80105e44 <alltraps>

80106921 <vector108>:
.globl vector108
vector108:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $108
80106923:	6a 6c                	push   $0x6c
  jmp alltraps
80106925:	e9 1a f5 ff ff       	jmp    80105e44 <alltraps>

8010692a <vector109>:
.globl vector109
vector109:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $109
8010692c:	6a 6d                	push   $0x6d
  jmp alltraps
8010692e:	e9 11 f5 ff ff       	jmp    80105e44 <alltraps>

80106933 <vector110>:
.globl vector110
vector110:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $110
80106935:	6a 6e                	push   $0x6e
  jmp alltraps
80106937:	e9 08 f5 ff ff       	jmp    80105e44 <alltraps>

8010693c <vector111>:
.globl vector111
vector111:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $111
8010693e:	6a 6f                	push   $0x6f
  jmp alltraps
80106940:	e9 ff f4 ff ff       	jmp    80105e44 <alltraps>

80106945 <vector112>:
.globl vector112
vector112:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $112
80106947:	6a 70                	push   $0x70
  jmp alltraps
80106949:	e9 f6 f4 ff ff       	jmp    80105e44 <alltraps>

8010694e <vector113>:
.globl vector113
vector113:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $113
80106950:	6a 71                	push   $0x71
  jmp alltraps
80106952:	e9 ed f4 ff ff       	jmp    80105e44 <alltraps>

80106957 <vector114>:
.globl vector114
vector114:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $114
80106959:	6a 72                	push   $0x72
  jmp alltraps
8010695b:	e9 e4 f4 ff ff       	jmp    80105e44 <alltraps>

80106960 <vector115>:
.globl vector115
vector115:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $115
80106962:	6a 73                	push   $0x73
  jmp alltraps
80106964:	e9 db f4 ff ff       	jmp    80105e44 <alltraps>

80106969 <vector116>:
.globl vector116
vector116:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $116
8010696b:	6a 74                	push   $0x74
  jmp alltraps
8010696d:	e9 d2 f4 ff ff       	jmp    80105e44 <alltraps>

80106972 <vector117>:
.globl vector117
vector117:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $117
80106974:	6a 75                	push   $0x75
  jmp alltraps
80106976:	e9 c9 f4 ff ff       	jmp    80105e44 <alltraps>

8010697b <vector118>:
.globl vector118
vector118:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $118
8010697d:	6a 76                	push   $0x76
  jmp alltraps
8010697f:	e9 c0 f4 ff ff       	jmp    80105e44 <alltraps>

80106984 <vector119>:
.globl vector119
vector119:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $119
80106986:	6a 77                	push   $0x77
  jmp alltraps
80106988:	e9 b7 f4 ff ff       	jmp    80105e44 <alltraps>

8010698d <vector120>:
.globl vector120
vector120:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $120
8010698f:	6a 78                	push   $0x78
  jmp alltraps
80106991:	e9 ae f4 ff ff       	jmp    80105e44 <alltraps>

80106996 <vector121>:
.globl vector121
vector121:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $121
80106998:	6a 79                	push   $0x79
  jmp alltraps
8010699a:	e9 a5 f4 ff ff       	jmp    80105e44 <alltraps>

8010699f <vector122>:
.globl vector122
vector122:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $122
801069a1:	6a 7a                	push   $0x7a
  jmp alltraps
801069a3:	e9 9c f4 ff ff       	jmp    80105e44 <alltraps>

801069a8 <vector123>:
.globl vector123
vector123:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $123
801069aa:	6a 7b                	push   $0x7b
  jmp alltraps
801069ac:	e9 93 f4 ff ff       	jmp    80105e44 <alltraps>

801069b1 <vector124>:
.globl vector124
vector124:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $124
801069b3:	6a 7c                	push   $0x7c
  jmp alltraps
801069b5:	e9 8a f4 ff ff       	jmp    80105e44 <alltraps>

801069ba <vector125>:
.globl vector125
vector125:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $125
801069bc:	6a 7d                	push   $0x7d
  jmp alltraps
801069be:	e9 81 f4 ff ff       	jmp    80105e44 <alltraps>

801069c3 <vector126>:
.globl vector126
vector126:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $126
801069c5:	6a 7e                	push   $0x7e
  jmp alltraps
801069c7:	e9 78 f4 ff ff       	jmp    80105e44 <alltraps>

801069cc <vector127>:
.globl vector127
vector127:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $127
801069ce:	6a 7f                	push   $0x7f
  jmp alltraps
801069d0:	e9 6f f4 ff ff       	jmp    80105e44 <alltraps>

801069d5 <vector128>:
.globl vector128
vector128:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $128
801069d7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801069dc:	e9 63 f4 ff ff       	jmp    80105e44 <alltraps>

801069e1 <vector129>:
.globl vector129
vector129:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $129
801069e3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801069e8:	e9 57 f4 ff ff       	jmp    80105e44 <alltraps>

801069ed <vector130>:
.globl vector130
vector130:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $130
801069ef:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801069f4:	e9 4b f4 ff ff       	jmp    80105e44 <alltraps>

801069f9 <vector131>:
.globl vector131
vector131:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $131
801069fb:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106a00:	e9 3f f4 ff ff       	jmp    80105e44 <alltraps>

80106a05 <vector132>:
.globl vector132
vector132:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $132
80106a07:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106a0c:	e9 33 f4 ff ff       	jmp    80105e44 <alltraps>

80106a11 <vector133>:
.globl vector133
vector133:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $133
80106a13:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106a18:	e9 27 f4 ff ff       	jmp    80105e44 <alltraps>

80106a1d <vector134>:
.globl vector134
vector134:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $134
80106a1f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106a24:	e9 1b f4 ff ff       	jmp    80105e44 <alltraps>

80106a29 <vector135>:
.globl vector135
vector135:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $135
80106a2b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106a30:	e9 0f f4 ff ff       	jmp    80105e44 <alltraps>

80106a35 <vector136>:
.globl vector136
vector136:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $136
80106a37:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106a3c:	e9 03 f4 ff ff       	jmp    80105e44 <alltraps>

80106a41 <vector137>:
.globl vector137
vector137:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $137
80106a43:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106a48:	e9 f7 f3 ff ff       	jmp    80105e44 <alltraps>

80106a4d <vector138>:
.globl vector138
vector138:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $138
80106a4f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106a54:	e9 eb f3 ff ff       	jmp    80105e44 <alltraps>

80106a59 <vector139>:
.globl vector139
vector139:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $139
80106a5b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106a60:	e9 df f3 ff ff       	jmp    80105e44 <alltraps>

80106a65 <vector140>:
.globl vector140
vector140:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $140
80106a67:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106a6c:	e9 d3 f3 ff ff       	jmp    80105e44 <alltraps>

80106a71 <vector141>:
.globl vector141
vector141:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $141
80106a73:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106a78:	e9 c7 f3 ff ff       	jmp    80105e44 <alltraps>

80106a7d <vector142>:
.globl vector142
vector142:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $142
80106a7f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106a84:	e9 bb f3 ff ff       	jmp    80105e44 <alltraps>

80106a89 <vector143>:
.globl vector143
vector143:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $143
80106a8b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106a90:	e9 af f3 ff ff       	jmp    80105e44 <alltraps>

80106a95 <vector144>:
.globl vector144
vector144:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $144
80106a97:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106a9c:	e9 a3 f3 ff ff       	jmp    80105e44 <alltraps>

80106aa1 <vector145>:
.globl vector145
vector145:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $145
80106aa3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106aa8:	e9 97 f3 ff ff       	jmp    80105e44 <alltraps>

80106aad <vector146>:
.globl vector146
vector146:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $146
80106aaf:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ab4:	e9 8b f3 ff ff       	jmp    80105e44 <alltraps>

80106ab9 <vector147>:
.globl vector147
vector147:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $147
80106abb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106ac0:	e9 7f f3 ff ff       	jmp    80105e44 <alltraps>

80106ac5 <vector148>:
.globl vector148
vector148:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $148
80106ac7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106acc:	e9 73 f3 ff ff       	jmp    80105e44 <alltraps>

80106ad1 <vector149>:
.globl vector149
vector149:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $149
80106ad3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106ad8:	e9 67 f3 ff ff       	jmp    80105e44 <alltraps>

80106add <vector150>:
.globl vector150
vector150:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $150
80106adf:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106ae4:	e9 5b f3 ff ff       	jmp    80105e44 <alltraps>

80106ae9 <vector151>:
.globl vector151
vector151:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $151
80106aeb:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106af0:	e9 4f f3 ff ff       	jmp    80105e44 <alltraps>

80106af5 <vector152>:
.globl vector152
vector152:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $152
80106af7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106afc:	e9 43 f3 ff ff       	jmp    80105e44 <alltraps>

80106b01 <vector153>:
.globl vector153
vector153:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $153
80106b03:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106b08:	e9 37 f3 ff ff       	jmp    80105e44 <alltraps>

80106b0d <vector154>:
.globl vector154
vector154:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $154
80106b0f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106b14:	e9 2b f3 ff ff       	jmp    80105e44 <alltraps>

80106b19 <vector155>:
.globl vector155
vector155:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $155
80106b1b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106b20:	e9 1f f3 ff ff       	jmp    80105e44 <alltraps>

80106b25 <vector156>:
.globl vector156
vector156:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $156
80106b27:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106b2c:	e9 13 f3 ff ff       	jmp    80105e44 <alltraps>

80106b31 <vector157>:
.globl vector157
vector157:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $157
80106b33:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106b38:	e9 07 f3 ff ff       	jmp    80105e44 <alltraps>

80106b3d <vector158>:
.globl vector158
vector158:
  pushl $0
80106b3d:	6a 00                	push   $0x0
  pushl $158
80106b3f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106b44:	e9 fb f2 ff ff       	jmp    80105e44 <alltraps>

80106b49 <vector159>:
.globl vector159
vector159:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $159
80106b4b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106b50:	e9 ef f2 ff ff       	jmp    80105e44 <alltraps>

80106b55 <vector160>:
.globl vector160
vector160:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $160
80106b57:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106b5c:	e9 e3 f2 ff ff       	jmp    80105e44 <alltraps>

80106b61 <vector161>:
.globl vector161
vector161:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $161
80106b63:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106b68:	e9 d7 f2 ff ff       	jmp    80105e44 <alltraps>

80106b6d <vector162>:
.globl vector162
vector162:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $162
80106b6f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106b74:	e9 cb f2 ff ff       	jmp    80105e44 <alltraps>

80106b79 <vector163>:
.globl vector163
vector163:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $163
80106b7b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106b80:	e9 bf f2 ff ff       	jmp    80105e44 <alltraps>

80106b85 <vector164>:
.globl vector164
vector164:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $164
80106b87:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106b8c:	e9 b3 f2 ff ff       	jmp    80105e44 <alltraps>

80106b91 <vector165>:
.globl vector165
vector165:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $165
80106b93:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106b98:	e9 a7 f2 ff ff       	jmp    80105e44 <alltraps>

80106b9d <vector166>:
.globl vector166
vector166:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $166
80106b9f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ba4:	e9 9b f2 ff ff       	jmp    80105e44 <alltraps>

80106ba9 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $167
80106bab:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106bb0:	e9 8f f2 ff ff       	jmp    80105e44 <alltraps>

80106bb5 <vector168>:
.globl vector168
vector168:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $168
80106bb7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106bbc:	e9 83 f2 ff ff       	jmp    80105e44 <alltraps>

80106bc1 <vector169>:
.globl vector169
vector169:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $169
80106bc3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106bc8:	e9 77 f2 ff ff       	jmp    80105e44 <alltraps>

80106bcd <vector170>:
.globl vector170
vector170:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $170
80106bcf:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106bd4:	e9 6b f2 ff ff       	jmp    80105e44 <alltraps>

80106bd9 <vector171>:
.globl vector171
vector171:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $171
80106bdb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106be0:	e9 5f f2 ff ff       	jmp    80105e44 <alltraps>

80106be5 <vector172>:
.globl vector172
vector172:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $172
80106be7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106bec:	e9 53 f2 ff ff       	jmp    80105e44 <alltraps>

80106bf1 <vector173>:
.globl vector173
vector173:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $173
80106bf3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106bf8:	e9 47 f2 ff ff       	jmp    80105e44 <alltraps>

80106bfd <vector174>:
.globl vector174
vector174:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $174
80106bff:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106c04:	e9 3b f2 ff ff       	jmp    80105e44 <alltraps>

80106c09 <vector175>:
.globl vector175
vector175:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $175
80106c0b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106c10:	e9 2f f2 ff ff       	jmp    80105e44 <alltraps>

80106c15 <vector176>:
.globl vector176
vector176:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $176
80106c17:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106c1c:	e9 23 f2 ff ff       	jmp    80105e44 <alltraps>

80106c21 <vector177>:
.globl vector177
vector177:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $177
80106c23:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106c28:	e9 17 f2 ff ff       	jmp    80105e44 <alltraps>

80106c2d <vector178>:
.globl vector178
vector178:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $178
80106c2f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106c34:	e9 0b f2 ff ff       	jmp    80105e44 <alltraps>

80106c39 <vector179>:
.globl vector179
vector179:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $179
80106c3b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106c40:	e9 ff f1 ff ff       	jmp    80105e44 <alltraps>

80106c45 <vector180>:
.globl vector180
vector180:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $180
80106c47:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106c4c:	e9 f3 f1 ff ff       	jmp    80105e44 <alltraps>

80106c51 <vector181>:
.globl vector181
vector181:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $181
80106c53:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106c58:	e9 e7 f1 ff ff       	jmp    80105e44 <alltraps>

80106c5d <vector182>:
.globl vector182
vector182:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $182
80106c5f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106c64:	e9 db f1 ff ff       	jmp    80105e44 <alltraps>

80106c69 <vector183>:
.globl vector183
vector183:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $183
80106c6b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106c70:	e9 cf f1 ff ff       	jmp    80105e44 <alltraps>

80106c75 <vector184>:
.globl vector184
vector184:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $184
80106c77:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106c7c:	e9 c3 f1 ff ff       	jmp    80105e44 <alltraps>

80106c81 <vector185>:
.globl vector185
vector185:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $185
80106c83:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106c88:	e9 b7 f1 ff ff       	jmp    80105e44 <alltraps>

80106c8d <vector186>:
.globl vector186
vector186:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $186
80106c8f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106c94:	e9 ab f1 ff ff       	jmp    80105e44 <alltraps>

80106c99 <vector187>:
.globl vector187
vector187:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $187
80106c9b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ca0:	e9 9f f1 ff ff       	jmp    80105e44 <alltraps>

80106ca5 <vector188>:
.globl vector188
vector188:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $188
80106ca7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106cac:	e9 93 f1 ff ff       	jmp    80105e44 <alltraps>

80106cb1 <vector189>:
.globl vector189
vector189:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $189
80106cb3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106cb8:	e9 87 f1 ff ff       	jmp    80105e44 <alltraps>

80106cbd <vector190>:
.globl vector190
vector190:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $190
80106cbf:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106cc4:	e9 7b f1 ff ff       	jmp    80105e44 <alltraps>

80106cc9 <vector191>:
.globl vector191
vector191:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $191
80106ccb:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106cd0:	e9 6f f1 ff ff       	jmp    80105e44 <alltraps>

80106cd5 <vector192>:
.globl vector192
vector192:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $192
80106cd7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106cdc:	e9 63 f1 ff ff       	jmp    80105e44 <alltraps>

80106ce1 <vector193>:
.globl vector193
vector193:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $193
80106ce3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ce8:	e9 57 f1 ff ff       	jmp    80105e44 <alltraps>

80106ced <vector194>:
.globl vector194
vector194:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $194
80106cef:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106cf4:	e9 4b f1 ff ff       	jmp    80105e44 <alltraps>

80106cf9 <vector195>:
.globl vector195
vector195:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $195
80106cfb:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106d00:	e9 3f f1 ff ff       	jmp    80105e44 <alltraps>

80106d05 <vector196>:
.globl vector196
vector196:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $196
80106d07:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106d0c:	e9 33 f1 ff ff       	jmp    80105e44 <alltraps>

80106d11 <vector197>:
.globl vector197
vector197:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $197
80106d13:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106d18:	e9 27 f1 ff ff       	jmp    80105e44 <alltraps>

80106d1d <vector198>:
.globl vector198
vector198:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $198
80106d1f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106d24:	e9 1b f1 ff ff       	jmp    80105e44 <alltraps>

80106d29 <vector199>:
.globl vector199
vector199:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $199
80106d2b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106d30:	e9 0f f1 ff ff       	jmp    80105e44 <alltraps>

80106d35 <vector200>:
.globl vector200
vector200:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $200
80106d37:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106d3c:	e9 03 f1 ff ff       	jmp    80105e44 <alltraps>

80106d41 <vector201>:
.globl vector201
vector201:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $201
80106d43:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106d48:	e9 f7 f0 ff ff       	jmp    80105e44 <alltraps>

80106d4d <vector202>:
.globl vector202
vector202:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $202
80106d4f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106d54:	e9 eb f0 ff ff       	jmp    80105e44 <alltraps>

80106d59 <vector203>:
.globl vector203
vector203:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $203
80106d5b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106d60:	e9 df f0 ff ff       	jmp    80105e44 <alltraps>

80106d65 <vector204>:
.globl vector204
vector204:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $204
80106d67:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106d6c:	e9 d3 f0 ff ff       	jmp    80105e44 <alltraps>

80106d71 <vector205>:
.globl vector205
vector205:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $205
80106d73:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106d78:	e9 c7 f0 ff ff       	jmp    80105e44 <alltraps>

80106d7d <vector206>:
.globl vector206
vector206:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $206
80106d7f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106d84:	e9 bb f0 ff ff       	jmp    80105e44 <alltraps>

80106d89 <vector207>:
.globl vector207
vector207:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $207
80106d8b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106d90:	e9 af f0 ff ff       	jmp    80105e44 <alltraps>

80106d95 <vector208>:
.globl vector208
vector208:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $208
80106d97:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106d9c:	e9 a3 f0 ff ff       	jmp    80105e44 <alltraps>

80106da1 <vector209>:
.globl vector209
vector209:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $209
80106da3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106da8:	e9 97 f0 ff ff       	jmp    80105e44 <alltraps>

80106dad <vector210>:
.globl vector210
vector210:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $210
80106daf:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106db4:	e9 8b f0 ff ff       	jmp    80105e44 <alltraps>

80106db9 <vector211>:
.globl vector211
vector211:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $211
80106dbb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106dc0:	e9 7f f0 ff ff       	jmp    80105e44 <alltraps>

80106dc5 <vector212>:
.globl vector212
vector212:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $212
80106dc7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106dcc:	e9 73 f0 ff ff       	jmp    80105e44 <alltraps>

80106dd1 <vector213>:
.globl vector213
vector213:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $213
80106dd3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106dd8:	e9 67 f0 ff ff       	jmp    80105e44 <alltraps>

80106ddd <vector214>:
.globl vector214
vector214:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $214
80106ddf:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106de4:	e9 5b f0 ff ff       	jmp    80105e44 <alltraps>

80106de9 <vector215>:
.globl vector215
vector215:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $215
80106deb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106df0:	e9 4f f0 ff ff       	jmp    80105e44 <alltraps>

80106df5 <vector216>:
.globl vector216
vector216:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $216
80106df7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106dfc:	e9 43 f0 ff ff       	jmp    80105e44 <alltraps>

80106e01 <vector217>:
.globl vector217
vector217:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $217
80106e03:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106e08:	e9 37 f0 ff ff       	jmp    80105e44 <alltraps>

80106e0d <vector218>:
.globl vector218
vector218:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $218
80106e0f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106e14:	e9 2b f0 ff ff       	jmp    80105e44 <alltraps>

80106e19 <vector219>:
.globl vector219
vector219:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $219
80106e1b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106e20:	e9 1f f0 ff ff       	jmp    80105e44 <alltraps>

80106e25 <vector220>:
.globl vector220
vector220:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $220
80106e27:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106e2c:	e9 13 f0 ff ff       	jmp    80105e44 <alltraps>

80106e31 <vector221>:
.globl vector221
vector221:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $221
80106e33:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106e38:	e9 07 f0 ff ff       	jmp    80105e44 <alltraps>

80106e3d <vector222>:
.globl vector222
vector222:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $222
80106e3f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106e44:	e9 fb ef ff ff       	jmp    80105e44 <alltraps>

80106e49 <vector223>:
.globl vector223
vector223:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $223
80106e4b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106e50:	e9 ef ef ff ff       	jmp    80105e44 <alltraps>

80106e55 <vector224>:
.globl vector224
vector224:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $224
80106e57:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106e5c:	e9 e3 ef ff ff       	jmp    80105e44 <alltraps>

80106e61 <vector225>:
.globl vector225
vector225:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $225
80106e63:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106e68:	e9 d7 ef ff ff       	jmp    80105e44 <alltraps>

80106e6d <vector226>:
.globl vector226
vector226:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $226
80106e6f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106e74:	e9 cb ef ff ff       	jmp    80105e44 <alltraps>

80106e79 <vector227>:
.globl vector227
vector227:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $227
80106e7b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106e80:	e9 bf ef ff ff       	jmp    80105e44 <alltraps>

80106e85 <vector228>:
.globl vector228
vector228:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $228
80106e87:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106e8c:	e9 b3 ef ff ff       	jmp    80105e44 <alltraps>

80106e91 <vector229>:
.globl vector229
vector229:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $229
80106e93:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106e98:	e9 a7 ef ff ff       	jmp    80105e44 <alltraps>

80106e9d <vector230>:
.globl vector230
vector230:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $230
80106e9f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106ea4:	e9 9b ef ff ff       	jmp    80105e44 <alltraps>

80106ea9 <vector231>:
.globl vector231
vector231:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $231
80106eab:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106eb0:	e9 8f ef ff ff       	jmp    80105e44 <alltraps>

80106eb5 <vector232>:
.globl vector232
vector232:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $232
80106eb7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106ebc:	e9 83 ef ff ff       	jmp    80105e44 <alltraps>

80106ec1 <vector233>:
.globl vector233
vector233:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $233
80106ec3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106ec8:	e9 77 ef ff ff       	jmp    80105e44 <alltraps>

80106ecd <vector234>:
.globl vector234
vector234:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $234
80106ecf:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106ed4:	e9 6b ef ff ff       	jmp    80105e44 <alltraps>

80106ed9 <vector235>:
.globl vector235
vector235:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $235
80106edb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106ee0:	e9 5f ef ff ff       	jmp    80105e44 <alltraps>

80106ee5 <vector236>:
.globl vector236
vector236:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $236
80106ee7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106eec:	e9 53 ef ff ff       	jmp    80105e44 <alltraps>

80106ef1 <vector237>:
.globl vector237
vector237:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $237
80106ef3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106ef8:	e9 47 ef ff ff       	jmp    80105e44 <alltraps>

80106efd <vector238>:
.globl vector238
vector238:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $238
80106eff:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106f04:	e9 3b ef ff ff       	jmp    80105e44 <alltraps>

80106f09 <vector239>:
.globl vector239
vector239:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $239
80106f0b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106f10:	e9 2f ef ff ff       	jmp    80105e44 <alltraps>

80106f15 <vector240>:
.globl vector240
vector240:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $240
80106f17:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106f1c:	e9 23 ef ff ff       	jmp    80105e44 <alltraps>

80106f21 <vector241>:
.globl vector241
vector241:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $241
80106f23:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106f28:	e9 17 ef ff ff       	jmp    80105e44 <alltraps>

80106f2d <vector242>:
.globl vector242
vector242:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $242
80106f2f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106f34:	e9 0b ef ff ff       	jmp    80105e44 <alltraps>

80106f39 <vector243>:
.globl vector243
vector243:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $243
80106f3b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106f40:	e9 ff ee ff ff       	jmp    80105e44 <alltraps>

80106f45 <vector244>:
.globl vector244
vector244:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $244
80106f47:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106f4c:	e9 f3 ee ff ff       	jmp    80105e44 <alltraps>

80106f51 <vector245>:
.globl vector245
vector245:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $245
80106f53:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106f58:	e9 e7 ee ff ff       	jmp    80105e44 <alltraps>

80106f5d <vector246>:
.globl vector246
vector246:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $246
80106f5f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106f64:	e9 db ee ff ff       	jmp    80105e44 <alltraps>

80106f69 <vector247>:
.globl vector247
vector247:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $247
80106f6b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106f70:	e9 cf ee ff ff       	jmp    80105e44 <alltraps>

80106f75 <vector248>:
.globl vector248
vector248:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $248
80106f77:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106f7c:	e9 c3 ee ff ff       	jmp    80105e44 <alltraps>

80106f81 <vector249>:
.globl vector249
vector249:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $249
80106f83:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106f88:	e9 b7 ee ff ff       	jmp    80105e44 <alltraps>

80106f8d <vector250>:
.globl vector250
vector250:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $250
80106f8f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106f94:	e9 ab ee ff ff       	jmp    80105e44 <alltraps>

80106f99 <vector251>:
.globl vector251
vector251:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $251
80106f9b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106fa0:	e9 9f ee ff ff       	jmp    80105e44 <alltraps>

80106fa5 <vector252>:
.globl vector252
vector252:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $252
80106fa7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106fac:	e9 93 ee ff ff       	jmp    80105e44 <alltraps>

80106fb1 <vector253>:
.globl vector253
vector253:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $253
80106fb3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106fb8:	e9 87 ee ff ff       	jmp    80105e44 <alltraps>

80106fbd <vector254>:
.globl vector254
vector254:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $254
80106fbf:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106fc4:	e9 7b ee ff ff       	jmp    80105e44 <alltraps>

80106fc9 <vector255>:
.globl vector255
vector255:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $255
80106fcb:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106fd0:	e9 6f ee ff ff       	jmp    80105e44 <alltraps>

80106fd5 <lgdt>:
{
80106fd5:	55                   	push   %ebp
80106fd6:	89 e5                	mov    %esp,%ebp
80106fd8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fde:	83 e8 01             	sub    $0x1,%eax
80106fe1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80106fe8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106fec:	8b 45 08             	mov    0x8(%ebp),%eax
80106fef:	c1 e8 10             	shr    $0x10,%eax
80106ff2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106ff6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ff9:	0f 01 10             	lgdtl  (%eax)
}
80106ffc:	90                   	nop
80106ffd:	c9                   	leave  
80106ffe:	c3                   	ret    

80106fff <ltr>:
{
80106fff:	55                   	push   %ebp
80107000:	89 e5                	mov    %esp,%ebp
80107002:	83 ec 04             	sub    $0x4,%esp
80107005:	8b 45 08             	mov    0x8(%ebp),%eax
80107008:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010700c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107010:	0f 00 d8             	ltr    %ax
}
80107013:	90                   	nop
80107014:	c9                   	leave  
80107015:	c3                   	ret    

80107016 <lcr3>:
{
80107016:	55                   	push   %ebp
80107017:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107019:	8b 45 08             	mov    0x8(%ebp),%eax
8010701c:	0f 22 d8             	mov    %eax,%cr3
}
8010701f:	90                   	nop
80107020:	5d                   	pop    %ebp
80107021:	c3                   	ret    

80107022 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107022:	55                   	push   %ebp
80107023:	89 e5                	mov    %esp,%ebp
80107025:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107028:	e8 71 c9 ff ff       	call   8010399e <cpuid>
8010702d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107033:	05 80 69 19 80       	add    $0x80196980,%eax
80107038:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010703b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107047:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010704d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107050:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107057:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010705b:	83 e2 f0             	and    $0xfffffff0,%edx
8010705e:	83 ca 0a             	or     $0xa,%edx
80107061:	88 50 7d             	mov    %dl,0x7d(%eax)
80107064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107067:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010706b:	83 ca 10             	or     $0x10,%edx
8010706e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107074:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107078:	83 e2 9f             	and    $0xffffff9f,%edx
8010707b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010707e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107081:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107085:	83 ca 80             	or     $0xffffff80,%edx
80107088:	88 50 7d             	mov    %dl,0x7d(%eax)
8010708b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107092:	83 ca 0f             	or     $0xf,%edx
80107095:	88 50 7e             	mov    %dl,0x7e(%eax)
80107098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010709f:	83 e2 ef             	and    $0xffffffef,%edx
801070a2:	88 50 7e             	mov    %dl,0x7e(%eax)
801070a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070ac:	83 e2 df             	and    $0xffffffdf,%edx
801070af:	88 50 7e             	mov    %dl,0x7e(%eax)
801070b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070b9:	83 ca 40             	or     $0x40,%edx
801070bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801070bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070c6:	83 ca 80             	or     $0xffffff80,%edx
801070c9:	88 50 7e             	mov    %dl,0x7e(%eax)
801070cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cf:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801070d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801070dd:	ff ff 
801070df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801070e9:	00 00 
801070eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ee:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801070f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801070ff:	83 e2 f0             	and    $0xfffffff0,%edx
80107102:	83 ca 02             	or     $0x2,%edx
80107105:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010710b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107115:	83 ca 10             	or     $0x10,%edx
80107118:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010711e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107121:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107128:	83 e2 9f             	and    $0xffffff9f,%edx
8010712b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107134:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010713b:	83 ca 80             	or     $0xffffff80,%edx
8010713e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107147:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010714e:	83 ca 0f             	or     $0xf,%edx
80107151:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107161:	83 e2 ef             	and    $0xffffffef,%edx
80107164:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010716a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107174:	83 e2 df             	and    $0xffffffdf,%edx
80107177:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010717d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107180:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107187:	83 ca 40             	or     $0x40,%edx
8010718a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107193:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010719a:	83 ca 80             	or     $0xffffff80,%edx
8010719d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801071ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b0:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801071b7:	ff ff 
801071b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bc:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801071c3:	00 00 
801071c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c8:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801071cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801071d9:	83 e2 f0             	and    $0xfffffff0,%edx
801071dc:	83 ca 0a             	or     $0xa,%edx
801071df:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801071e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801071ef:	83 ca 10             	or     $0x10,%edx
801071f2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801071f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107202:	83 ca 60             	or     $0x60,%edx
80107205:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010720b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107215:	83 ca 80             	or     $0xffffff80,%edx
80107218:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010721e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107221:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107228:	83 ca 0f             	or     $0xf,%edx
8010722b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107234:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010723b:	83 e2 ef             	and    $0xffffffef,%edx
8010723e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107247:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010724e:	83 e2 df             	and    $0xffffffdf,%edx
80107251:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107261:	83 ca 40             	or     $0x40,%edx
80107264:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010726a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107274:	83 ca 80             	or     $0xffffff80,%edx
80107277:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010727d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107280:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107291:	ff ff 
80107293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107296:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010729d:	00 00 
8010729f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801072a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ac:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801072b3:	83 e2 f0             	and    $0xfffffff0,%edx
801072b6:	83 ca 02             	or     $0x2,%edx
801072b9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801072bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801072c9:	83 ca 10             	or     $0x10,%edx
801072cc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801072d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801072dc:	83 ca 60             	or     $0x60,%edx
801072df:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801072e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801072ef:	83 ca 80             	or     $0xffffff80,%edx
801072f2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801072f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107302:	83 ca 0f             	or     $0xf,%edx
80107305:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010730b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107315:	83 e2 ef             	and    $0xffffffef,%edx
80107318:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107328:	83 e2 df             	and    $0xffffffdf,%edx
8010732b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107334:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010733b:	83 ca 40             	or     $0x40,%edx
8010733e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107347:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010734e:	83 ca 80             	or     $0xffffff80,%edx
80107351:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107364:	83 c0 70             	add    $0x70,%eax
80107367:	83 ec 08             	sub    $0x8,%esp
8010736a:	6a 30                	push   $0x30
8010736c:	50                   	push   %eax
8010736d:	e8 63 fc ff ff       	call   80106fd5 <lgdt>
80107372:	83 c4 10             	add    $0x10,%esp
}
80107375:	90                   	nop
80107376:	c9                   	leave  
80107377:	c3                   	ret    

80107378 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107378:	55                   	push   %ebp
80107379:	89 e5                	mov    %esp,%ebp
8010737b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010737e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107381:	c1 e8 16             	shr    $0x16,%eax
80107384:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010738b:	8b 45 08             	mov    0x8(%ebp),%eax
8010738e:	01 d0                	add    %edx,%eax
80107390:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107396:	8b 00                	mov    (%eax),%eax
80107398:	83 e0 01             	and    $0x1,%eax
8010739b:	85 c0                	test   %eax,%eax
8010739d:	74 14                	je     801073b3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010739f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073a2:	8b 00                	mov    (%eax),%eax
801073a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801073a9:	05 00 00 00 80       	add    $0x80000000,%eax
801073ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073b1:	eb 42                	jmp    801073f5 <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801073b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801073b7:	74 0e                	je     801073c7 <walkpgdir+0x4f>
801073b9:	e8 e3 b3 ff ff       	call   801027a1 <kalloc>
801073be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801073c5:	75 07                	jne    801073ce <walkpgdir+0x56>
      return 0;
801073c7:	b8 00 00 00 00       	mov    $0x0,%eax
801073cc:	eb 3e                	jmp    8010740c <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801073ce:	83 ec 04             	sub    $0x4,%esp
801073d1:	68 00 10 00 00       	push   $0x1000
801073d6:	6a 00                	push   $0x0
801073d8:	ff 75 f4             	push   -0xc(%ebp)
801073db:	e8 e4 d6 ff ff       	call   80104ac4 <memset>
801073e0:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801073e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e6:	05 00 00 00 80       	add    $0x80000000,%eax
801073eb:	83 c8 07             	or     $0x7,%eax
801073ee:	89 c2                	mov    %eax,%edx
801073f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073f3:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801073f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801073f8:	c1 e8 0c             	shr    $0xc,%eax
801073fb:	25 ff 03 00 00       	and    $0x3ff,%eax
80107400:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740a:	01 d0                	add    %edx,%eax
}
8010740c:	c9                   	leave  
8010740d:	c3                   	ret    

8010740e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010740e:	55                   	push   %ebp
8010740f:	89 e5                	mov    %esp,%ebp
80107411:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107414:	8b 45 0c             	mov    0xc(%ebp),%eax
80107417:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010741c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010741f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107422:	8b 45 10             	mov    0x10(%ebp),%eax
80107425:	01 d0                	add    %edx,%eax
80107427:	83 e8 01             	sub    $0x1,%eax
8010742a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010742f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107432:	83 ec 04             	sub    $0x4,%esp
80107435:	6a 01                	push   $0x1
80107437:	ff 75 f4             	push   -0xc(%ebp)
8010743a:	ff 75 08             	push   0x8(%ebp)
8010743d:	e8 36 ff ff ff       	call   80107378 <walkpgdir>
80107442:	83 c4 10             	add    $0x10,%esp
80107445:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107448:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010744c:	75 07                	jne    80107455 <mappages+0x47>
      return -1;
8010744e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107453:	eb 47                	jmp    8010749c <mappages+0x8e>
    if(*pte & PTE_P)
80107455:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107458:	8b 00                	mov    (%eax),%eax
8010745a:	83 e0 01             	and    $0x1,%eax
8010745d:	85 c0                	test   %eax,%eax
8010745f:	74 0d                	je     8010746e <mappages+0x60>
      panic("remap");
80107461:	83 ec 0c             	sub    $0xc,%esp
80107464:	68 f0 a7 10 80       	push   $0x8010a7f0
80107469:	e8 3b 91 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
8010746e:	8b 45 18             	mov    0x18(%ebp),%eax
80107471:	0b 45 14             	or     0x14(%ebp),%eax
80107474:	83 c8 01             	or     $0x1,%eax
80107477:	89 c2                	mov    %eax,%edx
80107479:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010747c:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010747e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107481:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107484:	74 10                	je     80107496 <mappages+0x88>
      break;
    a += PGSIZE;
80107486:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010748d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107494:	eb 9c                	jmp    80107432 <mappages+0x24>
      break;
80107496:	90                   	nop
  }
  return 0;
80107497:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010749c:	c9                   	leave  
8010749d:	c3                   	ret    

8010749e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010749e:	55                   	push   %ebp
8010749f:	89 e5                	mov    %esp,%ebp
801074a1:	53                   	push   %ebx
801074a2:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801074a5:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801074ac:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
801074b2:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801074b7:	29 d0                	sub    %edx,%eax
801074b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801074bc:	a1 48 6c 19 80       	mov    0x80196c48,%eax
801074c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801074c4:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
801074ca:	a1 50 6c 19 80       	mov    0x80196c50,%eax
801074cf:	01 d0                	add    %edx,%eax
801074d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
801074d4:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	83 c0 30             	add    $0x30,%eax
801074e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801074e4:	89 10                	mov    %edx,(%eax)
801074e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801074e9:	89 50 04             	mov    %edx,0x4(%eax)
801074ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
801074ef:	89 50 08             	mov    %edx,0x8(%eax)
801074f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801074f5:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801074f8:	e8 a4 b2 ff ff       	call   801027a1 <kalloc>
801074fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107500:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107504:	75 07                	jne    8010750d <setupkvm+0x6f>
    return 0;
80107506:	b8 00 00 00 00       	mov    $0x0,%eax
8010750b:	eb 78                	jmp    80107585 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010750d:	83 ec 04             	sub    $0x4,%esp
80107510:	68 00 10 00 00       	push   $0x1000
80107515:	6a 00                	push   $0x0
80107517:	ff 75 f0             	push   -0x10(%ebp)
8010751a:	e8 a5 d5 ff ff       	call   80104ac4 <memset>
8010751f:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107522:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107529:	eb 4e                	jmp    80107579 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010752b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107534:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753a:	8b 58 08             	mov    0x8(%eax),%ebx
8010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107540:	8b 40 04             	mov    0x4(%eax),%eax
80107543:	29 c3                	sub    %eax,%ebx
80107545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107548:	8b 00                	mov    (%eax),%eax
8010754a:	83 ec 0c             	sub    $0xc,%esp
8010754d:	51                   	push   %ecx
8010754e:	52                   	push   %edx
8010754f:	53                   	push   %ebx
80107550:	50                   	push   %eax
80107551:	ff 75 f0             	push   -0x10(%ebp)
80107554:	e8 b5 fe ff ff       	call   8010740e <mappages>
80107559:	83 c4 20             	add    $0x20,%esp
8010755c:	85 c0                	test   %eax,%eax
8010755e:	79 15                	jns    80107575 <setupkvm+0xd7>
      freevm(pgdir);
80107560:	83 ec 0c             	sub    $0xc,%esp
80107563:	ff 75 f0             	push   -0x10(%ebp)
80107566:	e8 f5 04 00 00       	call   80107a60 <freevm>
8010756b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010756e:	b8 00 00 00 00       	mov    $0x0,%eax
80107573:	eb 10                	jmp    80107585 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107575:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107579:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107580:	72 a9                	jb     8010752b <setupkvm+0x8d>
    }
  return pgdir;
80107582:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107588:	c9                   	leave  
80107589:	c3                   	ret    

8010758a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010758a:	55                   	push   %ebp
8010758b:	89 e5                	mov    %esp,%ebp
8010758d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107590:	e8 09 ff ff ff       	call   8010749e <setupkvm>
80107595:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
8010759a:	e8 03 00 00 00       	call   801075a2 <switchkvm>
}
8010759f:	90                   	nop
801075a0:	c9                   	leave  
801075a1:	c3                   	ret    

801075a2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801075a2:	55                   	push   %ebp
801075a3:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801075a5:	a1 7c 69 19 80       	mov    0x8019697c,%eax
801075aa:	05 00 00 00 80       	add    $0x80000000,%eax
801075af:	50                   	push   %eax
801075b0:	e8 61 fa ff ff       	call   80107016 <lcr3>
801075b5:	83 c4 04             	add    $0x4,%esp
}
801075b8:	90                   	nop
801075b9:	c9                   	leave  
801075ba:	c3                   	ret    

801075bb <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801075bb:	55                   	push   %ebp
801075bc:	89 e5                	mov    %esp,%ebp
801075be:	56                   	push   %esi
801075bf:	53                   	push   %ebx
801075c0:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801075c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801075c7:	75 0d                	jne    801075d6 <switchuvm+0x1b>
    panic("switchuvm: no process");
801075c9:	83 ec 0c             	sub    $0xc,%esp
801075cc:	68 f6 a7 10 80       	push   $0x8010a7f6
801075d1:	e8 d3 8f ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801075d6:	8b 45 08             	mov    0x8(%ebp),%eax
801075d9:	8b 40 08             	mov    0x8(%eax),%eax
801075dc:	85 c0                	test   %eax,%eax
801075de:	75 0d                	jne    801075ed <switchuvm+0x32>
    panic("switchuvm: no kstack");
801075e0:	83 ec 0c             	sub    $0xc,%esp
801075e3:	68 0c a8 10 80       	push   $0x8010a80c
801075e8:	e8 bc 8f ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801075ed:	8b 45 08             	mov    0x8(%ebp),%eax
801075f0:	8b 40 04             	mov    0x4(%eax),%eax
801075f3:	85 c0                	test   %eax,%eax
801075f5:	75 0d                	jne    80107604 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801075f7:	83 ec 0c             	sub    $0xc,%esp
801075fa:	68 21 a8 10 80       	push   $0x8010a821
801075ff:	e8 a5 8f ff ff       	call   801005a9 <panic>

  pushcli();
80107604:	e8 b0 d3 ff ff       	call   801049b9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107609:	e8 ab c3 ff ff       	call   801039b9 <mycpu>
8010760e:	89 c3                	mov    %eax,%ebx
80107610:	e8 a4 c3 ff ff       	call   801039b9 <mycpu>
80107615:	83 c0 08             	add    $0x8,%eax
80107618:	89 c6                	mov    %eax,%esi
8010761a:	e8 9a c3 ff ff       	call   801039b9 <mycpu>
8010761f:	83 c0 08             	add    $0x8,%eax
80107622:	c1 e8 10             	shr    $0x10,%eax
80107625:	88 45 f7             	mov    %al,-0x9(%ebp)
80107628:	e8 8c c3 ff ff       	call   801039b9 <mycpu>
8010762d:	83 c0 08             	add    $0x8,%eax
80107630:	c1 e8 18             	shr    $0x18,%eax
80107633:	89 c2                	mov    %eax,%edx
80107635:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010763c:	67 00 
8010763e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107645:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107649:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010764f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107656:	83 e0 f0             	and    $0xfffffff0,%eax
80107659:	83 c8 09             	or     $0x9,%eax
8010765c:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107662:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107669:	83 c8 10             	or     $0x10,%eax
8010766c:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107672:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107679:	83 e0 9f             	and    $0xffffff9f,%eax
8010767c:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107682:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107689:	83 c8 80             	or     $0xffffff80,%eax
8010768c:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107692:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107699:	83 e0 f0             	and    $0xfffffff0,%eax
8010769c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801076a2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801076a9:	83 e0 ef             	and    $0xffffffef,%eax
801076ac:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801076b2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801076b9:	83 e0 df             	and    $0xffffffdf,%eax
801076bc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801076c2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801076c9:	83 c8 40             	or     $0x40,%eax
801076cc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801076d2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801076d9:	83 e0 7f             	and    $0x7f,%eax
801076dc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801076e2:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801076e8:	e8 cc c2 ff ff       	call   801039b9 <mycpu>
801076ed:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076f4:	83 e2 ef             	and    $0xffffffef,%edx
801076f7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801076fd:	e8 b7 c2 ff ff       	call   801039b9 <mycpu>
80107702:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107708:	8b 45 08             	mov    0x8(%ebp),%eax
8010770b:	8b 40 08             	mov    0x8(%eax),%eax
8010770e:	89 c3                	mov    %eax,%ebx
80107710:	e8 a4 c2 ff ff       	call   801039b9 <mycpu>
80107715:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010771b:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010771e:	e8 96 c2 ff ff       	call   801039b9 <mycpu>
80107723:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107729:	83 ec 0c             	sub    $0xc,%esp
8010772c:	6a 28                	push   $0x28
8010772e:	e8 cc f8 ff ff       	call   80106fff <ltr>
80107733:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107736:	8b 45 08             	mov    0x8(%ebp),%eax
80107739:	8b 40 04             	mov    0x4(%eax),%eax
8010773c:	05 00 00 00 80       	add    $0x80000000,%eax
80107741:	83 ec 0c             	sub    $0xc,%esp
80107744:	50                   	push   %eax
80107745:	e8 cc f8 ff ff       	call   80107016 <lcr3>
8010774a:	83 c4 10             	add    $0x10,%esp
  popcli();
8010774d:	e8 b4 d2 ff ff       	call   80104a06 <popcli>
}
80107752:	90                   	nop
80107753:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107756:	5b                   	pop    %ebx
80107757:	5e                   	pop    %esi
80107758:	5d                   	pop    %ebp
80107759:	c3                   	ret    

8010775a <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010775a:	55                   	push   %ebp
8010775b:	89 e5                	mov    %esp,%ebp
8010775d:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107760:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107767:	76 0d                	jbe    80107776 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107769:	83 ec 0c             	sub    $0xc,%esp
8010776c:	68 35 a8 10 80       	push   $0x8010a835
80107771:	e8 33 8e ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107776:	e8 26 b0 ff ff       	call   801027a1 <kalloc>
8010777b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010777e:	83 ec 04             	sub    $0x4,%esp
80107781:	68 00 10 00 00       	push   $0x1000
80107786:	6a 00                	push   $0x0
80107788:	ff 75 f4             	push   -0xc(%ebp)
8010778b:	e8 34 d3 ff ff       	call   80104ac4 <memset>
80107790:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	05 00 00 00 80       	add    $0x80000000,%eax
8010779b:	83 ec 0c             	sub    $0xc,%esp
8010779e:	6a 06                	push   $0x6
801077a0:	50                   	push   %eax
801077a1:	68 00 10 00 00       	push   $0x1000
801077a6:	6a 00                	push   $0x0
801077a8:	ff 75 08             	push   0x8(%ebp)
801077ab:	e8 5e fc ff ff       	call   8010740e <mappages>
801077b0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801077b3:	83 ec 04             	sub    $0x4,%esp
801077b6:	ff 75 10             	push   0x10(%ebp)
801077b9:	ff 75 0c             	push   0xc(%ebp)
801077bc:	ff 75 f4             	push   -0xc(%ebp)
801077bf:	e8 bf d3 ff ff       	call   80104b83 <memmove>
801077c4:	83 c4 10             	add    $0x10,%esp
}
801077c7:	90                   	nop
801077c8:	c9                   	leave  
801077c9:	c3                   	ret    

801077ca <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801077ca:	55                   	push   %ebp
801077cb:	89 e5                	mov    %esp,%ebp
801077cd:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801077d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801077d3:	25 ff 0f 00 00       	and    $0xfff,%eax
801077d8:	85 c0                	test   %eax,%eax
801077da:	74 0d                	je     801077e9 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801077dc:	83 ec 0c             	sub    $0xc,%esp
801077df:	68 50 a8 10 80       	push   $0x8010a850
801077e4:	e8 c0 8d ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801077e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801077f0:	e9 8f 00 00 00       	jmp    80107884 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801077f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801077f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fb:	01 d0                	add    %edx,%eax
801077fd:	83 ec 04             	sub    $0x4,%esp
80107800:	6a 00                	push   $0x0
80107802:	50                   	push   %eax
80107803:	ff 75 08             	push   0x8(%ebp)
80107806:	e8 6d fb ff ff       	call   80107378 <walkpgdir>
8010780b:	83 c4 10             	add    $0x10,%esp
8010780e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107811:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107815:	75 0d                	jne    80107824 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107817:	83 ec 0c             	sub    $0xc,%esp
8010781a:	68 73 a8 10 80       	push   $0x8010a873
8010781f:	e8 85 8d ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107824:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107827:	8b 00                	mov    (%eax),%eax
80107829:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010782e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107831:	8b 45 18             	mov    0x18(%ebp),%eax
80107834:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107837:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010783c:	77 0b                	ja     80107849 <loaduvm+0x7f>
      n = sz - i;
8010783e:	8b 45 18             	mov    0x18(%ebp),%eax
80107841:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107844:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107847:	eb 07                	jmp    80107850 <loaduvm+0x86>
    else
      n = PGSIZE;
80107849:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107850:	8b 55 14             	mov    0x14(%ebp),%edx
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	01 d0                	add    %edx,%eax
80107858:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010785b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107861:	ff 75 f0             	push   -0x10(%ebp)
80107864:	50                   	push   %eax
80107865:	52                   	push   %edx
80107866:	ff 75 10             	push   0x10(%ebp)
80107869:	e8 69 a6 ff ff       	call   80101ed7 <readi>
8010786e:	83 c4 10             	add    $0x10,%esp
80107871:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107874:	74 07                	je     8010787d <loaduvm+0xb3>
      return -1;
80107876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010787b:	eb 18                	jmp    80107895 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
8010787d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	3b 45 18             	cmp    0x18(%ebp),%eax
8010788a:	0f 82 65 ff ff ff    	jb     801077f5 <loaduvm+0x2b>
  }
  return 0;
80107890:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107895:	c9                   	leave  
80107896:	c3                   	ret    

80107897 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107897:	55                   	push   %ebp
80107898:	89 e5                	mov    %esp,%ebp
8010789a:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010789d:	8b 45 10             	mov    0x10(%ebp),%eax
801078a0:	85 c0                	test   %eax,%eax
801078a2:	79 0a                	jns    801078ae <allocuvm+0x17>
    return 0;
801078a4:	b8 00 00 00 00       	mov    $0x0,%eax
801078a9:	e9 ec 00 00 00       	jmp    8010799a <allocuvm+0x103>
  if(newsz < oldsz)
801078ae:	8b 45 10             	mov    0x10(%ebp),%eax
801078b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078b4:	73 08                	jae    801078be <allocuvm+0x27>
    return oldsz;
801078b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801078b9:	e9 dc 00 00 00       	jmp    8010799a <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801078be:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c1:	05 ff 0f 00 00       	add    $0xfff,%eax
801078c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801078ce:	e9 b8 00 00 00       	jmp    8010798b <allocuvm+0xf4>
    mem = kalloc();
801078d3:	e8 c9 ae ff ff       	call   801027a1 <kalloc>
801078d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801078db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078df:	75 2e                	jne    8010790f <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
801078e1:	83 ec 0c             	sub    $0xc,%esp
801078e4:	68 91 a8 10 80       	push   $0x8010a891
801078e9:	e8 06 8b ff ff       	call   801003f4 <cprintf>
801078ee:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078f1:	83 ec 04             	sub    $0x4,%esp
801078f4:	ff 75 0c             	push   0xc(%ebp)
801078f7:	ff 75 10             	push   0x10(%ebp)
801078fa:	ff 75 08             	push   0x8(%ebp)
801078fd:	e8 9a 00 00 00       	call   8010799c <deallocuvm>
80107902:	83 c4 10             	add    $0x10,%esp
      return 0;
80107905:	b8 00 00 00 00       	mov    $0x0,%eax
8010790a:	e9 8b 00 00 00       	jmp    8010799a <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010790f:	83 ec 04             	sub    $0x4,%esp
80107912:	68 00 10 00 00       	push   $0x1000
80107917:	6a 00                	push   $0x0
80107919:	ff 75 f0             	push   -0x10(%ebp)
8010791c:	e8 a3 d1 ff ff       	call   80104ac4 <memset>
80107921:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107927:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010792d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107930:	83 ec 0c             	sub    $0xc,%esp
80107933:	6a 06                	push   $0x6
80107935:	52                   	push   %edx
80107936:	68 00 10 00 00       	push   $0x1000
8010793b:	50                   	push   %eax
8010793c:	ff 75 08             	push   0x8(%ebp)
8010793f:	e8 ca fa ff ff       	call   8010740e <mappages>
80107944:	83 c4 20             	add    $0x20,%esp
80107947:	85 c0                	test   %eax,%eax
80107949:	79 39                	jns    80107984 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010794b:	83 ec 0c             	sub    $0xc,%esp
8010794e:	68 a9 a8 10 80       	push   $0x8010a8a9
80107953:	e8 9c 8a ff ff       	call   801003f4 <cprintf>
80107958:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010795b:	83 ec 04             	sub    $0x4,%esp
8010795e:	ff 75 0c             	push   0xc(%ebp)
80107961:	ff 75 10             	push   0x10(%ebp)
80107964:	ff 75 08             	push   0x8(%ebp)
80107967:	e8 30 00 00 00       	call   8010799c <deallocuvm>
8010796c:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010796f:	83 ec 0c             	sub    $0xc,%esp
80107972:	ff 75 f0             	push   -0x10(%ebp)
80107975:	e8 8d ad ff ff       	call   80102707 <kfree>
8010797a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010797d:	b8 00 00 00 00       	mov    $0x0,%eax
80107982:	eb 16                	jmp    8010799a <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107984:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010798b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798e:	3b 45 10             	cmp    0x10(%ebp),%eax
80107991:	0f 82 3c ff ff ff    	jb     801078d3 <allocuvm+0x3c>
    }
  }
  return newsz;
80107997:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010799a:	c9                   	leave  
8010799b:	c3                   	ret    

8010799c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010799c:	55                   	push   %ebp
8010799d:	89 e5                	mov    %esp,%ebp
8010799f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801079a2:	8b 45 10             	mov    0x10(%ebp),%eax
801079a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079a8:	72 08                	jb     801079b2 <deallocuvm+0x16>
    return oldsz;
801079aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801079ad:	e9 ac 00 00 00       	jmp    80107a5e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801079b2:	8b 45 10             	mov    0x10(%ebp),%eax
801079b5:	05 ff 0f 00 00       	add    $0xfff,%eax
801079ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801079c2:	e9 88 00 00 00       	jmp    80107a4f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801079c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ca:	83 ec 04             	sub    $0x4,%esp
801079cd:	6a 00                	push   $0x0
801079cf:	50                   	push   %eax
801079d0:	ff 75 08             	push   0x8(%ebp)
801079d3:	e8 a0 f9 ff ff       	call   80107378 <walkpgdir>
801079d8:	83 c4 10             	add    $0x10,%esp
801079db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801079de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079e2:	75 16                	jne    801079fa <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801079e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e7:	c1 e8 16             	shr    $0x16,%eax
801079ea:	83 c0 01             	add    $0x1,%eax
801079ed:	c1 e0 16             	shl    $0x16,%eax
801079f0:	2d 00 10 00 00       	sub    $0x1000,%eax
801079f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079f8:	eb 4e                	jmp    80107a48 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801079fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079fd:	8b 00                	mov    (%eax),%eax
801079ff:	83 e0 01             	and    $0x1,%eax
80107a02:	85 c0                	test   %eax,%eax
80107a04:	74 42                	je     80107a48 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a09:	8b 00                	mov    (%eax),%eax
80107a0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a10:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107a13:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a17:	75 0d                	jne    80107a26 <deallocuvm+0x8a>
        panic("kfree");
80107a19:	83 ec 0c             	sub    $0xc,%esp
80107a1c:	68 c5 a8 10 80       	push   $0x8010a8c5
80107a21:	e8 83 8b ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107a26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a29:	05 00 00 00 80       	add    $0x80000000,%eax
80107a2e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107a31:	83 ec 0c             	sub    $0xc,%esp
80107a34:	ff 75 e8             	push   -0x18(%ebp)
80107a37:	e8 cb ac ff ff       	call   80102707 <kfree>
80107a3c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107a48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a55:	0f 82 6c ff ff ff    	jb     801079c7 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107a5b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a5e:	c9                   	leave  
80107a5f:	c3                   	ret    

80107a60 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107a60:	55                   	push   %ebp
80107a61:	89 e5                	mov    %esp,%ebp
80107a63:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107a66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a6a:	75 0d                	jne    80107a79 <freevm+0x19>
    panic("freevm: no pgdir");
80107a6c:	83 ec 0c             	sub    $0xc,%esp
80107a6f:	68 cb a8 10 80       	push   $0x8010a8cb
80107a74:	e8 30 8b ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107a79:	83 ec 04             	sub    $0x4,%esp
80107a7c:	6a 00                	push   $0x0
80107a7e:	68 00 00 00 80       	push   $0x80000000
80107a83:	ff 75 08             	push   0x8(%ebp)
80107a86:	e8 11 ff ff ff       	call   8010799c <deallocuvm>
80107a8b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a95:	eb 48                	jmp    80107adf <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80107aa4:	01 d0                	add    %edx,%eax
80107aa6:	8b 00                	mov    (%eax),%eax
80107aa8:	83 e0 01             	and    $0x1,%eax
80107aab:	85 c0                	test   %eax,%eax
80107aad:	74 2c                	je     80107adb <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80107abc:	01 d0                	add    %edx,%eax
80107abe:	8b 00                	mov    (%eax),%eax
80107ac0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ac5:	05 00 00 00 80       	add    $0x80000000,%eax
80107aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107acd:	83 ec 0c             	sub    $0xc,%esp
80107ad0:	ff 75 f0             	push   -0x10(%ebp)
80107ad3:	e8 2f ac ff ff       	call   80102707 <kfree>
80107ad8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107adf:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107ae6:	76 af                	jbe    80107a97 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107ae8:	83 ec 0c             	sub    $0xc,%esp
80107aeb:	ff 75 08             	push   0x8(%ebp)
80107aee:	e8 14 ac ff ff       	call   80102707 <kfree>
80107af3:	83 c4 10             	add    $0x10,%esp
}
80107af6:	90                   	nop
80107af7:	c9                   	leave  
80107af8:	c3                   	ret    

80107af9 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107af9:	55                   	push   %ebp
80107afa:	89 e5                	mov    %esp,%ebp
80107afc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107aff:	83 ec 04             	sub    $0x4,%esp
80107b02:	6a 00                	push   $0x0
80107b04:	ff 75 0c             	push   0xc(%ebp)
80107b07:	ff 75 08             	push   0x8(%ebp)
80107b0a:	e8 69 f8 ff ff       	call   80107378 <walkpgdir>
80107b0f:	83 c4 10             	add    $0x10,%esp
80107b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107b15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b19:	75 0d                	jne    80107b28 <clearpteu+0x2f>
    panic("clearpteu");
80107b1b:	83 ec 0c             	sub    $0xc,%esp
80107b1e:	68 dc a8 10 80       	push   $0x8010a8dc
80107b23:	e8 81 8a ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2b:	8b 00                	mov    (%eax),%eax
80107b2d:	83 e0 fb             	and    $0xfffffffb,%eax
80107b30:	89 c2                	mov    %eax,%edx
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	89 10                	mov    %edx,(%eax)
}
80107b37:	90                   	nop
80107b38:	c9                   	leave  
80107b39:	c3                   	ret    

80107b3a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107b3a:	55                   	push   %ebp
80107b3b:	89 e5                	mov    %esp,%ebp
80107b3d:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107b40:	e8 59 f9 ff ff       	call   8010749e <setupkvm>
80107b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b4c:	75 0a                	jne    80107b58 <copyuvm+0x1e>
    return 0;
80107b4e:	b8 00 00 00 00       	mov    $0x0,%eax
80107b53:	e9 d6 00 00 00       	jmp    80107c2e <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107b58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b5f:	e9 a3 00 00 00       	jmp    80107c07 <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	83 ec 04             	sub    $0x4,%esp
80107b6a:	6a 00                	push   $0x0
80107b6c:	50                   	push   %eax
80107b6d:	ff 75 08             	push   0x8(%ebp)
80107b70:	e8 03 f8 ff ff       	call   80107378 <walkpgdir>
80107b75:	83 c4 10             	add    $0x10,%esp
80107b78:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b7f:	74 7b                	je     80107bfc <copyuvm+0xc2>
      continue;
    }
    if(!(*pte & PTE_P)){
80107b81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b84:	8b 00                	mov    (%eax),%eax
80107b86:	83 e0 01             	and    $0x1,%eax
80107b89:	85 c0                	test   %eax,%eax
80107b8b:	74 72                	je     80107bff <copyuvm+0xc5>
      continue;
    }
    pa = PTE_ADDR(*pte);
80107b8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b90:	8b 00                	mov    (%eax),%eax
80107b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b97:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b9d:	8b 00                	mov    (%eax),%eax
80107b9f:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ba4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ba7:	e8 f5 ab ff ff       	call   801027a1 <kalloc>
80107bac:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107baf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107bb3:	74 62                	je     80107c17 <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107bb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107bb8:	05 00 00 00 80       	add    $0x80000000,%eax
80107bbd:	83 ec 04             	sub    $0x4,%esp
80107bc0:	68 00 10 00 00       	push   $0x1000
80107bc5:	50                   	push   %eax
80107bc6:	ff 75 e0             	push   -0x20(%ebp)
80107bc9:	e8 b5 cf ff ff       	call   80104b83 <memmove>
80107bce:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107bd1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107bd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107bd7:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be0:	83 ec 0c             	sub    $0xc,%esp
80107be3:	52                   	push   %edx
80107be4:	51                   	push   %ecx
80107be5:	68 00 10 00 00       	push   $0x1000
80107bea:	50                   	push   %eax
80107beb:	ff 75 f0             	push   -0x10(%ebp)
80107bee:	e8 1b f8 ff ff       	call   8010740e <mappages>
80107bf3:	83 c4 20             	add    $0x20,%esp
80107bf6:	85 c0                	test   %eax,%eax
80107bf8:	78 20                	js     80107c1a <copyuvm+0xe0>
80107bfa:	eb 04                	jmp    80107c00 <copyuvm+0xc6>
      continue;
80107bfc:	90                   	nop
80107bfd:	eb 01                	jmp    80107c00 <copyuvm+0xc6>
      continue;
80107bff:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107c00:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	85 c0                	test   %eax,%eax
80107c0c:	0f 89 52 ff ff ff    	jns    80107b64 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c15:	eb 17                	jmp    80107c2e <copyuvm+0xf4>
      goto bad;
80107c17:	90                   	nop
80107c18:	eb 01                	jmp    80107c1b <copyuvm+0xe1>
      goto bad;
80107c1a:	90                   	nop

bad:
  freevm(d);
80107c1b:	83 ec 0c             	sub    $0xc,%esp
80107c1e:	ff 75 f0             	push   -0x10(%ebp)
80107c21:	e8 3a fe ff ff       	call   80107a60 <freevm>
80107c26:	83 c4 10             	add    $0x10,%esp
  return 0;
80107c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c2e:	c9                   	leave  
80107c2f:	c3                   	ret    

80107c30 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107c30:	55                   	push   %ebp
80107c31:	89 e5                	mov    %esp,%ebp
80107c33:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107c36:	83 ec 04             	sub    $0x4,%esp
80107c39:	6a 00                	push   $0x0
80107c3b:	ff 75 0c             	push   0xc(%ebp)
80107c3e:	ff 75 08             	push   0x8(%ebp)
80107c41:	e8 32 f7 ff ff       	call   80107378 <walkpgdir>
80107c46:	83 c4 10             	add    $0x10,%esp
80107c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	8b 00                	mov    (%eax),%eax
80107c51:	83 e0 01             	and    $0x1,%eax
80107c54:	85 c0                	test   %eax,%eax
80107c56:	75 07                	jne    80107c5f <uva2ka+0x2f>
    return 0;
80107c58:	b8 00 00 00 00       	mov    $0x0,%eax
80107c5d:	eb 22                	jmp    80107c81 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	8b 00                	mov    (%eax),%eax
80107c64:	83 e0 04             	and    $0x4,%eax
80107c67:	85 c0                	test   %eax,%eax
80107c69:	75 07                	jne    80107c72 <uva2ka+0x42>
    return 0;
80107c6b:	b8 00 00 00 00       	mov    $0x0,%eax
80107c70:	eb 0f                	jmp    80107c81 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	8b 00                	mov    (%eax),%eax
80107c77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c7c:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107c81:	c9                   	leave  
80107c82:	c3                   	ret    

80107c83 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107c83:	55                   	push   %ebp
80107c84:	89 e5                	mov    %esp,%ebp
80107c86:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107c89:	8b 45 10             	mov    0x10(%ebp),%eax
80107c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107c8f:	eb 7f                	jmp    80107d10 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107c91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c99:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9f:	83 ec 08             	sub    $0x8,%esp
80107ca2:	50                   	push   %eax
80107ca3:	ff 75 08             	push   0x8(%ebp)
80107ca6:	e8 85 ff ff ff       	call   80107c30 <uva2ka>
80107cab:	83 c4 10             	add    $0x10,%esp
80107cae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107cb1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107cb5:	75 07                	jne    80107cbe <copyout+0x3b>
      return -1;
80107cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cbc:	eb 61                	jmp    80107d1f <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107cbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc1:	2b 45 0c             	sub    0xc(%ebp),%eax
80107cc4:	05 00 10 00 00       	add    $0x1000,%eax
80107cc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ccf:	3b 45 14             	cmp    0x14(%ebp),%eax
80107cd2:	76 06                	jbe    80107cda <copyout+0x57>
      n = len;
80107cd4:	8b 45 14             	mov    0x14(%ebp),%eax
80107cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cdd:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107ce0:	89 c2                	mov    %eax,%edx
80107ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ce5:	01 d0                	add    %edx,%eax
80107ce7:	83 ec 04             	sub    $0x4,%esp
80107cea:	ff 75 f0             	push   -0x10(%ebp)
80107ced:	ff 75 f4             	push   -0xc(%ebp)
80107cf0:	50                   	push   %eax
80107cf1:	e8 8d ce ff ff       	call   80104b83 <memmove>
80107cf6:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cfc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d02:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107d05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d08:	05 00 10 00 00       	add    $0x1000,%eax
80107d0d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107d10:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107d14:	0f 85 77 ff ff ff    	jne    80107c91 <copyout+0xe>
  }
  return 0;
80107d1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d1f:	c9                   	leave  
80107d20:	c3                   	ret    

80107d21 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107d21:	55                   	push   %ebp
80107d22:	89 e5                	mov    %esp,%ebp
80107d24:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107d27:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107d2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107d31:	8b 40 08             	mov    0x8(%eax),%eax
80107d34:	05 00 00 00 80       	add    $0x80000000,%eax
80107d39:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107d3c:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	8b 40 24             	mov    0x24(%eax),%eax
80107d49:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107d4e:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107d55:	00 00 00 

  while(i<madt->len){
80107d58:	90                   	nop
80107d59:	e9 bd 00 00 00       	jmp    80107e1b <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107d5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107d64:	01 d0                	add    %edx,%eax
80107d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6c:	0f b6 00             	movzbl (%eax),%eax
80107d6f:	0f b6 c0             	movzbl %al,%eax
80107d72:	83 f8 05             	cmp    $0x5,%eax
80107d75:	0f 87 a0 00 00 00    	ja     80107e1b <mpinit_uefi+0xfa>
80107d7b:	8b 04 85 e8 a8 10 80 	mov    -0x7fef5718(,%eax,4),%eax
80107d82:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107d8a:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d8f:	83 f8 03             	cmp    $0x3,%eax
80107d92:	7f 28                	jg     80107dbc <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107d94:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107d9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d9d:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107da1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107da7:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107dad:	88 02                	mov    %al,(%edx)
          ncpu++;
80107daf:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107db4:	83 c0 01             	add    $0x1,%eax
80107db7:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107dbf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107dc3:	0f b6 c0             	movzbl %al,%eax
80107dc6:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107dc9:	eb 50                	jmp    80107e1b <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107dd4:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107dd8:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107de0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107de4:	0f b6 c0             	movzbl %al,%eax
80107de7:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107dea:	eb 2f                	jmp    80107e1b <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107def:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107df5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107df9:	0f b6 c0             	movzbl %al,%eax
80107dfc:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107dff:	eb 1a                	jmp    80107e1b <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e04:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e0a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e0e:	0f b6 c0             	movzbl %al,%eax
80107e11:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e14:	eb 05                	jmp    80107e1b <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107e16:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107e1a:	90                   	nop
  while(i<madt->len){
80107e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1e:	8b 40 04             	mov    0x4(%eax),%eax
80107e21:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107e24:	0f 82 34 ff ff ff    	jb     80107d5e <mpinit_uefi+0x3d>
    }
  }

}
80107e2a:	90                   	nop
80107e2b:	90                   	nop
80107e2c:	c9                   	leave  
80107e2d:	c3                   	ret    

80107e2e <inb>:
{
80107e2e:	55                   	push   %ebp
80107e2f:	89 e5                	mov    %esp,%ebp
80107e31:	83 ec 14             	sub    $0x14,%esp
80107e34:	8b 45 08             	mov    0x8(%ebp),%eax
80107e37:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107e3b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107e3f:	89 c2                	mov    %eax,%edx
80107e41:	ec                   	in     (%dx),%al
80107e42:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107e45:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107e49:	c9                   	leave  
80107e4a:	c3                   	ret    

80107e4b <outb>:
{
80107e4b:	55                   	push   %ebp
80107e4c:	89 e5                	mov    %esp,%ebp
80107e4e:	83 ec 08             	sub    $0x8,%esp
80107e51:	8b 45 08             	mov    0x8(%ebp),%eax
80107e54:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107e5b:	89 d0                	mov    %edx,%eax
80107e5d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107e60:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107e64:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107e68:	ee                   	out    %al,(%dx)
}
80107e69:	90                   	nop
80107e6a:	c9                   	leave  
80107e6b:	c3                   	ret    

80107e6c <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107e6c:	55                   	push   %ebp
80107e6d:	89 e5                	mov    %esp,%ebp
80107e6f:	83 ec 28             	sub    $0x28,%esp
80107e72:	8b 45 08             	mov    0x8(%ebp),%eax
80107e75:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107e78:	6a 00                	push   $0x0
80107e7a:	68 fa 03 00 00       	push   $0x3fa
80107e7f:	e8 c7 ff ff ff       	call   80107e4b <outb>
80107e84:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107e87:	68 80 00 00 00       	push   $0x80
80107e8c:	68 fb 03 00 00       	push   $0x3fb
80107e91:	e8 b5 ff ff ff       	call   80107e4b <outb>
80107e96:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107e99:	6a 0c                	push   $0xc
80107e9b:	68 f8 03 00 00       	push   $0x3f8
80107ea0:	e8 a6 ff ff ff       	call   80107e4b <outb>
80107ea5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107ea8:	6a 00                	push   $0x0
80107eaa:	68 f9 03 00 00       	push   $0x3f9
80107eaf:	e8 97 ff ff ff       	call   80107e4b <outb>
80107eb4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107eb7:	6a 03                	push   $0x3
80107eb9:	68 fb 03 00 00       	push   $0x3fb
80107ebe:	e8 88 ff ff ff       	call   80107e4b <outb>
80107ec3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107ec6:	6a 00                	push   $0x0
80107ec8:	68 fc 03 00 00       	push   $0x3fc
80107ecd:	e8 79 ff ff ff       	call   80107e4b <outb>
80107ed2:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107ed5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107edc:	eb 11                	jmp    80107eef <uart_debug+0x83>
80107ede:	83 ec 0c             	sub    $0xc,%esp
80107ee1:	6a 0a                	push   $0xa
80107ee3:	e8 50 ac ff ff       	call   80102b38 <microdelay>
80107ee8:	83 c4 10             	add    $0x10,%esp
80107eeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107eef:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107ef3:	7f 1a                	jg     80107f0f <uart_debug+0xa3>
80107ef5:	83 ec 0c             	sub    $0xc,%esp
80107ef8:	68 fd 03 00 00       	push   $0x3fd
80107efd:	e8 2c ff ff ff       	call   80107e2e <inb>
80107f02:	83 c4 10             	add    $0x10,%esp
80107f05:	0f b6 c0             	movzbl %al,%eax
80107f08:	83 e0 20             	and    $0x20,%eax
80107f0b:	85 c0                	test   %eax,%eax
80107f0d:	74 cf                	je     80107ede <uart_debug+0x72>
  outb(COM1+0, p);
80107f0f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107f13:	0f b6 c0             	movzbl %al,%eax
80107f16:	83 ec 08             	sub    $0x8,%esp
80107f19:	50                   	push   %eax
80107f1a:	68 f8 03 00 00       	push   $0x3f8
80107f1f:	e8 27 ff ff ff       	call   80107e4b <outb>
80107f24:	83 c4 10             	add    $0x10,%esp
}
80107f27:	90                   	nop
80107f28:	c9                   	leave  
80107f29:	c3                   	ret    

80107f2a <uart_debugs>:

void uart_debugs(char *p){
80107f2a:	55                   	push   %ebp
80107f2b:	89 e5                	mov    %esp,%ebp
80107f2d:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107f30:	eb 1b                	jmp    80107f4d <uart_debugs+0x23>
    uart_debug(*p++);
80107f32:	8b 45 08             	mov    0x8(%ebp),%eax
80107f35:	8d 50 01             	lea    0x1(%eax),%edx
80107f38:	89 55 08             	mov    %edx,0x8(%ebp)
80107f3b:	0f b6 00             	movzbl (%eax),%eax
80107f3e:	0f be c0             	movsbl %al,%eax
80107f41:	83 ec 0c             	sub    $0xc,%esp
80107f44:	50                   	push   %eax
80107f45:	e8 22 ff ff ff       	call   80107e6c <uart_debug>
80107f4a:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f50:	0f b6 00             	movzbl (%eax),%eax
80107f53:	84 c0                	test   %al,%al
80107f55:	75 db                	jne    80107f32 <uart_debugs+0x8>
  }
}
80107f57:	90                   	nop
80107f58:	90                   	nop
80107f59:	c9                   	leave  
80107f5a:	c3                   	ret    

80107f5b <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107f5b:	55                   	push   %ebp
80107f5c:	89 e5                	mov    %esp,%ebp
80107f5e:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f61:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107f68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f6b:	8b 50 14             	mov    0x14(%eax),%edx
80107f6e:	8b 40 10             	mov    0x10(%eax),%eax
80107f71:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107f76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f79:	8b 50 1c             	mov    0x1c(%eax),%edx
80107f7c:	8b 40 18             	mov    0x18(%eax),%eax
80107f7f:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107f84:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107f8a:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107f8f:	29 d0                	sub    %edx,%eax
80107f91:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107f96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f99:	8b 50 24             	mov    0x24(%eax),%edx
80107f9c:	8b 40 20             	mov    0x20(%eax),%eax
80107f9f:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107fa7:	8b 50 2c             	mov    0x2c(%eax),%edx
80107faa:	8b 40 28             	mov    0x28(%eax),%eax
80107fad:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107fb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107fb5:	8b 50 34             	mov    0x34(%eax),%edx
80107fb8:	8b 40 30             	mov    0x30(%eax),%eax
80107fbb:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107fc0:	90                   	nop
80107fc1:	c9                   	leave  
80107fc2:	c3                   	ret    

80107fc3 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107fc3:	55                   	push   %ebp
80107fc4:	89 e5                	mov    %esp,%ebp
80107fc6:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107fc9:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd2:	0f af d0             	imul   %eax,%edx
80107fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd8:	01 d0                	add    %edx,%eax
80107fda:	c1 e0 02             	shl    $0x2,%eax
80107fdd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107fe0:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107fe9:	01 d0                	add    %edx,%eax
80107feb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107fee:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff1:	0f b6 10             	movzbl (%eax),%edx
80107ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ff7:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107ff9:	8b 45 10             	mov    0x10(%ebp),%eax
80107ffc:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108000:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108003:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108006:	8b 45 10             	mov    0x10(%ebp),%eax
80108009:	0f b6 50 02          	movzbl 0x2(%eax),%edx
8010800d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108010:	88 50 02             	mov    %dl,0x2(%eax)
}
80108013:	90                   	nop
80108014:	c9                   	leave  
80108015:	c3                   	ret    

80108016 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108016:	55                   	push   %ebp
80108017:	89 e5                	mov    %esp,%ebp
80108019:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010801c:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80108022:	8b 45 08             	mov    0x8(%ebp),%eax
80108025:	0f af c2             	imul   %edx,%eax
80108028:	c1 e0 02             	shl    $0x2,%eax
8010802b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
8010802e:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80108033:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108036:	29 d0                	sub    %edx,%eax
80108038:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
8010803e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108041:	01 ca                	add    %ecx,%edx
80108043:	89 d1                	mov    %edx,%ecx
80108045:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
8010804b:	83 ec 04             	sub    $0x4,%esp
8010804e:	50                   	push   %eax
8010804f:	51                   	push   %ecx
80108050:	52                   	push   %edx
80108051:	e8 2d cb ff ff       	call   80104b83 <memmove>
80108056:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805c:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80108062:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80108068:	01 ca                	add    %ecx,%edx
8010806a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010806d:	29 ca                	sub    %ecx,%edx
8010806f:	83 ec 04             	sub    $0x4,%esp
80108072:	50                   	push   %eax
80108073:	6a 00                	push   $0x0
80108075:	52                   	push   %edx
80108076:	e8 49 ca ff ff       	call   80104ac4 <memset>
8010807b:	83 c4 10             	add    $0x10,%esp
}
8010807e:	90                   	nop
8010807f:	c9                   	leave  
80108080:	c3                   	ret    

80108081 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108081:	55                   	push   %ebp
80108082:	89 e5                	mov    %esp,%ebp
80108084:	53                   	push   %ebx
80108085:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108088:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010808f:	e9 b1 00 00 00       	jmp    80108145 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108094:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010809b:	e9 97 00 00 00       	jmp    80108137 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801080a0:	8b 45 10             	mov    0x10(%ebp),%eax
801080a3:	83 e8 20             	sub    $0x20,%eax
801080a6:	6b d0 1e             	imul   $0x1e,%eax,%edx
801080a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ac:	01 d0                	add    %edx,%eax
801080ae:	0f b7 84 00 00 a9 10 	movzwl -0x7fef5700(%eax,%eax,1),%eax
801080b5:	80 
801080b6:	0f b7 d0             	movzwl %ax,%edx
801080b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bc:	bb 01 00 00 00       	mov    $0x1,%ebx
801080c1:	89 c1                	mov    %eax,%ecx
801080c3:	d3 e3                	shl    %cl,%ebx
801080c5:	89 d8                	mov    %ebx,%eax
801080c7:	21 d0                	and    %edx,%eax
801080c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801080cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cf:	ba 01 00 00 00       	mov    $0x1,%edx
801080d4:	89 c1                	mov    %eax,%ecx
801080d6:	d3 e2                	shl    %cl,%edx
801080d8:	89 d0                	mov    %edx,%eax
801080da:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801080dd:	75 2b                	jne    8010810a <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801080df:	8b 55 0c             	mov    0xc(%ebp),%edx
801080e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e5:	01 c2                	add    %eax,%edx
801080e7:	b8 0e 00 00 00       	mov    $0xe,%eax
801080ec:	2b 45 f0             	sub    -0x10(%ebp),%eax
801080ef:	89 c1                	mov    %eax,%ecx
801080f1:	8b 45 08             	mov    0x8(%ebp),%eax
801080f4:	01 c8                	add    %ecx,%eax
801080f6:	83 ec 04             	sub    $0x4,%esp
801080f9:	68 e0 f4 10 80       	push   $0x8010f4e0
801080fe:	52                   	push   %edx
801080ff:	50                   	push   %eax
80108100:	e8 be fe ff ff       	call   80107fc3 <graphic_draw_pixel>
80108105:	83 c4 10             	add    $0x10,%esp
80108108:	eb 29                	jmp    80108133 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010810a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010810d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108110:	01 c2                	add    %eax,%edx
80108112:	b8 0e 00 00 00       	mov    $0xe,%eax
80108117:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010811a:	89 c1                	mov    %eax,%ecx
8010811c:	8b 45 08             	mov    0x8(%ebp),%eax
8010811f:	01 c8                	add    %ecx,%eax
80108121:	83 ec 04             	sub    $0x4,%esp
80108124:	68 60 6c 19 80       	push   $0x80196c60
80108129:	52                   	push   %edx
8010812a:	50                   	push   %eax
8010812b:	e8 93 fe ff ff       	call   80107fc3 <graphic_draw_pixel>
80108130:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108133:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108137:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010813b:	0f 89 5f ff ff ff    	jns    801080a0 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108141:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108145:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108149:	0f 8e 45 ff ff ff    	jle    80108094 <font_render+0x13>
      }
    }
  }
}
8010814f:	90                   	nop
80108150:	90                   	nop
80108151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108154:	c9                   	leave  
80108155:	c3                   	ret    

80108156 <font_render_string>:

void font_render_string(char *string,int row){
80108156:	55                   	push   %ebp
80108157:	89 e5                	mov    %esp,%ebp
80108159:	53                   	push   %ebx
8010815a:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010815d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108164:	eb 33                	jmp    80108199 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108166:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108169:	8b 45 08             	mov    0x8(%ebp),%eax
8010816c:	01 d0                	add    %edx,%eax
8010816e:	0f b6 00             	movzbl (%eax),%eax
80108171:	0f be c8             	movsbl %al,%ecx
80108174:	8b 45 0c             	mov    0xc(%ebp),%eax
80108177:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010817a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010817d:	89 d8                	mov    %ebx,%eax
8010817f:	c1 e0 04             	shl    $0x4,%eax
80108182:	29 d8                	sub    %ebx,%eax
80108184:	83 c0 02             	add    $0x2,%eax
80108187:	83 ec 04             	sub    $0x4,%esp
8010818a:	51                   	push   %ecx
8010818b:	52                   	push   %edx
8010818c:	50                   	push   %eax
8010818d:	e8 ef fe ff ff       	call   80108081 <font_render>
80108192:	83 c4 10             	add    $0x10,%esp
    i++;
80108195:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108199:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010819c:	8b 45 08             	mov    0x8(%ebp),%eax
8010819f:	01 d0                	add    %edx,%eax
801081a1:	0f b6 00             	movzbl (%eax),%eax
801081a4:	84 c0                	test   %al,%al
801081a6:	74 06                	je     801081ae <font_render_string+0x58>
801081a8:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801081ac:	7e b8                	jle    80108166 <font_render_string+0x10>
  }
}
801081ae:	90                   	nop
801081af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081b2:	c9                   	leave  
801081b3:	c3                   	ret    

801081b4 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801081b4:	55                   	push   %ebp
801081b5:	89 e5                	mov    %esp,%ebp
801081b7:	53                   	push   %ebx
801081b8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801081bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081c2:	eb 6b                	jmp    8010822f <pci_init+0x7b>
    for(int j=0;j<32;j++){
801081c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801081cb:	eb 58                	jmp    80108225 <pci_init+0x71>
      for(int k=0;k<8;k++){
801081cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801081d4:	eb 45                	jmp    8010821b <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801081d6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801081d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801081dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081df:	83 ec 0c             	sub    $0xc,%esp
801081e2:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801081e5:	53                   	push   %ebx
801081e6:	6a 00                	push   $0x0
801081e8:	51                   	push   %ecx
801081e9:	52                   	push   %edx
801081ea:	50                   	push   %eax
801081eb:	e8 b0 00 00 00       	call   801082a0 <pci_access_config>
801081f0:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801081f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081f6:	0f b7 c0             	movzwl %ax,%eax
801081f9:	3d ff ff 00 00       	cmp    $0xffff,%eax
801081fe:	74 17                	je     80108217 <pci_init+0x63>
        pci_init_device(i,j,k);
80108200:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108203:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108209:	83 ec 04             	sub    $0x4,%esp
8010820c:	51                   	push   %ecx
8010820d:	52                   	push   %edx
8010820e:	50                   	push   %eax
8010820f:	e8 37 01 00 00       	call   8010834b <pci_init_device>
80108214:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108217:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010821b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010821f:	7e b5                	jle    801081d6 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108221:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108225:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108229:	7e a2                	jle    801081cd <pci_init+0x19>
  for(int i=0;i<256;i++){
8010822b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010822f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108236:	7e 8c                	jle    801081c4 <pci_init+0x10>
      }
      }
    }
  }
}
80108238:	90                   	nop
80108239:	90                   	nop
8010823a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010823d:	c9                   	leave  
8010823e:	c3                   	ret    

8010823f <pci_write_config>:

void pci_write_config(uint config){
8010823f:	55                   	push   %ebp
80108240:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108242:	8b 45 08             	mov    0x8(%ebp),%eax
80108245:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010824a:	89 c0                	mov    %eax,%eax
8010824c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010824d:	90                   	nop
8010824e:	5d                   	pop    %ebp
8010824f:	c3                   	ret    

80108250 <pci_write_data>:

void pci_write_data(uint config){
80108250:	55                   	push   %ebp
80108251:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108253:	8b 45 08             	mov    0x8(%ebp),%eax
80108256:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010825b:	89 c0                	mov    %eax,%eax
8010825d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010825e:	90                   	nop
8010825f:	5d                   	pop    %ebp
80108260:	c3                   	ret    

80108261 <pci_read_config>:
uint pci_read_config(){
80108261:	55                   	push   %ebp
80108262:	89 e5                	mov    %esp,%ebp
80108264:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108267:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010826c:	ed                   	in     (%dx),%eax
8010826d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108270:	83 ec 0c             	sub    $0xc,%esp
80108273:	68 c8 00 00 00       	push   $0xc8
80108278:	e8 bb a8 ff ff       	call   80102b38 <microdelay>
8010827d:	83 c4 10             	add    $0x10,%esp
  return data;
80108280:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108283:	c9                   	leave  
80108284:	c3                   	ret    

80108285 <pci_test>:


void pci_test(){
80108285:	55                   	push   %ebp
80108286:	89 e5                	mov    %esp,%ebp
80108288:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010828b:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108292:	ff 75 fc             	push   -0x4(%ebp)
80108295:	e8 a5 ff ff ff       	call   8010823f <pci_write_config>
8010829a:	83 c4 04             	add    $0x4,%esp
}
8010829d:	90                   	nop
8010829e:	c9                   	leave  
8010829f:	c3                   	ret    

801082a0 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801082a0:	55                   	push   %ebp
801082a1:	89 e5                	mov    %esp,%ebp
801082a3:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801082a6:	8b 45 08             	mov    0x8(%ebp),%eax
801082a9:	c1 e0 10             	shl    $0x10,%eax
801082ac:	25 00 00 ff 00       	and    $0xff0000,%eax
801082b1:	89 c2                	mov    %eax,%edx
801082b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b6:	c1 e0 0b             	shl    $0xb,%eax
801082b9:	0f b7 c0             	movzwl %ax,%eax
801082bc:	09 c2                	or     %eax,%edx
801082be:	8b 45 10             	mov    0x10(%ebp),%eax
801082c1:	c1 e0 08             	shl    $0x8,%eax
801082c4:	25 00 07 00 00       	and    $0x700,%eax
801082c9:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801082cb:	8b 45 14             	mov    0x14(%ebp),%eax
801082ce:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801082d3:	09 d0                	or     %edx,%eax
801082d5:	0d 00 00 00 80       	or     $0x80000000,%eax
801082da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801082dd:	ff 75 f4             	push   -0xc(%ebp)
801082e0:	e8 5a ff ff ff       	call   8010823f <pci_write_config>
801082e5:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801082e8:	e8 74 ff ff ff       	call   80108261 <pci_read_config>
801082ed:	8b 55 18             	mov    0x18(%ebp),%edx
801082f0:	89 02                	mov    %eax,(%edx)
}
801082f2:	90                   	nop
801082f3:	c9                   	leave  
801082f4:	c3                   	ret    

801082f5 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801082f5:	55                   	push   %ebp
801082f6:	89 e5                	mov    %esp,%ebp
801082f8:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801082fb:	8b 45 08             	mov    0x8(%ebp),%eax
801082fe:	c1 e0 10             	shl    $0x10,%eax
80108301:	25 00 00 ff 00       	and    $0xff0000,%eax
80108306:	89 c2                	mov    %eax,%edx
80108308:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830b:	c1 e0 0b             	shl    $0xb,%eax
8010830e:	0f b7 c0             	movzwl %ax,%eax
80108311:	09 c2                	or     %eax,%edx
80108313:	8b 45 10             	mov    0x10(%ebp),%eax
80108316:	c1 e0 08             	shl    $0x8,%eax
80108319:	25 00 07 00 00       	and    $0x700,%eax
8010831e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108320:	8b 45 14             	mov    0x14(%ebp),%eax
80108323:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108328:	09 d0                	or     %edx,%eax
8010832a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010832f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108332:	ff 75 fc             	push   -0x4(%ebp)
80108335:	e8 05 ff ff ff       	call   8010823f <pci_write_config>
8010833a:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010833d:	ff 75 18             	push   0x18(%ebp)
80108340:	e8 0b ff ff ff       	call   80108250 <pci_write_data>
80108345:	83 c4 04             	add    $0x4,%esp
}
80108348:	90                   	nop
80108349:	c9                   	leave  
8010834a:	c3                   	ret    

8010834b <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010834b:	55                   	push   %ebp
8010834c:	89 e5                	mov    %esp,%ebp
8010834e:	53                   	push   %ebx
8010834f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108352:	8b 45 08             	mov    0x8(%ebp),%eax
80108355:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
8010835a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010835d:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
80108362:	8b 45 10             	mov    0x10(%ebp),%eax
80108365:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010836a:	ff 75 10             	push   0x10(%ebp)
8010836d:	ff 75 0c             	push   0xc(%ebp)
80108370:	ff 75 08             	push   0x8(%ebp)
80108373:	68 44 bf 10 80       	push   $0x8010bf44
80108378:	e8 77 80 ff ff       	call   801003f4 <cprintf>
8010837d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108380:	83 ec 0c             	sub    $0xc,%esp
80108383:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108386:	50                   	push   %eax
80108387:	6a 00                	push   $0x0
80108389:	ff 75 10             	push   0x10(%ebp)
8010838c:	ff 75 0c             	push   0xc(%ebp)
8010838f:	ff 75 08             	push   0x8(%ebp)
80108392:	e8 09 ff ff ff       	call   801082a0 <pci_access_config>
80108397:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010839a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010839d:	c1 e8 10             	shr    $0x10,%eax
801083a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801083a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a6:	25 ff ff 00 00       	and    $0xffff,%eax
801083ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801083ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b1:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
801083b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b9:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801083be:	83 ec 04             	sub    $0x4,%esp
801083c1:	ff 75 f0             	push   -0x10(%ebp)
801083c4:	ff 75 f4             	push   -0xc(%ebp)
801083c7:	68 78 bf 10 80       	push   $0x8010bf78
801083cc:	e8 23 80 ff ff       	call   801003f4 <cprintf>
801083d1:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801083d4:	83 ec 0c             	sub    $0xc,%esp
801083d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083da:	50                   	push   %eax
801083db:	6a 08                	push   $0x8
801083dd:	ff 75 10             	push   0x10(%ebp)
801083e0:	ff 75 0c             	push   0xc(%ebp)
801083e3:	ff 75 08             	push   0x8(%ebp)
801083e6:	e8 b5 fe ff ff       	call   801082a0 <pci_access_config>
801083eb:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801083ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f1:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801083f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f7:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801083fa:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801083fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108400:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108403:	0f b6 c0             	movzbl %al,%eax
80108406:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108409:	c1 eb 18             	shr    $0x18,%ebx
8010840c:	83 ec 0c             	sub    $0xc,%esp
8010840f:	51                   	push   %ecx
80108410:	52                   	push   %edx
80108411:	50                   	push   %eax
80108412:	53                   	push   %ebx
80108413:	68 9c bf 10 80       	push   $0x8010bf9c
80108418:	e8 d7 7f ff ff       	call   801003f4 <cprintf>
8010841d:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108420:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108423:	c1 e8 18             	shr    $0x18,%eax
80108426:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
8010842b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010842e:	c1 e8 10             	shr    $0x10,%eax
80108431:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
80108436:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108439:	c1 e8 08             	shr    $0x8,%eax
8010843c:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
80108441:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108444:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108449:	83 ec 0c             	sub    $0xc,%esp
8010844c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010844f:	50                   	push   %eax
80108450:	6a 10                	push   $0x10
80108452:	ff 75 10             	push   0x10(%ebp)
80108455:	ff 75 0c             	push   0xc(%ebp)
80108458:	ff 75 08             	push   0x8(%ebp)
8010845b:	e8 40 fe ff ff       	call   801082a0 <pci_access_config>
80108460:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108466:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010846b:	83 ec 0c             	sub    $0xc,%esp
8010846e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108471:	50                   	push   %eax
80108472:	6a 14                	push   $0x14
80108474:	ff 75 10             	push   0x10(%ebp)
80108477:	ff 75 0c             	push   0xc(%ebp)
8010847a:	ff 75 08             	push   0x8(%ebp)
8010847d:	e8 1e fe ff ff       	call   801082a0 <pci_access_config>
80108482:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108488:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010848d:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108494:	75 5a                	jne    801084f0 <pci_init_device+0x1a5>
80108496:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010849d:	75 51                	jne    801084f0 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
8010849f:	83 ec 0c             	sub    $0xc,%esp
801084a2:	68 e1 bf 10 80       	push   $0x8010bfe1
801084a7:	e8 48 7f ff ff       	call   801003f4 <cprintf>
801084ac:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801084af:	83 ec 0c             	sub    $0xc,%esp
801084b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084b5:	50                   	push   %eax
801084b6:	68 f0 00 00 00       	push   $0xf0
801084bb:	ff 75 10             	push   0x10(%ebp)
801084be:	ff 75 0c             	push   0xc(%ebp)
801084c1:	ff 75 08             	push   0x8(%ebp)
801084c4:	e8 d7 fd ff ff       	call   801082a0 <pci_access_config>
801084c9:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801084cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084cf:	83 ec 08             	sub    $0x8,%esp
801084d2:	50                   	push   %eax
801084d3:	68 fb bf 10 80       	push   $0x8010bffb
801084d8:	e8 17 7f ff ff       	call   801003f4 <cprintf>
801084dd:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801084e0:	83 ec 0c             	sub    $0xc,%esp
801084e3:	68 64 6c 19 80       	push   $0x80196c64
801084e8:	e8 09 00 00 00       	call   801084f6 <i8254_init>
801084ed:	83 c4 10             	add    $0x10,%esp
  }
}
801084f0:	90                   	nop
801084f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084f4:	c9                   	leave  
801084f5:	c3                   	ret    

801084f6 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801084f6:	55                   	push   %ebp
801084f7:	89 e5                	mov    %esp,%ebp
801084f9:	53                   	push   %ebx
801084fa:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801084fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108500:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108504:	0f b6 c8             	movzbl %al,%ecx
80108507:	8b 45 08             	mov    0x8(%ebp),%eax
8010850a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010850e:	0f b6 d0             	movzbl %al,%edx
80108511:	8b 45 08             	mov    0x8(%ebp),%eax
80108514:	0f b6 00             	movzbl (%eax),%eax
80108517:	0f b6 c0             	movzbl %al,%eax
8010851a:	83 ec 0c             	sub    $0xc,%esp
8010851d:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108520:	53                   	push   %ebx
80108521:	6a 04                	push   $0x4
80108523:	51                   	push   %ecx
80108524:	52                   	push   %edx
80108525:	50                   	push   %eax
80108526:	e8 75 fd ff ff       	call   801082a0 <pci_access_config>
8010852b:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010852e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108531:	83 c8 04             	or     $0x4,%eax
80108534:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108537:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010853a:	8b 45 08             	mov    0x8(%ebp),%eax
8010853d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108541:	0f b6 c8             	movzbl %al,%ecx
80108544:	8b 45 08             	mov    0x8(%ebp),%eax
80108547:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010854b:	0f b6 d0             	movzbl %al,%edx
8010854e:	8b 45 08             	mov    0x8(%ebp),%eax
80108551:	0f b6 00             	movzbl (%eax),%eax
80108554:	0f b6 c0             	movzbl %al,%eax
80108557:	83 ec 0c             	sub    $0xc,%esp
8010855a:	53                   	push   %ebx
8010855b:	6a 04                	push   $0x4
8010855d:	51                   	push   %ecx
8010855e:	52                   	push   %edx
8010855f:	50                   	push   %eax
80108560:	e8 90 fd ff ff       	call   801082f5 <pci_write_config_register>
80108565:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108568:	8b 45 08             	mov    0x8(%ebp),%eax
8010856b:	8b 40 10             	mov    0x10(%eax),%eax
8010856e:	05 00 00 00 40       	add    $0x40000000,%eax
80108573:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
80108578:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010857d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108580:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108585:	05 d8 00 00 00       	add    $0xd8,%eax
8010858a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010858d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108590:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	8b 00                	mov    (%eax),%eax
8010859b:	0d 00 00 00 04       	or     $0x4000000,%eax
801085a0:	89 c2                	mov    %eax,%edx
801085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a5:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801085a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085aa:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801085b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b3:	8b 00                	mov    (%eax),%eax
801085b5:	83 c8 40             	or     $0x40,%eax
801085b8:	89 c2                	mov    %eax,%edx
801085ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bd:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801085bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c2:	8b 10                	mov    (%eax),%edx
801085c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c7:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801085c9:	83 ec 0c             	sub    $0xc,%esp
801085cc:	68 10 c0 10 80       	push   $0x8010c010
801085d1:	e8 1e 7e ff ff       	call   801003f4 <cprintf>
801085d6:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801085d9:	e8 c3 a1 ff ff       	call   801027a1 <kalloc>
801085de:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
801085e3:	a1 88 6c 19 80       	mov    0x80196c88,%eax
801085e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801085ee:	a1 88 6c 19 80       	mov    0x80196c88,%eax
801085f3:	83 ec 08             	sub    $0x8,%esp
801085f6:	50                   	push   %eax
801085f7:	68 32 c0 10 80       	push   $0x8010c032
801085fc:	e8 f3 7d ff ff       	call   801003f4 <cprintf>
80108601:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108604:	e8 50 00 00 00       	call   80108659 <i8254_init_recv>
  i8254_init_send();
80108609:	e8 69 03 00 00       	call   80108977 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010860e:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108615:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108618:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010861f:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108622:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108629:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010862c:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108633:	0f b6 c0             	movzbl %al,%eax
80108636:	83 ec 0c             	sub    $0xc,%esp
80108639:	53                   	push   %ebx
8010863a:	51                   	push   %ecx
8010863b:	52                   	push   %edx
8010863c:	50                   	push   %eax
8010863d:	68 40 c0 10 80       	push   $0x8010c040
80108642:	e8 ad 7d ff ff       	call   801003f4 <cprintf>
80108647:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010864a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010864d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108653:	90                   	nop
80108654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108657:	c9                   	leave  
80108658:	c3                   	ret    

80108659 <i8254_init_recv>:

void i8254_init_recv(){
80108659:	55                   	push   %ebp
8010865a:	89 e5                	mov    %esp,%ebp
8010865c:	57                   	push   %edi
8010865d:	56                   	push   %esi
8010865e:	53                   	push   %ebx
8010865f:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108662:	83 ec 0c             	sub    $0xc,%esp
80108665:	6a 00                	push   $0x0
80108667:	e8 e8 04 00 00       	call   80108b54 <i8254_read_eeprom>
8010866c:	83 c4 10             	add    $0x10,%esp
8010866f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108672:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108675:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
8010867a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010867d:	c1 e8 08             	shr    $0x8,%eax
80108680:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
80108685:	83 ec 0c             	sub    $0xc,%esp
80108688:	6a 01                	push   $0x1
8010868a:	e8 c5 04 00 00       	call   80108b54 <i8254_read_eeprom>
8010868f:	83 c4 10             	add    $0x10,%esp
80108692:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108695:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108698:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
8010869d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801086a0:	c1 e8 08             	shr    $0x8,%eax
801086a3:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
801086a8:	83 ec 0c             	sub    $0xc,%esp
801086ab:	6a 02                	push   $0x2
801086ad:	e8 a2 04 00 00       	call   80108b54 <i8254_read_eeprom>
801086b2:	83 c4 10             	add    $0x10,%esp
801086b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801086b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801086bb:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
801086c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801086c3:	c1 e8 08             	shr    $0x8,%eax
801086c6:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801086cb:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801086d2:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801086d5:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801086dc:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801086df:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801086e6:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801086e9:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801086f0:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801086f3:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801086fa:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801086fd:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108704:	0f b6 c0             	movzbl %al,%eax
80108707:	83 ec 04             	sub    $0x4,%esp
8010870a:	57                   	push   %edi
8010870b:	56                   	push   %esi
8010870c:	53                   	push   %ebx
8010870d:	51                   	push   %ecx
8010870e:	52                   	push   %edx
8010870f:	50                   	push   %eax
80108710:	68 58 c0 10 80       	push   $0x8010c058
80108715:	e8 da 7c ff ff       	call   801003f4 <cprintf>
8010871a:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010871d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108722:	05 00 54 00 00       	add    $0x5400,%eax
80108727:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010872a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010872f:	05 04 54 00 00       	add    $0x5404,%eax
80108734:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108737:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010873a:	c1 e0 10             	shl    $0x10,%eax
8010873d:	0b 45 d8             	or     -0x28(%ebp),%eax
80108740:	89 c2                	mov    %eax,%edx
80108742:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108745:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108747:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010874a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010874f:	89 c2                	mov    %eax,%edx
80108751:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108754:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108756:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010875b:	05 00 52 00 00       	add    $0x5200,%eax
80108760:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108763:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010876a:	eb 19                	jmp    80108785 <i8254_init_recv+0x12c>
    mta[i] = 0;
8010876c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010876f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108776:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108779:	01 d0                	add    %edx,%eax
8010877b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108781:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108785:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108789:	7e e1                	jle    8010876c <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
8010878b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108790:	05 d0 00 00 00       	add    $0xd0,%eax
80108795:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108798:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010879b:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801087a1:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087a6:	05 c8 00 00 00       	add    $0xc8,%eax
801087ab:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801087ae:	8b 45 bc             	mov    -0x44(%ebp),%eax
801087b1:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801087b7:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087bc:	05 28 28 00 00       	add    $0x2828,%eax
801087c1:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801087c4:	8b 45 b8             	mov    -0x48(%ebp),%eax
801087c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801087cd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087d2:	05 00 01 00 00       	add    $0x100,%eax
801087d7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801087da:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087dd:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801087e3:	e8 b9 9f ff ff       	call   801027a1 <kalloc>
801087e8:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801087eb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087f0:	05 00 28 00 00       	add    $0x2800,%eax
801087f5:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801087f8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801087fd:	05 04 28 00 00       	add    $0x2804,%eax
80108802:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108805:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010880a:	05 08 28 00 00       	add    $0x2808,%eax
8010880f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108812:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108817:	05 10 28 00 00       	add    $0x2810,%eax
8010881c:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010881f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108824:	05 18 28 00 00       	add    $0x2818,%eax
80108829:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010882c:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010882f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108835:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108838:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010883a:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010883d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108843:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108846:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010884c:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010884f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108855:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108858:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010885e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108861:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108864:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010886b:	eb 73                	jmp    801088e0 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
8010886d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108870:	c1 e0 04             	shl    $0x4,%eax
80108873:	89 c2                	mov    %eax,%edx
80108875:	8b 45 98             	mov    -0x68(%ebp),%eax
80108878:	01 d0                	add    %edx,%eax
8010887a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108881:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108884:	c1 e0 04             	shl    $0x4,%eax
80108887:	89 c2                	mov    %eax,%edx
80108889:	8b 45 98             	mov    -0x68(%ebp),%eax
8010888c:	01 d0                	add    %edx,%eax
8010888e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108894:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108897:	c1 e0 04             	shl    $0x4,%eax
8010889a:	89 c2                	mov    %eax,%edx
8010889c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010889f:	01 d0                	add    %edx,%eax
801088a1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801088a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088aa:	c1 e0 04             	shl    $0x4,%eax
801088ad:	89 c2                	mov    %eax,%edx
801088af:	8b 45 98             	mov    -0x68(%ebp),%eax
801088b2:	01 d0                	add    %edx,%eax
801088b4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801088b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088bb:	c1 e0 04             	shl    $0x4,%eax
801088be:	89 c2                	mov    %eax,%edx
801088c0:	8b 45 98             	mov    -0x68(%ebp),%eax
801088c3:	01 d0                	add    %edx,%eax
801088c5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801088c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088cc:	c1 e0 04             	shl    $0x4,%eax
801088cf:	89 c2                	mov    %eax,%edx
801088d1:	8b 45 98             	mov    -0x68(%ebp),%eax
801088d4:	01 d0                	add    %edx,%eax
801088d6:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801088dc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801088e0:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801088e7:	7e 84                	jle    8010886d <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801088e9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801088f0:	eb 57                	jmp    80108949 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801088f2:	e8 aa 9e ff ff       	call   801027a1 <kalloc>
801088f7:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801088fa:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801088fe:	75 12                	jne    80108912 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108900:	83 ec 0c             	sub    $0xc,%esp
80108903:	68 78 c0 10 80       	push   $0x8010c078
80108908:	e8 e7 7a ff ff       	call   801003f4 <cprintf>
8010890d:	83 c4 10             	add    $0x10,%esp
      break;
80108910:	eb 3d                	jmp    8010894f <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108912:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108915:	c1 e0 04             	shl    $0x4,%eax
80108918:	89 c2                	mov    %eax,%edx
8010891a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010891d:	01 d0                	add    %edx,%eax
8010891f:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108922:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108928:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010892a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010892d:	83 c0 01             	add    $0x1,%eax
80108930:	c1 e0 04             	shl    $0x4,%eax
80108933:	89 c2                	mov    %eax,%edx
80108935:	8b 45 98             	mov    -0x68(%ebp),%eax
80108938:	01 d0                	add    %edx,%eax
8010893a:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010893d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108943:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108945:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108949:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010894d:	7e a3                	jle    801088f2 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
8010894f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108952:	8b 00                	mov    (%eax),%eax
80108954:	83 c8 02             	or     $0x2,%eax
80108957:	89 c2                	mov    %eax,%edx
80108959:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010895c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010895e:	83 ec 0c             	sub    $0xc,%esp
80108961:	68 98 c0 10 80       	push   $0x8010c098
80108966:	e8 89 7a ff ff       	call   801003f4 <cprintf>
8010896b:	83 c4 10             	add    $0x10,%esp
}
8010896e:	90                   	nop
8010896f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108972:	5b                   	pop    %ebx
80108973:	5e                   	pop    %esi
80108974:	5f                   	pop    %edi
80108975:	5d                   	pop    %ebp
80108976:	c3                   	ret    

80108977 <i8254_init_send>:

void i8254_init_send(){
80108977:	55                   	push   %ebp
80108978:	89 e5                	mov    %esp,%ebp
8010897a:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
8010897d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108982:	05 28 38 00 00       	add    $0x3828,%eax
80108987:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010898a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898d:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108993:	e8 09 9e ff ff       	call   801027a1 <kalloc>
80108998:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010899b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801089a0:	05 00 38 00 00       	add    $0x3800,%eax
801089a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801089a8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801089ad:	05 04 38 00 00       	add    $0x3804,%eax
801089b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801089b5:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801089ba:	05 08 38 00 00       	add    $0x3808,%eax
801089bf:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801089c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801089cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089ce:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801089d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801089d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089dc:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801089e2:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801089e7:	05 10 38 00 00       	add    $0x3810,%eax
801089ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801089ef:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801089f4:	05 18 38 00 00       	add    $0x3818,%eax
801089f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801089fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108a05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108a0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a11:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a1b:	e9 82 00 00 00       	jmp    80108aa2 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a23:	c1 e0 04             	shl    $0x4,%eax
80108a26:	89 c2                	mov    %eax,%edx
80108a28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a2b:	01 d0                	add    %edx,%eax
80108a2d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a37:	c1 e0 04             	shl    $0x4,%eax
80108a3a:	89 c2                	mov    %eax,%edx
80108a3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a3f:	01 d0                	add    %edx,%eax
80108a41:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4a:	c1 e0 04             	shl    $0x4,%eax
80108a4d:	89 c2                	mov    %eax,%edx
80108a4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a52:	01 d0                	add    %edx,%eax
80108a54:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5b:	c1 e0 04             	shl    $0x4,%eax
80108a5e:	89 c2                	mov    %eax,%edx
80108a60:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a63:	01 d0                	add    %edx,%eax
80108a65:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6c:	c1 e0 04             	shl    $0x4,%eax
80108a6f:	89 c2                	mov    %eax,%edx
80108a71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a74:	01 d0                	add    %edx,%eax
80108a76:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7d:	c1 e0 04             	shl    $0x4,%eax
80108a80:	89 c2                	mov    %eax,%edx
80108a82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a85:	01 d0                	add    %edx,%eax
80108a87:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8e:	c1 e0 04             	shl    $0x4,%eax
80108a91:	89 c2                	mov    %eax,%edx
80108a93:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a96:	01 d0                	add    %edx,%eax
80108a98:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108aa2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108aa9:	0f 8e 71 ff ff ff    	jle    80108a20 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108aaf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ab6:	eb 57                	jmp    80108b0f <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108ab8:	e8 e4 9c ff ff       	call   801027a1 <kalloc>
80108abd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ac0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ac4:	75 12                	jne    80108ad8 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108ac6:	83 ec 0c             	sub    $0xc,%esp
80108ac9:	68 78 c0 10 80       	push   $0x8010c078
80108ace:	e8 21 79 ff ff       	call   801003f4 <cprintf>
80108ad3:	83 c4 10             	add    $0x10,%esp
      break;
80108ad6:	eb 3d                	jmp    80108b15 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108adb:	c1 e0 04             	shl    $0x4,%eax
80108ade:	89 c2                	mov    %eax,%edx
80108ae0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ae3:	01 d0                	add    %edx,%eax
80108ae5:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ae8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108aee:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af3:	83 c0 01             	add    $0x1,%eax
80108af6:	c1 e0 04             	shl    $0x4,%eax
80108af9:	89 c2                	mov    %eax,%edx
80108afb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108afe:	01 d0                	add    %edx,%eax
80108b00:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108b03:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b09:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108b0b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108b0f:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108b13:	7e a3                	jle    80108ab8 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108b15:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b1a:	05 00 04 00 00       	add    $0x400,%eax
80108b1f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108b22:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b25:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108b2b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b30:	05 10 04 00 00       	add    $0x410,%eax
80108b35:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108b38:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b3b:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108b41:	83 ec 0c             	sub    $0xc,%esp
80108b44:	68 b8 c0 10 80       	push   $0x8010c0b8
80108b49:	e8 a6 78 ff ff       	call   801003f4 <cprintf>
80108b4e:	83 c4 10             	add    $0x10,%esp

}
80108b51:	90                   	nop
80108b52:	c9                   	leave  
80108b53:	c3                   	ret    

80108b54 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108b54:	55                   	push   %ebp
80108b55:	89 e5                	mov    %esp,%ebp
80108b57:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108b5a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b5f:	83 c0 14             	add    $0x14,%eax
80108b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108b65:	8b 45 08             	mov    0x8(%ebp),%eax
80108b68:	c1 e0 08             	shl    $0x8,%eax
80108b6b:	0f b7 c0             	movzwl %ax,%eax
80108b6e:	83 c8 01             	or     $0x1,%eax
80108b71:	89 c2                	mov    %eax,%edx
80108b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b76:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108b78:	83 ec 0c             	sub    $0xc,%esp
80108b7b:	68 d8 c0 10 80       	push   $0x8010c0d8
80108b80:	e8 6f 78 ff ff       	call   801003f4 <cprintf>
80108b85:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8b:	8b 00                	mov    (%eax),%eax
80108b8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b93:	83 e0 10             	and    $0x10,%eax
80108b96:	85 c0                	test   %eax,%eax
80108b98:	75 02                	jne    80108b9c <i8254_read_eeprom+0x48>
  while(1){
80108b9a:	eb dc                	jmp    80108b78 <i8254_read_eeprom+0x24>
      break;
80108b9c:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba0:	8b 00                	mov    (%eax),%eax
80108ba2:	c1 e8 10             	shr    $0x10,%eax
}
80108ba5:	c9                   	leave  
80108ba6:	c3                   	ret    

80108ba7 <i8254_recv>:
void i8254_recv(){
80108ba7:	55                   	push   %ebp
80108ba8:	89 e5                	mov    %esp,%ebp
80108baa:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108bad:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bb2:	05 10 28 00 00       	add    $0x2810,%eax
80108bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108bba:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bbf:	05 18 28 00 00       	add    $0x2818,%eax
80108bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bc7:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bcc:	05 00 28 00 00       	add    $0x2800,%eax
80108bd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bd7:	8b 00                	mov    (%eax),%eax
80108bd9:	05 00 00 00 80       	add    $0x80000000,%eax
80108bde:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be4:	8b 10                	mov    (%eax),%edx
80108be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be9:	8b 08                	mov    (%eax),%ecx
80108beb:	89 d0                	mov    %edx,%eax
80108bed:	29 c8                	sub    %ecx,%eax
80108bef:	25 ff 00 00 00       	and    $0xff,%eax
80108bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108bf7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108bfb:	7e 37                	jle    80108c34 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c00:	8b 00                	mov    (%eax),%eax
80108c02:	c1 e0 04             	shl    $0x4,%eax
80108c05:	89 c2                	mov    %eax,%edx
80108c07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c0a:	01 d0                	add    %edx,%eax
80108c0c:	8b 00                	mov    (%eax),%eax
80108c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80108c13:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c19:	8b 00                	mov    (%eax),%eax
80108c1b:	83 c0 01             	add    $0x1,%eax
80108c1e:	0f b6 d0             	movzbl %al,%edx
80108c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c24:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108c26:	83 ec 0c             	sub    $0xc,%esp
80108c29:	ff 75 e0             	push   -0x20(%ebp)
80108c2c:	e8 15 09 00 00       	call   80109546 <eth_proc>
80108c31:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c37:	8b 10                	mov    (%eax),%edx
80108c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3c:	8b 00                	mov    (%eax),%eax
80108c3e:	39 c2                	cmp    %eax,%edx
80108c40:	75 9f                	jne    80108be1 <i8254_recv+0x3a>
      (*rdt)--;
80108c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c45:	8b 00                	mov    (%eax),%eax
80108c47:	8d 50 ff             	lea    -0x1(%eax),%edx
80108c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c4d:	89 10                	mov    %edx,(%eax)
  while(1){
80108c4f:	eb 90                	jmp    80108be1 <i8254_recv+0x3a>

80108c51 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108c51:	55                   	push   %ebp
80108c52:	89 e5                	mov    %esp,%ebp
80108c54:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108c57:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c5c:	05 10 38 00 00       	add    $0x3810,%eax
80108c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108c64:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c69:	05 18 38 00 00       	add    $0x3818,%eax
80108c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108c71:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108c76:	05 00 38 00 00       	add    $0x3800,%eax
80108c7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c81:	8b 00                	mov    (%eax),%eax
80108c83:	05 00 00 00 80       	add    $0x80000000,%eax
80108c88:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c8e:	8b 10                	mov    (%eax),%edx
80108c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c93:	8b 08                	mov    (%eax),%ecx
80108c95:	89 d0                	mov    %edx,%eax
80108c97:	29 c8                	sub    %ecx,%eax
80108c99:	0f b6 d0             	movzbl %al,%edx
80108c9c:	b8 00 01 00 00       	mov    $0x100,%eax
80108ca1:	29 d0                	sub    %edx,%eax
80108ca3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca9:	8b 00                	mov    (%eax),%eax
80108cab:	25 ff 00 00 00       	and    $0xff,%eax
80108cb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108cb3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108cb7:	0f 8e a8 00 00 00    	jle    80108d65 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108cc3:	89 d1                	mov    %edx,%ecx
80108cc5:	c1 e1 04             	shl    $0x4,%ecx
80108cc8:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108ccb:	01 ca                	add    %ecx,%edx
80108ccd:	8b 12                	mov    (%edx),%edx
80108ccf:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cd5:	83 ec 04             	sub    $0x4,%esp
80108cd8:	ff 75 0c             	push   0xc(%ebp)
80108cdb:	50                   	push   %eax
80108cdc:	52                   	push   %edx
80108cdd:	e8 a1 be ff ff       	call   80104b83 <memmove>
80108ce2:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ce8:	c1 e0 04             	shl    $0x4,%eax
80108ceb:	89 c2                	mov    %eax,%edx
80108ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cf0:	01 d0                	add    %edx,%eax
80108cf2:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cf5:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cfc:	c1 e0 04             	shl    $0x4,%eax
80108cff:	89 c2                	mov    %eax,%edx
80108d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d04:	01 d0                	add    %edx,%eax
80108d06:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108d0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d0d:	c1 e0 04             	shl    $0x4,%eax
80108d10:	89 c2                	mov    %eax,%edx
80108d12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d15:	01 d0                	add    %edx,%eax
80108d17:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108d1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d1e:	c1 e0 04             	shl    $0x4,%eax
80108d21:	89 c2                	mov    %eax,%edx
80108d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d26:	01 d0                	add    %edx,%eax
80108d28:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108d2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d2f:	c1 e0 04             	shl    $0x4,%eax
80108d32:	89 c2                	mov    %eax,%edx
80108d34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d37:	01 d0                	add    %edx,%eax
80108d39:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108d3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d42:	c1 e0 04             	shl    $0x4,%eax
80108d45:	89 c2                	mov    %eax,%edx
80108d47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d4a:	01 d0                	add    %edx,%eax
80108d4c:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d53:	8b 00                	mov    (%eax),%eax
80108d55:	83 c0 01             	add    $0x1,%eax
80108d58:	0f b6 d0             	movzbl %al,%edx
80108d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d5e:	89 10                	mov    %edx,(%eax)
    return len;
80108d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d63:	eb 05                	jmp    80108d6a <i8254_send+0x119>
  }else{
    return -1;
80108d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108d6a:	c9                   	leave  
80108d6b:	c3                   	ret    

80108d6c <i8254_intr>:

void i8254_intr(){
80108d6c:	55                   	push   %ebp
80108d6d:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108d6f:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108d74:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108d7a:	90                   	nop
80108d7b:	5d                   	pop    %ebp
80108d7c:	c3                   	ret    

80108d7d <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108d7d:	55                   	push   %ebp
80108d7e:	89 e5                	mov    %esp,%ebp
80108d80:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108d83:	8b 45 08             	mov    0x8(%ebp),%eax
80108d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8c:	0f b7 00             	movzwl (%eax),%eax
80108d8f:	66 3d 00 01          	cmp    $0x100,%ax
80108d93:	74 0a                	je     80108d9f <arp_proc+0x22>
80108d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d9a:	e9 4f 01 00 00       	jmp    80108eee <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da2:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108da6:	66 83 f8 08          	cmp    $0x8,%ax
80108daa:	74 0a                	je     80108db6 <arp_proc+0x39>
80108dac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108db1:	e9 38 01 00 00       	jmp    80108eee <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108dbd:	3c 06                	cmp    $0x6,%al
80108dbf:	74 0a                	je     80108dcb <arp_proc+0x4e>
80108dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108dc6:	e9 23 01 00 00       	jmp    80108eee <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dce:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108dd2:	3c 04                	cmp    $0x4,%al
80108dd4:	74 0a                	je     80108de0 <arp_proc+0x63>
80108dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ddb:	e9 0e 01 00 00       	jmp    80108eee <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de3:	83 c0 18             	add    $0x18,%eax
80108de6:	83 ec 04             	sub    $0x4,%esp
80108de9:	6a 04                	push   $0x4
80108deb:	50                   	push   %eax
80108dec:	68 e4 f4 10 80       	push   $0x8010f4e4
80108df1:	e8 35 bd ff ff       	call   80104b2b <memcmp>
80108df6:	83 c4 10             	add    $0x10,%esp
80108df9:	85 c0                	test   %eax,%eax
80108dfb:	74 27                	je     80108e24 <arp_proc+0xa7>
80108dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e00:	83 c0 0e             	add    $0xe,%eax
80108e03:	83 ec 04             	sub    $0x4,%esp
80108e06:	6a 04                	push   $0x4
80108e08:	50                   	push   %eax
80108e09:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e0e:	e8 18 bd ff ff       	call   80104b2b <memcmp>
80108e13:	83 c4 10             	add    $0x10,%esp
80108e16:	85 c0                	test   %eax,%eax
80108e18:	74 0a                	je     80108e24 <arp_proc+0xa7>
80108e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e1f:	e9 ca 00 00 00       	jmp    80108eee <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e27:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108e2b:	66 3d 00 01          	cmp    $0x100,%ax
80108e2f:	75 69                	jne    80108e9a <arp_proc+0x11d>
80108e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e34:	83 c0 18             	add    $0x18,%eax
80108e37:	83 ec 04             	sub    $0x4,%esp
80108e3a:	6a 04                	push   $0x4
80108e3c:	50                   	push   %eax
80108e3d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e42:	e8 e4 bc ff ff       	call   80104b2b <memcmp>
80108e47:	83 c4 10             	add    $0x10,%esp
80108e4a:	85 c0                	test   %eax,%eax
80108e4c:	75 4c                	jne    80108e9a <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108e4e:	e8 4e 99 ff ff       	call   801027a1 <kalloc>
80108e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108e56:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108e5d:	83 ec 04             	sub    $0x4,%esp
80108e60:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e63:	50                   	push   %eax
80108e64:	ff 75 f0             	push   -0x10(%ebp)
80108e67:	ff 75 f4             	push   -0xc(%ebp)
80108e6a:	e8 1f 04 00 00       	call   8010928e <arp_reply_pkt_create>
80108e6f:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e75:	83 ec 08             	sub    $0x8,%esp
80108e78:	50                   	push   %eax
80108e79:	ff 75 f0             	push   -0x10(%ebp)
80108e7c:	e8 d0 fd ff ff       	call   80108c51 <i8254_send>
80108e81:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e87:	83 ec 0c             	sub    $0xc,%esp
80108e8a:	50                   	push   %eax
80108e8b:	e8 77 98 ff ff       	call   80102707 <kfree>
80108e90:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108e93:	b8 02 00 00 00       	mov    $0x2,%eax
80108e98:	eb 54                	jmp    80108eee <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108ea1:	66 3d 00 02          	cmp    $0x200,%ax
80108ea5:	75 42                	jne    80108ee9 <arp_proc+0x16c>
80108ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaa:	83 c0 18             	add    $0x18,%eax
80108ead:	83 ec 04             	sub    $0x4,%esp
80108eb0:	6a 04                	push   $0x4
80108eb2:	50                   	push   %eax
80108eb3:	68 e4 f4 10 80       	push   $0x8010f4e4
80108eb8:	e8 6e bc ff ff       	call   80104b2b <memcmp>
80108ebd:	83 c4 10             	add    $0x10,%esp
80108ec0:	85 c0                	test   %eax,%eax
80108ec2:	75 25                	jne    80108ee9 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108ec4:	83 ec 0c             	sub    $0xc,%esp
80108ec7:	68 dc c0 10 80       	push   $0x8010c0dc
80108ecc:	e8 23 75 ff ff       	call   801003f4 <cprintf>
80108ed1:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108ed4:	83 ec 0c             	sub    $0xc,%esp
80108ed7:	ff 75 f4             	push   -0xc(%ebp)
80108eda:	e8 af 01 00 00       	call   8010908e <arp_table_update>
80108edf:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108ee2:	b8 01 00 00 00       	mov    $0x1,%eax
80108ee7:	eb 05                	jmp    80108eee <arp_proc+0x171>
  }else{
    return -1;
80108ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108eee:	c9                   	leave  
80108eef:	c3                   	ret    

80108ef0 <arp_scan>:

void arp_scan(){
80108ef0:	55                   	push   %ebp
80108ef1:	89 e5                	mov    %esp,%ebp
80108ef3:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108efd:	eb 6f                	jmp    80108f6e <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108eff:	e8 9d 98 ff ff       	call   801027a1 <kalloc>
80108f04:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108f07:	83 ec 04             	sub    $0x4,%esp
80108f0a:	ff 75 f4             	push   -0xc(%ebp)
80108f0d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108f10:	50                   	push   %eax
80108f11:	ff 75 ec             	push   -0x14(%ebp)
80108f14:	e8 62 00 00 00       	call   80108f7b <arp_broadcast>
80108f19:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108f1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f1f:	83 ec 08             	sub    $0x8,%esp
80108f22:	50                   	push   %eax
80108f23:	ff 75 ec             	push   -0x14(%ebp)
80108f26:	e8 26 fd ff ff       	call   80108c51 <i8254_send>
80108f2b:	83 c4 10             	add    $0x10,%esp
80108f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108f31:	eb 22                	jmp    80108f55 <arp_scan+0x65>
      microdelay(1);
80108f33:	83 ec 0c             	sub    $0xc,%esp
80108f36:	6a 01                	push   $0x1
80108f38:	e8 fb 9b ff ff       	call   80102b38 <microdelay>
80108f3d:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108f40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f43:	83 ec 08             	sub    $0x8,%esp
80108f46:	50                   	push   %eax
80108f47:	ff 75 ec             	push   -0x14(%ebp)
80108f4a:	e8 02 fd ff ff       	call   80108c51 <i8254_send>
80108f4f:	83 c4 10             	add    $0x10,%esp
80108f52:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108f55:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108f59:	74 d8                	je     80108f33 <arp_scan+0x43>
    }
    kfree((char *)send);
80108f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f5e:	83 ec 0c             	sub    $0xc,%esp
80108f61:	50                   	push   %eax
80108f62:	e8 a0 97 ff ff       	call   80102707 <kfree>
80108f67:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108f6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f6e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f75:	7e 88                	jle    80108eff <arp_scan+0xf>
  }
}
80108f77:	90                   	nop
80108f78:	90                   	nop
80108f79:	c9                   	leave  
80108f7a:	c3                   	ret    

80108f7b <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108f7b:	55                   	push   %ebp
80108f7c:	89 e5                	mov    %esp,%ebp
80108f7e:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108f81:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108f85:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108f89:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80108f90:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108f93:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108f9a:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108fa0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108fa7:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108fad:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fb0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80108fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80108fbf:	83 c0 0e             	add    $0xe,%eax
80108fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fcf:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd6:	83 ec 04             	sub    $0x4,%esp
80108fd9:	6a 06                	push   $0x6
80108fdb:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108fde:	52                   	push   %edx
80108fdf:	50                   	push   %eax
80108fe0:	e8 9e bb ff ff       	call   80104b83 <memmove>
80108fe5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108feb:	83 c0 06             	add    $0x6,%eax
80108fee:	83 ec 04             	sub    $0x4,%esp
80108ff1:	6a 06                	push   $0x6
80108ff3:	68 80 6c 19 80       	push   $0x80196c80
80108ff8:	50                   	push   %eax
80108ff9:	e8 85 bb ff ff       	call   80104b83 <memmove>
80108ffe:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109004:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900c:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109015:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109023:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010902c:	8d 50 12             	lea    0x12(%eax),%edx
8010902f:	83 ec 04             	sub    $0x4,%esp
80109032:	6a 06                	push   $0x6
80109034:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109037:	50                   	push   %eax
80109038:	52                   	push   %edx
80109039:	e8 45 bb ff ff       	call   80104b83 <memmove>
8010903e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109044:	8d 50 18             	lea    0x18(%eax),%edx
80109047:	83 ec 04             	sub    $0x4,%esp
8010904a:	6a 04                	push   $0x4
8010904c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010904f:	50                   	push   %eax
80109050:	52                   	push   %edx
80109051:	e8 2d bb ff ff       	call   80104b83 <memmove>
80109056:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905c:	83 c0 08             	add    $0x8,%eax
8010905f:	83 ec 04             	sub    $0x4,%esp
80109062:	6a 06                	push   $0x6
80109064:	68 80 6c 19 80       	push   $0x80196c80
80109069:	50                   	push   %eax
8010906a:	e8 14 bb ff ff       	call   80104b83 <memmove>
8010906f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109075:	83 c0 0e             	add    $0xe,%eax
80109078:	83 ec 04             	sub    $0x4,%esp
8010907b:	6a 04                	push   $0x4
8010907d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109082:	50                   	push   %eax
80109083:	e8 fb ba ff ff       	call   80104b83 <memmove>
80109088:	83 c4 10             	add    $0x10,%esp
}
8010908b:	90                   	nop
8010908c:	c9                   	leave  
8010908d:	c3                   	ret    

8010908e <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010908e:	55                   	push   %ebp
8010908f:	89 e5                	mov    %esp,%ebp
80109091:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109094:	8b 45 08             	mov    0x8(%ebp),%eax
80109097:	83 c0 0e             	add    $0xe,%eax
8010909a:	83 ec 0c             	sub    $0xc,%esp
8010909d:	50                   	push   %eax
8010909e:	e8 bc 00 00 00       	call   8010915f <arp_table_search>
801090a3:	83 c4 10             	add    $0x10,%esp
801090a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801090a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801090ad:	78 2d                	js     801090dc <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801090af:	8b 45 08             	mov    0x8(%ebp),%eax
801090b2:	8d 48 08             	lea    0x8(%eax),%ecx
801090b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090b8:	89 d0                	mov    %edx,%eax
801090ba:	c1 e0 02             	shl    $0x2,%eax
801090bd:	01 d0                	add    %edx,%eax
801090bf:	01 c0                	add    %eax,%eax
801090c1:	01 d0                	add    %edx,%eax
801090c3:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090c8:	83 c0 04             	add    $0x4,%eax
801090cb:	83 ec 04             	sub    $0x4,%esp
801090ce:	6a 06                	push   $0x6
801090d0:	51                   	push   %ecx
801090d1:	50                   	push   %eax
801090d2:	e8 ac ba ff ff       	call   80104b83 <memmove>
801090d7:	83 c4 10             	add    $0x10,%esp
801090da:	eb 70                	jmp    8010914c <arp_table_update+0xbe>
  }else{
    index += 1;
801090dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801090e0:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801090e3:	8b 45 08             	mov    0x8(%ebp),%eax
801090e6:	8d 48 08             	lea    0x8(%eax),%ecx
801090e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090ec:	89 d0                	mov    %edx,%eax
801090ee:	c1 e0 02             	shl    $0x2,%eax
801090f1:	01 d0                	add    %edx,%eax
801090f3:	01 c0                	add    %eax,%eax
801090f5:	01 d0                	add    %edx,%eax
801090f7:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090fc:	83 c0 04             	add    $0x4,%eax
801090ff:	83 ec 04             	sub    $0x4,%esp
80109102:	6a 06                	push   $0x6
80109104:	51                   	push   %ecx
80109105:	50                   	push   %eax
80109106:	e8 78 ba ff ff       	call   80104b83 <memmove>
8010910b:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010910e:	8b 45 08             	mov    0x8(%ebp),%eax
80109111:	8d 48 0e             	lea    0xe(%eax),%ecx
80109114:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109117:	89 d0                	mov    %edx,%eax
80109119:	c1 e0 02             	shl    $0x2,%eax
8010911c:	01 d0                	add    %edx,%eax
8010911e:	01 c0                	add    %eax,%eax
80109120:	01 d0                	add    %edx,%eax
80109122:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109127:	83 ec 04             	sub    $0x4,%esp
8010912a:	6a 04                	push   $0x4
8010912c:	51                   	push   %ecx
8010912d:	50                   	push   %eax
8010912e:	e8 50 ba ff ff       	call   80104b83 <memmove>
80109133:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109136:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109139:	89 d0                	mov    %edx,%eax
8010913b:	c1 e0 02             	shl    $0x2,%eax
8010913e:	01 d0                	add    %edx,%eax
80109140:	01 c0                	add    %eax,%eax
80109142:	01 d0                	add    %edx,%eax
80109144:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109149:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010914c:	83 ec 0c             	sub    $0xc,%esp
8010914f:	68 a0 6c 19 80       	push   $0x80196ca0
80109154:	e8 83 00 00 00       	call   801091dc <print_arp_table>
80109159:	83 c4 10             	add    $0x10,%esp
}
8010915c:	90                   	nop
8010915d:	c9                   	leave  
8010915e:	c3                   	ret    

8010915f <arp_table_search>:

int arp_table_search(uchar *ip){
8010915f:	55                   	push   %ebp
80109160:	89 e5                	mov    %esp,%ebp
80109162:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109165:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010916c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109173:	eb 59                	jmp    801091ce <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109175:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109178:	89 d0                	mov    %edx,%eax
8010917a:	c1 e0 02             	shl    $0x2,%eax
8010917d:	01 d0                	add    %edx,%eax
8010917f:	01 c0                	add    %eax,%eax
80109181:	01 d0                	add    %edx,%eax
80109183:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109188:	83 ec 04             	sub    $0x4,%esp
8010918b:	6a 04                	push   $0x4
8010918d:	ff 75 08             	push   0x8(%ebp)
80109190:	50                   	push   %eax
80109191:	e8 95 b9 ff ff       	call   80104b2b <memcmp>
80109196:	83 c4 10             	add    $0x10,%esp
80109199:	85 c0                	test   %eax,%eax
8010919b:	75 05                	jne    801091a2 <arp_table_search+0x43>
      return i;
8010919d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a0:	eb 38                	jmp    801091da <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801091a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801091a5:	89 d0                	mov    %edx,%eax
801091a7:	c1 e0 02             	shl    $0x2,%eax
801091aa:	01 d0                	add    %edx,%eax
801091ac:	01 c0                	add    %eax,%eax
801091ae:	01 d0                	add    %edx,%eax
801091b0:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801091b5:	0f b6 00             	movzbl (%eax),%eax
801091b8:	84 c0                	test   %al,%al
801091ba:	75 0e                	jne    801091ca <arp_table_search+0x6b>
801091bc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801091c0:	75 08                	jne    801091ca <arp_table_search+0x6b>
      empty = -i;
801091c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c5:	f7 d8                	neg    %eax
801091c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801091ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801091ce:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801091d2:	7e a1                	jle    80109175 <arp_table_search+0x16>
    }
  }
  return empty-1;
801091d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d7:	83 e8 01             	sub    $0x1,%eax
}
801091da:	c9                   	leave  
801091db:	c3                   	ret    

801091dc <print_arp_table>:

void print_arp_table(){
801091dc:	55                   	push   %ebp
801091dd:	89 e5                	mov    %esp,%ebp
801091df:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801091e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091e9:	e9 92 00 00 00       	jmp    80109280 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801091ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091f1:	89 d0                	mov    %edx,%eax
801091f3:	c1 e0 02             	shl    $0x2,%eax
801091f6:	01 d0                	add    %edx,%eax
801091f8:	01 c0                	add    %eax,%eax
801091fa:	01 d0                	add    %edx,%eax
801091fc:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109201:	0f b6 00             	movzbl (%eax),%eax
80109204:	84 c0                	test   %al,%al
80109206:	74 74                	je     8010927c <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109208:	83 ec 08             	sub    $0x8,%esp
8010920b:	ff 75 f4             	push   -0xc(%ebp)
8010920e:	68 ef c0 10 80       	push   $0x8010c0ef
80109213:	e8 dc 71 ff ff       	call   801003f4 <cprintf>
80109218:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010921b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010921e:	89 d0                	mov    %edx,%eax
80109220:	c1 e0 02             	shl    $0x2,%eax
80109223:	01 d0                	add    %edx,%eax
80109225:	01 c0                	add    %eax,%eax
80109227:	01 d0                	add    %edx,%eax
80109229:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010922e:	83 ec 0c             	sub    $0xc,%esp
80109231:	50                   	push   %eax
80109232:	e8 54 02 00 00       	call   8010948b <print_ipv4>
80109237:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010923a:	83 ec 0c             	sub    $0xc,%esp
8010923d:	68 fe c0 10 80       	push   $0x8010c0fe
80109242:	e8 ad 71 ff ff       	call   801003f4 <cprintf>
80109247:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010924a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010924d:	89 d0                	mov    %edx,%eax
8010924f:	c1 e0 02             	shl    $0x2,%eax
80109252:	01 d0                	add    %edx,%eax
80109254:	01 c0                	add    %eax,%eax
80109256:	01 d0                	add    %edx,%eax
80109258:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010925d:	83 c0 04             	add    $0x4,%eax
80109260:	83 ec 0c             	sub    $0xc,%esp
80109263:	50                   	push   %eax
80109264:	e8 70 02 00 00       	call   801094d9 <print_mac>
80109269:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010926c:	83 ec 0c             	sub    $0xc,%esp
8010926f:	68 00 c1 10 80       	push   $0x8010c100
80109274:	e8 7b 71 ff ff       	call   801003f4 <cprintf>
80109279:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010927c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109280:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109284:	0f 8e 64 ff ff ff    	jle    801091ee <print_arp_table+0x12>
    }
  }
}
8010928a:	90                   	nop
8010928b:	90                   	nop
8010928c:	c9                   	leave  
8010928d:	c3                   	ret    

8010928e <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010928e:	55                   	push   %ebp
8010928f:	89 e5                	mov    %esp,%ebp
80109291:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109294:	8b 45 10             	mov    0x10(%ebp),%eax
80109297:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010929d:	8b 45 0c             	mov    0xc(%ebp),%eax
801092a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801092a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801092a6:	83 c0 0e             	add    $0xe,%eax
801092a9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801092ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092af:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801092b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801092ba:	8b 45 08             	mov    0x8(%ebp),%eax
801092bd:	8d 50 08             	lea    0x8(%eax),%edx
801092c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c3:	83 ec 04             	sub    $0x4,%esp
801092c6:	6a 06                	push   $0x6
801092c8:	52                   	push   %edx
801092c9:	50                   	push   %eax
801092ca:	e8 b4 b8 ff ff       	call   80104b83 <memmove>
801092cf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801092d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d5:	83 c0 06             	add    $0x6,%eax
801092d8:	83 ec 04             	sub    $0x4,%esp
801092db:	6a 06                	push   $0x6
801092dd:	68 80 6c 19 80       	push   $0x80196c80
801092e2:	50                   	push   %eax
801092e3:	e8 9b b8 ff ff       	call   80104b83 <memmove>
801092e8:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801092eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ee:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801092f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092f6:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801092fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ff:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109306:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010930a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010930d:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109313:	8b 45 08             	mov    0x8(%ebp),%eax
80109316:	8d 50 08             	lea    0x8(%eax),%edx
80109319:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010931c:	83 c0 12             	add    $0x12,%eax
8010931f:	83 ec 04             	sub    $0x4,%esp
80109322:	6a 06                	push   $0x6
80109324:	52                   	push   %edx
80109325:	50                   	push   %eax
80109326:	e8 58 b8 ff ff       	call   80104b83 <memmove>
8010932b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010932e:	8b 45 08             	mov    0x8(%ebp),%eax
80109331:	8d 50 0e             	lea    0xe(%eax),%edx
80109334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109337:	83 c0 18             	add    $0x18,%eax
8010933a:	83 ec 04             	sub    $0x4,%esp
8010933d:	6a 04                	push   $0x4
8010933f:	52                   	push   %edx
80109340:	50                   	push   %eax
80109341:	e8 3d b8 ff ff       	call   80104b83 <memmove>
80109346:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934c:	83 c0 08             	add    $0x8,%eax
8010934f:	83 ec 04             	sub    $0x4,%esp
80109352:	6a 06                	push   $0x6
80109354:	68 80 6c 19 80       	push   $0x80196c80
80109359:	50                   	push   %eax
8010935a:	e8 24 b8 ff ff       	call   80104b83 <memmove>
8010935f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109365:	83 c0 0e             	add    $0xe,%eax
80109368:	83 ec 04             	sub    $0x4,%esp
8010936b:	6a 04                	push   $0x4
8010936d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109372:	50                   	push   %eax
80109373:	e8 0b b8 ff ff       	call   80104b83 <memmove>
80109378:	83 c4 10             	add    $0x10,%esp
}
8010937b:	90                   	nop
8010937c:	c9                   	leave  
8010937d:	c3                   	ret    

8010937e <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010937e:	55                   	push   %ebp
8010937f:	89 e5                	mov    %esp,%ebp
80109381:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109384:	83 ec 0c             	sub    $0xc,%esp
80109387:	68 02 c1 10 80       	push   $0x8010c102
8010938c:	e8 63 70 ff ff       	call   801003f4 <cprintf>
80109391:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109394:	8b 45 08             	mov    0x8(%ebp),%eax
80109397:	83 c0 0e             	add    $0xe,%eax
8010939a:	83 ec 0c             	sub    $0xc,%esp
8010939d:	50                   	push   %eax
8010939e:	e8 e8 00 00 00       	call   8010948b <print_ipv4>
801093a3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801093a6:	83 ec 0c             	sub    $0xc,%esp
801093a9:	68 00 c1 10 80       	push   $0x8010c100
801093ae:	e8 41 70 ff ff       	call   801003f4 <cprintf>
801093b3:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801093b6:	8b 45 08             	mov    0x8(%ebp),%eax
801093b9:	83 c0 08             	add    $0x8,%eax
801093bc:	83 ec 0c             	sub    $0xc,%esp
801093bf:	50                   	push   %eax
801093c0:	e8 14 01 00 00       	call   801094d9 <print_mac>
801093c5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801093c8:	83 ec 0c             	sub    $0xc,%esp
801093cb:	68 00 c1 10 80       	push   $0x8010c100
801093d0:	e8 1f 70 ff ff       	call   801003f4 <cprintf>
801093d5:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801093d8:	83 ec 0c             	sub    $0xc,%esp
801093db:	68 19 c1 10 80       	push   $0x8010c119
801093e0:	e8 0f 70 ff ff       	call   801003f4 <cprintf>
801093e5:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801093e8:	8b 45 08             	mov    0x8(%ebp),%eax
801093eb:	83 c0 18             	add    $0x18,%eax
801093ee:	83 ec 0c             	sub    $0xc,%esp
801093f1:	50                   	push   %eax
801093f2:	e8 94 00 00 00       	call   8010948b <print_ipv4>
801093f7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801093fa:	83 ec 0c             	sub    $0xc,%esp
801093fd:	68 00 c1 10 80       	push   $0x8010c100
80109402:	e8 ed 6f ff ff       	call   801003f4 <cprintf>
80109407:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010940a:	8b 45 08             	mov    0x8(%ebp),%eax
8010940d:	83 c0 12             	add    $0x12,%eax
80109410:	83 ec 0c             	sub    $0xc,%esp
80109413:	50                   	push   %eax
80109414:	e8 c0 00 00 00       	call   801094d9 <print_mac>
80109419:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010941c:	83 ec 0c             	sub    $0xc,%esp
8010941f:	68 00 c1 10 80       	push   $0x8010c100
80109424:	e8 cb 6f ff ff       	call   801003f4 <cprintf>
80109429:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010942c:	83 ec 0c             	sub    $0xc,%esp
8010942f:	68 30 c1 10 80       	push   $0x8010c130
80109434:	e8 bb 6f ff ff       	call   801003f4 <cprintf>
80109439:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010943c:	8b 45 08             	mov    0x8(%ebp),%eax
8010943f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109443:	66 3d 00 01          	cmp    $0x100,%ax
80109447:	75 12                	jne    8010945b <print_arp_info+0xdd>
80109449:	83 ec 0c             	sub    $0xc,%esp
8010944c:	68 3c c1 10 80       	push   $0x8010c13c
80109451:	e8 9e 6f ff ff       	call   801003f4 <cprintf>
80109456:	83 c4 10             	add    $0x10,%esp
80109459:	eb 1d                	jmp    80109478 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010945b:	8b 45 08             	mov    0x8(%ebp),%eax
8010945e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109462:	66 3d 00 02          	cmp    $0x200,%ax
80109466:	75 10                	jne    80109478 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109468:	83 ec 0c             	sub    $0xc,%esp
8010946b:	68 45 c1 10 80       	push   $0x8010c145
80109470:	e8 7f 6f ff ff       	call   801003f4 <cprintf>
80109475:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109478:	83 ec 0c             	sub    $0xc,%esp
8010947b:	68 00 c1 10 80       	push   $0x8010c100
80109480:	e8 6f 6f ff ff       	call   801003f4 <cprintf>
80109485:	83 c4 10             	add    $0x10,%esp
}
80109488:	90                   	nop
80109489:	c9                   	leave  
8010948a:	c3                   	ret    

8010948b <print_ipv4>:

void print_ipv4(uchar *ip){
8010948b:	55                   	push   %ebp
8010948c:	89 e5                	mov    %esp,%ebp
8010948e:	53                   	push   %ebx
8010948f:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109492:	8b 45 08             	mov    0x8(%ebp),%eax
80109495:	83 c0 03             	add    $0x3,%eax
80109498:	0f b6 00             	movzbl (%eax),%eax
8010949b:	0f b6 d8             	movzbl %al,%ebx
8010949e:	8b 45 08             	mov    0x8(%ebp),%eax
801094a1:	83 c0 02             	add    $0x2,%eax
801094a4:	0f b6 00             	movzbl (%eax),%eax
801094a7:	0f b6 c8             	movzbl %al,%ecx
801094aa:	8b 45 08             	mov    0x8(%ebp),%eax
801094ad:	83 c0 01             	add    $0x1,%eax
801094b0:	0f b6 00             	movzbl (%eax),%eax
801094b3:	0f b6 d0             	movzbl %al,%edx
801094b6:	8b 45 08             	mov    0x8(%ebp),%eax
801094b9:	0f b6 00             	movzbl (%eax),%eax
801094bc:	0f b6 c0             	movzbl %al,%eax
801094bf:	83 ec 0c             	sub    $0xc,%esp
801094c2:	53                   	push   %ebx
801094c3:	51                   	push   %ecx
801094c4:	52                   	push   %edx
801094c5:	50                   	push   %eax
801094c6:	68 4c c1 10 80       	push   $0x8010c14c
801094cb:	e8 24 6f ff ff       	call   801003f4 <cprintf>
801094d0:	83 c4 20             	add    $0x20,%esp
}
801094d3:	90                   	nop
801094d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801094d7:	c9                   	leave  
801094d8:	c3                   	ret    

801094d9 <print_mac>:

void print_mac(uchar *mac){
801094d9:	55                   	push   %ebp
801094da:	89 e5                	mov    %esp,%ebp
801094dc:	57                   	push   %edi
801094dd:	56                   	push   %esi
801094de:	53                   	push   %ebx
801094df:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801094e2:	8b 45 08             	mov    0x8(%ebp),%eax
801094e5:	83 c0 05             	add    $0x5,%eax
801094e8:	0f b6 00             	movzbl (%eax),%eax
801094eb:	0f b6 f8             	movzbl %al,%edi
801094ee:	8b 45 08             	mov    0x8(%ebp),%eax
801094f1:	83 c0 04             	add    $0x4,%eax
801094f4:	0f b6 00             	movzbl (%eax),%eax
801094f7:	0f b6 f0             	movzbl %al,%esi
801094fa:	8b 45 08             	mov    0x8(%ebp),%eax
801094fd:	83 c0 03             	add    $0x3,%eax
80109500:	0f b6 00             	movzbl (%eax),%eax
80109503:	0f b6 d8             	movzbl %al,%ebx
80109506:	8b 45 08             	mov    0x8(%ebp),%eax
80109509:	83 c0 02             	add    $0x2,%eax
8010950c:	0f b6 00             	movzbl (%eax),%eax
8010950f:	0f b6 c8             	movzbl %al,%ecx
80109512:	8b 45 08             	mov    0x8(%ebp),%eax
80109515:	83 c0 01             	add    $0x1,%eax
80109518:	0f b6 00             	movzbl (%eax),%eax
8010951b:	0f b6 d0             	movzbl %al,%edx
8010951e:	8b 45 08             	mov    0x8(%ebp),%eax
80109521:	0f b6 00             	movzbl (%eax),%eax
80109524:	0f b6 c0             	movzbl %al,%eax
80109527:	83 ec 04             	sub    $0x4,%esp
8010952a:	57                   	push   %edi
8010952b:	56                   	push   %esi
8010952c:	53                   	push   %ebx
8010952d:	51                   	push   %ecx
8010952e:	52                   	push   %edx
8010952f:	50                   	push   %eax
80109530:	68 64 c1 10 80       	push   $0x8010c164
80109535:	e8 ba 6e ff ff       	call   801003f4 <cprintf>
8010953a:	83 c4 20             	add    $0x20,%esp
}
8010953d:	90                   	nop
8010953e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109541:	5b                   	pop    %ebx
80109542:	5e                   	pop    %esi
80109543:	5f                   	pop    %edi
80109544:	5d                   	pop    %ebp
80109545:	c3                   	ret    

80109546 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109546:	55                   	push   %ebp
80109547:	89 e5                	mov    %esp,%ebp
80109549:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010954c:	8b 45 08             	mov    0x8(%ebp),%eax
8010954f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109552:	8b 45 08             	mov    0x8(%ebp),%eax
80109555:	83 c0 0e             	add    $0xe,%eax
80109558:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010955b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109562:	3c 08                	cmp    $0x8,%al
80109564:	75 1b                	jne    80109581 <eth_proc+0x3b>
80109566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109569:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010956d:	3c 06                	cmp    $0x6,%al
8010956f:	75 10                	jne    80109581 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109571:	83 ec 0c             	sub    $0xc,%esp
80109574:	ff 75 f0             	push   -0x10(%ebp)
80109577:	e8 01 f8 ff ff       	call   80108d7d <arp_proc>
8010957c:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010957f:	eb 24                	jmp    801095a5 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109584:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109588:	3c 08                	cmp    $0x8,%al
8010958a:	75 19                	jne    801095a5 <eth_proc+0x5f>
8010958c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109593:	84 c0                	test   %al,%al
80109595:	75 0e                	jne    801095a5 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109597:	83 ec 0c             	sub    $0xc,%esp
8010959a:	ff 75 08             	push   0x8(%ebp)
8010959d:	e8 a3 00 00 00       	call   80109645 <ipv4_proc>
801095a2:	83 c4 10             	add    $0x10,%esp
}
801095a5:	90                   	nop
801095a6:	c9                   	leave  
801095a7:	c3                   	ret    

801095a8 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801095a8:	55                   	push   %ebp
801095a9:	89 e5                	mov    %esp,%ebp
801095ab:	83 ec 04             	sub    $0x4,%esp
801095ae:	8b 45 08             	mov    0x8(%ebp),%eax
801095b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801095b5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801095b9:	c1 e0 08             	shl    $0x8,%eax
801095bc:	89 c2                	mov    %eax,%edx
801095be:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801095c2:	66 c1 e8 08          	shr    $0x8,%ax
801095c6:	01 d0                	add    %edx,%eax
}
801095c8:	c9                   	leave  
801095c9:	c3                   	ret    

801095ca <H2N_ushort>:

ushort H2N_ushort(ushort value){
801095ca:	55                   	push   %ebp
801095cb:	89 e5                	mov    %esp,%ebp
801095cd:	83 ec 04             	sub    $0x4,%esp
801095d0:	8b 45 08             	mov    0x8(%ebp),%eax
801095d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801095d7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801095db:	c1 e0 08             	shl    $0x8,%eax
801095de:	89 c2                	mov    %eax,%edx
801095e0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801095e4:	66 c1 e8 08          	shr    $0x8,%ax
801095e8:	01 d0                	add    %edx,%eax
}
801095ea:	c9                   	leave  
801095eb:	c3                   	ret    

801095ec <H2N_uint>:

uint H2N_uint(uint value){
801095ec:	55                   	push   %ebp
801095ed:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801095ef:	8b 45 08             	mov    0x8(%ebp),%eax
801095f2:	c1 e0 18             	shl    $0x18,%eax
801095f5:	25 00 00 00 0f       	and    $0xf000000,%eax
801095fa:	89 c2                	mov    %eax,%edx
801095fc:	8b 45 08             	mov    0x8(%ebp),%eax
801095ff:	c1 e0 08             	shl    $0x8,%eax
80109602:	25 00 f0 00 00       	and    $0xf000,%eax
80109607:	09 c2                	or     %eax,%edx
80109609:	8b 45 08             	mov    0x8(%ebp),%eax
8010960c:	c1 e8 08             	shr    $0x8,%eax
8010960f:	83 e0 0f             	and    $0xf,%eax
80109612:	01 d0                	add    %edx,%eax
}
80109614:	5d                   	pop    %ebp
80109615:	c3                   	ret    

80109616 <N2H_uint>:

uint N2H_uint(uint value){
80109616:	55                   	push   %ebp
80109617:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109619:	8b 45 08             	mov    0x8(%ebp),%eax
8010961c:	c1 e0 18             	shl    $0x18,%eax
8010961f:	89 c2                	mov    %eax,%edx
80109621:	8b 45 08             	mov    0x8(%ebp),%eax
80109624:	c1 e0 08             	shl    $0x8,%eax
80109627:	25 00 00 ff 00       	and    $0xff0000,%eax
8010962c:	01 c2                	add    %eax,%edx
8010962e:	8b 45 08             	mov    0x8(%ebp),%eax
80109631:	c1 e8 08             	shr    $0x8,%eax
80109634:	25 00 ff 00 00       	and    $0xff00,%eax
80109639:	01 c2                	add    %eax,%edx
8010963b:	8b 45 08             	mov    0x8(%ebp),%eax
8010963e:	c1 e8 18             	shr    $0x18,%eax
80109641:	01 d0                	add    %edx,%eax
}
80109643:	5d                   	pop    %ebp
80109644:	c3                   	ret    

80109645 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109645:	55                   	push   %ebp
80109646:	89 e5                	mov    %esp,%ebp
80109648:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010964b:	8b 45 08             	mov    0x8(%ebp),%eax
8010964e:	83 c0 0e             	add    $0xe,%eax
80109651:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109657:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010965b:	0f b7 d0             	movzwl %ax,%edx
8010965e:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109663:	39 c2                	cmp    %eax,%edx
80109665:	74 60                	je     801096c7 <ipv4_proc+0x82>
80109667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010966a:	83 c0 0c             	add    $0xc,%eax
8010966d:	83 ec 04             	sub    $0x4,%esp
80109670:	6a 04                	push   $0x4
80109672:	50                   	push   %eax
80109673:	68 e4 f4 10 80       	push   $0x8010f4e4
80109678:	e8 ae b4 ff ff       	call   80104b2b <memcmp>
8010967d:	83 c4 10             	add    $0x10,%esp
80109680:	85 c0                	test   %eax,%eax
80109682:	74 43                	je     801096c7 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109687:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010968b:	0f b7 c0             	movzwl %ax,%eax
8010968e:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109696:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010969a:	3c 01                	cmp    $0x1,%al
8010969c:	75 10                	jne    801096ae <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010969e:	83 ec 0c             	sub    $0xc,%esp
801096a1:	ff 75 08             	push   0x8(%ebp)
801096a4:	e8 a3 00 00 00       	call   8010974c <icmp_proc>
801096a9:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801096ac:	eb 19                	jmp    801096c7 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801096ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b1:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801096b5:	3c 06                	cmp    $0x6,%al
801096b7:	75 0e                	jne    801096c7 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801096b9:	83 ec 0c             	sub    $0xc,%esp
801096bc:	ff 75 08             	push   0x8(%ebp)
801096bf:	e8 b3 03 00 00       	call   80109a77 <tcp_proc>
801096c4:	83 c4 10             	add    $0x10,%esp
}
801096c7:	90                   	nop
801096c8:	c9                   	leave  
801096c9:	c3                   	ret    

801096ca <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801096ca:	55                   	push   %ebp
801096cb:	89 e5                	mov    %esp,%ebp
801096cd:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801096d0:	8b 45 08             	mov    0x8(%ebp),%eax
801096d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801096d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d9:	0f b6 00             	movzbl (%eax),%eax
801096dc:	83 e0 0f             	and    $0xf,%eax
801096df:	01 c0                	add    %eax,%eax
801096e1:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801096e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801096eb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801096f2:	eb 48                	jmp    8010973c <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801096f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801096f7:	01 c0                	add    %eax,%eax
801096f9:	89 c2                	mov    %eax,%edx
801096fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fe:	01 d0                	add    %edx,%eax
80109700:	0f b6 00             	movzbl (%eax),%eax
80109703:	0f b6 c0             	movzbl %al,%eax
80109706:	c1 e0 08             	shl    $0x8,%eax
80109709:	89 c2                	mov    %eax,%edx
8010970b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010970e:	01 c0                	add    %eax,%eax
80109710:	8d 48 01             	lea    0x1(%eax),%ecx
80109713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109716:	01 c8                	add    %ecx,%eax
80109718:	0f b6 00             	movzbl (%eax),%eax
8010971b:	0f b6 c0             	movzbl %al,%eax
8010971e:	01 d0                	add    %edx,%eax
80109720:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109723:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010972a:	76 0c                	jbe    80109738 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010972c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010972f:	0f b7 c0             	movzwl %ax,%eax
80109732:	83 c0 01             	add    $0x1,%eax
80109735:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109738:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010973c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109740:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109743:	7c af                	jl     801096f4 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109745:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109748:	f7 d0                	not    %eax
}
8010974a:	c9                   	leave  
8010974b:	c3                   	ret    

8010974c <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010974c:	55                   	push   %ebp
8010974d:	89 e5                	mov    %esp,%ebp
8010974f:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109752:	8b 45 08             	mov    0x8(%ebp),%eax
80109755:	83 c0 0e             	add    $0xe,%eax
80109758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010975b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975e:	0f b6 00             	movzbl (%eax),%eax
80109761:	0f b6 c0             	movzbl %al,%eax
80109764:	83 e0 0f             	and    $0xf,%eax
80109767:	c1 e0 02             	shl    $0x2,%eax
8010976a:	89 c2                	mov    %eax,%edx
8010976c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976f:	01 d0                	add    %edx,%eax
80109771:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109777:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010977b:	84 c0                	test   %al,%al
8010977d:	75 4f                	jne    801097ce <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010977f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109782:	0f b6 00             	movzbl (%eax),%eax
80109785:	3c 08                	cmp    $0x8,%al
80109787:	75 45                	jne    801097ce <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109789:	e8 13 90 ff ff       	call   801027a1 <kalloc>
8010978e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109791:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109798:	83 ec 04             	sub    $0x4,%esp
8010979b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010979e:	50                   	push   %eax
8010979f:	ff 75 ec             	push   -0x14(%ebp)
801097a2:	ff 75 08             	push   0x8(%ebp)
801097a5:	e8 78 00 00 00       	call   80109822 <icmp_reply_pkt_create>
801097aa:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801097ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097b0:	83 ec 08             	sub    $0x8,%esp
801097b3:	50                   	push   %eax
801097b4:	ff 75 ec             	push   -0x14(%ebp)
801097b7:	e8 95 f4 ff ff       	call   80108c51 <i8254_send>
801097bc:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801097bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097c2:	83 ec 0c             	sub    $0xc,%esp
801097c5:	50                   	push   %eax
801097c6:	e8 3c 8f ff ff       	call   80102707 <kfree>
801097cb:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801097ce:	90                   	nop
801097cf:	c9                   	leave  
801097d0:	c3                   	ret    

801097d1 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801097d1:	55                   	push   %ebp
801097d2:	89 e5                	mov    %esp,%ebp
801097d4:	53                   	push   %ebx
801097d5:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801097d8:	8b 45 08             	mov    0x8(%ebp),%eax
801097db:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097df:	0f b7 c0             	movzwl %ax,%eax
801097e2:	83 ec 0c             	sub    $0xc,%esp
801097e5:	50                   	push   %eax
801097e6:	e8 bd fd ff ff       	call   801095a8 <N2H_ushort>
801097eb:	83 c4 10             	add    $0x10,%esp
801097ee:	0f b7 d8             	movzwl %ax,%ebx
801097f1:	8b 45 08             	mov    0x8(%ebp),%eax
801097f4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097f8:	0f b7 c0             	movzwl %ax,%eax
801097fb:	83 ec 0c             	sub    $0xc,%esp
801097fe:	50                   	push   %eax
801097ff:	e8 a4 fd ff ff       	call   801095a8 <N2H_ushort>
80109804:	83 c4 10             	add    $0x10,%esp
80109807:	0f b7 c0             	movzwl %ax,%eax
8010980a:	83 ec 04             	sub    $0x4,%esp
8010980d:	53                   	push   %ebx
8010980e:	50                   	push   %eax
8010980f:	68 83 c1 10 80       	push   $0x8010c183
80109814:	e8 db 6b ff ff       	call   801003f4 <cprintf>
80109819:	83 c4 10             	add    $0x10,%esp
}
8010981c:	90                   	nop
8010981d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109820:	c9                   	leave  
80109821:	c3                   	ret    

80109822 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109822:	55                   	push   %ebp
80109823:	89 e5                	mov    %esp,%ebp
80109825:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109828:	8b 45 08             	mov    0x8(%ebp),%eax
8010982b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010982e:	8b 45 08             	mov    0x8(%ebp),%eax
80109831:	83 c0 0e             	add    $0xe,%eax
80109834:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010983a:	0f b6 00             	movzbl (%eax),%eax
8010983d:	0f b6 c0             	movzbl %al,%eax
80109840:	83 e0 0f             	and    $0xf,%eax
80109843:	c1 e0 02             	shl    $0x2,%eax
80109846:	89 c2                	mov    %eax,%edx
80109848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984b:	01 d0                	add    %edx,%eax
8010984d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109850:	8b 45 0c             	mov    0xc(%ebp),%eax
80109853:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109856:	8b 45 0c             	mov    0xc(%ebp),%eax
80109859:	83 c0 0e             	add    $0xe,%eax
8010985c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010985f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109862:	83 c0 14             	add    $0x14,%eax
80109865:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109868:	8b 45 10             	mov    0x10(%ebp),%eax
8010986b:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109874:	8d 50 06             	lea    0x6(%eax),%edx
80109877:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010987a:	83 ec 04             	sub    $0x4,%esp
8010987d:	6a 06                	push   $0x6
8010987f:	52                   	push   %edx
80109880:	50                   	push   %eax
80109881:	e8 fd b2 ff ff       	call   80104b83 <memmove>
80109886:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109889:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010988c:	83 c0 06             	add    $0x6,%eax
8010988f:	83 ec 04             	sub    $0x4,%esp
80109892:	6a 06                	push   $0x6
80109894:	68 80 6c 19 80       	push   $0x80196c80
80109899:	50                   	push   %eax
8010989a:	e8 e4 b2 ff ff       	call   80104b83 <memmove>
8010989f:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801098a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098a5:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801098a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098ac:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801098b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098b3:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801098b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098b9:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
801098bd:	83 ec 0c             	sub    $0xc,%esp
801098c0:	6a 54                	push   $0x54
801098c2:	e8 03 fd ff ff       	call   801095ca <H2N_ushort>
801098c7:	83 c4 10             	add    $0x10,%esp
801098ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801098cd:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
801098d1:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
801098d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098db:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801098df:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
801098e6:	83 c0 01             	add    $0x1,%eax
801098e9:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
801098ef:	83 ec 0c             	sub    $0xc,%esp
801098f2:	68 00 40 00 00       	push   $0x4000
801098f7:	e8 ce fc ff ff       	call   801095ca <H2N_ushort>
801098fc:	83 c4 10             	add    $0x10,%esp
801098ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109902:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109906:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109909:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010990d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109910:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109917:	83 c0 0c             	add    $0xc,%eax
8010991a:	83 ec 04             	sub    $0x4,%esp
8010991d:	6a 04                	push   $0x4
8010991f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109924:	50                   	push   %eax
80109925:	e8 59 b2 ff ff       	call   80104b83 <memmove>
8010992a:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010992d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109930:	8d 50 0c             	lea    0xc(%eax),%edx
80109933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109936:	83 c0 10             	add    $0x10,%eax
80109939:	83 ec 04             	sub    $0x4,%esp
8010993c:	6a 04                	push   $0x4
8010993e:	52                   	push   %edx
8010993f:	50                   	push   %eax
80109940:	e8 3e b2 ff ff       	call   80104b83 <memmove>
80109945:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010994b:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109951:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109954:	83 ec 0c             	sub    $0xc,%esp
80109957:	50                   	push   %eax
80109958:	e8 6d fd ff ff       	call   801096ca <ipv4_chksum>
8010995d:	83 c4 10             	add    $0x10,%esp
80109960:	0f b7 c0             	movzwl %ax,%eax
80109963:	83 ec 0c             	sub    $0xc,%esp
80109966:	50                   	push   %eax
80109967:	e8 5e fc ff ff       	call   801095ca <H2N_ushort>
8010996c:	83 c4 10             	add    $0x10,%esp
8010996f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109972:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109976:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109979:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010997c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010997f:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109983:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109986:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010998a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010998d:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109991:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109994:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109998:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010999b:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010999f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099a2:	8d 50 08             	lea    0x8(%eax),%edx
801099a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099a8:	83 c0 08             	add    $0x8,%eax
801099ab:	83 ec 04             	sub    $0x4,%esp
801099ae:	6a 08                	push   $0x8
801099b0:	52                   	push   %edx
801099b1:	50                   	push   %eax
801099b2:	e8 cc b1 ff ff       	call   80104b83 <memmove>
801099b7:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801099ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099bd:	8d 50 10             	lea    0x10(%eax),%edx
801099c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099c3:	83 c0 10             	add    $0x10,%eax
801099c6:	83 ec 04             	sub    $0x4,%esp
801099c9:	6a 30                	push   $0x30
801099cb:	52                   	push   %edx
801099cc:	50                   	push   %eax
801099cd:	e8 b1 b1 ff ff       	call   80104b83 <memmove>
801099d2:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
801099d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099d8:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
801099de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801099e1:	83 ec 0c             	sub    $0xc,%esp
801099e4:	50                   	push   %eax
801099e5:	e8 1c 00 00 00       	call   80109a06 <icmp_chksum>
801099ea:	83 c4 10             	add    $0x10,%esp
801099ed:	0f b7 c0             	movzwl %ax,%eax
801099f0:	83 ec 0c             	sub    $0xc,%esp
801099f3:	50                   	push   %eax
801099f4:	e8 d1 fb ff ff       	call   801095ca <H2N_ushort>
801099f9:	83 c4 10             	add    $0x10,%esp
801099fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801099ff:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109a03:	90                   	nop
80109a04:	c9                   	leave  
80109a05:	c3                   	ret    

80109a06 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109a06:	55                   	push   %ebp
80109a07:	89 e5                	mov    %esp,%ebp
80109a09:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109a12:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109a19:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a20:	eb 48                	jmp    80109a6a <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a22:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a25:	01 c0                	add    %eax,%eax
80109a27:	89 c2                	mov    %eax,%edx
80109a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a2c:	01 d0                	add    %edx,%eax
80109a2e:	0f b6 00             	movzbl (%eax),%eax
80109a31:	0f b6 c0             	movzbl %al,%eax
80109a34:	c1 e0 08             	shl    $0x8,%eax
80109a37:	89 c2                	mov    %eax,%edx
80109a39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a3c:	01 c0                	add    %eax,%eax
80109a3e:	8d 48 01             	lea    0x1(%eax),%ecx
80109a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a44:	01 c8                	add    %ecx,%eax
80109a46:	0f b6 00             	movzbl (%eax),%eax
80109a49:	0f b6 c0             	movzbl %al,%eax
80109a4c:	01 d0                	add    %edx,%eax
80109a4e:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a51:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a58:	76 0c                	jbe    80109a66 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a5d:	0f b7 c0             	movzwl %ax,%eax
80109a60:	83 c0 01             	add    $0x1,%eax
80109a63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109a66:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a6a:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109a6e:	7e b2                	jle    80109a22 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a73:	f7 d0                	not    %eax
}
80109a75:	c9                   	leave  
80109a76:	c3                   	ret    

80109a77 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109a77:	55                   	push   %ebp
80109a78:	89 e5                	mov    %esp,%ebp
80109a7a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a80:	83 c0 0e             	add    $0xe,%eax
80109a83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a89:	0f b6 00             	movzbl (%eax),%eax
80109a8c:	0f b6 c0             	movzbl %al,%eax
80109a8f:	83 e0 0f             	and    $0xf,%eax
80109a92:	c1 e0 02             	shl    $0x2,%eax
80109a95:	89 c2                	mov    %eax,%edx
80109a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a9a:	01 d0                	add    %edx,%eax
80109a9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa2:	83 c0 14             	add    $0x14,%eax
80109aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109aa8:	e8 f4 8c ff ff       	call   801027a1 <kalloc>
80109aad:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109ab0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aba:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109abe:	0f b6 c0             	movzbl %al,%eax
80109ac1:	83 e0 02             	and    $0x2,%eax
80109ac4:	85 c0                	test   %eax,%eax
80109ac6:	74 3d                	je     80109b05 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109ac8:	83 ec 0c             	sub    $0xc,%esp
80109acb:	6a 00                	push   $0x0
80109acd:	6a 12                	push   $0x12
80109acf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ad2:	50                   	push   %eax
80109ad3:	ff 75 e8             	push   -0x18(%ebp)
80109ad6:	ff 75 08             	push   0x8(%ebp)
80109ad9:	e8 a2 01 00 00       	call   80109c80 <tcp_pkt_create>
80109ade:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109ae1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ae4:	83 ec 08             	sub    $0x8,%esp
80109ae7:	50                   	push   %eax
80109ae8:	ff 75 e8             	push   -0x18(%ebp)
80109aeb:	e8 61 f1 ff ff       	call   80108c51 <i8254_send>
80109af0:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109af3:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109af8:	83 c0 01             	add    $0x1,%eax
80109afb:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109b00:	e9 69 01 00 00       	jmp    80109c6e <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b08:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b0c:	3c 18                	cmp    $0x18,%al
80109b0e:	0f 85 10 01 00 00    	jne    80109c24 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109b14:	83 ec 04             	sub    $0x4,%esp
80109b17:	6a 03                	push   $0x3
80109b19:	68 9e c1 10 80       	push   $0x8010c19e
80109b1e:	ff 75 ec             	push   -0x14(%ebp)
80109b21:	e8 05 b0 ff ff       	call   80104b2b <memcmp>
80109b26:	83 c4 10             	add    $0x10,%esp
80109b29:	85 c0                	test   %eax,%eax
80109b2b:	74 74                	je     80109ba1 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109b2d:	83 ec 0c             	sub    $0xc,%esp
80109b30:	68 a2 c1 10 80       	push   $0x8010c1a2
80109b35:	e8 ba 68 ff ff       	call   801003f4 <cprintf>
80109b3a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109b3d:	83 ec 0c             	sub    $0xc,%esp
80109b40:	6a 00                	push   $0x0
80109b42:	6a 10                	push   $0x10
80109b44:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b47:	50                   	push   %eax
80109b48:	ff 75 e8             	push   -0x18(%ebp)
80109b4b:	ff 75 08             	push   0x8(%ebp)
80109b4e:	e8 2d 01 00 00       	call   80109c80 <tcp_pkt_create>
80109b53:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109b56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b59:	83 ec 08             	sub    $0x8,%esp
80109b5c:	50                   	push   %eax
80109b5d:	ff 75 e8             	push   -0x18(%ebp)
80109b60:	e8 ec f0 ff ff       	call   80108c51 <i8254_send>
80109b65:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b6b:	83 c0 36             	add    $0x36,%eax
80109b6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b71:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109b74:	50                   	push   %eax
80109b75:	ff 75 e0             	push   -0x20(%ebp)
80109b78:	6a 00                	push   $0x0
80109b7a:	6a 00                	push   $0x0
80109b7c:	e8 5a 04 00 00       	call   80109fdb <http_proc>
80109b81:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b84:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109b87:	83 ec 0c             	sub    $0xc,%esp
80109b8a:	50                   	push   %eax
80109b8b:	6a 18                	push   $0x18
80109b8d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b90:	50                   	push   %eax
80109b91:	ff 75 e8             	push   -0x18(%ebp)
80109b94:	ff 75 08             	push   0x8(%ebp)
80109b97:	e8 e4 00 00 00       	call   80109c80 <tcp_pkt_create>
80109b9c:	83 c4 20             	add    $0x20,%esp
80109b9f:	eb 62                	jmp    80109c03 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	6a 00                	push   $0x0
80109ba6:	6a 10                	push   $0x10
80109ba8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bab:	50                   	push   %eax
80109bac:	ff 75 e8             	push   -0x18(%ebp)
80109baf:	ff 75 08             	push   0x8(%ebp)
80109bb2:	e8 c9 00 00 00       	call   80109c80 <tcp_pkt_create>
80109bb7:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109bba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bbd:	83 ec 08             	sub    $0x8,%esp
80109bc0:	50                   	push   %eax
80109bc1:	ff 75 e8             	push   -0x18(%ebp)
80109bc4:	e8 88 f0 ff ff       	call   80108c51 <i8254_send>
80109bc9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109bcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bcf:	83 c0 36             	add    $0x36,%eax
80109bd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109bd5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109bd8:	50                   	push   %eax
80109bd9:	ff 75 e4             	push   -0x1c(%ebp)
80109bdc:	6a 00                	push   $0x0
80109bde:	6a 00                	push   $0x0
80109be0:	e8 f6 03 00 00       	call   80109fdb <http_proc>
80109be5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109be8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109beb:	83 ec 0c             	sub    $0xc,%esp
80109bee:	50                   	push   %eax
80109bef:	6a 18                	push   $0x18
80109bf1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bf4:	50                   	push   %eax
80109bf5:	ff 75 e8             	push   -0x18(%ebp)
80109bf8:	ff 75 08             	push   0x8(%ebp)
80109bfb:	e8 80 00 00 00       	call   80109c80 <tcp_pkt_create>
80109c00:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109c03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c06:	83 ec 08             	sub    $0x8,%esp
80109c09:	50                   	push   %eax
80109c0a:	ff 75 e8             	push   -0x18(%ebp)
80109c0d:	e8 3f f0 ff ff       	call   80108c51 <i8254_send>
80109c12:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109c15:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109c1a:	83 c0 01             	add    $0x1,%eax
80109c1d:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109c22:	eb 4a                	jmp    80109c6e <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c27:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c2b:	3c 10                	cmp    $0x10,%al
80109c2d:	75 3f                	jne    80109c6e <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109c2f:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109c34:	83 f8 01             	cmp    $0x1,%eax
80109c37:	75 35                	jne    80109c6e <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109c39:	83 ec 0c             	sub    $0xc,%esp
80109c3c:	6a 00                	push   $0x0
80109c3e:	6a 01                	push   $0x1
80109c40:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c43:	50                   	push   %eax
80109c44:	ff 75 e8             	push   -0x18(%ebp)
80109c47:	ff 75 08             	push   0x8(%ebp)
80109c4a:	e8 31 00 00 00       	call   80109c80 <tcp_pkt_create>
80109c4f:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109c52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c55:	83 ec 08             	sub    $0x8,%esp
80109c58:	50                   	push   %eax
80109c59:	ff 75 e8             	push   -0x18(%ebp)
80109c5c:	e8 f0 ef ff ff       	call   80108c51 <i8254_send>
80109c61:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109c64:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109c6b:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c71:	83 ec 0c             	sub    $0xc,%esp
80109c74:	50                   	push   %eax
80109c75:	e8 8d 8a ff ff       	call   80102707 <kfree>
80109c7a:	83 c4 10             	add    $0x10,%esp
}
80109c7d:	90                   	nop
80109c7e:	c9                   	leave  
80109c7f:	c3                   	ret    

80109c80 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109c80:	55                   	push   %ebp
80109c81:	89 e5                	mov    %esp,%ebp
80109c83:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c86:	8b 45 08             	mov    0x8(%ebp),%eax
80109c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8f:	83 c0 0e             	add    $0xe,%eax
80109c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c98:	0f b6 00             	movzbl (%eax),%eax
80109c9b:	0f b6 c0             	movzbl %al,%eax
80109c9e:	83 e0 0f             	and    $0xf,%eax
80109ca1:	c1 e0 02             	shl    $0x2,%eax
80109ca4:	89 c2                	mov    %eax,%edx
80109ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ca9:	01 d0                	add    %edx,%eax
80109cab:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109cae:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cb7:	83 c0 0e             	add    $0xe,%eax
80109cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109cbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc0:	83 c0 14             	add    $0x14,%eax
80109cc3:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109cc6:	8b 45 18             	mov    0x18(%ebp),%eax
80109cc9:	8d 50 36             	lea    0x36(%eax),%edx
80109ccc:	8b 45 10             	mov    0x10(%ebp),%eax
80109ccf:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd4:	8d 50 06             	lea    0x6(%eax),%edx
80109cd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cda:	83 ec 04             	sub    $0x4,%esp
80109cdd:	6a 06                	push   $0x6
80109cdf:	52                   	push   %edx
80109ce0:	50                   	push   %eax
80109ce1:	e8 9d ae ff ff       	call   80104b83 <memmove>
80109ce6:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cec:	83 c0 06             	add    $0x6,%eax
80109cef:	83 ec 04             	sub    $0x4,%esp
80109cf2:	6a 06                	push   $0x6
80109cf4:	68 80 6c 19 80       	push   $0x80196c80
80109cf9:	50                   	push   %eax
80109cfa:	e8 84 ae ff ff       	call   80104b83 <memmove>
80109cff:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d05:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d0c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d13:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d19:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109d1d:	8b 45 18             	mov    0x18(%ebp),%eax
80109d20:	83 c0 28             	add    $0x28,%eax
80109d23:	0f b7 c0             	movzwl %ax,%eax
80109d26:	83 ec 0c             	sub    $0xc,%esp
80109d29:	50                   	push   %eax
80109d2a:	e8 9b f8 ff ff       	call   801095ca <H2N_ushort>
80109d2f:	83 c4 10             	add    $0x10,%esp
80109d32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d35:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d39:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d43:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d47:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109d4e:	83 c0 01             	add    $0x1,%eax
80109d51:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109d57:	83 ec 0c             	sub    $0xc,%esp
80109d5a:	6a 00                	push   $0x0
80109d5c:	e8 69 f8 ff ff       	call   801095ca <H2N_ushort>
80109d61:	83 c4 10             	add    $0x10,%esp
80109d64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d67:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d6e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109d72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d75:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d7c:	83 c0 0c             	add    $0xc,%eax
80109d7f:	83 ec 04             	sub    $0x4,%esp
80109d82:	6a 04                	push   $0x4
80109d84:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d89:	50                   	push   %eax
80109d8a:	e8 f4 ad ff ff       	call   80104b83 <memmove>
80109d8f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d95:	8d 50 0c             	lea    0xc(%eax),%edx
80109d98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9b:	83 c0 10             	add    $0x10,%eax
80109d9e:	83 ec 04             	sub    $0x4,%esp
80109da1:	6a 04                	push   $0x4
80109da3:	52                   	push   %edx
80109da4:	50                   	push   %eax
80109da5:	e8 d9 ad ff ff       	call   80104b83 <memmove>
80109daa:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	50                   	push   %eax
80109dbd:	e8 08 f9 ff ff       	call   801096ca <ipv4_chksum>
80109dc2:	83 c4 10             	add    $0x10,%esp
80109dc5:	0f b7 c0             	movzwl %ax,%eax
80109dc8:	83 ec 0c             	sub    $0xc,%esp
80109dcb:	50                   	push   %eax
80109dcc:	e8 f9 f7 ff ff       	call   801095ca <H2N_ushort>
80109dd1:	83 c4 10             	add    $0x10,%esp
80109dd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dd7:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dde:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109de2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de5:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109de8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109deb:	0f b7 10             	movzwl (%eax),%edx
80109dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df1:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109df5:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109dfa:	83 ec 0c             	sub    $0xc,%esp
80109dfd:	50                   	push   %eax
80109dfe:	e8 e9 f7 ff ff       	call   801095ec <H2N_uint>
80109e03:	83 c4 10             	add    $0x10,%esp
80109e06:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e09:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109e0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e0f:	8b 40 04             	mov    0x4(%eax),%eax
80109e12:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109e18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e1b:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109e1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e21:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e28:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109e2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e2f:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109e33:	8b 45 14             	mov    0x14(%ebp),%eax
80109e36:	89 c2                	mov    %eax,%edx
80109e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e3b:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109e3e:	83 ec 0c             	sub    $0xc,%esp
80109e41:	68 90 38 00 00       	push   $0x3890
80109e46:	e8 7f f7 ff ff       	call   801095ca <H2N_ushort>
80109e4b:	83 c4 10             	add    $0x10,%esp
80109e4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e51:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109e55:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e58:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109e5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e61:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e6a:	83 ec 0c             	sub    $0xc,%esp
80109e6d:	50                   	push   %eax
80109e6e:	e8 1f 00 00 00       	call   80109e92 <tcp_chksum>
80109e73:	83 c4 10             	add    $0x10,%esp
80109e76:	83 c0 08             	add    $0x8,%eax
80109e79:	0f b7 c0             	movzwl %ax,%eax
80109e7c:	83 ec 0c             	sub    $0xc,%esp
80109e7f:	50                   	push   %eax
80109e80:	e8 45 f7 ff ff       	call   801095ca <H2N_ushort>
80109e85:	83 c4 10             	add    $0x10,%esp
80109e88:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e8b:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109e8f:	90                   	nop
80109e90:	c9                   	leave  
80109e91:	c3                   	ret    

80109e92 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109e92:	55                   	push   %ebp
80109e93:	89 e5                	mov    %esp,%ebp
80109e95:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109e98:	8b 45 08             	mov    0x8(%ebp),%eax
80109e9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109e9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ea1:	83 c0 14             	add    $0x14,%eax
80109ea4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109ea7:	83 ec 04             	sub    $0x4,%esp
80109eaa:	6a 04                	push   $0x4
80109eac:	68 e4 f4 10 80       	push   $0x8010f4e4
80109eb1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109eb4:	50                   	push   %eax
80109eb5:	e8 c9 ac ff ff       	call   80104b83 <memmove>
80109eba:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ec0:	83 c0 0c             	add    $0xc,%eax
80109ec3:	83 ec 04             	sub    $0x4,%esp
80109ec6:	6a 04                	push   $0x4
80109ec8:	50                   	push   %eax
80109ec9:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ecc:	83 c0 04             	add    $0x4,%eax
80109ecf:	50                   	push   %eax
80109ed0:	e8 ae ac ff ff       	call   80104b83 <memmove>
80109ed5:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109ed8:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109edc:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109ee0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ee3:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109ee7:	0f b7 c0             	movzwl %ax,%eax
80109eea:	83 ec 0c             	sub    $0xc,%esp
80109eed:	50                   	push   %eax
80109eee:	e8 b5 f6 ff ff       	call   801095a8 <N2H_ushort>
80109ef3:	83 c4 10             	add    $0x10,%esp
80109ef6:	83 e8 14             	sub    $0x14,%eax
80109ef9:	0f b7 c0             	movzwl %ax,%eax
80109efc:	83 ec 0c             	sub    $0xc,%esp
80109eff:	50                   	push   %eax
80109f00:	e8 c5 f6 ff ff       	call   801095ca <H2N_ushort>
80109f05:	83 c4 10             	add    $0x10,%esp
80109f08:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109f0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109f13:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f16:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109f19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109f20:	eb 33                	jmp    80109f55 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f25:	01 c0                	add    %eax,%eax
80109f27:	89 c2                	mov    %eax,%edx
80109f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f2c:	01 d0                	add    %edx,%eax
80109f2e:	0f b6 00             	movzbl (%eax),%eax
80109f31:	0f b6 c0             	movzbl %al,%eax
80109f34:	c1 e0 08             	shl    $0x8,%eax
80109f37:	89 c2                	mov    %eax,%edx
80109f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f3c:	01 c0                	add    %eax,%eax
80109f3e:	8d 48 01             	lea    0x1(%eax),%ecx
80109f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f44:	01 c8                	add    %ecx,%eax
80109f46:	0f b6 00             	movzbl (%eax),%eax
80109f49:	0f b6 c0             	movzbl %al,%eax
80109f4c:	01 d0                	add    %edx,%eax
80109f4e:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109f51:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109f55:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109f59:	7e c7                	jle    80109f22 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109f61:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109f68:	eb 33                	jmp    80109f9d <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f6d:	01 c0                	add    %eax,%eax
80109f6f:	89 c2                	mov    %eax,%edx
80109f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f74:	01 d0                	add    %edx,%eax
80109f76:	0f b6 00             	movzbl (%eax),%eax
80109f79:	0f b6 c0             	movzbl %al,%eax
80109f7c:	c1 e0 08             	shl    $0x8,%eax
80109f7f:	89 c2                	mov    %eax,%edx
80109f81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f84:	01 c0                	add    %eax,%eax
80109f86:	8d 48 01             	lea    0x1(%eax),%ecx
80109f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f8c:	01 c8                	add    %ecx,%eax
80109f8e:	0f b6 00             	movzbl (%eax),%eax
80109f91:	0f b6 c0             	movzbl %al,%eax
80109f94:	01 d0                	add    %edx,%eax
80109f96:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109f99:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109f9d:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109fa1:	0f b7 c0             	movzwl %ax,%eax
80109fa4:	83 ec 0c             	sub    $0xc,%esp
80109fa7:	50                   	push   %eax
80109fa8:	e8 fb f5 ff ff       	call   801095a8 <N2H_ushort>
80109fad:	83 c4 10             	add    $0x10,%esp
80109fb0:	66 d1 e8             	shr    %ax
80109fb3:	0f b7 c0             	movzwl %ax,%eax
80109fb6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109fb9:	7c af                	jl     80109f6a <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fbe:	c1 e8 10             	shr    $0x10,%eax
80109fc1:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc7:	f7 d0                	not    %eax
}
80109fc9:	c9                   	leave  
80109fca:	c3                   	ret    

80109fcb <tcp_fin>:

void tcp_fin(){
80109fcb:	55                   	push   %ebp
80109fcc:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109fce:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109fd5:	00 00 00 
}
80109fd8:	90                   	nop
80109fd9:	5d                   	pop    %ebp
80109fda:	c3                   	ret    

80109fdb <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109fdb:	55                   	push   %ebp
80109fdc:	89 e5                	mov    %esp,%ebp
80109fde:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109fe1:	8b 45 10             	mov    0x10(%ebp),%eax
80109fe4:	83 ec 04             	sub    $0x4,%esp
80109fe7:	6a 00                	push   $0x0
80109fe9:	68 ab c1 10 80       	push   $0x8010c1ab
80109fee:	50                   	push   %eax
80109fef:	e8 65 00 00 00       	call   8010a059 <http_strcpy>
80109ff4:	83 c4 10             	add    $0x10,%esp
80109ff7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109ffa:	8b 45 10             	mov    0x10(%ebp),%eax
80109ffd:	83 ec 04             	sub    $0x4,%esp
8010a000:	ff 75 f4             	push   -0xc(%ebp)
8010a003:	68 be c1 10 80       	push   $0x8010c1be
8010a008:	50                   	push   %eax
8010a009:	e8 4b 00 00 00       	call   8010a059 <http_strcpy>
8010a00e:	83 c4 10             	add    $0x10,%esp
8010a011:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a014:	8b 45 10             	mov    0x10(%ebp),%eax
8010a017:	83 ec 04             	sub    $0x4,%esp
8010a01a:	ff 75 f4             	push   -0xc(%ebp)
8010a01d:	68 d9 c1 10 80       	push   $0x8010c1d9
8010a022:	50                   	push   %eax
8010a023:	e8 31 00 00 00       	call   8010a059 <http_strcpy>
8010a028:	83 c4 10             	add    $0x10,%esp
8010a02b:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a02e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a031:	83 e0 01             	and    $0x1,%eax
8010a034:	85 c0                	test   %eax,%eax
8010a036:	74 11                	je     8010a049 <http_proc+0x6e>
    char *payload = (char *)send;
8010a038:	8b 45 10             	mov    0x10(%ebp),%eax
8010a03b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a03e:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a041:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a044:	01 d0                	add    %edx,%eax
8010a046:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a049:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a04c:	8b 45 14             	mov    0x14(%ebp),%eax
8010a04f:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a051:	e8 75 ff ff ff       	call   80109fcb <tcp_fin>
}
8010a056:	90                   	nop
8010a057:	c9                   	leave  
8010a058:	c3                   	ret    

8010a059 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a059:	55                   	push   %ebp
8010a05a:	89 e5                	mov    %esp,%ebp
8010a05c:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a05f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a066:	eb 20                	jmp    8010a088 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a068:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a06b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a06e:	01 d0                	add    %edx,%eax
8010a070:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a073:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a076:	01 ca                	add    %ecx,%edx
8010a078:	89 d1                	mov    %edx,%ecx
8010a07a:	8b 55 08             	mov    0x8(%ebp),%edx
8010a07d:	01 ca                	add    %ecx,%edx
8010a07f:	0f b6 00             	movzbl (%eax),%eax
8010a082:	88 02                	mov    %al,(%edx)
    i++;
8010a084:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a088:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a08b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a08e:	01 d0                	add    %edx,%eax
8010a090:	0f b6 00             	movzbl (%eax),%eax
8010a093:	84 c0                	test   %al,%al
8010a095:	75 d1                	jne    8010a068 <http_strcpy+0xf>
  }
  return i;
8010a097:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a09a:	c9                   	leave  
8010a09b:	c3                   	ret    

8010a09c <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a09c:	55                   	push   %ebp
8010a09d:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a09f:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
8010a0a6:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a0a9:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a0ae:	c1 e8 09             	shr    $0x9,%eax
8010a0b1:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a0b6:	90                   	nop
8010a0b7:	5d                   	pop    %ebp
8010a0b8:	c3                   	ret    

8010a0b9 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a0b9:	55                   	push   %ebp
8010a0ba:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a0bc:	90                   	nop
8010a0bd:	5d                   	pop    %ebp
8010a0be:	c3                   	ret    

8010a0bf <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a0bf:	55                   	push   %ebp
8010a0c0:	89 e5                	mov    %esp,%ebp
8010a0c2:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a0c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c8:	83 c0 0c             	add    $0xc,%eax
8010a0cb:	83 ec 0c             	sub    $0xc,%esp
8010a0ce:	50                   	push   %eax
8010a0cf:	e8 e9 a6 ff ff       	call   801047bd <holdingsleep>
8010a0d4:	83 c4 10             	add    $0x10,%esp
8010a0d7:	85 c0                	test   %eax,%eax
8010a0d9:	75 0d                	jne    8010a0e8 <iderw+0x29>
    panic("iderw: buf not locked");
8010a0db:	83 ec 0c             	sub    $0xc,%esp
8010a0de:	68 ea c1 10 80       	push   $0x8010c1ea
8010a0e3:	e8 c1 64 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a0e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0eb:	8b 00                	mov    (%eax),%eax
8010a0ed:	83 e0 06             	and    $0x6,%eax
8010a0f0:	83 f8 02             	cmp    $0x2,%eax
8010a0f3:	75 0d                	jne    8010a102 <iderw+0x43>
    panic("iderw: nothing to do");
8010a0f5:	83 ec 0c             	sub    $0xc,%esp
8010a0f8:	68 00 c2 10 80       	push   $0x8010c200
8010a0fd:	e8 a7 64 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a102:	8b 45 08             	mov    0x8(%ebp),%eax
8010a105:	8b 40 04             	mov    0x4(%eax),%eax
8010a108:	83 f8 01             	cmp    $0x1,%eax
8010a10b:	74 0d                	je     8010a11a <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a10d:	83 ec 0c             	sub    $0xc,%esp
8010a110:	68 15 c2 10 80       	push   $0x8010c215
8010a115:	e8 8f 64 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a11a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a11d:	8b 40 08             	mov    0x8(%eax),%eax
8010a120:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a126:	39 d0                	cmp    %edx,%eax
8010a128:	72 0d                	jb     8010a137 <iderw+0x78>
    panic("iderw: block out of range");
8010a12a:	83 ec 0c             	sub    $0xc,%esp
8010a12d:	68 33 c2 10 80       	push   $0x8010c233
8010a132:	e8 72 64 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a137:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a13d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a140:	8b 40 08             	mov    0x8(%eax),%eax
8010a143:	c1 e0 09             	shl    $0x9,%eax
8010a146:	01 d0                	add    %edx,%eax
8010a148:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a14b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a14e:	8b 00                	mov    (%eax),%eax
8010a150:	83 e0 04             	and    $0x4,%eax
8010a153:	85 c0                	test   %eax,%eax
8010a155:	74 2b                	je     8010a182 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a157:	8b 45 08             	mov    0x8(%ebp),%eax
8010a15a:	8b 00                	mov    (%eax),%eax
8010a15c:	83 e0 fb             	and    $0xfffffffb,%eax
8010a15f:	89 c2                	mov    %eax,%edx
8010a161:	8b 45 08             	mov    0x8(%ebp),%eax
8010a164:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a166:	8b 45 08             	mov    0x8(%ebp),%eax
8010a169:	83 c0 5c             	add    $0x5c,%eax
8010a16c:	83 ec 04             	sub    $0x4,%esp
8010a16f:	68 00 02 00 00       	push   $0x200
8010a174:	50                   	push   %eax
8010a175:	ff 75 f4             	push   -0xc(%ebp)
8010a178:	e8 06 aa ff ff       	call   80104b83 <memmove>
8010a17d:	83 c4 10             	add    $0x10,%esp
8010a180:	eb 1a                	jmp    8010a19c <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a182:	8b 45 08             	mov    0x8(%ebp),%eax
8010a185:	83 c0 5c             	add    $0x5c,%eax
8010a188:	83 ec 04             	sub    $0x4,%esp
8010a18b:	68 00 02 00 00       	push   $0x200
8010a190:	ff 75 f4             	push   -0xc(%ebp)
8010a193:	50                   	push   %eax
8010a194:	e8 ea a9 ff ff       	call   80104b83 <memmove>
8010a199:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a19c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a19f:	8b 00                	mov    (%eax),%eax
8010a1a1:	83 c8 02             	or     $0x2,%eax
8010a1a4:	89 c2                	mov    %eax,%edx
8010a1a6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a9:	89 10                	mov    %edx,(%eax)
}
8010a1ab:	90                   	nop
8010a1ac:	c9                   	leave  
8010a1ad:	c3                   	ret    
