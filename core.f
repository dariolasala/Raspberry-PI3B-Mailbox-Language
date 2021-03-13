\ For pijForth in Raspberry Pi 3B+
\ INCLUDE jonesforth.f
\ INCLUDE se-ans.f

HEX
4 CONSTANT u32_t	\ Data size of words through mailbox
4 CONSTANT CELL 	\ Cell of memory (4 Byte in Pi3B+ 32-kernel mode) 

\ ( —-Utility—- )
\ : C, HERE C! 1 ALLOT ;	\ ( n —- )
: 0ALLOT BEGIN 0 C, 1 - DUP 0= UNTIL DROP ; \ ( nbyte —- )
: u32* 2 LSHIFT ; 	\ ( n —- n*4bytes )
: u32/ 2 RSHIFT ;	\ ( n —- n/4bytes )
: u32+ 4 + ; 		\ ( n —- n+4bytes )
: u32- 4 - ;		\ ( n —- n-4bytes )
: u32! ! ;		\ ( val addr —- )
: u32@ @ ; 		\ ( addr —- val )
: u32, , ; 		\ ( val —- )
: 16ALIGNED F + F INVERT AND ;			\ ( n —- n16aligned )
: 16ALIGN JF-HERE @ 16ALIGNED JF-HERE ! ; 	\ ( —- )

\ ( —-Message management—- )
\ : MESSAGE CELL 0ALLOT 16ALIGN HERE 2 u32* 0ALLOT ;	\ Without giving name like M1.
: MESSAGE CREATE 0 , 16ALIGN HERE 0 u32, 0 u32, ;
: OFFSET CELL + 16ALIGNED ; 	\ ( struct_addr —- msg_addr )
: RESPONSE u32+ u32@ ; 	\ ( msg_addr —- response_code )
: FIRST-TAG 2 u32* + ; 	\ ( msg_addr —- FIRST_tag_addr )
: ITERATOR CELL - ; 		\ ( msg_addr —- iterator_addr )
: STORETAG ITERATOR ! ;	\ ( addr msg_addr —- )
: UPDATE-SIZE HERE OVER - SWAP u32! ;	\ ( msg_addr —- )

\ ( —-Tag building—- )
: INIT-VALUEBUFFER ALIGNED 0ALLOT ; 	\ ( valuebuffer_size —- )
: ADDTAG DUP ROT u32, u32, 0 u32, INIT-VALUEBUFFER ;	\ ( id size —- )
: ENDTAG 0 u32, DUP 			\ ( msg_addr —- msg_addr )
	DUP UPDATE-SIZE
	DUP FIRST-TAG SWAP STORETAG ;	\ ( Initializes iterator to the first tag )
: VBUFFER 3 u32* + ; 			\ ( tag_addr —- valuebuffer_addr )
: SET-VALUES VBUFFER OVER 1 - u32* + BEGIN		\ ( n1 n2 … nk nvalues tag_addr —- )
	ROT OVER u32! u32- SWAP 1 - SWAP OVER 0 = UNTIL
	DROP DROP ;
\ Build a GET tag setting its values
: GET HERE >R >R DROP ADDTAG R> DUP				\ ( {values} id size nset_params nget_params —- )
	0<> IF R> SET-VALUES ELSE R> 2DROP THEN ;
\ Build a SET tag setting its values
: SET HERE >R DROP >R SWAP 00008000 OR SWAP ADDTAG R> DUP	\ ( {values} id size nset_params nget_params —- )
	0<> IF R> SET-VALUES ELSE R> 2DROP THEN ;

\ ( —-Tag management—- )
: ID u32@ ; 				\ ( tag_addr —- id )
: VBSIZE u32+ u32@ ; 			\ ( tag_addr —- valuebuffer_size )
: RESCODE 2 u32* + u32@ ; 		\ ( tag_addr —- res_code )
: TAGSIZE VBSIZE ALIGNED 3 u32* + ; 	\ ( tag_addr —- tag_size )
: GET-VALUES DUP VBSIZE ALIGNED u32/ DUP		\ ( tag_addr —- n1 … nk )
	0<> IF SWAP VBUFFER BEGIN DUP u32@ SWAP u32+ ROT 1 - SWAP OVER 0 = UNTIL 
	THEN DROP DROP ;

