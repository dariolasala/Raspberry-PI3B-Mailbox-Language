——————————————————————————————————————
—- Raspberry PI3B+ Mailbox Language —-
——————————————————————————————————————
This project was designed to simplify information transmission operations through 
mailboxes. It allows you to get hardware informations from VideoCore GPU, like 
board specifics, ARM and VC memory address, temperature of SoC, and get or set 
some specifics of hardware devices, like clock rate and state, voltage, power 
state. It also allows you to get, set or test a new frame buffer with specified 
width and height physical and virtual sizes, depth, pitch, cursor info and other
features.

This version was developed to communicate through Mailbox 0, that one to make request
from CPU and get response from VC. It uses the channel 8 to transmit property tags.

The code was written in Forth and was fully tested on a Raspberry PI3B+ board model.

——————————————————————————————————————
—- What’s included —-
——————————————————————————————————————
(1) Dictionary folder: contains Forth glossaries for structures and words defined.
(2) Utility folder: contains ‘se-ans.f’ and ‘jonesforth.f’ as support material.
(3) Mailbox.txt: a brief description of mailboxes on Raspberry PI boards.
(4) core.f : is the main code of the language (it must be imported as first).
(5) property-tag.f : includes the procedures to manage the property tags.
(6) frame-buffer.f : includes the procedures to manage the frame buffer.
(7) This README.txt file.

——————————————————————————————————————
—- Getting started —-
——————————————————————————————————————
I will refer to an interactive on-target programming mode, so the Raspberry PI3B+ 
has to be connected through its serial interconnection UART1 to a local computer.

—- Prerequisites —-
——————————————————————————————————————
In order to get this configuration, you need:
	(1) An FTDI 232 Usb Adapter, correctly connected to the PI through 
		GPIO14 (TX), GPIO15 (RX), GND pin and to the local computer
		through USB.
	(2) A pijForthos (bare-metal FORTH operating system for Raspberry Pi)
		booted on the PI.
	(3) A terminal emulator (like picocom) launched on the local computer.

—- Running —-
——————————————————————————————————————
To run up the project:
	(1) Launch the terminal emulator on the local computer with the following 
		parameters:
	$ picocom --b 9600 /dev/cu.usbserial-AH00TP26 --send "ascii-xfr -sn -l100 
	-c10" --imap delbs
	(2) Import the files in the following order:
		- jonesforth.f
		- se-ans.f
		- core.f
		- (optional) property-tag.f
		- (optional) frame-buffer.f
(To import a file from the terminal emulator: Ctrl-a followed by Ctrl-s and type 
the directory of the file)
!NOTE: If there are some issues on loading (like WORDS not recognized), try to
start a new line after every file loaded.

——————————————————————————————————————
—- Some features of PI 3B+	      —-
——————————————————————————————————————
With this project I obtained some particular features 
of the Raspberry PI 3B+:

Temperature average with ARM clock rate = 600Mhz: 34~37 °C
Temperature average with ARM clock rate > 800Mhz: >39 °C
Temperature max: 85 °C
ARM max clock rate: 1.4Ghz
ARM min clock rate: 600Mhz
CORE max voltage: 1.368750 V
CORE min voltage: 1.2 V
Base address of ARM memory (RAM): 0x0
Size of ARM memory (RAM): 994.05 MB
Base address of VC memory (RAM): 0x3B400000
Size of VC memory (RAM): 79.69 MB

——————————————————————————————————————
—- Coding style —-
——————————————————————————————————————
Here are foundamental encoding prototypes to manipulate the language:

(Property-tag)
———————————————————————————————————
MESSAGE name_message
parameters tag action
. . .
parameters tag action
ENDTAG

‘action’ can be SET or GET for all tags except for MEMORY tag, which performs
ALLOCATE, LOCK, UNLOCK or RELEASE, and EXECUTE-CODE tag, which needn’t action.

ATTENTION: MESSAGE word must be ended by ENDTAG word.

(Frame-buffer)
———————————————————————————————————
MESSAGE name_message
FRAMEBUFFER action
tag
. . .
tag
ENDTAG

‘action’ can be GET, SET or TEST.

ATTENTION: MESSAGE word must be ended by ENDTAG word.

To allocate a new frame buffer use SET-Mode and add ALLOCATE-BUFFER tag
(with alignment) as last tag before ENDTAG.

ATTENTION: it’s better to use a single message for each of framebuffer 
get/set/test action.

NOTE: Since Raspberry PI 2 model, frame buffer can be set, get or test through
the property-tag channel.

(Accessing mailbox)
———————————————————————————————————
channel MAILBOX action

‘action’ can be READ or WRITE.
‘channel’ can be 0-15 (here use PROPERTY-TAG).

NOTE: After building the message, write to mailbox through channel
PROPERTY-TAG and then read from mailbox through the same channel.

——————————————————————————————————————
—- Tags —-
——————————————————————————————————————
Following a list of tags defined in the language.

Specific:	|    parameters		|   tag			|    action
		————————————————————————————————————————————————————————————————
