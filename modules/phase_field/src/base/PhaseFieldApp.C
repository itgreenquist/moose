//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PhaseFieldApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

/*
 * Kernels
 */
#include "ACGBPoly.h"
#include "ACGrGrElasticDrivingForce.h"
#include "ACGrGrMulti.h"
#include "ACGrGrPoly.h"
#include "ACInterface.h"
#include "ACMultiInterface.h"
#include "ACInterfaceKobayashi1.h"
#include "ACInterfaceKobayashi2.h"
#include "ACInterfaceStress.h"
#include "AllenCahnPFFracture.h"
#include "ACSEDGPoly.h"
#include "ACSwitching.h"
#include "AllenCahn.h"
#include "CahnHilliard.h"
#include "CahnHilliardAniso.h"
#include "CHBulkPFCTrad.h"
#include "CHCpldPFCTrad.h"
#include "CHInterface.h"
#include "CHInterfaceAniso.h"
#include "CHMath.h"
#include "CHPFCRFF.h"
#include "CHSplitChemicalPotential.h"
#include "CHSplitConcentration.h"
#include "CHSplitFlux.h"
#include "CoefCoupledTimeDerivative.h"
#include "CoefReaction.h"
#include "ConservedLangevinNoise.h"
#include "CoupledAllenCahn.h"
#include "CoupledSusceptibilityTimeDerivative.h"
#include "CoupledSwitchingTimeDerivative.h"
#include "CoupledMaterialDerivative.h"
#include "GradientComponent.h"
#include "HHPFCRFF.h"
#include "KKSACBulkC.h"
#include "KKSACBulkF.h"
#include "KKSCHBulk.h"
#include "KKSMultiACBulkC.h"
#include "KKSMultiACBulkF.h"
#include "KKSMultiPhaseConcentration.h"
#include "KKSPhaseChemicalPotential.h"
#include "KKSPhaseConcentration.h"
#include "KKSSplitCHCRes.h"
#include "LangevinNoise.h"
#include "LaplacianSplit.h"
#include "MaskedBodyForce.h"
#include "MatAnisoDiffusion.h"
#include "MatDiffusion.h"
#include "MatReaction.h"
#include "MatGradSquareCoupled.h"
#include "MultiGrainRigidBodyMotion.h"
#include "PFFracBulkRate.h"
#include "PFFracCoupledInterface.h"
#include "SimpleACInterface.h"
#include "SimpleCHInterface.h"
#include "SimpleCoupledACInterface.h"
#include "SimpleSplitCHWRes.h"
#include "SingleGrainRigidBodyMotion.h"
#include "SoretDiffusion.h"
#include "SplitCHMath.h"
#include "SplitCHParsed.h"
#include "SplitCHWRes.h"
#include "SplitCHWResAniso.h"
#include "SplitPFFractureBulkRate.h"
#include "PFFractureBulkRate.h"
#include "SusceptibilityTimeDerivative.h"
#include "SwitchingFunctionConstraintEta.h"
#include "SwitchingFunctionConstraintLagrange.h"
#include "SwitchingFunctionPenalty.h"

// Remove this once the PFFracIntVar -> Reaction deprecation is expired:
#include "Reaction.h"

/*
 * Initial Conditions
 */
#include "BimodalInverseSuperellipsoidsIC.h"
#include "BimodalSuperellipsoidsIC.h"
#include "ClosePackIC.h"
#include "CrossIC.h"
#include "LatticeSmoothCircleIC.h"
#include "MultiBoundingBoxIC.h"
#include "MultiSmoothCircleIC.h"
#include "MultiSmoothSuperellipsoidIC.h"
#include "PFCFreezingIC.h"
#include "PolycrystalColoringIC.h"
#include "PolycrystalRandomIC.h"
#include "PolycrystalVoronoiVoidIC.h"
#include "RampIC.h"
#include "ReconPhaseVarIC.h"
#include "RndBoundingBoxIC.h"
#include "RndSmoothCircleIC.h"
#include "SmoothCircleIC.h"
#include "SmoothCircleFromFileIC.h"
#include "SmoothSuperellipsoidIC.h"
#include "SpecifiedSmoothCircleIC.h"
#include "SpecifiedSmoothSuperellipsoidIC.h"
#include "ThumbIC.h"
#include "Tricrystal2CircleGrainsIC.h"
#include "TricrystalTripleJunctionIC.h"

/*
 * InterfaceKernels
 */
#include "EqualGradientLagrangeInterface.h"
#include "EqualGradientLagrangeMultiplier.h"
#include "InterfaceDiffusionBoundaryTerm.h"
#include "InterfaceDiffusionFluxMatch.h"

