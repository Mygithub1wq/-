
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
void kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

void
kern_init(void){
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 88 af 11 c0       	mov    $0xc011af88,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 41 5f 00 00       	call   c0105fa3 <memset>

    cons_init();                // init the console
c0100062:	e8 9c 15 00 00       	call   c0101603 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 40 61 10 c0 	movl   $0xc0106140,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 5c 61 10 c0 	movl   $0xc010615c,(%esp)
c010007c:	e8 d7 02 00 00       	call   c0100358 <cprintf>

    print_kerninfo();
c0100081:	e8 06 08 00 00       	call   c010088c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8b 00 00 00       	call   c0100116 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 5c 44 00 00       	call   c01044ec <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 d7 16 00 00       	call   c010176c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 4f 18 00 00       	call   c01018e9 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 1a 0d 00 00       	call   c0100db9 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 36 16 00 00       	call   c01016da <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a4:	e8 6d 01 00 00       	call   c0100216 <lab1_switch_test>

    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	55                   	push   %ebp
c01000ac:	89 e5                	mov    %esp,%ebp
c01000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b8:	00 
c01000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c0:	00 
c01000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c8:	e8 0d 0c 00 00       	call   c0100cda <mon_backtrace>
}
c01000cd:	c9                   	leave  
c01000ce:	c3                   	ret    

c01000cf <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cf:	55                   	push   %ebp
c01000d0:	89 e5                	mov    %esp,%ebp
c01000d2:	53                   	push   %ebx
c01000d3:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d6:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000dc:	8d 55 08             	lea    0x8(%ebp),%edx
c01000df:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000ea:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000ee:	89 04 24             	mov    %eax,(%esp)
c01000f1:	e8 b5 ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000f6:	83 c4 14             	add    $0x14,%esp
c01000f9:	5b                   	pop    %ebx
c01000fa:	5d                   	pop    %ebp
c01000fb:	c3                   	ret    

c01000fc <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fc:	55                   	push   %ebp
c01000fd:	89 e5                	mov    %esp,%ebp
c01000ff:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100102:	8b 45 10             	mov    0x10(%ebp),%eax
c0100105:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100109:	8b 45 08             	mov    0x8(%ebp),%eax
c010010c:	89 04 24             	mov    %eax,(%esp)
c010010f:	e8 bb ff ff ff       	call   c01000cf <grade_backtrace1>
}
c0100114:	c9                   	leave  
c0100115:	c3                   	ret    

c0100116 <grade_backtrace>:

void
grade_backtrace(void) {
c0100116:	55                   	push   %ebp
c0100117:	89 e5                	mov    %esp,%ebp
c0100119:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011c:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100121:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100128:	ff 
c0100129:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100134:	e8 c3 ff ff ff       	call   c01000fc <grade_backtrace0>
}
c0100139:	c9                   	leave  
c010013a:	c3                   	ret    

c010013b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013b:	55                   	push   %ebp
c010013c:	89 e5                	mov    %esp,%ebp
c010013e:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100141:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100144:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100147:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100151:	0f b7 c0             	movzwl %ax,%eax
c0100154:	83 e0 03             	and    $0x3,%eax
c0100157:	89 c2                	mov    %eax,%edx
c0100159:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100162:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100166:	c7 04 24 61 61 10 c0 	movl   $0xc0106161,(%esp)
c010016d:	e8 e6 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100172:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100176:	0f b7 d0             	movzwl %ax,%edx
c0100179:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 6f 61 10 c0 	movl   $0xc010616f,(%esp)
c010018d:	e8 c6 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	0f b7 d0             	movzwl %ax,%edx
c0100199:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010019e:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a6:	c7 04 24 7d 61 10 c0 	movl   $0xc010617d,(%esp)
c01001ad:	e8 a6 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b6:	0f b7 d0             	movzwl %ax,%edx
c01001b9:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001be:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c6:	c7 04 24 8b 61 10 c0 	movl   $0xc010618b,(%esp)
c01001cd:	e8 86 01 00 00       	call   c0100358 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d6:	0f b7 d0             	movzwl %ax,%edx
c01001d9:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001de:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e6:	c7 04 24 99 61 10 c0 	movl   $0xc0106199,(%esp)
c01001ed:	e8 66 01 00 00       	call   c0100358 <cprintf>
    round ++;
c01001f2:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f7:	83 c0 01             	add    $0x1,%eax
c01001fa:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001ff:	c9                   	leave  
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
c0100204:	83 ec 08             	sub    $0x8,%esp
c0100207:	cd 78                	int    $0x78
c0100209:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
c010020b:	5d                   	pop    %ebp
c010020c:	c3                   	ret    

c010020d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020d:	55                   	push   %ebp
c010020e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
c0100210:	cd 79                	int    $0x79
c0100212:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
c0100214:	5d                   	pop    %ebp
c0100215:	c3                   	ret    

c0100216 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100216:	55                   	push   %ebp
c0100217:	89 e5                	mov    %esp,%ebp
c0100219:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021c:	e8 1a ff ff ff       	call   c010013b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100221:	c7 04 24 a8 61 10 c0 	movl   $0xc01061a8,(%esp)
c0100228:	e8 2b 01 00 00       	call   c0100358 <cprintf>
    lab1_switch_to_user();
c010022d:	e8 cf ff ff ff       	call   c0100201 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100232:	e8 04 ff ff ff       	call   c010013b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100237:	c7 04 24 c8 61 10 c0 	movl   $0xc01061c8,(%esp)
c010023e:	e8 15 01 00 00       	call   c0100358 <cprintf>
    lab1_switch_to_kernel();
c0100243:	e8 c5 ff ff ff       	call   c010020d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100248:	e8 ee fe ff ff       	call   c010013b <lab1_print_cur_status>
}
c010024d:	c9                   	leave  
c010024e:	c3                   	ret    

c010024f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024f:	55                   	push   %ebp
c0100250:	89 e5                	mov    %esp,%ebp
c0100252:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100255:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100259:	74 13                	je     c010026e <readline+0x1f>
        cprintf("%s", prompt);
c010025b:	8b 45 08             	mov    0x8(%ebp),%eax
c010025e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100262:	c7 04 24 e7 61 10 c0 	movl   $0xc01061e7,(%esp)
c0100269:	e8 ea 00 00 00       	call   c0100358 <cprintf>
    }
    int i = 0, c;
c010026e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100275:	e8 66 01 00 00       	call   c01003e0 <getchar>
c010027a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010027d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100281:	79 07                	jns    c010028a <readline+0x3b>
            return NULL;
c0100283:	b8 00 00 00 00       	mov    $0x0,%eax
c0100288:	eb 79                	jmp    c0100303 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010028a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010028e:	7e 28                	jle    c01002b8 <readline+0x69>
c0100290:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100297:	7f 1f                	jg     c01002b8 <readline+0x69>
            cputchar(c);
c0100299:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010029c:	89 04 24             	mov    %eax,(%esp)
c010029f:	e8 da 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c01002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a7:	8d 50 01             	lea    0x1(%eax),%edx
c01002aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002b6:	eb 46                	jmp    c01002fe <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002bc:	75 17                	jne    c01002d5 <readline+0x86>
c01002be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c2:	7e 11                	jle    c01002d5 <readline+0x86>
            cputchar(c);
c01002c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c7:	89 04 24             	mov    %eax,(%esp)
c01002ca:	e8 af 00 00 00       	call   c010037e <cputchar>
            i --;
c01002cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002d3:	eb 29                	jmp    c01002fe <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d9:	74 06                	je     c01002e1 <readline+0x92>
c01002db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002df:	75 1d                	jne    c01002fe <readline+0xaf>
            cputchar(c);
c01002e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e4:	89 04 24             	mov    %eax,(%esp)
c01002e7:	e8 92 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ef:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002f4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002fc:	eb 05                	jmp    c0100303 <readline+0xb4>
        }
    }
c01002fe:	e9 72 ff ff ff       	jmp    c0100275 <readline+0x26>
}
c0100303:	c9                   	leave  
c0100304:	c3                   	ret    

c0100305 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100305:	55                   	push   %ebp
c0100306:	89 e5                	mov    %esp,%ebp
c0100308:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010030b:	8b 45 08             	mov    0x8(%ebp),%eax
c010030e:	89 04 24             	mov    %eax,(%esp)
c0100311:	e8 19 13 00 00       	call   c010162f <cons_putc>
    (*cnt) ++;
c0100316:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100319:	8b 00                	mov    (%eax),%eax
c010031b:	8d 50 01             	lea    0x1(%eax),%edx
c010031e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100321:	89 10                	mov    %edx,(%eax)
}
c0100323:	c9                   	leave  
c0100324:	c3                   	ret    

c0100325 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100325:	55                   	push   %ebp
c0100326:	89 e5                	mov    %esp,%ebp
c0100328:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010032b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100332:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100335:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100339:	8b 45 08             	mov    0x8(%ebp),%eax
c010033c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100340:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100343:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100347:	c7 04 24 05 03 10 c0 	movl   $0xc0100305,(%esp)
c010034e:	e8 69 54 00 00       	call   c01057bc <vprintfmt>
    return cnt;
c0100353:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100356:	c9                   	leave  
c0100357:	c3                   	ret    

c0100358 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100358:	55                   	push   %ebp
c0100359:	89 e5                	mov    %esp,%ebp
c010035b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100361:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100364:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100367:	89 44 24 04          	mov    %eax,0x4(%esp)
c010036b:	8b 45 08             	mov    0x8(%ebp),%eax
c010036e:	89 04 24             	mov    %eax,(%esp)
c0100371:	e8 af ff ff ff       	call   c0100325 <vcprintf>
c0100376:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100379:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037c:	c9                   	leave  
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 a0 12 00 00       	call   c010162f <cons_putc>
}
c010038f:	c9                   	leave  
c0100390:	c3                   	ret    

c0100391 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100391:	55                   	push   %ebp
c0100392:	89 e5                	mov    %esp,%ebp
c0100394:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100397:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010039e:	eb 13                	jmp    c01003b3 <cputs+0x22>
        cputch(c, &cnt);
c01003a0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a4:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ab:	89 04 24             	mov    %eax,(%esp)
c01003ae:	e8 52 ff ff ff       	call   c0100305 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b6:	8d 50 01             	lea    0x1(%eax),%edx
c01003b9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bc:	0f b6 00             	movzbl (%eax),%eax
c01003bf:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c6:	75 d8                	jne    c01003a0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003cf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d6:	e8 2a ff ff ff       	call   c0100305 <cputch>
    return cnt;
c01003db:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003de:	c9                   	leave  
c01003df:	c3                   	ret    

c01003e0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e0:	55                   	push   %ebp
c01003e1:	89 e5                	mov    %esp,%ebp
c01003e3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e6:	e8 80 12 00 00       	call   c010166b <cons_getc>
c01003eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f2:	74 f2                	je     c01003e6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f7:	c9                   	leave  
c01003f8:	c3                   	ret    

c01003f9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f9:	55                   	push   %ebp
c01003fa:	89 e5                	mov    %esp,%ebp
c01003fc:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100402:	8b 00                	mov    (%eax),%eax
c0100404:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100407:	8b 45 10             	mov    0x10(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100416:	e9 d2 00 00 00       	jmp    c01004ed <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010041b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010041e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100421:	01 d0                	add    %edx,%eax
c0100423:	89 c2                	mov    %eax,%edx
c0100425:	c1 ea 1f             	shr    $0x1f,%edx
c0100428:	01 d0                	add    %edx,%eax
c010042a:	d1 f8                	sar    %eax
c010042c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100432:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100435:	eb 04                	jmp    c010043b <stab_binsearch+0x42>
            m --;
c0100437:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010043e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100441:	7c 1f                	jl     c0100462 <stab_binsearch+0x69>
c0100443:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100446:	89 d0                	mov    %edx,%eax
c0100448:	01 c0                	add    %eax,%eax
c010044a:	01 d0                	add    %edx,%eax
c010044c:	c1 e0 02             	shl    $0x2,%eax
c010044f:	89 c2                	mov    %eax,%edx
c0100451:	8b 45 08             	mov    0x8(%ebp),%eax
c0100454:	01 d0                	add    %edx,%eax
c0100456:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010045a:	0f b6 c0             	movzbl %al,%eax
c010045d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100460:	75 d5                	jne    c0100437 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100462:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100465:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100468:	7d 0b                	jge    c0100475 <stab_binsearch+0x7c>
            l = true_m + 1;
c010046a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010046d:	83 c0 01             	add    $0x1,%eax
c0100470:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100473:	eb 78                	jmp    c01004ed <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100475:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010047c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047f:	89 d0                	mov    %edx,%eax
c0100481:	01 c0                	add    %eax,%eax
c0100483:	01 d0                	add    %edx,%eax
c0100485:	c1 e0 02             	shl    $0x2,%eax
c0100488:	89 c2                	mov    %eax,%edx
c010048a:	8b 45 08             	mov    0x8(%ebp),%eax
c010048d:	01 d0                	add    %edx,%eax
c010048f:	8b 40 08             	mov    0x8(%eax),%eax
c0100492:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100495:	73 13                	jae    c01004aa <stab_binsearch+0xb1>
            *region_left = m;
c0100497:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a2:	83 c0 01             	add    $0x1,%eax
c01004a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a8:	eb 43                	jmp    c01004ed <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ad:	89 d0                	mov    %edx,%eax
c01004af:	01 c0                	add    %eax,%eax
c01004b1:	01 d0                	add    %edx,%eax
c01004b3:	c1 e0 02             	shl    $0x2,%eax
c01004b6:	89 c2                	mov    %eax,%edx
c01004b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004bb:	01 d0                	add    %edx,%eax
c01004bd:	8b 40 08             	mov    0x8(%eax),%eax
c01004c0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004c3:	76 16                	jbe    c01004db <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ce:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d3:	83 e8 01             	sub    $0x1,%eax
c01004d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d9:	eb 12                	jmp    c01004ed <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 22 ff ff ff    	jle    c010041b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
c010050c:	eb 3f                	jmp    c010054d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 04                	jmp    c010051c <stab_binsearch+0x123>
c0100518:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010051c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051f:	8b 00                	mov    (%eax),%eax
c0100521:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100524:	7d 1f                	jge    c0100545 <stab_binsearch+0x14c>
c0100526:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100529:	89 d0                	mov    %edx,%eax
c010052b:	01 c0                	add    %eax,%eax
c010052d:	01 d0                	add    %edx,%eax
c010052f:	c1 e0 02             	shl    $0x2,%eax
c0100532:	89 c2                	mov    %eax,%edx
c0100534:	8b 45 08             	mov    0x8(%ebp),%eax
c0100537:	01 d0                	add    %edx,%eax
c0100539:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053d:	0f b6 c0             	movzbl %al,%eax
c0100540:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100543:	75 d3                	jne    c0100518 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054b:	89 10                	mov    %edx,(%eax)
    }
}
c010054d:	c9                   	leave  
c010054e:	c3                   	ret    

c010054f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054f:	55                   	push   %ebp
c0100550:	89 e5                	mov    %esp,%ebp
c0100552:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100555:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100558:	c7 00 ec 61 10 c0    	movl   $0xc01061ec,(%eax)
    info->eip_line = 0;
c010055e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100561:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100568:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056b:	c7 40 08 ec 61 10 c0 	movl   $0xc01061ec,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100572:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100575:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100582:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100585:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100588:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058f:	c7 45 f4 a0 74 10 c0 	movl   $0xc01074a0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100596:	c7 45 f0 b0 21 11 c0 	movl   $0xc01121b0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059d:	c7 45 ec b1 21 11 c0 	movl   $0xc01121b1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a4:	c7 45 e8 38 4c 11 c0 	movl   $0xc0114c38,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b1:	76 0d                	jbe    c01005c0 <debuginfo_eip+0x71>
c01005b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b6:	83 e8 01             	sub    $0x1,%eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x7b>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 c0 02 00 00       	jmp    c010088a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d7:	29 c2                	sub    %eax,%edx
c01005d9:	89 d0                	mov    %edx,%eax
c01005db:	c1 f8 02             	sar    $0x2,%eax
c01005de:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e4:	83 e8 01             	sub    $0x1,%eax
c01005e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ed:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005f1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f8:	00 
c01005f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100600:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100603:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100607:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010060a:	89 04 24             	mov    %eax,(%esp)
c010060d:	e8 e7 fd ff ff       	call   c01003f9 <stab_binsearch>
    if (lfile == 0)
c0100612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100615:	85 c0                	test   %eax,%eax
c0100617:	75 0a                	jne    c0100623 <debuginfo_eip+0xd4>
        return -1;
c0100619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010061e:	e9 67 02 00 00       	jmp    c010088a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100626:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100629:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100632:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100636:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010063d:	00 
c010063e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100641:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100645:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100648:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064f:	89 04 24             	mov    %eax,(%esp)
c0100652:	e8 a2 fd ff ff       	call   c01003f9 <stab_binsearch>

    if (lfun <= rfun) {
c0100657:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010065a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010065d:	39 c2                	cmp    %eax,%edx
c010065f:	7f 7c                	jg     c01006dd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100661:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100664:	89 c2                	mov    %eax,%edx
c0100666:	89 d0                	mov    %edx,%eax
c0100668:	01 c0                	add    %eax,%eax
c010066a:	01 d0                	add    %edx,%eax
c010066c:	c1 e0 02             	shl    $0x2,%eax
c010066f:	89 c2                	mov    %eax,%edx
c0100671:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100674:	01 d0                	add    %edx,%eax
c0100676:	8b 10                	mov    (%eax),%edx
c0100678:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010067b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067e:	29 c1                	sub    %eax,%ecx
c0100680:	89 c8                	mov    %ecx,%eax
c0100682:	39 c2                	cmp    %eax,%edx
c0100684:	73 22                	jae    c01006a8 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100686:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100689:	89 c2                	mov    %eax,%edx
c010068b:	89 d0                	mov    %edx,%eax
c010068d:	01 c0                	add    %eax,%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	c1 e0 02             	shl    $0x2,%eax
c0100694:	89 c2                	mov    %eax,%edx
c0100696:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100699:	01 d0                	add    %edx,%eax
c010069b:	8b 10                	mov    (%eax),%edx
c010069d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006a0:	01 c2                	add    %eax,%edx
c01006a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a5:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006ab:	89 c2                	mov    %eax,%edx
c01006ad:	89 d0                	mov    %edx,%eax
c01006af:	01 c0                	add    %eax,%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	c1 e0 02             	shl    $0x2,%eax
c01006b6:	89 c2                	mov    %eax,%edx
c01006b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bb:	01 d0                	add    %edx,%eax
c01006bd:	8b 50 08             	mov    0x8(%eax),%edx
c01006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c9:	8b 40 10             	mov    0x10(%eax),%eax
c01006cc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006db:	eb 15                	jmp    c01006f2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f5:	8b 40 08             	mov    0x8(%eax),%eax
c01006f8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ff:	00 
c0100700:	89 04 24             	mov    %eax,(%esp)
c0100703:	e8 0f 57 00 00       	call   c0105e17 <strfind>
c0100708:	89 c2                	mov    %eax,%edx
c010070a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070d:	8b 40 08             	mov    0x8(%eax),%eax
c0100710:	29 c2                	sub    %eax,%edx
c0100712:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100715:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100718:	8b 45 08             	mov    0x8(%ebp),%eax
c010071b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100726:	00 
c0100727:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010072a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010072e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100731:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100735:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100738:	89 04 24             	mov    %eax,(%esp)
c010073b:	e8 b9 fc ff ff       	call   c01003f9 <stab_binsearch>
    if (lline <= rline) {
c0100740:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100743:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100746:	39 c2                	cmp    %eax,%edx
c0100748:	7f 24                	jg     c010076e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010074a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074d:	89 c2                	mov    %eax,%edx
c010074f:	89 d0                	mov    %edx,%eax
c0100751:	01 c0                	add    %eax,%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	c1 e0 02             	shl    $0x2,%eax
c0100758:	89 c2                	mov    %eax,%edx
c010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075d:	01 d0                	add    %edx,%eax
c010075f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100763:	0f b7 d0             	movzwl %ax,%edx
c0100766:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100769:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010076c:	eb 13                	jmp    c0100781 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010076e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100773:	e9 12 01 00 00       	jmp    c010088a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077b:	83 e8 01             	sub    $0x1,%eax
c010077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100781:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100787:	39 c2                	cmp    %eax,%edx
c0100789:	7c 56                	jl     c01007e1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010078b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078e:	89 c2                	mov    %eax,%edx
c0100790:	89 d0                	mov    %edx,%eax
c0100792:	01 c0                	add    %eax,%eax
c0100794:	01 d0                	add    %edx,%eax
c0100796:	c1 e0 02             	shl    $0x2,%eax
c0100799:	89 c2                	mov    %eax,%edx
c010079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079e:	01 d0                	add    %edx,%eax
c01007a0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a4:	3c 84                	cmp    $0x84,%al
c01007a6:	74 39                	je     c01007e1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ab:	89 c2                	mov    %eax,%edx
c01007ad:	89 d0                	mov    %edx,%eax
c01007af:	01 c0                	add    %eax,%eax
c01007b1:	01 d0                	add    %edx,%eax
c01007b3:	c1 e0 02             	shl    $0x2,%eax
c01007b6:	89 c2                	mov    %eax,%edx
c01007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bb:	01 d0                	add    %edx,%eax
c01007bd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c1:	3c 64                	cmp    $0x64,%al
c01007c3:	75 b3                	jne    c0100778 <debuginfo_eip+0x229>
c01007c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c8:	89 c2                	mov    %eax,%edx
c01007ca:	89 d0                	mov    %edx,%eax
c01007cc:	01 c0                	add    %eax,%eax
c01007ce:	01 d0                	add    %edx,%eax
c01007d0:	c1 e0 02             	shl    $0x2,%eax
c01007d3:	89 c2                	mov    %eax,%edx
c01007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d8:	01 d0                	add    %edx,%eax
c01007da:	8b 40 08             	mov    0x8(%eax),%eax
c01007dd:	85 c0                	test   %eax,%eax
c01007df:	74 97                	je     c0100778 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e7:	39 c2                	cmp    %eax,%edx
c01007e9:	7c 46                	jl     c0100831 <debuginfo_eip+0x2e2>
c01007eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ee:	89 c2                	mov    %eax,%edx
c01007f0:	89 d0                	mov    %edx,%eax
c01007f2:	01 c0                	add    %eax,%eax
c01007f4:	01 d0                	add    %edx,%eax
c01007f6:	c1 e0 02             	shl    $0x2,%eax
c01007f9:	89 c2                	mov    %eax,%edx
c01007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fe:	01 d0                	add    %edx,%eax
c0100800:	8b 10                	mov    (%eax),%edx
c0100802:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100805:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100808:	29 c1                	sub    %eax,%ecx
c010080a:	89 c8                	mov    %ecx,%eax
c010080c:	39 c2                	cmp    %eax,%edx
c010080e:	73 21                	jae    c0100831 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100810:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100813:	89 c2                	mov    %eax,%edx
c0100815:	89 d0                	mov    %edx,%eax
c0100817:	01 c0                	add    %eax,%eax
c0100819:	01 d0                	add    %edx,%eax
c010081b:	c1 e0 02             	shl    $0x2,%eax
c010081e:	89 c2                	mov    %eax,%edx
c0100820:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100823:	01 d0                	add    %edx,%eax
c0100825:	8b 10                	mov    (%eax),%edx
c0100827:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010082a:	01 c2                	add    %eax,%edx
c010082c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100831:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100834:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100837:	39 c2                	cmp    %eax,%edx
c0100839:	7d 4a                	jge    c0100885 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010083b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083e:	83 c0 01             	add    $0x1,%eax
c0100841:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100844:	eb 18                	jmp    c010085e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100846:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100849:	8b 40 14             	mov    0x14(%eax),%eax
c010084c:	8d 50 01             	lea    0x1(%eax),%edx
c010084f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100852:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100855:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100858:	83 c0 01             	add    $0x1,%eax
c010085b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010085e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100861:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100864:	39 c2                	cmp    %eax,%edx
c0100866:	7d 1d                	jge    c0100885 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	89 d0                	mov    %edx,%eax
c010086f:	01 c0                	add    %eax,%eax
c0100871:	01 d0                	add    %edx,%eax
c0100873:	c1 e0 02             	shl    $0x2,%eax
c0100876:	89 c2                	mov    %eax,%edx
c0100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087b:	01 d0                	add    %edx,%eax
c010087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100881:	3c a0                	cmp    $0xa0,%al
c0100883:	74 c1                	je     c0100846 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100885:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010088a:	c9                   	leave  
c010088b:	c3                   	ret    

c010088c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010088c:	55                   	push   %ebp
c010088d:	89 e5                	mov    %esp,%ebp
c010088f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100892:	c7 04 24 f6 61 10 c0 	movl   $0xc01061f6,(%esp)
c0100899:	e8 ba fa ff ff       	call   c0100358 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a5:	c0 
c01008a6:	c7 04 24 0f 62 10 c0 	movl   $0xc010620f,(%esp)
c01008ad:	e8 a6 fa ff ff       	call   c0100358 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b2:	c7 44 24 04 2c 61 10 	movl   $0xc010612c,0x4(%esp)
c01008b9:	c0 
c01008ba:	c7 04 24 27 62 10 c0 	movl   $0xc0106227,(%esp)
c01008c1:	e8 92 fa ff ff       	call   c0100358 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008cd:	c0 
c01008ce:	c7 04 24 3f 62 10 c0 	movl   $0xc010623f,(%esp)
c01008d5:	e8 7e fa ff ff       	call   c0100358 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008da:	c7 44 24 04 88 af 11 	movl   $0xc011af88,0x4(%esp)
c01008e1:	c0 
c01008e2:	c7 04 24 57 62 10 c0 	movl   $0xc0106257,(%esp)
c01008e9:	e8 6a fa ff ff       	call   c0100358 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ee:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c01008f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008fe:	29 c2                	sub    %eax,%edx
c0100900:	89 d0                	mov    %edx,%eax
c0100902:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100908:	85 c0                	test   %eax,%eax
c010090a:	0f 48 c2             	cmovs  %edx,%eax
c010090d:	c1 f8 0a             	sar    $0xa,%eax
c0100910:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100914:	c7 04 24 70 62 10 c0 	movl   $0xc0106270,(%esp)
c010091b:	e8 38 fa ff ff       	call   c0100358 <cprintf>
}
c0100920:	c9                   	leave  
c0100921:	c3                   	ret    

c0100922 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100922:	55                   	push   %ebp
c0100923:	89 e5                	mov    %esp,%ebp
c0100925:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010092b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010092e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100932:	8b 45 08             	mov    0x8(%ebp),%eax
c0100935:	89 04 24             	mov    %eax,(%esp)
c0100938:	e8 12 fc ff ff       	call   c010054f <debuginfo_eip>
c010093d:	85 c0                	test   %eax,%eax
c010093f:	74 15                	je     c0100956 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100941:	8b 45 08             	mov    0x8(%ebp),%eax
c0100944:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100948:	c7 04 24 9a 62 10 c0 	movl   $0xc010629a,(%esp)
c010094f:	e8 04 fa ff ff       	call   c0100358 <cprintf>
c0100954:	eb 6d                	jmp    c01009c3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010095d:	eb 1c                	jmp    c010097b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100962:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100965:	01 d0                	add    %edx,%eax
c0100967:	0f b6 00             	movzbl (%eax),%eax
c010096a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100970:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100973:	01 ca                	add    %ecx,%edx
c0100975:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100977:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010097b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010097e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100981:	7f dc                	jg     c010095f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100983:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098c:	01 d0                	add    %edx,%eax
c010098e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100991:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100994:	8b 55 08             	mov    0x8(%ebp),%edx
c0100997:	89 d1                	mov    %edx,%ecx
c0100999:	29 c1                	sub    %eax,%ecx
c010099b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010099e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a5:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009ab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b7:	c7 04 24 b6 62 10 c0 	movl   $0xc01062b6,(%esp)
c01009be:	e8 95 f9 ff ff       	call   c0100358 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009c3:	c9                   	leave  
c01009c4:	c3                   	ret    

c01009c5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009cb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d4:	c9                   	leave  
c01009d5:	c3                   	ret    

c01009d6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d6:	55                   	push   %ebp
c01009d7:	89 e5                	mov    %esp,%ebp
c01009d9:	53                   	push   %ebx
c01009da:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009dd:	89 e8                	mov    %ebp,%eax
c01009df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
   uint32_t ebp=read_ebp();
c01009e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
c01009e8:	e8 d8 ff ff ff       	call   c01009c5 <read_eip>
c01009ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;// from 0 .. STACKFRAME_DEPTH
	for (i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c01009f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f7:	e9 8d 00 00 00       	jmp    c0100a89 <print_stackframe+0xb3>
		// printf value of ebp, eip
		cprintf("ebp:0x%08x eip:0x%08x",ebp,eip);
c01009fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0a:	c7 04 24 c8 62 10 c0 	movl   $0xc01062c8,(%esp)
c0100a11:	e8 42 f9 ff ff       	call   c0100358 <cprintf>
//
		uint32_t *tmp=(uint32_t *)ebp+2;
c0100a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a19:	83 c0 08             	add    $0x8,%eax
c0100a1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
//每个数组大小为4，输出数组元素
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x",*(tmp+0),*(tmp+1),*(tmp+2),*(tmp+3));
c0100a1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a22:	83 c0 0c             	add    $0xc,%eax
c0100a25:	8b 18                	mov    (%eax),%ebx
c0100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2a:	83 c0 08             	add    $0x8,%eax
c0100a2d:	8b 08                	mov    (%eax),%ecx
c0100a2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a32:	83 c0 04             	add    $0x4,%eax
c0100a35:	8b 10                	mov    (%eax),%edx
c0100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a3a:	8b 00                	mov    (%eax),%eax
c0100a3c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a40:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a44:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4c:	c7 04 24 e0 62 10 c0 	movl   $0xc01062e0,(%esp)
c0100a53:	e8 00 f9 ff ff       	call   c0100358 <cprintf>

		cprintf("\n");
c0100a58:	c7 04 24 01 63 10 c0 	movl   $0xc0106301,(%esp)
c0100a5f:	e8 f4 f8 ff ff       	call   c0100358 <cprintf>

//eip指向异常指令的下一条指令，所以要减1
		print_debuginfo(eip-1);
c0100a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a67:	83 e8 01             	sub    $0x1,%eax
c0100a6a:	89 04 24             	mov    %eax,(%esp)
c0100a6d:	e8 b0 fe ff ff       	call   c0100922 <print_debuginfo>

 // 将ebp 和eip设置为上一个栈帧的ebp和eip
 //  注意要先设置eip后设置ebp，否则当ebp被修改后，eip就无法找到正确的位置
		eip=((uint32_t *)ebp)[1];//popup a calling stackframe
c0100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a75:	83 c0 04             	add    $0x4,%eax
c0100a78:	8b 00                	mov    (%eax),%eax
c0100a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
c0100a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a80:	8b 00                	mov    (%eax),%eax
c0100a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
   uint32_t ebp=read_ebp();
	uint32_t eip=read_eip();
	int i;// from 0 .. STACKFRAME_DEPTH
	for (i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100a85:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a89:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a8d:	7f 0a                	jg     c0100a99 <print_stackframe+0xc3>
c0100a8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a93:	0f 85 63 ff ff ff    	jne    c01009fc <print_stackframe+0x26>
 // 将ebp 和eip设置为上一个栈帧的ebp和eip
 //  注意要先设置eip后设置ebp，否则当ebp被修改后，eip就无法找到正确的位置
		eip=((uint32_t *)ebp)[1];//popup a calling stackframe
		ebp=((uint32_t *)ebp)[0];
	}
}
c0100a99:	83 c4 44             	add    $0x44,%esp
c0100a9c:	5b                   	pop    %ebx
c0100a9d:	5d                   	pop    %ebp
c0100a9e:	c3                   	ret    

c0100a9f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a9f:	55                   	push   %ebp
c0100aa0:	89 e5                	mov    %esp,%ebp
c0100aa2:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aac:	eb 0c                	jmp    c0100aba <parse+0x1b>
            *buf ++ = '\0';
c0100aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab1:	8d 50 01             	lea    0x1(%eax),%edx
c0100ab4:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ab7:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abd:	0f b6 00             	movzbl (%eax),%eax
c0100ac0:	84 c0                	test   %al,%al
c0100ac2:	74 1d                	je     c0100ae1 <parse+0x42>
c0100ac4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac7:	0f b6 00             	movzbl (%eax),%eax
c0100aca:	0f be c0             	movsbl %al,%eax
c0100acd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad1:	c7 04 24 84 63 10 c0 	movl   $0xc0106384,(%esp)
c0100ad8:	e8 07 53 00 00       	call   c0105de4 <strchr>
c0100add:	85 c0                	test   %eax,%eax
c0100adf:	75 cd                	jne    c0100aae <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ae1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae4:	0f b6 00             	movzbl (%eax),%eax
c0100ae7:	84 c0                	test   %al,%al
c0100ae9:	75 02                	jne    c0100aed <parse+0x4e>
            break;
c0100aeb:	eb 67                	jmp    c0100b54 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100aed:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100af1:	75 14                	jne    c0100b07 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100af3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100afa:	00 
c0100afb:	c7 04 24 89 63 10 c0 	movl   $0xc0106389,(%esp)
c0100b02:	e8 51 f8 ff ff       	call   c0100358 <cprintf>
        }
        argv[argc ++] = buf;
c0100b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b0a:	8d 50 01             	lea    0x1(%eax),%edx
c0100b0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b17:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b1a:	01 c2                	add    %eax,%edx
c0100b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1f:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b21:	eb 04                	jmp    c0100b27 <parse+0x88>
            buf ++;
c0100b23:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b27:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b2a:	0f b6 00             	movzbl (%eax),%eax
c0100b2d:	84 c0                	test   %al,%al
c0100b2f:	74 1d                	je     c0100b4e <parse+0xaf>
c0100b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b34:	0f b6 00             	movzbl (%eax),%eax
c0100b37:	0f be c0             	movsbl %al,%eax
c0100b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b3e:	c7 04 24 84 63 10 c0 	movl   $0xc0106384,(%esp)
c0100b45:	e8 9a 52 00 00       	call   c0105de4 <strchr>
c0100b4a:	85 c0                	test   %eax,%eax
c0100b4c:	74 d5                	je     c0100b23 <parse+0x84>
            buf ++;
        }
    }
c0100b4e:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4f:	e9 66 ff ff ff       	jmp    c0100aba <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b57:	c9                   	leave  
c0100b58:	c3                   	ret    

c0100b59 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b59:	55                   	push   %ebp
c0100b5a:	89 e5                	mov    %esp,%ebp
c0100b5c:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b5f:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b69:	89 04 24             	mov    %eax,(%esp)
c0100b6c:	e8 2e ff ff ff       	call   c0100a9f <parse>
c0100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b78:	75 0a                	jne    c0100b84 <runcmd+0x2b>
        return 0;
c0100b7a:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b7f:	e9 85 00 00 00       	jmp    c0100c09 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b8b:	eb 5c                	jmp    c0100be9 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b8d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b93:	89 d0                	mov    %edx,%eax
c0100b95:	01 c0                	add    %eax,%eax
c0100b97:	01 d0                	add    %edx,%eax
c0100b99:	c1 e0 02             	shl    $0x2,%eax
c0100b9c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100ba1:	8b 00                	mov    (%eax),%eax
c0100ba3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ba7:	89 04 24             	mov    %eax,(%esp)
c0100baa:	e8 96 51 00 00       	call   c0105d45 <strcmp>
c0100baf:	85 c0                	test   %eax,%eax
c0100bb1:	75 32                	jne    c0100be5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bb6:	89 d0                	mov    %edx,%eax
c0100bb8:	01 c0                	add    %eax,%eax
c0100bba:	01 d0                	add    %edx,%eax
c0100bbc:	c1 e0 02             	shl    $0x2,%eax
c0100bbf:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100bc4:	8b 40 08             	mov    0x8(%eax),%eax
c0100bc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bca:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bd0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bd4:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bd7:	83 c2 04             	add    $0x4,%edx
c0100bda:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bde:	89 0c 24             	mov    %ecx,(%esp)
c0100be1:	ff d0                	call   *%eax
c0100be3:	eb 24                	jmp    c0100c09 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bec:	83 f8 02             	cmp    $0x2,%eax
c0100bef:	76 9c                	jbe    c0100b8d <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bf1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf8:	c7 04 24 a7 63 10 c0 	movl   $0xc01063a7,(%esp)
c0100bff:	e8 54 f7 ff ff       	call   c0100358 <cprintf>
    return 0;
c0100c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c09:	c9                   	leave  
c0100c0a:	c3                   	ret    

c0100c0b <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c0b:	55                   	push   %ebp
c0100c0c:	89 e5                	mov    %esp,%ebp
c0100c0e:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c11:	c7 04 24 c0 63 10 c0 	movl   $0xc01063c0,(%esp)
c0100c18:	e8 3b f7 ff ff       	call   c0100358 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c1d:	c7 04 24 e8 63 10 c0 	movl   $0xc01063e8,(%esp)
c0100c24:	e8 2f f7 ff ff       	call   c0100358 <cprintf>

    if (tf != NULL) {
c0100c29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c2d:	74 0b                	je     c0100c3a <kmonitor+0x2f>
        print_trapframe(tf);
c0100c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c32:	89 04 24             	mov    %eax,(%esp)
c0100c35:	e8 67 0e 00 00       	call   c0101aa1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c3a:	c7 04 24 0d 64 10 c0 	movl   $0xc010640d,(%esp)
c0100c41:	e8 09 f6 ff ff       	call   c010024f <readline>
c0100c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c4d:	74 18                	je     c0100c67 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c59:	89 04 24             	mov    %eax,(%esp)
c0100c5c:	e8 f8 fe ff ff       	call   c0100b59 <runcmd>
c0100c61:	85 c0                	test   %eax,%eax
c0100c63:	79 02                	jns    c0100c67 <kmonitor+0x5c>
                break;
c0100c65:	eb 02                	jmp    c0100c69 <kmonitor+0x5e>
            }
        }
    }
c0100c67:	eb d1                	jmp    c0100c3a <kmonitor+0x2f>
}
c0100c69:	c9                   	leave  
c0100c6a:	c3                   	ret    

c0100c6b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c6b:	55                   	push   %ebp
c0100c6c:	89 e5                	mov    %esp,%ebp
c0100c6e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c78:	eb 3f                	jmp    c0100cb9 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c7d:	89 d0                	mov    %edx,%eax
c0100c7f:	01 c0                	add    %eax,%eax
c0100c81:	01 d0                	add    %edx,%eax
c0100c83:	c1 e0 02             	shl    $0x2,%eax
c0100c86:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c8b:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c91:	89 d0                	mov    %edx,%eax
c0100c93:	01 c0                	add    %eax,%eax
c0100c95:	01 d0                	add    %edx,%eax
c0100c97:	c1 e0 02             	shl    $0x2,%eax
c0100c9a:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c9f:	8b 00                	mov    (%eax),%eax
c0100ca1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca9:	c7 04 24 11 64 10 c0 	movl   $0xc0106411,(%esp)
c0100cb0:	e8 a3 f6 ff ff       	call   c0100358 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbc:	83 f8 02             	cmp    $0x2,%eax
c0100cbf:	76 b9                	jbe    c0100c7a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc6:	c9                   	leave  
c0100cc7:	c3                   	ret    

