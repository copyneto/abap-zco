@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Grupo de imposto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SD_VH_TAXGRP 
  as select from    dd07l as Domain
    left outer join dd07t as Text on  Text.domname    = Domain.domname
                                  and Text.as4local   = Domain.as4local
                                  and Text.valpos     = Domain.valpos
                                  and Text.as4vers    = Domain.as4vers
                                  and Text.ddlanguage = $session.system_language
{
       @ObjectModel.text.element: ['Name']
  key  Domain.domvalue_l as TaxGroup,
       Text.ddtext       as Name
}
where
  Domain.domname = 'J_1BTAXGRP'