/*
 * Materials
 */
#include "AsymmetricCrossTermBarrierFunctionMaterial.h"
#include "BarrierFunctionMaterial.h"
#include "CompositeMobilityTensor.h"
#include "ComputePolycrystalElasticityTensor.h"
#include "ConstantAnisotropicMobility.h"
#include "CrossTermBarrierFunctionMaterial.h"
#include "DeformedGrainMaterial.h"
#include "DerivativeMultiPhaseMaterial.h"
#include "DerivativeTwoPhaseMaterial.h"
#include "DiscreteNucleation.h"
#include "ElasticEnergyMaterial.h"
#include "ExternalForceDensityMaterial.h"
#include "ForceDensityMaterial.h"
#include "GBAnisotropy.h"
#include "GBDependentAnisotropicTensor.h"
#include "GBDependentDiffusivity.h"
#include "GBEvolution.h"
#include "GBWidthAnisotropy.h"
#include "GrainAdvectionVelocity.h"
#include "IdealGasFreeEnergy.h"
#include "InterfaceOrientationMaterial.h"
#include "KKSXeVacSolidMaterial.h"
#include "MathEBFreeEnergy.h"
#include "MathFreeEnergy.h"
#include "MixedSwitchingFunctionMaterial.h"
#include "MultiBarrierFunctionMaterial.h"
#include "PFCRFFMaterial.h"
#include "PFCTradMaterial.h"
#include "PFFracBulkRateMaterial.h"
#include "PFMobility.h"
#include "PFParamsPolyFreeEnergy.h"
#include "PhaseNormalTensor.h"
#include "PolynomialFreeEnergy.h"
#include "RegularSolutionFreeEnergy.h"
#include "StrainGradDispDerivatives.h"
#include "SwitchingFunction3PhaseMaterial.h"
#include "SwitchingFunctionMaterial.h"
#include "SwitchingFunctionMultiPhaseMaterial.h"
#include "ThirdPhaseSuppressionMaterial.h"
#include "TimeStepMaterial.h"
#include "VanDerWaalsFreeEnergy.h"
#include "VariableGradientMaterial.h"

/*
 * Postprocessors
 */
#include "AverageGrainVolume.h"
#include "FeatureFloodCount.h"
#include "GrainBoundaryArea.h"
#include "GrainTracker.h"
#include "GrainTrackerElasticity.h"
#include "FauxGrainTracker.h"
#include "PFCElementEnergyIntegral.h"

/*
 * AuxKernels
 */
#include "BndsCalcAux.h"
#include "CrossTermGradientFreeEnergy.h"
#include "EulerAngleVariables2RGBAux.h"
#include "FeatureFloodCountAux.h"
#include "GrainAdvectionAux.h"
#include "KKSGlobalFreeEnergy.h"
#include "KKSMultiFreeEnergy.h"
#include "PFCEnergyDensity.h"
#include "PFCRFFEnergyDensity.h"
#include "EBSDReaderAvgDataAux.h"
#include "EBSDReaderPointDataAux.h"
#include "TotalFreeEnergy.h"
#include "OutputEulerAngles.h"
#include "EulerAngleProvider2RGBAux.h"

/*
 * Functions
 */

/*
 * User Objects
 */
#include "ComputeExternalGrainForceAndTorque.h"
#include "ComputeGrainCenterUserObject.h"
#include "ComputeGrainForceAndTorque.h"
#include "ConservedMaskedNormalNoise.h"
#include "ConservedMaskedUniformNoise.h"
#include "ConservedNormalNoise.h"
#include "ConservedUniformNoise.h"
#include "ConstantGrainForceAndTorque.h"
#include "DiscreteNucleationInserter.h"
#include "DiscreteNucleationMap.h"
#include "EulerAngleUpdater.h"
#include "GrainForceAndTorqueSum.h"
#include "MaskedGrainForceAndTorque.h"
#include "PolycrystalCircles.h"
#include "PolycrystalHex.h"
#include "PolycrystalVoronoi.h"
#include "PolycrystalEBSD.h"
#include "RandomEulerAngleProvider.h"

#include "EBSDReader.h"
#include "SolutionRasterizer.h"

/*
 * Meshes
 */
#include "EBSDMesh.h"
#include "MortarPeriodicMesh.h"

/*
 * Actions
 */
