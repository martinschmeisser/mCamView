#include "mex.h"
#include "../PylonProxy/PylonProxy.h"

#include <iostream>

/*
 *  definition of camera info array
 *  uint64_t Info
 *      1   x                   0
 *      2   y                   1
 *      3   size in bytes       2
 *      4   exposure min        3
 *      5   exposure max        4
 *      6   exposure value      5
 *      7   gain min            6
 *      8   gain max            7
 *      9   gain value          8
 *     10   black level min     9
 *     11   black level max     10
 *     12   black level value   11
 *
 *      matlab index            c index
 *
 */

void PylonSetInfo(void** Proxy, uint64_t *array)
{
  PylonProxy *hProxy = reinterpret_cast<PylonProxy*>(*Proxy);
  
  hProxy->setInfoArray(array);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  
  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>0) {
    mexErrMsgTxt("No output arguments possible.");
  }
  
  //update acquire settings of previously instantiated PylonProxy class
  //        void pointer to proxy class    array with settings
  PylonSetInfo((void**)mxGetData(prhs[0]), (uint64_t*)mxGetData(prhs[1]));
}