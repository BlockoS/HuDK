; PSG (Programmable Sound Generator)

; Channel count.
PSG_CHAN_COUNT = 6

; PSG registers.
psgport = $0800
; Channel select register.
psg_ch = psgport
; Global sound volume.
psg_mainvol = psgport+1
; Fine frequency adjust.
psg_freq.lo = psgport+2
; Rough frequency adjust.
psg_freq.hi = psgport+3
; Control register.
psg_ctrl = psgport+4
; Channel balance.
psg_pan = psgport+5
; Channel sound data.
psg_wavebuf = psgport+6
; Noise control.
psg_noise = psgport+7
; LFO frequency.
psg_lfofreq = psgport+8
; LFO trigger and control.
psg_lfoctrl = psgport+9

; PSG control register bit masks
; Channel on (1), off(0)
PSG_CTRL_CHAN_ON = %1000_0000
; Reset waveform write index to 0
PSG_CTRL_WRITE_RESET = %0100_0000
; DDA output on(1), off(0)
PSG_CTRL_DDA_ON = %1100_0000
; Channel volume
PSG_CTRL_VOL_MASK = %0001_1111
; Channel maximum volume (bit 5 is unused)
PSG_CTRL_FULL_VOLUME = %0011_1111

