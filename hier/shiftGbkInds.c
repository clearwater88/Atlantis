#include <math.h>
#include "mex.h"


int* getIndex(int* idxSz, const mxArray* szDataMx, const mxArray* indexMx) {
    
    int i,j,id;
    double* szData;
    double* indexs;
    
    size_t szIndex[2];
    szIndex[0] = mxGetM(indexMx);
    szIndex[1] = mxGetN(indexMx);
    
    szData = mxGetPr(szDataMx);
    indexs = mxGetPr(indexMx);
    
    int* res = malloc(sizeof(int)*szIndex[0]);
    
    /* 1-indexed */
    for (j=0; j < szIndex[0]; j++) {
        id=0;
        for (i=szIndex[1]-1; i >= 0; i--) id = id*szData[i] + (indexs[j+i*szIndex[0]]-1);
        res[j] = id;
    }
    idxSz[0] = szIndex[0];
    return res;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    
    int i, idxSz;
    int* idx = getIndex(&idxSz, prhs[1],prhs[2]);
    if (idxSz != 1) mexErrMsgTxt("too many inds" );

    plhs[0] = mxDuplicateArray (mxGetCell (prhs[0], idx[0]));
    
    
    
    free(idx);
    
    /*getIndex(temp,szGbkCell,gbkCellIndex,szGbkCellIndex);*/
    
    
    
    

    return;
}

/*
void index(double res[], double data[], double szData[], double indexs[], size_t szIndex[]) {
    
    int temp[szIndex[0]]; 
    getIndex(temp, szData,indexs, szIndex);

    int i;
    for (i=0; i < szIndex[0]; i++) {
        res[i] = data[temp[i]];
    }
    return;   
}
*/