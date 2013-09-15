#include <math.h>
#include "mex.h"

mxArray* shiftGbkInds(const mxArray *gBkIndsMx, const mxArray *conversionMx, const mxArray *refPointMx, double point[]) {
    /* might return indices out of range */    
    
    size_t szGbkTable[2], szConversionTable[2];
    int i, chType;
    double convToChild[2];
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
		  int nrhs, const mxArray *prhs[] )
     
{ 
    double* pointsBoundary, *shiftedInds, *child, *parent, *isChild;
    int i,x,y,agInd,childType,childX,childY,childAgInd;
    double point[2], convToChild[2], message;
    
    size_t m_gbkInds,n_gbkInds,nChildren;
    
    const mwSize* dims;
    
    const mxArray *gBkIndsMx, *conversionMx, *refPointMx;
    mxArray *shiftedIndsMx, *map_TypeMx;
    
    gBkIndsMx = prhs[0];
    conversionMx = prhs[1];
    refPointMx = prhs[2];
    parent = mxGetPr(prhs[3]);
    child = mxGetPr(prhs[4]);
    
    plhs[0] =  mxCreateDoubleMatrix(1, 1, mxREAL);
        
    isChild = mxGetPr(plhs[0]);
    isChild[0] = -1;

    nChildren = mxGetN(gBkIndsMx);
    m_gbkInds = mxGetM(gBkIndsMx);
    n_gbkInds=mxGetN(gBkIndsMx);

    point[0] = parent[0];
    point[1] = parent[1];

    shiftedIndsMx = shiftGbkInds(gBkIndsMx, conversionMx, refPointMx,point);
    shiftedInds = mxGetPr(shiftedIndsMx);
    for (i=0; i < nChildren; i++) {
                    
        /*1-indexed*/
        childType = shiftedInds[m_gbkInds*i];
        childX = shiftedInds[m_gbkInds*i+1];
        childY = shiftedInds[m_gbkInds*i+2];
        childAgInd = shiftedInds[m_gbkInds*i+3];
        
        printf("type,x,y,ind: %d, %d, %d, %d\n", childType,childX,childY,childAgInd);
        
        if(abs(childType - child[0]) < 0.001 &&
                abs(childX - child[1]) < 0.001 &&
                abs(childY - child[2]) < 0.001 &&
                abs(childAgInd - child[3]) < 0.001) {
            isChild[0] = i;
        }
    }
    return;
}