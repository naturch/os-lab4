
kernel:     file format elf32-i386


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
8010005a:	bc b0 af 11 80       	mov    $0x8011afb0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 57 38 10 80       	mov    $0x80103857,%edx
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
8010006f:	68 20 a5 10 80       	push   $0x8010a520
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 5d 4c 00 00       	call   80104cdb <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a5 10 80       	push   $0x8010a527
801000c2:	50                   	push   %eax
801000c3:	e8 b6 4a 00 00       	call   80104b7e <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
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
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 f7 4b 00 00       	call   80104cfd <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
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
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 26 4c 00 00       	call   80104d6b <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 63 4a 00 00       	call   80104bba <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
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
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 a5 4b 00 00       	call   80104d6b <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 e2 49 00 00       	call   80104bba <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a5 10 80       	push   $0x8010a52e
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
8010022d:	e8 07 27 00 00       	call   80102939 <iderw>
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
8010024a:	e8 1d 4a 00 00       	call   80104c6c <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a5 10 80       	push   $0x8010a53f
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
80100278:	e8 bc 26 00 00       	call   80102939 <iderw>
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
80100293:	e8 d4 49 00 00       	call   80104c6c <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a5 10 80       	push   $0x8010a546
801002a7:	e8 15 03 00 00       	call   801005c1 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 63 49 00 00       	call   80104c1e <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 32 4a 00 00       	call   80104cfd <acquire>
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
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 30 4a 00 00       	call   80104d6b <release>
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
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 e8 48 00 00       	call   80104cfd <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 50 a5 10 80       	push   $0x8010a550
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
801004b2:	8b 04 85 60 a5 10 80 	mov    -0x7fef5aa0(,%eax,4),%eax
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
80100528:	c7 45 ec 59 a5 10 80 	movl   $0x8010a559,-0x14(%ebp)
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
801005b1:	68 00 4a 11 80       	push   $0x80114a00
801005b6:	e8 b0 47 00 00       	call   80104d6b <release>
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
801005cc:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005d3:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005d6:	e8 11 2a 00 00       	call   80102fec <lapicid>
801005db:	83 ec 08             	sub    $0x8,%esp
801005de:	50                   	push   %eax
801005df:	68 b8 a5 10 80       	push   $0x8010a5b8
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
801005fe:	68 cc a5 10 80       	push   $0x8010a5cc
80100603:	e8 ec fd ff ff       	call   801003f4 <cprintf>
80100608:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010060b:	83 ec 08             	sub    $0x8,%esp
8010060e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100611:	50                   	push   %eax
80100612:	8d 45 08             	lea    0x8(%ebp),%eax
80100615:	50                   	push   %eax
80100616:	e8 a2 47 00 00       	call   80104dbd <getcallerpcs>
8010061b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010061e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100625:	eb 1c                	jmp    80100643 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010062a:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010062e:	83 ec 08             	sub    $0x8,%esp
80100631:	50                   	push   %eax
80100632:	68 ce a5 10 80       	push   $0x8010a5ce
80100637:	e8 b8 fd ff ff       	call   801003f4 <cprintf>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100643:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100647:	7e de                	jle    80100627 <panic+0x66>
  panicked = 1; // freeze other CPU
80100649:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
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
801006b8:	e8 d1 7d 00 00       	call   8010848e <graphic_scroll_up>
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
8010070b:	e8 7e 7d 00 00       	call   8010848e <graphic_scroll_up>
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
8010076f:	e8 85 7d 00 00       	call   801084f9 <font_render>
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
8010078d:	a1 ec 49 11 80       	mov    0x801149ec,%eax
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
801007ab:	e8 6a 61 00 00       	call   8010691a <uartputc>
801007b0:	83 c4 10             	add    $0x10,%esp
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	6a 20                	push   $0x20
801007b8:	e8 5d 61 00 00       	call   8010691a <uartputc>
801007bd:	83 c4 10             	add    $0x10,%esp
801007c0:	83 ec 0c             	sub    $0xc,%esp
801007c3:	6a 08                	push   $0x8
801007c5:	e8 50 61 00 00       	call   8010691a <uartputc>
801007ca:	83 c4 10             	add    $0x10,%esp
801007cd:	eb 0e                	jmp    801007dd <consputc+0x56>
  } else {
    uartputc(c);
801007cf:	83 ec 0c             	sub    $0xc,%esp
801007d2:	ff 75 08             	push   0x8(%ebp)
801007d5:	e8 40 61 00 00       	call   8010691a <uartputc>
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
801007fe:	68 00 4a 11 80       	push   $0x80114a00
80100803:	e8 f5 44 00 00       	call   80104cfd <acquire>
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
80100850:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100855:	83 e8 01             	sub    $0x1,%eax
80100858:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
8010085d:	83 ec 0c             	sub    $0xc,%esp
80100860:	68 00 01 00 00       	push   $0x100
80100865:	e8 1d ff ff ff       	call   80100787 <consputc>
8010086a:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010086d:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100873:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100878:	39 c2                	cmp    %eax,%edx
8010087a:	0f 84 e0 00 00 00    	je     80100960 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100880:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	83 e0 7f             	and    $0x7f,%eax
8010088b:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
80100892:	3c 0a                	cmp    $0xa,%al
80100894:	75 ba                	jne    80100850 <consoleintr+0x62>
      }
      break;
80100896:	e9 c5 00 00 00       	jmp    80100960 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010089b:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
801008a1:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 b2 00 00 00    	je     80100960 <consoleintr+0x172>
        input.e--;
801008ae:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	a3 e8 49 11 80       	mov    %eax,0x801149e8
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
801008da:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008df:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
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
801008ff:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100904:	8d 50 01             	lea    0x1(%eax),%edx
80100907:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
8010090d:	83 e0 7f             	and    $0x7f,%eax
80100910:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100913:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
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
80100933:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100938:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
8010093e:	83 ea 80             	sub    $0xffffff80,%edx
80100941:	39 d0                	cmp    %edx,%eax
80100943:	75 1a                	jne    8010095f <consoleintr+0x171>
          input.w = input.e;
80100945:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010094a:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e0 49 11 80       	push   $0x801149e0
80100957:	e8 56 3f 00 00       	call   801048b2 <wakeup>
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
80100975:	68 00 4a 11 80       	push   $0x80114a00
8010097a:	e8 ec 43 00 00       	call   80104d6b <release>
8010097f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100982:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100986:	74 05                	je     8010098d <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100988:	e8 e0 3f 00 00       	call   8010496d <procdump>
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
801009ad:	68 00 4a 11 80       	push   $0x80114a00
801009b2:	e8 46 43 00 00       	call   80104cfd <acquire>
801009b7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ba:	e9 ab 00 00 00       	jmp    80100a6a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009bf:	e8 5e 35 00 00       	call   80103f22 <myproc>
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x63>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 00 4a 11 80       	push   $0x80114a00
801009d3:	e8 93 43 00 00       	call   80104d6b <release>
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
801009f6:	68 00 4a 11 80       	push   $0x80114a00
801009fb:	68 e0 49 11 80       	push   $0x801149e0
80100a00:	e8 c6 3d 00 00       	call   801047cb <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a08:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100a0e:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a8                	je     801009bf <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
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
80100a43:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 e0 49 11 80       	mov    %eax,0x801149e0
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
80100a79:	68 00 4a 11 80       	push   $0x80114a00
80100a7e:	e8 e8 42 00 00       	call   80104d6b <release>
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
80100ab5:	68 00 4a 11 80       	push   $0x80114a00
80100aba:	e8 3e 42 00 00       	call   80104cfd <acquire>
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
80100af7:	68 00 4a 11 80       	push   $0x80114a00
80100afc:	e8 6a 42 00 00       	call   80104d6b <release>
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
80100b1d:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b24:	00 00 00 
  initlock(&cons.lock, "console");
80100b27:	83 ec 08             	sub    $0x8,%esp
80100b2a:	68 d2 a5 10 80       	push   $0x8010a5d2
80100b2f:	68 00 4a 11 80       	push   $0x80114a00
80100b34:	e8 a2 41 00 00       	call   80104cdb <initlock>
80100b39:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b3c:	c7 05 4c 4a 11 80 9e 	movl   $0x80100a9e,0x80114a4c
80100b43:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b46:	c7 05 48 4a 11 80 90 	movl   $0x80100990,0x80114a48
80100b4d:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b50:	c7 45 f4 da a5 10 80 	movl   $0x8010a5da,-0xc(%ebp)
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
80100b7c:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b83:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b86:	83 ec 08             	sub    $0x8,%esp
80100b89:	6a 00                	push   $0x0
80100b8b:	6a 01                	push   $0x1
80100b8d:	e8 8e 1f 00 00       	call   80102b20 <ioapicenable>
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
80100ba1:	e8 7c 33 00 00       	call   80103f22 <myproc>
80100ba6:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba9:	e8 80 29 00 00       	call   8010352e <begin_op>

  if((ip = namei(path)) == 0){
80100bae:	83 ec 0c             	sub    $0xc,%esp
80100bb1:	ff 75 08             	push   0x8(%ebp)
80100bb4:	e8 72 19 00 00       	call   8010252b <namei>
80100bb9:	83 c4 10             	add    $0x10,%esp
80100bbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc3:	75 1f                	jne    80100be4 <exec+0x4c>
    end_op();
80100bc5:	e8 f0 29 00 00       	call   801035ba <end_op>
    cprintf("exec: fail\n");
80100bca:	83 ec 0c             	sub    $0xc,%esp
80100bcd:	68 f0 a5 10 80       	push   $0x8010a5f0
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
80100c29:	e8 e8 6c 00 00       	call   80107916 <setupkvm>
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
80100ccf:	e8 3b 70 00 00       	call   80107d0f <allocuvm>
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
80100d15:	e8 28 6f 00 00       	call   80107c42 <loaduvm>
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
80100d56:	e8 5f 28 00 00       	call   801035ba <end_op>
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
80100d7b:	e8 8f 6f 00 00       	call   80107d0f <allocuvm>
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
80100dc9:	e8 f3 43 00 00       	call   801051c1 <strlen>
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
80100df6:	e8 c6 43 00 00       	call   801051c1 <strlen>
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
80100e1c:	e8 da 72 00 00       	call   801080fb <copyout>
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
80100eb8:	e8 3e 72 00 00       	call   801080fb <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	79 15                	jns    80100ed9 <exec+0x341>
    cprintf("[exec] copyout of ustack failed\n");
80100ec4:	83 ec 0c             	sub    $0xc,%esp
80100ec7:	68 fc a5 10 80       	push   $0x8010a5fc
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
80100f17:	e8 5a 42 00 00       	call   80105176 <safestrcpy>
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
80100f5a:	e8 d4 6a 00 00       	call   80107a33 <switchuvm>
80100f5f:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f62:	83 ec 0c             	sub    $0xc,%esp
80100f65:	ff 75 cc             	push   -0x34(%ebp)
80100f68:	e8 6b 6f 00 00       	call   80107ed8 <freevm>
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
80100fa5:	e8 2e 6f 00 00       	call   80107ed8 <freevm>
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
80100fc1:	e8 f4 25 00 00       	call   801035ba <end_op>
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
80100fd6:	68 1d a6 10 80       	push   $0x8010a61d
80100fdb:	68 a0 4a 11 80       	push   $0x80114aa0
80100fe0:	e8 f6 3c 00 00       	call   80104cdb <initlock>
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
80100ff4:	68 a0 4a 11 80       	push   $0x80114aa0
80100ff9:	e8 ff 3c 00 00       	call   80104cfd <acquire>
80100ffe:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101001:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
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
80101021:	68 a0 4a 11 80       	push   $0x80114aa0
80101026:	e8 40 3d 00 00       	call   80104d6b <release>
8010102b:	83 c4 10             	add    $0x10,%esp
      return f;
8010102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101031:	eb 23                	jmp    80101056 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101033:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101037:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010103c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103f:	72 c9                	jb     8010100a <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	68 a0 4a 11 80       	push   $0x80114aa0
80101049:	e8 1d 3d 00 00       	call   80104d6b <release>
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
80101061:	68 a0 4a 11 80       	push   $0x80114aa0
80101066:	e8 92 3c 00 00       	call   80104cfd <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 24 a6 10 80       	push   $0x8010a624
80101080:	e8 3c f5 ff ff       	call   801005c1 <panic>
  f->ref++;
80101085:	8b 45 08             	mov    0x8(%ebp),%eax
80101088:	8b 40 04             	mov    0x4(%eax),%eax
8010108b:	8d 50 01             	lea    0x1(%eax),%edx
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101094:	83 ec 0c             	sub    $0xc,%esp
80101097:	68 a0 4a 11 80       	push   $0x80114aa0
8010109c:	e8 ca 3c 00 00       	call   80104d6b <release>
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
801010b2:	68 a0 4a 11 80       	push   $0x80114aa0
801010b7:	e8 41 3c 00 00       	call   80104cfd <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 2c a6 10 80       	push   $0x8010a62c
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
801010f2:	68 a0 4a 11 80       	push   $0x80114aa0
801010f7:	e8 6f 3c 00 00       	call   80104d6b <release>
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
80101140:	68 a0 4a 11 80       	push   $0x80114aa0
80101145:	e8 21 3c 00 00       	call   80104d6b <release>
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
80101164:	e8 48 2a 00 00       	call   80103bb1 <pipeclose>
80101169:	83 c4 10             	add    $0x10,%esp
8010116c:	eb 21                	jmp    8010118f <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101171:	83 f8 02             	cmp    $0x2,%eax
80101174:	75 19                	jne    8010118f <fileclose+0xe6>
    begin_op();
80101176:	e8 b3 23 00 00       	call   8010352e <begin_op>
    iput(ff.ip);
8010117b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117e:	83 ec 0c             	sub    $0xc,%esp
80101181:	50                   	push   %eax
80101182:	e8 d2 09 00 00       	call   80101b59 <iput>
80101187:	83 c4 10             	add    $0x10,%esp
    end_op();
8010118a:	e8 2b 24 00 00       	call   801035ba <end_op>
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
8010121d:	e8 3c 2b 00 00       	call   80103d5e <piperead>
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
80101294:	68 36 a6 10 80       	push   $0x8010a636
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
801012d6:	e8 81 29 00 00       	call   80103c5c <pipewrite>
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
8010131b:	e8 0e 22 00 00       	call   8010352e <begin_op>
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
80101381:	e8 34 22 00 00       	call   801035ba <end_op>

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
80101397:	68 3f a6 10 80       	push   $0x8010a63f
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
801013cd:	68 4f a6 10 80       	push   $0x8010a64f
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
80101405:	e8 28 3c 00 00       	call   80105032 <memmove>
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
8010144b:	e8 23 3b 00 00       	call   80104f73 <memset>
80101450:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 09 23 00 00       	call   80103767 <log_write>
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
8010149e:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101525:	e8 3d 22 00 00       	call   80103767 <log_write>
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
80101574:	a1 40 54 11 80       	mov    0x80115440,%eax
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
80101596:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159f:	39 c2                	cmp    %eax,%edx
801015a1:	0f 87 e4 fe ff ff    	ja     8010148b <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a7:	83 ec 0c             	sub    $0xc,%esp
801015aa:	68 5c a6 10 80       	push   $0x8010a65c
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
801015bf:	68 40 54 11 80       	push   $0x80115440
801015c4:	ff 75 08             	push   0x8(%ebp)
801015c7:	e8 10 fe ff ff       	call   801013dc <readsb>
801015cc:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d2:	c1 e8 0c             	shr    $0xc,%eax
801015d5:	89 c2                	mov    %eax,%edx
801015d7:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101635:	68 72 a6 10 80       	push   $0x8010a672
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
8010166d:	e8 f5 20 00 00       	call   80103767 <log_write>
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
80101699:	68 85 a6 10 80       	push   $0x8010a685
8010169e:	68 60 54 11 80       	push   $0x80115460
801016a3:	e8 33 36 00 00       	call   80104cdb <initlock>
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
801016c4:	05 60 54 11 80       	add    $0x80115460,%eax
801016c9:	83 c0 10             	add    $0x10,%eax
801016cc:	83 ec 08             	sub    $0x8,%esp
801016cf:	68 8c a6 10 80       	push   $0x8010a68c
801016d4:	50                   	push   %eax
801016d5:	e8 a4 34 00 00       	call   80104b7e <initsleeplock>
801016da:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016dd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016e1:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e5:	7e cd                	jle    801016b4 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e7:	83 ec 08             	sub    $0x8,%esp
801016ea:	68 40 54 11 80       	push   $0x80115440
801016ef:	ff 75 08             	push   0x8(%ebp)
801016f2:	e8 e5 fc ff ff       	call   801013dc <readsb>
801016f7:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016fa:	a1 58 54 11 80       	mov    0x80115458,%eax
801016ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101702:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
80101708:	8b 35 50 54 11 80    	mov    0x80115450,%esi
8010170e:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101714:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010171a:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101720:	a1 40 54 11 80       	mov    0x80115440,%eax
80101725:	ff 75 d4             	push   -0x2c(%ebp)
80101728:	57                   	push   %edi
80101729:	56                   	push   %esi
8010172a:	53                   	push   %ebx
8010172b:	51                   	push   %ecx
8010172c:	52                   	push   %edx
8010172d:	50                   	push   %eax
8010172e:	68 94 a6 10 80       	push   $0x8010a694
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
80101765:	a1 54 54 11 80       	mov    0x80115454,%eax
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
801017a7:	e8 c7 37 00 00       	call   80104f73 <memset>
801017ac:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b2:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b6:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 a3 1f 00 00       	call   80103767 <log_write>
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
801017fb:	8b 15 48 54 11 80    	mov    0x80115448,%edx
80101801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101804:	39 c2                	cmp    %eax,%edx
80101806:	0f 87 51 ff ff ff    	ja     8010175d <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010180c:	83 ec 0c             	sub    $0xc,%esp
8010180f:	68 e7 a6 10 80       	push   $0x8010a6e7
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
8010182c:	a1 54 54 11 80       	mov    0x80115454,%eax
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
801018b5:	e8 78 37 00 00       	call   80105032 <memmove>
801018ba:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 9f 1e 00 00       	call   80103767 <log_write>
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
801018e5:	68 60 54 11 80       	push   $0x80115460
801018ea:	e8 0e 34 00 00       	call   80104cfd <acquire>
801018ef:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f9:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
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
80101933:	68 60 54 11 80       	push   $0x80115460
80101938:	e8 2e 34 00 00       	call   80104d6b <release>
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
80101962:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80101969:	72 97                	jb     80101902 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010196b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010196f:	75 0d                	jne    8010197e <iget+0xa2>
    panic("iget: no inodes");
80101971:	83 ec 0c             	sub    $0xc,%esp
80101974:	68 f9 a6 10 80       	push   $0x8010a6f9
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
801019ac:	68 60 54 11 80       	push   $0x80115460
801019b1:	e8 b5 33 00 00       	call   80104d6b <release>
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
801019c7:	68 60 54 11 80       	push   $0x80115460
801019cc:	e8 2c 33 00 00       	call   80104cfd <acquire>
801019d1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019d4:	8b 45 08             	mov    0x8(%ebp),%eax
801019d7:	8b 40 08             	mov    0x8(%eax),%eax
801019da:	8d 50 01             	lea    0x1(%eax),%edx
801019dd:	8b 45 08             	mov    0x8(%ebp),%eax
801019e0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019e3:	83 ec 0c             	sub    $0xc,%esp
801019e6:	68 60 54 11 80       	push   $0x80115460
801019eb:	e8 7b 33 00 00       	call   80104d6b <release>
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
80101a11:	68 09 a7 10 80       	push   $0x8010a709
80101a16:	e8 a6 eb ff ff       	call   801005c1 <panic>

  acquiresleep(&ip->lock);
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	83 c0 0c             	add    $0xc,%eax
80101a21:	83 ec 0c             	sub    $0xc,%esp
80101a24:	50                   	push   %eax
80101a25:	e8 90 31 00 00       	call   80104bba <acquiresleep>
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
80101a46:	a1 54 54 11 80       	mov    0x80115454,%eax
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
80101acf:	e8 5e 35 00 00       	call   80105032 <memmove>
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
80101afe:	68 0f a7 10 80       	push   $0x8010a70f
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
80101b21:	e8 46 31 00 00       	call   80104c6c <holdingsleep>
80101b26:	83 c4 10             	add    $0x10,%esp
80101b29:	85 c0                	test   %eax,%eax
80101b2b:	74 0a                	je     80101b37 <iunlock+0x2c>
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 40 08             	mov    0x8(%eax),%eax
80101b33:	85 c0                	test   %eax,%eax
80101b35:	7f 0d                	jg     80101b44 <iunlock+0x39>
    panic("iunlock");
80101b37:	83 ec 0c             	sub    $0xc,%esp
80101b3a:	68 1e a7 10 80       	push   $0x8010a71e
80101b3f:	e8 7d ea ff ff       	call   801005c1 <panic>

  releasesleep(&ip->lock);
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	83 c0 0c             	add    $0xc,%eax
80101b4a:	83 ec 0c             	sub    $0xc,%esp
80101b4d:	50                   	push   %eax
80101b4e:	e8 cb 30 00 00       	call   80104c1e <releasesleep>
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
80101b69:	e8 4c 30 00 00       	call   80104bba <acquiresleep>
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
80101b8a:	68 60 54 11 80       	push   $0x80115460
80101b8f:	e8 69 31 00 00       	call   80104cfd <acquire>
80101b94:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	8b 40 08             	mov    0x8(%eax),%eax
80101b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	68 60 54 11 80       	push   $0x80115460
80101ba8:	e8 be 31 00 00       	call   80104d6b <release>
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
80101bef:	e8 2a 30 00 00       	call   80104c1e <releasesleep>
80101bf4:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf7:	83 ec 0c             	sub    $0xc,%esp
80101bfa:	68 60 54 11 80       	push   $0x80115460
80101bff:	e8 f9 30 00 00       	call   80104cfd <acquire>
80101c04:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	8b 40 08             	mov    0x8(%eax),%eax
80101c0d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c16:	83 ec 0c             	sub    $0xc,%esp
80101c19:	68 60 54 11 80       	push   $0x80115460
80101c1e:	e8 48 31 00 00       	call   80104d6b <release>
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
80101d44:	e8 1e 1a 00 00       	call   80103767 <log_write>
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
80101d62:	68 26 a7 10 80       	push   $0x8010a726
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
80101f18:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f1f:	85 c0                	test   %eax,%eax
80101f21:	75 0a                	jne    80101f2d <readi+0x49>
      return -1;
80101f23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f28:	e9 0a 01 00 00       	jmp    80102037 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f34:	98                   	cwtl   
80101f35:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
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
80102000:	e8 2d 30 00 00       	call   80105032 <memmove>
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
8010206d:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102074:	85 c0                	test   %eax,%eax
80102076:	75 0a                	jne    80102082 <writei+0x49>
      return -1;
80102078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010207d:	e9 3b 01 00 00       	jmp    801021bd <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102089:	98                   	cwtl   
8010208a:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
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
80102150:	e8 dd 2e 00 00       	call   80105032 <memmove>
80102155:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 04 16 00 00       	call   80103767 <log_write>
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
801021d0:	e8 f3 2e 00 00       	call   801050c8 <strncmp>
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
801021f0:	68 39 a7 10 80       	push   $0x8010a739
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
8010221f:	68 4b a7 10 80       	push   $0x8010a74b
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
801022f4:	68 5a a7 10 80       	push   $0x8010a75a
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
8010232f:	e8 ea 2d 00 00       	call   8010511e <strncpy>
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
8010235b:	68 67 a7 10 80       	push   $0x8010a767
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
801023cd:	e8 60 2c 00 00       	call   80105032 <memmove>
801023d2:	83 c4 10             	add    $0x10,%esp
801023d5:	eb 26                	jmp    801023fd <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023da:	83 ec 04             	sub    $0x4,%esp
801023dd:	50                   	push   %eax
801023de:	ff 75 f4             	push   -0xc(%ebp)
801023e1:	ff 75 0c             	push   0xc(%ebp)
801023e4:	e8 49 2c 00 00       	call   80105032 <memmove>
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
80102433:	e8 ea 1a 00 00       	call   80103f22 <myproc>
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

80102562 <inb>:
{
80102562:	55                   	push   %ebp
80102563:	89 e5                	mov    %esp,%ebp
80102565:	83 ec 14             	sub    $0x14,%esp
80102568:	8b 45 08             	mov    0x8(%ebp),%eax
8010256b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102573:	89 c2                	mov    %eax,%edx
80102575:	ec                   	in     (%dx),%al
80102576:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102579:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257d:	c9                   	leave  
8010257e:	c3                   	ret    

8010257f <insl>:
{
8010257f:	55                   	push   %ebp
80102580:	89 e5                	mov    %esp,%ebp
80102582:	57                   	push   %edi
80102583:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102584:	8b 55 08             	mov    0x8(%ebp),%edx
80102587:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010258a:	8b 45 10             	mov    0x10(%ebp),%eax
8010258d:	89 cb                	mov    %ecx,%ebx
8010258f:	89 df                	mov    %ebx,%edi
80102591:	89 c1                	mov    %eax,%ecx
80102593:	fc                   	cld    
80102594:	f3 6d                	rep insl (%dx),%es:(%edi)
80102596:	89 c8                	mov    %ecx,%eax
80102598:	89 fb                	mov    %edi,%ebx
8010259a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259d:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025a0:	90                   	nop
801025a1:	5b                   	pop    %ebx
801025a2:	5f                   	pop    %edi
801025a3:	5d                   	pop    %ebp
801025a4:	c3                   	ret    

801025a5 <outb>:
{
801025a5:	55                   	push   %ebp
801025a6:	89 e5                	mov    %esp,%ebp
801025a8:	83 ec 08             	sub    $0x8,%esp
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801025b1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025b5:	89 d0                	mov    %edx,%eax
801025b7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025be:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025c2:	ee                   	out    %al,(%dx)
}
801025c3:	90                   	nop
801025c4:	c9                   	leave  
801025c5:	c3                   	ret    

801025c6 <outsl>:
{
801025c6:	55                   	push   %ebp
801025c7:	89 e5                	mov    %esp,%ebp
801025c9:	56                   	push   %esi
801025ca:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025cb:	8b 55 08             	mov    0x8(%ebp),%edx
801025ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d1:	8b 45 10             	mov    0x10(%ebp),%eax
801025d4:	89 cb                	mov    %ecx,%ebx
801025d6:	89 de                	mov    %ebx,%esi
801025d8:	89 c1                	mov    %eax,%ecx
801025da:	fc                   	cld    
801025db:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025dd:	89 c8                	mov    %ecx,%eax
801025df:	89 f3                	mov    %esi,%ebx
801025e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e4:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025e7:	90                   	nop
801025e8:	5b                   	pop    %ebx
801025e9:	5e                   	pop    %esi
801025ea:	5d                   	pop    %ebp
801025eb:	c3                   	ret    

801025ec <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025ec:	55                   	push   %ebp
801025ed:	89 e5                	mov    %esp,%ebp
801025ef:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025f2:	90                   	nop
801025f3:	68 f7 01 00 00       	push   $0x1f7
801025f8:	e8 65 ff ff ff       	call   80102562 <inb>
801025fd:	83 c4 04             	add    $0x4,%esp
80102600:	0f b6 c0             	movzbl %al,%eax
80102603:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102606:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102609:	25 c0 00 00 00       	and    $0xc0,%eax
8010260e:	83 f8 40             	cmp    $0x40,%eax
80102611:	75 e0                	jne    801025f3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102613:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102617:	74 11                	je     8010262a <idewait+0x3e>
80102619:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261c:	83 e0 21             	and    $0x21,%eax
8010261f:	85 c0                	test   %eax,%eax
80102621:	74 07                	je     8010262a <idewait+0x3e>
    return -1;
80102623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102628:	eb 05                	jmp    8010262f <idewait+0x43>
  return 0;
8010262a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262f:	c9                   	leave  
80102630:	c3                   	ret    

80102631 <ideinit>:

void
ideinit(void)
{
80102631:	55                   	push   %ebp
80102632:	89 e5                	mov    %esp,%ebp
80102634:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102637:	83 ec 08             	sub    $0x8,%esp
8010263a:	68 6f a7 10 80       	push   $0x8010a76f
8010263f:	68 c0 70 11 80       	push   $0x801170c0
80102644:	e8 92 26 00 00       	call   80104cdb <initlock>
80102649:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010264c:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80102651:	83 e8 01             	sub    $0x1,%eax
80102654:	83 ec 08             	sub    $0x8,%esp
80102657:	50                   	push   %eax
80102658:	6a 0e                	push   $0xe
8010265a:	e8 c1 04 00 00       	call   80102b20 <ioapicenable>
8010265f:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102662:	83 ec 0c             	sub    $0xc,%esp
80102665:	6a 00                	push   $0x0
80102667:	e8 80 ff ff ff       	call   801025ec <idewait>
8010266c:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010266f:	83 ec 08             	sub    $0x8,%esp
80102672:	68 f0 00 00 00       	push   $0xf0
80102677:	68 f6 01 00 00       	push   $0x1f6
8010267c:	e8 24 ff ff ff       	call   801025a5 <outb>
80102681:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010268b:	eb 24                	jmp    801026b1 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010268d:	83 ec 0c             	sub    $0xc,%esp
80102690:	68 f7 01 00 00       	push   $0x1f7
80102695:	e8 c8 fe ff ff       	call   80102562 <inb>
8010269a:	83 c4 10             	add    $0x10,%esp
8010269d:	84 c0                	test   %al,%al
8010269f:	74 0c                	je     801026ad <ideinit+0x7c>
      havedisk1 = 1;
801026a1:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
801026a8:	00 00 00 
      break;
801026ab:	eb 0d                	jmp    801026ba <ideinit+0x89>
  for(i=0; i<1000; i++){
801026ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026b8:	7e d3                	jle    8010268d <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ba:	83 ec 08             	sub    $0x8,%esp
801026bd:	68 e0 00 00 00       	push   $0xe0
801026c2:	68 f6 01 00 00       	push   $0x1f6
801026c7:	e8 d9 fe ff ff       	call   801025a5 <outb>
801026cc:	83 c4 10             	add    $0x10,%esp
}
801026cf:	90                   	nop
801026d0:	c9                   	leave  
801026d1:	c3                   	ret    

801026d2 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026d2:	55                   	push   %ebp
801026d3:	89 e5                	mov    %esp,%ebp
801026d5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026dc:	75 0d                	jne    801026eb <idestart+0x19>
    panic("idestart");
801026de:	83 ec 0c             	sub    $0xc,%esp
801026e1:	68 73 a7 10 80       	push   $0x8010a773
801026e6:	e8 d6 de ff ff       	call   801005c1 <panic>
  if(b->blockno >= FSSIZE)
801026eb:	8b 45 08             	mov    0x8(%ebp),%eax
801026ee:	8b 40 08             	mov    0x8(%eax),%eax
801026f1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026f6:	76 0d                	jbe    80102705 <idestart+0x33>
    panic("incorrect blockno");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 7c a7 10 80       	push   $0x8010a77c
80102700:	e8 bc de ff ff       	call   801005c1 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102705:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	8b 50 08             	mov    0x8(%eax),%edx
80102712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102715:	0f af c2             	imul   %edx,%eax
80102718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010271b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010271f:	75 07                	jne    80102728 <idestart+0x56>
80102721:	b8 20 00 00 00       	mov    $0x20,%eax
80102726:	eb 05                	jmp    8010272d <idestart+0x5b>
80102728:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010272d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102730:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102734:	75 07                	jne    8010273d <idestart+0x6b>
80102736:	b8 30 00 00 00       	mov    $0x30,%eax
8010273b:	eb 05                	jmp    80102742 <idestart+0x70>
8010273d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102742:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102745:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102749:	7e 0d                	jle    80102758 <idestart+0x86>
8010274b:	83 ec 0c             	sub    $0xc,%esp
8010274e:	68 73 a7 10 80       	push   $0x8010a773
80102753:	e8 69 de ff ff       	call   801005c1 <panic>

  idewait(0);
80102758:	83 ec 0c             	sub    $0xc,%esp
8010275b:	6a 00                	push   $0x0
8010275d:	e8 8a fe ff ff       	call   801025ec <idewait>
80102762:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102765:	83 ec 08             	sub    $0x8,%esp
80102768:	6a 00                	push   $0x0
8010276a:	68 f6 03 00 00       	push   $0x3f6
8010276f:	e8 31 fe ff ff       	call   801025a5 <outb>
80102774:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	0f b6 c0             	movzbl %al,%eax
8010277d:	83 ec 08             	sub    $0x8,%esp
80102780:	50                   	push   %eax
80102781:	68 f2 01 00 00       	push   $0x1f2
80102786:	e8 1a fe ff ff       	call   801025a5 <outb>
8010278b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010278e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102791:	0f b6 c0             	movzbl %al,%eax
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	50                   	push   %eax
80102798:	68 f3 01 00 00       	push   $0x1f3
8010279d:	e8 03 fe ff ff       	call   801025a5 <outb>
801027a2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a8:	c1 f8 08             	sar    $0x8,%eax
801027ab:	0f b6 c0             	movzbl %al,%eax
801027ae:	83 ec 08             	sub    $0x8,%esp
801027b1:	50                   	push   %eax
801027b2:	68 f4 01 00 00       	push   $0x1f4
801027b7:	e8 e9 fd ff ff       	call   801025a5 <outb>
801027bc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c2:	c1 f8 10             	sar    $0x10,%eax
801027c5:	0f b6 c0             	movzbl %al,%eax
801027c8:	83 ec 08             	sub    $0x8,%esp
801027cb:	50                   	push   %eax
801027cc:	68 f5 01 00 00       	push   $0x1f5
801027d1:	e8 cf fd ff ff       	call   801025a5 <outb>
801027d6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027d9:	8b 45 08             	mov    0x8(%ebp),%eax
801027dc:	8b 40 04             	mov    0x4(%eax),%eax
801027df:	c1 e0 04             	shl    $0x4,%eax
801027e2:	83 e0 10             	and    $0x10,%eax
801027e5:	89 c2                	mov    %eax,%edx
801027e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ea:	c1 f8 18             	sar    $0x18,%eax
801027ed:	83 e0 0f             	and    $0xf,%eax
801027f0:	09 d0                	or     %edx,%eax
801027f2:	83 c8 e0             	or     $0xffffffe0,%eax
801027f5:	0f b6 c0             	movzbl %al,%eax
801027f8:	83 ec 08             	sub    $0x8,%esp
801027fb:	50                   	push   %eax
801027fc:	68 f6 01 00 00       	push   $0x1f6
80102801:	e8 9f fd ff ff       	call   801025a5 <outb>
80102806:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102809:	8b 45 08             	mov    0x8(%ebp),%eax
8010280c:	8b 00                	mov    (%eax),%eax
8010280e:	83 e0 04             	and    $0x4,%eax
80102811:	85 c0                	test   %eax,%eax
80102813:	74 35                	je     8010284a <idestart+0x178>
    outb(0x1f7, write_cmd);
80102815:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102818:	0f b6 c0             	movzbl %al,%eax
8010281b:	83 ec 08             	sub    $0x8,%esp
8010281e:	50                   	push   %eax
8010281f:	68 f7 01 00 00       	push   $0x1f7
80102824:	e8 7c fd ff ff       	call   801025a5 <outb>
80102829:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010282c:	8b 45 08             	mov    0x8(%ebp),%eax
8010282f:	83 c0 5c             	add    $0x5c,%eax
80102832:	83 ec 04             	sub    $0x4,%esp
80102835:	68 80 00 00 00       	push   $0x80
8010283a:	50                   	push   %eax
8010283b:	68 f0 01 00 00       	push   $0x1f0
80102840:	e8 81 fd ff ff       	call   801025c6 <outsl>
80102845:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102848:	eb 17                	jmp    80102861 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010284a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010284d:	0f b6 c0             	movzbl %al,%eax
80102850:	83 ec 08             	sub    $0x8,%esp
80102853:	50                   	push   %eax
80102854:	68 f7 01 00 00       	push   $0x1f7
80102859:	e8 47 fd ff ff       	call   801025a5 <outb>
8010285e:	83 c4 10             	add    $0x10,%esp
}
80102861:	90                   	nop
80102862:	c9                   	leave  
80102863:	c3                   	ret    

80102864 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102864:	55                   	push   %ebp
80102865:	89 e5                	mov    %esp,%ebp
80102867:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010286a:	83 ec 0c             	sub    $0xc,%esp
8010286d:	68 c0 70 11 80       	push   $0x801170c0
80102872:	e8 86 24 00 00       	call   80104cfd <acquire>
80102877:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010287a:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010287f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102882:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102886:	75 15                	jne    8010289d <ideintr+0x39>
    release(&idelock);
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	68 c0 70 11 80       	push   $0x801170c0
80102890:	e8 d6 24 00 00       	call   80104d6b <release>
80102895:	83 c4 10             	add    $0x10,%esp
    return;
80102898:	e9 9a 00 00 00       	jmp    80102937 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010289d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a0:	8b 40 58             	mov    0x58(%eax),%eax
801028a3:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ab:	8b 00                	mov    (%eax),%eax
801028ad:	83 e0 04             	and    $0x4,%eax
801028b0:	85 c0                	test   %eax,%eax
801028b2:	75 2d                	jne    801028e1 <ideintr+0x7d>
801028b4:	83 ec 0c             	sub    $0xc,%esp
801028b7:	6a 01                	push   $0x1
801028b9:	e8 2e fd ff ff       	call   801025ec <idewait>
801028be:	83 c4 10             	add    $0x10,%esp
801028c1:	85 c0                	test   %eax,%eax
801028c3:	78 1c                	js     801028e1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c8:	83 c0 5c             	add    $0x5c,%eax
801028cb:	83 ec 04             	sub    $0x4,%esp
801028ce:	68 80 00 00 00       	push   $0x80
801028d3:	50                   	push   %eax
801028d4:	68 f0 01 00 00       	push   $0x1f0
801028d9:	e8 a1 fc ff ff       	call   8010257f <insl>
801028de:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e4:	8b 00                	mov    (%eax),%eax
801028e6:	83 c8 02             	or     $0x2,%eax
801028e9:	89 c2                	mov    %eax,%edx
801028eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ee:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f3:	8b 00                	mov    (%eax),%eax
801028f5:	83 e0 fb             	and    $0xfffffffb,%eax
801028f8:	89 c2                	mov    %eax,%edx
801028fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fd:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028ff:	83 ec 0c             	sub    $0xc,%esp
80102902:	ff 75 f4             	push   -0xc(%ebp)
80102905:	e8 a8 1f 00 00       	call   801048b2 <wakeup>
8010290a:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010290d:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102912:	85 c0                	test   %eax,%eax
80102914:	74 11                	je     80102927 <ideintr+0xc3>
    idestart(idequeue);
80102916:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010291b:	83 ec 0c             	sub    $0xc,%esp
8010291e:	50                   	push   %eax
8010291f:	e8 ae fd ff ff       	call   801026d2 <idestart>
80102924:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 c0 70 11 80       	push   $0x801170c0
8010292f:	e8 37 24 00 00       	call   80104d6b <release>
80102934:	83 c4 10             	add    $0x10,%esp
}
80102937:	c9                   	leave  
80102938:	c3                   	ret    

80102939 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102939:	55                   	push   %ebp
8010293a:	89 e5                	mov    %esp,%ebp
8010293c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
8010293f:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102945:	8b 45 08             	mov    0x8(%ebp),%eax
80102948:	8b 40 04             	mov    0x4(%eax),%eax
8010294b:	83 ec 04             	sub    $0x4,%esp
8010294e:	52                   	push   %edx
8010294f:	50                   	push   %eax
80102950:	68 8e a7 10 80       	push   $0x8010a78e
80102955:	e8 9a da ff ff       	call   801003f4 <cprintf>
8010295a:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010295d:	8b 45 08             	mov    0x8(%ebp),%eax
80102960:	83 c0 0c             	add    $0xc,%eax
80102963:	83 ec 0c             	sub    $0xc,%esp
80102966:	50                   	push   %eax
80102967:	e8 00 23 00 00       	call   80104c6c <holdingsleep>
8010296c:	83 c4 10             	add    $0x10,%esp
8010296f:	85 c0                	test   %eax,%eax
80102971:	75 0d                	jne    80102980 <iderw+0x47>
    panic("iderw: buf not locked");
80102973:	83 ec 0c             	sub    $0xc,%esp
80102976:	68 a8 a7 10 80       	push   $0x8010a7a8
8010297b:	e8 41 dc ff ff       	call   801005c1 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	8b 00                	mov    (%eax),%eax
80102985:	83 e0 06             	and    $0x6,%eax
80102988:	83 f8 02             	cmp    $0x2,%eax
8010298b:	75 0d                	jne    8010299a <iderw+0x61>
    panic("iderw: nothing to do");
8010298d:	83 ec 0c             	sub    $0xc,%esp
80102990:	68 be a7 10 80       	push   $0x8010a7be
80102995:	e8 27 dc ff ff       	call   801005c1 <panic>
  if(b->dev != 0 && !havedisk1)
8010299a:	8b 45 08             	mov    0x8(%ebp),%eax
8010299d:	8b 40 04             	mov    0x4(%eax),%eax
801029a0:	85 c0                	test   %eax,%eax
801029a2:	74 16                	je     801029ba <iderw+0x81>
801029a4:	a1 f8 70 11 80       	mov    0x801170f8,%eax
801029a9:	85 c0                	test   %eax,%eax
801029ab:	75 0d                	jne    801029ba <iderw+0x81>
    panic("iderw: ide disk 1 not present");
801029ad:	83 ec 0c             	sub    $0xc,%esp
801029b0:	68 d3 a7 10 80       	push   $0x8010a7d3
801029b5:	e8 07 dc ff ff       	call   801005c1 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ba:	83 ec 0c             	sub    $0xc,%esp
801029bd:	68 c0 70 11 80       	push   $0x801170c0
801029c2:	e8 36 23 00 00       	call   80104cfd <acquire>
801029c7:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029d4:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029db:	eb 0b                	jmp    801029e8 <iderw+0xaf>
801029dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e0:	8b 00                	mov    (%eax),%eax
801029e2:	83 c0 58             	add    $0x58,%eax
801029e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029eb:	8b 00                	mov    (%eax),%eax
801029ed:	85 c0                	test   %eax,%eax
801029ef:	75 ec                	jne    801029dd <iderw+0xa4>
    ;
  *pp = b;
801029f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f4:	8b 55 08             	mov    0x8(%ebp),%edx
801029f7:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029f9:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029fe:	39 45 08             	cmp    %eax,0x8(%ebp)
80102a01:	75 23                	jne    80102a26 <iderw+0xed>
    idestart(b);
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	ff 75 08             	push   0x8(%ebp)
80102a09:	e8 c4 fc ff ff       	call   801026d2 <idestart>
80102a0e:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a11:	eb 13                	jmp    80102a26 <iderw+0xed>
    sleep(b, &idelock);
80102a13:	83 ec 08             	sub    $0x8,%esp
80102a16:	68 c0 70 11 80       	push   $0x801170c0
80102a1b:	ff 75 08             	push   0x8(%ebp)
80102a1e:	e8 a8 1d 00 00       	call   801047cb <sleep>
80102a23:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a26:	8b 45 08             	mov    0x8(%ebp),%eax
80102a29:	8b 00                	mov    (%eax),%eax
80102a2b:	83 e0 06             	and    $0x6,%eax
80102a2e:	83 f8 02             	cmp    $0x2,%eax
80102a31:	75 e0                	jne    80102a13 <iderw+0xda>
  }


  release(&idelock);
80102a33:	83 ec 0c             	sub    $0xc,%esp
80102a36:	68 c0 70 11 80       	push   $0x801170c0
80102a3b:	e8 2b 23 00 00       	call   80104d6b <release>
80102a40:	83 c4 10             	add    $0x10,%esp
}
80102a43:	90                   	nop
80102a44:	c9                   	leave  
80102a45:	c3                   	ret    

80102a46 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a46:	55                   	push   %ebp
80102a47:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a49:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4e:	8b 55 08             	mov    0x8(%ebp),%edx
80102a51:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a53:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a58:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a5b:	5d                   	pop    %ebp
80102a5c:	c3                   	ret    

80102a5d <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a5d:	55                   	push   %ebp
80102a5e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a60:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a65:	8b 55 08             	mov    0x8(%ebp),%edx
80102a68:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a6a:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a72:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a75:	90                   	nop
80102a76:	5d                   	pop    %ebp
80102a77:	c3                   	ret    

80102a78 <ioapicinit>:

void
ioapicinit(void)
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a7e:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a85:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a88:	6a 01                	push   $0x1
80102a8a:	e8 b7 ff ff ff       	call   80102a46 <ioapicread>
80102a8f:	83 c4 04             	add    $0x4,%esp
80102a92:	c1 e8 10             	shr    $0x10,%eax
80102a95:	25 ff 00 00 00       	and    $0xff,%eax
80102a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a9d:	6a 00                	push   $0x0
80102a9f:	e8 a2 ff ff ff       	call   80102a46 <ioapicread>
80102aa4:	83 c4 04             	add    $0x4,%esp
80102aa7:	c1 e8 18             	shr    $0x18,%eax
80102aaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aad:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
80102ab4:	0f b6 c0             	movzbl %al,%eax
80102ab7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aba:	74 10                	je     80102acc <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102abc:	83 ec 0c             	sub    $0xc,%esp
80102abf:	68 f4 a7 10 80       	push   $0x8010a7f4
80102ac4:	e8 2b d9 ff ff       	call   801003f4 <cprintf>
80102ac9:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ad3:	eb 3f                	jmp    80102b14 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad8:	83 c0 20             	add    $0x20,%eax
80102adb:	0d 00 00 01 00       	or     $0x10000,%eax
80102ae0:	89 c2                	mov    %eax,%edx
80102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae5:	83 c0 08             	add    $0x8,%eax
80102ae8:	01 c0                	add    %eax,%eax
80102aea:	83 ec 08             	sub    $0x8,%esp
80102aed:	52                   	push   %edx
80102aee:	50                   	push   %eax
80102aef:	e8 69 ff ff ff       	call   80102a5d <ioapicwrite>
80102af4:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afa:	83 c0 08             	add    $0x8,%eax
80102afd:	01 c0                	add    %eax,%eax
80102aff:	83 c0 01             	add    $0x1,%eax
80102b02:	83 ec 08             	sub    $0x8,%esp
80102b05:	6a 00                	push   $0x0
80102b07:	50                   	push   %eax
80102b08:	e8 50 ff ff ff       	call   80102a5d <ioapicwrite>
80102b0d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b17:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b1a:	7e b9                	jle    80102ad5 <ioapicinit+0x5d>
  }
}
80102b1c:	90                   	nop
80102b1d:	90                   	nop
80102b1e:	c9                   	leave  
80102b1f:	c3                   	ret    

80102b20 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b20:	55                   	push   %ebp
80102b21:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 20             	add    $0x20,%eax
80102b29:	89 c2                	mov    %eax,%edx
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	83 c0 08             	add    $0x8,%eax
80102b31:	01 c0                	add    %eax,%eax
80102b33:	52                   	push   %edx
80102b34:	50                   	push   %eax
80102b35:	e8 23 ff ff ff       	call   80102a5d <ioapicwrite>
80102b3a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b40:	c1 e0 18             	shl    $0x18,%eax
80102b43:	89 c2                	mov    %eax,%edx
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	83 c0 08             	add    $0x8,%eax
80102b4b:	01 c0                	add    %eax,%eax
80102b4d:	83 c0 01             	add    $0x1,%eax
80102b50:	52                   	push   %edx
80102b51:	50                   	push   %eax
80102b52:	e8 06 ff ff ff       	call   80102a5d <ioapicwrite>
80102b57:	83 c4 08             	add    $0x8,%esp
}
80102b5a:	90                   	nop
80102b5b:	c9                   	leave  
80102b5c:	c3                   	ret    

80102b5d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b5d:	55                   	push   %ebp
80102b5e:	89 e5                	mov    %esp,%ebp
80102b60:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b63:	83 ec 08             	sub    $0x8,%esp
80102b66:	68 26 a8 10 80       	push   $0x8010a826
80102b6b:	68 00 71 11 80       	push   $0x80117100
80102b70:	e8 66 21 00 00       	call   80104cdb <initlock>
80102b75:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b78:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b7f:	00 00 00 
  freerange(vstart, vend);
80102b82:	83 ec 08             	sub    $0x8,%esp
80102b85:	ff 75 0c             	push   0xc(%ebp)
80102b88:	ff 75 08             	push   0x8(%ebp)
80102b8b:	e8 2a 00 00 00       	call   80102bba <freerange>
80102b90:	83 c4 10             	add    $0x10,%esp
}
80102b93:	90                   	nop
80102b94:	c9                   	leave  
80102b95:	c3                   	ret    

80102b96 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b96:	55                   	push   %ebp
80102b97:	89 e5                	mov    %esp,%ebp
80102b99:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b9c:	83 ec 08             	sub    $0x8,%esp
80102b9f:	ff 75 0c             	push   0xc(%ebp)
80102ba2:	ff 75 08             	push   0x8(%ebp)
80102ba5:	e8 10 00 00 00       	call   80102bba <freerange>
80102baa:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bad:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102bb4:	00 00 00 
}
80102bb7:	90                   	nop
80102bb8:	c9                   	leave  
80102bb9:	c3                   	ret    

80102bba <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bba:	55                   	push   %ebp
80102bbb:	89 e5                	mov    %esp,%ebp
80102bbd:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc3:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd0:	eb 15                	jmp    80102be7 <freerange+0x2d>
    kfree(p);
80102bd2:	83 ec 0c             	sub    $0xc,%esp
80102bd5:	ff 75 f4             	push   -0xc(%ebp)
80102bd8:	e8 1b 00 00 00       	call   80102bf8 <kfree>
80102bdd:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102be0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bea:	05 00 10 00 00       	add    $0x1000,%eax
80102bef:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bf2:	73 de                	jae    80102bd2 <freerange+0x18>
}
80102bf4:	90                   	nop
80102bf5:	90                   	nop
80102bf6:	c9                   	leave  
80102bf7:	c3                   	ret    

80102bf8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bf8:	55                   	push   %ebp
80102bf9:	89 e5                	mov    %esp,%ebp
80102bfb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80102c01:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c06:	85 c0                	test   %eax,%eax
80102c08:	75 18                	jne    80102c22 <kfree+0x2a>
80102c0a:	81 7d 08 00 b0 11 80 	cmpl   $0x8011b000,0x8(%ebp)
80102c11:	72 0f                	jb     80102c22 <kfree+0x2a>
80102c13:	8b 45 08             	mov    0x8(%ebp),%eax
80102c16:	05 00 00 00 80       	add    $0x80000000,%eax
80102c1b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c20:	76 0d                	jbe    80102c2f <kfree+0x37>
    panic("kfree");
80102c22:	83 ec 0c             	sub    $0xc,%esp
80102c25:	68 2b a8 10 80       	push   $0x8010a82b
80102c2a:	e8 92 d9 ff ff       	call   801005c1 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c2f:	83 ec 04             	sub    $0x4,%esp
80102c32:	68 00 10 00 00       	push   $0x1000
80102c37:	6a 01                	push   $0x1
80102c39:	ff 75 08             	push   0x8(%ebp)
80102c3c:	e8 32 23 00 00       	call   80104f73 <memset>
80102c41:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c44:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c49:	85 c0                	test   %eax,%eax
80102c4b:	74 10                	je     80102c5d <kfree+0x65>
    acquire(&kmem.lock);
80102c4d:	83 ec 0c             	sub    $0xc,%esp
80102c50:	68 00 71 11 80       	push   $0x80117100
80102c55:	e8 a3 20 00 00       	call   80104cfd <acquire>
80102c5a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c63:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c71:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c76:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c7b:	85 c0                	test   %eax,%eax
80102c7d:	74 10                	je     80102c8f <kfree+0x97>
    release(&kmem.lock);
80102c7f:	83 ec 0c             	sub    $0xc,%esp
80102c82:	68 00 71 11 80       	push   $0x80117100
80102c87:	e8 df 20 00 00       	call   80104d6b <release>
80102c8c:	83 c4 10             	add    $0x10,%esp
}
80102c8f:	90                   	nop
80102c90:	c9                   	leave  
80102c91:	c3                   	ret    

80102c92 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c92:	55                   	push   %ebp
80102c93:	89 e5                	mov    %esp,%ebp
80102c95:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c98:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c9d:	85 c0                	test   %eax,%eax
80102c9f:	74 10                	je     80102cb1 <kalloc+0x1f>
    acquire(&kmem.lock);
80102ca1:	83 ec 0c             	sub    $0xc,%esp
80102ca4:	68 00 71 11 80       	push   $0x80117100
80102ca9:	e8 4f 20 00 00       	call   80104cfd <acquire>
80102cae:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cb1:	a1 38 71 11 80       	mov    0x80117138,%eax
80102cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cbd:	74 0a                	je     80102cc9 <kalloc+0x37>
    kmem.freelist = r->next;
80102cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc2:	8b 00                	mov    (%eax),%eax
80102cc4:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cc9:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cce:	85 c0                	test   %eax,%eax
80102cd0:	74 10                	je     80102ce2 <kalloc+0x50>
    release(&kmem.lock);
80102cd2:	83 ec 0c             	sub    $0xc,%esp
80102cd5:	68 00 71 11 80       	push   $0x80117100
80102cda:	e8 8c 20 00 00       	call   80104d6b <release>
80102cdf:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce5:	c9                   	leave  
80102ce6:	c3                   	ret    

80102ce7 <inb>:
{
80102ce7:	55                   	push   %ebp
80102ce8:	89 e5                	mov    %esp,%ebp
80102cea:	83 ec 14             	sub    $0x14,%esp
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf8:	89 c2                	mov    %eax,%edx
80102cfa:	ec                   	in     (%dx),%al
80102cfb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cfe:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d0a:	6a 64                	push   $0x64
80102d0c:	e8 d6 ff ff ff       	call   80102ce7 <inb>
80102d11:	83 c4 04             	add    $0x4,%esp
80102d14:	0f b6 c0             	movzbl %al,%eax
80102d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d1d:	83 e0 01             	and    $0x1,%eax
80102d20:	85 c0                	test   %eax,%eax
80102d22:	75 0a                	jne    80102d2e <kbdgetc+0x2a>
    return -1;
80102d24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d29:	e9 23 01 00 00       	jmp    80102e51 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d2e:	6a 60                	push   $0x60
80102d30:	e8 b2 ff ff ff       	call   80102ce7 <inb>
80102d35:	83 c4 04             	add    $0x4,%esp
80102d38:	0f b6 c0             	movzbl %al,%eax
80102d3b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d3e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d45:	75 17                	jne    80102d5e <kbdgetc+0x5a>
    shift |= E0ESC;
80102d47:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d4c:	83 c8 40             	or     $0x40,%eax
80102d4f:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d54:	b8 00 00 00 00       	mov    $0x0,%eax
80102d59:	e9 f3 00 00 00       	jmp    80102e51 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d61:	25 80 00 00 00       	and    $0x80,%eax
80102d66:	85 c0                	test   %eax,%eax
80102d68:	74 45                	je     80102daf <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6a:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d6f:	83 e0 40             	and    $0x40,%eax
80102d72:	85 c0                	test   %eax,%eax
80102d74:	75 08                	jne    80102d7e <kbdgetc+0x7a>
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	83 e0 7f             	and    $0x7f,%eax
80102d7c:	eb 03                	jmp    80102d81 <kbdgetc+0x7d>
80102d7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d81:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d87:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d8c:	0f b6 00             	movzbl (%eax),%eax
80102d8f:	83 c8 40             	or     $0x40,%eax
80102d92:	0f b6 c0             	movzbl %al,%eax
80102d95:	f7 d0                	not    %eax
80102d97:	89 c2                	mov    %eax,%edx
80102d99:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d9e:	21 d0                	and    %edx,%eax
80102da0:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102da5:	b8 00 00 00 00       	mov    $0x0,%eax
80102daa:	e9 a2 00 00 00       	jmp    80102e51 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102daf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102db4:	83 e0 40             	and    $0x40,%eax
80102db7:	85 c0                	test   %eax,%eax
80102db9:	74 14                	je     80102dcf <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbb:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc2:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dc7:	83 e0 bf             	and    $0xffffffbf,%eax
80102dca:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd2:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dd7:	0f b6 00             	movzbl (%eax),%eax
80102dda:	0f b6 d0             	movzbl %al,%edx
80102ddd:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102de2:	09 d0                	or     %edx,%eax
80102de4:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102de9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dec:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102df1:	0f b6 00             	movzbl (%eax),%eax
80102df4:	0f b6 d0             	movzbl %al,%edx
80102df7:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfc:	31 d0                	xor    %edx,%eax
80102dfe:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e03:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e08:	83 e0 03             	and    $0x3,%eax
80102e0b:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e15:	01 d0                	add    %edx,%eax
80102e17:	0f b6 00             	movzbl (%eax),%eax
80102e1a:	0f b6 c0             	movzbl %al,%eax
80102e1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e20:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e25:	83 e0 08             	and    $0x8,%eax
80102e28:	85 c0                	test   %eax,%eax
80102e2a:	74 22                	je     80102e4e <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e2c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e30:	76 0c                	jbe    80102e3e <kbdgetc+0x13a>
80102e32:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e36:	77 06                	ja     80102e3e <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e38:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e3c:	eb 10                	jmp    80102e4e <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e3e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e42:	76 0a                	jbe    80102e4e <kbdgetc+0x14a>
80102e44:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e48:	77 04                	ja     80102e4e <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e4a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e51:	c9                   	leave  
80102e52:	c3                   	ret    

80102e53 <kbdintr>:

void
kbdintr(void)
{
80102e53:	55                   	push   %ebp
80102e54:	89 e5                	mov    %esp,%ebp
80102e56:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e59:	83 ec 0c             	sub    $0xc,%esp
80102e5c:	68 04 2d 10 80       	push   $0x80102d04
80102e61:	e8 88 d9 ff ff       	call   801007ee <consoleintr>
80102e66:	83 c4 10             	add    $0x10,%esp
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave  
80102e6b:	c3                   	ret    

80102e6c <inb>:
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 14             	sub    $0x14,%esp
80102e72:	8b 45 08             	mov    0x8(%ebp),%eax
80102e75:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e79:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e7d:	89 c2                	mov    %eax,%edx
80102e7f:	ec                   	in     (%dx),%al
80102e80:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e83:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e87:	c9                   	leave  
80102e88:	c3                   	ret    

80102e89 <outb>:
{
80102e89:	55                   	push   %ebp
80102e8a:	89 e5                	mov    %esp,%ebp
80102e8c:	83 ec 08             	sub    $0x8,%esp
80102e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e92:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e95:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e99:	89 d0                	mov    %edx,%eax
80102e9b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e9e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ea2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ea6:	ee                   	out    %al,(%dx)
}
80102ea7:	90                   	nop
80102ea8:	c9                   	leave  
80102ea9:	c3                   	ret    

80102eaa <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102eaa:	55                   	push   %ebp
80102eab:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ead:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102eb6:	c1 e0 02             	shl    $0x2,%eax
80102eb9:	01 c2                	add    %eax,%edx
80102ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ebe:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ec0:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec5:	83 c0 20             	add    $0x20,%eax
80102ec8:	8b 00                	mov    (%eax),%eax
}
80102eca:	90                   	nop
80102ecb:	5d                   	pop    %ebp
80102ecc:	c3                   	ret    

80102ecd <lapicinit>:

void
lapicinit(void)
{
80102ecd:	55                   	push   %ebp
80102ece:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ed0:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ed5:	85 c0                	test   %eax,%eax
80102ed7:	0f 84 0c 01 00 00    	je     80102fe9 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102edd:	68 3f 01 00 00       	push   $0x13f
80102ee2:	6a 3c                	push   $0x3c
80102ee4:	e8 c1 ff ff ff       	call   80102eaa <lapicw>
80102ee9:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102eec:	6a 0b                	push   $0xb
80102eee:	68 f8 00 00 00       	push   $0xf8
80102ef3:	e8 b2 ff ff ff       	call   80102eaa <lapicw>
80102ef8:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102efb:	68 20 00 02 00       	push   $0x20020
80102f00:	68 c8 00 00 00       	push   $0xc8
80102f05:	e8 a0 ff ff ff       	call   80102eaa <lapicw>
80102f0a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f0d:	68 80 96 98 00       	push   $0x989680
80102f12:	68 e0 00 00 00       	push   $0xe0
80102f17:	e8 8e ff ff ff       	call   80102eaa <lapicw>
80102f1c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f1f:	68 00 00 01 00       	push   $0x10000
80102f24:	68 d4 00 00 00       	push   $0xd4
80102f29:	e8 7c ff ff ff       	call   80102eaa <lapicw>
80102f2e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f31:	68 00 00 01 00       	push   $0x10000
80102f36:	68 d8 00 00 00       	push   $0xd8
80102f3b:	e8 6a ff ff ff       	call   80102eaa <lapicw>
80102f40:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f43:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f48:	83 c0 30             	add    $0x30,%eax
80102f4b:	8b 00                	mov    (%eax),%eax
80102f4d:	c1 e8 10             	shr    $0x10,%eax
80102f50:	25 fc 00 00 00       	and    $0xfc,%eax
80102f55:	85 c0                	test   %eax,%eax
80102f57:	74 12                	je     80102f6b <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f59:	68 00 00 01 00       	push   $0x10000
80102f5e:	68 d0 00 00 00       	push   $0xd0
80102f63:	e8 42 ff ff ff       	call   80102eaa <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f6b:	6a 33                	push   $0x33
80102f6d:	68 dc 00 00 00       	push   $0xdc
80102f72:	e8 33 ff ff ff       	call   80102eaa <lapicw>
80102f77:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f7a:	6a 00                	push   $0x0
80102f7c:	68 a0 00 00 00       	push   $0xa0
80102f81:	e8 24 ff ff ff       	call   80102eaa <lapicw>
80102f86:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f89:	6a 00                	push   $0x0
80102f8b:	68 a0 00 00 00       	push   $0xa0
80102f90:	e8 15 ff ff ff       	call   80102eaa <lapicw>
80102f95:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f98:	6a 00                	push   $0x0
80102f9a:	6a 2c                	push   $0x2c
80102f9c:	e8 09 ff ff ff       	call   80102eaa <lapicw>
80102fa1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fa4:	6a 00                	push   $0x0
80102fa6:	68 c4 00 00 00       	push   $0xc4
80102fab:	e8 fa fe ff ff       	call   80102eaa <lapicw>
80102fb0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fb3:	68 00 85 08 00       	push   $0x88500
80102fb8:	68 c0 00 00 00       	push   $0xc0
80102fbd:	e8 e8 fe ff ff       	call   80102eaa <lapicw>
80102fc2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fc5:	90                   	nop
80102fc6:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fcb:	05 00 03 00 00       	add    $0x300,%eax
80102fd0:	8b 00                	mov    (%eax),%eax
80102fd2:	25 00 10 00 00       	and    $0x1000,%eax
80102fd7:	85 c0                	test   %eax,%eax
80102fd9:	75 eb                	jne    80102fc6 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fdb:	6a 00                	push   $0x0
80102fdd:	6a 20                	push   $0x20
80102fdf:	e8 c6 fe ff ff       	call   80102eaa <lapicw>
80102fe4:	83 c4 08             	add    $0x8,%esp
80102fe7:	eb 01                	jmp    80102fea <lapicinit+0x11d>
    return;
80102fe9:	90                   	nop
}
80102fea:	c9                   	leave  
80102feb:	c3                   	ret    

80102fec <lapicid>:

int
lapicid(void)
{
80102fec:	55                   	push   %ebp
80102fed:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fef:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff4:	85 c0                	test   %eax,%eax
80102ff6:	75 07                	jne    80102fff <lapicid+0x13>
    return 0;
80102ff8:	b8 00 00 00 00       	mov    $0x0,%eax
80102ffd:	eb 0d                	jmp    8010300c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102fff:	a1 40 71 11 80       	mov    0x80117140,%eax
80103004:	83 c0 20             	add    $0x20,%eax
80103007:	8b 00                	mov    (%eax),%eax
80103009:	c1 e8 18             	shr    $0x18,%eax
}
8010300c:	5d                   	pop    %ebp
8010300d:	c3                   	ret    

8010300e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010300e:	55                   	push   %ebp
8010300f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103011:	a1 40 71 11 80       	mov    0x80117140,%eax
80103016:	85 c0                	test   %eax,%eax
80103018:	74 0c                	je     80103026 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010301a:	6a 00                	push   $0x0
8010301c:	6a 2c                	push   $0x2c
8010301e:	e8 87 fe ff ff       	call   80102eaa <lapicw>
80103023:	83 c4 08             	add    $0x8,%esp
}
80103026:	90                   	nop
80103027:	c9                   	leave  
80103028:	c3                   	ret    

80103029 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103029:	55                   	push   %ebp
8010302a:	89 e5                	mov    %esp,%ebp
}
8010302c:	90                   	nop
8010302d:	5d                   	pop    %ebp
8010302e:	c3                   	ret    

8010302f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010302f:	55                   	push   %ebp
80103030:	89 e5                	mov    %esp,%ebp
80103032:	83 ec 14             	sub    $0x14,%esp
80103035:	8b 45 08             	mov    0x8(%ebp),%eax
80103038:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010303b:	6a 0f                	push   $0xf
8010303d:	6a 70                	push   $0x70
8010303f:	e8 45 fe ff ff       	call   80102e89 <outb>
80103044:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103047:	6a 0a                	push   $0xa
80103049:	6a 71                	push   $0x71
8010304b:	e8 39 fe ff ff       	call   80102e89 <outb>
80103050:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103053:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010305a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103062:	8b 45 0c             	mov    0xc(%ebp),%eax
80103065:	c1 e8 04             	shr    $0x4,%eax
80103068:	89 c2                	mov    %eax,%edx
8010306a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010306d:	83 c0 02             	add    $0x2,%eax
80103070:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103073:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103077:	c1 e0 18             	shl    $0x18,%eax
8010307a:	50                   	push   %eax
8010307b:	68 c4 00 00 00       	push   $0xc4
80103080:	e8 25 fe ff ff       	call   80102eaa <lapicw>
80103085:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103088:	68 00 c5 00 00       	push   $0xc500
8010308d:	68 c0 00 00 00       	push   $0xc0
80103092:	e8 13 fe ff ff       	call   80102eaa <lapicw>
80103097:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010309a:	68 c8 00 00 00       	push   $0xc8
8010309f:	e8 85 ff ff ff       	call   80103029 <microdelay>
801030a4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030a7:	68 00 85 00 00       	push   $0x8500
801030ac:	68 c0 00 00 00       	push   $0xc0
801030b1:	e8 f4 fd ff ff       	call   80102eaa <lapicw>
801030b6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030b9:	6a 64                	push   $0x64
801030bb:	e8 69 ff ff ff       	call   80103029 <microdelay>
801030c0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030ca:	eb 3d                	jmp    80103109 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030cc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d0:	c1 e0 18             	shl    $0x18,%eax
801030d3:	50                   	push   %eax
801030d4:	68 c4 00 00 00       	push   $0xc4
801030d9:	e8 cc fd ff ff       	call   80102eaa <lapicw>
801030de:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801030e4:	c1 e8 0c             	shr    $0xc,%eax
801030e7:	80 cc 06             	or     $0x6,%ah
801030ea:	50                   	push   %eax
801030eb:	68 c0 00 00 00       	push   $0xc0
801030f0:	e8 b5 fd ff ff       	call   80102eaa <lapicw>
801030f5:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030f8:	68 c8 00 00 00       	push   $0xc8
801030fd:	e8 27 ff ff ff       	call   80103029 <microdelay>
80103102:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103105:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103109:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010310d:	7e bd                	jle    801030cc <lapicstartap+0x9d>
  }
}
8010310f:	90                   	nop
80103110:	90                   	nop
80103111:	c9                   	leave  
80103112:	c3                   	ret    

80103113 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103113:	55                   	push   %ebp
80103114:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103116:	8b 45 08             	mov    0x8(%ebp),%eax
80103119:	0f b6 c0             	movzbl %al,%eax
8010311c:	50                   	push   %eax
8010311d:	6a 70                	push   $0x70
8010311f:	e8 65 fd ff ff       	call   80102e89 <outb>
80103124:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103127:	68 c8 00 00 00       	push   $0xc8
8010312c:	e8 f8 fe ff ff       	call   80103029 <microdelay>
80103131:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103134:	6a 71                	push   $0x71
80103136:	e8 31 fd ff ff       	call   80102e6c <inb>
8010313b:	83 c4 04             	add    $0x4,%esp
8010313e:	0f b6 c0             	movzbl %al,%eax
}
80103141:	c9                   	leave  
80103142:	c3                   	ret    

80103143 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103143:	55                   	push   %ebp
80103144:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103146:	6a 00                	push   $0x0
80103148:	e8 c6 ff ff ff       	call   80103113 <cmos_read>
8010314d:	83 c4 04             	add    $0x4,%esp
80103150:	8b 55 08             	mov    0x8(%ebp),%edx
80103153:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103155:	6a 02                	push   $0x2
80103157:	e8 b7 ff ff ff       	call   80103113 <cmos_read>
8010315c:	83 c4 04             	add    $0x4,%esp
8010315f:	8b 55 08             	mov    0x8(%ebp),%edx
80103162:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103165:	6a 04                	push   $0x4
80103167:	e8 a7 ff ff ff       	call   80103113 <cmos_read>
8010316c:	83 c4 04             	add    $0x4,%esp
8010316f:	8b 55 08             	mov    0x8(%ebp),%edx
80103172:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103175:	6a 07                	push   $0x7
80103177:	e8 97 ff ff ff       	call   80103113 <cmos_read>
8010317c:	83 c4 04             	add    $0x4,%esp
8010317f:	8b 55 08             	mov    0x8(%ebp),%edx
80103182:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103185:	6a 08                	push   $0x8
80103187:	e8 87 ff ff ff       	call   80103113 <cmos_read>
8010318c:	83 c4 04             	add    $0x4,%esp
8010318f:	8b 55 08             	mov    0x8(%ebp),%edx
80103192:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103195:	6a 09                	push   $0x9
80103197:	e8 77 ff ff ff       	call   80103113 <cmos_read>
8010319c:	83 c4 04             	add    $0x4,%esp
8010319f:	8b 55 08             	mov    0x8(%ebp),%edx
801031a2:	89 42 14             	mov    %eax,0x14(%edx)
}
801031a5:	90                   	nop
801031a6:	c9                   	leave  
801031a7:	c3                   	ret    

801031a8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031a8:	55                   	push   %ebp
801031a9:	89 e5                	mov    %esp,%ebp
801031ab:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ae:	6a 0b                	push   $0xb
801031b0:	e8 5e ff ff ff       	call   80103113 <cmos_read>
801031b5:	83 c4 04             	add    $0x4,%esp
801031b8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031be:	83 e0 04             	and    $0x4,%eax
801031c1:	85 c0                	test   %eax,%eax
801031c3:	0f 94 c0             	sete   %al
801031c6:	0f b6 c0             	movzbl %al,%eax
801031c9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031cc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031cf:	50                   	push   %eax
801031d0:	e8 6e ff ff ff       	call   80103143 <fill_rtcdate>
801031d5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031d8:	6a 0a                	push   $0xa
801031da:	e8 34 ff ff ff       	call   80103113 <cmos_read>
801031df:	83 c4 04             	add    $0x4,%esp
801031e2:	25 80 00 00 00       	and    $0x80,%eax
801031e7:	85 c0                	test   %eax,%eax
801031e9:	75 27                	jne    80103212 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031eb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031ee:	50                   	push   %eax
801031ef:	e8 4f ff ff ff       	call   80103143 <fill_rtcdate>
801031f4:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031f7:	83 ec 04             	sub    $0x4,%esp
801031fa:	6a 18                	push   $0x18
801031fc:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031ff:	50                   	push   %eax
80103200:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103203:	50                   	push   %eax
80103204:	e8 d1 1d 00 00       	call   80104fda <memcmp>
80103209:	83 c4 10             	add    $0x10,%esp
8010320c:	85 c0                	test   %eax,%eax
8010320e:	74 05                	je     80103215 <cmostime+0x6d>
80103210:	eb ba                	jmp    801031cc <cmostime+0x24>
        continue;
80103212:	90                   	nop
    fill_rtcdate(&t1);
80103213:	eb b7                	jmp    801031cc <cmostime+0x24>
      break;
80103215:	90                   	nop
  }

  // convert
  if(bcd) {
80103216:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010321a:	0f 84 b4 00 00 00    	je     801032d4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103220:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103223:	c1 e8 04             	shr    $0x4,%eax
80103226:	89 c2                	mov    %eax,%edx
80103228:	89 d0                	mov    %edx,%eax
8010322a:	c1 e0 02             	shl    $0x2,%eax
8010322d:	01 d0                	add    %edx,%eax
8010322f:	01 c0                	add    %eax,%eax
80103231:	89 c2                	mov    %eax,%edx
80103233:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103236:	83 e0 0f             	and    $0xf,%eax
80103239:	01 d0                	add    %edx,%eax
8010323b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010323e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103241:	c1 e8 04             	shr    $0x4,%eax
80103244:	89 c2                	mov    %eax,%edx
80103246:	89 d0                	mov    %edx,%eax
80103248:	c1 e0 02             	shl    $0x2,%eax
8010324b:	01 d0                	add    %edx,%eax
8010324d:	01 c0                	add    %eax,%eax
8010324f:	89 c2                	mov    %eax,%edx
80103251:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103254:	83 e0 0f             	and    $0xf,%eax
80103257:	01 d0                	add    %edx,%eax
80103259:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010325c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010325f:	c1 e8 04             	shr    $0x4,%eax
80103262:	89 c2                	mov    %eax,%edx
80103264:	89 d0                	mov    %edx,%eax
80103266:	c1 e0 02             	shl    $0x2,%eax
80103269:	01 d0                	add    %edx,%eax
8010326b:	01 c0                	add    %eax,%eax
8010326d:	89 c2                	mov    %eax,%edx
8010326f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103272:	83 e0 0f             	and    $0xf,%eax
80103275:	01 d0                	add    %edx,%eax
80103277:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010327a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010327d:	c1 e8 04             	shr    $0x4,%eax
80103280:	89 c2                	mov    %eax,%edx
80103282:	89 d0                	mov    %edx,%eax
80103284:	c1 e0 02             	shl    $0x2,%eax
80103287:	01 d0                	add    %edx,%eax
80103289:	01 c0                	add    %eax,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103290:	83 e0 0f             	and    $0xf,%eax
80103293:	01 d0                	add    %edx,%eax
80103295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103298:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010329b:	c1 e8 04             	shr    $0x4,%eax
8010329e:	89 c2                	mov    %eax,%edx
801032a0:	89 d0                	mov    %edx,%eax
801032a2:	c1 e0 02             	shl    $0x2,%eax
801032a5:	01 d0                	add    %edx,%eax
801032a7:	01 c0                	add    %eax,%eax
801032a9:	89 c2                	mov    %eax,%edx
801032ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ae:	83 e0 0f             	and    $0xf,%eax
801032b1:	01 d0                	add    %edx,%eax
801032b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b9:	c1 e8 04             	shr    $0x4,%eax
801032bc:	89 c2                	mov    %eax,%edx
801032be:	89 d0                	mov    %edx,%eax
801032c0:	c1 e0 02             	shl    $0x2,%eax
801032c3:	01 d0                	add    %edx,%eax
801032c5:	01 c0                	add    %eax,%eax
801032c7:	89 c2                	mov    %eax,%edx
801032c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032cc:	83 e0 0f             	and    $0xf,%eax
801032cf:	01 d0                	add    %edx,%eax
801032d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d4:	8b 45 08             	mov    0x8(%ebp),%eax
801032d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032da:	89 10                	mov    %edx,(%eax)
801032dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032df:	89 50 04             	mov    %edx,0x4(%eax)
801032e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032e5:	89 50 08             	mov    %edx,0x8(%eax)
801032e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032eb:	89 50 0c             	mov    %edx,0xc(%eax)
801032ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f1:	89 50 10             	mov    %edx,0x10(%eax)
801032f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032f7:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032fa:	8b 45 08             	mov    0x8(%ebp),%eax
801032fd:	8b 40 14             	mov    0x14(%eax),%eax
80103300:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103306:	8b 45 08             	mov    0x8(%ebp),%eax
80103309:	89 50 14             	mov    %edx,0x14(%eax)
}
8010330c:	90                   	nop
8010330d:	c9                   	leave  
8010330e:	c3                   	ret    

8010330f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010330f:	55                   	push   %ebp
80103310:	89 e5                	mov    %esp,%ebp
80103312:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103315:	83 ec 08             	sub    $0x8,%esp
80103318:	68 31 a8 10 80       	push   $0x8010a831
8010331d:	68 60 71 11 80       	push   $0x80117160
80103322:	e8 b4 19 00 00       	call   80104cdb <initlock>
80103327:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010332a:	83 ec 08             	sub    $0x8,%esp
8010332d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103330:	50                   	push   %eax
80103331:	ff 75 08             	push   0x8(%ebp)
80103334:	e8 a3 e0 ff ff       	call   801013dc <readsb>
80103339:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010333c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333f:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103344:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103347:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010334c:	8b 45 08             	mov    0x8(%ebp),%eax
8010334f:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103354:	e8 b3 01 00 00       	call   8010350c <recover_from_log>
}
80103359:	90                   	nop
8010335a:	c9                   	leave  
8010335b:	c3                   	ret    

8010335c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010335c:	55                   	push   %ebp
8010335d:	89 e5                	mov    %esp,%ebp
8010335f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103369:	e9 95 00 00 00       	jmp    80103403 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010336e:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103377:	01 d0                	add    %edx,%eax
80103379:	83 c0 01             	add    $0x1,%eax
8010337c:	89 c2                	mov    %eax,%edx
8010337e:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103383:	83 ec 08             	sub    $0x8,%esp
80103386:	52                   	push   %edx
80103387:	50                   	push   %eax
80103388:	e8 74 ce ff ff       	call   80100201 <bread>
8010338d:	83 c4 10             	add    $0x10,%esp
80103390:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103396:	83 c0 10             	add    $0x10,%eax
80103399:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801033a0:	89 c2                	mov    %eax,%edx
801033a2:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801033a7:	83 ec 08             	sub    $0x8,%esp
801033aa:	52                   	push   %edx
801033ab:	50                   	push   %eax
801033ac:	e8 50 ce ff ff       	call   80100201 <bread>
801033b1:	83 c4 10             	add    $0x10,%esp
801033b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ba:	8d 50 5c             	lea    0x5c(%eax),%edx
801033bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c0:	83 c0 5c             	add    $0x5c,%eax
801033c3:	83 ec 04             	sub    $0x4,%esp
801033c6:	68 00 02 00 00       	push   $0x200
801033cb:	52                   	push   %edx
801033cc:	50                   	push   %eax
801033cd:	e8 60 1c 00 00       	call   80105032 <memmove>
801033d2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 ec             	push   -0x14(%ebp)
801033db:	e8 5a ce ff ff       	call   8010023a <bwrite>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 f0             	push   -0x10(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f1:	83 ec 0c             	sub    $0xc,%esp
801033f4:	ff 75 ec             	push   -0x14(%ebp)
801033f7:	e8 87 ce ff ff       	call   80100283 <brelse>
801033fc:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103403:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103408:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010340b:	0f 8c 5d ff ff ff    	jl     8010336e <install_trans+0x12>
  }
}
80103411:	90                   	nop
80103412:	90                   	nop
80103413:	c9                   	leave  
80103414:	c3                   	ret    

80103415 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103415:	55                   	push   %ebp
80103416:	89 e5                	mov    %esp,%ebp
80103418:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341b:	a1 94 71 11 80       	mov    0x80117194,%eax
80103420:	89 c2                	mov    %eax,%edx
80103422:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103427:	83 ec 08             	sub    $0x8,%esp
8010342a:	52                   	push   %edx
8010342b:	50                   	push   %eax
8010342c:	e8 d0 cd ff ff       	call   80100201 <bread>
80103431:	83 c4 10             	add    $0x10,%esp
80103434:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343a:	83 c0 5c             	add    $0x5c,%eax
8010343d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103443:	8b 00                	mov    (%eax),%eax
80103445:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010344a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103451:	eb 1b                	jmp    8010346e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103453:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103456:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103459:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010345d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103460:	83 c2 10             	add    $0x10,%edx
80103463:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010346a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346e:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103473:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103476:	7c db                	jl     80103453 <read_head+0x3e>
  }
  brelse(buf);
80103478:	83 ec 0c             	sub    $0xc,%esp
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 00 ce ff ff       	call   80100283 <brelse>
80103483:	83 c4 10             	add    $0x10,%esp
}
80103486:	90                   	nop
80103487:	c9                   	leave  
80103488:	c3                   	ret    

80103489 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103489:	55                   	push   %ebp
8010348a:	89 e5                	mov    %esp,%ebp
8010348c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010348f:	a1 94 71 11 80       	mov    0x80117194,%eax
80103494:	89 c2                	mov    %eax,%edx
80103496:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010349b:	83 ec 08             	sub    $0x8,%esp
8010349e:	52                   	push   %edx
8010349f:	50                   	push   %eax
801034a0:	e8 5c cd ff ff       	call   80100201 <bread>
801034a5:	83 c4 10             	add    $0x10,%esp
801034a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ae:	83 c0 5c             	add    $0x5c,%eax
801034b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b4:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034bd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034c6:	eb 1b                	jmp    801034e3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cb:	83 c0 10             	add    $0x10,%eax
801034ce:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034db:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e3:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034e8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034eb:	7c db                	jl     801034c8 <write_head+0x3f>
  }
  bwrite(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 42 cd ff ff       	call   8010023a <bwrite>
801034f8:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034fb:	83 ec 0c             	sub    $0xc,%esp
801034fe:	ff 75 f0             	push   -0x10(%ebp)
80103501:	e8 7d cd ff ff       	call   80100283 <brelse>
80103506:	83 c4 10             	add    $0x10,%esp
}
80103509:	90                   	nop
8010350a:	c9                   	leave  
8010350b:	c3                   	ret    

8010350c <recover_from_log>:

static void
recover_from_log(void)
{
8010350c:	55                   	push   %ebp
8010350d:	89 e5                	mov    %esp,%ebp
8010350f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103512:	e8 fe fe ff ff       	call   80103415 <read_head>
  install_trans(); // if committed, copy from log to disk
80103517:	e8 40 fe ff ff       	call   8010335c <install_trans>
  log.lh.n = 0;
8010351c:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103523:	00 00 00 
  write_head(); // clear the log
80103526:	e8 5e ff ff ff       	call   80103489 <write_head>
}
8010352b:	90                   	nop
8010352c:	c9                   	leave  
8010352d:	c3                   	ret    

8010352e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010352e:	55                   	push   %ebp
8010352f:	89 e5                	mov    %esp,%ebp
80103531:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103534:	83 ec 0c             	sub    $0xc,%esp
80103537:	68 60 71 11 80       	push   $0x80117160
8010353c:	e8 bc 17 00 00       	call   80104cfd <acquire>
80103541:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103544:	a1 a0 71 11 80       	mov    0x801171a0,%eax
80103549:	85 c0                	test   %eax,%eax
8010354b:	74 17                	je     80103564 <begin_op+0x36>
      sleep(&log, &log.lock);
8010354d:	83 ec 08             	sub    $0x8,%esp
80103550:	68 60 71 11 80       	push   $0x80117160
80103555:	68 60 71 11 80       	push   $0x80117160
8010355a:	e8 6c 12 00 00       	call   801047cb <sleep>
8010355f:	83 c4 10             	add    $0x10,%esp
80103562:	eb e0                	jmp    80103544 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103564:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010356a:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010356f:	8d 50 01             	lea    0x1(%eax),%edx
80103572:	89 d0                	mov    %edx,%eax
80103574:	c1 e0 02             	shl    $0x2,%eax
80103577:	01 d0                	add    %edx,%eax
80103579:	01 c0                	add    %eax,%eax
8010357b:	01 c8                	add    %ecx,%eax
8010357d:	83 f8 1e             	cmp    $0x1e,%eax
80103580:	7e 17                	jle    80103599 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103582:	83 ec 08             	sub    $0x8,%esp
80103585:	68 60 71 11 80       	push   $0x80117160
8010358a:	68 60 71 11 80       	push   $0x80117160
8010358f:	e8 37 12 00 00       	call   801047cb <sleep>
80103594:	83 c4 10             	add    $0x10,%esp
80103597:	eb ab                	jmp    80103544 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103599:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010359e:	83 c0 01             	add    $0x1,%eax
801035a1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
801035a6:	83 ec 0c             	sub    $0xc,%esp
801035a9:	68 60 71 11 80       	push   $0x80117160
801035ae:	e8 b8 17 00 00       	call   80104d6b <release>
801035b3:	83 c4 10             	add    $0x10,%esp
      break;
801035b6:	90                   	nop
    }
  }
}
801035b7:	90                   	nop
801035b8:	c9                   	leave  
801035b9:	c3                   	ret    

801035ba <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ba:	55                   	push   %ebp
801035bb:	89 e5                	mov    %esp,%ebp
801035bd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035c7:	83 ec 0c             	sub    $0xc,%esp
801035ca:	68 60 71 11 80       	push   $0x80117160
801035cf:	e8 29 17 00 00       	call   80104cfd <acquire>
801035d4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035d7:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035dc:	83 e8 01             	sub    $0x1,%eax
801035df:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035e4:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035e9:	85 c0                	test   %eax,%eax
801035eb:	74 0d                	je     801035fa <end_op+0x40>
    panic("log.committing");
801035ed:	83 ec 0c             	sub    $0xc,%esp
801035f0:	68 35 a8 10 80       	push   $0x8010a835
801035f5:	e8 c7 cf ff ff       	call   801005c1 <panic>
  if(log.outstanding == 0){
801035fa:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ff:	85 c0                	test   %eax,%eax
80103601:	75 13                	jne    80103616 <end_op+0x5c>
    do_commit = 1;
80103603:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360a:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103611:	00 00 00 
80103614:	eb 10                	jmp    80103626 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103616:	83 ec 0c             	sub    $0xc,%esp
80103619:	68 60 71 11 80       	push   $0x80117160
8010361e:	e8 8f 12 00 00       	call   801048b2 <wakeup>
80103623:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103626:	83 ec 0c             	sub    $0xc,%esp
80103629:	68 60 71 11 80       	push   $0x80117160
8010362e:	e8 38 17 00 00       	call   80104d6b <release>
80103633:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103636:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010363a:	74 3f                	je     8010367b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010363c:	e8 f6 00 00 00       	call   80103737 <commit>
    acquire(&log.lock);
80103641:	83 ec 0c             	sub    $0xc,%esp
80103644:	68 60 71 11 80       	push   $0x80117160
80103649:	e8 af 16 00 00       	call   80104cfd <acquire>
8010364e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103651:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
80103658:	00 00 00 
    wakeup(&log);
8010365b:	83 ec 0c             	sub    $0xc,%esp
8010365e:	68 60 71 11 80       	push   $0x80117160
80103663:	e8 4a 12 00 00       	call   801048b2 <wakeup>
80103668:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010366b:	83 ec 0c             	sub    $0xc,%esp
8010366e:	68 60 71 11 80       	push   $0x80117160
80103673:	e8 f3 16 00 00       	call   80104d6b <release>
80103678:	83 c4 10             	add    $0x10,%esp
  }
}
8010367b:	90                   	nop
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368b:	e9 95 00 00 00       	jmp    80103725 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103690:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103699:	01 d0                	add    %edx,%eax
8010369b:	83 c0 01             	add    $0x1,%eax
8010369e:	89 c2                	mov    %eax,%edx
801036a0:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036a5:	83 ec 08             	sub    $0x8,%esp
801036a8:	52                   	push   %edx
801036a9:	50                   	push   %eax
801036aa:	e8 52 cb ff ff       	call   80100201 <bread>
801036af:	83 c4 10             	add    $0x10,%esp
801036b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b8:	83 c0 10             	add    $0x10,%eax
801036bb:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036c2:	89 c2                	mov    %eax,%edx
801036c4:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036c9:	83 ec 08             	sub    $0x8,%esp
801036cc:	52                   	push   %edx
801036cd:	50                   	push   %eax
801036ce:	e8 2e cb ff ff       	call   80100201 <bread>
801036d3:	83 c4 10             	add    $0x10,%esp
801036d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036dc:	8d 50 5c             	lea    0x5c(%eax),%edx
801036df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e2:	83 c0 5c             	add    $0x5c,%eax
801036e5:	83 ec 04             	sub    $0x4,%esp
801036e8:	68 00 02 00 00       	push   $0x200
801036ed:	52                   	push   %edx
801036ee:	50                   	push   %eax
801036ef:	e8 3e 19 00 00       	call   80105032 <memmove>
801036f4:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 f0             	push   -0x10(%ebp)
801036fd:	e8 38 cb ff ff       	call   8010023a <bwrite>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 ec             	push   -0x14(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103713:	83 ec 0c             	sub    $0xc,%esp
80103716:	ff 75 f0             	push   -0x10(%ebp)
80103719:	e8 65 cb ff ff       	call   80100283 <brelse>
8010371e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103721:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103725:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010372a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010372d:	0f 8c 5d ff ff ff    	jl     80103690 <write_log+0x12>
  }
}
80103733:	90                   	nop
80103734:	90                   	nop
80103735:	c9                   	leave  
80103736:	c3                   	ret    

80103737 <commit>:

static void
commit()
{
80103737:	55                   	push   %ebp
80103738:	89 e5                	mov    %esp,%ebp
8010373a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010373d:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103742:	85 c0                	test   %eax,%eax
80103744:	7e 1e                	jle    80103764 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103746:	e8 33 ff ff ff       	call   8010367e <write_log>
    write_head();    // Write header to disk -- the real commit
8010374b:	e8 39 fd ff ff       	call   80103489 <write_head>
    install_trans(); // Now install writes to home locations
80103750:	e8 07 fc ff ff       	call   8010335c <install_trans>
    log.lh.n = 0;
80103755:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010375c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010375f:	e8 25 fd ff ff       	call   80103489 <write_head>
  }
}
80103764:	90                   	nop
80103765:	c9                   	leave  
80103766:	c3                   	ret    

80103767 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103767:	55                   	push   %ebp
80103768:	89 e5                	mov    %esp,%ebp
8010376a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010376d:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103772:	83 f8 1d             	cmp    $0x1d,%eax
80103775:	7f 12                	jg     80103789 <log_write+0x22>
80103777:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010377c:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103782:	83 ea 01             	sub    $0x1,%edx
80103785:	39 d0                	cmp    %edx,%eax
80103787:	7c 0d                	jl     80103796 <log_write+0x2f>
    panic("too big a transaction");
80103789:	83 ec 0c             	sub    $0xc,%esp
8010378c:	68 44 a8 10 80       	push   $0x8010a844
80103791:	e8 2b ce ff ff       	call   801005c1 <panic>
  if (log.outstanding < 1)
80103796:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	7f 0d                	jg     801037ac <log_write+0x45>
    panic("log_write outside of trans");
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	68 5a a8 10 80       	push   $0x8010a85a
801037a7:	e8 15 ce ff ff       	call   801005c1 <panic>

  acquire(&log.lock);
801037ac:	83 ec 0c             	sub    $0xc,%esp
801037af:	68 60 71 11 80       	push   $0x80117160
801037b4:	e8 44 15 00 00       	call   80104cfd <acquire>
801037b9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c3:	eb 1d                	jmp    801037e2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c8:	83 c0 10             	add    $0x10,%eax
801037cb:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037d2:	89 c2                	mov    %eax,%edx
801037d4:	8b 45 08             	mov    0x8(%ebp),%eax
801037d7:	8b 40 08             	mov    0x8(%eax),%eax
801037da:	39 c2                	cmp    %eax,%edx
801037dc:	74 10                	je     801037ee <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e2:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037e7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037ea:	7c d9                	jl     801037c5 <log_write+0x5e>
801037ec:	eb 01                	jmp    801037ef <log_write+0x88>
      break;
801037ee:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037ef:	8b 45 08             	mov    0x8(%ebp),%eax
801037f2:	8b 40 08             	mov    0x8(%eax),%eax
801037f5:	89 c2                	mov    %eax,%edx
801037f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fa:	83 c0 10             	add    $0x10,%eax
801037fd:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
80103804:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103809:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010380c:	75 0d                	jne    8010381b <log_write+0xb4>
    log.lh.n++;
8010380e:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103813:	83 c0 01             	add    $0x1,%eax
80103816:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010381b:	8b 45 08             	mov    0x8(%ebp),%eax
8010381e:	8b 00                	mov    (%eax),%eax
80103820:	83 c8 04             	or     $0x4,%eax
80103823:	89 c2                	mov    %eax,%edx
80103825:	8b 45 08             	mov    0x8(%ebp),%eax
80103828:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010382a:	83 ec 0c             	sub    $0xc,%esp
8010382d:	68 60 71 11 80       	push   $0x80117160
80103832:	e8 34 15 00 00       	call   80104d6b <release>
80103837:	83 c4 10             	add    $0x10,%esp
}
8010383a:	90                   	nop
8010383b:	c9                   	leave  
8010383c:	c3                   	ret    

8010383d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010383d:	55                   	push   %ebp
8010383e:	89 e5                	mov    %esp,%ebp
80103840:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103843:	8b 55 08             	mov    0x8(%ebp),%edx
80103846:	8b 45 0c             	mov    0xc(%ebp),%eax
80103849:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010384c:	f0 87 02             	lock xchg %eax,(%edx)
8010384f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103852:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103855:	c9                   	leave  
80103856:	c3                   	ret    

80103857 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103857:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010385b:	83 e4 f0             	and    $0xfffffff0,%esp
8010385e:	ff 71 fc             	push   -0x4(%ecx)
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	51                   	push   %ecx
80103865:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103868:	e8 66 4b 00 00       	call   801083d3 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010386d:	83 ec 08             	sub    $0x8,%esp
80103870:	68 00 00 40 80       	push   $0x80400000
80103875:	68 00 b0 11 80       	push   $0x8011b000
8010387a:	e8 de f2 ff ff       	call   80102b5d <kinit1>
8010387f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103882:	e8 7b 41 00 00       	call   80107a02 <kvmalloc>
  mpinit_uefi();
80103887:	e8 0d 49 00 00       	call   80108199 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010388c:	e8 3c f6 ff ff       	call   80102ecd <lapicinit>
  seginit();       // segment descriptors
80103891:	e8 04 3c 00 00       	call   8010749a <seginit>
  picinit();    // disable pic
80103896:	e8 9d 01 00 00       	call   80103a38 <picinit>
  ioapicinit();    // another interrupt controller
8010389b:	e8 d8 f1 ff ff       	call   80102a78 <ioapicinit>
  consoleinit();   // console hardware
801038a0:	e8 72 d2 ff ff       	call   80100b17 <consoleinit>
  uartinit();      // serial port
801038a5:	e8 89 2f 00 00       	call   80106833 <uartinit>
  pinit();         // process table
801038aa:	e8 c2 05 00 00       	call   80103e71 <pinit>
  tvinit();        // trap vectors
801038af:	e8 a7 2a 00 00       	call   8010635b <tvinit>
  binit();         // buffer cache
801038b4:	e8 ad c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038b9:	e8 0f d7 ff ff       	call   80100fcd <fileinit>
  ideinit();       // disk 
801038be:	e8 6e ed ff ff       	call   80102631 <ideinit>
  startothers();   // start other processors
801038c3:	e8 8a 00 00 00       	call   80103952 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038c8:	83 ec 08             	sub    $0x8,%esp
801038cb:	68 00 00 00 a0       	push   $0xa0000000
801038d0:	68 00 00 40 80       	push   $0x80400000
801038d5:	e8 bc f2 ff ff       	call   80102b96 <kinit2>
801038da:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038dd:	e8 4a 4d 00 00       	call   8010862c <pci_init>
  arp_scan();
801038e2:	e8 81 5a 00 00       	call   80109368 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038e7:	e8 63 07 00 00       	call   8010404f <userinit>

  mpmain();        // finish this processor's setup
801038ec:	e8 1a 00 00 00       	call   8010390b <mpmain>

801038f1 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038f1:	55                   	push   %ebp
801038f2:	89 e5                	mov    %esp,%ebp
801038f4:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038f7:	e8 1e 41 00 00       	call   80107a1a <switchkvm>
  seginit();
801038fc:	e8 99 3b 00 00       	call   8010749a <seginit>
  lapicinit();
80103901:	e8 c7 f5 ff ff       	call   80102ecd <lapicinit>
  mpmain();
80103906:	e8 00 00 00 00       	call   8010390b <mpmain>

8010390b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010390b:	55                   	push   %ebp
8010390c:	89 e5                	mov    %esp,%ebp
8010390e:	53                   	push   %ebx
8010390f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103912:	e8 78 05 00 00       	call   80103e8f <cpuid>
80103917:	89 c3                	mov    %eax,%ebx
80103919:	e8 71 05 00 00       	call   80103e8f <cpuid>
8010391e:	83 ec 04             	sub    $0x4,%esp
80103921:	53                   	push   %ebx
80103922:	50                   	push   %eax
80103923:	68 75 a8 10 80       	push   $0x8010a875
80103928:	e8 c7 ca ff ff       	call   801003f4 <cprintf>
8010392d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103930:	e8 9c 2b 00 00       	call   801064d1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103935:	e8 70 05 00 00       	call   80103eaa <mycpu>
8010393a:	05 a0 00 00 00       	add    $0xa0,%eax
8010393f:	83 ec 08             	sub    $0x8,%esp
80103942:	6a 01                	push   $0x1
80103944:	50                   	push   %eax
80103945:	e8 f3 fe ff ff       	call   8010383d <xchg>
8010394a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010394d:	e8 88 0c 00 00       	call   801045da <scheduler>

80103952 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
80103955:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103958:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010395f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103964:	83 ec 04             	sub    $0x4,%esp
80103967:	50                   	push   %eax
80103968:	68 18 f5 10 80       	push   $0x8010f518
8010396d:	ff 75 f0             	push   -0x10(%ebp)
80103970:	e8 bd 16 00 00       	call   80105032 <memmove>
80103975:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103978:	c7 45 f4 c0 99 11 80 	movl   $0x801199c0,-0xc(%ebp)
8010397f:	eb 79                	jmp    801039fa <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103981:	e8 24 05 00 00       	call   80103eaa <mycpu>
80103986:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103989:	74 67                	je     801039f2 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010398b:	e8 02 f3 ff ff       	call   80102c92 <kalloc>
80103990:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103996:	83 e8 04             	sub    $0x4,%eax
80103999:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010399c:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039a2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a7:	83 e8 08             	sub    $0x8,%eax
801039aa:	c7 00 f1 38 10 80    	movl   $0x801038f1,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039b0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039b5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039be:	83 e8 0c             	sub    $0xc,%eax
801039c1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cf:	0f b6 00             	movzbl (%eax),%eax
801039d2:	0f b6 c0             	movzbl %al,%eax
801039d5:	83 ec 08             	sub    $0x8,%esp
801039d8:	52                   	push   %edx
801039d9:	50                   	push   %eax
801039da:	e8 50 f6 ff ff       	call   8010302f <lapicstartap>
801039df:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039e2:	90                   	nop
801039e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039ec:	85 c0                	test   %eax,%eax
801039ee:	74 f3                	je     801039e3 <startothers+0x91>
801039f0:	eb 01                	jmp    801039f3 <startothers+0xa1>
      continue;
801039f2:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039f3:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039fa:	a1 80 9c 11 80       	mov    0x80119c80,%eax
801039ff:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a05:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103a0a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a0d:	0f 82 6e ff ff ff    	jb     80103981 <startothers+0x2f>
      ;
  }
}
80103a13:	90                   	nop
80103a14:	90                   	nop
80103a15:	c9                   	leave  
80103a16:	c3                   	ret    

80103a17 <outb>:
{
80103a17:	55                   	push   %ebp
80103a18:	89 e5                	mov    %esp,%ebp
80103a1a:	83 ec 08             	sub    $0x8,%esp
80103a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a20:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a23:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a27:	89 d0                	mov    %edx,%eax
80103a29:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a2c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a30:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a34:	ee                   	out    %al,(%dx)
}
80103a35:	90                   	nop
80103a36:	c9                   	leave  
80103a37:	c3                   	ret    

80103a38 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a38:	55                   	push   %ebp
80103a39:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a3b:	68 ff 00 00 00       	push   $0xff
80103a40:	6a 21                	push   $0x21
80103a42:	e8 d0 ff ff ff       	call   80103a17 <outb>
80103a47:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a4a:	68 ff 00 00 00       	push   $0xff
80103a4f:	68 a1 00 00 00       	push   $0xa1
80103a54:	e8 be ff ff ff       	call   80103a17 <outb>
80103a59:	83 c4 08             	add    $0x8,%esp
}
80103a5c:	90                   	nop
80103a5d:	c9                   	leave  
80103a5e:	c3                   	ret    

80103a5f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a5f:	55                   	push   %ebp
80103a60:	89 e5                	mov    %esp,%ebp
80103a62:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a75:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a78:	8b 10                	mov    (%eax),%edx
80103a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a7f:	e8 67 d5 ff ff       	call   80100feb <filealloc>
80103a84:	8b 55 08             	mov    0x8(%ebp),%edx
80103a87:	89 02                	mov    %eax,(%edx)
80103a89:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8c:	8b 00                	mov    (%eax),%eax
80103a8e:	85 c0                	test   %eax,%eax
80103a90:	0f 84 c8 00 00 00    	je     80103b5e <pipealloc+0xff>
80103a96:	e8 50 d5 ff ff       	call   80100feb <filealloc>
80103a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a9e:	89 02                	mov    %eax,(%edx)
80103aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aa3:	8b 00                	mov    (%eax),%eax
80103aa5:	85 c0                	test   %eax,%eax
80103aa7:	0f 84 b1 00 00 00    	je     80103b5e <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103aad:	e8 e0 f1 ff ff       	call   80102c92 <kalloc>
80103ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ab5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ab9:	0f 84 a2 00 00 00    	je     80103b61 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ac9:	00 00 00 
  p->writeopen = 1;
80103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ad6:	00 00 00 
  p->nwrite = 0;
80103ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ae3:	00 00 00 
  p->nread = 0;
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103af0:	00 00 00 
  initlock(&p->lock, "pipe");
80103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 89 a8 10 80       	push   $0x8010a889
80103afe:	50                   	push   %eax
80103aff:	e8 d7 11 00 00       	call   80104cdb <initlock>
80103b04:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103b07:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0a:	8b 00                	mov    (%eax),%eax
80103b0c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b12:	8b 45 08             	mov    0x8(%ebp),%eax
80103b15:	8b 00                	mov    (%eax),%eax
80103b17:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1e:	8b 00                	mov    (%eax),%eax
80103b20:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b24:	8b 45 08             	mov    0x8(%ebp),%eax
80103b27:	8b 00                	mov    (%eax),%eax
80103b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b2c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b32:	8b 00                	mov    (%eax),%eax
80103b34:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b3d:	8b 00                	mov    (%eax),%eax
80103b3f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b43:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b46:	8b 00                	mov    (%eax),%eax
80103b48:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b4f:	8b 00                	mov    (%eax),%eax
80103b51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b54:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b57:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5c:	eb 51                	jmp    80103baf <pipealloc+0x150>
    goto bad;
80103b5e:	90                   	nop
80103b5f:	eb 01                	jmp    80103b62 <pipealloc+0x103>
    goto bad;
80103b61:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b66:	74 0e                	je     80103b76 <pipealloc+0x117>
    kfree((char*)p);
80103b68:	83 ec 0c             	sub    $0xc,%esp
80103b6b:	ff 75 f4             	push   -0xc(%ebp)
80103b6e:	e8 85 f0 ff ff       	call   80102bf8 <kfree>
80103b73:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b76:	8b 45 08             	mov    0x8(%ebp),%eax
80103b79:	8b 00                	mov    (%eax),%eax
80103b7b:	85 c0                	test   %eax,%eax
80103b7d:	74 11                	je     80103b90 <pipealloc+0x131>
    fileclose(*f0);
80103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b82:	8b 00                	mov    (%eax),%eax
80103b84:	83 ec 0c             	sub    $0xc,%esp
80103b87:	50                   	push   %eax
80103b88:	e8 1c d5 ff ff       	call   801010a9 <fileclose>
80103b8d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b90:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b93:	8b 00                	mov    (%eax),%eax
80103b95:	85 c0                	test   %eax,%eax
80103b97:	74 11                	je     80103baa <pipealloc+0x14b>
    fileclose(*f1);
80103b99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b9c:	8b 00                	mov    (%eax),%eax
80103b9e:	83 ec 0c             	sub    $0xc,%esp
80103ba1:	50                   	push   %eax
80103ba2:	e8 02 d5 ff ff       	call   801010a9 <fileclose>
80103ba7:	83 c4 10             	add    $0x10,%esp
  return -1;
80103baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103baf:	c9                   	leave  
80103bb0:	c3                   	ret    

80103bb1 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103bb1:	55                   	push   %ebp
80103bb2:	89 e5                	mov    %esp,%ebp
80103bb4:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103bba:	83 ec 0c             	sub    $0xc,%esp
80103bbd:	50                   	push   %eax
80103bbe:	e8 3a 11 00 00       	call   80104cfd <acquire>
80103bc3:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bca:	74 23                	je     80103bef <pipeclose+0x3e>
    p->writeopen = 0;
80103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcf:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bd6:	00 00 00 
    wakeup(&p->nread);
80103bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdc:	05 34 02 00 00       	add    $0x234,%eax
80103be1:	83 ec 0c             	sub    $0xc,%esp
80103be4:	50                   	push   %eax
80103be5:	e8 c8 0c 00 00       	call   801048b2 <wakeup>
80103bea:	83 c4 10             	add    $0x10,%esp
80103bed:	eb 21                	jmp    80103c10 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103bef:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf2:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103bf9:	00 00 00 
    wakeup(&p->nwrite);
80103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bff:	05 38 02 00 00       	add    $0x238,%eax
80103c04:	83 ec 0c             	sub    $0xc,%esp
80103c07:	50                   	push   %eax
80103c08:	e8 a5 0c 00 00       	call   801048b2 <wakeup>
80103c0d:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c10:	8b 45 08             	mov    0x8(%ebp),%eax
80103c13:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c19:	85 c0                	test   %eax,%eax
80103c1b:	75 2c                	jne    80103c49 <pipeclose+0x98>
80103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c20:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c26:	85 c0                	test   %eax,%eax
80103c28:	75 1f                	jne    80103c49 <pipeclose+0x98>
    release(&p->lock);
80103c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2d:	83 ec 0c             	sub    $0xc,%esp
80103c30:	50                   	push   %eax
80103c31:	e8 35 11 00 00       	call   80104d6b <release>
80103c36:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c39:	83 ec 0c             	sub    $0xc,%esp
80103c3c:	ff 75 08             	push   0x8(%ebp)
80103c3f:	e8 b4 ef ff ff       	call   80102bf8 <kfree>
80103c44:	83 c4 10             	add    $0x10,%esp
80103c47:	eb 10                	jmp    80103c59 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c49:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4c:	83 ec 0c             	sub    $0xc,%esp
80103c4f:	50                   	push   %eax
80103c50:	e8 16 11 00 00       	call   80104d6b <release>
80103c55:	83 c4 10             	add    $0x10,%esp
}
80103c58:	90                   	nop
80103c59:	90                   	nop
80103c5a:	c9                   	leave  
80103c5b:	c3                   	ret    

80103c5c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c5c:	55                   	push   %ebp
80103c5d:	89 e5                	mov    %esp,%ebp
80103c5f:	53                   	push   %ebx
80103c60:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c63:	8b 45 08             	mov    0x8(%ebp),%eax
80103c66:	83 ec 0c             	sub    $0xc,%esp
80103c69:	50                   	push   %eax
80103c6a:	e8 8e 10 00 00       	call   80104cfd <acquire>
80103c6f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c79:	e9 ad 00 00 00       	jmp    80103d2b <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c81:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c87:	85 c0                	test   %eax,%eax
80103c89:	74 0c                	je     80103c97 <pipewrite+0x3b>
80103c8b:	e8 92 02 00 00       	call   80103f22 <myproc>
80103c90:	8b 40 24             	mov    0x24(%eax),%eax
80103c93:	85 c0                	test   %eax,%eax
80103c95:	74 19                	je     80103cb0 <pipewrite+0x54>
        release(&p->lock);
80103c97:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9a:	83 ec 0c             	sub    $0xc,%esp
80103c9d:	50                   	push   %eax
80103c9e:	e8 c8 10 00 00       	call   80104d6b <release>
80103ca3:	83 c4 10             	add    $0x10,%esp
        return -1;
80103ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cab:	e9 a9 00 00 00       	jmp    80103d59 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb3:	05 34 02 00 00       	add    $0x234,%eax
80103cb8:	83 ec 0c             	sub    $0xc,%esp
80103cbb:	50                   	push   %eax
80103cbc:	e8 f1 0b 00 00       	call   801048b2 <wakeup>
80103cc1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cca:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cd0:	83 ec 08             	sub    $0x8,%esp
80103cd3:	50                   	push   %eax
80103cd4:	52                   	push   %edx
80103cd5:	e8 f1 0a 00 00       	call   801047cb <sleep>
80103cda:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103cef:	05 00 02 00 00       	add    $0x200,%eax
80103cf4:	39 c2                	cmp    %eax,%edx
80103cf6:	74 86                	je     80103c7e <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfe:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103d01:	8b 45 08             	mov    0x8(%ebp),%eax
80103d04:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103d0a:	8d 48 01             	lea    0x1(%eax),%ecx
80103d0d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d10:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d16:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d1b:	89 c1                	mov    %eax,%ecx
80103d1d:	0f b6 13             	movzbl (%ebx),%edx
80103d20:	8b 45 08             	mov    0x8(%ebp),%eax
80103d23:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2e:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d31:	7c aa                	jl     80103cdd <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d33:	8b 45 08             	mov    0x8(%ebp),%eax
80103d36:	05 34 02 00 00       	add    $0x234,%eax
80103d3b:	83 ec 0c             	sub    $0xc,%esp
80103d3e:	50                   	push   %eax
80103d3f:	e8 6e 0b 00 00       	call   801048b2 <wakeup>
80103d44:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d47:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4a:	83 ec 0c             	sub    $0xc,%esp
80103d4d:	50                   	push   %eax
80103d4e:	e8 18 10 00 00       	call   80104d6b <release>
80103d53:	83 c4 10             	add    $0x10,%esp
  return n;
80103d56:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d5c:	c9                   	leave  
80103d5d:	c3                   	ret    

80103d5e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d5e:	55                   	push   %ebp
80103d5f:	89 e5                	mov    %esp,%ebp
80103d61:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d64:	8b 45 08             	mov    0x8(%ebp),%eax
80103d67:	83 ec 0c             	sub    $0xc,%esp
80103d6a:	50                   	push   %eax
80103d6b:	e8 8d 0f 00 00       	call   80104cfd <acquire>
80103d70:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d73:	eb 3e                	jmp    80103db3 <piperead+0x55>
    if(myproc()->killed){
80103d75:	e8 a8 01 00 00       	call   80103f22 <myproc>
80103d7a:	8b 40 24             	mov    0x24(%eax),%eax
80103d7d:	85 c0                	test   %eax,%eax
80103d7f:	74 19                	je     80103d9a <piperead+0x3c>
      release(&p->lock);
80103d81:	8b 45 08             	mov    0x8(%ebp),%eax
80103d84:	83 ec 0c             	sub    $0xc,%esp
80103d87:	50                   	push   %eax
80103d88:	e8 de 0f 00 00       	call   80104d6b <release>
80103d8d:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d95:	e9 be 00 00 00       	jmp    80103e58 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9d:	8b 55 08             	mov    0x8(%ebp),%edx
80103da0:	81 c2 34 02 00 00    	add    $0x234,%edx
80103da6:	83 ec 08             	sub    $0x8,%esp
80103da9:	50                   	push   %eax
80103daa:	52                   	push   %edx
80103dab:	e8 1b 0a 00 00       	call   801047cb <sleep>
80103db0:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103db3:	8b 45 08             	mov    0x8(%ebp),%eax
80103db6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103dc5:	39 c2                	cmp    %eax,%edx
80103dc7:	75 0d                	jne    80103dd6 <piperead+0x78>
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	75 9f                	jne    80103d75 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ddd:	eb 48                	jmp    80103e27 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80103de2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103de8:	8b 45 08             	mov    0x8(%ebp),%eax
80103deb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103df1:	39 c2                	cmp    %eax,%edx
80103df3:	74 3c                	je     80103e31 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103df5:	8b 45 08             	mov    0x8(%ebp),%eax
80103df8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103dfe:	8d 48 01             	lea    0x1(%eax),%ecx
80103e01:	8b 55 08             	mov    0x8(%ebp),%edx
80103e04:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103e0a:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e0f:	89 c1                	mov    %eax,%ecx
80103e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e17:	01 c2                	add    %eax,%edx
80103e19:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1c:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e21:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e2d:	7c b0                	jl     80103ddf <piperead+0x81>
80103e2f:	eb 01                	jmp    80103e32 <piperead+0xd4>
      break;
80103e31:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e32:	8b 45 08             	mov    0x8(%ebp),%eax
80103e35:	05 38 02 00 00       	add    $0x238,%eax
80103e3a:	83 ec 0c             	sub    $0xc,%esp
80103e3d:	50                   	push   %eax
80103e3e:	e8 6f 0a 00 00       	call   801048b2 <wakeup>
80103e43:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e46:	8b 45 08             	mov    0x8(%ebp),%eax
80103e49:	83 ec 0c             	sub    $0xc,%esp
80103e4c:	50                   	push   %eax
80103e4d:	e8 19 0f 00 00       	call   80104d6b <release>
80103e52:	83 c4 10             	add    $0x10,%esp
  return i;
80103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e58:	c9                   	leave  
80103e59:	c3                   	ret    

80103e5a <readeflags>:
{
80103e5a:	55                   	push   %ebp
80103e5b:	89 e5                	mov    %esp,%ebp
80103e5d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e60:	9c                   	pushf  
80103e61:	58                   	pop    %eax
80103e62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e68:	c9                   	leave  
80103e69:	c3                   	ret    

80103e6a <sti>:
{
80103e6a:	55                   	push   %ebp
80103e6b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e6d:	fb                   	sti    
}
80103e6e:	90                   	nop
80103e6f:	5d                   	pop    %ebp
80103e70:	c3                   	ret    

80103e71 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e71:	55                   	push   %ebp
80103e72:	89 e5                	mov    %esp,%ebp
80103e74:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e77:	83 ec 08             	sub    $0x8,%esp
80103e7a:	68 90 a8 10 80       	push   $0x8010a890
80103e7f:	68 40 72 11 80       	push   $0x80117240
80103e84:	e8 52 0e 00 00       	call   80104cdb <initlock>
80103e89:	83 c4 10             	add    $0x10,%esp
}
80103e8c:	90                   	nop
80103e8d:	c9                   	leave  
80103e8e:	c3                   	ret    

80103e8f <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e8f:	55                   	push   %ebp
80103e90:	89 e5                	mov    %esp,%ebp
80103e92:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e95:	e8 10 00 00 00       	call   80103eaa <mycpu>
80103e9a:	2d c0 99 11 80       	sub    $0x801199c0,%eax
80103e9f:	c1 f8 04             	sar    $0x4,%eax
80103ea2:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103ea8:	c9                   	leave  
80103ea9:	c3                   	ret    

80103eaa <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103eaa:	55                   	push   %ebp
80103eab:	89 e5                	mov    %esp,%ebp
80103ead:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103eb0:	e8 a5 ff ff ff       	call   80103e5a <readeflags>
80103eb5:	25 00 02 00 00       	and    $0x200,%eax
80103eba:	85 c0                	test   %eax,%eax
80103ebc:	74 0d                	je     80103ecb <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103ebe:	83 ec 0c             	sub    $0xc,%esp
80103ec1:	68 98 a8 10 80       	push   $0x8010a898
80103ec6:	e8 f6 c6 ff ff       	call   801005c1 <panic>
  }

  apicid = lapicid();
80103ecb:	e8 1c f1 ff ff       	call   80102fec <lapicid>
80103ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ed3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103eda:	eb 2d                	jmp    80103f09 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103edf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ee5:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103eea:	0f b6 00             	movzbl (%eax),%eax
80103eed:	0f b6 c0             	movzbl %al,%eax
80103ef0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ef3:	75 10                	jne    80103f05 <mycpu+0x5b>
      return &cpus[i];
80103ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103efe:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103f03:	eb 1b                	jmp    80103f20 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103f05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f09:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80103f0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f11:	7c c9                	jl     80103edc <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f13:	83 ec 0c             	sub    $0xc,%esp
80103f16:	68 be a8 10 80       	push   $0x8010a8be
80103f1b:	e8 a1 c6 ff ff       	call   801005c1 <panic>
}
80103f20:	c9                   	leave  
80103f21:	c3                   	ret    

80103f22 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f22:	55                   	push   %ebp
80103f23:	89 e5                	mov    %esp,%ebp
80103f25:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f28:	e8 3b 0f 00 00       	call   80104e68 <pushcli>
  c = mycpu();
80103f2d:	e8 78 ff ff ff       	call   80103eaa <mycpu>
80103f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f38:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f41:	e8 6f 0f 00 00       	call   80104eb5 <popcli>
  return p;
80103f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f49:	c9                   	leave  
80103f4a:	c3                   	ret    

80103f4b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f4b:	55                   	push   %ebp
80103f4c:	89 e5                	mov    %esp,%ebp
80103f4e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f51:	83 ec 0c             	sub    $0xc,%esp
80103f54:	68 40 72 11 80       	push   $0x80117240
80103f59:	e8 9f 0d 00 00       	call   80104cfd <acquire>
80103f5e:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f61:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f68:	eb 0e                	jmp    80103f78 <allocproc+0x2d>
    if(p->state == UNUSED){
80103f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6d:	8b 40 0c             	mov    0xc(%eax),%eax
80103f70:	85 c0                	test   %eax,%eax
80103f72:	74 27                	je     80103f9b <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f74:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f78:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80103f7f:	72 e9                	jb     80103f6a <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f81:	83 ec 0c             	sub    $0xc,%esp
80103f84:	68 40 72 11 80       	push   $0x80117240
80103f89:	e8 dd 0d 00 00       	call   80104d6b <release>
80103f8e:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f91:	b8 00 00 00 00       	mov    $0x0,%eax
80103f96:	e9 b2 00 00 00       	jmp    8010404d <allocproc+0x102>
      goto found;
80103f9b:	90                   	nop

found:
  p->state = EMBRYO;
80103f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103fa6:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103fab:	8d 50 01             	lea    0x1(%eax),%edx
80103fae:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fb7:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103fba:	83 ec 0c             	sub    $0xc,%esp
80103fbd:	68 40 72 11 80       	push   $0x80117240
80103fc2:	e8 a4 0d 00 00       	call   80104d6b <release>
80103fc7:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fca:	e8 c3 ec ff ff       	call   80102c92 <kalloc>
80103fcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fd2:	89 42 08             	mov    %eax,0x8(%edx)
80103fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd8:	8b 40 08             	mov    0x8(%eax),%eax
80103fdb:	85 c0                	test   %eax,%eax
80103fdd:	75 11                	jne    80103ff0 <allocproc+0xa5>
    p->state = UNUSED;
80103fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fe9:	b8 00 00 00 00       	mov    $0x0,%eax
80103fee:	eb 5d                	jmp    8010404d <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff3:	8b 40 08             	mov    0x8(%eax),%eax
80103ff6:	05 00 10 00 00       	add    $0x1000,%eax
80103ffb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ffe:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104005:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104008:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010400b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010400f:	ba 09 63 10 80       	mov    $0x80106309,%edx
80104014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104017:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104019:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010401d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104020:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104023:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104029:	8b 40 1c             	mov    0x1c(%eax),%eax
8010402c:	83 ec 04             	sub    $0x4,%esp
8010402f:	6a 14                	push   $0x14
80104031:	6a 00                	push   $0x0
80104033:	50                   	push   %eax
80104034:	e8 3a 0f 00 00       	call   80104f73 <memset>
80104039:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104042:	ba 85 47 10 80       	mov    $0x80104785,%edx
80104047:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010404d:	c9                   	leave  
8010404e:	c3                   	ret    

8010404f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010404f:	55                   	push   %ebp
80104050:	89 e5                	mov    %esp,%ebp
80104052:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104055:	e8 f1 fe ff ff       	call   80103f4b <allocproc>
8010405a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	a3 74 91 11 80       	mov    %eax,0x80119174
  if((p->pgdir = setupkvm()) == 0){
80104065:	e8 ac 38 00 00       	call   80107916 <setupkvm>
8010406a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406d:	89 42 04             	mov    %eax,0x4(%edx)
80104070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104073:	8b 40 04             	mov    0x4(%eax),%eax
80104076:	85 c0                	test   %eax,%eax
80104078:	75 0d                	jne    80104087 <userinit+0x38>
    panic("userinit: out of memory?");
8010407a:	83 ec 0c             	sub    $0xc,%esp
8010407d:	68 ce a8 10 80       	push   $0x8010a8ce
80104082:	e8 3a c5 ff ff       	call   801005c1 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104087:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010408c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408f:	8b 40 04             	mov    0x4(%eax),%eax
80104092:	83 ec 04             	sub    $0x4,%esp
80104095:	52                   	push   %edx
80104096:	68 ec f4 10 80       	push   $0x8010f4ec
8010409b:	50                   	push   %eax
8010409c:	e8 31 3b 00 00       	call   80107bd2 <inituvm>
801040a1:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801040a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801040ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b0:	8b 40 18             	mov    0x18(%eax),%eax
801040b3:	83 ec 04             	sub    $0x4,%esp
801040b6:	6a 4c                	push   $0x4c
801040b8:	6a 00                	push   $0x0
801040ba:	50                   	push   %eax
801040bb:	e8 b3 0e 00 00       	call   80104f73 <memset>
801040c0:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c6:	8b 40 18             	mov    0x18(%eax),%eax
801040c9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d2:	8b 40 18             	mov    0x18(%eax),%eax
801040d5:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040de:	8b 50 18             	mov    0x18(%eax),%edx
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	8b 40 18             	mov    0x18(%eax),%eax
801040e7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040eb:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f2:	8b 50 18             	mov    0x18(%eax),%edx
801040f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f8:	8b 40 18             	mov    0x18(%eax),%eax
801040fb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040ff:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104106:	8b 40 18             	mov    0x18(%eax),%eax
80104109:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104113:	8b 40 18             	mov    0x18(%eax),%eax
80104116:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	8b 40 18             	mov    0x18(%eax),%eax
80104123:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010412a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412d:	83 c0 6c             	add    $0x6c,%eax
80104130:	83 ec 04             	sub    $0x4,%esp
80104133:	6a 10                	push   $0x10
80104135:	68 e7 a8 10 80       	push   $0x8010a8e7
8010413a:	50                   	push   %eax
8010413b:	e8 36 10 00 00       	call   80105176 <safestrcpy>
80104140:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104143:	83 ec 0c             	sub    $0xc,%esp
80104146:	68 f0 a8 10 80       	push   $0x8010a8f0
8010414b:	e8 db e3 ff ff       	call   8010252b <namei>
80104150:	83 c4 10             	add    $0x10,%esp
80104153:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104156:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104159:	83 ec 0c             	sub    $0xc,%esp
8010415c:	68 40 72 11 80       	push   $0x80117240
80104161:	e8 97 0b 00 00       	call   80104cfd <acquire>
80104166:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104173:	83 ec 0c             	sub    $0xc,%esp
80104176:	68 40 72 11 80       	push   $0x80117240
8010417b:	e8 eb 0b 00 00       	call   80104d6b <release>
80104180:	83 c4 10             	add    $0x10,%esp
}
80104183:	90                   	nop
80104184:	c9                   	leave  
80104185:	c3                   	ret    

80104186 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104186:	55                   	push   %ebp
80104187:	89 e5                	mov    %esp,%ebp
80104189:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010418c:	e8 91 fd ff ff       	call   80103f22 <myproc>
80104191:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104197:	8b 00                	mov    (%eax),%eax
80104199:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010419c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041a0:	7e 2e                	jle    801041d0 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041a2:	8b 55 08             	mov    0x8(%ebp),%edx
801041a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a8:	01 c2                	add    %eax,%edx
801041aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041ad:	8b 40 04             	mov    0x4(%eax),%eax
801041b0:	83 ec 04             	sub    $0x4,%esp
801041b3:	52                   	push   %edx
801041b4:	ff 75 f4             	push   -0xc(%ebp)
801041b7:	50                   	push   %eax
801041b8:	e8 52 3b 00 00       	call   80107d0f <allocuvm>
801041bd:	83 c4 10             	add    $0x10,%esp
801041c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041c7:	75 3b                	jne    80104204 <growproc+0x7e>
      return -1;
801041c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ce:	eb 4f                	jmp    8010421f <growproc+0x99>
  } else if(n < 0){
801041d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041d4:	79 2e                	jns    80104204 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041d6:	8b 55 08             	mov    0x8(%ebp),%edx
801041d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041dc:	01 c2                	add    %eax,%edx
801041de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041e1:	8b 40 04             	mov    0x4(%eax),%eax
801041e4:	83 ec 04             	sub    $0x4,%esp
801041e7:	52                   	push   %edx
801041e8:	ff 75 f4             	push   -0xc(%ebp)
801041eb:	50                   	push   %eax
801041ec:	e8 23 3c 00 00       	call   80107e14 <deallocuvm>
801041f1:	83 c4 10             	add    $0x10,%esp
801041f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041fb:	75 07                	jne    80104204 <growproc+0x7e>
      return -1;
801041fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104202:	eb 1b                	jmp    8010421f <growproc+0x99>
  }
  curproc->sz = sz;
80104204:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104207:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420a:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010420c:	83 ec 0c             	sub    $0xc,%esp
8010420f:	ff 75 f0             	push   -0x10(%ebp)
80104212:	e8 1c 38 00 00       	call   80107a33 <switchuvm>
80104217:	83 c4 10             	add    $0x10,%esp
  return 0;
8010421a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010421f:	c9                   	leave  
80104220:	c3                   	ret    

80104221 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104221:	55                   	push   %ebp
80104222:	89 e5                	mov    %esp,%ebp
80104224:	57                   	push   %edi
80104225:	56                   	push   %esi
80104226:	53                   	push   %ebx
80104227:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010422a:	e8 f3 fc ff ff       	call   80103f22 <myproc>
8010422f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104232:	e8 14 fd ff ff       	call   80103f4b <allocproc>
80104237:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010423a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010423e:	75 0a                	jne    8010424a <fork+0x29>
    return -1;
80104240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104245:	e9 48 01 00 00       	jmp    80104392 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010424a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010424d:	8b 10                	mov    (%eax),%edx
8010424f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104252:	8b 40 04             	mov    0x4(%eax),%eax
80104255:	83 ec 08             	sub    $0x8,%esp
80104258:	52                   	push   %edx
80104259:	50                   	push   %eax
8010425a:	e8 53 3d 00 00       	call   80107fb2 <copyuvm>
8010425f:	83 c4 10             	add    $0x10,%esp
80104262:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104265:	89 42 04             	mov    %eax,0x4(%edx)
80104268:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010426b:	8b 40 04             	mov    0x4(%eax),%eax
8010426e:	85 c0                	test   %eax,%eax
80104270:	75 30                	jne    801042a2 <fork+0x81>
    kfree(np->kstack);
80104272:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104275:	8b 40 08             	mov    0x8(%eax),%eax
80104278:	83 ec 0c             	sub    $0xc,%esp
8010427b:	50                   	push   %eax
8010427c:	e8 77 e9 ff ff       	call   80102bf8 <kfree>
80104281:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104284:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104287:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010428e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104291:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010429d:	e9 f0 00 00 00       	jmp    80104392 <fork+0x171>
  }
  np->sz = curproc->sz;
801042a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042a5:	8b 10                	mov    (%eax),%edx
801042a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042aa:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801042ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042af:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042b2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042b8:	8b 48 18             	mov    0x18(%eax),%ecx
801042bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042be:	8b 40 18             	mov    0x18(%eax),%eax
801042c1:	89 c2                	mov    %eax,%edx
801042c3:	89 cb                	mov    %ecx,%ebx
801042c5:	b8 13 00 00 00       	mov    $0x13,%eax
801042ca:	89 d7                	mov    %edx,%edi
801042cc:	89 de                	mov    %ebx,%esi
801042ce:	89 c1                	mov    %eax,%ecx
801042d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042d5:	8b 40 18             	mov    0x18(%eax),%eax
801042d8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042e6:	eb 3b                	jmp    80104323 <fork+0x102>
    if(curproc->ofile[i])
801042e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042ee:	83 c2 08             	add    $0x8,%edx
801042f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f5:	85 c0                	test   %eax,%eax
801042f7:	74 26                	je     8010431f <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042ff:	83 c2 08             	add    $0x8,%edx
80104302:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	50                   	push   %eax
8010430a:	e8 49 cd ff ff       	call   80101058 <filedup>
8010430f:	83 c4 10             	add    $0x10,%esp
80104312:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104315:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104318:	83 c1 08             	add    $0x8,%ecx
8010431b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010431f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104323:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104327:	7e bf                	jle    801042e8 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104329:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010432c:	8b 40 68             	mov    0x68(%eax),%eax
8010432f:	83 ec 0c             	sub    $0xc,%esp
80104332:	50                   	push   %eax
80104333:	e8 86 d6 ff ff       	call   801019be <idup>
80104338:	83 c4 10             	add    $0x10,%esp
8010433b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010433e:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104341:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104344:	8d 50 6c             	lea    0x6c(%eax),%edx
80104347:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010434a:	83 c0 6c             	add    $0x6c,%eax
8010434d:	83 ec 04             	sub    $0x4,%esp
80104350:	6a 10                	push   $0x10
80104352:	52                   	push   %edx
80104353:	50                   	push   %eax
80104354:	e8 1d 0e 00 00       	call   80105176 <safestrcpy>
80104359:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010435c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010435f:	8b 40 10             	mov    0x10(%eax),%eax
80104362:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104365:	83 ec 0c             	sub    $0xc,%esp
80104368:	68 40 72 11 80       	push   $0x80117240
8010436d:	e8 8b 09 00 00       	call   80104cfd <acquire>
80104372:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104375:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104378:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010437f:	83 ec 0c             	sub    $0xc,%esp
80104382:	68 40 72 11 80       	push   $0x80117240
80104387:	e8 df 09 00 00       	call   80104d6b <release>
8010438c:	83 c4 10             	add    $0x10,%esp

  return pid;
8010438f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104392:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104395:	5b                   	pop    %ebx
80104396:	5e                   	pop    %esi
80104397:	5f                   	pop    %edi
80104398:	5d                   	pop    %ebp
80104399:	c3                   	ret    

8010439a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010439a:	55                   	push   %ebp
8010439b:	89 e5                	mov    %esp,%ebp
8010439d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043a0:	e8 7d fb ff ff       	call   80103f22 <myproc>
801043a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801043a8:	a1 74 91 11 80       	mov    0x80119174,%eax
801043ad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043b0:	75 0d                	jne    801043bf <exit+0x25>
    panic("init exiting");
801043b2:	83 ec 0c             	sub    $0xc,%esp
801043b5:	68 f2 a8 10 80       	push   $0x8010a8f2
801043ba:	e8 02 c2 ff ff       	call   801005c1 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043c6:	eb 3f                	jmp    80104407 <exit+0x6d>
    if(curproc->ofile[fd]){
801043c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ce:	83 c2 08             	add    $0x8,%edx
801043d1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d5:	85 c0                	test   %eax,%eax
801043d7:	74 2a                	je     80104403 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043df:	83 c2 08             	add    $0x8,%edx
801043e2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	50                   	push   %eax
801043ea:	e8 ba cc ff ff       	call   801010a9 <fileclose>
801043ef:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f8:	83 c2 08             	add    $0x8,%edx
801043fb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104402:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104403:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104407:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010440b:	7e bb                	jle    801043c8 <exit+0x2e>
    }
  }

  begin_op();
8010440d:	e8 1c f1 ff ff       	call   8010352e <begin_op>
  iput(curproc->cwd);
80104412:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104415:	8b 40 68             	mov    0x68(%eax),%eax
80104418:	83 ec 0c             	sub    $0xc,%esp
8010441b:	50                   	push   %eax
8010441c:	e8 38 d7 ff ff       	call   80101b59 <iput>
80104421:	83 c4 10             	add    $0x10,%esp
  end_op();
80104424:	e8 91 f1 ff ff       	call   801035ba <end_op>
  curproc->cwd = 0;
80104429:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010442c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104433:	83 ec 0c             	sub    $0xc,%esp
80104436:	68 40 72 11 80       	push   $0x80117240
8010443b:	e8 bd 08 00 00       	call   80104cfd <acquire>
80104440:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104443:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104446:	8b 40 14             	mov    0x14(%eax),%eax
80104449:	83 ec 0c             	sub    $0xc,%esp
8010444c:	50                   	push   %eax
8010444d:	e8 20 04 00 00       	call   80104872 <wakeup1>
80104452:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104455:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010445c:	eb 37                	jmp    80104495 <exit+0xfb>
    if(p->parent == curproc){
8010445e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104461:	8b 40 14             	mov    0x14(%eax),%eax
80104464:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104467:	75 28                	jne    80104491 <exit+0xf7>
      p->parent = initproc;
80104469:	8b 15 74 91 11 80    	mov    0x80119174,%edx
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	8b 40 0c             	mov    0xc(%eax),%eax
8010447b:	83 f8 05             	cmp    $0x5,%eax
8010447e:	75 11                	jne    80104491 <exit+0xf7>
        wakeup1(initproc);
80104480:	a1 74 91 11 80       	mov    0x80119174,%eax
80104485:	83 ec 0c             	sub    $0xc,%esp
80104488:	50                   	push   %eax
80104489:	e8 e4 03 00 00       	call   80104872 <wakeup1>
8010448e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104491:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104495:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010449c:	72 c0                	jb     8010445e <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010449e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044a1:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801044a8:	e8 e5 01 00 00       	call   80104692 <sched>
  panic("zombie exit");
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	68 ff a8 10 80       	push   $0x8010a8ff
801044b5:	e8 07 c1 ff ff       	call   801005c1 <panic>

801044ba <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044ba:	55                   	push   %ebp
801044bb:	89 e5                	mov    %esp,%ebp
801044bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044c0:	e8 5d fa ff ff       	call   80103f22 <myproc>
801044c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044c8:	83 ec 0c             	sub    $0xc,%esp
801044cb:	68 40 72 11 80       	push   $0x80117240
801044d0:	e8 28 08 00 00       	call   80104cfd <acquire>
801044d5:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044df:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044e6:	e9 a1 00 00 00       	jmp    8010458c <wait+0xd2>
      if(p->parent != curproc)
801044eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ee:	8b 40 14             	mov    0x14(%eax),%eax
801044f1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044f4:	0f 85 8d 00 00 00    	jne    80104587 <wait+0xcd>
        continue;
      havekids = 1;
801044fa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 0c             	mov    0xc(%eax),%eax
80104507:	83 f8 05             	cmp    $0x5,%eax
8010450a:	75 7c                	jne    80104588 <wait+0xce>
        // Found one.
        pid = p->pid;
8010450c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450f:	8b 40 10             	mov    0x10(%eax),%eax
80104512:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 08             	mov    0x8(%eax),%eax
8010451b:	83 ec 0c             	sub    $0xc,%esp
8010451e:	50                   	push   %eax
8010451f:	e8 d4 e6 ff ff       	call   80102bf8 <kfree>
80104524:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	8b 40 04             	mov    0x4(%eax),%eax
80104537:	83 ec 0c             	sub    $0xc,%esp
8010453a:	50                   	push   %eax
8010453b:	e8 98 39 00 00       	call   80107ed8 <freevm>
80104540:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104561:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	68 40 72 11 80       	push   $0x80117240
8010457a:	e8 ec 07 00 00       	call   80104d6b <release>
8010457f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104582:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104585:	eb 51                	jmp    801045d8 <wait+0x11e>
        continue;
80104587:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104588:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010458c:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104593:	0f 82 52 ff ff ff    	jb     801044eb <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104599:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010459d:	74 0a                	je     801045a9 <wait+0xef>
8010459f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045a2:	8b 40 24             	mov    0x24(%eax),%eax
801045a5:	85 c0                	test   %eax,%eax
801045a7:	74 17                	je     801045c0 <wait+0x106>
      release(&ptable.lock);
801045a9:	83 ec 0c             	sub    $0xc,%esp
801045ac:	68 40 72 11 80       	push   $0x80117240
801045b1:	e8 b5 07 00 00       	call   80104d6b <release>
801045b6:	83 c4 10             	add    $0x10,%esp
      return -1;
801045b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045be:	eb 18                	jmp    801045d8 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045c0:	83 ec 08             	sub    $0x8,%esp
801045c3:	68 40 72 11 80       	push   $0x80117240
801045c8:	ff 75 ec             	push   -0x14(%ebp)
801045cb:	e8 fb 01 00 00       	call   801047cb <sleep>
801045d0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045d3:	e9 00 ff ff ff       	jmp    801044d8 <wait+0x1e>
  }
}
801045d8:	c9                   	leave  
801045d9:	c3                   	ret    

801045da <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045da:	55                   	push   %ebp
801045db:	89 e5                	mov    %esp,%ebp
801045dd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045e0:	e8 c5 f8 ff ff       	call   80103eaa <mycpu>
801045e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045eb:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045f2:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045f5:	e8 70 f8 ff ff       	call   80103e6a <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045fa:	83 ec 0c             	sub    $0xc,%esp
801045fd:	68 40 72 11 80       	push   $0x80117240
80104602:	e8 f6 06 00 00       	call   80104cfd <acquire>
80104607:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010460a:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104611:	eb 61                	jmp    80104674 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	8b 40 0c             	mov    0xc(%eax),%eax
80104619:	83 f8 03             	cmp    $0x3,%eax
8010461c:	75 51                	jne    8010466f <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010461e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104621:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104624:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010462a:	83 ec 0c             	sub    $0xc,%esp
8010462d:	ff 75 f4             	push   -0xc(%ebp)
80104630:	e8 fe 33 00 00       	call   80107a33 <switchuvm>
80104635:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104645:	8b 40 1c             	mov    0x1c(%eax),%eax
80104648:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010464b:	83 c2 04             	add    $0x4,%edx
8010464e:	83 ec 08             	sub    $0x8,%esp
80104651:	50                   	push   %eax
80104652:	52                   	push   %edx
80104653:	e8 90 0b 00 00       	call   801051e8 <swtch>
80104658:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010465b:	e8 ba 33 00 00       	call   80107a1a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104663:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010466a:	00 00 00 
8010466d:	eb 01                	jmp    80104670 <scheduler+0x96>
        continue;
8010466f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104670:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104674:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010467b:	72 96                	jb     80104613 <scheduler+0x39>
    }
    release(&ptable.lock);
8010467d:	83 ec 0c             	sub    $0xc,%esp
80104680:	68 40 72 11 80       	push   $0x80117240
80104685:	e8 e1 06 00 00       	call   80104d6b <release>
8010468a:	83 c4 10             	add    $0x10,%esp
    sti();
8010468d:	e9 63 ff ff ff       	jmp    801045f5 <scheduler+0x1b>

80104692 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104692:	55                   	push   %ebp
80104693:	89 e5                	mov    %esp,%ebp
80104695:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104698:	e8 85 f8 ff ff       	call   80103f22 <myproc>
8010469d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801046a0:	83 ec 0c             	sub    $0xc,%esp
801046a3:	68 40 72 11 80       	push   $0x80117240
801046a8:	e8 8b 07 00 00       	call   80104e38 <holding>
801046ad:	83 c4 10             	add    $0x10,%esp
801046b0:	85 c0                	test   %eax,%eax
801046b2:	75 0d                	jne    801046c1 <sched+0x2f>
    panic("sched ptable.lock");
801046b4:	83 ec 0c             	sub    $0xc,%esp
801046b7:	68 0b a9 10 80       	push   $0x8010a90b
801046bc:	e8 00 bf ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli != 1)
801046c1:	e8 e4 f7 ff ff       	call   80103eaa <mycpu>
801046c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046cc:	83 f8 01             	cmp    $0x1,%eax
801046cf:	74 0d                	je     801046de <sched+0x4c>
    panic("sched locks");
801046d1:	83 ec 0c             	sub    $0xc,%esp
801046d4:	68 1d a9 10 80       	push   $0x8010a91d
801046d9:	e8 e3 be ff ff       	call   801005c1 <panic>
  if(p->state == RUNNING)
801046de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e1:	8b 40 0c             	mov    0xc(%eax),%eax
801046e4:	83 f8 04             	cmp    $0x4,%eax
801046e7:	75 0d                	jne    801046f6 <sched+0x64>
    panic("sched running");
801046e9:	83 ec 0c             	sub    $0xc,%esp
801046ec:	68 29 a9 10 80       	push   $0x8010a929
801046f1:	e8 cb be ff ff       	call   801005c1 <panic>
  if(readeflags()&FL_IF)
801046f6:	e8 5f f7 ff ff       	call   80103e5a <readeflags>
801046fb:	25 00 02 00 00       	and    $0x200,%eax
80104700:	85 c0                	test   %eax,%eax
80104702:	74 0d                	je     80104711 <sched+0x7f>
    panic("sched interruptible");
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	68 37 a9 10 80       	push   $0x8010a937
8010470c:	e8 b0 be ff ff       	call   801005c1 <panic>
  intena = mycpu()->intena;
80104711:	e8 94 f7 ff ff       	call   80103eaa <mycpu>
80104716:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010471c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010471f:	e8 86 f7 ff ff       	call   80103eaa <mycpu>
80104724:	8b 40 04             	mov    0x4(%eax),%eax
80104727:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010472a:	83 c2 1c             	add    $0x1c,%edx
8010472d:	83 ec 08             	sub    $0x8,%esp
80104730:	50                   	push   %eax
80104731:	52                   	push   %edx
80104732:	e8 b1 0a 00 00       	call   801051e8 <swtch>
80104737:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010473a:	e8 6b f7 ff ff       	call   80103eaa <mycpu>
8010473f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104742:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104748:	90                   	nop
80104749:	c9                   	leave  
8010474a:	c3                   	ret    

8010474b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010474b:	55                   	push   %ebp
8010474c:	89 e5                	mov    %esp,%ebp
8010474e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104751:	83 ec 0c             	sub    $0xc,%esp
80104754:	68 40 72 11 80       	push   $0x80117240
80104759:	e8 9f 05 00 00       	call   80104cfd <acquire>
8010475e:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104761:	e8 bc f7 ff ff       	call   80103f22 <myproc>
80104766:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010476d:	e8 20 ff ff ff       	call   80104692 <sched>
  release(&ptable.lock);
80104772:	83 ec 0c             	sub    $0xc,%esp
80104775:	68 40 72 11 80       	push   $0x80117240
8010477a:	e8 ec 05 00 00       	call   80104d6b <release>
8010477f:	83 c4 10             	add    $0x10,%esp
}
80104782:	90                   	nop
80104783:	c9                   	leave  
80104784:	c3                   	ret    

80104785 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104785:	55                   	push   %ebp
80104786:	89 e5                	mov    %esp,%ebp
80104788:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010478b:	83 ec 0c             	sub    $0xc,%esp
8010478e:	68 40 72 11 80       	push   $0x80117240
80104793:	e8 d3 05 00 00       	call   80104d6b <release>
80104798:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010479b:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801047a0:	85 c0                	test   %eax,%eax
801047a2:	74 24                	je     801047c8 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801047a4:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801047ab:	00 00 00 
    iinit(ROOTDEV);
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	6a 01                	push   $0x1
801047b3:	e8 ce ce ff ff       	call   80101686 <iinit>
801047b8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	6a 01                	push   $0x1
801047c0:	e8 4a eb ff ff       	call   8010330f <initlog>
801047c5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047c8:	90                   	nop
801047c9:	c9                   	leave  
801047ca:	c3                   	ret    

801047cb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047cb:	55                   	push   %ebp
801047cc:	89 e5                	mov    %esp,%ebp
801047ce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047d1:	e8 4c f7 ff ff       	call   80103f22 <myproc>
801047d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047dd:	75 0d                	jne    801047ec <sleep+0x21>
    panic("sleep");
801047df:	83 ec 0c             	sub    $0xc,%esp
801047e2:	68 4b a9 10 80       	push   $0x8010a94b
801047e7:	e8 d5 bd ff ff       	call   801005c1 <panic>

  if(lk == 0)
801047ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047f0:	75 0d                	jne    801047ff <sleep+0x34>
    panic("sleep without lk");
801047f2:	83 ec 0c             	sub    $0xc,%esp
801047f5:	68 51 a9 10 80       	push   $0x8010a951
801047fa:	e8 c2 bd ff ff       	call   801005c1 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047ff:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104806:	74 1e                	je     80104826 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	68 40 72 11 80       	push   $0x80117240
80104810:	e8 e8 04 00 00       	call   80104cfd <acquire>
80104815:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104818:	83 ec 0c             	sub    $0xc,%esp
8010481b:	ff 75 0c             	push   0xc(%ebp)
8010481e:	e8 48 05 00 00       	call   80104d6b <release>
80104823:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104829:	8b 55 08             	mov    0x8(%ebp),%edx
8010482c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010482f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104832:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104839:	e8 54 fe ff ff       	call   80104692 <sched>

  // Tidy up.
  p->chan = 0;
8010483e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104841:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104848:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
8010484f:	74 1e                	je     8010486f <sleep+0xa4>
    release(&ptable.lock);
80104851:	83 ec 0c             	sub    $0xc,%esp
80104854:	68 40 72 11 80       	push   $0x80117240
80104859:	e8 0d 05 00 00       	call   80104d6b <release>
8010485e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104861:	83 ec 0c             	sub    $0xc,%esp
80104864:	ff 75 0c             	push   0xc(%ebp)
80104867:	e8 91 04 00 00       	call   80104cfd <acquire>
8010486c:	83 c4 10             	add    $0x10,%esp
  }
}
8010486f:	90                   	nop
80104870:	c9                   	leave  
80104871:	c3                   	ret    

80104872 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104872:	55                   	push   %ebp
80104873:	89 e5                	mov    %esp,%ebp
80104875:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104878:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
8010487f:	eb 24                	jmp    801048a5 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104881:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104884:	8b 40 0c             	mov    0xc(%eax),%eax
80104887:	83 f8 02             	cmp    $0x2,%eax
8010488a:	75 15                	jne    801048a1 <wakeup1+0x2f>
8010488c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488f:	8b 40 20             	mov    0x20(%eax),%eax
80104892:	39 45 08             	cmp    %eax,0x8(%ebp)
80104895:	75 0a                	jne    801048a1 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104897:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010489a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048a1:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801048a5:	81 7d fc 74 91 11 80 	cmpl   $0x80119174,-0x4(%ebp)
801048ac:	72 d3                	jb     80104881 <wakeup1+0xf>
}
801048ae:	90                   	nop
801048af:	90                   	nop
801048b0:	c9                   	leave  
801048b1:	c3                   	ret    

801048b2 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048b2:	55                   	push   %ebp
801048b3:	89 e5                	mov    %esp,%ebp
801048b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	68 40 72 11 80       	push   $0x80117240
801048c0:	e8 38 04 00 00       	call   80104cfd <acquire>
801048c5:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048c8:	83 ec 0c             	sub    $0xc,%esp
801048cb:	ff 75 08             	push   0x8(%ebp)
801048ce:	e8 9f ff ff ff       	call   80104872 <wakeup1>
801048d3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048d6:	83 ec 0c             	sub    $0xc,%esp
801048d9:	68 40 72 11 80       	push   $0x80117240
801048de:	e8 88 04 00 00       	call   80104d6b <release>
801048e3:	83 c4 10             	add    $0x10,%esp
}
801048e6:	90                   	nop
801048e7:	c9                   	leave  
801048e8:	c3                   	ret    

801048e9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048e9:	55                   	push   %ebp
801048ea:	89 e5                	mov    %esp,%ebp
801048ec:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048ef:	83 ec 0c             	sub    $0xc,%esp
801048f2:	68 40 72 11 80       	push   $0x80117240
801048f7:	e8 01 04 00 00       	call   80104cfd <acquire>
801048fc:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ff:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104906:	eb 45                	jmp    8010494d <kill+0x64>
    if(p->pid == pid){
80104908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490b:	8b 40 10             	mov    0x10(%eax),%eax
8010490e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104911:	75 36                	jne    80104949 <kill+0x60>
      p->killed = 1;
80104913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104916:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	8b 40 0c             	mov    0xc(%eax),%eax
80104923:	83 f8 02             	cmp    $0x2,%eax
80104926:	75 0a                	jne    80104932 <kill+0x49>
        p->state = RUNNABLE;
80104928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104932:	83 ec 0c             	sub    $0xc,%esp
80104935:	68 40 72 11 80       	push   $0x80117240
8010493a:	e8 2c 04 00 00       	call   80104d6b <release>
8010493f:	83 c4 10             	add    $0x10,%esp
      return 0;
80104942:	b8 00 00 00 00       	mov    $0x0,%eax
80104947:	eb 22                	jmp    8010496b <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104949:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010494d:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104954:	72 b2                	jb     80104908 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104956:	83 ec 0c             	sub    $0xc,%esp
80104959:	68 40 72 11 80       	push   $0x80117240
8010495e:	e8 08 04 00 00       	call   80104d6b <release>
80104963:	83 c4 10             	add    $0x10,%esp
  return -1;
80104966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010496b:	c9                   	leave  
8010496c:	c3                   	ret    

8010496d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010496d:	55                   	push   %ebp
8010496e:	89 e5                	mov    %esp,%ebp
80104970:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104973:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010497a:	e9 d7 00 00 00       	jmp    80104a56 <procdump+0xe9>
    if(p->state == UNUSED)
8010497f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104982:	8b 40 0c             	mov    0xc(%eax),%eax
80104985:	85 c0                	test   %eax,%eax
80104987:	0f 84 c4 00 00 00    	je     80104a51 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010498d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104990:	8b 40 0c             	mov    0xc(%eax),%eax
80104993:	83 f8 05             	cmp    $0x5,%eax
80104996:	77 23                	ja     801049bb <procdump+0x4e>
80104998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499b:	8b 40 0c             	mov    0xc(%eax),%eax
8010499e:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a5:	85 c0                	test   %eax,%eax
801049a7:	74 12                	je     801049bb <procdump+0x4e>
      state = states[p->state];
801049a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ac:	8b 40 0c             	mov    0xc(%eax),%eax
801049af:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049b9:	eb 07                	jmp    801049c2 <procdump+0x55>
    else
      state = "???";
801049bb:	c7 45 ec 62 a9 10 80 	movl   $0x8010a962,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c5:	8d 50 6c             	lea    0x6c(%eax),%edx
801049c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049cb:	8b 40 10             	mov    0x10(%eax),%eax
801049ce:	52                   	push   %edx
801049cf:	ff 75 ec             	push   -0x14(%ebp)
801049d2:	50                   	push   %eax
801049d3:	68 66 a9 10 80       	push   $0x8010a966
801049d8:	e8 17 ba ff ff       	call   801003f4 <cprintf>
801049dd:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e3:	8b 40 0c             	mov    0xc(%eax),%eax
801049e6:	83 f8 02             	cmp    $0x2,%eax
801049e9:	75 54                	jne    80104a3f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801049f1:	8b 40 0c             	mov    0xc(%eax),%eax
801049f4:	83 c0 08             	add    $0x8,%eax
801049f7:	89 c2                	mov    %eax,%edx
801049f9:	83 ec 08             	sub    $0x8,%esp
801049fc:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049ff:	50                   	push   %eax
80104a00:	52                   	push   %edx
80104a01:	e8 b7 03 00 00       	call   80104dbd <getcallerpcs>
80104a06:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a10:	eb 1c                	jmp    80104a2e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a15:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a19:	83 ec 08             	sub    $0x8,%esp
80104a1c:	50                   	push   %eax
80104a1d:	68 6f a9 10 80       	push   $0x8010a96f
80104a22:	e8 cd b9 ff ff       	call   801003f4 <cprintf>
80104a27:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a2e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a32:	7f 0b                	jg     80104a3f <procdump+0xd2>
80104a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a37:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a3b:	85 c0                	test   %eax,%eax
80104a3d:	75 d3                	jne    80104a12 <procdump+0xa5>
    }
    cprintf("\n");
80104a3f:	83 ec 0c             	sub    $0xc,%esp
80104a42:	68 73 a9 10 80       	push   $0x8010a973
80104a47:	e8 a8 b9 ff ff       	call   801003f4 <cprintf>
80104a4c:	83 c4 10             	add    $0x10,%esp
80104a4f:	eb 01                	jmp    80104a52 <procdump+0xe5>
      continue;
80104a51:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a52:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104a56:	81 7d f0 74 91 11 80 	cmpl   $0x80119174,-0x10(%ebp)
80104a5d:	0f 82 1c ff ff ff    	jb     8010497f <procdump+0x12>
  }
}
80104a63:	90                   	nop
80104a64:	90                   	nop
80104a65:	c9                   	leave  
80104a66:	c3                   	ret    

80104a67 <printpt>:
 //추가
int printpt(int pid) {
80104a67:	55                   	push   %ebp
80104a68:	89 e5                	mov    %esp,%ebp
80104a6a:	53                   	push   %ebx
80104a6b:	83 ec 14             	sub    $0x14,%esp
    struct proc *p;
    pde_t *pgdir;
    pte_t *pte;
    uint a;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a6e:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104a75:	eb 0f                	jmp    80104a86 <printpt+0x1f>
        if(p->pid == pid)
80104a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7a:	8b 40 10             	mov    0x10(%eax),%eax
80104a7d:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a80:	74 0f                	je     80104a91 <printpt+0x2a>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a82:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a86:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104a8d:	72 e8                	jb     80104a77 <printpt+0x10>
80104a8f:	eb 01                	jmp    80104a92 <printpt+0x2b>
            break;
80104a91:	90                   	nop
    }
    if(p == 0 || p->pid != pid)
80104a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a96:	74 0b                	je     80104aa3 <printpt+0x3c>
80104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9b:	8b 40 10             	mov    0x10(%eax),%eax
80104a9e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104aa1:	74 0a                	je     80104aad <printpt+0x46>
        return -1;
80104aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa8:	e9 cc 00 00 00       	jmp    80104b79 <printpt+0x112>
    pgdir = p->pgdir;
80104aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab0:	8b 40 04             	mov    0x4(%eax),%eax
80104ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104ab6:	83 ec 08             	sub    $0x8,%esp
80104ab9:	ff 75 08             	push   0x8(%ebp)
80104abc:	68 75 a9 10 80       	push   $0x8010a975
80104ac1:	e8 2e b9 ff ff       	call   801003f4 <cprintf>
80104ac6:	83 c4 10             	add    $0x10,%esp
    for(a = 0; a < KERNBASE; a += PGSIZE) {
80104ac9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ad0:	e9 84 00 00 00       	jmp    80104b59 <printpt+0xf2>
        pte = walkpgdir(pgdir, (void *)a, 0); 
80104ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad8:	83 ec 04             	sub    $0x4,%esp
80104adb:	6a 00                	push   $0x0
80104add:	50                   	push   %eax
80104ade:	ff 75 ec             	push   -0x14(%ebp)
80104ae1:	e8 0a 2d 00 00       	call   801077f0 <walkpgdir>
80104ae6:	83 c4 10             	add    $0x10,%esp
80104ae9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(pte && (*pte & PTE_P)) {
80104aec:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104af0:	74 60                	je     80104b52 <printpt+0xeb>
80104af2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104af5:	8b 00                	mov    (%eax),%eax
80104af7:	83 e0 01             	and    $0x1,%eax
80104afa:	85 c0                	test   %eax,%eax
80104afc:	74 54                	je     80104b52 <printpt+0xeb>
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
                (*pte & PTE_U) ? 'U' : 'K', //user or kernel
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
                PTE_ADDR(*pte)>>12); //프레임
80104afe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b01:	8b 00                	mov    (%eax),%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104b03:	c1 e8 0c             	shr    $0xc,%eax
80104b06:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
80104b08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b0b:	8b 00                	mov    (%eax),%eax
80104b0d:	83 e0 02             	and    $0x2,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104b10:	85 c0                	test   %eax,%eax
80104b12:	74 07                	je     80104b1b <printpt+0xb4>
80104b14:	bb 57 00 00 00       	mov    $0x57,%ebx
80104b19:	eb 05                	jmp    80104b20 <printpt+0xb9>
80104b1b:	bb 2d 00 00 00       	mov    $0x2d,%ebx
                (*pte & PTE_U) ? 'U' : 'K', //user or kernel
80104b20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b23:	8b 00                	mov    (%eax),%eax
80104b25:	83 e0 04             	and    $0x4,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104b28:	85 c0                	test   %eax,%eax
80104b2a:	74 07                	je     80104b33 <printpt+0xcc>
80104b2c:	b9 55 00 00 00       	mov    $0x55,%ecx
80104b31:	eb 05                	jmp    80104b38 <printpt+0xd1>
80104b33:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b3b:	c1 e8 0c             	shr    $0xc,%eax
80104b3e:	83 ec 0c             	sub    $0xc,%esp
80104b41:	52                   	push   %edx
80104b42:	53                   	push   %ebx
80104b43:	51                   	push   %ecx
80104b44:	50                   	push   %eax
80104b45:	68 90 a9 10 80       	push   $0x8010a990
80104b4a:	e8 a5 b8 ff ff       	call   801003f4 <cprintf>
80104b4f:	83 c4 20             	add    $0x20,%esp
    for(a = 0; a < KERNBASE; a += PGSIZE) {
80104b52:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	0f 89 71 ff ff ff    	jns    80104ad5 <printpt+0x6e>
        }
    }
    
    cprintf("END PAGE TABLE\n");
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	68 9f a9 10 80       	push   $0x8010a99f
80104b6c:	e8 83 b8 ff ff       	call   801003f4 <cprintf>
80104b71:	83 c4 10             	add    $0x10,%esp
    return 0;
80104b74:	b8 00 00 00 00       	mov    $0x0,%eax
80104b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b7c:	c9                   	leave  
80104b7d:	c3                   	ret    

80104b7e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
80104b81:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104b84:	8b 45 08             	mov    0x8(%ebp),%eax
80104b87:	83 c0 04             	add    $0x4,%eax
80104b8a:	83 ec 08             	sub    $0x8,%esp
80104b8d:	68 d9 a9 10 80       	push   $0x8010a9d9
80104b92:	50                   	push   %eax
80104b93:	e8 43 01 00 00       	call   80104cdb <initlock>
80104b98:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ba1:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104bad:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104bb7:	90                   	nop
80104bb8:	c9                   	leave  
80104bb9:	c3                   	ret    

80104bba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104bba:	55                   	push   %ebp
80104bbb:	89 e5                	mov    %esp,%ebp
80104bbd:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc3:	83 c0 04             	add    $0x4,%eax
80104bc6:	83 ec 0c             	sub    $0xc,%esp
80104bc9:	50                   	push   %eax
80104bca:	e8 2e 01 00 00       	call   80104cfd <acquire>
80104bcf:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104bd2:	eb 15                	jmp    80104be9 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd7:	83 c0 04             	add    $0x4,%eax
80104bda:	83 ec 08             	sub    $0x8,%esp
80104bdd:	50                   	push   %eax
80104bde:	ff 75 08             	push   0x8(%ebp)
80104be1:	e8 e5 fb ff ff       	call   801047cb <sleep>
80104be6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104be9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bec:	8b 00                	mov    (%eax),%eax
80104bee:	85 c0                	test   %eax,%eax
80104bf0:	75 e2                	jne    80104bd4 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104bfb:	e8 22 f3 ff ff       	call   80103f22 <myproc>
80104c00:	8b 50 10             	mov    0x10(%eax),%edx
80104c03:	8b 45 08             	mov    0x8(%ebp),%eax
80104c06:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c09:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0c:	83 c0 04             	add    $0x4,%eax
80104c0f:	83 ec 0c             	sub    $0xc,%esp
80104c12:	50                   	push   %eax
80104c13:	e8 53 01 00 00       	call   80104d6b <release>
80104c18:	83 c4 10             	add    $0x10,%esp
}
80104c1b:	90                   	nop
80104c1c:	c9                   	leave  
80104c1d:	c3                   	ret    

80104c1e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104c1e:	55                   	push   %ebp
80104c1f:	89 e5                	mov    %esp,%ebp
80104c21:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c24:	8b 45 08             	mov    0x8(%ebp),%eax
80104c27:	83 c0 04             	add    $0x4,%eax
80104c2a:	83 ec 0c             	sub    $0xc,%esp
80104c2d:	50                   	push   %eax
80104c2e:	e8 ca 00 00 00       	call   80104cfd <acquire>
80104c33:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c36:	8b 45 08             	mov    0x8(%ebp),%eax
80104c39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c49:	83 ec 0c             	sub    $0xc,%esp
80104c4c:	ff 75 08             	push   0x8(%ebp)
80104c4f:	e8 5e fc ff ff       	call   801048b2 <wakeup>
80104c54:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c57:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5a:	83 c0 04             	add    $0x4,%eax
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	50                   	push   %eax
80104c61:	e8 05 01 00 00       	call   80104d6b <release>
80104c66:	83 c4 10             	add    $0x10,%esp
}
80104c69:	90                   	nop
80104c6a:	c9                   	leave  
80104c6b:	c3                   	ret    

80104c6c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104c6c:	55                   	push   %ebp
80104c6d:	89 e5                	mov    %esp,%ebp
80104c6f:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104c72:	8b 45 08             	mov    0x8(%ebp),%eax
80104c75:	83 c0 04             	add    $0x4,%eax
80104c78:	83 ec 0c             	sub    $0xc,%esp
80104c7b:	50                   	push   %eax
80104c7c:	e8 7c 00 00 00       	call   80104cfd <acquire>
80104c81:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104c84:	8b 45 08             	mov    0x8(%ebp),%eax
80104c87:	8b 00                	mov    (%eax),%eax
80104c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8f:	83 c0 04             	add    $0x4,%eax
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	50                   	push   %eax
80104c96:	e8 d0 00 00 00       	call   80104d6b <release>
80104c9b:	83 c4 10             	add    $0x10,%esp
  return r;
80104c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ca1:	c9                   	leave  
80104ca2:	c3                   	ret    

80104ca3 <readeflags>:
{
80104ca3:	55                   	push   %ebp
80104ca4:	89 e5                	mov    %esp,%ebp
80104ca6:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ca9:	9c                   	pushf  
80104caa:	58                   	pop    %eax
80104cab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104cae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cb1:	c9                   	leave  
80104cb2:	c3                   	ret    

80104cb3 <cli>:
{
80104cb3:	55                   	push   %ebp
80104cb4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104cb6:	fa                   	cli    
}
80104cb7:	90                   	nop
80104cb8:	5d                   	pop    %ebp
80104cb9:	c3                   	ret    

80104cba <sti>:
{
80104cba:	55                   	push   %ebp
80104cbb:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104cbd:	fb                   	sti    
}
80104cbe:	90                   	nop
80104cbf:	5d                   	pop    %ebp
80104cc0:	c3                   	ret    

80104cc1 <xchg>:
{
80104cc1:	55                   	push   %ebp
80104cc2:	89 e5                	mov    %esp,%ebp
80104cc4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104cc7:	8b 55 08             	mov    0x8(%ebp),%edx
80104cca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cd0:	f0 87 02             	lock xchg %eax,(%edx)
80104cd3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd9:	c9                   	leave  
80104cda:	c3                   	ret    

80104cdb <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104cdb:	55                   	push   %ebp
80104cdc:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ce4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104cfa:	90                   	nop
80104cfb:	5d                   	pop    %ebp
80104cfc:	c3                   	ret    

80104cfd <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104cfd:	55                   	push   %ebp
80104cfe:	89 e5                	mov    %esp,%ebp
80104d00:	53                   	push   %ebx
80104d01:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d04:	e8 5f 01 00 00       	call   80104e68 <pushcli>
  if(holding(lk)){
80104d09:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0c:	83 ec 0c             	sub    $0xc,%esp
80104d0f:	50                   	push   %eax
80104d10:	e8 23 01 00 00       	call   80104e38 <holding>
80104d15:	83 c4 10             	add    $0x10,%esp
80104d18:	85 c0                	test   %eax,%eax
80104d1a:	74 0d                	je     80104d29 <acquire+0x2c>
    panic("acquire");
80104d1c:	83 ec 0c             	sub    $0xc,%esp
80104d1f:	68 e4 a9 10 80       	push   $0x8010a9e4
80104d24:	e8 98 b8 ff ff       	call   801005c1 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d29:	90                   	nop
80104d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2d:	83 ec 08             	sub    $0x8,%esp
80104d30:	6a 01                	push   $0x1
80104d32:	50                   	push   %eax
80104d33:	e8 89 ff ff ff       	call   80104cc1 <xchg>
80104d38:	83 c4 10             	add    $0x10,%esp
80104d3b:	85 c0                	test   %eax,%eax
80104d3d:	75 eb                	jne    80104d2a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d3f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d44:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d47:	e8 5e f1 ff ff       	call   80103eaa <mycpu>
80104d4c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d52:	83 c0 0c             	add    $0xc,%eax
80104d55:	83 ec 08             	sub    $0x8,%esp
80104d58:	50                   	push   %eax
80104d59:	8d 45 08             	lea    0x8(%ebp),%eax
80104d5c:	50                   	push   %eax
80104d5d:	e8 5b 00 00 00       	call   80104dbd <getcallerpcs>
80104d62:	83 c4 10             	add    $0x10,%esp
}
80104d65:	90                   	nop
80104d66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d69:	c9                   	leave  
80104d6a:	c3                   	ret    

80104d6b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104d6b:	55                   	push   %ebp
80104d6c:	89 e5                	mov    %esp,%ebp
80104d6e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	ff 75 08             	push   0x8(%ebp)
80104d77:	e8 bc 00 00 00       	call   80104e38 <holding>
80104d7c:	83 c4 10             	add    $0x10,%esp
80104d7f:	85 c0                	test   %eax,%eax
80104d81:	75 0d                	jne    80104d90 <release+0x25>
    panic("release");
80104d83:	83 ec 0c             	sub    $0xc,%esp
80104d86:	68 ec a9 10 80       	push   $0x8010a9ec
80104d8b:	e8 31 b8 ff ff       	call   801005c1 <panic>

  lk->pcs[0] = 0;
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
80104d93:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104da4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104da9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dac:	8b 55 08             	mov    0x8(%ebp),%edx
80104daf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104db5:	e8 fb 00 00 00       	call   80104eb5 <popcli>
}
80104dba:	90                   	nop
80104dbb:	c9                   	leave  
80104dbc:	c3                   	ret    

80104dbd <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104dbd:	55                   	push   %ebp
80104dbe:	89 e5                	mov    %esp,%ebp
80104dc0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc6:	83 e8 08             	sub    $0x8,%eax
80104dc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104dcc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104dd3:	eb 38                	jmp    80104e0d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104dd5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104dd9:	74 53                	je     80104e2e <getcallerpcs+0x71>
80104ddb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104de2:	76 4a                	jbe    80104e2e <getcallerpcs+0x71>
80104de4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104de8:	74 44                	je     80104e2e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104dea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ded:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104df4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df7:	01 c2                	add    %eax,%edx
80104df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfc:	8b 40 04             	mov    0x4(%eax),%eax
80104dff:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e04:	8b 00                	mov    (%eax),%eax
80104e06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e09:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e0d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e11:	7e c2                	jle    80104dd5 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104e13:	eb 19                	jmp    80104e2e <getcallerpcs+0x71>
    pcs[i] = 0;
80104e15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e22:	01 d0                	add    %edx,%eax
80104e24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e2a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e2e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e32:	7e e1                	jle    80104e15 <getcallerpcs+0x58>
}
80104e34:	90                   	nop
80104e35:	90                   	nop
80104e36:	c9                   	leave  
80104e37:	c3                   	ret    

80104e38 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e38:	55                   	push   %ebp
80104e39:	89 e5                	mov    %esp,%ebp
80104e3b:	53                   	push   %ebx
80104e3c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e42:	8b 00                	mov    (%eax),%eax
80104e44:	85 c0                	test   %eax,%eax
80104e46:	74 16                	je     80104e5e <holding+0x26>
80104e48:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4b:	8b 58 08             	mov    0x8(%eax),%ebx
80104e4e:	e8 57 f0 ff ff       	call   80103eaa <mycpu>
80104e53:	39 c3                	cmp    %eax,%ebx
80104e55:	75 07                	jne    80104e5e <holding+0x26>
80104e57:	b8 01 00 00 00       	mov    $0x1,%eax
80104e5c:	eb 05                	jmp    80104e63 <holding+0x2b>
80104e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e68:	55                   	push   %ebp
80104e69:	89 e5                	mov    %esp,%ebp
80104e6b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104e6e:	e8 30 fe ff ff       	call   80104ca3 <readeflags>
80104e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104e76:	e8 38 fe ff ff       	call   80104cb3 <cli>
  if(mycpu()->ncli == 0)
80104e7b:	e8 2a f0 ff ff       	call   80103eaa <mycpu>
80104e80:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e86:	85 c0                	test   %eax,%eax
80104e88:	75 14                	jne    80104e9e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104e8a:	e8 1b f0 ff ff       	call   80103eaa <mycpu>
80104e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e92:	81 e2 00 02 00 00    	and    $0x200,%edx
80104e98:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104e9e:	e8 07 f0 ff ff       	call   80103eaa <mycpu>
80104ea3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ea9:	83 c2 01             	add    $0x1,%edx
80104eac:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104eb2:	90                   	nop
80104eb3:	c9                   	leave  
80104eb4:	c3                   	ret    

80104eb5 <popcli>:

void
popcli(void)
{
80104eb5:	55                   	push   %ebp
80104eb6:	89 e5                	mov    %esp,%ebp
80104eb8:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ebb:	e8 e3 fd ff ff       	call   80104ca3 <readeflags>
80104ec0:	25 00 02 00 00       	and    $0x200,%eax
80104ec5:	85 c0                	test   %eax,%eax
80104ec7:	74 0d                	je     80104ed6 <popcli+0x21>
    panic("popcli - interruptible");
80104ec9:	83 ec 0c             	sub    $0xc,%esp
80104ecc:	68 f4 a9 10 80       	push   $0x8010a9f4
80104ed1:	e8 eb b6 ff ff       	call   801005c1 <panic>
  if(--mycpu()->ncli < 0)
80104ed6:	e8 cf ef ff ff       	call   80103eaa <mycpu>
80104edb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ee1:	83 ea 01             	sub    $0x1,%edx
80104ee4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104eea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ef0:	85 c0                	test   %eax,%eax
80104ef2:	79 0d                	jns    80104f01 <popcli+0x4c>
    panic("popcli");
80104ef4:	83 ec 0c             	sub    $0xc,%esp
80104ef7:	68 0b aa 10 80       	push   $0x8010aa0b
80104efc:	e8 c0 b6 ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f01:	e8 a4 ef ff ff       	call   80103eaa <mycpu>
80104f06:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f0c:	85 c0                	test   %eax,%eax
80104f0e:	75 14                	jne    80104f24 <popcli+0x6f>
80104f10:	e8 95 ef ff ff       	call   80103eaa <mycpu>
80104f15:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f1b:	85 c0                	test   %eax,%eax
80104f1d:	74 05                	je     80104f24 <popcli+0x6f>
    sti();
80104f1f:	e8 96 fd ff ff       	call   80104cba <sti>
}
80104f24:	90                   	nop
80104f25:	c9                   	leave  
80104f26:	c3                   	ret    

80104f27 <stosb>:
{
80104f27:	55                   	push   %ebp
80104f28:	89 e5                	mov    %esp,%ebp
80104f2a:	57                   	push   %edi
80104f2b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f2f:	8b 55 10             	mov    0x10(%ebp),%edx
80104f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f35:	89 cb                	mov    %ecx,%ebx
80104f37:	89 df                	mov    %ebx,%edi
80104f39:	89 d1                	mov    %edx,%ecx
80104f3b:	fc                   	cld    
80104f3c:	f3 aa                	rep stos %al,%es:(%edi)
80104f3e:	89 ca                	mov    %ecx,%edx
80104f40:	89 fb                	mov    %edi,%ebx
80104f42:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f45:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f48:	90                   	nop
80104f49:	5b                   	pop    %ebx
80104f4a:	5f                   	pop    %edi
80104f4b:	5d                   	pop    %ebp
80104f4c:	c3                   	ret    

80104f4d <stosl>:
{
80104f4d:	55                   	push   %ebp
80104f4e:	89 e5                	mov    %esp,%ebp
80104f50:	57                   	push   %edi
80104f51:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f55:	8b 55 10             	mov    0x10(%ebp),%edx
80104f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5b:	89 cb                	mov    %ecx,%ebx
80104f5d:	89 df                	mov    %ebx,%edi
80104f5f:	89 d1                	mov    %edx,%ecx
80104f61:	fc                   	cld    
80104f62:	f3 ab                	rep stos %eax,%es:(%edi)
80104f64:	89 ca                	mov    %ecx,%edx
80104f66:	89 fb                	mov    %edi,%ebx
80104f68:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f6b:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f6e:	90                   	nop
80104f6f:	5b                   	pop    %ebx
80104f70:	5f                   	pop    %edi
80104f71:	5d                   	pop    %ebp
80104f72:	c3                   	ret    

80104f73 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104f73:	55                   	push   %ebp
80104f74:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104f76:	8b 45 08             	mov    0x8(%ebp),%eax
80104f79:	83 e0 03             	and    $0x3,%eax
80104f7c:	85 c0                	test   %eax,%eax
80104f7e:	75 43                	jne    80104fc3 <memset+0x50>
80104f80:	8b 45 10             	mov    0x10(%ebp),%eax
80104f83:	83 e0 03             	and    $0x3,%eax
80104f86:	85 c0                	test   %eax,%eax
80104f88:	75 39                	jne    80104fc3 <memset+0x50>
    c &= 0xFF;
80104f8a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104f91:	8b 45 10             	mov    0x10(%ebp),%eax
80104f94:	c1 e8 02             	shr    $0x2,%eax
80104f97:	89 c2                	mov    %eax,%edx
80104f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9c:	c1 e0 18             	shl    $0x18,%eax
80104f9f:	89 c1                	mov    %eax,%ecx
80104fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa4:	c1 e0 10             	shl    $0x10,%eax
80104fa7:	09 c1                	or     %eax,%ecx
80104fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fac:	c1 e0 08             	shl    $0x8,%eax
80104faf:	09 c8                	or     %ecx,%eax
80104fb1:	0b 45 0c             	or     0xc(%ebp),%eax
80104fb4:	52                   	push   %edx
80104fb5:	50                   	push   %eax
80104fb6:	ff 75 08             	push   0x8(%ebp)
80104fb9:	e8 8f ff ff ff       	call   80104f4d <stosl>
80104fbe:	83 c4 0c             	add    $0xc,%esp
80104fc1:	eb 12                	jmp    80104fd5 <memset+0x62>
  } else
    stosb(dst, c, n);
80104fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc6:	50                   	push   %eax
80104fc7:	ff 75 0c             	push   0xc(%ebp)
80104fca:	ff 75 08             	push   0x8(%ebp)
80104fcd:	e8 55 ff ff ff       	call   80104f27 <stosb>
80104fd2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104fd5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fd8:	c9                   	leave  
80104fd9:	c3                   	ret    

80104fda <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104fda:	55                   	push   %ebp
80104fdb:	89 e5                	mov    %esp,%ebp
80104fdd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104fec:	eb 30                	jmp    8010501e <memcmp+0x44>
    if(*s1 != *s2)
80104fee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ff1:	0f b6 10             	movzbl (%eax),%edx
80104ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ff7:	0f b6 00             	movzbl (%eax),%eax
80104ffa:	38 c2                	cmp    %al,%dl
80104ffc:	74 18                	je     80105016 <memcmp+0x3c>
      return *s1 - *s2;
80104ffe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105001:	0f b6 00             	movzbl (%eax),%eax
80105004:	0f b6 d0             	movzbl %al,%edx
80105007:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010500a:	0f b6 00             	movzbl (%eax),%eax
8010500d:	0f b6 c8             	movzbl %al,%ecx
80105010:	89 d0                	mov    %edx,%eax
80105012:	29 c8                	sub    %ecx,%eax
80105014:	eb 1a                	jmp    80105030 <memcmp+0x56>
    s1++, s2++;
80105016:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010501a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010501e:	8b 45 10             	mov    0x10(%ebp),%eax
80105021:	8d 50 ff             	lea    -0x1(%eax),%edx
80105024:	89 55 10             	mov    %edx,0x10(%ebp)
80105027:	85 c0                	test   %eax,%eax
80105029:	75 c3                	jne    80104fee <memcmp+0x14>
  }

  return 0;
8010502b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105030:	c9                   	leave  
80105031:	c3                   	ret    

80105032 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105032:	55                   	push   %ebp
80105033:	89 e5                	mov    %esp,%ebp
80105035:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105038:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010503e:	8b 45 08             	mov    0x8(%ebp),%eax
80105041:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105044:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105047:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010504a:	73 54                	jae    801050a0 <memmove+0x6e>
8010504c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010504f:	8b 45 10             	mov    0x10(%ebp),%eax
80105052:	01 d0                	add    %edx,%eax
80105054:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105057:	73 47                	jae    801050a0 <memmove+0x6e>
    s += n;
80105059:	8b 45 10             	mov    0x10(%ebp),%eax
8010505c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010505f:	8b 45 10             	mov    0x10(%ebp),%eax
80105062:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105065:	eb 13                	jmp    8010507a <memmove+0x48>
      *--d = *--s;
80105067:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010506b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010506f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105072:	0f b6 10             	movzbl (%eax),%edx
80105075:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105078:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010507a:	8b 45 10             	mov    0x10(%ebp),%eax
8010507d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105080:	89 55 10             	mov    %edx,0x10(%ebp)
80105083:	85 c0                	test   %eax,%eax
80105085:	75 e0                	jne    80105067 <memmove+0x35>
  if(s < d && s + n > d){
80105087:	eb 24                	jmp    801050ad <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105089:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010508c:	8d 42 01             	lea    0x1(%edx),%eax
8010508f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105092:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105095:	8d 48 01             	lea    0x1(%eax),%ecx
80105098:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010509b:	0f b6 12             	movzbl (%edx),%edx
8010509e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050a0:	8b 45 10             	mov    0x10(%ebp),%eax
801050a3:	8d 50 ff             	lea    -0x1(%eax),%edx
801050a6:	89 55 10             	mov    %edx,0x10(%ebp)
801050a9:	85 c0                	test   %eax,%eax
801050ab:	75 dc                	jne    80105089 <memmove+0x57>

  return dst;
801050ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050b0:	c9                   	leave  
801050b1:	c3                   	ret    

801050b2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050b2:	55                   	push   %ebp
801050b3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801050b5:	ff 75 10             	push   0x10(%ebp)
801050b8:	ff 75 0c             	push   0xc(%ebp)
801050bb:	ff 75 08             	push   0x8(%ebp)
801050be:	e8 6f ff ff ff       	call   80105032 <memmove>
801050c3:	83 c4 0c             	add    $0xc,%esp
}
801050c6:	c9                   	leave  
801050c7:	c3                   	ret    

801050c8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801050c8:	55                   	push   %ebp
801050c9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801050cb:	eb 0c                	jmp    801050d9 <strncmp+0x11>
    n--, p++, q++;
801050cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801050d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801050d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050dd:	74 1a                	je     801050f9 <strncmp+0x31>
801050df:	8b 45 08             	mov    0x8(%ebp),%eax
801050e2:	0f b6 00             	movzbl (%eax),%eax
801050e5:	84 c0                	test   %al,%al
801050e7:	74 10                	je     801050f9 <strncmp+0x31>
801050e9:	8b 45 08             	mov    0x8(%ebp),%eax
801050ec:	0f b6 10             	movzbl (%eax),%edx
801050ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f2:	0f b6 00             	movzbl (%eax),%eax
801050f5:	38 c2                	cmp    %al,%dl
801050f7:	74 d4                	je     801050cd <strncmp+0x5>
  if(n == 0)
801050f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050fd:	75 07                	jne    80105106 <strncmp+0x3e>
    return 0;
801050ff:	b8 00 00 00 00       	mov    $0x0,%eax
80105104:	eb 16                	jmp    8010511c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	0f b6 00             	movzbl (%eax),%eax
8010510c:	0f b6 d0             	movzbl %al,%edx
8010510f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105112:	0f b6 00             	movzbl (%eax),%eax
80105115:	0f b6 c8             	movzbl %al,%ecx
80105118:	89 d0                	mov    %edx,%eax
8010511a:	29 c8                	sub    %ecx,%eax
}
8010511c:	5d                   	pop    %ebp
8010511d:	c3                   	ret    

8010511e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010511e:	55                   	push   %ebp
8010511f:	89 e5                	mov    %esp,%ebp
80105121:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010512a:	90                   	nop
8010512b:	8b 45 10             	mov    0x10(%ebp),%eax
8010512e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105131:	89 55 10             	mov    %edx,0x10(%ebp)
80105134:	85 c0                	test   %eax,%eax
80105136:	7e 2c                	jle    80105164 <strncpy+0x46>
80105138:	8b 55 0c             	mov    0xc(%ebp),%edx
8010513b:	8d 42 01             	lea    0x1(%edx),%eax
8010513e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	8d 48 01             	lea    0x1(%eax),%ecx
80105147:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010514a:	0f b6 12             	movzbl (%edx),%edx
8010514d:	88 10                	mov    %dl,(%eax)
8010514f:	0f b6 00             	movzbl (%eax),%eax
80105152:	84 c0                	test   %al,%al
80105154:	75 d5                	jne    8010512b <strncpy+0xd>
    ;
  while(n-- > 0)
80105156:	eb 0c                	jmp    80105164 <strncpy+0x46>
    *s++ = 0;
80105158:	8b 45 08             	mov    0x8(%ebp),%eax
8010515b:	8d 50 01             	lea    0x1(%eax),%edx
8010515e:	89 55 08             	mov    %edx,0x8(%ebp)
80105161:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105164:	8b 45 10             	mov    0x10(%ebp),%eax
80105167:	8d 50 ff             	lea    -0x1(%eax),%edx
8010516a:	89 55 10             	mov    %edx,0x10(%ebp)
8010516d:	85 c0                	test   %eax,%eax
8010516f:	7f e7                	jg     80105158 <strncpy+0x3a>
  return os;
80105171:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105174:	c9                   	leave  
80105175:	c3                   	ret    

80105176 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105176:	55                   	push   %ebp
80105177:	89 e5                	mov    %esp,%ebp
80105179:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010517c:	8b 45 08             	mov    0x8(%ebp),%eax
8010517f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105182:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105186:	7f 05                	jg     8010518d <safestrcpy+0x17>
    return os;
80105188:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010518b:	eb 32                	jmp    801051bf <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010518d:	90                   	nop
8010518e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105196:	7e 1e                	jle    801051b6 <safestrcpy+0x40>
80105198:	8b 55 0c             	mov    0xc(%ebp),%edx
8010519b:	8d 42 01             	lea    0x1(%edx),%eax
8010519e:	89 45 0c             	mov    %eax,0xc(%ebp)
801051a1:	8b 45 08             	mov    0x8(%ebp),%eax
801051a4:	8d 48 01             	lea    0x1(%eax),%ecx
801051a7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801051aa:	0f b6 12             	movzbl (%edx),%edx
801051ad:	88 10                	mov    %dl,(%eax)
801051af:	0f b6 00             	movzbl (%eax),%eax
801051b2:	84 c0                	test   %al,%al
801051b4:	75 d8                	jne    8010518e <safestrcpy+0x18>
    ;
  *s = 0;
801051b6:	8b 45 08             	mov    0x8(%ebp),%eax
801051b9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801051bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051bf:	c9                   	leave  
801051c0:	c3                   	ret    

801051c1 <strlen>:

int
strlen(const char *s)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801051c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801051ce:	eb 04                	jmp    801051d4 <strlen+0x13>
801051d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051d7:	8b 45 08             	mov    0x8(%ebp),%eax
801051da:	01 d0                	add    %edx,%eax
801051dc:	0f b6 00             	movzbl (%eax),%eax
801051df:	84 c0                	test   %al,%al
801051e1:	75 ed                	jne    801051d0 <strlen+0xf>
    ;
  return n;
801051e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051e6:	c9                   	leave  
801051e7:	c3                   	ret    

801051e8 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801051e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801051ec:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801051f0:	55                   	push   %ebp
  pushl %ebx
801051f1:	53                   	push   %ebx
  pushl %esi
801051f2:	56                   	push   %esi
  pushl %edi
801051f3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801051f4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801051f6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801051f8:	5f                   	pop    %edi
  popl %esi
801051f9:	5e                   	pop    %esi
  popl %ebx
801051fa:	5b                   	pop    %ebx
  popl %ebp
801051fb:	5d                   	pop    %ebp
  ret
801051fc:	c3                   	ret    

801051fd <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801051fd:	55                   	push   %ebp
801051fe:	89 e5                	mov    %esp,%ebp

  if(addr >=KERNBASE || addr+4 > KERNBASE)
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	85 c0                	test   %eax,%eax
80105205:	78 0d                	js     80105214 <fetchint+0x17>
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	83 c0 04             	add    $0x4,%eax
8010520d:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105212:	76 07                	jbe    8010521b <fetchint+0x1e>
    return -1;
80105214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105219:	eb 0f                	jmp    8010522a <fetchint+0x2d>
  *ip = *(int*)(addr);
8010521b:	8b 45 08             	mov    0x8(%ebp),%eax
8010521e:	8b 10                	mov    (%eax),%edx
80105220:	8b 45 0c             	mov    0xc(%ebp),%eax
80105223:	89 10                	mov    %edx,(%eax)
  return 0;
80105225:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010522a:	5d                   	pop    %ebp
8010522b:	c3                   	ret    

8010522c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010522c:	55                   	push   %ebp
8010522d:	89 e5                	mov    %esp,%ebp
8010522f:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >=KERNBASE)
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	85 c0                	test   %eax,%eax
80105237:	79 07                	jns    80105240 <fetchstr+0x14>
    return -1;
80105239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523e:	eb 40                	jmp    80105280 <fetchstr+0x54>
  *pp = (char*)addr;
80105240:	8b 55 08             	mov    0x8(%ebp),%edx
80105243:	8b 45 0c             	mov    0xc(%ebp),%eax
80105246:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE;
80105248:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
8010524f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105252:	8b 00                	mov    (%eax),%eax
80105254:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105257:	eb 1a                	jmp    80105273 <fetchstr+0x47>
    if(*s == 0)
80105259:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010525c:	0f b6 00             	movzbl (%eax),%eax
8010525f:	84 c0                	test   %al,%al
80105261:	75 0c                	jne    8010526f <fetchstr+0x43>
      return s - *pp;
80105263:	8b 45 0c             	mov    0xc(%ebp),%eax
80105266:	8b 10                	mov    (%eax),%edx
80105268:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010526b:	29 d0                	sub    %edx,%eax
8010526d:	eb 11                	jmp    80105280 <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
8010526f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105273:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105276:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105279:	72 de                	jb     80105259 <fetchstr+0x2d>
  }
  return -1;
8010527b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105280:	c9                   	leave  
80105281:	c3                   	ret    

80105282 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105282:	55                   	push   %ebp
80105283:	89 e5                	mov    %esp,%ebp
80105285:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105288:	e8 95 ec ff ff       	call   80103f22 <myproc>
8010528d:	8b 40 18             	mov    0x18(%eax),%eax
80105290:	8b 50 44             	mov    0x44(%eax),%edx
80105293:	8b 45 08             	mov    0x8(%ebp),%eax
80105296:	c1 e0 02             	shl    $0x2,%eax
80105299:	01 d0                	add    %edx,%eax
8010529b:	83 c0 04             	add    $0x4,%eax
8010529e:	83 ec 08             	sub    $0x8,%esp
801052a1:	ff 75 0c             	push   0xc(%ebp)
801052a4:	50                   	push   %eax
801052a5:	e8 53 ff ff ff       	call   801051fd <fetchint>
801052aa:	83 c4 10             	add    $0x10,%esp
}
801052ad:	c9                   	leave  
801052ae:	c3                   	ret    

801052af <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801052af:	55                   	push   %ebp
801052b0:	89 e5                	mov    %esp,%ebp
801052b2:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801052b5:	83 ec 08             	sub    $0x8,%esp
801052b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052bb:	50                   	push   %eax
801052bc:	ff 75 08             	push   0x8(%ebp)
801052bf:	e8 be ff ff ff       	call   80105282 <argint>
801052c4:	83 c4 10             	add    $0x10,%esp
801052c7:	85 c0                	test   %eax,%eax
801052c9:	79 07                	jns    801052d2 <argptr+0x23>
    return -1;
801052cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d0:	eb 34                	jmp    80105306 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801052d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052d6:	78 18                	js     801052f0 <argptr+0x41>
801052d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052db:	85 c0                	test   %eax,%eax
801052dd:	78 11                	js     801052f0 <argptr+0x41>
801052df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e2:	89 c2                	mov    %eax,%edx
801052e4:	8b 45 10             	mov    0x10(%ebp),%eax
801052e7:	01 d0                	add    %edx,%eax
801052e9:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801052ee:	76 07                	jbe    801052f7 <argptr+0x48>
    return -1;
801052f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f5:	eb 0f                	jmp    80105306 <argptr+0x57>
  *pp = (char*)i;
801052f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fa:	89 c2                	mov    %eax,%edx
801052fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ff:	89 10                	mov    %edx,(%eax)
  return 0;
80105301:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105306:	c9                   	leave  
80105307:	c3                   	ret    

80105308 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105308:	55                   	push   %ebp
80105309:	89 e5                	mov    %esp,%ebp
8010530b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010530e:	83 ec 08             	sub    $0x8,%esp
80105311:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105314:	50                   	push   %eax
80105315:	ff 75 08             	push   0x8(%ebp)
80105318:	e8 65 ff ff ff       	call   80105282 <argint>
8010531d:	83 c4 10             	add    $0x10,%esp
80105320:	85 c0                	test   %eax,%eax
80105322:	79 07                	jns    8010532b <argstr+0x23>
    return -1;
80105324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105329:	eb 12                	jmp    8010533d <argstr+0x35>
  return fetchstr(addr, pp);
8010532b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532e:	83 ec 08             	sub    $0x8,%esp
80105331:	ff 75 0c             	push   0xc(%ebp)
80105334:	50                   	push   %eax
80105335:	e8 f2 fe ff ff       	call   8010522c <fetchstr>
8010533a:	83 c4 10             	add    $0x10,%esp
}
8010533d:	c9                   	leave  
8010533e:	c3                   	ret    

8010533f <syscall>:

};

void
syscall(void)
{
8010533f:	55                   	push   %ebp
80105340:	89 e5                	mov    %esp,%ebp
80105342:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105345:	e8 d8 eb ff ff       	call   80103f22 <myproc>
8010534a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010534d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105350:	8b 40 18             	mov    0x18(%eax),%eax
80105353:	8b 40 1c             	mov    0x1c(%eax),%eax
80105356:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105359:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010535d:	7e 2f                	jle    8010538e <syscall+0x4f>
8010535f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105362:	83 f8 16             	cmp    $0x16,%eax
80105365:	77 27                	ja     8010538e <syscall+0x4f>
80105367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010536a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105371:	85 c0                	test   %eax,%eax
80105373:	74 19                	je     8010538e <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105378:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010537f:	ff d0                	call   *%eax
80105381:	89 c2                	mov    %eax,%edx
80105383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105386:	8b 40 18             	mov    0x18(%eax),%eax
80105389:	89 50 1c             	mov    %edx,0x1c(%eax)
8010538c:	eb 2c                	jmp    801053ba <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010538e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105391:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105397:	8b 40 10             	mov    0x10(%eax),%eax
8010539a:	ff 75 f0             	push   -0x10(%ebp)
8010539d:	52                   	push   %edx
8010539e:	50                   	push   %eax
8010539f:	68 12 aa 10 80       	push   $0x8010aa12
801053a4:	e8 4b b0 ff ff       	call   801003f4 <cprintf>
801053a9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	8b 40 18             	mov    0x18(%eax),%eax
801053b2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801053b9:	90                   	nop
801053ba:	90                   	nop
801053bb:	c9                   	leave  
801053bc:	c3                   	ret    

801053bd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801053bd:	55                   	push   %ebp
801053be:	89 e5                	mov    %esp,%ebp
801053c0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801053c3:	83 ec 08             	sub    $0x8,%esp
801053c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c9:	50                   	push   %eax
801053ca:	ff 75 08             	push   0x8(%ebp)
801053cd:	e8 b0 fe ff ff       	call   80105282 <argint>
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	85 c0                	test   %eax,%eax
801053d7:	79 07                	jns    801053e0 <argfd+0x23>
    return -1;
801053d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053de:	eb 4f                	jmp    8010542f <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801053e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e3:	85 c0                	test   %eax,%eax
801053e5:	78 20                	js     80105407 <argfd+0x4a>
801053e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ea:	83 f8 0f             	cmp    $0xf,%eax
801053ed:	7f 18                	jg     80105407 <argfd+0x4a>
801053ef:	e8 2e eb ff ff       	call   80103f22 <myproc>
801053f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053f7:	83 c2 08             	add    $0x8,%edx
801053fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801053fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105401:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105405:	75 07                	jne    8010540e <argfd+0x51>
    return -1;
80105407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010540c:	eb 21                	jmp    8010542f <argfd+0x72>
  if(pfd)
8010540e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105412:	74 08                	je     8010541c <argfd+0x5f>
    *pfd = fd;
80105414:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105417:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010541c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105420:	74 08                	je     8010542a <argfd+0x6d>
    *pf = f;
80105422:	8b 45 10             	mov    0x10(%ebp),%eax
80105425:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105428:	89 10                	mov    %edx,(%eax)
  return 0;
8010542a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010542f:	c9                   	leave  
80105430:	c3                   	ret    

80105431 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105431:	55                   	push   %ebp
80105432:	89 e5                	mov    %esp,%ebp
80105434:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105437:	e8 e6 ea ff ff       	call   80103f22 <myproc>
8010543c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010543f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105446:	eb 2a                	jmp    80105472 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010544e:	83 c2 08             	add    $0x8,%edx
80105451:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105455:	85 c0                	test   %eax,%eax
80105457:	75 15                	jne    8010546e <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010545c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010545f:	8d 4a 08             	lea    0x8(%edx),%ecx
80105462:	8b 55 08             	mov    0x8(%ebp),%edx
80105465:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546c:	eb 0f                	jmp    8010547d <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010546e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105472:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105476:	7e d0                	jle    80105448 <fdalloc+0x17>
    }
  }
  return -1;
80105478:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010547d:	c9                   	leave  
8010547e:	c3                   	ret    

8010547f <sys_dup>:

int
sys_dup(void)
{
8010547f:	55                   	push   %ebp
80105480:	89 e5                	mov    %esp,%ebp
80105482:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105485:	83 ec 04             	sub    $0x4,%esp
80105488:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010548b:	50                   	push   %eax
8010548c:	6a 00                	push   $0x0
8010548e:	6a 00                	push   $0x0
80105490:	e8 28 ff ff ff       	call   801053bd <argfd>
80105495:	83 c4 10             	add    $0x10,%esp
80105498:	85 c0                	test   %eax,%eax
8010549a:	79 07                	jns    801054a3 <sys_dup+0x24>
    return -1;
8010549c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a1:	eb 31                	jmp    801054d4 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801054a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a6:	83 ec 0c             	sub    $0xc,%esp
801054a9:	50                   	push   %eax
801054aa:	e8 82 ff ff ff       	call   80105431 <fdalloc>
801054af:	83 c4 10             	add    $0x10,%esp
801054b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054b9:	79 07                	jns    801054c2 <sys_dup+0x43>
    return -1;
801054bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c0:	eb 12                	jmp    801054d4 <sys_dup+0x55>
  filedup(f);
801054c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c5:	83 ec 0c             	sub    $0xc,%esp
801054c8:	50                   	push   %eax
801054c9:	e8 8a bb ff ff       	call   80101058 <filedup>
801054ce:	83 c4 10             	add    $0x10,%esp
  return fd;
801054d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801054d4:	c9                   	leave  
801054d5:	c3                   	ret    

801054d6 <sys_read>:

int
sys_read(void)
{
801054d6:	55                   	push   %ebp
801054d7:	89 e5                	mov    %esp,%ebp
801054d9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801054dc:	83 ec 04             	sub    $0x4,%esp
801054df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054e2:	50                   	push   %eax
801054e3:	6a 00                	push   $0x0
801054e5:	6a 00                	push   $0x0
801054e7:	e8 d1 fe ff ff       	call   801053bd <argfd>
801054ec:	83 c4 10             	add    $0x10,%esp
801054ef:	85 c0                	test   %eax,%eax
801054f1:	78 2e                	js     80105521 <sys_read+0x4b>
801054f3:	83 ec 08             	sub    $0x8,%esp
801054f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054f9:	50                   	push   %eax
801054fa:	6a 02                	push   $0x2
801054fc:	e8 81 fd ff ff       	call   80105282 <argint>
80105501:	83 c4 10             	add    $0x10,%esp
80105504:	85 c0                	test   %eax,%eax
80105506:	78 19                	js     80105521 <sys_read+0x4b>
80105508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550b:	83 ec 04             	sub    $0x4,%esp
8010550e:	50                   	push   %eax
8010550f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105512:	50                   	push   %eax
80105513:	6a 01                	push   $0x1
80105515:	e8 95 fd ff ff       	call   801052af <argptr>
8010551a:	83 c4 10             	add    $0x10,%esp
8010551d:	85 c0                	test   %eax,%eax
8010551f:	79 07                	jns    80105528 <sys_read+0x52>
    return -1;
80105521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105526:	eb 17                	jmp    8010553f <sys_read+0x69>
  return fileread(f, p, n);
80105528:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010552b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010552e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105531:	83 ec 04             	sub    $0x4,%esp
80105534:	51                   	push   %ecx
80105535:	52                   	push   %edx
80105536:	50                   	push   %eax
80105537:	e8 ac bc ff ff       	call   801011e8 <fileread>
8010553c:	83 c4 10             	add    $0x10,%esp
}
8010553f:	c9                   	leave  
80105540:	c3                   	ret    

80105541 <sys_write>:

int
sys_write(void)
{
80105541:	55                   	push   %ebp
80105542:	89 e5                	mov    %esp,%ebp
80105544:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105547:	83 ec 04             	sub    $0x4,%esp
8010554a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010554d:	50                   	push   %eax
8010554e:	6a 00                	push   $0x0
80105550:	6a 00                	push   $0x0
80105552:	e8 66 fe ff ff       	call   801053bd <argfd>
80105557:	83 c4 10             	add    $0x10,%esp
8010555a:	85 c0                	test   %eax,%eax
8010555c:	78 2e                	js     8010558c <sys_write+0x4b>
8010555e:	83 ec 08             	sub    $0x8,%esp
80105561:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105564:	50                   	push   %eax
80105565:	6a 02                	push   $0x2
80105567:	e8 16 fd ff ff       	call   80105282 <argint>
8010556c:	83 c4 10             	add    $0x10,%esp
8010556f:	85 c0                	test   %eax,%eax
80105571:	78 19                	js     8010558c <sys_write+0x4b>
80105573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105576:	83 ec 04             	sub    $0x4,%esp
80105579:	50                   	push   %eax
8010557a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010557d:	50                   	push   %eax
8010557e:	6a 01                	push   $0x1
80105580:	e8 2a fd ff ff       	call   801052af <argptr>
80105585:	83 c4 10             	add    $0x10,%esp
80105588:	85 c0                	test   %eax,%eax
8010558a:	79 07                	jns    80105593 <sys_write+0x52>
    return -1;
8010558c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105591:	eb 17                	jmp    801055aa <sys_write+0x69>
  return filewrite(f, p, n);
80105593:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105596:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559c:	83 ec 04             	sub    $0x4,%esp
8010559f:	51                   	push   %ecx
801055a0:	52                   	push   %edx
801055a1:	50                   	push   %eax
801055a2:	e8 f9 bc ff ff       	call   801012a0 <filewrite>
801055a7:	83 c4 10             	add    $0x10,%esp
}
801055aa:	c9                   	leave  
801055ab:	c3                   	ret    

801055ac <sys_close>:

int
sys_close(void)
{
801055ac:	55                   	push   %ebp
801055ad:	89 e5                	mov    %esp,%ebp
801055af:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801055b2:	83 ec 04             	sub    $0x4,%esp
801055b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055b8:	50                   	push   %eax
801055b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055bc:	50                   	push   %eax
801055bd:	6a 00                	push   $0x0
801055bf:	e8 f9 fd ff ff       	call   801053bd <argfd>
801055c4:	83 c4 10             	add    $0x10,%esp
801055c7:	85 c0                	test   %eax,%eax
801055c9:	79 07                	jns    801055d2 <sys_close+0x26>
    return -1;
801055cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d0:	eb 27                	jmp    801055f9 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801055d2:	e8 4b e9 ff ff       	call   80103f22 <myproc>
801055d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055da:	83 c2 08             	add    $0x8,%edx
801055dd:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801055e4:	00 
  fileclose(f);
801055e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e8:	83 ec 0c             	sub    $0xc,%esp
801055eb:	50                   	push   %eax
801055ec:	e8 b8 ba ff ff       	call   801010a9 <fileclose>
801055f1:	83 c4 10             	add    $0x10,%esp
  return 0;
801055f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055f9:	c9                   	leave  
801055fa:	c3                   	ret    

801055fb <sys_fstat>:

int
sys_fstat(void)
{
801055fb:	55                   	push   %ebp
801055fc:	89 e5                	mov    %esp,%ebp
801055fe:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105601:	83 ec 04             	sub    $0x4,%esp
80105604:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105607:	50                   	push   %eax
80105608:	6a 00                	push   $0x0
8010560a:	6a 00                	push   $0x0
8010560c:	e8 ac fd ff ff       	call   801053bd <argfd>
80105611:	83 c4 10             	add    $0x10,%esp
80105614:	85 c0                	test   %eax,%eax
80105616:	78 17                	js     8010562f <sys_fstat+0x34>
80105618:	83 ec 04             	sub    $0x4,%esp
8010561b:	6a 14                	push   $0x14
8010561d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105620:	50                   	push   %eax
80105621:	6a 01                	push   $0x1
80105623:	e8 87 fc ff ff       	call   801052af <argptr>
80105628:	83 c4 10             	add    $0x10,%esp
8010562b:	85 c0                	test   %eax,%eax
8010562d:	79 07                	jns    80105636 <sys_fstat+0x3b>
    return -1;
8010562f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105634:	eb 13                	jmp    80105649 <sys_fstat+0x4e>
  return filestat(f, st);
80105636:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563c:	83 ec 08             	sub    $0x8,%esp
8010563f:	52                   	push   %edx
80105640:	50                   	push   %eax
80105641:	e8 4b bb ff ff       	call   80101191 <filestat>
80105646:	83 c4 10             	add    $0x10,%esp
}
80105649:	c9                   	leave  
8010564a:	c3                   	ret    

8010564b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010564b:	55                   	push   %ebp
8010564c:	89 e5                	mov    %esp,%ebp
8010564e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105651:	83 ec 08             	sub    $0x8,%esp
80105654:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105657:	50                   	push   %eax
80105658:	6a 00                	push   $0x0
8010565a:	e8 a9 fc ff ff       	call   80105308 <argstr>
8010565f:	83 c4 10             	add    $0x10,%esp
80105662:	85 c0                	test   %eax,%eax
80105664:	78 15                	js     8010567b <sys_link+0x30>
80105666:	83 ec 08             	sub    $0x8,%esp
80105669:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010566c:	50                   	push   %eax
8010566d:	6a 01                	push   $0x1
8010566f:	e8 94 fc ff ff       	call   80105308 <argstr>
80105674:	83 c4 10             	add    $0x10,%esp
80105677:	85 c0                	test   %eax,%eax
80105679:	79 0a                	jns    80105685 <sys_link+0x3a>
    return -1;
8010567b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105680:	e9 68 01 00 00       	jmp    801057ed <sys_link+0x1a2>

  begin_op();
80105685:	e8 a4 de ff ff       	call   8010352e <begin_op>
  if((ip = namei(old)) == 0){
8010568a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010568d:	83 ec 0c             	sub    $0xc,%esp
80105690:	50                   	push   %eax
80105691:	e8 95 ce ff ff       	call   8010252b <namei>
80105696:	83 c4 10             	add    $0x10,%esp
80105699:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010569c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a0:	75 0f                	jne    801056b1 <sys_link+0x66>
    end_op();
801056a2:	e8 13 df ff ff       	call   801035ba <end_op>
    return -1;
801056a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ac:	e9 3c 01 00 00       	jmp    801057ed <sys_link+0x1a2>
  }

  ilock(ip);
801056b1:	83 ec 0c             	sub    $0xc,%esp
801056b4:	ff 75 f4             	push   -0xc(%ebp)
801056b7:	e8 3c c3 ff ff       	call   801019f8 <ilock>
801056bc:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801056bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056c6:	66 83 f8 01          	cmp    $0x1,%ax
801056ca:	75 1d                	jne    801056e9 <sys_link+0x9e>
    iunlockput(ip);
801056cc:	83 ec 0c             	sub    $0xc,%esp
801056cf:	ff 75 f4             	push   -0xc(%ebp)
801056d2:	e8 52 c5 ff ff       	call   80101c29 <iunlockput>
801056d7:	83 c4 10             	add    $0x10,%esp
    end_op();
801056da:	e8 db de ff ff       	call   801035ba <end_op>
    return -1;
801056df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e4:	e9 04 01 00 00       	jmp    801057ed <sys_link+0x1a2>
  }

  ip->nlink++;
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056f0:	83 c0 01             	add    $0x1,%eax
801056f3:	89 c2                	mov    %eax,%edx
801056f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056fc:	83 ec 0c             	sub    $0xc,%esp
801056ff:	ff 75 f4             	push   -0xc(%ebp)
80105702:	e8 14 c1 ff ff       	call   8010181b <iupdate>
80105707:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010570a:	83 ec 0c             	sub    $0xc,%esp
8010570d:	ff 75 f4             	push   -0xc(%ebp)
80105710:	e8 f6 c3 ff ff       	call   80101b0b <iunlock>
80105715:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105718:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010571b:	83 ec 08             	sub    $0x8,%esp
8010571e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105721:	52                   	push   %edx
80105722:	50                   	push   %eax
80105723:	e8 1f ce ff ff       	call   80102547 <nameiparent>
80105728:	83 c4 10             	add    $0x10,%esp
8010572b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010572e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105732:	74 71                	je     801057a5 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	ff 75 f0             	push   -0x10(%ebp)
8010573a:	e8 b9 c2 ff ff       	call   801019f8 <ilock>
8010573f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105745:	8b 10                	mov    (%eax),%edx
80105747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574a:	8b 00                	mov    (%eax),%eax
8010574c:	39 c2                	cmp    %eax,%edx
8010574e:	75 1d                	jne    8010576d <sys_link+0x122>
80105750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105753:	8b 40 04             	mov    0x4(%eax),%eax
80105756:	83 ec 04             	sub    $0x4,%esp
80105759:	50                   	push   %eax
8010575a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010575d:	50                   	push   %eax
8010575e:	ff 75 f0             	push   -0x10(%ebp)
80105761:	e8 2e cb ff ff       	call   80102294 <dirlink>
80105766:	83 c4 10             	add    $0x10,%esp
80105769:	85 c0                	test   %eax,%eax
8010576b:	79 10                	jns    8010577d <sys_link+0x132>
    iunlockput(dp);
8010576d:	83 ec 0c             	sub    $0xc,%esp
80105770:	ff 75 f0             	push   -0x10(%ebp)
80105773:	e8 b1 c4 ff ff       	call   80101c29 <iunlockput>
80105778:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010577b:	eb 29                	jmp    801057a6 <sys_link+0x15b>
  }
  iunlockput(dp);
8010577d:	83 ec 0c             	sub    $0xc,%esp
80105780:	ff 75 f0             	push   -0x10(%ebp)
80105783:	e8 a1 c4 ff ff       	call   80101c29 <iunlockput>
80105788:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010578b:	83 ec 0c             	sub    $0xc,%esp
8010578e:	ff 75 f4             	push   -0xc(%ebp)
80105791:	e8 c3 c3 ff ff       	call   80101b59 <iput>
80105796:	83 c4 10             	add    $0x10,%esp

  end_op();
80105799:	e8 1c de ff ff       	call   801035ba <end_op>

  return 0;
8010579e:	b8 00 00 00 00       	mov    $0x0,%eax
801057a3:	eb 48                	jmp    801057ed <sys_link+0x1a2>
    goto bad;
801057a5:	90                   	nop

bad:
  ilock(ip);
801057a6:	83 ec 0c             	sub    $0xc,%esp
801057a9:	ff 75 f4             	push   -0xc(%ebp)
801057ac:	e8 47 c2 ff ff       	call   801019f8 <ilock>
801057b1:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801057b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057bb:	83 e8 01             	sub    $0x1,%eax
801057be:	89 c2                	mov    %eax,%edx
801057c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057c7:	83 ec 0c             	sub    $0xc,%esp
801057ca:	ff 75 f4             	push   -0xc(%ebp)
801057cd:	e8 49 c0 ff ff       	call   8010181b <iupdate>
801057d2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801057d5:	83 ec 0c             	sub    $0xc,%esp
801057d8:	ff 75 f4             	push   -0xc(%ebp)
801057db:	e8 49 c4 ff ff       	call   80101c29 <iunlockput>
801057e0:	83 c4 10             	add    $0x10,%esp
  end_op();
801057e3:	e8 d2 dd ff ff       	call   801035ba <end_op>
  return -1;
801057e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057ed:	c9                   	leave  
801057ee:	c3                   	ret    

801057ef <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801057ef:	55                   	push   %ebp
801057f0:	89 e5                	mov    %esp,%ebp
801057f2:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801057f5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801057fc:	eb 40                	jmp    8010583e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105801:	6a 10                	push   $0x10
80105803:	50                   	push   %eax
80105804:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105807:	50                   	push   %eax
80105808:	ff 75 08             	push   0x8(%ebp)
8010580b:	e8 d4 c6 ff ff       	call   80101ee4 <readi>
80105810:	83 c4 10             	add    $0x10,%esp
80105813:	83 f8 10             	cmp    $0x10,%eax
80105816:	74 0d                	je     80105825 <isdirempty+0x36>
      panic("isdirempty: readi");
80105818:	83 ec 0c             	sub    $0xc,%esp
8010581b:	68 2e aa 10 80       	push   $0x8010aa2e
80105820:	e8 9c ad ff ff       	call   801005c1 <panic>
    if(de.inum != 0)
80105825:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105829:	66 85 c0             	test   %ax,%ax
8010582c:	74 07                	je     80105835 <isdirempty+0x46>
      return 0;
8010582e:	b8 00 00 00 00       	mov    $0x0,%eax
80105833:	eb 1b                	jmp    80105850 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105838:	83 c0 10             	add    $0x10,%eax
8010583b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010583e:	8b 45 08             	mov    0x8(%ebp),%eax
80105841:	8b 50 58             	mov    0x58(%eax),%edx
80105844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105847:	39 c2                	cmp    %eax,%edx
80105849:	77 b3                	ja     801057fe <isdirempty+0xf>
  }
  return 1;
8010584b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105850:	c9                   	leave  
80105851:	c3                   	ret    

80105852 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105852:	55                   	push   %ebp
80105853:	89 e5                	mov    %esp,%ebp
80105855:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105858:	83 ec 08             	sub    $0x8,%esp
8010585b:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010585e:	50                   	push   %eax
8010585f:	6a 00                	push   $0x0
80105861:	e8 a2 fa ff ff       	call   80105308 <argstr>
80105866:	83 c4 10             	add    $0x10,%esp
80105869:	85 c0                	test   %eax,%eax
8010586b:	79 0a                	jns    80105877 <sys_unlink+0x25>
    return -1;
8010586d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105872:	e9 bf 01 00 00       	jmp    80105a36 <sys_unlink+0x1e4>

  begin_op();
80105877:	e8 b2 dc ff ff       	call   8010352e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010587c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010587f:	83 ec 08             	sub    $0x8,%esp
80105882:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105885:	52                   	push   %edx
80105886:	50                   	push   %eax
80105887:	e8 bb cc ff ff       	call   80102547 <nameiparent>
8010588c:	83 c4 10             	add    $0x10,%esp
8010588f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105892:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105896:	75 0f                	jne    801058a7 <sys_unlink+0x55>
    end_op();
80105898:	e8 1d dd ff ff       	call   801035ba <end_op>
    return -1;
8010589d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a2:	e9 8f 01 00 00       	jmp    80105a36 <sys_unlink+0x1e4>
  }

  ilock(dp);
801058a7:	83 ec 0c             	sub    $0xc,%esp
801058aa:	ff 75 f4             	push   -0xc(%ebp)
801058ad:	e8 46 c1 ff ff       	call   801019f8 <ilock>
801058b2:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801058b5:	83 ec 08             	sub    $0x8,%esp
801058b8:	68 40 aa 10 80       	push   $0x8010aa40
801058bd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801058c0:	50                   	push   %eax
801058c1:	e8 f9 c8 ff ff       	call   801021bf <namecmp>
801058c6:	83 c4 10             	add    $0x10,%esp
801058c9:	85 c0                	test   %eax,%eax
801058cb:	0f 84 49 01 00 00    	je     80105a1a <sys_unlink+0x1c8>
801058d1:	83 ec 08             	sub    $0x8,%esp
801058d4:	68 42 aa 10 80       	push   $0x8010aa42
801058d9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801058dc:	50                   	push   %eax
801058dd:	e8 dd c8 ff ff       	call   801021bf <namecmp>
801058e2:	83 c4 10             	add    $0x10,%esp
801058e5:	85 c0                	test   %eax,%eax
801058e7:	0f 84 2d 01 00 00    	je     80105a1a <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801058ed:	83 ec 04             	sub    $0x4,%esp
801058f0:	8d 45 c8             	lea    -0x38(%ebp),%eax
801058f3:	50                   	push   %eax
801058f4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801058f7:	50                   	push   %eax
801058f8:	ff 75 f4             	push   -0xc(%ebp)
801058fb:	e8 da c8 ff ff       	call   801021da <dirlookup>
80105900:	83 c4 10             	add    $0x10,%esp
80105903:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105906:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010590a:	0f 84 0d 01 00 00    	je     80105a1d <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105910:	83 ec 0c             	sub    $0xc,%esp
80105913:	ff 75 f0             	push   -0x10(%ebp)
80105916:	e8 dd c0 ff ff       	call   801019f8 <ilock>
8010591b:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105921:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105925:	66 85 c0             	test   %ax,%ax
80105928:	7f 0d                	jg     80105937 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010592a:	83 ec 0c             	sub    $0xc,%esp
8010592d:	68 45 aa 10 80       	push   $0x8010aa45
80105932:	e8 8a ac ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010593e:	66 83 f8 01          	cmp    $0x1,%ax
80105942:	75 25                	jne    80105969 <sys_unlink+0x117>
80105944:	83 ec 0c             	sub    $0xc,%esp
80105947:	ff 75 f0             	push   -0x10(%ebp)
8010594a:	e8 a0 fe ff ff       	call   801057ef <isdirempty>
8010594f:	83 c4 10             	add    $0x10,%esp
80105952:	85 c0                	test   %eax,%eax
80105954:	75 13                	jne    80105969 <sys_unlink+0x117>
    iunlockput(ip);
80105956:	83 ec 0c             	sub    $0xc,%esp
80105959:	ff 75 f0             	push   -0x10(%ebp)
8010595c:	e8 c8 c2 ff ff       	call   80101c29 <iunlockput>
80105961:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105964:	e9 b5 00 00 00       	jmp    80105a1e <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105969:	83 ec 04             	sub    $0x4,%esp
8010596c:	6a 10                	push   $0x10
8010596e:	6a 00                	push   $0x0
80105970:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105973:	50                   	push   %eax
80105974:	e8 fa f5 ff ff       	call   80104f73 <memset>
80105979:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010597c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010597f:	6a 10                	push   $0x10
80105981:	50                   	push   %eax
80105982:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105985:	50                   	push   %eax
80105986:	ff 75 f4             	push   -0xc(%ebp)
80105989:	e8 ab c6 ff ff       	call   80102039 <writei>
8010598e:	83 c4 10             	add    $0x10,%esp
80105991:	83 f8 10             	cmp    $0x10,%eax
80105994:	74 0d                	je     801059a3 <sys_unlink+0x151>
    panic("unlink: writei");
80105996:	83 ec 0c             	sub    $0xc,%esp
80105999:	68 57 aa 10 80       	push   $0x8010aa57
8010599e:	e8 1e ac ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR){
801059a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059aa:	66 83 f8 01          	cmp    $0x1,%ax
801059ae:	75 21                	jne    801059d1 <sys_unlink+0x17f>
    dp->nlink--;
801059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059b7:	83 e8 01             	sub    $0x1,%eax
801059ba:	89 c2                	mov    %eax,%edx
801059bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bf:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059c3:	83 ec 0c             	sub    $0xc,%esp
801059c6:	ff 75 f4             	push   -0xc(%ebp)
801059c9:	e8 4d be ff ff       	call   8010181b <iupdate>
801059ce:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801059d1:	83 ec 0c             	sub    $0xc,%esp
801059d4:	ff 75 f4             	push   -0xc(%ebp)
801059d7:	e8 4d c2 ff ff       	call   80101c29 <iunlockput>
801059dc:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801059df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059e6:	83 e8 01             	sub    $0x1,%eax
801059e9:	89 c2                	mov    %eax,%edx
801059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ee:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801059f2:	83 ec 0c             	sub    $0xc,%esp
801059f5:	ff 75 f0             	push   -0x10(%ebp)
801059f8:	e8 1e be ff ff       	call   8010181b <iupdate>
801059fd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a00:	83 ec 0c             	sub    $0xc,%esp
80105a03:	ff 75 f0             	push   -0x10(%ebp)
80105a06:	e8 1e c2 ff ff       	call   80101c29 <iunlockput>
80105a0b:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a0e:	e8 a7 db ff ff       	call   801035ba <end_op>

  return 0;
80105a13:	b8 00 00 00 00       	mov    $0x0,%eax
80105a18:	eb 1c                	jmp    80105a36 <sys_unlink+0x1e4>
    goto bad;
80105a1a:	90                   	nop
80105a1b:	eb 01                	jmp    80105a1e <sys_unlink+0x1cc>
    goto bad;
80105a1d:	90                   	nop

bad:
  iunlockput(dp);
80105a1e:	83 ec 0c             	sub    $0xc,%esp
80105a21:	ff 75 f4             	push   -0xc(%ebp)
80105a24:	e8 00 c2 ff ff       	call   80101c29 <iunlockput>
80105a29:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a2c:	e8 89 db ff ff       	call   801035ba <end_op>
  return -1;
80105a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a36:	c9                   	leave  
80105a37:	c3                   	ret    

80105a38 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105a38:	55                   	push   %ebp
80105a39:	89 e5                	mov    %esp,%ebp
80105a3b:	83 ec 38             	sub    $0x38,%esp
80105a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105a41:	8b 55 10             	mov    0x10(%ebp),%edx
80105a44:	8b 45 14             	mov    0x14(%ebp),%eax
80105a47:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105a4b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105a4f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105a53:	83 ec 08             	sub    $0x8,%esp
80105a56:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a59:	50                   	push   %eax
80105a5a:	ff 75 08             	push   0x8(%ebp)
80105a5d:	e8 e5 ca ff ff       	call   80102547 <nameiparent>
80105a62:	83 c4 10             	add    $0x10,%esp
80105a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a6c:	75 0a                	jne    80105a78 <create+0x40>
    return 0;
80105a6e:	b8 00 00 00 00       	mov    $0x0,%eax
80105a73:	e9 90 01 00 00       	jmp    80105c08 <create+0x1d0>
  ilock(dp);
80105a78:	83 ec 0c             	sub    $0xc,%esp
80105a7b:	ff 75 f4             	push   -0xc(%ebp)
80105a7e:	e8 75 bf ff ff       	call   801019f8 <ilock>
80105a83:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105a86:	83 ec 04             	sub    $0x4,%esp
80105a89:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a8c:	50                   	push   %eax
80105a8d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a90:	50                   	push   %eax
80105a91:	ff 75 f4             	push   -0xc(%ebp)
80105a94:	e8 41 c7 ff ff       	call   801021da <dirlookup>
80105a99:	83 c4 10             	add    $0x10,%esp
80105a9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aa3:	74 50                	je     80105af5 <create+0xbd>
    iunlockput(dp);
80105aa5:	83 ec 0c             	sub    $0xc,%esp
80105aa8:	ff 75 f4             	push   -0xc(%ebp)
80105aab:	e8 79 c1 ff ff       	call   80101c29 <iunlockput>
80105ab0:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105ab3:	83 ec 0c             	sub    $0xc,%esp
80105ab6:	ff 75 f0             	push   -0x10(%ebp)
80105ab9:	e8 3a bf ff ff       	call   801019f8 <ilock>
80105abe:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105ac1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ac6:	75 15                	jne    80105add <create+0xa5>
80105ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105acb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105acf:	66 83 f8 02          	cmp    $0x2,%ax
80105ad3:	75 08                	jne    80105add <create+0xa5>
      return ip;
80105ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad8:	e9 2b 01 00 00       	jmp    80105c08 <create+0x1d0>
    iunlockput(ip);
80105add:	83 ec 0c             	sub    $0xc,%esp
80105ae0:	ff 75 f0             	push   -0x10(%ebp)
80105ae3:	e8 41 c1 ff ff       	call   80101c29 <iunlockput>
80105ae8:	83 c4 10             	add    $0x10,%esp
    return 0;
80105aeb:	b8 00 00 00 00       	mov    $0x0,%eax
80105af0:	e9 13 01 00 00       	jmp    80105c08 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105af5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	8b 00                	mov    (%eax),%eax
80105afe:	83 ec 08             	sub    $0x8,%esp
80105b01:	52                   	push   %edx
80105b02:	50                   	push   %eax
80105b03:	e8 3c bc ff ff       	call   80101744 <ialloc>
80105b08:	83 c4 10             	add    $0x10,%esp
80105b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b12:	75 0d                	jne    80105b21 <create+0xe9>
    panic("create: ialloc");
80105b14:	83 ec 0c             	sub    $0xc,%esp
80105b17:	68 66 aa 10 80       	push   $0x8010aa66
80105b1c:	e8 a0 aa ff ff       	call   801005c1 <panic>

  ilock(ip);
80105b21:	83 ec 0c             	sub    $0xc,%esp
80105b24:	ff 75 f0             	push   -0x10(%ebp)
80105b27:	e8 cc be ff ff       	call   801019f8 <ilock>
80105b2c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b32:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105b36:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105b41:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b48:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105b4e:	83 ec 0c             	sub    $0xc,%esp
80105b51:	ff 75 f0             	push   -0x10(%ebp)
80105b54:	e8 c2 bc ff ff       	call   8010181b <iupdate>
80105b59:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105b5c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105b61:	75 6a                	jne    80105bcd <create+0x195>
    dp->nlink++;  // for ".."
80105b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b66:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b6a:	83 c0 01             	add    $0x1,%eax
80105b6d:	89 c2                	mov    %eax,%edx
80105b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b72:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105b76:	83 ec 0c             	sub    $0xc,%esp
80105b79:	ff 75 f4             	push   -0xc(%ebp)
80105b7c:	e8 9a bc ff ff       	call   8010181b <iupdate>
80105b81:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b87:	8b 40 04             	mov    0x4(%eax),%eax
80105b8a:	83 ec 04             	sub    $0x4,%esp
80105b8d:	50                   	push   %eax
80105b8e:	68 40 aa 10 80       	push   $0x8010aa40
80105b93:	ff 75 f0             	push   -0x10(%ebp)
80105b96:	e8 f9 c6 ff ff       	call   80102294 <dirlink>
80105b9b:	83 c4 10             	add    $0x10,%esp
80105b9e:	85 c0                	test   %eax,%eax
80105ba0:	78 1e                	js     80105bc0 <create+0x188>
80105ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba5:	8b 40 04             	mov    0x4(%eax),%eax
80105ba8:	83 ec 04             	sub    $0x4,%esp
80105bab:	50                   	push   %eax
80105bac:	68 42 aa 10 80       	push   $0x8010aa42
80105bb1:	ff 75 f0             	push   -0x10(%ebp)
80105bb4:	e8 db c6 ff ff       	call   80102294 <dirlink>
80105bb9:	83 c4 10             	add    $0x10,%esp
80105bbc:	85 c0                	test   %eax,%eax
80105bbe:	79 0d                	jns    80105bcd <create+0x195>
      panic("create dots");
80105bc0:	83 ec 0c             	sub    $0xc,%esp
80105bc3:	68 75 aa 10 80       	push   $0x8010aa75
80105bc8:	e8 f4 a9 ff ff       	call   801005c1 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd0:	8b 40 04             	mov    0x4(%eax),%eax
80105bd3:	83 ec 04             	sub    $0x4,%esp
80105bd6:	50                   	push   %eax
80105bd7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bda:	50                   	push   %eax
80105bdb:	ff 75 f4             	push   -0xc(%ebp)
80105bde:	e8 b1 c6 ff ff       	call   80102294 <dirlink>
80105be3:	83 c4 10             	add    $0x10,%esp
80105be6:	85 c0                	test   %eax,%eax
80105be8:	79 0d                	jns    80105bf7 <create+0x1bf>
    panic("create: dirlink");
80105bea:	83 ec 0c             	sub    $0xc,%esp
80105bed:	68 81 aa 10 80       	push   $0x8010aa81
80105bf2:	e8 ca a9 ff ff       	call   801005c1 <panic>

  iunlockput(dp);
80105bf7:	83 ec 0c             	sub    $0xc,%esp
80105bfa:	ff 75 f4             	push   -0xc(%ebp)
80105bfd:	e8 27 c0 ff ff       	call   80101c29 <iunlockput>
80105c02:	83 c4 10             	add    $0x10,%esp

  return ip;
80105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c08:	c9                   	leave  
80105c09:	c3                   	ret    

80105c0a <sys_open>:

int
sys_open(void)
{
80105c0a:	55                   	push   %ebp
80105c0b:	89 e5                	mov    %esp,%ebp
80105c0d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c10:	83 ec 08             	sub    $0x8,%esp
80105c13:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c16:	50                   	push   %eax
80105c17:	6a 00                	push   $0x0
80105c19:	e8 ea f6 ff ff       	call   80105308 <argstr>
80105c1e:	83 c4 10             	add    $0x10,%esp
80105c21:	85 c0                	test   %eax,%eax
80105c23:	78 15                	js     80105c3a <sys_open+0x30>
80105c25:	83 ec 08             	sub    $0x8,%esp
80105c28:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c2b:	50                   	push   %eax
80105c2c:	6a 01                	push   $0x1
80105c2e:	e8 4f f6 ff ff       	call   80105282 <argint>
80105c33:	83 c4 10             	add    $0x10,%esp
80105c36:	85 c0                	test   %eax,%eax
80105c38:	79 0a                	jns    80105c44 <sys_open+0x3a>
    return -1;
80105c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3f:	e9 61 01 00 00       	jmp    80105da5 <sys_open+0x19b>

  begin_op();
80105c44:	e8 e5 d8 ff ff       	call   8010352e <begin_op>

  if(omode & O_CREATE){
80105c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c4c:	25 00 02 00 00       	and    $0x200,%eax
80105c51:	85 c0                	test   %eax,%eax
80105c53:	74 2a                	je     80105c7f <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c58:	6a 00                	push   $0x0
80105c5a:	6a 00                	push   $0x0
80105c5c:	6a 02                	push   $0x2
80105c5e:	50                   	push   %eax
80105c5f:	e8 d4 fd ff ff       	call   80105a38 <create>
80105c64:	83 c4 10             	add    $0x10,%esp
80105c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105c6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c6e:	75 75                	jne    80105ce5 <sys_open+0xdb>
      end_op();
80105c70:	e8 45 d9 ff ff       	call   801035ba <end_op>
      return -1;
80105c75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7a:	e9 26 01 00 00       	jmp    80105da5 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c82:	83 ec 0c             	sub    $0xc,%esp
80105c85:	50                   	push   %eax
80105c86:	e8 a0 c8 ff ff       	call   8010252b <namei>
80105c8b:	83 c4 10             	add    $0x10,%esp
80105c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c95:	75 0f                	jne    80105ca6 <sys_open+0x9c>
      end_op();
80105c97:	e8 1e d9 ff ff       	call   801035ba <end_op>
      return -1;
80105c9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca1:	e9 ff 00 00 00       	jmp    80105da5 <sys_open+0x19b>
    }
    ilock(ip);
80105ca6:	83 ec 0c             	sub    $0xc,%esp
80105ca9:	ff 75 f4             	push   -0xc(%ebp)
80105cac:	e8 47 bd ff ff       	call   801019f8 <ilock>
80105cb1:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cbb:	66 83 f8 01          	cmp    $0x1,%ax
80105cbf:	75 24                	jne    80105ce5 <sys_open+0xdb>
80105cc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cc4:	85 c0                	test   %eax,%eax
80105cc6:	74 1d                	je     80105ce5 <sys_open+0xdb>
      iunlockput(ip);
80105cc8:	83 ec 0c             	sub    $0xc,%esp
80105ccb:	ff 75 f4             	push   -0xc(%ebp)
80105cce:	e8 56 bf ff ff       	call   80101c29 <iunlockput>
80105cd3:	83 c4 10             	add    $0x10,%esp
      end_op();
80105cd6:	e8 df d8 ff ff       	call   801035ba <end_op>
      return -1;
80105cdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce0:	e9 c0 00 00 00       	jmp    80105da5 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ce5:	e8 01 b3 ff ff       	call   80100feb <filealloc>
80105cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ced:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cf1:	74 17                	je     80105d0a <sys_open+0x100>
80105cf3:	83 ec 0c             	sub    $0xc,%esp
80105cf6:	ff 75 f0             	push   -0x10(%ebp)
80105cf9:	e8 33 f7 ff ff       	call   80105431 <fdalloc>
80105cfe:	83 c4 10             	add    $0x10,%esp
80105d01:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d04:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d08:	79 2e                	jns    80105d38 <sys_open+0x12e>
    if(f)
80105d0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d0e:	74 0e                	je     80105d1e <sys_open+0x114>
      fileclose(f);
80105d10:	83 ec 0c             	sub    $0xc,%esp
80105d13:	ff 75 f0             	push   -0x10(%ebp)
80105d16:	e8 8e b3 ff ff       	call   801010a9 <fileclose>
80105d1b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105d1e:	83 ec 0c             	sub    $0xc,%esp
80105d21:	ff 75 f4             	push   -0xc(%ebp)
80105d24:	e8 00 bf ff ff       	call   80101c29 <iunlockput>
80105d29:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d2c:	e8 89 d8 ff ff       	call   801035ba <end_op>
    return -1;
80105d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d36:	eb 6d                	jmp    80105da5 <sys_open+0x19b>
  }
  iunlock(ip);
80105d38:	83 ec 0c             	sub    $0xc,%esp
80105d3b:	ff 75 f4             	push   -0xc(%ebp)
80105d3e:	e8 c8 bd ff ff       	call   80101b0b <iunlock>
80105d43:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d46:	e8 6f d8 ff ff       	call   801035ba <end_op>

  f->type = FD_INODE;
80105d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d5a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d60:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105d67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d6a:	83 e0 01             	and    $0x1,%eax
80105d6d:	85 c0                	test   %eax,%eax
80105d6f:	0f 94 c0             	sete   %al
80105d72:	89 c2                	mov    %eax,%edx
80105d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d77:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105d7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d7d:	83 e0 01             	and    $0x1,%eax
80105d80:	85 c0                	test   %eax,%eax
80105d82:	75 0a                	jne    80105d8e <sys_open+0x184>
80105d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d87:	83 e0 02             	and    $0x2,%eax
80105d8a:	85 c0                	test   %eax,%eax
80105d8c:	74 07                	je     80105d95 <sys_open+0x18b>
80105d8e:	b8 01 00 00 00       	mov    $0x1,%eax
80105d93:	eb 05                	jmp    80105d9a <sys_open+0x190>
80105d95:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9a:	89 c2                	mov    %eax,%edx
80105d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105da2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    

80105da7 <sys_mkdir>:

int
sys_mkdir(void)
{
80105da7:	55                   	push   %ebp
80105da8:	89 e5                	mov    %esp,%ebp
80105daa:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105dad:	e8 7c d7 ff ff       	call   8010352e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105db2:	83 ec 08             	sub    $0x8,%esp
80105db5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db8:	50                   	push   %eax
80105db9:	6a 00                	push   $0x0
80105dbb:	e8 48 f5 ff ff       	call   80105308 <argstr>
80105dc0:	83 c4 10             	add    $0x10,%esp
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	78 1b                	js     80105de2 <sys_mkdir+0x3b>
80105dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dca:	6a 00                	push   $0x0
80105dcc:	6a 00                	push   $0x0
80105dce:	6a 01                	push   $0x1
80105dd0:	50                   	push   %eax
80105dd1:	e8 62 fc ff ff       	call   80105a38 <create>
80105dd6:	83 c4 10             	add    $0x10,%esp
80105dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ddc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de0:	75 0c                	jne    80105dee <sys_mkdir+0x47>
    end_op();
80105de2:	e8 d3 d7 ff ff       	call   801035ba <end_op>
    return -1;
80105de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dec:	eb 18                	jmp    80105e06 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105dee:	83 ec 0c             	sub    $0xc,%esp
80105df1:	ff 75 f4             	push   -0xc(%ebp)
80105df4:	e8 30 be ff ff       	call   80101c29 <iunlockput>
80105df9:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dfc:	e8 b9 d7 ff ff       	call   801035ba <end_op>
  return 0;
80105e01:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e06:	c9                   	leave  
80105e07:	c3                   	ret    

80105e08 <sys_mknod>:

int
sys_mknod(void)
{
80105e08:	55                   	push   %ebp
80105e09:	89 e5                	mov    %esp,%ebp
80105e0b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105e0e:	e8 1b d7 ff ff       	call   8010352e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105e13:	83 ec 08             	sub    $0x8,%esp
80105e16:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	6a 00                	push   $0x0
80105e1c:	e8 e7 f4 ff ff       	call   80105308 <argstr>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	78 4f                	js     80105e77 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105e28:	83 ec 08             	sub    $0x8,%esp
80105e2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e2e:	50                   	push   %eax
80105e2f:	6a 01                	push   $0x1
80105e31:	e8 4c f4 ff ff       	call   80105282 <argint>
80105e36:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105e39:	85 c0                	test   %eax,%eax
80105e3b:	78 3a                	js     80105e77 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105e3d:	83 ec 08             	sub    $0x8,%esp
80105e40:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e43:	50                   	push   %eax
80105e44:	6a 02                	push   $0x2
80105e46:	e8 37 f4 ff ff       	call   80105282 <argint>
80105e4b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105e4e:	85 c0                	test   %eax,%eax
80105e50:	78 25                	js     80105e77 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e55:	0f bf c8             	movswl %ax,%ecx
80105e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e5b:	0f bf d0             	movswl %ax,%edx
80105e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e61:	51                   	push   %ecx
80105e62:	52                   	push   %edx
80105e63:	6a 03                	push   $0x3
80105e65:	50                   	push   %eax
80105e66:	e8 cd fb ff ff       	call   80105a38 <create>
80105e6b:	83 c4 10             	add    $0x10,%esp
80105e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105e71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e75:	75 0c                	jne    80105e83 <sys_mknod+0x7b>
    end_op();
80105e77:	e8 3e d7 ff ff       	call   801035ba <end_op>
    return -1;
80105e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e81:	eb 18                	jmp    80105e9b <sys_mknod+0x93>
  }
  iunlockput(ip);
80105e83:	83 ec 0c             	sub    $0xc,%esp
80105e86:	ff 75 f4             	push   -0xc(%ebp)
80105e89:	e8 9b bd ff ff       	call   80101c29 <iunlockput>
80105e8e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e91:	e8 24 d7 ff ff       	call   801035ba <end_op>
  return 0;
80105e96:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e9b:	c9                   	leave  
80105e9c:	c3                   	ret    

80105e9d <sys_chdir>:

int
sys_chdir(void)
{
80105e9d:	55                   	push   %ebp
80105e9e:	89 e5                	mov    %esp,%ebp
80105ea0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ea3:	e8 7a e0 ff ff       	call   80103f22 <myproc>
80105ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105eab:	e8 7e d6 ff ff       	call   8010352e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	6a 00                	push   $0x0
80105eb9:	e8 4a f4 ff ff       	call   80105308 <argstr>
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	78 18                	js     80105edd <sys_chdir+0x40>
80105ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ec8:	83 ec 0c             	sub    $0xc,%esp
80105ecb:	50                   	push   %eax
80105ecc:	e8 5a c6 ff ff       	call   8010252b <namei>
80105ed1:	83 c4 10             	add    $0x10,%esp
80105ed4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ed7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105edb:	75 0c                	jne    80105ee9 <sys_chdir+0x4c>
    end_op();
80105edd:	e8 d8 d6 ff ff       	call   801035ba <end_op>
    return -1;
80105ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee7:	eb 68                	jmp    80105f51 <sys_chdir+0xb4>
  }
  ilock(ip);
80105ee9:	83 ec 0c             	sub    $0xc,%esp
80105eec:	ff 75 f0             	push   -0x10(%ebp)
80105eef:	e8 04 bb ff ff       	call   801019f8 <ilock>
80105ef4:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105efe:	66 83 f8 01          	cmp    $0x1,%ax
80105f02:	74 1a                	je     80105f1e <sys_chdir+0x81>
    iunlockput(ip);
80105f04:	83 ec 0c             	sub    $0xc,%esp
80105f07:	ff 75 f0             	push   -0x10(%ebp)
80105f0a:	e8 1a bd ff ff       	call   80101c29 <iunlockput>
80105f0f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f12:	e8 a3 d6 ff ff       	call   801035ba <end_op>
    return -1;
80105f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1c:	eb 33                	jmp    80105f51 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105f1e:	83 ec 0c             	sub    $0xc,%esp
80105f21:	ff 75 f0             	push   -0x10(%ebp)
80105f24:	e8 e2 bb ff ff       	call   80101b0b <iunlock>
80105f29:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2f:	8b 40 68             	mov    0x68(%eax),%eax
80105f32:	83 ec 0c             	sub    $0xc,%esp
80105f35:	50                   	push   %eax
80105f36:	e8 1e bc ff ff       	call   80101b59 <iput>
80105f3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f3e:	e8 77 d6 ff ff       	call   801035ba <end_op>
  curproc->cwd = ip;
80105f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f46:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f49:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f51:	c9                   	leave  
80105f52:	c3                   	ret    

80105f53 <sys_exec>:

int
sys_exec(void)
{
80105f53:	55                   	push   %ebp
80105f54:	89 e5                	mov    %esp,%ebp
80105f56:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105f5c:	83 ec 08             	sub    $0x8,%esp
80105f5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f62:	50                   	push   %eax
80105f63:	6a 00                	push   $0x0
80105f65:	e8 9e f3 ff ff       	call   80105308 <argstr>
80105f6a:	83 c4 10             	add    $0x10,%esp
80105f6d:	85 c0                	test   %eax,%eax
80105f6f:	78 18                	js     80105f89 <sys_exec+0x36>
80105f71:	83 ec 08             	sub    $0x8,%esp
80105f74:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105f7a:	50                   	push   %eax
80105f7b:	6a 01                	push   $0x1
80105f7d:	e8 00 f3 ff ff       	call   80105282 <argint>
80105f82:	83 c4 10             	add    $0x10,%esp
80105f85:	85 c0                	test   %eax,%eax
80105f87:	79 0a                	jns    80105f93 <sys_exec+0x40>
    return -1;
80105f89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8e:	e9 c6 00 00 00       	jmp    80106059 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105f93:	83 ec 04             	sub    $0x4,%esp
80105f96:	68 80 00 00 00       	push   $0x80
80105f9b:	6a 00                	push   $0x0
80105f9d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105fa3:	50                   	push   %eax
80105fa4:	e8 ca ef ff ff       	call   80104f73 <memset>
80105fa9:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105fac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb6:	83 f8 1f             	cmp    $0x1f,%eax
80105fb9:	76 0a                	jbe    80105fc5 <sys_exec+0x72>
      return -1;
80105fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc0:	e9 94 00 00 00       	jmp    80106059 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc8:	c1 e0 02             	shl    $0x2,%eax
80105fcb:	89 c2                	mov    %eax,%edx
80105fcd:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105fd3:	01 c2                	add    %eax,%edx
80105fd5:	83 ec 08             	sub    $0x8,%esp
80105fd8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105fde:	50                   	push   %eax
80105fdf:	52                   	push   %edx
80105fe0:	e8 18 f2 ff ff       	call   801051fd <fetchint>
80105fe5:	83 c4 10             	add    $0x10,%esp
80105fe8:	85 c0                	test   %eax,%eax
80105fea:	79 07                	jns    80105ff3 <sys_exec+0xa0>
      return -1;
80105fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff1:	eb 66                	jmp    80106059 <sys_exec+0x106>
    if(uarg == 0){
80105ff3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ff9:	85 c0                	test   %eax,%eax
80105ffb:	75 27                	jne    80106024 <sys_exec+0xd1>
      argv[i] = 0;
80105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106000:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106007:	00 00 00 00 
      break;
8010600b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010600c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600f:	83 ec 08             	sub    $0x8,%esp
80106012:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106018:	52                   	push   %edx
80106019:	50                   	push   %eax
8010601a:	e8 79 ab ff ff       	call   80100b98 <exec>
8010601f:	83 c4 10             	add    $0x10,%esp
80106022:	eb 35                	jmp    80106059 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106024:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010602a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602d:	c1 e0 02             	shl    $0x2,%eax
80106030:	01 c2                	add    %eax,%edx
80106032:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106038:	83 ec 08             	sub    $0x8,%esp
8010603b:	52                   	push   %edx
8010603c:	50                   	push   %eax
8010603d:	e8 ea f1 ff ff       	call   8010522c <fetchstr>
80106042:	83 c4 10             	add    $0x10,%esp
80106045:	85 c0                	test   %eax,%eax
80106047:	79 07                	jns    80106050 <sys_exec+0xfd>
      return -1;
80106049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604e:	eb 09                	jmp    80106059 <sys_exec+0x106>
  for(i=0;; i++){
80106050:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106054:	e9 5a ff ff ff       	jmp    80105fb3 <sys_exec+0x60>
}
80106059:	c9                   	leave  
8010605a:	c3                   	ret    

8010605b <sys_pipe>:

int
sys_pipe(void)
{
8010605b:	55                   	push   %ebp
8010605c:	89 e5                	mov    %esp,%ebp
8010605e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106061:	83 ec 04             	sub    $0x4,%esp
80106064:	6a 08                	push   $0x8
80106066:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106069:	50                   	push   %eax
8010606a:	6a 00                	push   $0x0
8010606c:	e8 3e f2 ff ff       	call   801052af <argptr>
80106071:	83 c4 10             	add    $0x10,%esp
80106074:	85 c0                	test   %eax,%eax
80106076:	79 0a                	jns    80106082 <sys_pipe+0x27>
    return -1;
80106078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607d:	e9 ae 00 00 00       	jmp    80106130 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80106082:	83 ec 08             	sub    $0x8,%esp
80106085:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106088:	50                   	push   %eax
80106089:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010608c:	50                   	push   %eax
8010608d:	e8 cd d9 ff ff       	call   80103a5f <pipealloc>
80106092:	83 c4 10             	add    $0x10,%esp
80106095:	85 c0                	test   %eax,%eax
80106097:	79 0a                	jns    801060a3 <sys_pipe+0x48>
    return -1;
80106099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609e:	e9 8d 00 00 00       	jmp    80106130 <sys_pipe+0xd5>
  fd0 = -1;
801060a3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801060aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	50                   	push   %eax
801060b1:	e8 7b f3 ff ff       	call   80105431 <fdalloc>
801060b6:	83 c4 10             	add    $0x10,%esp
801060b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c0:	78 18                	js     801060da <sys_pipe+0x7f>
801060c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c5:	83 ec 0c             	sub    $0xc,%esp
801060c8:	50                   	push   %eax
801060c9:	e8 63 f3 ff ff       	call   80105431 <fdalloc>
801060ce:	83 c4 10             	add    $0x10,%esp
801060d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060d8:	79 3e                	jns    80106118 <sys_pipe+0xbd>
    if(fd0 >= 0)
801060da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060de:	78 13                	js     801060f3 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801060e0:	e8 3d de ff ff       	call   80103f22 <myproc>
801060e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060e8:	83 c2 08             	add    $0x8,%edx
801060eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801060f2:	00 
    fileclose(rf);
801060f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060f6:	83 ec 0c             	sub    $0xc,%esp
801060f9:	50                   	push   %eax
801060fa:	e8 aa af ff ff       	call   801010a9 <fileclose>
801060ff:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106105:	83 ec 0c             	sub    $0xc,%esp
80106108:	50                   	push   %eax
80106109:	e8 9b af ff ff       	call   801010a9 <fileclose>
8010610e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106116:	eb 18                	jmp    80106130 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106118:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010611b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010611e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106120:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106123:	8d 50 04             	lea    0x4(%eax),%edx
80106126:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106129:	89 02                	mov    %eax,(%edx)
  return 0;
8010612b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106130:	c9                   	leave  
80106131:	c3                   	ret    

80106132 <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
80106132:	55                   	push   %ebp
80106133:	89 e5                	mov    %esp,%ebp
80106135:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106138:	e8 e4 e0 ff ff       	call   80104221 <fork>
}
8010613d:	c9                   	leave  
8010613e:	c3                   	ret    

8010613f <sys_exit>:

int
sys_exit(void)
{
8010613f:	55                   	push   %ebp
80106140:	89 e5                	mov    %esp,%ebp
80106142:	83 ec 08             	sub    $0x8,%esp
  exit();
80106145:	e8 50 e2 ff ff       	call   8010439a <exit>
  return 0;  // not reached
8010614a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010614f:	c9                   	leave  
80106150:	c3                   	ret    

80106151 <sys_wait>:

int
sys_wait(void)
{
80106151:	55                   	push   %ebp
80106152:	89 e5                	mov    %esp,%ebp
80106154:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106157:	e8 5e e3 ff ff       	call   801044ba <wait>
}
8010615c:	c9                   	leave  
8010615d:	c3                   	ret    

8010615e <sys_kill>:

int
sys_kill(void)
{
8010615e:	55                   	push   %ebp
8010615f:	89 e5                	mov    %esp,%ebp
80106161:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106164:	83 ec 08             	sub    $0x8,%esp
80106167:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010616a:	50                   	push   %eax
8010616b:	6a 00                	push   $0x0
8010616d:	e8 10 f1 ff ff       	call   80105282 <argint>
80106172:	83 c4 10             	add    $0x10,%esp
80106175:	85 c0                	test   %eax,%eax
80106177:	79 07                	jns    80106180 <sys_kill+0x22>
    return -1;
80106179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617e:	eb 0f                	jmp    8010618f <sys_kill+0x31>
  return kill(pid);
80106180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106183:	83 ec 0c             	sub    $0xc,%esp
80106186:	50                   	push   %eax
80106187:	e8 5d e7 ff ff       	call   801048e9 <kill>
8010618c:	83 c4 10             	add    $0x10,%esp
}
8010618f:	c9                   	leave  
80106190:	c3                   	ret    

80106191 <sys_getpid>:

int
sys_getpid(void)
{
80106191:	55                   	push   %ebp
80106192:	89 e5                	mov    %esp,%ebp
80106194:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106197:	e8 86 dd ff ff       	call   80103f22 <myproc>
8010619c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010619f:	c9                   	leave  
801061a0:	c3                   	ret    

801061a1 <sys_printpt>:
 //추가
int
sys_printpt(void)
{
801061a1:	55                   	push   %ebp
801061a2:	89 e5                	mov    %esp,%ebp
801061a4:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
801061a7:	83 ec 08             	sub    $0x8,%esp
801061aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061ad:	50                   	push   %eax
801061ae:	6a 00                	push   $0x0
801061b0:	e8 cd f0 ff ff       	call   80105282 <argint>
801061b5:	83 c4 10             	add    $0x10,%esp
801061b8:	85 c0                	test   %eax,%eax
801061ba:	79 07                	jns    801061c3 <sys_printpt+0x22>
    return -1;
801061bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c1:	eb 14                	jmp    801061d7 <sys_printpt+0x36>
  printpt(pid);
801061c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c6:	83 ec 0c             	sub    $0xc,%esp
801061c9:	50                   	push   %eax
801061ca:	e8 98 e8 ff ff       	call   80104a67 <printpt>
801061cf:	83 c4 10             	add    $0x10,%esp
  return 0;
801061d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d7:	c9                   	leave  
801061d8:	c3                   	ret    

801061d9 <sys_sbrk>:


int
sys_sbrk(void)
{
801061d9:	55                   	push   %ebp
801061da:	89 e5                	mov    %esp,%ebp
801061dc:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801061df:	83 ec 08             	sub    $0x8,%esp
801061e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061e5:	50                   	push   %eax
801061e6:	6a 00                	push   $0x0
801061e8:	e8 95 f0 ff ff       	call   80105282 <argint>
801061ed:	83 c4 10             	add    $0x10,%esp
801061f0:	85 c0                	test   %eax,%eax
801061f2:	79 07                	jns    801061fb <sys_sbrk+0x22>
    return -1;
801061f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f9:	eb 27                	jmp    80106222 <sys_sbrk+0x49>
  addr = myproc()->sz;
801061fb:	e8 22 dd ff ff       	call   80103f22 <myproc>
80106200:	8b 00                	mov    (%eax),%eax
80106202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106205:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106208:	83 ec 0c             	sub    $0xc,%esp
8010620b:	50                   	push   %eax
8010620c:	e8 75 df ff ff       	call   80104186 <growproc>
80106211:	83 c4 10             	add    $0x10,%esp
80106214:	85 c0                	test   %eax,%eax
80106216:	79 07                	jns    8010621f <sys_sbrk+0x46>
    return -1;
80106218:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621d:	eb 03                	jmp    80106222 <sys_sbrk+0x49>
  return addr;
8010621f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106222:	c9                   	leave  
80106223:	c3                   	ret    

80106224 <sys_sleep>:

int
sys_sleep(void)
{
80106224:	55                   	push   %ebp
80106225:	89 e5                	mov    %esp,%ebp
80106227:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010622a:	83 ec 08             	sub    $0x8,%esp
8010622d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106230:	50                   	push   %eax
80106231:	6a 00                	push   $0x0
80106233:	e8 4a f0 ff ff       	call   80105282 <argint>
80106238:	83 c4 10             	add    $0x10,%esp
8010623b:	85 c0                	test   %eax,%eax
8010623d:	79 07                	jns    80106246 <sys_sleep+0x22>
    return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	eb 76                	jmp    801062bc <sys_sleep+0x98>
  acquire(&tickslock);
80106246:	83 ec 0c             	sub    $0xc,%esp
80106249:	68 80 99 11 80       	push   $0x80119980
8010624e:	e8 aa ea ff ff       	call   80104cfd <acquire>
80106253:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106256:	a1 b4 99 11 80       	mov    0x801199b4,%eax
8010625b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010625e:	eb 38                	jmp    80106298 <sys_sleep+0x74>
    if(myproc()->killed){
80106260:	e8 bd dc ff ff       	call   80103f22 <myproc>
80106265:	8b 40 24             	mov    0x24(%eax),%eax
80106268:	85 c0                	test   %eax,%eax
8010626a:	74 17                	je     80106283 <sys_sleep+0x5f>
      release(&tickslock);
8010626c:	83 ec 0c             	sub    $0xc,%esp
8010626f:	68 80 99 11 80       	push   $0x80119980
80106274:	e8 f2 ea ff ff       	call   80104d6b <release>
80106279:	83 c4 10             	add    $0x10,%esp
      return -1;
8010627c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106281:	eb 39                	jmp    801062bc <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106283:	83 ec 08             	sub    $0x8,%esp
80106286:	68 80 99 11 80       	push   $0x80119980
8010628b:	68 b4 99 11 80       	push   $0x801199b4
80106290:	e8 36 e5 ff ff       	call   801047cb <sleep>
80106295:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106298:	a1 b4 99 11 80       	mov    0x801199b4,%eax
8010629d:	2b 45 f4             	sub    -0xc(%ebp),%eax
801062a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062a3:	39 d0                	cmp    %edx,%eax
801062a5:	72 b9                	jb     80106260 <sys_sleep+0x3c>
  }
  release(&tickslock);
801062a7:	83 ec 0c             	sub    $0xc,%esp
801062aa:	68 80 99 11 80       	push   $0x80119980
801062af:	e8 b7 ea ff ff       	call   80104d6b <release>
801062b4:	83 c4 10             	add    $0x10,%esp
  return 0;
801062b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bc:	c9                   	leave  
801062bd:	c3                   	ret    

801062be <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801062be:	55                   	push   %ebp
801062bf:	89 e5                	mov    %esp,%ebp
801062c1:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	68 80 99 11 80       	push   $0x80119980
801062cc:	e8 2c ea ff ff       	call   80104cfd <acquire>
801062d1:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801062d4:	a1 b4 99 11 80       	mov    0x801199b4,%eax
801062d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801062dc:	83 ec 0c             	sub    $0xc,%esp
801062df:	68 80 99 11 80       	push   $0x80119980
801062e4:	e8 82 ea ff ff       	call   80104d6b <release>
801062e9:	83 c4 10             	add    $0x10,%esp
  return xticks;
801062ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062ef:	c9                   	leave  
801062f0:	c3                   	ret    

801062f1 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062f1:	1e                   	push   %ds
  pushl %es
801062f2:	06                   	push   %es
  pushl %fs
801062f3:	0f a0                	push   %fs
  pushl %gs
801062f5:	0f a8                	push   %gs
  pushal
801062f7:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062f8:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062fc:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062fe:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106300:	54                   	push   %esp
  call trap
80106301:	e8 e3 01 00 00       	call   801064e9 <trap>
  addl $4, %esp
80106306:	83 c4 04             	add    $0x4,%esp

80106309 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106309:	61                   	popa   
  popl %gs
8010630a:	0f a9                	pop    %gs
  popl %fs
8010630c:	0f a1                	pop    %fs
  popl %es
8010630e:	07                   	pop    %es
  popl %ds
8010630f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106310:	83 c4 08             	add    $0x8,%esp
  iret
80106313:	cf                   	iret   

80106314 <lidt>:
{
80106314:	55                   	push   %ebp
80106315:	89 e5                	mov    %esp,%ebp
80106317:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010631a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010631d:	83 e8 01             	sub    $0x1,%eax
80106320:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106324:	8b 45 08             	mov    0x8(%ebp),%eax
80106327:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010632b:	8b 45 08             	mov    0x8(%ebp),%eax
8010632e:	c1 e8 10             	shr    $0x10,%eax
80106331:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106335:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106338:	0f 01 18             	lidtl  (%eax)
}
8010633b:	90                   	nop
8010633c:	c9                   	leave  
8010633d:	c3                   	ret    

8010633e <rcr2>:

static inline uint
rcr2(void)
{
8010633e:	55                   	push   %ebp
8010633f:	89 e5                	mov    %esp,%ebp
80106341:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106344:	0f 20 d0             	mov    %cr2,%eax
80106347:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010634a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010634d:	c9                   	leave  
8010634e:	c3                   	ret    

8010634f <lcr3>:

static inline void
lcr3(uint val)
{
8010634f:	55                   	push   %ebp
80106350:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106352:	8b 45 08             	mov    0x8(%ebp),%eax
80106355:	0f 22 d8             	mov    %eax,%cr3
}
80106358:	90                   	nop
80106359:	5d                   	pop    %ebp
8010635a:	c3                   	ret    

8010635b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010635b:	55                   	push   %ebp
8010635c:	89 e5                	mov    %esp,%ebp
8010635e:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106368:	e9 c3 00 00 00       	jmp    80106430 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106377:	89 c2                	mov    %eax,%edx
80106379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637c:	66 89 14 c5 80 91 11 	mov    %dx,-0x7fee6e80(,%eax,8)
80106383:	80 
80106384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106387:	66 c7 04 c5 82 91 11 	movw   $0x8,-0x7fee6e7e(,%eax,8)
8010638e:	80 08 00 
80106391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106394:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
8010639b:	80 
8010639c:	83 e2 e0             	and    $0xffffffe0,%edx
8010639f:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
801063a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a9:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
801063b0:	80 
801063b1:	83 e2 1f             	and    $0x1f,%edx
801063b4:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
801063bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063be:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801063c5:	80 
801063c6:	83 e2 f0             	and    $0xfffffff0,%edx
801063c9:	83 ca 0e             	or     $0xe,%edx
801063cc:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801063dd:	80 
801063de:	83 e2 ef             	and    $0xffffffef,%edx
801063e1:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801063e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063eb:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801063f2:	80 
801063f3:	83 e2 9f             	and    $0xffffff9f,%edx
801063f6:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801063fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106400:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
80106407:	80 
80106408:	83 ca 80             	or     $0xffffff80,%edx
8010640b:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
80106412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106415:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
8010641c:	c1 e8 10             	shr    $0x10,%eax
8010641f:	89 c2                	mov    %eax,%edx
80106421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106424:	66 89 14 c5 86 91 11 	mov    %dx,-0x7fee6e7a(,%eax,8)
8010642b:	80 
  for(i = 0; i < 256; i++)
8010642c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106430:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106437:	0f 8e 30 ff ff ff    	jle    8010636d <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010643d:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106442:	66 a3 80 93 11 80    	mov    %ax,0x80119380
80106448:	66 c7 05 82 93 11 80 	movw   $0x8,0x80119382
8010644f:	08 00 
80106451:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
80106458:	83 e0 e0             	and    $0xffffffe0,%eax
8010645b:	a2 84 93 11 80       	mov    %al,0x80119384
80106460:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
80106467:	83 e0 1f             	and    $0x1f,%eax
8010646a:	a2 84 93 11 80       	mov    %al,0x80119384
8010646f:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
80106476:	83 c8 0f             	or     $0xf,%eax
80106479:	a2 85 93 11 80       	mov    %al,0x80119385
8010647e:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
80106485:	83 e0 ef             	and    $0xffffffef,%eax
80106488:	a2 85 93 11 80       	mov    %al,0x80119385
8010648d:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
80106494:	83 c8 60             	or     $0x60,%eax
80106497:	a2 85 93 11 80       	mov    %al,0x80119385
8010649c:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
801064a3:	83 c8 80             	or     $0xffffff80,%eax
801064a6:	a2 85 93 11 80       	mov    %al,0x80119385
801064ab:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801064b0:	c1 e8 10             	shr    $0x10,%eax
801064b3:	66 a3 86 93 11 80    	mov    %ax,0x80119386

  initlock(&tickslock, "time");
801064b9:	83 ec 08             	sub    $0x8,%esp
801064bc:	68 94 aa 10 80       	push   $0x8010aa94
801064c1:	68 80 99 11 80       	push   $0x80119980
801064c6:	e8 10 e8 ff ff       	call   80104cdb <initlock>
801064cb:	83 c4 10             	add    $0x10,%esp
}
801064ce:	90                   	nop
801064cf:	c9                   	leave  
801064d0:	c3                   	ret    

801064d1 <idtinit>:

void
idtinit(void)
{
801064d1:	55                   	push   %ebp
801064d2:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801064d4:	68 00 08 00 00       	push   $0x800
801064d9:	68 80 91 11 80       	push   $0x80119180
801064de:	e8 31 fe ff ff       	call   80106314 <lidt>
801064e3:	83 c4 08             	add    $0x8,%esp
}
801064e6:	90                   	nop
801064e7:	c9                   	leave  
801064e8:	c3                   	ret    

801064e9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801064e9:	55                   	push   %ebp
801064ea:	89 e5                	mov    %esp,%ebp
801064ec:	57                   	push   %edi
801064ed:	56                   	push   %esi
801064ee:	53                   	push   %ebx
801064ef:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801064f2:	8b 45 08             	mov    0x8(%ebp),%eax
801064f5:	8b 40 30             	mov    0x30(%eax),%eax
801064f8:	83 f8 40             	cmp    $0x40,%eax
801064fb:	75 3b                	jne    80106538 <trap+0x4f>
    if(myproc()->killed)
801064fd:	e8 20 da ff ff       	call   80103f22 <myproc>
80106502:	8b 40 24             	mov    0x24(%eax),%eax
80106505:	85 c0                	test   %eax,%eax
80106507:	74 05                	je     8010650e <trap+0x25>
      exit();
80106509:	e8 8c de ff ff       	call   8010439a <exit>
    myproc()->tf = tf;
8010650e:	e8 0f da ff ff       	call   80103f22 <myproc>
80106513:	8b 55 08             	mov    0x8(%ebp),%edx
80106516:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106519:	e8 21 ee ff ff       	call   8010533f <syscall>
    if(myproc()->killed)
8010651e:	e8 ff d9 ff ff       	call   80103f22 <myproc>
80106523:	8b 40 24             	mov    0x24(%eax),%eax
80106526:	85 c0                	test   %eax,%eax
80106528:	0f 84 be 02 00 00    	je     801067ec <trap+0x303>
      exit();
8010652e:	e8 67 de ff ff       	call   8010439a <exit>
    return;
80106533:	e9 b4 02 00 00       	jmp    801067ec <trap+0x303>
  }

  switch(tf->trapno){
80106538:	8b 45 08             	mov    0x8(%ebp),%eax
8010653b:	8b 40 30             	mov    0x30(%eax),%eax
8010653e:	83 e8 0e             	sub    $0xe,%eax
80106541:	83 f8 31             	cmp    $0x31,%eax
80106544:	0f 87 6d 01 00 00    	ja     801066b7 <trap+0x1ce>
8010654a:	8b 04 85 5c ab 10 80 	mov    -0x7fef54a4(,%eax,4),%eax
80106551:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106553:	e8 37 d9 ff ff       	call   80103e8f <cpuid>
80106558:	85 c0                	test   %eax,%eax
8010655a:	75 3d                	jne    80106599 <trap+0xb0>
      acquire(&tickslock);
8010655c:	83 ec 0c             	sub    $0xc,%esp
8010655f:	68 80 99 11 80       	push   $0x80119980
80106564:	e8 94 e7 ff ff       	call   80104cfd <acquire>
80106569:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010656c:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106571:	83 c0 01             	add    $0x1,%eax
80106574:	a3 b4 99 11 80       	mov    %eax,0x801199b4
      wakeup(&ticks);
80106579:	83 ec 0c             	sub    $0xc,%esp
8010657c:	68 b4 99 11 80       	push   $0x801199b4
80106581:	e8 2c e3 ff ff       	call   801048b2 <wakeup>
80106586:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106589:	83 ec 0c             	sub    $0xc,%esp
8010658c:	68 80 99 11 80       	push   $0x80119980
80106591:	e8 d5 e7 ff ff       	call   80104d6b <release>
80106596:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106599:	e8 70 ca ff ff       	call   8010300e <lapiceoi>
    break;
8010659e:	e9 c9 01 00 00       	jmp    8010676c <trap+0x283>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801065a3:	e8 bc c2 ff ff       	call   80102864 <ideintr>
    lapiceoi();
801065a8:	e8 61 ca ff ff       	call   8010300e <lapiceoi>
    break;
801065ad:	e9 ba 01 00 00       	jmp    8010676c <trap+0x283>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801065b2:	e8 9c c8 ff ff       	call   80102e53 <kbdintr>
    lapiceoi();
801065b7:	e8 52 ca ff ff       	call   8010300e <lapiceoi>
    break;
801065bc:	e9 ab 01 00 00       	jmp    8010676c <trap+0x283>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801065c1:	e8 fc 03 00 00       	call   801069c2 <uartintr>
    lapiceoi();
801065c6:	e8 43 ca ff ff       	call   8010300e <lapiceoi>
    break;
801065cb:	e9 9c 01 00 00       	jmp    8010676c <trap+0x283>
  case T_IRQ0 + 0xB:
    i8254_intr();
801065d0:	e8 0f 2c 00 00       	call   801091e4 <i8254_intr>
    lapiceoi();
801065d5:	e8 34 ca ff ff       	call   8010300e <lapiceoi>
    break;
801065da:	e9 8d 01 00 00       	jmp    8010676c <trap+0x283>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065df:	8b 45 08             	mov    0x8(%ebp),%eax
801065e2:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065e5:	8b 45 08             	mov    0x8(%ebp),%eax
801065e8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065ec:	0f b7 d8             	movzwl %ax,%ebx
801065ef:	e8 9b d8 ff ff       	call   80103e8f <cpuid>
801065f4:	56                   	push   %esi
801065f5:	53                   	push   %ebx
801065f6:	50                   	push   %eax
801065f7:	68 9c aa 10 80       	push   $0x8010aa9c
801065fc:	e8 f3 9d ff ff       	call   801003f4 <cprintf>
80106601:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106604:	e8 05 ca ff ff       	call   8010300e <lapiceoi>
    break;
80106609:	e9 5e 01 00 00       	jmp    8010676c <trap+0x283>

  //추가
  case T_PGFLT: 
      // 페이지 폴트 발생 → 접근한 주소 가져오기
      uint va = PGROUNDDOWN(rcr2());
8010660e:	e8 2b fd ff ff       	call   8010633e <rcr2>
80106613:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106618:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     // 물리 메모리 한 페이지 할당
      char *mem = kalloc();
8010661b:	e8 72 c6 ff ff       	call   80102c92 <kalloc>
80106620:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(mem == 0){
80106623:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80106627:	75 18                	jne    80106641 <trap+0x158>
        cprintf("[trap] out of memory at 0x%x\n", va);
80106629:	83 ec 08             	sub    $0x8,%esp
8010662c:	ff 75 e4             	push   -0x1c(%ebp)
8010662f:	68 c0 aa 10 80       	push   $0x8010aac0
80106634:	e8 bb 9d ff ff       	call   801003f4 <cprintf>
80106639:	83 c4 10             	add    $0x10,%esp
        break;
8010663c:	e9 2b 01 00 00       	jmp    8010676c <trap+0x283>
      }

      // 페이지 내용 초기화 후 매핑
      memset(mem, 0, PGSIZE);
80106641:	83 ec 04             	sub    $0x4,%esp
80106644:	68 00 10 00 00       	push   $0x1000
80106649:	6a 00                	push   $0x0
8010664b:	ff 75 e0             	push   -0x20(%ebp)
8010664e:	e8 20 e9 ff ff       	call   80104f73 <memset>
80106653:	83 c4 10             	add    $0x10,%esp
      mappages(myproc()->pgdir, (char*)va, PGSIZE, V2P(mem), PTE_W | PTE_U | PTE_P);
80106656:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106659:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
8010665f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80106662:	e8 bb d8 ff ff       	call   80103f22 <myproc>
80106667:	8b 40 04             	mov    0x4(%eax),%eax
8010666a:	83 ec 0c             	sub    $0xc,%esp
8010666d:	6a 07                	push   $0x7
8010666f:	56                   	push   %esi
80106670:	68 00 10 00 00       	push   $0x1000
80106675:	53                   	push   %ebx
80106676:	50                   	push   %eax
80106677:	e8 0a 12 00 00       	call   80107886 <mappages>
8010667c:	83 c4 20             	add    $0x20,%esp
      walkpgdir( myproc()->pgdir, (char*)va, 0);
8010667f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80106682:	e8 9b d8 ff ff       	call   80103f22 <myproc>
80106687:	8b 40 04             	mov    0x4(%eax),%eax
8010668a:	83 ec 04             	sub    $0x4,%esp
8010668d:	6a 00                	push   $0x0
8010668f:	53                   	push   %ebx
80106690:	50                   	push   %eax
80106691:	e8 5a 11 00 00       	call   801077f0 <walkpgdir>
80106696:	83 c4 10             	add    $0x10,%esp

      // TLB flush (페이지 테이블 갱신 반영)
      lcr3(V2P(myproc()->pgdir));
80106699:	e8 84 d8 ff ff       	call   80103f22 <myproc>
8010669e:	8b 40 04             	mov    0x4(%eax),%eax
801066a1:	05 00 00 00 80       	add    $0x80000000,%eax
801066a6:	83 ec 0c             	sub    $0xc,%esp
801066a9:	50                   	push   %eax
801066aa:	e8 a0 fc ff ff       	call   8010634f <lcr3>
801066af:	83 c4 10             	add    $0x10,%esp
      break;
801066b2:	e9 b5 00 00 00       	jmp    8010676c <trap+0x283>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801066b7:	e8 66 d8 ff ff       	call   80103f22 <myproc>
801066bc:	85 c0                	test   %eax,%eax
801066be:	74 11                	je     801066d1 <trap+0x1e8>
801066c0:	8b 45 08             	mov    0x8(%ebp),%eax
801066c3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066c7:	0f b7 c0             	movzwl %ax,%eax
801066ca:	83 e0 03             	and    $0x3,%eax
801066cd:	85 c0                	test   %eax,%eax
801066cf:	75 39                	jne    8010670a <trap+0x221>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801066d1:	e8 68 fc ff ff       	call   8010633e <rcr2>
801066d6:	89 c3                	mov    %eax,%ebx
801066d8:	8b 45 08             	mov    0x8(%ebp),%eax
801066db:	8b 70 38             	mov    0x38(%eax),%esi
801066de:	e8 ac d7 ff ff       	call   80103e8f <cpuid>
801066e3:	8b 55 08             	mov    0x8(%ebp),%edx
801066e6:	8b 52 30             	mov    0x30(%edx),%edx
801066e9:	83 ec 0c             	sub    $0xc,%esp
801066ec:	53                   	push   %ebx
801066ed:	56                   	push   %esi
801066ee:	50                   	push   %eax
801066ef:	52                   	push   %edx
801066f0:	68 e0 aa 10 80       	push   $0x8010aae0
801066f5:	e8 fa 9c ff ff       	call   801003f4 <cprintf>
801066fa:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801066fd:	83 ec 0c             	sub    $0xc,%esp
80106700:	68 12 ab 10 80       	push   $0x8010ab12
80106705:	e8 b7 9e ff ff       	call   801005c1 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010670a:	e8 2f fc ff ff       	call   8010633e <rcr2>
8010670f:	89 c6                	mov    %eax,%esi
80106711:	8b 45 08             	mov    0x8(%ebp),%eax
80106714:	8b 40 38             	mov    0x38(%eax),%eax
80106717:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010671a:	e8 70 d7 ff ff       	call   80103e8f <cpuid>
8010671f:	89 c3                	mov    %eax,%ebx
80106721:	8b 45 08             	mov    0x8(%ebp),%eax
80106724:	8b 48 34             	mov    0x34(%eax),%ecx
80106727:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010672a:	8b 45 08             	mov    0x8(%ebp),%eax
8010672d:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106730:	e8 ed d7 ff ff       	call   80103f22 <myproc>
80106735:	8d 50 6c             	lea    0x6c(%eax),%edx
80106738:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010673b:	e8 e2 d7 ff ff       	call   80103f22 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106740:	8b 40 10             	mov    0x10(%eax),%eax
80106743:	56                   	push   %esi
80106744:	ff 75 d4             	push   -0x2c(%ebp)
80106747:	53                   	push   %ebx
80106748:	ff 75 d0             	push   -0x30(%ebp)
8010674b:	57                   	push   %edi
8010674c:	ff 75 cc             	push   -0x34(%ebp)
8010674f:	50                   	push   %eax
80106750:	68 18 ab 10 80       	push   $0x8010ab18
80106755:	e8 9a 9c ff ff       	call   801003f4 <cprintf>
8010675a:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010675d:	e8 c0 d7 ff ff       	call   80103f22 <myproc>
80106762:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106769:	eb 01                	jmp    8010676c <trap+0x283>
    break;
8010676b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010676c:	e8 b1 d7 ff ff       	call   80103f22 <myproc>
80106771:	85 c0                	test   %eax,%eax
80106773:	74 23                	je     80106798 <trap+0x2af>
80106775:	e8 a8 d7 ff ff       	call   80103f22 <myproc>
8010677a:	8b 40 24             	mov    0x24(%eax),%eax
8010677d:	85 c0                	test   %eax,%eax
8010677f:	74 17                	je     80106798 <trap+0x2af>
80106781:	8b 45 08             	mov    0x8(%ebp),%eax
80106784:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106788:	0f b7 c0             	movzwl %ax,%eax
8010678b:	83 e0 03             	and    $0x3,%eax
8010678e:	83 f8 03             	cmp    $0x3,%eax
80106791:	75 05                	jne    80106798 <trap+0x2af>
    exit();
80106793:	e8 02 dc ff ff       	call   8010439a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106798:	e8 85 d7 ff ff       	call   80103f22 <myproc>
8010679d:	85 c0                	test   %eax,%eax
8010679f:	74 1d                	je     801067be <trap+0x2d5>
801067a1:	e8 7c d7 ff ff       	call   80103f22 <myproc>
801067a6:	8b 40 0c             	mov    0xc(%eax),%eax
801067a9:	83 f8 04             	cmp    $0x4,%eax
801067ac:	75 10                	jne    801067be <trap+0x2d5>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801067ae:	8b 45 08             	mov    0x8(%ebp),%eax
801067b1:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801067b4:	83 f8 20             	cmp    $0x20,%eax
801067b7:	75 05                	jne    801067be <trap+0x2d5>
    yield();
801067b9:	e8 8d df ff ff       	call   8010474b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067be:	e8 5f d7 ff ff       	call   80103f22 <myproc>
801067c3:	85 c0                	test   %eax,%eax
801067c5:	74 26                	je     801067ed <trap+0x304>
801067c7:	e8 56 d7 ff ff       	call   80103f22 <myproc>
801067cc:	8b 40 24             	mov    0x24(%eax),%eax
801067cf:	85 c0                	test   %eax,%eax
801067d1:	74 1a                	je     801067ed <trap+0x304>
801067d3:	8b 45 08             	mov    0x8(%ebp),%eax
801067d6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067da:	0f b7 c0             	movzwl %ax,%eax
801067dd:	83 e0 03             	and    $0x3,%eax
801067e0:	83 f8 03             	cmp    $0x3,%eax
801067e3:	75 08                	jne    801067ed <trap+0x304>
    exit();
801067e5:	e8 b0 db ff ff       	call   8010439a <exit>
801067ea:	eb 01                	jmp    801067ed <trap+0x304>
    return;
801067ec:	90                   	nop
}
801067ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067f0:	5b                   	pop    %ebx
801067f1:	5e                   	pop    %esi
801067f2:	5f                   	pop    %edi
801067f3:	5d                   	pop    %ebp
801067f4:	c3                   	ret    

801067f5 <inb>:
{
801067f5:	55                   	push   %ebp
801067f6:	89 e5                	mov    %esp,%ebp
801067f8:	83 ec 14             	sub    $0x14,%esp
801067fb:	8b 45 08             	mov    0x8(%ebp),%eax
801067fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106806:	89 c2                	mov    %eax,%edx
80106808:	ec                   	in     (%dx),%al
80106809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010680c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106810:	c9                   	leave  
80106811:	c3                   	ret    

80106812 <outb>:
{
80106812:	55                   	push   %ebp
80106813:	89 e5                	mov    %esp,%ebp
80106815:	83 ec 08             	sub    $0x8,%esp
80106818:	8b 45 08             	mov    0x8(%ebp),%eax
8010681b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010681e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106822:	89 d0                	mov    %edx,%eax
80106824:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106827:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010682b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010682f:	ee                   	out    %al,(%dx)
}
80106830:	90                   	nop
80106831:	c9                   	leave  
80106832:	c3                   	ret    

80106833 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106833:	55                   	push   %ebp
80106834:	89 e5                	mov    %esp,%ebp
80106836:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106839:	6a 00                	push   $0x0
8010683b:	68 fa 03 00 00       	push   $0x3fa
80106840:	e8 cd ff ff ff       	call   80106812 <outb>
80106845:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106848:	68 80 00 00 00       	push   $0x80
8010684d:	68 fb 03 00 00       	push   $0x3fb
80106852:	e8 bb ff ff ff       	call   80106812 <outb>
80106857:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010685a:	6a 0c                	push   $0xc
8010685c:	68 f8 03 00 00       	push   $0x3f8
80106861:	e8 ac ff ff ff       	call   80106812 <outb>
80106866:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106869:	6a 00                	push   $0x0
8010686b:	68 f9 03 00 00       	push   $0x3f9
80106870:	e8 9d ff ff ff       	call   80106812 <outb>
80106875:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106878:	6a 03                	push   $0x3
8010687a:	68 fb 03 00 00       	push   $0x3fb
8010687f:	e8 8e ff ff ff       	call   80106812 <outb>
80106884:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106887:	6a 00                	push   $0x0
80106889:	68 fc 03 00 00       	push   $0x3fc
8010688e:	e8 7f ff ff ff       	call   80106812 <outb>
80106893:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106896:	6a 01                	push   $0x1
80106898:	68 f9 03 00 00       	push   $0x3f9
8010689d:	e8 70 ff ff ff       	call   80106812 <outb>
801068a2:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801068a5:	68 fd 03 00 00       	push   $0x3fd
801068aa:	e8 46 ff ff ff       	call   801067f5 <inb>
801068af:	83 c4 04             	add    $0x4,%esp
801068b2:	3c ff                	cmp    $0xff,%al
801068b4:	74 61                	je     80106917 <uartinit+0xe4>
    return;
  uart = 1;
801068b6:	c7 05 b8 99 11 80 01 	movl   $0x1,0x801199b8
801068bd:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801068c0:	68 fa 03 00 00       	push   $0x3fa
801068c5:	e8 2b ff ff ff       	call   801067f5 <inb>
801068ca:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801068cd:	68 f8 03 00 00       	push   $0x3f8
801068d2:	e8 1e ff ff ff       	call   801067f5 <inb>
801068d7:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801068da:	83 ec 08             	sub    $0x8,%esp
801068dd:	6a 00                	push   $0x0
801068df:	6a 04                	push   $0x4
801068e1:	e8 3a c2 ff ff       	call   80102b20 <ioapicenable>
801068e6:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801068e9:	c7 45 f4 24 ac 10 80 	movl   $0x8010ac24,-0xc(%ebp)
801068f0:	eb 19                	jmp    8010690b <uartinit+0xd8>
    uartputc(*p);
801068f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f5:	0f b6 00             	movzbl (%eax),%eax
801068f8:	0f be c0             	movsbl %al,%eax
801068fb:	83 ec 0c             	sub    $0xc,%esp
801068fe:	50                   	push   %eax
801068ff:	e8 16 00 00 00       	call   8010691a <uartputc>
80106904:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106907:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010690b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690e:	0f b6 00             	movzbl (%eax),%eax
80106911:	84 c0                	test   %al,%al
80106913:	75 dd                	jne    801068f2 <uartinit+0xbf>
80106915:	eb 01                	jmp    80106918 <uartinit+0xe5>
    return;
80106917:	90                   	nop
}
80106918:	c9                   	leave  
80106919:	c3                   	ret    

8010691a <uartputc>:

void
uartputc(int c)
{
8010691a:	55                   	push   %ebp
8010691b:	89 e5                	mov    %esp,%ebp
8010691d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106920:	a1 b8 99 11 80       	mov    0x801199b8,%eax
80106925:	85 c0                	test   %eax,%eax
80106927:	74 53                	je     8010697c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106930:	eb 11                	jmp    80106943 <uartputc+0x29>
    microdelay(10);
80106932:	83 ec 0c             	sub    $0xc,%esp
80106935:	6a 0a                	push   $0xa
80106937:	e8 ed c6 ff ff       	call   80103029 <microdelay>
8010693c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010693f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106943:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106947:	7f 1a                	jg     80106963 <uartputc+0x49>
80106949:	83 ec 0c             	sub    $0xc,%esp
8010694c:	68 fd 03 00 00       	push   $0x3fd
80106951:	e8 9f fe ff ff       	call   801067f5 <inb>
80106956:	83 c4 10             	add    $0x10,%esp
80106959:	0f b6 c0             	movzbl %al,%eax
8010695c:	83 e0 20             	and    $0x20,%eax
8010695f:	85 c0                	test   %eax,%eax
80106961:	74 cf                	je     80106932 <uartputc+0x18>
  outb(COM1+0, c);
80106963:	8b 45 08             	mov    0x8(%ebp),%eax
80106966:	0f b6 c0             	movzbl %al,%eax
80106969:	83 ec 08             	sub    $0x8,%esp
8010696c:	50                   	push   %eax
8010696d:	68 f8 03 00 00       	push   $0x3f8
80106972:	e8 9b fe ff ff       	call   80106812 <outb>
80106977:	83 c4 10             	add    $0x10,%esp
8010697a:	eb 01                	jmp    8010697d <uartputc+0x63>
    return;
8010697c:	90                   	nop
}
8010697d:	c9                   	leave  
8010697e:	c3                   	ret    

8010697f <uartgetc>:

static int
uartgetc(void)
{
8010697f:	55                   	push   %ebp
80106980:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106982:	a1 b8 99 11 80       	mov    0x801199b8,%eax
80106987:	85 c0                	test   %eax,%eax
80106989:	75 07                	jne    80106992 <uartgetc+0x13>
    return -1;
8010698b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106990:	eb 2e                	jmp    801069c0 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106992:	68 fd 03 00 00       	push   $0x3fd
80106997:	e8 59 fe ff ff       	call   801067f5 <inb>
8010699c:	83 c4 04             	add    $0x4,%esp
8010699f:	0f b6 c0             	movzbl %al,%eax
801069a2:	83 e0 01             	and    $0x1,%eax
801069a5:	85 c0                	test   %eax,%eax
801069a7:	75 07                	jne    801069b0 <uartgetc+0x31>
    return -1;
801069a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ae:	eb 10                	jmp    801069c0 <uartgetc+0x41>
  return inb(COM1+0);
801069b0:	68 f8 03 00 00       	push   $0x3f8
801069b5:	e8 3b fe ff ff       	call   801067f5 <inb>
801069ba:	83 c4 04             	add    $0x4,%esp
801069bd:	0f b6 c0             	movzbl %al,%eax
}
801069c0:	c9                   	leave  
801069c1:	c3                   	ret    

801069c2 <uartintr>:

void
uartintr(void)
{
801069c2:	55                   	push   %ebp
801069c3:	89 e5                	mov    %esp,%ebp
801069c5:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801069c8:	83 ec 0c             	sub    $0xc,%esp
801069cb:	68 7f 69 10 80       	push   $0x8010697f
801069d0:	e8 19 9e ff ff       	call   801007ee <consoleintr>
801069d5:	83 c4 10             	add    $0x10,%esp
}
801069d8:	90                   	nop
801069d9:	c9                   	leave  
801069da:	c3                   	ret    

801069db <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $0
801069dd:	6a 00                	push   $0x0
  jmp alltraps
801069df:	e9 0d f9 ff ff       	jmp    801062f1 <alltraps>

801069e4 <vector1>:
.globl vector1
vector1:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $1
801069e6:	6a 01                	push   $0x1
  jmp alltraps
801069e8:	e9 04 f9 ff ff       	jmp    801062f1 <alltraps>

801069ed <vector2>:
.globl vector2
vector2:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $2
801069ef:	6a 02                	push   $0x2
  jmp alltraps
801069f1:	e9 fb f8 ff ff       	jmp    801062f1 <alltraps>

801069f6 <vector3>:
.globl vector3
vector3:
  pushl $0
801069f6:	6a 00                	push   $0x0
  pushl $3
801069f8:	6a 03                	push   $0x3
  jmp alltraps
801069fa:	e9 f2 f8 ff ff       	jmp    801062f1 <alltraps>

801069ff <vector4>:
.globl vector4
vector4:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $4
80106a01:	6a 04                	push   $0x4
  jmp alltraps
80106a03:	e9 e9 f8 ff ff       	jmp    801062f1 <alltraps>

80106a08 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $5
80106a0a:	6a 05                	push   $0x5
  jmp alltraps
80106a0c:	e9 e0 f8 ff ff       	jmp    801062f1 <alltraps>

80106a11 <vector6>:
.globl vector6
vector6:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $6
80106a13:	6a 06                	push   $0x6
  jmp alltraps
80106a15:	e9 d7 f8 ff ff       	jmp    801062f1 <alltraps>

80106a1a <vector7>:
.globl vector7
vector7:
  pushl $0
80106a1a:	6a 00                	push   $0x0
  pushl $7
80106a1c:	6a 07                	push   $0x7
  jmp alltraps
80106a1e:	e9 ce f8 ff ff       	jmp    801062f1 <alltraps>

80106a23 <vector8>:
.globl vector8
vector8:
  pushl $8
80106a23:	6a 08                	push   $0x8
  jmp alltraps
80106a25:	e9 c7 f8 ff ff       	jmp    801062f1 <alltraps>

80106a2a <vector9>:
.globl vector9
vector9:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $9
80106a2c:	6a 09                	push   $0x9
  jmp alltraps
80106a2e:	e9 be f8 ff ff       	jmp    801062f1 <alltraps>

80106a33 <vector10>:
.globl vector10
vector10:
  pushl $10
80106a33:	6a 0a                	push   $0xa
  jmp alltraps
80106a35:	e9 b7 f8 ff ff       	jmp    801062f1 <alltraps>

80106a3a <vector11>:
.globl vector11
vector11:
  pushl $11
80106a3a:	6a 0b                	push   $0xb
  jmp alltraps
80106a3c:	e9 b0 f8 ff ff       	jmp    801062f1 <alltraps>

80106a41 <vector12>:
.globl vector12
vector12:
  pushl $12
80106a41:	6a 0c                	push   $0xc
  jmp alltraps
80106a43:	e9 a9 f8 ff ff       	jmp    801062f1 <alltraps>

80106a48 <vector13>:
.globl vector13
vector13:
  pushl $13
80106a48:	6a 0d                	push   $0xd
  jmp alltraps
80106a4a:	e9 a2 f8 ff ff       	jmp    801062f1 <alltraps>

80106a4f <vector14>:
.globl vector14
vector14:
  pushl $14
80106a4f:	6a 0e                	push   $0xe
  jmp alltraps
80106a51:	e9 9b f8 ff ff       	jmp    801062f1 <alltraps>

80106a56 <vector15>:
.globl vector15
vector15:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $15
80106a58:	6a 0f                	push   $0xf
  jmp alltraps
80106a5a:	e9 92 f8 ff ff       	jmp    801062f1 <alltraps>

80106a5f <vector16>:
.globl vector16
vector16:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $16
80106a61:	6a 10                	push   $0x10
  jmp alltraps
80106a63:	e9 89 f8 ff ff       	jmp    801062f1 <alltraps>

80106a68 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a68:	6a 11                	push   $0x11
  jmp alltraps
80106a6a:	e9 82 f8 ff ff       	jmp    801062f1 <alltraps>

80106a6f <vector18>:
.globl vector18
vector18:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $18
80106a71:	6a 12                	push   $0x12
  jmp alltraps
80106a73:	e9 79 f8 ff ff       	jmp    801062f1 <alltraps>

80106a78 <vector19>:
.globl vector19
vector19:
  pushl $0
80106a78:	6a 00                	push   $0x0
  pushl $19
80106a7a:	6a 13                	push   $0x13
  jmp alltraps
80106a7c:	e9 70 f8 ff ff       	jmp    801062f1 <alltraps>

80106a81 <vector20>:
.globl vector20
vector20:
  pushl $0
80106a81:	6a 00                	push   $0x0
  pushl $20
80106a83:	6a 14                	push   $0x14
  jmp alltraps
80106a85:	e9 67 f8 ff ff       	jmp    801062f1 <alltraps>

80106a8a <vector21>:
.globl vector21
vector21:
  pushl $0
80106a8a:	6a 00                	push   $0x0
  pushl $21
80106a8c:	6a 15                	push   $0x15
  jmp alltraps
80106a8e:	e9 5e f8 ff ff       	jmp    801062f1 <alltraps>

80106a93 <vector22>:
.globl vector22
vector22:
  pushl $0
80106a93:	6a 00                	push   $0x0
  pushl $22
80106a95:	6a 16                	push   $0x16
  jmp alltraps
80106a97:	e9 55 f8 ff ff       	jmp    801062f1 <alltraps>

80106a9c <vector23>:
.globl vector23
vector23:
  pushl $0
80106a9c:	6a 00                	push   $0x0
  pushl $23
80106a9e:	6a 17                	push   $0x17
  jmp alltraps
80106aa0:	e9 4c f8 ff ff       	jmp    801062f1 <alltraps>

80106aa5 <vector24>:
.globl vector24
vector24:
  pushl $0
80106aa5:	6a 00                	push   $0x0
  pushl $24
80106aa7:	6a 18                	push   $0x18
  jmp alltraps
80106aa9:	e9 43 f8 ff ff       	jmp    801062f1 <alltraps>

80106aae <vector25>:
.globl vector25
vector25:
  pushl $0
80106aae:	6a 00                	push   $0x0
  pushl $25
80106ab0:	6a 19                	push   $0x19
  jmp alltraps
80106ab2:	e9 3a f8 ff ff       	jmp    801062f1 <alltraps>

80106ab7 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ab7:	6a 00                	push   $0x0
  pushl $26
80106ab9:	6a 1a                	push   $0x1a
  jmp alltraps
80106abb:	e9 31 f8 ff ff       	jmp    801062f1 <alltraps>

80106ac0 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ac0:	6a 00                	push   $0x0
  pushl $27
80106ac2:	6a 1b                	push   $0x1b
  jmp alltraps
80106ac4:	e9 28 f8 ff ff       	jmp    801062f1 <alltraps>

80106ac9 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ac9:	6a 00                	push   $0x0
  pushl $28
80106acb:	6a 1c                	push   $0x1c
  jmp alltraps
80106acd:	e9 1f f8 ff ff       	jmp    801062f1 <alltraps>

80106ad2 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ad2:	6a 00                	push   $0x0
  pushl $29
80106ad4:	6a 1d                	push   $0x1d
  jmp alltraps
80106ad6:	e9 16 f8 ff ff       	jmp    801062f1 <alltraps>

80106adb <vector30>:
.globl vector30
vector30:
  pushl $0
80106adb:	6a 00                	push   $0x0
  pushl $30
80106add:	6a 1e                	push   $0x1e
  jmp alltraps
80106adf:	e9 0d f8 ff ff       	jmp    801062f1 <alltraps>

80106ae4 <vector31>:
.globl vector31
vector31:
  pushl $0
80106ae4:	6a 00                	push   $0x0
  pushl $31
80106ae6:	6a 1f                	push   $0x1f
  jmp alltraps
80106ae8:	e9 04 f8 ff ff       	jmp    801062f1 <alltraps>

80106aed <vector32>:
.globl vector32
vector32:
  pushl $0
80106aed:	6a 00                	push   $0x0
  pushl $32
80106aef:	6a 20                	push   $0x20
  jmp alltraps
80106af1:	e9 fb f7 ff ff       	jmp    801062f1 <alltraps>

80106af6 <vector33>:
.globl vector33
vector33:
  pushl $0
80106af6:	6a 00                	push   $0x0
  pushl $33
80106af8:	6a 21                	push   $0x21
  jmp alltraps
80106afa:	e9 f2 f7 ff ff       	jmp    801062f1 <alltraps>

80106aff <vector34>:
.globl vector34
vector34:
  pushl $0
80106aff:	6a 00                	push   $0x0
  pushl $34
80106b01:	6a 22                	push   $0x22
  jmp alltraps
80106b03:	e9 e9 f7 ff ff       	jmp    801062f1 <alltraps>

80106b08 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b08:	6a 00                	push   $0x0
  pushl $35
80106b0a:	6a 23                	push   $0x23
  jmp alltraps
80106b0c:	e9 e0 f7 ff ff       	jmp    801062f1 <alltraps>

80106b11 <vector36>:
.globl vector36
vector36:
  pushl $0
80106b11:	6a 00                	push   $0x0
  pushl $36
80106b13:	6a 24                	push   $0x24
  jmp alltraps
80106b15:	e9 d7 f7 ff ff       	jmp    801062f1 <alltraps>

80106b1a <vector37>:
.globl vector37
vector37:
  pushl $0
80106b1a:	6a 00                	push   $0x0
  pushl $37
80106b1c:	6a 25                	push   $0x25
  jmp alltraps
80106b1e:	e9 ce f7 ff ff       	jmp    801062f1 <alltraps>

80106b23 <vector38>:
.globl vector38
vector38:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $38
80106b25:	6a 26                	push   $0x26
  jmp alltraps
80106b27:	e9 c5 f7 ff ff       	jmp    801062f1 <alltraps>

80106b2c <vector39>:
.globl vector39
vector39:
  pushl $0
80106b2c:	6a 00                	push   $0x0
  pushl $39
80106b2e:	6a 27                	push   $0x27
  jmp alltraps
80106b30:	e9 bc f7 ff ff       	jmp    801062f1 <alltraps>

80106b35 <vector40>:
.globl vector40
vector40:
  pushl $0
80106b35:	6a 00                	push   $0x0
  pushl $40
80106b37:	6a 28                	push   $0x28
  jmp alltraps
80106b39:	e9 b3 f7 ff ff       	jmp    801062f1 <alltraps>

80106b3e <vector41>:
.globl vector41
vector41:
  pushl $0
80106b3e:	6a 00                	push   $0x0
  pushl $41
80106b40:	6a 29                	push   $0x29
  jmp alltraps
80106b42:	e9 aa f7 ff ff       	jmp    801062f1 <alltraps>

80106b47 <vector42>:
.globl vector42
vector42:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $42
80106b49:	6a 2a                	push   $0x2a
  jmp alltraps
80106b4b:	e9 a1 f7 ff ff       	jmp    801062f1 <alltraps>

80106b50 <vector43>:
.globl vector43
vector43:
  pushl $0
80106b50:	6a 00                	push   $0x0
  pushl $43
80106b52:	6a 2b                	push   $0x2b
  jmp alltraps
80106b54:	e9 98 f7 ff ff       	jmp    801062f1 <alltraps>

80106b59 <vector44>:
.globl vector44
vector44:
  pushl $0
80106b59:	6a 00                	push   $0x0
  pushl $44
80106b5b:	6a 2c                	push   $0x2c
  jmp alltraps
80106b5d:	e9 8f f7 ff ff       	jmp    801062f1 <alltraps>

80106b62 <vector45>:
.globl vector45
vector45:
  pushl $0
80106b62:	6a 00                	push   $0x0
  pushl $45
80106b64:	6a 2d                	push   $0x2d
  jmp alltraps
80106b66:	e9 86 f7 ff ff       	jmp    801062f1 <alltraps>

80106b6b <vector46>:
.globl vector46
vector46:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $46
80106b6d:	6a 2e                	push   $0x2e
  jmp alltraps
80106b6f:	e9 7d f7 ff ff       	jmp    801062f1 <alltraps>

80106b74 <vector47>:
.globl vector47
vector47:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $47
80106b76:	6a 2f                	push   $0x2f
  jmp alltraps
80106b78:	e9 74 f7 ff ff       	jmp    801062f1 <alltraps>

80106b7d <vector48>:
.globl vector48
vector48:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $48
80106b7f:	6a 30                	push   $0x30
  jmp alltraps
80106b81:	e9 6b f7 ff ff       	jmp    801062f1 <alltraps>

80106b86 <vector49>:
.globl vector49
vector49:
  pushl $0
80106b86:	6a 00                	push   $0x0
  pushl $49
80106b88:	6a 31                	push   $0x31
  jmp alltraps
80106b8a:	e9 62 f7 ff ff       	jmp    801062f1 <alltraps>

80106b8f <vector50>:
.globl vector50
vector50:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $50
80106b91:	6a 32                	push   $0x32
  jmp alltraps
80106b93:	e9 59 f7 ff ff       	jmp    801062f1 <alltraps>

80106b98 <vector51>:
.globl vector51
vector51:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $51
80106b9a:	6a 33                	push   $0x33
  jmp alltraps
80106b9c:	e9 50 f7 ff ff       	jmp    801062f1 <alltraps>

80106ba1 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ba1:	6a 00                	push   $0x0
  pushl $52
80106ba3:	6a 34                	push   $0x34
  jmp alltraps
80106ba5:	e9 47 f7 ff ff       	jmp    801062f1 <alltraps>

80106baa <vector53>:
.globl vector53
vector53:
  pushl $0
80106baa:	6a 00                	push   $0x0
  pushl $53
80106bac:	6a 35                	push   $0x35
  jmp alltraps
80106bae:	e9 3e f7 ff ff       	jmp    801062f1 <alltraps>

80106bb3 <vector54>:
.globl vector54
vector54:
  pushl $0
80106bb3:	6a 00                	push   $0x0
  pushl $54
80106bb5:	6a 36                	push   $0x36
  jmp alltraps
80106bb7:	e9 35 f7 ff ff       	jmp    801062f1 <alltraps>

80106bbc <vector55>:
.globl vector55
vector55:
  pushl $0
80106bbc:	6a 00                	push   $0x0
  pushl $55
80106bbe:	6a 37                	push   $0x37
  jmp alltraps
80106bc0:	e9 2c f7 ff ff       	jmp    801062f1 <alltraps>

80106bc5 <vector56>:
.globl vector56
vector56:
  pushl $0
80106bc5:	6a 00                	push   $0x0
  pushl $56
80106bc7:	6a 38                	push   $0x38
  jmp alltraps
80106bc9:	e9 23 f7 ff ff       	jmp    801062f1 <alltraps>

80106bce <vector57>:
.globl vector57
vector57:
  pushl $0
80106bce:	6a 00                	push   $0x0
  pushl $57
80106bd0:	6a 39                	push   $0x39
  jmp alltraps
80106bd2:	e9 1a f7 ff ff       	jmp    801062f1 <alltraps>

80106bd7 <vector58>:
.globl vector58
vector58:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $58
80106bd9:	6a 3a                	push   $0x3a
  jmp alltraps
80106bdb:	e9 11 f7 ff ff       	jmp    801062f1 <alltraps>

80106be0 <vector59>:
.globl vector59
vector59:
  pushl $0
80106be0:	6a 00                	push   $0x0
  pushl $59
80106be2:	6a 3b                	push   $0x3b
  jmp alltraps
80106be4:	e9 08 f7 ff ff       	jmp    801062f1 <alltraps>

80106be9 <vector60>:
.globl vector60
vector60:
  pushl $0
80106be9:	6a 00                	push   $0x0
  pushl $60
80106beb:	6a 3c                	push   $0x3c
  jmp alltraps
80106bed:	e9 ff f6 ff ff       	jmp    801062f1 <alltraps>

80106bf2 <vector61>:
.globl vector61
vector61:
  pushl $0
80106bf2:	6a 00                	push   $0x0
  pushl $61
80106bf4:	6a 3d                	push   $0x3d
  jmp alltraps
80106bf6:	e9 f6 f6 ff ff       	jmp    801062f1 <alltraps>

80106bfb <vector62>:
.globl vector62
vector62:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $62
80106bfd:	6a 3e                	push   $0x3e
  jmp alltraps
80106bff:	e9 ed f6 ff ff       	jmp    801062f1 <alltraps>

80106c04 <vector63>:
.globl vector63
vector63:
  pushl $0
80106c04:	6a 00                	push   $0x0
  pushl $63
80106c06:	6a 3f                	push   $0x3f
  jmp alltraps
80106c08:	e9 e4 f6 ff ff       	jmp    801062f1 <alltraps>

80106c0d <vector64>:
.globl vector64
vector64:
  pushl $0
80106c0d:	6a 00                	push   $0x0
  pushl $64
80106c0f:	6a 40                	push   $0x40
  jmp alltraps
80106c11:	e9 db f6 ff ff       	jmp    801062f1 <alltraps>

80106c16 <vector65>:
.globl vector65
vector65:
  pushl $0
80106c16:	6a 00                	push   $0x0
  pushl $65
80106c18:	6a 41                	push   $0x41
  jmp alltraps
80106c1a:	e9 d2 f6 ff ff       	jmp    801062f1 <alltraps>

80106c1f <vector66>:
.globl vector66
vector66:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $66
80106c21:	6a 42                	push   $0x42
  jmp alltraps
80106c23:	e9 c9 f6 ff ff       	jmp    801062f1 <alltraps>

80106c28 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c28:	6a 00                	push   $0x0
  pushl $67
80106c2a:	6a 43                	push   $0x43
  jmp alltraps
80106c2c:	e9 c0 f6 ff ff       	jmp    801062f1 <alltraps>

80106c31 <vector68>:
.globl vector68
vector68:
  pushl $0
80106c31:	6a 00                	push   $0x0
  pushl $68
80106c33:	6a 44                	push   $0x44
  jmp alltraps
80106c35:	e9 b7 f6 ff ff       	jmp    801062f1 <alltraps>

80106c3a <vector69>:
.globl vector69
vector69:
  pushl $0
80106c3a:	6a 00                	push   $0x0
  pushl $69
80106c3c:	6a 45                	push   $0x45
  jmp alltraps
80106c3e:	e9 ae f6 ff ff       	jmp    801062f1 <alltraps>

80106c43 <vector70>:
.globl vector70
vector70:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $70
80106c45:	6a 46                	push   $0x46
  jmp alltraps
80106c47:	e9 a5 f6 ff ff       	jmp    801062f1 <alltraps>

80106c4c <vector71>:
.globl vector71
vector71:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $71
80106c4e:	6a 47                	push   $0x47
  jmp alltraps
80106c50:	e9 9c f6 ff ff       	jmp    801062f1 <alltraps>

80106c55 <vector72>:
.globl vector72
vector72:
  pushl $0
80106c55:	6a 00                	push   $0x0
  pushl $72
80106c57:	6a 48                	push   $0x48
  jmp alltraps
80106c59:	e9 93 f6 ff ff       	jmp    801062f1 <alltraps>

80106c5e <vector73>:
.globl vector73
vector73:
  pushl $0
80106c5e:	6a 00                	push   $0x0
  pushl $73
80106c60:	6a 49                	push   $0x49
  jmp alltraps
80106c62:	e9 8a f6 ff ff       	jmp    801062f1 <alltraps>

80106c67 <vector74>:
.globl vector74
vector74:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $74
80106c69:	6a 4a                	push   $0x4a
  jmp alltraps
80106c6b:	e9 81 f6 ff ff       	jmp    801062f1 <alltraps>

80106c70 <vector75>:
.globl vector75
vector75:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $75
80106c72:	6a 4b                	push   $0x4b
  jmp alltraps
80106c74:	e9 78 f6 ff ff       	jmp    801062f1 <alltraps>

80106c79 <vector76>:
.globl vector76
vector76:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $76
80106c7b:	6a 4c                	push   $0x4c
  jmp alltraps
80106c7d:	e9 6f f6 ff ff       	jmp    801062f1 <alltraps>

80106c82 <vector77>:
.globl vector77
vector77:
  pushl $0
80106c82:	6a 00                	push   $0x0
  pushl $77
80106c84:	6a 4d                	push   $0x4d
  jmp alltraps
80106c86:	e9 66 f6 ff ff       	jmp    801062f1 <alltraps>

80106c8b <vector78>:
.globl vector78
vector78:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $78
80106c8d:	6a 4e                	push   $0x4e
  jmp alltraps
80106c8f:	e9 5d f6 ff ff       	jmp    801062f1 <alltraps>

80106c94 <vector79>:
.globl vector79
vector79:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $79
80106c96:	6a 4f                	push   $0x4f
  jmp alltraps
80106c98:	e9 54 f6 ff ff       	jmp    801062f1 <alltraps>

80106c9d <vector80>:
.globl vector80
vector80:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $80
80106c9f:	6a 50                	push   $0x50
  jmp alltraps
80106ca1:	e9 4b f6 ff ff       	jmp    801062f1 <alltraps>

80106ca6 <vector81>:
.globl vector81
vector81:
  pushl $0
80106ca6:	6a 00                	push   $0x0
  pushl $81
80106ca8:	6a 51                	push   $0x51
  jmp alltraps
80106caa:	e9 42 f6 ff ff       	jmp    801062f1 <alltraps>

80106caf <vector82>:
.globl vector82
vector82:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $82
80106cb1:	6a 52                	push   $0x52
  jmp alltraps
80106cb3:	e9 39 f6 ff ff       	jmp    801062f1 <alltraps>

80106cb8 <vector83>:
.globl vector83
vector83:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $83
80106cba:	6a 53                	push   $0x53
  jmp alltraps
80106cbc:	e9 30 f6 ff ff       	jmp    801062f1 <alltraps>

80106cc1 <vector84>:
.globl vector84
vector84:
  pushl $0
80106cc1:	6a 00                	push   $0x0
  pushl $84
80106cc3:	6a 54                	push   $0x54
  jmp alltraps
80106cc5:	e9 27 f6 ff ff       	jmp    801062f1 <alltraps>

80106cca <vector85>:
.globl vector85
vector85:
  pushl $0
80106cca:	6a 00                	push   $0x0
  pushl $85
80106ccc:	6a 55                	push   $0x55
  jmp alltraps
80106cce:	e9 1e f6 ff ff       	jmp    801062f1 <alltraps>

80106cd3 <vector86>:
.globl vector86
vector86:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $86
80106cd5:	6a 56                	push   $0x56
  jmp alltraps
80106cd7:	e9 15 f6 ff ff       	jmp    801062f1 <alltraps>

80106cdc <vector87>:
.globl vector87
vector87:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $87
80106cde:	6a 57                	push   $0x57
  jmp alltraps
80106ce0:	e9 0c f6 ff ff       	jmp    801062f1 <alltraps>

80106ce5 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $88
80106ce7:	6a 58                	push   $0x58
  jmp alltraps
80106ce9:	e9 03 f6 ff ff       	jmp    801062f1 <alltraps>

80106cee <vector89>:
.globl vector89
vector89:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $89
80106cf0:	6a 59                	push   $0x59
  jmp alltraps
80106cf2:	e9 fa f5 ff ff       	jmp    801062f1 <alltraps>

80106cf7 <vector90>:
.globl vector90
vector90:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $90
80106cf9:	6a 5a                	push   $0x5a
  jmp alltraps
80106cfb:	e9 f1 f5 ff ff       	jmp    801062f1 <alltraps>

80106d00 <vector91>:
.globl vector91
vector91:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $91
80106d02:	6a 5b                	push   $0x5b
  jmp alltraps
80106d04:	e9 e8 f5 ff ff       	jmp    801062f1 <alltraps>

80106d09 <vector92>:
.globl vector92
vector92:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $92
80106d0b:	6a 5c                	push   $0x5c
  jmp alltraps
80106d0d:	e9 df f5 ff ff       	jmp    801062f1 <alltraps>

80106d12 <vector93>:
.globl vector93
vector93:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $93
80106d14:	6a 5d                	push   $0x5d
  jmp alltraps
80106d16:	e9 d6 f5 ff ff       	jmp    801062f1 <alltraps>

80106d1b <vector94>:
.globl vector94
vector94:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $94
80106d1d:	6a 5e                	push   $0x5e
  jmp alltraps
80106d1f:	e9 cd f5 ff ff       	jmp    801062f1 <alltraps>

80106d24 <vector95>:
.globl vector95
vector95:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $95
80106d26:	6a 5f                	push   $0x5f
  jmp alltraps
80106d28:	e9 c4 f5 ff ff       	jmp    801062f1 <alltraps>

80106d2d <vector96>:
.globl vector96
vector96:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $96
80106d2f:	6a 60                	push   $0x60
  jmp alltraps
80106d31:	e9 bb f5 ff ff       	jmp    801062f1 <alltraps>

80106d36 <vector97>:
.globl vector97
vector97:
  pushl $0
80106d36:	6a 00                	push   $0x0
  pushl $97
80106d38:	6a 61                	push   $0x61
  jmp alltraps
80106d3a:	e9 b2 f5 ff ff       	jmp    801062f1 <alltraps>

80106d3f <vector98>:
.globl vector98
vector98:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $98
80106d41:	6a 62                	push   $0x62
  jmp alltraps
80106d43:	e9 a9 f5 ff ff       	jmp    801062f1 <alltraps>

80106d48 <vector99>:
.globl vector99
vector99:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $99
80106d4a:	6a 63                	push   $0x63
  jmp alltraps
80106d4c:	e9 a0 f5 ff ff       	jmp    801062f1 <alltraps>

80106d51 <vector100>:
.globl vector100
vector100:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $100
80106d53:	6a 64                	push   $0x64
  jmp alltraps
80106d55:	e9 97 f5 ff ff       	jmp    801062f1 <alltraps>

80106d5a <vector101>:
.globl vector101
vector101:
  pushl $0
80106d5a:	6a 00                	push   $0x0
  pushl $101
80106d5c:	6a 65                	push   $0x65
  jmp alltraps
80106d5e:	e9 8e f5 ff ff       	jmp    801062f1 <alltraps>

80106d63 <vector102>:
.globl vector102
vector102:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $102
80106d65:	6a 66                	push   $0x66
  jmp alltraps
80106d67:	e9 85 f5 ff ff       	jmp    801062f1 <alltraps>

80106d6c <vector103>:
.globl vector103
vector103:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $103
80106d6e:	6a 67                	push   $0x67
  jmp alltraps
80106d70:	e9 7c f5 ff ff       	jmp    801062f1 <alltraps>

80106d75 <vector104>:
.globl vector104
vector104:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $104
80106d77:	6a 68                	push   $0x68
  jmp alltraps
80106d79:	e9 73 f5 ff ff       	jmp    801062f1 <alltraps>

80106d7e <vector105>:
.globl vector105
vector105:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $105
80106d80:	6a 69                	push   $0x69
  jmp alltraps
80106d82:	e9 6a f5 ff ff       	jmp    801062f1 <alltraps>

80106d87 <vector106>:
.globl vector106
vector106:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $106
80106d89:	6a 6a                	push   $0x6a
  jmp alltraps
80106d8b:	e9 61 f5 ff ff       	jmp    801062f1 <alltraps>

80106d90 <vector107>:
.globl vector107
vector107:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $107
80106d92:	6a 6b                	push   $0x6b
  jmp alltraps
80106d94:	e9 58 f5 ff ff       	jmp    801062f1 <alltraps>

80106d99 <vector108>:
.globl vector108
vector108:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $108
80106d9b:	6a 6c                	push   $0x6c
  jmp alltraps
80106d9d:	e9 4f f5 ff ff       	jmp    801062f1 <alltraps>

80106da2 <vector109>:
.globl vector109
vector109:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $109
80106da4:	6a 6d                	push   $0x6d
  jmp alltraps
80106da6:	e9 46 f5 ff ff       	jmp    801062f1 <alltraps>

80106dab <vector110>:
.globl vector110
vector110:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $110
80106dad:	6a 6e                	push   $0x6e
  jmp alltraps
80106daf:	e9 3d f5 ff ff       	jmp    801062f1 <alltraps>

80106db4 <vector111>:
.globl vector111
vector111:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $111
80106db6:	6a 6f                	push   $0x6f
  jmp alltraps
80106db8:	e9 34 f5 ff ff       	jmp    801062f1 <alltraps>

80106dbd <vector112>:
.globl vector112
vector112:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $112
80106dbf:	6a 70                	push   $0x70
  jmp alltraps
80106dc1:	e9 2b f5 ff ff       	jmp    801062f1 <alltraps>

80106dc6 <vector113>:
.globl vector113
vector113:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $113
80106dc8:	6a 71                	push   $0x71
  jmp alltraps
80106dca:	e9 22 f5 ff ff       	jmp    801062f1 <alltraps>

80106dcf <vector114>:
.globl vector114
vector114:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $114
80106dd1:	6a 72                	push   $0x72
  jmp alltraps
80106dd3:	e9 19 f5 ff ff       	jmp    801062f1 <alltraps>

80106dd8 <vector115>:
.globl vector115
vector115:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $115
80106dda:	6a 73                	push   $0x73
  jmp alltraps
80106ddc:	e9 10 f5 ff ff       	jmp    801062f1 <alltraps>

80106de1 <vector116>:
.globl vector116
vector116:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $116
80106de3:	6a 74                	push   $0x74
  jmp alltraps
80106de5:	e9 07 f5 ff ff       	jmp    801062f1 <alltraps>

80106dea <vector117>:
.globl vector117
vector117:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $117
80106dec:	6a 75                	push   $0x75
  jmp alltraps
80106dee:	e9 fe f4 ff ff       	jmp    801062f1 <alltraps>

80106df3 <vector118>:
.globl vector118
vector118:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $118
80106df5:	6a 76                	push   $0x76
  jmp alltraps
80106df7:	e9 f5 f4 ff ff       	jmp    801062f1 <alltraps>

80106dfc <vector119>:
.globl vector119
vector119:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $119
80106dfe:	6a 77                	push   $0x77
  jmp alltraps
80106e00:	e9 ec f4 ff ff       	jmp    801062f1 <alltraps>

80106e05 <vector120>:
.globl vector120
vector120:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $120
80106e07:	6a 78                	push   $0x78
  jmp alltraps
80106e09:	e9 e3 f4 ff ff       	jmp    801062f1 <alltraps>

80106e0e <vector121>:
.globl vector121
vector121:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $121
80106e10:	6a 79                	push   $0x79
  jmp alltraps
80106e12:	e9 da f4 ff ff       	jmp    801062f1 <alltraps>

80106e17 <vector122>:
.globl vector122
vector122:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $122
80106e19:	6a 7a                	push   $0x7a
  jmp alltraps
80106e1b:	e9 d1 f4 ff ff       	jmp    801062f1 <alltraps>

80106e20 <vector123>:
.globl vector123
vector123:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $123
80106e22:	6a 7b                	push   $0x7b
  jmp alltraps
80106e24:	e9 c8 f4 ff ff       	jmp    801062f1 <alltraps>

80106e29 <vector124>:
.globl vector124
vector124:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $124
80106e2b:	6a 7c                	push   $0x7c
  jmp alltraps
80106e2d:	e9 bf f4 ff ff       	jmp    801062f1 <alltraps>

80106e32 <vector125>:
.globl vector125
vector125:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $125
80106e34:	6a 7d                	push   $0x7d
  jmp alltraps
80106e36:	e9 b6 f4 ff ff       	jmp    801062f1 <alltraps>

80106e3b <vector126>:
.globl vector126
vector126:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $126
80106e3d:	6a 7e                	push   $0x7e
  jmp alltraps
80106e3f:	e9 ad f4 ff ff       	jmp    801062f1 <alltraps>

80106e44 <vector127>:
.globl vector127
vector127:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $127
80106e46:	6a 7f                	push   $0x7f
  jmp alltraps
80106e48:	e9 a4 f4 ff ff       	jmp    801062f1 <alltraps>

80106e4d <vector128>:
.globl vector128
vector128:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $128
80106e4f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106e54:	e9 98 f4 ff ff       	jmp    801062f1 <alltraps>

80106e59 <vector129>:
.globl vector129
vector129:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $129
80106e5b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e60:	e9 8c f4 ff ff       	jmp    801062f1 <alltraps>

80106e65 <vector130>:
.globl vector130
vector130:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $130
80106e67:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e6c:	e9 80 f4 ff ff       	jmp    801062f1 <alltraps>

80106e71 <vector131>:
.globl vector131
vector131:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $131
80106e73:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106e78:	e9 74 f4 ff ff       	jmp    801062f1 <alltraps>

80106e7d <vector132>:
.globl vector132
vector132:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $132
80106e7f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106e84:	e9 68 f4 ff ff       	jmp    801062f1 <alltraps>

80106e89 <vector133>:
.globl vector133
vector133:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $133
80106e8b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106e90:	e9 5c f4 ff ff       	jmp    801062f1 <alltraps>

80106e95 <vector134>:
.globl vector134
vector134:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $134
80106e97:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106e9c:	e9 50 f4 ff ff       	jmp    801062f1 <alltraps>

80106ea1 <vector135>:
.globl vector135
vector135:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $135
80106ea3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106ea8:	e9 44 f4 ff ff       	jmp    801062f1 <alltraps>

80106ead <vector136>:
.globl vector136
vector136:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $136
80106eaf:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106eb4:	e9 38 f4 ff ff       	jmp    801062f1 <alltraps>

80106eb9 <vector137>:
.globl vector137
vector137:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $137
80106ebb:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106ec0:	e9 2c f4 ff ff       	jmp    801062f1 <alltraps>

80106ec5 <vector138>:
.globl vector138
vector138:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $138
80106ec7:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ecc:	e9 20 f4 ff ff       	jmp    801062f1 <alltraps>

80106ed1 <vector139>:
.globl vector139
vector139:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $139
80106ed3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ed8:	e9 14 f4 ff ff       	jmp    801062f1 <alltraps>

80106edd <vector140>:
.globl vector140
vector140:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $140
80106edf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106ee4:	e9 08 f4 ff ff       	jmp    801062f1 <alltraps>

80106ee9 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $141
80106eeb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ef0:	e9 fc f3 ff ff       	jmp    801062f1 <alltraps>

80106ef5 <vector142>:
.globl vector142
vector142:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $142
80106ef7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106efc:	e9 f0 f3 ff ff       	jmp    801062f1 <alltraps>

80106f01 <vector143>:
.globl vector143
vector143:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $143
80106f03:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f08:	e9 e4 f3 ff ff       	jmp    801062f1 <alltraps>

80106f0d <vector144>:
.globl vector144
vector144:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $144
80106f0f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f14:	e9 d8 f3 ff ff       	jmp    801062f1 <alltraps>

80106f19 <vector145>:
.globl vector145
vector145:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $145
80106f1b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f20:	e9 cc f3 ff ff       	jmp    801062f1 <alltraps>

80106f25 <vector146>:
.globl vector146
vector146:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $146
80106f27:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f2c:	e9 c0 f3 ff ff       	jmp    801062f1 <alltraps>

80106f31 <vector147>:
.globl vector147
vector147:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $147
80106f33:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106f38:	e9 b4 f3 ff ff       	jmp    801062f1 <alltraps>

80106f3d <vector148>:
.globl vector148
vector148:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $148
80106f3f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106f44:	e9 a8 f3 ff ff       	jmp    801062f1 <alltraps>

80106f49 <vector149>:
.globl vector149
vector149:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $149
80106f4b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106f50:	e9 9c f3 ff ff       	jmp    801062f1 <alltraps>

80106f55 <vector150>:
.globl vector150
vector150:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $150
80106f57:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106f5c:	e9 90 f3 ff ff       	jmp    801062f1 <alltraps>

80106f61 <vector151>:
.globl vector151
vector151:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $151
80106f63:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f68:	e9 84 f3 ff ff       	jmp    801062f1 <alltraps>

80106f6d <vector152>:
.globl vector152
vector152:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $152
80106f6f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f74:	e9 78 f3 ff ff       	jmp    801062f1 <alltraps>

80106f79 <vector153>:
.globl vector153
vector153:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $153
80106f7b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106f80:	e9 6c f3 ff ff       	jmp    801062f1 <alltraps>

80106f85 <vector154>:
.globl vector154
vector154:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $154
80106f87:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106f8c:	e9 60 f3 ff ff       	jmp    801062f1 <alltraps>

80106f91 <vector155>:
.globl vector155
vector155:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $155
80106f93:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106f98:	e9 54 f3 ff ff       	jmp    801062f1 <alltraps>

80106f9d <vector156>:
.globl vector156
vector156:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $156
80106f9f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106fa4:	e9 48 f3 ff ff       	jmp    801062f1 <alltraps>

80106fa9 <vector157>:
.globl vector157
vector157:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $157
80106fab:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106fb0:	e9 3c f3 ff ff       	jmp    801062f1 <alltraps>

80106fb5 <vector158>:
.globl vector158
vector158:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $158
80106fb7:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106fbc:	e9 30 f3 ff ff       	jmp    801062f1 <alltraps>

80106fc1 <vector159>:
.globl vector159
vector159:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $159
80106fc3:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106fc8:	e9 24 f3 ff ff       	jmp    801062f1 <alltraps>

80106fcd <vector160>:
.globl vector160
vector160:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $160
80106fcf:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106fd4:	e9 18 f3 ff ff       	jmp    801062f1 <alltraps>

80106fd9 <vector161>:
.globl vector161
vector161:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $161
80106fdb:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106fe0:	e9 0c f3 ff ff       	jmp    801062f1 <alltraps>

80106fe5 <vector162>:
.globl vector162
vector162:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $162
80106fe7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106fec:	e9 00 f3 ff ff       	jmp    801062f1 <alltraps>

80106ff1 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $163
80106ff3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ff8:	e9 f4 f2 ff ff       	jmp    801062f1 <alltraps>

80106ffd <vector164>:
.globl vector164
vector164:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $164
80106fff:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107004:	e9 e8 f2 ff ff       	jmp    801062f1 <alltraps>

80107009 <vector165>:
.globl vector165
vector165:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $165
8010700b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107010:	e9 dc f2 ff ff       	jmp    801062f1 <alltraps>

80107015 <vector166>:
.globl vector166
vector166:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $166
80107017:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010701c:	e9 d0 f2 ff ff       	jmp    801062f1 <alltraps>

80107021 <vector167>:
.globl vector167
vector167:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $167
80107023:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107028:	e9 c4 f2 ff ff       	jmp    801062f1 <alltraps>

8010702d <vector168>:
.globl vector168
vector168:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $168
8010702f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107034:	e9 b8 f2 ff ff       	jmp    801062f1 <alltraps>

80107039 <vector169>:
.globl vector169
vector169:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $169
8010703b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107040:	e9 ac f2 ff ff       	jmp    801062f1 <alltraps>

80107045 <vector170>:
.globl vector170
vector170:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $170
80107047:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010704c:	e9 a0 f2 ff ff       	jmp    801062f1 <alltraps>

80107051 <vector171>:
.globl vector171
vector171:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $171
80107053:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107058:	e9 94 f2 ff ff       	jmp    801062f1 <alltraps>

8010705d <vector172>:
.globl vector172
vector172:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $172
8010705f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107064:	e9 88 f2 ff ff       	jmp    801062f1 <alltraps>

80107069 <vector173>:
.globl vector173
vector173:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $173
8010706b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107070:	e9 7c f2 ff ff       	jmp    801062f1 <alltraps>

80107075 <vector174>:
.globl vector174
vector174:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $174
80107077:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010707c:	e9 70 f2 ff ff       	jmp    801062f1 <alltraps>

80107081 <vector175>:
.globl vector175
vector175:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $175
80107083:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107088:	e9 64 f2 ff ff       	jmp    801062f1 <alltraps>

8010708d <vector176>:
.globl vector176
vector176:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $176
8010708f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107094:	e9 58 f2 ff ff       	jmp    801062f1 <alltraps>

80107099 <vector177>:
.globl vector177
vector177:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $177
8010709b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801070a0:	e9 4c f2 ff ff       	jmp    801062f1 <alltraps>

801070a5 <vector178>:
.globl vector178
vector178:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $178
801070a7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801070ac:	e9 40 f2 ff ff       	jmp    801062f1 <alltraps>

801070b1 <vector179>:
.globl vector179
vector179:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $179
801070b3:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801070b8:	e9 34 f2 ff ff       	jmp    801062f1 <alltraps>

801070bd <vector180>:
.globl vector180
vector180:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $180
801070bf:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801070c4:	e9 28 f2 ff ff       	jmp    801062f1 <alltraps>

801070c9 <vector181>:
.globl vector181
vector181:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $181
801070cb:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801070d0:	e9 1c f2 ff ff       	jmp    801062f1 <alltraps>

801070d5 <vector182>:
.globl vector182
vector182:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $182
801070d7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801070dc:	e9 10 f2 ff ff       	jmp    801062f1 <alltraps>

801070e1 <vector183>:
.globl vector183
vector183:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $183
801070e3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801070e8:	e9 04 f2 ff ff       	jmp    801062f1 <alltraps>

801070ed <vector184>:
.globl vector184
vector184:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $184
801070ef:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801070f4:	e9 f8 f1 ff ff       	jmp    801062f1 <alltraps>

801070f9 <vector185>:
.globl vector185
vector185:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $185
801070fb:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107100:	e9 ec f1 ff ff       	jmp    801062f1 <alltraps>

80107105 <vector186>:
.globl vector186
vector186:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $186
80107107:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010710c:	e9 e0 f1 ff ff       	jmp    801062f1 <alltraps>

80107111 <vector187>:
.globl vector187
vector187:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $187
80107113:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107118:	e9 d4 f1 ff ff       	jmp    801062f1 <alltraps>

8010711d <vector188>:
.globl vector188
vector188:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $188
8010711f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107124:	e9 c8 f1 ff ff       	jmp    801062f1 <alltraps>

80107129 <vector189>:
.globl vector189
vector189:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $189
8010712b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107130:	e9 bc f1 ff ff       	jmp    801062f1 <alltraps>

80107135 <vector190>:
.globl vector190
vector190:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $190
80107137:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010713c:	e9 b0 f1 ff ff       	jmp    801062f1 <alltraps>

80107141 <vector191>:
.globl vector191
vector191:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $191
80107143:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107148:	e9 a4 f1 ff ff       	jmp    801062f1 <alltraps>

8010714d <vector192>:
.globl vector192
vector192:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $192
8010714f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107154:	e9 98 f1 ff ff       	jmp    801062f1 <alltraps>

80107159 <vector193>:
.globl vector193
vector193:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $193
8010715b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107160:	e9 8c f1 ff ff       	jmp    801062f1 <alltraps>

80107165 <vector194>:
.globl vector194
vector194:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $194
80107167:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010716c:	e9 80 f1 ff ff       	jmp    801062f1 <alltraps>

80107171 <vector195>:
.globl vector195
vector195:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $195
80107173:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107178:	e9 74 f1 ff ff       	jmp    801062f1 <alltraps>

8010717d <vector196>:
.globl vector196
vector196:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $196
8010717f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107184:	e9 68 f1 ff ff       	jmp    801062f1 <alltraps>

80107189 <vector197>:
.globl vector197
vector197:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $197
8010718b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107190:	e9 5c f1 ff ff       	jmp    801062f1 <alltraps>

80107195 <vector198>:
.globl vector198
vector198:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $198
80107197:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010719c:	e9 50 f1 ff ff       	jmp    801062f1 <alltraps>

801071a1 <vector199>:
.globl vector199
vector199:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $199
801071a3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801071a8:	e9 44 f1 ff ff       	jmp    801062f1 <alltraps>

801071ad <vector200>:
.globl vector200
vector200:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $200
801071af:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801071b4:	e9 38 f1 ff ff       	jmp    801062f1 <alltraps>

801071b9 <vector201>:
.globl vector201
vector201:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $201
801071bb:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801071c0:	e9 2c f1 ff ff       	jmp    801062f1 <alltraps>

801071c5 <vector202>:
.globl vector202
vector202:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $202
801071c7:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801071cc:	e9 20 f1 ff ff       	jmp    801062f1 <alltraps>

801071d1 <vector203>:
.globl vector203
vector203:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $203
801071d3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801071d8:	e9 14 f1 ff ff       	jmp    801062f1 <alltraps>

801071dd <vector204>:
.globl vector204
vector204:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $204
801071df:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801071e4:	e9 08 f1 ff ff       	jmp    801062f1 <alltraps>

801071e9 <vector205>:
.globl vector205
vector205:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $205
801071eb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801071f0:	e9 fc f0 ff ff       	jmp    801062f1 <alltraps>

801071f5 <vector206>:
.globl vector206
vector206:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $206
801071f7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801071fc:	e9 f0 f0 ff ff       	jmp    801062f1 <alltraps>

80107201 <vector207>:
.globl vector207
vector207:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $207
80107203:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107208:	e9 e4 f0 ff ff       	jmp    801062f1 <alltraps>

8010720d <vector208>:
.globl vector208
vector208:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $208
8010720f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107214:	e9 d8 f0 ff ff       	jmp    801062f1 <alltraps>

80107219 <vector209>:
.globl vector209
vector209:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $209
8010721b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107220:	e9 cc f0 ff ff       	jmp    801062f1 <alltraps>

80107225 <vector210>:
.globl vector210
vector210:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $210
80107227:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010722c:	e9 c0 f0 ff ff       	jmp    801062f1 <alltraps>

80107231 <vector211>:
.globl vector211
vector211:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $211
80107233:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107238:	e9 b4 f0 ff ff       	jmp    801062f1 <alltraps>

8010723d <vector212>:
.globl vector212
vector212:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $212
8010723f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107244:	e9 a8 f0 ff ff       	jmp    801062f1 <alltraps>

80107249 <vector213>:
.globl vector213
vector213:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $213
8010724b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107250:	e9 9c f0 ff ff       	jmp    801062f1 <alltraps>

80107255 <vector214>:
.globl vector214
vector214:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $214
80107257:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010725c:	e9 90 f0 ff ff       	jmp    801062f1 <alltraps>

80107261 <vector215>:
.globl vector215
vector215:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $215
80107263:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107268:	e9 84 f0 ff ff       	jmp    801062f1 <alltraps>

8010726d <vector216>:
.globl vector216
vector216:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $216
8010726f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107274:	e9 78 f0 ff ff       	jmp    801062f1 <alltraps>

80107279 <vector217>:
.globl vector217
vector217:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $217
8010727b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107280:	e9 6c f0 ff ff       	jmp    801062f1 <alltraps>

80107285 <vector218>:
.globl vector218
vector218:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $218
80107287:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010728c:	e9 60 f0 ff ff       	jmp    801062f1 <alltraps>

80107291 <vector219>:
.globl vector219
vector219:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $219
80107293:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107298:	e9 54 f0 ff ff       	jmp    801062f1 <alltraps>

8010729d <vector220>:
.globl vector220
vector220:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $220
8010729f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801072a4:	e9 48 f0 ff ff       	jmp    801062f1 <alltraps>

801072a9 <vector221>:
.globl vector221
vector221:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $221
801072ab:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801072b0:	e9 3c f0 ff ff       	jmp    801062f1 <alltraps>

801072b5 <vector222>:
.globl vector222
vector222:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $222
801072b7:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801072bc:	e9 30 f0 ff ff       	jmp    801062f1 <alltraps>

801072c1 <vector223>:
.globl vector223
vector223:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $223
801072c3:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801072c8:	e9 24 f0 ff ff       	jmp    801062f1 <alltraps>

801072cd <vector224>:
.globl vector224
vector224:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $224
801072cf:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801072d4:	e9 18 f0 ff ff       	jmp    801062f1 <alltraps>

801072d9 <vector225>:
.globl vector225
vector225:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $225
801072db:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801072e0:	e9 0c f0 ff ff       	jmp    801062f1 <alltraps>

801072e5 <vector226>:
.globl vector226
vector226:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $226
801072e7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801072ec:	e9 00 f0 ff ff       	jmp    801062f1 <alltraps>

801072f1 <vector227>:
.globl vector227
vector227:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $227
801072f3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801072f8:	e9 f4 ef ff ff       	jmp    801062f1 <alltraps>

801072fd <vector228>:
.globl vector228
vector228:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $228
801072ff:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107304:	e9 e8 ef ff ff       	jmp    801062f1 <alltraps>

80107309 <vector229>:
.globl vector229
vector229:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $229
8010730b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107310:	e9 dc ef ff ff       	jmp    801062f1 <alltraps>

80107315 <vector230>:
.globl vector230
vector230:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $230
80107317:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010731c:	e9 d0 ef ff ff       	jmp    801062f1 <alltraps>

80107321 <vector231>:
.globl vector231
vector231:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $231
80107323:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107328:	e9 c4 ef ff ff       	jmp    801062f1 <alltraps>

8010732d <vector232>:
.globl vector232
vector232:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $232
8010732f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107334:	e9 b8 ef ff ff       	jmp    801062f1 <alltraps>

80107339 <vector233>:
.globl vector233
vector233:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $233
8010733b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107340:	e9 ac ef ff ff       	jmp    801062f1 <alltraps>

80107345 <vector234>:
.globl vector234
vector234:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $234
80107347:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010734c:	e9 a0 ef ff ff       	jmp    801062f1 <alltraps>

80107351 <vector235>:
.globl vector235
vector235:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $235
80107353:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107358:	e9 94 ef ff ff       	jmp    801062f1 <alltraps>

8010735d <vector236>:
.globl vector236
vector236:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $236
8010735f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107364:	e9 88 ef ff ff       	jmp    801062f1 <alltraps>

80107369 <vector237>:
.globl vector237
vector237:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $237
8010736b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107370:	e9 7c ef ff ff       	jmp    801062f1 <alltraps>

80107375 <vector238>:
.globl vector238
vector238:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $238
80107377:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010737c:	e9 70 ef ff ff       	jmp    801062f1 <alltraps>

80107381 <vector239>:
.globl vector239
vector239:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $239
80107383:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107388:	e9 64 ef ff ff       	jmp    801062f1 <alltraps>

8010738d <vector240>:
.globl vector240
vector240:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $240
8010738f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107394:	e9 58 ef ff ff       	jmp    801062f1 <alltraps>

80107399 <vector241>:
.globl vector241
vector241:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $241
8010739b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801073a0:	e9 4c ef ff ff       	jmp    801062f1 <alltraps>

801073a5 <vector242>:
.globl vector242
vector242:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $242
801073a7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801073ac:	e9 40 ef ff ff       	jmp    801062f1 <alltraps>

801073b1 <vector243>:
.globl vector243
vector243:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $243
801073b3:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801073b8:	e9 34 ef ff ff       	jmp    801062f1 <alltraps>

801073bd <vector244>:
.globl vector244
vector244:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $244
801073bf:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801073c4:	e9 28 ef ff ff       	jmp    801062f1 <alltraps>

801073c9 <vector245>:
.globl vector245
vector245:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $245
801073cb:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801073d0:	e9 1c ef ff ff       	jmp    801062f1 <alltraps>

801073d5 <vector246>:
.globl vector246
vector246:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $246
801073d7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801073dc:	e9 10 ef ff ff       	jmp    801062f1 <alltraps>

801073e1 <vector247>:
.globl vector247
vector247:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $247
801073e3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801073e8:	e9 04 ef ff ff       	jmp    801062f1 <alltraps>

801073ed <vector248>:
.globl vector248
vector248:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $248
801073ef:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801073f4:	e9 f8 ee ff ff       	jmp    801062f1 <alltraps>

801073f9 <vector249>:
.globl vector249
vector249:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $249
801073fb:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107400:	e9 ec ee ff ff       	jmp    801062f1 <alltraps>

80107405 <vector250>:
.globl vector250
vector250:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $250
80107407:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010740c:	e9 e0 ee ff ff       	jmp    801062f1 <alltraps>

80107411 <vector251>:
.globl vector251
vector251:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $251
80107413:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107418:	e9 d4 ee ff ff       	jmp    801062f1 <alltraps>

8010741d <vector252>:
.globl vector252
vector252:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $252
8010741f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107424:	e9 c8 ee ff ff       	jmp    801062f1 <alltraps>

80107429 <vector253>:
.globl vector253
vector253:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $253
8010742b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107430:	e9 bc ee ff ff       	jmp    801062f1 <alltraps>

80107435 <vector254>:
.globl vector254
vector254:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $254
80107437:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010743c:	e9 b0 ee ff ff       	jmp    801062f1 <alltraps>

80107441 <vector255>:
.globl vector255
vector255:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $255
80107443:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107448:	e9 a4 ee ff ff       	jmp    801062f1 <alltraps>

8010744d <lgdt>:
{
8010744d:	55                   	push   %ebp
8010744e:	89 e5                	mov    %esp,%ebp
80107450:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107453:	8b 45 0c             	mov    0xc(%ebp),%eax
80107456:	83 e8 01             	sub    $0x1,%eax
80107459:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010745d:	8b 45 08             	mov    0x8(%ebp),%eax
80107460:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107464:	8b 45 08             	mov    0x8(%ebp),%eax
80107467:	c1 e8 10             	shr    $0x10,%eax
8010746a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010746e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107471:	0f 01 10             	lgdtl  (%eax)
}
80107474:	90                   	nop
80107475:	c9                   	leave  
80107476:	c3                   	ret    

80107477 <ltr>:
{
80107477:	55                   	push   %ebp
80107478:	89 e5                	mov    %esp,%ebp
8010747a:	83 ec 04             	sub    $0x4,%esp
8010747d:	8b 45 08             	mov    0x8(%ebp),%eax
80107480:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107484:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107488:	0f 00 d8             	ltr    %ax
}
8010748b:	90                   	nop
8010748c:	c9                   	leave  
8010748d:	c3                   	ret    

8010748e <lcr3>:
{
8010748e:	55                   	push   %ebp
8010748f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107491:	8b 45 08             	mov    0x8(%ebp),%eax
80107494:	0f 22 d8             	mov    %eax,%cr3
}
80107497:	90                   	nop
80107498:	5d                   	pop    %ebp
80107499:	c3                   	ret    

8010749a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010749a:	55                   	push   %ebp
8010749b:	89 e5                	mov    %esp,%ebp
8010749d:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801074a0:	e8 ea c9 ff ff       	call   80103e8f <cpuid>
801074a5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801074ab:	05 c0 99 11 80       	add    $0x801199c0,%eax
801074b0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801074b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801074bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bf:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801074cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074cf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074d3:	83 e2 f0             	and    $0xfffffff0,%edx
801074d6:	83 ca 0a             	or     $0xa,%edx
801074d9:	88 50 7d             	mov    %dl,0x7d(%eax)
801074dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074df:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074e3:	83 ca 10             	or     $0x10,%edx
801074e6:	88 50 7d             	mov    %dl,0x7d(%eax)
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074f0:	83 e2 9f             	and    $0xffffff9f,%edx
801074f3:	88 50 7d             	mov    %dl,0x7d(%eax)
801074f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074fd:	83 ca 80             	or     $0xffffff80,%edx
80107500:	88 50 7d             	mov    %dl,0x7d(%eax)
80107503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107506:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010750a:	83 ca 0f             	or     $0xf,%edx
8010750d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107513:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107517:	83 e2 ef             	and    $0xffffffef,%edx
8010751a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010751d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107520:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107524:	83 e2 df             	and    $0xffffffdf,%edx
80107527:	88 50 7e             	mov    %dl,0x7e(%eax)
8010752a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107531:	83 ca 40             	or     $0x40,%edx
80107534:	88 50 7e             	mov    %dl,0x7e(%eax)
80107537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010753e:	83 ca 80             	or     $0xffffff80,%edx
80107541:	88 50 7e             	mov    %dl,0x7e(%eax)
80107544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107547:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010754b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107555:	ff ff 
80107557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107561:	00 00 
80107563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107566:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010756d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107570:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107577:	83 e2 f0             	and    $0xfffffff0,%edx
8010757a:	83 ca 02             	or     $0x2,%edx
8010757d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107586:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010758d:	83 ca 10             	or     $0x10,%edx
80107590:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107599:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075a0:	83 e2 9f             	and    $0xffffff9f,%edx
801075a3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075b3:	83 ca 80             	or     $0xffffff80,%edx
801075b6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075c6:	83 ca 0f             	or     $0xf,%edx
801075c9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075d9:	83 e2 ef             	and    $0xffffffef,%edx
801075dc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075ec:	83 e2 df             	and    $0xffffffdf,%edx
801075ef:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075ff:	83 ca 40             	or     $0x40,%edx
80107602:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107612:	83 ca 80             	or     $0xffffff80,%edx
80107615:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010761b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107628:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010762f:	ff ff 
80107631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107634:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010763b:	00 00 
8010763d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107640:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107651:	83 e2 f0             	and    $0xfffffff0,%edx
80107654:	83 ca 0a             	or     $0xa,%edx
80107657:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107667:	83 ca 10             	or     $0x10,%edx
8010766a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107673:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010767a:	83 ca 60             	or     $0x60,%edx
8010767d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010768d:	83 ca 80             	or     $0xffffff80,%edx
80107690:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107699:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076a0:	83 ca 0f             	or     $0xf,%edx
801076a3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ac:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076b3:	83 e2 ef             	and    $0xffffffef,%edx
801076b6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076c6:	83 e2 df             	and    $0xffffffdf,%edx
801076c9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076d9:	83 ca 40             	or     $0x40,%edx
801076dc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801076ec:	83 ca 80             	or     $0xffffff80,%edx
801076ef:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801076f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107702:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107709:	ff ff 
8010770b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107715:	00 00 
80107717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107724:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010772b:	83 e2 f0             	and    $0xfffffff0,%edx
8010772e:	83 ca 02             	or     $0x2,%edx
80107731:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107741:	83 ca 10             	or     $0x10,%edx
80107744:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010774a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107754:	83 ca 60             	or     $0x60,%edx
80107757:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010775d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107760:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107767:	83 ca 80             	or     $0xffffff80,%edx
8010776a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107773:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010777a:	83 ca 0f             	or     $0xf,%edx
8010777d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107786:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010778d:	83 e2 ef             	and    $0xffffffef,%edx
80107790:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107799:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077a0:	83 e2 df             	and    $0xffffffdf,%edx
801077a3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077b3:	83 ca 40             	or     $0x40,%edx
801077b6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077c6:	83 ca 80             	or     $0xffffff80,%edx
801077c9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	83 c0 70             	add    $0x70,%eax
801077df:	83 ec 08             	sub    $0x8,%esp
801077e2:	6a 30                	push   $0x30
801077e4:	50                   	push   %eax
801077e5:	e8 63 fc ff ff       	call   8010744d <lgdt>
801077ea:	83 c4 10             	add    $0x10,%esp
}
801077ed:	90                   	nop
801077ee:	c9                   	leave  
801077ef:	c3                   	ret    

801077f0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801077f0:	55                   	push   %ebp
801077f1:	89 e5                	mov    %esp,%ebp
801077f3:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801077f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801077f9:	c1 e8 16             	shr    $0x16,%eax
801077fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107803:	8b 45 08             	mov    0x8(%ebp),%eax
80107806:	01 d0                	add    %edx,%eax
80107808:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010780b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010780e:	8b 00                	mov    (%eax),%eax
80107810:	83 e0 01             	and    $0x1,%eax
80107813:	85 c0                	test   %eax,%eax
80107815:	74 14                	je     8010782b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010781a:	8b 00                	mov    (%eax),%eax
8010781c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107821:	05 00 00 00 80       	add    $0x80000000,%eax
80107826:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107829:	eb 42                	jmp    8010786d <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010782b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010782f:	74 0e                	je     8010783f <walkpgdir+0x4f>
80107831:	e8 5c b4 ff ff       	call   80102c92 <kalloc>
80107836:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010783d:	75 07                	jne    80107846 <walkpgdir+0x56>
      return 0;
8010783f:	b8 00 00 00 00       	mov    $0x0,%eax
80107844:	eb 3e                	jmp    80107884 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107846:	83 ec 04             	sub    $0x4,%esp
80107849:	68 00 10 00 00       	push   $0x1000
8010784e:	6a 00                	push   $0x0
80107850:	ff 75 f4             	push   -0xc(%ebp)
80107853:	e8 1b d7 ff ff       	call   80104f73 <memset>
80107858:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010785b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785e:	05 00 00 00 80       	add    $0x80000000,%eax
80107863:	83 c8 07             	or     $0x7,%eax
80107866:	89 c2                	mov    %eax,%edx
80107868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010786b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010786d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107870:	c1 e8 0c             	shr    $0xc,%eax
80107873:	25 ff 03 00 00       	and    $0x3ff,%eax
80107878:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	01 d0                	add    %edx,%eax
}
80107884:	c9                   	leave  
80107885:	c3                   	ret    

80107886 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107886:	55                   	push   %ebp
80107887:	89 e5                	mov    %esp,%ebp
80107889:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010788c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010788f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107897:	8b 55 0c             	mov    0xc(%ebp),%edx
8010789a:	8b 45 10             	mov    0x10(%ebp),%eax
8010789d:	01 d0                	add    %edx,%eax
8010789f:	83 e8 01             	sub    $0x1,%eax
801078a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078aa:	83 ec 04             	sub    $0x4,%esp
801078ad:	6a 01                	push   $0x1
801078af:	ff 75 f4             	push   -0xc(%ebp)
801078b2:	ff 75 08             	push   0x8(%ebp)
801078b5:	e8 36 ff ff ff       	call   801077f0 <walkpgdir>
801078ba:	83 c4 10             	add    $0x10,%esp
801078bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078c4:	75 07                	jne    801078cd <mappages+0x47>
      return -1;
801078c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078cb:	eb 47                	jmp    80107914 <mappages+0x8e>
    if(*pte & PTE_P)
801078cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078d0:	8b 00                	mov    (%eax),%eax
801078d2:	83 e0 01             	and    $0x1,%eax
801078d5:	85 c0                	test   %eax,%eax
801078d7:	74 0d                	je     801078e6 <mappages+0x60>
      panic("remap");
801078d9:	83 ec 0c             	sub    $0xc,%esp
801078dc:	68 2c ac 10 80       	push   $0x8010ac2c
801078e1:	e8 db 8c ff ff       	call   801005c1 <panic>
    *pte = pa | perm | PTE_P;
801078e6:	8b 45 18             	mov    0x18(%ebp),%eax
801078e9:	0b 45 14             	or     0x14(%ebp),%eax
801078ec:	83 c8 01             	or     $0x1,%eax
801078ef:	89 c2                	mov    %eax,%edx
801078f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078f4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801078f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801078fc:	74 10                	je     8010790e <mappages+0x88>
      break;
    a += PGSIZE;
801078fe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107905:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010790c:	eb 9c                	jmp    801078aa <mappages+0x24>
      break;
8010790e:	90                   	nop
  }
  return 0;
8010790f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107914:	c9                   	leave  
80107915:	c3                   	ret    

80107916 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107916:	55                   	push   %ebp
80107917:	89 e5                	mov    %esp,%ebp
80107919:	53                   	push   %ebx
8010791a:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010791d:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107924:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
8010792a:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010792f:	29 d0                	sub    %edx,%eax
80107931:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107934:	a1 88 9c 11 80       	mov    0x80119c88,%eax
80107939:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010793c:	8b 15 88 9c 11 80    	mov    0x80119c88,%edx
80107942:	a1 90 9c 11 80       	mov    0x80119c90,%eax
80107947:	01 d0                	add    %edx,%eax
80107949:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010794c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107956:	83 c0 30             	add    $0x30,%eax
80107959:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010795c:	89 10                	mov    %edx,(%eax)
8010795e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107961:	89 50 04             	mov    %edx,0x4(%eax)
80107964:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107967:	89 50 08             	mov    %edx,0x8(%eax)
8010796a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010796d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107970:	e8 1d b3 ff ff       	call   80102c92 <kalloc>
80107975:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107978:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010797c:	75 07                	jne    80107985 <setupkvm+0x6f>
    return 0;
8010797e:	b8 00 00 00 00       	mov    $0x0,%eax
80107983:	eb 78                	jmp    801079fd <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107985:	83 ec 04             	sub    $0x4,%esp
80107988:	68 00 10 00 00       	push   $0x1000
8010798d:	6a 00                	push   $0x0
8010798f:	ff 75 f0             	push   -0x10(%ebp)
80107992:	e8 dc d5 ff ff       	call   80104f73 <memset>
80107997:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010799a:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801079a1:	eb 4e                	jmp    801079f1 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801079af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b2:	8b 58 08             	mov    0x8(%eax),%ebx
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	8b 40 04             	mov    0x4(%eax),%eax
801079bb:	29 c3                	sub    %eax,%ebx
801079bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c0:	8b 00                	mov    (%eax),%eax
801079c2:	83 ec 0c             	sub    $0xc,%esp
801079c5:	51                   	push   %ecx
801079c6:	52                   	push   %edx
801079c7:	53                   	push   %ebx
801079c8:	50                   	push   %eax
801079c9:	ff 75 f0             	push   -0x10(%ebp)
801079cc:	e8 b5 fe ff ff       	call   80107886 <mappages>
801079d1:	83 c4 20             	add    $0x20,%esp
801079d4:	85 c0                	test   %eax,%eax
801079d6:	79 15                	jns    801079ed <setupkvm+0xd7>
      freevm(pgdir);
801079d8:	83 ec 0c             	sub    $0xc,%esp
801079db:	ff 75 f0             	push   -0x10(%ebp)
801079de:	e8 f5 04 00 00       	call   80107ed8 <freevm>
801079e3:	83 c4 10             	add    $0x10,%esp
      return 0;
801079e6:	b8 00 00 00 00       	mov    $0x0,%eax
801079eb:	eb 10                	jmp    801079fd <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079ed:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801079f1:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801079f8:	72 a9                	jb     801079a3 <setupkvm+0x8d>
    }
  return pgdir;
801079fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801079fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a00:	c9                   	leave  
80107a01:	c3                   	ret    

80107a02 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a02:	55                   	push   %ebp
80107a03:	89 e5                	mov    %esp,%ebp
80107a05:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a08:	e8 09 ff ff ff       	call   80107916 <setupkvm>
80107a0d:	a3 bc 99 11 80       	mov    %eax,0x801199bc
  switchkvm();
80107a12:	e8 03 00 00 00       	call   80107a1a <switchkvm>
}
80107a17:	90                   	nop
80107a18:	c9                   	leave  
80107a19:	c3                   	ret    

80107a1a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a1a:	55                   	push   %ebp
80107a1b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a1d:	a1 bc 99 11 80       	mov    0x801199bc,%eax
80107a22:	05 00 00 00 80       	add    $0x80000000,%eax
80107a27:	50                   	push   %eax
80107a28:	e8 61 fa ff ff       	call   8010748e <lcr3>
80107a2d:	83 c4 04             	add    $0x4,%esp
}
80107a30:	90                   	nop
80107a31:	c9                   	leave  
80107a32:	c3                   	ret    

80107a33 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a33:	55                   	push   %ebp
80107a34:	89 e5                	mov    %esp,%ebp
80107a36:	56                   	push   %esi
80107a37:	53                   	push   %ebx
80107a38:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107a3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107a3f:	75 0d                	jne    80107a4e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107a41:	83 ec 0c             	sub    $0xc,%esp
80107a44:	68 32 ac 10 80       	push   $0x8010ac32
80107a49:	e8 73 8b ff ff       	call   801005c1 <panic>
  if(p->kstack == 0)
80107a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a51:	8b 40 08             	mov    0x8(%eax),%eax
80107a54:	85 c0                	test   %eax,%eax
80107a56:	75 0d                	jne    80107a65 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107a58:	83 ec 0c             	sub    $0xc,%esp
80107a5b:	68 48 ac 10 80       	push   $0x8010ac48
80107a60:	e8 5c 8b ff ff       	call   801005c1 <panic>
  if(p->pgdir == 0)
80107a65:	8b 45 08             	mov    0x8(%ebp),%eax
80107a68:	8b 40 04             	mov    0x4(%eax),%eax
80107a6b:	85 c0                	test   %eax,%eax
80107a6d:	75 0d                	jne    80107a7c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107a6f:	83 ec 0c             	sub    $0xc,%esp
80107a72:	68 5d ac 10 80       	push   $0x8010ac5d
80107a77:	e8 45 8b ff ff       	call   801005c1 <panic>

  pushcli();
80107a7c:	e8 e7 d3 ff ff       	call   80104e68 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107a81:	e8 24 c4 ff ff       	call   80103eaa <mycpu>
80107a86:	89 c3                	mov    %eax,%ebx
80107a88:	e8 1d c4 ff ff       	call   80103eaa <mycpu>
80107a8d:	83 c0 08             	add    $0x8,%eax
80107a90:	89 c6                	mov    %eax,%esi
80107a92:	e8 13 c4 ff ff       	call   80103eaa <mycpu>
80107a97:	83 c0 08             	add    $0x8,%eax
80107a9a:	c1 e8 10             	shr    $0x10,%eax
80107a9d:	88 45 f7             	mov    %al,-0x9(%ebp)
80107aa0:	e8 05 c4 ff ff       	call   80103eaa <mycpu>
80107aa5:	83 c0 08             	add    $0x8,%eax
80107aa8:	c1 e8 18             	shr    $0x18,%eax
80107aab:	89 c2                	mov    %eax,%edx
80107aad:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ab4:	67 00 
80107ab6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107abd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107ac1:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107ac7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ace:	83 e0 f0             	and    $0xfffffff0,%eax
80107ad1:	83 c8 09             	or     $0x9,%eax
80107ad4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ada:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ae1:	83 c8 10             	or     $0x10,%eax
80107ae4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107aea:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107af1:	83 e0 9f             	and    $0xffffff9f,%eax
80107af4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107afa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b01:	83 c8 80             	or     $0xffffff80,%eax
80107b04:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b0a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b11:	83 e0 f0             	and    $0xfffffff0,%eax
80107b14:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b1a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b21:	83 e0 ef             	and    $0xffffffef,%eax
80107b24:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b2a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b31:	83 e0 df             	and    $0xffffffdf,%eax
80107b34:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b3a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b41:	83 c8 40             	or     $0x40,%eax
80107b44:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b4a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b51:	83 e0 7f             	and    $0x7f,%eax
80107b54:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b5a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107b60:	e8 45 c3 ff ff       	call   80103eaa <mycpu>
80107b65:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b6c:	83 e2 ef             	and    $0xffffffef,%edx
80107b6f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107b75:	e8 30 c3 ff ff       	call   80103eaa <mycpu>
80107b7a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107b80:	8b 45 08             	mov    0x8(%ebp),%eax
80107b83:	8b 40 08             	mov    0x8(%eax),%eax
80107b86:	89 c3                	mov    %eax,%ebx
80107b88:	e8 1d c3 ff ff       	call   80103eaa <mycpu>
80107b8d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107b93:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107b96:	e8 0f c3 ff ff       	call   80103eaa <mycpu>
80107b9b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ba1:	83 ec 0c             	sub    $0xc,%esp
80107ba4:	6a 28                	push   $0x28
80107ba6:	e8 cc f8 ff ff       	call   80107477 <ltr>
80107bab:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107bae:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb1:	8b 40 04             	mov    0x4(%eax),%eax
80107bb4:	05 00 00 00 80       	add    $0x80000000,%eax
80107bb9:	83 ec 0c             	sub    $0xc,%esp
80107bbc:	50                   	push   %eax
80107bbd:	e8 cc f8 ff ff       	call   8010748e <lcr3>
80107bc2:	83 c4 10             	add    $0x10,%esp
  popcli();
80107bc5:	e8 eb d2 ff ff       	call   80104eb5 <popcli>
}
80107bca:	90                   	nop
80107bcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107bce:	5b                   	pop    %ebx
80107bcf:	5e                   	pop    %esi
80107bd0:	5d                   	pop    %ebp
80107bd1:	c3                   	ret    

80107bd2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107bd2:	55                   	push   %ebp
80107bd3:	89 e5                	mov    %esp,%ebp
80107bd5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107bd8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107bdf:	76 0d                	jbe    80107bee <inituvm+0x1c>
    panic("inituvm: more than a page");
80107be1:	83 ec 0c             	sub    $0xc,%esp
80107be4:	68 71 ac 10 80       	push   $0x8010ac71
80107be9:	e8 d3 89 ff ff       	call   801005c1 <panic>
  mem = kalloc();
80107bee:	e8 9f b0 ff ff       	call   80102c92 <kalloc>
80107bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107bf6:	83 ec 04             	sub    $0x4,%esp
80107bf9:	68 00 10 00 00       	push   $0x1000
80107bfe:	6a 00                	push   $0x0
80107c00:	ff 75 f4             	push   -0xc(%ebp)
80107c03:	e8 6b d3 ff ff       	call   80104f73 <memset>
80107c08:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80107c13:	83 ec 0c             	sub    $0xc,%esp
80107c16:	6a 06                	push   $0x6
80107c18:	50                   	push   %eax
80107c19:	68 00 10 00 00       	push   $0x1000
80107c1e:	6a 00                	push   $0x0
80107c20:	ff 75 08             	push   0x8(%ebp)
80107c23:	e8 5e fc ff ff       	call   80107886 <mappages>
80107c28:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c2b:	83 ec 04             	sub    $0x4,%esp
80107c2e:	ff 75 10             	push   0x10(%ebp)
80107c31:	ff 75 0c             	push   0xc(%ebp)
80107c34:	ff 75 f4             	push   -0xc(%ebp)
80107c37:	e8 f6 d3 ff ff       	call   80105032 <memmove>
80107c3c:	83 c4 10             	add    $0x10,%esp
}
80107c3f:	90                   	nop
80107c40:	c9                   	leave  
80107c41:	c3                   	ret    

80107c42 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c42:	55                   	push   %ebp
80107c43:	89 e5                	mov    %esp,%ebp
80107c45:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c48:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c50:	85 c0                	test   %eax,%eax
80107c52:	74 0d                	je     80107c61 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107c54:	83 ec 0c             	sub    $0xc,%esp
80107c57:	68 8c ac 10 80       	push   $0x8010ac8c
80107c5c:	e8 60 89 ff ff       	call   801005c1 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c68:	e9 8f 00 00 00       	jmp    80107cfc <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	01 d0                	add    %edx,%eax
80107c75:	83 ec 04             	sub    $0x4,%esp
80107c78:	6a 00                	push   $0x0
80107c7a:	50                   	push   %eax
80107c7b:	ff 75 08             	push   0x8(%ebp)
80107c7e:	e8 6d fb ff ff       	call   801077f0 <walkpgdir>
80107c83:	83 c4 10             	add    $0x10,%esp
80107c86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c8d:	75 0d                	jne    80107c9c <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107c8f:	83 ec 0c             	sub    $0xc,%esp
80107c92:	68 af ac 10 80       	push   $0x8010acaf
80107c97:	e8 25 89 ff ff       	call   801005c1 <panic>
    pa = PTE_ADDR(*pte);
80107c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9f:	8b 00                	mov    (%eax),%eax
80107ca1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ca6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ca9:	8b 45 18             	mov    0x18(%ebp),%eax
80107cac:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107caf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107cb4:	77 0b                	ja     80107cc1 <loaduvm+0x7f>
      n = sz - i;
80107cb6:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cbf:	eb 07                	jmp    80107cc8 <loaduvm+0x86>
    else
      n = PGSIZE;
80107cc1:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107cc8:	8b 55 14             	mov    0x14(%ebp),%edx
80107ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cce:	01 d0                	add    %edx,%eax
80107cd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107cd3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107cd9:	ff 75 f0             	push   -0x10(%ebp)
80107cdc:	50                   	push   %eax
80107cdd:	52                   	push   %edx
80107cde:	ff 75 10             	push   0x10(%ebp)
80107ce1:	e8 fe a1 ff ff       	call   80101ee4 <readi>
80107ce6:	83 c4 10             	add    $0x10,%esp
80107ce9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107cec:	74 07                	je     80107cf5 <loaduvm+0xb3>
      return -1;
80107cee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cf3:	eb 18                	jmp    80107d0d <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107cf5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d02:	0f 82 65 ff ff ff    	jb     80107c6d <loaduvm+0x2b>
  }
  return 0;
80107d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d0d:	c9                   	leave  
80107d0e:	c3                   	ret    

80107d0f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d0f:	55                   	push   %ebp
80107d10:	89 e5                	mov    %esp,%ebp
80107d12:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d15:	8b 45 10             	mov    0x10(%ebp),%eax
80107d18:	85 c0                	test   %eax,%eax
80107d1a:	79 0a                	jns    80107d26 <allocuvm+0x17>
    return 0;
80107d1c:	b8 00 00 00 00       	mov    $0x0,%eax
80107d21:	e9 ec 00 00 00       	jmp    80107e12 <allocuvm+0x103>
  if(newsz < oldsz)
80107d26:	8b 45 10             	mov    0x10(%ebp),%eax
80107d29:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d2c:	73 08                	jae    80107d36 <allocuvm+0x27>
    return oldsz;
80107d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d31:	e9 dc 00 00 00       	jmp    80107e12 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d39:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d46:	e9 b8 00 00 00       	jmp    80107e03 <allocuvm+0xf4>
    mem = kalloc();
80107d4b:	e8 42 af ff ff       	call   80102c92 <kalloc>
80107d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d57:	75 2e                	jne    80107d87 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107d59:	83 ec 0c             	sub    $0xc,%esp
80107d5c:	68 cd ac 10 80       	push   $0x8010accd
80107d61:	e8 8e 86 ff ff       	call   801003f4 <cprintf>
80107d66:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d69:	83 ec 04             	sub    $0x4,%esp
80107d6c:	ff 75 0c             	push   0xc(%ebp)
80107d6f:	ff 75 10             	push   0x10(%ebp)
80107d72:	ff 75 08             	push   0x8(%ebp)
80107d75:	e8 9a 00 00 00       	call   80107e14 <deallocuvm>
80107d7a:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d7d:	b8 00 00 00 00       	mov    $0x0,%eax
80107d82:	e9 8b 00 00 00       	jmp    80107e12 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107d87:	83 ec 04             	sub    $0x4,%esp
80107d8a:	68 00 10 00 00       	push   $0x1000
80107d8f:	6a 00                	push   $0x0
80107d91:	ff 75 f0             	push   -0x10(%ebp)
80107d94:	e8 da d1 ff ff       	call   80104f73 <memset>
80107d99:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d9f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da8:	83 ec 0c             	sub    $0xc,%esp
80107dab:	6a 06                	push   $0x6
80107dad:	52                   	push   %edx
80107dae:	68 00 10 00 00       	push   $0x1000
80107db3:	50                   	push   %eax
80107db4:	ff 75 08             	push   0x8(%ebp)
80107db7:	e8 ca fa ff ff       	call   80107886 <mappages>
80107dbc:	83 c4 20             	add    $0x20,%esp
80107dbf:	85 c0                	test   %eax,%eax
80107dc1:	79 39                	jns    80107dfc <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107dc3:	83 ec 0c             	sub    $0xc,%esp
80107dc6:	68 e5 ac 10 80       	push   $0x8010ace5
80107dcb:	e8 24 86 ff ff       	call   801003f4 <cprintf>
80107dd0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dd3:	83 ec 04             	sub    $0x4,%esp
80107dd6:	ff 75 0c             	push   0xc(%ebp)
80107dd9:	ff 75 10             	push   0x10(%ebp)
80107ddc:	ff 75 08             	push   0x8(%ebp)
80107ddf:	e8 30 00 00 00       	call   80107e14 <deallocuvm>
80107de4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107de7:	83 ec 0c             	sub    $0xc,%esp
80107dea:	ff 75 f0             	push   -0x10(%ebp)
80107ded:	e8 06 ae ff ff       	call   80102bf8 <kfree>
80107df2:	83 c4 10             	add    $0x10,%esp
      return 0;
80107df5:	b8 00 00 00 00       	mov    $0x0,%eax
80107dfa:	eb 16                	jmp    80107e12 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107dfc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e06:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e09:	0f 82 3c ff ff ff    	jb     80107d4b <allocuvm+0x3c>
    }
  }
  return newsz;
80107e0f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e12:	c9                   	leave  
80107e13:	c3                   	ret    

80107e14 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e14:	55                   	push   %ebp
80107e15:	89 e5                	mov    %esp,%ebp
80107e17:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e1a:	8b 45 10             	mov    0x10(%ebp),%eax
80107e1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e20:	72 08                	jb     80107e2a <deallocuvm+0x16>
    return oldsz;
80107e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e25:	e9 ac 00 00 00       	jmp    80107ed6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107e2a:	8b 45 10             	mov    0x10(%ebp),%eax
80107e2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e3a:	e9 88 00 00 00       	jmp    80107ec7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	83 ec 04             	sub    $0x4,%esp
80107e45:	6a 00                	push   $0x0
80107e47:	50                   	push   %eax
80107e48:	ff 75 08             	push   0x8(%ebp)
80107e4b:	e8 a0 f9 ff ff       	call   801077f0 <walkpgdir>
80107e50:	83 c4 10             	add    $0x10,%esp
80107e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e5a:	75 16                	jne    80107e72 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5f:	c1 e8 16             	shr    $0x16,%eax
80107e62:	83 c0 01             	add    $0x1,%eax
80107e65:	c1 e0 16             	shl    $0x16,%eax
80107e68:	2d 00 10 00 00       	sub    $0x1000,%eax
80107e6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e70:	eb 4e                	jmp    80107ec0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e75:	8b 00                	mov    (%eax),%eax
80107e77:	83 e0 01             	and    $0x1,%eax
80107e7a:	85 c0                	test   %eax,%eax
80107e7c:	74 42                	je     80107ec0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e81:	8b 00                	mov    (%eax),%eax
80107e83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e88:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107e8b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e8f:	75 0d                	jne    80107e9e <deallocuvm+0x8a>
        panic("kfree");
80107e91:	83 ec 0c             	sub    $0xc,%esp
80107e94:	68 01 ad 10 80       	push   $0x8010ad01
80107e99:	e8 23 87 ff ff       	call   801005c1 <panic>
      char *v = P2V(pa);
80107e9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ea1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ea6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107ea9:	83 ec 0c             	sub    $0xc,%esp
80107eac:	ff 75 e8             	push   -0x18(%ebp)
80107eaf:	e8 44 ad ff ff       	call   80102bf8 <kfree>
80107eb4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107ec0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ecd:	0f 82 6c ff ff ff    	jb     80107e3f <deallocuvm+0x2b>
    }
  }
  return newsz;
80107ed3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ed6:	c9                   	leave  
80107ed7:	c3                   	ret    

80107ed8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ed8:	55                   	push   %ebp
80107ed9:	89 e5                	mov    %esp,%ebp
80107edb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107ede:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ee2:	75 0d                	jne    80107ef1 <freevm+0x19>
    panic("freevm: no pgdir");
80107ee4:	83 ec 0c             	sub    $0xc,%esp
80107ee7:	68 07 ad 10 80       	push   $0x8010ad07
80107eec:	e8 d0 86 ff ff       	call   801005c1 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107ef1:	83 ec 04             	sub    $0x4,%esp
80107ef4:	6a 00                	push   $0x0
80107ef6:	68 00 00 00 80       	push   $0x80000000
80107efb:	ff 75 08             	push   0x8(%ebp)
80107efe:	e8 11 ff ff ff       	call   80107e14 <deallocuvm>
80107f03:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f0d:	eb 48                	jmp    80107f57 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f19:	8b 45 08             	mov    0x8(%ebp),%eax
80107f1c:	01 d0                	add    %edx,%eax
80107f1e:	8b 00                	mov    (%eax),%eax
80107f20:	83 e0 01             	and    $0x1,%eax
80107f23:	85 c0                	test   %eax,%eax
80107f25:	74 2c                	je     80107f53 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f31:	8b 45 08             	mov    0x8(%ebp),%eax
80107f34:	01 d0                	add    %edx,%eax
80107f36:	8b 00                	mov    (%eax),%eax
80107f38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f3d:	05 00 00 00 80       	add    $0x80000000,%eax
80107f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f45:	83 ec 0c             	sub    $0xc,%esp
80107f48:	ff 75 f0             	push   -0x10(%ebp)
80107f4b:	e8 a8 ac ff ff       	call   80102bf8 <kfree>
80107f50:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f53:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f57:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f5e:	76 af                	jbe    80107f0f <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107f60:	83 ec 0c             	sub    $0xc,%esp
80107f63:	ff 75 08             	push   0x8(%ebp)
80107f66:	e8 8d ac ff ff       	call   80102bf8 <kfree>
80107f6b:	83 c4 10             	add    $0x10,%esp
}
80107f6e:	90                   	nop
80107f6f:	c9                   	leave  
80107f70:	c3                   	ret    

80107f71 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f71:	55                   	push   %ebp
80107f72:	89 e5                	mov    %esp,%ebp
80107f74:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f77:	83 ec 04             	sub    $0x4,%esp
80107f7a:	6a 00                	push   $0x0
80107f7c:	ff 75 0c             	push   0xc(%ebp)
80107f7f:	ff 75 08             	push   0x8(%ebp)
80107f82:	e8 69 f8 ff ff       	call   801077f0 <walkpgdir>
80107f87:	83 c4 10             	add    $0x10,%esp
80107f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f91:	75 0d                	jne    80107fa0 <clearpteu+0x2f>
    panic("clearpteu");
80107f93:	83 ec 0c             	sub    $0xc,%esp
80107f96:	68 18 ad 10 80       	push   $0x8010ad18
80107f9b:	e8 21 86 ff ff       	call   801005c1 <panic>
  *pte &= ~PTE_U;
80107fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa3:	8b 00                	mov    (%eax),%eax
80107fa5:	83 e0 fb             	and    $0xfffffffb,%eax
80107fa8:	89 c2                	mov    %eax,%edx
80107faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fad:	89 10                	mov    %edx,(%eax)
}
80107faf:	90                   	nop
80107fb0:	c9                   	leave  
80107fb1:	c3                   	ret    

80107fb2 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107fb2:	55                   	push   %ebp
80107fb3:	89 e5                	mov    %esp,%ebp
80107fb5:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107fb8:	e8 59 f9 ff ff       	call   80107916 <setupkvm>
80107fbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fc4:	75 0a                	jne    80107fd0 <copyuvm+0x1e>
    return 0;
80107fc6:	b8 00 00 00 00       	mov    $0x0,%eax
80107fcb:	e9 d6 00 00 00       	jmp    801080a6 <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107fd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fd7:	e9 a3 00 00 00       	jmp    8010807f <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80107fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdf:	83 ec 04             	sub    $0x4,%esp
80107fe2:	6a 00                	push   $0x0
80107fe4:	50                   	push   %eax
80107fe5:	ff 75 08             	push   0x8(%ebp)
80107fe8:	e8 03 f8 ff ff       	call   801077f0 <walkpgdir>
80107fed:	83 c4 10             	add    $0x10,%esp
80107ff0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ff3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ff7:	74 7b                	je     80108074 <copyuvm+0xc2>
      continue;
    }
    if(!(*pte & PTE_P)){
80107ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffc:	8b 00                	mov    (%eax),%eax
80107ffe:	83 e0 01             	and    $0x1,%eax
80108001:	85 c0                	test   %eax,%eax
80108003:	74 72                	je     80108077 <copyuvm+0xc5>
      continue;
    }
    pa = PTE_ADDR(*pte);
80108005:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108008:	8b 00                	mov    (%eax),%eax
8010800a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010800f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108015:	8b 00                	mov    (%eax),%eax
80108017:	25 ff 0f 00 00       	and    $0xfff,%eax
8010801c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010801f:	e8 6e ac ff ff       	call   80102c92 <kalloc>
80108024:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108027:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010802b:	74 62                	je     8010808f <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010802d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108030:	05 00 00 00 80       	add    $0x80000000,%eax
80108035:	83 ec 04             	sub    $0x4,%esp
80108038:	68 00 10 00 00       	push   $0x1000
8010803d:	50                   	push   %eax
8010803e:	ff 75 e0             	push   -0x20(%ebp)
80108041:	e8 ec cf ff ff       	call   80105032 <memmove>
80108046:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108049:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010804c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010804f:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	83 ec 0c             	sub    $0xc,%esp
8010805b:	52                   	push   %edx
8010805c:	51                   	push   %ecx
8010805d:	68 00 10 00 00       	push   $0x1000
80108062:	50                   	push   %eax
80108063:	ff 75 f0             	push   -0x10(%ebp)
80108066:	e8 1b f8 ff ff       	call   80107886 <mappages>
8010806b:	83 c4 20             	add    $0x20,%esp
8010806e:	85 c0                	test   %eax,%eax
80108070:	78 20                	js     80108092 <copyuvm+0xe0>
80108072:	eb 04                	jmp    80108078 <copyuvm+0xc6>
      continue;
80108074:	90                   	nop
80108075:	eb 01                	jmp    80108078 <copyuvm+0xc6>
      continue;
80108077:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80108078:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010807f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108082:	85 c0                	test   %eax,%eax
80108084:	0f 89 52 ff ff ff    	jns    80107fdc <copyuvm+0x2a>
      goto bad;
  }
  return d;
8010808a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808d:	eb 17                	jmp    801080a6 <copyuvm+0xf4>
      goto bad;
8010808f:	90                   	nop
80108090:	eb 01                	jmp    80108093 <copyuvm+0xe1>
      goto bad;
80108092:	90                   	nop

bad:
  freevm(d);
80108093:	83 ec 0c             	sub    $0xc,%esp
80108096:	ff 75 f0             	push   -0x10(%ebp)
80108099:	e8 3a fe ff ff       	call   80107ed8 <freevm>
8010809e:	83 c4 10             	add    $0x10,%esp
  return 0;
801080a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080a6:	c9                   	leave  
801080a7:	c3                   	ret    

801080a8 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801080a8:	55                   	push   %ebp
801080a9:	89 e5                	mov    %esp,%ebp
801080ab:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080ae:	83 ec 04             	sub    $0x4,%esp
801080b1:	6a 00                	push   $0x0
801080b3:	ff 75 0c             	push   0xc(%ebp)
801080b6:	ff 75 08             	push   0x8(%ebp)
801080b9:	e8 32 f7 ff ff       	call   801077f0 <walkpgdir>
801080be:	83 c4 10             	add    $0x10,%esp
801080c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801080c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c7:	8b 00                	mov    (%eax),%eax
801080c9:	83 e0 01             	and    $0x1,%eax
801080cc:	85 c0                	test   %eax,%eax
801080ce:	75 07                	jne    801080d7 <uva2ka+0x2f>
    return 0;
801080d0:	b8 00 00 00 00       	mov    $0x0,%eax
801080d5:	eb 22                	jmp    801080f9 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801080d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080da:	8b 00                	mov    (%eax),%eax
801080dc:	83 e0 04             	and    $0x4,%eax
801080df:	85 c0                	test   %eax,%eax
801080e1:	75 07                	jne    801080ea <uva2ka+0x42>
    return 0;
801080e3:	b8 00 00 00 00       	mov    $0x0,%eax
801080e8:	eb 0f                	jmp    801080f9 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	8b 00                	mov    (%eax),%eax
801080ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f4:	05 00 00 00 80       	add    $0x80000000,%eax
}
801080f9:	c9                   	leave  
801080fa:	c3                   	ret    

801080fb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801080fb:	55                   	push   %ebp
801080fc:	89 e5                	mov    %esp,%ebp
801080fe:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108101:	8b 45 10             	mov    0x10(%ebp),%eax
80108104:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108107:	eb 7f                	jmp    80108188 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010810c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108111:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108117:	83 ec 08             	sub    $0x8,%esp
8010811a:	50                   	push   %eax
8010811b:	ff 75 08             	push   0x8(%ebp)
8010811e:	e8 85 ff ff ff       	call   801080a8 <uva2ka>
80108123:	83 c4 10             	add    $0x10,%esp
80108126:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108129:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010812d:	75 07                	jne    80108136 <copyout+0x3b>
      return -1;
8010812f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108134:	eb 61                	jmp    80108197 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108139:	2b 45 0c             	sub    0xc(%ebp),%eax
8010813c:	05 00 10 00 00       	add    $0x1000,%eax
80108141:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108147:	3b 45 14             	cmp    0x14(%ebp),%eax
8010814a:	76 06                	jbe    80108152 <copyout+0x57>
      n = len;
8010814c:	8b 45 14             	mov    0x14(%ebp),%eax
8010814f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108152:	8b 45 0c             	mov    0xc(%ebp),%eax
80108155:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108158:	89 c2                	mov    %eax,%edx
8010815a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010815d:	01 d0                	add    %edx,%eax
8010815f:	83 ec 04             	sub    $0x4,%esp
80108162:	ff 75 f0             	push   -0x10(%ebp)
80108165:	ff 75 f4             	push   -0xc(%ebp)
80108168:	50                   	push   %eax
80108169:	e8 c4 ce ff ff       	call   80105032 <memmove>
8010816e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108174:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010817a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010817d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108180:	05 00 10 00 00       	add    $0x1000,%eax
80108185:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108188:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010818c:	0f 85 77 ff ff ff    	jne    80108109 <copyout+0xe>
  }
  return 0;
80108192:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108197:	c9                   	leave  
80108198:	c3                   	ret    

80108199 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108199:	55                   	push   %ebp
8010819a:	89 e5                	mov    %esp,%ebp
8010819c:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010819f:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801081a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081a9:	8b 40 08             	mov    0x8(%eax),%eax
801081ac:	05 00 00 00 80       	add    $0x80000000,%eax
801081b1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801081b4:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801081bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081be:	8b 40 24             	mov    0x24(%eax),%eax
801081c1:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
801081c6:	c7 05 80 9c 11 80 00 	movl   $0x0,0x80119c80
801081cd:	00 00 00 

  while(i<madt->len){
801081d0:	90                   	nop
801081d1:	e9 bd 00 00 00       	jmp    80108293 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
801081d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081dc:	01 d0                	add    %edx,%eax
801081de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801081e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e4:	0f b6 00             	movzbl (%eax),%eax
801081e7:	0f b6 c0             	movzbl %al,%eax
801081ea:	83 f8 05             	cmp    $0x5,%eax
801081ed:	0f 87 a0 00 00 00    	ja     80108293 <mpinit_uefi+0xfa>
801081f3:	8b 04 85 24 ad 10 80 	mov    -0x7fef52dc(,%eax,4),%eax
801081fa:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801081fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108202:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80108207:	83 f8 03             	cmp    $0x3,%eax
8010820a:	7f 28                	jg     80108234 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010820c:	8b 15 80 9c 11 80    	mov    0x80119c80,%edx
80108212:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108215:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108219:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010821f:	81 c2 c0 99 11 80    	add    $0x801199c0,%edx
80108225:	88 02                	mov    %al,(%edx)
          ncpu++;
80108227:	a1 80 9c 11 80       	mov    0x80119c80,%eax
8010822c:	83 c0 01             	add    $0x1,%eax
8010822f:	a3 80 9c 11 80       	mov    %eax,0x80119c80
        }
        i += lapic_entry->record_len;
80108234:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108237:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010823b:	0f b6 c0             	movzbl %al,%eax
8010823e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108241:	eb 50                	jmp    80108293 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010824c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108250:	a2 84 9c 11 80       	mov    %al,0x80119c84
        i += ioapic->record_len;
80108255:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108258:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010825c:	0f b6 c0             	movzbl %al,%eax
8010825f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108262:	eb 2f                	jmp    80108293 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108264:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108267:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010826a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010826d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108271:	0f b6 c0             	movzbl %al,%eax
80108274:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108277:	eb 1a                	jmp    80108293 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108279:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010827c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010827f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108282:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108286:	0f b6 c0             	movzbl %al,%eax
80108289:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010828c:	eb 05                	jmp    80108293 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
8010828e:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108292:	90                   	nop
  while(i<madt->len){
80108293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108296:	8b 40 04             	mov    0x4(%eax),%eax
80108299:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010829c:	0f 82 34 ff ff ff    	jb     801081d6 <mpinit_uefi+0x3d>
    }
  }

}
801082a2:	90                   	nop
801082a3:	90                   	nop
801082a4:	c9                   	leave  
801082a5:	c3                   	ret    

801082a6 <inb>:
{
801082a6:	55                   	push   %ebp
801082a7:	89 e5                	mov    %esp,%ebp
801082a9:	83 ec 14             	sub    $0x14,%esp
801082ac:	8b 45 08             	mov    0x8(%ebp),%eax
801082af:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801082b3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801082b7:	89 c2                	mov    %eax,%edx
801082b9:	ec                   	in     (%dx),%al
801082ba:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801082bd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801082c1:	c9                   	leave  
801082c2:	c3                   	ret    

801082c3 <outb>:
{
801082c3:	55                   	push   %ebp
801082c4:	89 e5                	mov    %esp,%ebp
801082c6:	83 ec 08             	sub    $0x8,%esp
801082c9:	8b 45 08             	mov    0x8(%ebp),%eax
801082cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801082cf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801082d3:	89 d0                	mov    %edx,%eax
801082d5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801082d8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801082dc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801082e0:	ee                   	out    %al,(%dx)
}
801082e1:	90                   	nop
801082e2:	c9                   	leave  
801082e3:	c3                   	ret    

801082e4 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801082e4:	55                   	push   %ebp
801082e5:	89 e5                	mov    %esp,%ebp
801082e7:	83 ec 28             	sub    $0x28,%esp
801082ea:	8b 45 08             	mov    0x8(%ebp),%eax
801082ed:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801082f0:	6a 00                	push   $0x0
801082f2:	68 fa 03 00 00       	push   $0x3fa
801082f7:	e8 c7 ff ff ff       	call   801082c3 <outb>
801082fc:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801082ff:	68 80 00 00 00       	push   $0x80
80108304:	68 fb 03 00 00       	push   $0x3fb
80108309:	e8 b5 ff ff ff       	call   801082c3 <outb>
8010830e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108311:	6a 0c                	push   $0xc
80108313:	68 f8 03 00 00       	push   $0x3f8
80108318:	e8 a6 ff ff ff       	call   801082c3 <outb>
8010831d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108320:	6a 00                	push   $0x0
80108322:	68 f9 03 00 00       	push   $0x3f9
80108327:	e8 97 ff ff ff       	call   801082c3 <outb>
8010832c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010832f:	6a 03                	push   $0x3
80108331:	68 fb 03 00 00       	push   $0x3fb
80108336:	e8 88 ff ff ff       	call   801082c3 <outb>
8010833b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010833e:	6a 00                	push   $0x0
80108340:	68 fc 03 00 00       	push   $0x3fc
80108345:	e8 79 ff ff ff       	call   801082c3 <outb>
8010834a:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010834d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108354:	eb 11                	jmp    80108367 <uart_debug+0x83>
80108356:	83 ec 0c             	sub    $0xc,%esp
80108359:	6a 0a                	push   $0xa
8010835b:	e8 c9 ac ff ff       	call   80103029 <microdelay>
80108360:	83 c4 10             	add    $0x10,%esp
80108363:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108367:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010836b:	7f 1a                	jg     80108387 <uart_debug+0xa3>
8010836d:	83 ec 0c             	sub    $0xc,%esp
80108370:	68 fd 03 00 00       	push   $0x3fd
80108375:	e8 2c ff ff ff       	call   801082a6 <inb>
8010837a:	83 c4 10             	add    $0x10,%esp
8010837d:	0f b6 c0             	movzbl %al,%eax
80108380:	83 e0 20             	and    $0x20,%eax
80108383:	85 c0                	test   %eax,%eax
80108385:	74 cf                	je     80108356 <uart_debug+0x72>
  outb(COM1+0, p);
80108387:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010838b:	0f b6 c0             	movzbl %al,%eax
8010838e:	83 ec 08             	sub    $0x8,%esp
80108391:	50                   	push   %eax
80108392:	68 f8 03 00 00       	push   $0x3f8
80108397:	e8 27 ff ff ff       	call   801082c3 <outb>
8010839c:	83 c4 10             	add    $0x10,%esp
}
8010839f:	90                   	nop
801083a0:	c9                   	leave  
801083a1:	c3                   	ret    

801083a2 <uart_debugs>:

void uart_debugs(char *p){
801083a2:	55                   	push   %ebp
801083a3:	89 e5                	mov    %esp,%ebp
801083a5:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801083a8:	eb 1b                	jmp    801083c5 <uart_debugs+0x23>
    uart_debug(*p++);
801083aa:	8b 45 08             	mov    0x8(%ebp),%eax
801083ad:	8d 50 01             	lea    0x1(%eax),%edx
801083b0:	89 55 08             	mov    %edx,0x8(%ebp)
801083b3:	0f b6 00             	movzbl (%eax),%eax
801083b6:	0f be c0             	movsbl %al,%eax
801083b9:	83 ec 0c             	sub    $0xc,%esp
801083bc:	50                   	push   %eax
801083bd:	e8 22 ff ff ff       	call   801082e4 <uart_debug>
801083c2:	83 c4 10             	add    $0x10,%esp
  while(*p){
801083c5:	8b 45 08             	mov    0x8(%ebp),%eax
801083c8:	0f b6 00             	movzbl (%eax),%eax
801083cb:	84 c0                	test   %al,%al
801083cd:	75 db                	jne    801083aa <uart_debugs+0x8>
  }
}
801083cf:	90                   	nop
801083d0:	90                   	nop
801083d1:	c9                   	leave  
801083d2:	c3                   	ret    

801083d3 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801083d3:	55                   	push   %ebp
801083d4:	89 e5                	mov    %esp,%ebp
801083d6:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801083d9:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801083e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083e3:	8b 50 14             	mov    0x14(%eax),%edx
801083e6:	8b 40 10             	mov    0x10(%eax),%eax
801083e9:	a3 88 9c 11 80       	mov    %eax,0x80119c88
  gpu.vram_size = boot_param->graphic_config.frame_size;
801083ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083f1:	8b 50 1c             	mov    0x1c(%eax),%edx
801083f4:	8b 40 18             	mov    0x18(%eax),%eax
801083f7:	a3 90 9c 11 80       	mov    %eax,0x80119c90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801083fc:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
80108402:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108407:	29 d0                	sub    %edx,%eax
80108409:	a3 8c 9c 11 80       	mov    %eax,0x80119c8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010840e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108411:	8b 50 24             	mov    0x24(%eax),%edx
80108414:	8b 40 20             	mov    0x20(%eax),%eax
80108417:	a3 94 9c 11 80       	mov    %eax,0x80119c94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010841c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010841f:	8b 50 2c             	mov    0x2c(%eax),%edx
80108422:	8b 40 28             	mov    0x28(%eax),%eax
80108425:	a3 98 9c 11 80       	mov    %eax,0x80119c98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010842a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010842d:	8b 50 34             	mov    0x34(%eax),%edx
80108430:	8b 40 30             	mov    0x30(%eax),%eax
80108433:	a3 9c 9c 11 80       	mov    %eax,0x80119c9c
}
80108438:	90                   	nop
80108439:	c9                   	leave  
8010843a:	c3                   	ret    

8010843b <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010843b:	55                   	push   %ebp
8010843c:	89 e5                	mov    %esp,%ebp
8010843e:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108441:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
80108447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844a:	0f af d0             	imul   %eax,%edx
8010844d:	8b 45 08             	mov    0x8(%ebp),%eax
80108450:	01 d0                	add    %edx,%eax
80108452:	c1 e0 02             	shl    $0x2,%eax
80108455:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108458:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
8010845e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108461:	01 d0                	add    %edx,%eax
80108463:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108466:	8b 45 10             	mov    0x10(%ebp),%eax
80108469:	0f b6 10             	movzbl (%eax),%edx
8010846c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010846f:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108471:	8b 45 10             	mov    0x10(%ebp),%eax
80108474:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108478:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010847b:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010847e:	8b 45 10             	mov    0x10(%ebp),%eax
80108481:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108485:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108488:	88 50 02             	mov    %dl,0x2(%eax)
}
8010848b:	90                   	nop
8010848c:	c9                   	leave  
8010848d:	c3                   	ret    

8010848e <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010848e:	55                   	push   %ebp
8010848f:	89 e5                	mov    %esp,%ebp
80108491:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108494:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
8010849a:	8b 45 08             	mov    0x8(%ebp),%eax
8010849d:	0f af c2             	imul   %edx,%eax
801084a0:	c1 e0 02             	shl    $0x2,%eax
801084a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801084a6:	a1 90 9c 11 80       	mov    0x80119c90,%eax
801084ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084ae:	29 d0                	sub    %edx,%eax
801084b0:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
801084b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084b9:	01 ca                	add    %ecx,%edx
801084bb:	89 d1                	mov    %edx,%ecx
801084bd:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
801084c3:	83 ec 04             	sub    $0x4,%esp
801084c6:	50                   	push   %eax
801084c7:	51                   	push   %ecx
801084c8:	52                   	push   %edx
801084c9:	e8 64 cb ff ff       	call   80105032 <memmove>
801084ce:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801084d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d4:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
801084da:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
801084e0:	01 ca                	add    %ecx,%edx
801084e2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801084e5:	29 ca                	sub    %ecx,%edx
801084e7:	83 ec 04             	sub    $0x4,%esp
801084ea:	50                   	push   %eax
801084eb:	6a 00                	push   $0x0
801084ed:	52                   	push   %edx
801084ee:	e8 80 ca ff ff       	call   80104f73 <memset>
801084f3:	83 c4 10             	add    $0x10,%esp
}
801084f6:	90                   	nop
801084f7:	c9                   	leave  
801084f8:	c3                   	ret    

801084f9 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801084f9:	55                   	push   %ebp
801084fa:	89 e5                	mov    %esp,%ebp
801084fc:	53                   	push   %ebx
801084fd:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108507:	e9 b1 00 00 00       	jmp    801085bd <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010850c:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108513:	e9 97 00 00 00       	jmp    801085af <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108518:	8b 45 10             	mov    0x10(%ebp),%eax
8010851b:	83 e8 20             	sub    $0x20,%eax
8010851e:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108524:	01 d0                	add    %edx,%eax
80108526:	0f b7 84 00 40 ad 10 	movzwl -0x7fef52c0(%eax,%eax,1),%eax
8010852d:	80 
8010852e:	0f b7 d0             	movzwl %ax,%edx
80108531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108534:	bb 01 00 00 00       	mov    $0x1,%ebx
80108539:	89 c1                	mov    %eax,%ecx
8010853b:	d3 e3                	shl    %cl,%ebx
8010853d:	89 d8                	mov    %ebx,%eax
8010853f:	21 d0                	and    %edx,%eax
80108541:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108547:	ba 01 00 00 00       	mov    $0x1,%edx
8010854c:	89 c1                	mov    %eax,%ecx
8010854e:	d3 e2                	shl    %cl,%edx
80108550:	89 d0                	mov    %edx,%eax
80108552:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108555:	75 2b                	jne    80108582 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108557:	8b 55 0c             	mov    0xc(%ebp),%edx
8010855a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855d:	01 c2                	add    %eax,%edx
8010855f:	b8 0e 00 00 00       	mov    $0xe,%eax
80108564:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108567:	89 c1                	mov    %eax,%ecx
80108569:	8b 45 08             	mov    0x8(%ebp),%eax
8010856c:	01 c8                	add    %ecx,%eax
8010856e:	83 ec 04             	sub    $0x4,%esp
80108571:	68 e0 f4 10 80       	push   $0x8010f4e0
80108576:	52                   	push   %edx
80108577:	50                   	push   %eax
80108578:	e8 be fe ff ff       	call   8010843b <graphic_draw_pixel>
8010857d:	83 c4 10             	add    $0x10,%esp
80108580:	eb 29                	jmp    801085ab <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108582:	8b 55 0c             	mov    0xc(%ebp),%edx
80108585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108588:	01 c2                	add    %eax,%edx
8010858a:	b8 0e 00 00 00       	mov    $0xe,%eax
8010858f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108592:	89 c1                	mov    %eax,%ecx
80108594:	8b 45 08             	mov    0x8(%ebp),%eax
80108597:	01 c8                	add    %ecx,%eax
80108599:	83 ec 04             	sub    $0x4,%esp
8010859c:	68 a0 9c 11 80       	push   $0x80119ca0
801085a1:	52                   	push   %edx
801085a2:	50                   	push   %eax
801085a3:	e8 93 fe ff ff       	call   8010843b <graphic_draw_pixel>
801085a8:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801085ab:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801085af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085b3:	0f 89 5f ff ff ff    	jns    80108518 <font_render+0x1f>
  for(int i=0;i<30;i++){
801085b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085bd:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801085c1:	0f 8e 45 ff ff ff    	jle    8010850c <font_render+0x13>
      }
    }
  }
}
801085c7:	90                   	nop
801085c8:	90                   	nop
801085c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085cc:	c9                   	leave  
801085cd:	c3                   	ret    

801085ce <font_render_string>:

void font_render_string(char *string,int row){
801085ce:	55                   	push   %ebp
801085cf:	89 e5                	mov    %esp,%ebp
801085d1:	53                   	push   %ebx
801085d2:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801085d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801085dc:	eb 33                	jmp    80108611 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801085de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085e1:	8b 45 08             	mov    0x8(%ebp),%eax
801085e4:	01 d0                	add    %edx,%eax
801085e6:	0f b6 00             	movzbl (%eax),%eax
801085e9:	0f be c8             	movsbl %al,%ecx
801085ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ef:	6b d0 1e             	imul   $0x1e,%eax,%edx
801085f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801085f5:	89 d8                	mov    %ebx,%eax
801085f7:	c1 e0 04             	shl    $0x4,%eax
801085fa:	29 d8                	sub    %ebx,%eax
801085fc:	83 c0 02             	add    $0x2,%eax
801085ff:	83 ec 04             	sub    $0x4,%esp
80108602:	51                   	push   %ecx
80108603:	52                   	push   %edx
80108604:	50                   	push   %eax
80108605:	e8 ef fe ff ff       	call   801084f9 <font_render>
8010860a:	83 c4 10             	add    $0x10,%esp
    i++;
8010860d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108614:	8b 45 08             	mov    0x8(%ebp),%eax
80108617:	01 d0                	add    %edx,%eax
80108619:	0f b6 00             	movzbl (%eax),%eax
8010861c:	84 c0                	test   %al,%al
8010861e:	74 06                	je     80108626 <font_render_string+0x58>
80108620:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108624:	7e b8                	jle    801085de <font_render_string+0x10>
  }
}
80108626:	90                   	nop
80108627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010862a:	c9                   	leave  
8010862b:	c3                   	ret    

8010862c <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010862c:	55                   	push   %ebp
8010862d:	89 e5                	mov    %esp,%ebp
8010862f:	53                   	push   %ebx
80108630:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108633:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010863a:	eb 6b                	jmp    801086a7 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010863c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108643:	eb 58                	jmp    8010869d <pci_init+0x71>
      for(int k=0;k<8;k++){
80108645:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010864c:	eb 45                	jmp    80108693 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010864e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108651:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108657:	83 ec 0c             	sub    $0xc,%esp
8010865a:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010865d:	53                   	push   %ebx
8010865e:	6a 00                	push   $0x0
80108660:	51                   	push   %ecx
80108661:	52                   	push   %edx
80108662:	50                   	push   %eax
80108663:	e8 b0 00 00 00       	call   80108718 <pci_access_config>
80108668:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010866b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010866e:	0f b7 c0             	movzwl %ax,%eax
80108671:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108676:	74 17                	je     8010868f <pci_init+0x63>
        pci_init_device(i,j,k);
80108678:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010867b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010867e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108681:	83 ec 04             	sub    $0x4,%esp
80108684:	51                   	push   %ecx
80108685:	52                   	push   %edx
80108686:	50                   	push   %eax
80108687:	e8 37 01 00 00       	call   801087c3 <pci_init_device>
8010868c:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010868f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108693:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108697:	7e b5                	jle    8010864e <pci_init+0x22>
    for(int j=0;j<32;j++){
80108699:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010869d:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801086a1:	7e a2                	jle    80108645 <pci_init+0x19>
  for(int i=0;i<256;i++){
801086a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086a7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801086ae:	7e 8c                	jle    8010863c <pci_init+0x10>
      }
      }
    }
  }
}
801086b0:	90                   	nop
801086b1:	90                   	nop
801086b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086b5:	c9                   	leave  
801086b6:	c3                   	ret    

801086b7 <pci_write_config>:

void pci_write_config(uint config){
801086b7:	55                   	push   %ebp
801086b8:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801086ba:	8b 45 08             	mov    0x8(%ebp),%eax
801086bd:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801086c2:	89 c0                	mov    %eax,%eax
801086c4:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801086c5:	90                   	nop
801086c6:	5d                   	pop    %ebp
801086c7:	c3                   	ret    

801086c8 <pci_write_data>:

void pci_write_data(uint config){
801086c8:	55                   	push   %ebp
801086c9:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801086cb:	8b 45 08             	mov    0x8(%ebp),%eax
801086ce:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801086d3:	89 c0                	mov    %eax,%eax
801086d5:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801086d6:	90                   	nop
801086d7:	5d                   	pop    %ebp
801086d8:	c3                   	ret    

801086d9 <pci_read_config>:
uint pci_read_config(){
801086d9:	55                   	push   %ebp
801086da:	89 e5                	mov    %esp,%ebp
801086dc:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801086df:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801086e4:	ed                   	in     (%dx),%eax
801086e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801086e8:	83 ec 0c             	sub    $0xc,%esp
801086eb:	68 c8 00 00 00       	push   $0xc8
801086f0:	e8 34 a9 ff ff       	call   80103029 <microdelay>
801086f5:	83 c4 10             	add    $0x10,%esp
  return data;
801086f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801086fb:	c9                   	leave  
801086fc:	c3                   	ret    

801086fd <pci_test>:


void pci_test(){
801086fd:	55                   	push   %ebp
801086fe:	89 e5                	mov    %esp,%ebp
80108700:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108703:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010870a:	ff 75 fc             	push   -0x4(%ebp)
8010870d:	e8 a5 ff ff ff       	call   801086b7 <pci_write_config>
80108712:	83 c4 04             	add    $0x4,%esp
}
80108715:	90                   	nop
80108716:	c9                   	leave  
80108717:	c3                   	ret    

80108718 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108718:	55                   	push   %ebp
80108719:	89 e5                	mov    %esp,%ebp
8010871b:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010871e:	8b 45 08             	mov    0x8(%ebp),%eax
80108721:	c1 e0 10             	shl    $0x10,%eax
80108724:	25 00 00 ff 00       	and    $0xff0000,%eax
80108729:	89 c2                	mov    %eax,%edx
8010872b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010872e:	c1 e0 0b             	shl    $0xb,%eax
80108731:	0f b7 c0             	movzwl %ax,%eax
80108734:	09 c2                	or     %eax,%edx
80108736:	8b 45 10             	mov    0x10(%ebp),%eax
80108739:	c1 e0 08             	shl    $0x8,%eax
8010873c:	25 00 07 00 00       	and    $0x700,%eax
80108741:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108743:	8b 45 14             	mov    0x14(%ebp),%eax
80108746:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010874b:	09 d0                	or     %edx,%eax
8010874d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108752:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108755:	ff 75 f4             	push   -0xc(%ebp)
80108758:	e8 5a ff ff ff       	call   801086b7 <pci_write_config>
8010875d:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108760:	e8 74 ff ff ff       	call   801086d9 <pci_read_config>
80108765:	8b 55 18             	mov    0x18(%ebp),%edx
80108768:	89 02                	mov    %eax,(%edx)
}
8010876a:	90                   	nop
8010876b:	c9                   	leave  
8010876c:	c3                   	ret    

8010876d <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010876d:	55                   	push   %ebp
8010876e:	89 e5                	mov    %esp,%ebp
80108770:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108773:	8b 45 08             	mov    0x8(%ebp),%eax
80108776:	c1 e0 10             	shl    $0x10,%eax
80108779:	25 00 00 ff 00       	and    $0xff0000,%eax
8010877e:	89 c2                	mov    %eax,%edx
80108780:	8b 45 0c             	mov    0xc(%ebp),%eax
80108783:	c1 e0 0b             	shl    $0xb,%eax
80108786:	0f b7 c0             	movzwl %ax,%eax
80108789:	09 c2                	or     %eax,%edx
8010878b:	8b 45 10             	mov    0x10(%ebp),%eax
8010878e:	c1 e0 08             	shl    $0x8,%eax
80108791:	25 00 07 00 00       	and    $0x700,%eax
80108796:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108798:	8b 45 14             	mov    0x14(%ebp),%eax
8010879b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087a0:	09 d0                	or     %edx,%eax
801087a2:	0d 00 00 00 80       	or     $0x80000000,%eax
801087a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801087aa:	ff 75 fc             	push   -0x4(%ebp)
801087ad:	e8 05 ff ff ff       	call   801086b7 <pci_write_config>
801087b2:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801087b5:	ff 75 18             	push   0x18(%ebp)
801087b8:	e8 0b ff ff ff       	call   801086c8 <pci_write_data>
801087bd:	83 c4 04             	add    $0x4,%esp
}
801087c0:	90                   	nop
801087c1:	c9                   	leave  
801087c2:	c3                   	ret    

801087c3 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801087c3:	55                   	push   %ebp
801087c4:	89 e5                	mov    %esp,%ebp
801087c6:	53                   	push   %ebx
801087c7:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801087ca:	8b 45 08             	mov    0x8(%ebp),%eax
801087cd:	a2 a4 9c 11 80       	mov    %al,0x80119ca4
  dev.device_num = device_num;
801087d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d5:	a2 a5 9c 11 80       	mov    %al,0x80119ca5
  dev.function_num = function_num;
801087da:	8b 45 10             	mov    0x10(%ebp),%eax
801087dd:	a2 a6 9c 11 80       	mov    %al,0x80119ca6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801087e2:	ff 75 10             	push   0x10(%ebp)
801087e5:	ff 75 0c             	push   0xc(%ebp)
801087e8:	ff 75 08             	push   0x8(%ebp)
801087eb:	68 84 c3 10 80       	push   $0x8010c384
801087f0:	e8 ff 7b ff ff       	call   801003f4 <cprintf>
801087f5:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801087f8:	83 ec 0c             	sub    $0xc,%esp
801087fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087fe:	50                   	push   %eax
801087ff:	6a 00                	push   $0x0
80108801:	ff 75 10             	push   0x10(%ebp)
80108804:	ff 75 0c             	push   0xc(%ebp)
80108807:	ff 75 08             	push   0x8(%ebp)
8010880a:	e8 09 ff ff ff       	call   80108718 <pci_access_config>
8010880f:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108815:	c1 e8 10             	shr    $0x10,%eax
80108818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010881b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010881e:	25 ff ff 00 00       	and    $0xffff,%eax
80108823:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108829:	a3 a8 9c 11 80       	mov    %eax,0x80119ca8
  dev.vendor_id = vendor_id;
8010882e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108831:	a3 ac 9c 11 80       	mov    %eax,0x80119cac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108836:	83 ec 04             	sub    $0x4,%esp
80108839:	ff 75 f0             	push   -0x10(%ebp)
8010883c:	ff 75 f4             	push   -0xc(%ebp)
8010883f:	68 b8 c3 10 80       	push   $0x8010c3b8
80108844:	e8 ab 7b ff ff       	call   801003f4 <cprintf>
80108849:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010884c:	83 ec 0c             	sub    $0xc,%esp
8010884f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108852:	50                   	push   %eax
80108853:	6a 08                	push   $0x8
80108855:	ff 75 10             	push   0x10(%ebp)
80108858:	ff 75 0c             	push   0xc(%ebp)
8010885b:	ff 75 08             	push   0x8(%ebp)
8010885e:	e8 b5 fe ff ff       	call   80108718 <pci_access_config>
80108863:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108866:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108869:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010886c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010886f:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108872:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108878:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010887b:	0f b6 c0             	movzbl %al,%eax
8010887e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108881:	c1 eb 18             	shr    $0x18,%ebx
80108884:	83 ec 0c             	sub    $0xc,%esp
80108887:	51                   	push   %ecx
80108888:	52                   	push   %edx
80108889:	50                   	push   %eax
8010888a:	53                   	push   %ebx
8010888b:	68 dc c3 10 80       	push   $0x8010c3dc
80108890:	e8 5f 7b ff ff       	call   801003f4 <cprintf>
80108895:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108898:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010889b:	c1 e8 18             	shr    $0x18,%eax
8010889e:	a2 b0 9c 11 80       	mov    %al,0x80119cb0
  dev.sub_class = (data>>16)&0xFF;
801088a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a6:	c1 e8 10             	shr    $0x10,%eax
801088a9:	a2 b1 9c 11 80       	mov    %al,0x80119cb1
  dev.interface = (data>>8)&0xFF;
801088ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b1:	c1 e8 08             	shr    $0x8,%eax
801088b4:	a2 b2 9c 11 80       	mov    %al,0x80119cb2
  dev.revision_id = data&0xFF;
801088b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088bc:	a2 b3 9c 11 80       	mov    %al,0x80119cb3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801088c1:	83 ec 0c             	sub    $0xc,%esp
801088c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088c7:	50                   	push   %eax
801088c8:	6a 10                	push   $0x10
801088ca:	ff 75 10             	push   0x10(%ebp)
801088cd:	ff 75 0c             	push   0xc(%ebp)
801088d0:	ff 75 08             	push   0x8(%ebp)
801088d3:	e8 40 fe ff ff       	call   80108718 <pci_access_config>
801088d8:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801088db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088de:	a3 b4 9c 11 80       	mov    %eax,0x80119cb4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801088e3:	83 ec 0c             	sub    $0xc,%esp
801088e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088e9:	50                   	push   %eax
801088ea:	6a 14                	push   $0x14
801088ec:	ff 75 10             	push   0x10(%ebp)
801088ef:	ff 75 0c             	push   0xc(%ebp)
801088f2:	ff 75 08             	push   0x8(%ebp)
801088f5:	e8 1e fe ff ff       	call   80108718 <pci_access_config>
801088fa:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801088fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108900:	a3 b8 9c 11 80       	mov    %eax,0x80119cb8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108905:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010890c:	75 5a                	jne    80108968 <pci_init_device+0x1a5>
8010890e:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108915:	75 51                	jne    80108968 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108917:	83 ec 0c             	sub    $0xc,%esp
8010891a:	68 21 c4 10 80       	push   $0x8010c421
8010891f:	e8 d0 7a ff ff       	call   801003f4 <cprintf>
80108924:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108927:	83 ec 0c             	sub    $0xc,%esp
8010892a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010892d:	50                   	push   %eax
8010892e:	68 f0 00 00 00       	push   $0xf0
80108933:	ff 75 10             	push   0x10(%ebp)
80108936:	ff 75 0c             	push   0xc(%ebp)
80108939:	ff 75 08             	push   0x8(%ebp)
8010893c:	e8 d7 fd ff ff       	call   80108718 <pci_access_config>
80108941:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108944:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108947:	83 ec 08             	sub    $0x8,%esp
8010894a:	50                   	push   %eax
8010894b:	68 3b c4 10 80       	push   $0x8010c43b
80108950:	e8 9f 7a ff ff       	call   801003f4 <cprintf>
80108955:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108958:	83 ec 0c             	sub    $0xc,%esp
8010895b:	68 a4 9c 11 80       	push   $0x80119ca4
80108960:	e8 09 00 00 00       	call   8010896e <i8254_init>
80108965:	83 c4 10             	add    $0x10,%esp
  }
}
80108968:	90                   	nop
80108969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010896c:	c9                   	leave  
8010896d:	c3                   	ret    

8010896e <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010896e:	55                   	push   %ebp
8010896f:	89 e5                	mov    %esp,%ebp
80108971:	53                   	push   %ebx
80108972:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108975:	8b 45 08             	mov    0x8(%ebp),%eax
80108978:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010897c:	0f b6 c8             	movzbl %al,%ecx
8010897f:	8b 45 08             	mov    0x8(%ebp),%eax
80108982:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108986:	0f b6 d0             	movzbl %al,%edx
80108989:	8b 45 08             	mov    0x8(%ebp),%eax
8010898c:	0f b6 00             	movzbl (%eax),%eax
8010898f:	0f b6 c0             	movzbl %al,%eax
80108992:	83 ec 0c             	sub    $0xc,%esp
80108995:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108998:	53                   	push   %ebx
80108999:	6a 04                	push   $0x4
8010899b:	51                   	push   %ecx
8010899c:	52                   	push   %edx
8010899d:	50                   	push   %eax
8010899e:	e8 75 fd ff ff       	call   80108718 <pci_access_config>
801089a3:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801089a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a9:	83 c8 04             	or     $0x4,%eax
801089ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801089af:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089b2:	8b 45 08             	mov    0x8(%ebp),%eax
801089b5:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801089b9:	0f b6 c8             	movzbl %al,%ecx
801089bc:	8b 45 08             	mov    0x8(%ebp),%eax
801089bf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089c3:	0f b6 d0             	movzbl %al,%edx
801089c6:	8b 45 08             	mov    0x8(%ebp),%eax
801089c9:	0f b6 00             	movzbl (%eax),%eax
801089cc:	0f b6 c0             	movzbl %al,%eax
801089cf:	83 ec 0c             	sub    $0xc,%esp
801089d2:	53                   	push   %ebx
801089d3:	6a 04                	push   $0x4
801089d5:	51                   	push   %ecx
801089d6:	52                   	push   %edx
801089d7:	50                   	push   %eax
801089d8:	e8 90 fd ff ff       	call   8010876d <pci_write_config_register>
801089dd:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801089e0:	8b 45 08             	mov    0x8(%ebp),%eax
801089e3:	8b 40 10             	mov    0x10(%eax),%eax
801089e6:	05 00 00 00 40       	add    $0x40000000,%eax
801089eb:	a3 bc 9c 11 80       	mov    %eax,0x80119cbc
  uint *ctrl = (uint *)base_addr;
801089f0:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801089f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801089f8:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801089fd:	05 d8 00 00 00       	add    $0xd8,%eax
80108a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a08:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a11:	8b 00                	mov    (%eax),%eax
80108a13:	0d 00 00 00 04       	or     $0x4000000,%eax
80108a18:	89 c2                	mov    %eax,%edx
80108a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1d:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a22:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2b:	8b 00                	mov    (%eax),%eax
80108a2d:	83 c8 40             	or     $0x40,%eax
80108a30:	89 c2                	mov    %eax,%edx
80108a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a35:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3a:	8b 10                	mov    (%eax),%edx
80108a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3f:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108a41:	83 ec 0c             	sub    $0xc,%esp
80108a44:	68 50 c4 10 80       	push   $0x8010c450
80108a49:	e8 a6 79 ff ff       	call   801003f4 <cprintf>
80108a4e:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108a51:	e8 3c a2 ff ff       	call   80102c92 <kalloc>
80108a56:	a3 c8 9c 11 80       	mov    %eax,0x80119cc8
  *intr_addr = 0;
80108a5b:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108a60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108a66:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108a6b:	83 ec 08             	sub    $0x8,%esp
80108a6e:	50                   	push   %eax
80108a6f:	68 72 c4 10 80       	push   $0x8010c472
80108a74:	e8 7b 79 ff ff       	call   801003f4 <cprintf>
80108a79:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108a7c:	e8 50 00 00 00       	call   80108ad1 <i8254_init_recv>
  i8254_init_send();
80108a81:	e8 69 03 00 00       	call   80108def <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108a86:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a8d:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108a90:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a97:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108a9a:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108aa1:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108aa4:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108aab:	0f b6 c0             	movzbl %al,%eax
80108aae:	83 ec 0c             	sub    $0xc,%esp
80108ab1:	53                   	push   %ebx
80108ab2:	51                   	push   %ecx
80108ab3:	52                   	push   %edx
80108ab4:	50                   	push   %eax
80108ab5:	68 80 c4 10 80       	push   $0x8010c480
80108aba:	e8 35 79 ff ff       	call   801003f4 <cprintf>
80108abf:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108acb:	90                   	nop
80108acc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108acf:	c9                   	leave  
80108ad0:	c3                   	ret    

80108ad1 <i8254_init_recv>:

void i8254_init_recv(){
80108ad1:	55                   	push   %ebp
80108ad2:	89 e5                	mov    %esp,%ebp
80108ad4:	57                   	push   %edi
80108ad5:	56                   	push   %esi
80108ad6:	53                   	push   %ebx
80108ad7:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108ada:	83 ec 0c             	sub    $0xc,%esp
80108add:	6a 00                	push   $0x0
80108adf:	e8 e8 04 00 00       	call   80108fcc <i8254_read_eeprom>
80108ae4:	83 c4 10             	add    $0x10,%esp
80108ae7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108aea:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108aed:	a2 c0 9c 11 80       	mov    %al,0x80119cc0
  mac_addr[1] = data_l>>8;
80108af2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108af5:	c1 e8 08             	shr    $0x8,%eax
80108af8:	a2 c1 9c 11 80       	mov    %al,0x80119cc1
  uint data_m = i8254_read_eeprom(0x1);
80108afd:	83 ec 0c             	sub    $0xc,%esp
80108b00:	6a 01                	push   $0x1
80108b02:	e8 c5 04 00 00       	call   80108fcc <i8254_read_eeprom>
80108b07:	83 c4 10             	add    $0x10,%esp
80108b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108b0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b10:	a2 c2 9c 11 80       	mov    %al,0x80119cc2
  mac_addr[3] = data_m>>8;
80108b15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b18:	c1 e8 08             	shr    $0x8,%eax
80108b1b:	a2 c3 9c 11 80       	mov    %al,0x80119cc3
  uint data_h = i8254_read_eeprom(0x2);
80108b20:	83 ec 0c             	sub    $0xc,%esp
80108b23:	6a 02                	push   $0x2
80108b25:	e8 a2 04 00 00       	call   80108fcc <i8254_read_eeprom>
80108b2a:	83 c4 10             	add    $0x10,%esp
80108b2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108b30:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b33:	a2 c4 9c 11 80       	mov    %al,0x80119cc4
  mac_addr[5] = data_h>>8;
80108b38:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b3b:	c1 e8 08             	shr    $0x8,%eax
80108b3e:	a2 c5 9c 11 80       	mov    %al,0x80119cc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108b43:	0f b6 05 c5 9c 11 80 	movzbl 0x80119cc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b4a:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108b4d:	0f b6 05 c4 9c 11 80 	movzbl 0x80119cc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b54:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108b57:	0f b6 05 c3 9c 11 80 	movzbl 0x80119cc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b5e:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108b61:	0f b6 05 c2 9c 11 80 	movzbl 0x80119cc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b68:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108b6b:	0f b6 05 c1 9c 11 80 	movzbl 0x80119cc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b72:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108b75:	0f b6 05 c0 9c 11 80 	movzbl 0x80119cc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b7c:	0f b6 c0             	movzbl %al,%eax
80108b7f:	83 ec 04             	sub    $0x4,%esp
80108b82:	57                   	push   %edi
80108b83:	56                   	push   %esi
80108b84:	53                   	push   %ebx
80108b85:	51                   	push   %ecx
80108b86:	52                   	push   %edx
80108b87:	50                   	push   %eax
80108b88:	68 98 c4 10 80       	push   $0x8010c498
80108b8d:	e8 62 78 ff ff       	call   801003f4 <cprintf>
80108b92:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108b95:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108b9a:	05 00 54 00 00       	add    $0x5400,%eax
80108b9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108ba2:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ba7:	05 04 54 00 00       	add    $0x5404,%eax
80108bac:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108baf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bb2:	c1 e0 10             	shl    $0x10,%eax
80108bb5:	0b 45 d8             	or     -0x28(%ebp),%eax
80108bb8:	89 c2                	mov    %eax,%edx
80108bba:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108bbd:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108bbf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bc2:	0d 00 00 00 80       	or     $0x80000000,%eax
80108bc7:	89 c2                	mov    %eax,%edx
80108bc9:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108bcc:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108bce:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108bd3:	05 00 52 00 00       	add    $0x5200,%eax
80108bd8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108bdb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108be2:	eb 19                	jmp    80108bfd <i8254_init_recv+0x12c>
    mta[i] = 0;
80108be4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108be7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108bf1:	01 d0                	add    %edx,%eax
80108bf3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108bf9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108bfd:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108c01:	7e e1                	jle    80108be4 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108c03:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c08:	05 d0 00 00 00       	add    $0xd0,%eax
80108c0d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c10:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108c13:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108c19:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c1e:	05 c8 00 00 00       	add    $0xc8,%eax
80108c23:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c26:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108c29:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108c2f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c34:	05 28 28 00 00       	add    $0x2828,%eax
80108c39:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108c3c:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108c3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108c45:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c4a:	05 00 01 00 00       	add    $0x100,%eax
80108c4f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108c52:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c55:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108c5b:	e8 32 a0 ff ff       	call   80102c92 <kalloc>
80108c60:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108c63:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c68:	05 00 28 00 00       	add    $0x2800,%eax
80108c6d:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108c70:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c75:	05 04 28 00 00       	add    $0x2804,%eax
80108c7a:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108c7d:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c82:	05 08 28 00 00       	add    $0x2808,%eax
80108c87:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c8a:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c8f:	05 10 28 00 00       	add    $0x2810,%eax
80108c94:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c97:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c9c:	05 18 28 00 00       	add    $0x2818,%eax
80108ca1:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108ca4:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ca7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108cad:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108cb0:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108cb2:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108cb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108cbb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108cbe:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108cc4:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108cc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108ccd:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108cd0:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108cd6:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108cd9:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108cdc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ce3:	eb 73                	jmp    80108d58 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ce8:	c1 e0 04             	shl    $0x4,%eax
80108ceb:	89 c2                	mov    %eax,%edx
80108ced:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cf0:	01 d0                	add    %edx,%eax
80108cf2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cfc:	c1 e0 04             	shl    $0x4,%eax
80108cff:	89 c2                	mov    %eax,%edx
80108d01:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d04:	01 d0                	add    %edx,%eax
80108d06:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d0f:	c1 e0 04             	shl    $0x4,%eax
80108d12:	89 c2                	mov    %eax,%edx
80108d14:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d17:	01 d0                	add    %edx,%eax
80108d19:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108d1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d22:	c1 e0 04             	shl    $0x4,%eax
80108d25:	89 c2                	mov    %eax,%edx
80108d27:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d2a:	01 d0                	add    %edx,%eax
80108d2c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108d30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d33:	c1 e0 04             	shl    $0x4,%eax
80108d36:	89 c2                	mov    %eax,%edx
80108d38:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d3b:	01 d0                	add    %edx,%eax
80108d3d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108d41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d44:	c1 e0 04             	shl    $0x4,%eax
80108d47:	89 c2                	mov    %eax,%edx
80108d49:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d4c:	01 d0                	add    %edx,%eax
80108d4e:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d54:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108d58:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108d5f:	7e 84                	jle    80108ce5 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d61:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108d68:	eb 57                	jmp    80108dc1 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108d6a:	e8 23 9f ff ff       	call   80102c92 <kalloc>
80108d6f:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108d72:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108d76:	75 12                	jne    80108d8a <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108d78:	83 ec 0c             	sub    $0xc,%esp
80108d7b:	68 b8 c4 10 80       	push   $0x8010c4b8
80108d80:	e8 6f 76 ff ff       	call   801003f4 <cprintf>
80108d85:	83 c4 10             	add    $0x10,%esp
      break;
80108d88:	eb 3d                	jmp    80108dc7 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108d8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d8d:	c1 e0 04             	shl    $0x4,%eax
80108d90:	89 c2                	mov    %eax,%edx
80108d92:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d95:	01 d0                	add    %edx,%eax
80108d97:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d9a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108da0:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108da2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108da5:	83 c0 01             	add    $0x1,%eax
80108da8:	c1 e0 04             	shl    $0x4,%eax
80108dab:	89 c2                	mov    %eax,%edx
80108dad:	8b 45 98             	mov    -0x68(%ebp),%eax
80108db0:	01 d0                	add    %edx,%eax
80108db2:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108db5:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108dbb:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108dbd:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108dc1:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108dc5:	7e a3                	jle    80108d6a <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108dc7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108dca:	8b 00                	mov    (%eax),%eax
80108dcc:	83 c8 02             	or     $0x2,%eax
80108dcf:	89 c2                	mov    %eax,%edx
80108dd1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108dd4:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108dd6:	83 ec 0c             	sub    $0xc,%esp
80108dd9:	68 d8 c4 10 80       	push   $0x8010c4d8
80108dde:	e8 11 76 ff ff       	call   801003f4 <cprintf>
80108de3:	83 c4 10             	add    $0x10,%esp
}
80108de6:	90                   	nop
80108de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108dea:	5b                   	pop    %ebx
80108deb:	5e                   	pop    %esi
80108dec:	5f                   	pop    %edi
80108ded:	5d                   	pop    %ebp
80108dee:	c3                   	ret    

80108def <i8254_init_send>:

void i8254_init_send(){
80108def:	55                   	push   %ebp
80108df0:	89 e5                	mov    %esp,%ebp
80108df2:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108df5:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108dfa:	05 28 38 00 00       	add    $0x3828,%eax
80108dff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e05:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108e0b:	e8 82 9e ff ff       	call   80102c92 <kalloc>
80108e10:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e13:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e18:	05 00 38 00 00       	add    $0x3800,%eax
80108e1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108e20:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e25:	05 04 38 00 00       	add    $0x3804,%eax
80108e2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108e2d:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e32:	05 08 38 00 00       	add    $0x3808,%eax
80108e37:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108e3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e3d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e46:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108e51:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e54:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e5a:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e5f:	05 10 38 00 00       	add    $0x3810,%eax
80108e64:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e67:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e6c:	05 18 38 00 00       	add    $0x3818,%eax
80108e71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108e74:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108e7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108e86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e89:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e93:	e9 82 00 00 00       	jmp    80108f1a <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9b:	c1 e0 04             	shl    $0x4,%eax
80108e9e:	89 c2                	mov    %eax,%edx
80108ea0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ea3:	01 d0                	add    %edx,%eax
80108ea5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaf:	c1 e0 04             	shl    $0x4,%eax
80108eb2:	89 c2                	mov    %eax,%edx
80108eb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eb7:	01 d0                	add    %edx,%eax
80108eb9:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec2:	c1 e0 04             	shl    $0x4,%eax
80108ec5:	89 c2                	mov    %eax,%edx
80108ec7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eca:	01 d0                	add    %edx,%eax
80108ecc:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed3:	c1 e0 04             	shl    $0x4,%eax
80108ed6:	89 c2                	mov    %eax,%edx
80108ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108edb:	01 d0                	add    %edx,%eax
80108edd:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee4:	c1 e0 04             	shl    $0x4,%eax
80108ee7:	89 c2                	mov    %eax,%edx
80108ee9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eec:	01 d0                	add    %edx,%eax
80108eee:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef5:	c1 e0 04             	shl    $0x4,%eax
80108ef8:	89 c2                	mov    %eax,%edx
80108efa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108efd:	01 d0                	add    %edx,%eax
80108eff:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f06:	c1 e0 04             	shl    $0x4,%eax
80108f09:	89 c2                	mov    %eax,%edx
80108f0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f0e:	01 d0                	add    %edx,%eax
80108f10:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f1a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f21:	0f 8e 71 ff ff ff    	jle    80108e98 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f27:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f2e:	eb 57                	jmp    80108f87 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108f30:	e8 5d 9d ff ff       	call   80102c92 <kalloc>
80108f35:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108f38:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108f3c:	75 12                	jne    80108f50 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108f3e:	83 ec 0c             	sub    $0xc,%esp
80108f41:	68 b8 c4 10 80       	push   $0x8010c4b8
80108f46:	e8 a9 74 ff ff       	call   801003f4 <cprintf>
80108f4b:	83 c4 10             	add    $0x10,%esp
      break;
80108f4e:	eb 3d                	jmp    80108f8d <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f53:	c1 e0 04             	shl    $0x4,%eax
80108f56:	89 c2                	mov    %eax,%edx
80108f58:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f5b:	01 d0                	add    %edx,%eax
80108f5d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f60:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f66:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6b:	83 c0 01             	add    $0x1,%eax
80108f6e:	c1 e0 04             	shl    $0x4,%eax
80108f71:	89 c2                	mov    %eax,%edx
80108f73:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f76:	01 d0                	add    %edx,%eax
80108f78:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f7b:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f81:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f83:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f87:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108f8b:	7e a3                	jle    80108f30 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108f8d:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108f92:	05 00 04 00 00       	add    $0x400,%eax
80108f97:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108f9a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f9d:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108fa3:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108fa8:	05 10 04 00 00       	add    $0x410,%eax
80108fad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108fb0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108fb3:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108fb9:	83 ec 0c             	sub    $0xc,%esp
80108fbc:	68 f8 c4 10 80       	push   $0x8010c4f8
80108fc1:	e8 2e 74 ff ff       	call   801003f4 <cprintf>
80108fc6:	83 c4 10             	add    $0x10,%esp

}
80108fc9:	90                   	nop
80108fca:	c9                   	leave  
80108fcb:	c3                   	ret    

80108fcc <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108fcc:	55                   	push   %ebp
80108fcd:	89 e5                	mov    %esp,%ebp
80108fcf:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108fd2:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108fd7:	83 c0 14             	add    $0x14,%eax
80108fda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe0:	c1 e0 08             	shl    $0x8,%eax
80108fe3:	0f b7 c0             	movzwl %ax,%eax
80108fe6:	83 c8 01             	or     $0x1,%eax
80108fe9:	89 c2                	mov    %eax,%edx
80108feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fee:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108ff0:	83 ec 0c             	sub    $0xc,%esp
80108ff3:	68 18 c5 10 80       	push   $0x8010c518
80108ff8:	e8 f7 73 ff ff       	call   801003f4 <cprintf>
80108ffd:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109003:	8b 00                	mov    (%eax),%eax
80109005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900b:	83 e0 10             	and    $0x10,%eax
8010900e:	85 c0                	test   %eax,%eax
80109010:	75 02                	jne    80109014 <i8254_read_eeprom+0x48>
  while(1){
80109012:	eb dc                	jmp    80108ff0 <i8254_read_eeprom+0x24>
      break;
80109014:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109018:	8b 00                	mov    (%eax),%eax
8010901a:	c1 e8 10             	shr    $0x10,%eax
}
8010901d:	c9                   	leave  
8010901e:	c3                   	ret    

8010901f <i8254_recv>:
void i8254_recv(){
8010901f:	55                   	push   %ebp
80109020:	89 e5                	mov    %esp,%ebp
80109022:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109025:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010902a:	05 10 28 00 00       	add    $0x2810,%eax
8010902f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109032:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109037:	05 18 28 00 00       	add    $0x2818,%eax
8010903c:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010903f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109044:	05 00 28 00 00       	add    $0x2800,%eax
80109049:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010904c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904f:	8b 00                	mov    (%eax),%eax
80109051:	05 00 00 00 80       	add    $0x80000000,%eax
80109056:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905c:	8b 10                	mov    (%eax),%edx
8010905e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109061:	8b 08                	mov    (%eax),%ecx
80109063:	89 d0                	mov    %edx,%eax
80109065:	29 c8                	sub    %ecx,%eax
80109067:	25 ff 00 00 00       	and    $0xff,%eax
8010906c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010906f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109073:	7e 37                	jle    801090ac <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109075:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109078:	8b 00                	mov    (%eax),%eax
8010907a:	c1 e0 04             	shl    $0x4,%eax
8010907d:	89 c2                	mov    %eax,%edx
8010907f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109082:	01 d0                	add    %edx,%eax
80109084:	8b 00                	mov    (%eax),%eax
80109086:	05 00 00 00 80       	add    $0x80000000,%eax
8010908b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010908e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109091:	8b 00                	mov    (%eax),%eax
80109093:	83 c0 01             	add    $0x1,%eax
80109096:	0f b6 d0             	movzbl %al,%edx
80109099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909c:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010909e:	83 ec 0c             	sub    $0xc,%esp
801090a1:	ff 75 e0             	push   -0x20(%ebp)
801090a4:	e8 15 09 00 00       	call   801099be <eth_proc>
801090a9:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801090ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090af:	8b 10                	mov    (%eax),%edx
801090b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b4:	8b 00                	mov    (%eax),%eax
801090b6:	39 c2                	cmp    %eax,%edx
801090b8:	75 9f                	jne    80109059 <i8254_recv+0x3a>
      (*rdt)--;
801090ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090bd:	8b 00                	mov    (%eax),%eax
801090bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801090c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c5:	89 10                	mov    %edx,(%eax)
  while(1){
801090c7:	eb 90                	jmp    80109059 <i8254_recv+0x3a>

801090c9 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801090c9:	55                   	push   %ebp
801090ca:	89 e5                	mov    %esp,%ebp
801090cc:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801090cf:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090d4:	05 10 38 00 00       	add    $0x3810,%eax
801090d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801090dc:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090e1:	05 18 38 00 00       	add    $0x3818,%eax
801090e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801090e9:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090ee:	05 00 38 00 00       	add    $0x3800,%eax
801090f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801090f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090f9:	8b 00                	mov    (%eax),%eax
801090fb:	05 00 00 00 80       	add    $0x80000000,%eax
80109100:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109106:	8b 10                	mov    (%eax),%edx
80109108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010910b:	8b 08                	mov    (%eax),%ecx
8010910d:	89 d0                	mov    %edx,%eax
8010910f:	29 c8                	sub    %ecx,%eax
80109111:	0f b6 d0             	movzbl %al,%edx
80109114:	b8 00 01 00 00       	mov    $0x100,%eax
80109119:	29 d0                	sub    %edx,%eax
8010911b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010911e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109121:	8b 00                	mov    (%eax),%eax
80109123:	25 ff 00 00 00       	and    $0xff,%eax
80109128:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010912b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010912f:	0f 8e a8 00 00 00    	jle    801091dd <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109135:	8b 45 08             	mov    0x8(%ebp),%eax
80109138:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010913b:	89 d1                	mov    %edx,%ecx
8010913d:	c1 e1 04             	shl    $0x4,%ecx
80109140:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109143:	01 ca                	add    %ecx,%edx
80109145:	8b 12                	mov    (%edx),%edx
80109147:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010914d:	83 ec 04             	sub    $0x4,%esp
80109150:	ff 75 0c             	push   0xc(%ebp)
80109153:	50                   	push   %eax
80109154:	52                   	push   %edx
80109155:	e8 d8 be ff ff       	call   80105032 <memmove>
8010915a:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010915d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109160:	c1 e0 04             	shl    $0x4,%eax
80109163:	89 c2                	mov    %eax,%edx
80109165:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109168:	01 d0                	add    %edx,%eax
8010916a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010916d:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109171:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109174:	c1 e0 04             	shl    $0x4,%eax
80109177:	89 c2                	mov    %eax,%edx
80109179:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010917c:	01 d0                	add    %edx,%eax
8010917e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109182:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109185:	c1 e0 04             	shl    $0x4,%eax
80109188:	89 c2                	mov    %eax,%edx
8010918a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010918d:	01 d0                	add    %edx,%eax
8010918f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109193:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109196:	c1 e0 04             	shl    $0x4,%eax
80109199:	89 c2                	mov    %eax,%edx
8010919b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010919e:	01 d0                	add    %edx,%eax
801091a0:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801091a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091a7:	c1 e0 04             	shl    $0x4,%eax
801091aa:	89 c2                	mov    %eax,%edx
801091ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091af:	01 d0                	add    %edx,%eax
801091b1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801091b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091ba:	c1 e0 04             	shl    $0x4,%eax
801091bd:	89 c2                	mov    %eax,%edx
801091bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091c2:	01 d0                	add    %edx,%eax
801091c4:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801091c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091cb:	8b 00                	mov    (%eax),%eax
801091cd:	83 c0 01             	add    $0x1,%eax
801091d0:	0f b6 d0             	movzbl %al,%edx
801091d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091d6:	89 10                	mov    %edx,(%eax)
    return len;
801091d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801091db:	eb 05                	jmp    801091e2 <i8254_send+0x119>
  }else{
    return -1;
801091dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801091e2:	c9                   	leave  
801091e3:	c3                   	ret    

801091e4 <i8254_intr>:

void i8254_intr(){
801091e4:	55                   	push   %ebp
801091e5:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801091e7:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
801091ec:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801091f2:	90                   	nop
801091f3:	5d                   	pop    %ebp
801091f4:	c3                   	ret    

801091f5 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801091f5:	55                   	push   %ebp
801091f6:	89 e5                	mov    %esp,%ebp
801091f8:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801091fb:	8b 45 08             	mov    0x8(%ebp),%eax
801091fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109204:	0f b7 00             	movzwl (%eax),%eax
80109207:	66 3d 00 01          	cmp    $0x100,%ax
8010920b:	74 0a                	je     80109217 <arp_proc+0x22>
8010920d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109212:	e9 4f 01 00 00       	jmp    80109366 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010921e:	66 83 f8 08          	cmp    $0x8,%ax
80109222:	74 0a                	je     8010922e <arp_proc+0x39>
80109224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109229:	e9 38 01 00 00       	jmp    80109366 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010922e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109231:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109235:	3c 06                	cmp    $0x6,%al
80109237:	74 0a                	je     80109243 <arp_proc+0x4e>
80109239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010923e:	e9 23 01 00 00       	jmp    80109366 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109246:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010924a:	3c 04                	cmp    $0x4,%al
8010924c:	74 0a                	je     80109258 <arp_proc+0x63>
8010924e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109253:	e9 0e 01 00 00       	jmp    80109366 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925b:	83 c0 18             	add    $0x18,%eax
8010925e:	83 ec 04             	sub    $0x4,%esp
80109261:	6a 04                	push   $0x4
80109263:	50                   	push   %eax
80109264:	68 e4 f4 10 80       	push   $0x8010f4e4
80109269:	e8 6c bd ff ff       	call   80104fda <memcmp>
8010926e:	83 c4 10             	add    $0x10,%esp
80109271:	85 c0                	test   %eax,%eax
80109273:	74 27                	je     8010929c <arp_proc+0xa7>
80109275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109278:	83 c0 0e             	add    $0xe,%eax
8010927b:	83 ec 04             	sub    $0x4,%esp
8010927e:	6a 04                	push   $0x4
80109280:	50                   	push   %eax
80109281:	68 e4 f4 10 80       	push   $0x8010f4e4
80109286:	e8 4f bd ff ff       	call   80104fda <memcmp>
8010928b:	83 c4 10             	add    $0x10,%esp
8010928e:	85 c0                	test   %eax,%eax
80109290:	74 0a                	je     8010929c <arp_proc+0xa7>
80109292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109297:	e9 ca 00 00 00       	jmp    80109366 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010929c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092a3:	66 3d 00 01          	cmp    $0x100,%ax
801092a7:	75 69                	jne    80109312 <arp_proc+0x11d>
801092a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ac:	83 c0 18             	add    $0x18,%eax
801092af:	83 ec 04             	sub    $0x4,%esp
801092b2:	6a 04                	push   $0x4
801092b4:	50                   	push   %eax
801092b5:	68 e4 f4 10 80       	push   $0x8010f4e4
801092ba:	e8 1b bd ff ff       	call   80104fda <memcmp>
801092bf:	83 c4 10             	add    $0x10,%esp
801092c2:	85 c0                	test   %eax,%eax
801092c4:	75 4c                	jne    80109312 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801092c6:	e8 c7 99 ff ff       	call   80102c92 <kalloc>
801092cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801092ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801092d5:	83 ec 04             	sub    $0x4,%esp
801092d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801092db:	50                   	push   %eax
801092dc:	ff 75 f0             	push   -0x10(%ebp)
801092df:	ff 75 f4             	push   -0xc(%ebp)
801092e2:	e8 1f 04 00 00       	call   80109706 <arp_reply_pkt_create>
801092e7:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801092ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ed:	83 ec 08             	sub    $0x8,%esp
801092f0:	50                   	push   %eax
801092f1:	ff 75 f0             	push   -0x10(%ebp)
801092f4:	e8 d0 fd ff ff       	call   801090c9 <i8254_send>
801092f9:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801092fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ff:	83 ec 0c             	sub    $0xc,%esp
80109302:	50                   	push   %eax
80109303:	e8 f0 98 ff ff       	call   80102bf8 <kfree>
80109308:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010930b:	b8 02 00 00 00       	mov    $0x2,%eax
80109310:	eb 54                	jmp    80109366 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109315:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109319:	66 3d 00 02          	cmp    $0x200,%ax
8010931d:	75 42                	jne    80109361 <arp_proc+0x16c>
8010931f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109322:	83 c0 18             	add    $0x18,%eax
80109325:	83 ec 04             	sub    $0x4,%esp
80109328:	6a 04                	push   $0x4
8010932a:	50                   	push   %eax
8010932b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109330:	e8 a5 bc ff ff       	call   80104fda <memcmp>
80109335:	83 c4 10             	add    $0x10,%esp
80109338:	85 c0                	test   %eax,%eax
8010933a:	75 25                	jne    80109361 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010933c:	83 ec 0c             	sub    $0xc,%esp
8010933f:	68 1c c5 10 80       	push   $0x8010c51c
80109344:	e8 ab 70 ff ff       	call   801003f4 <cprintf>
80109349:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010934c:	83 ec 0c             	sub    $0xc,%esp
8010934f:	ff 75 f4             	push   -0xc(%ebp)
80109352:	e8 af 01 00 00       	call   80109506 <arp_table_update>
80109357:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010935a:	b8 01 00 00 00       	mov    $0x1,%eax
8010935f:	eb 05                	jmp    80109366 <arp_proc+0x171>
  }else{
    return -1;
80109361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109366:	c9                   	leave  
80109367:	c3                   	ret    

80109368 <arp_scan>:

void arp_scan(){
80109368:	55                   	push   %ebp
80109369:	89 e5                	mov    %esp,%ebp
8010936b:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010936e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109375:	eb 6f                	jmp    801093e6 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109377:	e8 16 99 ff ff       	call   80102c92 <kalloc>
8010937c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010937f:	83 ec 04             	sub    $0x4,%esp
80109382:	ff 75 f4             	push   -0xc(%ebp)
80109385:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109388:	50                   	push   %eax
80109389:	ff 75 ec             	push   -0x14(%ebp)
8010938c:	e8 62 00 00 00       	call   801093f3 <arp_broadcast>
80109391:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109394:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109397:	83 ec 08             	sub    $0x8,%esp
8010939a:	50                   	push   %eax
8010939b:	ff 75 ec             	push   -0x14(%ebp)
8010939e:	e8 26 fd ff ff       	call   801090c9 <i8254_send>
801093a3:	83 c4 10             	add    $0x10,%esp
801093a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801093a9:	eb 22                	jmp    801093cd <arp_scan+0x65>
      microdelay(1);
801093ab:	83 ec 0c             	sub    $0xc,%esp
801093ae:	6a 01                	push   $0x1
801093b0:	e8 74 9c ff ff       	call   80103029 <microdelay>
801093b5:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801093b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093bb:	83 ec 08             	sub    $0x8,%esp
801093be:	50                   	push   %eax
801093bf:	ff 75 ec             	push   -0x14(%ebp)
801093c2:	e8 02 fd ff ff       	call   801090c9 <i8254_send>
801093c7:	83 c4 10             	add    $0x10,%esp
801093ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801093cd:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801093d1:	74 d8                	je     801093ab <arp_scan+0x43>
    }
    kfree((char *)send);
801093d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093d6:	83 ec 0c             	sub    $0xc,%esp
801093d9:	50                   	push   %eax
801093da:	e8 19 98 ff ff       	call   80102bf8 <kfree>
801093df:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801093e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093e6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801093ed:	7e 88                	jle    80109377 <arp_scan+0xf>
  }
}
801093ef:	90                   	nop
801093f0:	90                   	nop
801093f1:	c9                   	leave  
801093f2:	c3                   	ret    

801093f3 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801093f3:	55                   	push   %ebp
801093f4:	89 e5                	mov    %esp,%ebp
801093f6:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801093f9:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801093fd:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109401:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109405:	8b 45 10             	mov    0x10(%ebp),%eax
80109408:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010940b:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109412:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109418:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010941f:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109425:	8b 45 0c             	mov    0xc(%ebp),%eax
80109428:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109434:	8b 45 08             	mov    0x8(%ebp),%eax
80109437:	83 c0 0e             	add    $0xe,%eax
8010943a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010943d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109440:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109447:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010944b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010944e:	83 ec 04             	sub    $0x4,%esp
80109451:	6a 06                	push   $0x6
80109453:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109456:	52                   	push   %edx
80109457:	50                   	push   %eax
80109458:	e8 d5 bb ff ff       	call   80105032 <memmove>
8010945d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109463:	83 c0 06             	add    $0x6,%eax
80109466:	83 ec 04             	sub    $0x4,%esp
80109469:	6a 06                	push   $0x6
8010946b:	68 c0 9c 11 80       	push   $0x80119cc0
80109470:	50                   	push   %eax
80109471:	e8 bc bb ff ff       	call   80105032 <memmove>
80109476:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010947c:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109484:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010948a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010948d:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109494:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010949b:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801094a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a4:	8d 50 12             	lea    0x12(%eax),%edx
801094a7:	83 ec 04             	sub    $0x4,%esp
801094aa:	6a 06                	push   $0x6
801094ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801094af:	50                   	push   %eax
801094b0:	52                   	push   %edx
801094b1:	e8 7c bb ff ff       	call   80105032 <memmove>
801094b6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801094b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094bc:	8d 50 18             	lea    0x18(%eax),%edx
801094bf:	83 ec 04             	sub    $0x4,%esp
801094c2:	6a 04                	push   $0x4
801094c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801094c7:	50                   	push   %eax
801094c8:	52                   	push   %edx
801094c9:	e8 64 bb ff ff       	call   80105032 <memmove>
801094ce:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801094d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094d4:	83 c0 08             	add    $0x8,%eax
801094d7:	83 ec 04             	sub    $0x4,%esp
801094da:	6a 06                	push   $0x6
801094dc:	68 c0 9c 11 80       	push   $0x80119cc0
801094e1:	50                   	push   %eax
801094e2:	e8 4b bb ff ff       	call   80105032 <memmove>
801094e7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801094ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ed:	83 c0 0e             	add    $0xe,%eax
801094f0:	83 ec 04             	sub    $0x4,%esp
801094f3:	6a 04                	push   $0x4
801094f5:	68 e4 f4 10 80       	push   $0x8010f4e4
801094fa:	50                   	push   %eax
801094fb:	e8 32 bb ff ff       	call   80105032 <memmove>
80109500:	83 c4 10             	add    $0x10,%esp
}
80109503:	90                   	nop
80109504:	c9                   	leave  
80109505:	c3                   	ret    

80109506 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109506:	55                   	push   %ebp
80109507:	89 e5                	mov    %esp,%ebp
80109509:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010950c:	8b 45 08             	mov    0x8(%ebp),%eax
8010950f:	83 c0 0e             	add    $0xe,%eax
80109512:	83 ec 0c             	sub    $0xc,%esp
80109515:	50                   	push   %eax
80109516:	e8 bc 00 00 00       	call   801095d7 <arp_table_search>
8010951b:	83 c4 10             	add    $0x10,%esp
8010951e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109521:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109525:	78 2d                	js     80109554 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109527:	8b 45 08             	mov    0x8(%ebp),%eax
8010952a:	8d 48 08             	lea    0x8(%eax),%ecx
8010952d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109530:	89 d0                	mov    %edx,%eax
80109532:	c1 e0 02             	shl    $0x2,%eax
80109535:	01 d0                	add    %edx,%eax
80109537:	01 c0                	add    %eax,%eax
80109539:	01 d0                	add    %edx,%eax
8010953b:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
80109540:	83 c0 04             	add    $0x4,%eax
80109543:	83 ec 04             	sub    $0x4,%esp
80109546:	6a 06                	push   $0x6
80109548:	51                   	push   %ecx
80109549:	50                   	push   %eax
8010954a:	e8 e3 ba ff ff       	call   80105032 <memmove>
8010954f:	83 c4 10             	add    $0x10,%esp
80109552:	eb 70                	jmp    801095c4 <arp_table_update+0xbe>
  }else{
    index += 1;
80109554:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109558:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010955b:	8b 45 08             	mov    0x8(%ebp),%eax
8010955e:	8d 48 08             	lea    0x8(%eax),%ecx
80109561:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109564:	89 d0                	mov    %edx,%eax
80109566:	c1 e0 02             	shl    $0x2,%eax
80109569:	01 d0                	add    %edx,%eax
8010956b:	01 c0                	add    %eax,%eax
8010956d:	01 d0                	add    %edx,%eax
8010956f:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
80109574:	83 c0 04             	add    $0x4,%eax
80109577:	83 ec 04             	sub    $0x4,%esp
8010957a:	6a 06                	push   $0x6
8010957c:	51                   	push   %ecx
8010957d:	50                   	push   %eax
8010957e:	e8 af ba ff ff       	call   80105032 <memmove>
80109583:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109586:	8b 45 08             	mov    0x8(%ebp),%eax
80109589:	8d 48 0e             	lea    0xe(%eax),%ecx
8010958c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010958f:	89 d0                	mov    %edx,%eax
80109591:	c1 e0 02             	shl    $0x2,%eax
80109594:	01 d0                	add    %edx,%eax
80109596:	01 c0                	add    %eax,%eax
80109598:	01 d0                	add    %edx,%eax
8010959a:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010959f:	83 ec 04             	sub    $0x4,%esp
801095a2:	6a 04                	push   $0x4
801095a4:	51                   	push   %ecx
801095a5:	50                   	push   %eax
801095a6:	e8 87 ba ff ff       	call   80105032 <memmove>
801095ab:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801095ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095b1:	89 d0                	mov    %edx,%eax
801095b3:	c1 e0 02             	shl    $0x2,%eax
801095b6:	01 d0                	add    %edx,%eax
801095b8:	01 c0                	add    %eax,%eax
801095ba:	01 d0                	add    %edx,%eax
801095bc:	05 ea 9c 11 80       	add    $0x80119cea,%eax
801095c1:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801095c4:	83 ec 0c             	sub    $0xc,%esp
801095c7:	68 e0 9c 11 80       	push   $0x80119ce0
801095cc:	e8 83 00 00 00       	call   80109654 <print_arp_table>
801095d1:	83 c4 10             	add    $0x10,%esp
}
801095d4:	90                   	nop
801095d5:	c9                   	leave  
801095d6:	c3                   	ret    

801095d7 <arp_table_search>:

int arp_table_search(uchar *ip){
801095d7:	55                   	push   %ebp
801095d8:	89 e5                	mov    %esp,%ebp
801095da:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801095dd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801095eb:	eb 59                	jmp    80109646 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801095ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095f0:	89 d0                	mov    %edx,%eax
801095f2:	c1 e0 02             	shl    $0x2,%eax
801095f5:	01 d0                	add    %edx,%eax
801095f7:	01 c0                	add    %eax,%eax
801095f9:	01 d0                	add    %edx,%eax
801095fb:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
80109600:	83 ec 04             	sub    $0x4,%esp
80109603:	6a 04                	push   $0x4
80109605:	ff 75 08             	push   0x8(%ebp)
80109608:	50                   	push   %eax
80109609:	e8 cc b9 ff ff       	call   80104fda <memcmp>
8010960e:	83 c4 10             	add    $0x10,%esp
80109611:	85 c0                	test   %eax,%eax
80109613:	75 05                	jne    8010961a <arp_table_search+0x43>
      return i;
80109615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109618:	eb 38                	jmp    80109652 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010961a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010961d:	89 d0                	mov    %edx,%eax
8010961f:	c1 e0 02             	shl    $0x2,%eax
80109622:	01 d0                	add    %edx,%eax
80109624:	01 c0                	add    %eax,%eax
80109626:	01 d0                	add    %edx,%eax
80109628:	05 ea 9c 11 80       	add    $0x80119cea,%eax
8010962d:	0f b6 00             	movzbl (%eax),%eax
80109630:	84 c0                	test   %al,%al
80109632:	75 0e                	jne    80109642 <arp_table_search+0x6b>
80109634:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109638:	75 08                	jne    80109642 <arp_table_search+0x6b>
      empty = -i;
8010963a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963d:	f7 d8                	neg    %eax
8010963f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109642:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109646:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010964a:	7e a1                	jle    801095ed <arp_table_search+0x16>
    }
  }
  return empty-1;
8010964c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964f:	83 e8 01             	sub    $0x1,%eax
}
80109652:	c9                   	leave  
80109653:	c3                   	ret    

80109654 <print_arp_table>:

void print_arp_table(){
80109654:	55                   	push   %ebp
80109655:	89 e5                	mov    %esp,%ebp
80109657:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010965a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109661:	e9 92 00 00 00       	jmp    801096f8 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109669:	89 d0                	mov    %edx,%eax
8010966b:	c1 e0 02             	shl    $0x2,%eax
8010966e:	01 d0                	add    %edx,%eax
80109670:	01 c0                	add    %eax,%eax
80109672:	01 d0                	add    %edx,%eax
80109674:	05 ea 9c 11 80       	add    $0x80119cea,%eax
80109679:	0f b6 00             	movzbl (%eax),%eax
8010967c:	84 c0                	test   %al,%al
8010967e:	74 74                	je     801096f4 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109680:	83 ec 08             	sub    $0x8,%esp
80109683:	ff 75 f4             	push   -0xc(%ebp)
80109686:	68 2f c5 10 80       	push   $0x8010c52f
8010968b:	e8 64 6d ff ff       	call   801003f4 <cprintf>
80109690:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109696:	89 d0                	mov    %edx,%eax
80109698:	c1 e0 02             	shl    $0x2,%eax
8010969b:	01 d0                	add    %edx,%eax
8010969d:	01 c0                	add    %eax,%eax
8010969f:	01 d0                	add    %edx,%eax
801096a1:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801096a6:	83 ec 0c             	sub    $0xc,%esp
801096a9:	50                   	push   %eax
801096aa:	e8 54 02 00 00       	call   80109903 <print_ipv4>
801096af:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801096b2:	83 ec 0c             	sub    $0xc,%esp
801096b5:	68 3e c5 10 80       	push   $0x8010c53e
801096ba:	e8 35 6d ff ff       	call   801003f4 <cprintf>
801096bf:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801096c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096c5:	89 d0                	mov    %edx,%eax
801096c7:	c1 e0 02             	shl    $0x2,%eax
801096ca:	01 d0                	add    %edx,%eax
801096cc:	01 c0                	add    %eax,%eax
801096ce:	01 d0                	add    %edx,%eax
801096d0:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801096d5:	83 c0 04             	add    $0x4,%eax
801096d8:	83 ec 0c             	sub    $0xc,%esp
801096db:	50                   	push   %eax
801096dc:	e8 70 02 00 00       	call   80109951 <print_mac>
801096e1:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801096e4:	83 ec 0c             	sub    $0xc,%esp
801096e7:	68 40 c5 10 80       	push   $0x8010c540
801096ec:	e8 03 6d ff ff       	call   801003f4 <cprintf>
801096f1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096f8:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801096fc:	0f 8e 64 ff ff ff    	jle    80109666 <print_arp_table+0x12>
    }
  }
}
80109702:	90                   	nop
80109703:	90                   	nop
80109704:	c9                   	leave  
80109705:	c3                   	ret    

80109706 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109706:	55                   	push   %ebp
80109707:	89 e5                	mov    %esp,%ebp
80109709:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010970c:	8b 45 10             	mov    0x10(%ebp),%eax
8010970f:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109715:	8b 45 0c             	mov    0xc(%ebp),%eax
80109718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010971b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010971e:	83 c0 0e             	add    $0xe,%eax
80109721:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109727:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010972b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010972e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109732:	8b 45 08             	mov    0x8(%ebp),%eax
80109735:	8d 50 08             	lea    0x8(%eax),%edx
80109738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010973b:	83 ec 04             	sub    $0x4,%esp
8010973e:	6a 06                	push   $0x6
80109740:	52                   	push   %edx
80109741:	50                   	push   %eax
80109742:	e8 eb b8 ff ff       	call   80105032 <memmove>
80109747:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010974a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974d:	83 c0 06             	add    $0x6,%eax
80109750:	83 ec 04             	sub    $0x4,%esp
80109753:	6a 06                	push   $0x6
80109755:	68 c0 9c 11 80       	push   $0x80119cc0
8010975a:	50                   	push   %eax
8010975b:	e8 d2 b8 ff ff       	call   80105032 <memmove>
80109760:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109766:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010976b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010976e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109777:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010977b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010977e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109785:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010978b:	8b 45 08             	mov    0x8(%ebp),%eax
8010978e:	8d 50 08             	lea    0x8(%eax),%edx
80109791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109794:	83 c0 12             	add    $0x12,%eax
80109797:	83 ec 04             	sub    $0x4,%esp
8010979a:	6a 06                	push   $0x6
8010979c:	52                   	push   %edx
8010979d:	50                   	push   %eax
8010979e:	e8 8f b8 ff ff       	call   80105032 <memmove>
801097a3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801097a6:	8b 45 08             	mov    0x8(%ebp),%eax
801097a9:	8d 50 0e             	lea    0xe(%eax),%edx
801097ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097af:	83 c0 18             	add    $0x18,%eax
801097b2:	83 ec 04             	sub    $0x4,%esp
801097b5:	6a 04                	push   $0x4
801097b7:	52                   	push   %edx
801097b8:	50                   	push   %eax
801097b9:	e8 74 b8 ff ff       	call   80105032 <memmove>
801097be:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801097c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097c4:	83 c0 08             	add    $0x8,%eax
801097c7:	83 ec 04             	sub    $0x4,%esp
801097ca:	6a 06                	push   $0x6
801097cc:	68 c0 9c 11 80       	push   $0x80119cc0
801097d1:	50                   	push   %eax
801097d2:	e8 5b b8 ff ff       	call   80105032 <memmove>
801097d7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801097da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097dd:	83 c0 0e             	add    $0xe,%eax
801097e0:	83 ec 04             	sub    $0x4,%esp
801097e3:	6a 04                	push   $0x4
801097e5:	68 e4 f4 10 80       	push   $0x8010f4e4
801097ea:	50                   	push   %eax
801097eb:	e8 42 b8 ff ff       	call   80105032 <memmove>
801097f0:	83 c4 10             	add    $0x10,%esp
}
801097f3:	90                   	nop
801097f4:	c9                   	leave  
801097f5:	c3                   	ret    

801097f6 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801097f6:	55                   	push   %ebp
801097f7:	89 e5                	mov    %esp,%ebp
801097f9:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801097fc:	83 ec 0c             	sub    $0xc,%esp
801097ff:	68 42 c5 10 80       	push   $0x8010c542
80109804:	e8 eb 6b ff ff       	call   801003f4 <cprintf>
80109809:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010980c:	8b 45 08             	mov    0x8(%ebp),%eax
8010980f:	83 c0 0e             	add    $0xe,%eax
80109812:	83 ec 0c             	sub    $0xc,%esp
80109815:	50                   	push   %eax
80109816:	e8 e8 00 00 00       	call   80109903 <print_ipv4>
8010981b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010981e:	83 ec 0c             	sub    $0xc,%esp
80109821:	68 40 c5 10 80       	push   $0x8010c540
80109826:	e8 c9 6b ff ff       	call   801003f4 <cprintf>
8010982b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010982e:	8b 45 08             	mov    0x8(%ebp),%eax
80109831:	83 c0 08             	add    $0x8,%eax
80109834:	83 ec 0c             	sub    $0xc,%esp
80109837:	50                   	push   %eax
80109838:	e8 14 01 00 00       	call   80109951 <print_mac>
8010983d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109840:	83 ec 0c             	sub    $0xc,%esp
80109843:	68 40 c5 10 80       	push   $0x8010c540
80109848:	e8 a7 6b ff ff       	call   801003f4 <cprintf>
8010984d:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109850:	83 ec 0c             	sub    $0xc,%esp
80109853:	68 59 c5 10 80       	push   $0x8010c559
80109858:	e8 97 6b ff ff       	call   801003f4 <cprintf>
8010985d:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109860:	8b 45 08             	mov    0x8(%ebp),%eax
80109863:	83 c0 18             	add    $0x18,%eax
80109866:	83 ec 0c             	sub    $0xc,%esp
80109869:	50                   	push   %eax
8010986a:	e8 94 00 00 00       	call   80109903 <print_ipv4>
8010986f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109872:	83 ec 0c             	sub    $0xc,%esp
80109875:	68 40 c5 10 80       	push   $0x8010c540
8010987a:	e8 75 6b ff ff       	call   801003f4 <cprintf>
8010987f:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109882:	8b 45 08             	mov    0x8(%ebp),%eax
80109885:	83 c0 12             	add    $0x12,%eax
80109888:	83 ec 0c             	sub    $0xc,%esp
8010988b:	50                   	push   %eax
8010988c:	e8 c0 00 00 00       	call   80109951 <print_mac>
80109891:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109894:	83 ec 0c             	sub    $0xc,%esp
80109897:	68 40 c5 10 80       	push   $0x8010c540
8010989c:	e8 53 6b ff ff       	call   801003f4 <cprintf>
801098a1:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801098a4:	83 ec 0c             	sub    $0xc,%esp
801098a7:	68 70 c5 10 80       	push   $0x8010c570
801098ac:	e8 43 6b ff ff       	call   801003f4 <cprintf>
801098b1:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801098b4:	8b 45 08             	mov    0x8(%ebp),%eax
801098b7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098bb:	66 3d 00 01          	cmp    $0x100,%ax
801098bf:	75 12                	jne    801098d3 <print_arp_info+0xdd>
801098c1:	83 ec 0c             	sub    $0xc,%esp
801098c4:	68 7c c5 10 80       	push   $0x8010c57c
801098c9:	e8 26 6b ff ff       	call   801003f4 <cprintf>
801098ce:	83 c4 10             	add    $0x10,%esp
801098d1:	eb 1d                	jmp    801098f0 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801098d3:	8b 45 08             	mov    0x8(%ebp),%eax
801098d6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098da:	66 3d 00 02          	cmp    $0x200,%ax
801098de:	75 10                	jne    801098f0 <print_arp_info+0xfa>
    cprintf("Reply\n");
801098e0:	83 ec 0c             	sub    $0xc,%esp
801098e3:	68 85 c5 10 80       	push   $0x8010c585
801098e8:	e8 07 6b ff ff       	call   801003f4 <cprintf>
801098ed:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801098f0:	83 ec 0c             	sub    $0xc,%esp
801098f3:	68 40 c5 10 80       	push   $0x8010c540
801098f8:	e8 f7 6a ff ff       	call   801003f4 <cprintf>
801098fd:	83 c4 10             	add    $0x10,%esp
}
80109900:	90                   	nop
80109901:	c9                   	leave  
80109902:	c3                   	ret    

80109903 <print_ipv4>:

void print_ipv4(uchar *ip){
80109903:	55                   	push   %ebp
80109904:	89 e5                	mov    %esp,%ebp
80109906:	53                   	push   %ebx
80109907:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010990a:	8b 45 08             	mov    0x8(%ebp),%eax
8010990d:	83 c0 03             	add    $0x3,%eax
80109910:	0f b6 00             	movzbl (%eax),%eax
80109913:	0f b6 d8             	movzbl %al,%ebx
80109916:	8b 45 08             	mov    0x8(%ebp),%eax
80109919:	83 c0 02             	add    $0x2,%eax
8010991c:	0f b6 00             	movzbl (%eax),%eax
8010991f:	0f b6 c8             	movzbl %al,%ecx
80109922:	8b 45 08             	mov    0x8(%ebp),%eax
80109925:	83 c0 01             	add    $0x1,%eax
80109928:	0f b6 00             	movzbl (%eax),%eax
8010992b:	0f b6 d0             	movzbl %al,%edx
8010992e:	8b 45 08             	mov    0x8(%ebp),%eax
80109931:	0f b6 00             	movzbl (%eax),%eax
80109934:	0f b6 c0             	movzbl %al,%eax
80109937:	83 ec 0c             	sub    $0xc,%esp
8010993a:	53                   	push   %ebx
8010993b:	51                   	push   %ecx
8010993c:	52                   	push   %edx
8010993d:	50                   	push   %eax
8010993e:	68 8c c5 10 80       	push   $0x8010c58c
80109943:	e8 ac 6a ff ff       	call   801003f4 <cprintf>
80109948:	83 c4 20             	add    $0x20,%esp
}
8010994b:	90                   	nop
8010994c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010994f:	c9                   	leave  
80109950:	c3                   	ret    

80109951 <print_mac>:

void print_mac(uchar *mac){
80109951:	55                   	push   %ebp
80109952:	89 e5                	mov    %esp,%ebp
80109954:	57                   	push   %edi
80109955:	56                   	push   %esi
80109956:	53                   	push   %ebx
80109957:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010995a:	8b 45 08             	mov    0x8(%ebp),%eax
8010995d:	83 c0 05             	add    $0x5,%eax
80109960:	0f b6 00             	movzbl (%eax),%eax
80109963:	0f b6 f8             	movzbl %al,%edi
80109966:	8b 45 08             	mov    0x8(%ebp),%eax
80109969:	83 c0 04             	add    $0x4,%eax
8010996c:	0f b6 00             	movzbl (%eax),%eax
8010996f:	0f b6 f0             	movzbl %al,%esi
80109972:	8b 45 08             	mov    0x8(%ebp),%eax
80109975:	83 c0 03             	add    $0x3,%eax
80109978:	0f b6 00             	movzbl (%eax),%eax
8010997b:	0f b6 d8             	movzbl %al,%ebx
8010997e:	8b 45 08             	mov    0x8(%ebp),%eax
80109981:	83 c0 02             	add    $0x2,%eax
80109984:	0f b6 00             	movzbl (%eax),%eax
80109987:	0f b6 c8             	movzbl %al,%ecx
8010998a:	8b 45 08             	mov    0x8(%ebp),%eax
8010998d:	83 c0 01             	add    $0x1,%eax
80109990:	0f b6 00             	movzbl (%eax),%eax
80109993:	0f b6 d0             	movzbl %al,%edx
80109996:	8b 45 08             	mov    0x8(%ebp),%eax
80109999:	0f b6 00             	movzbl (%eax),%eax
8010999c:	0f b6 c0             	movzbl %al,%eax
8010999f:	83 ec 04             	sub    $0x4,%esp
801099a2:	57                   	push   %edi
801099a3:	56                   	push   %esi
801099a4:	53                   	push   %ebx
801099a5:	51                   	push   %ecx
801099a6:	52                   	push   %edx
801099a7:	50                   	push   %eax
801099a8:	68 a4 c5 10 80       	push   $0x8010c5a4
801099ad:	e8 42 6a ff ff       	call   801003f4 <cprintf>
801099b2:	83 c4 20             	add    $0x20,%esp
}
801099b5:	90                   	nop
801099b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801099b9:	5b                   	pop    %ebx
801099ba:	5e                   	pop    %esi
801099bb:	5f                   	pop    %edi
801099bc:	5d                   	pop    %ebp
801099bd:	c3                   	ret    

801099be <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801099be:	55                   	push   %ebp
801099bf:	89 e5                	mov    %esp,%ebp
801099c1:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801099c4:	8b 45 08             	mov    0x8(%ebp),%eax
801099c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801099ca:	8b 45 08             	mov    0x8(%ebp),%eax
801099cd:	83 c0 0e             	add    $0xe,%eax
801099d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801099d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099da:	3c 08                	cmp    $0x8,%al
801099dc:	75 1b                	jne    801099f9 <eth_proc+0x3b>
801099de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099e5:	3c 06                	cmp    $0x6,%al
801099e7:	75 10                	jne    801099f9 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801099e9:	83 ec 0c             	sub    $0xc,%esp
801099ec:	ff 75 f0             	push   -0x10(%ebp)
801099ef:	e8 01 f8 ff ff       	call   801091f5 <arp_proc>
801099f4:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801099f7:	eb 24                	jmp    80109a1d <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801099f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fc:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a00:	3c 08                	cmp    $0x8,%al
80109a02:	75 19                	jne    80109a1d <eth_proc+0x5f>
80109a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a07:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a0b:	84 c0                	test   %al,%al
80109a0d:	75 0e                	jne    80109a1d <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109a0f:	83 ec 0c             	sub    $0xc,%esp
80109a12:	ff 75 08             	push   0x8(%ebp)
80109a15:	e8 a3 00 00 00       	call   80109abd <ipv4_proc>
80109a1a:	83 c4 10             	add    $0x10,%esp
}
80109a1d:	90                   	nop
80109a1e:	c9                   	leave  
80109a1f:	c3                   	ret    

80109a20 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109a20:	55                   	push   %ebp
80109a21:	89 e5                	mov    %esp,%ebp
80109a23:	83 ec 04             	sub    $0x4,%esp
80109a26:	8b 45 08             	mov    0x8(%ebp),%eax
80109a29:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a2d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a31:	c1 e0 08             	shl    $0x8,%eax
80109a34:	89 c2                	mov    %eax,%edx
80109a36:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a3a:	66 c1 e8 08          	shr    $0x8,%ax
80109a3e:	01 d0                	add    %edx,%eax
}
80109a40:	c9                   	leave  
80109a41:	c3                   	ret    

80109a42 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109a42:	55                   	push   %ebp
80109a43:	89 e5                	mov    %esp,%ebp
80109a45:	83 ec 04             	sub    $0x4,%esp
80109a48:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a4f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a53:	c1 e0 08             	shl    $0x8,%eax
80109a56:	89 c2                	mov    %eax,%edx
80109a58:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a5c:	66 c1 e8 08          	shr    $0x8,%ax
80109a60:	01 d0                	add    %edx,%eax
}
80109a62:	c9                   	leave  
80109a63:	c3                   	ret    

80109a64 <H2N_uint>:

uint H2N_uint(uint value){
80109a64:	55                   	push   %ebp
80109a65:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a67:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6a:	c1 e0 18             	shl    $0x18,%eax
80109a6d:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a72:	89 c2                	mov    %eax,%edx
80109a74:	8b 45 08             	mov    0x8(%ebp),%eax
80109a77:	c1 e0 08             	shl    $0x8,%eax
80109a7a:	25 00 f0 00 00       	and    $0xf000,%eax
80109a7f:	09 c2                	or     %eax,%edx
80109a81:	8b 45 08             	mov    0x8(%ebp),%eax
80109a84:	c1 e8 08             	shr    $0x8,%eax
80109a87:	83 e0 0f             	and    $0xf,%eax
80109a8a:	01 d0                	add    %edx,%eax
}
80109a8c:	5d                   	pop    %ebp
80109a8d:	c3                   	ret    

80109a8e <N2H_uint>:

uint N2H_uint(uint value){
80109a8e:	55                   	push   %ebp
80109a8f:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a91:	8b 45 08             	mov    0x8(%ebp),%eax
80109a94:	c1 e0 18             	shl    $0x18,%eax
80109a97:	89 c2                	mov    %eax,%edx
80109a99:	8b 45 08             	mov    0x8(%ebp),%eax
80109a9c:	c1 e0 08             	shl    $0x8,%eax
80109a9f:	25 00 00 ff 00       	and    $0xff0000,%eax
80109aa4:	01 c2                	add    %eax,%edx
80109aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa9:	c1 e8 08             	shr    $0x8,%eax
80109aac:	25 00 ff 00 00       	and    $0xff00,%eax
80109ab1:	01 c2                	add    %eax,%edx
80109ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab6:	c1 e8 18             	shr    $0x18,%eax
80109ab9:	01 d0                	add    %edx,%eax
}
80109abb:	5d                   	pop    %ebp
80109abc:	c3                   	ret    

80109abd <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109abd:	55                   	push   %ebp
80109abe:	89 e5                	mov    %esp,%ebp
80109ac0:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac6:	83 c0 0e             	add    $0xe,%eax
80109ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ad3:	0f b7 d0             	movzwl %ax,%edx
80109ad6:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109adb:	39 c2                	cmp    %eax,%edx
80109add:	74 60                	je     80109b3f <ipv4_proc+0x82>
80109adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae2:	83 c0 0c             	add    $0xc,%eax
80109ae5:	83 ec 04             	sub    $0x4,%esp
80109ae8:	6a 04                	push   $0x4
80109aea:	50                   	push   %eax
80109aeb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109af0:	e8 e5 b4 ff ff       	call   80104fda <memcmp>
80109af5:	83 c4 10             	add    $0x10,%esp
80109af8:	85 c0                	test   %eax,%eax
80109afa:	74 43                	je     80109b3f <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aff:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b03:	0f b7 c0             	movzwl %ax,%eax
80109b06:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b0e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b12:	3c 01                	cmp    $0x1,%al
80109b14:	75 10                	jne    80109b26 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109b16:	83 ec 0c             	sub    $0xc,%esp
80109b19:	ff 75 08             	push   0x8(%ebp)
80109b1c:	e8 a3 00 00 00       	call   80109bc4 <icmp_proc>
80109b21:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109b24:	eb 19                	jmp    80109b3f <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b29:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b2d:	3c 06                	cmp    $0x6,%al
80109b2f:	75 0e                	jne    80109b3f <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109b31:	83 ec 0c             	sub    $0xc,%esp
80109b34:	ff 75 08             	push   0x8(%ebp)
80109b37:	e8 b3 03 00 00       	call   80109eef <tcp_proc>
80109b3c:	83 c4 10             	add    $0x10,%esp
}
80109b3f:	90                   	nop
80109b40:	c9                   	leave  
80109b41:	c3                   	ret    

80109b42 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109b42:	55                   	push   %ebp
80109b43:	89 e5                	mov    %esp,%ebp
80109b45:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109b48:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b51:	0f b6 00             	movzbl (%eax),%eax
80109b54:	83 e0 0f             	and    $0xf,%eax
80109b57:	01 c0                	add    %eax,%eax
80109b59:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b5c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b63:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b6a:	eb 48                	jmp    80109bb4 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b6f:	01 c0                	add    %eax,%eax
80109b71:	89 c2                	mov    %eax,%edx
80109b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b76:	01 d0                	add    %edx,%eax
80109b78:	0f b6 00             	movzbl (%eax),%eax
80109b7b:	0f b6 c0             	movzbl %al,%eax
80109b7e:	c1 e0 08             	shl    $0x8,%eax
80109b81:	89 c2                	mov    %eax,%edx
80109b83:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b86:	01 c0                	add    %eax,%eax
80109b88:	8d 48 01             	lea    0x1(%eax),%ecx
80109b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b8e:	01 c8                	add    %ecx,%eax
80109b90:	0f b6 00             	movzbl (%eax),%eax
80109b93:	0f b6 c0             	movzbl %al,%eax
80109b96:	01 d0                	add    %edx,%eax
80109b98:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b9b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ba2:	76 0c                	jbe    80109bb0 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ba4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ba7:	0f b7 c0             	movzwl %ax,%eax
80109baa:	83 c0 01             	add    $0x1,%eax
80109bad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109bb0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109bb4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109bb8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109bbb:	7c af                	jl     80109b6c <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109bbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bc0:	f7 d0                	not    %eax
}
80109bc2:	c9                   	leave  
80109bc3:	c3                   	ret    

80109bc4 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109bc4:	55                   	push   %ebp
80109bc5:	89 e5                	mov    %esp,%ebp
80109bc7:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109bca:	8b 45 08             	mov    0x8(%ebp),%eax
80109bcd:	83 c0 0e             	add    $0xe,%eax
80109bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd6:	0f b6 00             	movzbl (%eax),%eax
80109bd9:	0f b6 c0             	movzbl %al,%eax
80109bdc:	83 e0 0f             	and    $0xf,%eax
80109bdf:	c1 e0 02             	shl    $0x2,%eax
80109be2:	89 c2                	mov    %eax,%edx
80109be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be7:	01 d0                	add    %edx,%eax
80109be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bef:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109bf3:	84 c0                	test   %al,%al
80109bf5:	75 4f                	jne    80109c46 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bfa:	0f b6 00             	movzbl (%eax),%eax
80109bfd:	3c 08                	cmp    $0x8,%al
80109bff:	75 45                	jne    80109c46 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109c01:	e8 8c 90 ff ff       	call   80102c92 <kalloc>
80109c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109c09:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109c10:	83 ec 04             	sub    $0x4,%esp
80109c13:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c16:	50                   	push   %eax
80109c17:	ff 75 ec             	push   -0x14(%ebp)
80109c1a:	ff 75 08             	push   0x8(%ebp)
80109c1d:	e8 78 00 00 00       	call   80109c9a <icmp_reply_pkt_create>
80109c22:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109c25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c28:	83 ec 08             	sub    $0x8,%esp
80109c2b:	50                   	push   %eax
80109c2c:	ff 75 ec             	push   -0x14(%ebp)
80109c2f:	e8 95 f4 ff ff       	call   801090c9 <i8254_send>
80109c34:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c3a:	83 ec 0c             	sub    $0xc,%esp
80109c3d:	50                   	push   %eax
80109c3e:	e8 b5 8f ff ff       	call   80102bf8 <kfree>
80109c43:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109c46:	90                   	nop
80109c47:	c9                   	leave  
80109c48:	c3                   	ret    

80109c49 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c49:	55                   	push   %ebp
80109c4a:	89 e5                	mov    %esp,%ebp
80109c4c:	53                   	push   %ebx
80109c4d:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c50:	8b 45 08             	mov    0x8(%ebp),%eax
80109c53:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c57:	0f b7 c0             	movzwl %ax,%eax
80109c5a:	83 ec 0c             	sub    $0xc,%esp
80109c5d:	50                   	push   %eax
80109c5e:	e8 bd fd ff ff       	call   80109a20 <N2H_ushort>
80109c63:	83 c4 10             	add    $0x10,%esp
80109c66:	0f b7 d8             	movzwl %ax,%ebx
80109c69:	8b 45 08             	mov    0x8(%ebp),%eax
80109c6c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c70:	0f b7 c0             	movzwl %ax,%eax
80109c73:	83 ec 0c             	sub    $0xc,%esp
80109c76:	50                   	push   %eax
80109c77:	e8 a4 fd ff ff       	call   80109a20 <N2H_ushort>
80109c7c:	83 c4 10             	add    $0x10,%esp
80109c7f:	0f b7 c0             	movzwl %ax,%eax
80109c82:	83 ec 04             	sub    $0x4,%esp
80109c85:	53                   	push   %ebx
80109c86:	50                   	push   %eax
80109c87:	68 c3 c5 10 80       	push   $0x8010c5c3
80109c8c:	e8 63 67 ff ff       	call   801003f4 <cprintf>
80109c91:	83 c4 10             	add    $0x10,%esp
}
80109c94:	90                   	nop
80109c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c98:	c9                   	leave  
80109c99:	c3                   	ret    

80109c9a <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c9a:	55                   	push   %ebp
80109c9b:	89 e5                	mov    %esp,%ebp
80109c9d:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca9:	83 c0 0e             	add    $0xe,%eax
80109cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cb2:	0f b6 00             	movzbl (%eax),%eax
80109cb5:	0f b6 c0             	movzbl %al,%eax
80109cb8:	83 e0 0f             	and    $0xf,%eax
80109cbb:	c1 e0 02             	shl    $0x2,%eax
80109cbe:	89 c2                	mov    %eax,%edx
80109cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cc3:	01 d0                	add    %edx,%eax
80109cc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ccb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109cce:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cd1:	83 c0 0e             	add    $0xe,%eax
80109cd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cda:	83 c0 14             	add    $0x14,%eax
80109cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109ce0:	8b 45 10             	mov    0x10(%ebp),%eax
80109ce3:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cec:	8d 50 06             	lea    0x6(%eax),%edx
80109cef:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cf2:	83 ec 04             	sub    $0x4,%esp
80109cf5:	6a 06                	push   $0x6
80109cf7:	52                   	push   %edx
80109cf8:	50                   	push   %eax
80109cf9:	e8 34 b3 ff ff       	call   80105032 <memmove>
80109cfe:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d04:	83 c0 06             	add    $0x6,%eax
80109d07:	83 ec 04             	sub    $0x4,%esp
80109d0a:	6a 06                	push   $0x6
80109d0c:	68 c0 9c 11 80       	push   $0x80119cc0
80109d11:	50                   	push   %eax
80109d12:	e8 1b b3 ff ff       	call   80105032 <memmove>
80109d17:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d1d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d24:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d2b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d31:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109d35:	83 ec 0c             	sub    $0xc,%esp
80109d38:	6a 54                	push   $0x54
80109d3a:	e8 03 fd ff ff       	call   80109a42 <H2N_ushort>
80109d3f:	83 c4 10             	add    $0x10,%esp
80109d42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d45:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d49:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
80109d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d53:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d57:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
80109d5e:	83 c0 01             	add    $0x1,%eax
80109d61:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d67:	83 ec 0c             	sub    $0xc,%esp
80109d6a:	68 00 40 00 00       	push   $0x4000
80109d6f:	e8 ce fc ff ff       	call   80109a42 <H2N_ushort>
80109d74:	83 c4 10             	add    $0x10,%esp
80109d77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d7a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d81:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d88:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d8f:	83 c0 0c             	add    $0xc,%eax
80109d92:	83 ec 04             	sub    $0x4,%esp
80109d95:	6a 04                	push   $0x4
80109d97:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d9c:	50                   	push   %eax
80109d9d:	e8 90 b2 ff ff       	call   80105032 <memmove>
80109da2:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109da8:	8d 50 0c             	lea    0xc(%eax),%edx
80109dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dae:	83 c0 10             	add    $0x10,%eax
80109db1:	83 ec 04             	sub    $0x4,%esp
80109db4:	6a 04                	push   $0x4
80109db6:	52                   	push   %edx
80109db7:	50                   	push   %eax
80109db8:	e8 75 b2 ff ff       	call   80105032 <memmove>
80109dbd:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dc3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dcc:	83 ec 0c             	sub    $0xc,%esp
80109dcf:	50                   	push   %eax
80109dd0:	e8 6d fd ff ff       	call   80109b42 <ipv4_chksum>
80109dd5:	83 c4 10             	add    $0x10,%esp
80109dd8:	0f b7 c0             	movzwl %ax,%eax
80109ddb:	83 ec 0c             	sub    $0xc,%esp
80109dde:	50                   	push   %eax
80109ddf:	e8 5e fc ff ff       	call   80109a42 <H2N_ushort>
80109de4:	83 c4 10             	add    $0x10,%esp
80109de7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dea:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df1:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df7:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dfe:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e05:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e0c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e13:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109e17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e1a:	8d 50 08             	lea    0x8(%eax),%edx
80109e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e20:	83 c0 08             	add    $0x8,%eax
80109e23:	83 ec 04             	sub    $0x4,%esp
80109e26:	6a 08                	push   $0x8
80109e28:	52                   	push   %edx
80109e29:	50                   	push   %eax
80109e2a:	e8 03 b2 ff ff       	call   80105032 <memmove>
80109e2f:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e35:	8d 50 10             	lea    0x10(%eax),%edx
80109e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e3b:	83 c0 10             	add    $0x10,%eax
80109e3e:	83 ec 04             	sub    $0x4,%esp
80109e41:	6a 30                	push   $0x30
80109e43:	52                   	push   %edx
80109e44:	50                   	push   %eax
80109e45:	e8 e8 b1 ff ff       	call   80105032 <memmove>
80109e4a:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e50:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e59:	83 ec 0c             	sub    $0xc,%esp
80109e5c:	50                   	push   %eax
80109e5d:	e8 1c 00 00 00       	call   80109e7e <icmp_chksum>
80109e62:	83 c4 10             	add    $0x10,%esp
80109e65:	0f b7 c0             	movzwl %ax,%eax
80109e68:	83 ec 0c             	sub    $0xc,%esp
80109e6b:	50                   	push   %eax
80109e6c:	e8 d1 fb ff ff       	call   80109a42 <H2N_ushort>
80109e71:	83 c4 10             	add    $0x10,%esp
80109e74:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e77:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e7b:	90                   	nop
80109e7c:	c9                   	leave  
80109e7d:	c3                   	ret    

80109e7e <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e7e:	55                   	push   %ebp
80109e7f:	89 e5                	mov    %esp,%ebp
80109e81:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e84:	8b 45 08             	mov    0x8(%ebp),%eax
80109e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e8a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e91:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e98:	eb 48                	jmp    80109ee2 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e9d:	01 c0                	add    %eax,%eax
80109e9f:	89 c2                	mov    %eax,%edx
80109ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ea4:	01 d0                	add    %edx,%eax
80109ea6:	0f b6 00             	movzbl (%eax),%eax
80109ea9:	0f b6 c0             	movzbl %al,%eax
80109eac:	c1 e0 08             	shl    $0x8,%eax
80109eaf:	89 c2                	mov    %eax,%edx
80109eb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109eb4:	01 c0                	add    %eax,%eax
80109eb6:	8d 48 01             	lea    0x1(%eax),%ecx
80109eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ebc:	01 c8                	add    %ecx,%eax
80109ebe:	0f b6 00             	movzbl (%eax),%eax
80109ec1:	0f b6 c0             	movzbl %al,%eax
80109ec4:	01 d0                	add    %edx,%eax
80109ec6:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ec9:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ed0:	76 0c                	jbe    80109ede <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ed2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ed5:	0f b7 c0             	movzwl %ax,%eax
80109ed8:	83 c0 01             	add    $0x1,%eax
80109edb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ede:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ee2:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ee6:	7e b2                	jle    80109e9a <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109ee8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109eeb:	f7 d0                	not    %eax
}
80109eed:	c9                   	leave  
80109eee:	c3                   	ret    

80109eef <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109eef:	55                   	push   %ebp
80109ef0:	89 e5                	mov    %esp,%ebp
80109ef2:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef8:	83 c0 0e             	add    $0xe,%eax
80109efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f01:	0f b6 00             	movzbl (%eax),%eax
80109f04:	0f b6 c0             	movzbl %al,%eax
80109f07:	83 e0 0f             	and    $0xf,%eax
80109f0a:	c1 e0 02             	shl    $0x2,%eax
80109f0d:	89 c2                	mov    %eax,%edx
80109f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f12:	01 d0                	add    %edx,%eax
80109f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f1a:	83 c0 14             	add    $0x14,%eax
80109f1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109f20:	e8 6d 8d ff ff       	call   80102c92 <kalloc>
80109f25:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109f28:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f32:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f36:	0f b6 c0             	movzbl %al,%eax
80109f39:	83 e0 02             	and    $0x2,%eax
80109f3c:	85 c0                	test   %eax,%eax
80109f3e:	74 3d                	je     80109f7d <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f40:	83 ec 0c             	sub    $0xc,%esp
80109f43:	6a 00                	push   $0x0
80109f45:	6a 12                	push   $0x12
80109f47:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f4a:	50                   	push   %eax
80109f4b:	ff 75 e8             	push   -0x18(%ebp)
80109f4e:	ff 75 08             	push   0x8(%ebp)
80109f51:	e8 a2 01 00 00       	call   8010a0f8 <tcp_pkt_create>
80109f56:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f59:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f5c:	83 ec 08             	sub    $0x8,%esp
80109f5f:	50                   	push   %eax
80109f60:	ff 75 e8             	push   -0x18(%ebp)
80109f63:	e8 61 f1 ff ff       	call   801090c9 <i8254_send>
80109f68:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f6b:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
80109f70:	83 c0 01             	add    $0x1,%eax
80109f73:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
80109f78:	e9 69 01 00 00       	jmp    8010a0e6 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f80:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f84:	3c 18                	cmp    $0x18,%al
80109f86:	0f 85 10 01 00 00    	jne    8010a09c <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109f8c:	83 ec 04             	sub    $0x4,%esp
80109f8f:	6a 03                	push   $0x3
80109f91:	68 de c5 10 80       	push   $0x8010c5de
80109f96:	ff 75 ec             	push   -0x14(%ebp)
80109f99:	e8 3c b0 ff ff       	call   80104fda <memcmp>
80109f9e:	83 c4 10             	add    $0x10,%esp
80109fa1:	85 c0                	test   %eax,%eax
80109fa3:	74 74                	je     8010a019 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109fa5:	83 ec 0c             	sub    $0xc,%esp
80109fa8:	68 e2 c5 10 80       	push   $0x8010c5e2
80109fad:	e8 42 64 ff ff       	call   801003f4 <cprintf>
80109fb2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109fb5:	83 ec 0c             	sub    $0xc,%esp
80109fb8:	6a 00                	push   $0x0
80109fba:	6a 10                	push   $0x10
80109fbc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fbf:	50                   	push   %eax
80109fc0:	ff 75 e8             	push   -0x18(%ebp)
80109fc3:	ff 75 08             	push   0x8(%ebp)
80109fc6:	e8 2d 01 00 00       	call   8010a0f8 <tcp_pkt_create>
80109fcb:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fce:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fd1:	83 ec 08             	sub    $0x8,%esp
80109fd4:	50                   	push   %eax
80109fd5:	ff 75 e8             	push   -0x18(%ebp)
80109fd8:	e8 ec f0 ff ff       	call   801090c9 <i8254_send>
80109fdd:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe3:	83 c0 36             	add    $0x36,%eax
80109fe6:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fe9:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109fec:	50                   	push   %eax
80109fed:	ff 75 e0             	push   -0x20(%ebp)
80109ff0:	6a 00                	push   $0x0
80109ff2:	6a 00                	push   $0x0
80109ff4:	e8 5a 04 00 00       	call   8010a453 <http_proc>
80109ff9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ffc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109fff:	83 ec 0c             	sub    $0xc,%esp
8010a002:	50                   	push   %eax
8010a003:	6a 18                	push   $0x18
8010a005:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a008:	50                   	push   %eax
8010a009:	ff 75 e8             	push   -0x18(%ebp)
8010a00c:	ff 75 08             	push   0x8(%ebp)
8010a00f:	e8 e4 00 00 00       	call   8010a0f8 <tcp_pkt_create>
8010a014:	83 c4 20             	add    $0x20,%esp
8010a017:	eb 62                	jmp    8010a07b <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a019:	83 ec 0c             	sub    $0xc,%esp
8010a01c:	6a 00                	push   $0x0
8010a01e:	6a 10                	push   $0x10
8010a020:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a023:	50                   	push   %eax
8010a024:	ff 75 e8             	push   -0x18(%ebp)
8010a027:	ff 75 08             	push   0x8(%ebp)
8010a02a:	e8 c9 00 00 00       	call   8010a0f8 <tcp_pkt_create>
8010a02f:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a032:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a035:	83 ec 08             	sub    $0x8,%esp
8010a038:	50                   	push   %eax
8010a039:	ff 75 e8             	push   -0x18(%ebp)
8010a03c:	e8 88 f0 ff ff       	call   801090c9 <i8254_send>
8010a041:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a044:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a047:	83 c0 36             	add    $0x36,%eax
8010a04a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a04d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a050:	50                   	push   %eax
8010a051:	ff 75 e4             	push   -0x1c(%ebp)
8010a054:	6a 00                	push   $0x0
8010a056:	6a 00                	push   $0x0
8010a058:	e8 f6 03 00 00       	call   8010a453 <http_proc>
8010a05d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a060:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a063:	83 ec 0c             	sub    $0xc,%esp
8010a066:	50                   	push   %eax
8010a067:	6a 18                	push   $0x18
8010a069:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a06c:	50                   	push   %eax
8010a06d:	ff 75 e8             	push   -0x18(%ebp)
8010a070:	ff 75 08             	push   0x8(%ebp)
8010a073:	e8 80 00 00 00       	call   8010a0f8 <tcp_pkt_create>
8010a078:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a07b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a07e:	83 ec 08             	sub    $0x8,%esp
8010a081:	50                   	push   %eax
8010a082:	ff 75 e8             	push   -0x18(%ebp)
8010a085:	e8 3f f0 ff ff       	call   801090c9 <i8254_send>
8010a08a:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a08d:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a092:	83 c0 01             	add    $0x1,%eax
8010a095:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
8010a09a:	eb 4a                	jmp    8010a0e6 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a09c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0a3:	3c 10                	cmp    $0x10,%al
8010a0a5:	75 3f                	jne    8010a0e6 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a0a7:	a1 a8 9f 11 80       	mov    0x80119fa8,%eax
8010a0ac:	83 f8 01             	cmp    $0x1,%eax
8010a0af:	75 35                	jne    8010a0e6 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a0b1:	83 ec 0c             	sub    $0xc,%esp
8010a0b4:	6a 00                	push   $0x0
8010a0b6:	6a 01                	push   $0x1
8010a0b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0bb:	50                   	push   %eax
8010a0bc:	ff 75 e8             	push   -0x18(%ebp)
8010a0bf:	ff 75 08             	push   0x8(%ebp)
8010a0c2:	e8 31 00 00 00       	call   8010a0f8 <tcp_pkt_create>
8010a0c7:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0cd:	83 ec 08             	sub    $0x8,%esp
8010a0d0:	50                   	push   %eax
8010a0d1:	ff 75 e8             	push   -0x18(%ebp)
8010a0d4:	e8 f0 ef ff ff       	call   801090c9 <i8254_send>
8010a0d9:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0dc:	c7 05 a8 9f 11 80 00 	movl   $0x0,0x80119fa8
8010a0e3:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e9:	83 ec 0c             	sub    $0xc,%esp
8010a0ec:	50                   	push   %eax
8010a0ed:	e8 06 8b ff ff       	call   80102bf8 <kfree>
8010a0f2:	83 c4 10             	add    $0x10,%esp
}
8010a0f5:	90                   	nop
8010a0f6:	c9                   	leave  
8010a0f7:	c3                   	ret    

8010a0f8 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a0f8:	55                   	push   %ebp
8010a0f9:	89 e5                	mov    %esp,%ebp
8010a0fb:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a0fe:	8b 45 08             	mov    0x8(%ebp),%eax
8010a101:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a104:	8b 45 08             	mov    0x8(%ebp),%eax
8010a107:	83 c0 0e             	add    $0xe,%eax
8010a10a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a10d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a110:	0f b6 00             	movzbl (%eax),%eax
8010a113:	0f b6 c0             	movzbl %al,%eax
8010a116:	83 e0 0f             	and    $0xf,%eax
8010a119:	c1 e0 02             	shl    $0x2,%eax
8010a11c:	89 c2                	mov    %eax,%edx
8010a11e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a121:	01 d0                	add    %edx,%eax
8010a123:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a126:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a129:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a12c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a12f:	83 c0 0e             	add    $0xe,%eax
8010a132:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a138:	83 c0 14             	add    $0x14,%eax
8010a13b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a13e:	8b 45 18             	mov    0x18(%ebp),%eax
8010a141:	8d 50 36             	lea    0x36(%eax),%edx
8010a144:	8b 45 10             	mov    0x10(%ebp),%eax
8010a147:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14c:	8d 50 06             	lea    0x6(%eax),%edx
8010a14f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a152:	83 ec 04             	sub    $0x4,%esp
8010a155:	6a 06                	push   $0x6
8010a157:	52                   	push   %edx
8010a158:	50                   	push   %eax
8010a159:	e8 d4 ae ff ff       	call   80105032 <memmove>
8010a15e:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a161:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a164:	83 c0 06             	add    $0x6,%eax
8010a167:	83 ec 04             	sub    $0x4,%esp
8010a16a:	6a 06                	push   $0x6
8010a16c:	68 c0 9c 11 80       	push   $0x80119cc0
8010a171:	50                   	push   %eax
8010a172:	e8 bb ae ff ff       	call   80105032 <memmove>
8010a177:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a17a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a17d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a181:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a184:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a18e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a191:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a195:	8b 45 18             	mov    0x18(%ebp),%eax
8010a198:	83 c0 28             	add    $0x28,%eax
8010a19b:	0f b7 c0             	movzwl %ax,%eax
8010a19e:	83 ec 0c             	sub    $0xc,%esp
8010a1a1:	50                   	push   %eax
8010a1a2:	e8 9b f8 ff ff       	call   80109a42 <H2N_ushort>
8010a1a7:	83 c4 10             	add    $0x10,%esp
8010a1aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1ad:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a1b1:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
8010a1b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1bb:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a1bf:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
8010a1c6:	83 c0 01             	add    $0x1,%eax
8010a1c9:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a1cf:	83 ec 0c             	sub    $0xc,%esp
8010a1d2:	6a 00                	push   $0x0
8010a1d4:	e8 69 f8 ff ff       	call   80109a42 <H2N_ushort>
8010a1d9:	83 c4 10             	add    $0x10,%esp
8010a1dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1df:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e6:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a1ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1ed:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f4:	83 c0 0c             	add    $0xc,%eax
8010a1f7:	83 ec 04             	sub    $0x4,%esp
8010a1fa:	6a 04                	push   $0x4
8010a1fc:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a201:	50                   	push   %eax
8010a202:	e8 2b ae ff ff       	call   80105032 <memmove>
8010a207:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a20a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a20d:	8d 50 0c             	lea    0xc(%eax),%edx
8010a210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a213:	83 c0 10             	add    $0x10,%eax
8010a216:	83 ec 04             	sub    $0x4,%esp
8010a219:	6a 04                	push   $0x4
8010a21b:	52                   	push   %edx
8010a21c:	50                   	push   %eax
8010a21d:	e8 10 ae ff ff       	call   80105032 <memmove>
8010a222:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a225:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a228:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a22e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a231:	83 ec 0c             	sub    $0xc,%esp
8010a234:	50                   	push   %eax
8010a235:	e8 08 f9 ff ff       	call   80109b42 <ipv4_chksum>
8010a23a:	83 c4 10             	add    $0x10,%esp
8010a23d:	0f b7 c0             	movzwl %ax,%eax
8010a240:	83 ec 0c             	sub    $0xc,%esp
8010a243:	50                   	push   %eax
8010a244:	e8 f9 f7 ff ff       	call   80109a42 <H2N_ushort>
8010a249:	83 c4 10             	add    $0x10,%esp
8010a24c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a24f:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a253:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a256:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a25a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a25d:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a260:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a263:	0f b7 10             	movzwl (%eax),%edx
8010a266:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a269:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a26d:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a272:	83 ec 0c             	sub    $0xc,%esp
8010a275:	50                   	push   %eax
8010a276:	e8 e9 f7 ff ff       	call   80109a64 <H2N_uint>
8010a27b:	83 c4 10             	add    $0x10,%esp
8010a27e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a281:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a284:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a287:	8b 40 04             	mov    0x4(%eax),%eax
8010a28a:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a290:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a293:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a296:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a299:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a29d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a2a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a7:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a2ab:	8b 45 14             	mov    0x14(%ebp),%eax
8010a2ae:	89 c2                	mov    %eax,%edx
8010a2b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b3:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a2b6:	83 ec 0c             	sub    $0xc,%esp
8010a2b9:	68 90 38 00 00       	push   $0x3890
8010a2be:	e8 7f f7 ff ff       	call   80109a42 <H2N_ushort>
8010a2c3:	83 c4 10             	add    $0x10,%esp
8010a2c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2c9:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a2cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d0:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e2:	83 ec 0c             	sub    $0xc,%esp
8010a2e5:	50                   	push   %eax
8010a2e6:	e8 1f 00 00 00       	call   8010a30a <tcp_chksum>
8010a2eb:	83 c4 10             	add    $0x10,%esp
8010a2ee:	83 c0 08             	add    $0x8,%eax
8010a2f1:	0f b7 c0             	movzwl %ax,%eax
8010a2f4:	83 ec 0c             	sub    $0xc,%esp
8010a2f7:	50                   	push   %eax
8010a2f8:	e8 45 f7 ff ff       	call   80109a42 <H2N_ushort>
8010a2fd:	83 c4 10             	add    $0x10,%esp
8010a300:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a303:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a307:	90                   	nop
8010a308:	c9                   	leave  
8010a309:	c3                   	ret    

8010a30a <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a30a:	55                   	push   %ebp
8010a30b:	89 e5                	mov    %esp,%ebp
8010a30d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a310:	8b 45 08             	mov    0x8(%ebp),%eax
8010a313:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a316:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a319:	83 c0 14             	add    $0x14,%eax
8010a31c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a31f:	83 ec 04             	sub    $0x4,%esp
8010a322:	6a 04                	push   $0x4
8010a324:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a329:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a32c:	50                   	push   %eax
8010a32d:	e8 00 ad ff ff       	call   80105032 <memmove>
8010a332:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a335:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a338:	83 c0 0c             	add    $0xc,%eax
8010a33b:	83 ec 04             	sub    $0x4,%esp
8010a33e:	6a 04                	push   $0x4
8010a340:	50                   	push   %eax
8010a341:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a344:	83 c0 04             	add    $0x4,%eax
8010a347:	50                   	push   %eax
8010a348:	e8 e5 ac ff ff       	call   80105032 <memmove>
8010a34d:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a350:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a354:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a358:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a35b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a35f:	0f b7 c0             	movzwl %ax,%eax
8010a362:	83 ec 0c             	sub    $0xc,%esp
8010a365:	50                   	push   %eax
8010a366:	e8 b5 f6 ff ff       	call   80109a20 <N2H_ushort>
8010a36b:	83 c4 10             	add    $0x10,%esp
8010a36e:	83 e8 14             	sub    $0x14,%eax
8010a371:	0f b7 c0             	movzwl %ax,%eax
8010a374:	83 ec 0c             	sub    $0xc,%esp
8010a377:	50                   	push   %eax
8010a378:	e8 c5 f6 ff ff       	call   80109a42 <H2N_ushort>
8010a37d:	83 c4 10             	add    $0x10,%esp
8010a380:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a38b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a38e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a391:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a398:	eb 33                	jmp    8010a3cd <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a39a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a39d:	01 c0                	add    %eax,%eax
8010a39f:	89 c2                	mov    %eax,%edx
8010a3a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3a4:	01 d0                	add    %edx,%eax
8010a3a6:	0f b6 00             	movzbl (%eax),%eax
8010a3a9:	0f b6 c0             	movzbl %al,%eax
8010a3ac:	c1 e0 08             	shl    $0x8,%eax
8010a3af:	89 c2                	mov    %eax,%edx
8010a3b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3b4:	01 c0                	add    %eax,%eax
8010a3b6:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bc:	01 c8                	add    %ecx,%eax
8010a3be:	0f b6 00             	movzbl (%eax),%eax
8010a3c1:	0f b6 c0             	movzbl %al,%eax
8010a3c4:	01 d0                	add    %edx,%eax
8010a3c6:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a3c9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a3cd:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3d1:	7e c7                	jle    8010a39a <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a3d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3e0:	eb 33                	jmp    8010a415 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3e5:	01 c0                	add    %eax,%eax
8010a3e7:	89 c2                	mov    %eax,%edx
8010a3e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ec:	01 d0                	add    %edx,%eax
8010a3ee:	0f b6 00             	movzbl (%eax),%eax
8010a3f1:	0f b6 c0             	movzbl %al,%eax
8010a3f4:	c1 e0 08             	shl    $0x8,%eax
8010a3f7:	89 c2                	mov    %eax,%edx
8010a3f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3fc:	01 c0                	add    %eax,%eax
8010a3fe:	8d 48 01             	lea    0x1(%eax),%ecx
8010a401:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a404:	01 c8                	add    %ecx,%eax
8010a406:	0f b6 00             	movzbl (%eax),%eax
8010a409:	0f b6 c0             	movzbl %al,%eax
8010a40c:	01 d0                	add    %edx,%eax
8010a40e:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a411:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a415:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a419:	0f b7 c0             	movzwl %ax,%eax
8010a41c:	83 ec 0c             	sub    $0xc,%esp
8010a41f:	50                   	push   %eax
8010a420:	e8 fb f5 ff ff       	call   80109a20 <N2H_ushort>
8010a425:	83 c4 10             	add    $0x10,%esp
8010a428:	66 d1 e8             	shr    %ax
8010a42b:	0f b7 c0             	movzwl %ax,%eax
8010a42e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a431:	7c af                	jl     8010a3e2 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a433:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a436:	c1 e8 10             	shr    $0x10,%eax
8010a439:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a43f:	f7 d0                	not    %eax
}
8010a441:	c9                   	leave  
8010a442:	c3                   	ret    

8010a443 <tcp_fin>:

void tcp_fin(){
8010a443:	55                   	push   %ebp
8010a444:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a446:	c7 05 a8 9f 11 80 01 	movl   $0x1,0x80119fa8
8010a44d:	00 00 00 
}
8010a450:	90                   	nop
8010a451:	5d                   	pop    %ebp
8010a452:	c3                   	ret    

8010a453 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a453:	55                   	push   %ebp
8010a454:	89 e5                	mov    %esp,%ebp
8010a456:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a459:	8b 45 10             	mov    0x10(%ebp),%eax
8010a45c:	83 ec 04             	sub    $0x4,%esp
8010a45f:	6a 00                	push   $0x0
8010a461:	68 eb c5 10 80       	push   $0x8010c5eb
8010a466:	50                   	push   %eax
8010a467:	e8 65 00 00 00       	call   8010a4d1 <http_strcpy>
8010a46c:	83 c4 10             	add    $0x10,%esp
8010a46f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a472:	8b 45 10             	mov    0x10(%ebp),%eax
8010a475:	83 ec 04             	sub    $0x4,%esp
8010a478:	ff 75 f4             	push   -0xc(%ebp)
8010a47b:	68 fe c5 10 80       	push   $0x8010c5fe
8010a480:	50                   	push   %eax
8010a481:	e8 4b 00 00 00       	call   8010a4d1 <http_strcpy>
8010a486:	83 c4 10             	add    $0x10,%esp
8010a489:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a48c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a48f:	83 ec 04             	sub    $0x4,%esp
8010a492:	ff 75 f4             	push   -0xc(%ebp)
8010a495:	68 19 c6 10 80       	push   $0x8010c619
8010a49a:	50                   	push   %eax
8010a49b:	e8 31 00 00 00       	call   8010a4d1 <http_strcpy>
8010a4a0:	83 c4 10             	add    $0x10,%esp
8010a4a3:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a4a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4a9:	83 e0 01             	and    $0x1,%eax
8010a4ac:	85 c0                	test   %eax,%eax
8010a4ae:	74 11                	je     8010a4c1 <http_proc+0x6e>
    char *payload = (char *)send;
8010a4b0:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a4b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4bc:	01 d0                	add    %edx,%eax
8010a4be:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a4c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4c4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a4c7:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a4c9:	e8 75 ff ff ff       	call   8010a443 <tcp_fin>
}
8010a4ce:	90                   	nop
8010a4cf:	c9                   	leave  
8010a4d0:	c3                   	ret    

8010a4d1 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4d1:	55                   	push   %ebp
8010a4d2:	89 e5                	mov    %esp,%ebp
8010a4d4:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a4de:	eb 20                	jmp    8010a500 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a4e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4e3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4e6:	01 d0                	add    %edx,%eax
8010a4e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a4eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4ee:	01 ca                	add    %ecx,%edx
8010a4f0:	89 d1                	mov    %edx,%ecx
8010a4f2:	8b 55 08             	mov    0x8(%ebp),%edx
8010a4f5:	01 ca                	add    %ecx,%edx
8010a4f7:	0f b6 00             	movzbl (%eax),%eax
8010a4fa:	88 02                	mov    %al,(%edx)
    i++;
8010a4fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a500:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a503:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a506:	01 d0                	add    %edx,%eax
8010a508:	0f b6 00             	movzbl (%eax),%eax
8010a50b:	84 c0                	test   %al,%al
8010a50d:	75 d1                	jne    8010a4e0 <http_strcpy+0xf>
  }
  return i;
8010a50f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a512:	c9                   	leave  
8010a513:	c3                   	ret    
