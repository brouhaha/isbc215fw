; Disassembly of Intel iSBC 215G firmware, 147931-001 and -002
; symbols and comments copyright 2016 Eric Smith <spacewar@gmail.com>

; Compared to the iSBC 215A, B, and C, the iSBX 215G adds these features:
; * supports drives with open-loop or closed-loop positioning, or
;   ANSI X3T9/1226 interface
; * supports iSBX 217B or iSBX 217C cartridge tape interface
; * optional 24-bit addressing, for data buffers only


; channel control values
cc_port_to_port		equ	00000h
cc_block_to_port  	equ	04000h
cc_port_to_block  	equ	08000h
cc_block_to_block 	equ	0c000h

cc_no_translate		equ	00000h
cc_translate		equ	02000h

cc_no_sync		equ	00800h
cc_source_sync		equ	01000h
cc_dest_sync		equ	01800h

cc_ga_src_gb_dest	equ	00000h
cc_gb_src_ga_dest	equ	00400h

cc_no_lock		equ	00000h
cc_lock			equ	00200h

cc_no_chain		equ	00000h
cc_chain		equ	00100h

cc_no_single_transfer	equ	00000h
cc_single_transfer	equ	00080h

cc_no_ext_term		equ	00000h
cc_ext_term_res_0	equ	00020h
cc_ext_term_res_4	equ	00040h
cc_ext_term_res_8	equ	00060h

cc_no_bc_term		equ	00000h
cc_bc_term_res_0	equ	00008h
cc_bc_term_res_4	equ	00010h
cc_bc_term_res_8	equ	00018h

; Note that TSH mask/compare termination field definitions in Figure 1-14 of
; Intel 8089 Assembler User's Guide, August 1979, order number 9800938-01,
; appear to have errors. The following definitions are from Figure 3-26 of
; Intel iAPX 86, 88 User's Manual, August 1981, order number 210201-001.

cc_no_search		equ	00000h
cc_match_term_res_0	equ	00001h
cc_match_term_res_4	equ	00002h
cc_match_term_res_8	equ	00003h
cc_no_match_term_res_0	equ	00004h
cc_no_match_term_res_4	equ	00005h
cc_no_match_term_res_8	equ	00006h


cc_ga_port_to_gb_mem		equ	cc_port_to_block+cc_ga_src_gb_dest+cc_bc_term_res_0

cc_ga_port_to_gb_mem_extt	equ	cc_port_to_block+cc_ga_src_gb_dest+cc_ext_term_res_0+cc_bc_term_res_0

cc_gb_mem_to_ga_mem		equ	cc_block_to_block+cc_gb_src_ga_dest+cc_bc_term_res_0

cc_ga_mem_to_gb_mem		equ	cc_block_to_block+cc_ga_src_gb_dest+cc_bc_term_res_0

cc_gb_mem_to_ga_port_extt	equ	cc_block_to_port+cc_gb_src_ga_dest+cc_ext_term_res_0+cc_bc_term_res_0

cc_gb_mem_to_ga_port_extt_no_bc	equ	cc_block_to_port+cc_gb_src_ga_dest+cc_ext_term_res_0


dc_reg_base	equ	8000h	; for use when not indexed from global
				; variables

dc_reg_s	struc
rdc00:		ds	2	; 8000h: read status
s00_ready		equ	1
s00_seek_complete	equ	2
s00_data_sync		equ	3
s00_fault		equ	4
s00_bus_ack		equ	5
s00_id_no_compare	equ	6
s00_timeout		equ	7
s00_isbx_217_present	equ	8
s00_int_00		equ	9
s00_int_10		equ	10
s00_opt_00		equ	11
s00_opt_10		equ	12
s00_illegal_request	equ	13
s00_drive_request	equ	14
s00_index		equ	15
wdc00		equ	rdc00	; 8000h: write control data to disk drive and
				; enable AM SEARCH/, RDGATE and WRT GATE

		ds	6

rdc08:		ds	2	; 8008h: read status
s08_isbx_218a_present	equ	0
s08_int_01		equ	1
s08_int_11		equ	2
s08_opt_01		equ	3
s08_opt_11		equ	4
s08_vendor		equ	5
s08_track_zero		equ	6
s08_write_protected	equ	7

wdc08		equ	rdc08	; 8008h: clear index and ID not compare latches

		ds	6

rdc10:		ds	2	; 8010h

wdc10		equ	rdc10	; 8010h: write to disk control register

		ds	6

rdc18:		ds	2	; 8018h: raise 8089 channel 2 CA input

wdc18		equ	rdc18	; 8018h: write to unit select and control registers

		ds	6

; 8253 timer
counter_0:	ds	1	; 8020h
		ds	1
counter_1:	ds	1	; 8022h
		ds	1
counter_2:	ds	1	; 8024h
		ds	1
counter_mode:	ds	1	; 8026h
		ds	1

dc_data:	ds	2	; 8028h: data register

		ds	6

rdc30:		ds	2	; 8030h: read vendor bits 3 and 4

wdc30		equ	rdc30	; 8030h: write sector ID to high comparator
				;        start track format operation

		ds	6
		
wdc38:		ds	2	; 8038h: write sector ID to low comparator

last_dc_reg:

dc_reg_s	ends


; iSBX 217B Cartridge Tape Controller
; (iSBX 217C also supported)

isbx_217_ch0		equ	0c070h
isbx_217_ch1		equ	0c0b0h

; registers relative to isbx_217_ch0:
tc_ch0_reg_s	struc
tc_cmd_param:		ds	1		; write
tc_drive_status		equ	tc_cmd_param	; read
			ds	1

tc_cmd_func:		ds	1		; write
tc_upi_status		equ	tc_cmd_func	; read
tc_ch0_reg_s	ends

; registers relative to isbx_217_ch0:
tc_ch1_reg_s	struc
tc_data:		ds	1		; read/write
tc_ch1_reg_s	ends

; tape controller commands:
tc_cmd_reset		equ	00h
tc_cmd_initialize	equ	01h
tc_cmd_write		equ	02h
tc_cmd_write_file_mark	equ	03h
tc_cmd_read		equ	04h
tc_cmd_read_file_mark	equ	05h	; not for 3M drive
tc_cmd_read_status	equ	06h
tc_cmd_rewind		equ	07h	; not for 3M drive
tc_cmd_retension	equ	08h	; not for 3M drive
tc_cmd_erase_tape	equ	09h	; not for 3M drive
tc_cmd_unload		equ	0ch	; 3M drive only
tc_cmd_continue		equ	14h	; 3M drive only
tc_cmd_write_ram	equ	15h	; 3M drive only
tc_cmd_read_ram		equ	16h	; 3M drive only
tc_cmd_verify		equ	17h	; 3M drive only
tc_cmd_start_of_xfer	equ	40h
tc_cmd_end_of_xfer	equ	80h


; iSBX 218A Floppy Disk Controller

isbx_218a_ch0	equ	0c0d0h	; iSBX 218A floppy
fdc_status	equ	0	; offset of status register
fdc_data	equ	2	; offset of data register
isbx_218a_ch1	equ	0c0e0h
fdc_dack_gen	equ	0	; offset of DACK generator register
fdc_reset_latch	equ	4	; offset of write reset latch
fdc_latch_0	equ	8	; offset of latch 0
fdc_latch_1	equ	0ch	; offset of latch 1


; 2KiB of RAM is nominally from 4000h through 47ffh, but due to partial
; decode is mirrored throughout the entire 4000h through 7fffh region.
; The hard disk controller registers are from 8000h through 8039h.
; Since the range of the offset in base plus offset addressing is 00h
; through 0ffh, addressing both RAM variables and hard disk controller
; registers from the same base requires the base address to be within
; the last RAM mirror image, slightly below 8000h.

var_base	equ	dc_reg_base+last_dc_reg-0100h

vars_s		struc

		ds	2
ccb:		ds	2
		ds	2
cib:		ds	2
		ds	2
iopb_ptr:	ds	2
		ds	4
iopb:		ds	30
		ds	44
wdc18_shadow:	ds	2

		org	8000h-var_base
vhw:		ds	58	; hardware registers starting at 8000h

vars_s		ends
		

iopb_s		struc
iopb_rsvd:	ds	4
iopb_act_count:	ds	4
iopb_dev_code:	ds	2
iopb_unit:	ds	1
iopb_function:	ds	1
iopb_modifier:	ds	2
iopb_cylinder:	ds	2
iopb_head:	ds	1
iopb_sector:	ds	1
iopb_data_ptr:	ds	4
iopb_req_count:	ds	4
iopb_gen_addr:	ds	4
iopb_s		ends


        ljmp    chan1_prog_start

        ljmp    chan2_prog_start

chan1_prog_start:
        movi    gc,var_base
        movbi   [gc].0dh,0h
        movbi   cc,0h

        movbi   mc,20h
x0016:  movbi   bc,55h
        addb    bc,[gc].0dh
        jz      bc,x0054
        dec     mc
        jnz     mc,x0016

        mov     [gc].vhw+wdc38,ix
        mov     [gc].0a0h,cc	; clear system bus width to 8-bit
        movb    [gc],[gc].vhw+rdc30
        jnbt    [gc],5,x0035
        setb    [gc].0a1h,6
x0035:  movi    ga,x0206	; gb = SCP pointer (sys addr 0ffff6h)
        lpd     gb,[ga]
        movb    [gc],[gb]	; [gc] = SCP.SYSBUS = system (Multibus) bus width
        jnbt    [gc],0,x0045
        setb    [gc].0a0h,6	; set system bus width to 16-bit
x0045:  lpd     ga,[gb].2h	; ga = SCB ptr (iSBC 215 WUB: wake up block)
        jnbt    [gc].0a1h,6,x004e
        dec     mc
x004e:  lpd     gb,[ga].2h	; gb = [SCB+2] = 8089 channel 1 CCB ptr
				;   (iSBC 215 CIB: channel invocation block offset 4)
        movp    [gc].ccb,gb

x0054:  movp    gb,[gc].ccb	; gb = [SCB+2] = 8089 channel 1 CCB ptr
				;   (iSBC 215 CIB: channel invocation block offset 4)
        lpd     ga,[gb].2h	; ga = [CCB+2] = 8089 channel 1 CPB ptr
        addbi   ga,0fffch	; ga = channel 1 CIB (starts 4 bytes before CPB)
        movp    [gc].cib,ga

        lpd     gb,[ga].8h	; gb = [CIB+8] = IOPB pointer
        movp    [gc].iopb_ptr,gb

; set system bus width, local bus always 16 bit
        wid     16,16
        jbt     [gc].0a0h,6,x006e
        wid     8,16
x006e:

; copy 30-byte IOPB to local mem
        movi    ga,7f4ah
        movi    cc,cc_gb_mem_to_ga_mem
        movbi   bc,30
        xfer    

        setb    [gc].1h,3
        movi    ga,7e00h
        movbi   [ga].3h,0h
        movbi   mc,0ffech
        movb    [gc],[gc].iopb+iopb_dev_code
        andb    mc,[gc].iopb+iopb_unit
        jz      mc,x00a1
        movbi   [ga].3h,0ffffh
        movi    [gc].2fh,6000h
        movbi   [gc].iopb+iopb_unit,0h
x00a1:  movb    mc,[gc].iopb+iopb_function
        addi    mc,0e0h
        andi    mc,0ff00h
        ljz     mc,x0183

cmd_invalid:
	movi    [gc].2fh,801h	; status byte 0, invalid iSBC 215G function
				; status byte 1, invalid function code
x00b5:  movbi   [gc].31h,0h
        movbi   bc,0h
        jmp     x00c5

	fill	00c5h,0ffh

x00c5:  movi    gc,var_base
        movb    ga,[gc].3bh
        addb    [gc].3ah,ga
        movi    ga,7e00h
        movbi   gb,0h
        jnbt    [gc].0a1h,6,x00dc
        dec     gb
x00dc:  movb    [gc].vhw+wdc08,gb
        movp    gb,[gc].iopb_ptr
        movb    ix,[gc].iopb+iopb_unit
        andbi   ix,3h

	; copy act_count from local IOPB copy to system IOPB
        mov     [gb].iopb_act_count,[gc].iopb+iopb_act_count
        mov     [gb].iopb_act_count+2,[gc].iopb+iopb_act_count+2

        movi    cc,100h
        movbi   [gc].0dh,0ffffh
        mov     mc,[gc].vhw+rdc18
        jbt     [gc].1h,3,x0118
        jnbt    [gc],2,x0118
        movi    gc,7f00h
        lcall   [ga],x370e
        movb    mc,[gc].0f7h
        movi    gc,var_base
        jmp     x012c

x0118:  movbi   mc,1h
        jnz     [gc].2fh,x0123
        jzb     [gc].31h,x012c
x0123:  orbi    mc,0ff80h
        jnz     bc,x012c
        orbi    mc,40h
x012c:  lcall   [ga].14h,x0248
        hlt     

; command dispatch table

;   comments include:
;     hexadecimal opcode
;     "hft" with letters present for applicable drive types:
;       hard, floppy, tape (if no drive type included,
;       e.g., "---", then drive-independent)
;     full name

cmd_dispatch:
        dw      cmd_initialize	; 00 hft initialize
        dw      cmd_xfer_status	; 01 hft transfer status buffer
        dw      cmd_format	; 02 hf- format
        dw      cmd_read_id	; 03 hf- read sector ID
	dw	cmd_read_data	; 04 hft read data
        dw      cmd_read_verify	; 05 hf- read data to buffer and verify
        dw      cmd_write_data	; 06 hft write data
        dw      cmd_write_buf	; 07 hf- write buffer data
        dw      cmd_track_seek	; 08 hf- initiate track seek
        dw      cmd_invalid
        dw      cmd_invalid
        dw      cmd_spin_down	; 0b h-- spin down
	dw	cmd_isbx_exec	; 0c --- iSBX execute
        dw      cmd_isbx_xfer	; 0d --- iSBX transfer
        dw      cmd_buf_io	; 0e --- buffer I/O
	dw	cmd_diag	; 0f hf- diagnostic
        dw      cmdx_tape_init			; 10 --t tape initialize
        dw      cmdx_tape_rewind		; 11 --t rewind
        dw      cmdx_tape_skip_file_mark	; 12 --t space forward one file mark
        dw      cmd_invalid
        dw      cmdx_tape_write_file_mark	; 14 --t write file mark
        dw      cmd_invalid
        dw      cmd_invalid
        dw      cmdx_tape_erase			; 17 --t erase tape
        dw      cmdx_tape_load			; 18 --t load tape
        dw      cmd_invalid
        dw      cmd_invalid
        dw      cmd_invalid
        dw      cmdx_tape_reset			; 1c --t tape reset
        dw      cmdx_tape_retension		; 1d --t retension tape
        dw      cmdx_tape_read_status		; 1e --t read tape status
        dw      cmdx_tape_rw_terminate		; 1f --t read/write terminate

x0173:  dw      x01ba
        dw      x01ba
        dw      x01cb
        dw      x01ba
        dw      x01ba
        dw      x01cb
        dw      x01cb
        dw      x01cb

x0183:  movb    [ga],[gc].iopb+iopb_function
        addbi   [ga],0fff4h
        andbi   [ga],0fffch
        jnzb    [ga],x019b
        movb    [ga],[gc].iopb+iopb_function
        incb    [ga]
        jnbt    [ga],4,x01ef
x019b:  ljnzb   [ga].3h,x00b5
        jnzb    [gc].iopb+iopb_dev_code+1,x01cb
        movb    [ga],[gc]
        andbi   [ga],0fff8h
        jnzb    [ga],x01cb
        movi    gb,x0173
        addb    gb,[gc].iopb+iopb_dev_code
        addb    gb,[gc].iopb+iopb_dev_code
        mov     tp,[gb]

x01ba:  clr     [gc].1h,3
        jbt     [gc],2,x01d4
        movb    [ga],[gc].iopb+iopb_function
        andbi   [ga],0fff0h
        jzb     [ga],x01d4
x01cb:  movi    [gc].2fh,40h
        ljmp    x00b5

x01d4:  movb    ix,[gc].iopb+iopb_unit
        andbi   ix,3h
        lcall   [ga].0fh,x208e
        setb    [gb+ix],5
        clr     [gb+ix],3
        jnbt    [gc].iopb+iopb_modifier,0,x01e9	; suppress interrupt?
        clr     [gb+ix],5
x01e9:  jnbt    [gc].iopb+iopb_modifier,1,x01ef	; inhibit retries?
        setb    [gb+ix],3
x01ef:  jnbt    [gc].iopb+iopb_modifier,4,x01f6	; 24-bit addressing?
        call    [ga],x020a
x01f6:  movi    gb,cmd_dispatch
        addb    gb,[gc].iopb+iopb_function	; add 2 * iopb_function
        addb    gb,[gc].iopb+iopb_function
        movbi   [gc].0bch,0h
        mov     tp,[gb]

x0206:  dw      0fff6h
        dw      0f000h


; mangle data buffer address if 24-bit addressing is enabled
x020a:  movb    [gc].5h,[gc].iopb+iopb_data_ptr+2
        andbi   [gc].5h,0fff0h
        movb    [gc].9h,[gc].iopb+iopb_data_ptr+2
        andbi   [gc].9h,0fh
        movbi   [gc].iopb+iopb_data_ptr+2,0h
        movi    gb,238h
        addb    gb,[gc].9h
        movb    [gc].iopb+iopb_data_ptr+3,[gb]
        mov     tp,[ga]			; return


cmd_spin_down:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x25bb

x0238:  db      00h,10h,20h,30h
	db	40h,50h,60h,70h
        db      80h,90h,0a0h,0b0h
	db	0c0h,0d0h,0e0h,0f0h

x0248:  movbi   gb,0h
        jnbt    [gc].0a1h,6,x0251
        dec     gb
x0251:  movb    [gc].vhw+wdc08,gb
        movi    gb,x3beb
        orb     mc,[gb+ix]
        movp    gb,[gc].cib
        jnbt    [gc],0,x0263
        orbi    mc,8h
x0263:  jzb     [gb].3h,x0270
        mov     [ga].16h,[ga].19h
        jmp     x0263

x0270:  movb    [gb].1h,mc
        movbi   [gb].3h,0ffffh
        jbt     [gc].1h,3,x0286
        lcall   [ga].0fh,x208e
        jnbt    [gb+ix],5,x0299
        jmp     x028a

x0286:  jbt     [gc].iopb+iopb_modifier,0,x0299	; suppress interrupt
x028a:  setb    [gc].5fh,0
        mov     [gc].vhw+wdc10,[gc].5eh
        clr     [gc].5fh,0
        clr     [gc].1h,3
x0299:  mov     tp,[ga].14h

