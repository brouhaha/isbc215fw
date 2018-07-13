; Disassembly of Intel iSBC 215B firmware, 144580-001 and 144581-001
; symbols and comments copyright 2016 Eric Smith <spacewar@gmail.com>

; The iSBC 215B Winchester Disk Controller uses the same hardware as
; the iSBC 215A, but different firmware. The iSBC 215B supports hard
; drives with closed-loop positioning, and floppy drives via an optional
; iSBX 218 Floppy Disk Controller daughterboard.


isbx_218a_ch0	equ	0c0d0h	; iSBX 218 floppy
fdc_status	equ	0	; offset of status register
fdc_data	equ	2	; offset of data register


        ljmp    chan1_prog_start

        ljmp    chan2_prog_start

chan1_prog_start:
	movi    gc,7f3bh
        movbi   [gc].0bh,0h
        movbi   cc,0h

        movi    ga,x010a	; ga = SCP pointer (sys addr 0fff6h)
        lpd     gb,[ga]

        movb    [gc].0ch,[gb]	; [gc].0ch = SCP.SYSBUS = system (Multibus) bus width
        jbt     [gc].0ch,0,x0027  ; set system bus width per SCP.SYSBUS
        wid     8,16
        jmp     x0029
x0027:  wid     16,16
x0029:

	lpd     ga,[gb].2h	; ga = SCB ptr (iSBC 215 WUB: wake up block

        lpd     gb,[ga].2h	; gb = [SCB+2] = 8089 channel 1 CCB ptr
				;   (iSBC 215 CIB: channel invocation block offset 4)

        lpd     ga,[gb].2h	; ga = [CCB+2] = 8089 channel 1 CPB ptr
        addbi   ga,0fffch	; ga = channel 1 CIB (starts 4 bytes before CPB)
        movp    [gc].1h,ga
	
        lpd     gb,[ga].8h	; gb = [CIB+8] = IOPB pointer
        movp    [gc].5h,gb

; copy 30-byte IOPB to local mem
        movi    ga,7f48h
        movi    cc,0c408h
        movbi   bc,1eh
        xfer

        movbi   mc,0ffech
        movb    [gc],[gc].15h
        andb    mc,[gc].17h
        jz      mc,x0062
        movi    [gc].2eh,6000h
        movbi   [gc].17h,0h
x0062:  movb    ix,[gc].17h
        andbi   ix,3h
        movi    ga,7e00h
        lcall   [ga].0fh,x15aa
        setb    [gb+ix],5
        clr     [gb+ix],3
        jnbt    [gc].19h,0,x007b
        clr     [gb+ix],5
x007b:  jnbt    [gc].19h,1,x0081
        setb    [gb+ix],3
x0081:  jnz     mc,x00be
        movb    mc,[gc].18h
        andbi   mc,0fff0h
        jnz     mc,cmd_invalid
        movi    gb,cmd_dispatch
        addb    gb,[gc].18h
        addb    gb,[gc].18h
        mov     tp,[gb]

cmd_dispatch:
	dw      cmd_initialize	; 00 initialize
        dw      cmd_xfer_status	; 01 transfer status buffer
	dw	cmd_format	; 02 format
	dw	cmd_read_id	; 03 read sector ID
	dw	cmd_read_data	; 04 read data
	dw	cmd_read_verify	; 05 read data to buffer and verify
	dw	cmd_write_data	; 06 write data
	dw	cmd_write_buf	; 07 write buffer data
	dw	cmd_track_seek	; 08 initiate track seek
	dw	cmd_invalid
	dw	cmd_invalid
	dw	cmd_invalid
	dw	cmd_isbx_exec	; 0c iSBX execute
	dw	cmd_isbx_xfer	; 0d iSBX transfer
	dw	cmd_buf_io	; 0e buffer I/O
	dw	cmd_diag	; 0f diagnostic


cmd_invalid:
	movi    [gc].2eh,800h
x00be:  movbi   [gc].30h,0h
        movbi   bc,0h

x00c5:  movb    ga,[gc].3ah
        addb    [gc].39h,ga
        movi    ga,7e00h
        movp    gb,[gc].5h
        movb    ix,[gc].17h
        andbi   ix,3h
        mov     [gb].4h,[gc].11h
        mov     [gb].6h,[gc].13h
        movi    cc,100h
        movbi   [gc].0bh,0ffffh
        mov     mc,[gc].0ddh
        movbi   mc,1h
        jnz     [gc].2eh,x00fa
        jzb     [gc].30h,x0103
x00fa:  orbi    mc,0ff80h
        jnz     bc,x0103
        orbi    mc,40h
x0103:  lcall   [ga].14h,x0203
        hlt     

x010a:  dw      0fff6h
        dw      0f000h


chan2_prog_start:
	movi    gc,7f3bh
        movbi   [gc].52h,0h
x0116:  movi    ga,7e82h
        movbi   ix,0ffffh
        incb    [gc].52h
        clr     [gc],0
x0122:  movi    gb,7fd4h
        movbi   cc,0h
        jbt     [gc].52h,0,x0132
        setb    [gc],0
        addbi   gb,4h
x0132:  inc     ix
        mov     [gc].9h,gb
        movbi   [ga],0fffch
        addb    [ga],ix
        movi    cc,100h
        jnzb    [gc].0bh,x0146
        hlt     
x0146:  jzb     [ga],x0116
        jnbt    [gb+ix],0,x0122
        lcall   [ga],x15b7
        mov     gb,[gc].9h
        jbt     [gb+ix],2,x019b
        ljbt    [gc],0,x01db
        jnbt    [gc].0c5h,1,x0170
x015e:  clr     [gb+ix],1
        jmp     x0122

x0163:  lcall   [ga],x16e2
        mov     gb,[gc].9h
        jnz     bc,x0170
        jmp     x015e

x0170:  jbt     [gb+ix],1,x0122
        jnbt    [gc],0,x0187
        lcall   [ga],x19d3
        jnz     bc,x0181
        lcall   [ga],x19d3
x0181:  mov     gb,[gc].9h
        jz      bc,x015e
x0187:  setb    [gb+ix],1
        movbi   mc,4h
        call    [ga],x0192
        jmp     x0122

x0192:  setb    [gb+ix],5
        lcall   [ga].14h,x0203
        mov     tp,[ga]

x019b:  jbt     [gc],0,x01db
        jnbt    [gc].0cdh,5,x01bf
        ljbt    [gc].0c5h,2,x0122
x01a7:  movbi   [ga].3h,0h
        addbi   ga,14h
x01ae:  movbi   mc,2h
        mov     gb,[gc].9h
        clr     [gb+ix],2
        call    [ga],x0192
        addbi   ga,0ffefh
        jmp     x01ec

x01bf:  lcall   [ga],x17fa
        ljbt    [ga].2h,4,x0122
        movb    [ga],[ga].2h
        andbi   [ga],0ffa4h
        jnzb    [ga],x01a7
        ljnbt   [ga].2h,1,x0122
        jmp     x01a7

x01db:  ljbt    [gc].0cdh,0,x0116
        ljnbt   [gc].0cdh,2,x0163
        lcall   [ga],x1818
x01e9:  addbi   ga,3h
x01ec:  ljzb    [ga],x0122
        movb    ix,[ga]
        andbi   ix,3h
        jzb     [ga].2h,x01e9
        ljnbt   [ga],5,x0122
        addbi   ga,14h
        jmp     x01ae

x0203:  movi    gb,1ff9h
        orb     mc,[gb+ix]
        movp    gb,[gc].1h
        jnbt    [gc],0,x0212
        orbi    mc,8h
x0212:  jzb     [gb].3h,x021e
        dec     bc
        jmp     x021b

x021b:  jmp     x0212

x021e:  movb    [gb].1h,mc
        movbi   [gb].3h,0ffffh
        lcall   [ga].0fh,x15aa
        jnbt    [gb+ix],5,x0239
        setb    [gc].58h,0
        mov     [gc].0d5h,[gc].57h
        clr     [gc].58h,0
x0239:  mov     tp,[ga].14h

cmd_initialize:
        lcall   [ga],x1333
        jbt     [gc],0,x0258
        jnz     ix,x0258
        lcall   [ga],x078a
        jz      bc,x0251
        lcall   [ga],x07ea
x0251:  movbi   [gc].11h,45h
        jmp     x025c

x0258:  movbi   [gc].11h,8h
x025c:  lcall   [ga],x158d
        mov     [gc].53h,gb
        mov     ga,[gc].53h
        lpd     gb,[gc].1fh
        movbi   bc,8h
        movi    cc,0c408h
        xfer    
        nop     
        movi    ga,7e00h
        mov     gb,[gc].53h
        lcall   [ga],x15e2
        movi    ga,7fd4h
        jnbt    [gc],0,x0297
        addbi   ga,4h
        jzb     [gb],x02b2
        clr     [ga+ix],6
        jnbt    [gb].7h,0,x0294
        setb    [ga+ix],6
x0294:  jmp     x02e0

x0297:  jz      [gb],x02b2
        orbi    [ga+ix],3h
x029d:  movi    ga,7e00h
        lcall   [ga],x15b7
        jz      bc,x02af
        lcall   [ga],x19d3
        jnz     bc,x02b2
x02af:  setb    [gc].2fh,6
x02b2:  movbi   [gc].0ebh,34h
        movbi   [gc].0ebh,74h
        movbi   [gc].0ebh,0ffb4h
        movb    [gc].0e5h,bc
        movb    [gc].0e5h,bc
        movb    [gc].0e7h,bc
        movb    [gc].0e7h,bc
        movb    [gc].0e9h,bc
        movb    [gc].0e9h,bc
        movbi   [gc].0ebh,3ah
        movbi   [gc].0ebh,7ah
        movbi   [gc].0ebh,0ffbah
        ljmp    x00c5

x02e0:  orbi    [ga+ix],3h
        movi    ga,7e00h
        jbt     [gc].0cdh,0,x029d
        lcall   [ga].19h,x1769
        lcall   [ga],x1818
        lcall   [ga],x1333
        movbi   [gb].2h,3h
        movi    mc,0f090h
        lcall   [ga].19h,x1796
        jbt     [gc],1,x0318
        movbi   [gb].2h,5fh
        lcall   [ga].19h,x1796
        movbi   [gb].2h,3dh
        jmp     x029d

x0318:  movbi   [gb].2h,0fh
        lcall   [ga].19h,x1796
        movbi   [gb].2h,4dh
        ljmp    x029d

cmd_xfer_status:
        lpd     ga,[gc].1fh
        movi    gb,7f69h
        movbi   bc,0ch
        jbt     [gc].0ch,0,x0339
        wid     16,8
x0339:  xfer    
        nop     
        movi    ga,7e00h
        lcall   [ga],x1333
        movbi   [gc].11h,0ch
        dec     bc
        ljmp    x00c5

cmd_buf_io:
        lcall   [ga],x1333
        mov     [gc].11h,[gc].23h
        lpd     ga,[gc].1fh
        mov     bc,[gc].23h
        movi    cc,0c408h
        wid     16,16
        jzb     [gc].1dh,x0376
        andi    cc,0fbffh
        jbt     [gc].0ch,0,x037c
        wid     8,16
        jmp     x037c

x0376:  jbt     [gc].0ch,0,x037c
        wid     16,8
x037c:  mov     gb,[gc].1bh
        xfer    
        nop     
        dec     bc
        ljmp    x00c5

cmd_track_seek:
        lcall   [ga],x1333
        movb    [gc].33h,[gc].1dh
        mov     [gc].31h,[gc].1bh
        andi    [gc].31h,0fffh
        lcall   [ga].0fh,x15aa
        jnbt    [gb+ix],2,x03af
        setb    [gc].2eh,5
        movbi   bc,0h
        jmp     x03f9

x03af:  lcall   [ga],x15b7
        jz      bc,x03d2
        lcall   [ga],x158d
        lcall   [ga],x1539
        jz      bc,x03d8
        lcall   [ga],x1530
        jnz     bc,x03de
        lcall   [ga],x19d3
        movbi   bc,0h
        jmp     x03d8

x03d2:  setb    [gc].2fh,6
        jmp     x03f9

x03d8:  setb    [gc].2fh,5
        jmp     x03f9

x03de:  movb    mc,[gc].33h
        lcall   [ga],x1646
        jz      bc,x03f9
        mov     mc,[gc].31h
        lcall   [ga],x18ba
        jz      bc,x03f9
        lcall   [ga].0fh,x15aa
        setb    [gb+ix],2
x03f9:  ljmp    x00c5

cmd_format:
        lcall   [ga],x1250
        ljz     bc,x051b
        lcall   [ga],x1043
        ljz     bc,x051b
        movbi   [gc].11h,6h
        lpd     gb,[gc].1fh
        mov     [ga],[gb]
        mov     [ga].2h,[gb].2h
        mov     [ga].4h,[gb].4h
        andbi   [ga],0ffc0h
        jnbt    [gc],0,x0438
        movb    [gc].51h,[ga].1h
        ljzb    [ga],x0484
        ljmp    x0504

x0438:  jnbt    [ga],7,x043f
        ljbt    [ga],6,x0504
x043f:  movb    bc,[ga]
        orb     [gc].3eh,bc
        mov     bc,[gc].42h
        movb    [ga].8h,[gc].44h
        movi    [gc].4fh,4429h
        movb    mc,[gc].44h
        movb    [gc].53h,[gc].44h
        movb    gb,[gc].44h
        addb    [gc].53h,gb
        addbi   gb,0fffch
        movb    [ga].9h,gb
        movb    [ga].0ah,[gc].53h
        movi    gb,4010h
        movbi   ix,0h
x0474:  mov     [gb+ix+],[ga].1h
        mov     [gb+ix+],[ga].3h
        addbi   bc,0fffch
        jnz     bc,x0474
x0484:  movb    ix,[ga].5h
        addbi   ga,0fh
        lcall   [ga],x121f
        movi    gb,4428h
        lcall   [ga],x14c3
        wid     16,16
        lcall   [ga],x106a
        ljbt    [gc],0,x051f
        ljz     bc,x051b
        lcall   [ga],x117a
        addbi   ga,0fff1h
        movi    ix,0c5h
        jmp     x04c2

x04b2:  movb    [gc].53h,[ga].0ah
        addi    [gc].4fh,2h
        dec     mc
        jz      mc,x04f4
x04c2:  mov     gb,[gc].4fh
        jnzb    [gb],x04cf
        movi    gb,4428h
        mov     [gc].4fh,gb
x04cf:  movb    [gc].40h,[gb]
x04d4:  movi    cc,8008h
        mov     [gc].0cdh,mc
        lcall   [ga].10h,x0ff8
        jnz     bc,x04b2
        decb    [gc].53h
        jnzb    [gc].53h,x04d4
        jnbt    [gc].32h,7,x04fe
        decb    [ga].9h
        jmp     x04b2

x04f4:  jbt     [ga].9h,7,x04fe
        movbi   bc,0ffffh
        jmp     x051b

x04fe:  setb    [gc].2fh,4
        jmp     x0507

x0504:  setb    [gc].2eh,6
x0507:  mov     [gc].34h,[gc].40h
        mov     [gc].35h,[gb]
        mov     [gc].37h,[gb].2h
        movbi   bc,0h
x051b:  ljmp    x00c5

x051f:  movi    ga,4010h
        movbi   ix,0h
        movb    bc,[gc].44h
x0529:  movb    [ga+ix+],[gc].3dh
        movb    [ga+ix+],[gc].3fh
        movb    [ga+ix+],[gb]
        movb    [ga+ix+],[gc].41h
        inc     gb
        dec     bc
        jnz     bc,x0529
        addi    ga,1f4h
        mov     [gc].53h,ix
        lcall   [ga].19h,x1769
        movbi   bc,0dh
        orb     bc,[gc].3bh
        movb    [gb].2h,bc
        movi    mc,0ff90h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].3ch
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].41h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].44h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].46h
        movi    ga,4011h
        add     ga,[gc].53h
        not     ix
        movb    cc,[ga+ix+]
        movb    bc,[ga+ix+]
