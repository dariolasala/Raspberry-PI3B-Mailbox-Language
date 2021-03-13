\ ( —- PROPERTY TAGS —- )
\ INCLUDE core.f

HEX
00000000 CONSTANT STATE-OFF		\ For ‘state’ value in some tags
00000001 CONSTANT STATE-ON		\ For ‘state’ value in some tags
00000002 CONSTANT STATE-OFF-WAIT	\ For ‘state’ value in some tags
00000003 CONSTANT STATE-ON-WAIT	\ For ‘state’ value in some tags
VARIABLE CURRENT-TAG

\ —- BOARD —-
: BOARD 00010000 CURRENT-TAG ! ;	\ ( —- )
\ Specifics
: MODEL 	00000001 CURRENT-TAG @ OR 4 0 0 ;	\ ( —- id size nset_params nget_params )
: REVISION 	00000002 CURRENT-TAG @ OR 4 0 0 ;	\ ( —- id size nset_params nget_params )
: MAC-ADDR 	00000003 CURRENT-TAG @ OR 6 0 0 ; 	\ ( —- id size nset_params nget_params )
: SERIAL 	00000004 CURRENT-TAG @ OR 8 0 0 ; 	\ ( —- id size nset_params nget_params )

\ —- POWER —-
: POWER 00020000 CURRENT-TAG ! ;	\ ( —- )
\ Specifics
: PSTATE 	00000001 CURRENT-TAG @ OR 8 2 1 ;	\ ( —- id size nset_params nget_params )
: TIMING 	00000002 CURRENT-TAG @ OR 8 0 1 ;	\ ( —- id size nset_params nget_params )
\ Unique device IDs
00000000 CONSTANT SD-CARD
00000001 CONSTANT UART0
00000002 CONSTANT UART1
00000003 CONSTANT USB-HCD
00000004 CONSTANT I2C0
00000005 CONSTANT I2C1
00000006 CONSTANT I2C2
00000007 CONSTANT SPI
00000008 CONSTANT CCP2TX

\ —- CLOCK —-
: CLOCK 00030000 CURRENT-TAG ! ;	\ ( —- )
\ Specifics
: STATE 	00000001 CURRENT-TAG @ OR 8 2 1 ;	\ ( —- id size nset_params nget_params )
: RATE	 	00000002 CURRENT-TAG @ OR C 3 1 ;	\ ( —- id size nset_params nget_params )
: MAXRATE 	00000004 CURRENT-TAG @ OR 8 0 1 ;	\ ( —- id size nset_params nget_params )
: MINRATE 	00000007 CURRENT-TAG @ OR 8 0 1 ;	\ ( —- id size nset_params nget_params )
: TURBO 	00000009 CURRENT-TAG @ OR 8 2 1 ;	\ ( —- id size nset_params nget_params )
\ Unique clock IDs
00000001 CONSTANT EMMC
00000002 CONSTANT UART
00000003 CONSTANT ARM
00000004 CONSTANT CORE
00000005 CONSTANT V3D
00000006 CONSTANT H264
00000007 CONSTANT ISP
00000008 CONSTANT SDRAM
00000009 CONSTANT PIXEL
0000000A CONSTANT PWM

\ —- VOLTAGE —-
: VOLTAGE 	00030003 8 2 1 ;	\ ( —- id size nset_params nget_params )
: MAX-VOLTAGE 	00030005 8 0 1 ;	\ ( —- id size nset_params nget_params )
: MIN-VOLTAGE 	00030008 8 0 1 ;	\ ( —- id size nset_params nget_params )
\ Unique voltage IDs
00000001 CONSTANT CORE_VOLT
00000002 CONSTANT SDRAM_C
00000003 CONSTANT SDRAM_P
00000004 CONSTANT SDRAM_I

\ —- MEMORY —-
: MEMORY 00030000 CURRENT-TAG ! ;	\ ( —- )
\ Specifics
: ALLOCATE 	HERE >R 0000000C CURRENT-TAG @ OR C ADDTAG 3 R> SET-VALUES ;	\ ( size align flags —- )
: LOCK	 	HERE >R 0000000D CURRENT-TAG @ OR 4 ADDTAG 1 R> SET-VALUES ;	\ ( handle —- )
: UNLOCK 	HERE >R 0000000E CURRENT-TAG @ OR 4 ADDTAG 1 R> SET-VALUES ;	\ ( handle —- )
: RELEASE 	HERE >R 0000000F CURRENT-TAG @ OR 4 ADDTAG 1 R> SET-VALUES ;	\ ( handle —- )
\ Memory flags (For ALLOCATE use only)
00000001 CONSTANT MEM_FLAG_DISCARDABLE
00000000 CONSTANT MEM_FLAG_NORMAL
00000100 CONSTANT MEM_FLAG_DIRECT
00001000 CONSTANT MEM_FLAG_COHERENT
00001100 CONSTANT MEM_FLAG_L1_NONALLOCATING \ ( MEM_FLAG_DIRECT | MEM_FLAG_COHERENT )
00010000 CONSTANT MEM_FLAG_ZERO
00100000 CONSTANT MEM_FLAG_NO_INIT
01000000 CONSTANT MEM_FLAG_HINT_PERMALOCK

\ —- TEMPERATURE —-
: TEMPERATURE 		00030006 8 0 0 ;	\ ( —- id size nset_params nget_params )
: MAX-TEMPERATURE 	0003000A 8 0 0 ;	\ ( —- id size nset_params nget_params )

\ —- VideoCore —-
: FIRMWARE-REVISION 	00000001 4 0 0 ;	\ ( —- id size nset_params nget_params )

\ Hardware
: ARM-MEMORY	00010005 8 0 0 ;		\ ( —- id size nset_params nget_params )
: VC-MEMORY 	00010006 8 0 0 ;		\ ( —- id size nset_params nget_params )
: CLOCKS 	00010007 60 0 0 ;		\ ( —- id size nset_params nget_params )

\ Config
: COMMAND-LINE	00050001 19A 0 0 ;		\ ( —- id size nset_params nget_params )	

\ Shared resource management
: DMA-CHANNELS	00060001 4 0 0 ;		\ ( —- id size nset_params nget_params )

\ Other
: EXECUTE-CODE HERE >R 00030010 1C ADDTAG 7 R> SET-VALUES ;	\ ( function_pointer r0 … r5 —- )
: DISPMANX-RESOURCE-MEM-HANDLE 00030014 8 0 1 ;		\ ( —- id size nset_params nget_params )
: EDID-BLOCK 00030020 88 0 1 ; 				\ ( block_number —- id size nset_params nget_params ) 