class ZCL_DYNAMIC_SELECT definition
  public
  final
  create private .

public section.

    "! <p class="shorttext synchronized" lang="en">Get instance</p>
    "!
    "! @parameter i_tabname | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter ro_instance | <p class="shorttext synchronized" lang="en"></p>
    "! used to get a instance of the class for table [tablename]
  class-methods GET_INSTANCE
    importing
      !I_TABNAME type TABNAME
    returning
      value(RO_INSTANCE) type ref to ZCL_DYNAMIC_SELECT .
  "! does not work with sel_option/range
  methods ADD_WHERE_COND
    importing
      !I_LOG_EXPRESSION type CHAR3 default 'AND'
      !I_SIGN type CHAR2 default IF_SLAD_SELECT_OPTIONS=>C_OPTIONS-EQ
      !IG_VALUE type ANY
      !I_KEY_TO_KEY_MAPPING type ABAP_BOOL default ABAP_FALSE
    raising
      CX_TAAN_FIELD_NOT_FOUND
      CX_MI_NO_VALUE_FOUND .
  "! <p class="shorttext synchronized" lang="en">Add a where cond to the select statement &#124; key 2 key mapping</p>
  methods ADD_WHERE_COND_KEY_TO_KEY
    importing
      !IG_KEY type ANY
    raising
      CX_TAAN_FIELD_NOT_FOUND
      CX_MI_NO_VALUE_FOUND .
*    METHODS add_where_cond_by_sel_opt
*      IMPORTING
*        log_expression TYPE char3 DEFAULT sql_log_expression-and
*        range_table TYPE STANDARD TABLE.
  methods CLEAR_WHERE_COND .
  methods IS_RANGE_TABLE
    importing
      !IT_RANGE_TABLE type STANDARD TABLE
    returning
      value(R_IS_RANGED_TABLE) type ABAP_BOOL .
  methods SELECT
    exporting
      !ET_SELECT_RESULT type ANY TABLE .
  methods SELECT_FOR_ALL_ENTIRES_KEYTAB
    importing
      !IT_TABLE type ANY TABLE
      !I_LOG_EXPRESSION type CHAR3 default 'AND'
      !I_SIGN type CHAR2 default IF_SLAD_SELECT_OPTIONS=>C_OPTIONS-EQ
    exporting
      !ET_SELECT_RESULT type ANY TABLE
    raising
      CX_TAAN_FIELD_NOT_FOUND .
  methods SELECT_SINGLE
    exporting
      !EG_SELECT_RESULT type ANY .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF gtys_instance_table,
             tabname  TYPE tabname,
             instance TYPE REF TO zcl_dynamic_select,
           END OF gtys_instance_table .
  types:
    BEGIN OF gtys_saved_ranges,
             range_name TYPE string,
             content    TYPE REF TO data,
           END OF gtys_saved_ranges .

  class-data:
    gtr_instance_table TYPE TABLE OF gtys_instance_table .
  data:
    t_table_fields TYPE TABLE OF dd03l .
  data:
    tr_c_like_types TYPE RANGE OF abap_typecategory .
  data TABNAME type TABNAME .
  data where_clause type string .

  methods CONSTRUCTOR
    importing
      !I_TABNAME type TABNAME
    raising
      CX_TAAN_TABLE_NOT_FOUND .
  methods MAP_FIELDS
    importing
      !IS_FIELD type DFIES
      !I_KEY_TO_KEY_MAPPING type ABAP_BOOL default ABAP_FALSE
    returning
      value(R_FIELDNAME) type DD03L-FIELDNAME
    raising
      CX_TAAN_FIELD_NOT_FOUND .
   methods build_where_cond
    IMPORTING
      i_log_operator TYPE char3
      i_operator TYPE char5
      i_field_name TYPE fieldname
      ig_value TYPE string.
      .
ENDCLASS.