#include "BicrystalBoundingBoxICAction.h"
#include "BicrystalCircleGrainICAction.h"
#include "CHPFCRFFSplitKernelAction.h"
#include "CHPFCRFFSplitVariablesAction.h"
#include "ConservedAction.h"
#include "DisplacementGradientsAction.h"
#include "EulerAngle2RGBAction.h"
#include "GrainGrowthAction.h"
#include "HHPFCRFFSplitKernelAction.h"
#include "HHPFCRFFSplitVariablesAction.h"
#include "MaterialVectorAuxKernelAction.h"
#include "MaterialVectorGradAuxKernelAction.h"
#include "MatVecRealGradAuxKernelAction.h"
#include "MortarPeriodicAction.h"
#include "MultiAuxVariablesAction.h"
#include "NonconservedAction.h"
#include "PFCRFFKernelAction.h"
#include "PFCRFFVariablesAction.h"
#include "PolycrystalColoringICAction.h"
#include "PolycrystalElasticDrivingForceAction.h"
#include "PolycrystalKernelAction.h"
#include "PolycrystalRandomICAction.h"
#include "PolycrystalStoredEnergyAction.h"
#include "PolycrystalVariablesAction.h"
#include "PolycrystalVoronoiVoidICAction.h"
#include "RigidBodyMultiKernelAction.h"
#include "Tricrystal2CircleGrainsICAction.h"
#include "GPMKernelAction.h"

/*
 * VectorPostprocessors
 */
#include "EulerAngleUpdaterCheck.h"
#include "FeatureVolumeFraction.h"
#include "FeatureVolumeVectorPostprocessor.h"
#include "GrainCentersPostprocessor.h"
#include "GrainForcesPostprocessor.h"
#include "GrainTextureVectorPostprocessor.h"

/*
 * RelationshipManagers
 */
#include "GrainTrackerHaloRM.h"
template <>
InputParameters
validParams<PhaseFieldApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

registerKnownLabel("PhaseFieldApp");

PhaseFieldApp::PhaseFieldApp(const InputParameters & parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  PhaseFieldApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  PhaseFieldApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  PhaseFieldApp::registerExecFlags(_factory);
}

PhaseFieldApp::~PhaseFieldApp() {}

// External entry point for dynamic application loading
extern "C" void
PhaseFieldApp__registerApps()
{
  PhaseFieldApp::registerApps();
}
void
PhaseFieldApp::registerApps()
{
  registerApp(PhaseFieldApp);
}

// External entry point for dynamic object registration
extern "C" void
PhaseFieldApp__registerObjects(Factory & factory)
{
  PhaseFieldApp::registerObjects(factory);
}
void
PhaseFieldApp::registerObjects(Factory & factory)
{
  Registry::registerObjectsTo(factory, {"PhaseFieldApp"});
}

