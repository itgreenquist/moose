//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PiecewiseBarrierSwitching.h"

registerMooseObject("PhaseFieldApp", PiecewiseBarrierSwitching);

template<>
InputParameters
validParams<PiecewiseBarrierSwitching>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Remember to add this later");
  params.addRequiredCoupledVar("void_variable", "Variable that determines the void phase");
  params.addRequiredParam<MaterialPropertyName>("interface_name", "Name of material property");
  params.addRequiredParam<MaterialPropertyName>("surface_value", "Value for the surface interface");
  params.addRequiredParam<MaterialPropertyName>("grain_boundary_value", "Value for the grain boundary interfaces");
  params.addParam<Real>("switch_point", 0.2, "void_variable value at which point the material switches values");
  return params;
}

PiecewiseBarrierSwitching::PiecewiseBarrierSwitching( const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
  _var(coupledValue("void_variable", 0)),
  _var_name(getVar("void_variable", 0)->name()),
  _f_name(getParam<MaterialPropertyName>("interface_name")),
  _prop_f(declareProperty<Real>(_f_name)),
  _prop_df(declarePropertyDerivative<Real>(_f_name, _var_name)),
  _prop_d2f(declarePropertyDerivative<Real>(_f_name, _var_name, _var_name)),
  _val_s(getMaterialProperty<Real>("surface_value")),
  _val_gb(getMaterialProperty<Real>("grain_boundary_value")),
  _switch(getParam<Real>("switch_point"))
{
}

void
PiecewiseBarrierSwitching::computeQpProperties()
{
  Real f = 0.0;
  Real df = 0.0;
  Real d2f = 0.0;
  if (_var[_qp] >= _switch)
    f = 1.0;
  else if (_var[_qp] > 0.0)
  {
    Real rat = _var[_qp] / _switch;
    f = rat * rat * rat *(10.0 + rat * (-15.0 + rat * 6.0));
    df = 30.0 * rat * rat * (1.0 + rat * (-2.0 + rat));
    d2f = 60.0 * rat * (1.0 + rat * (-3.0 + 2.0 * rat));
  }
  _prop_f[_qp] = _val_gb[_qp] + (_val_s[_qp] - _val_gb[_qp]) * f;
  _prop_df[_qp] = (_val_s[_qp] - _val_gb[_qp]) * df;
  _prop_d2f[_qp] = (_val_s[_qp] - _val_gb[_qp]) * d2f;
}
