@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de imposto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SD_VH_TAXTYP
  as select from    I_BR_TaxType     as TaxType
    left outer join I_BR_TaxTypeText as Text on  Text.BR_TaxType = TaxType.BR_TaxType
                                             and Text.Language   = $session.system_language
{
       @ObjectModel.text.element: ['Name']
  key  TaxType.BR_TaxType as TaxType,
       Text.TaxTypeName   as Name
}
