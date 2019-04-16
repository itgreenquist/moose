[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 70
  ymax = 23
  nx = 70
  ny = 23
  uniform_refine = 1
[]

[GlobalParams]
  op_num = 7
  var_name_base = gr
[]

[UserObjects]
  [./IC_UO]
    type =  PolycrystalVoronoi
    grain_num = 40
    rand_seed = 13
    execute_on = INITIAL
  [../]
  [./grain_tracker]
    type = GrainTracker
    remap_grains = true
    halo_level = 3
    threshold = 0.4
    connecting_threshold = 0.2
    polycrystal_ic_uo = IC_UO
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
[]

[Functions]
  [./trg_logo]
    type = ImageFunction
    file = 'TRG.png'
    threshold = 10
    lower_value = 1
    upper_value = 0
  [../]
  [./timer]
    type = PiecewiseLinear
    x = '0 20 200'
    y = '0 0 0.4'
  [../]
[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[Kernels]
  [./dt_0]
    type = TimeDerivative
    variable = gr0
  [../]
  [./AC_0]
    type = AllenCahn
    variable = gr0
    f_name = F
    mob_name = M
    args = 'gr1 gr2 gr3 gr4 gr5 gr6'
  [../]
  [./IF_0]
    type = ACInterface
    variable = gr0
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_1]
    type = TimeDerivative
    variable = gr1
  [../]
  [./AC_1]
    type = AllenCahn
    variable = gr1
    f_name = F
    mob_name = M
    args = 'gr0 gr2 gr3 gr4 gr5 gr6'
  [../]
  [./IF_1]
    type = ACInterface
    variable = gr1
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_2]
    type = TimeDerivative
    variable = gr2
  [../]
  [./AC_2]
    type = AllenCahn
    variable = gr2
    f_name = F
    mob_name = M
    args = 'gr0 gr1 gr3 gr4 gr5 gr6'
  [../]
  [./IF_2]
    type = ACInterface
    variable = gr2
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_3]
    type = TimeDerivative
    variable = gr3
  [../]
  [./AC_3]
    type = AllenCahn
    variable = gr3
    f_name = F
    mob_name = M
    args = 'gr0 gr1 gr2 gr4 gr5 gr6'
  [../]
  [./IF_3]
    type = ACInterface
    variable = gr3
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_4]
    type = TimeDerivative
    variable = gr4
  [../]
  [./AC_4]
    type = AllenCahn
    variable = gr4
    f_name = F
    mob_name = M
    args = 'gr0 gr1 gr2 gr3 gr5 gr6'
  [../]
  [./IF_4]
    type = ACInterface
    variable = gr4
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_5]
    type = TimeDerivative
    variable = gr5
  [../]
  [./AC_5]
    type = AllenCahn
    variable = gr5
    f_name = F
    mob_name = M
    args = 'gr0 gr1 gr2 gr3 gr4 gr6'
  [../]
  [./IF_5]
    type = ACInterface
    variable = gr5
    mob_name = M
    kappa_name = kappa
  [../]
  [./dt_6]
    type = TimeDerivative
    variable = gr6
  [../]
  [./AC_6]
    type = AllenCahn
    variable = gr6
    f_name = F
    mob_name = M
    args = 'gr0 gr1 gr2 gr3 gr4 gr5'
  [../]
  [./IF_6]
    type = ACInterface
    variable = gr6
    mob_name = M
    kappa_name = kappa
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = IC_UO
    [../]
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
    [../]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./ftot]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./grains_aux]
    type = FeatureFloodCountAux
    variable = grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  [../]
  [./ftot_aux]
    type = MaterialRealAux
    variable = ftot
    property = F
  [../]
[]

[Materials]
  [./constants]
    type =GenericConstantMaterial
    prop_names = 'kappa M'
    prop_values = '0.1 1'
  [../]
  [./functions]
    type = GenericFunctionMaterial
    prop_names = 'h A'
    prop_values = 'trg_logo timer'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    f_name = F
    args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6'
    material_property_names = 'h A'
    constant_names = 'eps gam'
    constant_expressions = '0.6 1.5'
    derivative_order = 2
    function = 'f_S:=eps * (0.25 * (gr0^4 + gr1^4 + gr2^4 + gr3^4 + gr4^4 + gr5^4 + gr6^4)
                  - 0.5 * (gr0^2 + gr1^2 + gr2^2 + gr3^2 + gr4^2 + gr5^2 + gr6^2)
                  + gam * (gr0^2 * (gr1^2 + gr2^2 + gr3^2 + gr4^2 + gr5^2 + gr6^2)
                  + gr1^2 * (gr2^2 + gr3^2 + gr4^2 + gr5^2 + gr6^2)
                  + gr2^2 * (gr3^2 + gr4^2 + gr5^2 + gr6^2) + gr3^2 * (gr4^2 + gr5^2 + gr6^2)
                  + gr4^2 * (gr5^2 + gr6^2) + gr5^2 * gr6^2) + 0.25);
                f_V:=eps * (gr0^2 + gr1^2 + gr2^2 + gr3^2 + gr4^2 + gr5^2 + gr6^2);
                A * (1.0 - h) * f_V + (A * (h - 1.0) + 1.0) * f_S'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -mat_mffd_type'
  petsc_options_value = 'hypre boomeramg 101 ds'
  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-9
  nl_abs_tol = 1e-9
  end_time = 200
  dt = 2
  [./Adaptivity]
    initial_adaptivity = 1
    max_h_level = 2
    refine_fraction = 0.9
    coarsen_fraction = 0.09
  [../]
[]

[Outputs]
  exodus = true
[]
