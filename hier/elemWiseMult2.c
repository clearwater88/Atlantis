#include <math.h>
#include<string.h>
#include "mex.h"

/* Input Arguments */

#define	A_IN	prhs[0]
#define	B_IN	prhs[1]


/* Output Arguments */

#define	RES plhs[0]

static void compute(double res[], double *a, double	*b, size_t len) {
    size_t i;
    
    mxArray* temp = mxCreateDoubleMatrix( (mwSize)len, 1, mxREAL);
    mxArray* temp2 = mxCreateDoubleMatrix( (mwSize)len, 1, mxREAL);
    
    memcpy(mxGetPr(temp2),a, sizeof(double)*len);
    /**mxGetPr(temp2) = *a;*/ /*doesnt work; probably need to get at temp2 directly*/
    
    /*for (i=0; i < len; i++) mxGetPr(temp2)[i] = a[i];*/
    
    mexCallMATLAB(1, &temp, 1, &temp2, "addOne");
    
    double* a2 = mxGetPr(temp);
    
    for (i = 0; i < len; i++) {
        res[i] = a2[i]*b[i];
    }
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *resp; 
    double *a,*b; 
    size_t mA,mB; 
    
    /* Check for proper number of arguments */
    
    
    /* Check the dimensions of Y.  Y can be 4 X 1 or 1 X 4. */ 
    
    mA = mxGetM(A_IN); 
    mB = mxGetM(B_IN);
    if (mA != mB) {
	    error("not same size"); 
    } 
    
    /* Create a matrix for the return argument */ 
    RES = mxCreateDoubleMatrix( (mwSize)mA, 1, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    resp = mxGetPr(RES);
    
    a = mxGetPr(A_IN); 
    b = mxGetPr(B_IN);
        
    /* Do the actual computations in a subroutine */
    compute(resp,a,b,mA); 
    return;
    
}