cmd_initialize:
        lcall   [ga],x1def
        jnbt    [gc],2,x02ae	; XXX possibly following handles floppy or tape
        lcall   [ga],x36f1
        lcall   [ga],x372c
        jmp     x02fd

x02ae:  jbt     [gc],0,x02f9
        jnz     ix,x02f9
        jbt     [gc].iopb+iopb_modifier,5,x02f2	; bypass board test
        movbi   [gc].vhw+counter_mode,34h
        movbi   [gc].vhw+counter_mode,74h
        movbi   [gc].vhw+counter_mode,0ffb4h
        movb    [gc].vhw+counter_0,bc
        movb    [gc].vhw+counter_0,bc
        movb    [gc].vhw+counter_1,bc
        movb    [gc].vhw+counter_1,bc
        movb    [gc].vhw+counter_2,bc
        movb    [gc].vhw+counter_2,bc
        movbi   [gc].vhw+counter_mode,3ah
        movbi   [gc].vhw+counter_mode,7ah
        movbi   [gc].vhw+counter_mode,0ffbah
        lcall   [ga],x0941
        ljz     bc,x0376
        lcall   [ga],x09a9
        ljz     bc,x0376
x02f2:  movbi   [gc].iopb+iopb_act_count,55h
        jmp     x02fd

x02f9:  movbi   [gc].iopb+iopb_act_count,8h
x02fd:  lcall   [ga],x205e
        mov     [gc].54h,gb
        jnbt    [gc],2,x0316
        movbi   [gc].iopb+iopb_act_count,1h
        movb    [gc].0bfh,[gb]
        movbi   bc,1h
        jmp     x0319

x0316:  movbi   bc,8h
x0319:  movi    cc,cc_gb_mem_to_ga_mem
        movbi   [ga].3h,8h
        lcall   [ga],x0a60
        mov     gb,[gc].54h
        movi    ga,7fdah
        jbt     [gc],2,x037a
        jnbt    [gc],0,x0358
        addbi   ga,4h
        jnzb    [gb],x033e
        andbi   [ga+ix],20h
        jmp     x0376

x033e:  movbi   [gc].3dh,0h
        andbi   [ga+ix],28h
        movb    [gc].56h,[gb].7h
        clr     [gc].56h,0
        jnbt    [gb].7h,0,x0354
        setb    [ga+ix],6
x0354:  ljmp    x039d

x0358:  andbi   [ga+ix],68h
        jz      [gb],x0376
        orbi    [ga+ix],3h
x0361:  movi    ga,7e00h
        lcall   [ga],x23c0
        jz      bc,x0373
        lcall   [ga],x2bc3
        jnz     bc,x0376
x0373:  setb    [gc].30h,6
x0376:  ljmp    x00c5

x037a:  movi    gc,7f00h
        andbi   [gc].0f9h,28h
        movb    bc,[gc].0f9h
        orb     [gb],bc
        jnbt    [gb],0,x0394
        orbi    [gb],2h
        andbi   [gc].16h,8h
        jmp     x0396

x0394:  clr     [gb],6
x0396:  movbi   [gc].0f7h,9h
        jmp     x0376

x039d:  orbi    [ga+ix],3h
        movi    ga,7e00h
        lcall   [ga],x20ba
        jz      bc,x0373
        movi    gb,isbx_218a_ch1
        movbi   [gb].fdc_latch_0,1h
        jnbt    [gb].fdc_latch_0,0,x03c6
        movbi   [gb].fdc_latch_0,0h
        jbt     [gb].fdc_latch_0,0,x03c6
        movbi   [gb].fdc_latch_1,0h
        setb    [gc].1h,2
x03c6:  lcall   [ga].19h,x2971
        lcall   [ga],x29af
        lcall   [ga],x1def
        movbi   [gb].2h,3h
        movi    mc,0f090h
        lcall   [ga].19h,x299e
        movi    gc,7f00h
        clr     [gc].16h,3
        jbt     [gc].56h,7,x03ef
        jnbt    [gc].3ah,1,x03f2
x03ef:  setb    [gc].16h,3
x03f2:  movi    gc,var_base
        jnzb    [gc].56h,x0400
        jbt     [gc],1,x0467
        jmp     x0458

x0400:  mov     [ga],[gc].56h
        andbi   [ga],0eh
        addbi   [ga],2h
        notb    [ga]
        incb    [ga]
        movbi   [ga].1h,0h
        jnbt    [ga],0,x0419
        setb    [ga].1h,4
x0419:  jnbt    [ga],1,x041f
        setb    [ga].1h,5
x041f:  jnbt    [ga],2,x0425
        setb    [ga].1h,6
x0425:  jnbt    [ga],3,x042b
        setb    [ga].1h,7
x042b:  orbi    [ga].1h,0fh
        movb    [gb].2h,[ga].1h
        lcall   [ga].19h,x299e
        movbi   [ga],1h
        jnbt    [gc].56h,4,x0443
        setb    [ga],3
x0443:  jnbt    [gc].56h,5,x0449
        setb    [ga],4
x0449:  jnbt    [gc].56h,6,x044f
        setb    [ga],5
x044f:  jnbt    [gc].56h,7,x0455
        setb    [ga],6
x0455:  jmp     x0473

x0458:  movbi   [gb].2h,5fh
        lcall   [ga].19h,x299e
        movbi   [ga],3dh
        jmp     x0473

x0467:  movbi   [gb].2h,5fh
        lcall   [ga].19h,x299e
        movbi   [ga],13h
x0473:  movb    [gb].2h,[ga]
        ljmp    x0361

cmd_xfer_status:
        jnbt    [gc],2,x048f		; XXX possibly following handles floppy or tape
        jnbt    [gc].iopb+iopb_modifier,6,x048b	 ; xfer long term status buffer
        lcall   [ga],x370e
        movi    gc,var_base
x048b:  movbi   [gc].0bdh,9h
x048f:  movi    cc,cc_ga_mem_to_gb_mem
        movbi   bc,0ch
        movbi   [ga].3h,10h
        lcall   [ga],x0a60
        lcall   [ga],x1def
        movbi   [gc].iopb+iopb_act_count,12
        dec     bc
        ljmp    x00c5

cmd_buf_io:
        lcall   [ga],x1def
        mov     bc,[gc].26h
        mov     [gc].14h,bc
        movi    cc,cc_gb_mem_to_ga_mem
        movbi   [ga].3h,20h
        jnzb    [gc].20h,x04c6
        andi    cc,0ffffh-cc_gb_src_ga_dest	; reverse direction of xfer
x04c6:  lcall   [ga],x0a60
        dec     bc
        ljmp    x00c5

cmd_track_seek:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1def
        movb    [gc].34h,[gc].20h
        mov     [gc].32h,[gc].1eh
        andi    [gc].32h,0fffh
        lcall   [ga].0fh,x208e
        jnbt    [gb+ix],2,x04fa
        setb    [gc].2fh,5
        movbi   bc,0h
        jmp     x054c

x04fa:  lcall   [ga],x20ba
        jz      bc,x051d
        lcall   [ga],x205e
        lcall   [ga],x200a
        jz      bc,x0523
        lcall   [ga],x2001
        jnz     bc,x0529
        lcall   [ga],x2bc3
        movbi   bc,0h
        jmp     x0523

x051d:  setb    [gc].30h,6
        jmp     x054c

x0523:  setb    [gc].30h,5
        jmp     x054c

x0529:  movb    mc,[gc].34h
        lcall   [ga],x21d8
        jz      bc,x054c
        mov     mc,[gc].32h
        lcall   [ga],x2a6b
        jz      bc,x054c
        lcall   [ga].0fh,x208e
        setb    [gb+ix],2
        lcall   [ga],x20a5
        movi    [gb],0d508h
x054c:  ljmp    x00c5

cmd_format:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1d00
        ljz     bc,x068e
        lcall   [ga],x1761
        ljz     bc,x068e
        movbi   [gc].14h,6h
        movbi   bc,6h
        movi    cc,cc_gb_mem_to_ga_mem
        movbi   [ga].3h,4h
        lcall   [ga],x0a60
        mov     [ga],[ga].0ah
        mov     [ga].2h,[ga].0ch
        mov     [ga].4h,[ga].0eh
        andbi   [ga],0ffc0h
        jnbt    [gc],0,x059c
        movb    [gc].52h,[ga].1h
        ljzb    [ga],x05e8
        ljmp    x0677

x059c:  jnbt    [ga],7,x05a3
        ljbt    [ga],6,x0677
x05a3:  movb    bc,[ga]
        orb     [gc].3fh,bc
        mov     bc,[gc].46h
        movb    [ga].8h,[gc].43h
        movi    [gc].50h,4429h
        movb    mc,[gc].43h
        movb    [gc].54h,[gc].43h
        movb    gb,[gc].43h
        addb    [gc].54h,gb
        addbi   gb,0fffch
        movb    [ga].9h,gb
        movb    [ga].0ah,[gc].54h
        movi    gb,4010h
        movbi   ix,0h
x05d8:  mov     [gb+ix+],[ga].1h
        mov     [gb+ix+],[ga].3h
        addbi   bc,0fffch
        jnz     bc,x05d8
x05e8:  movb    ix,[ga].5h
        addbi   ga,0fh
        lcall   [ga],x1a4e
        movi    gb,4428h
        lcall   [ga],x1f94
        wid     16,16
        lcall   [ga],x17d6
        ljbt    [gc],0,x0692
        ljz     bc,x068e
        lcall   [ga],x1984
        addbi   ga,0fff1h
        movi    ix,0c6h
        mov     [gc].4ch,ga
        jmp     x0629

x0619:  movb    [gc].54h,[ga].0ah
        addi    [gc].50h,2h
        dec     mc
        jz      mc,x0667
x0629:  mov     gb,[gc].50h
        jnzb    [gb],x0636
        movi    gb,4428h
        mov     [gc].50h,gb
x0636:  movb    [gc].41h,[gb]
x063b:  movi    cc,cc_ga_port_to_gb_mem
        mov     [gc].vhw+wdc08,mc
        jnzb    [gc].0b9h,x064e
        lcall   [ga].10h,x177a
        jmp     x0653

x064e:  lcall   [ga].10h,x1724
x0653:  jnz     bc,x0619
        decb    [gc].54h
        jnzb    [gc].54h,x063b
        jnbt    [gc].3fh,7,x0671
        decb    [ga].9h
        jmp     x0619

x0667:  jbt     [ga].9h,7,x0671
        movbi   bc,0ffffh
        jmp     x068e

x0671:  setb    [gc].30h,4
        jmp     x067a

x0677:  setb    [gc].2fh,6
x067a:  mov     [gc].35h,[gc].41h
        mov     [gc].36h,[gb]
        mov     [gc].38h,[gb].2h
        movbi   bc,0h
x068e:  ljmp    x00c5

x0692:  movi    ga,4010h
        movbi   ix,0h
        movb    bc,[gc].43h
x069c:  movb    [ga+ix+],[gc].3eh
        movb    [ga+ix+],[gc].40h
        movb    [ga+ix+],[gb]
        movb    [ga+ix+],[gc].42h
        inc     gb
        dec     bc
        jnz     bc,x069c
        addi    ga,1f4h
        mov     [gc].54h,ix
        lcall   [ga].19h,x2971
        movbi   bc,0dh
        orb     bc,[gc].3ch
        movb    [gb].2h,bc
        movi    mc,0ff90h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].3dh
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].42h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].43h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].44h
        movi    ga,4011h
        add     ga,[gc].54h
        not     ix
        movb    cc,[ga+ix+]
        movb    bc,[ga+ix+]
x0708:  jmcne   [gb],x0708
        jmp     x070e

; transfer data to FDC
x070e:  movi    mc,0ffd0h
        movb    [gb].2h,[gc].52h
        movi    gc,isbx_218a_ch0+fdc_data
x071c:  ljnbt   [gb],7,x071c
        movb    [gc],cc
        jmce    [gb],x072f
x0725:  jnbt    [gb],7,x0725
        movb    [gc],bc
        movb    bc,[ga+ix+]
        jnz     ix,x0725
x072f:  movi    gc,var_base
        lcall   [ga],x14df
        ljmp    x068e

cmd_write_data:
        ljbt    [gc],2,x319f	; XXX possibly to handle floppy or tape
        lcall   [ga],x1d00
        jz      bc,x07b9
        lcall   [ga],x1761
        jz      bc,x07b9
        lcall   [ga],x1a4e
        lcall   [ga],x1984
        lcall   [ga],x0baa
        jnbt    [ga].3h,0,x0761
        lcall   [ga],x0bfc
x0761:  jz      bc,x07b6
        mov     [ga].4h,bc
        lpd     gb,[gc].22h
x076a:  movi    cc,cc_gb_mem_to_ga_mem
        lcall   [ga],x0be4
        movbi   [ga].3h,2h
        lcall   [ga],x0a60
        movp    [ga],gb
        addbi   ga,9h
        lcall   [ga],x1337
        addbi   ga,0fff7h
        jz      bc,x07b9
        addbi   ga,9h
        lcall   [ga],x0baa
        jnbt    [ga].3h,0,x0798
        lcall   [ga],x0bfc
x0798:  addbi   ga,0fff7h
        jz      bc,x07b6
        mov     [ga].4h,bc
        addbi   ga,9h
        lcall   [ga],x1f05
        addbi   ga,0fff7h
        jz      bc,x07b9
        mov     bc,[ga].4h
        movp    gb,[ga]
        jmp     x076a

x07b6:  movbi   bc,0ffffh
x07b9:  ljmp    x00c5

cmd_read_data:
        ljbt    [gc],2,x317b	; XXX possibly to handle floppy or tape
        lcall   [ga],x1d00
        jz      bc,x081f
        lcall   [ga],x1a03
        lcall   [ga],x0baa
        jz      bc,x081c
        mov     [ga].4h,bc
        lpd     gb,[gc].22h
        movp    [ga],gb
        addbi   ga,9h
x07de:  lcall   [ga],x1000
        addbi   ga,0fff7h
        jz      bc,x081f
        movp    gb,[ga]
        mov     bc,[ga].4h
        lcall   [ga],x0be4
        movi    cc,cc_ga_mem_to_gb_mem
        addbi   ga,9h
        movbi   [ga].3h,2h
        lcall   [ga],x0a60
        lcall   [ga],x0baa
        addbi   ga,0fff7h
        jz      bc,x081c
        mov     [ga].4h,bc
        movp    [ga],gb
        addbi   ga,9h
        lcall   [ga],x1f05
        jnz     bc,x07de
        jmp     x081f

x081c:  movbi   bc,0ffffh
x081f:  ljmp    x00c5

cmd_read_id:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1def
        movi    [gc].32h,0ffffh
        movi    [gc].34h,0ffffh
        lcall   [ga].0fh,x208e
        jnbt    [gb+ix],2,x0846
        setb    [gc].2fh,5
        movbi   bc,0h
        jmp     x0881

x0846:  lcall   [ga],x20ba
        jz      bc,x0881
        lcall   [ga],x2700
        jz      bc,x0881
        lcall   [ga],x159e
        jz      bc,x0881
        movb    [gb].4h,[gb].1h
        andbi   [gb].4h,0fff0h
        andbi   [gb].1h,0fh
        movbi   bc,5h
        movb    [gc].14h,bc
        movi    cc,cc_ga_mem_to_gb_mem
        lpd     gb,[gc].22h
        movbi   [ga].3h,2h
        lcall   [ga],x0a60
        movbi   bc,0ffffh
x0881:  ljmp    x00c5

cmd_diag:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1def
        movb    bc,[gc].1dh
        jz      bc,x08be
        dec     bc
        ljz     bc,x093a
        lcall   [ga],x20ba
        ljz     bc,x0933
        lcall   [ga].0fh,x208e
        jnbt    [gb+ix],2,x08b3
        setb    [gc].2fh,5
        movbi   bc,0h
        ljmp    x0933

x08b3:  lcall   [ga],x2bc3
        ljz     bc,x0933
        jmp     x0936

x08be:  mov     [gc].1eh,cc
        movi    [gc].20h,100h
        lcall   [ga],x1d00
        jz      bc,x0933
        lcall   [ga],x1761
        jz      bc,x0933
        mov     mc,[gc].4ah
        or      [gc].3eh,mc
        lcall   [ga],x1e03
        jz      bc,x0933
        lcall   [ga],x159e
        not     bc,[gb]
        andi    bc,0fffh
        and     bc,[gc].32h
        jz      bc,x0906
        mov     [gc].36h,[gc].10h
        mov     [gc].38h,[gc].12h
        setb    [gc].31h,6
        movbi   bc,0h
        jmp     x0933

x0906:  mov     [ga],ix
        movi    gb,4410h
        movi    ix,0fc00h
x0910:  movi    [gb+ix+],55aah
        jnz     ix,x0910
        mov     ix,[ga]
        lcall   [ga],x1a4e
        lcall   [ga],x1984
        lcall   [ga],x1337
        jz      bc,x0933
        lcall   [ga],x1a03
        lcall   [ga],x1000
        jnz     bc,x0936
x0933:  setb    [gc].30h,1
x0936:  ljmp    x00c5

x093a:  call    [ga],x0941
        ljmp    x00c5

x0941:  addbi   ga,4h
        movbi   bc,0ffffh
        nop     
        nop     
        movi    gc,3ffeh
        mov     [ga],cc
        mov     [ga].2h,cc
x0954:  addbi   gc,0fffeh
        movb    gb,[gc]
        andi    gb,0ffh
        add     [ga],gb
        movb    gb,[gc].1h
        andi    gb,0ffh
        add     [ga].2h,gb
        jnz     gc,x0954
        movi    gc,3ffeh
        movb    gb,[ga]
        addb    gb,[ga].1h
        not     gb
        inc     gb
        addb    gb,[gc]
        andi    gb,0ffh
        jnz     gb,x0996
        movb    gb,[ga].2h
        addb    gb,[ga].3h
        not     gb
        inc     gb
        addb    gb,[gc].1h
        andi    gb,0ffh
        jz      gb,x09a0
x0996:  movi    gc,var_base
        setb    [gc].2fh,4
        movbi   bc,0h
x09a0:  addbi   ga,0fffch
        movi    gc,var_base
        mov     tp,[ga]

x09a9:  mov     mc,[ga]
        mov     cc,[gc].0a0h
        movp    gc,[gc].2h
        movi    ix,0f800h
        movi    gb,4800h
        movi    ga,0ffffh
x09bd:  mov     [gb+ix+],ga
        jnz     ix,x09bd
        movi    ix,0f800h
x09c6:  not     bc,[gb+ix+]
        jnz     bc,x09f5
        jnz     ix,x09c6
        movi    ix,0f800h
        movi    ga,0h
