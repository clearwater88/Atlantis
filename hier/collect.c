#include <math.h>
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    
    int i,x,y,sliceInd,dataSliceInd,ind,nBounds,nBoundsSlice,nDataSlice;
    double *sz, *dataSz, *bounds, *res, *data;
    int start1,start2,end1,end2;
    
    plhs[0] = mxDuplicateArray(prhs[6]);
    res = mxGetPr(plhs[0]);
    
    data =mxGetPr(prhs[0]);
    bounds = mxGetPr(prhs[1]);
    nBounds = (int) mxGetPr(prhs[2])[0];
    nBoundsSlice = (int) mxGetPr(prhs[3])[0];
    dataSz = mxGetPr(prhs[4]);
    nDataSlice = (int) mxGetPr(prhs[5])[0];
    
    for (i=0; i < nBounds; i++) {
    /*for (i=0; i < 1; i++) {*/
        sliceInd = i*nBoundsSlice;
        
        /* change to 0-indexed. Skip over angles during indexing.*/
        start1 = (int) bounds[sliceInd]-1;
        end1 = (int) bounds[sliceInd+3]-1;
        start2 = (int) bounds[sliceInd+1]-1;
        end2 = (int) bounds[sliceInd+4]-1;
        /*end2 = (int) bounds[sliceInd+3]-1;*/
        
        dataSliceInd = i*nDataSlice;
        ind = 0;
        
        /* careful with ensuring raster order!!!!*/
        for (y = start2; y <= end2; y++) {
            for (x = start1; x <= end1; x++) {            
                res[dataSliceInd+ind] = data[x+y*((int) dataSz[0])];
                ind++;
            }
        }
        
    }
}
    
    