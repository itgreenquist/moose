#Phase Field Hub Benchmark Problem 2:
#https://pages.nist.gov/pfhub/benchmarks/benchmark2.ipynb/
#MOOSE commit hash: 5a9964cd8be9fcddda0e1093e377eeae77c47629
#Ian Greenquist -- 3/19/2018

[GlobalParams]
  op_num = 4
  var_name_base = eta
[]

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
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./localE]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./bnds]
  [../]
[]

[Functions]
  [./lab_logo]
    type = ImageFunction
    file = TRG.png
    threshold = 5
    lower_value = 0
    upper_value = 1.0
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
    kappa_name = kappa_c
    f_name = f_chem
    w = w
    args = 'eta0 eta1 eta2 eta3'
  [../]

  [./time_eta0]
    type = TimeDerivative
    variable = eta0
  [../]
  [./interface_eta0]
    type = ACInterface
    variable = eta0
    mob_name = L
    args = 'w c eta1 eta2 eta3'
    kappa_name = kappa_eta
  [../]
  [./AC_eta0]
    type = AllenCahn
    variable = eta0
    mob_name = L
    f_name = f_chem
    args = 'w c eta1 eta2 eta3'
  [../]

  [./time_eta1]
    type = TimeDerivative
    variable = eta1
  [../]
  [./interface_eta1]
    type = ACInterface
    variable = eta1
    mob_name = L
    args = 'w c eta0 eta2 eta3'
    kappa_name = kappa_eta
  [../]
  [./AC_eta1]
    type = AllenCahn
    variable = eta1
    mob_name = L
    f_name = f_chem
    args = 'w c eta0 eta2 eta3'
  [../]

  [./time_eta2]
    type = TimeDerivative
    variable = eta2
  [../]
  [./interface_eta2]
    type = ACInterface
    variable = eta2
    mob_name = L
    args = 'w c eta1 eta0 eta3'
    kappa_name = kappa_eta
  [../]
  [./AC_eta2]
    type = AllenCahn
    variable = eta2
    mob_name = L
    f_name = f_chem
    args = 'w c eta1 eta0 eta3'
  [../]

  [./time_eta3]
    type = TimeDerivative
    variable = eta3
  [../]
  [./interface_eta3]
    type = ACInterface
    variable = eta3
    mob_name = L
    args = 'w c eta1 eta2 eta0'
    kappa_name = kappa_eta
  [../]
  [./AC_eta3]
    type = AllenCahn
    variable = eta3
    mob_name = L
    f_name = f_chem
    args = 'w c eta1 eta2 eta0'
  [../]
[]

[AuxKernels]
  [./totalenergy]
    type = TotalFreeEnergy
    variable = localE
    f_name = f_chem
    interfacial_vars = 'c eta0 eta1 eta2 eta3'
    kappa_names = 'kappa_c kappa_eta kappa_eta kappa_eta kappa_eta'
  [../]
  [./BNDS]
    type = BndsCalcAux
    variable = bnds
  [../]
[]