c0100cc8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cc8:	55                   	push   %ebp
c0100cc9:	89 e5                	mov    %esp,%ebp
c0100ccb:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cce:	e8 b9 fb ff ff       	call   c010088c <print_kerninfo>
    return 0;
c0100cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd8:	c9                   	leave  
c0100cd9:	c3                   	ret    

c0100cda <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cda:	55                   	push   %ebp
c0100cdb:	89 e5                	mov    %esp,%ebp
c0100cdd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ce0:	e8 f1 fc ff ff       	call   c01009d6 <print_stackframe>
    return 0;
c0100ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cea:	c9                   	leave  
c0100ceb:	c3                   	ret    

c0100cec <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cec:	55                   	push   %ebp
c0100ced:	89 e5                	mov    %esp,%ebp
c0100cef:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cf2:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cf7:	85 c0                	test   %eax,%eax
c0100cf9:	74 02                	je     c0100cfd <__panic+0x11>
        goto panic_dead;
c0100cfb:	eb 59                	jmp    c0100d56 <__panic+0x6a>
    }
    is_panic = 1;
c0100cfd:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100d04:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d07:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d10:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d14:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1b:	c7 04 24 1a 64 10 c0 	movl   $0xc010641a,(%esp)
c0100d22:	e8 31 f6 ff ff       	call   c0100358 <cprintf>
    vcprintf(fmt, ap);
c0100d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d2e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d31:	89 04 24             	mov    %eax,(%esp)
c0100d34:	e8 ec f5 ff ff       	call   c0100325 <vcprintf>
    cprintf("\n");
c0100d39:	c7 04 24 36 64 10 c0 	movl   $0xc0106436,(%esp)
c0100d40:	e8 13 f6 ff ff       	call   c0100358 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d45:	c7 04 24 38 64 10 c0 	movl   $0xc0106438,(%esp)
c0100d4c:	e8 07 f6 ff ff       	call   c0100358 <cprintf>
    print_stackframe();
c0100d51:	e8 80 fc ff ff       	call   c01009d6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d56:	e8 85 09 00 00       	call   c01016e0 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d62:	e8 a4 fe ff ff       	call   c0100c0b <kmonitor>
    }
c0100d67:	eb f2                	jmp    c0100d5b <__panic+0x6f>

c0100d69 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d69:	55                   	push   %ebp
c0100d6a:	89 e5                	mov    %esp,%ebp
c0100d6c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d6f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d78:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d83:	c7 04 24 4a 64 10 c0 	movl   $0xc010644a,(%esp)
c0100d8a:	e8 c9 f5 ff ff       	call   c0100358 <cprintf>
    vcprintf(fmt, ap);
c0100d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d96:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d99:	89 04 24             	mov    %eax,(%esp)
c0100d9c:	e8 84 f5 ff ff       	call   c0100325 <vcprintf>
    cprintf("\n");
c0100da1:	c7 04 24 36 64 10 c0 	movl   $0xc0106436,(%esp)
c0100da8:	e8 ab f5 ff ff       	call   c0100358 <cprintf>
    va_end(ap);
}
c0100dad:	c9                   	leave  
c0100dae:	c3                   	ret    

c0100daf <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100daf:	55                   	push   %ebp
c0100db0:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100db2:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100db7:	5d                   	pop    %ebp
c0100db8:	c3                   	ret    

c0100db9 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100db9:	55                   	push   %ebp
c0100dba:	89 e5                	mov    %esp,%ebp
c0100dbc:	83 ec 28             	sub    $0x28,%esp
c0100dbf:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dc5:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dcd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dd1:	ee                   	out    %al,(%dx)
c0100dd2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dd8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100ddc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100de0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100de4:	ee                   	out    %al,(%dx)
c0100de5:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100deb:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100def:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100df3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100df7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100df8:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100dff:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e02:	c7 04 24 68 64 10 c0 	movl   $0xc0106468,(%esp)
c0100e09:	e8 4a f5 ff ff       	call   c0100358 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e15:	e8 24 09 00 00       	call   c010173e <pic_enable>
}
c0100e1a:	c9                   	leave  
c0100e1b:	c3                   	ret    

c0100e1c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e1c:	55                   	push   %ebp
c0100e1d:	89 e5                	mov    %esp,%ebp
c0100e1f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e22:	9c                   	pushf  
c0100e23:	58                   	pop    %eax
c0100e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e2a:	25 00 02 00 00       	and    $0x200,%eax
c0100e2f:	85 c0                	test   %eax,%eax
c0100e31:	74 0c                	je     c0100e3f <__intr_save+0x23>
        intr_disable();
c0100e33:	e8 a8 08 00 00       	call   c01016e0 <intr_disable>
        return 1;
c0100e38:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e3d:	eb 05                	jmp    c0100e44 <__intr_save+0x28>
    }
    return 0;
c0100e3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e44:	c9                   	leave  
c0100e45:	c3                   	ret    

c0100e46 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e46:	55                   	push   %ebp
c0100e47:	89 e5                	mov    %esp,%ebp
c0100e49:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e50:	74 05                	je     c0100e57 <__intr_restore+0x11>
        intr_enable();
c0100e52:	e8 83 08 00 00       	call   c01016da <intr_enable>
    }
}
c0100e57:	c9                   	leave  
c0100e58:	c3                   	ret    

c0100e59 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e59:	55                   	push   %ebp
c0100e5a:	89 e5                	mov    %esp,%ebp
c0100e5c:	83 ec 10             	sub    $0x10,%esp
c0100e5f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e65:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e69:	89 c2                	mov    %eax,%edx
c0100e6b:	ec                   	in     (%dx),%al
c0100e6c:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e6f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e75:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e79:	89 c2                	mov    %eax,%edx
c0100e7b:	ec                   	in     (%dx),%al
c0100e7c:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e7f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e85:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e89:	89 c2                	mov    %eax,%edx
c0100e8b:	ec                   	in     (%dx),%al
c0100e8c:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e8f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e95:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e99:	89 c2                	mov    %eax,%edx
c0100e9b:	ec                   	in     (%dx),%al
c0100e9c:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e9f:	c9                   	leave  
c0100ea0:	c3                   	ret    

c0100ea1 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ea1:	55                   	push   %ebp
c0100ea2:	89 e5                	mov    %esp,%ebp
c0100ea4:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ea7:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb1:	0f b7 00             	movzwl (%eax),%eax
c0100eb4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebb:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ec0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec3:	0f b7 00             	movzwl (%eax),%eax
c0100ec6:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eca:	74 12                	je     c0100ede <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ecc:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ed3:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100eda:	b4 03 
c0100edc:	eb 13                	jmp    c0100ef1 <cga_init+0x50>
    } else {
        *cp = was;
c0100ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee5:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee8:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100eef:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ef1:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef8:	0f b7 c0             	movzwl %ax,%eax
c0100efb:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100eff:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f03:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f07:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f0b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f0c:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f13:	83 c0 01             	add    $0x1,%eax
c0100f16:	0f b7 c0             	movzwl %ax,%eax
c0100f19:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f1d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f21:	89 c2                	mov    %eax,%edx
c0100f23:	ec                   	in     (%dx),%al
c0100f24:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f27:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f2b:	0f b6 c0             	movzbl %al,%eax
c0100f2e:	c1 e0 08             	shl    $0x8,%eax
c0100f31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f34:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3b:	0f b7 c0             	movzwl %ax,%eax
c0100f3e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f42:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f46:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f4a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f4e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f4f:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f56:	83 c0 01             	add    $0x1,%eax
c0100f59:	0f b7 c0             	movzwl %ax,%eax
c0100f5c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f60:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f64:	89 c2                	mov    %eax,%edx
c0100f66:	ec                   	in     (%dx),%al
c0100f67:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f6a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f6e:	0f b6 c0             	movzbl %al,%eax
c0100f71:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f74:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f77:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f7f:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f85:	c9                   	leave  
c0100f86:	c3                   	ret    

c0100f87 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f87:	55                   	push   %ebp
c0100f88:	89 e5                	mov    %esp,%ebp
c0100f8a:	83 ec 48             	sub    $0x48,%esp
c0100f8d:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f93:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f97:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f9b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f9f:	ee                   	out    %al,(%dx)
c0100fa0:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100fa6:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100faa:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fb2:	ee                   	out    %al,(%dx)
c0100fb3:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fb9:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fbd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fc1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fc5:	ee                   	out    %al,(%dx)
c0100fc6:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fcc:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fd0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fd4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fd8:	ee                   	out    %al,(%dx)
c0100fd9:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fdf:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fe3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fe7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100feb:	ee                   	out    %al,(%dx)
c0100fec:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100ff2:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100ff6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100ffa:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ffe:	ee                   	out    %al,(%dx)
c0100fff:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101005:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101009:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010100d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101011:	ee                   	out    %al,(%dx)
c0101012:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101018:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010101c:	89 c2                	mov    %eax,%edx
c010101e:	ec                   	in     (%dx),%al
c010101f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101022:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101026:	3c ff                	cmp    $0xff,%al
c0101028:	0f 95 c0             	setne  %al
c010102b:	0f b6 c0             	movzbl %al,%eax
c010102e:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101033:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101039:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010103d:	89 c2                	mov    %eax,%edx
c010103f:	ec                   	in     (%dx),%al
c0101040:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101043:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101049:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010104d:	89 c2                	mov    %eax,%edx
c010104f:	ec                   	in     (%dx),%al
c0101050:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101053:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101058:	85 c0                	test   %eax,%eax
c010105a:	74 0c                	je     c0101068 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010105c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101063:	e8 d6 06 00 00       	call   c010173e <pic_enable>
    }
}
c0101068:	c9                   	leave  
c0101069:	c3                   	ret    

c010106a <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010106a:	55                   	push   %ebp
c010106b:	89 e5                	mov    %esp,%ebp
c010106d:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101070:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101077:	eb 09                	jmp    c0101082 <lpt_putc_sub+0x18>
        delay();
c0101079:	e8 db fd ff ff       	call   c0100e59 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010107e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101082:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101088:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010108c:	89 c2                	mov    %eax,%edx
c010108e:	ec                   	in     (%dx),%al
c010108f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101092:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101096:	84 c0                	test   %al,%al
c0101098:	78 09                	js     c01010a3 <lpt_putc_sub+0x39>
c010109a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010a1:	7e d6                	jle    c0101079 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01010a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01010a6:	0f b6 c0             	movzbl %al,%eax
c01010a9:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010af:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010b2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010b6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010ba:	ee                   	out    %al,(%dx)
c01010bb:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010c1:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010c5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010c9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010cd:	ee                   	out    %al,(%dx)
c01010ce:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010d4:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010d8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010dc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010e0:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010e1:	c9                   	leave  
c01010e2:	c3                   	ret    

c01010e3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010e3:	55                   	push   %ebp
c01010e4:	89 e5                	mov    %esp,%ebp
c01010e6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010e9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010ed:	74 0d                	je     c01010fc <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f2:	89 04 24             	mov    %eax,(%esp)
c01010f5:	e8 70 ff ff ff       	call   c010106a <lpt_putc_sub>
c01010fa:	eb 24                	jmp    c0101120 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010fc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101103:	e8 62 ff ff ff       	call   c010106a <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101108:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010110f:	e8 56 ff ff ff       	call   c010106a <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101114:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010111b:	e8 4a ff ff ff       	call   c010106a <lpt_putc_sub>
    }
}
c0101120:	c9                   	leave  
c0101121:	c3                   	ret    

c0101122 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101122:	55                   	push   %ebp
c0101123:	89 e5                	mov    %esp,%ebp
c0101125:	53                   	push   %ebx
c0101126:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101129:	8b 45 08             	mov    0x8(%ebp),%eax
c010112c:	b0 00                	mov    $0x0,%al
c010112e:	85 c0                	test   %eax,%eax
c0101130:	75 07                	jne    c0101139 <cga_putc+0x17>
        c |= 0x0700;
c0101132:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101139:	8b 45 08             	mov    0x8(%ebp),%eax
c010113c:	0f b6 c0             	movzbl %al,%eax
c010113f:	83 f8 0a             	cmp    $0xa,%eax
c0101142:	74 4c                	je     c0101190 <cga_putc+0x6e>
c0101144:	83 f8 0d             	cmp    $0xd,%eax
c0101147:	74 57                	je     c01011a0 <cga_putc+0x7e>
c0101149:	83 f8 08             	cmp    $0x8,%eax
c010114c:	0f 85 88 00 00 00    	jne    c01011da <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101152:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101159:	66 85 c0             	test   %ax,%ax
c010115c:	74 30                	je     c010118e <cga_putc+0x6c>
            crt_pos --;
c010115e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101165:	83 e8 01             	sub    $0x1,%eax
c0101168:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010116e:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101173:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010117a:	0f b7 d2             	movzwl %dx,%edx
c010117d:	01 d2                	add    %edx,%edx
c010117f:	01 c2                	add    %eax,%edx
c0101181:	8b 45 08             	mov    0x8(%ebp),%eax
c0101184:	b0 00                	mov    $0x0,%al
c0101186:	83 c8 20             	or     $0x20,%eax
c0101189:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010118c:	eb 72                	jmp    c0101200 <cga_putc+0xde>
c010118e:	eb 70                	jmp    c0101200 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101190:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101197:	83 c0 50             	add    $0x50,%eax
c010119a:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011a0:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c01011a7:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c01011ae:	0f b7 c1             	movzwl %cx,%eax
c01011b1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011b7:	c1 e8 10             	shr    $0x10,%eax
c01011ba:	89 c2                	mov    %eax,%edx
c01011bc:	66 c1 ea 06          	shr    $0x6,%dx
c01011c0:	89 d0                	mov    %edx,%eax
c01011c2:	c1 e0 02             	shl    $0x2,%eax
c01011c5:	01 d0                	add    %edx,%eax
c01011c7:	c1 e0 04             	shl    $0x4,%eax
c01011ca:	29 c1                	sub    %eax,%ecx
c01011cc:	89 ca                	mov    %ecx,%edx
c01011ce:	89 d8                	mov    %ebx,%eax
c01011d0:	29 d0                	sub    %edx,%eax
c01011d2:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011d8:	eb 26                	jmp    c0101200 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011da:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011e0:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011e7:	8d 50 01             	lea    0x1(%eax),%edx
c01011ea:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011f1:	0f b7 c0             	movzwl %ax,%eax
c01011f4:	01 c0                	add    %eax,%eax
c01011f6:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01011fc:	66 89 02             	mov    %ax,(%edx)
        break;
c01011ff:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101200:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101207:	66 3d cf 07          	cmp    $0x7cf,%ax
c010120b:	76 5b                	jbe    c0101268 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010120d:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101212:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101218:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010121d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101224:	00 
c0101225:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101229:	89 04 24             	mov    %eax,(%esp)
c010122c:	e8 b1 4d 00 00       	call   c0105fe2 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101231:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101238:	eb 15                	jmp    c010124f <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010123a:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010123f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101242:	01 d2                	add    %edx,%edx
c0101244:	01 d0                	add    %edx,%eax
c0101246:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010124b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010124f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101256:	7e e2                	jle    c010123a <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101258:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010125f:	83 e8 50             	sub    $0x50,%eax
c0101262:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101268:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010126f:	0f b7 c0             	movzwl %ax,%eax
c0101272:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101276:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010127a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010127e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101282:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101283:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010128a:	66 c1 e8 08          	shr    $0x8,%ax
c010128e:	0f b6 c0             	movzbl %al,%eax
c0101291:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101298:	83 c2 01             	add    $0x1,%edx
c010129b:	0f b7 d2             	movzwl %dx,%edx
c010129e:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01012a2:	88 45 ed             	mov    %al,-0x13(%ebp)
c01012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012ae:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c01012b5:	0f b7 c0             	movzwl %ax,%eax
c01012b8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012bc:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012c0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012c4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012c8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012c9:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012d0:	0f b6 c0             	movzbl %al,%eax
c01012d3:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012da:	83 c2 01             	add    $0x1,%edx
c01012dd:	0f b7 d2             	movzwl %dx,%edx
c01012e0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012e4:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012e7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012eb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ef:	ee                   	out    %al,(%dx)
}
c01012f0:	83 c4 34             	add    $0x34,%esp
c01012f3:	5b                   	pop    %ebx
c01012f4:	5d                   	pop    %ebp
c01012f5:	c3                   	ret    

c01012f6 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012f6:	55                   	push   %ebp
c01012f7:	89 e5                	mov    %esp,%ebp
c01012f9:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101303:	eb 09                	jmp    c010130e <serial_putc_sub+0x18>
        delay();
c0101305:	e8 4f fb ff ff       	call   c0100e59 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010130a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010130e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101314:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101318:	89 c2                	mov    %eax,%edx
c010131a:	ec                   	in     (%dx),%al
c010131b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010131e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101322:	0f b6 c0             	movzbl %al,%eax
c0101325:	83 e0 20             	and    $0x20,%eax
c0101328:	85 c0                	test   %eax,%eax
c010132a:	75 09                	jne    c0101335 <serial_putc_sub+0x3f>
c010132c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101333:	7e d0                	jle    c0101305 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101335:	8b 45 08             	mov    0x8(%ebp),%eax
c0101338:	0f b6 c0             	movzbl %al,%eax
c010133b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101341:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101344:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101348:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010134c:	ee                   	out    %al,(%dx)
}
c010134d:	c9                   	leave  
c010134e:	c3                   	ret    

c010134f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010134f:	55                   	push   %ebp
c0101350:	89 e5                	mov    %esp,%ebp
c0101352:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101355:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101359:	74 0d                	je     c0101368 <serial_putc+0x19>
        serial_putc_sub(c);
c010135b:	8b 45 08             	mov    0x8(%ebp),%eax
c010135e:	89 04 24             	mov    %eax,(%esp)
c0101361:	e8 90 ff ff ff       	call   c01012f6 <serial_putc_sub>
c0101366:	eb 24                	jmp    c010138c <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101368:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136f:	e8 82 ff ff ff       	call   c01012f6 <serial_putc_sub>
        serial_putc_sub(' ');
c0101374:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010137b:	e8 76 ff ff ff       	call   c01012f6 <serial_putc_sub>
        serial_putc_sub('\b');
c0101380:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101387:	e8 6a ff ff ff       	call   c01012f6 <serial_putc_sub>
    }
}
c010138c:	c9                   	leave  
c010138d:	c3                   	ret    

c010138e <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010138e:	55                   	push   %ebp
c010138f:	89 e5                	mov    %esp,%ebp
c0101391:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101394:	eb 33                	jmp    c01013c9 <cons_intr+0x3b>
        if (c != 0) {
c0101396:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010139a:	74 2d                	je     c01013c9 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010139c:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013a1:	8d 50 01             	lea    0x1(%eax),%edx
c01013a4:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c01013aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013ad:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013b3:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013b8:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013bd:	75 0a                	jne    c01013c9 <cons_intr+0x3b>
                cons.wpos = 0;
c01013bf:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013c6:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01013cc:	ff d0                	call   *%eax
c01013ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013d1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013d5:	75 bf                	jne    c0101396 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013d7:	c9                   	leave  
c01013d8:	c3                   	ret    

c01013d9 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013d9:	55                   	push   %ebp
c01013da:	89 e5                	mov    %esp,%ebp
c01013dc:	83 ec 10             	sub    $0x10,%esp
c01013df:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013e9:	89 c2                	mov    %eax,%edx
c01013eb:	ec                   	in     (%dx),%al
c01013ec:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013ef:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013f3:	0f b6 c0             	movzbl %al,%eax
c01013f6:	83 e0 01             	and    $0x1,%eax
c01013f9:	85 c0                	test   %eax,%eax
c01013fb:	75 07                	jne    c0101404 <serial_proc_data+0x2b>
        return -1;
c01013fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101402:	eb 2a                	jmp    c010142e <serial_proc_data+0x55>
c0101404:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010140a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010140e:	89 c2                	mov    %eax,%edx
c0101410:	ec                   	in     (%dx),%al
c0101411:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101414:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101418:	0f b6 c0             	movzbl %al,%eax
c010141b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010141e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101422:	75 07                	jne    c010142b <serial_proc_data+0x52>
        c = '\b';
c0101424:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010142b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010142e:	c9                   	leave  
c010142f:	c3                   	ret    

c0101430 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101430:	55                   	push   %ebp
c0101431:	89 e5                	mov    %esp,%ebp
c0101433:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101436:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010143b:	85 c0                	test   %eax,%eax
c010143d:	74 0c                	je     c010144b <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010143f:	c7 04 24 d9 13 10 c0 	movl   $0xc01013d9,(%esp)
c0101446:	e8 43 ff ff ff       	call   c010138e <cons_intr>
    }
}
c010144b:	c9                   	leave  
c010144c:	c3                   	ret    

c010144d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010144d:	55                   	push   %ebp
c010144e:	89 e5                	mov    %esp,%ebp
c0101450:	83 ec 38             	sub    $0x38,%esp
c0101453:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101459:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010145d:	89 c2                	mov    %eax,%edx
c010145f:	ec                   	in     (%dx),%al
c0101460:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101463:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101467:	0f b6 c0             	movzbl %al,%eax
c010146a:	83 e0 01             	and    $0x1,%eax
c010146d:	85 c0                	test   %eax,%eax
c010146f:	75 0a                	jne    c010147b <kbd_proc_data+0x2e>
        return -1;
c0101471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101476:	e9 59 01 00 00       	jmp    c01015d4 <kbd_proc_data+0x187>
c010147b:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101481:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101485:	89 c2                	mov    %eax,%edx
c0101487:	ec                   	in     (%dx),%al
c0101488:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010148b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010148f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101492:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101496:	75 17                	jne    c01014af <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101498:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010149d:	83 c8 40             	or     $0x40,%eax
c01014a0:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014a5:	b8 00 00 00 00       	mov    $0x0,%eax
c01014aa:	e9 25 01 00 00       	jmp    c01015d4 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014af:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b3:	84 c0                	test   %al,%al
c01014b5:	79 47                	jns    c01014fe <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014b7:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014bc:	83 e0 40             	and    $0x40,%eax
c01014bf:	85 c0                	test   %eax,%eax
c01014c1:	75 09                	jne    c01014cc <kbd_proc_data+0x7f>
c01014c3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c7:	83 e0 7f             	and    $0x7f,%eax
c01014ca:	eb 04                	jmp    c01014d0 <kbd_proc_data+0x83>
c01014cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d0:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d7:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014de:	83 c8 40             	or     $0x40,%eax
c01014e1:	0f b6 c0             	movzbl %al,%eax
c01014e4:	f7 d0                	not    %eax
c01014e6:	89 c2                	mov    %eax,%edx
c01014e8:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014ed:	21 d0                	and    %edx,%eax
c01014ef:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014f4:	b8 00 00 00 00       	mov    $0x0,%eax
c01014f9:	e9 d6 00 00 00       	jmp    c01015d4 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014fe:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101503:	83 e0 40             	and    $0x40,%eax
c0101506:	85 c0                	test   %eax,%eax
c0101508:	74 11                	je     c010151b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010150a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010150e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101513:	83 e0 bf             	and    $0xffffffbf,%eax
c0101516:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c0101526:	0f b6 d0             	movzbl %al,%edx
c0101529:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152e:	09 d0                	or     %edx,%eax
c0101530:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101539:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101540:	0f b6 d0             	movzbl %al,%edx
c0101543:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101548:	31 d0                	xor    %edx,%eax
c010154a:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c010154f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101554:	83 e0 03             	and    $0x3,%eax
c0101557:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c010155e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101562:	01 d0                	add    %edx,%eax
c0101564:	0f b6 00             	movzbl (%eax),%eax
c0101567:	0f b6 c0             	movzbl %al,%eax
c010156a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010156d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101572:	83 e0 08             	and    $0x8,%eax
c0101575:	85 c0                	test   %eax,%eax
c0101577:	74 22                	je     c010159b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101579:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010157d:	7e 0c                	jle    c010158b <kbd_proc_data+0x13e>
c010157f:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101583:	7f 06                	jg     c010158b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101585:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101589:	eb 10                	jmp    c010159b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010158b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010158f:	7e 0a                	jle    c010159b <kbd_proc_data+0x14e>
c0101591:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101595:	7f 04                	jg     c010159b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101597:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010159b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01015a0:	f7 d0                	not    %eax
c01015a2:	83 e0 06             	and    $0x6,%eax
c01015a5:	85 c0                	test   %eax,%eax
c01015a7:	75 28                	jne    c01015d1 <kbd_proc_data+0x184>
c01015a9:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015b0:	75 1f                	jne    c01015d1 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015b2:	c7 04 24 83 64 10 c0 	movl   $0xc0106483,(%esp)
c01015b9:	e8 9a ed ff ff       	call   c0100358 <cprintf>
c01015be:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015c4:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015c8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015cc:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015d0:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015d4:	c9                   	leave  
c01015d5:	c3                   	ret    

c01015d6 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015d6:	55                   	push   %ebp
c01015d7:	89 e5                	mov    %esp,%ebp
c01015d9:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015dc:	c7 04 24 4d 14 10 c0 	movl   $0xc010144d,(%esp)
c01015e3:	e8 a6 fd ff ff       	call   c010138e <cons_intr>
}
c01015e8:	c9                   	leave  
c01015e9:	c3                   	ret    

c01015ea <kbd_init>:

static void
kbd_init(void) {
c01015ea:	55                   	push   %ebp
c01015eb:	89 e5                	mov    %esp,%ebp
c01015ed:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015f0:	e8 e1 ff ff ff       	call   c01015d6 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015fc:	e8 3d 01 00 00       	call   c010173e <pic_enable>
}
c0101601:	c9                   	leave  
c0101602:	c3                   	ret    

c0101603 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101603:	55                   	push   %ebp
c0101604:	89 e5                	mov    %esp,%ebp
c0101606:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101609:	e8 93 f8 ff ff       	call   c0100ea1 <cga_init>
    serial_init();
c010160e:	e8 74 f9 ff ff       	call   c0100f87 <serial_init>
    kbd_init();
c0101613:	e8 d2 ff ff ff       	call   c01015ea <kbd_init>
    if (!serial_exists) {
c0101618:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010161d:	85 c0                	test   %eax,%eax
c010161f:	75 0c                	jne    c010162d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101621:	c7 04 24 8f 64 10 c0 	movl   $0xc010648f,(%esp)
c0101628:	e8 2b ed ff ff       	call   c0100358 <cprintf>
    }
}
c010162d:	c9                   	leave  
c010162e:	c3                   	ret    

c010162f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010162f:	55                   	push   %ebp
c0101630:	89 e5                	mov    %esp,%ebp
c0101632:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101635:	e8 e2 f7 ff ff       	call   c0100e1c <__intr_save>
c010163a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010163d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101640:	89 04 24             	mov    %eax,(%esp)
c0101643:	e8 9b fa ff ff       	call   c01010e3 <lpt_putc>
        cga_putc(c);
c0101648:	8b 45 08             	mov    0x8(%ebp),%eax
c010164b:	89 04 24             	mov    %eax,(%esp)
c010164e:	e8 cf fa ff ff       	call   c0101122 <cga_putc>
        serial_putc(c);
c0101653:	8b 45 08             	mov    0x8(%ebp),%eax
c0101656:	89 04 24             	mov    %eax,(%esp)
c0101659:	e8 f1 fc ff ff       	call   c010134f <serial_putc>
    }
    local_intr_restore(intr_flag);
c010165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101661:	89 04 24             	mov    %eax,(%esp)
c0101664:	e8 dd f7 ff ff       	call   c0100e46 <__intr_restore>
}
c0101669:	c9                   	leave  
c010166a:	c3                   	ret    

c010166b <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010166b:	55                   	push   %ebp
c010166c:	89 e5                	mov    %esp,%ebp
c010166e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101678:	e8 9f f7 ff ff       	call   c0100e1c <__intr_save>
c010167d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101680:	e8 ab fd ff ff       	call   c0101430 <serial_intr>
        kbd_intr();
c0101685:	e8 4c ff ff ff       	call   c01015d6 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010168a:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101690:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101695:	39 c2                	cmp    %eax,%edx
c0101697:	74 31                	je     c01016ca <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101699:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169e:	8d 50 01             	lea    0x1(%eax),%edx
c01016a1:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c01016a7:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c01016ae:	0f b6 c0             	movzbl %al,%eax
c01016b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016b4:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01016b9:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016be:	75 0a                	jne    c01016ca <cons_getc+0x5f>
                cons.rpos = 0;
c01016c0:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016c7:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016cd:	89 04 24             	mov    %eax,(%esp)
c01016d0:	e8 71 f7 ff ff       	call   c0100e46 <__intr_restore>
    return c;
c01016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d8:	c9                   	leave  
c01016d9:	c3                   	ret    

c01016da <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016da:	55                   	push   %ebp
c01016db:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016dd:	fb                   	sti    
    sti();
}
c01016de:	5d                   	pop    %ebp
c01016df:	c3                   	ret    

c01016e0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016e0:	55                   	push   %ebp
c01016e1:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016e3:	fa                   	cli    
    cli();
}
c01016e4:	5d                   	pop    %ebp
c01016e5:	c3                   	ret    

c01016e6 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016e6:	55                   	push   %ebp
c01016e7:	89 e5                	mov    %esp,%ebp
c01016e9:	83 ec 14             	sub    $0x14,%esp
c01016ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01016ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f7:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016fd:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c0101702:	85 c0                	test   %eax,%eax
c0101704:	74 36                	je     c010173c <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101706:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010170a:	0f b6 c0             	movzbl %al,%eax
c010170d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101713:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101716:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010171a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010171e:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010171f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101723:	66 c1 e8 08          	shr    $0x8,%ax
c0101727:	0f b6 c0             	movzbl %al,%eax
c010172a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101730:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101733:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101737:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010173b:	ee                   	out    %al,(%dx)
    }
}
c010173c:	c9                   	leave  
c010173d:	c3                   	ret    

c010173e <pic_enable>:

void
pic_enable(unsigned int irq) {
c010173e:	55                   	push   %ebp
c010173f:	89 e5                	mov    %esp,%ebp
c0101741:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101744:	8b 45 08             	mov    0x8(%ebp),%eax
c0101747:	ba 01 00 00 00       	mov    $0x1,%edx
c010174c:	89 c1                	mov    %eax,%ecx
c010174e:	d3 e2                	shl    %cl,%edx
c0101750:	89 d0                	mov    %edx,%eax
c0101752:	f7 d0                	not    %eax
c0101754:	89 c2                	mov    %eax,%edx
c0101756:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010175d:	21 d0                	and    %edx,%eax
c010175f:	0f b7 c0             	movzwl %ax,%eax
c0101762:	89 04 24             	mov    %eax,(%esp)
c0101765:	e8 7c ff ff ff       	call   c01016e6 <pic_setmask>
}
c010176a:	c9                   	leave  
c010176b:	c3                   	ret    

c010176c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010176c:	55                   	push   %ebp
c010176d:	89 e5                	mov    %esp,%ebp
c010176f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101772:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c0101779:	00 00 00 
c010177c:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101782:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101786:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010178a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010178e:	ee                   	out    %al,(%dx)
c010178f:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101795:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0101799:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010179d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017a1:	ee                   	out    %al,(%dx)
c01017a2:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01017a8:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01017ac:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01017b0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b4:	ee                   	out    %al,(%dx)
c01017b5:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017bb:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017bf:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017c3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017c7:	ee                   	out    %al,(%dx)
c01017c8:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017ce:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017d2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017d6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017da:	ee                   	out    %al,(%dx)
c01017db:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017e1:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017e5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017e9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017ed:	ee                   	out    %al,(%dx)
c01017ee:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017f4:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017f8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017fc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101800:	ee                   	out    %al,(%dx)
c0101801:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101807:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c010180b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010180f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101813:	ee                   	out    %al,(%dx)
c0101814:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010181a:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010181e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101822:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101826:	ee                   	out    %al,(%dx)
c0101827:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010182d:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101831:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101835:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101839:	ee                   	out    %al,(%dx)
c010183a:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101840:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101844:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101848:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010184c:	ee                   	out    %al,(%dx)
c010184d:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101853:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101857:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010185b:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010185f:	ee                   	out    %al,(%dx)
c0101860:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0101866:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010186a:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010186e:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101872:	ee                   	out    %al,(%dx)
c0101873:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0101879:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c010187d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101881:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101885:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101886:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010188d:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101891:	74 12                	je     c01018a5 <pic_init+0x139>
        pic_setmask(irq_mask);
c0101893:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010189a:	0f b7 c0             	movzwl %ax,%eax
c010189d:	89 04 24             	mov    %eax,(%esp)
c01018a0:	e8 41 fe ff ff       	call   c01016e6 <pic_setmask>
    }
}
c01018a5:	c9                   	leave  
c01018a6:	c3                   	ret    

c01018a7 <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c01018a7:	55                   	push   %ebp
c01018a8:	89 e5                	mov    %esp,%ebp
c01018aa:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01018ad:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018b4:	00 
c01018b5:	c7 04 24 c0 64 10 c0 	movl   $0xc01064c0,(%esp)
c01018bc:	e8 97 ea ff ff       	call   c0100358 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018c1:	c7 04 24 ca 64 10 c0 	movl   $0xc01064ca,(%esp)
c01018c8:	e8 8b ea ff ff       	call   c0100358 <cprintf>
    panic("EOT: kernel seems ok.");
c01018cd:	c7 44 24 08 d8 64 10 	movl   $0xc01064d8,0x8(%esp)
c01018d4:	c0 
c01018d5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018dc:	00 
c01018dd:	c7 04 24 ee 64 10 c0 	movl   $0xc01064ee,(%esp)
c01018e4:	e8 03 f4 ff ff       	call   c0100cec <__panic>

c01018e9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018e9:	55                   	push   %ebp
c01018ea:	89 e5                	mov    %esp,%ebp
c01018ec:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018f6:	e9 c3 00 00 00       	jmp    c01019be <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fe:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101905:	89 c2                	mov    %eax,%edx
c0101907:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190a:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c0101911:	c0 
c0101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101915:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c010191c:	c0 08 00 
c010191f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101922:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101929:	c0 
c010192a:	83 e2 e0             	and    $0xffffffe0,%edx
c010192d:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101934:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101937:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010193e:	c0 
c010193f:	83 e2 1f             	and    $0x1f,%edx
c0101942:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101949:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194c:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101953:	c0 
c0101954:	83 e2 f0             	and    $0xfffffff0,%edx
c0101957:	83 ca 0e             	or     $0xe,%edx
c010195a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101964:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010196b:	c0 
c010196c:	83 e2 ef             	and    $0xffffffef,%edx
c010196f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101976:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101979:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101980:	c0 
c0101981:	83 e2 9f             	and    $0xffffff9f,%edx
c0101984:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010198b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198e:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101995:	c0 
c0101996:	83 ca 80             	or     $0xffffff80,%edx
c0101999:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c01019a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a3:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01019aa:	c1 e8 10             	shr    $0x10,%eax
c01019ad:	89 c2                	mov    %eax,%edx
c01019af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b2:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c01019b9:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01019ba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019be:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019c1:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019c6:	0f 86 2f ff ff ff    	jbe    c01018fb <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01019cc:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019d1:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c01019d7:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c01019de:	08 00 
c01019e0:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019e7:	83 e0 e0             	and    $0xffffffe0,%eax
c01019ea:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019ef:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019f6:	83 e0 1f             	and    $0x1f,%eax
c01019f9:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019fe:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a05:	83 e0 f0             	and    $0xfffffff0,%eax
c0101a08:	83 c8 0e             	or     $0xe,%eax
c0101a0b:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a10:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a17:	83 e0 ef             	and    $0xffffffef,%eax
c0101a1a:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a1f:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a26:	83 c8 60             	or     $0x60,%eax
c0101a29:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a2e:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a35:	83 c8 80             	or     $0xffffff80,%eax
c0101a38:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a3d:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a42:	c1 e8 10             	shr    $0x10,%eax
c0101a45:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a4b:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a55:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
c0101a58:	c9                   	leave  
c0101a59:	c3                   	ret    

c0101a5a <trapname>:

static const char *
trapname(int trapno) {
c0101a5a:	55                   	push   %ebp
c0101a5b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a60:	83 f8 13             	cmp    $0x13,%eax
c0101a63:	77 0c                	ja     c0101a71 <trapname+0x17>
        return excnames[trapno];
c0101a65:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a68:	8b 04 85 40 68 10 c0 	mov    -0x3fef97c0(,%eax,4),%eax
c0101a6f:	eb 18                	jmp    c0101a89 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a71:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a75:	7e 0d                	jle    c0101a84 <trapname+0x2a>
c0101a77:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a7b:	7f 07                	jg     c0101a84 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a7d:	b8 ff 64 10 c0       	mov    $0xc01064ff,%eax
c0101a82:	eb 05                	jmp    c0101a89 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a84:	b8 12 65 10 c0       	mov    $0xc0106512,%eax
}
c0101a89:	5d                   	pop    %ebp
c0101a8a:	c3                   	ret    

c0101a8b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a8b:	55                   	push   %ebp
c0101a8c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a91:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a95:	66 83 f8 08          	cmp    $0x8,%ax
c0101a99:	0f 94 c0             	sete   %al
c0101a9c:	0f b6 c0             	movzbl %al,%eax
}
c0101a9f:	5d                   	pop    %ebp
c0101aa0:	c3                   	ret    

c0101aa1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101aa1:	55                   	push   %ebp
c0101aa2:	89 e5                	mov    %esp,%ebp
c0101aa4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aae:	c7 04 24 53 65 10 c0 	movl   $0xc0106553,(%esp)
c0101ab5:	e8 9e e8 ff ff       	call   c0100358 <cprintf>
    print_regs(&tf->tf_regs);
