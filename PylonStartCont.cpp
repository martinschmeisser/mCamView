#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

void PylonStartCont(void** Proxy, mxArray *plhs[], int numBuffers)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
    
  int imageSize = hProxy->getWidth()*hProxy->getHeight();
  int bufferSize = imageSize*sizeof(int16_t);
  
  //allocate memory for buffers in matlab, C++ code writes data here
  plhs[0] = mxCreateNumericMatrix((mwSize)imageSize, (mwSize)numBuffers, mxINT16_CLASS, mxREAL); 
  
  hProxy->startContinuous((int16_t*)mxGetData(plhs[0]), numBuffers, bufferSize);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{  
  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  int numBuffers = (*(double*)mxGetData(prhs[1]));   
  
  //get an image from previously instantiated PylonProxy class
  //        void pointer to proxy class       image buffer
  PylonStartCont((void**)mxGetData(prhs[0]),  plhs, numBuffers);
}