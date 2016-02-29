;;
;; Title: PSG registers.
;;

; Channel count.
PSG_CHAN_COUNT = 6

;;
;; Group: Registers.
;;

;;
;; ubyte: psgport
;; PSG port.
;; 
psgport = $0800
;;
;; ubyte psg_chn
;; Channel select register.
;;
psg_chn = psgport
;;
;; ubyte: psg_mainvol
;; Global sound volume.
;;
psg_mainvol = psgport+1
;;
;; ubyte: psg_freq_lo
;; Fine frequency adjust.
;;
psg_freq_lo = psgport+2
;;
;; ubyte: psg_freq_hi
;; Rough frequency adjust.
;;
psg_freq_hi = psgport+3
;;
;; ubyte: psg_ctrl
;; Control register.
;;
psg_ctrl = psgport+4
;;
;; ubyte: psg_pan
;; Channel balance.
;;
psg_pan = psgport+5
;;
;; ubyte: psg_wavebuf
;; Channel sound data.
;;
psg_wavebuf = psgport+6
;;
;; ubyte: psg_noise
;; Noise control.
;;
psg_noise = psgport+7
;;
;; ubyte: psg_lfofreq
;; LFO frequency.
;;
psg_lfofreq = psgport+8
;;
;; ubyte: psg_lfoctrl
;; LFO trigger and control.
;;
psg_lfoctrl = psgport+9

;;
;; Group: Control Register Flags.
;;

;;
;; bits: PSG_CTRL_CHAN_ON
;; PSG control register bit masks
;;  1 - Channel on
;;  0 - Channel off
PSG_CTRL_CHAN_ON = %10000000
;;
;; bits: PSG_CTRL_WRITE_RESET
;; Reset waveform write index to 0
;;
PSG_CTRL_WRITE_RESET = %01000000
;;
;; bits: PSG_CTRL_DDA_ON
;; DDA output.
;;  1 - on
;;  0 - off
;;
PSG_CTRL_DDA_ON = %11000000
;;
;; bits: PSG_CTRL_VOL_MASK
;; Channel volume.
;;
PSG_CTRL_VOL_MASK = %00011111
;;
;; bits: PSG_CTRL_FULL_VOLUME
;; Channel maximum volume (bit 5 is unused)
;;
PSG_CTRL_FULL_VOLUME = %00111111

