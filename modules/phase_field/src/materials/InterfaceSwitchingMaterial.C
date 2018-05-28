//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "InterfaceSwitchingMaterial.h"

// I have verified, using derivative parsed materials, that this is returning the
// correct value and derivative for a two-grain problem with a void, so...
// NO EDITING THIS FILE!!

registerMooseObject("PhaseFieldApp", InterfaceSwitchingMaterial);

template<>
InputParameters
validParams<InterfaceSwitchingMaterial>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Switching function for nonuniform interfaces for surfaces and grain boundaries");
  params.addRequiredParam<MaterialPropertyName>("interface_name", "Name of the material property");
  params.addRequiredCoupledVar("void_op", "Variable that determines the void phase");
  params.addRequiredCoupledVarWithAutoBuild("gb_vars", "var_name_base", "op_num", "Array of variables that determine the solid phase");
  params.addRequiredParam<MaterialPropertyName>("surface_value", "Value for the surface interface");
  params.addRequiredParam<MaterialPropertyName>("grain_boundary_value", "Value for the grain boundary interfaces");
  params.addParam<Real>("division_min", 0.0022, "Minimum value for the switching function to use as the denominator in division");
  return params;
}

InterfaceSwitchingMaterial::InterfaceSwitchingMaterial(
  const InputParameters & parameters) : DerivativeMaterialInterface<Material>(parameters),
  _f_name(getParam<MaterialPropertyName>("interface_name")),
  _num_gr(coupledComponents("gb_vars")),
  _prop_f(declareProperty<Real>(_f_name)),
  _all_op(_num_gr+1),
  _all_op_names(_num_gr+1),
  _prop_df(_num_gr+1),
  _prop_d2f(_num_gr+1),
  _val_s(getMaterialProperty<Real>("surface_value")),
  _val_gb(getMaterialProperty<Real>("grain_boundary_value")),
  _err(getParam<Real>("division_min"))
{
  // Void phase variable is last on the list
  _all_op[_num_gr] = &coupledValue("void_op", 0); // \phi
  _all_op_names[_num_gr] = getVar("void_op", 0)->name();

  // Fetch variable values and names
  for (unsigned int i = 0; i < _num_gr; ++i)
  {
    _all_op[i] = &coupledValue("gb_vars", i); // \eta_i
    _all_op_names[i] = getVar("gb_vars", i)->name();

    // Check that no op is not listed twice
    if (_all_op_names[i] == _all_op_names[_num_gr])
      mooseError("InterfaceSwitchingMaterial: Void phase variable must be unique from grain variables.");
  } // for (unisgned int i = 0; i < _num_gr; ++i)

  //Assign Values
  for (unsigned int i = 0; i <= _num_gr; ++i)
  {
    _prop_d2f[i].resize(_num_gr + 1);
    _prop_df[i] = &declarePropertyDerivative<Real>(_f_name, _all_op_names[i]);

    for (unsigned int j = 0; j <= _num_gr; ++j)
    {
      _prop_d2f[i][j] = &declarePropertyDerivative<Real>(_f_name, _all_op_names[i], _all_op_names[j]);
    }
  } // for (unsigned int i = 0; i <= _num_gr; ++i)

} // InterfaceSwitchingMaterial::InterfaceSwitchingMaterial

