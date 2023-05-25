@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Documentos Co/Pa''s lançados no banc.imp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CO_BANC_IMP_COPA
  as select from ztco_banc_imp_cp
  
  //Associação a linha do processo
  association to parent ZI_CO_BANC_IMP_PROCESS as _BancImpProcess on  $projection.Guid     = _BancImpProcess.Guid
                                                                  and $projection.GuidItem = _BancImpProcess.GuidItem

{
  key guid     as Guid,
  key guiditem as GuidItem,
  key guidcp   as GuidCp,
      bln_c_cp as CpDocument,
      gjr_c_cp as CpYear,
      bln_r_cp as CpDocumentRev,
      gjr_r_cp as CpYearRev,

      //*Associações*//
      _BancImpProcess
}
