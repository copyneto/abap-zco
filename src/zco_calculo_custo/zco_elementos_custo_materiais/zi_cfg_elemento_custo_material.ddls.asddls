@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Configuração ajuste elem. custo material'
@Metadata.allowExtensions: true
@VDM.viewType: #COMPOSITE
define root view entity ZI_CFG_ELEMENTO_CUSTO_MATERIAL
  as select from ztco_cfg_elmcust

  association [0..1] to I_TaxCode                as _TaxCode                on  _TaxCode.TaxCode                 = $projection.TaxCode
                                                                            and _TaxCode.TaxCalculationProcedure = 'TAXBRA'
  association [0..1] to I_BR_TaxType             as _TaxType                on  _TaxType.BR_TaxType = $projection.TaxType
  association [0..1] to I_GLAcctInChtAcctsTP     as _DebitAccount           on  _DebitAccount.ChartOfAccounts = 'PC3C'
                                                                            and _DebitAccount.GLAccount       = $projection.DebitAccount
  association [0..1] to I_GLAcctInChtAcctsTP     as _CreditAccount          on  _CreditAccount.ChartOfAccounts = 'PC3C'
                                                                            and _CreditAccount.GLAccount       = $projection.DebitAccount
  association [0..1] to I_AccountingDocumentType as _AccountingDocumentType on  _AccountingDocumentType.AccountingDocumentType = $projection.AccountingDocumentType
{
      @ObjectModel.foreignKey.association: '_TaxCode'
  key mwskz    as TaxCode,
  key taxgrp   as TaxGroup,
      @ObjectModel.foreignKey.association: '_TaxType'
  key taxtyp   as TaxType,
      elemento as Element,
      mr22     as Mr22,
      sinal    as Sinal,
      fb50     as Fb50,
      @ObjectModel.foreignKey.association: '_DebitAccount'
      hkont_d  as DebitAccount,
      @ObjectModel.foreignKey.association: '_CreditAccount'
      hkont_c  as CreditAccount,
      @ObjectModel.foreignKey.association: '_AccountingDocumentType'
      blart    as AccountingDocumentType,

      //Association
      _TaxCode,
      _TaxType,
      _DebitAccount,
      _CreditAccount,
      _AccountingDocumentType
}