x09d6:  mov     [gb+ix+],ga
        jnz     ix,x09d6
        movi    ix,0f800h
x09df:  mov     bc,[gb+ix+]
        jnz     bc,x09f5
        jnz     ix,x09df
        movbi   bc,0ffffh
        movi    ga,7f69h
        movi    [ga],0h
        jmp     x0a00

x09f5:  movbi   bc,0h
        movi    ga,7f69h
        movi    [ga],8h
x0a00:  movbi   [ga].2h,0h
        movp    [ga].1fh,gc
        movi    gc,var_base
        movp    ga,[gc].4eh
        movp    [gc].2h,ga
        lpd     gb,[ga].2h
        addbi   gb,0fffch
        movp    [gc].6h,gb
        lpd     ga,[gb].8h
        movp    [gc].0ah,ga
        mov     [gc].22h,[ga].12h
        mov     [gc].24h,[ga].14h
        mov     [gc].1ch,[ga].0ch
        mov     [gc],cc
        movi    gb,8002h
        movbi   cc,0h
        movi    ix,0ff6ah
x0a3f:  mov     [gb+ix+],cc
        jnz     ix,x0a3f
        mov     [gc].0a0h,[gc]
        movb    [gc].1ah,cc
        mov     [gc],cc
        movi    ga,7e00h
        nop     
        jnbt    [gc].iopb+iopb_modifier,4,x0a5c	; 24-bit addressing
        lcall   [ga],x020a
x0a5c:  mov     [ga],mc
        mov     tp,[ga]

x0a60:  mov     [gc].56h,cc
        wid     16,16
        jbt     [gc].0a0h,6,x0a71
        wid     16,8
        jnbt    [gc].57h,2,x0a71
        wid     8,16
x0a71:  movbi   [ga].8h,0ffffh
        movb    [gc].vhw+wdc08,[gc].5h
        jnbt    [gc].iopb+iopb_modifier,4,x0af2	; 24-bit addressing
        clr     [ga].3h,7
        mov     [gc].58h,[gc].22h
        jbt     [ga].3h,1,x0a90
        jnbt    [ga].3h,6,x0a93
x0a90:  add     [gc].22h,bc
x0a93:  dec     bc
        mov     [ga].6h,bc
        jbt     [ga].7h,7,x0aa3
        jnbt    [gc].59h,7,x0af0
        jmp     x0aa7

x0aa3:  jbt     [gc].59h,7,x0ab6
x0aa7:  add     [gc].58h,bc
        jbt     [gc].59h,7,x0ae1
        inc     bc
        inc     [gc].58h
        jmp     x0abb

x0ab6:  inc     bc
        add     [gc].58h,bc
x0abb:  inc     [ga].6h
x0abe:  incb    [gc].9h
        jnbt    [gc].9h,4,x0af2
        setb    [ga].3h,0
        movbi   [gc].9h,0h
        jbt     [ga].3h,7,x0adb
        not     mc,[gc].58h
        inc     mc
        add     [ga].6h,mc
        mov     bc,[ga].6h
x0adb:  decb    [ga].8h
        jmp     x0af2

x0ae1:  inc     [gc].58h
        jnz     [gc].58h,x0af0
        setb    [ga].3h,7
        inc     bc
        jmp     x0abe

x0af0:  inc     bc
x0af2:  mov     [gc].0eh,ga
        jbt     [ga].3h,1,x0b11
        jbt     [ga].3h,2,x0b19
        jbt     [ga].3h,3,x0b20
        ljbt    [ga].3h,4,x0b49
        jbt     [ga].3h,6,x0b27
        mov     ga,[gc].1eh
        ljmp    x0b4d

x0b11:  movi    ga,4010h
        ljmp    x0b50

x0b19:  addbi   ga,0ah
        ljmp    x0b4d

x0b20:  mov     ga,[gc].54h
        ljmp    x0b4d

x0b27:  movi    gc,7f00h
        jbt     [gc].16h,5,x0b3e
        setb    [gc].16h,5
        jnbt    [gc].vhw+rdc30,4,x0b3e
        setb    [gc].16h,2
        movi    [gc].27h,0h
x0b3e:  movi    ga,isbx_217_ch1		; tape data
        movi    gc,var_base
        jmp     x0b50

x0b49:  movi    ga,7f69h
x0b4d:  lpd     gb,[gc].22h
x0b50:  mov     [gc].4eh,ga
        dec     bc
        jz      bc,x0b94
        inc     bc
        xfer    
        nop     
x0b5e:  mov     ga,[gc].0eh
        jnbt    [gc],2,x0b67
        jnz     bc,x0b92
x0b67:  incb    [ga].8h
        jzb     [ga].8h,x0b92
        addbi   [gc].5h,10h
        movb    [gc].vhw+wdc08,[gc].5h
        jbt     [ga].3h,7,x0b92
        mov     bc,[gc].58h
        jnbt    [ga].3h,6,x0b89
        mov     ga,[gc].4eh
        jmp     x0b50

x0b89:  mov     ga,[ga].6h
        add     ga,[gc].4eh
        jmp     x0b50

x0b92:  mov     tp,[ga]

x0b94:  jnbt    [gc].57h,2,x0ba1
        movb    [ga],[gb]
        inc     gb
        jmp     x0b5e

x0ba1:  movb    [gb],[ga]
        inc     gb
        jmp     x0b5e

x0baa:  clr     [ga].3h,0
        not     bc,[gc].46h
        inc     bc
        movbi   mc,0h
        jbt     [gc].27h,7,x0bbd
        movi    mc,80h
x0bbd:  add     [gc].26h,bc
        not     bc
        inc     bc
        andb    mc,[gc].27h
        jz      mc,x0be2
        jnz     [gc].28h,x0bdf
        add     bc,[gc].26h
        jz      bc,x0bd7
        setb    [ga].3h,0
x0bd7:  movi    [gc].26h,0h
        jmp     x0be2

x0bdf:  dec     [gc].28h
x0be2:  mov     tp,[ga]

x0be4:  movbi   mc,0h
        jnbt    [gc].15h,7,x0bed
        inc     mc
x0bed:  add     [gc].14h,bc
        jz      mc,x0bfa
        jbt     [gc].15h,7,x0bfa
        inc     [gc].16h
x0bfa:  mov     tp,[ga]

x0bfc:  mov     [ga].0ah,ix
        mov     [ga].0ch,[gc].46h
        not     bc
        inc     bc
        add     [ga].0ch,bc
        not     bc
        inc     bc
        mov     ix,[ga].0ch
        mov     [ga].0ch,bc
        movi    gb,4010h
        add     gb,[ga].0ch
x0c1d:  movbi   [gb+ix],0h
        dec     ix
        jnz     ix,x0c1d
        movbi   [gb],0h
        mov     ix,[ga].0ah
        mov     tp,[ga]

cmd_write_buf:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1d00
        jz      bc,x0c90
        lcall   [ga],x1761
        jz      bc,x0c90
        lcall   [ga],x1a4e
        lcall   [ga],x1984
        lcall   [ga],x0baa
        jnbt    [ga].3h,0,x0c53
        lcall   [ga],x0bfc
x0c53:  jz      bc,x0c8c
        mov     [ga],bc
        addbi   ga,2h
x0c5b:  lcall   [ga],x1337
        jz      bc,x0c90
        addbi   ga,0fffeh
        mov     bc,[ga]
        lcall   [ga],x0be4
        lcall   [ga],x0baa
        jnbt    [ga].3h,0,x0c77
        lcall   [ga],x0bfc
x0c77:  addbi   ga,0fffeh
        jz      bc,x0c8c
        mov     [ga],bc
        addbi   ga,2h
        lcall   [ga],x1f05
        jz      bc,x0c90
        jmp     x0c5b

x0c8c:  movi    bc,0ffh
x0c90:  ljmp    x00c5

cmd_read_verify:
        ljbt    [gc],2,x3778	; XXX possibly to handle floppy
        lcall   [ga],x1d00
        jz      bc,x0cd8
        lcall   [ga],x1a03
        lcall   [ga],x0baa
        jz      bc,x0cd5
        mov     [ga],bc
        addbi   ga,2h
x0caf:  lcall   [ga],x1000
        jz      bc,x0cd8
        addbi   ga,0fffeh
        mov     bc,[ga]
        lcall   [ga],x0be4
        lcall   [ga],x0baa
        jz      bc,x0cd5
        mov     [ga],bc
        addbi   ga,2h
        lcall   [ga],x1f05
        jz      bc,x0cd8
        jmp     x0caf

x0cd5:  movbi   bc,0ffffh
x0cd8:  ljmp    x00c5

cmd_isbx_exec:
        lpd     gb,[gc].2ah
        mov     [ga],gb
        mov     tp,[ga]

cmd_isbx_xfer:
        lcall   [ga],x1def
        movb    [gc].vhw+wdc08,[gc].5h
        mov     [ga],[gc].1eh
        lpd     gb,[gc].22h
        movp    [ga].2h,gb
        lpd     gb,[gc].26h
        mov     [ga].5h,gb
        mov     bc,[ga].5h
        movb    [ga].5h,[gc].20h
        wid     16,16
        jnbt    [ga].5h,7,x0d31
        movi    [ga].6h,4428h
        jbt     [gc].0a0h,6,x0d21
        wid     8,16
        jbt     [ga].5h,1,x0d27
        wid     8,8
        jmp     x0d27

x0d21:  jbt     [ga].5h,1,x0d27
        wid     16,8
x0d27:  jnbt    [ga].5h,0,x0d2e
        setb    [ga].7h,3
x0d2e:  jmp     x0d52

x0d31:  movi    [ga].6h,8028h		; XXX possibly dc_reg_base+dc_data
					;     or cc_ga_port_to_gb_mem_extt
        jbt     [gc].0a0h,6,x0d45
        wid     16,8
        jbt     [ga].5h,1,x0d4b
        wid     8,8
        jmp     x0d4b

x0d45:  jbt     [ga].5h,1,x0d4b
        wid     8,16
x0d4b:  jnbt    [ga].5h,0,x0d52
        setb    [ga].7h,3
x0d52:  mov     cc,[ga].6h
        movp    gb,[ga].2h
        mov     ga,[ga]
        xfer    
        nop     
        jz      bc,x0d77
        not     bc
        inc     bc
        add     bc,[gc].26h
        mov     [gc].14h,bc
x0d6b:  movi    [gc].16h,0h
        movbi   bc,0ffffh
        ljmp    x00c5

x0d77:  mov     [gc].14h,[gc].26h
        jmp     x0d6b

cmdx_tape_init:
        ljmp    cmd_tape_init
cmdx_tape_rewind:
        ljmp    cmd_tape_rewind
cmdx_tape_skip_file_mark:
        ljmp    cmd_tape_skip_file_mark
cmdx_tape_write_file_mark:
        ljmp    cmd_tape_write_file_mark
cmdx_tape_erase:
        ljmp    cmd_tape_erase
cmdx_tape_load:
        ljmp    cmd_tape_load
cmdx_tape_reset:
        ljmp    cmd_tape_reset
cmdx_tape_retension:
        ljmp    cmd_tape_retension
cmdx_tape_read_status:
        ljmp    cmd_tape_read_status
cmdx_tape_rw_terminate:
        ljmp    cmd_tape_rw_terminate

	fill	1000h,0ffh

x1000:  mov     [ga].3h,ix
        movbi   [gc].0bdh,3h
x1007:  movbi   mc,0h
        ljbt    [gc],0,x1270
        mov     [ga].7h,mc
        mov     [ga].9h,mc
        movb    [gc].3ah,mc
        wid     16,16
        movi    cc,cc_ga_port_to_gb_mem_extt
        movb    [ga].0dh,mc
        movbi   bc,0fff1h
        addb    bc,[gc].0b8h
        jnz     bc,x102f
        mov     [gc].0c8h,[gc].5eh
x102f:  movi    ix,0c6h
        movb    mc,[gc].43h
        addb    mc,[gc].43h
        movb    [ga].0bh,mc
        movbi   [ga].0ch,0h
        mov     [gc].4ch,ga
x1043:  mov     [gc].vhw+wdc08,mc
        jnzb    [gc].0b9h,x1052
        lcall   [ga].12h,x1698
        jmp     x1057

x1052:  lcall   [ga].12h,x1646
x1057:  ljnz    bc,x10a6
        jnz     [gb].4h,x1063
        jz      [gb].6h,x1069
x1063:  incb    [ga].0ch
        jmp     x1094

x1069:  jnzb    [ga].0dh,x1094
        jnbt    [gc].vhw+rdc00,s00_timeout,x1078
        setb    [gc].30h,4
        ljmp    x13ce

x1078:  incb    [ga].0dh
        not     bc,[gc].3eh
        inc     bc
        add     bc,[gb]
        jnz     bc,x10b3
        notb    bc,[gc].40h
        inc     bc
        addb    bc,[gb].2h
        jz      bc,x1043
        ljmp    x1419

x1094:  decb    [ga].0bh
        jnzb    [ga].0bh,x1043
        jnzb    [ga].0ch,x111c
        setb    [gc].30h,4
        ljmp    x13ce

x10a6:  lcall   [ga].0fh,x11fc
        ljz     bc,x143b
        ljmp    x102f

x10b3:  mov     ix,[ga].3h
        andi    bc,0fffh
        jz      bc,x10e1
        mov     mc,[gc].3eh
        andi    mc,0fffh
        setb    [gc].31h,6
        addbi   ga,12h
        lcall   [ga],x1e20
        addbi   ga,0ffeeh
        decb    [gc].0bdh
        ljzb    [gc].0bdh,x1419
        ljnz    bc,x1007
        ljmp    x1419

x10e1:  jbt     [gb].1h,7,x110a
x10e5:  movb    bc,[gc].3fh
        movb    [ga].2h,[gb].1h
        andbi   bc,40h
        andbi   [ga].2h,40h
        addb    [ga].2h,bc
        jnbt    [ga].2h,6,x1103
        setb    [gc].2fh,6
        ljmp    x13ce

x1103:  setb    [gc].30h,0
        ljmp    x13ce

x110a:  addbi   ga,12h
        lcall   [ga],x1e57
        addbi   ga,0ffeeh
        ljnz    bc,x1007
        ljmp    x13ce

x111c:  movbi   [ga].0ch,0h
x1120:  movbi   [ga].0bh,0h
        movbi   mc,0ffffh
        movb    [ga].0dh,[gc].43h
        movbi   [gc].3ah,0h
        lcall   [ga].12h,x1252
x1136:  mov     [gc].vhw+wdc08,mc
        jnzb    [gc].0b9h,x1145
        lcall   [ga].12h,x1698
        jmp     x114a

x1145:  lcall   [ga].12h,x1646
x114a:  ljnz    bc,x11d6
        jnz     [gb].4h,x1156
        jz      [gb].6h,x1163
x1156:  notb    bc,[ga].0bh
        addb    bc,[ga].0ch
        andi    bc,8000h
        jnz     bc,x1177
x1163:  incb    [ga].0bh
        decb    [ga].0dh
        jnzb    [ga].0dh,x1136
        setb    [gc].30h,4
        setb    [gc].31h,4
        ljmp    x13ce

x1177:  movb    [ga].0ch,[ga].0bh
        lcall   [ga].12h,x1252
x1182:  jzb     [ga].0ch,x11a0
        movbi   mc,0ffffh
        jnzb    [gc].0b9h,x1195
        lcall   [ga].12h,x1698
        jmp     x119a

x1195:  lcall   [ga].12h,x1646
x119a:  decb    [ga].0ch
        jmp     x1182

x11a0:  movbi   mc,0h
        jnzb    [gc].0b9h,x11af
        lcall   [ga].12h,x1698
        jmp     x11b4

x11af:  lcall   [ga].12h,x1646
x11b4:  addbi   ga,12h
        lcall   [ga],x2daf
        jz      bc,x11e5
        addbi   ga,0ffeeh
        not     bc,[gc].3eh
        inc     bc
        add     bc,[gb]
        jnz     bc,x11ef
        not     bc,[gc].40h
        inc     bc
        add     bc,[gb].2h
        jnz     bc,x11ef
x11d6:  setb    [gc].31h,4
        lcall   [ga].0fh,x11fc
        jnz     bc,x1177
        ljmp    x1441

x11e5:  lcall   [ga],x1a77
        addbi   ga,0ffeeh
        jnz     bc,x1177
x11ef:  movb    [ga].0ch,[ga].0bh
        incb    [ga].0ch
        ljmp    x1120

x11fc:  add     gb,[gc].46h
        addbi   gb,8h
        movbi   bc,0h
        jnz     [gb],x120c
        jz      [gb].2h,x124f
x120c:  setb    [gc].31h,3
        not     bc,[ga].7h
        inc     bc
        add     bc,[gb]
        jnz     bc,x1232
        not     bc,[ga].9h
        inc     bc
        add     bc,[gb].2h
        jnz     bc,x1232
        addbi   ga,12h
        lcall   [ga],x2db9
        addbi   ga,0ffeeh
        ljnz    bc,x1441
x1232:  mov     [ga].7h,[gb]
        mov     [ga].9h,[gb].2h
        movi    gb,4008h
        addbi   ga,12h
        lcall   [ga],x1a77
        addbi   ga,0ffeeh
        ljz     bc,x13ce
x124f:  mov     tp,[ga].0fh

x1252:  movi    bc,2260h
x1256:  mov     [gc].vhw+wdc08,bc
        jbt     [gc].0c7h,7,x1256
x125d:  dec     bc
        jz      bc,x1269
        jnbt    [gc].0c7h,7,x125d
        mov     tp,[ga].12h

x1269:  setb    [gc].30h,2
        ljmp    x13ce

x1270:  addbi   ga,7h
        lcall   [ga],x2700
        ljz     bc,x14b8
        movbi   bc,6h
        jnbt    [gc].iopb+iopb_modifier,2,x1285	; read/write deleted data
        movbi   bc,0ch
x1285:  lcall   [ga],x12d7
        ljz     bc,x14b8
        movi    ga,4010h
        add     ga,[gc].46h
        inc     ix
        jnbt    [gc],1,x12b8
        jmp     x129c

x129c:  movb    [gb].2h,[gc].4eh
        movi    gc,isbx_218a_ch0+fdc_data
x12a6:  movi    mc,0fff0h
        jmce    [gb],x12c6
        movi    mc,0ffd0h
        jmcne   [gb],x12a6
        ljmp    x14a9

x12b8:  movb    [gb].2h,[gc].4eh
        movi    gc,isbx_218a_ch0+fdc_data
x12c2:  ljnbt   [gb],7,x12c2
x12c6:  movb    [ga+ix+],[gc]
        ljz     ix,x14a9
