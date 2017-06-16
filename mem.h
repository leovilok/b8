#ifndef MEM_H
#define MEM_H

#define MEM_SIZE  0x40000
#define CART_SIZE 0x20000
#define CART_HEADER_SIZE 0x20
#define SCREEN_MEM_SIZE 0x10000

#define SCREEN_MEM_OFFSET CART_SIZE
#define INPUT_MEM_OFFSET (SCREEN_MEM_OFFSET+SCREEN_MEM_SIZE)

extern unsigned char mem[];

#endif /* MEM_H */