CLASS ZCL_DYNAMIC_SELECT IMPLEMENTATION.


  METHOD add_where_cond.

    DATA: lt_field_list TYPE ddfields.

    DATA: lo_elem_descr  TYPE REF TO cl_abap_elemdescr,
          lo_struc_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS: <lg_value> TYPE any.


    TRY.
        lo_struc_descr ?= cl_abap_typedescr=>describe_by_data( ig_value ).
        lt_field_list = lo_struc_descr->get_ddic_field_list( ).
      CATCH cx_sy_move_cast_error.
        lo_elem_descr ?= cl_abap_typedescr=>describe_by_data( ig_value ).
        APPEND lo_elem_descr->get_ddic_field( ) TO lt_field_list.
    ENDTRY.

    "if value is a structure add structure field one by one
    "if value is a single field add it to where cond
    LOOP AT lt_field_list ASSIGNING FIELD-SYMBOL(<ls_field>).

      "mapping fields to table fields by "priority"
      IF <ls_field>-fieldname IS INITIAL.

        <ls_field>-fieldname = map_fields( is_field = <ls_field>
                                           i_key_to_key_mapping = i_key_to_key_mapping ).

      ENDIF.

      UNASSIGN <lg_value>.
      IF lines( lt_field_list ) EQ 1.
        ASSIGN ig_value TO <lg_value>.
      ELSE.
        ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE ig_value TO <lg_value>.
      ENDIF.

      IF <lg_value> IS NOT ASSIGNED.
        RAISE EXCEPTION TYPE cx_mi_no_value_found.
      ENDIF.

      where_clause = zcl_where_clause=>create_as_eq( i_fieldname = <ls_field>-fieldname
                                                            i_value = conv string( <lg_value> ) )->get( ).


    ENDLOOP.

  ENDMETHOD.


  METHOD add_where_cond_key_to_key.

    add_where_cond( ig_value = ig_key
                    i_key_to_key_mapping = abap_true ).

  ENDMETHOD.


  METHOD clear_where_cond.

    CLEAR where_clause.

  ENDMETHOD.


  METHOD constructor.

    me->tabname = i_tabname.

    SELECT *
    FROM dd03l
    INTO TABLE t_table_fields
    WHERE tabname = i_tabname
    ORDER BY position ASCENDING.

    IF sy-subrc NE 0
    OR lines( t_table_fields ) LE 0.
      RAISE EXCEPTION TYPE cx_taan_table_not_found.
    ENDIF.

    tr_c_like_types = VALUE #( sign = if_slad_select_options=>c_signs-including
                               option = if_slad_select_options=>c_options-eq
                             ( low = cl_abap_typedescr=>typekind_char )
                             ( low = cl_abap_typedescr=>typekind_clike )
                             ( low = cl_abap_typedescr=>typekind_csequence )
                             ( low = cl_abap_typedescr=>typekind_string )
                             ( low = cl_abap_typedescr=>typekind_num )
                             ( low = cl_abap_typedescr=>typekind_xstring ) ).

  ENDMETHOD.


  METHOD get_instance.

    TRY.

        ro_instance = gtr_instance_table[ tabname = i_tabname ]-instance.
        ro_instance->clear_where_cond( ).

      CATCH cx_sy_itab_line_not_found.

        ro_instance = NEW zcl_dynamic_select( i_tabname ).
        APPEND VALUE #( tabname = i_tabname
                        instance = ro_instance ) TO gtr_instance_table.

    ENDTRY.

  ENDMETHOD.


  METHOD is_range_table.

    FIELD-SYMBOLS: <lg_tabline> TYPE any.

    ASSIGN COMPONENT 'SIGN' OF STRUCTURE it_range_table TO <lg_tabline>.
    CHECK <lg_tabline> IS ASSIGNED.
    UNASSIGN <lg_tabline>.

    ASSIGN COMPONENT 'OPTION' OF STRUCTURE it_range_table TO <lg_tabline>.
    CHECK <lg_tabline> IS ASSIGNED.
    UNASSIGN <lg_tabline>.

    ASSIGN COMPONENT 'LOW' OF STRUCTURE it_range_table TO <lg_tabline>.
    CHECK <lg_tabline> IS ASSIGNED.
    UNASSIGN <lg_tabline>.

    ASSIGN COMPONENT 'HIGH' OF STRUCTURE it_range_table TO <lg_tabline>.
    CHECK <lg_tabline> IS ASSIGNED.
    UNASSIGN <lg_tabline>.

    r_is_ranged_table = abap_true.

  ENDMETHOD.


  METHOD map_fields.

    "tab-fieldname = field-datatype name
    r_fieldname = VALUE #( t_table_fields[ fieldname = is_field-rollname ]-fieldname OPTIONAL ).
    IF r_fieldname IS NOT INITIAL.
      RETURN.
    ENDIF.

    "tab-fieldname = field-domain name
    r_fieldname = VALUE #( t_table_fields[ fieldname = is_field-domname ]-fieldname OPTIONAL ).
    IF r_fieldname IS NOT INITIAL.
      RETURN.
    ENDIF.

    "tab has element with same datatype name as field
    r_fieldname = VALUE #( t_table_fields[ rollname = is_field-rollname ]-fieldname OPTIONAL ).
    IF r_fieldname IS NOT INITIAL.
      RETURN.
    ENDIF.

    "tab has element with same datatype name as field-domainname
    r_fieldname = VALUE #( t_table_fields[ rollname = is_field-domname ]-fieldname OPTIONAL ).
    IF r_fieldname IS NOT INITIAL.
      RETURN.
    ENDIF.

    "-------------------------------------
    " From here on out it can happen more often that the wrong fields are matched
    "-------------------------------------

    IF i_key_to_key_mapping EQ abap_true.

        "look for a key field same field type but GE field length
        LOOP AT t_table_fields REFERENCE INTO DATA(lr_field) WHERE leng GE is_field-leng
                                                               AND datatype EQ is_field-datatype
                                                               AND keyflag EQ abap_true.
            r_fieldname = lr_field->fieldname.
            EXIT.
        ENDLOOP.
        IF r_fieldname IS NOT INITIAL.
          RETURN.
        ENDIF.

    ENDIF.

    "if no fitting field is found
    RAISE EXCEPTION TYPE cx_taan_field_not_found.

  ENDMETHOD.


  METHOD select.

    SELECT *
    FROM (tabname)
    INTO TABLE et_select_result
    WHERE (where_clause).

  ENDMETHOD.


  METHOD select_for_all_entires_keytab.

    DATA: lo_table_descr TYPE REF TO cl_abap_tabledescr,
          lo_elem_descr  TYPE REF TO cl_abap_elemdescr,
          lo_struc_descr TYPE REF TO cl_abap_structdescr.

    DATA: lt_field_types TYPE ddfields.

    DATA: l_table_field TYPE fieldname.

    lo_table_descr ?= cl_abap_typedescr=>describe_by_data( it_table ).
    TRY.
        lo_struc_descr ?= lo_table_descr->get_table_line_type( ).
        lt_field_types = lo_struc_descr->get_ddic_field_list( ).
      CATCH cx_sy_move_cast_error.
        lo_elem_descr ?= lo_table_descr->get_table_line_type( ).
        APPEND lo_elem_descr->get_ddic_field( ) TO lt_field_types.
    ENDTRY.

    CLEAR where_clause.
    LOOP AT lt_field_types ASSIGNING FIELD-SYMBOL(<ls_field>).

      TRY.
          IF line_exists( t_table_fields[ fieldname = <ls_field>-fieldname
                                        keyflag = abap_true ] ).
            l_table_field = <ls_field>-fieldname.
          ELSE.
            l_table_field = t_table_fields[ keyflag = abap_true
                                          domname = <ls_field>-domname ]-fieldname.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
          RAISE EXCEPTION TYPE cx_taan_field_not_found.
      ENDTRY.

      IF where_clause IS INITIAL.
        "add '' if value contains characters { table_field } { sign } { value }/'{ value }'
        where_clause = |{ l_table_field } { i_sign } it_table-{ COND #( WHEN lo_elem_descr IS BOUND
                                                             THEN 'table_line'
                                                             ELSE <ls_field>-fieldname ) }|.
      ELSE.
        where_clause = |{ where_clause } { i_log_expression } { l_table_field } { i_sign } it_table-{ COND #( WHEN lo_elem_descr IS BOUND
                                                                                                  THEN 'table_line'
                                                                                                  ELSE <ls_field>-fieldname ) }|.
      ENDIF.

    ENDLOOP.

    SELECT *
    FROM (tabname)
    INTO TABLE et_select_result
    FOR ALL ENTRIES IN it_table
    WHERE (where_clause).

  ENDMETHOD.


  METHOD select_single.

    SELECT SINGLE *
    FROM (tabname)
    INTO eg_select_result
    WHERE (where_clause).

  ENDMETHOD.

  METHOD BUILD_WHERE_COND.

    "not implemtet yet

  ENDMETHOD.

ENDCLASS.