x0595:  jmcne   [gb],x0595
        movi    mc,0ffd0h
        movb    [gb].2h,[gc].51h
        movi    gc,0c0d2h
x05a6:  ljnbt   [gb],7,x05a6
        movb    [gc],cc
        jmce    [gb],x05b9
x05af:  jnbt    [gb],7,x05af
        movb    [gc],bc
        movb    bc,[ga+ix+]
        jnz     ix,x05af
x05b9:  movi    gc,7f3bh
        lcall   [ga],x0e95
        ljmp    x051b

cmd_write_data:
        lcall   [ga],x1250
        jz      bc,x063b
        lcall   [ga],x1043
        jz      bc,x063b
        lcall   [ga],x121f
        lcall   [ga],x117a
        lcall   [ga],x08c2
        jnzb    [ga].3h,x05e7
        lcall   [ga],x0915
x05e7:  jz      bc,x0638
        mov     [ga].4h,bc
        lpd     gb,[gc].1fh
x05f0:  movi    cc,0c408h
        lcall   [ga],x08fd
        lcall   [ga],x08a1
        movp    [ga],gb
        addbi   ga,4h
        lcall   [ga],x0d43
        addbi   ga,0fffch
        jz      bc,x063b
        addbi   ga,4h
        lcall   [ga],x08c2
        jnzb    [ga].3h,x061a
        lcall   [ga],x0915
x061a:  addbi   ga,0fffch
        jz      bc,x0638
        mov     [ga].4h,bc
        addbi   ga,6h
        lcall   [ga],x1434
        addbi   ga,0fffah
        jz      bc,x063b
        mov     bc,[ga].4h
        movp    gb,[ga]
        jmp     x05f0

x0638:  movbi   bc,0ffffh
x063b:  ljmp    x00c5

cmd_read_data:
        lcall   [ga],x1250
        jz      bc,x069c
        lcall   [ga],x11d4
        lcall   [ga],x08c2
        jz      bc,x0699
        mov     [ga].4h,bc
        lpd     gb,[gc].1fh
        movp    [ga],gb
        addbi   ga,6h
x065c:  lcall   [ga],x0a8f
        addbi   ga,0fffah
        jz      bc,x069c
        movp    gb,[ga]
        mov     bc,[ga].4h
        lcall   [ga],x08fd
        movi    cc,0c008h
        addbi   ga,6h
        lcall   [ga],x08a1
        lcall   [ga],x08c2
        addbi   ga,0fffah
        jz      bc,x0699
        mov     [ga].4h,bc
        movp    [ga],gb
        addbi   ga,6h
        lcall   [ga],x1434
        jnz     bc,x065c
        addbi   ga,0fffah
        jmp     x069c

x0699:  movbi   bc,0ffffh
x069c:  ljmp    x00c5

cmd_read_id:
        lcall   [ga],x1333
        movi    [gc].31h,0ffffh
        movi    [gc].33h,0ffffh
        lcall   [ga],x15b7
        jz      bc,x06e5
        lcall   [ga],x16e2
        jz      bc,x06e5
        lcall   [ga],x0f1b
        jz      bc,x06e5
        movb    [gb].4h,[gb].1h
        andbi   [gb].4h,0fff0h
        andbi   [gb].1h,0fh
        movbi   bc,5h
        movb    [gc].11h,bc
        movi    cc,0c008h
        lpd     gb,[gc].1fh
        lcall   [ga],x08a1
        movbi   bc,0ffffh
x06e5:  ljmp    x00c5

cmd_diag:
        lcall   [ga],x1333
        movb    bc,[gc].1ah
        jz      bc,x0704
        dec     bc
        ljz     bc,x0783
        lcall   [ga],x15b7
        lcall   [ga],x19d3
        jmp     x077f

x0704:  mov     [gc].1bh,cc
        movi    [gc].1dh,100h
        lcall   [ga],x1250
        jz      bc,x077c
        lcall   [ga],x1043
        jz      bc,x077c
        mov     mc,[gc].49h
        or      [gc].3dh,mc
        lcall   [ga],x1347
        jz      bc,x077c
        lcall   [ga],x0f1b
        not     bc,[gb]
        andi    bc,0fffh
        and     bc,[gc].31h
        jz      bc,x074c
        mov     [gc].35h,[gc].0dh
        mov     [gc].37h,[gc].0fh
        setb    [gc].30h,6
        movbi   bc,0h
        jmp     x077c

x074c:  mov     [ga],ix
        movi    gb,4008h
        movi    ix,400h
x0756:  addbi   ix,0fffeh
        movi    [gb+ix],55aah
        jnz     ix,x0756
        mov     ix,[ga]
        lcall   [ga],x121f
        lcall   [ga],x117a
        lcall   [ga],x0d43
        jz      bc,x077c
        lcall   [ga],x11d4
        lcall   [ga],x0a8f
        jnz     bc,x077f
x077c:  setb    [gc].2fh,1
x077f:  ljmp    x00c5

x0783:  call    [ga],x078a
        ljmp    x00c5

x078a:  addbi   ga,4h
        movbi   bc,0ffffh
        movi    gc,1ffeh
        mov     [ga],cc
        mov     [ga].2h,cc
x0799:  addbi   gc,0fffeh
        movb    gb,[gc]
        andi    gb,0ffh
        add     [ga],gb
        movb    gb,[gc].1h
        andi    gb,0ffh
        add     [ga].2h,gb
        jnz     gc,x0799
        movi    gc,1ffeh
        movb    gb,[ga]
        addb    gb,[ga].1h
        not     gb
        andi    gb,0ffh
        andb    gb,[gc]
        jnz     gb,x07d7
        movb    gb,[ga].2h
        addb    gb,[ga].3h
        not     gb
        andi    gb,0ffh
        andb    gb,[gc].1h
        jz      gb,x07e1
