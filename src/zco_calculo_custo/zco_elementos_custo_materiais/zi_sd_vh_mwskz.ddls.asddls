@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de imposto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SD_VH_MWSKZ
  as select from    I_TaxCode     as TaxCode
    left outer join I_TaxCodeText as Text on  Text.TaxCode  = TaxCode.TaxCode
                                          and Text.Language = $session.system_language
{
       @ObjectModel.text.element: ['Name']
  key  TaxCode.TaxCode  as TaxType,
       Text.TaxCodeName as Name
}
where
  TaxCode.TaxCalculationProcedure = 'TAXBRA'
