#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	A_IN	prhs[0]
#define	B_IN	prhs[1]


/* Output Arguments */

#define	RES plhs[0]


static void compute(double	res[], double	a[], double	b[], size_t len) {
    size_t i;
    for (i = 0; i < len; i++) {
        res[i] = a[i]*b[i];
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
	     mexErrMsgTxt("not same size"); 
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
