\ ( —- FRAME BUFFER —- )
\ INCLUDE core.f

HEX
VARIABLE MODE

\ —-Utility—-
: FRAMEBUFFER ' MODE ! ;	\ Mode can be SET, TEST or GET
\ Build a TEST tag setting its values
: TEST HERE >R DROP >R SWAP 00004000 OR SWAP ADDTAG R> DUP	\ ( {values} id size ntest_params nget_params —- )
	0<> IF R> SET-VALUES ELSE R> 2DROP THEN ;

\ —-Tags—-
: ALLOCATE-BUFFER 	1 HERE 00040001 8 ADDTAG SET-VALUES ; \ ( alignment —- )
: RELEASE-BUFFER 	00048001 u32, 0 u32, 0 u32, ;		\ ( —- )
: BLANK-SCREEN 		1 HERE 00040002 4 ADDTAG SET-VALUES ; \ ( 0=off/1=on —- )
: W/H 			00040003 8 2 0 MODE @ EXECUTE ;	\ ( {width height} —- )
: VIRTUALW/H 		00040004 8 2 0 MODE @ EXECUTE ;	\ ( {Vwidth Vheight} —- )
: DEPTH 		00040005 4 1 0 MODE @ EXECUTE ;	\ ( {depth} —- )
: PIXEL-ORDER 		00040006 4 1 0 MODE @ EXECUTE ;	\ ( {1=RGB/0=BGR} —- )
: ALPHA-MODE 		00040007 4 1 0 MODE @ EXECUTE ;	\ ( {0=enabled/1=reversed/2=ignored} —- ) 
: PITCH 		00040008 4 0 0 MODE @ EXECUTE ;	\ ( —- )
: VIRTUAL-OFFSET 	00040009 8 2 0 MODE @ EXECUTE ; 	\ ( {x y} —- )
: OVERSCAN		0004000A 10 4 0 MODE @ EXECUTE ; 	\ ( {top bottom left right} —- )
: PALETTE 		0004000B 408 102 0 MODE @ EXECUTE ; 	\ ( {offset length values} —- )
: CURSOR-INFO 		00008010 18 6 0 MODE @ EXECUTE ; 	\ ( width height 0 pointertopixel x y —- )
: CURSOR-STATE 		00008011 10 4 0 MODE @ EXECUTE ; 	\ ( enable x y flags —- )

\ Multi-tag struct to set (test or get) frame buffer in a simple way
: CONFIG		\ ( {config} —- )
	W/H
	VIRTUALW/H
	DEPTH
	PIXEL-ORDER
	ALPHA-MODE
	MODE @ ['] GET = IF PITCH THEN ;

\ Some standard video resolution configurations for monitor
DECIMAL
: VGA
	0 		\ Alpha mode = enabled ( 0=fully opaque )
	1 		\ Pixel order = RGB
	4		\ Depth = 4bpp ( 16 colours )
	640 480		\ Virtual width/height ( in pixel )
	640 480		\ Physical width/height ( in pixel ) 
;
: XGA 
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	8		\ Depth = 8bpp (256 colours)
	1024 768	\ Virtual width/height (in pixel)
	1024 768	\ Physical width/height (in pixel) 
;
: SXGA
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	32		\ Depth = 32bpp (4Mld colours)
	1280 1024	\ Virtual width/height (in pixel)
	1280 1024	\ Physical width/height (in pixel) 
;
: FULL-HD
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	32	  	\ Depth = 32bpp (4Mld colours)
	1920 1080 	\ Virtual width/height (in pixel)
	1920 1080 	\ Physical width/height (in pixel) 
;

\ Some standard video resolution configurations for TV and beamer
: 720p 	\ HD ready
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	24	 	\ Depth = 24bpp (16Mln colours)
	1280 720 	\ Virtual width/height (in pixel)
	1280 720 	\ Physical width/height (in pixel)
;
: 1080p \ Full HD
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	24	  	\ Depth = 24bpp (16Mln colours)
	1920 1080 	\ Virtual width/height (in pixel)
	1920 1080 	\ Physical width/height (in pixel)
;
: 2160p \ 4K
	0		\ Alpha mode = enabled (0=fully opaque)
	1		\ Pixel order = RGB
	24	 	\ Depth = 24bpp (16Mln colours)
	3840 2160 	\ Virtual width/height (in pixel)
	3840 2160 	\ Physical width/height (in pixel)
;
HEX