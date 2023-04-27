@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Processamento Banco de Impostos'
define view entity ZI_CO_BANC_IMP_PROCESS
  as select from ztco_banc_imp_pc as BancImpProcess
  //Composição de retornod do processamento
  composition [0..*] of ZI_CO_BANC_IMP_LOG          as _BancImpLog
  //Controle do Upload
  association        to parent ZI_CO_BANC_IMP_UPLOAD       as _BancImpUpload on $projection.Guid = _BancImpUpload.Guid
  //Status do Item
  association [1..1] to ZI_CO_VH_STATUS_BC_IMP_PC   as _StatusItem           on $projection.StatusItem = _StatusItem.StatusItem
  //Nome da empresa
  association [1..1] to I_CompanyCode               as _Company              on _Company.CompanyCode = $projection.CompanyCode
  //Nome da divisão
  association [1..1] to ZI_CO_VH_DIVISION_BC_IMP_PC as _Division             on _Division.Division = $projection.Division

{
  key guid                  as Guid,
  key guiditem              as GuidItem,
      BancImpProcess.status as StatusItem,
      bukrs                 as CompanyCode,
      gsber                 as Division,
      line                  as SheetLine,

      case BancImpProcess.status
        when '01' then 3  //Item Ok
        when '02' then 1  //Item com Erro
        when '03' then 2  //Item em Processamento
        when '04' then 0  //Item não processado
        else 0
        end                 as CriticalityItem, //Criticidade

      bln_c_fb              as FbDocument,      //FB50 para ICMS
      gjr_c_fb              as FbYear,
      bln_c_fb2             as FbDocument2,     //FB50 para ICMS ST
      gjr_c_fb2             as FbYear2,
      bln_c_fb3             as FbDocument3,     //FB50 para IPI
      gjr_c_fb3             as FbYear3,
      bln_r_fb              as FbDocumentRev,   //Rev FB50 para ICMS
      gjr_r_fb              as FbYearRev,
      bln_r_fb2             as FbDocumentRev2,  //Rev FB50 para ICMS ST
      gjr_r_fb2             as FbYearRev2,
      bln_r_fb3             as FbDocumentRev3,  //Rev FB50 para IPI
      gjr_r_fb3             as FbYearRev3,
      bln_c_mr              as MrDocument,      //MR22 para ICMS
      gjr_c_mr              as MrYear,
      bln_c_mr2             as MrDocument2,     //MR22 para ICMS ST
      gjr_c_mr2             as MrYear2,
      bln_c_mr3             as MrDocument3,     //MR22 para IPI
      gjr_c_mr3             as MrYear3,
      bln_r_mr              as MrDocumentRev,   //Rev MR22 para ICMS
      gjr_r_mr              as MrYearRev,
      bln_r_mr2             as MrDocumentRev2,  //Rev MR22 para ICMS ST
      gjr_r_mr2             as MrYearRev2,
      bln_r_mr3             as MrDocumentRev3,  //Rev MR22 para IPI
      gjr_r_mr3             as MrYearRev3,
      bln_c_cp              as CpDocument,
      gjr_c_cp              as CpYear,
      bln_r_cp              as CpDocumentRev,
      gjr_r_cp              as CpYearRev,

      //*Associações*//
      _BancImpLog,
      _BancImpUpload,
      _StatusItem,
      _Company,
      _Division
}