x07d7:  movi    gc,7f3bh
        setb    [gc].2eh,4
        movbi   bc,0h
x07e1:  addbi   ga,0fffch
        movi    gc,7f3bh
        mov     tp,[ga]

x07ea:  mov     mc,[ga]
        movi    gc,7f3ch
        movp    gc,[gc]
        movi    ga,7fd4h
        movb    cc,[ga]
        movi    ix,800h
        movbi   ga,0h
        movi    gb,4000h
x0803:  addbi   ix,0fffeh
        mov     [gb+ix],[ga+ix]
        jnz     ix,x0803
        movi    ix,800h
x0811:  addbi   ix,0fffeh
        not     bc,[gb+ix]
        and     bc,[ga+ix]
        jnz     bc,x0849
        jnz     ix,x0811
        movi    ix,800h
x0822:  addbi   ix,0fffeh
        not     [gb+ix]
        jnz     ix,x0822
        movi    ix,800h
x082e:  addbi   ix,0fffeh
        mov     bc,[gb+ix]
        and     bc,[ga+ix]
        jnz     bc,x0849
        jnz     ix,x082e
        movbi   bc,0ffffh
        movi    ga,7f69h
        movi    [ga],0h
        jmp     x0854

x0849:  movbi   bc,0h
        movi    ga,7f69h
        movi    [ga],8h
x0854:  movbi   [ga].2h,0h
        movp    [ga].1fh,gc
        movi    gc,7f3bh
        movp    ga,[gc].4dh
        movp    [gc].1h,ga
        lpd     gb,[pp].4h
        movp    [gc].5h,gb
        movi    ga,7fdch
        movbi   ix,0fff8h
        movb    [ga+ix],cc
        movbi   cc,0h
        andbi   [ga+ix],28h
x087a:  inc     ix
        jz      ix,x0884
        movb    [ga+ix],cc
        jmp     x087a

x0884:  movi    ga,7e00h
        movb    [gc].17h,cc
        mov     [gc].1fh,[gb].12h
        mov     [gc].21h,[gb].14h
        clr     [gc].0h,0
        mov     [gc].3bh,cc
        mov     [ga],mc
        mov     tp,[ga]

x08a1:  wid     16,16
        jbt     [gc].0ch,0,x08b2
        wid     16,8
        mov     [ga].4h,cc
        jnbt    [ga].5h,2,x08b2
        wid     8,16
x08b2:  mov     [gc].9h,ga
        movi    ga,4010h
        xfer    
        nop     
        mov     ga,[gc].9h
        mov     tp,[ga]

x08c2:  movbi   [ga].3h,0ffffh
        not     bc,[gc].42h
        inc     bc
        movbi   mc,0h
        jbt     [gc].24h,7,x08d6
        movi    mc,80h
x08d6:  add     [gc].23h,bc
        not     bc
        inc     bc
        andb    mc,[gc].24h
        jz      mc,x08fb
        jnz     [gc].25h,x08f8
        add     bc,[gc].23h
        jz      bc,x08f0
        incb    [ga].3h
x08f0:  movi    [gc].23h,0h
        jmp     x08fb

x08f8:  dec     [gc].25h
x08fb:  mov     tp,[ga]

x08fd:  movbi   mc,0h
        jnbt    [gc].12h,7,x0906
        inc     mc
x0906:  add     [gc].11h,bc
        jz      mc,x0913
        jbt     [gc].12h,7,x0913
        inc     [gc].13h
x0913:  mov     tp,[ga]

x0915:  mov     [ga].6h,ix
        mov     [ga].8h,[gc].42h
        not     bc
        inc     bc
        add     [ga].8h,bc
        not     bc
        inc     bc
        mov     ix,[ga].8h
        mov     [ga].8h,bc
        movi    gb,4010h
        add     gb,[ga].8h
x0936:  movbi   [gb+ix],0h
        dec     ix
        jnz     ix,x0936
        movbi   [gb],0h
        mov     ix,[ga].6h
        mov     tp,[ga]

cmd_write_buf:
        lcall   [ga],x1250
        jz      bc,x09a5
        lcall   [ga],x1043
        jz      bc,x09a5
        lcall   [ga],x121f
        lcall   [ga],x117a
        lcall   [ga],x08c2
        jnzb    [ga].3h,x0968
        lcall   [ga],x0915
x0968:  jz      bc,x09a1
        mov     [ga],bc
        addbi   ga,2h
x0970:  lcall   [ga],x0d43
        jz      bc,x09a5
        addbi   ga,0fffeh
        mov     bc,[ga]
        lcall   [ga],x08fd
        lcall   [ga],x08c2
        jnzb    [ga].3h,x098c
        lcall   [ga],x0915
x098c:  addbi   ga,0fffeh
        jz      bc,x09a1
        mov     [ga],bc
        addbi   ga,2h
        lcall   [ga],x1434
        jz      bc,x09a5
        jmp     x0970

x09a1:  movi    bc,0ffh
x09a5:  ljmp    x00c5

cmd_read_verify:
        lcall   [ga],x1250
        jz      bc,x09e9
        lcall   [ga],x11d4
        lcall   [ga],x08c2
        jz      bc,x09e6
        mov     [ga],bc
        addbi   ga,2h
x09c0:  lcall   [ga],x0a8f
        jz      bc,x09e9
        addbi   ga,0fffeh
        mov     bc,[ga]
        lcall   [ga],x08fd
        lcall   [ga],x08c2
        jz      bc,x09e6
        mov     [ga],bc
        addbi   ga,2h
        lcall   [ga],x1434
        jz      bc,x09e9
        jmp     x09c0

x09e6:  movbi   bc,0ffffh
x09e9:  ljmp    x00c5

cmd_isbx_exec:
        lpd     gb,[gc].27h
        mov     [ga],gb
        mov     tp,[ga]

cmd_isbx_xfer:
        lcall   [ga],x1333
        mov     [ga],[gc].1bh
        lpd     gb,[gc].1fh
        movp    [ga].2h,gb
        lpd     gb,[gc].23h
        mov     [ga].5h,gb
        mov     bc,[ga].5h
        movb    [ga].5h,[gc].1dh
        wid     16,16
        jnbt    [ga].5h,7,x0a3c
        movi    [ga].6h,4428h
        jbt     [gc].0ch,0,x0a2c
        wid     8,16
        jbt     [ga].5h,1,x0a32
        wid     8,8
        jmp     x0a32

x0a2c:  jbt     [ga].5h,1,x0a32
        wid     16,8
x0a32:  jnbt    [ga].5h,0,x0a39
        setb    [ga].7h,3
x0a39:  jmp     x0a5d

x0a3c:  movi    [ga].6h,8028h
        jbt     [gc].0ch,0,x0a50
        wid     16,8
        jbt     [ga].5h,1,x0a56
        wid     8,8
        jmp     x0a56

x0a50:  jbt     [ga].5h,1,x0a56
        wid     8,16
x0a56:  jnbt    [ga].5h,0,x0a5d
        setb    [ga].7h,3
x0a5d:  mov     cc,[ga].6h
        movp    gb,[ga].2h
        mov     ga,[ga]
        xfer    
        nop     
        jz      bc,x0a82
        not     bc
        inc     bc
        add     bc,[gc].23h
        mov     [gc].11h,bc
x0a76:  movi    [gc].13h,0h
        movbi   bc,0ffffh
        ljmp    x00c5

x0a82:  mov     [gc].11h,[gc].23h
        jmp     x0a76

        db      0ffh,0ffh,0ffh,0ffh

x0a8f:  mov     [ga].3h,ix
        movbi   [gc].0bch,3h
x0a96:  movbi   mc,0h
        ljbt    [gc],0,x0ca5
        mov     [ga].7h,mc
        mov     [ga].9h,mc
        movb    [gc].39h,mc
        wid     16,16
        movi    cc,8028h
        movb    [ga].0dh,mc
x0aaf:  movb    mc,[gc].44h
        addb    mc,[gc].44h
        movb    [ga].0bh,mc
        movbi   [ga].0ch,0h
x0abc:  mov     [gc].0cdh,mc
        lcall   [ga].12h,x0f9e
        ljnz    bc,x0b08
        jnz     [gb].4h,x0ad0
        jz      [gb].6h,x0ad6
x0ad0:  incb    [ga].0ch
        jmp     x0af6

x0ad6:  jnzb    [ga].0dh,x0af6
        incb    [ga].0dh
        not     bc,[gc].3dh
        inc     bc
        add     bc,[gb]
        jnz     bc,x0b14
        notb    bc,[gc].3fh
        inc     bc
        addb    bc,[gb].2h
        jz      bc,x0abc
        ljmp    x0df8

x0af6:  decb    [ga].0bh
        jnzb    [ga].0bh,x0abc
        jnzb    [ga].0ch,x0b7a
        setb    [gc].2fh,4
        ljmp    x0dad

x0b08:  lcall   [ga].0fh,x0c35
        ljz     bc,x0e1a
        jmp     x0aaf

x0b14:  andi    bc,0fffh
        jz      bc,x0b3f
        mov     mc,[gc].3dh
        andi    mc,0fffh
        setb    [gc].30h,6
        addbi   ga,12h
        lcall   [ga],x1364
        addbi   ga,0ffeeh
        decb    [gc].0bch
        ljzb    [gc].0bch,x0df8
        ljnz    bc,x0a96
        ljmp    x0df8

x0b3f:  jbt     [gb].1h,7,x0b68
x0b43:  movb    bc,[gc].3eh
        movb    [ga].2h,[gb].1h
        andbi   bc,40h
        andbi   [ga].2h,40h
        addb    [ga].2h,bc
        jnbt    [ga].2h,6,x0b61
        setb    [gc].2eh,6
        ljmp    x0dad

x0b61:  setb    [gc].2fh,0
        ljmp    x0dad

x0b68:  addbi   ga,12h
        lcall   [ga],x139b
        addbi   ga,0ffeeh
        ljnz    bc,x0a96
        ljmp    x0dad

x0b7a:  movbi   [ga].0ch,0h
x0b7e:  movbi   [ga].0bh,0h
        movbi   mc,0ffffh
        movb    [ga].0dh,[gc].44h
        movbi   [gc].39h,0h
        lcall   [ga].12h,x0c8b
x0b94:  mov     [gc].0cdh,mc
        lcall   [ga].12h,x0f9e
        jnz     bc,x0c0f
        jnz     [gb].4h,x0ba7
        jz      [gb].6h,x0bb4
x0ba7:  notb    bc,[ga].0bh
        addb    bc,[ga].0ch
        andi    bc,8000h
        jnz     bc,x0bc8
x0bb4:  incb    [ga].0bh
        decb    [ga].0dh
        jnzb    [ga].0dh,x0b94
        setb    [gc].2fh,4
        setb    [gc].30h,4
        ljmp    x0dad

x0bc8:  movb    [ga].0ch,[ga].0bh
        lcall   [ga].12h,x0c8b
