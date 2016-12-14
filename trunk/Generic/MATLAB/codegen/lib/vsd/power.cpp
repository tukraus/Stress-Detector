//
// File: power.cpp
//
// MATLAB Coder version            : 3.2
// C/C++ source code generated on  : 13-Dec-2016 23:51:29
//

// Include Files
#include "rt_nonfinite.h"
#include "vsd.h"
#include "power.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function Definitions

//
// Arguments    : const double a[8000]
//                double y[8000]
// Return Type  : void
//
void power(const double a[8000], double y[8000])
{
  int k;
  for (k = 0; k < 8000; k++) {
    y[k] = a[k] * a[k];
  }
}

//
// File trailer for power.cpp
//
// [EOF]
//
