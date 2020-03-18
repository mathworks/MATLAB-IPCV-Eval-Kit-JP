#include <stdio.h>
#include <malloc.h>

unsigned short get16Bits(FILE *fp, int format) {
   // format == 1 : little-endian
   // format == 2 : big-endian
    
   unsigned char  a0;
   unsigned char  a1;
   unsigned short a;

   a0 = fgetc(fp);
   a1 = fgetc(fp);

   switch (format) {
       case 1: a=(a1 << 8) + a0; break;
       case 2: a=(a0 << 8) + a1; break;
       default : a=10;           break;
   }
   
   return a;
}


void read_raw_main(char *fileName, int format,
                            unsigned short *pHeight,
                            unsigned short *pWidth,
                            unsigned short **ppOutRaw) {
  FILE *fp;
  int i;
  
  fp = fopen(fileName, "rb");
  if (!fp){
    return;
  }

  *pHeight = get16Bits(fp, format);
  *pWidth  = get16Bits(fp, format);
  
  *ppOutRaw = (unsigned short *)malloc((*pHeight) * (*pWidth) * sizeof(unsigned short));
  
  for (i=0; i < ((*pHeight) * (*pWidth)); i++) {
      *((*ppOutRaw) + i)  = get16Bits(fp, format);
  }
  
  fclose(fp);
}

// Copyright 2014 The MathWorks, Inc.
