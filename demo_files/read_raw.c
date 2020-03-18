// このMEX関数の使い方
//    raw = read_raw('Rawデータのファイル名', フォーマット);
//       フォーマット：1 => Little-Endian
//                    2 => Big-Endian
#include "mex.h"
#include "read_raw_main.h"

// ラッパー関数定義
void mexFunction(int           nlhs,      //出力パラメータ数
                 mxArray       *plhs[],   //出力パラメータへのポインタ配列
                 int           nrhs,      //入力パラメータ数
                 const mxArray *prhs[]) { //入力パラメータへのポインタ配列

    char   *fileName;                      //第1引数
    double *format;                        //第2引数
    unsigned short  height;           //C関数からの戻り値
    unsigned short  width;            //C関数からの戻り値
    unsigned short *pOutRaw;          //C関数からの戻り値
    
   
    fileName = mxArrayToString(prhs[0]);   //メモリ確保し、第1引数(文字列)をNULLを最後に付加してコピー
                                           //(そこへのポインタを変返す)
    format   = mxGetPr(prhs[1]);           //第2引数(double)へのポインタ

  // C関数を呼ぶ **********************************
    read_raw_main(fileName, (int)*format, &height, &width, &pOutRaw);

  // C関数からの戻り値を plhs[0]へ格納
    plhs[0] = mxCreateNumericMatrix(height, width, mxUINT16_CLASS, mxREAL);   //メモリ割当て
    memcpy((unsigned short *)mxGetData(plhs[0]), pOutRaw, height * width * sizeof(unsigned short));
    free(pOutRaw);

    mxFree(fileName);
}

// Copyright 2014 The MathWorks, Inc.
