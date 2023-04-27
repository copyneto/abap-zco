class ZCLCO_ESTRAT_CUSTOS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_GET_DEFCCS .

  types:
  BEGIN OF ty_split,
    partner TYPE bu_partner,
    bukrs TYPE bukrs,
    werks TYPE werks_d,
  END OF ty_split .
protected section.
private section.

  class-methods CALC1
    importing
      !IS_CKMLPRKEPH type CKMLPRKEPH
      !IV_LOSGR type CK_LOSGR
      !IV_MENGE type MENGE_D
      !IV_NEGATIVE type CHAR1
    changing
      !CS_KEPH type CKMLKEPH .
  class-methods CALC2
    importing
      !IS_CKMLPRKEPH type CKMLPRKEPH
      !IV_LOSGR type CK_LOSGR
      !IV_MENGE type MENGE_D
      !IV_KWERT type VFPRC_ELEMENT_VALUE
      !IV_VALUE type ACBTR
      !IV_TOTAL type MLCCS_D_KSTEL
      !IV_NEGATIVE type CHAR1
    changing
      !CS_KEPH type CKMLKEPH .
  class-methods CALC3
    importing
      !IS_CKMLPRKEPH type CKMLPRKEPH
      !IV_LOSGR type CK_LOSGR
      !IV_MENGE type MENGE_D
      !IV_KWERT type VFPRC_ELEMENT_VALUE
      !IV_VALUE type ACBTR
      !IV_TOTAL type MLCCS_D_KSTEL
      !IV_CONVER type KURSK
      !IV_NEGATIVE type CHAR1
    changing
      !CS_KEPH type CKMLKEPH .
  class-methods CALC4
    importing
      !IS_CKMLPRKEPH type CKMLPRKEPH
      !IV_LOSGR type CK_LOSGR
      !IV_MENGE type MENGE_D
      !IV_VALUE type ACBTR
      !IV_TOTAL type MLCCS_D_KSTEL
      !IV_NEGATIVE type CHAR1
    changing
      !CS_KEPH type CKMLKEPH .
  class-methods CALC_TOT
    importing
      !IS_CKMLPRKEPH type CKMLPRKEPH
      !IV_LOSGR type CK_LOSGR
      !IV_MENGE type MENGE_D
      !IV_NEGATIVE type CHAR1
    returning
      value(RV_TOTAL) type MLCCS_D_KSTEL .
ENDCLASS.



