define abstract entity ZI_CO_TYPE_TOPROCESS
{
  FileDirectory : abap.string(256);
  CodigoCenario : abap.char(50);
  Data          : abap.dats;
  Material      : matnr;
  TipoAvaliacao : bwtar_d;
  NotaFiscal    : docnum;
  Empresa       : bukrs;
  Centro        : werks_d;
  Divisao       : gsber;
  @Semantics.amount.currencyCode : 'Moeda'
  ValorICMS     : netpr;
  @Semantics.amount.currencyCode : 'Moeda'
  ValorICMSST   : netpr;
  @Semantics.amount.currencyCode : 'Moeda'
  ValorIPI      : netpr;
  Moeda         : waerk;
}
