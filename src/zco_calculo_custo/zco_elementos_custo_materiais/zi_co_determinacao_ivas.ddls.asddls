@AbapCatalog.sqlViewName: 'ZICODETIVAS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Determinação tipo de IVAs'
define view ZI_CO_DETERMINACAO_IVAS
  as select distinct from ztco_cfg_elmcust as _CfgCostElement
    inner join   j_1bt007         as _IVA on  _IVA.kalsm     = 'TAXBRA'
                                          and _IVA.out_mwskz = _CfgCostElement.mwskz
{
  key _CfgCostElement.mwskz as TaxCode,
      case when _IVA.in_mwskz  is not initial and _IVA.sd_mwskz is not initial
        then 'X'
      else ' ' end          as IsTransferIVA
}
