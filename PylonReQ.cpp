#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

void PylonReQ(void** Proxy, int *number)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  
  hProxy->requeue(*number);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  
  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>0) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  PylonReQ((void**)mxGetData(prhs[0]),     (int*)mxGetData(prhs[1]));
}