c0101aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abd:	89 04 24             	mov    %eax,(%esp)
c0101ac0:	e8 a1 01 00 00       	call   c0101c66 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101acc:	0f b7 c0             	movzwl %ax,%eax
c0101acf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad3:	c7 04 24 64 65 10 c0 	movl   $0xc0106564,(%esp)
c0101ada:	e8 79 e8 ff ff       	call   c0100358 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ae6:	0f b7 c0             	movzwl %ax,%eax
c0101ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aed:	c7 04 24 77 65 10 c0 	movl   $0xc0106577,(%esp)
c0101af4:	e8 5f e8 ff ff       	call   c0100358 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afc:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b00:	0f b7 c0             	movzwl %ax,%eax
c0101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b07:	c7 04 24 8a 65 10 c0 	movl   $0xc010658a,(%esp)
c0101b0e:	e8 45 e8 ff ff       	call   c0100358 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b16:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b1a:	0f b7 c0             	movzwl %ax,%eax
c0101b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b21:	c7 04 24 9d 65 10 c0 	movl   $0xc010659d,(%esp)
c0101b28:	e8 2b e8 ff ff       	call   c0100358 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b30:	8b 40 30             	mov    0x30(%eax),%eax
c0101b33:	89 04 24             	mov    %eax,(%esp)
c0101b36:	e8 1f ff ff ff       	call   c0101a5a <trapname>
c0101b3b:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b3e:	8b 52 30             	mov    0x30(%edx),%edx
c0101b41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b45:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b49:	c7 04 24 b0 65 10 c0 	movl   $0xc01065b0,(%esp)
c0101b50:	e8 03 e8 ff ff       	call   c0100358 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b58:	8b 40 34             	mov    0x34(%eax),%eax
c0101b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5f:	c7 04 24 c2 65 10 c0 	movl   $0xc01065c2,(%esp)
c0101b66:	e8 ed e7 ff ff       	call   c0100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6e:	8b 40 38             	mov    0x38(%eax),%eax
c0101b71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b75:	c7 04 24 d1 65 10 c0 	movl   $0xc01065d1,(%esp)
c0101b7c:	e8 d7 e7 ff ff       	call   c0100358 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b84:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b88:	0f b7 c0             	movzwl %ax,%eax
c0101b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8f:	c7 04 24 e0 65 10 c0 	movl   $0xc01065e0,(%esp)
c0101b96:	e8 bd e7 ff ff       	call   c0100358 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9e:	8b 40 40             	mov    0x40(%eax),%eax
c0101ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba5:	c7 04 24 f3 65 10 c0 	movl   $0xc01065f3,(%esp)
c0101bac:	e8 a7 e7 ff ff       	call   c0100358 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101bb8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101bbf:	eb 3e                	jmp    c0101bff <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc4:	8b 50 40             	mov    0x40(%eax),%edx
c0101bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bca:	21 d0                	and    %edx,%eax
c0101bcc:	85 c0                	test   %eax,%eax
c0101bce:	74 28                	je     c0101bf8 <print_trapframe+0x157>
c0101bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd3:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bda:	85 c0                	test   %eax,%eax
c0101bdc:	74 1a                	je     c0101bf8 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101be1:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101be8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bec:	c7 04 24 02 66 10 c0 	movl   $0xc0106602,(%esp)
c0101bf3:	e8 60 e7 ff ff       	call   c0100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bf8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bfc:	d1 65 f0             	shll   -0x10(%ebp)
c0101bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c02:	83 f8 17             	cmp    $0x17,%eax
c0101c05:	76 ba                	jbe    c0101bc1 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c07:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0a:	8b 40 40             	mov    0x40(%eax),%eax
c0101c0d:	25 00 30 00 00       	and    $0x3000,%eax
c0101c12:	c1 e8 0c             	shr    $0xc,%eax
c0101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c19:	c7 04 24 06 66 10 c0 	movl   $0xc0106606,(%esp)
c0101c20:	e8 33 e7 ff ff       	call   c0100358 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c28:	89 04 24             	mov    %eax,(%esp)
c0101c2b:	e8 5b fe ff ff       	call   c0101a8b <trap_in_kernel>
c0101c30:	85 c0                	test   %eax,%eax
c0101c32:	75 30                	jne    c0101c64 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c37:	8b 40 44             	mov    0x44(%eax),%eax
c0101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3e:	c7 04 24 0f 66 10 c0 	movl   $0xc010660f,(%esp)
c0101c45:	e8 0e e7 ff ff       	call   c0100358 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c51:	0f b7 c0             	movzwl %ax,%eax
c0101c54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c58:	c7 04 24 1e 66 10 c0 	movl   $0xc010661e,(%esp)
c0101c5f:	e8 f4 e6 ff ff       	call   c0100358 <cprintf>
    }
}
c0101c64:	c9                   	leave  
c0101c65:	c3                   	ret    

c0101c66 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c66:	55                   	push   %ebp
c0101c67:	89 e5                	mov    %esp,%ebp
c0101c69:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6f:	8b 00                	mov    (%eax),%eax
c0101c71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c75:	c7 04 24 31 66 10 c0 	movl   $0xc0106631,(%esp)
c0101c7c:	e8 d7 e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c84:	8b 40 04             	mov    0x4(%eax),%eax
c0101c87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c8b:	c7 04 24 40 66 10 c0 	movl   $0xc0106640,(%esp)
c0101c92:	e8 c1 e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9a:	8b 40 08             	mov    0x8(%eax),%eax
c0101c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca1:	c7 04 24 4f 66 10 c0 	movl   $0xc010664f,(%esp)
c0101ca8:	e8 ab e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb0:	8b 40 0c             	mov    0xc(%eax),%eax
c0101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb7:	c7 04 24 5e 66 10 c0 	movl   $0xc010665e,(%esp)
c0101cbe:	e8 95 e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc6:	8b 40 10             	mov    0x10(%eax),%eax
c0101cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccd:	c7 04 24 6d 66 10 c0 	movl   $0xc010666d,(%esp)
c0101cd4:	e8 7f e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdc:	8b 40 14             	mov    0x14(%eax),%eax
c0101cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce3:	c7 04 24 7c 66 10 c0 	movl   $0xc010667c,(%esp)
c0101cea:	e8 69 e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf2:	8b 40 18             	mov    0x18(%eax),%eax
c0101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf9:	c7 04 24 8b 66 10 c0 	movl   $0xc010668b,(%esp)
c0101d00:	e8 53 e6 ff ff       	call   c0100358 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d08:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0f:	c7 04 24 9a 66 10 c0 	movl   $0xc010669a,(%esp)
c0101d16:	e8 3d e6 ff ff       	call   c0100358 <cprintf>
}
c0101d1b:	c9                   	leave  
c0101d1c:	c3                   	ret    

c0101d1d <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d1d:	55                   	push   %ebp
c0101d1e:	89 e5                	mov    %esp,%ebp
c0101d20:	57                   	push   %edi
c0101d21:	56                   	push   %esi
c0101d22:	53                   	push   %ebx
c0101d23:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d26:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d29:	8b 40 30             	mov    0x30(%eax),%eax
c0101d2c:	83 f8 2f             	cmp    $0x2f,%eax
c0101d2f:	77 21                	ja     c0101d52 <trap_dispatch+0x35>
c0101d31:	83 f8 2e             	cmp    $0x2e,%eax
c0101d34:	0f 83 ec 01 00 00    	jae    c0101f26 <trap_dispatch+0x209>
c0101d3a:	83 f8 21             	cmp    $0x21,%eax
c0101d3d:	0f 84 8a 00 00 00    	je     c0101dcd <trap_dispatch+0xb0>
c0101d43:	83 f8 24             	cmp    $0x24,%eax
c0101d46:	74 5c                	je     c0101da4 <trap_dispatch+0x87>
c0101d48:	83 f8 20             	cmp    $0x20,%eax
c0101d4b:	74 1c                	je     c0101d69 <trap_dispatch+0x4c>
c0101d4d:	e9 9c 01 00 00       	jmp    c0101eee <trap_dispatch+0x1d1>
c0101d52:	83 f8 78             	cmp    $0x78,%eax
c0101d55:	0f 84 9b 00 00 00    	je     c0101df6 <trap_dispatch+0xd9>
c0101d5b:	83 f8 79             	cmp    $0x79,%eax
c0101d5e:	0f 84 11 01 00 00    	je     c0101e75 <trap_dispatch+0x158>
c0101d64:	e9 85 01 00 00       	jmp    c0101eee <trap_dispatch+0x1d1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101d69:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d6e:	83 c0 01             	add    $0x1,%eax
c0101d71:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101d76:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d7c:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d81:	89 c8                	mov    %ecx,%eax
c0101d83:	f7 e2                	mul    %edx
c0101d85:	89 d0                	mov    %edx,%eax
c0101d87:	c1 e8 05             	shr    $0x5,%eax
c0101d8a:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d8d:	29 c1                	sub    %eax,%ecx
c0101d8f:	89 c8                	mov    %ecx,%eax
c0101d91:	85 c0                	test   %eax,%eax
c0101d93:	75 0a                	jne    c0101d9f <trap_dispatch+0x82>
            print_ticks();
c0101d95:	e8 0d fb ff ff       	call   c01018a7 <print_ticks>
        }
        break;
c0101d9a:	e9 88 01 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
c0101d9f:	e9 83 01 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101da4:	e8 c2 f8 ff ff       	call   c010166b <cons_getc>
c0101da9:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101dac:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101db0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101db4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101db8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dbc:	c7 04 24 a9 66 10 c0 	movl   $0xc01066a9,(%esp)
c0101dc3:	e8 90 e5 ff ff       	call   c0100358 <cprintf>
        break;
c0101dc8:	e9 5a 01 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101dcd:	e8 99 f8 ff ff       	call   c010166b <cons_getc>
c0101dd2:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101dd5:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101dd9:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101ddd:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101de1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101de5:	c7 04 24 bb 66 10 c0 	movl   $0xc01066bb,(%esp)
c0101dec:	e8 67 e5 ff ff       	call   c0100358 <cprintf>
        break;
c0101df1:	e9 31 01 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c0101df6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dfd:	66 83 f8 1b          	cmp    $0x1b,%ax
c0101e01:	74 6d                	je     c0101e70 <trap_dispatch+0x153>
            switchk2u = *tf;
c0101e03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e06:	ba 20 af 11 c0       	mov    $0xc011af20,%edx
c0101e0b:	89 c3                	mov    %eax,%ebx
c0101e0d:	b8 13 00 00 00       	mov    $0x13,%eax
c0101e12:	89 d7                	mov    %edx,%edi
c0101e14:	89 de                	mov    %ebx,%esi
c0101e16:	89 c1                	mov    %eax,%ecx
c0101e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
c0101e1a:	66 c7 05 5c af 11 c0 	movw   $0x1b,0xc011af5c
c0101e21:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101e23:	66 c7 05 68 af 11 c0 	movw   $0x23,0xc011af68
c0101e2a:	23 00 
c0101e2c:	0f b7 05 68 af 11 c0 	movzwl 0xc011af68,%eax
c0101e33:	66 a3 48 af 11 c0    	mov    %ax,0xc011af48
c0101e39:	0f b7 05 48 af 11 c0 	movzwl 0xc011af48,%eax
c0101e40:	66 a3 4c af 11 c0    	mov    %ax,0xc011af4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;	
c0101e46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e49:	83 c0 44             	add    $0x44,%eax
c0101e4c:	a3 64 af 11 c0       	mov    %eax,0xc011af64
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0101e51:	a1 60 af 11 c0       	mov    0xc011af60,%eax
c0101e56:	80 cc 30             	or     $0x30,%ah
c0101e59:	a3 60 af 11 c0       	mov    %eax,0xc011af60
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e61:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101e64:	b8 20 af 11 c0       	mov    $0xc011af20,%eax
c0101e69:	89 02                	mov    %eax,(%edx)
        }
        break;
c0101e6b:	e9 b7 00 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
c0101e70:	e9 b2 00 00 00       	jmp    c0101f27 <trap_dispatch+0x20a>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
c0101e75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e78:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e7c:	66 83 f8 08          	cmp    $0x8,%ax
c0101e80:	74 6a                	je     c0101eec <trap_dispatch+0x1cf>
            tf->tf_cs = KERNEL_CS;
c0101e82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e85:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8e:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e97:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea5:	8b 40 40             	mov    0x40(%eax),%eax
c0101ea8:	80 e4 cf             	and    $0xcf,%ah
c0101eab:	89 c2                	mov    %eax,%edx
c0101ead:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb0:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101eb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb6:	8b 40 44             	mov    0x44(%eax),%eax
c0101eb9:	83 e8 44             	sub    $0x44,%eax
c0101ebc:	a3 6c af 11 c0       	mov    %eax,0xc011af6c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0101ec1:	a1 6c af 11 c0       	mov    0xc011af6c,%eax
c0101ec6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101ecd:	00 
c0101ece:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101ed5:	89 04 24             	mov    %eax,(%esp)
c0101ed8:	e8 05 41 00 00       	call   c0105fe2 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0101edd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee0:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101ee3:	a1 6c af 11 c0       	mov    0xc011af6c,%eax
c0101ee8:	89 02                	mov    %eax,(%edx)
        }
        break;
c0101eea:	eb 3b                	jmp    c0101f27 <trap_dispatch+0x20a>
c0101eec:	eb 39                	jmp    c0101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101eee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ef5:	0f b7 c0             	movzwl %ax,%eax
c0101ef8:	83 e0 03             	and    $0x3,%eax
c0101efb:	85 c0                	test   %eax,%eax
c0101efd:	75 28                	jne    c0101f27 <trap_dispatch+0x20a>
            print_trapframe(tf);
c0101eff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f02:	89 04 24             	mov    %eax,(%esp)
c0101f05:	e8 97 fb ff ff       	call   c0101aa1 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101f0a:	c7 44 24 08 ca 66 10 	movl   $0xc01066ca,0x8(%esp)
c0101f11:	c0 
c0101f12:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0101f19:	00 
c0101f1a:	c7 04 24 ee 64 10 c0 	movl   $0xc01064ee,(%esp)
c0101f21:	e8 c6 ed ff ff       	call   c0100cec <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101f26:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101f27:	83 c4 2c             	add    $0x2c,%esp
c0101f2a:	5b                   	pop    %ebx
c0101f2b:	5e                   	pop    %esi
c0101f2c:	5f                   	pop    %edi
c0101f2d:	5d                   	pop    %ebp
c0101f2e:	c3                   	ret    

c0101f2f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101f2f:	55                   	push   %ebp
c0101f30:	89 e5                	mov    %esp,%ebp
c0101f32:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f38:	89 04 24             	mov    %eax,(%esp)
c0101f3b:	e8 dd fd ff ff       	call   c0101d1d <trap_dispatch>
}
c0101f40:	c9                   	leave  
c0101f41:	c3                   	ret    

c0101f42 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101f42:	1e                   	push   %ds
    pushl %es
c0101f43:	06                   	push   %es
    pushl %fs
c0101f44:	0f a0                	push   %fs
    pushl %gs
c0101f46:	0f a8                	push   %gs
    pushal
c0101f48:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101f49:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101f4e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101f50:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101f52:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101f53:	e8 d7 ff ff ff       	call   c0101f2f <trap>

    # pop the pushed stack pointer
    popl %esp
c0101f58:	5c                   	pop    %esp

c0101f59 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101f59:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101f5a:	0f a9                	pop    %gs
    popl %fs
c0101f5c:	0f a1                	pop    %fs
    popl %es
c0101f5e:	07                   	pop    %es
    popl %ds
c0101f5f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101f60:	83 c4 08             	add    $0x8,%esp
    iret
c0101f63:	cf                   	iret   

c0101f64 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f64:	6a 00                	push   $0x0
  pushl $0
c0101f66:	6a 00                	push   $0x0
  jmp __alltraps
c0101f68:	e9 d5 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f6d <vector1>:
.globl vector1
vector1:
  pushl $0
c0101f6d:	6a 00                	push   $0x0
  pushl $1
c0101f6f:	6a 01                	push   $0x1
  jmp __alltraps
c0101f71:	e9 cc ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f76 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f76:	6a 00                	push   $0x0
  pushl $2
c0101f78:	6a 02                	push   $0x2
  jmp __alltraps
c0101f7a:	e9 c3 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f7f <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f7f:	6a 00                	push   $0x0
  pushl $3
c0101f81:	6a 03                	push   $0x3
  jmp __alltraps
c0101f83:	e9 ba ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f88 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f88:	6a 00                	push   $0x0
  pushl $4
c0101f8a:	6a 04                	push   $0x4
  jmp __alltraps
c0101f8c:	e9 b1 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f91 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101f91:	6a 00                	push   $0x0
  pushl $5
c0101f93:	6a 05                	push   $0x5
  jmp __alltraps
c0101f95:	e9 a8 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101f9a <vector6>:
.globl vector6
vector6:
  pushl $0
c0101f9a:	6a 00                	push   $0x0
  pushl $6
c0101f9c:	6a 06                	push   $0x6
  jmp __alltraps
c0101f9e:	e9 9f ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fa3 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101fa3:	6a 00                	push   $0x0
  pushl $7
c0101fa5:	6a 07                	push   $0x7
  jmp __alltraps
c0101fa7:	e9 96 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fac <vector8>:
.globl vector8
vector8:
  pushl $8
c0101fac:	6a 08                	push   $0x8
  jmp __alltraps
c0101fae:	e9 8f ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fb3 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101fb3:	6a 00                	push   $0x0
  pushl $9
c0101fb5:	6a 09                	push   $0x9
  jmp __alltraps
c0101fb7:	e9 86 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fbc <vector10>:
.globl vector10
vector10:
  pushl $10
c0101fbc:	6a 0a                	push   $0xa
  jmp __alltraps
c0101fbe:	e9 7f ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fc3 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101fc3:	6a 0b                	push   $0xb
  jmp __alltraps
c0101fc5:	e9 78 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fca <vector12>:
.globl vector12
vector12:
  pushl $12
c0101fca:	6a 0c                	push   $0xc
  jmp __alltraps
c0101fcc:	e9 71 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fd1 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101fd1:	6a 0d                	push   $0xd
  jmp __alltraps
c0101fd3:	e9 6a ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fd8 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101fd8:	6a 0e                	push   $0xe
  jmp __alltraps
c0101fda:	e9 63 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fdf <vector15>:
.globl vector15
vector15:
  pushl $0
c0101fdf:	6a 00                	push   $0x0
  pushl $15
c0101fe1:	6a 0f                	push   $0xf
  jmp __alltraps
c0101fe3:	e9 5a ff ff ff       	jmp    c0101f42 <__alltraps>

c0101fe8 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101fe8:	6a 00                	push   $0x0
  pushl $16
c0101fea:	6a 10                	push   $0x10
  jmp __alltraps
c0101fec:	e9 51 ff ff ff       	jmp    c0101f42 <__alltraps>

c0101ff1 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101ff1:	6a 11                	push   $0x11
  jmp __alltraps
c0101ff3:	e9 4a ff ff ff       	jmp    c0101f42 <__alltraps>

c0101ff8 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101ff8:	6a 00                	push   $0x0
  pushl $18
c0101ffa:	6a 12                	push   $0x12
  jmp __alltraps
c0101ffc:	e9 41 ff ff ff       	jmp    c0101f42 <__alltraps>

c0102001 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102001:	6a 00                	push   $0x0
  pushl $19
c0102003:	6a 13                	push   $0x13
  jmp __alltraps
c0102005:	e9 38 ff ff ff       	jmp    c0101f42 <__alltraps>

c010200a <vector20>:
.globl vector20
vector20:
  pushl $0
c010200a:	6a 00                	push   $0x0
  pushl $20
c010200c:	6a 14                	push   $0x14
  jmp __alltraps
c010200e:	e9 2f ff ff ff       	jmp    c0101f42 <__alltraps>

c0102013 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102013:	6a 00                	push   $0x0
  pushl $21
c0102015:	6a 15                	push   $0x15
  jmp __alltraps
c0102017:	e9 26 ff ff ff       	jmp    c0101f42 <__alltraps>

c010201c <vector22>:
.globl vector22
vector22:
  pushl $0
c010201c:	6a 00                	push   $0x0
  pushl $22
c010201e:	6a 16                	push   $0x16
  jmp __alltraps
c0102020:	e9 1d ff ff ff       	jmp    c0101f42 <__alltraps>

c0102025 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102025:	6a 00                	push   $0x0
  pushl $23
c0102027:	6a 17                	push   $0x17
  jmp __alltraps
c0102029:	e9 14 ff ff ff       	jmp    c0101f42 <__alltraps>

c010202e <vector24>:
.globl vector24
vector24:
  pushl $0
c010202e:	6a 00                	push   $0x0
  pushl $24
c0102030:	6a 18                	push   $0x18
  jmp __alltraps
c0102032:	e9 0b ff ff ff       	jmp    c0101f42 <__alltraps>

c0102037 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102037:	6a 00                	push   $0x0
  pushl $25
c0102039:	6a 19                	push   $0x19
  jmp __alltraps
c010203b:	e9 02 ff ff ff       	jmp    c0101f42 <__alltraps>

c0102040 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102040:	6a 00                	push   $0x0
  pushl $26
c0102042:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102044:	e9 f9 fe ff ff       	jmp    c0101f42 <__alltraps>

c0102049 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $27
c010204b:	6a 1b                	push   $0x1b
  jmp __alltraps
c010204d:	e9 f0 fe ff ff       	jmp    c0101f42 <__alltraps>

c0102052 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102052:	6a 00                	push   $0x0
  pushl $28
c0102054:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102056:	e9 e7 fe ff ff       	jmp    c0101f42 <__alltraps>

c010205b <vector29>:
.globl vector29
vector29:
  pushl $0
c010205b:	6a 00                	push   $0x0
  pushl $29
c010205d:	6a 1d                	push   $0x1d
  jmp __alltraps
c010205f:	e9 de fe ff ff       	jmp    c0101f42 <__alltraps>

c0102064 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102064:	6a 00                	push   $0x0
  pushl $30
c0102066:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102068:	e9 d5 fe ff ff       	jmp    c0101f42 <__alltraps>

c010206d <vector31>:
.globl vector31
vector31:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $31
c010206f:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102071:	e9 cc fe ff ff       	jmp    c0101f42 <__alltraps>

c0102076 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102076:	6a 00                	push   $0x0
  pushl $32
c0102078:	6a 20                	push   $0x20
  jmp __alltraps
c010207a:	e9 c3 fe ff ff       	jmp    c0101f42 <__alltraps>

c010207f <vector33>:
.globl vector33
vector33:
  pushl $0
c010207f:	6a 00                	push   $0x0
  pushl $33
c0102081:	6a 21                	push   $0x21
  jmp __alltraps
c0102083:	e9 ba fe ff ff       	jmp    c0101f42 <__alltraps>

c0102088 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102088:	6a 00                	push   $0x0
  pushl $34
c010208a:	6a 22                	push   $0x22
  jmp __alltraps
c010208c:	e9 b1 fe ff ff       	jmp    c0101f42 <__alltraps>

c0102091 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $35
c0102093:	6a 23                	push   $0x23
  jmp __alltraps
c0102095:	e9 a8 fe ff ff       	jmp    c0101f42 <__alltraps>

c010209a <vector36>:
.globl vector36
vector36:
  pushl $0
c010209a:	6a 00                	push   $0x0
  pushl $36
c010209c:	6a 24                	push   $0x24
  jmp __alltraps
c010209e:	e9 9f fe ff ff       	jmp    c0101f42 <__alltraps>

c01020a3 <vector37>:
.globl vector37
vector37:
  pushl $0
c01020a3:	6a 00                	push   $0x0
  pushl $37
c01020a5:	6a 25                	push   $0x25
  jmp __alltraps
c01020a7:	e9 96 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020ac <vector38>:
.globl vector38
vector38:
  pushl $0
c01020ac:	6a 00                	push   $0x0
  pushl $38
c01020ae:	6a 26                	push   $0x26
  jmp __alltraps
c01020b0:	e9 8d fe ff ff       	jmp    c0101f42 <__alltraps>

c01020b5 <vector39>:
.globl vector39
vector39:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $39
c01020b7:	6a 27                	push   $0x27
  jmp __alltraps
c01020b9:	e9 84 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020be <vector40>:
.globl vector40
vector40:
  pushl $0
c01020be:	6a 00                	push   $0x0
  pushl $40
c01020c0:	6a 28                	push   $0x28
  jmp __alltraps
c01020c2:	e9 7b fe ff ff       	jmp    c0101f42 <__alltraps>

c01020c7 <vector41>:
.globl vector41
vector41:
  pushl $0
c01020c7:	6a 00                	push   $0x0
  pushl $41
c01020c9:	6a 29                	push   $0x29
  jmp __alltraps
c01020cb:	e9 72 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020d0 <vector42>:
.globl vector42
vector42:
  pushl $0
c01020d0:	6a 00                	push   $0x0
  pushl $42
c01020d2:	6a 2a                	push   $0x2a
  jmp __alltraps
c01020d4:	e9 69 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020d9 <vector43>:
.globl vector43
vector43:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $43
c01020db:	6a 2b                	push   $0x2b
  jmp __alltraps
c01020dd:	e9 60 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020e2 <vector44>:
.globl vector44
vector44:
  pushl $0
c01020e2:	6a 00                	push   $0x0
  pushl $44
c01020e4:	6a 2c                	push   $0x2c
  jmp __alltraps
c01020e6:	e9 57 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020eb <vector45>:
.globl vector45
vector45:
  pushl $0
c01020eb:	6a 00                	push   $0x0
  pushl $45
c01020ed:	6a 2d                	push   $0x2d
  jmp __alltraps
c01020ef:	e9 4e fe ff ff       	jmp    c0101f42 <__alltraps>

c01020f4 <vector46>:
.globl vector46
vector46:
  pushl $0
c01020f4:	6a 00                	push   $0x0
  pushl $46
c01020f6:	6a 2e                	push   $0x2e
  jmp __alltraps
c01020f8:	e9 45 fe ff ff       	jmp    c0101f42 <__alltraps>

c01020fd <vector47>:
.globl vector47
vector47:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $47
c01020ff:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102101:	e9 3c fe ff ff       	jmp    c0101f42 <__alltraps>

c0102106 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102106:	6a 00                	push   $0x0
  pushl $48
c0102108:	6a 30                	push   $0x30
  jmp __alltraps
c010210a:	e9 33 fe ff ff       	jmp    c0101f42 <__alltraps>

c010210f <vector49>:
.globl vector49
vector49:
  pushl $0
c010210f:	6a 00                	push   $0x0
  pushl $49
c0102111:	6a 31                	push   $0x31
  jmp __alltraps
c0102113:	e9 2a fe ff ff       	jmp    c0101f42 <__alltraps>

c0102118 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102118:	6a 00                	push   $0x0
  pushl $50
c010211a:	6a 32                	push   $0x32
  jmp __alltraps
c010211c:	e9 21 fe ff ff       	jmp    c0101f42 <__alltraps>

c0102121 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $51
c0102123:	6a 33                	push   $0x33
  jmp __alltraps
c0102125:	e9 18 fe ff ff       	jmp    c0101f42 <__alltraps>

c010212a <vector52>:
.globl vector52
vector52:
  pushl $0
c010212a:	6a 00                	push   $0x0
  pushl $52
c010212c:	6a 34                	push   $0x34
  jmp __alltraps
c010212e:	e9 0f fe ff ff       	jmp    c0101f42 <__alltraps>

c0102133 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102133:	6a 00                	push   $0x0
  pushl $53
c0102135:	6a 35                	push   $0x35
  jmp __alltraps
c0102137:	e9 06 fe ff ff       	jmp    c0101f42 <__alltraps>

c010213c <vector54>:
.globl vector54
vector54:
  pushl $0
c010213c:	6a 00                	push   $0x0
  pushl $54
c010213e:	6a 36                	push   $0x36
  jmp __alltraps
c0102140:	e9 fd fd ff ff       	jmp    c0101f42 <__alltraps>

c0102145 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $55
c0102147:	6a 37                	push   $0x37
  jmp __alltraps
c0102149:	e9 f4 fd ff ff       	jmp    c0101f42 <__alltraps>

c010214e <vector56>:
.globl vector56
vector56:
  pushl $0
c010214e:	6a 00                	push   $0x0
  pushl $56
c0102150:	6a 38                	push   $0x38
  jmp __alltraps
c0102152:	e9 eb fd ff ff       	jmp    c0101f42 <__alltraps>

c0102157 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102157:	6a 00                	push   $0x0
  pushl $57
c0102159:	6a 39                	push   $0x39
  jmp __alltraps
c010215b:	e9 e2 fd ff ff       	jmp    c0101f42 <__alltraps>

c0102160 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102160:	6a 00                	push   $0x0
  pushl $58
c0102162:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102164:	e9 d9 fd ff ff       	jmp    c0101f42 <__alltraps>

c0102169 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $59
c010216b:	6a 3b                	push   $0x3b
  jmp __alltraps
c010216d:	e9 d0 fd ff ff       	jmp    c0101f42 <__alltraps>

c0102172 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102172:	6a 00                	push   $0x0
  pushl $60
c0102174:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102176:	e9 c7 fd ff ff       	jmp    c0101f42 <__alltraps>

c010217b <vector61>:
.globl vector61
vector61:
  pushl $0
c010217b:	6a 00                	push   $0x0
  pushl $61
c010217d:	6a 3d                	push   $0x3d
  jmp __alltraps
c010217f:	e9 be fd ff ff       	jmp    c0101f42 <__alltraps>

c0102184 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102184:	6a 00                	push   $0x0
  pushl $62
c0102186:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102188:	e9 b5 fd ff ff       	jmp    c0101f42 <__alltraps>

c010218d <vector63>:
.globl vector63
vector63:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $63
c010218f:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102191:	e9 ac fd ff ff       	jmp    c0101f42 <__alltraps>

c0102196 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102196:	6a 00                	push   $0x0
  pushl $64
c0102198:	6a 40                	push   $0x40
  jmp __alltraps
c010219a:	e9 a3 fd ff ff       	jmp    c0101f42 <__alltraps>

c010219f <vector65>:
.globl vector65
vector65:
  pushl $0
c010219f:	6a 00                	push   $0x0
  pushl $65
c01021a1:	6a 41                	push   $0x41
  jmp __alltraps
c01021a3:	e9 9a fd ff ff       	jmp    c0101f42 <__alltraps>

c01021a8 <vector66>:
.globl vector66
vector66:
  pushl $0
c01021a8:	6a 00                	push   $0x0
  pushl $66
c01021aa:	6a 42                	push   $0x42
  jmp __alltraps
c01021ac:	e9 91 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021b1 <vector67>:
.globl vector67
vector67:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $67
c01021b3:	6a 43                	push   $0x43
  jmp __alltraps
c01021b5:	e9 88 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021ba <vector68>:
.globl vector68
vector68:
  pushl $0
c01021ba:	6a 00                	push   $0x0
  pushl $68
c01021bc:	6a 44                	push   $0x44
  jmp __alltraps
c01021be:	e9 7f fd ff ff       	jmp    c0101f42 <__alltraps>

c01021c3 <vector69>:
.globl vector69
vector69:
  pushl $0
c01021c3:	6a 00                	push   $0x0
  pushl $69
c01021c5:	6a 45                	push   $0x45
  jmp __alltraps
c01021c7:	e9 76 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021cc <vector70>:
.globl vector70
vector70:
  pushl $0
c01021cc:	6a 00                	push   $0x0
  pushl $70
c01021ce:	6a 46                	push   $0x46
  jmp __alltraps
c01021d0:	e9 6d fd ff ff       	jmp    c0101f42 <__alltraps>

c01021d5 <vector71>:
.globl vector71
vector71:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $71
c01021d7:	6a 47                	push   $0x47
  jmp __alltraps
c01021d9:	e9 64 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021de <vector72>:
.globl vector72
vector72:
  pushl $0
c01021de:	6a 00                	push   $0x0
  pushl $72
c01021e0:	6a 48                	push   $0x48
  jmp __alltraps
c01021e2:	e9 5b fd ff ff       	jmp    c0101f42 <__alltraps>

c01021e7 <vector73>:
.globl vector73
vector73:
  pushl $0
c01021e7:	6a 00                	push   $0x0
  pushl $73
c01021e9:	6a 49                	push   $0x49
  jmp __alltraps
c01021eb:	e9 52 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021f0 <vector74>:
.globl vector74
vector74:
  pushl $0
c01021f0:	6a 00                	push   $0x0
  pushl $74
c01021f2:	6a 4a                	push   $0x4a
  jmp __alltraps
c01021f4:	e9 49 fd ff ff       	jmp    c0101f42 <__alltraps>

c01021f9 <vector75>:
.globl vector75
vector75:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $75
c01021fb:	6a 4b                	push   $0x4b
  jmp __alltraps
c01021fd:	e9 40 fd ff ff       	jmp    c0101f42 <__alltraps>

c0102202 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102202:	6a 00                	push   $0x0
  pushl $76
c0102204:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102206:	e9 37 fd ff ff       	jmp    c0101f42 <__alltraps>

c010220b <vector77>:
.globl vector77
vector77:
  pushl $0
c010220b:	6a 00                	push   $0x0
  pushl $77
c010220d:	6a 4d                	push   $0x4d
  jmp __alltraps
c010220f:	e9 2e fd ff ff       	jmp    c0101f42 <__alltraps>

c0102214 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $78
c0102216:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102218:	e9 25 fd ff ff       	jmp    c0101f42 <__alltraps>

c010221d <vector79>:
.globl vector79
vector79:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $79
c010221f:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102221:	e9 1c fd ff ff       	jmp    c0101f42 <__alltraps>

c0102226 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102226:	6a 00                	push   $0x0
  pushl $80
c0102228:	6a 50                	push   $0x50
  jmp __alltraps
c010222a:	e9 13 fd ff ff       	jmp    c0101f42 <__alltraps>

c010222f <vector81>:
.globl vector81
vector81:
  pushl $0
c010222f:	6a 00                	push   $0x0
  pushl $81
c0102231:	6a 51                	push   $0x51
  jmp __alltraps
c0102233:	e9 0a fd ff ff       	jmp    c0101f42 <__alltraps>

c0102238 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102238:	6a 00                	push   $0x0
  pushl $82
c010223a:	6a 52                	push   $0x52
  jmp __alltraps
c010223c:	e9 01 fd ff ff       	jmp    c0101f42 <__alltraps>

c0102241 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $83
c0102243:	6a 53                	push   $0x53
  jmp __alltraps
c0102245:	e9 f8 fc ff ff       	jmp    c0101f42 <__alltraps>

c010224a <vector84>:
.globl vector84
vector84:
  pushl $0
c010224a:	6a 00                	push   $0x0
  pushl $84
c010224c:	6a 54                	push   $0x54
  jmp __alltraps
c010224e:	e9 ef fc ff ff       	jmp    c0101f42 <__alltraps>

c0102253 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102253:	6a 00                	push   $0x0
  pushl $85
c0102255:	6a 55                	push   $0x55
  jmp __alltraps
c0102257:	e9 e6 fc ff ff       	jmp    c0101f42 <__alltraps>

c010225c <vector86>:
.globl vector86
vector86:
  pushl $0
c010225c:	6a 00                	push   $0x0
  pushl $86
c010225e:	6a 56                	push   $0x56
  jmp __alltraps
c0102260:	e9 dd fc ff ff       	jmp    c0101f42 <__alltraps>

c0102265 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $87
c0102267:	6a 57                	push   $0x57
  jmp __alltraps
c0102269:	e9 d4 fc ff ff       	jmp    c0101f42 <__alltraps>

c010226e <vector88>:
.globl vector88
vector88:
  pushl $0
c010226e:	6a 00                	push   $0x0
  pushl $88
c0102270:	6a 58                	push   $0x58
  jmp __alltraps
c0102272:	e9 cb fc ff ff       	jmp    c0101f42 <__alltraps>

c0102277 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102277:	6a 00                	push   $0x0
  pushl $89
c0102279:	6a 59                	push   $0x59
  jmp __alltraps
c010227b:	e9 c2 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102280 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102280:	6a 00                	push   $0x0
  pushl $90
c0102282:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102284:	e9 b9 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102289 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $91
c010228b:	6a 5b                	push   $0x5b
  jmp __alltraps
c010228d:	e9 b0 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102292 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102292:	6a 00                	push   $0x0
  pushl $92
c0102294:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102296:	e9 a7 fc ff ff       	jmp    c0101f42 <__alltraps>

c010229b <vector93>:
.globl vector93
vector93:
  pushl $0
c010229b:	6a 00                	push   $0x0
  pushl $93
c010229d:	6a 5d                	push   $0x5d
  jmp __alltraps
c010229f:	e9 9e fc ff ff       	jmp    c0101f42 <__alltraps>

c01022a4 <vector94>:
.globl vector94
vector94:
  pushl $0
c01022a4:	6a 00                	push   $0x0
  pushl $94
c01022a6:	6a 5e                	push   $0x5e
  jmp __alltraps
c01022a8:	e9 95 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022ad <vector95>:
.globl vector95
vector95:
  pushl $0
c01022ad:	6a 00                	push   $0x0
  pushl $95
c01022af:	6a 5f                	push   $0x5f
  jmp __alltraps
c01022b1:	e9 8c fc ff ff       	jmp    c0101f42 <__alltraps>

c01022b6 <vector96>:
.globl vector96
vector96:
  pushl $0
c01022b6:	6a 00                	push   $0x0
  pushl $96
c01022b8:	6a 60                	push   $0x60
  jmp __alltraps
c01022ba:	e9 83 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022bf <vector97>:
.globl vector97
vector97:
  pushl $0
c01022bf:	6a 00                	push   $0x0
  pushl $97
c01022c1:	6a 61                	push   $0x61
  jmp __alltraps
c01022c3:	e9 7a fc ff ff       	jmp    c0101f42 <__alltraps>

c01022c8 <vector98>:
.globl vector98
vector98:
  pushl $0
c01022c8:	6a 00                	push   $0x0
  pushl $98
c01022ca:	6a 62                	push   $0x62
  jmp __alltraps
c01022cc:	e9 71 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022d1 <vector99>:
.globl vector99
vector99:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $99
c01022d3:	6a 63                	push   $0x63
  jmp __alltraps
c01022d5:	e9 68 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022da <vector100>:
.globl vector100
vector100:
  pushl $0
c01022da:	6a 00                	push   $0x0
  pushl $100
c01022dc:	6a 64                	push   $0x64
  jmp __alltraps
c01022de:	e9 5f fc ff ff       	jmp    c0101f42 <__alltraps>

c01022e3 <vector101>:
.globl vector101
vector101:
  pushl $0
c01022e3:	6a 00                	push   $0x0
  pushl $101
c01022e5:	6a 65                	push   $0x65
  jmp __alltraps
c01022e7:	e9 56 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022ec <vector102>:
.globl vector102
vector102:
  pushl $0
c01022ec:	6a 00                	push   $0x0
  pushl $102
c01022ee:	6a 66                	push   $0x66
  jmp __alltraps
c01022f0:	e9 4d fc ff ff       	jmp    c0101f42 <__alltraps>

c01022f5 <vector103>:
.globl vector103
vector103:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $103
c01022f7:	6a 67                	push   $0x67
  jmp __alltraps
c01022f9:	e9 44 fc ff ff       	jmp    c0101f42 <__alltraps>

c01022fe <vector104>:
.globl vector104
vector104:
  pushl $0
c01022fe:	6a 00                	push   $0x0
  pushl $104
c0102300:	6a 68                	push   $0x68
  jmp __alltraps
c0102302:	e9 3b fc ff ff       	jmp    c0101f42 <__alltraps>

c0102307 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102307:	6a 00                	push   $0x0
  pushl $105
c0102309:	6a 69                	push   $0x69
  jmp __alltraps
c010230b:	e9 32 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102310 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102310:	6a 00                	push   $0x0
  pushl $106
c0102312:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102314:	e9 29 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102319 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $107
c010231b:	6a 6b                	push   $0x6b
  jmp __alltraps
c010231d:	e9 20 fc ff ff       	jmp    c0101f42 <__alltraps>

c0102322 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102322:	6a 00                	push   $0x0
  pushl $108
c0102324:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102326:	e9 17 fc ff ff       	jmp    c0101f42 <__alltraps>

c010232b <vector109>:
.globl vector109
vector109:
  pushl $0
c010232b:	6a 00                	push   $0x0
  pushl $109
c010232d:	6a 6d                	push   $0x6d
  jmp __alltraps
c010232f:	e9 0e fc ff ff       	jmp    c0101f42 <__alltraps>

