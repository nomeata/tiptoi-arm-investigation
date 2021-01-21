#include <stdint.h>

typedef void (*foo)(short, short, char, short);

int32_t _24_a(int32_t a1) {

    if (*(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) == 0) {
 	*(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) = 1;
 	*(char *)(*(int32_t *)(a1 + 0x34) + 0x58) = 100;
        return 1;
    }

    /*
    (*(void (**)())(a1 + 0x88))();
    (*(void (**)())(a1 + 0x90))();
    (*(void (**)())(a1 + 0x94))();
    */

    (*(foo*)(a1 + 140))(
      **((short **)(a1 + 228)),
      **((short **)(a1 + 232)),
      **((char **)(a1 + 236)),
      **((short **)(a1 + 240))
    );

    *(int *)(*(int *)(a1 + 0x124) + 0x78) =
    *(int *)(*(int *)(a1 + 0x124) + 0x52);


    *(char *)(*(int32_t *)(a1 + 0x34) + 0xdec) = -1;
    return 255;
}
