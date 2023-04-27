@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'OKB9 Especial'
@Metadata.allowExtensions: true

define root view entity ZI_CO_OKB9
  as select from ztco_okb9
{
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_COMPANYCODEVH', element: 'CompanyCode' }}]
  key bukrs,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_CSKA', element: 'Kstar' }}]
  key kstar,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_BusinessAreaStdVH', element: 'BusinessArea' }}]
  key gsber,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_ProfitCenterStdVH', element: 'ProfitCenter' }}]
  key prctr,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CostCenterVH', element: 'CostCenter' }}]
      kostl,
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
