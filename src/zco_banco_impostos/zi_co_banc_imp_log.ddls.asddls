@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de mensagens de retorno Banco de Imp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CO_BANC_IMP_LOG
  as select from ztco_banc_imp_lg

  association        to parent ZI_CO_BANC_IMP_PROCESS as _BancImpProcess on  $projection.Guid     = _BancImpProcess.Guid
                                                                         and $projection.GuidItem = _BancImpProcess.Guiditem
  association [1..1] to ZI_CO_VH_TYPE_BC_IMP_LG       as _Type           on  $projection.Type = _Type.Type

{
  key guid       as Guid,
  key guiditem   as GuidItem,
  key guidmsg    as GuidMsg,
      created_at as CreatedAt,
      message    as Message,
      type       as Type,

      case type
        when 'E' then 1
        when 'W' then 2
        when 'S' then 3
        when 'I' then 0
        else 0
        end      as CriticalityType, //Criticidade

      //*Associações*//
      _BancImpProcess,
      _Type
}
