//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef PIECEWISEBARRIERSWITCHING_H
#define PIECEWISEBARRIERSWITCHING_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class PiecewiseBarrierSwitching;

template<>
InputParameters validParams<PiecewiseBarrierSwitching>();

class PiecewiseBarrierSwitching : public DerivativeMaterialInterface<Material>
{
public:
  PiecewiseBarrierSwitching(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();
  const VariableValue & _var;
  const VariableName _var_name;

  MaterialPropertyName _f_name;
  MaterialProperty<Real> & _prop_f;
  MaterialProperty<Real> & _prop_df;
  MaterialProperty<Real> & _prop_d2f;

  const MaterialProperty<Real> & _val_s;
  const MaterialProperty<Real> & _val_gb;
  const Real _switch;
};

#endif // PIECEWISEBARRIERSWITCHING_H