x0bd3:  jzb     [ga].0ch,x0be5
        movbi   mc,0ffffh
        lcall   [ga].12h,x0f9e
        decb    [ga].0ch
        jmp     x0bd3

x0be5:  movbi   mc,0h
        lcall   [ga].12h,x0f9e
        addbi   ga,12h
        lcall   [ga],x1ae4
        jz      bc,x0c1e
        addbi   ga,0ffeeh
        not     bc,[gc].3dh
        inc     bc
        add     bc,[gb]
        jnz     bc,x0c28
        not     bc,[gc].3fh
        inc     bc
        add     bc,[gb].2h
        jnz     bc,x0c28
x0c0f:  setb    [gc].30h,4
        lcall   [ga].0fh,x0c35
        jnz     bc,x0bc8
        ljmp    x0e20

x0c1e:  lcall   [ga],x1239
        addbi   ga,0ffeeh
        jnz     bc,x0bc8
x0c28:  movb    [ga].0ch,[ga].0bh
        incb    [ga].0ch
        ljmp    x0b7e

x0c35:  add     gb,[gc].42h
        addbi   gb,8h
        movbi   bc,0h
        jnz     [gb],x0c45
        jz      [gb].2h,x0c88
x0c45:  setb    [gc].30h,3
        not     bc,[ga].7h
        inc     bc
        add     bc,[gb]
        jnz     bc,x0c6b
        not     bc,[ga].9h
        inc     bc
        add     bc,[gb].2h
        jnz     bc,x0c6b
        addbi   ga,12h
        lcall   [ga],x1aee
        addbi   ga,0ffeeh
        ljnz    bc,x0e20
x0c6b:  mov     [ga].7h,[gb]
        mov     [ga].9h,[gb].2h
        movi    gb,4008h
        addbi   ga,12h
        lcall   [ga],x1239
        addbi   ga,0ffeeh
        ljz     bc,x0dad
x0c88:  mov     tp,[ga].0fh

x0c8b:  movi    bc,2260h
        mov     [gc].0cdh,bc
x0c92:  dec     bc
        jz      bc,x0c9e
        jnbt    [gc].0c6h,7,x0c92
        mov     tp,[ga].12h

x0c9e:  setb    [gc].2fh,2
        ljmp    x0dad

x0ca5:  addbi   ga,7h
        lcall   [ga].19h,x1769
        movbi   bc,6h
        jnbt    [gc].19h,2,x0cb7
        movbi   bc,0ch
x0cb7:  lcall   [ga],x0cfa
        movi    ga,4010h
        add     ga,[gc].42h
        inc     ix
        movb    [gb].2h,[gc].4dh
        movi    gc,0c0d2h
x0cce:  jnbt    [gb],7,x0cce
        jmce    [gb],x0ce4
x0cd4:  movb    [ga+ix+],[gc]
        jz      ix,x0ce4
x0cdb:  jbt     [gb],7,x0cd4
        jbt     [gb],7,x0cd4
        jmp     x0cdb

x0ce4:  movi    gc,7f3bh
        movbi   [gc].0ddh,2h
        mov     ga,[gc].4bh
        lcall   [ga],x0e95
        addbi   ga,0fff9h
        ljmp    x0db0

x0cfa:  orb     bc,[gc].3bh
        movb    [gb].2h,bc
        movi    mc,0ff90h
        movi    [ga].3h,702h
x0d09:  movb    ix,[gc].3ch
        decb    [ga].4h
        inc     gc
        decb    [ga].3h
        jnzb    [ga].3h,x0d1a
        inc     gc
x0d1a:  jmcne   [gb],x0d1a
        movb    [gb].2h,ix
        jnzb    [ga].4h,x0d09
        movi    gc,7f3bh
        mov     [gc].4bh,ga
        movbi   [gc].4dh,0ffffh
        not     ix,[gc].42h
        jnzb    [gc].41h,x0d3a
        movbi   [gc].4dh,0ff80h
x0d3a:  jmcne   [gb],x0d3a
        movi    mc,0ffd0h
        mov     tp,[ga]

x0d43:  mov     [ga].3h,ix
        ljbt    [gc],0,x0e26
        wid     16,16
        movbi   [gc].0bch,3h
x0d50:  movi    ix,0c5h
        movb    mc,[gc].44h
        addb    mc,[gc].44h
        movb    [ga].7h,mc
        movi    [ga].8h,0h
x0d62:  mov     [gc].0cdh,mc
        movi    cc,8008h
        lcall   [ga].10h,x0ff8
        ljnz    bc,x0e1a
        jnz     [gb].4h,x0d7a
        jz      [gb].6h,x0d80
x0d7a:  incb    [ga].8h
        jmp     x0d9c

x0d80:  jnzb    [ga].9h,x0d9c
        incb    [ga].9h
        not     bc,[gc].3dh
        inc     bc
        add     bc,[gb]
        jnz     bc,x0dc4
        notb    bc,[gc].3fh
        inc     bc
        addb    bc,[gb].2h
        jnz     bc,x0df8
x0d9c:  decb    [ga].7h
        jnzb    [ga].7h,x0d62
        setb    [gc].2fh,4
        jzb     [ga].8h,x0dad
        setb    [gc].30h,4
x0dad:  movbi   bc,0h
x0db0:  movi    gb,4008h
        mov     [gc].35h,[gb]
        mov     [gc].37h,[gb].2h
        mov     ix,[ga].3h
        mov     tp,[ga]

x0dc4:  andi    bc,0fffh
        jz      bc,x0df0
        mov     mc,[gc].3dh
        andi    mc,0fffh
        mov     ix,[ga].3h
        setb    [gc].30h,6
        addbi   ga,10h
        lcall   [ga],x1364
        addbi   ga,0fff0h
        decb    [gc].0bch
        jzb     [gc].0bch,x0df8
        ljnz    bc,x0d50
        jmp     x0df8

x0df0:  jbt     [gb].1h,7,x0dfe
        ljmp    x0b43

x0df8:  setb    [gc].30h,6
        jmp     x0dad

x0dfe:  mov     ix,[ga].3h
        addbi   ga,10h
        lcall   [ga],x11d4
        lcall   [ga],x139b
        lcall   [ga],x117a
        addbi   ga,0fff0h
        ljnz    bc,x0d50
        jmp     x0dad

x0e1a:  movbi   bc,0ffffh
        jmp     x0db0

x0e20:  movbi   bc,0ffffh
        jmp     x0db0

x0e26:  addbi   ga,7h
        lcall   [ga].19h,x1769
        movbi   bc,5h
        jnbt    [gc].19h,2,x0e38
        movbi   bc,9h
x0e38:  lcall   [ga],x0cfa
        movi    ga,4011h
        add     ga,[gc].42h
        movb    cc,[ga+ix+]
        movb    bc,[ga+ix+]
        jmp     x0e4a

x0e4a:  movb    [gb].2h,[gc].4dh
        movi    gc,0c0d2h
x0e54:  ljnbt   [gb],7,x0e54
        movb    [gc],cc
        jmce    [gb],x0e67
x0e5d:  jnbt    [gb],7,x0e5d
        movb    [gc],bc
        movb    bc,[ga+ix+]
        jnz     ix,x0e5d
x0e67:  movi    gc,7f3bh
        movbi   [gc].0ddh,2h
        mov     ga,[gc].4bh
        lcall   [ga],x0e95
        addbi   ga,0fff9h
        ljmp    x0db0

x0e7d:  movbi   cc,0h
x0e80:  jmcne   [gb],x0e86
        mov     tp,[ga].0fh

x0e86:  dec     cc
        jnz     cc,x0e80
        setb    [gc].30h,5
        lcall   [ga].19h,x1769
        mov     tp,[ga]

x0e95:  mov     [ga].0ah,ix
        movbi   [gc].0ddh,0h
        movbi   bc,7h
        movbi   ix,2h
x0ea2:  call    [ga].0fh,x0e7d
        movb    [ga+ix+],[gb].2h
        dec     bc
        jnz     bc,x0ea2
        dec     bc
        movb    ix,[ga].8h
        movi    gb,1ff9h
        movb    [ga].9h,[gb+ix]
        movi    gb,4008h
        movb    [gb].1h,[ga].9h
        movb    [gb],[ga].5h
        mov     [gb].2h,[ga].6h
        jbt     [ga].2h,7,x0edf
        jbt     [ga].2h,6,x0edf
        jnbt    [ga].3h,0,x0ee2
x0edf:  setb    [gc].30h,5
x0ee2:  jnbt    [ga].3h,2,x0ee9
        setb    [gc].2fh,4
x0ee9:  jnbt    [ga].3h,5,x0ef0
        setb    [gc].30h,4
x0ef0:  jnbt    [ga].4h,5,x0ef7
        setb    [gc].30h,3
x0ef7:  jnbt    [ga].4h,4,x0efe
        setb    [gc].30h,6
x0efe:  notb    mc,[ga].8h
        inc     mc
        addb    mc,[gc].41h
        jz      mc,x0f0c
        setb    [gc].2fh,0
x0f0c:  mov     ix,[ga].0ah
        jnz     [gc].2eh,x0f17
        jzb     [gc].30h,x0f19
x0f17:  inc     bc
x0f19:  mov     tp,[ga]

x0f1b:  addbi   ga,4h
        lcall   [ga],x11d4
        jbt     [gc],0,x0f5e
        wid     16,16
        movi    cc,8028h
        movbi   mc,0h
x0f2e:  lcall   [ga].12h,x0f9e
        jnz     [gb].4h,x0f4f
        jnz     [gb].6h,x0f4f
        mov     [gb].8h,[gb]
        mov     [gb].0ah,[gb].2h
        addbi   gb,8h
        movbi   bc,0ffffh
        jmp     x0f59

x0f4f:  lcall   [ga],x1239
        setb    [gc].30h,4
        jnz     bc,x0f2e
x0f59:  addbi   ga,0fffch
        mov     tp,[ga]

x0f5e:  movi    gb,7fd8h
        jnbt    [gb+ix],6,x0f68
        setb    [gc].3bh,6
x0f68:  lcall   [ga].19h,x1769
        movbi   bc,0ah
        orb     bc,[gc].3bh
        movb    [gb].2h,bc
        movi    mc,0ff90h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].3ch
        movi    mc,0ffd0h
        lcall   [ga],x0e95
        mov     [gb].8h,[gb]
        mov     [gb].0ah,[gb].2h
        addbi   gb,8h
        jmp     x0f59

x0f9e:  movi    gb,4008h
x0fa2:  mov     [gc].0f5h,[gc].3dh
        mov     [gc].0fdh,[gc].3fh
        mov     [gc].4bh,ga
        movbi   bc,8h
        movi    ga,8028h
        jbt     [gc].0cdh,5,x0fc2
        mov     [gc].0c7h,[gc].57h
x0fc2:  movbi   [gc].0c5h,6h
        xfer    
        jz      mc,x0fe7
        nop     
        tsl     [gc].0c5h,2h,x0fdd
        movi    bc,410h
        xfer    
        nop     
