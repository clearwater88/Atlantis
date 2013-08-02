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
    double* pointsBoundary, *shiftedInds, *res, *map_0;
    int ind=0,i,x,y,agInd,childType,childX,childY,childAgInd;
    double point[2], convToChild[2], message;
    size_t m_gbkInds,n_gbkInds,nChildren,m_res,n_res;
    
    const mwSize* dims;
    
    const mxArray *gBkIndsMx, *conversionMx, *refPointMx, *pointsBoundaryMx, *mapMx;
    mxArray *shiftedIndsMx, *map_TypeMx;
    
    gBkIndsMx = prhs[0];
    conversionMx = prhs[1];
    refPointMx = prhs[2];
    pointsBoundaryMx = prhs[3];
    mapMx = prhs[4]; 
    
    pointsBoundary = mxGetPr(pointsBoundaryMx);
    
    nChildren = mxGetN(gBkIndsMx);
    m_gbkInds = mxGetM(gBkIndsMx);
    n_gbkInds=mxGetN(gBkIndsMx);
    
    plhs[0] =  mxDuplicateArray(prhs[5]);
    res = mxGetPr(plhs[0]);
    m_res = mxGetM(plhs[0]);
    n_res = mxGetN(plhs[0]);

    for (x = 1; x <= pointsBoundary[0]; x++) {
        point[0] = x;
        for (y = 1; y <= pointsBoundary[1]; y++) {
            point[1] = y;
            shiftedIndsMx = shiftGbkInds(gBkIndsMx, conversionMx, refPointMx,point);
            shiftedInds = mxGetPr(shiftedIndsMx);
            for (agInd=1; agInd <= pointsBoundary[2]; agInd++) {
                for (i=0; i < nChildren; i++) {
                    
                    /*1-indexed*/
                    childType = shiftedInds[m_gbkInds*i];
                    childX = shiftedInds[m_gbkInds*i+1];
                    childY = shiftedInds[m_gbkInds*i+2];
                    childAgInd = shiftedInds[m_gbkInds*i+3];
                    
                    map_TypeMx = mxGetCell(mapMx,childType-1);
                    map_0 = mxGetPr(map_TypeMx);
                    dims = mxGetDimensions(map_TypeMx);
                    
                    if ((childX < 0.99) || (childX > dims[0]+0.01) ||
                        (childY < 0.99) || (childY > dims[1]+0.01) ) {
                        continue;
                    }
                    res[ind+m_res*i] = map_0[childX-1 + dims[0]*(childY-1) + dims[0]*dims[1]*(childAgInd-1)];
                    
                    /*
                    printf("dims: %d,%d\n", dims[0],dims[1]);
                    printf("childType,x,y,agInd: %d,%d,%d,%d\n", childType, childX, childY, childAgInd);
                     **/
                }
                ind++;
            }
        }
    }
    return;
}