void
InterfaceSwitchingMaterial::computeQpProperties()
{
  // Define surface/grain boundary region variables
  Real tau_s = 0.0;
  Real tau_gb = 0.0;
  std::vector<Real> dtau_s;
  std::vector<std::vector<Real>> d2tau_s;
  std::vector<Real> dtau_gb;
  std::vector<std::vector<Real>> d2tau_gb;

  dtau_s.resize(_num_gr+1);
  dtau_s[_num_gr] = 0.0;
  d2tau_s.resize(_num_gr+1);
  dtau_gb.resize(_num_gr+1);
  dtau_gb[_num_gr] = 0.0; // dtau_gb/dphi = 0
  d2tau_gb.resize(_num_gr+1);
  d2tau_s[_num_gr].resize(_num_gr+1);
  d2tau_gb[_num_gr].resize(_num_gr+1);
  d2tau_s[_num_gr][_num_gr] = 0.0;
  d2tau_gb[_num_gr][_num_gr] = 0.0; // d^2tau_gb/dphi^2 = 0

  // Loop through grains to calculate region variable values
  for (unsigned int i = 0; i < _num_gr; ++i)
  {
    dtau_gb[i] = 0.0;

    d2tau_s[i].resize(_num_gr+1);
    d2tau_gb[i].resize(_num_gr+1);
    d2tau_gb[_num_gr][i] = d2tau_gb[i][_num_gr] = 0.0; //d^2tau_gb/(dphi deta_i) = 0

    tau_s += (*_all_op[i])[_qp] * (*_all_op[i])[_qp];
    dtau_s[i] = 2.0 * (*_all_op[_num_gr])[_qp] * (*_all_op[_num_gr])[_qp] * (*_all_op[i])[_qp]; // dtau_s/deta_i = 2\phi^2\eta_i
    dtau_s[_num_gr] += (*_all_op[i])[_qp] * (*_all_op[i])[_qp];
    d2tau_s[i][i] = 2.0 * (*_all_op[_num_gr])[_qp] * (*_all_op[_num_gr])[_qp]; // d^2tau_s/deta_i^2 = 2 \phi^2
    d2tau_s[_num_gr][i] = d2tau_s[i][_num_gr] = 4.0 * (*_all_op[_num_gr])[_qp] * (*_all_op[i])[_qp]; // d^2tau_s/(dphi deta_i) = 4 \phi \eta_i
    d2tau_s[_num_gr][_num_gr] += 2.0 * (*_all_op[i])[_qp] * (*_all_op[i])[_qp]; // d^2tau_s/dphi^2 = 2 /sum_i \eta_i^2
    for (unsigned int j = 0; j < _num_gr; ++j)
    {
      if (j != i)
      {
        dtau_gb[i] += (*_all_op[j])[_qp] * (*_all_op[j])[_qp];
        d2tau_gb[i][i] += 2.0 * (*_all_op[j])[_qp] * (*_all_op[j])[_qp]; // d^2tau_gb/deta_i^2 = 2 \sum_{j!=i}\eta_j^2
        d2tau_gb[i][j] = 4.0 * (*_all_op[i])[_qp] * (*_all_op[j])[_qp]; // d^2tau_gb/(deta_i d_eta_j) = 4 \eta_i \eta_j
        d2tau_s[i][j] = 0.0; // d^2tau_s/(deta_i deta_j) = 0
      } // if (j != i)
      if (j > i)
      {
        tau_gb += (*_all_op[i])[_qp] * (*_all_op[i])[_qp] * (*_all_op[j])[_qp] * (*_all_op[j])[_qp]; // tau_gb = \sum_i \sum_{j>i} \eta_i^2 \eta_j^2
      } // if (j > i)
    } // for (unsigned int j = 0; j < _num_gr; ++j)
    dtau_gb[i] *= 2.0 * (*_all_op[i])[_qp]; // dtau_gb/deta_i = 2\eta_i \sum_{j!=i}\eta_j^2

  } // for (unsigned int i = 0; i < _num_gr; ++i)
  tau_s *= (*_all_op[_num_gr])[_qp] * (*_all_op[_num_gr])[_qp]; // tau_s = \phi^2 \sum_i \eta_i^2
  dtau_s[_num_gr] *= 2.0 * (*_all_op[_num_gr])[_qp]; // dtau_s/dphi = 2\phi \sum_i \eta_i^2

  // Calculate switching function value
  if ((tau_s < _err) && (tau_gb < _err))
  {
    // If the denominator will be too small, use a Taylor expansion to estimate the switching function value
    Real f0 = (_val_s[_qp] + _val_gb[_qp]) * 0.5;
    Real df0dtaus = (_val_s[_qp] - _val_gb[_qp]) / (4.0 * _err);
    Real df0dtaugb = (_val_gb[_qp] - _val_s[_qp]) / (4.0 * _err);
    Real d2f0dtaus2 = (_val_gb[_qp] - _val_s[_qp]) / (4.0 * _err * _err);
    Real d2f0dtaugb2 = (_val_s[_qp] - _val_gb[_qp]) / (4.0 * _err * _err);

    _prop_f[_qp] = f0 + (tau_s - _err) * df0dtaus + (tau_gb - _err) * df0dtaugb
      + 0.5 * ((tau_s - _err) * (tau_s - _err) * d2f0dtaus2 + (tau_gb - _err) * (tau_gb - _err) * d2f0dtaugb2);

    for (unsigned int i = 0; i <= _num_gr; ++i)
    {
      (*_prop_df[i])[_qp] = df0dtaus * dtau_s[i] + df0dtaugb * dtau_gb[i]
        + (tau_s - _err) * d2f0dtaus2 * dtau_s[i] + (tau_gb - _err) * d2f0dtaugb2 * dtau_gb[i];
      for (unsigned int j = i; j <= _num_gr; ++j)
      {
        Real term1 = df0dtaus * d2tau_s[i][j] + df0dtaugb * d2tau_gb[i][j];
        Real term2 = d2f0dtaus2 * (dtau_s[i] * dtau_s[j] + (tau_s - _err) * d2tau_s[i][j]);
        Real term3 = d2f0dtaugb2 * (dtau_gb[i] * dtau_gb[j] + (tau_gb - _err) * d2tau_gb[i][j]);
        (*_prop_d2f[i][j])[_qp] = term1 + term2 + term3;
        (*_prop_d2f[j][i])[_qp] = term1 + term2 + term3;
      } // for (unsigned int j = i; j <= _num_gr; ++j)
    } // for (unsigned int i = 0; i <= _num_gr; ++i)
  } // if ((tau_s < _err) && (tau_gb < _err))
  else
  {
    Real denominator = tau_s + tau_gb;
    Real numerator = _val_s[_qp] * tau_s + _val_gb[_qp] * tau_gb;
    // Function value
    _prop_f[_qp] = numerator / denominator;

    // Derivative Values
    for (unsigned int i = 0; i <= _num_gr; ++i)
    {
      (*_prop_df[i])[_qp] = (_val_s[_qp] * dtau_s[i] + _val_gb[_qp] * dtau_gb[i]) / denominator
        - (dtau_s[i] + dtau_gb[i]) * numerator / (denominator * denominator);

      // Second derivative values
      for (unsigned int j = i; j <= _num_gr; ++j)
      {
        (*_prop_d2f[i][j])[_qp] = (_val_s[_qp] * d2tau_s[i][j] + _val_gb[_qp] * d2tau_gb[i][j]) / denominator
          + 2.0 * (dtau_s[i] + dtau_gb[i]) * (dtau_s[j] + dtau_gb[j]) * numerator
          / (denominator * denominator * denominator)
          - ((dtau_s[i] + dtau_gb[i]) * (_val_s[_qp] * dtau_s[j] + _val_gb[_qp] * dtau_gb[j])
          +  (dtau_s[j] + dtau_gb[j]) * (_val_s[_qp] * dtau_s[i] + _val_gb[_qp] * dtau_gb[i])
          + (d2tau_s[i][j] + d2tau_gb[i][j]) * numerator) / (denominator * denominator);
        (*_prop_d2f[j][i])[_qp] = (*_prop_d2f[i][j])[_qp];
      } // for (unsigned int j = i; j <= _num_gr; ++j)
    } // for (unsigned int i = 0; i <= _num_gr; ++i)
  } // else
} // InterfaceSwitchingMaterial::computeQpProperties()
