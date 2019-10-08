CLASS zcl_where_clause DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS gc_and TYPE char3 VALUE 'AND' ##NO_TEXT.
    CONSTANTS gc_or TYPE char3 VALUE 'OR' ##NO_TEXT.
    CONSTANTS gc_not TYPE char3 VALUE 'NOT' ##NO_TEXT.
    CONSTANTS gc_eq TYPE char4 VALUE 'EQ' ##NO_TEXT.
    CONSTANTS gc_ne TYPE char4 VALUE 'NE' ##NO_TEXT.
    CONSTANTS gc_bt TYPE char7 VALUE 'BETWEEN' ##NO_TEXT.
    CONSTANTS gc_like TYPE char4 VALUE 'LIKE' ##NO_TEXT.


    METHODS add_and_eq
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS add_and_ne
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS add_and_like
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS add_or_eq
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS add_or_ne
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS add_or_like
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string.
    METHODS get
      RETURNING
        VALUE(r_where_clause) TYPE string .
    CLASS-METHODS create_as_eq
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string
      RETURNING VALUE(ro_where_clause) TYPE REF TO zcl_where_clause.
    CLASS-METHODS create_as_ne
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string
      RETURNING VALUE(ro_where_clause) TYPE REF TO zcl_where_clause.
    CLASS-METHODS create_as_like
      IMPORTING
                !i_fieldname           TYPE fieldname
                !i_value               TYPE string
      RETURNING VALUE(ro_where_clause) TYPE REF TO zcl_where_clause.
    METHODS clear .

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA where_clause TYPE string .
    DATA:
      tr_c_like_types TYPE RANGE OF abap_typecategory .
    METHODS add
      IMPORTING
        !i_sql_chain_operator TYPE char3
        !i_fieldname          TYPE fieldname
        !i_expr_operator      TYPE char4
        !i_value              TYPE string.
    METHODS prepare_value
      IMPORTING
        i_expr_operator TYPE char4
        i_value         TYPE string
      RETURNING
        value(r_string) TYPE string.
    METHODS constructor
      IMPORTING
         i_fieldname          TYPE fieldname
         i_expr_operator      TYPE char4
         i_value              TYPE string.
ENDCLASS.



CLASS zcl_where_clause IMPLEMENTATION.


  METHOD constructor.

    where_clause = |{ i_fieldname } { i_expr_operator } { prepare_value( i_expr_operator = i_expr_operator
                                                                         i_value = i_value  ) }|.

  ENDMETHOD.


  METHOD clear.

    CLEAR where_clause.

  ENDMETHOD.

  METHOD create_as_eq.

    ro_where_clause = NEW zcl_where_clause( i_fieldname = i_fieldname
                                                   i_expr_operator = gc_eq
                                                   i_value = i_value ).

  ENDMETHOD.


  METHOD create_as_like.

    ro_where_clause = NEW zcl_where_clause( i_fieldname = i_fieldname
                                                   i_expr_operator = gc_like
                                                   i_value = i_value ).

  ENDMETHOD.


  METHOD create_as_ne.

    ro_where_clause = NEW zcl_where_clause( i_fieldname = i_fieldname
                                                   i_expr_operator = gc_ne
                                                   i_value = i_value ).

  ENDMETHOD.

  METHOD get.

    r_where_clause = where_clause.

  ENDMETHOD.
  METHOD add.

        where_clause = |{ where_clause } { i_sql_chain_operator } { i_fieldname } { i_expr_operator } { prepare_value( i_expr_operator = i_expr_operator
                                                                                                                       i_value = i_value ) }|.

  ENDMETHOD.

  METHOD add_and_eq.

    add( i_sql_chain_operator = gc_and
         i_fieldname = i_fieldname
         i_expr_operator = gc_eq
         i_value = i_value ).

  ENDMETHOD.

  METHOD add_and_like.

    add( i_sql_chain_operator = gc_and
         i_fieldname = i_fieldname
         i_expr_operator = gc_like
         i_value = i_value ).


  ENDMETHOD.

  METHOD add_and_ne.

    add( i_sql_chain_operator = gc_and
         i_fieldname = i_fieldname
         i_expr_operator = gc_ne
         i_value = i_value ).


  ENDMETHOD.

  METHOD add_or_eq.

    add( i_sql_chain_operator = gc_or
         i_fieldname = i_fieldname
         i_expr_operator = gc_eq
         i_value = i_value ).

  ENDMETHOD.

  METHOD add_or_like.

    add( i_sql_chain_operator = gc_or
         i_fieldname = i_fieldname
         i_expr_operator = gc_like
         i_value = i_value ).


  ENDMETHOD.

  METHOD add_or_ne.

    add( i_sql_chain_operator = gc_or
         i_fieldname = i_fieldname
         i_expr_operator = gc_ne
         i_value = i_value ).


  ENDMETHOD.


  METHOD prepare_value.

    DATA: lo_string TYPE REF TO zcl_string.

    tr_c_like_types = VALUE #( sign = if_slad_select_options=>c_signs-including
                               option = if_slad_select_options=>c_options-eq
                             ( low = cl_abap_typedescr=>typekind_char )
                             ( low = cl_abap_typedescr=>typekind_clike )
                             ( low = cl_abap_typedescr=>typekind_csequence )
                             ( low = cl_abap_typedescr=>typekind_string )
                             ( low = cl_abap_typedescr=>typekind_num )
                             ( low = cl_abap_typedescr=>typekind_xstring ) ).

    lo_string = new zcl_string( i_value ).


    IF i_expr_operator = gc_like
    AND NOT lo_string->ends_with( '%' ).
        lo_string->append( '%' ).
    ENDIF.

    "add single quotes to value
    DESCRIBE FIELD i_value TYPE DATA(l_value_type).

    IF l_value_type in tr_c_like_types.
        lo_string->add_single_quotes( ).
    ENDIF.

    r_string = lo_string->get_value( ).

  ENDMETHOD.

ENDCLASS.
