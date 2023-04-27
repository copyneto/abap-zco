@EndUserText.label: 'Log de mensagens de retorno Banco de Imp'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_CO_BANC_IMP_LOG
  as projection on ZI_CO_BANC_IMP_LOG
{
  key Guid,                                                 //Guid do Log Upload
  key GuidItem,                                             //Guid do item excel
  key GuidMsg,                                              //Guid do Log de Mensagem
      @ObjectModel.text.element: ['Description']
      _BancImpProcess._BancImpUpload.Status,                //Status
      _BancImpProcess._BancImpUpload._Status.Description,   //Descrição Status
      _BancImpProcess._BancImpUpload.Criticality,           //Criticidade
      _BancImpProcess._BancImpUpload.LastChangedBy,         //Última modificação por
      _BancImpProcess._BancImpUpload.LastChangedAt,         //Última modificação Ás
      _BancImpProcess.SheetLine,                            //Linha da planilha
      @ObjectModel.text.element: ['DescriptionItem']
      _BancImpProcess.StatusItem,                           //Status do Item
      _BancImpProcess._StatusItem.Description as DescriptionItem, 
      _BancImpProcess.CriticalityItem,                      //Criticidade do Item
      CreatedAt,                                            //Data de criação da mensagem
      Message,                                              //Mensagem
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_CO_VH_TYPE_BC_IMP_LG', element: 'Type' } }]
      @ObjectModel.text.element: ['DescriptionType']
      Type,                                                 //Tipo de Mensagem
      _Type.Description as DescriptionType,                 //Descrição do Tipo
      CriticalityType,                                      //Criticidade do retorno
      
      /* Associations */
      _BancImpProcess : redirected to parent ZC_CO_BANC_IMP_PROCESS,
      _Type
}
