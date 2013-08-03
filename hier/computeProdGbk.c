#include <math.h>
#include "mex.h"

mxArray* shiftGbkInds(const mxArray *gBkIndsMx, const mxArray *conversionMx, const mxArray *refPointMx, double point[]) {
    /* might return indices out of range */    
    
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
    int ind,i,x,y,agInd,childType,childX,childY,childAgInd;
    double point[2], convToChild[2], message;
    double *pointsBoundary, *allMessages, *prodGbk, *shiftedInds;
    size_t m_uGbkToFb1_0, n_uGbkToFb1_0, m_gbkInds, n_gbkInds;
    
    const mwSize* dims;
    
    const mxArray *gBkIndsMx, *conversionMx, *refPointMx, *pointsBoundaryMx, *uGbkToFb1_0, *prodGbkMx;
    mxArray * shiftedIndsMx, *prodGbk_TypeMx;
    
    gBkIndsMx = prhs[0]; conversionMx = prhs[1]; refPointMx = prhs[2]; pointsBoundaryMx = prhs[3]; uGbkToFb1_0 = prhs[4], prodGbkMx = prhs[5];
    pointsBoundary = mxGetPr(pointsBoundaryMx);
    allMessages = mxGetPr(uGbkToFb1_0);
    
    /*plhs[0] = mxDuplicateArray(uFb1ToSb_0_holderMx);*/
    plhs[0] = mxDuplicateArray(prodGbkMx);
    
    m_uGbkToFb1_0 = mxGetM(uGbkToFb1_0);
    n_uGbkToFb1_0 = mxGetN(uGbkToFb1_0);
    m_gbkInds = mxGetM(gBkIndsMx);
    n_gbkInds=mxGetN(gBkIndsMx);
    
    for (x = 1; x <= pointsBoundary[0]; x++) {
        point[0] = x;
            for (y = 1; y <= pointsBoundary[1]; y++) {
                point[1] = y;
                shiftedIndsMx = shiftGbkInds(gBkIndsMx, conversionMx, refPointMx,point);
                shiftedInds = mxGetPr(shiftedIndsMx); 
                for (agInd=1; agInd <= pointsBoundary[2]; agInd++) {
                    
                    ind = (x-1) + (y-1)*pointsBoundary[0] + (agInd-1)*pointsBoundary[0]*pointsBoundary[1];
                    
                    for (i=0; i < n_uGbkToFb1_0; i++) { /* iterate over children */
                        message = allMessages[ind + m_uGbkToFb1_0*i];
                        
                        /* these are 1-indexed */
                        childType = shiftedInds[m_gbkInds*i];
                        childX = shiftedInds[m_gbkInds*i+1];
                        childY = shiftedInds[m_gbkInds*i+2];
                        childAgInd = shiftedInds[m_gbkInds*i+3];
                        
                        prodGbk_TypeMx = mxGetCell(plhs[0],childType-1);
                        prodGbk = mxGetPr(prodGbk_TypeMx);
                        dims = mxGetDimensions(prodGbk_TypeMx);

                        if (childX < 0.99) continue;
                        if (childX > dims[0]+0.01) continue;
                        if (childY < 0.99) continue;
                        if (childY > dims[1]+0.01) continue;
                        
                        if (ind == 1) {
                            printf("childType,x,y,agInd: %d,%d,%d,%d\n", childType, childX, childY, childAgInd);
                            printf("message: fd\n", message);
                            printf("parent x,y,agInd: %d,%d,%d\n", x,y,agInd);
                        }
                        prodGbk[childX-1 + dims[0]*(childY-1) + dims[0]*dims[1]*(childAgInd-1)] *= message;
                    }
                    
                }
                
                mxDestroyArray(shiftedIndsMx);
            }
    }   
    
    return;
}