;;
;; Title: Backup RAM.
;;
;; Description:
;; The Tennokoe 2, IFU-30 and DUO systems provided an extra 2KB of battery
;; powered back up memory.
;;
;; The backup ram (BRAM for short) "file system" is organized as follows :
;; 
;; BRAM Header ($10 bytes):
;;
;;   00-03 - Header tag (equals to "HUBM")
;;   04-05 - Pointer to the first byte after BRAM.
;;   06-07 - Pointer to the next available BRAM slot (first unused byte).
;;   08-0f - Reserved (set to 0).
;;
;; BRAM Entry Header:
;;   00-01 - Entry size. This size includes the $10 bytes of the entry header.
;;   02-03 - Checksum. .
;;   04-0f - Entry name. 
;;
;; BRAM Entry name:
;;   00-01 - Unique ID.
;;   02-0b - ASCII name (padded with spaces).
;;
;; BRAM Entry Data:
;;   Miscenalleous data which size is given in the BRAM Entry Header.
;;
;; BRAM Entry Trailer (2 bytes):
;;   This 2 bytes are set to zeroes. They are not part of the BRAM "used area".
;;   It is used as a linked list terminator.
;;

;;
;; function: bm_format
;; Initialize backup memory.
;;
bm_format:

;;
;; function: bm_free
;; Returns the number of free bytes.
;;
bm_free:

;;
;; function: bm_read
;; Read entry data.
;;
bm_read:

;;
;; function: bm_write
;; Write data.
;;
bm_write:

;;
;; function: bm_delete
;; Delete the specified entry.
;; 
bm_delete:

;;
;; function: bm_files
;; 
bm_files:
