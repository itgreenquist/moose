[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 200
  ny = 200
  xmax = 200
  xmin = 0
  ymax = 200
  ymin = 0
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./eta1]
  [../]
  [./eta2]
  [../]
  [./eta3]
  [../]
  [./eta4]
  [../]
[]

[Kernels]
  [./dcdt]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./CHWres]
    type = SplitCHWRes
    mob_name = M
    variable = w
  [../]
  [./CHParsed]
    type = SplitCHParsed
    kappa_name = kappa
    f_name = fbulk
    variable = c
    w = w
    args = 'eta1 eta2 eta3 eta4'
  [../]

  [./deta1dt]
    type = TimeDerivative
    variable = eta1
  [../]
  [./int_eta1]
    type = ACInterface
    mob_name = L
    kappa_name = kappa
    variable = eta1
  [../]
  [./bulk_eta1]
    type = AllenCahn
    mob_name = L
    f_name = fbulk
    variable = eta1
    args = 'c eta2 eta3 eta4'
  [../]

  [./deta2dt]
    type = TimeDerivative
    variable = eta2
  [../]
  [./int_eta2]
    type = ACInterface
    mob_name = L
    kappa_name = kappa
    variable = eta2
  [../]
  [./bulk_eta2]
    type = AllenCahn
    mob_name = L
    f_name = fbulk
    variable = eta2
    args = 'c eta1 eta3 eta4'
  [../]

  [./deta3dt]
    type = TimeDerivative
    variable = eta3
  [../]
  [./int_eta3]
    type = ACInterface
    mob_name = L
    kappa_name = kappa
    variable = eta3
  [../]
  [./bulk_eta3]
    type = AllenCahn
    mob_name = L
    f_name = fbulk
    variable = eta3
    args = 'c eta1 eta2 eta4'
  [../]

  [./deta4dt]
    type = TimeDerivative
    variable = eta4
  [../]
  [./int_eta4]
    type = ACInterface
    mob_name = L
    kappa_name = kappa
    variable = eta4
  [../]
  [./bulk_eta4]
    type = AllenCahn
    mob_name = L
    f_name = fbulk
    variable = eta4
    args = 'c eta1 eta2 eta3'
  [../]
[]

[AuxVariables]
  [./local_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  [./f_c]
    type = ParsedFunction
     value = 'c0+eps*(
              cos(0.105*x)*cos(0.11*y)
              +(cos(0.13*x)*cos(0.087*y))^2
              +cos(0.025*x-0.15*y)*cos(0.07*x-0.02*y)
              )'
    vars = 'c0  eps'
    vals = '0.5 0.05'
  [../]
  [./f_eta1]
    type = ParsedFunction
     value = 'eps*(
              cos((0.01*i)*x-4)*cos((0.007+0.01*i)*y)
              +cos((0.11+0.01*i)*x)*cos((0.11+0.01*i)*y)
              +psi*(
              cos((0.046+0.001*i)*x+(0.0405+0.001*i)*y)
              *cos((0.031+0.001*i)*x-(0.004+0.001*i)*y)
              )^2
              )^2'
    vars = 'eps i psi'
    vals = '0.1 1 1.5'
  [../]
  [./f_eta2]
    type = ParsedFunction
     value = 'eps*(
              cos((0.01*i)*x-4)*cos((0.007+0.01*i)*y)
              +cos((0.11+0.01*i)*x)*cos((0.11+0.01*i)*y)
              +psi*(
              cos((0.046+0.001*i)*x+(0.0405+0.001*i)*y)
              *cos((0.031+0.001*i)*x-(0.004+0.001*i)*y)
              )^2
              )^2'
    vars = 'eps i psi'
    vals = '0.1 2 1.5'
  [../]
  [./f_eta3]
    type = ParsedFunction
     value = 'eps*(
              cos((0.01*i)*x-4)*cos((0.007+0.01*i)*y)
              +cos((0.11+0.01*i)*x)*cos((0.11+0.01*i)*y)
              +psi*(
              cos((0.046+0.001*i)*x+(0.0405+0.001*i)*y)
              *cos((0.031+0.001*i)*x-(0.004+0.001*i)*y)
              )^2
              )^2'
    vars = 'eps i psi'
    vals = '0.1 3 1.5'
  [../]
  [./f_eta4]
    type = ParsedFunction
     value = 'eps*(
              cos((0.01*i)*x-4)*cos((0.007+0.01*i)*y)
              +cos((0.11+0.01*i)*x)*cos((0.11+0.01*i)*y)
              +psi*(
              cos((0.046+0.001*i)*x+(0.0405+0.001*i)*y)
              *cos((0.031+0.001*i)*x-(0.004+0.001*i)*y)
              )^2
              )^2'
    vars = 'eps i psi'
    vals = '0.1 4 1.5'
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
    variable = c
    function = f_c
  [../]
  [./eta1IC]
    type = FunctionIC
    variable = eta1
    function = f_eta1
  [../]
  [./eta2IC]
    type = FunctionIC
    variable = eta2
    function = f_eta2
  [../]
  [./eta3IC]
    type = FunctionIC
    variable = eta3
    function = f_eta3
  [../]
  [./eta4IC]
    type = FunctionIC
    variable = eta4
    function = f_eta4
  [../]
[]