c0102334 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102334:	6a 00                	push   $0x0
  pushl $110
c0102336:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102338:	e9 05 fc ff ff       	jmp    c0101f42 <__alltraps>

c010233d <vector111>:
.globl vector111
vector111:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $111
c010233f:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102341:	e9 fc fb ff ff       	jmp    c0101f42 <__alltraps>

c0102346 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102346:	6a 00                	push   $0x0
  pushl $112
c0102348:	6a 70                	push   $0x70
  jmp __alltraps
c010234a:	e9 f3 fb ff ff       	jmp    c0101f42 <__alltraps>

c010234f <vector113>:
.globl vector113
vector113:
  pushl $0
c010234f:	6a 00                	push   $0x0
  pushl $113
c0102351:	6a 71                	push   $0x71
  jmp __alltraps
c0102353:	e9 ea fb ff ff       	jmp    c0101f42 <__alltraps>

c0102358 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102358:	6a 00                	push   $0x0
  pushl $114
c010235a:	6a 72                	push   $0x72
  jmp __alltraps
c010235c:	e9 e1 fb ff ff       	jmp    c0101f42 <__alltraps>

c0102361 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $115
c0102363:	6a 73                	push   $0x73
  jmp __alltraps
c0102365:	e9 d8 fb ff ff       	jmp    c0101f42 <__alltraps>

c010236a <vector116>:
.globl vector116
vector116:
  pushl $0
c010236a:	6a 00                	push   $0x0
  pushl $116
c010236c:	6a 74                	push   $0x74
  jmp __alltraps
c010236e:	e9 cf fb ff ff       	jmp    c0101f42 <__alltraps>

c0102373 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102373:	6a 00                	push   $0x0
  pushl $117
c0102375:	6a 75                	push   $0x75
  jmp __alltraps
c0102377:	e9 c6 fb ff ff       	jmp    c0101f42 <__alltraps>

c010237c <vector118>:
.globl vector118
vector118:
  pushl $0
c010237c:	6a 00                	push   $0x0
  pushl $118
c010237e:	6a 76                	push   $0x76
  jmp __alltraps
c0102380:	e9 bd fb ff ff       	jmp    c0101f42 <__alltraps>

c0102385 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $119
c0102387:	6a 77                	push   $0x77
  jmp __alltraps
c0102389:	e9 b4 fb ff ff       	jmp    c0101f42 <__alltraps>

c010238e <vector120>:
.globl vector120
vector120:
  pushl $0
c010238e:	6a 00                	push   $0x0
  pushl $120
c0102390:	6a 78                	push   $0x78
  jmp __alltraps
c0102392:	e9 ab fb ff ff       	jmp    c0101f42 <__alltraps>

c0102397 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102397:	6a 00                	push   $0x0
  pushl $121
c0102399:	6a 79                	push   $0x79
  jmp __alltraps
c010239b:	e9 a2 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023a0 <vector122>:
.globl vector122
vector122:
  pushl $0
c01023a0:	6a 00                	push   $0x0
  pushl $122
c01023a2:	6a 7a                	push   $0x7a
  jmp __alltraps
c01023a4:	e9 99 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023a9 <vector123>:
.globl vector123
vector123:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $123
c01023ab:	6a 7b                	push   $0x7b
  jmp __alltraps
c01023ad:	e9 90 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023b2 <vector124>:
.globl vector124
vector124:
  pushl $0
c01023b2:	6a 00                	push   $0x0
  pushl $124
c01023b4:	6a 7c                	push   $0x7c
  jmp __alltraps
c01023b6:	e9 87 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023bb <vector125>:
.globl vector125
vector125:
  pushl $0
c01023bb:	6a 00                	push   $0x0
  pushl $125
c01023bd:	6a 7d                	push   $0x7d
  jmp __alltraps
c01023bf:	e9 7e fb ff ff       	jmp    c0101f42 <__alltraps>

c01023c4 <vector126>:
.globl vector126
vector126:
  pushl $0
c01023c4:	6a 00                	push   $0x0
  pushl $126
c01023c6:	6a 7e                	push   $0x7e
  jmp __alltraps
c01023c8:	e9 75 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023cd <vector127>:
.globl vector127
vector127:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $127
c01023cf:	6a 7f                	push   $0x7f
  jmp __alltraps
c01023d1:	e9 6c fb ff ff       	jmp    c0101f42 <__alltraps>

c01023d6 <vector128>:
.globl vector128
vector128:
  pushl $0
c01023d6:	6a 00                	push   $0x0
  pushl $128
c01023d8:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01023dd:	e9 60 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023e2 <vector129>:
.globl vector129
vector129:
  pushl $0
c01023e2:	6a 00                	push   $0x0
  pushl $129
c01023e4:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01023e9:	e9 54 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023ee <vector130>:
.globl vector130
vector130:
  pushl $0
c01023ee:	6a 00                	push   $0x0
  pushl $130
c01023f0:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01023f5:	e9 48 fb ff ff       	jmp    c0101f42 <__alltraps>

c01023fa <vector131>:
.globl vector131
vector131:
  pushl $0
c01023fa:	6a 00                	push   $0x0
  pushl $131
c01023fc:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102401:	e9 3c fb ff ff       	jmp    c0101f42 <__alltraps>

c0102406 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102406:	6a 00                	push   $0x0
  pushl $132
c0102408:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010240d:	e9 30 fb ff ff       	jmp    c0101f42 <__alltraps>

c0102412 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102412:	6a 00                	push   $0x0
  pushl $133
c0102414:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102419:	e9 24 fb ff ff       	jmp    c0101f42 <__alltraps>

c010241e <vector134>:
.globl vector134
vector134:
  pushl $0
c010241e:	6a 00                	push   $0x0
  pushl $134
c0102420:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102425:	e9 18 fb ff ff       	jmp    c0101f42 <__alltraps>

c010242a <vector135>:
.globl vector135
vector135:
  pushl $0
c010242a:	6a 00                	push   $0x0
  pushl $135
c010242c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102431:	e9 0c fb ff ff       	jmp    c0101f42 <__alltraps>

c0102436 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102436:	6a 00                	push   $0x0
  pushl $136
c0102438:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010243d:	e9 00 fb ff ff       	jmp    c0101f42 <__alltraps>

c0102442 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102442:	6a 00                	push   $0x0
  pushl $137
c0102444:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102449:	e9 f4 fa ff ff       	jmp    c0101f42 <__alltraps>

c010244e <vector138>:
.globl vector138
vector138:
  pushl $0
c010244e:	6a 00                	push   $0x0
  pushl $138
c0102450:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102455:	e9 e8 fa ff ff       	jmp    c0101f42 <__alltraps>

c010245a <vector139>:
.globl vector139
vector139:
  pushl $0
c010245a:	6a 00                	push   $0x0
  pushl $139
c010245c:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102461:	e9 dc fa ff ff       	jmp    c0101f42 <__alltraps>

c0102466 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102466:	6a 00                	push   $0x0
  pushl $140
c0102468:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010246d:	e9 d0 fa ff ff       	jmp    c0101f42 <__alltraps>

c0102472 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102472:	6a 00                	push   $0x0
  pushl $141
c0102474:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102479:	e9 c4 fa ff ff       	jmp    c0101f42 <__alltraps>

c010247e <vector142>:
.globl vector142
vector142:
  pushl $0
c010247e:	6a 00                	push   $0x0
  pushl $142
c0102480:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102485:	e9 b8 fa ff ff       	jmp    c0101f42 <__alltraps>

c010248a <vector143>:
.globl vector143
vector143:
  pushl $0
c010248a:	6a 00                	push   $0x0
  pushl $143
c010248c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102491:	e9 ac fa ff ff       	jmp    c0101f42 <__alltraps>

c0102496 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102496:	6a 00                	push   $0x0
  pushl $144
c0102498:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010249d:	e9 a0 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024a2 <vector145>:
.globl vector145
vector145:
  pushl $0
c01024a2:	6a 00                	push   $0x0
  pushl $145
c01024a4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01024a9:	e9 94 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024ae <vector146>:
.globl vector146
vector146:
  pushl $0
c01024ae:	6a 00                	push   $0x0
  pushl $146
c01024b0:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01024b5:	e9 88 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024ba <vector147>:
.globl vector147
vector147:
  pushl $0
c01024ba:	6a 00                	push   $0x0
  pushl $147
c01024bc:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01024c1:	e9 7c fa ff ff       	jmp    c0101f42 <__alltraps>

c01024c6 <vector148>:
.globl vector148
vector148:
  pushl $0
c01024c6:	6a 00                	push   $0x0
  pushl $148
c01024c8:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01024cd:	e9 70 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024d2 <vector149>:
.globl vector149
vector149:
  pushl $0
c01024d2:	6a 00                	push   $0x0
  pushl $149
c01024d4:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01024d9:	e9 64 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024de <vector150>:
.globl vector150
vector150:
  pushl $0
c01024de:	6a 00                	push   $0x0
  pushl $150
c01024e0:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01024e5:	e9 58 fa ff ff       	jmp    c0101f42 <__alltraps>

c01024ea <vector151>:
.globl vector151
vector151:
  pushl $0
c01024ea:	6a 00                	push   $0x0
  pushl $151
c01024ec:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01024f1:	e9 4c fa ff ff       	jmp    c0101f42 <__alltraps>

c01024f6 <vector152>:
.globl vector152
vector152:
  pushl $0
c01024f6:	6a 00                	push   $0x0
  pushl $152
c01024f8:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01024fd:	e9 40 fa ff ff       	jmp    c0101f42 <__alltraps>

c0102502 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102502:	6a 00                	push   $0x0
  pushl $153
c0102504:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102509:	e9 34 fa ff ff       	jmp    c0101f42 <__alltraps>

c010250e <vector154>:
.globl vector154
vector154:
  pushl $0
c010250e:	6a 00                	push   $0x0
  pushl $154
c0102510:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102515:	e9 28 fa ff ff       	jmp    c0101f42 <__alltraps>

c010251a <vector155>:
.globl vector155
vector155:
  pushl $0
c010251a:	6a 00                	push   $0x0
  pushl $155
c010251c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102521:	e9 1c fa ff ff       	jmp    c0101f42 <__alltraps>

c0102526 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102526:	6a 00                	push   $0x0
  pushl $156
c0102528:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010252d:	e9 10 fa ff ff       	jmp    c0101f42 <__alltraps>

c0102532 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102532:	6a 00                	push   $0x0
  pushl $157
c0102534:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102539:	e9 04 fa ff ff       	jmp    c0101f42 <__alltraps>

c010253e <vector158>:
.globl vector158
vector158:
  pushl $0
c010253e:	6a 00                	push   $0x0
  pushl $158
c0102540:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102545:	e9 f8 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010254a <vector159>:
.globl vector159
vector159:
  pushl $0
c010254a:	6a 00                	push   $0x0
  pushl $159
c010254c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102551:	e9 ec f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102556 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102556:	6a 00                	push   $0x0
  pushl $160
c0102558:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010255d:	e9 e0 f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102562 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102562:	6a 00                	push   $0x0
  pushl $161
c0102564:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102569:	e9 d4 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010256e <vector162>:
.globl vector162
vector162:
  pushl $0
c010256e:	6a 00                	push   $0x0
  pushl $162
c0102570:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102575:	e9 c8 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010257a <vector163>:
.globl vector163
vector163:
  pushl $0
c010257a:	6a 00                	push   $0x0
  pushl $163
c010257c:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102581:	e9 bc f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102586 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102586:	6a 00                	push   $0x0
  pushl $164
c0102588:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010258d:	e9 b0 f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102592 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102592:	6a 00                	push   $0x0
  pushl $165
c0102594:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102599:	e9 a4 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010259e <vector166>:
.globl vector166
vector166:
  pushl $0
c010259e:	6a 00                	push   $0x0
  pushl $166
c01025a0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01025a5:	e9 98 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025aa <vector167>:
.globl vector167
vector167:
  pushl $0
c01025aa:	6a 00                	push   $0x0
  pushl $167
c01025ac:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01025b1:	e9 8c f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025b6 <vector168>:
.globl vector168
vector168:
  pushl $0
c01025b6:	6a 00                	push   $0x0
  pushl $168
c01025b8:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01025bd:	e9 80 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025c2 <vector169>:
.globl vector169
vector169:
  pushl $0
c01025c2:	6a 00                	push   $0x0
  pushl $169
c01025c4:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01025c9:	e9 74 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025ce <vector170>:
.globl vector170
vector170:
  pushl $0
c01025ce:	6a 00                	push   $0x0
  pushl $170
c01025d0:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01025d5:	e9 68 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025da <vector171>:
.globl vector171
vector171:
  pushl $0
c01025da:	6a 00                	push   $0x0
  pushl $171
c01025dc:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01025e1:	e9 5c f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025e6 <vector172>:
.globl vector172
vector172:
  pushl $0
c01025e6:	6a 00                	push   $0x0
  pushl $172
c01025e8:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01025ed:	e9 50 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025f2 <vector173>:
.globl vector173
vector173:
  pushl $0
c01025f2:	6a 00                	push   $0x0
  pushl $173
c01025f4:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01025f9:	e9 44 f9 ff ff       	jmp    c0101f42 <__alltraps>

c01025fe <vector174>:
.globl vector174
vector174:
  pushl $0
c01025fe:	6a 00                	push   $0x0
  pushl $174
c0102600:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102605:	e9 38 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010260a <vector175>:
.globl vector175
vector175:
  pushl $0
c010260a:	6a 00                	push   $0x0
  pushl $175
c010260c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102611:	e9 2c f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102616 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102616:	6a 00                	push   $0x0
  pushl $176
c0102618:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010261d:	e9 20 f9 ff ff       	jmp    c0101f42 <__alltraps>

c0102622 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102622:	6a 00                	push   $0x0
  pushl $177
c0102624:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102629:	e9 14 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010262e <vector178>:
.globl vector178
vector178:
  pushl $0
c010262e:	6a 00                	push   $0x0
  pushl $178
c0102630:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102635:	e9 08 f9 ff ff       	jmp    c0101f42 <__alltraps>

c010263a <vector179>:
.globl vector179
vector179:
  pushl $0
c010263a:	6a 00                	push   $0x0
  pushl $179
c010263c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102641:	e9 fc f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102646 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102646:	6a 00                	push   $0x0
  pushl $180
c0102648:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010264d:	e9 f0 f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102652 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102652:	6a 00                	push   $0x0
  pushl $181
c0102654:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102659:	e9 e4 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010265e <vector182>:
.globl vector182
vector182:
  pushl $0
c010265e:	6a 00                	push   $0x0
  pushl $182
c0102660:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102665:	e9 d8 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010266a <vector183>:
.globl vector183
vector183:
  pushl $0
c010266a:	6a 00                	push   $0x0
  pushl $183
c010266c:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102671:	e9 cc f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102676 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102676:	6a 00                	push   $0x0
  pushl $184
c0102678:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010267d:	e9 c0 f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102682 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102682:	6a 00                	push   $0x0
  pushl $185
c0102684:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102689:	e9 b4 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010268e <vector186>:
.globl vector186
vector186:
  pushl $0
c010268e:	6a 00                	push   $0x0
  pushl $186
c0102690:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102695:	e9 a8 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010269a <vector187>:
.globl vector187
vector187:
  pushl $0
c010269a:	6a 00                	push   $0x0
  pushl $187
c010269c:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01026a1:	e9 9c f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026a6 <vector188>:
.globl vector188
vector188:
  pushl $0
c01026a6:	6a 00                	push   $0x0
  pushl $188
c01026a8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01026ad:	e9 90 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026b2 <vector189>:
.globl vector189
vector189:
  pushl $0
c01026b2:	6a 00                	push   $0x0
  pushl $189
c01026b4:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01026b9:	e9 84 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026be <vector190>:
.globl vector190
vector190:
  pushl $0
c01026be:	6a 00                	push   $0x0
  pushl $190
c01026c0:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01026c5:	e9 78 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026ca <vector191>:
.globl vector191
vector191:
  pushl $0
c01026ca:	6a 00                	push   $0x0
  pushl $191
c01026cc:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01026d1:	e9 6c f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026d6 <vector192>:
.globl vector192
vector192:
  pushl $0
c01026d6:	6a 00                	push   $0x0
  pushl $192
c01026d8:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01026dd:	e9 60 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026e2 <vector193>:
.globl vector193
vector193:
  pushl $0
c01026e2:	6a 00                	push   $0x0
  pushl $193
c01026e4:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01026e9:	e9 54 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026ee <vector194>:
.globl vector194
vector194:
  pushl $0
c01026ee:	6a 00                	push   $0x0
  pushl $194
c01026f0:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01026f5:	e9 48 f8 ff ff       	jmp    c0101f42 <__alltraps>

c01026fa <vector195>:
.globl vector195
vector195:
  pushl $0
c01026fa:	6a 00                	push   $0x0
  pushl $195
c01026fc:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102701:	e9 3c f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102706 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102706:	6a 00                	push   $0x0
  pushl $196
c0102708:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010270d:	e9 30 f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102712 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102712:	6a 00                	push   $0x0
  pushl $197
c0102714:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102719:	e9 24 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010271e <vector198>:
.globl vector198
vector198:
  pushl $0
c010271e:	6a 00                	push   $0x0
  pushl $198
c0102720:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102725:	e9 18 f8 ff ff       	jmp    c0101f42 <__alltraps>

c010272a <vector199>:
.globl vector199
vector199:
  pushl $0
c010272a:	6a 00                	push   $0x0
  pushl $199
c010272c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102731:	e9 0c f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102736 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102736:	6a 00                	push   $0x0
  pushl $200
c0102738:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010273d:	e9 00 f8 ff ff       	jmp    c0101f42 <__alltraps>

c0102742 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102742:	6a 00                	push   $0x0
  pushl $201
c0102744:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102749:	e9 f4 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010274e <vector202>:
.globl vector202
vector202:
  pushl $0
c010274e:	6a 00                	push   $0x0
  pushl $202
c0102750:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102755:	e9 e8 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010275a <vector203>:
.globl vector203
vector203:
  pushl $0
c010275a:	6a 00                	push   $0x0
  pushl $203
c010275c:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102761:	e9 dc f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102766 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102766:	6a 00                	push   $0x0
  pushl $204
c0102768:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010276d:	e9 d0 f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102772 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102772:	6a 00                	push   $0x0
  pushl $205
c0102774:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102779:	e9 c4 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010277e <vector206>:
.globl vector206
vector206:
  pushl $0
c010277e:	6a 00                	push   $0x0
  pushl $206
c0102780:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102785:	e9 b8 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010278a <vector207>:
.globl vector207
vector207:
  pushl $0
c010278a:	6a 00                	push   $0x0
  pushl $207
c010278c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102791:	e9 ac f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102796 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102796:	6a 00                	push   $0x0
  pushl $208
c0102798:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010279d:	e9 a0 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027a2 <vector209>:
.globl vector209
vector209:
  pushl $0
c01027a2:	6a 00                	push   $0x0
  pushl $209
c01027a4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01027a9:	e9 94 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027ae <vector210>:
.globl vector210
vector210:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $210
c01027b0:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01027b5:	e9 88 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027ba <vector211>:
.globl vector211
vector211:
  pushl $0
c01027ba:	6a 00                	push   $0x0
  pushl $211
c01027bc:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01027c1:	e9 7c f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027c6 <vector212>:
.globl vector212
vector212:
  pushl $0
c01027c6:	6a 00                	push   $0x0
  pushl $212
c01027c8:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01027cd:	e9 70 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027d2 <vector213>:
.globl vector213
vector213:
  pushl $0
c01027d2:	6a 00                	push   $0x0
  pushl $213
c01027d4:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01027d9:	e9 64 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027de <vector214>:
.globl vector214
vector214:
  pushl $0
c01027de:	6a 00                	push   $0x0
  pushl $214
c01027e0:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01027e5:	e9 58 f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027ea <vector215>:
.globl vector215
vector215:
  pushl $0
c01027ea:	6a 00                	push   $0x0
  pushl $215
c01027ec:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01027f1:	e9 4c f7 ff ff       	jmp    c0101f42 <__alltraps>

c01027f6 <vector216>:
.globl vector216
vector216:
  pushl $0
c01027f6:	6a 00                	push   $0x0
  pushl $216
c01027f8:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01027fd:	e9 40 f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102802 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102802:	6a 00                	push   $0x0
  pushl $217
c0102804:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102809:	e9 34 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010280e <vector218>:
.globl vector218
vector218:
  pushl $0
c010280e:	6a 00                	push   $0x0
  pushl $218
c0102810:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102815:	e9 28 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010281a <vector219>:
.globl vector219
vector219:
  pushl $0
c010281a:	6a 00                	push   $0x0
  pushl $219
c010281c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102821:	e9 1c f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102826 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $220
c0102828:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010282d:	e9 10 f7 ff ff       	jmp    c0101f42 <__alltraps>

c0102832 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102832:	6a 00                	push   $0x0
  pushl $221
c0102834:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102839:	e9 04 f7 ff ff       	jmp    c0101f42 <__alltraps>

c010283e <vector222>:
.globl vector222
vector222:
  pushl $0
c010283e:	6a 00                	push   $0x0
  pushl $222
c0102840:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102845:	e9 f8 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010284a <vector223>:
.globl vector223
vector223:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $223
c010284c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102851:	e9 ec f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102856 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102856:	6a 00                	push   $0x0
  pushl $224
c0102858:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010285d:	e9 e0 f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102862 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102862:	6a 00                	push   $0x0
  pushl $225
c0102864:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102869:	e9 d4 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010286e <vector226>:
.globl vector226
vector226:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $226
c0102870:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102875:	e9 c8 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010287a <vector227>:
.globl vector227
vector227:
  pushl $0
c010287a:	6a 00                	push   $0x0
  pushl $227
c010287c:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102881:	e9 bc f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102886 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102886:	6a 00                	push   $0x0
  pushl $228
c0102888:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010288d:	e9 b0 f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102892 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $229
c0102894:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102899:	e9 a4 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010289e <vector230>:
.globl vector230
vector230:
  pushl $0
c010289e:	6a 00                	push   $0x0
  pushl $230
c01028a0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01028a5:	e9 98 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028aa <vector231>:
.globl vector231
vector231:
  pushl $0
c01028aa:	6a 00                	push   $0x0
  pushl $231
c01028ac:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01028b1:	e9 8c f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028b6 <vector232>:
.globl vector232
vector232:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $232
c01028b8:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01028bd:	e9 80 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028c2 <vector233>:
.globl vector233
vector233:
  pushl $0
c01028c2:	6a 00                	push   $0x0
  pushl $233
c01028c4:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01028c9:	e9 74 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028ce <vector234>:
.globl vector234
vector234:
  pushl $0
c01028ce:	6a 00                	push   $0x0
  pushl $234
c01028d0:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01028d5:	e9 68 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028da <vector235>:
.globl vector235
vector235:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $235
c01028dc:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01028e1:	e9 5c f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028e6 <vector236>:
.globl vector236
vector236:
  pushl $0
c01028e6:	6a 00                	push   $0x0
  pushl $236
c01028e8:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01028ed:	e9 50 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028f2 <vector237>:
.globl vector237
vector237:
  pushl $0
c01028f2:	6a 00                	push   $0x0
  pushl $237
c01028f4:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01028f9:	e9 44 f6 ff ff       	jmp    c0101f42 <__alltraps>

c01028fe <vector238>:
.globl vector238
vector238:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $238
c0102900:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102905:	e9 38 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010290a <vector239>:
.globl vector239
vector239:
  pushl $0
c010290a:	6a 00                	push   $0x0
  pushl $239
c010290c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102911:	e9 2c f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102916 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102916:	6a 00                	push   $0x0
  pushl $240
c0102918:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010291d:	e9 20 f6 ff ff       	jmp    c0101f42 <__alltraps>

c0102922 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $241
c0102924:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102929:	e9 14 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010292e <vector242>:
.globl vector242
vector242:
  pushl $0
c010292e:	6a 00                	push   $0x0
  pushl $242
c0102930:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102935:	e9 08 f6 ff ff       	jmp    c0101f42 <__alltraps>

c010293a <vector243>:
.globl vector243
vector243:
  pushl $0
c010293a:	6a 00                	push   $0x0
  pushl $243
c010293c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102941:	e9 fc f5 ff ff       	jmp    c0101f42 <__alltraps>

c0102946 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $244
c0102948:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010294d:	e9 f0 f5 ff ff       	jmp    c0101f42 <__alltraps>

c0102952 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102952:	6a 00                	push   $0x0
  pushl $245
c0102954:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102959:	e9 e4 f5 ff ff       	jmp    c0101f42 <__alltraps>

c010295e <vector246>:
.globl vector246
vector246:
  pushl $0
c010295e:	6a 00                	push   $0x0
  pushl $246
c0102960:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102965:	e9 d8 f5 ff ff       	jmp    c0101f42 <__alltraps>

c010296a <vector247>:
.globl vector247
vector247:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $247
c010296c:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102971:	e9 cc f5 ff ff       	jmp    c0101f42 <__alltraps>

c0102976 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102976:	6a 00                	push   $0x0
  pushl $248
c0102978:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010297d:	e9 c0 f5 ff ff       	jmp    c0101f42 <__alltraps>

c0102982 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102982:	6a 00                	push   $0x0
  pushl $249
c0102984:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102989:	e9 b4 f5 ff ff       	jmp    c0101f42 <__alltraps>

c010298e <vector250>:
.globl vector250
vector250:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $250
c0102990:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102995:	e9 a8 f5 ff ff       	jmp    c0101f42 <__alltraps>

c010299a <vector251>:
.globl vector251
vector251:
  pushl $0
c010299a:	6a 00                	push   $0x0
  pushl $251
c010299c:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01029a1:	e9 9c f5 ff ff       	jmp    c0101f42 <__alltraps>

c01029a6 <vector252>:
.globl vector252
vector252:
  pushl $0
c01029a6:	6a 00                	push   $0x0
  pushl $252
c01029a8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01029ad:	e9 90 f5 ff ff       	jmp    c0101f42 <__alltraps>

c01029b2 <vector253>:
.globl vector253
vector253:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $253
c01029b4:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01029b9:	e9 84 f5 ff ff       	jmp    c0101f42 <__alltraps>

c01029be <vector254>:
.globl vector254
vector254:
  pushl $0
c01029be:	6a 00                	push   $0x0
  pushl $254
c01029c0:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01029c5:	e9 78 f5 ff ff       	jmp    c0101f42 <__alltraps>

c01029ca <vector255>:
.globl vector255
vector255:
  pushl $0
c01029ca:	6a 00                	push   $0x0
  pushl $255
c01029cc:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01029d1:	e9 6c f5 ff ff       	jmp    c0101f42 <__alltraps>

c01029d6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01029d6:	55                   	push   %ebp
c01029d7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01029d9:	8b 55 08             	mov    0x8(%ebp),%edx
c01029dc:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01029e1:	29 c2                	sub    %eax,%edx
c01029e3:	89 d0                	mov    %edx,%eax
c01029e5:	c1 f8 02             	sar    $0x2,%eax
c01029e8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01029ee:	5d                   	pop    %ebp
c01029ef:	c3                   	ret    

c01029f0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01029f0:	55                   	push   %ebp
c01029f1:	89 e5                	mov    %esp,%ebp
c01029f3:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01029f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f9:	89 04 24             	mov    %eax,(%esp)
c01029fc:	e8 d5 ff ff ff       	call   c01029d6 <page2ppn>
c0102a01:	c1 e0 0c             	shl    $0xc,%eax
}
c0102a04:	c9                   	leave  
c0102a05:	c3                   	ret    

c0102a06 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102a06:	55                   	push   %ebp
c0102a07:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102a09:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0c:	8b 00                	mov    (%eax),%eax
}
c0102a0e:	5d                   	pop    %ebp
c0102a0f:	c3                   	ret    

c0102a10 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102a10:	55                   	push   %ebp
c0102a11:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a16:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102a19:	89 10                	mov    %edx,(%eax)
}
c0102a1b:	5d                   	pop    %ebp
c0102a1c:	c3                   	ret    

c0102a1d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102a1d:	55                   	push   %ebp
c0102a1e:	89 e5                	mov    %esp,%ebp
c0102a20:	83 ec 10             	sub    $0x10,%esp
c0102a23:	c7 45 fc 70 af 11 c0 	movl   $0xc011af70,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102a30:	89 50 04             	mov    %edx,0x4(%eax)
c0102a33:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a36:	8b 50 04             	mov    0x4(%eax),%edx
c0102a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a3c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0102a3e:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c0102a45:	00 00 00 
}
c0102a48:	c9                   	leave  
c0102a49:	c3                   	ret    

c0102a4a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102a4a:	55                   	push   %ebp
c0102a4b:	89 e5                	mov    %esp,%ebp
c0102a4d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0102a50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102a54:	75 24                	jne    c0102a7a <default_init_memmap+0x30>
c0102a56:	c7 44 24 0c 90 68 10 	movl   $0xc0106890,0xc(%esp)
c0102a5d:	c0 
c0102a5e:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102a65:	c0 
c0102a66:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102a6d:	00 
c0102a6e:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102a75:	e8 72 e2 ff ff       	call   c0100cec <__panic>
    struct Page *p = base;
c0102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102a80:	eb 7d                	jmp    c0102aff <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a85:	83 c0 04             	add    $0x4,%eax
c0102a88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a95:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102a98:	0f a3 10             	bt     %edx,(%eax)
c0102a9b:	19 c0                	sbb    %eax,%eax
c0102a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102aa0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102aa4:	0f 95 c0             	setne  %al
c0102aa7:	0f b6 c0             	movzbl %al,%eax
c0102aaa:	85 c0                	test   %eax,%eax
c0102aac:	75 24                	jne    c0102ad2 <default_init_memmap+0x88>
c0102aae:	c7 44 24 0c c1 68 10 	movl   $0xc01068c1,0xc(%esp)
c0102ab5:	c0 
c0102ab6:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102abd:	c0 
c0102abe:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102ac5:	00 
c0102ac6:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102acd:	e8 1a e2 ff ff       	call   c0100cec <__panic>
        p->flags = p->property = 0;
c0102ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102adf:	8b 50 08             	mov    0x8(%eax),%edx
c0102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ae5:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102ae8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102aef:	00 
c0102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102af3:	89 04 24             	mov    %eax,(%esp)
c0102af6:	e8 15 ff ff ff       	call   c0102a10 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102afb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102aff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b02:	89 d0                	mov    %edx,%eax
c0102b04:	c1 e0 02             	shl    $0x2,%eax
c0102b07:	01 d0                	add    %edx,%eax
c0102b09:	c1 e0 02             	shl    $0x2,%eax
c0102b0c:	89 c2                	mov    %eax,%edx
c0102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b11:	01 d0                	add    %edx,%eax
c0102b13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102b16:	0f 85 66 ff ff ff    	jne    c0102a82 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b22:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b28:	83 c0 04             	add    $0x4,%eax
c0102b2b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102b32:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b35:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102b38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102b3b:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0102b3e:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c0102b44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102b47:	01 d0                	add    %edx,%eax
c0102b49:	a3 78 af 11 c0       	mov    %eax,0xc011af78
    list_add_before(&free_list, &(base->page_link));
c0102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b51:	83 c0 0c             	add    $0xc,%eax
c0102b54:	c7 45 dc 70 af 11 c0 	movl   $0xc011af70,-0x24(%ebp)
c0102b5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b61:	8b 00                	mov    (%eax),%eax
c0102b63:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b66:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102b69:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102b6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b72:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b78:	89 10                	mov    %edx,(%eax)
c0102b7a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b7d:	8b 10                	mov    (%eax),%edx
c0102b7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b82:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b88:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b8b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102b91:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b94:	89 10                	mov    %edx,(%eax)
}
c0102b96:	c9                   	leave  
c0102b97:	c3                   	ret    

c0102b98 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102b98:	55                   	push   %ebp
c0102b99:	89 e5                	mov    %esp,%ebp
c0102b9b:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102b9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102ba2:	75 24                	jne    c0102bc8 <default_alloc_pages+0x30>
c0102ba4:	c7 44 24 0c 90 68 10 	movl   $0xc0106890,0xc(%esp)
c0102bab:	c0 
c0102bac:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102bb3:	c0 
c0102bb4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102bbb:	00 
c0102bbc:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102bc3:	e8 24 e1 ff ff       	call   c0100cec <__panic>
    if (n > nr_free) {
c0102bc8:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0102bcd:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102bd0:	73 0a                	jae    c0102bdc <default_alloc_pages+0x44>
        return NULL;
c0102bd2:	b8 00 00 00 00       	mov    $0x0,%eax
c0102bd7:	e9 3d 01 00 00       	jmp    c0102d19 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0102bdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102be3:	c7 45 f0 70 af 11 c0 	movl   $0xc011af70,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0102bea:	eb 1c                	jmp    c0102c08 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bef:	83 e8 0c             	sub    $0xc,%eax
c0102bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102bf8:	8b 40 08             	mov    0x8(%eax),%eax
c0102bfb:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102bfe:	72 08                	jb     c0102c08 <default_alloc_pages+0x70>
            page = p;
c0102c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102c06:	eb 18                	jmp    c0102c20 <default_alloc_pages+0x88>
c0102c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c11:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0102c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102c17:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102c1e:	75 cc                	jne    c0102bec <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102c24:	0f 84 ec 00 00 00    	je     c0102d16 <default_alloc_pages+0x17e>
        if (page->property > n) {
c0102c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c2d:	8b 40 08             	mov    0x8(%eax),%eax
c0102c30:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102c33:	0f 86 8c 00 00 00    	jbe    c0102cc5 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c0102c39:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c3c:	89 d0                	mov    %edx,%eax
c0102c3e:	c1 e0 02             	shl    $0x2,%eax
c0102c41:	01 d0                	add    %edx,%eax
c0102c43:	c1 e0 02             	shl    $0x2,%eax
c0102c46:	89 c2                	mov    %eax,%edx
c0102c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c4b:	01 d0                	add    %edx,%eax
c0102c4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c53:	8b 40 08             	mov    0x8(%eax),%eax
c0102c56:	2b 45 08             	sub    0x8(%ebp),%eax
c0102c59:	89 c2                	mov    %eax,%edx
c0102c5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c5e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c64:	83 c0 04             	add    $0x4,%eax
c0102c67:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102c6e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102c71:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c74:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102c77:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0102c7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c7d:	83 c0 0c             	add    $0xc,%eax
c0102c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102c83:	83 c2 0c             	add    $0xc,%edx
c0102c86:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102c89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102c8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102c8f:	8b 40 04             	mov    0x4(%eax),%eax
c0102c92:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102c95:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102c98:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102c9b:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102c9e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102ca1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102ca4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102ca7:	89 10                	mov    %edx,(%eax)
c0102ca9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cac:	8b 10                	mov    (%eax),%edx
c0102cae:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102cb1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102cb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cb7:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102cba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102cbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cc0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102cc3:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cc8:	83 c0 0c             	add    $0xc,%eax
c0102ccb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102cce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102cd1:	8b 40 04             	mov    0x4(%eax),%eax
c0102cd4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102cd7:	8b 12                	mov    (%edx),%edx
c0102cd9:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102cdc:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102cdf:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102ce2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102ce5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ce8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102ceb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102cee:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0102cf0:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0102cf5:	2b 45 08             	sub    0x8(%ebp),%eax
c0102cf8:	a3 78 af 11 c0       	mov    %eax,0xc011af78
        ClearPageProperty(page);
c0102cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d00:	83 c0 04             	add    $0x4,%eax
c0102d03:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102d0a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d0d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d10:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d13:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102d19:	c9                   	leave  
c0102d1a:	c3                   	ret    

c0102d1b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102d1b:	55                   	push   %ebp
c0102d1c:	89 e5                	mov    %esp,%ebp
c0102d1e:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102d24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102d28:	75 24                	jne    c0102d4e <default_free_pages+0x33>
c0102d2a:	c7 44 24 0c 90 68 10 	movl   $0xc0106890,0xc(%esp)
c0102d31:	c0 
c0102d32:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102d39:	c0 
c0102d3a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0102d41:	00 
c0102d42:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102d49:	e8 9e df ff ff       	call   c0100cec <__panic>
    struct Page *p = base;
c0102d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102d54:	e9 9d 00 00 00       	jmp    c0102df6 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d5c:	83 c0 04             	add    $0x4,%eax
c0102d5f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102d6f:	0f a3 10             	bt     %edx,(%eax)
c0102d72:	19 c0                	sbb    %eax,%eax
c0102d74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102d77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d7b:	0f 95 c0             	setne  %al
c0102d7e:	0f b6 c0             	movzbl %al,%eax
c0102d81:	85 c0                	test   %eax,%eax
c0102d83:	75 2c                	jne    c0102db1 <default_free_pages+0x96>
c0102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d88:	83 c0 04             	add    $0x4,%eax
c0102d8b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102d92:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102d98:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102d9b:	0f a3 10             	bt     %edx,(%eax)
c0102d9e:	19 c0                	sbb    %eax,%eax
c0102da0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102da3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102da7:	0f 95 c0             	setne  %al
c0102daa:	0f b6 c0             	movzbl %al,%eax
c0102dad:	85 c0                	test   %eax,%eax
c0102daf:	74 24                	je     c0102dd5 <default_free_pages+0xba>
c0102db1:	c7 44 24 0c d4 68 10 	movl   $0xc01068d4,0xc(%esp)
c0102db8:	c0 
c0102db9:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102dc0:	c0 
c0102dc1:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c0102dc8:	00 
c0102dc9:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102dd0:	e8 17 df ff ff       	call   c0100cec <__panic>
        p->flags = 0;
c0102dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dd8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102ddf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102de6:	00 
c0102de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dea:	89 04 24             	mov    %eax,(%esp)
c0102ded:	e8 1e fc ff ff       	call   c0102a10 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102df2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102df6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102df9:	89 d0                	mov    %edx,%eax
c0102dfb:	c1 e0 02             	shl    $0x2,%eax
c0102dfe:	01 d0                	add    %edx,%eax
c0102e00:	c1 e0 02             	shl    $0x2,%eax
c0102e03:	89 c2                	mov    %eax,%edx
c0102e05:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e08:	01 d0                	add    %edx,%eax
c0102e0a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e0d:	0f 85 46 ff ff ff    	jne    c0102d59 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e16:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e19:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102e1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e1f:	83 c0 04             	add    $0x4,%eax
c0102e22:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102e29:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102e2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102e32:	0f ab 10             	bts    %edx,(%eax)
c0102e35:	c7 45 cc 70 af 11 c0 	movl   $0xc011af70,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102e3c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102e3f:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102e45:	e9 08 01 00 00       	jmp    c0102f52 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0102e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e4d:	83 e8 0c             	sub    $0xc,%eax
c0102e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e56:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102e59:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102e5c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102e5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0102e62:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e65:	8b 50 08             	mov    0x8(%eax),%edx
c0102e68:	89 d0                	mov    %edx,%eax
c0102e6a:	c1 e0 02             	shl    $0x2,%eax
c0102e6d:	01 d0                	add    %edx,%eax
c0102e6f:	c1 e0 02             	shl    $0x2,%eax
c0102e72:	89 c2                	mov    %eax,%edx
c0102e74:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e77:	01 d0                	add    %edx,%eax
c0102e79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e7c:	75 5a                	jne    c0102ed8 <default_free_pages+0x1bd>
            base->property += p->property;
c0102e7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e81:	8b 50 08             	mov    0x8(%eax),%edx
c0102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e87:	8b 40 08             	mov    0x8(%eax),%eax
c0102e8a:	01 c2                	add    %eax,%edx
c0102e8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e8f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e95:	83 c0 04             	add    $0x4,%eax
c0102e98:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102e9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ea2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102ea5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102ea8:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eae:	83 c0 0c             	add    $0xc,%eax
c0102eb1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102eb4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102eb7:	8b 40 04             	mov    0x4(%eax),%eax
c0102eba:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102ebd:	8b 12                	mov    (%edx),%edx
c0102ebf:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102ec2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102ec5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ec8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102ecb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102ece:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102ed1:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102ed4:	89 10                	mov    %edx,(%eax)
c0102ed6:	eb 7a                	jmp    c0102f52 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102edb:	8b 50 08             	mov    0x8(%eax),%edx
c0102ede:	89 d0                	mov    %edx,%eax
c0102ee0:	c1 e0 02             	shl    $0x2,%eax
c0102ee3:	01 d0                	add    %edx,%eax
c0102ee5:	c1 e0 02             	shl    $0x2,%eax
c0102ee8:	89 c2                	mov    %eax,%edx
c0102eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eed:	01 d0                	add    %edx,%eax
c0102eef:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ef2:	75 5e                	jne    c0102f52 <default_free_pages+0x237>
            p->property += base->property;
c0102ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ef7:	8b 50 08             	mov    0x8(%eax),%edx
c0102efa:	8b 45 08             	mov    0x8(%ebp),%eax
c0102efd:	8b 40 08             	mov    0x8(%eax),%eax
c0102f00:	01 c2                	add    %eax,%edx
c0102f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f05:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102f08:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f0b:	83 c0 04             	add    $0x4,%eax
c0102f0e:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102f15:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102f18:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102f1b:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102f1e:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f24:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f2a:	83 c0 0c             	add    $0xc,%eax
c0102f2d:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102f30:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102f33:	8b 40 04             	mov    0x4(%eax),%eax
c0102f36:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102f39:	8b 12                	mov    (%edx),%edx
c0102f3b:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102f3e:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102f41:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102f44:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102f47:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102f4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f4d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102f50:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102f52:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102f59:	0f 85 eb fe ff ff    	jne    c0102e4a <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102f5f:	8b 15 78 af 11 c0    	mov    0xc011af78,%edx
c0102f65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102f68:	01 d0                	add    %edx,%eax
c0102f6a:	a3 78 af 11 c0       	mov    %eax,0xc011af78
c0102f6f:	c7 45 9c 70 af 11 c0 	movl   $0xc011af70,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102f76:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f79:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0102f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102f7f:	eb 76                	jmp    c0102ff7 <default_free_pages+0x2dc>
        p = le2page(le, page_link);
c0102f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f84:	83 e8 0c             	sub    $0xc,%eax
c0102f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0102f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f8d:	8b 50 08             	mov    0x8(%eax),%edx
c0102f90:	89 d0                	mov    %edx,%eax
c0102f92:	c1 e0 02             	shl    $0x2,%eax
c0102f95:	01 d0                	add    %edx,%eax
c0102f97:	c1 e0 02             	shl    $0x2,%eax
c0102f9a:	89 c2                	mov    %eax,%edx
c0102f9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f9f:	01 d0                	add    %edx,%eax
c0102fa1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fa4:	77 42                	ja     c0102fe8 <default_free_pages+0x2cd>
            assert(base + base->property != p);
c0102fa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fa9:	8b 50 08             	mov    0x8(%eax),%edx
c0102fac:	89 d0                	mov    %edx,%eax
c0102fae:	c1 e0 02             	shl    $0x2,%eax
c0102fb1:	01 d0                	add    %edx,%eax
c0102fb3:	c1 e0 02             	shl    $0x2,%eax
c0102fb6:	89 c2                	mov    %eax,%edx
c0102fb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fbb:	01 d0                	add    %edx,%eax
c0102fbd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fc0:	75 24                	jne    c0102fe6 <default_free_pages+0x2cb>
c0102fc2:	c7 44 24 0c f9 68 10 	movl   $0xc01068f9,0xc(%esp)
c0102fc9:	c0 
c0102fca:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0102fd1:	c0 
c0102fd2:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0102fd9:	00 
c0102fda:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0102fe1:	e8 06 dd ff ff       	call   c0100cec <__panic>
            break;
c0102fe6:	eb 18                	jmp    c0103000 <default_free_pages+0x2e5>
c0102fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102feb:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102fee:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102ff1:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0102ff4:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0102ff7:	81 7d f0 70 af 11 c0 	cmpl   $0xc011af70,-0x10(%ebp)
c0102ffe:	75 81                	jne    c0102f81 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0103000:	8b 45 08             	mov    0x8(%ebp),%eax
c0103003:	8d 50 0c             	lea    0xc(%eax),%edx
c0103006:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103009:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010300c:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010300f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103012:	8b 00                	mov    (%eax),%eax
c0103014:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103017:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010301a:	89 45 88             	mov    %eax,-0x78(%ebp)
c010301d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103020:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103023:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103026:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103029:	89 10                	mov    %edx,(%eax)
c010302b:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010302e:	8b 10                	mov    (%eax),%edx
c0103030:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103033:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103036:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103039:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010303c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010303f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103042:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103045:	89 10                	mov    %edx,(%eax)
}
c0103047:	c9                   	leave  
c0103048:	c3                   	ret    

c0103049 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103049:	55                   	push   %ebp
c010304a:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010304c:	a1 78 af 11 c0       	mov    0xc011af78,%eax
}
c0103051:	5d                   	pop    %ebp
c0103052:	c3                   	ret    

