CLASS zcl_client010 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: default_response
* Description: default_response
* Version: 1.0.11
  PUBLIC SECTION.
    INTERFACES zif_interface010.
    "! Supply http client and possibily extra http headers to instantiate the openAPI client
    "! Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    "! the caller must close() the client
    METHODS constructor
      IMPORTING
        ii_client        TYPE REF TO if_http_client
        iv_uri_prefix    TYPE string OPTIONAL
        it_extra_headers TYPE tihttpnvp OPTIONAL
        iv_logon_popup   TYPE i DEFAULT if_http_client=>co_disabled
        iv_timeout       TYPE i DEFAULT if_http_client=>co_timeout_default.
  PROTECTED SECTION.
    DATA mi_client        TYPE REF TO if_http_client.
    DATA mv_timeout       TYPE i.
    DATA mv_logon_popup   TYPE i.
    DATA mv_uri_prefix    TYPE string.
    DATA mt_extra_headers TYPE tihttpnvp.
ENDCLASS.

CLASS zcl_client010 IMPLEMENTATION.
  METHOD constructor.
    mi_client = ii_client.
    mv_timeout = iv_timeout.
    mv_logon_popup = iv_logon_popup.
    mv_uri_prefix = iv_uri_prefix.
    mt_extra_headers = it_extra_headers.
  ENDMETHOD.

  METHOD zif_interface010~create_user.
    DATA lv_uri          TYPE string.
    DATA ls_header       LIKE LINE OF mt_extra_headers.
    DATA lv_dummy        TYPE string.
    DATA lv_content_type TYPE string.

    mi_client->propertytype_logon_popup = mv_logon_popup.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_version( if_http_request=>co_protocol_version_1_1 ).
    mi_client->request->set_compression( ).
    lv_uri = mv_uri_prefix && '/user'.
    cl_http_utility=>set_request_uri(
      request = mi_client->request
      uri     = lv_uri ).
    LOOP AT mt_extra_headers INTO ls_header.
      mi_client->request->set_header_field(
        name  = ls_header-name
        value = ls_header-value ).
    ENDLOOP.
    mi_client->request->set_content_type( 'application/json' ).
    mi_client->request->set_cdata( body ).
    mi_client->send( mv_timeout ).
    mi_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      mi_client->get_last_error(
        IMPORTING
          code    = return-code
          message = return-reason ).
      ASSERT 1 = 2.
    ENDIF.

    lv_content_type = mi_client->response->get_content_type( ).
    mi_client->response->get_status(
      IMPORTING
        code   = return-code
        reason = return-reason ).
    CASE return-code.
      WHEN OTHERS.
        SPLIT lv_content_type AT ';' INTO lv_content_type lv_dummy.
        CASE lv_content_type.
          WHEN 'application/json'.
            /ui2/cl_json=>deserialize(
              EXPORTING
                json        = mi_client->response->get_cdata( )
                pretty_name = /ui2/cl_json=>pretty_mode-camel_case
              CHANGING
                data        = return-_default_app_json ).
          WHEN OTHERS.
* unexpected content type
        ENDCASE.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