x0fda:  movbi   bc,0ffffh
x0fdd:  mov     ga,[gc].4bh
        movi    gb,4008h
        mov     tp,[ga].12h

x0fe7:  inc     bc
        movbi   [gc].0c5h,2h
        movi    bc,410h
        xfer    
        nop     
        jmp     x0fda

x0ff8:  movi    gb,4008h
        mov     [gc].0f5h,[gc].3dh
        mov     [gc].0fdh,[gc].3fh
        movbi   bc,8h
        mov     [gc].4bh,ga
        movi    ga,8028h
        jbt     [gc].0cdh,5,x101c
        mov     [gc].0c7h,[gc].57h
x101c:  movi    [gc].0edh,19h
        movi    [gc].0c5h,6h
        xfer    
        nop     
        tsl     [gc+ix],1h,x1039
        movi    cc,4428h
        xfer    
        nop     
        movbi   bc,0ffffh
x1039:  mov     ga,[gc].4bh
        movi    gb,4008h
        mov     tp,[ga].10h

x1043:  addbi   ga,3h
        movbi   bc,0ffffh
        jbt     [gc],0,x1063
        jbt     [gc].0cdh,5,x105e
        lcall   [ga],x17fa
x1054:  jnbt    [gc].0bdh,6,x105e
        setb    [gc].2fh,7
        movbi   bc,0h
x105e:  addbi   ga,0fffdh
        mov     tp,[ga]

x1063:  lcall   [ga],x16e2
        jmp     x1054

x106a:  mov     [gc].4bh,ga
        ljbt    [gc],0,x114e
        mov     [gc].4dh,gb
        lcall   [ga].0fh,x1200
        movbi   [gc].0ebh,3ah
        movi    gb,441ah
        mov     [gb],[gc].3dh
        movb    [gb].2h,[gc].3fh
        movb    [gb].3h,cc
        mov     [gb].4h,cc
        movbi   [gc].0e9h,2h
        movb    [gc].0e9h,cc
        addi    [ga].19h,19h
        movb    [gc].0e5h,[ga].19h
        movb    [gc].0e5h,[ga].1ah
        movbi   [gc].0e7h,7h
        movb    [gc].0e7h,cc
        jbt     [gc].0cdh,5,x10c8
        movb    [gc].0e5h,cc
        movb    [gc].0e5h,cc
        movbi   [gc].0e7h,5h
        movb    [gc].0e7h,cc
        mov     [gc].0c7h,[gc].57h
x10c8:  lcall   [ga].12h,x0c8b
        jz      bc,x1143
        movi    cc,4428h
        movi    [gc].0edh,19h
        orbi    [gc].55h,0ffc0h
        movb    [gc].0ddh,[gc].55h
        movbi   [gc].0c5h,1h
        movbi   bc,6h
        jnbt    [gc].0cdh,5,x10f5
        mov     [gc].0cdh,mc
x10f1:  jnbt    [gc].0c6h,7,x10f1
x10f5:  movi    ga,8028h
        movi    gb,441ah
        jnbt    [gc].0cdh,5,x1104
        mov     [gc].0f5h,mc
x1104:  xfer    
        nop     
        inc     [gc].4dh
        mov     gb,[gc].4dh
        movb    ix,[gb]
        jz      ix,x1129
        movi    gb,441ah
        movb    [gb].3h,ix
        movbi   bc,6h
        movi    [gc].0edh,19h
        movbi   [gc].0c5h,1h
        jmp     x1104

x1129:  clr     [gc].55h,6
        jnbt    [gc].0cdh,5,x1136
        movb    [gc].0ddh,[gc].55h
x1136:  clr     [gc].55h,7
        movbi   bc,0ffffh
        mov     [gc].0cdh,mc
x113f:  jnbt    [gc].0c6h,7,x113f
x1143:  movb    [gc].0ddh,[gc].55h
x1149:  mov     ga,[gc].4bh
        mov     tp,[ga]

x114e:  movi    ga,x116a
        movb    ix,[gc].41h
        jnbt    [gc],1,x115b
        addbi   ga,8h
x115b:  jnbt    [gc].3bh,6,x1162
        addbi   ga,4h
x1162:  movb    [gc].46h,[ga+ix]
        jmp     x1149

x116a:  db      01bh,02ah,03ah,000h
	db	000h,036h,054h,074h
        db      018h,026h,087h,0ffh
        db      000h,032h,070h,0f0h

x117a:  mov     [ga].3h,ix
        jbt     [gc],0,x11a8
        lcall   [ga].0fh,x1200
        movbi   [gc].0ebh,32h
        movbi   [gc].0e5h,1h
        movb    [gc].0e5h,cc
        movb    [gc].0e9h,[ga].19h
        movb    [gc].0e9h,[ga].1ah
        movbi   [gc].0e7h,0eh
        movb    [gc].0e7h,cc
x11a3:  mov     ix,[ga].3h
        mov     tp,[ga]

x11a8:  movi    gb,11c4h
        movb    ix,[gc].41h
        jnbt    [gc],1,x11b5
        addbi   gb,8h
x11b5:  jnbt    [gc].3bh,6,x11bc
        addbi   gb,4h
x11bc:  movb    [gc].46h,[gb+ix]
        jmp     x11a3

x11c4:  db      007h,00eh,01bh,000h
	db	000h,00fh,01bh,035h
        db      010h,012h,046h,0c8h
        db      000h,020h,033h,080h

x11d4:	mov	[ga].03h,ix
        jbt     [gc],0,x11a8
        lcall   [ga].0fh,x1200
        movbi   [gc].0ebh,32h
        movbi   [gc].0e5h,1h
        movb    [gc].0e5h,cc
        addi    [ga].19h,0fffeh
        movb    [gc].0e9h,[ga].19h
        movb    [gc].0e9h,[ga].1ah
        mov     ix,[ga].3h
        mov     tp,[ga]

x1200:  movb    ix,[gc].43h
        addb    ix,[gc].43h
        movi    gb,1215h
        mov     [ga].19h,[gb+ix]
        movbi   cc,0h
        mov     tp,[ga].0fh

x1215:	dw	0040h,0080h,0100h,0000h,0200h

x121f:	mov	[ga].5h,ix
        movbi   cc,0h
        mov     ix,[gc].42h
        movi    gb,4010h
        mov     [gb+ix+],cc
        mov     [gb+ix+],cc
        mov     [gb+ix+],cc
        mov     [gb+ix+],cc
        mov     ix,[ga].5h
        mov     tp,[ga]

x1239:  movbi   bc,0h
        jbt     [gc].19h,1,x124c
        movbi   bc,0fffdh
        addb    bc,[gc].39h
        jz      bc,x124c
        incb    [gc].39h
x124c:  mov     tp,[ga]

        db      0ffh,0ffh

x1250:  addbi   ga,6h
        lcall   [ga],x1333
        mov     [gc].31h,[gc].1bh
        mov     [gc].33h,[gc].1dh
        andi    [gc].31h,0fffh
        lcall   [ga],x158d
        lcall   [ga],x1530
        jnz     bc,x127d
        lcall   [ga],x19d3
        movbi   bc,0h
        jmp     x128b

x127d:  lcall   [ga],x1539
        jz      bc,x128b
        lcall   [ga],x1566
        jnz     bc,x1292
x128b:  setb    [gc].2fh,5
        ljmp    x132e

x1292:  movi    gb,7fd4h
        movb    [gc].0bah,ix
        jnbt    [gc],0,x12af
        addbi   gb,4h
        movb    [gc].3bh,[gb+ix]
        andbi   [gc].3bh,40h
        jnbt    [gc].19h,2,x12af
        setb    [gc].3bh,5
x12af:  jnbt    [gb+ix],2,x12bc
        setb    [gc].2eh,5
        movbi   bc,0h
        ljmp    x132e

x12bc:  lcall   [ga],x15b7
        movb    mc,[gc].33h
        lcall   [ga],x1646
        mov     mc,[gc].31h
        lcall   [ga],x1347
        jz      bc,x132e
        lcall   [ga],x158d
        mov     [gc].42h,[gb].5h
        movb    [gc].44h,[gb].4h
        notb    mc,[gb].7h
        inc     mc
        add     mc,[gb].0h
        mov     [gc].47h,mc
        mov     [gc].49h,[gb].0h
        movi    gb,7fd4h
        jnbt    [gc],0,x130f
        addbi   gb,4h
        mov     [gc].47h,[gc].49h
        movb    [gc].41h,[gc].43h
        jnbt    [gc].43h,2,x130f
        decb    [gc].41h
x130f:  dec     [gc].49h
        mov     [gc].3dh,[gc].31h
        mov     [gc].3fh,[gc].33h
        movb    [ga],[gc].43h
        movi    gb,1ff9h
        addb    gb,[ga]
        movb    mc,[gb]
        orb     [gc].3eh,mc
x132e:  addbi   ga,0fffah
        mov     tp,[ga]

x1333:  movbi   cc,0h
        mov     [gc].11h,cc
        mov     [gc].13h,cc
        mov     [gc].2eh,cc
        movb    [gc].30h,cc
        mov     [gc].39h,cc
        mov     tp,[ga]

x1347:  movbi   [gc].0b9h,0h
x134b:  addbi   ga,8h
        lcall   [ga],x18ba
        jz      bc,x135c
        lcall   [ga],x1a80
        jnz     bc,x135f
x135c:  call    [ga],x1364
x135f:  addbi   ga,0fff8h
        mov     tp,[ga]

x1364:  addbi   ga,8h
        lcall   [ga].0fh,x15aa
        jbt     [gb+ix],3,x138f
        movbi   cc,3h
x1372:  incb    [gc].3ah
        lcall   [ga],x19d3
        jz      bc,x138a
        lcall   [ga],x18ba
        jz      bc,x138a
        lcall   [ga],x1a80
        jnz     bc,x1396
x138a:  dec     cc
        jnz     cc,x1372
x138f:  lcall   [ga],x19d3
        movbi   bc,0h
x1396:  addbi   ga,0fff8h
        mov     tp,[ga]

x139b:  mov     [ga].8h,ix
        addbi   ga,0ah
        ljnzb   [gc].0b9h,x1420
        movi    cc,8028h
        movb    [ga].2h,[gc].44h
        incb    [ga].2h
        mov     bc,[gc].42h
        addbi   bc,0ch
        not     bc
        inc     bc
        addi    bc,4008h
        mov     [ga],bc
        movbi   mc,0h