c0103053 <basic_check>:

static void
basic_check(void) {
c0103053:	55                   	push   %ebp
c0103054:	89 e5                	mov    %esp,%ebp
c0103056:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103059:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103060:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103063:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103066:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103069:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c010306c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103073:	e8 9d 0e 00 00       	call   c0103f15 <alloc_pages>
c0103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010307b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010307f:	75 24                	jne    c01030a5 <basic_check+0x52>
c0103081:	c7 44 24 0c 14 69 10 	movl   $0xc0106914,0xc(%esp)
c0103088:	c0 
c0103089:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103090:	c0 
c0103091:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103098:	00 
c0103099:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01030a0:	e8 47 dc ff ff       	call   c0100cec <__panic>
    assert((p1 = alloc_page()) != NULL);
c01030a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030ac:	e8 64 0e 00 00       	call   c0103f15 <alloc_pages>
c01030b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01030b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01030b8:	75 24                	jne    c01030de <basic_check+0x8b>
c01030ba:	c7 44 24 0c 30 69 10 	movl   $0xc0106930,0xc(%esp)
c01030c1:	c0 
c01030c2:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01030c9:	c0 
c01030ca:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01030d1:	00 
c01030d2:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01030d9:	e8 0e dc ff ff       	call   c0100cec <__panic>
    assert((p2 = alloc_page()) != NULL);
c01030de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030e5:	e8 2b 0e 00 00       	call   c0103f15 <alloc_pages>
c01030ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01030ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030f1:	75 24                	jne    c0103117 <basic_check+0xc4>
c01030f3:	c7 44 24 0c 4c 69 10 	movl   $0xc010694c,0xc(%esp)
c01030fa:	c0 
c01030fb:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103102:	c0 
c0103103:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010310a:	00 
c010310b:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103112:	e8 d5 db ff ff       	call   c0100cec <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103117:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010311a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010311d:	74 10                	je     c010312f <basic_check+0xdc>
c010311f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103122:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103125:	74 08                	je     c010312f <basic_check+0xdc>
c0103127:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010312a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010312d:	75 24                	jne    c0103153 <basic_check+0x100>
c010312f:	c7 44 24 0c 68 69 10 	movl   $0xc0106968,0xc(%esp)
c0103136:	c0 
c0103137:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010313e:	c0 
c010313f:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103146:	00 
c0103147:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010314e:	e8 99 db ff ff       	call   c0100cec <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103153:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103156:	89 04 24             	mov    %eax,(%esp)
c0103159:	e8 a8 f8 ff ff       	call   c0102a06 <page_ref>
c010315e:	85 c0                	test   %eax,%eax
c0103160:	75 1e                	jne    c0103180 <basic_check+0x12d>
c0103162:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103165:	89 04 24             	mov    %eax,(%esp)
c0103168:	e8 99 f8 ff ff       	call   c0102a06 <page_ref>
c010316d:	85 c0                	test   %eax,%eax
c010316f:	75 0f                	jne    c0103180 <basic_check+0x12d>
c0103171:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103174:	89 04 24             	mov    %eax,(%esp)
c0103177:	e8 8a f8 ff ff       	call   c0102a06 <page_ref>
c010317c:	85 c0                	test   %eax,%eax
c010317e:	74 24                	je     c01031a4 <basic_check+0x151>
c0103180:	c7 44 24 0c 8c 69 10 	movl   $0xc010698c,0xc(%esp)
c0103187:	c0 
c0103188:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010318f:	c0 
c0103190:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0103197:	00 
c0103198:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010319f:	e8 48 db ff ff       	call   c0100cec <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01031a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031a7:	89 04 24             	mov    %eax,(%esp)
c01031aa:	e8 41 f8 ff ff       	call   c01029f0 <page2pa>
c01031af:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01031b5:	c1 e2 0c             	shl    $0xc,%edx
c01031b8:	39 d0                	cmp    %edx,%eax
c01031ba:	72 24                	jb     c01031e0 <basic_check+0x18d>
c01031bc:	c7 44 24 0c c8 69 10 	movl   $0xc01069c8,0xc(%esp)
c01031c3:	c0 
c01031c4:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01031cb:	c0 
c01031cc:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01031d3:	00 
c01031d4:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01031db:	e8 0c db ff ff       	call   c0100cec <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01031e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031e3:	89 04 24             	mov    %eax,(%esp)
c01031e6:	e8 05 f8 ff ff       	call   c01029f0 <page2pa>
c01031eb:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01031f1:	c1 e2 0c             	shl    $0xc,%edx
c01031f4:	39 d0                	cmp    %edx,%eax
c01031f6:	72 24                	jb     c010321c <basic_check+0x1c9>
c01031f8:	c7 44 24 0c e5 69 10 	movl   $0xc01069e5,0xc(%esp)
c01031ff:	c0 
c0103200:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103207:	c0 
c0103208:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c010320f:	00 
c0103210:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103217:	e8 d0 da ff ff       	call   c0100cec <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010321c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010321f:	89 04 24             	mov    %eax,(%esp)
c0103222:	e8 c9 f7 ff ff       	call   c01029f0 <page2pa>
c0103227:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010322d:	c1 e2 0c             	shl    $0xc,%edx
c0103230:	39 d0                	cmp    %edx,%eax
c0103232:	72 24                	jb     c0103258 <basic_check+0x205>
c0103234:	c7 44 24 0c 02 6a 10 	movl   $0xc0106a02,0xc(%esp)
c010323b:	c0 
c010323c:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103243:	c0 
c0103244:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010324b:	00 
c010324c:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103253:	e8 94 da ff ff       	call   c0100cec <__panic>

    list_entry_t free_list_store = free_list;
c0103258:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c010325d:	8b 15 74 af 11 c0    	mov    0xc011af74,%edx
c0103263:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103266:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103269:	c7 45 e0 70 af 11 c0 	movl   $0xc011af70,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103270:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103273:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103276:	89 50 04             	mov    %edx,0x4(%eax)
c0103279:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010327c:	8b 50 04             	mov    0x4(%eax),%edx
c010327f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103282:	89 10                	mov    %edx,(%eax)
c0103284:	c7 45 dc 70 af 11 c0 	movl   $0xc011af70,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010328b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010328e:	8b 40 04             	mov    0x4(%eax),%eax
c0103291:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103294:	0f 94 c0             	sete   %al
c0103297:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010329a:	85 c0                	test   %eax,%eax
c010329c:	75 24                	jne    c01032c2 <basic_check+0x26f>
c010329e:	c7 44 24 0c 1f 6a 10 	movl   $0xc0106a1f,0xc(%esp)
c01032a5:	c0 
c01032a6:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01032ad:	c0 
c01032ae:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01032b5:	00 
c01032b6:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01032bd:	e8 2a da ff ff       	call   c0100cec <__panic>

    unsigned int nr_free_store = nr_free;
c01032c2:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c01032c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01032ca:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c01032d1:	00 00 00 

    assert(alloc_page() == NULL);
c01032d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032db:	e8 35 0c 00 00       	call   c0103f15 <alloc_pages>
c01032e0:	85 c0                	test   %eax,%eax
c01032e2:	74 24                	je     c0103308 <basic_check+0x2b5>
c01032e4:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c01032eb:	c0 
c01032ec:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01032f3:	c0 
c01032f4:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01032fb:	00 
c01032fc:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103303:	e8 e4 d9 ff ff       	call   c0100cec <__panic>

    free_page(p0);
c0103308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010330f:	00 
c0103310:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103313:	89 04 24             	mov    %eax,(%esp)
c0103316:	e8 32 0c 00 00       	call   c0103f4d <free_pages>
    free_page(p1);
c010331b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103322:	00 
c0103323:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103326:	89 04 24             	mov    %eax,(%esp)
c0103329:	e8 1f 0c 00 00       	call   c0103f4d <free_pages>
    free_page(p2);
c010332e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103335:	00 
c0103336:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103339:	89 04 24             	mov    %eax,(%esp)
c010333c:	e8 0c 0c 00 00       	call   c0103f4d <free_pages>
    assert(nr_free == 3);
c0103341:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0103346:	83 f8 03             	cmp    $0x3,%eax
c0103349:	74 24                	je     c010336f <basic_check+0x31c>
c010334b:	c7 44 24 0c 4b 6a 10 	movl   $0xc0106a4b,0xc(%esp)
c0103352:	c0 
c0103353:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010335a:	c0 
c010335b:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103362:	00 
c0103363:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010336a:	e8 7d d9 ff ff       	call   c0100cec <__panic>

    assert((p0 = alloc_page()) != NULL);
c010336f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103376:	e8 9a 0b 00 00       	call   c0103f15 <alloc_pages>
c010337b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010337e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103382:	75 24                	jne    c01033a8 <basic_check+0x355>
c0103384:	c7 44 24 0c 14 69 10 	movl   $0xc0106914,0xc(%esp)
c010338b:	c0 
c010338c:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103393:	c0 
c0103394:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010339b:	00 
c010339c:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01033a3:	e8 44 d9 ff ff       	call   c0100cec <__panic>
    assert((p1 = alloc_page()) != NULL);
c01033a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033af:	e8 61 0b 00 00       	call   c0103f15 <alloc_pages>
c01033b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01033bb:	75 24                	jne    c01033e1 <basic_check+0x38e>
c01033bd:	c7 44 24 0c 30 69 10 	movl   $0xc0106930,0xc(%esp)
c01033c4:	c0 
c01033c5:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01033cc:	c0 
c01033cd:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01033d4:	00 
c01033d5:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01033dc:	e8 0b d9 ff ff       	call   c0100cec <__panic>
    assert((p2 = alloc_page()) != NULL);
c01033e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033e8:	e8 28 0b 00 00       	call   c0103f15 <alloc_pages>
c01033ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033f4:	75 24                	jne    c010341a <basic_check+0x3c7>
c01033f6:	c7 44 24 0c 4c 69 10 	movl   $0xc010694c,0xc(%esp)
c01033fd:	c0 
c01033fe:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103405:	c0 
c0103406:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c010340d:	00 
c010340e:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103415:	e8 d2 d8 ff ff       	call   c0100cec <__panic>

    assert(alloc_page() == NULL);
c010341a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103421:	e8 ef 0a 00 00       	call   c0103f15 <alloc_pages>
c0103426:	85 c0                	test   %eax,%eax
c0103428:	74 24                	je     c010344e <basic_check+0x3fb>
c010342a:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c0103431:	c0 
c0103432:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103439:	c0 
c010343a:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103441:	00 
c0103442:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103449:	e8 9e d8 ff ff       	call   c0100cec <__panic>

    free_page(p0);
c010344e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103455:	00 
c0103456:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103459:	89 04 24             	mov    %eax,(%esp)
c010345c:	e8 ec 0a 00 00       	call   c0103f4d <free_pages>
c0103461:	c7 45 d8 70 af 11 c0 	movl   $0xc011af70,-0x28(%ebp)
c0103468:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010346b:	8b 40 04             	mov    0x4(%eax),%eax
c010346e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103471:	0f 94 c0             	sete   %al
c0103474:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103477:	85 c0                	test   %eax,%eax
c0103479:	74 24                	je     c010349f <basic_check+0x44c>
c010347b:	c7 44 24 0c 58 6a 10 	movl   $0xc0106a58,0xc(%esp)
c0103482:	c0 
c0103483:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010348a:	c0 
c010348b:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0103492:	00 
c0103493:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010349a:	e8 4d d8 ff ff       	call   c0100cec <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010349f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034a6:	e8 6a 0a 00 00       	call   c0103f15 <alloc_pages>
c01034ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01034ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01034b4:	74 24                	je     c01034da <basic_check+0x487>
c01034b6:	c7 44 24 0c 70 6a 10 	movl   $0xc0106a70,0xc(%esp)
c01034bd:	c0 
c01034be:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01034c5:	c0 
c01034c6:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01034cd:	00 
c01034ce:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01034d5:	e8 12 d8 ff ff       	call   c0100cec <__panic>
    assert(alloc_page() == NULL);
c01034da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034e1:	e8 2f 0a 00 00       	call   c0103f15 <alloc_pages>
c01034e6:	85 c0                	test   %eax,%eax
c01034e8:	74 24                	je     c010350e <basic_check+0x4bb>
c01034ea:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c01034f1:	c0 
c01034f2:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01034f9:	c0 
c01034fa:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103501:	00 
c0103502:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103509:	e8 de d7 ff ff       	call   c0100cec <__panic>

    assert(nr_free == 0);
c010350e:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0103513:	85 c0                	test   %eax,%eax
c0103515:	74 24                	je     c010353b <basic_check+0x4e8>
c0103517:	c7 44 24 0c 89 6a 10 	movl   $0xc0106a89,0xc(%esp)
c010351e:	c0 
c010351f:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103526:	c0 
c0103527:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010352e:	00 
c010352f:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103536:	e8 b1 d7 ff ff       	call   c0100cec <__panic>
    free_list = free_list_store;
c010353b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010353e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103541:	a3 70 af 11 c0       	mov    %eax,0xc011af70
c0103546:	89 15 74 af 11 c0    	mov    %edx,0xc011af74
    nr_free = nr_free_store;
c010354c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010354f:	a3 78 af 11 c0       	mov    %eax,0xc011af78

    free_page(p);
c0103554:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010355b:	00 
c010355c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010355f:	89 04 24             	mov    %eax,(%esp)
c0103562:	e8 e6 09 00 00       	call   c0103f4d <free_pages>
    free_page(p1);
c0103567:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010356e:	00 
c010356f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103572:	89 04 24             	mov    %eax,(%esp)
c0103575:	e8 d3 09 00 00       	call   c0103f4d <free_pages>
    free_page(p2);
c010357a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103581:	00 
c0103582:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103585:	89 04 24             	mov    %eax,(%esp)
c0103588:	e8 c0 09 00 00       	call   c0103f4d <free_pages>
}
c010358d:	c9                   	leave  
c010358e:	c3                   	ret    

c010358f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010358f:	55                   	push   %ebp
c0103590:	89 e5                	mov    %esp,%ebp
c0103592:	53                   	push   %ebx
c0103593:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01035a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01035a7:	c7 45 ec 70 af 11 c0 	movl   $0xc011af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01035ae:	eb 6b                	jmp    c010361b <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c01035b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035b3:	83 e8 0c             	sub    $0xc,%eax
c01035b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01035b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035bc:	83 c0 04             	add    $0x4,%eax
c01035bf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01035c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01035cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035cf:	0f a3 10             	bt     %edx,(%eax)
c01035d2:	19 c0                	sbb    %eax,%eax
c01035d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01035d7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01035db:	0f 95 c0             	setne  %al
c01035de:	0f b6 c0             	movzbl %al,%eax
c01035e1:	85 c0                	test   %eax,%eax
c01035e3:	75 24                	jne    c0103609 <default_check+0x7a>
c01035e5:	c7 44 24 0c 96 6a 10 	movl   $0xc0106a96,0xc(%esp)
c01035ec:	c0 
c01035ed:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01035f4:	c0 
c01035f5:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01035fc:	00 
c01035fd:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103604:	e8 e3 d6 ff ff       	call   c0100cec <__panic>
        count ++, total += p->property;
c0103609:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010360d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103610:	8b 50 08             	mov    0x8(%eax),%edx
c0103613:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103616:	01 d0                	add    %edx,%eax
c0103618:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010361b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010361e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103621:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103624:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103627:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010362a:	81 7d ec 70 af 11 c0 	cmpl   $0xc011af70,-0x14(%ebp)
c0103631:	0f 85 79 ff ff ff    	jne    c01035b0 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103637:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010363a:	e8 40 09 00 00       	call   c0103f7f <nr_free_pages>
c010363f:	39 c3                	cmp    %eax,%ebx
c0103641:	74 24                	je     c0103667 <default_check+0xd8>
c0103643:	c7 44 24 0c a6 6a 10 	movl   $0xc0106aa6,0xc(%esp)
c010364a:	c0 
c010364b:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103652:	c0 
c0103653:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010365a:	00 
c010365b:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103662:	e8 85 d6 ff ff       	call   c0100cec <__panic>

    basic_check();
c0103667:	e8 e7 f9 ff ff       	call   c0103053 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010366c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103673:	e8 9d 08 00 00       	call   c0103f15 <alloc_pages>
c0103678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010367b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010367f:	75 24                	jne    c01036a5 <default_check+0x116>
c0103681:	c7 44 24 0c bf 6a 10 	movl   $0xc0106abf,0xc(%esp)
c0103688:	c0 
c0103689:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103690:	c0 
c0103691:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103698:	00 
c0103699:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01036a0:	e8 47 d6 ff ff       	call   c0100cec <__panic>
    assert(!PageProperty(p0));
c01036a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036a8:	83 c0 04             	add    $0x4,%eax
c01036ab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01036b2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036b5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01036b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01036bb:	0f a3 10             	bt     %edx,(%eax)
c01036be:	19 c0                	sbb    %eax,%eax
c01036c0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01036c3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01036c7:	0f 95 c0             	setne  %al
c01036ca:	0f b6 c0             	movzbl %al,%eax
c01036cd:	85 c0                	test   %eax,%eax
c01036cf:	74 24                	je     c01036f5 <default_check+0x166>
c01036d1:	c7 44 24 0c ca 6a 10 	movl   $0xc0106aca,0xc(%esp)
c01036d8:	c0 
c01036d9:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01036e0:	c0 
c01036e1:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01036e8:	00 
c01036e9:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01036f0:	e8 f7 d5 ff ff       	call   c0100cec <__panic>

    list_entry_t free_list_store = free_list;
c01036f5:	a1 70 af 11 c0       	mov    0xc011af70,%eax
c01036fa:	8b 15 74 af 11 c0    	mov    0xc011af74,%edx
c0103700:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103703:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103706:	c7 45 b4 70 af 11 c0 	movl   $0xc011af70,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010370d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103710:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103713:	89 50 04             	mov    %edx,0x4(%eax)
c0103716:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103719:	8b 50 04             	mov    0x4(%eax),%edx
c010371c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010371f:	89 10                	mov    %edx,(%eax)
c0103721:	c7 45 b0 70 af 11 c0 	movl   $0xc011af70,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103728:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010372b:	8b 40 04             	mov    0x4(%eax),%eax
c010372e:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103731:	0f 94 c0             	sete   %al
c0103734:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103737:	85 c0                	test   %eax,%eax
c0103739:	75 24                	jne    c010375f <default_check+0x1d0>
c010373b:	c7 44 24 0c 1f 6a 10 	movl   $0xc0106a1f,0xc(%esp)
c0103742:	c0 
c0103743:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010374a:	c0 
c010374b:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103752:	00 
c0103753:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010375a:	e8 8d d5 ff ff       	call   c0100cec <__panic>
    assert(alloc_page() == NULL);
c010375f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103766:	e8 aa 07 00 00       	call   c0103f15 <alloc_pages>
c010376b:	85 c0                	test   %eax,%eax
c010376d:	74 24                	je     c0103793 <default_check+0x204>
c010376f:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c0103776:	c0 
c0103777:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010377e:	c0 
c010377f:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103786:	00 
c0103787:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010378e:	e8 59 d5 ff ff       	call   c0100cec <__panic>

    unsigned int nr_free_store = nr_free;
c0103793:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0103798:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010379b:	c7 05 78 af 11 c0 00 	movl   $0x0,0xc011af78
c01037a2:	00 00 00 

    free_pages(p0 + 2, 3);
c01037a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037a8:	83 c0 28             	add    $0x28,%eax
c01037ab:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01037b2:	00 
c01037b3:	89 04 24             	mov    %eax,(%esp)
c01037b6:	e8 92 07 00 00       	call   c0103f4d <free_pages>
    assert(alloc_pages(4) == NULL);
c01037bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01037c2:	e8 4e 07 00 00       	call   c0103f15 <alloc_pages>
c01037c7:	85 c0                	test   %eax,%eax
c01037c9:	74 24                	je     c01037ef <default_check+0x260>
c01037cb:	c7 44 24 0c dc 6a 10 	movl   $0xc0106adc,0xc(%esp)
c01037d2:	c0 
c01037d3:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01037da:	c0 
c01037db:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01037e2:	00 
c01037e3:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01037ea:	e8 fd d4 ff ff       	call   c0100cec <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01037ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037f2:	83 c0 28             	add    $0x28,%eax
c01037f5:	83 c0 04             	add    $0x4,%eax
c01037f8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01037ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103802:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103805:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103808:	0f a3 10             	bt     %edx,(%eax)
c010380b:	19 c0                	sbb    %eax,%eax
c010380d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103810:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103814:	0f 95 c0             	setne  %al
c0103817:	0f b6 c0             	movzbl %al,%eax
c010381a:	85 c0                	test   %eax,%eax
c010381c:	74 0e                	je     c010382c <default_check+0x29d>
c010381e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103821:	83 c0 28             	add    $0x28,%eax
c0103824:	8b 40 08             	mov    0x8(%eax),%eax
c0103827:	83 f8 03             	cmp    $0x3,%eax
c010382a:	74 24                	je     c0103850 <default_check+0x2c1>
c010382c:	c7 44 24 0c f4 6a 10 	movl   $0xc0106af4,0xc(%esp)
c0103833:	c0 
c0103834:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c010383b:	c0 
c010383c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0103843:	00 
c0103844:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c010384b:	e8 9c d4 ff ff       	call   c0100cec <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0103850:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103857:	e8 b9 06 00 00       	call   c0103f15 <alloc_pages>
c010385c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010385f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103863:	75 24                	jne    c0103889 <default_check+0x2fa>
c0103865:	c7 44 24 0c 20 6b 10 	movl   $0xc0106b20,0xc(%esp)
c010386c:	c0 
c010386d:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103874:	c0 
c0103875:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010387c:	00 
c010387d:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103884:	e8 63 d4 ff ff       	call   c0100cec <__panic>
    assert(alloc_page() == NULL);
c0103889:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103890:	e8 80 06 00 00       	call   c0103f15 <alloc_pages>
c0103895:	85 c0                	test   %eax,%eax
c0103897:	74 24                	je     c01038bd <default_check+0x32e>
c0103899:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c01038a0:	c0 
c01038a1:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01038a8:	c0 
c01038a9:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01038b0:	00 
c01038b1:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01038b8:	e8 2f d4 ff ff       	call   c0100cec <__panic>
    assert(p0 + 2 == p1);
c01038bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038c0:	83 c0 28             	add    $0x28,%eax
c01038c3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01038c6:	74 24                	je     c01038ec <default_check+0x35d>
c01038c8:	c7 44 24 0c 3e 6b 10 	movl   $0xc0106b3e,0xc(%esp)
c01038cf:	c0 
c01038d0:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01038d7:	c0 
c01038d8:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01038df:	00 
c01038e0:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01038e7:	e8 00 d4 ff ff       	call   c0100cec <__panic>

    p2 = p0 + 1;
c01038ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038ef:	83 c0 14             	add    $0x14,%eax
c01038f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01038f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038fc:	00 
c01038fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103900:	89 04 24             	mov    %eax,(%esp)
c0103903:	e8 45 06 00 00       	call   c0103f4d <free_pages>
    free_pages(p1, 3);
c0103908:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010390f:	00 
c0103910:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103913:	89 04 24             	mov    %eax,(%esp)
c0103916:	e8 32 06 00 00       	call   c0103f4d <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010391b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010391e:	83 c0 04             	add    $0x4,%eax
c0103921:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103928:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010392b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010392e:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103931:	0f a3 10             	bt     %edx,(%eax)
c0103934:	19 c0                	sbb    %eax,%eax
c0103936:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103939:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010393d:	0f 95 c0             	setne  %al
c0103940:	0f b6 c0             	movzbl %al,%eax
c0103943:	85 c0                	test   %eax,%eax
c0103945:	74 0b                	je     c0103952 <default_check+0x3c3>
c0103947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010394a:	8b 40 08             	mov    0x8(%eax),%eax
c010394d:	83 f8 01             	cmp    $0x1,%eax
c0103950:	74 24                	je     c0103976 <default_check+0x3e7>
c0103952:	c7 44 24 0c 4c 6b 10 	movl   $0xc0106b4c,0xc(%esp)
c0103959:	c0 
c010395a:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103961:	c0 
c0103962:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0103969:	00 
c010396a:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103971:	e8 76 d3 ff ff       	call   c0100cec <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103976:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103979:	83 c0 04             	add    $0x4,%eax
c010397c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103983:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103986:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103989:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010398c:	0f a3 10             	bt     %edx,(%eax)
c010398f:	19 c0                	sbb    %eax,%eax
c0103991:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103994:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103998:	0f 95 c0             	setne  %al
c010399b:	0f b6 c0             	movzbl %al,%eax
c010399e:	85 c0                	test   %eax,%eax
c01039a0:	74 0b                	je     c01039ad <default_check+0x41e>
c01039a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039a5:	8b 40 08             	mov    0x8(%eax),%eax
c01039a8:	83 f8 03             	cmp    $0x3,%eax
c01039ab:	74 24                	je     c01039d1 <default_check+0x442>
c01039ad:	c7 44 24 0c 74 6b 10 	movl   $0xc0106b74,0xc(%esp)
c01039b4:	c0 
c01039b5:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01039bc:	c0 
c01039bd:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01039c4:	00 
c01039c5:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c01039cc:	e8 1b d3 ff ff       	call   c0100cec <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01039d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039d8:	e8 38 05 00 00       	call   c0103f15 <alloc_pages>
c01039dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01039e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01039e3:	83 e8 14             	sub    $0x14,%eax
c01039e6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01039e9:	74 24                	je     c0103a0f <default_check+0x480>
c01039eb:	c7 44 24 0c 9a 6b 10 	movl   $0xc0106b9a,0xc(%esp)
c01039f2:	c0 
c01039f3:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c01039fa:	c0 
c01039fb:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0103a02:	00 
c0103a03:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103a0a:	e8 dd d2 ff ff       	call   c0100cec <__panic>
    free_page(p0);
c0103a0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a16:	00 
c0103a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a1a:	89 04 24             	mov    %eax,(%esp)
c0103a1d:	e8 2b 05 00 00       	call   c0103f4d <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103a22:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103a29:	e8 e7 04 00 00       	call   c0103f15 <alloc_pages>
c0103a2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a31:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103a34:	83 c0 14             	add    $0x14,%eax
c0103a37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103a3a:	74 24                	je     c0103a60 <default_check+0x4d1>
c0103a3c:	c7 44 24 0c b8 6b 10 	movl   $0xc0106bb8,0xc(%esp)
c0103a43:	c0 
c0103a44:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103a4b:	c0 
c0103a4c:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0103a53:	00 
c0103a54:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103a5b:	e8 8c d2 ff ff       	call   c0100cec <__panic>

    free_pages(p0, 2);
c0103a60:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103a67:	00 
c0103a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a6b:	89 04 24             	mov    %eax,(%esp)
c0103a6e:	e8 da 04 00 00       	call   c0103f4d <free_pages>
    free_page(p2);
c0103a73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a7a:	00 
c0103a7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103a7e:	89 04 24             	mov    %eax,(%esp)
c0103a81:	e8 c7 04 00 00       	call   c0103f4d <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103a86:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103a8d:	e8 83 04 00 00       	call   c0103f15 <alloc_pages>
c0103a92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103a99:	75 24                	jne    c0103abf <default_check+0x530>
c0103a9b:	c7 44 24 0c d8 6b 10 	movl   $0xc0106bd8,0xc(%esp)
c0103aa2:	c0 
c0103aa3:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103aaa:	c0 
c0103aab:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103ab2:	00 
c0103ab3:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103aba:	e8 2d d2 ff ff       	call   c0100cec <__panic>
    assert(alloc_page() == NULL);
c0103abf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ac6:	e8 4a 04 00 00       	call   c0103f15 <alloc_pages>
c0103acb:	85 c0                	test   %eax,%eax
c0103acd:	74 24                	je     c0103af3 <default_check+0x564>
c0103acf:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c0103ad6:	c0 
c0103ad7:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103ade:	c0 
c0103adf:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0103ae6:	00 
c0103ae7:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103aee:	e8 f9 d1 ff ff       	call   c0100cec <__panic>

    assert(nr_free == 0);
c0103af3:	a1 78 af 11 c0       	mov    0xc011af78,%eax
c0103af8:	85 c0                	test   %eax,%eax
c0103afa:	74 24                	je     c0103b20 <default_check+0x591>
c0103afc:	c7 44 24 0c 89 6a 10 	movl   $0xc0106a89,0xc(%esp)
c0103b03:	c0 
c0103b04:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103b0b:	c0 
c0103b0c:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0103b13:	00 
c0103b14:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103b1b:	e8 cc d1 ff ff       	call   c0100cec <__panic>
    nr_free = nr_free_store;
c0103b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b23:	a3 78 af 11 c0       	mov    %eax,0xc011af78

    free_list = free_list_store;
c0103b28:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103b2b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103b2e:	a3 70 af 11 c0       	mov    %eax,0xc011af70
c0103b33:	89 15 74 af 11 c0    	mov    %edx,0xc011af74
    free_pages(p0, 5);
c0103b39:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103b40:	00 
c0103b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b44:	89 04 24             	mov    %eax,(%esp)
c0103b47:	e8 01 04 00 00       	call   c0103f4d <free_pages>

    le = &free_list;
c0103b4c:	c7 45 ec 70 af 11 c0 	movl   $0xc011af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103b53:	eb 1d                	jmp    c0103b72 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0103b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b58:	83 e8 0c             	sub    $0xc,%eax
c0103b5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0103b5e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103b62:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103b65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103b68:	8b 40 08             	mov    0x8(%eax),%eax
c0103b6b:	29 c2                	sub    %eax,%edx
c0103b6d:	89 d0                	mov    %edx,%eax
c0103b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b75:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103b78:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103b7b:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b81:	81 7d ec 70 af 11 c0 	cmpl   $0xc011af70,-0x14(%ebp)
c0103b88:	75 cb                	jne    c0103b55 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103b8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b8e:	74 24                	je     c0103bb4 <default_check+0x625>
c0103b90:	c7 44 24 0c f6 6b 10 	movl   $0xc0106bf6,0xc(%esp)
c0103b97:	c0 
c0103b98:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103b9f:	c0 
c0103ba0:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0103ba7:	00 
c0103ba8:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103baf:	e8 38 d1 ff ff       	call   c0100cec <__panic>
    assert(total == 0);
c0103bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103bb8:	74 24                	je     c0103bde <default_check+0x64f>
c0103bba:	c7 44 24 0c 01 6c 10 	movl   $0xc0106c01,0xc(%esp)
c0103bc1:	c0 
c0103bc2:	c7 44 24 08 96 68 10 	movl   $0xc0106896,0x8(%esp)
c0103bc9:	c0 
c0103bca:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0103bd1:	00 
c0103bd2:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0103bd9:	e8 0e d1 ff ff       	call   c0100cec <__panic>
}
c0103bde:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103be4:	5b                   	pop    %ebx
c0103be5:	5d                   	pop    %ebp
c0103be6:	c3                   	ret    

c0103be7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103be7:	55                   	push   %ebp
c0103be8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103bea:	8b 55 08             	mov    0x8(%ebp),%edx
c0103bed:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c0103bf2:	29 c2                	sub    %eax,%edx
c0103bf4:	89 d0                	mov    %edx,%eax
c0103bf6:	c1 f8 02             	sar    $0x2,%eax
c0103bf9:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103bff:	5d                   	pop    %ebp
c0103c00:	c3                   	ret    

c0103c01 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103c01:	55                   	push   %ebp
c0103c02:	89 e5                	mov    %esp,%ebp
c0103c04:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103c07:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c0a:	89 04 24             	mov    %eax,(%esp)
c0103c0d:	e8 d5 ff ff ff       	call   c0103be7 <page2ppn>
c0103c12:	c1 e0 0c             	shl    $0xc,%eax
}
c0103c15:	c9                   	leave  
c0103c16:	c3                   	ret    

c0103c17 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103c17:	55                   	push   %ebp
c0103c18:	89 e5                	mov    %esp,%ebp
c0103c1a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c20:	c1 e8 0c             	shr    $0xc,%eax
c0103c23:	89 c2                	mov    %eax,%edx
c0103c25:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103c2a:	39 c2                	cmp    %eax,%edx
c0103c2c:	72 1c                	jb     c0103c4a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103c2e:	c7 44 24 08 3c 6c 10 	movl   $0xc0106c3c,0x8(%esp)
c0103c35:	c0 
c0103c36:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103c3d:	00 
c0103c3e:	c7 04 24 5b 6c 10 c0 	movl   $0xc0106c5b,(%esp)
c0103c45:	e8 a2 d0 ff ff       	call   c0100cec <__panic>
    }
    return &pages[PPN(pa)];
c0103c4a:	8b 0d 84 af 11 c0    	mov    0xc011af84,%ecx
c0103c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c53:	c1 e8 0c             	shr    $0xc,%eax
c0103c56:	89 c2                	mov    %eax,%edx
c0103c58:	89 d0                	mov    %edx,%eax
c0103c5a:	c1 e0 02             	shl    $0x2,%eax
c0103c5d:	01 d0                	add    %edx,%eax
c0103c5f:	c1 e0 02             	shl    $0x2,%eax
c0103c62:	01 c8                	add    %ecx,%eax
}
c0103c64:	c9                   	leave  
c0103c65:	c3                   	ret    