\ ( —-Iterator Property—- )
: TAG DUP ITERATOR @ ; 	\ ( msg_addr —- msg_addr CURRENT_tag_addr )
: NEXT-TAG TAG DUP TAGSIZE + NIP ; 	\ ( msg_addr —- NEXT_tag_addr )
: HASNEXT DUP NEXT-TAG SWAP DUP u32@ + u32- < ;	\ ( msg_addr —- bool )
: NEXT DUP HASNEXT IF		\ ( msg_addr —- msg_addr )
	DUP NEXT-TAG ELSE
	DUP FIRST-TAG THEN
	OVER STORETAG ;

\ ( —-Sending through mailbox—- )
3F00B880 CONSTANT MAIL_0	\ Base address for mailbox 0
00000000 CONSTANT READ_OFFS	\ Offset of read register
00000018 CONSTANT STATUS_OFFS	\ Offset of status register
00000020 CONSTANT WRITE_OFFS	\ Offset of write register
80000000 CONSTANT MAIL_FULL	\ Set if WRITE_REG is FULL ( can’t write )
40000000 CONSTANT MAIL_EMPTY	\ Set if READ_REG is EMPTY ( nothing to read )
8 CONSTANT PROPERTY-TAG	\ Channel
1 CONSTANT FRAME-BUFFER	\ Channel (unused since PI 2. Use PROPERTY-TAG channel)
VARIABLE MAIL_BASE

: MAILBOX MAIL_0 MAIL_BASE ! ;			\ ( —- )
: REG MAIL_BASE @ + ; 				\ ( offset —- reg_addr )
: CHECK-STATUS STATUS_OFFS REG @ AND ;	\ ( bit_to_evaluate —- bool )
: CHECK-CHANNEL F AND = ; 			\ ( channel data —- bool )
: WRITE OR 					\ ( msg_addr channel —- )
	BEGIN MAIL_FULL CHECK-STATUS NOT UNTIL WRITE_OFFS REG ! ;
: READ 						\ ( channel —- {data} )
	BEGIN MAIL_EMPTY CHECK-STATUS NOT UNTIL 
	READ_OFFS REG @ SWAP OVER CHECK-CHANNEL IF FFFFFFF0 AND ELSE DROP THEN ;

\ ( —-Print—- )
HEX
: BOARD-MODEL-STR 	." board model " ;
: BOARD-REVISION-STR 	." board revision " ;
: BOARD-MAC-ADDR-STR 	." board mac address " ;
: BOARD-SERIAL-STR 	." board serial " ;
: POWER-STATE-STR 	." power state " ;
: POWER-TIMING-STR 	." power timing " ;
: CLOCK-STATE-STR 	." clock state " ;
: CLOCK-RATE-STR 	." clock rate " ;
: CLOCK-MAXRATE-STR 	." max clock rate " ;
: CLOCK-MINRATE-STR 	." min clock rate " ;
: CLOCK-TURBO-STR 	." clock turbo " ;
: VOLTAGE-STR 		." voltage " ;
: MAX-VOLTAGE-STR 	." max voltage " ;
: MIN-VOLTAGE-STR 	." min voltage " ;
: ALLOCATE—MEMORY-STR 	." allocate memory " ;
: LOCK—MEMORY-STR 	." lock memory " ;
: RELEASE—MEMORY-STR 	." release memory " ;
: UNLOCK—MEMORY-STR 	." unlock memory " ;
: TEMPERATURE-STR 	." temperature " ;
: MAX-TEMPERATURE-STR 	." max temperature " ;
: FIRMWARE-REVISION-STR ." firmware revision " ;
: ARM-MEMORY-STR 	." ARM memory " ;
: VC-MEMORY-STR		." VC memory " ;
: CLOCKS-STR		." clocks " ;
: COMMAND-LINE-STR	." command line " ;
: DMA-CHANNELS-STR	." DMA channels " ;
: EXECUTE-CODE-STR	." execute code " ;
: DISPMANX-RESOURCE-MEM-HANDLE-STR	." dispmanx resource mem handle " ;
: EDID-BLOCK-STR	." EDID block " ;
: BLANK-SCREEN-STR	." blank screen " ;
: W/H-STR		." physical width/height " ;
: VIRTUALW/H-STR	." virtual width/height " ;
: DEPTH-STR		." depth " ;
: PIXEL-ORDER-STR	." pixel order " ;
: ALPHA-MODE-STR	." alpha mode " ;
: PITCH-STR		." pitch " ;
: VIRTUAL-OFFSET-STR	." virtual offset " ;
: OVERSCAN-STR		." overscan " ;
: PALETTE-STR		." palette " ;
: CURSOR-INFO-STR	." cursor info " ;
: CURSOR-STATE-STR	." cursor state " ;

