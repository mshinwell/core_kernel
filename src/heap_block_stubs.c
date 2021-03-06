#include "config.h"
#include <caml/mlvalues.h>

#define In_heap 1
#define In_young 2

/* copied from byterun/memory.h */
#ifdef JSC_ARCH_SIXTYFOUR

/* 64 bits: Represent page table as a sparse hash table */
int caml_page_table_lookup(void * addr);
#define Classify_addr(a) (caml_page_table_lookup((void *)(a)))

#else

/* 32 bits: Represent page table as a 2-level array */
#define Pagetable2_log 11
#define Pagetable2_size (1 << Pagetable2_log)
#define Pagetable1_log (Page_log + Pagetable2_log)
#define Pagetable1_size (1 << (32 - Pagetable1_log))
CAMLextern unsigned char * caml_page_table[Pagetable1_size];

#define Pagetable_index1(a) (((uintnat)(a)) >> Pagetable1_log)
#define Pagetable_index2(a) \
    ((((uintnat)(a)) >> Page_log) & (Pagetable2_size - 1))
#define Classify_addr(a) \
    caml_page_table[Pagetable_index1(a)][Pagetable_index2(a)]

#endif

#define Is_in_heap_or_young(a) (Classify_addr(a) & (In_heap | In_young))

CAMLprim value
core_heap_block_is_heap_block(value v)
{
  return (Is_block(v) && Is_in_heap_or_young(v)) ? Val_true : Val_false;
}