x12ce:  jbt     [gb],7,x12c6
        jbt     [gb],7,x12c6
        jmp     x12ce

x12d7:  movi    gb,isbx_218a_ch0
        orb     bc,[gc].3ch
        movb    [gb].fdc_data,bc
        movi    mc,0ff90h
        movbi   bc,0ffffh
        movi    [ga].3h,702h
x12ed:  movb    ix,[gc].3dh
        decb    [ga].4h
        inc     gc
        decb    [ga].3h
        jnzb    [ga].3h,x12fe
        inc     gc
x12fe:  jmce    [gb],x1310	; FDC status
        dec     bc
        jnz     bc,x12fe
        movi    gc,var_base
        setb    [gc].31h,5
        jmp     x1335

x1310:  movb    [gb].2h,ix
        jnzb    [ga].4h,x12ed
        movi    gc,var_base
        mov     [gc].4ch,ga
        movbi   [gc].4eh,0ffffh
        not     ix,[gc].46h
        jnzb    [gc].42h,x1335
        movbi   [gc].4eh,0ff80h
x132d:  jmce    [gb],x1335	; FDC status
        dec     bc
        jnz     bc,x132d
x1335:  mov     tp,[ga]

x1337:  mov     [ga].3h,ix
        ljbt    [gc],0,x1447
        wid     16,16
        movbi   [gc].0bdh,3h
x1344:  movi    ix,0c6h
        mov     [gc].4ch,ga
        movb    mc,[gc].43h
        addb    mc,[gc].43h
        inc     mc
        movb    [ga].7h,mc
        movbi   bc,0fff1h
        addb    bc,[gc].0b8h
        jnz     bc,x1365
        mov     [gc].0c8h,[gc].5eh
x1365:  movi    [ga].8h,0h
        jnbt    [gc].1h,0,x1373
        movi    [gc].0c8h,140h
x1373:  mov     [gc].vhw+wdc08,mc
        movi    cc,cc_ga_port_to_gb_mem
        jnzb    [gc].0b9h,x1386
        lcall   [ga].10h,x177a
        jmp     x138b

x1386:  lcall   [ga].10h,x1724
x138b:  ljnz    bc,x143b
        jnz     [gb].4h,x1397
        jz      [gb].6h,x139d
x1397:  incb    [ga].8h
        jmp     x13bd

x139d:  jnzb    [ga].9h,x13bd
        jbt     [gc].vhw+rdc00,s00_timeout,x13c4
        incb    [ga].9h
        not     bc,[gc].3eh
        inc     bc
        add     bc,[gb]
        jnz     bc,x13e5
        notb    bc,[gc].40h
        inc     bc
        addb    bc,[gb].2h
        jnz     bc,x1419
x13bd:  decb    [ga].7h
        jnzb    [ga].7h,x1373
x13c4:  setb    [gc].30h,4
        jzb     [ga].8h,x13ce
        setb    [gc].31h,4
x13ce:  movbi   bc,0h
x13d1:  movi    gb,4008h
        mov     [gc].36h,[gb]
        mov     [gc].38h,[gb].2h
        mov     ix,[ga].3h
        mov     tp,[ga]

x13e5:  andi    bc,0fffh
        jz      bc,x1411
        mov     mc,[gc].3eh
        andi    mc,0fffh
        mov     ix,[ga].3h
        setb    [gc].31h,6
        addbi   ga,10h
        lcall   [ga],x1e20
        addbi   ga,0fff0h
        decb    [gc].0bdh
        jzb     [gc].0bdh,x1419
        ljnz    bc,x1344
        jmp     x1419

x1411:  jbt     [gb].1h,7,x141f
        ljmp    x10e5

x1419:  setb    [gc].31h,6
        jmp     x13ce

x141f:  mov     ix,[ga].3h
        addbi   ga,10h
        lcall   [ga],x1a03
        lcall   [ga],x1e57
        lcall   [ga],x1984
        addbi   ga,0fff0h
        ljnz    bc,x1344
        jmp     x13ce

x143b:  movbi   bc,0ffffh
        jmp     x13d1

x1441:  movbi   bc,0ffffh
        jmp     x13d1

x1447:  addbi   ga,7h
        lcall   [ga],x2700
        jz      bc,x14b8
        movbi   bc,5h
        jnbt    [gc].iopb+iopb_modifier,2,x145b	; read/write deleted data
        movbi   bc,9h
x145b:  lcall   [ga],x12d7
        jz      bc,x14b8
        movi    ga,4011h
        add     ga,[gc].46h
        movb    bc,[ga+ix+]
        jnbt    [gc],1,x1495
        movb    [gb].2h,[gc].4eh
        movi    gc,isbx_218a_ch0+2
x1478:  movi    mc,0ffb0h
        jmce    [gb],x148a
        movi    mc,0ffd0h
        jmcne   [gb],x1478
        ljmp    x14a9

x148a:  movb    [gc],bc
        movb    bc,[ga+ix+]
        jnz     ix,x1478
        ljmp    x14a9

x1495:  movb    [gb].2h,[gc].4eh
        movi    gc,isbx_218a_ch0+2
x149f:  jnbt    [gb],7,x149f
        movb    [gc],bc
        movb    bc,[ga+ix+]
        jnz     ix,x149f
x14a9:  movi    gc,var_base
        movbi   [gc].vhw+wdc18,2h
        mov     ga,[gc].4ch
        lcall   [ga],x14df
x14b8:  addbi   ga,0fff9h
        ljmp    x13d1

x14bf:  movbi   cc,1h
x14c2:  jmcne   [gb],x14c8
        mov     tp,[ga].0fh

x14c8:  inc     cc
        jnz     cc,x14c2
        movi    gc,var_base
        setb    [gc].31h,5
        setb    [gc].30h,4
        lcall   [ga].19h,x2971
        mov     tp,[ga].0fh

x14df:  mov     [ga].0ah,ix
        movbi   [gc].vhw+wdc18,0h
        movi    mc,0ffd0h
        movbi   bc,7h
        movbi   ix,2h
        movi    gc,7f30h
x14f4:  call    [ga].0fh,x14bf
        ljz     cc,x158a
        movb    [ga+ix],[gb].2h
        movb    [gc+ix+],[ga+ix]
        dec     bc
        jnz     bc,x14f4
        dec     bc
        movi    gc,var_base
        movb    ix,[ga].8h
        movi    gb,x3beb
        movb    [ga].9h,[gb+ix]
        movi    gb,4008h
        movb    [gb].1h,[ga].9h
        movb    [gb],[ga].5h
        mov     [gb].2h,[ga].6h
        jbt     [ga].2h,7,x1539
        jnbt    [ga].2h,6,x1572
x1539:  jnbt    [ga].4h,4,x1543
        setb    [gc].31h,6
        jmp     x1572

x1543:  jnbt    [ga].3h,5,x1557
        jnbt    [ga].4h,5,x1551
        setb    [gc].31h,3
        jmp     x1572

x1551:  setb    [gc].31h,4
        jmp     x1572

x1557:  jbt     [ga].3h,0,x155f
        jnbt    [ga].3h,2,x1565
x155f:  setb    [gc].30h,4
        jmp     x1572

x1565:  jnbt    [ga].2h,3,x156f
        setb    [gc].30h,6
        jmp     x1572

x156f:  setb    [gc].31h,5
x1572:  movb    mc,[gc].1bh
        addi    mc,0fffdh
        jz      mc,x158a
        notb    mc,[ga].8h
        inc     mc
        addb    mc,[gc].42h
        jz      mc,x158a
        setb    [gc].30h,0
x158a:  mov     ix,[ga].0ah
        movi    gc,var_base
        jnz     [gc].2fh,x1599
        jzb     [gc].31h,x159c
x1599:  movbi   bc,0h
x159c:  mov     tp,[ga]

x159e:  addbi   ga,4h
        lcall   [ga],x1a03
        jbt     [gc],0,x15ff
        wid     16,16
        movi    cc,cc_ga_port_to_gb_mem_extt
        movbi   mc,0fff1h
        addb    mc,[gc].0b8h
        jnz     mc,x15bd
        mov     [gc].0c8h,[gc].5eh
x15bd:  movbi   mc,0h
        mov     [gc].4ch,ga
x15c3:  jnzb    [gc].0b9h,x15cf
        lcall   [ga].12h,x1698
        jmp     x15d4

x15cf:  lcall   [ga].12h,x1646
x15d4:  jnz     [gb].4h,x15f0
        jnz     [gb].6h,x15f0
        mov     [gb].8h,[gb]
        mov     [gb].0ah,[gb].2h
        addbi   gb,8h
        movbi   bc,0ffffh
        jmp     x15fa

x15f0:  lcall   [ga],x1a77
        setb    [gc].31h,4
        jnz     bc,x15c3
x15fa:  addbi   ga,0fffch
        mov     tp,[ga]

x15ff:  movi    gb,7fdeh
        jnbt    [gb+ix],6,x1609
        setb    [gc].3ch,6
x1609:  lcall   [ga].19h,x2971
        movbi   bc,0ah
        orb     bc,[gc].3ch
        movb    [gb].2h,bc
        movi    mc,0ff90h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].3dh
        lcall   [ga],x14df
        mov     [gc].36h,[gb]
        mov     [gc].38h,[gb].2h
        mov     [gb].8h,[gb]
        mov     [gb].0ah,[gb].2h
        addbi   gb,8h
        jmp     x15fa

x1646:  movi    gb,4008h
x164a:  mov     [gc].vhw+wdc30,[gc].3eh
        mov     [gc].vhw+wdc38,[gc].40h
        movi    ga,dc_reg_base+dc_data
        movbi   bc,8h
        movbi   [gc].vhw+wdc00,6h
        xfer    
        jz      mc,x1684
        dec     mc
        tsl     [gc+ix],2h,x1677
        movi    bc,410h
        xfer    
        nop     
x1674:  movbi   bc,0ffffh
x1677:  mov     ga,[gc].4ch
        movi    gb,4008h
        mov     tp,[ga].12h

        jmp     x1684

x1684:  inc     bc
        movbi   [gc].vhw+wdc00,2h
        movi    bc,410h
        xfer    
        nop     
        jmp     x1674

        jmp     x1698

x1698:  movi    gb,4008h
x169c:  movb    [gc].4fh,mc
        movbi   bc,8h
        movi    ga,dc_reg_base+dc_data
        movbi   [gc].4eh,0h
        ljz     mc,x1700
x16ae:  mov     [gc].vhw+wdc30,[gc].3eh
        mov     [gc].vhw+wdc38,[gc].40h
        xfer    
        movi    [gc].vhw+wdc00,6h
        tsl     [gc].vhw+rdc00,s00_seek_complete,x16e4
        movi    bc,410h
        xfer    
        nop     
x16ce:  movbi   bc,0ffffh
x16d1:  mov     ga,[gc].4ch
        movi    gb,4008h
        movb    mc,[gc].4fh
        mov     tp,[ga].12h

x16de:  movbi   bc,0h
        jmp     x16d1

x16e4:  jnbt    [gc].vhw+rdc00,s00_data_sync,x16de
x16e8:  movi    gc,var_base
        jnzb    [gc].4eh,x16de
        movbi   bc,8h
        addbi   gb,0fff8h
        mov     [gc].vhw+wdc08,mc
        incb    [gc].4eh
        jnzb    [gc].4fh,x16ae
x1700:  movi    gc,dc_reg_base+wdc00
        movbi   [gc],6h
        xfer    
        movbi   mc,2h
        ljbt    [gc],3,x16e8	; rdc00
        mov     [gc],mc		; wdc00
        movi    bc,410h
        xfer    
        nop     
        movi    gc,var_base
        jmp     x16ce

        jmp     x1724

x1724:  movi    gb,4008h
        mov     [gc].vhw+wdc30,[gc].3eh
        mov     [gc].vhw+wdc38,[gc].40h
        movi    ga,dc_reg_base+dc_data
        movi    [gc].vhw+dc_data,19h
        movbi   bc,8h
        movbi   [gc].vhw+wdc00,6h
        xfer    
        nop     
        tsl     [gc+ix],1h,x1757
        movi    cc,cc_gb_mem_to_ga_port_extt
        xfer    
        nop     
        movbi   bc,0ffffh
x1757:  mov     ga,[gc].4ch
        movi    gb,4008h
        mov     tp,[ga].10h

x1761:  addbi   ga,3h
        lcall   [ga],x2700
        jnbt    [gc].52h,3,x1772
        setb    [gc].30h,7
        movbi   bc,0h
x1772:  addbi   ga,0fffdh
        mov     tp,[ga]

        jmp     x177a

x177a:  movi    gb,4008h
        mov     [gc].vhw+wdc30,[gc].3eh
        mov     [gc].vhw+wdc38,[gc].40h
        movbi   bc,8h
        movi    ga,dc_reg_base+dc_data
        movbi   [gc].4eh,0h
x1795:  movi    [gc].vhw+dc_data,0a1d9h
        xfer    
        movbi   [gc].vhw+wdc00,6h
        tsl     [gc+ix],1h,x17b9
        movi    cc,cc_gb_mem_to_ga_port_extt
        xfer    
        nop     
        movbi   bc,0ffffh
x17af:  mov     ga,[gc].4ch
        movi    gb,4008h
        mov     tp,[ga].10h

x17b9:  jnbt    [gc].vhw+rdc00,s00_data_sync,x17d0
        jnzb    [gc].4eh,x17d0
        addbi   bc,8h
        addbi   gb,0fff8h
        mov     [gc].vhw+wdc08,mc
        incb    [gc].4eh
        jmp     x1795

x17d0:  movbi   bc,0h
        jmp     x17af

x17d6:  mov     [gc].4ch,ga
        ljbt    [gc],0,x192e
        mov     [gc].4eh,gb
        lcall   [ga].0fh,x1a2f
        movbi   [gc].vhw+counter_mode,3ah
        movbi   [gc].vhw+counter_2,2h
        movb    [gc].vhw+counter_2,cc
        jbt     [gc].vhw+rdc08,s08_vendor,x180c
        movb    [gc].vhw+counter_0,cc
        movb    [gc].vhw+counter_0,cc
        movbi   gb,0fff1h
        addb    gb,[gc].0b8h
        jnz     gb,x1843
        mov     [gc].0c8h,[gc].5eh
        jmp     x1843

x180c:  jnzb    [gc].0b9h,x1821
        movi    gb,197ah
        movb    [gc].vhw+counter_0,[gb+ix+]
        movb    [gc].vhw+counter_0,[gb+ix]
        jmp     x1843

x1821:  jnzb    [gc].0bah,x182b
        movb    ix,[gc].0c3h
        jmp     x1834

x182b:  movi    gb,195ah
        addb    gb,[gc].0b8h
        movb    ix,[gb]
x1834:  add     [ga].19h,ix
        movb    [gc].vhw+counter_0,[ga].19h
        movb    [gc].vhw+counter_0,[ga].1ah
x1843:  jnzb    [gc].0bah,x1850
        movb    [gc].vhw+counter_1,[gc].0c4h
        jmp     x185c

x1850:  movi    gb,196ah
        addb    gb,[gc].0b8h
        movb    [gc].vhw+counter_1,[gb]
x185c:  movb    [gc].vhw+counter_1,cc
        movi    gb,441ah
        movbi   ix,0h
        mov     [gb+ix+],[gc].3eh
        movb    [gb+ix+],[gc].40h
        movb    [gb+ix+],cc
        mov     [gb+ix+],cc
        jnzb    [gc].0b9h,x1895
        mov     [gb+ix+],cc
        mov     [gb+ix+],cc
        movi    [gb+ix+],4e4eh
        movi    cc,cc_gb_mem_to_ga_port_extt_no_bc
        movi    [gc].vhw+dc_data,0a119h
        jnbt    [gc].1h,0,x189e
        movi    [gc].0c8h,140h
        jmp     x189e

x1895:  movi    cc,cc_gb_mem_to_ga_port_extt
        movi    [gc].vhw+dc_data,19h
x189e:  lcall   [ga].12h,x1252
        jz      bc,x1923
x18a6:  mov     [gc].vhw+wdc08,bc
        jbt     [gc].0c7h,7,x18a6
        orbi    [gc].wdc18_shadow,0c0h
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        movbi   [gc].vhw+wdc00,1h
        movbi   bc,6h
        jnbt    [gc].vhw+rdc08,s08_vendor,x18c9
        mov     [gc].vhw+wdc08,mc
x18c5:  jnbt    [gc].0c7h,7,x18c5
x18c9:  movi    ga,dc_reg_base+dc_data
        movi    gb,441ah
        jnbt    [gc].vhw+rdc08,s08_vendor,x18d8
        mov     [gc].vhw+wdc30,mc
x18d8:  xfer    
        nop     
        inc     [gc].4eh
        mov     gb,[gc].4eh
        movb    ix,[gb]
        jz      ix,x1909
        movi    gb,441ah
        movb    [gb].3h,ix
        movbi   bc,6h
        jnzb    [gc].0b9h,x18fd
        movi    [gc].vhw+dc_data,0a119h
        jmp     x1902

x18fd:  movi    [gc].vhw+dc_data,19h
x1902:  movbi   [gc].vhw+wdc00,1h
        jmp     x18d8

x1909:  clr     [gc].wdc18_shadow,6
        jnbt    [gc].vhw+rdc08,s08_vendor,x1916
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
x1916:  clr     [gc].wdc18_shadow,7
        movbi   bc,0ffffh
        mov     [gc].vhw+wdc08,mc
x191f:  jnbt    [gc].0c7h,7,x191f
x1923:  movb    [gc].vhw+wdc18,[gc].wdc18_shadow
x1929:  mov     ga,[gc].4ch
        mov     tp,[ga]

x192e:  movi    ga,x194a
        movb    ix,[gc].42h
        jnbt    [gc],1,x193b
        addbi   ga,8h
x193b:  jnbt    [gc].3ch,6,x1942
        addbi   ga,4h
x1942:  movb    [gc].44h,[ga+ix]
        jmp     x1929

x194a:  db      1bh
        db      2ah
        db      3ah
        db	00h
	db	00h
        db      36h
        db      54h
        db      74h
        db      18h
	db	26h
	db	87h
        db      0ffh
        db      0h
        db      32h
        db      50h
        db      0f0h
        db      0ffh
        db      0ffh
        db      19h
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      4h
        db      10h
        db      7h
        db      7h
        db      8h
        db      2h
        db      3h
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      5h
        db      5h
        db      4h
        db      54h
        db      0h
        db      98h
        db      0h
        db      1fh
        db      1h
        db      2fh
        db      2h
        db      2fh
	db	02h