(Board)
		|			| BOARD MODEL 		| GET
		|			| BOARD REVISION	| GET
		|			| BOARD MAC-ADDR 	| GET
		|			| BOARD SERIAL 		| GET
(Power)
		| device_ID state	| POWER PSTATE 		| SET
		| device_ID 		| POWER PSTATE 		| GET
		| device_ID 		| POWER TIMING 		| GET

(Clock)
		| clock_ID 		| CLOCK STATE 		| GET
		| clock_ID state 	| CLOCK STATE 		| SET
		| clock_ID 		| CLOCK RATE 		| GET
		| clock_ID rate 	
		| skip_setting_turbo 	| CLOCK RATE 		| SET
		| clock_ID 		| CLOCK MAXRATE 	| GET
		| clock_ID 		| CLOCK MINRATE 	| GET
		| clock_ID 		| CLOCK TURBO 		| GET
		| clock_ID level 	| CLOCK TURBO 		| SET
(Voltage)
		| voltage_ID 		| VOLTAGE 		| GET
		| voltage_ID value 	| VOLTAGE 		| SET
		| voltage_ID 		| MAX-VOLTAGE 		| GET
		| voltage_ID 		| MIN-VOLTAGE 		| GET
(Memory)
		| size align flags 	| MEMORY 		| ALLOCATE
		| handle 		| MEMORY 		| LOCK
		| handle 		| MEMORY 		| UNLOCK
		| handle 		| MEMORY 		| RELEASE
(Other)
		|			| TEMPERATURE 		| GET
		|			| MAX-TEMPERATURE 	| GET
		| 			| FIRMWARE-REVISION 	| GET
		|			| ARM-MEMORY 		| GET
		| 			| VC-MEMORY 		| GET
		| 			| CLOCKS 		| GET
		|			| COMMAND-LINE 		| GET
		|			| DMA-CHANNELS 		| GET
		| function_pointer r0 
		| … r5 			| EXECUTE-CODE		| {no action}
		| dispmanx_res_handle 	| DISPMANX-RESOURCE-MEM-HANDLE | GET
		| block_number 		| EDID-BLOCK 		| GET
(Framebuffer)
		| alignment 		| ALLOCATE-BUFFER	| {no action}	
		|			| RELEASE-BUFFER	| {no action}
		| state 		| BLANK-SCREEN		| {no action}
-Switching mode-
		|			| W/H			| (GET Mode)
		| width height 		| W/H			| (SET-TEST Mode)
		|			| VIRTUALW/H		| (GET Mode)
		| width height 		| VIRTUALW/H		| (SET-TEST Mode)
		|			| DEPTH			| (GET Mode)
		| depth 		| DEPTH			| (SET-TEST Mode)
		|			| PIXEL-ORDER		| (GET Mode)
		| state 		| PIXEL-ORDER		| (SET-TEST Mode)
		|			| ALPHA-MODE		| (GET Mode)
		| state 		| ALPHA-MODE		| (SET-TEST Mode)
		| 			| PITCH			| (GET Mode)
		| 			| VIRTUAL-OFFSET	| (GET Mode)
		| x y 			| VIRTUAL-OFFSET	| (SET-TEST Mode)
		| 			| OVERSCAN		| (GET Mode)
		| top bottom left right| OVERSCAN		| (SET-TEST Mode)
		| 			| PALETTE		| (GET Mode)
		| offset length values	| PALETTE		| (SET-TEST Mode)
		| width height 0 
		| pointertopixel x y 	| CURSOR-INFO		| (SET-TEST Mode)
		| enable x y flags 	| CURSOR-STATE		| (SET-TEST Mode)

——————————————————————————————————————
—- Examples —-
——————————————————————————————————————

- EXAMPLE 1 - General tag
- The prototype is:
MESSAGE M
value1 value2 ... valuen id_tag size_vbuffer n_set_parameter n_get_parameter GET/SET
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL	
- For example, to activate/deactivate the red led, the tag id is 0x00030041,
the pin number is 130 (0x82) and the status ON is 1:
MESSAGE M
00000082 1 00030041 8 2 1 SET
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL	

- EXAMPLE 2 - Getting and setting ARM clock rate
\ Getting ARM clock rate
MESSAGE M
ARM CLOCK RATE GET
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL		\ 600Mhz
\ Setting ARM clock rate to 1.2Ghz
MESSAGE M
ARM 1200000000 1 CLOCK RATE SET
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL		\ Look if response code is 0x80000008

- EXAMPLE 3 - Getting and setting new frame buffer
\ Getting current frame buffer (if exists)
MESSAGE M
FRAMEBUFFER GET
CONFIG
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL		\ Shows all features
\ Setting and allocating new frame buffer
MESSAGE M
FRAMEBUFFER SET
VGA CONFIG
16 ALLOCATE-BUFFER	\ 16-byte aligned
ENDTAG
PROPERTY-TAG MAILBOX WRITE
PROPERTY-TAG MAILBOX READ
SHOWALL		\ Look if everything is well