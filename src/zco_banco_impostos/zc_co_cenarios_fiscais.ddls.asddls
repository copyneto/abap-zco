@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumo - Cenários p banco imposto'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

define root view entity ZC_CO_CENARIOS_FISCAIS
  as projection on ZI_CO_CENARIOS_FISCAIS {
    key Codigo,
    key ElemCusto,
    Mr22,
    Sinal,
    Fb50,
    Debito,
    Credito,
    TipoDocumento,
    CoPa,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
