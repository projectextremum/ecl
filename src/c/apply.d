/*
    apply.c -- Interface to C call mechanism.
*/
/*
    Copyright (c) 1993, Giuseppe Attardi.
    Copyright (c) 2001, Juan Jose Garcia Ripoll.

    ECLS is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/


#include "ecls.h"

cl_object
APPLY(int n, cl_object (*fn)(), cl_object *x)
#ifdef ARGCALL
{ int i; ARGSTACK(n);
  for (i = 0; i < n; i++)
    CPUSH(*x++);
  return ARGCALL(n, fn);
}
#else
{
  switch (n) {
  case 0:  return (*fn)(n);
  case 1:  return (*fn)(n, x[0]);
  case 2:  return (*fn)(n, x[0],x[1]);
  case 3:  return (*fn)(n, x[0],x[1],x[2]);
  case 4:  return (*fn)(n, x[0],x[1],x[2],x[3]);
  case 5:  return (*fn)(n, x[0],x[1],x[2],x[3],x[4]);
  case 6:  return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5]);
  case 7:  return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6]);
  case 8:  return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7]);
  case 9:  return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		     x[8]);
  case 10: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9]);
  case 11: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10]);
  case 12: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11]);
  case 13: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12]);
  case 14: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13]);
  case 15: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14]);
  case 16: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15]);
  case 17: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16]);
  case 18: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17]);
  case 19: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18]);
  case 20: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19]);
  case 21: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20]);
  case 22: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21]);
  case 23: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22]);
  case 24: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23]);
  case 25: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24]);
  case 26: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25]);
  case 27: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26]);
  case 28: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27]);
  case 29: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28]);
  case 30: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29]);
  case 31: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30]);
  case 32: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31]);
  case 33: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32]);
  case 34: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33]);
  case 35: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34]);
  case 36: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35]);
  case 37: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36]);
  case 38: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37]);
  case 39: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38]);
  case 40: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39]);
  case 41: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40]);
  case 42: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41]);
  case 43: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42]);
  case 44: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43]);
  case 45: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44]);
  case 46: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45]);
  case 47: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46]);
  case 48: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47]);
  case 49: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48]);
  case 50: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49]);
  case 51: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50]);
  case 52: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51]);
  case 53: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52]);
  case 54: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53]);
  case 55: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54]);
  case 56: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55]);
  case 57: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56]);
  case 58: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57]);
  case 59: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58]);
  case 60: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59]);
  case 61: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60]);
  case 62: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60],x[61]);
  case 63: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60],x[61],x[62]);
  case 64: return (*fn)(n, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60],x[61],x[62],x[63]);
  default: FEprogram_error("Exceeded call-arguments-limit.", 0);
  } 
}
#endif ARGCALL

cl_object
APPLY_closure(int n, cl_object (*fn)(), cl_object cl, cl_object *x)
#ifdef ARGCALL
{ int i; ARGSTACK(n+1);
  CPUSH(cl);
  for (i = 0; i < n; i++)
    CPUSH(*x++);
  return ARGCALL(n++, fn);
}
#else
{
  switch (++n) {
  case 1:  return (*fn)(n, cl);
  case 2:  return (*fn)(n, cl, x[0]);
  case 3:  return (*fn)(n, cl, x[0],x[1]);
  case 4:  return (*fn)(n, cl, x[0],x[1],x[2]);
  case 5:  return (*fn)(n, cl, x[0],x[1],x[2],x[3]);
  case 6:  return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4]);
  case 7:  return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5]);
  case 8:  return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6]);
  case 9:  return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7]);
  case 10: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		     x[8]);
  case 11: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9]);
  case 12: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10]);
  case 13: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11]);
  case 14: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12]);
  case 15: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13]);
  case 16: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14]);
  case 17: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15]);
  case 18: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16]);
  case 19: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17]);
  case 20: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18]);
  case 21: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19]);
  case 22: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20]);
  case 23: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21]);
  case 24: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22]);
  case 25: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23]);
  case 26: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24]);
  case 27: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25]);
  case 28: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26]);
  case 29: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27]);
  case 30: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28]);
  case 31: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29]);
  case 32: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30]);
  case 33: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31]);
  case 34: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32]);
  case 35: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33]);
  case 36: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34]);
  case 37: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35]);
  case 38: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36]);
  case 39: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37]);
  case 40: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38]);
  case 41: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39]);
  case 42: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40]);
  case 43: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41]);
  case 44: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42]);
  case 45: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43]);
  case 46: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44]);
  case 47: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45]);
  case 48: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46]);
  case 49: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47]);
  case 50: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48]);
  case 51: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49]);
  case 52: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50]);
  case 53: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51]);
  case 54: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52]);
  case 55: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53]);
  case 56: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54]);
  case 57: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55]);
  case 58: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56]);
  case 59: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57]);
  case 60: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58]);
  case 61: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59]);
  case 62: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60]);
  case 63: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60],x[61]);
  case 64: return (*fn)(n, cl, x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],
		      x[8],x[9],x[10],x[11],x[12],x[13],x[14],
		      x[15],x[16],x[17],x[18],x[19],x[20],x[21],
		      x[22],x[23],x[24],x[25],x[26],x[27],x[28],
		      x[29],x[30],x[31],x[32],x[33],x[34],x[35],
		      x[36],x[37],x[38],x[39],x[40],x[41],x[42],
		      x[43],x[44],x[45],x[46],x[47],x[48],x[49],
		      x[50],x[51],x[52],x[53],x[54],x[55],x[56],
		      x[57],x[58],x[59],x[60],x[61],x[62]);
  default: FEprogram_error("Exceeded call-arguments-limit.", 0);
  } 
}
#endif ARGCALL
