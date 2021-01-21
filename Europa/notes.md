
## Minimal code

OidMain needs to write 0xff to *(*(arg+52)+3564), else the pen crashes. Minimal code in assembly:

```
push {r4, r5, r6, r7, r8, r9, sl, lr}
ldr r5, [r0, #52]   @ 0x34
mov     r0, #255        @ 0xff
strb    r0, [r5, #3564] @ 0xdec
pop   {r4, r5, r6, r7, r8, r9, sl, pc}
```

or as C:
```
#include <stdint.h>
int32_t _24_a(int32_t a1) {
    *(char *)(*(int32_t *)(a1 + 52) + 3564) = -1;
    return 255;
}
```

See `still-works.txt` and `still-works.c`.

The C file can be compiled with
```
arm-none-eabi-gcc -O1 -c test.c -o test.o
arm-none-eabi-objcopy -O binary test.o test.bin
```

## Register

r8 sometimes #0, sometimes 0x08141000

r9 sometimes #1, sometimes 0x08141024

sl: sometimes 0x08141004, sometimes 0x08141000


sp: The stack pointer  is only used in the inital segment, before the `entry`. Unclear if that is used.


## Program input analysis

It looks like the program gets an argumet in r0, which
it then moves to r4, keeps around, and treats as a pointer to a structure
(maybe a C++ object)?

Looking at the assembly code, I find these offsets occur, with some notes based on how the data seems to be used (crazy ad-hoc syntax):

* 12 // function
* 24 // function
* 36 // function
* 44 // function
* 48 // function, no arguments, no results
* 52 // loaded into r5, seems to point to a structure that it is working with
* 72 // u16, wird mit 48 verglichen
* 76 // ptr to u32
* 80 // ptr to u32, wird mit obigem verglichen
* 84 // ptr, ziel 2. argument von #44
* 88 // ptr, ziel 3. argument von #44
* 96 // ptr, byte, ziel wird nach *sl geschrieben, wenn 0 beendet
* 100 // ptr, byte, wird geschrieben (von r8, r9)
* 104 // ptr, byte, wird geschrieben (von r9)
* 124 // function, argument: r5->4
* 128 // function, argument: array offset from 288, result compared against 0
* 136 // function

  Occurs exactly once. If replaced with a nop, this turns the pen silent on
  power on and all fields, but does not crash it (other books still work)

  Running this function twice does not have any obvoius effect.
* 140 // function, arguments(*h(#288+2*r6), -256, *b(#236+r6), *h(#240+2*r6))

  If replaced with a nop, this turns the pen silent on
  power on and all fields, but does not crash it (other books still work)

  Passing the first element of these arrays (as in x0854-x0878) in an otherwise empty file does not seem to do anything.
* 144 // function
* 148 // function, no args?

  Occurs exactly once. If replaced with a nop, this turns the pen silent on
  power on and all fields, but does not crash it (other books still work)

  Running this function twice does not have any obvious effect.
