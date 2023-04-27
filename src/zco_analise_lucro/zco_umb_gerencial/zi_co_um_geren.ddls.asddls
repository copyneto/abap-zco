@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unidade Medida Gerencial'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_CO_UM_GEREN
  as select from ztco_copa_unmedg
{
      @EndUserText: {
          label: 'Família(CL)',
          quickInfo: 'Família(CL)'
      }
  key wwmt1                 as Wwmt1,   
      @Semantics.quantity.unitOfMeasure: 'Vv030Me'
      @EndUserText: {
          label: 'Unidade 30',
          quickInfo: 'Unidade 30'
      }
      vv030                 as Vv030,
      @Semantics.quantity.unitOfMeasure: 'Vv031Me'
      @EndUserText: {
          label: 'Unidade 31',
          quickInfo: 'Unidade 31'
      }
      vv031                 as Vv031,
      @Semantics.quantity.unitOfMeasure: 'Vv032Me'
      @EndUserText: {
          label: 'Unidade 32',
          quickInfo: 'Unidade 32'
      }
      vv032                 as Vv032,
      vv030_me              as Vv030Me,
      vv031_me              as Vv031Me,
      vv032_me              as Vv032Me,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
