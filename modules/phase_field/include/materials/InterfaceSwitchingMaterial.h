//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef INTERFACESWITCHINGMATERIAL_H
#define INTERFACESWITCHINGMATERIAL_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

/**
 * This material defines interface switching materials for use with Moelans free
 * energy equation, according to Eqs. 2, 40, and 43 in Moelans et al. 2008.
 * It switches between two parameter values: a surface interface and grain boundary
 * interface.
**/

// Forward Declarations
class InterfaceSwitchingMaterial;

template<>
InputParameters validParams<InterfaceSwitchingMaterial>();

class InterfaceSwitchingMaterial : public DerivativeMaterialInterface<Material>
{
public:
  InterfaceSwitchingMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();
  std::vector<const VariableValue *> _op_vars;
  const VariableValue  *_void_var;

  MaterialPropertyName _f_name;
  unsigned int _num_gr;
  MaterialProperty<Real> & _prop_f;
  std::vector<const VariableValue *> _all_op;
  std::vector<VariableName> _all_op_names;
  std::vector<MaterialProperty<Real> *> _prop_df;
  std::vector<std::vector<MaterialProperty<Real> *>> _prop_d2f;

  const MaterialProperty<Real> & _val_s;
  const MaterialProperty<Real> & _val_gb;
  Real _err;
};

#endif // INTERFACESWITCHINGMATERIAL_H