x1984:  mov     [ga].03h,ix
        jbt     [gc],0,x19c7
        lcall   [ga].0fh,x1a2f
        movbi   [gc].vhw+counter_mode,32h
        movbi   [gc].vhw+counter_0,1h
        movb    [gc].vhw+counter_0,cc
        movb    [gc].vhw+counter_2,[ga].19h
        movb    [gc].vhw+counter_2,[ga].1ah
        jnzb    [gc].0bah,x19b3
        movb    [gc].vhw+counter_1,[gc].0c5h
        jmp     x19bf

x19b3:  movi    gb,19f3h
        addb    gb,[gc].0b8h
        movb    [gc].vhw+counter_1,[gb]
x19bf:  movb    [gc].vhw+counter_1,cc
x19c2:  mov     ix,[ga].3h
        mov     tp,[ga]

x19c7:  movi    gb,x19e3
        movb    ix,[gc].42h
        jnbt    [gc],1,x19d4
        addbi   gb,8h
x19d4:  jnbt    [gc].3ch,6,x19db
        addbi   gb,4h
x19db:  movb    [gc].44h,[gb+ix]
        jmp     x19c2

x19e3:  db      7h
        db      0eh
        db      1bh
        db	00h
	db	00h
        db      0fh
        db      1bh
        db      35h
        db      10h
        db      12h
        db      46h
        db      0c8h
        db      0h
        db      20h
        db      2ah
        db      80h
        db      0ch
        db      0bh
        db      0eh
        db      0fh
        db      11h
        db      0ah
        db      0dh
        db	00h
	db	00h
        db	00h
	db	00h
        db	00h
	db	00h
        db      0bh
        db      0ah
        db      0ch

x1a03:  mov     [ga].3h,ix
        jbt     [gc],0,x19c7
        lcall   [ga].0fh,x1a2f
        movbi   [gc].vhw+counter_mode,32h
        movbi   [gc].vhw+counter_0,1h
        movb    [gc].vhw+counter_0,cc
        addi    [ga].19h,0fffeh
        movb    [gc].vhw+counter_2,[ga].19h
        movb    [gc].vhw+counter_2,[ga].1ah
        mov     ix,[ga].3h
        mov     tp,[ga]

x1a2f:  movb    ix,[gc].47h
        addb    ix,[gc].47h
        movi    gb,x1a44
        mov     [ga].19h,[gb+ix]
        movbi   cc,0h
        mov     tp,[ga].0fh

x1a44:	dw	40h,80h,100h,0h,200h

x1a4e:	mov     [ga].05h,ix
        movbi   cc,0h
        mov     ix,[gc].46h
        movi    gb,4010h
        mov     [gb+ix+],cc
        mov     [gb+ix+],cc
        jnzb    [gc].0b9h,x1a6e
        movi    [gb+ix+],4e4eh
        movi    [gb+ix+],4e4eh
        jmp     x1a72

x1a6e:  mov     [gb+ix+],cc
        mov     [gb+ix+],cc
x1a72:  mov     ix,[ga].5h
        mov     tp,[ga]

x1a77:  addbi   ga,5h
        movbi   bc,0h
        jbt     [gc].iopb+iopb_modifier,1,x1aa1	; inhibit retries
        jnzb    [gc].3ah,x1a8b
        mov     [gc].58h,bc
        mov     [gc].56h,bc
x1a8b:  movbi   bc,0fffdh
        jzb     [gc].0b7h,x1aa6
x1a92:  addb    bc,[gc].3ah
        jz      bc,x1aa1
x1a98:  movbi   bc,0ffffh
        incb    [gc].3ah
        incb    [gc].56h
x1aa1:  addbi   ga,0fffbh
        mov     tp,[ga]

x1aa6:  jnbt    [gc].1h,5,x1ab1
        jnbt    [gc].1h,6,x1ab8
        jmp     x1a92

x1ab1:  movbi   bc,0fff7h
        jbt     [gc].1h,6,x1abb
x1ab8:  movbi   bc,0ffe5h
x1abb:  addb    bc,[gc].3ah
        jz      bc,x1aa1
        movbi   bc,0fffdh
        addb    bc,[gc].56h
        jnz     bc,x1aeb
        movb    [gc].56h,bc
        incb    [gc].58h
        movbi   bc,0fffdh
        addb    bc,[gc].58h
        jnz     bc,x1aeb
        movb    [gc].58h,bc
        incb    [gc].59h
        movbi   bc,0fffdh
        addb    bc,[gc].59h
        jnz     bc,x1aeb
        jmp     x1aa1

x1aeb:  jbt     [gc].1h,6,x1b0d
        movi    gb,x1b59
        addb    gb,[gc].58h
        movb    [ga].1h,[gb]
        movbi   [ga],53h
        lcall   [ga].2h,x2235
        jnz     bc,x1b0d
        jnbt    [gc].5ch,0,x1aa1
        setb    [gc].1h,6
x1b0d:  movbi   [gc].57h,3h
        ljbt    [gc].1h,5,x1a98
x1b16:  movi    gb,1b5ch
        jbt     [gc].1h,6,x1b24
        addb    gb,[gc].59h
        jmp     x1b27

x1b24:  addb    gb,[gc].58h
x1b27:  movb    [ga].1h,[gb]
        movbi   [ga],54h
        lcall   [ga].2h,x2235
        jnz     bc,x1b42
        jnbt    [gc].5ch,0,x1b4a
        setb    [gc].1h,5
        ljmp    x1a98

x1b42:  lcall   [ga],x28d8
        ljnz    bc,x1a98
x1b4a:  decb    [gc].57h
        jnzb    [gc].57h,x1b16
        ljmp    x1aa1

        ljmp    x1a98

x1b59:  db	00h
	db	80h
	db	0c0h
	db	00h
        db      80h
        db      0c0h

	fill	1d00h,0ffh

x1d00:  addbi   ga,6h
        lcall   [ga],x1def
        mov     [gc].32h,[gc].1eh
        mov     [gc].34h,[gc].20h
        andi    [gc].32h,0fffh
        lcall   [ga],x205e
        lcall   [ga],x2001
        jnz     bc,x1d34
        lcall   [ga],x20ba
        jz      bc,x1d42
        lcall   [ga],x2bc3
        movbi   bc,0h
        jmp     x1d42

x1d34:  lcall   [ga],x200a
        jz      bc,x1d42
        lcall   [ga],x2037
        jnz     bc,x1d49
x1d42:  setb    [gc].30h,5
        ljmp    x1dea

x1d49:  movi    gb,7fdah
        jnbt    [gc],0,x1d63
        addbi   gb,4h
        movb    [gc].3ch,[gb+ix]
        andbi   [gc].3ch,40h
        jnbt    [gc].iopb+iopb_modifier,2,x1d63	; read/write deleted data
        setb    [gc].3ch,5
x1d63:  jnbt    [gb+ix],2,x1d70
        setb    [gc].2fh,5
        movbi   bc,0h
        ljmp    x1dea

x1d70:  lcall   [ga],x20ba
        ljz     bc,x1dea
        movb    mc,[gc].34h
        lcall   [ga],x21d8
        ljz     bc,x1dea
        mov     mc,[gc].32h
        lcall   [ga],x1e03
        jz      bc,x1dea
        lcall   [ga],x205e
        mov     [gc].46h,[gb].5h
        movb    [gc].43h,[gb].4h
        notb    mc,[gb].7h
        inc     mc
        add     mc,[gb].0h
        mov     [gc].48h,mc
        mov     [gc].4ah,[gb].0h
        movi    gb,7fdah
        jnbt    [gc],0,x1dcb
        addbi   gb,4h
        mov     [gc].48h,[gc].4ah
        movb    [gc].42h,[gc].47h
        jnbt    [gc].47h,2,x1dcb
        decb    [gc].42h
x1dcb:  dec     [gc].4ah
        mov     [gc].3eh,[gc].32h
        mov     [gc].40h,[gc].34h
        movb    [ga],[gc].47h
        movi    gb,x3beb
        addb    gb,[ga]
        movb    mc,[gb]
        orb     [gc].3fh,mc
x1dea:  addbi   ga,0fffah
        mov     tp,[ga]

x1def:  movbi   cc,0h
        mov     [gc].14h,cc
        mov     [gc].16h,cc
        mov     [gc].2fh,cc
        movb    [gc].31h,cc
        mov     [gc].3ah,cc
        mov     tp,[ga]

x1e03:  movbi   [gc].45h,0h
x1e07:  addbi   ga,8h
        lcall   [ga],x2a6b
        jz      bc,x1e18
        lcall   [ga],x2cd2
        jnz     bc,x1e1b
x1e18:  call    [ga],x1e20
x1e1b:  addbi   ga,0fff8h
        mov     tp,[ga]

x1e20:  addbi   ga,8h
        lcall   [ga].0fh,x208e
        jbt     [gb+ix],3,x1e4b
        movbi   cc,3h
x1e2e:  incb    [gc].3bh
        lcall   [ga],x2bc3
        jz      bc,x1e46
        lcall   [ga],x2a6b
        jz      bc,x1e46
        lcall   [ga],x2cd2
        jnz     bc,x1e52
x1e46:  dec     cc
        jnz     cc,x1e2e
x1e4b:  lcall   [ga],x2bc3
        movbi   bc,0h
x1e52:  addbi   ga,0fff8h
        mov     tp,[ga]

x1e57:  mov     [ga].8h,ix
        addbi   ga,0ah
        ljnzb   [gc].45h,x1ef1
        movi    cc,cc_ga_port_to_gb_mem_extt
        movb    [ga].2h,[gc].43h
        movb    bc,[ga].2h
        addb    [ga].2h,bc
        incb    [ga].2h
        mov     bc,[gc].46h
        addbi   bc,0ch
        not     bc
        inc     bc
        addi    bc,4008h
        mov     [ga],bc
        movbi   mc,0h
        mov     [gc].4ch,ga
x1e8b:  decb    [ga].2h
        jzb     [ga].2h,x1ef7
        mov     gb,[ga]
        jnzb    [gc].0b9h,x1ea0
        lcall   [ga].12h,x169c
        jmp     x1ea5

x1ea0:  lcall   [ga].12h,x164a
x1ea5:  movi    gb,4000h
        jnz     [gb].4h,x1e8b
        jnz     [gb].6h,x1e8b
        movb    ix,[gc].0b4h
        movi    mc,0f000h
        and     mc,[gc].3eh
        andi    [gb],0fffh
        or      mc,[gb]
        mov     [gc].3eh,mc
        movb    [gc].40h,[gb].2h
        setb    [gc].3fh,6
        not     mc,[gc].4ah
        add     [gb],mc
        jnbt    [gb].1h,7,x1eee
        movbi   [gc].45h,0ffffh
        movb    mc,[gc].40h
        lcall   [ga],x21d8
        jz      bc,x1efd
        mov     mc,[gc].3eh
        lcall   [ga],x1e07
        jmp     x1efd

x1eee:  setb    [gc].30h,5
x1ef1:  setb    [gc].2fh,6
        jmp     x1efa

x1ef7:  setb    [gc].30h,4
x1efa:  movbi   bc,0h
x1efd:  addbi   ga,0fff6h
        mov     ix,[ga].8h
        mov     tp,[ga]

x1f05:  addbi   ga,0ah
        lcall   [ga],x205e
        incb    [gc].35h
        incb    [gc].41h
        lcall   [ga],x2037
        ljnz    bc,x1f8f
        movbi   [gc].35h,0h
        movbi   [gc].41h,0h
        jnbt    [gc],0,x1f2b
        incb    [gc].35h
        incb    [gc].41h
x1f2b:  mov     [gc].4eh,gb
        jzb     [gc].45h,x1f4a
        mov     mc,[gc].32h
        lcall   [ga],x1e03
        jz      bc,x1f8f
        andi    [gc].3eh,3000h
        or      [gc].3eh,mc
        movb    [gc].40h,[gc].34h
x1f4a:  incb    [gc].34h
        incb    [gc].40h
        mov     gb,[gc].4eh
        lcall   [ga],x200a
        jz      bc,x1f61
        lcall   [ga],x21d8
        jmp     x1f8f

x1f61:  movbi   mc,0h
        movb    [gc].34h,mc
        movb    [gc].40h,mc
        lcall   [ga],x21d8
        inc     [gc].32h
        inc     [gc].3eh
        mov     mc,[gc].32h
        not     mc
        and     mc,[gc].48h
        jnz     mc,x1f88
        setb    [gc].2fh,7
        movbi   bc,0h
        jmp     x1f8f

x1f88:  mov     mc,[gc].32h
        lcall   [ga],x1e07
x1f8f:  addbi   ga,0fff6h
        mov     tp,[ga]

x1f94:  movb    [ga].3h,[gc].43h
        notb    [ga].3h
        incb    [ga].3h
        movb    [ga].5h,[ga].3h
        incb    [ga].5h
        movb    [ga].6h,[ga].3h
        movb    [ga].4h,ix
        movbi   ix,0h
x1fb5:  movb    [gb+ix+],cc
        incb    [ga].6h
        jnzb    [ga].6h,x1fb5
        movbi   bc,1h
        incb    [gb]
        movbi   ix,0h
x1fc6:  addb    ix,[ga].4h
x1fc9:  movb    [ga].6h,[ga].3h
        addb    [ga].6h,ix
        jbt     [ga].6h,7,x1fd9
        movb    ix,[ga].6h
x1fd9:  jzb     [gb+ix],x1fe1
        inc     ix
        jmp     x1fc9

x1fe1:  movb    [gb+ix],bc
        inc     bc
        jnbt    [gc],0,x1fea
        movb    [gb+ix],bc
x1fea:  incb    [ga].5h
        jnzb    [ga].5h,x1fc6
        movb    [gb],cc
        jnbt    [gc],0,x1ff8
        incb    [gb]
x1ff8:  movb    ix,[gc].43h
        mov     [gb+ix+],cc
        movb    [gb+ix],cc
        mov     tp,[ga]

x2001:  mov     mc,[gc].32h
        not     bc,[gb].0h
        jmp     x2046

x200a:  movb    mc,[gc].34h
        mov     [gc].0eh,ga
        jbt     [gc],0,x202e
        movi    ga,7fdah
        addb    ga,[gc].0b4h
        jnbt    [ga],7,x2024
        jbt     [gc].1ah,4,x202e
        jmp     x2028

x2024:  jzb     [gb].2h,x202e
x2028:  notb    bc,[gb].2h
        jmp     x2031

x202e:  notb    bc,[gb].3h
x2031:  mov     ga,[gc].0eh
        jmp     x2046

x2037:  movb    mc,[gc].35h
        notb    bc,[gb].4h
        jnbt    [gc],0,x2046
        jz      mc,x2059
        jmp     x2048

x2046:  inc     bc
x2048:  mov     [ga].4h,mc
        jbt     [ga].5h,7,x2059
        add     [ga].4h,bc
        movbi   bc,0ffffh
        jbt     [ga].5h,7,x205c
x2059:  movbi   bc,0h
x205c:  mov     tp,[ga]

x205e:  jnbt    [gc],2,x2068
        movi    gb,7fe2h
        jmp     x2072

x2068:  movi    gb,7f9ah
        jnbt    [gc],0,x2072
        addbi   gb,20h
x2072:  movb    [ga].3h,ix
x2075:  jz      ix,x2089
        jbt     [gc],2,x2081
        addbi   gb,8h
        jmp     x2084

x2081:  addbi   gb,1h
x2084:  dec     ix
        jmp     x2075

x2089:  movb    ix,[ga].3h
        mov     tp,[ga]

x208e:  movi    gb,7fdah
        jbt     [gc],2,x209e
        jnbt    [gc],0,x209b
        addbi   gb,4h
x209b:  mov     tp,[ga].0fh

x209e:  addi    gb,8h
        mov     tp,[ga].0fh

x20a5:  movi    gb,7ef0h
        jzb     [gc],x20af
        addbi   gb,8h
x20af:  mov     [ga].3h,ix
        add     gb,[ga].3h
        add     gb,[ga].3h
        mov     tp,[ga]

x20ba:  movb    [gc].0b4h,ix
        ljbt    [gc],0,x20d8
        jzb     [gc].0b7h,x20fa
        movi    gb,x21d4
        movb    [gc].vhw+wdc18,[gb+ix]
        movb    [gc].wdc18_shadow,[gb+ix]
x20d3:  movbi   bc,0ffffh
x20d6:  mov     tp,[ga]

x20d8:  movbi   bc,0h
        jbt     [gc].0dh,6,x20ec
        movbi   ix,0fff8h
x20e2:  movi    [gc+ix+],0h
        jnz     ix,x20e2
        movb    ix,[gc].0b4h
x20ec:  jbt     [gc].vhw+rdc08,s08_isbx_218a_present,x20d6
        andbi   [gc].3dh,4h
        orb     [gc].3dh,ix
        jmp     x20d3

x20fa:  movbi   [gc].51h,0h
x20fe:  movbi   bc,0ffffh
        movbi   ix,0h
        addbi   ga,5h
x2107:  movb    [gc].50h,ix
        jbt     [gc].51h,0,x2116
        movi    gb,7fdah
        ljnbt   [gb+ix],0,x219f
x2116:  movi    gb,x21d0
        movbi   [gc].vhw+wdc18,1h
        movb    [ga],[gb+ix]
        movbi   [ga].1h,0h
        movi    [gc].0c8h,48h
        mov     [gc].vhw+wdc10,[ga]
        movi    [gc].0c8h,58h
        jnbt    [gc].vhw+rdc08,s08_write_protected,x213c
        setb    [gc].51h,7
x213c:  movi    [gc].0c8h,48h
        movi    [gc].0c8h,40h
        ljbt    [gc].51h,2,x2183
        jnbt    [gc].51h,0,x2157
        jbt     [gc].51h,7,x219f
        lcall   [ga],x2700
x2157:  movb    gb,[gc].0b4h
        not     gb
        inc     gb
        addb    gb,[gc].50h
        movi    [ga],8040h
        jnz     gb,x2173
        jbt     [gc].51h,7,x21c3
        clr     [ga].1h,7
        orbi    [gc].51h,60h
x2173:  jbt     [gc].51h,7,x219f
        lcall   [ga].2h,x2235
        jnz     bc,x219f
        jnbt    [gc].51h,6,x219f
x2183:  movb    ix,[gc].0b4h
        jnbt    [gc].51h,0,x2193
        movi    [gc].2fh,0h
        movbi   [gc].31h,0h
x2193:  addbi   ga,0fffbh
        jbt     [gc].51h,5,x219d
        movbi   bc,0h
x219d:  mov     tp,[ga]

