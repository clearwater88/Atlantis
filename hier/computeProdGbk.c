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
    int ind=0,i,x,y,agInd,childType,childX,childY,childAgInd;
    double point[2], convToChild[2], message;
    size_t m_uGbkToFb1_0, n_uGbkToFb1_0, m_gbkInds, n_gbkInds;
    
    const mwSize* dims;
    
    const mxArray *gBkIndsMx, *conversionMx, *refPointMx, *pointsBoundaryMx, *uGbkToFb1_0, *uFb1ToSb_0_holderMx;
    mxArray * shiftedIndsMx, *uFb1ToSb_0_TypeMx;
    
    gBkIndsMx = prhs[0]; conversionMx = prhs[1]; refPointMx = prhs[2]; pointsBoundaryMx = prhs[3]; uGbkToFb1_0 = prhs[4], uFb1ToSb_0_holderMx = prhs[5];
    double* pointsBoundary = mxGetPr(pointsBoundaryMx);
    double* allMessages = mxGetPr(uGbkToFb1_0);
    double* uFb1ToSb_0_holder;
    double* shiftedInds;
    
    /*plhs[0] = mxDuplicateArray(uFb1ToSb_0_holderMx);*/
    plhs[0] = mxDuplicateArray(uFb1ToSb_0_holderMx);
    
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
                    for (i=0; i < n_uGbkToFb1_0; i++) { /* iterate over children */
                        message = allMessages[ind + m_uGbkToFb1_0*i];
                        
                        /* these are 1-indexed */
                        childType = shiftedInds[m_gbkInds*i];
                        childX = shiftedInds[m_gbkInds*i+1];
                        childY = shiftedInds[m_gbkInds*i+2];
                        childAgInd = shiftedInds[m_gbkInds*i+3];
                        
                        
                        uFb1ToSb_0_TypeMx = mxGetCell(plhs[0],childType-1);
                        uFb1ToSb_0_holder = mxGetPr(uFb1ToSb_0_TypeMx);
                        dims = mxGetDimensions(uFb1ToSb_0_TypeMx);
                        
                        if (childX < 0.99) continue;
                        if (childX > dims[0]+0.01) continue;
                        if (childY < 0.99) continue;
                        if (childY > dims[1]+0.01) continue;
                        
                        /*
                        printf("childType,x,y,agInd: %d,%d,%d,%d\n", childType, childX, childY, childAgInd);
                        printf("mess: %f \n",message);
                         */
                        
                        uFb1ToSb_0_holder[childX-1 + dims[0]*(childY-1) + dims[0]*dims[1]*(agInd-1)] *= message;
                    }
                    
                    
                    ind++;
                }
                
                mxDestroyArray(shiftedIndsMx);
            }
    }   
    
    return;
}