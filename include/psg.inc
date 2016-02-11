; PSG (Programmable Sound Generator)

; Channel count.
PSG_CHAN_COUNT .equ 6

; PSG registers.
psgport      .equ  $0800
; Channel select register.
psg_ch       .equ  psgport
; Global sound volume.
psg_mainvol  .equ  psgport+1
; Fine frequency adjust.
psg_freq.lo  .equ  psgport+2
; Rough frequency adjust.
psg_freq.hi  .equ  psgport+3
; Control register.
psg_ctrl     .equ  psgport+4
; Channel balance.
psg_pan      .equ  psgport+5
; Channel sound data.
psg_wavebuf  .equ  psgport+6
; Noise control.
psg_noise    .equ  psgport+7
; LFO frequency.
psg_lfofreq  .equ  psgport+8
; LFO trigger and control.
psg_lfoctrl  .equ  psgport+9

; PSG control register bit masks
; Channel on (1), off(0)
PSG_CTRL_CHAN_ON        .equ %1000_0000
; Reset waveform write index to 0
PSG_CTRL_WRITE_RESET    .equ %0100_0000
; DDA output on(1), off(0)
PSG_CTRL_DDA_ON         .equ %1100_0000
; Channel volume
PSG_CTRL_VOL_MASK       .equ %0001_1111
; Channel maximum volume (bit 5 is unused)
PSG_CTRL_FULL_VOLUME    .equ %0011_1111

