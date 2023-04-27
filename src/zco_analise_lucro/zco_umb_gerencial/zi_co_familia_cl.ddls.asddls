@AbapCatalog.sqlViewName: 'ZV_FAMILIACL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Pesquisa Familia CL'
define view ZI_CO_FAMILIA_CL
  as select from t25a0
{
  key spras as Spras,
  key wwmt1 as Wwmt1,
      bezek as Bezek
}
where
  spras = $session.system_language
