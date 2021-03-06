//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// MOOSE includes
#include "Eigenvalue.h"
#include "EigenProblem.h"
#include "Factory.h"
#include "MooseApp.h"
#include "NonlinearEigenSystem.h"
#include "SlepcSupport.h"

registerMooseObject("MooseApp", Eigenvalue);

template <>
InputParameters
validParams<Eigenvalue>()
{
  InputParameters params = validParams<Steady>();

  params.addClassDescription("Eigenvalue solves a standard/generalized eigenvaue problem");

  params.addPrivateParam<bool>("_use_eigen_value", true);

// Add slepc options and eigen problems
#ifdef LIBMESH_HAVE_SLEPC
  Moose::SlepcSupport::getSlepcValidParams(params);

  params += Moose::SlepcSupport::getSlepcEigenProblemValidParams();
#endif
  return params;
}

Eigenvalue::Eigenvalue(const InputParameters & parameters)
  : Steady(parameters),
    _eigen_problem(*getCheckedPointerParam<EigenProblem *>(
        "_eigen_problem", "This might happen if you don't have a mesh"))
{
// Extract and store SLEPc options
#if LIBMESH_HAVE_SLEPC
  Moose::SlepcSupport::storeSlepcOptions(_fe_problem, parameters);

  Moose::SlepcSupport::storeSlepcEigenProblemOptions(_eigen_problem, parameters);
  _eigen_problem.setEigenproblemType(_eigen_problem.solverParams()._eigen_problem_type);
#endif
}

void
Eigenvalue::execute()
{
#if LIBMESH_HAVE_SLEPC
#if PETSC_RELEASE_LESS_THAN(3, 12, 0)
  // Make sure the SLEPc options are setup for this app
  Moose::SlepcSupport::slepcSetOptions(_eigen_problem, _pars);
#else
  if (!_eigen_problem.petscOptionsInserted())
  {
    PetscOptionsPush(_eigen_problem.petscOptionsDatabase());
    Moose::SlepcSupport::slepcSetOptions(_eigen_problem, _pars);
    PetscOptionsPop();
    _eigen_problem.petscOptionsInserted() = true;
  }
#endif
#endif

  Steady::execute();
}