x219f:  andbi   [gc].51h,3fh
        addbi   [gc].50h,0fffdh
        jnzb    [gc].50h,x21b5
        setb    [gc].51h,2
        movb    ix,[gc].0b4h
        ljmp    x2116

x21b5:  inc     ix
        ljmp    x2107

x21bb:  movbi   [gc].51h,1h
        ljmp    x20fe

x21c3:  movbi   bc,0h
        jbt     [gc].3bh,7,x2183
        setb    [gc].31h,5
        jmp     x2183

x21d0:  db      1h
        db      2h
        db      4h
        db      8h

x21d4:  db      0h
        db      8h
        db      10h
        db      18h

x21d8:  addbi   ga,5h
        movbi   bc,0ffffh
        jbt     [gc],0,x2202
        movi    gb,x21ea
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x21ea:  dw      x21f2
        dw      x2210
        dw      x2210
        dw      x2219

x21f2:  movbi   [ga],44h
        movb    [ga].1h,mc
        lcall   [ga].2h,x2235
x21fd:  addbi   ga,0fffbh
        mov     tp,[ga]

x2202:  clr     [gc].3dh,2
        movb    [ga],mc
        jnbt    [ga],0,x21fd
        setb    [gc].3dh,2
        jmp     x21fd

x2210:  mov     [gc].vhw+wdc10,mc
        mov     [gc].5eh,mc
        jmp     x21fd

x2219:  mov     [ga],mc
        movi    [gc].5eh,1c0h
        jnbt    [ga],0,x2226
        setb    [gc].5eh,5
x2226:  jnbt    [ga],1,x222c
        setb    [gc].5eh,4
x222c:  jnbt    [ga],2,x2232
        setb    [gc].5fh,2
x2232:  jmp     x21fd

x2235:  movi    [gc].5ch,0h
        jnbt    [gc].0c7h,6,x2247
        setb    [gc].5ch,3
        jmp     x2247

x2244:  setb    [gc].5ch,1
x2247:  mov     [ga].4h,[ga]
        movbi   bc,0ffffh
        movbi   gb,0ffc0h
        addb    gb,[ga]
        jnz     gb,x225a
        setb    [gc].5ch,6
x225a:  movbi   [ga].6h,5dh
x225e:  jbt     [gc].vhw+rdc08,s08_track_zero,x22be
        dec     bc
        jnz     bc,x225e
        decb    [ga].6h
        jnzb    [ga].6h,x225e
        setb    [gc].31h,5
        ljmp    x2385

x2275:  movi    [gc].0c8h,40h
        movbi   [gc].vhw+wdc18,0h
        ljbt    [gc].1ch,1,x2385
        ljbt    [gc].5ch,1,x238c
        ljbt    [gc].5ch,6,x2385
        ljbt    [gc].5dh,0,x2385
        addbi   ga,7h
        lcall   [ga],x272a
        addbi   ga,0fff9h
        ljbt    [gc].5ch,7,x238c
        setb    [gc].5ch,7
        jbt     [gc].5ch,0,x22b7
        jbt     [gc].5ch,5,x22b7
        jbt     [gc].5ch,4,x22b7
        ljz     bc,x2385
        setb    [gc].5dh,0
x22b7:  andbi   [gc].5ch,0ffc8h
        jmp     x225a

x22be:  movbi   [gc].vhw+wdc18,1h
        movbi   bc,0ffffh
        movb    [ga],[ga].4h
        movi    [gc].0c8h,48h
        movbi   [ga].1h,0h
        mov     [gc].vhw+wdc10,[ga]
        addbi   [ga],0ffc0h
        movi    [gc].0c8h,248h
x22e0:  jnbt    [gc].vhw+rdc08,s08_write_protected,x22ec
        dec     bc
        jnz     bc,x22e0
        jmp     x2275

x22ec:  movi    [gc].0c8h,48h
x22f1:  jbt     [gc].vhw+rdc08,s08_write_protected,x22fe
        dec     bc
        jnz     bc,x22f1
        ljmp    x2275

x22fe:  jbt     [ga],7,x233b
        movb    [ga],[ga].5h
        mov     [gc].vhw+wdc10,[ga]
        movi    [gc].0c8h,448h
x2310:  jnbt    [gc].vhw+rdc08,s08_write_protected,x231d
        dec     bc
        jnz     bc,x2310
        ljmp    x2275

x231d:  movi    [gc].0c8h,48h
x2322:  ljbt    [gc].vhw+rdc08,s08_write_protected,x235b
        jnbt    [gc].5ch,3,x2332
        jbt     [gc].0c7h,6,x2332
        setb    [gc].5ch,2
x2332:  dec     bc
        jnz     bc,x2322
        ljmp    x2275

x233b:  movi    [gc].0c8h,40h
        movbi   [gc].vhw+wdc18,0h
        movi    [gc].0c8h,440h
x2349:  jnbt    [gc].vhw+rdc08,s08_write_protected,x2356
        dec     bc
        jnz     bc,x2349
        ljmp    x2275

x2356:  movb    [ga],[gc].vhw+rdc10
x235b:  movi    [gc].0c8h,40h
        movbi   [gc].vhw+wdc18,0h
x2364:  jbt     [gc].vhw+rdc08,s08_write_protected,x237c
        jnbt    [gc].5ch,3,x2373
        jbt     [gc].0c7h,6,x2373
        setb    [gc].5ch,2
x2373:  dec     bc
        jnz     bc,x2364
        ljmp    x2275

x237c:  jbt     [gc].5ch,1,x2385
        ljbt    [gc].5ch,2,x2275
x2385:  andbi   [gc].5ch,0fff9h
        mov     tp,[ga].2h

x238c:  movbi   bc,0h
        jmp     x2385

x2392:  addbi   ga,5h
        lcall   [ga],x289b
        jz      bc,x23bb
        movi    [gc].0c8h,1c8h
        setb    [gc].wdc18_shadow,0
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        clr     [gc].wdc18_shadow,0
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        movi    [gc].0c8h,1c0h
        movbi   bc,0ffffh
x23bb:  addbi   ga,0fffbh
        mov     tp,[ga]

x23c0:  addbi   ga,5h
        ljbt    [gc],0,x246a
        movb    [gc].43h,[gb].4h
        mov     [gc].46h,[gb].5h
        ljbt    [gc].1h,1,x2467
        movb    [gc].vhw+wdc08,mc
        jbt     [gc].vhw+rdc30,1,x23e2
        setb    [gc].0b8h,0
x23e2:  jbt     [gc].0c7h,5,x23e9
        setb    [gc].0b8h,1
x23e9:  jnbt    [gc].vhw+rdc30,4,x23f0
        setb    [gc].0b8h,2
x23f0:  jnbt    [gc].vhw+rdc30,5,x23f7
        setb    [gc].0b8h,3
x23f7:  movb    bc,[gc].0b8h
        addbi   bc,0fff2h
        movb    [gc].0b9h,bc
        addbi   bc,3h
        movb    [gc].0bah,bc
        addbi   bc,0fffeh
        movb    [gc].0b7h,bc
        jnzb    [gc].0bah,x241f
        movp    gb,[gc].iopb_ptr
        mov     [gc].0c2h,[gb].iopb_gen_addr
        mov     [gc].0c4h,[gb].iopb_gen_addr+2
x241f:  jbt     [gc].0b7h,7,x2429
        incb    [gc].0b7h
        jmp     x242d

x2429:  movbi   [gc].0b7h,0h
x242d:  movb    bc,[gc].0b7h
        addb    [gc].0b7h,bc
        jnzb    [gc].0b7h,x2467
        jbt     [gc].1h,1,x2467
        movbi   [gc].vhw+wdc18,18h
        movi    bc,3d09h
x2443:  dec     bc
        jnz     bc,x2443
        movb    [gc].vhw+wdc18,ix
        movbi   [ga],62h
x244e:  jnbt    [gc].0c7h,6,x2460
        dec     bc
        jnz     bc,x244e
        decb    [ga]
        jnzb    [ga],x244e
        ljmp    x255f

x2460:  movb    [gc].0b4h,ix
        lcall   [ga],x21bb
x2467:  setb    [gc].1h,1
x246a:  lcall   [ga],x20ba
        ljz     bc,x255f
        ljbt    [gc],0,x255b
        movi    gb,x247f
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x247f:  dw      x2487
        dw      x257f
        dw      x2564
        dw      x2593

x2487:  movi    [ga],8055h
        lcall   [ga].2h,x2235
        jnz     bc,x24a2
        jbt     [gc].5ch,4,x24aa
        ljnbt   [gc].5ch,0,x255f
        setb    [gc].1h,4
        jmp     x24aa

x24a2:  lcall   [ga],x28d8
        ljz     bc,x255f
x24aa:  movi    [ga],8041h
        lcall   [ga].2h,x2235
        ljz     bc,x255f
        jnzb    [gc].0bah,x24c1
        movb    gb,[gc].0c2h
        jmp     x24ca

x24c1:  movi    gb,x2585
        addb    gb,[gc].0b8h
        movb    gb,[gb]
x24ca:  add     gb,[gc].46h
        mov     [gc].56h,gb
        movbi   [ga],58h
        movb    [ga].1h,[gc].56h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x250d
        ljz     bc,x255f
        movbi   [ga],57h
        movb    [ga].1h,[gc].57h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x250d
        ljz     bc,x255f
        movi    [ga],56h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x250d
        ljz     bc,x255f
x250d:  decb    [gc].43h
        movbi   [ga],5bh
        movb    [ga].1h,[gc].43h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x2545
        jz      bc,x255f
        movi    [ga],5ah
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x2545
        jz      bc,x255f
        movi    [ga],59h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x2545
        jz      bc,x255f
x2545:  movbi   [ga],16h
        lcall   [ga].2h,x2235
        jbt     [gc].5ch,0,x255b
        jz      bc,x255f
        lcall   [ga],x28d8
        jz      bc,x255f
x255b:  lcall   [ga],x2700
x255f:  addbi   ga,0fffbh
        mov     tp,[ga]

x2564:  jnz     ix,x255b
        mov     gb,[gc].54h
        mov     [ga],[gb]
        movbi   bc,0fffeh
        movbi   mc,0h
x2574:  add     [ga],bc
        dec     mc
        jnbt    [ga].1h,7,x2574
        mov     [gc].5ch,mc
x257f:  setb    [gc].1h,4
        jmp     x255b

x2585:  db      0ffh
        db      5ah
        db      0ffh
        db      0ffh
        db      56h
        db      32h
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh
        db      0ffh

x2593:  movi    [gc].vhw+wdc10,0feh
        lcall   [ga],x2392
        jz      bc,x255f
        movbi   mc,12h
x25a2:  lcall   [ga],x28b5
        addbi   [ga].2h,0fff5h
        jzb     [ga].2h,x255b
        dec     bc
        jnz     bc,x25a2
        dec     mc
        jnz     mc,x25a2
        jmp     x255b

x25bb:  lcall   [ga],x1def
        mov     [gc].14h,[gc].26h
        jnbt    [gc].1h,4,x25cd
x25c9:  lcall   [ga],cmd_invalid	; does this return?

x25cd:  lcall   [ga],x20ba
        jz      bc,x25e1
        jzb     [gc].0b7h,x25e5
        movi    [gc].vhw+wdc10,0fdh
        lcall   [ga],x2392
x25e1:  ljmp    x00c5

x25e5:  movi    [ga],55h
        lcall   [ga].2h,x2235
        jnz     bc,x25e1
        jbt     [gc].5ch,0,x25c9
        jmp     x25e1

	fill	2700h,0ffh

x2700:  mov     [ga].3h,mc
        addbi   ga,9h
        movbi   bc,0ffffh
        movbi   [gc].52h,0h
        ljbt    [gc],0,x28fb
        movi    gb,x271a
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x271a:  dw      x2722
        dw      x2840
	dw	x2840
        dw      x2872

x2722:  movi    [gc].5ch,2h
        jmp     x2734

x272a:  mov     [ga].7h,mc
        addbi   ga,9h
        movbi   [gc].52h,0h
x2734:  ljbt    [gc].5ch,6,x282d
        jnbt    [gc].0c7h,6,x2743
        movbi   [ga],0fh
        jmp     x2746

x2743:  movbi   [ga],2h
x2746:  lcall   [ga].2h,x2244
x274b:  ljz     bc,x282a
        setb    [gc].52h,5
        clr     [ga],6
        ljzb    [ga],x282d
        jbt     [ga],7,x275e
        clr     [gc].52h,5
x275e:  jnbt    [gc].5ch,6,x2770
        andbi   [ga],1eh
        ljzb    [ga],x2838
        setb    [gc].52h,6
        ljmp    x27b7

x2770:  jnbt    [ga],0,x2781
        setb    [gc].52h,4
        ljbt    [gc].3bh,7,x282a
        setb    [gc].52h,0
        setb    [gc].30h,6
x2781:  ljbt    [gc].3bh,7,x282a
        jnbt    [ga],1,x279c
        setb    [gc].52h,6
        orbi    [gc].5ch,11h
        jbt     [ga],2,x279c
        jbt     [ga],3,x279c
        setb    [gc].31h,5
        clr     [gc].5ch,0
x279c:  jbt     [ga],4,x27d5
x279f:  jbt     [ga],5,x2812
x27a2:  andbi   [ga],0ch
        jzb     [ga],x27b7
        jnbt    [ga],3,x27ae
        setb    [gc].5ch,5
x27ae:  jnbt    [ga],2,x27b4
        setb    [gc].5ch,0
x27b4:  setb    [gc].52h,6
x27b7:  jbt     [gc].52h,7,x282a
        setb    [gc].52h,7
        jbt     [gc].52h,0,x282a
        jnbt    [gc].52h,6,x282d
        movbi   [ga],1h
        lcall   [ga].2h,x2244
        jz      bc,x282d
        ljmp    x274b

x27d5:  setb    [gc].52h,6
        addbi   ga,5h
        movbi   [ga],0eh
        lcall   [ga].2h,x2244
        addbi   ga,0fffbh
        jz      bc,x282a
        jzb     [ga].5h,x279f
        setb    [gc].52h,6
        jnbt    [ga].5h,0,x27f7
        setb    [gc].31h,7
x27f7:  jnbt    [ga].5h,5,x27fe
        setb    [gc].5ch,5
x27fe:  andbi   [ga].5h,1eh
        jnzb    [ga].5h,x280c
        setb    [gc].52h,2
        jmp     x279f

x280c:  setb    [gc].31h,5
        jmp     x279f

x2812:  addbi   ga,5h
        movbi   [ga],0dh
        lcall   [ga].2h,x2244
        jnbt    [ga],6,x2823
        setb    [gc].52h,3
x2823:  addbi   ga,0fffbh
        ljnz    bc,x27a2
x282a:  movbi   bc,0h
x282d:  jnbt    [gc].52h,6,x2838
        jbt     [gc].52h,2,x2838
        movbi   bc,0h
x2838:  addbi   ga,0fff7h
        mov     mc,[ga].3h
        mov     tp,[ga]

x2840:  jnbt    [gc].vhw+rdc00,s00_fault,x2854
        movi    [gc].0c8h,50h
        movi    [gc].0c8h,0h
        setb    [gc].31h,5
        movbi   bc,0h
x2854:  movi    bc,66d0h
x2858:  jnbt    [gc].vhw+rdc00,s00_ready,x286b
        dec     bc
        jnz     bc,x2858
x2861:  setb    [gc].30h,6
        movbi   bc,0h
        ljmp    x282d

x286b:  movbi   bc,0ffffh
        ljmp    x282d

x2872:  call    [ga],x289b
        jz      bc,x2861
        andbi   [ga].5h,0ffa4h
        jzb     [ga].5h,x2854
        setb    [gc].31h,5
        setb    [gc].52h,6
        movi    [gc].vhw+wdc10,0fah
        lcall   [ga],x2392
        jz      bc,x2861
        call    [ga],x289b
        jz      bc,x2861
        jmp     x2854

x289b:  addbi   ga,3h
        movbi   bc,0ffffh
x28a1:  call    [ga],x28b5
        jnbt    [ga].2h,4,x28b0
        dec     bc
        jnz     bc,x28a1
        setb    [gc].31h,5
x28b0:  addbi   ga,0fffdh
        mov     tp,[ga]

x28b5:  movbi   [gc].52h,0h
        movi    [gc].0c8h,3c0h
        movb    [ga].2h,[gc].vhw+rdc10
        movi    [gc].0c8h,1c0h
        notb    [ga].2h
        jnbt    [ga].2h,6,x28d3
        setb    [gc].52h,3
x28d3:  clr     [ga].2h,6
        mov     tp,[ga]

x28d8:  addbi   ga,5h
        movbi   [ga],40h
x28de:  jnbt    [gc].0c7h,6,x28f4
        dec     bc
        jnz     bc,x28de
        decb    [ga]
        jnzb    [ga],x28de
        setb    [gc].31h,5
x28ef:  addbi   ga,0fffbh
        mov     tp,[ga]

x28f4:  lcall   [ga],x2700
        jmp     x28ef

x28fb:  movi    gc,7f00h
        jnbt    [gc].3bh,2,x292d
        jnbt    [gc].16h,3,x292d
        jbt     [gc].47h,6,x292d
        movi    gb,isbx_218a_ch1
        jbt     [gb].fdc_latch_0,0,x2928
        movbi   [gb].fdc_latch_0,1h
        movbi   mc,3h
        movi    gb,1c00h
x291e:  dec     gb
        jnz     gb,x291e
        dec     mc
        jnz     mc,x291e
x2928:  movi    [gc].18h,0f704h
x292d:  movi    gc,var_base
        addbi   ga,19h
        lcall   [ga],x29af
        addbi   ga,0ffe7h
        ljz     bc,x2838
        movbi   [gb].2h,4h
        movi    mc,0f090h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].3dh
        movi    mc,0f0d0h
        lcall   [ga].19h,x299e
        movb    [ga].2h,[gb].2h
        jnbt    [ga].2h,6,x2968
        setb    [gc].52h,3
x2968:  ljbt    [ga].2h,5,x282d
        ljmp    x2861

x2971:  movi    gb,isbx_218a_ch0
        movbi   [ga].18h,7fh
        movi    mc,0f080h
        jnbt    [gb],4,x2998	; FDC status
        movbi   [gc].vhw+wdc18,2h
        movbi   [gc].vhw+wdc18,0h
x2988:  decb    [ga].18h
        jmce    [gb],x2998
        jnzb    [ga].18h,x2988
        movb    [ga].1bh,[gb].2h
x2998:  jmcne   [gb],x2988
        mov     tp,[ga].19h

x299e:  movbi   [gc].0bdh,3h
x29a2:  decb    [gc].0bdh
        jnzb    [gc].0bdh,x29a2
