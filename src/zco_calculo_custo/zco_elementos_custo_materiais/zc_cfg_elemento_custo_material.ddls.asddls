@EndUserText.label: 'Configuração ajuste elem. custo material'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

@UI: { headerInfo: { typeName: 'Parametro',
                     typeNamePlural: 'Parametros' } }

define root view entity ZC_CFG_ELEMENTO_CUSTO_MATERIAL
  as projection on ZI_CFG_ELEMENTO_CUSTO_MATERIAL

  association [0..1] to I_TaxCode                as _TaxCode                on  _TaxCode.TaxCode                 = $projection.TaxCode
                                                                            and _TaxCode.TaxCalculationProcedure = 'TAXBRA'
  association [0..1] to I_BR_TaxType             as _TaxType                on  _TaxType.BR_TaxType = $projection.TaxType
  association [0..1] to I_GLAcctInChtAcctsTP     as _DebitAccount           on  _DebitAccount.ChartOfAccounts = 'PC3C'
                                                                            and _DebitAccount.GLAccount       = $projection.DebitAccount
  association [0..1] to I_GLAcctInChtAcctsTP     as _CreditAccount          on  _CreditAccount.ChartOfAccounts = 'PC3C'
                                                                            and _CreditAccount.GLAccount       = $projection.DebitAccount
  association [0..1] to I_AccountingDocumentType as _AccountingDocumentType on  _AccountingDocumentType.AccountingDocumentType = $projection.AccountingDocumentType


{
      @UI.facet: [ { id:       'Parametro',
                     purpose:  #STANDARD,
                     type:     #IDENTIFICATION_REFERENCE,
                     label:    'Parâmetros',
                     position: 10 } ]

      @UI: { lineItem:       [ { position: 10, importance: #HIGH } ],
             identification: [ { position: 10 } ],
             selectionField: [ { position: 10 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_SD_VH_MWSKZ', element: 'TaxType' } } ]
  key TaxCode,

      @UI: { lineItem:       [ { position: 20, importance: #HIGH } ],
             identification: [ { position: 20 } ],
             selectionField: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_SD_VH_TAXGRP', element: 'TaxGroup' } } ]
  key TaxGroup,

      @UI: { lineItem:       [ { position: 30, importance: #HIGH } ],
             identification: [ { position: 30 } ],
             selectionField: [ { position: 30 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_SD_VH_TAXTYP', element: 'TaxType' } } ]
  key TaxType,

      @UI: { lineItem:       [ { position: 40, importance: #MEDIUM } ],
             identification: [ { position: 40 } ],
             selectionField: [ { position: 40 } ] }
      Element,

      @UI: { lineItem:       [ { position: 40, importance: #MEDIUM } ],
             identification: [ { position: 40 } ] }
      Mr22,

      @UI: { lineItem:       [ { position: 50, importance: #MEDIUM } ],
             identification: [ { position: 50 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_CO_VH_SINAL', element: 'Sinal' } } ]
      Sinal,

      @UI: { lineItem:       [ { position: 60, importance: #MEDIUM } ],
             identification: [ { position: 60 } ] }
      Fb50,

      @UI: { lineItem:       [ { position: 70, importance: #MEDIUM } ],
             identification: [ { position: 70 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_FI_VH_HKONT', element: 'GlAccount' } } ]
      DebitAccount,

      @UI: { lineItem:       [ { position: 80, importance: #MEDIUM } ],
             identification: [ { position: 80 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_FI_VH_HKONT', element: 'GlAccount' } } ]
      CreditAccount,

      @UI: { lineItem:       [ { position: 90, importance: #MEDIUM } ],
             identification: [ { position: 90 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: 'ZI_CA_VH_DOCTYPE', element: 'DocType' } } ]
      AccountingDocumentType,

      /* Associations */
      _CreditAccount,
      _DebitAccount,
      _TaxCode,
      _TaxType,
      _AccountingDocumentType
}
