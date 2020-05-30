# Print string using the system font

This ROM displays "Hello world!" using the `print_string` routine and HuDK system font.

<table>
<tr><th>asm</th><th>C</th></tr>
<tr><td>

```asm
stw    #txt, <_si   ; string address
stb    #32, <_al    ; text area width
stb    #20, <_ah    ; text area height
ldx    #10          ; BAT X coordinate
lda    #8           ; BAT Y coordinate
jsr    print_string

; ...

txt:
    .db "Hello world!", 0

```

</td><td>

```C
print_string(8,10,32,20,"Hello world!");
```

</td></tr>
</table>

![font.pce screenshot](screenshot.png)
