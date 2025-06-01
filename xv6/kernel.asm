
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
8010005f:	ba 3f 38 10 80       	mov    $0x8010383f,%edx
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
8010006f:	68 60 a6 10 80       	push   $0x8010a660
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 87 4c 00 00       	call   80104d05 <initlock>
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
801000bd:	68 67 a6 10 80       	push   $0x8010a667
801000c2:	50                   	push   %eax
801000c3:	e8 e0 4a 00 00       	call   80104ba8 <initsleeplock>
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
80100101:	e8 21 4c 00 00       	call   80104d27 <acquire>
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
80100140:	e8 50 4c 00 00       	call   80104d95 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 8d 4a 00 00       	call   80104be4 <acquiresleep>
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
801001c1:	e8 cf 4b 00 00       	call   80104d95 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 0c 4a 00 00       	call   80104be4 <acquiresleep>
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
801001f5:	68 6e a6 10 80       	push   $0x8010a66e
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
8010022d:	e8 ef 26 00 00       	call   80102921 <iderw>
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
8010024a:	e8 47 4a 00 00       	call   80104c96 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 7f a6 10 80       	push   $0x8010a67f
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
80100278:	e8 a4 26 00 00       	call   80102921 <iderw>
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
80100293:	e8 fe 49 00 00       	call   80104c96 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 86 a6 10 80       	push   $0x8010a686
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 8d 49 00 00       	call   80104c48 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 5c 4a 00 00       	call   80104d27 <acquire>
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
80100336:	e8 5a 4a 00 00       	call   80104d95 <release>
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
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 12 49 00 00       	call   80104d27 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 8d a6 10 80       	push   $0x8010a68d
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
80100510:	c7 45 ec 96 a6 10 80 	movl   $0x8010a696,-0x14(%ebp)
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
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 f2 47 00 00       	call   80104d95 <release>
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
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 11 2a 00 00       	call   80102fd4 <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 9d a6 10 80       	push   $0x8010a69d
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
801005e6:	68 b1 a6 10 80       	push   $0x8010a6b1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 e4 47 00 00       	call   80104de7 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 b3 a6 10 80       	push   $0x8010a6b3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
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
801006a0:	e8 33 7f 00 00       	call   801085d8 <graphic_scroll_up>
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
801006f3:	e8 e0 7e 00 00       	call   801085d8 <graphic_scroll_up>
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
80100757:	e8 e7 7e 00 00       	call   80108643 <font_render>
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
80100775:	a1 ec 49 11 80       	mov    0x801149ec,%eax
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
80100793:	e8 9c 62 00 00       	call   80106a34 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 8f 62 00 00       	call   80106a34 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 82 62 00 00       	call   80106a34 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 72 62 00 00       	call   80106a34 <uartputc>
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
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 37 45 00 00       	call   80104d27 <acquire>
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
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
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
801008c2:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008c7:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
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
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
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
8010091b:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100920:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 56 3f 00 00       	call   8010489a <wakeup>
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
8010095d:	68 00 4a 11 80       	push   $0x80114a00
80100962:	e8 2e 44 00 00       	call   80104d95 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 e0 3f 00 00       	call   80104955 <procdump>
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
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 88 43 00 00       	call   80104d27 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 5e 35 00 00       	call   80103f0a <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 d5 43 00 00       	call   80104d95 <release>
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
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 c6 3d 00 00       	call   801047b3 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009f6:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
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
80100a2b:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 49 11 80       	mov    %eax,0x801149e0
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
80100a61:	68 00 4a 11 80       	push   $0x80114a00
80100a66:	e8 2a 43 00 00       	call   80104d95 <release>
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
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
80100aa2:	e8 80 42 00 00       	call   80104d27 <acquire>
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
80100adf:	68 00 4a 11 80       	push   $0x80114a00
80100ae4:	e8 ac 42 00 00       	call   80104d95 <release>
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
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 b7 a6 10 80       	push   $0x8010a6b7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 e4 41 00 00       	call   80104d05 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 bf a6 10 80 	movl   $0x8010a6bf,-0xc(%ebp)
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
80100b64:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 8e 1f 00 00       	call   80102b08 <ioapicenable>
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
80100b89:	e8 7c 33 00 00       	call   80103f0a <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 80 29 00 00       	call   80103516 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 72 19 00 00       	call   80102513 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 f0 29 00 00       	call   801035a2 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 d8 a6 10 80       	push   $0x8010a6d8
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
80100c11:	e8 1a 6e 00 00       	call   80107a30 <setupkvm>
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
80100cb7:	e8 6d 71 00 00       	call   80107e29 <allocuvm>
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
80100cfd:	e8 5a 70 00 00       	call   80107d5c <loaduvm>
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
80100d3e:	e8 5f 28 00 00       	call   801035a2 <end_op>
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
80100d63:	e8 c1 70 00 00       	call   80107e29 <allocuvm>
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
80100db1:	e8 35 44 00 00       	call   801051eb <strlen>
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
80100dde:	e8 08 44 00 00       	call   801051eb <strlen>
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
80100e04:	e8 3c 74 00 00       	call   80108245 <copyout>
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
80100ea0:	e8 a0 73 00 00       	call   80108245 <copyout>
80100ea5:	83 c4 10             	add    $0x10,%esp
80100ea8:	85 c0                	test   %eax,%eax
80100eaa:	79 15                	jns    80100ec1 <exec+0x341>
    cprintf("[exec] copyout of ustack failed\n");
80100eac:	83 ec 0c             	sub    $0xc,%esp
80100eaf:	68 e4 a6 10 80       	push   $0x8010a6e4
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
80100eff:	e8 9c 42 00 00       	call   801051a0 <safestrcpy>
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
80100f42:	e8 06 6c 00 00       	call   80107b4d <switchuvm>
80100f47:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4a:	83 ec 0c             	sub    $0xc,%esp
80100f4d:	ff 75 cc             	push   -0x34(%ebp)
80100f50:	e8 9d 70 00 00       	call   80107ff2 <freevm>
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
80100f8d:	e8 60 70 00 00       	call   80107ff2 <freevm>
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
80100fa9:	e8 f4 25 00 00       	call   801035a2 <end_op>
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
80100fbe:	68 05 a7 10 80       	push   $0x8010a705
80100fc3:	68 a0 4a 11 80       	push   $0x80114aa0
80100fc8:	e8 38 3d 00 00       	call   80104d05 <initlock>
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
80100fdc:	68 a0 4a 11 80       	push   $0x80114aa0
80100fe1:	e8 41 3d 00 00       	call   80104d27 <acquire>
80100fe6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe9:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
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
80101009:	68 a0 4a 11 80       	push   $0x80114aa0
8010100e:	e8 82 3d 00 00       	call   80104d95 <release>
80101013:	83 c4 10             	add    $0x10,%esp
      return f;
80101016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101019:	eb 23                	jmp    8010103e <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010101b:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010101f:	b8 34 54 11 80       	mov    $0x80115434,%eax
80101024:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101027:	72 c9                	jb     80100ff2 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101029:	83 ec 0c             	sub    $0xc,%esp
8010102c:	68 a0 4a 11 80       	push   $0x80114aa0
80101031:	e8 5f 3d 00 00       	call   80104d95 <release>
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
80101049:	68 a0 4a 11 80       	push   $0x80114aa0
8010104e:	e8 d4 3c 00 00       	call   80104d27 <acquire>
80101053:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101056:	8b 45 08             	mov    0x8(%ebp),%eax
80101059:	8b 40 04             	mov    0x4(%eax),%eax
8010105c:	85 c0                	test   %eax,%eax
8010105e:	7f 0d                	jg     8010106d <filedup+0x2d>
    panic("filedup");
80101060:	83 ec 0c             	sub    $0xc,%esp
80101063:	68 0c a7 10 80       	push   $0x8010a70c
80101068:	e8 3c f5 ff ff       	call   801005a9 <panic>
  f->ref++;
8010106d:	8b 45 08             	mov    0x8(%ebp),%eax
80101070:	8b 40 04             	mov    0x4(%eax),%eax
80101073:	8d 50 01             	lea    0x1(%eax),%edx
80101076:	8b 45 08             	mov    0x8(%ebp),%eax
80101079:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 a0 4a 11 80       	push   $0x80114aa0
80101084:	e8 0c 3d 00 00       	call   80104d95 <release>
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
8010109a:	68 a0 4a 11 80       	push   $0x80114aa0
8010109f:	e8 83 3c 00 00       	call   80104d27 <acquire>
801010a4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a7:	8b 45 08             	mov    0x8(%ebp),%eax
801010aa:	8b 40 04             	mov    0x4(%eax),%eax
801010ad:	85 c0                	test   %eax,%eax
801010af:	7f 0d                	jg     801010be <fileclose+0x2d>
    panic("fileclose");
801010b1:	83 ec 0c             	sub    $0xc,%esp
801010b4:	68 14 a7 10 80       	push   $0x8010a714
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
801010da:	68 a0 4a 11 80       	push   $0x80114aa0
801010df:	e8 b1 3c 00 00       	call   80104d95 <release>
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
80101128:	68 a0 4a 11 80       	push   $0x80114aa0
8010112d:	e8 63 3c 00 00       	call   80104d95 <release>
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
8010114c:	e8 48 2a 00 00       	call   80103b99 <pipeclose>
80101151:	83 c4 10             	add    $0x10,%esp
80101154:	eb 21                	jmp    80101177 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101156:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101159:	83 f8 02             	cmp    $0x2,%eax
8010115c:	75 19                	jne    80101177 <fileclose+0xe6>
    begin_op();
8010115e:	e8 b3 23 00 00       	call   80103516 <begin_op>
    iput(ff.ip);
80101163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101166:	83 ec 0c             	sub    $0xc,%esp
80101169:	50                   	push   %eax
8010116a:	e8 d2 09 00 00       	call   80101b41 <iput>
8010116f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101172:	e8 2b 24 00 00       	call   801035a2 <end_op>
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
80101205:	e8 3c 2b 00 00       	call   80103d46 <piperead>
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
8010127c:	68 1e a7 10 80       	push   $0x8010a71e
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
801012be:	e8 81 29 00 00       	call   80103c44 <pipewrite>
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
80101303:	e8 0e 22 00 00       	call   80103516 <begin_op>
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
80101369:	e8 34 22 00 00       	call   801035a2 <end_op>

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
8010137f:	68 27 a7 10 80       	push   $0x8010a727
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
801013b5:	68 37 a7 10 80       	push   $0x8010a737
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
801013ed:	e8 6a 3c 00 00       	call   8010505c <memmove>
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
80101433:	e8 65 3b 00 00       	call   80104f9d <memset>
80101438:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010143b:	83 ec 0c             	sub    $0xc,%esp
8010143e:	ff 75 f4             	push   -0xc(%ebp)
80101441:	e8 09 23 00 00       	call   8010374f <log_write>
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
80101486:	a1 58 54 11 80       	mov    0x80115458,%eax
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
8010150d:	e8 3d 22 00 00       	call   8010374f <log_write>
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
8010155c:	a1 40 54 11 80       	mov    0x80115440,%eax
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
8010157e:	8b 15 40 54 11 80    	mov    0x80115440,%edx
80101584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101587:	39 c2                	cmp    %eax,%edx
80101589:	0f 87 e4 fe ff ff    	ja     80101473 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010158f:	83 ec 0c             	sub    $0xc,%esp
80101592:	68 44 a7 10 80       	push   $0x8010a744
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
801015a7:	68 40 54 11 80       	push   $0x80115440
801015ac:	ff 75 08             	push   0x8(%ebp)
801015af:	e8 10 fe ff ff       	call   801013c4 <readsb>
801015b4:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ba:	c1 e8 0c             	shr    $0xc,%eax
801015bd:	89 c2                	mov    %eax,%edx
801015bf:	a1 58 54 11 80       	mov    0x80115458,%eax
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
8010161d:	68 5a a7 10 80       	push   $0x8010a75a
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
80101655:	e8 f5 20 00 00       	call   8010374f <log_write>
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
80101681:	68 6d a7 10 80       	push   $0x8010a76d
80101686:	68 60 54 11 80       	push   $0x80115460
8010168b:	e8 75 36 00 00       	call   80104d05 <initlock>
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
801016ac:	05 60 54 11 80       	add    $0x80115460,%eax
801016b1:	83 c0 10             	add    $0x10,%eax
801016b4:	83 ec 08             	sub    $0x8,%esp
801016b7:	68 74 a7 10 80       	push   $0x8010a774
801016bc:	50                   	push   %eax
801016bd:	e8 e6 34 00 00       	call   80104ba8 <initsleeplock>
801016c2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016c5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016c9:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016cd:	7e cd                	jle    8010169c <iinit+0x2e>
  }

  readsb(dev, &sb);
801016cf:	83 ec 08             	sub    $0x8,%esp
801016d2:	68 40 54 11 80       	push   $0x80115440
801016d7:	ff 75 08             	push   0x8(%ebp)
801016da:	e8 e5 fc ff ff       	call   801013c4 <readsb>
801016df:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016e2:	a1 58 54 11 80       	mov    0x80115458,%eax
801016e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016ea:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016f0:	8b 35 50 54 11 80    	mov    0x80115450,%esi
801016f6:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
801016fc:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
80101702:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101708:	a1 40 54 11 80       	mov    0x80115440,%eax
8010170d:	ff 75 d4             	push   -0x2c(%ebp)
80101710:	57                   	push   %edi
80101711:	56                   	push   %esi
80101712:	53                   	push   %ebx
80101713:	51                   	push   %ecx
80101714:	52                   	push   %edx
80101715:	50                   	push   %eax
80101716:	68 7c a7 10 80       	push   $0x8010a77c
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
8010174d:	a1 54 54 11 80       	mov    0x80115454,%eax
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
8010178f:	e8 09 38 00 00       	call   80104f9d <memset>
80101794:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010179a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010179e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017a1:	83 ec 0c             	sub    $0xc,%esp
801017a4:	ff 75 f0             	push   -0x10(%ebp)
801017a7:	e8 a3 1f 00 00       	call   8010374f <log_write>
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
801017e3:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ec:	39 c2                	cmp    %eax,%edx
801017ee:	0f 87 51 ff ff ff    	ja     80101745 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017f4:	83 ec 0c             	sub    $0xc,%esp
801017f7:	68 cf a7 10 80       	push   $0x8010a7cf
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
80101814:	a1 54 54 11 80       	mov    0x80115454,%eax
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
8010189d:	e8 ba 37 00 00       	call   8010505c <memmove>
801018a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	ff 75 f4             	push   -0xc(%ebp)
801018ab:	e8 9f 1e 00 00       	call   8010374f <log_write>
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
801018cd:	68 60 54 11 80       	push   $0x80115460
801018d2:	e8 50 34 00 00       	call   80104d27 <acquire>
801018d7:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018e1:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
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
8010191b:	68 60 54 11 80       	push   $0x80115460
80101920:	e8 70 34 00 00       	call   80104d95 <release>
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
8010194a:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80101951:	72 97                	jb     801018ea <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101953:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101957:	75 0d                	jne    80101966 <iget+0xa2>
    panic("iget: no inodes");
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	68 e1 a7 10 80       	push   $0x8010a7e1
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
80101994:	68 60 54 11 80       	push   $0x80115460
80101999:	e8 f7 33 00 00       	call   80104d95 <release>
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
801019af:	68 60 54 11 80       	push   $0x80115460
801019b4:	e8 6e 33 00 00       	call   80104d27 <acquire>
801019b9:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019bc:	8b 45 08             	mov    0x8(%ebp),%eax
801019bf:	8b 40 08             	mov    0x8(%eax),%eax
801019c2:	8d 50 01             	lea    0x1(%eax),%edx
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019cb:	83 ec 0c             	sub    $0xc,%esp
801019ce:	68 60 54 11 80       	push   $0x80115460
801019d3:	e8 bd 33 00 00       	call   80104d95 <release>
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
801019f9:	68 f1 a7 10 80       	push   $0x8010a7f1
801019fe:	e8 a6 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	83 c0 0c             	add    $0xc,%eax
80101a09:	83 ec 0c             	sub    $0xc,%esp
80101a0c:	50                   	push   %eax
80101a0d:	e8 d2 31 00 00       	call   80104be4 <acquiresleep>
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
80101a2e:	a1 54 54 11 80       	mov    0x80115454,%eax
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
80101ab7:	e8 a0 35 00 00       	call   8010505c <memmove>
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
80101ae6:	68 f7 a7 10 80       	push   $0x8010a7f7
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
80101b09:	e8 88 31 00 00       	call   80104c96 <holdingsleep>
80101b0e:	83 c4 10             	add    $0x10,%esp
80101b11:	85 c0                	test   %eax,%eax
80101b13:	74 0a                	je     80101b1f <iunlock+0x2c>
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	8b 40 08             	mov    0x8(%eax),%eax
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	7f 0d                	jg     80101b2c <iunlock+0x39>
    panic("iunlock");
80101b1f:	83 ec 0c             	sub    $0xc,%esp
80101b22:	68 06 a8 10 80       	push   $0x8010a806
80101b27:	e8 7d ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	83 c0 0c             	add    $0xc,%eax
80101b32:	83 ec 0c             	sub    $0xc,%esp
80101b35:	50                   	push   %eax
80101b36:	e8 0d 31 00 00       	call   80104c48 <releasesleep>
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
80101b51:	e8 8e 30 00 00       	call   80104be4 <acquiresleep>
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
80101b72:	68 60 54 11 80       	push   $0x80115460
80101b77:	e8 ab 31 00 00       	call   80104d27 <acquire>
80101b7c:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 40 08             	mov    0x8(%eax),%eax
80101b85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	68 60 54 11 80       	push   $0x80115460
80101b90:	e8 00 32 00 00       	call   80104d95 <release>
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
80101bd7:	e8 6c 30 00 00       	call   80104c48 <releasesleep>
80101bdc:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	68 60 54 11 80       	push   $0x80115460
80101be7:	e8 3b 31 00 00       	call   80104d27 <acquire>
80101bec:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	8b 40 08             	mov    0x8(%eax),%eax
80101bf5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	68 60 54 11 80       	push   $0x80115460
80101c06:	e8 8a 31 00 00       	call   80104d95 <release>
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
80101d2c:	e8 1e 1a 00 00       	call   8010374f <log_write>
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
80101d4a:	68 0e a8 10 80       	push   $0x8010a80e
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
80101f00:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <readi+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 0a 01 00 00       	jmp    8010201f <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
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
80101fe8:	e8 6f 30 00 00       	call   8010505c <memmove>
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
80102055:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
8010205c:	85 c0                	test   %eax,%eax
8010205e:	75 0a                	jne    8010206a <writei+0x49>
      return -1;
80102060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102065:	e9 3b 01 00 00       	jmp    801021a5 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102071:	98                   	cwtl   
80102072:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
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
80102138:	e8 1f 2f 00 00       	call   8010505c <memmove>
8010213d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102140:	83 ec 0c             	sub    $0xc,%esp
80102143:	ff 75 f0             	push   -0x10(%ebp)
80102146:	e8 04 16 00 00       	call   8010374f <log_write>
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
801021b8:	e8 35 2f 00 00       	call   801050f2 <strncmp>
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
801021d8:	68 21 a8 10 80       	push   $0x8010a821
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
80102207:	68 33 a8 10 80       	push   $0x8010a833
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
801022dc:	68 42 a8 10 80       	push   $0x8010a842
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
80102317:	e8 2c 2e 00 00       	call   80105148 <strncpy>
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
80102343:	68 4f a8 10 80       	push   $0x8010a84f
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
801023b5:	e8 a2 2c 00 00       	call   8010505c <memmove>
801023ba:	83 c4 10             	add    $0x10,%esp
801023bd:	eb 26                	jmp    801023e5 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	50                   	push   %eax
801023c6:	ff 75 f4             	push   -0xc(%ebp)
801023c9:	ff 75 0c             	push   0xc(%ebp)
801023cc:	e8 8b 2c 00 00       	call   8010505c <memmove>
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
8010241b:	e8 ea 1a 00 00       	call   80103f0a <myproc>
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

8010254a <inb>:
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
8010254d:	83 ec 14             	sub    $0x14,%esp
80102550:	8b 45 08             	mov    0x8(%ebp),%eax
80102553:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102557:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010255b:	89 c2                	mov    %eax,%edx
8010255d:	ec                   	in     (%dx),%al
8010255e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102561:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102565:	c9                   	leave  
80102566:	c3                   	ret    

80102567 <insl>:
{
80102567:	55                   	push   %ebp
80102568:	89 e5                	mov    %esp,%ebp
8010256a:	57                   	push   %edi
8010256b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010256c:	8b 55 08             	mov    0x8(%ebp),%edx
8010256f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102572:	8b 45 10             	mov    0x10(%ebp),%eax
80102575:	89 cb                	mov    %ecx,%ebx
80102577:	89 df                	mov    %ebx,%edi
80102579:	89 c1                	mov    %eax,%ecx
8010257b:	fc                   	cld    
8010257c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010257e:	89 c8                	mov    %ecx,%eax
80102580:	89 fb                	mov    %edi,%ebx
80102582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102585:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102588:	90                   	nop
80102589:	5b                   	pop    %ebx
8010258a:	5f                   	pop    %edi
8010258b:	5d                   	pop    %ebp
8010258c:	c3                   	ret    

8010258d <outb>:
{
8010258d:	55                   	push   %ebp
8010258e:	89 e5                	mov    %esp,%ebp
80102590:	83 ec 08             	sub    $0x8,%esp
80102593:	8b 45 08             	mov    0x8(%ebp),%eax
80102596:	8b 55 0c             	mov    0xc(%ebp),%edx
80102599:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010259d:	89 d0                	mov    %edx,%eax
8010259f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025a2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025a6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025aa:	ee                   	out    %al,(%dx)
}
801025ab:	90                   	nop
801025ac:	c9                   	leave  
801025ad:	c3                   	ret    

801025ae <outsl>:
{
801025ae:	55                   	push   %ebp
801025af:	89 e5                	mov    %esp,%ebp
801025b1:	56                   	push   %esi
801025b2:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025b3:	8b 55 08             	mov    0x8(%ebp),%edx
801025b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025b9:	8b 45 10             	mov    0x10(%ebp),%eax
801025bc:	89 cb                	mov    %ecx,%ebx
801025be:	89 de                	mov    %ebx,%esi
801025c0:	89 c1                	mov    %eax,%ecx
801025c2:	fc                   	cld    
801025c3:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025c5:	89 c8                	mov    %ecx,%eax
801025c7:	89 f3                	mov    %esi,%ebx
801025c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025cc:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025cf:	90                   	nop
801025d0:	5b                   	pop    %ebx
801025d1:	5e                   	pop    %esi
801025d2:	5d                   	pop    %ebp
801025d3:	c3                   	ret    

801025d4 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025d4:	55                   	push   %ebp
801025d5:	89 e5                	mov    %esp,%ebp
801025d7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025da:	90                   	nop
801025db:	68 f7 01 00 00       	push   $0x1f7
801025e0:	e8 65 ff ff ff       	call   8010254a <inb>
801025e5:	83 c4 04             	add    $0x4,%esp
801025e8:	0f b6 c0             	movzbl %al,%eax
801025eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025f1:	25 c0 00 00 00       	and    $0xc0,%eax
801025f6:	83 f8 40             	cmp    $0x40,%eax
801025f9:	75 e0                	jne    801025db <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ff:	74 11                	je     80102612 <idewait+0x3e>
80102601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102604:	83 e0 21             	and    $0x21,%eax
80102607:	85 c0                	test   %eax,%eax
80102609:	74 07                	je     80102612 <idewait+0x3e>
    return -1;
8010260b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102610:	eb 05                	jmp    80102617 <idewait+0x43>
  return 0;
80102612:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102617:	c9                   	leave  
80102618:	c3                   	ret    

80102619 <ideinit>:

void
ideinit(void)
{
80102619:	55                   	push   %ebp
8010261a:	89 e5                	mov    %esp,%ebp
8010261c:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010261f:	83 ec 08             	sub    $0x8,%esp
80102622:	68 57 a8 10 80       	push   $0x8010a857
80102627:	68 c0 70 11 80       	push   $0x801170c0
8010262c:	e8 d4 26 00 00       	call   80104d05 <initlock>
80102631:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102634:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80102639:	83 e8 01             	sub    $0x1,%eax
8010263c:	83 ec 08             	sub    $0x8,%esp
8010263f:	50                   	push   %eax
80102640:	6a 0e                	push   $0xe
80102642:	e8 c1 04 00 00       	call   80102b08 <ioapicenable>
80102647:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010264a:	83 ec 0c             	sub    $0xc,%esp
8010264d:	6a 00                	push   $0x0
8010264f:	e8 80 ff ff ff       	call   801025d4 <idewait>
80102654:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102657:	83 ec 08             	sub    $0x8,%esp
8010265a:	68 f0 00 00 00       	push   $0xf0
8010265f:	68 f6 01 00 00       	push   $0x1f6
80102664:	e8 24 ff ff ff       	call   8010258d <outb>
80102669:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010266c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102673:	eb 24                	jmp    80102699 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102675:	83 ec 0c             	sub    $0xc,%esp
80102678:	68 f7 01 00 00       	push   $0x1f7
8010267d:	e8 c8 fe ff ff       	call   8010254a <inb>
80102682:	83 c4 10             	add    $0x10,%esp
80102685:	84 c0                	test   %al,%al
80102687:	74 0c                	je     80102695 <ideinit+0x7c>
      havedisk1 = 1;
80102689:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
80102690:	00 00 00 
      break;
80102693:	eb 0d                	jmp    801026a2 <ideinit+0x89>
  for(i=0; i<1000; i++){
80102695:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102699:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026a0:	7e d3                	jle    80102675 <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026a2:	83 ec 08             	sub    $0x8,%esp
801026a5:	68 e0 00 00 00       	push   $0xe0
801026aa:	68 f6 01 00 00       	push   $0x1f6
801026af:	e8 d9 fe ff ff       	call   8010258d <outb>
801026b4:	83 c4 10             	add    $0x10,%esp
}
801026b7:	90                   	nop
801026b8:	c9                   	leave  
801026b9:	c3                   	ret    

801026ba <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ba:	55                   	push   %ebp
801026bb:	89 e5                	mov    %esp,%ebp
801026bd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c4:	75 0d                	jne    801026d3 <idestart+0x19>
    panic("idestart");
801026c6:	83 ec 0c             	sub    $0xc,%esp
801026c9:	68 5b a8 10 80       	push   $0x8010a85b
801026ce:	e8 d6 de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026d3:	8b 45 08             	mov    0x8(%ebp),%eax
801026d6:	8b 40 08             	mov    0x8(%eax),%eax
801026d9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026de:	76 0d                	jbe    801026ed <idestart+0x33>
    panic("incorrect blockno");
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	68 64 a8 10 80       	push   $0x8010a864
801026e8:	e8 bc de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026ed:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026f4:	8b 45 08             	mov    0x8(%ebp),%eax
801026f7:	8b 50 08             	mov    0x8(%eax),%edx
801026fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026fd:	0f af c2             	imul   %edx,%eax
80102700:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102703:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102707:	75 07                	jne    80102710 <idestart+0x56>
80102709:	b8 20 00 00 00       	mov    $0x20,%eax
8010270e:	eb 05                	jmp    80102715 <idestart+0x5b>
80102710:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102715:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102718:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010271c:	75 07                	jne    80102725 <idestart+0x6b>
8010271e:	b8 30 00 00 00       	mov    $0x30,%eax
80102723:	eb 05                	jmp    8010272a <idestart+0x70>
80102725:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010272a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010272d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102731:	7e 0d                	jle    80102740 <idestart+0x86>
80102733:	83 ec 0c             	sub    $0xc,%esp
80102736:	68 5b a8 10 80       	push   $0x8010a85b
8010273b:	e8 69 de ff ff       	call   801005a9 <panic>

  idewait(0);
80102740:	83 ec 0c             	sub    $0xc,%esp
80102743:	6a 00                	push   $0x0
80102745:	e8 8a fe ff ff       	call   801025d4 <idewait>
8010274a:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010274d:	83 ec 08             	sub    $0x8,%esp
80102750:	6a 00                	push   $0x0
80102752:	68 f6 03 00 00       	push   $0x3f6
80102757:	e8 31 fe ff ff       	call   8010258d <outb>
8010275c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010275f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102762:	0f b6 c0             	movzbl %al,%eax
80102765:	83 ec 08             	sub    $0x8,%esp
80102768:	50                   	push   %eax
80102769:	68 f2 01 00 00       	push   $0x1f2
8010276e:	e8 1a fe ff ff       	call   8010258d <outb>
80102773:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102779:	0f b6 c0             	movzbl %al,%eax
8010277c:	83 ec 08             	sub    $0x8,%esp
8010277f:	50                   	push   %eax
80102780:	68 f3 01 00 00       	push   $0x1f3
80102785:	e8 03 fe ff ff       	call   8010258d <outb>
8010278a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010278d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102790:	c1 f8 08             	sar    $0x8,%eax
80102793:	0f b6 c0             	movzbl %al,%eax
80102796:	83 ec 08             	sub    $0x8,%esp
80102799:	50                   	push   %eax
8010279a:	68 f4 01 00 00       	push   $0x1f4
8010279f:	e8 e9 fd ff ff       	call   8010258d <outb>
801027a4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027aa:	c1 f8 10             	sar    $0x10,%eax
801027ad:	0f b6 c0             	movzbl %al,%eax
801027b0:	83 ec 08             	sub    $0x8,%esp
801027b3:	50                   	push   %eax
801027b4:	68 f5 01 00 00       	push   $0x1f5
801027b9:	e8 cf fd ff ff       	call   8010258d <outb>
801027be:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027c1:	8b 45 08             	mov    0x8(%ebp),%eax
801027c4:	8b 40 04             	mov    0x4(%eax),%eax
801027c7:	c1 e0 04             	shl    $0x4,%eax
801027ca:	83 e0 10             	and    $0x10,%eax
801027cd:	89 c2                	mov    %eax,%edx
801027cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027d2:	c1 f8 18             	sar    $0x18,%eax
801027d5:	83 e0 0f             	and    $0xf,%eax
801027d8:	09 d0                	or     %edx,%eax
801027da:	83 c8 e0             	or     $0xffffffe0,%eax
801027dd:	0f b6 c0             	movzbl %al,%eax
801027e0:	83 ec 08             	sub    $0x8,%esp
801027e3:	50                   	push   %eax
801027e4:	68 f6 01 00 00       	push   $0x1f6
801027e9:	e8 9f fd ff ff       	call   8010258d <outb>
801027ee:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027f1:	8b 45 08             	mov    0x8(%ebp),%eax
801027f4:	8b 00                	mov    (%eax),%eax
801027f6:	83 e0 04             	and    $0x4,%eax
801027f9:	85 c0                	test   %eax,%eax
801027fb:	74 35                	je     80102832 <idestart+0x178>
    outb(0x1f7, write_cmd);
801027fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102800:	0f b6 c0             	movzbl %al,%eax
80102803:	83 ec 08             	sub    $0x8,%esp
80102806:	50                   	push   %eax
80102807:	68 f7 01 00 00       	push   $0x1f7
8010280c:	e8 7c fd ff ff       	call   8010258d <outb>
80102811:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102814:	8b 45 08             	mov    0x8(%ebp),%eax
80102817:	83 c0 5c             	add    $0x5c,%eax
8010281a:	83 ec 04             	sub    $0x4,%esp
8010281d:	68 80 00 00 00       	push   $0x80
80102822:	50                   	push   %eax
80102823:	68 f0 01 00 00       	push   $0x1f0
80102828:	e8 81 fd ff ff       	call   801025ae <outsl>
8010282d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102830:	eb 17                	jmp    80102849 <idestart+0x18f>
    outb(0x1f7, read_cmd);
80102832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102835:	0f b6 c0             	movzbl %al,%eax
80102838:	83 ec 08             	sub    $0x8,%esp
8010283b:	50                   	push   %eax
8010283c:	68 f7 01 00 00       	push   $0x1f7
80102841:	e8 47 fd ff ff       	call   8010258d <outb>
80102846:	83 c4 10             	add    $0x10,%esp
}
80102849:	90                   	nop
8010284a:	c9                   	leave  
8010284b:	c3                   	ret    

8010284c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010284c:	55                   	push   %ebp
8010284d:	89 e5                	mov    %esp,%ebp
8010284f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102852:	83 ec 0c             	sub    $0xc,%esp
80102855:	68 c0 70 11 80       	push   $0x801170c0
8010285a:	e8 c8 24 00 00       	call   80104d27 <acquire>
8010285f:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102862:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102867:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010286a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010286e:	75 15                	jne    80102885 <ideintr+0x39>
    release(&idelock);
80102870:	83 ec 0c             	sub    $0xc,%esp
80102873:	68 c0 70 11 80       	push   $0x801170c0
80102878:	e8 18 25 00 00       	call   80104d95 <release>
8010287d:	83 c4 10             	add    $0x10,%esp
    return;
80102880:	e9 9a 00 00 00       	jmp    8010291f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102888:	8b 40 58             	mov    0x58(%eax),%eax
8010288b:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102893:	8b 00                	mov    (%eax),%eax
80102895:	83 e0 04             	and    $0x4,%eax
80102898:	85 c0                	test   %eax,%eax
8010289a:	75 2d                	jne    801028c9 <ideintr+0x7d>
8010289c:	83 ec 0c             	sub    $0xc,%esp
8010289f:	6a 01                	push   $0x1
801028a1:	e8 2e fd ff ff       	call   801025d4 <idewait>
801028a6:	83 c4 10             	add    $0x10,%esp
801028a9:	85 c0                	test   %eax,%eax
801028ab:	78 1c                	js     801028c9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b0:	83 c0 5c             	add    $0x5c,%eax
801028b3:	83 ec 04             	sub    $0x4,%esp
801028b6:	68 80 00 00 00       	push   $0x80
801028bb:	50                   	push   %eax
801028bc:	68 f0 01 00 00       	push   $0x1f0
801028c1:	e8 a1 fc ff ff       	call   80102567 <insl>
801028c6:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cc:	8b 00                	mov    (%eax),%eax
801028ce:	83 c8 02             	or     $0x2,%eax
801028d1:	89 c2                	mov    %eax,%edx
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028db:	8b 00                	mov    (%eax),%eax
801028dd:	83 e0 fb             	and    $0xfffffffb,%eax
801028e0:	89 c2                	mov    %eax,%edx
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028e7:	83 ec 0c             	sub    $0xc,%esp
801028ea:	ff 75 f4             	push   -0xc(%ebp)
801028ed:	e8 a8 1f 00 00       	call   8010489a <wakeup>
801028f2:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028f5:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801028fa:	85 c0                	test   %eax,%eax
801028fc:	74 11                	je     8010290f <ideintr+0xc3>
    idestart(idequeue);
801028fe:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102903:	83 ec 0c             	sub    $0xc,%esp
80102906:	50                   	push   %eax
80102907:	e8 ae fd ff ff       	call   801026ba <idestart>
8010290c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010290f:	83 ec 0c             	sub    $0xc,%esp
80102912:	68 c0 70 11 80       	push   $0x801170c0
80102917:	e8 79 24 00 00       	call   80104d95 <release>
8010291c:	83 c4 10             	add    $0x10,%esp
}
8010291f:	c9                   	leave  
80102920:	c3                   	ret    

80102921 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102921:	55                   	push   %ebp
80102922:	89 e5                	mov    %esp,%ebp
80102924:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102927:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
8010292d:	8b 45 08             	mov    0x8(%ebp),%eax
80102930:	8b 40 04             	mov    0x4(%eax),%eax
80102933:	83 ec 04             	sub    $0x4,%esp
80102936:	52                   	push   %edx
80102937:	50                   	push   %eax
80102938:	68 76 a8 10 80       	push   $0x8010a876
8010293d:	e8 b2 da ff ff       	call   801003f4 <cprintf>
80102942:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102945:	8b 45 08             	mov    0x8(%ebp),%eax
80102948:	83 c0 0c             	add    $0xc,%eax
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	50                   	push   %eax
8010294f:	e8 42 23 00 00       	call   80104c96 <holdingsleep>
80102954:	83 c4 10             	add    $0x10,%esp
80102957:	85 c0                	test   %eax,%eax
80102959:	75 0d                	jne    80102968 <iderw+0x47>
    panic("iderw: buf not locked");
8010295b:	83 ec 0c             	sub    $0xc,%esp
8010295e:	68 90 a8 10 80       	push   $0x8010a890
80102963:	e8 41 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	8b 00                	mov    (%eax),%eax
8010296d:	83 e0 06             	and    $0x6,%eax
80102970:	83 f8 02             	cmp    $0x2,%eax
80102973:	75 0d                	jne    80102982 <iderw+0x61>
    panic("iderw: nothing to do");
80102975:	83 ec 0c             	sub    $0xc,%esp
80102978:	68 a6 a8 10 80       	push   $0x8010a8a6
8010297d:	e8 27 dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
80102982:	8b 45 08             	mov    0x8(%ebp),%eax
80102985:	8b 40 04             	mov    0x4(%eax),%eax
80102988:	85 c0                	test   %eax,%eax
8010298a:	74 16                	je     801029a2 <iderw+0x81>
8010298c:	a1 f8 70 11 80       	mov    0x801170f8,%eax
80102991:	85 c0                	test   %eax,%eax
80102993:	75 0d                	jne    801029a2 <iderw+0x81>
    panic("iderw: ide disk 1 not present");
80102995:	83 ec 0c             	sub    $0xc,%esp
80102998:	68 bb a8 10 80       	push   $0x8010a8bb
8010299d:	e8 07 dc ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029a2:	83 ec 0c             	sub    $0xc,%esp
801029a5:	68 c0 70 11 80       	push   $0x801170c0
801029aa:	e8 78 23 00 00       	call   80104d27 <acquire>
801029af:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029b2:	8b 45 08             	mov    0x8(%ebp),%eax
801029b5:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029bc:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029c3:	eb 0b                	jmp    801029d0 <iderw+0xaf>
801029c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c8:	8b 00                	mov    (%eax),%eax
801029ca:	83 c0 58             	add    $0x58,%eax
801029cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d3:	8b 00                	mov    (%eax),%eax
801029d5:	85 c0                	test   %eax,%eax
801029d7:	75 ec                	jne    801029c5 <iderw+0xa4>
    ;
  *pp = b;
801029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dc:	8b 55 08             	mov    0x8(%ebp),%edx
801029df:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029e1:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029e6:	39 45 08             	cmp    %eax,0x8(%ebp)
801029e9:	75 23                	jne    80102a0e <iderw+0xed>
    idestart(b);
801029eb:	83 ec 0c             	sub    $0xc,%esp
801029ee:	ff 75 08             	push   0x8(%ebp)
801029f1:	e8 c4 fc ff ff       	call   801026ba <idestart>
801029f6:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029f9:	eb 13                	jmp    80102a0e <iderw+0xed>
    sleep(b, &idelock);
801029fb:	83 ec 08             	sub    $0x8,%esp
801029fe:	68 c0 70 11 80       	push   $0x801170c0
80102a03:	ff 75 08             	push   0x8(%ebp)
80102a06:	e8 a8 1d 00 00       	call   801047b3 <sleep>
80102a0b:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a11:	8b 00                	mov    (%eax),%eax
80102a13:	83 e0 06             	and    $0x6,%eax
80102a16:	83 f8 02             	cmp    $0x2,%eax
80102a19:	75 e0                	jne    801029fb <iderw+0xda>
  }


  release(&idelock);
80102a1b:	83 ec 0c             	sub    $0xc,%esp
80102a1e:	68 c0 70 11 80       	push   $0x801170c0
80102a23:	e8 6d 23 00 00       	call   80104d95 <release>
80102a28:	83 c4 10             	add    $0x10,%esp
}
80102a2b:	90                   	nop
80102a2c:	c9                   	leave  
80102a2d:	c3                   	ret    

80102a2e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a2e:	55                   	push   %ebp
80102a2f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a31:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a36:	8b 55 08             	mov    0x8(%ebp),%edx
80102a39:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a3b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a40:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a43:	5d                   	pop    %ebp
80102a44:	c3                   	ret    

80102a45 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a45:	55                   	push   %ebp
80102a46:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a48:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a50:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a52:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a57:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a5a:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a5d:	90                   	nop
80102a5e:	5d                   	pop    %ebp
80102a5f:	c3                   	ret    

80102a60 <ioapicinit>:

void
ioapicinit(void)
{
80102a60:	55                   	push   %ebp
80102a61:	89 e5                	mov    %esp,%ebp
80102a63:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a66:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a6d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a70:	6a 01                	push   $0x1
80102a72:	e8 b7 ff ff ff       	call   80102a2e <ioapicread>
80102a77:	83 c4 04             	add    $0x4,%esp
80102a7a:	c1 e8 10             	shr    $0x10,%eax
80102a7d:	25 ff 00 00 00       	and    $0xff,%eax
80102a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a85:	6a 00                	push   $0x0
80102a87:	e8 a2 ff ff ff       	call   80102a2e <ioapicread>
80102a8c:	83 c4 04             	add    $0x4,%esp
80102a8f:	c1 e8 18             	shr    $0x18,%eax
80102a92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a95:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
80102a9c:	0f b6 c0             	movzbl %al,%eax
80102a9f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aa2:	74 10                	je     80102ab4 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aa4:	83 ec 0c             	sub    $0xc,%esp
80102aa7:	68 dc a8 10 80       	push   $0x8010a8dc
80102aac:	e8 43 d9 ff ff       	call   801003f4 <cprintf>
80102ab1:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102abb:	eb 3f                	jmp    80102afc <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac0:	83 c0 20             	add    $0x20,%eax
80102ac3:	0d 00 00 01 00       	or     $0x10000,%eax
80102ac8:	89 c2                	mov    %eax,%edx
80102aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acd:	83 c0 08             	add    $0x8,%eax
80102ad0:	01 c0                	add    %eax,%eax
80102ad2:	83 ec 08             	sub    $0x8,%esp
80102ad5:	52                   	push   %edx
80102ad6:	50                   	push   %eax
80102ad7:	e8 69 ff ff ff       	call   80102a45 <ioapicwrite>
80102adc:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	83 c0 08             	add    $0x8,%eax
80102ae5:	01 c0                	add    %eax,%eax
80102ae7:	83 c0 01             	add    $0x1,%eax
80102aea:	83 ec 08             	sub    $0x8,%esp
80102aed:	6a 00                	push   $0x0
80102aef:	50                   	push   %eax
80102af0:	e8 50 ff ff ff       	call   80102a45 <ioapicwrite>
80102af5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102af8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b02:	7e b9                	jle    80102abd <ioapicinit+0x5d>
  }
}
80102b04:	90                   	nop
80102b05:	90                   	nop
80102b06:	c9                   	leave  
80102b07:	c3                   	ret    

80102b08 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0e:	83 c0 20             	add    $0x20,%eax
80102b11:	89 c2                	mov    %eax,%edx
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	83 c0 08             	add    $0x8,%eax
80102b19:	01 c0                	add    %eax,%eax
80102b1b:	52                   	push   %edx
80102b1c:	50                   	push   %eax
80102b1d:	e8 23 ff ff ff       	call   80102a45 <ioapicwrite>
80102b22:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b25:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b28:	c1 e0 18             	shl    $0x18,%eax
80102b2b:	89 c2                	mov    %eax,%edx
80102b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b30:	83 c0 08             	add    $0x8,%eax
80102b33:	01 c0                	add    %eax,%eax
80102b35:	83 c0 01             	add    $0x1,%eax
80102b38:	52                   	push   %edx
80102b39:	50                   	push   %eax
80102b3a:	e8 06 ff ff ff       	call   80102a45 <ioapicwrite>
80102b3f:	83 c4 08             	add    $0x8,%esp
}
80102b42:	90                   	nop
80102b43:	c9                   	leave  
80102b44:	c3                   	ret    

80102b45 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b45:	55                   	push   %ebp
80102b46:	89 e5                	mov    %esp,%ebp
80102b48:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b4b:	83 ec 08             	sub    $0x8,%esp
80102b4e:	68 0e a9 10 80       	push   $0x8010a90e
80102b53:	68 00 71 11 80       	push   $0x80117100
80102b58:	e8 a8 21 00 00       	call   80104d05 <initlock>
80102b5d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b60:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b67:	00 00 00 
  freerange(vstart, vend);
80102b6a:	83 ec 08             	sub    $0x8,%esp
80102b6d:	ff 75 0c             	push   0xc(%ebp)
80102b70:	ff 75 08             	push   0x8(%ebp)
80102b73:	e8 2a 00 00 00       	call   80102ba2 <freerange>
80102b78:	83 c4 10             	add    $0x10,%esp
}
80102b7b:	90                   	nop
80102b7c:	c9                   	leave  
80102b7d:	c3                   	ret    

80102b7e <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b7e:	55                   	push   %ebp
80102b7f:	89 e5                	mov    %esp,%ebp
80102b81:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b84:	83 ec 08             	sub    $0x8,%esp
80102b87:	ff 75 0c             	push   0xc(%ebp)
80102b8a:	ff 75 08             	push   0x8(%ebp)
80102b8d:	e8 10 00 00 00       	call   80102ba2 <freerange>
80102b92:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b95:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102b9c:	00 00 00 
}
80102b9f:	90                   	nop
80102ba0:	c9                   	leave  
80102ba1:	c3                   	ret    

80102ba2 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ba2:	55                   	push   %ebp
80102ba3:	89 e5                	mov    %esp,%ebp
80102ba5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bab:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb8:	eb 15                	jmp    80102bcf <freerange+0x2d>
    kfree(p);
80102bba:	83 ec 0c             	sub    $0xc,%esp
80102bbd:	ff 75 f4             	push   -0xc(%ebp)
80102bc0:	e8 1b 00 00 00       	call   80102be0 <kfree>
80102bc5:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd2:	05 00 10 00 00       	add    $0x1000,%eax
80102bd7:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bda:	73 de                	jae    80102bba <freerange+0x18>
}
80102bdc:	90                   	nop
80102bdd:	90                   	nop
80102bde:	c9                   	leave  
80102bdf:	c3                   	ret    

80102be0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102be0:	55                   	push   %ebp
80102be1:	89 e5                	mov    %esp,%ebp
80102be3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102be6:	8b 45 08             	mov    0x8(%ebp),%eax
80102be9:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bee:	85 c0                	test   %eax,%eax
80102bf0:	75 18                	jne    80102c0a <kfree+0x2a>
80102bf2:	81 7d 08 00 b0 11 80 	cmpl   $0x8011b000,0x8(%ebp)
80102bf9:	72 0f                	jb     80102c0a <kfree+0x2a>
80102bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfe:	05 00 00 00 80       	add    $0x80000000,%eax
80102c03:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c08:	76 0d                	jbe    80102c17 <kfree+0x37>
    panic("kfree");
80102c0a:	83 ec 0c             	sub    $0xc,%esp
80102c0d:	68 13 a9 10 80       	push   $0x8010a913
80102c12:	e8 92 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c17:	83 ec 04             	sub    $0x4,%esp
80102c1a:	68 00 10 00 00       	push   $0x1000
80102c1f:	6a 01                	push   $0x1
80102c21:	ff 75 08             	push   0x8(%ebp)
80102c24:	e8 74 23 00 00       	call   80104f9d <memset>
80102c29:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c2c:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 10                	je     80102c45 <kfree+0x65>
    acquire(&kmem.lock);
80102c35:	83 ec 0c             	sub    $0xc,%esp
80102c38:	68 00 71 11 80       	push   $0x80117100
80102c3d:	e8 e5 20 00 00       	call   80104d27 <acquire>
80102c42:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c45:	8b 45 08             	mov    0x8(%ebp),%eax
80102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4b:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c54:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c59:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c5e:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c63:	85 c0                	test   %eax,%eax
80102c65:	74 10                	je     80102c77 <kfree+0x97>
    release(&kmem.lock);
80102c67:	83 ec 0c             	sub    $0xc,%esp
80102c6a:	68 00 71 11 80       	push   $0x80117100
80102c6f:	e8 21 21 00 00       	call   80104d95 <release>
80102c74:	83 c4 10             	add    $0x10,%esp
}
80102c77:	90                   	nop
80102c78:	c9                   	leave  
80102c79:	c3                   	ret    

80102c7a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c7a:	55                   	push   %ebp
80102c7b:	89 e5                	mov    %esp,%ebp
80102c7d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c80:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c85:	85 c0                	test   %eax,%eax
80102c87:	74 10                	je     80102c99 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c89:	83 ec 0c             	sub    $0xc,%esp
80102c8c:	68 00 71 11 80       	push   $0x80117100
80102c91:	e8 91 20 00 00       	call   80104d27 <acquire>
80102c96:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c99:	a1 38 71 11 80       	mov    0x80117138,%eax
80102c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ca1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ca5:	74 0a                	je     80102cb1 <kalloc+0x37>
    kmem.freelist = r->next;
80102ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102caa:	8b 00                	mov    (%eax),%eax
80102cac:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cb1:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cb6:	85 c0                	test   %eax,%eax
80102cb8:	74 10                	je     80102cca <kalloc+0x50>
    release(&kmem.lock);
80102cba:	83 ec 0c             	sub    $0xc,%esp
80102cbd:	68 00 71 11 80       	push   $0x80117100
80102cc2:	e8 ce 20 00 00       	call   80104d95 <release>
80102cc7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    

80102ccf <inb>:
{
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 14             	sub    $0x14,%esp
80102cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cdc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ce0:	89 c2                	mov    %eax,%edx
80102ce2:	ec                   	in     (%dx),%al
80102ce3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ce6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cea:	c9                   	leave  
80102ceb:	c3                   	ret    

80102cec <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cf2:	6a 64                	push   $0x64
80102cf4:	e8 d6 ff ff ff       	call   80102ccf <inb>
80102cf9:	83 c4 04             	add    $0x4,%esp
80102cfc:	0f b6 c0             	movzbl %al,%eax
80102cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d05:	83 e0 01             	and    $0x1,%eax
80102d08:	85 c0                	test   %eax,%eax
80102d0a:	75 0a                	jne    80102d16 <kbdgetc+0x2a>
    return -1;
80102d0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d11:	e9 23 01 00 00       	jmp    80102e39 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d16:	6a 60                	push   $0x60
80102d18:	e8 b2 ff ff ff       	call   80102ccf <inb>
80102d1d:	83 c4 04             	add    $0x4,%esp
80102d20:	0f b6 c0             	movzbl %al,%eax
80102d23:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d26:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d2d:	75 17                	jne    80102d46 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d2f:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d34:	83 c8 40             	or     $0x40,%eax
80102d37:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d3c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d41:	e9 f3 00 00 00       	jmp    80102e39 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d49:	25 80 00 00 00       	and    $0x80,%eax
80102d4e:	85 c0                	test   %eax,%eax
80102d50:	74 45                	je     80102d97 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d52:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d57:	83 e0 40             	and    $0x40,%eax
80102d5a:	85 c0                	test   %eax,%eax
80102d5c:	75 08                	jne    80102d66 <kbdgetc+0x7a>
80102d5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d61:	83 e0 7f             	and    $0x7f,%eax
80102d64:	eb 03                	jmp    80102d69 <kbdgetc+0x7d>
80102d66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d69:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d74:	0f b6 00             	movzbl (%eax),%eax
80102d77:	83 c8 40             	or     $0x40,%eax
80102d7a:	0f b6 c0             	movzbl %al,%eax
80102d7d:	f7 d0                	not    %eax
80102d7f:	89 c2                	mov    %eax,%edx
80102d81:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d86:	21 d0                	and    %edx,%eax
80102d88:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d8d:	b8 00 00 00 00       	mov    $0x0,%eax
80102d92:	e9 a2 00 00 00       	jmp    80102e39 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d97:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d9c:	83 e0 40             	and    $0x40,%eax
80102d9f:	85 c0                	test   %eax,%eax
80102da1:	74 14                	je     80102db7 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102da3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102daa:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102daf:	83 e0 bf             	and    $0xffffffbf,%eax
80102db2:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102db7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dba:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dbf:	0f b6 00             	movzbl (%eax),%eax
80102dc2:	0f b6 d0             	movzbl %al,%edx
80102dc5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dca:	09 d0                	or     %edx,%eax
80102dcc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102dd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd4:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102dd9:	0f b6 00             	movzbl (%eax),%eax
80102ddc:	0f b6 d0             	movzbl %al,%edx
80102ddf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102de4:	31 d0                	xor    %edx,%eax
80102de6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102deb:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102df0:	83 e0 03             	and    $0x3,%eax
80102df3:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102dfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dfd:	01 d0                	add    %edx,%eax
80102dff:	0f b6 00             	movzbl (%eax),%eax
80102e02:	0f b6 c0             	movzbl %al,%eax
80102e05:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e08:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e0d:	83 e0 08             	and    $0x8,%eax
80102e10:	85 c0                	test   %eax,%eax
80102e12:	74 22                	je     80102e36 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e14:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e18:	76 0c                	jbe    80102e26 <kbdgetc+0x13a>
80102e1a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e1e:	77 06                	ja     80102e26 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e20:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e24:	eb 10                	jmp    80102e36 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e26:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e2a:	76 0a                	jbe    80102e36 <kbdgetc+0x14a>
80102e2c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e30:	77 04                	ja     80102e36 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e32:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e36:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e39:	c9                   	leave  
80102e3a:	c3                   	ret    

80102e3b <kbdintr>:

void
kbdintr(void)
{
80102e3b:	55                   	push   %ebp
80102e3c:	89 e5                	mov    %esp,%ebp
80102e3e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e41:	83 ec 0c             	sub    $0xc,%esp
80102e44:	68 ec 2c 10 80       	push   $0x80102cec
80102e49:	e8 88 d9 ff ff       	call   801007d6 <consoleintr>
80102e4e:	83 c4 10             	add    $0x10,%esp
}
80102e51:	90                   	nop
80102e52:	c9                   	leave  
80102e53:	c3                   	ret    

80102e54 <inb>:
{
80102e54:	55                   	push   %ebp
80102e55:	89 e5                	mov    %esp,%ebp
80102e57:	83 ec 14             	sub    $0x14,%esp
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e61:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e65:	89 c2                	mov    %eax,%edx
80102e67:	ec                   	in     (%dx),%al
80102e68:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e6b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e6f:	c9                   	leave  
80102e70:	c3                   	ret    

80102e71 <outb>:
{
80102e71:	55                   	push   %ebp
80102e72:	89 e5                	mov    %esp,%ebp
80102e74:	83 ec 08             	sub    $0x8,%esp
80102e77:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e7d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e81:	89 d0                	mov    %edx,%eax
80102e83:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e86:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e8a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e8e:	ee                   	out    %al,(%dx)
}
80102e8f:	90                   	nop
80102e90:	c9                   	leave  
80102e91:	c3                   	ret    

80102e92 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e92:	55                   	push   %ebp
80102e93:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e95:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e9e:	c1 e0 02             	shl    $0x2,%eax
80102ea1:	01 c2                	add    %eax,%edx
80102ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ea6:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ead:	83 c0 20             	add    $0x20,%eax
80102eb0:	8b 00                	mov    (%eax),%eax
}
80102eb2:	90                   	nop
80102eb3:	5d                   	pop    %ebp
80102eb4:	c3                   	ret    

80102eb5 <lapicinit>:

void
lapicinit(void)
{
80102eb5:	55                   	push   %ebp
80102eb6:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102eb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ebd:	85 c0                	test   %eax,%eax
80102ebf:	0f 84 0c 01 00 00    	je     80102fd1 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ec5:	68 3f 01 00 00       	push   $0x13f
80102eca:	6a 3c                	push   $0x3c
80102ecc:	e8 c1 ff ff ff       	call   80102e92 <lapicw>
80102ed1:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ed4:	6a 0b                	push   $0xb
80102ed6:	68 f8 00 00 00       	push   $0xf8
80102edb:	e8 b2 ff ff ff       	call   80102e92 <lapicw>
80102ee0:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ee3:	68 20 00 02 00       	push   $0x20020
80102ee8:	68 c8 00 00 00       	push   $0xc8
80102eed:	e8 a0 ff ff ff       	call   80102e92 <lapicw>
80102ef2:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102ef5:	68 80 96 98 00       	push   $0x989680
80102efa:	68 e0 00 00 00       	push   $0xe0
80102eff:	e8 8e ff ff ff       	call   80102e92 <lapicw>
80102f04:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f07:	68 00 00 01 00       	push   $0x10000
80102f0c:	68 d4 00 00 00       	push   $0xd4
80102f11:	e8 7c ff ff ff       	call   80102e92 <lapicw>
80102f16:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f19:	68 00 00 01 00       	push   $0x10000
80102f1e:	68 d8 00 00 00       	push   $0xd8
80102f23:	e8 6a ff ff ff       	call   80102e92 <lapicw>
80102f28:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f2b:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f30:	83 c0 30             	add    $0x30,%eax
80102f33:	8b 00                	mov    (%eax),%eax
80102f35:	c1 e8 10             	shr    $0x10,%eax
80102f38:	25 fc 00 00 00       	and    $0xfc,%eax
80102f3d:	85 c0                	test   %eax,%eax
80102f3f:	74 12                	je     80102f53 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f41:	68 00 00 01 00       	push   $0x10000
80102f46:	68 d0 00 00 00       	push   $0xd0
80102f4b:	e8 42 ff ff ff       	call   80102e92 <lapicw>
80102f50:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f53:	6a 33                	push   $0x33
80102f55:	68 dc 00 00 00       	push   $0xdc
80102f5a:	e8 33 ff ff ff       	call   80102e92 <lapicw>
80102f5f:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f62:	6a 00                	push   $0x0
80102f64:	68 a0 00 00 00       	push   $0xa0
80102f69:	e8 24 ff ff ff       	call   80102e92 <lapicw>
80102f6e:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f71:	6a 00                	push   $0x0
80102f73:	68 a0 00 00 00       	push   $0xa0
80102f78:	e8 15 ff ff ff       	call   80102e92 <lapicw>
80102f7d:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f80:	6a 00                	push   $0x0
80102f82:	6a 2c                	push   $0x2c
80102f84:	e8 09 ff ff ff       	call   80102e92 <lapicw>
80102f89:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f8c:	6a 00                	push   $0x0
80102f8e:	68 c4 00 00 00       	push   $0xc4
80102f93:	e8 fa fe ff ff       	call   80102e92 <lapicw>
80102f98:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f9b:	68 00 85 08 00       	push   $0x88500
80102fa0:	68 c0 00 00 00       	push   $0xc0
80102fa5:	e8 e8 fe ff ff       	call   80102e92 <lapicw>
80102faa:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fad:	90                   	nop
80102fae:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fb3:	05 00 03 00 00       	add    $0x300,%eax
80102fb8:	8b 00                	mov    (%eax),%eax
80102fba:	25 00 10 00 00       	and    $0x1000,%eax
80102fbf:	85 c0                	test   %eax,%eax
80102fc1:	75 eb                	jne    80102fae <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fc3:	6a 00                	push   $0x0
80102fc5:	6a 20                	push   $0x20
80102fc7:	e8 c6 fe ff ff       	call   80102e92 <lapicw>
80102fcc:	83 c4 08             	add    $0x8,%esp
80102fcf:	eb 01                	jmp    80102fd2 <lapicinit+0x11d>
    return;
80102fd1:	90                   	nop
}
80102fd2:	c9                   	leave  
80102fd3:	c3                   	ret    

80102fd4 <lapicid>:

int
lapicid(void)
{
80102fd4:	55                   	push   %ebp
80102fd5:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fd7:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fdc:	85 c0                	test   %eax,%eax
80102fde:	75 07                	jne    80102fe7 <lapicid+0x13>
    return 0;
80102fe0:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe5:	eb 0d                	jmp    80102ff4 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102fe7:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fec:	83 c0 20             	add    $0x20,%eax
80102fef:	8b 00                	mov    (%eax),%eax
80102ff1:	c1 e8 18             	shr    $0x18,%eax
}
80102ff4:	5d                   	pop    %ebp
80102ff5:	c3                   	ret    

80102ff6 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ff6:	55                   	push   %ebp
80102ff7:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102ff9:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ffe:	85 c0                	test   %eax,%eax
80103000:	74 0c                	je     8010300e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103002:	6a 00                	push   $0x0
80103004:	6a 2c                	push   $0x2c
80103006:	e8 87 fe ff ff       	call   80102e92 <lapicw>
8010300b:	83 c4 08             	add    $0x8,%esp
}
8010300e:	90                   	nop
8010300f:	c9                   	leave  
80103010:	c3                   	ret    

80103011 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103011:	55                   	push   %ebp
80103012:	89 e5                	mov    %esp,%ebp
}
80103014:	90                   	nop
80103015:	5d                   	pop    %ebp
80103016:	c3                   	ret    

80103017 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103017:	55                   	push   %ebp
80103018:	89 e5                	mov    %esp,%ebp
8010301a:	83 ec 14             	sub    $0x14,%esp
8010301d:	8b 45 08             	mov    0x8(%ebp),%eax
80103020:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103023:	6a 0f                	push   $0xf
80103025:	6a 70                	push   $0x70
80103027:	e8 45 fe ff ff       	call   80102e71 <outb>
8010302c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010302f:	6a 0a                	push   $0xa
80103031:	6a 71                	push   $0x71
80103033:	e8 39 fe ff ff       	call   80102e71 <outb>
80103038:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010303b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103042:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103045:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010304a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010304d:	c1 e8 04             	shr    $0x4,%eax
80103050:	89 c2                	mov    %eax,%edx
80103052:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103055:	83 c0 02             	add    $0x2,%eax
80103058:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010305b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010305f:	c1 e0 18             	shl    $0x18,%eax
80103062:	50                   	push   %eax
80103063:	68 c4 00 00 00       	push   $0xc4
80103068:	e8 25 fe ff ff       	call   80102e92 <lapicw>
8010306d:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103070:	68 00 c5 00 00       	push   $0xc500
80103075:	68 c0 00 00 00       	push   $0xc0
8010307a:	e8 13 fe ff ff       	call   80102e92 <lapicw>
8010307f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103082:	68 c8 00 00 00       	push   $0xc8
80103087:	e8 85 ff ff ff       	call   80103011 <microdelay>
8010308c:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010308f:	68 00 85 00 00       	push   $0x8500
80103094:	68 c0 00 00 00       	push   $0xc0
80103099:	e8 f4 fd ff ff       	call   80102e92 <lapicw>
8010309e:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030a1:	6a 64                	push   $0x64
801030a3:	e8 69 ff ff ff       	call   80103011 <microdelay>
801030a8:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030b2:	eb 3d                	jmp    801030f1 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030b4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030b8:	c1 e0 18             	shl    $0x18,%eax
801030bb:	50                   	push   %eax
801030bc:	68 c4 00 00 00       	push   $0xc4
801030c1:	e8 cc fd ff ff       	call   80102e92 <lapicw>
801030c6:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801030cc:	c1 e8 0c             	shr    $0xc,%eax
801030cf:	80 cc 06             	or     $0x6,%ah
801030d2:	50                   	push   %eax
801030d3:	68 c0 00 00 00       	push   $0xc0
801030d8:	e8 b5 fd ff ff       	call   80102e92 <lapicw>
801030dd:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030e0:	68 c8 00 00 00       	push   $0xc8
801030e5:	e8 27 ff ff ff       	call   80103011 <microdelay>
801030ea:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030f1:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030f5:	7e bd                	jle    801030b4 <lapicstartap+0x9d>
  }
}
801030f7:	90                   	nop
801030f8:	90                   	nop
801030f9:	c9                   	leave  
801030fa:	c3                   	ret    

801030fb <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030fb:	55                   	push   %ebp
801030fc:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801030fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103101:	0f b6 c0             	movzbl %al,%eax
80103104:	50                   	push   %eax
80103105:	6a 70                	push   $0x70
80103107:	e8 65 fd ff ff       	call   80102e71 <outb>
8010310c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010310f:	68 c8 00 00 00       	push   $0xc8
80103114:	e8 f8 fe ff ff       	call   80103011 <microdelay>
80103119:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010311c:	6a 71                	push   $0x71
8010311e:	e8 31 fd ff ff       	call   80102e54 <inb>
80103123:	83 c4 04             	add    $0x4,%esp
80103126:	0f b6 c0             	movzbl %al,%eax
}
80103129:	c9                   	leave  
8010312a:	c3                   	ret    

8010312b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010312b:	55                   	push   %ebp
8010312c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010312e:	6a 00                	push   $0x0
80103130:	e8 c6 ff ff ff       	call   801030fb <cmos_read>
80103135:	83 c4 04             	add    $0x4,%esp
80103138:	8b 55 08             	mov    0x8(%ebp),%edx
8010313b:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010313d:	6a 02                	push   $0x2
8010313f:	e8 b7 ff ff ff       	call   801030fb <cmos_read>
80103144:	83 c4 04             	add    $0x4,%esp
80103147:	8b 55 08             	mov    0x8(%ebp),%edx
8010314a:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010314d:	6a 04                	push   $0x4
8010314f:	e8 a7 ff ff ff       	call   801030fb <cmos_read>
80103154:	83 c4 04             	add    $0x4,%esp
80103157:	8b 55 08             	mov    0x8(%ebp),%edx
8010315a:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010315d:	6a 07                	push   $0x7
8010315f:	e8 97 ff ff ff       	call   801030fb <cmos_read>
80103164:	83 c4 04             	add    $0x4,%esp
80103167:	8b 55 08             	mov    0x8(%ebp),%edx
8010316a:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010316d:	6a 08                	push   $0x8
8010316f:	e8 87 ff ff ff       	call   801030fb <cmos_read>
80103174:	83 c4 04             	add    $0x4,%esp
80103177:	8b 55 08             	mov    0x8(%ebp),%edx
8010317a:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010317d:	6a 09                	push   $0x9
8010317f:	e8 77 ff ff ff       	call   801030fb <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	8b 55 08             	mov    0x8(%ebp),%edx
8010318a:	89 42 14             	mov    %eax,0x14(%edx)
}
8010318d:	90                   	nop
8010318e:	c9                   	leave  
8010318f:	c3                   	ret    

80103190 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103190:	55                   	push   %ebp
80103191:	89 e5                	mov    %esp,%ebp
80103193:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103196:	6a 0b                	push   $0xb
80103198:	e8 5e ff ff ff       	call   801030fb <cmos_read>
8010319d:	83 c4 04             	add    $0x4,%esp
801031a0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a6:	83 e0 04             	and    $0x4,%eax
801031a9:	85 c0                	test   %eax,%eax
801031ab:	0f 94 c0             	sete   %al
801031ae:	0f b6 c0             	movzbl %al,%eax
801031b1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031b7:	50                   	push   %eax
801031b8:	e8 6e ff ff ff       	call   8010312b <fill_rtcdate>
801031bd:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031c0:	6a 0a                	push   $0xa
801031c2:	e8 34 ff ff ff       	call   801030fb <cmos_read>
801031c7:	83 c4 04             	add    $0x4,%esp
801031ca:	25 80 00 00 00       	and    $0x80,%eax
801031cf:	85 c0                	test   %eax,%eax
801031d1:	75 27                	jne    801031fa <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031d3:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031d6:	50                   	push   %eax
801031d7:	e8 4f ff ff ff       	call   8010312b <fill_rtcdate>
801031dc:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031df:	83 ec 04             	sub    $0x4,%esp
801031e2:	6a 18                	push   $0x18
801031e4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e7:	50                   	push   %eax
801031e8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031eb:	50                   	push   %eax
801031ec:	e8 13 1e 00 00       	call   80105004 <memcmp>
801031f1:	83 c4 10             	add    $0x10,%esp
801031f4:	85 c0                	test   %eax,%eax
801031f6:	74 05                	je     801031fd <cmostime+0x6d>
801031f8:	eb ba                	jmp    801031b4 <cmostime+0x24>
        continue;
801031fa:	90                   	nop
    fill_rtcdate(&t1);
801031fb:	eb b7                	jmp    801031b4 <cmostime+0x24>
      break;
801031fd:	90                   	nop
  }

  // convert
  if(bcd) {
801031fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103202:	0f 84 b4 00 00 00    	je     801032bc <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103208:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010320b:	c1 e8 04             	shr    $0x4,%eax
8010320e:	89 c2                	mov    %eax,%edx
80103210:	89 d0                	mov    %edx,%eax
80103212:	c1 e0 02             	shl    $0x2,%eax
80103215:	01 d0                	add    %edx,%eax
80103217:	01 c0                	add    %eax,%eax
80103219:	89 c2                	mov    %eax,%edx
8010321b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010321e:	83 e0 0f             	and    $0xf,%eax
80103221:	01 d0                	add    %edx,%eax
80103223:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103226:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103229:	c1 e8 04             	shr    $0x4,%eax
8010322c:	89 c2                	mov    %eax,%edx
8010322e:	89 d0                	mov    %edx,%eax
80103230:	c1 e0 02             	shl    $0x2,%eax
80103233:	01 d0                	add    %edx,%eax
80103235:	01 c0                	add    %eax,%eax
80103237:	89 c2                	mov    %eax,%edx
80103239:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010323c:	83 e0 0f             	and    $0xf,%eax
8010323f:	01 d0                	add    %edx,%eax
80103241:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103244:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103247:	c1 e8 04             	shr    $0x4,%eax
8010324a:	89 c2                	mov    %eax,%edx
8010324c:	89 d0                	mov    %edx,%eax
8010324e:	c1 e0 02             	shl    $0x2,%eax
80103251:	01 d0                	add    %edx,%eax
80103253:	01 c0                	add    %eax,%eax
80103255:	89 c2                	mov    %eax,%edx
80103257:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010325a:	83 e0 0f             	and    $0xf,%eax
8010325d:	01 d0                	add    %edx,%eax
8010325f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103278:	83 e0 0f             	and    $0xf,%eax
8010327b:	01 d0                	add    %edx,%eax
8010327d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103280:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103283:	c1 e8 04             	shr    $0x4,%eax
80103286:	89 c2                	mov    %eax,%edx
80103288:	89 d0                	mov    %edx,%eax
8010328a:	c1 e0 02             	shl    $0x2,%eax
8010328d:	01 d0                	add    %edx,%eax
8010328f:	01 c0                	add    %eax,%eax
80103291:	89 c2                	mov    %eax,%edx
80103293:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103296:	83 e0 0f             	and    $0xf,%eax
80103299:	01 d0                	add    %edx,%eax
8010329b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010329e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032a1:	c1 e8 04             	shr    $0x4,%eax
801032a4:	89 c2                	mov    %eax,%edx
801032a6:	89 d0                	mov    %edx,%eax
801032a8:	c1 e0 02             	shl    $0x2,%eax
801032ab:	01 d0                	add    %edx,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b4:	83 e0 0f             	and    $0xf,%eax
801032b7:	01 d0                	add    %edx,%eax
801032b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032bc:	8b 45 08             	mov    0x8(%ebp),%eax
801032bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032c2:	89 10                	mov    %edx,(%eax)
801032c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032c7:	89 50 04             	mov    %edx,0x4(%eax)
801032ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032cd:	89 50 08             	mov    %edx,0x8(%eax)
801032d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032d3:	89 50 0c             	mov    %edx,0xc(%eax)
801032d6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032d9:	89 50 10             	mov    %edx,0x10(%eax)
801032dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032df:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 14             	mov    0x14(%eax),%eax
801032e8:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032ee:	8b 45 08             	mov    0x8(%ebp),%eax
801032f1:	89 50 14             	mov    %edx,0x14(%eax)
}
801032f4:	90                   	nop
801032f5:	c9                   	leave  
801032f6:	c3                   	ret    

801032f7 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032f7:	55                   	push   %ebp
801032f8:	89 e5                	mov    %esp,%ebp
801032fa:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032fd:	83 ec 08             	sub    $0x8,%esp
80103300:	68 19 a9 10 80       	push   $0x8010a919
80103305:	68 60 71 11 80       	push   $0x80117160
8010330a:	e8 f6 19 00 00       	call   80104d05 <initlock>
8010330f:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103312:	83 ec 08             	sub    $0x8,%esp
80103315:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103318:	50                   	push   %eax
80103319:	ff 75 08             	push   0x8(%ebp)
8010331c:	e8 a3 e0 ff ff       	call   801013c4 <readsb>
80103321:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103324:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103327:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
8010332c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010332f:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
8010333c:	e8 b3 01 00 00       	call   801034f4 <recover_from_log>
}
80103341:	90                   	nop
80103342:	c9                   	leave  
80103343:	c3                   	ret    

80103344 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103344:	55                   	push   %ebp
80103345:	89 e5                	mov    %esp,%ebp
80103347:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010334a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103351:	e9 95 00 00 00       	jmp    801033eb <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103356:	8b 15 94 71 11 80    	mov    0x80117194,%edx
8010335c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010335f:	01 d0                	add    %edx,%eax
80103361:	83 c0 01             	add    $0x1,%eax
80103364:	89 c2                	mov    %eax,%edx
80103366:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010336b:	83 ec 08             	sub    $0x8,%esp
8010336e:	52                   	push   %edx
8010336f:	50                   	push   %eax
80103370:	e8 8c ce ff ff       	call   80100201 <bread>
80103375:	83 c4 10             	add    $0x10,%esp
80103378:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010337b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337e:	83 c0 10             	add    $0x10,%eax
80103381:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103388:	89 c2                	mov    %eax,%edx
8010338a:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010338f:	83 ec 08             	sub    $0x8,%esp
80103392:	52                   	push   %edx
80103393:	50                   	push   %eax
80103394:	e8 68 ce ff ff       	call   80100201 <bread>
80103399:	83 c4 10             	add    $0x10,%esp
8010339c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010339f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033a2:	8d 50 5c             	lea    0x5c(%eax),%edx
801033a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a8:	83 c0 5c             	add    $0x5c,%eax
801033ab:	83 ec 04             	sub    $0x4,%esp
801033ae:	68 00 02 00 00       	push   $0x200
801033b3:	52                   	push   %edx
801033b4:	50                   	push   %eax
801033b5:	e8 a2 1c 00 00       	call   8010505c <memmove>
801033ba:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033bd:	83 ec 0c             	sub    $0xc,%esp
801033c0:	ff 75 ec             	push   -0x14(%ebp)
801033c3:	e8 72 ce ff ff       	call   8010023a <bwrite>
801033c8:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033cb:	83 ec 0c             	sub    $0xc,%esp
801033ce:	ff 75 f0             	push   -0x10(%ebp)
801033d1:	e8 ad ce ff ff       	call   80100283 <brelse>
801033d6:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033d9:	83 ec 0c             	sub    $0xc,%esp
801033dc:	ff 75 ec             	push   -0x14(%ebp)
801033df:	e8 9f ce ff ff       	call   80100283 <brelse>
801033e4:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033eb:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033f3:	0f 8c 5d ff ff ff    	jl     80103356 <install_trans+0x12>
  }
}
801033f9:	90                   	nop
801033fa:	90                   	nop
801033fb:	c9                   	leave  
801033fc:	c3                   	ret    

801033fd <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033fd:	55                   	push   %ebp
801033fe:	89 e5                	mov    %esp,%ebp
80103400:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103403:	a1 94 71 11 80       	mov    0x80117194,%eax
80103408:	89 c2                	mov    %eax,%edx
8010340a:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010340f:	83 ec 08             	sub    $0x8,%esp
80103412:	52                   	push   %edx
80103413:	50                   	push   %eax
80103414:	e8 e8 cd ff ff       	call   80100201 <bread>
80103419:	83 c4 10             	add    $0x10,%esp
8010341c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010341f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103422:	83 c0 5c             	add    $0x5c,%eax
80103425:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103428:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342b:	8b 00                	mov    (%eax),%eax
8010342d:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
80103432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103439:	eb 1b                	jmp    80103456 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010343b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010343e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103441:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103445:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103448:	83 c2 10             	add    $0x10,%edx
8010344b:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103452:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103456:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010345b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010345e:	7c db                	jl     8010343b <read_head+0x3e>
  }
  brelse(buf);
80103460:	83 ec 0c             	sub    $0xc,%esp
80103463:	ff 75 f0             	push   -0x10(%ebp)
80103466:	e8 18 ce ff ff       	call   80100283 <brelse>
8010346b:	83 c4 10             	add    $0x10,%esp
}
8010346e:	90                   	nop
8010346f:	c9                   	leave  
80103470:	c3                   	ret    

80103471 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103471:	55                   	push   %ebp
80103472:	89 e5                	mov    %esp,%ebp
80103474:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103477:	a1 94 71 11 80       	mov    0x80117194,%eax
8010347c:	89 c2                	mov    %eax,%edx
8010347e:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103483:	83 ec 08             	sub    $0x8,%esp
80103486:	52                   	push   %edx
80103487:	50                   	push   %eax
80103488:	e8 74 cd ff ff       	call   80100201 <bread>
8010348d:	83 c4 10             	add    $0x10,%esp
80103490:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103496:	83 c0 5c             	add    $0x5c,%eax
80103499:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010349c:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ae:	eb 1b                	jmp    801034cb <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b3:	83 c0 10             	add    $0x10,%eax
801034b6:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c3:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034cb:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034d3:	7c db                	jl     801034b0 <write_head+0x3f>
  }
  bwrite(buf);
801034d5:	83 ec 0c             	sub    $0xc,%esp
801034d8:	ff 75 f0             	push   -0x10(%ebp)
801034db:	e8 5a cd ff ff       	call   8010023a <bwrite>
801034e0:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034e3:	83 ec 0c             	sub    $0xc,%esp
801034e6:	ff 75 f0             	push   -0x10(%ebp)
801034e9:	e8 95 cd ff ff       	call   80100283 <brelse>
801034ee:	83 c4 10             	add    $0x10,%esp
}
801034f1:	90                   	nop
801034f2:	c9                   	leave  
801034f3:	c3                   	ret    

801034f4 <recover_from_log>:

static void
recover_from_log(void)
{
801034f4:	55                   	push   %ebp
801034f5:	89 e5                	mov    %esp,%ebp
801034f7:	83 ec 08             	sub    $0x8,%esp
  read_head();
801034fa:	e8 fe fe ff ff       	call   801033fd <read_head>
  install_trans(); // if committed, copy from log to disk
801034ff:	e8 40 fe ff ff       	call   80103344 <install_trans>
  log.lh.n = 0;
80103504:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010350b:	00 00 00 
  write_head(); // clear the log
8010350e:	e8 5e ff ff ff       	call   80103471 <write_head>
}
80103513:	90                   	nop
80103514:	c9                   	leave  
80103515:	c3                   	ret    

80103516 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103516:	55                   	push   %ebp
80103517:	89 e5                	mov    %esp,%ebp
80103519:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010351c:	83 ec 0c             	sub    $0xc,%esp
8010351f:	68 60 71 11 80       	push   $0x80117160
80103524:	e8 fe 17 00 00       	call   80104d27 <acquire>
80103529:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010352c:	a1 a0 71 11 80       	mov    0x801171a0,%eax
80103531:	85 c0                	test   %eax,%eax
80103533:	74 17                	je     8010354c <begin_op+0x36>
      sleep(&log, &log.lock);
80103535:	83 ec 08             	sub    $0x8,%esp
80103538:	68 60 71 11 80       	push   $0x80117160
8010353d:	68 60 71 11 80       	push   $0x80117160
80103542:	e8 6c 12 00 00       	call   801047b3 <sleep>
80103547:	83 c4 10             	add    $0x10,%esp
8010354a:	eb e0                	jmp    8010352c <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010354c:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
80103552:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103557:	8d 50 01             	lea    0x1(%eax),%edx
8010355a:	89 d0                	mov    %edx,%eax
8010355c:	c1 e0 02             	shl    $0x2,%eax
8010355f:	01 d0                	add    %edx,%eax
80103561:	01 c0                	add    %eax,%eax
80103563:	01 c8                	add    %ecx,%eax
80103565:	83 f8 1e             	cmp    $0x1e,%eax
80103568:	7e 17                	jle    80103581 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010356a:	83 ec 08             	sub    $0x8,%esp
8010356d:	68 60 71 11 80       	push   $0x80117160
80103572:	68 60 71 11 80       	push   $0x80117160
80103577:	e8 37 12 00 00       	call   801047b3 <sleep>
8010357c:	83 c4 10             	add    $0x10,%esp
8010357f:	eb ab                	jmp    8010352c <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103581:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103586:	83 c0 01             	add    $0x1,%eax
80103589:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
8010358e:	83 ec 0c             	sub    $0xc,%esp
80103591:	68 60 71 11 80       	push   $0x80117160
80103596:	e8 fa 17 00 00       	call   80104d95 <release>
8010359b:	83 c4 10             	add    $0x10,%esp
      break;
8010359e:	90                   	nop
    }
  }
}
8010359f:	90                   	nop
801035a0:	c9                   	leave  
801035a1:	c3                   	ret    

801035a2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035a2:	55                   	push   %ebp
801035a3:	89 e5                	mov    %esp,%ebp
801035a5:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035af:	83 ec 0c             	sub    $0xc,%esp
801035b2:	68 60 71 11 80       	push   $0x80117160
801035b7:	e8 6b 17 00 00       	call   80104d27 <acquire>
801035bc:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035bf:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035c4:	83 e8 01             	sub    $0x1,%eax
801035c7:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035cc:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035d1:	85 c0                	test   %eax,%eax
801035d3:	74 0d                	je     801035e2 <end_op+0x40>
    panic("log.committing");
801035d5:	83 ec 0c             	sub    $0xc,%esp
801035d8:	68 1d a9 10 80       	push   $0x8010a91d
801035dd:	e8 c7 cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035e2:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035e7:	85 c0                	test   %eax,%eax
801035e9:	75 13                	jne    801035fe <end_op+0x5c>
    do_commit = 1;
801035eb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035f2:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
801035f9:	00 00 00 
801035fc:	eb 10                	jmp    8010360e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801035fe:	83 ec 0c             	sub    $0xc,%esp
80103601:	68 60 71 11 80       	push   $0x80117160
80103606:	e8 8f 12 00 00       	call   8010489a <wakeup>
8010360b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010360e:	83 ec 0c             	sub    $0xc,%esp
80103611:	68 60 71 11 80       	push   $0x80117160
80103616:	e8 7a 17 00 00       	call   80104d95 <release>
8010361b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010361e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103622:	74 3f                	je     80103663 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103624:	e8 f6 00 00 00       	call   8010371f <commit>
    acquire(&log.lock);
80103629:	83 ec 0c             	sub    $0xc,%esp
8010362c:	68 60 71 11 80       	push   $0x80117160
80103631:	e8 f1 16 00 00       	call   80104d27 <acquire>
80103636:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103639:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
80103640:	00 00 00 
    wakeup(&log);
80103643:	83 ec 0c             	sub    $0xc,%esp
80103646:	68 60 71 11 80       	push   $0x80117160
8010364b:	e8 4a 12 00 00       	call   8010489a <wakeup>
80103650:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103653:	83 ec 0c             	sub    $0xc,%esp
80103656:	68 60 71 11 80       	push   $0x80117160
8010365b:	e8 35 17 00 00       	call   80104d95 <release>
80103660:	83 c4 10             	add    $0x10,%esp
  }
}
80103663:	90                   	nop
80103664:	c9                   	leave  
80103665:	c3                   	ret    

80103666 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103666:	55                   	push   %ebp
80103667:	89 e5                	mov    %esp,%ebp
80103669:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010366c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103673:	e9 95 00 00 00       	jmp    8010370d <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103678:	8b 15 94 71 11 80    	mov    0x80117194,%edx
8010367e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103681:	01 d0                	add    %edx,%eax
80103683:	83 c0 01             	add    $0x1,%eax
80103686:	89 c2                	mov    %eax,%edx
80103688:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010368d:	83 ec 08             	sub    $0x8,%esp
80103690:	52                   	push   %edx
80103691:	50                   	push   %eax
80103692:	e8 6a cb ff ff       	call   80100201 <bread>
80103697:	83 c4 10             	add    $0x10,%esp
8010369a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010369d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a0:	83 c0 10             	add    $0x10,%eax
801036a3:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036aa:	89 c2                	mov    %eax,%edx
801036ac:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036b1:	83 ec 08             	sub    $0x8,%esp
801036b4:	52                   	push   %edx
801036b5:	50                   	push   %eax
801036b6:	e8 46 cb ff ff       	call   80100201 <bread>
801036bb:	83 c4 10             	add    $0x10,%esp
801036be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036c4:	8d 50 5c             	lea    0x5c(%eax),%edx
801036c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ca:	83 c0 5c             	add    $0x5c,%eax
801036cd:	83 ec 04             	sub    $0x4,%esp
801036d0:	68 00 02 00 00       	push   $0x200
801036d5:	52                   	push   %edx
801036d6:	50                   	push   %eax
801036d7:	e8 80 19 00 00       	call   8010505c <memmove>
801036dc:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036df:	83 ec 0c             	sub    $0xc,%esp
801036e2:	ff 75 f0             	push   -0x10(%ebp)
801036e5:	e8 50 cb ff ff       	call   8010023a <bwrite>
801036ea:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036ed:	83 ec 0c             	sub    $0xc,%esp
801036f0:	ff 75 ec             	push   -0x14(%ebp)
801036f3:	e8 8b cb ff ff       	call   80100283 <brelse>
801036f8:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	ff 75 f0             	push   -0x10(%ebp)
80103701:	e8 7d cb ff ff       	call   80100283 <brelse>
80103706:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103709:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010370d:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103712:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103715:	0f 8c 5d ff ff ff    	jl     80103678 <write_log+0x12>
  }
}
8010371b:	90                   	nop
8010371c:	90                   	nop
8010371d:	c9                   	leave  
8010371e:	c3                   	ret    

8010371f <commit>:

static void
commit()
{
8010371f:	55                   	push   %ebp
80103720:	89 e5                	mov    %esp,%ebp
80103722:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103725:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010372a:	85 c0                	test   %eax,%eax
8010372c:	7e 1e                	jle    8010374c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010372e:	e8 33 ff ff ff       	call   80103666 <write_log>
    write_head();    // Write header to disk -- the real commit
80103733:	e8 39 fd ff ff       	call   80103471 <write_head>
    install_trans(); // Now install writes to home locations
80103738:	e8 07 fc ff ff       	call   80103344 <install_trans>
    log.lh.n = 0;
8010373d:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103744:	00 00 00 
    write_head();    // Erase the transaction from the log
80103747:	e8 25 fd ff ff       	call   80103471 <write_head>
  }
}
8010374c:	90                   	nop
8010374d:	c9                   	leave  
8010374e:	c3                   	ret    

8010374f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010374f:	55                   	push   %ebp
80103750:	89 e5                	mov    %esp,%ebp
80103752:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103755:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010375a:	83 f8 1d             	cmp    $0x1d,%eax
8010375d:	7f 12                	jg     80103771 <log_write+0x22>
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	8b 15 98 71 11 80    	mov    0x80117198,%edx
8010376a:	83 ea 01             	sub    $0x1,%edx
8010376d:	39 d0                	cmp    %edx,%eax
8010376f:	7c 0d                	jl     8010377e <log_write+0x2f>
    panic("too big a transaction");
80103771:	83 ec 0c             	sub    $0xc,%esp
80103774:	68 2c a9 10 80       	push   $0x8010a92c
80103779:	e8 2b ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
8010377e:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103783:	85 c0                	test   %eax,%eax
80103785:	7f 0d                	jg     80103794 <log_write+0x45>
    panic("log_write outside of trans");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 42 a9 10 80       	push   $0x8010a942
8010378f:	e8 15 ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	68 60 71 11 80       	push   $0x80117160
8010379c:	e8 86 15 00 00       	call   80104d27 <acquire>
801037a1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037ab:	eb 1d                	jmp    801037ca <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b0:	83 c0 10             	add    $0x10,%eax
801037b3:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037ba:	89 c2                	mov    %eax,%edx
801037bc:	8b 45 08             	mov    0x8(%ebp),%eax
801037bf:	8b 40 08             	mov    0x8(%eax),%eax
801037c2:	39 c2                	cmp    %eax,%edx
801037c4:	74 10                	je     801037d6 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037ca:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037d2:	7c d9                	jl     801037ad <log_write+0x5e>
801037d4:	eb 01                	jmp    801037d7 <log_write+0x88>
      break;
801037d6:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 40 08             	mov    0x8(%eax),%eax
801037dd:	89 c2                	mov    %eax,%edx
801037df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e2:	83 c0 10             	add    $0x10,%eax
801037e5:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037ec:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037f1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037f4:	75 0d                	jne    80103803 <log_write+0xb4>
    log.lh.n++;
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	83 c0 01             	add    $0x1,%eax
801037fe:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
80103803:	8b 45 08             	mov    0x8(%ebp),%eax
80103806:	8b 00                	mov    (%eax),%eax
80103808:	83 c8 04             	or     $0x4,%eax
8010380b:	89 c2                	mov    %eax,%edx
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103812:	83 ec 0c             	sub    $0xc,%esp
80103815:	68 60 71 11 80       	push   $0x80117160
8010381a:	e8 76 15 00 00       	call   80104d95 <release>
8010381f:	83 c4 10             	add    $0x10,%esp
}
80103822:	90                   	nop
80103823:	c9                   	leave  
80103824:	c3                   	ret    

80103825 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103825:	55                   	push   %ebp
80103826:	89 e5                	mov    %esp,%ebp
80103828:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010382b:	8b 55 08             	mov    0x8(%ebp),%edx
8010382e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103831:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103834:	f0 87 02             	lock xchg %eax,(%edx)
80103837:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010383a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010383d:	c9                   	leave  
8010383e:	c3                   	ret    

8010383f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010383f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103843:	83 e4 f0             	and    $0xfffffff0,%esp
80103846:	ff 71 fc             	push   -0x4(%ecx)
80103849:	55                   	push   %ebp
8010384a:	89 e5                	mov    %esp,%ebp
8010384c:	51                   	push   %ecx
8010384d:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103850:	e8 c8 4c 00 00       	call   8010851d <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103855:	83 ec 08             	sub    $0x8,%esp
80103858:	68 00 00 40 80       	push   $0x80400000
8010385d:	68 00 b0 11 80       	push   $0x8011b000
80103862:	e8 de f2 ff ff       	call   80102b45 <kinit1>
80103867:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010386a:	e8 ad 42 00 00       	call   80107b1c <kvmalloc>
  mpinit_uefi();
8010386f:	e8 6f 4a 00 00       	call   801082e3 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103874:	e8 3c f6 ff ff       	call   80102eb5 <lapicinit>
  seginit();       // segment descriptors
80103879:	e8 36 3d 00 00       	call   801075b4 <seginit>
  picinit();    // disable pic
8010387e:	e8 9d 01 00 00       	call   80103a20 <picinit>
  ioapicinit();    // another interrupt controller
80103883:	e8 d8 f1 ff ff       	call   80102a60 <ioapicinit>
  consoleinit();   // console hardware
80103888:	e8 72 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
8010388d:	e8 bb 30 00 00       	call   8010694d <uartinit>
  pinit();         // process table
80103892:	e8 c2 05 00 00       	call   80103e59 <pinit>
  tvinit();        // trap vectors
80103897:	e8 7a 2b 00 00       	call   80106416 <tvinit>
  binit();         // buffer cache
8010389c:	e8 c5 c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038a1:	e8 0f d7 ff ff       	call   80100fb5 <fileinit>
  ideinit();       // disk 
801038a6:	e8 6e ed ff ff       	call   80102619 <ideinit>
  startothers();   // start other processors
801038ab:	e8 8a 00 00 00       	call   8010393a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038b0:	83 ec 08             	sub    $0x8,%esp
801038b3:	68 00 00 00 a0       	push   $0xa0000000
801038b8:	68 00 00 40 80       	push   $0x80400000
801038bd:	e8 bc f2 ff ff       	call   80102b7e <kinit2>
801038c2:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038c5:	e8 ac 4e 00 00       	call   80108776 <pci_init>
  arp_scan();
801038ca:	e8 e3 5b 00 00       	call   801094b2 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038cf:	e8 63 07 00 00       	call   80104037 <userinit>

  mpmain();        // finish this processor's setup
801038d4:	e8 1a 00 00 00       	call   801038f3 <mpmain>

801038d9 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038d9:	55                   	push   %ebp
801038da:	89 e5                	mov    %esp,%ebp
801038dc:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038df:	e8 50 42 00 00       	call   80107b34 <switchkvm>
  seginit();
801038e4:	e8 cb 3c 00 00       	call   801075b4 <seginit>
  lapicinit();
801038e9:	e8 c7 f5 ff ff       	call   80102eb5 <lapicinit>
  mpmain();
801038ee:	e8 00 00 00 00       	call   801038f3 <mpmain>

801038f3 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038f3:	55                   	push   %ebp
801038f4:	89 e5                	mov    %esp,%ebp
801038f6:	53                   	push   %ebx
801038f7:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038fa:	e8 78 05 00 00       	call   80103e77 <cpuid>
801038ff:	89 c3                	mov    %eax,%ebx
80103901:	e8 71 05 00 00       	call   80103e77 <cpuid>
80103906:	83 ec 04             	sub    $0x4,%esp
80103909:	53                   	push   %ebx
8010390a:	50                   	push   %eax
8010390b:	68 5d a9 10 80       	push   $0x8010a95d
80103910:	e8 df ca ff ff       	call   801003f4 <cprintf>
80103915:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103918:	e8 6f 2c 00 00       	call   8010658c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010391d:	e8 70 05 00 00       	call   80103e92 <mycpu>
80103922:	05 a0 00 00 00       	add    $0xa0,%eax
80103927:	83 ec 08             	sub    $0x8,%esp
8010392a:	6a 01                	push   $0x1
8010392c:	50                   	push   %eax
8010392d:	e8 f3 fe ff ff       	call   80103825 <xchg>
80103932:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103935:	e8 88 0c 00 00       	call   801045c2 <scheduler>

8010393a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010393a:	55                   	push   %ebp
8010393b:	89 e5                	mov    %esp,%ebp
8010393d:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103940:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103947:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010394c:	83 ec 04             	sub    $0x4,%esp
8010394f:	50                   	push   %eax
80103950:	68 18 f5 10 80       	push   $0x8010f518
80103955:	ff 75 f0             	push   -0x10(%ebp)
80103958:	e8 ff 16 00 00       	call   8010505c <memmove>
8010395d:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103960:	c7 45 f4 c0 99 11 80 	movl   $0x801199c0,-0xc(%ebp)
80103967:	eb 79                	jmp    801039e2 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103969:	e8 24 05 00 00       	call   80103e92 <mycpu>
8010396e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103971:	74 67                	je     801039da <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103973:	e8 02 f3 ff ff       	call   80102c7a <kalloc>
80103978:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010397b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010397e:	83 e8 04             	sub    $0x4,%eax
80103981:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103984:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010398a:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010398c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398f:	83 e8 08             	sub    $0x8,%eax
80103992:	c7 00 d9 38 10 80    	movl   $0x801038d9,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103998:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010399d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a6:	83 e8 0c             	sub    $0xc,%eax
801039a9:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ae:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b7:	0f b6 00             	movzbl (%eax),%eax
801039ba:	0f b6 c0             	movzbl %al,%eax
801039bd:	83 ec 08             	sub    $0x8,%esp
801039c0:	52                   	push   %edx
801039c1:	50                   	push   %eax
801039c2:	e8 50 f6 ff ff       	call   80103017 <lapicstartap>
801039c7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039ca:	90                   	nop
801039cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ce:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039d4:	85 c0                	test   %eax,%eax
801039d6:	74 f3                	je     801039cb <startothers+0x91>
801039d8:	eb 01                	jmp    801039db <startothers+0xa1>
      continue;
801039da:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039db:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039e2:	a1 80 9c 11 80       	mov    0x80119c80,%eax
801039e7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039ed:	05 c0 99 11 80       	add    $0x801199c0,%eax
801039f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039f5:	0f 82 6e ff ff ff    	jb     80103969 <startothers+0x2f>
      ;
  }
}
801039fb:	90                   	nop
801039fc:	90                   	nop
801039fd:	c9                   	leave  
801039fe:	c3                   	ret    

801039ff <outb>:
{
801039ff:	55                   	push   %ebp
80103a00:	89 e5                	mov    %esp,%ebp
80103a02:	83 ec 08             	sub    $0x8,%esp
80103a05:	8b 45 08             	mov    0x8(%ebp),%eax
80103a08:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a0b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a0f:	89 d0                	mov    %edx,%eax
80103a11:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a14:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a18:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a1c:	ee                   	out    %al,(%dx)
}
80103a1d:	90                   	nop
80103a1e:	c9                   	leave  
80103a1f:	c3                   	ret    

80103a20 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a23:	68 ff 00 00 00       	push   $0xff
80103a28:	6a 21                	push   $0x21
80103a2a:	e8 d0 ff ff ff       	call   801039ff <outb>
80103a2f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a32:	68 ff 00 00 00       	push   $0xff
80103a37:	68 a1 00 00 00       	push   $0xa1
80103a3c:	e8 be ff ff ff       	call   801039ff <outb>
80103a41:	83 c4 08             	add    $0x8,%esp
}
80103a44:	90                   	nop
80103a45:	c9                   	leave  
80103a46:	c3                   	ret    

80103a47 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a47:	55                   	push   %ebp
80103a48:	89 e5                	mov    %esp,%ebp
80103a4a:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a54:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a60:	8b 10                	mov    (%eax),%edx
80103a62:	8b 45 08             	mov    0x8(%ebp),%eax
80103a65:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a67:	e8 67 d5 ff ff       	call   80100fd3 <filealloc>
80103a6c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a6f:	89 02                	mov    %eax,(%edx)
80103a71:	8b 45 08             	mov    0x8(%ebp),%eax
80103a74:	8b 00                	mov    (%eax),%eax
80103a76:	85 c0                	test   %eax,%eax
80103a78:	0f 84 c8 00 00 00    	je     80103b46 <pipealloc+0xff>
80103a7e:	e8 50 d5 ff ff       	call   80100fd3 <filealloc>
80103a83:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a86:	89 02                	mov    %eax,(%edx)
80103a88:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a8b:	8b 00                	mov    (%eax),%eax
80103a8d:	85 c0                	test   %eax,%eax
80103a8f:	0f 84 b1 00 00 00    	je     80103b46 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a95:	e8 e0 f1 ff ff       	call   80102c7a <kalloc>
80103a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aa1:	0f 84 a2 00 00 00    	je     80103b49 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaa:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ab1:	00 00 00 
  p->writeopen = 1;
80103ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab7:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103abe:	00 00 00 
  p->nwrite = 0;
80103ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac4:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103acb:	00 00 00 
  p->nread = 0;
80103ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad1:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ad8:	00 00 00 
  initlock(&p->lock, "pipe");
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	83 ec 08             	sub    $0x8,%esp
80103ae1:	68 71 a9 10 80       	push   $0x8010a971
80103ae6:	50                   	push   %eax
80103ae7:	e8 19 12 00 00       	call   80104d05 <initlock>
80103aec:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103aef:	8b 45 08             	mov    0x8(%ebp),%eax
80103af2:	8b 00                	mov    (%eax),%eax
80103af4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103afa:	8b 45 08             	mov    0x8(%ebp),%eax
80103afd:	8b 00                	mov    (%eax),%eax
80103aff:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b03:	8b 45 08             	mov    0x8(%ebp),%eax
80103b06:	8b 00                	mov    (%eax),%eax
80103b08:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0f:	8b 00                	mov    (%eax),%eax
80103b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b14:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b1a:	8b 00                	mov    (%eax),%eax
80103b1c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b25:	8b 00                	mov    (%eax),%eax
80103b27:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2e:	8b 00                	mov    (%eax),%eax
80103b30:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b34:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b37:	8b 00                	mov    (%eax),%eax
80103b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b3c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b3f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b44:	eb 51                	jmp    80103b97 <pipealloc+0x150>
    goto bad;
80103b46:	90                   	nop
80103b47:	eb 01                	jmp    80103b4a <pipealloc+0x103>
    goto bad;
80103b49:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b4e:	74 0e                	je     80103b5e <pipealloc+0x117>
    kfree((char*)p);
80103b50:	83 ec 0c             	sub    $0xc,%esp
80103b53:	ff 75 f4             	push   -0xc(%ebp)
80103b56:	e8 85 f0 ff ff       	call   80102be0 <kfree>
80103b5b:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b61:	8b 00                	mov    (%eax),%eax
80103b63:	85 c0                	test   %eax,%eax
80103b65:	74 11                	je     80103b78 <pipealloc+0x131>
    fileclose(*f0);
80103b67:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6a:	8b 00                	mov    (%eax),%eax
80103b6c:	83 ec 0c             	sub    $0xc,%esp
80103b6f:	50                   	push   %eax
80103b70:	e8 1c d5 ff ff       	call   80101091 <fileclose>
80103b75:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b78:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b7b:	8b 00                	mov    (%eax),%eax
80103b7d:	85 c0                	test   %eax,%eax
80103b7f:	74 11                	je     80103b92 <pipealloc+0x14b>
    fileclose(*f1);
80103b81:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b84:	8b 00                	mov    (%eax),%eax
80103b86:	83 ec 0c             	sub    $0xc,%esp
80103b89:	50                   	push   %eax
80103b8a:	e8 02 d5 ff ff       	call   80101091 <fileclose>
80103b8f:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b97:	c9                   	leave  
80103b98:	c3                   	ret    

80103b99 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103b99:	55                   	push   %ebp
80103b9a:	89 e5                	mov    %esp,%ebp
80103b9c:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba2:	83 ec 0c             	sub    $0xc,%esp
80103ba5:	50                   	push   %eax
80103ba6:	e8 7c 11 00 00       	call   80104d27 <acquire>
80103bab:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bb2:	74 23                	je     80103bd7 <pipeclose+0x3e>
    p->writeopen = 0;
80103bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb7:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bbe:	00 00 00 
    wakeup(&p->nread);
80103bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc4:	05 34 02 00 00       	add    $0x234,%eax
80103bc9:	83 ec 0c             	sub    $0xc,%esp
80103bcc:	50                   	push   %eax
80103bcd:	e8 c8 0c 00 00       	call   8010489a <wakeup>
80103bd2:	83 c4 10             	add    $0x10,%esp
80103bd5:	eb 21                	jmp    80103bf8 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80103bda:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103be1:	00 00 00 
    wakeup(&p->nwrite);
80103be4:	8b 45 08             	mov    0x8(%ebp),%eax
80103be7:	05 38 02 00 00       	add    $0x238,%eax
80103bec:	83 ec 0c             	sub    $0xc,%esp
80103bef:	50                   	push   %eax
80103bf0:	e8 a5 0c 00 00       	call   8010489a <wakeup>
80103bf5:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bfb:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c01:	85 c0                	test   %eax,%eax
80103c03:	75 2c                	jne    80103c31 <pipeclose+0x98>
80103c05:	8b 45 08             	mov    0x8(%ebp),%eax
80103c08:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c0e:	85 c0                	test   %eax,%eax
80103c10:	75 1f                	jne    80103c31 <pipeclose+0x98>
    release(&p->lock);
80103c12:	8b 45 08             	mov    0x8(%ebp),%eax
80103c15:	83 ec 0c             	sub    $0xc,%esp
80103c18:	50                   	push   %eax
80103c19:	e8 77 11 00 00       	call   80104d95 <release>
80103c1e:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c21:	83 ec 0c             	sub    $0xc,%esp
80103c24:	ff 75 08             	push   0x8(%ebp)
80103c27:	e8 b4 ef ff ff       	call   80102be0 <kfree>
80103c2c:	83 c4 10             	add    $0x10,%esp
80103c2f:	eb 10                	jmp    80103c41 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c31:	8b 45 08             	mov    0x8(%ebp),%eax
80103c34:	83 ec 0c             	sub    $0xc,%esp
80103c37:	50                   	push   %eax
80103c38:	e8 58 11 00 00       	call   80104d95 <release>
80103c3d:	83 c4 10             	add    $0x10,%esp
}
80103c40:	90                   	nop
80103c41:	90                   	nop
80103c42:	c9                   	leave  
80103c43:	c3                   	ret    

80103c44 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c44:	55                   	push   %ebp
80103c45:	89 e5                	mov    %esp,%ebp
80103c47:	53                   	push   %ebx
80103c48:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	50                   	push   %eax
80103c52:	e8 d0 10 00 00       	call   80104d27 <acquire>
80103c57:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c61:	e9 ad 00 00 00       	jmp    80103d13 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c66:	8b 45 08             	mov    0x8(%ebp),%eax
80103c69:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c6f:	85 c0                	test   %eax,%eax
80103c71:	74 0c                	je     80103c7f <pipewrite+0x3b>
80103c73:	e8 92 02 00 00       	call   80103f0a <myproc>
80103c78:	8b 40 24             	mov    0x24(%eax),%eax
80103c7b:	85 c0                	test   %eax,%eax
80103c7d:	74 19                	je     80103c98 <pipewrite+0x54>
        release(&p->lock);
80103c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c82:	83 ec 0c             	sub    $0xc,%esp
80103c85:	50                   	push   %eax
80103c86:	e8 0a 11 00 00       	call   80104d95 <release>
80103c8b:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c93:	e9 a9 00 00 00       	jmp    80103d41 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103c98:	8b 45 08             	mov    0x8(%ebp),%eax
80103c9b:	05 34 02 00 00       	add    $0x234,%eax
80103ca0:	83 ec 0c             	sub    $0xc,%esp
80103ca3:	50                   	push   %eax
80103ca4:	e8 f1 0b 00 00       	call   8010489a <wakeup>
80103ca9:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cac:	8b 45 08             	mov    0x8(%ebp),%eax
80103caf:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb2:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cb8:	83 ec 08             	sub    $0x8,%esp
80103cbb:	50                   	push   %eax
80103cbc:	52                   	push   %edx
80103cbd:	e8 f1 0a 00 00       	call   801047b3 <sleep>
80103cc2:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cce:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103cd7:	05 00 02 00 00       	add    $0x200,%eax
80103cdc:	39 c2                	cmp    %eax,%edx
80103cde:	74 86                	je     80103c66 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ce0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cec:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cf2:	8d 48 01             	lea    0x1(%eax),%ecx
80103cf5:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103cfe:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d03:	89 c1                	mov    %eax,%ecx
80103d05:	0f b6 13             	movzbl (%ebx),%edx
80103d08:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0b:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d16:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d19:	7c aa                	jl     80103cc5 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1e:	05 34 02 00 00       	add    $0x234,%eax
80103d23:	83 ec 0c             	sub    $0xc,%esp
80103d26:	50                   	push   %eax
80103d27:	e8 6e 0b 00 00       	call   8010489a <wakeup>
80103d2c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d32:	83 ec 0c             	sub    $0xc,%esp
80103d35:	50                   	push   %eax
80103d36:	e8 5a 10 00 00       	call   80104d95 <release>
80103d3b:	83 c4 10             	add    $0x10,%esp
  return n;
80103d3e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d44:	c9                   	leave  
80103d45:	c3                   	ret    

80103d46 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d46:	55                   	push   %ebp
80103d47:	89 e5                	mov    %esp,%ebp
80103d49:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4f:	83 ec 0c             	sub    $0xc,%esp
80103d52:	50                   	push   %eax
80103d53:	e8 cf 0f 00 00       	call   80104d27 <acquire>
80103d58:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d5b:	eb 3e                	jmp    80103d9b <piperead+0x55>
    if(myproc()->killed){
80103d5d:	e8 a8 01 00 00       	call   80103f0a <myproc>
80103d62:	8b 40 24             	mov    0x24(%eax),%eax
80103d65:	85 c0                	test   %eax,%eax
80103d67:	74 19                	je     80103d82 <piperead+0x3c>
      release(&p->lock);
80103d69:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6c:	83 ec 0c             	sub    $0xc,%esp
80103d6f:	50                   	push   %eax
80103d70:	e8 20 10 00 00       	call   80104d95 <release>
80103d75:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d7d:	e9 be 00 00 00       	jmp    80103e40 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d82:	8b 45 08             	mov    0x8(%ebp),%eax
80103d85:	8b 55 08             	mov    0x8(%ebp),%edx
80103d88:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d8e:	83 ec 08             	sub    $0x8,%esp
80103d91:	50                   	push   %eax
80103d92:	52                   	push   %edx
80103d93:	e8 1b 0a 00 00       	call   801047b3 <sleep>
80103d98:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103da4:	8b 45 08             	mov    0x8(%ebp),%eax
80103da7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103dad:	39 c2                	cmp    %eax,%edx
80103daf:	75 0d                	jne    80103dbe <piperead+0x78>
80103db1:	8b 45 08             	mov    0x8(%ebp),%eax
80103db4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dba:	85 c0                	test   %eax,%eax
80103dbc:	75 9f                	jne    80103d5d <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dc5:	eb 48                	jmp    80103e0f <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dca:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103dd9:	39 c2                	cmp    %eax,%edx
80103ddb:	74 3c                	je     80103e19 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80103de0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103de6:	8d 48 01             	lea    0x1(%eax),%ecx
80103de9:	8b 55 08             	mov    0x8(%ebp),%edx
80103dec:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103df2:	25 ff 01 00 00       	and    $0x1ff,%eax
80103df7:	89 c1                	mov    %eax,%ecx
80103df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dff:	01 c2                	add    %eax,%edx
80103e01:	8b 45 08             	mov    0x8(%ebp),%eax
80103e04:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e09:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e12:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e15:	7c b0                	jl     80103dc7 <piperead+0x81>
80103e17:	eb 01                	jmp    80103e1a <piperead+0xd4>
      break;
80103e19:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1d:	05 38 02 00 00       	add    $0x238,%eax
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	50                   	push   %eax
80103e26:	e8 6f 0a 00 00       	call   8010489a <wakeup>
80103e2b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e31:	83 ec 0c             	sub    $0xc,%esp
80103e34:	50                   	push   %eax
80103e35:	e8 5b 0f 00 00       	call   80104d95 <release>
80103e3a:	83 c4 10             	add    $0x10,%esp
  return i;
80103e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e40:	c9                   	leave  
80103e41:	c3                   	ret    

80103e42 <readeflags>:
{
80103e42:	55                   	push   %ebp
80103e43:	89 e5                	mov    %esp,%ebp
80103e45:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e48:	9c                   	pushf  
80103e49:	58                   	pop    %eax
80103e4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e50:	c9                   	leave  
80103e51:	c3                   	ret    

80103e52 <sti>:
{
80103e52:	55                   	push   %ebp
80103e53:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e55:	fb                   	sti    
}
80103e56:	90                   	nop
80103e57:	5d                   	pop    %ebp
80103e58:	c3                   	ret    

80103e59 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e59:	55                   	push   %ebp
80103e5a:	89 e5                	mov    %esp,%ebp
80103e5c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e5f:	83 ec 08             	sub    $0x8,%esp
80103e62:	68 78 a9 10 80       	push   $0x8010a978
80103e67:	68 40 72 11 80       	push   $0x80117240
80103e6c:	e8 94 0e 00 00       	call   80104d05 <initlock>
80103e71:	83 c4 10             	add    $0x10,%esp
}
80103e74:	90                   	nop
80103e75:	c9                   	leave  
80103e76:	c3                   	ret    

80103e77 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e77:	55                   	push   %ebp
80103e78:	89 e5                	mov    %esp,%ebp
80103e7a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e7d:	e8 10 00 00 00       	call   80103e92 <mycpu>
80103e82:	2d c0 99 11 80       	sub    $0x801199c0,%eax
80103e87:	c1 f8 04             	sar    $0x4,%eax
80103e8a:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e90:	c9                   	leave  
80103e91:	c3                   	ret    

80103e92 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e92:	55                   	push   %ebp
80103e93:	89 e5                	mov    %esp,%ebp
80103e95:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103e98:	e8 a5 ff ff ff       	call   80103e42 <readeflags>
80103e9d:	25 00 02 00 00       	and    $0x200,%eax
80103ea2:	85 c0                	test   %eax,%eax
80103ea4:	74 0d                	je     80103eb3 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103ea6:	83 ec 0c             	sub    $0xc,%esp
80103ea9:	68 80 a9 10 80       	push   $0x8010a980
80103eae:	e8 f6 c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103eb3:	e8 1c f1 ff ff       	call   80102fd4 <lapicid>
80103eb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ebb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ec2:	eb 2d                	jmp    80103ef1 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ecd:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103ed2:	0f b6 00             	movzbl (%eax),%eax
80103ed5:	0f b6 c0             	movzbl %al,%eax
80103ed8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103edb:	75 10                	jne    80103eed <mycpu+0x5b>
      return &cpus[i];
80103edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ee6:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103eeb:	eb 1b                	jmp    80103f08 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103eed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef1:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80103ef6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ef9:	7c c9                	jl     80103ec4 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	68 a6 a9 10 80       	push   $0x8010a9a6
80103f03:	e8 a1 c6 ff ff       	call   801005a9 <panic>
}
80103f08:	c9                   	leave  
80103f09:	c3                   	ret    

80103f0a <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f0a:	55                   	push   %ebp
80103f0b:	89 e5                	mov    %esp,%ebp
80103f0d:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f10:	e8 7d 0f 00 00       	call   80104e92 <pushcli>
  c = mycpu();
80103f15:	e8 78 ff ff ff       	call   80103e92 <mycpu>
80103f1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f20:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f29:	e8 b1 0f 00 00       	call   80104edf <popcli>
  return p;
80103f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f31:	c9                   	leave  
80103f32:	c3                   	ret    

80103f33 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f39:	83 ec 0c             	sub    $0xc,%esp
80103f3c:	68 40 72 11 80       	push   $0x80117240
80103f41:	e8 e1 0d 00 00       	call   80104d27 <acquire>
80103f46:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f49:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f50:	eb 0e                	jmp    80103f60 <allocproc+0x2d>
    if(p->state == UNUSED){
80103f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f55:	8b 40 0c             	mov    0xc(%eax),%eax
80103f58:	85 c0                	test   %eax,%eax
80103f5a:	74 27                	je     80103f83 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f5c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f60:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80103f67:	72 e9                	jb     80103f52 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f69:	83 ec 0c             	sub    $0xc,%esp
80103f6c:	68 40 72 11 80       	push   $0x80117240
80103f71:	e8 1f 0e 00 00       	call   80104d95 <release>
80103f76:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f79:	b8 00 00 00 00       	mov    $0x0,%eax
80103f7e:	e9 b2 00 00 00       	jmp    80104035 <allocproc+0x102>
      goto found;
80103f83:	90                   	nop

found:
  p->state = EMBRYO;
80103f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f87:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f8e:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f93:	8d 50 01             	lea    0x1(%eax),%edx
80103f96:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103f9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f9f:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103fa2:	83 ec 0c             	sub    $0xc,%esp
80103fa5:	68 40 72 11 80       	push   $0x80117240
80103faa:	e8 e6 0d 00 00       	call   80104d95 <release>
80103faf:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fb2:	e8 c3 ec ff ff       	call   80102c7a <kalloc>
80103fb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fba:	89 42 08             	mov    %eax,0x8(%edx)
80103fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc0:	8b 40 08             	mov    0x8(%eax),%eax
80103fc3:	85 c0                	test   %eax,%eax
80103fc5:	75 11                	jne    80103fd8 <allocproc+0xa5>
    p->state = UNUSED;
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fd1:	b8 00 00 00 00       	mov    $0x0,%eax
80103fd6:	eb 5d                	jmp    80104035 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdb:	8b 40 08             	mov    0x8(%eax),%eax
80103fde:	05 00 10 00 00       	add    $0x1000,%eax
80103fe3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103fe6:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fed:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ff0:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ff3:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103ff7:	ba c4 63 10 80       	mov    $0x801063c4,%edx
80103ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fff:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104001:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104008:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010400b:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010400e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104011:	8b 40 1c             	mov    0x1c(%eax),%eax
80104014:	83 ec 04             	sub    $0x4,%esp
80104017:	6a 14                	push   $0x14
80104019:	6a 00                	push   $0x0
8010401b:	50                   	push   %eax
8010401c:	e8 7c 0f 00 00       	call   80104f9d <memset>
80104021:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	8b 40 1c             	mov    0x1c(%eax),%eax
8010402a:	ba 6d 47 10 80       	mov    $0x8010476d,%edx
8010402f:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104032:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104035:	c9                   	leave  
80104036:	c3                   	ret    

80104037 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104037:	55                   	push   %ebp
80104038:	89 e5                	mov    %esp,%ebp
8010403a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010403d:	e8 f1 fe ff ff       	call   80103f33 <allocproc>
80104042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	a3 74 91 11 80       	mov    %eax,0x80119174
  if((p->pgdir = setupkvm()) == 0){
8010404d:	e8 de 39 00 00       	call   80107a30 <setupkvm>
80104052:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104055:	89 42 04             	mov    %eax,0x4(%edx)
80104058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405b:	8b 40 04             	mov    0x4(%eax),%eax
8010405e:	85 c0                	test   %eax,%eax
80104060:	75 0d                	jne    8010406f <userinit+0x38>
    panic("userinit: out of memory?");
80104062:	83 ec 0c             	sub    $0xc,%esp
80104065:	68 b6 a9 10 80       	push   $0x8010a9b6
8010406a:	e8 3a c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010406f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104077:	8b 40 04             	mov    0x4(%eax),%eax
8010407a:	83 ec 04             	sub    $0x4,%esp
8010407d:	52                   	push   %edx
8010407e:	68 ec f4 10 80       	push   $0x8010f4ec
80104083:	50                   	push   %eax
80104084:	e8 63 3c 00 00       	call   80107cec <inituvm>
80104089:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010408c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104098:	8b 40 18             	mov    0x18(%eax),%eax
8010409b:	83 ec 04             	sub    $0x4,%esp
8010409e:	6a 4c                	push   $0x4c
801040a0:	6a 00                	push   $0x0
801040a2:	50                   	push   %eax
801040a3:	e8 f5 0e 00 00       	call   80104f9d <memset>
801040a8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ae:	8b 40 18             	mov    0x18(%eax),%eax
801040b1:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ba:	8b 40 18             	mov    0x18(%eax),%eax
801040bd:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c6:	8b 50 18             	mov    0x18(%eax),%edx
801040c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cc:	8b 40 18             	mov    0x18(%eax),%eax
801040cf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040d3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040da:	8b 50 18             	mov    0x18(%eax),%edx
801040dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e0:	8b 40 18             	mov    0x18(%eax),%eax
801040e3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040e7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ee:	8b 40 18             	mov    0x18(%eax),%eax
801040f1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	8b 40 18             	mov    0x18(%eax),%eax
801040fe:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	8b 40 18             	mov    0x18(%eax),%eax
8010410b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	83 c0 6c             	add    $0x6c,%eax
80104118:	83 ec 04             	sub    $0x4,%esp
8010411b:	6a 10                	push   $0x10
8010411d:	68 cf a9 10 80       	push   $0x8010a9cf
80104122:	50                   	push   %eax
80104123:	e8 78 10 00 00       	call   801051a0 <safestrcpy>
80104128:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010412b:	83 ec 0c             	sub    $0xc,%esp
8010412e:	68 d8 a9 10 80       	push   $0x8010a9d8
80104133:	e8 db e3 ff ff       	call   80102513 <namei>
80104138:	83 c4 10             	add    $0x10,%esp
8010413b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413e:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104141:	83 ec 0c             	sub    $0xc,%esp
80104144:	68 40 72 11 80       	push   $0x80117240
80104149:	e8 d9 0b 00 00       	call   80104d27 <acquire>
8010414e:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104154:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010415b:	83 ec 0c             	sub    $0xc,%esp
8010415e:	68 40 72 11 80       	push   $0x80117240
80104163:	e8 2d 0c 00 00       	call   80104d95 <release>
80104168:	83 c4 10             	add    $0x10,%esp
}
8010416b:	90                   	nop
8010416c:	c9                   	leave  
8010416d:	c3                   	ret    

8010416e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010416e:	55                   	push   %ebp
8010416f:	89 e5                	mov    %esp,%ebp
80104171:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104174:	e8 91 fd ff ff       	call   80103f0a <myproc>
80104179:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
8010417c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417f:	8b 00                	mov    (%eax),%eax
80104181:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104184:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104188:	7e 2e                	jle    801041b8 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010418a:	8b 55 08             	mov    0x8(%ebp),%edx
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	01 c2                	add    %eax,%edx
80104192:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104195:	8b 40 04             	mov    0x4(%eax),%eax
80104198:	83 ec 04             	sub    $0x4,%esp
8010419b:	52                   	push   %edx
8010419c:	ff 75 f4             	push   -0xc(%ebp)
8010419f:	50                   	push   %eax
801041a0:	e8 84 3c 00 00       	call   80107e29 <allocuvm>
801041a5:	83 c4 10             	add    $0x10,%esp
801041a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041af:	75 3b                	jne    801041ec <growproc+0x7e>
      return -1;
801041b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b6:	eb 4f                	jmp    80104207 <growproc+0x99>
  } else if(n < 0){
801041b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041bc:	79 2e                	jns    801041ec <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041be:	8b 55 08             	mov    0x8(%ebp),%edx
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	01 c2                	add    %eax,%edx
801041c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041c9:	8b 40 04             	mov    0x4(%eax),%eax
801041cc:	83 ec 04             	sub    $0x4,%esp
801041cf:	52                   	push   %edx
801041d0:	ff 75 f4             	push   -0xc(%ebp)
801041d3:	50                   	push   %eax
801041d4:	e8 55 3d 00 00       	call   80107f2e <deallocuvm>
801041d9:	83 c4 10             	add    $0x10,%esp
801041dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041e3:	75 07                	jne    801041ec <growproc+0x7e>
      return -1;
801041e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ea:	eb 1b                	jmp    80104207 <growproc+0x99>
  }
  curproc->sz = sz;
801041ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f2:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	ff 75 f0             	push   -0x10(%ebp)
801041fa:	e8 4e 39 00 00       	call   80107b4d <switchuvm>
801041ff:	83 c4 10             	add    $0x10,%esp
  return 0;
80104202:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104207:	c9                   	leave  
80104208:	c3                   	ret    

80104209 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104209:	55                   	push   %ebp
8010420a:	89 e5                	mov    %esp,%ebp
8010420c:	57                   	push   %edi
8010420d:	56                   	push   %esi
8010420e:	53                   	push   %ebx
8010420f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104212:	e8 f3 fc ff ff       	call   80103f0a <myproc>
80104217:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010421a:	e8 14 fd ff ff       	call   80103f33 <allocproc>
8010421f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104222:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104226:	75 0a                	jne    80104232 <fork+0x29>
    return -1;
80104228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010422d:	e9 48 01 00 00       	jmp    8010437a <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104232:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104235:	8b 10                	mov    (%eax),%edx
80104237:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010423a:	8b 40 04             	mov    0x4(%eax),%eax
8010423d:	83 ec 08             	sub    $0x8,%esp
80104240:	52                   	push   %edx
80104241:	50                   	push   %eax
80104242:	e8 85 3e 00 00       	call   801080cc <copyuvm>
80104247:	83 c4 10             	add    $0x10,%esp
8010424a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010424d:	89 42 04             	mov    %eax,0x4(%edx)
80104250:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104253:	8b 40 04             	mov    0x4(%eax),%eax
80104256:	85 c0                	test   %eax,%eax
80104258:	75 30                	jne    8010428a <fork+0x81>
    kfree(np->kstack);
8010425a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425d:	8b 40 08             	mov    0x8(%eax),%eax
80104260:	83 ec 0c             	sub    $0xc,%esp
80104263:	50                   	push   %eax
80104264:	e8 77 e9 ff ff       	call   80102be0 <kfree>
80104269:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010426c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010426f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104276:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104279:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104285:	e9 f0 00 00 00       	jmp    8010437a <fork+0x171>
  }
  np->sz = curproc->sz;
8010428a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010428d:	8b 10                	mov    (%eax),%edx
8010428f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104292:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104294:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104297:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010429a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010429d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042a0:	8b 48 18             	mov    0x18(%eax),%ecx
801042a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a6:	8b 40 18             	mov    0x18(%eax),%eax
801042a9:	89 c2                	mov    %eax,%edx
801042ab:	89 cb                	mov    %ecx,%ebx
801042ad:	b8 13 00 00 00       	mov    $0x13,%eax
801042b2:	89 d7                	mov    %edx,%edi
801042b4:	89 de                	mov    %ebx,%esi
801042b6:	89 c1                	mov    %eax,%ecx
801042b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042bd:	8b 40 18             	mov    0x18(%eax),%eax
801042c0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042ce:	eb 3b                	jmp    8010430b <fork+0x102>
    if(curproc->ofile[i])
801042d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042d6:	83 c2 08             	add    $0x8,%edx
801042d9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042dd:	85 c0                	test   %eax,%eax
801042df:	74 26                	je     80104307 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042e7:	83 c2 08             	add    $0x8,%edx
801042ea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042ee:	83 ec 0c             	sub    $0xc,%esp
801042f1:	50                   	push   %eax
801042f2:	e8 49 cd ff ff       	call   80101040 <filedup>
801042f7:	83 c4 10             	add    $0x10,%esp
801042fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801042fd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104300:	83 c1 08             	add    $0x8,%ecx
80104303:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104307:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010430b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010430f:	7e bf                	jle    801042d0 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104311:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104314:	8b 40 68             	mov    0x68(%eax),%eax
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	50                   	push   %eax
8010431b:	e8 86 d6 ff ff       	call   801019a6 <idup>
80104320:	83 c4 10             	add    $0x10,%esp
80104323:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104326:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104329:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010432c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010432f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104332:	83 c0 6c             	add    $0x6c,%eax
80104335:	83 ec 04             	sub    $0x4,%esp
80104338:	6a 10                	push   $0x10
8010433a:	52                   	push   %edx
8010433b:	50                   	push   %eax
8010433c:	e8 5f 0e 00 00       	call   801051a0 <safestrcpy>
80104341:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104344:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104347:	8b 40 10             	mov    0x10(%eax),%eax
8010434a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010434d:	83 ec 0c             	sub    $0xc,%esp
80104350:	68 40 72 11 80       	push   $0x80117240
80104355:	e8 cd 09 00 00       	call   80104d27 <acquire>
8010435a:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010435d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104360:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104367:	83 ec 0c             	sub    $0xc,%esp
8010436a:	68 40 72 11 80       	push   $0x80117240
8010436f:	e8 21 0a 00 00       	call   80104d95 <release>
80104374:	83 c4 10             	add    $0x10,%esp

  return pid;
80104377:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010437a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010437d:	5b                   	pop    %ebx
8010437e:	5e                   	pop    %esi
8010437f:	5f                   	pop    %edi
80104380:	5d                   	pop    %ebp
80104381:	c3                   	ret    

80104382 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104382:	55                   	push   %ebp
80104383:	89 e5                	mov    %esp,%ebp
80104385:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104388:	e8 7d fb ff ff       	call   80103f0a <myproc>
8010438d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104390:	a1 74 91 11 80       	mov    0x80119174,%eax
80104395:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104398:	75 0d                	jne    801043a7 <exit+0x25>
    panic("init exiting");
8010439a:	83 ec 0c             	sub    $0xc,%esp
8010439d:	68 da a9 10 80       	push   $0x8010a9da
801043a2:	e8 02 c2 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043ae:	eb 3f                	jmp    801043ef <exit+0x6d>
    if(curproc->ofile[fd]){
801043b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b6:	83 c2 08             	add    $0x8,%edx
801043b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043bd:	85 c0                	test   %eax,%eax
801043bf:	74 2a                	je     801043eb <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c7:	83 c2 08             	add    $0x8,%edx
801043ca:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043ce:	83 ec 0c             	sub    $0xc,%esp
801043d1:	50                   	push   %eax
801043d2:	e8 ba cc ff ff       	call   80101091 <fileclose>
801043d7:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e0:	83 c2 08             	add    $0x8,%edx
801043e3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043ea:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043ef:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043f3:	7e bb                	jle    801043b0 <exit+0x2e>
    }
  }

  begin_op();
801043f5:	e8 1c f1 ff ff       	call   80103516 <begin_op>
  iput(curproc->cwd);
801043fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043fd:	8b 40 68             	mov    0x68(%eax),%eax
80104400:	83 ec 0c             	sub    $0xc,%esp
80104403:	50                   	push   %eax
80104404:	e8 38 d7 ff ff       	call   80101b41 <iput>
80104409:	83 c4 10             	add    $0x10,%esp
  end_op();
8010440c:	e8 91 f1 ff ff       	call   801035a2 <end_op>
  curproc->cwd = 0;
80104411:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104414:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	68 40 72 11 80       	push   $0x80117240
80104423:	e8 ff 08 00 00       	call   80104d27 <acquire>
80104428:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010442b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010442e:	8b 40 14             	mov    0x14(%eax),%eax
80104431:	83 ec 0c             	sub    $0xc,%esp
80104434:	50                   	push   %eax
80104435:	e8 20 04 00 00       	call   8010485a <wakeup1>
8010443a:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010443d:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104444:	eb 37                	jmp    8010447d <exit+0xfb>
    if(p->parent == curproc){
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 14             	mov    0x14(%eax),%eax
8010444c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010444f:	75 28                	jne    80104479 <exit+0xf7>
      p->parent = initproc;
80104451:	8b 15 74 91 11 80    	mov    0x80119174,%edx
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010445d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104460:	8b 40 0c             	mov    0xc(%eax),%eax
80104463:	83 f8 05             	cmp    $0x5,%eax
80104466:	75 11                	jne    80104479 <exit+0xf7>
        wakeup1(initproc);
80104468:	a1 74 91 11 80       	mov    0x80119174,%eax
8010446d:	83 ec 0c             	sub    $0xc,%esp
80104470:	50                   	push   %eax
80104471:	e8 e4 03 00 00       	call   8010485a <wakeup1>
80104476:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104479:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010447d:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104484:	72 c0                	jb     80104446 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104486:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104489:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104490:	e8 e5 01 00 00       	call   8010467a <sched>
  panic("zombie exit");
80104495:	83 ec 0c             	sub    $0xc,%esp
80104498:	68 e7 a9 10 80       	push   $0x8010a9e7
8010449d:	e8 07 c1 ff ff       	call   801005a9 <panic>

801044a2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044a2:	55                   	push   %ebp
801044a3:	89 e5                	mov    %esp,%ebp
801044a5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044a8:	e8 5d fa ff ff       	call   80103f0a <myproc>
801044ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044b0:	83 ec 0c             	sub    $0xc,%esp
801044b3:	68 40 72 11 80       	push   $0x80117240
801044b8:	e8 6a 08 00 00       	call   80104d27 <acquire>
801044bd:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044c7:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044ce:	e9 a1 00 00 00       	jmp    80104574 <wait+0xd2>
      if(p->parent != curproc)
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	8b 40 14             	mov    0x14(%eax),%eax
801044d9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044dc:	0f 85 8d 00 00 00    	jne    8010456f <wait+0xcd>
        continue;
      havekids = 1;
801044e2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ec:	8b 40 0c             	mov    0xc(%eax),%eax
801044ef:	83 f8 05             	cmp    $0x5,%eax
801044f2:	75 7c                	jne    80104570 <wait+0xce>
        // Found one.
        pid = p->pid;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	8b 40 10             	mov    0x10(%eax),%eax
801044fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801044fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104500:	8b 40 08             	mov    0x8(%eax),%eax
80104503:	83 ec 0c             	sub    $0xc,%esp
80104506:	50                   	push   %eax
80104507:	e8 d4 e6 ff ff       	call   80102be0 <kfree>
8010450c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010450f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104512:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 40 04             	mov    0x4(%eax),%eax
8010451f:	83 ec 0c             	sub    $0xc,%esp
80104522:	50                   	push   %eax
80104523:	e8 ca 3a 00 00       	call   80107ff2 <freevm>
80104528:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010452b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010453f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104542:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104549:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010455a:	83 ec 0c             	sub    $0xc,%esp
8010455d:	68 40 72 11 80       	push   $0x80117240
80104562:	e8 2e 08 00 00       	call   80104d95 <release>
80104567:	83 c4 10             	add    $0x10,%esp
        return pid;
8010456a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010456d:	eb 51                	jmp    801045c0 <wait+0x11e>
        continue;
8010456f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104570:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104574:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010457b:	0f 82 52 ff ff ff    	jb     801044d3 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104581:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104585:	74 0a                	je     80104591 <wait+0xef>
80104587:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010458a:	8b 40 24             	mov    0x24(%eax),%eax
8010458d:	85 c0                	test   %eax,%eax
8010458f:	74 17                	je     801045a8 <wait+0x106>
      release(&ptable.lock);
80104591:	83 ec 0c             	sub    $0xc,%esp
80104594:	68 40 72 11 80       	push   $0x80117240
80104599:	e8 f7 07 00 00       	call   80104d95 <release>
8010459e:	83 c4 10             	add    $0x10,%esp
      return -1;
801045a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a6:	eb 18                	jmp    801045c0 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045a8:	83 ec 08             	sub    $0x8,%esp
801045ab:	68 40 72 11 80       	push   $0x80117240
801045b0:	ff 75 ec             	push   -0x14(%ebp)
801045b3:	e8 fb 01 00 00       	call   801047b3 <sleep>
801045b8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045bb:	e9 00 ff ff ff       	jmp    801044c0 <wait+0x1e>
  }
}
801045c0:	c9                   	leave  
801045c1:	c3                   	ret    

801045c2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045c2:	55                   	push   %ebp
801045c3:	89 e5                	mov    %esp,%ebp
801045c5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045c8:	e8 c5 f8 ff ff       	call   80103e92 <mycpu>
801045cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045d3:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045da:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045dd:	e8 70 f8 ff ff       	call   80103e52 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	68 40 72 11 80       	push   $0x80117240
801045ea:	e8 38 07 00 00       	call   80104d27 <acquire>
801045ef:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f2:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801045f9:	eb 61                	jmp    8010465c <scheduler+0x9a>
      if(p->state != RUNNABLE)
801045fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fe:	8b 40 0c             	mov    0xc(%eax),%eax
80104601:	83 f8 03             	cmp    $0x3,%eax
80104604:	75 51                	jne    80104657 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010460c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	ff 75 f4             	push   -0xc(%ebp)
80104618:	e8 30 35 00 00       	call   80107b4d <switchuvm>
8010461d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104630:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104633:	83 c2 04             	add    $0x4,%edx
80104636:	83 ec 08             	sub    $0x8,%esp
80104639:	50                   	push   %eax
8010463a:	52                   	push   %edx
8010463b:	e8 d2 0b 00 00       	call   80105212 <swtch>
80104640:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104643:	e8 ec 34 00 00       	call   80107b34 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010464b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104652:	00 00 00 
80104655:	eb 01                	jmp    80104658 <scheduler+0x96>
        continue;
80104657:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104658:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010465c:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104663:	72 96                	jb     801045fb <scheduler+0x39>
    }
    release(&ptable.lock);
80104665:	83 ec 0c             	sub    $0xc,%esp
80104668:	68 40 72 11 80       	push   $0x80117240
8010466d:	e8 23 07 00 00       	call   80104d95 <release>
80104672:	83 c4 10             	add    $0x10,%esp
    sti();
80104675:	e9 63 ff ff ff       	jmp    801045dd <scheduler+0x1b>

8010467a <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010467a:	55                   	push   %ebp
8010467b:	89 e5                	mov    %esp,%ebp
8010467d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104680:	e8 85 f8 ff ff       	call   80103f0a <myproc>
80104685:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104688:	83 ec 0c             	sub    $0xc,%esp
8010468b:	68 40 72 11 80       	push   $0x80117240
80104690:	e8 cd 07 00 00       	call   80104e62 <holding>
80104695:	83 c4 10             	add    $0x10,%esp
80104698:	85 c0                	test   %eax,%eax
8010469a:	75 0d                	jne    801046a9 <sched+0x2f>
    panic("sched ptable.lock");
8010469c:	83 ec 0c             	sub    $0xc,%esp
8010469f:	68 f3 a9 10 80       	push   $0x8010a9f3
801046a4:	e8 00 bf ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046a9:	e8 e4 f7 ff ff       	call   80103e92 <mycpu>
801046ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046b4:	83 f8 01             	cmp    $0x1,%eax
801046b7:	74 0d                	je     801046c6 <sched+0x4c>
    panic("sched locks");
801046b9:	83 ec 0c             	sub    $0xc,%esp
801046bc:	68 05 aa 10 80       	push   $0x8010aa05
801046c1:	e8 e3 be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c9:	8b 40 0c             	mov    0xc(%eax),%eax
801046cc:	83 f8 04             	cmp    $0x4,%eax
801046cf:	75 0d                	jne    801046de <sched+0x64>
    panic("sched running");
801046d1:	83 ec 0c             	sub    $0xc,%esp
801046d4:	68 11 aa 10 80       	push   $0x8010aa11
801046d9:	e8 cb be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046de:	e8 5f f7 ff ff       	call   80103e42 <readeflags>
801046e3:	25 00 02 00 00       	and    $0x200,%eax
801046e8:	85 c0                	test   %eax,%eax
801046ea:	74 0d                	je     801046f9 <sched+0x7f>
    panic("sched interruptible");
801046ec:	83 ec 0c             	sub    $0xc,%esp
801046ef:	68 1f aa 10 80       	push   $0x8010aa1f
801046f4:	e8 b0 be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801046f9:	e8 94 f7 ff ff       	call   80103e92 <mycpu>
801046fe:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104704:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104707:	e8 86 f7 ff ff       	call   80103e92 <mycpu>
8010470c:	8b 40 04             	mov    0x4(%eax),%eax
8010470f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104712:	83 c2 1c             	add    $0x1c,%edx
80104715:	83 ec 08             	sub    $0x8,%esp
80104718:	50                   	push   %eax
80104719:	52                   	push   %edx
8010471a:	e8 f3 0a 00 00       	call   80105212 <swtch>
8010471f:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104722:	e8 6b f7 ff ff       	call   80103e92 <mycpu>
80104727:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010472a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104730:	90                   	nop
80104731:	c9                   	leave  
80104732:	c3                   	ret    

80104733 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104733:	55                   	push   %ebp
80104734:	89 e5                	mov    %esp,%ebp
80104736:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104739:	83 ec 0c             	sub    $0xc,%esp
8010473c:	68 40 72 11 80       	push   $0x80117240
80104741:	e8 e1 05 00 00       	call   80104d27 <acquire>
80104746:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104749:	e8 bc f7 ff ff       	call   80103f0a <myproc>
8010474e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104755:	e8 20 ff ff ff       	call   8010467a <sched>
  release(&ptable.lock);
8010475a:	83 ec 0c             	sub    $0xc,%esp
8010475d:	68 40 72 11 80       	push   $0x80117240
80104762:	e8 2e 06 00 00       	call   80104d95 <release>
80104767:	83 c4 10             	add    $0x10,%esp
}
8010476a:	90                   	nop
8010476b:	c9                   	leave  
8010476c:	c3                   	ret    

8010476d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010476d:	55                   	push   %ebp
8010476e:	89 e5                	mov    %esp,%ebp
80104770:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	68 40 72 11 80       	push   $0x80117240
8010477b:	e8 15 06 00 00       	call   80104d95 <release>
80104780:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104783:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104788:	85 c0                	test   %eax,%eax
8010478a:	74 24                	je     801047b0 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010478c:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104793:	00 00 00 
    iinit(ROOTDEV);
80104796:	83 ec 0c             	sub    $0xc,%esp
80104799:	6a 01                	push   $0x1
8010479b:	e8 ce ce ff ff       	call   8010166e <iinit>
801047a0:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047a3:	83 ec 0c             	sub    $0xc,%esp
801047a6:	6a 01                	push   $0x1
801047a8:	e8 4a eb ff ff       	call   801032f7 <initlog>
801047ad:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047b0:	90                   	nop
801047b1:	c9                   	leave  
801047b2:	c3                   	ret    

801047b3 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047b3:	55                   	push   %ebp
801047b4:	89 e5                	mov    %esp,%ebp
801047b6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047b9:	e8 4c f7 ff ff       	call   80103f0a <myproc>
801047be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047c5:	75 0d                	jne    801047d4 <sleep+0x21>
    panic("sleep");
801047c7:	83 ec 0c             	sub    $0xc,%esp
801047ca:	68 33 aa 10 80       	push   $0x8010aa33
801047cf:	e8 d5 bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047d8:	75 0d                	jne    801047e7 <sleep+0x34>
    panic("sleep without lk");
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	68 39 aa 10 80       	push   $0x8010aa39
801047e2:	e8 c2 bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047e7:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
801047ee:	74 1e                	je     8010480e <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047f0:	83 ec 0c             	sub    $0xc,%esp
801047f3:	68 40 72 11 80       	push   $0x80117240
801047f8:	e8 2a 05 00 00       	call   80104d27 <acquire>
801047fd:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104800:	83 ec 0c             	sub    $0xc,%esp
80104803:	ff 75 0c             	push   0xc(%ebp)
80104806:	e8 8a 05 00 00       	call   80104d95 <release>
8010480b:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104811:	8b 55 08             	mov    0x8(%ebp),%edx
80104814:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104821:	e8 54 fe ff ff       	call   8010467a <sched>

  // Tidy up.
  p->chan = 0;
80104826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104829:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104830:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104837:	74 1e                	je     80104857 <sleep+0xa4>
    release(&ptable.lock);
80104839:	83 ec 0c             	sub    $0xc,%esp
8010483c:	68 40 72 11 80       	push   $0x80117240
80104841:	e8 4f 05 00 00       	call   80104d95 <release>
80104846:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104849:	83 ec 0c             	sub    $0xc,%esp
8010484c:	ff 75 0c             	push   0xc(%ebp)
8010484f:	e8 d3 04 00 00       	call   80104d27 <acquire>
80104854:	83 c4 10             	add    $0x10,%esp
  }
}
80104857:	90                   	nop
80104858:	c9                   	leave  
80104859:	c3                   	ret    

8010485a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010485a:	55                   	push   %ebp
8010485b:	89 e5                	mov    %esp,%ebp
8010485d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104860:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104867:	eb 24                	jmp    8010488d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104869:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010486c:	8b 40 0c             	mov    0xc(%eax),%eax
8010486f:	83 f8 02             	cmp    $0x2,%eax
80104872:	75 15                	jne    80104889 <wakeup1+0x2f>
80104874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104877:	8b 40 20             	mov    0x20(%eax),%eax
8010487a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010487d:	75 0a                	jne    80104889 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010487f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104882:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104889:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010488d:	81 7d fc 74 91 11 80 	cmpl   $0x80119174,-0x4(%ebp)
80104894:	72 d3                	jb     80104869 <wakeup1+0xf>
}
80104896:	90                   	nop
80104897:	90                   	nop
80104898:	c9                   	leave  
80104899:	c3                   	ret    

8010489a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010489a:	55                   	push   %ebp
8010489b:	89 e5                	mov    %esp,%ebp
8010489d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048a0:	83 ec 0c             	sub    $0xc,%esp
801048a3:	68 40 72 11 80       	push   $0x80117240
801048a8:	e8 7a 04 00 00       	call   80104d27 <acquire>
801048ad:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048b0:	83 ec 0c             	sub    $0xc,%esp
801048b3:	ff 75 08             	push   0x8(%ebp)
801048b6:	e8 9f ff ff ff       	call   8010485a <wakeup1>
801048bb:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	68 40 72 11 80       	push   $0x80117240
801048c6:	e8 ca 04 00 00       	call   80104d95 <release>
801048cb:	83 c4 10             	add    $0x10,%esp
}
801048ce:	90                   	nop
801048cf:	c9                   	leave  
801048d0:	c3                   	ret    

801048d1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048d1:	55                   	push   %ebp
801048d2:	89 e5                	mov    %esp,%ebp
801048d4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048d7:	83 ec 0c             	sub    $0xc,%esp
801048da:	68 40 72 11 80       	push   $0x80117240
801048df:	e8 43 04 00 00       	call   80104d27 <acquire>
801048e4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048e7:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801048ee:	eb 45                	jmp    80104935 <kill+0x64>
    if(p->pid == pid){
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f3:	8b 40 10             	mov    0x10(%eax),%eax
801048f6:	39 45 08             	cmp    %eax,0x8(%ebp)
801048f9:	75 36                	jne    80104931 <kill+0x60>
      p->killed = 1;
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 40 0c             	mov    0xc(%eax),%eax
8010490b:	83 f8 02             	cmp    $0x2,%eax
8010490e:	75 0a                	jne    8010491a <kill+0x49>
        p->state = RUNNABLE;
80104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104913:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010491a:	83 ec 0c             	sub    $0xc,%esp
8010491d:	68 40 72 11 80       	push   $0x80117240
80104922:	e8 6e 04 00 00       	call   80104d95 <release>
80104927:	83 c4 10             	add    $0x10,%esp
      return 0;
8010492a:	b8 00 00 00 00       	mov    $0x0,%eax
8010492f:	eb 22                	jmp    80104953 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104931:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104935:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010493c:	72 b2                	jb     801048f0 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010493e:	83 ec 0c             	sub    $0xc,%esp
80104941:	68 40 72 11 80       	push   $0x80117240
80104946:	e8 4a 04 00 00       	call   80104d95 <release>
8010494b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010494e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104953:	c9                   	leave  
80104954:	c3                   	ret    

80104955 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104955:	55                   	push   %ebp
80104956:	89 e5                	mov    %esp,%ebp
80104958:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010495b:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
80104962:	e9 d7 00 00 00       	jmp    80104a3e <procdump+0xe9>
    if(p->state == UNUSED)
80104967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010496a:	8b 40 0c             	mov    0xc(%eax),%eax
8010496d:	85 c0                	test   %eax,%eax
8010496f:	0f 84 c4 00 00 00    	je     80104a39 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104975:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104978:	8b 40 0c             	mov    0xc(%eax),%eax
8010497b:	83 f8 05             	cmp    $0x5,%eax
8010497e:	77 23                	ja     801049a3 <procdump+0x4e>
80104980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104983:	8b 40 0c             	mov    0xc(%eax),%eax
80104986:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010498d:	85 c0                	test   %eax,%eax
8010498f:	74 12                	je     801049a3 <procdump+0x4e>
      state = states[p->state];
80104991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104994:	8b 40 0c             	mov    0xc(%eax),%eax
80104997:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010499e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049a1:	eb 07                	jmp    801049aa <procdump+0x55>
    else
      state = "???";
801049a3:	c7 45 ec 4a aa 10 80 	movl   $0x8010aa4a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ad:	8d 50 6c             	lea    0x6c(%eax),%edx
801049b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b3:	8b 40 10             	mov    0x10(%eax),%eax
801049b6:	52                   	push   %edx
801049b7:	ff 75 ec             	push   -0x14(%ebp)
801049ba:	50                   	push   %eax
801049bb:	68 4e aa 10 80       	push   $0x8010aa4e
801049c0:	e8 2f ba ff ff       	call   801003f4 <cprintf>
801049c5:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049cb:	8b 40 0c             	mov    0xc(%eax),%eax
801049ce:	83 f8 02             	cmp    $0x2,%eax
801049d1:	75 54                	jne    80104a27 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d6:	8b 40 1c             	mov    0x1c(%eax),%eax
801049d9:	8b 40 0c             	mov    0xc(%eax),%eax
801049dc:	83 c0 08             	add    $0x8,%eax
801049df:	89 c2                	mov    %eax,%edx
801049e1:	83 ec 08             	sub    $0x8,%esp
801049e4:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049e7:	50                   	push   %eax
801049e8:	52                   	push   %edx
801049e9:	e8 f9 03 00 00       	call   80104de7 <getcallerpcs>
801049ee:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801049f8:	eb 1c                	jmp    80104a16 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801049fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a01:	83 ec 08             	sub    $0x8,%esp
80104a04:	50                   	push   %eax
80104a05:	68 57 aa 10 80       	push   $0x8010aa57
80104a0a:	e8 e5 b9 ff ff       	call   801003f4 <cprintf>
80104a0f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a16:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a1a:	7f 0b                	jg     80104a27 <procdump+0xd2>
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a23:	85 c0                	test   %eax,%eax
80104a25:	75 d3                	jne    801049fa <procdump+0xa5>
    }
    cprintf("\n");
80104a27:	83 ec 0c             	sub    $0xc,%esp
80104a2a:	68 5b aa 10 80       	push   $0x8010aa5b
80104a2f:	e8 c0 b9 ff ff       	call   801003f4 <cprintf>
80104a34:	83 c4 10             	add    $0x10,%esp
80104a37:	eb 01                	jmp    80104a3a <procdump+0xe5>
      continue;
80104a39:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a3a:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104a3e:	81 7d f0 74 91 11 80 	cmpl   $0x80119174,-0x10(%ebp)
80104a45:	0f 82 1c ff ff ff    	jb     80104967 <procdump+0x12>
  }
}
80104a4b:	90                   	nop
80104a4c:	90                   	nop
80104a4d:	c9                   	leave  
80104a4e:	c3                   	ret    

80104a4f <printpt>:

int
printpt(int pid)
{
80104a4f:	55                   	push   %ebp
80104a50:	89 e5                	mov    %esp,%ebp
80104a52:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = 0;
80104a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t *pte;
  pde_t *pgdir;
  uint addr;

  acquire(&ptable.lock);
80104a5c:	83 ec 0c             	sub    $0xc,%esp
80104a5f:	68 40 72 11 80       	push   $0x80117240
80104a64:	e8 be 02 00 00       	call   80104d27 <acquire>
80104a69:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a6c:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104a73:	eb 0f                	jmp    80104a84 <printpt+0x35>
    if (p->pid == pid)
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	8b 40 10             	mov    0x10(%eax),%eax
80104a7b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a7e:	74 0f                	je     80104a8f <printpt+0x40>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a80:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a84:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104a8b:	72 e8                	jb     80104a75 <printpt+0x26>
80104a8d:	eb 01                	jmp    80104a90 <printpt+0x41>
      break;
80104a8f:	90                   	nop
  }
  if (p == &ptable.proc[NPROC] || p->state == UNUSED) {
80104a90:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104a97:	74 0a                	je     80104aa3 <printpt+0x54>
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a9f:	85 c0                	test   %eax,%eax
80104aa1:	75 1a                	jne    80104abd <printpt+0x6e>
    release(&ptable.lock);
80104aa3:	83 ec 0c             	sub    $0xc,%esp
80104aa6:	68 40 72 11 80       	push   $0x80117240
80104aab:	e8 e5 02 00 00       	call   80104d95 <release>
80104ab0:	83 c4 10             	add    $0x10,%esp
    return -1;
80104ab3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ab8:	e9 e9 00 00 00       	jmp    80104ba6 <printpt+0x157>
  }

  pgdir = p->pgdir;
80104abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac0:	8b 40 04             	mov    0x4(%eax),%eax
80104ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  release(&ptable.lock);
80104ac6:	83 ec 0c             	sub    $0xc,%esp
80104ac9:	68 40 72 11 80       	push   $0x80117240
80104ace:	e8 c2 02 00 00       	call   80104d95 <release>
80104ad3:	83 c4 10             	add    $0x10,%esp

  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104ad6:	83 ec 08             	sub    $0x8,%esp
80104ad9:	ff 75 08             	push   0x8(%ebp)
80104adc:	68 5d aa 10 80       	push   $0x8010aa5d
80104ae1:	e8 0e b9 ff ff       	call   801003f4 <cprintf>
80104ae6:	83 c4 10             	add    $0x10,%esp

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104ae9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104af0:	e9 91 00 00 00       	jmp    80104b86 <printpt+0x137>
    pte = walkpgdir(pgdir, (void*)addr, 0);
80104af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104af8:	83 ec 04             	sub    $0x4,%esp
80104afb:	6a 00                	push   $0x0
80104afd:	50                   	push   %eax
80104afe:	ff 75 ec             	push   -0x14(%ebp)
80104b01:	e8 04 2e 00 00       	call   8010790a <walkpgdir>
80104b06:	83 c4 10             	add    $0x10,%esp
80104b09:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (!pte || !(*pte & PTE_P)) continue;
80104b0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104b10:	74 6c                	je     80104b7e <printpt+0x12f>
80104b12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b15:	8b 00                	mov    (%eax),%eax
80104b17:	83 e0 01             	and    $0x1,%eax
80104b1a:	85 c0                	test   %eax,%eax
80104b1c:	74 60                	je     80104b7e <printpt+0x12f>

    // 플래그 문자열 생성
    const char *access = (*pte & PTE_U) ? "U" : "K";
80104b1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b21:	8b 00                	mov    (%eax),%eax
80104b23:	83 e0 04             	and    $0x4,%eax
80104b26:	85 c0                	test   %eax,%eax
80104b28:	74 07                	je     80104b31 <printpt+0xe2>
80104b2a:	b8 78 aa 10 80       	mov    $0x8010aa78,%eax
80104b2f:	eb 05                	jmp    80104b36 <printpt+0xe7>
80104b31:	b8 7a aa 10 80       	mov    $0x8010aa7a,%eax
80104b36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    const char *write = (*pte & PTE_W) ? "W" : "-";
80104b39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b3c:	8b 00                	mov    (%eax),%eax
80104b3e:	83 e0 02             	and    $0x2,%eax
80104b41:	85 c0                	test   %eax,%eax
80104b43:	74 07                	je     80104b4c <printpt+0xfd>
80104b45:	b8 7c aa 10 80       	mov    $0x8010aa7c,%eax
80104b4a:	eb 05                	jmp    80104b51 <printpt+0x102>
80104b4c:	b8 7e aa 10 80       	mov    $0x8010aa7e,%eax
80104b51:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // 전체 문자열 조합 
    cprintf("%x P %s %s %x\n",
      addr >> 12,               // 가상 페이지 번호 (VA >> 12)
      access,                   // U or K
      write,                    // W or -
      PTE_ADDR(*pte) >> 12      // 물리 페이지 번호 (PA >> 12)
80104b54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b57:	8b 00                	mov    (%eax),%eax
    cprintf("%x P %s %s %x\n",
80104b59:	c1 e8 0c             	shr    $0xc,%eax
80104b5c:	89 c2                	mov    %eax,%edx
80104b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b61:	c1 e8 0c             	shr    $0xc,%eax
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	52                   	push   %edx
80104b68:	ff 75 e0             	push   -0x20(%ebp)
80104b6b:	ff 75 e4             	push   -0x1c(%ebp)
80104b6e:	50                   	push   %eax
80104b6f:	68 80 aa 10 80       	push   $0x8010aa80
80104b74:	e8 7b b8 ff ff       	call   801003f4 <cprintf>
80104b79:	83 c4 20             	add    $0x20,%esp
80104b7c:	eb 01                	jmp    80104b7f <printpt+0x130>
    if (!pte || !(*pte & PTE_P)) continue;
80104b7e:	90                   	nop
  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104b7f:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	0f 89 64 ff ff ff    	jns    80104af5 <printpt+0xa6>
    );
  }

  cprintf("END PAGE TABLE\n");
80104b91:	83 ec 0c             	sub    $0xc,%esp
80104b94:	68 8f aa 10 80       	push   $0x8010aa8f
80104b99:	e8 56 b8 ff ff       	call   801003f4 <cprintf>
80104b9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ba6:	c9                   	leave  
80104ba7:	c3                   	ret    

80104ba8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104ba8:	55                   	push   %ebp
80104ba9:	89 e5                	mov    %esp,%ebp
80104bab:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104bae:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb1:	83 c0 04             	add    $0x4,%eax
80104bb4:	83 ec 08             	sub    $0x8,%esp
80104bb7:	68 c9 aa 10 80       	push   $0x8010aac9
80104bbc:	50                   	push   %eax
80104bbd:	e8 43 01 00 00       	call   80104d05 <initlock>
80104bc2:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bcb:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104bce:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bda:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104be1:	90                   	nop
80104be2:	c9                   	leave  
80104be3:	c3                   	ret    

80104be4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104be4:	55                   	push   %ebp
80104be5:	89 e5                	mov    %esp,%ebp
80104be7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104bea:	8b 45 08             	mov    0x8(%ebp),%eax
80104bed:	83 c0 04             	add    $0x4,%eax
80104bf0:	83 ec 0c             	sub    $0xc,%esp
80104bf3:	50                   	push   %eax
80104bf4:	e8 2e 01 00 00       	call   80104d27 <acquire>
80104bf9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104bfc:	eb 15                	jmp    80104c13 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80104c01:	83 c0 04             	add    $0x4,%eax
80104c04:	83 ec 08             	sub    $0x8,%esp
80104c07:	50                   	push   %eax
80104c08:	ff 75 08             	push   0x8(%ebp)
80104c0b:	e8 a3 fb ff ff       	call   801047b3 <sleep>
80104c10:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c13:	8b 45 08             	mov    0x8(%ebp),%eax
80104c16:	8b 00                	mov    (%eax),%eax
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	75 e2                	jne    80104bfe <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c25:	e8 e0 f2 ff ff       	call   80103f0a <myproc>
80104c2a:	8b 50 10             	mov    0x10(%eax),%edx
80104c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c30:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c33:	8b 45 08             	mov    0x8(%ebp),%eax
80104c36:	83 c0 04             	add    $0x4,%eax
80104c39:	83 ec 0c             	sub    $0xc,%esp
80104c3c:	50                   	push   %eax
80104c3d:	e8 53 01 00 00       	call   80104d95 <release>
80104c42:	83 c4 10             	add    $0x10,%esp
}
80104c45:	90                   	nop
80104c46:	c9                   	leave  
80104c47:	c3                   	ret    

80104c48 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104c48:	55                   	push   %ebp
80104c49:	89 e5                	mov    %esp,%ebp
80104c4b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c51:	83 c0 04             	add    $0x4,%eax
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	50                   	push   %eax
80104c58:	e8 ca 00 00 00       	call   80104d27 <acquire>
80104c5d:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c60:	8b 45 08             	mov    0x8(%ebp),%eax
80104c63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c69:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c73:	83 ec 0c             	sub    $0xc,%esp
80104c76:	ff 75 08             	push   0x8(%ebp)
80104c79:	e8 1c fc ff ff       	call   8010489a <wakeup>
80104c7e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c81:	8b 45 08             	mov    0x8(%ebp),%eax
80104c84:	83 c0 04             	add    $0x4,%eax
80104c87:	83 ec 0c             	sub    $0xc,%esp
80104c8a:	50                   	push   %eax
80104c8b:	e8 05 01 00 00       	call   80104d95 <release>
80104c90:	83 c4 10             	add    $0x10,%esp
}
80104c93:	90                   	nop
80104c94:	c9                   	leave  
80104c95:	c3                   	ret    

80104c96 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104c96:	55                   	push   %ebp
80104c97:	89 e5                	mov    %esp,%ebp
80104c99:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9f:	83 c0 04             	add    $0x4,%eax
80104ca2:	83 ec 0c             	sub    $0xc,%esp
80104ca5:	50                   	push   %eax
80104ca6:	e8 7c 00 00 00       	call   80104d27 <acquire>
80104cab:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104cae:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb1:	8b 00                	mov    (%eax),%eax
80104cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb9:	83 c0 04             	add    $0x4,%eax
80104cbc:	83 ec 0c             	sub    $0xc,%esp
80104cbf:	50                   	push   %eax
80104cc0:	e8 d0 00 00 00       	call   80104d95 <release>
80104cc5:	83 c4 10             	add    $0x10,%esp
  return r;
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ccb:	c9                   	leave  
80104ccc:	c3                   	ret    

80104ccd <readeflags>:
{
80104ccd:	55                   	push   %ebp
80104cce:	89 e5                	mov    %esp,%ebp
80104cd0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104cd3:	9c                   	pushf  
80104cd4:	58                   	pop    %eax
80104cd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104cd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cdb:	c9                   	leave  
80104cdc:	c3                   	ret    

80104cdd <cli>:
{
80104cdd:	55                   	push   %ebp
80104cde:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ce0:	fa                   	cli    
}
80104ce1:	90                   	nop
80104ce2:	5d                   	pop    %ebp
80104ce3:	c3                   	ret    

80104ce4 <sti>:
{
80104ce4:	55                   	push   %ebp
80104ce5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ce7:	fb                   	sti    
}
80104ce8:	90                   	nop
80104ce9:	5d                   	pop    %ebp
80104cea:	c3                   	ret    

80104ceb <xchg>:
{
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104cf1:	8b 55 08             	mov    0x8(%ebp),%edx
80104cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cfa:	f0 87 02             	lock xchg %eax,(%edx)
80104cfd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d03:	c9                   	leave  
80104d04:	c3                   	ret    

80104d05 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d05:	55                   	push   %ebp
80104d06:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d08:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d0e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d11:	8b 45 08             	mov    0x8(%ebp),%eax
80104d14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d24:	90                   	nop
80104d25:	5d                   	pop    %ebp
80104d26:	c3                   	ret    

80104d27 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	53                   	push   %ebx
80104d2b:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d2e:	e8 5f 01 00 00       	call   80104e92 <pushcli>
  if(holding(lk)){
80104d33:	8b 45 08             	mov    0x8(%ebp),%eax
80104d36:	83 ec 0c             	sub    $0xc,%esp
80104d39:	50                   	push   %eax
80104d3a:	e8 23 01 00 00       	call   80104e62 <holding>
80104d3f:	83 c4 10             	add    $0x10,%esp
80104d42:	85 c0                	test   %eax,%eax
80104d44:	74 0d                	je     80104d53 <acquire+0x2c>
    panic("acquire");
80104d46:	83 ec 0c             	sub    $0xc,%esp
80104d49:	68 d4 aa 10 80       	push   $0x8010aad4
80104d4e:	e8 56 b8 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d53:	90                   	nop
80104d54:	8b 45 08             	mov    0x8(%ebp),%eax
80104d57:	83 ec 08             	sub    $0x8,%esp
80104d5a:	6a 01                	push   $0x1
80104d5c:	50                   	push   %eax
80104d5d:	e8 89 ff ff ff       	call   80104ceb <xchg>
80104d62:	83 c4 10             	add    $0x10,%esp
80104d65:	85 c0                	test   %eax,%eax
80104d67:	75 eb                	jne    80104d54 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d69:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d71:	e8 1c f1 ff ff       	call   80103e92 <mycpu>
80104d76:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d79:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7c:	83 c0 0c             	add    $0xc,%eax
80104d7f:	83 ec 08             	sub    $0x8,%esp
80104d82:	50                   	push   %eax
80104d83:	8d 45 08             	lea    0x8(%ebp),%eax
80104d86:	50                   	push   %eax
80104d87:	e8 5b 00 00 00       	call   80104de7 <getcallerpcs>
80104d8c:	83 c4 10             	add    $0x10,%esp
}
80104d8f:	90                   	nop
80104d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d93:	c9                   	leave  
80104d94:	c3                   	ret    

80104d95 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104d95:	55                   	push   %ebp
80104d96:	89 e5                	mov    %esp,%ebp
80104d98:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104d9b:	83 ec 0c             	sub    $0xc,%esp
80104d9e:	ff 75 08             	push   0x8(%ebp)
80104da1:	e8 bc 00 00 00       	call   80104e62 <holding>
80104da6:	83 c4 10             	add    $0x10,%esp
80104da9:	85 c0                	test   %eax,%eax
80104dab:	75 0d                	jne    80104dba <release+0x25>
    panic("release");
80104dad:	83 ec 0c             	sub    $0xc,%esp
80104db0:	68 dc aa 10 80       	push   $0x8010aadc
80104db5:	e8 ef b7 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104dba:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104dce:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd6:	8b 55 08             	mov    0x8(%ebp),%edx
80104dd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104ddf:	e8 fb 00 00 00       	call   80104edf <popcli>
}
80104de4:	90                   	nop
80104de5:	c9                   	leave  
80104de6:	c3                   	ret    

80104de7 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104de7:	55                   	push   %ebp
80104de8:	89 e5                	mov    %esp,%ebp
80104dea:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104ded:	8b 45 08             	mov    0x8(%ebp),%eax
80104df0:	83 e8 08             	sub    $0x8,%eax
80104df3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104df6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104dfd:	eb 38                	jmp    80104e37 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104dff:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e03:	74 53                	je     80104e58 <getcallerpcs+0x71>
80104e05:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e0c:	76 4a                	jbe    80104e58 <getcallerpcs+0x71>
80104e0e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e12:	74 44                	je     80104e58 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e14:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e21:	01 c2                	add    %eax,%edx
80104e23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e26:	8b 40 04             	mov    0x4(%eax),%eax
80104e29:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2e:	8b 00                	mov    (%eax),%eax
80104e30:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e33:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e37:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e3b:	7e c2                	jle    80104dff <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104e3d:	eb 19                	jmp    80104e58 <getcallerpcs+0x71>
    pcs[i] = 0;
80104e3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e4c:	01 d0                	add    %edx,%eax
80104e4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e54:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e58:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e5c:	7e e1                	jle    80104e3f <getcallerpcs+0x58>
}
80104e5e:	90                   	nop
80104e5f:	90                   	nop
80104e60:	c9                   	leave  
80104e61:	c3                   	ret    

80104e62 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e62:	55                   	push   %ebp
80104e63:	89 e5                	mov    %esp,%ebp
80104e65:	53                   	push   %ebx
80104e66:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e69:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6c:	8b 00                	mov    (%eax),%eax
80104e6e:	85 c0                	test   %eax,%eax
80104e70:	74 16                	je     80104e88 <holding+0x26>
80104e72:	8b 45 08             	mov    0x8(%ebp),%eax
80104e75:	8b 58 08             	mov    0x8(%eax),%ebx
80104e78:	e8 15 f0 ff ff       	call   80103e92 <mycpu>
80104e7d:	39 c3                	cmp    %eax,%ebx
80104e7f:	75 07                	jne    80104e88 <holding+0x26>
80104e81:	b8 01 00 00 00       	mov    $0x1,%eax
80104e86:	eb 05                	jmp    80104e8d <holding+0x2b>
80104e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e90:	c9                   	leave  
80104e91:	c3                   	ret    

80104e92 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e92:	55                   	push   %ebp
80104e93:	89 e5                	mov    %esp,%ebp
80104e95:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104e98:	e8 30 fe ff ff       	call   80104ccd <readeflags>
80104e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104ea0:	e8 38 fe ff ff       	call   80104cdd <cli>
  if(mycpu()->ncli == 0)
80104ea5:	e8 e8 ef ff ff       	call   80103e92 <mycpu>
80104eaa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104eb0:	85 c0                	test   %eax,%eax
80104eb2:	75 14                	jne    80104ec8 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104eb4:	e8 d9 ef ff ff       	call   80103e92 <mycpu>
80104eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ebc:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ec2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ec8:	e8 c5 ef ff ff       	call   80103e92 <mycpu>
80104ecd:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ed3:	83 c2 01             	add    $0x1,%edx
80104ed6:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104edc:	90                   	nop
80104edd:	c9                   	leave  
80104ede:	c3                   	ret    

80104edf <popcli>:

void
popcli(void)
{
80104edf:	55                   	push   %ebp
80104ee0:	89 e5                	mov    %esp,%ebp
80104ee2:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ee5:	e8 e3 fd ff ff       	call   80104ccd <readeflags>
80104eea:	25 00 02 00 00       	and    $0x200,%eax
80104eef:	85 c0                	test   %eax,%eax
80104ef1:	74 0d                	je     80104f00 <popcli+0x21>
    panic("popcli - interruptible");
80104ef3:	83 ec 0c             	sub    $0xc,%esp
80104ef6:	68 e4 aa 10 80       	push   $0x8010aae4
80104efb:	e8 a9 b6 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104f00:	e8 8d ef ff ff       	call   80103e92 <mycpu>
80104f05:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f0b:	83 ea 01             	sub    $0x1,%edx
80104f0e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104f14:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f1a:	85 c0                	test   %eax,%eax
80104f1c:	79 0d                	jns    80104f2b <popcli+0x4c>
    panic("popcli");
80104f1e:	83 ec 0c             	sub    $0xc,%esp
80104f21:	68 fb aa 10 80       	push   $0x8010aafb
80104f26:	e8 7e b6 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f2b:	e8 62 ef ff ff       	call   80103e92 <mycpu>
80104f30:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f36:	85 c0                	test   %eax,%eax
80104f38:	75 14                	jne    80104f4e <popcli+0x6f>
80104f3a:	e8 53 ef ff ff       	call   80103e92 <mycpu>
80104f3f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f45:	85 c0                	test   %eax,%eax
80104f47:	74 05                	je     80104f4e <popcli+0x6f>
    sti();
80104f49:	e8 96 fd ff ff       	call   80104ce4 <sti>
}
80104f4e:	90                   	nop
80104f4f:	c9                   	leave  
80104f50:	c3                   	ret    

80104f51 <stosb>:
{
80104f51:	55                   	push   %ebp
80104f52:	89 e5                	mov    %esp,%ebp
80104f54:	57                   	push   %edi
80104f55:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f56:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f59:	8b 55 10             	mov    0x10(%ebp),%edx
80104f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5f:	89 cb                	mov    %ecx,%ebx
80104f61:	89 df                	mov    %ebx,%edi
80104f63:	89 d1                	mov    %edx,%ecx
80104f65:	fc                   	cld    
80104f66:	f3 aa                	rep stos %al,%es:(%edi)
80104f68:	89 ca                	mov    %ecx,%edx
80104f6a:	89 fb                	mov    %edi,%ebx
80104f6c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f6f:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f72:	90                   	nop
80104f73:	5b                   	pop    %ebx
80104f74:	5f                   	pop    %edi
80104f75:	5d                   	pop    %ebp
80104f76:	c3                   	ret    

80104f77 <stosl>:
{
80104f77:	55                   	push   %ebp
80104f78:	89 e5                	mov    %esp,%ebp
80104f7a:	57                   	push   %edi
80104f7b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f7f:	8b 55 10             	mov    0x10(%ebp),%edx
80104f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f85:	89 cb                	mov    %ecx,%ebx
80104f87:	89 df                	mov    %ebx,%edi
80104f89:	89 d1                	mov    %edx,%ecx
80104f8b:	fc                   	cld    
80104f8c:	f3 ab                	rep stos %eax,%es:(%edi)
80104f8e:	89 ca                	mov    %ecx,%edx
80104f90:	89 fb                	mov    %edi,%ebx
80104f92:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f95:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f98:	90                   	nop
80104f99:	5b                   	pop    %ebx
80104f9a:	5f                   	pop    %edi
80104f9b:	5d                   	pop    %ebp
80104f9c:	c3                   	ret    

80104f9d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104f9d:	55                   	push   %ebp
80104f9e:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa3:	83 e0 03             	and    $0x3,%eax
80104fa6:	85 c0                	test   %eax,%eax
80104fa8:	75 43                	jne    80104fed <memset+0x50>
80104faa:	8b 45 10             	mov    0x10(%ebp),%eax
80104fad:	83 e0 03             	and    $0x3,%eax
80104fb0:	85 c0                	test   %eax,%eax
80104fb2:	75 39                	jne    80104fed <memset+0x50>
    c &= 0xFF;
80104fb4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80104fbe:	c1 e8 02             	shr    $0x2,%eax
80104fc1:	89 c2                	mov    %eax,%edx
80104fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc6:	c1 e0 18             	shl    $0x18,%eax
80104fc9:	89 c1                	mov    %eax,%ecx
80104fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fce:	c1 e0 10             	shl    $0x10,%eax
80104fd1:	09 c1                	or     %eax,%ecx
80104fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd6:	c1 e0 08             	shl    $0x8,%eax
80104fd9:	09 c8                	or     %ecx,%eax
80104fdb:	0b 45 0c             	or     0xc(%ebp),%eax
80104fde:	52                   	push   %edx
80104fdf:	50                   	push   %eax
80104fe0:	ff 75 08             	push   0x8(%ebp)
80104fe3:	e8 8f ff ff ff       	call   80104f77 <stosl>
80104fe8:	83 c4 0c             	add    $0xc,%esp
80104feb:	eb 12                	jmp    80104fff <memset+0x62>
  } else
    stosb(dst, c, n);
80104fed:	8b 45 10             	mov    0x10(%ebp),%eax
80104ff0:	50                   	push   %eax
80104ff1:	ff 75 0c             	push   0xc(%ebp)
80104ff4:	ff 75 08             	push   0x8(%ebp)
80104ff7:	e8 55 ff ff ff       	call   80104f51 <stosb>
80104ffc:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104fff:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105002:	c9                   	leave  
80105003:	c3                   	ret    

80105004 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105004:	55                   	push   %ebp
80105005:	89 e5                	mov    %esp,%ebp
80105007:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010500a:	8b 45 08             	mov    0x8(%ebp),%eax
8010500d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105010:	8b 45 0c             	mov    0xc(%ebp),%eax
80105013:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105016:	eb 30                	jmp    80105048 <memcmp+0x44>
    if(*s1 != *s2)
80105018:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010501b:	0f b6 10             	movzbl (%eax),%edx
8010501e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105021:	0f b6 00             	movzbl (%eax),%eax
80105024:	38 c2                	cmp    %al,%dl
80105026:	74 18                	je     80105040 <memcmp+0x3c>
      return *s1 - *s2;
80105028:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010502b:	0f b6 00             	movzbl (%eax),%eax
8010502e:	0f b6 d0             	movzbl %al,%edx
80105031:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105034:	0f b6 00             	movzbl (%eax),%eax
80105037:	0f b6 c8             	movzbl %al,%ecx
8010503a:	89 d0                	mov    %edx,%eax
8010503c:	29 c8                	sub    %ecx,%eax
8010503e:	eb 1a                	jmp    8010505a <memcmp+0x56>
    s1++, s2++;
80105040:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105044:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105048:	8b 45 10             	mov    0x10(%ebp),%eax
8010504b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010504e:	89 55 10             	mov    %edx,0x10(%ebp)
80105051:	85 c0                	test   %eax,%eax
80105053:	75 c3                	jne    80105018 <memcmp+0x14>
  }

  return 0;
80105055:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010505a:	c9                   	leave  
8010505b:	c3                   	ret    

8010505c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010505c:	55                   	push   %ebp
8010505d:	89 e5                	mov    %esp,%ebp
8010505f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105062:	8b 45 0c             	mov    0xc(%ebp),%eax
80105065:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105068:	8b 45 08             	mov    0x8(%ebp),%eax
8010506b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010506e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105071:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105074:	73 54                	jae    801050ca <memmove+0x6e>
80105076:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105079:	8b 45 10             	mov    0x10(%ebp),%eax
8010507c:	01 d0                	add    %edx,%eax
8010507e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105081:	73 47                	jae    801050ca <memmove+0x6e>
    s += n;
80105083:	8b 45 10             	mov    0x10(%ebp),%eax
80105086:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105089:	8b 45 10             	mov    0x10(%ebp),%eax
8010508c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010508f:	eb 13                	jmp    801050a4 <memmove+0x48>
      *--d = *--s;
80105091:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105095:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105099:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010509c:	0f b6 10             	movzbl (%eax),%edx
8010509f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050a2:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050a4:	8b 45 10             	mov    0x10(%ebp),%eax
801050a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801050aa:	89 55 10             	mov    %edx,0x10(%ebp)
801050ad:	85 c0                	test   %eax,%eax
801050af:	75 e0                	jne    80105091 <memmove+0x35>
  if(s < d && s + n > d){
801050b1:	eb 24                	jmp    801050d7 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801050b3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050b6:	8d 42 01             	lea    0x1(%edx),%eax
801050b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050bf:	8d 48 01             	lea    0x1(%eax),%ecx
801050c2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801050c5:	0f b6 12             	movzbl (%edx),%edx
801050c8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050ca:	8b 45 10             	mov    0x10(%ebp),%eax
801050cd:	8d 50 ff             	lea    -0x1(%eax),%edx
801050d0:	89 55 10             	mov    %edx,0x10(%ebp)
801050d3:	85 c0                	test   %eax,%eax
801050d5:	75 dc                	jne    801050b3 <memmove+0x57>

  return dst;
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050da:	c9                   	leave  
801050db:	c3                   	ret    

801050dc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050dc:	55                   	push   %ebp
801050dd:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801050df:	ff 75 10             	push   0x10(%ebp)
801050e2:	ff 75 0c             	push   0xc(%ebp)
801050e5:	ff 75 08             	push   0x8(%ebp)
801050e8:	e8 6f ff ff ff       	call   8010505c <memmove>
801050ed:	83 c4 0c             	add    $0xc,%esp
}
801050f0:	c9                   	leave  
801050f1:	c3                   	ret    

801050f2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801050f2:	55                   	push   %ebp
801050f3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801050f5:	eb 0c                	jmp    80105103 <strncmp+0x11>
    n--, p++, q++;
801050f7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801050ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105103:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105107:	74 1a                	je     80105123 <strncmp+0x31>
80105109:	8b 45 08             	mov    0x8(%ebp),%eax
8010510c:	0f b6 00             	movzbl (%eax),%eax
8010510f:	84 c0                	test   %al,%al
80105111:	74 10                	je     80105123 <strncmp+0x31>
80105113:	8b 45 08             	mov    0x8(%ebp),%eax
80105116:	0f b6 10             	movzbl (%eax),%edx
80105119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511c:	0f b6 00             	movzbl (%eax),%eax
8010511f:	38 c2                	cmp    %al,%dl
80105121:	74 d4                	je     801050f7 <strncmp+0x5>
  if(n == 0)
80105123:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105127:	75 07                	jne    80105130 <strncmp+0x3e>
    return 0;
80105129:	b8 00 00 00 00       	mov    $0x0,%eax
8010512e:	eb 16                	jmp    80105146 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105130:	8b 45 08             	mov    0x8(%ebp),%eax
80105133:	0f b6 00             	movzbl (%eax),%eax
80105136:	0f b6 d0             	movzbl %al,%edx
80105139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513c:	0f b6 00             	movzbl (%eax),%eax
8010513f:	0f b6 c8             	movzbl %al,%ecx
80105142:	89 d0                	mov    %edx,%eax
80105144:	29 c8                	sub    %ecx,%eax
}
80105146:	5d                   	pop    %ebp
80105147:	c3                   	ret    

80105148 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105148:	55                   	push   %ebp
80105149:	89 e5                	mov    %esp,%ebp
8010514b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010514e:	8b 45 08             	mov    0x8(%ebp),%eax
80105151:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105154:	90                   	nop
80105155:	8b 45 10             	mov    0x10(%ebp),%eax
80105158:	8d 50 ff             	lea    -0x1(%eax),%edx
8010515b:	89 55 10             	mov    %edx,0x10(%ebp)
8010515e:	85 c0                	test   %eax,%eax
80105160:	7e 2c                	jle    8010518e <strncpy+0x46>
80105162:	8b 55 0c             	mov    0xc(%ebp),%edx
80105165:	8d 42 01             	lea    0x1(%edx),%eax
80105168:	89 45 0c             	mov    %eax,0xc(%ebp)
8010516b:	8b 45 08             	mov    0x8(%ebp),%eax
8010516e:	8d 48 01             	lea    0x1(%eax),%ecx
80105171:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105174:	0f b6 12             	movzbl (%edx),%edx
80105177:	88 10                	mov    %dl,(%eax)
80105179:	0f b6 00             	movzbl (%eax),%eax
8010517c:	84 c0                	test   %al,%al
8010517e:	75 d5                	jne    80105155 <strncpy+0xd>
    ;
  while(n-- > 0)
80105180:	eb 0c                	jmp    8010518e <strncpy+0x46>
    *s++ = 0;
80105182:	8b 45 08             	mov    0x8(%ebp),%eax
80105185:	8d 50 01             	lea    0x1(%eax),%edx
80105188:	89 55 08             	mov    %edx,0x8(%ebp)
8010518b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010518e:	8b 45 10             	mov    0x10(%ebp),%eax
80105191:	8d 50 ff             	lea    -0x1(%eax),%edx
80105194:	89 55 10             	mov    %edx,0x10(%ebp)
80105197:	85 c0                	test   %eax,%eax
80105199:	7f e7                	jg     80105182 <strncpy+0x3a>
  return os;
8010519b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010519e:	c9                   	leave  
8010519f:	c3                   	ret    

801051a0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051a0:	55                   	push   %ebp
801051a1:	89 e5                	mov    %esp,%ebp
801051a3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051a6:	8b 45 08             	mov    0x8(%ebp),%eax
801051a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051b0:	7f 05                	jg     801051b7 <safestrcpy+0x17>
    return os;
801051b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b5:	eb 32                	jmp    801051e9 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801051b7:	90                   	nop
801051b8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051c0:	7e 1e                	jle    801051e0 <safestrcpy+0x40>
801051c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801051c5:	8d 42 01             	lea    0x1(%edx),%eax
801051c8:	89 45 0c             	mov    %eax,0xc(%ebp)
801051cb:	8b 45 08             	mov    0x8(%ebp),%eax
801051ce:	8d 48 01             	lea    0x1(%eax),%ecx
801051d1:	89 4d 08             	mov    %ecx,0x8(%ebp)
801051d4:	0f b6 12             	movzbl (%edx),%edx
801051d7:	88 10                	mov    %dl,(%eax)
801051d9:	0f b6 00             	movzbl (%eax),%eax
801051dc:	84 c0                	test   %al,%al
801051de:	75 d8                	jne    801051b8 <safestrcpy+0x18>
    ;
  *s = 0;
801051e0:	8b 45 08             	mov    0x8(%ebp),%eax
801051e3:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801051e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051e9:	c9                   	leave  
801051ea:	c3                   	ret    

801051eb <strlen>:

int
strlen(const char *s)
{
801051eb:	55                   	push   %ebp
801051ec:	89 e5                	mov    %esp,%ebp
801051ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801051f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801051f8:	eb 04                	jmp    801051fe <strlen+0x13>
801051fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105201:	8b 45 08             	mov    0x8(%ebp),%eax
80105204:	01 d0                	add    %edx,%eax
80105206:	0f b6 00             	movzbl (%eax),%eax
80105209:	84 c0                	test   %al,%al
8010520b:	75 ed                	jne    801051fa <strlen+0xf>
    ;
  return n;
8010520d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105210:	c9                   	leave  
80105211:	c3                   	ret    

80105212 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105212:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105216:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010521a:	55                   	push   %ebp
  pushl %ebx
8010521b:	53                   	push   %ebx
  pushl %esi
8010521c:	56                   	push   %esi
  pushl %edi
8010521d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010521e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105220:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105222:	5f                   	pop    %edi
  popl %esi
80105223:	5e                   	pop    %esi
  popl %ebx
80105224:	5b                   	pop    %ebx
  popl %ebp
80105225:	5d                   	pop    %ebp
  ret
80105226:	c3                   	ret    

80105227 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105227:	55                   	push   %ebp
80105228:	89 e5                	mov    %esp,%ebp
  //커널 영역 침범 방지
  if(addr >=KERNBASE || addr+4 > KERNBASE)
8010522a:	8b 45 08             	mov    0x8(%ebp),%eax
8010522d:	85 c0                	test   %eax,%eax
8010522f:	78 0d                	js     8010523e <fetchint+0x17>
80105231:	8b 45 08             	mov    0x8(%ebp),%eax
80105234:	83 c0 04             	add    $0x4,%eax
80105237:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010523c:	76 07                	jbe    80105245 <fetchint+0x1e>
    return -1;
8010523e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105243:	eb 0f                	jmp    80105254 <fetchint+0x2d>
  
  *ip = *(int*)(addr);
80105245:	8b 45 08             	mov    0x8(%ebp),%eax
80105248:	8b 10                	mov    (%eax),%edx
8010524a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524d:	89 10                	mov    %edx,(%eax)
  return 0;
8010524f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105254:	5d                   	pop    %ebp
80105255:	c3                   	ret    

80105256 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105256:	55                   	push   %ebp
80105257:	89 e5                	mov    %esp,%ebp
80105259:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  // 잘못된 접근 방지
  if(addr >=KERNBASE)
8010525c:	8b 45 08             	mov    0x8(%ebp),%eax
8010525f:	85 c0                	test   %eax,%eax
80105261:	79 07                	jns    8010526a <fetchstr+0x14>
    return -1;
80105263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105268:	eb 40                	jmp    801052aa <fetchstr+0x54>

  *pp = (char*)addr;
8010526a:	8b 55 08             	mov    0x8(%ebp),%edx
8010526d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105270:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE; //상한선은 가상 메모리 한계로 설정
80105272:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527c:	8b 00                	mov    (%eax),%eax
8010527e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105281:	eb 1a                	jmp    8010529d <fetchstr+0x47>
    if(*s == 0)
80105283:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105286:	0f b6 00             	movzbl (%eax),%eax
80105289:	84 c0                	test   %al,%al
8010528b:	75 0c                	jne    80105299 <fetchstr+0x43>
      return s - *pp;
8010528d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105290:	8b 10                	mov    (%eax),%edx
80105292:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105295:	29 d0                	sub    %edx,%eax
80105297:	eb 11                	jmp    801052aa <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80105299:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010529d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052a3:	72 de                	jb     80105283 <fetchstr+0x2d>
  }
  return -1;
801052a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052aa:	c9                   	leave  
801052ab:	c3                   	ret    

801052ac <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801052ac:	55                   	push   %ebp
801052ad:	89 e5                	mov    %esp,%ebp
801052af:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801052b2:	e8 53 ec ff ff       	call   80103f0a <myproc>
801052b7:	8b 40 18             	mov    0x18(%eax),%eax
801052ba:	8b 50 44             	mov    0x44(%eax),%edx
801052bd:	8b 45 08             	mov    0x8(%ebp),%eax
801052c0:	c1 e0 02             	shl    $0x2,%eax
801052c3:	01 d0                	add    %edx,%eax
801052c5:	83 c0 04             	add    $0x4,%eax
801052c8:	83 ec 08             	sub    $0x8,%esp
801052cb:	ff 75 0c             	push   0xc(%ebp)
801052ce:	50                   	push   %eax
801052cf:	e8 53 ff ff ff       	call   80105227 <fetchint>
801052d4:	83 c4 10             	add    $0x10,%esp
}
801052d7:	c9                   	leave  
801052d8:	c3                   	ret    

801052d9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801052d9:	55                   	push   %ebp
801052da:	89 e5                	mov    %esp,%ebp
801052dc:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801052df:	83 ec 08             	sub    $0x8,%esp
801052e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052e5:	50                   	push   %eax
801052e6:	ff 75 08             	push   0x8(%ebp)
801052e9:	e8 be ff ff ff       	call   801052ac <argint>
801052ee:	83 c4 10             	add    $0x10,%esp
801052f1:	85 c0                	test   %eax,%eax
801052f3:	79 07                	jns    801052fc <argptr+0x23>
    return -1;
801052f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fa:	eb 34                	jmp    80105330 <argptr+0x57>
    
  //size만큼 공간 확보 + 커널 영역 접근 방지
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801052fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105300:	78 18                	js     8010531a <argptr+0x41>
80105302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105305:	85 c0                	test   %eax,%eax
80105307:	78 11                	js     8010531a <argptr+0x41>
80105309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530c:	89 c2                	mov    %eax,%edx
8010530e:	8b 45 10             	mov    0x10(%ebp),%eax
80105311:	01 d0                	add    %edx,%eax
80105313:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105318:	76 07                	jbe    80105321 <argptr+0x48>
    return -1;
8010531a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531f:	eb 0f                	jmp    80105330 <argptr+0x57>
  *pp = (char*)i;
80105321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105324:	89 c2                	mov    %eax,%edx
80105326:	8b 45 0c             	mov    0xc(%ebp),%eax
80105329:	89 10                	mov    %edx,(%eax)
  return 0;
8010532b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105330:	c9                   	leave  
80105331:	c3                   	ret    

80105332 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105332:	55                   	push   %ebp
80105333:	89 e5                	mov    %esp,%ebp
80105335:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105338:	83 ec 08             	sub    $0x8,%esp
8010533b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010533e:	50                   	push   %eax
8010533f:	ff 75 08             	push   0x8(%ebp)
80105342:	e8 65 ff ff ff       	call   801052ac <argint>
80105347:	83 c4 10             	add    $0x10,%esp
8010534a:	85 c0                	test   %eax,%eax
8010534c:	79 07                	jns    80105355 <argstr+0x23>
    return -1;
8010534e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105353:	eb 12                	jmp    80105367 <argstr+0x35>
  return fetchstr(addr, pp);
80105355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105358:	83 ec 08             	sub    $0x8,%esp
8010535b:	ff 75 0c             	push   0xc(%ebp)
8010535e:	50                   	push   %eax
8010535f:	e8 f2 fe ff ff       	call   80105256 <fetchstr>
80105364:	83 c4 10             	add    $0x10,%esp
}
80105367:	c9                   	leave  
80105368:	c3                   	ret    

80105369 <syscall>:

};

void
syscall(void)
{
80105369:	55                   	push   %ebp
8010536a:	89 e5                	mov    %esp,%ebp
8010536c:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010536f:	e8 96 eb ff ff       	call   80103f0a <myproc>
80105374:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537a:	8b 40 18             	mov    0x18(%eax),%eax
8010537d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105380:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105383:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105387:	7e 2f                	jle    801053b8 <syscall+0x4f>
80105389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538c:	83 f8 16             	cmp    $0x16,%eax
8010538f:	77 27                	ja     801053b8 <syscall+0x4f>
80105391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105394:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010539b:	85 c0                	test   %eax,%eax
8010539d:	74 19                	je     801053b8 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010539f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a2:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053a9:	ff d0                	call   *%eax
801053ab:	89 c2                	mov    %eax,%edx
801053ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b0:	8b 40 18             	mov    0x18(%eax),%eax
801053b3:	89 50 1c             	mov    %edx,0x1c(%eax)
801053b6:	eb 2c                	jmp    801053e4 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801053b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053bb:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801053be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c1:	8b 40 10             	mov    0x10(%eax),%eax
801053c4:	ff 75 f0             	push   -0x10(%ebp)
801053c7:	52                   	push   %edx
801053c8:	50                   	push   %eax
801053c9:	68 02 ab 10 80       	push   $0x8010ab02
801053ce:	e8 21 b0 ff ff       	call   801003f4 <cprintf>
801053d3:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801053d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d9:	8b 40 18             	mov    0x18(%eax),%eax
801053dc:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801053e3:	90                   	nop
801053e4:	90                   	nop
801053e5:	c9                   	leave  
801053e6:	c3                   	ret    

801053e7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801053e7:	55                   	push   %ebp
801053e8:	89 e5                	mov    %esp,%ebp
801053ea:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801053ed:	83 ec 08             	sub    $0x8,%esp
801053f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053f3:	50                   	push   %eax
801053f4:	ff 75 08             	push   0x8(%ebp)
801053f7:	e8 b0 fe ff ff       	call   801052ac <argint>
801053fc:	83 c4 10             	add    $0x10,%esp
801053ff:	85 c0                	test   %eax,%eax
80105401:	79 07                	jns    8010540a <argfd+0x23>
    return -1;
80105403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105408:	eb 4f                	jmp    80105459 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010540a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540d:	85 c0                	test   %eax,%eax
8010540f:	78 20                	js     80105431 <argfd+0x4a>
80105411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105414:	83 f8 0f             	cmp    $0xf,%eax
80105417:	7f 18                	jg     80105431 <argfd+0x4a>
80105419:	e8 ec ea ff ff       	call   80103f0a <myproc>
8010541e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105421:	83 c2 08             	add    $0x8,%edx
80105424:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105428:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010542b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010542f:	75 07                	jne    80105438 <argfd+0x51>
    return -1;
80105431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105436:	eb 21                	jmp    80105459 <argfd+0x72>
  if(pfd)
80105438:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010543c:	74 08                	je     80105446 <argfd+0x5f>
    *pfd = fd;
8010543e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105441:	8b 45 0c             	mov    0xc(%ebp),%eax
80105444:	89 10                	mov    %edx,(%eax)
  if(pf)
80105446:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010544a:	74 08                	je     80105454 <argfd+0x6d>
    *pf = f;
8010544c:	8b 45 10             	mov    0x10(%ebp),%eax
8010544f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105452:	89 10                	mov    %edx,(%eax)
  return 0;
80105454:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105459:	c9                   	leave  
8010545a:	c3                   	ret    

8010545b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010545b:	55                   	push   %ebp
8010545c:	89 e5                	mov    %esp,%ebp
8010545e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105461:	e8 a4 ea ff ff       	call   80103f0a <myproc>
80105466:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105470:	eb 2a                	jmp    8010549c <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105472:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105478:	83 c2 08             	add    $0x8,%edx
8010547b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010547f:	85 c0                	test   %eax,%eax
80105481:	75 15                	jne    80105498 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105489:	8d 4a 08             	lea    0x8(%edx),%ecx
8010548c:	8b 55 08             	mov    0x8(%ebp),%edx
8010548f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105496:	eb 0f                	jmp    801054a7 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105498:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010549c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054a0:	7e d0                	jle    80105472 <fdalloc+0x17>
    }
  }
  return -1;
801054a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054a7:	c9                   	leave  
801054a8:	c3                   	ret    

801054a9 <sys_dup>:

int
sys_dup(void)
{
801054a9:	55                   	push   %ebp
801054aa:	89 e5                	mov    %esp,%ebp
801054ac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801054af:	83 ec 04             	sub    $0x4,%esp
801054b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054b5:	50                   	push   %eax
801054b6:	6a 00                	push   $0x0
801054b8:	6a 00                	push   $0x0
801054ba:	e8 28 ff ff ff       	call   801053e7 <argfd>
801054bf:	83 c4 10             	add    $0x10,%esp
801054c2:	85 c0                	test   %eax,%eax
801054c4:	79 07                	jns    801054cd <sys_dup+0x24>
    return -1;
801054c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054cb:	eb 31                	jmp    801054fe <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801054cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d0:	83 ec 0c             	sub    $0xc,%esp
801054d3:	50                   	push   %eax
801054d4:	e8 82 ff ff ff       	call   8010545b <fdalloc>
801054d9:	83 c4 10             	add    $0x10,%esp
801054dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054e3:	79 07                	jns    801054ec <sys_dup+0x43>
    return -1;
801054e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ea:	eb 12                	jmp    801054fe <sys_dup+0x55>
  filedup(f);
801054ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ef:	83 ec 0c             	sub    $0xc,%esp
801054f2:	50                   	push   %eax
801054f3:	e8 48 bb ff ff       	call   80101040 <filedup>
801054f8:	83 c4 10             	add    $0x10,%esp
  return fd;
801054fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801054fe:	c9                   	leave  
801054ff:	c3                   	ret    

80105500 <sys_read>:

int
sys_read(void)
{
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
80105503:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105506:	83 ec 04             	sub    $0x4,%esp
80105509:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010550c:	50                   	push   %eax
8010550d:	6a 00                	push   $0x0
8010550f:	6a 00                	push   $0x0
80105511:	e8 d1 fe ff ff       	call   801053e7 <argfd>
80105516:	83 c4 10             	add    $0x10,%esp
80105519:	85 c0                	test   %eax,%eax
8010551b:	78 2e                	js     8010554b <sys_read+0x4b>
8010551d:	83 ec 08             	sub    $0x8,%esp
80105520:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105523:	50                   	push   %eax
80105524:	6a 02                	push   $0x2
80105526:	e8 81 fd ff ff       	call   801052ac <argint>
8010552b:	83 c4 10             	add    $0x10,%esp
8010552e:	85 c0                	test   %eax,%eax
80105530:	78 19                	js     8010554b <sys_read+0x4b>
80105532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105535:	83 ec 04             	sub    $0x4,%esp
80105538:	50                   	push   %eax
80105539:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010553c:	50                   	push   %eax
8010553d:	6a 01                	push   $0x1
8010553f:	e8 95 fd ff ff       	call   801052d9 <argptr>
80105544:	83 c4 10             	add    $0x10,%esp
80105547:	85 c0                	test   %eax,%eax
80105549:	79 07                	jns    80105552 <sys_read+0x52>
    return -1;
8010554b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105550:	eb 17                	jmp    80105569 <sys_read+0x69>
  return fileread(f, p, n);
80105552:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105555:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555b:	83 ec 04             	sub    $0x4,%esp
8010555e:	51                   	push   %ecx
8010555f:	52                   	push   %edx
80105560:	50                   	push   %eax
80105561:	e8 6a bc ff ff       	call   801011d0 <fileread>
80105566:	83 c4 10             	add    $0x10,%esp
}
80105569:	c9                   	leave  
8010556a:	c3                   	ret    

8010556b <sys_write>:

int
sys_write(void)
{
8010556b:	55                   	push   %ebp
8010556c:	89 e5                	mov    %esp,%ebp
8010556e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105571:	83 ec 04             	sub    $0x4,%esp
80105574:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105577:	50                   	push   %eax
80105578:	6a 00                	push   $0x0
8010557a:	6a 00                	push   $0x0
8010557c:	e8 66 fe ff ff       	call   801053e7 <argfd>
80105581:	83 c4 10             	add    $0x10,%esp
80105584:	85 c0                	test   %eax,%eax
80105586:	78 2e                	js     801055b6 <sys_write+0x4b>
80105588:	83 ec 08             	sub    $0x8,%esp
8010558b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010558e:	50                   	push   %eax
8010558f:	6a 02                	push   $0x2
80105591:	e8 16 fd ff ff       	call   801052ac <argint>
80105596:	83 c4 10             	add    $0x10,%esp
80105599:	85 c0                	test   %eax,%eax
8010559b:	78 19                	js     801055b6 <sys_write+0x4b>
8010559d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a0:	83 ec 04             	sub    $0x4,%esp
801055a3:	50                   	push   %eax
801055a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055a7:	50                   	push   %eax
801055a8:	6a 01                	push   $0x1
801055aa:	e8 2a fd ff ff       	call   801052d9 <argptr>
801055af:	83 c4 10             	add    $0x10,%esp
801055b2:	85 c0                	test   %eax,%eax
801055b4:	79 07                	jns    801055bd <sys_write+0x52>
    return -1;
801055b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bb:	eb 17                	jmp    801055d4 <sys_write+0x69>
  return filewrite(f, p, n);
801055bd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c6:	83 ec 04             	sub    $0x4,%esp
801055c9:	51                   	push   %ecx
801055ca:	52                   	push   %edx
801055cb:	50                   	push   %eax
801055cc:	e8 b7 bc ff ff       	call   80101288 <filewrite>
801055d1:	83 c4 10             	add    $0x10,%esp
}
801055d4:	c9                   	leave  
801055d5:	c3                   	ret    

801055d6 <sys_close>:

int
sys_close(void)
{
801055d6:	55                   	push   %ebp
801055d7:	89 e5                	mov    %esp,%ebp
801055d9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801055dc:	83 ec 04             	sub    $0x4,%esp
801055df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055e2:	50                   	push   %eax
801055e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055e6:	50                   	push   %eax
801055e7:	6a 00                	push   $0x0
801055e9:	e8 f9 fd ff ff       	call   801053e7 <argfd>
801055ee:	83 c4 10             	add    $0x10,%esp
801055f1:	85 c0                	test   %eax,%eax
801055f3:	79 07                	jns    801055fc <sys_close+0x26>
    return -1;
801055f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055fa:	eb 27                	jmp    80105623 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801055fc:	e8 09 e9 ff ff       	call   80103f0a <myproc>
80105601:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105604:	83 c2 08             	add    $0x8,%edx
80105607:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010560e:	00 
  fileclose(f);
8010560f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105612:	83 ec 0c             	sub    $0xc,%esp
80105615:	50                   	push   %eax
80105616:	e8 76 ba ff ff       	call   80101091 <fileclose>
8010561b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010561e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105623:	c9                   	leave  
80105624:	c3                   	ret    

80105625 <sys_fstat>:

int
sys_fstat(void)
{
80105625:	55                   	push   %ebp
80105626:	89 e5                	mov    %esp,%ebp
80105628:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010562b:	83 ec 04             	sub    $0x4,%esp
8010562e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105631:	50                   	push   %eax
80105632:	6a 00                	push   $0x0
80105634:	6a 00                	push   $0x0
80105636:	e8 ac fd ff ff       	call   801053e7 <argfd>
8010563b:	83 c4 10             	add    $0x10,%esp
8010563e:	85 c0                	test   %eax,%eax
80105640:	78 17                	js     80105659 <sys_fstat+0x34>
80105642:	83 ec 04             	sub    $0x4,%esp
80105645:	6a 14                	push   $0x14
80105647:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010564a:	50                   	push   %eax
8010564b:	6a 01                	push   $0x1
8010564d:	e8 87 fc ff ff       	call   801052d9 <argptr>
80105652:	83 c4 10             	add    $0x10,%esp
80105655:	85 c0                	test   %eax,%eax
80105657:	79 07                	jns    80105660 <sys_fstat+0x3b>
    return -1;
80105659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565e:	eb 13                	jmp    80105673 <sys_fstat+0x4e>
  return filestat(f, st);
80105660:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105666:	83 ec 08             	sub    $0x8,%esp
80105669:	52                   	push   %edx
8010566a:	50                   	push   %eax
8010566b:	e8 09 bb ff ff       	call   80101179 <filestat>
80105670:	83 c4 10             	add    $0x10,%esp
}
80105673:	c9                   	leave  
80105674:	c3                   	ret    

80105675 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105675:	55                   	push   %ebp
80105676:	89 e5                	mov    %esp,%ebp
80105678:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010567b:	83 ec 08             	sub    $0x8,%esp
8010567e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105681:	50                   	push   %eax
80105682:	6a 00                	push   $0x0
80105684:	e8 a9 fc ff ff       	call   80105332 <argstr>
80105689:	83 c4 10             	add    $0x10,%esp
8010568c:	85 c0                	test   %eax,%eax
8010568e:	78 15                	js     801056a5 <sys_link+0x30>
80105690:	83 ec 08             	sub    $0x8,%esp
80105693:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105696:	50                   	push   %eax
80105697:	6a 01                	push   $0x1
80105699:	e8 94 fc ff ff       	call   80105332 <argstr>
8010569e:	83 c4 10             	add    $0x10,%esp
801056a1:	85 c0                	test   %eax,%eax
801056a3:	79 0a                	jns    801056af <sys_link+0x3a>
    return -1;
801056a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056aa:	e9 68 01 00 00       	jmp    80105817 <sys_link+0x1a2>

  begin_op();
801056af:	e8 62 de ff ff       	call   80103516 <begin_op>
  if((ip = namei(old)) == 0){
801056b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801056b7:	83 ec 0c             	sub    $0xc,%esp
801056ba:	50                   	push   %eax
801056bb:	e8 53 ce ff ff       	call   80102513 <namei>
801056c0:	83 c4 10             	add    $0x10,%esp
801056c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ca:	75 0f                	jne    801056db <sys_link+0x66>
    end_op();
801056cc:	e8 d1 de ff ff       	call   801035a2 <end_op>
    return -1;
801056d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d6:	e9 3c 01 00 00       	jmp    80105817 <sys_link+0x1a2>
  }

  ilock(ip);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f4             	push   -0xc(%ebp)
801056e1:	e8 fa c2 ff ff       	call   801019e0 <ilock>
801056e6:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056f0:	66 83 f8 01          	cmp    $0x1,%ax
801056f4:	75 1d                	jne    80105713 <sys_link+0x9e>
    iunlockput(ip);
801056f6:	83 ec 0c             	sub    $0xc,%esp
801056f9:	ff 75 f4             	push   -0xc(%ebp)
801056fc:	e8 10 c5 ff ff       	call   80101c11 <iunlockput>
80105701:	83 c4 10             	add    $0x10,%esp
    end_op();
80105704:	e8 99 de ff ff       	call   801035a2 <end_op>
    return -1;
80105709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010570e:	e9 04 01 00 00       	jmp    80105817 <sys_link+0x1a2>
  }

  ip->nlink++;
80105713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105716:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010571a:	83 c0 01             	add    $0x1,%eax
8010571d:	89 c2                	mov    %eax,%edx
8010571f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105722:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105726:	83 ec 0c             	sub    $0xc,%esp
80105729:	ff 75 f4             	push   -0xc(%ebp)
8010572c:	e8 d2 c0 ff ff       	call   80101803 <iupdate>
80105731:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105734:	83 ec 0c             	sub    $0xc,%esp
80105737:	ff 75 f4             	push   -0xc(%ebp)
8010573a:	e8 b4 c3 ff ff       	call   80101af3 <iunlock>
8010573f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105742:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105745:	83 ec 08             	sub    $0x8,%esp
80105748:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010574b:	52                   	push   %edx
8010574c:	50                   	push   %eax
8010574d:	e8 dd cd ff ff       	call   8010252f <nameiparent>
80105752:	83 c4 10             	add    $0x10,%esp
80105755:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105758:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010575c:	74 71                	je     801057cf <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	ff 75 f0             	push   -0x10(%ebp)
80105764:	e8 77 c2 ff ff       	call   801019e0 <ilock>
80105769:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010576c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576f:	8b 10                	mov    (%eax),%edx
80105771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105774:	8b 00                	mov    (%eax),%eax
80105776:	39 c2                	cmp    %eax,%edx
80105778:	75 1d                	jne    80105797 <sys_link+0x122>
8010577a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577d:	8b 40 04             	mov    0x4(%eax),%eax
80105780:	83 ec 04             	sub    $0x4,%esp
80105783:	50                   	push   %eax
80105784:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105787:	50                   	push   %eax
80105788:	ff 75 f0             	push   -0x10(%ebp)
8010578b:	e8 ec ca ff ff       	call   8010227c <dirlink>
80105790:	83 c4 10             	add    $0x10,%esp
80105793:	85 c0                	test   %eax,%eax
80105795:	79 10                	jns    801057a7 <sys_link+0x132>
    iunlockput(dp);
80105797:	83 ec 0c             	sub    $0xc,%esp
8010579a:	ff 75 f0             	push   -0x10(%ebp)
8010579d:	e8 6f c4 ff ff       	call   80101c11 <iunlockput>
801057a2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057a5:	eb 29                	jmp    801057d0 <sys_link+0x15b>
  }
  iunlockput(dp);
801057a7:	83 ec 0c             	sub    $0xc,%esp
801057aa:	ff 75 f0             	push   -0x10(%ebp)
801057ad:	e8 5f c4 ff ff       	call   80101c11 <iunlockput>
801057b2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801057b5:	83 ec 0c             	sub    $0xc,%esp
801057b8:	ff 75 f4             	push   -0xc(%ebp)
801057bb:	e8 81 c3 ff ff       	call   80101b41 <iput>
801057c0:	83 c4 10             	add    $0x10,%esp

  end_op();
801057c3:	e8 da dd ff ff       	call   801035a2 <end_op>

  return 0;
801057c8:	b8 00 00 00 00       	mov    $0x0,%eax
801057cd:	eb 48                	jmp    80105817 <sys_link+0x1a2>
    goto bad;
801057cf:	90                   	nop

bad:
  ilock(ip);
801057d0:	83 ec 0c             	sub    $0xc,%esp
801057d3:	ff 75 f4             	push   -0xc(%ebp)
801057d6:	e8 05 c2 ff ff       	call   801019e0 <ilock>
801057db:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801057de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057e5:	83 e8 01             	sub    $0x1,%eax
801057e8:	89 c2                	mov    %eax,%edx
801057ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ed:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057f1:	83 ec 0c             	sub    $0xc,%esp
801057f4:	ff 75 f4             	push   -0xc(%ebp)
801057f7:	e8 07 c0 ff ff       	call   80101803 <iupdate>
801057fc:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801057ff:	83 ec 0c             	sub    $0xc,%esp
80105802:	ff 75 f4             	push   -0xc(%ebp)
80105805:	e8 07 c4 ff ff       	call   80101c11 <iunlockput>
8010580a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010580d:	e8 90 dd ff ff       	call   801035a2 <end_op>
  return -1;
80105812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105817:	c9                   	leave  
80105818:	c3                   	ret    

80105819 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105819:	55                   	push   %ebp
8010581a:	89 e5                	mov    %esp,%ebp
8010581c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010581f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105826:	eb 40                	jmp    80105868 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582b:	6a 10                	push   $0x10
8010582d:	50                   	push   %eax
8010582e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105831:	50                   	push   %eax
80105832:	ff 75 08             	push   0x8(%ebp)
80105835:	e8 92 c6 ff ff       	call   80101ecc <readi>
8010583a:	83 c4 10             	add    $0x10,%esp
8010583d:	83 f8 10             	cmp    $0x10,%eax
80105840:	74 0d                	je     8010584f <isdirempty+0x36>
      panic("isdirempty: readi");
80105842:	83 ec 0c             	sub    $0xc,%esp
80105845:	68 1e ab 10 80       	push   $0x8010ab1e
8010584a:	e8 5a ad ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010584f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105853:	66 85 c0             	test   %ax,%ax
80105856:	74 07                	je     8010585f <isdirempty+0x46>
      return 0;
80105858:	b8 00 00 00 00       	mov    $0x0,%eax
8010585d:	eb 1b                	jmp    8010587a <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010585f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105862:	83 c0 10             	add    $0x10,%eax
80105865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105868:	8b 45 08             	mov    0x8(%ebp),%eax
8010586b:	8b 50 58             	mov    0x58(%eax),%edx
8010586e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105871:	39 c2                	cmp    %eax,%edx
80105873:	77 b3                	ja     80105828 <isdirempty+0xf>
  }
  return 1;
80105875:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010587a:	c9                   	leave  
8010587b:	c3                   	ret    

8010587c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010587c:	55                   	push   %ebp
8010587d:	89 e5                	mov    %esp,%ebp
8010587f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105882:	83 ec 08             	sub    $0x8,%esp
80105885:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105888:	50                   	push   %eax
80105889:	6a 00                	push   $0x0
8010588b:	e8 a2 fa ff ff       	call   80105332 <argstr>
80105890:	83 c4 10             	add    $0x10,%esp
80105893:	85 c0                	test   %eax,%eax
80105895:	79 0a                	jns    801058a1 <sys_unlink+0x25>
    return -1;
80105897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589c:	e9 bf 01 00 00       	jmp    80105a60 <sys_unlink+0x1e4>

  begin_op();
801058a1:	e8 70 dc ff ff       	call   80103516 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801058a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801058a9:	83 ec 08             	sub    $0x8,%esp
801058ac:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801058af:	52                   	push   %edx
801058b0:	50                   	push   %eax
801058b1:	e8 79 cc ff ff       	call   8010252f <nameiparent>
801058b6:	83 c4 10             	add    $0x10,%esp
801058b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c0:	75 0f                	jne    801058d1 <sys_unlink+0x55>
    end_op();
801058c2:	e8 db dc ff ff       	call   801035a2 <end_op>
    return -1;
801058c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058cc:	e9 8f 01 00 00       	jmp    80105a60 <sys_unlink+0x1e4>
  }

  ilock(dp);
801058d1:	83 ec 0c             	sub    $0xc,%esp
801058d4:	ff 75 f4             	push   -0xc(%ebp)
801058d7:	e8 04 c1 ff ff       	call   801019e0 <ilock>
801058dc:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801058df:	83 ec 08             	sub    $0x8,%esp
801058e2:	68 30 ab 10 80       	push   $0x8010ab30
801058e7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801058ea:	50                   	push   %eax
801058eb:	e8 b7 c8 ff ff       	call   801021a7 <namecmp>
801058f0:	83 c4 10             	add    $0x10,%esp
801058f3:	85 c0                	test   %eax,%eax
801058f5:	0f 84 49 01 00 00    	je     80105a44 <sys_unlink+0x1c8>
801058fb:	83 ec 08             	sub    $0x8,%esp
801058fe:	68 32 ab 10 80       	push   $0x8010ab32
80105903:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105906:	50                   	push   %eax
80105907:	e8 9b c8 ff ff       	call   801021a7 <namecmp>
8010590c:	83 c4 10             	add    $0x10,%esp
8010590f:	85 c0                	test   %eax,%eax
80105911:	0f 84 2d 01 00 00    	je     80105a44 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105917:	83 ec 04             	sub    $0x4,%esp
8010591a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010591d:	50                   	push   %eax
8010591e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105921:	50                   	push   %eax
80105922:	ff 75 f4             	push   -0xc(%ebp)
80105925:	e8 98 c8 ff ff       	call   801021c2 <dirlookup>
8010592a:	83 c4 10             	add    $0x10,%esp
8010592d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105934:	0f 84 0d 01 00 00    	je     80105a47 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010593a:	83 ec 0c             	sub    $0xc,%esp
8010593d:	ff 75 f0             	push   -0x10(%ebp)
80105940:	e8 9b c0 ff ff       	call   801019e0 <ilock>
80105945:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010594f:	66 85 c0             	test   %ax,%ax
80105952:	7f 0d                	jg     80105961 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105954:	83 ec 0c             	sub    $0xc,%esp
80105957:	68 35 ab 10 80       	push   $0x8010ab35
8010595c:	e8 48 ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105964:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105968:	66 83 f8 01          	cmp    $0x1,%ax
8010596c:	75 25                	jne    80105993 <sys_unlink+0x117>
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	ff 75 f0             	push   -0x10(%ebp)
80105974:	e8 a0 fe ff ff       	call   80105819 <isdirempty>
80105979:	83 c4 10             	add    $0x10,%esp
8010597c:	85 c0                	test   %eax,%eax
8010597e:	75 13                	jne    80105993 <sys_unlink+0x117>
    iunlockput(ip);
80105980:	83 ec 0c             	sub    $0xc,%esp
80105983:	ff 75 f0             	push   -0x10(%ebp)
80105986:	e8 86 c2 ff ff       	call   80101c11 <iunlockput>
8010598b:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010598e:	e9 b5 00 00 00       	jmp    80105a48 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105993:	83 ec 04             	sub    $0x4,%esp
80105996:	6a 10                	push   $0x10
80105998:	6a 00                	push   $0x0
8010599a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010599d:	50                   	push   %eax
8010599e:	e8 fa f5 ff ff       	call   80104f9d <memset>
801059a3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801059a9:	6a 10                	push   $0x10
801059ab:	50                   	push   %eax
801059ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059af:	50                   	push   %eax
801059b0:	ff 75 f4             	push   -0xc(%ebp)
801059b3:	e8 69 c6 ff ff       	call   80102021 <writei>
801059b8:	83 c4 10             	add    $0x10,%esp
801059bb:	83 f8 10             	cmp    $0x10,%eax
801059be:	74 0d                	je     801059cd <sys_unlink+0x151>
    panic("unlink: writei");
801059c0:	83 ec 0c             	sub    $0xc,%esp
801059c3:	68 47 ab 10 80       	push   $0x8010ab47
801059c8:	e8 dc ab ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801059cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059d4:	66 83 f8 01          	cmp    $0x1,%ax
801059d8:	75 21                	jne    801059fb <sys_unlink+0x17f>
    dp->nlink--;
801059da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059dd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059e1:	83 e8 01             	sub    $0x1,%eax
801059e4:	89 c2                	mov    %eax,%edx
801059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059ed:	83 ec 0c             	sub    $0xc,%esp
801059f0:	ff 75 f4             	push   -0xc(%ebp)
801059f3:	e8 0b be ff ff       	call   80101803 <iupdate>
801059f8:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801059fb:	83 ec 0c             	sub    $0xc,%esp
801059fe:	ff 75 f4             	push   -0xc(%ebp)
80105a01:	e8 0b c2 ff ff       	call   80101c11 <iunlockput>
80105a06:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a10:	83 e8 01             	sub    $0x1,%eax
80105a13:	89 c2                	mov    %eax,%edx
80105a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a18:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a1c:	83 ec 0c             	sub    $0xc,%esp
80105a1f:	ff 75 f0             	push   -0x10(%ebp)
80105a22:	e8 dc bd ff ff       	call   80101803 <iupdate>
80105a27:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a2a:	83 ec 0c             	sub    $0xc,%esp
80105a2d:	ff 75 f0             	push   -0x10(%ebp)
80105a30:	e8 dc c1 ff ff       	call   80101c11 <iunlockput>
80105a35:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a38:	e8 65 db ff ff       	call   801035a2 <end_op>

  return 0;
80105a3d:	b8 00 00 00 00       	mov    $0x0,%eax
80105a42:	eb 1c                	jmp    80105a60 <sys_unlink+0x1e4>
    goto bad;
80105a44:	90                   	nop
80105a45:	eb 01                	jmp    80105a48 <sys_unlink+0x1cc>
    goto bad;
80105a47:	90                   	nop

bad:
  iunlockput(dp);
80105a48:	83 ec 0c             	sub    $0xc,%esp
80105a4b:	ff 75 f4             	push   -0xc(%ebp)
80105a4e:	e8 be c1 ff ff       	call   80101c11 <iunlockput>
80105a53:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a56:	e8 47 db ff ff       	call   801035a2 <end_op>
  return -1;
80105a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a60:	c9                   	leave  
80105a61:	c3                   	ret    

80105a62 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 38             	sub    $0x38,%esp
80105a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105a6b:	8b 55 10             	mov    0x10(%ebp),%edx
80105a6e:	8b 45 14             	mov    0x14(%ebp),%eax
80105a71:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105a75:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105a79:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105a7d:	83 ec 08             	sub    $0x8,%esp
80105a80:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a83:	50                   	push   %eax
80105a84:	ff 75 08             	push   0x8(%ebp)
80105a87:	e8 a3 ca ff ff       	call   8010252f <nameiparent>
80105a8c:	83 c4 10             	add    $0x10,%esp
80105a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a96:	75 0a                	jne    80105aa2 <create+0x40>
    return 0;
80105a98:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9d:	e9 90 01 00 00       	jmp    80105c32 <create+0x1d0>
  ilock(dp);
80105aa2:	83 ec 0c             	sub    $0xc,%esp
80105aa5:	ff 75 f4             	push   -0xc(%ebp)
80105aa8:	e8 33 bf ff ff       	call   801019e0 <ilock>
80105aad:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ab0:	83 ec 04             	sub    $0x4,%esp
80105ab3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ab6:	50                   	push   %eax
80105ab7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105aba:	50                   	push   %eax
80105abb:	ff 75 f4             	push   -0xc(%ebp)
80105abe:	e8 ff c6 ff ff       	call   801021c2 <dirlookup>
80105ac3:	83 c4 10             	add    $0x10,%esp
80105ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ac9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105acd:	74 50                	je     80105b1f <create+0xbd>
    iunlockput(dp);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f4             	push   -0xc(%ebp)
80105ad5:	e8 37 c1 ff ff       	call   80101c11 <iunlockput>
80105ada:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105add:	83 ec 0c             	sub    $0xc,%esp
80105ae0:	ff 75 f0             	push   -0x10(%ebp)
80105ae3:	e8 f8 be ff ff       	call   801019e0 <ilock>
80105ae8:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105aeb:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105af0:	75 15                	jne    80105b07 <create+0xa5>
80105af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105af9:	66 83 f8 02          	cmp    $0x2,%ax
80105afd:	75 08                	jne    80105b07 <create+0xa5>
      return ip;
80105aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b02:	e9 2b 01 00 00       	jmp    80105c32 <create+0x1d0>
    iunlockput(ip);
80105b07:	83 ec 0c             	sub    $0xc,%esp
80105b0a:	ff 75 f0             	push   -0x10(%ebp)
80105b0d:	e8 ff c0 ff ff       	call   80101c11 <iunlockput>
80105b12:	83 c4 10             	add    $0x10,%esp
    return 0;
80105b15:	b8 00 00 00 00       	mov    $0x0,%eax
80105b1a:	e9 13 01 00 00       	jmp    80105c32 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b1f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b26:	8b 00                	mov    (%eax),%eax
80105b28:	83 ec 08             	sub    $0x8,%esp
80105b2b:	52                   	push   %edx
80105b2c:	50                   	push   %eax
80105b2d:	e8 fa bb ff ff       	call   8010172c <ialloc>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b3c:	75 0d                	jne    80105b4b <create+0xe9>
    panic("create: ialloc");
80105b3e:	83 ec 0c             	sub    $0xc,%esp
80105b41:	68 56 ab 10 80       	push   $0x8010ab56
80105b46:	e8 5e aa ff ff       	call   801005a9 <panic>

  ilock(ip);
80105b4b:	83 ec 0c             	sub    $0xc,%esp
80105b4e:	ff 75 f0             	push   -0x10(%ebp)
80105b51:	e8 8a be ff ff       	call   801019e0 <ilock>
80105b56:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105b60:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b67:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105b6b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b72:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105b78:	83 ec 0c             	sub    $0xc,%esp
80105b7b:	ff 75 f0             	push   -0x10(%ebp)
80105b7e:	e8 80 bc ff ff       	call   80101803 <iupdate>
80105b83:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105b86:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105b8b:	75 6a                	jne    80105bf7 <create+0x195>
    dp->nlink++;  // for ".."
80105b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b90:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b94:	83 c0 01             	add    $0x1,%eax
80105b97:	89 c2                	mov    %eax,%edx
80105b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ba0:	83 ec 0c             	sub    $0xc,%esp
80105ba3:	ff 75 f4             	push   -0xc(%ebp)
80105ba6:	e8 58 bc ff ff       	call   80101803 <iupdate>
80105bab:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb1:	8b 40 04             	mov    0x4(%eax),%eax
80105bb4:	83 ec 04             	sub    $0x4,%esp
80105bb7:	50                   	push   %eax
80105bb8:	68 30 ab 10 80       	push   $0x8010ab30
80105bbd:	ff 75 f0             	push   -0x10(%ebp)
80105bc0:	e8 b7 c6 ff ff       	call   8010227c <dirlink>
80105bc5:	83 c4 10             	add    $0x10,%esp
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	78 1e                	js     80105bea <create+0x188>
80105bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcf:	8b 40 04             	mov    0x4(%eax),%eax
80105bd2:	83 ec 04             	sub    $0x4,%esp
80105bd5:	50                   	push   %eax
80105bd6:	68 32 ab 10 80       	push   $0x8010ab32
80105bdb:	ff 75 f0             	push   -0x10(%ebp)
80105bde:	e8 99 c6 ff ff       	call   8010227c <dirlink>
80105be3:	83 c4 10             	add    $0x10,%esp
80105be6:	85 c0                	test   %eax,%eax
80105be8:	79 0d                	jns    80105bf7 <create+0x195>
      panic("create dots");
80105bea:	83 ec 0c             	sub    $0xc,%esp
80105bed:	68 65 ab 10 80       	push   $0x8010ab65
80105bf2:	e8 b2 a9 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfa:	8b 40 04             	mov    0x4(%eax),%eax
80105bfd:	83 ec 04             	sub    $0x4,%esp
80105c00:	50                   	push   %eax
80105c01:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c04:	50                   	push   %eax
80105c05:	ff 75 f4             	push   -0xc(%ebp)
80105c08:	e8 6f c6 ff ff       	call   8010227c <dirlink>
80105c0d:	83 c4 10             	add    $0x10,%esp
80105c10:	85 c0                	test   %eax,%eax
80105c12:	79 0d                	jns    80105c21 <create+0x1bf>
    panic("create: dirlink");
80105c14:	83 ec 0c             	sub    $0xc,%esp
80105c17:	68 71 ab 10 80       	push   $0x8010ab71
80105c1c:	e8 88 a9 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105c21:	83 ec 0c             	sub    $0xc,%esp
80105c24:	ff 75 f4             	push   -0xc(%ebp)
80105c27:	e8 e5 bf ff ff       	call   80101c11 <iunlockput>
80105c2c:	83 c4 10             	add    $0x10,%esp

  return ip;
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c32:	c9                   	leave  
80105c33:	c3                   	ret    

80105c34 <sys_open>:

int
sys_open(void)
{
80105c34:	55                   	push   %ebp
80105c35:	89 e5                	mov    %esp,%ebp
80105c37:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c3a:	83 ec 08             	sub    $0x8,%esp
80105c3d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c40:	50                   	push   %eax
80105c41:	6a 00                	push   $0x0
80105c43:	e8 ea f6 ff ff       	call   80105332 <argstr>
80105c48:	83 c4 10             	add    $0x10,%esp
80105c4b:	85 c0                	test   %eax,%eax
80105c4d:	78 15                	js     80105c64 <sys_open+0x30>
80105c4f:	83 ec 08             	sub    $0x8,%esp
80105c52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c55:	50                   	push   %eax
80105c56:	6a 01                	push   $0x1
80105c58:	e8 4f f6 ff ff       	call   801052ac <argint>
80105c5d:	83 c4 10             	add    $0x10,%esp
80105c60:	85 c0                	test   %eax,%eax
80105c62:	79 0a                	jns    80105c6e <sys_open+0x3a>
    return -1;
80105c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c69:	e9 61 01 00 00       	jmp    80105dcf <sys_open+0x19b>

  begin_op();
80105c6e:	e8 a3 d8 ff ff       	call   80103516 <begin_op>

  if(omode & O_CREATE){
80105c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c76:	25 00 02 00 00       	and    $0x200,%eax
80105c7b:	85 c0                	test   %eax,%eax
80105c7d:	74 2a                	je     80105ca9 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c82:	6a 00                	push   $0x0
80105c84:	6a 00                	push   $0x0
80105c86:	6a 02                	push   $0x2
80105c88:	50                   	push   %eax
80105c89:	e8 d4 fd ff ff       	call   80105a62 <create>
80105c8e:	83 c4 10             	add    $0x10,%esp
80105c91:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105c94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c98:	75 75                	jne    80105d0f <sys_open+0xdb>
      end_op();
80105c9a:	e8 03 d9 ff ff       	call   801035a2 <end_op>
      return -1;
80105c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca4:	e9 26 01 00 00       	jmp    80105dcf <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ca9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cac:	83 ec 0c             	sub    $0xc,%esp
80105caf:	50                   	push   %eax
80105cb0:	e8 5e c8 ff ff       	call   80102513 <namei>
80105cb5:	83 c4 10             	add    $0x10,%esp
80105cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cbf:	75 0f                	jne    80105cd0 <sys_open+0x9c>
      end_op();
80105cc1:	e8 dc d8 ff ff       	call   801035a2 <end_op>
      return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	e9 ff 00 00 00       	jmp    80105dcf <sys_open+0x19b>
    }
    ilock(ip);
80105cd0:	83 ec 0c             	sub    $0xc,%esp
80105cd3:	ff 75 f4             	push   -0xc(%ebp)
80105cd6:	e8 05 bd ff ff       	call   801019e0 <ilock>
80105cdb:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ce5:	66 83 f8 01          	cmp    $0x1,%ax
80105ce9:	75 24                	jne    80105d0f <sys_open+0xdb>
80105ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cee:	85 c0                	test   %eax,%eax
80105cf0:	74 1d                	je     80105d0f <sys_open+0xdb>
      iunlockput(ip);
80105cf2:	83 ec 0c             	sub    $0xc,%esp
80105cf5:	ff 75 f4             	push   -0xc(%ebp)
80105cf8:	e8 14 bf ff ff       	call   80101c11 <iunlockput>
80105cfd:	83 c4 10             	add    $0x10,%esp
      end_op();
80105d00:	e8 9d d8 ff ff       	call   801035a2 <end_op>
      return -1;
80105d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0a:	e9 c0 00 00 00       	jmp    80105dcf <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d0f:	e8 bf b2 ff ff       	call   80100fd3 <filealloc>
80105d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d1b:	74 17                	je     80105d34 <sys_open+0x100>
80105d1d:	83 ec 0c             	sub    $0xc,%esp
80105d20:	ff 75 f0             	push   -0x10(%ebp)
80105d23:	e8 33 f7 ff ff       	call   8010545b <fdalloc>
80105d28:	83 c4 10             	add    $0x10,%esp
80105d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d2e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d32:	79 2e                	jns    80105d62 <sys_open+0x12e>
    if(f)
80105d34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d38:	74 0e                	je     80105d48 <sys_open+0x114>
      fileclose(f);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f0             	push   -0x10(%ebp)
80105d40:	e8 4c b3 ff ff       	call   80101091 <fileclose>
80105d45:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105d48:	83 ec 0c             	sub    $0xc,%esp
80105d4b:	ff 75 f4             	push   -0xc(%ebp)
80105d4e:	e8 be be ff ff       	call   80101c11 <iunlockput>
80105d53:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d56:	e8 47 d8 ff ff       	call   801035a2 <end_op>
    return -1;
80105d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d60:	eb 6d                	jmp    80105dcf <sys_open+0x19b>
  }
  iunlock(ip);
80105d62:	83 ec 0c             	sub    $0xc,%esp
80105d65:	ff 75 f4             	push   -0xc(%ebp)
80105d68:	e8 86 bd ff ff       	call   80101af3 <iunlock>
80105d6d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d70:	e8 2d d8 ff ff       	call   801035a2 <end_op>

  f->type = FD_INODE;
80105d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d78:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d84:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d94:	83 e0 01             	and    $0x1,%eax
80105d97:	85 c0                	test   %eax,%eax
80105d99:	0f 94 c0             	sete   %al
80105d9c:	89 c2                	mov    %eax,%edx
80105d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105da7:	83 e0 01             	and    $0x1,%eax
80105daa:	85 c0                	test   %eax,%eax
80105dac:	75 0a                	jne    80105db8 <sys_open+0x184>
80105dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db1:	83 e0 02             	and    $0x2,%eax
80105db4:	85 c0                	test   %eax,%eax
80105db6:	74 07                	je     80105dbf <sys_open+0x18b>
80105db8:	b8 01 00 00 00       	mov    $0x1,%eax
80105dbd:	eb 05                	jmp    80105dc4 <sys_open+0x190>
80105dbf:	b8 00 00 00 00       	mov    $0x0,%eax
80105dc4:	89 c2                	mov    %eax,%edx
80105dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105dcf:	c9                   	leave  
80105dd0:	c3                   	ret    

80105dd1 <sys_mkdir>:

int
sys_mkdir(void)
{
80105dd1:	55                   	push   %ebp
80105dd2:	89 e5                	mov    %esp,%ebp
80105dd4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105dd7:	e8 3a d7 ff ff       	call   80103516 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ddc:	83 ec 08             	sub    $0x8,%esp
80105ddf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105de2:	50                   	push   %eax
80105de3:	6a 00                	push   $0x0
80105de5:	e8 48 f5 ff ff       	call   80105332 <argstr>
80105dea:	83 c4 10             	add    $0x10,%esp
80105ded:	85 c0                	test   %eax,%eax
80105def:	78 1b                	js     80105e0c <sys_mkdir+0x3b>
80105df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df4:	6a 00                	push   $0x0
80105df6:	6a 00                	push   $0x0
80105df8:	6a 01                	push   $0x1
80105dfa:	50                   	push   %eax
80105dfb:	e8 62 fc ff ff       	call   80105a62 <create>
80105e00:	83 c4 10             	add    $0x10,%esp
80105e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e0a:	75 0c                	jne    80105e18 <sys_mkdir+0x47>
    end_op();
80105e0c:	e8 91 d7 ff ff       	call   801035a2 <end_op>
    return -1;
80105e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e16:	eb 18                	jmp    80105e30 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105e18:	83 ec 0c             	sub    $0xc,%esp
80105e1b:	ff 75 f4             	push   -0xc(%ebp)
80105e1e:	e8 ee bd ff ff       	call   80101c11 <iunlockput>
80105e23:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e26:	e8 77 d7 ff ff       	call   801035a2 <end_op>
  return 0;
80105e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e30:	c9                   	leave  
80105e31:	c3                   	ret    

80105e32 <sys_mknod>:

int
sys_mknod(void)
{
80105e32:	55                   	push   %ebp
80105e33:	89 e5                	mov    %esp,%ebp
80105e35:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105e38:	e8 d9 d6 ff ff       	call   80103516 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105e3d:	83 ec 08             	sub    $0x8,%esp
80105e40:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e43:	50                   	push   %eax
80105e44:	6a 00                	push   $0x0
80105e46:	e8 e7 f4 ff ff       	call   80105332 <argstr>
80105e4b:	83 c4 10             	add    $0x10,%esp
80105e4e:	85 c0                	test   %eax,%eax
80105e50:	78 4f                	js     80105ea1 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105e52:	83 ec 08             	sub    $0x8,%esp
80105e55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e58:	50                   	push   %eax
80105e59:	6a 01                	push   $0x1
80105e5b:	e8 4c f4 ff ff       	call   801052ac <argint>
80105e60:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105e63:	85 c0                	test   %eax,%eax
80105e65:	78 3a                	js     80105ea1 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105e67:	83 ec 08             	sub    $0x8,%esp
80105e6a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e6d:	50                   	push   %eax
80105e6e:	6a 02                	push   $0x2
80105e70:	e8 37 f4 ff ff       	call   801052ac <argint>
80105e75:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105e78:	85 c0                	test   %eax,%eax
80105e7a:	78 25                	js     80105ea1 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105e7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e7f:	0f bf c8             	movswl %ax,%ecx
80105e82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e85:	0f bf d0             	movswl %ax,%edx
80105e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8b:	51                   	push   %ecx
80105e8c:	52                   	push   %edx
80105e8d:	6a 03                	push   $0x3
80105e8f:	50                   	push   %eax
80105e90:	e8 cd fb ff ff       	call   80105a62 <create>
80105e95:	83 c4 10             	add    $0x10,%esp
80105e98:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105e9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e9f:	75 0c                	jne    80105ead <sys_mknod+0x7b>
    end_op();
80105ea1:	e8 fc d6 ff ff       	call   801035a2 <end_op>
    return -1;
80105ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eab:	eb 18                	jmp    80105ec5 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105ead:	83 ec 0c             	sub    $0xc,%esp
80105eb0:	ff 75 f4             	push   -0xc(%ebp)
80105eb3:	e8 59 bd ff ff       	call   80101c11 <iunlockput>
80105eb8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ebb:	e8 e2 d6 ff ff       	call   801035a2 <end_op>
  return 0;
80105ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ec5:	c9                   	leave  
80105ec6:	c3                   	ret    

80105ec7 <sys_chdir>:

int
sys_chdir(void)
{
80105ec7:	55                   	push   %ebp
80105ec8:	89 e5                	mov    %esp,%ebp
80105eca:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ecd:	e8 38 e0 ff ff       	call   80103f0a <myproc>
80105ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105ed5:	e8 3c d6 ff ff       	call   80103516 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105eda:	83 ec 08             	sub    $0x8,%esp
80105edd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ee0:	50                   	push   %eax
80105ee1:	6a 00                	push   $0x0
80105ee3:	e8 4a f4 ff ff       	call   80105332 <argstr>
80105ee8:	83 c4 10             	add    $0x10,%esp
80105eeb:	85 c0                	test   %eax,%eax
80105eed:	78 18                	js     80105f07 <sys_chdir+0x40>
80105eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ef2:	83 ec 0c             	sub    $0xc,%esp
80105ef5:	50                   	push   %eax
80105ef6:	e8 18 c6 ff ff       	call   80102513 <namei>
80105efb:	83 c4 10             	add    $0x10,%esp
80105efe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f05:	75 0c                	jne    80105f13 <sys_chdir+0x4c>
    end_op();
80105f07:	e8 96 d6 ff ff       	call   801035a2 <end_op>
    return -1;
80105f0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f11:	eb 68                	jmp    80105f7b <sys_chdir+0xb4>
  }
  ilock(ip);
80105f13:	83 ec 0c             	sub    $0xc,%esp
80105f16:	ff 75 f0             	push   -0x10(%ebp)
80105f19:	e8 c2 ba ff ff       	call   801019e0 <ilock>
80105f1e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f24:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f28:	66 83 f8 01          	cmp    $0x1,%ax
80105f2c:	74 1a                	je     80105f48 <sys_chdir+0x81>
    iunlockput(ip);
80105f2e:	83 ec 0c             	sub    $0xc,%esp
80105f31:	ff 75 f0             	push   -0x10(%ebp)
80105f34:	e8 d8 bc ff ff       	call   80101c11 <iunlockput>
80105f39:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f3c:	e8 61 d6 ff ff       	call   801035a2 <end_op>
    return -1;
80105f41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f46:	eb 33                	jmp    80105f7b <sys_chdir+0xb4>
  }
  iunlock(ip);
80105f48:	83 ec 0c             	sub    $0xc,%esp
80105f4b:	ff 75 f0             	push   -0x10(%ebp)
80105f4e:	e8 a0 bb ff ff       	call   80101af3 <iunlock>
80105f53:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f59:	8b 40 68             	mov    0x68(%eax),%eax
80105f5c:	83 ec 0c             	sub    $0xc,%esp
80105f5f:	50                   	push   %eax
80105f60:	e8 dc bb ff ff       	call   80101b41 <iput>
80105f65:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f68:	e8 35 d6 ff ff       	call   801035a2 <end_op>
  curproc->cwd = ip;
80105f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f73:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105f76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f7b:	c9                   	leave  
80105f7c:	c3                   	ret    

80105f7d <sys_exec>:

int
sys_exec(void)
{
80105f7d:	55                   	push   %ebp
80105f7e:	89 e5                	mov    %esp,%ebp
80105f80:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105f86:	83 ec 08             	sub    $0x8,%esp
80105f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f8c:	50                   	push   %eax
80105f8d:	6a 00                	push   $0x0
80105f8f:	e8 9e f3 ff ff       	call   80105332 <argstr>
80105f94:	83 c4 10             	add    $0x10,%esp
80105f97:	85 c0                	test   %eax,%eax
80105f99:	78 18                	js     80105fb3 <sys_exec+0x36>
80105f9b:	83 ec 08             	sub    $0x8,%esp
80105f9e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105fa4:	50                   	push   %eax
80105fa5:	6a 01                	push   $0x1
80105fa7:	e8 00 f3 ff ff       	call   801052ac <argint>
80105fac:	83 c4 10             	add    $0x10,%esp
80105faf:	85 c0                	test   %eax,%eax
80105fb1:	79 0a                	jns    80105fbd <sys_exec+0x40>
    return -1;
80105fb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb8:	e9 c6 00 00 00       	jmp    80106083 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105fbd:	83 ec 04             	sub    $0x4,%esp
80105fc0:	68 80 00 00 00       	push   $0x80
80105fc5:	6a 00                	push   $0x0
80105fc7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105fcd:	50                   	push   %eax
80105fce:	e8 ca ef ff ff       	call   80104f9d <memset>
80105fd3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105fd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe0:	83 f8 1f             	cmp    $0x1f,%eax
80105fe3:	76 0a                	jbe    80105fef <sys_exec+0x72>
      return -1;
80105fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fea:	e9 94 00 00 00       	jmp    80106083 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff2:	c1 e0 02             	shl    $0x2,%eax
80105ff5:	89 c2                	mov    %eax,%edx
80105ff7:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ffd:	01 c2                	add    %eax,%edx
80105fff:	83 ec 08             	sub    $0x8,%esp
80106002:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106008:	50                   	push   %eax
80106009:	52                   	push   %edx
8010600a:	e8 18 f2 ff ff       	call   80105227 <fetchint>
8010600f:	83 c4 10             	add    $0x10,%esp
80106012:	85 c0                	test   %eax,%eax
80106014:	79 07                	jns    8010601d <sys_exec+0xa0>
      return -1;
80106016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601b:	eb 66                	jmp    80106083 <sys_exec+0x106>
    if(uarg == 0){
8010601d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106023:	85 c0                	test   %eax,%eax
80106025:	75 27                	jne    8010604e <sys_exec+0xd1>
      argv[i] = 0;
80106027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106031:	00 00 00 00 
      break;
80106035:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106039:	83 ec 08             	sub    $0x8,%esp
8010603c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106042:	52                   	push   %edx
80106043:	50                   	push   %eax
80106044:	e8 37 ab ff ff       	call   80100b80 <exec>
80106049:	83 c4 10             	add    $0x10,%esp
8010604c:	eb 35                	jmp    80106083 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010604e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106057:	c1 e0 02             	shl    $0x2,%eax
8010605a:	01 c2                	add    %eax,%edx
8010605c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106062:	83 ec 08             	sub    $0x8,%esp
80106065:	52                   	push   %edx
80106066:	50                   	push   %eax
80106067:	e8 ea f1 ff ff       	call   80105256 <fetchstr>
8010606c:	83 c4 10             	add    $0x10,%esp
8010606f:	85 c0                	test   %eax,%eax
80106071:	79 07                	jns    8010607a <sys_exec+0xfd>
      return -1;
80106073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106078:	eb 09                	jmp    80106083 <sys_exec+0x106>
  for(i=0;; i++){
8010607a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010607e:	e9 5a ff ff ff       	jmp    80105fdd <sys_exec+0x60>
}
80106083:	c9                   	leave  
80106084:	c3                   	ret    

80106085 <sys_pipe>:

int
sys_pipe(void)
{
80106085:	55                   	push   %ebp
80106086:	89 e5                	mov    %esp,%ebp
80106088:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010608b:	83 ec 04             	sub    $0x4,%esp
8010608e:	6a 08                	push   $0x8
80106090:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106093:	50                   	push   %eax
80106094:	6a 00                	push   $0x0
80106096:	e8 3e f2 ff ff       	call   801052d9 <argptr>
8010609b:	83 c4 10             	add    $0x10,%esp
8010609e:	85 c0                	test   %eax,%eax
801060a0:	79 0a                	jns    801060ac <sys_pipe+0x27>
    return -1;
801060a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a7:	e9 ae 00 00 00       	jmp    8010615a <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801060ac:	83 ec 08             	sub    $0x8,%esp
801060af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060b2:	50                   	push   %eax
801060b3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060b6:	50                   	push   %eax
801060b7:	e8 8b d9 ff ff       	call   80103a47 <pipealloc>
801060bc:	83 c4 10             	add    $0x10,%esp
801060bf:	85 c0                	test   %eax,%eax
801060c1:	79 0a                	jns    801060cd <sys_pipe+0x48>
    return -1;
801060c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c8:	e9 8d 00 00 00       	jmp    8010615a <sys_pipe+0xd5>
  fd0 = -1;
801060cd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801060d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060d7:	83 ec 0c             	sub    $0xc,%esp
801060da:	50                   	push   %eax
801060db:	e8 7b f3 ff ff       	call   8010545b <fdalloc>
801060e0:	83 c4 10             	add    $0x10,%esp
801060e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ea:	78 18                	js     80106104 <sys_pipe+0x7f>
801060ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ef:	83 ec 0c             	sub    $0xc,%esp
801060f2:	50                   	push   %eax
801060f3:	e8 63 f3 ff ff       	call   8010545b <fdalloc>
801060f8:	83 c4 10             	add    $0x10,%esp
801060fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106102:	79 3e                	jns    80106142 <sys_pipe+0xbd>
    if(fd0 >= 0)
80106104:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106108:	78 13                	js     8010611d <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
8010610a:	e8 fb dd ff ff       	call   80103f0a <myproc>
8010610f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106112:	83 c2 08             	add    $0x8,%edx
80106115:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010611c:	00 
    fileclose(rf);
8010611d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106120:	83 ec 0c             	sub    $0xc,%esp
80106123:	50                   	push   %eax
80106124:	e8 68 af ff ff       	call   80101091 <fileclose>
80106129:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010612c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010612f:	83 ec 0c             	sub    $0xc,%esp
80106132:	50                   	push   %eax
80106133:	e8 59 af ff ff       	call   80101091 <fileclose>
80106138:	83 c4 10             	add    $0x10,%esp
    return -1;
8010613b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106140:	eb 18                	jmp    8010615a <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106142:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106148:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010614a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010614d:	8d 50 04             	lea    0x4(%eax),%edx
80106150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106153:	89 02                	mov    %eax,(%edx)
  return 0;
80106155:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010615a:	c9                   	leave  
8010615b:	c3                   	ret    

8010615c <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
8010615c:	55                   	push   %ebp
8010615d:	89 e5                	mov    %esp,%ebp
8010615f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106162:	e8 a2 e0 ff ff       	call   80104209 <fork>
}
80106167:	c9                   	leave  
80106168:	c3                   	ret    

80106169 <sys_exit>:

int
sys_exit(void)
{
80106169:	55                   	push   %ebp
8010616a:	89 e5                	mov    %esp,%ebp
8010616c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010616f:	e8 0e e2 ff ff       	call   80104382 <exit>
  return 0;  // not reached
80106174:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106179:	c9                   	leave  
8010617a:	c3                   	ret    

8010617b <sys_wait>:

int
sys_wait(void)
{
8010617b:	55                   	push   %ebp
8010617c:	89 e5                	mov    %esp,%ebp
8010617e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106181:	e8 1c e3 ff ff       	call   801044a2 <wait>
}
80106186:	c9                   	leave  
80106187:	c3                   	ret    

80106188 <sys_kill>:

int
sys_kill(void)
{
80106188:	55                   	push   %ebp
80106189:	89 e5                	mov    %esp,%ebp
8010618b:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010618e:	83 ec 08             	sub    $0x8,%esp
80106191:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106194:	50                   	push   %eax
80106195:	6a 00                	push   $0x0
80106197:	e8 10 f1 ff ff       	call   801052ac <argint>
8010619c:	83 c4 10             	add    $0x10,%esp
8010619f:	85 c0                	test   %eax,%eax
801061a1:	79 07                	jns    801061aa <sys_kill+0x22>
    return -1;
801061a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a8:	eb 0f                	jmp    801061b9 <sys_kill+0x31>
  return kill(pid);
801061aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	50                   	push   %eax
801061b1:	e8 1b e7 ff ff       	call   801048d1 <kill>
801061b6:	83 c4 10             	add    $0x10,%esp
}
801061b9:	c9                   	leave  
801061ba:	c3                   	ret    

801061bb <sys_getpid>:

int
sys_getpid(void)
{
801061bb:	55                   	push   %ebp
801061bc:	89 e5                	mov    %esp,%ebp
801061be:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801061c1:	e8 44 dd ff ff       	call   80103f0a <myproc>
801061c6:	8b 40 10             	mov    0x10(%eax),%eax
}
801061c9:	c9                   	leave  
801061ca:	c3                   	ret    

801061cb <sys_printpt>:
 //추가
int
sys_printpt(void)
{
801061cb:	55                   	push   %ebp
801061cc:	89 e5                	mov    %esp,%ebp
801061ce:	83 ec 18             	sub    $0x18,%esp
  int pid =0;
801061d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (argint(0, &pid) < 0) //사용자에게 pid 넘겨받지 못하면 실패
801061d8:	83 ec 08             	sub    $0x8,%esp
801061db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061de:	50                   	push   %eax
801061df:	6a 00                	push   $0x0
801061e1:	e8 c6 f0 ff ff       	call   801052ac <argint>
801061e6:	83 c4 10             	add    $0x10,%esp
801061e9:	85 c0                	test   %eax,%eax
801061eb:	79 07                	jns    801061f4 <sys_printpt+0x29>
    return -1;
801061ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f2:	eb 0f                	jmp    80106203 <sys_printpt+0x38>
  
  return printpt(pid);
801061f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f7:	83 ec 0c             	sub    $0xc,%esp
801061fa:	50                   	push   %eax
801061fb:	e8 4f e8 ff ff       	call   80104a4f <printpt>
80106200:	83 c4 10             	add    $0x10,%esp
}
80106203:	c9                   	leave  
80106204:	c3                   	ret    

80106205 <sys_sbrk>:

//lazy allocation 수정
int
sys_sbrk(void)
{
80106205:	55                   	push   %ebp
80106206:	89 e5                	mov    %esp,%ebp
80106208:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc *curproc = myproc ();
8010620b:	e8 fa dc ff ff       	call   80103f0a <myproc>
80106210:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(argint(0, &n) < 0)
80106213:	83 ec 08             	sub    $0x8,%esp
80106216:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106219:	50                   	push   %eax
8010621a:	6a 00                	push   $0x0
8010621c:	e8 8b f0 ff ff       	call   801052ac <argint>
80106221:	83 c4 10             	add    $0x10,%esp
80106224:	85 c0                	test   %eax,%eax
80106226:	79 0a                	jns    80106232 <sys_sbrk+0x2d>
    return -1;
80106228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622d:	e9 ab 00 00 00       	jmp    801062dd <sys_sbrk+0xd8>

  addr = curproc->sz;
80106232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106235:	8b 00                	mov    (%eax),%eax
80106237:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(n < 0) {
8010623a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010623d:	85 c0                	test   %eax,%eax
8010623f:	79 6e                	jns    801062af <sys_sbrk+0xaa>

    uint oldsz = curproc->sz;
80106241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106244:	8b 00                	mov    (%eax),%eax
80106246:	89 45 ec             	mov    %eax,-0x14(%ebp)
    uint newsz = oldsz + n;
80106249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010624c:	89 c2                	mov    %eax,%edx
8010624e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106251:	01 d0                	add    %edx,%eax
80106253:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if (newsz > oldsz) //오버플로우 방지
80106256:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106259:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010625c:	76 07                	jbe    80106265 <sys_sbrk+0x60>
    return -1;
8010625e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106263:	eb 78                	jmp    801062dd <sys_sbrk+0xd8>

    //PGROUNDUP된 boundary 범위만 unmap
    if(deallocuvm(curproc->pgdir, PGROUNDUP(oldsz), PGROUNDUP(newsz)) == 0)
80106265:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106268:	05 ff 0f 00 00       	add    $0xfff,%eax
8010626d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106272:	89 c1                	mov    %eax,%ecx
80106274:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106277:	05 ff 0f 00 00       	add    $0xfff,%eax
8010627c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106281:	89 c2                	mov    %eax,%edx
80106283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106286:	8b 40 04             	mov    0x4(%eax),%eax
80106289:	83 ec 04             	sub    $0x4,%esp
8010628c:	51                   	push   %ecx
8010628d:	52                   	push   %edx
8010628e:	50                   	push   %eax
8010628f:	e8 9a 1c 00 00       	call   80107f2e <deallocuvm>
80106294:	83 c4 10             	add    $0x10,%esp
80106297:	85 c0                	test   %eax,%eax
80106299:	75 07                	jne    801062a2 <sys_sbrk+0x9d>
      return -1;
8010629b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a0:	eb 3b                	jmp    801062dd <sys_sbrk+0xd8>
    curproc -> sz = newsz;
801062a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801062a8:	89 10                	mov    %edx,(%eax)
    return addr;
801062aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ad:	eb 2e                	jmp    801062dd <sys_sbrk+0xd8>
  }
  
  if (n > 0){ // sz+n이 커널 영역 넘어가면 안됨
801062af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b2:	85 c0                	test   %eax,%eax
801062b4:	7e 15                	jle    801062cb <sys_sbrk+0xc6>
    if (curproc ->sz + n >= KERNBASE) //lazy allocation -> 물리메모리 할당 안함함
801062b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b9:	8b 10                	mov    (%eax),%edx
801062bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062be:	01 d0                	add    %edx,%eax
801062c0:	85 c0                	test   %eax,%eax
801062c2:	79 07                	jns    801062cb <sys_sbrk+0xc6>
      return -1;
801062c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c9:	eb 12                	jmp    801062dd <sys_sbrk+0xd8>
  }
  curproc ->sz +=n;
801062cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ce:	8b 10                	mov    (%eax),%edx
801062d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d3:	01 c2                	add    %eax,%edx
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	89 10                	mov    %edx,(%eax)
  return addr;
801062da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062dd:	c9                   	leave  
801062de:	c3                   	ret    

801062df <sys_sleep>:

int
sys_sleep(void)
{
801062df:	55                   	push   %ebp
801062e0:	89 e5                	mov    %esp,%ebp
801062e2:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062eb:	50                   	push   %eax
801062ec:	6a 00                	push   $0x0
801062ee:	e8 b9 ef ff ff       	call   801052ac <argint>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	85 c0                	test   %eax,%eax
801062f8:	79 07                	jns    80106301 <sys_sleep+0x22>
    return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	eb 76                	jmp    80106377 <sys_sleep+0x98>
  acquire(&tickslock);
80106301:	83 ec 0c             	sub    $0xc,%esp
80106304:	68 80 99 11 80       	push   $0x80119980
80106309:	e8 19 ea ff ff       	call   80104d27 <acquire>
8010630e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106311:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106316:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106319:	eb 38                	jmp    80106353 <sys_sleep+0x74>
    if(myproc()->killed){
8010631b:	e8 ea db ff ff       	call   80103f0a <myproc>
80106320:	8b 40 24             	mov    0x24(%eax),%eax
80106323:	85 c0                	test   %eax,%eax
80106325:	74 17                	je     8010633e <sys_sleep+0x5f>
      release(&tickslock);
80106327:	83 ec 0c             	sub    $0xc,%esp
8010632a:	68 80 99 11 80       	push   $0x80119980
8010632f:	e8 61 ea ff ff       	call   80104d95 <release>
80106334:	83 c4 10             	add    $0x10,%esp
      return -1;
80106337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633c:	eb 39                	jmp    80106377 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010633e:	83 ec 08             	sub    $0x8,%esp
80106341:	68 80 99 11 80       	push   $0x80119980
80106346:	68 b4 99 11 80       	push   $0x801199b4
8010634b:	e8 63 e4 ff ff       	call   801047b3 <sleep>
80106350:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106353:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106358:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010635b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010635e:	39 d0                	cmp    %edx,%eax
80106360:	72 b9                	jb     8010631b <sys_sleep+0x3c>
  }
  release(&tickslock);
80106362:	83 ec 0c             	sub    $0xc,%esp
80106365:	68 80 99 11 80       	push   $0x80119980
8010636a:	e8 26 ea ff ff       	call   80104d95 <release>
8010636f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106372:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106379:	55                   	push   %ebp
8010637a:	89 e5                	mov    %esp,%ebp
8010637c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010637f:	83 ec 0c             	sub    $0xc,%esp
80106382:	68 80 99 11 80       	push   $0x80119980
80106387:	e8 9b e9 ff ff       	call   80104d27 <acquire>
8010638c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010638f:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106394:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106397:	83 ec 0c             	sub    $0xc,%esp
8010639a:	68 80 99 11 80       	push   $0x80119980
8010639f:	e8 f1 e9 ff ff       	call   80104d95 <release>
801063a4:	83 c4 10             	add    $0x10,%esp
  return xticks;
801063a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063aa:	c9                   	leave  
801063ab:	c3                   	ret    

801063ac <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801063ac:	1e                   	push   %ds
  pushl %es
801063ad:	06                   	push   %es
  pushl %fs
801063ae:	0f a0                	push   %fs
  pushl %gs
801063b0:	0f a8                	push   %gs
  pushal
801063b2:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801063b3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801063b7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801063b9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801063bb:	54                   	push   %esp
  call trap
801063bc:	e8 e3 01 00 00       	call   801065a4 <trap>
  addl $4, %esp
801063c1:	83 c4 04             	add    $0x4,%esp

801063c4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801063c4:	61                   	popa   
  popl %gs
801063c5:	0f a9                	pop    %gs
  popl %fs
801063c7:	0f a1                	pop    %fs
  popl %es
801063c9:	07                   	pop    %es
  popl %ds
801063ca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801063cb:	83 c4 08             	add    $0x8,%esp
  iret
801063ce:	cf                   	iret   

801063cf <lidt>:
{
801063cf:	55                   	push   %ebp
801063d0:	89 e5                	mov    %esp,%ebp
801063d2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801063d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d8:	83 e8 01             	sub    $0x1,%eax
801063db:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801063df:	8b 45 08             	mov    0x8(%ebp),%eax
801063e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801063e6:	8b 45 08             	mov    0x8(%ebp),%eax
801063e9:	c1 e8 10             	shr    $0x10,%eax
801063ec:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801063f0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801063f3:	0f 01 18             	lidtl  (%eax)
}
801063f6:	90                   	nop
801063f7:	c9                   	leave  
801063f8:	c3                   	ret    

801063f9 <rcr2>:

static inline uint
rcr2(void)
{
801063f9:	55                   	push   %ebp
801063fa:	89 e5                	mov    %esp,%ebp
801063fc:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801063ff:	0f 20 d0             	mov    %cr2,%eax
80106402:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106405:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106408:	c9                   	leave  
80106409:	c3                   	ret    

8010640a <lcr3>:

static inline void
lcr3(uint val)
{
8010640a:	55                   	push   %ebp
8010640b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010640d:	8b 45 08             	mov    0x8(%ebp),%eax
80106410:	0f 22 d8             	mov    %eax,%cr3
}
80106413:	90                   	nop
80106414:	5d                   	pop    %ebp
80106415:	c3                   	ret    

80106416 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106416:	55                   	push   %ebp
80106417:	89 e5                	mov    %esp,%ebp
80106419:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010641c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106423:	e9 c3 00 00 00       	jmp    801064eb <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642b:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106432:	89 c2                	mov    %eax,%edx
80106434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106437:	66 89 14 c5 80 91 11 	mov    %dx,-0x7fee6e80(,%eax,8)
8010643e:	80 
8010643f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106442:	66 c7 04 c5 82 91 11 	movw   $0x8,-0x7fee6e7e(,%eax,8)
80106449:	80 08 00 
8010644c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644f:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
80106456:	80 
80106457:	83 e2 e0             	and    $0xffffffe0,%edx
8010645a:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
80106461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106464:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
8010646b:	80 
8010646c:	83 e2 1f             	and    $0x1f,%edx
8010646f:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
80106476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106479:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
80106480:	80 
80106481:	83 e2 f0             	and    $0xfffffff0,%edx
80106484:	83 ca 0e             	or     $0xe,%edx
80106487:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
8010648e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106491:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
80106498:	80 
80106499:	83 e2 ef             	and    $0xffffffef,%edx
8010649c:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801064a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a6:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801064ad:	80 
801064ae:	83 e2 9f             	and    $0xffffff9f,%edx
801064b1:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801064b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bb:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801064c2:	80 
801064c3:	83 ca 80             	or     $0xffffff80,%edx
801064c6:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
801064cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d0:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
801064d7:	c1 e8 10             	shr    $0x10,%eax
801064da:	89 c2                	mov    %eax,%edx
801064dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064df:	66 89 14 c5 86 91 11 	mov    %dx,-0x7fee6e7a(,%eax,8)
801064e6:	80 
  for(i = 0; i < 256; i++)
801064e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064eb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801064f2:	0f 8e 30 ff ff ff    	jle    80106428 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801064f8:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801064fd:	66 a3 80 93 11 80    	mov    %ax,0x80119380
80106503:	66 c7 05 82 93 11 80 	movw   $0x8,0x80119382
8010650a:	08 00 
8010650c:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
80106513:	83 e0 e0             	and    $0xffffffe0,%eax
80106516:	a2 84 93 11 80       	mov    %al,0x80119384
8010651b:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
80106522:	83 e0 1f             	and    $0x1f,%eax
80106525:	a2 84 93 11 80       	mov    %al,0x80119384
8010652a:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
80106531:	83 c8 0f             	or     $0xf,%eax
80106534:	a2 85 93 11 80       	mov    %al,0x80119385
80106539:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
80106540:	83 e0 ef             	and    $0xffffffef,%eax
80106543:	a2 85 93 11 80       	mov    %al,0x80119385
80106548:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
8010654f:	83 c8 60             	or     $0x60,%eax
80106552:	a2 85 93 11 80       	mov    %al,0x80119385
80106557:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
8010655e:	83 c8 80             	or     $0xffffff80,%eax
80106561:	a2 85 93 11 80       	mov    %al,0x80119385
80106566:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
8010656b:	c1 e8 10             	shr    $0x10,%eax
8010656e:	66 a3 86 93 11 80    	mov    %ax,0x80119386

  initlock(&tickslock, "time");
80106574:	83 ec 08             	sub    $0x8,%esp
80106577:	68 84 ab 10 80       	push   $0x8010ab84
8010657c:	68 80 99 11 80       	push   $0x80119980
80106581:	e8 7f e7 ff ff       	call   80104d05 <initlock>
80106586:	83 c4 10             	add    $0x10,%esp
}
80106589:	90                   	nop
8010658a:	c9                   	leave  
8010658b:	c3                   	ret    

8010658c <idtinit>:

void
idtinit(void)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010658f:	68 00 08 00 00       	push   $0x800
80106594:	68 80 91 11 80       	push   $0x80119180
80106599:	e8 31 fe ff ff       	call   801063cf <lidt>
8010659e:	83 c4 08             	add    $0x8,%esp
}
801065a1:	90                   	nop
801065a2:	c9                   	leave  
801065a3:	c3                   	ret    

801065a4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065a4:	55                   	push   %ebp
801065a5:	89 e5                	mov    %esp,%ebp
801065a7:	57                   	push   %edi
801065a8:	56                   	push   %esi
801065a9:	53                   	push   %ebx
801065aa:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801065ad:	8b 45 08             	mov    0x8(%ebp),%eax
801065b0:	8b 40 30             	mov    0x30(%eax),%eax
801065b3:	83 f8 40             	cmp    $0x40,%eax
801065b6:	75 3b                	jne    801065f3 <trap+0x4f>
    if(myproc()->killed)
801065b8:	e8 4d d9 ff ff       	call   80103f0a <myproc>
801065bd:	8b 40 24             	mov    0x24(%eax),%eax
801065c0:	85 c0                	test   %eax,%eax
801065c2:	74 05                	je     801065c9 <trap+0x25>
      exit();
801065c4:	e8 b9 dd ff ff       	call   80104382 <exit>
    myproc()->tf = tf;
801065c9:	e8 3c d9 ff ff       	call   80103f0a <myproc>
801065ce:	8b 55 08             	mov    0x8(%ebp),%edx
801065d1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801065d4:	e8 90 ed ff ff       	call   80105369 <syscall>
    if(myproc()->killed)
801065d9:	e8 2c d9 ff ff       	call   80103f0a <myproc>
801065de:	8b 40 24             	mov    0x24(%eax),%eax
801065e1:	85 c0                	test   %eax,%eax
801065e3:	0f 84 1d 03 00 00    	je     80106906 <trap+0x362>
      exit();
801065e9:	e8 94 dd ff ff       	call   80104382 <exit>
    return;
801065ee:	e9 13 03 00 00       	jmp    80106906 <trap+0x362>
  }

  switch(tf->trapno){
801065f3:	8b 45 08             	mov    0x8(%ebp),%eax
801065f6:	8b 40 30             	mov    0x30(%eax),%eax
801065f9:	83 e8 0e             	sub    $0xe,%eax
801065fc:	83 f8 31             	cmp    $0x31,%eax
801065ff:	0f 87 c9 01 00 00    	ja     801067ce <trap+0x22a>
80106605:	8b 04 85 44 ac 10 80 	mov    -0x7fef53bc(,%eax,4),%eax
8010660c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010660e:	e8 64 d8 ff ff       	call   80103e77 <cpuid>
80106613:	85 c0                	test   %eax,%eax
80106615:	75 3d                	jne    80106654 <trap+0xb0>
      acquire(&tickslock);
80106617:	83 ec 0c             	sub    $0xc,%esp
8010661a:	68 80 99 11 80       	push   $0x80119980
8010661f:	e8 03 e7 ff ff       	call   80104d27 <acquire>
80106624:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106627:	a1 b4 99 11 80       	mov    0x801199b4,%eax
8010662c:	83 c0 01             	add    $0x1,%eax
8010662f:	a3 b4 99 11 80       	mov    %eax,0x801199b4
      wakeup(&ticks);
80106634:	83 ec 0c             	sub    $0xc,%esp
80106637:	68 b4 99 11 80       	push   $0x801199b4
8010663c:	e8 59 e2 ff ff       	call   8010489a <wakeup>
80106641:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106644:	83 ec 0c             	sub    $0xc,%esp
80106647:	68 80 99 11 80       	push   $0x80119980
8010664c:	e8 44 e7 ff ff       	call   80104d95 <release>
80106651:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106654:	e8 9d c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
80106659:	e9 28 02 00 00       	jmp    80106886 <trap+0x2e2>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010665e:	e8 e9 c1 ff ff       	call   8010284c <ideintr>
    lapiceoi();
80106663:	e8 8e c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
80106668:	e9 19 02 00 00       	jmp    80106886 <trap+0x2e2>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010666d:	e8 c9 c7 ff ff       	call   80102e3b <kbdintr>
    lapiceoi();
80106672:	e8 7f c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
80106677:	e9 0a 02 00 00       	jmp    80106886 <trap+0x2e2>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010667c:	e8 5b 04 00 00       	call   80106adc <uartintr>
    lapiceoi();
80106681:	e8 70 c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
80106686:	e9 fb 01 00 00       	jmp    80106886 <trap+0x2e2>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010668b:	e8 9e 2c 00 00       	call   8010932e <i8254_intr>
    lapiceoi();
80106690:	e8 61 c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
80106695:	e9 ec 01 00 00       	jmp    80106886 <trap+0x2e2>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010669a:	8b 45 08             	mov    0x8(%ebp),%eax
8010669d:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801066a0:	8b 45 08             	mov    0x8(%ebp),%eax
801066a3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066a7:	0f b7 d8             	movzwl %ax,%ebx
801066aa:	e8 c8 d7 ff ff       	call   80103e77 <cpuid>
801066af:	56                   	push   %esi
801066b0:	53                   	push   %ebx
801066b1:	50                   	push   %eax
801066b2:	68 8c ab 10 80       	push   $0x8010ab8c
801066b7:	e8 38 9d ff ff       	call   801003f4 <cprintf>
801066bc:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801066bf:	e8 32 c9 ff ff       	call   80102ff6 <lapiceoi>
    break;
801066c4:	e9 bd 01 00 00       	jmp    80106886 <trap+0x2e2>
  
  case T_PGFLT: {
    uint fault_addr = PGROUNDDOWN(rcr2());
801066c9:	e8 2b fd ff ff       	call   801063f9 <rcr2>
801066ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *p = myproc();
801066d6:	e8 2f d8 ff ff       	call   80103f0a <myproc>
801066db:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // 커널 영역 접근 시 kill
    if ( fault_addr >= KERNBASE) {
801066de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066e1:	85 c0                	test   %eax,%eax
801066e3:	79 22                	jns    80106707 <trap+0x163>
      cprintf("Invalid access at %x\n", fault_addr);
801066e5:	83 ec 08             	sub    $0x8,%esp
801066e8:	ff 75 e4             	push   -0x1c(%ebp)
801066eb:	68 b0 ab 10 80       	push   $0x8010abb0
801066f0:	e8 ff 9c ff ff       	call   801003f4 <cprintf>
801066f5:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
801066f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066fb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106702:	e9 7f 01 00 00       	jmp    80106886 <trap+0x2e2>
    }
    // 페이지가 이미 매핑되어 있으면 무시
    pte_t *pte = walkpgdir(p->pgdir, (void *)fault_addr, 0);
80106707:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010670a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010670d:	8b 40 04             	mov    0x4(%eax),%eax
80106710:	83 ec 04             	sub    $0x4,%esp
80106713:	6a 00                	push   $0x0
80106715:	52                   	push   %edx
80106716:	50                   	push   %eax
80106717:	e8 ee 11 00 00       	call   8010790a <walkpgdir>
8010671c:	83 c4 10             	add    $0x10,%esp
8010671f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pte && (*pte & PTE_P))
80106722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106726:	74 10                	je     80106738 <trap+0x194>
80106728:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010672b:	8b 00                	mov    (%eax),%eax
8010672d:	83 e0 01             	and    $0x1,%eax
80106730:	85 c0                	test   %eax,%eax
80106732:	0f 85 4d 01 00 00    	jne    80106885 <trap+0x2e1>
      break;

    // 새 물리 메모리 할당
    char *mem = kalloc();
80106738:	e8 3d c5 ff ff       	call   80102c7a <kalloc>
8010673d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!mem) {
80106740:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80106744:	75 0f                	jne    80106755 <trap+0x1b1>
      p->killed = 1;
80106746:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106749:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
80106750:	e9 31 01 00 00       	jmp    80106886 <trap+0x2e2>
    }

    memset(mem, 0, PGSIZE);
80106755:	83 ec 04             	sub    $0x4,%esp
80106758:	68 00 10 00 00       	push   $0x1000
8010675d:	6a 00                	push   $0x0
8010675f:	ff 75 d8             	push   -0x28(%ebp)
80106762:	e8 36 e8 ff ff       	call   80104f9d <memset>
80106767:	83 c4 10             	add    $0x10,%esp

    // 페이지 매핑
    if (mappages(p->pgdir, (void *)fault_addr, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
8010676a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010676d:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80106773:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106776:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106779:	8b 40 04             	mov    0x4(%eax),%eax
8010677c:	83 ec 0c             	sub    $0xc,%esp
8010677f:	6a 06                	push   $0x6
80106781:	51                   	push   %ecx
80106782:	68 00 10 00 00       	push   $0x1000
80106787:	52                   	push   %edx
80106788:	50                   	push   %eax
80106789:	e8 12 12 00 00       	call   801079a0 <mappages>
8010678e:	83 c4 20             	add    $0x20,%esp
80106791:	85 c0                	test   %eax,%eax
80106793:	79 1d                	jns    801067b2 <trap+0x20e>
      kfree(mem);  // 실패했으면 할당 회수
80106795:	83 ec 0c             	sub    $0xc,%esp
80106798:	ff 75 d8             	push   -0x28(%ebp)
8010679b:	e8 40 c4 ff ff       	call   80102be0 <kfree>
801067a0:	83 c4 10             	add    $0x10,%esp
      p->killed = 1;
801067a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801067a6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      break;
801067ad:	e9 d4 00 00 00       	jmp    80106886 <trap+0x2e2>
    }

    // TLB 플러싱
    lcr3(V2P(p->pgdir));
801067b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801067b5:	8b 40 04             	mov    0x4(%eax),%eax
801067b8:	05 00 00 00 80       	add    $0x80000000,%eax
801067bd:	83 ec 0c             	sub    $0xc,%esp
801067c0:	50                   	push   %eax
801067c1:	e8 44 fc ff ff       	call   8010640a <lcr3>
801067c6:	83 c4 10             	add    $0x10,%esp
    break;
801067c9:	e9 b8 00 00 00       	jmp    80106886 <trap+0x2e2>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801067ce:	e8 37 d7 ff ff       	call   80103f0a <myproc>
801067d3:	85 c0                	test   %eax,%eax
801067d5:	74 11                	je     801067e8 <trap+0x244>
801067d7:	8b 45 08             	mov    0x8(%ebp),%eax
801067da:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067de:	0f b7 c0             	movzwl %ax,%eax
801067e1:	83 e0 03             	and    $0x3,%eax
801067e4:	85 c0                	test   %eax,%eax
801067e6:	75 39                	jne    80106821 <trap+0x27d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067e8:	e8 0c fc ff ff       	call   801063f9 <rcr2>
801067ed:	89 c3                	mov    %eax,%ebx
801067ef:	8b 45 08             	mov    0x8(%ebp),%eax
801067f2:	8b 70 38             	mov    0x38(%eax),%esi
801067f5:	e8 7d d6 ff ff       	call   80103e77 <cpuid>
801067fa:	8b 55 08             	mov    0x8(%ebp),%edx
801067fd:	8b 52 30             	mov    0x30(%edx),%edx
80106800:	83 ec 0c             	sub    $0xc,%esp
80106803:	53                   	push   %ebx
80106804:	56                   	push   %esi
80106805:	50                   	push   %eax
80106806:	52                   	push   %edx
80106807:	68 c8 ab 10 80       	push   $0x8010abc8
8010680c:	e8 e3 9b ff ff       	call   801003f4 <cprintf>
80106811:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106814:	83 ec 0c             	sub    $0xc,%esp
80106817:	68 fa ab 10 80       	push   $0x8010abfa
8010681c:	e8 88 9d ff ff       	call   801005a9 <panic>
    }

    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106821:	e8 d3 fb ff ff       	call   801063f9 <rcr2>
80106826:	89 c6                	mov    %eax,%esi
80106828:	8b 45 08             	mov    0x8(%ebp),%eax
8010682b:	8b 40 38             	mov    0x38(%eax),%eax
8010682e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106831:	e8 41 d6 ff ff       	call   80103e77 <cpuid>
80106836:	89 c3                	mov    %eax,%ebx
80106838:	8b 45 08             	mov    0x8(%ebp),%eax
8010683b:	8b 48 34             	mov    0x34(%eax),%ecx
8010683e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106841:	8b 45 08             	mov    0x8(%ebp),%eax
80106844:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106847:	e8 be d6 ff ff       	call   80103f0a <myproc>
8010684c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010684f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106852:	e8 b3 d6 ff ff       	call   80103f0a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106857:	8b 40 10             	mov    0x10(%eax),%eax
8010685a:	56                   	push   %esi
8010685b:	ff 75 d4             	push   -0x2c(%ebp)
8010685e:	53                   	push   %ebx
8010685f:	ff 75 d0             	push   -0x30(%ebp)
80106862:	57                   	push   %edi
80106863:	ff 75 cc             	push   -0x34(%ebp)
80106866:	50                   	push   %eax
80106867:	68 00 ac 10 80       	push   $0x8010ac00
8010686c:	e8 83 9b ff ff       	call   801003f4 <cprintf>
80106871:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106874:	e8 91 d6 ff ff       	call   80103f0a <myproc>
80106879:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106880:	eb 04                	jmp    80106886 <trap+0x2e2>
    break;
80106882:	90                   	nop
80106883:	eb 01                	jmp    80106886 <trap+0x2e2>
      break;
80106885:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106886:	e8 7f d6 ff ff       	call   80103f0a <myproc>
8010688b:	85 c0                	test   %eax,%eax
8010688d:	74 23                	je     801068b2 <trap+0x30e>
8010688f:	e8 76 d6 ff ff       	call   80103f0a <myproc>
80106894:	8b 40 24             	mov    0x24(%eax),%eax
80106897:	85 c0                	test   %eax,%eax
80106899:	74 17                	je     801068b2 <trap+0x30e>
8010689b:	8b 45 08             	mov    0x8(%ebp),%eax
8010689e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068a2:	0f b7 c0             	movzwl %ax,%eax
801068a5:	83 e0 03             	and    $0x3,%eax
801068a8:	83 f8 03             	cmp    $0x3,%eax
801068ab:	75 05                	jne    801068b2 <trap+0x30e>
    exit();
801068ad:	e8 d0 da ff ff       	call   80104382 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801068b2:	e8 53 d6 ff ff       	call   80103f0a <myproc>
801068b7:	85 c0                	test   %eax,%eax
801068b9:	74 1d                	je     801068d8 <trap+0x334>
801068bb:	e8 4a d6 ff ff       	call   80103f0a <myproc>
801068c0:	8b 40 0c             	mov    0xc(%eax),%eax
801068c3:	83 f8 04             	cmp    $0x4,%eax
801068c6:	75 10                	jne    801068d8 <trap+0x334>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801068c8:	8b 45 08             	mov    0x8(%ebp),%eax
801068cb:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801068ce:	83 f8 20             	cmp    $0x20,%eax
801068d1:	75 05                	jne    801068d8 <trap+0x334>
    yield();
801068d3:	e8 5b de ff ff       	call   80104733 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068d8:	e8 2d d6 ff ff       	call   80103f0a <myproc>
801068dd:	85 c0                	test   %eax,%eax
801068df:	74 26                	je     80106907 <trap+0x363>
801068e1:	e8 24 d6 ff ff       	call   80103f0a <myproc>
801068e6:	8b 40 24             	mov    0x24(%eax),%eax
801068e9:	85 c0                	test   %eax,%eax
801068eb:	74 1a                	je     80106907 <trap+0x363>
801068ed:	8b 45 08             	mov    0x8(%ebp),%eax
801068f0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068f4:	0f b7 c0             	movzwl %ax,%eax
801068f7:	83 e0 03             	and    $0x3,%eax
801068fa:	83 f8 03             	cmp    $0x3,%eax
801068fd:	75 08                	jne    80106907 <trap+0x363>
    exit();
801068ff:	e8 7e da ff ff       	call   80104382 <exit>
80106904:	eb 01                	jmp    80106907 <trap+0x363>
    return;
80106906:	90                   	nop
}
80106907:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010690a:	5b                   	pop    %ebx
8010690b:	5e                   	pop    %esi
8010690c:	5f                   	pop    %edi
8010690d:	5d                   	pop    %ebp
8010690e:	c3                   	ret    

8010690f <inb>:
{
8010690f:	55                   	push   %ebp
80106910:	89 e5                	mov    %esp,%ebp
80106912:	83 ec 14             	sub    $0x14,%esp
80106915:	8b 45 08             	mov    0x8(%ebp),%eax
80106918:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010691c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106920:	89 c2                	mov    %eax,%edx
80106922:	ec                   	in     (%dx),%al
80106923:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106926:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010692a:	c9                   	leave  
8010692b:	c3                   	ret    

8010692c <outb>:
{
8010692c:	55                   	push   %ebp
8010692d:	89 e5                	mov    %esp,%ebp
8010692f:	83 ec 08             	sub    $0x8,%esp
80106932:	8b 45 08             	mov    0x8(%ebp),%eax
80106935:	8b 55 0c             	mov    0xc(%ebp),%edx
80106938:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010693c:	89 d0                	mov    %edx,%eax
8010693e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106941:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106945:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106949:	ee                   	out    %al,(%dx)
}
8010694a:	90                   	nop
8010694b:	c9                   	leave  
8010694c:	c3                   	ret    

8010694d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010694d:	55                   	push   %ebp
8010694e:	89 e5                	mov    %esp,%ebp
80106950:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106953:	6a 00                	push   $0x0
80106955:	68 fa 03 00 00       	push   $0x3fa
8010695a:	e8 cd ff ff ff       	call   8010692c <outb>
8010695f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106962:	68 80 00 00 00       	push   $0x80
80106967:	68 fb 03 00 00       	push   $0x3fb
8010696c:	e8 bb ff ff ff       	call   8010692c <outb>
80106971:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106974:	6a 0c                	push   $0xc
80106976:	68 f8 03 00 00       	push   $0x3f8
8010697b:	e8 ac ff ff ff       	call   8010692c <outb>
80106980:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106983:	6a 00                	push   $0x0
80106985:	68 f9 03 00 00       	push   $0x3f9
8010698a:	e8 9d ff ff ff       	call   8010692c <outb>
8010698f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106992:	6a 03                	push   $0x3
80106994:	68 fb 03 00 00       	push   $0x3fb
80106999:	e8 8e ff ff ff       	call   8010692c <outb>
8010699e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069a1:	6a 00                	push   $0x0
801069a3:	68 fc 03 00 00       	push   $0x3fc
801069a8:	e8 7f ff ff ff       	call   8010692c <outb>
801069ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069b0:	6a 01                	push   $0x1
801069b2:	68 f9 03 00 00       	push   $0x3f9
801069b7:	e8 70 ff ff ff       	call   8010692c <outb>
801069bc:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801069bf:	68 fd 03 00 00       	push   $0x3fd
801069c4:	e8 46 ff ff ff       	call   8010690f <inb>
801069c9:	83 c4 04             	add    $0x4,%esp
801069cc:	3c ff                	cmp    $0xff,%al
801069ce:	74 61                	je     80106a31 <uartinit+0xe4>
    return;
  uart = 1;
801069d0:	c7 05 b8 99 11 80 01 	movl   $0x1,0x801199b8
801069d7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069da:	68 fa 03 00 00       	push   $0x3fa
801069df:	e8 2b ff ff ff       	call   8010690f <inb>
801069e4:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801069e7:	68 f8 03 00 00       	push   $0x3f8
801069ec:	e8 1e ff ff ff       	call   8010690f <inb>
801069f1:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801069f4:	83 ec 08             	sub    $0x8,%esp
801069f7:	6a 00                	push   $0x0
801069f9:	6a 04                	push   $0x4
801069fb:	e8 08 c1 ff ff       	call   80102b08 <ioapicenable>
80106a00:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a03:	c7 45 f4 0c ad 10 80 	movl   $0x8010ad0c,-0xc(%ebp)
80106a0a:	eb 19                	jmp    80106a25 <uartinit+0xd8>
    uartputc(*p);
80106a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0f:	0f b6 00             	movzbl (%eax),%eax
80106a12:	0f be c0             	movsbl %al,%eax
80106a15:	83 ec 0c             	sub    $0xc,%esp
80106a18:	50                   	push   %eax
80106a19:	e8 16 00 00 00       	call   80106a34 <uartputc>
80106a1e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a28:	0f b6 00             	movzbl (%eax),%eax
80106a2b:	84 c0                	test   %al,%al
80106a2d:	75 dd                	jne    80106a0c <uartinit+0xbf>
80106a2f:	eb 01                	jmp    80106a32 <uartinit+0xe5>
    return;
80106a31:	90                   	nop
}
80106a32:	c9                   	leave  
80106a33:	c3                   	ret    

80106a34 <uartputc>:

void
uartputc(int c)
{
80106a34:	55                   	push   %ebp
80106a35:	89 e5                	mov    %esp,%ebp
80106a37:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a3a:	a1 b8 99 11 80       	mov    0x801199b8,%eax
80106a3f:	85 c0                	test   %eax,%eax
80106a41:	74 53                	je     80106a96 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a4a:	eb 11                	jmp    80106a5d <uartputc+0x29>
    microdelay(10);
80106a4c:	83 ec 0c             	sub    $0xc,%esp
80106a4f:	6a 0a                	push   $0xa
80106a51:	e8 bb c5 ff ff       	call   80103011 <microdelay>
80106a56:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a5d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a61:	7f 1a                	jg     80106a7d <uartputc+0x49>
80106a63:	83 ec 0c             	sub    $0xc,%esp
80106a66:	68 fd 03 00 00       	push   $0x3fd
80106a6b:	e8 9f fe ff ff       	call   8010690f <inb>
80106a70:	83 c4 10             	add    $0x10,%esp
80106a73:	0f b6 c0             	movzbl %al,%eax
80106a76:	83 e0 20             	and    $0x20,%eax
80106a79:	85 c0                	test   %eax,%eax
80106a7b:	74 cf                	je     80106a4c <uartputc+0x18>
  outb(COM1+0, c);
80106a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a80:	0f b6 c0             	movzbl %al,%eax
80106a83:	83 ec 08             	sub    $0x8,%esp
80106a86:	50                   	push   %eax
80106a87:	68 f8 03 00 00       	push   $0x3f8
80106a8c:	e8 9b fe ff ff       	call   8010692c <outb>
80106a91:	83 c4 10             	add    $0x10,%esp
80106a94:	eb 01                	jmp    80106a97 <uartputc+0x63>
    return;
80106a96:	90                   	nop
}
80106a97:	c9                   	leave  
80106a98:	c3                   	ret    

80106a99 <uartgetc>:

static int
uartgetc(void)
{
80106a99:	55                   	push   %ebp
80106a9a:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a9c:	a1 b8 99 11 80       	mov    0x801199b8,%eax
80106aa1:	85 c0                	test   %eax,%eax
80106aa3:	75 07                	jne    80106aac <uartgetc+0x13>
    return -1;
80106aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aaa:	eb 2e                	jmp    80106ada <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106aac:	68 fd 03 00 00       	push   $0x3fd
80106ab1:	e8 59 fe ff ff       	call   8010690f <inb>
80106ab6:	83 c4 04             	add    $0x4,%esp
80106ab9:	0f b6 c0             	movzbl %al,%eax
80106abc:	83 e0 01             	and    $0x1,%eax
80106abf:	85 c0                	test   %eax,%eax
80106ac1:	75 07                	jne    80106aca <uartgetc+0x31>
    return -1;
80106ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ac8:	eb 10                	jmp    80106ada <uartgetc+0x41>
  return inb(COM1+0);
80106aca:	68 f8 03 00 00       	push   $0x3f8
80106acf:	e8 3b fe ff ff       	call   8010690f <inb>
80106ad4:	83 c4 04             	add    $0x4,%esp
80106ad7:	0f b6 c0             	movzbl %al,%eax
}
80106ada:	c9                   	leave  
80106adb:	c3                   	ret    

80106adc <uartintr>:

void
uartintr(void)
{
80106adc:	55                   	push   %ebp
80106add:	89 e5                	mov    %esp,%ebp
80106adf:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106ae2:	83 ec 0c             	sub    $0xc,%esp
80106ae5:	68 99 6a 10 80       	push   $0x80106a99
80106aea:	e8 e7 9c ff ff       	call   801007d6 <consoleintr>
80106aef:	83 c4 10             	add    $0x10,%esp
}
80106af2:	90                   	nop
80106af3:	c9                   	leave  
80106af4:	c3                   	ret    

80106af5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $0
80106af7:	6a 00                	push   $0x0
  jmp alltraps
80106af9:	e9 ae f8 ff ff       	jmp    801063ac <alltraps>

80106afe <vector1>:
.globl vector1
vector1:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $1
80106b00:	6a 01                	push   $0x1
  jmp alltraps
80106b02:	e9 a5 f8 ff ff       	jmp    801063ac <alltraps>

80106b07 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $2
80106b09:	6a 02                	push   $0x2
  jmp alltraps
80106b0b:	e9 9c f8 ff ff       	jmp    801063ac <alltraps>

80106b10 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $3
80106b12:	6a 03                	push   $0x3
  jmp alltraps
80106b14:	e9 93 f8 ff ff       	jmp    801063ac <alltraps>

80106b19 <vector4>:
.globl vector4
vector4:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $4
80106b1b:	6a 04                	push   $0x4
  jmp alltraps
80106b1d:	e9 8a f8 ff ff       	jmp    801063ac <alltraps>

80106b22 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $5
80106b24:	6a 05                	push   $0x5
  jmp alltraps
80106b26:	e9 81 f8 ff ff       	jmp    801063ac <alltraps>

80106b2b <vector6>:
.globl vector6
vector6:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $6
80106b2d:	6a 06                	push   $0x6
  jmp alltraps
80106b2f:	e9 78 f8 ff ff       	jmp    801063ac <alltraps>

80106b34 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $7
80106b36:	6a 07                	push   $0x7
  jmp alltraps
80106b38:	e9 6f f8 ff ff       	jmp    801063ac <alltraps>

80106b3d <vector8>:
.globl vector8
vector8:
  pushl $8
80106b3d:	6a 08                	push   $0x8
  jmp alltraps
80106b3f:	e9 68 f8 ff ff       	jmp    801063ac <alltraps>

80106b44 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $9
80106b46:	6a 09                	push   $0x9
  jmp alltraps
80106b48:	e9 5f f8 ff ff       	jmp    801063ac <alltraps>

80106b4d <vector10>:
.globl vector10
vector10:
  pushl $10
80106b4d:	6a 0a                	push   $0xa
  jmp alltraps
80106b4f:	e9 58 f8 ff ff       	jmp    801063ac <alltraps>

80106b54 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b54:	6a 0b                	push   $0xb
  jmp alltraps
80106b56:	e9 51 f8 ff ff       	jmp    801063ac <alltraps>

80106b5b <vector12>:
.globl vector12
vector12:
  pushl $12
80106b5b:	6a 0c                	push   $0xc
  jmp alltraps
80106b5d:	e9 4a f8 ff ff       	jmp    801063ac <alltraps>

80106b62 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b62:	6a 0d                	push   $0xd
  jmp alltraps
80106b64:	e9 43 f8 ff ff       	jmp    801063ac <alltraps>

80106b69 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b69:	6a 0e                	push   $0xe
  jmp alltraps
80106b6b:	e9 3c f8 ff ff       	jmp    801063ac <alltraps>

80106b70 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $15
80106b72:	6a 0f                	push   $0xf
  jmp alltraps
80106b74:	e9 33 f8 ff ff       	jmp    801063ac <alltraps>

80106b79 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $16
80106b7b:	6a 10                	push   $0x10
  jmp alltraps
80106b7d:	e9 2a f8 ff ff       	jmp    801063ac <alltraps>

80106b82 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b82:	6a 11                	push   $0x11
  jmp alltraps
80106b84:	e9 23 f8 ff ff       	jmp    801063ac <alltraps>

80106b89 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $18
80106b8b:	6a 12                	push   $0x12
  jmp alltraps
80106b8d:	e9 1a f8 ff ff       	jmp    801063ac <alltraps>

80106b92 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $19
80106b94:	6a 13                	push   $0x13
  jmp alltraps
80106b96:	e9 11 f8 ff ff       	jmp    801063ac <alltraps>

80106b9b <vector20>:
.globl vector20
vector20:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $20
80106b9d:	6a 14                	push   $0x14
  jmp alltraps
80106b9f:	e9 08 f8 ff ff       	jmp    801063ac <alltraps>

80106ba4 <vector21>:
.globl vector21
vector21:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $21
80106ba6:	6a 15                	push   $0x15
  jmp alltraps
80106ba8:	e9 ff f7 ff ff       	jmp    801063ac <alltraps>

80106bad <vector22>:
.globl vector22
vector22:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $22
80106baf:	6a 16                	push   $0x16
  jmp alltraps
80106bb1:	e9 f6 f7 ff ff       	jmp    801063ac <alltraps>

80106bb6 <vector23>:
.globl vector23
vector23:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $23
80106bb8:	6a 17                	push   $0x17
  jmp alltraps
80106bba:	e9 ed f7 ff ff       	jmp    801063ac <alltraps>

80106bbf <vector24>:
.globl vector24
vector24:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $24
80106bc1:	6a 18                	push   $0x18
  jmp alltraps
80106bc3:	e9 e4 f7 ff ff       	jmp    801063ac <alltraps>

80106bc8 <vector25>:
.globl vector25
vector25:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $25
80106bca:	6a 19                	push   $0x19
  jmp alltraps
80106bcc:	e9 db f7 ff ff       	jmp    801063ac <alltraps>

80106bd1 <vector26>:
.globl vector26
vector26:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $26
80106bd3:	6a 1a                	push   $0x1a
  jmp alltraps
80106bd5:	e9 d2 f7 ff ff       	jmp    801063ac <alltraps>

80106bda <vector27>:
.globl vector27
vector27:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $27
80106bdc:	6a 1b                	push   $0x1b
  jmp alltraps
80106bde:	e9 c9 f7 ff ff       	jmp    801063ac <alltraps>

80106be3 <vector28>:
.globl vector28
vector28:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $28
80106be5:	6a 1c                	push   $0x1c
  jmp alltraps
80106be7:	e9 c0 f7 ff ff       	jmp    801063ac <alltraps>

80106bec <vector29>:
.globl vector29
vector29:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $29
80106bee:	6a 1d                	push   $0x1d
  jmp alltraps
80106bf0:	e9 b7 f7 ff ff       	jmp    801063ac <alltraps>

80106bf5 <vector30>:
.globl vector30
vector30:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $30
80106bf7:	6a 1e                	push   $0x1e
  jmp alltraps
80106bf9:	e9 ae f7 ff ff       	jmp    801063ac <alltraps>

80106bfe <vector31>:
.globl vector31
vector31:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $31
80106c00:	6a 1f                	push   $0x1f
  jmp alltraps
80106c02:	e9 a5 f7 ff ff       	jmp    801063ac <alltraps>

80106c07 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $32
80106c09:	6a 20                	push   $0x20
  jmp alltraps
80106c0b:	e9 9c f7 ff ff       	jmp    801063ac <alltraps>

80106c10 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $33
80106c12:	6a 21                	push   $0x21
  jmp alltraps
80106c14:	e9 93 f7 ff ff       	jmp    801063ac <alltraps>

80106c19 <vector34>:
.globl vector34
vector34:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $34
80106c1b:	6a 22                	push   $0x22
  jmp alltraps
80106c1d:	e9 8a f7 ff ff       	jmp    801063ac <alltraps>

80106c22 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $35
80106c24:	6a 23                	push   $0x23
  jmp alltraps
80106c26:	e9 81 f7 ff ff       	jmp    801063ac <alltraps>

80106c2b <vector36>:
.globl vector36
vector36:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $36
80106c2d:	6a 24                	push   $0x24
  jmp alltraps
80106c2f:	e9 78 f7 ff ff       	jmp    801063ac <alltraps>

80106c34 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $37
80106c36:	6a 25                	push   $0x25
  jmp alltraps
80106c38:	e9 6f f7 ff ff       	jmp    801063ac <alltraps>

80106c3d <vector38>:
.globl vector38
vector38:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $38
80106c3f:	6a 26                	push   $0x26
  jmp alltraps
80106c41:	e9 66 f7 ff ff       	jmp    801063ac <alltraps>

80106c46 <vector39>:
.globl vector39
vector39:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $39
80106c48:	6a 27                	push   $0x27
  jmp alltraps
80106c4a:	e9 5d f7 ff ff       	jmp    801063ac <alltraps>

80106c4f <vector40>:
.globl vector40
vector40:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $40
80106c51:	6a 28                	push   $0x28
  jmp alltraps
80106c53:	e9 54 f7 ff ff       	jmp    801063ac <alltraps>

80106c58 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $41
80106c5a:	6a 29                	push   $0x29
  jmp alltraps
80106c5c:	e9 4b f7 ff ff       	jmp    801063ac <alltraps>

80106c61 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $42
80106c63:	6a 2a                	push   $0x2a
  jmp alltraps
80106c65:	e9 42 f7 ff ff       	jmp    801063ac <alltraps>

80106c6a <vector43>:
.globl vector43
vector43:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $43
80106c6c:	6a 2b                	push   $0x2b
  jmp alltraps
80106c6e:	e9 39 f7 ff ff       	jmp    801063ac <alltraps>

80106c73 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $44
80106c75:	6a 2c                	push   $0x2c
  jmp alltraps
80106c77:	e9 30 f7 ff ff       	jmp    801063ac <alltraps>

80106c7c <vector45>:
.globl vector45
vector45:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $45
80106c7e:	6a 2d                	push   $0x2d
  jmp alltraps
80106c80:	e9 27 f7 ff ff       	jmp    801063ac <alltraps>

80106c85 <vector46>:
.globl vector46
vector46:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $46
80106c87:	6a 2e                	push   $0x2e
  jmp alltraps
80106c89:	e9 1e f7 ff ff       	jmp    801063ac <alltraps>

80106c8e <vector47>:
.globl vector47
vector47:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $47
80106c90:	6a 2f                	push   $0x2f
  jmp alltraps
80106c92:	e9 15 f7 ff ff       	jmp    801063ac <alltraps>

80106c97 <vector48>:
.globl vector48
vector48:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $48
80106c99:	6a 30                	push   $0x30
  jmp alltraps
80106c9b:	e9 0c f7 ff ff       	jmp    801063ac <alltraps>

80106ca0 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $49
80106ca2:	6a 31                	push   $0x31
  jmp alltraps
80106ca4:	e9 03 f7 ff ff       	jmp    801063ac <alltraps>

80106ca9 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $50
80106cab:	6a 32                	push   $0x32
  jmp alltraps
80106cad:	e9 fa f6 ff ff       	jmp    801063ac <alltraps>

80106cb2 <vector51>:
.globl vector51
vector51:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $51
80106cb4:	6a 33                	push   $0x33
  jmp alltraps
80106cb6:	e9 f1 f6 ff ff       	jmp    801063ac <alltraps>

80106cbb <vector52>:
.globl vector52
vector52:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $52
80106cbd:	6a 34                	push   $0x34
  jmp alltraps
80106cbf:	e9 e8 f6 ff ff       	jmp    801063ac <alltraps>

80106cc4 <vector53>:
.globl vector53
vector53:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $53
80106cc6:	6a 35                	push   $0x35
  jmp alltraps
80106cc8:	e9 df f6 ff ff       	jmp    801063ac <alltraps>

80106ccd <vector54>:
.globl vector54
vector54:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $54
80106ccf:	6a 36                	push   $0x36
  jmp alltraps
80106cd1:	e9 d6 f6 ff ff       	jmp    801063ac <alltraps>

80106cd6 <vector55>:
.globl vector55
vector55:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $55
80106cd8:	6a 37                	push   $0x37
  jmp alltraps
80106cda:	e9 cd f6 ff ff       	jmp    801063ac <alltraps>

80106cdf <vector56>:
.globl vector56
vector56:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $56
80106ce1:	6a 38                	push   $0x38
  jmp alltraps
80106ce3:	e9 c4 f6 ff ff       	jmp    801063ac <alltraps>

80106ce8 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $57
80106cea:	6a 39                	push   $0x39
  jmp alltraps
80106cec:	e9 bb f6 ff ff       	jmp    801063ac <alltraps>

80106cf1 <vector58>:
.globl vector58
vector58:
  pushl $0
80106cf1:	6a 00                	push   $0x0
  pushl $58
80106cf3:	6a 3a                	push   $0x3a
  jmp alltraps
80106cf5:	e9 b2 f6 ff ff       	jmp    801063ac <alltraps>

80106cfa <vector59>:
.globl vector59
vector59:
  pushl $0
80106cfa:	6a 00                	push   $0x0
  pushl $59
80106cfc:	6a 3b                	push   $0x3b
  jmp alltraps
80106cfe:	e9 a9 f6 ff ff       	jmp    801063ac <alltraps>

80106d03 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $60
80106d05:	6a 3c                	push   $0x3c
  jmp alltraps
80106d07:	e9 a0 f6 ff ff       	jmp    801063ac <alltraps>

80106d0c <vector61>:
.globl vector61
vector61:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $61
80106d0e:	6a 3d                	push   $0x3d
  jmp alltraps
80106d10:	e9 97 f6 ff ff       	jmp    801063ac <alltraps>

80106d15 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $62
80106d17:	6a 3e                	push   $0x3e
  jmp alltraps
80106d19:	e9 8e f6 ff ff       	jmp    801063ac <alltraps>

80106d1e <vector63>:
.globl vector63
vector63:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $63
80106d20:	6a 3f                	push   $0x3f
  jmp alltraps
80106d22:	e9 85 f6 ff ff       	jmp    801063ac <alltraps>

80106d27 <vector64>:
.globl vector64
vector64:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $64
80106d29:	6a 40                	push   $0x40
  jmp alltraps
80106d2b:	e9 7c f6 ff ff       	jmp    801063ac <alltraps>

80106d30 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $65
80106d32:	6a 41                	push   $0x41
  jmp alltraps
80106d34:	e9 73 f6 ff ff       	jmp    801063ac <alltraps>

80106d39 <vector66>:
.globl vector66
vector66:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $66
80106d3b:	6a 42                	push   $0x42
  jmp alltraps
80106d3d:	e9 6a f6 ff ff       	jmp    801063ac <alltraps>

80106d42 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $67
80106d44:	6a 43                	push   $0x43
  jmp alltraps
80106d46:	e9 61 f6 ff ff       	jmp    801063ac <alltraps>

80106d4b <vector68>:
.globl vector68
vector68:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $68
80106d4d:	6a 44                	push   $0x44
  jmp alltraps
80106d4f:	e9 58 f6 ff ff       	jmp    801063ac <alltraps>

80106d54 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $69
80106d56:	6a 45                	push   $0x45
  jmp alltraps
80106d58:	e9 4f f6 ff ff       	jmp    801063ac <alltraps>

80106d5d <vector70>:
.globl vector70
vector70:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $70
80106d5f:	6a 46                	push   $0x46
  jmp alltraps
80106d61:	e9 46 f6 ff ff       	jmp    801063ac <alltraps>

80106d66 <vector71>:
.globl vector71
vector71:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $71
80106d68:	6a 47                	push   $0x47
  jmp alltraps
80106d6a:	e9 3d f6 ff ff       	jmp    801063ac <alltraps>

80106d6f <vector72>:
.globl vector72
vector72:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $72
80106d71:	6a 48                	push   $0x48
  jmp alltraps
80106d73:	e9 34 f6 ff ff       	jmp    801063ac <alltraps>

80106d78 <vector73>:
.globl vector73
vector73:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $73
80106d7a:	6a 49                	push   $0x49
  jmp alltraps
80106d7c:	e9 2b f6 ff ff       	jmp    801063ac <alltraps>

80106d81 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $74
80106d83:	6a 4a                	push   $0x4a
  jmp alltraps
80106d85:	e9 22 f6 ff ff       	jmp    801063ac <alltraps>

80106d8a <vector75>:
.globl vector75
vector75:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $75
80106d8c:	6a 4b                	push   $0x4b
  jmp alltraps
80106d8e:	e9 19 f6 ff ff       	jmp    801063ac <alltraps>

80106d93 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $76
80106d95:	6a 4c                	push   $0x4c
  jmp alltraps
80106d97:	e9 10 f6 ff ff       	jmp    801063ac <alltraps>

80106d9c <vector77>:
.globl vector77
vector77:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $77
80106d9e:	6a 4d                	push   $0x4d
  jmp alltraps
80106da0:	e9 07 f6 ff ff       	jmp    801063ac <alltraps>

80106da5 <vector78>:
.globl vector78
vector78:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $78
80106da7:	6a 4e                	push   $0x4e
  jmp alltraps
80106da9:	e9 fe f5 ff ff       	jmp    801063ac <alltraps>

80106dae <vector79>:
.globl vector79
vector79:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $79
80106db0:	6a 4f                	push   $0x4f
  jmp alltraps
80106db2:	e9 f5 f5 ff ff       	jmp    801063ac <alltraps>

80106db7 <vector80>:
.globl vector80
vector80:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $80
80106db9:	6a 50                	push   $0x50
  jmp alltraps
80106dbb:	e9 ec f5 ff ff       	jmp    801063ac <alltraps>

80106dc0 <vector81>:
.globl vector81
vector81:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $81
80106dc2:	6a 51                	push   $0x51
  jmp alltraps
80106dc4:	e9 e3 f5 ff ff       	jmp    801063ac <alltraps>

80106dc9 <vector82>:
.globl vector82
vector82:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $82
80106dcb:	6a 52                	push   $0x52
  jmp alltraps
80106dcd:	e9 da f5 ff ff       	jmp    801063ac <alltraps>

80106dd2 <vector83>:
.globl vector83
vector83:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $83
80106dd4:	6a 53                	push   $0x53
  jmp alltraps
80106dd6:	e9 d1 f5 ff ff       	jmp    801063ac <alltraps>

80106ddb <vector84>:
.globl vector84
vector84:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $84
80106ddd:	6a 54                	push   $0x54
  jmp alltraps
80106ddf:	e9 c8 f5 ff ff       	jmp    801063ac <alltraps>

80106de4 <vector85>:
.globl vector85
vector85:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $85
80106de6:	6a 55                	push   $0x55
  jmp alltraps
80106de8:	e9 bf f5 ff ff       	jmp    801063ac <alltraps>

80106ded <vector86>:
.globl vector86
vector86:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $86
80106def:	6a 56                	push   $0x56
  jmp alltraps
80106df1:	e9 b6 f5 ff ff       	jmp    801063ac <alltraps>

80106df6 <vector87>:
.globl vector87
vector87:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $87
80106df8:	6a 57                	push   $0x57
  jmp alltraps
80106dfa:	e9 ad f5 ff ff       	jmp    801063ac <alltraps>

80106dff <vector88>:
.globl vector88
vector88:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $88
80106e01:	6a 58                	push   $0x58
  jmp alltraps
80106e03:	e9 a4 f5 ff ff       	jmp    801063ac <alltraps>

80106e08 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $89
80106e0a:	6a 59                	push   $0x59
  jmp alltraps
80106e0c:	e9 9b f5 ff ff       	jmp    801063ac <alltraps>

80106e11 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $90
80106e13:	6a 5a                	push   $0x5a
  jmp alltraps
80106e15:	e9 92 f5 ff ff       	jmp    801063ac <alltraps>

80106e1a <vector91>:
.globl vector91
vector91:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $91
80106e1c:	6a 5b                	push   $0x5b
  jmp alltraps
80106e1e:	e9 89 f5 ff ff       	jmp    801063ac <alltraps>

80106e23 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $92
80106e25:	6a 5c                	push   $0x5c
  jmp alltraps
80106e27:	e9 80 f5 ff ff       	jmp    801063ac <alltraps>

80106e2c <vector93>:
.globl vector93
vector93:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $93
80106e2e:	6a 5d                	push   $0x5d
  jmp alltraps
80106e30:	e9 77 f5 ff ff       	jmp    801063ac <alltraps>

80106e35 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $94
80106e37:	6a 5e                	push   $0x5e
  jmp alltraps
80106e39:	e9 6e f5 ff ff       	jmp    801063ac <alltraps>

80106e3e <vector95>:
.globl vector95
vector95:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $95
80106e40:	6a 5f                	push   $0x5f
  jmp alltraps
80106e42:	e9 65 f5 ff ff       	jmp    801063ac <alltraps>

80106e47 <vector96>:
.globl vector96
vector96:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $96
80106e49:	6a 60                	push   $0x60
  jmp alltraps
80106e4b:	e9 5c f5 ff ff       	jmp    801063ac <alltraps>

80106e50 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $97
80106e52:	6a 61                	push   $0x61
  jmp alltraps
80106e54:	e9 53 f5 ff ff       	jmp    801063ac <alltraps>

80106e59 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $98
80106e5b:	6a 62                	push   $0x62
  jmp alltraps
80106e5d:	e9 4a f5 ff ff       	jmp    801063ac <alltraps>

80106e62 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $99
80106e64:	6a 63                	push   $0x63
  jmp alltraps
80106e66:	e9 41 f5 ff ff       	jmp    801063ac <alltraps>

80106e6b <vector100>:
.globl vector100
vector100:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $100
80106e6d:	6a 64                	push   $0x64
  jmp alltraps
80106e6f:	e9 38 f5 ff ff       	jmp    801063ac <alltraps>

80106e74 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $101
80106e76:	6a 65                	push   $0x65
  jmp alltraps
80106e78:	e9 2f f5 ff ff       	jmp    801063ac <alltraps>

80106e7d <vector102>:
.globl vector102
vector102:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $102
80106e7f:	6a 66                	push   $0x66
  jmp alltraps
80106e81:	e9 26 f5 ff ff       	jmp    801063ac <alltraps>

80106e86 <vector103>:
.globl vector103
vector103:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $103
80106e88:	6a 67                	push   $0x67
  jmp alltraps
80106e8a:	e9 1d f5 ff ff       	jmp    801063ac <alltraps>

80106e8f <vector104>:
.globl vector104
vector104:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $104
80106e91:	6a 68                	push   $0x68
  jmp alltraps
80106e93:	e9 14 f5 ff ff       	jmp    801063ac <alltraps>

80106e98 <vector105>:
.globl vector105
vector105:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $105
80106e9a:	6a 69                	push   $0x69
  jmp alltraps
80106e9c:	e9 0b f5 ff ff       	jmp    801063ac <alltraps>

80106ea1 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $106
80106ea3:	6a 6a                	push   $0x6a
  jmp alltraps
80106ea5:	e9 02 f5 ff ff       	jmp    801063ac <alltraps>

80106eaa <vector107>:
.globl vector107
vector107:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $107
80106eac:	6a 6b                	push   $0x6b
  jmp alltraps
80106eae:	e9 f9 f4 ff ff       	jmp    801063ac <alltraps>

80106eb3 <vector108>:
.globl vector108
vector108:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $108
80106eb5:	6a 6c                	push   $0x6c
  jmp alltraps
80106eb7:	e9 f0 f4 ff ff       	jmp    801063ac <alltraps>

80106ebc <vector109>:
.globl vector109
vector109:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $109
80106ebe:	6a 6d                	push   $0x6d
  jmp alltraps
80106ec0:	e9 e7 f4 ff ff       	jmp    801063ac <alltraps>

80106ec5 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $110
80106ec7:	6a 6e                	push   $0x6e
  jmp alltraps
80106ec9:	e9 de f4 ff ff       	jmp    801063ac <alltraps>

80106ece <vector111>:
.globl vector111
vector111:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $111
80106ed0:	6a 6f                	push   $0x6f
  jmp alltraps
80106ed2:	e9 d5 f4 ff ff       	jmp    801063ac <alltraps>

80106ed7 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $112
80106ed9:	6a 70                	push   $0x70
  jmp alltraps
80106edb:	e9 cc f4 ff ff       	jmp    801063ac <alltraps>

80106ee0 <vector113>:
.globl vector113
vector113:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $113
80106ee2:	6a 71                	push   $0x71
  jmp alltraps
80106ee4:	e9 c3 f4 ff ff       	jmp    801063ac <alltraps>

80106ee9 <vector114>:
.globl vector114
vector114:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $114
80106eeb:	6a 72                	push   $0x72
  jmp alltraps
80106eed:	e9 ba f4 ff ff       	jmp    801063ac <alltraps>

80106ef2 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $115
80106ef4:	6a 73                	push   $0x73
  jmp alltraps
80106ef6:	e9 b1 f4 ff ff       	jmp    801063ac <alltraps>

80106efb <vector116>:
.globl vector116
vector116:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $116
80106efd:	6a 74                	push   $0x74
  jmp alltraps
80106eff:	e9 a8 f4 ff ff       	jmp    801063ac <alltraps>

80106f04 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $117
80106f06:	6a 75                	push   $0x75
  jmp alltraps
80106f08:	e9 9f f4 ff ff       	jmp    801063ac <alltraps>

80106f0d <vector118>:
.globl vector118
vector118:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $118
80106f0f:	6a 76                	push   $0x76
  jmp alltraps
80106f11:	e9 96 f4 ff ff       	jmp    801063ac <alltraps>

80106f16 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $119
80106f18:	6a 77                	push   $0x77
  jmp alltraps
80106f1a:	e9 8d f4 ff ff       	jmp    801063ac <alltraps>

80106f1f <vector120>:
.globl vector120
vector120:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $120
80106f21:	6a 78                	push   $0x78
  jmp alltraps
80106f23:	e9 84 f4 ff ff       	jmp    801063ac <alltraps>

80106f28 <vector121>:
.globl vector121
vector121:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $121
80106f2a:	6a 79                	push   $0x79
  jmp alltraps
80106f2c:	e9 7b f4 ff ff       	jmp    801063ac <alltraps>

80106f31 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $122
80106f33:	6a 7a                	push   $0x7a
  jmp alltraps
80106f35:	e9 72 f4 ff ff       	jmp    801063ac <alltraps>

80106f3a <vector123>:
.globl vector123
vector123:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $123
80106f3c:	6a 7b                	push   $0x7b
  jmp alltraps
80106f3e:	e9 69 f4 ff ff       	jmp    801063ac <alltraps>

80106f43 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $124
80106f45:	6a 7c                	push   $0x7c
  jmp alltraps
80106f47:	e9 60 f4 ff ff       	jmp    801063ac <alltraps>

80106f4c <vector125>:
.globl vector125
vector125:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $125
80106f4e:	6a 7d                	push   $0x7d
  jmp alltraps
80106f50:	e9 57 f4 ff ff       	jmp    801063ac <alltraps>

80106f55 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $126
80106f57:	6a 7e                	push   $0x7e
  jmp alltraps
80106f59:	e9 4e f4 ff ff       	jmp    801063ac <alltraps>

80106f5e <vector127>:
.globl vector127
vector127:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $127
80106f60:	6a 7f                	push   $0x7f
  jmp alltraps
80106f62:	e9 45 f4 ff ff       	jmp    801063ac <alltraps>

80106f67 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $128
80106f69:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f6e:	e9 39 f4 ff ff       	jmp    801063ac <alltraps>

80106f73 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $129
80106f75:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f7a:	e9 2d f4 ff ff       	jmp    801063ac <alltraps>

80106f7f <vector130>:
.globl vector130
vector130:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $130
80106f81:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f86:	e9 21 f4 ff ff       	jmp    801063ac <alltraps>

80106f8b <vector131>:
.globl vector131
vector131:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $131
80106f8d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f92:	e9 15 f4 ff ff       	jmp    801063ac <alltraps>

80106f97 <vector132>:
.globl vector132
vector132:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $132
80106f99:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f9e:	e9 09 f4 ff ff       	jmp    801063ac <alltraps>

80106fa3 <vector133>:
.globl vector133
vector133:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $133
80106fa5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106faa:	e9 fd f3 ff ff       	jmp    801063ac <alltraps>

80106faf <vector134>:
.globl vector134
vector134:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $134
80106fb1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106fb6:	e9 f1 f3 ff ff       	jmp    801063ac <alltraps>

80106fbb <vector135>:
.globl vector135
vector135:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $135
80106fbd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106fc2:	e9 e5 f3 ff ff       	jmp    801063ac <alltraps>

80106fc7 <vector136>:
.globl vector136
vector136:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $136
80106fc9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106fce:	e9 d9 f3 ff ff       	jmp    801063ac <alltraps>

80106fd3 <vector137>:
.globl vector137
vector137:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $137
80106fd5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106fda:	e9 cd f3 ff ff       	jmp    801063ac <alltraps>

80106fdf <vector138>:
.globl vector138
vector138:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $138
80106fe1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106fe6:	e9 c1 f3 ff ff       	jmp    801063ac <alltraps>

80106feb <vector139>:
.globl vector139
vector139:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $139
80106fed:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ff2:	e9 b5 f3 ff ff       	jmp    801063ac <alltraps>

80106ff7 <vector140>:
.globl vector140
vector140:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $140
80106ff9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106ffe:	e9 a9 f3 ff ff       	jmp    801063ac <alltraps>

80107003 <vector141>:
.globl vector141
vector141:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $141
80107005:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010700a:	e9 9d f3 ff ff       	jmp    801063ac <alltraps>

8010700f <vector142>:
.globl vector142
vector142:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $142
80107011:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107016:	e9 91 f3 ff ff       	jmp    801063ac <alltraps>

8010701b <vector143>:
.globl vector143
vector143:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $143
8010701d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107022:	e9 85 f3 ff ff       	jmp    801063ac <alltraps>

80107027 <vector144>:
.globl vector144
vector144:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $144
80107029:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010702e:	e9 79 f3 ff ff       	jmp    801063ac <alltraps>

80107033 <vector145>:
.globl vector145
vector145:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $145
80107035:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010703a:	e9 6d f3 ff ff       	jmp    801063ac <alltraps>

8010703f <vector146>:
.globl vector146
vector146:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $146
80107041:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107046:	e9 61 f3 ff ff       	jmp    801063ac <alltraps>

8010704b <vector147>:
.globl vector147
vector147:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $147
8010704d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107052:	e9 55 f3 ff ff       	jmp    801063ac <alltraps>

80107057 <vector148>:
.globl vector148
vector148:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $148
80107059:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010705e:	e9 49 f3 ff ff       	jmp    801063ac <alltraps>

80107063 <vector149>:
.globl vector149
vector149:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $149
80107065:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010706a:	e9 3d f3 ff ff       	jmp    801063ac <alltraps>

8010706f <vector150>:
.globl vector150
vector150:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $150
80107071:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107076:	e9 31 f3 ff ff       	jmp    801063ac <alltraps>

8010707b <vector151>:
.globl vector151
vector151:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $151
8010707d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107082:	e9 25 f3 ff ff       	jmp    801063ac <alltraps>

80107087 <vector152>:
.globl vector152
vector152:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $152
80107089:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010708e:	e9 19 f3 ff ff       	jmp    801063ac <alltraps>

80107093 <vector153>:
.globl vector153
vector153:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $153
80107095:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010709a:	e9 0d f3 ff ff       	jmp    801063ac <alltraps>

8010709f <vector154>:
.globl vector154
vector154:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $154
801070a1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070a6:	e9 01 f3 ff ff       	jmp    801063ac <alltraps>

801070ab <vector155>:
.globl vector155
vector155:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $155
801070ad:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801070b2:	e9 f5 f2 ff ff       	jmp    801063ac <alltraps>

801070b7 <vector156>:
.globl vector156
vector156:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $156
801070b9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070be:	e9 e9 f2 ff ff       	jmp    801063ac <alltraps>

801070c3 <vector157>:
.globl vector157
vector157:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $157
801070c5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801070ca:	e9 dd f2 ff ff       	jmp    801063ac <alltraps>

801070cf <vector158>:
.globl vector158
vector158:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $158
801070d1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801070d6:	e9 d1 f2 ff ff       	jmp    801063ac <alltraps>

801070db <vector159>:
.globl vector159
vector159:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $159
801070dd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801070e2:	e9 c5 f2 ff ff       	jmp    801063ac <alltraps>

801070e7 <vector160>:
.globl vector160
vector160:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $160
801070e9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070ee:	e9 b9 f2 ff ff       	jmp    801063ac <alltraps>

801070f3 <vector161>:
.globl vector161
vector161:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $161
801070f5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070fa:	e9 ad f2 ff ff       	jmp    801063ac <alltraps>

801070ff <vector162>:
.globl vector162
vector162:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $162
80107101:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107106:	e9 a1 f2 ff ff       	jmp    801063ac <alltraps>

8010710b <vector163>:
.globl vector163
vector163:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $163
8010710d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107112:	e9 95 f2 ff ff       	jmp    801063ac <alltraps>

80107117 <vector164>:
.globl vector164
vector164:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $164
80107119:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010711e:	e9 89 f2 ff ff       	jmp    801063ac <alltraps>

80107123 <vector165>:
.globl vector165
vector165:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $165
80107125:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010712a:	e9 7d f2 ff ff       	jmp    801063ac <alltraps>

8010712f <vector166>:
.globl vector166
vector166:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $166
80107131:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107136:	e9 71 f2 ff ff       	jmp    801063ac <alltraps>

8010713b <vector167>:
.globl vector167
vector167:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $167
8010713d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107142:	e9 65 f2 ff ff       	jmp    801063ac <alltraps>

80107147 <vector168>:
.globl vector168
vector168:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $168
80107149:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010714e:	e9 59 f2 ff ff       	jmp    801063ac <alltraps>

80107153 <vector169>:
.globl vector169
vector169:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $169
80107155:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010715a:	e9 4d f2 ff ff       	jmp    801063ac <alltraps>

8010715f <vector170>:
.globl vector170
vector170:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $170
80107161:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107166:	e9 41 f2 ff ff       	jmp    801063ac <alltraps>

8010716b <vector171>:
.globl vector171
vector171:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $171
8010716d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107172:	e9 35 f2 ff ff       	jmp    801063ac <alltraps>

80107177 <vector172>:
.globl vector172
vector172:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $172
80107179:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010717e:	e9 29 f2 ff ff       	jmp    801063ac <alltraps>

80107183 <vector173>:
.globl vector173
vector173:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $173
80107185:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010718a:	e9 1d f2 ff ff       	jmp    801063ac <alltraps>

8010718f <vector174>:
.globl vector174
vector174:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $174
80107191:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107196:	e9 11 f2 ff ff       	jmp    801063ac <alltraps>

8010719b <vector175>:
.globl vector175
vector175:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $175
8010719d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071a2:	e9 05 f2 ff ff       	jmp    801063ac <alltraps>

801071a7 <vector176>:
.globl vector176
vector176:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $176
801071a9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801071ae:	e9 f9 f1 ff ff       	jmp    801063ac <alltraps>

801071b3 <vector177>:
.globl vector177
vector177:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $177
801071b5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801071ba:	e9 ed f1 ff ff       	jmp    801063ac <alltraps>

801071bf <vector178>:
.globl vector178
vector178:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $178
801071c1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801071c6:	e9 e1 f1 ff ff       	jmp    801063ac <alltraps>

801071cb <vector179>:
.globl vector179
vector179:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $179
801071cd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801071d2:	e9 d5 f1 ff ff       	jmp    801063ac <alltraps>

801071d7 <vector180>:
.globl vector180
vector180:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $180
801071d9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071de:	e9 c9 f1 ff ff       	jmp    801063ac <alltraps>

801071e3 <vector181>:
.globl vector181
vector181:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $181
801071e5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071ea:	e9 bd f1 ff ff       	jmp    801063ac <alltraps>

801071ef <vector182>:
.globl vector182
vector182:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $182
801071f1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071f6:	e9 b1 f1 ff ff       	jmp    801063ac <alltraps>

801071fb <vector183>:
.globl vector183
vector183:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $183
801071fd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107202:	e9 a5 f1 ff ff       	jmp    801063ac <alltraps>

80107207 <vector184>:
.globl vector184
vector184:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $184
80107209:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010720e:	e9 99 f1 ff ff       	jmp    801063ac <alltraps>

80107213 <vector185>:
.globl vector185
vector185:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $185
80107215:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010721a:	e9 8d f1 ff ff       	jmp    801063ac <alltraps>

8010721f <vector186>:
.globl vector186
vector186:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $186
80107221:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107226:	e9 81 f1 ff ff       	jmp    801063ac <alltraps>

8010722b <vector187>:
.globl vector187
vector187:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $187
8010722d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107232:	e9 75 f1 ff ff       	jmp    801063ac <alltraps>

80107237 <vector188>:
.globl vector188
vector188:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $188
80107239:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010723e:	e9 69 f1 ff ff       	jmp    801063ac <alltraps>

80107243 <vector189>:
.globl vector189
vector189:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $189
80107245:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010724a:	e9 5d f1 ff ff       	jmp    801063ac <alltraps>

8010724f <vector190>:
.globl vector190
vector190:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $190
80107251:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107256:	e9 51 f1 ff ff       	jmp    801063ac <alltraps>

8010725b <vector191>:
.globl vector191
vector191:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $191
8010725d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107262:	e9 45 f1 ff ff       	jmp    801063ac <alltraps>

80107267 <vector192>:
.globl vector192
vector192:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $192
80107269:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010726e:	e9 39 f1 ff ff       	jmp    801063ac <alltraps>

80107273 <vector193>:
.globl vector193
vector193:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $193
80107275:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010727a:	e9 2d f1 ff ff       	jmp    801063ac <alltraps>

8010727f <vector194>:
.globl vector194
vector194:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $194
80107281:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107286:	e9 21 f1 ff ff       	jmp    801063ac <alltraps>

8010728b <vector195>:
.globl vector195
vector195:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $195
8010728d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107292:	e9 15 f1 ff ff       	jmp    801063ac <alltraps>

80107297 <vector196>:
.globl vector196
vector196:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $196
80107299:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010729e:	e9 09 f1 ff ff       	jmp    801063ac <alltraps>

801072a3 <vector197>:
.globl vector197
vector197:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $197
801072a5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801072aa:	e9 fd f0 ff ff       	jmp    801063ac <alltraps>

801072af <vector198>:
.globl vector198
vector198:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $198
801072b1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801072b6:	e9 f1 f0 ff ff       	jmp    801063ac <alltraps>

801072bb <vector199>:
.globl vector199
vector199:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $199
801072bd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801072c2:	e9 e5 f0 ff ff       	jmp    801063ac <alltraps>

801072c7 <vector200>:
.globl vector200
vector200:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $200
801072c9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801072ce:	e9 d9 f0 ff ff       	jmp    801063ac <alltraps>

801072d3 <vector201>:
.globl vector201
vector201:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $201
801072d5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072da:	e9 cd f0 ff ff       	jmp    801063ac <alltraps>

801072df <vector202>:
.globl vector202
vector202:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $202
801072e1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801072e6:	e9 c1 f0 ff ff       	jmp    801063ac <alltraps>

801072eb <vector203>:
.globl vector203
vector203:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $203
801072ed:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072f2:	e9 b5 f0 ff ff       	jmp    801063ac <alltraps>

801072f7 <vector204>:
.globl vector204
vector204:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $204
801072f9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072fe:	e9 a9 f0 ff ff       	jmp    801063ac <alltraps>

80107303 <vector205>:
.globl vector205
vector205:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $205
80107305:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010730a:	e9 9d f0 ff ff       	jmp    801063ac <alltraps>

8010730f <vector206>:
.globl vector206
vector206:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $206
80107311:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107316:	e9 91 f0 ff ff       	jmp    801063ac <alltraps>

8010731b <vector207>:
.globl vector207
vector207:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $207
8010731d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107322:	e9 85 f0 ff ff       	jmp    801063ac <alltraps>

80107327 <vector208>:
.globl vector208
vector208:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $208
80107329:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010732e:	e9 79 f0 ff ff       	jmp    801063ac <alltraps>

80107333 <vector209>:
.globl vector209
vector209:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $209
80107335:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010733a:	e9 6d f0 ff ff       	jmp    801063ac <alltraps>

8010733f <vector210>:
.globl vector210
vector210:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $210
80107341:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107346:	e9 61 f0 ff ff       	jmp    801063ac <alltraps>

8010734b <vector211>:
.globl vector211
vector211:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $211
8010734d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107352:	e9 55 f0 ff ff       	jmp    801063ac <alltraps>

80107357 <vector212>:
.globl vector212
vector212:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $212
80107359:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010735e:	e9 49 f0 ff ff       	jmp    801063ac <alltraps>

80107363 <vector213>:
.globl vector213
vector213:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $213
80107365:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010736a:	e9 3d f0 ff ff       	jmp    801063ac <alltraps>

8010736f <vector214>:
.globl vector214
vector214:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $214
80107371:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107376:	e9 31 f0 ff ff       	jmp    801063ac <alltraps>

8010737b <vector215>:
.globl vector215
vector215:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $215
8010737d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107382:	e9 25 f0 ff ff       	jmp    801063ac <alltraps>

80107387 <vector216>:
.globl vector216
vector216:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $216
80107389:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010738e:	e9 19 f0 ff ff       	jmp    801063ac <alltraps>

80107393 <vector217>:
.globl vector217
vector217:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $217
80107395:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010739a:	e9 0d f0 ff ff       	jmp    801063ac <alltraps>

8010739f <vector218>:
.globl vector218
vector218:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $218
801073a1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073a6:	e9 01 f0 ff ff       	jmp    801063ac <alltraps>

801073ab <vector219>:
.globl vector219
vector219:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $219
801073ad:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801073b2:	e9 f5 ef ff ff       	jmp    801063ac <alltraps>

801073b7 <vector220>:
.globl vector220
vector220:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $220
801073b9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073be:	e9 e9 ef ff ff       	jmp    801063ac <alltraps>

801073c3 <vector221>:
.globl vector221
vector221:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $221
801073c5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801073ca:	e9 dd ef ff ff       	jmp    801063ac <alltraps>

801073cf <vector222>:
.globl vector222
vector222:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $222
801073d1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801073d6:	e9 d1 ef ff ff       	jmp    801063ac <alltraps>

801073db <vector223>:
.globl vector223
vector223:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $223
801073dd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801073e2:	e9 c5 ef ff ff       	jmp    801063ac <alltraps>

801073e7 <vector224>:
.globl vector224
vector224:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $224
801073e9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073ee:	e9 b9 ef ff ff       	jmp    801063ac <alltraps>

801073f3 <vector225>:
.globl vector225
vector225:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $225
801073f5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073fa:	e9 ad ef ff ff       	jmp    801063ac <alltraps>

801073ff <vector226>:
.globl vector226
vector226:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $226
80107401:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107406:	e9 a1 ef ff ff       	jmp    801063ac <alltraps>

8010740b <vector227>:
.globl vector227
vector227:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $227
8010740d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107412:	e9 95 ef ff ff       	jmp    801063ac <alltraps>

80107417 <vector228>:
.globl vector228
vector228:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $228
80107419:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010741e:	e9 89 ef ff ff       	jmp    801063ac <alltraps>

80107423 <vector229>:
.globl vector229
vector229:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $229
80107425:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010742a:	e9 7d ef ff ff       	jmp    801063ac <alltraps>

8010742f <vector230>:
.globl vector230
vector230:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $230
80107431:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107436:	e9 71 ef ff ff       	jmp    801063ac <alltraps>

8010743b <vector231>:
.globl vector231
vector231:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $231
8010743d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107442:	e9 65 ef ff ff       	jmp    801063ac <alltraps>

80107447 <vector232>:
.globl vector232
vector232:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $232
80107449:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010744e:	e9 59 ef ff ff       	jmp    801063ac <alltraps>

80107453 <vector233>:
.globl vector233
vector233:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $233
80107455:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010745a:	e9 4d ef ff ff       	jmp    801063ac <alltraps>

8010745f <vector234>:
.globl vector234
vector234:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $234
80107461:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107466:	e9 41 ef ff ff       	jmp    801063ac <alltraps>

8010746b <vector235>:
.globl vector235
vector235:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $235
8010746d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107472:	e9 35 ef ff ff       	jmp    801063ac <alltraps>

80107477 <vector236>:
.globl vector236
vector236:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $236
80107479:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010747e:	e9 29 ef ff ff       	jmp    801063ac <alltraps>

80107483 <vector237>:
.globl vector237
vector237:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $237
80107485:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010748a:	e9 1d ef ff ff       	jmp    801063ac <alltraps>

8010748f <vector238>:
.globl vector238
vector238:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $238
80107491:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107496:	e9 11 ef ff ff       	jmp    801063ac <alltraps>

8010749b <vector239>:
.globl vector239
vector239:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $239
8010749d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074a2:	e9 05 ef ff ff       	jmp    801063ac <alltraps>

801074a7 <vector240>:
.globl vector240
vector240:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $240
801074a9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801074ae:	e9 f9 ee ff ff       	jmp    801063ac <alltraps>

801074b3 <vector241>:
.globl vector241
vector241:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $241
801074b5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801074ba:	e9 ed ee ff ff       	jmp    801063ac <alltraps>

801074bf <vector242>:
.globl vector242
vector242:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $242
801074c1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801074c6:	e9 e1 ee ff ff       	jmp    801063ac <alltraps>

801074cb <vector243>:
.globl vector243
vector243:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $243
801074cd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801074d2:	e9 d5 ee ff ff       	jmp    801063ac <alltraps>

801074d7 <vector244>:
.globl vector244
vector244:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $244
801074d9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074de:	e9 c9 ee ff ff       	jmp    801063ac <alltraps>

801074e3 <vector245>:
.globl vector245
vector245:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $245
801074e5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074ea:	e9 bd ee ff ff       	jmp    801063ac <alltraps>

801074ef <vector246>:
.globl vector246
vector246:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $246
801074f1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074f6:	e9 b1 ee ff ff       	jmp    801063ac <alltraps>

801074fb <vector247>:
.globl vector247
vector247:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $247
801074fd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107502:	e9 a5 ee ff ff       	jmp    801063ac <alltraps>

80107507 <vector248>:
.globl vector248
vector248:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $248
80107509:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010750e:	e9 99 ee ff ff       	jmp    801063ac <alltraps>

80107513 <vector249>:
.globl vector249
vector249:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $249
80107515:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010751a:	e9 8d ee ff ff       	jmp    801063ac <alltraps>

8010751f <vector250>:
.globl vector250
vector250:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $250
80107521:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107526:	e9 81 ee ff ff       	jmp    801063ac <alltraps>

8010752b <vector251>:
.globl vector251
vector251:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $251
8010752d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107532:	e9 75 ee ff ff       	jmp    801063ac <alltraps>

80107537 <vector252>:
.globl vector252
vector252:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $252
80107539:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010753e:	e9 69 ee ff ff       	jmp    801063ac <alltraps>

80107543 <vector253>:
.globl vector253
vector253:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $253
80107545:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010754a:	e9 5d ee ff ff       	jmp    801063ac <alltraps>

8010754f <vector254>:
.globl vector254
vector254:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $254
80107551:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107556:	e9 51 ee ff ff       	jmp    801063ac <alltraps>

8010755b <vector255>:
.globl vector255
vector255:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $255
8010755d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107562:	e9 45 ee ff ff       	jmp    801063ac <alltraps>

80107567 <lgdt>:
{
80107567:	55                   	push   %ebp
80107568:	89 e5                	mov    %esp,%ebp
8010756a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010756d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107570:	83 e8 01             	sub    $0x1,%eax
80107573:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107577:	8b 45 08             	mov    0x8(%ebp),%eax
8010757a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010757e:	8b 45 08             	mov    0x8(%ebp),%eax
80107581:	c1 e8 10             	shr    $0x10,%eax
80107584:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107588:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010758b:	0f 01 10             	lgdtl  (%eax)
}
8010758e:	90                   	nop
8010758f:	c9                   	leave  
80107590:	c3                   	ret    

80107591 <ltr>:
{
80107591:	55                   	push   %ebp
80107592:	89 e5                	mov    %esp,%ebp
80107594:	83 ec 04             	sub    $0x4,%esp
80107597:	8b 45 08             	mov    0x8(%ebp),%eax
8010759a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010759e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075a2:	0f 00 d8             	ltr    %ax
}
801075a5:	90                   	nop
801075a6:	c9                   	leave  
801075a7:	c3                   	ret    

801075a8 <lcr3>:
{
801075a8:	55                   	push   %ebp
801075a9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075ab:	8b 45 08             	mov    0x8(%ebp),%eax
801075ae:	0f 22 d8             	mov    %eax,%cr3
}
801075b1:	90                   	nop
801075b2:	5d                   	pop    %ebp
801075b3:	c3                   	ret    

801075b4 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075b4:	55                   	push   %ebp
801075b5:	89 e5                	mov    %esp,%ebp
801075b7:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801075ba:	e8 b8 c8 ff ff       	call   80103e77 <cpuid>
801075bf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801075c5:	05 c0 99 11 80       	add    $0x801199c0,%eax
801075ca:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801075d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075ed:	83 e2 f0             	and    $0xfffffff0,%edx
801075f0:	83 ca 0a             	or     $0xa,%edx
801075f3:	88 50 7d             	mov    %dl,0x7d(%eax)
801075f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075fd:	83 ca 10             	or     $0x10,%edx
80107600:	88 50 7d             	mov    %dl,0x7d(%eax)
80107603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107606:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010760a:	83 e2 9f             	and    $0xffffff9f,%edx
8010760d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107613:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107617:	83 ca 80             	or     $0xffffff80,%edx
8010761a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010761d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107620:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107624:	83 ca 0f             	or     $0xf,%edx
80107627:	88 50 7e             	mov    %dl,0x7e(%eax)
8010762a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107631:	83 e2 ef             	and    $0xffffffef,%edx
80107634:	88 50 7e             	mov    %dl,0x7e(%eax)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010763e:	83 e2 df             	and    $0xffffffdf,%edx
80107641:	88 50 7e             	mov    %dl,0x7e(%eax)
80107644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107647:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010764b:	83 ca 40             	or     $0x40,%edx
8010764e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107654:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107658:	83 ca 80             	or     $0xffffff80,%edx
8010765b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107668:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010766f:	ff ff 
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010767b:	00 00 
8010767d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107680:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107691:	83 e2 f0             	and    $0xfffffff0,%edx
80107694:	83 ca 02             	or     $0x2,%edx
80107697:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076a7:	83 ca 10             	or     $0x10,%edx
801076aa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076ba:	83 e2 9f             	and    $0xffffff9f,%edx
801076bd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076cd:	83 ca 80             	or     $0xffffff80,%edx
801076d0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076e0:	83 ca 0f             	or     $0xf,%edx
801076e3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ec:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076f3:	83 e2 ef             	and    $0xffffffef,%edx
801076f6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107706:	83 e2 df             	and    $0xffffffdf,%edx
80107709:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107712:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107719:	83 ca 40             	or     $0x40,%edx
8010771c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107725:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010772c:	83 ca 80             	or     $0xffffff80,%edx
8010772f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107738:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010773f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107742:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107749:	ff ff 
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107755:	00 00 
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010776b:	83 e2 f0             	and    $0xfffffff0,%edx
8010776e:	83 ca 0a             	or     $0xa,%edx
80107771:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107781:	83 ca 10             	or     $0x10,%edx
80107784:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107794:	83 ca 60             	or     $0x60,%edx
80107797:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077a7:	83 ca 80             	or     $0xffffff80,%edx
801077aa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077ba:	83 ca 0f             	or     $0xf,%edx
801077bd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077cd:	83 e2 ef             	and    $0xffffffef,%edx
801077d0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077e0:	83 e2 df             	and    $0xffffffdf,%edx
801077e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077f3:	83 ca 40             	or     $0x40,%edx
801077f6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107806:	83 ca 80             	or     $0xffffff80,%edx
80107809:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010780f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107812:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107823:	ff ff 
80107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107828:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010782f:	00 00 
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107845:	83 e2 f0             	and    $0xfffffff0,%edx
80107848:	83 ca 02             	or     $0x2,%edx
8010784b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010785b:	83 ca 10             	or     $0x10,%edx
8010785e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107867:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010786e:	83 ca 60             	or     $0x60,%edx
80107871:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107881:	83 ca 80             	or     $0xffffff80,%edx
80107884:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107894:	83 ca 0f             	or     $0xf,%edx
80107897:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010789d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078a7:	83 e2 ef             	and    $0xffffffef,%edx
801078aa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ba:	83 e2 df             	and    $0xffffffdf,%edx
801078bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078cd:	83 ca 40             	or     $0x40,%edx
801078d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078e0:	83 ca 80             	or     $0xffffff80,%edx
801078e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ec:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	83 c0 70             	add    $0x70,%eax
801078f9:	83 ec 08             	sub    $0x8,%esp
801078fc:	6a 30                	push   $0x30
801078fe:	50                   	push   %eax
801078ff:	e8 63 fc ff ff       	call   80107567 <lgdt>
80107904:	83 c4 10             	add    $0x10,%esp
}
80107907:	90                   	nop
80107908:	c9                   	leave  
80107909:	c3                   	ret    

8010790a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010790a:	55                   	push   %ebp
8010790b:	89 e5                	mov    %esp,%ebp
8010790d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107910:	8b 45 0c             	mov    0xc(%ebp),%eax
80107913:	c1 e8 16             	shr    $0x16,%eax
80107916:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010791d:	8b 45 08             	mov    0x8(%ebp),%eax
80107920:	01 d0                	add    %edx,%eax
80107922:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107928:	8b 00                	mov    (%eax),%eax
8010792a:	83 e0 01             	and    $0x1,%eax
8010792d:	85 c0                	test   %eax,%eax
8010792f:	74 14                	je     80107945 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107934:	8b 00                	mov    (%eax),%eax
80107936:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010793b:	05 00 00 00 80       	add    $0x80000000,%eax
80107940:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107943:	eb 42                	jmp    80107987 <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107945:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107949:	74 0e                	je     80107959 <walkpgdir+0x4f>
8010794b:	e8 2a b3 ff ff       	call   80102c7a <kalloc>
80107950:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107953:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107957:	75 07                	jne    80107960 <walkpgdir+0x56>
      return 0;
80107959:	b8 00 00 00 00       	mov    $0x0,%eax
8010795e:	eb 3e                	jmp    8010799e <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107960:	83 ec 04             	sub    $0x4,%esp
80107963:	68 00 10 00 00       	push   $0x1000
80107968:	6a 00                	push   $0x0
8010796a:	ff 75 f4             	push   -0xc(%ebp)
8010796d:	e8 2b d6 ff ff       	call   80104f9d <memset>
80107972:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107978:	05 00 00 00 80       	add    $0x80000000,%eax
8010797d:	83 c8 07             	or     $0x7,%eax
80107980:	89 c2                	mov    %eax,%edx
80107982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107985:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107987:	8b 45 0c             	mov    0xc(%ebp),%eax
8010798a:	c1 e8 0c             	shr    $0xc,%eax
8010798d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107992:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799c:	01 d0                	add    %edx,%eax
}
8010799e:	c9                   	leave  
8010799f:	c3                   	ret    

801079a0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801079a0:	55                   	push   %ebp
801079a1:	89 e5                	mov    %esp,%ebp
801079a3:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801079a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801079a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801079b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801079b4:	8b 45 10             	mov    0x10(%ebp),%eax
801079b7:	01 d0                	add    %edx,%eax
801079b9:	83 e8 01             	sub    $0x1,%eax
801079bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801079c4:	83 ec 04             	sub    $0x4,%esp
801079c7:	6a 01                	push   $0x1
801079c9:	ff 75 f4             	push   -0xc(%ebp)
801079cc:	ff 75 08             	push   0x8(%ebp)
801079cf:	e8 36 ff ff ff       	call   8010790a <walkpgdir>
801079d4:	83 c4 10             	add    $0x10,%esp
801079d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079de:	75 07                	jne    801079e7 <mappages+0x47>
      return -1;
801079e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079e5:	eb 47                	jmp    80107a2e <mappages+0x8e>
    if(*pte & PTE_P)
801079e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079ea:	8b 00                	mov    (%eax),%eax
801079ec:	83 e0 01             	and    $0x1,%eax
801079ef:	85 c0                	test   %eax,%eax
801079f1:	74 0d                	je     80107a00 <mappages+0x60>
      panic("remap");
801079f3:	83 ec 0c             	sub    $0xc,%esp
801079f6:	68 14 ad 10 80       	push   $0x8010ad14
801079fb:	e8 a9 8b ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107a00:	8b 45 18             	mov    0x18(%ebp),%eax
80107a03:	0b 45 14             	or     0x14(%ebp),%eax
80107a06:	83 c8 01             	or     $0x1,%eax
80107a09:	89 c2                	mov    %eax,%edx
80107a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a0e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a13:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a16:	74 10                	je     80107a28 <mappages+0x88>
      break;
    a += PGSIZE;
80107a18:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107a1f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a26:	eb 9c                	jmp    801079c4 <mappages+0x24>
      break;
80107a28:	90                   	nop
  }
  return 0;
80107a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a2e:	c9                   	leave  
80107a2f:	c3                   	ret    

80107a30 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107a30:	55                   	push   %ebp
80107a31:	89 e5                	mov    %esp,%ebp
80107a33:	53                   	push   %ebx
80107a34:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107a37:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107a3e:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
80107a44:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107a49:	29 d0                	sub    %edx,%eax
80107a4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a4e:	a1 88 9c 11 80       	mov    0x80119c88,%eax
80107a53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a56:	8b 15 88 9c 11 80    	mov    0x80119c88,%edx
80107a5c:	a1 90 9c 11 80       	mov    0x80119c90,%eax
80107a61:	01 d0                	add    %edx,%eax
80107a63:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a66:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	83 c0 30             	add    $0x30,%eax
80107a73:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a76:	89 10                	mov    %edx,(%eax)
80107a78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a7b:	89 50 04             	mov    %edx,0x4(%eax)
80107a7e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a81:	89 50 08             	mov    %edx,0x8(%eax)
80107a84:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107a87:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107a8a:	e8 eb b1 ff ff       	call   80102c7a <kalloc>
80107a8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a96:	75 07                	jne    80107a9f <setupkvm+0x6f>
    return 0;
80107a98:	b8 00 00 00 00       	mov    $0x0,%eax
80107a9d:	eb 78                	jmp    80107b17 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107a9f:	83 ec 04             	sub    $0x4,%esp
80107aa2:	68 00 10 00 00       	push   $0x1000
80107aa7:	6a 00                	push   $0x0
80107aa9:	ff 75 f0             	push   -0x10(%ebp)
80107aac:	e8 ec d4 ff ff       	call   80104f9d <memset>
80107ab1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ab4:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107abb:	eb 4e                	jmp    80107b0b <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac6:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acc:	8b 58 08             	mov    0x8(%eax),%ebx
80107acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad2:	8b 40 04             	mov    0x4(%eax),%eax
80107ad5:	29 c3                	sub    %eax,%ebx
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	8b 00                	mov    (%eax),%eax
80107adc:	83 ec 0c             	sub    $0xc,%esp
80107adf:	51                   	push   %ecx
80107ae0:	52                   	push   %edx
80107ae1:	53                   	push   %ebx
80107ae2:	50                   	push   %eax
80107ae3:	ff 75 f0             	push   -0x10(%ebp)
80107ae6:	e8 b5 fe ff ff       	call   801079a0 <mappages>
80107aeb:	83 c4 20             	add    $0x20,%esp
80107aee:	85 c0                	test   %eax,%eax
80107af0:	79 15                	jns    80107b07 <setupkvm+0xd7>
      freevm(pgdir);
80107af2:	83 ec 0c             	sub    $0xc,%esp
80107af5:	ff 75 f0             	push   -0x10(%ebp)
80107af8:	e8 f5 04 00 00       	call   80107ff2 <freevm>
80107afd:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b00:	b8 00 00 00 00       	mov    $0x0,%eax
80107b05:	eb 10                	jmp    80107b17 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b07:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b0b:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107b12:	72 a9                	jb     80107abd <setupkvm+0x8d>
    }
  return pgdir;
80107b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b1a:	c9                   	leave  
80107b1b:	c3                   	ret    

80107b1c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b1c:	55                   	push   %ebp
80107b1d:	89 e5                	mov    %esp,%ebp
80107b1f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107b22:	e8 09 ff ff ff       	call   80107a30 <setupkvm>
80107b27:	a3 bc 99 11 80       	mov    %eax,0x801199bc
  switchkvm();
80107b2c:	e8 03 00 00 00       	call   80107b34 <switchkvm>
}
80107b31:	90                   	nop
80107b32:	c9                   	leave  
80107b33:	c3                   	ret    

80107b34 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b34:	55                   	push   %ebp
80107b35:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107b37:	a1 bc 99 11 80       	mov    0x801199bc,%eax
80107b3c:	05 00 00 00 80       	add    $0x80000000,%eax
80107b41:	50                   	push   %eax
80107b42:	e8 61 fa ff ff       	call   801075a8 <lcr3>
80107b47:	83 c4 04             	add    $0x4,%esp
}
80107b4a:	90                   	nop
80107b4b:	c9                   	leave  
80107b4c:	c3                   	ret    

80107b4d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107b4d:	55                   	push   %ebp
80107b4e:	89 e5                	mov    %esp,%ebp
80107b50:	56                   	push   %esi
80107b51:	53                   	push   %ebx
80107b52:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b59:	75 0d                	jne    80107b68 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107b5b:	83 ec 0c             	sub    $0xc,%esp
80107b5e:	68 1a ad 10 80       	push   $0x8010ad1a
80107b63:	e8 41 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107b68:	8b 45 08             	mov    0x8(%ebp),%eax
80107b6b:	8b 40 08             	mov    0x8(%eax),%eax
80107b6e:	85 c0                	test   %eax,%eax
80107b70:	75 0d                	jne    80107b7f <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107b72:	83 ec 0c             	sub    $0xc,%esp
80107b75:	68 30 ad 10 80       	push   $0x8010ad30
80107b7a:	e8 2a 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b82:	8b 40 04             	mov    0x4(%eax),%eax
80107b85:	85 c0                	test   %eax,%eax
80107b87:	75 0d                	jne    80107b96 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107b89:	83 ec 0c             	sub    $0xc,%esp
80107b8c:	68 45 ad 10 80       	push   $0x8010ad45
80107b91:	e8 13 8a ff ff       	call   801005a9 <panic>

  pushcli();
80107b96:	e8 f7 d2 ff ff       	call   80104e92 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b9b:	e8 f2 c2 ff ff       	call   80103e92 <mycpu>
80107ba0:	89 c3                	mov    %eax,%ebx
80107ba2:	e8 eb c2 ff ff       	call   80103e92 <mycpu>
80107ba7:	83 c0 08             	add    $0x8,%eax
80107baa:	89 c6                	mov    %eax,%esi
80107bac:	e8 e1 c2 ff ff       	call   80103e92 <mycpu>
80107bb1:	83 c0 08             	add    $0x8,%eax
80107bb4:	c1 e8 10             	shr    $0x10,%eax
80107bb7:	88 45 f7             	mov    %al,-0x9(%ebp)
80107bba:	e8 d3 c2 ff ff       	call   80103e92 <mycpu>
80107bbf:	83 c0 08             	add    $0x8,%eax
80107bc2:	c1 e8 18             	shr    $0x18,%eax
80107bc5:	89 c2                	mov    %eax,%edx
80107bc7:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107bce:	67 00 
80107bd0:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107bd7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107bdb:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107be1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107be8:	83 e0 f0             	and    $0xfffffff0,%eax
80107beb:	83 c8 09             	or     $0x9,%eax
80107bee:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bf4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bfb:	83 c8 10             	or     $0x10,%eax
80107bfe:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c04:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c0b:	83 e0 9f             	and    $0xffffff9f,%eax
80107c0e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c14:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c1b:	83 c8 80             	or     $0xffffff80,%eax
80107c1e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c24:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c2b:	83 e0 f0             	and    $0xfffffff0,%eax
80107c2e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c34:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c3b:	83 e0 ef             	and    $0xffffffef,%eax
80107c3e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c44:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c4b:	83 e0 df             	and    $0xffffffdf,%eax
80107c4e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c54:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c5b:	83 c8 40             	or     $0x40,%eax
80107c5e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c64:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c6b:	83 e0 7f             	and    $0x7f,%eax
80107c6e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c74:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107c7a:	e8 13 c2 ff ff       	call   80103e92 <mycpu>
80107c7f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c86:	83 e2 ef             	and    $0xffffffef,%edx
80107c89:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c8f:	e8 fe c1 ff ff       	call   80103e92 <mycpu>
80107c94:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107c9d:	8b 40 08             	mov    0x8(%eax),%eax
80107ca0:	89 c3                	mov    %eax,%ebx
80107ca2:	e8 eb c1 ff ff       	call   80103e92 <mycpu>
80107ca7:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107cad:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107cb0:	e8 dd c1 ff ff       	call   80103e92 <mycpu>
80107cb5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107cbb:	83 ec 0c             	sub    $0xc,%esp
80107cbe:	6a 28                	push   $0x28
80107cc0:	e8 cc f8 ff ff       	call   80107591 <ltr>
80107cc5:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107ccb:	8b 40 04             	mov    0x4(%eax),%eax
80107cce:	05 00 00 00 80       	add    $0x80000000,%eax
80107cd3:	83 ec 0c             	sub    $0xc,%esp
80107cd6:	50                   	push   %eax
80107cd7:	e8 cc f8 ff ff       	call   801075a8 <lcr3>
80107cdc:	83 c4 10             	add    $0x10,%esp
  popcli();
80107cdf:	e8 fb d1 ff ff       	call   80104edf <popcli>
}
80107ce4:	90                   	nop
80107ce5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ce8:	5b                   	pop    %ebx
80107ce9:	5e                   	pop    %esi
80107cea:	5d                   	pop    %ebp
80107ceb:	c3                   	ret    

80107cec <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107cec:	55                   	push   %ebp
80107ced:	89 e5                	mov    %esp,%ebp
80107cef:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107cf2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107cf9:	76 0d                	jbe    80107d08 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107cfb:	83 ec 0c             	sub    $0xc,%esp
80107cfe:	68 59 ad 10 80       	push   $0x8010ad59
80107d03:	e8 a1 88 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107d08:	e8 6d af ff ff       	call   80102c7a <kalloc>
80107d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107d10:	83 ec 04             	sub    $0x4,%esp
80107d13:	68 00 10 00 00       	push   $0x1000
80107d18:	6a 00                	push   $0x0
80107d1a:	ff 75 f4             	push   -0xc(%ebp)
80107d1d:	e8 7b d2 ff ff       	call   80104f9d <memset>
80107d22:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d28:	05 00 00 00 80       	add    $0x80000000,%eax
80107d2d:	83 ec 0c             	sub    $0xc,%esp
80107d30:	6a 06                	push   $0x6
80107d32:	50                   	push   %eax
80107d33:	68 00 10 00 00       	push   $0x1000
80107d38:	6a 00                	push   $0x0
80107d3a:	ff 75 08             	push   0x8(%ebp)
80107d3d:	e8 5e fc ff ff       	call   801079a0 <mappages>
80107d42:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107d45:	83 ec 04             	sub    $0x4,%esp
80107d48:	ff 75 10             	push   0x10(%ebp)
80107d4b:	ff 75 0c             	push   0xc(%ebp)
80107d4e:	ff 75 f4             	push   -0xc(%ebp)
80107d51:	e8 06 d3 ff ff       	call   8010505c <memmove>
80107d56:	83 c4 10             	add    $0x10,%esp
}
80107d59:	90                   	nop
80107d5a:	c9                   	leave  
80107d5b:	c3                   	ret    

80107d5c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d5c:	55                   	push   %ebp
80107d5d:	89 e5                	mov    %esp,%ebp
80107d5f:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d65:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d6a:	85 c0                	test   %eax,%eax
80107d6c:	74 0d                	je     80107d7b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107d6e:	83 ec 0c             	sub    $0xc,%esp
80107d71:	68 74 ad 10 80       	push   $0x8010ad74
80107d76:	e8 2e 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107d7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d82:	e9 8f 00 00 00       	jmp    80107e16 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d87:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8d:	01 d0                	add    %edx,%eax
80107d8f:	83 ec 04             	sub    $0x4,%esp
80107d92:	6a 00                	push   $0x0
80107d94:	50                   	push   %eax
80107d95:	ff 75 08             	push   0x8(%ebp)
80107d98:	e8 6d fb ff ff       	call   8010790a <walkpgdir>
80107d9d:	83 c4 10             	add    $0x10,%esp
80107da0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107da3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107da7:	75 0d                	jne    80107db6 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107da9:	83 ec 0c             	sub    $0xc,%esp
80107dac:	68 97 ad 10 80       	push   $0x8010ad97
80107db1:	e8 f3 87 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107db6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107db9:	8b 00                	mov    (%eax),%eax
80107dbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107dc3:	8b 45 18             	mov    0x18(%ebp),%eax
80107dc6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107dc9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107dce:	77 0b                	ja     80107ddb <loaduvm+0x7f>
      n = sz - i;
80107dd0:	8b 45 18             	mov    0x18(%ebp),%eax
80107dd3:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107dd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107dd9:	eb 07                	jmp    80107de2 <loaduvm+0x86>
    else
      n = PGSIZE;
80107ddb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107de2:	8b 55 14             	mov    0x14(%ebp),%edx
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	01 d0                	add    %edx,%eax
80107dea:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ded:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107df3:	ff 75 f0             	push   -0x10(%ebp)
80107df6:	50                   	push   %eax
80107df7:	52                   	push   %edx
80107df8:	ff 75 10             	push   0x10(%ebp)
80107dfb:	e8 cc a0 ff ff       	call   80101ecc <readi>
80107e00:	83 c4 10             	add    $0x10,%esp
80107e03:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e06:	74 07                	je     80107e0f <loaduvm+0xb3>
      return -1;
80107e08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e0d:	eb 18                	jmp    80107e27 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107e0f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	3b 45 18             	cmp    0x18(%ebp),%eax
80107e1c:	0f 82 65 ff ff ff    	jb     80107d87 <loaduvm+0x2b>
  }
  return 0;
80107e22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e27:	c9                   	leave  
80107e28:	c3                   	ret    

80107e29 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e29:	55                   	push   %ebp
80107e2a:	89 e5                	mov    %esp,%ebp
80107e2c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107e2f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e32:	85 c0                	test   %eax,%eax
80107e34:	79 0a                	jns    80107e40 <allocuvm+0x17>
    return 0;
80107e36:	b8 00 00 00 00       	mov    $0x0,%eax
80107e3b:	e9 ec 00 00 00       	jmp    80107f2c <allocuvm+0x103>
  if(newsz < oldsz)
80107e40:	8b 45 10             	mov    0x10(%ebp),%eax
80107e43:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e46:	73 08                	jae    80107e50 <allocuvm+0x27>
    return oldsz;
80107e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e4b:	e9 dc 00 00 00       	jmp    80107f2c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e53:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107e60:	e9 b8 00 00 00       	jmp    80107f1d <allocuvm+0xf4>
    mem = kalloc();
80107e65:	e8 10 ae ff ff       	call   80102c7a <kalloc>
80107e6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e71:	75 2e                	jne    80107ea1 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107e73:	83 ec 0c             	sub    $0xc,%esp
80107e76:	68 b5 ad 10 80       	push   $0x8010adb5
80107e7b:	e8 74 85 ff ff       	call   801003f4 <cprintf>
80107e80:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e83:	83 ec 04             	sub    $0x4,%esp
80107e86:	ff 75 0c             	push   0xc(%ebp)
80107e89:	ff 75 10             	push   0x10(%ebp)
80107e8c:	ff 75 08             	push   0x8(%ebp)
80107e8f:	e8 9a 00 00 00       	call   80107f2e <deallocuvm>
80107e94:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e97:	b8 00 00 00 00       	mov    $0x0,%eax
80107e9c:	e9 8b 00 00 00       	jmp    80107f2c <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107ea1:	83 ec 04             	sub    $0x4,%esp
80107ea4:	68 00 10 00 00       	push   $0x1000
80107ea9:	6a 00                	push   $0x0
80107eab:	ff 75 f0             	push   -0x10(%ebp)
80107eae:	e8 ea d0 ff ff       	call   80104f9d <memset>
80107eb3:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	83 ec 0c             	sub    $0xc,%esp
80107ec5:	6a 06                	push   $0x6
80107ec7:	52                   	push   %edx
80107ec8:	68 00 10 00 00       	push   $0x1000
80107ecd:	50                   	push   %eax
80107ece:	ff 75 08             	push   0x8(%ebp)
80107ed1:	e8 ca fa ff ff       	call   801079a0 <mappages>
80107ed6:	83 c4 20             	add    $0x20,%esp
80107ed9:	85 c0                	test   %eax,%eax
80107edb:	79 39                	jns    80107f16 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107edd:	83 ec 0c             	sub    $0xc,%esp
80107ee0:	68 cd ad 10 80       	push   $0x8010adcd
80107ee5:	e8 0a 85 ff ff       	call   801003f4 <cprintf>
80107eea:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107eed:	83 ec 04             	sub    $0x4,%esp
80107ef0:	ff 75 0c             	push   0xc(%ebp)
80107ef3:	ff 75 10             	push   0x10(%ebp)
80107ef6:	ff 75 08             	push   0x8(%ebp)
80107ef9:	e8 30 00 00 00       	call   80107f2e <deallocuvm>
80107efe:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107f01:	83 ec 0c             	sub    $0xc,%esp
80107f04:	ff 75 f0             	push   -0x10(%ebp)
80107f07:	e8 d4 ac ff ff       	call   80102be0 <kfree>
80107f0c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f0f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f14:	eb 16                	jmp    80107f2c <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107f16:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f23:	0f 82 3c ff ff ff    	jb     80107e65 <allocuvm+0x3c>
    }
  }
  return newsz;
80107f29:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f2c:	c9                   	leave  
80107f2d:	c3                   	ret    

80107f2e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f2e:	55                   	push   %ebp
80107f2f:	89 e5                	mov    %esp,%ebp
80107f31:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107f34:	8b 45 10             	mov    0x10(%ebp),%eax
80107f37:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f3a:	72 08                	jb     80107f44 <deallocuvm+0x16>
    return oldsz;
80107f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f3f:	e9 ac 00 00 00       	jmp    80107ff0 <deallocuvm+0xc2>
  a = PGROUNDUP(newsz);
80107f44:	8b 45 10             	mov    0x10(%ebp),%eax
80107f47:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f51:	89 45 f4             	mov    %eax,-0xc(%ebp)

  for(; a  < oldsz; a += PGSIZE){
80107f54:	e9 88 00 00 00       	jmp    80107fe1 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	83 ec 04             	sub    $0x4,%esp
80107f5f:	6a 00                	push   $0x0
80107f61:	50                   	push   %eax
80107f62:	ff 75 08             	push   0x8(%ebp)
80107f65:	e8 a0 f9 ff ff       	call   8010790a <walkpgdir>
80107f6a:	83 c4 10             	add    $0x10,%esp
80107f6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f74:	75 16                	jne    80107f8c <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f79:	c1 e8 16             	shr    $0x16,%eax
80107f7c:	83 c0 01             	add    $0x1,%eax
80107f7f:	c1 e0 16             	shl    $0x16,%eax
80107f82:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f8a:	eb 4e                	jmp    80107fda <deallocuvm+0xac>
    else{
      if(*pte & PTE_P){
80107f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8f:	8b 00                	mov    (%eax),%eax
80107f91:	83 e0 01             	and    $0x1,%eax
80107f94:	85 c0                	test   %eax,%eax
80107f96:	74 39                	je     80107fd1 <deallocuvm+0xa3>
        pa = PTE_ADDR(*pte);
80107f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9b:	8b 00                	mov    (%eax),%eax
80107f9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (pa ==0)
80107fa5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fa9:	75 0d                	jne    80107fb8 <deallocuvm+0x8a>
          panic("kfree");
80107fab:	83 ec 0c             	sub    $0xc,%esp
80107fae:	68 e9 ad 10 80       	push   $0x8010ade9
80107fb3:	e8 f1 85 ff ff       	call   801005a9 <panic>
        char *v = P2V(pa);
80107fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fbb:	05 00 00 00 80       	add    $0x80000000,%eax
80107fc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(v);
80107fc3:	83 ec 0c             	sub    $0xc,%esp
80107fc6:	ff 75 e8             	push   -0x18(%ebp)
80107fc9:	e8 12 ac ff ff       	call   80102be0 <kfree>
80107fce:	83 c4 10             	add    $0x10,%esp
      }
      *pte = 0;
80107fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107fda:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fe7:	0f 82 6c ff ff ff    	jb     80107f59 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107fed:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ff0:	c9                   	leave  
80107ff1:	c3                   	ret    

80107ff2 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ff2:	55                   	push   %ebp
80107ff3:	89 e5                	mov    %esp,%ebp
80107ff5:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107ff8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ffc:	75 0d                	jne    8010800b <freevm+0x19>
    panic("freevm: no pgdir");
80107ffe:	83 ec 0c             	sub    $0xc,%esp
80108001:	68 ef ad 10 80       	push   $0x8010adef
80108006:	e8 9e 85 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010800b:	83 ec 04             	sub    $0x4,%esp
8010800e:	6a 00                	push   $0x0
80108010:	68 00 00 00 80       	push   $0x80000000
80108015:	ff 75 08             	push   0x8(%ebp)
80108018:	e8 11 ff ff ff       	call   80107f2e <deallocuvm>
8010801d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108020:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108027:	eb 48                	jmp    80108071 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108033:	8b 45 08             	mov    0x8(%ebp),%eax
80108036:	01 d0                	add    %edx,%eax
80108038:	8b 00                	mov    (%eax),%eax
8010803a:	83 e0 01             	and    $0x1,%eax
8010803d:	85 c0                	test   %eax,%eax
8010803f:	74 2c                	je     8010806d <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108044:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010804b:	8b 45 08             	mov    0x8(%ebp),%eax
8010804e:	01 d0                	add    %edx,%eax
80108050:	8b 00                	mov    (%eax),%eax
80108052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108057:	05 00 00 00 80       	add    $0x80000000,%eax
8010805c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010805f:	83 ec 0c             	sub    $0xc,%esp
80108062:	ff 75 f0             	push   -0x10(%ebp)
80108065:	e8 76 ab ff ff       	call   80102be0 <kfree>
8010806a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010806d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108071:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108078:	76 af                	jbe    80108029 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010807a:	83 ec 0c             	sub    $0xc,%esp
8010807d:	ff 75 08             	push   0x8(%ebp)
80108080:	e8 5b ab ff ff       	call   80102be0 <kfree>
80108085:	83 c4 10             	add    $0x10,%esp
}
80108088:	90                   	nop
80108089:	c9                   	leave  
8010808a:	c3                   	ret    

8010808b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010808b:	55                   	push   %ebp
8010808c:	89 e5                	mov    %esp,%ebp
8010808e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108091:	83 ec 04             	sub    $0x4,%esp
80108094:	6a 00                	push   $0x0
80108096:	ff 75 0c             	push   0xc(%ebp)
80108099:	ff 75 08             	push   0x8(%ebp)
8010809c:	e8 69 f8 ff ff       	call   8010790a <walkpgdir>
801080a1:	83 c4 10             	add    $0x10,%esp
801080a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801080a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080ab:	75 0d                	jne    801080ba <clearpteu+0x2f>
    panic("clearpteu");
801080ad:	83 ec 0c             	sub    $0xc,%esp
801080b0:	68 00 ae 10 80       	push   $0x8010ae00
801080b5:	e8 ef 84 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801080ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bd:	8b 00                	mov    (%eax),%eax
801080bf:	83 e0 fb             	and    $0xfffffffb,%eax
801080c2:	89 c2                	mov    %eax,%edx
801080c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c7:	89 10                	mov    %edx,(%eax)
}
801080c9:	90                   	nop
801080ca:	c9                   	leave  
801080cb:	c3                   	ret    

801080cc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801080cc:	55                   	push   %ebp
801080cd:	89 e5                	mov    %esp,%ebp
801080cf:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801080d2:	e8 59 f9 ff ff       	call   80107a30 <setupkvm>
801080d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080de:	75 0a                	jne    801080ea <copyuvm+0x1e>
    return 0;
801080e0:	b8 00 00 00 00       	mov    $0x0,%eax
801080e5:	e9 06 01 00 00       	jmp    801081f0 <copyuvm+0x124>
    
  for(i = 0; i < KERNBASE; i += PGSIZE){
801080ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080f1:	e9 d0 00 00 00       	jmp    801081c6 <copyuvm+0xfa>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
801080f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f9:	83 ec 04             	sub    $0x4,%esp
801080fc:	6a 00                	push   $0x0
801080fe:	50                   	push   %eax
801080ff:	ff 75 08             	push   0x8(%ebp)
80108102:	e8 03 f8 ff ff       	call   8010790a <walkpgdir>
80108107:	83 c4 10             	add    $0x10,%esp
8010810a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010810d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108111:	0f 84 a7 00 00 00    	je     801081be <copyuvm+0xf2>
      continue;
    }
    if(!(*pte & PTE_P)){
80108117:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010811a:	8b 00                	mov    (%eax),%eax
8010811c:	83 e0 01             	and    $0x1,%eax
8010811f:	85 c0                	test   %eax,%eax
80108121:	75 2c                	jne    8010814f <copyuvm+0x83>
      pte_t *child_pte = walkpgdir(d , (void *)i, 1);
80108123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108126:	83 ec 04             	sub    $0x4,%esp
80108129:	6a 01                	push   $0x1
8010812b:	50                   	push   %eax
8010812c:	ff 75 f0             	push   -0x10(%ebp)
8010812f:	e8 d6 f7 ff ff       	call   8010790a <walkpgdir>
80108134:	83 c4 10             	add    $0x10,%esp
80108137:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if (child_pte ==0)
8010813a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010813e:	0f 84 92 00 00 00    	je     801081d6 <copyuvm+0x10a>
        goto bad;
      *child_pte = 0;
80108144:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108147:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      continue;
8010814d:	eb 70                	jmp    801081bf <copyuvm+0xf3>
    }
    pa = PTE_ADDR(*pte);
8010814f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108152:	8b 00                	mov    (%eax),%eax
80108154:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108159:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010815c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010815f:	8b 00                	mov    (%eax),%eax
80108161:	25 ff 0f 00 00       	and    $0xfff,%eax
80108166:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108169:	e8 0c ab ff ff       	call   80102c7a <kalloc>
8010816e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108171:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108175:	74 62                	je     801081d9 <copyuvm+0x10d>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108177:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010817a:	05 00 00 00 80       	add    $0x80000000,%eax
8010817f:	83 ec 04             	sub    $0x4,%esp
80108182:	68 00 10 00 00       	push   $0x1000
80108187:	50                   	push   %eax
80108188:	ff 75 e0             	push   -0x20(%ebp)
8010818b:	e8 cc ce ff ff       	call   8010505c <memmove>
80108190:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108193:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108196:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108199:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010819f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	52                   	push   %edx
801081a6:	51                   	push   %ecx
801081a7:	68 00 10 00 00       	push   $0x1000
801081ac:	50                   	push   %eax
801081ad:	ff 75 f0             	push   -0x10(%ebp)
801081b0:	e8 eb f7 ff ff       	call   801079a0 <mappages>
801081b5:	83 c4 20             	add    $0x20,%esp
801081b8:	85 c0                	test   %eax,%eax
801081ba:	78 20                	js     801081dc <copyuvm+0x110>
801081bc:	eb 01                	jmp    801081bf <copyuvm+0xf3>
      continue;
801081be:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
801081bf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c9:	85 c0                	test   %eax,%eax
801081cb:	0f 89 25 ff ff ff    	jns    801080f6 <copyuvm+0x2a>
      goto bad;
  }
  return d;
801081d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d4:	eb 1a                	jmp    801081f0 <copyuvm+0x124>
        goto bad;
801081d6:	90                   	nop
801081d7:	eb 04                	jmp    801081dd <copyuvm+0x111>
      goto bad;
801081d9:	90                   	nop
801081da:	eb 01                	jmp    801081dd <copyuvm+0x111>
      goto bad;
801081dc:	90                   	nop

bad:
  freevm(d);
801081dd:	83 ec 0c             	sub    $0xc,%esp
801081e0:	ff 75 f0             	push   -0x10(%ebp)
801081e3:	e8 0a fe ff ff       	call   80107ff2 <freevm>
801081e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801081eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081f0:	c9                   	leave  
801081f1:	c3                   	ret    

801081f2 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801081f2:	55                   	push   %ebp
801081f3:	89 e5                	mov    %esp,%ebp
801081f5:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081f8:	83 ec 04             	sub    $0x4,%esp
801081fb:	6a 00                	push   $0x0
801081fd:	ff 75 0c             	push   0xc(%ebp)
80108200:	ff 75 08             	push   0x8(%ebp)
80108203:	e8 02 f7 ff ff       	call   8010790a <walkpgdir>
80108208:	83 c4 10             	add    $0x10,%esp
8010820b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010820e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108211:	8b 00                	mov    (%eax),%eax
80108213:	83 e0 01             	and    $0x1,%eax
80108216:	85 c0                	test   %eax,%eax
80108218:	75 07                	jne    80108221 <uva2ka+0x2f>
    return 0;
8010821a:	b8 00 00 00 00       	mov    $0x0,%eax
8010821f:	eb 22                	jmp    80108243 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108224:	8b 00                	mov    (%eax),%eax
80108226:	83 e0 04             	and    $0x4,%eax
80108229:	85 c0                	test   %eax,%eax
8010822b:	75 07                	jne    80108234 <uva2ka+0x42>
    return 0;
8010822d:	b8 00 00 00 00       	mov    $0x0,%eax
80108232:	eb 0f                	jmp    80108243 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8b 00                	mov    (%eax),%eax
80108239:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010823e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108243:	c9                   	leave  
80108244:	c3                   	ret    

80108245 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108245:	55                   	push   %ebp
80108246:	89 e5                	mov    %esp,%ebp
80108248:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010824b:	8b 45 10             	mov    0x10(%ebp),%eax
8010824e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108251:	eb 7f                	jmp    801082d2 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108253:	8b 45 0c             	mov    0xc(%ebp),%eax
80108256:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010825b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010825e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108261:	83 ec 08             	sub    $0x8,%esp
80108264:	50                   	push   %eax
80108265:	ff 75 08             	push   0x8(%ebp)
80108268:	e8 85 ff ff ff       	call   801081f2 <uva2ka>
8010826d:	83 c4 10             	add    $0x10,%esp
80108270:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108273:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108277:	75 07                	jne    80108280 <copyout+0x3b>
      return -1;
80108279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010827e:	eb 61                	jmp    801082e1 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108280:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108283:	2b 45 0c             	sub    0xc(%ebp),%eax
80108286:	05 00 10 00 00       	add    $0x1000,%eax
8010828b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010828e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108291:	3b 45 14             	cmp    0x14(%ebp),%eax
80108294:	76 06                	jbe    8010829c <copyout+0x57>
      n = len;
80108296:	8b 45 14             	mov    0x14(%ebp),%eax
80108299:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010829c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010829f:	2b 45 ec             	sub    -0x14(%ebp),%eax
801082a2:	89 c2                	mov    %eax,%edx
801082a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082a7:	01 d0                	add    %edx,%eax
801082a9:	83 ec 04             	sub    $0x4,%esp
801082ac:	ff 75 f0             	push   -0x10(%ebp)
801082af:	ff 75 f4             	push   -0xc(%ebp)
801082b2:	50                   	push   %eax
801082b3:	e8 a4 cd ff ff       	call   8010505c <memmove>
801082b8:	83 c4 10             	add    $0x10,%esp
    len -= n;
801082bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082be:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801082c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801082c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ca:	05 00 10 00 00       	add    $0x1000,%eax
801082cf:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801082d2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801082d6:	0f 85 77 ff ff ff    	jne    80108253 <copyout+0xe>
  }
  return 0;
801082dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082e1:	c9                   	leave  
801082e2:	c3                   	ret    

801082e3 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801082e3:	55                   	push   %ebp
801082e4:	89 e5                	mov    %esp,%ebp
801082e6:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082e9:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801082f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082f3:	8b 40 08             	mov    0x8(%eax),%eax
801082f6:	05 00 00 00 80       	add    $0x80000000,%eax
801082fb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801082fe:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108308:	8b 40 24             	mov    0x24(%eax),%eax
8010830b:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108310:	c7 05 80 9c 11 80 00 	movl   $0x0,0x80119c80
80108317:	00 00 00 

  while(i<madt->len){
8010831a:	90                   	nop
8010831b:	e9 bd 00 00 00       	jmp    801083dd <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108320:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108323:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108326:	01 d0                	add    %edx,%eax
80108328:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010832b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010832e:	0f b6 00             	movzbl (%eax),%eax
80108331:	0f b6 c0             	movzbl %al,%eax
80108334:	83 f8 05             	cmp    $0x5,%eax
80108337:	0f 87 a0 00 00 00    	ja     801083dd <mpinit_uefi+0xfa>
8010833d:	8b 04 85 0c ae 10 80 	mov    -0x7fef51f4(,%eax,4),%eax
80108344:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108349:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010834c:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80108351:	83 f8 03             	cmp    $0x3,%eax
80108354:	7f 28                	jg     8010837e <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108356:	8b 15 80 9c 11 80    	mov    0x80119c80,%edx
8010835c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010835f:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108363:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108369:	81 c2 c0 99 11 80    	add    $0x801199c0,%edx
8010836f:	88 02                	mov    %al,(%edx)
          ncpu++;
80108371:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80108376:	83 c0 01             	add    $0x1,%eax
80108379:	a3 80 9c 11 80       	mov    %eax,0x80119c80
        }
        i += lapic_entry->record_len;
8010837e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108381:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108385:	0f b6 c0             	movzbl %al,%eax
80108388:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010838b:	eb 50                	jmp    801083dd <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010838d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108396:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010839a:	a2 84 9c 11 80       	mov    %al,0x80119c84
        i += ioapic->record_len;
8010839f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801083a2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083a6:	0f b6 c0             	movzbl %al,%eax
801083a9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083ac:	eb 2f                	jmp    801083dd <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801083ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801083b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083b7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083bb:	0f b6 c0             	movzbl %al,%eax
801083be:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083c1:	eb 1a                	jmp    801083dd <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801083c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801083c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083cc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083d0:	0f b6 c0             	movzbl %al,%eax
801083d3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083d6:	eb 05                	jmp    801083dd <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801083d8:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801083dc:	90                   	nop
  while(i<madt->len){
801083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e0:	8b 40 04             	mov    0x4(%eax),%eax
801083e3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801083e6:	0f 82 34 ff ff ff    	jb     80108320 <mpinit_uefi+0x3d>
    }
  }

}
801083ec:	90                   	nop
801083ed:	90                   	nop
801083ee:	c9                   	leave  
801083ef:	c3                   	ret    

801083f0 <inb>:
{
801083f0:	55                   	push   %ebp
801083f1:	89 e5                	mov    %esp,%ebp
801083f3:	83 ec 14             	sub    $0x14,%esp
801083f6:	8b 45 08             	mov    0x8(%ebp),%eax
801083f9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801083fd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108401:	89 c2                	mov    %eax,%edx
80108403:	ec                   	in     (%dx),%al
80108404:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108407:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010840b:	c9                   	leave  
8010840c:	c3                   	ret    

8010840d <outb>:
{
8010840d:	55                   	push   %ebp
8010840e:	89 e5                	mov    %esp,%ebp
80108410:	83 ec 08             	sub    $0x8,%esp
80108413:	8b 45 08             	mov    0x8(%ebp),%eax
80108416:	8b 55 0c             	mov    0xc(%ebp),%edx
80108419:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010841d:	89 d0                	mov    %edx,%eax
8010841f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108422:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108426:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010842a:	ee                   	out    %al,(%dx)
}
8010842b:	90                   	nop
8010842c:	c9                   	leave  
8010842d:	c3                   	ret    

8010842e <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010842e:	55                   	push   %ebp
8010842f:	89 e5                	mov    %esp,%ebp
80108431:	83 ec 28             	sub    $0x28,%esp
80108434:	8b 45 08             	mov    0x8(%ebp),%eax
80108437:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010843a:	6a 00                	push   $0x0
8010843c:	68 fa 03 00 00       	push   $0x3fa
80108441:	e8 c7 ff ff ff       	call   8010840d <outb>
80108446:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108449:	68 80 00 00 00       	push   $0x80
8010844e:	68 fb 03 00 00       	push   $0x3fb
80108453:	e8 b5 ff ff ff       	call   8010840d <outb>
80108458:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010845b:	6a 0c                	push   $0xc
8010845d:	68 f8 03 00 00       	push   $0x3f8
80108462:	e8 a6 ff ff ff       	call   8010840d <outb>
80108467:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010846a:	6a 00                	push   $0x0
8010846c:	68 f9 03 00 00       	push   $0x3f9
80108471:	e8 97 ff ff ff       	call   8010840d <outb>
80108476:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108479:	6a 03                	push   $0x3
8010847b:	68 fb 03 00 00       	push   $0x3fb
80108480:	e8 88 ff ff ff       	call   8010840d <outb>
80108485:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108488:	6a 00                	push   $0x0
8010848a:	68 fc 03 00 00       	push   $0x3fc
8010848f:	e8 79 ff ff ff       	call   8010840d <outb>
80108494:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010849e:	eb 11                	jmp    801084b1 <uart_debug+0x83>
801084a0:	83 ec 0c             	sub    $0xc,%esp
801084a3:	6a 0a                	push   $0xa
801084a5:	e8 67 ab ff ff       	call   80103011 <microdelay>
801084aa:	83 c4 10             	add    $0x10,%esp
801084ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084b1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801084b5:	7f 1a                	jg     801084d1 <uart_debug+0xa3>
801084b7:	83 ec 0c             	sub    $0xc,%esp
801084ba:	68 fd 03 00 00       	push   $0x3fd
801084bf:	e8 2c ff ff ff       	call   801083f0 <inb>
801084c4:	83 c4 10             	add    $0x10,%esp
801084c7:	0f b6 c0             	movzbl %al,%eax
801084ca:	83 e0 20             	and    $0x20,%eax
801084cd:	85 c0                	test   %eax,%eax
801084cf:	74 cf                	je     801084a0 <uart_debug+0x72>
  outb(COM1+0, p);
801084d1:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801084d5:	0f b6 c0             	movzbl %al,%eax
801084d8:	83 ec 08             	sub    $0x8,%esp
801084db:	50                   	push   %eax
801084dc:	68 f8 03 00 00       	push   $0x3f8
801084e1:	e8 27 ff ff ff       	call   8010840d <outb>
801084e6:	83 c4 10             	add    $0x10,%esp
}
801084e9:	90                   	nop
801084ea:	c9                   	leave  
801084eb:	c3                   	ret    

801084ec <uart_debugs>:

void uart_debugs(char *p){
801084ec:	55                   	push   %ebp
801084ed:	89 e5                	mov    %esp,%ebp
801084ef:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801084f2:	eb 1b                	jmp    8010850f <uart_debugs+0x23>
    uart_debug(*p++);
801084f4:	8b 45 08             	mov    0x8(%ebp),%eax
801084f7:	8d 50 01             	lea    0x1(%eax),%edx
801084fa:	89 55 08             	mov    %edx,0x8(%ebp)
801084fd:	0f b6 00             	movzbl (%eax),%eax
80108500:	0f be c0             	movsbl %al,%eax
80108503:	83 ec 0c             	sub    $0xc,%esp
80108506:	50                   	push   %eax
80108507:	e8 22 ff ff ff       	call   8010842e <uart_debug>
8010850c:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010850f:	8b 45 08             	mov    0x8(%ebp),%eax
80108512:	0f b6 00             	movzbl (%eax),%eax
80108515:	84 c0                	test   %al,%al
80108517:	75 db                	jne    801084f4 <uart_debugs+0x8>
  }
}
80108519:	90                   	nop
8010851a:	90                   	nop
8010851b:	c9                   	leave  
8010851c:	c3                   	ret    

8010851d <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010851d:	55                   	push   %ebp
8010851e:	89 e5                	mov    %esp,%ebp
80108520:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108523:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010852a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010852d:	8b 50 14             	mov    0x14(%eax),%edx
80108530:	8b 40 10             	mov    0x10(%eax),%eax
80108533:	a3 88 9c 11 80       	mov    %eax,0x80119c88
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108538:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010853b:	8b 50 1c             	mov    0x1c(%eax),%edx
8010853e:	8b 40 18             	mov    0x18(%eax),%eax
80108541:	a3 90 9c 11 80       	mov    %eax,0x80119c90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108546:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
8010854c:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108551:	29 d0                	sub    %edx,%eax
80108553:	a3 8c 9c 11 80       	mov    %eax,0x80119c8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108558:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010855b:	8b 50 24             	mov    0x24(%eax),%edx
8010855e:	8b 40 20             	mov    0x20(%eax),%eax
80108561:	a3 94 9c 11 80       	mov    %eax,0x80119c94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108566:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108569:	8b 50 2c             	mov    0x2c(%eax),%edx
8010856c:	8b 40 28             	mov    0x28(%eax),%eax
8010856f:	a3 98 9c 11 80       	mov    %eax,0x80119c98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108574:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108577:	8b 50 34             	mov    0x34(%eax),%edx
8010857a:	8b 40 30             	mov    0x30(%eax),%eax
8010857d:	a3 9c 9c 11 80       	mov    %eax,0x80119c9c
}
80108582:	90                   	nop
80108583:	c9                   	leave  
80108584:	c3                   	ret    

80108585 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108585:	55                   	push   %ebp
80108586:	89 e5                	mov    %esp,%ebp
80108588:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010858b:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
80108591:	8b 45 0c             	mov    0xc(%ebp),%eax
80108594:	0f af d0             	imul   %eax,%edx
80108597:	8b 45 08             	mov    0x8(%ebp),%eax
8010859a:	01 d0                	add    %edx,%eax
8010859c:	c1 e0 02             	shl    $0x2,%eax
8010859f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801085a2:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
801085a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085ab:	01 d0                	add    %edx,%eax
801085ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801085b0:	8b 45 10             	mov    0x10(%ebp),%eax
801085b3:	0f b6 10             	movzbl (%eax),%edx
801085b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085b9:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801085bb:	8b 45 10             	mov    0x10(%ebp),%eax
801085be:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801085c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085c5:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801085c8:	8b 45 10             	mov    0x10(%ebp),%eax
801085cb:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801085cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085d2:	88 50 02             	mov    %dl,0x2(%eax)
}
801085d5:	90                   	nop
801085d6:	c9                   	leave  
801085d7:	c3                   	ret    

801085d8 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801085d8:	55                   	push   %ebp
801085d9:	89 e5                	mov    %esp,%ebp
801085db:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801085de:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
801085e4:	8b 45 08             	mov    0x8(%ebp),%eax
801085e7:	0f af c2             	imul   %edx,%eax
801085ea:	c1 e0 02             	shl    $0x2,%eax
801085ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801085f0:	a1 90 9c 11 80       	mov    0x80119c90,%eax
801085f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085f8:	29 d0                	sub    %edx,%eax
801085fa:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
80108600:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108603:	01 ca                	add    %ecx,%edx
80108605:	89 d1                	mov    %edx,%ecx
80108607:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
8010860d:	83 ec 04             	sub    $0x4,%esp
80108610:	50                   	push   %eax
80108611:	51                   	push   %ecx
80108612:	52                   	push   %edx
80108613:	e8 44 ca ff ff       	call   8010505c <memmove>
80108618:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010861b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861e:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
80108624:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
8010862a:	01 ca                	add    %ecx,%edx
8010862c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010862f:	29 ca                	sub    %ecx,%edx
80108631:	83 ec 04             	sub    $0x4,%esp
80108634:	50                   	push   %eax
80108635:	6a 00                	push   $0x0
80108637:	52                   	push   %edx
80108638:	e8 60 c9 ff ff       	call   80104f9d <memset>
8010863d:	83 c4 10             	add    $0x10,%esp
}
80108640:	90                   	nop
80108641:	c9                   	leave  
80108642:	c3                   	ret    

80108643 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108643:	55                   	push   %ebp
80108644:	89 e5                	mov    %esp,%ebp
80108646:	53                   	push   %ebx
80108647:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010864a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108651:	e9 b1 00 00 00       	jmp    80108707 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108656:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010865d:	e9 97 00 00 00       	jmp    801086f9 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108662:	8b 45 10             	mov    0x10(%ebp),%eax
80108665:	83 e8 20             	sub    $0x20,%eax
80108668:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010866b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866e:	01 d0                	add    %edx,%eax
80108670:	0f b7 84 00 40 ae 10 	movzwl -0x7fef51c0(%eax,%eax,1),%eax
80108677:	80 
80108678:	0f b7 d0             	movzwl %ax,%edx
8010867b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867e:	bb 01 00 00 00       	mov    $0x1,%ebx
80108683:	89 c1                	mov    %eax,%ecx
80108685:	d3 e3                	shl    %cl,%ebx
80108687:	89 d8                	mov    %ebx,%eax
80108689:	21 d0                	and    %edx,%eax
8010868b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010868e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108691:	ba 01 00 00 00       	mov    $0x1,%edx
80108696:	89 c1                	mov    %eax,%ecx
80108698:	d3 e2                	shl    %cl,%edx
8010869a:	89 d0                	mov    %edx,%eax
8010869c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010869f:	75 2b                	jne    801086cc <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801086a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801086a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a7:	01 c2                	add    %eax,%edx
801086a9:	b8 0e 00 00 00       	mov    $0xe,%eax
801086ae:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086b1:	89 c1                	mov    %eax,%ecx
801086b3:	8b 45 08             	mov    0x8(%ebp),%eax
801086b6:	01 c8                	add    %ecx,%eax
801086b8:	83 ec 04             	sub    $0x4,%esp
801086bb:	68 e0 f4 10 80       	push   $0x8010f4e0
801086c0:	52                   	push   %edx
801086c1:	50                   	push   %eax
801086c2:	e8 be fe ff ff       	call   80108585 <graphic_draw_pixel>
801086c7:	83 c4 10             	add    $0x10,%esp
801086ca:	eb 29                	jmp    801086f5 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801086cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801086cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d2:	01 c2                	add    %eax,%edx
801086d4:	b8 0e 00 00 00       	mov    $0xe,%eax
801086d9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086dc:	89 c1                	mov    %eax,%ecx
801086de:	8b 45 08             	mov    0x8(%ebp),%eax
801086e1:	01 c8                	add    %ecx,%eax
801086e3:	83 ec 04             	sub    $0x4,%esp
801086e6:	68 a0 9c 11 80       	push   $0x80119ca0
801086eb:	52                   	push   %edx
801086ec:	50                   	push   %eax
801086ed:	e8 93 fe ff ff       	call   80108585 <graphic_draw_pixel>
801086f2:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801086f5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801086f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086fd:	0f 89 5f ff ff ff    	jns    80108662 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108703:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108707:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010870b:	0f 8e 45 ff ff ff    	jle    80108656 <font_render+0x13>
      }
    }
  }
}
80108711:	90                   	nop
80108712:	90                   	nop
80108713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108716:	c9                   	leave  
80108717:	c3                   	ret    

80108718 <font_render_string>:

void font_render_string(char *string,int row){
80108718:	55                   	push   %ebp
80108719:	89 e5                	mov    %esp,%ebp
8010871b:	53                   	push   %ebx
8010871c:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010871f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108726:	eb 33                	jmp    8010875b <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108728:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010872b:	8b 45 08             	mov    0x8(%ebp),%eax
8010872e:	01 d0                	add    %edx,%eax
80108730:	0f b6 00             	movzbl (%eax),%eax
80108733:	0f be c8             	movsbl %al,%ecx
80108736:	8b 45 0c             	mov    0xc(%ebp),%eax
80108739:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010873c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010873f:	89 d8                	mov    %ebx,%eax
80108741:	c1 e0 04             	shl    $0x4,%eax
80108744:	29 d8                	sub    %ebx,%eax
80108746:	83 c0 02             	add    $0x2,%eax
80108749:	83 ec 04             	sub    $0x4,%esp
8010874c:	51                   	push   %ecx
8010874d:	52                   	push   %edx
8010874e:	50                   	push   %eax
8010874f:	e8 ef fe ff ff       	call   80108643 <font_render>
80108754:	83 c4 10             	add    $0x10,%esp
    i++;
80108757:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010875b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010875e:	8b 45 08             	mov    0x8(%ebp),%eax
80108761:	01 d0                	add    %edx,%eax
80108763:	0f b6 00             	movzbl (%eax),%eax
80108766:	84 c0                	test   %al,%al
80108768:	74 06                	je     80108770 <font_render_string+0x58>
8010876a:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010876e:	7e b8                	jle    80108728 <font_render_string+0x10>
  }
}
80108770:	90                   	nop
80108771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108774:	c9                   	leave  
80108775:	c3                   	ret    

80108776 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108776:	55                   	push   %ebp
80108777:	89 e5                	mov    %esp,%ebp
80108779:	53                   	push   %ebx
8010877a:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010877d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108784:	eb 6b                	jmp    801087f1 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108786:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010878d:	eb 58                	jmp    801087e7 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010878f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108796:	eb 45                	jmp    801087dd <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108798:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010879b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010879e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a1:	83 ec 0c             	sub    $0xc,%esp
801087a4:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801087a7:	53                   	push   %ebx
801087a8:	6a 00                	push   $0x0
801087aa:	51                   	push   %ecx
801087ab:	52                   	push   %edx
801087ac:	50                   	push   %eax
801087ad:	e8 b0 00 00 00       	call   80108862 <pci_access_config>
801087b2:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801087b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087b8:	0f b7 c0             	movzwl %ax,%eax
801087bb:	3d ff ff 00 00       	cmp    $0xffff,%eax
801087c0:	74 17                	je     801087d9 <pci_init+0x63>
        pci_init_device(i,j,k);
801087c2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	83 ec 04             	sub    $0x4,%esp
801087ce:	51                   	push   %ecx
801087cf:	52                   	push   %edx
801087d0:	50                   	push   %eax
801087d1:	e8 37 01 00 00       	call   8010890d <pci_init_device>
801087d6:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801087d9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801087dd:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801087e1:	7e b5                	jle    80108798 <pci_init+0x22>
    for(int j=0;j<32;j++){
801087e3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801087e7:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801087eb:	7e a2                	jle    8010878f <pci_init+0x19>
  for(int i=0;i<256;i++){
801087ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087f1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801087f8:	7e 8c                	jle    80108786 <pci_init+0x10>
      }
      }
    }
  }
}
801087fa:	90                   	nop
801087fb:	90                   	nop
801087fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087ff:	c9                   	leave  
80108800:	c3                   	ret    

80108801 <pci_write_config>:

void pci_write_config(uint config){
80108801:	55                   	push   %ebp
80108802:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108804:	8b 45 08             	mov    0x8(%ebp),%eax
80108807:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010880c:	89 c0                	mov    %eax,%eax
8010880e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010880f:	90                   	nop
80108810:	5d                   	pop    %ebp
80108811:	c3                   	ret    

80108812 <pci_write_data>:

void pci_write_data(uint config){
80108812:	55                   	push   %ebp
80108813:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108815:	8b 45 08             	mov    0x8(%ebp),%eax
80108818:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010881d:	89 c0                	mov    %eax,%eax
8010881f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108820:	90                   	nop
80108821:	5d                   	pop    %ebp
80108822:	c3                   	ret    

80108823 <pci_read_config>:
uint pci_read_config(){
80108823:	55                   	push   %ebp
80108824:	89 e5                	mov    %esp,%ebp
80108826:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108829:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010882e:	ed                   	in     (%dx),%eax
8010882f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108832:	83 ec 0c             	sub    $0xc,%esp
80108835:	68 c8 00 00 00       	push   $0xc8
8010883a:	e8 d2 a7 ff ff       	call   80103011 <microdelay>
8010883f:	83 c4 10             	add    $0x10,%esp
  return data;
80108842:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108845:	c9                   	leave  
80108846:	c3                   	ret    

80108847 <pci_test>:


void pci_test(){
80108847:	55                   	push   %ebp
80108848:	89 e5                	mov    %esp,%ebp
8010884a:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010884d:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108854:	ff 75 fc             	push   -0x4(%ebp)
80108857:	e8 a5 ff ff ff       	call   80108801 <pci_write_config>
8010885c:	83 c4 04             	add    $0x4,%esp
}
8010885f:	90                   	nop
80108860:	c9                   	leave  
80108861:	c3                   	ret    

80108862 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108862:	55                   	push   %ebp
80108863:	89 e5                	mov    %esp,%ebp
80108865:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108868:	8b 45 08             	mov    0x8(%ebp),%eax
8010886b:	c1 e0 10             	shl    $0x10,%eax
8010886e:	25 00 00 ff 00       	and    $0xff0000,%eax
80108873:	89 c2                	mov    %eax,%edx
80108875:	8b 45 0c             	mov    0xc(%ebp),%eax
80108878:	c1 e0 0b             	shl    $0xb,%eax
8010887b:	0f b7 c0             	movzwl %ax,%eax
8010887e:	09 c2                	or     %eax,%edx
80108880:	8b 45 10             	mov    0x10(%ebp),%eax
80108883:	c1 e0 08             	shl    $0x8,%eax
80108886:	25 00 07 00 00       	and    $0x700,%eax
8010888b:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010888d:	8b 45 14             	mov    0x14(%ebp),%eax
80108890:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108895:	09 d0                	or     %edx,%eax
80108897:	0d 00 00 00 80       	or     $0x80000000,%eax
8010889c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010889f:	ff 75 f4             	push   -0xc(%ebp)
801088a2:	e8 5a ff ff ff       	call   80108801 <pci_write_config>
801088a7:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801088aa:	e8 74 ff ff ff       	call   80108823 <pci_read_config>
801088af:	8b 55 18             	mov    0x18(%ebp),%edx
801088b2:	89 02                	mov    %eax,(%edx)
}
801088b4:	90                   	nop
801088b5:	c9                   	leave  
801088b6:	c3                   	ret    

801088b7 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801088b7:	55                   	push   %ebp
801088b8:	89 e5                	mov    %esp,%ebp
801088ba:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088bd:	8b 45 08             	mov    0x8(%ebp),%eax
801088c0:	c1 e0 10             	shl    $0x10,%eax
801088c3:	25 00 00 ff 00       	and    $0xff0000,%eax
801088c8:	89 c2                	mov    %eax,%edx
801088ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801088cd:	c1 e0 0b             	shl    $0xb,%eax
801088d0:	0f b7 c0             	movzwl %ax,%eax
801088d3:	09 c2                	or     %eax,%edx
801088d5:	8b 45 10             	mov    0x10(%ebp),%eax
801088d8:	c1 e0 08             	shl    $0x8,%eax
801088db:	25 00 07 00 00       	and    $0x700,%eax
801088e0:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801088e2:	8b 45 14             	mov    0x14(%ebp),%eax
801088e5:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088ea:	09 d0                	or     %edx,%eax
801088ec:	0d 00 00 00 80       	or     $0x80000000,%eax
801088f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801088f4:	ff 75 fc             	push   -0x4(%ebp)
801088f7:	e8 05 ff ff ff       	call   80108801 <pci_write_config>
801088fc:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801088ff:	ff 75 18             	push   0x18(%ebp)
80108902:	e8 0b ff ff ff       	call   80108812 <pci_write_data>
80108907:	83 c4 04             	add    $0x4,%esp
}
8010890a:	90                   	nop
8010890b:	c9                   	leave  
8010890c:	c3                   	ret    

8010890d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010890d:	55                   	push   %ebp
8010890e:	89 e5                	mov    %esp,%ebp
80108910:	53                   	push   %ebx
80108911:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108914:	8b 45 08             	mov    0x8(%ebp),%eax
80108917:	a2 a4 9c 11 80       	mov    %al,0x80119ca4
  dev.device_num = device_num;
8010891c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010891f:	a2 a5 9c 11 80       	mov    %al,0x80119ca5
  dev.function_num = function_num;
80108924:	8b 45 10             	mov    0x10(%ebp),%eax
80108927:	a2 a6 9c 11 80       	mov    %al,0x80119ca6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010892c:	ff 75 10             	push   0x10(%ebp)
8010892f:	ff 75 0c             	push   0xc(%ebp)
80108932:	ff 75 08             	push   0x8(%ebp)
80108935:	68 84 c4 10 80       	push   $0x8010c484
8010893a:	e8 b5 7a ff ff       	call   801003f4 <cprintf>
8010893f:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108942:	83 ec 0c             	sub    $0xc,%esp
80108945:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108948:	50                   	push   %eax
80108949:	6a 00                	push   $0x0
8010894b:	ff 75 10             	push   0x10(%ebp)
8010894e:	ff 75 0c             	push   0xc(%ebp)
80108951:	ff 75 08             	push   0x8(%ebp)
80108954:	e8 09 ff ff ff       	call   80108862 <pci_access_config>
80108959:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010895c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010895f:	c1 e8 10             	shr    $0x10,%eax
80108962:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108965:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108968:	25 ff ff 00 00       	and    $0xffff,%eax
8010896d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108973:	a3 a8 9c 11 80       	mov    %eax,0x80119ca8
  dev.vendor_id = vendor_id;
80108978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010897b:	a3 ac 9c 11 80       	mov    %eax,0x80119cac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108980:	83 ec 04             	sub    $0x4,%esp
80108983:	ff 75 f0             	push   -0x10(%ebp)
80108986:	ff 75 f4             	push   -0xc(%ebp)
80108989:	68 b8 c4 10 80       	push   $0x8010c4b8
8010898e:	e8 61 7a ff ff       	call   801003f4 <cprintf>
80108993:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108996:	83 ec 0c             	sub    $0xc,%esp
80108999:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010899c:	50                   	push   %eax
8010899d:	6a 08                	push   $0x8
8010899f:	ff 75 10             	push   0x10(%ebp)
801089a2:	ff 75 0c             	push   0xc(%ebp)
801089a5:	ff 75 08             	push   0x8(%ebp)
801089a8:	e8 b5 fe ff ff       	call   80108862 <pci_access_config>
801089ad:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b3:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b9:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089bc:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c2:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089c5:	0f b6 c0             	movzbl %al,%eax
801089c8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089cb:	c1 eb 18             	shr    $0x18,%ebx
801089ce:	83 ec 0c             	sub    $0xc,%esp
801089d1:	51                   	push   %ecx
801089d2:	52                   	push   %edx
801089d3:	50                   	push   %eax
801089d4:	53                   	push   %ebx
801089d5:	68 dc c4 10 80       	push   $0x8010c4dc
801089da:	e8 15 7a ff ff       	call   801003f4 <cprintf>
801089df:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801089e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e5:	c1 e8 18             	shr    $0x18,%eax
801089e8:	a2 b0 9c 11 80       	mov    %al,0x80119cb0
  dev.sub_class = (data>>16)&0xFF;
801089ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f0:	c1 e8 10             	shr    $0x10,%eax
801089f3:	a2 b1 9c 11 80       	mov    %al,0x80119cb1
  dev.interface = (data>>8)&0xFF;
801089f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089fb:	c1 e8 08             	shr    $0x8,%eax
801089fe:	a2 b2 9c 11 80       	mov    %al,0x80119cb2
  dev.revision_id = data&0xFF;
80108a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a06:	a2 b3 9c 11 80       	mov    %al,0x80119cb3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108a0b:	83 ec 0c             	sub    $0xc,%esp
80108a0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a11:	50                   	push   %eax
80108a12:	6a 10                	push   $0x10
80108a14:	ff 75 10             	push   0x10(%ebp)
80108a17:	ff 75 0c             	push   0xc(%ebp)
80108a1a:	ff 75 08             	push   0x8(%ebp)
80108a1d:	e8 40 fe ff ff       	call   80108862 <pci_access_config>
80108a22:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108a25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a28:	a3 b4 9c 11 80       	mov    %eax,0x80119cb4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108a2d:	83 ec 0c             	sub    $0xc,%esp
80108a30:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a33:	50                   	push   %eax
80108a34:	6a 14                	push   $0x14
80108a36:	ff 75 10             	push   0x10(%ebp)
80108a39:	ff 75 0c             	push   0xc(%ebp)
80108a3c:	ff 75 08             	push   0x8(%ebp)
80108a3f:	e8 1e fe ff ff       	call   80108862 <pci_access_config>
80108a44:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4a:	a3 b8 9c 11 80       	mov    %eax,0x80119cb8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108a4f:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108a56:	75 5a                	jne    80108ab2 <pci_init_device+0x1a5>
80108a58:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108a5f:	75 51                	jne    80108ab2 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108a61:	83 ec 0c             	sub    $0xc,%esp
80108a64:	68 21 c5 10 80       	push   $0x8010c521
80108a69:	e8 86 79 ff ff       	call   801003f4 <cprintf>
80108a6e:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a71:	83 ec 0c             	sub    $0xc,%esp
80108a74:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a77:	50                   	push   %eax
80108a78:	68 f0 00 00 00       	push   $0xf0
80108a7d:	ff 75 10             	push   0x10(%ebp)
80108a80:	ff 75 0c             	push   0xc(%ebp)
80108a83:	ff 75 08             	push   0x8(%ebp)
80108a86:	e8 d7 fd ff ff       	call   80108862 <pci_access_config>
80108a8b:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108a8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a91:	83 ec 08             	sub    $0x8,%esp
80108a94:	50                   	push   %eax
80108a95:	68 3b c5 10 80       	push   $0x8010c53b
80108a9a:	e8 55 79 ff ff       	call   801003f4 <cprintf>
80108a9f:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108aa2:	83 ec 0c             	sub    $0xc,%esp
80108aa5:	68 a4 9c 11 80       	push   $0x80119ca4
80108aaa:	e8 09 00 00 00       	call   80108ab8 <i8254_init>
80108aaf:	83 c4 10             	add    $0x10,%esp
  }
}
80108ab2:	90                   	nop
80108ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ab6:	c9                   	leave  
80108ab7:	c3                   	ret    

80108ab8 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108ab8:	55                   	push   %ebp
80108ab9:	89 e5                	mov    %esp,%ebp
80108abb:	53                   	push   %ebx
80108abc:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108abf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ac2:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108ac6:	0f b6 c8             	movzbl %al,%ecx
80108ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80108acc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ad0:	0f b6 d0             	movzbl %al,%edx
80108ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad6:	0f b6 00             	movzbl (%eax),%eax
80108ad9:	0f b6 c0             	movzbl %al,%eax
80108adc:	83 ec 0c             	sub    $0xc,%esp
80108adf:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ae2:	53                   	push   %ebx
80108ae3:	6a 04                	push   $0x4
80108ae5:	51                   	push   %ecx
80108ae6:	52                   	push   %edx
80108ae7:	50                   	push   %eax
80108ae8:	e8 75 fd ff ff       	call   80108862 <pci_access_config>
80108aed:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af3:	83 c8 04             	or     $0x4,%eax
80108af6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108af9:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108afc:	8b 45 08             	mov    0x8(%ebp),%eax
80108aff:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b03:	0f b6 c8             	movzbl %al,%ecx
80108b06:	8b 45 08             	mov    0x8(%ebp),%eax
80108b09:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b0d:	0f b6 d0             	movzbl %al,%edx
80108b10:	8b 45 08             	mov    0x8(%ebp),%eax
80108b13:	0f b6 00             	movzbl (%eax),%eax
80108b16:	0f b6 c0             	movzbl %al,%eax
80108b19:	83 ec 0c             	sub    $0xc,%esp
80108b1c:	53                   	push   %ebx
80108b1d:	6a 04                	push   $0x4
80108b1f:	51                   	push   %ecx
80108b20:	52                   	push   %edx
80108b21:	50                   	push   %eax
80108b22:	e8 90 fd ff ff       	call   801088b7 <pci_write_config_register>
80108b27:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2d:	8b 40 10             	mov    0x10(%eax),%eax
80108b30:	05 00 00 00 40       	add    $0x40000000,%eax
80108b35:	a3 bc 9c 11 80       	mov    %eax,0x80119cbc
  uint *ctrl = (uint *)base_addr;
80108b3a:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108b42:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108b47:	05 d8 00 00 00       	add    $0xd8,%eax
80108b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b52:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5b:	8b 00                	mov    (%eax),%eax
80108b5d:	0d 00 00 00 04       	or     $0x4000000,%eax
80108b62:	89 c2                	mov    %eax,%edx
80108b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b67:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b75:	8b 00                	mov    (%eax),%eax
80108b77:	83 c8 40             	or     $0x40,%eax
80108b7a:	89 c2                	mov    %eax,%edx
80108b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7f:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b84:	8b 10                	mov    (%eax),%edx
80108b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b89:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108b8b:	83 ec 0c             	sub    $0xc,%esp
80108b8e:	68 50 c5 10 80       	push   $0x8010c550
80108b93:	e8 5c 78 ff ff       	call   801003f4 <cprintf>
80108b98:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108b9b:	e8 da a0 ff ff       	call   80102c7a <kalloc>
80108ba0:	a3 c8 9c 11 80       	mov    %eax,0x80119cc8
  *intr_addr = 0;
80108ba5:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108baa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108bb0:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108bb5:	83 ec 08             	sub    $0x8,%esp
80108bb8:	50                   	push   %eax
80108bb9:	68 72 c5 10 80       	push   $0x8010c572
80108bbe:	e8 31 78 ff ff       	call   801003f4 <cprintf>
80108bc3:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108bc6:	e8 50 00 00 00       	call   80108c1b <i8254_init_recv>
  i8254_init_send();
80108bcb:	e8 69 03 00 00       	call   80108f39 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108bd0:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bd7:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108bda:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108be1:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108be4:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108beb:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108bee:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bf5:	0f b6 c0             	movzbl %al,%eax
80108bf8:	83 ec 0c             	sub    $0xc,%esp
80108bfb:	53                   	push   %ebx
80108bfc:	51                   	push   %ecx
80108bfd:	52                   	push   %edx
80108bfe:	50                   	push   %eax
80108bff:	68 80 c5 10 80       	push   $0x8010c580
80108c04:	e8 eb 77 ff ff       	call   801003f4 <cprintf>
80108c09:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108c15:	90                   	nop
80108c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c19:	c9                   	leave  
80108c1a:	c3                   	ret    

80108c1b <i8254_init_recv>:

void i8254_init_recv(){
80108c1b:	55                   	push   %ebp
80108c1c:	89 e5                	mov    %esp,%ebp
80108c1e:	57                   	push   %edi
80108c1f:	56                   	push   %esi
80108c20:	53                   	push   %ebx
80108c21:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108c24:	83 ec 0c             	sub    $0xc,%esp
80108c27:	6a 00                	push   $0x0
80108c29:	e8 e8 04 00 00       	call   80109116 <i8254_read_eeprom>
80108c2e:	83 c4 10             	add    $0x10,%esp
80108c31:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108c34:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c37:	a2 c0 9c 11 80       	mov    %al,0x80119cc0
  mac_addr[1] = data_l>>8;
80108c3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c3f:	c1 e8 08             	shr    $0x8,%eax
80108c42:	a2 c1 9c 11 80       	mov    %al,0x80119cc1
  uint data_m = i8254_read_eeprom(0x1);
80108c47:	83 ec 0c             	sub    $0xc,%esp
80108c4a:	6a 01                	push   $0x1
80108c4c:	e8 c5 04 00 00       	call   80109116 <i8254_read_eeprom>
80108c51:	83 c4 10             	add    $0x10,%esp
80108c54:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108c57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c5a:	a2 c2 9c 11 80       	mov    %al,0x80119cc2
  mac_addr[3] = data_m>>8;
80108c5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c62:	c1 e8 08             	shr    $0x8,%eax
80108c65:	a2 c3 9c 11 80       	mov    %al,0x80119cc3
  uint data_h = i8254_read_eeprom(0x2);
80108c6a:	83 ec 0c             	sub    $0xc,%esp
80108c6d:	6a 02                	push   $0x2
80108c6f:	e8 a2 04 00 00       	call   80109116 <i8254_read_eeprom>
80108c74:	83 c4 10             	add    $0x10,%esp
80108c77:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108c7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c7d:	a2 c4 9c 11 80       	mov    %al,0x80119cc4
  mac_addr[5] = data_h>>8;
80108c82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c85:	c1 e8 08             	shr    $0x8,%eax
80108c88:	a2 c5 9c 11 80       	mov    %al,0x80119cc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108c8d:	0f b6 05 c5 9c 11 80 	movzbl 0x80119cc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c94:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c97:	0f b6 05 c4 9c 11 80 	movzbl 0x80119cc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c9e:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ca1:	0f b6 05 c3 9c 11 80 	movzbl 0x80119cc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ca8:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108cab:	0f b6 05 c2 9c 11 80 	movzbl 0x80119cc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cb2:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108cb5:	0f b6 05 c1 9c 11 80 	movzbl 0x80119cc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cbc:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108cbf:	0f b6 05 c0 9c 11 80 	movzbl 0x80119cc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cc6:	0f b6 c0             	movzbl %al,%eax
80108cc9:	83 ec 04             	sub    $0x4,%esp
80108ccc:	57                   	push   %edi
80108ccd:	56                   	push   %esi
80108cce:	53                   	push   %ebx
80108ccf:	51                   	push   %ecx
80108cd0:	52                   	push   %edx
80108cd1:	50                   	push   %eax
80108cd2:	68 98 c5 10 80       	push   $0x8010c598
80108cd7:	e8 18 77 ff ff       	call   801003f4 <cprintf>
80108cdc:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108cdf:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ce4:	05 00 54 00 00       	add    $0x5400,%eax
80108ce9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108cec:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108cf1:	05 04 54 00 00       	add    $0x5404,%eax
80108cf6:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108cf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cfc:	c1 e0 10             	shl    $0x10,%eax
80108cff:	0b 45 d8             	or     -0x28(%ebp),%eax
80108d02:	89 c2                	mov    %eax,%edx
80108d04:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108d07:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108d09:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d0c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d11:	89 c2                	mov    %eax,%edx
80108d13:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d16:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108d18:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d1d:	05 00 52 00 00       	add    $0x5200,%eax
80108d22:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108d25:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108d2c:	eb 19                	jmp    80108d47 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d38:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d3b:	01 d0                	add    %edx,%eax
80108d3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108d43:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108d47:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108d4b:	7e e1                	jle    80108d2e <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108d4d:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d52:	05 d0 00 00 00       	add    $0xd0,%eax
80108d57:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d5a:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108d5d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108d63:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d68:	05 c8 00 00 00       	add    $0xc8,%eax
80108d6d:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d70:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d73:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108d79:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d7e:	05 28 28 00 00       	add    $0x2828,%eax
80108d83:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108d86:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108d89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108d8f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d94:	05 00 01 00 00       	add    $0x100,%eax
80108d99:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108d9c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d9f:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108da5:	e8 d0 9e ff ff       	call   80102c7a <kalloc>
80108daa:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108dad:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108db2:	05 00 28 00 00       	add    $0x2800,%eax
80108db7:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108dba:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108dbf:	05 04 28 00 00       	add    $0x2804,%eax
80108dc4:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108dc7:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108dcc:	05 08 28 00 00       	add    $0x2808,%eax
80108dd1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108dd4:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108dd9:	05 10 28 00 00       	add    $0x2810,%eax
80108dde:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108de1:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108de6:	05 18 28 00 00       	add    $0x2818,%eax
80108deb:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108dee:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108df1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108df7:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108dfa:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108dfc:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108dff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108e05:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108e08:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108e0e:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108e11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108e17:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108e1a:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108e20:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e23:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e26:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e2d:	eb 73                	jmp    80108ea2 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e32:	c1 e0 04             	shl    $0x4,%eax
80108e35:	89 c2                	mov    %eax,%edx
80108e37:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e3a:	01 d0                	add    %edx,%eax
80108e3c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e46:	c1 e0 04             	shl    $0x4,%eax
80108e49:	89 c2                	mov    %eax,%edx
80108e4b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e4e:	01 d0                	add    %edx,%eax
80108e50:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108e56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e59:	c1 e0 04             	shl    $0x4,%eax
80108e5c:	89 c2                	mov    %eax,%edx
80108e5e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e61:	01 d0                	add    %edx,%eax
80108e63:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e6c:	c1 e0 04             	shl    $0x4,%eax
80108e6f:	89 c2                	mov    %eax,%edx
80108e71:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e74:	01 d0                	add    %edx,%eax
80108e76:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e7d:	c1 e0 04             	shl    $0x4,%eax
80108e80:	89 c2                	mov    %eax,%edx
80108e82:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e85:	01 d0                	add    %edx,%eax
80108e87:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e8e:	c1 e0 04             	shl    $0x4,%eax
80108e91:	89 c2                	mov    %eax,%edx
80108e93:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e96:	01 d0                	add    %edx,%eax
80108e98:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e9e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ea2:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ea9:	7e 84                	jle    80108e2f <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108eab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108eb2:	eb 57                	jmp    80108f0b <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108eb4:	e8 c1 9d ff ff       	call   80102c7a <kalloc>
80108eb9:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ebc:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108ec0:	75 12                	jne    80108ed4 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108ec2:	83 ec 0c             	sub    $0xc,%esp
80108ec5:	68 b8 c5 10 80       	push   $0x8010c5b8
80108eca:	e8 25 75 ff ff       	call   801003f4 <cprintf>
80108ecf:	83 c4 10             	add    $0x10,%esp
      break;
80108ed2:	eb 3d                	jmp    80108f11 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108ed4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ed7:	c1 e0 04             	shl    $0x4,%eax
80108eda:	89 c2                	mov    %eax,%edx
80108edc:	8b 45 98             	mov    -0x68(%ebp),%eax
80108edf:	01 d0                	add    %edx,%eax
80108ee1:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ee4:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eea:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108eec:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108eef:	83 c0 01             	add    $0x1,%eax
80108ef2:	c1 e0 04             	shl    $0x4,%eax
80108ef5:	89 c2                	mov    %eax,%edx
80108ef7:	8b 45 98             	mov    -0x68(%ebp),%eax
80108efa:	01 d0                	add    %edx,%eax
80108efc:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108eff:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f05:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108f07:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108f0b:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108f0f:	7e a3                	jle    80108eb4 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108f11:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f14:	8b 00                	mov    (%eax),%eax
80108f16:	83 c8 02             	or     $0x2,%eax
80108f19:	89 c2                	mov    %eax,%edx
80108f1b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f1e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108f20:	83 ec 0c             	sub    $0xc,%esp
80108f23:	68 d8 c5 10 80       	push   $0x8010c5d8
80108f28:	e8 c7 74 ff ff       	call   801003f4 <cprintf>
80108f2d:	83 c4 10             	add    $0x10,%esp
}
80108f30:	90                   	nop
80108f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108f34:	5b                   	pop    %ebx
80108f35:	5e                   	pop    %esi
80108f36:	5f                   	pop    %edi
80108f37:	5d                   	pop    %ebp
80108f38:	c3                   	ret    

80108f39 <i8254_init_send>:

void i8254_init_send(){
80108f39:	55                   	push   %ebp
80108f3a:	89 e5                	mov    %esp,%ebp
80108f3c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108f3f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108f44:	05 28 38 00 00       	add    $0x3828,%eax
80108f49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f4f:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108f55:	e8 20 9d ff ff       	call   80102c7a <kalloc>
80108f5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f5d:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108f62:	05 00 38 00 00       	add    $0x3800,%eax
80108f67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108f6a:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108f6f:	05 04 38 00 00       	add    $0x3804,%eax
80108f74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108f77:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108f7c:	05 08 38 00 00       	add    $0x3808,%eax
80108f81:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f87:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f90:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f9e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fa4:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108fa9:	05 10 38 00 00       	add    $0x3810,%eax
80108fae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fb1:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108fb6:	05 18 38 00 00       	add    $0x3818,%eax
80108fbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108fbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108fc7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108fd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108fd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fdd:	e9 82 00 00 00       	jmp    80109064 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe5:	c1 e0 04             	shl    $0x4,%eax
80108fe8:	89 c2                	mov    %eax,%edx
80108fea:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fed:	01 d0                	add    %edx,%eax
80108fef:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff9:	c1 e0 04             	shl    $0x4,%eax
80108ffc:	89 c2                	mov    %eax,%edx
80108ffe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109001:	01 d0                	add    %edx,%eax
80109003:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900c:	c1 e0 04             	shl    $0x4,%eax
8010900f:	89 c2                	mov    %eax,%edx
80109011:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109014:	01 d0                	add    %edx,%eax
80109016:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010901a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901d:	c1 e0 04             	shl    $0x4,%eax
80109020:	89 c2                	mov    %eax,%edx
80109022:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109025:	01 d0                	add    %edx,%eax
80109027:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010902b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902e:	c1 e0 04             	shl    $0x4,%eax
80109031:	89 c2                	mov    %eax,%edx
80109033:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109036:	01 d0                	add    %edx,%eax
80109038:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010903c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010903f:	c1 e0 04             	shl    $0x4,%eax
80109042:	89 c2                	mov    %eax,%edx
80109044:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109047:	01 d0                	add    %edx,%eax
80109049:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010904d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109050:	c1 e0 04             	shl    $0x4,%eax
80109053:	89 c2                	mov    %eax,%edx
80109055:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109058:	01 d0                	add    %edx,%eax
8010905a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109060:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109064:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010906b:	0f 8e 71 ff ff ff    	jle    80108fe2 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109071:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109078:	eb 57                	jmp    801090d1 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
8010907a:	e8 fb 9b ff ff       	call   80102c7a <kalloc>
8010907f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109082:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109086:	75 12                	jne    8010909a <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109088:	83 ec 0c             	sub    $0xc,%esp
8010908b:	68 b8 c5 10 80       	push   $0x8010c5b8
80109090:	e8 5f 73 ff ff       	call   801003f4 <cprintf>
80109095:	83 c4 10             	add    $0x10,%esp
      break;
80109098:	eb 3d                	jmp    801090d7 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010909a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909d:	c1 e0 04             	shl    $0x4,%eax
801090a0:	89 c2                	mov    %eax,%edx
801090a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090a5:	01 d0                	add    %edx,%eax
801090a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090aa:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090b0:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b5:	83 c0 01             	add    $0x1,%eax
801090b8:	c1 e0 04             	shl    $0x4,%eax
801090bb:	89 c2                	mov    %eax,%edx
801090bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090c0:	01 d0                	add    %edx,%eax
801090c2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090c5:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090cb:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801090cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801090d1:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801090d5:	7e a3                	jle    8010907a <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801090d7:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090dc:	05 00 04 00 00       	add    $0x400,%eax
801090e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801090e4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801090e7:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801090ed:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090f2:	05 10 04 00 00       	add    $0x410,%eax
801090f7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801090fa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801090fd:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109103:	83 ec 0c             	sub    $0xc,%esp
80109106:	68 f8 c5 10 80       	push   $0x8010c5f8
8010910b:	e8 e4 72 ff ff       	call   801003f4 <cprintf>
80109110:	83 c4 10             	add    $0x10,%esp

}
80109113:	90                   	nop
80109114:	c9                   	leave  
80109115:	c3                   	ret    

80109116 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109116:	55                   	push   %ebp
80109117:	89 e5                	mov    %esp,%ebp
80109119:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010911c:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109121:	83 c0 14             	add    $0x14,%eax
80109124:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109127:	8b 45 08             	mov    0x8(%ebp),%eax
8010912a:	c1 e0 08             	shl    $0x8,%eax
8010912d:	0f b7 c0             	movzwl %ax,%eax
80109130:	83 c8 01             	or     $0x1,%eax
80109133:	89 c2                	mov    %eax,%edx
80109135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109138:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010913a:	83 ec 0c             	sub    $0xc,%esp
8010913d:	68 18 c6 10 80       	push   $0x8010c618
80109142:	e8 ad 72 ff ff       	call   801003f4 <cprintf>
80109147:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010914a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914d:	8b 00                	mov    (%eax),%eax
8010914f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109155:	83 e0 10             	and    $0x10,%eax
80109158:	85 c0                	test   %eax,%eax
8010915a:	75 02                	jne    8010915e <i8254_read_eeprom+0x48>
  while(1){
8010915c:	eb dc                	jmp    8010913a <i8254_read_eeprom+0x24>
      break;
8010915e:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
8010915f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109162:	8b 00                	mov    (%eax),%eax
80109164:	c1 e8 10             	shr    $0x10,%eax
}
80109167:	c9                   	leave  
80109168:	c3                   	ret    

80109169 <i8254_recv>:
void i8254_recv(){
80109169:	55                   	push   %ebp
8010916a:	89 e5                	mov    %esp,%ebp
8010916c:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010916f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109174:	05 10 28 00 00       	add    $0x2810,%eax
80109179:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010917c:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109181:	05 18 28 00 00       	add    $0x2818,%eax
80109186:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109189:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010918e:	05 00 28 00 00       	add    $0x2800,%eax
80109193:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109199:	8b 00                	mov    (%eax),%eax
8010919b:	05 00 00 00 80       	add    $0x80000000,%eax
801091a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801091a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a6:	8b 10                	mov    (%eax),%edx
801091a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ab:	8b 08                	mov    (%eax),%ecx
801091ad:	89 d0                	mov    %edx,%eax
801091af:	29 c8                	sub    %ecx,%eax
801091b1:	25 ff 00 00 00       	and    $0xff,%eax
801091b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801091b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091bd:	7e 37                	jle    801091f6 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801091bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c2:	8b 00                	mov    (%eax),%eax
801091c4:	c1 e0 04             	shl    $0x4,%eax
801091c7:	89 c2                	mov    %eax,%edx
801091c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091cc:	01 d0                	add    %edx,%eax
801091ce:	8b 00                	mov    (%eax),%eax
801091d0:	05 00 00 00 80       	add    $0x80000000,%eax
801091d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801091d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091db:	8b 00                	mov    (%eax),%eax
801091dd:	83 c0 01             	add    $0x1,%eax
801091e0:	0f b6 d0             	movzbl %al,%edx
801091e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e6:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801091e8:	83 ec 0c             	sub    $0xc,%esp
801091eb:	ff 75 e0             	push   -0x20(%ebp)
801091ee:	e8 15 09 00 00       	call   80109b08 <eth_proc>
801091f3:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801091f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f9:	8b 10                	mov    (%eax),%edx
801091fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fe:	8b 00                	mov    (%eax),%eax
80109200:	39 c2                	cmp    %eax,%edx
80109202:	75 9f                	jne    801091a3 <i8254_recv+0x3a>
      (*rdt)--;
80109204:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109207:	8b 00                	mov    (%eax),%eax
80109209:	8d 50 ff             	lea    -0x1(%eax),%edx
8010920c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920f:	89 10                	mov    %edx,(%eax)
  while(1){
80109211:	eb 90                	jmp    801091a3 <i8254_recv+0x3a>

80109213 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109213:	55                   	push   %ebp
80109214:	89 e5                	mov    %esp,%ebp
80109216:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109219:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010921e:	05 10 38 00 00       	add    $0x3810,%eax
80109223:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109226:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010922b:	05 18 38 00 00       	add    $0x3818,%eax
80109230:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109233:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109238:	05 00 38 00 00       	add    $0x3800,%eax
8010923d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109240:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109243:	8b 00                	mov    (%eax),%eax
80109245:	05 00 00 00 80       	add    $0x80000000,%eax
8010924a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010924d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109250:	8b 10                	mov    (%eax),%edx
80109252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109255:	8b 08                	mov    (%eax),%ecx
80109257:	89 d0                	mov    %edx,%eax
80109259:	29 c8                	sub    %ecx,%eax
8010925b:	0f b6 d0             	movzbl %al,%edx
8010925e:	b8 00 01 00 00       	mov    $0x100,%eax
80109263:	29 d0                	sub    %edx,%eax
80109265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010926b:	8b 00                	mov    (%eax),%eax
8010926d:	25 ff 00 00 00       	and    $0xff,%eax
80109272:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109275:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109279:	0f 8e a8 00 00 00    	jle    80109327 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010927f:	8b 45 08             	mov    0x8(%ebp),%eax
80109282:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109285:	89 d1                	mov    %edx,%ecx
80109287:	c1 e1 04             	shl    $0x4,%ecx
8010928a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010928d:	01 ca                	add    %ecx,%edx
8010928f:	8b 12                	mov    (%edx),%edx
80109291:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109297:	83 ec 04             	sub    $0x4,%esp
8010929a:	ff 75 0c             	push   0xc(%ebp)
8010929d:	50                   	push   %eax
8010929e:	52                   	push   %edx
8010929f:	e8 b8 bd ff ff       	call   8010505c <memmove>
801092a4:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801092a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092aa:	c1 e0 04             	shl    $0x4,%eax
801092ad:	89 c2                	mov    %eax,%edx
801092af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092b2:	01 d0                	add    %edx,%eax
801092b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801092b7:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801092bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092be:	c1 e0 04             	shl    $0x4,%eax
801092c1:	89 c2                	mov    %eax,%edx
801092c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092c6:	01 d0                	add    %edx,%eax
801092c8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801092cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092cf:	c1 e0 04             	shl    $0x4,%eax
801092d2:	89 c2                	mov    %eax,%edx
801092d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092d7:	01 d0                	add    %edx,%eax
801092d9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801092dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e0:	c1 e0 04             	shl    $0x4,%eax
801092e3:	89 c2                	mov    %eax,%edx
801092e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092e8:	01 d0                	add    %edx,%eax
801092ea:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801092ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092f1:	c1 e0 04             	shl    $0x4,%eax
801092f4:	89 c2                	mov    %eax,%edx
801092f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092f9:	01 d0                	add    %edx,%eax
801092fb:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109301:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109304:	c1 e0 04             	shl    $0x4,%eax
80109307:	89 c2                	mov    %eax,%edx
80109309:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010930c:	01 d0                	add    %edx,%eax
8010930e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109312:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109315:	8b 00                	mov    (%eax),%eax
80109317:	83 c0 01             	add    $0x1,%eax
8010931a:	0f b6 d0             	movzbl %al,%edx
8010931d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109320:	89 10                	mov    %edx,(%eax)
    return len;
80109322:	8b 45 0c             	mov    0xc(%ebp),%eax
80109325:	eb 05                	jmp    8010932c <i8254_send+0x119>
  }else{
    return -1;
80109327:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010932c:	c9                   	leave  
8010932d:	c3                   	ret    

8010932e <i8254_intr>:

void i8254_intr(){
8010932e:	55                   	push   %ebp
8010932f:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109331:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80109336:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010933c:	90                   	nop
8010933d:	5d                   	pop    %ebp
8010933e:	c3                   	ret    

8010933f <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010933f:	55                   	push   %ebp
80109340:	89 e5                	mov    %esp,%ebp
80109342:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109345:	8b 45 08             	mov    0x8(%ebp),%eax
80109348:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
8010934b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934e:	0f b7 00             	movzwl (%eax),%eax
80109351:	66 3d 00 01          	cmp    $0x100,%ax
80109355:	74 0a                	je     80109361 <arp_proc+0x22>
80109357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010935c:	e9 4f 01 00 00       	jmp    801094b0 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109364:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109368:	66 83 f8 08          	cmp    $0x8,%ax
8010936c:	74 0a                	je     80109378 <arp_proc+0x39>
8010936e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109373:	e9 38 01 00 00       	jmp    801094b0 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010937f:	3c 06                	cmp    $0x6,%al
80109381:	74 0a                	je     8010938d <arp_proc+0x4e>
80109383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109388:	e9 23 01 00 00       	jmp    801094b0 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
8010938d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109390:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109394:	3c 04                	cmp    $0x4,%al
80109396:	74 0a                	je     801093a2 <arp_proc+0x63>
80109398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010939d:	e9 0e 01 00 00       	jmp    801094b0 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801093a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a5:	83 c0 18             	add    $0x18,%eax
801093a8:	83 ec 04             	sub    $0x4,%esp
801093ab:	6a 04                	push   $0x4
801093ad:	50                   	push   %eax
801093ae:	68 e4 f4 10 80       	push   $0x8010f4e4
801093b3:	e8 4c bc ff ff       	call   80105004 <memcmp>
801093b8:	83 c4 10             	add    $0x10,%esp
801093bb:	85 c0                	test   %eax,%eax
801093bd:	74 27                	je     801093e6 <arp_proc+0xa7>
801093bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c2:	83 c0 0e             	add    $0xe,%eax
801093c5:	83 ec 04             	sub    $0x4,%esp
801093c8:	6a 04                	push   $0x4
801093ca:	50                   	push   %eax
801093cb:	68 e4 f4 10 80       	push   $0x8010f4e4
801093d0:	e8 2f bc ff ff       	call   80105004 <memcmp>
801093d5:	83 c4 10             	add    $0x10,%esp
801093d8:	85 c0                	test   %eax,%eax
801093da:	74 0a                	je     801093e6 <arp_proc+0xa7>
801093dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093e1:	e9 ca 00 00 00       	jmp    801094b0 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801093e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093ed:	66 3d 00 01          	cmp    $0x100,%ax
801093f1:	75 69                	jne    8010945c <arp_proc+0x11d>
801093f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f6:	83 c0 18             	add    $0x18,%eax
801093f9:	83 ec 04             	sub    $0x4,%esp
801093fc:	6a 04                	push   $0x4
801093fe:	50                   	push   %eax
801093ff:	68 e4 f4 10 80       	push   $0x8010f4e4
80109404:	e8 fb bb ff ff       	call   80105004 <memcmp>
80109409:	83 c4 10             	add    $0x10,%esp
8010940c:	85 c0                	test   %eax,%eax
8010940e:	75 4c                	jne    8010945c <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109410:	e8 65 98 ff ff       	call   80102c7a <kalloc>
80109415:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109418:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010941f:	83 ec 04             	sub    $0x4,%esp
80109422:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109425:	50                   	push   %eax
80109426:	ff 75 f0             	push   -0x10(%ebp)
80109429:	ff 75 f4             	push   -0xc(%ebp)
8010942c:	e8 1f 04 00 00       	call   80109850 <arp_reply_pkt_create>
80109431:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109434:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109437:	83 ec 08             	sub    $0x8,%esp
8010943a:	50                   	push   %eax
8010943b:	ff 75 f0             	push   -0x10(%ebp)
8010943e:	e8 d0 fd ff ff       	call   80109213 <i8254_send>
80109443:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109446:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109449:	83 ec 0c             	sub    $0xc,%esp
8010944c:	50                   	push   %eax
8010944d:	e8 8e 97 ff ff       	call   80102be0 <kfree>
80109452:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109455:	b8 02 00 00 00       	mov    $0x2,%eax
8010945a:	eb 54                	jmp    801094b0 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010945c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010945f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109463:	66 3d 00 02          	cmp    $0x200,%ax
80109467:	75 42                	jne    801094ab <arp_proc+0x16c>
80109469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010946c:	83 c0 18             	add    $0x18,%eax
8010946f:	83 ec 04             	sub    $0x4,%esp
80109472:	6a 04                	push   $0x4
80109474:	50                   	push   %eax
80109475:	68 e4 f4 10 80       	push   $0x8010f4e4
8010947a:	e8 85 bb ff ff       	call   80105004 <memcmp>
8010947f:	83 c4 10             	add    $0x10,%esp
80109482:	85 c0                	test   %eax,%eax
80109484:	75 25                	jne    801094ab <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109486:	83 ec 0c             	sub    $0xc,%esp
80109489:	68 1c c6 10 80       	push   $0x8010c61c
8010948e:	e8 61 6f ff ff       	call   801003f4 <cprintf>
80109493:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109496:	83 ec 0c             	sub    $0xc,%esp
80109499:	ff 75 f4             	push   -0xc(%ebp)
8010949c:	e8 af 01 00 00       	call   80109650 <arp_table_update>
801094a1:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801094a4:	b8 01 00 00 00       	mov    $0x1,%eax
801094a9:	eb 05                	jmp    801094b0 <arp_proc+0x171>
  }else{
    return -1;
801094ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801094b0:	c9                   	leave  
801094b1:	c3                   	ret    

801094b2 <arp_scan>:

void arp_scan(){
801094b2:	55                   	push   %ebp
801094b3:	89 e5                	mov    %esp,%ebp
801094b5:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801094b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801094bf:	eb 6f                	jmp    80109530 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801094c1:	e8 b4 97 ff ff       	call   80102c7a <kalloc>
801094c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801094c9:	83 ec 04             	sub    $0x4,%esp
801094cc:	ff 75 f4             	push   -0xc(%ebp)
801094cf:	8d 45 e8             	lea    -0x18(%ebp),%eax
801094d2:	50                   	push   %eax
801094d3:	ff 75 ec             	push   -0x14(%ebp)
801094d6:	e8 62 00 00 00       	call   8010953d <arp_broadcast>
801094db:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801094de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094e1:	83 ec 08             	sub    $0x8,%esp
801094e4:	50                   	push   %eax
801094e5:	ff 75 ec             	push   -0x14(%ebp)
801094e8:	e8 26 fd ff ff       	call   80109213 <i8254_send>
801094ed:	83 c4 10             	add    $0x10,%esp
801094f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094f3:	eb 22                	jmp    80109517 <arp_scan+0x65>
      microdelay(1);
801094f5:	83 ec 0c             	sub    $0xc,%esp
801094f8:	6a 01                	push   $0x1
801094fa:	e8 12 9b ff ff       	call   80103011 <microdelay>
801094ff:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109502:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109505:	83 ec 08             	sub    $0x8,%esp
80109508:	50                   	push   %eax
80109509:	ff 75 ec             	push   -0x14(%ebp)
8010950c:	e8 02 fd ff ff       	call   80109213 <i8254_send>
80109511:	83 c4 10             	add    $0x10,%esp
80109514:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109517:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010951b:	74 d8                	je     801094f5 <arp_scan+0x43>
    }
    kfree((char *)send);
8010951d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109520:	83 ec 0c             	sub    $0xc,%esp
80109523:	50                   	push   %eax
80109524:	e8 b7 96 ff ff       	call   80102be0 <kfree>
80109529:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010952c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109530:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109537:	7e 88                	jle    801094c1 <arp_scan+0xf>
  }
}
80109539:	90                   	nop
8010953a:	90                   	nop
8010953b:	c9                   	leave  
8010953c:	c3                   	ret    

8010953d <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010953d:	55                   	push   %ebp
8010953e:	89 e5                	mov    %esp,%ebp
80109540:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109543:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109547:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010954b:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010954f:	8b 45 10             	mov    0x10(%ebp),%eax
80109552:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109555:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010955c:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109562:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109569:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010956f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109572:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109578:	8b 45 08             	mov    0x8(%ebp),%eax
8010957b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010957e:	8b 45 08             	mov    0x8(%ebp),%eax
80109581:	83 c0 0e             	add    $0xe,%eax
80109584:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010958e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109591:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109598:	83 ec 04             	sub    $0x4,%esp
8010959b:	6a 06                	push   $0x6
8010959d:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801095a0:	52                   	push   %edx
801095a1:	50                   	push   %eax
801095a2:	e8 b5 ba ff ff       	call   8010505c <memmove>
801095a7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ad:	83 c0 06             	add    $0x6,%eax
801095b0:	83 ec 04             	sub    $0x4,%esp
801095b3:	6a 06                	push   $0x6
801095b5:	68 c0 9c 11 80       	push   $0x80119cc0
801095ba:	50                   	push   %eax
801095bb:	e8 9c ba ff ff       	call   8010505c <memmove>
801095c0:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801095c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c6:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801095cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ce:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801095d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d7:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801095db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095de:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801095e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e5:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801095eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ee:	8d 50 12             	lea    0x12(%eax),%edx
801095f1:	83 ec 04             	sub    $0x4,%esp
801095f4:	6a 06                	push   $0x6
801095f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801095f9:	50                   	push   %eax
801095fa:	52                   	push   %edx
801095fb:	e8 5c ba ff ff       	call   8010505c <memmove>
80109600:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109606:	8d 50 18             	lea    0x18(%eax),%edx
80109609:	83 ec 04             	sub    $0x4,%esp
8010960c:	6a 04                	push   $0x4
8010960e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109611:	50                   	push   %eax
80109612:	52                   	push   %edx
80109613:	e8 44 ba ff ff       	call   8010505c <memmove>
80109618:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010961b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961e:	83 c0 08             	add    $0x8,%eax
80109621:	83 ec 04             	sub    $0x4,%esp
80109624:	6a 06                	push   $0x6
80109626:	68 c0 9c 11 80       	push   $0x80119cc0
8010962b:	50                   	push   %eax
8010962c:	e8 2b ba ff ff       	call   8010505c <memmove>
80109631:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109637:	83 c0 0e             	add    $0xe,%eax
8010963a:	83 ec 04             	sub    $0x4,%esp
8010963d:	6a 04                	push   $0x4
8010963f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109644:	50                   	push   %eax
80109645:	e8 12 ba ff ff       	call   8010505c <memmove>
8010964a:	83 c4 10             	add    $0x10,%esp
}
8010964d:	90                   	nop
8010964e:	c9                   	leave  
8010964f:	c3                   	ret    

80109650 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109650:	55                   	push   %ebp
80109651:	89 e5                	mov    %esp,%ebp
80109653:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109656:	8b 45 08             	mov    0x8(%ebp),%eax
80109659:	83 c0 0e             	add    $0xe,%eax
8010965c:	83 ec 0c             	sub    $0xc,%esp
8010965f:	50                   	push   %eax
80109660:	e8 bc 00 00 00       	call   80109721 <arp_table_search>
80109665:	83 c4 10             	add    $0x10,%esp
80109668:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010966b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010966f:	78 2d                	js     8010969e <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109671:	8b 45 08             	mov    0x8(%ebp),%eax
80109674:	8d 48 08             	lea    0x8(%eax),%ecx
80109677:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010967a:	89 d0                	mov    %edx,%eax
8010967c:	c1 e0 02             	shl    $0x2,%eax
8010967f:	01 d0                	add    %edx,%eax
80109681:	01 c0                	add    %eax,%eax
80109683:	01 d0                	add    %edx,%eax
80109685:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010968a:	83 c0 04             	add    $0x4,%eax
8010968d:	83 ec 04             	sub    $0x4,%esp
80109690:	6a 06                	push   $0x6
80109692:	51                   	push   %ecx
80109693:	50                   	push   %eax
80109694:	e8 c3 b9 ff ff       	call   8010505c <memmove>
80109699:	83 c4 10             	add    $0x10,%esp
8010969c:	eb 70                	jmp    8010970e <arp_table_update+0xbe>
  }else{
    index += 1;
8010969e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801096a2:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801096a5:	8b 45 08             	mov    0x8(%ebp),%eax
801096a8:	8d 48 08             	lea    0x8(%eax),%ecx
801096ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096ae:	89 d0                	mov    %edx,%eax
801096b0:	c1 e0 02             	shl    $0x2,%eax
801096b3:	01 d0                	add    %edx,%eax
801096b5:	01 c0                	add    %eax,%eax
801096b7:	01 d0                	add    %edx,%eax
801096b9:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801096be:	83 c0 04             	add    $0x4,%eax
801096c1:	83 ec 04             	sub    $0x4,%esp
801096c4:	6a 06                	push   $0x6
801096c6:	51                   	push   %ecx
801096c7:	50                   	push   %eax
801096c8:	e8 8f b9 ff ff       	call   8010505c <memmove>
801096cd:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801096d0:	8b 45 08             	mov    0x8(%ebp),%eax
801096d3:	8d 48 0e             	lea    0xe(%eax),%ecx
801096d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096d9:	89 d0                	mov    %edx,%eax
801096db:	c1 e0 02             	shl    $0x2,%eax
801096de:	01 d0                	add    %edx,%eax
801096e0:	01 c0                	add    %eax,%eax
801096e2:	01 d0                	add    %edx,%eax
801096e4:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801096e9:	83 ec 04             	sub    $0x4,%esp
801096ec:	6a 04                	push   $0x4
801096ee:	51                   	push   %ecx
801096ef:	50                   	push   %eax
801096f0:	e8 67 b9 ff ff       	call   8010505c <memmove>
801096f5:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801096f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096fb:	89 d0                	mov    %edx,%eax
801096fd:	c1 e0 02             	shl    $0x2,%eax
80109700:	01 d0                	add    %edx,%eax
80109702:	01 c0                	add    %eax,%eax
80109704:	01 d0                	add    %edx,%eax
80109706:	05 ea 9c 11 80       	add    $0x80119cea,%eax
8010970b:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010970e:	83 ec 0c             	sub    $0xc,%esp
80109711:	68 e0 9c 11 80       	push   $0x80119ce0
80109716:	e8 83 00 00 00       	call   8010979e <print_arp_table>
8010971b:	83 c4 10             	add    $0x10,%esp
}
8010971e:	90                   	nop
8010971f:	c9                   	leave  
80109720:	c3                   	ret    

80109721 <arp_table_search>:

int arp_table_search(uchar *ip){
80109721:	55                   	push   %ebp
80109722:	89 e5                	mov    %esp,%ebp
80109724:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109727:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010972e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109735:	eb 59                	jmp    80109790 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109737:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010973a:	89 d0                	mov    %edx,%eax
8010973c:	c1 e0 02             	shl    $0x2,%eax
8010973f:	01 d0                	add    %edx,%eax
80109741:	01 c0                	add    %eax,%eax
80109743:	01 d0                	add    %edx,%eax
80109745:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010974a:	83 ec 04             	sub    $0x4,%esp
8010974d:	6a 04                	push   $0x4
8010974f:	ff 75 08             	push   0x8(%ebp)
80109752:	50                   	push   %eax
80109753:	e8 ac b8 ff ff       	call   80105004 <memcmp>
80109758:	83 c4 10             	add    $0x10,%esp
8010975b:	85 c0                	test   %eax,%eax
8010975d:	75 05                	jne    80109764 <arp_table_search+0x43>
      return i;
8010975f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109762:	eb 38                	jmp    8010979c <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109764:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109767:	89 d0                	mov    %edx,%eax
80109769:	c1 e0 02             	shl    $0x2,%eax
8010976c:	01 d0                	add    %edx,%eax
8010976e:	01 c0                	add    %eax,%eax
80109770:	01 d0                	add    %edx,%eax
80109772:	05 ea 9c 11 80       	add    $0x80119cea,%eax
80109777:	0f b6 00             	movzbl (%eax),%eax
8010977a:	84 c0                	test   %al,%al
8010977c:	75 0e                	jne    8010978c <arp_table_search+0x6b>
8010977e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109782:	75 08                	jne    8010978c <arp_table_search+0x6b>
      empty = -i;
80109784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109787:	f7 d8                	neg    %eax
80109789:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010978c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109790:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109794:	7e a1                	jle    80109737 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109799:	83 e8 01             	sub    $0x1,%eax
}
8010979c:	c9                   	leave  
8010979d:	c3                   	ret    

8010979e <print_arp_table>:

void print_arp_table(){
8010979e:	55                   	push   %ebp
8010979f:	89 e5                	mov    %esp,%ebp
801097a1:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801097ab:	e9 92 00 00 00       	jmp    80109842 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801097b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097b3:	89 d0                	mov    %edx,%eax
801097b5:	c1 e0 02             	shl    $0x2,%eax
801097b8:	01 d0                	add    %edx,%eax
801097ba:	01 c0                	add    %eax,%eax
801097bc:	01 d0                	add    %edx,%eax
801097be:	05 ea 9c 11 80       	add    $0x80119cea,%eax
801097c3:	0f b6 00             	movzbl (%eax),%eax
801097c6:	84 c0                	test   %al,%al
801097c8:	74 74                	je     8010983e <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801097ca:	83 ec 08             	sub    $0x8,%esp
801097cd:	ff 75 f4             	push   -0xc(%ebp)
801097d0:	68 2f c6 10 80       	push   $0x8010c62f
801097d5:	e8 1a 6c ff ff       	call   801003f4 <cprintf>
801097da:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801097dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097e0:	89 d0                	mov    %edx,%eax
801097e2:	c1 e0 02             	shl    $0x2,%eax
801097e5:	01 d0                	add    %edx,%eax
801097e7:	01 c0                	add    %eax,%eax
801097e9:	01 d0                	add    %edx,%eax
801097eb:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801097f0:	83 ec 0c             	sub    $0xc,%esp
801097f3:	50                   	push   %eax
801097f4:	e8 54 02 00 00       	call   80109a4d <print_ipv4>
801097f9:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801097fc:	83 ec 0c             	sub    $0xc,%esp
801097ff:	68 3e c6 10 80       	push   $0x8010c63e
80109804:	e8 eb 6b ff ff       	call   801003f4 <cprintf>
80109809:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010980c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010980f:	89 d0                	mov    %edx,%eax
80109811:	c1 e0 02             	shl    $0x2,%eax
80109814:	01 d0                	add    %edx,%eax
80109816:	01 c0                	add    %eax,%eax
80109818:	01 d0                	add    %edx,%eax
8010981a:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010981f:	83 c0 04             	add    $0x4,%eax
80109822:	83 ec 0c             	sub    $0xc,%esp
80109825:	50                   	push   %eax
80109826:	e8 70 02 00 00       	call   80109a9b <print_mac>
8010982b:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010982e:	83 ec 0c             	sub    $0xc,%esp
80109831:	68 40 c6 10 80       	push   $0x8010c640
80109836:	e8 b9 6b ff ff       	call   801003f4 <cprintf>
8010983b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010983e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109842:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109846:	0f 8e 64 ff ff ff    	jle    801097b0 <print_arp_table+0x12>
    }
  }
}
8010984c:	90                   	nop
8010984d:	90                   	nop
8010984e:	c9                   	leave  
8010984f:	c3                   	ret    

80109850 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109850:	55                   	push   %ebp
80109851:	89 e5                	mov    %esp,%ebp
80109853:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109856:	8b 45 10             	mov    0x10(%ebp),%eax
80109859:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010985f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109862:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109865:	8b 45 0c             	mov    0xc(%ebp),%eax
80109868:	83 c0 0e             	add    $0xe,%eax
8010986b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010986e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109871:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109878:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010987c:	8b 45 08             	mov    0x8(%ebp),%eax
8010987f:	8d 50 08             	lea    0x8(%eax),%edx
80109882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109885:	83 ec 04             	sub    $0x4,%esp
80109888:	6a 06                	push   $0x6
8010988a:	52                   	push   %edx
8010988b:	50                   	push   %eax
8010988c:	e8 cb b7 ff ff       	call   8010505c <memmove>
80109891:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109897:	83 c0 06             	add    $0x6,%eax
8010989a:	83 ec 04             	sub    $0x4,%esp
8010989d:	6a 06                	push   $0x6
8010989f:	68 c0 9c 11 80       	push   $0x80119cc0
801098a4:	50                   	push   %eax
801098a5:	e8 b2 b7 ff ff       	call   8010505c <memmove>
801098aa:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801098ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b0:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801098b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b8:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801098be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c1:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801098c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c8:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801098cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098cf:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801098d5:	8b 45 08             	mov    0x8(%ebp),%eax
801098d8:	8d 50 08             	lea    0x8(%eax),%edx
801098db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098de:	83 c0 12             	add    $0x12,%eax
801098e1:	83 ec 04             	sub    $0x4,%esp
801098e4:	6a 06                	push   $0x6
801098e6:	52                   	push   %edx
801098e7:	50                   	push   %eax
801098e8:	e8 6f b7 ff ff       	call   8010505c <memmove>
801098ed:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801098f0:	8b 45 08             	mov    0x8(%ebp),%eax
801098f3:	8d 50 0e             	lea    0xe(%eax),%edx
801098f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f9:	83 c0 18             	add    $0x18,%eax
801098fc:	83 ec 04             	sub    $0x4,%esp
801098ff:	6a 04                	push   $0x4
80109901:	52                   	push   %edx
80109902:	50                   	push   %eax
80109903:	e8 54 b7 ff ff       	call   8010505c <memmove>
80109908:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010990b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990e:	83 c0 08             	add    $0x8,%eax
80109911:	83 ec 04             	sub    $0x4,%esp
80109914:	6a 06                	push   $0x6
80109916:	68 c0 9c 11 80       	push   $0x80119cc0
8010991b:	50                   	push   %eax
8010991c:	e8 3b b7 ff ff       	call   8010505c <memmove>
80109921:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109927:	83 c0 0e             	add    $0xe,%eax
8010992a:	83 ec 04             	sub    $0x4,%esp
8010992d:	6a 04                	push   $0x4
8010992f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109934:	50                   	push   %eax
80109935:	e8 22 b7 ff ff       	call   8010505c <memmove>
8010993a:	83 c4 10             	add    $0x10,%esp
}
8010993d:	90                   	nop
8010993e:	c9                   	leave  
8010993f:	c3                   	ret    

80109940 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109940:	55                   	push   %ebp
80109941:	89 e5                	mov    %esp,%ebp
80109943:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109946:	83 ec 0c             	sub    $0xc,%esp
80109949:	68 42 c6 10 80       	push   $0x8010c642
8010994e:	e8 a1 6a ff ff       	call   801003f4 <cprintf>
80109953:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109956:	8b 45 08             	mov    0x8(%ebp),%eax
80109959:	83 c0 0e             	add    $0xe,%eax
8010995c:	83 ec 0c             	sub    $0xc,%esp
8010995f:	50                   	push   %eax
80109960:	e8 e8 00 00 00       	call   80109a4d <print_ipv4>
80109965:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109968:	83 ec 0c             	sub    $0xc,%esp
8010996b:	68 40 c6 10 80       	push   $0x8010c640
80109970:	e8 7f 6a ff ff       	call   801003f4 <cprintf>
80109975:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109978:	8b 45 08             	mov    0x8(%ebp),%eax
8010997b:	83 c0 08             	add    $0x8,%eax
8010997e:	83 ec 0c             	sub    $0xc,%esp
80109981:	50                   	push   %eax
80109982:	e8 14 01 00 00       	call   80109a9b <print_mac>
80109987:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010998a:	83 ec 0c             	sub    $0xc,%esp
8010998d:	68 40 c6 10 80       	push   $0x8010c640
80109992:	e8 5d 6a ff ff       	call   801003f4 <cprintf>
80109997:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010999a:	83 ec 0c             	sub    $0xc,%esp
8010999d:	68 59 c6 10 80       	push   $0x8010c659
801099a2:	e8 4d 6a ff ff       	call   801003f4 <cprintf>
801099a7:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801099aa:	8b 45 08             	mov    0x8(%ebp),%eax
801099ad:	83 c0 18             	add    $0x18,%eax
801099b0:	83 ec 0c             	sub    $0xc,%esp
801099b3:	50                   	push   %eax
801099b4:	e8 94 00 00 00       	call   80109a4d <print_ipv4>
801099b9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099bc:	83 ec 0c             	sub    $0xc,%esp
801099bf:	68 40 c6 10 80       	push   $0x8010c640
801099c4:	e8 2b 6a ff ff       	call   801003f4 <cprintf>
801099c9:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801099cc:	8b 45 08             	mov    0x8(%ebp),%eax
801099cf:	83 c0 12             	add    $0x12,%eax
801099d2:	83 ec 0c             	sub    $0xc,%esp
801099d5:	50                   	push   %eax
801099d6:	e8 c0 00 00 00       	call   80109a9b <print_mac>
801099db:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099de:	83 ec 0c             	sub    $0xc,%esp
801099e1:	68 40 c6 10 80       	push   $0x8010c640
801099e6:	e8 09 6a ff ff       	call   801003f4 <cprintf>
801099eb:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801099ee:	83 ec 0c             	sub    $0xc,%esp
801099f1:	68 70 c6 10 80       	push   $0x8010c670
801099f6:	e8 f9 69 ff ff       	call   801003f4 <cprintf>
801099fb:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801099fe:	8b 45 08             	mov    0x8(%ebp),%eax
80109a01:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a05:	66 3d 00 01          	cmp    $0x100,%ax
80109a09:	75 12                	jne    80109a1d <print_arp_info+0xdd>
80109a0b:	83 ec 0c             	sub    $0xc,%esp
80109a0e:	68 7c c6 10 80       	push   $0x8010c67c
80109a13:	e8 dc 69 ff ff       	call   801003f4 <cprintf>
80109a18:	83 c4 10             	add    $0x10,%esp
80109a1b:	eb 1d                	jmp    80109a3a <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a20:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a24:	66 3d 00 02          	cmp    $0x200,%ax
80109a28:	75 10                	jne    80109a3a <print_arp_info+0xfa>
    cprintf("Reply\n");
80109a2a:	83 ec 0c             	sub    $0xc,%esp
80109a2d:	68 85 c6 10 80       	push   $0x8010c685
80109a32:	e8 bd 69 ff ff       	call   801003f4 <cprintf>
80109a37:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109a3a:	83 ec 0c             	sub    $0xc,%esp
80109a3d:	68 40 c6 10 80       	push   $0x8010c640
80109a42:	e8 ad 69 ff ff       	call   801003f4 <cprintf>
80109a47:	83 c4 10             	add    $0x10,%esp
}
80109a4a:	90                   	nop
80109a4b:	c9                   	leave  
80109a4c:	c3                   	ret    

80109a4d <print_ipv4>:

void print_ipv4(uchar *ip){
80109a4d:	55                   	push   %ebp
80109a4e:	89 e5                	mov    %esp,%ebp
80109a50:	53                   	push   %ebx
80109a51:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109a54:	8b 45 08             	mov    0x8(%ebp),%eax
80109a57:	83 c0 03             	add    $0x3,%eax
80109a5a:	0f b6 00             	movzbl (%eax),%eax
80109a5d:	0f b6 d8             	movzbl %al,%ebx
80109a60:	8b 45 08             	mov    0x8(%ebp),%eax
80109a63:	83 c0 02             	add    $0x2,%eax
80109a66:	0f b6 00             	movzbl (%eax),%eax
80109a69:	0f b6 c8             	movzbl %al,%ecx
80109a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6f:	83 c0 01             	add    $0x1,%eax
80109a72:	0f b6 00             	movzbl (%eax),%eax
80109a75:	0f b6 d0             	movzbl %al,%edx
80109a78:	8b 45 08             	mov    0x8(%ebp),%eax
80109a7b:	0f b6 00             	movzbl (%eax),%eax
80109a7e:	0f b6 c0             	movzbl %al,%eax
80109a81:	83 ec 0c             	sub    $0xc,%esp
80109a84:	53                   	push   %ebx
80109a85:	51                   	push   %ecx
80109a86:	52                   	push   %edx
80109a87:	50                   	push   %eax
80109a88:	68 8c c6 10 80       	push   $0x8010c68c
80109a8d:	e8 62 69 ff ff       	call   801003f4 <cprintf>
80109a92:	83 c4 20             	add    $0x20,%esp
}
80109a95:	90                   	nop
80109a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a99:	c9                   	leave  
80109a9a:	c3                   	ret    

80109a9b <print_mac>:

void print_mac(uchar *mac){
80109a9b:	55                   	push   %ebp
80109a9c:	89 e5                	mov    %esp,%ebp
80109a9e:	57                   	push   %edi
80109a9f:	56                   	push   %esi
80109aa0:	53                   	push   %ebx
80109aa1:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa7:	83 c0 05             	add    $0x5,%eax
80109aaa:	0f b6 00             	movzbl (%eax),%eax
80109aad:	0f b6 f8             	movzbl %al,%edi
80109ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab3:	83 c0 04             	add    $0x4,%eax
80109ab6:	0f b6 00             	movzbl (%eax),%eax
80109ab9:	0f b6 f0             	movzbl %al,%esi
80109abc:	8b 45 08             	mov    0x8(%ebp),%eax
80109abf:	83 c0 03             	add    $0x3,%eax
80109ac2:	0f b6 00             	movzbl (%eax),%eax
80109ac5:	0f b6 d8             	movzbl %al,%ebx
80109ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80109acb:	83 c0 02             	add    $0x2,%eax
80109ace:	0f b6 00             	movzbl (%eax),%eax
80109ad1:	0f b6 c8             	movzbl %al,%ecx
80109ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad7:	83 c0 01             	add    $0x1,%eax
80109ada:	0f b6 00             	movzbl (%eax),%eax
80109add:	0f b6 d0             	movzbl %al,%edx
80109ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae3:	0f b6 00             	movzbl (%eax),%eax
80109ae6:	0f b6 c0             	movzbl %al,%eax
80109ae9:	83 ec 04             	sub    $0x4,%esp
80109aec:	57                   	push   %edi
80109aed:	56                   	push   %esi
80109aee:	53                   	push   %ebx
80109aef:	51                   	push   %ecx
80109af0:	52                   	push   %edx
80109af1:	50                   	push   %eax
80109af2:	68 a4 c6 10 80       	push   $0x8010c6a4
80109af7:	e8 f8 68 ff ff       	call   801003f4 <cprintf>
80109afc:	83 c4 20             	add    $0x20,%esp
}
80109aff:	90                   	nop
80109b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109b03:	5b                   	pop    %ebx
80109b04:	5e                   	pop    %esi
80109b05:	5f                   	pop    %edi
80109b06:	5d                   	pop    %ebp
80109b07:	c3                   	ret    

80109b08 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109b08:	55                   	push   %ebp
80109b09:	89 e5                	mov    %esp,%ebp
80109b0b:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109b14:	8b 45 08             	mov    0x8(%ebp),%eax
80109b17:	83 c0 0e             	add    $0xe,%eax
80109b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b20:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b24:	3c 08                	cmp    $0x8,%al
80109b26:	75 1b                	jne    80109b43 <eth_proc+0x3b>
80109b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b2b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b2f:	3c 06                	cmp    $0x6,%al
80109b31:	75 10                	jne    80109b43 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109b33:	83 ec 0c             	sub    $0xc,%esp
80109b36:	ff 75 f0             	push   -0x10(%ebp)
80109b39:	e8 01 f8 ff ff       	call   8010933f <arp_proc>
80109b3e:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109b41:	eb 24                	jmp    80109b67 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b46:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b4a:	3c 08                	cmp    $0x8,%al
80109b4c:	75 19                	jne    80109b67 <eth_proc+0x5f>
80109b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b51:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b55:	84 c0                	test   %al,%al
80109b57:	75 0e                	jne    80109b67 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109b59:	83 ec 0c             	sub    $0xc,%esp
80109b5c:	ff 75 08             	push   0x8(%ebp)
80109b5f:	e8 a3 00 00 00       	call   80109c07 <ipv4_proc>
80109b64:	83 c4 10             	add    $0x10,%esp
}
80109b67:	90                   	nop
80109b68:	c9                   	leave  
80109b69:	c3                   	ret    

80109b6a <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b6a:	55                   	push   %ebp
80109b6b:	89 e5                	mov    %esp,%ebp
80109b6d:	83 ec 04             	sub    $0x4,%esp
80109b70:	8b 45 08             	mov    0x8(%ebp),%eax
80109b73:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b77:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b7b:	c1 e0 08             	shl    $0x8,%eax
80109b7e:	89 c2                	mov    %eax,%edx
80109b80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b84:	66 c1 e8 08          	shr    $0x8,%ax
80109b88:	01 d0                	add    %edx,%eax
}
80109b8a:	c9                   	leave  
80109b8b:	c3                   	ret    

80109b8c <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b8c:	55                   	push   %ebp
80109b8d:	89 e5                	mov    %esp,%ebp
80109b8f:	83 ec 04             	sub    $0x4,%esp
80109b92:	8b 45 08             	mov    0x8(%ebp),%eax
80109b95:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b99:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b9d:	c1 e0 08             	shl    $0x8,%eax
80109ba0:	89 c2                	mov    %eax,%edx
80109ba2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ba6:	66 c1 e8 08          	shr    $0x8,%ax
80109baa:	01 d0                	add    %edx,%eax
}
80109bac:	c9                   	leave  
80109bad:	c3                   	ret    

80109bae <H2N_uint>:

uint H2N_uint(uint value){
80109bae:	55                   	push   %ebp
80109baf:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb4:	c1 e0 18             	shl    $0x18,%eax
80109bb7:	25 00 00 00 0f       	and    $0xf000000,%eax
80109bbc:	89 c2                	mov    %eax,%edx
80109bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc1:	c1 e0 08             	shl    $0x8,%eax
80109bc4:	25 00 f0 00 00       	and    $0xf000,%eax
80109bc9:	09 c2                	or     %eax,%edx
80109bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80109bce:	c1 e8 08             	shr    $0x8,%eax
80109bd1:	83 e0 0f             	and    $0xf,%eax
80109bd4:	01 d0                	add    %edx,%eax
}
80109bd6:	5d                   	pop    %ebp
80109bd7:	c3                   	ret    

80109bd8 <N2H_uint>:

uint N2H_uint(uint value){
80109bd8:	55                   	push   %ebp
80109bd9:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80109bde:	c1 e0 18             	shl    $0x18,%eax
80109be1:	89 c2                	mov    %eax,%edx
80109be3:	8b 45 08             	mov    0x8(%ebp),%eax
80109be6:	c1 e0 08             	shl    $0x8,%eax
80109be9:	25 00 00 ff 00       	and    $0xff0000,%eax
80109bee:	01 c2                	add    %eax,%edx
80109bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf3:	c1 e8 08             	shr    $0x8,%eax
80109bf6:	25 00 ff 00 00       	and    $0xff00,%eax
80109bfb:	01 c2                	add    %eax,%edx
80109bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80109c00:	c1 e8 18             	shr    $0x18,%eax
80109c03:	01 d0                	add    %edx,%eax
}
80109c05:	5d                   	pop    %ebp
80109c06:	c3                   	ret    

80109c07 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109c07:	55                   	push   %ebp
80109c08:	89 e5                	mov    %esp,%ebp
80109c0a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c10:	83 c0 0e             	add    $0xe,%eax
80109c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c19:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c1d:	0f b7 d0             	movzwl %ax,%edx
80109c20:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109c25:	39 c2                	cmp    %eax,%edx
80109c27:	74 60                	je     80109c89 <ipv4_proc+0x82>
80109c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2c:	83 c0 0c             	add    $0xc,%eax
80109c2f:	83 ec 04             	sub    $0x4,%esp
80109c32:	6a 04                	push   $0x4
80109c34:	50                   	push   %eax
80109c35:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c3a:	e8 c5 b3 ff ff       	call   80105004 <memcmp>
80109c3f:	83 c4 10             	add    $0x10,%esp
80109c42:	85 c0                	test   %eax,%eax
80109c44:	74 43                	je     80109c89 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c49:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c4d:	0f b7 c0             	movzwl %ax,%eax
80109c50:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c58:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c5c:	3c 01                	cmp    $0x1,%al
80109c5e:	75 10                	jne    80109c70 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109c60:	83 ec 0c             	sub    $0xc,%esp
80109c63:	ff 75 08             	push   0x8(%ebp)
80109c66:	e8 a3 00 00 00       	call   80109d0e <icmp_proc>
80109c6b:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c6e:	eb 19                	jmp    80109c89 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c73:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c77:	3c 06                	cmp    $0x6,%al
80109c79:	75 0e                	jne    80109c89 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109c7b:	83 ec 0c             	sub    $0xc,%esp
80109c7e:	ff 75 08             	push   0x8(%ebp)
80109c81:	e8 b3 03 00 00       	call   8010a039 <tcp_proc>
80109c86:	83 c4 10             	add    $0x10,%esp
}
80109c89:	90                   	nop
80109c8a:	c9                   	leave  
80109c8b:	c3                   	ret    

80109c8c <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c8c:	55                   	push   %ebp
80109c8d:	89 e5                	mov    %esp,%ebp
80109c8f:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c92:	8b 45 08             	mov    0x8(%ebp),%eax
80109c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9b:	0f b6 00             	movzbl (%eax),%eax
80109c9e:	83 e0 0f             	and    $0xf,%eax
80109ca1:	01 c0                	add    %eax,%eax
80109ca3:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109ca6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cad:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109cb4:	eb 48                	jmp    80109cfe <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109cb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cb9:	01 c0                	add    %eax,%eax
80109cbb:	89 c2                	mov    %eax,%edx
80109cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc0:	01 d0                	add    %edx,%eax
80109cc2:	0f b6 00             	movzbl (%eax),%eax
80109cc5:	0f b6 c0             	movzbl %al,%eax
80109cc8:	c1 e0 08             	shl    $0x8,%eax
80109ccb:	89 c2                	mov    %eax,%edx
80109ccd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109cd0:	01 c0                	add    %eax,%eax
80109cd2:	8d 48 01             	lea    0x1(%eax),%ecx
80109cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cd8:	01 c8                	add    %ecx,%eax
80109cda:	0f b6 00             	movzbl (%eax),%eax
80109cdd:	0f b6 c0             	movzbl %al,%eax
80109ce0:	01 d0                	add    %edx,%eax
80109ce2:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ce5:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109cec:	76 0c                	jbe    80109cfa <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109cee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109cf1:	0f b7 c0             	movzwl %ax,%eax
80109cf4:	83 c0 01             	add    $0x1,%eax
80109cf7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109cfa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109cfe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109d02:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109d05:	7c af                	jl     80109cb6 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109d07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d0a:	f7 d0                	not    %eax
}
80109d0c:	c9                   	leave  
80109d0d:	c3                   	ret    

80109d0e <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109d0e:	55                   	push   %ebp
80109d0f:	89 e5                	mov    %esp,%ebp
80109d11:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109d14:	8b 45 08             	mov    0x8(%ebp),%eax
80109d17:	83 c0 0e             	add    $0xe,%eax
80109d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d20:	0f b6 00             	movzbl (%eax),%eax
80109d23:	0f b6 c0             	movzbl %al,%eax
80109d26:	83 e0 0f             	and    $0xf,%eax
80109d29:	c1 e0 02             	shl    $0x2,%eax
80109d2c:	89 c2                	mov    %eax,%edx
80109d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d31:	01 d0                	add    %edx,%eax
80109d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d39:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109d3d:	84 c0                	test   %al,%al
80109d3f:	75 4f                	jne    80109d90 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d44:	0f b6 00             	movzbl (%eax),%eax
80109d47:	3c 08                	cmp    $0x8,%al
80109d49:	75 45                	jne    80109d90 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109d4b:	e8 2a 8f ff ff       	call   80102c7a <kalloc>
80109d50:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109d53:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109d5a:	83 ec 04             	sub    $0x4,%esp
80109d5d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109d60:	50                   	push   %eax
80109d61:	ff 75 ec             	push   -0x14(%ebp)
80109d64:	ff 75 08             	push   0x8(%ebp)
80109d67:	e8 78 00 00 00       	call   80109de4 <icmp_reply_pkt_create>
80109d6c:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d72:	83 ec 08             	sub    $0x8,%esp
80109d75:	50                   	push   %eax
80109d76:	ff 75 ec             	push   -0x14(%ebp)
80109d79:	e8 95 f4 ff ff       	call   80109213 <i8254_send>
80109d7e:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d84:	83 ec 0c             	sub    $0xc,%esp
80109d87:	50                   	push   %eax
80109d88:	e8 53 8e ff ff       	call   80102be0 <kfree>
80109d8d:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d90:	90                   	nop
80109d91:	c9                   	leave  
80109d92:	c3                   	ret    

80109d93 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d93:	55                   	push   %ebp
80109d94:	89 e5                	mov    %esp,%ebp
80109d96:	53                   	push   %ebx
80109d97:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d9d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109da1:	0f b7 c0             	movzwl %ax,%eax
80109da4:	83 ec 0c             	sub    $0xc,%esp
80109da7:	50                   	push   %eax
80109da8:	e8 bd fd ff ff       	call   80109b6a <N2H_ushort>
80109dad:	83 c4 10             	add    $0x10,%esp
80109db0:	0f b7 d8             	movzwl %ax,%ebx
80109db3:	8b 45 08             	mov    0x8(%ebp),%eax
80109db6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109dba:	0f b7 c0             	movzwl %ax,%eax
80109dbd:	83 ec 0c             	sub    $0xc,%esp
80109dc0:	50                   	push   %eax
80109dc1:	e8 a4 fd ff ff       	call   80109b6a <N2H_ushort>
80109dc6:	83 c4 10             	add    $0x10,%esp
80109dc9:	0f b7 c0             	movzwl %ax,%eax
80109dcc:	83 ec 04             	sub    $0x4,%esp
80109dcf:	53                   	push   %ebx
80109dd0:	50                   	push   %eax
80109dd1:	68 c3 c6 10 80       	push   $0x8010c6c3
80109dd6:	e8 19 66 ff ff       	call   801003f4 <cprintf>
80109ddb:	83 c4 10             	add    $0x10,%esp
}
80109dde:	90                   	nop
80109ddf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109de2:	c9                   	leave  
80109de3:	c3                   	ret    

80109de4 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109de4:	55                   	push   %ebp
80109de5:	89 e5                	mov    %esp,%ebp
80109de7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109dea:	8b 45 08             	mov    0x8(%ebp),%eax
80109ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109df0:	8b 45 08             	mov    0x8(%ebp),%eax
80109df3:	83 c0 0e             	add    $0xe,%eax
80109df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dfc:	0f b6 00             	movzbl (%eax),%eax
80109dff:	0f b6 c0             	movzbl %al,%eax
80109e02:	83 e0 0f             	and    $0xf,%eax
80109e05:	c1 e0 02             	shl    $0x2,%eax
80109e08:	89 c2                	mov    %eax,%edx
80109e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e0d:	01 d0                	add    %edx,%eax
80109e0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e12:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e15:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e1b:	83 c0 0e             	add    $0xe,%eax
80109e1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e24:	83 c0 14             	add    $0x14,%eax
80109e27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109e2a:	8b 45 10             	mov    0x10(%ebp),%eax
80109e2d:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e36:	8d 50 06             	lea    0x6(%eax),%edx
80109e39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e3c:	83 ec 04             	sub    $0x4,%esp
80109e3f:	6a 06                	push   $0x6
80109e41:	52                   	push   %edx
80109e42:	50                   	push   %eax
80109e43:	e8 14 b2 ff ff       	call   8010505c <memmove>
80109e48:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e4e:	83 c0 06             	add    $0x6,%eax
80109e51:	83 ec 04             	sub    $0x4,%esp
80109e54:	6a 06                	push   $0x6
80109e56:	68 c0 9c 11 80       	push   $0x80119cc0
80109e5b:	50                   	push   %eax
80109e5c:	e8 fb b1 ff ff       	call   8010505c <memmove>
80109e61:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e67:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e6e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e75:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e7b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e7f:	83 ec 0c             	sub    $0xc,%esp
80109e82:	6a 54                	push   $0x54
80109e84:	e8 03 fd ff ff       	call   80109b8c <H2N_ushort>
80109e89:	83 c4 10             	add    $0x10,%esp
80109e8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e8f:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e93:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
80109e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e9d:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ea1:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
80109ea8:	83 c0 01             	add    $0x1,%eax
80109eab:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109eb1:	83 ec 0c             	sub    $0xc,%esp
80109eb4:	68 00 40 00 00       	push   $0x4000
80109eb9:	e8 ce fc ff ff       	call   80109b8c <H2N_ushort>
80109ebe:	83 c4 10             	add    $0x10,%esp
80109ec1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ec4:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ecb:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed9:	83 c0 0c             	add    $0xc,%eax
80109edc:	83 ec 04             	sub    $0x4,%esp
80109edf:	6a 04                	push   $0x4
80109ee1:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ee6:	50                   	push   %eax
80109ee7:	e8 70 b1 ff ff       	call   8010505c <memmove>
80109eec:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef2:	8d 50 0c             	lea    0xc(%eax),%edx
80109ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ef8:	83 c0 10             	add    $0x10,%eax
80109efb:	83 ec 04             	sub    $0x4,%esp
80109efe:	6a 04                	push   $0x4
80109f00:	52                   	push   %edx
80109f01:	50                   	push   %eax
80109f02:	e8 55 b1 ff ff       	call   8010505c <memmove>
80109f07:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f0d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f16:	83 ec 0c             	sub    $0xc,%esp
80109f19:	50                   	push   %eax
80109f1a:	e8 6d fd ff ff       	call   80109c8c <ipv4_chksum>
80109f1f:	83 c4 10             	add    $0x10,%esp
80109f22:	0f b7 c0             	movzwl %ax,%eax
80109f25:	83 ec 0c             	sub    $0xc,%esp
80109f28:	50                   	push   %eax
80109f29:	e8 5e fc ff ff       	call   80109b8c <H2N_ushort>
80109f2e:	83 c4 10             	add    $0x10,%esp
80109f31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f34:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f3b:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109f3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f41:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f48:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f4f:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f56:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f5d:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f64:	8d 50 08             	lea    0x8(%eax),%edx
80109f67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f6a:	83 c0 08             	add    $0x8,%eax
80109f6d:	83 ec 04             	sub    $0x4,%esp
80109f70:	6a 08                	push   $0x8
80109f72:	52                   	push   %edx
80109f73:	50                   	push   %eax
80109f74:	e8 e3 b0 ff ff       	call   8010505c <memmove>
80109f79:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f7f:	8d 50 10             	lea    0x10(%eax),%edx
80109f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f85:	83 c0 10             	add    $0x10,%eax
80109f88:	83 ec 04             	sub    $0x4,%esp
80109f8b:	6a 30                	push   $0x30
80109f8d:	52                   	push   %edx
80109f8e:	50                   	push   %eax
80109f8f:	e8 c8 b0 ff ff       	call   8010505c <memmove>
80109f94:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f9a:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fa3:	83 ec 0c             	sub    $0xc,%esp
80109fa6:	50                   	push   %eax
80109fa7:	e8 1c 00 00 00       	call   80109fc8 <icmp_chksum>
80109fac:	83 c4 10             	add    $0x10,%esp
80109faf:	0f b7 c0             	movzwl %ax,%eax
80109fb2:	83 ec 0c             	sub    $0xc,%esp
80109fb5:	50                   	push   %eax
80109fb6:	e8 d1 fb ff ff       	call   80109b8c <H2N_ushort>
80109fbb:	83 c4 10             	add    $0x10,%esp
80109fbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fc1:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109fc5:	90                   	nop
80109fc6:	c9                   	leave  
80109fc7:	c3                   	ret    

80109fc8 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109fc8:	55                   	push   %ebp
80109fc9:	89 e5                	mov    %esp,%ebp
80109fcb:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109fce:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109fd4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fdb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109fe2:	eb 48                	jmp    8010a02c <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fe4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109fe7:	01 c0                	add    %eax,%eax
80109fe9:	89 c2                	mov    %eax,%edx
80109feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fee:	01 d0                	add    %edx,%eax
80109ff0:	0f b6 00             	movzbl (%eax),%eax
80109ff3:	0f b6 c0             	movzbl %al,%eax
80109ff6:	c1 e0 08             	shl    $0x8,%eax
80109ff9:	89 c2                	mov    %eax,%edx
80109ffb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ffe:	01 c0                	add    %eax,%eax
8010a000:	8d 48 01             	lea    0x1(%eax),%ecx
8010a003:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a006:	01 c8                	add    %ecx,%eax
8010a008:	0f b6 00             	movzbl (%eax),%eax
8010a00b:	0f b6 c0             	movzbl %al,%eax
8010a00e:	01 d0                	add    %edx,%eax
8010a010:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a013:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a01a:	76 0c                	jbe    8010a028 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a01c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a01f:	0f b7 c0             	movzwl %ax,%eax
8010a022:	83 c0 01             	add    $0x1,%eax
8010a025:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a028:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a02c:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a030:	7e b2                	jle    80109fe4 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a032:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a035:	f7 d0                	not    %eax
}
8010a037:	c9                   	leave  
8010a038:	c3                   	ret    

8010a039 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a039:	55                   	push   %ebp
8010a03a:	89 e5                	mov    %esp,%ebp
8010a03c:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a03f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a042:	83 c0 0e             	add    $0xe,%eax
8010a045:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a04b:	0f b6 00             	movzbl (%eax),%eax
8010a04e:	0f b6 c0             	movzbl %al,%eax
8010a051:	83 e0 0f             	and    $0xf,%eax
8010a054:	c1 e0 02             	shl    $0x2,%eax
8010a057:	89 c2                	mov    %eax,%edx
8010a059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a05c:	01 d0                	add    %edx,%eax
8010a05e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a061:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a064:	83 c0 14             	add    $0x14,%eax
8010a067:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a06a:	e8 0b 8c ff ff       	call   80102c7a <kalloc>
8010a06f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a072:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a07c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a080:	0f b6 c0             	movzbl %al,%eax
8010a083:	83 e0 02             	and    $0x2,%eax
8010a086:	85 c0                	test   %eax,%eax
8010a088:	74 3d                	je     8010a0c7 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a08a:	83 ec 0c             	sub    $0xc,%esp
8010a08d:	6a 00                	push   $0x0
8010a08f:	6a 12                	push   $0x12
8010a091:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a094:	50                   	push   %eax
8010a095:	ff 75 e8             	push   -0x18(%ebp)
8010a098:	ff 75 08             	push   0x8(%ebp)
8010a09b:	e8 a2 01 00 00       	call   8010a242 <tcp_pkt_create>
8010a0a0:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a0a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0a6:	83 ec 08             	sub    $0x8,%esp
8010a0a9:	50                   	push   %eax
8010a0aa:	ff 75 e8             	push   -0x18(%ebp)
8010a0ad:	e8 61 f1 ff ff       	call   80109213 <i8254_send>
8010a0b2:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a0b5:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a0ba:	83 c0 01             	add    $0x1,%eax
8010a0bd:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
8010a0c2:	e9 69 01 00 00       	jmp    8010a230 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a0c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ca:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0ce:	3c 18                	cmp    $0x18,%al
8010a0d0:	0f 85 10 01 00 00    	jne    8010a1e6 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a0d6:	83 ec 04             	sub    $0x4,%esp
8010a0d9:	6a 03                	push   $0x3
8010a0db:	68 de c6 10 80       	push   $0x8010c6de
8010a0e0:	ff 75 ec             	push   -0x14(%ebp)
8010a0e3:	e8 1c af ff ff       	call   80105004 <memcmp>
8010a0e8:	83 c4 10             	add    $0x10,%esp
8010a0eb:	85 c0                	test   %eax,%eax
8010a0ed:	74 74                	je     8010a163 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a0ef:	83 ec 0c             	sub    $0xc,%esp
8010a0f2:	68 e2 c6 10 80       	push   $0x8010c6e2
8010a0f7:	e8 f8 62 ff ff       	call   801003f4 <cprintf>
8010a0fc:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0ff:	83 ec 0c             	sub    $0xc,%esp
8010a102:	6a 00                	push   $0x0
8010a104:	6a 10                	push   $0x10
8010a106:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a109:	50                   	push   %eax
8010a10a:	ff 75 e8             	push   -0x18(%ebp)
8010a10d:	ff 75 08             	push   0x8(%ebp)
8010a110:	e8 2d 01 00 00       	call   8010a242 <tcp_pkt_create>
8010a115:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a118:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a11b:	83 ec 08             	sub    $0x8,%esp
8010a11e:	50                   	push   %eax
8010a11f:	ff 75 e8             	push   -0x18(%ebp)
8010a122:	e8 ec f0 ff ff       	call   80109213 <i8254_send>
8010a127:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a12a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a12d:	83 c0 36             	add    $0x36,%eax
8010a130:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a133:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a136:	50                   	push   %eax
8010a137:	ff 75 e0             	push   -0x20(%ebp)
8010a13a:	6a 00                	push   $0x0
8010a13c:	6a 00                	push   $0x0
8010a13e:	e8 5a 04 00 00       	call   8010a59d <http_proc>
8010a143:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a146:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a149:	83 ec 0c             	sub    $0xc,%esp
8010a14c:	50                   	push   %eax
8010a14d:	6a 18                	push   $0x18
8010a14f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a152:	50                   	push   %eax
8010a153:	ff 75 e8             	push   -0x18(%ebp)
8010a156:	ff 75 08             	push   0x8(%ebp)
8010a159:	e8 e4 00 00 00       	call   8010a242 <tcp_pkt_create>
8010a15e:	83 c4 20             	add    $0x20,%esp
8010a161:	eb 62                	jmp    8010a1c5 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a163:	83 ec 0c             	sub    $0xc,%esp
8010a166:	6a 00                	push   $0x0
8010a168:	6a 10                	push   $0x10
8010a16a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a16d:	50                   	push   %eax
8010a16e:	ff 75 e8             	push   -0x18(%ebp)
8010a171:	ff 75 08             	push   0x8(%ebp)
8010a174:	e8 c9 00 00 00       	call   8010a242 <tcp_pkt_create>
8010a179:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a17c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a17f:	83 ec 08             	sub    $0x8,%esp
8010a182:	50                   	push   %eax
8010a183:	ff 75 e8             	push   -0x18(%ebp)
8010a186:	e8 88 f0 ff ff       	call   80109213 <i8254_send>
8010a18b:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a18e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a191:	83 c0 36             	add    $0x36,%eax
8010a194:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a197:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a19a:	50                   	push   %eax
8010a19b:	ff 75 e4             	push   -0x1c(%ebp)
8010a19e:	6a 00                	push   $0x0
8010a1a0:	6a 00                	push   $0x0
8010a1a2:	e8 f6 03 00 00       	call   8010a59d <http_proc>
8010a1a7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a1aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a1ad:	83 ec 0c             	sub    $0xc,%esp
8010a1b0:	50                   	push   %eax
8010a1b1:	6a 18                	push   $0x18
8010a1b3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1b6:	50                   	push   %eax
8010a1b7:	ff 75 e8             	push   -0x18(%ebp)
8010a1ba:	ff 75 08             	push   0x8(%ebp)
8010a1bd:	e8 80 00 00 00       	call   8010a242 <tcp_pkt_create>
8010a1c2:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a1c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1c8:	83 ec 08             	sub    $0x8,%esp
8010a1cb:	50                   	push   %eax
8010a1cc:	ff 75 e8             	push   -0x18(%ebp)
8010a1cf:	e8 3f f0 ff ff       	call   80109213 <i8254_send>
8010a1d4:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1d7:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a1dc:	83 c0 01             	add    $0x1,%eax
8010a1df:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
8010a1e4:	eb 4a                	jmp    8010a230 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a1e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1e9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1ed:	3c 10                	cmp    $0x10,%al
8010a1ef:	75 3f                	jne    8010a230 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a1f1:	a1 a8 9f 11 80       	mov    0x80119fa8,%eax
8010a1f6:	83 f8 01             	cmp    $0x1,%eax
8010a1f9:	75 35                	jne    8010a230 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a1fb:	83 ec 0c             	sub    $0xc,%esp
8010a1fe:	6a 00                	push   $0x0
8010a200:	6a 01                	push   $0x1
8010a202:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a205:	50                   	push   %eax
8010a206:	ff 75 e8             	push   -0x18(%ebp)
8010a209:	ff 75 08             	push   0x8(%ebp)
8010a20c:	e8 31 00 00 00       	call   8010a242 <tcp_pkt_create>
8010a211:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a214:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a217:	83 ec 08             	sub    $0x8,%esp
8010a21a:	50                   	push   %eax
8010a21b:	ff 75 e8             	push   -0x18(%ebp)
8010a21e:	e8 f0 ef ff ff       	call   80109213 <i8254_send>
8010a223:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a226:	c7 05 a8 9f 11 80 00 	movl   $0x0,0x80119fa8
8010a22d:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a230:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a233:	83 ec 0c             	sub    $0xc,%esp
8010a236:	50                   	push   %eax
8010a237:	e8 a4 89 ff ff       	call   80102be0 <kfree>
8010a23c:	83 c4 10             	add    $0x10,%esp
}
8010a23f:	90                   	nop
8010a240:	c9                   	leave  
8010a241:	c3                   	ret    

8010a242 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a242:	55                   	push   %ebp
8010a243:	89 e5                	mov    %esp,%ebp
8010a245:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a248:	8b 45 08             	mov    0x8(%ebp),%eax
8010a24b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a24e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a251:	83 c0 0e             	add    $0xe,%eax
8010a254:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a257:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a25a:	0f b6 00             	movzbl (%eax),%eax
8010a25d:	0f b6 c0             	movzbl %al,%eax
8010a260:	83 e0 0f             	and    $0xf,%eax
8010a263:	c1 e0 02             	shl    $0x2,%eax
8010a266:	89 c2                	mov    %eax,%edx
8010a268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a26b:	01 d0                	add    %edx,%eax
8010a26d:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a270:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a273:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a276:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a279:	83 c0 0e             	add    $0xe,%eax
8010a27c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a27f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a282:	83 c0 14             	add    $0x14,%eax
8010a285:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a288:	8b 45 18             	mov    0x18(%ebp),%eax
8010a28b:	8d 50 36             	lea    0x36(%eax),%edx
8010a28e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a291:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a293:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a296:	8d 50 06             	lea    0x6(%eax),%edx
8010a299:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a29c:	83 ec 04             	sub    $0x4,%esp
8010a29f:	6a 06                	push   $0x6
8010a2a1:	52                   	push   %edx
8010a2a2:	50                   	push   %eax
8010a2a3:	e8 b4 ad ff ff       	call   8010505c <memmove>
8010a2a8:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ae:	83 c0 06             	add    $0x6,%eax
8010a2b1:	83 ec 04             	sub    $0x4,%esp
8010a2b4:	6a 06                	push   $0x6
8010a2b6:	68 c0 9c 11 80       	push   $0x80119cc0
8010a2bb:	50                   	push   %eax
8010a2bc:	e8 9b ad ff ff       	call   8010505c <memmove>
8010a2c1:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ce:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d5:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2db:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a2df:	8b 45 18             	mov    0x18(%ebp),%eax
8010a2e2:	83 c0 28             	add    $0x28,%eax
8010a2e5:	0f b7 c0             	movzwl %ax,%eax
8010a2e8:	83 ec 0c             	sub    $0xc,%esp
8010a2eb:	50                   	push   %eax
8010a2ec:	e8 9b f8 ff ff       	call   80109b8c <H2N_ushort>
8010a2f1:	83 c4 10             	add    $0x10,%esp
8010a2f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2f7:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2fb:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
8010a302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a305:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a309:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
8010a310:	83 c0 01             	add    $0x1,%eax
8010a313:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a319:	83 ec 0c             	sub    $0xc,%esp
8010a31c:	6a 00                	push   $0x0
8010a31e:	e8 69 f8 ff ff       	call   80109b8c <H2N_ushort>
8010a323:	83 c4 10             	add    $0x10,%esp
8010a326:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a329:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a32d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a330:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a334:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a337:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a33b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a33e:	83 c0 0c             	add    $0xc,%eax
8010a341:	83 ec 04             	sub    $0x4,%esp
8010a344:	6a 04                	push   $0x4
8010a346:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a34b:	50                   	push   %eax
8010a34c:	e8 0b ad ff ff       	call   8010505c <memmove>
8010a351:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a354:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a357:	8d 50 0c             	lea    0xc(%eax),%edx
8010a35a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a35d:	83 c0 10             	add    $0x10,%eax
8010a360:	83 ec 04             	sub    $0x4,%esp
8010a363:	6a 04                	push   $0x4
8010a365:	52                   	push   %edx
8010a366:	50                   	push   %eax
8010a367:	e8 f0 ac ff ff       	call   8010505c <memmove>
8010a36c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a36f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a372:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a37b:	83 ec 0c             	sub    $0xc,%esp
8010a37e:	50                   	push   %eax
8010a37f:	e8 08 f9 ff ff       	call   80109c8c <ipv4_chksum>
8010a384:	83 c4 10             	add    $0x10,%esp
8010a387:	0f b7 c0             	movzwl %ax,%eax
8010a38a:	83 ec 0c             	sub    $0xc,%esp
8010a38d:	50                   	push   %eax
8010a38e:	e8 f9 f7 ff ff       	call   80109b8c <H2N_ushort>
8010a393:	83 c4 10             	add    $0x10,%esp
8010a396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a399:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a39d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a3a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3a7:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a3aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3ad:	0f b7 10             	movzwl (%eax),%edx
8010a3b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b3:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a3b7:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a3bc:	83 ec 0c             	sub    $0xc,%esp
8010a3bf:	50                   	push   %eax
8010a3c0:	e8 e9 f7 ff ff       	call   80109bae <H2N_uint>
8010a3c5:	83 c4 10             	add    $0x10,%esp
8010a3c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3cb:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a3ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3d1:	8b 40 04             	mov    0x4(%eax),%eax
8010a3d4:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a3da:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3dd:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a3e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a3e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ea:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a3ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3f1:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a3f5:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3f8:	89 c2                	mov    %eax,%edx
8010a3fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fd:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a400:	83 ec 0c             	sub    $0xc,%esp
8010a403:	68 90 38 00 00       	push   $0x3890
8010a408:	e8 7f f7 ff ff       	call   80109b8c <H2N_ushort>
8010a40d:	83 c4 10             	add    $0x10,%esp
8010a410:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a413:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a417:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a41a:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a420:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a423:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a42c:	83 ec 0c             	sub    $0xc,%esp
8010a42f:	50                   	push   %eax
8010a430:	e8 1f 00 00 00       	call   8010a454 <tcp_chksum>
8010a435:	83 c4 10             	add    $0x10,%esp
8010a438:	83 c0 08             	add    $0x8,%eax
8010a43b:	0f b7 c0             	movzwl %ax,%eax
8010a43e:	83 ec 0c             	sub    $0xc,%esp
8010a441:	50                   	push   %eax
8010a442:	e8 45 f7 ff ff       	call   80109b8c <H2N_ushort>
8010a447:	83 c4 10             	add    $0x10,%esp
8010a44a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a44d:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a451:	90                   	nop
8010a452:	c9                   	leave  
8010a453:	c3                   	ret    

8010a454 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a454:	55                   	push   %ebp
8010a455:	89 e5                	mov    %esp,%ebp
8010a457:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a45a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a45d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a460:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a463:	83 c0 14             	add    $0x14,%eax
8010a466:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a469:	83 ec 04             	sub    $0x4,%esp
8010a46c:	6a 04                	push   $0x4
8010a46e:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a473:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a476:	50                   	push   %eax
8010a477:	e8 e0 ab ff ff       	call   8010505c <memmove>
8010a47c:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a47f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a482:	83 c0 0c             	add    $0xc,%eax
8010a485:	83 ec 04             	sub    $0x4,%esp
8010a488:	6a 04                	push   $0x4
8010a48a:	50                   	push   %eax
8010a48b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a48e:	83 c0 04             	add    $0x4,%eax
8010a491:	50                   	push   %eax
8010a492:	e8 c5 ab ff ff       	call   8010505c <memmove>
8010a497:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a49a:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a49e:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a4a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4a5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a4a9:	0f b7 c0             	movzwl %ax,%eax
8010a4ac:	83 ec 0c             	sub    $0xc,%esp
8010a4af:	50                   	push   %eax
8010a4b0:	e8 b5 f6 ff ff       	call   80109b6a <N2H_ushort>
8010a4b5:	83 c4 10             	add    $0x10,%esp
8010a4b8:	83 e8 14             	sub    $0x14,%eax
8010a4bb:	0f b7 c0             	movzwl %ax,%eax
8010a4be:	83 ec 0c             	sub    $0xc,%esp
8010a4c1:	50                   	push   %eax
8010a4c2:	e8 c5 f6 ff ff       	call   80109b8c <H2N_ushort>
8010a4c7:	83 c4 10             	add    $0x10,%esp
8010a4ca:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a4ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a4d5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a4d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a4db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a4e2:	eb 33                	jmp    8010a517 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4e7:	01 c0                	add    %eax,%eax
8010a4e9:	89 c2                	mov    %eax,%edx
8010a4eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4ee:	01 d0                	add    %edx,%eax
8010a4f0:	0f b6 00             	movzbl (%eax),%eax
8010a4f3:	0f b6 c0             	movzbl %al,%eax
8010a4f6:	c1 e0 08             	shl    $0x8,%eax
8010a4f9:	89 c2                	mov    %eax,%edx
8010a4fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4fe:	01 c0                	add    %eax,%eax
8010a500:	8d 48 01             	lea    0x1(%eax),%ecx
8010a503:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a506:	01 c8                	add    %ecx,%eax
8010a508:	0f b6 00             	movzbl (%eax),%eax
8010a50b:	0f b6 c0             	movzbl %al,%eax
8010a50e:	01 d0                	add    %edx,%eax
8010a510:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a513:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a517:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a51b:	7e c7                	jle    8010a4e4 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a51d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a520:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a523:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a52a:	eb 33                	jmp    8010a55f <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a52c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a52f:	01 c0                	add    %eax,%eax
8010a531:	89 c2                	mov    %eax,%edx
8010a533:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a536:	01 d0                	add    %edx,%eax
8010a538:	0f b6 00             	movzbl (%eax),%eax
8010a53b:	0f b6 c0             	movzbl %al,%eax
8010a53e:	c1 e0 08             	shl    $0x8,%eax
8010a541:	89 c2                	mov    %eax,%edx
8010a543:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a546:	01 c0                	add    %eax,%eax
8010a548:	8d 48 01             	lea    0x1(%eax),%ecx
8010a54b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a54e:	01 c8                	add    %ecx,%eax
8010a550:	0f b6 00             	movzbl (%eax),%eax
8010a553:	0f b6 c0             	movzbl %al,%eax
8010a556:	01 d0                	add    %edx,%eax
8010a558:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a55b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a55f:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a563:	0f b7 c0             	movzwl %ax,%eax
8010a566:	83 ec 0c             	sub    $0xc,%esp
8010a569:	50                   	push   %eax
8010a56a:	e8 fb f5 ff ff       	call   80109b6a <N2H_ushort>
8010a56f:	83 c4 10             	add    $0x10,%esp
8010a572:	66 d1 e8             	shr    %ax
8010a575:	0f b7 c0             	movzwl %ax,%eax
8010a578:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a57b:	7c af                	jl     8010a52c <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a57d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a580:	c1 e8 10             	shr    $0x10,%eax
8010a583:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a586:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a589:	f7 d0                	not    %eax
}
8010a58b:	c9                   	leave  
8010a58c:	c3                   	ret    

8010a58d <tcp_fin>:

void tcp_fin(){
8010a58d:	55                   	push   %ebp
8010a58e:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a590:	c7 05 a8 9f 11 80 01 	movl   $0x1,0x80119fa8
8010a597:	00 00 00 
}
8010a59a:	90                   	nop
8010a59b:	5d                   	pop    %ebp
8010a59c:	c3                   	ret    

8010a59d <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a59d:	55                   	push   %ebp
8010a59e:	89 e5                	mov    %esp,%ebp
8010a5a0:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a5a3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5a6:	83 ec 04             	sub    $0x4,%esp
8010a5a9:	6a 00                	push   $0x0
8010a5ab:	68 eb c6 10 80       	push   $0x8010c6eb
8010a5b0:	50                   	push   %eax
8010a5b1:	e8 65 00 00 00       	call   8010a61b <http_strcpy>
8010a5b6:	83 c4 10             	add    $0x10,%esp
8010a5b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a5bc:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5bf:	83 ec 04             	sub    $0x4,%esp
8010a5c2:	ff 75 f4             	push   -0xc(%ebp)
8010a5c5:	68 fe c6 10 80       	push   $0x8010c6fe
8010a5ca:	50                   	push   %eax
8010a5cb:	e8 4b 00 00 00       	call   8010a61b <http_strcpy>
8010a5d0:	83 c4 10             	add    $0x10,%esp
8010a5d3:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a5d6:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5d9:	83 ec 04             	sub    $0x4,%esp
8010a5dc:	ff 75 f4             	push   -0xc(%ebp)
8010a5df:	68 19 c7 10 80       	push   $0x8010c719
8010a5e4:	50                   	push   %eax
8010a5e5:	e8 31 00 00 00       	call   8010a61b <http_strcpy>
8010a5ea:	83 c4 10             	add    $0x10,%esp
8010a5ed:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a5f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a5f3:	83 e0 01             	and    $0x1,%eax
8010a5f6:	85 c0                	test   %eax,%eax
8010a5f8:	74 11                	je     8010a60b <http_proc+0x6e>
    char *payload = (char *)send;
8010a5fa:	8b 45 10             	mov    0x10(%ebp),%eax
8010a5fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a600:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a603:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a606:	01 d0                	add    %edx,%eax
8010a608:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a60b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a60e:	8b 45 14             	mov    0x14(%ebp),%eax
8010a611:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a613:	e8 75 ff ff ff       	call   8010a58d <tcp_fin>
}
8010a618:	90                   	nop
8010a619:	c9                   	leave  
8010a61a:	c3                   	ret    

8010a61b <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a61b:	55                   	push   %ebp
8010a61c:	89 e5                	mov    %esp,%ebp
8010a61e:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a621:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a628:	eb 20                	jmp    8010a64a <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a62a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a62d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a630:	01 d0                	add    %edx,%eax
8010a632:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a635:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a638:	01 ca                	add    %ecx,%edx
8010a63a:	89 d1                	mov    %edx,%ecx
8010a63c:	8b 55 08             	mov    0x8(%ebp),%edx
8010a63f:	01 ca                	add    %ecx,%edx
8010a641:	0f b6 00             	movzbl (%eax),%eax
8010a644:	88 02                	mov    %al,(%edx)
    i++;
8010a646:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a64a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a64d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a650:	01 d0                	add    %edx,%eax
8010a652:	0f b6 00             	movzbl (%eax),%eax
8010a655:	84 c0                	test   %al,%al
8010a657:	75 d1                	jne    8010a62a <http_strcpy+0xf>
  }
  return i;
8010a659:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a65c:	c9                   	leave  
8010a65d:	c3                   	ret    