x29a9:  jmcne   [gb],x29a9
        mov     tp,[ga].19h

x29af:  addbi   ga,3h
        lcall   [ga].19h,x2971
        movbi   bc,0ffffh
x29ba:  movi    mc,0f080h
        lcall   [ga].19h,x299e
        movbi   [gb].2h,8h
        movi    mc,0c0c0h
        lcall   [ga].19h,x299e
        movb    [ga],[gb].2h
        movb    [ga].1h,[ga]
        movb    [ga].19h,[ga]
        addbi   [ga].19h,0ff80h
        jzb     [ga].19h,x2a3c
        movb    [ga].2h,[ga]
        andbi   [ga].2h,3h
        andbi   [ga].1h,0ffc0h
        jzb     [ga].1h,x2a10
        orbi    [ga].1h,3fh
        incb    [ga].1h
        jzb     [ga].1h,x2a4f
        movbi   bc,0h
        jbt     [gc].0dh,6,x2a3c
        setb    [gc].31h,5
        jmp     x2a3c

x2a10:  jbt     [ga],5,x2a20
        jbt     [gc].0dh,6,x2a2f
        setb    [gc].31h,7
        movbi   bc,0h
        jmp     x2a2f

x2a20:  movi    gb,7fdeh
        addb    gb,[ga].2h
        setb    [gb],7
        clr     [gb],2
        movi    gb,isbx_218a_ch0
x2a2f:  jnbt    [gb],6,x2a3c		; FDC status
        movb    [ga].3h,[gb].2h
        ljmp    x29ba

x2a3c:  jnbt    [gb],6,x2a42		; FDC status
        movb    mc,[gb].2h
x2a42:  ljzb    [ga].1h,x29ba
        movb    mc,[ga].3h
        addbi   ga,0fffdh
        mov     tp,[ga]

x2a4f:  movi    gb,7fdeh
        addb    gb,[ga].2h
        jnbt    [ga],3,x2a5e
        clr     [gb],1
        jmp     x2a64

x2a5e:  jbt     [gb],1,x2a64
        orbi    [gb],12h
x2a64:  movi    gb,isbx_218a_ch0
        jmp     x2a3c

x2a6b:  mov     [gc].58h,ix
        andi    mc,0fffh
        mov     [gc].56h,mc
        addbi   ga,7h
        lcall   [ga],x2700
        ljz     bc,x2ae9
        ljbt    [gc],0,x2b9c
        jzb     [gc].0b7h,x2ac0
        mov     mc,[gc].56h
        add     ix,[gc].58h
        movi    gb,7fe6h
        not     mc
        inc     mc
        add     mc,[gb+ix]
        jnz     mc,x2aa7
        movi    gb,7fdah
        mov     ix,[gc].58h
        setb    [gb+ix],7
        jmp     x2ae9

x2aa7:  mov     [gb+ix],[gc].56h
        mov     ix,[gc].58h
        movi    gb,x2ab8
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x2ab8:  dw      x2ac0
        dw      x2b5e
        dw      x2b49
        dw      x2af4

x2ac0:  movb    [ga].1h,[gc].56h
        movbi   [ga],43h
        lcall   [ga].2h,x2235
        jz      bc,x2ae9
        mov     [ga],[gc].56h
        movbi   [ga],42h
        lcall   [ga].2h,x2235
        jz      bc,x2ae9
        movbi   [ga],3h
        lcall   [ga].2h,x2235
x2ae9:  addbi   ga,0fff9h
x2aec:  mov     ix,[gc].58h
        mov     mc,[gc].56h
        mov     tp,[ga]

x2af4:  not     mc,[gc].56h
        andi    mc,0ffh
        setb    [gc].wdc18_shadow,0
        mov     [gc].vhw+wdc10,mc
        movi    [gc].0c8h,0c8h
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        clr     [gc].wdc18_shadow,0
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        lcall   [ga],x289b
        jz      bc,x2ae9
        notb    mc,[gc].57h
        andi    mc,0ffh
        mov     [gc].vhw+wdc10,mc
        movi    [gc].0c8h,148h
        setb    [gc].wdc18_shadow,0
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        clr     [gc].wdc18_shadow,0
        movb    [gc].vhw+wdc18,[gc].wdc18_shadow
        movi    [gc].vhw+wdc10,0fbh
        lcall   [ga],x2392
        jmp     x2ae9

x2b49:  clr     [gc].1h,0
        mov     bc,[gc].56h
        add     bc,[gc].5ch
        mov     [ga],bc
        movbi   bc,0ffffh
        jbt     [ga].1h,7,x2b5e
        setb    [gc].1h,0
x2b5e:  addbi   ga,0fff9h
        mov     [ga].5h,mc
        jnbt    [ga].6h,7,x2b73
        movi    gb,0c0h
        not     mc
        inc     mc
        jmp     x2b77

x2b73:  movi    gb,40h
x2b77:  mov     [gc].0c8h,gb
        movb    gb,[gc].wdc18_shadow
x2b7d:  orbi    gb,1h
        movb    [gc].vhw+wdc18,gb
        andbi   gb,0fffeh
        movb    [gc].vhw+wdc18,gb
        nop     
        nop     
        nop     
        nop     
        nop     
        dec     mc
        jnz     mc,x2b7d
        ljmp    x2aec

x2b9c:  lcall   [ga].19h,x2971
        movbi   [gb].2h,0fh
        movi    mc,0f090h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].3dh
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].56h
        ljmp    x2ae9

x2bc3:  mov     [gc].58h,ix
        mov     [ga].3h,mc
        addbi   ga,5h
        lcall   [ga],x2700
        ljz     bc,x2c11
        movi    [gc].0bfh,802h
        ljbt    [gc],0,x2c79
        movi    gb,7fdah
        clr     [gb+ix],7
        movi    gb,7fe6h
        add     ix,[gc].58h
        movi    [gb+ix],0h
        mov     ix,[gc].58h
        movi    gb,x2bfa
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x2bfa:  dw      x2c02
        dw      x2c50
        dw      x2c50
        dw      x2c30

x2c02:  movbi   [ga],4h
        lcall   [ga].2h,x2235
        lcall   [ga],x28d8
        jnz     bc,x2c22
x2c11:  setb    [gc].31h,7
        setb    [gc].0bfh,7
x2c17:  lcall   [ga],x2700
        jnbt    [gc].0bfh,7,x2c22
        movbi   bc,0h
x2c22:  clr     [gc].5fh,7
        addbi   ga,0fffbh
        mov     mc,[ga].3h
        mov     ix,[gc].58h
        mov     tp,[ga]

x2c30:  movi    [gc].vhw+wdc10,0fch
        lcall   [ga],x2392
        jz      bc,x2c11
x2c3c:  lcall   [ga],x28b5
        addbi   [ga].2h,0fff5h
        jzb     [ga].2h,x2c22
        dec     bc
        jnz     bc,x2c3c
        jmp     x2c11

x2c50:  movi    [gc].0c8h,40h
        setb    [gc].5fh,7
        movi    [gc].4eh,4b0h
x2c5d:  movbi   mc,1h
        jnbt    [gc].vhw+rdc08,s08_track_zero,x2c17
        dec     [gc].4eh
        jz      [gc].4eh,x2c11
        lcall   [ga],x2b73
        lcall   [ga],x2cd2
        jz      bc,x2c11
        jmp     x2c5d

x2c79:  lcall   [ga].19h,x2971
        movbi   [gb].2h,7h
        movi    mc,0f090h
        lcall   [ga].19h,x299e
        movb    [gb].2h,[gc].3dh
x2c91:  movi    gc,var_base
        jbt     [gc].vhw+rdc08,s08_int_11,x2ca9
        dec     bc
        jnz     bc,x2c91
        decb    [gc].0c0h
        jnzb    [gc].0c0h,x2c91
        ljmp    x2c11

x2ca9:  lcall   [ga],x29af
        jz      bc,x2cc4
        movi    gc,7fdeh
        jnbt    [gc+ix],7,x2c91
        clr     [gc+ix],7
        movi    gc,var_base
        jnz     mc,x2cc4
        ljmp    x2c17

x2cc4:  decb    [gc].0bfh
        ljzb    [gc].0bfh,x2c11
        clr     [gc].31h,5
        jmp     x2c79

x2cd2:  mov     [ga].3h,mc
        movbi   bc,0ffffh
        movbi   [gc].0bfh,0eh
        addbi   ga,5h
        ljbt    [gc],0,x2d7e
        movi    gb,7fdah
        jnbt    [gb+ix],7,x2cef
        clr     [gb+ix],7
        jmp     x2d1c

x2cef:  movi    gb,x2cf8
        addb    gb,[gc].0b7h
        mov     tp,[gb]

x2cf8:  dw      x2d00
        dw      x2d52
        dw      x2d52
        dw      x2d24

x2d00:  lcall   [ga],x28d8
        jbt     [gc].52h,5,x2d1c
        jnz     bc,x2d11
x2d0b:  setb    [gc].31h,7
        setb    [gc].0bfh,7
x2d11:  lcall   [ga],x2700
        jnbt    [gc].0bfh,7,x2d1c
        movbi   bc,0h
x2d1c:  addbi   ga,0fffbh
        mov     mc,[ga].3h
        mov     tp,[ga]

x2d24:  movbi   [ga].0fh,14h
x2d28:  lcall   [ga],x28b5
        jbt     [ga].2h,4,x2d43
        lcall   [ga],x28b5
        movb    [ga],[ga].2h
        andbi   [ga],0ffa4h
        jnzb    [ga],x2d0b
        jbt     [ga].2h,1,x2d1c
x2d43:  dec     bc
        jnz     bc,x2d28
        decb    [ga].0fh
        jnzb    [ga].0fh,x2d28
        jmp     x2d0b

x2d52:  jnbt    [gc].vhw+rdc00,s00_seek_complete,x2d65
        dec     bc
        jnz     bc,x2d52
        decb    [gc].0bfh
        jnzb    [gc].0bfh,x2d52
        jmp     x2d0b

x2d65:  jbt     [gc].5fh,7,x2d1c
        movbi   mc,0fff3h
        addb    mc,[gc].0b8h
        jnz     mc,x2d7b
        movi    gb,163ah
x2d76:  dec     gb
        jnz     gb,x2d76
x2d7b:  jmp     x2d11

x2d7e:  movi    gc,var_base
        jbt     [gc].vhw+rdc08,s08_int_11,x2d96
        dec     bc
        jnz     bc,x2d7e
        decb    [gc].0bfh
        jnzb    [gc].0bfh,x2d7e
        ljmp    x2d0b

x2d96:  lcall   [ga],x29af
        ljz     bc,x2d0b
        movi    gc,7fdeh
        jnbt    [gc+ix],7,x2d7e
        clr     [gc+ix],7
        movi    gc,var_base
        ljmp    x2d11

x2daf:  movbi   [gc].53h,0h
        movbi   bc,4h
        jmp     x2dc0

x2db9:  movbi   [gc].53h,0ffffh
        mov     bc,[gc].46h
x2dc0:  mov     [gc].0eh,ga
        mov     [ga].3h,gb
        mov     [ga].5h,ix
        movi    ga,3bf0h
        addbi   bc,3h
        movi    gb,400ch
        jzb     [gc].53h,x2dde
        addbi   gb,4h
        add     gb,[gc].46h
x2dde:  mov     [gc].50h,[gb]
        mov     [gc].4eh,[gb].2h
        movbi   [gc].52h,0h
x2ded:  dec     bc
        mov     gb,[gc].50h
        andbi   gb,0fffch
        jnz     gb,x2e2f
        mov     mc,[gc].4eh
        jbt     [gc].50h,1,x2e29
        jbt     [gc].50h,0,x2e26
        jbt     [gc].4fh,7,x2e23
        jbt     [gc].4fh,6,x2e20
        jbt     [gc].4fh,5,x2e1d
        jbt     [gc].4fh,4,x2e1a
        jnbt    [gc].4fh,3,x2e63
        andbi   mc,1h
x2e1a:  andbi   mc,3h
x2e1d:  andbi   mc,7h
x2e20:  andbi   mc,0fh
x2e23:  andbi   mc,1fh
x2e26:  andbi   mc,3fh
x2e29:  andbi   mc,7fh
        jz      mc,x2e63
x2e2f:  movb    ix,[gc].4eh
        addb    ix,[gc].4eh
        andi    ix,1feh
        not     mc,[ga+ix]
        and     mc,[gc].4fh
        not     gb,[gc].4fh
        and     gb,[ga+ix]
        mov     [gc].4eh,mc
        or      [gc].4eh,gb
        addi    ix,200h
        not     mc,[ga+ix]
        and     mc,[gc].51h
        not     gb,[gc].51h
        and     gb,[ga+ix]
        mov     [gc].50h,mc
        or      [gc].50h,gb
        jnz     bc,x2ded
        jmp     x2eb0

x2e63:  jnz     bc,x2e6a
        jnz     [gc].50h,x2eb0
x2e6a:  movi    ga,4006h
        jzb     [gc].53h,x2e75
        addbi   ga,8h
x2e75:  mov     [gc].54h,bc
        mov     ix,[gc].54h
        jnbt    [gc].54h,0,x2e91
        inc     ix
        mov     [gc].50h,[gc].4fh
        movb    [gc].4fh,[gc].4eh
        movbi   [gc].4eh,0h
x2e91:  not     mc,[gc].50h
        and     mc,[ga+ix]
        not     gb,[ga+ix]
        and     gb,[gc].50h
        mov     [ga+ix],mc
        or      [ga+ix+],gb
        not     mc,[gc].4eh
        and     mc,[ga+ix]
        not     gb,[ga+ix]
        and     gb,[gc].4eh
        mov     [ga+ix],mc
        or      [ga+ix],gb
        movbi   bc,0ffffh
x2eb0:  mov     ga,[gc].0eh
        mov     gb,[ga].3h
        mov     ix,[ga].5h
        mov     tp,[ga]

	fill	2f40h,0ffh

chan2_prog_start:
        movi    cc,100h
        movi    gc,var_base
        movbi   [gc].53h,0h
        movbi   [gc].3bh,0ffffh
x2f50:  movi    gc,var_base
        movi    ga,7e64h
        movbi   ix,0ffffh
        jnbt    [gc].53h,1,x2f63
        movbi   [gc].53h,0ffffh
x2f63:  incb    [gc].53h
        movbi   [gc],0h
x2f69:  movi    gc,var_base
        mov     [gc].vhw+wdc38,ix
        jnzb    [gc].0dh,x2f7a
        movbi   [gc].0dh,0ffabh
        hlt     
x2f7a:  movbi   cc,0h
        movi    gb,7fdah
        jzb     [gc].53h,x2f8f
        ljbt    [gc].53h,1,x30a6
        setb    [gc],0
        addbi   gb,4h
x2f8f:  inc     ix
        mov     [gc].0eh,gb
        movbi   [ga],0fffch
        addb    [ga],ix
        movi    cc,100h
        jzb     [ga],x2f50
        jnbt    [gb+ix],0,x2f69
        ljnbt   [gb+ix],2,x2fb1
        lcall   [ga],x20a5
        inc     [gb]
        ljz     [gb],x305b
x2fb1:  lcall   [ga],x20ba
        jz      bc,x2f69
        mov     gb,[gc].0eh
        ljbt    [gc],0,x308b
        jzb     [gc].0b7h,x2fd4
        ljbt    [gb+ix],7,x305b
        ljbt    [gb+ix],2,x303e
        jnbt    [gc].vhw+rdc00,s00_ready,x2fec
x2fcf:  clr     [gb+ix],1
        jmp     x2f69

x2fd4:  ljbt    [gc].0c7h,6,x2f69
        lcall   [ga],x2700
        mov     gb,[gc].0eh
        jnbt    [gb+ix],2,x2fe8
        ljbt    [gc].52h,5,x305b
x2fe8:  jbt     [gc].52h,4,x2fcf
x2fec:  ljbt    [gb+ix],1,x2f69
        setb    [gb+ix],1
        movbi   mc,4h
        call    [ga],x3035
        ljmp    x2f69

x2ffc:  jnbt    [gc].1h,2,x3017
        movi    gb,isbx_218a_ch1
        jnbt    [gb].fdc_latch_0,0,x3017
        movi    gc,7f00h
        inc     [gc].18h
        jnz     [gc].18h,x3017
        movbi   [gb].fdc_latch_0,0h
x3017:  ljmp    x2f69

x301b:  lcall   [ga],x2bc3
        mov     gb,[gc].0eh
        clr     [gb+ix],4
        jnz     bc,x302c
        clr     [gb+ix],1
        jmp     x2ffc

x302c:  movbi   mc,0ch
        call    [ga],x3035
        jmp     x2ffc

x3035:  setb    [gb+ix],5
        lcall   [ga].14h,x0248
        mov     tp,[ga]

x303e:  movbi   bc,0fff1h
        addb    bc,[gc].0b8h
        jz      bc,x306b
        ljbt    [gc].vhw+rdc00,s00_seek_complete,x2f69
        addbi   bc,2h
        jnz     bc,x305b
        movi    bc,1434h
x3056:  dec     bc
        jnz     bc,x3056
x305b:  movbi   mc,2h
        mov     gb,[gc].0eh
        andbi   [gb+ix],7bh
        call    [ga],x3035
        ljmp    x2f69

x306b:  lcall   [ga],x28b5
        ljbt    [ga].2h,4,x2f69
        lcall   [ga],x28b5
        movb    [ga],[ga].2h
        andbi   [ga],0ffa4h
        jnzb    [ga],x305b
        ljnbt   [ga].2h,1,x2f69
        jmp     x305b

x308b:  ljbt    [gc].vhw+rdc08,s08_isbx_218a_present,x2f69
        jbt     [gb+ix],7,x305b
        jbt     [gb+ix],2,x3099
        jbt     [gb+ix],4,x301b
x3099:  ljnbt   [gc].vhw+rdc08,s08_int_11,x2ffc
        lcall   [ga],x29af
        ljmp    x2ffc

x30a6:  movi    cc,100h
        inc     [gc].0b5h
        ljnbt   [gc].0b6h,1,x2f50
        addi    gb,8h
        movi    gc,7f00h
        inc     ix
        movbi   [ga],0fffch
        addb    [ga],ix
        jnzb    [ga],x30cd
        movi    [gc].0efh,0h
        ljmp    x2f50

x30cd:  ljnbt   [gb+ix],0,x2f69
        ljbt    [gc].16h,5,x2f69
        jbt     [gc].16h,6,x30eb
        jbt     [gc].vhw+rdc30,7,x30e3
        jnbt    [gb+ix],2,x310f
        clr     [gb+ix],2
