#include <math.h>
#include "mex.h"


int* getIndex(const mxArray* szDataMx, const mxArray* indexMx, int* idxSz) {
    /*
     * idxSz: how many (sub2ind) indices have been computed (size(indexMx,1))
     * szDataMx: how big the thing being indexed into is
     * indexMx: M x N matrix of indices. Each row is another index.
     */
    int i,j,id;
    double* szData;
    double* indexs;
    int* res;
    
    size_t szIndex[2] = {mxGetM(indexMx),mxGetN(indexMx)};
    
    szData = mxGetPr(szDataMx);
    indexs = mxGetPr(indexMx);
    
    res = malloc(szIndex[0]*sizeof(int));
    
    for (j=0; j < szIndex[0]; j++) {
        id=0;
        for (i=szIndex[1]-1; i >= 0; i--) id = id*szData[i] + (indexs[j+i*szIndex[0]]-1);
        res[j] = id;
    }
    idxSz[0] = szIndex[0];
    return res;
}

double* getRefPoint(double parType, double* refPointsTable, const mxArray* szRefPoints) {
    int idxSz;
    mxArray* mxRefPoints;
    double* refTableInd;
    double* res = malloc(2*sizeof(double));    
    int* refPointInds;
        
    /*1-indexed*/
    mxRefPoints = mxCreateDoubleMatrix( (mwSize)2, (mwSize)2, mxREAL); /*x,type;y,type*/    
    refTableInd = mxGetPr(mxRefPoints);
    refTableInd[0] = 1; refTableInd[1] = 2;
    refTableInd[2] = parType; refTableInd[3] = parType; /* parent type*/
    
    refPointInds = getIndex(szRefPoints,mxRefPoints,&idxSz);
    res[0] = refPointsTable[refPointInds[0]];
    res[1] = refPointsTable[refPointInds[1]];
    free(refPointInds);
    return res;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    const mxArray *szConversionTable, *szGBkLookUp, *gbLookUpInds, *szRefPoints;
    mxArray *mxTypes, *gBkIndsMxArray;
    size_t szGbkTable[2];
    int i,x,y, idxSz;
    double parType,chType,convToChildX,convToChildY,refPointX,refPointY;
    int* convFactorId, *idx;
    double *gBkInds, *conversionTable, *types, *refPointsTable, *res, *refPoint;
    double pointTest[2] = {18,28};
    double point[2];
    
    szGBkLookUp = prhs[1];
    gbLookUpInds = prhs[2];  
    conversionTable = mxGetPr(prhs[3]);
    szConversionTable = prhs[4];
    refPointsTable = mxGetPr(prhs[5]);
    szRefPoints = prhs[6];
    
    parType = mxGetPr(gbLookUpInds)[0];
    
    /*1-indexed*/
    mxTypes = mxCreateDoubleMatrix( (mwSize)2, (mwSize)3, mxREAL); /*x,parentType,childType;y,parentType,childType*/    
    types = mxGetPr(mxTypes);
    types[0] = 1; types[1] = 2;
    types[2] = parType; types[3] = parType;
    
    refPoint = getRefPoint(parType, refPointsTable, szRefPoints);
         
    /* get index into cell to tell us which Gbk indices to get*/
    idx = getIndex(szGBkLookUp,gbLookUpInds,&idxSz);
    if (idxSz != 1) mexErrMsgTxt("too many inds" );
    
    /* get appropriate cell entry*/
    gBkIndsMxArray = mxGetCell(prhs[0], idx[0]);
    gBkInds = mxGetPr(gBkIndsMxArray);
    
    /* initialize output to default gbk table. We will twiddle the locations in this. */
    plhs[0] = mxDuplicateArray(gBkIndsMxArray);
    res = mxGetPr(plhs[0]);
    
    szGbkTable[0] = mxGetM(gBkIndsMxArray);
    szGbkTable[1] = mxGetN(gBkIndsMxArray);
    
    for (x = 1; x <= pointTest[0]; x++) {
        point[0] = x;
        for (y = 1; y <= pointTest[1]; y++) {
            point[1] = y;
            
            for (i = 0; i < szGbkTable[1]; i++) {
                chType = gBkInds[i*szGbkTable[0]];
                types[4] = chType; types[5] = chType;

                convFactorId = getIndex(szConversionTable,mxTypes,&idxSz);
                convToChildX = conversionTable[convFactorId[0]];
                convToChildY = conversionTable[convFactorId[1]];
                free(convFactorId);

                res[szGbkTable[0]*i+1] += convToChildX*(point[0]-refPoint[0]);
                res[szGbkTable[0]*i+2] += convToChildY*(point[1]-refPoint[1]);        
            }
        }
    }
    free(refPoint);
    free(idx);

    return;
}
