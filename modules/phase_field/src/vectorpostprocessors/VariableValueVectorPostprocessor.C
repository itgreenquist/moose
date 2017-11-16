/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#include "VariableValueVectorPostprocessor.h"
#include "MooseMesh.h"
#include "MooseVariable.h"

template <>
InputParameters
validParams<VariableValueVectorPostprocessor>()
{
  InputParameters params = validParams<GeneralVectorPostprocessor>();
  params.addRequiredParam<VariableName>("variable", "The name of the variable that will be output.");
  return params;
}

/*
  Current status: It works in serial and debug mode, but not in opt mode. The problem
  seems to be in getting the nodal points. If I output the points to terminal the
  simulation will crash mid-outpoint, which is very odd and leads me to believe the
  problem is not with my code, but with libmesh.
  I have rebuilt libmesh once and recompiled three times and the nature of the problem
  does not change.
*/

VariableValueVectorPostprocessor::VariableValueVectorPostprocessor(
    const InputParameters & parameters)
  : GeneralVectorPostprocessor(parameters),
  _var(_fe_problem.getVariable(_tid, getParam<VariableName>("variable"))),
  _element_num(declareVector("element_number")),
  _pnt_x(declareVector("x-coordinate")),
  _pnt_y(declareVector("y-coordinate")),
  _pnt_z(declareVector("z-coordinate")),
  _element_vol(declareVector("element_volume")),
  _var_val(declareVector("variable_elemental_value")),
  _mesh(_subproblem.mesh())
{
}

void
VariableValueVectorPostprocessor::execute()
{

  const auto end = _mesh.getMesh().n_active_elem(); //Number of elements in mesh
  //Resize output vectors
  _element_num.resize(end);
  _pnt_x.resize(end);
  _pnt_y.resize(end);
  _pnt_z.resize(end);
  _element_vol.resize(end);
  _var_val.resize(end);
  for (unsigned int el = 0; el < end; ++el)
  {
    Elem* elem = _mesh.getMesh().elem_ptr(el); //Current element
    auto n_node = elem->n_nodes(); //How many nodes does the element have?
    auto vol = elem->volume(); //Volume of element

    std::cout << COLOR_BLUE << "pre-pnt " << COLOR_DEFAULT; //TODO
    Point pnt = elem->centroid(); //Take the average nodal position and variable value of the element
    std::cout << COLOR_BLUE << "post-pnt " << COLOR_DEFAULT; //TODO
    Real var_val = 0;
    for (unsigned int n = 0; n < n_node; ++n)
      var_val += _var.getElementalValue(elem, n);
    var_val /= n_node;
    std::cout << COLOR_BLUE << "post-var_val" << '\n' << COLOR_DEFAULT; //TODO

    //Write to VectorPostprocessor
    _element_num[el] = el;
    _pnt_x[el] = pnt(0);
    _pnt_y[el] = pnt(1);
    _pnt_z[el] = pnt(2);
    _element_vol[el] = vol;
    _var_val[el] = var_val;
  }
}
