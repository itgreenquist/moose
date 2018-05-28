//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ACBARRIERFUNCTION_H
#define ACBARRIERFUNCTION_H

#include "ACGrGrBase.h"

/**
 * Calculates Allen-Cahn bulk term when mu is a function of the variable. Currently
 * only supports a single input for gamma.
**/

class ACBarrierFunction;

template<>
InputParameters validParams<ACBarrierFunction>();

class ACBarrierFunction : public ACGrGrBase
{
public:
  ACBarrierFunction(const InputParameters & parameters);

protected:
  virtual Real computeDFDOP(PFFunctionType type);
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  unsigned int _n_eta;
  const NonlinearVariableName _uname;
  const MaterialPropertyName _gamma_name;
  const MaterialProperty<Real> & _gamma;
  const MaterialProperty<Real> & _dmudvar;
  const MaterialProperty<Real> & _d2mudvar2;

  const std::vector<VariableName> _vname;
  std::vector<const MaterialProperty<Real> *> _d2mudvardeta;

private:
  Real calculate_f0();
};

#endif //ACBARRIERFUNCTION_H
