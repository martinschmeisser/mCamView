#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

void PylonGetFrame(void** Proxy, int *number)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  
  *number = hProxy->getFrame();
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
  
  plhs[0] = mxCreateNumericMatrix((mwSize)1, (mwSize)1, mxINT32_CLASS, mxREAL);
  
  //get an image from previously instantiated PylonProxy class
  //        void pointer to proxy class    image buffer
  PylonGetFrame((void**)mxGetData(prhs[0]),     (int*)mxGetData(plhs[0]));
}