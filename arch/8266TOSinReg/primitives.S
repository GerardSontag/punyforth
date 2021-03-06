.macro DPUSH reg    
    addi a15, a15, -CELLS
    s32i \reg, a15, 0
.endm

.macro DPOP reg    
    l32i \reg, a15, 0
    addi a15, a15, CELLS
.endm

.macro RPUSH reg    
    addi a13, a13, -CELLS
    s32i \reg, a13, 0    
.endm

.macro RPOP reg    
    l32i \reg, a13, 0
    addi a13, a13, CELLS
.endm

.macro READTOS1 reg
    l32i \reg, a15, 0
.endm

.macro READTOS2 reg
    l32i \reg, a15, CELLS
.endm

.macro READTOS3 reg
    l32i \reg, a15, 2*CELLS
.endm

.macro READTOS4 reg
    l32i \reg, a15, 3*CELLS
.endm

.macro WRTETOS1 reg
    s32i \reg, a15, 0
.endm

.macro WRTETOS2 reg
    s32i \reg, a15, CELLS
.endm

.macro WRTETOS3 reg
    s32i \reg, a15, 2*CELLS
.endm

.macro WRTETOS4 reg
    s32i \reg, a15, 3*CELLS
.endm

defprimitive "dup",3,dup,REGULAR /* ( a -- a a ) */
    
    DPUSH     a2
    NEXT

defprimitive "drop",4,drop,REGULAR /* ( a -- ) */
    DPOP      a2
    NEXT

defprimitive "swap",4,swap,REGULAR /* ( a b -- b a ) */
    READTOS1  a8
    
    WRTETOS1  a2
    move.n    a2,a8
    NEXT

defprimitive "rot",3,rot,REGULAR /* ( a b c -- b c a ) */    
    
    READTOS1  a9
    READTOS2  a10
    WRTETOS2  a9
    WRTETOS1  a2
    move      a2,a10
    NEXT

defprimitive "2swap",5,swap2,REGULAR /* ( a b c d -- c d a b ) */    
    
    READTOS1  a9
    READTOS2  a10
    READTOS3  a11
    WRTETOS1  a11
    WRTETOS2  a2
    WRTETOS3  a9
    move      a2,a10
    NEXT

defprimitive "2over",5,over2,REGULAR /* ( a b c d -- a b c d a b ) */    
    DPUSH     a2
    READTOS3  a2
    READTOS4  a9
    DPUSH     a9

    NEXT

defprimitive "+",1,plus,REGULAR
    DPOP      a8
   
    add       a2, a2, a8

    NEXT

defprimitive "-",1,minus,REGULAR
    DPOP      a9
    
    sub       a2, a2, a9
 
    NEXT

defprimitive "*",1,multiply,REGULAR
    DPOP      a9

    mull      a2, a2, a9

    NEXT

.literal_position
defprimitive "/mod",4,divmod,REGULAR /* ( n d -- m q ) */    
    move      a3,a2         // denom
    DPOP      a2            // numer
    CCALL     forth_divmod
    DPUSH     a3           // remainder
                            // quotient in a2
    NEXT

defprimitive "or",2,or,REGULAR
    DPOP      a9
  
    or        a2, a2, a9
 
    NEXT

defprimitive "and",3,and,REGULAR
    DPOP      a9
  
    and       a2, a2, a9
 
    NEXT

defprimitive "xor",3,xor,REGULAR
    DPOP      a9
  
    xor       a2, a2, a9
     
    NEXT

defprimitive "invert",6,invert,REGULAR
    movi      a9,TRUE
    
    xor       a2, a2, a9
    
    NEXT

defprimitive "lshift",6,lshift,REGULAR
    DPOP      a9

    ssl       a2
    sll       a2, a9
 
    NEXT

defprimitive "rshift",6,rshift,REGULAR
    DPOP      a9
 
    ssr       a2
    srl       a2, a9
  
    NEXT

.literal_position
defprimitive "_emit",5,uemit,REGULAR
   
    CCALL      forth_putchar
    DPOP       a2
    NEXT    

defprimitive "abort",5,abort,REGULAR
    CCALL      forth_abort
    NEXT

defprimitive "@",1,fetch,REGULAR

    l32i       a2, a2, 0

    NEXT

defprimitive "c@",2,fetchbyte,REGULAR

    l8ui       a2, a2, 0

    NEXT

defprimitive "!",1,store,REGULAR
 
    DPOP       a9
    s32i       a9, a2, 0
    DPOP       a2
    NEXT

defprimitive "c!",2,storebyte,REGULAR
    
    DPOP       a9
    s8i        a9, a2, 0
    DPOP       a2
    NEXT

defprimitive "[']",3,btick,REGULAR    // compile only
    DPUSH      a2
    l32i       a2, a14, 0
    addi       a14, a14, CELLS
    NEXT

defprimitive "<",1,lt,REGULAR         // only need to define this, all other comparisions are implemented in terms of lt
    DPOP a8
    READTOS1 a9
    movi a10, FALSE
    bge a9, a8, L4              // a9 >= a8 ?
    movi a10, TRUE
L4: WRTETOS1 a10
    NEXT

defprimitive "branch",6,branch,REGULAR
    l32i        a8, a14, 0           // read relative address as the next instruction
    add         a14, a14, a8         // advance forth PC
    NEXT

defprimitive "branch0",7,branch0,REGULAR
    DPOP a9
    beqz a9, code_branch
    addi a14, a14, CELLS
    NEXT

defprimitive ">r",2,rpush,REGULAR
 
    RPUSH       a2
    DPOP        a2
    NEXT

defprimitive "r>",2,rpop,REGULAR
    DPUSH       a2
    RPOP        a2
   
    NEXT

defprimitive "i",1,i,REGULAR
    DPUSH       a2
    l32i        a2, a13, 0
    
    NEXT

defprimitive "j",1,j,REGULAR
    DPUSH       a2
    l32i        a2, a13, 2*CELLS

    NEXT

defprimitive "execute",7,execute,REGULAR    
                                     // xt is in a2
    l32i        a9, a2, 0            // fetch codeword the same way as the inner interpreter does
    DPOP        a2
    jx          a9  

defprimitive "exit",4,exit,REGULAR
    RPOP        a14                     // pop forth PC from the return stack
    NEXT

defprimitive "sp@",3,spat,REGULAR
    DPUSH       a2
    mov         a2, a15

    NEXT

defprimitive "sp!",3,spstore,REGULAR

    mov         a15, a2
    DPOP        a2
    NEXT

defprimitive "rp@",3,rpat,REGULAR
    DPUSH       a2
    mov         a2,a13
    NEXT

defprimitive "rp!",3,rpstore,REGULAR
  
    mov         a13, a2
    DPOP        a2
    NEXT

// Different types of code words

.section .irom0.text
.align 4

ENTERCOL:                       // codeword for word (colon) definitions
    RPUSH       a14             // save program counter before entering the word
    addi        a14, a8, CELLS  // a8 points to the ENTERCOL, skip this cell    
    NEXT

ENTERDOES:
    DPUSH       a2
    RPUSH       a14             // save program counter before entering the word
    addi        a8, a8, CELLS   // a8 is on the codeword after there is the behaviour pointer
    l32i        a14, a8, 0      // set the FORTH PC to the behaviour
    addi        a2, a8, CELLS   // after the behaviour there is the data
    NEXT                        // invoke behavour with the data pointer in a2
  

ENTERCONST:
    DPUSH       a2
    l32i        a2, a8, CELLS

    NEXT

ENTERVAR:
    DPUSH       a2
    addi        a8, a8, CELLS
    
    NEXT
