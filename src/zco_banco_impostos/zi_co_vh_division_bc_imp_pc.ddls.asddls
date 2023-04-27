@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Divisões para banco de impostos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CO_VH_DIVISION_BC_IMP_PC
  as select from tgsbt
{
  key spras as Spras,
  key gsber as Division,
      gtext as DivisionName
}

where
  spras = $session.system_language