c0103c66 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103c66:	55                   	push   %ebp
c0103c67:	89 e5                	mov    %esp,%ebp
c0103c69:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103c6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c6f:	89 04 24             	mov    %eax,(%esp)
c0103c72:	e8 8a ff ff ff       	call   c0103c01 <page2pa>
c0103c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c7d:	c1 e8 0c             	shr    $0xc,%eax
c0103c80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c83:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103c88:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103c8b:	72 23                	jb     c0103cb0 <page2kva+0x4a>
c0103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c90:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c94:	c7 44 24 08 6c 6c 10 	movl   $0xc0106c6c,0x8(%esp)
c0103c9b:	c0 
c0103c9c:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103ca3:	00 
c0103ca4:	c7 04 24 5b 6c 10 c0 	movl   $0xc0106c5b,(%esp)
c0103cab:	e8 3c d0 ff ff       	call   c0100cec <__panic>
c0103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cb3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103cb8:	c9                   	leave  
c0103cb9:	c3                   	ret    

c0103cba <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103cba:	55                   	push   %ebp
c0103cbb:	89 e5                	mov    %esp,%ebp
c0103cbd:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103cc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc3:	83 e0 01             	and    $0x1,%eax
c0103cc6:	85 c0                	test   %eax,%eax
c0103cc8:	75 1c                	jne    c0103ce6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103cca:	c7 44 24 08 90 6c 10 	movl   $0xc0106c90,0x8(%esp)
c0103cd1:	c0 
c0103cd2:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103cd9:	00 
c0103cda:	c7 04 24 5b 6c 10 c0 	movl   $0xc0106c5b,(%esp)
c0103ce1:	e8 06 d0 ff ff       	call   c0100cec <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ce9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cee:	89 04 24             	mov    %eax,(%esp)
c0103cf1:	e8 21 ff ff ff       	call   c0103c17 <pa2page>
}
c0103cf6:	c9                   	leave  
c0103cf7:	c3                   	ret    

c0103cf8 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103cf8:	55                   	push   %ebp
c0103cf9:	89 e5                	mov    %esp,%ebp
c0103cfb:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d06:	89 04 24             	mov    %eax,(%esp)
c0103d09:	e8 09 ff ff ff       	call   c0103c17 <pa2page>
}
c0103d0e:	c9                   	leave  
c0103d0f:	c3                   	ret    

c0103d10 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103d10:	55                   	push   %ebp
c0103d11:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d16:	8b 00                	mov    (%eax),%eax
}
c0103d18:	5d                   	pop    %ebp
c0103d19:	c3                   	ret    

c0103d1a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103d1a:	55                   	push   %ebp
c0103d1b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103d1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d20:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d23:	89 10                	mov    %edx,(%eax)
}
c0103d25:	5d                   	pop    %ebp
c0103d26:	c3                   	ret    

c0103d27 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103d27:	55                   	push   %ebp
c0103d28:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103d2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d2d:	8b 00                	mov    (%eax),%eax
c0103d2f:	8d 50 01             	lea    0x1(%eax),%edx
c0103d32:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d35:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d3a:	8b 00                	mov    (%eax),%eax
}
c0103d3c:	5d                   	pop    %ebp
c0103d3d:	c3                   	ret    

c0103d3e <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103d3e:	55                   	push   %ebp
c0103d3f:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103d41:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d44:	8b 00                	mov    (%eax),%eax
c0103d46:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103d49:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d4c:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d51:	8b 00                	mov    (%eax),%eax
}
c0103d53:	5d                   	pop    %ebp
c0103d54:	c3                   	ret    

c0103d55 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103d55:	55                   	push   %ebp
c0103d56:	89 e5                	mov    %esp,%ebp
c0103d58:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103d5b:	9c                   	pushf  
c0103d5c:	58                   	pop    %eax
c0103d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103d63:	25 00 02 00 00       	and    $0x200,%eax
c0103d68:	85 c0                	test   %eax,%eax
c0103d6a:	74 0c                	je     c0103d78 <__intr_save+0x23>
        intr_disable();
c0103d6c:	e8 6f d9 ff ff       	call   c01016e0 <intr_disable>
        return 1;
c0103d71:	b8 01 00 00 00       	mov    $0x1,%eax
c0103d76:	eb 05                	jmp    c0103d7d <__intr_save+0x28>
    }
    return 0;
c0103d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d7d:	c9                   	leave  
c0103d7e:	c3                   	ret    

c0103d7f <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103d7f:	55                   	push   %ebp
c0103d80:	89 e5                	mov    %esp,%ebp
c0103d82:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103d85:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103d89:	74 05                	je     c0103d90 <__intr_restore+0x11>
        intr_enable();
c0103d8b:	e8 4a d9 ff ff       	call   c01016da <intr_enable>
    }
}
c0103d90:	c9                   	leave  
c0103d91:	c3                   	ret    

c0103d92 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103d92:	55                   	push   %ebp
c0103d93:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103d95:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d98:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103d9b:	b8 23 00 00 00       	mov    $0x23,%eax
c0103da0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103da2:	b8 23 00 00 00       	mov    $0x23,%eax
c0103da7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103da9:	b8 10 00 00 00       	mov    $0x10,%eax
c0103dae:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103db0:	b8 10 00 00 00       	mov    $0x10,%eax
c0103db5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103db7:	b8 10 00 00 00       	mov    $0x10,%eax
c0103dbc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103dbe:	ea c5 3d 10 c0 08 00 	ljmp   $0x8,$0xc0103dc5
}
c0103dc5:	5d                   	pop    %ebp
c0103dc6:	c3                   	ret    

c0103dc7 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103dc7:	55                   	push   %ebp
c0103dc8:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dcd:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103dd2:	5d                   	pop    %ebp
c0103dd3:	c3                   	ret    

c0103dd4 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103dd4:	55                   	push   %ebp
c0103dd5:	89 e5                	mov    %esp,%ebp
c0103dd7:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103dda:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103ddf:	89 04 24             	mov    %eax,(%esp)
c0103de2:	e8 e0 ff ff ff       	call   c0103dc7 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103de7:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103dee:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103df0:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103df7:	68 00 
c0103df9:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103dfe:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103e04:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103e09:	c1 e8 10             	shr    $0x10,%eax
c0103e0c:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103e11:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103e18:	83 e0 f0             	and    $0xfffffff0,%eax
c0103e1b:	83 c8 09             	or     $0x9,%eax
c0103e1e:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103e23:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103e2a:	83 e0 ef             	and    $0xffffffef,%eax
c0103e2d:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103e32:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103e39:	83 e0 9f             	and    $0xffffff9f,%eax
c0103e3c:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103e41:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103e48:	83 c8 80             	or     $0xffffff80,%eax
c0103e4b:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103e50:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103e57:	83 e0 f0             	and    $0xfffffff0,%eax
c0103e5a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103e5f:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103e66:	83 e0 ef             	and    $0xffffffef,%eax
c0103e69:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103e6e:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103e75:	83 e0 df             	and    $0xffffffdf,%eax
c0103e78:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103e7d:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103e84:	83 c8 40             	or     $0x40,%eax
c0103e87:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103e8c:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103e93:	83 e0 7f             	and    $0x7f,%eax
c0103e96:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103e9b:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103ea0:	c1 e8 18             	shr    $0x18,%eax
c0103ea3:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103ea8:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103eaf:	e8 de fe ff ff       	call   c0103d92 <lgdt>
c0103eb4:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103eba:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103ebe:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103ec1:	c9                   	leave  
c0103ec2:	c3                   	ret    

c0103ec3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103ec3:	55                   	push   %ebp
c0103ec4:	89 e5                	mov    %esp,%ebp
c0103ec6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103ec9:	c7 05 7c af 11 c0 20 	movl   $0xc0106c20,0xc011af7c
c0103ed0:	6c 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103ed3:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103ed8:	8b 00                	mov    (%eax),%eax
c0103eda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ede:	c7 04 24 bc 6c 10 c0 	movl   $0xc0106cbc,(%esp)
c0103ee5:	e8 6e c4 ff ff       	call   c0100358 <cprintf>
    pmm_manager->init();
c0103eea:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103eef:	8b 40 04             	mov    0x4(%eax),%eax
c0103ef2:	ff d0                	call   *%eax
}
c0103ef4:	c9                   	leave  
c0103ef5:	c3                   	ret    

c0103ef6 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103ef6:	55                   	push   %ebp
c0103ef7:	89 e5                	mov    %esp,%ebp
c0103ef9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103efc:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103f01:	8b 40 08             	mov    0x8(%eax),%eax
c0103f04:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103f07:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f0b:	8b 55 08             	mov    0x8(%ebp),%edx
c0103f0e:	89 14 24             	mov    %edx,(%esp)
c0103f11:	ff d0                	call   *%eax
}
c0103f13:	c9                   	leave  
c0103f14:	c3                   	ret    

c0103f15 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103f15:	55                   	push   %ebp
c0103f16:	89 e5                	mov    %esp,%ebp
c0103f18:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103f1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103f22:	e8 2e fe ff ff       	call   c0103d55 <__intr_save>
c0103f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103f2a:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103f2f:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f32:	8b 55 08             	mov    0x8(%ebp),%edx
c0103f35:	89 14 24             	mov    %edx,(%esp)
c0103f38:	ff d0                	call   *%eax
c0103f3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f40:	89 04 24             	mov    %eax,(%esp)
c0103f43:	e8 37 fe ff ff       	call   c0103d7f <__intr_restore>
    return page;
c0103f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103f4b:	c9                   	leave  
c0103f4c:	c3                   	ret    

c0103f4d <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103f4d:	55                   	push   %ebp
c0103f4e:	89 e5                	mov    %esp,%ebp
c0103f50:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103f53:	e8 fd fd ff ff       	call   c0103d55 <__intr_save>
c0103f58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103f5b:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103f60:	8b 40 10             	mov    0x10(%eax),%eax
c0103f63:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103f66:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f6a:	8b 55 08             	mov    0x8(%ebp),%edx
c0103f6d:	89 14 24             	mov    %edx,(%esp)
c0103f70:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f75:	89 04 24             	mov    %eax,(%esp)
c0103f78:	e8 02 fe ff ff       	call   c0103d7f <__intr_restore>
}
c0103f7d:	c9                   	leave  
c0103f7e:	c3                   	ret    

c0103f7f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103f7f:	55                   	push   %ebp
c0103f80:	89 e5                	mov    %esp,%ebp
c0103f82:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103f85:	e8 cb fd ff ff       	call   c0103d55 <__intr_save>
c0103f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103f8d:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c0103f92:	8b 40 14             	mov    0x14(%eax),%eax
c0103f95:	ff d0                	call   *%eax
c0103f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f9d:	89 04 24             	mov    %eax,(%esp)
c0103fa0:	e8 da fd ff ff       	call   c0103d7f <__intr_restore>
    return ret;
c0103fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103fa8:	c9                   	leave  
c0103fa9:	c3                   	ret    

c0103faa <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103faa:	55                   	push   %ebp
c0103fab:	89 e5                	mov    %esp,%ebp
c0103fad:	57                   	push   %edi
c0103fae:	56                   	push   %esi
c0103faf:	53                   	push   %ebx
c0103fb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103fb6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103fbd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103fc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103fcb:	c7 04 24 d3 6c 10 c0 	movl   $0xc0106cd3,(%esp)
c0103fd2:	e8 81 c3 ff ff       	call   c0100358 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103fd7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103fde:	e9 15 01 00 00       	jmp    c01040f8 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103fe3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fe6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fe9:	89 d0                	mov    %edx,%eax
c0103feb:	c1 e0 02             	shl    $0x2,%eax
c0103fee:	01 d0                	add    %edx,%eax
c0103ff0:	c1 e0 02             	shl    $0x2,%eax
c0103ff3:	01 c8                	add    %ecx,%eax
c0103ff5:	8b 50 08             	mov    0x8(%eax),%edx
c0103ff8:	8b 40 04             	mov    0x4(%eax),%eax
c0103ffb:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103ffe:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0104001:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104004:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104007:	89 d0                	mov    %edx,%eax
c0104009:	c1 e0 02             	shl    $0x2,%eax
c010400c:	01 d0                	add    %edx,%eax
c010400e:	c1 e0 02             	shl    $0x2,%eax
c0104011:	01 c8                	add    %ecx,%eax
c0104013:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104016:	8b 58 10             	mov    0x10(%eax),%ebx
c0104019:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010401c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010401f:	01 c8                	add    %ecx,%eax
c0104021:	11 da                	adc    %ebx,%edx
c0104023:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0104026:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104029:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010402c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010402f:	89 d0                	mov    %edx,%eax
c0104031:	c1 e0 02             	shl    $0x2,%eax
c0104034:	01 d0                	add    %edx,%eax
c0104036:	c1 e0 02             	shl    $0x2,%eax
c0104039:	01 c8                	add    %ecx,%eax
c010403b:	83 c0 14             	add    $0x14,%eax
c010403e:	8b 00                	mov    (%eax),%eax
c0104040:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104046:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104049:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010404c:	83 c0 ff             	add    $0xffffffff,%eax
c010404f:	83 d2 ff             	adc    $0xffffffff,%edx
c0104052:	89 c6                	mov    %eax,%esi
c0104054:	89 d7                	mov    %edx,%edi
c0104056:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104059:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010405c:	89 d0                	mov    %edx,%eax
c010405e:	c1 e0 02             	shl    $0x2,%eax
c0104061:	01 d0                	add    %edx,%eax
c0104063:	c1 e0 02             	shl    $0x2,%eax
c0104066:	01 c8                	add    %ecx,%eax
c0104068:	8b 48 0c             	mov    0xc(%eax),%ecx
c010406b:	8b 58 10             	mov    0x10(%eax),%ebx
c010406e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104074:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104078:	89 74 24 14          	mov    %esi,0x14(%esp)
c010407c:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104080:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104083:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104086:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010408a:	89 54 24 10          	mov    %edx,0x10(%esp)
c010408e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104092:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104096:	c7 04 24 e0 6c 10 c0 	movl   $0xc0106ce0,(%esp)
c010409d:	e8 b6 c2 ff ff       	call   c0100358 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01040a2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040a8:	89 d0                	mov    %edx,%eax
c01040aa:	c1 e0 02             	shl    $0x2,%eax
c01040ad:	01 d0                	add    %edx,%eax
c01040af:	c1 e0 02             	shl    $0x2,%eax
c01040b2:	01 c8                	add    %ecx,%eax
c01040b4:	83 c0 14             	add    $0x14,%eax
c01040b7:	8b 00                	mov    (%eax),%eax
c01040b9:	83 f8 01             	cmp    $0x1,%eax
c01040bc:	75 36                	jne    c01040f4 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c01040be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01040c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01040c4:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01040c7:	77 2b                	ja     c01040f4 <page_init+0x14a>
c01040c9:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01040cc:	72 05                	jb     c01040d3 <page_init+0x129>
c01040ce:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c01040d1:	73 21                	jae    c01040f4 <page_init+0x14a>
c01040d3:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01040d7:	77 1b                	ja     c01040f4 <page_init+0x14a>
c01040d9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01040dd:	72 09                	jb     c01040e8 <page_init+0x13e>
c01040df:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c01040e6:	77 0c                	ja     c01040f4 <page_init+0x14a>
                maxpa = end;
c01040e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040eb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01040ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01040f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01040f4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01040f8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01040fb:	8b 00                	mov    (%eax),%eax
c01040fd:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104100:	0f 8f dd fe ff ff    	jg     c0103fe3 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010410a:	72 1d                	jb     c0104129 <page_init+0x17f>
c010410c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104110:	77 09                	ja     c010411b <page_init+0x171>
c0104112:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0104119:	76 0e                	jbe    c0104129 <page_init+0x17f>
        maxpa = KMEMSIZE;
c010411b:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104122:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104129:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010412c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010412f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104133:	c1 ea 0c             	shr    $0xc,%edx
c0104136:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010413b:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0104142:	b8 88 af 11 c0       	mov    $0xc011af88,%eax
c0104147:	8d 50 ff             	lea    -0x1(%eax),%edx
c010414a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010414d:	01 d0                	add    %edx,%eax
c010414f:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104152:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104155:	ba 00 00 00 00       	mov    $0x0,%edx
c010415a:	f7 75 ac             	divl   -0x54(%ebp)
c010415d:	89 d0                	mov    %edx,%eax
c010415f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104162:	29 c2                	sub    %eax,%edx
c0104164:	89 d0                	mov    %edx,%eax
c0104166:	a3 84 af 11 c0       	mov    %eax,0xc011af84

    for (i = 0; i < npage; i ++) {
c010416b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104172:	eb 2f                	jmp    c01041a3 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0104174:	8b 0d 84 af 11 c0    	mov    0xc011af84,%ecx
c010417a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010417d:	89 d0                	mov    %edx,%eax
c010417f:	c1 e0 02             	shl    $0x2,%eax
c0104182:	01 d0                	add    %edx,%eax
c0104184:	c1 e0 02             	shl    $0x2,%eax
c0104187:	01 c8                	add    %ecx,%eax
c0104189:	83 c0 04             	add    $0x4,%eax
c010418c:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104193:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104196:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104199:	8b 55 90             	mov    -0x70(%ebp),%edx
c010419c:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c010419f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01041a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041a6:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01041ab:	39 c2                	cmp    %eax,%edx
c01041ad:	72 c5                	jb     c0104174 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01041af:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01041b5:	89 d0                	mov    %edx,%eax
c01041b7:	c1 e0 02             	shl    $0x2,%eax
c01041ba:	01 d0                	add    %edx,%eax
c01041bc:	c1 e0 02             	shl    $0x2,%eax
c01041bf:	89 c2                	mov    %eax,%edx
c01041c1:	a1 84 af 11 c0       	mov    0xc011af84,%eax
c01041c6:	01 d0                	add    %edx,%eax
c01041c8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01041cb:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01041d2:	77 23                	ja     c01041f7 <page_init+0x24d>
c01041d4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01041d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01041db:	c7 44 24 08 10 6d 10 	movl   $0xc0106d10,0x8(%esp)
c01041e2:	c0 
c01041e3:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01041ea:	00 
c01041eb:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01041f2:	e8 f5 ca ff ff       	call   c0100cec <__panic>
c01041f7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01041fa:	05 00 00 00 40       	add    $0x40000000,%eax
c01041ff:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104202:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104209:	e9 74 01 00 00       	jmp    c0104382 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010420e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104211:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104214:	89 d0                	mov    %edx,%eax
c0104216:	c1 e0 02             	shl    $0x2,%eax
c0104219:	01 d0                	add    %edx,%eax
c010421b:	c1 e0 02             	shl    $0x2,%eax
c010421e:	01 c8                	add    %ecx,%eax
c0104220:	8b 50 08             	mov    0x8(%eax),%edx
c0104223:	8b 40 04             	mov    0x4(%eax),%eax
c0104226:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104229:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010422c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010422f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104232:	89 d0                	mov    %edx,%eax
c0104234:	c1 e0 02             	shl    $0x2,%eax
c0104237:	01 d0                	add    %edx,%eax
c0104239:	c1 e0 02             	shl    $0x2,%eax
c010423c:	01 c8                	add    %ecx,%eax
c010423e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104241:	8b 58 10             	mov    0x10(%eax),%ebx
c0104244:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104247:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010424a:	01 c8                	add    %ecx,%eax
c010424c:	11 da                	adc    %ebx,%edx
c010424e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104251:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104254:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104257:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010425a:	89 d0                	mov    %edx,%eax
c010425c:	c1 e0 02             	shl    $0x2,%eax
c010425f:	01 d0                	add    %edx,%eax
c0104261:	c1 e0 02             	shl    $0x2,%eax
c0104264:	01 c8                	add    %ecx,%eax
c0104266:	83 c0 14             	add    $0x14,%eax
c0104269:	8b 00                	mov    (%eax),%eax
c010426b:	83 f8 01             	cmp    $0x1,%eax
c010426e:	0f 85 0a 01 00 00    	jne    c010437e <page_init+0x3d4>
            if (begin < freemem) {
c0104274:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104277:	ba 00 00 00 00       	mov    $0x0,%edx
c010427c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010427f:	72 17                	jb     c0104298 <page_init+0x2ee>
c0104281:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104284:	77 05                	ja     c010428b <page_init+0x2e1>
c0104286:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104289:	76 0d                	jbe    c0104298 <page_init+0x2ee>
                begin = freemem;
c010428b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010428e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104291:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104298:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010429c:	72 1d                	jb     c01042bb <page_init+0x311>
c010429e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01042a2:	77 09                	ja     c01042ad <page_init+0x303>
c01042a4:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01042ab:	76 0e                	jbe    c01042bb <page_init+0x311>
                end = KMEMSIZE;
c01042ad:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01042b4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01042bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01042be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01042c1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01042c4:	0f 87 b4 00 00 00    	ja     c010437e <page_init+0x3d4>
c01042ca:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01042cd:	72 09                	jb     c01042d8 <page_init+0x32e>
c01042cf:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01042d2:	0f 83 a6 00 00 00    	jae    c010437e <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c01042d8:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01042df:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01042e2:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01042e5:	01 d0                	add    %edx,%eax
c01042e7:	83 e8 01             	sub    $0x1,%eax
c01042ea:	89 45 98             	mov    %eax,-0x68(%ebp)
c01042ed:	8b 45 98             	mov    -0x68(%ebp),%eax
c01042f0:	ba 00 00 00 00       	mov    $0x0,%edx
c01042f5:	f7 75 9c             	divl   -0x64(%ebp)
c01042f8:	89 d0                	mov    %edx,%eax
c01042fa:	8b 55 98             	mov    -0x68(%ebp),%edx
c01042fd:	29 c2                	sub    %eax,%edx
c01042ff:	89 d0                	mov    %edx,%eax
c0104301:	ba 00 00 00 00       	mov    $0x0,%edx
c0104306:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104309:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010430c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010430f:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104312:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104315:	ba 00 00 00 00       	mov    $0x0,%edx
c010431a:	89 c7                	mov    %eax,%edi
c010431c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104322:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104325:	89 d0                	mov    %edx,%eax
c0104327:	83 e0 00             	and    $0x0,%eax
c010432a:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010432d:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104330:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104333:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104336:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104339:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010433c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010433f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104342:	77 3a                	ja     c010437e <page_init+0x3d4>
c0104344:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104347:	72 05                	jb     c010434e <page_init+0x3a4>
c0104349:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010434c:	73 30                	jae    c010437e <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010434e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104351:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104354:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104357:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010435a:	29 c8                	sub    %ecx,%eax
c010435c:	19 da                	sbb    %ebx,%edx
c010435e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104362:	c1 ea 0c             	shr    $0xc,%edx
c0104365:	89 c3                	mov    %eax,%ebx
c0104367:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010436a:	89 04 24             	mov    %eax,(%esp)
c010436d:	e8 a5 f8 ff ff       	call   c0103c17 <pa2page>
c0104372:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104376:	89 04 24             	mov    %eax,(%esp)
c0104379:	e8 78 fb ff ff       	call   c0103ef6 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010437e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104382:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104385:	8b 00                	mov    (%eax),%eax
c0104387:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010438a:	0f 8f 7e fe ff ff    	jg     c010420e <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104390:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104396:	5b                   	pop    %ebx
c0104397:	5e                   	pop    %esi
c0104398:	5f                   	pop    %edi
c0104399:	5d                   	pop    %ebp
c010439a:	c3                   	ret    

c010439b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010439b:	55                   	push   %ebp
c010439c:	89 e5                	mov    %esp,%ebp
c010439e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01043a1:	8b 45 14             	mov    0x14(%ebp),%eax
c01043a4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01043a7:	31 d0                	xor    %edx,%eax
c01043a9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01043ae:	85 c0                	test   %eax,%eax
c01043b0:	74 24                	je     c01043d6 <boot_map_segment+0x3b>
c01043b2:	c7 44 24 0c 42 6d 10 	movl   $0xc0106d42,0xc(%esp)
c01043b9:	c0 
c01043ba:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01043c1:	c0 
c01043c2:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01043c9:	00 
c01043ca:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01043d1:	e8 16 c9 ff ff       	call   c0100cec <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01043d6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01043dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01043e0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01043e5:	89 c2                	mov    %eax,%edx
c01043e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01043ea:	01 c2                	add    %eax,%edx
c01043ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043ef:	01 d0                	add    %edx,%eax
c01043f1:	83 e8 01             	sub    $0x1,%eax
c01043f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01043f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01043ff:	f7 75 f0             	divl   -0x10(%ebp)
c0104402:	89 d0                	mov    %edx,%eax
c0104404:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104407:	29 c2                	sub    %eax,%edx
c0104409:	89 d0                	mov    %edx,%eax
c010440b:	c1 e8 0c             	shr    $0xc,%eax
c010440e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104411:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104414:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104417:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010441a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010441f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104422:	8b 45 14             	mov    0x14(%ebp),%eax
c0104425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010442b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104430:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104433:	eb 6b                	jmp    c01044a0 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104435:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010443c:	00 
c010443d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104440:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104444:	8b 45 08             	mov    0x8(%ebp),%eax
c0104447:	89 04 24             	mov    %eax,(%esp)
c010444a:	e8 82 01 00 00       	call   c01045d1 <get_pte>
c010444f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104456:	75 24                	jne    c010447c <boot_map_segment+0xe1>
c0104458:	c7 44 24 0c 6e 6d 10 	movl   $0xc0106d6e,0xc(%esp)
c010445f:	c0 
c0104460:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104467:	c0 
c0104468:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010446f:	00 
c0104470:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104477:	e8 70 c8 ff ff       	call   c0100cec <__panic>
        *ptep = pa | PTE_P | perm;
c010447c:	8b 45 18             	mov    0x18(%ebp),%eax
c010447f:	8b 55 14             	mov    0x14(%ebp),%edx
c0104482:	09 d0                	or     %edx,%eax
c0104484:	83 c8 01             	or     $0x1,%eax
c0104487:	89 c2                	mov    %eax,%edx
c0104489:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010448c:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010448e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104492:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104499:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01044a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044a4:	75 8f                	jne    c0104435 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01044a6:	c9                   	leave  
c01044a7:	c3                   	ret    

c01044a8 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01044a8:	55                   	push   %ebp
c01044a9:	89 e5                	mov    %esp,%ebp
c01044ab:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01044ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044b5:	e8 5b fa ff ff       	call   c0103f15 <alloc_pages>
c01044ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01044bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044c1:	75 1c                	jne    c01044df <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01044c3:	c7 44 24 08 7b 6d 10 	movl   $0xc0106d7b,0x8(%esp)
c01044ca:	c0 
c01044cb:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01044d2:	00 
c01044d3:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01044da:	e8 0d c8 ff ff       	call   c0100cec <__panic>
    }
    return page2kva(p);
c01044df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044e2:	89 04 24             	mov    %eax,(%esp)
c01044e5:	e8 7c f7 ff ff       	call   c0103c66 <page2kva>
}
c01044ea:	c9                   	leave  
c01044eb:	c3                   	ret    

c01044ec <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01044ec:	55                   	push   %ebp
c01044ed:	89 e5                	mov    %esp,%ebp
c01044ef:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01044f2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01044f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01044fa:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104501:	77 23                	ja     c0104526 <pmm_init+0x3a>
c0104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104506:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010450a:	c7 44 24 08 10 6d 10 	movl   $0xc0106d10,0x8(%esp)
c0104511:	c0 
c0104512:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104519:	00 
c010451a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104521:	e8 c6 c7 ff ff       	call   c0100cec <__panic>
c0104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104529:	05 00 00 00 40       	add    $0x40000000,%eax
c010452e:	a3 80 af 11 c0       	mov    %eax,0xc011af80
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104533:	e8 8b f9 ff ff       	call   c0103ec3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104538:	e8 6d fa ff ff       	call   c0103faa <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010453d:	e8 fd 03 00 00       	call   c010493f <check_alloc_page>

    check_pgdir();
c0104542:	e8 16 04 00 00       	call   c010495d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104547:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010454c:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104552:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104557:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010455a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104561:	77 23                	ja     c0104586 <pmm_init+0x9a>
c0104563:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104566:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010456a:	c7 44 24 08 10 6d 10 	movl   $0xc0106d10,0x8(%esp)
c0104571:	c0 
c0104572:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104579:	00 
c010457a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104581:	e8 66 c7 ff ff       	call   c0100cec <__panic>
c0104586:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104589:	05 00 00 00 40       	add    $0x40000000,%eax
c010458e:	83 c8 03             	or     $0x3,%eax
c0104591:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104593:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104598:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010459f:	00 
c01045a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01045a7:	00 
c01045a8:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01045af:	38 
c01045b0:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01045b7:	c0 
c01045b8:	89 04 24             	mov    %eax,(%esp)
c01045bb:	e8 db fd ff ff       	call   c010439b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01045c0:	e8 0f f8 ff ff       	call   c0103dd4 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01045c5:	e8 2e 0a 00 00       	call   c0104ff8 <check_boot_pgdir>

    print_pgdir();
c01045ca:	e8 b6 0e 00 00       	call   c0105485 <print_pgdir>

}
c01045cf:	c9                   	leave  
c01045d0:	c3                   	ret    

c01045d1 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01045d1:	55                   	push   %ebp
c01045d2:	89 e5                	mov    %esp,%ebp
c01045d4:	83 ec 48             	sub    $0x48,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
   pde_t *pdep = NULL;
c01045d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    uintptr_t pde = PDX(la);
c01045de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045e1:	c1 e8 16             	shr    $0x16,%eax
c01045e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    pdep = &pgdir[pde];
c01045e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01045f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f4:	01 d0                	add    %edx,%eax
c01045f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 非present也就是不存在这样的page（缺页），需要分配页
    if (!(*pdep & PTE_P)) {
c01045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045fc:	8b 00                	mov    (%eax),%eax
c01045fe:	83 e0 01             	and    $0x1,%eax
c0104601:	85 c0                	test   %eax,%eax
c0104603:	0f 85 af 00 00 00    	jne    c01046b8 <get_pte+0xe7>
        struct Page *p;
        // 如果不需要分配或者分配的页为NULL
        if (!create || (p = alloc_page()) == NULL) {
c0104609:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010460d:	74 15                	je     c0104624 <get_pte+0x53>
c010460f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104616:	e8 fa f8 ff ff       	call   c0103f15 <alloc_pages>
c010461b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010461e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104622:	75 0a                	jne    c010462e <get_pte+0x5d>
            return NULL;
c0104624:	b8 00 00 00 00       	mov    $0x0,%eax
c0104629:	e9 fb 00 00 00       	jmp    c0104729 <get_pte+0x158>
        }
        set_page_ref(p, 1);
c010462e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104635:	00 
c0104636:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104639:	89 04 24             	mov    %eax,(%esp)
c010463c:	e8 d9 f6 ff ff       	call   c0103d1a <set_page_ref>
        // page table的索引值（PTE)
        uintptr_t pti = page2pa(p);
c0104641:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104644:	89 04 24             	mov    %eax,(%esp)
c0104647:	e8 b5 f5 ff ff       	call   c0103c01 <page2pa>
c010464c:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // KADDR: takes a physical address and returns the corresponding kernel virtual address.
        memset(KADDR(pti), 0, sizeof(struct Page));
c010464f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104652:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104658:	c1 e8 0c             	shr    $0xc,%eax
c010465b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010465e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104663:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104666:	72 23                	jb     c010468b <get_pte+0xba>
c0104668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010466b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010466f:	c7 44 24 08 6c 6c 10 	movl   $0xc0106c6c,0x8(%esp)
c0104676:	c0 
c0104677:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c010467e:	00 
c010467f:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104686:	e8 61 c6 ff ff       	call   c0100cec <__panic>
c010468b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010468e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104693:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
c010469a:	00 
c010469b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01046a2:	00 
c01046a3:	89 04 24             	mov    %eax,(%esp)
c01046a6:	e8 f8 18 00 00       	call   c0105fa3 <memset>

        // 相当于把物理地址给了pdep
        // pdep: page directory entry point
        *pdep = pti | PTE_P | PTE_W | PTE_U;
c01046ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046ae:	83 c8 07             	or     $0x7,%eax
c01046b1:	89 c2                	mov    %eax,%edx
c01046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b6:	89 10                	mov    %edx,(%eax)
    // address in page table or page directory entry
    // 0xFFF = 111111111111
    // ~0xFFF = 1111111111 1111111111 000000000000
    // #define PTE_ADDR(pte)   ((uintptr_t)(pte) & ~0xFFF)
    // #define PDE_ADDR(pde)   PTE_ADDR(pde)
    uintptr_t pa = PDE_ADDR(*pdep);
c01046b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046bb:	8b 00                	mov    (%eax),%eax
c01046bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01046c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    // 再转换为虚拟地址（线性地址）
    // KADDR = pa >> 12 + 0xC0000000
    // 0xC0000000 = 11000000 00000000 00000000 00000000
    pte_t *pde_kva = KADDR(pa);
c01046c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01046c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01046cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046ce:	c1 e8 0c             	shr    $0xc,%eax
c01046d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01046d4:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01046d9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
c01046dc:	72 23                	jb     c0104701 <get_pte+0x130>
c01046de:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046e5:	c7 44 24 08 6c 6c 10 	movl   $0xc0106c6c,0x8(%esp)
c01046ec:	c0 
c01046ed:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c01046f4:	00 
c01046f5:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01046fc:	e8 eb c5 ff ff       	call   c0100cec <__panic>
c0104701:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104704:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104709:	89 45 d0             	mov    %eax,-0x30(%ebp)
    
    // 需要映射的线性地址
    // 中间10位(PTE)
    uintptr_t need_to_map_ptx = PTX(la);
c010470c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010470f:	c1 e8 0c             	shr    $0xc,%eax
c0104712:	25 ff 03 00 00       	and    $0x3ff,%eax
c0104717:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return &pde_kva[need_to_map_ptx];
c010471a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010471d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104724:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104727:	01 d0                	add    %edx,%eax
}
c0104729:	c9                   	leave  
c010472a:	c3                   	ret    

c010472b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010472b:	55                   	push   %ebp
c010472c:	89 e5                	mov    %esp,%ebp
c010472e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104731:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104738:	00 
c0104739:	8b 45 0c             	mov    0xc(%ebp),%eax
c010473c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104740:	8b 45 08             	mov    0x8(%ebp),%eax
c0104743:	89 04 24             	mov    %eax,(%esp)
c0104746:	e8 86 fe ff ff       	call   c01045d1 <get_pte>
c010474b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010474e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104752:	74 08                	je     c010475c <get_page+0x31>
        *ptep_store = ptep;
c0104754:	8b 45 10             	mov    0x10(%ebp),%eax
c0104757:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010475a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010475c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104760:	74 1b                	je     c010477d <get_page+0x52>
c0104762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104765:	8b 00                	mov    (%eax),%eax
c0104767:	83 e0 01             	and    $0x1,%eax
c010476a:	85 c0                	test   %eax,%eax
c010476c:	74 0f                	je     c010477d <get_page+0x52>
        return pte2page(*ptep);
c010476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104771:	8b 00                	mov    (%eax),%eax
c0104773:	89 04 24             	mov    %eax,(%esp)
c0104776:	e8 3f f5 ff ff       	call   c0103cba <pte2page>
c010477b:	eb 05                	jmp    c0104782 <get_page+0x57>
    }
    return NULL;
c010477d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104782:	c9                   	leave  
c0104783:	c3                   	ret    

c0104784 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104784:	55                   	push   %ebp
c0104785:	89 e5                	mov    %esp,%ebp
c0104787:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010478a:	8b 45 10             	mov    0x10(%ebp),%eax
c010478d:	8b 00                	mov    (%eax),%eax
c010478f:	83 e0 01             	and    $0x1,%eax
c0104792:	85 c0                	test   %eax,%eax
c0104794:	74 4d                	je     c01047e3 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104796:	8b 45 10             	mov    0x10(%ebp),%eax
c0104799:	8b 00                	mov    (%eax),%eax
c010479b:	89 04 24             	mov    %eax,(%esp)
c010479e:	e8 17 f5 ff ff       	call   c0103cba <pte2page>
c01047a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c01047a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a9:	89 04 24             	mov    %eax,(%esp)
c01047ac:	e8 8d f5 ff ff       	call   c0103d3e <page_ref_dec>
c01047b1:	85 c0                	test   %eax,%eax
c01047b3:	75 13                	jne    c01047c8 <page_remove_pte+0x44>
            free_page(page);
c01047b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01047bc:	00 
c01047bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c0:	89 04 24             	mov    %eax,(%esp)
c01047c3:	e8 85 f7 ff ff       	call   c0103f4d <free_pages>
        }
        *ptep = 0;
c01047c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01047cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01047d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01047d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01047db:	89 04 24             	mov    %eax,(%esp)
c01047de:	e8 ff 00 00 00       	call   c01048e2 <tlb_invalidate>
    }
}
c01047e3:	c9                   	leave  
c01047e4:	c3                   	ret    

c01047e5 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01047e5:	55                   	push   %ebp
c01047e6:	89 e5                	mov    %esp,%ebp
c01047e8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01047eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047f2:	00 
c01047f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01047fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01047fd:	89 04 24             	mov    %eax,(%esp)
c0104800:	e8 cc fd ff ff       	call   c01045d1 <get_pte>
c0104805:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104808:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010480c:	74 19                	je     c0104827 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104811:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104815:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104818:	89 44 24 04          	mov    %eax,0x4(%esp)
c010481c:	8b 45 08             	mov    0x8(%ebp),%eax
c010481f:	89 04 24             	mov    %eax,(%esp)
c0104822:	e8 5d ff ff ff       	call   c0104784 <page_remove_pte>
    }
}
c0104827:	c9                   	leave  
c0104828:	c3                   	ret    

c0104829 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104829:	55                   	push   %ebp
c010482a:	89 e5                	mov    %esp,%ebp
c010482c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010482f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104836:	00 
c0104837:	8b 45 10             	mov    0x10(%ebp),%eax
c010483a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010483e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104841:	89 04 24             	mov    %eax,(%esp)
c0104844:	e8 88 fd ff ff       	call   c01045d1 <get_pte>
c0104849:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010484c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104850:	75 0a                	jne    c010485c <page_insert+0x33>
        return -E_NO_MEM;
