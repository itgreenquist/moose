[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 960
  ymax = 960
  nx = 240
  ny = 240
  uniform_refine = 1
[]

[Variables]
  [./phi]
  [../]
  [./U]
  [../]
[]

[Kernels]
  [./dUdt]
    type = TimeDerivative
    variable = U
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'W0 m eps4 theta0 tau0 D Delta'
    prop_values = '1 4 0.05      0   1 10  -0.3'
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
  [../]
[]
