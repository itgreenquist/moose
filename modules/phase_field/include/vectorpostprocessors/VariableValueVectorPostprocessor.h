/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#ifndef VARIABLEVALUEVECTORPOSTPROCESSOR_H
#define VARIABLEVALUEVECTORPOSTPROCESSOR_H

#include "GeneralVectorPostprocessor.h"


// Forward Declarations
class VariableValueVectorPostprocessor;

template <>
InputParameters validParams<VariableValueVectorPostprocessor>();

class VariableValueVectorPostprocessor : public GeneralVectorPostprocessor
{
public:
  VariableValueVectorPostprocessor(const InputParameters & parameters);

  virtual void initialize() override{}
  virtual void execute() override;
  virtual void finalize() override{}

protected:
  MooseVariable & _var;

  VectorPostprocessorValue _element_num;
  VectorPostprocessorValue _pnt_x;
  VectorPostprocessorValue _pnt_y;
  VectorPostprocessorValue _pnt_z;
  VectorPostprocessorValue _element_vol;
  VectorPostprocessorValue _var_val;
private:
  MooseMesh & _mesh;
};

#endif
