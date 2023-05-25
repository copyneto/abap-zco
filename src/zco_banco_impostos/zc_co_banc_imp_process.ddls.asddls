@EndUserText.label: 'Processamento Banco de Impostos'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_CO_BANC_IMP_PROCESS
  as projection on ZI_CO_BANC_IMP_PROCESS
{
  key Guid,
  key GuidItem,
      @ObjectModel.text.element: ['CompanyCodeName']
      CompanyCode,
      _Company.CompanyCodeName,
      @ObjectModel.text.element: ['DivisionName']
      Division,
      _Division.DivisionName,
      SheetLine,                          //Linha planilha
      @ObjectModel.text.element: ['Description']
      _BancImpUpload.Status,              //Status
      _BancImpUpload._Status.Description, //Descrição Status
      _BancImpUpload.Criticality,         //Criticidade
      _BancImpUpload.LastChangedBy,       //Última modificação por
      _BancImpUpload.LastChangedAt,       //Última modificação Ás
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_CO_VH_STATUS_BC_IMP_PC', element: 'StatusItem' } }]
      @ObjectModel.text.element: ['DescriptionItem']
      StatusItem,
      _StatusItem.Description as DescriptionItem,
      CriticalityItem,                    //Criticidade Item
      FbDocument,                         //FB50 ICMS
      FbYear,                             //Ano  ICMS
      FbDocument2,                        //FB50 ICMS ST
      FbYear2,                            //Ano  ICMS ST
      FbDocument3,                        //FB50 IPI
      FbYear3,                            //Ano  IPI
      FbDocumentRev,                      //FB50 Estorno ICMS
      FbYearRev,                          //FB50 Estorno Ano ICMS
      FbDocumentRev2,                     //FB50 Estorno ICMS ST
      FbYearRev2,                         //FB50 Estorno Ano ICMS ST
      FbDocumentRev3,                     //FB50 Estorno IPI
      FbYearRev3,                         //FB50 Estorno Ano IPI
      MrDocument,                         //MR22 ICMS
      MrYear,                             //Ano ICMS
      MrDocument2,                        //MR22 ICMS ST
      MrYear2,                            //Ano ICMS ST
      MrDocument3,                        //MR22 IPI
      MrYear3,                            //Ano IPI
      MrDocumentRev,                      //MR22 Estorno ICMS
      MrYearRev,                          //MR22 Estorno Ano ICMS
      MrDocumentRev2,                     //MR22 Estorno ICMS ST
      MrYearRev2,                         //MR22 Estorno Ano ICMS ST
      MrDocumentRev3,                     //MR22 Estorno IPI
      MrYearRev3,                         //MR22 Estorno Ano ICMS IPI

      //*Associações*//
      _BancImpCopa   : redirected to composition child ZC_CO_BANC_IMP_COPA,
      _BancImpLog    : redirected to composition child ZC_CO_BANC_IMP_LOG,
      _BancImpUpload : redirected to parent ZC_CO_BANC_IMP_UPLOAD,
      _StatusItem

}
