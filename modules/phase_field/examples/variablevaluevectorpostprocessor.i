[Mesh]
  type = GeneratedMesh
  nx = 10
  ny = 10
  dim = 2
  xmin = 0
  xmax = 20
  ymin = 0
  ymax = 20
[]

[Variables]
  [./var]
    family = LAGRANGE
    order = FIRST
    [./InitialCondition]
      type = FunctionIC
      function = 'y'
    [../]
  [../]
[]

[Kernels]
  [./no_change]
    type = TimeDerivative
    variable = var
  [../]
[]

[VectorPostprocessors]
  [./variable_value]
    type = VariableValueVectorPostprocessor
    variable = var
    execute_on = timestep_end
    outputs = 'csv console'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  dt = 1
  num_steps = 1
  nl_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
  csv = true
[]