x30e3:  setb    [gc].16h,6
        movi    [gc].10h,0f830h
x30eb:  movbi   mc,0h
        inc     [gc].10h
        jnz     [gc].10h,x30fb
        setb    [gc].1h,2
        jmp     x3156

x30fb:  movbi   [gc].vhw+wdc30,0h
        lcall   [ga],x3586
        ljbt    [gc].1h,2,x2f69
        jbt     [gc].vhw+rdc30,1,x3156
        jmp     x3159

x310f:  ljbt    [gc].16h,6,x2f69
        ljnbt   [gb+ix],6,x2f69
        movbi   [gc].vhw+wdc30,0h
        movbi   [gc].17h,6h
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x3134
        lcall   [ga],x3586
        jnbt    [gc].vhw+rdc30,7,x313c
x3134:  movbi   [gc].vhw+wdc30,0h
        ljmp    x2f69

x313c:  movi    gb,7fe2h
        jbt     [gc].1h,4,x3150
        ljbt    [gb+ix],1,x2f69
        setb    [gb+ix],1
        movbi   mc,0h
        jmp     x315d

x3150:  clr     [gb+ix],1
        ljmp    x2f69

x3156:  orbi    mc,0ffc0h
x3159:  ori     mc,0fh
x315d:  ori     mc,0eh
        lcall   [ga],x372c
        movbi   [gc].vhw+wdc30,0h
        andbi   [gc].16h,0ff9bh
        movi    gc,var_base
        setb    [gc],2
        lcall   [ga],x3035
        ljmp    x2f69

; XXX possibly cmd_floppy_read_data
x317b:  movi    gc,7f00h
        movbi   [gc].vhw+wdc30,1h
        movbi   [gc].17h,4h
        movi    cc,8828h		; XXX is this a channel control word?
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x319b
        orbi    [gc].0ch,9h
x319b:  ljmp    x3792

; XXX possibly cmd_floppy_write_data
x319f:  movi    gc,7f00h
        movbi   [gc].vhw+wdc30,11h
        movbi   [gc].17h,2h
        movi    cc,5428h		; XXX is this a channel control word?
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x31bf
        orbi    [gc].0ch,9h
x31bf:  ljmp    x3792

cmd_tape_init:
        lcall   [ga],x3767
        movbi   [gc].17h,0h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        lcall   [ga],x3586
        clr     [gc].1h,6
        jnzb    [gc],x31f1
        jnzb    [gc].1h,x31f1
        jnzb    [gc].2h,x31f1
        clr     [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
        movbi   [gc].0ch,9h
x31f1:  ljmp    x3792

cmd_tape_rewind:
        movi    gc,7f00h
        movbi   [gc].17h,7h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].0ch,9h
        ljmp    x378c

cmd_tape_skip_file_mark:
        movi    gc,7f00h
        lcall   [ga],x36f1
        movbi   [gc].17h,5h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].0ch,9h
        ljmp    x378c

cmd_tape_write_file_mark:
        movi    gc,7f00h
        movbi   [gc].vhw+wdc30,10h
        movbi   [gc].17h,3h
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x324f
        lcall   [ga],x3586
x324f:  ljmp    x3792

cmd_tape_erase:
        movi    gc,7f00h
        movbi   [gc].vhw+wdc30,10h
        movbi   [gc].17h,6h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        lcall   [ga],x3586
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].17h,9h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].0ch,9h
        ljmp    x378c

cmd_tape_load:
        movi    gc,7f00h
        movbi   [gc].17h,7h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].0ch,9h
        movi    gc,7fe2h
        setb    [gc+ix],6
        movi    gc,7f00h
        ljmp    x378c

cmd_tape_reset:
        lcall   [ga],x3767
        movbi   [gc].17h,1h
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x32cd
        lcall   [ga],x3586
x32cd:  ljmp    x3792

cmd_tape_retension:
        movi    gc,7f00h
        movbi   [gc].17h,8h
        lcall   [ga],x3752
        lcall   [ga],x3370
        ljbt    [gc].vhw+rdc30,1,x3792
        movbi   [gc].0ch,9h
        ljmp    x378c

cmd_tape_read_status:
        movi    gc,7f00h
        movbi   [gc].17h,6h
        lcall   [ga],x3752
        lcall   [ga],x3370
        jbt     [gc].vhw+rdc30,1,x3306
        lcall   [ga],x3586
x3306:  ljmp    x3792

cmd_tape_rw_terminate:
        movi    gc,7f00h
        lcall   [ga],x36f1
        movi    gb,isbx_217_ch0
        lcall   [ga],x3528
        jbt     [gc].vhw+rdc30,1,x3365
        jbt     [gc].vhw+rdc30,2,x336c
        movbi   [gb].tc_cmd_func,0ff82h
        lcall   [ga],x3528
        jbt     [gc].vhw+rdc30,1,x3365
        jbt     [gc].vhw+rdc30,2,x336c
        movb    [gb],ix				; tc_cmd_param
        lcall   [ga],x3528
        jbt     [gc].vhw+rdc30,1,x3365
        jbt     [gc].vhw+rdc30,2,x336c
        movbi   [gb].tc_cmd_func,tc_cmd_end_of_xfer
        lcall   [ga],x3528
        jbt     [gc].vhw+rdc30,1,x3365
        jbt     [gc].vhw+rdc30,2,x336c
        movb    [gb],ix				; tc_cmd_param
        lcall   [ga],x3528
        jbt     [gc].vhw+rdc30,1,x3365
        jbt     [gc].vhw+rdc30,2,x336c
        lcall   [ga],x355d
        jmp     x336c

x3365:  setb    [gc].1h,2
        movbi   [gc].0ch,0ffc9h
x336c:  ljmp    x3792

x3370:  addbi   ga,3h
        movi    gc,7f00h
        lcall   [ga],x36f1
        movi    gb,7fe2h
        ljnbt   [gb+ix],0,x34ad
        movi    gc,dc_reg_base+rdc00
        mov     [ga],[gc]
        movi    gc,7f00h
        ljbt    [ga].1h,0,x34ad
        jnbt    [gc].16h,5,x33ae
        jnbt    [gc].vhw+rdc30,0,x33b6
        movb    [ga],[gc].vhw+rdc30
        jnbt    [gc].16h,2,x33a8
        addbi   [ga],10h
x33a8:  jbt     [ga],4,x33b6
        jmp     x33c9

x33ae:  jnbt    [gc].16h,6,x33bc
        jbt     [gc].47h,6,x33bc
x33b6:  setb    [gc],5
        ljmp    x34b6

x33bc:  lcall   [ga],x3528
        ljbt    [gc].vhw+rdc30,1,x34b2
        jnbt    [gc].vhw+rdc30,0,x33e5
x33c9:  movi    [gc].4eh,0h
        movi    [gc].50h,0h
        jnz     [gc].60h,x33df
        ljz     [gc].62h,x34a3
        dec     [gc].62h
x33df:  wid     8,8
        jbt     [gc].16h,5,x3414
x33e5:  movb    [gb].2h,[gc].17h
        lcall   [ga],x3528
        movb    [gb],[gc].0f9h
        ljbt    [gc].vhw+rdc30,1,x34b2
        ljnbt   [gc].vhw+rdc30,0,x34bd
        lcall   [ga],x3528
        movbi   [gb].2h,40h
        lcall   [ga],x3528
        ljbt    [gc].vhw+rdc30,1,x34b2
        movb    [gb],ix
        jmp     x342b

x3414:  movi    gb,isbx_217_ch0
        movbi   [gb].tc_cmd_func,0ff82h
        lcall   [ga],x3528
        movb    [gb],ix			; tc_cmd_param
        lcall   [ga],x3528
        ljbt    [gc].vhw+rdc30,1,x34b2
x342b:  mov     bc,[gc].60h
        movi    [gc].60h,0h
        lpd     gb,[gc].5ch
x3436:  movbi   [ga].3h,40h
        mov     [gc].0f9h,bc
        movi    gc,var_base
        lcall   [ga],x0a71
        movi    gc,7f00h
        jbt     [gc].vhw+rdc30,1,x34b2
        lcall   [ga],x34cc
        mov     mc,[gc].4eh
        add     [gc].27h,mc
        jz      bc,x3479
        lcall   [ga],x355d
        jnbt    [gc].vhw+rdc30,4,x34bd
        jbt     [gc].2h,3,x3469
        jnbt    [gc],7,x34bd
x3469:  andi    [gc].27h,1ffh
        not     mc,[gc].27h
        inc     mc
        add     [gc].4eh,mc
        jmp     x34bd

x3479:  jnz     [gc].62h,x349d
        movi    gb,isbx_217_ch0
        jnbt    [gb].tc_upi_status,6,x3490
        movbi   [gb],20h		; tc_cmd_param
x3488:  jnbt    [gb].tc_upi_status,0,x3488
        movb    [ga],[gb]		; tc_drive_status
x3490:  movbi   [gb].tc_cmd_func,0ff81h
        lcall   [ga],x3528
        movb    [gb],ix
        jmp     x34bd

x349d:  dec     [gc].62h
        jmp     x3436

x34a3:  setb    [gc].1h,0
        clr     [gc].vhw+wdc30,0	; XXX clr on a reg that isn't R/W?
        ljmp    x34b6

x34ad:  setb    [gc],6
        jmp     x34b6

x34b2:  andbi   [gc].16h,0ffdbh
x34b6:  orbi    [gc].0ch,0ffc9h
        setb    [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
x34bd:  jnbt    [gc].vhw+rdc30,0,x34c7
        mov     [gc].60h,[gc].0f9h
x34c7:  addbi   ga,0fffdh
        mov     tp,[ga]

x34cc:  addbi   ga,3h
        mov     [ga].3h,[gc].0f9h
        jnz     bc,x34e8
        jz      [gc].0f9h,x34e2
        call    [ga],x3503
        jmp     x34f8

x34e2:  inc     [gc].50h
        jmp     x34f8

x34e8:  mov     [ga].5h,bc
        not     bc
        inc     bc
        add     [gc].0f9h,bc
        mov     bc,[ga].5h
        call    [ga],x3503
x34f8:  mov     [gc].0f9h,[ga].3h
        addbi   ga,0fffdh
        mov     tp,[ga]

x3503:  mov     mc,[gc].0f9h
        jbt     [gc].0fah,7,x3513
        jbt     [gc].4fh,7,x3517
        add     [gc].4eh,mc
        mov     tp,[ga]

x3513:  jbt     [gc].4fh,7,x3520
x3517:  add     [gc].4eh,mc
        jnbt    [gc].4fh,7,x3523
        mov     tp,[ga]

x3520:  add     [gc].4eh,mc
x3523:  inc     [gc].50h
        mov     tp,[ga]

x3528:  addi    ga,3h
x352c:  movi    gb,isbx_217_ch0
        movi    mc,0ec78h
x3534:  jbt     [gb].tc_upi_status,0,x354a
        jnbt    [gb].tc_upi_status,1,x3557
        inc     mc
        jnz     mc,x3534
        setb    [gc].1h,2
        setb    [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
        jmp     x3557

x354a:  call    [ga],x355d
        jbt     [gc].vhw+rdc30,7,x3557
        setb    [gc].vhw+wdc30,2	; XXX clr on a reg that isn't R/W?
        jmp     x352c

x3557:  addi    ga,0fffdh
        mov     tp,[ga]

x355d:  addi    ga,3h
        call    [ga],x3586
        jnbt    [gc].16h,5,x357c
        jbt     [gc].vhw+rdc30,7,x357c
        andbi   [gc].16h,0ffdbh
        jnzb    [gc].5h,x3578
        jzb     [gc].8h,x357c
x3578:  orbi    [gc].0ch,0ff80h
x357c:  andbi   [gc].vhw+wdc30,7dh	; XXX clr on a reg that isn't R/W?
        addi    ga,0fffdh
        mov     tp,[ga]

x3586:  addi    ga,3h
        mov     [ga],mc
        mov     [ga].2h,gb
        mov     [ga].4h,bc
        addi    ga,6h
        clr     [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
        call    [ga],x35eb
        jbt     [gc].vhw+rdc30,1,x35c0
        jbt     [gc].2h,5,x35c0
        jnzb    [gc].2h,x35c7
        jnzb    [gc],x35c0
        movb    mc,[gc].1h
        andi    mc,0feh
        jnz     mc,x35c0
        jbt     [gc].16h,5,x35bc
        clr     [gc].vhw+wdc30,4	; XXX clr on a reg that isn't R/W?
x35bc:  jzb     [gc].8h,x35d5
x35c0:  orbi    [gc].0ch,0ffc0h
        jmp     x35d2

x35c7:  movi    gb,7fe2h
        jbt     [gc].2h,3,x35c0
        setb    [gc].0ch,7
x35d2:  setb    [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
x35d5:  orbi    [gc].0ch,9h
        addi    ga,0fffah
        mov     mc,[ga]
        mov     gb,[ga].2h
        mov     bc,[ga].4h
        addi    ga,0fffdh
        mov     tp,[ga]

x35eb:  addi    ga,3h
        mov     [ga],ix
        addi    ga,2h
        lcall   [ga],x36f1
        movbi   [ga],0h
        movbi   ix,0h
x35ff:  movi    gc,7f00h
        movbi   mc,68h
        movi    bc,0h
x360a:  movi    gb,isbx_217_ch0
        jbt     [gb].tc_upi_status,0,x3638
        jbt     [ga],0,x3619
        jbt     [gc].16h,6,x3623
x3619:  dec     bc
        jnz     bc,x360a
        dec     mc
        jnz     mc,x360a
x3623:  setb    [gc].1h,2
        setb    [gc].vhw+wdc30,7	; XXX clr on a reg that isn't R/W?
        setb    [gc].vhw+wdc30,1	; XXX clr on a reg that isn't R/W?
        addi    ga,0fffeh
        mov     ix,[ga]
x3632:  addi    ga,0fffdh
        mov     tp,[ga]

x3638:  movi    gc,7f10h
        jnz     ix,x364a
        movb    ix,[gb]
        not     ix
        inc     ix
        setb    [ga],0
        jmp     x35ff

x364a:  movb    [gc+ix],[gb]
        inc     ix
        jnz     ix,x35ff
        movi    gc,7f00h
        addi    ga,0fffeh
        mov     ix,[ga]
        jnbt    [gc].0dh,0,x3663
        setb    [gc],4
x3663:  jnbt    [gc].0dh,1,x366e
        jbt     [gc].16h,6,x366e
        setb    [gc].1h,6
x366e:  jnbt    [gc].0dh,2,x3675
        setb    [gc].2h,3
x3675:  jnbt    [gc].0dh,3,x367c
        setb    [gc].2h,1
x367c:  jnbt    [gc].0dh,4,x3683
        setb    [gc].2h,6
x3683:  jnbt    [gc].0dh,5,x368a
        setb    [gc].2h,5
x368a:  jnbt    [gc].0dh,6,x3695
        jnbt    [gc].vhw+rdc30,4,x3695
        setb    [gc].1h,7
x3695:  jnbt    [gc].0dh,7,x369c
        setb    [gc].1h,4
x369c:  jnbt    [gc].0eh,1,x36a3
        setb    [gc].1h,0
x36a3:  jnbt    [gc].0eh,2,x36aa
        setb    [gc].2h,2
x36aa:  jnbt    [gc].0eh,3,x36b3
        setb    [gc],2
        setb    [gc].1h,3
x36b3:  jnbt    [gc].0eh,4,x36bc
        setb    [gc],1
        setb    [gc].1h,3
x36bc:  jnbt    [gc].0eh,5,x36c4
        movbi   [gc].8h,0ffffh
x36c4:  jnbt    [gc].0eh,6,x36cc
        movbi   [gc].3h,0ffffh
x36cc:  jnbt    [gc].0fh,4,x36d4
        movbi   [gc].4h,0ffffh
x36d4:  jnbt    [gc].0fh,5,x36dc
        movbi   [gc].5h,0ffffh
x36dc:  jnbt    [gc].0fh,6,x36ea
        movbi   [gc].6h,0ffffh
        setb    [gc],7
        orbi    [gc].0ch,0ffc0h
x36ea:  clr     [gc].vhw+wdc30,7	; XXX clr on a reg that isn't R/W?
        ljmp    x3632

x36f1:  mov     [ga].4h,ix
        mov     [ga].6h,gc
        movbi   ix,0fff0h
        movbi   bc,0h
        movi    gc,7f10h
x3701:  mov     [gc+ix+],bc
        jnz     ix,x3701
        mov     ix,[ga].4h
        mov     gc,[ga].6h
        mov     tp,[ga]

; XXX possibly cmd_floppy_xfer_status
x370e:  mov     [ga].3h,ix
        movbi   ix,0fff4h
        movi    gb,7f27h
        movi    gc,7f75h
x371c:  mov     [gc+ix+],[gb+ix]
        jnz     ix,x371c
        movi    gc,7f00h
        mov     ix,[ga].3h
        mov     tp,[ga]

x372c:  mov     [ga].4h,ix
        mov     [ga].6h,gc
        mov     [ga].8h,gb
        movbi   ix,0fff4h
        movi    gb,7f0ch
        movi    gc,7f27h
x3740:  mov     [gc+ix+],[gb+ix]
        jnz     ix,x3740
        mov     ix,[ga].4h
        mov     gc,[ga].6h
        mov     gb,[ga].8h
        mov     tp,[ga]

x3752:  movb    [ga].3h,ix
        movb    mc,[ga].3h
        orbi    mc,0ff80h
        jnbt    [gc].vhw+rdc30,0,x3762
        andbi   mc,7fh
x3762:  movb    [gc].0f9h,mc
        mov     tp,[ga]

x3767:  movi    gc,7fe2h
        andbi   [gc+ix],2bh
        movi    gc,7f00h
        andbi   [gc].16h,0ff9bh
        mov     tp,[ga]

; XXX possibly cmd_floppy_spin_down
; XXX possibly cmd_floppy_track_seek
; XXX possibly cmd_floppy_format
; XXX possibly cmd_floppy_read_id
; XXX possibly cmd_floppy_diag
x3778:  lcall   [ga],x36f1
        setb    [gc],6
        movbi   [gc].0ch,0ffc9h
        jmp     x3792

        orbi    [gc].0ch,0ffc0h
        jmp     x3792

x378c:  addi    ix,0e2h
        setb    [gc+ix],2
x3792:  movb    [gc].0f7h,[gc].0ch
        call    [ga],x372c
        ljmp    x00c5

	fill	3bebh,0ffh

x3beb:  db      000h,010h,020h,030h,030h
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
	db	000h,000h,0ffh,0ffh,055h,055h,0aah,0aah
	db	055h,055h,003h,007h,085h,0ffh,04ah,00dh