* 156 // function (similar context as 144+148)
* 164 // function
* 176 // ptr, ziel 1. argument von #44
* 188 // ptr, ziel finishes loop around #128
* 192 // ptr, target used as addition to to *(#288+3*r6), to be writtento *#200
* 200 // ptr, target above writes to
* 204

  Points to a byte value that the loop counter for x0750-0x7e4
  The loop index `r6` is used to index into #232 (half-words)

  May execute #140. Arguments to #140 are r6 indexed into #240, #236, #228

  If not executed #140, then r6 written to *(#308 + r7)
  This branch also bumps r7 and what’s pointed to by #312

  After the loop, *(#308) is used as an index into #240, #236, #232, #228, as arguments to #140

  Skipping that loop (with our without the after-the-loop) crashes the pen.

* 228 // arg to #140
* 232 // array of half-words
* 236 // arg to #140
* 240 // arg to #140
* 244 // ptr, target compared to r5->#301
* 272 // ptr, target compared to r5->#4
* 288 // arg to 128
* 292 // ptr to thing, offset 82 of that read and written to 120

  See below, this is likely the registers. Offeset 82 is index 41, which is the
  only one not written by function x029c

  But also offset 120 is relevant! That would be register $60, that is too much...

  Also, *(arg+292)+256 is something else, but only used early in the code.

  Otherwise, not much use of this value here.

* 300 // arg to #44
* 304 // arg to #44
* 308 // ptr to array or something
* 312 // ptr to something that gets counted up
* 396 // function.

  Occurs exactly once. Argument is #43. Weglassen hat keinen sichtbaren Effekt.


## Functions?

x029c - x02e0 is a function.

It is started shortly on `entry`, if “register” $60 == 4 and $41 ≠ 4.

Seems to fill array #292 (of 16 bit words) from [0] to [47] with 0, with exception of
[42], which becomes [99], and [41], which is not written to.

Compare initial registers, also 48, and $42 == 99 (but $41 == 1)
```
Number of registers: 48
Initial registers: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,99,0,0,0,0,0]
```

**Conjecture** array #292 is the register array! (But there is more stuff there, too)


After the function call (if done or not), $60 := $41.

## Various notes

Which is the function to play sounds?

* Tried to remove all calls to #44.
  All sound still played
* Tried to remove all calls to #140.
  No sound played on START, or later. Pen not crashed.
* Tried to change array index (+1) in call to #140 near 0x910.
  On START, Only first sound (P(0)) is played, but not P(1).
  Some other fields still work.
* Disabled call to #140 near 0x910. Same effect as above.
* Tried to change array index (+1) in call to #140 near 0x820.
  On START, Only second sound (P(1)) is played, but not the first (P(0))
  Some other fields still work.
* In call to #140 near 0x820, tried to load array index from 0x138, not 0x134
  On START, Only second sound (P(1)) is played, but not the first (P(0))
  Some other fields still work.
* In call to #140 near 0x820, tried to load array index from (*0x134 + 1)
  On START, it plays P(1) twice! Whoohoo!
* In call to #140 near 0x820, tried to load array index from (*0x134 + 1)
  In call to #140 near 0x910, tried to load array index at one less.
  On START, it plays P(0) and then P(1)! Whoohoo!
* In call to #140 near 0x820, tried to load array index from (*0x134 + 2)
  On START, only plays P(1)
* In call to #140 near 0x820, tried to set array index to 0
  In call to #140 near 0x910, disable call.
  On START, only plays P(0)
* In call to #140 near 0x820, tried to set array index to 1
  In call to #140 near 0x910, disable call.
  On START, only plays P(1)
* In call to #140 near 0x820, tried to set array index to 2
  In call to #140 near 0x910, disable call.
  On START, nothing played. Other thing still work

Theory:
Function #140 plays a sound.
It is always passed corresponding values from the arrays (#288, #232, #236, #240)
These arrays contain only the media from a single playlist (hence index 2 does
not work here).
Field 0xcc contains the lenght of the playlist.


The code following code alone does not play a sound.

    typedef void (*foo)(short, short, char, short);
    int32_t _24_a(int32_t a1) {
       (*(foo*)(a1 + 140))(
         **((short **)(a1 + 228)),
         **((short **)(a1 + 232)),
         **((char **)(a1 + 236)),
         **((short **)(a1 + 240))
        );
        *(char *)(*(int32_t *)(a1 + 52) + 3564) = -1;
        return 255;
    }

Theory: Need to load/activate a playlist first!

The original code runs

    (*(code *)self->field_0x88)();
    (*(code *)self->field_0x90)();
    (*(code *)self->field_0x94)();

before. Trying that… Crashes the pen.


Now trying to find out which branches are necessary to play the first sound.

* at 0x030c, unconditional:
  no sound, crashes
* at 0x030c, removed:
  no sound, crashes
* at 0x030c, only set self->0x34->0xdec = 1 in this branch
  no on-sound, pen still works
* at 0x030c, only set self->0x34->0xdec = 1 and self->0x34->0x58 = #100 in this branch
  on-sound, pen still works

  note: unclear in hindsight if on-sounds works on first or only second  tap
        from now on working towars second tap only
* skipping branch at 0x030c and 0x370c alltogether:
  stuttering on-sound
* at 0x370, unconditional:
  stuttering
* at 0x370, removed:
  still works
* at 0x390, removed
  second tap still works

* at 0x440, unconditional
  crash
* at 0x440 and 0x44c: removed:
  crash

* at 0x710: unconditional (like when field0x128 == false)
  plays nothing (but no crash)
* at 0x710: removed (like when field0x128 == true)
  no start-up sound.
  Second tap, and other sounds play repeatedly the first few ms, then crash

* at 0x728 (checking for nsounds = 0)
  still works (as expected)
  so does removing the other branches for nsounds

* at 0x888: unconditional
  still works

* at 0x944: unconditional
  still works

* at 0x9bc: unconditional
  still works

* at 0xa4c: unconditional
  still works

* at 0xaa8: unconditional
  still works

* at 0xa2c: removed
  still works

* removing code 0x48 ... entry:
  still works

* at 0x484: removed
  no on-sound, does not crash

* at 0x484: unconditional
  still works

* at 0x530: unconditional
  no on-sound, does not crash

* at 0x530: removed
  no on-sound, does not crash
