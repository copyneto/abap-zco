@EndUserText.label: 'Documentos Co/Pa''s lançados no banc.imp'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_CO_BANC_IMP_COPA
  as projection on ZI_CO_BANC_IMP_COPA
{
  key Guid,
  key GuidItem,
  key GuidCp,
      CpDocument,    //CO/PA              
      CpYear,        //Ano              
      CpDocumentRev, //CO/PA Estorno    
      CpYearRev,     //CO/PA Estorno Ano
      
      /* Associations */
      _BancImpProcess : redirected to parent ZC_CO_BANC_IMP_PROCESS
}
