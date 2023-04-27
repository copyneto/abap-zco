*&---------------------------------------------------------------------*
*& Include zcoc_pr_mr22_fb50top
*&---------------------------------------------------------------------*

TABLES: j_1bnfdoc, marv.

CLASS lcx_exception DEFINITION
  INHERITING FROM cx_static_check
  FINAL.

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF gc_unauthorized,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_unauthorized .

    CONSTANTS:
      BEGIN OF gc_no_data_found,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_no_data_found .

    CONSTANTS:
      BEGIN OF gc_nf_blocked,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_nf_blocked .

    METHODS constructor
      IMPORTING
        iv_textid   LIKE if_t100_message=>t100key OPTIONAL
        io_previous TYPE REF TO cx_root OPTIONAL
        iv_msgv1    TYPE msgv1 OPTIONAL
        iv_msgv2    TYPE msgv2 OPTIONAL
        iv_msgv3    TYPE msgv3 OPTIONAL
        iv_msgv4    TYPE msgv4 OPTIONAL.

    DATA gv_msgv1   TYPE msgv1 READ-ONLY.
    DATA gv_msgv2   TYPE msgv2 READ-ONLY.
    DATA gv_msgv3   TYPE msgv3 READ-ONLY.
    DATA gv_msgv4   TYPE msgv4 READ-ONLY.

    METHODS get_bapi_return
      RETURNING
        VALUE(rt_return) TYPE bapiret2_t.

ENDCLASS.

