
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
8010005f:	ba 4a 38 10 80       	mov    $0x8010384a,%edx
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
8010006f:	68 80 a5 10 80       	push   $0x8010a580
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 92 4c 00 00       	call   80104d10 <initlock>
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
801000bd:	68 87 a5 10 80       	push   $0x8010a587
801000c2:	50                   	push   %eax
801000c3:	e8 eb 4a 00 00       	call   80104bb3 <initsleeplock>
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
80100101:	e8 2c 4c 00 00       	call   80104d32 <acquire>
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
80100140:	e8 5b 4c 00 00       	call   80104da0 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 98 4a 00 00       	call   80104bef <acquiresleep>
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
801001c1:	e8 da 4b 00 00       	call   80104da0 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 17 4a 00 00       	call   80104bef <acquiresleep>
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
801001f5:	68 8e a5 10 80       	push   $0x8010a58e
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
8010022d:	e8 fa 26 00 00       	call   8010292c <iderw>
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
8010024a:	e8 52 4a 00 00       	call   80104ca1 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a5 10 80       	push   $0x8010a59f
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
80100278:	e8 af 26 00 00       	call   8010292c <iderw>
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
80100293:	e8 09 4a 00 00       	call   80104ca1 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a5 10 80       	push   $0x8010a5a6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 98 49 00 00       	call   80104c53 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 67 4a 00 00       	call   80104d32 <acquire>
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
80100336:	e8 65 4a 00 00       	call   80104da0 <release>
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
80100410:	e8 1d 49 00 00       	call   80104d32 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a5 10 80       	push   $0x8010a5ad
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
80100510:	c7 45 ec b6 a5 10 80 	movl   $0x8010a5b6,-0x14(%ebp)
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
8010059e:	e8 fd 47 00 00       	call   80104da0 <release>
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
801005be:	e8 1c 2a 00 00       	call   80102fdf <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 bd a5 10 80       	push   $0x8010a5bd
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
801005e6:	68 d1 a5 10 80       	push   $0x8010a5d1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 ef 47 00 00       	call   80104df2 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 a5 10 80       	push   $0x8010a5d3
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
801006a0:	e8 55 7e 00 00       	call   801084fa <graphic_scroll_up>
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
801006f3:	e8 02 7e 00 00       	call   801084fa <graphic_scroll_up>
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
80100757:	e8 09 7e 00 00       	call   80108565 <font_render>
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
80100793:	e8 ee 61 00 00       	call   80106986 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 e1 61 00 00       	call   80106986 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 d4 61 00 00       	call   80106986 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 c4 61 00 00       	call   80106986 <uartputc>
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
801007eb:	e8 42 45 00 00       	call   80104d32 <acquire>
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
8010093f:	e8 61 3f 00 00       	call   801048a5 <wakeup>
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
80100962:	e8 39 44 00 00       	call   80104da0 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 eb 3f 00 00       	call   80104960 <procdump>
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
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 93 43 00 00       	call   80104d32 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 69 35 00 00       	call   80103f15 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 e0 43 00 00       	call   80104da0 <release>
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
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 d1 3d 00 00       	call   801047be <sleep>
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
80100a66:	e8 35 43 00 00       	call   80104da0 <release>
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
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
80100aa2:	e8 8b 42 00 00       	call   80104d32 <acquire>
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
80100ae4:	e8 b7 42 00 00       	call   80104da0 <release>
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
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 d7 a5 10 80       	push   $0x8010a5d7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 ef 41 00 00       	call   80104d10 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a5 10 80 	movl   $0x8010a5df,-0xc(%ebp)
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
80100b75:	e8 99 1f 00 00       	call   80102b13 <ioapicenable>
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
80100b89:	e8 87 33 00 00       	call   80103f15 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8b 29 00 00       	call   80103521 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7d 19 00 00       	call   8010251e <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fb 29 00 00       	call   801035ad <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 f8 a5 10 80       	push   $0x8010a5f8
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
80100c11:	e8 6c 6d 00 00       	call   80107982 <setupkvm>
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
80100cb7:	e8 bf 70 00 00       	call   80107d7b <allocuvm>
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
80100cfd:	e8 ac 6f 00 00       	call   80107cae <loaduvm>
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
80100d3e:	e8 6a 28 00 00       	call   801035ad <end_op>
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
80100d6e:	e8 08 70 00 00       	call   80107d7b <allocuvm>
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
80100dbc:	e8 35 44 00 00       	call   801051f6 <strlen>
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
80100de9:	e8 08 44 00 00       	call   801051f6 <strlen>
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
80100e0f:	e8 53 73 00 00       	call   80108167 <copyout>
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
80100eab:	e8 b7 72 00 00       	call   80108167 <copyout>
80100eb0:	83 c4 10             	add    $0x10,%esp
80100eb3:	85 c0                	test   %eax,%eax
80100eb5:	79 15                	jns    80100ecc <exec+0x34c>
    cprintf("[exec] copyout of ustack failed\n");
80100eb7:	83 ec 0c             	sub    $0xc,%esp
80100eba:	68 04 a6 10 80       	push   $0x8010a604
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
80100f0a:	e8 9c 42 00 00       	call   801051ab <safestrcpy>
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
80100f4d:	e8 4d 6b 00 00       	call   80107a9f <switchuvm>
80100f52:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f55:	83 ec 0c             	sub    $0xc,%esp
80100f58:	ff 75 c4             	push   -0x3c(%ebp)
80100f5b:	e8 e4 6f 00 00       	call   80107f44 <freevm>
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
80100f98:	e8 a7 6f 00 00       	call   80107f44 <freevm>
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
80100fb4:	e8 f4 25 00 00       	call   801035ad <end_op>
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
80100fc9:	68 25 a6 10 80       	push   $0x8010a625
80100fce:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd3:	e8 38 3d 00 00       	call   80104d10 <initlock>
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
80100fe7:	68 a0 4a 11 80       	push   $0x80114aa0
80100fec:	e8 41 3d 00 00       	call   80104d32 <acquire>
80100ff1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff4:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
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
80101014:	68 a0 4a 11 80       	push   $0x80114aa0
80101019:	e8 82 3d 00 00       	call   80104da0 <release>
8010101e:	83 c4 10             	add    $0x10,%esp
      return f;
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	eb 23                	jmp    80101049 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101026:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010102a:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010102f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101032:	72 c9                	jb     80100ffd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101034:	83 ec 0c             	sub    $0xc,%esp
80101037:	68 a0 4a 11 80       	push   $0x80114aa0
8010103c:	e8 5f 3d 00 00       	call   80104da0 <release>
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
80101054:	68 a0 4a 11 80       	push   $0x80114aa0
80101059:	e8 d4 3c 00 00       	call   80104d32 <acquire>
8010105e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	8b 40 04             	mov    0x4(%eax),%eax
80101067:	85 c0                	test   %eax,%eax
80101069:	7f 0d                	jg     80101078 <filedup+0x2d>
    panic("filedup");
8010106b:	83 ec 0c             	sub    $0xc,%esp
8010106e:	68 2c a6 10 80       	push   $0x8010a62c
80101073:	e8 31 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101078:	8b 45 08             	mov    0x8(%ebp),%eax
8010107b:	8b 40 04             	mov    0x4(%eax),%eax
8010107e:	8d 50 01             	lea    0x1(%eax),%edx
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101087:	83 ec 0c             	sub    $0xc,%esp
8010108a:	68 a0 4a 11 80       	push   $0x80114aa0
8010108f:	e8 0c 3d 00 00       	call   80104da0 <release>
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
801010a5:	68 a0 4a 11 80       	push   $0x80114aa0
801010aa:	e8 83 3c 00 00       	call   80104d32 <acquire>
801010af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b2:	8b 45 08             	mov    0x8(%ebp),%eax
801010b5:	8b 40 04             	mov    0x4(%eax),%eax
801010b8:	85 c0                	test   %eax,%eax
801010ba:	7f 0d                	jg     801010c9 <fileclose+0x2d>
    panic("fileclose");
801010bc:	83 ec 0c             	sub    $0xc,%esp
801010bf:	68 34 a6 10 80       	push   $0x8010a634
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
801010e5:	68 a0 4a 11 80       	push   $0x80114aa0
801010ea:	e8 b1 3c 00 00       	call   80104da0 <release>
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
80101133:	68 a0 4a 11 80       	push   $0x80114aa0
80101138:	e8 63 3c 00 00       	call   80104da0 <release>
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
80101157:	e8 48 2a 00 00       	call   80103ba4 <pipeclose>
8010115c:	83 c4 10             	add    $0x10,%esp
8010115f:	eb 21                	jmp    80101182 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101161:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101164:	83 f8 02             	cmp    $0x2,%eax
80101167:	75 19                	jne    80101182 <fileclose+0xe6>
    begin_op();
80101169:	e8 b3 23 00 00       	call   80103521 <begin_op>
    iput(ff.ip);
8010116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101171:	83 ec 0c             	sub    $0xc,%esp
80101174:	50                   	push   %eax
80101175:	e8 d2 09 00 00       	call   80101b4c <iput>
8010117a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117d:	e8 2b 24 00 00       	call   801035ad <end_op>
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
80101210:	e8 3c 2b 00 00       	call   80103d51 <piperead>
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
80101287:	68 3e a6 10 80       	push   $0x8010a63e
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
801012c9:	e8 81 29 00 00       	call   80103c4f <pipewrite>
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
8010130e:	e8 0e 22 00 00       	call   80103521 <begin_op>
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
80101374:	e8 34 22 00 00       	call   801035ad <end_op>

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
8010138a:	68 47 a6 10 80       	push   $0x8010a647
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
801013c0:	68 57 a6 10 80       	push   $0x8010a657
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
801013f8:	e8 6a 3c 00 00       	call   80105067 <memmove>
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
8010143e:	e8 65 3b 00 00       	call   80104fa8 <memset>
80101443:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101446:	83 ec 0c             	sub    $0xc,%esp
80101449:	ff 75 f4             	push   -0xc(%ebp)
8010144c:	e8 09 23 00 00       	call   8010375a <log_write>
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
80101491:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101518:	e8 3d 22 00 00       	call   8010375a <log_write>
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
80101567:	a1 40 54 11 80       	mov    0x80115440,%eax
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
80101589:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101592:	39 c2                	cmp    %eax,%edx
80101594:	0f 87 e4 fe ff ff    	ja     8010147e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010159a:	83 ec 0c             	sub    $0xc,%esp
8010159d:	68 64 a6 10 80       	push   $0x8010a664
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
801015b2:	68 40 54 11 80       	push   $0x80115440
801015b7:	ff 75 08             	push   0x8(%ebp)
801015ba:	e8 10 fe ff ff       	call   801013cf <readsb>
801015bf:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c5:	c1 e8 0c             	shr    $0xc,%eax
801015c8:	89 c2                	mov    %eax,%edx
801015ca:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101628:	68 7a a6 10 80       	push   $0x8010a67a
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
80101660:	e8 f5 20 00 00       	call   8010375a <log_write>
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
8010168c:	68 8d a6 10 80       	push   $0x8010a68d
80101691:	68 60 54 11 80       	push   $0x80115460
80101696:	e8 75 36 00 00       	call   80104d10 <initlock>
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
801016b7:	05 60 54 11 80       	add    $0x80115460,%eax
801016bc:	83 c0 10             	add    $0x10,%eax
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	68 94 a6 10 80       	push   $0x8010a694
801016c7:	50                   	push   %eax
801016c8:	e8 e6 34 00 00       	call   80104bb3 <initsleeplock>
801016cd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d4:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d8:	7e cd                	jle    801016a7 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016da:	83 ec 08             	sub    $0x8,%esp
801016dd:	68 40 54 11 80       	push   $0x80115440
801016e2:	ff 75 08             	push   0x8(%ebp)
801016e5:	e8 e5 fc ff ff       	call   801013cf <readsb>
801016ea:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ed:	a1 58 54 11 80       	mov    0x80115458,%eax
801016f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f5:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016fb:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101701:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101707:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010170d:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101713:	a1 40 54 11 80       	mov    0x80115440,%eax
80101718:	ff 75 d4             	push   -0x2c(%ebp)
8010171b:	57                   	push   %edi
8010171c:	56                   	push   %esi
8010171d:	53                   	push   %ebx
8010171e:	51                   	push   %ecx
8010171f:	52                   	push   %edx
80101720:	50                   	push   %eax
80101721:	68 9c a6 10 80       	push   $0x8010a69c
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
80101758:	a1 54 54 11 80       	mov    0x80115454,%eax
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
8010179a:	e8 09 38 00 00       	call   80104fa8 <memset>
8010179f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a5:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a9:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ac:	83 ec 0c             	sub    $0xc,%esp
801017af:	ff 75 f0             	push   -0x10(%ebp)
801017b2:	e8 a3 1f 00 00       	call   8010375a <log_write>
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
801017ee:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f7:	39 c2                	cmp    %eax,%edx
801017f9:	0f 87 51 ff ff ff    	ja     80101750 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ff:	83 ec 0c             	sub    $0xc,%esp
80101802:	68 ef a6 10 80       	push   $0x8010a6ef
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
8010181f:	a1 54 54 11 80       	mov    0x80115454,%eax
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
801018a8:	e8 ba 37 00 00       	call   80105067 <memmove>
801018ad:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	ff 75 f4             	push   -0xc(%ebp)
801018b6:	e8 9f 1e 00 00       	call   8010375a <log_write>
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
801018d8:	68 60 54 11 80       	push   $0x80115460
801018dd:	e8 50 34 00 00       	call   80104d32 <acquire>
801018e2:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ec:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
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
80101926:	68 60 54 11 80       	push   $0x80115460
8010192b:	e8 70 34 00 00       	call   80104da0 <release>
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
80101955:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010195c:	72 97                	jb     801018f5 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101962:	75 0d                	jne    80101971 <iget+0xa2>
    panic("iget: no inodes");
80101964:	83 ec 0c             	sub    $0xc,%esp
80101967:	68 01 a7 10 80       	push   $0x8010a701
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
8010199f:	68 60 54 11 80       	push   $0x80115460
801019a4:	e8 f7 33 00 00       	call   80104da0 <release>
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
801019ba:	68 60 54 11 80       	push   $0x80115460
801019bf:	e8 6e 33 00 00       	call   80104d32 <acquire>
801019c4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	8d 50 01             	lea    0x1(%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	68 60 54 11 80       	push   $0x80115460
801019de:	e8 bd 33 00 00       	call   80104da0 <release>
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
80101a04:	68 11 a7 10 80       	push   $0x8010a711
80101a09:	e8 9b eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	50                   	push   %eax
80101a18:	e8 d2 31 00 00       	call   80104bef <acquiresleep>
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
80101a39:	a1 54 54 11 80       	mov    0x80115454,%eax
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
80101ac2:	e8 a0 35 00 00       	call   80105067 <memmove>
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
80101af1:	68 17 a7 10 80       	push   $0x8010a717
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
80101b14:	e8 88 31 00 00       	call   80104ca1 <holdingsleep>
80101b19:	83 c4 10             	add    $0x10,%esp
80101b1c:	85 c0                	test   %eax,%eax
80101b1e:	74 0a                	je     80101b2a <iunlock+0x2c>
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 40 08             	mov    0x8(%eax),%eax
80101b26:	85 c0                	test   %eax,%eax
80101b28:	7f 0d                	jg     80101b37 <iunlock+0x39>
    panic("iunlock");
80101b2a:	83 ec 0c             	sub    $0xc,%esp
80101b2d:	68 26 a7 10 80       	push   $0x8010a726
80101b32:	e8 72 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	83 c0 0c             	add    $0xc,%eax
80101b3d:	83 ec 0c             	sub    $0xc,%esp
80101b40:	50                   	push   %eax
80101b41:	e8 0d 31 00 00       	call   80104c53 <releasesleep>
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
80101b5c:	e8 8e 30 00 00       	call   80104bef <acquiresleep>
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
80101b7d:	68 60 54 11 80       	push   $0x80115460
80101b82:	e8 ab 31 00 00       	call   80104d32 <acquire>
80101b87:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	8b 40 08             	mov    0x8(%eax),%eax
80101b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b93:	83 ec 0c             	sub    $0xc,%esp
80101b96:	68 60 54 11 80       	push   $0x80115460
80101b9b:	e8 00 32 00 00       	call   80104da0 <release>
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
80101be2:	e8 6c 30 00 00       	call   80104c53 <releasesleep>
80101be7:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bea:	83 ec 0c             	sub    $0xc,%esp
80101bed:	68 60 54 11 80       	push   $0x80115460
80101bf2:	e8 3b 31 00 00       	call   80104d32 <acquire>
80101bf7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 40 08             	mov    0x8(%eax),%eax
80101c00:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	68 60 54 11 80       	push   $0x80115460
80101c11:	e8 8a 31 00 00       	call   80104da0 <release>
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
80101d37:	e8 1e 1a 00 00       	call   8010375a <log_write>
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
80101d55:	68 2e a7 10 80       	push   $0x8010a72e
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
80101f0b:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f12:	85 c0                	test   %eax,%eax
80101f14:	75 0a                	jne    80101f20 <readi+0x49>
      return -1;
80101f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1b:	e9 0a 01 00 00       	jmp    8010202a <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f20:	8b 45 08             	mov    0x8(%ebp),%eax
80101f23:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f27:	98                   	cwtl   
80101f28:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
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
80101ff3:	e8 6f 30 00 00       	call   80105067 <memmove>
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
80102060:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <writei+0x49>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 3b 01 00 00       	jmp    801021b0 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
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
80102143:	e8 1f 2f 00 00       	call   80105067 <memmove>
80102148:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	ff 75 f0             	push   -0x10(%ebp)
80102151:	e8 04 16 00 00       	call   8010375a <log_write>
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
801021c3:	e8 35 2f 00 00       	call   801050fd <strncmp>
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
801021e3:	68 41 a7 10 80       	push   $0x8010a741
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
80102212:	68 53 a7 10 80       	push   $0x8010a753
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
801022e7:	68 62 a7 10 80       	push   $0x8010a762
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
80102322:	e8 2c 2e 00 00       	call   80105153 <strncpy>
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
8010234e:	68 6f a7 10 80       	push   $0x8010a76f
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
801023c0:	e8 a2 2c 00 00       	call   80105067 <memmove>
801023c5:	83 c4 10             	add    $0x10,%esp
801023c8:	eb 26                	jmp    801023f0 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cd:	83 ec 04             	sub    $0x4,%esp
801023d0:	50                   	push   %eax
801023d1:	ff 75 f4             	push   -0xc(%ebp)
801023d4:	ff 75 0c             	push   0xc(%ebp)
801023d7:	e8 8b 2c 00 00       	call   80105067 <memmove>
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
80102426:	e8 ea 1a 00 00       	call   80103f15 <myproc>
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

80102555 <inb>:
{
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
80102558:	83 ec 14             	sub    $0x14,%esp
8010255b:	8b 45 08             	mov    0x8(%ebp),%eax
8010255e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102562:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102566:	89 c2                	mov    %eax,%edx
80102568:	ec                   	in     (%dx),%al
80102569:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010256c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102570:	c9                   	leave  
80102571:	c3                   	ret    

80102572 <insl>:
{
80102572:	55                   	push   %ebp
80102573:	89 e5                	mov    %esp,%ebp
80102575:	57                   	push   %edi
80102576:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102577:	8b 55 08             	mov    0x8(%ebp),%edx
8010257a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010257d:	8b 45 10             	mov    0x10(%ebp),%eax
80102580:	89 cb                	mov    %ecx,%ebx
80102582:	89 df                	mov    %ebx,%edi
80102584:	89 c1                	mov    %eax,%ecx
80102586:	fc                   	cld    
80102587:	f3 6d                	rep insl (%dx),%es:(%edi)
80102589:	89 c8                	mov    %ecx,%eax
8010258b:	89 fb                	mov    %edi,%ebx
8010258d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102590:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102593:	90                   	nop
80102594:	5b                   	pop    %ebx
80102595:	5f                   	pop    %edi
80102596:	5d                   	pop    %ebp
80102597:	c3                   	ret    

80102598 <outb>:
{
80102598:	55                   	push   %ebp
80102599:	89 e5                	mov    %esp,%ebp
8010259b:	83 ec 08             	sub    $0x8,%esp
8010259e:	8b 45 08             	mov    0x8(%ebp),%eax
801025a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801025a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025a8:	89 d0                	mov    %edx,%eax
801025aa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ad:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025b5:	ee                   	out    %al,(%dx)
}
801025b6:	90                   	nop
801025b7:	c9                   	leave  
801025b8:	c3                   	ret    

801025b9 <outsl>:
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	56                   	push   %esi
801025bd:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025be:	8b 55 08             	mov    0x8(%ebp),%edx
801025c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c4:	8b 45 10             	mov    0x10(%ebp),%eax
801025c7:	89 cb                	mov    %ecx,%ebx
801025c9:	89 de                	mov    %ebx,%esi
801025cb:	89 c1                	mov    %eax,%ecx
801025cd:	fc                   	cld    
801025ce:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d0:	89 c8                	mov    %ecx,%eax
801025d2:	89 f3                	mov    %esi,%ebx
801025d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025d7:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025da:	90                   	nop
801025db:	5b                   	pop    %ebx
801025dc:	5e                   	pop    %esi
801025dd:	5d                   	pop    %ebp
801025de:	c3                   	ret    

801025df <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025df:	55                   	push   %ebp
801025e0:	89 e5                	mov    %esp,%ebp
801025e2:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025e5:	90                   	nop
801025e6:	68 f7 01 00 00       	push   $0x1f7
801025eb:	e8 65 ff ff ff       	call   80102555 <inb>
801025f0:	83 c4 04             	add    $0x4,%esp
801025f3:	0f b6 c0             	movzbl %al,%eax
801025f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fc:	25 c0 00 00 00       	and    $0xc0,%eax
80102601:	83 f8 40             	cmp    $0x40,%eax
80102604:	75 e0                	jne    801025e6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102606:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010260a:	74 11                	je     8010261d <idewait+0x3e>
8010260c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010260f:	83 e0 21             	and    $0x21,%eax
80102612:	85 c0                	test   %eax,%eax
80102614:	74 07                	je     8010261d <idewait+0x3e>
    return -1;
80102616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010261b:	eb 05                	jmp    80102622 <idewait+0x43>
  return 0;
8010261d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102622:	c9                   	leave  
80102623:	c3                   	ret    

80102624 <ideinit>:

void
ideinit(void)
{
80102624:	55                   	push   %ebp
80102625:	89 e5                	mov    %esp,%ebp
80102627:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010262a:	83 ec 08             	sub    $0x8,%esp
8010262d:	68 77 a7 10 80       	push   $0x8010a777
80102632:	68 c0 70 11 80       	push   $0x801170c0
80102637:	e8 d4 26 00 00       	call   80104d10 <initlock>
8010263c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263f:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80102644:	83 e8 01             	sub    $0x1,%eax
80102647:	83 ec 08             	sub    $0x8,%esp
8010264a:	50                   	push   %eax
8010264b:	6a 0e                	push   $0xe
8010264d:	e8 c1 04 00 00       	call   80102b13 <ioapicenable>
80102652:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102655:	83 ec 0c             	sub    $0xc,%esp
80102658:	6a 00                	push   $0x0
8010265a:	e8 80 ff ff ff       	call   801025df <idewait>
8010265f:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102662:	83 ec 08             	sub    $0x8,%esp
80102665:	68 f0 00 00 00       	push   $0xf0
8010266a:	68 f6 01 00 00       	push   $0x1f6
8010266f:	e8 24 ff ff ff       	call   80102598 <outb>
80102674:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010267e:	eb 24                	jmp    801026a4 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102680:	83 ec 0c             	sub    $0xc,%esp
80102683:	68 f7 01 00 00       	push   $0x1f7
80102688:	e8 c8 fe ff ff       	call   80102555 <inb>
8010268d:	83 c4 10             	add    $0x10,%esp
80102690:	84 c0                	test   %al,%al
80102692:	74 0c                	je     801026a0 <ideinit+0x7c>
      havedisk1 = 1;
80102694:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
8010269b:	00 00 00 
      break;
8010269e:	eb 0d                	jmp    801026ad <ideinit+0x89>
  for(i=0; i<1000; i++){
801026a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a4:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026ab:	7e d3                	jle    80102680 <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ad:	83 ec 08             	sub    $0x8,%esp
801026b0:	68 e0 00 00 00       	push   $0xe0
801026b5:	68 f6 01 00 00       	push   $0x1f6
801026ba:	e8 d9 fe ff ff       	call   80102598 <outb>
801026bf:	83 c4 10             	add    $0x10,%esp
}
801026c2:	90                   	nop
801026c3:	c9                   	leave  
801026c4:	c3                   	ret    

801026c5 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026c5:	55                   	push   %ebp
801026c6:	89 e5                	mov    %esp,%ebp
801026c8:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026cf:	75 0d                	jne    801026de <idestart+0x19>
    panic("idestart");
801026d1:	83 ec 0c             	sub    $0xc,%esp
801026d4:	68 7b a7 10 80       	push   $0x8010a77b
801026d9:	e8 cb de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026de:	8b 45 08             	mov    0x8(%ebp),%eax
801026e1:	8b 40 08             	mov    0x8(%eax),%eax
801026e4:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e9:	76 0d                	jbe    801026f8 <idestart+0x33>
    panic("incorrect blockno");
801026eb:	83 ec 0c             	sub    $0xc,%esp
801026ee:	68 84 a7 10 80       	push   $0x8010a784
801026f3:	e8 b1 de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102702:	8b 50 08             	mov    0x8(%eax),%edx
80102705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102708:	0f af c2             	imul   %edx,%eax
8010270b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010270e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102712:	75 07                	jne    8010271b <idestart+0x56>
80102714:	b8 20 00 00 00       	mov    $0x20,%eax
80102719:	eb 05                	jmp    80102720 <idestart+0x5b>
8010271b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102723:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102727:	75 07                	jne    80102730 <idestart+0x6b>
80102729:	b8 30 00 00 00       	mov    $0x30,%eax
8010272e:	eb 05                	jmp    80102735 <idestart+0x70>
80102730:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102735:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102738:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010273c:	7e 0d                	jle    8010274b <idestart+0x86>
8010273e:	83 ec 0c             	sub    $0xc,%esp
80102741:	68 7b a7 10 80       	push   $0x8010a77b
80102746:	e8 5e de ff ff       	call   801005a9 <panic>

  idewait(0);
8010274b:	83 ec 0c             	sub    $0xc,%esp
8010274e:	6a 00                	push   $0x0
80102750:	e8 8a fe ff ff       	call   801025df <idewait>
80102755:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102758:	83 ec 08             	sub    $0x8,%esp
8010275b:	6a 00                	push   $0x0
8010275d:	68 f6 03 00 00       	push   $0x3f6
80102762:	e8 31 fe ff ff       	call   80102598 <outb>
80102767:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010276a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276d:	0f b6 c0             	movzbl %al,%eax
80102770:	83 ec 08             	sub    $0x8,%esp
80102773:	50                   	push   %eax
80102774:	68 f2 01 00 00       	push   $0x1f2
80102779:	e8 1a fe ff ff       	call   80102598 <outb>
8010277e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102784:	0f b6 c0             	movzbl %al,%eax
80102787:	83 ec 08             	sub    $0x8,%esp
8010278a:	50                   	push   %eax
8010278b:	68 f3 01 00 00       	push   $0x1f3
80102790:	e8 03 fe ff ff       	call   80102598 <outb>
80102795:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010279b:	c1 f8 08             	sar    $0x8,%eax
8010279e:	0f b6 c0             	movzbl %al,%eax
801027a1:	83 ec 08             	sub    $0x8,%esp
801027a4:	50                   	push   %eax
801027a5:	68 f4 01 00 00       	push   $0x1f4
801027aa:	e8 e9 fd ff ff       	call   80102598 <outb>
801027af:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b5:	c1 f8 10             	sar    $0x10,%eax
801027b8:	0f b6 c0             	movzbl %al,%eax
801027bb:	83 ec 08             	sub    $0x8,%esp
801027be:	50                   	push   %eax
801027bf:	68 f5 01 00 00       	push   $0x1f5
801027c4:	e8 cf fd ff ff       	call   80102598 <outb>
801027c9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 40 04             	mov    0x4(%eax),%eax
801027d2:	c1 e0 04             	shl    $0x4,%eax
801027d5:	83 e0 10             	and    $0x10,%eax
801027d8:	89 c2                	mov    %eax,%edx
801027da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dd:	c1 f8 18             	sar    $0x18,%eax
801027e0:	83 e0 0f             	and    $0xf,%eax
801027e3:	09 d0                	or     %edx,%eax
801027e5:	83 c8 e0             	or     $0xffffffe0,%eax
801027e8:	0f b6 c0             	movzbl %al,%eax
801027eb:	83 ec 08             	sub    $0x8,%esp
801027ee:	50                   	push   %eax
801027ef:	68 f6 01 00 00       	push   $0x1f6
801027f4:	e8 9f fd ff ff       	call   80102598 <outb>
801027f9:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027fc:	8b 45 08             	mov    0x8(%ebp),%eax
801027ff:	8b 00                	mov    (%eax),%eax
80102801:	83 e0 04             	and    $0x4,%eax
80102804:	85 c0                	test   %eax,%eax
80102806:	74 35                	je     8010283d <idestart+0x178>
    outb(0x1f7, write_cmd);
80102808:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010280b:	0f b6 c0             	movzbl %al,%eax
8010280e:	83 ec 08             	sub    $0x8,%esp
80102811:	50                   	push   %eax
80102812:	68 f7 01 00 00       	push   $0x1f7
80102817:	e8 7c fd ff ff       	call   80102598 <outb>
8010281c:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010281f:	8b 45 08             	mov    0x8(%ebp),%eax
80102822:	83 c0 5c             	add    $0x5c,%eax
80102825:	83 ec 04             	sub    $0x4,%esp
80102828:	68 80 00 00 00       	push   $0x80
8010282d:	50                   	push   %eax
8010282e:	68 f0 01 00 00       	push   $0x1f0
80102833:	e8 81 fd ff ff       	call   801025b9 <outsl>
80102838:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010283b:	eb 17                	jmp    80102854 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010283d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102840:	0f b6 c0             	movzbl %al,%eax
80102843:	83 ec 08             	sub    $0x8,%esp
80102846:	50                   	push   %eax
80102847:	68 f7 01 00 00       	push   $0x1f7
8010284c:	e8 47 fd ff ff       	call   80102598 <outb>
80102851:	83 c4 10             	add    $0x10,%esp
}
80102854:	90                   	nop
80102855:	c9                   	leave  
80102856:	c3                   	ret    

80102857 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010285d:	83 ec 0c             	sub    $0xc,%esp
80102860:	68 c0 70 11 80       	push   $0x801170c0
80102865:	e8 c8 24 00 00       	call   80104d32 <acquire>
8010286a:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286d:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102872:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102875:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102879:	75 15                	jne    80102890 <ideintr+0x39>
    release(&idelock);
8010287b:	83 ec 0c             	sub    $0xc,%esp
8010287e:	68 c0 70 11 80       	push   $0x801170c0
80102883:	e8 18 25 00 00       	call   80104da0 <release>
80102888:	83 c4 10             	add    $0x10,%esp
    return;
8010288b:	e9 9a 00 00 00       	jmp    8010292a <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102893:	8b 40 58             	mov    0x58(%eax),%eax
80102896:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289e:	8b 00                	mov    (%eax),%eax
801028a0:	83 e0 04             	and    $0x4,%eax
801028a3:	85 c0                	test   %eax,%eax
801028a5:	75 2d                	jne    801028d4 <ideintr+0x7d>
801028a7:	83 ec 0c             	sub    $0xc,%esp
801028aa:	6a 01                	push   $0x1
801028ac:	e8 2e fd ff ff       	call   801025df <idewait>
801028b1:	83 c4 10             	add    $0x10,%esp
801028b4:	85 c0                	test   %eax,%eax
801028b6:	78 1c                	js     801028d4 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bb:	83 c0 5c             	add    $0x5c,%eax
801028be:	83 ec 04             	sub    $0x4,%esp
801028c1:	68 80 00 00 00       	push   $0x80
801028c6:	50                   	push   %eax
801028c7:	68 f0 01 00 00       	push   $0x1f0
801028cc:	e8 a1 fc ff ff       	call   80102572 <insl>
801028d1:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d7:	8b 00                	mov    (%eax),%eax
801028d9:	83 c8 02             	or     $0x2,%eax
801028dc:	89 c2                	mov    %eax,%edx
801028de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e1:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e6:	8b 00                	mov    (%eax),%eax
801028e8:	83 e0 fb             	and    $0xfffffffb,%eax
801028eb:	89 c2                	mov    %eax,%edx
801028ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f0:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f2:	83 ec 0c             	sub    $0xc,%esp
801028f5:	ff 75 f4             	push   -0xc(%ebp)
801028f8:	e8 a8 1f 00 00       	call   801048a5 <wakeup>
801028fd:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102900:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102905:	85 c0                	test   %eax,%eax
80102907:	74 11                	je     8010291a <ideintr+0xc3>
    idestart(idequeue);
80102909:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290e:	83 ec 0c             	sub    $0xc,%esp
80102911:	50                   	push   %eax
80102912:	e8 ae fd ff ff       	call   801026c5 <idestart>
80102917:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 c0 70 11 80       	push   $0x801170c0
80102922:	e8 79 24 00 00       	call   80104da0 <release>
80102927:	83 c4 10             	add    $0x10,%esp
}
8010292a:	c9                   	leave  
8010292b:	c3                   	ret    

8010292c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292c:	55                   	push   %ebp
8010292d:	89 e5                	mov    %esp,%ebp
8010292f:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102932:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102938:	8b 45 08             	mov    0x8(%ebp),%eax
8010293b:	8b 40 04             	mov    0x4(%eax),%eax
8010293e:	83 ec 04             	sub    $0x4,%esp
80102941:	52                   	push   %edx
80102942:	50                   	push   %eax
80102943:	68 96 a7 10 80       	push   $0x8010a796
80102948:	e8 a7 da ff ff       	call   801003f4 <cprintf>
8010294d:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102950:	8b 45 08             	mov    0x8(%ebp),%eax
80102953:	83 c0 0c             	add    $0xc,%eax
80102956:	83 ec 0c             	sub    $0xc,%esp
80102959:	50                   	push   %eax
8010295a:	e8 42 23 00 00       	call   80104ca1 <holdingsleep>
8010295f:	83 c4 10             	add    $0x10,%esp
80102962:	85 c0                	test   %eax,%eax
80102964:	75 0d                	jne    80102973 <iderw+0x47>
    panic("iderw: buf not locked");
80102966:	83 ec 0c             	sub    $0xc,%esp
80102969:	68 b0 a7 10 80       	push   $0x8010a7b0
8010296e:	e8 36 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102973:	8b 45 08             	mov    0x8(%ebp),%eax
80102976:	8b 00                	mov    (%eax),%eax
80102978:	83 e0 06             	and    $0x6,%eax
8010297b:	83 f8 02             	cmp    $0x2,%eax
8010297e:	75 0d                	jne    8010298d <iderw+0x61>
    panic("iderw: nothing to do");
80102980:	83 ec 0c             	sub    $0xc,%esp
80102983:	68 c6 a7 10 80       	push   $0x8010a7c6
80102988:	e8 1c dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
8010298d:	8b 45 08             	mov    0x8(%ebp),%eax
80102990:	8b 40 04             	mov    0x4(%eax),%eax
80102993:	85 c0                	test   %eax,%eax
80102995:	74 16                	je     801029ad <iderw+0x81>
80102997:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010299c:	85 c0                	test   %eax,%eax
8010299e:	75 0d                	jne    801029ad <iderw+0x81>
    panic("iderw: ide disk 1 not present");
801029a0:	83 ec 0c             	sub    $0xc,%esp
801029a3:	68 db a7 10 80       	push   $0x8010a7db
801029a8:	e8 fc db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ad:	83 ec 0c             	sub    $0xc,%esp
801029b0:	68 c0 70 11 80       	push   $0x801170c0
801029b5:	e8 78 23 00 00       	call   80104d32 <acquire>
801029ba:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bd:	8b 45 08             	mov    0x8(%ebp),%eax
801029c0:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c7:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029ce:	eb 0b                	jmp    801029db <iderw+0xaf>
801029d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d3:	8b 00                	mov    (%eax),%eax
801029d5:	83 c0 58             	add    $0x58,%eax
801029d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029de:	8b 00                	mov    (%eax),%eax
801029e0:	85 c0                	test   %eax,%eax
801029e2:	75 ec                	jne    801029d0 <iderw+0xa4>
    ;
  *pp = b;
801029e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e7:	8b 55 08             	mov    0x8(%ebp),%edx
801029ea:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029ec:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f1:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f4:	75 23                	jne    80102a19 <iderw+0xed>
    idestart(b);
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	ff 75 08             	push   0x8(%ebp)
801029fc:	e8 c4 fc ff ff       	call   801026c5 <idestart>
80102a01:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a04:	eb 13                	jmp    80102a19 <iderw+0xed>
    sleep(b, &idelock);
80102a06:	83 ec 08             	sub    $0x8,%esp
80102a09:	68 c0 70 11 80       	push   $0x801170c0
80102a0e:	ff 75 08             	push   0x8(%ebp)
80102a11:	e8 a8 1d 00 00       	call   801047be <sleep>
80102a16:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a19:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1c:	8b 00                	mov    (%eax),%eax
80102a1e:	83 e0 06             	and    $0x6,%eax
80102a21:	83 f8 02             	cmp    $0x2,%eax
80102a24:	75 e0                	jne    80102a06 <iderw+0xda>
  }


  release(&idelock);
80102a26:	83 ec 0c             	sub    $0xc,%esp
80102a29:	68 c0 70 11 80       	push   $0x801170c0
80102a2e:	e8 6d 23 00 00       	call   80104da0 <release>
80102a33:	83 c4 10             	add    $0x10,%esp
}
80102a36:	90                   	nop
80102a37:	c9                   	leave  
80102a38:	c3                   	ret    

80102a39 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a41:	8b 55 08             	mov    0x8(%ebp),%edx
80102a44:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a46:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4b:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4e:	5d                   	pop    %ebp
80102a4f:	c3                   	ret    

80102a50 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a50:	55                   	push   %ebp
80102a51:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a53:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a58:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5d:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a62:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a65:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a68:	90                   	nop
80102a69:	5d                   	pop    %ebp
80102a6a:	c3                   	ret    

80102a6b <ioapicinit>:

void
ioapicinit(void)
{
80102a6b:	55                   	push   %ebp
80102a6c:	89 e5                	mov    %esp,%ebp
80102a6e:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a71:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a78:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7b:	6a 01                	push   $0x1
80102a7d:	e8 b7 ff ff ff       	call   80102a39 <ioapicread>
80102a82:	83 c4 04             	add    $0x4,%esp
80102a85:	c1 e8 10             	shr    $0x10,%eax
80102a88:	25 ff 00 00 00       	and    $0xff,%eax
80102a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a90:	6a 00                	push   $0x0
80102a92:	e8 a2 ff ff ff       	call   80102a39 <ioapicread>
80102a97:	83 c4 04             	add    $0x4,%esp
80102a9a:	c1 e8 18             	shr    $0x18,%eax
80102a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aa0:	0f b6 05 84 9c 11 80 	movzbl 0x80119c84,%eax
80102aa7:	0f b6 c0             	movzbl %al,%eax
80102aaa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aad:	74 10                	je     80102abf <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aaf:	83 ec 0c             	sub    $0xc,%esp
80102ab2:	68 fc a7 10 80       	push   $0x8010a7fc
80102ab7:	e8 38 d9 ff ff       	call   801003f4 <cprintf>
80102abc:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac6:	eb 3f                	jmp    80102b07 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acb:	83 c0 20             	add    $0x20,%eax
80102ace:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad3:	89 c2                	mov    %eax,%edx
80102ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad8:	83 c0 08             	add    $0x8,%eax
80102adb:	01 c0                	add    %eax,%eax
80102add:	83 ec 08             	sub    $0x8,%esp
80102ae0:	52                   	push   %edx
80102ae1:	50                   	push   %eax
80102ae2:	e8 69 ff ff ff       	call   80102a50 <ioapicwrite>
80102ae7:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aed:	83 c0 08             	add    $0x8,%eax
80102af0:	01 c0                	add    %eax,%eax
80102af2:	83 c0 01             	add    $0x1,%eax
80102af5:	83 ec 08             	sub    $0x8,%esp
80102af8:	6a 00                	push   $0x0
80102afa:	50                   	push   %eax
80102afb:	e8 50 ff ff ff       	call   80102a50 <ioapicwrite>
80102b00:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0d:	7e b9                	jle    80102ac8 <ioapicinit+0x5d>
  }
}
80102b0f:	90                   	nop
80102b10:	90                   	nop
80102b11:	c9                   	leave  
80102b12:	c3                   	ret    

80102b13 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b13:	55                   	push   %ebp
80102b14:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b16:	8b 45 08             	mov    0x8(%ebp),%eax
80102b19:	83 c0 20             	add    $0x20,%eax
80102b1c:	89 c2                	mov    %eax,%edx
80102b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b21:	83 c0 08             	add    $0x8,%eax
80102b24:	01 c0                	add    %eax,%eax
80102b26:	52                   	push   %edx
80102b27:	50                   	push   %eax
80102b28:	e8 23 ff ff ff       	call   80102a50 <ioapicwrite>
80102b2d:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b30:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b33:	c1 e0 18             	shl    $0x18,%eax
80102b36:	89 c2                	mov    %eax,%edx
80102b38:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3b:	83 c0 08             	add    $0x8,%eax
80102b3e:	01 c0                	add    %eax,%eax
80102b40:	83 c0 01             	add    $0x1,%eax
80102b43:	52                   	push   %edx
80102b44:	50                   	push   %eax
80102b45:	e8 06 ff ff ff       	call   80102a50 <ioapicwrite>
80102b4a:	83 c4 08             	add    $0x8,%esp
}
80102b4d:	90                   	nop
80102b4e:	c9                   	leave  
80102b4f:	c3                   	ret    

80102b50 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b50:	55                   	push   %ebp
80102b51:	89 e5                	mov    %esp,%ebp
80102b53:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b56:	83 ec 08             	sub    $0x8,%esp
80102b59:	68 2e a8 10 80       	push   $0x8010a82e
80102b5e:	68 00 71 11 80       	push   $0x80117100
80102b63:	e8 a8 21 00 00       	call   80104d10 <initlock>
80102b68:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6b:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b72:	00 00 00 
  freerange(vstart, vend);
80102b75:	83 ec 08             	sub    $0x8,%esp
80102b78:	ff 75 0c             	push   0xc(%ebp)
80102b7b:	ff 75 08             	push   0x8(%ebp)
80102b7e:	e8 2a 00 00 00       	call   80102bad <freerange>
80102b83:	83 c4 10             	add    $0x10,%esp
}
80102b86:	90                   	nop
80102b87:	c9                   	leave  
80102b88:	c3                   	ret    

80102b89 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b89:	55                   	push   %ebp
80102b8a:	89 e5                	mov    %esp,%ebp
80102b8c:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8f:	83 ec 08             	sub    $0x8,%esp
80102b92:	ff 75 0c             	push   0xc(%ebp)
80102b95:	ff 75 08             	push   0x8(%ebp)
80102b98:	e8 10 00 00 00       	call   80102bad <freerange>
80102b9d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ba0:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102ba7:	00 00 00 
}
80102baa:	90                   	nop
80102bab:	c9                   	leave  
80102bac:	c3                   	ret    

80102bad <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bad:	55                   	push   %ebp
80102bae:	89 e5                	mov    %esp,%ebp
80102bb0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc3:	eb 15                	jmp    80102bda <freerange+0x2d>
    kfree(p);
80102bc5:	83 ec 0c             	sub    $0xc,%esp
80102bc8:	ff 75 f4             	push   -0xc(%ebp)
80102bcb:	e8 1b 00 00 00       	call   80102beb <kfree>
80102bd0:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdd:	05 00 10 00 00       	add    $0x1000,%eax
80102be2:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be5:	73 de                	jae    80102bc5 <freerange+0x18>
}
80102be7:	90                   	nop
80102be8:	90                   	nop
80102be9:	c9                   	leave  
80102bea:	c3                   	ret    

80102beb <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102beb:	55                   	push   %ebp
80102bec:	89 e5                	mov    %esp,%ebp
80102bee:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf4:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf9:	85 c0                	test   %eax,%eax
80102bfb:	75 18                	jne    80102c15 <kfree+0x2a>
80102bfd:	81 7d 08 00 b0 11 80 	cmpl   $0x8011b000,0x8(%ebp)
80102c04:	72 0f                	jb     80102c15 <kfree+0x2a>
80102c06:	8b 45 08             	mov    0x8(%ebp),%eax
80102c09:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0e:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c13:	76 0d                	jbe    80102c22 <kfree+0x37>
    panic("kfree");
80102c15:	83 ec 0c             	sub    $0xc,%esp
80102c18:	68 33 a8 10 80       	push   $0x8010a833
80102c1d:	e8 87 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c22:	83 ec 04             	sub    $0x4,%esp
80102c25:	68 00 10 00 00       	push   $0x1000
80102c2a:	6a 01                	push   $0x1
80102c2c:	ff 75 08             	push   0x8(%ebp)
80102c2f:	e8 74 23 00 00       	call   80104fa8 <memset>
80102c34:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c37:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3c:	85 c0                	test   %eax,%eax
80102c3e:	74 10                	je     80102c50 <kfree+0x65>
    acquire(&kmem.lock);
80102c40:	83 ec 0c             	sub    $0xc,%esp
80102c43:	68 00 71 11 80       	push   $0x80117100
80102c48:	e8 e5 20 00 00       	call   80104d32 <acquire>
80102c4d:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c50:	8b 45 08             	mov    0x8(%ebp),%eax
80102c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c56:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5f:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c64:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c69:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c6e:	85 c0                	test   %eax,%eax
80102c70:	74 10                	je     80102c82 <kfree+0x97>
    release(&kmem.lock);
80102c72:	83 ec 0c             	sub    $0xc,%esp
80102c75:	68 00 71 11 80       	push   $0x80117100
80102c7a:	e8 21 21 00 00       	call   80104da0 <release>
80102c7f:	83 c4 10             	add    $0x10,%esp
}
80102c82:	90                   	nop
80102c83:	c9                   	leave  
80102c84:	c3                   	ret    

80102c85 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c85:	55                   	push   %ebp
80102c86:	89 e5                	mov    %esp,%ebp
80102c88:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8b:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c90:	85 c0                	test   %eax,%eax
80102c92:	74 10                	je     80102ca4 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	68 00 71 11 80       	push   $0x80117100
80102c9c:	e8 91 20 00 00       	call   80104d32 <acquire>
80102ca1:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca4:	a1 38 71 11 80       	mov    0x80117138,%eax
80102ca9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb0:	74 0a                	je     80102cbc <kalloc+0x37>
    kmem.freelist = r->next;
80102cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb5:	8b 00                	mov    (%eax),%eax
80102cb7:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cbc:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc1:	85 c0                	test   %eax,%eax
80102cc3:	74 10                	je     80102cd5 <kalloc+0x50>
    release(&kmem.lock);
80102cc5:	83 ec 0c             	sub    $0xc,%esp
80102cc8:	68 00 71 11 80       	push   $0x80117100
80102ccd:	e8 ce 20 00 00       	call   80104da0 <release>
80102cd2:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd8:	c9                   	leave  
80102cd9:	c3                   	ret    

80102cda <inb>:
{
80102cda:	55                   	push   %ebp
80102cdb:	89 e5                	mov    %esp,%ebp
80102cdd:	83 ec 14             	sub    $0x14,%esp
80102ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ceb:	89 c2                	mov    %eax,%edx
80102ced:	ec                   	in     (%dx),%al
80102cee:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf5:	c9                   	leave  
80102cf6:	c3                   	ret    

80102cf7 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf7:	55                   	push   %ebp
80102cf8:	89 e5                	mov    %esp,%ebp
80102cfa:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfd:	6a 64                	push   $0x64
80102cff:	e8 d6 ff ff ff       	call   80102cda <inb>
80102d04:	83 c4 04             	add    $0x4,%esp
80102d07:	0f b6 c0             	movzbl %al,%eax
80102d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d10:	83 e0 01             	and    $0x1,%eax
80102d13:	85 c0                	test   %eax,%eax
80102d15:	75 0a                	jne    80102d21 <kbdgetc+0x2a>
    return -1;
80102d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d1c:	e9 23 01 00 00       	jmp    80102e44 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d21:	6a 60                	push   $0x60
80102d23:	e8 b2 ff ff ff       	call   80102cda <inb>
80102d28:	83 c4 04             	add    $0x4,%esp
80102d2b:	0f b6 c0             	movzbl %al,%eax
80102d2e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d31:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d38:	75 17                	jne    80102d51 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d3a:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d3f:	83 c8 40             	or     $0x40,%eax
80102d42:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d47:	b8 00 00 00 00       	mov    $0x0,%eax
80102d4c:	e9 f3 00 00 00       	jmp    80102e44 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d54:	25 80 00 00 00       	and    $0x80,%eax
80102d59:	85 c0                	test   %eax,%eax
80102d5b:	74 45                	je     80102da2 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5d:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d62:	83 e0 40             	and    $0x40,%eax
80102d65:	85 c0                	test   %eax,%eax
80102d67:	75 08                	jne    80102d71 <kbdgetc+0x7a>
80102d69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6c:	83 e0 7f             	and    $0x7f,%eax
80102d6f:	eb 03                	jmp    80102d74 <kbdgetc+0x7d>
80102d71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d74:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7a:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d7f:	0f b6 00             	movzbl (%eax),%eax
80102d82:	83 c8 40             	or     $0x40,%eax
80102d85:	0f b6 c0             	movzbl %al,%eax
80102d88:	f7 d0                	not    %eax
80102d8a:	89 c2                	mov    %eax,%edx
80102d8c:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d91:	21 d0                	and    %edx,%eax
80102d93:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d98:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9d:	e9 a2 00 00 00       	jmp    80102e44 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da2:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102da7:	83 e0 40             	and    $0x40,%eax
80102daa:	85 c0                	test   %eax,%eax
80102dac:	74 14                	je     80102dc2 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dae:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dba:	83 e0 bf             	and    $0xffffffbf,%eax
80102dbd:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc5:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dca:	0f b6 00             	movzbl (%eax),%eax
80102dcd:	0f b6 d0             	movzbl %al,%edx
80102dd0:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dd5:	09 d0                	or     %edx,%eax
80102dd7:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102ddc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ddf:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de4:	0f b6 00             	movzbl (%eax),%eax
80102de7:	0f b6 d0             	movzbl %al,%edx
80102dea:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102def:	31 d0                	xor    %edx,%eax
80102df1:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df6:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfb:	83 e0 03             	and    $0x3,%eax
80102dfe:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e08:	01 d0                	add    %edx,%eax
80102e0a:	0f b6 00             	movzbl (%eax),%eax
80102e0d:	0f b6 c0             	movzbl %al,%eax
80102e10:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e13:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e18:	83 e0 08             	and    $0x8,%eax
80102e1b:	85 c0                	test   %eax,%eax
80102e1d:	74 22                	je     80102e41 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e23:	76 0c                	jbe    80102e31 <kbdgetc+0x13a>
80102e25:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e29:	77 06                	ja     80102e31 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2f:	eb 10                	jmp    80102e41 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e31:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e35:	76 0a                	jbe    80102e41 <kbdgetc+0x14a>
80102e37:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3b:	77 04                	ja     80102e41 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e41:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e44:	c9                   	leave  
80102e45:	c3                   	ret    

80102e46 <kbdintr>:

void
kbdintr(void)
{
80102e46:	55                   	push   %ebp
80102e47:	89 e5                	mov    %esp,%ebp
80102e49:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e4c:	83 ec 0c             	sub    $0xc,%esp
80102e4f:	68 f7 2c 10 80       	push   $0x80102cf7
80102e54:	e8 7d d9 ff ff       	call   801007d6 <consoleintr>
80102e59:	83 c4 10             	add    $0x10,%esp
}
80102e5c:	90                   	nop
80102e5d:	c9                   	leave  
80102e5e:	c3                   	ret    

80102e5f <inb>:
{
80102e5f:	55                   	push   %ebp
80102e60:	89 e5                	mov    %esp,%ebp
80102e62:	83 ec 14             	sub    $0x14,%esp
80102e65:	8b 45 08             	mov    0x8(%ebp),%eax
80102e68:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e70:	89 c2                	mov    %eax,%edx
80102e72:	ec                   	in     (%dx),%al
80102e73:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e76:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e7a:	c9                   	leave  
80102e7b:	c3                   	ret    

80102e7c <outb>:
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 08             	sub    $0x8,%esp
80102e82:	8b 45 08             	mov    0x8(%ebp),%eax
80102e85:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e88:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e8c:	89 d0                	mov    %edx,%eax
80102e8e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e91:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e95:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e99:	ee                   	out    %al,(%dx)
}
80102e9a:	90                   	nop
80102e9b:	c9                   	leave  
80102e9c:	c3                   	ret    

80102e9d <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9d:	55                   	push   %ebp
80102e9e:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea0:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea9:	c1 e0 02             	shl    $0x2,%eax
80102eac:	01 c2                	add    %eax,%edx
80102eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb3:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eb8:	83 c0 20             	add    $0x20,%eax
80102ebb:	8b 00                	mov    (%eax),%eax
}
80102ebd:	90                   	nop
80102ebe:	5d                   	pop    %ebp
80102ebf:	c3                   	ret    

80102ec0 <lapicinit>:

void
lapicinit(void)
{
80102ec0:	55                   	push   %ebp
80102ec1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec3:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec8:	85 c0                	test   %eax,%eax
80102eca:	0f 84 0c 01 00 00    	je     80102fdc <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed0:	68 3f 01 00 00       	push   $0x13f
80102ed5:	6a 3c                	push   $0x3c
80102ed7:	e8 c1 ff ff ff       	call   80102e9d <lapicw>
80102edc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102edf:	6a 0b                	push   $0xb
80102ee1:	68 f8 00 00 00       	push   $0xf8
80102ee6:	e8 b2 ff ff ff       	call   80102e9d <lapicw>
80102eeb:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eee:	68 20 00 02 00       	push   $0x20020
80102ef3:	68 c8 00 00 00       	push   $0xc8
80102ef8:	e8 a0 ff ff ff       	call   80102e9d <lapicw>
80102efd:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f00:	68 80 96 98 00       	push   $0x989680
80102f05:	68 e0 00 00 00       	push   $0xe0
80102f0a:	e8 8e ff ff ff       	call   80102e9d <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f12:	68 00 00 01 00       	push   $0x10000
80102f17:	68 d4 00 00 00       	push   $0xd4
80102f1c:	e8 7c ff ff ff       	call   80102e9d <lapicw>
80102f21:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f24:	68 00 00 01 00       	push   $0x10000
80102f29:	68 d8 00 00 00       	push   $0xd8
80102f2e:	e8 6a ff ff ff       	call   80102e9d <lapicw>
80102f33:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f36:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3b:	83 c0 30             	add    $0x30,%eax
80102f3e:	8b 00                	mov    (%eax),%eax
80102f40:	c1 e8 10             	shr    $0x10,%eax
80102f43:	25 fc 00 00 00       	and    $0xfc,%eax
80102f48:	85 c0                	test   %eax,%eax
80102f4a:	74 12                	je     80102f5e <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f4c:	68 00 00 01 00       	push   $0x10000
80102f51:	68 d0 00 00 00       	push   $0xd0
80102f56:	e8 42 ff ff ff       	call   80102e9d <lapicw>
80102f5b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5e:	6a 33                	push   $0x33
80102f60:	68 dc 00 00 00       	push   $0xdc
80102f65:	e8 33 ff ff ff       	call   80102e9d <lapicw>
80102f6a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6d:	6a 00                	push   $0x0
80102f6f:	68 a0 00 00 00       	push   $0xa0
80102f74:	e8 24 ff ff ff       	call   80102e9d <lapicw>
80102f79:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7c:	6a 00                	push   $0x0
80102f7e:	68 a0 00 00 00       	push   $0xa0
80102f83:	e8 15 ff ff ff       	call   80102e9d <lapicw>
80102f88:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8b:	6a 00                	push   $0x0
80102f8d:	6a 2c                	push   $0x2c
80102f8f:	e8 09 ff ff ff       	call   80102e9d <lapicw>
80102f94:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f97:	6a 00                	push   $0x0
80102f99:	68 c4 00 00 00       	push   $0xc4
80102f9e:	e8 fa fe ff ff       	call   80102e9d <lapicw>
80102fa3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa6:	68 00 85 08 00       	push   $0x88500
80102fab:	68 c0 00 00 00       	push   $0xc0
80102fb0:	e8 e8 fe ff ff       	call   80102e9d <lapicw>
80102fb5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb8:	90                   	nop
80102fb9:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbe:	05 00 03 00 00       	add    $0x300,%eax
80102fc3:	8b 00                	mov    (%eax),%eax
80102fc5:	25 00 10 00 00       	and    $0x1000,%eax
80102fca:	85 c0                	test   %eax,%eax
80102fcc:	75 eb                	jne    80102fb9 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fce:	6a 00                	push   $0x0
80102fd0:	6a 20                	push   $0x20
80102fd2:	e8 c6 fe ff ff       	call   80102e9d <lapicw>
80102fd7:	83 c4 08             	add    $0x8,%esp
80102fda:	eb 01                	jmp    80102fdd <lapicinit+0x11d>
    return;
80102fdc:	90                   	nop
}
80102fdd:	c9                   	leave  
80102fde:	c3                   	ret    

80102fdf <lapicid>:

int
lapicid(void)
{
80102fdf:	55                   	push   %ebp
80102fe0:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe7:	85 c0                	test   %eax,%eax
80102fe9:	75 07                	jne    80102ff2 <lapicid+0x13>
    return 0;
80102feb:	b8 00 00 00 00       	mov    $0x0,%eax
80102ff0:	eb 0d                	jmp    80102fff <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff7:	83 c0 20             	add    $0x20,%eax
80102ffa:	8b 00                	mov    (%eax),%eax
80102ffc:	c1 e8 18             	shr    $0x18,%eax
}
80102fff:	5d                   	pop    %ebp
80103000:	c3                   	ret    

80103001 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103001:	55                   	push   %ebp
80103002:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103004:	a1 40 71 11 80       	mov    0x80117140,%eax
80103009:	85 c0                	test   %eax,%eax
8010300b:	74 0c                	je     80103019 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300d:	6a 00                	push   $0x0
8010300f:	6a 2c                	push   $0x2c
80103011:	e8 87 fe ff ff       	call   80102e9d <lapicw>
80103016:	83 c4 08             	add    $0x8,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
}
8010301f:	90                   	nop
80103020:	5d                   	pop    %ebp
80103021:	c3                   	ret    

80103022 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103022:	55                   	push   %ebp
80103023:	89 e5                	mov    %esp,%ebp
80103025:	83 ec 14             	sub    $0x14,%esp
80103028:	8b 45 08             	mov    0x8(%ebp),%eax
8010302b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302e:	6a 0f                	push   $0xf
80103030:	6a 70                	push   $0x70
80103032:	e8 45 fe ff ff       	call   80102e7c <outb>
80103037:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010303a:	6a 0a                	push   $0xa
8010303c:	6a 71                	push   $0x71
8010303e:	e8 39 fe ff ff       	call   80102e7c <outb>
80103043:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103046:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103050:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103055:	8b 45 0c             	mov    0xc(%ebp),%eax
80103058:	c1 e8 04             	shr    $0x4,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103060:	83 c0 02             	add    $0x2,%eax
80103063:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103066:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010306a:	c1 e0 18             	shl    $0x18,%eax
8010306d:	50                   	push   %eax
8010306e:	68 c4 00 00 00       	push   $0xc4
80103073:	e8 25 fe ff ff       	call   80102e9d <lapicw>
80103078:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307b:	68 00 c5 00 00       	push   $0xc500
80103080:	68 c0 00 00 00       	push   $0xc0
80103085:	e8 13 fe ff ff       	call   80102e9d <lapicw>
8010308a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308d:	68 c8 00 00 00       	push   $0xc8
80103092:	e8 85 ff ff ff       	call   8010301c <microdelay>
80103097:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010309a:	68 00 85 00 00       	push   $0x8500
8010309f:	68 c0 00 00 00       	push   $0xc0
801030a4:	e8 f4 fd ff ff       	call   80102e9d <lapicw>
801030a9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ac:	6a 64                	push   $0x64
801030ae:	e8 69 ff ff ff       	call   8010301c <microdelay>
801030b3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bd:	eb 3d                	jmp    801030fc <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030bf:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c3:	c1 e0 18             	shl    $0x18,%eax
801030c6:	50                   	push   %eax
801030c7:	68 c4 00 00 00       	push   $0xc4
801030cc:	e8 cc fd ff ff       	call   80102e9d <lapicw>
801030d1:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d7:	c1 e8 0c             	shr    $0xc,%eax
801030da:	80 cc 06             	or     $0x6,%ah
801030dd:	50                   	push   %eax
801030de:	68 c0 00 00 00       	push   $0xc0
801030e3:	e8 b5 fd ff ff       	call   80102e9d <lapicw>
801030e8:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030eb:	68 c8 00 00 00       	push   $0xc8
801030f0:	e8 27 ff ff ff       	call   8010301c <microdelay>
801030f5:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fc:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103100:	7e bd                	jle    801030bf <lapicstartap+0x9d>
  }
}
80103102:	90                   	nop
80103103:	90                   	nop
80103104:	c9                   	leave  
80103105:	c3                   	ret    

80103106 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103106:	55                   	push   %ebp
80103107:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103109:	8b 45 08             	mov    0x8(%ebp),%eax
8010310c:	0f b6 c0             	movzbl %al,%eax
8010310f:	50                   	push   %eax
80103110:	6a 70                	push   $0x70
80103112:	e8 65 fd ff ff       	call   80102e7c <outb>
80103117:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010311a:	68 c8 00 00 00       	push   $0xc8
8010311f:	e8 f8 fe ff ff       	call   8010301c <microdelay>
80103124:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103127:	6a 71                	push   $0x71
80103129:	e8 31 fd ff ff       	call   80102e5f <inb>
8010312e:	83 c4 04             	add    $0x4,%esp
80103131:	0f b6 c0             	movzbl %al,%eax
}
80103134:	c9                   	leave  
80103135:	c3                   	ret    

80103136 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103136:	55                   	push   %ebp
80103137:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103139:	6a 00                	push   $0x0
8010313b:	e8 c6 ff ff ff       	call   80103106 <cmos_read>
80103140:	83 c4 04             	add    $0x4,%esp
80103143:	8b 55 08             	mov    0x8(%ebp),%edx
80103146:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103148:	6a 02                	push   $0x2
8010314a:	e8 b7 ff ff ff       	call   80103106 <cmos_read>
8010314f:	83 c4 04             	add    $0x4,%esp
80103152:	8b 55 08             	mov    0x8(%ebp),%edx
80103155:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103158:	6a 04                	push   $0x4
8010315a:	e8 a7 ff ff ff       	call   80103106 <cmos_read>
8010315f:	83 c4 04             	add    $0x4,%esp
80103162:	8b 55 08             	mov    0x8(%ebp),%edx
80103165:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103168:	6a 07                	push   $0x7
8010316a:	e8 97 ff ff ff       	call   80103106 <cmos_read>
8010316f:	83 c4 04             	add    $0x4,%esp
80103172:	8b 55 08             	mov    0x8(%ebp),%edx
80103175:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103178:	6a 08                	push   $0x8
8010317a:	e8 87 ff ff ff       	call   80103106 <cmos_read>
8010317f:	83 c4 04             	add    $0x4,%esp
80103182:	8b 55 08             	mov    0x8(%ebp),%edx
80103185:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103188:	6a 09                	push   $0x9
8010318a:	e8 77 ff ff ff       	call   80103106 <cmos_read>
8010318f:	83 c4 04             	add    $0x4,%esp
80103192:	8b 55 08             	mov    0x8(%ebp),%edx
80103195:	89 42 14             	mov    %eax,0x14(%edx)
}
80103198:	90                   	nop
80103199:	c9                   	leave  
8010319a:	c3                   	ret    

8010319b <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319b:	55                   	push   %ebp
8010319c:	89 e5                	mov    %esp,%ebp
8010319e:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a1:	6a 0b                	push   $0xb
801031a3:	e8 5e ff ff ff       	call   80103106 <cmos_read>
801031a8:	83 c4 04             	add    $0x4,%esp
801031ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b1:	83 e0 04             	and    $0x4,%eax
801031b4:	85 c0                	test   %eax,%eax
801031b6:	0f 94 c0             	sete   %al
801031b9:	0f b6 c0             	movzbl %al,%eax
801031bc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031bf:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c2:	50                   	push   %eax
801031c3:	e8 6e ff ff ff       	call   80103136 <fill_rtcdate>
801031c8:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031cb:	6a 0a                	push   $0xa
801031cd:	e8 34 ff ff ff       	call   80103106 <cmos_read>
801031d2:	83 c4 04             	add    $0x4,%esp
801031d5:	25 80 00 00 00       	and    $0x80,%eax
801031da:	85 c0                	test   %eax,%eax
801031dc:	75 27                	jne    80103205 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031de:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e1:	50                   	push   %eax
801031e2:	e8 4f ff ff ff       	call   80103136 <fill_rtcdate>
801031e7:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031ea:	83 ec 04             	sub    $0x4,%esp
801031ed:	6a 18                	push   $0x18
801031ef:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f2:	50                   	push   %eax
801031f3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f6:	50                   	push   %eax
801031f7:	e8 13 1e 00 00       	call   8010500f <memcmp>
801031fc:	83 c4 10             	add    $0x10,%esp
801031ff:	85 c0                	test   %eax,%eax
80103201:	74 05                	je     80103208 <cmostime+0x6d>
80103203:	eb ba                	jmp    801031bf <cmostime+0x24>
        continue;
80103205:	90                   	nop
    fill_rtcdate(&t1);
80103206:	eb b7                	jmp    801031bf <cmostime+0x24>
      break;
80103208:	90                   	nop
  }

  // convert
  if(bcd) {
80103209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320d:	0f 84 b4 00 00 00    	je     801032c7 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103213:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103216:	c1 e8 04             	shr    $0x4,%eax
80103219:	89 c2                	mov    %eax,%edx
8010321b:	89 d0                	mov    %edx,%eax
8010321d:	c1 e0 02             	shl    $0x2,%eax
80103220:	01 d0                	add    %edx,%eax
80103222:	01 c0                	add    %eax,%eax
80103224:	89 c2                	mov    %eax,%edx
80103226:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103229:	83 e0 0f             	and    $0xf,%eax
8010322c:	01 d0                	add    %edx,%eax
8010322e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103231:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103234:	c1 e8 04             	shr    $0x4,%eax
80103237:	89 c2                	mov    %eax,%edx
80103239:	89 d0                	mov    %edx,%eax
8010323b:	c1 e0 02             	shl    $0x2,%eax
8010323e:	01 d0                	add    %edx,%eax
80103240:	01 c0                	add    %eax,%eax
80103242:	89 c2                	mov    %eax,%edx
80103244:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103247:	83 e0 0f             	and    $0xf,%eax
8010324a:	01 d0                	add    %edx,%eax
8010324c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103252:	c1 e8 04             	shr    $0x4,%eax
80103255:	89 c2                	mov    %eax,%edx
80103257:	89 d0                	mov    %edx,%eax
80103259:	c1 e0 02             	shl    $0x2,%eax
8010325c:	01 d0                	add    %edx,%eax
8010325e:	01 c0                	add    %eax,%eax
80103260:	89 c2                	mov    %eax,%edx
80103262:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103265:	83 e0 0f             	and    $0xf,%eax
80103268:	01 d0                	add    %edx,%eax
8010326a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103270:	c1 e8 04             	shr    $0x4,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	89 d0                	mov    %edx,%eax
80103277:	c1 e0 02             	shl    $0x2,%eax
8010327a:	01 d0                	add    %edx,%eax
8010327c:	01 c0                	add    %eax,%eax
8010327e:	89 c2                	mov    %eax,%edx
80103280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103283:	83 e0 0f             	and    $0xf,%eax
80103286:	01 d0                	add    %edx,%eax
80103288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328e:	c1 e8 04             	shr    $0x4,%eax
80103291:	89 c2                	mov    %eax,%edx
80103293:	89 d0                	mov    %edx,%eax
80103295:	c1 e0 02             	shl    $0x2,%eax
80103298:	01 d0                	add    %edx,%eax
8010329a:	01 c0                	add    %eax,%eax
8010329c:	89 c2                	mov    %eax,%edx
8010329e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a1:	83 e0 0f             	and    $0xf,%eax
801032a4:	01 d0                	add    %edx,%eax
801032a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ac:	c1 e8 04             	shr    $0x4,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	89 d0                	mov    %edx,%eax
801032b3:	c1 e0 02             	shl    $0x2,%eax
801032b6:	01 d0                	add    %edx,%eax
801032b8:	01 c0                	add    %eax,%eax
801032ba:	89 c2                	mov    %eax,%edx
801032bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032bf:	83 e0 0f             	and    $0xf,%eax
801032c2:	01 d0                	add    %edx,%eax
801032c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c7:	8b 45 08             	mov    0x8(%ebp),%eax
801032ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cd:	89 10                	mov    %edx,(%eax)
801032cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d2:	89 50 04             	mov    %edx,0x4(%eax)
801032d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d8:	89 50 08             	mov    %edx,0x8(%eax)
801032db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032de:	89 50 0c             	mov    %edx,0xc(%eax)
801032e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e4:	89 50 10             	mov    %edx,0x10(%eax)
801032e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032ea:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ed:	8b 45 08             	mov    0x8(%ebp),%eax
801032f0:	8b 40 14             	mov    0x14(%eax),%eax
801032f3:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f9:	8b 45 08             	mov    0x8(%ebp),%eax
801032fc:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ff:	90                   	nop
80103300:	c9                   	leave  
80103301:	c3                   	ret    

80103302 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103302:	55                   	push   %ebp
80103303:	89 e5                	mov    %esp,%ebp
80103305:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103308:	83 ec 08             	sub    $0x8,%esp
8010330b:	68 39 a8 10 80       	push   $0x8010a839
80103310:	68 60 71 11 80       	push   $0x80117160
80103315:	e8 f6 19 00 00       	call   80104d10 <initlock>
8010331a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331d:	83 ec 08             	sub    $0x8,%esp
80103320:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103323:	50                   	push   %eax
80103324:	ff 75 08             	push   0x8(%ebp)
80103327:	e8 a3 e0 ff ff       	call   801013cf <readsb>
8010332c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103332:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103337:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010333a:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333f:	8b 45 08             	mov    0x8(%ebp),%eax
80103342:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103347:	e8 b3 01 00 00       	call   801034ff <recover_from_log>
}
8010334c:	90                   	nop
8010334d:	c9                   	leave  
8010334e:	c3                   	ret    

8010334f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334f:	55                   	push   %ebp
80103350:	89 e5                	mov    %esp,%ebp
80103352:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103355:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335c:	e9 95 00 00 00       	jmp    801033f6 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103361:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010336a:	01 d0                	add    %edx,%eax
8010336c:	83 c0 01             	add    $0x1,%eax
8010336f:	89 c2                	mov    %eax,%edx
80103371:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103376:	83 ec 08             	sub    $0x8,%esp
80103379:	52                   	push   %edx
8010337a:	50                   	push   %eax
8010337b:	e8 81 ce ff ff       	call   80100201 <bread>
80103380:	83 c4 10             	add    $0x10,%esp
80103383:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103389:	83 c0 10             	add    $0x10,%eax
8010338c:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103393:	89 c2                	mov    %eax,%edx
80103395:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010339a:	83 ec 08             	sub    $0x8,%esp
8010339d:	52                   	push   %edx
8010339e:	50                   	push   %eax
8010339f:	e8 5d ce ff ff       	call   80100201 <bread>
801033a4:	83 c4 10             	add    $0x10,%esp
801033a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ad:	8d 50 5c             	lea    0x5c(%eax),%edx
801033b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b3:	83 c0 5c             	add    $0x5c,%eax
801033b6:	83 ec 04             	sub    $0x4,%esp
801033b9:	68 00 02 00 00       	push   $0x200
801033be:	52                   	push   %edx
801033bf:	50                   	push   %eax
801033c0:	e8 a2 1c 00 00       	call   80105067 <memmove>
801033c5:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c8:	83 ec 0c             	sub    $0xc,%esp
801033cb:	ff 75 ec             	push   -0x14(%ebp)
801033ce:	e8 67 ce ff ff       	call   8010023a <bwrite>
801033d3:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d6:	83 ec 0c             	sub    $0xc,%esp
801033d9:	ff 75 f0             	push   -0x10(%ebp)
801033dc:	e8 a2 ce ff ff       	call   80100283 <brelse>
801033e1:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e4:	83 ec 0c             	sub    $0xc,%esp
801033e7:	ff 75 ec             	push   -0x14(%ebp)
801033ea:	e8 94 ce ff ff       	call   80100283 <brelse>
801033ef:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fe:	0f 8c 5d ff ff ff    	jl     80103361 <install_trans+0x12>
  }
}
80103404:	90                   	nop
80103405:	90                   	nop
80103406:	c9                   	leave  
80103407:	c3                   	ret    

80103408 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103408:	55                   	push   %ebp
80103409:	89 e5                	mov    %esp,%ebp
8010340b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340e:	a1 94 71 11 80       	mov    0x80117194,%eax
80103413:	89 c2                	mov    %eax,%edx
80103415:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010341a:	83 ec 08             	sub    $0x8,%esp
8010341d:	52                   	push   %edx
8010341e:	50                   	push   %eax
8010341f:	e8 dd cd ff ff       	call   80100201 <bread>
80103424:	83 c4 10             	add    $0x10,%esp
80103427:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010342a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342d:	83 c0 5c             	add    $0x5c,%eax
80103430:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103436:	8b 00                	mov    (%eax),%eax
80103438:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103444:	eb 1b                	jmp    80103461 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103446:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103449:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103450:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103453:	83 c2 10             	add    $0x10,%edx
80103456:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103461:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103466:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103469:	7c db                	jl     80103446 <read_head+0x3e>
  }
  brelse(buf);
8010346b:	83 ec 0c             	sub    $0xc,%esp
8010346e:	ff 75 f0             	push   -0x10(%ebp)
80103471:	e8 0d ce ff ff       	call   80100283 <brelse>
80103476:	83 c4 10             	add    $0x10,%esp
}
80103479:	90                   	nop
8010347a:	c9                   	leave  
8010347b:	c3                   	ret    

8010347c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347c:	55                   	push   %ebp
8010347d:	89 e5                	mov    %esp,%ebp
8010347f:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103482:	a1 94 71 11 80       	mov    0x80117194,%eax
80103487:	89 c2                	mov    %eax,%edx
80103489:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348e:	83 ec 08             	sub    $0x8,%esp
80103491:	52                   	push   %edx
80103492:	50                   	push   %eax
80103493:	e8 69 cd ff ff       	call   80100201 <bread>
80103498:	83 c4 10             	add    $0x10,%esp
8010349b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a1:	83 c0 5c             	add    $0x5c,%eax
801034a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a7:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b0:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b9:	eb 1b                	jmp    801034d6 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034be:	83 c0 10             	add    $0x10,%eax
801034c1:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034ce:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034de:	7c db                	jl     801034bb <write_head+0x3f>
  }
  bwrite(buf);
801034e0:	83 ec 0c             	sub    $0xc,%esp
801034e3:	ff 75 f0             	push   -0x10(%ebp)
801034e6:	e8 4f cd ff ff       	call   8010023a <bwrite>
801034eb:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ee:	83 ec 0c             	sub    $0xc,%esp
801034f1:	ff 75 f0             	push   -0x10(%ebp)
801034f4:	e8 8a cd ff ff       	call   80100283 <brelse>
801034f9:	83 c4 10             	add    $0x10,%esp
}
801034fc:	90                   	nop
801034fd:	c9                   	leave  
801034fe:	c3                   	ret    

801034ff <recover_from_log>:

static void
recover_from_log(void)
{
801034ff:	55                   	push   %ebp
80103500:	89 e5                	mov    %esp,%ebp
80103502:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103505:	e8 fe fe ff ff       	call   80103408 <read_head>
  install_trans(); // if committed, copy from log to disk
8010350a:	e8 40 fe ff ff       	call   8010334f <install_trans>
  log.lh.n = 0;
8010350f:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103516:	00 00 00 
  write_head(); // clear the log
80103519:	e8 5e ff ff ff       	call   8010347c <write_head>
}
8010351e:	90                   	nop
8010351f:	c9                   	leave  
80103520:	c3                   	ret    

80103521 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103521:	55                   	push   %ebp
80103522:	89 e5                	mov    %esp,%ebp
80103524:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103527:	83 ec 0c             	sub    $0xc,%esp
8010352a:	68 60 71 11 80       	push   $0x80117160
8010352f:	e8 fe 17 00 00       	call   80104d32 <acquire>
80103534:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103537:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353c:	85 c0                	test   %eax,%eax
8010353e:	74 17                	je     80103557 <begin_op+0x36>
      sleep(&log, &log.lock);
80103540:	83 ec 08             	sub    $0x8,%esp
80103543:	68 60 71 11 80       	push   $0x80117160
80103548:	68 60 71 11 80       	push   $0x80117160
8010354d:	e8 6c 12 00 00       	call   801047be <sleep>
80103552:	83 c4 10             	add    $0x10,%esp
80103555:	eb e0                	jmp    80103537 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103557:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355d:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103562:	8d 50 01             	lea    0x1(%eax),%edx
80103565:	89 d0                	mov    %edx,%eax
80103567:	c1 e0 02             	shl    $0x2,%eax
8010356a:	01 d0                	add    %edx,%eax
8010356c:	01 c0                	add    %eax,%eax
8010356e:	01 c8                	add    %ecx,%eax
80103570:	83 f8 1e             	cmp    $0x1e,%eax
80103573:	7e 17                	jle    8010358c <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103575:	83 ec 08             	sub    $0x8,%esp
80103578:	68 60 71 11 80       	push   $0x80117160
8010357d:	68 60 71 11 80       	push   $0x80117160
80103582:	e8 37 12 00 00       	call   801047be <sleep>
80103587:	83 c4 10             	add    $0x10,%esp
8010358a:	eb ab                	jmp    80103537 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103591:	83 c0 01             	add    $0x1,%eax
80103594:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103599:	83 ec 0c             	sub    $0xc,%esp
8010359c:	68 60 71 11 80       	push   $0x80117160
801035a1:	e8 fa 17 00 00       	call   80104da0 <release>
801035a6:	83 c4 10             	add    $0x10,%esp
      break;
801035a9:	90                   	nop
    }
  }
}
801035aa:	90                   	nop
801035ab:	c9                   	leave  
801035ac:	c3                   	ret    

801035ad <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ad:	55                   	push   %ebp
801035ae:	89 e5                	mov    %esp,%ebp
801035b0:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ba:	83 ec 0c             	sub    $0xc,%esp
801035bd:	68 60 71 11 80       	push   $0x80117160
801035c2:	e8 6b 17 00 00       	call   80104d32 <acquire>
801035c7:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035ca:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035cf:	83 e8 01             	sub    $0x1,%eax
801035d2:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d7:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035dc:	85 c0                	test   %eax,%eax
801035de:	74 0d                	je     801035ed <end_op+0x40>
    panic("log.committing");
801035e0:	83 ec 0c             	sub    $0xc,%esp
801035e3:	68 3d a8 10 80       	push   $0x8010a83d
801035e8:	e8 bc cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ed:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f2:	85 c0                	test   %eax,%eax
801035f4:	75 13                	jne    80103609 <end_op+0x5c>
    do_commit = 1;
801035f6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fd:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103604:	00 00 00 
80103607:	eb 10                	jmp    80103619 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103609:	83 ec 0c             	sub    $0xc,%esp
8010360c:	68 60 71 11 80       	push   $0x80117160
80103611:	e8 8f 12 00 00       	call   801048a5 <wakeup>
80103616:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103619:	83 ec 0c             	sub    $0xc,%esp
8010361c:	68 60 71 11 80       	push   $0x80117160
80103621:	e8 7a 17 00 00       	call   80104da0 <release>
80103626:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362d:	74 3f                	je     8010366e <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362f:	e8 f6 00 00 00       	call   8010372a <commit>
    acquire(&log.lock);
80103634:	83 ec 0c             	sub    $0xc,%esp
80103637:	68 60 71 11 80       	push   $0x80117160
8010363c:	e8 f1 16 00 00       	call   80104d32 <acquire>
80103641:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103644:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364b:	00 00 00 
    wakeup(&log);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	68 60 71 11 80       	push   $0x80117160
80103656:	e8 4a 12 00 00       	call   801048a5 <wakeup>
8010365b:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365e:	83 ec 0c             	sub    $0xc,%esp
80103661:	68 60 71 11 80       	push   $0x80117160
80103666:	e8 35 17 00 00       	call   80104da0 <release>
8010366b:	83 c4 10             	add    $0x10,%esp
  }
}
8010366e:	90                   	nop
8010366f:	c9                   	leave  
80103670:	c3                   	ret    

80103671 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103671:	55                   	push   %ebp
80103672:	89 e5                	mov    %esp,%ebp
80103674:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367e:	e9 95 00 00 00       	jmp    80103718 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103683:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368c:	01 d0                	add    %edx,%eax
8010368e:	83 c0 01             	add    $0x1,%eax
80103691:	89 c2                	mov    %eax,%edx
80103693:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103698:	83 ec 08             	sub    $0x8,%esp
8010369b:	52                   	push   %edx
8010369c:	50                   	push   %eax
8010369d:	e8 5f cb ff ff       	call   80100201 <bread>
801036a2:	83 c4 10             	add    $0x10,%esp
801036a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ab:	83 c0 10             	add    $0x10,%eax
801036ae:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b5:	89 c2                	mov    %eax,%edx
801036b7:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bc:	83 ec 08             	sub    $0x8,%esp
801036bf:	52                   	push   %edx
801036c0:	50                   	push   %eax
801036c1:	e8 3b cb ff ff       	call   80100201 <bread>
801036c6:	83 c4 10             	add    $0x10,%esp
801036c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d5:	83 c0 5c             	add    $0x5c,%eax
801036d8:	83 ec 04             	sub    $0x4,%esp
801036db:	68 00 02 00 00       	push   $0x200
801036e0:	52                   	push   %edx
801036e1:	50                   	push   %eax
801036e2:	e8 80 19 00 00       	call   80105067 <memmove>
801036e7:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036ea:	83 ec 0c             	sub    $0xc,%esp
801036ed:	ff 75 f0             	push   -0x10(%ebp)
801036f0:	e8 45 cb ff ff       	call   8010023a <bwrite>
801036f5:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f8:	83 ec 0c             	sub    $0xc,%esp
801036fb:	ff 75 ec             	push   -0x14(%ebp)
801036fe:	e8 80 cb ff ff       	call   80100283 <brelse>
80103703:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103706:	83 ec 0c             	sub    $0xc,%esp
80103709:	ff 75 f0             	push   -0x10(%ebp)
8010370c:	e8 72 cb ff ff       	call   80100283 <brelse>
80103711:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103714:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103718:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103720:	0f 8c 5d ff ff ff    	jl     80103683 <write_log+0x12>
  }
}
80103726:	90                   	nop
80103727:	90                   	nop
80103728:	c9                   	leave  
80103729:	c3                   	ret    

8010372a <commit>:

static void
commit()
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103730:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	7e 1e                	jle    80103757 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103739:	e8 33 ff ff ff       	call   80103671 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373e:	e8 39 fd ff ff       	call   8010347c <write_head>
    install_trans(); // Now install writes to home locations
80103743:	e8 07 fc ff ff       	call   8010334f <install_trans>
    log.lh.n = 0;
80103748:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103752:	e8 25 fd ff ff       	call   8010347c <write_head>
  }
}
80103757:	90                   	nop
80103758:	c9                   	leave  
80103759:	c3                   	ret    

8010375a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010375a:	55                   	push   %ebp
8010375b:	89 e5                	mov    %esp,%ebp
8010375d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103760:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103765:	83 f8 1d             	cmp    $0x1d,%eax
80103768:	7f 12                	jg     8010377c <log_write+0x22>
8010376a:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010376f:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103775:	83 ea 01             	sub    $0x1,%edx
80103778:	39 d0                	cmp    %edx,%eax
8010377a:	7c 0d                	jl     80103789 <log_write+0x2f>
    panic("too big a transaction");
8010377c:	83 ec 0c             	sub    $0xc,%esp
8010377f:	68 4c a8 10 80       	push   $0x8010a84c
80103784:	e8 20 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103789:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378e:	85 c0                	test   %eax,%eax
80103790:	7f 0d                	jg     8010379f <log_write+0x45>
    panic("log_write outside of trans");
80103792:	83 ec 0c             	sub    $0xc,%esp
80103795:	68 62 a8 10 80       	push   $0x8010a862
8010379a:	e8 0a ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	68 60 71 11 80       	push   $0x80117160
801037a7:	e8 86 15 00 00       	call   80104d32 <acquire>
801037ac:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b6:	eb 1d                	jmp    801037d5 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037bb:	83 c0 10             	add    $0x10,%eax
801037be:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c5:	89 c2                	mov    %eax,%edx
801037c7:	8b 45 08             	mov    0x8(%ebp),%eax
801037ca:	8b 40 08             	mov    0x8(%eax),%eax
801037cd:	39 c2                	cmp    %eax,%edx
801037cf:	74 10                	je     801037e1 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dd:	7c d9                	jl     801037b8 <log_write+0x5e>
801037df:	eb 01                	jmp    801037e2 <log_write+0x88>
      break;
801037e1:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e2:	8b 45 08             	mov    0x8(%ebp),%eax
801037e5:	8b 40 08             	mov    0x8(%eax),%eax
801037e8:	89 c2                	mov    %eax,%edx
801037ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ed:	83 c0 10             	add    $0x10,%eax
801037f0:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f7:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037ff:	75 0d                	jne    8010380e <log_write+0xb4>
    log.lh.n++;
80103801:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103806:	83 c0 01             	add    $0x1,%eax
80103809:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380e:	8b 45 08             	mov    0x8(%ebp),%eax
80103811:	8b 00                	mov    (%eax),%eax
80103813:	83 c8 04             	or     $0x4,%eax
80103816:	89 c2                	mov    %eax,%edx
80103818:	8b 45 08             	mov    0x8(%ebp),%eax
8010381b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381d:	83 ec 0c             	sub    $0xc,%esp
80103820:	68 60 71 11 80       	push   $0x80117160
80103825:	e8 76 15 00 00       	call   80104da0 <release>
8010382a:	83 c4 10             	add    $0x10,%esp
}
8010382d:	90                   	nop
8010382e:	c9                   	leave  
8010382f:	c3                   	ret    

80103830 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103830:	55                   	push   %ebp
80103831:	89 e5                	mov    %esp,%ebp
80103833:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103836:	8b 55 08             	mov    0x8(%ebp),%edx
80103839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383f:	f0 87 02             	lock xchg %eax,(%edx)
80103842:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103848:	c9                   	leave  
80103849:	c3                   	ret    

8010384a <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010384a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384e:	83 e4 f0             	and    $0xfffffff0,%esp
80103851:	ff 71 fc             	push   -0x4(%ecx)
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	51                   	push   %ecx
80103858:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385b:	e8 df 4b 00 00       	call   8010843f <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103860:	83 ec 08             	sub    $0x8,%esp
80103863:	68 00 00 40 80       	push   $0x80400000
80103868:	68 00 b0 11 80       	push   $0x8011b000
8010386d:	e8 de f2 ff ff       	call   80102b50 <kinit1>
80103872:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103875:	e8 f4 41 00 00       	call   80107a6e <kvmalloc>
  mpinit_uefi();
8010387a:	e8 86 49 00 00       	call   80108205 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387f:	e8 3c f6 ff ff       	call   80102ec0 <lapicinit>
  seginit();       // segment descriptors
80103884:	e8 7d 3c 00 00       	call   80107506 <seginit>
  picinit();    // disable pic
80103889:	e8 9d 01 00 00       	call   80103a2b <picinit>
  ioapicinit();    // another interrupt controller
8010388e:	e8 d8 f1 ff ff       	call   80102a6b <ioapicinit>
  consoleinit();   // console hardware
80103893:	e8 67 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103898:	e8 02 30 00 00       	call   8010689f <uartinit>
  pinit();         // process table
8010389d:	e8 c2 05 00 00       	call   80103e64 <pinit>
  tvinit();        // trap vectors
801038a2:	e8 eb 2a 00 00       	call   80106392 <tvinit>
  binit();         // buffer cache
801038a7:	e8 ba c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ac:	e8 0f d7 ff ff       	call   80100fc0 <fileinit>
  ideinit();       // disk 
801038b1:	e8 6e ed ff ff       	call   80102624 <ideinit>
  startothers();   // start other processors
801038b6:	e8 8a 00 00 00       	call   80103945 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038bb:	83 ec 08             	sub    $0x8,%esp
801038be:	68 00 00 00 a0       	push   $0xa0000000
801038c3:	68 00 00 40 80       	push   $0x80400000
801038c8:	e8 bc f2 ff ff       	call   80102b89 <kinit2>
801038cd:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038d0:	e8 c3 4d 00 00       	call   80108698 <pci_init>
  arp_scan();
801038d5:	e8 fa 5a 00 00       	call   801093d4 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038da:	e8 63 07 00 00       	call   80104042 <userinit>

  mpmain();        // finish this processor's setup
801038df:	e8 1a 00 00 00       	call   801038fe <mpmain>

801038e4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e4:	55                   	push   %ebp
801038e5:	89 e5                	mov    %esp,%ebp
801038e7:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038ea:	e8 97 41 00 00       	call   80107a86 <switchkvm>
  seginit();
801038ef:	e8 12 3c 00 00       	call   80107506 <seginit>
  lapicinit();
801038f4:	e8 c7 f5 ff ff       	call   80102ec0 <lapicinit>
  mpmain();
801038f9:	e8 00 00 00 00       	call   801038fe <mpmain>

801038fe <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fe:	55                   	push   %ebp
801038ff:	89 e5                	mov    %esp,%ebp
80103901:	53                   	push   %ebx
80103902:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103905:	e8 78 05 00 00       	call   80103e82 <cpuid>
8010390a:	89 c3                	mov    %eax,%ebx
8010390c:	e8 71 05 00 00       	call   80103e82 <cpuid>
80103911:	83 ec 04             	sub    $0x4,%esp
80103914:	53                   	push   %ebx
80103915:	50                   	push   %eax
80103916:	68 7d a8 10 80       	push   $0x8010a87d
8010391b:	e8 d4 ca ff ff       	call   801003f4 <cprintf>
80103920:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103923:	e8 e0 2b 00 00       	call   80106508 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103928:	e8 70 05 00 00       	call   80103e9d <mycpu>
8010392d:	05 a0 00 00 00       	add    $0xa0,%eax
80103932:	83 ec 08             	sub    $0x8,%esp
80103935:	6a 01                	push   $0x1
80103937:	50                   	push   %eax
80103938:	e8 f3 fe ff ff       	call   80103830 <xchg>
8010393d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103940:	e8 88 0c 00 00       	call   801045cd <scheduler>

80103945 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103945:	55                   	push   %ebp
80103946:	89 e5                	mov    %esp,%ebp
80103948:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394b:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103952:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103957:	83 ec 04             	sub    $0x4,%esp
8010395a:	50                   	push   %eax
8010395b:	68 18 f5 10 80       	push   $0x8010f518
80103960:	ff 75 f0             	push   -0x10(%ebp)
80103963:	e8 ff 16 00 00       	call   80105067 <memmove>
80103968:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396b:	c7 45 f4 c0 99 11 80 	movl   $0x801199c0,-0xc(%ebp)
80103972:	eb 79                	jmp    801039ed <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103974:	e8 24 05 00 00       	call   80103e9d <mycpu>
80103979:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397c:	74 67                	je     801039e5 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397e:	e8 02 f3 ff ff       	call   80102c85 <kalloc>
80103983:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103989:	83 e8 04             	sub    $0x4,%eax
8010398c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103995:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399a:	83 e8 08             	sub    $0x8,%eax
8010399d:	c7 00 e4 38 10 80    	movl   $0x801038e4,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a3:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b1:	83 e8 0c             	sub    $0xc,%eax
801039b4:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c2:	0f b6 00             	movzbl (%eax),%eax
801039c5:	0f b6 c0             	movzbl %al,%eax
801039c8:	83 ec 08             	sub    $0x8,%esp
801039cb:	52                   	push   %edx
801039cc:	50                   	push   %eax
801039cd:	e8 50 f6 ff ff       	call   80103022 <lapicstartap>
801039d2:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d5:	90                   	nop
801039d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039df:	85 c0                	test   %eax,%eax
801039e1:	74 f3                	je     801039d6 <startothers+0x91>
801039e3:	eb 01                	jmp    801039e6 <startothers+0xa1>
      continue;
801039e5:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e6:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ed:	a1 80 9c 11 80       	mov    0x80119c80,%eax
801039f2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f8:	05 c0 99 11 80       	add    $0x801199c0,%eax
801039fd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a00:	0f 82 6e ff ff ff    	jb     80103974 <startothers+0x2f>
      ;
  }
}
80103a06:	90                   	nop
80103a07:	90                   	nop
80103a08:	c9                   	leave  
80103a09:	c3                   	ret    

80103a0a <outb>:
{
80103a0a:	55                   	push   %ebp
80103a0b:	89 e5                	mov    %esp,%ebp
80103a0d:	83 ec 08             	sub    $0x8,%esp
80103a10:	8b 45 08             	mov    0x8(%ebp),%eax
80103a13:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a16:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a1a:	89 d0                	mov    %edx,%eax
80103a1c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a23:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a27:	ee                   	out    %al,(%dx)
}
80103a28:	90                   	nop
80103a29:	c9                   	leave  
80103a2a:	c3                   	ret    

80103a2b <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a2b:	55                   	push   %ebp
80103a2c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2e:	68 ff 00 00 00       	push   $0xff
80103a33:	6a 21                	push   $0x21
80103a35:	e8 d0 ff ff ff       	call   80103a0a <outb>
80103a3a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3d:	68 ff 00 00 00       	push   $0xff
80103a42:	68 a1 00 00 00       	push   $0xa1
80103a47:	e8 be ff ff ff       	call   80103a0a <outb>
80103a4c:	83 c4 08             	add    $0x8,%esp
}
80103a4f:	90                   	nop
80103a50:	c9                   	leave  
80103a51:	c3                   	ret    

80103a52 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a52:	55                   	push   %ebp
80103a53:	89 e5                	mov    %esp,%ebp
80103a55:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a68:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6b:	8b 10                	mov    (%eax),%edx
80103a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a70:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a72:	e8 67 d5 ff ff       	call   80100fde <filealloc>
80103a77:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7a:	89 02                	mov    %eax,(%edx)
80103a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7f:	8b 00                	mov    (%eax),%eax
80103a81:	85 c0                	test   %eax,%eax
80103a83:	0f 84 c8 00 00 00    	je     80103b51 <pipealloc+0xff>
80103a89:	e8 50 d5 ff ff       	call   80100fde <filealloc>
80103a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a91:	89 02                	mov    %eax,(%edx)
80103a93:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a96:	8b 00                	mov    (%eax),%eax
80103a98:	85 c0                	test   %eax,%eax
80103a9a:	0f 84 b1 00 00 00    	je     80103b51 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103aa0:	e8 e0 f1 ff ff       	call   80102c85 <kalloc>
80103aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aac:	0f 84 a2 00 00 00    	je     80103b54 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab5:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103abc:	00 00 00 
  p->writeopen = 1;
80103abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac2:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac9:	00 00 00 
  p->nwrite = 0;
80103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acf:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad6:	00 00 00 
  p->nread = 0;
80103ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adc:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae3:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	83 ec 08             	sub    $0x8,%esp
80103aec:	68 91 a8 10 80       	push   $0x8010a891
80103af1:	50                   	push   %eax
80103af2:	e8 19 12 00 00       	call   80104d10 <initlock>
80103af7:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103afa:	8b 45 08             	mov    0x8(%ebp),%eax
80103afd:	8b 00                	mov    (%eax),%eax
80103aff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b05:	8b 45 08             	mov    0x8(%ebp),%eax
80103b08:	8b 00                	mov    (%eax),%eax
80103b0a:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b11:	8b 00                	mov    (%eax),%eax
80103b13:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b17:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1a:	8b 00                	mov    (%eax),%eax
80103b1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1f:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b25:	8b 00                	mov    (%eax),%eax
80103b27:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b30:	8b 00                	mov    (%eax),%eax
80103b32:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b36:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b39:	8b 00                	mov    (%eax),%eax
80103b3b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b42:	8b 00                	mov    (%eax),%eax
80103b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b47:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b4a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4f:	eb 51                	jmp    80103ba2 <pipealloc+0x150>
    goto bad;
80103b51:	90                   	nop
80103b52:	eb 01                	jmp    80103b55 <pipealloc+0x103>
    goto bad;
80103b54:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b59:	74 0e                	je     80103b69 <pipealloc+0x117>
    kfree((char*)p);
80103b5b:	83 ec 0c             	sub    $0xc,%esp
80103b5e:	ff 75 f4             	push   -0xc(%ebp)
80103b61:	e8 85 f0 ff ff       	call   80102beb <kfree>
80103b66:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b69:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6c:	8b 00                	mov    (%eax),%eax
80103b6e:	85 c0                	test   %eax,%eax
80103b70:	74 11                	je     80103b83 <pipealloc+0x131>
    fileclose(*f0);
80103b72:	8b 45 08             	mov    0x8(%ebp),%eax
80103b75:	8b 00                	mov    (%eax),%eax
80103b77:	83 ec 0c             	sub    $0xc,%esp
80103b7a:	50                   	push   %eax
80103b7b:	e8 1c d5 ff ff       	call   8010109c <fileclose>
80103b80:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b83:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b86:	8b 00                	mov    (%eax),%eax
80103b88:	85 c0                	test   %eax,%eax
80103b8a:	74 11                	je     80103b9d <pipealloc+0x14b>
    fileclose(*f1);
80103b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8f:	8b 00                	mov    (%eax),%eax
80103b91:	83 ec 0c             	sub    $0xc,%esp
80103b94:	50                   	push   %eax
80103b95:	e8 02 d5 ff ff       	call   8010109c <fileclose>
80103b9a:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ba2:	c9                   	leave  
80103ba3:	c3                   	ret    

80103ba4 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba4:	55                   	push   %ebp
80103ba5:	89 e5                	mov    %esp,%ebp
80103ba7:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103baa:	8b 45 08             	mov    0x8(%ebp),%eax
80103bad:	83 ec 0c             	sub    $0xc,%esp
80103bb0:	50                   	push   %eax
80103bb1:	e8 7c 11 00 00       	call   80104d32 <acquire>
80103bb6:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bbd:	74 23                	je     80103be2 <pipeclose+0x3e>
    p->writeopen = 0;
80103bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc2:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc9:	00 00 00 
    wakeup(&p->nread);
80103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcf:	05 34 02 00 00       	add    $0x234,%eax
80103bd4:	83 ec 0c             	sub    $0xc,%esp
80103bd7:	50                   	push   %eax
80103bd8:	e8 c8 0c 00 00       	call   801048a5 <wakeup>
80103bdd:	83 c4 10             	add    $0x10,%esp
80103be0:	eb 21                	jmp    80103c03 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103be2:	8b 45 08             	mov    0x8(%ebp),%eax
80103be5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103bec:	00 00 00 
    wakeup(&p->nwrite);
80103bef:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf2:	05 38 02 00 00       	add    $0x238,%eax
80103bf7:	83 ec 0c             	sub    $0xc,%esp
80103bfa:	50                   	push   %eax
80103bfb:	e8 a5 0c 00 00       	call   801048a5 <wakeup>
80103c00:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c03:	8b 45 08             	mov    0x8(%ebp),%eax
80103c06:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c0c:	85 c0                	test   %eax,%eax
80103c0e:	75 2c                	jne    80103c3c <pipeclose+0x98>
80103c10:	8b 45 08             	mov    0x8(%ebp),%eax
80103c13:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c19:	85 c0                	test   %eax,%eax
80103c1b:	75 1f                	jne    80103c3c <pipeclose+0x98>
    release(&p->lock);
80103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c20:	83 ec 0c             	sub    $0xc,%esp
80103c23:	50                   	push   %eax
80103c24:	e8 77 11 00 00       	call   80104da0 <release>
80103c29:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c2c:	83 ec 0c             	sub    $0xc,%esp
80103c2f:	ff 75 08             	push   0x8(%ebp)
80103c32:	e8 b4 ef ff ff       	call   80102beb <kfree>
80103c37:	83 c4 10             	add    $0x10,%esp
80103c3a:	eb 10                	jmp    80103c4c <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3f:	83 ec 0c             	sub    $0xc,%esp
80103c42:	50                   	push   %eax
80103c43:	e8 58 11 00 00       	call   80104da0 <release>
80103c48:	83 c4 10             	add    $0x10,%esp
}
80103c4b:	90                   	nop
80103c4c:	90                   	nop
80103c4d:	c9                   	leave  
80103c4e:	c3                   	ret    

80103c4f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4f:	55                   	push   %ebp
80103c50:	89 e5                	mov    %esp,%ebp
80103c52:	53                   	push   %ebx
80103c53:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c56:	8b 45 08             	mov    0x8(%ebp),%eax
80103c59:	83 ec 0c             	sub    $0xc,%esp
80103c5c:	50                   	push   %eax
80103c5d:	e8 d0 10 00 00       	call   80104d32 <acquire>
80103c62:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c6c:	e9 ad 00 00 00       	jmp    80103d1e <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c71:	8b 45 08             	mov    0x8(%ebp),%eax
80103c74:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c7a:	85 c0                	test   %eax,%eax
80103c7c:	74 0c                	je     80103c8a <pipewrite+0x3b>
80103c7e:	e8 92 02 00 00       	call   80103f15 <myproc>
80103c83:	8b 40 24             	mov    0x24(%eax),%eax
80103c86:	85 c0                	test   %eax,%eax
80103c88:	74 19                	je     80103ca3 <pipewrite+0x54>
        release(&p->lock);
80103c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8d:	83 ec 0c             	sub    $0xc,%esp
80103c90:	50                   	push   %eax
80103c91:	e8 0a 11 00 00       	call   80104da0 <release>
80103c96:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9e:	e9 a9 00 00 00       	jmp    80103d4c <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca6:	05 34 02 00 00       	add    $0x234,%eax
80103cab:	83 ec 0c             	sub    $0xc,%esp
80103cae:	50                   	push   %eax
80103caf:	e8 f1 0b 00 00       	call   801048a5 <wakeup>
80103cb4:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cba:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbd:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc3:	83 ec 08             	sub    $0x8,%esp
80103cc6:	50                   	push   %eax
80103cc7:	52                   	push   %edx
80103cc8:	e8 f1 0a 00 00       	call   801047be <sleep>
80103ccd:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd3:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdc:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ce2:	05 00 02 00 00       	add    $0x200,%eax
80103ce7:	39 c2                	cmp    %eax,%edx
80103ce9:	74 86                	je     80103c71 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ceb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfd:	8d 48 01             	lea    0x1(%eax),%ecx
80103d00:	8b 55 08             	mov    0x8(%ebp),%edx
80103d03:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d09:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0e:	89 c1                	mov    %eax,%ecx
80103d10:	0f b6 13             	movzbl (%ebx),%edx
80103d13:	8b 45 08             	mov    0x8(%ebp),%eax
80103d16:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d21:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d24:	7c aa                	jl     80103cd0 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d26:	8b 45 08             	mov    0x8(%ebp),%eax
80103d29:	05 34 02 00 00       	add    $0x234,%eax
80103d2e:	83 ec 0c             	sub    $0xc,%esp
80103d31:	50                   	push   %eax
80103d32:	e8 6e 0b 00 00       	call   801048a5 <wakeup>
80103d37:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3d:	83 ec 0c             	sub    $0xc,%esp
80103d40:	50                   	push   %eax
80103d41:	e8 5a 10 00 00       	call   80104da0 <release>
80103d46:	83 c4 10             	add    $0x10,%esp
  return n;
80103d49:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4f:	c9                   	leave  
80103d50:	c3                   	ret    

80103d51 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d51:	55                   	push   %ebp
80103d52:	89 e5                	mov    %esp,%ebp
80103d54:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d57:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5a:	83 ec 0c             	sub    $0xc,%esp
80103d5d:	50                   	push   %eax
80103d5e:	e8 cf 0f 00 00       	call   80104d32 <acquire>
80103d63:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d66:	eb 3e                	jmp    80103da6 <piperead+0x55>
    if(myproc()->killed){
80103d68:	e8 a8 01 00 00       	call   80103f15 <myproc>
80103d6d:	8b 40 24             	mov    0x24(%eax),%eax
80103d70:	85 c0                	test   %eax,%eax
80103d72:	74 19                	je     80103d8d <piperead+0x3c>
      release(&p->lock);
80103d74:	8b 45 08             	mov    0x8(%ebp),%eax
80103d77:	83 ec 0c             	sub    $0xc,%esp
80103d7a:	50                   	push   %eax
80103d7b:	e8 20 10 00 00       	call   80104da0 <release>
80103d80:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d88:	e9 be 00 00 00       	jmp    80103e4b <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d90:	8b 55 08             	mov    0x8(%ebp),%edx
80103d93:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d99:	83 ec 08             	sub    $0x8,%esp
80103d9c:	50                   	push   %eax
80103d9d:	52                   	push   %edx
80103d9e:	e8 1b 0a 00 00       	call   801047be <sleep>
80103da3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da6:	8b 45 08             	mov    0x8(%ebp),%eax
80103da9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103daf:	8b 45 08             	mov    0x8(%ebp),%eax
80103db2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db8:	39 c2                	cmp    %eax,%edx
80103dba:	75 0d                	jne    80103dc9 <piperead+0x78>
80103dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc5:	85 c0                	test   %eax,%eax
80103dc7:	75 9f                	jne    80103d68 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dd0:	eb 48                	jmp    80103e1a <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de4:	39 c2                	cmp    %eax,%edx
80103de6:	74 3c                	je     80103e24 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de8:	8b 45 08             	mov    0x8(%ebp),%eax
80103deb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103df1:	8d 48 01             	lea    0x1(%eax),%ecx
80103df4:	8b 55 08             	mov    0x8(%ebp),%edx
80103df7:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfd:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e02:	89 c1                	mov    %eax,%ecx
80103e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e0a:	01 c2                	add    %eax,%edx
80103e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e14:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e20:	7c b0                	jl     80103dd2 <piperead+0x81>
80103e22:	eb 01                	jmp    80103e25 <piperead+0xd4>
      break;
80103e24:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e25:	8b 45 08             	mov    0x8(%ebp),%eax
80103e28:	05 38 02 00 00       	add    $0x238,%eax
80103e2d:	83 ec 0c             	sub    $0xc,%esp
80103e30:	50                   	push   %eax
80103e31:	e8 6f 0a 00 00       	call   801048a5 <wakeup>
80103e36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e39:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3c:	83 ec 0c             	sub    $0xc,%esp
80103e3f:	50                   	push   %eax
80103e40:	e8 5b 0f 00 00       	call   80104da0 <release>
80103e45:	83 c4 10             	add    $0x10,%esp
  return i;
80103e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e4b:	c9                   	leave  
80103e4c:	c3                   	ret    

80103e4d <readeflags>:
{
80103e4d:	55                   	push   %ebp
80103e4e:	89 e5                	mov    %esp,%ebp
80103e50:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e53:	9c                   	pushf  
80103e54:	58                   	pop    %eax
80103e55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e5b:	c9                   	leave  
80103e5c:	c3                   	ret    

80103e5d <sti>:
{
80103e5d:	55                   	push   %ebp
80103e5e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e60:	fb                   	sti    
}
80103e61:	90                   	nop
80103e62:	5d                   	pop    %ebp
80103e63:	c3                   	ret    

80103e64 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e64:	55                   	push   %ebp
80103e65:	89 e5                	mov    %esp,%ebp
80103e67:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e6a:	83 ec 08             	sub    $0x8,%esp
80103e6d:	68 98 a8 10 80       	push   $0x8010a898
80103e72:	68 40 72 11 80       	push   $0x80117240
80103e77:	e8 94 0e 00 00       	call   80104d10 <initlock>
80103e7c:	83 c4 10             	add    $0x10,%esp
}
80103e7f:	90                   	nop
80103e80:	c9                   	leave  
80103e81:	c3                   	ret    

80103e82 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e82:	55                   	push   %ebp
80103e83:	89 e5                	mov    %esp,%ebp
80103e85:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e88:	e8 10 00 00 00       	call   80103e9d <mycpu>
80103e8d:	2d c0 99 11 80       	sub    $0x801199c0,%eax
80103e92:	c1 f8 04             	sar    $0x4,%eax
80103e95:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e9b:	c9                   	leave  
80103e9c:	c3                   	ret    

80103e9d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9d:	55                   	push   %ebp
80103e9e:	89 e5                	mov    %esp,%ebp
80103ea0:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea3:	e8 a5 ff ff ff       	call   80103e4d <readeflags>
80103ea8:	25 00 02 00 00       	and    $0x200,%eax
80103ead:	85 c0                	test   %eax,%eax
80103eaf:	74 0d                	je     80103ebe <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eb1:	83 ec 0c             	sub    $0xc,%esp
80103eb4:	68 a0 a8 10 80       	push   $0x8010a8a0
80103eb9:	e8 eb c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebe:	e8 1c f1 ff ff       	call   80102fdf <lapicid>
80103ec3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ecd:	eb 2d                	jmp    80103efc <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed8:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103edd:	0f b6 00             	movzbl (%eax),%eax
80103ee0:	0f b6 c0             	movzbl %al,%eax
80103ee3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee6:	75 10                	jne    80103ef8 <mycpu+0x5b>
      return &cpus[i];
80103ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eeb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ef1:	05 c0 99 11 80       	add    $0x801199c0,%eax
80103ef6:	eb 1b                	jmp    80103f13 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103efc:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80103f01:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f04:	7c c9                	jl     80103ecf <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f06:	83 ec 0c             	sub    $0xc,%esp
80103f09:	68 c6 a8 10 80       	push   $0x8010a8c6
80103f0e:	e8 96 c6 ff ff       	call   801005a9 <panic>
}
80103f13:	c9                   	leave  
80103f14:	c3                   	ret    

80103f15 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f15:	55                   	push   %ebp
80103f16:	89 e5                	mov    %esp,%ebp
80103f18:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f1b:	e8 7d 0f 00 00       	call   80104e9d <pushcli>
  c = mycpu();
80103f20:	e8 78 ff ff ff       	call   80103e9d <mycpu>
80103f25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f34:	e8 b1 0f 00 00       	call   80104eea <popcli>
  return p;
80103f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f3c:	c9                   	leave  
80103f3d:	c3                   	ret    

80103f3e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3e:	55                   	push   %ebp
80103f3f:	89 e5                	mov    %esp,%ebp
80103f41:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f44:	83 ec 0c             	sub    $0xc,%esp
80103f47:	68 40 72 11 80       	push   $0x80117240
80103f4c:	e8 e1 0d 00 00       	call   80104d32 <acquire>
80103f51:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f54:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f5b:	eb 0e                	jmp    80103f6b <allocproc+0x2d>
    if(p->state == UNUSED){
80103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f60:	8b 40 0c             	mov    0xc(%eax),%eax
80103f63:	85 c0                	test   %eax,%eax
80103f65:	74 27                	je     80103f8e <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f67:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f6b:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80103f72:	72 e9                	jb     80103f5d <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f74:	83 ec 0c             	sub    $0xc,%esp
80103f77:	68 40 72 11 80       	push   $0x80117240
80103f7c:	e8 1f 0e 00 00       	call   80104da0 <release>
80103f81:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f84:	b8 00 00 00 00       	mov    $0x0,%eax
80103f89:	e9 b2 00 00 00       	jmp    80104040 <allocproc+0x102>
      goto found;
80103f8e:	90                   	nop

found:
  p->state = EMBRYO;
80103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f92:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f99:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f9e:	8d 50 01             	lea    0x1(%eax),%edx
80103fa1:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103faa:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103fad:	83 ec 0c             	sub    $0xc,%esp
80103fb0:	68 40 72 11 80       	push   $0x80117240
80103fb5:	e8 e6 0d 00 00       	call   80104da0 <release>
80103fba:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fbd:	e8 c3 ec ff ff       	call   80102c85 <kalloc>
80103fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc5:	89 42 08             	mov    %eax,0x8(%edx)
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcb:	8b 40 08             	mov    0x8(%eax),%eax
80103fce:	85 c0                	test   %eax,%eax
80103fd0:	75 11                	jne    80103fe3 <allocproc+0xa5>
    p->state = UNUSED;
80103fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fdc:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe1:	eb 5d                	jmp    80104040 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe6:	8b 40 08             	mov    0x8(%eax),%eax
80103fe9:	05 00 10 00 00       	add    $0x1000,%eax
80103fee:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ff1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffb:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ffe:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104002:	ba 40 63 10 80       	mov    $0x80106340,%edx
80104007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010400a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010400c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104013:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104016:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010401f:	83 ec 04             	sub    $0x4,%esp
80104022:	6a 14                	push   $0x14
80104024:	6a 00                	push   $0x0
80104026:	50                   	push   %eax
80104027:	e8 7c 0f 00 00       	call   80104fa8 <memset>
8010402c:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	8b 40 1c             	mov    0x1c(%eax),%eax
80104035:	ba 78 47 10 80       	mov    $0x80104778,%edx
8010403a:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104040:	c9                   	leave  
80104041:	c3                   	ret    

80104042 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104042:	55                   	push   %ebp
80104043:	89 e5                	mov    %esp,%ebp
80104045:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104048:	e8 f1 fe ff ff       	call   80103f3e <allocproc>
8010404d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	a3 74 91 11 80       	mov    %eax,0x80119174
  if((p->pgdir = setupkvm()) == 0){
80104058:	e8 25 39 00 00       	call   80107982 <setupkvm>
8010405d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104060:	89 42 04             	mov    %eax,0x4(%edx)
80104063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104066:	8b 40 04             	mov    0x4(%eax),%eax
80104069:	85 c0                	test   %eax,%eax
8010406b:	75 0d                	jne    8010407a <userinit+0x38>
    panic("userinit: out of memory?");
8010406d:	83 ec 0c             	sub    $0xc,%esp
80104070:	68 d6 a8 10 80       	push   $0x8010a8d6
80104075:	e8 2f c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010407a:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010407f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104082:	8b 40 04             	mov    0x4(%eax),%eax
80104085:	83 ec 04             	sub    $0x4,%esp
80104088:	52                   	push   %edx
80104089:	68 ec f4 10 80       	push   $0x8010f4ec
8010408e:	50                   	push   %eax
8010408f:	e8 aa 3b 00 00       	call   80107c3e <inituvm>
80104094:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801040a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a3:	8b 40 18             	mov    0x18(%eax),%eax
801040a6:	83 ec 04             	sub    $0x4,%esp
801040a9:	6a 4c                	push   $0x4c
801040ab:	6a 00                	push   $0x0
801040ad:	50                   	push   %eax
801040ae:	e8 f5 0e 00 00       	call   80104fa8 <memset>
801040b3:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b9:	8b 40 18             	mov    0x18(%eax),%eax
801040bc:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	8b 40 18             	mov    0x18(%eax),%eax
801040c8:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d1:	8b 50 18             	mov    0x18(%eax),%edx
801040d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d7:	8b 40 18             	mov    0x18(%eax),%eax
801040da:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040de:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e5:	8b 50 18             	mov    0x18(%eax),%edx
801040e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040eb:	8b 40 18             	mov    0x18(%eax),%eax
801040ee:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040f2:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f9:	8b 40 18             	mov    0x18(%eax),%eax
801040fc:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104106:	8b 40 18             	mov    0x18(%eax),%eax
80104109:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104113:	8b 40 18             	mov    0x18(%eax),%eax
80104116:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	83 c0 6c             	add    $0x6c,%eax
80104123:	83 ec 04             	sub    $0x4,%esp
80104126:	6a 10                	push   $0x10
80104128:	68 ef a8 10 80       	push   $0x8010a8ef
8010412d:	50                   	push   %eax
8010412e:	e8 78 10 00 00       	call   801051ab <safestrcpy>
80104133:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104136:	83 ec 0c             	sub    $0xc,%esp
80104139:	68 f8 a8 10 80       	push   $0x8010a8f8
8010413e:	e8 db e3 ff ff       	call   8010251e <namei>
80104143:	83 c4 10             	add    $0x10,%esp
80104146:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104149:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010414c:	83 ec 0c             	sub    $0xc,%esp
8010414f:	68 40 72 11 80       	push   $0x80117240
80104154:	e8 d9 0b 00 00       	call   80104d32 <acquire>
80104159:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	68 40 72 11 80       	push   $0x80117240
8010416e:	e8 2d 0c 00 00       	call   80104da0 <release>
80104173:	83 c4 10             	add    $0x10,%esp
}
80104176:	90                   	nop
80104177:	c9                   	leave  
80104178:	c3                   	ret    

80104179 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104179:	55                   	push   %ebp
8010417a:	89 e5                	mov    %esp,%ebp
8010417c:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010417f:	e8 91 fd ff ff       	call   80103f15 <myproc>
80104184:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010418a:	8b 00                	mov    (%eax),%eax
8010418c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010418f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104193:	7e 2e                	jle    801041c3 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104195:	8b 55 08             	mov    0x8(%ebp),%edx
80104198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419b:	01 c2                	add    %eax,%edx
8010419d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a0:	8b 40 04             	mov    0x4(%eax),%eax
801041a3:	83 ec 04             	sub    $0x4,%esp
801041a6:	52                   	push   %edx
801041a7:	ff 75 f4             	push   -0xc(%ebp)
801041aa:	50                   	push   %eax
801041ab:	e8 cb 3b 00 00       	call   80107d7b <allocuvm>
801041b0:	83 c4 10             	add    $0x10,%esp
801041b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ba:	75 3b                	jne    801041f7 <growproc+0x7e>
      return -1;
801041bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c1:	eb 4f                	jmp    80104212 <growproc+0x99>
  } else if(n < 0){
801041c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c7:	79 2e                	jns    801041f7 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041c9:	8b 55 08             	mov    0x8(%ebp),%edx
801041cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cf:	01 c2                	add    %eax,%edx
801041d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d4:	8b 40 04             	mov    0x4(%eax),%eax
801041d7:	83 ec 04             	sub    $0x4,%esp
801041da:	52                   	push   %edx
801041db:	ff 75 f4             	push   -0xc(%ebp)
801041de:	50                   	push   %eax
801041df:	e8 9c 3c 00 00       	call   80107e80 <deallocuvm>
801041e4:	83 c4 10             	add    $0x10,%esp
801041e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041ee:	75 07                	jne    801041f7 <growproc+0x7e>
      return -1;
801041f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f5:	eb 1b                	jmp    80104212 <growproc+0x99>
  }
  curproc->sz = sz;
801041f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fd:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041ff:	83 ec 0c             	sub    $0xc,%esp
80104202:	ff 75 f0             	push   -0x10(%ebp)
80104205:	e8 95 38 00 00       	call   80107a9f <switchuvm>
8010420a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104212:	c9                   	leave  
80104213:	c3                   	ret    

80104214 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104214:	55                   	push   %ebp
80104215:	89 e5                	mov    %esp,%ebp
80104217:	57                   	push   %edi
80104218:	56                   	push   %esi
80104219:	53                   	push   %ebx
8010421a:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421d:	e8 f3 fc ff ff       	call   80103f15 <myproc>
80104222:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104225:	e8 14 fd ff ff       	call   80103f3e <allocproc>
8010422a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104231:	75 0a                	jne    8010423d <fork+0x29>
    return -1;
80104233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104238:	e9 48 01 00 00       	jmp    80104385 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104240:	8b 10                	mov    (%eax),%edx
80104242:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104245:	8b 40 04             	mov    0x4(%eax),%eax
80104248:	83 ec 08             	sub    $0x8,%esp
8010424b:	52                   	push   %edx
8010424c:	50                   	push   %eax
8010424d:	e8 cc 3d 00 00       	call   8010801e <copyuvm>
80104252:	83 c4 10             	add    $0x10,%esp
80104255:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104258:	89 42 04             	mov    %eax,0x4(%edx)
8010425b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425e:	8b 40 04             	mov    0x4(%eax),%eax
80104261:	85 c0                	test   %eax,%eax
80104263:	75 30                	jne    80104295 <fork+0x81>
    kfree(np->kstack);
80104265:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104268:	8b 40 08             	mov    0x8(%eax),%eax
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	50                   	push   %eax
8010426f:	e8 77 e9 ff ff       	call   80102beb <kfree>
80104274:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104277:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010427a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104281:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104284:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010428b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104290:	e9 f0 00 00 00       	jmp    80104385 <fork+0x171>
  }
  np->sz = curproc->sz;
80104295:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104298:	8b 10                	mov    (%eax),%edx
8010429a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429d:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010429f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ab:	8b 48 18             	mov    0x18(%eax),%ecx
801042ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042b1:	8b 40 18             	mov    0x18(%eax),%eax
801042b4:	89 c2                	mov    %eax,%edx
801042b6:	89 cb                	mov    %ecx,%ebx
801042b8:	b8 13 00 00 00       	mov    $0x13,%eax
801042bd:	89 d7                	mov    %edx,%edi
801042bf:	89 de                	mov    %ebx,%esi
801042c1:	89 c1                	mov    %eax,%ecx
801042c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042c8:	8b 40 18             	mov    0x18(%eax),%eax
801042cb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042d9:	eb 3b                	jmp    80104316 <fork+0x102>
    if(curproc->ofile[i])
801042db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042e1:	83 c2 08             	add    $0x8,%edx
801042e4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042e8:	85 c0                	test   %eax,%eax
801042ea:	74 26                	je     80104312 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042f2:	83 c2 08             	add    $0x8,%edx
801042f5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	50                   	push   %eax
801042fd:	e8 49 cd ff ff       	call   8010104b <filedup>
80104302:	83 c4 10             	add    $0x10,%esp
80104305:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104308:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010430b:	83 c1 08             	add    $0x8,%ecx
8010430e:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104312:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104316:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010431a:	7e bf                	jle    801042db <fork+0xc7>
  np->cwd = idup(curproc->cwd);
8010431c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431f:	8b 40 68             	mov    0x68(%eax),%eax
80104322:	83 ec 0c             	sub    $0xc,%esp
80104325:	50                   	push   %eax
80104326:	e8 86 d6 ff ff       	call   801019b1 <idup>
8010432b:	83 c4 10             	add    $0x10,%esp
8010432e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104331:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104334:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104337:	8d 50 6c             	lea    0x6c(%eax),%edx
8010433a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433d:	83 c0 6c             	add    $0x6c,%eax
80104340:	83 ec 04             	sub    $0x4,%esp
80104343:	6a 10                	push   $0x10
80104345:	52                   	push   %edx
80104346:	50                   	push   %eax
80104347:	e8 5f 0e 00 00       	call   801051ab <safestrcpy>
8010434c:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010434f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104352:	8b 40 10             	mov    0x10(%eax),%eax
80104355:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 40 72 11 80       	push   $0x80117240
80104360:	e8 cd 09 00 00       	call   80104d32 <acquire>
80104365:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104368:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010436b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104372:	83 ec 0c             	sub    $0xc,%esp
80104375:	68 40 72 11 80       	push   $0x80117240
8010437a:	e8 21 0a 00 00       	call   80104da0 <release>
8010437f:	83 c4 10             	add    $0x10,%esp

  return pid;
80104382:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104385:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104388:	5b                   	pop    %ebx
80104389:	5e                   	pop    %esi
8010438a:	5f                   	pop    %edi
8010438b:	5d                   	pop    %ebp
8010438c:	c3                   	ret    

8010438d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438d:	55                   	push   %ebp
8010438e:	89 e5                	mov    %esp,%ebp
80104390:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104393:	e8 7d fb ff ff       	call   80103f15 <myproc>
80104398:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010439b:	a1 74 91 11 80       	mov    0x80119174,%eax
801043a0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a3:	75 0d                	jne    801043b2 <exit+0x25>
    panic("init exiting");
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	68 fa a8 10 80       	push   $0x8010a8fa
801043ad:	e8 f7 c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043b9:	eb 3f                	jmp    801043fa <exit+0x6d>
    if(curproc->ofile[fd]){
801043bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c1:	83 c2 08             	add    $0x8,%edx
801043c4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043c8:	85 c0                	test   %eax,%eax
801043ca:	74 2a                	je     801043f6 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d2:	83 c2 08             	add    $0x8,%edx
801043d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d9:	83 ec 0c             	sub    $0xc,%esp
801043dc:	50                   	push   %eax
801043dd:	e8 ba cc ff ff       	call   8010109c <fileclose>
801043e2:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043eb:	83 c2 08             	add    $0x8,%edx
801043ee:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043fa:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043fe:	7e bb                	jle    801043bb <exit+0x2e>
    }
  }

  begin_op();
80104400:	e8 1c f1 ff ff       	call   80103521 <begin_op>
  iput(curproc->cwd);
80104405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104408:	8b 40 68             	mov    0x68(%eax),%eax
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	50                   	push   %eax
8010440f:	e8 38 d7 ff ff       	call   80101b4c <iput>
80104414:	83 c4 10             	add    $0x10,%esp
  end_op();
80104417:	e8 91 f1 ff ff       	call   801035ad <end_op>
  curproc->cwd = 0;
8010441c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010441f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104426:	83 ec 0c             	sub    $0xc,%esp
80104429:	68 40 72 11 80       	push   $0x80117240
8010442e:	e8 ff 08 00 00       	call   80104d32 <acquire>
80104433:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104436:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104439:	8b 40 14             	mov    0x14(%eax),%eax
8010443c:	83 ec 0c             	sub    $0xc,%esp
8010443f:	50                   	push   %eax
80104440:	e8 20 04 00 00       	call   80104865 <wakeup1>
80104445:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104448:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010444f:	eb 37                	jmp    80104488 <exit+0xfb>
    if(p->parent == curproc){
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	8b 40 14             	mov    0x14(%eax),%eax
80104457:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010445a:	75 28                	jne    80104484 <exit+0xf7>
      p->parent = initproc;
8010445c:	8b 15 74 91 11 80    	mov    0x80119174,%edx
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446b:	8b 40 0c             	mov    0xc(%eax),%eax
8010446e:	83 f8 05             	cmp    $0x5,%eax
80104471:	75 11                	jne    80104484 <exit+0xf7>
        wakeup1(initproc);
80104473:	a1 74 91 11 80       	mov    0x80119174,%eax
80104478:	83 ec 0c             	sub    $0xc,%esp
8010447b:	50                   	push   %eax
8010447c:	e8 e4 03 00 00       	call   80104865 <wakeup1>
80104481:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104484:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104488:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010448f:	72 c0                	jb     80104451 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104491:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104494:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010449b:	e8 e5 01 00 00       	call   80104685 <sched>
  panic("zombie exit");
801044a0:	83 ec 0c             	sub    $0xc,%esp
801044a3:	68 07 a9 10 80       	push   $0x8010a907
801044a8:	e8 fc c0 ff ff       	call   801005a9 <panic>

801044ad <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044ad:	55                   	push   %ebp
801044ae:	89 e5                	mov    %esp,%ebp
801044b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044b3:	e8 5d fa ff ff       	call   80103f15 <myproc>
801044b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044bb:	83 ec 0c             	sub    $0xc,%esp
801044be:	68 40 72 11 80       	push   $0x80117240
801044c3:	e8 6a 08 00 00       	call   80104d32 <acquire>
801044c8:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044d2:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044d9:	e9 a1 00 00 00       	jmp    8010457f <wait+0xd2>
      if(p->parent != curproc)
801044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e1:	8b 40 14             	mov    0x14(%eax),%eax
801044e4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044e7:	0f 85 8d 00 00 00    	jne    8010457a <wait+0xcd>
        continue;
      havekids = 1;
801044ed:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	8b 40 0c             	mov    0xc(%eax),%eax
801044fa:	83 f8 05             	cmp    $0x5,%eax
801044fd:	75 7c                	jne    8010457b <wait+0xce>
        // Found one.
        pid = p->pid;
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	8b 40 10             	mov    0x10(%eax),%eax
80104505:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 08             	mov    0x8(%eax),%eax
8010450e:	83 ec 0c             	sub    $0xc,%esp
80104511:	50                   	push   %eax
80104512:	e8 d4 e6 ff ff       	call   80102beb <kfree>
80104517:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 04             	mov    0x4(%eax),%eax
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	50                   	push   %eax
8010452e:	e8 11 3a 00 00       	call   80107f44 <freevm>
80104533:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104543:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010454a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104554:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104565:	83 ec 0c             	sub    $0xc,%esp
80104568:	68 40 72 11 80       	push   $0x80117240
8010456d:	e8 2e 08 00 00       	call   80104da0 <release>
80104572:	83 c4 10             	add    $0x10,%esp
        return pid;
80104575:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104578:	eb 51                	jmp    801045cb <wait+0x11e>
        continue;
8010457a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010457b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010457f:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104586:	0f 82 52 ff ff ff    	jb     801044de <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010458c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104590:	74 0a                	je     8010459c <wait+0xef>
80104592:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104595:	8b 40 24             	mov    0x24(%eax),%eax
80104598:	85 c0                	test   %eax,%eax
8010459a:	74 17                	je     801045b3 <wait+0x106>
      release(&ptable.lock);
8010459c:	83 ec 0c             	sub    $0xc,%esp
8010459f:	68 40 72 11 80       	push   $0x80117240
801045a4:	e8 f7 07 00 00       	call   80104da0 <release>
801045a9:	83 c4 10             	add    $0x10,%esp
      return -1;
801045ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b1:	eb 18                	jmp    801045cb <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045b3:	83 ec 08             	sub    $0x8,%esp
801045b6:	68 40 72 11 80       	push   $0x80117240
801045bb:	ff 75 ec             	push   -0x14(%ebp)
801045be:	e8 fb 01 00 00       	call   801047be <sleep>
801045c3:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045c6:	e9 00 ff ff ff       	jmp    801044cb <wait+0x1e>
  }
}
801045cb:	c9                   	leave  
801045cc:	c3                   	ret    

801045cd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045cd:	55                   	push   %ebp
801045ce:	89 e5                	mov    %esp,%ebp
801045d0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045d3:	e8 c5 f8 ff ff       	call   80103e9d <mycpu>
801045d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045de:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045e5:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045e8:	e8 70 f8 ff ff       	call   80103e5d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045ed:	83 ec 0c             	sub    $0xc,%esp
801045f0:	68 40 72 11 80       	push   $0x80117240
801045f5:	e8 38 07 00 00       	call   80104d32 <acquire>
801045fa:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fd:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104604:	eb 61                	jmp    80104667 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104609:	8b 40 0c             	mov    0xc(%eax),%eax
8010460c:	83 f8 03             	cmp    $0x3,%eax
8010460f:	75 51                	jne    80104662 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104614:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104617:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010461d:	83 ec 0c             	sub    $0xc,%esp
80104620:	ff 75 f4             	push   -0xc(%ebp)
80104623:	e8 77 34 00 00       	call   80107a9f <switchuvm>
80104628:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104638:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463e:	83 c2 04             	add    $0x4,%edx
80104641:	83 ec 08             	sub    $0x8,%esp
80104644:	50                   	push   %eax
80104645:	52                   	push   %edx
80104646:	e8 d2 0b 00 00       	call   8010521d <swtch>
8010464b:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010464e:	e8 33 34 00 00       	call   80107a86 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104656:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010465d:	00 00 00 
80104660:	eb 01                	jmp    80104663 <scheduler+0x96>
        continue;
80104662:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104663:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104667:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
8010466e:	72 96                	jb     80104606 <scheduler+0x39>
    }
    release(&ptable.lock);
80104670:	83 ec 0c             	sub    $0xc,%esp
80104673:	68 40 72 11 80       	push   $0x80117240
80104678:	e8 23 07 00 00       	call   80104da0 <release>
8010467d:	83 c4 10             	add    $0x10,%esp
    sti();
80104680:	e9 63 ff ff ff       	jmp    801045e8 <scheduler+0x1b>

80104685 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104685:	55                   	push   %ebp
80104686:	89 e5                	mov    %esp,%ebp
80104688:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010468b:	e8 85 f8 ff ff       	call   80103f15 <myproc>
80104690:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104693:	83 ec 0c             	sub    $0xc,%esp
80104696:	68 40 72 11 80       	push   $0x80117240
8010469b:	e8 cd 07 00 00       	call   80104e6d <holding>
801046a0:	83 c4 10             	add    $0x10,%esp
801046a3:	85 c0                	test   %eax,%eax
801046a5:	75 0d                	jne    801046b4 <sched+0x2f>
    panic("sched ptable.lock");
801046a7:	83 ec 0c             	sub    $0xc,%esp
801046aa:	68 13 a9 10 80       	push   $0x8010a913
801046af:	e8 f5 be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046b4:	e8 e4 f7 ff ff       	call   80103e9d <mycpu>
801046b9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046bf:	83 f8 01             	cmp    $0x1,%eax
801046c2:	74 0d                	je     801046d1 <sched+0x4c>
    panic("sched locks");
801046c4:	83 ec 0c             	sub    $0xc,%esp
801046c7:	68 25 a9 10 80       	push   $0x8010a925
801046cc:	e8 d8 be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d4:	8b 40 0c             	mov    0xc(%eax),%eax
801046d7:	83 f8 04             	cmp    $0x4,%eax
801046da:	75 0d                	jne    801046e9 <sched+0x64>
    panic("sched running");
801046dc:	83 ec 0c             	sub    $0xc,%esp
801046df:	68 31 a9 10 80       	push   $0x8010a931
801046e4:	e8 c0 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046e9:	e8 5f f7 ff ff       	call   80103e4d <readeflags>
801046ee:	25 00 02 00 00       	and    $0x200,%eax
801046f3:	85 c0                	test   %eax,%eax
801046f5:	74 0d                	je     80104704 <sched+0x7f>
    panic("sched interruptible");
801046f7:	83 ec 0c             	sub    $0xc,%esp
801046fa:	68 3f a9 10 80       	push   $0x8010a93f
801046ff:	e8 a5 be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104704:	e8 94 f7 ff ff       	call   80103e9d <mycpu>
80104709:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010470f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104712:	e8 86 f7 ff ff       	call   80103e9d <mycpu>
80104717:	8b 40 04             	mov    0x4(%eax),%eax
8010471a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471d:	83 c2 1c             	add    $0x1c,%edx
80104720:	83 ec 08             	sub    $0x8,%esp
80104723:	50                   	push   %eax
80104724:	52                   	push   %edx
80104725:	e8 f3 0a 00 00       	call   8010521d <swtch>
8010472a:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010472d:	e8 6b f7 ff ff       	call   80103e9d <mycpu>
80104732:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104735:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010473b:	90                   	nop
8010473c:	c9                   	leave  
8010473d:	c3                   	ret    

8010473e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010473e:	55                   	push   %ebp
8010473f:	89 e5                	mov    %esp,%ebp
80104741:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104744:	83 ec 0c             	sub    $0xc,%esp
80104747:	68 40 72 11 80       	push   $0x80117240
8010474c:	e8 e1 05 00 00       	call   80104d32 <acquire>
80104751:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104754:	e8 bc f7 ff ff       	call   80103f15 <myproc>
80104759:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104760:	e8 20 ff ff ff       	call   80104685 <sched>
  release(&ptable.lock);
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	68 40 72 11 80       	push   $0x80117240
8010476d:	e8 2e 06 00 00       	call   80104da0 <release>
80104772:	83 c4 10             	add    $0x10,%esp
}
80104775:	90                   	nop
80104776:	c9                   	leave  
80104777:	c3                   	ret    

80104778 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104778:	55                   	push   %ebp
80104779:	89 e5                	mov    %esp,%ebp
8010477b:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010477e:	83 ec 0c             	sub    $0xc,%esp
80104781:	68 40 72 11 80       	push   $0x80117240
80104786:	e8 15 06 00 00       	call   80104da0 <release>
8010478b:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010478e:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104793:	85 c0                	test   %eax,%eax
80104795:	74 24                	je     801047bb <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104797:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010479e:	00 00 00 
    iinit(ROOTDEV);
801047a1:	83 ec 0c             	sub    $0xc,%esp
801047a4:	6a 01                	push   $0x1
801047a6:	e8 ce ce ff ff       	call   80101679 <iinit>
801047ab:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047ae:	83 ec 0c             	sub    $0xc,%esp
801047b1:	6a 01                	push   $0x1
801047b3:	e8 4a eb ff ff       	call   80103302 <initlog>
801047b8:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047bb:	90                   	nop
801047bc:	c9                   	leave  
801047bd:	c3                   	ret    

801047be <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047be:	55                   	push   %ebp
801047bf:	89 e5                	mov    %esp,%ebp
801047c1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047c4:	e8 4c f7 ff ff       	call   80103f15 <myproc>
801047c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047d0:	75 0d                	jne    801047df <sleep+0x21>
    panic("sleep");
801047d2:	83 ec 0c             	sub    $0xc,%esp
801047d5:	68 53 a9 10 80       	push   $0x8010a953
801047da:	e8 ca bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047e3:	75 0d                	jne    801047f2 <sleep+0x34>
    panic("sleep without lk");
801047e5:	83 ec 0c             	sub    $0xc,%esp
801047e8:	68 59 a9 10 80       	push   $0x8010a959
801047ed:	e8 b7 bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047f2:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
801047f9:	74 1e                	je     80104819 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047fb:	83 ec 0c             	sub    $0xc,%esp
801047fe:	68 40 72 11 80       	push   $0x80117240
80104803:	e8 2a 05 00 00       	call   80104d32 <acquire>
80104808:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010480b:	83 ec 0c             	sub    $0xc,%esp
8010480e:	ff 75 0c             	push   0xc(%ebp)
80104811:	e8 8a 05 00 00       	call   80104da0 <release>
80104816:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481c:	8b 55 08             	mov    0x8(%ebp),%edx
8010481f:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104825:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010482c:	e8 54 fe ff ff       	call   80104685 <sched>

  // Tidy up.
  p->chan = 0;
80104831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104834:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010483b:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104842:	74 1e                	je     80104862 <sleep+0xa4>
    release(&ptable.lock);
80104844:	83 ec 0c             	sub    $0xc,%esp
80104847:	68 40 72 11 80       	push   $0x80117240
8010484c:	e8 4f 05 00 00       	call   80104da0 <release>
80104851:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104854:	83 ec 0c             	sub    $0xc,%esp
80104857:	ff 75 0c             	push   0xc(%ebp)
8010485a:	e8 d3 04 00 00       	call   80104d32 <acquire>
8010485f:	83 c4 10             	add    $0x10,%esp
  }
}
80104862:	90                   	nop
80104863:	c9                   	leave  
80104864:	c3                   	ret    

80104865 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104865:	55                   	push   %ebp
80104866:	89 e5                	mov    %esp,%ebp
80104868:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010486b:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
80104872:	eb 24                	jmp    80104898 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104877:	8b 40 0c             	mov    0xc(%eax),%eax
8010487a:	83 f8 02             	cmp    $0x2,%eax
8010487d:	75 15                	jne    80104894 <wakeup1+0x2f>
8010487f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104882:	8b 40 20             	mov    0x20(%eax),%eax
80104885:	39 45 08             	cmp    %eax,0x8(%ebp)
80104888:	75 0a                	jne    80104894 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010488a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104894:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104898:	81 7d fc 74 91 11 80 	cmpl   $0x80119174,-0x4(%ebp)
8010489f:	72 d3                	jb     80104874 <wakeup1+0xf>
}
801048a1:	90                   	nop
801048a2:	90                   	nop
801048a3:	c9                   	leave  
801048a4:	c3                   	ret    

801048a5 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048a5:	55                   	push   %ebp
801048a6:	89 e5                	mov    %esp,%ebp
801048a8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048ab:	83 ec 0c             	sub    $0xc,%esp
801048ae:	68 40 72 11 80       	push   $0x80117240
801048b3:	e8 7a 04 00 00       	call   80104d32 <acquire>
801048b8:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048bb:	83 ec 0c             	sub    $0xc,%esp
801048be:	ff 75 08             	push   0x8(%ebp)
801048c1:	e8 9f ff ff ff       	call   80104865 <wakeup1>
801048c6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048c9:	83 ec 0c             	sub    $0xc,%esp
801048cc:	68 40 72 11 80       	push   $0x80117240
801048d1:	e8 ca 04 00 00       	call   80104da0 <release>
801048d6:	83 c4 10             	add    $0x10,%esp
}
801048d9:	90                   	nop
801048da:	c9                   	leave  
801048db:	c3                   	ret    

801048dc <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048dc:	55                   	push   %ebp
801048dd:	89 e5                	mov    %esp,%ebp
801048df:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048e2:	83 ec 0c             	sub    $0xc,%esp
801048e5:	68 40 72 11 80       	push   $0x80117240
801048ea:	e8 43 04 00 00       	call   80104d32 <acquire>
801048ef:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f2:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801048f9:	eb 45                	jmp    80104940 <kill+0x64>
    if(p->pid == pid){
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	8b 40 10             	mov    0x10(%eax),%eax
80104901:	39 45 08             	cmp    %eax,0x8(%ebp)
80104904:	75 36                	jne    8010493c <kill+0x60>
      p->killed = 1;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104913:	8b 40 0c             	mov    0xc(%eax),%eax
80104916:	83 f8 02             	cmp    $0x2,%eax
80104919:	75 0a                	jne    80104925 <kill+0x49>
        p->state = RUNNABLE;
8010491b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104925:	83 ec 0c             	sub    $0xc,%esp
80104928:	68 40 72 11 80       	push   $0x80117240
8010492d:	e8 6e 04 00 00       	call   80104da0 <release>
80104932:	83 c4 10             	add    $0x10,%esp
      return 0;
80104935:	b8 00 00 00 00       	mov    $0x0,%eax
8010493a:	eb 22                	jmp    8010495e <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010493c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104940:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104947:	72 b2                	jb     801048fb <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104949:	83 ec 0c             	sub    $0xc,%esp
8010494c:	68 40 72 11 80       	push   $0x80117240
80104951:	e8 4a 04 00 00       	call   80104da0 <release>
80104956:	83 c4 10             	add    $0x10,%esp
  return -1;
80104959:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010495e:	c9                   	leave  
8010495f:	c3                   	ret    

80104960 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104966:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010496d:	e9 d7 00 00 00       	jmp    80104a49 <procdump+0xe9>
    if(p->state == UNUSED)
80104972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104975:	8b 40 0c             	mov    0xc(%eax),%eax
80104978:	85 c0                	test   %eax,%eax
8010497a:	0f 84 c4 00 00 00    	je     80104a44 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104983:	8b 40 0c             	mov    0xc(%eax),%eax
80104986:	83 f8 05             	cmp    $0x5,%eax
80104989:	77 23                	ja     801049ae <procdump+0x4e>
8010498b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498e:	8b 40 0c             	mov    0xc(%eax),%eax
80104991:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104998:	85 c0                	test   %eax,%eax
8010499a:	74 12                	je     801049ae <procdump+0x4e>
      state = states[p->state];
8010499c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499f:	8b 40 0c             	mov    0xc(%eax),%eax
801049a2:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049ac:	eb 07                	jmp    801049b5 <procdump+0x55>
    else
      state = "???";
801049ae:	c7 45 ec 6a a9 10 80 	movl   $0x8010a96a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b8:	8d 50 6c             	lea    0x6c(%eax),%edx
801049bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049be:	8b 40 10             	mov    0x10(%eax),%eax
801049c1:	52                   	push   %edx
801049c2:	ff 75 ec             	push   -0x14(%ebp)
801049c5:	50                   	push   %eax
801049c6:	68 6e a9 10 80       	push   $0x8010a96e
801049cb:	e8 24 ba ff ff       	call   801003f4 <cprintf>
801049d0:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d6:	8b 40 0c             	mov    0xc(%eax),%eax
801049d9:	83 f8 02             	cmp    $0x2,%eax
801049dc:	75 54                	jne    80104a32 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e1:	8b 40 1c             	mov    0x1c(%eax),%eax
801049e4:	8b 40 0c             	mov    0xc(%eax),%eax
801049e7:	83 c0 08             	add    $0x8,%eax
801049ea:	89 c2                	mov    %eax,%edx
801049ec:	83 ec 08             	sub    $0x8,%esp
801049ef:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049f2:	50                   	push   %eax
801049f3:	52                   	push   %edx
801049f4:	e8 f9 03 00 00       	call   80104df2 <getcallerpcs>
801049f9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a03:	eb 1c                	jmp    80104a21 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a08:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a0c:	83 ec 08             	sub    $0x8,%esp
80104a0f:	50                   	push   %eax
80104a10:	68 77 a9 10 80       	push   $0x8010a977
80104a15:	e8 da b9 ff ff       	call   801003f4 <cprintf>
80104a1a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a21:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a25:	7f 0b                	jg     80104a32 <procdump+0xd2>
80104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a2e:	85 c0                	test   %eax,%eax
80104a30:	75 d3                	jne    80104a05 <procdump+0xa5>
    }
    cprintf("\n");
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	68 7b a9 10 80       	push   $0x8010a97b
80104a3a:	e8 b5 b9 ff ff       	call   801003f4 <cprintf>
80104a3f:	83 c4 10             	add    $0x10,%esp
80104a42:	eb 01                	jmp    80104a45 <procdump+0xe5>
      continue;
80104a44:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a45:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104a49:	81 7d f0 74 91 11 80 	cmpl   $0x80119174,-0x10(%ebp)
80104a50:	0f 82 1c ff ff ff    	jb     80104972 <procdump+0x12>
  }
}
80104a56:	90                   	nop
80104a57:	90                   	nop
80104a58:	c9                   	leave  
80104a59:	c3                   	ret    

80104a5a <printpt>:

int
printpt(int pid)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
80104a5d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = 0;
80104a60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  pte_t *pte;
  pde_t *pgdir;
  uint addr;

  acquire(&ptable.lock);
80104a67:	83 ec 0c             	sub    $0xc,%esp
80104a6a:	68 40 72 11 80       	push   $0x80117240
80104a6f:	e8 be 02 00 00       	call   80104d32 <acquire>
80104a74:	83 c4 10             	add    $0x10,%esp
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a77:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104a7e:	eb 0f                	jmp    80104a8f <printpt+0x35>
    if (p->pid == pid)
80104a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a83:	8b 40 10             	mov    0x10(%eax),%eax
80104a86:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a89:	74 0f                	je     80104a9a <printpt+0x40>
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a8b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a8f:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104a96:	72 e8                	jb     80104a80 <printpt+0x26>
80104a98:	eb 01                	jmp    80104a9b <printpt+0x41>
      break;
80104a9a:	90                   	nop
  }
  if (p == &ptable.proc[NPROC] || p->state == UNUSED) {
80104a9b:	81 7d f4 74 91 11 80 	cmpl   $0x80119174,-0xc(%ebp)
80104aa2:	74 0a                	je     80104aae <printpt+0x54>
80104aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa7:	8b 40 0c             	mov    0xc(%eax),%eax
80104aaa:	85 c0                	test   %eax,%eax
80104aac:	75 1a                	jne    80104ac8 <printpt+0x6e>
    release(&ptable.lock);
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	68 40 72 11 80       	push   $0x80117240
80104ab6:	e8 e5 02 00 00       	call   80104da0 <release>
80104abb:	83 c4 10             	add    $0x10,%esp
    return -1;
80104abe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ac3:	e9 e9 00 00 00       	jmp    80104bb1 <printpt+0x157>
  }

  pgdir = p->pgdir;
80104ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acb:	8b 40 04             	mov    0x4(%eax),%eax
80104ace:	89 45 ec             	mov    %eax,-0x14(%ebp)
  release(&ptable.lock);
80104ad1:	83 ec 0c             	sub    $0xc,%esp
80104ad4:	68 40 72 11 80       	push   $0x80117240
80104ad9:	e8 c2 02 00 00       	call   80104da0 <release>
80104ade:	83 c4 10             	add    $0x10,%esp

  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104ae1:	83 ec 08             	sub    $0x8,%esp
80104ae4:	ff 75 08             	push   0x8(%ebp)
80104ae7:	68 7d a9 10 80       	push   $0x8010a97d
80104aec:	e8 03 b9 ff ff       	call   801003f4 <cprintf>
80104af1:	83 c4 10             	add    $0x10,%esp

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104af4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104afb:	e9 91 00 00 00       	jmp    80104b91 <printpt+0x137>
    pte = walkpgdir(pgdir, (void*)addr, 0);
80104b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b03:	83 ec 04             	sub    $0x4,%esp
80104b06:	6a 00                	push   $0x0
80104b08:	50                   	push   %eax
80104b09:	ff 75 ec             	push   -0x14(%ebp)
80104b0c:	e8 4b 2d 00 00       	call   8010785c <walkpgdir>
80104b11:	83 c4 10             	add    $0x10,%esp
80104b14:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (!pte || !(*pte & PTE_P)) continue;
80104b17:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104b1b:	74 6c                	je     80104b89 <printpt+0x12f>
80104b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b20:	8b 00                	mov    (%eax),%eax
80104b22:	83 e0 01             	and    $0x1,%eax
80104b25:	85 c0                	test   %eax,%eax
80104b27:	74 60                	je     80104b89 <printpt+0x12f>

    // 플래그 문자열 생성
    const char *access = (*pte & PTE_U) ? "U" : "K";
80104b29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b2c:	8b 00                	mov    (%eax),%eax
80104b2e:	83 e0 04             	and    $0x4,%eax
80104b31:	85 c0                	test   %eax,%eax
80104b33:	74 07                	je     80104b3c <printpt+0xe2>
80104b35:	b8 98 a9 10 80       	mov    $0x8010a998,%eax
80104b3a:	eb 05                	jmp    80104b41 <printpt+0xe7>
80104b3c:	b8 9a a9 10 80       	mov    $0x8010a99a,%eax
80104b41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    const char *write = (*pte & PTE_W) ? "W" : "-";
80104b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b47:	8b 00                	mov    (%eax),%eax
80104b49:	83 e0 02             	and    $0x2,%eax
80104b4c:	85 c0                	test   %eax,%eax
80104b4e:	74 07                	je     80104b57 <printpt+0xfd>
80104b50:	b8 9c a9 10 80       	mov    $0x8010a99c,%eax
80104b55:	eb 05                	jmp    80104b5c <printpt+0x102>
80104b57:	b8 9e a9 10 80       	mov    $0x8010a99e,%eax
80104b5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // 전체 문자열 조합 
    cprintf("%x P %s %s %x\n",
      addr >> 12,               // 가상 페이지 번호 (VA >> 12)
      access,                   // U or K
      write,                    // W or -
      PTE_ADDR(*pte) >> 12      // 물리 페이지 번호 (PA >> 12)
80104b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b62:	8b 00                	mov    (%eax),%eax
    cprintf("%x P %s %s %x\n",
80104b64:	c1 e8 0c             	shr    $0xc,%eax
80104b67:	89 c2                	mov    %eax,%edx
80104b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b6c:	c1 e8 0c             	shr    $0xc,%eax
80104b6f:	83 ec 0c             	sub    $0xc,%esp
80104b72:	52                   	push   %edx
80104b73:	ff 75 e0             	push   -0x20(%ebp)
80104b76:	ff 75 e4             	push   -0x1c(%ebp)
80104b79:	50                   	push   %eax
80104b7a:	68 a0 a9 10 80       	push   $0x8010a9a0
80104b7f:	e8 70 b8 ff ff       	call   801003f4 <cprintf>
80104b84:	83 c4 20             	add    $0x20,%esp
80104b87:	eb 01                	jmp    80104b8a <printpt+0x130>
    if (!pte || !(*pte & PTE_P)) continue;
80104b89:	90                   	nop
  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
80104b8a:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b94:	85 c0                	test   %eax,%eax
80104b96:	0f 89 64 ff ff ff    	jns    80104b00 <printpt+0xa6>
    );
  }

  cprintf("END PAGE TABLE\n");
80104b9c:	83 ec 0c             	sub    $0xc,%esp
80104b9f:	68 af a9 10 80       	push   $0x8010a9af
80104ba4:	e8 4b b8 ff ff       	call   801003f4 <cprintf>
80104ba9:	83 c4 10             	add    $0x10,%esp
  return 0;
80104bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bb1:	c9                   	leave  
80104bb2:	c3                   	ret    

80104bb3 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104bb3:	55                   	push   %ebp
80104bb4:	89 e5                	mov    %esp,%ebp
80104bb6:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbc:	83 c0 04             	add    $0x4,%eax
80104bbf:	83 ec 08             	sub    $0x8,%esp
80104bc2:	68 e9 a9 10 80       	push   $0x8010a9e9
80104bc7:	50                   	push   %eax
80104bc8:	e8 43 01 00 00       	call   80104d10 <initlock>
80104bcd:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bd6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104be2:	8b 45 08             	mov    0x8(%ebp),%eax
80104be5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104bec:	90                   	nop
80104bed:	c9                   	leave  
80104bee:	c3                   	ret    

80104bef <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104bef:	55                   	push   %ebp
80104bf0:	89 e5                	mov    %esp,%ebp
80104bf2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf8:	83 c0 04             	add    $0x4,%eax
80104bfb:	83 ec 0c             	sub    $0xc,%esp
80104bfe:	50                   	push   %eax
80104bff:	e8 2e 01 00 00       	call   80104d32 <acquire>
80104c04:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c07:	eb 15                	jmp    80104c1e <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104c09:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0c:	83 c0 04             	add    $0x4,%eax
80104c0f:	83 ec 08             	sub    $0x8,%esp
80104c12:	50                   	push   %eax
80104c13:	ff 75 08             	push   0x8(%ebp)
80104c16:	e8 a3 fb ff ff       	call   801047be <sleep>
80104c1b:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c21:	8b 00                	mov    (%eax),%eax
80104c23:	85 c0                	test   %eax,%eax
80104c25:	75 e2                	jne    80104c09 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104c27:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c30:	e8 e0 f2 ff ff       	call   80103f15 <myproc>
80104c35:	8b 50 10             	mov    0x10(%eax),%edx
80104c38:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c41:	83 c0 04             	add    $0x4,%eax
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	50                   	push   %eax
80104c48:	e8 53 01 00 00       	call   80104da0 <release>
80104c4d:	83 c4 10             	add    $0x10,%esp
}
80104c50:	90                   	nop
80104c51:	c9                   	leave  
80104c52:	c3                   	ret    

80104c53 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104c53:	55                   	push   %ebp
80104c54:	89 e5                	mov    %esp,%ebp
80104c56:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c59:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5c:	83 c0 04             	add    $0x4,%eax
80104c5f:	83 ec 0c             	sub    $0xc,%esp
80104c62:	50                   	push   %eax
80104c63:	e8 ca 00 00 00       	call   80104d32 <acquire>
80104c68:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c74:	8b 45 08             	mov    0x8(%ebp),%eax
80104c77:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c7e:	83 ec 0c             	sub    $0xc,%esp
80104c81:	ff 75 08             	push   0x8(%ebp)
80104c84:	e8 1c fc ff ff       	call   801048a5 <wakeup>
80104c89:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8f:	83 c0 04             	add    $0x4,%eax
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	50                   	push   %eax
80104c96:	e8 05 01 00 00       	call   80104da0 <release>
80104c9b:	83 c4 10             	add    $0x10,%esp
}
80104c9e:	90                   	nop
80104c9f:	c9                   	leave  
80104ca0:	c3                   	ret    

80104ca1 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104ca1:	55                   	push   %ebp
80104ca2:	89 e5                	mov    %esp,%ebp
80104ca4:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80104caa:	83 c0 04             	add    $0x4,%eax
80104cad:	83 ec 0c             	sub    $0xc,%esp
80104cb0:	50                   	push   %eax
80104cb1:	e8 7c 00 00 00       	call   80104d32 <acquire>
80104cb6:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbc:	8b 00                	mov    (%eax),%eax
80104cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc4:	83 c0 04             	add    $0x4,%eax
80104cc7:	83 ec 0c             	sub    $0xc,%esp
80104cca:	50                   	push   %eax
80104ccb:	e8 d0 00 00 00       	call   80104da0 <release>
80104cd0:	83 c4 10             	add    $0x10,%esp
  return r;
80104cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104cd6:	c9                   	leave  
80104cd7:	c3                   	ret    

80104cd8 <readeflags>:
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
80104cdb:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104cde:	9c                   	pushf  
80104cdf:	58                   	pop    %eax
80104ce0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ce3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ce6:	c9                   	leave  
80104ce7:	c3                   	ret    

80104ce8 <cli>:
{
80104ce8:	55                   	push   %ebp
80104ce9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ceb:	fa                   	cli    
}
80104cec:	90                   	nop
80104ced:	5d                   	pop    %ebp
80104cee:	c3                   	ret    

80104cef <sti>:
{
80104cef:	55                   	push   %ebp
80104cf0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104cf2:	fb                   	sti    
}
80104cf3:	90                   	nop
80104cf4:	5d                   	pop    %ebp
80104cf5:	c3                   	ret    

80104cf6 <xchg>:
{
80104cf6:	55                   	push   %ebp
80104cf7:	89 e5                	mov    %esp,%ebp
80104cf9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104cfc:	8b 55 08             	mov    0x8(%ebp),%edx
80104cff:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d05:	f0 87 02             	lock xchg %eax,(%edx)
80104d08:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104d0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d0e:	c9                   	leave  
80104d0f:	c3                   	ret    

80104d10 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d13:	8b 45 08             	mov    0x8(%ebp),%eax
80104d16:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d19:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d25:	8b 45 08             	mov    0x8(%ebp),%eax
80104d28:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d2f:	90                   	nop
80104d30:	5d                   	pop    %ebp
80104d31:	c3                   	ret    

80104d32 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d32:	55                   	push   %ebp
80104d33:	89 e5                	mov    %esp,%ebp
80104d35:	53                   	push   %ebx
80104d36:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d39:	e8 5f 01 00 00       	call   80104e9d <pushcli>
  if(holding(lk)){
80104d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d41:	83 ec 0c             	sub    $0xc,%esp
80104d44:	50                   	push   %eax
80104d45:	e8 23 01 00 00       	call   80104e6d <holding>
80104d4a:	83 c4 10             	add    $0x10,%esp
80104d4d:	85 c0                	test   %eax,%eax
80104d4f:	74 0d                	je     80104d5e <acquire+0x2c>
    panic("acquire");
80104d51:	83 ec 0c             	sub    $0xc,%esp
80104d54:	68 f4 a9 10 80       	push   $0x8010a9f4
80104d59:	e8 4b b8 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d5e:	90                   	nop
80104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d62:	83 ec 08             	sub    $0x8,%esp
80104d65:	6a 01                	push   $0x1
80104d67:	50                   	push   %eax
80104d68:	e8 89 ff ff ff       	call   80104cf6 <xchg>
80104d6d:	83 c4 10             	add    $0x10,%esp
80104d70:	85 c0                	test   %eax,%eax
80104d72:	75 eb                	jne    80104d5f <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d74:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d79:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d7c:	e8 1c f1 ff ff       	call   80103e9d <mycpu>
80104d81:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d84:	8b 45 08             	mov    0x8(%ebp),%eax
80104d87:	83 c0 0c             	add    $0xc,%eax
80104d8a:	83 ec 08             	sub    $0x8,%esp
80104d8d:	50                   	push   %eax
80104d8e:	8d 45 08             	lea    0x8(%ebp),%eax
80104d91:	50                   	push   %eax
80104d92:	e8 5b 00 00 00       	call   80104df2 <getcallerpcs>
80104d97:	83 c4 10             	add    $0x10,%esp
}
80104d9a:	90                   	nop
80104d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d9e:	c9                   	leave  
80104d9f:	c3                   	ret    

80104da0 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104da0:	55                   	push   %ebp
80104da1:	89 e5                	mov    %esp,%ebp
80104da3:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104da6:	83 ec 0c             	sub    $0xc,%esp
80104da9:	ff 75 08             	push   0x8(%ebp)
80104dac:	e8 bc 00 00 00       	call   80104e6d <holding>
80104db1:	83 c4 10             	add    $0x10,%esp
80104db4:	85 c0                	test   %eax,%eax
80104db6:	75 0d                	jne    80104dc5 <release+0x25>
    panic("release");
80104db8:	83 ec 0c             	sub    $0xc,%esp
80104dbb:	68 fc a9 10 80       	push   $0x8010a9fc
80104dc0:	e8 e4 b7 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104dd9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104dde:	8b 45 08             	mov    0x8(%ebp),%eax
80104de1:	8b 55 08             	mov    0x8(%ebp),%edx
80104de4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104dea:	e8 fb 00 00 00       	call   80104eea <popcli>
}
80104def:	90                   	nop
80104df0:	c9                   	leave  
80104df1:	c3                   	ret    

80104df2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104df2:	55                   	push   %ebp
80104df3:	89 e5                	mov    %esp,%ebp
80104df5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104df8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfb:	83 e8 08             	sub    $0x8,%eax
80104dfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e01:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e08:	eb 38                	jmp    80104e42 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e0a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e0e:	74 53                	je     80104e63 <getcallerpcs+0x71>
80104e10:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e17:	76 4a                	jbe    80104e63 <getcallerpcs+0x71>
80104e19:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e1d:	74 44                	je     80104e63 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e29:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2c:	01 c2                	add    %eax,%edx
80104e2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e31:	8b 40 04             	mov    0x4(%eax),%eax
80104e34:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e39:	8b 00                	mov    (%eax),%eax
80104e3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e3e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e42:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e46:	7e c2                	jle    80104e0a <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104e48:	eb 19                	jmp    80104e63 <getcallerpcs+0x71>
    pcs[i] = 0;
80104e4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e57:	01 d0                	add    %edx,%eax
80104e59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e5f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e63:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e67:	7e e1                	jle    80104e4a <getcallerpcs+0x58>
}
80104e69:	90                   	nop
80104e6a:	90                   	nop
80104e6b:	c9                   	leave  
80104e6c:	c3                   	ret    

80104e6d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e6d:	55                   	push   %ebp
80104e6e:	89 e5                	mov    %esp,%ebp
80104e70:	53                   	push   %ebx
80104e71:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e74:	8b 45 08             	mov    0x8(%ebp),%eax
80104e77:	8b 00                	mov    (%eax),%eax
80104e79:	85 c0                	test   %eax,%eax
80104e7b:	74 16                	je     80104e93 <holding+0x26>
80104e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e80:	8b 58 08             	mov    0x8(%eax),%ebx
80104e83:	e8 15 f0 ff ff       	call   80103e9d <mycpu>
80104e88:	39 c3                	cmp    %eax,%ebx
80104e8a:	75 07                	jne    80104e93 <holding+0x26>
80104e8c:	b8 01 00 00 00       	mov    $0x1,%eax
80104e91:	eb 05                	jmp    80104e98 <holding+0x2b>
80104e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e9b:	c9                   	leave  
80104e9c:	c3                   	ret    

80104e9d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e9d:	55                   	push   %ebp
80104e9e:	89 e5                	mov    %esp,%ebp
80104ea0:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ea3:	e8 30 fe ff ff       	call   80104cd8 <readeflags>
80104ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104eab:	e8 38 fe ff ff       	call   80104ce8 <cli>
  if(mycpu()->ncli == 0)
80104eb0:	e8 e8 ef ff ff       	call   80103e9d <mycpu>
80104eb5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ebb:	85 c0                	test   %eax,%eax
80104ebd:	75 14                	jne    80104ed3 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104ebf:	e8 d9 ef ff ff       	call   80103e9d <mycpu>
80104ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ec7:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ecd:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ed3:	e8 c5 ef ff ff       	call   80103e9d <mycpu>
80104ed8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ede:	83 c2 01             	add    $0x1,%edx
80104ee1:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ee7:	90                   	nop
80104ee8:	c9                   	leave  
80104ee9:	c3                   	ret    

80104eea <popcli>:

void
popcli(void)
{
80104eea:	55                   	push   %ebp
80104eeb:	89 e5                	mov    %esp,%ebp
80104eed:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ef0:	e8 e3 fd ff ff       	call   80104cd8 <readeflags>
80104ef5:	25 00 02 00 00       	and    $0x200,%eax
80104efa:	85 c0                	test   %eax,%eax
80104efc:	74 0d                	je     80104f0b <popcli+0x21>
    panic("popcli - interruptible");
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	68 04 aa 10 80       	push   $0x8010aa04
80104f06:	e8 9e b6 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104f0b:	e8 8d ef ff ff       	call   80103e9d <mycpu>
80104f10:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f16:	83 ea 01             	sub    $0x1,%edx
80104f19:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104f1f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f25:	85 c0                	test   %eax,%eax
80104f27:	79 0d                	jns    80104f36 <popcli+0x4c>
    panic("popcli");
80104f29:	83 ec 0c             	sub    $0xc,%esp
80104f2c:	68 1b aa 10 80       	push   $0x8010aa1b
80104f31:	e8 73 b6 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f36:	e8 62 ef ff ff       	call   80103e9d <mycpu>
80104f3b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f41:	85 c0                	test   %eax,%eax
80104f43:	75 14                	jne    80104f59 <popcli+0x6f>
80104f45:	e8 53 ef ff ff       	call   80103e9d <mycpu>
80104f4a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f50:	85 c0                	test   %eax,%eax
80104f52:	74 05                	je     80104f59 <popcli+0x6f>
    sti();
80104f54:	e8 96 fd ff ff       	call   80104cef <sti>
}
80104f59:	90                   	nop
80104f5a:	c9                   	leave  
80104f5b:	c3                   	ret    

80104f5c <stosb>:
{
80104f5c:	55                   	push   %ebp
80104f5d:	89 e5                	mov    %esp,%ebp
80104f5f:	57                   	push   %edi
80104f60:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f61:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f64:	8b 55 10             	mov    0x10(%ebp),%edx
80104f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6a:	89 cb                	mov    %ecx,%ebx
80104f6c:	89 df                	mov    %ebx,%edi
80104f6e:	89 d1                	mov    %edx,%ecx
80104f70:	fc                   	cld    
80104f71:	f3 aa                	rep stos %al,%es:(%edi)
80104f73:	89 ca                	mov    %ecx,%edx
80104f75:	89 fb                	mov    %edi,%ebx
80104f77:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f7a:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f7d:	90                   	nop
80104f7e:	5b                   	pop    %ebx
80104f7f:	5f                   	pop    %edi
80104f80:	5d                   	pop    %ebp
80104f81:	c3                   	ret    

80104f82 <stosl>:
{
80104f82:	55                   	push   %ebp
80104f83:	89 e5                	mov    %esp,%ebp
80104f85:	57                   	push   %edi
80104f86:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f87:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f8a:	8b 55 10             	mov    0x10(%ebp),%edx
80104f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f90:	89 cb                	mov    %ecx,%ebx
80104f92:	89 df                	mov    %ebx,%edi
80104f94:	89 d1                	mov    %edx,%ecx
80104f96:	fc                   	cld    
80104f97:	f3 ab                	rep stos %eax,%es:(%edi)
80104f99:	89 ca                	mov    %ecx,%edx
80104f9b:	89 fb                	mov    %edi,%ebx
80104f9d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fa0:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104fa3:	90                   	nop
80104fa4:	5b                   	pop    %ebx
80104fa5:	5f                   	pop    %edi
80104fa6:	5d                   	pop    %ebp
80104fa7:	c3                   	ret    

80104fa8 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104fa8:	55                   	push   %ebp
80104fa9:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fab:	8b 45 08             	mov    0x8(%ebp),%eax
80104fae:	83 e0 03             	and    $0x3,%eax
80104fb1:	85 c0                	test   %eax,%eax
80104fb3:	75 43                	jne    80104ff8 <memset+0x50>
80104fb5:	8b 45 10             	mov    0x10(%ebp),%eax
80104fb8:	83 e0 03             	and    $0x3,%eax
80104fbb:	85 c0                	test   %eax,%eax
80104fbd:	75 39                	jne    80104ff8 <memset+0x50>
    c &= 0xFF;
80104fbf:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104fc6:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc9:	c1 e8 02             	shr    $0x2,%eax
80104fcc:	89 c2                	mov    %eax,%edx
80104fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd1:	c1 e0 18             	shl    $0x18,%eax
80104fd4:	89 c1                	mov    %eax,%ecx
80104fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd9:	c1 e0 10             	shl    $0x10,%eax
80104fdc:	09 c1                	or     %eax,%ecx
80104fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe1:	c1 e0 08             	shl    $0x8,%eax
80104fe4:	09 c8                	or     %ecx,%eax
80104fe6:	0b 45 0c             	or     0xc(%ebp),%eax
80104fe9:	52                   	push   %edx
80104fea:	50                   	push   %eax
80104feb:	ff 75 08             	push   0x8(%ebp)
80104fee:	e8 8f ff ff ff       	call   80104f82 <stosl>
80104ff3:	83 c4 0c             	add    $0xc,%esp
80104ff6:	eb 12                	jmp    8010500a <memset+0x62>
  } else
    stosb(dst, c, n);
80104ff8:	8b 45 10             	mov    0x10(%ebp),%eax
80104ffb:	50                   	push   %eax
80104ffc:	ff 75 0c             	push   0xc(%ebp)
80104fff:	ff 75 08             	push   0x8(%ebp)
80105002:	e8 55 ff ff ff       	call   80104f5c <stosb>
80105007:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010500a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010500d:	c9                   	leave  
8010500e:	c3                   	ret    

8010500f <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010500f:	55                   	push   %ebp
80105010:	89 e5                	mov    %esp,%ebp
80105012:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105015:	8b 45 08             	mov    0x8(%ebp),%eax
80105018:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010501b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105021:	eb 30                	jmp    80105053 <memcmp+0x44>
    if(*s1 != *s2)
80105023:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105026:	0f b6 10             	movzbl (%eax),%edx
80105029:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010502c:	0f b6 00             	movzbl (%eax),%eax
8010502f:	38 c2                	cmp    %al,%dl
80105031:	74 18                	je     8010504b <memcmp+0x3c>
      return *s1 - *s2;
80105033:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105036:	0f b6 00             	movzbl (%eax),%eax
80105039:	0f b6 d0             	movzbl %al,%edx
8010503c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010503f:	0f b6 00             	movzbl (%eax),%eax
80105042:	0f b6 c8             	movzbl %al,%ecx
80105045:	89 d0                	mov    %edx,%eax
80105047:	29 c8                	sub    %ecx,%eax
80105049:	eb 1a                	jmp    80105065 <memcmp+0x56>
    s1++, s2++;
8010504b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010504f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105053:	8b 45 10             	mov    0x10(%ebp),%eax
80105056:	8d 50 ff             	lea    -0x1(%eax),%edx
80105059:	89 55 10             	mov    %edx,0x10(%ebp)
8010505c:	85 c0                	test   %eax,%eax
8010505e:	75 c3                	jne    80105023 <memcmp+0x14>
  }

  return 0;
80105060:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105065:	c9                   	leave  
80105066:	c3                   	ret    

80105067 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010506d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105070:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105073:	8b 45 08             	mov    0x8(%ebp),%eax
80105076:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105079:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010507c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010507f:	73 54                	jae    801050d5 <memmove+0x6e>
80105081:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105084:	8b 45 10             	mov    0x10(%ebp),%eax
80105087:	01 d0                	add    %edx,%eax
80105089:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010508c:	73 47                	jae    801050d5 <memmove+0x6e>
    s += n;
8010508e:	8b 45 10             	mov    0x10(%ebp),%eax
80105091:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105094:	8b 45 10             	mov    0x10(%ebp),%eax
80105097:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010509a:	eb 13                	jmp    801050af <memmove+0x48>
      *--d = *--s;
8010509c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050a0:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a7:	0f b6 10             	movzbl (%eax),%edx
801050aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050ad:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050af:	8b 45 10             	mov    0x10(%ebp),%eax
801050b2:	8d 50 ff             	lea    -0x1(%eax),%edx
801050b5:	89 55 10             	mov    %edx,0x10(%ebp)
801050b8:	85 c0                	test   %eax,%eax
801050ba:	75 e0                	jne    8010509c <memmove+0x35>
  if(s < d && s + n > d){
801050bc:	eb 24                	jmp    801050e2 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801050be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050c1:	8d 42 01             	lea    0x1(%edx),%eax
801050c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050ca:	8d 48 01             	lea    0x1(%eax),%ecx
801050cd:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801050d0:	0f b6 12             	movzbl (%edx),%edx
801050d3:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050d5:	8b 45 10             	mov    0x10(%ebp),%eax
801050d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801050db:	89 55 10             	mov    %edx,0x10(%ebp)
801050de:	85 c0                	test   %eax,%eax
801050e0:	75 dc                	jne    801050be <memmove+0x57>

  return dst;
801050e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050e5:	c9                   	leave  
801050e6:	c3                   	ret    

801050e7 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050e7:	55                   	push   %ebp
801050e8:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801050ea:	ff 75 10             	push   0x10(%ebp)
801050ed:	ff 75 0c             	push   0xc(%ebp)
801050f0:	ff 75 08             	push   0x8(%ebp)
801050f3:	e8 6f ff ff ff       	call   80105067 <memmove>
801050f8:	83 c4 0c             	add    $0xc,%esp
}
801050fb:	c9                   	leave  
801050fc:	c3                   	ret    

801050fd <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801050fd:	55                   	push   %ebp
801050fe:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105100:	eb 0c                	jmp    8010510e <strncmp+0x11>
    n--, p++, q++;
80105102:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105106:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010510a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010510e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105112:	74 1a                	je     8010512e <strncmp+0x31>
80105114:	8b 45 08             	mov    0x8(%ebp),%eax
80105117:	0f b6 00             	movzbl (%eax),%eax
8010511a:	84 c0                	test   %al,%al
8010511c:	74 10                	je     8010512e <strncmp+0x31>
8010511e:	8b 45 08             	mov    0x8(%ebp),%eax
80105121:	0f b6 10             	movzbl (%eax),%edx
80105124:	8b 45 0c             	mov    0xc(%ebp),%eax
80105127:	0f b6 00             	movzbl (%eax),%eax
8010512a:	38 c2                	cmp    %al,%dl
8010512c:	74 d4                	je     80105102 <strncmp+0x5>
  if(n == 0)
8010512e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105132:	75 07                	jne    8010513b <strncmp+0x3e>
    return 0;
80105134:	b8 00 00 00 00       	mov    $0x0,%eax
80105139:	eb 16                	jmp    80105151 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010513b:	8b 45 08             	mov    0x8(%ebp),%eax
8010513e:	0f b6 00             	movzbl (%eax),%eax
80105141:	0f b6 d0             	movzbl %al,%edx
80105144:	8b 45 0c             	mov    0xc(%ebp),%eax
80105147:	0f b6 00             	movzbl (%eax),%eax
8010514a:	0f b6 c8             	movzbl %al,%ecx
8010514d:	89 d0                	mov    %edx,%eax
8010514f:	29 c8                	sub    %ecx,%eax
}
80105151:	5d                   	pop    %ebp
80105152:	c3                   	ret    

80105153 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105153:	55                   	push   %ebp
80105154:	89 e5                	mov    %esp,%ebp
80105156:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105159:	8b 45 08             	mov    0x8(%ebp),%eax
8010515c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010515f:	90                   	nop
80105160:	8b 45 10             	mov    0x10(%ebp),%eax
80105163:	8d 50 ff             	lea    -0x1(%eax),%edx
80105166:	89 55 10             	mov    %edx,0x10(%ebp)
80105169:	85 c0                	test   %eax,%eax
8010516b:	7e 2c                	jle    80105199 <strncpy+0x46>
8010516d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105170:	8d 42 01             	lea    0x1(%edx),%eax
80105173:	89 45 0c             	mov    %eax,0xc(%ebp)
80105176:	8b 45 08             	mov    0x8(%ebp),%eax
80105179:	8d 48 01             	lea    0x1(%eax),%ecx
8010517c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010517f:	0f b6 12             	movzbl (%edx),%edx
80105182:	88 10                	mov    %dl,(%eax)
80105184:	0f b6 00             	movzbl (%eax),%eax
80105187:	84 c0                	test   %al,%al
80105189:	75 d5                	jne    80105160 <strncpy+0xd>
    ;
  while(n-- > 0)
8010518b:	eb 0c                	jmp    80105199 <strncpy+0x46>
    *s++ = 0;
8010518d:	8b 45 08             	mov    0x8(%ebp),%eax
80105190:	8d 50 01             	lea    0x1(%eax),%edx
80105193:	89 55 08             	mov    %edx,0x8(%ebp)
80105196:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105199:	8b 45 10             	mov    0x10(%ebp),%eax
8010519c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010519f:	89 55 10             	mov    %edx,0x10(%ebp)
801051a2:	85 c0                	test   %eax,%eax
801051a4:	7f e7                	jg     8010518d <strncpy+0x3a>
  return os;
801051a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051a9:	c9                   	leave  
801051aa:	c3                   	ret    

801051ab <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051ab:	55                   	push   %ebp
801051ac:	89 e5                	mov    %esp,%ebp
801051ae:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051bb:	7f 05                	jg     801051c2 <safestrcpy+0x17>
    return os;
801051bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c0:	eb 32                	jmp    801051f4 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801051c2:	90                   	nop
801051c3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051cb:	7e 1e                	jle    801051eb <safestrcpy+0x40>
801051cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801051d0:	8d 42 01             	lea    0x1(%edx),%eax
801051d3:	89 45 0c             	mov    %eax,0xc(%ebp)
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	8d 48 01             	lea    0x1(%eax),%ecx
801051dc:	89 4d 08             	mov    %ecx,0x8(%ebp)
801051df:	0f b6 12             	movzbl (%edx),%edx
801051e2:	88 10                	mov    %dl,(%eax)
801051e4:	0f b6 00             	movzbl (%eax),%eax
801051e7:	84 c0                	test   %al,%al
801051e9:	75 d8                	jne    801051c3 <safestrcpy+0x18>
    ;
  *s = 0;
801051eb:	8b 45 08             	mov    0x8(%ebp),%eax
801051ee:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801051f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051f4:	c9                   	leave  
801051f5:	c3                   	ret    

801051f6 <strlen>:

int
strlen(const char *s)
{
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
801051f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801051fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105203:	eb 04                	jmp    80105209 <strlen+0x13>
80105205:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105209:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	01 d0                	add    %edx,%eax
80105211:	0f b6 00             	movzbl (%eax),%eax
80105214:	84 c0                	test   %al,%al
80105216:	75 ed                	jne    80105205 <strlen+0xf>
    ;
  return n;
80105218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010521b:	c9                   	leave  
8010521c:	c3                   	ret    

8010521d <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010521d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105221:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105225:	55                   	push   %ebp
  pushl %ebx
80105226:	53                   	push   %ebx
  pushl %esi
80105227:	56                   	push   %esi
  pushl %edi
80105228:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105229:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010522b:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010522d:	5f                   	pop    %edi
  popl %esi
8010522e:	5e                   	pop    %esi
  popl %ebx
8010522f:	5b                   	pop    %ebx
  popl %ebp
80105230:	5d                   	pop    %ebp
  ret
80105231:	c3                   	ret    

80105232 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105232:	55                   	push   %ebp
80105233:	89 e5                	mov    %esp,%ebp
  //커널 영역 침범 방지
  if(addr >=KERNBASE || addr+4 > KERNBASE)
80105235:	8b 45 08             	mov    0x8(%ebp),%eax
80105238:	85 c0                	test   %eax,%eax
8010523a:	78 0d                	js     80105249 <fetchint+0x17>
8010523c:	8b 45 08             	mov    0x8(%ebp),%eax
8010523f:	83 c0 04             	add    $0x4,%eax
80105242:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105247:	76 07                	jbe    80105250 <fetchint+0x1e>
    return -1;
80105249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524e:	eb 0f                	jmp    8010525f <fetchint+0x2d>
  
  *ip = *(int*)(addr);
80105250:	8b 45 08             	mov    0x8(%ebp),%eax
80105253:	8b 10                	mov    (%eax),%edx
80105255:	8b 45 0c             	mov    0xc(%ebp),%eax
80105258:	89 10                	mov    %edx,(%eax)
  return 0;
8010525a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010525f:	5d                   	pop    %ebp
80105260:	c3                   	ret    

80105261 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105261:	55                   	push   %ebp
80105262:	89 e5                	mov    %esp,%ebp
80105264:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  // 잘못된 접근 방지
  if(addr >=KERNBASE)
80105267:	8b 45 08             	mov    0x8(%ebp),%eax
8010526a:	85 c0                	test   %eax,%eax
8010526c:	79 07                	jns    80105275 <fetchstr+0x14>
    return -1;
8010526e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105273:	eb 40                	jmp    801052b5 <fetchstr+0x54>

  *pp = (char*)addr;
80105275:	8b 55 08             	mov    0x8(%ebp),%edx
80105278:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527b:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE; //상한선은 가상 메모리 한계로 설정
8010527d:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105284:	8b 45 0c             	mov    0xc(%ebp),%eax
80105287:	8b 00                	mov    (%eax),%eax
80105289:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010528c:	eb 1a                	jmp    801052a8 <fetchstr+0x47>
    if(*s == 0)
8010528e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105291:	0f b6 00             	movzbl (%eax),%eax
80105294:	84 c0                	test   %al,%al
80105296:	75 0c                	jne    801052a4 <fetchstr+0x43>
      return s - *pp;
80105298:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529b:	8b 10                	mov    (%eax),%edx
8010529d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052a0:	29 d0                	sub    %edx,%eax
801052a2:	eb 11                	jmp    801052b5 <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
801052a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ab:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052ae:	72 de                	jb     8010528e <fetchstr+0x2d>
  }
  return -1;
801052b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052b5:	c9                   	leave  
801052b6:	c3                   	ret    

801052b7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801052b7:	55                   	push   %ebp
801052b8:	89 e5                	mov    %esp,%ebp
801052ba:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801052bd:	e8 53 ec ff ff       	call   80103f15 <myproc>
801052c2:	8b 40 18             	mov    0x18(%eax),%eax
801052c5:	8b 50 44             	mov    0x44(%eax),%edx
801052c8:	8b 45 08             	mov    0x8(%ebp),%eax
801052cb:	c1 e0 02             	shl    $0x2,%eax
801052ce:	01 d0                	add    %edx,%eax
801052d0:	83 c0 04             	add    $0x4,%eax
801052d3:	83 ec 08             	sub    $0x8,%esp
801052d6:	ff 75 0c             	push   0xc(%ebp)
801052d9:	50                   	push   %eax
801052da:	e8 53 ff ff ff       	call   80105232 <fetchint>
801052df:	83 c4 10             	add    $0x10,%esp
}
801052e2:	c9                   	leave  
801052e3:	c3                   	ret    

801052e4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801052e4:	55                   	push   %ebp
801052e5:	89 e5                	mov    %esp,%ebp
801052e7:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801052ea:	83 ec 08             	sub    $0x8,%esp
801052ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052f0:	50                   	push   %eax
801052f1:	ff 75 08             	push   0x8(%ebp)
801052f4:	e8 be ff ff ff       	call   801052b7 <argint>
801052f9:	83 c4 10             	add    $0x10,%esp
801052fc:	85 c0                	test   %eax,%eax
801052fe:	79 07                	jns    80105307 <argptr+0x23>
    return -1;
80105300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105305:	eb 34                	jmp    8010533b <argptr+0x57>
    
  //size만큼 공간 확보 + 커널 영역 접근 방지
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80105307:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010530b:	78 18                	js     80105325 <argptr+0x41>
8010530d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105310:	85 c0                	test   %eax,%eax
80105312:	78 11                	js     80105325 <argptr+0x41>
80105314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105317:	89 c2                	mov    %eax,%edx
80105319:	8b 45 10             	mov    0x10(%ebp),%eax
8010531c:	01 d0                	add    %edx,%eax
8010531e:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105323:	76 07                	jbe    8010532c <argptr+0x48>
    return -1;
80105325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010532a:	eb 0f                	jmp    8010533b <argptr+0x57>
  *pp = (char*)i;
8010532c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010532f:	89 c2                	mov    %eax,%edx
80105331:	8b 45 0c             	mov    0xc(%ebp),%eax
80105334:	89 10                	mov    %edx,(%eax)
  return 0;
80105336:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010533b:	c9                   	leave  
8010533c:	c3                   	ret    

8010533d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010533d:	55                   	push   %ebp
8010533e:	89 e5                	mov    %esp,%ebp
80105340:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105343:	83 ec 08             	sub    $0x8,%esp
80105346:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105349:	50                   	push   %eax
8010534a:	ff 75 08             	push   0x8(%ebp)
8010534d:	e8 65 ff ff ff       	call   801052b7 <argint>
80105352:	83 c4 10             	add    $0x10,%esp
80105355:	85 c0                	test   %eax,%eax
80105357:	79 07                	jns    80105360 <argstr+0x23>
    return -1;
80105359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010535e:	eb 12                	jmp    80105372 <argstr+0x35>
  return fetchstr(addr, pp);
80105360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105363:	83 ec 08             	sub    $0x8,%esp
80105366:	ff 75 0c             	push   0xc(%ebp)
80105369:	50                   	push   %eax
8010536a:	e8 f2 fe ff ff       	call   80105261 <fetchstr>
8010536f:	83 c4 10             	add    $0x10,%esp
}
80105372:	c9                   	leave  
80105373:	c3                   	ret    

80105374 <syscall>:

};

void
syscall(void)
{
80105374:	55                   	push   %ebp
80105375:	89 e5                	mov    %esp,%ebp
80105377:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010537a:	e8 96 eb ff ff       	call   80103f15 <myproc>
8010537f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105385:	8b 40 18             	mov    0x18(%eax),%eax
80105388:	8b 40 1c             	mov    0x1c(%eax),%eax
8010538b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010538e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105392:	7e 2f                	jle    801053c3 <syscall+0x4f>
80105394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105397:	83 f8 16             	cmp    $0x16,%eax
8010539a:	77 27                	ja     801053c3 <syscall+0x4f>
8010539c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539f:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053a6:	85 c0                	test   %eax,%eax
801053a8:	74 19                	je     801053c3 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801053aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ad:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053b4:	ff d0                	call   *%eax
801053b6:	89 c2                	mov    %eax,%edx
801053b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053bb:	8b 40 18             	mov    0x18(%eax),%eax
801053be:	89 50 1c             	mov    %edx,0x1c(%eax)
801053c1:	eb 2c                	jmp    801053ef <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801053c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c6:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801053c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053cc:	8b 40 10             	mov    0x10(%eax),%eax
801053cf:	ff 75 f0             	push   -0x10(%ebp)
801053d2:	52                   	push   %edx
801053d3:	50                   	push   %eax
801053d4:	68 22 aa 10 80       	push   $0x8010aa22
801053d9:	e8 16 b0 ff ff       	call   801003f4 <cprintf>
801053de:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e4:	8b 40 18             	mov    0x18(%eax),%eax
801053e7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801053ee:	90                   	nop
801053ef:	90                   	nop
801053f0:	c9                   	leave  
801053f1:	c3                   	ret    

801053f2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
801053f5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801053f8:	83 ec 08             	sub    $0x8,%esp
801053fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053fe:	50                   	push   %eax
801053ff:	ff 75 08             	push   0x8(%ebp)
80105402:	e8 b0 fe ff ff       	call   801052b7 <argint>
80105407:	83 c4 10             	add    $0x10,%esp
8010540a:	85 c0                	test   %eax,%eax
8010540c:	79 07                	jns    80105415 <argfd+0x23>
    return -1;
8010540e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105413:	eb 4f                	jmp    80105464 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105418:	85 c0                	test   %eax,%eax
8010541a:	78 20                	js     8010543c <argfd+0x4a>
8010541c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541f:	83 f8 0f             	cmp    $0xf,%eax
80105422:	7f 18                	jg     8010543c <argfd+0x4a>
80105424:	e8 ec ea ff ff       	call   80103f15 <myproc>
80105429:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010542c:	83 c2 08             	add    $0x8,%edx
8010542f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105433:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105436:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010543a:	75 07                	jne    80105443 <argfd+0x51>
    return -1;
8010543c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105441:	eb 21                	jmp    80105464 <argfd+0x72>
  if(pfd)
80105443:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105447:	74 08                	je     80105451 <argfd+0x5f>
    *pfd = fd;
80105449:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010544c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544f:	89 10                	mov    %edx,(%eax)
  if(pf)
80105451:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105455:	74 08                	je     8010545f <argfd+0x6d>
    *pf = f;
80105457:	8b 45 10             	mov    0x10(%ebp),%eax
8010545a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010545d:	89 10                	mov    %edx,(%eax)
  return 0;
8010545f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105464:	c9                   	leave  
80105465:	c3                   	ret    

80105466 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105466:	55                   	push   %ebp
80105467:	89 e5                	mov    %esp,%ebp
80105469:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010546c:	e8 a4 ea ff ff       	call   80103f15 <myproc>
80105471:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105474:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010547b:	eb 2a                	jmp    801054a7 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010547d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105480:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105483:	83 c2 08             	add    $0x8,%edx
80105486:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010548a:	85 c0                	test   %eax,%eax
8010548c:	75 15                	jne    801054a3 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010548e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105491:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105494:	8d 4a 08             	lea    0x8(%edx),%ecx
80105497:	8b 55 08             	mov    0x8(%ebp),%edx
8010549a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010549e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a1:	eb 0f                	jmp    801054b2 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801054a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054a7:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054ab:	7e d0                	jle    8010547d <fdalloc+0x17>
    }
  }
  return -1;
801054ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054b2:	c9                   	leave  
801054b3:	c3                   	ret    

801054b4 <sys_dup>:

int
sys_dup(void)
{
801054b4:	55                   	push   %ebp
801054b5:	89 e5                	mov    %esp,%ebp
801054b7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801054ba:	83 ec 04             	sub    $0x4,%esp
801054bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054c0:	50                   	push   %eax
801054c1:	6a 00                	push   $0x0
801054c3:	6a 00                	push   $0x0
801054c5:	e8 28 ff ff ff       	call   801053f2 <argfd>
801054ca:	83 c4 10             	add    $0x10,%esp
801054cd:	85 c0                	test   %eax,%eax
801054cf:	79 07                	jns    801054d8 <sys_dup+0x24>
    return -1;
801054d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d6:	eb 31                	jmp    80105509 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054db:	83 ec 0c             	sub    $0xc,%esp
801054de:	50                   	push   %eax
801054df:	e8 82 ff ff ff       	call   80105466 <fdalloc>
801054e4:	83 c4 10             	add    $0x10,%esp
801054e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ee:	79 07                	jns    801054f7 <sys_dup+0x43>
    return -1;
801054f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f5:	eb 12                	jmp    80105509 <sys_dup+0x55>
  filedup(f);
801054f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fa:	83 ec 0c             	sub    $0xc,%esp
801054fd:	50                   	push   %eax
801054fe:	e8 48 bb ff ff       	call   8010104b <filedup>
80105503:	83 c4 10             	add    $0x10,%esp
  return fd;
80105506:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105509:	c9                   	leave  
8010550a:	c3                   	ret    

8010550b <sys_read>:

int
sys_read(void)
{
8010550b:	55                   	push   %ebp
8010550c:	89 e5                	mov    %esp,%ebp
8010550e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105511:	83 ec 04             	sub    $0x4,%esp
80105514:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105517:	50                   	push   %eax
80105518:	6a 00                	push   $0x0
8010551a:	6a 00                	push   $0x0
8010551c:	e8 d1 fe ff ff       	call   801053f2 <argfd>
80105521:	83 c4 10             	add    $0x10,%esp
80105524:	85 c0                	test   %eax,%eax
80105526:	78 2e                	js     80105556 <sys_read+0x4b>
80105528:	83 ec 08             	sub    $0x8,%esp
8010552b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010552e:	50                   	push   %eax
8010552f:	6a 02                	push   $0x2
80105531:	e8 81 fd ff ff       	call   801052b7 <argint>
80105536:	83 c4 10             	add    $0x10,%esp
80105539:	85 c0                	test   %eax,%eax
8010553b:	78 19                	js     80105556 <sys_read+0x4b>
8010553d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105540:	83 ec 04             	sub    $0x4,%esp
80105543:	50                   	push   %eax
80105544:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105547:	50                   	push   %eax
80105548:	6a 01                	push   $0x1
8010554a:	e8 95 fd ff ff       	call   801052e4 <argptr>
8010554f:	83 c4 10             	add    $0x10,%esp
80105552:	85 c0                	test   %eax,%eax
80105554:	79 07                	jns    8010555d <sys_read+0x52>
    return -1;
80105556:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555b:	eb 17                	jmp    80105574 <sys_read+0x69>
  return fileread(f, p, n);
8010555d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105560:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105566:	83 ec 04             	sub    $0x4,%esp
80105569:	51                   	push   %ecx
8010556a:	52                   	push   %edx
8010556b:	50                   	push   %eax
8010556c:	e8 6a bc ff ff       	call   801011db <fileread>
80105571:	83 c4 10             	add    $0x10,%esp
}
80105574:	c9                   	leave  
80105575:	c3                   	ret    

80105576 <sys_write>:

int
sys_write(void)
{
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
80105579:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010557c:	83 ec 04             	sub    $0x4,%esp
8010557f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105582:	50                   	push   %eax
80105583:	6a 00                	push   $0x0
80105585:	6a 00                	push   $0x0
80105587:	e8 66 fe ff ff       	call   801053f2 <argfd>
8010558c:	83 c4 10             	add    $0x10,%esp
8010558f:	85 c0                	test   %eax,%eax
80105591:	78 2e                	js     801055c1 <sys_write+0x4b>
80105593:	83 ec 08             	sub    $0x8,%esp
80105596:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105599:	50                   	push   %eax
8010559a:	6a 02                	push   $0x2
8010559c:	e8 16 fd ff ff       	call   801052b7 <argint>
801055a1:	83 c4 10             	add    $0x10,%esp
801055a4:	85 c0                	test   %eax,%eax
801055a6:	78 19                	js     801055c1 <sys_write+0x4b>
801055a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ab:	83 ec 04             	sub    $0x4,%esp
801055ae:	50                   	push   %eax
801055af:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055b2:	50                   	push   %eax
801055b3:	6a 01                	push   $0x1
801055b5:	e8 2a fd ff ff       	call   801052e4 <argptr>
801055ba:	83 c4 10             	add    $0x10,%esp
801055bd:	85 c0                	test   %eax,%eax
801055bf:	79 07                	jns    801055c8 <sys_write+0x52>
    return -1;
801055c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c6:	eb 17                	jmp    801055df <sys_write+0x69>
  return filewrite(f, p, n);
801055c8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d1:	83 ec 04             	sub    $0x4,%esp
801055d4:	51                   	push   %ecx
801055d5:	52                   	push   %edx
801055d6:	50                   	push   %eax
801055d7:	e8 b7 bc ff ff       	call   80101293 <filewrite>
801055dc:	83 c4 10             	add    $0x10,%esp
}
801055df:	c9                   	leave  
801055e0:	c3                   	ret    

801055e1 <sys_close>:

int
sys_close(void)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801055e7:	83 ec 04             	sub    $0x4,%esp
801055ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055ed:	50                   	push   %eax
801055ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055f1:	50                   	push   %eax
801055f2:	6a 00                	push   $0x0
801055f4:	e8 f9 fd ff ff       	call   801053f2 <argfd>
801055f9:	83 c4 10             	add    $0x10,%esp
801055fc:	85 c0                	test   %eax,%eax
801055fe:	79 07                	jns    80105607 <sys_close+0x26>
    return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105605:	eb 27                	jmp    8010562e <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105607:	e8 09 e9 ff ff       	call   80103f15 <myproc>
8010560c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010560f:	83 c2 08             	add    $0x8,%edx
80105612:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105619:	00 
  fileclose(f);
8010561a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561d:	83 ec 0c             	sub    $0xc,%esp
80105620:	50                   	push   %eax
80105621:	e8 76 ba ff ff       	call   8010109c <fileclose>
80105626:	83 c4 10             	add    $0x10,%esp
  return 0;
80105629:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010562e:	c9                   	leave  
8010562f:	c3                   	ret    

80105630 <sys_fstat>:

int
sys_fstat(void)
{
80105630:	55                   	push   %ebp
80105631:	89 e5                	mov    %esp,%ebp
80105633:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105636:	83 ec 04             	sub    $0x4,%esp
80105639:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010563c:	50                   	push   %eax
8010563d:	6a 00                	push   $0x0
8010563f:	6a 00                	push   $0x0
80105641:	e8 ac fd ff ff       	call   801053f2 <argfd>
80105646:	83 c4 10             	add    $0x10,%esp
80105649:	85 c0                	test   %eax,%eax
8010564b:	78 17                	js     80105664 <sys_fstat+0x34>
8010564d:	83 ec 04             	sub    $0x4,%esp
80105650:	6a 14                	push   $0x14
80105652:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105655:	50                   	push   %eax
80105656:	6a 01                	push   $0x1
80105658:	e8 87 fc ff ff       	call   801052e4 <argptr>
8010565d:	83 c4 10             	add    $0x10,%esp
80105660:	85 c0                	test   %eax,%eax
80105662:	79 07                	jns    8010566b <sys_fstat+0x3b>
    return -1;
80105664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105669:	eb 13                	jmp    8010567e <sys_fstat+0x4e>
  return filestat(f, st);
8010566b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010566e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105671:	83 ec 08             	sub    $0x8,%esp
80105674:	52                   	push   %edx
80105675:	50                   	push   %eax
80105676:	e8 09 bb ff ff       	call   80101184 <filestat>
8010567b:	83 c4 10             	add    $0x10,%esp
}
8010567e:	c9                   	leave  
8010567f:	c3                   	ret    

80105680 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105686:	83 ec 08             	sub    $0x8,%esp
80105689:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010568c:	50                   	push   %eax
8010568d:	6a 00                	push   $0x0
8010568f:	e8 a9 fc ff ff       	call   8010533d <argstr>
80105694:	83 c4 10             	add    $0x10,%esp
80105697:	85 c0                	test   %eax,%eax
80105699:	78 15                	js     801056b0 <sys_link+0x30>
8010569b:	83 ec 08             	sub    $0x8,%esp
8010569e:	8d 45 dc             	lea    -0x24(%ebp),%eax
801056a1:	50                   	push   %eax
801056a2:	6a 01                	push   $0x1
801056a4:	e8 94 fc ff ff       	call   8010533d <argstr>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	85 c0                	test   %eax,%eax
801056ae:	79 0a                	jns    801056ba <sys_link+0x3a>
    return -1;
801056b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b5:	e9 68 01 00 00       	jmp    80105822 <sys_link+0x1a2>

  begin_op();
801056ba:	e8 62 de ff ff       	call   80103521 <begin_op>
  if((ip = namei(old)) == 0){
801056bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801056c2:	83 ec 0c             	sub    $0xc,%esp
801056c5:	50                   	push   %eax
801056c6:	e8 53 ce ff ff       	call   8010251e <namei>
801056cb:	83 c4 10             	add    $0x10,%esp
801056ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d5:	75 0f                	jne    801056e6 <sys_link+0x66>
    end_op();
801056d7:	e8 d1 de ff ff       	call   801035ad <end_op>
    return -1;
801056dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e1:	e9 3c 01 00 00       	jmp    80105822 <sys_link+0x1a2>
  }

  ilock(ip);
801056e6:	83 ec 0c             	sub    $0xc,%esp
801056e9:	ff 75 f4             	push   -0xc(%ebp)
801056ec:	e8 fa c2 ff ff       	call   801019eb <ilock>
801056f1:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056fb:	66 83 f8 01          	cmp    $0x1,%ax
801056ff:	75 1d                	jne    8010571e <sys_link+0x9e>
    iunlockput(ip);
80105701:	83 ec 0c             	sub    $0xc,%esp
80105704:	ff 75 f4             	push   -0xc(%ebp)
80105707:	e8 10 c5 ff ff       	call   80101c1c <iunlockput>
8010570c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010570f:	e8 99 de ff ff       	call   801035ad <end_op>
    return -1;
80105714:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105719:	e9 04 01 00 00       	jmp    80105822 <sys_link+0x1a2>
  }

  ip->nlink++;
8010571e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105721:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105725:	83 c0 01             	add    $0x1,%eax
80105728:	89 c2                	mov    %eax,%edx
8010572a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105731:	83 ec 0c             	sub    $0xc,%esp
80105734:	ff 75 f4             	push   -0xc(%ebp)
80105737:	e8 d2 c0 ff ff       	call   8010180e <iupdate>
8010573c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010573f:	83 ec 0c             	sub    $0xc,%esp
80105742:	ff 75 f4             	push   -0xc(%ebp)
80105745:	e8 b4 c3 ff ff       	call   80101afe <iunlock>
8010574a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010574d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105750:	83 ec 08             	sub    $0x8,%esp
80105753:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105756:	52                   	push   %edx
80105757:	50                   	push   %eax
80105758:	e8 dd cd ff ff       	call   8010253a <nameiparent>
8010575d:	83 c4 10             	add    $0x10,%esp
80105760:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105763:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105767:	74 71                	je     801057da <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105769:	83 ec 0c             	sub    $0xc,%esp
8010576c:	ff 75 f0             	push   -0x10(%ebp)
8010576f:	e8 77 c2 ff ff       	call   801019eb <ilock>
80105774:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577a:	8b 10                	mov    (%eax),%edx
8010577c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577f:	8b 00                	mov    (%eax),%eax
80105781:	39 c2                	cmp    %eax,%edx
80105783:	75 1d                	jne    801057a2 <sys_link+0x122>
80105785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105788:	8b 40 04             	mov    0x4(%eax),%eax
8010578b:	83 ec 04             	sub    $0x4,%esp
8010578e:	50                   	push   %eax
8010578f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105792:	50                   	push   %eax
80105793:	ff 75 f0             	push   -0x10(%ebp)
80105796:	e8 ec ca ff ff       	call   80102287 <dirlink>
8010579b:	83 c4 10             	add    $0x10,%esp
8010579e:	85 c0                	test   %eax,%eax
801057a0:	79 10                	jns    801057b2 <sys_link+0x132>
    iunlockput(dp);
801057a2:	83 ec 0c             	sub    $0xc,%esp
801057a5:	ff 75 f0             	push   -0x10(%ebp)
801057a8:	e8 6f c4 ff ff       	call   80101c1c <iunlockput>
801057ad:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057b0:	eb 29                	jmp    801057db <sys_link+0x15b>
  }
  iunlockput(dp);
801057b2:	83 ec 0c             	sub    $0xc,%esp
801057b5:	ff 75 f0             	push   -0x10(%ebp)
801057b8:	e8 5f c4 ff ff       	call   80101c1c <iunlockput>
801057bd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801057c0:	83 ec 0c             	sub    $0xc,%esp
801057c3:	ff 75 f4             	push   -0xc(%ebp)
801057c6:	e8 81 c3 ff ff       	call   80101b4c <iput>
801057cb:	83 c4 10             	add    $0x10,%esp

  end_op();
801057ce:	e8 da dd ff ff       	call   801035ad <end_op>

  return 0;
801057d3:	b8 00 00 00 00       	mov    $0x0,%eax
801057d8:	eb 48                	jmp    80105822 <sys_link+0x1a2>
    goto bad;
801057da:	90                   	nop

bad:
  ilock(ip);
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	ff 75 f4             	push   -0xc(%ebp)
801057e1:	e8 05 c2 ff ff       	call   801019eb <ilock>
801057e6:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801057e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ec:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057f0:	83 e8 01             	sub    $0x1,%eax
801057f3:	89 c2                	mov    %eax,%edx
801057f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057fc:	83 ec 0c             	sub    $0xc,%esp
801057ff:	ff 75 f4             	push   -0xc(%ebp)
80105802:	e8 07 c0 ff ff       	call   8010180e <iupdate>
80105807:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010580a:	83 ec 0c             	sub    $0xc,%esp
8010580d:	ff 75 f4             	push   -0xc(%ebp)
80105810:	e8 07 c4 ff ff       	call   80101c1c <iunlockput>
80105815:	83 c4 10             	add    $0x10,%esp
  end_op();
80105818:	e8 90 dd ff ff       	call   801035ad <end_op>
  return -1;
8010581d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105822:	c9                   	leave  
80105823:	c3                   	ret    

80105824 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105824:	55                   	push   %ebp
80105825:	89 e5                	mov    %esp,%ebp
80105827:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010582a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105831:	eb 40                	jmp    80105873 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105836:	6a 10                	push   $0x10
80105838:	50                   	push   %eax
80105839:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010583c:	50                   	push   %eax
8010583d:	ff 75 08             	push   0x8(%ebp)
80105840:	e8 92 c6 ff ff       	call   80101ed7 <readi>
80105845:	83 c4 10             	add    $0x10,%esp
80105848:	83 f8 10             	cmp    $0x10,%eax
8010584b:	74 0d                	je     8010585a <isdirempty+0x36>
      panic("isdirempty: readi");
8010584d:	83 ec 0c             	sub    $0xc,%esp
80105850:	68 3e aa 10 80       	push   $0x8010aa3e
80105855:	e8 4f ad ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010585a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010585e:	66 85 c0             	test   %ax,%ax
80105861:	74 07                	je     8010586a <isdirempty+0x46>
      return 0;
80105863:	b8 00 00 00 00       	mov    $0x0,%eax
80105868:	eb 1b                	jmp    80105885 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010586a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586d:	83 c0 10             	add    $0x10,%eax
80105870:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105873:	8b 45 08             	mov    0x8(%ebp),%eax
80105876:	8b 50 58             	mov    0x58(%eax),%edx
80105879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587c:	39 c2                	cmp    %eax,%edx
8010587e:	77 b3                	ja     80105833 <isdirempty+0xf>
  }
  return 1;
80105880:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105885:	c9                   	leave  
80105886:	c3                   	ret    

80105887 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105887:	55                   	push   %ebp
80105888:	89 e5                	mov    %esp,%ebp
8010588a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010588d:	83 ec 08             	sub    $0x8,%esp
80105890:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105893:	50                   	push   %eax
80105894:	6a 00                	push   $0x0
80105896:	e8 a2 fa ff ff       	call   8010533d <argstr>
8010589b:	83 c4 10             	add    $0x10,%esp
8010589e:	85 c0                	test   %eax,%eax
801058a0:	79 0a                	jns    801058ac <sys_unlink+0x25>
    return -1;
801058a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a7:	e9 bf 01 00 00       	jmp    80105a6b <sys_unlink+0x1e4>

  begin_op();
801058ac:	e8 70 dc ff ff       	call   80103521 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801058b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801058b4:	83 ec 08             	sub    $0x8,%esp
801058b7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801058ba:	52                   	push   %edx
801058bb:	50                   	push   %eax
801058bc:	e8 79 cc ff ff       	call   8010253a <nameiparent>
801058c1:	83 c4 10             	add    $0x10,%esp
801058c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058cb:	75 0f                	jne    801058dc <sys_unlink+0x55>
    end_op();
801058cd:	e8 db dc ff ff       	call   801035ad <end_op>
    return -1;
801058d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d7:	e9 8f 01 00 00       	jmp    80105a6b <sys_unlink+0x1e4>
  }

  ilock(dp);
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	ff 75 f4             	push   -0xc(%ebp)
801058e2:	e8 04 c1 ff ff       	call   801019eb <ilock>
801058e7:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801058ea:	83 ec 08             	sub    $0x8,%esp
801058ed:	68 50 aa 10 80       	push   $0x8010aa50
801058f2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801058f5:	50                   	push   %eax
801058f6:	e8 b7 c8 ff ff       	call   801021b2 <namecmp>
801058fb:	83 c4 10             	add    $0x10,%esp
801058fe:	85 c0                	test   %eax,%eax
80105900:	0f 84 49 01 00 00    	je     80105a4f <sys_unlink+0x1c8>
80105906:	83 ec 08             	sub    $0x8,%esp
80105909:	68 52 aa 10 80       	push   $0x8010aa52
8010590e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105911:	50                   	push   %eax
80105912:	e8 9b c8 ff ff       	call   801021b2 <namecmp>
80105917:	83 c4 10             	add    $0x10,%esp
8010591a:	85 c0                	test   %eax,%eax
8010591c:	0f 84 2d 01 00 00    	je     80105a4f <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105922:	83 ec 04             	sub    $0x4,%esp
80105925:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105928:	50                   	push   %eax
80105929:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010592c:	50                   	push   %eax
8010592d:	ff 75 f4             	push   -0xc(%ebp)
80105930:	e8 98 c8 ff ff       	call   801021cd <dirlookup>
80105935:	83 c4 10             	add    $0x10,%esp
80105938:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010593b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010593f:	0f 84 0d 01 00 00    	je     80105a52 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105945:	83 ec 0c             	sub    $0xc,%esp
80105948:	ff 75 f0             	push   -0x10(%ebp)
8010594b:	e8 9b c0 ff ff       	call   801019eb <ilock>
80105950:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105956:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010595a:	66 85 c0             	test   %ax,%ax
8010595d:	7f 0d                	jg     8010596c <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010595f:	83 ec 0c             	sub    $0xc,%esp
80105962:	68 55 aa 10 80       	push   $0x8010aa55
80105967:	e8 3d ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010596c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105973:	66 83 f8 01          	cmp    $0x1,%ax
80105977:	75 25                	jne    8010599e <sys_unlink+0x117>
80105979:	83 ec 0c             	sub    $0xc,%esp
8010597c:	ff 75 f0             	push   -0x10(%ebp)
8010597f:	e8 a0 fe ff ff       	call   80105824 <isdirempty>
80105984:	83 c4 10             	add    $0x10,%esp
80105987:	85 c0                	test   %eax,%eax
80105989:	75 13                	jne    8010599e <sys_unlink+0x117>
    iunlockput(ip);
8010598b:	83 ec 0c             	sub    $0xc,%esp
8010598e:	ff 75 f0             	push   -0x10(%ebp)
80105991:	e8 86 c2 ff ff       	call   80101c1c <iunlockput>
80105996:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105999:	e9 b5 00 00 00       	jmp    80105a53 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010599e:	83 ec 04             	sub    $0x4,%esp
801059a1:	6a 10                	push   $0x10
801059a3:	6a 00                	push   $0x0
801059a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059a8:	50                   	push   %eax
801059a9:	e8 fa f5 ff ff       	call   80104fa8 <memset>
801059ae:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801059b4:	6a 10                	push   $0x10
801059b6:	50                   	push   %eax
801059b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059ba:	50                   	push   %eax
801059bb:	ff 75 f4             	push   -0xc(%ebp)
801059be:	e8 69 c6 ff ff       	call   8010202c <writei>
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	83 f8 10             	cmp    $0x10,%eax
801059c9:	74 0d                	je     801059d8 <sys_unlink+0x151>
    panic("unlink: writei");
801059cb:	83 ec 0c             	sub    $0xc,%esp
801059ce:	68 67 aa 10 80       	push   $0x8010aa67
801059d3:	e8 d1 ab ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059db:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059df:	66 83 f8 01          	cmp    $0x1,%ax
801059e3:	75 21                	jne    80105a06 <sys_unlink+0x17f>
    dp->nlink--;
801059e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059ec:	83 e8 01             	sub    $0x1,%eax
801059ef:	89 c2                	mov    %eax,%edx
801059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059f8:	83 ec 0c             	sub    $0xc,%esp
801059fb:	ff 75 f4             	push   -0xc(%ebp)
801059fe:	e8 0b be ff ff       	call   8010180e <iupdate>
80105a03:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105a06:	83 ec 0c             	sub    $0xc,%esp
80105a09:	ff 75 f4             	push   -0xc(%ebp)
80105a0c:	e8 0b c2 ff ff       	call   80101c1c <iunlockput>
80105a11:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a1b:	83 e8 01             	sub    $0x1,%eax
80105a1e:	89 c2                	mov    %eax,%edx
80105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a23:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a27:	83 ec 0c             	sub    $0xc,%esp
80105a2a:	ff 75 f0             	push   -0x10(%ebp)
80105a2d:	e8 dc bd ff ff       	call   8010180e <iupdate>
80105a32:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a35:	83 ec 0c             	sub    $0xc,%esp
80105a38:	ff 75 f0             	push   -0x10(%ebp)
80105a3b:	e8 dc c1 ff ff       	call   80101c1c <iunlockput>
80105a40:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a43:	e8 65 db ff ff       	call   801035ad <end_op>

  return 0;
80105a48:	b8 00 00 00 00       	mov    $0x0,%eax
80105a4d:	eb 1c                	jmp    80105a6b <sys_unlink+0x1e4>
    goto bad;
80105a4f:	90                   	nop
80105a50:	eb 01                	jmp    80105a53 <sys_unlink+0x1cc>
    goto bad;
80105a52:	90                   	nop

bad:
  iunlockput(dp);
80105a53:	83 ec 0c             	sub    $0xc,%esp
80105a56:	ff 75 f4             	push   -0xc(%ebp)
80105a59:	e8 be c1 ff ff       	call   80101c1c <iunlockput>
80105a5e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a61:	e8 47 db ff ff       	call   801035ad <end_op>
  return -1;
80105a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a6b:	c9                   	leave  
80105a6c:	c3                   	ret    

80105a6d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105a6d:	55                   	push   %ebp
80105a6e:	89 e5                	mov    %esp,%ebp
80105a70:	83 ec 38             	sub    $0x38,%esp
80105a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105a76:	8b 55 10             	mov    0x10(%ebp),%edx
80105a79:	8b 45 14             	mov    0x14(%ebp),%eax
80105a7c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105a80:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105a84:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105a88:	83 ec 08             	sub    $0x8,%esp
80105a8b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a8e:	50                   	push   %eax
80105a8f:	ff 75 08             	push   0x8(%ebp)
80105a92:	e8 a3 ca ff ff       	call   8010253a <nameiparent>
80105a97:	83 c4 10             	add    $0x10,%esp
80105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aa1:	75 0a                	jne    80105aad <create+0x40>
    return 0;
80105aa3:	b8 00 00 00 00       	mov    $0x0,%eax
80105aa8:	e9 90 01 00 00       	jmp    80105c3d <create+0x1d0>
  ilock(dp);
80105aad:	83 ec 0c             	sub    $0xc,%esp
80105ab0:	ff 75 f4             	push   -0xc(%ebp)
80105ab3:	e8 33 bf ff ff       	call   801019eb <ilock>
80105ab8:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105abb:	83 ec 04             	sub    $0x4,%esp
80105abe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ac1:	50                   	push   %eax
80105ac2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ac5:	50                   	push   %eax
80105ac6:	ff 75 f4             	push   -0xc(%ebp)
80105ac9:	e8 ff c6 ff ff       	call   801021cd <dirlookup>
80105ace:	83 c4 10             	add    $0x10,%esp
80105ad1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ad4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ad8:	74 50                	je     80105b2a <create+0xbd>
    iunlockput(dp);
80105ada:	83 ec 0c             	sub    $0xc,%esp
80105add:	ff 75 f4             	push   -0xc(%ebp)
80105ae0:	e8 37 c1 ff ff       	call   80101c1c <iunlockput>
80105ae5:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105ae8:	83 ec 0c             	sub    $0xc,%esp
80105aeb:	ff 75 f0             	push   -0x10(%ebp)
80105aee:	e8 f8 be ff ff       	call   801019eb <ilock>
80105af3:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105af6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105afb:	75 15                	jne    80105b12 <create+0xa5>
80105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b00:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b04:	66 83 f8 02          	cmp    $0x2,%ax
80105b08:	75 08                	jne    80105b12 <create+0xa5>
      return ip;
80105b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0d:	e9 2b 01 00 00       	jmp    80105c3d <create+0x1d0>
    iunlockput(ip);
80105b12:	83 ec 0c             	sub    $0xc,%esp
80105b15:	ff 75 f0             	push   -0x10(%ebp)
80105b18:	e8 ff c0 ff ff       	call   80101c1c <iunlockput>
80105b1d:	83 c4 10             	add    $0x10,%esp
    return 0;
80105b20:	b8 00 00 00 00       	mov    $0x0,%eax
80105b25:	e9 13 01 00 00       	jmp    80105c3d <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b2a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b31:	8b 00                	mov    (%eax),%eax
80105b33:	83 ec 08             	sub    $0x8,%esp
80105b36:	52                   	push   %edx
80105b37:	50                   	push   %eax
80105b38:	e8 fa bb ff ff       	call   80101737 <ialloc>
80105b3d:	83 c4 10             	add    $0x10,%esp
80105b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b47:	75 0d                	jne    80105b56 <create+0xe9>
    panic("create: ialloc");
80105b49:	83 ec 0c             	sub    $0xc,%esp
80105b4c:	68 76 aa 10 80       	push   $0x8010aa76
80105b51:	e8 53 aa ff ff       	call   801005a9 <panic>

  ilock(ip);
80105b56:	83 ec 0c             	sub    $0xc,%esp
80105b59:	ff 75 f0             	push   -0x10(%ebp)
80105b5c:	e8 8a be ff ff       	call   801019eb <ilock>
80105b61:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b67:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105b6b:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b72:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105b76:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7d:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105b83:	83 ec 0c             	sub    $0xc,%esp
80105b86:	ff 75 f0             	push   -0x10(%ebp)
80105b89:	e8 80 bc ff ff       	call   8010180e <iupdate>
80105b8e:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105b91:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105b96:	75 6a                	jne    80105c02 <create+0x195>
    dp->nlink++;  // for ".."
80105b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b9f:	83 c0 01             	add    $0x1,%eax
80105ba2:	89 c2                	mov    %eax,%edx
80105ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba7:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105bab:	83 ec 0c             	sub    $0xc,%esp
80105bae:	ff 75 f4             	push   -0xc(%ebp)
80105bb1:	e8 58 bc ff ff       	call   8010180e <iupdate>
80105bb6:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	8b 40 04             	mov    0x4(%eax),%eax
80105bbf:	83 ec 04             	sub    $0x4,%esp
80105bc2:	50                   	push   %eax
80105bc3:	68 50 aa 10 80       	push   $0x8010aa50
80105bc8:	ff 75 f0             	push   -0x10(%ebp)
80105bcb:	e8 b7 c6 ff ff       	call   80102287 <dirlink>
80105bd0:	83 c4 10             	add    $0x10,%esp
80105bd3:	85 c0                	test   %eax,%eax
80105bd5:	78 1e                	js     80105bf5 <create+0x188>
80105bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bda:	8b 40 04             	mov    0x4(%eax),%eax
80105bdd:	83 ec 04             	sub    $0x4,%esp
80105be0:	50                   	push   %eax
80105be1:	68 52 aa 10 80       	push   $0x8010aa52
80105be6:	ff 75 f0             	push   -0x10(%ebp)
80105be9:	e8 99 c6 ff ff       	call   80102287 <dirlink>
80105bee:	83 c4 10             	add    $0x10,%esp
80105bf1:	85 c0                	test   %eax,%eax
80105bf3:	79 0d                	jns    80105c02 <create+0x195>
      panic("create dots");
80105bf5:	83 ec 0c             	sub    $0xc,%esp
80105bf8:	68 85 aa 10 80       	push   $0x8010aa85
80105bfd:	e8 a7 a9 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c05:	8b 40 04             	mov    0x4(%eax),%eax
80105c08:	83 ec 04             	sub    $0x4,%esp
80105c0b:	50                   	push   %eax
80105c0c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c0f:	50                   	push   %eax
80105c10:	ff 75 f4             	push   -0xc(%ebp)
80105c13:	e8 6f c6 ff ff       	call   80102287 <dirlink>
80105c18:	83 c4 10             	add    $0x10,%esp
80105c1b:	85 c0                	test   %eax,%eax
80105c1d:	79 0d                	jns    80105c2c <create+0x1bf>
    panic("create: dirlink");
80105c1f:	83 ec 0c             	sub    $0xc,%esp
80105c22:	68 91 aa 10 80       	push   $0x8010aa91
80105c27:	e8 7d a9 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105c2c:	83 ec 0c             	sub    $0xc,%esp
80105c2f:	ff 75 f4             	push   -0xc(%ebp)
80105c32:	e8 e5 bf ff ff       	call   80101c1c <iunlockput>
80105c37:	83 c4 10             	add    $0x10,%esp

  return ip;
80105c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c3d:	c9                   	leave  
80105c3e:	c3                   	ret    

80105c3f <sys_open>:

int
sys_open(void)
{
80105c3f:	55                   	push   %ebp
80105c40:	89 e5                	mov    %esp,%ebp
80105c42:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c45:	83 ec 08             	sub    $0x8,%esp
80105c48:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c4b:	50                   	push   %eax
80105c4c:	6a 00                	push   $0x0
80105c4e:	e8 ea f6 ff ff       	call   8010533d <argstr>
80105c53:	83 c4 10             	add    $0x10,%esp
80105c56:	85 c0                	test   %eax,%eax
80105c58:	78 15                	js     80105c6f <sys_open+0x30>
80105c5a:	83 ec 08             	sub    $0x8,%esp
80105c5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c60:	50                   	push   %eax
80105c61:	6a 01                	push   $0x1
80105c63:	e8 4f f6 ff ff       	call   801052b7 <argint>
80105c68:	83 c4 10             	add    $0x10,%esp
80105c6b:	85 c0                	test   %eax,%eax
80105c6d:	79 0a                	jns    80105c79 <sys_open+0x3a>
    return -1;
80105c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c74:	e9 61 01 00 00       	jmp    80105dda <sys_open+0x19b>

  begin_op();
80105c79:	e8 a3 d8 ff ff       	call   80103521 <begin_op>

  if(omode & O_CREATE){
80105c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c81:	25 00 02 00 00       	and    $0x200,%eax
80105c86:	85 c0                	test   %eax,%eax
80105c88:	74 2a                	je     80105cb4 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c8d:	6a 00                	push   $0x0
80105c8f:	6a 00                	push   $0x0
80105c91:	6a 02                	push   $0x2
80105c93:	50                   	push   %eax
80105c94:	e8 d4 fd ff ff       	call   80105a6d <create>
80105c99:	83 c4 10             	add    $0x10,%esp
80105c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105c9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca3:	75 75                	jne    80105d1a <sys_open+0xdb>
      end_op();
80105ca5:	e8 03 d9 ff ff       	call   801035ad <end_op>
      return -1;
80105caa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105caf:	e9 26 01 00 00       	jmp    80105dda <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cb7:	83 ec 0c             	sub    $0xc,%esp
80105cba:	50                   	push   %eax
80105cbb:	e8 5e c8 ff ff       	call   8010251e <namei>
80105cc0:	83 c4 10             	add    $0x10,%esp
80105cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cca:	75 0f                	jne    80105cdb <sys_open+0x9c>
      end_op();
80105ccc:	e8 dc d8 ff ff       	call   801035ad <end_op>
      return -1;
80105cd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd6:	e9 ff 00 00 00       	jmp    80105dda <sys_open+0x19b>
    }
    ilock(ip);
80105cdb:	83 ec 0c             	sub    $0xc,%esp
80105cde:	ff 75 f4             	push   -0xc(%ebp)
80105ce1:	e8 05 bd ff ff       	call   801019eb <ilock>
80105ce6:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cf0:	66 83 f8 01          	cmp    $0x1,%ax
80105cf4:	75 24                	jne    80105d1a <sys_open+0xdb>
80105cf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cf9:	85 c0                	test   %eax,%eax
80105cfb:	74 1d                	je     80105d1a <sys_open+0xdb>
      iunlockput(ip);
80105cfd:	83 ec 0c             	sub    $0xc,%esp
80105d00:	ff 75 f4             	push   -0xc(%ebp)
80105d03:	e8 14 bf ff ff       	call   80101c1c <iunlockput>
80105d08:	83 c4 10             	add    $0x10,%esp
      end_op();
80105d0b:	e8 9d d8 ff ff       	call   801035ad <end_op>
      return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	e9 c0 00 00 00       	jmp    80105dda <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d1a:	e8 bf b2 ff ff       	call   80100fde <filealloc>
80105d1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d26:	74 17                	je     80105d3f <sys_open+0x100>
80105d28:	83 ec 0c             	sub    $0xc,%esp
80105d2b:	ff 75 f0             	push   -0x10(%ebp)
80105d2e:	e8 33 f7 ff ff       	call   80105466 <fdalloc>
80105d33:	83 c4 10             	add    $0x10,%esp
80105d36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d3d:	79 2e                	jns    80105d6d <sys_open+0x12e>
    if(f)
80105d3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d43:	74 0e                	je     80105d53 <sys_open+0x114>
      fileclose(f);
80105d45:	83 ec 0c             	sub    $0xc,%esp
80105d48:	ff 75 f0             	push   -0x10(%ebp)
80105d4b:	e8 4c b3 ff ff       	call   8010109c <fileclose>
80105d50:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105d53:	83 ec 0c             	sub    $0xc,%esp
80105d56:	ff 75 f4             	push   -0xc(%ebp)
80105d59:	e8 be be ff ff       	call   80101c1c <iunlockput>
80105d5e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d61:	e8 47 d8 ff ff       	call   801035ad <end_op>
    return -1;
80105d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6b:	eb 6d                	jmp    80105dda <sys_open+0x19b>
  }
  iunlock(ip);
80105d6d:	83 ec 0c             	sub    $0xc,%esp
80105d70:	ff 75 f4             	push   -0xc(%ebp)
80105d73:	e8 86 bd ff ff       	call   80101afe <iunlock>
80105d78:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d7b:	e8 2d d8 ff ff       	call   801035ad <end_op>

  f->type = FD_INODE;
80105d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d83:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d8f:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d95:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d9f:	83 e0 01             	and    $0x1,%eax
80105da2:	85 c0                	test   %eax,%eax
80105da4:	0f 94 c0             	sete   %al
80105da7:	89 c2                	mov    %eax,%edx
80105da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dac:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db2:	83 e0 01             	and    $0x1,%eax
80105db5:	85 c0                	test   %eax,%eax
80105db7:	75 0a                	jne    80105dc3 <sys_open+0x184>
80105db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dbc:	83 e0 02             	and    $0x2,%eax
80105dbf:	85 c0                	test   %eax,%eax
80105dc1:	74 07                	je     80105dca <sys_open+0x18b>
80105dc3:	b8 01 00 00 00       	mov    $0x1,%eax
80105dc8:	eb 05                	jmp    80105dcf <sys_open+0x190>
80105dca:	b8 00 00 00 00       	mov    $0x0,%eax
80105dcf:	89 c2                	mov    %eax,%edx
80105dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd4:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105dda:	c9                   	leave  
80105ddb:	c3                   	ret    

80105ddc <sys_mkdir>:

int
sys_mkdir(void)
{
80105ddc:	55                   	push   %ebp
80105ddd:	89 e5                	mov    %esp,%ebp
80105ddf:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105de2:	e8 3a d7 ff ff       	call   80103521 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105de7:	83 ec 08             	sub    $0x8,%esp
80105dea:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ded:	50                   	push   %eax
80105dee:	6a 00                	push   $0x0
80105df0:	e8 48 f5 ff ff       	call   8010533d <argstr>
80105df5:	83 c4 10             	add    $0x10,%esp
80105df8:	85 c0                	test   %eax,%eax
80105dfa:	78 1b                	js     80105e17 <sys_mkdir+0x3b>
80105dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dff:	6a 00                	push   $0x0
80105e01:	6a 00                	push   $0x0
80105e03:	6a 01                	push   $0x1
80105e05:	50                   	push   %eax
80105e06:	e8 62 fc ff ff       	call   80105a6d <create>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e15:	75 0c                	jne    80105e23 <sys_mkdir+0x47>
    end_op();
80105e17:	e8 91 d7 ff ff       	call   801035ad <end_op>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	eb 18                	jmp    80105e3b <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105e23:	83 ec 0c             	sub    $0xc,%esp
80105e26:	ff 75 f4             	push   -0xc(%ebp)
80105e29:	e8 ee bd ff ff       	call   80101c1c <iunlockput>
80105e2e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e31:	e8 77 d7 ff ff       	call   801035ad <end_op>
  return 0;
80105e36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e3b:	c9                   	leave  
80105e3c:	c3                   	ret    

80105e3d <sys_mknod>:

int
sys_mknod(void)
{
80105e3d:	55                   	push   %ebp
80105e3e:	89 e5                	mov    %esp,%ebp
80105e40:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105e43:	e8 d9 d6 ff ff       	call   80103521 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105e48:	83 ec 08             	sub    $0x8,%esp
80105e4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e4e:	50                   	push   %eax
80105e4f:	6a 00                	push   $0x0
80105e51:	e8 e7 f4 ff ff       	call   8010533d <argstr>
80105e56:	83 c4 10             	add    $0x10,%esp
80105e59:	85 c0                	test   %eax,%eax
80105e5b:	78 4f                	js     80105eac <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105e5d:	83 ec 08             	sub    $0x8,%esp
80105e60:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e63:	50                   	push   %eax
80105e64:	6a 01                	push   $0x1
80105e66:	e8 4c f4 ff ff       	call   801052b7 <argint>
80105e6b:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105e6e:	85 c0                	test   %eax,%eax
80105e70:	78 3a                	js     80105eac <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105e72:	83 ec 08             	sub    $0x8,%esp
80105e75:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e78:	50                   	push   %eax
80105e79:	6a 02                	push   $0x2
80105e7b:	e8 37 f4 ff ff       	call   801052b7 <argint>
80105e80:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105e83:	85 c0                	test   %eax,%eax
80105e85:	78 25                	js     80105eac <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105e87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e8a:	0f bf c8             	movswl %ax,%ecx
80105e8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e90:	0f bf d0             	movswl %ax,%edx
80105e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e96:	51                   	push   %ecx
80105e97:	52                   	push   %edx
80105e98:	6a 03                	push   $0x3
80105e9a:	50                   	push   %eax
80105e9b:	e8 cd fb ff ff       	call   80105a6d <create>
80105ea0:	83 c4 10             	add    $0x10,%esp
80105ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105ea6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eaa:	75 0c                	jne    80105eb8 <sys_mknod+0x7b>
    end_op();
80105eac:	e8 fc d6 ff ff       	call   801035ad <end_op>
    return -1;
80105eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb6:	eb 18                	jmp    80105ed0 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105eb8:	83 ec 0c             	sub    $0xc,%esp
80105ebb:	ff 75 f4             	push   -0xc(%ebp)
80105ebe:	e8 59 bd ff ff       	call   80101c1c <iunlockput>
80105ec3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ec6:	e8 e2 d6 ff ff       	call   801035ad <end_op>
  return 0;
80105ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ed0:	c9                   	leave  
80105ed1:	c3                   	ret    

80105ed2 <sys_chdir>:

int
sys_chdir(void)
{
80105ed2:	55                   	push   %ebp
80105ed3:	89 e5                	mov    %esp,%ebp
80105ed5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105ed8:	e8 38 e0 ff ff       	call   80103f15 <myproc>
80105edd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105ee0:	e8 3c d6 ff ff       	call   80103521 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105ee5:	83 ec 08             	sub    $0x8,%esp
80105ee8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eeb:	50                   	push   %eax
80105eec:	6a 00                	push   $0x0
80105eee:	e8 4a f4 ff ff       	call   8010533d <argstr>
80105ef3:	83 c4 10             	add    $0x10,%esp
80105ef6:	85 c0                	test   %eax,%eax
80105ef8:	78 18                	js     80105f12 <sys_chdir+0x40>
80105efa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105efd:	83 ec 0c             	sub    $0xc,%esp
80105f00:	50                   	push   %eax
80105f01:	e8 18 c6 ff ff       	call   8010251e <namei>
80105f06:	83 c4 10             	add    $0x10,%esp
80105f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f10:	75 0c                	jne    80105f1e <sys_chdir+0x4c>
    end_op();
80105f12:	e8 96 d6 ff ff       	call   801035ad <end_op>
    return -1;
80105f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1c:	eb 68                	jmp    80105f86 <sys_chdir+0xb4>
  }
  ilock(ip);
80105f1e:	83 ec 0c             	sub    $0xc,%esp
80105f21:	ff 75 f0             	push   -0x10(%ebp)
80105f24:	e8 c2 ba ff ff       	call   801019eb <ilock>
80105f29:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f33:	66 83 f8 01          	cmp    $0x1,%ax
80105f37:	74 1a                	je     80105f53 <sys_chdir+0x81>
    iunlockput(ip);
80105f39:	83 ec 0c             	sub    $0xc,%esp
80105f3c:	ff 75 f0             	push   -0x10(%ebp)
80105f3f:	e8 d8 bc ff ff       	call   80101c1c <iunlockput>
80105f44:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f47:	e8 61 d6 ff ff       	call   801035ad <end_op>
    return -1;
80105f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f51:	eb 33                	jmp    80105f86 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105f53:	83 ec 0c             	sub    $0xc,%esp
80105f56:	ff 75 f0             	push   -0x10(%ebp)
80105f59:	e8 a0 bb ff ff       	call   80101afe <iunlock>
80105f5e:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f64:	8b 40 68             	mov    0x68(%eax),%eax
80105f67:	83 ec 0c             	sub    $0xc,%esp
80105f6a:	50                   	push   %eax
80105f6b:	e8 dc bb ff ff       	call   80101b4c <iput>
80105f70:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f73:	e8 35 d6 ff ff       	call   801035ad <end_op>
  curproc->cwd = ip;
80105f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f7e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f86:	c9                   	leave  
80105f87:	c3                   	ret    

80105f88 <sys_exec>:

int
sys_exec(void)
{
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105f91:	83 ec 08             	sub    $0x8,%esp
80105f94:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f97:	50                   	push   %eax
80105f98:	6a 00                	push   $0x0
80105f9a:	e8 9e f3 ff ff       	call   8010533d <argstr>
80105f9f:	83 c4 10             	add    $0x10,%esp
80105fa2:	85 c0                	test   %eax,%eax
80105fa4:	78 18                	js     80105fbe <sys_exec+0x36>
80105fa6:	83 ec 08             	sub    $0x8,%esp
80105fa9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105faf:	50                   	push   %eax
80105fb0:	6a 01                	push   $0x1
80105fb2:	e8 00 f3 ff ff       	call   801052b7 <argint>
80105fb7:	83 c4 10             	add    $0x10,%esp
80105fba:	85 c0                	test   %eax,%eax
80105fbc:	79 0a                	jns    80105fc8 <sys_exec+0x40>
    return -1;
80105fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc3:	e9 c6 00 00 00       	jmp    8010608e <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105fc8:	83 ec 04             	sub    $0x4,%esp
80105fcb:	68 80 00 00 00       	push   $0x80
80105fd0:	6a 00                	push   $0x0
80105fd2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105fd8:	50                   	push   %eax
80105fd9:	e8 ca ef ff ff       	call   80104fa8 <memset>
80105fde:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105fe1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105feb:	83 f8 1f             	cmp    $0x1f,%eax
80105fee:	76 0a                	jbe    80105ffa <sys_exec+0x72>
      return -1;
80105ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff5:	e9 94 00 00 00       	jmp    8010608e <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffd:	c1 e0 02             	shl    $0x2,%eax
80106000:	89 c2                	mov    %eax,%edx
80106002:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106008:	01 c2                	add    %eax,%edx
8010600a:	83 ec 08             	sub    $0x8,%esp
8010600d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106013:	50                   	push   %eax
80106014:	52                   	push   %edx
80106015:	e8 18 f2 ff ff       	call   80105232 <fetchint>
8010601a:	83 c4 10             	add    $0x10,%esp
8010601d:	85 c0                	test   %eax,%eax
8010601f:	79 07                	jns    80106028 <sys_exec+0xa0>
      return -1;
80106021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106026:	eb 66                	jmp    8010608e <sys_exec+0x106>
    if(uarg == 0){
80106028:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010602e:	85 c0                	test   %eax,%eax
80106030:	75 27                	jne    80106059 <sys_exec+0xd1>
      argv[i] = 0;
80106032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106035:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010603c:	00 00 00 00 
      break;
80106040:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106044:	83 ec 08             	sub    $0x8,%esp
80106047:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010604d:	52                   	push   %edx
8010604e:	50                   	push   %eax
8010604f:	e8 2c ab ff ff       	call   80100b80 <exec>
80106054:	83 c4 10             	add    $0x10,%esp
80106057:	eb 35                	jmp    8010608e <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106059:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010605f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106062:	c1 e0 02             	shl    $0x2,%eax
80106065:	01 c2                	add    %eax,%edx
80106067:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010606d:	83 ec 08             	sub    $0x8,%esp
80106070:	52                   	push   %edx
80106071:	50                   	push   %eax
80106072:	e8 ea f1 ff ff       	call   80105261 <fetchstr>
80106077:	83 c4 10             	add    $0x10,%esp
8010607a:	85 c0                	test   %eax,%eax
8010607c:	79 07                	jns    80106085 <sys_exec+0xfd>
      return -1;
8010607e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106083:	eb 09                	jmp    8010608e <sys_exec+0x106>
  for(i=0;; i++){
80106085:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106089:	e9 5a ff ff ff       	jmp    80105fe8 <sys_exec+0x60>
}
8010608e:	c9                   	leave  
8010608f:	c3                   	ret    

80106090 <sys_pipe>:

int
sys_pipe(void)
{
80106090:	55                   	push   %ebp
80106091:	89 e5                	mov    %esp,%ebp
80106093:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106096:	83 ec 04             	sub    $0x4,%esp
80106099:	6a 08                	push   $0x8
8010609b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010609e:	50                   	push   %eax
8010609f:	6a 00                	push   $0x0
801060a1:	e8 3e f2 ff ff       	call   801052e4 <argptr>
801060a6:	83 c4 10             	add    $0x10,%esp
801060a9:	85 c0                	test   %eax,%eax
801060ab:	79 0a                	jns    801060b7 <sys_pipe+0x27>
    return -1;
801060ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b2:	e9 ae 00 00 00       	jmp    80106165 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801060b7:	83 ec 08             	sub    $0x8,%esp
801060ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060bd:	50                   	push   %eax
801060be:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060c1:	50                   	push   %eax
801060c2:	e8 8b d9 ff ff       	call   80103a52 <pipealloc>
801060c7:	83 c4 10             	add    $0x10,%esp
801060ca:	85 c0                	test   %eax,%eax
801060cc:	79 0a                	jns    801060d8 <sys_pipe+0x48>
    return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d3:	e9 8d 00 00 00       	jmp    80106165 <sys_pipe+0xd5>
  fd0 = -1;
801060d8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801060df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060e2:	83 ec 0c             	sub    $0xc,%esp
801060e5:	50                   	push   %eax
801060e6:	e8 7b f3 ff ff       	call   80105466 <fdalloc>
801060eb:	83 c4 10             	add    $0x10,%esp
801060ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060f5:	78 18                	js     8010610f <sys_pipe+0x7f>
801060f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	50                   	push   %eax
801060fe:	e8 63 f3 ff ff       	call   80105466 <fdalloc>
80106103:	83 c4 10             	add    $0x10,%esp
80106106:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106109:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010610d:	79 3e                	jns    8010614d <sys_pipe+0xbd>
    if(fd0 >= 0)
8010610f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106113:	78 13                	js     80106128 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106115:	e8 fb dd ff ff       	call   80103f15 <myproc>
8010611a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010611d:	83 c2 08             	add    $0x8,%edx
80106120:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106127:	00 
    fileclose(rf);
80106128:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010612b:	83 ec 0c             	sub    $0xc,%esp
8010612e:	50                   	push   %eax
8010612f:	e8 68 af ff ff       	call   8010109c <fileclose>
80106134:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	50                   	push   %eax
8010613e:	e8 59 af ff ff       	call   8010109c <fileclose>
80106143:	83 c4 10             	add    $0x10,%esp
    return -1;
80106146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614b:	eb 18                	jmp    80106165 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010614d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106150:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106153:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106155:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106158:	8d 50 04             	lea    0x4(%eax),%edx
8010615b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615e:	89 02                	mov    %eax,(%edx)
  return 0;
80106160:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106165:	c9                   	leave  
80106166:	c3                   	ret    

80106167 <sys_fork>:

int printpt(int pid);  // 추가

int
sys_fork(void)
{
80106167:	55                   	push   %ebp
80106168:	89 e5                	mov    %esp,%ebp
8010616a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010616d:	e8 a2 e0 ff ff       	call   80104214 <fork>
}
80106172:	c9                   	leave  
80106173:	c3                   	ret    

80106174 <sys_exit>:

int
sys_exit(void)
{
80106174:	55                   	push   %ebp
80106175:	89 e5                	mov    %esp,%ebp
80106177:	83 ec 08             	sub    $0x8,%esp
  exit();
8010617a:	e8 0e e2 ff ff       	call   8010438d <exit>
  return 0;  // not reached
8010617f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106184:	c9                   	leave  
80106185:	c3                   	ret    

80106186 <sys_wait>:

int
sys_wait(void)
{
80106186:	55                   	push   %ebp
80106187:	89 e5                	mov    %esp,%ebp
80106189:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010618c:	e8 1c e3 ff ff       	call   801044ad <wait>
}
80106191:	c9                   	leave  
80106192:	c3                   	ret    

80106193 <sys_kill>:

int
sys_kill(void)
{
80106193:	55                   	push   %ebp
80106194:	89 e5                	mov    %esp,%ebp
80106196:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106199:	83 ec 08             	sub    $0x8,%esp
8010619c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010619f:	50                   	push   %eax
801061a0:	6a 00                	push   $0x0
801061a2:	e8 10 f1 ff ff       	call   801052b7 <argint>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	85 c0                	test   %eax,%eax
801061ac:	79 07                	jns    801061b5 <sys_kill+0x22>
    return -1;
801061ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b3:	eb 0f                	jmp    801061c4 <sys_kill+0x31>
  return kill(pid);
801061b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b8:	83 ec 0c             	sub    $0xc,%esp
801061bb:	50                   	push   %eax
801061bc:	e8 1b e7 ff ff       	call   801048dc <kill>
801061c1:	83 c4 10             	add    $0x10,%esp
}
801061c4:	c9                   	leave  
801061c5:	c3                   	ret    

801061c6 <sys_getpid>:

int
sys_getpid(void)
{
801061c6:	55                   	push   %ebp
801061c7:	89 e5                	mov    %esp,%ebp
801061c9:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801061cc:	e8 44 dd ff ff       	call   80103f15 <myproc>
801061d1:	8b 40 10             	mov    0x10(%eax),%eax
}
801061d4:	c9                   	leave  
801061d5:	c3                   	ret    

801061d6 <sys_printpt>:
 //추가
int
sys_printpt(void)
{
801061d6:	55                   	push   %ebp
801061d7:	89 e5                	mov    %esp,%ebp
801061d9:	83 ec 18             	sub    $0x18,%esp
  int pid =0;
801061dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (argint(0, &pid) < 0) //사용자에게 pid 넘겨받지 못하면 실패
801061e3:	83 ec 08             	sub    $0x8,%esp
801061e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061e9:	50                   	push   %eax
801061ea:	6a 00                	push   $0x0
801061ec:	e8 c6 f0 ff ff       	call   801052b7 <argint>
801061f1:	83 c4 10             	add    $0x10,%esp
801061f4:	85 c0                	test   %eax,%eax
801061f6:	79 07                	jns    801061ff <sys_printpt+0x29>
    return -1;
801061f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fd:	eb 0f                	jmp    8010620e <sys_printpt+0x38>
  
  return printpt(pid);
801061ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106202:	83 ec 0c             	sub    $0xc,%esp
80106205:	50                   	push   %eax
80106206:	e8 4f e8 ff ff       	call   80104a5a <printpt>
8010620b:	83 c4 10             	add    $0x10,%esp
}
8010620e:	c9                   	leave  
8010620f:	c3                   	ret    

80106210 <sys_sbrk>:


int
sys_sbrk(void)
{
80106210:	55                   	push   %ebp
80106211:	89 e5                	mov    %esp,%ebp
80106213:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106216:	83 ec 08             	sub    $0x8,%esp
80106219:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010621c:	50                   	push   %eax
8010621d:	6a 00                	push   $0x0
8010621f:	e8 93 f0 ff ff       	call   801052b7 <argint>
80106224:	83 c4 10             	add    $0x10,%esp
80106227:	85 c0                	test   %eax,%eax
80106229:	79 07                	jns    80106232 <sys_sbrk+0x22>
    return -1;
8010622b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106230:	eb 27                	jmp    80106259 <sys_sbrk+0x49>
  addr = myproc()->sz;
80106232:	e8 de dc ff ff       	call   80103f15 <myproc>
80106237:	8b 00                	mov    (%eax),%eax
80106239:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010623c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623f:	83 ec 0c             	sub    $0xc,%esp
80106242:	50                   	push   %eax
80106243:	e8 31 df ff ff       	call   80104179 <growproc>
80106248:	83 c4 10             	add    $0x10,%esp
8010624b:	85 c0                	test   %eax,%eax
8010624d:	79 07                	jns    80106256 <sys_sbrk+0x46>
    return -1;
8010624f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106254:	eb 03                	jmp    80106259 <sys_sbrk+0x49>
  return addr;
80106256:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106259:	c9                   	leave  
8010625a:	c3                   	ret    

8010625b <sys_sleep>:

int
sys_sleep(void)
{
8010625b:	55                   	push   %ebp
8010625c:	89 e5                	mov    %esp,%ebp
8010625e:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106261:	83 ec 08             	sub    $0x8,%esp
80106264:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106267:	50                   	push   %eax
80106268:	6a 00                	push   $0x0
8010626a:	e8 48 f0 ff ff       	call   801052b7 <argint>
8010626f:	83 c4 10             	add    $0x10,%esp
80106272:	85 c0                	test   %eax,%eax
80106274:	79 07                	jns    8010627d <sys_sleep+0x22>
    return -1;
80106276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627b:	eb 76                	jmp    801062f3 <sys_sleep+0x98>
  acquire(&tickslock);
8010627d:	83 ec 0c             	sub    $0xc,%esp
80106280:	68 80 99 11 80       	push   $0x80119980
80106285:	e8 a8 ea ff ff       	call   80104d32 <acquire>
8010628a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010628d:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106295:	eb 38                	jmp    801062cf <sys_sleep+0x74>
    if(myproc()->killed){
80106297:	e8 79 dc ff ff       	call   80103f15 <myproc>
8010629c:	8b 40 24             	mov    0x24(%eax),%eax
8010629f:	85 c0                	test   %eax,%eax
801062a1:	74 17                	je     801062ba <sys_sleep+0x5f>
      release(&tickslock);
801062a3:	83 ec 0c             	sub    $0xc,%esp
801062a6:	68 80 99 11 80       	push   $0x80119980
801062ab:	e8 f0 ea ff ff       	call   80104da0 <release>
801062b0:	83 c4 10             	add    $0x10,%esp
      return -1;
801062b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b8:	eb 39                	jmp    801062f3 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801062ba:	83 ec 08             	sub    $0x8,%esp
801062bd:	68 80 99 11 80       	push   $0x80119980
801062c2:	68 b4 99 11 80       	push   $0x801199b4
801062c7:	e8 f2 e4 ff ff       	call   801047be <sleep>
801062cc:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801062cf:	a1 b4 99 11 80       	mov    0x801199b4,%eax
801062d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801062d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062da:	39 d0                	cmp    %edx,%eax
801062dc:	72 b9                	jb     80106297 <sys_sleep+0x3c>
  }
  release(&tickslock);
801062de:	83 ec 0c             	sub    $0xc,%esp
801062e1:	68 80 99 11 80       	push   $0x80119980
801062e6:	e8 b5 ea ff ff       	call   80104da0 <release>
801062eb:	83 c4 10             	add    $0x10,%esp
  return 0;
801062ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062f3:	c9                   	leave  
801062f4:	c3                   	ret    

801062f5 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801062f5:	55                   	push   %ebp
801062f6:	89 e5                	mov    %esp,%ebp
801062f8:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801062fb:	83 ec 0c             	sub    $0xc,%esp
801062fe:	68 80 99 11 80       	push   $0x80119980
80106303:	e8 2a ea ff ff       	call   80104d32 <acquire>
80106308:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010630b:	a1 b4 99 11 80       	mov    0x801199b4,%eax
80106310:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106313:	83 ec 0c             	sub    $0xc,%esp
80106316:	68 80 99 11 80       	push   $0x80119980
8010631b:	e8 80 ea ff ff       	call   80104da0 <release>
80106320:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106323:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106326:	c9                   	leave  
80106327:	c3                   	ret    

80106328 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106328:	1e                   	push   %ds
  pushl %es
80106329:	06                   	push   %es
  pushl %fs
8010632a:	0f a0                	push   %fs
  pushl %gs
8010632c:	0f a8                	push   %gs
  pushal
8010632e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010632f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106333:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106335:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106337:	54                   	push   %esp
  call trap
80106338:	e8 e3 01 00 00       	call   80106520 <trap>
  addl $4, %esp
8010633d:	83 c4 04             	add    $0x4,%esp

80106340 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106340:	61                   	popa   
  popl %gs
80106341:	0f a9                	pop    %gs
  popl %fs
80106343:	0f a1                	pop    %fs
  popl %es
80106345:	07                   	pop    %es
  popl %ds
80106346:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106347:	83 c4 08             	add    $0x8,%esp
  iret
8010634a:	cf                   	iret   

8010634b <lidt>:
{
8010634b:	55                   	push   %ebp
8010634c:	89 e5                	mov    %esp,%ebp
8010634e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106351:	8b 45 0c             	mov    0xc(%ebp),%eax
80106354:	83 e8 01             	sub    $0x1,%eax
80106357:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010635b:	8b 45 08             	mov    0x8(%ebp),%eax
8010635e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106362:	8b 45 08             	mov    0x8(%ebp),%eax
80106365:	c1 e8 10             	shr    $0x10,%eax
80106368:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010636c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010636f:	0f 01 18             	lidtl  (%eax)
}
80106372:	90                   	nop
80106373:	c9                   	leave  
80106374:	c3                   	ret    

80106375 <rcr2>:

static inline uint
rcr2(void)
{
80106375:	55                   	push   %ebp
80106376:	89 e5                	mov    %esp,%ebp
80106378:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010637b:	0f 20 d0             	mov    %cr2,%eax
8010637e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106381:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106384:	c9                   	leave  
80106385:	c3                   	ret    

80106386 <lcr3>:

static inline void
lcr3(uint val)
{
80106386:	55                   	push   %ebp
80106387:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106389:	8b 45 08             	mov    0x8(%ebp),%eax
8010638c:	0f 22 d8             	mov    %eax,%cr3
}
8010638f:	90                   	nop
80106390:	5d                   	pop    %ebp
80106391:	c3                   	ret    

80106392 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106392:	55                   	push   %ebp
80106393:	89 e5                	mov    %esp,%ebp
80106395:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010639f:	e9 c3 00 00 00       	jmp    80106467 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801063a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a7:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
801063ae:	89 c2                	mov    %eax,%edx
801063b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b3:	66 89 14 c5 80 91 11 	mov    %dx,-0x7fee6e80(,%eax,8)
801063ba:	80 
801063bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063be:	66 c7 04 c5 82 91 11 	movw   $0x8,-0x7fee6e7e(,%eax,8)
801063c5:	80 08 00 
801063c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cb:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
801063d2:	80 
801063d3:	83 e2 e0             	and    $0xffffffe0,%edx
801063d6:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
801063dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e0:	0f b6 14 c5 84 91 11 	movzbl -0x7fee6e7c(,%eax,8),%edx
801063e7:	80 
801063e8:	83 e2 1f             	and    $0x1f,%edx
801063eb:	88 14 c5 84 91 11 80 	mov    %dl,-0x7fee6e7c(,%eax,8)
801063f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f5:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
801063fc:	80 
801063fd:	83 e2 f0             	and    $0xfffffff0,%edx
80106400:	83 ca 0e             	or     $0xe,%edx
80106403:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
8010640a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640d:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
80106414:	80 
80106415:	83 e2 ef             	and    $0xffffffef,%edx
80106418:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
8010641f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106422:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
80106429:	80 
8010642a:	83 e2 9f             	and    $0xffffff9f,%edx
8010642d:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
80106434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106437:	0f b6 14 c5 85 91 11 	movzbl -0x7fee6e7b(,%eax,8),%edx
8010643e:	80 
8010643f:	83 ca 80             	or     $0xffffff80,%edx
80106442:	88 14 c5 85 91 11 80 	mov    %dl,-0x7fee6e7b(,%eax,8)
80106449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644c:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106453:	c1 e8 10             	shr    $0x10,%eax
80106456:	89 c2                	mov    %eax,%edx
80106458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645b:	66 89 14 c5 86 91 11 	mov    %dx,-0x7fee6e7a(,%eax,8)
80106462:	80 
  for(i = 0; i < 256; i++)
80106463:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106467:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010646e:	0f 8e 30 ff ff ff    	jle    801063a4 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106474:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106479:	66 a3 80 93 11 80    	mov    %ax,0x80119380
8010647f:	66 c7 05 82 93 11 80 	movw   $0x8,0x80119382
80106486:	08 00 
80106488:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
8010648f:	83 e0 e0             	and    $0xffffffe0,%eax
80106492:	a2 84 93 11 80       	mov    %al,0x80119384
80106497:	0f b6 05 84 93 11 80 	movzbl 0x80119384,%eax
8010649e:	83 e0 1f             	and    $0x1f,%eax
801064a1:	a2 84 93 11 80       	mov    %al,0x80119384
801064a6:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
801064ad:	83 c8 0f             	or     $0xf,%eax
801064b0:	a2 85 93 11 80       	mov    %al,0x80119385
801064b5:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
801064bc:	83 e0 ef             	and    $0xffffffef,%eax
801064bf:	a2 85 93 11 80       	mov    %al,0x80119385
801064c4:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
801064cb:	83 c8 60             	or     $0x60,%eax
801064ce:	a2 85 93 11 80       	mov    %al,0x80119385
801064d3:	0f b6 05 85 93 11 80 	movzbl 0x80119385,%eax
801064da:	83 c8 80             	or     $0xffffff80,%eax
801064dd:	a2 85 93 11 80       	mov    %al,0x80119385
801064e2:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801064e7:	c1 e8 10             	shr    $0x10,%eax
801064ea:	66 a3 86 93 11 80    	mov    %ax,0x80119386

  initlock(&tickslock, "time");
801064f0:	83 ec 08             	sub    $0x8,%esp
801064f3:	68 a4 aa 10 80       	push   $0x8010aaa4
801064f8:	68 80 99 11 80       	push   $0x80119980
801064fd:	e8 0e e8 ff ff       	call   80104d10 <initlock>
80106502:	83 c4 10             	add    $0x10,%esp
}
80106505:	90                   	nop
80106506:	c9                   	leave  
80106507:	c3                   	ret    

80106508 <idtinit>:

void
idtinit(void)
{
80106508:	55                   	push   %ebp
80106509:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010650b:	68 00 08 00 00       	push   $0x800
80106510:	68 80 91 11 80       	push   $0x80119180
80106515:	e8 31 fe ff ff       	call   8010634b <lidt>
8010651a:	83 c4 08             	add    $0x8,%esp
}
8010651d:	90                   	nop
8010651e:	c9                   	leave  
8010651f:	c3                   	ret    

80106520 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	57                   	push   %edi
80106524:	56                   	push   %esi
80106525:	53                   	push   %ebx
80106526:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106529:	8b 45 08             	mov    0x8(%ebp),%eax
8010652c:	8b 40 30             	mov    0x30(%eax),%eax
8010652f:	83 f8 40             	cmp    $0x40,%eax
80106532:	75 3b                	jne    8010656f <trap+0x4f>
    if(myproc()->killed)
80106534:	e8 dc d9 ff ff       	call   80103f15 <myproc>
80106539:	8b 40 24             	mov    0x24(%eax),%eax
8010653c:	85 c0                	test   %eax,%eax
8010653e:	74 05                	je     80106545 <trap+0x25>
      exit();
80106540:	e8 48 de ff ff       	call   8010438d <exit>
    myproc()->tf = tf;
80106545:	e8 cb d9 ff ff       	call   80103f15 <myproc>
8010654a:	8b 55 08             	mov    0x8(%ebp),%edx
8010654d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106550:	e8 1f ee ff ff       	call   80105374 <syscall>
    if(myproc()->killed)
80106555:	e8 bb d9 ff ff       	call   80103f15 <myproc>
8010655a:	8b 40 24             	mov    0x24(%eax),%eax
8010655d:	85 c0                	test   %eax,%eax
8010655f:	0f 84 f3 02 00 00    	je     80106858 <trap+0x338>
      exit();
80106565:	e8 23 de ff ff       	call   8010438d <exit>
    return;
8010656a:	e9 e9 02 00 00       	jmp    80106858 <trap+0x338>
  }

  switch(tf->trapno){
8010656f:	8b 45 08             	mov    0x8(%ebp),%eax
80106572:	8b 40 30             	mov    0x30(%eax),%eax
80106575:	83 e8 0e             	sub    $0xe,%eax
80106578:	83 f8 31             	cmp    $0x31,%eax
8010657b:	0f 87 9f 01 00 00    	ja     80106720 <trap+0x200>
80106581:	8b 04 85 64 ab 10 80 	mov    -0x7fef549c(,%eax,4),%eax
80106588:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010658a:	e8 f3 d8 ff ff       	call   80103e82 <cpuid>
8010658f:	85 c0                	test   %eax,%eax
80106591:	75 3d                	jne    801065d0 <trap+0xb0>
      acquire(&tickslock);
80106593:	83 ec 0c             	sub    $0xc,%esp
80106596:	68 80 99 11 80       	push   $0x80119980
8010659b:	e8 92 e7 ff ff       	call   80104d32 <acquire>
801065a0:	83 c4 10             	add    $0x10,%esp
      ticks++;
801065a3:	a1 b4 99 11 80       	mov    0x801199b4,%eax
801065a8:	83 c0 01             	add    $0x1,%eax
801065ab:	a3 b4 99 11 80       	mov    %eax,0x801199b4
      wakeup(&ticks);
801065b0:	83 ec 0c             	sub    $0xc,%esp
801065b3:	68 b4 99 11 80       	push   $0x801199b4
801065b8:	e8 e8 e2 ff ff       	call   801048a5 <wakeup>
801065bd:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801065c0:	83 ec 0c             	sub    $0xc,%esp
801065c3:	68 80 99 11 80       	push   $0x80119980
801065c8:	e8 d3 e7 ff ff       	call   80104da0 <release>
801065cd:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801065d0:	e8 2c ca ff ff       	call   80103001 <lapiceoi>
    break;
801065d5:	e9 fe 01 00 00       	jmp    801067d8 <trap+0x2b8>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801065da:	e8 78 c2 ff ff       	call   80102857 <ideintr>
    lapiceoi();
801065df:	e8 1d ca ff ff       	call   80103001 <lapiceoi>
    break;
801065e4:	e9 ef 01 00 00       	jmp    801067d8 <trap+0x2b8>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801065e9:	e8 58 c8 ff ff       	call   80102e46 <kbdintr>
    lapiceoi();
801065ee:	e8 0e ca ff ff       	call   80103001 <lapiceoi>
    break;
801065f3:	e9 e0 01 00 00       	jmp    801067d8 <trap+0x2b8>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801065f8:	e8 31 04 00 00       	call   80106a2e <uartintr>
    lapiceoi();
801065fd:	e8 ff c9 ff ff       	call   80103001 <lapiceoi>
    break;
80106602:	e9 d1 01 00 00       	jmp    801067d8 <trap+0x2b8>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106607:	e8 44 2c 00 00       	call   80109250 <i8254_intr>
    lapiceoi();
8010660c:	e8 f0 c9 ff ff       	call   80103001 <lapiceoi>
    break;
80106611:	e9 c2 01 00 00       	jmp    801067d8 <trap+0x2b8>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106616:	8b 45 08             	mov    0x8(%ebp),%eax
80106619:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010661c:	8b 45 08             	mov    0x8(%ebp),%eax
8010661f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106623:	0f b7 d8             	movzwl %ax,%ebx
80106626:	e8 57 d8 ff ff       	call   80103e82 <cpuid>
8010662b:	56                   	push   %esi
8010662c:	53                   	push   %ebx
8010662d:	50                   	push   %eax
8010662e:	68 ac aa 10 80       	push   $0x8010aaac
80106633:	e8 bc 9d ff ff       	call   801003f4 <cprintf>
80106638:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010663b:	e8 c1 c9 ff ff       	call   80103001 <lapiceoi>
    break;
80106640:	e9 93 01 00 00       	jmp    801067d8 <trap+0x2b8>
  
  case T_PGFLT: {
    uint fault_addr = PGROUNDDOWN(rcr2());
80106645:	e8 2b fd ff ff       	call   80106375 <rcr2>
8010664a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010664f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct proc *p = myproc();
80106652:	e8 be d8 ff ff       	call   80103f15 <myproc>
80106657:	89 45 e0             	mov    %eax,-0x20(%ebp)

    // 페이지가 이미 매핑되어 있으면 무시
    pte_t *pte = walkpgdir(p->pgdir, (void *)fault_addr, 0);
8010665a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010665d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106660:	8b 40 04             	mov    0x4(%eax),%eax
80106663:	83 ec 04             	sub    $0x4,%esp
80106666:	6a 00                	push   $0x0
80106668:	52                   	push   %edx
80106669:	50                   	push   %eax
8010666a:	e8 ed 11 00 00       	call   8010785c <walkpgdir>
8010666f:	83 c4 10             	add    $0x10,%esp
80106672:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pte && (*pte & PTE_P))
80106675:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106679:	74 10                	je     8010668b <trap+0x16b>
8010667b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010667e:	8b 00                	mov    (%eax),%eax
80106680:	83 e0 01             	and    $0x1,%eax
80106683:	85 c0                	test   %eax,%eax
80106685:	0f 85 4c 01 00 00    	jne    801067d7 <trap+0x2b7>
      break;

    // 새 물리 메모리 할당
    char *new_mem = kalloc();
8010668b:	e8 f5 c5 ff ff       	call   80102c85 <kalloc>
80106690:	89 45 d8             	mov    %eax,-0x28(%ebp)
    if (!new_mem) {
80106693:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80106697:	75 18                	jne    801066b1 <trap+0x191>
      cprintf("page alloc fail at %x\n", fault_addr);
80106699:	83 ec 08             	sub    $0x8,%esp
8010669c:	ff 75 e4             	push   -0x1c(%ebp)
8010669f:	68 d0 aa 10 80       	push   $0x8010aad0
801066a4:	e8 4b 9d ff ff       	call   801003f4 <cprintf>
801066a9:	83 c4 10             	add    $0x10,%esp
      break;
801066ac:	e9 27 01 00 00       	jmp    801067d8 <trap+0x2b8>
    }

    memset(new_mem, 0, PGSIZE);
801066b1:	83 ec 04             	sub    $0x4,%esp
801066b4:	68 00 10 00 00       	push   $0x1000
801066b9:	6a 00                	push   $0x0
801066bb:	ff 75 d8             	push   -0x28(%ebp)
801066be:	e8 e5 e8 ff ff       	call   80104fa8 <memset>
801066c3:	83 c4 10             	add    $0x10,%esp

    // 페이지 매핑
    if (mappages(p->pgdir, (void *)fault_addr, PGSIZE, V2P(new_mem), PTE_W | PTE_U) < 0) {
801066c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801066c9:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801066cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801066d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066d5:	8b 40 04             	mov    0x4(%eax),%eax
801066d8:	83 ec 0c             	sub    $0xc,%esp
801066db:	6a 06                	push   $0x6
801066dd:	51                   	push   %ecx
801066de:	68 00 10 00 00       	push   $0x1000
801066e3:	52                   	push   %edx
801066e4:	50                   	push   %eax
801066e5:	e8 08 12 00 00       	call   801078f2 <mappages>
801066ea:	83 c4 20             	add    $0x20,%esp
801066ed:	85 c0                	test   %eax,%eax
801066ef:	79 13                	jns    80106704 <trap+0x1e4>
      kfree(new_mem);  // 실패했으면 할당 회수
801066f1:	83 ec 0c             	sub    $0xc,%esp
801066f4:	ff 75 d8             	push   -0x28(%ebp)
801066f7:	e8 ef c4 ff ff       	call   80102beb <kfree>
801066fc:	83 c4 10             	add    $0x10,%esp
      break;
801066ff:	e9 d4 00 00 00       	jmp    801067d8 <trap+0x2b8>
    }

    // TLB 플러싱
    lcr3(V2P(p->pgdir));
80106704:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106707:	8b 40 04             	mov    0x4(%eax),%eax
8010670a:	05 00 00 00 80       	add    $0x80000000,%eax
8010670f:	83 ec 0c             	sub    $0xc,%esp
80106712:	50                   	push   %eax
80106713:	e8 6e fc ff ff       	call   80106386 <lcr3>
80106718:	83 c4 10             	add    $0x10,%esp
    break;
8010671b:	e9 b8 00 00 00       	jmp    801067d8 <trap+0x2b8>



  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106720:	e8 f0 d7 ff ff       	call   80103f15 <myproc>
80106725:	85 c0                	test   %eax,%eax
80106727:	74 11                	je     8010673a <trap+0x21a>
80106729:	8b 45 08             	mov    0x8(%ebp),%eax
8010672c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106730:	0f b7 c0             	movzwl %ax,%eax
80106733:	83 e0 03             	and    $0x3,%eax
80106736:	85 c0                	test   %eax,%eax
80106738:	75 39                	jne    80106773 <trap+0x253>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010673a:	e8 36 fc ff ff       	call   80106375 <rcr2>
8010673f:	89 c3                	mov    %eax,%ebx
80106741:	8b 45 08             	mov    0x8(%ebp),%eax
80106744:	8b 70 38             	mov    0x38(%eax),%esi
80106747:	e8 36 d7 ff ff       	call   80103e82 <cpuid>
8010674c:	8b 55 08             	mov    0x8(%ebp),%edx
8010674f:	8b 52 30             	mov    0x30(%edx),%edx
80106752:	83 ec 0c             	sub    $0xc,%esp
80106755:	53                   	push   %ebx
80106756:	56                   	push   %esi
80106757:	50                   	push   %eax
80106758:	52                   	push   %edx
80106759:	68 e8 aa 10 80       	push   $0x8010aae8
8010675e:	e8 91 9c ff ff       	call   801003f4 <cprintf>
80106763:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106766:	83 ec 0c             	sub    $0xc,%esp
80106769:	68 1a ab 10 80       	push   $0x8010ab1a
8010676e:	e8 36 9e ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106773:	e8 fd fb ff ff       	call   80106375 <rcr2>
80106778:	89 c6                	mov    %eax,%esi
8010677a:	8b 45 08             	mov    0x8(%ebp),%eax
8010677d:	8b 40 38             	mov    0x38(%eax),%eax
80106780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106783:	e8 fa d6 ff ff       	call   80103e82 <cpuid>
80106788:	89 c3                	mov    %eax,%ebx
8010678a:	8b 45 08             	mov    0x8(%ebp),%eax
8010678d:	8b 48 34             	mov    0x34(%eax),%ecx
80106790:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106793:	8b 45 08             	mov    0x8(%ebp),%eax
80106796:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106799:	e8 77 d7 ff ff       	call   80103f15 <myproc>
8010679e:	8d 50 6c             	lea    0x6c(%eax),%edx
801067a1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801067a4:	e8 6c d7 ff ff       	call   80103f15 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067a9:	8b 40 10             	mov    0x10(%eax),%eax
801067ac:	56                   	push   %esi
801067ad:	ff 75 d4             	push   -0x2c(%ebp)
801067b0:	53                   	push   %ebx
801067b1:	ff 75 d0             	push   -0x30(%ebp)
801067b4:	57                   	push   %edi
801067b5:	ff 75 cc             	push   -0x34(%ebp)
801067b8:	50                   	push   %eax
801067b9:	68 20 ab 10 80       	push   $0x8010ab20
801067be:	e8 31 9c ff ff       	call   801003f4 <cprintf>
801067c3:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801067c6:	e8 4a d7 ff ff       	call   80103f15 <myproc>
801067cb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801067d2:	eb 04                	jmp    801067d8 <trap+0x2b8>
    break;
801067d4:	90                   	nop
801067d5:	eb 01                	jmp    801067d8 <trap+0x2b8>
      break;
801067d7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801067d8:	e8 38 d7 ff ff       	call   80103f15 <myproc>
801067dd:	85 c0                	test   %eax,%eax
801067df:	74 23                	je     80106804 <trap+0x2e4>
801067e1:	e8 2f d7 ff ff       	call   80103f15 <myproc>
801067e6:	8b 40 24             	mov    0x24(%eax),%eax
801067e9:	85 c0                	test   %eax,%eax
801067eb:	74 17                	je     80106804 <trap+0x2e4>
801067ed:	8b 45 08             	mov    0x8(%ebp),%eax
801067f0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067f4:	0f b7 c0             	movzwl %ax,%eax
801067f7:	83 e0 03             	and    $0x3,%eax
801067fa:	83 f8 03             	cmp    $0x3,%eax
801067fd:	75 05                	jne    80106804 <trap+0x2e4>
    exit();
801067ff:	e8 89 db ff ff       	call   8010438d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106804:	e8 0c d7 ff ff       	call   80103f15 <myproc>
80106809:	85 c0                	test   %eax,%eax
8010680b:	74 1d                	je     8010682a <trap+0x30a>
8010680d:	e8 03 d7 ff ff       	call   80103f15 <myproc>
80106812:	8b 40 0c             	mov    0xc(%eax),%eax
80106815:	83 f8 04             	cmp    $0x4,%eax
80106818:	75 10                	jne    8010682a <trap+0x30a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010681a:	8b 45 08             	mov    0x8(%ebp),%eax
8010681d:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106820:	83 f8 20             	cmp    $0x20,%eax
80106823:	75 05                	jne    8010682a <trap+0x30a>
    yield();
80106825:	e8 14 df ff ff       	call   8010473e <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010682a:	e8 e6 d6 ff ff       	call   80103f15 <myproc>
8010682f:	85 c0                	test   %eax,%eax
80106831:	74 26                	je     80106859 <trap+0x339>
80106833:	e8 dd d6 ff ff       	call   80103f15 <myproc>
80106838:	8b 40 24             	mov    0x24(%eax),%eax
8010683b:	85 c0                	test   %eax,%eax
8010683d:	74 1a                	je     80106859 <trap+0x339>
8010683f:	8b 45 08             	mov    0x8(%ebp),%eax
80106842:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106846:	0f b7 c0             	movzwl %ax,%eax
80106849:	83 e0 03             	and    $0x3,%eax
8010684c:	83 f8 03             	cmp    $0x3,%eax
8010684f:	75 08                	jne    80106859 <trap+0x339>
    exit();
80106851:	e8 37 db ff ff       	call   8010438d <exit>
80106856:	eb 01                	jmp    80106859 <trap+0x339>
    return;
80106858:	90                   	nop
}
80106859:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010685c:	5b                   	pop    %ebx
8010685d:	5e                   	pop    %esi
8010685e:	5f                   	pop    %edi
8010685f:	5d                   	pop    %ebp
80106860:	c3                   	ret    

80106861 <inb>:
{
80106861:	55                   	push   %ebp
80106862:	89 e5                	mov    %esp,%ebp
80106864:	83 ec 14             	sub    $0x14,%esp
80106867:	8b 45 08             	mov    0x8(%ebp),%eax
8010686a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010686e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106872:	89 c2                	mov    %eax,%edx
80106874:	ec                   	in     (%dx),%al
80106875:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106878:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010687c:	c9                   	leave  
8010687d:	c3                   	ret    

8010687e <outb>:
{
8010687e:	55                   	push   %ebp
8010687f:	89 e5                	mov    %esp,%ebp
80106881:	83 ec 08             	sub    $0x8,%esp
80106884:	8b 45 08             	mov    0x8(%ebp),%eax
80106887:	8b 55 0c             	mov    0xc(%ebp),%edx
8010688a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010688e:	89 d0                	mov    %edx,%eax
80106890:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106893:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106897:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010689b:	ee                   	out    %al,(%dx)
}
8010689c:	90                   	nop
8010689d:	c9                   	leave  
8010689e:	c3                   	ret    

8010689f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010689f:	55                   	push   %ebp
801068a0:	89 e5                	mov    %esp,%ebp
801068a2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068a5:	6a 00                	push   $0x0
801068a7:	68 fa 03 00 00       	push   $0x3fa
801068ac:	e8 cd ff ff ff       	call   8010687e <outb>
801068b1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801068b4:	68 80 00 00 00       	push   $0x80
801068b9:	68 fb 03 00 00       	push   $0x3fb
801068be:	e8 bb ff ff ff       	call   8010687e <outb>
801068c3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801068c6:	6a 0c                	push   $0xc
801068c8:	68 f8 03 00 00       	push   $0x3f8
801068cd:	e8 ac ff ff ff       	call   8010687e <outb>
801068d2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801068d5:	6a 00                	push   $0x0
801068d7:	68 f9 03 00 00       	push   $0x3f9
801068dc:	e8 9d ff ff ff       	call   8010687e <outb>
801068e1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801068e4:	6a 03                	push   $0x3
801068e6:	68 fb 03 00 00       	push   $0x3fb
801068eb:	e8 8e ff ff ff       	call   8010687e <outb>
801068f0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801068f3:	6a 00                	push   $0x0
801068f5:	68 fc 03 00 00       	push   $0x3fc
801068fa:	e8 7f ff ff ff       	call   8010687e <outb>
801068ff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106902:	6a 01                	push   $0x1
80106904:	68 f9 03 00 00       	push   $0x3f9
80106909:	e8 70 ff ff ff       	call   8010687e <outb>
8010690e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106911:	68 fd 03 00 00       	push   $0x3fd
80106916:	e8 46 ff ff ff       	call   80106861 <inb>
8010691b:	83 c4 04             	add    $0x4,%esp
8010691e:	3c ff                	cmp    $0xff,%al
80106920:	74 61                	je     80106983 <uartinit+0xe4>
    return;
  uart = 1;
80106922:	c7 05 b8 99 11 80 01 	movl   $0x1,0x801199b8
80106929:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010692c:	68 fa 03 00 00       	push   $0x3fa
80106931:	e8 2b ff ff ff       	call   80106861 <inb>
80106936:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106939:	68 f8 03 00 00       	push   $0x3f8
8010693e:	e8 1e ff ff ff       	call   80106861 <inb>
80106943:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106946:	83 ec 08             	sub    $0x8,%esp
80106949:	6a 00                	push   $0x0
8010694b:	6a 04                	push   $0x4
8010694d:	e8 c1 c1 ff ff       	call   80102b13 <ioapicenable>
80106952:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106955:	c7 45 f4 2c ac 10 80 	movl   $0x8010ac2c,-0xc(%ebp)
8010695c:	eb 19                	jmp    80106977 <uartinit+0xd8>
    uartputc(*p);
8010695e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106961:	0f b6 00             	movzbl (%eax),%eax
80106964:	0f be c0             	movsbl %al,%eax
80106967:	83 ec 0c             	sub    $0xc,%esp
8010696a:	50                   	push   %eax
8010696b:	e8 16 00 00 00       	call   80106986 <uartputc>
80106970:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106973:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697a:	0f b6 00             	movzbl (%eax),%eax
8010697d:	84 c0                	test   %al,%al
8010697f:	75 dd                	jne    8010695e <uartinit+0xbf>
80106981:	eb 01                	jmp    80106984 <uartinit+0xe5>
    return;
80106983:	90                   	nop
}
80106984:	c9                   	leave  
80106985:	c3                   	ret    

80106986 <uartputc>:

void
uartputc(int c)
{
80106986:	55                   	push   %ebp
80106987:	89 e5                	mov    %esp,%ebp
80106989:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010698c:	a1 b8 99 11 80       	mov    0x801199b8,%eax
80106991:	85 c0                	test   %eax,%eax
80106993:	74 53                	je     801069e8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106995:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010699c:	eb 11                	jmp    801069af <uartputc+0x29>
    microdelay(10);
8010699e:	83 ec 0c             	sub    $0xc,%esp
801069a1:	6a 0a                	push   $0xa
801069a3:	e8 74 c6 ff ff       	call   8010301c <microdelay>
801069a8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069af:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801069b3:	7f 1a                	jg     801069cf <uartputc+0x49>
801069b5:	83 ec 0c             	sub    $0xc,%esp
801069b8:	68 fd 03 00 00       	push   $0x3fd
801069bd:	e8 9f fe ff ff       	call   80106861 <inb>
801069c2:	83 c4 10             	add    $0x10,%esp
801069c5:	0f b6 c0             	movzbl %al,%eax
801069c8:	83 e0 20             	and    $0x20,%eax
801069cb:	85 c0                	test   %eax,%eax
801069cd:	74 cf                	je     8010699e <uartputc+0x18>
  outb(COM1+0, c);
801069cf:	8b 45 08             	mov    0x8(%ebp),%eax
801069d2:	0f b6 c0             	movzbl %al,%eax
801069d5:	83 ec 08             	sub    $0x8,%esp
801069d8:	50                   	push   %eax
801069d9:	68 f8 03 00 00       	push   $0x3f8
801069de:	e8 9b fe ff ff       	call   8010687e <outb>
801069e3:	83 c4 10             	add    $0x10,%esp
801069e6:	eb 01                	jmp    801069e9 <uartputc+0x63>
    return;
801069e8:	90                   	nop
}
801069e9:	c9                   	leave  
801069ea:	c3                   	ret    

801069eb <uartgetc>:

static int
uartgetc(void)
{
801069eb:	55                   	push   %ebp
801069ec:	89 e5                	mov    %esp,%ebp
  if(!uart)
801069ee:	a1 b8 99 11 80       	mov    0x801199b8,%eax
801069f3:	85 c0                	test   %eax,%eax
801069f5:	75 07                	jne    801069fe <uartgetc+0x13>
    return -1;
801069f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069fc:	eb 2e                	jmp    80106a2c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801069fe:	68 fd 03 00 00       	push   $0x3fd
80106a03:	e8 59 fe ff ff       	call   80106861 <inb>
80106a08:	83 c4 04             	add    $0x4,%esp
80106a0b:	0f b6 c0             	movzbl %al,%eax
80106a0e:	83 e0 01             	and    $0x1,%eax
80106a11:	85 c0                	test   %eax,%eax
80106a13:	75 07                	jne    80106a1c <uartgetc+0x31>
    return -1;
80106a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a1a:	eb 10                	jmp    80106a2c <uartgetc+0x41>
  return inb(COM1+0);
80106a1c:	68 f8 03 00 00       	push   $0x3f8
80106a21:	e8 3b fe ff ff       	call   80106861 <inb>
80106a26:	83 c4 04             	add    $0x4,%esp
80106a29:	0f b6 c0             	movzbl %al,%eax
}
80106a2c:	c9                   	leave  
80106a2d:	c3                   	ret    

80106a2e <uartintr>:

void
uartintr(void)
{
80106a2e:	55                   	push   %ebp
80106a2f:	89 e5                	mov    %esp,%ebp
80106a31:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106a34:	83 ec 0c             	sub    $0xc,%esp
80106a37:	68 eb 69 10 80       	push   $0x801069eb
80106a3c:	e8 95 9d ff ff       	call   801007d6 <consoleintr>
80106a41:	83 c4 10             	add    $0x10,%esp
}
80106a44:	90                   	nop
80106a45:	c9                   	leave  
80106a46:	c3                   	ret    

80106a47 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $0
80106a49:	6a 00                	push   $0x0
  jmp alltraps
80106a4b:	e9 d8 f8 ff ff       	jmp    80106328 <alltraps>

80106a50 <vector1>:
.globl vector1
vector1:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $1
80106a52:	6a 01                	push   $0x1
  jmp alltraps
80106a54:	e9 cf f8 ff ff       	jmp    80106328 <alltraps>

80106a59 <vector2>:
.globl vector2
vector2:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $2
80106a5b:	6a 02                	push   $0x2
  jmp alltraps
80106a5d:	e9 c6 f8 ff ff       	jmp    80106328 <alltraps>

80106a62 <vector3>:
.globl vector3
vector3:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $3
80106a64:	6a 03                	push   $0x3
  jmp alltraps
80106a66:	e9 bd f8 ff ff       	jmp    80106328 <alltraps>

80106a6b <vector4>:
.globl vector4
vector4:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $4
80106a6d:	6a 04                	push   $0x4
  jmp alltraps
80106a6f:	e9 b4 f8 ff ff       	jmp    80106328 <alltraps>

80106a74 <vector5>:
.globl vector5
vector5:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $5
80106a76:	6a 05                	push   $0x5
  jmp alltraps
80106a78:	e9 ab f8 ff ff       	jmp    80106328 <alltraps>

80106a7d <vector6>:
.globl vector6
vector6:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $6
80106a7f:	6a 06                	push   $0x6
  jmp alltraps
80106a81:	e9 a2 f8 ff ff       	jmp    80106328 <alltraps>

80106a86 <vector7>:
.globl vector7
vector7:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $7
80106a88:	6a 07                	push   $0x7
  jmp alltraps
80106a8a:	e9 99 f8 ff ff       	jmp    80106328 <alltraps>

80106a8f <vector8>:
.globl vector8
vector8:
  pushl $8
80106a8f:	6a 08                	push   $0x8
  jmp alltraps
80106a91:	e9 92 f8 ff ff       	jmp    80106328 <alltraps>

80106a96 <vector9>:
.globl vector9
vector9:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $9
80106a98:	6a 09                	push   $0x9
  jmp alltraps
80106a9a:	e9 89 f8 ff ff       	jmp    80106328 <alltraps>

80106a9f <vector10>:
.globl vector10
vector10:
  pushl $10
80106a9f:	6a 0a                	push   $0xa
  jmp alltraps
80106aa1:	e9 82 f8 ff ff       	jmp    80106328 <alltraps>

80106aa6 <vector11>:
.globl vector11
vector11:
  pushl $11
80106aa6:	6a 0b                	push   $0xb
  jmp alltraps
80106aa8:	e9 7b f8 ff ff       	jmp    80106328 <alltraps>

80106aad <vector12>:
.globl vector12
vector12:
  pushl $12
80106aad:	6a 0c                	push   $0xc
  jmp alltraps
80106aaf:	e9 74 f8 ff ff       	jmp    80106328 <alltraps>

80106ab4 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ab4:	6a 0d                	push   $0xd
  jmp alltraps
80106ab6:	e9 6d f8 ff ff       	jmp    80106328 <alltraps>

80106abb <vector14>:
.globl vector14
vector14:
  pushl $14
80106abb:	6a 0e                	push   $0xe
  jmp alltraps
80106abd:	e9 66 f8 ff ff       	jmp    80106328 <alltraps>

80106ac2 <vector15>:
.globl vector15
vector15:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $15
80106ac4:	6a 0f                	push   $0xf
  jmp alltraps
80106ac6:	e9 5d f8 ff ff       	jmp    80106328 <alltraps>

80106acb <vector16>:
.globl vector16
vector16:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $16
80106acd:	6a 10                	push   $0x10
  jmp alltraps
80106acf:	e9 54 f8 ff ff       	jmp    80106328 <alltraps>

80106ad4 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ad4:	6a 11                	push   $0x11
  jmp alltraps
80106ad6:	e9 4d f8 ff ff       	jmp    80106328 <alltraps>

80106adb <vector18>:
.globl vector18
vector18:
  pushl $0
80106adb:	6a 00                	push   $0x0
  pushl $18
80106add:	6a 12                	push   $0x12
  jmp alltraps
80106adf:	e9 44 f8 ff ff       	jmp    80106328 <alltraps>

80106ae4 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ae4:	6a 00                	push   $0x0
  pushl $19
80106ae6:	6a 13                	push   $0x13
  jmp alltraps
80106ae8:	e9 3b f8 ff ff       	jmp    80106328 <alltraps>

80106aed <vector20>:
.globl vector20
vector20:
  pushl $0
80106aed:	6a 00                	push   $0x0
  pushl $20
80106aef:	6a 14                	push   $0x14
  jmp alltraps
80106af1:	e9 32 f8 ff ff       	jmp    80106328 <alltraps>

80106af6 <vector21>:
.globl vector21
vector21:
  pushl $0
80106af6:	6a 00                	push   $0x0
  pushl $21
80106af8:	6a 15                	push   $0x15
  jmp alltraps
80106afa:	e9 29 f8 ff ff       	jmp    80106328 <alltraps>

80106aff <vector22>:
.globl vector22
vector22:
  pushl $0
80106aff:	6a 00                	push   $0x0
  pushl $22
80106b01:	6a 16                	push   $0x16
  jmp alltraps
80106b03:	e9 20 f8 ff ff       	jmp    80106328 <alltraps>

80106b08 <vector23>:
.globl vector23
vector23:
  pushl $0
80106b08:	6a 00                	push   $0x0
  pushl $23
80106b0a:	6a 17                	push   $0x17
  jmp alltraps
80106b0c:	e9 17 f8 ff ff       	jmp    80106328 <alltraps>

80106b11 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b11:	6a 00                	push   $0x0
  pushl $24
80106b13:	6a 18                	push   $0x18
  jmp alltraps
80106b15:	e9 0e f8 ff ff       	jmp    80106328 <alltraps>

80106b1a <vector25>:
.globl vector25
vector25:
  pushl $0
80106b1a:	6a 00                	push   $0x0
  pushl $25
80106b1c:	6a 19                	push   $0x19
  jmp alltraps
80106b1e:	e9 05 f8 ff ff       	jmp    80106328 <alltraps>

80106b23 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $26
80106b25:	6a 1a                	push   $0x1a
  jmp alltraps
80106b27:	e9 fc f7 ff ff       	jmp    80106328 <alltraps>

80106b2c <vector27>:
.globl vector27
vector27:
  pushl $0
80106b2c:	6a 00                	push   $0x0
  pushl $27
80106b2e:	6a 1b                	push   $0x1b
  jmp alltraps
80106b30:	e9 f3 f7 ff ff       	jmp    80106328 <alltraps>

80106b35 <vector28>:
.globl vector28
vector28:
  pushl $0
80106b35:	6a 00                	push   $0x0
  pushl $28
80106b37:	6a 1c                	push   $0x1c
  jmp alltraps
80106b39:	e9 ea f7 ff ff       	jmp    80106328 <alltraps>

80106b3e <vector29>:
.globl vector29
vector29:
  pushl $0
80106b3e:	6a 00                	push   $0x0
  pushl $29
80106b40:	6a 1d                	push   $0x1d
  jmp alltraps
80106b42:	e9 e1 f7 ff ff       	jmp    80106328 <alltraps>

80106b47 <vector30>:
.globl vector30
vector30:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $30
80106b49:	6a 1e                	push   $0x1e
  jmp alltraps
80106b4b:	e9 d8 f7 ff ff       	jmp    80106328 <alltraps>

80106b50 <vector31>:
.globl vector31
vector31:
  pushl $0
80106b50:	6a 00                	push   $0x0
  pushl $31
80106b52:	6a 1f                	push   $0x1f
  jmp alltraps
80106b54:	e9 cf f7 ff ff       	jmp    80106328 <alltraps>

80106b59 <vector32>:
.globl vector32
vector32:
  pushl $0
80106b59:	6a 00                	push   $0x0
  pushl $32
80106b5b:	6a 20                	push   $0x20
  jmp alltraps
80106b5d:	e9 c6 f7 ff ff       	jmp    80106328 <alltraps>

80106b62 <vector33>:
.globl vector33
vector33:
  pushl $0
80106b62:	6a 00                	push   $0x0
  pushl $33
80106b64:	6a 21                	push   $0x21
  jmp alltraps
80106b66:	e9 bd f7 ff ff       	jmp    80106328 <alltraps>

80106b6b <vector34>:
.globl vector34
vector34:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $34
80106b6d:	6a 22                	push   $0x22
  jmp alltraps
80106b6f:	e9 b4 f7 ff ff       	jmp    80106328 <alltraps>

80106b74 <vector35>:
.globl vector35
vector35:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $35
80106b76:	6a 23                	push   $0x23
  jmp alltraps
80106b78:	e9 ab f7 ff ff       	jmp    80106328 <alltraps>

80106b7d <vector36>:
.globl vector36
vector36:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $36
80106b7f:	6a 24                	push   $0x24
  jmp alltraps
80106b81:	e9 a2 f7 ff ff       	jmp    80106328 <alltraps>

80106b86 <vector37>:
.globl vector37
vector37:
  pushl $0
80106b86:	6a 00                	push   $0x0
  pushl $37
80106b88:	6a 25                	push   $0x25
  jmp alltraps
80106b8a:	e9 99 f7 ff ff       	jmp    80106328 <alltraps>

80106b8f <vector38>:
.globl vector38
vector38:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $38
80106b91:	6a 26                	push   $0x26
  jmp alltraps
80106b93:	e9 90 f7 ff ff       	jmp    80106328 <alltraps>

80106b98 <vector39>:
.globl vector39
vector39:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $39
80106b9a:	6a 27                	push   $0x27
  jmp alltraps
80106b9c:	e9 87 f7 ff ff       	jmp    80106328 <alltraps>

80106ba1 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ba1:	6a 00                	push   $0x0
  pushl $40
80106ba3:	6a 28                	push   $0x28
  jmp alltraps
80106ba5:	e9 7e f7 ff ff       	jmp    80106328 <alltraps>

80106baa <vector41>:
.globl vector41
vector41:
  pushl $0
80106baa:	6a 00                	push   $0x0
  pushl $41
80106bac:	6a 29                	push   $0x29
  jmp alltraps
80106bae:	e9 75 f7 ff ff       	jmp    80106328 <alltraps>

80106bb3 <vector42>:
.globl vector42
vector42:
  pushl $0
80106bb3:	6a 00                	push   $0x0
  pushl $42
80106bb5:	6a 2a                	push   $0x2a
  jmp alltraps
80106bb7:	e9 6c f7 ff ff       	jmp    80106328 <alltraps>

80106bbc <vector43>:
.globl vector43
vector43:
  pushl $0
80106bbc:	6a 00                	push   $0x0
  pushl $43
80106bbe:	6a 2b                	push   $0x2b
  jmp alltraps
80106bc0:	e9 63 f7 ff ff       	jmp    80106328 <alltraps>

80106bc5 <vector44>:
.globl vector44
vector44:
  pushl $0
80106bc5:	6a 00                	push   $0x0
  pushl $44
80106bc7:	6a 2c                	push   $0x2c
  jmp alltraps
80106bc9:	e9 5a f7 ff ff       	jmp    80106328 <alltraps>

80106bce <vector45>:
.globl vector45
vector45:
  pushl $0
80106bce:	6a 00                	push   $0x0
  pushl $45
80106bd0:	6a 2d                	push   $0x2d
  jmp alltraps
80106bd2:	e9 51 f7 ff ff       	jmp    80106328 <alltraps>

80106bd7 <vector46>:
.globl vector46
vector46:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $46
80106bd9:	6a 2e                	push   $0x2e
  jmp alltraps
80106bdb:	e9 48 f7 ff ff       	jmp    80106328 <alltraps>

80106be0 <vector47>:
.globl vector47
vector47:
  pushl $0
80106be0:	6a 00                	push   $0x0
  pushl $47
80106be2:	6a 2f                	push   $0x2f
  jmp alltraps
80106be4:	e9 3f f7 ff ff       	jmp    80106328 <alltraps>

80106be9 <vector48>:
.globl vector48
vector48:
  pushl $0
80106be9:	6a 00                	push   $0x0
  pushl $48
80106beb:	6a 30                	push   $0x30
  jmp alltraps
80106bed:	e9 36 f7 ff ff       	jmp    80106328 <alltraps>

80106bf2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106bf2:	6a 00                	push   $0x0
  pushl $49
80106bf4:	6a 31                	push   $0x31
  jmp alltraps
80106bf6:	e9 2d f7 ff ff       	jmp    80106328 <alltraps>

80106bfb <vector50>:
.globl vector50
vector50:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $50
80106bfd:	6a 32                	push   $0x32
  jmp alltraps
80106bff:	e9 24 f7 ff ff       	jmp    80106328 <alltraps>

80106c04 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c04:	6a 00                	push   $0x0
  pushl $51
80106c06:	6a 33                	push   $0x33
  jmp alltraps
80106c08:	e9 1b f7 ff ff       	jmp    80106328 <alltraps>

80106c0d <vector52>:
.globl vector52
vector52:
  pushl $0
80106c0d:	6a 00                	push   $0x0
  pushl $52
80106c0f:	6a 34                	push   $0x34
  jmp alltraps
80106c11:	e9 12 f7 ff ff       	jmp    80106328 <alltraps>

80106c16 <vector53>:
.globl vector53
vector53:
  pushl $0
80106c16:	6a 00                	push   $0x0
  pushl $53
80106c18:	6a 35                	push   $0x35
  jmp alltraps
80106c1a:	e9 09 f7 ff ff       	jmp    80106328 <alltraps>

80106c1f <vector54>:
.globl vector54
vector54:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $54
80106c21:	6a 36                	push   $0x36
  jmp alltraps
80106c23:	e9 00 f7 ff ff       	jmp    80106328 <alltraps>

80106c28 <vector55>:
.globl vector55
vector55:
  pushl $0
80106c28:	6a 00                	push   $0x0
  pushl $55
80106c2a:	6a 37                	push   $0x37
  jmp alltraps
80106c2c:	e9 f7 f6 ff ff       	jmp    80106328 <alltraps>

80106c31 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c31:	6a 00                	push   $0x0
  pushl $56
80106c33:	6a 38                	push   $0x38
  jmp alltraps
80106c35:	e9 ee f6 ff ff       	jmp    80106328 <alltraps>

80106c3a <vector57>:
.globl vector57
vector57:
  pushl $0
80106c3a:	6a 00                	push   $0x0
  pushl $57
80106c3c:	6a 39                	push   $0x39
  jmp alltraps
80106c3e:	e9 e5 f6 ff ff       	jmp    80106328 <alltraps>

80106c43 <vector58>:
.globl vector58
vector58:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $58
80106c45:	6a 3a                	push   $0x3a
  jmp alltraps
80106c47:	e9 dc f6 ff ff       	jmp    80106328 <alltraps>

80106c4c <vector59>:
.globl vector59
vector59:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $59
80106c4e:	6a 3b                	push   $0x3b
  jmp alltraps
80106c50:	e9 d3 f6 ff ff       	jmp    80106328 <alltraps>

80106c55 <vector60>:
.globl vector60
vector60:
  pushl $0
80106c55:	6a 00                	push   $0x0
  pushl $60
80106c57:	6a 3c                	push   $0x3c
  jmp alltraps
80106c59:	e9 ca f6 ff ff       	jmp    80106328 <alltraps>

80106c5e <vector61>:
.globl vector61
vector61:
  pushl $0
80106c5e:	6a 00                	push   $0x0
  pushl $61
80106c60:	6a 3d                	push   $0x3d
  jmp alltraps
80106c62:	e9 c1 f6 ff ff       	jmp    80106328 <alltraps>

80106c67 <vector62>:
.globl vector62
vector62:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $62
80106c69:	6a 3e                	push   $0x3e
  jmp alltraps
80106c6b:	e9 b8 f6 ff ff       	jmp    80106328 <alltraps>

80106c70 <vector63>:
.globl vector63
vector63:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $63
80106c72:	6a 3f                	push   $0x3f
  jmp alltraps
80106c74:	e9 af f6 ff ff       	jmp    80106328 <alltraps>

80106c79 <vector64>:
.globl vector64
vector64:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $64
80106c7b:	6a 40                	push   $0x40
  jmp alltraps
80106c7d:	e9 a6 f6 ff ff       	jmp    80106328 <alltraps>

80106c82 <vector65>:
.globl vector65
vector65:
  pushl $0
80106c82:	6a 00                	push   $0x0
  pushl $65
80106c84:	6a 41                	push   $0x41
  jmp alltraps
80106c86:	e9 9d f6 ff ff       	jmp    80106328 <alltraps>

80106c8b <vector66>:
.globl vector66
vector66:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $66
80106c8d:	6a 42                	push   $0x42
  jmp alltraps
80106c8f:	e9 94 f6 ff ff       	jmp    80106328 <alltraps>

80106c94 <vector67>:
.globl vector67
vector67:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $67
80106c96:	6a 43                	push   $0x43
  jmp alltraps
80106c98:	e9 8b f6 ff ff       	jmp    80106328 <alltraps>

80106c9d <vector68>:
.globl vector68
vector68:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $68
80106c9f:	6a 44                	push   $0x44
  jmp alltraps
80106ca1:	e9 82 f6 ff ff       	jmp    80106328 <alltraps>

80106ca6 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ca6:	6a 00                	push   $0x0
  pushl $69
80106ca8:	6a 45                	push   $0x45
  jmp alltraps
80106caa:	e9 79 f6 ff ff       	jmp    80106328 <alltraps>

80106caf <vector70>:
.globl vector70
vector70:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $70
80106cb1:	6a 46                	push   $0x46
  jmp alltraps
80106cb3:	e9 70 f6 ff ff       	jmp    80106328 <alltraps>

80106cb8 <vector71>:
.globl vector71
vector71:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $71
80106cba:	6a 47                	push   $0x47
  jmp alltraps
80106cbc:	e9 67 f6 ff ff       	jmp    80106328 <alltraps>

80106cc1 <vector72>:
.globl vector72
vector72:
  pushl $0
80106cc1:	6a 00                	push   $0x0
  pushl $72
80106cc3:	6a 48                	push   $0x48
  jmp alltraps
80106cc5:	e9 5e f6 ff ff       	jmp    80106328 <alltraps>

80106cca <vector73>:
.globl vector73
vector73:
  pushl $0
80106cca:	6a 00                	push   $0x0
  pushl $73
80106ccc:	6a 49                	push   $0x49
  jmp alltraps
80106cce:	e9 55 f6 ff ff       	jmp    80106328 <alltraps>

80106cd3 <vector74>:
.globl vector74
vector74:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $74
80106cd5:	6a 4a                	push   $0x4a
  jmp alltraps
80106cd7:	e9 4c f6 ff ff       	jmp    80106328 <alltraps>

80106cdc <vector75>:
.globl vector75
vector75:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $75
80106cde:	6a 4b                	push   $0x4b
  jmp alltraps
80106ce0:	e9 43 f6 ff ff       	jmp    80106328 <alltraps>

80106ce5 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $76
80106ce7:	6a 4c                	push   $0x4c
  jmp alltraps
80106ce9:	e9 3a f6 ff ff       	jmp    80106328 <alltraps>

80106cee <vector77>:
.globl vector77
vector77:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $77
80106cf0:	6a 4d                	push   $0x4d
  jmp alltraps
80106cf2:	e9 31 f6 ff ff       	jmp    80106328 <alltraps>

80106cf7 <vector78>:
.globl vector78
vector78:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $78
80106cf9:	6a 4e                	push   $0x4e
  jmp alltraps
80106cfb:	e9 28 f6 ff ff       	jmp    80106328 <alltraps>

80106d00 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $79
80106d02:	6a 4f                	push   $0x4f
  jmp alltraps
80106d04:	e9 1f f6 ff ff       	jmp    80106328 <alltraps>

80106d09 <vector80>:
.globl vector80
vector80:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $80
80106d0b:	6a 50                	push   $0x50
  jmp alltraps
80106d0d:	e9 16 f6 ff ff       	jmp    80106328 <alltraps>

80106d12 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $81
80106d14:	6a 51                	push   $0x51
  jmp alltraps
80106d16:	e9 0d f6 ff ff       	jmp    80106328 <alltraps>

80106d1b <vector82>:
.globl vector82
vector82:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $82
80106d1d:	6a 52                	push   $0x52
  jmp alltraps
80106d1f:	e9 04 f6 ff ff       	jmp    80106328 <alltraps>

80106d24 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $83
80106d26:	6a 53                	push   $0x53
  jmp alltraps
80106d28:	e9 fb f5 ff ff       	jmp    80106328 <alltraps>

80106d2d <vector84>:
.globl vector84
vector84:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $84
80106d2f:	6a 54                	push   $0x54
  jmp alltraps
80106d31:	e9 f2 f5 ff ff       	jmp    80106328 <alltraps>

80106d36 <vector85>:
.globl vector85
vector85:
  pushl $0
80106d36:	6a 00                	push   $0x0
  pushl $85
80106d38:	6a 55                	push   $0x55
  jmp alltraps
80106d3a:	e9 e9 f5 ff ff       	jmp    80106328 <alltraps>

80106d3f <vector86>:
.globl vector86
vector86:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $86
80106d41:	6a 56                	push   $0x56
  jmp alltraps
80106d43:	e9 e0 f5 ff ff       	jmp    80106328 <alltraps>

80106d48 <vector87>:
.globl vector87
vector87:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $87
80106d4a:	6a 57                	push   $0x57
  jmp alltraps
80106d4c:	e9 d7 f5 ff ff       	jmp    80106328 <alltraps>

80106d51 <vector88>:
.globl vector88
vector88:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $88
80106d53:	6a 58                	push   $0x58
  jmp alltraps
80106d55:	e9 ce f5 ff ff       	jmp    80106328 <alltraps>

80106d5a <vector89>:
.globl vector89
vector89:
  pushl $0
80106d5a:	6a 00                	push   $0x0
  pushl $89
80106d5c:	6a 59                	push   $0x59
  jmp alltraps
80106d5e:	e9 c5 f5 ff ff       	jmp    80106328 <alltraps>

80106d63 <vector90>:
.globl vector90
vector90:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $90
80106d65:	6a 5a                	push   $0x5a
  jmp alltraps
80106d67:	e9 bc f5 ff ff       	jmp    80106328 <alltraps>

80106d6c <vector91>:
.globl vector91
vector91:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $91
80106d6e:	6a 5b                	push   $0x5b
  jmp alltraps
80106d70:	e9 b3 f5 ff ff       	jmp    80106328 <alltraps>

80106d75 <vector92>:
.globl vector92
vector92:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $92
80106d77:	6a 5c                	push   $0x5c
  jmp alltraps
80106d79:	e9 aa f5 ff ff       	jmp    80106328 <alltraps>

80106d7e <vector93>:
.globl vector93
vector93:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $93
80106d80:	6a 5d                	push   $0x5d
  jmp alltraps
80106d82:	e9 a1 f5 ff ff       	jmp    80106328 <alltraps>

80106d87 <vector94>:
.globl vector94
vector94:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $94
80106d89:	6a 5e                	push   $0x5e
  jmp alltraps
80106d8b:	e9 98 f5 ff ff       	jmp    80106328 <alltraps>

80106d90 <vector95>:
.globl vector95
vector95:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $95
80106d92:	6a 5f                	push   $0x5f
  jmp alltraps
80106d94:	e9 8f f5 ff ff       	jmp    80106328 <alltraps>

80106d99 <vector96>:
.globl vector96
vector96:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $96
80106d9b:	6a 60                	push   $0x60
  jmp alltraps
80106d9d:	e9 86 f5 ff ff       	jmp    80106328 <alltraps>

80106da2 <vector97>:
.globl vector97
vector97:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $97
80106da4:	6a 61                	push   $0x61
  jmp alltraps
80106da6:	e9 7d f5 ff ff       	jmp    80106328 <alltraps>

80106dab <vector98>:
.globl vector98
vector98:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $98
80106dad:	6a 62                	push   $0x62
  jmp alltraps
80106daf:	e9 74 f5 ff ff       	jmp    80106328 <alltraps>

80106db4 <vector99>:
.globl vector99
vector99:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $99
80106db6:	6a 63                	push   $0x63
  jmp alltraps
80106db8:	e9 6b f5 ff ff       	jmp    80106328 <alltraps>

80106dbd <vector100>:
.globl vector100
vector100:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $100
80106dbf:	6a 64                	push   $0x64
  jmp alltraps
80106dc1:	e9 62 f5 ff ff       	jmp    80106328 <alltraps>

80106dc6 <vector101>:
.globl vector101
vector101:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $101
80106dc8:	6a 65                	push   $0x65
  jmp alltraps
80106dca:	e9 59 f5 ff ff       	jmp    80106328 <alltraps>

80106dcf <vector102>:
.globl vector102
vector102:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $102
80106dd1:	6a 66                	push   $0x66
  jmp alltraps
80106dd3:	e9 50 f5 ff ff       	jmp    80106328 <alltraps>

80106dd8 <vector103>:
.globl vector103
vector103:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $103
80106dda:	6a 67                	push   $0x67
  jmp alltraps
80106ddc:	e9 47 f5 ff ff       	jmp    80106328 <alltraps>

80106de1 <vector104>:
.globl vector104
vector104:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $104
80106de3:	6a 68                	push   $0x68
  jmp alltraps
80106de5:	e9 3e f5 ff ff       	jmp    80106328 <alltraps>

80106dea <vector105>:
.globl vector105
vector105:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $105
80106dec:	6a 69                	push   $0x69
  jmp alltraps
80106dee:	e9 35 f5 ff ff       	jmp    80106328 <alltraps>

80106df3 <vector106>:
.globl vector106
vector106:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $106
80106df5:	6a 6a                	push   $0x6a
  jmp alltraps
80106df7:	e9 2c f5 ff ff       	jmp    80106328 <alltraps>

80106dfc <vector107>:
.globl vector107
vector107:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $107
80106dfe:	6a 6b                	push   $0x6b
  jmp alltraps
80106e00:	e9 23 f5 ff ff       	jmp    80106328 <alltraps>

80106e05 <vector108>:
.globl vector108
vector108:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $108
80106e07:	6a 6c                	push   $0x6c
  jmp alltraps
80106e09:	e9 1a f5 ff ff       	jmp    80106328 <alltraps>

80106e0e <vector109>:
.globl vector109
vector109:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $109
80106e10:	6a 6d                	push   $0x6d
  jmp alltraps
80106e12:	e9 11 f5 ff ff       	jmp    80106328 <alltraps>

80106e17 <vector110>:
.globl vector110
vector110:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $110
80106e19:	6a 6e                	push   $0x6e
  jmp alltraps
80106e1b:	e9 08 f5 ff ff       	jmp    80106328 <alltraps>

80106e20 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $111
80106e22:	6a 6f                	push   $0x6f
  jmp alltraps
80106e24:	e9 ff f4 ff ff       	jmp    80106328 <alltraps>

80106e29 <vector112>:
.globl vector112
vector112:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $112
80106e2b:	6a 70                	push   $0x70
  jmp alltraps
80106e2d:	e9 f6 f4 ff ff       	jmp    80106328 <alltraps>

80106e32 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $113
80106e34:	6a 71                	push   $0x71
  jmp alltraps
80106e36:	e9 ed f4 ff ff       	jmp    80106328 <alltraps>

80106e3b <vector114>:
.globl vector114
vector114:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $114
80106e3d:	6a 72                	push   $0x72
  jmp alltraps
80106e3f:	e9 e4 f4 ff ff       	jmp    80106328 <alltraps>

80106e44 <vector115>:
.globl vector115
vector115:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $115
80106e46:	6a 73                	push   $0x73
  jmp alltraps
80106e48:	e9 db f4 ff ff       	jmp    80106328 <alltraps>

80106e4d <vector116>:
.globl vector116
vector116:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $116
80106e4f:	6a 74                	push   $0x74
  jmp alltraps
80106e51:	e9 d2 f4 ff ff       	jmp    80106328 <alltraps>

80106e56 <vector117>:
.globl vector117
vector117:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $117
80106e58:	6a 75                	push   $0x75
  jmp alltraps
80106e5a:	e9 c9 f4 ff ff       	jmp    80106328 <alltraps>

80106e5f <vector118>:
.globl vector118
vector118:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $118
80106e61:	6a 76                	push   $0x76
  jmp alltraps
80106e63:	e9 c0 f4 ff ff       	jmp    80106328 <alltraps>

80106e68 <vector119>:
.globl vector119
vector119:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $119
80106e6a:	6a 77                	push   $0x77
  jmp alltraps
80106e6c:	e9 b7 f4 ff ff       	jmp    80106328 <alltraps>

80106e71 <vector120>:
.globl vector120
vector120:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $120
80106e73:	6a 78                	push   $0x78
  jmp alltraps
80106e75:	e9 ae f4 ff ff       	jmp    80106328 <alltraps>

80106e7a <vector121>:
.globl vector121
vector121:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $121
80106e7c:	6a 79                	push   $0x79
  jmp alltraps
80106e7e:	e9 a5 f4 ff ff       	jmp    80106328 <alltraps>

80106e83 <vector122>:
.globl vector122
vector122:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $122
80106e85:	6a 7a                	push   $0x7a
  jmp alltraps
80106e87:	e9 9c f4 ff ff       	jmp    80106328 <alltraps>

80106e8c <vector123>:
.globl vector123
vector123:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $123
80106e8e:	6a 7b                	push   $0x7b
  jmp alltraps
80106e90:	e9 93 f4 ff ff       	jmp    80106328 <alltraps>

80106e95 <vector124>:
.globl vector124
vector124:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $124
80106e97:	6a 7c                	push   $0x7c
  jmp alltraps
80106e99:	e9 8a f4 ff ff       	jmp    80106328 <alltraps>

80106e9e <vector125>:
.globl vector125
vector125:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $125
80106ea0:	6a 7d                	push   $0x7d
  jmp alltraps
80106ea2:	e9 81 f4 ff ff       	jmp    80106328 <alltraps>

80106ea7 <vector126>:
.globl vector126
vector126:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $126
80106ea9:	6a 7e                	push   $0x7e
  jmp alltraps
80106eab:	e9 78 f4 ff ff       	jmp    80106328 <alltraps>

80106eb0 <vector127>:
.globl vector127
vector127:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $127
80106eb2:	6a 7f                	push   $0x7f
  jmp alltraps
80106eb4:	e9 6f f4 ff ff       	jmp    80106328 <alltraps>

80106eb9 <vector128>:
.globl vector128
vector128:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $128
80106ebb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ec0:	e9 63 f4 ff ff       	jmp    80106328 <alltraps>

80106ec5 <vector129>:
.globl vector129
vector129:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $129
80106ec7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106ecc:	e9 57 f4 ff ff       	jmp    80106328 <alltraps>

80106ed1 <vector130>:
.globl vector130
vector130:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $130
80106ed3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106ed8:	e9 4b f4 ff ff       	jmp    80106328 <alltraps>

80106edd <vector131>:
.globl vector131
vector131:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $131
80106edf:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ee4:	e9 3f f4 ff ff       	jmp    80106328 <alltraps>

80106ee9 <vector132>:
.globl vector132
vector132:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $132
80106eeb:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106ef0:	e9 33 f4 ff ff       	jmp    80106328 <alltraps>

80106ef5 <vector133>:
.globl vector133
vector133:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $133
80106ef7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106efc:	e9 27 f4 ff ff       	jmp    80106328 <alltraps>

80106f01 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $134
80106f03:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f08:	e9 1b f4 ff ff       	jmp    80106328 <alltraps>

80106f0d <vector135>:
.globl vector135
vector135:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $135
80106f0f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f14:	e9 0f f4 ff ff       	jmp    80106328 <alltraps>

80106f19 <vector136>:
.globl vector136
vector136:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $136
80106f1b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f20:	e9 03 f4 ff ff       	jmp    80106328 <alltraps>

80106f25 <vector137>:
.globl vector137
vector137:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $137
80106f27:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f2c:	e9 f7 f3 ff ff       	jmp    80106328 <alltraps>

80106f31 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $138
80106f33:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f38:	e9 eb f3 ff ff       	jmp    80106328 <alltraps>

80106f3d <vector139>:
.globl vector139
vector139:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $139
80106f3f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106f44:	e9 df f3 ff ff       	jmp    80106328 <alltraps>

80106f49 <vector140>:
.globl vector140
vector140:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $140
80106f4b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106f50:	e9 d3 f3 ff ff       	jmp    80106328 <alltraps>

80106f55 <vector141>:
.globl vector141
vector141:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $141
80106f57:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106f5c:	e9 c7 f3 ff ff       	jmp    80106328 <alltraps>

80106f61 <vector142>:
.globl vector142
vector142:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $142
80106f63:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106f68:	e9 bb f3 ff ff       	jmp    80106328 <alltraps>

80106f6d <vector143>:
.globl vector143
vector143:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $143
80106f6f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106f74:	e9 af f3 ff ff       	jmp    80106328 <alltraps>

80106f79 <vector144>:
.globl vector144
vector144:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $144
80106f7b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106f80:	e9 a3 f3 ff ff       	jmp    80106328 <alltraps>

80106f85 <vector145>:
.globl vector145
vector145:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $145
80106f87:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106f8c:	e9 97 f3 ff ff       	jmp    80106328 <alltraps>

80106f91 <vector146>:
.globl vector146
vector146:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $146
80106f93:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106f98:	e9 8b f3 ff ff       	jmp    80106328 <alltraps>

80106f9d <vector147>:
.globl vector147
vector147:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $147
80106f9f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106fa4:	e9 7f f3 ff ff       	jmp    80106328 <alltraps>

80106fa9 <vector148>:
.globl vector148
vector148:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $148
80106fab:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106fb0:	e9 73 f3 ff ff       	jmp    80106328 <alltraps>

80106fb5 <vector149>:
.globl vector149
vector149:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $149
80106fb7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106fbc:	e9 67 f3 ff ff       	jmp    80106328 <alltraps>

80106fc1 <vector150>:
.globl vector150
vector150:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $150
80106fc3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106fc8:	e9 5b f3 ff ff       	jmp    80106328 <alltraps>

80106fcd <vector151>:
.globl vector151
vector151:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $151
80106fcf:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106fd4:	e9 4f f3 ff ff       	jmp    80106328 <alltraps>

80106fd9 <vector152>:
.globl vector152
vector152:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $152
80106fdb:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106fe0:	e9 43 f3 ff ff       	jmp    80106328 <alltraps>

80106fe5 <vector153>:
.globl vector153
vector153:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $153
80106fe7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106fec:	e9 37 f3 ff ff       	jmp    80106328 <alltraps>

80106ff1 <vector154>:
.globl vector154
vector154:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $154
80106ff3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ff8:	e9 2b f3 ff ff       	jmp    80106328 <alltraps>

80106ffd <vector155>:
.globl vector155
vector155:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $155
80106fff:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107004:	e9 1f f3 ff ff       	jmp    80106328 <alltraps>

80107009 <vector156>:
.globl vector156
vector156:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $156
8010700b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107010:	e9 13 f3 ff ff       	jmp    80106328 <alltraps>

80107015 <vector157>:
.globl vector157
vector157:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $157
80107017:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010701c:	e9 07 f3 ff ff       	jmp    80106328 <alltraps>

80107021 <vector158>:
.globl vector158
vector158:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $158
80107023:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107028:	e9 fb f2 ff ff       	jmp    80106328 <alltraps>

8010702d <vector159>:
.globl vector159
vector159:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $159
8010702f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107034:	e9 ef f2 ff ff       	jmp    80106328 <alltraps>

80107039 <vector160>:
.globl vector160
vector160:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $160
8010703b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107040:	e9 e3 f2 ff ff       	jmp    80106328 <alltraps>

80107045 <vector161>:
.globl vector161
vector161:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $161
80107047:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010704c:	e9 d7 f2 ff ff       	jmp    80106328 <alltraps>

80107051 <vector162>:
.globl vector162
vector162:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $162
80107053:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107058:	e9 cb f2 ff ff       	jmp    80106328 <alltraps>

8010705d <vector163>:
.globl vector163
vector163:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $163
8010705f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107064:	e9 bf f2 ff ff       	jmp    80106328 <alltraps>

80107069 <vector164>:
.globl vector164
vector164:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $164
8010706b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107070:	e9 b3 f2 ff ff       	jmp    80106328 <alltraps>

80107075 <vector165>:
.globl vector165
vector165:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $165
80107077:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010707c:	e9 a7 f2 ff ff       	jmp    80106328 <alltraps>

80107081 <vector166>:
.globl vector166
vector166:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $166
80107083:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107088:	e9 9b f2 ff ff       	jmp    80106328 <alltraps>

8010708d <vector167>:
.globl vector167
vector167:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $167
8010708f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107094:	e9 8f f2 ff ff       	jmp    80106328 <alltraps>

80107099 <vector168>:
.globl vector168
vector168:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $168
8010709b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801070a0:	e9 83 f2 ff ff       	jmp    80106328 <alltraps>

801070a5 <vector169>:
.globl vector169
vector169:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $169
801070a7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801070ac:	e9 77 f2 ff ff       	jmp    80106328 <alltraps>

801070b1 <vector170>:
.globl vector170
vector170:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $170
801070b3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801070b8:	e9 6b f2 ff ff       	jmp    80106328 <alltraps>

801070bd <vector171>:
.globl vector171
vector171:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $171
801070bf:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801070c4:	e9 5f f2 ff ff       	jmp    80106328 <alltraps>

801070c9 <vector172>:
.globl vector172
vector172:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $172
801070cb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801070d0:	e9 53 f2 ff ff       	jmp    80106328 <alltraps>

801070d5 <vector173>:
.globl vector173
vector173:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $173
801070d7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801070dc:	e9 47 f2 ff ff       	jmp    80106328 <alltraps>

801070e1 <vector174>:
.globl vector174
vector174:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $174
801070e3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801070e8:	e9 3b f2 ff ff       	jmp    80106328 <alltraps>

801070ed <vector175>:
.globl vector175
vector175:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $175
801070ef:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801070f4:	e9 2f f2 ff ff       	jmp    80106328 <alltraps>

801070f9 <vector176>:
.globl vector176
vector176:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $176
801070fb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107100:	e9 23 f2 ff ff       	jmp    80106328 <alltraps>

80107105 <vector177>:
.globl vector177
vector177:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $177
80107107:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010710c:	e9 17 f2 ff ff       	jmp    80106328 <alltraps>

80107111 <vector178>:
.globl vector178
vector178:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $178
80107113:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107118:	e9 0b f2 ff ff       	jmp    80106328 <alltraps>

8010711d <vector179>:
.globl vector179
vector179:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $179
8010711f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107124:	e9 ff f1 ff ff       	jmp    80106328 <alltraps>

80107129 <vector180>:
.globl vector180
vector180:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $180
8010712b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107130:	e9 f3 f1 ff ff       	jmp    80106328 <alltraps>

80107135 <vector181>:
.globl vector181
vector181:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $181
80107137:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010713c:	e9 e7 f1 ff ff       	jmp    80106328 <alltraps>

80107141 <vector182>:
.globl vector182
vector182:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $182
80107143:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107148:	e9 db f1 ff ff       	jmp    80106328 <alltraps>

8010714d <vector183>:
.globl vector183
vector183:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $183
8010714f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107154:	e9 cf f1 ff ff       	jmp    80106328 <alltraps>

80107159 <vector184>:
.globl vector184
vector184:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $184
8010715b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107160:	e9 c3 f1 ff ff       	jmp    80106328 <alltraps>

80107165 <vector185>:
.globl vector185
vector185:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $185
80107167:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010716c:	e9 b7 f1 ff ff       	jmp    80106328 <alltraps>

80107171 <vector186>:
.globl vector186
vector186:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $186
80107173:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107178:	e9 ab f1 ff ff       	jmp    80106328 <alltraps>

8010717d <vector187>:
.globl vector187
vector187:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $187
8010717f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107184:	e9 9f f1 ff ff       	jmp    80106328 <alltraps>

80107189 <vector188>:
.globl vector188
vector188:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $188
8010718b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107190:	e9 93 f1 ff ff       	jmp    80106328 <alltraps>

80107195 <vector189>:
.globl vector189
vector189:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $189
80107197:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010719c:	e9 87 f1 ff ff       	jmp    80106328 <alltraps>

801071a1 <vector190>:
.globl vector190
vector190:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $190
801071a3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801071a8:	e9 7b f1 ff ff       	jmp    80106328 <alltraps>

801071ad <vector191>:
.globl vector191
vector191:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $191
801071af:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801071b4:	e9 6f f1 ff ff       	jmp    80106328 <alltraps>

801071b9 <vector192>:
.globl vector192
vector192:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $192
801071bb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801071c0:	e9 63 f1 ff ff       	jmp    80106328 <alltraps>

801071c5 <vector193>:
.globl vector193
vector193:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $193
801071c7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801071cc:	e9 57 f1 ff ff       	jmp    80106328 <alltraps>

801071d1 <vector194>:
.globl vector194
vector194:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $194
801071d3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801071d8:	e9 4b f1 ff ff       	jmp    80106328 <alltraps>

801071dd <vector195>:
.globl vector195
vector195:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $195
801071df:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801071e4:	e9 3f f1 ff ff       	jmp    80106328 <alltraps>

801071e9 <vector196>:
.globl vector196
vector196:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $196
801071eb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801071f0:	e9 33 f1 ff ff       	jmp    80106328 <alltraps>

801071f5 <vector197>:
.globl vector197
vector197:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $197
801071f7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801071fc:	e9 27 f1 ff ff       	jmp    80106328 <alltraps>

80107201 <vector198>:
.globl vector198
vector198:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $198
80107203:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107208:	e9 1b f1 ff ff       	jmp    80106328 <alltraps>

8010720d <vector199>:
.globl vector199
vector199:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $199
8010720f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107214:	e9 0f f1 ff ff       	jmp    80106328 <alltraps>

80107219 <vector200>:
.globl vector200
vector200:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $200
8010721b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107220:	e9 03 f1 ff ff       	jmp    80106328 <alltraps>

80107225 <vector201>:
.globl vector201
vector201:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $201
80107227:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010722c:	e9 f7 f0 ff ff       	jmp    80106328 <alltraps>

80107231 <vector202>:
.globl vector202
vector202:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $202
80107233:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107238:	e9 eb f0 ff ff       	jmp    80106328 <alltraps>

8010723d <vector203>:
.globl vector203
vector203:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $203
8010723f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107244:	e9 df f0 ff ff       	jmp    80106328 <alltraps>

80107249 <vector204>:
.globl vector204
vector204:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $204
8010724b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107250:	e9 d3 f0 ff ff       	jmp    80106328 <alltraps>

80107255 <vector205>:
.globl vector205
vector205:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $205
80107257:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010725c:	e9 c7 f0 ff ff       	jmp    80106328 <alltraps>

80107261 <vector206>:
.globl vector206
vector206:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $206
80107263:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107268:	e9 bb f0 ff ff       	jmp    80106328 <alltraps>

8010726d <vector207>:
.globl vector207
vector207:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $207
8010726f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107274:	e9 af f0 ff ff       	jmp    80106328 <alltraps>

80107279 <vector208>:
.globl vector208
vector208:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $208
8010727b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107280:	e9 a3 f0 ff ff       	jmp    80106328 <alltraps>

80107285 <vector209>:
.globl vector209
vector209:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $209
80107287:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010728c:	e9 97 f0 ff ff       	jmp    80106328 <alltraps>

80107291 <vector210>:
.globl vector210
vector210:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $210
80107293:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107298:	e9 8b f0 ff ff       	jmp    80106328 <alltraps>

8010729d <vector211>:
.globl vector211
vector211:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $211
8010729f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801072a4:	e9 7f f0 ff ff       	jmp    80106328 <alltraps>

801072a9 <vector212>:
.globl vector212
vector212:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $212
801072ab:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801072b0:	e9 73 f0 ff ff       	jmp    80106328 <alltraps>

801072b5 <vector213>:
.globl vector213
vector213:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $213
801072b7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801072bc:	e9 67 f0 ff ff       	jmp    80106328 <alltraps>

801072c1 <vector214>:
.globl vector214
vector214:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $214
801072c3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801072c8:	e9 5b f0 ff ff       	jmp    80106328 <alltraps>

801072cd <vector215>:
.globl vector215
vector215:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $215
801072cf:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801072d4:	e9 4f f0 ff ff       	jmp    80106328 <alltraps>

801072d9 <vector216>:
.globl vector216
vector216:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $216
801072db:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801072e0:	e9 43 f0 ff ff       	jmp    80106328 <alltraps>

801072e5 <vector217>:
.globl vector217
vector217:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $217
801072e7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801072ec:	e9 37 f0 ff ff       	jmp    80106328 <alltraps>

801072f1 <vector218>:
.globl vector218
vector218:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $218
801072f3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801072f8:	e9 2b f0 ff ff       	jmp    80106328 <alltraps>

801072fd <vector219>:
.globl vector219
vector219:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $219
801072ff:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107304:	e9 1f f0 ff ff       	jmp    80106328 <alltraps>

80107309 <vector220>:
.globl vector220
vector220:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $220
8010730b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107310:	e9 13 f0 ff ff       	jmp    80106328 <alltraps>

80107315 <vector221>:
.globl vector221
vector221:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $221
80107317:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010731c:	e9 07 f0 ff ff       	jmp    80106328 <alltraps>

80107321 <vector222>:
.globl vector222
vector222:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $222
80107323:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107328:	e9 fb ef ff ff       	jmp    80106328 <alltraps>

8010732d <vector223>:
.globl vector223
vector223:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $223
8010732f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107334:	e9 ef ef ff ff       	jmp    80106328 <alltraps>

80107339 <vector224>:
.globl vector224
vector224:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $224
8010733b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107340:	e9 e3 ef ff ff       	jmp    80106328 <alltraps>

80107345 <vector225>:
.globl vector225
vector225:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $225
80107347:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010734c:	e9 d7 ef ff ff       	jmp    80106328 <alltraps>

80107351 <vector226>:
.globl vector226
vector226:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $226
80107353:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107358:	e9 cb ef ff ff       	jmp    80106328 <alltraps>

8010735d <vector227>:
.globl vector227
vector227:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $227
8010735f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107364:	e9 bf ef ff ff       	jmp    80106328 <alltraps>

80107369 <vector228>:
.globl vector228
vector228:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $228
8010736b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107370:	e9 b3 ef ff ff       	jmp    80106328 <alltraps>

80107375 <vector229>:
.globl vector229
vector229:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $229
80107377:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010737c:	e9 a7 ef ff ff       	jmp    80106328 <alltraps>

80107381 <vector230>:
.globl vector230
vector230:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $230
80107383:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107388:	e9 9b ef ff ff       	jmp    80106328 <alltraps>

8010738d <vector231>:
.globl vector231
vector231:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $231
8010738f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107394:	e9 8f ef ff ff       	jmp    80106328 <alltraps>

80107399 <vector232>:
.globl vector232
vector232:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $232
8010739b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801073a0:	e9 83 ef ff ff       	jmp    80106328 <alltraps>

801073a5 <vector233>:
.globl vector233
vector233:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $233
801073a7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801073ac:	e9 77 ef ff ff       	jmp    80106328 <alltraps>

801073b1 <vector234>:
.globl vector234
vector234:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $234
801073b3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801073b8:	e9 6b ef ff ff       	jmp    80106328 <alltraps>

801073bd <vector235>:
.globl vector235
vector235:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $235
801073bf:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801073c4:	e9 5f ef ff ff       	jmp    80106328 <alltraps>

801073c9 <vector236>:
.globl vector236
vector236:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $236
801073cb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801073d0:	e9 53 ef ff ff       	jmp    80106328 <alltraps>

801073d5 <vector237>:
.globl vector237
vector237:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $237
801073d7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801073dc:	e9 47 ef ff ff       	jmp    80106328 <alltraps>

801073e1 <vector238>:
.globl vector238
vector238:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $238
801073e3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801073e8:	e9 3b ef ff ff       	jmp    80106328 <alltraps>

801073ed <vector239>:
.globl vector239
vector239:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $239
801073ef:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801073f4:	e9 2f ef ff ff       	jmp    80106328 <alltraps>

801073f9 <vector240>:
.globl vector240
vector240:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $240
801073fb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107400:	e9 23 ef ff ff       	jmp    80106328 <alltraps>

80107405 <vector241>:
.globl vector241
vector241:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $241
80107407:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010740c:	e9 17 ef ff ff       	jmp    80106328 <alltraps>

80107411 <vector242>:
.globl vector242
vector242:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $242
80107413:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107418:	e9 0b ef ff ff       	jmp    80106328 <alltraps>

8010741d <vector243>:
.globl vector243
vector243:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $243
8010741f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107424:	e9 ff ee ff ff       	jmp    80106328 <alltraps>

80107429 <vector244>:
.globl vector244
vector244:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $244
8010742b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107430:	e9 f3 ee ff ff       	jmp    80106328 <alltraps>

80107435 <vector245>:
.globl vector245
vector245:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $245
80107437:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010743c:	e9 e7 ee ff ff       	jmp    80106328 <alltraps>

80107441 <vector246>:
.globl vector246
vector246:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $246
80107443:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107448:	e9 db ee ff ff       	jmp    80106328 <alltraps>

8010744d <vector247>:
.globl vector247
vector247:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $247
8010744f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107454:	e9 cf ee ff ff       	jmp    80106328 <alltraps>

80107459 <vector248>:
.globl vector248
vector248:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $248
8010745b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107460:	e9 c3 ee ff ff       	jmp    80106328 <alltraps>

80107465 <vector249>:
.globl vector249
vector249:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $249
80107467:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010746c:	e9 b7 ee ff ff       	jmp    80106328 <alltraps>

80107471 <vector250>:
.globl vector250
vector250:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $250
80107473:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107478:	e9 ab ee ff ff       	jmp    80106328 <alltraps>

8010747d <vector251>:
.globl vector251
vector251:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $251
8010747f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107484:	e9 9f ee ff ff       	jmp    80106328 <alltraps>

80107489 <vector252>:
.globl vector252
vector252:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $252
8010748b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107490:	e9 93 ee ff ff       	jmp    80106328 <alltraps>

80107495 <vector253>:
.globl vector253
vector253:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $253
80107497:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010749c:	e9 87 ee ff ff       	jmp    80106328 <alltraps>

801074a1 <vector254>:
.globl vector254
vector254:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $254
801074a3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801074a8:	e9 7b ee ff ff       	jmp    80106328 <alltraps>

801074ad <vector255>:
.globl vector255
vector255:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $255
801074af:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801074b4:	e9 6f ee ff ff       	jmp    80106328 <alltraps>

801074b9 <lgdt>:
{
801074b9:	55                   	push   %ebp
801074ba:	89 e5                	mov    %esp,%ebp
801074bc:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801074bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801074c2:	83 e8 01             	sub    $0x1,%eax
801074c5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074c9:	8b 45 08             	mov    0x8(%ebp),%eax
801074cc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074d0:	8b 45 08             	mov    0x8(%ebp),%eax
801074d3:	c1 e8 10             	shr    $0x10,%eax
801074d6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801074da:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074dd:	0f 01 10             	lgdtl  (%eax)
}
801074e0:	90                   	nop
801074e1:	c9                   	leave  
801074e2:	c3                   	ret    

801074e3 <ltr>:
{
801074e3:	55                   	push   %ebp
801074e4:	89 e5                	mov    %esp,%ebp
801074e6:	83 ec 04             	sub    $0x4,%esp
801074e9:	8b 45 08             	mov    0x8(%ebp),%eax
801074ec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801074f0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801074f4:	0f 00 d8             	ltr    %ax
}
801074f7:	90                   	nop
801074f8:	c9                   	leave  
801074f9:	c3                   	ret    

801074fa <lcr3>:
{
801074fa:	55                   	push   %ebp
801074fb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107500:	0f 22 d8             	mov    %eax,%cr3
}
80107503:	90                   	nop
80107504:	5d                   	pop    %ebp
80107505:	c3                   	ret    

80107506 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107506:	55                   	push   %ebp
80107507:	89 e5                	mov    %esp,%ebp
80107509:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010750c:	e8 71 c9 ff ff       	call   80103e82 <cpuid>
80107511:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107517:	05 c0 99 11 80       	add    $0x801199c0,%eax
8010751c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010751f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107522:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107534:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010753f:	83 e2 f0             	and    $0xfffffff0,%edx
80107542:	83 ca 0a             	or     $0xa,%edx
80107545:	88 50 7d             	mov    %dl,0x7d(%eax)
80107548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010754f:	83 ca 10             	or     $0x10,%edx
80107552:	88 50 7d             	mov    %dl,0x7d(%eax)
80107555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107558:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010755c:	83 e2 9f             	and    $0xffffff9f,%edx
8010755f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107565:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107569:	83 ca 80             	or     $0xffffff80,%edx
8010756c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010756f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107572:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107576:	83 ca 0f             	or     $0xf,%edx
80107579:	88 50 7e             	mov    %dl,0x7e(%eax)
8010757c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107583:	83 e2 ef             	and    $0xffffffef,%edx
80107586:	88 50 7e             	mov    %dl,0x7e(%eax)
80107589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107590:	83 e2 df             	and    $0xffffffdf,%edx
80107593:	88 50 7e             	mov    %dl,0x7e(%eax)
80107596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107599:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010759d:	83 ca 40             	or     $0x40,%edx
801075a0:	88 50 7e             	mov    %dl,0x7e(%eax)
801075a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075aa:	83 ca 80             	or     $0xffffff80,%edx
801075ad:	88 50 7e             	mov    %dl,0x7e(%eax)
801075b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801075c1:	ff ff 
801075c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801075cd:	00 00 
801075cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075e3:	83 e2 f0             	and    $0xfffffff0,%edx
801075e6:	83 ca 02             	or     $0x2,%edx
801075e9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801075f9:	83 ca 10             	or     $0x10,%edx
801075fc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107605:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010760c:	83 e2 9f             	and    $0xffffff9f,%edx
8010760f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107618:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010761f:	83 ca 80             	or     $0xffffff80,%edx
80107622:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107632:	83 ca 0f             	or     $0xf,%edx
80107635:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010763b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107645:	83 e2 ef             	and    $0xffffffef,%edx
80107648:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107658:	83 e2 df             	and    $0xffffffdf,%edx
8010765b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107664:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010766b:	83 ca 40             	or     $0x40,%edx
8010766e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107677:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010767e:	83 ca 80             	or     $0xffffff80,%edx
80107681:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010769b:	ff ff 
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801076a7:	00 00 
801076a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ac:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076bd:	83 e2 f0             	and    $0xfffffff0,%edx
801076c0:	83 ca 0a             	or     $0xa,%edx
801076c3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076d3:	83 ca 10             	or     $0x10,%edx
801076d6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076df:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076e6:	83 ca 60             	or     $0x60,%edx
801076e9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801076ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801076f9:	83 ca 80             	or     $0xffffff80,%edx
801076fc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107705:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010770c:	83 ca 0f             	or     $0xf,%edx
8010770f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107718:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010771f:	83 e2 ef             	and    $0xffffffef,%edx
80107722:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107732:	83 e2 df             	and    $0xffffffdf,%edx
80107735:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010773b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107745:	83 ca 40             	or     $0x40,%edx
80107748:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010774e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107751:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107758:	83 ca 80             	or     $0xffffff80,%edx
8010775b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010776b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107775:	ff ff 
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107781:	00 00 
80107783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107786:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010778d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107790:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107797:	83 e2 f0             	and    $0xfffffff0,%edx
8010779a:	83 ca 02             	or     $0x2,%edx
8010779d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077ad:	83 ca 10             	or     $0x10,%edx
801077b0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077c0:	83 ca 60             	or     $0x60,%edx
801077c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077d3:	83 ca 80             	or     $0xffffff80,%edx
801077d6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077df:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077e6:	83 ca 0f             	or     $0xf,%edx
801077e9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077f9:	83 e2 ef             	and    $0xffffffef,%edx
801077fc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107805:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010780c:	83 e2 df             	and    $0xffffffdf,%edx
8010780f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010781f:	83 ca 40             	or     $0x40,%edx
80107822:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107832:	83 ca 80             	or     $0xffffff80,%edx
80107835:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	83 c0 70             	add    $0x70,%eax
8010784b:	83 ec 08             	sub    $0x8,%esp
8010784e:	6a 30                	push   $0x30
80107850:	50                   	push   %eax
80107851:	e8 63 fc ff ff       	call   801074b9 <lgdt>
80107856:	83 c4 10             	add    $0x10,%esp
}
80107859:	90                   	nop
8010785a:	c9                   	leave  
8010785b:	c3                   	ret    

8010785c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010785c:	55                   	push   %ebp
8010785d:	89 e5                	mov    %esp,%ebp
8010785f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107862:	8b 45 0c             	mov    0xc(%ebp),%eax
80107865:	c1 e8 16             	shr    $0x16,%eax
80107868:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010786f:	8b 45 08             	mov    0x8(%ebp),%eax
80107872:	01 d0                	add    %edx,%eax
80107874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010787a:	8b 00                	mov    (%eax),%eax
8010787c:	83 e0 01             	and    $0x1,%eax
8010787f:	85 c0                	test   %eax,%eax
80107881:	74 14                	je     80107897 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107886:	8b 00                	mov    (%eax),%eax
80107888:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010788d:	05 00 00 00 80       	add    $0x80000000,%eax
80107892:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107895:	eb 42                	jmp    801078d9 <walkpgdir+0x7d>
  }
  else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107897:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010789b:	74 0e                	je     801078ab <walkpgdir+0x4f>
8010789d:	e8 e3 b3 ff ff       	call   80102c85 <kalloc>
801078a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078a9:	75 07                	jne    801078b2 <walkpgdir+0x56>
      return 0;
801078ab:	b8 00 00 00 00       	mov    $0x0,%eax
801078b0:	eb 3e                	jmp    801078f0 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801078b2:	83 ec 04             	sub    $0x4,%esp
801078b5:	68 00 10 00 00       	push   $0x1000
801078ba:	6a 00                	push   $0x0
801078bc:	ff 75 f4             	push   -0xc(%ebp)
801078bf:	e8 e4 d6 ff ff       	call   80104fa8 <memset>
801078c4:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801078c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ca:	05 00 00 00 80       	add    $0x80000000,%eax
801078cf:	83 c8 07             	or     $0x7,%eax
801078d2:	89 c2                	mov    %eax,%edx
801078d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d7:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801078dc:	c1 e8 0c             	shr    $0xc,%eax
801078df:	25 ff 03 00 00       	and    $0x3ff,%eax
801078e4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	01 d0                	add    %edx,%eax
}
801078f0:	c9                   	leave  
801078f1:	c3                   	ret    

801078f2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
 int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078f2:	55                   	push   %ebp
801078f3:	89 e5                	mov    %esp,%ebp
801078f5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801078f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801078fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107900:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107903:	8b 55 0c             	mov    0xc(%ebp),%edx
80107906:	8b 45 10             	mov    0x10(%ebp),%eax
80107909:	01 d0                	add    %edx,%eax
8010790b:	83 e8 01             	sub    $0x1,%eax
8010790e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107913:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107916:	83 ec 04             	sub    $0x4,%esp
80107919:	6a 01                	push   $0x1
8010791b:	ff 75 f4             	push   -0xc(%ebp)
8010791e:	ff 75 08             	push   0x8(%ebp)
80107921:	e8 36 ff ff ff       	call   8010785c <walkpgdir>
80107926:	83 c4 10             	add    $0x10,%esp
80107929:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010792c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107930:	75 07                	jne    80107939 <mappages+0x47>
      return -1;
80107932:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107937:	eb 47                	jmp    80107980 <mappages+0x8e>
    if(*pte & PTE_P)
80107939:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010793c:	8b 00                	mov    (%eax),%eax
8010793e:	83 e0 01             	and    $0x1,%eax
80107941:	85 c0                	test   %eax,%eax
80107943:	74 0d                	je     80107952 <mappages+0x60>
      panic("remap");
80107945:	83 ec 0c             	sub    $0xc,%esp
80107948:	68 34 ac 10 80       	push   $0x8010ac34
8010794d:	e8 57 8c ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107952:	8b 45 18             	mov    0x18(%ebp),%eax
80107955:	0b 45 14             	or     0x14(%ebp),%eax
80107958:	83 c8 01             	or     $0x1,%eax
8010795b:	89 c2                	mov    %eax,%edx
8010795d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107960:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107965:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107968:	74 10                	je     8010797a <mappages+0x88>
      break;
    a += PGSIZE;
8010796a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107971:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107978:	eb 9c                	jmp    80107916 <mappages+0x24>
      break;
8010797a:	90                   	nop
  }
  return 0;
8010797b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107980:	c9                   	leave  
80107981:	c3                   	ret    

80107982 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107982:	55                   	push   %ebp
80107983:	89 e5                	mov    %esp,%ebp
80107985:	53                   	push   %ebx
80107986:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107989:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107990:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
80107996:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010799b:	29 d0                	sub    %edx,%eax
8010799d:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079a0:	a1 88 9c 11 80       	mov    0x80119c88,%eax
801079a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801079a8:	8b 15 88 9c 11 80    	mov    0x80119c88,%edx
801079ae:	a1 90 9c 11 80       	mov    0x80119c90,%eax
801079b3:	01 d0                	add    %edx,%eax
801079b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801079b8:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	83 c0 30             	add    $0x30,%eax
801079c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801079c8:	89 10                	mov    %edx,(%eax)
801079ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801079cd:	89 50 04             	mov    %edx,0x4(%eax)
801079d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801079d3:	89 50 08             	mov    %edx,0x8(%eax)
801079d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801079d9:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801079dc:	e8 a4 b2 ff ff       	call   80102c85 <kalloc>
801079e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079e8:	75 07                	jne    801079f1 <setupkvm+0x6f>
    return 0;
801079ea:	b8 00 00 00 00       	mov    $0x0,%eax
801079ef:	eb 78                	jmp    80107a69 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801079f1:	83 ec 04             	sub    $0x4,%esp
801079f4:	68 00 10 00 00       	push   $0x1000
801079f9:	6a 00                	push   $0x0
801079fb:	ff 75 f0             	push   -0x10(%ebp)
801079fe:	e8 a5 d5 ff ff       	call   80104fa8 <memset>
80107a03:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a06:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107a0d:	eb 4e                	jmp    80107a5d <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a12:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a18:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	8b 58 08             	mov    0x8(%eax),%ebx
80107a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a24:	8b 40 04             	mov    0x4(%eax),%eax
80107a27:	29 c3                	sub    %eax,%ebx
80107a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2c:	8b 00                	mov    (%eax),%eax
80107a2e:	83 ec 0c             	sub    $0xc,%esp
80107a31:	51                   	push   %ecx
80107a32:	52                   	push   %edx
80107a33:	53                   	push   %ebx
80107a34:	50                   	push   %eax
80107a35:	ff 75 f0             	push   -0x10(%ebp)
80107a38:	e8 b5 fe ff ff       	call   801078f2 <mappages>
80107a3d:	83 c4 20             	add    $0x20,%esp
80107a40:	85 c0                	test   %eax,%eax
80107a42:	79 15                	jns    80107a59 <setupkvm+0xd7>
      freevm(pgdir);
80107a44:	83 ec 0c             	sub    $0xc,%esp
80107a47:	ff 75 f0             	push   -0x10(%ebp)
80107a4a:	e8 f5 04 00 00       	call   80107f44 <freevm>
80107a4f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a52:	b8 00 00 00 00       	mov    $0x0,%eax
80107a57:	eb 10                	jmp    80107a69 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a59:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a5d:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107a64:	72 a9                	jb     80107a0f <setupkvm+0x8d>
    }
  return pgdir;
80107a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a6c:	c9                   	leave  
80107a6d:	c3                   	ret    

80107a6e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a6e:	55                   	push   %ebp
80107a6f:	89 e5                	mov    %esp,%ebp
80107a71:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a74:	e8 09 ff ff ff       	call   80107982 <setupkvm>
80107a79:	a3 bc 99 11 80       	mov    %eax,0x801199bc
  switchkvm();
80107a7e:	e8 03 00 00 00       	call   80107a86 <switchkvm>
}
80107a83:	90                   	nop
80107a84:	c9                   	leave  
80107a85:	c3                   	ret    

80107a86 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a86:	55                   	push   %ebp
80107a87:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107a89:	a1 bc 99 11 80       	mov    0x801199bc,%eax
80107a8e:	05 00 00 00 80       	add    $0x80000000,%eax
80107a93:	50                   	push   %eax
80107a94:	e8 61 fa ff ff       	call   801074fa <lcr3>
80107a99:	83 c4 04             	add    $0x4,%esp
}
80107a9c:	90                   	nop
80107a9d:	c9                   	leave  
80107a9e:	c3                   	ret    

80107a9f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a9f:	55                   	push   %ebp
80107aa0:	89 e5                	mov    %esp,%ebp
80107aa2:	56                   	push   %esi
80107aa3:	53                   	push   %ebx
80107aa4:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107aa7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107aab:	75 0d                	jne    80107aba <switchuvm+0x1b>
    panic("switchuvm: no process");
80107aad:	83 ec 0c             	sub    $0xc,%esp
80107ab0:	68 3a ac 10 80       	push   $0x8010ac3a
80107ab5:	e8 ef 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107aba:	8b 45 08             	mov    0x8(%ebp),%eax
80107abd:	8b 40 08             	mov    0x8(%eax),%eax
80107ac0:	85 c0                	test   %eax,%eax
80107ac2:	75 0d                	jne    80107ad1 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107ac4:	83 ec 0c             	sub    $0xc,%esp
80107ac7:	68 50 ac 10 80       	push   $0x8010ac50
80107acc:	e8 d8 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ad4:	8b 40 04             	mov    0x4(%eax),%eax
80107ad7:	85 c0                	test   %eax,%eax
80107ad9:	75 0d                	jne    80107ae8 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107adb:	83 ec 0c             	sub    $0xc,%esp
80107ade:	68 65 ac 10 80       	push   $0x8010ac65
80107ae3:	e8 c1 8a ff ff       	call   801005a9 <panic>

  pushcli();
80107ae8:	e8 b0 d3 ff ff       	call   80104e9d <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107aed:	e8 ab c3 ff ff       	call   80103e9d <mycpu>
80107af2:	89 c3                	mov    %eax,%ebx
80107af4:	e8 a4 c3 ff ff       	call   80103e9d <mycpu>
80107af9:	83 c0 08             	add    $0x8,%eax
80107afc:	89 c6                	mov    %eax,%esi
80107afe:	e8 9a c3 ff ff       	call   80103e9d <mycpu>
80107b03:	83 c0 08             	add    $0x8,%eax
80107b06:	c1 e8 10             	shr    $0x10,%eax
80107b09:	88 45 f7             	mov    %al,-0x9(%ebp)
80107b0c:	e8 8c c3 ff ff       	call   80103e9d <mycpu>
80107b11:	83 c0 08             	add    $0x8,%eax
80107b14:	c1 e8 18             	shr    $0x18,%eax
80107b17:	89 c2                	mov    %eax,%edx
80107b19:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b20:	67 00 
80107b22:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b29:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107b2d:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107b33:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b3a:	83 e0 f0             	and    $0xfffffff0,%eax
80107b3d:	83 c8 09             	or     $0x9,%eax
80107b40:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b46:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b4d:	83 c8 10             	or     $0x10,%eax
80107b50:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b56:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b5d:	83 e0 9f             	and    $0xffffff9f,%eax
80107b60:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b66:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107b6d:	83 c8 80             	or     $0xffffff80,%eax
80107b70:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107b76:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b7d:	83 e0 f0             	and    $0xfffffff0,%eax
80107b80:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b86:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b8d:	83 e0 ef             	and    $0xffffffef,%eax
80107b90:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b96:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b9d:	83 e0 df             	and    $0xffffffdf,%eax
80107ba0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ba6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bad:	83 c8 40             	or     $0x40,%eax
80107bb0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bb6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bbd:	83 e0 7f             	and    $0x7f,%eax
80107bc0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bc6:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107bcc:	e8 cc c2 ff ff       	call   80103e9d <mycpu>
80107bd1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bd8:	83 e2 ef             	and    $0xffffffef,%edx
80107bdb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107be1:	e8 b7 c2 ff ff       	call   80103e9d <mycpu>
80107be6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107bec:	8b 45 08             	mov    0x8(%ebp),%eax
80107bef:	8b 40 08             	mov    0x8(%eax),%eax
80107bf2:	89 c3                	mov    %eax,%ebx
80107bf4:	e8 a4 c2 ff ff       	call   80103e9d <mycpu>
80107bf9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107bff:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c02:	e8 96 c2 ff ff       	call   80103e9d <mycpu>
80107c07:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c0d:	83 ec 0c             	sub    $0xc,%esp
80107c10:	6a 28                	push   $0x28
80107c12:	e8 cc f8 ff ff       	call   801074e3 <ltr>
80107c17:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1d:	8b 40 04             	mov    0x4(%eax),%eax
80107c20:	05 00 00 00 80       	add    $0x80000000,%eax
80107c25:	83 ec 0c             	sub    $0xc,%esp
80107c28:	50                   	push   %eax
80107c29:	e8 cc f8 ff ff       	call   801074fa <lcr3>
80107c2e:	83 c4 10             	add    $0x10,%esp
  popcli();
80107c31:	e8 b4 d2 ff ff       	call   80104eea <popcli>
}
80107c36:	90                   	nop
80107c37:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107c3a:	5b                   	pop    %ebx
80107c3b:	5e                   	pop    %esi
80107c3c:	5d                   	pop    %ebp
80107c3d:	c3                   	ret    

80107c3e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c3e:	55                   	push   %ebp
80107c3f:	89 e5                	mov    %esp,%ebp
80107c41:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107c44:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c4b:	76 0d                	jbe    80107c5a <inituvm+0x1c>
    panic("inituvm: more than a page");
80107c4d:	83 ec 0c             	sub    $0xc,%esp
80107c50:	68 79 ac 10 80       	push   $0x8010ac79
80107c55:	e8 4f 89 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107c5a:	e8 26 b0 ff ff       	call   80102c85 <kalloc>
80107c5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c62:	83 ec 04             	sub    $0x4,%esp
80107c65:	68 00 10 00 00       	push   $0x1000
80107c6a:	6a 00                	push   $0x0
80107c6c:	ff 75 f4             	push   -0xc(%ebp)
80107c6f:	e8 34 d3 ff ff       	call   80104fa8 <memset>
80107c74:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7a:	05 00 00 00 80       	add    $0x80000000,%eax
80107c7f:	83 ec 0c             	sub    $0xc,%esp
80107c82:	6a 06                	push   $0x6
80107c84:	50                   	push   %eax
80107c85:	68 00 10 00 00       	push   $0x1000
80107c8a:	6a 00                	push   $0x0
80107c8c:	ff 75 08             	push   0x8(%ebp)
80107c8f:	e8 5e fc ff ff       	call   801078f2 <mappages>
80107c94:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c97:	83 ec 04             	sub    $0x4,%esp
80107c9a:	ff 75 10             	push   0x10(%ebp)
80107c9d:	ff 75 0c             	push   0xc(%ebp)
80107ca0:	ff 75 f4             	push   -0xc(%ebp)
80107ca3:	e8 bf d3 ff ff       	call   80105067 <memmove>
80107ca8:	83 c4 10             	add    $0x10,%esp
}
80107cab:	90                   	nop
80107cac:	c9                   	leave  
80107cad:	c3                   	ret    

80107cae <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107cae:	55                   	push   %ebp
80107caf:	89 e5                	mov    %esp,%ebp
80107cb1:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cb7:	25 ff 0f 00 00       	and    $0xfff,%eax
80107cbc:	85 c0                	test   %eax,%eax
80107cbe:	74 0d                	je     80107ccd <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107cc0:	83 ec 0c             	sub    $0xc,%esp
80107cc3:	68 94 ac 10 80       	push   $0x8010ac94
80107cc8:	e8 dc 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107ccd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cd4:	e9 8f 00 00 00       	jmp    80107d68 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdf:	01 d0                	add    %edx,%eax
80107ce1:	83 ec 04             	sub    $0x4,%esp
80107ce4:	6a 00                	push   $0x0
80107ce6:	50                   	push   %eax
80107ce7:	ff 75 08             	push   0x8(%ebp)
80107cea:	e8 6d fb ff ff       	call   8010785c <walkpgdir>
80107cef:	83 c4 10             	add    $0x10,%esp
80107cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cf5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cf9:	75 0d                	jne    80107d08 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107cfb:	83 ec 0c             	sub    $0xc,%esp
80107cfe:	68 b7 ac 10 80       	push   $0x8010acb7
80107d03:	e8 a1 88 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d0b:	8b 00                	mov    (%eax),%eax
80107d0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d12:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d15:	8b 45 18             	mov    0x18(%ebp),%eax
80107d18:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d1b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d20:	77 0b                	ja     80107d2d <loaduvm+0x7f>
      n = sz - i;
80107d22:	8b 45 18             	mov    0x18(%ebp),%eax
80107d25:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d28:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d2b:	eb 07                	jmp    80107d34 <loaduvm+0x86>
    else
      n = PGSIZE;
80107d2d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107d34:	8b 55 14             	mov    0x14(%ebp),%edx
80107d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3a:	01 d0                	add    %edx,%eax
80107d3c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107d3f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107d45:	ff 75 f0             	push   -0x10(%ebp)
80107d48:	50                   	push   %eax
80107d49:	52                   	push   %edx
80107d4a:	ff 75 10             	push   0x10(%ebp)
80107d4d:	e8 85 a1 ff ff       	call   80101ed7 <readi>
80107d52:	83 c4 10             	add    $0x10,%esp
80107d55:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107d58:	74 07                	je     80107d61 <loaduvm+0xb3>
      return -1;
80107d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5f:	eb 18                	jmp    80107d79 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107d61:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d6e:	0f 82 65 ff ff ff    	jb     80107cd9 <loaduvm+0x2b>
  }
  return 0;
80107d74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d79:	c9                   	leave  
80107d7a:	c3                   	ret    

80107d7b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d7b:	55                   	push   %ebp
80107d7c:	89 e5                	mov    %esp,%ebp
80107d7e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d81:	8b 45 10             	mov    0x10(%ebp),%eax
80107d84:	85 c0                	test   %eax,%eax
80107d86:	79 0a                	jns    80107d92 <allocuvm+0x17>
    return 0;
80107d88:	b8 00 00 00 00       	mov    $0x0,%eax
80107d8d:	e9 ec 00 00 00       	jmp    80107e7e <allocuvm+0x103>
  if(newsz < oldsz)
80107d92:	8b 45 10             	mov    0x10(%ebp),%eax
80107d95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d98:	73 08                	jae    80107da2 <allocuvm+0x27>
    return oldsz;
80107d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d9d:	e9 dc 00 00 00       	jmp    80107e7e <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da5:	05 ff 0f 00 00       	add    $0xfff,%eax
80107daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107db2:	e9 b8 00 00 00       	jmp    80107e6f <allocuvm+0xf4>
    mem = kalloc();
80107db7:	e8 c9 ae ff ff       	call   80102c85 <kalloc>
80107dbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107dbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dc3:	75 2e                	jne    80107df3 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107dc5:	83 ec 0c             	sub    $0xc,%esp
80107dc8:	68 d5 ac 10 80       	push   $0x8010acd5
80107dcd:	e8 22 86 ff ff       	call   801003f4 <cprintf>
80107dd2:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107dd5:	83 ec 04             	sub    $0x4,%esp
80107dd8:	ff 75 0c             	push   0xc(%ebp)
80107ddb:	ff 75 10             	push   0x10(%ebp)
80107dde:	ff 75 08             	push   0x8(%ebp)
80107de1:	e8 9a 00 00 00       	call   80107e80 <deallocuvm>
80107de6:	83 c4 10             	add    $0x10,%esp
      return 0;
80107de9:	b8 00 00 00 00       	mov    $0x0,%eax
80107dee:	e9 8b 00 00 00       	jmp    80107e7e <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107df3:	83 ec 04             	sub    $0x4,%esp
80107df6:	68 00 10 00 00       	push   $0x1000
80107dfb:	6a 00                	push   $0x0
80107dfd:	ff 75 f0             	push   -0x10(%ebp)
80107e00:	e8 a3 d1 ff ff       	call   80104fa8 <memset>
80107e05:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e14:	83 ec 0c             	sub    $0xc,%esp
80107e17:	6a 06                	push   $0x6
80107e19:	52                   	push   %edx
80107e1a:	68 00 10 00 00       	push   $0x1000
80107e1f:	50                   	push   %eax
80107e20:	ff 75 08             	push   0x8(%ebp)
80107e23:	e8 ca fa ff ff       	call   801078f2 <mappages>
80107e28:	83 c4 20             	add    $0x20,%esp
80107e2b:	85 c0                	test   %eax,%eax
80107e2d:	79 39                	jns    80107e68 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107e2f:	83 ec 0c             	sub    $0xc,%esp
80107e32:	68 ed ac 10 80       	push   $0x8010aced
80107e37:	e8 b8 85 ff ff       	call   801003f4 <cprintf>
80107e3c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e3f:	83 ec 04             	sub    $0x4,%esp
80107e42:	ff 75 0c             	push   0xc(%ebp)
80107e45:	ff 75 10             	push   0x10(%ebp)
80107e48:	ff 75 08             	push   0x8(%ebp)
80107e4b:	e8 30 00 00 00       	call   80107e80 <deallocuvm>
80107e50:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107e53:	83 ec 0c             	sub    $0xc,%esp
80107e56:	ff 75 f0             	push   -0x10(%ebp)
80107e59:	e8 8d ad ff ff       	call   80102beb <kfree>
80107e5e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e61:	b8 00 00 00 00       	mov    $0x0,%eax
80107e66:	eb 16                	jmp    80107e7e <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107e68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e72:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e75:	0f 82 3c ff ff ff    	jb     80107db7 <allocuvm+0x3c>
    }
  }
  return newsz;
80107e7b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e7e:	c9                   	leave  
80107e7f:	c3                   	ret    

80107e80 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e80:	55                   	push   %ebp
80107e81:	89 e5                	mov    %esp,%ebp
80107e83:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e86:	8b 45 10             	mov    0x10(%ebp),%eax
80107e89:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e8c:	72 08                	jb     80107e96 <deallocuvm+0x16>
    return oldsz;
80107e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e91:	e9 ac 00 00 00       	jmp    80107f42 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107e96:	8b 45 10             	mov    0x10(%ebp),%eax
80107e99:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ea6:	e9 88 00 00 00       	jmp    80107f33 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	83 ec 04             	sub    $0x4,%esp
80107eb1:	6a 00                	push   $0x0
80107eb3:	50                   	push   %eax
80107eb4:	ff 75 08             	push   0x8(%ebp)
80107eb7:	e8 a0 f9 ff ff       	call   8010785c <walkpgdir>
80107ebc:	83 c4 10             	add    $0x10,%esp
80107ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ec2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ec6:	75 16                	jne    80107ede <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecb:	c1 e8 16             	shr    $0x16,%eax
80107ece:	83 c0 01             	add    $0x1,%eax
80107ed1:	c1 e0 16             	shl    $0x16,%eax
80107ed4:	2d 00 10 00 00       	sub    $0x1000,%eax
80107ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107edc:	eb 4e                	jmp    80107f2c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee1:	8b 00                	mov    (%eax),%eax
80107ee3:	83 e0 01             	and    $0x1,%eax
80107ee6:	85 c0                	test   %eax,%eax
80107ee8:	74 42                	je     80107f2c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eed:	8b 00                	mov    (%eax),%eax
80107eef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ef7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107efb:	75 0d                	jne    80107f0a <deallocuvm+0x8a>
        panic("kfree");
80107efd:	83 ec 0c             	sub    $0xc,%esp
80107f00:	68 09 ad 10 80       	push   $0x8010ad09
80107f05:	e8 9f 86 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f0d:	05 00 00 00 80       	add    $0x80000000,%eax
80107f12:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f15:	83 ec 0c             	sub    $0xc,%esp
80107f18:	ff 75 e8             	push   -0x18(%ebp)
80107f1b:	e8 cb ac ff ff       	call   80102beb <kfree>
80107f20:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107f2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f39:	0f 82 6c ff ff ff    	jb     80107eab <deallocuvm+0x2b>
    }
  }
  return newsz;
80107f3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f42:	c9                   	leave  
80107f43:	c3                   	ret    

80107f44 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f44:	55                   	push   %ebp
80107f45:	89 e5                	mov    %esp,%ebp
80107f47:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107f4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f4e:	75 0d                	jne    80107f5d <freevm+0x19>
    panic("freevm: no pgdir");
80107f50:	83 ec 0c             	sub    $0xc,%esp
80107f53:	68 0f ad 10 80       	push   $0x8010ad0f
80107f58:	e8 4c 86 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f5d:	83 ec 04             	sub    $0x4,%esp
80107f60:	6a 00                	push   $0x0
80107f62:	68 00 00 00 80       	push   $0x80000000
80107f67:	ff 75 08             	push   0x8(%ebp)
80107f6a:	e8 11 ff ff ff       	call   80107e80 <deallocuvm>
80107f6f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f79:	eb 48                	jmp    80107fc3 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f85:	8b 45 08             	mov    0x8(%ebp),%eax
80107f88:	01 d0                	add    %edx,%eax
80107f8a:	8b 00                	mov    (%eax),%eax
80107f8c:	83 e0 01             	and    $0x1,%eax
80107f8f:	85 c0                	test   %eax,%eax
80107f91:	74 2c                	je     80107fbf <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa0:	01 d0                	add    %edx,%eax
80107fa2:	8b 00                	mov    (%eax),%eax
80107fa4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa9:	05 00 00 00 80       	add    $0x80000000,%eax
80107fae:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107fb1:	83 ec 0c             	sub    $0xc,%esp
80107fb4:	ff 75 f0             	push   -0x10(%ebp)
80107fb7:	e8 2f ac ff ff       	call   80102beb <kfree>
80107fbc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fc3:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107fca:	76 af                	jbe    80107f7b <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107fcc:	83 ec 0c             	sub    $0xc,%esp
80107fcf:	ff 75 08             	push   0x8(%ebp)
80107fd2:	e8 14 ac ff ff       	call   80102beb <kfree>
80107fd7:	83 c4 10             	add    $0x10,%esp
}
80107fda:	90                   	nop
80107fdb:	c9                   	leave  
80107fdc:	c3                   	ret    

80107fdd <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fdd:	55                   	push   %ebp
80107fde:	89 e5                	mov    %esp,%ebp
80107fe0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fe3:	83 ec 04             	sub    $0x4,%esp
80107fe6:	6a 00                	push   $0x0
80107fe8:	ff 75 0c             	push   0xc(%ebp)
80107feb:	ff 75 08             	push   0x8(%ebp)
80107fee:	e8 69 f8 ff ff       	call   8010785c <walkpgdir>
80107ff3:	83 c4 10             	add    $0x10,%esp
80107ff6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107ff9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ffd:	75 0d                	jne    8010800c <clearpteu+0x2f>
    panic("clearpteu");
80107fff:	83 ec 0c             	sub    $0xc,%esp
80108002:	68 20 ad 10 80       	push   $0x8010ad20
80108007:	e8 9d 85 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010800c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800f:	8b 00                	mov    (%eax),%eax
80108011:	83 e0 fb             	and    $0xfffffffb,%eax
80108014:	89 c2                	mov    %eax,%edx
80108016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108019:	89 10                	mov    %edx,(%eax)
}
8010801b:	90                   	nop
8010801c:	c9                   	leave  
8010801d:	c3                   	ret    

8010801e <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010801e:	55                   	push   %ebp
8010801f:	89 e5                	mov    %esp,%ebp
80108021:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108024:	e8 59 f9 ff ff       	call   80107982 <setupkvm>
80108029:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010802c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108030:	75 0a                	jne    8010803c <copyuvm+0x1e>
    return 0;
80108032:	b8 00 00 00 00       	mov    $0x0,%eax
80108037:	e9 d6 00 00 00       	jmp    80108112 <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
8010803c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108043:	e9 a3 00 00 00       	jmp    801080eb <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80108048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804b:	83 ec 04             	sub    $0x4,%esp
8010804e:	6a 00                	push   $0x0
80108050:	50                   	push   %eax
80108051:	ff 75 08             	push   0x8(%ebp)
80108054:	e8 03 f8 ff ff       	call   8010785c <walkpgdir>
80108059:	83 c4 10             	add    $0x10,%esp
8010805c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010805f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108063:	74 7b                	je     801080e0 <copyuvm+0xc2>
      continue;
    }
    if(!(*pte & PTE_P)){
80108065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108068:	8b 00                	mov    (%eax),%eax
8010806a:	83 e0 01             	and    $0x1,%eax
8010806d:	85 c0                	test   %eax,%eax
8010806f:	74 72                	je     801080e3 <copyuvm+0xc5>
      continue;
    }
    pa = PTE_ADDR(*pte);
80108071:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108074:	8b 00                	mov    (%eax),%eax
80108076:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010807b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010807e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108081:	8b 00                	mov    (%eax),%eax
80108083:	25 ff 0f 00 00       	and    $0xfff,%eax
80108088:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010808b:	e8 f5 ab ff ff       	call   80102c85 <kalloc>
80108090:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108093:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108097:	74 62                	je     801080fb <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108099:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010809c:	05 00 00 00 80       	add    $0x80000000,%eax
801080a1:	83 ec 04             	sub    $0x4,%esp
801080a4:	68 00 10 00 00       	push   $0x1000
801080a9:	50                   	push   %eax
801080aa:	ff 75 e0             	push   -0x20(%ebp)
801080ad:	e8 b5 cf ff ff       	call   80105067 <memmove>
801080b2:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801080b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801080b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080bb:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801080c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c4:	83 ec 0c             	sub    $0xc,%esp
801080c7:	52                   	push   %edx
801080c8:	51                   	push   %ecx
801080c9:	68 00 10 00 00       	push   $0x1000
801080ce:	50                   	push   %eax
801080cf:	ff 75 f0             	push   -0x10(%ebp)
801080d2:	e8 1b f8 ff ff       	call   801078f2 <mappages>
801080d7:	83 c4 20             	add    $0x20,%esp
801080da:	85 c0                	test   %eax,%eax
801080dc:	78 20                	js     801080fe <copyuvm+0xe0>
801080de:	eb 04                	jmp    801080e4 <copyuvm+0xc6>
      continue;
801080e0:	90                   	nop
801080e1:	eb 01                	jmp    801080e4 <copyuvm+0xc6>
      continue;
801080e3:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
801080e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ee:	85 c0                	test   %eax,%eax
801080f0:	0f 89 52 ff ff ff    	jns    80108048 <copyuvm+0x2a>
      goto bad;
  }
  return d;
801080f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f9:	eb 17                	jmp    80108112 <copyuvm+0xf4>
      goto bad;
801080fb:	90                   	nop
801080fc:	eb 01                	jmp    801080ff <copyuvm+0xe1>
      goto bad;
801080fe:	90                   	nop

bad:
  freevm(d);
801080ff:	83 ec 0c             	sub    $0xc,%esp
80108102:	ff 75 f0             	push   -0x10(%ebp)
80108105:	e8 3a fe ff ff       	call   80107f44 <freevm>
8010810a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010810d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108112:	c9                   	leave  
80108113:	c3                   	ret    

80108114 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108114:	55                   	push   %ebp
80108115:	89 e5                	mov    %esp,%ebp
80108117:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010811a:	83 ec 04             	sub    $0x4,%esp
8010811d:	6a 00                	push   $0x0
8010811f:	ff 75 0c             	push   0xc(%ebp)
80108122:	ff 75 08             	push   0x8(%ebp)
80108125:	e8 32 f7 ff ff       	call   8010785c <walkpgdir>
8010812a:	83 c4 10             	add    $0x10,%esp
8010812d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108133:	8b 00                	mov    (%eax),%eax
80108135:	83 e0 01             	and    $0x1,%eax
80108138:	85 c0                	test   %eax,%eax
8010813a:	75 07                	jne    80108143 <uva2ka+0x2f>
    return 0;
8010813c:	b8 00 00 00 00       	mov    $0x0,%eax
80108141:	eb 22                	jmp    80108165 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	8b 00                	mov    (%eax),%eax
80108148:	83 e0 04             	and    $0x4,%eax
8010814b:	85 c0                	test   %eax,%eax
8010814d:	75 07                	jne    80108156 <uva2ka+0x42>
    return 0;
8010814f:	b8 00 00 00 00       	mov    $0x0,%eax
80108154:	eb 0f                	jmp    80108165 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108159:	8b 00                	mov    (%eax),%eax
8010815b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108160:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108165:	c9                   	leave  
80108166:	c3                   	ret    

80108167 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108167:	55                   	push   %ebp
80108168:	89 e5                	mov    %esp,%ebp
8010816a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010816d:	8b 45 10             	mov    0x10(%ebp),%eax
80108170:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108173:	eb 7f                	jmp    801081f4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108175:	8b 45 0c             	mov    0xc(%ebp),%eax
80108178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108180:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108183:	83 ec 08             	sub    $0x8,%esp
80108186:	50                   	push   %eax
80108187:	ff 75 08             	push   0x8(%ebp)
8010818a:	e8 85 ff ff ff       	call   80108114 <uva2ka>
8010818f:	83 c4 10             	add    $0x10,%esp
80108192:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108195:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108199:	75 07                	jne    801081a2 <copyout+0x3b>
      return -1;
8010819b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081a0:	eb 61                	jmp    80108203 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801081a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081a5:	2b 45 0c             	sub    0xc(%ebp),%eax
801081a8:	05 00 10 00 00       	add    $0x1000,%eax
801081ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801081b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b3:	3b 45 14             	cmp    0x14(%ebp),%eax
801081b6:	76 06                	jbe    801081be <copyout+0x57>
      n = len;
801081b8:	8b 45 14             	mov    0x14(%ebp),%eax
801081bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081be:	8b 45 0c             	mov    0xc(%ebp),%eax
801081c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
801081c4:	89 c2                	mov    %eax,%edx
801081c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c9:	01 d0                	add    %edx,%eax
801081cb:	83 ec 04             	sub    $0x4,%esp
801081ce:	ff 75 f0             	push   -0x10(%ebp)
801081d1:	ff 75 f4             	push   -0xc(%ebp)
801081d4:	50                   	push   %eax
801081d5:	e8 8d ce ff ff       	call   80105067 <memmove>
801081da:	83 c4 10             	add    $0x10,%esp
    len -= n;
801081dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e0:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e6:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ec:	05 00 10 00 00       	add    $0x1000,%eax
801081f1:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801081f4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081f8:	0f 85 77 ff ff ff    	jne    80108175 <copyout+0xe>
  }
  return 0;
801081fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108203:	c9                   	leave  
80108204:	c3                   	ret    

80108205 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108205:	55                   	push   %ebp
80108206:	89 e5                	mov    %esp,%ebp
80108208:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010820b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108212:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108215:	8b 40 08             	mov    0x8(%eax),%eax
80108218:	05 00 00 00 80       	add    $0x80000000,%eax
8010821d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108220:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822a:	8b 40 24             	mov    0x24(%eax),%eax
8010822d:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108232:	c7 05 80 9c 11 80 00 	movl   $0x0,0x80119c80
80108239:	00 00 00 

  while(i<madt->len){
8010823c:	90                   	nop
8010823d:	e9 bd 00 00 00       	jmp    801082ff <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108242:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108245:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108248:	01 d0                	add    %edx,%eax
8010824a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010824d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108250:	0f b6 00             	movzbl (%eax),%eax
80108253:	0f b6 c0             	movzbl %al,%eax
80108256:	83 f8 05             	cmp    $0x5,%eax
80108259:	0f 87 a0 00 00 00    	ja     801082ff <mpinit_uefi+0xfa>
8010825f:	8b 04 85 2c ad 10 80 	mov    -0x7fef52d4(,%eax,4),%eax
80108266:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010826e:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80108273:	83 f8 03             	cmp    $0x3,%eax
80108276:	7f 28                	jg     801082a0 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108278:	8b 15 80 9c 11 80    	mov    0x80119c80,%edx
8010827e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108281:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108285:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010828b:	81 c2 c0 99 11 80    	add    $0x801199c0,%edx
80108291:	88 02                	mov    %al,(%edx)
          ncpu++;
80108293:	a1 80 9c 11 80       	mov    0x80119c80,%eax
80108298:	83 c0 01             	add    $0x1,%eax
8010829b:	a3 80 9c 11 80       	mov    %eax,0x80119c80
        }
        i += lapic_entry->record_len;
801082a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082a3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082a7:	0f b6 c0             	movzbl %al,%eax
801082aa:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082ad:	eb 50                	jmp    801082ff <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801082af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801082b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082b8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801082bc:	a2 84 9c 11 80       	mov    %al,0x80119c84
        i += ioapic->record_len;
801082c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082c4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082c8:	0f b6 c0             	movzbl %al,%eax
801082cb:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082ce:	eb 2f                	jmp    801082ff <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801082d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801082d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082d9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082dd:	0f b6 c0             	movzbl %al,%eax
801082e0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082e3:	eb 1a                	jmp    801082ff <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801082e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801082eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ee:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801082f2:	0f b6 c0             	movzbl %al,%eax
801082f5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801082f8:	eb 05                	jmp    801082ff <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801082fa:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801082fe:	90                   	nop
  while(i<madt->len){
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	8b 40 04             	mov    0x4(%eax),%eax
80108305:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108308:	0f 82 34 ff ff ff    	jb     80108242 <mpinit_uefi+0x3d>
    }
  }

}
8010830e:	90                   	nop
8010830f:	90                   	nop
80108310:	c9                   	leave  
80108311:	c3                   	ret    

80108312 <inb>:
{
80108312:	55                   	push   %ebp
80108313:	89 e5                	mov    %esp,%ebp
80108315:	83 ec 14             	sub    $0x14,%esp
80108318:	8b 45 08             	mov    0x8(%ebp),%eax
8010831b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010831f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108323:	89 c2                	mov    %eax,%edx
80108325:	ec                   	in     (%dx),%al
80108326:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108329:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010832d:	c9                   	leave  
8010832e:	c3                   	ret    

8010832f <outb>:
{
8010832f:	55                   	push   %ebp
80108330:	89 e5                	mov    %esp,%ebp
80108332:	83 ec 08             	sub    $0x8,%esp
80108335:	8b 45 08             	mov    0x8(%ebp),%eax
80108338:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010833f:	89 d0                	mov    %edx,%eax
80108341:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108344:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108348:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010834c:	ee                   	out    %al,(%dx)
}
8010834d:	90                   	nop
8010834e:	c9                   	leave  
8010834f:	c3                   	ret    

80108350 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108350:	55                   	push   %ebp
80108351:	89 e5                	mov    %esp,%ebp
80108353:	83 ec 28             	sub    $0x28,%esp
80108356:	8b 45 08             	mov    0x8(%ebp),%eax
80108359:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010835c:	6a 00                	push   $0x0
8010835e:	68 fa 03 00 00       	push   $0x3fa
80108363:	e8 c7 ff ff ff       	call   8010832f <outb>
80108368:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010836b:	68 80 00 00 00       	push   $0x80
80108370:	68 fb 03 00 00       	push   $0x3fb
80108375:	e8 b5 ff ff ff       	call   8010832f <outb>
8010837a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010837d:	6a 0c                	push   $0xc
8010837f:	68 f8 03 00 00       	push   $0x3f8
80108384:	e8 a6 ff ff ff       	call   8010832f <outb>
80108389:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010838c:	6a 00                	push   $0x0
8010838e:	68 f9 03 00 00       	push   $0x3f9
80108393:	e8 97 ff ff ff       	call   8010832f <outb>
80108398:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010839b:	6a 03                	push   $0x3
8010839d:	68 fb 03 00 00       	push   $0x3fb
801083a2:	e8 88 ff ff ff       	call   8010832f <outb>
801083a7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801083aa:	6a 00                	push   $0x0
801083ac:	68 fc 03 00 00       	push   $0x3fc
801083b1:	e8 79 ff ff ff       	call   8010832f <outb>
801083b6:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801083b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c0:	eb 11                	jmp    801083d3 <uart_debug+0x83>
801083c2:	83 ec 0c             	sub    $0xc,%esp
801083c5:	6a 0a                	push   $0xa
801083c7:	e8 50 ac ff ff       	call   8010301c <microdelay>
801083cc:	83 c4 10             	add    $0x10,%esp
801083cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801083d3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801083d7:	7f 1a                	jg     801083f3 <uart_debug+0xa3>
801083d9:	83 ec 0c             	sub    $0xc,%esp
801083dc:	68 fd 03 00 00       	push   $0x3fd
801083e1:	e8 2c ff ff ff       	call   80108312 <inb>
801083e6:	83 c4 10             	add    $0x10,%esp
801083e9:	0f b6 c0             	movzbl %al,%eax
801083ec:	83 e0 20             	and    $0x20,%eax
801083ef:	85 c0                	test   %eax,%eax
801083f1:	74 cf                	je     801083c2 <uart_debug+0x72>
  outb(COM1+0, p);
801083f3:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801083f7:	0f b6 c0             	movzbl %al,%eax
801083fa:	83 ec 08             	sub    $0x8,%esp
801083fd:	50                   	push   %eax
801083fe:	68 f8 03 00 00       	push   $0x3f8
80108403:	e8 27 ff ff ff       	call   8010832f <outb>
80108408:	83 c4 10             	add    $0x10,%esp
}
8010840b:	90                   	nop
8010840c:	c9                   	leave  
8010840d:	c3                   	ret    

8010840e <uart_debugs>:

void uart_debugs(char *p){
8010840e:	55                   	push   %ebp
8010840f:	89 e5                	mov    %esp,%ebp
80108411:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108414:	eb 1b                	jmp    80108431 <uart_debugs+0x23>
    uart_debug(*p++);
80108416:	8b 45 08             	mov    0x8(%ebp),%eax
80108419:	8d 50 01             	lea    0x1(%eax),%edx
8010841c:	89 55 08             	mov    %edx,0x8(%ebp)
8010841f:	0f b6 00             	movzbl (%eax),%eax
80108422:	0f be c0             	movsbl %al,%eax
80108425:	83 ec 0c             	sub    $0xc,%esp
80108428:	50                   	push   %eax
80108429:	e8 22 ff ff ff       	call   80108350 <uart_debug>
8010842e:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108431:	8b 45 08             	mov    0x8(%ebp),%eax
80108434:	0f b6 00             	movzbl (%eax),%eax
80108437:	84 c0                	test   %al,%al
80108439:	75 db                	jne    80108416 <uart_debugs+0x8>
  }
}
8010843b:	90                   	nop
8010843c:	90                   	nop
8010843d:	c9                   	leave  
8010843e:	c3                   	ret    

8010843f <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010843f:	55                   	push   %ebp
80108440:	89 e5                	mov    %esp,%ebp
80108442:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108445:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010844c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010844f:	8b 50 14             	mov    0x14(%eax),%edx
80108452:	8b 40 10             	mov    0x10(%eax),%eax
80108455:	a3 88 9c 11 80       	mov    %eax,0x80119c88
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010845a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010845d:	8b 50 1c             	mov    0x1c(%eax),%edx
80108460:	8b 40 18             	mov    0x18(%eax),%eax
80108463:	a3 90 9c 11 80       	mov    %eax,0x80119c90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108468:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
8010846e:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108473:	29 d0                	sub    %edx,%eax
80108475:	a3 8c 9c 11 80       	mov    %eax,0x80119c8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010847a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010847d:	8b 50 24             	mov    0x24(%eax),%edx
80108480:	8b 40 20             	mov    0x20(%eax),%eax
80108483:	a3 94 9c 11 80       	mov    %eax,0x80119c94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108488:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010848b:	8b 50 2c             	mov    0x2c(%eax),%edx
8010848e:	8b 40 28             	mov    0x28(%eax),%eax
80108491:	a3 98 9c 11 80       	mov    %eax,0x80119c98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108496:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108499:	8b 50 34             	mov    0x34(%eax),%edx
8010849c:	8b 40 30             	mov    0x30(%eax),%eax
8010849f:	a3 9c 9c 11 80       	mov    %eax,0x80119c9c
}
801084a4:	90                   	nop
801084a5:	c9                   	leave  
801084a6:	c3                   	ret    

801084a7 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801084a7:	55                   	push   %ebp
801084a8:	89 e5                	mov    %esp,%ebp
801084aa:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801084ad:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
801084b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b6:	0f af d0             	imul   %eax,%edx
801084b9:	8b 45 08             	mov    0x8(%ebp),%eax
801084bc:	01 d0                	add    %edx,%eax
801084be:	c1 e0 02             	shl    $0x2,%eax
801084c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801084c4:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
801084ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084cd:	01 d0                	add    %edx,%eax
801084cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801084d2:	8b 45 10             	mov    0x10(%ebp),%eax
801084d5:	0f b6 10             	movzbl (%eax),%edx
801084d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084db:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801084dd:	8b 45 10             	mov    0x10(%ebp),%eax
801084e0:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801084e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084e7:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801084ea:	8b 45 10             	mov    0x10(%ebp),%eax
801084ed:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801084f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084f4:	88 50 02             	mov    %dl,0x2(%eax)
}
801084f7:	90                   	nop
801084f8:	c9                   	leave  
801084f9:	c3                   	ret    

801084fa <graphic_scroll_up>:

void graphic_scroll_up(int height){
801084fa:	55                   	push   %ebp
801084fb:	89 e5                	mov    %esp,%ebp
801084fd:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108500:	8b 15 9c 9c 11 80    	mov    0x80119c9c,%edx
80108506:	8b 45 08             	mov    0x8(%ebp),%eax
80108509:	0f af c2             	imul   %edx,%eax
8010850c:	c1 e0 02             	shl    $0x2,%eax
8010850f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108512:	a1 90 9c 11 80       	mov    0x80119c90,%eax
80108517:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010851a:	29 d0                	sub    %edx,%eax
8010851c:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
80108522:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108525:	01 ca                	add    %ecx,%edx
80108527:	89 d1                	mov    %edx,%ecx
80108529:	8b 15 8c 9c 11 80    	mov    0x80119c8c,%edx
8010852f:	83 ec 04             	sub    $0x4,%esp
80108532:	50                   	push   %eax
80108533:	51                   	push   %ecx
80108534:	52                   	push   %edx
80108535:	e8 2d cb ff ff       	call   80105067 <memmove>
8010853a:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010853d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108540:	8b 0d 8c 9c 11 80    	mov    0x80119c8c,%ecx
80108546:	8b 15 90 9c 11 80    	mov    0x80119c90,%edx
8010854c:	01 ca                	add    %ecx,%edx
8010854e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108551:	29 ca                	sub    %ecx,%edx
80108553:	83 ec 04             	sub    $0x4,%esp
80108556:	50                   	push   %eax
80108557:	6a 00                	push   $0x0
80108559:	52                   	push   %edx
8010855a:	e8 49 ca ff ff       	call   80104fa8 <memset>
8010855f:	83 c4 10             	add    $0x10,%esp
}
80108562:	90                   	nop
80108563:	c9                   	leave  
80108564:	c3                   	ret    

80108565 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108565:	55                   	push   %ebp
80108566:	89 e5                	mov    %esp,%ebp
80108568:	53                   	push   %ebx
80108569:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010856c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108573:	e9 b1 00 00 00       	jmp    80108629 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108578:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010857f:	e9 97 00 00 00       	jmp    8010861b <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108584:	8b 45 10             	mov    0x10(%ebp),%eax
80108587:	83 e8 20             	sub    $0x20,%eax
8010858a:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010858d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108590:	01 d0                	add    %edx,%eax
80108592:	0f b7 84 00 60 ad 10 	movzwl -0x7fef52a0(%eax,%eax,1),%eax
80108599:	80 
8010859a:	0f b7 d0             	movzwl %ax,%edx
8010859d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085a0:	bb 01 00 00 00       	mov    $0x1,%ebx
801085a5:	89 c1                	mov    %eax,%ecx
801085a7:	d3 e3                	shl    %cl,%ebx
801085a9:	89 d8                	mov    %ebx,%eax
801085ab:	21 d0                	and    %edx,%eax
801085ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801085b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b3:	ba 01 00 00 00       	mov    $0x1,%edx
801085b8:	89 c1                	mov    %eax,%ecx
801085ba:	d3 e2                	shl    %cl,%edx
801085bc:	89 d0                	mov    %edx,%eax
801085be:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801085c1:	75 2b                	jne    801085ee <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801085c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801085c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c9:	01 c2                	add    %eax,%edx
801085cb:	b8 0e 00 00 00       	mov    $0xe,%eax
801085d0:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085d3:	89 c1                	mov    %eax,%ecx
801085d5:	8b 45 08             	mov    0x8(%ebp),%eax
801085d8:	01 c8                	add    %ecx,%eax
801085da:	83 ec 04             	sub    $0x4,%esp
801085dd:	68 e0 f4 10 80       	push   $0x8010f4e0
801085e2:	52                   	push   %edx
801085e3:	50                   	push   %eax
801085e4:	e8 be fe ff ff       	call   801084a7 <graphic_draw_pixel>
801085e9:	83 c4 10             	add    $0x10,%esp
801085ec:	eb 29                	jmp    80108617 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801085ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801085f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f4:	01 c2                	add    %eax,%edx
801085f6:	b8 0e 00 00 00       	mov    $0xe,%eax
801085fb:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085fe:	89 c1                	mov    %eax,%ecx
80108600:	8b 45 08             	mov    0x8(%ebp),%eax
80108603:	01 c8                	add    %ecx,%eax
80108605:	83 ec 04             	sub    $0x4,%esp
80108608:	68 a0 9c 11 80       	push   $0x80119ca0
8010860d:	52                   	push   %edx
8010860e:	50                   	push   %eax
8010860f:	e8 93 fe ff ff       	call   801084a7 <graphic_draw_pixel>
80108614:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108617:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010861b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010861f:	0f 89 5f ff ff ff    	jns    80108584 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108625:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108629:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010862d:	0f 8e 45 ff ff ff    	jle    80108578 <font_render+0x13>
      }
    }
  }
}
80108633:	90                   	nop
80108634:	90                   	nop
80108635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108638:	c9                   	leave  
80108639:	c3                   	ret    

8010863a <font_render_string>:

void font_render_string(char *string,int row){
8010863a:	55                   	push   %ebp
8010863b:	89 e5                	mov    %esp,%ebp
8010863d:	53                   	push   %ebx
8010863e:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108641:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108648:	eb 33                	jmp    8010867d <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010864a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010864d:	8b 45 08             	mov    0x8(%ebp),%eax
80108650:	01 d0                	add    %edx,%eax
80108652:	0f b6 00             	movzbl (%eax),%eax
80108655:	0f be c8             	movsbl %al,%ecx
80108658:	8b 45 0c             	mov    0xc(%ebp),%eax
8010865b:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010865e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108661:	89 d8                	mov    %ebx,%eax
80108663:	c1 e0 04             	shl    $0x4,%eax
80108666:	29 d8                	sub    %ebx,%eax
80108668:	83 c0 02             	add    $0x2,%eax
8010866b:	83 ec 04             	sub    $0x4,%esp
8010866e:	51                   	push   %ecx
8010866f:	52                   	push   %edx
80108670:	50                   	push   %eax
80108671:	e8 ef fe ff ff       	call   80108565 <font_render>
80108676:	83 c4 10             	add    $0x10,%esp
    i++;
80108679:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010867d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108680:	8b 45 08             	mov    0x8(%ebp),%eax
80108683:	01 d0                	add    %edx,%eax
80108685:	0f b6 00             	movzbl (%eax),%eax
80108688:	84 c0                	test   %al,%al
8010868a:	74 06                	je     80108692 <font_render_string+0x58>
8010868c:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108690:	7e b8                	jle    8010864a <font_render_string+0x10>
  }
}
80108692:	90                   	nop
80108693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108696:	c9                   	leave  
80108697:	c3                   	ret    

80108698 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108698:	55                   	push   %ebp
80108699:	89 e5                	mov    %esp,%ebp
8010869b:	53                   	push   %ebx
8010869c:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010869f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a6:	eb 6b                	jmp    80108713 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801086a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801086af:	eb 58                	jmp    80108709 <pci_init+0x71>
      for(int k=0;k<8;k++){
801086b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801086b8:	eb 45                	jmp    801086ff <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801086ba:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c3:	83 ec 0c             	sub    $0xc,%esp
801086c6:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801086c9:	53                   	push   %ebx
801086ca:	6a 00                	push   $0x0
801086cc:	51                   	push   %ecx
801086cd:	52                   	push   %edx
801086ce:	50                   	push   %eax
801086cf:	e8 b0 00 00 00       	call   80108784 <pci_access_config>
801086d4:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801086d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086da:	0f b7 c0             	movzwl %ax,%eax
801086dd:	3d ff ff 00 00       	cmp    $0xffff,%eax
801086e2:	74 17                	je     801086fb <pci_init+0x63>
        pci_init_device(i,j,k);
801086e4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801086e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	83 ec 04             	sub    $0x4,%esp
801086f0:	51                   	push   %ecx
801086f1:	52                   	push   %edx
801086f2:	50                   	push   %eax
801086f3:	e8 37 01 00 00       	call   8010882f <pci_init_device>
801086f8:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801086fb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801086ff:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108703:	7e b5                	jle    801086ba <pci_init+0x22>
    for(int j=0;j<32;j++){
80108705:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108709:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010870d:	7e a2                	jle    801086b1 <pci_init+0x19>
  for(int i=0;i<256;i++){
8010870f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108713:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010871a:	7e 8c                	jle    801086a8 <pci_init+0x10>
      }
      }
    }
  }
}
8010871c:	90                   	nop
8010871d:	90                   	nop
8010871e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108721:	c9                   	leave  
80108722:	c3                   	ret    

80108723 <pci_write_config>:

void pci_write_config(uint config){
80108723:	55                   	push   %ebp
80108724:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108726:	8b 45 08             	mov    0x8(%ebp),%eax
80108729:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010872e:	89 c0                	mov    %eax,%eax
80108730:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108731:	90                   	nop
80108732:	5d                   	pop    %ebp
80108733:	c3                   	ret    

80108734 <pci_write_data>:

void pci_write_data(uint config){
80108734:	55                   	push   %ebp
80108735:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108737:	8b 45 08             	mov    0x8(%ebp),%eax
8010873a:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010873f:	89 c0                	mov    %eax,%eax
80108741:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108742:	90                   	nop
80108743:	5d                   	pop    %ebp
80108744:	c3                   	ret    

80108745 <pci_read_config>:
uint pci_read_config(){
80108745:	55                   	push   %ebp
80108746:	89 e5                	mov    %esp,%ebp
80108748:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010874b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108750:	ed                   	in     (%dx),%eax
80108751:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108754:	83 ec 0c             	sub    $0xc,%esp
80108757:	68 c8 00 00 00       	push   $0xc8
8010875c:	e8 bb a8 ff ff       	call   8010301c <microdelay>
80108761:	83 c4 10             	add    $0x10,%esp
  return data;
80108764:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108767:	c9                   	leave  
80108768:	c3                   	ret    

80108769 <pci_test>:


void pci_test(){
80108769:	55                   	push   %ebp
8010876a:	89 e5                	mov    %esp,%ebp
8010876c:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010876f:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108776:	ff 75 fc             	push   -0x4(%ebp)
80108779:	e8 a5 ff ff ff       	call   80108723 <pci_write_config>
8010877e:	83 c4 04             	add    $0x4,%esp
}
80108781:	90                   	nop
80108782:	c9                   	leave  
80108783:	c3                   	ret    

80108784 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108784:	55                   	push   %ebp
80108785:	89 e5                	mov    %esp,%ebp
80108787:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010878a:	8b 45 08             	mov    0x8(%ebp),%eax
8010878d:	c1 e0 10             	shl    $0x10,%eax
80108790:	25 00 00 ff 00       	and    $0xff0000,%eax
80108795:	89 c2                	mov    %eax,%edx
80108797:	8b 45 0c             	mov    0xc(%ebp),%eax
8010879a:	c1 e0 0b             	shl    $0xb,%eax
8010879d:	0f b7 c0             	movzwl %ax,%eax
801087a0:	09 c2                	or     %eax,%edx
801087a2:	8b 45 10             	mov    0x10(%ebp),%eax
801087a5:	c1 e0 08             	shl    $0x8,%eax
801087a8:	25 00 07 00 00       	and    $0x700,%eax
801087ad:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087af:	8b 45 14             	mov    0x14(%ebp),%eax
801087b2:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087b7:	09 d0                	or     %edx,%eax
801087b9:	0d 00 00 00 80       	or     $0x80000000,%eax
801087be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801087c1:	ff 75 f4             	push   -0xc(%ebp)
801087c4:	e8 5a ff ff ff       	call   80108723 <pci_write_config>
801087c9:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801087cc:	e8 74 ff ff ff       	call   80108745 <pci_read_config>
801087d1:	8b 55 18             	mov    0x18(%ebp),%edx
801087d4:	89 02                	mov    %eax,(%edx)
}
801087d6:	90                   	nop
801087d7:	c9                   	leave  
801087d8:	c3                   	ret    

801087d9 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801087d9:	55                   	push   %ebp
801087da:	89 e5                	mov    %esp,%ebp
801087dc:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087df:	8b 45 08             	mov    0x8(%ebp),%eax
801087e2:	c1 e0 10             	shl    $0x10,%eax
801087e5:	25 00 00 ff 00       	and    $0xff0000,%eax
801087ea:	89 c2                	mov    %eax,%edx
801087ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801087ef:	c1 e0 0b             	shl    $0xb,%eax
801087f2:	0f b7 c0             	movzwl %ax,%eax
801087f5:	09 c2                	or     %eax,%edx
801087f7:	8b 45 10             	mov    0x10(%ebp),%eax
801087fa:	c1 e0 08             	shl    $0x8,%eax
801087fd:	25 00 07 00 00       	and    $0x700,%eax
80108802:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108804:	8b 45 14             	mov    0x14(%ebp),%eax
80108807:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010880c:	09 d0                	or     %edx,%eax
8010880e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108813:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108816:	ff 75 fc             	push   -0x4(%ebp)
80108819:	e8 05 ff ff ff       	call   80108723 <pci_write_config>
8010881e:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108821:	ff 75 18             	push   0x18(%ebp)
80108824:	e8 0b ff ff ff       	call   80108734 <pci_write_data>
80108829:	83 c4 04             	add    $0x4,%esp
}
8010882c:	90                   	nop
8010882d:	c9                   	leave  
8010882e:	c3                   	ret    

8010882f <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010882f:	55                   	push   %ebp
80108830:	89 e5                	mov    %esp,%ebp
80108832:	53                   	push   %ebx
80108833:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108836:	8b 45 08             	mov    0x8(%ebp),%eax
80108839:	a2 a4 9c 11 80       	mov    %al,0x80119ca4
  dev.device_num = device_num;
8010883e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108841:	a2 a5 9c 11 80       	mov    %al,0x80119ca5
  dev.function_num = function_num;
80108846:	8b 45 10             	mov    0x10(%ebp),%eax
80108849:	a2 a6 9c 11 80       	mov    %al,0x80119ca6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010884e:	ff 75 10             	push   0x10(%ebp)
80108851:	ff 75 0c             	push   0xc(%ebp)
80108854:	ff 75 08             	push   0x8(%ebp)
80108857:	68 a4 c3 10 80       	push   $0x8010c3a4
8010885c:	e8 93 7b ff ff       	call   801003f4 <cprintf>
80108861:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108864:	83 ec 0c             	sub    $0xc,%esp
80108867:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010886a:	50                   	push   %eax
8010886b:	6a 00                	push   $0x0
8010886d:	ff 75 10             	push   0x10(%ebp)
80108870:	ff 75 0c             	push   0xc(%ebp)
80108873:	ff 75 08             	push   0x8(%ebp)
80108876:	e8 09 ff ff ff       	call   80108784 <pci_access_config>
8010887b:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010887e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108881:	c1 e8 10             	shr    $0x10,%eax
80108884:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108887:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888a:	25 ff ff 00 00       	and    $0xffff,%eax
8010888f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108895:	a3 a8 9c 11 80       	mov    %eax,0x80119ca8
  dev.vendor_id = vendor_id;
8010889a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010889d:	a3 ac 9c 11 80       	mov    %eax,0x80119cac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801088a2:	83 ec 04             	sub    $0x4,%esp
801088a5:	ff 75 f0             	push   -0x10(%ebp)
801088a8:	ff 75 f4             	push   -0xc(%ebp)
801088ab:	68 d8 c3 10 80       	push   $0x8010c3d8
801088b0:	e8 3f 7b ff ff       	call   801003f4 <cprintf>
801088b5:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801088b8:	83 ec 0c             	sub    $0xc,%esp
801088bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088be:	50                   	push   %eax
801088bf:	6a 08                	push   $0x8
801088c1:	ff 75 10             	push   0x10(%ebp)
801088c4:	ff 75 0c             	push   0xc(%ebp)
801088c7:	ff 75 08             	push   0x8(%ebp)
801088ca:	e8 b5 fe ff ff       	call   80108784 <pci_access_config>
801088cf:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d5:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801088d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088db:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088de:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801088e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e4:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088e7:	0f b6 c0             	movzbl %al,%eax
801088ea:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801088ed:	c1 eb 18             	shr    $0x18,%ebx
801088f0:	83 ec 0c             	sub    $0xc,%esp
801088f3:	51                   	push   %ecx
801088f4:	52                   	push   %edx
801088f5:	50                   	push   %eax
801088f6:	53                   	push   %ebx
801088f7:	68 fc c3 10 80       	push   $0x8010c3fc
801088fc:	e8 f3 7a ff ff       	call   801003f4 <cprintf>
80108901:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108904:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108907:	c1 e8 18             	shr    $0x18,%eax
8010890a:	a2 b0 9c 11 80       	mov    %al,0x80119cb0
  dev.sub_class = (data>>16)&0xFF;
8010890f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108912:	c1 e8 10             	shr    $0x10,%eax
80108915:	a2 b1 9c 11 80       	mov    %al,0x80119cb1
  dev.interface = (data>>8)&0xFF;
8010891a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010891d:	c1 e8 08             	shr    $0x8,%eax
80108920:	a2 b2 9c 11 80       	mov    %al,0x80119cb2
  dev.revision_id = data&0xFF;
80108925:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108928:	a2 b3 9c 11 80       	mov    %al,0x80119cb3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010892d:	83 ec 0c             	sub    $0xc,%esp
80108930:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108933:	50                   	push   %eax
80108934:	6a 10                	push   $0x10
80108936:	ff 75 10             	push   0x10(%ebp)
80108939:	ff 75 0c             	push   0xc(%ebp)
8010893c:	ff 75 08             	push   0x8(%ebp)
8010893f:	e8 40 fe ff ff       	call   80108784 <pci_access_config>
80108944:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108947:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894a:	a3 b4 9c 11 80       	mov    %eax,0x80119cb4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010894f:	83 ec 0c             	sub    $0xc,%esp
80108952:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108955:	50                   	push   %eax
80108956:	6a 14                	push   $0x14
80108958:	ff 75 10             	push   0x10(%ebp)
8010895b:	ff 75 0c             	push   0xc(%ebp)
8010895e:	ff 75 08             	push   0x8(%ebp)
80108961:	e8 1e fe ff ff       	call   80108784 <pci_access_config>
80108966:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108969:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896c:	a3 b8 9c 11 80       	mov    %eax,0x80119cb8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108971:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108978:	75 5a                	jne    801089d4 <pci_init_device+0x1a5>
8010897a:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108981:	75 51                	jne    801089d4 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108983:	83 ec 0c             	sub    $0xc,%esp
80108986:	68 41 c4 10 80       	push   $0x8010c441
8010898b:	e8 64 7a ff ff       	call   801003f4 <cprintf>
80108990:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108993:	83 ec 0c             	sub    $0xc,%esp
80108996:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108999:	50                   	push   %eax
8010899a:	68 f0 00 00 00       	push   $0xf0
8010899f:	ff 75 10             	push   0x10(%ebp)
801089a2:	ff 75 0c             	push   0xc(%ebp)
801089a5:	ff 75 08             	push   0x8(%ebp)
801089a8:	e8 d7 fd ff ff       	call   80108784 <pci_access_config>
801089ad:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801089b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b3:	83 ec 08             	sub    $0x8,%esp
801089b6:	50                   	push   %eax
801089b7:	68 5b c4 10 80       	push   $0x8010c45b
801089bc:	e8 33 7a ff ff       	call   801003f4 <cprintf>
801089c1:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801089c4:	83 ec 0c             	sub    $0xc,%esp
801089c7:	68 a4 9c 11 80       	push   $0x80119ca4
801089cc:	e8 09 00 00 00       	call   801089da <i8254_init>
801089d1:	83 c4 10             	add    $0x10,%esp
  }
}
801089d4:	90                   	nop
801089d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089d8:	c9                   	leave  
801089d9:	c3                   	ret    

801089da <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801089da:	55                   	push   %ebp
801089db:	89 e5                	mov    %esp,%ebp
801089dd:	53                   	push   %ebx
801089de:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801089e1:	8b 45 08             	mov    0x8(%ebp),%eax
801089e4:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801089e8:	0f b6 c8             	movzbl %al,%ecx
801089eb:	8b 45 08             	mov    0x8(%ebp),%eax
801089ee:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089f2:	0f b6 d0             	movzbl %al,%edx
801089f5:	8b 45 08             	mov    0x8(%ebp),%eax
801089f8:	0f b6 00             	movzbl (%eax),%eax
801089fb:	0f b6 c0             	movzbl %al,%eax
801089fe:	83 ec 0c             	sub    $0xc,%esp
80108a01:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a04:	53                   	push   %ebx
80108a05:	6a 04                	push   $0x4
80108a07:	51                   	push   %ecx
80108a08:	52                   	push   %edx
80108a09:	50                   	push   %eax
80108a0a:	e8 75 fd ff ff       	call   80108784 <pci_access_config>
80108a0f:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a15:	83 c8 04             	or     $0x4,%eax
80108a18:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108a1b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a21:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a25:	0f b6 c8             	movzbl %al,%ecx
80108a28:	8b 45 08             	mov    0x8(%ebp),%eax
80108a2b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a2f:	0f b6 d0             	movzbl %al,%edx
80108a32:	8b 45 08             	mov    0x8(%ebp),%eax
80108a35:	0f b6 00             	movzbl (%eax),%eax
80108a38:	0f b6 c0             	movzbl %al,%eax
80108a3b:	83 ec 0c             	sub    $0xc,%esp
80108a3e:	53                   	push   %ebx
80108a3f:	6a 04                	push   $0x4
80108a41:	51                   	push   %ecx
80108a42:	52                   	push   %edx
80108a43:	50                   	push   %eax
80108a44:	e8 90 fd ff ff       	call   801087d9 <pci_write_config_register>
80108a49:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a4f:	8b 40 10             	mov    0x10(%eax),%eax
80108a52:	05 00 00 00 40       	add    $0x40000000,%eax
80108a57:	a3 bc 9c 11 80       	mov    %eax,0x80119cbc
  uint *ctrl = (uint *)base_addr;
80108a5c:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108a64:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108a69:	05 d8 00 00 00       	add    $0xd8,%eax
80108a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a74:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7d:	8b 00                	mov    (%eax),%eax
80108a7f:	0d 00 00 00 04       	or     $0x4000000,%eax
80108a84:	89 c2                	mov    %eax,%edx
80108a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a89:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a8e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a97:	8b 00                	mov    (%eax),%eax
80108a99:	83 c8 40             	or     $0x40,%eax
80108a9c:	89 c2                	mov    %eax,%edx
80108a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa1:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa6:	8b 10                	mov    (%eax),%edx
80108aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aab:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108aad:	83 ec 0c             	sub    $0xc,%esp
80108ab0:	68 70 c4 10 80       	push   $0x8010c470
80108ab5:	e8 3a 79 ff ff       	call   801003f4 <cprintf>
80108aba:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108abd:	e8 c3 a1 ff ff       	call   80102c85 <kalloc>
80108ac2:	a3 c8 9c 11 80       	mov    %eax,0x80119cc8
  *intr_addr = 0;
80108ac7:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108acc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108ad2:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80108ad7:	83 ec 08             	sub    $0x8,%esp
80108ada:	50                   	push   %eax
80108adb:	68 92 c4 10 80       	push   $0x8010c492
80108ae0:	e8 0f 79 ff ff       	call   801003f4 <cprintf>
80108ae5:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108ae8:	e8 50 00 00 00       	call   80108b3d <i8254_init_recv>
  i8254_init_send();
80108aed:	e8 69 03 00 00       	call   80108e5b <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108af2:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108af9:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108afc:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b03:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b06:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b0d:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b10:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b17:	0f b6 c0             	movzbl %al,%eax
80108b1a:	83 ec 0c             	sub    $0xc,%esp
80108b1d:	53                   	push   %ebx
80108b1e:	51                   	push   %ecx
80108b1f:	52                   	push   %edx
80108b20:	50                   	push   %eax
80108b21:	68 a0 c4 10 80       	push   $0x8010c4a0
80108b26:	e8 c9 78 ff ff       	call   801003f4 <cprintf>
80108b2b:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b37:	90                   	nop
80108b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b3b:	c9                   	leave  
80108b3c:	c3                   	ret    

80108b3d <i8254_init_recv>:

void i8254_init_recv(){
80108b3d:	55                   	push   %ebp
80108b3e:	89 e5                	mov    %esp,%ebp
80108b40:	57                   	push   %edi
80108b41:	56                   	push   %esi
80108b42:	53                   	push   %ebx
80108b43:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b46:	83 ec 0c             	sub    $0xc,%esp
80108b49:	6a 00                	push   $0x0
80108b4b:	e8 e8 04 00 00       	call   80109038 <i8254_read_eeprom>
80108b50:	83 c4 10             	add    $0x10,%esp
80108b53:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108b56:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b59:	a2 c0 9c 11 80       	mov    %al,0x80119cc0
  mac_addr[1] = data_l>>8;
80108b5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b61:	c1 e8 08             	shr    $0x8,%eax
80108b64:	a2 c1 9c 11 80       	mov    %al,0x80119cc1
  uint data_m = i8254_read_eeprom(0x1);
80108b69:	83 ec 0c             	sub    $0xc,%esp
80108b6c:	6a 01                	push   $0x1
80108b6e:	e8 c5 04 00 00       	call   80109038 <i8254_read_eeprom>
80108b73:	83 c4 10             	add    $0x10,%esp
80108b76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108b79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b7c:	a2 c2 9c 11 80       	mov    %al,0x80119cc2
  mac_addr[3] = data_m>>8;
80108b81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b84:	c1 e8 08             	shr    $0x8,%eax
80108b87:	a2 c3 9c 11 80       	mov    %al,0x80119cc3
  uint data_h = i8254_read_eeprom(0x2);
80108b8c:	83 ec 0c             	sub    $0xc,%esp
80108b8f:	6a 02                	push   $0x2
80108b91:	e8 a2 04 00 00       	call   80109038 <i8254_read_eeprom>
80108b96:	83 c4 10             	add    $0x10,%esp
80108b99:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108b9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b9f:	a2 c4 9c 11 80       	mov    %al,0x80119cc4
  mac_addr[5] = data_h>>8;
80108ba4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ba7:	c1 e8 08             	shr    $0x8,%eax
80108baa:	a2 c5 9c 11 80       	mov    %al,0x80119cc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108baf:	0f b6 05 c5 9c 11 80 	movzbl 0x80119cc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bb6:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108bb9:	0f b6 05 c4 9c 11 80 	movzbl 0x80119cc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bc0:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108bc3:	0f b6 05 c3 9c 11 80 	movzbl 0x80119cc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bca:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108bcd:	0f b6 05 c2 9c 11 80 	movzbl 0x80119cc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bd4:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108bd7:	0f b6 05 c1 9c 11 80 	movzbl 0x80119cc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bde:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108be1:	0f b6 05 c0 9c 11 80 	movzbl 0x80119cc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108be8:	0f b6 c0             	movzbl %al,%eax
80108beb:	83 ec 04             	sub    $0x4,%esp
80108bee:	57                   	push   %edi
80108bef:	56                   	push   %esi
80108bf0:	53                   	push   %ebx
80108bf1:	51                   	push   %ecx
80108bf2:	52                   	push   %edx
80108bf3:	50                   	push   %eax
80108bf4:	68 b8 c4 10 80       	push   $0x8010c4b8
80108bf9:	e8 f6 77 ff ff       	call   801003f4 <cprintf>
80108bfe:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c01:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c06:	05 00 54 00 00       	add    $0x5400,%eax
80108c0b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c0e:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c13:	05 04 54 00 00       	add    $0x5404,%eax
80108c18:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108c1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c1e:	c1 e0 10             	shl    $0x10,%eax
80108c21:	0b 45 d8             	or     -0x28(%ebp),%eax
80108c24:	89 c2                	mov    %eax,%edx
80108c26:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c29:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c2b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c2e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c33:	89 c2                	mov    %eax,%edx
80108c35:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c38:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c3a:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c3f:	05 00 52 00 00       	add    $0x5200,%eax
80108c44:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c4e:	eb 19                	jmp    80108c69 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108c50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c53:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c5a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c5d:	01 d0                	add    %edx,%eax
80108c5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108c65:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108c69:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108c6d:	7e e1                	jle    80108c50 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108c6f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c74:	05 d0 00 00 00       	add    $0xd0,%eax
80108c79:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c7c:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108c7f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108c85:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108c8a:	05 c8 00 00 00       	add    $0xc8,%eax
80108c8f:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c92:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108c95:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108c9b:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ca0:	05 28 28 00 00       	add    $0x2828,%eax
80108ca5:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108ca8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108cb1:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108cb6:	05 00 01 00 00       	add    $0x100,%eax
80108cbb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108cbe:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cc1:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108cc7:	e8 b9 9f ff ff       	call   80102c85 <kalloc>
80108ccc:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ccf:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108cd4:	05 00 28 00 00       	add    $0x2800,%eax
80108cd9:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108cdc:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ce1:	05 04 28 00 00       	add    $0x2804,%eax
80108ce6:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108ce9:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108cee:	05 08 28 00 00       	add    $0x2808,%eax
80108cf3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108cf6:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108cfb:	05 10 28 00 00       	add    $0x2810,%eax
80108d00:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d03:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108d08:	05 18 28 00 00       	add    $0x2818,%eax
80108d0d:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d10:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d13:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d19:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108d1c:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108d1e:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108d21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d27:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d2a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d30:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d39:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d3c:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d42:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d45:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d48:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d4f:	eb 73                	jmp    80108dc4 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d54:	c1 e0 04             	shl    $0x4,%eax
80108d57:	89 c2                	mov    %eax,%edx
80108d59:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d5c:	01 d0                	add    %edx,%eax
80108d5e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d68:	c1 e0 04             	shl    $0x4,%eax
80108d6b:	89 c2                	mov    %eax,%edx
80108d6d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d70:	01 d0                	add    %edx,%eax
80108d72:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d7b:	c1 e0 04             	shl    $0x4,%eax
80108d7e:	89 c2                	mov    %eax,%edx
80108d80:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d83:	01 d0                	add    %edx,%eax
80108d85:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d8e:	c1 e0 04             	shl    $0x4,%eax
80108d91:	89 c2                	mov    %eax,%edx
80108d93:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d96:	01 d0                	add    %edx,%eax
80108d98:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d9f:	c1 e0 04             	shl    $0x4,%eax
80108da2:	89 c2                	mov    %eax,%edx
80108da4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108da7:	01 d0                	add    %edx,%eax
80108da9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108dad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db0:	c1 e0 04             	shl    $0x4,%eax
80108db3:	89 c2                	mov    %eax,%edx
80108db5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108db8:	01 d0                	add    %edx,%eax
80108dba:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108dc0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108dc4:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108dcb:	7e 84                	jle    80108d51 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108dcd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108dd4:	eb 57                	jmp    80108e2d <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108dd6:	e8 aa 9e ff ff       	call   80102c85 <kalloc>
80108ddb:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108dde:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108de2:	75 12                	jne    80108df6 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108de4:	83 ec 0c             	sub    $0xc,%esp
80108de7:	68 d8 c4 10 80       	push   $0x8010c4d8
80108dec:	e8 03 76 ff ff       	call   801003f4 <cprintf>
80108df1:	83 c4 10             	add    $0x10,%esp
      break;
80108df4:	eb 3d                	jmp    80108e33 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108df6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108df9:	c1 e0 04             	shl    $0x4,%eax
80108dfc:	89 c2                	mov    %eax,%edx
80108dfe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e01:	01 d0                	add    %edx,%eax
80108e03:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e06:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e0c:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e11:	83 c0 01             	add    $0x1,%eax
80108e14:	c1 e0 04             	shl    $0x4,%eax
80108e17:	89 c2                	mov    %eax,%edx
80108e19:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e1c:	01 d0                	add    %edx,%eax
80108e1e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e21:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e27:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e29:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e2d:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e31:	7e a3                	jle    80108dd6 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108e33:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e36:	8b 00                	mov    (%eax),%eax
80108e38:	83 c8 02             	or     $0x2,%eax
80108e3b:	89 c2                	mov    %eax,%edx
80108e3d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e40:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e42:	83 ec 0c             	sub    $0xc,%esp
80108e45:	68 f8 c4 10 80       	push   $0x8010c4f8
80108e4a:	e8 a5 75 ff ff       	call   801003f4 <cprintf>
80108e4f:	83 c4 10             	add    $0x10,%esp
}
80108e52:	90                   	nop
80108e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108e56:	5b                   	pop    %ebx
80108e57:	5e                   	pop    %esi
80108e58:	5f                   	pop    %edi
80108e59:	5d                   	pop    %ebp
80108e5a:	c3                   	ret    

80108e5b <i8254_init_send>:

void i8254_init_send(){
80108e5b:	55                   	push   %ebp
80108e5c:	89 e5                	mov    %esp,%ebp
80108e5e:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108e61:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e66:	05 28 38 00 00       	add    $0x3828,%eax
80108e6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108e6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e71:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108e77:	e8 09 9e ff ff       	call   80102c85 <kalloc>
80108e7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e7f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e84:	05 00 38 00 00       	add    $0x3800,%eax
80108e89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108e8c:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e91:	05 04 38 00 00       	add    $0x3804,%eax
80108e96:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108e99:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108e9e:	05 08 38 00 00       	add    $0x3808,%eax
80108ea3:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ea9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eb2:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108eb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108eb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108ebd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ec0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ec6:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ecb:	05 10 38 00 00       	add    $0x3810,%eax
80108ed0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ed3:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ed8:	05 18 38 00 00       	add    $0x3818,%eax
80108edd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108ee0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ee3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ee9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108eec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ef8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108eff:	e9 82 00 00 00       	jmp    80108f86 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f07:	c1 e0 04             	shl    $0x4,%eax
80108f0a:	89 c2                	mov    %eax,%edx
80108f0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f0f:	01 d0                	add    %edx,%eax
80108f11:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1b:	c1 e0 04             	shl    $0x4,%eax
80108f1e:	89 c2                	mov    %eax,%edx
80108f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f23:	01 d0                	add    %edx,%eax
80108f25:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2e:	c1 e0 04             	shl    $0x4,%eax
80108f31:	89 c2                	mov    %eax,%edx
80108f33:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f36:	01 d0                	add    %edx,%eax
80108f38:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3f:	c1 e0 04             	shl    $0x4,%eax
80108f42:	89 c2                	mov    %eax,%edx
80108f44:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f47:	01 d0                	add    %edx,%eax
80108f49:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f50:	c1 e0 04             	shl    $0x4,%eax
80108f53:	89 c2                	mov    %eax,%edx
80108f55:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f58:	01 d0                	add    %edx,%eax
80108f5a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f61:	c1 e0 04             	shl    $0x4,%eax
80108f64:	89 c2                	mov    %eax,%edx
80108f66:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f69:	01 d0                	add    %edx,%eax
80108f6b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f72:	c1 e0 04             	shl    $0x4,%eax
80108f75:	89 c2                	mov    %eax,%edx
80108f77:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f7a:	01 d0                	add    %edx,%eax
80108f7c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f82:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f86:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f8d:	0f 8e 71 ff ff ff    	jle    80108f04 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f9a:	eb 57                	jmp    80108ff3 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108f9c:	e8 e4 9c ff ff       	call   80102c85 <kalloc>
80108fa1:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108fa4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108fa8:	75 12                	jne    80108fbc <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108faa:	83 ec 0c             	sub    $0xc,%esp
80108fad:	68 d8 c4 10 80       	push   $0x8010c4d8
80108fb2:	e8 3d 74 ff ff       	call   801003f4 <cprintf>
80108fb7:	83 c4 10             	add    $0x10,%esp
      break;
80108fba:	eb 3d                	jmp    80108ff9 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fbf:	c1 e0 04             	shl    $0x4,%eax
80108fc2:	89 c2                	mov    %eax,%edx
80108fc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fc7:	01 d0                	add    %edx,%eax
80108fc9:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108fcc:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108fd2:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd7:	83 c0 01             	add    $0x1,%eax
80108fda:	c1 e0 04             	shl    $0x4,%eax
80108fdd:	89 c2                	mov    %eax,%edx
80108fdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fe2:	01 d0                	add    %edx,%eax
80108fe4:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108fe7:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108fed:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fef:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ff3:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108ff7:	7e a3                	jle    80108f9c <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108ff9:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80108ffe:	05 00 04 00 00       	add    $0x400,%eax
80109003:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109006:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109009:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010900f:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109014:	05 10 04 00 00       	add    $0x410,%eax
80109019:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010901c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010901f:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109025:	83 ec 0c             	sub    $0xc,%esp
80109028:	68 18 c5 10 80       	push   $0x8010c518
8010902d:	e8 c2 73 ff ff       	call   801003f4 <cprintf>
80109032:	83 c4 10             	add    $0x10,%esp

}
80109035:	90                   	nop
80109036:	c9                   	leave  
80109037:	c3                   	ret    

80109038 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109038:	55                   	push   %ebp
80109039:	89 e5                	mov    %esp,%ebp
8010903b:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010903e:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109043:	83 c0 14             	add    $0x14,%eax
80109046:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109049:	8b 45 08             	mov    0x8(%ebp),%eax
8010904c:	c1 e0 08             	shl    $0x8,%eax
8010904f:	0f b7 c0             	movzwl %ax,%eax
80109052:	83 c8 01             	or     $0x1,%eax
80109055:	89 c2                	mov    %eax,%edx
80109057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905a:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010905c:	83 ec 0c             	sub    $0xc,%esp
8010905f:	68 38 c5 10 80       	push   $0x8010c538
80109064:	e8 8b 73 ff ff       	call   801003f4 <cprintf>
80109069:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010906c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906f:	8b 00                	mov    (%eax),%eax
80109071:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109074:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109077:	83 e0 10             	and    $0x10,%eax
8010907a:	85 c0                	test   %eax,%eax
8010907c:	75 02                	jne    80109080 <i8254_read_eeprom+0x48>
  while(1){
8010907e:	eb dc                	jmp    8010905c <i8254_read_eeprom+0x24>
      break;
80109080:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109084:	8b 00                	mov    (%eax),%eax
80109086:	c1 e8 10             	shr    $0x10,%eax
}
80109089:	c9                   	leave  
8010908a:	c3                   	ret    

8010908b <i8254_recv>:
void i8254_recv(){
8010908b:	55                   	push   %ebp
8010908c:	89 e5                	mov    %esp,%ebp
8010908e:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109091:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109096:	05 10 28 00 00       	add    $0x2810,%eax
8010909b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010909e:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090a3:	05 18 28 00 00       	add    $0x2818,%eax
801090a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801090ab:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
801090b0:	05 00 28 00 00       	add    $0x2800,%eax
801090b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801090b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090bb:	8b 00                	mov    (%eax),%eax
801090bd:	05 00 00 00 80       	add    $0x80000000,%eax
801090c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801090c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c8:	8b 10                	mov    (%eax),%edx
801090ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090cd:	8b 08                	mov    (%eax),%ecx
801090cf:	89 d0                	mov    %edx,%eax
801090d1:	29 c8                	sub    %ecx,%eax
801090d3:	25 ff 00 00 00       	and    $0xff,%eax
801090d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801090db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801090df:	7e 37                	jle    80109118 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801090e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e4:	8b 00                	mov    (%eax),%eax
801090e6:	c1 e0 04             	shl    $0x4,%eax
801090e9:	89 c2                	mov    %eax,%edx
801090eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090ee:	01 d0                	add    %edx,%eax
801090f0:	8b 00                	mov    (%eax),%eax
801090f2:	05 00 00 00 80       	add    $0x80000000,%eax
801090f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801090fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fd:	8b 00                	mov    (%eax),%eax
801090ff:	83 c0 01             	add    $0x1,%eax
80109102:	0f b6 d0             	movzbl %al,%edx
80109105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109108:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010910a:	83 ec 0c             	sub    $0xc,%esp
8010910d:	ff 75 e0             	push   -0x20(%ebp)
80109110:	e8 15 09 00 00       	call   80109a2a <eth_proc>
80109115:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109118:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911b:	8b 10                	mov    (%eax),%edx
8010911d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109120:	8b 00                	mov    (%eax),%eax
80109122:	39 c2                	cmp    %eax,%edx
80109124:	75 9f                	jne    801090c5 <i8254_recv+0x3a>
      (*rdt)--;
80109126:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109129:	8b 00                	mov    (%eax),%eax
8010912b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010912e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109131:	89 10                	mov    %edx,(%eax)
  while(1){
80109133:	eb 90                	jmp    801090c5 <i8254_recv+0x3a>

80109135 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109135:	55                   	push   %ebp
80109136:	89 e5                	mov    %esp,%ebp
80109138:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010913b:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
80109140:	05 10 38 00 00       	add    $0x3810,%eax
80109145:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109148:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010914d:	05 18 38 00 00       	add    $0x3818,%eax
80109152:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109155:	a1 bc 9c 11 80       	mov    0x80119cbc,%eax
8010915a:	05 00 38 00 00       	add    $0x3800,%eax
8010915f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109162:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109165:	8b 00                	mov    (%eax),%eax
80109167:	05 00 00 00 80       	add    $0x80000000,%eax
8010916c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010916f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109172:	8b 10                	mov    (%eax),%edx
80109174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109177:	8b 08                	mov    (%eax),%ecx
80109179:	89 d0                	mov    %edx,%eax
8010917b:	29 c8                	sub    %ecx,%eax
8010917d:	0f b6 d0             	movzbl %al,%edx
80109180:	b8 00 01 00 00       	mov    $0x100,%eax
80109185:	29 d0                	sub    %edx,%eax
80109187:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010918a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918d:	8b 00                	mov    (%eax),%eax
8010918f:	25 ff 00 00 00       	and    $0xff,%eax
80109194:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109197:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010919b:	0f 8e a8 00 00 00    	jle    80109249 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801091a1:	8b 45 08             	mov    0x8(%ebp),%eax
801091a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801091a7:	89 d1                	mov    %edx,%ecx
801091a9:	c1 e1 04             	shl    $0x4,%ecx
801091ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
801091af:	01 ca                	add    %ecx,%edx
801091b1:	8b 12                	mov    (%edx),%edx
801091b3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091b9:	83 ec 04             	sub    $0x4,%esp
801091bc:	ff 75 0c             	push   0xc(%ebp)
801091bf:	50                   	push   %eax
801091c0:	52                   	push   %edx
801091c1:	e8 a1 be ff ff       	call   80105067 <memmove>
801091c6:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801091c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091cc:	c1 e0 04             	shl    $0x4,%eax
801091cf:	89 c2                	mov    %eax,%edx
801091d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091d4:	01 d0                	add    %edx,%eax
801091d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801091d9:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801091dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091e0:	c1 e0 04             	shl    $0x4,%eax
801091e3:	89 c2                	mov    %eax,%edx
801091e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091e8:	01 d0                	add    %edx,%eax
801091ea:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801091ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091f1:	c1 e0 04             	shl    $0x4,%eax
801091f4:	89 c2                	mov    %eax,%edx
801091f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091f9:	01 d0                	add    %edx,%eax
801091fb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801091ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109202:	c1 e0 04             	shl    $0x4,%eax
80109205:	89 c2                	mov    %eax,%edx
80109207:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010920a:	01 d0                	add    %edx,%eax
8010920c:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109210:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109213:	c1 e0 04             	shl    $0x4,%eax
80109216:	89 c2                	mov    %eax,%edx
80109218:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010921b:	01 d0                	add    %edx,%eax
8010921d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109223:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109226:	c1 e0 04             	shl    $0x4,%eax
80109229:	89 c2                	mov    %eax,%edx
8010922b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010922e:	01 d0                	add    %edx,%eax
80109230:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109237:	8b 00                	mov    (%eax),%eax
80109239:	83 c0 01             	add    $0x1,%eax
8010923c:	0f b6 d0             	movzbl %al,%edx
8010923f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109242:	89 10                	mov    %edx,(%eax)
    return len;
80109244:	8b 45 0c             	mov    0xc(%ebp),%eax
80109247:	eb 05                	jmp    8010924e <i8254_send+0x119>
  }else{
    return -1;
80109249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010924e:	c9                   	leave  
8010924f:	c3                   	ret    

80109250 <i8254_intr>:

void i8254_intr(){
80109250:	55                   	push   %ebp
80109251:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109253:	a1 c8 9c 11 80       	mov    0x80119cc8,%eax
80109258:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010925e:	90                   	nop
8010925f:	5d                   	pop    %ebp
80109260:	c3                   	ret    

80109261 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109261:	55                   	push   %ebp
80109262:	89 e5                	mov    %esp,%ebp
80109264:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109267:	8b 45 08             	mov    0x8(%ebp),%eax
8010926a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
8010926d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109270:	0f b7 00             	movzwl (%eax),%eax
80109273:	66 3d 00 01          	cmp    $0x100,%ax
80109277:	74 0a                	je     80109283 <arp_proc+0x22>
80109279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010927e:	e9 4f 01 00 00       	jmp    801093d2 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109286:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010928a:	66 83 f8 08          	cmp    $0x8,%ax
8010928e:	74 0a                	je     8010929a <arp_proc+0x39>
80109290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109295:	e9 38 01 00 00       	jmp    801093d2 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010929a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010929d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801092a1:	3c 06                	cmp    $0x6,%al
801092a3:	74 0a                	je     801092af <arp_proc+0x4e>
801092a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092aa:	e9 23 01 00 00       	jmp    801093d2 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
801092af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b2:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801092b6:	3c 04                	cmp    $0x4,%al
801092b8:	74 0a                	je     801092c4 <arp_proc+0x63>
801092ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092bf:	e9 0e 01 00 00       	jmp    801093d2 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801092c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c7:	83 c0 18             	add    $0x18,%eax
801092ca:	83 ec 04             	sub    $0x4,%esp
801092cd:	6a 04                	push   $0x4
801092cf:	50                   	push   %eax
801092d0:	68 e4 f4 10 80       	push   $0x8010f4e4
801092d5:	e8 35 bd ff ff       	call   8010500f <memcmp>
801092da:	83 c4 10             	add    $0x10,%esp
801092dd:	85 c0                	test   %eax,%eax
801092df:	74 27                	je     80109308 <arp_proc+0xa7>
801092e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e4:	83 c0 0e             	add    $0xe,%eax
801092e7:	83 ec 04             	sub    $0x4,%esp
801092ea:	6a 04                	push   $0x4
801092ec:	50                   	push   %eax
801092ed:	68 e4 f4 10 80       	push   $0x8010f4e4
801092f2:	e8 18 bd ff ff       	call   8010500f <memcmp>
801092f7:	83 c4 10             	add    $0x10,%esp
801092fa:	85 c0                	test   %eax,%eax
801092fc:	74 0a                	je     80109308 <arp_proc+0xa7>
801092fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109303:	e9 ca 00 00 00       	jmp    801093d2 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010930f:	66 3d 00 01          	cmp    $0x100,%ax
80109313:	75 69                	jne    8010937e <arp_proc+0x11d>
80109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109318:	83 c0 18             	add    $0x18,%eax
8010931b:	83 ec 04             	sub    $0x4,%esp
8010931e:	6a 04                	push   $0x4
80109320:	50                   	push   %eax
80109321:	68 e4 f4 10 80       	push   $0x8010f4e4
80109326:	e8 e4 bc ff ff       	call   8010500f <memcmp>
8010932b:	83 c4 10             	add    $0x10,%esp
8010932e:	85 c0                	test   %eax,%eax
80109330:	75 4c                	jne    8010937e <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109332:	e8 4e 99 ff ff       	call   80102c85 <kalloc>
80109337:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010933a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109341:	83 ec 04             	sub    $0x4,%esp
80109344:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109347:	50                   	push   %eax
80109348:	ff 75 f0             	push   -0x10(%ebp)
8010934b:	ff 75 f4             	push   -0xc(%ebp)
8010934e:	e8 1f 04 00 00       	call   80109772 <arp_reply_pkt_create>
80109353:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109356:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109359:	83 ec 08             	sub    $0x8,%esp
8010935c:	50                   	push   %eax
8010935d:	ff 75 f0             	push   -0x10(%ebp)
80109360:	e8 d0 fd ff ff       	call   80109135 <i8254_send>
80109365:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936b:	83 ec 0c             	sub    $0xc,%esp
8010936e:	50                   	push   %eax
8010936f:	e8 77 98 ff ff       	call   80102beb <kfree>
80109374:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109377:	b8 02 00 00 00       	mov    $0x2,%eax
8010937c:	eb 54                	jmp    801093d2 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010937e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109381:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109385:	66 3d 00 02          	cmp    $0x200,%ax
80109389:	75 42                	jne    801093cd <arp_proc+0x16c>
8010938b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938e:	83 c0 18             	add    $0x18,%eax
80109391:	83 ec 04             	sub    $0x4,%esp
80109394:	6a 04                	push   $0x4
80109396:	50                   	push   %eax
80109397:	68 e4 f4 10 80       	push   $0x8010f4e4
8010939c:	e8 6e bc ff ff       	call   8010500f <memcmp>
801093a1:	83 c4 10             	add    $0x10,%esp
801093a4:	85 c0                	test   %eax,%eax
801093a6:	75 25                	jne    801093cd <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801093a8:	83 ec 0c             	sub    $0xc,%esp
801093ab:	68 3c c5 10 80       	push   $0x8010c53c
801093b0:	e8 3f 70 ff ff       	call   801003f4 <cprintf>
801093b5:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801093b8:	83 ec 0c             	sub    $0xc,%esp
801093bb:	ff 75 f4             	push   -0xc(%ebp)
801093be:	e8 af 01 00 00       	call   80109572 <arp_table_update>
801093c3:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801093c6:	b8 01 00 00 00       	mov    $0x1,%eax
801093cb:	eb 05                	jmp    801093d2 <arp_proc+0x171>
  }else{
    return -1;
801093cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801093d2:	c9                   	leave  
801093d3:	c3                   	ret    

801093d4 <arp_scan>:

void arp_scan(){
801093d4:	55                   	push   %ebp
801093d5:	89 e5                	mov    %esp,%ebp
801093d7:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801093da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093e1:	eb 6f                	jmp    80109452 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801093e3:	e8 9d 98 ff ff       	call   80102c85 <kalloc>
801093e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801093eb:	83 ec 04             	sub    $0x4,%esp
801093ee:	ff 75 f4             	push   -0xc(%ebp)
801093f1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801093f4:	50                   	push   %eax
801093f5:	ff 75 ec             	push   -0x14(%ebp)
801093f8:	e8 62 00 00 00       	call   8010945f <arp_broadcast>
801093fd:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109400:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109403:	83 ec 08             	sub    $0x8,%esp
80109406:	50                   	push   %eax
80109407:	ff 75 ec             	push   -0x14(%ebp)
8010940a:	e8 26 fd ff ff       	call   80109135 <i8254_send>
8010940f:	83 c4 10             	add    $0x10,%esp
80109412:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109415:	eb 22                	jmp    80109439 <arp_scan+0x65>
      microdelay(1);
80109417:	83 ec 0c             	sub    $0xc,%esp
8010941a:	6a 01                	push   $0x1
8010941c:	e8 fb 9b ff ff       	call   8010301c <microdelay>
80109421:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109424:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109427:	83 ec 08             	sub    $0x8,%esp
8010942a:	50                   	push   %eax
8010942b:	ff 75 ec             	push   -0x14(%ebp)
8010942e:	e8 02 fd ff ff       	call   80109135 <i8254_send>
80109433:	83 c4 10             	add    $0x10,%esp
80109436:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109439:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010943d:	74 d8                	je     80109417 <arp_scan+0x43>
    }
    kfree((char *)send);
8010943f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109442:	83 ec 0c             	sub    $0xc,%esp
80109445:	50                   	push   %eax
80109446:	e8 a0 97 ff ff       	call   80102beb <kfree>
8010944b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010944e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109452:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109459:	7e 88                	jle    801093e3 <arp_scan+0xf>
  }
}
8010945b:	90                   	nop
8010945c:	90                   	nop
8010945d:	c9                   	leave  
8010945e:	c3                   	ret    

8010945f <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010945f:	55                   	push   %ebp
80109460:	89 e5                	mov    %esp,%ebp
80109462:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109465:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109469:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010946d:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109471:	8b 45 10             	mov    0x10(%ebp),%eax
80109474:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109477:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010947e:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109484:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010948b:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109491:	8b 45 0c             	mov    0xc(%ebp),%eax
80109494:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010949a:	8b 45 08             	mov    0x8(%ebp),%eax
8010949d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801094a0:	8b 45 08             	mov    0x8(%ebp),%eax
801094a3:	83 c0 0e             	add    $0xe,%eax
801094a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801094a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ac:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801094b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b3:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801094b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ba:	83 ec 04             	sub    $0x4,%esp
801094bd:	6a 06                	push   $0x6
801094bf:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801094c2:	52                   	push   %edx
801094c3:	50                   	push   %eax
801094c4:	e8 9e bb ff ff       	call   80105067 <memmove>
801094c9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801094cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cf:	83 c0 06             	add    $0x6,%eax
801094d2:	83 ec 04             	sub    $0x4,%esp
801094d5:	6a 06                	push   $0x6
801094d7:	68 c0 9c 11 80       	push   $0x80119cc0
801094dc:	50                   	push   %eax
801094dd:	e8 85 bb ff ff       	call   80105067 <memmove>
801094e2:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801094e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e8:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801094ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f0:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801094f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f9:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801094fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109500:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109507:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010950d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109510:	8d 50 12             	lea    0x12(%eax),%edx
80109513:	83 ec 04             	sub    $0x4,%esp
80109516:	6a 06                	push   $0x6
80109518:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010951b:	50                   	push   %eax
8010951c:	52                   	push   %edx
8010951d:	e8 45 bb ff ff       	call   80105067 <memmove>
80109522:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109528:	8d 50 18             	lea    0x18(%eax),%edx
8010952b:	83 ec 04             	sub    $0x4,%esp
8010952e:	6a 04                	push   $0x4
80109530:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109533:	50                   	push   %eax
80109534:	52                   	push   %edx
80109535:	e8 2d bb ff ff       	call   80105067 <memmove>
8010953a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010953d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109540:	83 c0 08             	add    $0x8,%eax
80109543:	83 ec 04             	sub    $0x4,%esp
80109546:	6a 06                	push   $0x6
80109548:	68 c0 9c 11 80       	push   $0x80119cc0
8010954d:	50                   	push   %eax
8010954e:	e8 14 bb ff ff       	call   80105067 <memmove>
80109553:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109559:	83 c0 0e             	add    $0xe,%eax
8010955c:	83 ec 04             	sub    $0x4,%esp
8010955f:	6a 04                	push   $0x4
80109561:	68 e4 f4 10 80       	push   $0x8010f4e4
80109566:	50                   	push   %eax
80109567:	e8 fb ba ff ff       	call   80105067 <memmove>
8010956c:	83 c4 10             	add    $0x10,%esp
}
8010956f:	90                   	nop
80109570:	c9                   	leave  
80109571:	c3                   	ret    

80109572 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109572:	55                   	push   %ebp
80109573:	89 e5                	mov    %esp,%ebp
80109575:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109578:	8b 45 08             	mov    0x8(%ebp),%eax
8010957b:	83 c0 0e             	add    $0xe,%eax
8010957e:	83 ec 0c             	sub    $0xc,%esp
80109581:	50                   	push   %eax
80109582:	e8 bc 00 00 00       	call   80109643 <arp_table_search>
80109587:	83 c4 10             	add    $0x10,%esp
8010958a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010958d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109591:	78 2d                	js     801095c0 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109593:	8b 45 08             	mov    0x8(%ebp),%eax
80109596:	8d 48 08             	lea    0x8(%eax),%ecx
80109599:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010959c:	89 d0                	mov    %edx,%eax
8010959e:	c1 e0 02             	shl    $0x2,%eax
801095a1:	01 d0                	add    %edx,%eax
801095a3:	01 c0                	add    %eax,%eax
801095a5:	01 d0                	add    %edx,%eax
801095a7:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801095ac:	83 c0 04             	add    $0x4,%eax
801095af:	83 ec 04             	sub    $0x4,%esp
801095b2:	6a 06                	push   $0x6
801095b4:	51                   	push   %ecx
801095b5:	50                   	push   %eax
801095b6:	e8 ac ba ff ff       	call   80105067 <memmove>
801095bb:	83 c4 10             	add    $0x10,%esp
801095be:	eb 70                	jmp    80109630 <arp_table_update+0xbe>
  }else{
    index += 1;
801095c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801095c4:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801095c7:	8b 45 08             	mov    0x8(%ebp),%eax
801095ca:	8d 48 08             	lea    0x8(%eax),%ecx
801095cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095d0:	89 d0                	mov    %edx,%eax
801095d2:	c1 e0 02             	shl    $0x2,%eax
801095d5:	01 d0                	add    %edx,%eax
801095d7:	01 c0                	add    %eax,%eax
801095d9:	01 d0                	add    %edx,%eax
801095db:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
801095e0:	83 c0 04             	add    $0x4,%eax
801095e3:	83 ec 04             	sub    $0x4,%esp
801095e6:	6a 06                	push   $0x6
801095e8:	51                   	push   %ecx
801095e9:	50                   	push   %eax
801095ea:	e8 78 ba ff ff       	call   80105067 <memmove>
801095ef:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801095f2:	8b 45 08             	mov    0x8(%ebp),%eax
801095f5:	8d 48 0e             	lea    0xe(%eax),%ecx
801095f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095fb:	89 d0                	mov    %edx,%eax
801095fd:	c1 e0 02             	shl    $0x2,%eax
80109600:	01 d0                	add    %edx,%eax
80109602:	01 c0                	add    %eax,%eax
80109604:	01 d0                	add    %edx,%eax
80109606:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010960b:	83 ec 04             	sub    $0x4,%esp
8010960e:	6a 04                	push   $0x4
80109610:	51                   	push   %ecx
80109611:	50                   	push   %eax
80109612:	e8 50 ba ff ff       	call   80105067 <memmove>
80109617:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010961a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010961d:	89 d0                	mov    %edx,%eax
8010961f:	c1 e0 02             	shl    $0x2,%eax
80109622:	01 d0                	add    %edx,%eax
80109624:	01 c0                	add    %eax,%eax
80109626:	01 d0                	add    %edx,%eax
80109628:	05 ea 9c 11 80       	add    $0x80119cea,%eax
8010962d:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109630:	83 ec 0c             	sub    $0xc,%esp
80109633:	68 e0 9c 11 80       	push   $0x80119ce0
80109638:	e8 83 00 00 00       	call   801096c0 <print_arp_table>
8010963d:	83 c4 10             	add    $0x10,%esp
}
80109640:	90                   	nop
80109641:	c9                   	leave  
80109642:	c3                   	ret    

80109643 <arp_table_search>:

int arp_table_search(uchar *ip){
80109643:	55                   	push   %ebp
80109644:	89 e5                	mov    %esp,%ebp
80109646:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109649:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109650:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109657:	eb 59                	jmp    801096b2 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109659:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010965c:	89 d0                	mov    %edx,%eax
8010965e:	c1 e0 02             	shl    $0x2,%eax
80109661:	01 d0                	add    %edx,%eax
80109663:	01 c0                	add    %eax,%eax
80109665:	01 d0                	add    %edx,%eax
80109667:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
8010966c:	83 ec 04             	sub    $0x4,%esp
8010966f:	6a 04                	push   $0x4
80109671:	ff 75 08             	push   0x8(%ebp)
80109674:	50                   	push   %eax
80109675:	e8 95 b9 ff ff       	call   8010500f <memcmp>
8010967a:	83 c4 10             	add    $0x10,%esp
8010967d:	85 c0                	test   %eax,%eax
8010967f:	75 05                	jne    80109686 <arp_table_search+0x43>
      return i;
80109681:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109684:	eb 38                	jmp    801096be <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109686:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109689:	89 d0                	mov    %edx,%eax
8010968b:	c1 e0 02             	shl    $0x2,%eax
8010968e:	01 d0                	add    %edx,%eax
80109690:	01 c0                	add    %eax,%eax
80109692:	01 d0                	add    %edx,%eax
80109694:	05 ea 9c 11 80       	add    $0x80119cea,%eax
80109699:	0f b6 00             	movzbl (%eax),%eax
8010969c:	84 c0                	test   %al,%al
8010969e:	75 0e                	jne    801096ae <arp_table_search+0x6b>
801096a0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801096a4:	75 08                	jne    801096ae <arp_table_search+0x6b>
      empty = -i;
801096a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a9:	f7 d8                	neg    %eax
801096ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801096b2:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801096b6:	7e a1                	jle    80109659 <arp_table_search+0x16>
    }
  }
  return empty-1;
801096b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096bb:	83 e8 01             	sub    $0x1,%eax
}
801096be:	c9                   	leave  
801096bf:	c3                   	ret    

801096c0 <print_arp_table>:

void print_arp_table(){
801096c0:	55                   	push   %ebp
801096c1:	89 e5                	mov    %esp,%ebp
801096c3:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801096cd:	e9 92 00 00 00       	jmp    80109764 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801096d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096d5:	89 d0                	mov    %edx,%eax
801096d7:	c1 e0 02             	shl    $0x2,%eax
801096da:	01 d0                	add    %edx,%eax
801096dc:	01 c0                	add    %eax,%eax
801096de:	01 d0                	add    %edx,%eax
801096e0:	05 ea 9c 11 80       	add    $0x80119cea,%eax
801096e5:	0f b6 00             	movzbl (%eax),%eax
801096e8:	84 c0                	test   %al,%al
801096ea:	74 74                	je     80109760 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801096ec:	83 ec 08             	sub    $0x8,%esp
801096ef:	ff 75 f4             	push   -0xc(%ebp)
801096f2:	68 4f c5 10 80       	push   $0x8010c54f
801096f7:	e8 f8 6c ff ff       	call   801003f4 <cprintf>
801096fc:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801096ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109702:	89 d0                	mov    %edx,%eax
80109704:	c1 e0 02             	shl    $0x2,%eax
80109707:	01 d0                	add    %edx,%eax
80109709:	01 c0                	add    %eax,%eax
8010970b:	01 d0                	add    %edx,%eax
8010970d:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
80109712:	83 ec 0c             	sub    $0xc,%esp
80109715:	50                   	push   %eax
80109716:	e8 54 02 00 00       	call   8010996f <print_ipv4>
8010971b:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010971e:	83 ec 0c             	sub    $0xc,%esp
80109721:	68 5e c5 10 80       	push   $0x8010c55e
80109726:	e8 c9 6c ff ff       	call   801003f4 <cprintf>
8010972b:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010972e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109731:	89 d0                	mov    %edx,%eax
80109733:	c1 e0 02             	shl    $0x2,%eax
80109736:	01 d0                	add    %edx,%eax
80109738:	01 c0                	add    %eax,%eax
8010973a:	01 d0                	add    %edx,%eax
8010973c:	05 e0 9c 11 80       	add    $0x80119ce0,%eax
80109741:	83 c0 04             	add    $0x4,%eax
80109744:	83 ec 0c             	sub    $0xc,%esp
80109747:	50                   	push   %eax
80109748:	e8 70 02 00 00       	call   801099bd <print_mac>
8010974d:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109750:	83 ec 0c             	sub    $0xc,%esp
80109753:	68 60 c5 10 80       	push   $0x8010c560
80109758:	e8 97 6c ff ff       	call   801003f4 <cprintf>
8010975d:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109760:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109764:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109768:	0f 8e 64 ff ff ff    	jle    801096d2 <print_arp_table+0x12>
    }
  }
}
8010976e:	90                   	nop
8010976f:	90                   	nop
80109770:	c9                   	leave  
80109771:	c3                   	ret    

80109772 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109772:	55                   	push   %ebp
80109773:	89 e5                	mov    %esp,%ebp
80109775:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109778:	8b 45 10             	mov    0x10(%ebp),%eax
8010977b:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109781:	8b 45 0c             	mov    0xc(%ebp),%eax
80109784:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109787:	8b 45 0c             	mov    0xc(%ebp),%eax
8010978a:	83 c0 0e             	add    $0xe,%eax
8010978d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109793:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979a:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010979e:	8b 45 08             	mov    0x8(%ebp),%eax
801097a1:	8d 50 08             	lea    0x8(%eax),%edx
801097a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a7:	83 ec 04             	sub    $0x4,%esp
801097aa:	6a 06                	push   $0x6
801097ac:	52                   	push   %edx
801097ad:	50                   	push   %eax
801097ae:	e8 b4 b8 ff ff       	call   80105067 <memmove>
801097b3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801097b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b9:	83 c0 06             	add    $0x6,%eax
801097bc:	83 ec 04             	sub    $0x4,%esp
801097bf:	6a 06                	push   $0x6
801097c1:	68 c0 9c 11 80       	push   $0x80119cc0
801097c6:	50                   	push   %eax
801097c7:	e8 9b b8 ff ff       	call   80105067 <memmove>
801097cc:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801097cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097d2:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801097d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097da:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801097e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097e3:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801097e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ea:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801097ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097f1:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801097f7:	8b 45 08             	mov    0x8(%ebp),%eax
801097fa:	8d 50 08             	lea    0x8(%eax),%edx
801097fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109800:	83 c0 12             	add    $0x12,%eax
80109803:	83 ec 04             	sub    $0x4,%esp
80109806:	6a 06                	push   $0x6
80109808:	52                   	push   %edx
80109809:	50                   	push   %eax
8010980a:	e8 58 b8 ff ff       	call   80105067 <memmove>
8010980f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109812:	8b 45 08             	mov    0x8(%ebp),%eax
80109815:	8d 50 0e             	lea    0xe(%eax),%edx
80109818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010981b:	83 c0 18             	add    $0x18,%eax
8010981e:	83 ec 04             	sub    $0x4,%esp
80109821:	6a 04                	push   $0x4
80109823:	52                   	push   %edx
80109824:	50                   	push   %eax
80109825:	e8 3d b8 ff ff       	call   80105067 <memmove>
8010982a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010982d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109830:	83 c0 08             	add    $0x8,%eax
80109833:	83 ec 04             	sub    $0x4,%esp
80109836:	6a 06                	push   $0x6
80109838:	68 c0 9c 11 80       	push   $0x80119cc0
8010983d:	50                   	push   %eax
8010983e:	e8 24 b8 ff ff       	call   80105067 <memmove>
80109843:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109849:	83 c0 0e             	add    $0xe,%eax
8010984c:	83 ec 04             	sub    $0x4,%esp
8010984f:	6a 04                	push   $0x4
80109851:	68 e4 f4 10 80       	push   $0x8010f4e4
80109856:	50                   	push   %eax
80109857:	e8 0b b8 ff ff       	call   80105067 <memmove>
8010985c:	83 c4 10             	add    $0x10,%esp
}
8010985f:	90                   	nop
80109860:	c9                   	leave  
80109861:	c3                   	ret    

80109862 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109862:	55                   	push   %ebp
80109863:	89 e5                	mov    %esp,%ebp
80109865:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109868:	83 ec 0c             	sub    $0xc,%esp
8010986b:	68 62 c5 10 80       	push   $0x8010c562
80109870:	e8 7f 6b ff ff       	call   801003f4 <cprintf>
80109875:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109878:	8b 45 08             	mov    0x8(%ebp),%eax
8010987b:	83 c0 0e             	add    $0xe,%eax
8010987e:	83 ec 0c             	sub    $0xc,%esp
80109881:	50                   	push   %eax
80109882:	e8 e8 00 00 00       	call   8010996f <print_ipv4>
80109887:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010988a:	83 ec 0c             	sub    $0xc,%esp
8010988d:	68 60 c5 10 80       	push   $0x8010c560
80109892:	e8 5d 6b ff ff       	call   801003f4 <cprintf>
80109897:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010989a:	8b 45 08             	mov    0x8(%ebp),%eax
8010989d:	83 c0 08             	add    $0x8,%eax
801098a0:	83 ec 0c             	sub    $0xc,%esp
801098a3:	50                   	push   %eax
801098a4:	e8 14 01 00 00       	call   801099bd <print_mac>
801098a9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098ac:	83 ec 0c             	sub    $0xc,%esp
801098af:	68 60 c5 10 80       	push   $0x8010c560
801098b4:	e8 3b 6b ff ff       	call   801003f4 <cprintf>
801098b9:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801098bc:	83 ec 0c             	sub    $0xc,%esp
801098bf:	68 79 c5 10 80       	push   $0x8010c579
801098c4:	e8 2b 6b ff ff       	call   801003f4 <cprintf>
801098c9:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801098cc:	8b 45 08             	mov    0x8(%ebp),%eax
801098cf:	83 c0 18             	add    $0x18,%eax
801098d2:	83 ec 0c             	sub    $0xc,%esp
801098d5:	50                   	push   %eax
801098d6:	e8 94 00 00 00       	call   8010996f <print_ipv4>
801098db:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098de:	83 ec 0c             	sub    $0xc,%esp
801098e1:	68 60 c5 10 80       	push   $0x8010c560
801098e6:	e8 09 6b ff ff       	call   801003f4 <cprintf>
801098eb:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801098ee:	8b 45 08             	mov    0x8(%ebp),%eax
801098f1:	83 c0 12             	add    $0x12,%eax
801098f4:	83 ec 0c             	sub    $0xc,%esp
801098f7:	50                   	push   %eax
801098f8:	e8 c0 00 00 00       	call   801099bd <print_mac>
801098fd:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109900:	83 ec 0c             	sub    $0xc,%esp
80109903:	68 60 c5 10 80       	push   $0x8010c560
80109908:	e8 e7 6a ff ff       	call   801003f4 <cprintf>
8010990d:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109910:	83 ec 0c             	sub    $0xc,%esp
80109913:	68 90 c5 10 80       	push   $0x8010c590
80109918:	e8 d7 6a ff ff       	call   801003f4 <cprintf>
8010991d:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109920:	8b 45 08             	mov    0x8(%ebp),%eax
80109923:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109927:	66 3d 00 01          	cmp    $0x100,%ax
8010992b:	75 12                	jne    8010993f <print_arp_info+0xdd>
8010992d:	83 ec 0c             	sub    $0xc,%esp
80109930:	68 9c c5 10 80       	push   $0x8010c59c
80109935:	e8 ba 6a ff ff       	call   801003f4 <cprintf>
8010993a:	83 c4 10             	add    $0x10,%esp
8010993d:	eb 1d                	jmp    8010995c <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010993f:	8b 45 08             	mov    0x8(%ebp),%eax
80109942:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109946:	66 3d 00 02          	cmp    $0x200,%ax
8010994a:	75 10                	jne    8010995c <print_arp_info+0xfa>
    cprintf("Reply\n");
8010994c:	83 ec 0c             	sub    $0xc,%esp
8010994f:	68 a5 c5 10 80       	push   $0x8010c5a5
80109954:	e8 9b 6a ff ff       	call   801003f4 <cprintf>
80109959:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010995c:	83 ec 0c             	sub    $0xc,%esp
8010995f:	68 60 c5 10 80       	push   $0x8010c560
80109964:	e8 8b 6a ff ff       	call   801003f4 <cprintf>
80109969:	83 c4 10             	add    $0x10,%esp
}
8010996c:	90                   	nop
8010996d:	c9                   	leave  
8010996e:	c3                   	ret    

8010996f <print_ipv4>:

void print_ipv4(uchar *ip){
8010996f:	55                   	push   %ebp
80109970:	89 e5                	mov    %esp,%ebp
80109972:	53                   	push   %ebx
80109973:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109976:	8b 45 08             	mov    0x8(%ebp),%eax
80109979:	83 c0 03             	add    $0x3,%eax
8010997c:	0f b6 00             	movzbl (%eax),%eax
8010997f:	0f b6 d8             	movzbl %al,%ebx
80109982:	8b 45 08             	mov    0x8(%ebp),%eax
80109985:	83 c0 02             	add    $0x2,%eax
80109988:	0f b6 00             	movzbl (%eax),%eax
8010998b:	0f b6 c8             	movzbl %al,%ecx
8010998e:	8b 45 08             	mov    0x8(%ebp),%eax
80109991:	83 c0 01             	add    $0x1,%eax
80109994:	0f b6 00             	movzbl (%eax),%eax
80109997:	0f b6 d0             	movzbl %al,%edx
8010999a:	8b 45 08             	mov    0x8(%ebp),%eax
8010999d:	0f b6 00             	movzbl (%eax),%eax
801099a0:	0f b6 c0             	movzbl %al,%eax
801099a3:	83 ec 0c             	sub    $0xc,%esp
801099a6:	53                   	push   %ebx
801099a7:	51                   	push   %ecx
801099a8:	52                   	push   %edx
801099a9:	50                   	push   %eax
801099aa:	68 ac c5 10 80       	push   $0x8010c5ac
801099af:	e8 40 6a ff ff       	call   801003f4 <cprintf>
801099b4:	83 c4 20             	add    $0x20,%esp
}
801099b7:	90                   	nop
801099b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801099bb:	c9                   	leave  
801099bc:	c3                   	ret    

801099bd <print_mac>:

void print_mac(uchar *mac){
801099bd:	55                   	push   %ebp
801099be:	89 e5                	mov    %esp,%ebp
801099c0:	57                   	push   %edi
801099c1:	56                   	push   %esi
801099c2:	53                   	push   %ebx
801099c3:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801099c6:	8b 45 08             	mov    0x8(%ebp),%eax
801099c9:	83 c0 05             	add    $0x5,%eax
801099cc:	0f b6 00             	movzbl (%eax),%eax
801099cf:	0f b6 f8             	movzbl %al,%edi
801099d2:	8b 45 08             	mov    0x8(%ebp),%eax
801099d5:	83 c0 04             	add    $0x4,%eax
801099d8:	0f b6 00             	movzbl (%eax),%eax
801099db:	0f b6 f0             	movzbl %al,%esi
801099de:	8b 45 08             	mov    0x8(%ebp),%eax
801099e1:	83 c0 03             	add    $0x3,%eax
801099e4:	0f b6 00             	movzbl (%eax),%eax
801099e7:	0f b6 d8             	movzbl %al,%ebx
801099ea:	8b 45 08             	mov    0x8(%ebp),%eax
801099ed:	83 c0 02             	add    $0x2,%eax
801099f0:	0f b6 00             	movzbl (%eax),%eax
801099f3:	0f b6 c8             	movzbl %al,%ecx
801099f6:	8b 45 08             	mov    0x8(%ebp),%eax
801099f9:	83 c0 01             	add    $0x1,%eax
801099fc:	0f b6 00             	movzbl (%eax),%eax
801099ff:	0f b6 d0             	movzbl %al,%edx
80109a02:	8b 45 08             	mov    0x8(%ebp),%eax
80109a05:	0f b6 00             	movzbl (%eax),%eax
80109a08:	0f b6 c0             	movzbl %al,%eax
80109a0b:	83 ec 04             	sub    $0x4,%esp
80109a0e:	57                   	push   %edi
80109a0f:	56                   	push   %esi
80109a10:	53                   	push   %ebx
80109a11:	51                   	push   %ecx
80109a12:	52                   	push   %edx
80109a13:	50                   	push   %eax
80109a14:	68 c4 c5 10 80       	push   $0x8010c5c4
80109a19:	e8 d6 69 ff ff       	call   801003f4 <cprintf>
80109a1e:	83 c4 20             	add    $0x20,%esp
}
80109a21:	90                   	nop
80109a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109a25:	5b                   	pop    %ebx
80109a26:	5e                   	pop    %esi
80109a27:	5f                   	pop    %edi
80109a28:	5d                   	pop    %ebp
80109a29:	c3                   	ret    

80109a2a <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109a2a:	55                   	push   %ebp
80109a2b:	89 e5                	mov    %esp,%ebp
80109a2d:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109a30:	8b 45 08             	mov    0x8(%ebp),%eax
80109a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109a36:	8b 45 08             	mov    0x8(%ebp),%eax
80109a39:	83 c0 0e             	add    $0xe,%eax
80109a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a42:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a46:	3c 08                	cmp    $0x8,%al
80109a48:	75 1b                	jne    80109a65 <eth_proc+0x3b>
80109a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a51:	3c 06                	cmp    $0x6,%al
80109a53:	75 10                	jne    80109a65 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109a55:	83 ec 0c             	sub    $0xc,%esp
80109a58:	ff 75 f0             	push   -0x10(%ebp)
80109a5b:	e8 01 f8 ff ff       	call   80109261 <arp_proc>
80109a60:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109a63:	eb 24                	jmp    80109a89 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a68:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a6c:	3c 08                	cmp    $0x8,%al
80109a6e:	75 19                	jne    80109a89 <eth_proc+0x5f>
80109a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a73:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a77:	84 c0                	test   %al,%al
80109a79:	75 0e                	jne    80109a89 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109a7b:	83 ec 0c             	sub    $0xc,%esp
80109a7e:	ff 75 08             	push   0x8(%ebp)
80109a81:	e8 a3 00 00 00       	call   80109b29 <ipv4_proc>
80109a86:	83 c4 10             	add    $0x10,%esp
}
80109a89:	90                   	nop
80109a8a:	c9                   	leave  
80109a8b:	c3                   	ret    

80109a8c <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109a8c:	55                   	push   %ebp
80109a8d:	89 e5                	mov    %esp,%ebp
80109a8f:	83 ec 04             	sub    $0x4,%esp
80109a92:	8b 45 08             	mov    0x8(%ebp),%eax
80109a95:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a99:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a9d:	c1 e0 08             	shl    $0x8,%eax
80109aa0:	89 c2                	mov    %eax,%edx
80109aa2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109aa6:	66 c1 e8 08          	shr    $0x8,%ax
80109aaa:	01 d0                	add    %edx,%eax
}
80109aac:	c9                   	leave  
80109aad:	c3                   	ret    

80109aae <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109aae:	55                   	push   %ebp
80109aaf:	89 e5                	mov    %esp,%ebp
80109ab1:	83 ec 04             	sub    $0x4,%esp
80109ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109abb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109abf:	c1 e0 08             	shl    $0x8,%eax
80109ac2:	89 c2                	mov    %eax,%edx
80109ac4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ac8:	66 c1 e8 08          	shr    $0x8,%ax
80109acc:	01 d0                	add    %edx,%eax
}
80109ace:	c9                   	leave  
80109acf:	c3                   	ret    

80109ad0 <H2N_uint>:

uint H2N_uint(uint value){
80109ad0:	55                   	push   %ebp
80109ad1:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad6:	c1 e0 18             	shl    $0x18,%eax
80109ad9:	25 00 00 00 0f       	and    $0xf000000,%eax
80109ade:	89 c2                	mov    %eax,%edx
80109ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae3:	c1 e0 08             	shl    $0x8,%eax
80109ae6:	25 00 f0 00 00       	and    $0xf000,%eax
80109aeb:	09 c2                	or     %eax,%edx
80109aed:	8b 45 08             	mov    0x8(%ebp),%eax
80109af0:	c1 e8 08             	shr    $0x8,%eax
80109af3:	83 e0 0f             	and    $0xf,%eax
80109af6:	01 d0                	add    %edx,%eax
}
80109af8:	5d                   	pop    %ebp
80109af9:	c3                   	ret    

80109afa <N2H_uint>:

uint N2H_uint(uint value){
80109afa:	55                   	push   %ebp
80109afb:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109afd:	8b 45 08             	mov    0x8(%ebp),%eax
80109b00:	c1 e0 18             	shl    $0x18,%eax
80109b03:	89 c2                	mov    %eax,%edx
80109b05:	8b 45 08             	mov    0x8(%ebp),%eax
80109b08:	c1 e0 08             	shl    $0x8,%eax
80109b0b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b10:	01 c2                	add    %eax,%edx
80109b12:	8b 45 08             	mov    0x8(%ebp),%eax
80109b15:	c1 e8 08             	shr    $0x8,%eax
80109b18:	25 00 ff 00 00       	and    $0xff00,%eax
80109b1d:	01 c2                	add    %eax,%edx
80109b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b22:	c1 e8 18             	shr    $0x18,%eax
80109b25:	01 d0                	add    %edx,%eax
}
80109b27:	5d                   	pop    %ebp
80109b28:	c3                   	ret    

80109b29 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109b29:	55                   	push   %ebp
80109b2a:	89 e5                	mov    %esp,%ebp
80109b2c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b32:	83 c0 0e             	add    $0xe,%eax
80109b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b3f:	0f b7 d0             	movzwl %ax,%edx
80109b42:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109b47:	39 c2                	cmp    %eax,%edx
80109b49:	74 60                	je     80109bab <ipv4_proc+0x82>
80109b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4e:	83 c0 0c             	add    $0xc,%eax
80109b51:	83 ec 04             	sub    $0x4,%esp
80109b54:	6a 04                	push   $0x4
80109b56:	50                   	push   %eax
80109b57:	68 e4 f4 10 80       	push   $0x8010f4e4
80109b5c:	e8 ae b4 ff ff       	call   8010500f <memcmp>
80109b61:	83 c4 10             	add    $0x10,%esp
80109b64:	85 c0                	test   %eax,%eax
80109b66:	74 43                	je     80109bab <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b6f:	0f b7 c0             	movzwl %ax,%eax
80109b72:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b7a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b7e:	3c 01                	cmp    $0x1,%al
80109b80:	75 10                	jne    80109b92 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109b82:	83 ec 0c             	sub    $0xc,%esp
80109b85:	ff 75 08             	push   0x8(%ebp)
80109b88:	e8 a3 00 00 00       	call   80109c30 <icmp_proc>
80109b8d:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109b90:	eb 19                	jmp    80109bab <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b95:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b99:	3c 06                	cmp    $0x6,%al
80109b9b:	75 0e                	jne    80109bab <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109b9d:	83 ec 0c             	sub    $0xc,%esp
80109ba0:	ff 75 08             	push   0x8(%ebp)
80109ba3:	e8 b3 03 00 00       	call   80109f5b <tcp_proc>
80109ba8:	83 c4 10             	add    $0x10,%esp
}
80109bab:	90                   	nop
80109bac:	c9                   	leave  
80109bad:	c3                   	ret    

80109bae <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109bae:	55                   	push   %ebp
80109baf:	89 e5                	mov    %esp,%ebp
80109bb1:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbd:	0f b6 00             	movzbl (%eax),%eax
80109bc0:	83 e0 0f             	and    $0xf,%eax
80109bc3:	01 c0                	add    %eax,%eax
80109bc5:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109bc8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109bcf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109bd6:	eb 48                	jmp    80109c20 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109bd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109bdb:	01 c0                	add    %eax,%eax
80109bdd:	89 c2                	mov    %eax,%edx
80109bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be2:	01 d0                	add    %edx,%eax
80109be4:	0f b6 00             	movzbl (%eax),%eax
80109be7:	0f b6 c0             	movzbl %al,%eax
80109bea:	c1 e0 08             	shl    $0x8,%eax
80109bed:	89 c2                	mov    %eax,%edx
80109bef:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109bf2:	01 c0                	add    %eax,%eax
80109bf4:	8d 48 01             	lea    0x1(%eax),%ecx
80109bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bfa:	01 c8                	add    %ecx,%eax
80109bfc:	0f b6 00             	movzbl (%eax),%eax
80109bff:	0f b6 c0             	movzbl %al,%eax
80109c02:	01 d0                	add    %edx,%eax
80109c04:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c07:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c0e:	76 0c                	jbe    80109c1c <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c13:	0f b7 c0             	movzwl %ax,%eax
80109c16:	83 c0 01             	add    $0x1,%eax
80109c19:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c1c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c20:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109c24:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109c27:	7c af                	jl     80109bd8 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c2c:	f7 d0                	not    %eax
}
80109c2e:	c9                   	leave  
80109c2f:	c3                   	ret    

80109c30 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109c30:	55                   	push   %ebp
80109c31:	89 e5                	mov    %esp,%ebp
80109c33:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109c36:	8b 45 08             	mov    0x8(%ebp),%eax
80109c39:	83 c0 0e             	add    $0xe,%eax
80109c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c42:	0f b6 00             	movzbl (%eax),%eax
80109c45:	0f b6 c0             	movzbl %al,%eax
80109c48:	83 e0 0f             	and    $0xf,%eax
80109c4b:	c1 e0 02             	shl    $0x2,%eax
80109c4e:	89 c2                	mov    %eax,%edx
80109c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c53:	01 d0                	add    %edx,%eax
80109c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c5b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109c5f:	84 c0                	test   %al,%al
80109c61:	75 4f                	jne    80109cb2 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c66:	0f b6 00             	movzbl (%eax),%eax
80109c69:	3c 08                	cmp    $0x8,%al
80109c6b:	75 45                	jne    80109cb2 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109c6d:	e8 13 90 ff ff       	call   80102c85 <kalloc>
80109c72:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109c75:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109c7c:	83 ec 04             	sub    $0x4,%esp
80109c7f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c82:	50                   	push   %eax
80109c83:	ff 75 ec             	push   -0x14(%ebp)
80109c86:	ff 75 08             	push   0x8(%ebp)
80109c89:	e8 78 00 00 00       	call   80109d06 <icmp_reply_pkt_create>
80109c8e:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c94:	83 ec 08             	sub    $0x8,%esp
80109c97:	50                   	push   %eax
80109c98:	ff 75 ec             	push   -0x14(%ebp)
80109c9b:	e8 95 f4 ff ff       	call   80109135 <i8254_send>
80109ca0:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca6:	83 ec 0c             	sub    $0xc,%esp
80109ca9:	50                   	push   %eax
80109caa:	e8 3c 8f ff ff       	call   80102beb <kfree>
80109caf:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109cb2:	90                   	nop
80109cb3:	c9                   	leave  
80109cb4:	c3                   	ret    

80109cb5 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109cb5:	55                   	push   %ebp
80109cb6:	89 e5                	mov    %esp,%ebp
80109cb8:	53                   	push   %ebx
80109cb9:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cc3:	0f b7 c0             	movzwl %ax,%eax
80109cc6:	83 ec 0c             	sub    $0xc,%esp
80109cc9:	50                   	push   %eax
80109cca:	e8 bd fd ff ff       	call   80109a8c <N2H_ushort>
80109ccf:	83 c4 10             	add    $0x10,%esp
80109cd2:	0f b7 d8             	movzwl %ax,%ebx
80109cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109cdc:	0f b7 c0             	movzwl %ax,%eax
80109cdf:	83 ec 0c             	sub    $0xc,%esp
80109ce2:	50                   	push   %eax
80109ce3:	e8 a4 fd ff ff       	call   80109a8c <N2H_ushort>
80109ce8:	83 c4 10             	add    $0x10,%esp
80109ceb:	0f b7 c0             	movzwl %ax,%eax
80109cee:	83 ec 04             	sub    $0x4,%esp
80109cf1:	53                   	push   %ebx
80109cf2:	50                   	push   %eax
80109cf3:	68 e3 c5 10 80       	push   $0x8010c5e3
80109cf8:	e8 f7 66 ff ff       	call   801003f4 <cprintf>
80109cfd:	83 c4 10             	add    $0x10,%esp
}
80109d00:	90                   	nop
80109d01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d04:	c9                   	leave  
80109d05:	c3                   	ret    

80109d06 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109d06:	55                   	push   %ebp
80109d07:	89 e5                	mov    %esp,%ebp
80109d09:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d12:	8b 45 08             	mov    0x8(%ebp),%eax
80109d15:	83 c0 0e             	add    $0xe,%eax
80109d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d1e:	0f b6 00             	movzbl (%eax),%eax
80109d21:	0f b6 c0             	movzbl %al,%eax
80109d24:	83 e0 0f             	and    $0xf,%eax
80109d27:	c1 e0 02             	shl    $0x2,%eax
80109d2a:	89 c2                	mov    %eax,%edx
80109d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d2f:	01 d0                	add    %edx,%eax
80109d31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d3d:	83 c0 0e             	add    $0xe,%eax
80109d40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d46:	83 c0 14             	add    $0x14,%eax
80109d49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109d4c:	8b 45 10             	mov    0x10(%ebp),%eax
80109d4f:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d58:	8d 50 06             	lea    0x6(%eax),%edx
80109d5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d5e:	83 ec 04             	sub    $0x4,%esp
80109d61:	6a 06                	push   $0x6
80109d63:	52                   	push   %edx
80109d64:	50                   	push   %eax
80109d65:	e8 fd b2 ff ff       	call   80105067 <memmove>
80109d6a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d70:	83 c0 06             	add    $0x6,%eax
80109d73:	83 ec 04             	sub    $0x4,%esp
80109d76:	6a 06                	push   $0x6
80109d78:	68 c0 9c 11 80       	push   $0x80119cc0
80109d7d:	50                   	push   %eax
80109d7e:	e8 e4 b2 ff ff       	call   80105067 <memmove>
80109d83:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d89:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d90:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d97:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109da1:	83 ec 0c             	sub    $0xc,%esp
80109da4:	6a 54                	push   $0x54
80109da6:	e8 03 fd ff ff       	call   80109aae <H2N_ushort>
80109dab:	83 c4 10             	add    $0x10,%esp
80109dae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109db1:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109db5:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
80109dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dbf:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109dc3:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
80109dca:	83 c0 01             	add    $0x1,%eax
80109dcd:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109dd3:	83 ec 0c             	sub    $0xc,%esp
80109dd6:	68 00 40 00 00       	push   $0x4000
80109ddb:	e8 ce fc ff ff       	call   80109aae <H2N_ushort>
80109de0:	83 c4 10             	add    $0x10,%esp
80109de3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109de6:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ded:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dfb:	83 c0 0c             	add    $0xc,%eax
80109dfe:	83 ec 04             	sub    $0x4,%esp
80109e01:	6a 04                	push   $0x4
80109e03:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e08:	50                   	push   %eax
80109e09:	e8 59 b2 ff ff       	call   80105067 <memmove>
80109e0e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e14:	8d 50 0c             	lea    0xc(%eax),%edx
80109e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e1a:	83 c0 10             	add    $0x10,%eax
80109e1d:	83 ec 04             	sub    $0x4,%esp
80109e20:	6a 04                	push   $0x4
80109e22:	52                   	push   %edx
80109e23:	50                   	push   %eax
80109e24:	e8 3e b2 ff ff       	call   80105067 <memmove>
80109e29:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e2f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e38:	83 ec 0c             	sub    $0xc,%esp
80109e3b:	50                   	push   %eax
80109e3c:	e8 6d fd ff ff       	call   80109bae <ipv4_chksum>
80109e41:	83 c4 10             	add    $0x10,%esp
80109e44:	0f b7 c0             	movzwl %ax,%eax
80109e47:	83 ec 0c             	sub    $0xc,%esp
80109e4a:	50                   	push   %eax
80109e4b:	e8 5e fc ff ff       	call   80109aae <H2N_ushort>
80109e50:	83 c4 10             	add    $0x10,%esp
80109e53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e56:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e5d:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109e60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e63:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e6a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109e6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e71:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e78:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e7f:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109e83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e86:	8d 50 08             	lea    0x8(%eax),%edx
80109e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e8c:	83 c0 08             	add    $0x8,%eax
80109e8f:	83 ec 04             	sub    $0x4,%esp
80109e92:	6a 08                	push   $0x8
80109e94:	52                   	push   %edx
80109e95:	50                   	push   %eax
80109e96:	e8 cc b1 ff ff       	call   80105067 <memmove>
80109e9b:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ea1:	8d 50 10             	lea    0x10(%eax),%edx
80109ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ea7:	83 c0 10             	add    $0x10,%eax
80109eaa:	83 ec 04             	sub    $0x4,%esp
80109ead:	6a 30                	push   $0x30
80109eaf:	52                   	push   %edx
80109eb0:	50                   	push   %eax
80109eb1:	e8 b1 b1 ff ff       	call   80105067 <memmove>
80109eb6:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109eb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ebc:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec5:	83 ec 0c             	sub    $0xc,%esp
80109ec8:	50                   	push   %eax
80109ec9:	e8 1c 00 00 00       	call   80109eea <icmp_chksum>
80109ece:	83 c4 10             	add    $0x10,%esp
80109ed1:	0f b7 c0             	movzwl %ax,%eax
80109ed4:	83 ec 0c             	sub    $0xc,%esp
80109ed7:	50                   	push   %eax
80109ed8:	e8 d1 fb ff ff       	call   80109aae <H2N_ushort>
80109edd:	83 c4 10             	add    $0x10,%esp
80109ee0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ee3:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109ee7:	90                   	nop
80109ee8:	c9                   	leave  
80109ee9:	c3                   	ret    

80109eea <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109eea:	55                   	push   %ebp
80109eeb:	89 e5                	mov    %esp,%ebp
80109eed:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109ef6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109efd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f04:	eb 48                	jmp    80109f4e <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f06:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f09:	01 c0                	add    %eax,%eax
80109f0b:	89 c2                	mov    %eax,%edx
80109f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f10:	01 d0                	add    %edx,%eax
80109f12:	0f b6 00             	movzbl (%eax),%eax
80109f15:	0f b6 c0             	movzbl %al,%eax
80109f18:	c1 e0 08             	shl    $0x8,%eax
80109f1b:	89 c2                	mov    %eax,%edx
80109f1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f20:	01 c0                	add    %eax,%eax
80109f22:	8d 48 01             	lea    0x1(%eax),%ecx
80109f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f28:	01 c8                	add    %ecx,%eax
80109f2a:	0f b6 00             	movzbl (%eax),%eax
80109f2d:	0f b6 c0             	movzbl %al,%eax
80109f30:	01 d0                	add    %edx,%eax
80109f32:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109f35:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f3c:	76 0c                	jbe    80109f4a <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f41:	0f b7 c0             	movzwl %ax,%eax
80109f44:	83 c0 01             	add    $0x1,%eax
80109f47:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f4a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f4e:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109f52:	7e b2                	jle    80109f06 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f57:	f7 d0                	not    %eax
}
80109f59:	c9                   	leave  
80109f5a:	c3                   	ret    

80109f5b <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109f5b:	55                   	push   %ebp
80109f5c:	89 e5                	mov    %esp,%ebp
80109f5e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109f61:	8b 45 08             	mov    0x8(%ebp),%eax
80109f64:	83 c0 0e             	add    $0xe,%eax
80109f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f6d:	0f b6 00             	movzbl (%eax),%eax
80109f70:	0f b6 c0             	movzbl %al,%eax
80109f73:	83 e0 0f             	and    $0xf,%eax
80109f76:	c1 e0 02             	shl    $0x2,%eax
80109f79:	89 c2                	mov    %eax,%edx
80109f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f7e:	01 d0                	add    %edx,%eax
80109f80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f86:	83 c0 14             	add    $0x14,%eax
80109f89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109f8c:	e8 f4 8c ff ff       	call   80102c85 <kalloc>
80109f91:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109f94:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f9e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fa2:	0f b6 c0             	movzbl %al,%eax
80109fa5:	83 e0 02             	and    $0x2,%eax
80109fa8:	85 c0                	test   %eax,%eax
80109faa:	74 3d                	je     80109fe9 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109fac:	83 ec 0c             	sub    $0xc,%esp
80109faf:	6a 00                	push   $0x0
80109fb1:	6a 12                	push   $0x12
80109fb3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fb6:	50                   	push   %eax
80109fb7:	ff 75 e8             	push   -0x18(%ebp)
80109fba:	ff 75 08             	push   0x8(%ebp)
80109fbd:	e8 a2 01 00 00       	call   8010a164 <tcp_pkt_create>
80109fc2:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109fc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fc8:	83 ec 08             	sub    $0x8,%esp
80109fcb:	50                   	push   %eax
80109fcc:	ff 75 e8             	push   -0x18(%ebp)
80109fcf:	e8 61 f1 ff ff       	call   80109135 <i8254_send>
80109fd4:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109fd7:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
80109fdc:	83 c0 01             	add    $0x1,%eax
80109fdf:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
80109fe4:	e9 69 01 00 00       	jmp    8010a152 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fec:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ff0:	3c 18                	cmp    $0x18,%al
80109ff2:	0f 85 10 01 00 00    	jne    8010a108 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109ff8:	83 ec 04             	sub    $0x4,%esp
80109ffb:	6a 03                	push   $0x3
80109ffd:	68 fe c5 10 80       	push   $0x8010c5fe
8010a002:	ff 75 ec             	push   -0x14(%ebp)
8010a005:	e8 05 b0 ff ff       	call   8010500f <memcmp>
8010a00a:	83 c4 10             	add    $0x10,%esp
8010a00d:	85 c0                	test   %eax,%eax
8010a00f:	74 74                	je     8010a085 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a011:	83 ec 0c             	sub    $0xc,%esp
8010a014:	68 02 c6 10 80       	push   $0x8010c602
8010a019:	e8 d6 63 ff ff       	call   801003f4 <cprintf>
8010a01e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a021:	83 ec 0c             	sub    $0xc,%esp
8010a024:	6a 00                	push   $0x0
8010a026:	6a 10                	push   $0x10
8010a028:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a02b:	50                   	push   %eax
8010a02c:	ff 75 e8             	push   -0x18(%ebp)
8010a02f:	ff 75 08             	push   0x8(%ebp)
8010a032:	e8 2d 01 00 00       	call   8010a164 <tcp_pkt_create>
8010a037:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a03a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a03d:	83 ec 08             	sub    $0x8,%esp
8010a040:	50                   	push   %eax
8010a041:	ff 75 e8             	push   -0x18(%ebp)
8010a044:	e8 ec f0 ff ff       	call   80109135 <i8254_send>
8010a049:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a04c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a04f:	83 c0 36             	add    $0x36,%eax
8010a052:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a055:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a058:	50                   	push   %eax
8010a059:	ff 75 e0             	push   -0x20(%ebp)
8010a05c:	6a 00                	push   $0x0
8010a05e:	6a 00                	push   $0x0
8010a060:	e8 5a 04 00 00       	call   8010a4bf <http_proc>
8010a065:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a068:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a06b:	83 ec 0c             	sub    $0xc,%esp
8010a06e:	50                   	push   %eax
8010a06f:	6a 18                	push   $0x18
8010a071:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a074:	50                   	push   %eax
8010a075:	ff 75 e8             	push   -0x18(%ebp)
8010a078:	ff 75 08             	push   0x8(%ebp)
8010a07b:	e8 e4 00 00 00       	call   8010a164 <tcp_pkt_create>
8010a080:	83 c4 20             	add    $0x20,%esp
8010a083:	eb 62                	jmp    8010a0e7 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a085:	83 ec 0c             	sub    $0xc,%esp
8010a088:	6a 00                	push   $0x0
8010a08a:	6a 10                	push   $0x10
8010a08c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a08f:	50                   	push   %eax
8010a090:	ff 75 e8             	push   -0x18(%ebp)
8010a093:	ff 75 08             	push   0x8(%ebp)
8010a096:	e8 c9 00 00 00       	call   8010a164 <tcp_pkt_create>
8010a09b:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a09e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0a1:	83 ec 08             	sub    $0x8,%esp
8010a0a4:	50                   	push   %eax
8010a0a5:	ff 75 e8             	push   -0x18(%ebp)
8010a0a8:	e8 88 f0 ff ff       	call   80109135 <i8254_send>
8010a0ad:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0b3:	83 c0 36             	add    $0x36,%eax
8010a0b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a0b9:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0bc:	50                   	push   %eax
8010a0bd:	ff 75 e4             	push   -0x1c(%ebp)
8010a0c0:	6a 00                	push   $0x0
8010a0c2:	6a 00                	push   $0x0
8010a0c4:	e8 f6 03 00 00       	call   8010a4bf <http_proc>
8010a0c9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a0cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a0cf:	83 ec 0c             	sub    $0xc,%esp
8010a0d2:	50                   	push   %eax
8010a0d3:	6a 18                	push   $0x18
8010a0d5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0d8:	50                   	push   %eax
8010a0d9:	ff 75 e8             	push   -0x18(%ebp)
8010a0dc:	ff 75 08             	push   0x8(%ebp)
8010a0df:	e8 80 00 00 00       	call   8010a164 <tcp_pkt_create>
8010a0e4:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a0e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0ea:	83 ec 08             	sub    $0x8,%esp
8010a0ed:	50                   	push   %eax
8010a0ee:	ff 75 e8             	push   -0x18(%ebp)
8010a0f1:	e8 3f f0 ff ff       	call   80109135 <i8254_send>
8010a0f6:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a0f9:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a0fe:	83 c0 01             	add    $0x1,%eax
8010a101:	a3 a4 9f 11 80       	mov    %eax,0x80119fa4
8010a106:	eb 4a                	jmp    8010a152 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a10b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a10f:	3c 10                	cmp    $0x10,%al
8010a111:	75 3f                	jne    8010a152 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a113:	a1 a8 9f 11 80       	mov    0x80119fa8,%eax
8010a118:	83 f8 01             	cmp    $0x1,%eax
8010a11b:	75 35                	jne    8010a152 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a11d:	83 ec 0c             	sub    $0xc,%esp
8010a120:	6a 00                	push   $0x0
8010a122:	6a 01                	push   $0x1
8010a124:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a127:	50                   	push   %eax
8010a128:	ff 75 e8             	push   -0x18(%ebp)
8010a12b:	ff 75 08             	push   0x8(%ebp)
8010a12e:	e8 31 00 00 00       	call   8010a164 <tcp_pkt_create>
8010a133:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a136:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a139:	83 ec 08             	sub    $0x8,%esp
8010a13c:	50                   	push   %eax
8010a13d:	ff 75 e8             	push   -0x18(%ebp)
8010a140:	e8 f0 ef ff ff       	call   80109135 <i8254_send>
8010a145:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a148:	c7 05 a8 9f 11 80 00 	movl   $0x0,0x80119fa8
8010a14f:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a152:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a155:	83 ec 0c             	sub    $0xc,%esp
8010a158:	50                   	push   %eax
8010a159:	e8 8d 8a ff ff       	call   80102beb <kfree>
8010a15e:	83 c4 10             	add    $0x10,%esp
}
8010a161:	90                   	nop
8010a162:	c9                   	leave  
8010a163:	c3                   	ret    

8010a164 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a164:	55                   	push   %ebp
8010a165:	89 e5                	mov    %esp,%ebp
8010a167:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a16a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a16d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a170:	8b 45 08             	mov    0x8(%ebp),%eax
8010a173:	83 c0 0e             	add    $0xe,%eax
8010a176:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a17c:	0f b6 00             	movzbl (%eax),%eax
8010a17f:	0f b6 c0             	movzbl %al,%eax
8010a182:	83 e0 0f             	and    $0xf,%eax
8010a185:	c1 e0 02             	shl    $0x2,%eax
8010a188:	89 c2                	mov    %eax,%edx
8010a18a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a18d:	01 d0                	add    %edx,%eax
8010a18f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a192:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a195:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a19b:	83 c0 0e             	add    $0xe,%eax
8010a19e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a1a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1a4:	83 c0 14             	add    $0x14,%eax
8010a1a7:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a1aa:	8b 45 18             	mov    0x18(%ebp),%eax
8010a1ad:	8d 50 36             	lea    0x36(%eax),%edx
8010a1b0:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1b3:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1b8:	8d 50 06             	lea    0x6(%eax),%edx
8010a1bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1be:	83 ec 04             	sub    $0x4,%esp
8010a1c1:	6a 06                	push   $0x6
8010a1c3:	52                   	push   %edx
8010a1c4:	50                   	push   %eax
8010a1c5:	e8 9d ae ff ff       	call   80105067 <memmove>
8010a1ca:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a1cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1d0:	83 c0 06             	add    $0x6,%eax
8010a1d3:	83 ec 04             	sub    $0x4,%esp
8010a1d6:	6a 06                	push   $0x6
8010a1d8:	68 c0 9c 11 80       	push   $0x80119cc0
8010a1dd:	50                   	push   %eax
8010a1de:	e8 84 ae ff ff       	call   80105067 <memmove>
8010a1e3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a1e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a1ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1f0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a1f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a1fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1fd:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a201:	8b 45 18             	mov    0x18(%ebp),%eax
8010a204:	83 c0 28             	add    $0x28,%eax
8010a207:	0f b7 c0             	movzwl %ax,%eax
8010a20a:	83 ec 0c             	sub    $0xc,%esp
8010a20d:	50                   	push   %eax
8010a20e:	e8 9b f8 ff ff       	call   80109aae <H2N_ushort>
8010a213:	83 c4 10             	add    $0x10,%esp
8010a216:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a219:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a21d:	0f b7 15 a0 9f 11 80 	movzwl 0x80119fa0,%edx
8010a224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a227:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a22b:	0f b7 05 a0 9f 11 80 	movzwl 0x80119fa0,%eax
8010a232:	83 c0 01             	add    $0x1,%eax
8010a235:	66 a3 a0 9f 11 80    	mov    %ax,0x80119fa0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a23b:	83 ec 0c             	sub    $0xc,%esp
8010a23e:	6a 00                	push   $0x0
8010a240:	e8 69 f8 ff ff       	call   80109aae <H2N_ushort>
8010a245:	83 c4 10             	add    $0x10,%esp
8010a248:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a24b:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a24f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a252:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a259:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a25d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a260:	83 c0 0c             	add    $0xc,%eax
8010a263:	83 ec 04             	sub    $0x4,%esp
8010a266:	6a 04                	push   $0x4
8010a268:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a26d:	50                   	push   %eax
8010a26e:	e8 f4 ad ff ff       	call   80105067 <memmove>
8010a273:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a276:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a279:	8d 50 0c             	lea    0xc(%eax),%edx
8010a27c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27f:	83 c0 10             	add    $0x10,%eax
8010a282:	83 ec 04             	sub    $0x4,%esp
8010a285:	6a 04                	push   $0x4
8010a287:	52                   	push   %edx
8010a288:	50                   	push   %eax
8010a289:	e8 d9 ad ff ff       	call   80105067 <memmove>
8010a28e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a294:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a29a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29d:	83 ec 0c             	sub    $0xc,%esp
8010a2a0:	50                   	push   %eax
8010a2a1:	e8 08 f9 ff ff       	call   80109bae <ipv4_chksum>
8010a2a6:	83 c4 10             	add    $0x10,%esp
8010a2a9:	0f b7 c0             	movzwl %ax,%eax
8010a2ac:	83 ec 0c             	sub    $0xc,%esp
8010a2af:	50                   	push   %eax
8010a2b0:	e8 f9 f7 ff ff       	call   80109aae <H2N_ushort>
8010a2b5:	83 c4 10             	add    $0x10,%esp
8010a2b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2bb:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a2bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2c2:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a2c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2c9:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a2cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2cf:	0f b7 10             	movzwl (%eax),%edx
8010a2d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d5:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a2d9:	a1 a4 9f 11 80       	mov    0x80119fa4,%eax
8010a2de:	83 ec 0c             	sub    $0xc,%esp
8010a2e1:	50                   	push   %eax
8010a2e2:	e8 e9 f7 ff ff       	call   80109ad0 <H2N_uint>
8010a2e7:	83 c4 10             	add    $0x10,%esp
8010a2ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2ed:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a2f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2f3:	8b 40 04             	mov    0x4(%eax),%eax
8010a2f6:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a2fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ff:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a302:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a305:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a309:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a30c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a310:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a313:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a317:	8b 45 14             	mov    0x14(%ebp),%eax
8010a31a:	89 c2                	mov    %eax,%edx
8010a31c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a31f:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a322:	83 ec 0c             	sub    $0xc,%esp
8010a325:	68 90 38 00 00       	push   $0x3890
8010a32a:	e8 7f f7 ff ff       	call   80109aae <H2N_ushort>
8010a32f:	83 c4 10             	add    $0x10,%esp
8010a332:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a335:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a339:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33c:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a342:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a345:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a34b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a34e:	83 ec 0c             	sub    $0xc,%esp
8010a351:	50                   	push   %eax
8010a352:	e8 1f 00 00 00       	call   8010a376 <tcp_chksum>
8010a357:	83 c4 10             	add    $0x10,%esp
8010a35a:	83 c0 08             	add    $0x8,%eax
8010a35d:	0f b7 c0             	movzwl %ax,%eax
8010a360:	83 ec 0c             	sub    $0xc,%esp
8010a363:	50                   	push   %eax
8010a364:	e8 45 f7 ff ff       	call   80109aae <H2N_ushort>
8010a369:	83 c4 10             	add    $0x10,%esp
8010a36c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a36f:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a373:	90                   	nop
8010a374:	c9                   	leave  
8010a375:	c3                   	ret    

8010a376 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a376:	55                   	push   %ebp
8010a377:	89 e5                	mov    %esp,%ebp
8010a379:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a37c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a37f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a382:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a385:	83 c0 14             	add    $0x14,%eax
8010a388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a38b:	83 ec 04             	sub    $0x4,%esp
8010a38e:	6a 04                	push   $0x4
8010a390:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a395:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a398:	50                   	push   %eax
8010a399:	e8 c9 ac ff ff       	call   80105067 <memmove>
8010a39e:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a3a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3a4:	83 c0 0c             	add    $0xc,%eax
8010a3a7:	83 ec 04             	sub    $0x4,%esp
8010a3aa:	6a 04                	push   $0x4
8010a3ac:	50                   	push   %eax
8010a3ad:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3b0:	83 c0 04             	add    $0x4,%eax
8010a3b3:	50                   	push   %eax
8010a3b4:	e8 ae ac ff ff       	call   80105067 <memmove>
8010a3b9:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a3bc:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a3c0:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a3c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3c7:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a3cb:	0f b7 c0             	movzwl %ax,%eax
8010a3ce:	83 ec 0c             	sub    $0xc,%esp
8010a3d1:	50                   	push   %eax
8010a3d2:	e8 b5 f6 ff ff       	call   80109a8c <N2H_ushort>
8010a3d7:	83 c4 10             	add    $0x10,%esp
8010a3da:	83 e8 14             	sub    $0x14,%eax
8010a3dd:	0f b7 c0             	movzwl %ax,%eax
8010a3e0:	83 ec 0c             	sub    $0xc,%esp
8010a3e3:	50                   	push   %eax
8010a3e4:	e8 c5 f6 ff ff       	call   80109aae <H2N_ushort>
8010a3e9:	83 c4 10             	add    $0x10,%esp
8010a3ec:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a3f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a3f7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a3fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a404:	eb 33                	jmp    8010a439 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a406:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a409:	01 c0                	add    %eax,%eax
8010a40b:	89 c2                	mov    %eax,%edx
8010a40d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a410:	01 d0                	add    %edx,%eax
8010a412:	0f b6 00             	movzbl (%eax),%eax
8010a415:	0f b6 c0             	movzbl %al,%eax
8010a418:	c1 e0 08             	shl    $0x8,%eax
8010a41b:	89 c2                	mov    %eax,%edx
8010a41d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a420:	01 c0                	add    %eax,%eax
8010a422:	8d 48 01             	lea    0x1(%eax),%ecx
8010a425:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a428:	01 c8                	add    %ecx,%eax
8010a42a:	0f b6 00             	movzbl (%eax),%eax
8010a42d:	0f b6 c0             	movzbl %al,%eax
8010a430:	01 d0                	add    %edx,%eax
8010a432:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a435:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a439:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a43d:	7e c7                	jle    8010a406 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a43f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a442:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a445:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a44c:	eb 33                	jmp    8010a481 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a44e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a451:	01 c0                	add    %eax,%eax
8010a453:	89 c2                	mov    %eax,%edx
8010a455:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a458:	01 d0                	add    %edx,%eax
8010a45a:	0f b6 00             	movzbl (%eax),%eax
8010a45d:	0f b6 c0             	movzbl %al,%eax
8010a460:	c1 e0 08             	shl    $0x8,%eax
8010a463:	89 c2                	mov    %eax,%edx
8010a465:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a468:	01 c0                	add    %eax,%eax
8010a46a:	8d 48 01             	lea    0x1(%eax),%ecx
8010a46d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a470:	01 c8                	add    %ecx,%eax
8010a472:	0f b6 00             	movzbl (%eax),%eax
8010a475:	0f b6 c0             	movzbl %al,%eax
8010a478:	01 d0                	add    %edx,%eax
8010a47a:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a47d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a481:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a485:	0f b7 c0             	movzwl %ax,%eax
8010a488:	83 ec 0c             	sub    $0xc,%esp
8010a48b:	50                   	push   %eax
8010a48c:	e8 fb f5 ff ff       	call   80109a8c <N2H_ushort>
8010a491:	83 c4 10             	add    $0x10,%esp
8010a494:	66 d1 e8             	shr    %ax
8010a497:	0f b7 c0             	movzwl %ax,%eax
8010a49a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a49d:	7c af                	jl     8010a44e <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a49f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4a2:	c1 e8 10             	shr    $0x10,%eax
8010a4a5:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a4a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4ab:	f7 d0                	not    %eax
}
8010a4ad:	c9                   	leave  
8010a4ae:	c3                   	ret    

8010a4af <tcp_fin>:

void tcp_fin(){
8010a4af:	55                   	push   %ebp
8010a4b0:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a4b2:	c7 05 a8 9f 11 80 01 	movl   $0x1,0x80119fa8
8010a4b9:	00 00 00 
}
8010a4bc:	90                   	nop
8010a4bd:	5d                   	pop    %ebp
8010a4be:	c3                   	ret    

8010a4bf <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a4bf:	55                   	push   %ebp
8010a4c0:	89 e5                	mov    %esp,%ebp
8010a4c2:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a4c5:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4c8:	83 ec 04             	sub    $0x4,%esp
8010a4cb:	6a 00                	push   $0x0
8010a4cd:	68 0b c6 10 80       	push   $0x8010c60b
8010a4d2:	50                   	push   %eax
8010a4d3:	e8 65 00 00 00       	call   8010a53d <http_strcpy>
8010a4d8:	83 c4 10             	add    $0x10,%esp
8010a4db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a4de:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4e1:	83 ec 04             	sub    $0x4,%esp
8010a4e4:	ff 75 f4             	push   -0xc(%ebp)
8010a4e7:	68 1e c6 10 80       	push   $0x8010c61e
8010a4ec:	50                   	push   %eax
8010a4ed:	e8 4b 00 00 00       	call   8010a53d <http_strcpy>
8010a4f2:	83 c4 10             	add    $0x10,%esp
8010a4f5:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a4f8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4fb:	83 ec 04             	sub    $0x4,%esp
8010a4fe:	ff 75 f4             	push   -0xc(%ebp)
8010a501:	68 39 c6 10 80       	push   $0x8010c639
8010a506:	50                   	push   %eax
8010a507:	e8 31 00 00 00       	call   8010a53d <http_strcpy>
8010a50c:	83 c4 10             	add    $0x10,%esp
8010a50f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a512:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a515:	83 e0 01             	and    $0x1,%eax
8010a518:	85 c0                	test   %eax,%eax
8010a51a:	74 11                	je     8010a52d <http_proc+0x6e>
    char *payload = (char *)send;
8010a51c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a51f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a522:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a525:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a528:	01 d0                	add    %edx,%eax
8010a52a:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a52d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a530:	8b 45 14             	mov    0x14(%ebp),%eax
8010a533:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a535:	e8 75 ff ff ff       	call   8010a4af <tcp_fin>
}
8010a53a:	90                   	nop
8010a53b:	c9                   	leave  
8010a53c:	c3                   	ret    

8010a53d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a53d:	55                   	push   %ebp
8010a53e:	89 e5                	mov    %esp,%ebp
8010a540:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a543:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a54a:	eb 20                	jmp    8010a56c <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a54c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a54f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a552:	01 d0                	add    %edx,%eax
8010a554:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a557:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a55a:	01 ca                	add    %ecx,%edx
8010a55c:	89 d1                	mov    %edx,%ecx
8010a55e:	8b 55 08             	mov    0x8(%ebp),%edx
8010a561:	01 ca                	add    %ecx,%edx
8010a563:	0f b6 00             	movzbl (%eax),%eax
8010a566:	88 02                	mov    %al,(%edx)
    i++;
8010a568:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a56c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a56f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a572:	01 d0                	add    %edx,%eax
8010a574:	0f b6 00             	movzbl (%eax),%eax
8010a577:	84 c0                	test   %al,%al
8010a579:	75 d1                	jne    8010a54c <http_strcpy+0xf>
  }
  return i;
8010a57b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a57e:	c9                   	leave  
8010a57f:	c3                   	ret    