[AuxKernels]
  [./local_energy]
    type = TotalFreeEnergy
    variable = local_energy
    f_name = fbulk
    interfacial_vars = 'c eta1 eta2 eta3 eta4'
    kappa_names = 'kappa kappa kappa kappa kappa'
    execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./mat]
    type = GenericConstantMaterial
    prop_names  = 'M L kappa'
    prop_values = '5 5 3'
  [../]
  [./fbulk]
    type = DerivativeParsedMaterial
    f_name = fbulk
    args = 'c eta1 eta2 eta3 eta4'
    constant_names = w
    constant_expressions = 1
    function = 'fa*(1-h)+fb*h+w*g'
    material_property_names = 'fa(c) fb(c) h(eta1,eta2,eta3,eta4) g(eta1,eta2,eta3,eta4)'
    derivative_order = 2
    outputs = exodus #EDITED
  [../]
  [./fa]
    type = DerivativeParsedMaterial
    f_name = fa
    args = c
    constant_names = '      rho     ca'
    constant_expressions = '1.41421356237 0.3'
    function = 'rho^2*(c-ca)^2'
    derivative_order = 2
  [../]
  [./fb]
    type = DerivativeParsedMaterial
    f_name = fb
    args = c
    constant_names = '      rho     cb'
    constant_expressions = '1.41421356237 0.7'
    function = 'rho^2*(cb-c)^2'
    derivative_order = 2
  [../]
  # [./h1]
  #   type = DerivativeParsedMaterial
  #   f_name = h1
  #   args = eta1
  #   function = 'eta1^3*(6*eta1^2-15*eta1+10)'
  #   derivative_order = 2
  # [../]
  # [./h2]
  #   type = DerivativeParsedMaterial
  #   f_name = h2
  #   args = eta2
  #   function = 'eta2^3*(6*eta2^2-15*eta2+10)'
  #   derivative_order = 2
  # [../]
  # [./h3]
  #   type = DerivativeParsedMaterial
  #   f_name = h3
  #   args = eta3
  #   function = 'eta3^3*(6*eta3^2-15*eta3+10)'
  #   derivative_order = 2
  # [../]
  # [./h4]
  #   type = DerivativeParsedMaterial
  #   f_name = h4
  #   args = eta4
  #   function = 'eta4^3*(6*eta4^2-15*eta4+10)'
  #   derivative_order = 2
  # [../]
  # [./h]
  #   type = DerivativeParsedMaterial
  #   f_name = h
  #   args = 'eta1 eta2 eta3 eta4'
  #   function = 'h1+h2+h3+h4'
  #   material_property_names = 'h1(eta1) h2(eta2) h3(eta3) h4(eta4)'
  #   derivative_order = 2
  #   outputs = exodus
  # [../]
  [./h]
    type = DerivativeParsedMaterial
    f_name = h
    args = 'eta1 eta2 eta3 eta4'
    function = 'eta1^3*(6*eta1^2-15*eta1+10)+eta2^3*(6*eta2^2-15*eta2+10)+eta3^3*(6*eta3^2-15*eta3+10)+eta4^3*(6*eta4^2-15*eta4+10)'
    derivative_order = 2
    outputs = exodus
  [../]
  # [./g]
  #   type = DerivativeParsedMaterial
  #   f_name = g
  #   args = 'eta1 eta2 eta3 eta4'
  #   function = 'eta1^2*(1-eta1)^2
  #               +eta2^2*(1-eta2)^2
  #               +eta3^2*(1-eta3)^2
  #               +eta4^2*(1-eta4)^2
  #               +a*(
  #               eta1^2*(eta2^2+eta3^2+eta4^2)
  #               +eta2^2*(eta1^2+eta3^2+eta4^2)
  #               +eta3^2*(eta1^2+eta2^2+eta4^2)
  #               +eta4^2*(eta1^2+eta2^2+eta3^2)
  #               )'
  #   constant_names = a
  #   constant_expressions = 5
  #   derivative_order = 2
  #   outputs = exodus
  # [../]
  [./g]
    type = DerivativeParsedMaterial
    f_name = g
    args = 'eta1 eta2 eta3 eta4'
    function = 'eta1^2*(1-eta1)^2
                +eta2^2*(1-eta2)^2
                +eta3^2*(1-eta3)^2
                +eta4^2*(1-eta4)^2
                +a*(
                (eta1^2*eta2^2+eta1^2*eta3^2+eta1^2*eta4^2)
                +(eta2^2*eta1^2+eta2^2*eta3^2+eta2^2*eta4^2)
                +(eta3^2*eta1^2+eta3^2*eta2^2+eta3^2*eta4^2)
                +(eta4^2*eta1^2+eta4^2*eta2^2+eta4^2*eta3^2)
                )'
    constant_names = a
    constant_expressions = 5
    derivative_order = 2
    outputs = exodus
  [../]
[]

[Postprocessors]
  [./memory]
    type = MemoryUsage
    mem_type = physical_memory
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_energy
    execute_on = 'initial timestep_end'
  [../]
  [./total_c]
    type = ElementAverageValue
    variable = c
    execute_on = 'initial timestep_end'
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
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           2'
  l_max_its = 15
  l_tol = 1e-4
  nl_max_its = 15
  nl_rel_tol = 1e-9
  nl_abs_tol = 1e-9
  num_steps = 10 #EDITED
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    iteration_window = 2
    optimal_iterations = 9
    growth_factor = 1.10
    cutback_factor = 0.75
  [../]
  end_time = 1e6
[]

[Outputs]
  exodus = true
  print_perf_log = true
  csv = true #EDITED
[]