x13c6:  decb    [ga].2h
        jzb     [ga].2h,x1426
        mov     gb,[ga]
        lcall   [ga].12h,x0fa2
        movi    gb,4000h
        jnz     [gb].4h,x13c6
        jnz     [gb].6h,x13c6
        movb    ix,[gc].0bah
        movi    mc,0f000h
        and     mc,[gc].3dh
        andi    [gb],0fffh
        or      mc,[gb]
        mov     [gc].3dh,mc
        movb    [gc].3fh,[gb].2h
        setb    [gc].3eh,6
        not     mc,[gc].49h
        add     [gb],mc
        jnbt    [gb].1h,7,x141d
        movbi   [gc].0b9h,0ffffh
        movb    mc,[gc].3fh
        lcall   [ga],x1646
        jz      bc,x142c
        mov     mc,[gc].3dh
        lcall   [ga],x134b
        jmp     x142c

x141d:  setb    [gc].2fh,5
x1420:  setb    [gc].2eh,6
        jmp     x1429

x1426:  setb    [gc].2fh,4
x1429:  movbi   bc,0h
x142c:  addbi   ga,0fff6h
        mov     ix,[ga].8h
        mov     tp,[ga]

x1434:  addbi   ga,0ah
        lcall   [ga],x158d
        incb    [gc].34h
        incb    [gc].40h
        lcall   [ga],x1566
        ljnz    bc,x14be
        movbi   [gc].34h,0h
        movbi   [gc].40h,0h
        jnbt    [gc],0,x145a
        incb    [gc].34h
        incb    [gc].40h
x145a:  mov     [gc].4dh,gb
        jzb     [gc].0b9h,x1479
        mov     mc,[gc].31h
        lcall   [ga],x1347
        jz      bc,x14be
        andi    [gc].3dh,3000h
        or      [gc].3dh,mc
        movb    [gc].3fh,[gc].33h
x1479:  incb    [gc].33h
        incb    [gc].3fh
        mov     gb,[gc].4dh
        lcall   [ga],x1539
        jz      bc,x1490
        lcall   [ga],x1646
        jmp     x14be

x1490:  movbi   mc,0h
        movb    [gc].33h,mc
        movb    [gc].3fh,mc
        lcall   [ga],x1646
        inc     [gc].31h
        inc     [gc].3dh
        mov     mc,[gc].31h
        not     mc
        and     mc,[gc].47h
        jnz     mc,x14b7
        setb    [gc].2eh,7
        movbi   bc,0h
        jmp     x14be

x14b7:  mov     mc,[gc].31h
        lcall   [ga],x134b
x14be:  addbi   ga,0fff6h
        mov     tp,[ga]

x14c3:  movb    [ga].3h,[gc].44h
        notb    [ga].3h
        incb    [ga].3h
        movb    [ga].5h,[ga].3h
        incb    [ga].5h
        movb    [ga].6h,[ga].3h
        movb    [ga].4h,ix
        movbi   ix,0h
x14e4:  movb    [gb+ix+],cc
        incb    [ga].6h
        jnzb    [ga].6h,x14e4
        movbi   bc,1h
        incb    [gb]
        movbi   ix,0h
x14f5:  addb    ix,[ga].4h
x14f8:  movb    [ga].6h,[ga].3h
        addb    [ga].6h,ix
        jbt     [ga].6h,7,x1508
        movb    ix,[ga].6h
x1508:  jzb     [gb+ix],x1510
        inc     ix
        jmp     x14f8

x1510:  movb    [gb+ix],bc
        inc     bc
        jnbt    [gc],0,x1519
        movb    [gb+ix],bc
x1519:  incb    [ga].5h
        jnzb    [ga].5h,x14f5
        movb    [gb],cc
        jnbt    [gc],0,x1527
        incb    [gb]
x1527:  movb    ix,[gc].44h
        mov     [gb+ix+],cc
        movb    [gb+ix],cc
        mov     tp,[ga]

x1530:  mov     mc,[gc].31h
        not     bc,[gb].0h
        jmp     x1575

x1539:  movb    mc,[gc].33h
        mov     [gc].9h,ga
        jbt     [gc],0,x155d
        movi    ga,7fd4h
        addb    ga,[gc].0bah
        jnbt    [ga],7,x1553
        jbt     [gc].17h,4,x155d
        jmp     x1557

x1553:  jzb     [gb].2h,x155d
x1557:  notb    bc,[gb].2h
        jmp     x1560

x155d:  notb    bc,[gb].3h
x1560:  mov     ga,[gc].9h
        jmp     x1575

x1566:  movb    mc,[gc].34h
        notb    bc,[gb].4h
        jnbt    [gc],0,x1575
        jz      mc,x1588
        jmp     x1577

x1575:  inc     bc
x1577:  mov     [ga].4h,mc
        jbt     [ga].5h,7,x1588
        add     [ga].4h,bc
        movbi   bc,0ffffh
        jbt     [ga].5h,7,x158b
x1588:  movbi   bc,0h
x158b:  mov     tp,[ga]

x158d:  movi    gb,7f94h
        jnbt    [gc],0,x1597
        addbi   gb,20h
x1597:  movb    [ga].3h,ix
x159a:  jz      ix,x15a5
        addbi   gb,8h
        dec     ix
        jmp     x159a

x15a5:  movb    ix,[ga].3h
        mov     tp,[ga]

x15aa:  movi    gb,7fd4h
        jnbt    [gc],0,x15b4
        addbi   gb,4h
x15b4:  mov     tp,[ga].0fh

x15b7:  jbt     [gc],0,x15cd
        movi    gb,x15de
        movb    [gc].0ddh,[gb+ix]
        movb    [gc].55h,[gb+ix]
x15c8:  movbi   bc,0ffffh
x15cb:  mov     tp,[ga]

x15cd:  movbi   bc,0h
        jbt     [gc].0cdh,0,x15cb
        andbi   [gc].3ch,4h
        orb     [gc].3ch,ix
        jmp     x15c8

x15de:  db      00h,08h,10h,18h

x15e2:  jbt     [gc],0,x1618
        jz      [gb],x1618
        addbi   ga,7h
        lcall   [ga],x15b7
        jnbt    [gc].0cdh,5,x161d
        movi    [gc].0d5h,0fah
        lcall   [ga],x168a
        movbi   [ga],0ff8ch
x15ff:  jbt     [gc].0c5h,1,x1607
        jnbt    [gc].0c5h,2,x1615
x1607:  dec     bc
        jnz     bc,x15ff
        decb    [ga]
        jnzb    [ga],x15ff
        lcall   [ga],x16e2
x1615:  addbi   ga,0fff9h
x1618:  mov     gb,[gc].53h
        mov     tp,[ga]

x161d:  movi    [gc].0d5h,0feh
        lcall   [ga],x16b7
        movbi   mc,12h
x1629:  lcall   [ga],x17fa
        addbi   [ga].2h,0fff5h
        jzb     [ga].2h,x1615
        dec     bc
        jnz     bc,x1629
        dec     mc
        jnz     mc,x1629
        lcall   [ga],x16e2
        jmp     x1615

x1646:  addbi   ga,5h
        mov     [ga],mc
        jbt     [gc],0,x167e
        jnbt    [gc].0cdh,5,x1664
        setb    [ga],7
        notb    [ga]
        mov     [gc].0d5h,[ga]
        lcall   [ga],x168a
x165f:  addbi   ga,0fffbh
        mov     tp,[ga]

x1664:  movi    [gc].57h,1c0h
        jnbt    [ga],0,x166f
        setb    [gc].57h,5
x166f:  jnbt    [ga],1,x1675
        setb    [gc].57h,4
x1675:  jnbt    [ga],2,x167b
        setb    [gc].58h,2
x167b:  jmp     x165f

x167e:  clr     [gc].3ch,2
        jnbt    [ga],0,x165f
        setb    [gc].3ch,2
        jmp     x165f

x168a:  addbi   ga,5h
        lcall   [ga],x17a7
        addbi   ga,0fffbh
        jz      bc,x16b0
        movi    [gc].0c7h,68h
        movi    [gc].0c7h,268h
        movbi   bc,0h
x16a4:  jbt     [gc].0c5h,5,x16b0
        dec     bc
        jnz     bc,x16a4
        setb    [gc].30h,5
x16b0:  movi    [gc].0c7h,60h
        mov     tp,[ga]

x16b7:  addbi   ga,5h
        lcall   [ga],x17e0
        movi    [gc].0c7h,1c8h
        setb    [gc].55h,0
        movb    [gc].0ddh,[gc].55h
        clr     [gc].55h,0
        movb    [gc].0ddh,[gc].55h
        movi    [gc].0c7h,1c0h
        movbi   bc,0ffffh
        addbi   ga,0fffbh
        mov     tp,[ga]

x16e2:  addbi   ga,14h
        movbi   bc,0ffffh
        jbt     [gc],0,x1735
        movbi   [gc].51h,0h
        jnbt    [gc].0cdh,5,x170d
        lcall   [ga],x17a7
x16f7:  jnbt    [gc].0c5h,1,x1701
x16fb:  setb    [gc].2fh,6
        incb    [gc].51h
x1701:  jzb     [gc].51h,x1708
        movbi   bc,0h
x1708:  addbi   ga,0ffech
        mov     tp,[ga]

x170d:  lcall   [ga],x17e0
        jz      bc,x16fb
        andbi   [ga].5h,0ffa4h
        jzb     [ga].5h,x16f7
        setb    [gc].30h,5
        movi    [gc].0d5h,0fah
        lcall   [ga],x16b7
        lcall   [ga],x17e0
        jz      bc,x16fb
        incb    [gc].51h
        jmp     x16f7

x1735:  lcall   [ga].19h,x1769
        movbi   [gb].2h,4h
        movi    mc,0f090h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].3ch
        movi    mc,0f0d0h
        lcall   [ga].19h,x1796
        movb    [ga].2h,[gb].2h
        movb    [gc].0bdh,[ga].2h
        jbt     [ga].2h,5,x1708
        jmp     x16fb

x1769:  movi    gb,0c0d0h
        movbi   [ga].18h,7fh
        movi    mc,0f080h
        jnbt    [gb],4,x1790
        movbi   [gc].0ddh,2h
        movbi   [gc].0ddh,0h
x1780:  decb    [ga].18h
        jmce    [gb],x1790
        jnzb    [ga].18h,x1780
        movb    [ga].1bh,[gb].2h
x1790:  jmcne   [gb],x1780
        mov     tp,[ga].19h

x1796:  movbi   [gc].0bch,3h
x179a:  decb    [gc].0bch
        jnzb    [gc].0bch,x179a
x17a1:  jmcne   [gb],x17a1
        mov     tp,[ga].19h

x17a7:  mov     [ga].3h,gb
        movbi   bc,0ffffh
        jbt     [gc].0c6h,6,x17db
        notb    gb,[gc].0d5h
        movi    [gc].0c7h,20h
x17b9:  jbt     [gc].0c6h,6,x17c5
        dec     bc
        jnz     bc,x17b9
        jmp     x17cd

x17c5:  movi    [gc].0c7h,60h
        jz      gb,x17db
x17cd:  incb    [gc].51h
        movi    [gc].0c7h,60h
        setb    [gc].30h,5
        movbi   bc,0h
x17db:  mov     gb,[ga].3h
        mov     tp,[ga]