[ICs]
  [./c_IC]
    type = SpecifiedSmoothCircleIC
    variable = c
    invalue = 0.8
    outvalue = 0.4
    radii = '50 50 50 50 50 50 50 50'
    x_positions = '87.5 262.5 437.5 612.5 87.5 262.5 437.5 612.5'
    y_positions = '57.5 57.5 57.5 57.5 172.5 172.5 172.5 172.5'
    z_positions = '0 0 0 0 0 0 0 0'
    int_width = 10
  [../]
  [./eta0_IC]
    type = RandomIC
    variable = eta0
    min = 0.1
    max = 1.0
    seed = 1688
  [../]
  [./eta1_IC]
    type = RandomIC
    variable = eta1
    min = 0.9
    max = 1.0
    seed = 6788
  [../]
  [./eta2_IC]
    type = RandomIC
    variable = eta2
    min = 0.9
    max = 1.0
    seed = 52912
  [../]
  [./eta3_IC]
    type = RandomIC
    variable = eta3
    min = 0.9
    max = 1.0
    seed = 91416
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'rho2 c_alpha c_beta kappa_c kappa_eta M L alpha omega'
    prop_values = '  2     0.3    0.7     3.0       3.0 5 5     5     1'
  [../]
  [./f_alpha]
    type = DerivativeParsedMaterial
    material_property_names = 'rho2 c_alpha'
    args = 'c'
    f_name = f_alpha
    function = 'rho2 * (c-c_alpha)^2'
    derivative_order = 2
  [../]
  [./f_beta]
    type = DerivativeParsedMaterial
    material_property_names = 'rho2 c_beta'
    args = 'c'
    f_name = f_beta
    function = 'rho2 * (c_beta-c)^2'
    derivative_order = 2
  [../]
  [./h]
    type = DerivativeParsedMaterial
    args = 'eta0 eta1 eta2 eta3'
    f_name = h
    function = 'h0:=6*eta0^2 - 15*eta0 + 10;
                h1:=6*eta1^2 - 15*eta1 + 10;
                h2:=6*eta2^2 - 15*eta2 + 10;
                h3:=6*eta3^2 - 15*eta3 + 10;
                eta0^3*h0 + eta1^3*h1 + eta2^3*h2 + eta3^3*h3'
    derivative_order = 2
  [../]
  [./g]
    type = DerivativeParsedMaterial
    material_property_names = 'alpha'
    args = 'eta0 eta1 eta2 eta3'
    f_name = g
    function = 'g0a:=eta0^2 * (1-eta0)^2; g0b:=eta0^2 * (eta1^2 + eta2^2 + eta3^2);
                g1a:=eta1^2 * (1-eta1)^2; g1b:=eta1^2 * (eta0^2 + eta2^2 + eta3^2);
                g2a:=eta2^2 * (1-eta2)^2; g2b:=eta2^2 * (eta0^2 + eta1^2 + eta3^2);
                g3a:=eta3^2 * (1-eta3)^2; g3b:=eta3^2 * (eta0^2 + eta1^2 + eta2^2);
                g0a + g1a + g2a + g3a + alpha*(g0b + g1b + g2b + g3b)'
    derivative_order = 2
  [../]
  [./f_chem_1]
    type = DerivativeParsedMaterial
    material_property_names = 'omega f_alpha(c) f_beta(c) h(eta0,eta1,eta2,eta3) g(eta0,eta1,eta2,eta3)'
    args = 'c eta0 eta1 eta2 eta3'
    f_name = f_chem_1
    function = 'f_alpha*(1-h) + f_beta*h + omega*g'
    derivative_order = 2
    outputs = exodus
  [../]
  [./logo]
    type = GenericFunctionMaterial
    prop_names = 'logo'
    prop_values = 'lab_logo'
  [../]
  [./f_logo]
    type = DerivativeParsedMaterial
    material_property_names = 'logo c_alpha c_beta'
    args = 'c'
    derivative_order = 2
    f_name = f_logo
    function = '0.4 * ((c - c_alpha)^2 * logo + (c - c_beta)^2 * (1 - logo))'
    outputs = exodus
  [../]
  [./f_chem]
    type = DerivativeSumMaterial
    args = 'c eta0 eta1 eta2 eta3'
    f_name = f_chem
    derivative_order = 2
    sum_materials = 'f_chem_1 f_logo'
    outputs = exodus
  [../]
[]

[Postprocessors]
  [./total_E]
    type = ElementIntegralVariablePostprocessor
    variable = localE
  [../]
  [./total_freeE]
    type = ElementIntegralMaterialProperty
    mat_prop = f_chem
  [../]
  [./memory]
    type = MemoryUsage
  [../]
  [./time_alive]
    type = PerformanceData
    event = ALIVE
  [../]
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
  steady_state_detection = true
  steady_state_tolerance = 5e-5
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2
    optimal_iterations = 9
    growth_factor = 1.4
    cutback_factor = 0.75
  [../]
  [./Adaptivity]
    initial_adaptivity = 0
    max_h_level = 1
    refine_fraction = 0.8
    coarsen_fraction = 0.1
    start_time = 0.3
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
  [./log]
    type = Console
    output_file = true
    execute_postprocessors_on = 'NONE'
  [../]
[]
