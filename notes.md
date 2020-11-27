
## Minimal code

OidMain needs to write 0xff to *(*(arg+52)+3564), else the pen crashes. Minimal code in assembly:

```
push {r4, r5, r6, r7, r8, r9, sl, lr}
ldr r5, [r0, #52]   @ 0x34
mov     r0, #255        @ 0xff
strb    r0, [r5, #3564] @ 0xdec
pop   {r4, r5, r6, r7, r8, r9, sl, pc}
```

## Register

r8 sometimes #0, sometimes 0x08141000
r9 sometimes #1, sometimes 0x08141024

## Program input analysis

It looks like the program gets an argumet in r0, which
it then moves to r4, keeps around, and treats as a pointer to a structure
(maybe a C++ object)?

Looking at the assembly code, I find these offsets occur, with some notes based on how the data seems to be used (crazy ad-hoc syntax):

12 // function
24 // function
36 // function
44 // function
48 // function, no arguments, no results
72 // u16, wird mit 48 verglichen
76 // ptr to u32
80 // ptr to u32, wird mit obigem verglichen
84 // ptr, ziel 2. argument von #44
88 // ptr, ziel 3. argument von #44
96 // ptr, byte, ziel wird nach *sl geschrieben, wenn 0 beendet
100 // ptr, byte, wird geschrieben (von r8, r9)
104 // ptr, byte, wird geschrieben (von r9)
124 // function, argument: r5->4
128 // function, argument: array offset from 288, result compared against 0
136 // function
140 // function, arguments(*h(#288+2*r6), -256, *b(#236+r6), *h(#240+2*r6))
144 // function
148 // function, no args?
156 // function (similar context as 144+148)
164 // function
176 // ptr, ziel 1. argument von #44
188 // ptr, ziel finishes loop around #128
192 // ptr, target used as addition to to *(#288+3*r6), to be writtento *#200
200 // ptr, target above writes to
204 // ptr, wird mit 1 verglichen
228 // arg to #140
232 // arg to #140
236 // arg to #140
240 // arg to #140
244 // ptr, target compared to r5->#301
272 // ptr, target compared to r5->#4
288 // arg to 128
292 // ptr to thing, offset 82 of that read and written to 120
300 // arg to #44
304 // arg to #44
308 // ptr to array or something
312 // ptr to something that gets counted up
396 // function




arg+52 // stored in r5

arg+292+82 // 16 bit value


r9: fix 0x08141024
r8: fix 0x08141000
sl: fix 0x08141004

