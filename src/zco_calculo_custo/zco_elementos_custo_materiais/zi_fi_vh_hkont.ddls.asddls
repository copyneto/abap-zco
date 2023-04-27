@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contas'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_VH_HKONT
  as select from    ska1 as GlAccount
    left outer join skat as Text on  Text.saknr = GlAccount.saknr
                                 and Text.ktopl = GlAccount.ktopl
                                 and Text.spras = $session.system_language
{
       @ObjectModel.text.element: ['Name']
  key  GlAccount.saknr as GlAccount,
       Text.txt50      as Name
}
where
  GlAccount.ktopl = 'PC3C'
