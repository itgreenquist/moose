[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -200
  xmax = 200
  ymin = -200
  ymax = 200
  nx = 400
  ny = 400
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables]
  [./eta]
    [./InitialCondition]
      type = SmoothCircleIC
      variable = eta
      x1 = 0
      y1 = 0
      radius = 20
      invalue = 1
      outvalue = 0.0065
    [../]
  [../]
  [./w]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
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
    type = ComputeVariableEigenstrain
    block = 0
    eigen_base = '1 1 1 0 0 0'
    prefactor = 1
    #outputs = exodus
    args = 'eta'
    eigenstrain_name = eigenstrain
  [../]
  [./strain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
    eigenstrain_names = eigenstrain
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
  petsc_options_iname = '-pc_type  -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm       lu           1'
  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10
  start_time = 0
  end_time = 1e+30
  num_steps = 100
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 1
    percent_change = 0.25
  [../]
[]

[Outputs]
  exodus = true
[]
