[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 960
  ymax = 960
  nx = 60
  ny = 60
  uniform_refine = 2
[]

[Variables]
  [./phi]
    [./InitialCondition]
      type = SmoothCircleIC
      variable = phi
      x1 = 0
      y1 = 0
      radius = 8
      invalue = 1
      outvalue = -1
      int_width = 4
    [../]
  [../]
  [./U]
    [./InitialCondition]
      type = ConstantIC
      variable = U
      value = -0.3
    [../]
    scaling = 1e6
  [../]
[]

[AuxVariables]
  [./f]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./dUdt]
    type = TimeDerivative
    variable = U
  [../]
  [./Udiffusion]
    type = MatDiffusion
    variable = U
    D_name = D
  [../]
  [./Ucoupledphi]
    type = CoefCoupledTimeDerivative
    variable = U
    v = phi
    coef = -0.5
  [../]

  [./dphidt]
    type = TimeDerivative
    variable = phi
  [../]
  [./phibulk]
    type = AllenCahn
    variable = phi
    f_name = f_chem
    mob_name = tau_inv
    args = 'U'
  [../]
  [./phi_scary]
    type = ACInterfaceKobayashi1
    variable = phi
    eps_name = eps
    mob_name = tau_inv
  [../]
  [./phi_alsoscary]
    type = ACInterfaceKobayashi2
    variable = phi
    eps_name = eps
    mob_name = tau_inv
  [../]
[]

[AuxKernels]
  [./f_aux]
    type = TotalFreeEnergy
    variable = f
    kappa_names = kappa
    f_name = f_chem
    interfacial_vars = phi
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'W0 m eps4 theta0 tau0 D'
    prop_values = '1 4 0.05      0   1 10'
  [../]
  [./lambda]
    type = ParsedMaterial
    f_name = lambda
    material_property_names = 'D tau0 W0'
    function = 'D*tau0/(0.6267*W0^2)'
  [../]
  [./f_chem]
    type = DerivativeParsedMaterial
    f_name = f_chem
    material_property_names = 'lambda'
    args = 'phi U'
    function = '-0.5*phi^2 + 0.25*phi^4 + lambda*U*phi*(1-2/3*phi^2+0.2*phi^4)'
    outputs = exodus
  [../]
  [./W]
    type = InterfaceOrientationMaterial
    op = phi
    mode_number = 4
    anisotropy_strength = 0.05
    eps_bar = 1
    reference_angle = 0
  [../]
  [./tau_inv]
    type = ParsedMaterial
    f_name = tau_inv
    material_property_names = 'eps'
    constant_names = 'W0 tau0' #W0=eps_bar from material W
    constant_expressions = '1 1'
    function = 'tau:=tau0*(eps/W0)*(eps/W0); 1/tau'
  [../]
  [./solid]
    type = ParsedMaterial
    f_name = solid
    args = 'phi'
    function = '0.5*(phi+1)'
  [../]
  [./kappa]
    type = ParsedMaterial
    f_name = kappa
    material_property_names = 'eps'
    function = 'eps*eps'
  [../]
[]

[Postprocessors]
  [./memory]
    type = MemoryUsage
  [../]
  [./solid_area]
    type = ElementIntegralMaterialProperty
    mat_prop = solid
  [../]
  [./F]
    type = ElementIntegralVariablePostprocessor
    variable = f
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
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_gmres_restart'
  petsc_options_value = 'asm       lu           31'
  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-07
  l_max_its = 30
  nl_max_its = 15
  end_time = 1500
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    iteration_window = 2
    dt = 0.1
    growth_factor = 1.1
    cutback_factor = 0.75
  [../]
  [./Adaptivity]
    initial_adaptivity = 2
    refine_fraction = 0.95
    coarsen_fraction = 0.05
    max_h_level = 4
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
  [./log]
    type = Console
    output_file = true
  [../]
[]
