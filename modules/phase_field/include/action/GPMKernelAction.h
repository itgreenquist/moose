//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef GPMKERNELACTION
#define GPMKERNELACTION

/**
 * Generates the necessary kernels for the Grand Potential Function for any number
 * of order parameters and chemical potentials. Can do so with two sets of order
 * parameters that use different material properties. Also able to use anisotropic
 * diffusivities for the chemical potential variables.
 **/

#include "Action.h"

class GPMKernelAction: public Action
{
public:
  GPMKernelAction(const InputParameters & parameters);

  virtual void act();

};

template <>
InputParameters validParams<GPMKernelAction>();
#endif //GPMKERNELACTION