c0104852:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104857:	e9 84 00 00 00       	jmp    c01048e0 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010485c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010485f:	89 04 24             	mov    %eax,(%esp)
c0104862:	e8 c0 f4 ff ff       	call   c0103d27 <page_ref_inc>
    if (*ptep & PTE_P) {
c0104867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010486a:	8b 00                	mov    (%eax),%eax
c010486c:	83 e0 01             	and    $0x1,%eax
c010486f:	85 c0                	test   %eax,%eax
c0104871:	74 3e                	je     c01048b1 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104876:	8b 00                	mov    (%eax),%eax
c0104878:	89 04 24             	mov    %eax,(%esp)
c010487b:	e8 3a f4 ff ff       	call   c0103cba <pte2page>
c0104880:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104883:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104886:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104889:	75 0d                	jne    c0104898 <page_insert+0x6f>
            page_ref_dec(page);
c010488b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010488e:	89 04 24             	mov    %eax,(%esp)
c0104891:	e8 a8 f4 ff ff       	call   c0103d3e <page_ref_dec>
c0104896:	eb 19                	jmp    c01048b1 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104898:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010489b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010489f:	8b 45 10             	mov    0x10(%ebp),%eax
c01048a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a9:	89 04 24             	mov    %eax,(%esp)
c01048ac:	e8 d3 fe ff ff       	call   c0104784 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01048b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048b4:	89 04 24             	mov    %eax,(%esp)
c01048b7:	e8 45 f3 ff ff       	call   c0103c01 <page2pa>
c01048bc:	0b 45 14             	or     0x14(%ebp),%eax
c01048bf:	83 c8 01             	or     $0x1,%eax
c01048c2:	89 c2                	mov    %eax,%edx
c01048c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c7:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01048c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01048cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01048d3:	89 04 24             	mov    %eax,(%esp)
c01048d6:	e8 07 00 00 00       	call   c01048e2 <tlb_invalidate>
    return 0;
c01048db:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01048e0:	c9                   	leave  
c01048e1:	c3                   	ret    

c01048e2 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01048e2:	55                   	push   %ebp
c01048e3:	89 e5                	mov    %esp,%ebp
c01048e5:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01048e8:	0f 20 d8             	mov    %cr3,%eax
c01048eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01048ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01048f1:	89 c2                	mov    %eax,%edx
c01048f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01048f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048f9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104900:	77 23                	ja     c0104925 <tlb_invalidate+0x43>
c0104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104905:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104909:	c7 44 24 08 10 6d 10 	movl   $0xc0106d10,0x8(%esp)
c0104910:	c0 
c0104911:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104918:	00 
c0104919:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104920:	e8 c7 c3 ff ff       	call   c0100cec <__panic>
c0104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104928:	05 00 00 00 40       	add    $0x40000000,%eax
c010492d:	39 c2                	cmp    %eax,%edx
c010492f:	75 0c                	jne    c010493d <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104931:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104934:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104937:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010493a:	0f 01 38             	invlpg (%eax)
    }
}
c010493d:	c9                   	leave  
c010493e:	c3                   	ret    

c010493f <check_alloc_page>:

static void
check_alloc_page(void) {
c010493f:	55                   	push   %ebp
c0104940:	89 e5                	mov    %esp,%ebp
c0104942:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104945:	a1 7c af 11 c0       	mov    0xc011af7c,%eax
c010494a:	8b 40 18             	mov    0x18(%eax),%eax
c010494d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010494f:	c7 04 24 94 6d 10 c0 	movl   $0xc0106d94,(%esp)
c0104956:	e8 fd b9 ff ff       	call   c0100358 <cprintf>
}
c010495b:	c9                   	leave  
c010495c:	c3                   	ret    

c010495d <check_pgdir>:

static void
check_pgdir(void) {
c010495d:	55                   	push   %ebp
c010495e:	89 e5                	mov    %esp,%ebp
c0104960:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104963:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104968:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010496d:	76 24                	jbe    c0104993 <check_pgdir+0x36>
c010496f:	c7 44 24 0c b3 6d 10 	movl   $0xc0106db3,0xc(%esp)
c0104976:	c0 
c0104977:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c010497e:	c0 
c010497f:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104986:	00 
c0104987:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c010498e:	e8 59 c3 ff ff       	call   c0100cec <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104993:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104998:	85 c0                	test   %eax,%eax
c010499a:	74 0e                	je     c01049aa <check_pgdir+0x4d>
c010499c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049a1:	25 ff 0f 00 00       	and    $0xfff,%eax
c01049a6:	85 c0                	test   %eax,%eax
c01049a8:	74 24                	je     c01049ce <check_pgdir+0x71>
c01049aa:	c7 44 24 0c d0 6d 10 	movl   $0xc0106dd0,0xc(%esp)
c01049b1:	c0 
c01049b2:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01049b9:	c0 
c01049ba:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c01049c1:	00 
c01049c2:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01049c9:	e8 1e c3 ff ff       	call   c0100cec <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01049ce:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049da:	00 
c01049db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01049e2:	00 
c01049e3:	89 04 24             	mov    %eax,(%esp)
c01049e6:	e8 40 fd ff ff       	call   c010472b <get_page>
c01049eb:	85 c0                	test   %eax,%eax
c01049ed:	74 24                	je     c0104a13 <check_pgdir+0xb6>
c01049ef:	c7 44 24 0c 08 6e 10 	movl   $0xc0106e08,0xc(%esp)
c01049f6:	c0 
c01049f7:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01049fe:	c0 
c01049ff:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104a06:	00 
c0104a07:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104a0e:	e8 d9 c2 ff ff       	call   c0100cec <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a1a:	e8 f6 f4 ff ff       	call   c0103f15 <alloc_pages>
c0104a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104a22:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104a2e:	00 
c0104a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a36:	00 
c0104a37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a3e:	89 04 24             	mov    %eax,(%esp)
c0104a41:	e8 e3 fd ff ff       	call   c0104829 <page_insert>
c0104a46:	85 c0                	test   %eax,%eax
c0104a48:	74 24                	je     c0104a6e <check_pgdir+0x111>
c0104a4a:	c7 44 24 0c 30 6e 10 	movl   $0xc0106e30,0xc(%esp)
c0104a51:	c0 
c0104a52:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104a59:	c0 
c0104a5a:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104a61:	00 
c0104a62:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104a69:	e8 7e c2 ff ff       	call   c0100cec <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104a6e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a7a:	00 
c0104a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104a82:	00 
c0104a83:	89 04 24             	mov    %eax,(%esp)
c0104a86:	e8 46 fb ff ff       	call   c01045d1 <get_pte>
c0104a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a92:	75 24                	jne    c0104ab8 <check_pgdir+0x15b>
c0104a94:	c7 44 24 0c 5c 6e 10 	movl   $0xc0106e5c,0xc(%esp)
c0104a9b:	c0 
c0104a9c:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104aa3:	c0 
c0104aa4:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104aab:	00 
c0104aac:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104ab3:	e8 34 c2 ff ff       	call   c0100cec <__panic>
    assert(pte2page(*ptep) == p1);
c0104ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abb:	8b 00                	mov    (%eax),%eax
c0104abd:	89 04 24             	mov    %eax,(%esp)
c0104ac0:	e8 f5 f1 ff ff       	call   c0103cba <pte2page>
c0104ac5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104ac8:	74 24                	je     c0104aee <check_pgdir+0x191>
c0104aca:	c7 44 24 0c 89 6e 10 	movl   $0xc0106e89,0xc(%esp)
c0104ad1:	c0 
c0104ad2:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104ad9:	c0 
c0104ada:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104ae1:	00 
c0104ae2:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104ae9:	e8 fe c1 ff ff       	call   c0100cec <__panic>
    assert(page_ref(p1) == 1);
c0104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104af1:	89 04 24             	mov    %eax,(%esp)
c0104af4:	e8 17 f2 ff ff       	call   c0103d10 <page_ref>
c0104af9:	83 f8 01             	cmp    $0x1,%eax
c0104afc:	74 24                	je     c0104b22 <check_pgdir+0x1c5>
c0104afe:	c7 44 24 0c 9f 6e 10 	movl   $0xc0106e9f,0xc(%esp)
c0104b05:	c0 
c0104b06:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104b0d:	c0 
c0104b0e:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104b15:	00 
c0104b16:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104b1d:	e8 ca c1 ff ff       	call   c0100cec <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104b22:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b27:	8b 00                	mov    (%eax),%eax
c0104b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b34:	c1 e8 0c             	shr    $0xc,%eax
c0104b37:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104b3a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104b3f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104b42:	72 23                	jb     c0104b67 <check_pgdir+0x20a>
c0104b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b4b:	c7 44 24 08 6c 6c 10 	movl   $0xc0106c6c,0x8(%esp)
c0104b52:	c0 
c0104b53:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104b5a:	00 
c0104b5b:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104b62:	e8 85 c1 ff ff       	call   c0100cec <__panic>
c0104b67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b6a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104b6f:	83 c0 04             	add    $0x4,%eax
c0104b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104b75:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b81:	00 
c0104b82:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b89:	00 
c0104b8a:	89 04 24             	mov    %eax,(%esp)
c0104b8d:	e8 3f fa ff ff       	call   c01045d1 <get_pte>
c0104b92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b95:	74 24                	je     c0104bbb <check_pgdir+0x25e>
c0104b97:	c7 44 24 0c b4 6e 10 	movl   $0xc0106eb4,0xc(%esp)
c0104b9e:	c0 
c0104b9f:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104ba6:	c0 
c0104ba7:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104bae:	00 
c0104baf:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104bb6:	e8 31 c1 ff ff       	call   c0100cec <__panic>

    p2 = alloc_page();
c0104bbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bc2:	e8 4e f3 ff ff       	call   c0103f15 <alloc_pages>
c0104bc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104bca:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bcf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104bd6:	00 
c0104bd7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104bde:	00 
c0104bdf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104be2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104be6:	89 04 24             	mov    %eax,(%esp)
c0104be9:	e8 3b fc ff ff       	call   c0104829 <page_insert>
c0104bee:	85 c0                	test   %eax,%eax
c0104bf0:	74 24                	je     c0104c16 <check_pgdir+0x2b9>
c0104bf2:	c7 44 24 0c dc 6e 10 	movl   $0xc0106edc,0xc(%esp)
c0104bf9:	c0 
c0104bfa:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104c01:	c0 
c0104c02:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104c09:	00 
c0104c0a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104c11:	e8 d6 c0 ff ff       	call   c0100cec <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c16:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c22:	00 
c0104c23:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c2a:	00 
c0104c2b:	89 04 24             	mov    %eax,(%esp)
c0104c2e:	e8 9e f9 ff ff       	call   c01045d1 <get_pte>
c0104c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c3a:	75 24                	jne    c0104c60 <check_pgdir+0x303>
c0104c3c:	c7 44 24 0c 14 6f 10 	movl   $0xc0106f14,0xc(%esp)
c0104c43:	c0 
c0104c44:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104c4b:	c0 
c0104c4c:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0104c53:	00 
c0104c54:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104c5b:	e8 8c c0 ff ff       	call   c0100cec <__panic>
    assert(*ptep & PTE_U);
c0104c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c63:	8b 00                	mov    (%eax),%eax
c0104c65:	83 e0 04             	and    $0x4,%eax
c0104c68:	85 c0                	test   %eax,%eax
c0104c6a:	75 24                	jne    c0104c90 <check_pgdir+0x333>
c0104c6c:	c7 44 24 0c 44 6f 10 	movl   $0xc0106f44,0xc(%esp)
c0104c73:	c0 
c0104c74:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104c7b:	c0 
c0104c7c:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0104c83:	00 
c0104c84:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104c8b:	e8 5c c0 ff ff       	call   c0100cec <__panic>
    assert(*ptep & PTE_W);
c0104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c93:	8b 00                	mov    (%eax),%eax
c0104c95:	83 e0 02             	and    $0x2,%eax
c0104c98:	85 c0                	test   %eax,%eax
c0104c9a:	75 24                	jne    c0104cc0 <check_pgdir+0x363>
c0104c9c:	c7 44 24 0c 52 6f 10 	movl   $0xc0106f52,0xc(%esp)
c0104ca3:	c0 
c0104ca4:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104cab:	c0 
c0104cac:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104cb3:	00 
c0104cb4:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104cbb:	e8 2c c0 ff ff       	call   c0100cec <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104cc0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104cc5:	8b 00                	mov    (%eax),%eax
c0104cc7:	83 e0 04             	and    $0x4,%eax
c0104cca:	85 c0                	test   %eax,%eax
c0104ccc:	75 24                	jne    c0104cf2 <check_pgdir+0x395>
c0104cce:	c7 44 24 0c 60 6f 10 	movl   $0xc0106f60,0xc(%esp)
c0104cd5:	c0 
c0104cd6:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104cdd:	c0 
c0104cde:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104ce5:	00 
c0104ce6:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104ced:	e8 fa bf ff ff       	call   c0100cec <__panic>
    assert(page_ref(p2) == 1);
c0104cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cf5:	89 04 24             	mov    %eax,(%esp)
c0104cf8:	e8 13 f0 ff ff       	call   c0103d10 <page_ref>
c0104cfd:	83 f8 01             	cmp    $0x1,%eax
c0104d00:	74 24                	je     c0104d26 <check_pgdir+0x3c9>
c0104d02:	c7 44 24 0c 76 6f 10 	movl   $0xc0106f76,0xc(%esp)
c0104d09:	c0 
c0104d0a:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104d11:	c0 
c0104d12:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104d19:	00 
c0104d1a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104d21:	e8 c6 bf ff ff       	call   c0100cec <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104d26:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d2b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104d32:	00 
c0104d33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104d3a:	00 
c0104d3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104d3e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104d42:	89 04 24             	mov    %eax,(%esp)
c0104d45:	e8 df fa ff ff       	call   c0104829 <page_insert>
c0104d4a:	85 c0                	test   %eax,%eax
c0104d4c:	74 24                	je     c0104d72 <check_pgdir+0x415>
c0104d4e:	c7 44 24 0c 88 6f 10 	movl   $0xc0106f88,0xc(%esp)
c0104d55:	c0 
c0104d56:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104d5d:	c0 
c0104d5e:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104d65:	00 
c0104d66:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104d6d:	e8 7a bf ff ff       	call   c0100cec <__panic>
    assert(page_ref(p1) == 2);
c0104d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d75:	89 04 24             	mov    %eax,(%esp)
c0104d78:	e8 93 ef ff ff       	call   c0103d10 <page_ref>
c0104d7d:	83 f8 02             	cmp    $0x2,%eax
c0104d80:	74 24                	je     c0104da6 <check_pgdir+0x449>
c0104d82:	c7 44 24 0c b4 6f 10 	movl   $0xc0106fb4,0xc(%esp)
c0104d89:	c0 
c0104d8a:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104d91:	c0 
c0104d92:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104d99:	00 
c0104d9a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104da1:	e8 46 bf ff ff       	call   c0100cec <__panic>
    assert(page_ref(p2) == 0);
c0104da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104da9:	89 04 24             	mov    %eax,(%esp)
c0104dac:	e8 5f ef ff ff       	call   c0103d10 <page_ref>
c0104db1:	85 c0                	test   %eax,%eax
c0104db3:	74 24                	je     c0104dd9 <check_pgdir+0x47c>
c0104db5:	c7 44 24 0c c6 6f 10 	movl   $0xc0106fc6,0xc(%esp)
c0104dbc:	c0 
c0104dbd:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104dc4:	c0 
c0104dc5:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104dcc:	00 
c0104dcd:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104dd4:	e8 13 bf ff ff       	call   c0100cec <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104dd9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dde:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104de5:	00 
c0104de6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ded:	00 
c0104dee:	89 04 24             	mov    %eax,(%esp)
c0104df1:	e8 db f7 ff ff       	call   c01045d1 <get_pte>
c0104df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104df9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104dfd:	75 24                	jne    c0104e23 <check_pgdir+0x4c6>
c0104dff:	c7 44 24 0c 14 6f 10 	movl   $0xc0106f14,0xc(%esp)
c0104e06:	c0 
c0104e07:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104e0e:	c0 
c0104e0f:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104e16:	00 
c0104e17:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104e1e:	e8 c9 be ff ff       	call   c0100cec <__panic>
    assert(pte2page(*ptep) == p1);
c0104e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e26:	8b 00                	mov    (%eax),%eax
c0104e28:	89 04 24             	mov    %eax,(%esp)
c0104e2b:	e8 8a ee ff ff       	call   c0103cba <pte2page>
c0104e30:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e33:	74 24                	je     c0104e59 <check_pgdir+0x4fc>
c0104e35:	c7 44 24 0c 89 6e 10 	movl   $0xc0106e89,0xc(%esp)
c0104e3c:	c0 
c0104e3d:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104e44:	c0 
c0104e45:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104e4c:	00 
c0104e4d:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104e54:	e8 93 be ff ff       	call   c0100cec <__panic>
    assert((*ptep & PTE_U) == 0);
c0104e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e5c:	8b 00                	mov    (%eax),%eax
c0104e5e:	83 e0 04             	and    $0x4,%eax
c0104e61:	85 c0                	test   %eax,%eax
c0104e63:	74 24                	je     c0104e89 <check_pgdir+0x52c>
c0104e65:	c7 44 24 0c d8 6f 10 	movl   $0xc0106fd8,0xc(%esp)
c0104e6c:	c0 
c0104e6d:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104e74:	c0 
c0104e75:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104e7c:	00 
c0104e7d:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104e84:	e8 63 be ff ff       	call   c0100cec <__panic>

    page_remove(boot_pgdir, 0x0);
c0104e89:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104e95:	00 
c0104e96:	89 04 24             	mov    %eax,(%esp)
c0104e99:	e8 47 f9 ff ff       	call   c01047e5 <page_remove>
    assert(page_ref(p1) == 1);
c0104e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ea1:	89 04 24             	mov    %eax,(%esp)
c0104ea4:	e8 67 ee ff ff       	call   c0103d10 <page_ref>
c0104ea9:	83 f8 01             	cmp    $0x1,%eax
c0104eac:	74 24                	je     c0104ed2 <check_pgdir+0x575>
c0104eae:	c7 44 24 0c 9f 6e 10 	movl   $0xc0106e9f,0xc(%esp)
c0104eb5:	c0 
c0104eb6:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104ebd:	c0 
c0104ebe:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104ec5:	00 
c0104ec6:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104ecd:	e8 1a be ff ff       	call   c0100cec <__panic>
    assert(page_ref(p2) == 0);
c0104ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ed5:	89 04 24             	mov    %eax,(%esp)
c0104ed8:	e8 33 ee ff ff       	call   c0103d10 <page_ref>
c0104edd:	85 c0                	test   %eax,%eax
c0104edf:	74 24                	je     c0104f05 <check_pgdir+0x5a8>
c0104ee1:	c7 44 24 0c c6 6f 10 	movl   $0xc0106fc6,0xc(%esp)
c0104ee8:	c0 
c0104ee9:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104ef8:	00 
c0104ef9:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104f00:	e8 e7 bd ff ff       	call   c0100cec <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104f05:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f0a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104f11:	00 
c0104f12:	89 04 24             	mov    %eax,(%esp)
c0104f15:	e8 cb f8 ff ff       	call   c01047e5 <page_remove>
    assert(page_ref(p1) == 0);
c0104f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f1d:	89 04 24             	mov    %eax,(%esp)
c0104f20:	e8 eb ed ff ff       	call   c0103d10 <page_ref>
c0104f25:	85 c0                	test   %eax,%eax
c0104f27:	74 24                	je     c0104f4d <check_pgdir+0x5f0>
c0104f29:	c7 44 24 0c ed 6f 10 	movl   $0xc0106fed,0xc(%esp)
c0104f30:	c0 
c0104f31:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104f38:	c0 
c0104f39:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0104f40:	00 
c0104f41:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104f48:	e8 9f bd ff ff       	call   c0100cec <__panic>
    assert(page_ref(p2) == 0);
c0104f4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f50:	89 04 24             	mov    %eax,(%esp)
c0104f53:	e8 b8 ed ff ff       	call   c0103d10 <page_ref>
c0104f58:	85 c0                	test   %eax,%eax
c0104f5a:	74 24                	je     c0104f80 <check_pgdir+0x623>
c0104f5c:	c7 44 24 0c c6 6f 10 	movl   $0xc0106fc6,0xc(%esp)
c0104f63:	c0 
c0104f64:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104f6b:	c0 
c0104f6c:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0104f73:	00 
c0104f74:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104f7b:	e8 6c bd ff ff       	call   c0100cec <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104f80:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f85:	8b 00                	mov    (%eax),%eax
c0104f87:	89 04 24             	mov    %eax,(%esp)
c0104f8a:	e8 69 ed ff ff       	call   c0103cf8 <pde2page>
c0104f8f:	89 04 24             	mov    %eax,(%esp)
c0104f92:	e8 79 ed ff ff       	call   c0103d10 <page_ref>
c0104f97:	83 f8 01             	cmp    $0x1,%eax
c0104f9a:	74 24                	je     c0104fc0 <check_pgdir+0x663>
c0104f9c:	c7 44 24 0c 00 70 10 	movl   $0xc0107000,0xc(%esp)
c0104fa3:	c0 
c0104fa4:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0104fab:	c0 
c0104fac:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0104fb3:	00 
c0104fb4:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0104fbb:	e8 2c bd ff ff       	call   c0100cec <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104fc0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fc5:	8b 00                	mov    (%eax),%eax
c0104fc7:	89 04 24             	mov    %eax,(%esp)
c0104fca:	e8 29 ed ff ff       	call   c0103cf8 <pde2page>
c0104fcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fd6:	00 
c0104fd7:	89 04 24             	mov    %eax,(%esp)
c0104fda:	e8 6e ef ff ff       	call   c0103f4d <free_pages>
    boot_pgdir[0] = 0;
c0104fdf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fe4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104fea:	c7 04 24 27 70 10 c0 	movl   $0xc0107027,(%esp)
c0104ff1:	e8 62 b3 ff ff       	call   c0100358 <cprintf>
}
c0104ff6:	c9                   	leave  
c0104ff7:	c3                   	ret    

c0104ff8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104ff8:	55                   	push   %ebp
c0104ff9:	89 e5                	mov    %esp,%ebp
c0104ffb:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104ffe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105005:	e9 ca 00 00 00       	jmp    c01050d4 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010500d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105010:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105013:	c1 e8 0c             	shr    $0xc,%eax
c0105016:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105019:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010501e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105021:	72 23                	jb     c0105046 <check_boot_pgdir+0x4e>
c0105023:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105026:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010502a:	c7 44 24 08 6c 6c 10 	movl   $0xc0106c6c,0x8(%esp)
c0105031:	c0 
c0105032:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0105039:	00 
c010503a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105041:	e8 a6 bc ff ff       	call   c0100cec <__panic>
c0105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105049:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010504e:	89 c2                	mov    %eax,%edx
c0105050:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105055:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010505c:	00 
c010505d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105061:	89 04 24             	mov    %eax,(%esp)
c0105064:	e8 68 f5 ff ff       	call   c01045d1 <get_pte>
c0105069:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010506c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105070:	75 24                	jne    c0105096 <check_boot_pgdir+0x9e>
c0105072:	c7 44 24 0c 44 70 10 	movl   $0xc0107044,0xc(%esp)
c0105079:	c0 
c010507a:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105081:	c0 
c0105082:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0105089:	00 
c010508a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105091:	e8 56 bc ff ff       	call   c0100cec <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105096:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105099:	8b 00                	mov    (%eax),%eax
c010509b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050a0:	89 c2                	mov    %eax,%edx
c01050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050a5:	39 c2                	cmp    %eax,%edx
c01050a7:	74 24                	je     c01050cd <check_boot_pgdir+0xd5>
c01050a9:	c7 44 24 0c 81 70 10 	movl   $0xc0107081,0xc(%esp)
c01050b0:	c0 
c01050b1:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01050b8:	c0 
c01050b9:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c01050c0:	00 
c01050c1:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01050c8:	e8 1f bc ff ff       	call   c0100cec <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01050cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01050d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01050d7:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01050dc:	39 c2                	cmp    %eax,%edx
c01050de:	0f 82 26 ff ff ff    	jb     c010500a <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01050e4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050e9:	05 ac 0f 00 00       	add    $0xfac,%eax
c01050ee:	8b 00                	mov    (%eax),%eax
c01050f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050f5:	89 c2                	mov    %eax,%edx
c01050f7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01050ff:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0105106:	77 23                	ja     c010512b <check_boot_pgdir+0x133>
c0105108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010510b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010510f:	c7 44 24 08 10 6d 10 	movl   $0xc0106d10,0x8(%esp)
c0105116:	c0 
c0105117:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c010511e:	00 
c010511f:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105126:	e8 c1 bb ff ff       	call   c0100cec <__panic>
c010512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010512e:	05 00 00 00 40       	add    $0x40000000,%eax
c0105133:	39 c2                	cmp    %eax,%edx
c0105135:	74 24                	je     c010515b <check_boot_pgdir+0x163>
c0105137:	c7 44 24 0c 98 70 10 	movl   $0xc0107098,0xc(%esp)
c010513e:	c0 
c010513f:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105146:	c0 
c0105147:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c010514e:	00 
c010514f:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105156:	e8 91 bb ff ff       	call   c0100cec <__panic>

    assert(boot_pgdir[0] == 0);
c010515b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105160:	8b 00                	mov    (%eax),%eax
c0105162:	85 c0                	test   %eax,%eax
c0105164:	74 24                	je     c010518a <check_boot_pgdir+0x192>
c0105166:	c7 44 24 0c cc 70 10 	movl   $0xc01070cc,0xc(%esp)
c010516d:	c0 
c010516e:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105175:	c0 
c0105176:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c010517d:	00 
c010517e:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105185:	e8 62 bb ff ff       	call   c0100cec <__panic>

    struct Page *p;
    p = alloc_page();
c010518a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105191:	e8 7f ed ff ff       	call   c0103f15 <alloc_pages>
c0105196:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105199:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010519e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01051a5:	00 
c01051a6:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01051ad:	00 
c01051ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01051b1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01051b5:	89 04 24             	mov    %eax,(%esp)
c01051b8:	e8 6c f6 ff ff       	call   c0104829 <page_insert>
c01051bd:	85 c0                	test   %eax,%eax
c01051bf:	74 24                	je     c01051e5 <check_boot_pgdir+0x1ed>
c01051c1:	c7 44 24 0c e0 70 10 	movl   $0xc01070e0,0xc(%esp)
c01051c8:	c0 
c01051c9:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01051d0:	c0 
c01051d1:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01051d8:	00 
c01051d9:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01051e0:	e8 07 bb ff ff       	call   c0100cec <__panic>
    assert(page_ref(p) == 1);
c01051e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051e8:	89 04 24             	mov    %eax,(%esp)
c01051eb:	e8 20 eb ff ff       	call   c0103d10 <page_ref>
c01051f0:	83 f8 01             	cmp    $0x1,%eax
c01051f3:	74 24                	je     c0105219 <check_boot_pgdir+0x221>
c01051f5:	c7 44 24 0c 0e 71 10 	movl   $0xc010710e,0xc(%esp)
c01051fc:	c0 
c01051fd:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105204:	c0 
c0105205:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c010520c:	00 
c010520d:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105214:	e8 d3 ba ff ff       	call   c0100cec <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105219:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010521e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105225:	00 
c0105226:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010522d:	00 
c010522e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105231:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105235:	89 04 24             	mov    %eax,(%esp)
c0105238:	e8 ec f5 ff ff       	call   c0104829 <page_insert>
c010523d:	85 c0                	test   %eax,%eax
c010523f:	74 24                	je     c0105265 <check_boot_pgdir+0x26d>
c0105241:	c7 44 24 0c 20 71 10 	movl   $0xc0107120,0xc(%esp)
c0105248:	c0 
c0105249:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105250:	c0 
c0105251:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0105258:	00 
c0105259:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105260:	e8 87 ba ff ff       	call   c0100cec <__panic>
    assert(page_ref(p) == 2);
c0105265:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105268:	89 04 24             	mov    %eax,(%esp)
c010526b:	e8 a0 ea ff ff       	call   c0103d10 <page_ref>
c0105270:	83 f8 02             	cmp    $0x2,%eax
c0105273:	74 24                	je     c0105299 <check_boot_pgdir+0x2a1>
c0105275:	c7 44 24 0c 57 71 10 	movl   $0xc0107157,0xc(%esp)
c010527c:	c0 
c010527d:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105284:	c0 
c0105285:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c010528c:	00 
c010528d:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105294:	e8 53 ba ff ff       	call   c0100cec <__panic>

    const char *str = "ucore: Hello world!!";
c0105299:	c7 45 dc 68 71 10 c0 	movl   $0xc0107168,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01052a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052a7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01052ae:	e8 19 0a 00 00       	call   c0105ccc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01052b3:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01052ba:	00 
c01052bb:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01052c2:	e8 7e 0a 00 00       	call   c0105d45 <strcmp>
c01052c7:	85 c0                	test   %eax,%eax
c01052c9:	74 24                	je     c01052ef <check_boot_pgdir+0x2f7>
c01052cb:	c7 44 24 0c 80 71 10 	movl   $0xc0107180,0xc(%esp)
c01052d2:	c0 
c01052d3:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c01052da:	c0 
c01052db:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c01052e2:	00 
c01052e3:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c01052ea:	e8 fd b9 ff ff       	call   c0100cec <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01052ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052f2:	89 04 24             	mov    %eax,(%esp)
c01052f5:	e8 6c e9 ff ff       	call   c0103c66 <page2kva>
c01052fa:	05 00 01 00 00       	add    $0x100,%eax
c01052ff:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105302:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105309:	e8 66 09 00 00       	call   c0105c74 <strlen>
c010530e:	85 c0                	test   %eax,%eax
c0105310:	74 24                	je     c0105336 <check_boot_pgdir+0x33e>
c0105312:	c7 44 24 0c b8 71 10 	movl   $0xc01071b8,0xc(%esp)
c0105319:	c0 
c010531a:	c7 44 24 08 59 6d 10 	movl   $0xc0106d59,0x8(%esp)
c0105321:	c0 
c0105322:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c0105329:	00 
c010532a:	c7 04 24 34 6d 10 c0 	movl   $0xc0106d34,(%esp)
c0105331:	e8 b6 b9 ff ff       	call   c0100cec <__panic>

    free_page(p);
c0105336:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010533d:	00 
c010533e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105341:	89 04 24             	mov    %eax,(%esp)
c0105344:	e8 04 ec ff ff       	call   c0103f4d <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105349:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010534e:	8b 00                	mov    (%eax),%eax
c0105350:	89 04 24             	mov    %eax,(%esp)
c0105353:	e8 a0 e9 ff ff       	call   c0103cf8 <pde2page>
c0105358:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010535f:	00 
c0105360:	89 04 24             	mov    %eax,(%esp)
c0105363:	e8 e5 eb ff ff       	call   c0103f4d <free_pages>
    boot_pgdir[0] = 0;
c0105368:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010536d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105373:	c7 04 24 dc 71 10 c0 	movl   $0xc01071dc,(%esp)
c010537a:	e8 d9 af ff ff       	call   c0100358 <cprintf>
}
c010537f:	c9                   	leave  
c0105380:	c3                   	ret    

c0105381 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105381:	55                   	push   %ebp
c0105382:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105384:	8b 45 08             	mov    0x8(%ebp),%eax
c0105387:	83 e0 04             	and    $0x4,%eax
c010538a:	85 c0                	test   %eax,%eax
c010538c:	74 07                	je     c0105395 <perm2str+0x14>
c010538e:	b8 75 00 00 00       	mov    $0x75,%eax
c0105393:	eb 05                	jmp    c010539a <perm2str+0x19>
c0105395:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010539a:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c010539f:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01053a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01053a9:	83 e0 02             	and    $0x2,%eax
c01053ac:	85 c0                	test   %eax,%eax
c01053ae:	74 07                	je     c01053b7 <perm2str+0x36>
c01053b0:	b8 77 00 00 00       	mov    $0x77,%eax
c01053b5:	eb 05                	jmp    c01053bc <perm2str+0x3b>
c01053b7:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01053bc:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c01053c1:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c01053c8:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c01053cd:	5d                   	pop    %ebp
c01053ce:	c3                   	ret    

c01053cf <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01053cf:	55                   	push   %ebp
c01053d0:	89 e5                	mov    %esp,%ebp
c01053d2:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01053d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01053d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053db:	72 0a                	jb     c01053e7 <get_pgtable_items+0x18>
        return 0;
c01053dd:	b8 00 00 00 00       	mov    $0x0,%eax
c01053e2:	e9 9c 00 00 00       	jmp    c0105483 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01053e7:	eb 04                	jmp    c01053ed <get_pgtable_items+0x1e>
        start ++;
c01053e9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01053ed:	8b 45 10             	mov    0x10(%ebp),%eax
c01053f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053f3:	73 18                	jae    c010540d <get_pgtable_items+0x3e>
c01053f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01053f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01053ff:	8b 45 14             	mov    0x14(%ebp),%eax
c0105402:	01 d0                	add    %edx,%eax
c0105404:	8b 00                	mov    (%eax),%eax
c0105406:	83 e0 01             	and    $0x1,%eax
c0105409:	85 c0                	test   %eax,%eax
c010540b:	74 dc                	je     c01053e9 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c010540d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105410:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105413:	73 69                	jae    c010547e <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105415:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105419:	74 08                	je     c0105423 <get_pgtable_items+0x54>
            *left_store = start;
c010541b:	8b 45 18             	mov    0x18(%ebp),%eax
c010541e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105421:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105423:	8b 45 10             	mov    0x10(%ebp),%eax
c0105426:	8d 50 01             	lea    0x1(%eax),%edx
c0105429:	89 55 10             	mov    %edx,0x10(%ebp)
c010542c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105433:	8b 45 14             	mov    0x14(%ebp),%eax
c0105436:	01 d0                	add    %edx,%eax
c0105438:	8b 00                	mov    (%eax),%eax
c010543a:	83 e0 07             	and    $0x7,%eax
c010543d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105440:	eb 04                	jmp    c0105446 <get_pgtable_items+0x77>
            start ++;
c0105442:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105446:	8b 45 10             	mov    0x10(%ebp),%eax
c0105449:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010544c:	73 1d                	jae    c010546b <get_pgtable_items+0x9c>
c010544e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105451:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105458:	8b 45 14             	mov    0x14(%ebp),%eax
c010545b:	01 d0                	add    %edx,%eax
c010545d:	8b 00                	mov    (%eax),%eax
c010545f:	83 e0 07             	and    $0x7,%eax
c0105462:	89 c2                	mov    %eax,%edx
c0105464:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105467:	39 c2                	cmp    %eax,%edx
c0105469:	74 d7                	je     c0105442 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c010546b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010546f:	74 08                	je     c0105479 <get_pgtable_items+0xaa>
            *right_store = start;
c0105471:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105474:	8b 55 10             	mov    0x10(%ebp),%edx
c0105477:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010547c:	eb 05                	jmp    c0105483 <get_pgtable_items+0xb4>
    }
    return 0;
c010547e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105483:	c9                   	leave  
c0105484:	c3                   	ret    

c0105485 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105485:	55                   	push   %ebp
c0105486:	89 e5                	mov    %esp,%ebp
c0105488:	57                   	push   %edi
c0105489:	56                   	push   %esi
c010548a:	53                   	push   %ebx
c010548b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010548e:	c7 04 24 fc 71 10 c0 	movl   $0xc01071fc,(%esp)
c0105495:	e8 be ae ff ff       	call   c0100358 <cprintf>
    size_t left, right = 0, perm;
c010549a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01054a1:	e9 fa 00 00 00       	jmp    c01055a0 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01054a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054a9:	89 04 24             	mov    %eax,(%esp)
c01054ac:	e8 d0 fe ff ff       	call   c0105381 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01054b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01054b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01054b7:	29 d1                	sub    %edx,%ecx
c01054b9:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01054bb:	89 d6                	mov    %edx,%esi
c01054bd:	c1 e6 16             	shl    $0x16,%esi
c01054c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01054c3:	89 d3                	mov    %edx,%ebx
c01054c5:	c1 e3 16             	shl    $0x16,%ebx
c01054c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01054cb:	89 d1                	mov    %edx,%ecx
c01054cd:	c1 e1 16             	shl    $0x16,%ecx
c01054d0:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01054d3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01054d6:	29 d7                	sub    %edx,%edi
c01054d8:	89 fa                	mov    %edi,%edx
c01054da:	89 44 24 14          	mov    %eax,0x14(%esp)
c01054de:	89 74 24 10          	mov    %esi,0x10(%esp)
c01054e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01054e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01054ea:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054ee:	c7 04 24 2d 72 10 c0 	movl   $0xc010722d,(%esp)
c01054f5:	e8 5e ae ff ff       	call   c0100358 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01054fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054fd:	c1 e0 0a             	shl    $0xa,%eax
c0105500:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105503:	eb 54                	jmp    c0105559 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105508:	89 04 24             	mov    %eax,(%esp)
c010550b:	e8 71 fe ff ff       	call   c0105381 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105510:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105513:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105516:	29 d1                	sub    %edx,%ecx
c0105518:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010551a:	89 d6                	mov    %edx,%esi
c010551c:	c1 e6 0c             	shl    $0xc,%esi
c010551f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105522:	89 d3                	mov    %edx,%ebx
c0105524:	c1 e3 0c             	shl    $0xc,%ebx
c0105527:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010552a:	c1 e2 0c             	shl    $0xc,%edx
c010552d:	89 d1                	mov    %edx,%ecx
c010552f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105532:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105535:	29 d7                	sub    %edx,%edi
c0105537:	89 fa                	mov    %edi,%edx
c0105539:	89 44 24 14          	mov    %eax,0x14(%esp)
c010553d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105541:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105545:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105549:	89 54 24 04          	mov    %edx,0x4(%esp)
c010554d:	c7 04 24 4c 72 10 c0 	movl   $0xc010724c,(%esp)
c0105554:	e8 ff ad ff ff       	call   c0100358 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105559:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c010555e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105564:	89 ce                	mov    %ecx,%esi
c0105566:	c1 e6 0a             	shl    $0xa,%esi
c0105569:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010556c:	89 cb                	mov    %ecx,%ebx
c010556e:	c1 e3 0a             	shl    $0xa,%ebx
c0105571:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105574:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105578:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010557b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010557f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105583:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105587:	89 74 24 04          	mov    %esi,0x4(%esp)
c010558b:	89 1c 24             	mov    %ebx,(%esp)
c010558e:	e8 3c fe ff ff       	call   c01053cf <get_pgtable_items>
c0105593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105596:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010559a:	0f 85 65 ff ff ff    	jne    c0105505 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01055a0:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c01055a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055a8:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c01055ab:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01055af:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c01055b2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01055b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01055ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c01055be:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01055c5:	00 
c01055c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01055cd:	e8 fd fd ff ff       	call   c01053cf <get_pgtable_items>
c01055d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01055d9:	0f 85 c7 fe ff ff    	jne    c01054a6 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01055df:	c7 04 24 70 72 10 c0 	movl   $0xc0107270,(%esp)
c01055e6:	e8 6d ad ff ff       	call   c0100358 <cprintf>
}
c01055eb:	83 c4 4c             	add    $0x4c,%esp
c01055ee:	5b                   	pop    %ebx
c01055ef:	5e                   	pop    %esi
c01055f0:	5f                   	pop    %edi
c01055f1:	5d                   	pop    %ebp
c01055f2:	c3                   	ret    