x17e0:  addbi   ga,3h
        movbi   bc,0ffffh
x17e6:  call    [ga],x17fa
        jnbt    [ga].2h,4,x17f5
        dec     bc
        jnz     bc,x17e6
        setb    [gc].30h,5
x17f5:  addbi   ga,0fffdh
        mov     tp,[ga]

x17fa:  movi    [gc].0c7h,3c0h
        movb    [ga].2h,[gc].0d5h
        movi    [gc].0c7h,1c0h
        notb    [ga].2h
        movb    [gc].0bdh,[ga].2h
        clr     [ga].2h,6
        mov     tp,[ga]

x1818:  mov     [ga].11h,ix
        lcall   [ga].19h,x1769
        movbi   ix,3h
        movbi   bc,0ffffh
        movbi   [ga].0fh,0h
x182a:  movi    mc,0f080h
        lcall   [ga].19h,x1796
        movbi   [gb].2h,8h
        movi    mc,0c0c0h
        lcall   [ga].19h,x1796
        movb    [ga+ix],[gb].2h
        movb    [ga].10h,[ga+ix]
        andbi   [ga].10h,0ffc0h
        incb    [ga].0fh
        jzb     [ga].10h,x1870
        orbi    [ga].10h,3fh
        incb    [ga].10h
        jzb     [ga].10h,x18b5
        decb    [ga].0fh
        jnzb    [ga].0fh,x1887
        movbi   bc,0h
        setb    [gc].30h,5
        jmp     x1887

x1870:  jbt     [ga+ix+],5,x1879
        setb    [gc].30h,7
        movbi   bc,0h
x1879:  jnbt    [gb],6,x1887
        movb    [ga+ix+],[gb].2h
        movbi   [ga+ix+],0ffffh
        jmp     x182a

x1887:  movi    [ga+ix+],0h
        jnbt    [gb],6,x1891
        movb    mc,[gb].2h
x1891:  jzb     [ga].10h,x182a
        jz      bc,x18b0
        movbi   [ga].2h,0h
        movbi   ix,3h
x189f:  jzb     [ga+ix],x18b0
        addbi   ix,2h
        jzb     [ga+ix+],x189f
        incb    [ga].2h
        addbi   ix,0fffeh
        movb    mc,[ga+ix]
x18b0:  mov     ix,[ga].11h
        mov     tp,[ga]

x18b5:  inc     ix
        jmp     x1887

x18ba:  mov     [ga].23h,ix
        andi    mc,0fffh
        mov     [ga].25h,mc
        addbi   ga,3h
        lcall   [ga],x16e2
        ljz     bc,x1946
        add     ix,[ga].20h
        movi    gb,7fdch
        jnbt    [gc],0,x18dc
        addbi   gb,8h
x18dc:  mov     [ga],[gb+ix]
        not     [ga]
        inc     [ga]
        add     [ga],mc
        mov     [gb+ix],mc
        ljbt    [gc],0,x19a9
        jz      [ga],x1946
        mov     [ga],mc
        jnbt    [gc].0cdh,5,x1951
        andbi   mc,3fh
        orbi    mc,20h
        not     mc
        andi    mc,0ffh
        mov     [gc].0d5h,mc
        lcall   [ga],x168a
        jz      bc,x1946
        movi    [ga],40h
        jnbt    [ga].22h,5,x1915
        setb    [ga],0
x1915:  jnbt    [ga].22h,6,x191b
        setb    [ga],1
x191b:  jnbt    [ga].22h,7,x1921
        setb    [ga],2
x1921:  jnbt    [ga].23h,0,x1927
        setb    [ga],3
x1927:  jnbt    [ga].23h,1,x192d
        setb    [ga],4
x192d:  setb    [ga],6
        notb    [ga]
        mov     [gc].0d5h,[ga]
        lcall   [ga],x168a
        jz      bc,x1946
        movi    [gc].0d5h,9eh
        lcall   [ga],x168a
x1946:  addbi   ga,0fffdh
        mov     ix,[ga].23h
        mov     mc,[ga].25h
        mov     tp,[ga]

x1951:  lcall   [ga],x17e0
        not     mc
        andi    mc,0ffh
        setb    [gc].55h,0
        mov     [gc].0d5h,mc
        movi    [gc].0c7h,0c8h
        movb    [gc].0ddh,[gc].55h
        clr     [gc].55h,0
        movb    [gc].0ddh,[gc].55h
        lcall   [ga],x17e0
        notb    mc,[ga].23h
        andi    mc,0ffh
        mov     [gc].0d5h,mc
        movi    [gc].0c7h,148h
        setb    [gc].55h,0
        movb    [gc].0ddh,[gc].55h
        clr     [gc].55h,0
        movb    [gc].0ddh,[gc].55h
        movi    [gc].0d5h,0fbh
        lcall   [ga],x16b7
        movbi   bc,0ffffh
        jmp     x1946

x19a9:  lcall   [ga].19h,x1769
        movbi   [gb].2h,0fh
        movi    mc,0f090h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].3ch
        lcall   [ga].19h,x1796
        movb    [gb].2h,[ga].22h
        movbi   bc,0ffffh
        ljmp    x1946

x19d3:  mov     [ga].7h,ix
        add     ix,[ga].7h
        movbi   bc,0ffffh
        movbi   [gc].0beh,3h
        addbi   ga,0bh
        jbt     [gc],0,x1a49
        jnbt    [gc].0cdh,5,x1a2c
        movi    [gc].0d5h,9dh
        lcall   [ga],x168a
        jz      bc,x1a24
x19f6:  jnbt    [gc].0c5h,2,x1a0f
        dec     bc
        jnz     bc,x19f6
        decb    [gc].0beh
        jnzb    [gc].0beh,x19f6
x1a06:  setb    [gc].30h,7
        movbi   bc,0h
        jmp     x1a24

x1a0f:  lcall   [ga],x16e2
x1a13:  jz      bc,x1a24
        movi    gb,7fdch
        jnbt    [gc],0,x1a20
        addbi   gb,8h
x1a20:  movi    [gb+ix],0h
x1a24:  addbi   ga,0fff5h
        mov     ix,[ga].7h
        mov     tp,[ga]

x1a2c:  movi    [gc].0d5h,0fch
        lcall   [ga],x16b7
x1a35:  lcall   [ga],x17fa
        addbi   [ga].2h,0fff5h
        jzb     [ga].2h,x1a0f
        dec     bc
        jnz     bc,x1a35
        jmp     x1a06

x1a49:  lcall   [ga].19h,x1769
        movbi   [gb].2h,7h
        movi    mc,0f090h
        lcall   [ga].19h,x1796
        movb    [gb].2h,[gc].3ch
x1a61:  jnbt    [gc].0cdh,2,x1a61
        lcall   [ga],x1818
        jz      bc,x1a76
        jzb     [ga].2h,x1a61
        jnz     mc,x1a76
        jmp     x1a13

x1a76:  decb    [gc].0beh
        jnzb    [gc].0beh,x1a49
        jmp     x1a06

x1a80:  mov     [ga].7h,mc
        addbi   ga,9h
        jbt     [gc],0,x1ad2
        movbi   bc,0ffffh
        jnbt    [gc].0cdh,5,x1aaf
x1a90:  jnbt    [gc].0c5h,2,x1a9c
        dec     bc
        jnz     bc,x1a90
x1a99:  setb    [gc].30h,7
x1a9c:  lcall   [ga],x16e2
        jnbt    [gc].30h,7,x1aa7
        movbi   bc,0h
x1aa7:  addbi   ga,0fff7h
        mov     mc,[ga].7h
        mov     tp,[ga]

x1aaf:  lcall   [ga],x17fa
        lcall   [ga],x17fa
        jbt     [ga].2h,4,x1aca
        movb    [ga],[ga].2h
        andbi   [ga],0ffa4h
        jnzb    [ga],x1a99
        jbt     [ga].2h,1,x1aa7
x1aca:  dec     bc
        jnz     bc,x1aaf
        jmp     x1a99

x1ad2:  jnbt    [gc].0cdh,2,x1ad2
        lcall   [ga],x1818
        jz      bc,x1a99
        jzb     [ga].2h,x1ad2
        jmp     x1aa7

x1ae4:  movbi   [gc].52h,0h
        movbi   bc,4h
        jmp     x1af5

x1aee:  movbi   [gc].52h,0ffffh
        mov     bc,[gc].42h
x1af5:  mov     [gc].4bh,ga
        mov     [ga].3h,gb
        movi    ga,x1bf0
        addbi   bc,3h
        movi    gb,400ch
        jzb     [gc].52h,x1b10
        addbi   gb,4h
        add     gb,[gc].42h
x1b10:  mov     [gc].4fh,[gb]
        mov     [gc].4dh,[gb].2h
        movbi   [gc].51h,0h
x1b1f:  dec     bc
        mov     gb,[gc].4fh
        andbi   gb,0fffch
        jnz     gb,x1b61
        mov     mc,[gc].4dh
        jbt     [gc].4fh,1,x1b5b
        jbt     [gc].4fh,0,x1b58
        jbt     [gc].4eh,7,x1b55
        jbt     [gc].4eh,6,x1b52
        jbt     [gc].4eh,5,x1b4f
        jbt     [gc].4eh,4,x1b4c
        jnbt    [gc].4eh,3,x1b95
        andbi   mc,1h
x1b4c:  andbi   mc,3h
x1b4f:  andbi   mc,7h
x1b52:  andbi   mc,0fh
x1b55:  andbi   mc,1fh
x1b58:  andbi   mc,3fh
x1b5b:  andbi   mc,7fh
        jz      mc,x1b95
x1b61:  movb    ix,[gc].4dh
        addb    ix,[gc].4dh
        andi    ix,1feh
        not     mc,[ga+ix]
        and     mc,[gc].4eh
        not     gb,[gc].4eh
        and     gb,[ga+ix]
        mov     [gc].4dh,mc
        or      [gc].4dh,gb
        addi    ix,200h
        not     mc,[ga+ix]
        and     mc,[gc].50h
        not     gb,[gc].50h
        and     gb,[ga+ix]
        mov     [gc].4fh,mc
        or      [gc].4fh,gb
        jnz     bc,x1b1f
        jmp     x1be2

x1b95:  jnz     bc,x1b9c
        jnz     [gc].4fh,x1be2
x1b9c:  movi    ga,4006h
        jzb     [gc].52h,x1ba7
        addbi   ga,8h
x1ba7:  mov     [gc].53h,bc
        mov     ix,[gc].53h
        jnbt    [gc].53h,0,x1bc3
        inc     ix
        mov     [gc].4fh,[gc].4eh
        movb    [gc].4eh,[gc].4dh
        movbi   [gc].4dh,0h
