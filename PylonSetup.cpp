#include "mex.h"
#include "../PylonProxy/PylonProxy.h"


void PylonSetup(void* &hProxy)
{
  hProxy = reinterpret_cast<void*>(new PylonProxy());
  //mexPrintf("hProxy is %d\n", hProxy);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  
  /* Check for proper number of arguments. */
  if(nrhs!=0) {
    mexErrMsgTxt("No input required.");
  } else if(nlhs>2) {
    mexErrMsgTxt("Too many output arguments.");
  }  
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  plhs[1] = mxCreateNumericMatrix(1, 12, mxUINT64_CLASS, mxREAL);
  
  void* temp = NULL;
  PylonSetup(temp);
  
  *((void**)mxGetData(plhs[0])) = temp;
  ((PylonProxy*)temp)->getInfoArray((uint64_t*) mxGetData(plhs[1]));
}
