@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cenários para exec. de banco imposto'
@VDM.viewType: #COMPOSITE

define root view entity ZI_CO_CENARIOS_FISCAIS
  as select from ztco_banco_imp
{
  key codigo                as Codigo,
  key elem_custo            as ElemCusto,
      mr22                  as Mr22,
      sinal                 as Sinal,
      fb50                  as Fb50,
      debito                as Debito,
      credito               as Credito,
      tipo_documento        as TipoDocumento,
      co_pa                 as CoPa,

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
