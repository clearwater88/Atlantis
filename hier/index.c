#include <math.h>
#include "mex.h"

void index(double res[], double data[], double szData[], double indexs[], size_t szIndex[]) {
    /* 1-indexed */
    int i,j,id;
    for (j=0; j < szIndex[0]; j++) {
        id=0;
        for (i=szIndex[1]-1; i >= 0; i--) id = id*szData[i] + (indexs[j+i*szIndex[0]]-1);
        res[j] = data[id];
    }
    return;   
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double* res;      
    double* data = mxGetPr(prhs[0]);
    double *szData = mxGetPr(prhs[1]);
    double* indexs = mxGetPr(prhs[2]);
    
    size_t szIndex[2];
    szIndex[0] = mxGetM(prhs[2]);
    szIndex[1] = mxGetN(prhs[2]);
    
    if(szIndex[1] != mxGetN(prhs[1])) mexErrMsgTxt("bad indexing: not enough dims");
    
    plhs[0] = mxCreateDoubleMatrix( (mwSize)szIndex[0], 1, mxREAL); 
    res = mxGetPr(plhs[0]);

    index(res,data, szData,indexs, szIndex);
    
    return;
}


