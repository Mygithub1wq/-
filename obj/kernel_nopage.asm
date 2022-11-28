
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
void kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

void
kern_init(void){
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 88 af 11 00       	mov    $0x11af88,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 41 5f 00 00       	call   105fa3 <memset>

    cons_init();                // init the console
  100062:	e8 9c 15 00 00       	call   101603 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 40 61 10 00 	movl   $0x106140,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 5c 61 10 00 	movl   $0x10615c,(%esp)
  10007c:	e8 d7 02 00 00       	call   100358 <cprintf>

    print_kerninfo();
  100081:	e8 06 08 00 00       	call   10088c <print_kerninfo>

    grade_backtrace();
  100086:	e8 8b 00 00 00       	call   100116 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 5c 44 00 00       	call   1044ec <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 d7 16 00 00       	call   10176c <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 4f 18 00 00       	call   1018e9 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 1a 0d 00 00       	call   100db9 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 36 16 00 00       	call   1016da <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a4:	e8 6d 01 00 00       	call   100216 <lab1_switch_test>

    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	55                   	push   %ebp
  1000ac:	89 e5                	mov    %esp,%ebp
  1000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b8:	00 
  1000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c0:	00 
  1000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c8:	e8 0d 0c 00 00       	call   100cda <mon_backtrace>
}
  1000cd:	c9                   	leave  
  1000ce:	c3                   	ret    

001000cf <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cf:	55                   	push   %ebp
  1000d0:	89 e5                	mov    %esp,%ebp
  1000d2:	53                   	push   %ebx
  1000d3:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d6:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000dc:	8d 55 08             	lea    0x8(%ebp),%edx
  1000df:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000ee:	89 04 24             	mov    %eax,(%esp)
  1000f1:	e8 b5 ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000f6:	83 c4 14             	add    $0x14,%esp
  1000f9:	5b                   	pop    %ebx
  1000fa:	5d                   	pop    %ebp
  1000fb:	c3                   	ret    

001000fc <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fc:	55                   	push   %ebp
  1000fd:	89 e5                	mov    %esp,%ebp
  1000ff:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100102:	8b 45 10             	mov    0x10(%ebp),%eax
  100105:	89 44 24 04          	mov    %eax,0x4(%esp)
  100109:	8b 45 08             	mov    0x8(%ebp),%eax
  10010c:	89 04 24             	mov    %eax,(%esp)
  10010f:	e8 bb ff ff ff       	call   1000cf <grade_backtrace1>
}
  100114:	c9                   	leave  
  100115:	c3                   	ret    

00100116 <grade_backtrace>:

void
grade_backtrace(void) {
  100116:	55                   	push   %ebp
  100117:	89 e5                	mov    %esp,%ebp
  100119:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011c:	b8 36 00 10 00       	mov    $0x100036,%eax
  100121:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100128:	ff 
  100129:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100134:	e8 c3 ff ff ff       	call   1000fc <grade_backtrace0>
}
  100139:	c9                   	leave  
  10013a:	c3                   	ret    

0010013b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013b:	55                   	push   %ebp
  10013c:	89 e5                	mov    %esp,%ebp
  10013e:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100141:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100144:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100147:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100151:	0f b7 c0             	movzwl %ax,%eax
  100154:	83 e0 03             	and    $0x3,%eax
  100157:	89 c2                	mov    %eax,%edx
  100159:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100162:	89 44 24 04          	mov    %eax,0x4(%esp)
  100166:	c7 04 24 61 61 10 00 	movl   $0x106161,(%esp)
  10016d:	e8 e6 01 00 00       	call   100358 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100172:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100176:	0f b7 d0             	movzwl %ax,%edx
  100179:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 6f 61 10 00 	movl   $0x10616f,(%esp)
  10018d:	e8 c6 01 00 00       	call   100358 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	0f b7 d0             	movzwl %ax,%edx
  100199:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10019e:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a6:	c7 04 24 7d 61 10 00 	movl   $0x10617d,(%esp)
  1001ad:	e8 a6 01 00 00       	call   100358 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b6:	0f b7 d0             	movzwl %ax,%edx
  1001b9:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001be:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c6:	c7 04 24 8b 61 10 00 	movl   $0x10618b,(%esp)
  1001cd:	e8 86 01 00 00       	call   100358 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d6:	0f b7 d0             	movzwl %ax,%edx
  1001d9:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001de:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e6:	c7 04 24 99 61 10 00 	movl   $0x106199,(%esp)
  1001ed:	e8 66 01 00 00       	call   100358 <cprintf>
    round ++;
  1001f2:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f7:	83 c0 01             	add    $0x1,%eax
  1001fa:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001ff:	c9                   	leave  
  100200:	c3                   	ret    

00100201 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  100204:	83 ec 08             	sub    $0x8,%esp
  100207:	cd 78                	int    $0x78
  100209:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  10020b:	5d                   	pop    %ebp
  10020c:	c3                   	ret    

0010020d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  10020d:	55                   	push   %ebp
  10020e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  100210:	cd 79                	int    $0x79
  100212:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  100214:	5d                   	pop    %ebp
  100215:	c3                   	ret    

00100216 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100216:	55                   	push   %ebp
  100217:	89 e5                	mov    %esp,%ebp
  100219:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10021c:	e8 1a ff ff ff       	call   10013b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100221:	c7 04 24 a8 61 10 00 	movl   $0x1061a8,(%esp)
  100228:	e8 2b 01 00 00       	call   100358 <cprintf>
    lab1_switch_to_user();
  10022d:	e8 cf ff ff ff       	call   100201 <lab1_switch_to_user>
    lab1_print_cur_status();
  100232:	e8 04 ff ff ff       	call   10013b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100237:	c7 04 24 c8 61 10 00 	movl   $0x1061c8,(%esp)
  10023e:	e8 15 01 00 00       	call   100358 <cprintf>
    lab1_switch_to_kernel();
  100243:	e8 c5 ff ff ff       	call   10020d <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100248:	e8 ee fe ff ff       	call   10013b <lab1_print_cur_status>
}
  10024d:	c9                   	leave  
  10024e:	c3                   	ret    

0010024f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10024f:	55                   	push   %ebp
  100250:	89 e5                	mov    %esp,%ebp
  100252:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100255:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100259:	74 13                	je     10026e <readline+0x1f>
        cprintf("%s", prompt);
  10025b:	8b 45 08             	mov    0x8(%ebp),%eax
  10025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100262:	c7 04 24 e7 61 10 00 	movl   $0x1061e7,(%esp)
  100269:	e8 ea 00 00 00       	call   100358 <cprintf>
    }
    int i = 0, c;
  10026e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100275:	e8 66 01 00 00       	call   1003e0 <getchar>
  10027a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10027d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100281:	79 07                	jns    10028a <readline+0x3b>
            return NULL;
  100283:	b8 00 00 00 00       	mov    $0x0,%eax
  100288:	eb 79                	jmp    100303 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10028a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10028e:	7e 28                	jle    1002b8 <readline+0x69>
  100290:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100297:	7f 1f                	jg     1002b8 <readline+0x69>
            cputchar(c);
  100299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10029c:	89 04 24             	mov    %eax,(%esp)
  10029f:	e8 da 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  1002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002a7:	8d 50 01             	lea    0x1(%eax),%edx
  1002aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002b0:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002b6:	eb 46                	jmp    1002fe <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002b8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002bc:	75 17                	jne    1002d5 <readline+0x86>
  1002be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002c2:	7e 11                	jle    1002d5 <readline+0x86>
            cputchar(c);
  1002c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002c7:	89 04 24             	mov    %eax,(%esp)
  1002ca:	e8 af 00 00 00       	call   10037e <cputchar>
            i --;
  1002cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002d3:	eb 29                	jmp    1002fe <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002d5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d9:	74 06                	je     1002e1 <readline+0x92>
  1002db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002df:	75 1d                	jne    1002fe <readline+0xaf>
            cputchar(c);
  1002e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002e4:	89 04 24             	mov    %eax,(%esp)
  1002e7:	e8 92 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002ef:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002f4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002f7:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002fc:	eb 05                	jmp    100303 <readline+0xb4>
        }
    }
  1002fe:	e9 72 ff ff ff       	jmp    100275 <readline+0x26>
}
  100303:	c9                   	leave  
  100304:	c3                   	ret    

00100305 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100305:	55                   	push   %ebp
  100306:	89 e5                	mov    %esp,%ebp
  100308:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10030b:	8b 45 08             	mov    0x8(%ebp),%eax
  10030e:	89 04 24             	mov    %eax,(%esp)
  100311:	e8 19 13 00 00       	call   10162f <cons_putc>
    (*cnt) ++;
  100316:	8b 45 0c             	mov    0xc(%ebp),%eax
  100319:	8b 00                	mov    (%eax),%eax
  10031b:	8d 50 01             	lea    0x1(%eax),%edx
  10031e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100321:	89 10                	mov    %edx,(%eax)
}
  100323:	c9                   	leave  
  100324:	c3                   	ret    

00100325 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100325:	55                   	push   %ebp
  100326:	89 e5                	mov    %esp,%ebp
  100328:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10032b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100332:	8b 45 0c             	mov    0xc(%ebp),%eax
  100335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100339:	8b 45 08             	mov    0x8(%ebp),%eax
  10033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100343:	89 44 24 04          	mov    %eax,0x4(%esp)
  100347:	c7 04 24 05 03 10 00 	movl   $0x100305,(%esp)
  10034e:	e8 69 54 00 00       	call   1057bc <vprintfmt>
    return cnt;
  100353:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100356:	c9                   	leave  
  100357:	c3                   	ret    

00100358 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100358:	55                   	push   %ebp
  100359:	89 e5                	mov    %esp,%ebp
  10035b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035e:	8d 45 0c             	lea    0xc(%ebp),%eax
  100361:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100367:	89 44 24 04          	mov    %eax,0x4(%esp)
  10036b:	8b 45 08             	mov    0x8(%ebp),%eax
  10036e:	89 04 24             	mov    %eax,(%esp)
  100371:	e8 af ff ff ff       	call   100325 <vcprintf>
  100376:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100379:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037c:	c9                   	leave  
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 a0 12 00 00       	call   10162f <cons_putc>
}
  10038f:	c9                   	leave  
  100390:	c3                   	ret    

00100391 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100391:	55                   	push   %ebp
  100392:	89 e5                	mov    %esp,%ebp
  100394:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100397:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10039e:	eb 13                	jmp    1003b3 <cputs+0x22>
        cputch(c, &cnt);
  1003a0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a4:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ab:	89 04 24             	mov    %eax,(%esp)
  1003ae:	e8 52 ff ff ff       	call   100305 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b6:	8d 50 01             	lea    0x1(%eax),%edx
  1003b9:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bc:	0f b6 00             	movzbl (%eax),%eax
  1003bf:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c6:	75 d8                	jne    1003a0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003cf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d6:	e8 2a ff ff ff       	call   100305 <cputch>
    return cnt;
  1003db:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003de:	c9                   	leave  
  1003df:	c3                   	ret    

001003e0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e0:	55                   	push   %ebp
  1003e1:	89 e5                	mov    %esp,%ebp
  1003e3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003e6:	e8 80 12 00 00       	call   10166b <cons_getc>
  1003eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f2:	74 f2                	je     1003e6 <getchar+0x6>
        /* do nothing */;
    return c;
  1003f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003f7:	c9                   	leave  
  1003f8:	c3                   	ret    

001003f9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003f9:	55                   	push   %ebp
  1003fa:	89 e5                	mov    %esp,%ebp
  1003fc:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100402:	8b 00                	mov    (%eax),%eax
  100404:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100407:	8b 45 10             	mov    0x10(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10040f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100416:	e9 d2 00 00 00       	jmp    1004ed <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10041b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10041e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100421:	01 d0                	add    %edx,%eax
  100423:	89 c2                	mov    %eax,%edx
  100425:	c1 ea 1f             	shr    $0x1f,%edx
  100428:	01 d0                	add    %edx,%eax
  10042a:	d1 f8                	sar    %eax
  10042c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10042f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100432:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100435:	eb 04                	jmp    10043b <stab_binsearch+0x42>
            m --;
  100437:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10043e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100441:	7c 1f                	jl     100462 <stab_binsearch+0x69>
  100443:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100446:	89 d0                	mov    %edx,%eax
  100448:	01 c0                	add    %eax,%eax
  10044a:	01 d0                	add    %edx,%eax
  10044c:	c1 e0 02             	shl    $0x2,%eax
  10044f:	89 c2                	mov    %eax,%edx
  100451:	8b 45 08             	mov    0x8(%ebp),%eax
  100454:	01 d0                	add    %edx,%eax
  100456:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10045a:	0f b6 c0             	movzbl %al,%eax
  10045d:	3b 45 14             	cmp    0x14(%ebp),%eax
  100460:	75 d5                	jne    100437 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100465:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100468:	7d 0b                	jge    100475 <stab_binsearch+0x7c>
            l = true_m + 1;
  10046a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10046d:	83 c0 01             	add    $0x1,%eax
  100470:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100473:	eb 78                	jmp    1004ed <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100475:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10047c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10047f:	89 d0                	mov    %edx,%eax
  100481:	01 c0                	add    %eax,%eax
  100483:	01 d0                	add    %edx,%eax
  100485:	c1 e0 02             	shl    $0x2,%eax
  100488:	89 c2                	mov    %eax,%edx
  10048a:	8b 45 08             	mov    0x8(%ebp),%eax
  10048d:	01 d0                	add    %edx,%eax
  10048f:	8b 40 08             	mov    0x8(%eax),%eax
  100492:	3b 45 18             	cmp    0x18(%ebp),%eax
  100495:	73 13                	jae    1004aa <stab_binsearch+0xb1>
            *region_left = m;
  100497:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10049f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a2:	83 c0 01             	add    $0x1,%eax
  1004a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a8:	eb 43                	jmp    1004ed <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  1004aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ad:	89 d0                	mov    %edx,%eax
  1004af:	01 c0                	add    %eax,%eax
  1004b1:	01 d0                	add    %edx,%eax
  1004b3:	c1 e0 02             	shl    $0x2,%eax
  1004b6:	89 c2                	mov    %eax,%edx
  1004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004bb:	01 d0                	add    %edx,%eax
  1004bd:	8b 40 08             	mov    0x8(%eax),%eax
  1004c0:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004c3:	76 16                	jbe    1004db <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004ce:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d3:	83 e8 01             	sub    $0x1,%eax
  1004d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d9:	eb 12                	jmp    1004ed <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004e9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 22 ff ff ff    	jle    10041b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
  10050c:	eb 3f                	jmp    10054d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 04                	jmp    10051c <stab_binsearch+0x123>
  100518:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051f:	8b 00                	mov    (%eax),%eax
  100521:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100524:	7d 1f                	jge    100545 <stab_binsearch+0x14c>
  100526:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100529:	89 d0                	mov    %edx,%eax
  10052b:	01 c0                	add    %eax,%eax
  10052d:	01 d0                	add    %edx,%eax
  10052f:	c1 e0 02             	shl    $0x2,%eax
  100532:	89 c2                	mov    %eax,%edx
  100534:	8b 45 08             	mov    0x8(%ebp),%eax
  100537:	01 d0                	add    %edx,%eax
  100539:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053d:	0f b6 c0             	movzbl %al,%eax
  100540:	3b 45 14             	cmp    0x14(%ebp),%eax
  100543:	75 d3                	jne    100518 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100545:	8b 45 0c             	mov    0xc(%ebp),%eax
  100548:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054b:	89 10                	mov    %edx,(%eax)
    }
}
  10054d:	c9                   	leave  
  10054e:	c3                   	ret    

0010054f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10054f:	55                   	push   %ebp
  100550:	89 e5                	mov    %esp,%ebp
  100552:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100555:	8b 45 0c             	mov    0xc(%ebp),%eax
  100558:	c7 00 ec 61 10 00    	movl   $0x1061ec,(%eax)
    info->eip_line = 0;
  10055e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100561:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100568:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056b:	c7 40 08 ec 61 10 00 	movl   $0x1061ec,0x8(%eax)
    info->eip_fn_namelen = 9;
  100572:	8b 45 0c             	mov    0xc(%ebp),%eax
  100575:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057f:	8b 55 08             	mov    0x8(%ebp),%edx
  100582:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100585:	8b 45 0c             	mov    0xc(%ebp),%eax
  100588:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10058f:	c7 45 f4 a0 74 10 00 	movl   $0x1074a0,-0xc(%ebp)
    stab_end = __STAB_END__;
  100596:	c7 45 f0 b0 21 11 00 	movl   $0x1121b0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059d:	c7 45 ec b1 21 11 00 	movl   $0x1121b1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a4:	c7 45 e8 38 4c 11 00 	movl   $0x114c38,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b1:	76 0d                	jbe    1005c0 <debuginfo_eip+0x71>
  1005b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b6:	83 e8 01             	sub    $0x1,%eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x7b>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 c0 02 00 00       	jmp    10088a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d7:	29 c2                	sub    %eax,%edx
  1005d9:	89 d0                	mov    %edx,%eax
  1005db:	c1 f8 02             	sar    $0x2,%eax
  1005de:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e4:	83 e8 01             	sub    $0x1,%eax
  1005e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005f1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f8:	00 
  1005f9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  100600:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100603:	89 44 24 04          	mov    %eax,0x4(%esp)
  100607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10060a:	89 04 24             	mov    %eax,(%esp)
  10060d:	e8 e7 fd ff ff       	call   1003f9 <stab_binsearch>
    if (lfile == 0)
  100612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100615:	85 c0                	test   %eax,%eax
  100617:	75 0a                	jne    100623 <debuginfo_eip+0xd4>
        return -1;
  100619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10061e:	e9 67 02 00 00       	jmp    10088a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100626:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100629:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10062f:	8b 45 08             	mov    0x8(%ebp),%eax
  100632:	89 44 24 10          	mov    %eax,0x10(%esp)
  100636:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10063d:	00 
  10063e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100641:	89 44 24 08          	mov    %eax,0x8(%esp)
  100645:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100648:	89 44 24 04          	mov    %eax,0x4(%esp)
  10064c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10064f:	89 04 24             	mov    %eax,(%esp)
  100652:	e8 a2 fd ff ff       	call   1003f9 <stab_binsearch>

    if (lfun <= rfun) {
  100657:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10065a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10065d:	39 c2                	cmp    %eax,%edx
  10065f:	7f 7c                	jg     1006dd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100661:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100664:	89 c2                	mov    %eax,%edx
  100666:	89 d0                	mov    %edx,%eax
  100668:	01 c0                	add    %eax,%eax
  10066a:	01 d0                	add    %edx,%eax
  10066c:	c1 e0 02             	shl    $0x2,%eax
  10066f:	89 c2                	mov    %eax,%edx
  100671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100674:	01 d0                	add    %edx,%eax
  100676:	8b 10                	mov    (%eax),%edx
  100678:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10067b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10067e:	29 c1                	sub    %eax,%ecx
  100680:	89 c8                	mov    %ecx,%eax
  100682:	39 c2                	cmp    %eax,%edx
  100684:	73 22                	jae    1006a8 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100686:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100689:	89 c2                	mov    %eax,%edx
  10068b:	89 d0                	mov    %edx,%eax
  10068d:	01 c0                	add    %eax,%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	c1 e0 02             	shl    $0x2,%eax
  100694:	89 c2                	mov    %eax,%edx
  100696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100699:	01 d0                	add    %edx,%eax
  10069b:	8b 10                	mov    (%eax),%edx
  10069d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1006a0:	01 c2                	add    %eax,%edx
  1006a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a5:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1006a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006ab:	89 c2                	mov    %eax,%edx
  1006ad:	89 d0                	mov    %edx,%eax
  1006af:	01 c0                	add    %eax,%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	c1 e0 02             	shl    $0x2,%eax
  1006b6:	89 c2                	mov    %eax,%edx
  1006b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006bb:	01 d0                	add    %edx,%eax
  1006bd:	8b 50 08             	mov    0x8(%eax),%edx
  1006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c9:	8b 40 10             	mov    0x10(%eax),%eax
  1006cc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006db:	eb 15                	jmp    1006f2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006e3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006f5:	8b 40 08             	mov    0x8(%eax),%eax
  1006f8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ff:	00 
  100700:	89 04 24             	mov    %eax,(%esp)
  100703:	e8 0f 57 00 00       	call   105e17 <strfind>
  100708:	89 c2                	mov    %eax,%edx
  10070a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070d:	8b 40 08             	mov    0x8(%eax),%eax
  100710:	29 c2                	sub    %eax,%edx
  100712:	8b 45 0c             	mov    0xc(%ebp),%eax
  100715:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100718:	8b 45 08             	mov    0x8(%ebp),%eax
  10071b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10071f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100726:	00 
  100727:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10072a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10072e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100731:	89 44 24 04          	mov    %eax,0x4(%esp)
  100735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100738:	89 04 24             	mov    %eax,(%esp)
  10073b:	e8 b9 fc ff ff       	call   1003f9 <stab_binsearch>
    if (lline <= rline) {
  100740:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100743:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100746:	39 c2                	cmp    %eax,%edx
  100748:	7f 24                	jg     10076e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  10074a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10074d:	89 c2                	mov    %eax,%edx
  10074f:	89 d0                	mov    %edx,%eax
  100751:	01 c0                	add    %eax,%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	c1 e0 02             	shl    $0x2,%eax
  100758:	89 c2                	mov    %eax,%edx
  10075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075d:	01 d0                	add    %edx,%eax
  10075f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100763:	0f b7 d0             	movzwl %ax,%edx
  100766:	8b 45 0c             	mov    0xc(%ebp),%eax
  100769:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10076c:	eb 13                	jmp    100781 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10076e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100773:	e9 12 01 00 00       	jmp    10088a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077b:	83 e8 01             	sub    $0x1,%eax
  10077e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100781:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100787:	39 c2                	cmp    %eax,%edx
  100789:	7c 56                	jl     1007e1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10078b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10078e:	89 c2                	mov    %eax,%edx
  100790:	89 d0                	mov    %edx,%eax
  100792:	01 c0                	add    %eax,%eax
  100794:	01 d0                	add    %edx,%eax
  100796:	c1 e0 02             	shl    $0x2,%eax
  100799:	89 c2                	mov    %eax,%edx
  10079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10079e:	01 d0                	add    %edx,%eax
  1007a0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007a4:	3c 84                	cmp    $0x84,%al
  1007a6:	74 39                	je     1007e1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ab:	89 c2                	mov    %eax,%edx
  1007ad:	89 d0                	mov    %edx,%eax
  1007af:	01 c0                	add    %eax,%eax
  1007b1:	01 d0                	add    %edx,%eax
  1007b3:	c1 e0 02             	shl    $0x2,%eax
  1007b6:	89 c2                	mov    %eax,%edx
  1007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bb:	01 d0                	add    %edx,%eax
  1007bd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007c1:	3c 64                	cmp    $0x64,%al
  1007c3:	75 b3                	jne    100778 <debuginfo_eip+0x229>
  1007c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007c8:	89 c2                	mov    %eax,%edx
  1007ca:	89 d0                	mov    %edx,%eax
  1007cc:	01 c0                	add    %eax,%eax
  1007ce:	01 d0                	add    %edx,%eax
  1007d0:	c1 e0 02             	shl    $0x2,%eax
  1007d3:	89 c2                	mov    %eax,%edx
  1007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007d8:	01 d0                	add    %edx,%eax
  1007da:	8b 40 08             	mov    0x8(%eax),%eax
  1007dd:	85 c0                	test   %eax,%eax
  1007df:	74 97                	je     100778 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e7:	39 c2                	cmp    %eax,%edx
  1007e9:	7c 46                	jl     100831 <debuginfo_eip+0x2e2>
  1007eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ee:	89 c2                	mov    %eax,%edx
  1007f0:	89 d0                	mov    %edx,%eax
  1007f2:	01 c0                	add    %eax,%eax
  1007f4:	01 d0                	add    %edx,%eax
  1007f6:	c1 e0 02             	shl    $0x2,%eax
  1007f9:	89 c2                	mov    %eax,%edx
  1007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fe:	01 d0                	add    %edx,%eax
  100800:	8b 10                	mov    (%eax),%edx
  100802:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100805:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100808:	29 c1                	sub    %eax,%ecx
  10080a:	89 c8                	mov    %ecx,%eax
  10080c:	39 c2                	cmp    %eax,%edx
  10080e:	73 21                	jae    100831 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100810:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100813:	89 c2                	mov    %eax,%edx
  100815:	89 d0                	mov    %edx,%eax
  100817:	01 c0                	add    %eax,%eax
  100819:	01 d0                	add    %edx,%eax
  10081b:	c1 e0 02             	shl    $0x2,%eax
  10081e:	89 c2                	mov    %eax,%edx
  100820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100823:	01 d0                	add    %edx,%eax
  100825:	8b 10                	mov    (%eax),%edx
  100827:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10082a:	01 c2                	add    %eax,%edx
  10082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100831:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100834:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100837:	39 c2                	cmp    %eax,%edx
  100839:	7d 4a                	jge    100885 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10083b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10083e:	83 c0 01             	add    $0x1,%eax
  100841:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100844:	eb 18                	jmp    10085e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100846:	8b 45 0c             	mov    0xc(%ebp),%eax
  100849:	8b 40 14             	mov    0x14(%eax),%eax
  10084c:	8d 50 01             	lea    0x1(%eax),%edx
  10084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100852:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100855:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100858:	83 c0 01             	add    $0x1,%eax
  10085b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10085e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100861:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100864:	39 c2                	cmp    %eax,%edx
  100866:	7d 1d                	jge    100885 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10086b:	89 c2                	mov    %eax,%edx
  10086d:	89 d0                	mov    %edx,%eax
  10086f:	01 c0                	add    %eax,%eax
  100871:	01 d0                	add    %edx,%eax
  100873:	c1 e0 02             	shl    $0x2,%eax
  100876:	89 c2                	mov    %eax,%edx
  100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10087b:	01 d0                	add    %edx,%eax
  10087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100881:	3c a0                	cmp    $0xa0,%al
  100883:	74 c1                	je     100846 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10088a:	c9                   	leave  
  10088b:	c3                   	ret    

0010088c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10088c:	55                   	push   %ebp
  10088d:	89 e5                	mov    %esp,%ebp
  10088f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100892:	c7 04 24 f6 61 10 00 	movl   $0x1061f6,(%esp)
  100899:	e8 ba fa ff ff       	call   100358 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10089e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1008a5:	00 
  1008a6:	c7 04 24 0f 62 10 00 	movl   $0x10620f,(%esp)
  1008ad:	e8 a6 fa ff ff       	call   100358 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008b2:	c7 44 24 04 2c 61 10 	movl   $0x10612c,0x4(%esp)
  1008b9:	00 
  1008ba:	c7 04 24 27 62 10 00 	movl   $0x106227,(%esp)
  1008c1:	e8 92 fa ff ff       	call   100358 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008c6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008cd:	00 
  1008ce:	c7 04 24 3f 62 10 00 	movl   $0x10623f,(%esp)
  1008d5:	e8 7e fa ff ff       	call   100358 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008da:	c7 44 24 04 88 af 11 	movl   $0x11af88,0x4(%esp)
  1008e1:	00 
  1008e2:	c7 04 24 57 62 10 00 	movl   $0x106257,(%esp)
  1008e9:	e8 6a fa ff ff       	call   100358 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008ee:	b8 88 af 11 00       	mov    $0x11af88,%eax
  1008f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008fe:	29 c2                	sub    %eax,%edx
  100900:	89 d0                	mov    %edx,%eax
  100902:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100908:	85 c0                	test   %eax,%eax
  10090a:	0f 48 c2             	cmovs  %edx,%eax
  10090d:	c1 f8 0a             	sar    $0xa,%eax
  100910:	89 44 24 04          	mov    %eax,0x4(%esp)
  100914:	c7 04 24 70 62 10 00 	movl   $0x106270,(%esp)
  10091b:	e8 38 fa ff ff       	call   100358 <cprintf>
}
  100920:	c9                   	leave  
  100921:	c3                   	ret    

00100922 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100922:	55                   	push   %ebp
  100923:	89 e5                	mov    %esp,%ebp
  100925:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10092b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100932:	8b 45 08             	mov    0x8(%ebp),%eax
  100935:	89 04 24             	mov    %eax,(%esp)
  100938:	e8 12 fc ff ff       	call   10054f <debuginfo_eip>
  10093d:	85 c0                	test   %eax,%eax
  10093f:	74 15                	je     100956 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100941:	8b 45 08             	mov    0x8(%ebp),%eax
  100944:	89 44 24 04          	mov    %eax,0x4(%esp)
  100948:	c7 04 24 9a 62 10 00 	movl   $0x10629a,(%esp)
  10094f:	e8 04 fa ff ff       	call   100358 <cprintf>
  100954:	eb 6d                	jmp    1009c3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10095d:	eb 1c                	jmp    10097b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10095f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100965:	01 d0                	add    %edx,%eax
  100967:	0f b6 00             	movzbl (%eax),%eax
  10096a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100970:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100973:	01 ca                	add    %ecx,%edx
  100975:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100977:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10097b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10097e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100981:	7f dc                	jg     10095f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100983:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100989:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10098c:	01 d0                	add    %edx,%eax
  10098e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100991:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100994:	8b 55 08             	mov    0x8(%ebp),%edx
  100997:	89 d1                	mov    %edx,%ecx
  100999:	29 c1                	sub    %eax,%ecx
  10099b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10099e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1009a1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1009a5:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009ab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1009af:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b7:	c7 04 24 b6 62 10 00 	movl   $0x1062b6,(%esp)
  1009be:	e8 95 f9 ff ff       	call   100358 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009c3:	c9                   	leave  
  1009c4:	c3                   	ret    

001009c5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009cb:	8b 45 04             	mov    0x4(%ebp),%eax
  1009ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009d4:	c9                   	leave  
  1009d5:	c3                   	ret    

001009d6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009d6:	55                   	push   %ebp
  1009d7:	89 e5                	mov    %esp,%ebp
  1009d9:	53                   	push   %ebx
  1009da:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009dd:	89 e8                	mov    %ebp,%eax
  1009df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
   uint32_t ebp=read_ebp();
  1009e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip=read_eip();
  1009e8:	e8 d8 ff ff ff       	call   1009c5 <read_eip>
  1009ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;// from 0 .. STACKFRAME_DEPTH
	for (i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  1009f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009f7:	e9 8d 00 00 00       	jmp    100a89 <print_stackframe+0xb3>
		// printf value of ebp, eip
		cprintf("ebp:0x%08x eip:0x%08x",ebp,eip);
  1009fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a0a:	c7 04 24 c8 62 10 00 	movl   $0x1062c8,(%esp)
  100a11:	e8 42 f9 ff ff       	call   100358 <cprintf>
//
		uint32_t *tmp=(uint32_t *)ebp+2;
  100a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a19:	83 c0 08             	add    $0x8,%eax
  100a1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
//每个数组大小为4，输出数组元素
		cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x",*(tmp+0),*(tmp+1),*(tmp+2),*(tmp+3));
  100a1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a22:	83 c0 0c             	add    $0xc,%eax
  100a25:	8b 18                	mov    (%eax),%ebx
  100a27:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2a:	83 c0 08             	add    $0x8,%eax
  100a2d:	8b 08                	mov    (%eax),%ecx
  100a2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a32:	83 c0 04             	add    $0x4,%eax
  100a35:	8b 10                	mov    (%eax),%edx
  100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a3a:	8b 00                	mov    (%eax),%eax
  100a3c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a40:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a44:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a4c:	c7 04 24 e0 62 10 00 	movl   $0x1062e0,(%esp)
  100a53:	e8 00 f9 ff ff       	call   100358 <cprintf>

		cprintf("\n");
  100a58:	c7 04 24 01 63 10 00 	movl   $0x106301,(%esp)
  100a5f:	e8 f4 f8 ff ff       	call   100358 <cprintf>

//eip指向异常指令的下一条指令，所以要减1
		print_debuginfo(eip-1);
  100a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a67:	83 e8 01             	sub    $0x1,%eax
  100a6a:	89 04 24             	mov    %eax,(%esp)
  100a6d:	e8 b0 fe ff ff       	call   100922 <print_debuginfo>

 // 将ebp 和eip设置为上一个栈帧的ebp和eip
 //  注意要先设置eip后设置ebp，否则当ebp被修改后，eip就无法找到正确的位置
		eip=((uint32_t *)ebp)[1];//popup a calling stackframe
  100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a75:	83 c0 04             	add    $0x4,%eax
  100a78:	8b 00                	mov    (%eax),%eax
  100a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp=((uint32_t *)ebp)[0];
  100a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a80:	8b 00                	mov    (%eax),%eax
  100a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
   uint32_t ebp=read_ebp();
	uint32_t eip=read_eip();
	int i;// from 0 .. STACKFRAME_DEPTH
	for (i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100a85:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a89:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a8d:	7f 0a                	jg     100a99 <print_stackframe+0xc3>
  100a8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a93:	0f 85 63 ff ff ff    	jne    1009fc <print_stackframe+0x26>
 // 将ebp 和eip设置为上一个栈帧的ebp和eip
 //  注意要先设置eip后设置ebp，否则当ebp被修改后，eip就无法找到正确的位置
		eip=((uint32_t *)ebp)[1];//popup a calling stackframe
		ebp=((uint32_t *)ebp)[0];
	}
}
  100a99:	83 c4 44             	add    $0x44,%esp
  100a9c:	5b                   	pop    %ebx
  100a9d:	5d                   	pop    %ebp
  100a9e:	c3                   	ret    

00100a9f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a9f:	55                   	push   %ebp
  100aa0:	89 e5                	mov    %esp,%ebp
  100aa2:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aac:	eb 0c                	jmp    100aba <parse+0x1b>
            *buf ++ = '\0';
  100aae:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab1:	8d 50 01             	lea    0x1(%eax),%edx
  100ab4:	89 55 08             	mov    %edx,0x8(%ebp)
  100ab7:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aba:	8b 45 08             	mov    0x8(%ebp),%eax
  100abd:	0f b6 00             	movzbl (%eax),%eax
  100ac0:	84 c0                	test   %al,%al
  100ac2:	74 1d                	je     100ae1 <parse+0x42>
  100ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ac7:	0f b6 00             	movzbl (%eax),%eax
  100aca:	0f be c0             	movsbl %al,%eax
  100acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad1:	c7 04 24 84 63 10 00 	movl   $0x106384,(%esp)
  100ad8:	e8 07 53 00 00       	call   105de4 <strchr>
  100add:	85 c0                	test   %eax,%eax
  100adf:	75 cd                	jne    100aae <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae4:	0f b6 00             	movzbl (%eax),%eax
  100ae7:	84 c0                	test   %al,%al
  100ae9:	75 02                	jne    100aed <parse+0x4e>
            break;
  100aeb:	eb 67                	jmp    100b54 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100aed:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100af1:	75 14                	jne    100b07 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100af3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100afa:	00 
  100afb:	c7 04 24 89 63 10 00 	movl   $0x106389,(%esp)
  100b02:	e8 51 f8 ff ff       	call   100358 <cprintf>
        }
        argv[argc ++] = buf;
  100b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b0a:	8d 50 01             	lea    0x1(%eax),%edx
  100b0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b1a:	01 c2                	add    %eax,%edx
  100b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1f:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b21:	eb 04                	jmp    100b27 <parse+0x88>
            buf ++;
  100b23:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b27:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2a:	0f b6 00             	movzbl (%eax),%eax
  100b2d:	84 c0                	test   %al,%al
  100b2f:	74 1d                	je     100b4e <parse+0xaf>
  100b31:	8b 45 08             	mov    0x8(%ebp),%eax
  100b34:	0f b6 00             	movzbl (%eax),%eax
  100b37:	0f be c0             	movsbl %al,%eax
  100b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b3e:	c7 04 24 84 63 10 00 	movl   $0x106384,(%esp)
  100b45:	e8 9a 52 00 00       	call   105de4 <strchr>
  100b4a:	85 c0                	test   %eax,%eax
  100b4c:	74 d5                	je     100b23 <parse+0x84>
            buf ++;
        }
    }
  100b4e:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4f:	e9 66 ff ff ff       	jmp    100aba <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b57:	c9                   	leave  
  100b58:	c3                   	ret    

00100b59 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b59:	55                   	push   %ebp
  100b5a:	89 e5                	mov    %esp,%ebp
  100b5c:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b5f:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b66:	8b 45 08             	mov    0x8(%ebp),%eax
  100b69:	89 04 24             	mov    %eax,(%esp)
  100b6c:	e8 2e ff ff ff       	call   100a9f <parse>
  100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b78:	75 0a                	jne    100b84 <runcmd+0x2b>
        return 0;
  100b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  100b7f:	e9 85 00 00 00       	jmp    100c09 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b8b:	eb 5c                	jmp    100be9 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b8d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b93:	89 d0                	mov    %edx,%eax
  100b95:	01 c0                	add    %eax,%eax
  100b97:	01 d0                	add    %edx,%eax
  100b99:	c1 e0 02             	shl    $0x2,%eax
  100b9c:	05 00 70 11 00       	add    $0x117000,%eax
  100ba1:	8b 00                	mov    (%eax),%eax
  100ba3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ba7:	89 04 24             	mov    %eax,(%esp)
  100baa:	e8 96 51 00 00       	call   105d45 <strcmp>
  100baf:	85 c0                	test   %eax,%eax
  100bb1:	75 32                	jne    100be5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100bb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bb6:	89 d0                	mov    %edx,%eax
  100bb8:	01 c0                	add    %eax,%eax
  100bba:	01 d0                	add    %edx,%eax
  100bbc:	c1 e0 02             	shl    $0x2,%eax
  100bbf:	05 00 70 11 00       	add    $0x117000,%eax
  100bc4:	8b 40 08             	mov    0x8(%eax),%eax
  100bc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bca:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bd0:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bd4:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bd7:	83 c2 04             	add    $0x4,%edx
  100bda:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bde:	89 0c 24             	mov    %ecx,(%esp)
  100be1:	ff d0                	call   *%eax
  100be3:	eb 24                	jmp    100c09 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bec:	83 f8 02             	cmp    $0x2,%eax
  100bef:	76 9c                	jbe    100b8d <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bf1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bf8:	c7 04 24 a7 63 10 00 	movl   $0x1063a7,(%esp)
  100bff:	e8 54 f7 ff ff       	call   100358 <cprintf>
    return 0;
  100c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c09:	c9                   	leave  
  100c0a:	c3                   	ret    

00100c0b <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c0b:	55                   	push   %ebp
  100c0c:	89 e5                	mov    %esp,%ebp
  100c0e:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c11:	c7 04 24 c0 63 10 00 	movl   $0x1063c0,(%esp)
  100c18:	e8 3b f7 ff ff       	call   100358 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c1d:	c7 04 24 e8 63 10 00 	movl   $0x1063e8,(%esp)
  100c24:	e8 2f f7 ff ff       	call   100358 <cprintf>

    if (tf != NULL) {
  100c29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c2d:	74 0b                	je     100c3a <kmonitor+0x2f>
        print_trapframe(tf);
  100c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  100c32:	89 04 24             	mov    %eax,(%esp)
  100c35:	e8 67 0e 00 00       	call   101aa1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c3a:	c7 04 24 0d 64 10 00 	movl   $0x10640d,(%esp)
  100c41:	e8 09 f6 ff ff       	call   10024f <readline>
  100c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c4d:	74 18                	je     100c67 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  100c52:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c59:	89 04 24             	mov    %eax,(%esp)
  100c5c:	e8 f8 fe ff ff       	call   100b59 <runcmd>
  100c61:	85 c0                	test   %eax,%eax
  100c63:	79 02                	jns    100c67 <kmonitor+0x5c>
                break;
  100c65:	eb 02                	jmp    100c69 <kmonitor+0x5e>
            }
        }
    }
  100c67:	eb d1                	jmp    100c3a <kmonitor+0x2f>
}
  100c69:	c9                   	leave  
  100c6a:	c3                   	ret    

00100c6b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c6b:	55                   	push   %ebp
  100c6c:	89 e5                	mov    %esp,%ebp
  100c6e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c78:	eb 3f                	jmp    100cb9 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c7d:	89 d0                	mov    %edx,%eax
  100c7f:	01 c0                	add    %eax,%eax
  100c81:	01 d0                	add    %edx,%eax
  100c83:	c1 e0 02             	shl    $0x2,%eax
  100c86:	05 00 70 11 00       	add    $0x117000,%eax
  100c8b:	8b 48 04             	mov    0x4(%eax),%ecx
  100c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c91:	89 d0                	mov    %edx,%eax
  100c93:	01 c0                	add    %eax,%eax
  100c95:	01 d0                	add    %edx,%eax
  100c97:	c1 e0 02             	shl    $0x2,%eax
  100c9a:	05 00 70 11 00       	add    $0x117000,%eax
  100c9f:	8b 00                	mov    (%eax),%eax
  100ca1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ca9:	c7 04 24 11 64 10 00 	movl   $0x106411,(%esp)
  100cb0:	e8 a3 f6 ff ff       	call   100358 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cbc:	83 f8 02             	cmp    $0x2,%eax
  100cbf:	76 b9                	jbe    100c7a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc6:	c9                   	leave  
  100cc7:	c3                   	ret    

00100cc8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cc8:	55                   	push   %ebp
  100cc9:	89 e5                	mov    %esp,%ebp
  100ccb:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cce:	e8 b9 fb ff ff       	call   10088c <print_kerninfo>
    return 0;
  100cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd8:	c9                   	leave  
  100cd9:	c3                   	ret    

00100cda <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cda:	55                   	push   %ebp
  100cdb:	89 e5                	mov    %esp,%ebp
  100cdd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ce0:	e8 f1 fc ff ff       	call   1009d6 <print_stackframe>
    return 0;
  100ce5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cea:	c9                   	leave  
  100ceb:	c3                   	ret    

00100cec <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cec:	55                   	push   %ebp
  100ced:	89 e5                	mov    %esp,%ebp
  100cef:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cf2:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100cf7:	85 c0                	test   %eax,%eax
  100cf9:	74 02                	je     100cfd <__panic+0x11>
        goto panic_dead;
  100cfb:	eb 59                	jmp    100d56 <__panic+0x6a>
    }
    is_panic = 1;
  100cfd:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100d04:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d07:	8d 45 14             	lea    0x14(%ebp),%eax
  100d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d10:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d14:	8b 45 08             	mov    0x8(%ebp),%eax
  100d17:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1b:	c7 04 24 1a 64 10 00 	movl   $0x10641a,(%esp)
  100d22:	e8 31 f6 ff ff       	call   100358 <cprintf>
    vcprintf(fmt, ap);
  100d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d2e:	8b 45 10             	mov    0x10(%ebp),%eax
  100d31:	89 04 24             	mov    %eax,(%esp)
  100d34:	e8 ec f5 ff ff       	call   100325 <vcprintf>
    cprintf("\n");
  100d39:	c7 04 24 36 64 10 00 	movl   $0x106436,(%esp)
  100d40:	e8 13 f6 ff ff       	call   100358 <cprintf>
    
    cprintf("stack trackback:\n");
  100d45:	c7 04 24 38 64 10 00 	movl   $0x106438,(%esp)
  100d4c:	e8 07 f6 ff ff       	call   100358 <cprintf>
    print_stackframe();
  100d51:	e8 80 fc ff ff       	call   1009d6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d56:	e8 85 09 00 00       	call   1016e0 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d62:	e8 a4 fe ff ff       	call   100c0b <kmonitor>
    }
  100d67:	eb f2                	jmp    100d5b <__panic+0x6f>

00100d69 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d69:	55                   	push   %ebp
  100d6a:	89 e5                	mov    %esp,%ebp
  100d6c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d6f:	8d 45 14             	lea    0x14(%ebp),%eax
  100d72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d78:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  100d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d83:	c7 04 24 4a 64 10 00 	movl   $0x10644a,(%esp)
  100d8a:	e8 c9 f5 ff ff       	call   100358 <cprintf>
    vcprintf(fmt, ap);
  100d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d92:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d96:	8b 45 10             	mov    0x10(%ebp),%eax
  100d99:	89 04 24             	mov    %eax,(%esp)
  100d9c:	e8 84 f5 ff ff       	call   100325 <vcprintf>
    cprintf("\n");
  100da1:	c7 04 24 36 64 10 00 	movl   $0x106436,(%esp)
  100da8:	e8 ab f5 ff ff       	call   100358 <cprintf>
    va_end(ap);
}
  100dad:	c9                   	leave  
  100dae:	c3                   	ret    

00100daf <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100daf:	55                   	push   %ebp
  100db0:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100db2:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100db7:	5d                   	pop    %ebp
  100db8:	c3                   	ret    

00100db9 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100db9:	55                   	push   %ebp
  100dba:	89 e5                	mov    %esp,%ebp
  100dbc:	83 ec 28             	sub    $0x28,%esp
  100dbf:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dc5:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dc9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dcd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dd1:	ee                   	out    %al,(%dx)
  100dd2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dd8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100ddc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100de0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100de4:	ee                   	out    %al,(%dx)
  100de5:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100deb:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100def:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100df3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100df7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100df8:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100dff:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e02:	c7 04 24 68 64 10 00 	movl   $0x106468,(%esp)
  100e09:	e8 4a f5 ff ff       	call   100358 <cprintf>
    pic_enable(IRQ_TIMER);
  100e0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e15:	e8 24 09 00 00       	call   10173e <pic_enable>
}
  100e1a:	c9                   	leave  
  100e1b:	c3                   	ret    

00100e1c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e1c:	55                   	push   %ebp
  100e1d:	89 e5                	mov    %esp,%ebp
  100e1f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e22:	9c                   	pushf  
  100e23:	58                   	pop    %eax
  100e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e2a:	25 00 02 00 00       	and    $0x200,%eax
  100e2f:	85 c0                	test   %eax,%eax
  100e31:	74 0c                	je     100e3f <__intr_save+0x23>
        intr_disable();
  100e33:	e8 a8 08 00 00       	call   1016e0 <intr_disable>
        return 1;
  100e38:	b8 01 00 00 00       	mov    $0x1,%eax
  100e3d:	eb 05                	jmp    100e44 <__intr_save+0x28>
    }
    return 0;
  100e3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e44:	c9                   	leave  
  100e45:	c3                   	ret    

00100e46 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e46:	55                   	push   %ebp
  100e47:	89 e5                	mov    %esp,%ebp
  100e49:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e50:	74 05                	je     100e57 <__intr_restore+0x11>
        intr_enable();
  100e52:	e8 83 08 00 00       	call   1016da <intr_enable>
    }
}
  100e57:	c9                   	leave  
  100e58:	c3                   	ret    

00100e59 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e59:	55                   	push   %ebp
  100e5a:	89 e5                	mov    %esp,%ebp
  100e5c:	83 ec 10             	sub    $0x10,%esp
  100e5f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e65:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e69:	89 c2                	mov    %eax,%edx
  100e6b:	ec                   	in     (%dx),%al
  100e6c:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e6f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e75:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e79:	89 c2                	mov    %eax,%edx
  100e7b:	ec                   	in     (%dx),%al
  100e7c:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e7f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e85:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e89:	89 c2                	mov    %eax,%edx
  100e8b:	ec                   	in     (%dx),%al
  100e8c:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e8f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e95:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e99:	89 c2                	mov    %eax,%edx
  100e9b:	ec                   	in     (%dx),%al
  100e9c:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e9f:	c9                   	leave  
  100ea0:	c3                   	ret    

00100ea1 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ea1:	55                   	push   %ebp
  100ea2:	89 e5                	mov    %esp,%ebp
  100ea4:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100ea7:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb1:	0f b7 00             	movzwl (%eax),%eax
  100eb4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebb:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ec0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec3:	0f b7 00             	movzwl (%eax),%eax
  100ec6:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eca:	74 12                	je     100ede <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ecc:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ed3:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100eda:	b4 03 
  100edc:	eb 13                	jmp    100ef1 <cga_init+0x50>
    } else {
        *cp = was;
  100ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ee5:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee8:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100eef:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ef1:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef8:	0f b7 c0             	movzwl %ax,%eax
  100efb:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100eff:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f03:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f07:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f0b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100f0c:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f13:	83 c0 01             	add    $0x1,%eax
  100f16:	0f b7 c0             	movzwl %ax,%eax
  100f19:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f1d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f21:	89 c2                	mov    %eax,%edx
  100f23:	ec                   	in     (%dx),%al
  100f24:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f27:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f2b:	0f b6 c0             	movzbl %al,%eax
  100f2e:	c1 e0 08             	shl    $0x8,%eax
  100f31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f34:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f3b:	0f b7 c0             	movzwl %ax,%eax
  100f3e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f42:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f46:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f4a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f4e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f4f:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f56:	83 c0 01             	add    $0x1,%eax
  100f59:	0f b7 c0             	movzwl %ax,%eax
  100f5c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f60:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f64:	89 c2                	mov    %eax,%edx
  100f66:	ec                   	in     (%dx),%al
  100f67:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f6a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f6e:	0f b6 c0             	movzbl %al,%eax
  100f71:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f77:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7f:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f85:	c9                   	leave  
  100f86:	c3                   	ret    

00100f87 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f87:	55                   	push   %ebp
  100f88:	89 e5                	mov    %esp,%ebp
  100f8a:	83 ec 48             	sub    $0x48,%esp
  100f8d:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f93:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f97:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f9b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f9f:	ee                   	out    %al,(%dx)
  100fa0:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100fa6:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100faa:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100fae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100fb2:	ee                   	out    %al,(%dx)
  100fb3:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100fb9:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fbd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fc1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fc5:	ee                   	out    %al,(%dx)
  100fc6:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fcc:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fd0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fd4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fd8:	ee                   	out    %al,(%dx)
  100fd9:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fdf:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fe3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fe7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100feb:	ee                   	out    %al,(%dx)
  100fec:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100ff2:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100ff6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100ffa:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ffe:	ee                   	out    %al,(%dx)
  100fff:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  101005:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  101009:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10100d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101011:	ee                   	out    %al,(%dx)
  101012:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101018:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  10101c:	89 c2                	mov    %eax,%edx
  10101e:	ec                   	in     (%dx),%al
  10101f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101022:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101026:	3c ff                	cmp    $0xff,%al
  101028:	0f 95 c0             	setne  %al
  10102b:	0f b6 c0             	movzbl %al,%eax
  10102e:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101033:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101039:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  10103d:	89 c2                	mov    %eax,%edx
  10103f:	ec                   	in     (%dx),%al
  101040:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101043:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  101049:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  10104d:	89 c2                	mov    %eax,%edx
  10104f:	ec                   	in     (%dx),%al
  101050:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101053:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101058:	85 c0                	test   %eax,%eax
  10105a:	74 0c                	je     101068 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10105c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101063:	e8 d6 06 00 00       	call   10173e <pic_enable>
    }
}
  101068:	c9                   	leave  
  101069:	c3                   	ret    

0010106a <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10106a:	55                   	push   %ebp
  10106b:	89 e5                	mov    %esp,%ebp
  10106d:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101070:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101077:	eb 09                	jmp    101082 <lpt_putc_sub+0x18>
        delay();
  101079:	e8 db fd ff ff       	call   100e59 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10107e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101082:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101088:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10108c:	89 c2                	mov    %eax,%edx
  10108e:	ec                   	in     (%dx),%al
  10108f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101092:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101096:	84 c0                	test   %al,%al
  101098:	78 09                	js     1010a3 <lpt_putc_sub+0x39>
  10109a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010a1:	7e d6                	jle    101079 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  1010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a6:	0f b6 c0             	movzbl %al,%eax
  1010a9:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  1010af:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010b2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010b6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010ba:	ee                   	out    %al,(%dx)
  1010bb:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010c1:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010c5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010c9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010cd:	ee                   	out    %al,(%dx)
  1010ce:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010d4:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010d8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010dc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010e0:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010e1:	c9                   	leave  
  1010e2:	c3                   	ret    

001010e3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010e3:	55                   	push   %ebp
  1010e4:	89 e5                	mov    %esp,%ebp
  1010e6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010e9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010ed:	74 0d                	je     1010fc <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f2:	89 04 24             	mov    %eax,(%esp)
  1010f5:	e8 70 ff ff ff       	call   10106a <lpt_putc_sub>
  1010fa:	eb 24                	jmp    101120 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010fc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101103:	e8 62 ff ff ff       	call   10106a <lpt_putc_sub>
        lpt_putc_sub(' ');
  101108:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10110f:	e8 56 ff ff ff       	call   10106a <lpt_putc_sub>
        lpt_putc_sub('\b');
  101114:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10111b:	e8 4a ff ff ff       	call   10106a <lpt_putc_sub>
    }
}
  101120:	c9                   	leave  
  101121:	c3                   	ret    

00101122 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101122:	55                   	push   %ebp
  101123:	89 e5                	mov    %esp,%ebp
  101125:	53                   	push   %ebx
  101126:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101129:	8b 45 08             	mov    0x8(%ebp),%eax
  10112c:	b0 00                	mov    $0x0,%al
  10112e:	85 c0                	test   %eax,%eax
  101130:	75 07                	jne    101139 <cga_putc+0x17>
        c |= 0x0700;
  101132:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101139:	8b 45 08             	mov    0x8(%ebp),%eax
  10113c:	0f b6 c0             	movzbl %al,%eax
  10113f:	83 f8 0a             	cmp    $0xa,%eax
  101142:	74 4c                	je     101190 <cga_putc+0x6e>
  101144:	83 f8 0d             	cmp    $0xd,%eax
  101147:	74 57                	je     1011a0 <cga_putc+0x7e>
  101149:	83 f8 08             	cmp    $0x8,%eax
  10114c:	0f 85 88 00 00 00    	jne    1011da <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101152:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101159:	66 85 c0             	test   %ax,%ax
  10115c:	74 30                	je     10118e <cga_putc+0x6c>
            crt_pos --;
  10115e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101165:	83 e8 01             	sub    $0x1,%eax
  101168:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10116e:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101173:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10117a:	0f b7 d2             	movzwl %dx,%edx
  10117d:	01 d2                	add    %edx,%edx
  10117f:	01 c2                	add    %eax,%edx
  101181:	8b 45 08             	mov    0x8(%ebp),%eax
  101184:	b0 00                	mov    $0x0,%al
  101186:	83 c8 20             	or     $0x20,%eax
  101189:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10118c:	eb 72                	jmp    101200 <cga_putc+0xde>
  10118e:	eb 70                	jmp    101200 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101190:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101197:	83 c0 50             	add    $0x50,%eax
  10119a:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011a0:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  1011a7:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  1011ae:	0f b7 c1             	movzwl %cx,%eax
  1011b1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1011b7:	c1 e8 10             	shr    $0x10,%eax
  1011ba:	89 c2                	mov    %eax,%edx
  1011bc:	66 c1 ea 06          	shr    $0x6,%dx
  1011c0:	89 d0                	mov    %edx,%eax
  1011c2:	c1 e0 02             	shl    $0x2,%eax
  1011c5:	01 d0                	add    %edx,%eax
  1011c7:	c1 e0 04             	shl    $0x4,%eax
  1011ca:	29 c1                	sub    %eax,%ecx
  1011cc:	89 ca                	mov    %ecx,%edx
  1011ce:	89 d8                	mov    %ebx,%eax
  1011d0:	29 d0                	sub    %edx,%eax
  1011d2:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011d8:	eb 26                	jmp    101200 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011da:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011e0:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011e7:	8d 50 01             	lea    0x1(%eax),%edx
  1011ea:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011f1:	0f b7 c0             	movzwl %ax,%eax
  1011f4:	01 c0                	add    %eax,%eax
  1011f6:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1011fc:	66 89 02             	mov    %ax,(%edx)
        break;
  1011ff:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101200:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101207:	66 3d cf 07          	cmp    $0x7cf,%ax
  10120b:	76 5b                	jbe    101268 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10120d:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101212:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101218:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10121d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101224:	00 
  101225:	89 54 24 04          	mov    %edx,0x4(%esp)
  101229:	89 04 24             	mov    %eax,(%esp)
  10122c:	e8 b1 4d 00 00       	call   105fe2 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101231:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101238:	eb 15                	jmp    10124f <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10123a:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10123f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101242:	01 d2                	add    %edx,%edx
  101244:	01 d0                	add    %edx,%eax
  101246:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10124b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10124f:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101256:	7e e2                	jle    10123a <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101258:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10125f:	83 e8 50             	sub    $0x50,%eax
  101262:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101268:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10126f:	0f b7 c0             	movzwl %ax,%eax
  101272:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101276:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10127a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10127e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101282:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101283:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10128a:	66 c1 e8 08          	shr    $0x8,%ax
  10128e:	0f b6 c0             	movzbl %al,%eax
  101291:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101298:	83 c2 01             	add    $0x1,%edx
  10129b:	0f b7 d2             	movzwl %dx,%edx
  10129e:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  1012a2:	88 45 ed             	mov    %al,-0x13(%ebp)
  1012a5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012a9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012ae:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  1012b5:	0f b7 c0             	movzwl %ax,%eax
  1012b8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012bc:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012c0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012c4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012c8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012c9:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012d0:	0f b6 c0             	movzbl %al,%eax
  1012d3:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012da:	83 c2 01             	add    $0x1,%edx
  1012dd:	0f b7 d2             	movzwl %dx,%edx
  1012e0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012e4:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012e7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012eb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012ef:	ee                   	out    %al,(%dx)
}
  1012f0:	83 c4 34             	add    $0x34,%esp
  1012f3:	5b                   	pop    %ebx
  1012f4:	5d                   	pop    %ebp
  1012f5:	c3                   	ret    

001012f6 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012f6:	55                   	push   %ebp
  1012f7:	89 e5                	mov    %esp,%ebp
  1012f9:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101303:	eb 09                	jmp    10130e <serial_putc_sub+0x18>
        delay();
  101305:	e8 4f fb ff ff       	call   100e59 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10130a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10130e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101314:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101318:	89 c2                	mov    %eax,%edx
  10131a:	ec                   	in     (%dx),%al
  10131b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10131e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101322:	0f b6 c0             	movzbl %al,%eax
  101325:	83 e0 20             	and    $0x20,%eax
  101328:	85 c0                	test   %eax,%eax
  10132a:	75 09                	jne    101335 <serial_putc_sub+0x3f>
  10132c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101333:	7e d0                	jle    101305 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101335:	8b 45 08             	mov    0x8(%ebp),%eax
  101338:	0f b6 c0             	movzbl %al,%eax
  10133b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101341:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101344:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101348:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10134c:	ee                   	out    %al,(%dx)
}
  10134d:	c9                   	leave  
  10134e:	c3                   	ret    

0010134f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10134f:	55                   	push   %ebp
  101350:	89 e5                	mov    %esp,%ebp
  101352:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101355:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101359:	74 0d                	je     101368 <serial_putc+0x19>
        serial_putc_sub(c);
  10135b:	8b 45 08             	mov    0x8(%ebp),%eax
  10135e:	89 04 24             	mov    %eax,(%esp)
  101361:	e8 90 ff ff ff       	call   1012f6 <serial_putc_sub>
  101366:	eb 24                	jmp    10138c <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101368:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136f:	e8 82 ff ff ff       	call   1012f6 <serial_putc_sub>
        serial_putc_sub(' ');
  101374:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10137b:	e8 76 ff ff ff       	call   1012f6 <serial_putc_sub>
        serial_putc_sub('\b');
  101380:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101387:	e8 6a ff ff ff       	call   1012f6 <serial_putc_sub>
    }
}
  10138c:	c9                   	leave  
  10138d:	c3                   	ret    

0010138e <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10138e:	55                   	push   %ebp
  10138f:	89 e5                	mov    %esp,%ebp
  101391:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101394:	eb 33                	jmp    1013c9 <cons_intr+0x3b>
        if (c != 0) {
  101396:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10139a:	74 2d                	je     1013c9 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10139c:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013a1:	8d 50 01             	lea    0x1(%eax),%edx
  1013a4:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  1013aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013ad:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013b3:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013b8:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013bd:	75 0a                	jne    1013c9 <cons_intr+0x3b>
                cons.wpos = 0;
  1013bf:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013c6:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1013cc:	ff d0                	call   *%eax
  1013ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013d1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013d5:	75 bf                	jne    101396 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013d7:	c9                   	leave  
  1013d8:	c3                   	ret    

001013d9 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013d9:	55                   	push   %ebp
  1013da:	89 e5                	mov    %esp,%ebp
  1013dc:	83 ec 10             	sub    $0x10,%esp
  1013df:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013e9:	89 c2                	mov    %eax,%edx
  1013eb:	ec                   	in     (%dx),%al
  1013ec:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013ef:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013f3:	0f b6 c0             	movzbl %al,%eax
  1013f6:	83 e0 01             	and    $0x1,%eax
  1013f9:	85 c0                	test   %eax,%eax
  1013fb:	75 07                	jne    101404 <serial_proc_data+0x2b>
        return -1;
  1013fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101402:	eb 2a                	jmp    10142e <serial_proc_data+0x55>
  101404:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10140a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10140e:	89 c2                	mov    %eax,%edx
  101410:	ec                   	in     (%dx),%al
  101411:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101414:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101418:	0f b6 c0             	movzbl %al,%eax
  10141b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10141e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101422:	75 07                	jne    10142b <serial_proc_data+0x52>
        c = '\b';
  101424:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10142b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10142e:	c9                   	leave  
  10142f:	c3                   	ret    

00101430 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101430:	55                   	push   %ebp
  101431:	89 e5                	mov    %esp,%ebp
  101433:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101436:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10143b:	85 c0                	test   %eax,%eax
  10143d:	74 0c                	je     10144b <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10143f:	c7 04 24 d9 13 10 00 	movl   $0x1013d9,(%esp)
  101446:	e8 43 ff ff ff       	call   10138e <cons_intr>
    }
}
  10144b:	c9                   	leave  
  10144c:	c3                   	ret    

0010144d <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10144d:	55                   	push   %ebp
  10144e:	89 e5                	mov    %esp,%ebp
  101450:	83 ec 38             	sub    $0x38,%esp
  101453:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101459:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10145d:	89 c2                	mov    %eax,%edx
  10145f:	ec                   	in     (%dx),%al
  101460:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101463:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101467:	0f b6 c0             	movzbl %al,%eax
  10146a:	83 e0 01             	and    $0x1,%eax
  10146d:	85 c0                	test   %eax,%eax
  10146f:	75 0a                	jne    10147b <kbd_proc_data+0x2e>
        return -1;
  101471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101476:	e9 59 01 00 00       	jmp    1015d4 <kbd_proc_data+0x187>
  10147b:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101481:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101485:	89 c2                	mov    %eax,%edx
  101487:	ec                   	in     (%dx),%al
  101488:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10148b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10148f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101492:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101496:	75 17                	jne    1014af <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101498:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10149d:	83 c8 40             	or     $0x40,%eax
  1014a0:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014a5:	b8 00 00 00 00       	mov    $0x0,%eax
  1014aa:	e9 25 01 00 00       	jmp    1015d4 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1014af:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b3:	84 c0                	test   %al,%al
  1014b5:	79 47                	jns    1014fe <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014b7:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014bc:	83 e0 40             	and    $0x40,%eax
  1014bf:	85 c0                	test   %eax,%eax
  1014c1:	75 09                	jne    1014cc <kbd_proc_data+0x7f>
  1014c3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c7:	83 e0 7f             	and    $0x7f,%eax
  1014ca:	eb 04                	jmp    1014d0 <kbd_proc_data+0x83>
  1014cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d0:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d7:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014de:	83 c8 40             	or     $0x40,%eax
  1014e1:	0f b6 c0             	movzbl %al,%eax
  1014e4:	f7 d0                	not    %eax
  1014e6:	89 c2                	mov    %eax,%edx
  1014e8:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014ed:	21 d0                	and    %edx,%eax
  1014ef:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014f4:	b8 00 00 00 00       	mov    $0x0,%eax
  1014f9:	e9 d6 00 00 00       	jmp    1015d4 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014fe:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101503:	83 e0 40             	and    $0x40,%eax
  101506:	85 c0                	test   %eax,%eax
  101508:	74 11                	je     10151b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10150a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10150e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101513:	83 e0 bf             	and    $0xffffffbf,%eax
  101516:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  10151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151f:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  101526:	0f b6 d0             	movzbl %al,%edx
  101529:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152e:	09 d0                	or     %edx,%eax
  101530:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101535:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101539:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101540:	0f b6 d0             	movzbl %al,%edx
  101543:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101548:	31 d0                	xor    %edx,%eax
  10154a:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  10154f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101554:	83 e0 03             	and    $0x3,%eax
  101557:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  10155e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101562:	01 d0                	add    %edx,%eax
  101564:	0f b6 00             	movzbl (%eax),%eax
  101567:	0f b6 c0             	movzbl %al,%eax
  10156a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  10156d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101572:	83 e0 08             	and    $0x8,%eax
  101575:	85 c0                	test   %eax,%eax
  101577:	74 22                	je     10159b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101579:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10157d:	7e 0c                	jle    10158b <kbd_proc_data+0x13e>
  10157f:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101583:	7f 06                	jg     10158b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101585:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101589:	eb 10                	jmp    10159b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10158b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10158f:	7e 0a                	jle    10159b <kbd_proc_data+0x14e>
  101591:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101595:	7f 04                	jg     10159b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101597:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10159b:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1015a0:	f7 d0                	not    %eax
  1015a2:	83 e0 06             	and    $0x6,%eax
  1015a5:	85 c0                	test   %eax,%eax
  1015a7:	75 28                	jne    1015d1 <kbd_proc_data+0x184>
  1015a9:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015b0:	75 1f                	jne    1015d1 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1015b2:	c7 04 24 83 64 10 00 	movl   $0x106483,(%esp)
  1015b9:	e8 9a ed ff ff       	call   100358 <cprintf>
  1015be:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015c4:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015c8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015cc:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015d0:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015d4:	c9                   	leave  
  1015d5:	c3                   	ret    

001015d6 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015d6:	55                   	push   %ebp
  1015d7:	89 e5                	mov    %esp,%ebp
  1015d9:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015dc:	c7 04 24 4d 14 10 00 	movl   $0x10144d,(%esp)
  1015e3:	e8 a6 fd ff ff       	call   10138e <cons_intr>
}
  1015e8:	c9                   	leave  
  1015e9:	c3                   	ret    

001015ea <kbd_init>:

static void
kbd_init(void) {
  1015ea:	55                   	push   %ebp
  1015eb:	89 e5                	mov    %esp,%ebp
  1015ed:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015f0:	e8 e1 ff ff ff       	call   1015d6 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015fc:	e8 3d 01 00 00       	call   10173e <pic_enable>
}
  101601:	c9                   	leave  
  101602:	c3                   	ret    

00101603 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101603:	55                   	push   %ebp
  101604:	89 e5                	mov    %esp,%ebp
  101606:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101609:	e8 93 f8 ff ff       	call   100ea1 <cga_init>
    serial_init();
  10160e:	e8 74 f9 ff ff       	call   100f87 <serial_init>
    kbd_init();
  101613:	e8 d2 ff ff ff       	call   1015ea <kbd_init>
    if (!serial_exists) {
  101618:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10161d:	85 c0                	test   %eax,%eax
  10161f:	75 0c                	jne    10162d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101621:	c7 04 24 8f 64 10 00 	movl   $0x10648f,(%esp)
  101628:	e8 2b ed ff ff       	call   100358 <cprintf>
    }
}
  10162d:	c9                   	leave  
  10162e:	c3                   	ret    

0010162f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10162f:	55                   	push   %ebp
  101630:	89 e5                	mov    %esp,%ebp
  101632:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101635:	e8 e2 f7 ff ff       	call   100e1c <__intr_save>
  10163a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10163d:	8b 45 08             	mov    0x8(%ebp),%eax
  101640:	89 04 24             	mov    %eax,(%esp)
  101643:	e8 9b fa ff ff       	call   1010e3 <lpt_putc>
        cga_putc(c);
  101648:	8b 45 08             	mov    0x8(%ebp),%eax
  10164b:	89 04 24             	mov    %eax,(%esp)
  10164e:	e8 cf fa ff ff       	call   101122 <cga_putc>
        serial_putc(c);
  101653:	8b 45 08             	mov    0x8(%ebp),%eax
  101656:	89 04 24             	mov    %eax,(%esp)
  101659:	e8 f1 fc ff ff       	call   10134f <serial_putc>
    }
    local_intr_restore(intr_flag);
  10165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101661:	89 04 24             	mov    %eax,(%esp)
  101664:	e8 dd f7 ff ff       	call   100e46 <__intr_restore>
}
  101669:	c9                   	leave  
  10166a:	c3                   	ret    

0010166b <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10166b:	55                   	push   %ebp
  10166c:	89 e5                	mov    %esp,%ebp
  10166e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101678:	e8 9f f7 ff ff       	call   100e1c <__intr_save>
  10167d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101680:	e8 ab fd ff ff       	call   101430 <serial_intr>
        kbd_intr();
  101685:	e8 4c ff ff ff       	call   1015d6 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10168a:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101690:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101695:	39 c2                	cmp    %eax,%edx
  101697:	74 31                	je     1016ca <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101699:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169e:	8d 50 01             	lea    0x1(%eax),%edx
  1016a1:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  1016a7:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  1016ae:	0f b6 c0             	movzbl %al,%eax
  1016b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016b4:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1016b9:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016be:	75 0a                	jne    1016ca <cons_getc+0x5f>
                cons.rpos = 0;
  1016c0:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016c7:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016cd:	89 04 24             	mov    %eax,(%esp)
  1016d0:	e8 71 f7 ff ff       	call   100e46 <__intr_restore>
    return c;
  1016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016d8:	c9                   	leave  
  1016d9:	c3                   	ret    

001016da <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016da:	55                   	push   %ebp
  1016db:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016dd:	fb                   	sti    
    sti();
}
  1016de:	5d                   	pop    %ebp
  1016df:	c3                   	ret    

001016e0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016e0:	55                   	push   %ebp
  1016e1:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016e3:	fa                   	cli    
    cli();
}
  1016e4:	5d                   	pop    %ebp
  1016e5:	c3                   	ret    

001016e6 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016e6:	55                   	push   %ebp
  1016e7:	89 e5                	mov    %esp,%ebp
  1016e9:	83 ec 14             	sub    $0x14,%esp
  1016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f7:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016fd:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  101702:	85 c0                	test   %eax,%eax
  101704:	74 36                	je     10173c <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101706:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10170a:	0f b6 c0             	movzbl %al,%eax
  10170d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101713:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101716:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10171a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10171e:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10171f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101723:	66 c1 e8 08          	shr    $0x8,%ax
  101727:	0f b6 c0             	movzbl %al,%eax
  10172a:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101730:	88 45 f9             	mov    %al,-0x7(%ebp)
  101733:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101737:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10173b:	ee                   	out    %al,(%dx)
    }
}
  10173c:	c9                   	leave  
  10173d:	c3                   	ret    

0010173e <pic_enable>:

void
pic_enable(unsigned int irq) {
  10173e:	55                   	push   %ebp
  10173f:	89 e5                	mov    %esp,%ebp
  101741:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101744:	8b 45 08             	mov    0x8(%ebp),%eax
  101747:	ba 01 00 00 00       	mov    $0x1,%edx
  10174c:	89 c1                	mov    %eax,%ecx
  10174e:	d3 e2                	shl    %cl,%edx
  101750:	89 d0                	mov    %edx,%eax
  101752:	f7 d0                	not    %eax
  101754:	89 c2                	mov    %eax,%edx
  101756:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10175d:	21 d0                	and    %edx,%eax
  10175f:	0f b7 c0             	movzwl %ax,%eax
  101762:	89 04 24             	mov    %eax,(%esp)
  101765:	e8 7c ff ff ff       	call   1016e6 <pic_setmask>
}
  10176a:	c9                   	leave  
  10176b:	c3                   	ret    

0010176c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10176c:	55                   	push   %ebp
  10176d:	89 e5                	mov    %esp,%ebp
  10176f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101772:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  101779:	00 00 00 
  10177c:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101782:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  101786:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10178a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10178e:	ee                   	out    %al,(%dx)
  10178f:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101795:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  101799:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10179d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017a1:	ee                   	out    %al,(%dx)
  1017a2:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1017a8:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1017ac:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017b0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017b4:	ee                   	out    %al,(%dx)
  1017b5:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017bb:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017bf:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017c3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017c7:	ee                   	out    %al,(%dx)
  1017c8:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017ce:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017d2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017d6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017da:	ee                   	out    %al,(%dx)
  1017db:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017e1:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017e5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017e9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017ed:	ee                   	out    %al,(%dx)
  1017ee:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017f4:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017f8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017fc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101800:	ee                   	out    %al,(%dx)
  101801:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101807:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  10180b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10180f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101813:	ee                   	out    %al,(%dx)
  101814:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  10181a:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  10181e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101822:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101826:	ee                   	out    %al,(%dx)
  101827:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  10182d:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101831:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101835:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101839:	ee                   	out    %al,(%dx)
  10183a:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101840:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101844:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101848:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10184c:	ee                   	out    %al,(%dx)
  10184d:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101853:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101857:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10185b:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10185f:	ee                   	out    %al,(%dx)
  101860:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  101866:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  10186a:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10186e:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101872:	ee                   	out    %al,(%dx)
  101873:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  101879:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  10187d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101881:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101885:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101886:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10188d:	66 83 f8 ff          	cmp    $0xffff,%ax
  101891:	74 12                	je     1018a5 <pic_init+0x139>
        pic_setmask(irq_mask);
  101893:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10189a:	0f b7 c0             	movzwl %ax,%eax
  10189d:	89 04 24             	mov    %eax,(%esp)
  1018a0:	e8 41 fe ff ff       	call   1016e6 <pic_setmask>
    }
}
  1018a5:	c9                   	leave  
  1018a6:	c3                   	ret    

001018a7 <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  1018a7:	55                   	push   %ebp
  1018a8:	89 e5                	mov    %esp,%ebp
  1018aa:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018ad:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018b4:	00 
  1018b5:	c7 04 24 c0 64 10 00 	movl   $0x1064c0,(%esp)
  1018bc:	e8 97 ea ff ff       	call   100358 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018c1:	c7 04 24 ca 64 10 00 	movl   $0x1064ca,(%esp)
  1018c8:	e8 8b ea ff ff       	call   100358 <cprintf>
    panic("EOT: kernel seems ok.");
  1018cd:	c7 44 24 08 d8 64 10 	movl   $0x1064d8,0x8(%esp)
  1018d4:	00 
  1018d5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018dc:	00 
  1018dd:	c7 04 24 ee 64 10 00 	movl   $0x1064ee,(%esp)
  1018e4:	e8 03 f4 ff ff       	call   100cec <__panic>

001018e9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018e9:	55                   	push   %ebp
  1018ea:	89 e5                	mov    %esp,%ebp
  1018ec:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018f6:	e9 c3 00 00 00       	jmp    1019be <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fe:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101905:	89 c2                	mov    %eax,%edx
  101907:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190a:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  101911:	00 
  101912:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101915:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  10191c:	00 08 00 
  10191f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101922:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101929:	00 
  10192a:	83 e2 e0             	and    $0xffffffe0,%edx
  10192d:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101934:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101937:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10193e:	00 
  10193f:	83 e2 1f             	and    $0x1f,%edx
  101942:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101949:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194c:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101953:	00 
  101954:	83 e2 f0             	and    $0xfffffff0,%edx
  101957:	83 ca 0e             	or     $0xe,%edx
  10195a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101964:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10196b:	00 
  10196c:	83 e2 ef             	and    $0xffffffef,%edx
  10196f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101976:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101979:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101980:	00 
  101981:	83 e2 9f             	and    $0xffffff9f,%edx
  101984:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10198b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101995:	00 
  101996:	83 ca 80             	or     $0xffffff80,%edx
  101999:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  1019a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a3:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1019aa:	c1 e8 10             	shr    $0x10,%eax
  1019ad:	89 c2                	mov    %eax,%edx
  1019af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b2:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  1019b9:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1019ba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1019be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019c6:	0f 86 2f ff ff ff    	jbe    1018fb <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019cc:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019d1:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  1019d7:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  1019de:	08 00 
  1019e0:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019e7:	83 e0 e0             	and    $0xffffffe0,%eax
  1019ea:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019ef:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019f6:	83 e0 1f             	and    $0x1f,%eax
  1019f9:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019fe:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a05:	83 e0 f0             	and    $0xfffffff0,%eax
  101a08:	83 c8 0e             	or     $0xe,%eax
  101a0b:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a10:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a17:	83 e0 ef             	and    $0xffffffef,%eax
  101a1a:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a1f:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a26:	83 c8 60             	or     $0x60,%eax
  101a29:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a2e:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a35:	83 c8 80             	or     $0xffffff80,%eax
  101a38:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a3d:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a42:	c1 e8 10             	shr    $0x10,%eax
  101a45:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a4b:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a55:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
  101a58:	c9                   	leave  
  101a59:	c3                   	ret    

00101a5a <trapname>:

static const char *
trapname(int trapno) {
  101a5a:	55                   	push   %ebp
  101a5b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	83 f8 13             	cmp    $0x13,%eax
  101a63:	77 0c                	ja     101a71 <trapname+0x17>
        return excnames[trapno];
  101a65:	8b 45 08             	mov    0x8(%ebp),%eax
  101a68:	8b 04 85 40 68 10 00 	mov    0x106840(,%eax,4),%eax
  101a6f:	eb 18                	jmp    101a89 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a71:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a75:	7e 0d                	jle    101a84 <trapname+0x2a>
  101a77:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a7b:	7f 07                	jg     101a84 <trapname+0x2a>
        return "Hardware Interrupt";
  101a7d:	b8 ff 64 10 00       	mov    $0x1064ff,%eax
  101a82:	eb 05                	jmp    101a89 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a84:	b8 12 65 10 00       	mov    $0x106512,%eax
}
  101a89:	5d                   	pop    %ebp
  101a8a:	c3                   	ret    

00101a8b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a8b:	55                   	push   %ebp
  101a8c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a91:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a95:	66 83 f8 08          	cmp    $0x8,%ax
  101a99:	0f 94 c0             	sete   %al
  101a9c:	0f b6 c0             	movzbl %al,%eax
}
  101a9f:	5d                   	pop    %ebp
  101aa0:	c3                   	ret    

00101aa1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101aa1:	55                   	push   %ebp
  101aa2:	89 e5                	mov    %esp,%ebp
  101aa4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aae:	c7 04 24 53 65 10 00 	movl   $0x106553,(%esp)
  101ab5:	e8 9e e8 ff ff       	call   100358 <cprintf>
    print_regs(&tf->tf_regs);
  101aba:	8b 45 08             	mov    0x8(%ebp),%eax
  101abd:	89 04 24             	mov    %eax,(%esp)
  101ac0:	e8 a1 01 00 00       	call   101c66 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101acc:	0f b7 c0             	movzwl %ax,%eax
  101acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad3:	c7 04 24 64 65 10 00 	movl   $0x106564,(%esp)
  101ada:	e8 79 e8 ff ff       	call   100358 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101adf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ae6:	0f b7 c0             	movzwl %ax,%eax
  101ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aed:	c7 04 24 77 65 10 00 	movl   $0x106577,(%esp)
  101af4:	e8 5f e8 ff ff       	call   100358 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101af9:	8b 45 08             	mov    0x8(%ebp),%eax
  101afc:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b00:	0f b7 c0             	movzwl %ax,%eax
  101b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b07:	c7 04 24 8a 65 10 00 	movl   $0x10658a,(%esp)
  101b0e:	e8 45 e8 ff ff       	call   100358 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b13:	8b 45 08             	mov    0x8(%ebp),%eax
  101b16:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b1a:	0f b7 c0             	movzwl %ax,%eax
  101b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b21:	c7 04 24 9d 65 10 00 	movl   $0x10659d,(%esp)
  101b28:	e8 2b e8 ff ff       	call   100358 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b30:	8b 40 30             	mov    0x30(%eax),%eax
  101b33:	89 04 24             	mov    %eax,(%esp)
  101b36:	e8 1f ff ff ff       	call   101a5a <trapname>
  101b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  101b3e:	8b 52 30             	mov    0x30(%edx),%edx
  101b41:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b45:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b49:	c7 04 24 b0 65 10 00 	movl   $0x1065b0,(%esp)
  101b50:	e8 03 e8 ff ff       	call   100358 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b55:	8b 45 08             	mov    0x8(%ebp),%eax
  101b58:	8b 40 34             	mov    0x34(%eax),%eax
  101b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5f:	c7 04 24 c2 65 10 00 	movl   $0x1065c2,(%esp)
  101b66:	e8 ed e7 ff ff       	call   100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6e:	8b 40 38             	mov    0x38(%eax),%eax
  101b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b75:	c7 04 24 d1 65 10 00 	movl   $0x1065d1,(%esp)
  101b7c:	e8 d7 e7 ff ff       	call   100358 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b81:	8b 45 08             	mov    0x8(%ebp),%eax
  101b84:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b88:	0f b7 c0             	movzwl %ax,%eax
  101b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8f:	c7 04 24 e0 65 10 00 	movl   $0x1065e0,(%esp)
  101b96:	e8 bd e7 ff ff       	call   100358 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9e:	8b 40 40             	mov    0x40(%eax),%eax
  101ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba5:	c7 04 24 f3 65 10 00 	movl   $0x1065f3,(%esp)
  101bac:	e8 a7 e7 ff ff       	call   100358 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101bb8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101bbf:	eb 3e                	jmp    101bff <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc4:	8b 50 40             	mov    0x40(%eax),%edx
  101bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bca:	21 d0                	and    %edx,%eax
  101bcc:	85 c0                	test   %eax,%eax
  101bce:	74 28                	je     101bf8 <print_trapframe+0x157>
  101bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd3:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bda:	85 c0                	test   %eax,%eax
  101bdc:	74 1a                	je     101bf8 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101be1:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bec:	c7 04 24 02 66 10 00 	movl   $0x106602,(%esp)
  101bf3:	e8 60 e7 ff ff       	call   100358 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bf8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bfc:	d1 65 f0             	shll   -0x10(%ebp)
  101bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c02:	83 f8 17             	cmp    $0x17,%eax
  101c05:	76 ba                	jbe    101bc1 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c07:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0a:	8b 40 40             	mov    0x40(%eax),%eax
  101c0d:	25 00 30 00 00       	and    $0x3000,%eax
  101c12:	c1 e8 0c             	shr    $0xc,%eax
  101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c19:	c7 04 24 06 66 10 00 	movl   $0x106606,(%esp)
  101c20:	e8 33 e7 ff ff       	call   100358 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	89 04 24             	mov    %eax,(%esp)
  101c2b:	e8 5b fe ff ff       	call   101a8b <trap_in_kernel>
  101c30:	85 c0                	test   %eax,%eax
  101c32:	75 30                	jne    101c64 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c34:	8b 45 08             	mov    0x8(%ebp),%eax
  101c37:	8b 40 44             	mov    0x44(%eax),%eax
  101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3e:	c7 04 24 0f 66 10 00 	movl   $0x10660f,(%esp)
  101c45:	e8 0e e7 ff ff       	call   100358 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c51:	0f b7 c0             	movzwl %ax,%eax
  101c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c58:	c7 04 24 1e 66 10 00 	movl   $0x10661e,(%esp)
  101c5f:	e8 f4 e6 ff ff       	call   100358 <cprintf>
    }
}
  101c64:	c9                   	leave  
  101c65:	c3                   	ret    

00101c66 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c66:	55                   	push   %ebp
  101c67:	89 e5                	mov    %esp,%ebp
  101c69:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6f:	8b 00                	mov    (%eax),%eax
  101c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c75:	c7 04 24 31 66 10 00 	movl   $0x106631,(%esp)
  101c7c:	e8 d7 e6 ff ff       	call   100358 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c81:	8b 45 08             	mov    0x8(%ebp),%eax
  101c84:	8b 40 04             	mov    0x4(%eax),%eax
  101c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c8b:	c7 04 24 40 66 10 00 	movl   $0x106640,(%esp)
  101c92:	e8 c1 e6 ff ff       	call   100358 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c97:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9a:	8b 40 08             	mov    0x8(%eax),%eax
  101c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca1:	c7 04 24 4f 66 10 00 	movl   $0x10664f,(%esp)
  101ca8:	e8 ab e6 ff ff       	call   100358 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101cad:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb0:	8b 40 0c             	mov    0xc(%eax),%eax
  101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb7:	c7 04 24 5e 66 10 00 	movl   $0x10665e,(%esp)
  101cbe:	e8 95 e6 ff ff       	call   100358 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc6:	8b 40 10             	mov    0x10(%eax),%eax
  101cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccd:	c7 04 24 6d 66 10 00 	movl   $0x10666d,(%esp)
  101cd4:	e8 7f e6 ff ff       	call   100358 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdc:	8b 40 14             	mov    0x14(%eax),%eax
  101cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce3:	c7 04 24 7c 66 10 00 	movl   $0x10667c,(%esp)
  101cea:	e8 69 e6 ff ff       	call   100358 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cef:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf2:	8b 40 18             	mov    0x18(%eax),%eax
  101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf9:	c7 04 24 8b 66 10 00 	movl   $0x10668b,(%esp)
  101d00:	e8 53 e6 ff ff       	call   100358 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d05:	8b 45 08             	mov    0x8(%ebp),%eax
  101d08:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0f:	c7 04 24 9a 66 10 00 	movl   $0x10669a,(%esp)
  101d16:	e8 3d e6 ff ff       	call   100358 <cprintf>
}
  101d1b:	c9                   	leave  
  101d1c:	c3                   	ret    

00101d1d <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d1d:	55                   	push   %ebp
  101d1e:	89 e5                	mov    %esp,%ebp
  101d20:	57                   	push   %edi
  101d21:	56                   	push   %esi
  101d22:	53                   	push   %ebx
  101d23:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101d26:	8b 45 08             	mov    0x8(%ebp),%eax
  101d29:	8b 40 30             	mov    0x30(%eax),%eax
  101d2c:	83 f8 2f             	cmp    $0x2f,%eax
  101d2f:	77 21                	ja     101d52 <trap_dispatch+0x35>
  101d31:	83 f8 2e             	cmp    $0x2e,%eax
  101d34:	0f 83 ec 01 00 00    	jae    101f26 <trap_dispatch+0x209>
  101d3a:	83 f8 21             	cmp    $0x21,%eax
  101d3d:	0f 84 8a 00 00 00    	je     101dcd <trap_dispatch+0xb0>
  101d43:	83 f8 24             	cmp    $0x24,%eax
  101d46:	74 5c                	je     101da4 <trap_dispatch+0x87>
  101d48:	83 f8 20             	cmp    $0x20,%eax
  101d4b:	74 1c                	je     101d69 <trap_dispatch+0x4c>
  101d4d:	e9 9c 01 00 00       	jmp    101eee <trap_dispatch+0x1d1>
  101d52:	83 f8 78             	cmp    $0x78,%eax
  101d55:	0f 84 9b 00 00 00    	je     101df6 <trap_dispatch+0xd9>
  101d5b:	83 f8 79             	cmp    $0x79,%eax
  101d5e:	0f 84 11 01 00 00    	je     101e75 <trap_dispatch+0x158>
  101d64:	e9 85 01 00 00       	jmp    101eee <trap_dispatch+0x1d1>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101d69:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d6e:	83 c0 01             	add    $0x1,%eax
  101d71:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks % TICK_NUM == 0) {
  101d76:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d7c:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d81:	89 c8                	mov    %ecx,%eax
  101d83:	f7 e2                	mul    %edx
  101d85:	89 d0                	mov    %edx,%eax
  101d87:	c1 e8 05             	shr    $0x5,%eax
  101d8a:	6b c0 64             	imul   $0x64,%eax,%eax
  101d8d:	29 c1                	sub    %eax,%ecx
  101d8f:	89 c8                	mov    %ecx,%eax
  101d91:	85 c0                	test   %eax,%eax
  101d93:	75 0a                	jne    101d9f <trap_dispatch+0x82>
            print_ticks();
  101d95:	e8 0d fb ff ff       	call   1018a7 <print_ticks>
        }
        break;
  101d9a:	e9 88 01 00 00       	jmp    101f27 <trap_dispatch+0x20a>
  101d9f:	e9 83 01 00 00       	jmp    101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101da4:	e8 c2 f8 ff ff       	call   10166b <cons_getc>
  101da9:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101dac:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101db0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101db4:	89 54 24 08          	mov    %edx,0x8(%esp)
  101db8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dbc:	c7 04 24 a9 66 10 00 	movl   $0x1066a9,(%esp)
  101dc3:	e8 90 e5 ff ff       	call   100358 <cprintf>
        break;
  101dc8:	e9 5a 01 00 00       	jmp    101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dcd:	e8 99 f8 ff ff       	call   10166b <cons_getc>
  101dd2:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dd5:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101dd9:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101ddd:	89 54 24 08          	mov    %edx,0x8(%esp)
  101de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101de5:	c7 04 24 bb 66 10 00 	movl   $0x1066bb,(%esp)
  101dec:	e8 67 e5 ff ff       	call   100358 <cprintf>
        break;
  101df1:	e9 31 01 00 00       	jmp    101f27 <trap_dispatch+0x20a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101df6:	8b 45 08             	mov    0x8(%ebp),%eax
  101df9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dfd:	66 83 f8 1b          	cmp    $0x1b,%ax
  101e01:	74 6d                	je     101e70 <trap_dispatch+0x153>
            switchk2u = *tf;
  101e03:	8b 45 08             	mov    0x8(%ebp),%eax
  101e06:	ba 20 af 11 00       	mov    $0x11af20,%edx
  101e0b:	89 c3                	mov    %eax,%ebx
  101e0d:	b8 13 00 00 00       	mov    $0x13,%eax
  101e12:	89 d7                	mov    %edx,%edi
  101e14:	89 de                	mov    %ebx,%esi
  101e16:	89 c1                	mov    %eax,%ecx
  101e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101e1a:	66 c7 05 5c af 11 00 	movw   $0x1b,0x11af5c
  101e21:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101e23:	66 c7 05 68 af 11 00 	movw   $0x23,0x11af68
  101e2a:	23 00 
  101e2c:	0f b7 05 68 af 11 00 	movzwl 0x11af68,%eax
  101e33:	66 a3 48 af 11 00    	mov    %ax,0x11af48
  101e39:	0f b7 05 48 af 11 00 	movzwl 0x11af48,%eax
  101e40:	66 a3 4c af 11 00    	mov    %ax,0x11af4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;	
  101e46:	8b 45 08             	mov    0x8(%ebp),%eax
  101e49:	83 c0 44             	add    $0x44,%eax
  101e4c:	a3 64 af 11 00       	mov    %eax,0x11af64
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101e51:	a1 60 af 11 00       	mov    0x11af60,%eax
  101e56:	80 cc 30             	or     $0x30,%ah
  101e59:	a3 60 af 11 00       	mov    %eax,0x11af60
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e61:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e64:	b8 20 af 11 00       	mov    $0x11af20,%eax
  101e69:	89 02                	mov    %eax,(%edx)
        }
        break;
  101e6b:	e9 b7 00 00 00       	jmp    101f27 <trap_dispatch+0x20a>
  101e70:	e9 b2 00 00 00       	jmp    101f27 <trap_dispatch+0x20a>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  101e75:	8b 45 08             	mov    0x8(%ebp),%eax
  101e78:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e7c:	66 83 f8 08          	cmp    $0x8,%ax
  101e80:	74 6a                	je     101eec <trap_dispatch+0x1cf>
            tf->tf_cs = KERNEL_CS;
  101e82:	8b 45 08             	mov    0x8(%ebp),%eax
  101e85:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8e:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101e94:	8b 45 08             	mov    0x8(%ebp),%eax
  101e97:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea5:	8b 40 40             	mov    0x40(%eax),%eax
  101ea8:	80 e4 cf             	and    $0xcf,%ah
  101eab:	89 c2                	mov    %eax,%edx
  101ead:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb0:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb6:	8b 40 44             	mov    0x44(%eax),%eax
  101eb9:	83 e8 44             	sub    $0x44,%eax
  101ebc:	a3 6c af 11 00       	mov    %eax,0x11af6c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101ec1:	a1 6c af 11 00       	mov    0x11af6c,%eax
  101ec6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101ecd:	00 
  101ece:	8b 55 08             	mov    0x8(%ebp),%edx
  101ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
  101ed5:	89 04 24             	mov    %eax,(%esp)
  101ed8:	e8 05 41 00 00       	call   105fe2 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101edd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee0:	8d 50 fc             	lea    -0x4(%eax),%edx
  101ee3:	a1 6c af 11 00       	mov    0x11af6c,%eax
  101ee8:	89 02                	mov    %eax,(%edx)
        }
        break;
  101eea:	eb 3b                	jmp    101f27 <trap_dispatch+0x20a>
  101eec:	eb 39                	jmp    101f27 <trap_dispatch+0x20a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101eee:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ef5:	0f b7 c0             	movzwl %ax,%eax
  101ef8:	83 e0 03             	and    $0x3,%eax
  101efb:	85 c0                	test   %eax,%eax
  101efd:	75 28                	jne    101f27 <trap_dispatch+0x20a>
            print_trapframe(tf);
  101eff:	8b 45 08             	mov    0x8(%ebp),%eax
  101f02:	89 04 24             	mov    %eax,(%esp)
  101f05:	e8 97 fb ff ff       	call   101aa1 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f0a:	c7 44 24 08 ca 66 10 	movl   $0x1066ca,0x8(%esp)
  101f11:	00 
  101f12:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  101f19:	00 
  101f1a:	c7 04 24 ee 64 10 00 	movl   $0x1064ee,(%esp)
  101f21:	e8 c6 ed ff ff       	call   100cec <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101f26:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101f27:	83 c4 2c             	add    $0x2c,%esp
  101f2a:	5b                   	pop    %ebx
  101f2b:	5e                   	pop    %esi
  101f2c:	5f                   	pop    %edi
  101f2d:	5d                   	pop    %ebp
  101f2e:	c3                   	ret    

00101f2f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f2f:	55                   	push   %ebp
  101f30:	89 e5                	mov    %esp,%ebp
  101f32:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f35:	8b 45 08             	mov    0x8(%ebp),%eax
  101f38:	89 04 24             	mov    %eax,(%esp)
  101f3b:	e8 dd fd ff ff       	call   101d1d <trap_dispatch>
}
  101f40:	c9                   	leave  
  101f41:	c3                   	ret    

00101f42 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101f42:	1e                   	push   %ds
    pushl %es
  101f43:	06                   	push   %es
    pushl %fs
  101f44:	0f a0                	push   %fs
    pushl %gs
  101f46:	0f a8                	push   %gs
    pushal
  101f48:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101f49:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101f4e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101f50:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101f52:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101f53:	e8 d7 ff ff ff       	call   101f2f <trap>

    # pop the pushed stack pointer
    popl %esp
  101f58:	5c                   	pop    %esp

00101f59 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101f59:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101f5a:	0f a9                	pop    %gs
    popl %fs
  101f5c:	0f a1                	pop    %fs
    popl %es
  101f5e:	07                   	pop    %es
    popl %ds
  101f5f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101f60:	83 c4 08             	add    $0x8,%esp
    iret
  101f63:	cf                   	iret   

00101f64 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f64:	6a 00                	push   $0x0
  pushl $0
  101f66:	6a 00                	push   $0x0
  jmp __alltraps
  101f68:	e9 d5 ff ff ff       	jmp    101f42 <__alltraps>

00101f6d <vector1>:
.globl vector1
vector1:
  pushl $0
  101f6d:	6a 00                	push   $0x0
  pushl $1
  101f6f:	6a 01                	push   $0x1
  jmp __alltraps
  101f71:	e9 cc ff ff ff       	jmp    101f42 <__alltraps>

00101f76 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f76:	6a 00                	push   $0x0
  pushl $2
  101f78:	6a 02                	push   $0x2
  jmp __alltraps
  101f7a:	e9 c3 ff ff ff       	jmp    101f42 <__alltraps>

00101f7f <vector3>:
.globl vector3
vector3:
  pushl $0
  101f7f:	6a 00                	push   $0x0
  pushl $3
  101f81:	6a 03                	push   $0x3
  jmp __alltraps
  101f83:	e9 ba ff ff ff       	jmp    101f42 <__alltraps>

00101f88 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f88:	6a 00                	push   $0x0
  pushl $4
  101f8a:	6a 04                	push   $0x4
  jmp __alltraps
  101f8c:	e9 b1 ff ff ff       	jmp    101f42 <__alltraps>

00101f91 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f91:	6a 00                	push   $0x0
  pushl $5
  101f93:	6a 05                	push   $0x5
  jmp __alltraps
  101f95:	e9 a8 ff ff ff       	jmp    101f42 <__alltraps>

00101f9a <vector6>:
.globl vector6
vector6:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $6
  101f9c:	6a 06                	push   $0x6
  jmp __alltraps
  101f9e:	e9 9f ff ff ff       	jmp    101f42 <__alltraps>

00101fa3 <vector7>:
.globl vector7
vector7:
  pushl $0
  101fa3:	6a 00                	push   $0x0
  pushl $7
  101fa5:	6a 07                	push   $0x7
  jmp __alltraps
  101fa7:	e9 96 ff ff ff       	jmp    101f42 <__alltraps>

00101fac <vector8>:
.globl vector8
vector8:
  pushl $8
  101fac:	6a 08                	push   $0x8
  jmp __alltraps
  101fae:	e9 8f ff ff ff       	jmp    101f42 <__alltraps>

00101fb3 <vector9>:
.globl vector9
vector9:
  pushl $0
  101fb3:	6a 00                	push   $0x0
  pushl $9
  101fb5:	6a 09                	push   $0x9
  jmp __alltraps
  101fb7:	e9 86 ff ff ff       	jmp    101f42 <__alltraps>

00101fbc <vector10>:
.globl vector10
vector10:
  pushl $10
  101fbc:	6a 0a                	push   $0xa
  jmp __alltraps
  101fbe:	e9 7f ff ff ff       	jmp    101f42 <__alltraps>

00101fc3 <vector11>:
.globl vector11
vector11:
  pushl $11
  101fc3:	6a 0b                	push   $0xb
  jmp __alltraps
  101fc5:	e9 78 ff ff ff       	jmp    101f42 <__alltraps>

00101fca <vector12>:
.globl vector12
vector12:
  pushl $12
  101fca:	6a 0c                	push   $0xc
  jmp __alltraps
  101fcc:	e9 71 ff ff ff       	jmp    101f42 <__alltraps>

00101fd1 <vector13>:
.globl vector13
vector13:
  pushl $13
  101fd1:	6a 0d                	push   $0xd
  jmp __alltraps
  101fd3:	e9 6a ff ff ff       	jmp    101f42 <__alltraps>

00101fd8 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fd8:	6a 0e                	push   $0xe
  jmp __alltraps
  101fda:	e9 63 ff ff ff       	jmp    101f42 <__alltraps>

00101fdf <vector15>:
.globl vector15
vector15:
  pushl $0
  101fdf:	6a 00                	push   $0x0
  pushl $15
  101fe1:	6a 0f                	push   $0xf
  jmp __alltraps
  101fe3:	e9 5a ff ff ff       	jmp    101f42 <__alltraps>

00101fe8 <vector16>:
.globl vector16
vector16:
  pushl $0
  101fe8:	6a 00                	push   $0x0
  pushl $16
  101fea:	6a 10                	push   $0x10
  jmp __alltraps
  101fec:	e9 51 ff ff ff       	jmp    101f42 <__alltraps>

00101ff1 <vector17>:
.globl vector17
vector17:
  pushl $17
  101ff1:	6a 11                	push   $0x11
  jmp __alltraps
  101ff3:	e9 4a ff ff ff       	jmp    101f42 <__alltraps>

00101ff8 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ff8:	6a 00                	push   $0x0
  pushl $18
  101ffa:	6a 12                	push   $0x12
  jmp __alltraps
  101ffc:	e9 41 ff ff ff       	jmp    101f42 <__alltraps>

00102001 <vector19>:
.globl vector19
vector19:
  pushl $0
  102001:	6a 00                	push   $0x0
  pushl $19
  102003:	6a 13                	push   $0x13
  jmp __alltraps
  102005:	e9 38 ff ff ff       	jmp    101f42 <__alltraps>

0010200a <vector20>:
.globl vector20
vector20:
  pushl $0
  10200a:	6a 00                	push   $0x0
  pushl $20
  10200c:	6a 14                	push   $0x14
  jmp __alltraps
  10200e:	e9 2f ff ff ff       	jmp    101f42 <__alltraps>

00102013 <vector21>:
.globl vector21
vector21:
  pushl $0
  102013:	6a 00                	push   $0x0
  pushl $21
  102015:	6a 15                	push   $0x15
  jmp __alltraps
  102017:	e9 26 ff ff ff       	jmp    101f42 <__alltraps>

0010201c <vector22>:
.globl vector22
vector22:
  pushl $0
  10201c:	6a 00                	push   $0x0
  pushl $22
  10201e:	6a 16                	push   $0x16
  jmp __alltraps
  102020:	e9 1d ff ff ff       	jmp    101f42 <__alltraps>

00102025 <vector23>:
.globl vector23
vector23:
  pushl $0
  102025:	6a 00                	push   $0x0
  pushl $23
  102027:	6a 17                	push   $0x17
  jmp __alltraps
  102029:	e9 14 ff ff ff       	jmp    101f42 <__alltraps>

0010202e <vector24>:
.globl vector24
vector24:
  pushl $0
  10202e:	6a 00                	push   $0x0
  pushl $24
  102030:	6a 18                	push   $0x18
  jmp __alltraps
  102032:	e9 0b ff ff ff       	jmp    101f42 <__alltraps>

00102037 <vector25>:
.globl vector25
vector25:
  pushl $0
  102037:	6a 00                	push   $0x0
  pushl $25
  102039:	6a 19                	push   $0x19
  jmp __alltraps
  10203b:	e9 02 ff ff ff       	jmp    101f42 <__alltraps>

00102040 <vector26>:
.globl vector26
vector26:
  pushl $0
  102040:	6a 00                	push   $0x0
  pushl $26
  102042:	6a 1a                	push   $0x1a
  jmp __alltraps
  102044:	e9 f9 fe ff ff       	jmp    101f42 <__alltraps>

00102049 <vector27>:
.globl vector27
vector27:
  pushl $0
  102049:	6a 00                	push   $0x0
  pushl $27
  10204b:	6a 1b                	push   $0x1b
  jmp __alltraps
  10204d:	e9 f0 fe ff ff       	jmp    101f42 <__alltraps>

00102052 <vector28>:
.globl vector28
vector28:
  pushl $0
  102052:	6a 00                	push   $0x0
  pushl $28
  102054:	6a 1c                	push   $0x1c
  jmp __alltraps
  102056:	e9 e7 fe ff ff       	jmp    101f42 <__alltraps>

0010205b <vector29>:
.globl vector29
vector29:
  pushl $0
  10205b:	6a 00                	push   $0x0
  pushl $29
  10205d:	6a 1d                	push   $0x1d
  jmp __alltraps
  10205f:	e9 de fe ff ff       	jmp    101f42 <__alltraps>

00102064 <vector30>:
.globl vector30
vector30:
  pushl $0
  102064:	6a 00                	push   $0x0
  pushl $30
  102066:	6a 1e                	push   $0x1e
  jmp __alltraps
  102068:	e9 d5 fe ff ff       	jmp    101f42 <__alltraps>

0010206d <vector31>:
.globl vector31
vector31:
  pushl $0
  10206d:	6a 00                	push   $0x0
  pushl $31
  10206f:	6a 1f                	push   $0x1f
  jmp __alltraps
  102071:	e9 cc fe ff ff       	jmp    101f42 <__alltraps>

00102076 <vector32>:
.globl vector32
vector32:
  pushl $0
  102076:	6a 00                	push   $0x0
  pushl $32
  102078:	6a 20                	push   $0x20
  jmp __alltraps
  10207a:	e9 c3 fe ff ff       	jmp    101f42 <__alltraps>

0010207f <vector33>:
.globl vector33
vector33:
  pushl $0
  10207f:	6a 00                	push   $0x0
  pushl $33
  102081:	6a 21                	push   $0x21
  jmp __alltraps
  102083:	e9 ba fe ff ff       	jmp    101f42 <__alltraps>

00102088 <vector34>:
.globl vector34
vector34:
  pushl $0
  102088:	6a 00                	push   $0x0
  pushl $34
  10208a:	6a 22                	push   $0x22
  jmp __alltraps
  10208c:	e9 b1 fe ff ff       	jmp    101f42 <__alltraps>

00102091 <vector35>:
.globl vector35
vector35:
  pushl $0
  102091:	6a 00                	push   $0x0
  pushl $35
  102093:	6a 23                	push   $0x23
  jmp __alltraps
  102095:	e9 a8 fe ff ff       	jmp    101f42 <__alltraps>

0010209a <vector36>:
.globl vector36
vector36:
  pushl $0
  10209a:	6a 00                	push   $0x0
  pushl $36
  10209c:	6a 24                	push   $0x24
  jmp __alltraps
  10209e:	e9 9f fe ff ff       	jmp    101f42 <__alltraps>

001020a3 <vector37>:
.globl vector37
vector37:
  pushl $0
  1020a3:	6a 00                	push   $0x0
  pushl $37
  1020a5:	6a 25                	push   $0x25
  jmp __alltraps
  1020a7:	e9 96 fe ff ff       	jmp    101f42 <__alltraps>

001020ac <vector38>:
.globl vector38
vector38:
  pushl $0
  1020ac:	6a 00                	push   $0x0
  pushl $38
  1020ae:	6a 26                	push   $0x26
  jmp __alltraps
  1020b0:	e9 8d fe ff ff       	jmp    101f42 <__alltraps>

001020b5 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $39
  1020b7:	6a 27                	push   $0x27
  jmp __alltraps
  1020b9:	e9 84 fe ff ff       	jmp    101f42 <__alltraps>

001020be <vector40>:
.globl vector40
vector40:
  pushl $0
  1020be:	6a 00                	push   $0x0
  pushl $40
  1020c0:	6a 28                	push   $0x28
  jmp __alltraps
  1020c2:	e9 7b fe ff ff       	jmp    101f42 <__alltraps>

001020c7 <vector41>:
.globl vector41
vector41:
  pushl $0
  1020c7:	6a 00                	push   $0x0
  pushl $41
  1020c9:	6a 29                	push   $0x29
  jmp __alltraps
  1020cb:	e9 72 fe ff ff       	jmp    101f42 <__alltraps>

001020d0 <vector42>:
.globl vector42
vector42:
  pushl $0
  1020d0:	6a 00                	push   $0x0
  pushl $42
  1020d2:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020d4:	e9 69 fe ff ff       	jmp    101f42 <__alltraps>

001020d9 <vector43>:
.globl vector43
vector43:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $43
  1020db:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020dd:	e9 60 fe ff ff       	jmp    101f42 <__alltraps>

001020e2 <vector44>:
.globl vector44
vector44:
  pushl $0
  1020e2:	6a 00                	push   $0x0
  pushl $44
  1020e4:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020e6:	e9 57 fe ff ff       	jmp    101f42 <__alltraps>

001020eb <vector45>:
.globl vector45
vector45:
  pushl $0
  1020eb:	6a 00                	push   $0x0
  pushl $45
  1020ed:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020ef:	e9 4e fe ff ff       	jmp    101f42 <__alltraps>

001020f4 <vector46>:
.globl vector46
vector46:
  pushl $0
  1020f4:	6a 00                	push   $0x0
  pushl $46
  1020f6:	6a 2e                	push   $0x2e
  jmp __alltraps
  1020f8:	e9 45 fe ff ff       	jmp    101f42 <__alltraps>

001020fd <vector47>:
.globl vector47
vector47:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $47
  1020ff:	6a 2f                	push   $0x2f
  jmp __alltraps
  102101:	e9 3c fe ff ff       	jmp    101f42 <__alltraps>

00102106 <vector48>:
.globl vector48
vector48:
  pushl $0
  102106:	6a 00                	push   $0x0
  pushl $48
  102108:	6a 30                	push   $0x30
  jmp __alltraps
  10210a:	e9 33 fe ff ff       	jmp    101f42 <__alltraps>

0010210f <vector49>:
.globl vector49
vector49:
  pushl $0
  10210f:	6a 00                	push   $0x0
  pushl $49
  102111:	6a 31                	push   $0x31
  jmp __alltraps
  102113:	e9 2a fe ff ff       	jmp    101f42 <__alltraps>

00102118 <vector50>:
.globl vector50
vector50:
  pushl $0
  102118:	6a 00                	push   $0x0
  pushl $50
  10211a:	6a 32                	push   $0x32
  jmp __alltraps
  10211c:	e9 21 fe ff ff       	jmp    101f42 <__alltraps>

00102121 <vector51>:
.globl vector51
vector51:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $51
  102123:	6a 33                	push   $0x33
  jmp __alltraps
  102125:	e9 18 fe ff ff       	jmp    101f42 <__alltraps>

0010212a <vector52>:
.globl vector52
vector52:
  pushl $0
  10212a:	6a 00                	push   $0x0
  pushl $52
  10212c:	6a 34                	push   $0x34
  jmp __alltraps
  10212e:	e9 0f fe ff ff       	jmp    101f42 <__alltraps>

00102133 <vector53>:
.globl vector53
vector53:
  pushl $0
  102133:	6a 00                	push   $0x0
  pushl $53
  102135:	6a 35                	push   $0x35
  jmp __alltraps
  102137:	e9 06 fe ff ff       	jmp    101f42 <__alltraps>

0010213c <vector54>:
.globl vector54
vector54:
  pushl $0
  10213c:	6a 00                	push   $0x0
  pushl $54
  10213e:	6a 36                	push   $0x36
  jmp __alltraps
  102140:	e9 fd fd ff ff       	jmp    101f42 <__alltraps>

00102145 <vector55>:
.globl vector55
vector55:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $55
  102147:	6a 37                	push   $0x37
  jmp __alltraps
  102149:	e9 f4 fd ff ff       	jmp    101f42 <__alltraps>

0010214e <vector56>:
.globl vector56
vector56:
  pushl $0
  10214e:	6a 00                	push   $0x0
  pushl $56
  102150:	6a 38                	push   $0x38
  jmp __alltraps
  102152:	e9 eb fd ff ff       	jmp    101f42 <__alltraps>

00102157 <vector57>:
.globl vector57
vector57:
  pushl $0
  102157:	6a 00                	push   $0x0
  pushl $57
  102159:	6a 39                	push   $0x39
  jmp __alltraps
  10215b:	e9 e2 fd ff ff       	jmp    101f42 <__alltraps>

00102160 <vector58>:
.globl vector58
vector58:
  pushl $0
  102160:	6a 00                	push   $0x0
  pushl $58
  102162:	6a 3a                	push   $0x3a
  jmp __alltraps
  102164:	e9 d9 fd ff ff       	jmp    101f42 <__alltraps>

00102169 <vector59>:
.globl vector59
vector59:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $59
  10216b:	6a 3b                	push   $0x3b
  jmp __alltraps
  10216d:	e9 d0 fd ff ff       	jmp    101f42 <__alltraps>

00102172 <vector60>:
.globl vector60
vector60:
  pushl $0
  102172:	6a 00                	push   $0x0
  pushl $60
  102174:	6a 3c                	push   $0x3c
  jmp __alltraps
  102176:	e9 c7 fd ff ff       	jmp    101f42 <__alltraps>

0010217b <vector61>:
.globl vector61
vector61:
  pushl $0
  10217b:	6a 00                	push   $0x0
  pushl $61
  10217d:	6a 3d                	push   $0x3d
  jmp __alltraps
  10217f:	e9 be fd ff ff       	jmp    101f42 <__alltraps>

00102184 <vector62>:
.globl vector62
vector62:
  pushl $0
  102184:	6a 00                	push   $0x0
  pushl $62
  102186:	6a 3e                	push   $0x3e
  jmp __alltraps
  102188:	e9 b5 fd ff ff       	jmp    101f42 <__alltraps>

0010218d <vector63>:
.globl vector63
vector63:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $63
  10218f:	6a 3f                	push   $0x3f
  jmp __alltraps
  102191:	e9 ac fd ff ff       	jmp    101f42 <__alltraps>

00102196 <vector64>:
.globl vector64
vector64:
  pushl $0
  102196:	6a 00                	push   $0x0
  pushl $64
  102198:	6a 40                	push   $0x40
  jmp __alltraps
  10219a:	e9 a3 fd ff ff       	jmp    101f42 <__alltraps>

0010219f <vector65>:
.globl vector65
vector65:
  pushl $0
  10219f:	6a 00                	push   $0x0
  pushl $65
  1021a1:	6a 41                	push   $0x41
  jmp __alltraps
  1021a3:	e9 9a fd ff ff       	jmp    101f42 <__alltraps>

001021a8 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021a8:	6a 00                	push   $0x0
  pushl $66
  1021aa:	6a 42                	push   $0x42
  jmp __alltraps
  1021ac:	e9 91 fd ff ff       	jmp    101f42 <__alltraps>

001021b1 <vector67>:
.globl vector67
vector67:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $67
  1021b3:	6a 43                	push   $0x43
  jmp __alltraps
  1021b5:	e9 88 fd ff ff       	jmp    101f42 <__alltraps>

001021ba <vector68>:
.globl vector68
vector68:
  pushl $0
  1021ba:	6a 00                	push   $0x0
  pushl $68
  1021bc:	6a 44                	push   $0x44
  jmp __alltraps
  1021be:	e9 7f fd ff ff       	jmp    101f42 <__alltraps>

001021c3 <vector69>:
.globl vector69
vector69:
  pushl $0
  1021c3:	6a 00                	push   $0x0
  pushl $69
  1021c5:	6a 45                	push   $0x45
  jmp __alltraps
  1021c7:	e9 76 fd ff ff       	jmp    101f42 <__alltraps>

001021cc <vector70>:
.globl vector70
vector70:
  pushl $0
  1021cc:	6a 00                	push   $0x0
  pushl $70
  1021ce:	6a 46                	push   $0x46
  jmp __alltraps
  1021d0:	e9 6d fd ff ff       	jmp    101f42 <__alltraps>

001021d5 <vector71>:
.globl vector71
vector71:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $71
  1021d7:	6a 47                	push   $0x47
  jmp __alltraps
  1021d9:	e9 64 fd ff ff       	jmp    101f42 <__alltraps>

001021de <vector72>:
.globl vector72
vector72:
  pushl $0
  1021de:	6a 00                	push   $0x0
  pushl $72
  1021e0:	6a 48                	push   $0x48
  jmp __alltraps
  1021e2:	e9 5b fd ff ff       	jmp    101f42 <__alltraps>

001021e7 <vector73>:
.globl vector73
vector73:
  pushl $0
  1021e7:	6a 00                	push   $0x0
  pushl $73
  1021e9:	6a 49                	push   $0x49
  jmp __alltraps
  1021eb:	e9 52 fd ff ff       	jmp    101f42 <__alltraps>

001021f0 <vector74>:
.globl vector74
vector74:
  pushl $0
  1021f0:	6a 00                	push   $0x0
  pushl $74
  1021f2:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021f4:	e9 49 fd ff ff       	jmp    101f42 <__alltraps>

001021f9 <vector75>:
.globl vector75
vector75:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $75
  1021fb:	6a 4b                	push   $0x4b
  jmp __alltraps
  1021fd:	e9 40 fd ff ff       	jmp    101f42 <__alltraps>

00102202 <vector76>:
.globl vector76
vector76:
  pushl $0
  102202:	6a 00                	push   $0x0
  pushl $76
  102204:	6a 4c                	push   $0x4c
  jmp __alltraps
  102206:	e9 37 fd ff ff       	jmp    101f42 <__alltraps>

0010220b <vector77>:
.globl vector77
vector77:
  pushl $0
  10220b:	6a 00                	push   $0x0
  pushl $77
  10220d:	6a 4d                	push   $0x4d
  jmp __alltraps
  10220f:	e9 2e fd ff ff       	jmp    101f42 <__alltraps>

00102214 <vector78>:
.globl vector78
vector78:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $78
  102216:	6a 4e                	push   $0x4e
  jmp __alltraps
  102218:	e9 25 fd ff ff       	jmp    101f42 <__alltraps>

0010221d <vector79>:
.globl vector79
vector79:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $79
  10221f:	6a 4f                	push   $0x4f
  jmp __alltraps
  102221:	e9 1c fd ff ff       	jmp    101f42 <__alltraps>

00102226 <vector80>:
.globl vector80
vector80:
  pushl $0
  102226:	6a 00                	push   $0x0
  pushl $80
  102228:	6a 50                	push   $0x50
  jmp __alltraps
  10222a:	e9 13 fd ff ff       	jmp    101f42 <__alltraps>

0010222f <vector81>:
.globl vector81
vector81:
  pushl $0
  10222f:	6a 00                	push   $0x0
  pushl $81
  102231:	6a 51                	push   $0x51
  jmp __alltraps
  102233:	e9 0a fd ff ff       	jmp    101f42 <__alltraps>

00102238 <vector82>:
.globl vector82
vector82:
  pushl $0
  102238:	6a 00                	push   $0x0
  pushl $82
  10223a:	6a 52                	push   $0x52
  jmp __alltraps
  10223c:	e9 01 fd ff ff       	jmp    101f42 <__alltraps>

00102241 <vector83>:
.globl vector83
vector83:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $83
  102243:	6a 53                	push   $0x53
  jmp __alltraps
  102245:	e9 f8 fc ff ff       	jmp    101f42 <__alltraps>

0010224a <vector84>:
.globl vector84
vector84:
  pushl $0
  10224a:	6a 00                	push   $0x0
  pushl $84
  10224c:	6a 54                	push   $0x54
  jmp __alltraps
  10224e:	e9 ef fc ff ff       	jmp    101f42 <__alltraps>

00102253 <vector85>:
.globl vector85
vector85:
  pushl $0
  102253:	6a 00                	push   $0x0
  pushl $85
  102255:	6a 55                	push   $0x55
  jmp __alltraps
  102257:	e9 e6 fc ff ff       	jmp    101f42 <__alltraps>

0010225c <vector86>:
.globl vector86
vector86:
  pushl $0
  10225c:	6a 00                	push   $0x0
  pushl $86
  10225e:	6a 56                	push   $0x56
  jmp __alltraps
  102260:	e9 dd fc ff ff       	jmp    101f42 <__alltraps>

00102265 <vector87>:
.globl vector87
vector87:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $87
  102267:	6a 57                	push   $0x57
  jmp __alltraps
  102269:	e9 d4 fc ff ff       	jmp    101f42 <__alltraps>

0010226e <vector88>:
.globl vector88
vector88:
  pushl $0
  10226e:	6a 00                	push   $0x0
  pushl $88
  102270:	6a 58                	push   $0x58
  jmp __alltraps
  102272:	e9 cb fc ff ff       	jmp    101f42 <__alltraps>

00102277 <vector89>:
.globl vector89
vector89:
  pushl $0
  102277:	6a 00                	push   $0x0
  pushl $89
  102279:	6a 59                	push   $0x59
  jmp __alltraps
  10227b:	e9 c2 fc ff ff       	jmp    101f42 <__alltraps>

00102280 <vector90>:
.globl vector90
vector90:
  pushl $0
  102280:	6a 00                	push   $0x0
  pushl $90
  102282:	6a 5a                	push   $0x5a
  jmp __alltraps
  102284:	e9 b9 fc ff ff       	jmp    101f42 <__alltraps>

00102289 <vector91>:
.globl vector91
vector91:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $91
  10228b:	6a 5b                	push   $0x5b
  jmp __alltraps
  10228d:	e9 b0 fc ff ff       	jmp    101f42 <__alltraps>

00102292 <vector92>:
.globl vector92
vector92:
  pushl $0
  102292:	6a 00                	push   $0x0
  pushl $92
  102294:	6a 5c                	push   $0x5c
  jmp __alltraps
  102296:	e9 a7 fc ff ff       	jmp    101f42 <__alltraps>

0010229b <vector93>:
.globl vector93
vector93:
  pushl $0
  10229b:	6a 00                	push   $0x0
  pushl $93
  10229d:	6a 5d                	push   $0x5d
  jmp __alltraps
  10229f:	e9 9e fc ff ff       	jmp    101f42 <__alltraps>

001022a4 <vector94>:
.globl vector94
vector94:
  pushl $0
  1022a4:	6a 00                	push   $0x0
  pushl $94
  1022a6:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022a8:	e9 95 fc ff ff       	jmp    101f42 <__alltraps>

001022ad <vector95>:
.globl vector95
vector95:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $95
  1022af:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022b1:	e9 8c fc ff ff       	jmp    101f42 <__alltraps>

001022b6 <vector96>:
.globl vector96
vector96:
  pushl $0
  1022b6:	6a 00                	push   $0x0
  pushl $96
  1022b8:	6a 60                	push   $0x60
  jmp __alltraps
  1022ba:	e9 83 fc ff ff       	jmp    101f42 <__alltraps>

001022bf <vector97>:
.globl vector97
vector97:
  pushl $0
  1022bf:	6a 00                	push   $0x0
  pushl $97
  1022c1:	6a 61                	push   $0x61
  jmp __alltraps
  1022c3:	e9 7a fc ff ff       	jmp    101f42 <__alltraps>

001022c8 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022c8:	6a 00                	push   $0x0
  pushl $98
  1022ca:	6a 62                	push   $0x62
  jmp __alltraps
  1022cc:	e9 71 fc ff ff       	jmp    101f42 <__alltraps>

001022d1 <vector99>:
.globl vector99
vector99:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $99
  1022d3:	6a 63                	push   $0x63
  jmp __alltraps
  1022d5:	e9 68 fc ff ff       	jmp    101f42 <__alltraps>

001022da <vector100>:
.globl vector100
vector100:
  pushl $0
  1022da:	6a 00                	push   $0x0
  pushl $100
  1022dc:	6a 64                	push   $0x64
  jmp __alltraps
  1022de:	e9 5f fc ff ff       	jmp    101f42 <__alltraps>

001022e3 <vector101>:
.globl vector101
vector101:
  pushl $0
  1022e3:	6a 00                	push   $0x0
  pushl $101
  1022e5:	6a 65                	push   $0x65
  jmp __alltraps
  1022e7:	e9 56 fc ff ff       	jmp    101f42 <__alltraps>

001022ec <vector102>:
.globl vector102
vector102:
  pushl $0
  1022ec:	6a 00                	push   $0x0
  pushl $102
  1022ee:	6a 66                	push   $0x66
  jmp __alltraps
  1022f0:	e9 4d fc ff ff       	jmp    101f42 <__alltraps>

001022f5 <vector103>:
.globl vector103
vector103:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $103
  1022f7:	6a 67                	push   $0x67
  jmp __alltraps
  1022f9:	e9 44 fc ff ff       	jmp    101f42 <__alltraps>

001022fe <vector104>:
.globl vector104
vector104:
  pushl $0
  1022fe:	6a 00                	push   $0x0
  pushl $104
  102300:	6a 68                	push   $0x68
  jmp __alltraps
  102302:	e9 3b fc ff ff       	jmp    101f42 <__alltraps>

00102307 <vector105>:
.globl vector105
vector105:
  pushl $0
  102307:	6a 00                	push   $0x0
  pushl $105
  102309:	6a 69                	push   $0x69
  jmp __alltraps
  10230b:	e9 32 fc ff ff       	jmp    101f42 <__alltraps>

00102310 <vector106>:
.globl vector106
vector106:
  pushl $0
  102310:	6a 00                	push   $0x0
  pushl $106
  102312:	6a 6a                	push   $0x6a
  jmp __alltraps
  102314:	e9 29 fc ff ff       	jmp    101f42 <__alltraps>

00102319 <vector107>:
.globl vector107
vector107:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $107
  10231b:	6a 6b                	push   $0x6b
  jmp __alltraps
  10231d:	e9 20 fc ff ff       	jmp    101f42 <__alltraps>

00102322 <vector108>:
.globl vector108
vector108:
  pushl $0
  102322:	6a 00                	push   $0x0
  pushl $108
  102324:	6a 6c                	push   $0x6c
  jmp __alltraps
  102326:	e9 17 fc ff ff       	jmp    101f42 <__alltraps>

0010232b <vector109>:
.globl vector109
vector109:
  pushl $0
  10232b:	6a 00                	push   $0x0
  pushl $109
  10232d:	6a 6d                	push   $0x6d
  jmp __alltraps
  10232f:	e9 0e fc ff ff       	jmp    101f42 <__alltraps>

00102334 <vector110>:
.globl vector110
vector110:
  pushl $0
  102334:	6a 00                	push   $0x0
  pushl $110
  102336:	6a 6e                	push   $0x6e
  jmp __alltraps
  102338:	e9 05 fc ff ff       	jmp    101f42 <__alltraps>

0010233d <vector111>:
.globl vector111
vector111:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $111
  10233f:	6a 6f                	push   $0x6f
  jmp __alltraps
  102341:	e9 fc fb ff ff       	jmp    101f42 <__alltraps>

00102346 <vector112>:
.globl vector112
vector112:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $112
  102348:	6a 70                	push   $0x70
  jmp __alltraps
  10234a:	e9 f3 fb ff ff       	jmp    101f42 <__alltraps>

0010234f <vector113>:
.globl vector113
vector113:
  pushl $0
  10234f:	6a 00                	push   $0x0
  pushl $113
  102351:	6a 71                	push   $0x71
  jmp __alltraps
  102353:	e9 ea fb ff ff       	jmp    101f42 <__alltraps>

00102358 <vector114>:
.globl vector114
vector114:
  pushl $0
  102358:	6a 00                	push   $0x0
  pushl $114
  10235a:	6a 72                	push   $0x72
  jmp __alltraps
  10235c:	e9 e1 fb ff ff       	jmp    101f42 <__alltraps>

00102361 <vector115>:
.globl vector115
vector115:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $115
  102363:	6a 73                	push   $0x73
  jmp __alltraps
  102365:	e9 d8 fb ff ff       	jmp    101f42 <__alltraps>

0010236a <vector116>:
.globl vector116
vector116:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $116
  10236c:	6a 74                	push   $0x74
  jmp __alltraps
  10236e:	e9 cf fb ff ff       	jmp    101f42 <__alltraps>

00102373 <vector117>:
.globl vector117
vector117:
  pushl $0
  102373:	6a 00                	push   $0x0
  pushl $117
  102375:	6a 75                	push   $0x75
  jmp __alltraps
  102377:	e9 c6 fb ff ff       	jmp    101f42 <__alltraps>

0010237c <vector118>:
.globl vector118
vector118:
  pushl $0
  10237c:	6a 00                	push   $0x0
  pushl $118
  10237e:	6a 76                	push   $0x76
  jmp __alltraps
  102380:	e9 bd fb ff ff       	jmp    101f42 <__alltraps>

00102385 <vector119>:
.globl vector119
vector119:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $119
  102387:	6a 77                	push   $0x77
  jmp __alltraps
  102389:	e9 b4 fb ff ff       	jmp    101f42 <__alltraps>

0010238e <vector120>:
.globl vector120
vector120:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $120
  102390:	6a 78                	push   $0x78
  jmp __alltraps
  102392:	e9 ab fb ff ff       	jmp    101f42 <__alltraps>

00102397 <vector121>:
.globl vector121
vector121:
  pushl $0
  102397:	6a 00                	push   $0x0
  pushl $121
  102399:	6a 79                	push   $0x79
  jmp __alltraps
  10239b:	e9 a2 fb ff ff       	jmp    101f42 <__alltraps>

001023a0 <vector122>:
.globl vector122
vector122:
  pushl $0
  1023a0:	6a 00                	push   $0x0
  pushl $122
  1023a2:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023a4:	e9 99 fb ff ff       	jmp    101f42 <__alltraps>

001023a9 <vector123>:
.globl vector123
vector123:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $123
  1023ab:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023ad:	e9 90 fb ff ff       	jmp    101f42 <__alltraps>

001023b2 <vector124>:
.globl vector124
vector124:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $124
  1023b4:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023b6:	e9 87 fb ff ff       	jmp    101f42 <__alltraps>

001023bb <vector125>:
.globl vector125
vector125:
  pushl $0
  1023bb:	6a 00                	push   $0x0
  pushl $125
  1023bd:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023bf:	e9 7e fb ff ff       	jmp    101f42 <__alltraps>

001023c4 <vector126>:
.globl vector126
vector126:
  pushl $0
  1023c4:	6a 00                	push   $0x0
  pushl $126
  1023c6:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023c8:	e9 75 fb ff ff       	jmp    101f42 <__alltraps>

001023cd <vector127>:
.globl vector127
vector127:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $127
  1023cf:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023d1:	e9 6c fb ff ff       	jmp    101f42 <__alltraps>

001023d6 <vector128>:
.globl vector128
vector128:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $128
  1023d8:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023dd:	e9 60 fb ff ff       	jmp    101f42 <__alltraps>

001023e2 <vector129>:
.globl vector129
vector129:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $129
  1023e4:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023e9:	e9 54 fb ff ff       	jmp    101f42 <__alltraps>

001023ee <vector130>:
.globl vector130
vector130:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $130
  1023f0:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1023f5:	e9 48 fb ff ff       	jmp    101f42 <__alltraps>

001023fa <vector131>:
.globl vector131
vector131:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $131
  1023fc:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102401:	e9 3c fb ff ff       	jmp    101f42 <__alltraps>

00102406 <vector132>:
.globl vector132
vector132:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $132
  102408:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10240d:	e9 30 fb ff ff       	jmp    101f42 <__alltraps>

00102412 <vector133>:
.globl vector133
vector133:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $133
  102414:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102419:	e9 24 fb ff ff       	jmp    101f42 <__alltraps>

0010241e <vector134>:
.globl vector134
vector134:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $134
  102420:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102425:	e9 18 fb ff ff       	jmp    101f42 <__alltraps>

0010242a <vector135>:
.globl vector135
vector135:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $135
  10242c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102431:	e9 0c fb ff ff       	jmp    101f42 <__alltraps>

00102436 <vector136>:
.globl vector136
vector136:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $136
  102438:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10243d:	e9 00 fb ff ff       	jmp    101f42 <__alltraps>

00102442 <vector137>:
.globl vector137
vector137:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $137
  102444:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102449:	e9 f4 fa ff ff       	jmp    101f42 <__alltraps>

0010244e <vector138>:
.globl vector138
vector138:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $138
  102450:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102455:	e9 e8 fa ff ff       	jmp    101f42 <__alltraps>

0010245a <vector139>:
.globl vector139
vector139:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $139
  10245c:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102461:	e9 dc fa ff ff       	jmp    101f42 <__alltraps>

00102466 <vector140>:
.globl vector140
vector140:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $140
  102468:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10246d:	e9 d0 fa ff ff       	jmp    101f42 <__alltraps>

00102472 <vector141>:
.globl vector141
vector141:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $141
  102474:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102479:	e9 c4 fa ff ff       	jmp    101f42 <__alltraps>

0010247e <vector142>:
.globl vector142
vector142:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $142
  102480:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102485:	e9 b8 fa ff ff       	jmp    101f42 <__alltraps>

0010248a <vector143>:
.globl vector143
vector143:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $143
  10248c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102491:	e9 ac fa ff ff       	jmp    101f42 <__alltraps>

00102496 <vector144>:
.globl vector144
vector144:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $144
  102498:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10249d:	e9 a0 fa ff ff       	jmp    101f42 <__alltraps>

001024a2 <vector145>:
.globl vector145
vector145:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $145
  1024a4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024a9:	e9 94 fa ff ff       	jmp    101f42 <__alltraps>

001024ae <vector146>:
.globl vector146
vector146:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $146
  1024b0:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024b5:	e9 88 fa ff ff       	jmp    101f42 <__alltraps>

001024ba <vector147>:
.globl vector147
vector147:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $147
  1024bc:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024c1:	e9 7c fa ff ff       	jmp    101f42 <__alltraps>

001024c6 <vector148>:
.globl vector148
vector148:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $148
  1024c8:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024cd:	e9 70 fa ff ff       	jmp    101f42 <__alltraps>

001024d2 <vector149>:
.globl vector149
vector149:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $149
  1024d4:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024d9:	e9 64 fa ff ff       	jmp    101f42 <__alltraps>

001024de <vector150>:
.globl vector150
vector150:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $150
  1024e0:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024e5:	e9 58 fa ff ff       	jmp    101f42 <__alltraps>

001024ea <vector151>:
.globl vector151
vector151:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $151
  1024ec:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024f1:	e9 4c fa ff ff       	jmp    101f42 <__alltraps>

001024f6 <vector152>:
.globl vector152
vector152:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $152
  1024f8:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1024fd:	e9 40 fa ff ff       	jmp    101f42 <__alltraps>

00102502 <vector153>:
.globl vector153
vector153:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $153
  102504:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102509:	e9 34 fa ff ff       	jmp    101f42 <__alltraps>

0010250e <vector154>:
.globl vector154
vector154:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $154
  102510:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102515:	e9 28 fa ff ff       	jmp    101f42 <__alltraps>

0010251a <vector155>:
.globl vector155
vector155:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $155
  10251c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102521:	e9 1c fa ff ff       	jmp    101f42 <__alltraps>

00102526 <vector156>:
.globl vector156
vector156:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $156
  102528:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10252d:	e9 10 fa ff ff       	jmp    101f42 <__alltraps>

00102532 <vector157>:
.globl vector157
vector157:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $157
  102534:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102539:	e9 04 fa ff ff       	jmp    101f42 <__alltraps>

0010253e <vector158>:
.globl vector158
vector158:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $158
  102540:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102545:	e9 f8 f9 ff ff       	jmp    101f42 <__alltraps>

0010254a <vector159>:
.globl vector159
vector159:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $159
  10254c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102551:	e9 ec f9 ff ff       	jmp    101f42 <__alltraps>

00102556 <vector160>:
.globl vector160
vector160:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $160
  102558:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10255d:	e9 e0 f9 ff ff       	jmp    101f42 <__alltraps>

00102562 <vector161>:
.globl vector161
vector161:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $161
  102564:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102569:	e9 d4 f9 ff ff       	jmp    101f42 <__alltraps>

0010256e <vector162>:
.globl vector162
vector162:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $162
  102570:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102575:	e9 c8 f9 ff ff       	jmp    101f42 <__alltraps>

0010257a <vector163>:
.globl vector163
vector163:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $163
  10257c:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102581:	e9 bc f9 ff ff       	jmp    101f42 <__alltraps>

00102586 <vector164>:
.globl vector164
vector164:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $164
  102588:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10258d:	e9 b0 f9 ff ff       	jmp    101f42 <__alltraps>

00102592 <vector165>:
.globl vector165
vector165:
  pushl $0
  102592:	6a 00                	push   $0x0
  pushl $165
  102594:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102599:	e9 a4 f9 ff ff       	jmp    101f42 <__alltraps>

0010259e <vector166>:
.globl vector166
vector166:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $166
  1025a0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025a5:	e9 98 f9 ff ff       	jmp    101f42 <__alltraps>

001025aa <vector167>:
.globl vector167
vector167:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $167
  1025ac:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025b1:	e9 8c f9 ff ff       	jmp    101f42 <__alltraps>

001025b6 <vector168>:
.globl vector168
vector168:
  pushl $0
  1025b6:	6a 00                	push   $0x0
  pushl $168
  1025b8:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025bd:	e9 80 f9 ff ff       	jmp    101f42 <__alltraps>

001025c2 <vector169>:
.globl vector169
vector169:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $169
  1025c4:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025c9:	e9 74 f9 ff ff       	jmp    101f42 <__alltraps>

001025ce <vector170>:
.globl vector170
vector170:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $170
  1025d0:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025d5:	e9 68 f9 ff ff       	jmp    101f42 <__alltraps>

001025da <vector171>:
.globl vector171
vector171:
  pushl $0
  1025da:	6a 00                	push   $0x0
  pushl $171
  1025dc:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025e1:	e9 5c f9 ff ff       	jmp    101f42 <__alltraps>

001025e6 <vector172>:
.globl vector172
vector172:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $172
  1025e8:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025ed:	e9 50 f9 ff ff       	jmp    101f42 <__alltraps>

001025f2 <vector173>:
.globl vector173
vector173:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $173
  1025f4:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1025f9:	e9 44 f9 ff ff       	jmp    101f42 <__alltraps>

001025fe <vector174>:
.globl vector174
vector174:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $174
  102600:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102605:	e9 38 f9 ff ff       	jmp    101f42 <__alltraps>

0010260a <vector175>:
.globl vector175
vector175:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $175
  10260c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102611:	e9 2c f9 ff ff       	jmp    101f42 <__alltraps>

00102616 <vector176>:
.globl vector176
vector176:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $176
  102618:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10261d:	e9 20 f9 ff ff       	jmp    101f42 <__alltraps>

00102622 <vector177>:
.globl vector177
vector177:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $177
  102624:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102629:	e9 14 f9 ff ff       	jmp    101f42 <__alltraps>

0010262e <vector178>:
.globl vector178
vector178:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $178
  102630:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102635:	e9 08 f9 ff ff       	jmp    101f42 <__alltraps>

0010263a <vector179>:
.globl vector179
vector179:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $179
  10263c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102641:	e9 fc f8 ff ff       	jmp    101f42 <__alltraps>

00102646 <vector180>:
.globl vector180
vector180:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $180
  102648:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10264d:	e9 f0 f8 ff ff       	jmp    101f42 <__alltraps>

00102652 <vector181>:
.globl vector181
vector181:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $181
  102654:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102659:	e9 e4 f8 ff ff       	jmp    101f42 <__alltraps>

0010265e <vector182>:
.globl vector182
vector182:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $182
  102660:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102665:	e9 d8 f8 ff ff       	jmp    101f42 <__alltraps>

0010266a <vector183>:
.globl vector183
vector183:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $183
  10266c:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102671:	e9 cc f8 ff ff       	jmp    101f42 <__alltraps>

00102676 <vector184>:
.globl vector184
vector184:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $184
  102678:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10267d:	e9 c0 f8 ff ff       	jmp    101f42 <__alltraps>

00102682 <vector185>:
.globl vector185
vector185:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $185
  102684:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102689:	e9 b4 f8 ff ff       	jmp    101f42 <__alltraps>

0010268e <vector186>:
.globl vector186
vector186:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $186
  102690:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102695:	e9 a8 f8 ff ff       	jmp    101f42 <__alltraps>

0010269a <vector187>:
.globl vector187
vector187:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $187
  10269c:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1026a1:	e9 9c f8 ff ff       	jmp    101f42 <__alltraps>

001026a6 <vector188>:
.globl vector188
vector188:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $188
  1026a8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026ad:	e9 90 f8 ff ff       	jmp    101f42 <__alltraps>

001026b2 <vector189>:
.globl vector189
vector189:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $189
  1026b4:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026b9:	e9 84 f8 ff ff       	jmp    101f42 <__alltraps>

001026be <vector190>:
.globl vector190
vector190:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $190
  1026c0:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026c5:	e9 78 f8 ff ff       	jmp    101f42 <__alltraps>

001026ca <vector191>:
.globl vector191
vector191:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $191
  1026cc:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026d1:	e9 6c f8 ff ff       	jmp    101f42 <__alltraps>

001026d6 <vector192>:
.globl vector192
vector192:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $192
  1026d8:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026dd:	e9 60 f8 ff ff       	jmp    101f42 <__alltraps>

001026e2 <vector193>:
.globl vector193
vector193:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $193
  1026e4:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026e9:	e9 54 f8 ff ff       	jmp    101f42 <__alltraps>

001026ee <vector194>:
.globl vector194
vector194:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $194
  1026f0:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1026f5:	e9 48 f8 ff ff       	jmp    101f42 <__alltraps>

001026fa <vector195>:
.globl vector195
vector195:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $195
  1026fc:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102701:	e9 3c f8 ff ff       	jmp    101f42 <__alltraps>

00102706 <vector196>:
.globl vector196
vector196:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $196
  102708:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10270d:	e9 30 f8 ff ff       	jmp    101f42 <__alltraps>

00102712 <vector197>:
.globl vector197
vector197:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $197
  102714:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102719:	e9 24 f8 ff ff       	jmp    101f42 <__alltraps>

0010271e <vector198>:
.globl vector198
vector198:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $198
  102720:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102725:	e9 18 f8 ff ff       	jmp    101f42 <__alltraps>

0010272a <vector199>:
.globl vector199
vector199:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $199
  10272c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102731:	e9 0c f8 ff ff       	jmp    101f42 <__alltraps>

00102736 <vector200>:
.globl vector200
vector200:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $200
  102738:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10273d:	e9 00 f8 ff ff       	jmp    101f42 <__alltraps>

00102742 <vector201>:
.globl vector201
vector201:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $201
  102744:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102749:	e9 f4 f7 ff ff       	jmp    101f42 <__alltraps>

0010274e <vector202>:
.globl vector202
vector202:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $202
  102750:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102755:	e9 e8 f7 ff ff       	jmp    101f42 <__alltraps>

0010275a <vector203>:
.globl vector203
vector203:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $203
  10275c:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102761:	e9 dc f7 ff ff       	jmp    101f42 <__alltraps>

00102766 <vector204>:
.globl vector204
vector204:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $204
  102768:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10276d:	e9 d0 f7 ff ff       	jmp    101f42 <__alltraps>

00102772 <vector205>:
.globl vector205
vector205:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $205
  102774:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102779:	e9 c4 f7 ff ff       	jmp    101f42 <__alltraps>

0010277e <vector206>:
.globl vector206
vector206:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $206
  102780:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102785:	e9 b8 f7 ff ff       	jmp    101f42 <__alltraps>

0010278a <vector207>:
.globl vector207
vector207:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $207
  10278c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102791:	e9 ac f7 ff ff       	jmp    101f42 <__alltraps>

00102796 <vector208>:
.globl vector208
vector208:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $208
  102798:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10279d:	e9 a0 f7 ff ff       	jmp    101f42 <__alltraps>

001027a2 <vector209>:
.globl vector209
vector209:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $209
  1027a4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027a9:	e9 94 f7 ff ff       	jmp    101f42 <__alltraps>

001027ae <vector210>:
.globl vector210
vector210:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $210
  1027b0:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027b5:	e9 88 f7 ff ff       	jmp    101f42 <__alltraps>

001027ba <vector211>:
.globl vector211
vector211:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $211
  1027bc:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027c1:	e9 7c f7 ff ff       	jmp    101f42 <__alltraps>

001027c6 <vector212>:
.globl vector212
vector212:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $212
  1027c8:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027cd:	e9 70 f7 ff ff       	jmp    101f42 <__alltraps>

001027d2 <vector213>:
.globl vector213
vector213:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $213
  1027d4:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027d9:	e9 64 f7 ff ff       	jmp    101f42 <__alltraps>

001027de <vector214>:
.globl vector214
vector214:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $214
  1027e0:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027e5:	e9 58 f7 ff ff       	jmp    101f42 <__alltraps>

001027ea <vector215>:
.globl vector215
vector215:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $215
  1027ec:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027f1:	e9 4c f7 ff ff       	jmp    101f42 <__alltraps>

001027f6 <vector216>:
.globl vector216
vector216:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $216
  1027f8:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1027fd:	e9 40 f7 ff ff       	jmp    101f42 <__alltraps>

00102802 <vector217>:
.globl vector217
vector217:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $217
  102804:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102809:	e9 34 f7 ff ff       	jmp    101f42 <__alltraps>

0010280e <vector218>:
.globl vector218
vector218:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $218
  102810:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102815:	e9 28 f7 ff ff       	jmp    101f42 <__alltraps>

0010281a <vector219>:
.globl vector219
vector219:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $219
  10281c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102821:	e9 1c f7 ff ff       	jmp    101f42 <__alltraps>

00102826 <vector220>:
.globl vector220
vector220:
  pushl $0
  102826:	6a 00                	push   $0x0
  pushl $220
  102828:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10282d:	e9 10 f7 ff ff       	jmp    101f42 <__alltraps>

00102832 <vector221>:
.globl vector221
vector221:
  pushl $0
  102832:	6a 00                	push   $0x0
  pushl $221
  102834:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102839:	e9 04 f7 ff ff       	jmp    101f42 <__alltraps>

0010283e <vector222>:
.globl vector222
vector222:
  pushl $0
  10283e:	6a 00                	push   $0x0
  pushl $222
  102840:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102845:	e9 f8 f6 ff ff       	jmp    101f42 <__alltraps>

0010284a <vector223>:
.globl vector223
vector223:
  pushl $0
  10284a:	6a 00                	push   $0x0
  pushl $223
  10284c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102851:	e9 ec f6 ff ff       	jmp    101f42 <__alltraps>

00102856 <vector224>:
.globl vector224
vector224:
  pushl $0
  102856:	6a 00                	push   $0x0
  pushl $224
  102858:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10285d:	e9 e0 f6 ff ff       	jmp    101f42 <__alltraps>

00102862 <vector225>:
.globl vector225
vector225:
  pushl $0
  102862:	6a 00                	push   $0x0
  pushl $225
  102864:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102869:	e9 d4 f6 ff ff       	jmp    101f42 <__alltraps>

0010286e <vector226>:
.globl vector226
vector226:
  pushl $0
  10286e:	6a 00                	push   $0x0
  pushl $226
  102870:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102875:	e9 c8 f6 ff ff       	jmp    101f42 <__alltraps>

0010287a <vector227>:
.globl vector227
vector227:
  pushl $0
  10287a:	6a 00                	push   $0x0
  pushl $227
  10287c:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102881:	e9 bc f6 ff ff       	jmp    101f42 <__alltraps>

00102886 <vector228>:
.globl vector228
vector228:
  pushl $0
  102886:	6a 00                	push   $0x0
  pushl $228
  102888:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10288d:	e9 b0 f6 ff ff       	jmp    101f42 <__alltraps>

00102892 <vector229>:
.globl vector229
vector229:
  pushl $0
  102892:	6a 00                	push   $0x0
  pushl $229
  102894:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102899:	e9 a4 f6 ff ff       	jmp    101f42 <__alltraps>

0010289e <vector230>:
.globl vector230
vector230:
  pushl $0
  10289e:	6a 00                	push   $0x0
  pushl $230
  1028a0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028a5:	e9 98 f6 ff ff       	jmp    101f42 <__alltraps>

001028aa <vector231>:
.globl vector231
vector231:
  pushl $0
  1028aa:	6a 00                	push   $0x0
  pushl $231
  1028ac:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028b1:	e9 8c f6 ff ff       	jmp    101f42 <__alltraps>

001028b6 <vector232>:
.globl vector232
vector232:
  pushl $0
  1028b6:	6a 00                	push   $0x0
  pushl $232
  1028b8:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028bd:	e9 80 f6 ff ff       	jmp    101f42 <__alltraps>

001028c2 <vector233>:
.globl vector233
vector233:
  pushl $0
  1028c2:	6a 00                	push   $0x0
  pushl $233
  1028c4:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028c9:	e9 74 f6 ff ff       	jmp    101f42 <__alltraps>

001028ce <vector234>:
.globl vector234
vector234:
  pushl $0
  1028ce:	6a 00                	push   $0x0
  pushl $234
  1028d0:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028d5:	e9 68 f6 ff ff       	jmp    101f42 <__alltraps>

001028da <vector235>:
.globl vector235
vector235:
  pushl $0
  1028da:	6a 00                	push   $0x0
  pushl $235
  1028dc:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028e1:	e9 5c f6 ff ff       	jmp    101f42 <__alltraps>

001028e6 <vector236>:
.globl vector236
vector236:
  pushl $0
  1028e6:	6a 00                	push   $0x0
  pushl $236
  1028e8:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028ed:	e9 50 f6 ff ff       	jmp    101f42 <__alltraps>

001028f2 <vector237>:
.globl vector237
vector237:
  pushl $0
  1028f2:	6a 00                	push   $0x0
  pushl $237
  1028f4:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1028f9:	e9 44 f6 ff ff       	jmp    101f42 <__alltraps>

001028fe <vector238>:
.globl vector238
vector238:
  pushl $0
  1028fe:	6a 00                	push   $0x0
  pushl $238
  102900:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102905:	e9 38 f6 ff ff       	jmp    101f42 <__alltraps>

0010290a <vector239>:
.globl vector239
vector239:
  pushl $0
  10290a:	6a 00                	push   $0x0
  pushl $239
  10290c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102911:	e9 2c f6 ff ff       	jmp    101f42 <__alltraps>

00102916 <vector240>:
.globl vector240
vector240:
  pushl $0
  102916:	6a 00                	push   $0x0
  pushl $240
  102918:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10291d:	e9 20 f6 ff ff       	jmp    101f42 <__alltraps>

00102922 <vector241>:
.globl vector241
vector241:
  pushl $0
  102922:	6a 00                	push   $0x0
  pushl $241
  102924:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102929:	e9 14 f6 ff ff       	jmp    101f42 <__alltraps>

0010292e <vector242>:
.globl vector242
vector242:
  pushl $0
  10292e:	6a 00                	push   $0x0
  pushl $242
  102930:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102935:	e9 08 f6 ff ff       	jmp    101f42 <__alltraps>

0010293a <vector243>:
.globl vector243
vector243:
  pushl $0
  10293a:	6a 00                	push   $0x0
  pushl $243
  10293c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102941:	e9 fc f5 ff ff       	jmp    101f42 <__alltraps>

00102946 <vector244>:
.globl vector244
vector244:
  pushl $0
  102946:	6a 00                	push   $0x0
  pushl $244
  102948:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10294d:	e9 f0 f5 ff ff       	jmp    101f42 <__alltraps>

00102952 <vector245>:
.globl vector245
vector245:
  pushl $0
  102952:	6a 00                	push   $0x0
  pushl $245
  102954:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102959:	e9 e4 f5 ff ff       	jmp    101f42 <__alltraps>

0010295e <vector246>:
.globl vector246
vector246:
  pushl $0
  10295e:	6a 00                	push   $0x0
  pushl $246
  102960:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102965:	e9 d8 f5 ff ff       	jmp    101f42 <__alltraps>

0010296a <vector247>:
.globl vector247
vector247:
  pushl $0
  10296a:	6a 00                	push   $0x0
  pushl $247
  10296c:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102971:	e9 cc f5 ff ff       	jmp    101f42 <__alltraps>

00102976 <vector248>:
.globl vector248
vector248:
  pushl $0
  102976:	6a 00                	push   $0x0
  pushl $248
  102978:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10297d:	e9 c0 f5 ff ff       	jmp    101f42 <__alltraps>

00102982 <vector249>:
.globl vector249
vector249:
  pushl $0
  102982:	6a 00                	push   $0x0
  pushl $249
  102984:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102989:	e9 b4 f5 ff ff       	jmp    101f42 <__alltraps>

0010298e <vector250>:
.globl vector250
vector250:
  pushl $0
  10298e:	6a 00                	push   $0x0
  pushl $250
  102990:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102995:	e9 a8 f5 ff ff       	jmp    101f42 <__alltraps>

0010299a <vector251>:
.globl vector251
vector251:
  pushl $0
  10299a:	6a 00                	push   $0x0
  pushl $251
  10299c:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1029a1:	e9 9c f5 ff ff       	jmp    101f42 <__alltraps>

001029a6 <vector252>:
.globl vector252
vector252:
  pushl $0
  1029a6:	6a 00                	push   $0x0
  pushl $252
  1029a8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029ad:	e9 90 f5 ff ff       	jmp    101f42 <__alltraps>

001029b2 <vector253>:
.globl vector253
vector253:
  pushl $0
  1029b2:	6a 00                	push   $0x0
  pushl $253
  1029b4:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029b9:	e9 84 f5 ff ff       	jmp    101f42 <__alltraps>

001029be <vector254>:
.globl vector254
vector254:
  pushl $0
  1029be:	6a 00                	push   $0x0
  pushl $254
  1029c0:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029c5:	e9 78 f5 ff ff       	jmp    101f42 <__alltraps>

001029ca <vector255>:
.globl vector255
vector255:
  pushl $0
  1029ca:	6a 00                	push   $0x0
  pushl $255
  1029cc:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029d1:	e9 6c f5 ff ff       	jmp    101f42 <__alltraps>

001029d6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1029d6:	55                   	push   %ebp
  1029d7:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1029d9:	8b 55 08             	mov    0x8(%ebp),%edx
  1029dc:	a1 84 af 11 00       	mov    0x11af84,%eax
  1029e1:	29 c2                	sub    %eax,%edx
  1029e3:	89 d0                	mov    %edx,%eax
  1029e5:	c1 f8 02             	sar    $0x2,%eax
  1029e8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1029ee:	5d                   	pop    %ebp
  1029ef:	c3                   	ret    

001029f0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1029f0:	55                   	push   %ebp
  1029f1:	89 e5                	mov    %esp,%ebp
  1029f3:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1029f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f9:	89 04 24             	mov    %eax,(%esp)
  1029fc:	e8 d5 ff ff ff       	call   1029d6 <page2ppn>
  102a01:	c1 e0 0c             	shl    $0xc,%eax
}
  102a04:	c9                   	leave  
  102a05:	c3                   	ret    

00102a06 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102a06:	55                   	push   %ebp
  102a07:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102a09:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0c:	8b 00                	mov    (%eax),%eax
}
  102a0e:	5d                   	pop    %ebp
  102a0f:	c3                   	ret    

00102a10 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102a10:	55                   	push   %ebp
  102a11:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102a13:	8b 45 08             	mov    0x8(%ebp),%eax
  102a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  102a19:	89 10                	mov    %edx,(%eax)
}
  102a1b:	5d                   	pop    %ebp
  102a1c:	c3                   	ret    

00102a1d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102a1d:	55                   	push   %ebp
  102a1e:	89 e5                	mov    %esp,%ebp
  102a20:	83 ec 10             	sub    $0x10,%esp
  102a23:	c7 45 fc 70 af 11 00 	movl   $0x11af70,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102a30:	89 50 04             	mov    %edx,0x4(%eax)
  102a33:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a36:	8b 50 04             	mov    0x4(%eax),%edx
  102a39:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102a3c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  102a3e:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  102a45:	00 00 00 
}
  102a48:	c9                   	leave  
  102a49:	c3                   	ret    

00102a4a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102a4a:	55                   	push   %ebp
  102a4b:	89 e5                	mov    %esp,%ebp
  102a4d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  102a50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102a54:	75 24                	jne    102a7a <default_init_memmap+0x30>
  102a56:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  102a5d:	00 
  102a5e:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102a65:	00 
  102a66:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  102a6d:	00 
  102a6e:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102a75:	e8 72 e2 ff ff       	call   100cec <__panic>
    struct Page *p = base;
  102a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102a80:	eb 7d                	jmp    102aff <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a85:	83 c0 04             	add    $0x4,%eax
  102a88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a95:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a98:	0f a3 10             	bt     %edx,(%eax)
  102a9b:	19 c0                	sbb    %eax,%eax
  102a9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102aa0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102aa4:	0f 95 c0             	setne  %al
  102aa7:	0f b6 c0             	movzbl %al,%eax
  102aaa:	85 c0                	test   %eax,%eax
  102aac:	75 24                	jne    102ad2 <default_init_memmap+0x88>
  102aae:	c7 44 24 0c c1 68 10 	movl   $0x1068c1,0xc(%esp)
  102ab5:	00 
  102ab6:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102abd:	00 
  102abe:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102ac5:	00 
  102ac6:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102acd:	e8 1a e2 ff ff       	call   100cec <__panic>
        p->flags = p->property = 0;
  102ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ad5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102adf:	8b 50 08             	mov    0x8(%eax),%edx
  102ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ae5:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102ae8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102aef:	00 
  102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102af3:	89 04 24             	mov    %eax,(%esp)
  102af6:	e8 15 ff ff ff       	call   102a10 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102afb:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b02:	89 d0                	mov    %edx,%eax
  102b04:	c1 e0 02             	shl    $0x2,%eax
  102b07:	01 d0                	add    %edx,%eax
  102b09:	c1 e0 02             	shl    $0x2,%eax
  102b0c:	89 c2                	mov    %eax,%edx
  102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b11:	01 d0                	add    %edx,%eax
  102b13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102b16:	0f 85 66 ff ff ff    	jne    102a82 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b22:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102b25:	8b 45 08             	mov    0x8(%ebp),%eax
  102b28:	83 c0 04             	add    $0x4,%eax
  102b2b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102b32:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b35:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102b38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102b3b:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  102b3e:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  102b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b47:	01 d0                	add    %edx,%eax
  102b49:	a3 78 af 11 00       	mov    %eax,0x11af78
    list_add_before(&free_list, &(base->page_link));
  102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b51:	83 c0 0c             	add    $0xc,%eax
  102b54:	c7 45 dc 70 af 11 00 	movl   $0x11af70,-0x24(%ebp)
  102b5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b61:	8b 00                	mov    (%eax),%eax
  102b63:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102b66:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102b69:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102b6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b72:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b78:	89 10                	mov    %edx,(%eax)
  102b7a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b7d:	8b 10                	mov    (%eax),%edx
  102b7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b82:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b88:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b8b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102b91:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b94:	89 10                	mov    %edx,(%eax)
}
  102b96:	c9                   	leave  
  102b97:	c3                   	ret    

00102b98 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102b98:	55                   	push   %ebp
  102b99:	89 e5                	mov    %esp,%ebp
  102b9b:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102b9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102ba2:	75 24                	jne    102bc8 <default_alloc_pages+0x30>
  102ba4:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  102bab:	00 
  102bac:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102bb3:	00 
  102bb4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102bbb:	00 
  102bbc:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102bc3:	e8 24 e1 ff ff       	call   100cec <__panic>
    if (n > nr_free) {
  102bc8:	a1 78 af 11 00       	mov    0x11af78,%eax
  102bcd:	3b 45 08             	cmp    0x8(%ebp),%eax
  102bd0:	73 0a                	jae    102bdc <default_alloc_pages+0x44>
        return NULL;
  102bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  102bd7:	e9 3d 01 00 00       	jmp    102d19 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  102bdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102be3:	c7 45 f0 70 af 11 00 	movl   $0x11af70,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  102bea:	eb 1c                	jmp    102c08 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bef:	83 e8 0c             	sub    $0xc,%eax
  102bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bf8:	8b 40 08             	mov    0x8(%eax),%eax
  102bfb:	3b 45 08             	cmp    0x8(%ebp),%eax
  102bfe:	72 08                	jb     102c08 <default_alloc_pages+0x70>
            page = p;
  102c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102c06:	eb 18                	jmp    102c20 <default_alloc_pages+0x88>
  102c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c11:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  102c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102c17:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102c1e:	75 cc                	jne    102bec <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102c24:	0f 84 ec 00 00 00    	je     102d16 <default_alloc_pages+0x17e>
        if (page->property > n) {
  102c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c2d:	8b 40 08             	mov    0x8(%eax),%eax
  102c30:	3b 45 08             	cmp    0x8(%ebp),%eax
  102c33:	0f 86 8c 00 00 00    	jbe    102cc5 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
  102c39:	8b 55 08             	mov    0x8(%ebp),%edx
  102c3c:	89 d0                	mov    %edx,%eax
  102c3e:	c1 e0 02             	shl    $0x2,%eax
  102c41:	01 d0                	add    %edx,%eax
  102c43:	c1 e0 02             	shl    $0x2,%eax
  102c46:	89 c2                	mov    %eax,%edx
  102c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c4b:	01 d0                	add    %edx,%eax
  102c4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c53:	8b 40 08             	mov    0x8(%eax),%eax
  102c56:	2b 45 08             	sub    0x8(%ebp),%eax
  102c59:	89 c2                	mov    %eax,%edx
  102c5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c5e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c64:	83 c0 04             	add    $0x4,%eax
  102c67:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102c6e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102c71:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c74:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c77:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
  102c7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c7d:	83 c0 0c             	add    $0xc,%eax
  102c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c83:	83 c2 0c             	add    $0xc,%edx
  102c86:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102c89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102c8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102c8f:	8b 40 04             	mov    0x4(%eax),%eax
  102c92:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102c95:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102c98:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102c9b:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102c9e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102ca1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102ca4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102ca7:	89 10                	mov    %edx,(%eax)
  102ca9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102cac:	8b 10                	mov    (%eax),%edx
  102cae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102cb1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102cb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102cb7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102cba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102cbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102cc0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102cc3:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cc8:	83 c0 0c             	add    $0xc,%eax
  102ccb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102cce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102cd1:	8b 40 04             	mov    0x4(%eax),%eax
  102cd4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102cd7:	8b 12                	mov    (%edx),%edx
  102cd9:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102cdc:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102cdf:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102ce2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ce5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ce8:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102ceb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102cee:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  102cf0:	a1 78 af 11 00       	mov    0x11af78,%eax
  102cf5:	2b 45 08             	sub    0x8(%ebp),%eax
  102cf8:	a3 78 af 11 00       	mov    %eax,0x11af78
        ClearPageProperty(page);
  102cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d00:	83 c0 04             	add    $0x4,%eax
  102d03:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102d0a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d0d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d10:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d13:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102d19:	c9                   	leave  
  102d1a:	c3                   	ret    

00102d1b <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102d1b:	55                   	push   %ebp
  102d1c:	89 e5                	mov    %esp,%ebp
  102d1e:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102d24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d28:	75 24                	jne    102d4e <default_free_pages+0x33>
  102d2a:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  102d31:	00 
  102d32:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102d39:	00 
  102d3a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  102d41:	00 
  102d42:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102d49:	e8 9e df ff ff       	call   100cec <__panic>
    struct Page *p = base;
  102d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102d54:	e9 9d 00 00 00       	jmp    102df6 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d5c:	83 c0 04             	add    $0x4,%eax
  102d5f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102d6f:	0f a3 10             	bt     %edx,(%eax)
  102d72:	19 c0                	sbb    %eax,%eax
  102d74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102d77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d7b:	0f 95 c0             	setne  %al
  102d7e:	0f b6 c0             	movzbl %al,%eax
  102d81:	85 c0                	test   %eax,%eax
  102d83:	75 2c                	jne    102db1 <default_free_pages+0x96>
  102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d88:	83 c0 04             	add    $0x4,%eax
  102d8b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102d92:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102d98:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102d9b:	0f a3 10             	bt     %edx,(%eax)
  102d9e:	19 c0                	sbb    %eax,%eax
  102da0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102da3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102da7:	0f 95 c0             	setne  %al
  102daa:	0f b6 c0             	movzbl %al,%eax
  102dad:	85 c0                	test   %eax,%eax
  102daf:	74 24                	je     102dd5 <default_free_pages+0xba>
  102db1:	c7 44 24 0c d4 68 10 	movl   $0x1068d4,0xc(%esp)
  102db8:	00 
  102db9:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102dc0:	00 
  102dc1:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  102dc8:	00 
  102dc9:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102dd0:	e8 17 df ff ff       	call   100cec <__panic>
        p->flags = 0;
  102dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dd8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102ddf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102de6:	00 
  102de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dea:	89 04 24             	mov    %eax,(%esp)
  102ded:	e8 1e fc ff ff       	call   102a10 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102df2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102df6:	8b 55 0c             	mov    0xc(%ebp),%edx
  102df9:	89 d0                	mov    %edx,%eax
  102dfb:	c1 e0 02             	shl    $0x2,%eax
  102dfe:	01 d0                	add    %edx,%eax
  102e00:	c1 e0 02             	shl    $0x2,%eax
  102e03:	89 c2                	mov    %eax,%edx
  102e05:	8b 45 08             	mov    0x8(%ebp),%eax
  102e08:	01 d0                	add    %edx,%eax
  102e0a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e0d:	0f 85 46 ff ff ff    	jne    102d59 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102e13:	8b 45 08             	mov    0x8(%ebp),%eax
  102e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e19:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e1f:	83 c0 04             	add    $0x4,%eax
  102e22:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102e29:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e32:	0f ab 10             	bts    %edx,(%eax)
  102e35:	c7 45 cc 70 af 11 00 	movl   $0x11af70,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102e3c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102e3f:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102e45:	e9 08 01 00 00       	jmp    102f52 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e4d:	83 e8 0c             	sub    $0xc,%eax
  102e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e56:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102e59:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102e5c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102e5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  102e62:	8b 45 08             	mov    0x8(%ebp),%eax
  102e65:	8b 50 08             	mov    0x8(%eax),%edx
  102e68:	89 d0                	mov    %edx,%eax
  102e6a:	c1 e0 02             	shl    $0x2,%eax
  102e6d:	01 d0                	add    %edx,%eax
  102e6f:	c1 e0 02             	shl    $0x2,%eax
  102e72:	89 c2                	mov    %eax,%edx
  102e74:	8b 45 08             	mov    0x8(%ebp),%eax
  102e77:	01 d0                	add    %edx,%eax
  102e79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e7c:	75 5a                	jne    102ed8 <default_free_pages+0x1bd>
            base->property += p->property;
  102e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  102e81:	8b 50 08             	mov    0x8(%eax),%edx
  102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e87:	8b 40 08             	mov    0x8(%eax),%eax
  102e8a:	01 c2                	add    %eax,%edx
  102e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e8f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e95:	83 c0 04             	add    $0x4,%eax
  102e98:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102e9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ea2:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102ea5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102ea8:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eae:	83 c0 0c             	add    $0xc,%eax
  102eb1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102eb4:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102eb7:	8b 40 04             	mov    0x4(%eax),%eax
  102eba:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ebd:	8b 12                	mov    (%edx),%edx
  102ebf:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102ec2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102ec5:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ec8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102ecb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102ece:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102ed1:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102ed4:	89 10                	mov    %edx,(%eax)
  102ed6:	eb 7a                	jmp    102f52 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102edb:	8b 50 08             	mov    0x8(%eax),%edx
  102ede:	89 d0                	mov    %edx,%eax
  102ee0:	c1 e0 02             	shl    $0x2,%eax
  102ee3:	01 d0                	add    %edx,%eax
  102ee5:	c1 e0 02             	shl    $0x2,%eax
  102ee8:	89 c2                	mov    %eax,%edx
  102eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eed:	01 d0                	add    %edx,%eax
  102eef:	3b 45 08             	cmp    0x8(%ebp),%eax
  102ef2:	75 5e                	jne    102f52 <default_free_pages+0x237>
            p->property += base->property;
  102ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ef7:	8b 50 08             	mov    0x8(%eax),%edx
  102efa:	8b 45 08             	mov    0x8(%ebp),%eax
  102efd:	8b 40 08             	mov    0x8(%eax),%eax
  102f00:	01 c2                	add    %eax,%edx
  102f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f05:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102f08:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0b:	83 c0 04             	add    $0x4,%eax
  102f0e:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102f15:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102f18:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102f1b:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102f1e:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f24:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f2a:	83 c0 0c             	add    $0xc,%eax
  102f2d:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102f30:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102f33:	8b 40 04             	mov    0x4(%eax),%eax
  102f36:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102f39:	8b 12                	mov    (%edx),%edx
  102f3b:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102f3e:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102f41:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102f44:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102f47:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102f4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f4d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102f50:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102f52:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102f59:	0f 85 eb fe ff ff    	jne    102e4a <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102f5f:	8b 15 78 af 11 00    	mov    0x11af78,%edx
  102f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f68:	01 d0                	add    %edx,%eax
  102f6a:	a3 78 af 11 00       	mov    %eax,0x11af78
  102f6f:	c7 45 9c 70 af 11 00 	movl   $0x11af70,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102f76:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f79:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  102f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102f7f:	eb 76                	jmp    102ff7 <default_free_pages+0x2dc>
        p = le2page(le, page_link);
  102f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f84:	83 e8 0c             	sub    $0xc,%eax
  102f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f8d:	8b 50 08             	mov    0x8(%eax),%edx
  102f90:	89 d0                	mov    %edx,%eax
  102f92:	c1 e0 02             	shl    $0x2,%eax
  102f95:	01 d0                	add    %edx,%eax
  102f97:	c1 e0 02             	shl    $0x2,%eax
  102f9a:	89 c2                	mov    %eax,%edx
  102f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102f9f:	01 d0                	add    %edx,%eax
  102fa1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fa4:	77 42                	ja     102fe8 <default_free_pages+0x2cd>
            assert(base + base->property != p);
  102fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  102fa9:	8b 50 08             	mov    0x8(%eax),%edx
  102fac:	89 d0                	mov    %edx,%eax
  102fae:	c1 e0 02             	shl    $0x2,%eax
  102fb1:	01 d0                	add    %edx,%eax
  102fb3:	c1 e0 02             	shl    $0x2,%eax
  102fb6:	89 c2                	mov    %eax,%edx
  102fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  102fbb:	01 d0                	add    %edx,%eax
  102fbd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fc0:	75 24                	jne    102fe6 <default_free_pages+0x2cb>
  102fc2:	c7 44 24 0c f9 68 10 	movl   $0x1068f9,0xc(%esp)
  102fc9:	00 
  102fca:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  102fd1:	00 
  102fd2:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  102fd9:	00 
  102fda:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  102fe1:	e8 06 dd ff ff       	call   100cec <__panic>
            break;
  102fe6:	eb 18                	jmp    103000 <default_free_pages+0x2e5>
  102fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102feb:	89 45 98             	mov    %eax,-0x68(%ebp)
  102fee:	8b 45 98             	mov    -0x68(%ebp),%eax
  102ff1:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  102ff4:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
  102ff7:	81 7d f0 70 af 11 00 	cmpl   $0x11af70,-0x10(%ebp)
  102ffe:	75 81                	jne    102f81 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  103000:	8b 45 08             	mov    0x8(%ebp),%eax
  103003:	8d 50 0c             	lea    0xc(%eax),%edx
  103006:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103009:	89 45 94             	mov    %eax,-0x6c(%ebp)
  10300c:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10300f:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103012:	8b 00                	mov    (%eax),%eax
  103014:	8b 55 90             	mov    -0x70(%ebp),%edx
  103017:	89 55 8c             	mov    %edx,-0x74(%ebp)
  10301a:	89 45 88             	mov    %eax,-0x78(%ebp)
  10301d:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103020:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103023:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103026:	8b 55 8c             	mov    -0x74(%ebp),%edx
  103029:	89 10                	mov    %edx,(%eax)
  10302b:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10302e:	8b 10                	mov    (%eax),%edx
  103030:	8b 45 88             	mov    -0x78(%ebp),%eax
  103033:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103036:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103039:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10303c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10303f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103042:	8b 55 88             	mov    -0x78(%ebp),%edx
  103045:	89 10                	mov    %edx,(%eax)
}
  103047:	c9                   	leave  
  103048:	c3                   	ret    

00103049 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  103049:	55                   	push   %ebp
  10304a:	89 e5                	mov    %esp,%ebp
    return nr_free;
  10304c:	a1 78 af 11 00       	mov    0x11af78,%eax
}
  103051:	5d                   	pop    %ebp
  103052:	c3                   	ret    

00103053 <basic_check>:

static void
basic_check(void) {
  103053:	55                   	push   %ebp
  103054:	89 e5                	mov    %esp,%ebp
  103056:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103059:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103063:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103066:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103069:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  10306c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103073:	e8 9d 0e 00 00       	call   103f15 <alloc_pages>
  103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10307b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10307f:	75 24                	jne    1030a5 <basic_check+0x52>
  103081:	c7 44 24 0c 14 69 10 	movl   $0x106914,0xc(%esp)
  103088:	00 
  103089:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103090:	00 
  103091:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  103098:	00 
  103099:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1030a0:	e8 47 dc ff ff       	call   100cec <__panic>
    assert((p1 = alloc_page()) != NULL);
  1030a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030ac:	e8 64 0e 00 00       	call   103f15 <alloc_pages>
  1030b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1030b8:	75 24                	jne    1030de <basic_check+0x8b>
  1030ba:	c7 44 24 0c 30 69 10 	movl   $0x106930,0xc(%esp)
  1030c1:	00 
  1030c2:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1030c9:	00 
  1030ca:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  1030d1:	00 
  1030d2:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1030d9:	e8 0e dc ff ff       	call   100cec <__panic>
    assert((p2 = alloc_page()) != NULL);
  1030de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030e5:	e8 2b 0e 00 00       	call   103f15 <alloc_pages>
  1030ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030f1:	75 24                	jne    103117 <basic_check+0xc4>
  1030f3:	c7 44 24 0c 4c 69 10 	movl   $0x10694c,0xc(%esp)
  1030fa:	00 
  1030fb:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103102:	00 
  103103:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  10310a:	00 
  10310b:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103112:	e8 d5 db ff ff       	call   100cec <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  103117:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10311a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10311d:	74 10                	je     10312f <basic_check+0xdc>
  10311f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103122:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103125:	74 08                	je     10312f <basic_check+0xdc>
  103127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10312a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10312d:	75 24                	jne    103153 <basic_check+0x100>
  10312f:	c7 44 24 0c 68 69 10 	movl   $0x106968,0xc(%esp)
  103136:	00 
  103137:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10313e:	00 
  10313f:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  103146:	00 
  103147:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10314e:	e8 99 db ff ff       	call   100cec <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  103153:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103156:	89 04 24             	mov    %eax,(%esp)
  103159:	e8 a8 f8 ff ff       	call   102a06 <page_ref>
  10315e:	85 c0                	test   %eax,%eax
  103160:	75 1e                	jne    103180 <basic_check+0x12d>
  103162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103165:	89 04 24             	mov    %eax,(%esp)
  103168:	e8 99 f8 ff ff       	call   102a06 <page_ref>
  10316d:	85 c0                	test   %eax,%eax
  10316f:	75 0f                	jne    103180 <basic_check+0x12d>
  103171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103174:	89 04 24             	mov    %eax,(%esp)
  103177:	e8 8a f8 ff ff       	call   102a06 <page_ref>
  10317c:	85 c0                	test   %eax,%eax
  10317e:	74 24                	je     1031a4 <basic_check+0x151>
  103180:	c7 44 24 0c 8c 69 10 	movl   $0x10698c,0xc(%esp)
  103187:	00 
  103188:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10318f:	00 
  103190:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  103197:	00 
  103198:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10319f:	e8 48 db ff ff       	call   100cec <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1031a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031a7:	89 04 24             	mov    %eax,(%esp)
  1031aa:	e8 41 f8 ff ff       	call   1029f0 <page2pa>
  1031af:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1031b5:	c1 e2 0c             	shl    $0xc,%edx
  1031b8:	39 d0                	cmp    %edx,%eax
  1031ba:	72 24                	jb     1031e0 <basic_check+0x18d>
  1031bc:	c7 44 24 0c c8 69 10 	movl   $0x1069c8,0xc(%esp)
  1031c3:	00 
  1031c4:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1031cb:	00 
  1031cc:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  1031d3:	00 
  1031d4:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1031db:	e8 0c db ff ff       	call   100cec <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1031e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e3:	89 04 24             	mov    %eax,(%esp)
  1031e6:	e8 05 f8 ff ff       	call   1029f0 <page2pa>
  1031eb:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1031f1:	c1 e2 0c             	shl    $0xc,%edx
  1031f4:	39 d0                	cmp    %edx,%eax
  1031f6:	72 24                	jb     10321c <basic_check+0x1c9>
  1031f8:	c7 44 24 0c e5 69 10 	movl   $0x1069e5,0xc(%esp)
  1031ff:	00 
  103200:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103207:	00 
  103208:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  10320f:	00 
  103210:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103217:	e8 d0 da ff ff       	call   100cec <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  10321c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10321f:	89 04 24             	mov    %eax,(%esp)
  103222:	e8 c9 f7 ff ff       	call   1029f0 <page2pa>
  103227:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10322d:	c1 e2 0c             	shl    $0xc,%edx
  103230:	39 d0                	cmp    %edx,%eax
  103232:	72 24                	jb     103258 <basic_check+0x205>
  103234:	c7 44 24 0c 02 6a 10 	movl   $0x106a02,0xc(%esp)
  10323b:	00 
  10323c:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103243:	00 
  103244:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  10324b:	00 
  10324c:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103253:	e8 94 da ff ff       	call   100cec <__panic>

    list_entry_t free_list_store = free_list;
  103258:	a1 70 af 11 00       	mov    0x11af70,%eax
  10325d:	8b 15 74 af 11 00    	mov    0x11af74,%edx
  103263:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103266:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103269:	c7 45 e0 70 af 11 00 	movl   $0x11af70,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  103270:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103273:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103276:	89 50 04             	mov    %edx,0x4(%eax)
  103279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10327c:	8b 50 04             	mov    0x4(%eax),%edx
  10327f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103282:	89 10                	mov    %edx,(%eax)
  103284:	c7 45 dc 70 af 11 00 	movl   $0x11af70,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10328b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10328e:	8b 40 04             	mov    0x4(%eax),%eax
  103291:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103294:	0f 94 c0             	sete   %al
  103297:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10329a:	85 c0                	test   %eax,%eax
  10329c:	75 24                	jne    1032c2 <basic_check+0x26f>
  10329e:	c7 44 24 0c 1f 6a 10 	movl   $0x106a1f,0xc(%esp)
  1032a5:	00 
  1032a6:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1032ad:	00 
  1032ae:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  1032b5:	00 
  1032b6:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1032bd:	e8 2a da ff ff       	call   100cec <__panic>

    unsigned int nr_free_store = nr_free;
  1032c2:	a1 78 af 11 00       	mov    0x11af78,%eax
  1032c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1032ca:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  1032d1:	00 00 00 

    assert(alloc_page() == NULL);
  1032d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032db:	e8 35 0c 00 00       	call   103f15 <alloc_pages>
  1032e0:	85 c0                	test   %eax,%eax
  1032e2:	74 24                	je     103308 <basic_check+0x2b5>
  1032e4:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  1032eb:	00 
  1032ec:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1032f3:	00 
  1032f4:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1032fb:	00 
  1032fc:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103303:	e8 e4 d9 ff ff       	call   100cec <__panic>

    free_page(p0);
  103308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10330f:	00 
  103310:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103313:	89 04 24             	mov    %eax,(%esp)
  103316:	e8 32 0c 00 00       	call   103f4d <free_pages>
    free_page(p1);
  10331b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103322:	00 
  103323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103326:	89 04 24             	mov    %eax,(%esp)
  103329:	e8 1f 0c 00 00       	call   103f4d <free_pages>
    free_page(p2);
  10332e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103335:	00 
  103336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103339:	89 04 24             	mov    %eax,(%esp)
  10333c:	e8 0c 0c 00 00       	call   103f4d <free_pages>
    assert(nr_free == 3);
  103341:	a1 78 af 11 00       	mov    0x11af78,%eax
  103346:	83 f8 03             	cmp    $0x3,%eax
  103349:	74 24                	je     10336f <basic_check+0x31c>
  10334b:	c7 44 24 0c 4b 6a 10 	movl   $0x106a4b,0xc(%esp)
  103352:	00 
  103353:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10335a:	00 
  10335b:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  103362:	00 
  103363:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10336a:	e8 7d d9 ff ff       	call   100cec <__panic>

    assert((p0 = alloc_page()) != NULL);
  10336f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103376:	e8 9a 0b 00 00       	call   103f15 <alloc_pages>
  10337b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10337e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103382:	75 24                	jne    1033a8 <basic_check+0x355>
  103384:	c7 44 24 0c 14 69 10 	movl   $0x106914,0xc(%esp)
  10338b:	00 
  10338c:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103393:	00 
  103394:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  10339b:	00 
  10339c:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1033a3:	e8 44 d9 ff ff       	call   100cec <__panic>
    assert((p1 = alloc_page()) != NULL);
  1033a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033af:	e8 61 0b 00 00       	call   103f15 <alloc_pages>
  1033b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1033bb:	75 24                	jne    1033e1 <basic_check+0x38e>
  1033bd:	c7 44 24 0c 30 69 10 	movl   $0x106930,0xc(%esp)
  1033c4:	00 
  1033c5:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1033cc:	00 
  1033cd:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  1033d4:	00 
  1033d5:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1033dc:	e8 0b d9 ff ff       	call   100cec <__panic>
    assert((p2 = alloc_page()) != NULL);
  1033e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033e8:	e8 28 0b 00 00       	call   103f15 <alloc_pages>
  1033ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033f4:	75 24                	jne    10341a <basic_check+0x3c7>
  1033f6:	c7 44 24 0c 4c 69 10 	movl   $0x10694c,0xc(%esp)
  1033fd:	00 
  1033fe:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103405:	00 
  103406:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  10340d:	00 
  10340e:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103415:	e8 d2 d8 ff ff       	call   100cec <__panic>

    assert(alloc_page() == NULL);
  10341a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103421:	e8 ef 0a 00 00       	call   103f15 <alloc_pages>
  103426:	85 c0                	test   %eax,%eax
  103428:	74 24                	je     10344e <basic_check+0x3fb>
  10342a:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  103431:	00 
  103432:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103439:	00 
  10343a:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  103441:	00 
  103442:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103449:	e8 9e d8 ff ff       	call   100cec <__panic>

    free_page(p0);
  10344e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103455:	00 
  103456:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103459:	89 04 24             	mov    %eax,(%esp)
  10345c:	e8 ec 0a 00 00       	call   103f4d <free_pages>
  103461:	c7 45 d8 70 af 11 00 	movl   $0x11af70,-0x28(%ebp)
  103468:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10346b:	8b 40 04             	mov    0x4(%eax),%eax
  10346e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  103471:	0f 94 c0             	sete   %al
  103474:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103477:	85 c0                	test   %eax,%eax
  103479:	74 24                	je     10349f <basic_check+0x44c>
  10347b:	c7 44 24 0c 58 6a 10 	movl   $0x106a58,0xc(%esp)
  103482:	00 
  103483:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10348a:	00 
  10348b:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  103492:	00 
  103493:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10349a:	e8 4d d8 ff ff       	call   100cec <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  10349f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034a6:	e8 6a 0a 00 00       	call   103f15 <alloc_pages>
  1034ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1034ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1034b4:	74 24                	je     1034da <basic_check+0x487>
  1034b6:	c7 44 24 0c 70 6a 10 	movl   $0x106a70,0xc(%esp)
  1034bd:	00 
  1034be:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1034c5:	00 
  1034c6:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  1034cd:	00 
  1034ce:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1034d5:	e8 12 d8 ff ff       	call   100cec <__panic>
    assert(alloc_page() == NULL);
  1034da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034e1:	e8 2f 0a 00 00       	call   103f15 <alloc_pages>
  1034e6:	85 c0                	test   %eax,%eax
  1034e8:	74 24                	je     10350e <basic_check+0x4bb>
  1034ea:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  1034f1:	00 
  1034f2:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1034f9:	00 
  1034fa:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  103501:	00 
  103502:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103509:	e8 de d7 ff ff       	call   100cec <__panic>

    assert(nr_free == 0);
  10350e:	a1 78 af 11 00       	mov    0x11af78,%eax
  103513:	85 c0                	test   %eax,%eax
  103515:	74 24                	je     10353b <basic_check+0x4e8>
  103517:	c7 44 24 0c 89 6a 10 	movl   $0x106a89,0xc(%esp)
  10351e:	00 
  10351f:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103526:	00 
  103527:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  10352e:	00 
  10352f:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103536:	e8 b1 d7 ff ff       	call   100cec <__panic>
    free_list = free_list_store;
  10353b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10353e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103541:	a3 70 af 11 00       	mov    %eax,0x11af70
  103546:	89 15 74 af 11 00    	mov    %edx,0x11af74
    nr_free = nr_free_store;
  10354c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10354f:	a3 78 af 11 00       	mov    %eax,0x11af78

    free_page(p);
  103554:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10355b:	00 
  10355c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10355f:	89 04 24             	mov    %eax,(%esp)
  103562:	e8 e6 09 00 00       	call   103f4d <free_pages>
    free_page(p1);
  103567:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10356e:	00 
  10356f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103572:	89 04 24             	mov    %eax,(%esp)
  103575:	e8 d3 09 00 00       	call   103f4d <free_pages>
    free_page(p2);
  10357a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103581:	00 
  103582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103585:	89 04 24             	mov    %eax,(%esp)
  103588:	e8 c0 09 00 00       	call   103f4d <free_pages>
}
  10358d:	c9                   	leave  
  10358e:	c3                   	ret    

0010358f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  10358f:	55                   	push   %ebp
  103590:	89 e5                	mov    %esp,%ebp
  103592:	53                   	push   %ebx
  103593:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  103599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1035a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1035a7:	c7 45 ec 70 af 11 00 	movl   $0x11af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1035ae:	eb 6b                	jmp    10361b <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  1035b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035b3:	83 e8 0c             	sub    $0xc,%eax
  1035b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  1035b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1035bc:	83 c0 04             	add    $0x4,%eax
  1035bf:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1035c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1035c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1035cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1035cf:	0f a3 10             	bt     %edx,(%eax)
  1035d2:	19 c0                	sbb    %eax,%eax
  1035d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1035d7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1035db:	0f 95 c0             	setne  %al
  1035de:	0f b6 c0             	movzbl %al,%eax
  1035e1:	85 c0                	test   %eax,%eax
  1035e3:	75 24                	jne    103609 <default_check+0x7a>
  1035e5:	c7 44 24 0c 96 6a 10 	movl   $0x106a96,0xc(%esp)
  1035ec:	00 
  1035ed:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1035f4:	00 
  1035f5:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  1035fc:	00 
  1035fd:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103604:	e8 e3 d6 ff ff       	call   100cec <__panic>
        count ++, total += p->property;
  103609:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10360d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103610:	8b 50 08             	mov    0x8(%eax),%edx
  103613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103616:	01 d0                	add    %edx,%eax
  103618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10361b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10361e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103621:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103624:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10362a:	81 7d ec 70 af 11 00 	cmpl   $0x11af70,-0x14(%ebp)
  103631:	0f 85 79 ff ff ff    	jne    1035b0 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103637:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  10363a:	e8 40 09 00 00       	call   103f7f <nr_free_pages>
  10363f:	39 c3                	cmp    %eax,%ebx
  103641:	74 24                	je     103667 <default_check+0xd8>
  103643:	c7 44 24 0c a6 6a 10 	movl   $0x106aa6,0xc(%esp)
  10364a:	00 
  10364b:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103652:	00 
  103653:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  10365a:	00 
  10365b:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103662:	e8 85 d6 ff ff       	call   100cec <__panic>

    basic_check();
  103667:	e8 e7 f9 ff ff       	call   103053 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10366c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103673:	e8 9d 08 00 00       	call   103f15 <alloc_pages>
  103678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  10367b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10367f:	75 24                	jne    1036a5 <default_check+0x116>
  103681:	c7 44 24 0c bf 6a 10 	movl   $0x106abf,0xc(%esp)
  103688:	00 
  103689:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103690:	00 
  103691:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  103698:	00 
  103699:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1036a0:	e8 47 d6 ff ff       	call   100cec <__panic>
    assert(!PageProperty(p0));
  1036a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036a8:	83 c0 04             	add    $0x4,%eax
  1036ab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1036b2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036b5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1036b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1036bb:	0f a3 10             	bt     %edx,(%eax)
  1036be:	19 c0                	sbb    %eax,%eax
  1036c0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1036c3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1036c7:	0f 95 c0             	setne  %al
  1036ca:	0f b6 c0             	movzbl %al,%eax
  1036cd:	85 c0                	test   %eax,%eax
  1036cf:	74 24                	je     1036f5 <default_check+0x166>
  1036d1:	c7 44 24 0c ca 6a 10 	movl   $0x106aca,0xc(%esp)
  1036d8:	00 
  1036d9:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1036e0:	00 
  1036e1:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1036e8:	00 
  1036e9:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1036f0:	e8 f7 d5 ff ff       	call   100cec <__panic>

    list_entry_t free_list_store = free_list;
  1036f5:	a1 70 af 11 00       	mov    0x11af70,%eax
  1036fa:	8b 15 74 af 11 00    	mov    0x11af74,%edx
  103700:	89 45 80             	mov    %eax,-0x80(%ebp)
  103703:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103706:	c7 45 b4 70 af 11 00 	movl   $0x11af70,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10370d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103710:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103713:	89 50 04             	mov    %edx,0x4(%eax)
  103716:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103719:	8b 50 04             	mov    0x4(%eax),%edx
  10371c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10371f:	89 10                	mov    %edx,(%eax)
  103721:	c7 45 b0 70 af 11 00 	movl   $0x11af70,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103728:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10372b:	8b 40 04             	mov    0x4(%eax),%eax
  10372e:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  103731:	0f 94 c0             	sete   %al
  103734:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103737:	85 c0                	test   %eax,%eax
  103739:	75 24                	jne    10375f <default_check+0x1d0>
  10373b:	c7 44 24 0c 1f 6a 10 	movl   $0x106a1f,0xc(%esp)
  103742:	00 
  103743:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10374a:	00 
  10374b:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103752:	00 
  103753:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10375a:	e8 8d d5 ff ff       	call   100cec <__panic>
    assert(alloc_page() == NULL);
  10375f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103766:	e8 aa 07 00 00       	call   103f15 <alloc_pages>
  10376b:	85 c0                	test   %eax,%eax
  10376d:	74 24                	je     103793 <default_check+0x204>
  10376f:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  103776:	00 
  103777:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10377e:	00 
  10377f:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  103786:	00 
  103787:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10378e:	e8 59 d5 ff ff       	call   100cec <__panic>

    unsigned int nr_free_store = nr_free;
  103793:	a1 78 af 11 00       	mov    0x11af78,%eax
  103798:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  10379b:	c7 05 78 af 11 00 00 	movl   $0x0,0x11af78
  1037a2:	00 00 00 

    free_pages(p0 + 2, 3);
  1037a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037a8:	83 c0 28             	add    $0x28,%eax
  1037ab:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1037b2:	00 
  1037b3:	89 04 24             	mov    %eax,(%esp)
  1037b6:	e8 92 07 00 00       	call   103f4d <free_pages>
    assert(alloc_pages(4) == NULL);
  1037bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1037c2:	e8 4e 07 00 00       	call   103f15 <alloc_pages>
  1037c7:	85 c0                	test   %eax,%eax
  1037c9:	74 24                	je     1037ef <default_check+0x260>
  1037cb:	c7 44 24 0c dc 6a 10 	movl   $0x106adc,0xc(%esp)
  1037d2:	00 
  1037d3:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1037da:	00 
  1037db:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1037e2:	00 
  1037e3:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1037ea:	e8 fd d4 ff ff       	call   100cec <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1037ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037f2:	83 c0 28             	add    $0x28,%eax
  1037f5:	83 c0 04             	add    $0x4,%eax
  1037f8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1037ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103802:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103805:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103808:	0f a3 10             	bt     %edx,(%eax)
  10380b:	19 c0                	sbb    %eax,%eax
  10380d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103810:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103814:	0f 95 c0             	setne  %al
  103817:	0f b6 c0             	movzbl %al,%eax
  10381a:	85 c0                	test   %eax,%eax
  10381c:	74 0e                	je     10382c <default_check+0x29d>
  10381e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103821:	83 c0 28             	add    $0x28,%eax
  103824:	8b 40 08             	mov    0x8(%eax),%eax
  103827:	83 f8 03             	cmp    $0x3,%eax
  10382a:	74 24                	je     103850 <default_check+0x2c1>
  10382c:	c7 44 24 0c f4 6a 10 	movl   $0x106af4,0xc(%esp)
  103833:	00 
  103834:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  10383b:	00 
  10383c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  103843:	00 
  103844:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  10384b:	e8 9c d4 ff ff       	call   100cec <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  103850:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103857:	e8 b9 06 00 00       	call   103f15 <alloc_pages>
  10385c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10385f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103863:	75 24                	jne    103889 <default_check+0x2fa>
  103865:	c7 44 24 0c 20 6b 10 	movl   $0x106b20,0xc(%esp)
  10386c:	00 
  10386d:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103874:	00 
  103875:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  10387c:	00 
  10387d:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103884:	e8 63 d4 ff ff       	call   100cec <__panic>
    assert(alloc_page() == NULL);
  103889:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103890:	e8 80 06 00 00       	call   103f15 <alloc_pages>
  103895:	85 c0                	test   %eax,%eax
  103897:	74 24                	je     1038bd <default_check+0x32e>
  103899:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  1038a0:	00 
  1038a1:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1038a8:	00 
  1038a9:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  1038b0:	00 
  1038b1:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1038b8:	e8 2f d4 ff ff       	call   100cec <__panic>
    assert(p0 + 2 == p1);
  1038bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038c0:	83 c0 28             	add    $0x28,%eax
  1038c3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1038c6:	74 24                	je     1038ec <default_check+0x35d>
  1038c8:	c7 44 24 0c 3e 6b 10 	movl   $0x106b3e,0xc(%esp)
  1038cf:	00 
  1038d0:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1038d7:	00 
  1038d8:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  1038df:	00 
  1038e0:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1038e7:	e8 00 d4 ff ff       	call   100cec <__panic>

    p2 = p0 + 1;
  1038ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038ef:	83 c0 14             	add    $0x14,%eax
  1038f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  1038f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038fc:	00 
  1038fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103900:	89 04 24             	mov    %eax,(%esp)
  103903:	e8 45 06 00 00       	call   103f4d <free_pages>
    free_pages(p1, 3);
  103908:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10390f:	00 
  103910:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103913:	89 04 24             	mov    %eax,(%esp)
  103916:	e8 32 06 00 00       	call   103f4d <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10391b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10391e:	83 c0 04             	add    $0x4,%eax
  103921:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103928:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10392b:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10392e:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103931:	0f a3 10             	bt     %edx,(%eax)
  103934:	19 c0                	sbb    %eax,%eax
  103936:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103939:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10393d:	0f 95 c0             	setne  %al
  103940:	0f b6 c0             	movzbl %al,%eax
  103943:	85 c0                	test   %eax,%eax
  103945:	74 0b                	je     103952 <default_check+0x3c3>
  103947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10394a:	8b 40 08             	mov    0x8(%eax),%eax
  10394d:	83 f8 01             	cmp    $0x1,%eax
  103950:	74 24                	je     103976 <default_check+0x3e7>
  103952:	c7 44 24 0c 4c 6b 10 	movl   $0x106b4c,0xc(%esp)
  103959:	00 
  10395a:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103961:	00 
  103962:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  103969:	00 
  10396a:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103971:	e8 76 d3 ff ff       	call   100cec <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103976:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103979:	83 c0 04             	add    $0x4,%eax
  10397c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103983:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103986:	8b 45 90             	mov    -0x70(%ebp),%eax
  103989:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10398c:	0f a3 10             	bt     %edx,(%eax)
  10398f:	19 c0                	sbb    %eax,%eax
  103991:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103994:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103998:	0f 95 c0             	setne  %al
  10399b:	0f b6 c0             	movzbl %al,%eax
  10399e:	85 c0                	test   %eax,%eax
  1039a0:	74 0b                	je     1039ad <default_check+0x41e>
  1039a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1039a5:	8b 40 08             	mov    0x8(%eax),%eax
  1039a8:	83 f8 03             	cmp    $0x3,%eax
  1039ab:	74 24                	je     1039d1 <default_check+0x442>
  1039ad:	c7 44 24 0c 74 6b 10 	movl   $0x106b74,0xc(%esp)
  1039b4:	00 
  1039b5:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1039bc:	00 
  1039bd:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  1039c4:	00 
  1039c5:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  1039cc:	e8 1b d3 ff ff       	call   100cec <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1039d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039d8:	e8 38 05 00 00       	call   103f15 <alloc_pages>
  1039dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1039e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1039e3:	83 e8 14             	sub    $0x14,%eax
  1039e6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1039e9:	74 24                	je     103a0f <default_check+0x480>
  1039eb:	c7 44 24 0c 9a 6b 10 	movl   $0x106b9a,0xc(%esp)
  1039f2:	00 
  1039f3:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  1039fa:	00 
  1039fb:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  103a02:	00 
  103a03:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103a0a:	e8 dd d2 ff ff       	call   100cec <__panic>
    free_page(p0);
  103a0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103a16:	00 
  103a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a1a:	89 04 24             	mov    %eax,(%esp)
  103a1d:	e8 2b 05 00 00       	call   103f4d <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103a22:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103a29:	e8 e7 04 00 00       	call   103f15 <alloc_pages>
  103a2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103a31:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103a34:	83 c0 14             	add    $0x14,%eax
  103a37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103a3a:	74 24                	je     103a60 <default_check+0x4d1>
  103a3c:	c7 44 24 0c b8 6b 10 	movl   $0x106bb8,0xc(%esp)
  103a43:	00 
  103a44:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103a4b:	00 
  103a4c:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  103a53:	00 
  103a54:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103a5b:	e8 8c d2 ff ff       	call   100cec <__panic>

    free_pages(p0, 2);
  103a60:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103a67:	00 
  103a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a6b:	89 04 24             	mov    %eax,(%esp)
  103a6e:	e8 da 04 00 00       	call   103f4d <free_pages>
    free_page(p2);
  103a73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103a7a:	00 
  103a7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103a7e:	89 04 24             	mov    %eax,(%esp)
  103a81:	e8 c7 04 00 00       	call   103f4d <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103a86:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103a8d:	e8 83 04 00 00       	call   103f15 <alloc_pages>
  103a92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103a95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103a99:	75 24                	jne    103abf <default_check+0x530>
  103a9b:	c7 44 24 0c d8 6b 10 	movl   $0x106bd8,0xc(%esp)
  103aa2:	00 
  103aa3:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103aaa:	00 
  103aab:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  103ab2:	00 
  103ab3:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103aba:	e8 2d d2 ff ff       	call   100cec <__panic>
    assert(alloc_page() == NULL);
  103abf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ac6:	e8 4a 04 00 00       	call   103f15 <alloc_pages>
  103acb:	85 c0                	test   %eax,%eax
  103acd:	74 24                	je     103af3 <default_check+0x564>
  103acf:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  103ad6:	00 
  103ad7:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103ade:	00 
  103adf:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  103ae6:	00 
  103ae7:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103aee:	e8 f9 d1 ff ff       	call   100cec <__panic>

    assert(nr_free == 0);
  103af3:	a1 78 af 11 00       	mov    0x11af78,%eax
  103af8:	85 c0                	test   %eax,%eax
  103afa:	74 24                	je     103b20 <default_check+0x591>
  103afc:	c7 44 24 0c 89 6a 10 	movl   $0x106a89,0xc(%esp)
  103b03:	00 
  103b04:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103b0b:	00 
  103b0c:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  103b13:	00 
  103b14:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103b1b:	e8 cc d1 ff ff       	call   100cec <__panic>
    nr_free = nr_free_store;
  103b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103b23:	a3 78 af 11 00       	mov    %eax,0x11af78

    free_list = free_list_store;
  103b28:	8b 45 80             	mov    -0x80(%ebp),%eax
  103b2b:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103b2e:	a3 70 af 11 00       	mov    %eax,0x11af70
  103b33:	89 15 74 af 11 00    	mov    %edx,0x11af74
    free_pages(p0, 5);
  103b39:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103b40:	00 
  103b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b44:	89 04 24             	mov    %eax,(%esp)
  103b47:	e8 01 04 00 00       	call   103f4d <free_pages>

    le = &free_list;
  103b4c:	c7 45 ec 70 af 11 00 	movl   $0x11af70,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103b53:	eb 1d                	jmp    103b72 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  103b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b58:	83 e8 0c             	sub    $0xc,%eax
  103b5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  103b5e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103b62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103b65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103b68:	8b 40 08             	mov    0x8(%eax),%eax
  103b6b:	29 c2                	sub    %eax,%edx
  103b6d:	89 d0                	mov    %edx,%eax
  103b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b75:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103b78:	8b 45 88             	mov    -0x78(%ebp),%eax
  103b7b:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103b81:	81 7d ec 70 af 11 00 	cmpl   $0x11af70,-0x14(%ebp)
  103b88:	75 cb                	jne    103b55 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  103b8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103b8e:	74 24                	je     103bb4 <default_check+0x625>
  103b90:	c7 44 24 0c f6 6b 10 	movl   $0x106bf6,0xc(%esp)
  103b97:	00 
  103b98:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103b9f:	00 
  103ba0:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  103ba7:	00 
  103ba8:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103baf:	e8 38 d1 ff ff       	call   100cec <__panic>
    assert(total == 0);
  103bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103bb8:	74 24                	je     103bde <default_check+0x64f>
  103bba:	c7 44 24 0c 01 6c 10 	movl   $0x106c01,0xc(%esp)
  103bc1:	00 
  103bc2:	c7 44 24 08 96 68 10 	movl   $0x106896,0x8(%esp)
  103bc9:	00 
  103bca:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  103bd1:	00 
  103bd2:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  103bd9:	e8 0e d1 ff ff       	call   100cec <__panic>
}
  103bde:	81 c4 94 00 00 00    	add    $0x94,%esp
  103be4:	5b                   	pop    %ebx
  103be5:	5d                   	pop    %ebp
  103be6:	c3                   	ret    

00103be7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103be7:	55                   	push   %ebp
  103be8:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103bea:	8b 55 08             	mov    0x8(%ebp),%edx
  103bed:	a1 84 af 11 00       	mov    0x11af84,%eax
  103bf2:	29 c2                	sub    %eax,%edx
  103bf4:	89 d0                	mov    %edx,%eax
  103bf6:	c1 f8 02             	sar    $0x2,%eax
  103bf9:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103bff:	5d                   	pop    %ebp
  103c00:	c3                   	ret    

00103c01 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103c01:	55                   	push   %ebp
  103c02:	89 e5                	mov    %esp,%ebp
  103c04:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103c07:	8b 45 08             	mov    0x8(%ebp),%eax
  103c0a:	89 04 24             	mov    %eax,(%esp)
  103c0d:	e8 d5 ff ff ff       	call   103be7 <page2ppn>
  103c12:	c1 e0 0c             	shl    $0xc,%eax
}
  103c15:	c9                   	leave  
  103c16:	c3                   	ret    

00103c17 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103c17:	55                   	push   %ebp
  103c18:	89 e5                	mov    %esp,%ebp
  103c1a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c20:	c1 e8 0c             	shr    $0xc,%eax
  103c23:	89 c2                	mov    %eax,%edx
  103c25:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103c2a:	39 c2                	cmp    %eax,%edx
  103c2c:	72 1c                	jb     103c4a <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103c2e:	c7 44 24 08 3c 6c 10 	movl   $0x106c3c,0x8(%esp)
  103c35:	00 
  103c36:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103c3d:	00 
  103c3e:	c7 04 24 5b 6c 10 00 	movl   $0x106c5b,(%esp)
  103c45:	e8 a2 d0 ff ff       	call   100cec <__panic>
    }
    return &pages[PPN(pa)];
  103c4a:	8b 0d 84 af 11 00    	mov    0x11af84,%ecx
  103c50:	8b 45 08             	mov    0x8(%ebp),%eax
  103c53:	c1 e8 0c             	shr    $0xc,%eax
  103c56:	89 c2                	mov    %eax,%edx
  103c58:	89 d0                	mov    %edx,%eax
  103c5a:	c1 e0 02             	shl    $0x2,%eax
  103c5d:	01 d0                	add    %edx,%eax
  103c5f:	c1 e0 02             	shl    $0x2,%eax
  103c62:	01 c8                	add    %ecx,%eax
}
  103c64:	c9                   	leave  
  103c65:	c3                   	ret    

00103c66 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103c66:	55                   	push   %ebp
  103c67:	89 e5                	mov    %esp,%ebp
  103c69:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  103c6f:	89 04 24             	mov    %eax,(%esp)
  103c72:	e8 8a ff ff ff       	call   103c01 <page2pa>
  103c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c7d:	c1 e8 0c             	shr    $0xc,%eax
  103c80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c83:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103c88:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103c8b:	72 23                	jb     103cb0 <page2kva+0x4a>
  103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c94:	c7 44 24 08 6c 6c 10 	movl   $0x106c6c,0x8(%esp)
  103c9b:	00 
  103c9c:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103ca3:	00 
  103ca4:	c7 04 24 5b 6c 10 00 	movl   $0x106c5b,(%esp)
  103cab:	e8 3c d0 ff ff       	call   100cec <__panic>
  103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cb3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103cb8:	c9                   	leave  
  103cb9:	c3                   	ret    

00103cba <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103cba:	55                   	push   %ebp
  103cbb:	89 e5                	mov    %esp,%ebp
  103cbd:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  103cc3:	83 e0 01             	and    $0x1,%eax
  103cc6:	85 c0                	test   %eax,%eax
  103cc8:	75 1c                	jne    103ce6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103cca:	c7 44 24 08 90 6c 10 	movl   $0x106c90,0x8(%esp)
  103cd1:	00 
  103cd2:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103cd9:	00 
  103cda:	c7 04 24 5b 6c 10 00 	movl   $0x106c5b,(%esp)
  103ce1:	e8 06 d0 ff ff       	call   100cec <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  103ce9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103cee:	89 04 24             	mov    %eax,(%esp)
  103cf1:	e8 21 ff ff ff       	call   103c17 <pa2page>
}
  103cf6:	c9                   	leave  
  103cf7:	c3                   	ret    

00103cf8 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103cf8:	55                   	push   %ebp
  103cf9:	89 e5                	mov    %esp,%ebp
  103cfb:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  103d01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d06:	89 04 24             	mov    %eax,(%esp)
  103d09:	e8 09 ff ff ff       	call   103c17 <pa2page>
}
  103d0e:	c9                   	leave  
  103d0f:	c3                   	ret    

00103d10 <page_ref>:

static inline int
page_ref(struct Page *page) {
  103d10:	55                   	push   %ebp
  103d11:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103d13:	8b 45 08             	mov    0x8(%ebp),%eax
  103d16:	8b 00                	mov    (%eax),%eax
}
  103d18:	5d                   	pop    %ebp
  103d19:	c3                   	ret    

00103d1a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103d1a:	55                   	push   %ebp
  103d1b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  103d20:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d23:	89 10                	mov    %edx,(%eax)
}
  103d25:	5d                   	pop    %ebp
  103d26:	c3                   	ret    

00103d27 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103d27:	55                   	push   %ebp
  103d28:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  103d2d:	8b 00                	mov    (%eax),%eax
  103d2f:	8d 50 01             	lea    0x1(%eax),%edx
  103d32:	8b 45 08             	mov    0x8(%ebp),%eax
  103d35:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103d37:	8b 45 08             	mov    0x8(%ebp),%eax
  103d3a:	8b 00                	mov    (%eax),%eax
}
  103d3c:	5d                   	pop    %ebp
  103d3d:	c3                   	ret    

00103d3e <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103d3e:	55                   	push   %ebp
  103d3f:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103d41:	8b 45 08             	mov    0x8(%ebp),%eax
  103d44:	8b 00                	mov    (%eax),%eax
  103d46:	8d 50 ff             	lea    -0x1(%eax),%edx
  103d49:	8b 45 08             	mov    0x8(%ebp),%eax
  103d4c:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  103d51:	8b 00                	mov    (%eax),%eax
}
  103d53:	5d                   	pop    %ebp
  103d54:	c3                   	ret    

00103d55 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103d55:	55                   	push   %ebp
  103d56:	89 e5                	mov    %esp,%ebp
  103d58:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103d5b:	9c                   	pushf  
  103d5c:	58                   	pop    %eax
  103d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103d63:	25 00 02 00 00       	and    $0x200,%eax
  103d68:	85 c0                	test   %eax,%eax
  103d6a:	74 0c                	je     103d78 <__intr_save+0x23>
        intr_disable();
  103d6c:	e8 6f d9 ff ff       	call   1016e0 <intr_disable>
        return 1;
  103d71:	b8 01 00 00 00       	mov    $0x1,%eax
  103d76:	eb 05                	jmp    103d7d <__intr_save+0x28>
    }
    return 0;
  103d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103d7d:	c9                   	leave  
  103d7e:	c3                   	ret    

00103d7f <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103d7f:	55                   	push   %ebp
  103d80:	89 e5                	mov    %esp,%ebp
  103d82:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103d85:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103d89:	74 05                	je     103d90 <__intr_restore+0x11>
        intr_enable();
  103d8b:	e8 4a d9 ff ff       	call   1016da <intr_enable>
    }
}
  103d90:	c9                   	leave  
  103d91:	c3                   	ret    

00103d92 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103d92:	55                   	push   %ebp
  103d93:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103d95:	8b 45 08             	mov    0x8(%ebp),%eax
  103d98:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103d9b:	b8 23 00 00 00       	mov    $0x23,%eax
  103da0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103da2:	b8 23 00 00 00       	mov    $0x23,%eax
  103da7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103da9:	b8 10 00 00 00       	mov    $0x10,%eax
  103dae:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103db0:	b8 10 00 00 00       	mov    $0x10,%eax
  103db5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103db7:	b8 10 00 00 00       	mov    $0x10,%eax
  103dbc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103dbe:	ea c5 3d 10 00 08 00 	ljmp   $0x8,$0x103dc5
}
  103dc5:	5d                   	pop    %ebp
  103dc6:	c3                   	ret    

00103dc7 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103dc7:	55                   	push   %ebp
  103dc8:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103dca:	8b 45 08             	mov    0x8(%ebp),%eax
  103dcd:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103dd2:	5d                   	pop    %ebp
  103dd3:	c3                   	ret    

00103dd4 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103dd4:	55                   	push   %ebp
  103dd5:	89 e5                	mov    %esp,%ebp
  103dd7:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103dda:	b8 00 70 11 00       	mov    $0x117000,%eax
  103ddf:	89 04 24             	mov    %eax,(%esp)
  103de2:	e8 e0 ff ff ff       	call   103dc7 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103de7:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103dee:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103df0:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103df7:	68 00 
  103df9:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103dfe:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103e04:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103e09:	c1 e8 10             	shr    $0x10,%eax
  103e0c:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103e11:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103e18:	83 e0 f0             	and    $0xfffffff0,%eax
  103e1b:	83 c8 09             	or     $0x9,%eax
  103e1e:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103e23:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103e2a:	83 e0 ef             	and    $0xffffffef,%eax
  103e2d:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103e32:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103e39:	83 e0 9f             	and    $0xffffff9f,%eax
  103e3c:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103e41:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103e48:	83 c8 80             	or     $0xffffff80,%eax
  103e4b:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103e50:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103e57:	83 e0 f0             	and    $0xfffffff0,%eax
  103e5a:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103e5f:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103e66:	83 e0 ef             	and    $0xffffffef,%eax
  103e69:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103e6e:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103e75:	83 e0 df             	and    $0xffffffdf,%eax
  103e78:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103e7d:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103e84:	83 c8 40             	or     $0x40,%eax
  103e87:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103e8c:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103e93:	83 e0 7f             	and    $0x7f,%eax
  103e96:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103e9b:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103ea0:	c1 e8 18             	shr    $0x18,%eax
  103ea3:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103ea8:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103eaf:	e8 de fe ff ff       	call   103d92 <lgdt>
  103eb4:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103eba:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103ebe:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103ec1:	c9                   	leave  
  103ec2:	c3                   	ret    

00103ec3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103ec3:	55                   	push   %ebp
  103ec4:	89 e5                	mov    %esp,%ebp
  103ec6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103ec9:	c7 05 7c af 11 00 20 	movl   $0x106c20,0x11af7c
  103ed0:	6c 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103ed3:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103ed8:	8b 00                	mov    (%eax),%eax
  103eda:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ede:	c7 04 24 bc 6c 10 00 	movl   $0x106cbc,(%esp)
  103ee5:	e8 6e c4 ff ff       	call   100358 <cprintf>
    pmm_manager->init();
  103eea:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103eef:	8b 40 04             	mov    0x4(%eax),%eax
  103ef2:	ff d0                	call   *%eax
}
  103ef4:	c9                   	leave  
  103ef5:	c3                   	ret    

00103ef6 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103ef6:	55                   	push   %ebp
  103ef7:	89 e5                	mov    %esp,%ebp
  103ef9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103efc:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103f01:	8b 40 08             	mov    0x8(%eax),%eax
  103f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  103f07:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  103f0e:	89 14 24             	mov    %edx,(%esp)
  103f11:	ff d0                	call   *%eax
}
  103f13:	c9                   	leave  
  103f14:	c3                   	ret    

00103f15 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103f15:	55                   	push   %ebp
  103f16:	89 e5                	mov    %esp,%ebp
  103f18:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103f1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103f22:	e8 2e fe ff ff       	call   103d55 <__intr_save>
  103f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103f2a:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103f2f:	8b 40 0c             	mov    0xc(%eax),%eax
  103f32:	8b 55 08             	mov    0x8(%ebp),%edx
  103f35:	89 14 24             	mov    %edx,(%esp)
  103f38:	ff d0                	call   *%eax
  103f3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f40:	89 04 24             	mov    %eax,(%esp)
  103f43:	e8 37 fe ff ff       	call   103d7f <__intr_restore>
    return page;
  103f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103f4b:	c9                   	leave  
  103f4c:	c3                   	ret    

00103f4d <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103f4d:	55                   	push   %ebp
  103f4e:	89 e5                	mov    %esp,%ebp
  103f50:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103f53:	e8 fd fd ff ff       	call   103d55 <__intr_save>
  103f58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103f5b:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103f60:	8b 40 10             	mov    0x10(%eax),%eax
  103f63:	8b 55 0c             	mov    0xc(%ebp),%edx
  103f66:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f6a:	8b 55 08             	mov    0x8(%ebp),%edx
  103f6d:	89 14 24             	mov    %edx,(%esp)
  103f70:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f75:	89 04 24             	mov    %eax,(%esp)
  103f78:	e8 02 fe ff ff       	call   103d7f <__intr_restore>
}
  103f7d:	c9                   	leave  
  103f7e:	c3                   	ret    

00103f7f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103f7f:	55                   	push   %ebp
  103f80:	89 e5                	mov    %esp,%ebp
  103f82:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103f85:	e8 cb fd ff ff       	call   103d55 <__intr_save>
  103f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103f8d:	a1 7c af 11 00       	mov    0x11af7c,%eax
  103f92:	8b 40 14             	mov    0x14(%eax),%eax
  103f95:	ff d0                	call   *%eax
  103f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f9d:	89 04 24             	mov    %eax,(%esp)
  103fa0:	e8 da fd ff ff       	call   103d7f <__intr_restore>
    return ret;
  103fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103fa8:	c9                   	leave  
  103fa9:	c3                   	ret    

00103faa <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103faa:	55                   	push   %ebp
  103fab:	89 e5                	mov    %esp,%ebp
  103fad:	57                   	push   %edi
  103fae:	56                   	push   %esi
  103faf:	53                   	push   %ebx
  103fb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103fb6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103fbd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103fc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103fcb:	c7 04 24 d3 6c 10 00 	movl   $0x106cd3,(%esp)
  103fd2:	e8 81 c3 ff ff       	call   100358 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103fd7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fde:	e9 15 01 00 00       	jmp    1040f8 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103fe3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fe6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fe9:	89 d0                	mov    %edx,%eax
  103feb:	c1 e0 02             	shl    $0x2,%eax
  103fee:	01 d0                	add    %edx,%eax
  103ff0:	c1 e0 02             	shl    $0x2,%eax
  103ff3:	01 c8                	add    %ecx,%eax
  103ff5:	8b 50 08             	mov    0x8(%eax),%edx
  103ff8:	8b 40 04             	mov    0x4(%eax),%eax
  103ffb:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103ffe:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104001:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104004:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104007:	89 d0                	mov    %edx,%eax
  104009:	c1 e0 02             	shl    $0x2,%eax
  10400c:	01 d0                	add    %edx,%eax
  10400e:	c1 e0 02             	shl    $0x2,%eax
  104011:	01 c8                	add    %ecx,%eax
  104013:	8b 48 0c             	mov    0xc(%eax),%ecx
  104016:	8b 58 10             	mov    0x10(%eax),%ebx
  104019:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10401c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10401f:	01 c8                	add    %ecx,%eax
  104021:	11 da                	adc    %ebx,%edx
  104023:	89 45 b0             	mov    %eax,-0x50(%ebp)
  104026:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104029:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10402c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10402f:	89 d0                	mov    %edx,%eax
  104031:	c1 e0 02             	shl    $0x2,%eax
  104034:	01 d0                	add    %edx,%eax
  104036:	c1 e0 02             	shl    $0x2,%eax
  104039:	01 c8                	add    %ecx,%eax
  10403b:	83 c0 14             	add    $0x14,%eax
  10403e:	8b 00                	mov    (%eax),%eax
  104040:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104046:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104049:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10404c:	83 c0 ff             	add    $0xffffffff,%eax
  10404f:	83 d2 ff             	adc    $0xffffffff,%edx
  104052:	89 c6                	mov    %eax,%esi
  104054:	89 d7                	mov    %edx,%edi
  104056:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104059:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10405c:	89 d0                	mov    %edx,%eax
  10405e:	c1 e0 02             	shl    $0x2,%eax
  104061:	01 d0                	add    %edx,%eax
  104063:	c1 e0 02             	shl    $0x2,%eax
  104066:	01 c8                	add    %ecx,%eax
  104068:	8b 48 0c             	mov    0xc(%eax),%ecx
  10406b:	8b 58 10             	mov    0x10(%eax),%ebx
  10406e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104074:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  104078:	89 74 24 14          	mov    %esi,0x14(%esp)
  10407c:	89 7c 24 18          	mov    %edi,0x18(%esp)
  104080:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104083:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104086:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10408a:	89 54 24 10          	mov    %edx,0x10(%esp)
  10408e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104092:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104096:	c7 04 24 e0 6c 10 00 	movl   $0x106ce0,(%esp)
  10409d:	e8 b6 c2 ff ff       	call   100358 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  1040a2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040a8:	89 d0                	mov    %edx,%eax
  1040aa:	c1 e0 02             	shl    $0x2,%eax
  1040ad:	01 d0                	add    %edx,%eax
  1040af:	c1 e0 02             	shl    $0x2,%eax
  1040b2:	01 c8                	add    %ecx,%eax
  1040b4:	83 c0 14             	add    $0x14,%eax
  1040b7:	8b 00                	mov    (%eax),%eax
  1040b9:	83 f8 01             	cmp    $0x1,%eax
  1040bc:	75 36                	jne    1040f4 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  1040be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1040c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1040c4:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  1040c7:	77 2b                	ja     1040f4 <page_init+0x14a>
  1040c9:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  1040cc:	72 05                	jb     1040d3 <page_init+0x129>
  1040ce:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  1040d1:	73 21                	jae    1040f4 <page_init+0x14a>
  1040d3:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  1040d7:	77 1b                	ja     1040f4 <page_init+0x14a>
  1040d9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  1040dd:	72 09                	jb     1040e8 <page_init+0x13e>
  1040df:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  1040e6:	77 0c                	ja     1040f4 <page_init+0x14a>
                maxpa = end;
  1040e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1040eb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1040ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1040f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  1040f4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1040f8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1040fb:	8b 00                	mov    (%eax),%eax
  1040fd:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104100:	0f 8f dd fe ff ff    	jg     103fe3 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10410a:	72 1d                	jb     104129 <page_init+0x17f>
  10410c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104110:	77 09                	ja     10411b <page_init+0x171>
  104112:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  104119:	76 0e                	jbe    104129 <page_init+0x17f>
        maxpa = KMEMSIZE;
  10411b:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104122:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104129:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10412c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10412f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104133:	c1 ea 0c             	shr    $0xc,%edx
  104136:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  10413b:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  104142:	b8 88 af 11 00       	mov    $0x11af88,%eax
  104147:	8d 50 ff             	lea    -0x1(%eax),%edx
  10414a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10414d:	01 d0                	add    %edx,%eax
  10414f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104152:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104155:	ba 00 00 00 00       	mov    $0x0,%edx
  10415a:	f7 75 ac             	divl   -0x54(%ebp)
  10415d:	89 d0                	mov    %edx,%eax
  10415f:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104162:	29 c2                	sub    %eax,%edx
  104164:	89 d0                	mov    %edx,%eax
  104166:	a3 84 af 11 00       	mov    %eax,0x11af84

    for (i = 0; i < npage; i ++) {
  10416b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104172:	eb 2f                	jmp    1041a3 <page_init+0x1f9>
        SetPageReserved(pages + i);
  104174:	8b 0d 84 af 11 00    	mov    0x11af84,%ecx
  10417a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10417d:	89 d0                	mov    %edx,%eax
  10417f:	c1 e0 02             	shl    $0x2,%eax
  104182:	01 d0                	add    %edx,%eax
  104184:	c1 e0 02             	shl    $0x2,%eax
  104187:	01 c8                	add    %ecx,%eax
  104189:	83 c0 04             	add    $0x4,%eax
  10418c:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  104193:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104196:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104199:	8b 55 90             	mov    -0x70(%ebp),%edx
  10419c:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  10419f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1041a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041a6:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1041ab:	39 c2                	cmp    %eax,%edx
  1041ad:	72 c5                	jb     104174 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  1041af:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1041b5:	89 d0                	mov    %edx,%eax
  1041b7:	c1 e0 02             	shl    $0x2,%eax
  1041ba:	01 d0                	add    %edx,%eax
  1041bc:	c1 e0 02             	shl    $0x2,%eax
  1041bf:	89 c2                	mov    %eax,%edx
  1041c1:	a1 84 af 11 00       	mov    0x11af84,%eax
  1041c6:	01 d0                	add    %edx,%eax
  1041c8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  1041cb:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  1041d2:	77 23                	ja     1041f7 <page_init+0x24d>
  1041d4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1041d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1041db:	c7 44 24 08 10 6d 10 	movl   $0x106d10,0x8(%esp)
  1041e2:	00 
  1041e3:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1041ea:	00 
  1041eb:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1041f2:	e8 f5 ca ff ff       	call   100cec <__panic>
  1041f7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1041fa:	05 00 00 00 40       	add    $0x40000000,%eax
  1041ff:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104202:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104209:	e9 74 01 00 00       	jmp    104382 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10420e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104211:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104214:	89 d0                	mov    %edx,%eax
  104216:	c1 e0 02             	shl    $0x2,%eax
  104219:	01 d0                	add    %edx,%eax
  10421b:	c1 e0 02             	shl    $0x2,%eax
  10421e:	01 c8                	add    %ecx,%eax
  104220:	8b 50 08             	mov    0x8(%eax),%edx
  104223:	8b 40 04             	mov    0x4(%eax),%eax
  104226:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104229:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10422c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10422f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104232:	89 d0                	mov    %edx,%eax
  104234:	c1 e0 02             	shl    $0x2,%eax
  104237:	01 d0                	add    %edx,%eax
  104239:	c1 e0 02             	shl    $0x2,%eax
  10423c:	01 c8                	add    %ecx,%eax
  10423e:	8b 48 0c             	mov    0xc(%eax),%ecx
  104241:	8b 58 10             	mov    0x10(%eax),%ebx
  104244:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104247:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10424a:	01 c8                	add    %ecx,%eax
  10424c:	11 da                	adc    %ebx,%edx
  10424e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104251:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104254:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104257:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10425a:	89 d0                	mov    %edx,%eax
  10425c:	c1 e0 02             	shl    $0x2,%eax
  10425f:	01 d0                	add    %edx,%eax
  104261:	c1 e0 02             	shl    $0x2,%eax
  104264:	01 c8                	add    %ecx,%eax
  104266:	83 c0 14             	add    $0x14,%eax
  104269:	8b 00                	mov    (%eax),%eax
  10426b:	83 f8 01             	cmp    $0x1,%eax
  10426e:	0f 85 0a 01 00 00    	jne    10437e <page_init+0x3d4>
            if (begin < freemem) {
  104274:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104277:	ba 00 00 00 00       	mov    $0x0,%edx
  10427c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10427f:	72 17                	jb     104298 <page_init+0x2ee>
  104281:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104284:	77 05                	ja     10428b <page_init+0x2e1>
  104286:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  104289:	76 0d                	jbe    104298 <page_init+0x2ee>
                begin = freemem;
  10428b:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10428e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104291:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104298:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  10429c:	72 1d                	jb     1042bb <page_init+0x311>
  10429e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1042a2:	77 09                	ja     1042ad <page_init+0x303>
  1042a4:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1042ab:	76 0e                	jbe    1042bb <page_init+0x311>
                end = KMEMSIZE;
  1042ad:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1042b4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1042bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1042be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042c1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1042c4:	0f 87 b4 00 00 00    	ja     10437e <page_init+0x3d4>
  1042ca:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1042cd:	72 09                	jb     1042d8 <page_init+0x32e>
  1042cf:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1042d2:	0f 83 a6 00 00 00    	jae    10437e <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  1042d8:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  1042df:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1042e2:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1042e5:	01 d0                	add    %edx,%eax
  1042e7:	83 e8 01             	sub    $0x1,%eax
  1042ea:	89 45 98             	mov    %eax,-0x68(%ebp)
  1042ed:	8b 45 98             	mov    -0x68(%ebp),%eax
  1042f0:	ba 00 00 00 00       	mov    $0x0,%edx
  1042f5:	f7 75 9c             	divl   -0x64(%ebp)
  1042f8:	89 d0                	mov    %edx,%eax
  1042fa:	8b 55 98             	mov    -0x68(%ebp),%edx
  1042fd:	29 c2                	sub    %eax,%edx
  1042ff:	89 d0                	mov    %edx,%eax
  104301:	ba 00 00 00 00       	mov    $0x0,%edx
  104306:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104309:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10430c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10430f:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104312:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104315:	ba 00 00 00 00       	mov    $0x0,%edx
  10431a:	89 c7                	mov    %eax,%edi
  10431c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  104322:	89 7d 80             	mov    %edi,-0x80(%ebp)
  104325:	89 d0                	mov    %edx,%eax
  104327:	83 e0 00             	and    $0x0,%eax
  10432a:	89 45 84             	mov    %eax,-0x7c(%ebp)
  10432d:	8b 45 80             	mov    -0x80(%ebp),%eax
  104330:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104333:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104336:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104339:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10433c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10433f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104342:	77 3a                	ja     10437e <page_init+0x3d4>
  104344:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104347:	72 05                	jb     10434e <page_init+0x3a4>
  104349:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10434c:	73 30                	jae    10437e <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10434e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  104351:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104354:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104357:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10435a:	29 c8                	sub    %ecx,%eax
  10435c:	19 da                	sbb    %ebx,%edx
  10435e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104362:	c1 ea 0c             	shr    $0xc,%edx
  104365:	89 c3                	mov    %eax,%ebx
  104367:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10436a:	89 04 24             	mov    %eax,(%esp)
  10436d:	e8 a5 f8 ff ff       	call   103c17 <pa2page>
  104372:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104376:	89 04 24             	mov    %eax,(%esp)
  104379:	e8 78 fb ff ff       	call   103ef6 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  10437e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104382:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104385:	8b 00                	mov    (%eax),%eax
  104387:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10438a:	0f 8f 7e fe ff ff    	jg     10420e <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  104390:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104396:	5b                   	pop    %ebx
  104397:	5e                   	pop    %esi
  104398:	5f                   	pop    %edi
  104399:	5d                   	pop    %ebp
  10439a:	c3                   	ret    

0010439b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10439b:	55                   	push   %ebp
  10439c:	89 e5                	mov    %esp,%ebp
  10439e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1043a1:	8b 45 14             	mov    0x14(%ebp),%eax
  1043a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1043a7:	31 d0                	xor    %edx,%eax
  1043a9:	25 ff 0f 00 00       	and    $0xfff,%eax
  1043ae:	85 c0                	test   %eax,%eax
  1043b0:	74 24                	je     1043d6 <boot_map_segment+0x3b>
  1043b2:	c7 44 24 0c 42 6d 10 	movl   $0x106d42,0xc(%esp)
  1043b9:	00 
  1043ba:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1043c1:	00 
  1043c2:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1043c9:	00 
  1043ca:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1043d1:	e8 16 c9 ff ff       	call   100cec <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1043d6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1043dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043e0:	25 ff 0f 00 00       	and    $0xfff,%eax
  1043e5:	89 c2                	mov    %eax,%edx
  1043e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1043ea:	01 c2                	add    %eax,%edx
  1043ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043ef:	01 d0                	add    %edx,%eax
  1043f1:	83 e8 01             	sub    $0x1,%eax
  1043f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1043f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1043fa:	ba 00 00 00 00       	mov    $0x0,%edx
  1043ff:	f7 75 f0             	divl   -0x10(%ebp)
  104402:	89 d0                	mov    %edx,%eax
  104404:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104407:	29 c2                	sub    %eax,%edx
  104409:	89 d0                	mov    %edx,%eax
  10440b:	c1 e8 0c             	shr    $0xc,%eax
  10440e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104411:	8b 45 0c             	mov    0xc(%ebp),%eax
  104414:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104417:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10441a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10441f:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  104422:	8b 45 14             	mov    0x14(%ebp),%eax
  104425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10442b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104430:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104433:	eb 6b                	jmp    1044a0 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104435:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10443c:	00 
  10443d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104440:	89 44 24 04          	mov    %eax,0x4(%esp)
  104444:	8b 45 08             	mov    0x8(%ebp),%eax
  104447:	89 04 24             	mov    %eax,(%esp)
  10444a:	e8 82 01 00 00       	call   1045d1 <get_pte>
  10444f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  104452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104456:	75 24                	jne    10447c <boot_map_segment+0xe1>
  104458:	c7 44 24 0c 6e 6d 10 	movl   $0x106d6e,0xc(%esp)
  10445f:	00 
  104460:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104467:	00 
  104468:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  10446f:	00 
  104470:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104477:	e8 70 c8 ff ff       	call   100cec <__panic>
        *ptep = pa | PTE_P | perm;
  10447c:	8b 45 18             	mov    0x18(%ebp),%eax
  10447f:	8b 55 14             	mov    0x14(%ebp),%edx
  104482:	09 d0                	or     %edx,%eax
  104484:	83 c8 01             	or     $0x1,%eax
  104487:	89 c2                	mov    %eax,%edx
  104489:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10448c:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10448e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104492:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104499:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1044a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1044a4:	75 8f                	jne    104435 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1044a6:	c9                   	leave  
  1044a7:	c3                   	ret    

001044a8 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1044a8:	55                   	push   %ebp
  1044a9:	89 e5                	mov    %esp,%ebp
  1044ab:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1044ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1044b5:	e8 5b fa ff ff       	call   103f15 <alloc_pages>
  1044ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1044bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1044c1:	75 1c                	jne    1044df <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1044c3:	c7 44 24 08 7b 6d 10 	movl   $0x106d7b,0x8(%esp)
  1044ca:	00 
  1044cb:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1044d2:	00 
  1044d3:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1044da:	e8 0d c8 ff ff       	call   100cec <__panic>
    }
    return page2kva(p);
  1044df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044e2:	89 04 24             	mov    %eax,(%esp)
  1044e5:	e8 7c f7 ff ff       	call   103c66 <page2kva>
}
  1044ea:	c9                   	leave  
  1044eb:	c3                   	ret    

001044ec <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1044ec:	55                   	push   %ebp
  1044ed:	89 e5                	mov    %esp,%ebp
  1044ef:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1044f2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1044f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1044fa:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104501:	77 23                	ja     104526 <pmm_init+0x3a>
  104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10450a:	c7 44 24 08 10 6d 10 	movl   $0x106d10,0x8(%esp)
  104511:	00 
  104512:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104519:	00 
  10451a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104521:	e8 c6 c7 ff ff       	call   100cec <__panic>
  104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104529:	05 00 00 00 40       	add    $0x40000000,%eax
  10452e:	a3 80 af 11 00       	mov    %eax,0x11af80
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  104533:	e8 8b f9 ff ff       	call   103ec3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104538:	e8 6d fa ff ff       	call   103faa <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10453d:	e8 fd 03 00 00       	call   10493f <check_alloc_page>

    check_pgdir();
  104542:	e8 16 04 00 00       	call   10495d <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104547:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10454c:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  104552:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104557:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10455a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104561:	77 23                	ja     104586 <pmm_init+0x9a>
  104563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104566:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10456a:	c7 44 24 08 10 6d 10 	movl   $0x106d10,0x8(%esp)
  104571:	00 
  104572:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104579:	00 
  10457a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104581:	e8 66 c7 ff ff       	call   100cec <__panic>
  104586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104589:	05 00 00 00 40       	add    $0x40000000,%eax
  10458e:	83 c8 03             	or     $0x3,%eax
  104591:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  104593:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104598:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10459f:	00 
  1045a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1045a7:	00 
  1045a8:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1045af:	38 
  1045b0:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1045b7:	c0 
  1045b8:	89 04 24             	mov    %eax,(%esp)
  1045bb:	e8 db fd ff ff       	call   10439b <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1045c0:	e8 0f f8 ff ff       	call   103dd4 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1045c5:	e8 2e 0a 00 00       	call   104ff8 <check_boot_pgdir>

    print_pgdir();
  1045ca:	e8 b6 0e 00 00       	call   105485 <print_pgdir>

}
  1045cf:	c9                   	leave  
  1045d0:	c3                   	ret    

001045d1 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1045d1:	55                   	push   %ebp
  1045d2:	89 e5                	mov    %esp,%ebp
  1045d4:	83 ec 48             	sub    $0x48,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
   pde_t *pdep = NULL;
  1045d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    uintptr_t pde = PDX(la);
  1045de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045e1:	c1 e8 16             	shr    $0x16,%eax
  1045e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    pdep = &pgdir[pde];
  1045e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1045f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1045f4:	01 d0                	add    %edx,%eax
  1045f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 非present也就是不存在这样的page（缺页），需要分配页
    if (!(*pdep & PTE_P)) {
  1045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045fc:	8b 00                	mov    (%eax),%eax
  1045fe:	83 e0 01             	and    $0x1,%eax
  104601:	85 c0                	test   %eax,%eax
  104603:	0f 85 af 00 00 00    	jne    1046b8 <get_pte+0xe7>
        struct Page *p;
        // 如果不需要分配或者分配的页为NULL
        if (!create || (p = alloc_page()) == NULL) {
  104609:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10460d:	74 15                	je     104624 <get_pte+0x53>
  10460f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104616:	e8 fa f8 ff ff       	call   103f15 <alloc_pages>
  10461b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10461e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104622:	75 0a                	jne    10462e <get_pte+0x5d>
            return NULL;
  104624:	b8 00 00 00 00       	mov    $0x0,%eax
  104629:	e9 fb 00 00 00       	jmp    104729 <get_pte+0x158>
        }
        set_page_ref(p, 1);
  10462e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104635:	00 
  104636:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104639:	89 04 24             	mov    %eax,(%esp)
  10463c:	e8 d9 f6 ff ff       	call   103d1a <set_page_ref>
        // page table的索引值（PTE)
        uintptr_t pti = page2pa(p);
  104641:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104644:	89 04 24             	mov    %eax,(%esp)
  104647:	e8 b5 f5 ff ff       	call   103c01 <page2pa>
  10464c:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // KADDR: takes a physical address and returns the corresponding kernel virtual address.
        memset(KADDR(pti), 0, sizeof(struct Page));
  10464f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104652:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104658:	c1 e8 0c             	shr    $0xc,%eax
  10465b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10465e:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104663:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104666:	72 23                	jb     10468b <get_pte+0xba>
  104668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10466b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10466f:	c7 44 24 08 6c 6c 10 	movl   $0x106c6c,0x8(%esp)
  104676:	00 
  104677:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  10467e:	00 
  10467f:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104686:	e8 61 c6 ff ff       	call   100cec <__panic>
  10468b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10468e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104693:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  10469a:	00 
  10469b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1046a2:	00 
  1046a3:	89 04 24             	mov    %eax,(%esp)
  1046a6:	e8 f8 18 00 00       	call   105fa3 <memset>

        // 相当于把物理地址给了pdep
        // pdep: page directory entry point
        *pdep = pti | PTE_P | PTE_W | PTE_U;
  1046ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046ae:	83 c8 07             	or     $0x7,%eax
  1046b1:	89 c2                	mov    %eax,%edx
  1046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046b6:	89 10                	mov    %edx,(%eax)
    // address in page table or page directory entry
    // 0xFFF = 111111111111
    // ~0xFFF = 1111111111 1111111111 000000000000
    // #define PTE_ADDR(pte)   ((uintptr_t)(pte) & ~0xFFF)
    // #define PDE_ADDR(pde)   PTE_ADDR(pde)
    uintptr_t pa = PDE_ADDR(*pdep);
  1046b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046bb:	8b 00                	mov    (%eax),%eax
  1046bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1046c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    // 再转换为虚拟地址（线性地址）
    // KADDR = pa >> 12 + 0xC0000000
    // 0xC0000000 = 11000000 00000000 00000000 00000000
    pte_t *pde_kva = KADDR(pa);
  1046c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1046c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1046cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046ce:	c1 e8 0c             	shr    $0xc,%eax
  1046d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1046d4:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1046d9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  1046dc:	72 23                	jb     104701 <get_pte+0x130>
  1046de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1046e5:	c7 44 24 08 6c 6c 10 	movl   $0x106c6c,0x8(%esp)
  1046ec:	00 
  1046ed:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  1046f4:	00 
  1046f5:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1046fc:	e8 eb c5 ff ff       	call   100cec <__panic>
  104701:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104704:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104709:	89 45 d0             	mov    %eax,-0x30(%ebp)
    
    // 需要映射的线性地址
    // 中间10位(PTE)
    uintptr_t need_to_map_ptx = PTX(la);
  10470c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10470f:	c1 e8 0c             	shr    $0xc,%eax
  104712:	25 ff 03 00 00       	and    $0x3ff,%eax
  104717:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return &pde_kva[need_to_map_ptx];
  10471a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10471d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104724:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104727:	01 d0                	add    %edx,%eax
}
  104729:	c9                   	leave  
  10472a:	c3                   	ret    

0010472b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10472b:	55                   	push   %ebp
  10472c:	89 e5                	mov    %esp,%ebp
  10472e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104731:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104738:	00 
  104739:	8b 45 0c             	mov    0xc(%ebp),%eax
  10473c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104740:	8b 45 08             	mov    0x8(%ebp),%eax
  104743:	89 04 24             	mov    %eax,(%esp)
  104746:	e8 86 fe ff ff       	call   1045d1 <get_pte>
  10474b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10474e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104752:	74 08                	je     10475c <get_page+0x31>
        *ptep_store = ptep;
  104754:	8b 45 10             	mov    0x10(%ebp),%eax
  104757:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10475a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10475c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104760:	74 1b                	je     10477d <get_page+0x52>
  104762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104765:	8b 00                	mov    (%eax),%eax
  104767:	83 e0 01             	and    $0x1,%eax
  10476a:	85 c0                	test   %eax,%eax
  10476c:	74 0f                	je     10477d <get_page+0x52>
        return pte2page(*ptep);
  10476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104771:	8b 00                	mov    (%eax),%eax
  104773:	89 04 24             	mov    %eax,(%esp)
  104776:	e8 3f f5 ff ff       	call   103cba <pte2page>
  10477b:	eb 05                	jmp    104782 <get_page+0x57>
    }
    return NULL;
  10477d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104782:	c9                   	leave  
  104783:	c3                   	ret    

00104784 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104784:	55                   	push   %ebp
  104785:	89 e5                	mov    %esp,%ebp
  104787:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  10478a:	8b 45 10             	mov    0x10(%ebp),%eax
  10478d:	8b 00                	mov    (%eax),%eax
  10478f:	83 e0 01             	and    $0x1,%eax
  104792:	85 c0                	test   %eax,%eax
  104794:	74 4d                	je     1047e3 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  104796:	8b 45 10             	mov    0x10(%ebp),%eax
  104799:	8b 00                	mov    (%eax),%eax
  10479b:	89 04 24             	mov    %eax,(%esp)
  10479e:	e8 17 f5 ff ff       	call   103cba <pte2page>
  1047a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  1047a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047a9:	89 04 24             	mov    %eax,(%esp)
  1047ac:	e8 8d f5 ff ff       	call   103d3e <page_ref_dec>
  1047b1:	85 c0                	test   %eax,%eax
  1047b3:	75 13                	jne    1047c8 <page_remove_pte+0x44>
            free_page(page);
  1047b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1047bc:	00 
  1047bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047c0:	89 04 24             	mov    %eax,(%esp)
  1047c3:	e8 85 f7 ff ff       	call   103f4d <free_pages>
        }
        *ptep = 0;
  1047c8:	8b 45 10             	mov    0x10(%ebp),%eax
  1047cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  1047d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1047db:	89 04 24             	mov    %eax,(%esp)
  1047de:	e8 ff 00 00 00       	call   1048e2 <tlb_invalidate>
    }
}
  1047e3:	c9                   	leave  
  1047e4:	c3                   	ret    

001047e5 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1047e5:	55                   	push   %ebp
  1047e6:	89 e5                	mov    %esp,%ebp
  1047e8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1047eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1047f2:	00 
  1047f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1047fd:	89 04 24             	mov    %eax,(%esp)
  104800:	e8 cc fd ff ff       	call   1045d1 <get_pte>
  104805:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104808:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10480c:	74 19                	je     104827 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104811:	89 44 24 08          	mov    %eax,0x8(%esp)
  104815:	8b 45 0c             	mov    0xc(%ebp),%eax
  104818:	89 44 24 04          	mov    %eax,0x4(%esp)
  10481c:	8b 45 08             	mov    0x8(%ebp),%eax
  10481f:	89 04 24             	mov    %eax,(%esp)
  104822:	e8 5d ff ff ff       	call   104784 <page_remove_pte>
    }
}
  104827:	c9                   	leave  
  104828:	c3                   	ret    

00104829 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104829:	55                   	push   %ebp
  10482a:	89 e5                	mov    %esp,%ebp
  10482c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10482f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104836:	00 
  104837:	8b 45 10             	mov    0x10(%ebp),%eax
  10483a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10483e:	8b 45 08             	mov    0x8(%ebp),%eax
  104841:	89 04 24             	mov    %eax,(%esp)
  104844:	e8 88 fd ff ff       	call   1045d1 <get_pte>
  104849:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10484c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104850:	75 0a                	jne    10485c <page_insert+0x33>
        return -E_NO_MEM;
  104852:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  104857:	e9 84 00 00 00       	jmp    1048e0 <page_insert+0xb7>
    }
    page_ref_inc(page);
  10485c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10485f:	89 04 24             	mov    %eax,(%esp)
  104862:	e8 c0 f4 ff ff       	call   103d27 <page_ref_inc>
    if (*ptep & PTE_P) {
  104867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10486a:	8b 00                	mov    (%eax),%eax
  10486c:	83 e0 01             	and    $0x1,%eax
  10486f:	85 c0                	test   %eax,%eax
  104871:	74 3e                	je     1048b1 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104876:	8b 00                	mov    (%eax),%eax
  104878:	89 04 24             	mov    %eax,(%esp)
  10487b:	e8 3a f4 ff ff       	call   103cba <pte2page>
  104880:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  104883:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104886:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104889:	75 0d                	jne    104898 <page_insert+0x6f>
            page_ref_dec(page);
  10488b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10488e:	89 04 24             	mov    %eax,(%esp)
  104891:	e8 a8 f4 ff ff       	call   103d3e <page_ref_dec>
  104896:	eb 19                	jmp    1048b1 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104898:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10489b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10489f:	8b 45 10             	mov    0x10(%ebp),%eax
  1048a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1048a9:	89 04 24             	mov    %eax,(%esp)
  1048ac:	e8 d3 fe ff ff       	call   104784 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1048b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048b4:	89 04 24             	mov    %eax,(%esp)
  1048b7:	e8 45 f3 ff ff       	call   103c01 <page2pa>
  1048bc:	0b 45 14             	or     0x14(%ebp),%eax
  1048bf:	83 c8 01             	or     $0x1,%eax
  1048c2:	89 c2                	mov    %eax,%edx
  1048c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048c7:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1048c9:	8b 45 10             	mov    0x10(%ebp),%eax
  1048cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1048d3:	89 04 24             	mov    %eax,(%esp)
  1048d6:	e8 07 00 00 00       	call   1048e2 <tlb_invalidate>
    return 0;
  1048db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1048e0:	c9                   	leave  
  1048e1:	c3                   	ret    

001048e2 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1048e2:	55                   	push   %ebp
  1048e3:	89 e5                	mov    %esp,%ebp
  1048e5:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1048e8:	0f 20 d8             	mov    %cr3,%eax
  1048eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1048ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  1048f1:	89 c2                	mov    %eax,%edx
  1048f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1048f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1048f9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104900:	77 23                	ja     104925 <tlb_invalidate+0x43>
  104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104905:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104909:	c7 44 24 08 10 6d 10 	movl   $0x106d10,0x8(%esp)
  104910:	00 
  104911:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104918:	00 
  104919:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104920:	e8 c7 c3 ff ff       	call   100cec <__panic>
  104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104928:	05 00 00 00 40       	add    $0x40000000,%eax
  10492d:	39 c2                	cmp    %eax,%edx
  10492f:	75 0c                	jne    10493d <tlb_invalidate+0x5b>
        invlpg((void *)la);
  104931:	8b 45 0c             	mov    0xc(%ebp),%eax
  104934:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104937:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10493a:	0f 01 38             	invlpg (%eax)
    }
}
  10493d:	c9                   	leave  
  10493e:	c3                   	ret    

0010493f <check_alloc_page>:

static void
check_alloc_page(void) {
  10493f:	55                   	push   %ebp
  104940:	89 e5                	mov    %esp,%ebp
  104942:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  104945:	a1 7c af 11 00       	mov    0x11af7c,%eax
  10494a:	8b 40 18             	mov    0x18(%eax),%eax
  10494d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10494f:	c7 04 24 94 6d 10 00 	movl   $0x106d94,(%esp)
  104956:	e8 fd b9 ff ff       	call   100358 <cprintf>
}
  10495b:	c9                   	leave  
  10495c:	c3                   	ret    

0010495d <check_pgdir>:

static void
check_pgdir(void) {
  10495d:	55                   	push   %ebp
  10495e:	89 e5                	mov    %esp,%ebp
  104960:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104963:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104968:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10496d:	76 24                	jbe    104993 <check_pgdir+0x36>
  10496f:	c7 44 24 0c b3 6d 10 	movl   $0x106db3,0xc(%esp)
  104976:	00 
  104977:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  10497e:	00 
  10497f:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104986:	00 
  104987:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  10498e:	e8 59 c3 ff ff       	call   100cec <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104993:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104998:	85 c0                	test   %eax,%eax
  10499a:	74 0e                	je     1049aa <check_pgdir+0x4d>
  10499c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049a1:	25 ff 0f 00 00       	and    $0xfff,%eax
  1049a6:	85 c0                	test   %eax,%eax
  1049a8:	74 24                	je     1049ce <check_pgdir+0x71>
  1049aa:	c7 44 24 0c d0 6d 10 	movl   $0x106dd0,0xc(%esp)
  1049b1:	00 
  1049b2:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1049b9:	00 
  1049ba:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  1049c1:	00 
  1049c2:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1049c9:	e8 1e c3 ff ff       	call   100cec <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1049ce:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049da:	00 
  1049db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1049e2:	00 
  1049e3:	89 04 24             	mov    %eax,(%esp)
  1049e6:	e8 40 fd ff ff       	call   10472b <get_page>
  1049eb:	85 c0                	test   %eax,%eax
  1049ed:	74 24                	je     104a13 <check_pgdir+0xb6>
  1049ef:	c7 44 24 0c 08 6e 10 	movl   $0x106e08,0xc(%esp)
  1049f6:	00 
  1049f7:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1049fe:	00 
  1049ff:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104a06:	00 
  104a07:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104a0e:	e8 d9 c2 ff ff       	call   100cec <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a1a:	e8 f6 f4 ff ff       	call   103f15 <alloc_pages>
  104a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104a22:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104a2e:	00 
  104a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a36:	00 
  104a37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104a3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a3e:	89 04 24             	mov    %eax,(%esp)
  104a41:	e8 e3 fd ff ff       	call   104829 <page_insert>
  104a46:	85 c0                	test   %eax,%eax
  104a48:	74 24                	je     104a6e <check_pgdir+0x111>
  104a4a:	c7 44 24 0c 30 6e 10 	movl   $0x106e30,0xc(%esp)
  104a51:	00 
  104a52:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104a59:	00 
  104a5a:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104a61:	00 
  104a62:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104a69:	e8 7e c2 ff ff       	call   100cec <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104a6e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a7a:	00 
  104a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104a82:	00 
  104a83:	89 04 24             	mov    %eax,(%esp)
  104a86:	e8 46 fb ff ff       	call   1045d1 <get_pte>
  104a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a92:	75 24                	jne    104ab8 <check_pgdir+0x15b>
  104a94:	c7 44 24 0c 5c 6e 10 	movl   $0x106e5c,0xc(%esp)
  104a9b:	00 
  104a9c:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104aa3:	00 
  104aa4:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104aab:	00 
  104aac:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104ab3:	e8 34 c2 ff ff       	call   100cec <__panic>
    assert(pte2page(*ptep) == p1);
  104ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104abb:	8b 00                	mov    (%eax),%eax
  104abd:	89 04 24             	mov    %eax,(%esp)
  104ac0:	e8 f5 f1 ff ff       	call   103cba <pte2page>
  104ac5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104ac8:	74 24                	je     104aee <check_pgdir+0x191>
  104aca:	c7 44 24 0c 89 6e 10 	movl   $0x106e89,0xc(%esp)
  104ad1:	00 
  104ad2:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104ad9:	00 
  104ada:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  104ae1:	00 
  104ae2:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104ae9:	e8 fe c1 ff ff       	call   100cec <__panic>
    assert(page_ref(p1) == 1);
  104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104af1:	89 04 24             	mov    %eax,(%esp)
  104af4:	e8 17 f2 ff ff       	call   103d10 <page_ref>
  104af9:	83 f8 01             	cmp    $0x1,%eax
  104afc:	74 24                	je     104b22 <check_pgdir+0x1c5>
  104afe:	c7 44 24 0c 9f 6e 10 	movl   $0x106e9f,0xc(%esp)
  104b05:	00 
  104b06:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104b0d:	00 
  104b0e:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104b15:	00 
  104b16:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104b1d:	e8 ca c1 ff ff       	call   100cec <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104b22:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b27:	8b 00                	mov    (%eax),%eax
  104b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b34:	c1 e8 0c             	shr    $0xc,%eax
  104b37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104b3a:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104b3f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104b42:	72 23                	jb     104b67 <check_pgdir+0x20a>
  104b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104b4b:	c7 44 24 08 6c 6c 10 	movl   $0x106c6c,0x8(%esp)
  104b52:	00 
  104b53:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104b5a:	00 
  104b5b:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104b62:	e8 85 c1 ff ff       	call   100cec <__panic>
  104b67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b6a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104b6f:	83 c0 04             	add    $0x4,%eax
  104b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104b75:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b81:	00 
  104b82:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b89:	00 
  104b8a:	89 04 24             	mov    %eax,(%esp)
  104b8d:	e8 3f fa ff ff       	call   1045d1 <get_pte>
  104b92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104b95:	74 24                	je     104bbb <check_pgdir+0x25e>
  104b97:	c7 44 24 0c b4 6e 10 	movl   $0x106eb4,0xc(%esp)
  104b9e:	00 
  104b9f:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104ba6:	00 
  104ba7:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  104bae:	00 
  104baf:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104bb6:	e8 31 c1 ff ff       	call   100cec <__panic>

    p2 = alloc_page();
  104bbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bc2:	e8 4e f3 ff ff       	call   103f15 <alloc_pages>
  104bc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104bca:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104bcf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104bd6:	00 
  104bd7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104bde:	00 
  104bdf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104be2:	89 54 24 04          	mov    %edx,0x4(%esp)
  104be6:	89 04 24             	mov    %eax,(%esp)
  104be9:	e8 3b fc ff ff       	call   104829 <page_insert>
  104bee:	85 c0                	test   %eax,%eax
  104bf0:	74 24                	je     104c16 <check_pgdir+0x2b9>
  104bf2:	c7 44 24 0c dc 6e 10 	movl   $0x106edc,0xc(%esp)
  104bf9:	00 
  104bfa:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104c01:	00 
  104c02:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104c09:	00 
  104c0a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104c11:	e8 d6 c0 ff ff       	call   100cec <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c16:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c22:	00 
  104c23:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c2a:	00 
  104c2b:	89 04 24             	mov    %eax,(%esp)
  104c2e:	e8 9e f9 ff ff       	call   1045d1 <get_pte>
  104c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c3a:	75 24                	jne    104c60 <check_pgdir+0x303>
  104c3c:	c7 44 24 0c 14 6f 10 	movl   $0x106f14,0xc(%esp)
  104c43:	00 
  104c44:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104c4b:	00 
  104c4c:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  104c53:	00 
  104c54:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104c5b:	e8 8c c0 ff ff       	call   100cec <__panic>
    assert(*ptep & PTE_U);
  104c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c63:	8b 00                	mov    (%eax),%eax
  104c65:	83 e0 04             	and    $0x4,%eax
  104c68:	85 c0                	test   %eax,%eax
  104c6a:	75 24                	jne    104c90 <check_pgdir+0x333>
  104c6c:	c7 44 24 0c 44 6f 10 	movl   $0x106f44,0xc(%esp)
  104c73:	00 
  104c74:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104c7b:	00 
  104c7c:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  104c83:	00 
  104c84:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104c8b:	e8 5c c0 ff ff       	call   100cec <__panic>
    assert(*ptep & PTE_W);
  104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c93:	8b 00                	mov    (%eax),%eax
  104c95:	83 e0 02             	and    $0x2,%eax
  104c98:	85 c0                	test   %eax,%eax
  104c9a:	75 24                	jne    104cc0 <check_pgdir+0x363>
  104c9c:	c7 44 24 0c 52 6f 10 	movl   $0x106f52,0xc(%esp)
  104ca3:	00 
  104ca4:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104cab:	00 
  104cac:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  104cb3:	00 
  104cb4:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104cbb:	e8 2c c0 ff ff       	call   100cec <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104cc0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104cc5:	8b 00                	mov    (%eax),%eax
  104cc7:	83 e0 04             	and    $0x4,%eax
  104cca:	85 c0                	test   %eax,%eax
  104ccc:	75 24                	jne    104cf2 <check_pgdir+0x395>
  104cce:	c7 44 24 0c 60 6f 10 	movl   $0x106f60,0xc(%esp)
  104cd5:	00 
  104cd6:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104cdd:	00 
  104cde:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104ce5:	00 
  104ce6:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104ced:	e8 fa bf ff ff       	call   100cec <__panic>
    assert(page_ref(p2) == 1);
  104cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cf5:	89 04 24             	mov    %eax,(%esp)
  104cf8:	e8 13 f0 ff ff       	call   103d10 <page_ref>
  104cfd:	83 f8 01             	cmp    $0x1,%eax
  104d00:	74 24                	je     104d26 <check_pgdir+0x3c9>
  104d02:	c7 44 24 0c 76 6f 10 	movl   $0x106f76,0xc(%esp)
  104d09:	00 
  104d0a:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104d11:	00 
  104d12:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104d19:	00 
  104d1a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104d21:	e8 c6 bf ff ff       	call   100cec <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104d26:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d2b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104d32:	00 
  104d33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104d3a:	00 
  104d3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  104d42:	89 04 24             	mov    %eax,(%esp)
  104d45:	e8 df fa ff ff       	call   104829 <page_insert>
  104d4a:	85 c0                	test   %eax,%eax
  104d4c:	74 24                	je     104d72 <check_pgdir+0x415>
  104d4e:	c7 44 24 0c 88 6f 10 	movl   $0x106f88,0xc(%esp)
  104d55:	00 
  104d56:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104d5d:	00 
  104d5e:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  104d65:	00 
  104d66:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104d6d:	e8 7a bf ff ff       	call   100cec <__panic>
    assert(page_ref(p1) == 2);
  104d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d75:	89 04 24             	mov    %eax,(%esp)
  104d78:	e8 93 ef ff ff       	call   103d10 <page_ref>
  104d7d:	83 f8 02             	cmp    $0x2,%eax
  104d80:	74 24                	je     104da6 <check_pgdir+0x449>
  104d82:	c7 44 24 0c b4 6f 10 	movl   $0x106fb4,0xc(%esp)
  104d89:	00 
  104d8a:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104d91:	00 
  104d92:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104d99:	00 
  104d9a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104da1:	e8 46 bf ff ff       	call   100cec <__panic>
    assert(page_ref(p2) == 0);
  104da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104da9:	89 04 24             	mov    %eax,(%esp)
  104dac:	e8 5f ef ff ff       	call   103d10 <page_ref>
  104db1:	85 c0                	test   %eax,%eax
  104db3:	74 24                	je     104dd9 <check_pgdir+0x47c>
  104db5:	c7 44 24 0c c6 6f 10 	movl   $0x106fc6,0xc(%esp)
  104dbc:	00 
  104dbd:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104dc4:	00 
  104dc5:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104dcc:	00 
  104dcd:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104dd4:	e8 13 bf ff ff       	call   100cec <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104dd9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104dde:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104de5:	00 
  104de6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104ded:	00 
  104dee:	89 04 24             	mov    %eax,(%esp)
  104df1:	e8 db f7 ff ff       	call   1045d1 <get_pte>
  104df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104df9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104dfd:	75 24                	jne    104e23 <check_pgdir+0x4c6>
  104dff:	c7 44 24 0c 14 6f 10 	movl   $0x106f14,0xc(%esp)
  104e06:	00 
  104e07:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104e0e:	00 
  104e0f:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104e16:	00 
  104e17:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104e1e:	e8 c9 be ff ff       	call   100cec <__panic>
    assert(pte2page(*ptep) == p1);
  104e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e26:	8b 00                	mov    (%eax),%eax
  104e28:	89 04 24             	mov    %eax,(%esp)
  104e2b:	e8 8a ee ff ff       	call   103cba <pte2page>
  104e30:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104e33:	74 24                	je     104e59 <check_pgdir+0x4fc>
  104e35:	c7 44 24 0c 89 6e 10 	movl   $0x106e89,0xc(%esp)
  104e3c:	00 
  104e3d:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104e44:	00 
  104e45:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  104e4c:	00 
  104e4d:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104e54:	e8 93 be ff ff       	call   100cec <__panic>
    assert((*ptep & PTE_U) == 0);
  104e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e5c:	8b 00                	mov    (%eax),%eax
  104e5e:	83 e0 04             	and    $0x4,%eax
  104e61:	85 c0                	test   %eax,%eax
  104e63:	74 24                	je     104e89 <check_pgdir+0x52c>
  104e65:	c7 44 24 0c d8 6f 10 	movl   $0x106fd8,0xc(%esp)
  104e6c:	00 
  104e6d:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104e74:	00 
  104e75:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104e7c:	00 
  104e7d:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104e84:	e8 63 be ff ff       	call   100cec <__panic>

    page_remove(boot_pgdir, 0x0);
  104e89:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104e95:	00 
  104e96:	89 04 24             	mov    %eax,(%esp)
  104e99:	e8 47 f9 ff ff       	call   1047e5 <page_remove>
    assert(page_ref(p1) == 1);
  104e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ea1:	89 04 24             	mov    %eax,(%esp)
  104ea4:	e8 67 ee ff ff       	call   103d10 <page_ref>
  104ea9:	83 f8 01             	cmp    $0x1,%eax
  104eac:	74 24                	je     104ed2 <check_pgdir+0x575>
  104eae:	c7 44 24 0c 9f 6e 10 	movl   $0x106e9f,0xc(%esp)
  104eb5:	00 
  104eb6:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104ebd:	00 
  104ebe:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  104ec5:	00 
  104ec6:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104ecd:	e8 1a be ff ff       	call   100cec <__panic>
    assert(page_ref(p2) == 0);
  104ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ed5:	89 04 24             	mov    %eax,(%esp)
  104ed8:	e8 33 ee ff ff       	call   103d10 <page_ref>
  104edd:	85 c0                	test   %eax,%eax
  104edf:	74 24                	je     104f05 <check_pgdir+0x5a8>
  104ee1:	c7 44 24 0c c6 6f 10 	movl   $0x106fc6,0xc(%esp)
  104ee8:	00 
  104ee9:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104ef0:	00 
  104ef1:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  104ef8:	00 
  104ef9:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104f00:	e8 e7 bd ff ff       	call   100cec <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104f05:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f0a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104f11:	00 
  104f12:	89 04 24             	mov    %eax,(%esp)
  104f15:	e8 cb f8 ff ff       	call   1047e5 <page_remove>
    assert(page_ref(p1) == 0);
  104f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f1d:	89 04 24             	mov    %eax,(%esp)
  104f20:	e8 eb ed ff ff       	call   103d10 <page_ref>
  104f25:	85 c0                	test   %eax,%eax
  104f27:	74 24                	je     104f4d <check_pgdir+0x5f0>
  104f29:	c7 44 24 0c ed 6f 10 	movl   $0x106fed,0xc(%esp)
  104f30:	00 
  104f31:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104f38:	00 
  104f39:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  104f40:	00 
  104f41:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104f48:	e8 9f bd ff ff       	call   100cec <__panic>
    assert(page_ref(p2) == 0);
  104f4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f50:	89 04 24             	mov    %eax,(%esp)
  104f53:	e8 b8 ed ff ff       	call   103d10 <page_ref>
  104f58:	85 c0                	test   %eax,%eax
  104f5a:	74 24                	je     104f80 <check_pgdir+0x623>
  104f5c:	c7 44 24 0c c6 6f 10 	movl   $0x106fc6,0xc(%esp)
  104f63:	00 
  104f64:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104f6b:	00 
  104f6c:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  104f73:	00 
  104f74:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104f7b:	e8 6c bd ff ff       	call   100cec <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104f80:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f85:	8b 00                	mov    (%eax),%eax
  104f87:	89 04 24             	mov    %eax,(%esp)
  104f8a:	e8 69 ed ff ff       	call   103cf8 <pde2page>
  104f8f:	89 04 24             	mov    %eax,(%esp)
  104f92:	e8 79 ed ff ff       	call   103d10 <page_ref>
  104f97:	83 f8 01             	cmp    $0x1,%eax
  104f9a:	74 24                	je     104fc0 <check_pgdir+0x663>
  104f9c:	c7 44 24 0c 00 70 10 	movl   $0x107000,0xc(%esp)
  104fa3:	00 
  104fa4:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  104fab:	00 
  104fac:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  104fb3:	00 
  104fb4:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  104fbb:	e8 2c bd ff ff       	call   100cec <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104fc0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fc5:	8b 00                	mov    (%eax),%eax
  104fc7:	89 04 24             	mov    %eax,(%esp)
  104fca:	e8 29 ed ff ff       	call   103cf8 <pde2page>
  104fcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104fd6:	00 
  104fd7:	89 04 24             	mov    %eax,(%esp)
  104fda:	e8 6e ef ff ff       	call   103f4d <free_pages>
    boot_pgdir[0] = 0;
  104fdf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fe4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104fea:	c7 04 24 27 70 10 00 	movl   $0x107027,(%esp)
  104ff1:	e8 62 b3 ff ff       	call   100358 <cprintf>
}
  104ff6:	c9                   	leave  
  104ff7:	c3                   	ret    

00104ff8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104ff8:	55                   	push   %ebp
  104ff9:	89 e5                	mov    %esp,%ebp
  104ffb:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104ffe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105005:	e9 ca 00 00 00       	jmp    1050d4 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  10500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10500d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105010:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105013:	c1 e8 0c             	shr    $0xc,%eax
  105016:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105019:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10501e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  105021:	72 23                	jb     105046 <check_boot_pgdir+0x4e>
  105023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105026:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10502a:	c7 44 24 08 6c 6c 10 	movl   $0x106c6c,0x8(%esp)
  105031:	00 
  105032:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  105039:	00 
  10503a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105041:	e8 a6 bc ff ff       	call   100cec <__panic>
  105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105049:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10504e:	89 c2                	mov    %eax,%edx
  105050:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105055:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10505c:	00 
  10505d:	89 54 24 04          	mov    %edx,0x4(%esp)
  105061:	89 04 24             	mov    %eax,(%esp)
  105064:	e8 68 f5 ff ff       	call   1045d1 <get_pte>
  105069:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10506c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105070:	75 24                	jne    105096 <check_boot_pgdir+0x9e>
  105072:	c7 44 24 0c 44 70 10 	movl   $0x107044,0xc(%esp)
  105079:	00 
  10507a:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105081:	00 
  105082:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  105089:	00 
  10508a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105091:	e8 56 bc ff ff       	call   100cec <__panic>
        assert(PTE_ADDR(*ptep) == i);
  105096:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105099:	8b 00                	mov    (%eax),%eax
  10509b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1050a0:	89 c2                	mov    %eax,%edx
  1050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050a5:	39 c2                	cmp    %eax,%edx
  1050a7:	74 24                	je     1050cd <check_boot_pgdir+0xd5>
  1050a9:	c7 44 24 0c 81 70 10 	movl   $0x107081,0xc(%esp)
  1050b0:	00 
  1050b1:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1050b8:	00 
  1050b9:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  1050c0:	00 
  1050c1:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1050c8:	e8 1f bc ff ff       	call   100cec <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  1050cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1050d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1050d7:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1050dc:	39 c2                	cmp    %eax,%edx
  1050de:	0f 82 26 ff ff ff    	jb     10500a <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  1050e4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1050e9:	05 ac 0f 00 00       	add    $0xfac,%eax
  1050ee:	8b 00                	mov    (%eax),%eax
  1050f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1050f5:	89 c2                	mov    %eax,%edx
  1050f7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1050fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1050ff:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  105106:	77 23                	ja     10512b <check_boot_pgdir+0x133>
  105108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10510b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10510f:	c7 44 24 08 10 6d 10 	movl   $0x106d10,0x8(%esp)
  105116:	00 
  105117:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  10511e:	00 
  10511f:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105126:	e8 c1 bb ff ff       	call   100cec <__panic>
  10512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10512e:	05 00 00 00 40       	add    $0x40000000,%eax
  105133:	39 c2                	cmp    %eax,%edx
  105135:	74 24                	je     10515b <check_boot_pgdir+0x163>
  105137:	c7 44 24 0c 98 70 10 	movl   $0x107098,0xc(%esp)
  10513e:	00 
  10513f:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105146:	00 
  105147:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  10514e:	00 
  10514f:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105156:	e8 91 bb ff ff       	call   100cec <__panic>

    assert(boot_pgdir[0] == 0);
  10515b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105160:	8b 00                	mov    (%eax),%eax
  105162:	85 c0                	test   %eax,%eax
  105164:	74 24                	je     10518a <check_boot_pgdir+0x192>
  105166:	c7 44 24 0c cc 70 10 	movl   $0x1070cc,0xc(%esp)
  10516d:	00 
  10516e:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105175:	00 
  105176:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  10517d:	00 
  10517e:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105185:	e8 62 bb ff ff       	call   100cec <__panic>

    struct Page *p;
    p = alloc_page();
  10518a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105191:	e8 7f ed ff ff       	call   103f15 <alloc_pages>
  105196:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105199:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10519e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1051a5:	00 
  1051a6:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  1051ad:	00 
  1051ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1051b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  1051b5:	89 04 24             	mov    %eax,(%esp)
  1051b8:	e8 6c f6 ff ff       	call   104829 <page_insert>
  1051bd:	85 c0                	test   %eax,%eax
  1051bf:	74 24                	je     1051e5 <check_boot_pgdir+0x1ed>
  1051c1:	c7 44 24 0c e0 70 10 	movl   $0x1070e0,0xc(%esp)
  1051c8:	00 
  1051c9:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1051d0:	00 
  1051d1:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
  1051d8:	00 
  1051d9:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1051e0:	e8 07 bb ff ff       	call   100cec <__panic>
    assert(page_ref(p) == 1);
  1051e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051e8:	89 04 24             	mov    %eax,(%esp)
  1051eb:	e8 20 eb ff ff       	call   103d10 <page_ref>
  1051f0:	83 f8 01             	cmp    $0x1,%eax
  1051f3:	74 24                	je     105219 <check_boot_pgdir+0x221>
  1051f5:	c7 44 24 0c 0e 71 10 	movl   $0x10710e,0xc(%esp)
  1051fc:	00 
  1051fd:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105204:	00 
  105205:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
  10520c:	00 
  10520d:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105214:	e8 d3 ba ff ff       	call   100cec <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105219:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10521e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105225:	00 
  105226:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10522d:	00 
  10522e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105231:	89 54 24 04          	mov    %edx,0x4(%esp)
  105235:	89 04 24             	mov    %eax,(%esp)
  105238:	e8 ec f5 ff ff       	call   104829 <page_insert>
  10523d:	85 c0                	test   %eax,%eax
  10523f:	74 24                	je     105265 <check_boot_pgdir+0x26d>
  105241:	c7 44 24 0c 20 71 10 	movl   $0x107120,0xc(%esp)
  105248:	00 
  105249:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105250:	00 
  105251:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
  105258:	00 
  105259:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105260:	e8 87 ba ff ff       	call   100cec <__panic>
    assert(page_ref(p) == 2);
  105265:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105268:	89 04 24             	mov    %eax,(%esp)
  10526b:	e8 a0 ea ff ff       	call   103d10 <page_ref>
  105270:	83 f8 02             	cmp    $0x2,%eax
  105273:	74 24                	je     105299 <check_boot_pgdir+0x2a1>
  105275:	c7 44 24 0c 57 71 10 	movl   $0x107157,0xc(%esp)
  10527c:	00 
  10527d:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105284:	00 
  105285:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
  10528c:	00 
  10528d:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105294:	e8 53 ba ff ff       	call   100cec <__panic>

    const char *str = "ucore: Hello world!!";
  105299:	c7 45 dc 68 71 10 00 	movl   $0x107168,-0x24(%ebp)
    strcpy((void *)0x100, str);
  1052a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1052a7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1052ae:	e8 19 0a 00 00       	call   105ccc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1052b3:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1052ba:	00 
  1052bb:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1052c2:	e8 7e 0a 00 00       	call   105d45 <strcmp>
  1052c7:	85 c0                	test   %eax,%eax
  1052c9:	74 24                	je     1052ef <check_boot_pgdir+0x2f7>
  1052cb:	c7 44 24 0c 80 71 10 	movl   $0x107180,0xc(%esp)
  1052d2:	00 
  1052d3:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  1052da:	00 
  1052db:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
  1052e2:	00 
  1052e3:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  1052ea:	e8 fd b9 ff ff       	call   100cec <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1052ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1052f2:	89 04 24             	mov    %eax,(%esp)
  1052f5:	e8 6c e9 ff ff       	call   103c66 <page2kva>
  1052fa:	05 00 01 00 00       	add    $0x100,%eax
  1052ff:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105302:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105309:	e8 66 09 00 00       	call   105c74 <strlen>
  10530e:	85 c0                	test   %eax,%eax
  105310:	74 24                	je     105336 <check_boot_pgdir+0x33e>
  105312:	c7 44 24 0c b8 71 10 	movl   $0x1071b8,0xc(%esp)
  105319:	00 
  10531a:	c7 44 24 08 59 6d 10 	movl   $0x106d59,0x8(%esp)
  105321:	00 
  105322:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
  105329:	00 
  10532a:	c7 04 24 34 6d 10 00 	movl   $0x106d34,(%esp)
  105331:	e8 b6 b9 ff ff       	call   100cec <__panic>

    free_page(p);
  105336:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10533d:	00 
  10533e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105341:	89 04 24             	mov    %eax,(%esp)
  105344:	e8 04 ec ff ff       	call   103f4d <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105349:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10534e:	8b 00                	mov    (%eax),%eax
  105350:	89 04 24             	mov    %eax,(%esp)
  105353:	e8 a0 e9 ff ff       	call   103cf8 <pde2page>
  105358:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10535f:	00 
  105360:	89 04 24             	mov    %eax,(%esp)
  105363:	e8 e5 eb ff ff       	call   103f4d <free_pages>
    boot_pgdir[0] = 0;
  105368:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10536d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105373:	c7 04 24 dc 71 10 00 	movl   $0x1071dc,(%esp)
  10537a:	e8 d9 af ff ff       	call   100358 <cprintf>
}
  10537f:	c9                   	leave  
  105380:	c3                   	ret    

00105381 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105381:	55                   	push   %ebp
  105382:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105384:	8b 45 08             	mov    0x8(%ebp),%eax
  105387:	83 e0 04             	and    $0x4,%eax
  10538a:	85 c0                	test   %eax,%eax
  10538c:	74 07                	je     105395 <perm2str+0x14>
  10538e:	b8 75 00 00 00       	mov    $0x75,%eax
  105393:	eb 05                	jmp    10539a <perm2str+0x19>
  105395:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10539a:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  10539f:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1053a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1053a9:	83 e0 02             	and    $0x2,%eax
  1053ac:	85 c0                	test   %eax,%eax
  1053ae:	74 07                	je     1053b7 <perm2str+0x36>
  1053b0:	b8 77 00 00 00       	mov    $0x77,%eax
  1053b5:	eb 05                	jmp    1053bc <perm2str+0x3b>
  1053b7:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1053bc:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  1053c1:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  1053c8:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  1053cd:	5d                   	pop    %ebp
  1053ce:	c3                   	ret    

001053cf <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1053cf:	55                   	push   %ebp
  1053d0:	89 e5                	mov    %esp,%ebp
  1053d2:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1053d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1053d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053db:	72 0a                	jb     1053e7 <get_pgtable_items+0x18>
        return 0;
  1053dd:	b8 00 00 00 00       	mov    $0x0,%eax
  1053e2:	e9 9c 00 00 00       	jmp    105483 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  1053e7:	eb 04                	jmp    1053ed <get_pgtable_items+0x1e>
        start ++;
  1053e9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  1053ed:	8b 45 10             	mov    0x10(%ebp),%eax
  1053f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1053f3:	73 18                	jae    10540d <get_pgtable_items+0x3e>
  1053f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1053f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1053ff:	8b 45 14             	mov    0x14(%ebp),%eax
  105402:	01 d0                	add    %edx,%eax
  105404:	8b 00                	mov    (%eax),%eax
  105406:	83 e0 01             	and    $0x1,%eax
  105409:	85 c0                	test   %eax,%eax
  10540b:	74 dc                	je     1053e9 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  10540d:	8b 45 10             	mov    0x10(%ebp),%eax
  105410:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105413:	73 69                	jae    10547e <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  105415:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105419:	74 08                	je     105423 <get_pgtable_items+0x54>
            *left_store = start;
  10541b:	8b 45 18             	mov    0x18(%ebp),%eax
  10541e:	8b 55 10             	mov    0x10(%ebp),%edx
  105421:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105423:	8b 45 10             	mov    0x10(%ebp),%eax
  105426:	8d 50 01             	lea    0x1(%eax),%edx
  105429:	89 55 10             	mov    %edx,0x10(%ebp)
  10542c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105433:	8b 45 14             	mov    0x14(%ebp),%eax
  105436:	01 d0                	add    %edx,%eax
  105438:	8b 00                	mov    (%eax),%eax
  10543a:	83 e0 07             	and    $0x7,%eax
  10543d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105440:	eb 04                	jmp    105446 <get_pgtable_items+0x77>
            start ++;
  105442:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  105446:	8b 45 10             	mov    0x10(%ebp),%eax
  105449:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10544c:	73 1d                	jae    10546b <get_pgtable_items+0x9c>
  10544e:	8b 45 10             	mov    0x10(%ebp),%eax
  105451:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105458:	8b 45 14             	mov    0x14(%ebp),%eax
  10545b:	01 d0                	add    %edx,%eax
  10545d:	8b 00                	mov    (%eax),%eax
  10545f:	83 e0 07             	and    $0x7,%eax
  105462:	89 c2                	mov    %eax,%edx
  105464:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105467:	39 c2                	cmp    %eax,%edx
  105469:	74 d7                	je     105442 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  10546b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10546f:	74 08                	je     105479 <get_pgtable_items+0xaa>
            *right_store = start;
  105471:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105474:	8b 55 10             	mov    0x10(%ebp),%edx
  105477:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10547c:	eb 05                	jmp    105483 <get_pgtable_items+0xb4>
    }
    return 0;
  10547e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105483:	c9                   	leave  
  105484:	c3                   	ret    

00105485 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  105485:	55                   	push   %ebp
  105486:	89 e5                	mov    %esp,%ebp
  105488:	57                   	push   %edi
  105489:	56                   	push   %esi
  10548a:	53                   	push   %ebx
  10548b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10548e:	c7 04 24 fc 71 10 00 	movl   $0x1071fc,(%esp)
  105495:	e8 be ae ff ff       	call   100358 <cprintf>
    size_t left, right = 0, perm;
  10549a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1054a1:	e9 fa 00 00 00       	jmp    1055a0 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1054a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1054a9:	89 04 24             	mov    %eax,(%esp)
  1054ac:	e8 d0 fe ff ff       	call   105381 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1054b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1054b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1054b7:	29 d1                	sub    %edx,%ecx
  1054b9:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1054bb:	89 d6                	mov    %edx,%esi
  1054bd:	c1 e6 16             	shl    $0x16,%esi
  1054c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1054c3:	89 d3                	mov    %edx,%ebx
  1054c5:	c1 e3 16             	shl    $0x16,%ebx
  1054c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1054cb:	89 d1                	mov    %edx,%ecx
  1054cd:	c1 e1 16             	shl    $0x16,%ecx
  1054d0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1054d3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1054d6:	29 d7                	sub    %edx,%edi
  1054d8:	89 fa                	mov    %edi,%edx
  1054da:	89 44 24 14          	mov    %eax,0x14(%esp)
  1054de:	89 74 24 10          	mov    %esi,0x10(%esp)
  1054e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1054e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1054ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  1054ee:	c7 04 24 2d 72 10 00 	movl   $0x10722d,(%esp)
  1054f5:	e8 5e ae ff ff       	call   100358 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  1054fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054fd:	c1 e0 0a             	shl    $0xa,%eax
  105500:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105503:	eb 54                	jmp    105559 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105508:	89 04 24             	mov    %eax,(%esp)
  10550b:	e8 71 fe ff ff       	call   105381 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  105510:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105513:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105516:	29 d1                	sub    %edx,%ecx
  105518:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10551a:	89 d6                	mov    %edx,%esi
  10551c:	c1 e6 0c             	shl    $0xc,%esi
  10551f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105522:	89 d3                	mov    %edx,%ebx
  105524:	c1 e3 0c             	shl    $0xc,%ebx
  105527:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10552a:	c1 e2 0c             	shl    $0xc,%edx
  10552d:	89 d1                	mov    %edx,%ecx
  10552f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  105532:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105535:	29 d7                	sub    %edx,%edi
  105537:	89 fa                	mov    %edi,%edx
  105539:	89 44 24 14          	mov    %eax,0x14(%esp)
  10553d:	89 74 24 10          	mov    %esi,0x10(%esp)
  105541:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105545:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105549:	89 54 24 04          	mov    %edx,0x4(%esp)
  10554d:	c7 04 24 4c 72 10 00 	movl   $0x10724c,(%esp)
  105554:	e8 ff ad ff ff       	call   100358 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105559:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  10555e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105564:	89 ce                	mov    %ecx,%esi
  105566:	c1 e6 0a             	shl    $0xa,%esi
  105569:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10556c:	89 cb                	mov    %ecx,%ebx
  10556e:	c1 e3 0a             	shl    $0xa,%ebx
  105571:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  105574:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105578:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  10557b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10557f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105583:	89 44 24 08          	mov    %eax,0x8(%esp)
  105587:	89 74 24 04          	mov    %esi,0x4(%esp)
  10558b:	89 1c 24             	mov    %ebx,(%esp)
  10558e:	e8 3c fe ff ff       	call   1053cf <get_pgtable_items>
  105593:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105596:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10559a:	0f 85 65 ff ff ff    	jne    105505 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1055a0:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1055a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1055a8:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1055ab:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1055af:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  1055b2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1055b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1055ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  1055be:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1055c5:	00 
  1055c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1055cd:	e8 fd fd ff ff       	call   1053cf <get_pgtable_items>
  1055d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1055d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1055d9:	0f 85 c7 fe ff ff    	jne    1054a6 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1055df:	c7 04 24 70 72 10 00 	movl   $0x107270,(%esp)
  1055e6:	e8 6d ad ff ff       	call   100358 <cprintf>
}
  1055eb:	83 c4 4c             	add    $0x4c,%esp
  1055ee:	5b                   	pop    %ebx
  1055ef:	5e                   	pop    %esi
  1055f0:	5f                   	pop    %edi
  1055f1:	5d                   	pop    %ebp
  1055f2:	c3                   	ret    

001055f3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1055f3:	55                   	push   %ebp
  1055f4:	89 e5                	mov    %esp,%ebp
  1055f6:	83 ec 58             	sub    $0x58,%esp
  1055f9:	8b 45 10             	mov    0x10(%ebp),%eax
  1055fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1055ff:	8b 45 14             	mov    0x14(%ebp),%eax
  105602:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105605:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105608:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10560b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10560e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105611:	8b 45 18             	mov    0x18(%ebp),%eax
  105614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105617:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10561a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10561d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105620:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105626:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105629:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10562d:	74 1c                	je     10564b <printnum+0x58>
  10562f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105632:	ba 00 00 00 00       	mov    $0x0,%edx
  105637:	f7 75 e4             	divl   -0x1c(%ebp)
  10563a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10563d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105640:	ba 00 00 00 00       	mov    $0x0,%edx
  105645:	f7 75 e4             	divl   -0x1c(%ebp)
  105648:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10564b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10564e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105651:	f7 75 e4             	divl   -0x1c(%ebp)
  105654:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105657:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10565a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10565d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105660:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105663:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105666:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105669:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10566c:	8b 45 18             	mov    0x18(%ebp),%eax
  10566f:	ba 00 00 00 00       	mov    $0x0,%edx
  105674:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105677:	77 56                	ja     1056cf <printnum+0xdc>
  105679:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10567c:	72 05                	jb     105683 <printnum+0x90>
  10567e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105681:	77 4c                	ja     1056cf <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105683:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105686:	8d 50 ff             	lea    -0x1(%eax),%edx
  105689:	8b 45 20             	mov    0x20(%ebp),%eax
  10568c:	89 44 24 18          	mov    %eax,0x18(%esp)
  105690:	89 54 24 14          	mov    %edx,0x14(%esp)
  105694:	8b 45 18             	mov    0x18(%ebp),%eax
  105697:	89 44 24 10          	mov    %eax,0x10(%esp)
  10569b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10569e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1056a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1056a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b3:	89 04 24             	mov    %eax,(%esp)
  1056b6:	e8 38 ff ff ff       	call   1055f3 <printnum>
  1056bb:	eb 1c                	jmp    1056d9 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1056bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056c4:	8b 45 20             	mov    0x20(%ebp),%eax
  1056c7:	89 04 24             	mov    %eax,(%esp)
  1056ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cd:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  1056cf:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1056d3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1056d7:	7f e4                	jg     1056bd <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1056d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1056dc:	05 24 73 10 00       	add    $0x107324,%eax
  1056e1:	0f b6 00             	movzbl (%eax),%eax
  1056e4:	0f be c0             	movsbl %al,%eax
  1056e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1056ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  1056ee:	89 04 24             	mov    %eax,(%esp)
  1056f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f4:	ff d0                	call   *%eax
}
  1056f6:	c9                   	leave  
  1056f7:	c3                   	ret    

001056f8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1056f8:	55                   	push   %ebp
  1056f9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1056fb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1056ff:	7e 14                	jle    105715 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105701:	8b 45 08             	mov    0x8(%ebp),%eax
  105704:	8b 00                	mov    (%eax),%eax
  105706:	8d 48 08             	lea    0x8(%eax),%ecx
  105709:	8b 55 08             	mov    0x8(%ebp),%edx
  10570c:	89 0a                	mov    %ecx,(%edx)
  10570e:	8b 50 04             	mov    0x4(%eax),%edx
  105711:	8b 00                	mov    (%eax),%eax
  105713:	eb 30                	jmp    105745 <getuint+0x4d>
    }
    else if (lflag) {
  105715:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105719:	74 16                	je     105731 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10571b:	8b 45 08             	mov    0x8(%ebp),%eax
  10571e:	8b 00                	mov    (%eax),%eax
  105720:	8d 48 04             	lea    0x4(%eax),%ecx
  105723:	8b 55 08             	mov    0x8(%ebp),%edx
  105726:	89 0a                	mov    %ecx,(%edx)
  105728:	8b 00                	mov    (%eax),%eax
  10572a:	ba 00 00 00 00       	mov    $0x0,%edx
  10572f:	eb 14                	jmp    105745 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105731:	8b 45 08             	mov    0x8(%ebp),%eax
  105734:	8b 00                	mov    (%eax),%eax
  105736:	8d 48 04             	lea    0x4(%eax),%ecx
  105739:	8b 55 08             	mov    0x8(%ebp),%edx
  10573c:	89 0a                	mov    %ecx,(%edx)
  10573e:	8b 00                	mov    (%eax),%eax
  105740:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105745:	5d                   	pop    %ebp
  105746:	c3                   	ret    

00105747 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105747:	55                   	push   %ebp
  105748:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10574a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10574e:	7e 14                	jle    105764 <getint+0x1d>
        return va_arg(*ap, long long);
  105750:	8b 45 08             	mov    0x8(%ebp),%eax
  105753:	8b 00                	mov    (%eax),%eax
  105755:	8d 48 08             	lea    0x8(%eax),%ecx
  105758:	8b 55 08             	mov    0x8(%ebp),%edx
  10575b:	89 0a                	mov    %ecx,(%edx)
  10575d:	8b 50 04             	mov    0x4(%eax),%edx
  105760:	8b 00                	mov    (%eax),%eax
  105762:	eb 28                	jmp    10578c <getint+0x45>
    }
    else if (lflag) {
  105764:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105768:	74 12                	je     10577c <getint+0x35>
        return va_arg(*ap, long);
  10576a:	8b 45 08             	mov    0x8(%ebp),%eax
  10576d:	8b 00                	mov    (%eax),%eax
  10576f:	8d 48 04             	lea    0x4(%eax),%ecx
  105772:	8b 55 08             	mov    0x8(%ebp),%edx
  105775:	89 0a                	mov    %ecx,(%edx)
  105777:	8b 00                	mov    (%eax),%eax
  105779:	99                   	cltd   
  10577a:	eb 10                	jmp    10578c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10577c:	8b 45 08             	mov    0x8(%ebp),%eax
  10577f:	8b 00                	mov    (%eax),%eax
  105781:	8d 48 04             	lea    0x4(%eax),%ecx
  105784:	8b 55 08             	mov    0x8(%ebp),%edx
  105787:	89 0a                	mov    %ecx,(%edx)
  105789:	8b 00                	mov    (%eax),%eax
  10578b:	99                   	cltd   
    }
}
  10578c:	5d                   	pop    %ebp
  10578d:	c3                   	ret    

0010578e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10578e:	55                   	push   %ebp
  10578f:	89 e5                	mov    %esp,%ebp
  105791:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105794:	8d 45 14             	lea    0x14(%ebp),%eax
  105797:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10579a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10579d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1057a1:	8b 45 10             	mov    0x10(%ebp),%eax
  1057a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057af:	8b 45 08             	mov    0x8(%ebp),%eax
  1057b2:	89 04 24             	mov    %eax,(%esp)
  1057b5:	e8 02 00 00 00       	call   1057bc <vprintfmt>
    va_end(ap);
}
  1057ba:	c9                   	leave  
  1057bb:	c3                   	ret    

001057bc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1057bc:	55                   	push   %ebp
  1057bd:	89 e5                	mov    %esp,%ebp
  1057bf:	56                   	push   %esi
  1057c0:	53                   	push   %ebx
  1057c1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1057c4:	eb 18                	jmp    1057de <vprintfmt+0x22>
            if (ch == '\0') {
  1057c6:	85 db                	test   %ebx,%ebx
  1057c8:	75 05                	jne    1057cf <vprintfmt+0x13>
                return;
  1057ca:	e9 d1 03 00 00       	jmp    105ba0 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  1057cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057d6:	89 1c 24             	mov    %ebx,(%esp)
  1057d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1057dc:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1057de:	8b 45 10             	mov    0x10(%ebp),%eax
  1057e1:	8d 50 01             	lea    0x1(%eax),%edx
  1057e4:	89 55 10             	mov    %edx,0x10(%ebp)
  1057e7:	0f b6 00             	movzbl (%eax),%eax
  1057ea:	0f b6 d8             	movzbl %al,%ebx
  1057ed:	83 fb 25             	cmp    $0x25,%ebx
  1057f0:	75 d4                	jne    1057c6 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  1057f2:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1057f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1057fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105800:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105803:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10580a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10580d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105810:	8b 45 10             	mov    0x10(%ebp),%eax
  105813:	8d 50 01             	lea    0x1(%eax),%edx
  105816:	89 55 10             	mov    %edx,0x10(%ebp)
  105819:	0f b6 00             	movzbl (%eax),%eax
  10581c:	0f b6 d8             	movzbl %al,%ebx
  10581f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105822:	83 f8 55             	cmp    $0x55,%eax
  105825:	0f 87 44 03 00 00    	ja     105b6f <vprintfmt+0x3b3>
  10582b:	8b 04 85 48 73 10 00 	mov    0x107348(,%eax,4),%eax
  105832:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105834:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105838:	eb d6                	jmp    105810 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10583a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10583e:	eb d0                	jmp    105810 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105840:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10584a:	89 d0                	mov    %edx,%eax
  10584c:	c1 e0 02             	shl    $0x2,%eax
  10584f:	01 d0                	add    %edx,%eax
  105851:	01 c0                	add    %eax,%eax
  105853:	01 d8                	add    %ebx,%eax
  105855:	83 e8 30             	sub    $0x30,%eax
  105858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10585b:	8b 45 10             	mov    0x10(%ebp),%eax
  10585e:	0f b6 00             	movzbl (%eax),%eax
  105861:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105864:	83 fb 2f             	cmp    $0x2f,%ebx
  105867:	7e 0b                	jle    105874 <vprintfmt+0xb8>
  105869:	83 fb 39             	cmp    $0x39,%ebx
  10586c:	7f 06                	jg     105874 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10586e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  105872:	eb d3                	jmp    105847 <vprintfmt+0x8b>
            goto process_precision;
  105874:	eb 33                	jmp    1058a9 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  105876:	8b 45 14             	mov    0x14(%ebp),%eax
  105879:	8d 50 04             	lea    0x4(%eax),%edx
  10587c:	89 55 14             	mov    %edx,0x14(%ebp)
  10587f:	8b 00                	mov    (%eax),%eax
  105881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105884:	eb 23                	jmp    1058a9 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105886:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10588a:	79 0c                	jns    105898 <vprintfmt+0xdc>
                width = 0;
  10588c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105893:	e9 78 ff ff ff       	jmp    105810 <vprintfmt+0x54>
  105898:	e9 73 ff ff ff       	jmp    105810 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  10589d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1058a4:	e9 67 ff ff ff       	jmp    105810 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1058a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1058ad:	79 12                	jns    1058c1 <vprintfmt+0x105>
                width = precision, precision = -1;
  1058af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1058b5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1058bc:	e9 4f ff ff ff       	jmp    105810 <vprintfmt+0x54>
  1058c1:	e9 4a ff ff ff       	jmp    105810 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1058c6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1058ca:	e9 41 ff ff ff       	jmp    105810 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1058cf:	8b 45 14             	mov    0x14(%ebp),%eax
  1058d2:	8d 50 04             	lea    0x4(%eax),%edx
  1058d5:	89 55 14             	mov    %edx,0x14(%ebp)
  1058d8:	8b 00                	mov    (%eax),%eax
  1058da:	8b 55 0c             	mov    0xc(%ebp),%edx
  1058dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  1058e1:	89 04 24             	mov    %eax,(%esp)
  1058e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1058e7:	ff d0                	call   *%eax
            break;
  1058e9:	e9 ac 02 00 00       	jmp    105b9a <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1058ee:	8b 45 14             	mov    0x14(%ebp),%eax
  1058f1:	8d 50 04             	lea    0x4(%eax),%edx
  1058f4:	89 55 14             	mov    %edx,0x14(%ebp)
  1058f7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1058f9:	85 db                	test   %ebx,%ebx
  1058fb:	79 02                	jns    1058ff <vprintfmt+0x143>
                err = -err;
  1058fd:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1058ff:	83 fb 06             	cmp    $0x6,%ebx
  105902:	7f 0b                	jg     10590f <vprintfmt+0x153>
  105904:	8b 34 9d 08 73 10 00 	mov    0x107308(,%ebx,4),%esi
  10590b:	85 f6                	test   %esi,%esi
  10590d:	75 23                	jne    105932 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  10590f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105913:	c7 44 24 08 35 73 10 	movl   $0x107335,0x8(%esp)
  10591a:	00 
  10591b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10591e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105922:	8b 45 08             	mov    0x8(%ebp),%eax
  105925:	89 04 24             	mov    %eax,(%esp)
  105928:	e8 61 fe ff ff       	call   10578e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10592d:	e9 68 02 00 00       	jmp    105b9a <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105932:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105936:	c7 44 24 08 3e 73 10 	movl   $0x10733e,0x8(%esp)
  10593d:	00 
  10593e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105941:	89 44 24 04          	mov    %eax,0x4(%esp)
  105945:	8b 45 08             	mov    0x8(%ebp),%eax
  105948:	89 04 24             	mov    %eax,(%esp)
  10594b:	e8 3e fe ff ff       	call   10578e <printfmt>
            }
            break;
  105950:	e9 45 02 00 00       	jmp    105b9a <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105955:	8b 45 14             	mov    0x14(%ebp),%eax
  105958:	8d 50 04             	lea    0x4(%eax),%edx
  10595b:	89 55 14             	mov    %edx,0x14(%ebp)
  10595e:	8b 30                	mov    (%eax),%esi
  105960:	85 f6                	test   %esi,%esi
  105962:	75 05                	jne    105969 <vprintfmt+0x1ad>
                p = "(null)";
  105964:	be 41 73 10 00       	mov    $0x107341,%esi
            }
            if (width > 0 && padc != '-') {
  105969:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10596d:	7e 3e                	jle    1059ad <vprintfmt+0x1f1>
  10596f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105973:	74 38                	je     1059ad <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105975:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10597b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10597f:	89 34 24             	mov    %esi,(%esp)
  105982:	e8 15 03 00 00       	call   105c9c <strnlen>
  105987:	29 c3                	sub    %eax,%ebx
  105989:	89 d8                	mov    %ebx,%eax
  10598b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10598e:	eb 17                	jmp    1059a7 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105990:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105994:	8b 55 0c             	mov    0xc(%ebp),%edx
  105997:	89 54 24 04          	mov    %edx,0x4(%esp)
  10599b:	89 04 24             	mov    %eax,(%esp)
  10599e:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a1:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1059a3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1059a7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1059ab:	7f e3                	jg     105990 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1059ad:	eb 38                	jmp    1059e7 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1059af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1059b3:	74 1f                	je     1059d4 <vprintfmt+0x218>
  1059b5:	83 fb 1f             	cmp    $0x1f,%ebx
  1059b8:	7e 05                	jle    1059bf <vprintfmt+0x203>
  1059ba:	83 fb 7e             	cmp    $0x7e,%ebx
  1059bd:	7e 15                	jle    1059d4 <vprintfmt+0x218>
                    putch('?', putdat);
  1059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059c6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1059cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d0:	ff d0                	call   *%eax
  1059d2:	eb 0f                	jmp    1059e3 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  1059d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059db:	89 1c 24             	mov    %ebx,(%esp)
  1059de:	8b 45 08             	mov    0x8(%ebp),%eax
  1059e1:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1059e3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1059e7:	89 f0                	mov    %esi,%eax
  1059e9:	8d 70 01             	lea    0x1(%eax),%esi
  1059ec:	0f b6 00             	movzbl (%eax),%eax
  1059ef:	0f be d8             	movsbl %al,%ebx
  1059f2:	85 db                	test   %ebx,%ebx
  1059f4:	74 10                	je     105a06 <vprintfmt+0x24a>
  1059f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1059fa:	78 b3                	js     1059af <vprintfmt+0x1f3>
  1059fc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105a00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105a04:	79 a9                	jns    1059af <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105a06:	eb 17                	jmp    105a1f <vprintfmt+0x263>
                putch(' ', putdat);
  105a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a0f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105a16:	8b 45 08             	mov    0x8(%ebp),%eax
  105a19:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105a1b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105a1f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a23:	7f e3                	jg     105a08 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  105a25:	e9 70 01 00 00       	jmp    105b9a <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a31:	8d 45 14             	lea    0x14(%ebp),%eax
  105a34:	89 04 24             	mov    %eax,(%esp)
  105a37:	e8 0b fd ff ff       	call   105747 <getint>
  105a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a3f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a48:	85 d2                	test   %edx,%edx
  105a4a:	79 26                	jns    105a72 <vprintfmt+0x2b6>
                putch('-', putdat);
  105a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a53:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5d:	ff d0                	call   *%eax
                num = -(long long)num;
  105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a65:	f7 d8                	neg    %eax
  105a67:	83 d2 00             	adc    $0x0,%edx
  105a6a:	f7 da                	neg    %edx
  105a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a6f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105a72:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105a79:	e9 a8 00 00 00       	jmp    105b26 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a85:	8d 45 14             	lea    0x14(%ebp),%eax
  105a88:	89 04 24             	mov    %eax,(%esp)
  105a8b:	e8 68 fc ff ff       	call   1056f8 <getuint>
  105a90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a93:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105a96:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105a9d:	e9 84 00 00 00       	jmp    105b26 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa9:	8d 45 14             	lea    0x14(%ebp),%eax
  105aac:	89 04 24             	mov    %eax,(%esp)
  105aaf:	e8 44 fc ff ff       	call   1056f8 <getuint>
  105ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ab7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105aba:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105ac1:	eb 63                	jmp    105b26 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ad4:	ff d0                	call   *%eax
            putch('x', putdat);
  105ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105add:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae7:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105ae9:	8b 45 14             	mov    0x14(%ebp),%eax
  105aec:	8d 50 04             	lea    0x4(%eax),%edx
  105aef:	89 55 14             	mov    %edx,0x14(%ebp)
  105af2:	8b 00                	mov    (%eax),%eax
  105af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105afe:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105b05:	eb 1f                	jmp    105b26 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  105b11:	89 04 24             	mov    %eax,(%esp)
  105b14:	e8 df fb ff ff       	call   1056f8 <getuint>
  105b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105b1f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105b26:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105b2d:	89 54 24 18          	mov    %edx,0x18(%esp)
  105b31:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105b34:	89 54 24 14          	mov    %edx,0x14(%esp)
  105b38:	89 44 24 10          	mov    %eax,0x10(%esp)
  105b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b42:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b46:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b51:	8b 45 08             	mov    0x8(%ebp),%eax
  105b54:	89 04 24             	mov    %eax,(%esp)
  105b57:	e8 97 fa ff ff       	call   1055f3 <printnum>
            break;
  105b5c:	eb 3c                	jmp    105b9a <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b65:	89 1c 24             	mov    %ebx,(%esp)
  105b68:	8b 45 08             	mov    0x8(%ebp),%eax
  105b6b:	ff d0                	call   *%eax
            break;
  105b6d:	eb 2b                	jmp    105b9a <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b76:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b80:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105b82:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105b86:	eb 04                	jmp    105b8c <vprintfmt+0x3d0>
  105b88:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105b8c:	8b 45 10             	mov    0x10(%ebp),%eax
  105b8f:	83 e8 01             	sub    $0x1,%eax
  105b92:	0f b6 00             	movzbl (%eax),%eax
  105b95:	3c 25                	cmp    $0x25,%al
  105b97:	75 ef                	jne    105b88 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105b99:	90                   	nop
        }
    }
  105b9a:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105b9b:	e9 3e fc ff ff       	jmp    1057de <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105ba0:	83 c4 40             	add    $0x40,%esp
  105ba3:	5b                   	pop    %ebx
  105ba4:	5e                   	pop    %esi
  105ba5:	5d                   	pop    %ebp
  105ba6:	c3                   	ret    

00105ba7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105ba7:	55                   	push   %ebp
  105ba8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bad:	8b 40 08             	mov    0x8(%eax),%eax
  105bb0:	8d 50 01             	lea    0x1(%eax),%edx
  105bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bb6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bbc:	8b 10                	mov    (%eax),%edx
  105bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bc1:	8b 40 04             	mov    0x4(%eax),%eax
  105bc4:	39 c2                	cmp    %eax,%edx
  105bc6:	73 12                	jae    105bda <sprintputch+0x33>
        *b->buf ++ = ch;
  105bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bcb:	8b 00                	mov    (%eax),%eax
  105bcd:	8d 48 01             	lea    0x1(%eax),%ecx
  105bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  105bd3:	89 0a                	mov    %ecx,(%edx)
  105bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  105bd8:	88 10                	mov    %dl,(%eax)
    }
}
  105bda:	5d                   	pop    %ebp
  105bdb:	c3                   	ret    

00105bdc <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105bdc:	55                   	push   %ebp
  105bdd:	89 e5                	mov    %esp,%ebp
  105bdf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105be2:	8d 45 14             	lea    0x14(%ebp),%eax
  105be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105beb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105bef:	8b 45 10             	mov    0x10(%ebp),%eax
  105bf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  105bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  105c00:	89 04 24             	mov    %eax,(%esp)
  105c03:	e8 08 00 00 00       	call   105c10 <vsnprintf>
  105c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105c0e:	c9                   	leave  
  105c0f:	c3                   	ret    

00105c10 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105c10:	55                   	push   %ebp
  105c11:	89 e5                	mov    %esp,%ebp
  105c13:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105c16:	8b 45 08             	mov    0x8(%ebp),%eax
  105c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105c22:	8b 45 08             	mov    0x8(%ebp),%eax
  105c25:	01 d0                	add    %edx,%eax
  105c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105c31:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105c35:	74 0a                	je     105c41 <vsnprintf+0x31>
  105c37:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c3d:	39 c2                	cmp    %eax,%edx
  105c3f:	76 07                	jbe    105c48 <vsnprintf+0x38>
        return -E_INVAL;
  105c41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105c46:	eb 2a                	jmp    105c72 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105c48:	8b 45 14             	mov    0x14(%ebp),%eax
  105c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
  105c52:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c56:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c5d:	c7 04 24 a7 5b 10 00 	movl   $0x105ba7,(%esp)
  105c64:	e8 53 fb ff ff       	call   1057bc <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105c6c:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105c72:	c9                   	leave  
  105c73:	c3                   	ret    

00105c74 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105c74:	55                   	push   %ebp
  105c75:	89 e5                	mov    %esp,%ebp
  105c77:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105c7a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105c81:	eb 04                	jmp    105c87 <strlen+0x13>
        cnt ++;
  105c83:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105c87:	8b 45 08             	mov    0x8(%ebp),%eax
  105c8a:	8d 50 01             	lea    0x1(%eax),%edx
  105c8d:	89 55 08             	mov    %edx,0x8(%ebp)
  105c90:	0f b6 00             	movzbl (%eax),%eax
  105c93:	84 c0                	test   %al,%al
  105c95:	75 ec                	jne    105c83 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105c97:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105c9a:	c9                   	leave  
  105c9b:	c3                   	ret    

00105c9c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105c9c:	55                   	push   %ebp
  105c9d:	89 e5                	mov    %esp,%ebp
  105c9f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ca2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105ca9:	eb 04                	jmp    105caf <strnlen+0x13>
        cnt ++;
  105cab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105cb2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105cb5:	73 10                	jae    105cc7 <strnlen+0x2b>
  105cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  105cba:	8d 50 01             	lea    0x1(%eax),%edx
  105cbd:	89 55 08             	mov    %edx,0x8(%ebp)
  105cc0:	0f b6 00             	movzbl (%eax),%eax
  105cc3:	84 c0                	test   %al,%al
  105cc5:	75 e4                	jne    105cab <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105cca:	c9                   	leave  
  105ccb:	c3                   	ret    

00105ccc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105ccc:	55                   	push   %ebp
  105ccd:	89 e5                	mov    %esp,%ebp
  105ccf:	57                   	push   %edi
  105cd0:	56                   	push   %esi
  105cd1:	83 ec 20             	sub    $0x20,%esp
  105cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ce6:	89 d1                	mov    %edx,%ecx
  105ce8:	89 c2                	mov    %eax,%edx
  105cea:	89 ce                	mov    %ecx,%esi
  105cec:	89 d7                	mov    %edx,%edi
  105cee:	ac                   	lods   %ds:(%esi),%al
  105cef:	aa                   	stos   %al,%es:(%edi)
  105cf0:	84 c0                	test   %al,%al
  105cf2:	75 fa                	jne    105cee <strcpy+0x22>
  105cf4:	89 fa                	mov    %edi,%edx
  105cf6:	89 f1                	mov    %esi,%ecx
  105cf8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105cfb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105cfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105d04:	83 c4 20             	add    $0x20,%esp
  105d07:	5e                   	pop    %esi
  105d08:	5f                   	pop    %edi
  105d09:	5d                   	pop    %ebp
  105d0a:	c3                   	ret    

00105d0b <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105d0b:	55                   	push   %ebp
  105d0c:	89 e5                	mov    %esp,%ebp
  105d0e:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105d11:	8b 45 08             	mov    0x8(%ebp),%eax
  105d14:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105d17:	eb 21                	jmp    105d3a <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d1c:	0f b6 10             	movzbl (%eax),%edx
  105d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d22:	88 10                	mov    %dl,(%eax)
  105d24:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d27:	0f b6 00             	movzbl (%eax),%eax
  105d2a:	84 c0                	test   %al,%al
  105d2c:	74 04                	je     105d32 <strncpy+0x27>
            src ++;
  105d2e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105d32:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105d36:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105d3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d3e:	75 d9                	jne    105d19 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105d40:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105d43:	c9                   	leave  
  105d44:	c3                   	ret    

00105d45 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105d45:	55                   	push   %ebp
  105d46:	89 e5                	mov    %esp,%ebp
  105d48:	57                   	push   %edi
  105d49:	56                   	push   %esi
  105d4a:	83 ec 20             	sub    $0x20,%esp
  105d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d5f:	89 d1                	mov    %edx,%ecx
  105d61:	89 c2                	mov    %eax,%edx
  105d63:	89 ce                	mov    %ecx,%esi
  105d65:	89 d7                	mov    %edx,%edi
  105d67:	ac                   	lods   %ds:(%esi),%al
  105d68:	ae                   	scas   %es:(%edi),%al
  105d69:	75 08                	jne    105d73 <strcmp+0x2e>
  105d6b:	84 c0                	test   %al,%al
  105d6d:	75 f8                	jne    105d67 <strcmp+0x22>
  105d6f:	31 c0                	xor    %eax,%eax
  105d71:	eb 04                	jmp    105d77 <strcmp+0x32>
  105d73:	19 c0                	sbb    %eax,%eax
  105d75:	0c 01                	or     $0x1,%al
  105d77:	89 fa                	mov    %edi,%edx
  105d79:	89 f1                	mov    %esi,%ecx
  105d7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105d7e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105d81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105d84:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105d87:	83 c4 20             	add    $0x20,%esp
  105d8a:	5e                   	pop    %esi
  105d8b:	5f                   	pop    %edi
  105d8c:	5d                   	pop    %ebp
  105d8d:	c3                   	ret    

00105d8e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105d8e:	55                   	push   %ebp
  105d8f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105d91:	eb 0c                	jmp    105d9f <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105d93:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105d97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d9b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105d9f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105da3:	74 1a                	je     105dbf <strncmp+0x31>
  105da5:	8b 45 08             	mov    0x8(%ebp),%eax
  105da8:	0f b6 00             	movzbl (%eax),%eax
  105dab:	84 c0                	test   %al,%al
  105dad:	74 10                	je     105dbf <strncmp+0x31>
  105daf:	8b 45 08             	mov    0x8(%ebp),%eax
  105db2:	0f b6 10             	movzbl (%eax),%edx
  105db5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db8:	0f b6 00             	movzbl (%eax),%eax
  105dbb:	38 c2                	cmp    %al,%dl
  105dbd:	74 d4                	je     105d93 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105dbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105dc3:	74 18                	je     105ddd <strncmp+0x4f>
  105dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc8:	0f b6 00             	movzbl (%eax),%eax
  105dcb:	0f b6 d0             	movzbl %al,%edx
  105dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dd1:	0f b6 00             	movzbl (%eax),%eax
  105dd4:	0f b6 c0             	movzbl %al,%eax
  105dd7:	29 c2                	sub    %eax,%edx
  105dd9:	89 d0                	mov    %edx,%eax
  105ddb:	eb 05                	jmp    105de2 <strncmp+0x54>
  105ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105de2:	5d                   	pop    %ebp
  105de3:	c3                   	ret    

00105de4 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105de4:	55                   	push   %ebp
  105de5:	89 e5                	mov    %esp,%ebp
  105de7:	83 ec 04             	sub    $0x4,%esp
  105dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ded:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105df0:	eb 14                	jmp    105e06 <strchr+0x22>
        if (*s == c) {
  105df2:	8b 45 08             	mov    0x8(%ebp),%eax
  105df5:	0f b6 00             	movzbl (%eax),%eax
  105df8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105dfb:	75 05                	jne    105e02 <strchr+0x1e>
            return (char *)s;
  105dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  105e00:	eb 13                	jmp    105e15 <strchr+0x31>
        }
        s ++;
  105e02:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105e06:	8b 45 08             	mov    0x8(%ebp),%eax
  105e09:	0f b6 00             	movzbl (%eax),%eax
  105e0c:	84 c0                	test   %al,%al
  105e0e:	75 e2                	jne    105df2 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105e15:	c9                   	leave  
  105e16:	c3                   	ret    

00105e17 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105e17:	55                   	push   %ebp
  105e18:	89 e5                	mov    %esp,%ebp
  105e1a:	83 ec 04             	sub    $0x4,%esp
  105e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e20:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105e23:	eb 11                	jmp    105e36 <strfind+0x1f>
        if (*s == c) {
  105e25:	8b 45 08             	mov    0x8(%ebp),%eax
  105e28:	0f b6 00             	movzbl (%eax),%eax
  105e2b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105e2e:	75 02                	jne    105e32 <strfind+0x1b>
            break;
  105e30:	eb 0e                	jmp    105e40 <strfind+0x29>
        }
        s ++;
  105e32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105e36:	8b 45 08             	mov    0x8(%ebp),%eax
  105e39:	0f b6 00             	movzbl (%eax),%eax
  105e3c:	84 c0                	test   %al,%al
  105e3e:	75 e5                	jne    105e25 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105e40:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105e43:	c9                   	leave  
  105e44:	c3                   	ret    

00105e45 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105e45:	55                   	push   %ebp
  105e46:	89 e5                	mov    %esp,%ebp
  105e48:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105e4b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105e52:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105e59:	eb 04                	jmp    105e5f <strtol+0x1a>
        s ++;
  105e5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  105e62:	0f b6 00             	movzbl (%eax),%eax
  105e65:	3c 20                	cmp    $0x20,%al
  105e67:	74 f2                	je     105e5b <strtol+0x16>
  105e69:	8b 45 08             	mov    0x8(%ebp),%eax
  105e6c:	0f b6 00             	movzbl (%eax),%eax
  105e6f:	3c 09                	cmp    $0x9,%al
  105e71:	74 e8                	je     105e5b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105e73:	8b 45 08             	mov    0x8(%ebp),%eax
  105e76:	0f b6 00             	movzbl (%eax),%eax
  105e79:	3c 2b                	cmp    $0x2b,%al
  105e7b:	75 06                	jne    105e83 <strtol+0x3e>
        s ++;
  105e7d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105e81:	eb 15                	jmp    105e98 <strtol+0x53>
    }
    else if (*s == '-') {
  105e83:	8b 45 08             	mov    0x8(%ebp),%eax
  105e86:	0f b6 00             	movzbl (%eax),%eax
  105e89:	3c 2d                	cmp    $0x2d,%al
  105e8b:	75 0b                	jne    105e98 <strtol+0x53>
        s ++, neg = 1;
  105e8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105e91:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105e98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e9c:	74 06                	je     105ea4 <strtol+0x5f>
  105e9e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105ea2:	75 24                	jne    105ec8 <strtol+0x83>
  105ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  105ea7:	0f b6 00             	movzbl (%eax),%eax
  105eaa:	3c 30                	cmp    $0x30,%al
  105eac:	75 1a                	jne    105ec8 <strtol+0x83>
  105eae:	8b 45 08             	mov    0x8(%ebp),%eax
  105eb1:	83 c0 01             	add    $0x1,%eax
  105eb4:	0f b6 00             	movzbl (%eax),%eax
  105eb7:	3c 78                	cmp    $0x78,%al
  105eb9:	75 0d                	jne    105ec8 <strtol+0x83>
        s += 2, base = 16;
  105ebb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105ebf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105ec6:	eb 2a                	jmp    105ef2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105ec8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105ecc:	75 17                	jne    105ee5 <strtol+0xa0>
  105ece:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed1:	0f b6 00             	movzbl (%eax),%eax
  105ed4:	3c 30                	cmp    $0x30,%al
  105ed6:	75 0d                	jne    105ee5 <strtol+0xa0>
        s ++, base = 8;
  105ed8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105edc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105ee3:	eb 0d                	jmp    105ef2 <strtol+0xad>
    }
    else if (base == 0) {
  105ee5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105ee9:	75 07                	jne    105ef2 <strtol+0xad>
        base = 10;
  105eeb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  105ef5:	0f b6 00             	movzbl (%eax),%eax
  105ef8:	3c 2f                	cmp    $0x2f,%al
  105efa:	7e 1b                	jle    105f17 <strtol+0xd2>
  105efc:	8b 45 08             	mov    0x8(%ebp),%eax
  105eff:	0f b6 00             	movzbl (%eax),%eax
  105f02:	3c 39                	cmp    $0x39,%al
  105f04:	7f 11                	jg     105f17 <strtol+0xd2>
            dig = *s - '0';
  105f06:	8b 45 08             	mov    0x8(%ebp),%eax
  105f09:	0f b6 00             	movzbl (%eax),%eax
  105f0c:	0f be c0             	movsbl %al,%eax
  105f0f:	83 e8 30             	sub    $0x30,%eax
  105f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105f15:	eb 48                	jmp    105f5f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105f17:	8b 45 08             	mov    0x8(%ebp),%eax
  105f1a:	0f b6 00             	movzbl (%eax),%eax
  105f1d:	3c 60                	cmp    $0x60,%al
  105f1f:	7e 1b                	jle    105f3c <strtol+0xf7>
  105f21:	8b 45 08             	mov    0x8(%ebp),%eax
  105f24:	0f b6 00             	movzbl (%eax),%eax
  105f27:	3c 7a                	cmp    $0x7a,%al
  105f29:	7f 11                	jg     105f3c <strtol+0xf7>
            dig = *s - 'a' + 10;
  105f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105f2e:	0f b6 00             	movzbl (%eax),%eax
  105f31:	0f be c0             	movsbl %al,%eax
  105f34:	83 e8 57             	sub    $0x57,%eax
  105f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105f3a:	eb 23                	jmp    105f5f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105f3f:	0f b6 00             	movzbl (%eax),%eax
  105f42:	3c 40                	cmp    $0x40,%al
  105f44:	7e 3d                	jle    105f83 <strtol+0x13e>
  105f46:	8b 45 08             	mov    0x8(%ebp),%eax
  105f49:	0f b6 00             	movzbl (%eax),%eax
  105f4c:	3c 5a                	cmp    $0x5a,%al
  105f4e:	7f 33                	jg     105f83 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105f50:	8b 45 08             	mov    0x8(%ebp),%eax
  105f53:	0f b6 00             	movzbl (%eax),%eax
  105f56:	0f be c0             	movsbl %al,%eax
  105f59:	83 e8 37             	sub    $0x37,%eax
  105f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105f62:	3b 45 10             	cmp    0x10(%ebp),%eax
  105f65:	7c 02                	jl     105f69 <strtol+0x124>
            break;
  105f67:	eb 1a                	jmp    105f83 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105f69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105f6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f70:	0f af 45 10          	imul   0x10(%ebp),%eax
  105f74:	89 c2                	mov    %eax,%edx
  105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105f79:	01 d0                	add    %edx,%eax
  105f7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105f7e:	e9 6f ff ff ff       	jmp    105ef2 <strtol+0xad>

    if (endptr) {
  105f83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105f87:	74 08                	je     105f91 <strtol+0x14c>
        *endptr = (char *) s;
  105f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  105f8f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105f91:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105f95:	74 07                	je     105f9e <strtol+0x159>
  105f97:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f9a:	f7 d8                	neg    %eax
  105f9c:	eb 03                	jmp    105fa1 <strtol+0x15c>
  105f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105fa1:	c9                   	leave  
  105fa2:	c3                   	ret    

00105fa3 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105fa3:	55                   	push   %ebp
  105fa4:	89 e5                	mov    %esp,%ebp
  105fa6:	57                   	push   %edi
  105fa7:	83 ec 24             	sub    $0x24,%esp
  105faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fad:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105fb0:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  105fb7:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105fba:	88 45 f7             	mov    %al,-0x9(%ebp)
  105fbd:	8b 45 10             	mov    0x10(%ebp),%eax
  105fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105fc3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105fc6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105fca:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105fcd:	89 d7                	mov    %edx,%edi
  105fcf:	f3 aa                	rep stos %al,%es:(%edi)
  105fd1:	89 fa                	mov    %edi,%edx
  105fd3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105fd6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105fd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105fdc:	83 c4 24             	add    $0x24,%esp
  105fdf:	5f                   	pop    %edi
  105fe0:	5d                   	pop    %ebp
  105fe1:	c3                   	ret    

00105fe2 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105fe2:	55                   	push   %ebp
  105fe3:	89 e5                	mov    %esp,%ebp
  105fe5:	57                   	push   %edi
  105fe6:	56                   	push   %esi
  105fe7:	53                   	push   %ebx
  105fe8:	83 ec 30             	sub    $0x30,%esp
  105feb:	8b 45 08             	mov    0x8(%ebp),%eax
  105fee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ff4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  105ffa:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106000:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  106003:	73 42                	jae    106047 <memmove+0x65>
  106005:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106008:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10600b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10600e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106011:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106014:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106017:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10601a:	c1 e8 02             	shr    $0x2,%eax
  10601d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10601f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106022:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106025:	89 d7                	mov    %edx,%edi
  106027:	89 c6                	mov    %eax,%esi
  106029:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10602b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10602e:	83 e1 03             	and    $0x3,%ecx
  106031:	74 02                	je     106035 <memmove+0x53>
  106033:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106035:	89 f0                	mov    %esi,%eax
  106037:	89 fa                	mov    %edi,%edx
  106039:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10603c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10603f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106045:	eb 36                	jmp    10607d <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106047:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10604a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10604d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106050:	01 c2                	add    %eax,%edx
  106052:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106055:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106058:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10605b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  10605e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106061:	89 c1                	mov    %eax,%ecx
  106063:	89 d8                	mov    %ebx,%eax
  106065:	89 d6                	mov    %edx,%esi
  106067:	89 c7                	mov    %eax,%edi
  106069:	fd                   	std    
  10606a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10606c:	fc                   	cld    
  10606d:	89 f8                	mov    %edi,%eax
  10606f:	89 f2                	mov    %esi,%edx
  106071:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106074:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106077:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  10607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10607d:	83 c4 30             	add    $0x30,%esp
  106080:	5b                   	pop    %ebx
  106081:	5e                   	pop    %esi
  106082:	5f                   	pop    %edi
  106083:	5d                   	pop    %ebp
  106084:	c3                   	ret    

00106085 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106085:	55                   	push   %ebp
  106086:	89 e5                	mov    %esp,%ebp
  106088:	57                   	push   %edi
  106089:	56                   	push   %esi
  10608a:	83 ec 20             	sub    $0x20,%esp
  10608d:	8b 45 08             	mov    0x8(%ebp),%eax
  106090:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106093:	8b 45 0c             	mov    0xc(%ebp),%eax
  106096:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106099:	8b 45 10             	mov    0x10(%ebp),%eax
  10609c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10609f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060a2:	c1 e8 02             	shr    $0x2,%eax
  1060a5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1060a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060ad:	89 d7                	mov    %edx,%edi
  1060af:	89 c6                	mov    %eax,%esi
  1060b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1060b3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1060b6:	83 e1 03             	and    $0x3,%ecx
  1060b9:	74 02                	je     1060bd <memcpy+0x38>
  1060bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1060bd:	89 f0                	mov    %esi,%eax
  1060bf:	89 fa                	mov    %edi,%edx
  1060c1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1060c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1060c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  1060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1060cd:	83 c4 20             	add    $0x20,%esp
  1060d0:	5e                   	pop    %esi
  1060d1:	5f                   	pop    %edi
  1060d2:	5d                   	pop    %ebp
  1060d3:	c3                   	ret    

001060d4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1060d4:	55                   	push   %ebp
  1060d5:	89 e5                	mov    %esp,%ebp
  1060d7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1060da:	8b 45 08             	mov    0x8(%ebp),%eax
  1060dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1060e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1060e6:	eb 30                	jmp    106118 <memcmp+0x44>
        if (*s1 != *s2) {
  1060e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1060eb:	0f b6 10             	movzbl (%eax),%edx
  1060ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1060f1:	0f b6 00             	movzbl (%eax),%eax
  1060f4:	38 c2                	cmp    %al,%dl
  1060f6:	74 18                	je     106110 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1060f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1060fb:	0f b6 00             	movzbl (%eax),%eax
  1060fe:	0f b6 d0             	movzbl %al,%edx
  106101:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106104:	0f b6 00             	movzbl (%eax),%eax
  106107:	0f b6 c0             	movzbl %al,%eax
  10610a:	29 c2                	sub    %eax,%edx
  10610c:	89 d0                	mov    %edx,%eax
  10610e:	eb 1a                	jmp    10612a <memcmp+0x56>
        }
        s1 ++, s2 ++;
  106110:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  106114:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  106118:	8b 45 10             	mov    0x10(%ebp),%eax
  10611b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10611e:	89 55 10             	mov    %edx,0x10(%ebp)
  106121:	85 c0                	test   %eax,%eax
  106123:	75 c3                	jne    1060e8 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  106125:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10612a:	c9                   	leave  
  10612b:	c3                   	ret    
