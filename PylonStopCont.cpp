#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

void PylonStopCont(void** Proxy, void** dummy)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  
  hProxy->stopContinuous();
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, mxArray *prhs[] )
{  
  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>0) {
    mexErrMsgTxt("Too many output arguments.");
  }
  //void** test = (void**)mxGetData(prhs[1]);
  //mxDestroyArray(prhs[1]);
  PylonStopCont((void**)mxGetData(prhs[0]), NULL);
}