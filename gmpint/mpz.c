//
//  mpz.c
//  gmpint
//
//  Created by Dan Kogai on 7/5/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

#include <stdio.h>
#include <gmp.h>

void gmpint_seti(mpz_t *op, int i) {
    mpz_init_set_si(*op, i);
}
void gmpint_sets(mpz_t *op, char *str, int base){
    mpz_init_set_str(*op, str, base);
}
void gmpint_unset(mpz_t *op) {
    mpz_clear(*op);
}
size_t gmpint_strlen(mpz_t *op, int base) {
    return mpz_sizeinbase(*op, base);
}
char *gmpint2str(mpz_t *op, int base) {
    return mpz_get_str(NULL, base, *op);
}
int gmpint_cmp(mpz_t *op, mpz_t *op2) {
    return mpz_cmp(*op, *op2);
}
void gmpint_negz(mpz_t *rop, mpz_t *op) {
    mpz_neg(*rop, *op);
}
void gmpint_absz(mpz_t *rop, mpz_t *op) {
    mpz_abs(*rop, *op);
}
void gmpint_lshift(mpz_t *rop, mpz_t *op, mp_bitcnt_t bits) {
    mpz_mul_2exp(*rop, *op, bits);
}
void gmpint_rshift(mpz_t *rop, mpz_t *op, mp_bitcnt_t bits) {
    mpz_div_2exp(*rop, *op, bits);
}
void gmpint_addz(mpz_t *rop, mpz_t *op, mpz_t *op2) {
    mpz_add(*rop, *op, *op2);
}
void gmpint_subz(mpz_t *rop, mpz_t *op, mpz_t *op2) {
    mpz_sub(*rop, *op, *op2);
}
void gmpint_mulz(mpz_t *rop, mpz_t *op, mpz_t *op2) {
    mpz_mul(*rop, *op, *op2);
}
void gmpint_divmodz(mpz_t *r, mpz_t *q, mpz_t *op, mpz_t *op2) {
    mpz_divmod(*r, *q, *op, *op2);
}
void gmpint_divmodui(mpz_t *r, mpz_t *q, mpz_t *op, unsigned long op2) {
    mpz_divmod_ui(*r, *q, *op, op2);
}
