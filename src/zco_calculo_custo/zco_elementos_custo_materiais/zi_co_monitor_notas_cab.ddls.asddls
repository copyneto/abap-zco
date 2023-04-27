@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Monitor NF CO - Lanç MR22 FB50-Cabeçalho'
define root view entity ZI_CO_MONITOR_NOTAS_CAB
  as select from ztco_notas_cab as NFHeader
  //Composição dos itens
  composition [0..*] of ZI_CO_MONITOR_NOTAS_ITM as _NFItem
  //Status do processamento
  association [1..1] to ZI_CO_VH_STATUS  as _Status on $projection.Status = _Status.Status
  //Empresa
  association [1..1] to I_CompanyCode    as _Company on $projection.CompanyCode = _Company.CompanyCode

{
  key docnum as NFDocument,
      bukrs  as CompanyCode,
      pstdat as ReleaseDate,
      parid  as PartnerID,
      nfenum as NFENumber,
      status as Status,
      case status
        when '01' then 2
        when '02' then 1
        when '03' then 2
        when '04' then 2
        when '05' then 3
        when '06' then 3
        when '07' then 1
        else 0
        end  as Criticality,

      //*Associations*//
      _NFItem,
      _Status,
      _Company
}