CLASS lcl_main DEFINITION.

  PUBLIC SECTION.

    TYPES: ty_r_companycode TYPE RANGE OF zi_co_pr_mr22_fb50-CompanyCode,
           ty_r_periodmonth TYPE RANGE OF zi_co_pr_mr22_fb50-PeriodMonth,
           ty_r_periodyear  TYPE RANGE OF zi_co_pr_mr22_fb50-PeriodYear,
           ty_r_ivas        TYPE RANGE OF j_1bnflin-mwskz.

    CLASS-METHODS: instance RETURNING VALUE(ro_main) TYPE REF TO lcl_main RAISING lcx_exception.

    CLASS-METHODS: handle_error  IMPORTING iv_popup TYPE flag OPTIONAL
                                           io_cx    TYPE REF TO lcx_exception.

    METHODS: constructor IMPORTING iv_monitor     TYPE abap_bool                     "Identificação de a execução é processo do monitor
                                   iv_actvt       TYPE char2                         "Atividade 01 Reprocessar, 02 Estornar
                                   iv_nf          TYPE zi_co_pr_mr22_fb50-NFDocument "Nota Fiscal
                                   ir_companycode TYPE ty_r_companycode              "Empresas
                                   ir_periodmonth TYPE ty_r_periodmonth              "Mês
                                   ir_periodyear  TYPE ty_r_periodyear.              "Ano


    METHODS: start RAISING lcx_exception.

  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_status,
                 in_process         TYPE char2 VALUE '01',
                 error_to_process   TYPE char2 VALUE '02',
                 error_to_reverse   TYPE char2 VALUE '07',
                 success_to_process TYPE char2 VALUE '05',
                 success_to_reverse TYPE char2 VALUE '06',
               END OF gc_status,

               BEGIN OF gc_actvt,
                 process TYPE char2 VALUE '01', "Processamento/Reprocessamento
                 reverse TYPE char2 VALUE '02', "Estorno
               END OF gc_actvt.

    TYPES: BEGIN OF ty_s_nfs,
             NFDocument         TYPE zi_co_pr_mr22_fb50-NFDocument,
             NFItem             TYPE zi_co_pr_mr22_fb50-NFItem,
             NFTaxGrp           TYPE zi_co_pr_mr22_fb50-NFTaxGrp,
             NFTaxTyp           TYPE zi_co_pr_mr22_fb50-NFTaxTyp,
             TaxValue           TYPE zi_co_pr_mr22_fb50-TaxValue,
             CompanyCode        TYPE zi_co_pr_mr22_fb50-CompanyCode,
             ReleaseDate        TYPE zi_co_pr_mr22_fb50-ReleaseDate,
             PartnerID          TYPE zi_co_pr_mr22_fb50-PartnerID,
             NFENumber          TYPE zi_co_pr_mr22_fb50-NFENumber,
             Currency           TYPE zi_co_pr_mr22_fb50-Currency,
             Direction          TYPE zi_co_pr_mr22_fb50-Direction,
             Canceled           TYPE zi_co_pr_mr22_fb50-Canceled,
             Center             TYPE zi_co_pr_mr22_fb50-Center,
             Material           TYPE zi_co_pr_mr22_fb50-Material,
             Quantity           TYPE zi_co_pr_mr22_fb50-Quantity,
             ValuationType      TYPE zi_co_pr_mr22_fb50-ValuationType,
             EvaluationArea     TYPE zi_co_pr_mr22_fb50-EvaluationArea,
             ReferenceKey       TYPE zi_co_pr_mr22_fb50-ReferenceKey,
             TaxCode            TYPE zi_co_pr_mr22_fb50-TaxCode,
             PurchaseOrder      TYPE zi_co_pr_mr22_fb50-PurchaseOrder,
             PurchaseOrderItem  TYPE zi_co_pr_mr22_fb50-PurchaseOrderItem,
             IsAffiliated       TYPE zi_co_pr_mr22_fb50-IsAffiliated,
             ReferenceKeyDoc    TYPE zi_co_pr_mr22_fb50-ReferenceKeyDoc,
             ExecMr22           TYPE zi_co_pr_mr22_fb50-ExecMr22,
             Sign               TYPE zi_co_pr_mr22_fb50-Sign,
             ExecFb50           TYPE zi_co_pr_mr22_fb50-ExecFb50,
             DebitAccount       TYPE zi_co_pr_mr22_fb50-DebitAccount,
             CreditAccount      TYPE zi_co_pr_mr22_fb50-CreditAccount,
             TypeDoc            TYPE zi_co_pr_mr22_fb50-TypeDoc,
             Status             TYPE zi_co_pr_mr22_fb50-Status,
             AccountingDocument TYPE zi_co_pr_mr22_fb50-AccountingDocument,
             AccountingYear     TYPE zi_co_pr_mr22_fb50-AccountingYear,
             MrDocument         TYPE zi_co_pr_mr22_fb50-MrDocument,
             MrYear             TYPE zi_co_pr_mr22_fb50-MrYear,
             ReversalDocument   TYPE zi_co_pr_mr22_fb50-ReversalDocument,
             ReversalYear       TYPE zi_co_pr_mr22_fb50-ReversalYear,
             MrRevDocument      TYPE zi_co_pr_mr22_fb50-MrRevDocument,
             MrRevYear          TYPE zi_co_pr_mr22_fb50-MrRevYear,
             LastUserChange     TYPE zi_co_pr_mr22_fb50-LastUserChange,
             LastDateChange     TYPE zi_co_pr_mr22_fb50-LastDateChange,
             LastTimeChange     TYPE zi_co_pr_mr22_fb50-LastTimeChange,
             MessageTextInfor   TYPE zi_co_pr_mr22_fb50-MessageTextInfor,
             TransferCenter     TYPE zi_co_pr_mr22_fb50-TransferCenter,
           END OF ty_s_nfs,

           ty_t_nfs  TYPE TABLE OF ty_s_nfs WITH DEFAULT KEY,
           ty_t_ncab TYPE TABLE OF ztco_notas_cab WITH DEFAULT KEY,
           ty_t_nitm TYPE TABLE OF ztco_notas_itm WITH DEFAULT KEY.

    "----Tabelas
    DATA: gt_nfs  TYPE REF TO ty_t_nfs,
          gt_ncab TYPE REF TO ty_t_ncab,
          gt_nitm TYPE REF TO ty_t_nitm.

    "----Rangers
    DATA: gr_companycode  TYPE ty_r_companycode.
    DATA: gr_month        TYPE ty_r_periodmonth.
    DATA: gr_year         TYPE ty_r_periodyear.

    "----Variáveis
    DATA: gv_monitor TYPE abap_bool,
          gv_actvt   TYPE char2,
          gv_nf      TYPE zi_co_pr_mr22_fb50-NFDocument.

    METHODS: enqueue_nf   RAISING lcx_exception.
    METHODS: dequeue_nf   RAISING lcx_exception.
    METHODS: select_data  RAISING lcx_exception.
    METHODS: save_data    RAISING lcx_exception.
    METHODS: process_data RAISING lcx_exception.

    METHODS: change_data      IMPORTING io_nf    TYPE REF TO ty_s_nfs
                                        iv_error TYPE abap_bool OPTIONAL
                              RAISING   lcx_exception.

    METHODS: convert_currency IMPORTING is_currency        TYPE cki_ml_cty
                                        iv_taxvalue        TYPE j_1btaxval
                              RETURNING VALUE(rv_taxvalue) TYPE j_1btaxval
                              RAISING   lcx_exception.

    METHODS: execute_mr22 CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.
    METHODS: execute_fb50 CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.
    METHODS: reverse_mr22 CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.
    METHODS: reverse_fb50 CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.

    METHODS: execute_mr22_affiliated CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.
    METHODS: reverse_mr22_affiliated CHANGING co_nf TYPE REF TO ty_s_nfs RAISING lcx_exception.
    METHODS: get_ranges_ivas EXPORTING
                               er_entrada       TYPE ty_r_ivas
                               er_transferencia TYPE ty_r_ivas.

ENDCLASS.
