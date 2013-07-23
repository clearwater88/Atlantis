#include <math.h>
#include "mex.h"
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    size_t sz1,sz2;
    /* matrices are M x N */
    sz1 = mxGetM(prhs[0]);
    sz2 = mxGetN(prhs[0]);
    printf("sz1,sz2: %d,%d\n",sz1,sz2);
    return;
}
