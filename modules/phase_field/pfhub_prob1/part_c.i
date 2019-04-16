#Phase Field Hub Benchmark Problem 1a:
#https://pages.nist.gov/pfhub/benchmarks/benchmark1.ipynb/
#MOOSE commit hash: 5a9964cd8be9fcddda0e1093e377eeae77c47629
#Ian Greenquist -- 3/19/2018

[Mesh]
  type = FileMesh
  file = tee_mesh.e
  uniform_refine = 3
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
[]

[AuxVariables]
  [./localE]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = M
    args = c
  [../]
  [./parsed]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa
    f_name = f
    w = w
  [../]
[]

[AuxKernels]
  [./totalenergy]
    type = TotalFreeEnergy
    variable = localE
    f_name = f
    interfacial_vars = c
    kappa_names = kappa
  [../]
[]

[Functions]
  [./IC_function]
    type = ParsedFunction
    vars = 'c0  eps'
    vals = '0.5 0.01'
    value = 'c0 + eps*(cos(0.105*x)*cos(0.11*y) + (cos(0.13*x)*cos(0.087*y))^2 +
             cos(0.025*x-0.15*y)*cos(0.07*x-0.02*y))'
  [../]
[]

[ICs]
  [./IC_c]
    type = FunctionIC
    variable = c
    function = IC_function
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'c_alpha c_beta squigle kappa M'
    prop_values = '0.3    0.7    5       2     5'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    args = c
    material_property_names = 'squigle c_alpha c_beta'
    f_name = f
    function = 'squigle*(c-c_alpha)*(c-c_alpha)*(c_beta-c)*(c_beta-c)'
    derivative_order = 2
  [../]
[]

[Postprocessors]
  [./totalE]
    type = ElementIntegralVariablePostprocessor
    variable = localE
  [../]
  [./memory]
    type = MemoryUsage
    mem_type = physical_memory
  [../]
  [./time_alive]
    type = PerformanceData
    event = ALIVE
  [../]
[]

[Preconditioning]
  [./coupled]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = ' asm      31                 preonly       ilu          1'
  l_tol = 1e-4
  l_max_its = 30
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  nl_max_its = 30
  steady_state_detection = true
  steady_state_tolerance = 5e-5
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 2
    optimal_iterations = 12
    growth_factor = 1.5
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
  [./log]
    type = Console
    output_file = true
    execute_postprocessors_on = 'NONE'
  [../]
[]
