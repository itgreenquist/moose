//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

//TODO I am not sure it is specific to AC, may need to change name to be more generic.

#ifndef ACKAPPAFUNCTION_H
#define ACKAPPAFUNCTION_H

#include "Kernel.h"
#include "JvarMapInterface.h"
#include "DerivativeMaterialInterface.h"

class ACKappaFunction;

template<>
InputParameters validParams<ACKappaFunction>();

class ACKappaFunction : public DerivativeMaterialInterface<JvarMapKernelInterface<Kernel>>
{
public:
  ACKappaFunction(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const NonlinearVariableName _var_name;
  const MaterialPropertyName _L_name;
  const MaterialProperty<Real> & _L;
  const MaterialProperty<Real> & _dLdvar;
  const MaterialPropertyName _kappa_name;
  const MaterialProperty<Real> & _dkappadvar;
  const MaterialProperty<Real> & _d2kappadvar2;
  const unsigned int _nv;
  std::vector<NonlinearVariableName> _v_name;
  std::vector<const VariableGradient *> _grad_v;
  std::vector<const MaterialProperty<Real> *> _dLdv;
  std::vector<const MaterialProperty<Real> *> _d2kappadvardv;

private:
  Real computeFg();
};

#endif // ACKAPPAFUNCTION_H
