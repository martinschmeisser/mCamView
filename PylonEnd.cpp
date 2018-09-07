#include "mex.h"
#include "../PylonProxy/PylonProxy.h"


void PylonEnd(void** Proxy)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  delete hProxy;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  
  /* Check for proper number of arguments. */
  if(nrhs!=1) {
    mexErrMsgTxt("One input required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  PylonEnd((void**)mxGetData(prhs[0]));
}