[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 700
  ymax = 230
  nx = 175
  ny = 58
  uniform_refine = 1
[]

[Variables]
  [./c]
    [./InitialCondition]
      type = RandomIC
      variable = c
      min = 0.1895
      max = 0.5895
    [../]
  [../]
  [./w]
  [../]
[]

[Functions]
  [./lab_logo]
    type = ImageFunction
    file = TRG.png
    threshold = 5
    lower_value = 1.0
    upper_value = 0.0
  [../]
[]

[Kernels]
  [./time_w]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./res_w]
    type = SplitCHWRes
    variable = w
    args = c
    mob_name = M
  [../]
  [./parsed_c]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa
    f_name = f_chem
    w = w
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'kappa M'
    prop_values = '10 10'
  [../]
  [./logo]
    type = GenericFunctionMaterial
    prop_names = 'A'
    prop_values = 'lab_logo'
    outputs = exodus
  [../]
  [./f_chem]
    type = DerivativeParsedMaterial
    f_name = f_chem
    material_property_names = 'A'
    args = 'c'
    function = 'c^2 * (1.0 - A)^2 + (1.0 - c)^2 * A^2 + c^2 * (1.0 - c)^2'
    outputs = exodus
  [../]
[]

[Postprocessors]
  [./total_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  #petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -mat_mffd_type'
  #petsc_options_value = 'hypre    boomeramg      31                 ds'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = ' asm      31                 preonly       ilu          1'
  l_max_its = 30
  l_tol = 1e-04
  nl_max_its = 30
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-9
  end_time = 1e+05
  num_steps = 100
  [./Adaptivity]
    initial_adaptivity = 0
    max_h_level = 1
    refine_fraction = 0.8
    coarsen_fraction = 0.1
    start_time = 0.3
  [../]
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.01
    percent_change = 0.25
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
[]