CREATE TAG-ID-NAME
00010001 , ' BOARD-MODEL-STR , 
00010002 , ' BOARD-REVISION-STR , 
00010003 , ' BOARD-MAC-ADDR-STR , 
00010004 , ' BOARD-SERIAL-STR , 
00020001 , ' POWER-STATE-STR , 
00020002 , ' POWER-TIMING-STR , 
00030001 , ' CLOCK-STATE-STR , 
00030002 , ' CLOCK-RATE-STR , 
00030004 , ' CLOCK-MAXRATE-STR , 
00030007 , ' CLOCK-MINRATE-STR , 
00030009 , ' CLOCK-TURBO-STR , 
00030003 , ' VOLTAGE-STR , 
00030005 , ' MAX-VOLTAGE-STR , 
00030008 , ' MIN-VOLTAGE-STR , 
0003000C , ' ALLOCATE—MEMORY-STR , 
0003000D , ' LOCK—MEMORY-STR , 
0003000F , ' RELEASE—MEMORY-STR , 
0003000E , ' UNLOCK—MEMORY-STR , 
00030006 , ' TEMPERATURE-STR , 
0003000A , ' MAX-TEMPERATURE-STR , 
00000001 , ' FIRMWARE-REVISION-STR ,
00010005 , ' ARM-MEMORY-STR ,
00010006 , ' VC-MEMORY-STR ,
00010007 , ' CLOCKS-STR ,
00050001 , ' COMMAND-LINE-STR ,
00060001 , ' DMA-CHANNELS-STR ,
00030010 , ' EXECUTE-CODE-STR ,
00030014 , ' DISPMANX-RESOURCE-MEM-HANDLE-STR ,
00030020 , ' EDID-BLOCK-STR ,
00040002 , ' BLANK-SCREEN-STR ,
00040003 , ' W/H-STR ,
00040004 , ' VIRTUALW/H-STR ,
00040005 , ' DEPTH-STR ,
00040006 , ' PIXEL-ORDER-STR ,
00040007 , ' ALPHA-MODE-STR ,
00040008 , ' PITCH-STR ,
00040009 , ' VIRTUAL-OFFSET-STR ,
0004000A , ' OVERSCAN-STR ,
0004000B , ' PALETTE-STR ,
00000010 , ' CURSOR-INFO-STR ,
00000011 , ' CURSOR-STATE-STR ,

29 CELL 2 * * CONSTANT SIZE-ARRAY	\ ( 41 elements * 2cells )

: PRINT-MODE 0000F000 AND DUP		\ ( id —- )
	00000000 = IF DROP ." Get " ELSE
	00008000 = IF ." Set " ELSE ." Test " THEN THEN ;
: PRINT-ID DUP				\ ( id —- )
	00040001 = IF DROP ." Allocate buffer " ELSE DUP
	00048001 = IF DROP ." Release buffer " ELSE DUP
	PRINT-MODE FFFF0FFF AND 0 BEGIN SWAP OVER TAG-ID-NAME + @ OVER 
		= IF DROP CELL + TAG-ID-NAME + @ EXECUTE EXIT THEN 
	SWAP 2 CELL * + DUP SIZE-ARRAY = UNTIL 2DROP THEN THEN ;
: PRINT-VALUES DUP VBSIZE ALIGNED u32/ DUP		\ ( tag_addr —- )
	0<> IF SWAP VBUFFER BEGIN DUP u32@ U. u32+ SWAP 1 - SWAP OVER 0 = UNTIL
	THEN DROP DROP ;
: SHOW DUP CR		\ ( tag_addr —- )
	ID PRINT-ID DUP CR	
	VBSIZE U. DUP CR
	RESCODE U. CR
	PRINT-VALUES CR ;
: SHOWALL DUP FIRST-TAG DUP SHOW OVER STORETAG DUP	\ ( msg_addr —- )
	HASNEXT IF BEGIN DUP NEXT TAG SHOW HASNEXT NOT UNTIL THEN DROP ;