CLASS ZCLCO_ESTRAT_CUSTOS IMPLEMENTATION.


  METHOD if_ex_get_defccs~badi_activity.

    INCLUDE zcoi_BADI_ACTIVITY IF FOUND.

  ENDMETHOD.


  method IF_EX_GET_DEFCCS~GET_DEFCCS.
    INCLUDE zcoi_estrat_custos IF FOUND.
    INCLUDE zcoi_estrat_custos_mm_tm IF FOUND.
    INCLUDE zcoi_estrat_custos_re IF FOUND.
  endmethod.


  method IF_EX_GET_DEFCCS~MOD_ACTIVITY_CCS.


  endmethod.


  method IF_EX_GET_DEFCCS~MOD_CCS.


  endmethod.


  method IF_EX_GET_DEFCCS~MOD_HRKFT_KSTAR.


  endmethod.


  method IF_EX_GET_DEFCCS~MOD_REVAL_CCS.


  endmethod.


  METHOD calc1.

    IF iv_negative EQ 'X'.
      cs_keph-kst001 = - ( ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge ).
      cs_keph-kst002 = - ( ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge ).
      cs_keph-kst003 = - ( ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge ).
      cs_keph-kst004 = - ( ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge ).
      cs_keph-kst005 = - ( ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge ).
      cs_keph-kst006 = - ( ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge ).
      cs_keph-kst007 = - ( ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge ).
      cs_keph-kst008 = - ( ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge ).
      cs_keph-kst009 = - ( ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge ).
      cs_keph-kst010 = - ( ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge ).
      cs_keph-kst011 = - ( ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge ).
      cs_keph-kst012 = - ( ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge ).
      cs_keph-kst013 = - ( ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge ).
      cs_keph-kst014 = - ( ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge ).
      cs_keph-kst015 = - ( ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge ).
      cs_keph-kst016 = - ( ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge ).
      cs_keph-kst017 = - ( ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge ).
      cs_keph-kst018 = - ( ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge ).
      cs_keph-kst019 = - ( ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge ).
      cs_keph-kst020 = - ( ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge ).
      cs_keph-kst021 = - ( ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge ).
      cs_keph-kst022 = - ( ( is_ckmlprkeph-kst022 / iv_losgr ) * iv_menge ).
      cs_keph-kst025 = - ( ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge ).
      cs_keph-kst026 = - ( ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge ).
      cs_keph-kst027 = - ( ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge ).
      cs_keph-kst028 = - ( ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge ).
      cs_keph-kst029 = - ( ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge ).
      cs_keph-kst030 = - ( ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge ).
      cs_keph-kst031 = - ( ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge ).
      cs_keph-kst032 = - ( ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge ).
      cs_keph-kst033 = - ( ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge ).
      cs_keph-kst034 = - ( ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge ).
      cs_keph-kst035 = - ( ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge ).
      cs_keph-kst036 = - ( ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge ).
      cs_keph-kst037 = - ( ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge ).
      cs_keph-kst038 = - ( ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge ).
      cs_keph-kst039 = - ( ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge ).
      cs_keph-kst040 = - ( ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge ).
      cs_keph-kst041 = - ( ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge ).
      cs_keph-kst042 = - ( ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge ).
      cs_keph-kst043 = - ( ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge ).
      cs_keph-kst044 = - ( ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge ).
      cs_keph-kst045 = - ( ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge ).
      cs_keph-kst046 = - ( ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge ).
      cs_keph-kst047 = - ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ).
      cs_keph-kst048 = - ( ( is_ckmlprkeph-kst048 / iv_losgr ) * iv_menge ).
      cs_keph-kst049 = - ( ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge ).
      cs_keph-kst050 = - ( ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge ).
    ELSE.
      cs_keph-kst001 = ( ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge ).
      cs_keph-kst002 = ( ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge ).
      cs_keph-kst003 = ( ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge ).
      cs_keph-kst004 = ( ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge ).
      cs_keph-kst005 = ( ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge ).
      cs_keph-kst006 = ( ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge ).
      cs_keph-kst007 = ( ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge ).
      cs_keph-kst008 = ( ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge ).
      cs_keph-kst009 = ( ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge ).
      cs_keph-kst010 = ( ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge ).
      cs_keph-kst011 = ( ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge ).
      cs_keph-kst012 = ( ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge ).
      cs_keph-kst013 = ( ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge ).
      cs_keph-kst014 = ( ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge ).
      cs_keph-kst015 = ( ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge ).
      cs_keph-kst016 = ( ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge ).
      cs_keph-kst017 = ( ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge ).
      cs_keph-kst018 = ( ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge ).
      cs_keph-kst019 = ( ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge ).
      cs_keph-kst020 = ( ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge ).
      cs_keph-kst021 = ( ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge ).
      cs_keph-kst022 = ( ( is_ckmlprkeph-kst022 / iv_losgr ) * iv_menge ).
      cs_keph-kst025 = ( ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge ).
      cs_keph-kst026 = ( ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge ).
      cs_keph-kst027 = ( ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge ).
      cs_keph-kst028 = ( ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge ).
      cs_keph-kst029 = ( ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge ).
      cs_keph-kst030 = ( ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge ).
      cs_keph-kst031 = ( ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge ).
      cs_keph-kst032 = ( ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge ).
      cs_keph-kst033 = ( ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge ).
      cs_keph-kst034 = ( ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge ).
      cs_keph-kst035 = ( ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge ).
      cs_keph-kst036 = ( ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge ).
      cs_keph-kst037 = ( ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge ).
      cs_keph-kst038 = ( ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge ).
      cs_keph-kst039 = ( ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge ).
      cs_keph-kst040 = ( ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge ).
      cs_keph-kst041 = ( ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge ).
      cs_keph-kst042 = ( ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge ).
      cs_keph-kst043 = ( ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge ).
      cs_keph-kst044 = ( ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge ).
      cs_keph-kst045 = ( ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge ).
      cs_keph-kst046 = ( ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge ).
      cs_keph-kst047 = ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ).
      cs_keph-kst048 = ( ( is_ckmlprkeph-kst048 / iv_losgr ) * iv_menge ).
      cs_keph-kst049 = ( ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge ).
      cs_keph-kst050 = ( ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge ).
    ENDIF.



  ENDMETHOD.


  METHOD calc2.

    IF iv_negative EQ 'X'.
      cs_keph-kst001 = - ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = - ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = - ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = - ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = - ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = - ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = - ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = - ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = - ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = - ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = - ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = - ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = - ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = - ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = - ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = - ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = - ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = - ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = - ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = - ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
