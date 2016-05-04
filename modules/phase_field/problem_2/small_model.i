[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  #lenght scale = nm
  xmin = -500
  xmax = 500
  ymin = -500
  ymax = 500
  uniform_refine = 1
[]

[Variables]
  [./phi]
    family = LAGRANGE
    order = FIRST
  [../]
  [./mu]
    family = LAGRANGE
    order = FIRST
  [../]
[]

[ICs]
  [./phi_ic]
    #type = SmoothCircleIC
    #variable = phi
    #radius = 100 # nm
    #x1 = 0
    #y1 = 0
    #z1 = 0
    #invalue = 1
    #outvalue = 0

    type = BoundingBoxIC
    variable = phi
    x1 = -100
    x2 = 100
    y1 = -100
    y2 = 100
    inside = 1
    outside = 0
  [../]
[]

[Kernels]
  [./time_derivative]
    type = CoupledTimeDerivative
    variable = mu
    v = phi
  [../]
  [./cahn_hilliard]
    type = SplitCHParsed
    variable = phi
    f_name = f
    kappa_name = kappa
    w = mu
  [../]
  [./mu_res]
    type = SplitCHWRes
    variable = mu
    mob_name = M
  [../]
[]

[BCs]
  [./all]
    type = DirichletBC
    value = 0
    variable = phi
    boundary = '0 1 2 3'
  [../]
[]

[Materials]
  [./consants]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'kappa M'
    prop_values = '18.7245 5'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    constant_names = 'h_0'
    constant_expressions = '1.49796'
    args = phi
    f_name = f
    function = h_0*phi^2*(phi-1)^2
  [../]
[]

[Preconditioning]
  [./precondition]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = bdf2
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm      lu          '
  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-9
  dt = 10
  end_time = 500.0
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]
