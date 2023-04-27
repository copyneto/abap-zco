@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de uploads Banco de Impostos'
define root view entity ZI_CO_BANC_IMP_UPLOAD
  as select from ztco_banc_imp_up as BancImpUpload
  //Composição dos itens do processamento
  composition [0..*] of  ZI_CO_BANC_IMP_PROCESS as _BancImpProcess
  //Status do processamento
  association [1..1] to ZI_CO_VH_STATUS_BC_IMP_UP as _Status on $projection.Status = _Status.Status
{
  key guid                    as Guid,          //Guid
      filedirectory           as FileDirectory, //Arquivo
      status                  as Status,        //Status do processamento

      case status
        when '01' then 3 //Processado
        when '02' then 3 //Estornado
        when '03' then 1 //Erro ao Processar
        when '04' then 1 //Erro ao Estornar
        when '05' then 2 //Em processamento
        when '06' then 2 //Em estorno
        else 0
        end                   as Criticality,   //Criticidade

      //Campos de controle
      created_by              as CreatedBy,
      created_at              as CreatedAt,
      last_changed_by         as LastChangedBy,
      last_changed_at         as LastChangedAt,
      
      //*Associações*//
      _BancImpProcess,
      _Status
}
