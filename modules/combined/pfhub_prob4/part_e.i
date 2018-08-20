[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -200
  xmax = 200
  ymin = -200
  ymax = 200
  nx = 50
  ny = 50
  uniform_refine = 1
[]

[MeshModifiers]
  [./center_pt]
    type = AddExtraNodeset
    new_boundary = MID
    coord = '0 0'
  [../]
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables]
  [./eta]
    [./InitialCondition]
      type = SmoothSuperellipsoidIC
      variable = eta
      a = 22.222
      b = 18
      n = 2
      invalue = 1.0
      outvalue = 0.0065
      x1 = 0
      y1 = 0
    [../]
  [../]
  [./w]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./prec]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./f_el]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./f_tot]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[BCs]
  [./BC_x]
    type = DirichletBC
    boundary = 'MID'
    variable = disp_x
    value = 0
  [../]
  [./BC_y]
    type = DirichletBC
    boundary = 'MID'
    variable = disp_y
    value = 0
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
  [./dt]
    type = CoupledTimeDerivative
    variable = w
    v = eta
  [../]
  [./bulk]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./interface]
    type = SplitCHParsed
    variable = eta
    w = w
    kappa_name = kappa
    f_name = f_bulk
  [../]
[]

[AuxKernels]
  [./prec_aux]
    type = FeatureFloodCountAux
    variable = prec
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  [../]
  [./f_el_aux]
    type = ElasticEnergyAux
    variable = f_el
  [../]
  [./f_tot_aux]
    type = TotalFreeEnergy
    f_name = f_comb
    kappa_names = 'kappa'
    variable = f_tot
    interfacial_vars = 'eta'
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'kappa omega M'
    prop_values = '0.29 0.1 5'
  [../]
  [./h_pre]
    type = DerivativeParsedMaterial
    f_name = h_pre
    args = eta
    function = 'eta^3*(6*eta^2-15*eta+10)'
  [../]
  [./h_mat]
    type = DerivativeParsedMaterial
    f_name = h_mat
    args = 'eta'
    material_property_names = 'h_pre(eta)'
    function = '1 - h_pre'
  [../]
  [./f_bulk]
    type = DerivativeParsedMaterial
    f_name = f_bulk
    args = 'eta'
    material_property_names = 'omega'
    constant_names = 'a0 a1 a2
                      a3 a4 a5
                      a6 a7 a8
                      a9 a10'
    constant_expressions = '0 0 8.072789087
                            -81.24549382 408.0297321 -1244.129167
                            2444.046270 -3120.635139 2506.663551
                            -1151.003178 230.2006355'
    function = 'omega * (a0 + a1*eta + a2*eta^2 + a3*eta^3 + a4*eta^4
                + a5*eta^5 + a6*eta^6 + a7*eta^7 + a8*eta^8 + a9*eta^9
                + a10*eta^10)'
    derivative_order = 2
    outputs = exodus
  [../]
  [./C_pre]
    type = ComputeElasticityTensor
    C_ijkl = '250 150 0 0 0 0 0 0 100'
    fill_method = symmetric9
    base_name = C_pre
  [../]
  [./C_mat]
    type = ComputeElasticityTensor
    C_ijkl = '250 150 0 0 0 0 0 0 100'
    fill_method = symmetric9
    base_name = C_mat
  [../]
  [./C_ijkl]
    type = CompositeElasticityTensor
    args = 'eta'
    tensors = 'C_pre C_mat'
    weights = 'h_pre h_mat'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
  [./eigenstrain]
    type = ComputeEigenstrain
    block = 0
    #             S11   S22   S33 from RankTwoTensor.C
    eigen_base = '0.005 0.005 0'
    prefactor = 1
    eigenstrain_name = eigenstrain
  [../]
  [./strain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
    eigenstrain_names = eigenstrain
  [../]
  #Materials used for outputting
  [./prec_area]
    type = ParsedMaterial
    args = 'prec'
    f_name = precipitate
    function = '1 + prec'
    outputs = exodus
  [../]
  [./f_comb]
    type = ParsedMaterial
    f_name = f_comb
    args = 'f_el'
    material_property_names = 'f_bulk'
    function = 'f_bulk + f_el'
  [../]
  [./f_grad]
    type = ParsedMaterial
    f_name = f_grad
    args = 'f_tot'
    material_property_names = 'f_comb'
    function = 'f_tot - f_comb'
    outputs = exodus
  [../]
[]

[UserObjects]
  [./grain_tracker]
    type = FeatureFloodCount
    variable = eta
    threshold = 0.5
    compute_var_to_feature_map = true
  [../]
[]

[Postprocessors]
  [./prec_vol]
    type = ElementIntegralMaterialProperty
    mat_prop = precipitate
  [../]
  [./F_tot]
    type = ElementIntegralVariablePostprocessor
    variable = f_tot
  [../]
  [./F_el]
    type = ElementIntegralVariablePostprocessor
    variable = f_el
  [../]
  [./F_grad]
    type = ElementIntegralMaterialProperty
    mat_prop = f_grad
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
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'
  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-7
  start_time = 0
  end_time = 60000
  num_steps = 1000
  steady_state_detection = true
  steady_state_tolerance = 1e-06
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 5
    percent_change = 0.25
  [../]
  [./Adaptivity]
    refine_fraction = 0.99
    coarsen_fraction = 0.01
    max_h_level = 3
    initial_adaptivity = 2
    weight_names = 'eta w disp_x disp_y'
    weight_values = '1 1 0 0'
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
  print_linear_residuals = false
  [./console]
    type = Console
    output_file = true
    file_base = part_e_log
  [../]
[]
