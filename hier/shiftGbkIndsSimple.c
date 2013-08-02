#include <math.h>
#include "mex.h"

mxArray* shiftGbkInds(const mxArray *gBkIndsMx, const mxArray *conversionMx, const mxArray *refPointMx, double point[]) {
        
    size_t szGbkTable[2], szConversionTable[2];
    int i, chType;
    int convToChild[2];
    double *gBkInds, *conversionTable, *res, *refPoint;
    mxArray *resMx;
    
    gBkInds = mxGetPr(gBkIndsMx);
    conversionTable = mxGetPr(conversionMx);
    refPoint = mxGetPr(refPointMx);
    
    szConversionTable[0] = mxGetM(conversionMx);
    szConversionTable[1] = mxGetN(conversionMx);
    
    /* initialize output to default gbk table. We will twiddle the locations in this. */
    resMx = mxDuplicateArray(gBkIndsMx);
    res = mxGetPr(resMx);
    
    szGbkTable[0] = mxGetM(gBkIndsMx);
    szGbkTable[1] = mxGetN(gBkIndsMx);
    
    for (i = 0; i < szGbkTable[1]; i++) {
        
        chType = gBkInds[i*szGbkTable[0]]-1;
        convToChild[0] = conversionTable[szConversionTable[0]*chType];
        convToChild[1] = conversionTable[1+szConversionTable[0]*chType];
        
        res[szGbkTable[0]*i+1] += convToChild[0]*(point[0]-refPoint[0]);
        res[szGbkTable[0]*i+2] += convToChild[1]*(point[1]-refPoint[1]);
    }
    return resMx;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    int x,y;
    double pointTest[2] = {18,28};
    double point[2], convToChild[2];
    
    const mxArray *gBkIndsMx, *conversionMx, *refPointMx;
    mxArray* shiftedInds;
    gBkIndsMx = prhs[0]; conversionMx = prhs[1]; refPointMx = prhs[2];
    
    for (x = 1; x <= pointTest[0]; x++) {
        point[0] = x;
            for (y = 1; y <= pointTest[1]; y++) {
                point[1] = y;
                shiftedInds = shiftGbkInds(gBkIndsMx, conversionMx, refPointMx,point);
            }
    }
            
    
    return;
}
