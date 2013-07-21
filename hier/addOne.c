#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	A_IN	prhs[0]


/* Output Arguments */

#define	RES plhs[0]

static void compute(double	res[], double	a[], size_t len) {
    size_t i;
    for (i = 0; i < len; i++) {
        res[i] = a[i]+1;
    }
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *resp; 
    double *a;
    size_t mA;
    
    mA = mxGetM(A_IN); 
    /* Create a matrix for the return argument */ 
    RES = mxCreateDoubleMatrix( (mwSize)mA, 1, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    resp = mxGetPr(RES);
    
    a = mxGetPr(A_IN); 
        
    /* Do the actual computations in a subroutine */
    compute(resp,a,mA); 
    return;
    
}