// External entry point for dynamic syntax association
extern "C" void
PhaseFieldApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  PhaseFieldApp::associateSyntax(syntax, action_factory);
}
void
PhaseFieldApp::associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  Registry::registerActionsTo(action_factory, {"PhaseFieldApp"});

  registerSyntax("BicrystalBoundingBoxICAction", "ICs/PolycrystalICs/BicrystalBoundingBoxIC");
  registerSyntax("BicrystalCircleGrainICAction", "ICs/PolycrystalICs/BicrystalCircleGrainIC");
  registerSyntax("CHPFCRFFSplitKernelAction", "Kernels/CHPFCRFFSplitKernel");
  registerSyntax("CHPFCRFFSplitVariablesAction", "Variables/CHPFCRFFSplitVariables");
  registerSyntax("ConservedAction", "Modules/PhaseField/Conserved/*");
  registerSyntax("DisplacementGradientsAction", "Modules/PhaseField/DisplacementGradients");
  registerSyntax("EmptyAction", "ICs/PolycrystalICs"); // placeholder
  registerSyntax("EulerAngle2RGBAction", "Modules/PhaseField/EulerAngles2RGB");
  registerSyntax("GrainGrowthAction", "Modules/PhaseField/GrainGrowth");
  registerSyntax("HHPFCRFFSplitKernelAction", "Kernels/HHPFCRFFSplitKernel");
  registerSyntax("HHPFCRFFSplitVariablesAction", "Variables/HHPFCRFFSplitVariables");
  registerSyntax("MatVecRealGradAuxKernelAction", "AuxKernels/MatVecRealGradAuxKernel");
  registerSyntax("MaterialVectorAuxKernelAction", "AuxKernels/MaterialVectorAuxKernel");
  registerSyntax("MaterialVectorGradAuxKernelAction", "AuxKernels/MaterialVectorGradAuxKernel");
  registerSyntax("MortarPeriodicAction", "Modules/PhaseField/MortarPeriodicity/*");
  registerSyntax("MultiAuxVariablesAction", "AuxVariables/MultiAuxVariables");
  registerSyntax("PFCRFFKernelAction", "Kernels/PFCRFFKernel");
  registerSyntax("PFCRFFVariablesAction", "Variables/PFCRFFVariables");
  registerSyntax("PolycrystalColoringICAction", "ICs/PolycrystalICs/PolycrystalColoringIC");
  registerSyntax("PolycrystalElasticDrivingForceAction", "Kernels/PolycrystalElasticDrivingForce");
  registerSyntax("NonconservedAction", "Modules/PhaseField/Nonconserved/*");
  registerSyntax("PolycrystalKernelAction", "Kernels/PolycrystalKernel");
  registerSyntax("PolycrystalRandomICAction", "ICs/PolycrystalICs/PolycrystalRandomIC");
  registerSyntax("PolycrystalStoredEnergyAction", "Kernels/PolycrystalStoredEnergy");
  registerSyntax("PolycrystalVariablesAction", "Variables/PolycrystalVariables");
  registerSyntax("PolycrystalVoronoiVoidICAction", "ICs/PolycrystalICs/PolycrystalVoronoiVoidIC");
  registerSyntax("RigidBodyMultiKernelAction", "Kernels/RigidBodyMultiKernel");
  registerSyntax("Tricrystal2CircleGrainsICAction", "ICs/PolycrystalICs/Tricrystal2CircleGrainsIC");
  registerSyntax("GPMKernelAction", "Kernels/GPMKernels");

  registerAction(BicrystalBoundingBoxICAction, "add_ic");
  registerAction(BicrystalCircleGrainICAction, "add_ic");
  registerAction(CHPFCRFFSplitKernelAction, "add_kernel");
  registerAction(CHPFCRFFSplitVariablesAction, "add_variable");
  registerAction(ConservedAction, "add_variable");
  registerAction(ConservedAction, "add_kernel");
  registerAction(DisplacementGradientsAction, "add_kernel");
  registerAction(DisplacementGradientsAction, "add_material");
  registerAction(DisplacementGradientsAction, "add_variable");
  registerAction(EulerAngle2RGBAction, "add_aux_kernel");
  registerAction(EulerAngle2RGBAction, "add_aux_variable");
  registerAction(GrainGrowthAction, "add_aux_variable");
  registerAction(GrainGrowthAction, "add_aux_kernel");
  registerAction(GrainGrowthAction, "add_variable");
  registerAction(GrainGrowthAction, "add_kernel");
  registerAction(HHPFCRFFSplitKernelAction, "add_kernel");
  registerAction(HHPFCRFFSplitVariablesAction, "add_variable");
  registerAction(MaterialVectorAuxKernelAction, "add_aux_kernel");
  registerAction(MaterialVectorGradAuxKernelAction, "add_aux_kernel");
  registerAction(MatVecRealGradAuxKernelAction, "add_aux_kernel");
  registerAction(MortarPeriodicAction, "add_constraint");
  registerAction(MortarPeriodicAction, "add_mortar_interface");
  registerAction(MortarPeriodicAction, "add_variable");
  registerAction(MultiAuxVariablesAction, "add_aux_variable");
  registerAction(NonconservedAction, "add_variable");
  registerAction(NonconservedAction, "add_kernel");
  registerAction(PFCRFFKernelAction, "add_kernel");
  registerAction(PFCRFFVariablesAction, "add_variable");
  registerAction(PolycrystalElasticDrivingForceAction, "add_kernel");
  registerAction(PolycrystalColoringICAction, "add_ic");
  registerAction(PolycrystalKernelAction, "add_kernel");
  registerAction(PolycrystalRandomICAction, "add_ic");
  registerAction(PolycrystalStoredEnergyAction, "add_kernel");
  registerAction(PolycrystalVariablesAction, "add_variable");
  registerAction(PolycrystalVoronoiVoidICAction, "add_ic");
  registerAction(RigidBodyMultiKernelAction, "add_kernel");
  registerAction(Tricrystal2CircleGrainsICAction, "add_ic");
  registerAction(GPMKernelAction, "add_kernel");
}

// External entry point for dynamic execute flag registration
extern "C" void
PhaseFieldApp__registerExecFlags(Factory & factory)
{
  PhaseFieldApp::registerExecFlags(factory);
}
void
PhaseFieldApp::registerExecFlags(Factory & /*factory*/)
{
}