c01055f3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01055f3:	55                   	push   %ebp
c01055f4:	89 e5                	mov    %esp,%ebp
c01055f6:	83 ec 58             	sub    $0x58,%esp
c01055f9:	8b 45 10             	mov    0x10(%ebp),%eax
c01055fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01055ff:	8b 45 14             	mov    0x14(%ebp),%eax
c0105602:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105605:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105608:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010560b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010560e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105611:	8b 45 18             	mov    0x18(%ebp),%eax
c0105614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105617:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010561a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010561d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105620:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105623:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105626:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105629:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010562d:	74 1c                	je     c010564b <printnum+0x58>
c010562f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105632:	ba 00 00 00 00       	mov    $0x0,%edx
c0105637:	f7 75 e4             	divl   -0x1c(%ebp)
c010563a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010563d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105640:	ba 00 00 00 00       	mov    $0x0,%edx
c0105645:	f7 75 e4             	divl   -0x1c(%ebp)
c0105648:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010564b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010564e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105651:	f7 75 e4             	divl   -0x1c(%ebp)
c0105654:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105657:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010565a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010565d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105660:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105663:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105666:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105669:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010566c:	8b 45 18             	mov    0x18(%ebp),%eax
c010566f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105674:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105677:	77 56                	ja     c01056cf <printnum+0xdc>
c0105679:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010567c:	72 05                	jb     c0105683 <printnum+0x90>
c010567e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105681:	77 4c                	ja     c01056cf <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105683:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105686:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105689:	8b 45 20             	mov    0x20(%ebp),%eax
c010568c:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105690:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105694:	8b 45 18             	mov    0x18(%ebp),%eax
c0105697:	89 44 24 10          	mov    %eax,0x10(%esp)
c010569b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010569e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056a1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01056a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01056a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b3:	89 04 24             	mov    %eax,(%esp)
c01056b6:	e8 38 ff ff ff       	call   c01055f3 <printnum>
c01056bb:	eb 1c                	jmp    c01056d9 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01056bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056c4:	8b 45 20             	mov    0x20(%ebp),%eax
c01056c7:	89 04 24             	mov    %eax,(%esp)
c01056ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01056cd:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01056cf:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01056d3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01056d7:	7f e4                	jg     c01056bd <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01056d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01056dc:	05 24 73 10 c0       	add    $0xc0107324,%eax
c01056e1:	0f b6 00             	movzbl (%eax),%eax
c01056e4:	0f be c0             	movsbl %al,%eax
c01056e7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056ea:	89 54 24 04          	mov    %edx,0x4(%esp)
c01056ee:	89 04 24             	mov    %eax,(%esp)
c01056f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01056f4:	ff d0                	call   *%eax
}
c01056f6:	c9                   	leave  
c01056f7:	c3                   	ret    

c01056f8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01056f8:	55                   	push   %ebp
c01056f9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01056fb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01056ff:	7e 14                	jle    c0105715 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105701:	8b 45 08             	mov    0x8(%ebp),%eax
c0105704:	8b 00                	mov    (%eax),%eax
c0105706:	8d 48 08             	lea    0x8(%eax),%ecx
c0105709:	8b 55 08             	mov    0x8(%ebp),%edx
c010570c:	89 0a                	mov    %ecx,(%edx)
c010570e:	8b 50 04             	mov    0x4(%eax),%edx
c0105711:	8b 00                	mov    (%eax),%eax
c0105713:	eb 30                	jmp    c0105745 <getuint+0x4d>
    }
    else if (lflag) {
c0105715:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105719:	74 16                	je     c0105731 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010571b:	8b 45 08             	mov    0x8(%ebp),%eax
c010571e:	8b 00                	mov    (%eax),%eax
c0105720:	8d 48 04             	lea    0x4(%eax),%ecx
c0105723:	8b 55 08             	mov    0x8(%ebp),%edx
c0105726:	89 0a                	mov    %ecx,(%edx)
c0105728:	8b 00                	mov    (%eax),%eax
c010572a:	ba 00 00 00 00       	mov    $0x0,%edx
c010572f:	eb 14                	jmp    c0105745 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105731:	8b 45 08             	mov    0x8(%ebp),%eax
c0105734:	8b 00                	mov    (%eax),%eax
c0105736:	8d 48 04             	lea    0x4(%eax),%ecx
c0105739:	8b 55 08             	mov    0x8(%ebp),%edx
c010573c:	89 0a                	mov    %ecx,(%edx)
c010573e:	8b 00                	mov    (%eax),%eax
c0105740:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105745:	5d                   	pop    %ebp
c0105746:	c3                   	ret    

c0105747 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105747:	55                   	push   %ebp
c0105748:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010574a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010574e:	7e 14                	jle    c0105764 <getint+0x1d>
        return va_arg(*ap, long long);
c0105750:	8b 45 08             	mov    0x8(%ebp),%eax
c0105753:	8b 00                	mov    (%eax),%eax
c0105755:	8d 48 08             	lea    0x8(%eax),%ecx
c0105758:	8b 55 08             	mov    0x8(%ebp),%edx
c010575b:	89 0a                	mov    %ecx,(%edx)
c010575d:	8b 50 04             	mov    0x4(%eax),%edx
c0105760:	8b 00                	mov    (%eax),%eax
c0105762:	eb 28                	jmp    c010578c <getint+0x45>
    }
    else if (lflag) {
c0105764:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105768:	74 12                	je     c010577c <getint+0x35>
        return va_arg(*ap, long);
c010576a:	8b 45 08             	mov    0x8(%ebp),%eax
c010576d:	8b 00                	mov    (%eax),%eax
c010576f:	8d 48 04             	lea    0x4(%eax),%ecx
c0105772:	8b 55 08             	mov    0x8(%ebp),%edx
c0105775:	89 0a                	mov    %ecx,(%edx)
c0105777:	8b 00                	mov    (%eax),%eax
c0105779:	99                   	cltd   
c010577a:	eb 10                	jmp    c010578c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010577c:	8b 45 08             	mov    0x8(%ebp),%eax
c010577f:	8b 00                	mov    (%eax),%eax
c0105781:	8d 48 04             	lea    0x4(%eax),%ecx
c0105784:	8b 55 08             	mov    0x8(%ebp),%edx
c0105787:	89 0a                	mov    %ecx,(%edx)
c0105789:	8b 00                	mov    (%eax),%eax
c010578b:	99                   	cltd   
    }
}
c010578c:	5d                   	pop    %ebp
c010578d:	c3                   	ret    

c010578e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010578e:	55                   	push   %ebp
c010578f:	89 e5                	mov    %esp,%ebp
c0105791:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105794:	8d 45 14             	lea    0x14(%ebp),%eax
c0105797:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010579a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010579d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01057a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01057a4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057af:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b2:	89 04 24             	mov    %eax,(%esp)
c01057b5:	e8 02 00 00 00       	call   c01057bc <vprintfmt>
    va_end(ap);
}
c01057ba:	c9                   	leave  
c01057bb:	c3                   	ret    

c01057bc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01057bc:	55                   	push   %ebp
c01057bd:	89 e5                	mov    %esp,%ebp
c01057bf:	56                   	push   %esi
c01057c0:	53                   	push   %ebx
c01057c1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01057c4:	eb 18                	jmp    c01057de <vprintfmt+0x22>
            if (ch == '\0') {
c01057c6:	85 db                	test   %ebx,%ebx
c01057c8:	75 05                	jne    c01057cf <vprintfmt+0x13>
                return;
c01057ca:	e9 d1 03 00 00       	jmp    c0105ba0 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01057cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057d6:	89 1c 24             	mov    %ebx,(%esp)
c01057d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01057dc:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01057de:	8b 45 10             	mov    0x10(%ebp),%eax
c01057e1:	8d 50 01             	lea    0x1(%eax),%edx
c01057e4:	89 55 10             	mov    %edx,0x10(%ebp)
c01057e7:	0f b6 00             	movzbl (%eax),%eax
c01057ea:	0f b6 d8             	movzbl %al,%ebx
c01057ed:	83 fb 25             	cmp    $0x25,%ebx
c01057f0:	75 d4                	jne    c01057c6 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01057f2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01057f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01057fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105800:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105803:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010580a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010580d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105810:	8b 45 10             	mov    0x10(%ebp),%eax
c0105813:	8d 50 01             	lea    0x1(%eax),%edx
c0105816:	89 55 10             	mov    %edx,0x10(%ebp)
c0105819:	0f b6 00             	movzbl (%eax),%eax
c010581c:	0f b6 d8             	movzbl %al,%ebx
c010581f:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105822:	83 f8 55             	cmp    $0x55,%eax
c0105825:	0f 87 44 03 00 00    	ja     c0105b6f <vprintfmt+0x3b3>
c010582b:	8b 04 85 48 73 10 c0 	mov    -0x3fef8cb8(,%eax,4),%eax
c0105832:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105834:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105838:	eb d6                	jmp    c0105810 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010583a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010583e:	eb d0                	jmp    c0105810 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105840:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010584a:	89 d0                	mov    %edx,%eax
c010584c:	c1 e0 02             	shl    $0x2,%eax
c010584f:	01 d0                	add    %edx,%eax
c0105851:	01 c0                	add    %eax,%eax
c0105853:	01 d8                	add    %ebx,%eax
c0105855:	83 e8 30             	sub    $0x30,%eax
c0105858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010585b:	8b 45 10             	mov    0x10(%ebp),%eax
c010585e:	0f b6 00             	movzbl (%eax),%eax
c0105861:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105864:	83 fb 2f             	cmp    $0x2f,%ebx
c0105867:	7e 0b                	jle    c0105874 <vprintfmt+0xb8>
c0105869:	83 fb 39             	cmp    $0x39,%ebx
c010586c:	7f 06                	jg     c0105874 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010586e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105872:	eb d3                	jmp    c0105847 <vprintfmt+0x8b>
            goto process_precision;
c0105874:	eb 33                	jmp    c01058a9 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0105876:	8b 45 14             	mov    0x14(%ebp),%eax
c0105879:	8d 50 04             	lea    0x4(%eax),%edx
c010587c:	89 55 14             	mov    %edx,0x14(%ebp)
c010587f:	8b 00                	mov    (%eax),%eax
c0105881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105884:	eb 23                	jmp    c01058a9 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0105886:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010588a:	79 0c                	jns    c0105898 <vprintfmt+0xdc>
                width = 0;
c010588c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105893:	e9 78 ff ff ff       	jmp    c0105810 <vprintfmt+0x54>
c0105898:	e9 73 ff ff ff       	jmp    c0105810 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010589d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01058a4:	e9 67 ff ff ff       	jmp    c0105810 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01058a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01058ad:	79 12                	jns    c01058c1 <vprintfmt+0x105>
                width = precision, precision = -1;
c01058af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058b5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01058bc:	e9 4f ff ff ff       	jmp    c0105810 <vprintfmt+0x54>
c01058c1:	e9 4a ff ff ff       	jmp    c0105810 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01058c6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01058ca:	e9 41 ff ff ff       	jmp    c0105810 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01058cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01058d2:	8d 50 04             	lea    0x4(%eax),%edx
c01058d5:	89 55 14             	mov    %edx,0x14(%ebp)
c01058d8:	8b 00                	mov    (%eax),%eax
c01058da:	8b 55 0c             	mov    0xc(%ebp),%edx
c01058dd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01058e1:	89 04 24             	mov    %eax,(%esp)
c01058e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e7:	ff d0                	call   *%eax
            break;
c01058e9:	e9 ac 02 00 00       	jmp    c0105b9a <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01058ee:	8b 45 14             	mov    0x14(%ebp),%eax
c01058f1:	8d 50 04             	lea    0x4(%eax),%edx
c01058f4:	89 55 14             	mov    %edx,0x14(%ebp)
c01058f7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01058f9:	85 db                	test   %ebx,%ebx
c01058fb:	79 02                	jns    c01058ff <vprintfmt+0x143>
                err = -err;
c01058fd:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01058ff:	83 fb 06             	cmp    $0x6,%ebx
c0105902:	7f 0b                	jg     c010590f <vprintfmt+0x153>
c0105904:	8b 34 9d 08 73 10 c0 	mov    -0x3fef8cf8(,%ebx,4),%esi
c010590b:	85 f6                	test   %esi,%esi
c010590d:	75 23                	jne    c0105932 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010590f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105913:	c7 44 24 08 35 73 10 	movl   $0xc0107335,0x8(%esp)
c010591a:	c0 
c010591b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010591e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105922:	8b 45 08             	mov    0x8(%ebp),%eax
c0105925:	89 04 24             	mov    %eax,(%esp)
c0105928:	e8 61 fe ff ff       	call   c010578e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010592d:	e9 68 02 00 00       	jmp    c0105b9a <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105932:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105936:	c7 44 24 08 3e 73 10 	movl   $0xc010733e,0x8(%esp)
c010593d:	c0 
c010593e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105941:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105945:	8b 45 08             	mov    0x8(%ebp),%eax
c0105948:	89 04 24             	mov    %eax,(%esp)
c010594b:	e8 3e fe ff ff       	call   c010578e <printfmt>
            }
            break;
c0105950:	e9 45 02 00 00       	jmp    c0105b9a <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105955:	8b 45 14             	mov    0x14(%ebp),%eax
c0105958:	8d 50 04             	lea    0x4(%eax),%edx
c010595b:	89 55 14             	mov    %edx,0x14(%ebp)
c010595e:	8b 30                	mov    (%eax),%esi
c0105960:	85 f6                	test   %esi,%esi
c0105962:	75 05                	jne    c0105969 <vprintfmt+0x1ad>
                p = "(null)";
c0105964:	be 41 73 10 c0       	mov    $0xc0107341,%esi
            }
            if (width > 0 && padc != '-') {
c0105969:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010596d:	7e 3e                	jle    c01059ad <vprintfmt+0x1f1>
c010596f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105973:	74 38                	je     c01059ad <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105975:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010597b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010597f:	89 34 24             	mov    %esi,(%esp)
c0105982:	e8 15 03 00 00       	call   c0105c9c <strnlen>
c0105987:	29 c3                	sub    %eax,%ebx
c0105989:	89 d8                	mov    %ebx,%eax
c010598b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010598e:	eb 17                	jmp    c01059a7 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105990:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105994:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105997:	89 54 24 04          	mov    %edx,0x4(%esp)
c010599b:	89 04 24             	mov    %eax,(%esp)
c010599e:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a1:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01059a3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01059a7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01059ab:	7f e3                	jg     c0105990 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01059ad:	eb 38                	jmp    c01059e7 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c01059af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01059b3:	74 1f                	je     c01059d4 <vprintfmt+0x218>
c01059b5:	83 fb 1f             	cmp    $0x1f,%ebx
c01059b8:	7e 05                	jle    c01059bf <vprintfmt+0x203>
c01059ba:	83 fb 7e             	cmp    $0x7e,%ebx
c01059bd:	7e 15                	jle    c01059d4 <vprintfmt+0x218>
                    putch('?', putdat);
c01059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01059cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d0:	ff d0                	call   *%eax
c01059d2:	eb 0f                	jmp    c01059e3 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01059d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059db:	89 1c 24             	mov    %ebx,(%esp)
c01059de:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e1:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01059e3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01059e7:	89 f0                	mov    %esi,%eax
c01059e9:	8d 70 01             	lea    0x1(%eax),%esi
c01059ec:	0f b6 00             	movzbl (%eax),%eax
c01059ef:	0f be d8             	movsbl %al,%ebx
c01059f2:	85 db                	test   %ebx,%ebx
c01059f4:	74 10                	je     c0105a06 <vprintfmt+0x24a>
c01059f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01059fa:	78 b3                	js     c01059af <vprintfmt+0x1f3>
c01059fc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105a00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105a04:	79 a9                	jns    c01059af <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105a06:	eb 17                	jmp    c0105a1f <vprintfmt+0x263>
                putch(' ', putdat);
c0105a08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a0f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105a16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a19:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105a1b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105a1f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a23:	7f e3                	jg     c0105a08 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0105a25:	e9 70 01 00 00       	jmp    c0105b9a <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a31:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a34:	89 04 24             	mov    %eax,(%esp)
c0105a37:	e8 0b fd ff ff       	call   c0105747 <getint>
c0105a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a3f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a48:	85 d2                	test   %edx,%edx
c0105a4a:	79 26                	jns    c0105a72 <vprintfmt+0x2b6>
                putch('-', putdat);
c0105a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a53:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105a5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5d:	ff d0                	call   *%eax
                num = -(long long)num;
c0105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a65:	f7 d8                	neg    %eax
c0105a67:	83 d2 00             	adc    $0x0,%edx
c0105a6a:	f7 da                	neg    %edx
c0105a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a6f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105a72:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105a79:	e9 a8 00 00 00       	jmp    c0105b26 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a85:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a88:	89 04 24             	mov    %eax,(%esp)
c0105a8b:	e8 68 fc ff ff       	call   c01056f8 <getuint>
c0105a90:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a93:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105a96:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105a9d:	e9 84 00 00 00       	jmp    c0105b26 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aa9:	8d 45 14             	lea    0x14(%ebp),%eax
c0105aac:	89 04 24             	mov    %eax,(%esp)
c0105aaf:	e8 44 fc ff ff       	call   c01056f8 <getuint>
c0105ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ab7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105aba:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105ac1:	eb 63                	jmp    c0105b26 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad4:	ff d0                	call   *%eax
            putch('x', putdat);
c0105ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105add:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105ae4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae7:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105ae9:	8b 45 14             	mov    0x14(%ebp),%eax
c0105aec:	8d 50 04             	lea    0x4(%eax),%edx
c0105aef:	89 55 14             	mov    %edx,0x14(%ebp)
c0105af2:	8b 00                	mov    (%eax),%eax
c0105af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105afe:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105b05:	eb 1f                	jmp    c0105b26 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b0e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b11:	89 04 24             	mov    %eax,(%esp)
c0105b14:	e8 df fb ff ff       	call   c01056f8 <getuint>
c0105b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105b1f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105b26:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b2d:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105b31:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105b34:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105b38:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b42:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b46:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b54:	89 04 24             	mov    %eax,(%esp)
c0105b57:	e8 97 fa ff ff       	call   c01055f3 <printnum>
            break;
c0105b5c:	eb 3c                	jmp    c0105b9a <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b65:	89 1c 24             	mov    %ebx,(%esp)
c0105b68:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b6b:	ff d0                	call   *%eax
            break;
c0105b6d:	eb 2b                	jmp    c0105b9a <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b76:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b80:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105b82:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105b86:	eb 04                	jmp    c0105b8c <vprintfmt+0x3d0>
c0105b88:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105b8c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b8f:	83 e8 01             	sub    $0x1,%eax
c0105b92:	0f b6 00             	movzbl (%eax),%eax
c0105b95:	3c 25                	cmp    $0x25,%al
c0105b97:	75 ef                	jne    c0105b88 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105b99:	90                   	nop
        }
    }
c0105b9a:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105b9b:	e9 3e fc ff ff       	jmp    c01057de <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105ba0:	83 c4 40             	add    $0x40,%esp
c0105ba3:	5b                   	pop    %ebx
c0105ba4:	5e                   	pop    %esi
c0105ba5:	5d                   	pop    %ebp
c0105ba6:	c3                   	ret    

c0105ba7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105ba7:	55                   	push   %ebp
c0105ba8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105baa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bad:	8b 40 08             	mov    0x8(%eax),%eax
c0105bb0:	8d 50 01             	lea    0x1(%eax),%edx
c0105bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bbc:	8b 10                	mov    (%eax),%edx
c0105bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bc1:	8b 40 04             	mov    0x4(%eax),%eax
c0105bc4:	39 c2                	cmp    %eax,%edx
c0105bc6:	73 12                	jae    c0105bda <sprintputch+0x33>
        *b->buf ++ = ch;
c0105bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bcb:	8b 00                	mov    (%eax),%eax
c0105bcd:	8d 48 01             	lea    0x1(%eax),%ecx
c0105bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105bd3:	89 0a                	mov    %ecx,(%edx)
c0105bd5:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bd8:	88 10                	mov    %dl,(%eax)
    }
}
c0105bda:	5d                   	pop    %ebp
c0105bdb:	c3                   	ret    

c0105bdc <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105bdc:	55                   	push   %ebp
c0105bdd:	89 e5                	mov    %esp,%ebp
c0105bdf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105be2:	8d 45 14             	lea    0x14(%ebp),%eax
c0105be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105beb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105bef:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bf2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c00:	89 04 24             	mov    %eax,(%esp)
c0105c03:	e8 08 00 00 00       	call   c0105c10 <vsnprintf>
c0105c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105c0e:	c9                   	leave  
c0105c0f:	c3                   	ret    

c0105c10 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105c10:	55                   	push   %ebp
c0105c11:	89 e5                	mov    %esp,%ebp
c0105c13:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c25:	01 d0                	add    %edx,%eax
c0105c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105c31:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c35:	74 0a                	je     c0105c41 <vsnprintf+0x31>
c0105c37:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c3d:	39 c2                	cmp    %eax,%edx
c0105c3f:	76 07                	jbe    c0105c48 <vsnprintf+0x38>
        return -E_INVAL;
c0105c41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105c46:	eb 2a                	jmp    c0105c72 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105c48:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c52:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c56:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105c59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c5d:	c7 04 24 a7 5b 10 c0 	movl   $0xc0105ba7,(%esp)
c0105c64:	e8 53 fb ff ff       	call   c01057bc <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c6c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105c72:	c9                   	leave  
c0105c73:	c3                   	ret    

c0105c74 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105c74:	55                   	push   %ebp
c0105c75:	89 e5                	mov    %esp,%ebp
c0105c77:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105c7a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105c81:	eb 04                	jmp    c0105c87 <strlen+0x13>
        cnt ++;
c0105c83:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8a:	8d 50 01             	lea    0x1(%eax),%edx
c0105c8d:	89 55 08             	mov    %edx,0x8(%ebp)
c0105c90:	0f b6 00             	movzbl (%eax),%eax
c0105c93:	84 c0                	test   %al,%al
c0105c95:	75 ec                	jne    c0105c83 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105c97:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105c9a:	c9                   	leave  
c0105c9b:	c3                   	ret    

c0105c9c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105c9c:	55                   	push   %ebp
c0105c9d:	89 e5                	mov    %esp,%ebp
c0105c9f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105ca2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105ca9:	eb 04                	jmp    c0105caf <strnlen+0x13>
        cnt ++;
c0105cab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105cb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105cb5:	73 10                	jae    c0105cc7 <strnlen+0x2b>
c0105cb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cba:	8d 50 01             	lea    0x1(%eax),%edx
c0105cbd:	89 55 08             	mov    %edx,0x8(%ebp)
c0105cc0:	0f b6 00             	movzbl (%eax),%eax
c0105cc3:	84 c0                	test   %al,%al
c0105cc5:	75 e4                	jne    c0105cab <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105cca:	c9                   	leave  
c0105ccb:	c3                   	ret    

c0105ccc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105ccc:	55                   	push   %ebp
c0105ccd:	89 e5                	mov    %esp,%ebp
c0105ccf:	57                   	push   %edi
c0105cd0:	56                   	push   %esi
c0105cd1:	83 ec 20             	sub    $0x20,%esp
c0105cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce6:	89 d1                	mov    %edx,%ecx
c0105ce8:	89 c2                	mov    %eax,%edx
c0105cea:	89 ce                	mov    %ecx,%esi
c0105cec:	89 d7                	mov    %edx,%edi
c0105cee:	ac                   	lods   %ds:(%esi),%al
c0105cef:	aa                   	stos   %al,%es:(%edi)
c0105cf0:	84 c0                	test   %al,%al
c0105cf2:	75 fa                	jne    c0105cee <strcpy+0x22>
c0105cf4:	89 fa                	mov    %edi,%edx
c0105cf6:	89 f1                	mov    %esi,%ecx
c0105cf8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105cfb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105cfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105d04:	83 c4 20             	add    $0x20,%esp
c0105d07:	5e                   	pop    %esi
c0105d08:	5f                   	pop    %edi
c0105d09:	5d                   	pop    %ebp
c0105d0a:	c3                   	ret    

c0105d0b <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105d0b:	55                   	push   %ebp
c0105d0c:	89 e5                	mov    %esp,%ebp
c0105d0e:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105d11:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d14:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105d17:	eb 21                	jmp    c0105d3a <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105d19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d1c:	0f b6 10             	movzbl (%eax),%edx
c0105d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d22:	88 10                	mov    %dl,(%eax)
c0105d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d27:	0f b6 00             	movzbl (%eax),%eax
c0105d2a:	84 c0                	test   %al,%al
c0105d2c:	74 04                	je     c0105d32 <strncpy+0x27>
            src ++;
c0105d2e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105d32:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105d36:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105d3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d3e:	75 d9                	jne    c0105d19 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105d40:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105d43:	c9                   	leave  
c0105d44:	c3                   	ret    

c0105d45 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105d45:	55                   	push   %ebp
c0105d46:	89 e5                	mov    %esp,%ebp
c0105d48:	57                   	push   %edi
c0105d49:	56                   	push   %esi
c0105d4a:	83 ec 20             	sub    $0x20,%esp
c0105d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d5f:	89 d1                	mov    %edx,%ecx
c0105d61:	89 c2                	mov    %eax,%edx
c0105d63:	89 ce                	mov    %ecx,%esi
c0105d65:	89 d7                	mov    %edx,%edi
c0105d67:	ac                   	lods   %ds:(%esi),%al
c0105d68:	ae                   	scas   %es:(%edi),%al
c0105d69:	75 08                	jne    c0105d73 <strcmp+0x2e>
c0105d6b:	84 c0                	test   %al,%al
c0105d6d:	75 f8                	jne    c0105d67 <strcmp+0x22>
c0105d6f:	31 c0                	xor    %eax,%eax
c0105d71:	eb 04                	jmp    c0105d77 <strcmp+0x32>
c0105d73:	19 c0                	sbb    %eax,%eax
c0105d75:	0c 01                	or     $0x1,%al
c0105d77:	89 fa                	mov    %edi,%edx
c0105d79:	89 f1                	mov    %esi,%ecx
c0105d7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d7e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105d81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105d84:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105d87:	83 c4 20             	add    $0x20,%esp
c0105d8a:	5e                   	pop    %esi
c0105d8b:	5f                   	pop    %edi
c0105d8c:	5d                   	pop    %ebp
c0105d8d:	c3                   	ret    

c0105d8e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105d8e:	55                   	push   %ebp
c0105d8f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105d91:	eb 0c                	jmp    c0105d9f <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105d93:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105d97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d9b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105d9f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105da3:	74 1a                	je     c0105dbf <strncmp+0x31>
c0105da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da8:	0f b6 00             	movzbl (%eax),%eax
c0105dab:	84 c0                	test   %al,%al
c0105dad:	74 10                	je     c0105dbf <strncmp+0x31>
c0105daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db2:	0f b6 10             	movzbl (%eax),%edx
c0105db5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db8:	0f b6 00             	movzbl (%eax),%eax
c0105dbb:	38 c2                	cmp    %al,%dl
c0105dbd:	74 d4                	je     c0105d93 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105dbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105dc3:	74 18                	je     c0105ddd <strncmp+0x4f>
c0105dc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc8:	0f b6 00             	movzbl (%eax),%eax
c0105dcb:	0f b6 d0             	movzbl %al,%edx
c0105dce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dd1:	0f b6 00             	movzbl (%eax),%eax
c0105dd4:	0f b6 c0             	movzbl %al,%eax
c0105dd7:	29 c2                	sub    %eax,%edx
c0105dd9:	89 d0                	mov    %edx,%eax
c0105ddb:	eb 05                	jmp    c0105de2 <strncmp+0x54>
c0105ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105de2:	5d                   	pop    %ebp
c0105de3:	c3                   	ret    

c0105de4 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105de4:	55                   	push   %ebp
c0105de5:	89 e5                	mov    %esp,%ebp
c0105de7:	83 ec 04             	sub    $0x4,%esp
c0105dea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ded:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105df0:	eb 14                	jmp    c0105e06 <strchr+0x22>
        if (*s == c) {
c0105df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df5:	0f b6 00             	movzbl (%eax),%eax
c0105df8:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105dfb:	75 05                	jne    c0105e02 <strchr+0x1e>
            return (char *)s;
c0105dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e00:	eb 13                	jmp    c0105e15 <strchr+0x31>
        }
        s ++;
c0105e02:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105e06:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e09:	0f b6 00             	movzbl (%eax),%eax
c0105e0c:	84 c0                	test   %al,%al
c0105e0e:	75 e2                	jne    c0105df2 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e15:	c9                   	leave  
c0105e16:	c3                   	ret    

c0105e17 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105e17:	55                   	push   %ebp
c0105e18:	89 e5                	mov    %esp,%ebp
c0105e1a:	83 ec 04             	sub    $0x4,%esp
c0105e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e20:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105e23:	eb 11                	jmp    c0105e36 <strfind+0x1f>
        if (*s == c) {
c0105e25:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e28:	0f b6 00             	movzbl (%eax),%eax
c0105e2b:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105e2e:	75 02                	jne    c0105e32 <strfind+0x1b>
            break;
c0105e30:	eb 0e                	jmp    c0105e40 <strfind+0x29>
        }
        s ++;
c0105e32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e39:	0f b6 00             	movzbl (%eax),%eax
c0105e3c:	84 c0                	test   %al,%al
c0105e3e:	75 e5                	jne    c0105e25 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105e40:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105e43:	c9                   	leave  
c0105e44:	c3                   	ret    

c0105e45 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105e45:	55                   	push   %ebp
c0105e46:	89 e5                	mov    %esp,%ebp
c0105e48:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105e4b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105e52:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105e59:	eb 04                	jmp    c0105e5f <strtol+0x1a>
        s ++;
c0105e5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e62:	0f b6 00             	movzbl (%eax),%eax
c0105e65:	3c 20                	cmp    $0x20,%al
c0105e67:	74 f2                	je     c0105e5b <strtol+0x16>
c0105e69:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6c:	0f b6 00             	movzbl (%eax),%eax
c0105e6f:	3c 09                	cmp    $0x9,%al
c0105e71:	74 e8                	je     c0105e5b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105e73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e76:	0f b6 00             	movzbl (%eax),%eax
c0105e79:	3c 2b                	cmp    $0x2b,%al
c0105e7b:	75 06                	jne    c0105e83 <strtol+0x3e>
        s ++;
c0105e7d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105e81:	eb 15                	jmp    c0105e98 <strtol+0x53>
    }
    else if (*s == '-') {
c0105e83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e86:	0f b6 00             	movzbl (%eax),%eax
c0105e89:	3c 2d                	cmp    $0x2d,%al
c0105e8b:	75 0b                	jne    c0105e98 <strtol+0x53>
        s ++, neg = 1;
c0105e8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105e91:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105e98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e9c:	74 06                	je     c0105ea4 <strtol+0x5f>
c0105e9e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105ea2:	75 24                	jne    c0105ec8 <strtol+0x83>
c0105ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ea7:	0f b6 00             	movzbl (%eax),%eax
c0105eaa:	3c 30                	cmp    $0x30,%al
c0105eac:	75 1a                	jne    c0105ec8 <strtol+0x83>
c0105eae:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb1:	83 c0 01             	add    $0x1,%eax
c0105eb4:	0f b6 00             	movzbl (%eax),%eax
c0105eb7:	3c 78                	cmp    $0x78,%al
c0105eb9:	75 0d                	jne    c0105ec8 <strtol+0x83>
        s += 2, base = 16;
c0105ebb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105ebf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105ec6:	eb 2a                	jmp    c0105ef2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105ec8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ecc:	75 17                	jne    c0105ee5 <strtol+0xa0>
c0105ece:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed1:	0f b6 00             	movzbl (%eax),%eax
c0105ed4:	3c 30                	cmp    $0x30,%al
c0105ed6:	75 0d                	jne    c0105ee5 <strtol+0xa0>
        s ++, base = 8;
c0105ed8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105edc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105ee3:	eb 0d                	jmp    c0105ef2 <strtol+0xad>
    }
    else if (base == 0) {
c0105ee5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ee9:	75 07                	jne    c0105ef2 <strtol+0xad>
        base = 10;
c0105eeb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105ef2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ef5:	0f b6 00             	movzbl (%eax),%eax
c0105ef8:	3c 2f                	cmp    $0x2f,%al
c0105efa:	7e 1b                	jle    c0105f17 <strtol+0xd2>
c0105efc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eff:	0f b6 00             	movzbl (%eax),%eax
c0105f02:	3c 39                	cmp    $0x39,%al
c0105f04:	7f 11                	jg     c0105f17 <strtol+0xd2>
            dig = *s - '0';
c0105f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f09:	0f b6 00             	movzbl (%eax),%eax
c0105f0c:	0f be c0             	movsbl %al,%eax
c0105f0f:	83 e8 30             	sub    $0x30,%eax
c0105f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f15:	eb 48                	jmp    c0105f5f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105f17:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f1a:	0f b6 00             	movzbl (%eax),%eax
c0105f1d:	3c 60                	cmp    $0x60,%al
c0105f1f:	7e 1b                	jle    c0105f3c <strtol+0xf7>
c0105f21:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f24:	0f b6 00             	movzbl (%eax),%eax
c0105f27:	3c 7a                	cmp    $0x7a,%al
c0105f29:	7f 11                	jg     c0105f3c <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f2e:	0f b6 00             	movzbl (%eax),%eax
c0105f31:	0f be c0             	movsbl %al,%eax
c0105f34:	83 e8 57             	sub    $0x57,%eax
c0105f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f3a:	eb 23                	jmp    c0105f5f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3f:	0f b6 00             	movzbl (%eax),%eax
c0105f42:	3c 40                	cmp    $0x40,%al
c0105f44:	7e 3d                	jle    c0105f83 <strtol+0x13e>
c0105f46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f49:	0f b6 00             	movzbl (%eax),%eax
c0105f4c:	3c 5a                	cmp    $0x5a,%al
c0105f4e:	7f 33                	jg     c0105f83 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105f50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f53:	0f b6 00             	movzbl (%eax),%eax
c0105f56:	0f be c0             	movsbl %al,%eax
c0105f59:	83 e8 37             	sub    $0x37,%eax
c0105f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f62:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105f65:	7c 02                	jl     c0105f69 <strtol+0x124>
            break;
c0105f67:	eb 1a                	jmp    c0105f83 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105f69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105f6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f70:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105f74:	89 c2                	mov    %eax,%edx
c0105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f79:	01 d0                	add    %edx,%eax
c0105f7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105f7e:	e9 6f ff ff ff       	jmp    c0105ef2 <strtol+0xad>

    if (endptr) {
c0105f83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f87:	74 08                	je     c0105f91 <strtol+0x14c>
        *endptr = (char *) s;
c0105f89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f8c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f8f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105f91:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105f95:	74 07                	je     c0105f9e <strtol+0x159>
c0105f97:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f9a:	f7 d8                	neg    %eax
c0105f9c:	eb 03                	jmp    c0105fa1 <strtol+0x15c>
c0105f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105fa1:	c9                   	leave  
c0105fa2:	c3                   	ret    

c0105fa3 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105fa3:	55                   	push   %ebp
c0105fa4:	89 e5                	mov    %esp,%ebp
c0105fa6:	57                   	push   %edi
c0105fa7:	83 ec 24             	sub    $0x24,%esp
c0105faa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fad:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105fb0:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105fb4:	8b 55 08             	mov    0x8(%ebp),%edx
c0105fb7:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105fba:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105fbd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105fc3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105fc6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105fca:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105fcd:	89 d7                	mov    %edx,%edi
c0105fcf:	f3 aa                	rep stos %al,%es:(%edi)
c0105fd1:	89 fa                	mov    %edi,%edx
c0105fd3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105fd6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105fd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105fdc:	83 c4 24             	add    $0x24,%esp
c0105fdf:	5f                   	pop    %edi
c0105fe0:	5d                   	pop    %ebp
c0105fe1:	c3                   	ret    

c0105fe2 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105fe2:	55                   	push   %ebp
c0105fe3:	89 e5                	mov    %esp,%ebp
c0105fe5:	57                   	push   %edi
c0105fe6:	56                   	push   %esi
c0105fe7:	53                   	push   %ebx
c0105fe8:	83 ec 30             	sub    $0x30,%esp
c0105feb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ff4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ff7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ffa:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106000:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106003:	73 42                	jae    c0106047 <memmove+0x65>
c0106005:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106008:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010600b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010600e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106011:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106014:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106017:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010601a:	c1 e8 02             	shr    $0x2,%eax
c010601d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010601f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106022:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106025:	89 d7                	mov    %edx,%edi
c0106027:	89 c6                	mov    %eax,%esi
c0106029:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010602b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010602e:	83 e1 03             	and    $0x3,%ecx
c0106031:	74 02                	je     c0106035 <memmove+0x53>
c0106033:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106035:	89 f0                	mov    %esi,%eax
c0106037:	89 fa                	mov    %edi,%edx
c0106039:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010603c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010603f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106045:	eb 36                	jmp    c010607d <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106047:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010604a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010604d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106050:	01 c2                	add    %eax,%edx
c0106052:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106055:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106058:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010605b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010605e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106061:	89 c1                	mov    %eax,%ecx
c0106063:	89 d8                	mov    %ebx,%eax
c0106065:	89 d6                	mov    %edx,%esi
c0106067:	89 c7                	mov    %eax,%edi
c0106069:	fd                   	std    
c010606a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010606c:	fc                   	cld    
c010606d:	89 f8                	mov    %edi,%eax
c010606f:	89 f2                	mov    %esi,%edx
c0106071:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106074:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106077:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010607d:	83 c4 30             	add    $0x30,%esp
c0106080:	5b                   	pop    %ebx
c0106081:	5e                   	pop    %esi
c0106082:	5f                   	pop    %edi
c0106083:	5d                   	pop    %ebp
c0106084:	c3                   	ret    

c0106085 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106085:	55                   	push   %ebp
c0106086:	89 e5                	mov    %esp,%ebp
c0106088:	57                   	push   %edi
c0106089:	56                   	push   %esi
c010608a:	83 ec 20             	sub    $0x20,%esp
c010608d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106090:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106093:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106096:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106099:	8b 45 10             	mov    0x10(%ebp),%eax
c010609c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010609f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060a2:	c1 e8 02             	shr    $0x2,%eax
c01060a5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01060a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060ad:	89 d7                	mov    %edx,%edi
c01060af:	89 c6                	mov    %eax,%esi
c01060b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01060b3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01060b6:	83 e1 03             	and    $0x3,%ecx
c01060b9:	74 02                	je     c01060bd <memcpy+0x38>
c01060bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01060bd:	89 f0                	mov    %esi,%eax
c01060bf:	89 fa                	mov    %edi,%edx
c01060c1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01060c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01060c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01060cd:	83 c4 20             	add    $0x20,%esp
c01060d0:	5e                   	pop    %esi
c01060d1:	5f                   	pop    %edi
c01060d2:	5d                   	pop    %ebp
c01060d3:	c3                   	ret    

c01060d4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01060d4:	55                   	push   %ebp
c01060d5:	89 e5                	mov    %esp,%ebp
c01060d7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01060da:	8b 45 08             	mov    0x8(%ebp),%eax
c01060dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01060e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01060e6:	eb 30                	jmp    c0106118 <memcmp+0x44>
        if (*s1 != *s2) {
c01060e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01060eb:	0f b6 10             	movzbl (%eax),%edx
c01060ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01060f1:	0f b6 00             	movzbl (%eax),%eax
c01060f4:	38 c2                	cmp    %al,%dl
c01060f6:	74 18                	je     c0106110 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01060f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01060fb:	0f b6 00             	movzbl (%eax),%eax
c01060fe:	0f b6 d0             	movzbl %al,%edx
c0106101:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106104:	0f b6 00             	movzbl (%eax),%eax
c0106107:	0f b6 c0             	movzbl %al,%eax
c010610a:	29 c2                	sub    %eax,%edx
c010610c:	89 d0                	mov    %edx,%eax
c010610e:	eb 1a                	jmp    c010612a <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0106110:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0106114:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0106118:	8b 45 10             	mov    0x10(%ebp),%eax
c010611b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010611e:	89 55 10             	mov    %edx,0x10(%ebp)
c0106121:	85 c0                	test   %eax,%eax
c0106123:	75 c3                	jne    c01060e8 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0106125:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010612a:	c9                   	leave  
c010612b:	c3                   	ret    