x1bc3:  not     mc,[gc].4fh
        and     mc,[ga+ix]
        not     gb,[ga+ix]
        and     gb,[gc].4fh
        mov     [ga+ix],mc
        or      [ga+ix+],gb
        not     mc,[gc].4dh
        and     mc,[ga+ix]
        not     gb,[ga+ix]
        and     gb,[gc].4dh
        mov     [ga+ix],mc
        or      [ga+ix],gb
        movbi   bc,0ffffh
x1be2:  mov     ga,[gc].4bh
        mov     gb,[ga].3h
        mov     tp,[ga]

	fill	1bf0h,0ffh
	
x1bf0:	

	db	000h,000h,0a9h,022h,052h,045h,0fbh,067h
	db	0a1h,082h,008h,0a0h,0f3h,0c7h,05ah,0e5h
	db	042h,005h,0ebh,027h,010h,040h,0b9h,062h
	db	0e3h,087h,04ah,0a5h,0b1h,0c2h,018h,0e0h
	db	081h,002h,028h,020h,0d3h,047h,07ah,065h
	db	020h,080h,089h,0a2h,072h,0c5h,0dbh,0e7h
	db	0c3h,007h,06ah,025h,091h,042h,038h,060h
	db	062h,085h,0cbh,0a7h,030h,0c0h,099h,0e2h
	db	002h,005h,0abh,027h,050h,040h,0f9h,062h
	db	0a3h,087h,00ah,0a5h,0f1h,0c2h,058h,0e0h
	db	040h,000h,0e9h,022h,012h,045h,0bbh,067h
	db	0e1h,082h,048h,0a0h,0b3h,0c7h,01ah,0e5h
	db	083h,007h,02ah,025h,0d1h,042h,078h,060h
	db	022h,085h,08bh,0a7h,070h,0c0h,0d9h,0e2h
	db	0c1h,002h,068h,020h,093h,047h,03ah,065h
	db	060h,080h,0c9h,0a2h,032h,0c5h,09bh,0e7h
	db	001h,002h,0a8h,020h,053h,047h,0fah,065h
	db	0a0h,080h,009h,0a2h,0f2h,0c5h,05bh,0e7h
	db	043h,007h,0eah,025h,011h,042h,0b8h,060h
	db	0e2h,085h,04bh,0a7h,0b0h,0c0h,019h,0e2h
	db	080h,000h,029h,022h,0d2h,045h,07bh,067h
	db	021h,082h,088h,0a0h,073h,0c7h,0dah,0e5h
	db	0c2h,005h,06bh,027h,090h,040h,039h,062h
	db	063h,087h,0cah,0a5h,031h,0c2h,098h,0e0h
	db	003h,007h,0aah,025h,051h,042h,0f8h,060h
	db	0a2h,085h,00bh,0a7h,0f0h,0c0h,059h,0e2h
	db	041h,002h,0e8h,020h,013h,047h,0bah,065h
	db	0e0h,080h,049h,0a2h,0b2h,0c5h,01bh,0e7h
	db	082h,005h,02bh,027h,0d0h,040h,079h,062h
	db	023h,087h,08ah,0a5h,071h,0c2h,0d8h,0e0h
	db	0c0h,000h,069h,022h,092h,045h,03bh,067h
	db	061h,082h,0c8h,0a0h,033h,0c7h,09ah,0e5h
	db	002h,004h,0abh,026h,050h,041h,0f9h,063h
	db	0a3h,086h,00ah,0a4h,0f1h,0c3h,058h,0e1h
	db	040h,001h,0e9h,023h,012h,044h,0bbh,066h
	db	0e1h,083h,048h,0a1h,0b3h,0c6h,01ah,0e4h
	db	083h,006h,02ah,024h,0d1h,043h,078h,061h
	db	022h,084h,08bh,0a6h,070h,0c1h,0d9h,0e3h
	db	0c1h,003h,068h,021h,093h,046h,03ah,064h
	db	060h,081h,0c9h,0a3h,032h,0c4h,09bh,0e6h
	db	000h,001h,0a9h,023h,052h,044h,0fbh,066h
	db	0a1h,083h,008h,0a1h,0f3h,0c6h,05ah,0e4h
	db	042h,004h,0ebh,026h,010h,041h,0b9h,063h
	db	0e3h,086h,04ah,0a4h,0b1h,0c3h,018h,0e1h
	db	081h,003h,028h,021h,0d3h,046h,07ah,064h
	db	020h,081h,089h,0a3h,072h,0c4h,0dbh,0e6h
	db	0c3h,006h,06ah,024h,091h,043h,038h,061h
	db	062h,084h,0cbh,0a6h,030h,0c1h,099h,0e3h
	db	003h,006h,0aah,024h,051h,043h,0f8h,061h
	db	0a2h,084h,00bh,0a6h,0f0h,0c1h,059h,0e3h
	db	041h,003h,0e8h,021h,013h,046h,0bah,064h
	db	0e0h,081h,049h,0a3h,0b2h,0c4h,01bh,0e6h
	db	082h,004h,02bh,026h,0d0h,041h,079h,063h
	db	023h,086h,08ah,0a4h,071h,0c3h,0d8h,0e1h
	db	0c0h,001h,069h,023h,092h,044h,03bh,066h
	db	061h,083h,0c8h,0a1h,033h,0c6h,09ah,0e4h
	db	001h,003h,0a8h,021h,053h,046h,0fah,064h
	db	0a0h,081h,009h,0a3h,0f2h,0c4h,05bh,0e6h
	db	043h,006h,0eah,024h,011h,043h,0b8h,061h
	db	0e2h,084h,04bh,0a6h,0b0h,0c1h,019h,0e3h
	db	080h,001h,029h,023h,0d2h,044h,07bh,066h
	db	021h,083h,088h,0a1h,073h,0c6h,0dah,0e4h
	db	0c2h,004h,06bh,026h,090h,041h,039h,063h
	db	063h,086h,0cah,0a4h,031h,0c3h,098h,0e1h
	db	000h,000h,020h,055h,040h,0aah,060h,0ffh
	db	020h,054h,000h,001h,060h,0feh,040h,0abh
	db	041h,0a8h,061h,0fdh,001h,002h,021h,057h
	db	061h,0fch,041h,0a9h,021h,056h,001h,003h
	db	022h,050h,002h,005h,062h,0fah,042h,0afh
	db	002h,004h,022h,051h,042h,0aeh,062h,0fbh
	db	063h,0f8h,043h,0adh,023h,052h,003h,007h
	db	043h,0ach,063h,0f9h,003h,006h,023h,053h
	db	044h,0a0h,064h,0f5h,004h,00ah,024h,05fh
	db	064h,0f4h,044h,0a1h,024h,05eh,004h,00bh
	db	005h,008h,025h,05dh,045h,0a2h,065h,0f7h
	db	025h,05ch,005h,009h,065h,0f6h,045h,0a3h
	db	066h,0f0h,046h,0a5h,026h,05ah,006h,00fh
	db	046h,0a4h,066h,0f1h,006h,00eh,026h,05bh
	db	027h,058h,007h,00dh,067h,0f2h,047h,0a7h
	db	007h,00ch,027h,059h,047h,0a6h,067h,0f3h
	db	028h,040h,008h,015h,068h,0eah,048h,0bfh
	db	008h,014h,028h,041h,048h,0beh,068h,0ebh
	db	069h,0e8h,049h,0bdh,029h,042h,009h,017h
	db	049h,0bch,069h,0e9h,009h,016h,029h,043h
	db	00ah,010h,02ah,045h,04ah,0bah,06ah,0efh
	db	02ah,044h,00ah,011h,06ah,0eeh,04ah,0bbh
	db	04bh,0b8h,06bh,0edh,00bh,012h,02bh,047h
	db	06bh,0ech,04bh,0b9h,02bh,046h,00bh,013h
	db	06ch,0e0h,04ch,0b5h,02ch,04ah,00ch,01fh
	db	04ch,0b4h,06ch,0e1h,00ch,01eh,02ch,04bh
	db	02dh,048h,00dh,01dh,06dh,0e2h,04dh,0b7h
	db	00dh,01ch,02dh,049h,04dh,0b6h,06dh,0e3h
	db	04eh,0b0h,06eh,0e5h,00eh,01ah,02eh,04fh
	db	06eh,0e4h,04eh,0b1h,02eh,04eh,00eh,01bh
	db	00fh,018h,02fh,04dh,04fh,0b2h,06fh,0e7h
	db	02fh,04ch,00fh,019h,06fh,0e6h,04fh,0b3h
	db	050h,080h,070h,0d5h,010h,02ah,030h,07fh
	db	070h,0d4h,050h,081h,030h,07eh,010h,02bh
	db	011h,028h,031h,07dh,051h,082h,071h,0d7h
	db	031h,07ch,011h,029h,071h,0d6h,051h,083h
	db	072h,0d0h,052h,085h,032h,07ah,012h,02fh
	db	052h,084h,072h,0d1h,012h,02eh,032h,07bh
	db	033h,078h,013h,02dh,073h,0d2h,053h,087h
	db	013h,02ch,033h,079h,053h,086h,073h,0d3h
	db	014h,020h,034h,075h,054h,08ah,074h,0dfh
	db	034h,074h,014h,021h,074h,0deh,054h,08bh
	db	055h,088h,075h,0ddh,015h,022h,035h,077h
	db	075h,0dch,055h,089h,035h,076h,015h,023h
	db	036h,070h,016h,025h,076h,0dah,056h,08fh
	db	016h,024h,036h,071h,056h,08eh,076h,0dbh
	db	077h,0d8h,057h,08dh,037h,072h,017h,027h
	db	057h,08ch,077h,0d9h,017h,026h,037h,073h
	db	078h,0c0h,058h,095h,038h,06ah,018h,03fh
	db	058h,094h,078h,0c1h,018h,03eh,038h,06bh
	db	039h,068h,019h,03dh,079h,0c2h,059h,097h
	db	019h,03ch,039h,069h,059h,096h,079h,0c3h
	db	05ah,090h,07ah,0c5h,01ah,03ah,03ah,06fh
	db	07ah,0c4h,05ah,091h,03ah,06eh,01ah,03bh
	db	01bh,038h,03bh,06dh,05bh,092h,07bh,0c7h
	db	03bh,06ch,01bh,039h,07bh,0c6h,05bh,093h
	db	03ch,060h,01ch,035h,07ch,0cah,05ch,09fh
	db	01ch,034h,03ch,061h,05ch,09eh,07ch,0cbh
	db	07dh,0c8h,05dh,09dh,03dh,062h,01dh,037h
	db	05dh,09ch,07dh,0c9h,01dh,036h,03dh,063h
	db	01eh,030h,03eh,065h,05eh,09ah,07eh,0cfh
	db	03eh,064h,01eh,031h,07eh,0ceh,05eh,09bh
	db	05fh,098h,07fh,0cdh,01fh,032h,03fh,067h
	db	07fh,0cch,05fh,099h,03fh,066h,01fh,033h
	db	000h,000h,0ffh,0ffh

	db	045h,045h,003h,030h
	db	082h,000h,010h,020h,030h,030h,0a7h,0cfh
