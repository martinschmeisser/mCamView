#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

void PylonUse(void** Proxy, mxArray *plhs[])
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  
  plhs[0] = mxCreateNumericMatrix((mwSize)hProxy->getWidth(), (mwSize)hProxy->getHeight(), mxINT16_CLASS, mxREAL);
  
  hProxy->acquire( (int16_t*)mxGetData(plhs[0]) );
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
    
  //get an image from elsewhere instantiated PylonProxy class
  //        void pointer to proxy class    image buffer
  PylonUse((void**)mxGetData(prhs[0]),     plhs);
}