*      cs_keph-kst021 = - ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge.
*      cs_keph-kst022 = - ( is_ckmlprkeph-kst022 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = - ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = - ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = - ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = - ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = - ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = - ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge.
      cs_keph-kst027 = 0.
      cs_keph-kst028 = 0.
      cs_keph-kst029 = - ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = - ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = - ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = - ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = - ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = - ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = - ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = - ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = - ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = - ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = - ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = - ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = - ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge  - iv_kwert .
      cs_keph-kst042 = - ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = - ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = - ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = - ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = - ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = - ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - ( iv_total - iv_kwert ) ).
      cs_keph-kst048 = - ( is_ckmlprkeph-kst048 / iv_losgr ).
      cs_keph-kst049 = - ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = - ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ELSE.
      cs_keph-kst001 = ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
*      cs_keph-kst021 = ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge.
*      cs_keph-kst022 = ( is_ckmlprkeph-kst022 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge.
      cs_keph-kst027 =  0.
      cs_keph-kst028 =  0.
      cs_keph-kst029 = ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge + iv_kwert.
      cs_keph-kst042 = ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - iv_total - iv_kwert  ).
      cs_keph-kst048 = ( is_ckmlprkeph-kst048 / iv_losgr ).
      cs_keph-kst049 = ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ENDIF.
  ENDMETHOD.


  METHOD calc3.

    IF iv_negative EQ 'X'.
      cs_keph-kst001 = - ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = - ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = - ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = - ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = - ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = - ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = - ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = - ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = - ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = - ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = - ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = - ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = - ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = - ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = - ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = - ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = - ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = - ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = - ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = - ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = - ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = - ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = - ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = - ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = - ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = - ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge.
      cs_keph-kst027 = 0.
      cs_keph-kst028 = 0.
      cs_keph-kst029 = - ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = - ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = - ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = - ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = - ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = - ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = - ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = - ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = - ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = - ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = - ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = - ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = - ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge - ( iv_kwert * iv_conver ).
      cs_keph-kst042 = - ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = - ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = - ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = - ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = - ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = - ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - ( iv_total - ( iv_kwert * iv_conver ) ) ).
      cs_keph-kst048 = - ( is_ckmlprkeph-kst048 / iv_losgr ) * iv_menge.
      cs_keph-kst049 = - ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = - ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ELSE.
      cs_keph-kst001 = ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge..
      cs_keph-kst027 = 0.
      cs_keph-kst028 = 0.
      cs_keph-kst029 = ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge + ( iv_kwert * iv_conver ).
      cs_keph-kst042 = ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - iv_total - ( iv_kwert * iv_conver ) ).
      cs_keph-kst048 = ( is_ckmlprkeph-kst048 / iv_losgr ) * iv_menge.
      cs_keph-kst049 = ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ENDIF.


  ENDMETHOD.


  METHOD calc4.

    IF iv_negative EQ 'X'.
      cs_keph-kst001 = - ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = - ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = - ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = - ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = - ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = - ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = - ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = - ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = - ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = - ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = - ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = - ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = - ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = - ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = - ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = - ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = - ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = - ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = - ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = - ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = - ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = - ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = - ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = - ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = - ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = - ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge.
      cs_keph-kst027 = 0.
      cs_keph-kst028 = 0.
      cs_keph-kst029 = - ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = - ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = - ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = - ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = - ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = - ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = - ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = - ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = - ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = - ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = - ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = - ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = - ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge.
      cs_keph-kst042 = - ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = - ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = - ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = - ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = - ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = - ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - iv_total ).
      cs_keph-kst048 = - ( is_ckmlprkeph-kst048 / iv_losgr ).
      cs_keph-kst049 = - ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = - ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ELSE.
      cs_keph-kst001 = ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge.
      cs_keph-kst002 = ( is_ckmlprkeph-kst002 / iv_losgr ) * iv_menge.
      cs_keph-kst003 = ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge.
      cs_keph-kst004 = ( is_ckmlprkeph-kst004 / iv_losgr ) * iv_menge.
      cs_keph-kst005 = ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge.
      cs_keph-kst006 = ( is_ckmlprkeph-kst006 / iv_losgr ) * iv_menge.
      cs_keph-kst007 = ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge.
      cs_keph-kst008 = ( is_ckmlprkeph-kst008 / iv_losgr ) * iv_menge.
      cs_keph-kst009 = ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge.
      cs_keph-kst010 = ( is_ckmlprkeph-kst010 / iv_losgr ) * iv_menge.
      cs_keph-kst011 = ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge.
      cs_keph-kst012 = ( is_ckmlprkeph-kst012 / iv_losgr ) * iv_menge.
      cs_keph-kst013 = ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge.
      cs_keph-kst014 = ( is_ckmlprkeph-kst014 / iv_losgr ) * iv_menge.
      cs_keph-kst015 = ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge.
      cs_keph-kst016 = ( is_ckmlprkeph-kst016 / iv_losgr ) * iv_menge.
      cs_keph-kst017 = ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge.
      cs_keph-kst018 = ( is_ckmlprkeph-kst018 / iv_losgr ) * iv_menge.
      cs_keph-kst019 = ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge.
      cs_keph-kst020 = ( is_ckmlprkeph-kst020 / iv_losgr ) * iv_menge.
      cs_keph-kst021 = ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge.
      cs_keph-kst022 = ( is_ckmlprkeph-kst028 / iv_losgr ) * iv_menge.
      cs_keph-kst023 = ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge.
      cs_keph-kst024 = ( is_ckmlprkeph-kst024 / iv_losgr ) * iv_menge.
      cs_keph-kst025 = ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge.
      cs_keph-kst026 = ( is_ckmlprkeph-kst026 / iv_losgr ) * iv_menge.
      cs_keph-kst027 =  0.
      cs_keph-kst028 =  0.
      cs_keph-kst029 = ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge.
      cs_keph-kst030 = ( is_ckmlprkeph-kst030 / iv_losgr ) * iv_menge.
      cs_keph-kst031 = ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge.
      cs_keph-kst032 = ( is_ckmlprkeph-kst032 / iv_losgr ) * iv_menge.
      cs_keph-kst033 = ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge.
      cs_keph-kst034 = ( is_ckmlprkeph-kst034 / iv_losgr ) * iv_menge.
      cs_keph-kst035 = ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge.
      cs_keph-kst036 = ( is_ckmlprkeph-kst036 / iv_losgr ) * iv_menge.
      cs_keph-kst037 = ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge.
      cs_keph-kst038 = ( is_ckmlprkeph-kst038 / iv_losgr ) * iv_menge.
      cs_keph-kst039 = ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge.
      cs_keph-kst040 = ( is_ckmlprkeph-kst040 / iv_losgr ) * iv_menge.
      cs_keph-kst041 = ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge.
      cs_keph-kst042 = ( is_ckmlprkeph-kst042 / iv_losgr ) * iv_menge.
      cs_keph-kst043 = ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge.
      cs_keph-kst044 = ( is_ckmlprkeph-kst044 / iv_losgr ) * iv_menge.
      cs_keph-kst045 = ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge.
      cs_keph-kst046 = ( is_ckmlprkeph-kst046 / iv_losgr ) * iv_menge.
      cs_keph-kst047 = ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) + ( iv_value - iv_total ).
      cs_keph-kst048 = ( is_ckmlprkeph-kst048 / iv_losgr ).
      cs_keph-kst049 = ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge.
      cs_keph-kst050 = ( is_ckmlprkeph-kst050 / iv_losgr ) * iv_menge.
    ENDIF.



  ENDMETHOD.


  METHOD calc_tot.

    IF iv_negative = 'X'.
      rv_total = - ( ( ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge ) ).
    ELSE.
      rv_total = ( ( ( is_ckmlprkeph-kst001 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst003 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst005 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst007 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst009 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst011 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst013 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst015 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst017 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst019 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst021 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst023 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst025 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst027 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst029 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst031 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst033 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst035 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst037 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst039 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst041 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst043 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst045 / iv_losgr ) * iv_menge ) + ( ( is_ckmlprkeph-kst047 / iv_losgr ) * iv_menge ) +
              ( ( is_ckmlprkeph-kst049 / iv_losgr ) * iv_menge ) ).
    ENDIF.



  ENDMETHOD.
ENDCLASS.
