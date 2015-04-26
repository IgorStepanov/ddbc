/**
 * DDBC - D DataBase Connector - abstraction layer for RDBMS access, with interface similar to JDBC.
 *
 * Source file ddbc/drivers/oracle.d.
 *
 * DDBC library attempts to provide implementation independent interface to different databases.
 *
 * Set of supported RDBMSs can be extended by writing Drivers for particular DBs.
 * Currently it only includes MySQL driver.
 *
 * JDBC documentation can be found here:
 * $(LINK http://docs.oracle.com/javase/1.5.0/docs/api/java/sql/package-summary.html)$(BR)
 *
 * This module contains liboci interface
 *
 *
 * You can find usage examples in unittest{} sections.
 *
 * Copyright: Copyright 2015
 * License:   $(LINK www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Author:   Igor Stepanov
 */
module ddbc.drivers.oracle;
version(USE_ORACLE)
{
    version (Windows)
    {
        pragma (lib, "oci");
    }
    else
    {
        pragma (lib, "clntsh");
    }


    import core.vararg : va_list;

    enum uint OCI_HTYPE_FIRST        = 1;        /// Start value of handle type.
    enum uint OCI_HTYPE_ENV        = 1;        /// Environment handle.
    enum uint OCI_HTYPE_ERROR        = 2;        /// Error handle.
    enum uint OCI_HTYPE_SVCCTX        = 3;        /// Service handle.
    enum uint OCI_HTYPE_STMT        = 4;        /// Statement handle.
    enum uint OCI_HTYPE_BIND        = 5;        /// Bind handle.
    enum uint OCI_HTYPE_DEFINE        = 6;        /// Define handle.
    enum uint OCI_HTYPE_DESCRIBE        = 7;        /// Describe handle.
    enum uint OCI_HTYPE_SERVER        = 8;        /// Server handle.
    enum uint OCI_HTYPE_SESSION        = 9;        /// Authentication handle.
    enum uint OCI_HTYPE_AUTHINFO        = OCI_HTYPE_SESSION; /// SessionGet auth handle.
    enum uint OCI_HTYPE_TRANS        = 10;        /// Transaction handle.
    enum uint OCI_HTYPE_COMPLEXOBJECT    = 11;        /// Complex object retrieval handle.
    enum uint OCI_HTYPE_SECURITY        = 12;        /// Security handle.
    enum uint OCI_HTYPE_SUBSCRIPTION    = 13;        /// Subscription handle.
    enum uint OCI_HTYPE_DIRPATH_CTX    = 14;        /// Direct path context.
    enum uint OCI_HTYPE_DIRPATH_COLUMN_ARRAY = 15;        /// Direct path column array.
    enum uint OCI_HTYPE_DIRPATH_STREAM    = 16;        /// Direct path stream.
    enum uint OCI_HTYPE_PROC        = 17;        /// Process handle.
    enum uint OCI_HTYPE_DIRPATH_FN_CTX    = 18;        /// Direct path function context.
    enum uint OCI_HTYPE_DIRPATH_FN_COL_ARRAY = 19;        /// Direct path object column array.
    enum uint OCI_HTYPE_XADSESSION        = 20;        /// Access driver session.
    enum uint OCI_HTYPE_XADTABLE        = 21;        /// Access driver table.
    enum uint OCI_HTYPE_XADFIELD        = 22;        /// Access driver field.
    enum uint OCI_HTYPE_XADGRANULE        = 23;        /// Access driver granule.
    enum uint OCI_HTYPE_XADRECORD        = 24;        /// Access driver record.
    enum uint OCI_HTYPE_XADIO        = 25;        /// Access driver I/O.
    enum uint OCI_HTYPE_CPOOL        = 26;        /// Connection pool handle.
    enum uint OCI_HTYPE_SPOOL        = 27;        /// Session pool handle.
    enum uint OCI_HTYPE_ADMIN        = 28;        /// Admin handle.
    enum uint OCI_HTYPE_EVENT        = 29;        /// HA event handle.
    enum uint OCI_HTYPE_LAST        = 29;        /// Last value of a handle type.

    enum uint OCI_DTYPE_FIRST        = 50;        /// Start value of descriptor type.
    enum uint OCI_DTYPE_LOB        = 50;        /// Lob locator.
    enum uint OCI_DTYPE_SNAP        = 51;        /// Snapshot descriptor.
    enum uint OCI_DTYPE_RSET        = 52;        /// Result set descriptor.
    enum uint OCI_DTYPE_PARAM        = 53;        /// A parameter descriptor obtained from ocigparm.
    enum uint OCI_DTYPE_ROWID        = 54;        /// Rowid descriptor.
    enum uint OCI_DTYPE_COMPLEXOBJECTCOMP    = 55;        /// Complex object retrieval descriptor.
    enum uint OCI_DTYPE_FILE        = 56;        /// File Lob locator.
    enum uint OCI_DTYPE_AQENQ_OPTIONS    = 57;        /// Enqueue options.
    enum uint OCI_DTYPE_AQDEQ_OPTIONS    = 58;        /// Dequeue options.
    enum uint OCI_DTYPE_AQMSG_PROPERTIES    = 59;        /// Message properties.
    enum uint OCI_DTYPE_AQAGENT        = 60;        /// Aq agent.
    enum uint OCI_DTYPE_LOCATOR        = 61;        /// LOB locator.
    enum uint OCI_DTYPE_INTERVAL_YM    = 62;        /// Interval year month.
    enum uint OCI_DTYPE_INTERVAL_DS    = 63;        /// Interval day second.
    enum uint OCI_DTYPE_AQNFY_DESCRIPTOR    = 64;        /// AQ notify descriptor.
    enum uint OCI_DTYPE_DATE        = 65;        /// Date.
    enum uint OCI_DTYPE_TIME        = 66;        /// Time.
    enum uint OCI_DTYPE_TIME_TZ        = 67;        /// Time with timezone.
    enum uint OCI_DTYPE_TIMESTAMP        = 68;        /// Timestamp.
    enum uint OCI_DTYPE_TIMESTAMP_TZ    = 69;        /// Timestamp with timezone.
    enum uint OCI_DTYPE_TIMESTAMP_LTZ    = 70;        /// Timestamp with local tz.
    enum uint OCI_DTYPE_UCB        = 71;        /// User callback descriptor.
    enum uint OCI_DTYPE_SRVDN        = 72;        /// Server DN list descriptor.
    enum uint OCI_DTYPE_SIGNATURE        = 73;        /// Signature.
    enum uint OCI_DTYPE_RESERVED_1        = 74;        /// Reserved for internal use.
    enum uint OCI_DTYPE_AQLIS_OPTIONS    = 75;        /// AQ listen options.
    enum uint OCI_DTYPE_AQLIS_MSG_PROPERTIES = 76;        /// AQ listen msg props.
    enum uint OCI_DTYPE_CHDES        = 77;        /// Top level change notification desc.
    enum uint OCI_DTYPE_TABLE_CHDES    = 78;        /// Table change descriptor.
    enum uint OCI_DTYPE_ROW_CHDES        = 79;        /// Row change descriptor.
    enum uint OCI_DTYPE_LAST        = 79;        /// Last value of a descriptor type.

    enum uint OCI_TEMP_BLOB        = 1;        /// LOB type - BLOB.
    enum uint OCI_TEMP_CLOB        = 2;        /// LOB type - CLOB.

    enum uint OCI_OTYPE_NAME        = 1;        /// Object name.
    enum uint OCI_OTYPE_REF        = 2;        /// REF to TDO.
    enum uint OCI_OTYPE_PTR        = 3;        /// PTR to TDO.

    enum uint OCI_ATTR_FNCODE        = 1;        /// The OCI function code.
    enum uint OCI_ATTR_OBJECT        = 2;        /// Is the environment initialized in object mode?
    enum uint OCI_ATTR_NONBLOCKING_MODE    = 3;        /// Non blocking mode.
    enum uint OCI_ATTR_SQLCODE        = 4;        /// The SQL verb.
    enum uint OCI_ATTR_ENV            = 5;        /// The environment handle.
    enum uint OCI_ATTR_SERVER        = 6;        /// The server handle.
    enum uint OCI_ATTR_SESSION        = 7;        /// The user session handle.
    enum uint OCI_ATTR_TRANS        = 8;        /// The transaction handle.
    enum uint OCI_ATTR_ROW_COUNT        = 9;        /// The rows processed so far.
    enum uint OCI_ATTR_SQLFNCODE        = 10;        /// The SQL verb of the statement.
    enum uint OCI_ATTR_PREFETCH_ROWS    = 11;        /// Sets the number of rows to prefetch.
    enum uint OCI_ATTR_NESTED_PREFETCH_ROWS= 12;        /// The prefetch rows of nested table.
    enum uint OCI_ATTR_PREFETCH_MEMORY    = 13;        /// Memory limit for rows fetched.
    enum uint OCI_ATTR_NESTED_PREFETCH_MEMORY = 14;    /// Memory limit for nested rows.
    enum uint OCI_ATTR_CHAR_COUNT        = 15;        /// This specifies the bind and define size in characters.
    enum uint OCI_ATTR_PDSCL        = 16;        /// Packed decimal scale.
    enum uint OCI_ATTR_FSPRECISION        = OCI_ATTR_PDSCL; /// Fs prec for datetime data types.
    enum uint OCI_ATTR_PDPRC        = 17;        /// Packed decimal format.
    enum uint OCI_ATTR_LFPRECISION        = OCI_ATTR_PDPRC; /// Fs prec for datetime data types.
    enum uint OCI_ATTR_PARAM_COUNT        = 18;        /// Number of column in the select list.
    enum uint OCI_ATTR_ROWID        = 19;        /// The rowid.
    enum uint OCI_ATTR_CHARSET        = 20;        /// The character set value.
    enum uint OCI_ATTR_NCHAR        = 21;        /// NCHAR type.
    enum uint OCI_ATTR_USERNAME        = 22;        /// Username attribute.
    enum uint OCI_ATTR_PASSWORD        = 23;        /// Password attribute.
    enum uint OCI_ATTR_STMT_TYPE        = 24;        /// Statement type.
    enum uint OCI_ATTR_INTERNAL_NAME    = 25;        /// Tser friendly global name.
    enum uint OCI_ATTR_EXTERNAL_NAME    = 26;        /// The internal name for global txn.
    enum uint OCI_ATTR_XID            = 27;                        /// XOPEN defined global transaction id.
    enum uint OCI_ATTR_TRANS_LOCK        = 28;        ///
    enum uint OCI_ATTR_TRANS_NAME        = 29;        /// String to identify a global transaction.
    enum uint OCI_ATTR_HEAPALLOC        = 30;        /// Memory allocated on the heap.
    enum uint OCI_ATTR_CHARSET_ID        = 31;        /// Character Set ID.
    enum uint OCI_ATTR_CHARSET_FORM    = 32;        /// Character Set Form.
    enum uint OCI_ATTR_MAXDATA_SIZE    = 33;        /// Maximumsize of data on the server .
    enum uint OCI_ATTR_CACHE_OPT_SIZE    = 34;        /// Object cache optimal size.
    enum uint OCI_ATTR_CACHE_MAX_SIZE    = 35;        /// Object cache maximum size percentage.
    enum uint OCI_ATTR_PINOPTION        = 36;        /// Object cache default pin option.
    enum uint OCI_ATTR_ALLOC_DURATION    = 37;        /// Object cache default allocation duration.
    enum uint OCI_ATTR_PIN_DURATION    = 38;        /// Object cache default pin duration.
    enum uint OCI_ATTR_FDO            = 39;        /// Format Descriptor object attribute.
    enum uint OCI_ATTR_POSTPROCESSING_CALLBACK = 40;    /// Callback to process outbind data.
    enum uint OCI_ATTR_POSTPROCESSING_CONTEXT = 41;    /// Callback context to process outbind data.
    enum uint OCI_ATTR_ROWS_RETURNED    = 42;        /// Number of rows returned in current iter - for Bind handles.
    enum uint OCI_ATTR_FOCBK        = 43;        /// Failover Callback attribute.
    enum uint OCI_ATTR_IN_V8_MODE        = 44;        /// Is the server/service context in V8 mode?
    enum uint OCI_ATTR_LOBEMPTY        = 45;        /// Empty lob ?
    enum uint OCI_ATTR_SESSLANG        = 46;        /// Session language handle.

    enum uint OCI_ATTR_VISIBILITY        = 47;        /// Visibility.
    enum uint OCI_ATTR_RELATIVE_MSGID    = 48;        /// Relative message id.
    enum uint OCI_ATTR_SEQUENCE_DEVIATION    = 49;        /// Sequence deviation.

    enum uint OCI_ATTR_CONSUMER_NAME    = 50;        /// Consumer name.
    enum uint OCI_ATTR_DEQ_MODE        = 51;        /// Dequeue mode.
    enum uint OCI_ATTR_NAVIGATION        = 52;        /// Navigation.
    enum uint OCI_ATTR_WAIT        = 53;        /// Wait.
    enum uint OCI_ATTR_DEQ_MSGID        = 54;        /// Dequeue message id.

    enum uint OCI_ATTR_PRIORITY        = 55;        /// Priority.
    enum uint OCI_ATTR_DELAY        = 56;        /// Delay.
    enum uint OCI_ATTR_EXPIRATION        = 57;        /// Expiration.
    enum uint OCI_ATTR_CORRELATION        = 58;        /// Correlation id.
    enum uint OCI_ATTR_ATTEMPTS        = 59;        /// # of attempts.
    enum uint OCI_ATTR_RECIPIENT_LIST    = 60;        /// Recipient list.
    enum uint OCI_ATTR_EXCEPTION_QUEUE    = 61;        /// Exception queue name.
    enum uint OCI_ATTR_ENQ_TIME        = 62;        /// Enqueue time (only OCIAttrGet).
    enum uint OCI_ATTR_MSG_STATE        = 63;        /// Message state (only OCIAttrGet).
    enum uint OCI_ATTR_AGENT_NAME        = 64;        /// Agent name.
    enum uint OCI_ATTR_AGENT_ADDRESS    = 65;        /// Agent address.
    enum uint OCI_ATTR_AGENT_PROTOCOL    = 66;        /// Agent protocol.
    enum uint OCI_ATTR_USER_PROPERTY    = 67;        /// User property.
    enum uint OCI_ATTR_SENDER_ID        = 68;        /// Sender id.
    enum uint OCI_ATTR_ORIGINAL_MSGID    = 69;        /// Original message id.

    enum uint OCI_ATTR_QUEUE_NAME        = 70;        /// Queue name.
    enum uint OCI_ATTR_NFY_MSGID        = 71;        /// Message id.
    enum uint OCI_ATTR_MSG_PROP        = 72;        /// Message properties.

    enum uint OCI_ATTR_NUM_DML_ERRORS    = 73;        /// Number of errors in array DML.
    enum uint OCI_ATTR_DML_ROW_OFFSET    = 74;        /// Row offset in the array.

    enum uint OCI_ATTR_AQ_NUM_ERRORS    = OCI_ATTR_NUM_DML_ERRORS; ///
    enum uint OCI_ATTR_AQ_ERROR_INDEX    = OCI_ATTR_DML_ROW_OFFSET; ///

    enum uint OCI_ATTR_DATEFORMAT        = 75;        /// Default date format string.
    enum uint OCI_ATTR_BUF_ADDR        = 76;        /// Buffer address.
    enum uint OCI_ATTR_BUF_SIZE        = 77;        /// Buffer size.

    enum uint OCI_ATTR_NUM_ROWS        = 81;        /// Number of rows in column array.
    enum uint OCI_ATTR_COL_COUNT        = 82;        /// Columns of column array processed so far.            .
    enum uint OCI_ATTR_STREAM_OFFSET    = 83;        /// Str off of last row processed.
    enum uint OCI_ATTR_SHARED_HEAPALLOC    = 84;        /// Shared Heap Allocation Size.

    enum uint OCI_ATTR_SERVER_GROUP    = 85;        /// Server group name.

    enum uint OCI_ATTR_MIGSESSION        = 86;        /// Migratable session attribute.

    enum uint OCI_ATTR_NOCACHE        = 87;        /// Temporary LOBs.

    enum uint OCI_ATTR_MEMPOOL_SIZE    = 88;        /// Pool Size.
    enum uint OCI_ATTR_MEMPOOL_INSTNAME    = 89;        /// Instance name.
    enum uint OCI_ATTR_MEMPOOL_APPNAME    = 90;        /// Application name.
    enum uint OCI_ATTR_MEMPOOL_HOMENAME    = 91;        /// Home Directory name.
    enum uint OCI_ATTR_MEMPOOL_MODEL    = 92;        /// Pool Model (proc,thrd,both).
    enum uint OCI_ATTR_MODES        = 93;        /// Modes.

    enum uint OCI_ATTR_SUBSCR_NAME        = 94;        /// Name of subscription.
    enum uint OCI_ATTR_SUBSCR_CALLBACK    = 95;        /// Associated callback.
    enum uint OCI_ATTR_SUBSCR_CTX        = 96;        /// Associated callback context.
    enum uint OCI_ATTR_SUBSCR_PAYLOAD    = 97;        /// Associated payload.
    enum uint OCI_ATTR_SUBSCR_NAMESPACE    = 98;        /// Associated namespace.

    enum uint OCI_ATTR_PROXY_CREDENTIALS    = 99;        /// Proxy user credentials.
    enum uint OCI_ATTR_INITIAL_CLIENT_ROLES= 100;        /// Initial client role list.

    enum uint OCI_ATTR_UNK            = 101;        /// Unknown attribute.
    enum uint OCI_ATTR_NUM_COLS        = 102;        /// Number of columns.
    enum uint OCI_ATTR_LIST_COLUMNS    = 103;        /// Parameter of the column list.
    enum uint OCI_ATTR_RDBA        = 104;        /// DBA of the segment header.
    enum uint OCI_ATTR_CLUSTERED        = 105;        /// Whether the table is clustered.
    enum uint OCI_ATTR_PARTITIONED        = 106;        /// Whether the table is partitioned.
    enum uint OCI_ATTR_INDEX_ONLY        = 107;        /// Whether the table is index only.
    enum uint OCI_ATTR_LIST_ARGUMENTS    = 108;        /// Parameter of the argument list.
    enum uint OCI_ATTR_LIST_SUBPROGRAMS    = 109;        /// Parameter of the subprogram list.
    enum uint OCI_ATTR_REF_TDO        = 110;        /// REF to the type descriptor.
    enum uint OCI_ATTR_LINK        = 111;        /// The database link name.
    enum uint OCI_ATTR_MIN            = 112;        /// Minimum value.
    enum uint OCI_ATTR_MAX            = 113;        /// Maximum value.
    enum uint OCI_ATTR_INCR        = 114;        /// Increment value.
    enum uint OCI_ATTR_CACHE        = 115;        /// Number of sequence numbers cached.
    enum uint OCI_ATTR_ORDER        = 116;        /// Whether the sequence is ordered.
    enum uint OCI_ATTR_HW_MARK        = 117;        /// High-water mark.
    enum uint OCI_ATTR_TYPE_SCHEMA        = 118;        /// Type's schema name.
    enum uint OCI_ATTR_TIMESTAMP        = 119;        /// Timestamp of the object.
    enum uint OCI_ATTR_NUM_ATTRS        = 120;        /// Number of sttributes.
    enum uint OCI_ATTR_NUM_PARAMS        = 121;        /// Number of parameters.
    enum uint OCI_ATTR_OBJID        = 122;        /// Object id for a table or view.
    enum uint OCI_ATTR_PTYPE        = 123;        /// Type of info described by.
    enum uint OCI_ATTR_PARAM        = 124;        /// Parameter descriptor.
    enum uint OCI_ATTR_OVERLOAD_ID        = 125;        /// Overload ID for funcs and procs.
    enum uint OCI_ATTR_TABLESPACE        = 126;        /// Table name space.
    enum uint OCI_ATTR_TDO            = 127;        /// TDO of a type.
    enum uint OCI_ATTR_LTYPE        = 128;        /// List type.
    enum uint OCI_ATTR_PARSE_ERROR_OFFSET    = 129;        /// Parse Error offset.
    enum uint OCI_ATTR_IS_TEMPORARY    = 130;        /// Whether table is temporary.
    enum uint OCI_ATTR_IS_TYPED        = 131;        /// Whether table is typed.
    enum uint OCI_ATTR_DURATION        = 132;        /// Duration of temporary table.
    enum uint OCI_ATTR_IS_INVOKER_RIGHTS    = 133;        /// Is invoker rights.
    enum uint OCI_ATTR_OBJ_NAME        = 134;        /// Top level schema obj name.
    enum uint OCI_ATTR_OBJ_SCHEMA        = 135;        /// Schema name.
    enum uint OCI_ATTR_OBJ_ID        = 136;        /// Top level schema object id.

    enum uint OCI_ATTR_TRANS_TIMEOUT    = 142;        /// Transaction timeout.
    enum uint OCI_ATTR_SERVER_STATUS    = 143;        /// State of the server handle.
    enum uint OCI_ATTR_STATEMENT        = 144;        /// Statement txt in stmt hdl.

    enum uint OCI_ATTR_DEQCOND        = 146;        /// Dequeue condition.
    enum uint OCI_ATTR_RESERVED_2        = 147;        /// Reserved.


    enum uint OCI_ATTR_SUBSCR_RECPT    = 148;        /// Recepient of subscription.
    enum uint OCI_ATTR_SUBSCR_RECPTPROTO    = 149;        /// Protocol for recepient.

    enum uint OCI_ATTR_LDAP_HOST        = 153;        /// LDAP host to connect to.
    enum uint OCI_ATTR_LDAP_PORT        = 154;        /// LDAP port to connect to.
    enum uint OCI_ATTR_BIND_DN        = 155;        /// Bind DN.
    enum uint OCI_ATTR_LDAP_CRED        = 156;        /// Credentials to connect to LDAP.
    enum uint OCI_ATTR_WALL_LOC        = 157;        /// Client wallet location.
    enum uint OCI_ATTR_LDAP_AUTH        = 158;        /// LDAP authentication method.
    enum uint OCI_ATTR_LDAP_CTX        = 159;        /// LDAP adminstration context DN.
    enum uint OCI_ATTR_SERVER_DNS        = 160;        /// List of registration server DNs.

    enum uint OCI_ATTR_DN_COUNT        = 161;        /// The number of server DNs.
    enum uint OCI_ATTR_SERVER_DN        = 162;        /// Server DN attribute.

    enum uint OCI_ATTR_MAXCHAR_SIZE    = 163;        /// Max char size of data.

    enum uint OCI_ATTR_CURRENT_POSITION    = 164;        /// For scrollable result sets.

    enum uint OCI_ATTR_RESERVED_3        = 165;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_4        = 166;        /// Reserved.

    enum uint OCI_ATTR_DIGEST_ALGO        = 168;        /// Digest algorithm.
    enum uint OCI_ATTR_CERTIFICATE        = 169;        /// Certificate.
    enum uint OCI_ATTR_SIGNATURE_ALGO    = 170;        /// Signature algorithm.
    enum uint OCI_ATTR_CANONICAL_ALGO    = 171;        /// Canonicalization algo..
    enum uint OCI_ATTR_PRIVATE_KEY        = 172;        /// Private key.
    enum uint OCI_ATTR_DIGEST_VALUE    = 173;        /// Digest value.
    enum uint OCI_ATTR_SIGNATURE_VAL    = 174;        /// Signature value.
    enum uint OCI_ATTR_SIGNATURE        = 175;        /// Signature.

    enum uint OCI_ATTR_STMTCACHESIZE    = 176;        /// Size of the stm cache.

    enum uint OCI_ATTR_CONN_NOWAIT        = 178;        ///
    enum uint OCI_ATTR_CONN_BUSY_COUNT    = 179;        ///
    enum uint OCI_ATTR_CONN_OPEN_COUNT    = 180;        ///
    enum uint OCI_ATTR_CONN_TIMEOUT    = 181;        ///
    enum uint OCI_ATTR_STMT_STATE        = 182;        ///
    enum uint OCI_ATTR_CONN_MIN        = 183;        ///
    enum uint OCI_ATTR_CONN_MAX        = 184;        ///
    enum uint OCI_ATTR_CONN_INCR        = 185;        ///

    enum uint OCI_ATTR_NUM_OPEN_STMTS    = 188;        /// Open stmts in session.
    enum uint OCI_ATTR_DESCRIBE_NATIVE    = 189;        /// Get native info via desc.

    enum uint OCI_ATTR_BIND_COUNT        = 190;        /// Number of bind postions.
    enum uint OCI_ATTR_HANDLE_POSITION    = 191;        /// Position of bind/define handle.
    enum uint OCI_ATTR_RESERVED_5        = 192;        /// Reserved.
    enum uint OCI_ATTR_SERVER_BUSY        = 193;        /// Call in progress on server.

    enum uint OCI_ATTR_SUBSCR_RECPTPRES    = 195;        ///
    enum uint OCI_ATTR_TRANSFORMATION    = 196;        /// AQ message transformation.

    enum uint OCI_ATTR_ROWS_FETCHED    = 197;        /// Rows fetched in last call.

    enum uint OCI_ATTR_SCN_BASE        = 198;        /// Snapshot base.
    enum uint OCI_ATTR_SCN_WRAP        = 199;        /// Snapshot wrap.

    enum uint OCI_ATTR_RESERVED_6        = 200;        /// Reserved.
    enum uint OCI_ATTR_READONLY_TXN    = 201;        /// Txn is readonly.
    enum uint OCI_ATTR_RESERVED_7        = 202;        /// Reserved.
    enum uint OCI_ATTR_ERRONEOUS_COLUMN    = 203;        /// Position of erroneous col.
    enum uint OCI_ATTR_RESERVED_8        = 204;        /// Reserved.

    enum uint OCI_ATTR_INST_TYPE        = 207;        /// Oracle instance type.

    enum uint OCI_ATTR_ENV_UTF16        = 209;        /// Is env in UTF16 mode?
    enum uint OCI_ATTR_RESERVED_9        = 210;        /// Reserved for TMZ.
    enum uint OCI_ATTR_RESERVED_10        = 211;        /// Reserved.

    enum uint OCI_ATTR_RESERVED_12        = 214;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_13        = 215;        /// Reserved.
    enum uint OCI_ATTR_IS_EXTERNAL        = 216;        /// Whether table is external.

    enum uint OCI_ATTR_RESERVED_15        = 217;        /// Reserved.
    enum uint OCI_ATTR_STMT_IS_RETURNING    = 218;        /// Stmt has returning clause.
    enum uint OCI_ATTR_RESERVED_16        = 219;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_17        = 220;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_18        = 221;        /// Reserved.

    enum uint OCI_ATTR_RESERVED_19        = 222;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_20        = 223;        /// Reserved.
    enum uint OCI_ATTR_CURRENT_SCHEMA    = 224;        /// Current Schema.

    enum uint OCI_ATTR_SUBSCR_QOSFLAGS    = 225;        /// QOS flags.
    enum uint OCI_ATTR_SUBSCR_PAYLOADCBK    = 226;        /// Payload callback.
    enum uint OCI_ATTR_SUBSCR_TIMEOUT    = 227;        /// Timeout.
    enum uint OCI_ATTR_SUBSCR_NAMESPACE_CTX= 228;        /// Namespace context.

    enum uint OCI_ATTR_BIND_ROWCBK        = 301;        /// Bind row callback.
    enum uint OCI_ATTR_BIND_ROWCTX        = 302;        /// Ctx for bind row callback.
    enum uint OCI_ATTR_SKIP_BUFFER        = 303;        /// Skip buffer in array ops.

    enum uint OCI_ATTR_EVTCBK        = 304;        /// Ha callback.
    enum uint OCI_ATTR_EVTCTX        = 305;        /// Ctx for ha callback.

    enum uint OCI_ATTR_USER_MEMORY        = 306;        /// Pointer to user memory.

    enum uint OCI_ATTR_SUBSCR_PORTNO    = 390;        /// Port no to listen.

    enum uint OCI_ATTR_CHNF_TABLENAMES    = 401;        /// Out: array of table names.
    enum uint OCI_ATTR_CHNF_ROWIDS        = 402;        /// In: rowids needed.
    enum uint OCI_ATTR_CHNF_OPERATIONS    = 403;        /// In: notification operation filter.
    enum uint OCI_ATTR_CHNF_CHANGELAG    = 404;        /// Txn lag between notifications.

    enum uint OCI_ATTR_CHDES_DBNAME    = 405;        /// Source database.
    enum uint OCI_ATTR_CHDES_NFYTYPE    = 406;        /// Notification type flags.
    enum uint OCI_ATTR_CHDES_XID        = 407;        /// XID    of the transaction.
    enum uint OCI_ATTR_CHDES_TABLE_CHANGES    = 408;        /// Array of table chg descriptors.

    enum uint OCI_ATTR_CHDES_TABLE_NAME    = 409;        /// Table name.
    enum uint OCI_ATTR_CHDES_TABLE_OPFLAGS    = 410;        /// Table operation flags.
    enum uint OCI_ATTR_CHDES_TABLE_ROW_CHANGES = 411;    /// Array of changed rows.
    enum uint OCI_ATTR_CHDES_ROW_ROWID    = 412;        /// Rowid of changed row.
    enum uint OCI_ATTR_CHDES_ROW_OPFLAGS    = 413;        /// Row operation flags.

    enum uint OCI_ATTR_CHNF_REGHANDLE    = 414;        /// IN: subscription handle.
    enum uint OCI_ATTR_RESERVED_21        = 415;        /// Reserved.
    enum uint OCI_ATTR_PROXY_CLIENT    = 416;        ///

    enum uint OCI_ATTR_TABLE_ENC        = 417;        /// Does table have any encrypt columns.
    enum uint OCI_ATTR_TABLE_ENC_ALG    = 418;        /// Table encryption Algorithm.
    enum uint OCI_ATTR_TABLE_ENC_ALG_ID    = 419;        /// Internal Id of encryption Algorithm.

    enum uint OCI_ATTR_ENV_CHARSET_ID    = OCI_ATTR_CHARSET_ID; /// Charset id in env.
    enum uint OCI_ATTR_ENV_NCHARSET_ID    = OCI_ATTR_NCHARSET_ID; /// Ncharset id in env.

    enum uint OCI_EVENT_NONE        = 0x0;        /// None.
    enum uint OCI_EVENT_STARTUP        = 0x1;        /// Startup database.
    enum uint OCI_EVENT_SHUTDOWN        = 0x2;        /// Shutdown database.
    enum uint OCI_EVENT_SHUTDOWN_ANY    = 0x3;        /// Startup instance.
    enum uint OCI_EVENT_DROP_DB        = 0x4;        /// Drop database        .
    enum uint OCI_EVENT_DEREG        = 0x5;        /// Subscription deregistered.
    enum uint OCI_EVENT_OBJCHANGE        = 0x6;        /// Object change notification.

    enum uint OCI_OPCODE_ALLOPS        = 0x0;        /// Interested in all operations.
    enum uint OCI_OPCODE_ALLROWS        = 0x1;        /// All rows invalidated .
    enum uint OCI_OPCODE_INSERT        = 0x2;        /// INSERT.
    enum uint OCI_OPCODE_UPDATE        = 0x4;        /// UPDATE.
    enum uint OCI_OPCODE_DELETE        = 0x8;        /// DELETE.
    enum uint OCI_OPCODE_ALTER        = 0x10;        /// ALTER.
    enum uint OCI_OPCODE_DROP        = 0x20;        /// DROP TABLE.
    enum uint OCI_OPCODE_UNKNOWN        = 0x40;        /// GENERIC/ UNKNOWN.

    enum uint OCI_SUBSCR_PROTO_OCI        = 0;        /// OCI.
    enum uint OCI_SUBSCR_PROTO_MAIL    = 1;        /// Mail.
    enum uint OCI_SUBSCR_PROTO_SERVER    = 2;        /// Server.
    enum uint OCI_SUBSCR_PROTO_HTTP    = 3;        /// HTTP.
    enum uint OCI_SUBSCR_PROTO_MAX        = 4;        /// Max current protocols.
    enum uint OCI_SUBSCR_PRES_DEFAULT    = 0;        /// Default.
    enum uint OCI_SUBSCR_PRES_XML        = 1;        /// XML.
    enum uint OCI_SUBSCR_PRES_MAX        = 2;        /// Max current presentations.
    enum uint OCI_SUBSCR_QOS_RELIABLE    = 0x01;        /// Reliable.
    enum uint OCI_SUBSCR_QOS_PAYLOAD    = 0x02;        /// Payload delivery.
    enum uint OCI_SUBSCR_QOS_REPLICATE    = 0x04;        /// Replicate to director.
    enum uint OCI_SUBSCR_QOS_SECURE    = 0x08;        /// Secure payload delivery.
    enum uint OCI_SUBSCR_QOS_PURGE_ON_NTFN    = 0x10;        /// Purge on first ntfn.
    enum uint OCI_SUBSCR_QOS_MULTICBK    = 0x20;        /// Multi instance callback.

    enum uint OCI_UCS2ID            = 1000;        /// UCS2 charset ID.
    enum uint OCI_UTF16ID            = 1000;        /// UTF16 charset ID.

    enum uint OCI_SERVER_NOT_CONNECTED    = 0x0;        ///
    enum uint OCI_SERVER_NORMAL        = 0x1;        ///

    enum uint OCI_SUBSCR_NAMESPACE_ANONYMOUS = 0;        /// Anonymous Namespace.
    enum uint OCI_SUBSCR_NAMESPACE_AQ    = 1;        /// Advanced Queues.
    enum uint OCI_SUBSCR_NAMESPACE_DBCHANGE= 2;        /// Change notification.
    enum uint OCI_SUBSCR_NAMESPACE_MAX    = 3;        /// Max Name Space Number.

    enum uint OCI_CRED_RDBMS        = 1;        /// Database username/password.
    enum uint OCI_CRED_EXT            = 2;        /// Externally provided credentials.
    enum uint OCI_CRED_PROXY        = 3;        /// Proxy authentication.
    enum uint OCI_CRED_RESERVED_1        = 4;        /// Reserved.
    enum uint OCI_CRED_RESERVED_2        = 5;        /// Reserved.

    enum uint OCI_SUCCESS            = 0;        /// Maps to SQL_SUCCESS of SAG CLI.
    enum uint OCI_SUCCESS_WITH_INFO    = 1;        /// Maps to SQL_SUCCESS_WITH_INFO.
    enum uint OCI_RESERVED_FOR_INT_USE    = 200;        /// Reserved.
    enum uint OCI_NO_DATA            = 100;        /// Maps to SQL_NO_DATA.
    enum int OCI_ERROR            = -1;        /// Maps to SQL_ERROR.
    enum int OCI_INVALID_HANDLE        = -2;        /// Maps to SQL_INVALID_HANDLE.
    enum uint OCI_NEED_DATA        = 99;        /// Maps to SQL_NEED_DATA.
    enum int OCI_STILL_EXECUTING        = -3123;    /// OCI would block error.

    enum int OCI_CONTINUE            = -24200;    /// Continue with the body of the OCI function.
    enum int OCI_ROWCBK_DONE        = -24201;    /// Done with user row callback.

    enum uint OCI_DT_INVALID_DAY        = 0x1;        /// Bad day.
    enum uint OCI_DT_DAY_BELOW_VALID    = 0x2;        /// Bad DAy Low/high bit (1=low).
    enum uint OCI_DT_INVALID_MONTH        = 0x4;        /// Bad MOnth.
    enum uint OCI_DT_MONTH_BELOW_VALID    = 0x8;        /// Bad MOnth Low/high bit (1=low).
    enum uint OCI_DT_INVALID_YEAR        = 0x10;        /// Bad YeaR.
    enum uint OCI_DT_YEAR_BELOW_VALID    = 0x20;        /// Bad YeaR Low/high bit (1=low).
    enum uint OCI_DT_INVALID_HOUR        = 0x40;        /// Bad HouR.
    enum uint OCI_DT_HOUR_BELOW_VALID    = 0x80;        /// Bad HouR Low/high bit (1=low).
    enum uint OCI_DT_INVALID_MINUTE    = 0x100;    /// Bad MiNute.
    enum uint OCI_DT_MINUTE_BELOW_VALID    = 0x200;    /// Bad MiNute Low/high bit (1=low).
    enum uint OCI_DT_INVALID_SECOND    = 0x400;    /// Bad SeCond.
    enum uint OCI_DT_SECOND_BELOW_VALID    = 0x800;    /// Bad second Low/high bit (1=low).
    enum uint OCI_DT_DAY_MISSING_FROM_1582    = 0x1000;    /// Day is one of those "missing" from 1582.
    enum uint OCI_DT_YEAR_ZERO        = 0x2000;    /// Year may not equal zero.
    enum uint OCI_DT_INVALID_TIMEZONE    = 0x4000;    /// Bad Timezone.
    enum uint OCI_DT_INVALID_FORMAT    = 0x8000;    /// Bad date format input.

    enum uint OCI_INTER_INVALID_DAY    = 0x1;        /// Bad day.
    enum uint OCI_INTER_DAY_BELOW_VALID    = 0x2;        /// Bad DAy Low/high bit (1=low).
    enum uint OCI_INTER_INVALID_MONTH    = 0x4;        /// Bad MOnth.
    enum uint OCI_INTER_MONTH_BELOW_VALID    = 0x8;        /// Bad MOnth Low/high bit (1=low).
    enum uint OCI_INTER_INVALID_YEAR    = 0x10;        /// Bad YeaR.
    enum uint OCI_INTER_YEAR_BELOW_VALID    = 0x20;        /// Bad YeaR Low/high bit (1=low).
    enum uint OCI_INTER_INVALID_HOUR    = 0x40;        /// Bad HouR.
    enum uint OCI_INTER_HOUR_BELOW_VALID    = 0x80;        /// Bad HouR Low/high bit (1=low).
    enum uint OCI_INTER_INVALID_MINUTE    = 0x100;    /// Bad MiNute.
    enum uint OCI_INTER_MINUTE_BELOW_VALID    = 0x200;    /// Bad MiNute Low/high bit(1=low).
    enum uint OCI_INTER_INVALID_SECOND    = 0x400;    /// Bad SeCond.
    enum uint OCI_INTER_SECOND_BELOW_VALID    = 0x800;    /// Bad second Low/high bit(1=low).
    enum uint OCI_INTER_INVALID_FRACSEC    = 0x1000;    /// Bad Fractional second.
    enum uint OCI_INTER_FRACSEC_BELOW_VALID= 0x2000;    /// Bad fractional second Low/High.

    enum uint OCI_V7_SYNTAX        = 2;        /// V815 language - for backwards compatibility.
    enum uint OCI_V8_SYNTAX        = 3;        /// V815 language - for backwards compatibility.
    enum uint OCI_NTV_SYNTAX        = 1;        /// Use whatever is the native lang of server.

    enum uint OCI_FETCH_CURRENT        = 0x00000001;    /// Refetching current position .
    enum uint OCI_FETCH_NEXT        = 0x00000002;    /// Next row.
    enum uint OCI_FETCH_FIRST        = 0x00000004;    /// First row of the result set.
    enum uint OCI_FETCH_LAST        = 0x00000008;    /// The last row of the result set.
    enum uint OCI_FETCH_PRIOR        = 0x00000010;    /// Previous row relative to current.
    enum uint OCI_FETCH_ABSOLUTE        = 0x00000020;    /// Absolute offset from first.
    enum uint OCI_FETCH_RELATIVE        = 0x00000040;    /// Offset relative to current.
    enum uint OCI_FETCH_RESERVED_1        = 0x00000080;    /// Reserved.
    enum uint OCI_FETCH_RESERVED_2        = 0x00000100;    /// Reserved.
    enum uint OCI_FETCH_RESERVED_3        = 0x00000200;    /// Reserved.
    enum uint OCI_FETCH_RESERVED_4        = 0x00000400;    /// Reserved.
    enum uint OCI_FETCH_RESERVED_5        = 0x00000800;    /// Reserved.

    enum uint OCI_SB2_IND_PTR        = 0x00000001;    /// Unused.
    enum uint OCI_DATA_AT_EXEC        = 0x00000002;    /// Fata at execute time.
    enum uint OCI_DYNAMIC_FETCH        = 0x00000002;    /// Detch dynamically.
    enum uint OCI_PIECEWISE        = 0x00000004;    /// Piecewise DMLs or fetch.
    enum uint OCI_DEFINE_RESERVED_1    = 0x00000008;    /// Reserved.
    enum uint OCI_BIND_RESERVED_2        = 0x00000010;    /// Reserved.
    enum uint OCI_DEFINE_RESERVED_2    = 0x00000020;    /// Reserved.
    enum uint OCI_BIND_SOFT        = 0x00000040;    /// Soft bind or define.
    enum uint OCI_DEFINE_SOFT        = 0x00000080;    /// Soft bind or define.
    enum uint OCI_BIND_RESERVED_3        = 0x00000100;    /// Reserved.

    enum uint OCI_DEFAULT            = 0x00000000;    /// The default value for parameters and attributes.
    enum uint OCI_THREADED            = 0x00000001;    /// Application is in threaded environment.
    enum uint OCI_OBJECT            = 0x00000002;    /// Application is in object environment.
    enum uint OCI_EVENTS            = 0x00000004;    /// Application is enabled for events.
    enum uint OCI_RESERVED1        = 0x00000008;    /// Reserved.
    enum uint OCI_SHARED            = 0x00000010;    /// The application is in shared mode.
    enum uint OCI_RESERVED2        = 0x00000020;    /// Reserved.

    enum uint OCI_NO_UCB            = 0x00000040;    /// No user callback called during ini.
    enum uint OCI_NO_MUTEX            = 0x00000080;    /// The environment handle will not be protected by a mutex internally.
    enum uint OCI_SHARED_EXT        = 0x00000100;    /// Used for shared forms.
    enum uint OCI_ALWAYS_BLOCKING        = 0x00000400;    /// All connections always blocking.
    enum uint OCI_USE_LDAP            = 0x00001000;    /// Allow    LDAP connections.
    enum uint OCI_REG_LDAPONLY        = 0x00002000;    /// Only register to LDAP.
    enum uint OCI_UTF16            = 0x00004000;    /// Mode for all UTF16 metadata.
    enum uint OCI_AFC_PAD_ON        = 0x00008000;    /// Turn on AFC blank padding when rlenp present.
    enum uint OCI_ENVCR_RESERVED3        = 0x00010000;    /// Reserved.
    enum uint OCI_NEW_LENGTH_SEMANTICS    = 0x00020000;    /// Adopt new length semantics.
    enum uint OCI_NO_MUTEX_STMT        = 0x00040000;    /// Do not mutex stmt handle.
    enum uint OCI_MUTEX_ENV_ONLY        = 0x00080000;    /// Mutex only the environment handle.
    enum uint OCI_STM_RESERVED4        = 0x00100000;    /// Reserved.
    enum uint OCI_MUTEX_TRY        = 0x00200000;    /// Try to acquire mutex.
    enum uint OCI_NCHAR_LITERAL_REPLACE_ON    = 0x00400000;    /// Nchar literal replace on.
    enum uint OCI_NCHAR_LITERAL_REPLACE_OFF= 0x00800000;    /// Nchar literal replace off.
    enum uint OCI_SRVATCH_RESERVED5    = 0x01000000;    /// Reserved.

    enum uint OCI_CPOOL_REINITIALIZE    = 0x111;    ///

    enum uint OCI_LOGON2_SPOOL        = 0x0001;    /// Use session pool.
    enum uint OCI_LOGON2_CPOOL        = OCI_CPOOL;    /// Use connection pool.
    enum uint OCI_LOGON2_STMTCACHE        = 0x0004;    /// Use Stmt Caching.
    enum uint OCI_LOGON2_PROXY        = 0x0008;    /// Proxy authentiaction.

    enum uint OCI_SPC_REINITIALIZE        = 0x0001;    /// Reinitialize the session pool.
    enum uint OCI_SPC_HOMOGENEOUS        = 0x0002;    /// Session pool is homogeneneous.
    enum uint OCI_SPC_STMTCACHE        = 0x0004;    /// Session pool has stmt cache.

    enum uint OCI_SESSGET_SPOOL        = 0x0001;    /// SessionGet called in SPOOL mode.
    enum uint OCI_SESSGET_CPOOL        = OCI_CPOOL;    /// SessionGet called in CPOOL mode.
    enum uint OCI_SESSGET_STMTCACHE    = 0x0004;    /// Use statement cache.
    enum uint OCI_SESSGET_CREDPROXY    = 0x0008;    /// SessionGet called in proxy mode.
    enum uint OCI_SESSGET_CREDEXT        = 0x0010;    ///
    enum uint OCI_SESSGET_SPOOL_MATCHANY    = 0x0020;    ///

    enum uint OCI_SPOOL_ATTRVAL_WAIT    = 0;        /// Block till you get a session.
    enum uint OCI_SPOOL_ATTRVAL_NOWAIT    = 1;        /// Error out if no session avaliable.
    enum uint OCI_SPOOL_ATTRVAL_FORCEGET    = 2;        /// Get session even if max is exceeded.

    enum uint OCI_SESSRLS_DROPSESS        = 0x0001;    /// Drop the Session.
    enum uint OCI_SESSRLS_RETAG        = 0x0002;    /// Retag the session.

    enum uint OCI_SPD_FORCE        = 0x0001;    /// Force the sessions to terminate.

    enum uint OCI_STMT_STATE_INITIALIZED    = 0x0001;    ///
    enum uint OCI_STMT_STATE_EXECUTED    = 0x0002;    ///
    enum uint OCI_STMT_STATE_END_OF_FETCH    = 0x0003;    ///

    enum uint OCI_MEM_INIT            = 0x01;        ///
    enum uint OCI_MEM_CLN            = 0x02;        ///
    enum uint OCI_MEM_FLUSH        = 0x04;        ///
    enum uint OCI_DUMP_HEAP        = 0x80;        ///

    enum uint OCI_CLIENT_STATS        = 0x10;        ///
    enum uint OCI_SERVER_STATS        = 0x20;        ///

    enum uint OCI_NO_SHARING        = 0x01;        /// Turn off statement handle sharing.
    enum uint OCI_PREP_RESERVED_1        = 0x02;        /// Reserved.
    enum uint OCI_PREP_AFC_PAD_ON        = 0x04;        /// Turn on blank padding for AFC.
    enum uint OCI_PREP_AFC_PAD_OFF        = 0x08;        /// Turn off blank padding for AFC.

    enum uint OCI_BATCH_MODE        = 0x01;        /// Batch the oci statement for execution.
    enum uint OCI_EXACT_FETCH        = 0x02;        /// Fetch the exact rows specified.
    enum uint OCI_STMT_SCROLLABLE_READONLY    = 0x08;        /// If result set is scrollable.
    enum uint OCI_DESCRIBE_ONLY        = 0x10;        /// Only describe the statement.
    enum uint OCI_COMMIT_ON_SUCCESS    = 0x20;        /// Commit, if successful execution.
    enum uint OCI_NON_BLOCKING        = 0x40;        /// Non-blocking.
    enum uint OCI_BATCH_ERRORS        = 0x80;        /// Batch errors in array dmls.
    enum uint OCI_PARSE_ONLY        = 0x100;    /// Only parse the statement.
    enum uint OCI_EXACT_FETCH_RESERVED_1    = 0x200;    /// Reserved.
    enum uint OCI_SHOW_DML_WARNINGS    = 0x400;    /// Return OCI_SUCCESS_WITH_INFO for delete/update w/no where clause.
    enum uint OCI_EXEC_RESERVED_2        = 0x800;    /// Reserved.
    enum uint OCI_DESC_RESERVED_1        = 0x1000;    /// Reserved.
    enum uint OCI_EXEC_RESERVED_3        = 0x2000;    /// Reserved.
    enum uint OCI_EXEC_RESERVED_4        = 0x4000;    /// Reserved.
    enum uint OCI_EXEC_RESERVED_5        = 0x8000;    /// Reserved.

    enum uint OCI_MIGRATE            = 0x00000001;    /// Migratable auth context.
    enum uint OCI_SYSDBA            = 0x00000002;    /// For SYSDBA authorization.
    enum uint OCI_SYSOPER            = 0x00000004;    /// For SYSOPER authorization.
    enum uint OCI_PRELIM_AUTH        = 0x00000008;    /// For preliminary authorization.
    enum uint OCIP_ICACHE            = 0x00000010;    /// Private OCI cache mode.
    enum uint OCI_AUTH_RESERVED_1        = 0x00000020;    /// Reserved.
    enum uint OCI_STMT_CACHE        = 0x00000040;    /// Enable OCI Stmt Caching.
    enum uint OCI_STATELESS_CALL        = 0x00000080;    /// Stateless at call boundary.
    enum uint OCI_STATELESS_TXN        = 0x00000100;    /// Stateless at txn boundary.
    enum uint OCI_STATELESS_APP        = 0x00000200;    /// Stateless at user-specified pts.
    enum uint OCI_AUTH_RESERVED_2        = 0x00000400;    /// Reserved.
    enum uint OCI_AUTH_RESERVED_3        = 0x00000800;    /// Reserved.
    enum uint OCI_AUTH_RESERVED_4        = 0x00001000;    /// Reserved.
    enum uint OCI_AUTH_RESERVED_5        = 0x00002000;    /// Reserved.

    enum uint OCI_SESSEND_RESERVED_1    = 0x0001;    /// Reserved.
    enum uint OCI_SESSEND_RESERVED_2    = 0x0002;    /// Reserved.

    enum uint OCI_FASTPATH            = 0x0010;    /// Attach in fast path mode.
    enum uint OCI_ATCH_RESERVED_1        = 0x0020;    /// Reserved.
    enum uint OCI_ATCH_RESERVED_2        = 0x0080;    /// Reserved.
    enum uint OCI_ATCH_RESERVED_3        = 0x0100;    /// Reserved.
    enum uint OCI_CPOOL            = 0x0200;    /// Attach using server handle from pool.
    enum uint OCI_ATCH_RESERVED_4        = 0x0400;    /// Reserved.
    enum uint OCI_ATCH_RESERVED_5        = 0x2000;    /// Reserved.

    enum uint OCI_PREP2_CACHE_SEARCHONLY    = 0x0010;    /// Only search.
    enum uint OCI_PREP2_GET_PLSQL_WARNINGS    = 0x0020;    /// Get PL/SQL warnings .
    enum uint OCI_PREP2_RESERVED_1        = 0x0040;    /// Reserved.

    enum uint OCI_STRLS_CACHE_DELETE    = 0x0010;    /// Delete from Cache.

    enum uint OCI_PARAM_IN            = 0x01;        /// In parameter.
    enum uint OCI_PARAM_OUT        = 0x02;        /// Out parameter.

    enum uint OCI_TRANS_NEW        = 0x00000001;    /// Starts a new transaction branch.
    enum uint OCI_TRANS_JOIN        = 0x00000002;    /// Join an existing transaction.
    enum uint OCI_TRANS_RESUME        = 0x00000004;    /// Resume this transaction.
    enum uint OCI_TRANS_STARTMASK        = 0x000000ff;    ///

    enum uint OCI_TRANS_READONLY        = 0x00000100;    /// Starts a readonly transaction.
    enum uint OCI_TRANS_READWRITE        = 0x00000200;    /// Starts a read-write transaction.
    enum uint OCI_TRANS_SERIALIZABLE    = 0x00000400;    /// Starts a serializable transaction.
    enum uint OCI_TRANS_ISOLMASK        = 0x0000ff00;    ///

    enum uint OCI_TRANS_LOOSE        = 0x00010000;    /// A loosely coupled branch.
    enum uint OCI_TRANS_TIGHT        = 0x00020000;    /// A tightly coupled branch.
    enum uint OCI_TRANS_TYPEMASK        = 0x000f0000;    ///

    enum uint OCI_TRANS_NOMIGRATE        = 0x00100000;    /// Non migratable transaction.
    enum uint OCI_TRANS_SEPARABLE        = 0x00200000;    /// Separable transaction (8.1.6+).
    enum uint OCI_TRANS_OTSRESUME        = 0x00400000;    /// OTS resuming a transaction.

    enum uint OCI_TRANS_TWOPHASE        = 0x01000000;    /// Use two phase commit.
    enum uint OCI_TRANS_WRITEBATCH        = 0x00000001;    /// Force cmt-redo for local txns.
    enum uint OCI_TRANS_WRITEIMMED        = 0x00000002;    /// No force cmt-redo.
    enum uint OCI_TRANS_WRITEWAIT        = 0x00000004;    /// No sync cmt-redo.
    enum uint OCI_TRANS_WRITENOWAIT    = 0x00000008;    /// Sync cmt-redo for local txns.

    enum uint OCI_ENQ_IMMEDIATE        = 1;        /// Enqueue is an independent transaction.
    enum uint OCI_ENQ_ON_COMMIT        = 2;        /// Enqueue is part of current transaction.

    enum uint OCI_DEQ_BROWSE        = 1;        /// Read message without acquiring a lock.
    enum uint OCI_DEQ_LOCKED        = 2;        /// Read and obtain write lock on message.
    enum uint OCI_DEQ_REMOVE        = 3;        /// Read the message and delete it.
    enum uint OCI_DEQ_REMOVE_NODATA    = 4;        /// Delete message w'o returning payload.
    enum uint OCI_DEQ_GETSIG        = 5;        /// Get signature only.

    enum uint OCI_DEQ_FIRST_MSG        = 1;        /// Get first message at head of queue.
    enum uint OCI_DEQ_NEXT_MSG        = 3;        /// Next message that is available.
    enum uint OCI_DEQ_NEXT_TRANSACTION    = 2;        /// Get first message of next txn group.
    enum uint OCI_DEQ_MULT_TRANSACTION    = 5;        /// Array dequeue across txn groups.

    enum uint OCI_DEQ_RESERVED_1        = 0x000001;    ///

    enum uint OCI_MSG_WAITING        = 1;        /// The message delay has not yet completed.
    enum uint OCI_MSG_READY        = 0;        /// The message is ready to be processed.
    enum uint OCI_MSG_PROCESSED        = 2;        /// The message has been processed.
    enum uint OCI_MSG_EXPIRED        = 3;        /// Message has moved to exception queue.

    enum uint OCI_ENQ_BEFORE        = 2;        /// Enqueue message before another message.
    enum uint OCI_ENQ_TOP            = 3;        /// Enqueue message before all messages.

    enum uint OCI_DEQ_IMMEDIATE        = 1;        /// Dequeue is an independent transaction.
    enum uint OCI_DEQ_ON_COMMIT        = 2;        /// Dequeue is part of current transaction.

    enum int OCI_DEQ_WAIT_FOREVER        = -1;        /// Wait forever if no message available.
    enum uint OCI_DEQ_NO_WAIT        = 0;        /// Do not wait if no message is available.

    enum uint OCI_MSG_NO_DELAY        = 0;        /// Message is available immediately.

    enum int OCI_MSG_NO_EXPIRATION        = -1;        /// Message will never expire.
    enum uint OCI_MSG_PERSISTENT_OR_BUFFERED = 3;        ///
    enum uint OCI_MSG_BUFFERED        = 2;        ///
    enum uint OCI_MSG_PERSISTENT        = 1;        ///

    enum uint OCI_AQ_RESERVED_1        = 0x0002;    ///
    enum uint OCI_AQ_RESERVED_2        = 0x0004;    ///
    enum uint OCI_AQ_RESERVED_3        = 0x0008;    ///
    enum uint OCI_AQ_RESERVED_4        = 0x0010;    ///


    enum uint OCI_ATTR_DATA_SIZE        = 1;        /// Maximum size of the data.
    enum uint OCI_ATTR_DATA_TYPE        = 2;        /// The SQL type of the column/argument.
    enum uint OCI_ATTR_DISP_SIZE        = 3;        /// The display size.
    enum uint OCI_ATTR_NAME        = 4;        /// The name of the column/argument.
    enum uint OCI_ATTR_PRECISION        = 5;        /// Precision if number type.
    enum uint OCI_ATTR_SCALE        = 6;        /// Scale if number type.
    enum uint OCI_ATTR_IS_NULL        = 7;        /// Is it null?
    enum uint OCI_ATTR_TYPE_NAME        = 8;        /// Name of the named data type or a package name for package private types.
    enum uint OCI_ATTR_SCHEMA_NAME        = 9;        /// The schema name.
    enum uint OCI_ATTR_SUB_NAME        = 10;        /// Type name if package private type.
    enum uint OCI_ATTR_POSITION        = 11;        /// Relative position of col/arg in the list of cols/args.

    enum uint OCI_ATTR_COMPLEXOBJECTCOMP_TYPE = 50;    ///
    enum uint OCI_ATTR_COMPLEXOBJECTCOMP_TYPE_LEVEL = 51;    ///
    enum uint OCI_ATTR_COMPLEXOBJECT_LEVEL = 52;        ///
    enum uint OCI_ATTR_COMPLEXOBJECT_COLL_OUTOFLINE = 53;    ///

    enum uint OCI_ATTR_DISP_NAME        = 100;        /// The display name.
    enum uint OCI_ATTR_ENCC_SIZE        = 101;        /// Encrypted data size.
    enum uint OCI_ATTR_COL_ENC        = 102;        /// Column is encrypted?
    enum uint OCI_ATTR_COL_ENC_SALT    = 103;        /// Is encrypted column salted?

    enum uint OCI_ATTR_OVERLOAD        = 210;        /// Is this position overloaded.
    enum uint OCI_ATTR_LEVEL        = 211;        /// Level for structured types.
    enum uint OCI_ATTR_HAS_DEFAULT        = 212;        /// Has a default value.
    enum uint OCI_ATTR_IOMODE        = 213;        /// In, out inout.
    enum uint OCI_ATTR_RADIX        = 214;        /// Returns a radix.
    enum uint OCI_ATTR_NUM_ARGS        = 215;        /// Total number of arguments.

    enum uint OCI_ATTR_TYPECODE        = 216;        /// Object or collection.
    enum uint OCI_ATTR_COLLECTION_TYPECODE    = 217;        /// Varray or nested table.
    enum uint OCI_ATTR_VERSION        = 218;        /// User assigned version.
    enum uint OCI_ATTR_IS_INCOMPLETE_TYPE    = 219;        /// Is this an incomplete type.
    enum uint OCI_ATTR_IS_SYSTEM_TYPE    = 220;        /// A system type.
    enum uint OCI_ATTR_IS_PREDEFINED_TYPE    = 221;        /// A predefined type.
    enum uint OCI_ATTR_IS_TRANSIENT_TYPE    = 222;        /// A transient type.
    enum uint OCI_ATTR_IS_SYSTEM_GENERATED_TYPE = 223;    /// System generated type.
    enum uint OCI_ATTR_HAS_NESTED_TABLE    = 224;        /// Contains nested table attr.
    enum uint OCI_ATTR_HAS_LOB        = 225;        /// Has a lob attribute.
    enum uint OCI_ATTR_HAS_FILE        = 226;        /// Has a file attribute.
    enum uint OCI_ATTR_COLLECTION_ELEMENT    = 227;        /// Has a collection attribute.
    enum uint OCI_ATTR_NUM_TYPE_ATTRS    = 228;        /// Number of attribute types.
    enum uint OCI_ATTR_LIST_TYPE_ATTRS    = 229;        /// List of type attributes.
    enum uint OCI_ATTR_NUM_TYPE_METHODS    = 230;        /// Number of type methods.
    enum uint OCI_ATTR_LIST_TYPE_METHODS    = 231;        /// List of type methods.
    enum uint OCI_ATTR_MAP_METHOD        = 232;        /// Map method of type.
    enum uint OCI_ATTR_ORDER_METHOD    = 233;        /// Order method of type.

    enum uint OCI_ATTR_NUM_ELEMS        = 234;        /// Number of elements.

    enum uint OCI_ATTR_ENCAPSULATION    = 235;        /// Encapsulation level.
    enum uint OCI_ATTR_IS_SELFISH        = 236;        /// Method selfish.
    enum uint OCI_ATTR_IS_VIRTUAL        = 237;        /// Virtual.
    enum uint OCI_ATTR_IS_INLINE        = 238;        /// Inline.
    enum uint OCI_ATTR_IS_CONSTANT        = 239;        /// Constant.
    enum uint OCI_ATTR_HAS_RESULT        = 240;        /// Has result.
    enum uint OCI_ATTR_IS_CONSTRUCTOR    = 241;        /// Constructor.
    enum uint OCI_ATTR_IS_DESTRUCTOR    = 242;        /// Destructor.
    enum uint OCI_ATTR_IS_OPERATOR        = 243;        /// Operator.
    enum uint OCI_ATTR_IS_MAP        = 244;        /// A map method.
    enum uint OCI_ATTR_IS_ORDER        = 245;        /// Order method.
    enum uint OCI_ATTR_IS_RNDS        = 246;        /// Read no data state method.
    enum uint OCI_ATTR_IS_RNPS        = 247;        /// Read no process state.
    enum uint OCI_ATTR_IS_WNDS        = 248;        /// Write no data state method.
    enum uint OCI_ATTR_IS_WNPS        = 249;        /// Write no process state.

    enum uint OCI_ATTR_DESC_PUBLIC        = 250;        /// Public object.

    enum uint OCI_ATTR_CACHE_CLIENT_CONTEXT= 251;        ///
    enum uint OCI_ATTR_UCI_CONSTRUCT    = 252;        ///
    enum uint OCI_ATTR_UCI_DESTRUCT    = 253;        ///
    enum uint OCI_ATTR_UCI_COPY        = 254;        ///
    enum uint OCI_ATTR_UCI_PICKLE        = 255;        ///
    enum uint OCI_ATTR_UCI_UNPICKLE    = 256;        ///
    enum uint OCI_ATTR_UCI_REFRESH        = 257;        ///

    enum uint OCI_ATTR_IS_SUBTYPE        = 258;        ///
    enum uint OCI_ATTR_SUPERTYPE_SCHEMA_NAME = 259;    ///
    enum uint OCI_ATTR_SUPERTYPE_NAME    = 260;        ///

    enum uint OCI_ATTR_LIST_OBJECTS    = 261;        /// List of objects in schema.

    enum uint OCI_ATTR_NCHARSET_ID        = 262;        /// Char set id.
    enum uint OCI_ATTR_LIST_SCHEMAS    = 263;        /// List of schemas.
    enum uint OCI_ATTR_MAX_PROC_LEN    = 264;        /// Max procedure length.
    enum uint OCI_ATTR_MAX_COLUMN_LEN    = 265;        /// Max column name length.
    enum uint OCI_ATTR_CURSOR_COMMIT_BEHAVIOR = 266;    /// Cursor commit behavior.
    enum uint OCI_ATTR_MAX_CATALOG_NAMELEN    = 267;        /// Catalog namelength.
    enum uint OCI_ATTR_CATALOG_LOCATION    = 268;        /// Catalog location.
    enum uint OCI_ATTR_SAVEPOINT_SUPPORT    = 269;        /// Savepoint support.
    enum uint OCI_ATTR_NOWAIT_SUPPORT    = 270;        /// Nowait support.
    enum uint OCI_ATTR_AUTOCOMMIT_DDL    = 271;        /// Autocommit DDL.
    enum uint OCI_ATTR_LOCKING_MODE    = 272;        /// Locking mode.

    enum uint OCI_ATTR_APPCTX_SIZE        = 273;        /// Count of context to be init.
    enum uint OCI_ATTR_APPCTX_LIST        = 274;        /// Count of context to be init.
    enum uint OCI_ATTR_APPCTX_NAME        = 275;        /// Name of context to be init.
    enum uint OCI_ATTR_APPCTX_ATTR        = 276;        /// Attr of context to be init.
    enum uint OCI_ATTR_APPCTX_VALUE    = 277;        /// Value of context to be init.

    enum uint OCI_ATTR_CLIENT_IDENTIFIER    = 278;        /// Value of client id to set.

    enum uint OCI_ATTR_IS_FINAL_TYPE    = 279;        /// Is final type?
    enum uint OCI_ATTR_IS_INSTANTIABLE_TYPE= 280;        /// Is instantiable type?
    enum uint OCI_ATTR_IS_FINAL_METHOD    = 281;        /// Is final method?
    enum uint OCI_ATTR_IS_INSTANTIABLE_METHOD = 282;    /// Is instantiable method?
    enum uint OCI_ATTR_IS_OVERRIDING_METHOD= 283;        /// Is overriding method?

    enum uint OCI_ATTR_DESC_SYNBASE    = 284;        /// Describe the base object.

    enum uint OCI_ATTR_CHAR_USED        = 285;        /// Char length semantics.
    enum uint OCI_ATTR_CHAR_SIZE        = 286;        /// Char length.

    enum uint OCI_ATTR_IS_JAVA_TYPE    = 287;        /// Is Java implemented type ?.

    enum uint OCI_ATTR_DISTINGUISHED_NAME    = 300;        /// Use DN as user name.
    enum uint OCI_ATTR_KERBEROS_TICKET    = 301;        /// Kerberos ticket as cred..

    enum uint OCI_ATTR_ORA_DEBUG_JDWP    = 302;        /// ORA_DEBUG_JDWP attribute.

    enum uint OCI_ATTR_RESERVED_14        = 303;        /// Reserved.


    enum uint OCI_ATTR_SPOOL_TIMEOUT    = 308;        /// Session timeout.
    enum uint OCI_ATTR_SPOOL_GETMODE    = 309;        /// Session get mode.
    enum uint OCI_ATTR_SPOOL_BUSY_COUNT    = 310;        /// Busy session count.
    enum uint OCI_ATTR_SPOOL_OPEN_COUNT    = 311;        /// Open session count.
    enum uint OCI_ATTR_SPOOL_MIN        = 312;        /// Min session count.
    enum uint OCI_ATTR_SPOOL_MAX        = 313;        /// Max session count.
    enum uint OCI_ATTR_SPOOL_INCR        = 314;        /// Session increment count.
    enum uint OCI_ATTR_SPOOL_STMTCACHESIZE    = 208;        /// Stmt cache size of pool .

    enum uint OCI_ATTR_IS_XMLTYPE        = 315;        /// Is the type an XML type?.
    enum uint OCI_ATTR_XMLSCHEMA_NAME    = 316;        /// Name of XML Schema.
    enum uint OCI_ATTR_XMLELEMENT_NAME    = 317;        /// Name of XML Element.
    enum uint OCI_ATTR_XMLSQLTYPSCH_NAME    = 318;        /// SQL type's schema for XML Ele.
    enum uint OCI_ATTR_XMLSQLTYPE_NAME    = 319;        /// Name of SQL type for XML Ele.
    enum uint OCI_ATTR_XMLTYPE_STORED_OBJ    = 320;        /// XML type stored as object?.

    enum uint OCI_ATTR_HAS_SUBTYPES    = 321;        /// Has subtypes?.
    enum uint OCI_ATTR_NUM_SUBTYPES    = 322;        /// Number of subtypes.
    enum uint OCI_ATTR_LIST_SUBTYPES    = 323;        /// List of subtypes.

    enum uint OCI_ATTR_XML_HRCHY_ENABLED    = 324;        /// Hierarchy enabled?.

    enum uint OCI_ATTR_IS_OVERRIDDEN_METHOD= 325;        /// Method is overridden?.

    enum uint OCI_ATTR_OBJ_SUBS        = 336;        /// Obj col/tab substitutable.

    enum uint OCI_ATTR_XADFIELD_RESERVED_1    = 339;        /// Reserved.
    enum uint OCI_ATTR_XADFIELD_RESERVED_2    = 340;        /// Reserved.

    enum uint OCI_ATTR_KERBEROS_CID    = 341;        /// Kerberos db service ticket.

    enum uint OCI_ATTR_CONDITION        = 342;        /// Rule condition.
    enum uint OCI_ATTR_COMMENT        = 343;        /// Comment.
    enum uint OCI_ATTR_VALUE        = 344;        /// Anydata value.
    enum uint OCI_ATTR_EVAL_CONTEXT_OWNER    = 345;        /// Eval context owner.
    enum uint OCI_ATTR_EVAL_CONTEXT_NAME    = 346;        /// Eval context name.
    enum uint OCI_ATTR_EVALUATION_FUNCTION    = 347;        /// Eval function name.
    enum uint OCI_ATTR_VAR_TYPE        = 348;        /// Variable type.
    enum uint OCI_ATTR_VAR_VALUE_FUNCTION    = 349;        /// Variable value function.
    enum uint OCI_ATTR_VAR_METHOD_FUNCTION    = 350;        /// Variable method function.
    enum uint OCI_ATTR_ACTION_CONTEXT    = 351;        /// Action context.
    enum uint OCI_ATTR_LIST_TABLE_ALIASES    = 352;        /// List of table aliases.
    enum uint OCI_ATTR_LIST_VARIABLE_TYPES    = 353;        /// List of variable types.
    enum uint OCI_ATTR_TABLE_NAME        = 356;        /// Table name.

    enum uint OCI_ATTR_MESSAGE_CSCN    = 360;        /// Message cscn.
    enum uint OCI_ATTR_MESSAGE_DSCN    = 361;        /// Message dscn.

    enum uint OCI_ATTR_AUDIT_SESSION_ID    = 362;        /// Audit session ID.

    enum uint OCI_ATTR_KERBEROS_KEY    = 363;        /// N-tier Kerberos cred key.
    enum uint OCI_ATTR_KERBEROS_CID_KEY    = 364;        /// SCID Kerberos cred key.


    enum uint OCI_ATTR_TRANSACTION_NO    = 365;        /// AQ enq txn number.

    enum uint OCI_ATTR_MODULE        = 366;        /// Module for tracing.
    enum uint OCI_ATTR_ACTION        = 367;        /// Action for tracing.
    enum uint OCI_ATTR_CLIENT_INFO        = 368;        /// Client info.
    enum uint OCI_ATTR_COLLECT_CALL_TIME    = 369;        /// Collect call time.
    enum uint OCI_ATTR_CALL_TIME        = 370;        /// Extract call time.
    enum uint OCI_ATTR_ECONTEXT_ID        = 371;        /// Execution-id context.
    enum uint OCI_ATTR_ECONTEXT_SEQ    = 372;        /// Execution-id sequence num.

    enum uint OCI_ATTR_SESSION_STATE    = 373;        /// Session state.
    enum uint OCI_SESSION_STATELESS    = 1;        /// Valid states.
    enum uint OCI_SESSION_STATEFUL        = 2;        ///

    enum uint OCI_ATTR_SESSION_STATETYPE    = 374;        /// Session state type.
    enum uint OCI_SESSION_STATELESS_DEF    = 0;        /// Valid state types.
    enum uint OCI_SESSION_STATELESS_CAL    = 1;        ///
    enum uint OCI_SESSION_STATELESS_TXN    = 2;        ///
    enum uint OCI_SESSION_STATELESS_APP    = 3;        ///

    enum uint OCI_ATTR_SESSION_STATE_CLEARED = 376;    /// Session state cleared.
    enum uint OCI_ATTR_SESSION_MIGRATED    = 377;        /// Did session migrate.
    enum uint OCI_ATTR_SESSION_PRESERVE_STATE = 388;    /// Preserve session state.

    enum uint OCI_ATTR_ADMIN_PFILE        = 389;        /// Client-side param file.

    enum uint OCI_ATTR_HOSTNAME        = 390;        /// SYS_CONTEXT hostname.
    enum uint OCI_ATTR_DBNAME        = 391;        /// SYS_CONTEXT dbname.
    enum uint OCI_ATTR_INSTNAME        = 392;        /// SYS_CONTEXT instance name.
    enum uint OCI_ATTR_SERVICENAME        = 393;        /// SYS_CONTEXT service name.
    enum uint OCI_ATTR_INSTSTARTTIME    = 394;        /// Instance start time.
    enum uint OCI_ATTR_HA_TIMESTAMP    = 395;        /// Event time.
    enum uint OCI_ATTR_RESERVED_22        = 396;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_23        = 397;        /// Reserved.
    enum uint OCI_ATTR_RESERVED_24        = 398;        /// Reserved.
    enum uint OCI_ATTR_DBDOMAIN        = 399;        /// Db domain.

    enum uint OCI_ATTR_EVENTTYPE        = 400;        /// Event type.
    enum uint OCI_EVENTTYPE_HA        = 0;        /// Valid value for OCI_ATTR_EVENTTYPE.

    enum uint OCI_ATTR_HA_SOURCE        = 401;        ///

    enum uint OCI_HA_SOURCE_INSTANCE    = 0;        ///
    enum uint OCI_HA_SOURCE_DATABASE    = 1;        ///
    enum uint OCI_HA_SOURCE_NODE        = 2;        ///
    enum uint OCI_HA_SOURCE_SERVICE    = 3;        ///
    enum uint OCI_HA_SOURCE_SERVICE_MEMBER    = 4;        ///
    enum uint OCI_HA_SOURCE_ASM_INSTANCE    = 5;        ///
    enum uint OCI_HA_SOURCE_SERVICE_PRECONNECT = 6;    ///

    enum uint OCI_ATTR_HA_STATUS        = 402;        ///
    enum uint OCI_HA_STATUS_DOWN        = 0;        /// Valid values for OCI_ATTR_HA_STATUS.
    enum uint OCI_HA_STATUS_UP        = 1;        ///

    enum uint OCI_ATTR_HA_SRVFIRST        = 403;        ///

    enum uint OCI_ATTR_HA_SRVNEXT        = 404;        ///

    enum uint OCI_ATTR_TAF_ENABLED        = 405;        ///

    enum uint OCI_ATTR_NFY_FLAGS        = 406;        ///

    enum uint OCI_ATTR_MSG_DELIVERY_MODE    = 407;        /// Msg delivery mode.
    enum uint OCI_ATTR_DB_CHARSET_ID    = 416;        /// Database charset ID.
    enum uint OCI_ATTR_DB_NCHARSET_ID    = 417;        /// Database ncharset ID.
    enum uint OCI_ATTR_RESERVED_25        = 418;        /// Reserved.

    enum uint OCI_DIRPATH_STREAM_VERSION_1    = 100;        ///
    enum uint OCI_DIRPATH_STREAM_VERSION_2    = 200;        ///
    enum uint OCI_DIRPATH_STREAM_VERSION_3    = 300;        /// Default.

    enum uint OCI_ATTR_DIRPATH_MODE    = 78;        /// Mode of direct path operation.
    enum uint OCI_ATTR_DIRPATH_NOLOG    = 79;        /// Nologging option.
    enum uint OCI_ATTR_DIRPATH_PARALLEL    = 80;        /// Parallel (temp seg) option.

    enum uint OCI_ATTR_DIRPATH_SORTED_INDEX= 137;        /// Index that data is sorted on.

    enum uint OCI_ATTR_DIRPATH_INDEX_MAINT_METHOD = 138;    ///

    enum uint OCI_ATTR_DIRPATH_FILE    = 139;        /// DB file to load into.
    enum uint OCI_ATTR_DIRPATH_STORAGE_INITIAL = 140;    /// Initial extent size.
    enum uint OCI_ATTR_DIRPATH_STORAGE_NEXT= 141;        /// Next extent size.
    enum uint OCI_ATTR_DIRPATH_SKIPINDEX_METHOD = 145;    /// Direct path index maint method (see oci8dp.h).

    enum uint OCI_ATTR_DIRPATH_EXPR_TYPE    = 150;        /// Expr type of OCI_ATTR_NAME.

    enum uint OCI_ATTR_DIRPATH_INPUT    = 151;        /// Input in text or stream format.
    enum uint OCI_DIRPATH_INPUT_TEXT    = 0x01;        ///
    enum uint OCI_DIRPATH_INPUT_STREAM    = 0x02;        ///
    enum uint OCI_DIRPATH_INPUT_UNKNOWN    = 0x04;        ///

    enum uint OCI_ATTR_DIRPATH_FN_CTX    = 167;        /// Fn ctx ADT attrs or args.

    enum uint OCI_ATTR_DIRPATH_OID        = 187;        /// Loading into an OID col.
    enum uint OCI_ATTR_DIRPATH_SID        = 194;        /// Loading into an SID col.
    enum uint OCI_ATTR_DIRPATH_OBJ_CONSTR    = 206;        /// Obj type of subst obj tbl.

    enum uint OCI_ATTR_DIRPATH_STREAM_VERSION = 212;    /// Version of the stream.

    enum uint OCIP_ATTR_DIRPATH_VARRAY_INDEX = 213;    /// Varray index column.

    enum uint OCI_ATTR_DIRPATH_DCACHE_NUM    = 303;        /// Date cache entries.
    enum uint OCI_ATTR_DIRPATH_DCACHE_SIZE    = 304;        /// Date cache limit.
    enum uint OCI_ATTR_DIRPATH_DCACHE_MISSES = 305;    /// Date cache misses.
    enum uint OCI_ATTR_DIRPATH_DCACHE_HITS    = 306;        /// Date cache hits.
    enum uint OCI_ATTR_DIRPATH_DCACHE_DISABLE = 307;    /// Disable datecache.

    enum uint OCI_ATTR_DIRPATH_RESERVED_7    = 326;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_RESERVED_8    = 327;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_CONVERT    = 328;        /// Stream conversion needed?.
    enum uint OCI_ATTR_DIRPATH_BADROW    = 329;        /// Info about bad row.
    enum uint OCI_ATTR_DIRPATH_BADROW_LENGTH = 330;    /// Length of bad row info.
    enum uint OCI_ATTR_DIRPATH_WRITE_ORDER    = 331;        /// Column fill order.
    enum uint OCI_ATTR_DIRPATH_GRANULE_SIZE= 332;        /// Granule size for unload.
    enum uint OCI_ATTR_DIRPATH_GRANULE_OFFSET = 333;    /// Offset to last granule.
    enum uint OCI_ATTR_DIRPATH_RESERVED_1    = 334;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_RESERVED_2    = 335;        /// Reserved.

    enum uint OCI_ATTR_DIRPATH_RESERVED_3    = 337;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_RESERVED_4    = 338;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_RESERVED_5    = 357;        /// Reserved.
    enum uint OCI_ATTR_DIRPATH_RESERVED_6    = 358;        /// Reserved.

    enum uint OCI_ATTR_DIRPATH_LOCK_WAIT    = 359;        /// Wait for lock in dpapi.

    enum uint OCI_ATTR_DIRPATH_RESERVED_9    = 2000;        /// Reserved.

    enum uint OCI_ATTR_DIRPATH_RESERVED_10    = 2001;        /// Vector of functions.
    enum uint OCI_ATTR_DIRPATH_RESERVED_11    = 2002;        /// Encryption metadata.

    enum uint OCI_ATTR_CURRENT_ERRCOL    = 2003;        /// Current error column.

    enum uint OCI_CURSOR_OPEN        = 0;        ///
    enum uint OCI_CURSOR_CLOSED        = 1;        ///

    enum uint OCI_CL_START            = 0;        ///
    enum uint OCI_CL_END            = 1;        ///

    enum uint OCI_SP_SUPPORTED        = 0;        ///
    enum uint OCI_SP_UNSUPPORTED        = 1;        ///

    enum uint OCI_NW_SUPPORTED        = 0;        ///
    enum uint OCI_NW_UNSUPPORTED        = 1;        ///

    enum uint OCI_AC_DDL            = 0;        ///
    enum uint OCI_NO_AC_DDL        = 1;        ///

    enum uint OCI_LOCK_IMMEDIATE        = 0;        ///
    enum uint OCI_LOCK_DELAYED        = 1;        ///

    enum uint OCI_INSTANCE_TYPE_UNKNOWN    = 0;        ///
    enum uint OCI_INSTANCE_TYPE_RDBMS    = 1;        ///
    enum uint OCI_INSTANCE_TYPE_OSM    = 2;        ///

    enum uint OCI_AUTH            = 0x08;        /// Change the password but do not login.

    enum uint OCI_MAX_FNS            = 100;        /// Max number of OCI Functions.
    enum uint OCI_SQLSTATE_SIZE        = 5;        ///
    enum uint OCI_ERROR_MAXMSG_SIZE    = 1024;        /// Max size of an error message.
    enum uint OCI_LOBMAXSIZE        = 4294967295;    /// Maximum lob data size.
    enum uint OCI_ROWID_LEN        = 23;        ///

    enum uint OCI_FO_END            = 0x00000001;    ///
    enum uint OCI_FO_ABORT            = 0x00000002;    ///
    enum uint OCI_FO_REAUTH        = 0x00000004;    ///
    enum uint OCI_FO_BEGIN            = 0x00000008;    ///
    enum uint OCI_FO_ERROR            = 0x00000010;    ///

    enum uint OCI_FO_RETRY            = 25410;    ///

    enum uint OCI_FO_NONE            = 0x00000001;    ///
    enum uint OCI_FO_SESSION        = 0x00000002;    ///
    enum uint OCI_FO_SELECT        = 0x00000004;    ///
    enum uint OCI_FO_TXNAL            = 0x00000008;    ///

    enum uint OCI_FNCODE_INITIALIZE    = 1;        /// OCIInitialize.
    enum uint OCI_FNCODE_HANDLEALLOC    = 2;        /// OCIHandleAlloc.
    enum uint OCI_FNCODE_HANDLEFREE    = 3;        /// OCIHandleFree.
    enum uint OCI_FNCODE_DESCRIPTORALLOC    = 4;        /// OCIDescriptorAlloc.
    enum uint OCI_FNCODE_DESCRIPTORFREE    = 5;        /// OCIDescriptorFree.
    enum uint OCI_FNCODE_ENVINIT        = 6;        /// OCIEnvInit.
    enum uint OCI_FNCODE_SERVERATTACH    = 7;        /// OCIServerAttach.
    enum uint OCI_FNCODE_SERVERDETACH    = 8;        /// OCIServerDetach.
    enum uint OCI_FNCODE_SESSIONBEGIN    = 10;        /// OCISessionBegin.
    enum uint OCI_FNCODE_SESSIONEND    = 11;        /// OCISessionEnd.
    enum uint OCI_FNCODE_PASSWORDCHANGE    = 12;        /// OCIPasswordChange.
    enum uint OCI_FNCODE_STMTPREPARE    = 13;        /// OCIStmtPrepare.
    enum uint OCI_FNCODE_BINDDYNAMIC    = 17;        /// OCIBindDynamic.
    enum uint OCI_FNCODE_BINDOBJECT    = 18;        /// OCIBindObject.
    enum uint OCI_FNCODE_BINDARRAYOFSTRUCT    = 20;        /// OCIBindArrayOfStruct.
    enum uint OCI_FNCODE_STMTEXECUTE    = 21;        /// OCIStmtExecute.
    enum uint OCI_FNCODE_DEFINEOBJECT    = 25;        /// OCIDefineObject.
    enum uint OCI_FNCODE_DEFINEDYNAMIC    = 26;        /// OCIDefineDynamic.
    enum uint OCI_FNCODE_DEFINEARRAYOFSTRUCT = 27;        /// OCIDefineArrayOfStruct.
    enum uint OCI_FNCODE_STMTFETCH        = 28;        /// OCIStmtFetch.
    enum uint OCI_FNCODE_STMTGETBIND    = 29;        /// OCIStmtGetBindInfo.
    enum uint OCI_FNCODE_DESCRIBEANY    = 32;        /// OCIDescribeAny.
    enum uint OCI_FNCODE_TRANSSTART    = 33;        /// OCITransStart.
    enum uint OCI_FNCODE_TRANSDETACH    = 34;        /// OCITransDetach.
    enum uint OCI_FNCODE_TRANSCOMMIT    = 35;        /// OCITransCommit.
    enum uint OCI_FNCODE_ERRORGET        = 37;        /// OCIErrorGet.
    enum uint OCI_FNCODE_LOBOPENFILE    = 38;        /// OCILobFileOpen.
    enum uint OCI_FNCODE_LOBCLOSEFILE    = 39;        /// OCILobFileClose.
    enum uint OCI_FNCODE_LOBCOPY        = 42;        /// OCILobCopy.
    enum uint OCI_FNCODE_LOBAPPEND        = 43;        /// OCILobAppend.
    enum uint OCI_FNCODE_LOBERASE        = 44;        /// OCILobErase.
    enum uint OCI_FNCODE_LOBLENGTH        = 45;        /// OCILobGetLength.
    enum uint OCI_FNCODE_LOBTRIM        = 46;        /// OCILobTrim.
    enum uint OCI_FNCODE_LOBREAD        = 47;        /// OCILobRead.
    enum uint OCI_FNCODE_LOBWRITE        = 48;        /// OCILobWrite.
    enum uint OCI_FNCODE_SVCCTXBREAK    = 50;        /// OCIBreak.
    enum uint OCI_FNCODE_SERVERVERSION    = 51;        /// OCIServerVersion.
    enum uint OCI_FNCODE_KERBATTRSET    = 52;        /// OCIKerbAttrSet.
    enum uint OCI_FNCODE_ATTRGET        = 54;        /// OCIAttrGet.
    enum uint OCI_FNCODE_ATTRSET        = 55;        /// OCIAttrSet.
    enum uint OCI_FNCODE_PARAMSET        = 56;        /// OCIParamSet.
    enum uint OCI_FNCODE_PARAMGET        = 57;        /// OCIParamGet.
    enum uint OCI_FNCODE_STMTGETPIECEINFO    = 58;        /// OCIStmtGetPieceInfo.
    enum uint OCI_FNCODE_LDATOSVCCTX    = 59;        /// OCILdaToSvcCtx.
    enum uint OCI_FNCODE_STMTSETPIECEINFO    = 61;        /// OCIStmtSetPieceInfo.
    enum uint OCI_FNCODE_TRANSFORGET    = 62;        /// OCITransForget.
    enum uint OCI_FNCODE_TRANSPREPARE    = 63;        /// OCITransPrepare.
    enum uint OCI_FNCODE_TRANSROLLBACK    = 64;        /// OCITransRollback.
    enum uint OCI_FNCODE_DEFINEBYPOS    = 65;        /// OCIDefineByPos.
    enum uint OCI_FNCODE_BINDBYPOS        = 66;        /// OCIBindByPos.
    enum uint OCI_FNCODE_BINDBYNAME    = 67;        /// OCIBindByName.
    enum uint OCI_FNCODE_LOBASSIGN        = 68;        /// OCILobAssign.
    enum uint OCI_FNCODE_LOBISEQUAL    = 69;        /// OCILobIsEqual.
    enum uint OCI_FNCODE_LOBISINIT        = 70;        /// OCILobLocatorIsInit.
    enum uint OCI_FNCODE_LOBENABLEBUFFERING= 71;                        /// OCILobEnableBuffering.
    enum uint OCI_FNCODE_LOBCHARSETID    = 72;        /// OCILobCharSetID.
    enum uint OCI_FNCODE_LOBCHARSETFORM    = 73;        /// OCILobCharSetForm.
    enum uint OCI_FNCODE_LOBFILESETNAME    = 74;        /// OCILobFileSetName.
    enum uint OCI_FNCODE_LOBFILEGETNAME    = 75;        /// OCILobFileGetName.
    enum uint OCI_FNCODE_LOGON        = 76;        /// OCILogon.
    enum uint OCI_FNCODE_LOGOFF        = 77;        /// OCILogoff.
    enum uint OCI_FNCODE_LOBDISABLEBUFFERING = 78;        /// OCILobDisableBuffering.
    enum uint OCI_FNCODE_LOBFLUSHBUFFER    = 79;        /// OCILobFlushBuffer.
    enum uint OCI_FNCODE_LOBLOADFROMFILE    = 80;        /// OCILobLoadFromFile.
    enum uint OCI_FNCODE_LOBOPEN        = 81;        /// OCILobOpen.
    enum uint OCI_FNCODE_LOBCLOSE        = 82;        /// OCILobClose.
    enum uint OCI_FNCODE_LOBISOPEN        = 83;        /// OCILobIsOpen.
    enum uint OCI_FNCODE_LOBFILEISOPEN    = 84;        /// OCILobFileIsOpen.
    enum uint OCI_FNCODE_LOBFILEEXISTS    = 85;        /// OCILobFileExists.
    enum uint OCI_FNCODE_LOBFILECLOSEALL    = 86;        /// OCILobFileCloseAll.
    enum uint OCI_FNCODE_LOBCREATETEMP    = 87;        /// OCILobCreateTemporary.
    enum uint OCI_FNCODE_LOBFREETEMP    = 88;        /// OCILobFreeTemporary.
    enum uint OCI_FNCODE_LOBISTEMP        = 89;        /// OCILobIsTemporary.
    enum uint OCI_FNCODE_AQENQ        = 90;        /// OCIAQEnq.
    enum uint OCI_FNCODE_AQDEQ        = 91;        /// OCIAQDeq.
    enum uint OCI_FNCODE_RESET        = 92;        /// OCIReset.
    enum uint OCI_FNCODE_SVCCTXTOLDA    = 93;        /// OCISvcCtxToLda.
    enum uint OCI_FNCODE_LOBLOCATORASSIGN    = 94;        /// OCILobLocatorAssign.
    enum uint OCI_FNCODE_UBINDBYNAME    = 95;        ///
    enum uint OCI_FNCODE_AQLISTEN        = 96;        /// OCIAQListen.
    enum uint OCI_FNCODE_SVC2HST        = 97;        /// Reserved.
    enum uint OCI_FNCODE_SVCRH        = 98;        /// Reserved.
    enum uint OCI_FNCODE_TRANSMULTIPREPARE    = 99;        /// OCITransMultiPrepare.
    enum uint OCI_FNCODE_CPOOLCREATE    = 100;        /// OCIConnectionPoolCreate.
    enum uint OCI_FNCODE_CPOOLDESTROY    = 101;        /// OCIConnectionPoolDestroy.
    enum uint OCI_FNCODE_LOGON2        = 102;        /// OCILogon2.
    enum uint OCI_FNCODE_ROWIDTOCHAR    = 103;        /// OCIRowidToChar.

    enum uint OCI_FNCODE_SPOOLCREATE    = 104;        /// OCISessionPoolCreate.
    enum uint OCI_FNCODE_SPOOLDESTROY    = 105;        /// OCISessionPoolDestroy.
    enum uint OCI_FNCODE_SESSIONGET    = 106;        /// OCISessionGet.
    enum uint OCI_FNCODE_SESSIONRELEASE    = 107;        /// OCISessionRelease.
    enum uint OCI_FNCODE_STMTPREPARE2    = 108;        /// OCIStmtPrepare2.
    enum uint OCI_FNCODE_STMTRELEASE    = 109;        /// OCIStmtRelease.
    enum uint OCI_FNCODE_AQENQARRAY    = 110;        /// OCIAQEnqArray.
    enum uint OCI_FNCODE_AQDEQARRAY    = 111;        /// OCIAQDeqArray.
    enum uint OCI_FNCODE_LOBCOPY2        = 112;        /// OCILobCopy2.
    enum uint OCI_FNCODE_LOBERASE2        = 113;        /// OCILobErase2.
    enum uint OCI_FNCODE_LOBLENGTH2    = 114;        /// OCILobGetLength2.
    enum uint OCI_FNCODE_LOBLOADFROMFILE2    = 115;        /// OCILobLoadFromFile2.
    enum uint OCI_FNCODE_LOBREAD2        = 116;        /// OCILobRead2.
    enum uint OCI_FNCODE_LOBTRIM2        = 117;        /// OCILobTrim2.
    enum uint OCI_FNCODE_LOBWRITE2        = 118;        /// OCILobWrite2.
    enum uint OCI_FNCODE_LOBGETSTORAGELIMIT= 119;        /// OCILobGetStorageLimit.
    enum uint OCI_FNCODE_DBSTARTUP        = 120;        /// OCIDBStartup.
    enum uint OCI_FNCODE_DBSHUTDOWN    = 121;        /// OCIDBShutdown.
    enum uint OCI_FNCODE_LOBARRAYREAD    = 122;        /// OCILobArrayRead.
    enum uint OCI_FNCODE_LOBARRAYWRITE    = 123;        /// OCILobArrayWrite.
    enum uint OCI_FNCODE_MAXFCN        = 123;        /// Maximum OCI function code.



    /**
    * Errors - when an error is added here, a message corresponding to the
    * error number must be added to the message file.
    * New errors must be assigned numbers, otherwise the compiler can assign any
    * value that it wants, which may lead to invalid error numbers being generated.
    * The number range currently assigned to the OSS is 28750 - 29249
    * New number range 43000 - 43499
    */
    enum nzerror {
        NZERROR_OK            = 0,        ///
        NZERROR_GENERIC            = 28750,    /// A catchall for errors.
        NZERROR_NO_MEMORY        = 28751,    /// No more memory.
        NZERROR_DATA_SOURCE_INIT_FAILED    = 28752,    /// Failed to init data source.
        NZERROR_DATA_SOURCE_TERM_FAILED    = 28753,    /// Failed to terminate data source.
        NZERROR_OBJECT_STORE_FAILED    = 28754,    /// Store object in data source failed.
        NZERROR_OBJECT_GET_FAILED    = 28755,    /// Failed to obtain object from data source.
        NZERROR_MEMORY_ALLOC_FAILED    = 28756,    /// Callback failed to allocate memory.
        NZERROR_MEMORY_ALLOC_0_BYTES    = 28757,    /// Attempted to ask for 0 bytes of memory.
        NZERROR_MEMORY_FREE_FAILED    = 28758,    /// Callback failed to free memory.
        NZERROR_FILE_OPEN_FAILED    = 28759,    /// Open of file failed.
        NZERROR_LIST_CREATION_FAILED    = 28760,    /// Creation of list failed.
        NZERROR_NO_ELEMENT        = 28761,    /// No list element found.
        NZERROR_ELEMENT_ADD_FAILED    = 28762,    /// Addition of list element failed.
        NZERROR_PARAMETER_BAD_TYPE    = 28763,    /// Retrieval of an unknown parameter type.
        NZERROR_PARAMETER_RETRIEVAL    = 28764,    /// Retrieval of parameter failed.
        NZERROR_NO_LIST            = 28765,    /// Data method list does not exist.
        NZERROR_TERMINATE_FAIL        = 28766,    /// Failed to terminate.
        NZERROR_BAD_VERSION_NUMBER    = 28767,    /// Bad version number.
        NZERROR_BAD_MAGIC_NUMBER    = 28768,    /// Bad magic number.
        NZERROR_METHOD_NOT_FOUND    = 28769,    /// Data retrieval method specified does not exist.
        NZERROR_ALREADY_INITIALIZED    = 28770,    /// The data source is already initialized.
        NZERROR_NOT_INITIALIZED        = 28771,    /// The data source is not initialized.
        NZERROR_BAD_FILE_ID        = 28772,    /// File ID is bad.
        NZERROR_WRITE_MAGIC_VERSION    = 28773,    /// Failed to write magic and version.
        NZERROR_FILE_WRITE_FAILED    = 28774,    /// Failed to write to file.
        NZERROR_FILE_CLOSE_FAILED    = 28775,    /// Failed to close file.
        NZERROR_OUTPUT_BUFFER_TOO_SMALL    = 28776,    /// The buffer supplied by the caller is too small.
        NZERROR_BINDING_CREATION_FAILED    = 28777,    /// NL failed in creating a binding.
        NZERROR_PARAMETER_MALFORMED    = 28778,    /// A parameter was in a bad format.
        NZERROR_PARAMETER_NO_METHOD    = 28779,    /// No method was specified for a data type.
        NZERROR_BAD_PARAMETER_METHOD    = 28780,    /// Illegal method for data type.
        NZERROR_PARAMETER_NO_DATA    = 28781,    /// No method specified when required.
        NZERROR_NOT_ALLOCATED        = 28782,    /// Data source is not allocated.
        NZERROR_INVALID_PARAMETER    = 28783,    /// Invalid parameter name.
        NZERROR_FILE_NAME_TRANSLATION    = 28784,    /// Could not translate OSD file name.
        NZERROR_NO_SUCH_PARAMETER    = 28785,    /// Selected parameter is non-existent.
        NZERROR_DECRYPT_FAILED        = 28786,    /// Encrypted private key decryption failure.
        NZERROR_ENCRYPT_FAILED        = 28787,    /// Private key encryption failed.
        NZERROR_INVALID_INPUT        = 28788,    /// Incorrect input or unknown error.
        NZERROR_NAME_TYPE_NOT_FOUND    = 28789,    /// Type of name requested is not available.
        NZERROR_NLS_STRING_OPEN_FAILED    = 28790,    /// Failure to generate an NLS string.
        NZERROR_CERTIFICATE_VERIFY    = 28791,    /// Failed to verify a certificate.
        NZERROR_OCI_PLSQL_FAILED    = 28792,    /// An OCI call to process some plsql failed.
        NZERROR_OCI_BIND_FAILED        = 28793,    /// An OCI call to bind an internal var. failed.
        NZERROR_ATTRIBUTE_INIT        = 28794,    /// Failed to init role retrieval.
        NZERROR_ATTRIBUTE_FINISH_FAILED    = 28795,    /// Did not complete role retrieval.
        NZERROR_UNSUPPORTED_METHOD    = 28796,    /// Data method specified not supported.
        NZERROR_INVALID_KEY_DATA_TYPE    = 28797,    /// Invalid data type specified for key.
        NZEROR_BIND_SUBKEY_COUNT    = 28798,    /// Number of sub-keys to bind does not match count in initialized key.
        NZERROR_AUTH_SHARED_MEMORY    = 28799,    /// Failed to retreieve authentication information from the shared memory.
        NZERROR_RIO_OPEN        = 28800,    /// RIO Open Failed.
        NZERROR_RIO_OBJECT_TYPE        = 28801,    /// RIO object type invalid.
        NZERROR_RIO_MODE        = 28802,    /// RIO mode invalid.
        NZERROR_RIO_IO            = 28803,    /// RIO io set or number invalid.
        NZERROR_RIO_CLOSE        = 28804,    /// RIO close failed.
        NZERROR_RIO_RETRIEVE        = 28805,    /// RIO retrieve failed.
        NZERROR_RIO_STORE        = 28806,    /// RIO store failed.
        NZERROR_RIO_UPDATE        = 28807,    /// RIO update failed.
        NZERROR_RIO_INFO        = 28808,    /// RIO info failed.
        NZERROR_RIO_DELETE        = 28809,    /// RIO delete failed.
        NZERROR_KD_CREATE        = 28810,    /// Key descriptor create failed.
        NZERROR_RIO_ACCESS_DESCRIPTOR    = 28811,    /// Access descriptor invalid.
        NZERROR_RIO_RECORD        = 28812,    /// Record invalid.
        NZERROR_RIO_RECORD_TYPE        = 28813,    /// Record type and AD type not matched.
        NZERROR_PLSQL_ORACLE_TO_REAL    = 28814,    /// A number passed to PL/SQL could not be converted to real format.
        NZERROR_PLSQL_REAL_TO_ORACLE    = 28815,    /// A number in machine format could not be converted to Oracle format.
        NZERROR_TK_PLSQL_NO_PASSWORD    = 28816,    /// A password was not provided to a PL/SQL function.
        NZERROR_TK_PLSQL_GENERIC    = 28817,    /// A PL/SQL function returned an error.
        NZERROR_TK_PLSQL_NO_CONTEXT    = 28818,    /// The package context was not specified to a PL/SQL function.
        NZERROR_TK_PLSQL_NO_DIST_NAME    = 28819,    /// The user's distinguished name was not provided to a PL/SQL function.
        NZERROR_TK_PLSQL_NO_STATE    = 28820,    /// The state of either a signature or decryption/encryption was not provided.
        NZERROR_TK_PLSQL_NO_INPUT    = 28821,    /// An input buffer was specified to a PL/SQL function.
        NZERROR_TK_PLSQL_NO_SEED    = 28822,    /// No seed was specified to the PL/SQL seed initialization function.
        NZERROR_TK_PLSQL_NO_BYTES    = 28823,    /// Number of bytes was not specified to the PL/SQL random number generator.
        NZERROR_TK_INVALID_STATE    = 28824,    /// Invalid encryption/decryption/signature state passed.
        NZERROR_TK_PLSQL_NO_ENG_FUNC    = 28825,    /// No crypto engine function was passed in.
        NZERROR_TK_INV_ENG_FUNC        = 28826,    /// An invalid crypto engine function was passed in.
        NZERROR_TK_INV_CIPHR_TYPE    = 28827,    /// An invalid cipher type was passed in.
        NZERROR_TK_INV_IDENT_TYPE    = 28828,    /// An invalid identity type was specified.
        NZERROR_TK_PLSQL_NO_CIPHER_TYPE    = 28829,    /// No cipher type was specified.
        NZERROR_TK_PLSQL_NO_IDENT_TYPE    = 28830,    /// No identity type was specified.
        NZERROR_TK_PLSQL_NO_DATA_FMT    = 28831,    /// No data unit format was specified.
        NZERROR_TK_INV_DATA_FMT        = 28832,    /// Invalid data unit format was provided to function.
        NZERROR_TK_PLSQL_INSUFF_INFO    = 28833,    /// Not enough info (usually parameters) provided to a PL/SQL function.
        NZERROR_TK_PLSQL_BUF_TOO_SMALL    = 28834,    /// Buffer provided by PL/SQL is too small for data to be returned.
        NZERROR_TK_PLSQL_INV_IDENT_DESC    = 28835,    /// Identity descriptor not present or too small.
        NZERROR_TK_PLSQL_WALLET_NOTOPEN    = 28836,    /// Wallet has not been opened yet.
        NZERROR_TK_PLSQL_NO_WALLET    = 28837,    /// No wallet descriptor specified to PL/SQL function.
        NZERROR_TK_PLSQL_NO_IDENTITY    = 28838,    /// No identity descriptor specified to PL/SQL function.
        NZERROR_TK_PLSQL_NO_PERSONA    = 28839,    /// No persona descriptor was specified to PL/SQL function.
        NZERROR_TK_PLSQL_WALLET_OPEN    = 28840,    /// Wallet was already opened.
        NZERROR_UNSUPPORTED        = 28841,    /// Operation is not supported.
        NZERROR_FILE_BAD_PERMISSION    = 28842,    /// Bad file permission specified.
        NZERROR_FILE_OSD_ERROR        = 28843,    /// OSD error when opening file.
        NZERROR_NO_WALLET        = 28844,    /// Cert + privkey + tp files do not exist.
        NZERROR_NO_CERTIFICATE_ALERT    = 28845,    /// No certificate.
        NZERROR_NO_PRIVATE_KEY        = 28846,    /// No private-key.
        NZERROR_NO_CLEAR_PRIVATE_KEY_FILE = 28847,    /// No clear key-file.
        NZERROR_NO_ENCRYPTED_PRIVATE_KEY_FILE = 28848,    /// No encrypted priv key.
        NZERROR_NO_TRUSTPOINTS        = 28849,    /// No trustpoints.
        NZERROR_NO_CLEAR_TRUSTPOINT_FILE= 28850,    /// No clear trustpoints.
        NZERROR_NO_ENCRYPTED_TRUSTPOINT_FILE = 28851,    /// No encrypted trustpoints.
        NZERROR_BAD_PASSWORD        = 28852,    /// Bad password.
        NZERROR_INITIALIZATION_FAILED    = 28853,    /// Init failed or module loading failed.
        NZERROR_SSLMemoryErr        = 28854,    ///
        NZERROR_SSLUnsupportedErr    = 28855,    ///
        NZERROR_SSLOverflowErr        = 28856,    ///
        NZERROR_SSLUnknownErr        = 28857,    ///
        NZERROR_SSLProtocolErr        = 28858,    ///
        NZERROR_SSLNegotiationErr    = 28859,    ///
        NZERROR_SSLFatalAlert        = 28860,    ///
        NZERROR_SSLWouldBlockErr    = 28861,    ///
        NZERROR_SSLIOErr        = 28862,    ///
        NZERROR_SSLSessionNotFoundErr    = 28863,    ///
        NZERROR_SSLConnectionClosedGraceful = 28864,    ///
        NZERROR_SSLConnectionClosedError= 28865,    ///
        NZERROR_ASNBadEncodingErr    = 28866,    ///
        NZERROR_ASNIntegerTooBigErr    = 28867,    ///
        NZERROR_X509CertChainInvalidErr    = 28868,    ///
        NZERROR_X509CertExpiredErr    = 28869,    ///
        NZERROR_X509NamesNotEqualErr    = 28870,    ///
        NZERROR_X509CertChainIncompleteErr = 28871,    ///
        NZERROR_X509DataNotFoundErr    = 28872,    ///
        NZERROR_SSLBadParameterErr    = 28873,    ///
        NZERROR_SSLIOClosedOverrideGoodbyeKiss = 28874,    ///
        NZERROR_X509MozillaSGCErr    =    28875,    ///
        NZERROR_X509IESGCErr        =    28876,    ///
        NZERROR_ImproperServerCredentials = 28877,    ///
        NZERROR_ImproperClientCredentials = 28878,    ///
        NZERROR_NoProtocolSideSet    = 28879,    ///
        NZERROR_setPersonaFailed    = 28880,    ///
        NZERROR_setCertFailed        = 28881,    ///
        NZERROR_setVKeyFailed        = 28882,    ///
        NZERROR_setTPFailed        = 28883,    ///
        NZERROR_BadCipherSuite        = 28884,    ///
        NZERROR_NoKeyPairForKeyUsage    = 28885,    ///
        NZERROR_EntrustLoginFailed    = 28890,    ///
        NZERROR_EntrustGetInfoFailed    = 28891,    ///
        NZERROR_EntrustLoadCertificateFailed = 28892,    ///
        NZERROR_EntrustGetNameFailed    = 28893,    ///
        NZERROR_CertNotInstalled    = 29000,    ///
        NZERROR_ServerDNMisMatched    = 29002,    ///
        NZERROR_ServerDNMisConfigured    = 29003,    ///
        NZERROR_CIC_ERR_SSL_ALERT_CB_FAILURE = 29004,    ///
        NZERROR_CIC_ERR_SSL_BAD_CERTIFICATE = 29005,    ///
        NZERROR_CIC_ERR_SSL_BAD_CERTIFICATE_REQUEST = 29006, ///
        NZERROR_CIC_ERR_SSL_BAD_CLEAR_KEY_LEN = 29007,    ///
        NZERROR_CIC_ERR_SSL_BAD_DHPARAM_KEY_LENGTH = 29008, ///
        NZERROR_CIC_ERR_SSL_BAD_ENCRYPTED_KEY_LEN = 29009, ///
        NZERROR_CIC_ERR_SSL_BAD_EXPORT_KEY_LENGTH = 29010, ///
        NZERROR_CIC_ERR_SSL_BAD_FINISHED_MESSAGE = 29011, ///
        NZERROR_CIC_ERR_SSL_BAD_KEY_ARG_LEN = 29012,    ///
        NZERROR_CIC_ERR_SSL_BAD_MAC    = 29013,    ///
        NZERROR_CIC_ERR_SSL_BAD_MAX_FRAGMENT_LENGTH_EXTENSION = 29014, ///
        NZERROR_CIC_ERR_SSL_BAD_MESSAGE_LENGTH = 29015,    ///
        NZERROR_CIC_ERR_SSL_BAD_PKCS1_PADDING = 29016,    ///
        NZERROR_CIC_ERR_SSL_BAD_PREMASTER_SECRET_LENGTH = 29017, ///
        NZERROR_CIC_ERR_SSL_BAD_PREMASTER_SECRET_VERSION = 29018, ///
        NZERROR_CIC_ERR_SSL_BAD_PROTOCOL_VERSION = 29019, ///
        NZERROR_CIC_ERR_SSL_BAD_RECORD_LENGTH = 29020,    ///
        NZERROR_CIC_ERR_SSL_BAD_SECRET_KEY_LEN = 29021,    ///
        NZERROR_CIC_ERR_SSL_BAD_SIDE    = 29022,    ///
        NZERROR_CIC_ERR_SSL_BUFFERS_NOT_EMPTY = 29023,    ///
        NZERROR_CIC_ERR_SSL_CERTIFICATE_VALIDATE_FAILED = 29024, ///
        NZERROR_CIC_ERR_SSL_CERT_CHECK_CALLBACK = 29025,///
        NZERROR_CIC_ERR_SSL_DECRYPT_FAILED = 29026,    ///
        NZERROR_CIC_ERR_SSL_ENTROPY_COLLECTION = 29027,    ///
        NZERROR_CIC_ERR_SSL_FAIL_SERVER_VERIFY = 29028,    ///
        NZERROR_CIC_ERR_SSL_HANDSHAKE_ALREADY_COMPLETED = 29029, ///
        NZERROR_CIC_ERR_SSL_HANDSHAKE_REQUESTED = 29030,///
        NZERROR_CIC_ERR_SSL_HANDSHAKE_REQUIRED = 29031,    ///
        NZERROR_CIC_ERR_SSL_INCOMPLETE_IDENTITY = 29032,///
        NZERROR_CIC_ERR_SSL_INVALID_PFX    = 29033,    ///
        NZERROR_CIC_ERR_SSL_NEEDS_CIPHER_OR_CLIENTAUTH = 29034, ///
        NZERROR_CIC_ERR_SSL_NEEDS_PRNG    = 29035,    ///
        NZERROR_CIC_ERR_SSL_NOT_SUPPORTED = 29036,    ///
        NZERROR_CIC_ERR_SSL_NO_CERTIFICATE = 29037,    ///
        NZERROR_CIC_ERR_SSL_NO_MATCHING_CERTIFICATES = 29038, ///
        NZERROR_CIC_ERR_SSL_NO_MATCHING_CIPHER_SUITES = 29039, ///
        NZERROR_CIC_ERR_SSL_NO_SUPPORTED_CIPHER_SUITES = 29040, ///
        NZERROR_CIC_ERR_SSL_NULL_CB    = 29041,    ///
        NZERROR_CIC_ERR_SSL_READ_BUFFER_NOT_EMPTY = 29042, ///
        NZERROR_CIC_ERR_SSL_READ_REQUIRED = 29043,    ///
        NZERROR_CIC_ERR_SSL_RENEGOTIATION_ALREADY_REQUESTED = 29044, ///
        NZERROR_CIC_ERR_SSL_RENEGOTIATION_REFUSED = 29045, ///
        NZERROR_CIC_ERR_SSL_RESUMABLE_SESSION = 29046,    ///
        NZERROR_CIC_ERR_SSL_TLS_EXTENSION_MISMATCH = 29047, ///
        NZERROR_CIC_ERR_SSL_UNEXPECTED_MSG = 29048,    ///
        NZERROR_CIC_ERR_SSL_UNKNOWN_RECORD = 29049,    ///
        NZERROR_CIC_ERR_SSL_UNSUPPORTED_CLIENT_AUTH_MODE = 29050, ///
        NZERROR_CIC_ERR_SSL_UNSUPPORTED_PUBKEY_TYPE = 29051, ///
        NZERROR_CIC_ERR_SSL_WRITE_BUFFER_NOT_EMPTY = 29052, ///
        NZERROR_CIC_ERR_PKCS12_MISSING_ALG = 29053,    ///
        NZERROR_CIC_ERR_PKCS_AUTH_FAILED= 29054,    ///
        NZERROR_CIC_ERR_PKCS_BAD_CONTENT_TYPE = 29055,    ///
        NZERROR_CIC_ERR_PKCS_BAD_INPUT    = 29056,    ///
        NZERROR_CIC_ERR_PKCS_BAD_PADDING= 29057,    ///
        NZERROR_CIC_ERR_PKCS_BAD_SN    = 29058,    ///
        NZERROR_CIC_ERR_PKCS_BAD_SN_LENGTH = 29059,    ///
        NZERROR_CIC_ERR_PKCS_BAD_VERSION= 29060,    ///
        NZERROR_CIC_ERR_PKCS_BASE    = 29061,    ///
        NZERROR_CIC_ERR_PKCS_FIELD_NOT_PRESENT = 29062,    ///
        NZERROR_CIC_ERR_PKCS_NEED_CERTVAL = 29063,    ///
        NZERROR_CIC_ERR_PKCS_NEED_PASSWORD = 29064,    ///
        NZERROR_CIC_ERR_PKCS_NEED_PKC    = 29065,    ///
        NZERROR_CIC_ERR_PKCS_NEED_PRV_KEY = 29066,    ///
        NZERROR_CIC_ERR_PKCS_NEED_TRUSTED = 29067,    ///
        NZERROR_CIC_ERR_PKCS_UNSUPPORTED_CERT_FORMAT = 29068, ///
        NZERROR_CIC_ERR_PKCS_UNSUP_PRVKEY_TYPE = 29069,    ///
        NZERROR_CIC_ERR_CODING_BAD_PEM    = 29070,    ///
        NZERROR_CIC_ERR_CODING_BASE    = 29071,     ///
        NZERROR_CIC_ERR_DER_BAD_ENCODING= 29072,    ///
        NZERROR_CIC_ERR_DER_BAD_ENCODING_LENGTH = 29073,///
        NZERROR_CIC_ERR_DER_BASE    = 29074,    ///
        NZERROR_CIC_ERR_DER_ELEMENT_TOO_LONG = 29075,    ///
        NZERROR_CIC_ERR_DER_INDEFINITE_LENGTH = 29076,    ///
        NZERROR_CIC_ERR_DER_NO_MORE_ELEMENTS = 29077,    ///
        NZERROR_CIC_ERR_DER_OBJECT_TOO_LONG = 29078,    ///
        NZERROR_CIC_ERR_DER_TAG_SIZE    = 29079,    ///
        NZERROR_CIC_ERR_DER_TIME_OUT_OF_RANGE = 29080,    ///
        NZERROR_CIC_ERR_DER_UNUSED_BITS_IN_BIT_STR = 29081, ///
        NZERROR_CIC_ERR_GENERAL_BASE    = 29082,    ///
        NZERROR_CIC_ERR_HASH_BASE    = 29083,    ///
        NZERROR_CIC_ERR_ILLEGAL_PARAM    = 29084,    ///
        NZERROR_CIC_ERR_MEM_NOT_OURS    = 29085,    ///
        NZERROR_CIC_ERR_MEM_OVERRUN    = 29086,    ///
        NZERROR_CIC_ERR_MEM_UNDERRUN    = 29087,    ///
        NZERROR_CIC_ERR_MEM_WAS_FREED    = 29088,    ///
        NZERROR_CIC_ERR_NOT_FOUND    = 29090,    ///
        NZERROR_CIC_ERR_NO_PTR        = 29091,    ///
        NZERROR_CIC_ERR_TIMEOUT        = 29092,    ///
        NZERROR_CIC_ERR_UNIT_MASK    = 29093,    ///
        NZERROR_CIC_ERR_BAD_CTX        = 29094,    ///
        NZERROR_CIC_ERR_BAD_INDEX    = 29095,    ///
        NZERROR_CIC_ERR_BAD_LENGTH    = 29096,    ///
        NZERROR_CIC_ERR_CODING_BAD_ENCODING = 29097,    ///
        NZERROR_CIC_ERR_SSL_NO_CLIENT_AUTH_MODES = 29098, ///
        NZERROR_LOCKEYID_CREATE_FAILED    = 29100,    ///
        NZERROR_P12_ADD_PVTKEY_FAILED    = 29101,    ///
        NZERROR_P12_ADD_CERT_FAILED    = 29102,    ///
        NZERROR_P12_WLT_CREATE_FAILED    = 29103,    ///
        NZERROR_P12_ADD_CERTREQ_FAILED    = 29104,    ///
        NZERROR_P12_WLT_EXP_FAILED    = 29105,    ///
        NZERROR_P12_WLT_IMP_FAILED    = 29106,    ///
        NZERROR_P12_CREATE_FAILED    = 29107,    ///
        NZERROR_P12_DEST_FAILED        = 29107,    ///
        NZERROR_P12_RAND_ERROR        = 29108,     ///
        NZERROR_P12_PVTKEY_CRT_FAILED    = 29109,    ///
        NZERROR_P12_INVALID_BAG        = 29110,    ///
        NZERROR_P12_INVALID_INDEX    = 29111,    ///
        NZERROR_P12_GET_CERT_FAILED    = 29112,    ///
        NZERROR_P12_GET_PVTKEY_FAILED    = 29113,    ///
        NZERROR_P12_IMP_PVTKEY_FAILED    = 29114,    ///
        NZERROR_P12_EXP_PVTKEY_FAILED    = 29115,    ///
        NZERROR_P12_GET_ATTRIB_FAILED    = 29116,    ///
        NZERROR_P12_ADD_ATTRIB_FAILED    = 29117,    ///
        NZERROR_P12_CRT_ATTRIB_FAILED    = 29118,    ///
        NZERROR_P12_IMP_CERT_FAILED    = 29119,    ///
        NZERROR_P12_EXP_CERT_FAILED    = 29120,    ///
        NZERROR_P12_ADD_SECRET_FAILED    = 29121,    ///
        NZERROR_P12_ADD_PKCS11INFO_FAILED = 29122,    ///
        NZERROR_P12_GET_PKCS11INFO_FAILED = 29123,    ///
        NZERROR_P12_MULTIPLE_PKCS11_LIBNAME = 29124,    ///
        NZERROR_P12_MULTIPLE_PKCS11_TOKENLABEL = 29125,    ///
        NZERROR_P12_MULTIPLE_PKCS11_TOKENPASSPHRASE = 29126, ///
        NZERROR_P12_UNKNOWN_PKCS11INFO    = 29127,    ///
        NZERROR_P12_PKCS11_LIBNAME_NOT_SET = 29128,    ///
        NZERROR_P12_PKCS11_TOKENLABEL_NOT_SET = 29129,    ///
        NZERROR_P12_PKCS11_TOKENPASSPHRASE_NOT_SET = 29130, ///
        NZERROR_P12_MULTIPLE_PKCS11_CERTLABEL = 29131,    ///
        NZERROR_CIC_ERR_RANDOM        = 29135,    ///
        NZERROR_CIC_ERR_SMALL_BUFFER    = 29136,    ///
        NZERROR_CIC_ERR_SSL_BAD_CONTEXT    = 29137,    ///
        NZERROR_MUTEX_INITIALIZE_FAILED    = 29138,    ///
        NZERROR_MUTEX_DESTROY_FAILED    = 29139,    ///
        NZERROR_BS_CERTOBJ_CREAT_FAILED    = 29140,    ///
        NZERROR_BS_DER_IMP_FAILED    = 29141,    ///
        NZERROR_DES_SELF_TEST_FAILED    = 29150,    ///
        NZERROR_3DES_SELF_TEST_FAILED    = 29151,    ///
        NZERROR_SHA_SELF_TEST_FAILED    = 29152,    ///
        NZERROR_RSA_SELF_TEST_FAILED    = 29153,    ///
        NZERROR_DRNG_SELF_TEST_FAILED    = 29154,    ///
        NZERROR_CKEYPAIR_SELF_TEST_FAILED = 29155,    ///
        NZERROR_CRNG_SELF_TEST_FAILED    = 29156,    ///
        NZERROR_FIPS_PATHNAME_ERROR    = 29157,    ///
        NZERROR_FIPS_LIB_OPEN_FAILED    = 29158,    ///
        NZERROR_FIPS_LIB_READ_ERROR    = 29159,    ///
        NZERROR_FIPS_LIB_DIFFERS    = 29160,    ///
        NZERROR_DAC_SELF_TEST_FAILED    = 29161,    ///
        NZERROR_NONFIPS_CIPHERSUITE    = 29162,    ///
        NZERROR_VENDOR_NOT_SUPPORTED_FIPS_MODE = 29163,    ///
        NZERROR_EXTERNAL_PKCS12_NOT_SUPPORTED_FIPS_MODE = 29164, ///
        NZERROR_AES_SELF_TEST_FAILED    = 29165,    ///
        NZERROR_CRL_SIG_VERIFY_FAILED    = 29176,    /// CRL signature verification failed.
        NZERROR_CERT_NOT_IN_CRL        = 29177,    /// Cert is not in CRL - cert is not revoked.
        NZERROR_CERT_IN_CRL        = 29178,    /// Cert is in CRL - cert is revoked.
        NZERROR_CERT_IN_CRL_CHECK_FAILED= 29179,    /// Cert revocation check failed.
        NZERROR_INVALID_CERT_STATUS_PROTOCOL = 29180,
        NZERROR_LDAP_OPEN_FAILED    = 29181,    /// ldap_open failed.
        NZERROR_LDAP_BIND_FAILED    = 29182,    /// ldap_bind failed.
        NZERROR_LDAP_SEARCH_FAILED    = 29183,    /// ldap_search failed.
        NZERROR_LDAP_RESULT_FAILED    = 29184,    /// ldap_result failed.
        NZERROR_LDAP_FIRSTATTR_FAILED    = 29185,    /// ldap_first_attribute failed.
        NZERROR_LDAP_GETVALUESLEN_FAILED= 29186,    /// ldap_get_values_len failed.
        NZERROR_LDAP_UNSUPPORTED_VALMEC = 29187,    /// Unsupported validation mechanism.
        NZERROR_LDAP_COUNT_ENTRIES_FAILED = 29188,    /// ldap_count_entries failed.
        NZERROR_LDAP_NO_ENTRY_FOUND    = 29189,    /// No entry found in OID.
        NZERROR_LDAP_MULTIPLE_ENTRIES_FOUND = 29190,    /// Multiple entries in OID.
        NZERROR_OID_INFO_NOT_SET    = 29191,
        NZERROR_LDAP_VALMEC_NOT_SET    = 29192,    /// Validation mechanism not set in OID.
        NZERROR_CRLDP_NO_CRL_FOUND    = 29193,    /// No CRL found using CRLDP mechanism.
        NZERROR_CRL_NOT_IN_CACHE    = 29194,    /// No CRL found in the cache.
        NZERROR_CRL_EXPIRED        = 29195,    /// CRL nextUpdate time is in the past.
        NZERROR_DN_MATCH        = 29222,    /// For nztCompareDN.
        NZERROR_CERT_CHAIN_CREATION    = 29223,    /// Unable to create a cert chain with the existing TPs for the    cert to be installed.
        NZERROR_NO_MATCHING_CERT_REQ    = 29224,    /// No matching cert_req was    found the corresponding to the privatekey which matches the cert to be installed.
        NZERROR_CERT_ALREADY_INSTALLED    = 29225,    /// We are attempting to install a cert again into a persona which already has it installed.
        NZERROR_NO_MATCHING_PRIVATE_KEY    = 29226,    /// Could not find a matching persona-private(privatekey) in the Persona, for the given cert(public key).
        NZERROR_VALIDITY_EXPIRED    = 29227,    /// Certificate validity date expired.
        NZERROR_TK_BYTES_NEEDED        = 29228,    /// Couldn't determine # of bytes needed.
        NZERROR_TK_BAD_MAGIC_NUMBER    = 29229,    /// Magic number found in header does not match expected.
        NZERROR_TK_BAD_HEADER_LENGTH    = 29230,    /// Header length passed in not sufficient for message header.
        NZERROR_TK_CE_INIT        = 29231,    /// Crypto engine failed to initialize.
        NZERROR_TK_CE_KEYINIT        = 29232,    /// Crypto engine key initialization failed.
        NZERROR_TK_CE_ENCODE_KEY    = 29233,    /// Count not encode key object.
        NZERROR_TK_CE_DECODE_KEY    = 29234,    /// Could not decode key into object.
        NZERROR_TK_CE_GEYKEYINFO    = 29235,    /// Crypto engine failed to get key info.
        NZERROR_TK_SEED_RANDOM        = 29236,    /// Couldn't seed random number generator.
        NZERROR_TK_CE_ALGFINISH        = 29237,    /// Couldn't finish algorithm.
        NZERROR_TK_CE_ALGAPPLY        = 29238,    /// Couldn't apply algorithm to data.
        NZERROR_TK_CE_ALGINIT        = 29239,    /// Couldn't init CE for algorithm.
        NZERROR_TK_ALGORITHM        = 29240,    /// Have no idea what algorithm you want.
        NZERROR_TK_CANNOT_GROW        = 29241,    /// Cannot grow output buffer block.
        NZERROR_TK_KEYSIZE        = 29242,    /// Key not large enough for data.
        NZERROR_TK_KEYTYPE        = 29243,    /// Unknown key type.
        NZERROR_TK_PLSQL_NO_WRL        = 29244,    /// Wallet resource locator not specified to PL/SQL function.
        NZERROR_TK_CE_FUNC        = 29245,    /// Unknown crypto engine function.
        NZERROR_TK_TDU_FORMAT        = 29246,    /// Unknown TDU format.
        NZERROR_TK_NOTOPEN        = 29247,    /// Object must be open.
        NZERROR_TK_WRLTYPE        = 29248,    /// Bad WRL type.
        NZERROR_TK_CE_STATE        = 29249,    /// Bad state specified for the crypto engine.
        NZERROR_PKCS11_LIBRARY_NOT_FOUND= 43000,    /// PKCS #11 library not found.
        NZERROR_PKCS11_TOKEN_NOT_FOUND    = 43001,    /// Can't find token with given label.
        NZERROR_PKCS11_BAD_PASSPHRASE    = 43002,    /// Passphrase is incorrect/expired.
        NZERROR_PKCS11_GET_FUNC_LIST    = 43003,    /// C_GetFunctionList returned error.
        NZERROR_PKCS11_INITIALIZE    = 43004,    /// C_Initialize returned error.
        NZERROR_PKCS11_NO_TOKENS_PRESENT= 43005,    /// No tokens present.
        NZERROR_PKCS11_GET_SLOT_LIST    = 43006,    /// C_GetSlotList returned error.
        NZERROR_PKCS11_GET_TOKEN_INFO    = 43008,    /// C_GetTokenInfo returned error.
        NZERROR_PKCS11_SYMBOL_NOT_FOUND    = 43009,    /// Symbol not found in PKCS11 lib.
        NZERROR_PKCS11_TOKEN_LOGIN_FAILED = 43011,    /// Token login failed.
        NZERROR_PKCS11_CHANGE_PROVIDERS_ERROR = 43013,    /// Change providers error.
        NZERROR_PKCS11_GET_PRIVATE_KEY_ERROR = 43014,    /// Error trying to find private key on token.
        NZERROR_PKCS11_CREATE_KEYPAIR_ERROR = 43015,    /// Key pair gen error.
        NZERROR_PKCS11_WALLET_CONTAINS_P11_INFO = 43016,/// Wallet already contains pkcs11 info.
        NZERROR_PKCS11_NO_CERT_ON_TOKEN    = 43017,    /// No cert found on token.
        NZERROR_PKCS11_NO_USER_CERT_ON_TOKEN = 43018,    /// No user cert found on token.
        NZERROR_PKCS11_NO_CERT_ON_TOKEN_WITH_GIVEN_LABEL = 43019, ///No cert found on token with given certificate label.
        NZERROR_PKCS11_MULTIPLE_CERTS_ON_TOKEN_WITH_GIVEN_LABEL = 43020, ///Multiple certs found on token with given certificate label.
        NZERROR_PKCS11_CERT_WITH_LABEL_NOT_USER_CERT    = 43021, ///Cert with given cert is not a user cert because no corresponding pvt key found on token.
        NZERROR_BIND_SERVICE_ERROR    = 43050,    /// C_BindService returned error.
        NZERROR_CREATE_KEY_OBJ_ERROR    = 43051,    /// B_CreateKeyObject returned error.
        NZERROR_GET_CERT_FIELDS        = 43052,    /// C_GetCertFields returned error.
        NZERROR_CREATE_PKCS10_OBJECT    = 43053,    /// C_CreatePKCS10Object returned error.
        NZERROR_SET_PKCS10_FIELDS    = 43054,    /// C_SetPKCS10Fields returned error.
        NZERROR_SIGN_CERT_REQUEST    = 43055,    /// C_SignCertRequest returned error.
        NZERROR_GET_PKCS10_DER        = 43056,    /// C_GetPKCS10DER returned error.
        NZERROR_INITIALIZE_CERTC    = 43057,    /// C_InitializeCertC returned error.
        NZERROR_INSERT_PRIVATE_KEY    = 43058,    /// C_InsertPrivateKey returned error.
        NZERROR_RSA_ERROR        = 43059,    /// RSA error. See trace output.
        NZERROR_SLTSCTX_INIT_FAILED    = 43060,    /// sltsini() returned error.
        NZERROR_SLTSKYC_FAILED        = 43061,    /// sltskyc() returned error.
        NZERROR_SLTSCTX_TERM_FAILED    = 43062,    /// sltster() returned error.
        NZERROR_SLTSKYS_FAILED        = 43063,    /// sltskys() returned error.
        NZERROR_INVALID_HEADER_LENGTH    = 43070,    /// Bad sso header length.
        NZERROR_WALLET_CONTAINS_USER_CREDENTIALS = 43071, /// Wallet not empty.
        NZERROR_LAST_ERROR        = 43499,    /// Last available error.
        NZERROR_THIS_MUST_BE_LAST
    }




    /**
    * OCI representation of XMLType.
    */
    struct OCIXMLType {
    }

    /**
    * OCI representation of OCIDomDocument.
    */
    struct OCIDOMDocument {
    }





    /**
    * OCI object reference.
    *
    * In the Oracle object runtime environment, an object is identified by an
    * object reference (ref) which contains the object identifier plus other
    * runtime information.    The contents of a ref is opaque to clients.    Use
    * OCIObjectNew() to enumruct a ref.
    */
    struct OCIRef {
    }

    /**
    * A variable of this type contains (null) indicator information.
    */
    /**
    *
    */
    alias OCIRef ODCIColInfo_ref;

    /**
    *
    */
    alias OCIArray ODCIColInfoList;

    /**
    *
    */
    alias OCIArray ODCIColInfoList2;

    /**
    *
    */
    alias OCIRef ODCIIndexInfo_ref;

    /**
    *
    */
    alias OCIRef ODCIPredInfo_ref;

    /**
    *
    */
    alias OCIArray ODCIRidList;

    /**
    *
    */
    alias OCIRef ODCIIndexCtx_ref;

    /**
    *
    */
    alias OCIRef ODCIObject_ref;

    /**
    *
    */
    alias OCIArray ODCIObjectList;

    /**
    *
    */
    alias OCIRef ODCIQueryInfo_ref;

    /**
    *
    */
    alias OCIRef ODCIFuncInfo_ref;

    /**
    *
    */
    alias OCIRef ODCICost_ref;

    /**
    *
    */
    alias OCIRef ODCIArgDesc_ref;

    /**
    *
    */
    alias OCIArray ODCIArgDescList;

    /**
    *
    */
    alias OCIRef ODCIStatsOptions_ref;

    /**
    *
    */
    alias OCIRef ODCIPartInfo_ref;

    /**
    *
    */
    alias OCIRef ODCIEnv_ref;

    /**
    * External table support.
    */
    alias OCIRef ODCIExtTableInfo_ref;

    /**
    * External table support.
    */
    alias OCIArray ODCIGranuleList;

    /**
    * External table support.
    */
    alias OCIRef ODCIExtTableQCInfo_ref;

    /**
    * External table support.
    */
    alias OCIRef ODCIFuncCallInfo_ref;

    /**
    *
    */
    alias OCIArray ODCINumberList;

    /**
    *
    */


    alias ubyte    ub1;                    ///
    alias byte    sb1;                    ///
    alias byte    b1;                    ///

    alias ushort    ub2;                    ///
    alias short    b2;                    ///
    alias short    sb2;                    ///
    alias short            OCIInd;
    alias uint    ub4;                    ///
    alias int    sb4;                    ///
    alias int    b4;                    ///
    alias ulong    ub8;                    ///
    alias long    sb8;                    ///
    alias ulong    oraub8;                    ///
    alias long    orasb8;                    ///
    alias size_t    sbig_ora;                ///
    alias ptrdiff_t    ubig_ora;                ///

    alias char    text;                    ///
    alias char    oratext;                ///
    alias char    OraText;                ///
    alias ushort    utext;                    ///
    alias char*    pstring;                    ///

    alias byte    eb1;                    ///
    alias short    eb2;                    ///
    alias int    eb4;                    ///
    alias int    sword;                    ///
    alias uint    uword;                    ///
    alias int    eword;                    ///

    alias void    dvoid;                    ///
    alias int    boolean;                ///

    /**
    *
    */
    enum OCITypeParamMode {
        OCI_TYPEPARAM_IN = 0,                /// In.
        OCI_TYPEPARAM_OUT,                /// Out.
        OCI_TYPEPARAM_INOUT,                /// Inout.
        OCI_TYPEPARAM_BYREF,                /// Call by reference (implicitly in-out).
        OCI_TYPEPARAM_OUTNCPY,                /// OUT with NOCOPY modifier.
        OCI_TYPEPARAM_INOUTNCPY                /// IN OUT with NOCOPY modifier.
    }



    /**
    * OCI object reference.
    *
    * In the Oracle object runtime environment, an object is identified by an
    * object reference (ref) which contains the object identifier plus other
    * runtime information.    The contents of a ref is opaque to clients.    Use
    * OCIObjectNew() to enumruct a ref.
    */



    /**
    * OCI object mark status.
    *
    * Status of the object - new, updated or deleted.
    */
    alias uword OCIObjectMarkStatus;



    enum bool TRUE = true;                    ///
    enum bool FALSE = false;                ///

    uword UB1MASK                = 1 << 8 - 1;    ///

    alias void function() lgenfp_t;                ///



    enum OCIInd OCI_IND_NOTNULL        = 0;        /// Not null.
    enum OCIInd OCI_IND_NULL        = -1;        /// Is null.
    enum OCIInd OCI_IND_BADNULL        = -2;        /// Bad null.
    enum OCIInd OCI_IND_NOTNULLABLE    = -3;        /// Can't be null.

    enum uint OCI_ATTR_OBJECT_DETECTCHANGE    = 0x00000020;    /// To enable object change detection mode, set this to TRUE.

    enum uint OCI_ATTR_OBJECT_NEWNOTNULL    = 0x00000010;    /// To enable object creation with non-null attributes by default, set this to TRUE.    By default, an object is created with null attributes.

    enum uint OCI_ATTR_CACHE_ARRAYFLUSH    = 0x00000040;    /// To enable sorting of the objects that belong to the same table before being flushed through OCICacheFlush, set this to TRUE.    Please note that by enabling this object cache will not be flushing the objects in the same order they were dirtied.

    /**
    * OCI object pin option.
    *
    * In the Oracle object runtime environment, the program has the option to
    * specify which copy of the object to pin.
    *
    * OCI_PINOPT_DEFAULT pins an object using the default pin option.    The default
    * pin option can be set as an attribute of the OCI environment handle
    * (OCI_ATTR_PINTOPTION).    The value of the default pin option can be
    * OCI_PINOPT_ANY, OCI_PINOPT_RECENT, or OCI_PIN_LATEST. The default option
    * is initialized to OCI_PINOPT_ANY.
    *
    * OCI_PIN_ANY pins any copy of the object.    The object is pinned
    * using the following criteria:
    *        If the object copy is not loaded, load it from the persistent store.
    *        Otherwise, the loaded object copy is returned to the program.
    *
    * OCI_PIN_RECENT pins the latest copy of an object.    The object is
    * pinned using the following criteria:
    *        If the object is not loaded, load the object from the persistent store
    *                from the latest version.
    *        If the object is not loaded in the current transaction and it is not
    *                dirtied, the object is refreshed from the latest version.
    *        Otherwise, the loaded object copy is returned to the program.
    *
    * OCI_PINOPT_LATEST pins the latest copy of an object.    The object copy is
    * pinned using the following criteria:
    *        If the object copy is not loaded, load it from the persistent store.
    *        If the object copy is loaded and dirtied, it is returned to the program.
    *        Otherwise, the loaded object copy is refreshed from the persistent store.
    */
    enum OCIPinOpt {
        OCI_PIN_DEFAULT = 1,                /// Default pin option.
        OCI_PIN_ANY = 3,                /// Pin any copy of the object.
        OCI_PIN_RECENT = 4,                /// Pin recent copy of the object.
        OCI_PIN_LATEST = 5                /// Pin latest copy of the object.
    }

    /**
    * OCI object lock option.
    *
    * This option is used to specify the locking preferences when an object is
    * loaded from the server.
    */
    enum OCILockOpt {
        OCI_LOCK_NONE = 1,                /// null (same as no lock).
        OCI_LOCK_X = 2,                    /// Exclusive lock.
        OCI_LOCK_X_NOWAIT = 3                /// Exclusive lock, do not wait.
    }

    /**
    * OCI object mark option.
    *
    * When the object is marked updated, the client has to specify how the
    * object is intended to be changed.
    */
    enum OCIMarkOpt {
        OCI_MARK_DEFAULT = 1,                /// Default (the same as OCI_MARK_NONE).
        OCI_MARK_NONE = OCI_MARK_DEFAULT,        /// Object has not been modified.
        OCI_MARK_UPDATE                    /// Object is to be updated.
    }

    /**
    * OCI object duration.
    *
    * A client can specify the duration of which an object is pinned (pin
    * duration) and the duration of which the object is in memory (allocation
    * duration).    If the objects are still pinned at the end of the pin duration,
    * the object cache manager will automatically unpin the objects for the
    * client. If the objects still exist at the end of the allocation duration,
    * the object cache manager will automatically free the objects for the client.
    *
    * Objects that are pinned with the option OCI_DURATION_TRANS will get unpinned
    * automatically at the end of the current transaction.
    *
    * Objects that are pinned with the option OCI_DURATION_SESSION will get
    * unpinned automatically at the end of the current session (connection).
    *
    * The option OCI_DURATION_NULL is used when the client does not want to set
    * the pin duration.    If the object is already loaded into the cache, then the
    * pin duration will remain the same.    If the object is not yet loaded, the
    * pin duration of the object will be set to OCI_DURATION_DEFAULT.
    */
    alias ub2 OCIDuration;

    enum OCIDuration OCI_DURATION_INVALID    = 0xFFFF;    /// Invalid duration.
    enum OCIDuration OCI_DURATION_BEGIN    = 10;        /// Beginning sequence of duration.
    enum OCIDuration OCI_DURATION_NULL    = OCI_DURATION_BEGIN - 1; /// Null duration.
    enum OCIDuration OCI_DURATION_DEFAULT    = OCI_DURATION_BEGIN - 2; /// Default.
    enum OCIDuration OCI_DURATION_USER_CALLBACK = OCI_DURATION_BEGIN - 3; ///
    enum OCIDuration OCI_DURATION_NEXT    = OCI_DURATION_BEGIN - 4; /// Next special duration.
    enum OCIDuration OCI_DURATION_SESSION    = OCI_DURATION_BEGIN; /// The end of user session.
    enum OCIDuration OCI_DURATION_TRANS    = OCI_DURATION_BEGIN + 1; /// The end of user transaction.
    enum OCIDuration OCI_DURATION_STATEMENT= OCI_DURATION_BEGIN + 3; ///
    enum OCIDuration OCI_DURATION_CALLOUT    = OCI_DURATION_BEGIN + 4; /// This is to be used only during callouts.    It is similar to that of OCI_DURATION_CALL, but lasts only for the duration of a callout.    Its heap is from PGA.
    enum OCIDuration OCI_DURATION_LAST    = OCI_DURATION_CALLOUT; /// The last predefined duration.
    enum OCIDuration OCI_DURATION_PROCESS    = OCI_DURATION_BEGIN - 5; /// This is not being treated as other predefined durations such as SESSION, CALL etc, because this would not have an entry in the duration table and its functionality is primitive such that only allocate, free, resize memory are allowed, but one cannot create subduration out of this.

    /**
    * OCI object property.
    *
    * Deprecated:
    *    This will be removed or changed in a future release.
    *
    * This specifies the properties of objects in the object cache.
    */
    enum OCIRefreshOpt {
        OCI_REFRESH_LOADED = 1                /// Refresh objects loaded in the transaction.
    }

    /**
    * OCI Object Event.
    *
    * Deprecated:
    *    This will be removed or changed in a future release.
    *
    * This specifies the kind of event that is supported by the object
    * cache.    The program can register a callback that is invoked when the
    * specified event occurs.
    */

    enum ub1 OCI_OBJECTCOPY_NOREF        = 0x01;        /// If OCI_OBJECTCOPY_NOREF is specified when copying an instance, the    reference and lob will not be copied to the target instance.

    enum ub2 OCI_OBJECTFREE_FORCE        = 0x0001;    /// If OCI_OBJECTCOPY_FORCE is specified when freeing an instance, the instance is freed regardless it is pinned or dirtied.
    enum ub2 OCI_OBJECTFREE_NONULL        = 0x0002;    /// If OCI_OBJECTCOPY_NONULL is specified when freeing an instance, the null structure is not freed.
    enum ub2 OCI_OBJECTFREE_HEADER        = 0x0004;    ///

    /**
    * OCI object property id.
    *
    * Identifies the different properties of objects.
    */
    alias ub1 OCIObjectPropId;

    enum OCIObjectPropId OCI_OBJECTPROP_LIFETIME = 1;    /// Persistent or transient or value.
    enum OCIObjectPropId OCI_OBJECTPROP_SCHEMA = 2;    /// Schema name of table containing object.
    enum OCIObjectPropId OCI_OBJECTPROP_TABLE = 3;        /// Table name of table containing object.
    enum OCIObjectPropId OCI_OBJECTPROP_PIN_DURATION = 4;    /// Pin duartion of object.
    enum OCIObjectPropId OCI_OBJECTPROP_ALLOC_DURATION = 5;/// Alloc duartion of object.
    enum OCIObjectPropId OCI_OBJECTPROP_LOCK = 6;        /// Lock status of object.
    enum OCIObjectPropId OCI_OBJECTPROP_MARKSTATUS = 7;    /// Mark status of object.
    enum OCIObjectPropId OCI_OBJECTPROP_VIEW = 8;        /// Is object a view object or not?

    /**
    * OCI object lifetime.
    *
    * Classifies objects depending upon the lifetime and referenceability
    * of the object.
    */
    enum OCIObjectLifetime {
        OCI_OBJECT_PERSISTENT = 1,            /// Persistent object.
        OCI_OBJECT_TRANSIENT,                /// Transient object.
        OCI_OBJECT_VALUE                /// Value object.
    }

    /**
    * OCI object mark status.
    *
    * Status of the object - new, updated or deleted.
    */

    enum OCIObjectMarkStatus OCI_OBJECT_NEW= 0x0001;    /// New object.
    enum OCIObjectMarkStatus OCI_OBJECT_DELETED = 0x0002;    /// Object marked deleted.
    enum OCIObjectMarkStatus OCI_OBJECT_UPDATED = 0x0004;    /// Object marked updated.





    /**
    * OCI environment handle.
    */
    struct OCIEnv {
    }

    /**
    * OCI error handle.
    */
    struct OCIError {
    }

    /**
    * OCI service handle.
    */
    struct OCISvcCtx {
    }

    /**
    * OCI statement handle.
    */
    struct OCIStmt {
    }

    /**
    * OCI bind handle.
    */
    struct OCIBind {
    }

    /**
    * OCI Define handle.
    */
    struct OCIDefine {
    }

    /**
    * OCI Describe handle.
    */
    struct OCIDescribe {
    }

    /**
    * OCI Server handle.
    */
    struct OCIServer {
    }

    /**
    * OCI Authentication handle.
    */
    struct OCISession {
    }

    /**
    * OCI COR handle.
    */
    struct OCIComplexObject {
    }

    /**
    * OCI Transaction handle.
    */
    struct OCITrans {
    }

    /**
    * OCI Security handle.
    */
    struct OCISecurity {
    }

    /**
    * Subscription handle.
    */
    struct OCISubscription {
    }

    /**
    * Connection pool handle.
    */
    struct OCICPool {
    }

    /**
    * Session pool handle.
    */
    struct OCISPool {
    }

    /**
    * Auth handle.
    */
    struct OCIAuthInfo {
    }

    /**
    * Admin handle.
    */
    struct OCIAdmin {
    }

    /**
    * HA event handle.
    */
    struct OCIEvent {
    }

    /**
    * OCI snapshot descriptor.
    */
    struct OCISnapshot {
    }

    /**
    * OCI Result Set descriptor.
    */
    struct OCIResult {
    }

    /**
    * OCI Lob Locator descriptor.
    */
    struct OCILobLocator {
    }

    /**
    * OCI Parameter descriptor.
    */
    struct OCIParam {
    }

    /**
    * OCI COR descriptor.
    */
    struct OCIComplexObjectComp {
    }

    /**
    * OCI ROWID descriptor.
    */
    struct OCIRowid {
    }

    /**
    * OCI DateTime descriptor.
    */
    struct OCIDateTime {
    }

    /**
    * OCI Interval descriptor.
    */
    struct OCIInterval {
    }

    /**
    * OCI User Callback descriptor.
    */
    struct OCIUcb {
    }

    /**
    * OCI server DN descriptor.
    */
    struct OCIServerDNs {
    }

    /**
    * AQ Enqueue Options hdl.
    */
    struct OCIAQEnqOptions {
    }

    /**
    * AQ Dequeue Options hdl.
    */
    struct OCIAQDeqOptions {
    }

    /**
    * AQ Msg properties.
    */
    struct OCIAQMsgProperties {
    }

    /**
    * AQ Agent descriptor.
    */
    struct OCIAQAgent {
    }

    /**
    * AQ Nfy descriptor.
    */
    struct OCIAQNfyDescriptor {
    }

    /**
    * AQ Siganture.
    */
    struct OCIAQSignature {
    }

    /**
    * AQ listen options.
    */
    struct OCIAQListenOpts {
    }

    /**
    * AQ listen msg props.
    */
    struct OCIAQLisMsgProps {
    }

    /**
    * OCI Character LOB Locator.
    */
    struct OCIClobLocator {
    }

    /**
    * OCI Binary LOB Locator.
    */
    struct OCIBlobLocator {
    }

    /**
    * OCI Binary LOB File Locator.
    */
    struct OCIBFileLocator {
    }

    enum uint OCI_INTHR_UNK        = 24;        /// Undefined value for tz in interval types.

    enum uint OCI_ADJUST_UNK        = 10;        ///
    enum uint OCI_ORACLE_DATE        = 0;        ///
    enum uint OCI_ANSI_DATE        = 1;        ///

    /**
    * OCI Lob Offset.
    *
    * The offset in the lob data.    The offset is specified in terms of bytes for
    * BLOBs and BFILes.    Character offsets are used for CLOBs, NCLOBs.
    * The maximum size of internal lob data is 4 gigabytes.    FILE LOB
    * size is limited by the operating system.
    */
    alias ub4 OCILobOffset;

    /**
    * OCI Lob Length (of lob data).
    *
    * Specifies the length of lob data in bytes for BLOBs and BFILes and in
    * characters for CLOBs, NCLOBs.    The maximum length of internal lob
    * data is 4 gigabytes.    The length of FILE LOBs is limited only by the
    * operating system.
    */
    alias ub4 OCILobLength;

    /**
    * OCI Lob Open Modes.
    *
    * The mode specifies the planned operations that will be performed on the
    * FILE lob data.    The FILE lob can be opened in read-only mode only.
    *
    * In the future, we may include read/write, append and truncate modes.    Append
    * is equivalent to read/write mode except that the FILE is positioned for
    * writing to the end.    Truncate is equivalent to read/write mode except that
    * the FILE LOB data is first truncated to a length of 0 before use.
    */
    enum OCILobMode {
        OCI_LOBMODE_READONLY = 1,            /// Read-only.
        OCI_LOBMODE_READWRITE = 2            /// Read and write for internal lobs only.
    }

    enum uint OCI_FILE_READONLY        = 1;        /// Read-only mode open for FILE types.

    enum uint OCI_LOB_READONLY        = 1;        /// Read-only mode open for ILOB types.
    enum uint OCI_LOB_READWRITE        = 2;        /// Read and write mode open for ILOBs.

    enum uint OCI_LOB_BUFFER_FREE        = 1;        ///
    enum uint OCI_LOB_BUFFER_NOFREE    = 2;        ///

    enum uint OCI_STMT_SELECT        = 1;        /// Select statement.
    enum uint OCI_STMT_UPDATE        = 2;        /// Update statement.
    enum uint OCI_STMT_DELETE        = 3;        /// Delete statement.
    enum uint OCI_STMT_INSERT        = 4;        /// Insert statement.
    enum uint OCI_STMT_CREATE        = 5;        /// Create statement.
    enum uint OCI_STMT_DROP        = 6;        /// Drop statement.
    enum uint OCI_STMT_ALTER        = 7;        /// Alter statement.
    enum uint OCI_STMT_BEGIN        = 8;        /// Begin ... (pl/sql statement).
    enum uint OCI_STMT_DECLARE        = 9;        /// Declare ... (pl/sql statement).

    enum uint OCI_PTYPE_UNK        = 0;        /// Unknown.
    enum uint OCI_PTYPE_TABLE        = 1;        /// Table.
    enum uint OCI_PTYPE_VIEW        = 2;        /// View.
    enum uint OCI_PTYPE_PROC        = 3;        /// Procedure.
    enum uint OCI_PTYPE_FUNC        = 4;        /// Function.
    enum uint OCI_PTYPE_PKG        = 5;        /// Package.
    enum uint OCI_PTYPE_TYPE        = 6;        /// User-defined type.
    enum uint OCI_PTYPE_SYN        = 7;        /// Synonym.
    enum uint OCI_PTYPE_SEQ        = 8;        /// Sequence.
    enum uint OCI_PTYPE_COL        = 9;        /// Column.
    enum uint OCI_PTYPE_ARG        = 10;        /// Argument.
    enum uint OCI_PTYPE_LIST        = 11;        /// List.
    enum uint OCI_PTYPE_TYPE_ATTR        = 12;        /// User-defined type's attribute.
    enum uint OCI_PTYPE_TYPE_COLL        = 13;        /// Collection type's element.
    enum uint OCI_PTYPE_TYPE_METHOD    = 14;        /// User-defined type's method.
    enum uint OCI_PTYPE_TYPE_ARG        = 15;        /// User-defined type method's arg.
    enum uint OCI_PTYPE_TYPE_RESULT    = 16;        /// User-defined type method's result.
    enum uint OCI_PTYPE_SCHEMA        = 17;        /// Schema.
    enum uint OCI_PTYPE_DATABASE        = 18;        /// Database.
    enum uint OCI_PTYPE_RULE        = 19;        /// Rule.
    enum uint OCI_PTYPE_RULE_SET        = 20;        /// Rule set.
    enum uint OCI_PTYPE_EVALUATION_CONTEXT    = 21;        /// Evaluation context.
    enum uint OCI_PTYPE_TABLE_ALIAS    = 22;        /// Table alias.
    enum uint OCI_PTYPE_VARIABLE_TYPE    = 23;        /// Variable type.
    enum uint OCI_PTYPE_NAME_VALUE        = 24;        /// Name value pair.

    enum uint OCI_LTYPE_UNK        = 0;        /// Unknown.
    enum uint OCI_LTYPE_COLUMN        = 1;        /// Column list.
    enum uint OCI_LTYPE_ARG_PROC        = 2;        /// Procedure argument list.
    enum uint OCI_LTYPE_ARG_FUNC        = 3;        /// Function argument list.
    enum uint OCI_LTYPE_SUBPRG        = 4;        /// Subprogram list.
    enum uint OCI_LTYPE_TYPE_ATTR        = 5;        /// Type attribute.
    enum uint OCI_LTYPE_TYPE_METHOD    = 6;        /// Type method.
    enum uint OCI_LTYPE_TYPE_ARG_PROC    = 7;        /// Type method w/o result argument list.
    enum uint OCI_LTYPE_TYPE_ARG_FUNC    = 8;        /// Type method w/ result argument list.
    enum uint OCI_LTYPE_SCH_OBJ        = 9;        /// Schema object list.
    enum uint OCI_LTYPE_DB_SCH        = 10;        /// Database schema list.
    enum uint OCI_LTYPE_TYPE_SUBTYPE    = 11;        /// Subtype list.
    enum uint OCI_LTYPE_TABLE_ALIAS    = 12;        /// Table alias list.
    enum uint OCI_LTYPE_VARIABLE_TYPE    = 13;        /// Variable type list.
    enum uint OCI_LTYPE_NAME_VALUE        = 14;        /// Name value list.

    enum uint OCI_MEMORY_CLEARED        = 1;        ///

    /**
    *
    */
    struct OCIPicklerTdsCtx {
    }

    /**
    *
    */
    struct OCIPicklerTds {
    }

    /**
    *
    */
    struct OCIPicklerImage {
    }

    /**
    *
    */
    struct OCIPicklerFdo {
    }

    /**
    *
    */
    struct OCIAnyData {
    }

    /**
    *
    */
    struct OCIAnyDataSet {
    }

    /**
    *
    */
    struct OCIAnyDataCtx {
    }

    alias ub4 OCIPicklerTdsElement;

    enum uint OCI_UCBTYPE_ENTRY        = 1;        /// Entry callback.
    enum uint OCI_UCBTYPE_EXIT        = 2;        /// Exit callback.
    enum uint OCI_UCBTYPE_REPLACE        = 3;        /// Replacement callback.

    enum uint OCI_NLS_DAYNAME1        = 1;        /// Native name for Monday.
    enum uint OCI_NLS_DAYNAME2        = 2;        /// Native name for Tuesday.
    enum uint OCI_NLS_DAYNAME3        = 3;        /// Native name for Wednesday.
    enum uint OCI_NLS_DAYNAME4        = 4;        /// Native name for Thursday.
    enum uint OCI_NLS_DAYNAME5        = 5;        /// Native name for Friday.
    enum uint OCI_NLS_DAYNAME6        = 6;        /// Native name for Saturday.
    enum uint OCI_NLS_DAYNAME7        = 7;        /// Native name for Sunday.
    enum uint OCI_NLS_ABDAYNAME1        = 8;        /// Native abbreviated name for Monday.
    enum uint OCI_NLS_ABDAYNAME2        = 9;        /// Native abbreviated name for Tuesday.
    enum uint OCI_NLS_ABDAYNAME3        = 10;        /// Native abbreviated name for Wednesday.
    enum uint OCI_NLS_ABDAYNAME4        = 11;        /// Native abbreviated name for Thursday.
    enum uint OCI_NLS_ABDAYNAME5        = 12;        /// Native abbreviated name for Friday.
    enum uint OCI_NLS_ABDAYNAME6        = 13;        /// Native abbreviated name for Saturday.
    enum uint OCI_NLS_ABDAYNAME7        = 14;        /// Native abbreviated name for Sunday.
    enum uint OCI_NLS_MONTHNAME1        = 15;        /// Native name for January.
    enum uint OCI_NLS_MONTHNAME2        = 16;        /// Native name for February.
    enum uint OCI_NLS_MONTHNAME3        = 17;        /// Native name for March.
    enum uint OCI_NLS_MONTHNAME4        = 18;        /// Native name for April.
    enum uint OCI_NLS_MONTHNAME5        = 19;        /// Native name for May.
    enum uint OCI_NLS_MONTHNAME6        = 20;        /// Native name for June.
    enum uint OCI_NLS_MONTHNAME7        = 21;        /// Native name for July.
    enum uint OCI_NLS_MONTHNAME8        = 22;        /// Native name for August.
    enum uint OCI_NLS_MONTHNAME9        = 23;        /// Native name for September.
    enum uint OCI_NLS_MONTHNAME10        = 24;        /// Native name for October.
    enum uint OCI_NLS_MONTHNAME11        = 25;        /// Native name for November.
    enum uint OCI_NLS_MONTHNAME12        = 26;        /// Native name for December.
    enum uint OCI_NLS_ABMONTHNAME1        = 27;        /// Native abbreviated name for January.
    enum uint OCI_NLS_ABMONTHNAME2        = 28;        /// Native abbreviated name for February.
    enum uint OCI_NLS_ABMONTHNAME3        = 29;        /// Native abbreviated name for March.
    enum uint OCI_NLS_ABMONTHNAME4        = 30;        /// Native abbreviated name for April.
    enum uint OCI_NLS_ABMONTHNAME5        = 31;        /// Native abbreviated name for May.
    enum uint OCI_NLS_ABMONTHNAME6        = 32;        /// Native abbreviated name for June.
    enum uint OCI_NLS_ABMONTHNAME7        = 33;        /// Native abbreviated name for July.
    enum uint OCI_NLS_ABMONTHNAME8        = 34;        /// Native abbreviated name for August.
    enum uint OCI_NLS_ABMONTHNAME9        = 35;        /// Native abbreviated name for September.
    enum uint OCI_NLS_ABMONTHNAME10    = 36;        /// Native abbreviated name for October.
    enum uint OCI_NLS_ABMONTHNAME11    = 37;        /// Native abbreviated name for November.
    enum uint OCI_NLS_ABMONTHNAME12    = 38;        /// Native abbreviated name for December.
    enum uint OCI_NLS_YES            = 39;        /// Native string for affirmative response.
    enum uint OCI_NLS_NO            = 40;        /// Native negative response.
    enum uint OCI_NLS_AM            = 41;        /// Native equivalent string of AM.
    enum uint OCI_NLS_PM            = 42;        /// Native equivalent string of PM.
    enum uint OCI_NLS_AD            = 43;        /// Native equivalent string of AD.
    enum uint OCI_NLS_BC            = 44;        /// Native equivalent string of BC.
    enum uint OCI_NLS_DECIMAL        = 45;        /// Decimal character.
    enum uint OCI_NLS_GROUP        = 46;        /// Group separator.
    enum uint OCI_NLS_DEBIT        = 47;        /// Native symbol of debit.
    enum uint OCI_NLS_CREDIT        = 48;        /// Native sumbol of credit.
    enum uint OCI_NLS_DATEFORMAT        = 49;        /// Oracle date format.
    enum uint OCI_NLS_INT_CURRENCY        = 50;        /// International currency symbol.
    enum uint OCI_NLS_LOC_CURRENCY        = 51;        /// Locale currency symbol.
    enum uint OCI_NLS_LANGUAGE        = 52;        /// Language name.
    enum uint OCI_NLS_ABLANGUAGE        = 53;        /// Abbreviation for language name.
    enum uint OCI_NLS_TERRITORY        = 54;        /// Territory name.
    enum uint OCI_NLS_CHARACTER_SET    = 55;        /// Character set name.
    enum uint OCI_NLS_LINGUISTIC_NAME    = 56;        /// Linguistic name.
    enum uint OCI_NLS_CALENDAR        = 57;        /// Calendar name.
    enum uint OCI_NLS_DUAL_CURRENCY    = 78;        /// Dual currency symbol.
    enum uint OCI_NLS_WRITINGDIR        = 79;        /// Language writing direction.
    enum uint OCI_NLS_ABTERRITORY        = 80;        /// Territory Abbreviation.
    enum uint OCI_NLS_DDATEFORMAT        = 81;        /// Oracle default date format.
    enum uint OCI_NLS_DTIMEFORMAT        = 82;        /// Oracle default time format.
    enum uint OCI_NLS_SFDATEFORMAT        = 83;        /// Local string formatted date format.
    enum uint OCI_NLS_SFTIMEFORMAT        = 84;        /// Local string formatted time format.
    enum uint OCI_NLS_NUMGROUPING        = 85;        /// Number grouping fields.
    enum uint OCI_NLS_LISTSEP        = 86;        /// List separator.
    enum uint OCI_NLS_MONDECIMAL        = 87;        /// Monetary decimal character.
    enum uint OCI_NLS_MONGROUP        = 88;        /// Monetary group separator.
    enum uint OCI_NLS_MONGROUPING        = 89;        /// Monetary grouping fields.
    enum uint OCI_NLS_INT_CURRENCYSEP    = 90;        /// International currency separator.
    enum uint OCI_NLS_CHARSET_MAXBYTESZ    = 91;        /// Maximum character byte size            .
    enum uint OCI_NLS_CHARSET_FIXEDWIDTH    = 92;        /// Fixed-width charset byte size        .
    enum uint OCI_NLS_CHARSET_ID        = 93;        /// Character set id.
    enum uint OCI_NLS_NCHARSET_ID        = 94;        /// NCharacter set id.

    enum uint OCI_NLS_MAXBUFSZ        = 100;        /// Max buffer size may need for OCINlsGetInfo.

    enum uint OCI_NLS_BINARY        = 0x1;        /// For the binary comparison.
    enum uint OCI_NLS_LINGUISTIC        = 0x2;        /// For linguistic comparison.
    enum uint OCI_NLS_CASE_INSENSITIVE    = 0x10;        /// For case-insensitive comparison.

    enum uint OCI_NLS_UPPERCASE        = 0x20;        /// Convert to uppercase.
    enum uint OCI_NLS_LOWERCASE        = 0x40;        /// Convert to lowercase.

    enum uint OCI_NLS_CS_IANA_TO_ORA    = 0;        /// Map charset name from IANA to Oracle.
    enum uint OCI_NLS_CS_ORA_TO_IANA    = 1;        /// Map charset name from Oracle to IANA.
    enum uint OCI_NLS_LANG_ISO_TO_ORA    = 2;        /// Map language name from ISO to Oracle.
    enum uint OCI_NLS_LANG_ORA_TO_ISO    = 3;        /// Map language name from Oracle to ISO.
    enum uint OCI_NLS_TERR_ISO_TO_ORA    = 4;        /// Map territory name from ISO to Oracle.
    enum uint OCI_NLS_TERR_ORA_TO_ISO    = 5;        /// Map territory name from Oracle to ISO.
    enum uint OCI_NLS_TERR_ISO3_TO_ORA    = 6;        /// Map territory name from 3-letter ISO abbreviation to Oracle.
    enum uint OCI_NLS_TERR_ORA_TO_ISO3    = 7;        /// Map territory name from Oracle to    3-letter ISO abbreviation.

    /**
    *
    */
    struct OCIMsg {
    }

    alias ub4 OCIWchar;

    enum uint OCI_XMLTYPE_CREATE_OCISTRING    = 1;        ///
    enum uint OCI_XMLTYPE_CREATE_CLOB    = 2;        ///
    enum uint OCI_XMLTYPE_CREATE_BLOB    = 3;        ///

    enum uint OCI_KERBCRED_PROXY        = 1;        /// Apply Kerberos Creds for Proxy.
    enum uint OCI_KERBCRED_CLIENT_IDENTIFIER = 2;        /// Apply Creds for Secure Client ID.

    enum uint OCI_DBSTARTUPFLAG_FORCE    = 0x00000001;    /// Abort running instance, start.
    enum uint OCI_DBSTARTUPFLAG_RESTRICT    = 0x00000002;    /// Restrict access to DBA.

    enum uint OCI_DBSHUTDOWN_TRANSACTIONAL    = 1;        /// Wait for all the transactions.
    enum uint OCI_DBSHUTDOWN_TRANSACTIONAL_LOCAL = 2;    /// Wait for local transactions.
    enum uint OCI_DBSHUTDOWN_IMMEDIATE    = 3;        /// Terminate and roll back.
    enum uint OCI_DBSHUTDOWN_ABORT        = 4;        /// Terminate and don't roll back.
    enum uint OCI_DBSHUTDOWN_FINAL        = 5;        /// Orderly shutdown.

    enum uint OCI_MAJOR_VERSION        = 10;        /// Major release version.
    enum uint OCI_MINOR_VERSION        = 2;        /// Minor release version.





    /**
    *
    */
    ub1 OCIFormatUb1 (ub1 variable) {
        return cast(ub1)(OCIFormatTUb1() & variable);
    }

    /**
    *
    */
    ub2 OCIFormatUb2 (ub2 variable) {
        return cast(ub2)(OCIFormatTUb2() & variable);
    }

    /**
    *
    */
    ub4 OCIFormatUb4 (ub4 variable) {
        return cast(ub4)(OCIFormatTUb4() & variable);
    }

    /**
    *
    */
    uword OCIFormatUword (uword variable) {
        return cast(uword)(OCIFormatTUword() & variable);
    }

    /**
    *
    */
    ubig_ora OCIFormatUbig_ora (ubig_ora variable) {
        return cast(ubig_ora)(OCIFormatTUbig_ora() & variable);
    }

    /**
    *
    */
    sb1 OCIFormatSb1 (sb1 variable) {
        return cast(sb1)(OCIFormatTSb1() & variable);
    }

    /**
    *
    */
    sb2 OCIFormatSb2 (sb2 variable) {
        return cast(sb2)(OCIFormatTSb2() & variable);
    }

    /**
    *
    */
    sb4 OCIFormatSb4 (sb4 variable) {
        return cast(sb4)(OCIFormatTSb4() & variable);
    }

    /**
    *
    */
    sword OCIFormatSword (sword variable) {
        return cast(sword)(OCIFormatTSword() & variable);
    }

    /**
    *
    */
    sbig_ora OCIFormatSbig_ora (sbig_ora variable) {
        return cast(sbig_ora)(OCIFormatTSbig_ora() & variable);
    }

    /**
    *
    */
    eb1 OCIFormatEb1 (eb1 variable) {
        return cast(eb1)(OCIFormatTEb1() & variable);
    }

    /**
    *
    */
    eb2 OCIFormatEb2 (eb2 variable) {
        return cast(eb2)(OCIFormatTEb2() & variable);
    }

    /**
    *
    */
    eb4 OCIFormatEb4 (eb4 variable) {
        return cast(eb4)(OCIFormatTEb4() & variable);
    }

    /**
    *
    */
    eword OCIFormatEword (eword variable) {
        return cast(eword)(OCIFormatTEword() & variable);
    }

    /**
    *
    */
    char OCIFormatChar (char variable) {
        return cast(char)(OCIFormatTChar() & variable);
    }

    /**
    *
    */
    text OCIFormatText (text variable) {
        return cast(text)(OCIFormatTText() & variable);
    }

    /**
    *
    */
    double OCIFormatDouble (double variable) {
        return cast(double)cast(size_t)(cast(size_t)OCIFormatTDouble() & cast(size_t)variable);
    }

    /**
    *
    */
    dvoid* OCIFormatDvoid (dvoid* variable) {
        return cast(dvoid*)(OCIFormatTDvoid() & cast(ptrdiff_t)variable);
    }

    /**
    *
    */
    alias OCIFormatTEnd OCIFormatEnd;

    enum uint OCIFormatDP            = 6;        ///

    enum uint OCI_FILE_READ_ONLY        = 1;        /// Open for read only.
    enum uint OCI_FILE_WRITE_ONLY        = 2;        /// Open for write only.
    enum uint OCI_FILE_READ_WRITE        = 3;        /// Open for read & write.

    enum uint OCI_FILE_EXIST        = 0;        /// The file should exist.
    enum uint OCI_FILE_CREATE        = 1;        /// Create if the file doesn't exist.
    enum uint OCI_FILE_EXCL        = 2;        /// The file should not exist.
    enum uint OCI_FILE_TRUNCATE        = 4;        /// Create if the file doesn't exist, else truncate file the file to 0.
    enum uint OCI_FILE_APPEND        = 8;        /// Open the file in append mode.

    enum uint OCI_FILE_SEEK_BEGINNING    = 1;        /// Seek from the beginning of the file.
    enum uint OCI_FILE_SEEK_CURRENT    = 2;        /// Seek from the current position.
    enum uint OCI_FILE_SEEK_END        = 3;        /// Seek from the end of the file.

    enum uint OCI_FILE_FORWARD        = 1;        /// Seek forward.
    enum uint OCI_FILE_BACKWARD        = 2;        /// Seek backward.

    enum uint OCI_FILE_BIN            = 0;        /// Binary file.
    enum uint OCI_FILE_TEXT        = 1;        /// Text file.
    enum uint OCI_FILE_STDIN        = 2;        /// Standard i/p.
    enum uint OCI_FILE_STDOUT        = 3;        /// Standard o/p.
    enum uint OCI_FILE_STDERR        = 4;        /// Standard error.

    /**
    * Represents an open file.
    */
    struct OCIFileObject {
    }

    /**
    * OCIThread Context.
    */
    struct OCIThreadContext {
    }

    /**
    * OCIThread Mutual Exclusion Lock.
    */
    struct OCIThreadMutex {
    }

    /**
    * OCIThread Key for Thread-Specific Data.
    */
    struct OCIThreadKey {
    }

    /**
    * OCIThread Thread ID.
    */
    struct OCIThreadId {
    }

    /**
    * OCIThread Thread Handle.
    */
    struct OCIThreadHandle {
    }

    /**
    * OCIThread Key Destructor Function Type.
    */
    alias void function(dvoid*) OCIThreadKeyDestFunc;

    enum uint OCI_EXTRACT_CASE_SENSITIVE    = 0x1;        /// Matching is case sensitive.
    enum uint OCI_EXTRACT_UNIQUE_ABBREVS    = 0x2;        /// Unique abbreviations for keys are allowed.
    enum uint OCI_EXTRACT_APPEND_VALUES    = 0x4;        /// If multiple values for a key exist, this determines if the new value should be appended to (or replace) the current list of values.

    enum uint OCI_EXTRACT_MULTIPLE        = 0x8;        /// Key can accept multiple values.
    enum uint OCI_EXTRACT_TYPE_BOOLEAN    = 1;        /// Key type is boolean.
    enum uint OCI_EXTRACT_TYPE_STRING    = 2;        /// Key type is string.
    enum uint OCI_EXTRACT_TYPE_INTEGER    = 3;        /// Key type is integer.
    enum uint OCI_EXTRACT_TYPE_OCINUM    = 4;        /// Key type is ocinum.



    /**
    * Context.
    */
    struct OCIDirPathCtx {
    }

    /**
    * Function context.
    */
    struct OCIDirPathFuncCtx {
    }

    /**
    * Column array.
    */
    struct OCIDirPathColArray {
    }

    /**
    * Stream.
    */
    struct OCIDirPathStream {
    }

    /**
    * Direct path descriptor.
    */
    struct OCIDirPathDesc {
    }

    enum uint OCI_DIRPATH_LOAD        = 1;        /// Direct path load operation.
    enum uint OCI_DIRPATH_UNLOAD        = 2;        /// Direct path unload operation.
    enum uint OCI_DIRPATH_CONVERT        = 3;        /// Direct path convert only operation.

    enum uint OCI_DIRPATH_INDEX_MAINT_SINGLE_ROW = 1;    ///

    enum uint OCI_DIRPATH_INDEX_MAINT_SKIP_UNUSABLE = 2;    ///
    enum uint OCI_DIRPATH_INDEX_MAINT_DONT_SKIP_UNUSABLE = 3; ///
    enum uint OCI_DIRPATH_INDEX_MAINT_SKIP_ALL = 4;    ///

    enum uint OCI_DIRPATH_NORMAL        = 1;        /// Can accept rows, last row complete.
    enum uint OCI_DIRPATH_PARTIAL        = 2;        /// Last row was partial.
    enum uint OCI_DIRPATH_NOT_PREPARED    = 3;        /// Direct path context is not prepared.

    enum uint OCI_DIRPATH_COL_COMPLETE    = 0;        /// Column data is complete.
    enum uint OCI_DIRPATH_COL_NULL        = 1;        /// Column is null.
    enum uint OCI_DIRPATH_COL_PARTIAL    = 2;        /// Column data is partial.
    enum uint OCI_DIRPATH_COL_ERROR    = 3;        /// Column error, ignore row.

    enum uint OCI_DIRPATH_DATASAVE_SAVEONLY= 0;        /// Data save point only.
    enum uint OCI_DIRPATH_DATASAVE_FINISH    = 1;        /// Execute finishing logic.

    enum uint OCI_DIRPATH_DATASAVE_PARTIAL    = 2;        /// Save portion of input data (before space error occurred) and finish.

    enum uint OCI_DIRPATH_EXPR_OBJ_CONSTR    = 1;        /// NAME is an object enumructor.
    enum uint OCI_DIRPATH_EXPR_SQL        = 2;        /// NAME is an opaque or sql function.
    enum uint OCI_DIRPATH_EXPR_REF_TBLNAME    = 3;        /// NAME is table name if ref is scoped.

    /**
    * Abort a direct path operation.
    *
    * Upon successful completion the direct path context is no longer valid.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathAbort (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Execute a data save point.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *    action =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathDataSave (OCIDirPathCtx* dpctx, OCIError* errhp, ub4 action);

    /**
    * Finish a direct path operation.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathFinish (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Flush a partial row from the server.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathFlushRow (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Prepare a direct path operation.
    *
    * Params:
    *    dpctx =
    *    svchp =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathPrepare (OCIDirPathCtx* dpctx, OCISvcCtx* svchp, OCIError* errhp);

    /**
    * Load a direct path stream.
    *
    * Params:
    *    dpctx =
    *    dpstr =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathLoadStream (OCIDirPathCtx* dpctx, OCIDirPathStream* dpstr, OCIError* errhp);

    /**
    * Get column array entry.
    *
    * Deprecated:
    *    Use OCIDirPathColArrayRowGet instead.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    colIdx =
    *    cvalpp =
    *    clenp =
    *    cflgp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayEntryGet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub2 colIdx, ub1** cvalpp, ub4* clenp, ub1* cflgp);

    /**
    * Set column array entry.
    *
    * Deprecated:
    *    Use OCIDirPathColArrayRowGet instead.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    colIdx =
    *    cvalp =
    *    clenp =
    *    clen =
    *    cflgp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayEntrySet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub2 colIdx, ub1* cvalp, ub4 clen, ub1 cflg);

    /**
    * Get column array row pointers.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    cvalppp =
    *    clenpp =
    *    cflgpp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayRowGet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub1*** cvalppp, ub4** clenpp, ub1** cflgpp);

    /**
    * Reset column array state.
    *
    * Resetting the column array state is necessary when piecing in a large
    * column and an error occurs in the middle of loading the column.
    *
    * Params:
    *    dpca =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayReset (OCIDirPathColArray* dpca, OCIError* errhp);

    /**
    * Convert column array to stream format.
    *
    * Params:
    *    dpca =
    *    dpctx =
    *    dpstr =
    *    errhp =
    *    rowcnt =
    *    rowoff =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayToStream (OCIDirPathColArray* dpca, OCIDirPathCtx* dpctx, OCIDirPathStream* dpstr, OCIError* errhp, ub4 rowcnt, ub4 rowoff);

    /**
    *
    *
    * Params:
    *    dpstr =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathStreamReset (OCIDirPathStream* dpstr, OCIError* errhp);



    enum uint NZT_MAX_SHA1            = 20;        ///
    enum uint NZT_MAX_MD5            = 16;        ///

    enum NZT_SQLNET_WRL        = "sqlnet:";    /// In this case, the directory path will be retrieved from the sqlnet.ora file under the oss.source.my_wallet parameter.
    enum NZT_FILE_WRL        = "file:";    /// Find the Oracle wallet in this directory. eg: file:<dir-path>.
    enum NZT_ENTR_WRL        = "entr:";    /// Entrust WRL. eg: entr:<dir-path>.
    enum NZT_MCS_WRL        = "mcs:";    /// Microsoft WRL.
    enum NZT_ORACLE_WRL        = "oracle:";    ///
    enum NZT_REGISTRY_WRL        = "reg:";    ///

    /**
    *
    */
    enum nzttwrl {
        NZTTWRL_DEFAULT = 1,                /// Default, use SNZD_DEFAULT_FILE_DIRECTORY.
        NZTTWRL_SQLNET,                    /// Use oss.source.my_wallet in sqlnet.ora file.
        NZTTWRL_FILE,                    /// Find the oracle wallet in this directory.
        NZTTWRL_ENTR,                    /// Find the entrust profile in this directory.
        NZTTWRL_MCS,                    /// WRL for Microsoft.
        NZTTWRL_ORACLE,                    /// Get the wallet from OSS db.
        NZTTWRL_NULL,                    /// New SSO defaulting mechanism.
        NZTTWRL_REGISTRY                /// Find the wallet in Windows Registry.
    }

    /**
    *
    */
    struct nzctx {
    }

    /**
    *
    */
    struct nzstrc {
    }

    /**
    *
    */
    struct nzosContext {
    }

    /**
    *
    */
    struct nzttIdentityPrivate {
    }

    /**
    *
    */
    struct nzttPersonaPrivate {
    }

    /**
    *
    */
    struct nzttWalletPrivate {
    }

    /**
    * For wallet object.
    */
    struct nzttWalletObj {
    }

    /**
    * For secretstore.
    */
    struct nzssEntry {
    }

    /**
    *
    */
    struct nzpkcs11_Info {
    }

    /**
    * Crypto Engine State.
    *
    * Once the crypto engine (CE) has been initialized for a particular
    * cipher, it is either at the initial state, or it is continuing to
    * use the cipher.    NZTCES_END is used to change the state back to
    * initialized and flush any remaining output.    NZTTCES_RESET can be
    * used to change the state back to initialized and throw away any
    * remaining output.
    */
    enum nzttces {
        NZTTCES_CONTINUE = 1,                /// Continue processing input.
        NZTTCES_END,                    /// End processing input.
        NZTTCES_RESET                    /// Reset processing and skip generating output.
    }

    /**
    * Crypto Engine Functions.
    *
    * List of crypto engine categories; used to index into protection
    * vector.
    */
    enum nzttcef {
        NZTTCEF_DETACHEDSIGNATURE = 1,            /// Signature detached from content.
        NZTTCEF_SIGNATURE,                /// Signature combined with content.
        NZTTCEF_ENVELOPING,                /// Signature and encryption with content.
        NZTTCEF_PKENCRYPTION,                /// Encryption for one or more recipients.
        NZTTCEF_ENCRYPTION,                /// Symmetric encryption.
        NZTTCEF_KEYEDHASH,                /// Keyed hash/checksum.
        NZTTCEF_HASH,                    /// Hash/checksum.
        NZTTCEF_RANDOM,                    /// Random byte generation.
        NZTTCEF_LAST                    /// Used for array size.
    }

    /**
    * State of the persona.
    */
    enum nzttState {
        NZTTSTATE_EMPTY = 0,                /// Is not in any state(senseless???).
        NZTTSTATE_REQUESTED,                /// Cert-request.
        NZTTSTATE_READY,                /// Certificate.
        NZTTSTATE_INVALID,                /// Certificate.
        NZTTSTATE_RENEWAL                /// Renewal-requested.
    }

    /**
    * Cert-version types.
    *
    * This is used to quickly look-up the cert-type.
    */
    enum nzttVersion {
        NZTTVERSION_X509v1 = 1,                /// X.509v1.
        NZTTVERSION_X509v3,                /// X.509v3.
        NZTTVERSION_SYMMETRIC,                /// Deprecated.    Symmetric.
        NZTTVERSION_INVALID_TYPE            /// For Initialization.
    }

    /**
    * Cipher Types.
    *
    * List of all cryptographic algorithms, some of which may not be
    * available.
    */
    enum nzttCipherType {
        NZTTCIPHERTYPE_RSA = 1,                /// RSA public key.
        NZTTCIPHERTYPE_DES,                /// DES.
        NZTTCIPHERTYPE_RC4,                /// RC4.
        NZTTCIPHERTYPE_MD5DES,                /// DES encrypted MD5 with salt (PBE).
        NZTTCIPHERTYPE_MD5RC2,                /// RC2 encrypted MD5 with salt (PBE).
        NZTTCIPHERTYPE_MD5,                /// MD5.
        NZTTCIPHERTYPE_SHA                /// SHA.
    }

    /**
    * TDU Formats.
    *
    * List of possible toolkit data unit (TDU) formats.    Depending on the
    * function and cipher used some may be not be available.
    */
    enum nztttdufmt {
        NZTTTDUFMT_PKCS7 = 1,                /// PKCS7 format.
        NZTTTDUFMT_RSAPAD,                /// RSA padded format.
        NZTTTDUFMT_ORACLEv1,                /// Oracle v1 format.
        NZTTTDUFMT_LAST                    /// Used for array size.
    }

    /**
    * Validation States.
    *
    * Possible validation states an identity can be in.
    */
    enum nzttValState {
        NZTTVALSTATE_NONE = 1,                /// Needs to be validated.
        NZTTVALSTATE_GOOD,                /// Validated.
        NZTTVALSTATE_REVOKED                /// Failed to validate.
    }

    /**
    * Policy Fields.
    *
    * Policies enforced.
    */
    enum nzttPolicy {
        NZTTPOLICY_NONE = 0,                /// No retries are allowed.
        NZTTPOLICY_RETRY_1,                /// Number of retries for decryption = 1.
        NZTTPOLICY_RETRY_2,                /// Number of retries for decryption = 2.
        NZTTPOLICY_RETRY_3                /// Number of retries for decryption = 3.
    }

    /*
    * Persona Usage.
    *
    * Deprecated:
    *
    *
    * What a persona will be used for?
    */
    enum nzttUsage {
        NZTTUSAGE_NONE = 0,                ///
        NZTTUSAGE_SSL                    /// Persona for SSL usage.
    }
    /**
    * Personas and identities have unique id's that are represented with
    * 128 bits.
    */
    alias ub1[16] nzttID;

    /**
    * Identity Types
    *
    * List of all Identity types..
    */
    enum nzttIdentType {
        NZTTIDENTITYTYPE_INVALID_TYPE = 0,        ///
        NZTTIDENTITYTYPE_CERTIFICTAE,            ///
        NZTTIDENTITYTYPE_CERT_REQ,            ///
        NZTTIDENTITYTYPE_RENEW_CERT_REQ,        ///
        NZTTIDENTITYTYPE_CLEAR_ETP,            ///
        NZTTIDENTITYTYPE_CLEAR_UTP,            ///
        NZTTIDENTITYTYPE_CLEAR_PTP            ///
    }

    alias ub4 nzttKPUsage;

    enum uint NZTTKPUSAGE_NONE        = 0;
    enum uint NZTTKPUSAGE_SSL        = 1;        /// SSL Server.
    enum uint NZTTKPUSAGE_SMIME_ENCR    = 2;
    enum uint NZTTKPUSAGE_SMIME_SIGN    = 4;
    enum uint NZTTKPUSAGE_CODE_SIGN    = 8;
    enum uint NZTTKPUSAGE_CERT_SIGN    = 16;
    enum uint NZTTKPUSAGE_SSL_CLIENT    = 32;        /// SSL Client.
    enum uint NZTTKPUSAGE_INVALID_USE    = 0xffff;

    /**
    * Timestamp as 32 bit quantity in UTC.
    */
    alias ub1[4] nzttTStamp;

    /**
    * Buffer Block.
    *
    * A function that needs to fill (and possibly grow) an output buffer
    * uses an output parameter block to describe each buffer.
    *
    * The flags_nzttBufferBlock member tells the function whether the
    * buffer can be grown or not.    If flags_nzttBufferBlock is 0, then
    * the buffer will be realloc'ed automatically.
    *
    * The buflen_nzttBufferBLock member is set to the length of the
    * buffer before the function is called and will be the length of the
    * buffer when the function is finished.    If buflen_nzttBufferBlock is
    * 0, then the initial pointer stored in pobj_nzttBufferBlock is
    * ignored.
    *
    * The objlen_nzttBufferBlock member is set to the length of the
    * object stored in the buffer when the function is finished.    If the
    * initial buffer had a non-0 length, then it is possible that the
    * object length is shorter than the buffer length.
    *
    * The pobj_nzttBufferBlock member is a pointer to the output object.
    */
    struct nzttBufferBlock {
        uword flags_nzttBufferBlock;            /// Flags.
        ub4 buflen_nzttBufferBlock;            /// Total length of buffer.
        ub4 usedlen_nzttBufferBlock;            /// Length of used buffer part.
        ub1 *buffer_nzttBufferBlock;            /// Pointer to buffer.
    }

    enum uint NZT_NO_AUTO_REALLOC        = 0x1;        ///

    /**
    * Wallet.
    */
    struct nzttWallet {
        ub1* ldapName_nzttWallet;            /// User's LDAP name.
        ub4 ldapNamelen_nzttWallet;            /// Length of user's LDAP name.
        nzttPolicy securePolicy_nzttWallet;        /// Secured-policy of the wallet.
        nzttPolicy openPolicy_nzttWallet;        /// Open-policy of the wallet.
        nzttPersona* persona_nzttWallet;        /// List of personas in wallet.
        nzttWalletPrivate* private_nzttWallet;        /// Private wallet information.
        ub4 npersona_nzttWallet;            /// Deprecated.    Number of personas.
    }

    /**
    * Persona.
    *
    * The wallet contains one or more personas.    A persona always
    * contains its private key and its identity.    It may also contain
    * other 3rd party identites.    All identities qualified with trust
    * where the qualifier can indicate anything from untrusted to trusted
    * for specific operations.
    */
    struct nzttPersona {
        ub1*genericName_nzttPersona;            /// User-friendly persona name.
        ub4 genericNamelen_nzttPersona;            /// Persona-name length.
        nzttPersonaPrivate* private_nzttPersona;    /// Opaque part of persona.
        nzttIdentity* mycertreqs_nzttPersona;        /// My cert-requests.
        nzttIdentity* mycerts_nzttPersona;        /// My certificates.
        nzttIdentity* mytps_nzttPersona;        /// List of trusted identities.
        nzssEntry* mystore_nzttPersona;            /// List of secrets.
        nzpkcs11_Info* mypkcs11Info_nzttPersona;    /// PKCS11 token info.
        nzttPersona* next_nzttPersona;            /// Next persona.

        nzttUsage usage_nzttPersona;            /// Deprecated.    persona usage; SSL/SET/etc.
        nzttState state_nzttPersona;            /// Deprecated.    persona state-requested/ready.
        ub4 ntps_nzttPersona;                /// Deprecated.    Num of trusted identities.
    }

    /**
    * Identity.
    *
    * Structure containing information about an identity.
    *
    * NOTE
    *    -- the next_trustpoint field only applies to trusted identities and
    *            has no meaning (i.e. is null) for self identities.
    */
    struct nzttIdentity {
        text* dn_nzttIdentity;                /// Alias.
        ub4 dnlen_nzttIdentity;                /// Length of alias.
        text* comment_nzttIdentity;            /// Comment.
        ub4 commentlen_nzttIdentity;            /// Length of comment.
        nzttIdentityPrivate* private_nzttIdentity;    /// Opaque part of identity.
        nzttIdentity* next_nzttIdentity;        /// Next identity in list.
    }

    /**
    *
    */
    struct nzttB64Cert {
        ub1* b64Cert_nzttB64Cert;            ///
        ub4 b64Certlen_nzttB64Cert;            ///
        nzttB64Cert* next_nzttB64Cert;            ///
    }

    /**
    *
    */
    struct nzttPKCS7ProtInfo {
        nzttCipherType mictype_nzttPKCS7ProtInfo;    /// Hash cipher.
        nzttCipherType symmtype_nzttPKCS7ProtInfo;    /// Symmetric cipher.
        ub4 keylen_nzttPKCS7ProtInfo;            /// Length of key to use.
    }

    /**
    * Protection Information.
    *
    * Information specific to a type of protection.
    */
    union nzttProtInfo {
        nzttPKCS7ProtInfo pkcs7_nzttProtInfo;        ///
    }

    /**
    * A description of a persona so that the toolkit can create one.    A
    * persona can be symmetric or asymmetric and both contain an
    * identity.    The identity for an asymmetric persona will be the
    * certificate and the identity for the symmetric persona will be
    * descriptive information about the persona.    In either case, an
    * identity will have been created before the persona is created.
    *
    * A persona can be stored separately from the wallet that references
    * it.    By default, a persona is stored with the wallet (it inherits
    * with WRL used to open the wallet).    If a WRL is specified, then it
    * is used to store the actuall persona and the wallet will have a
    * reference to it.
    */
    struct nzttPersonaDesc {
        ub4 privlen_nzttPersonaDesc;            /// Length of private info (key).
        ub1* priv_nzttPersonaDesc;            /// Private information.
        ub4 prllen_nzttPersonaDesc;            /// Length of PRL.
        text* prl_nzttPersonaDesc;            /// PRL for storage.
        ub4 aliaslen_nzttPersonaDesc;            /// Length of alias.
        text* alias_nzttPersonaDesc;            /// Alias.
        ub4 longlen_nzttPersonaDesc;            /// Length of longer description.
        text* long_nzttPersonaDesc;            /// Longer persona description.
    }

    /**
    * A description of an identity so that the toolkit can create one.
    * Since an identity can be symmetric or asymmetric, the asymmetric
    * identity information will not be used when a symmetric identity is
    * created.    This means the publen_nzttIdentityDesc and
    * pub_nzttIdentityDesc members will not be used when creating a
    * symmetric identity.
    */
    struct nzttIdentityDesc {
        ub4 publen_nzttIdentityDesc;            /// Length of identity.
        ub1* pub_nzttIdentityDesc;            /// Type specific identity.
        ub4 dnlen_nzttIdentityDesc;            /// Length of alias.
        text* dn_nzttIdentityDesc;            /// Alias.
        ub4 longlen_nzttIdentityDesc;            /// Length of longer description.
        text* long_nzttIdentityDesc;            /// Longer description.
        ub4 quallen_nzttIdentityDesc;            /// Length of trust qualifier.
        text* trustqual_nzttIdentityDesc;        /// Trust qualifier.
    }

    /**
    * Open a wallet based on a wallet Resource Locator (WRL).
    *
    * The syntax for a WRL is <Wallet Type>:<Wallet Type Parameters>.
    *
    * Wallet Type    Wallet Type Parameters.
    * -----------    ----------------------
    * File        Pathname (e.g. "file:/home/asriniva")
    * Oracle    Connect string (e.g. "oracle:scott/tiger@oss")
    *
    * There are also defaults.    If the WRL is NZT_DEFAULT_WRL, then
    * the platform specific WRL default is used.    If only the wallet
    * type is specified, then the WRL type specific default is used
    * (e.g. "oracle:")
    *
    * There is an implication with Oracle that should be stated: An
    * Oracle based wallet can be implemented in a user's private space
    * or in world readable space.
    *
    * When the wallet is opened, the password is verified by hashing
    * it and comparing against the password hash stored with the
    * wallet.    The list of personas (and their associated identities)
    * is built and stored into the wallet structure.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wrllen = Length of WRL.
    *    wrl = WRL.
    *    pwdlen = Length of password.
    *    pwd = Password.
    *    wallet = Initialized wallet structure.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_RIO_OPEN    RIO could not open wallet (see network trace file).
    *    NZERROR_TK_PASSWORD    Password verification failed.
    *    NZERROR_TK_WRLTYPE    WRL type is not known.
    *    NZERROR_TK_WRLPARM    WRL parm does not match type.
    */
    extern (C) nzerror nztwOpenWallet (nzctx* osscntxt, ub4 wrllen, text* wrl, ub4 pwdlen, text* pwd, nzttWallet* wallet);

    /**
    * Close a wallet.
    *
    * Closing a wallet also closes all personas associated with that
    * wallet.    It does not cause a persona to automatically be saved
    * if it has changed.    The implication is that a persona can be
    * modified by an application but if it is not explicitly saved it
    * reverts back to what was in the wallet.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wallet = Wallet.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_RIO_CLOSE    RIO could not close wallet (see network trace file).
    */
    extern (C) nzerror nztwCloseWallet (nzctx* osscntxt, nzttWallet* wallet);

    /**
    * This function shouldn't be called.    It's a temporary Oracle hack.
    */

    /+
    /**
    *
    */
    extern (C) nzerror nztwConstructWallet (nzctx* oss_context, nzttPolicy openPolicy, nzttPolicy securePolicy, ub1* ldapName, ub4 ldapNamelen, nzstrc* wrl, nzttPersona* personas, nzttWallet** wallet );
    +/

    /**
    * Retrieve a persona from wallet.
    *
    * Retrieves a persona from the wallet based on the index number passed
    * in.    This persona is a COPY of the one stored in the wallet, therefore
    * it is perfectly fine for the wallet to be closed after this call is
    * made.
    *
    * The caller is responsible for disposing of the persona when completed.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wallet = Wallet.
    *    index = Which wallet index to remove (first persona is zero).
    *    persona = Persona found.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztwRetrievePersonaCopy (nzctx* osscntxt, nzttWallet* wallet, ub4 index, nzttPersona** persona);

    /**
    * Retrieve a persona based on its name.
    *
    * Retrieves a persona from the wallet based on the name of the persona.
    * This persona is a COPY of the one stored in the wallet, therefore
    * it is perfectly fine for the wallet to be closed after this call is
    * made.
    *
    * The caller is responsible for disposing of the persona when completed.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wallet = Wallet.
    *    name = Name of the persona
    *    persona = Persona found.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztwRetrievePersonaCopyByName(nzctx* osscntxt, nzttWallet* wallet, char* name, nzttPersona** persona);

    /**
    * Open a persona.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_PASSWORD    Password failed to decrypt persona.
    *    NZERROR_TK_BADPRL    Persona resource locator did not work.
    *    NZERROR_RIO_OPEN    Could not open persona (see network trace file).
    */
    extern (C) nzerror nzteOpenPersona (nzctx* osscntxt, nzttPersona* persona);

    /**
    * Close a persona.
    *
    * Closing a persona does not store the persona, it simply releases
    * the memory associated with the crypto engine.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nzteClosePersona (nzctx* osscntxt, nzttPersona* persona);

    /**
    * Destroy a persona.
    *
    * The persona is destroyed in the open state, but it will
    * not be associated with a wallet.
    *
    * The persona parameter is doubly indirect so that at the
    * conclusion of the function, the pointer can be set to null.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_TYPE        Unsupported itype/ctype combination.
    *    NZERROR_TK_PARMS    Error in persona description.
    */
    extern (C) nzerror nzteDestroyPersona (nzctx* osscntxt, nzttPersona** persona);

    /**
    * Retrieve a trusted identity from a persona.
    *
    * Retrieves a trusted identity from the persona based on the index
    * number passed in.    This identity is a copy of the one stored in
    * the persona, therefore it is perfectly fine to close the persona
    * after this call is made.
    *
    * The caller is responsible for freeing the memory of this object
    * by calling nztiAbortIdentity it is no longer needed.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    index = Which wallet index to remove (first element is zero).
    *    identity = Trusted Identity from this persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nzteRetrieveTrustedIdentCopy (nzctx* osscntxt, nzttPersona* persona, ub4 index, nzttIdentity** identity);

    /**
    * Get the decrypted Private Key for the Persona.
    *
    * This function will only work for X.509 based persona which contain
    * a private key.
    * A copy of the private key is returned to the caller so that they do not
    * have to worry about the key changing "underneath them."
    * Memory will be allocated for the vkey and therefore, the caller
    * will be responsible for freeing this memory.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    vkey = Private Key [B_KEY_OBJ].
    *    vkey_len = Private Key Length.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_NO_MEMORY    ossctx is null.
    *    NZERROR_TK_BADPRL    Persona resource locator did not work.
    */
    extern (C) nzerror nztePriKey (nzctx* osscntxt, nzttPersona* persona, ub1** vkey, ub4* vkey_len);

    /**
    * Get the X.509 Certificate for a persona.
    *
    * This funiction will only work for X.509 based persona which contain
    * a certificate for the self identity.
    * A copy of the certificate is returned to the caller so that they do not
    * have to worry about the certificate changing "underneath them."
    * Memory will be allocated for the cert and therefore, the caller
    * will be responsible for freeing this memory.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    cert = X.509 Certificate [BER encoded].
    *    cert_len = Certificate length.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_NO_MEMORY    ossctx is null.
    */
    extern (C) nzerror nzteMyCert (nzctx* osscntxt, nzttPersona* persona, ub1** cert, ub4* cert_len);

    /**
    * Create a persona gives a BER X.509 cert.
    *
    * Memory will be allocated for the persona and therefore, the caller
    * will be responsible for freeing this memory.
    *
    * Params:
    *    osscntxt = OSS context.
    *    cert = X.509 Certificate [BER encoded].
    *    cert_len = Certificate length.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_NO_MEMORY    ossctx is null.
    */
    extern (C) nzerror nzteX509CreatePersona (nzctx* osscntxt, ub1* cert, ub4 cert_len, nzttPersona** persona);

    /**
    * Create an identity.
    *
    * Memory is only allocated for the identity structure.    The elements in
    * the description struct are not copied.    Rather their pointers are copied
    * into the identity structure.    Therefore, the caller should not free
    * the elements referenced by the description.    These elements will be freed
    * when nztiDestroyIdentity is called.
    *
    * Params:
    *    osscntxt = OSS context.
    *    itype = Identity type.
    *    desc = Description of identity.
    *    identity = Identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_PARMS        Error in description.
    */
    extern (C) nzerror nztiCreateIdentity (nzctx* osscntxt, nzttVersion itype, nzttIdentityDesc* desc, nzttIdentity** identity);

    version (NZ_OLD_TOOLS) {

    /**
    * Duplicate an identity.
    *
    * Memory for the identity is allocated inside the function, and all
    * internal identity elements as well.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Target Identity.
    *    new_identity = New Identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTFOUND    Identity not found.
    *    NZERROR_PARMS        Error in description.
    */
    extern (C) nzerror nztiDuplicateIdentity (nzctx* osscntxt, nzttIdentity* identity, nzttIdentity** new_identity);

    }

    /**
    * Abort an unassociated identity.
    *
    * It is an error to try to abort an identity that can be
    * referenced through a persona.
    *
    * The identity pointer is set to null at the conclusion.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_CANTABORT    Identity is associated with persona.
    */
    extern (C) nzerror nztiAbortIdentity (nzctx* osscntxt, nzttIdentity** identity);

    version (NZ_OLD_TOOLS) {

    /**
    * Get an Identity Description from an identity.
    *
    * Memory is allocated for the Identity Description. It
    * is the caller's responsibility to free this memory by calling
    * nztiFreeIdentityDesc.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity.
    *    description = Identity Description.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztidGetIdentityDesc (nzctx* osscntxt, nzttIdentity* identity, nzttIdentityDesc** description);

    /**
    * Free memory from an Identity Description object.
    *
    * Memory is freed for all Identity Description elements.    The pointer is then set to null.
    *
    * PARAMETERS
    *        osscntxt = OSS context.
    *        description = Identity Description.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztidFreeIdentityDesc (nzctx* osscntxt, nzttIdentityDesc** description);

    }

    /**
    * Free the contents of an identity.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity to free.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztific_FreeIdentityContent (nzctx* ossctx, nzttIdentity* identity);

    /**
    * Create an attached signature.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Open persona acting as signer.
    *    state = State of signature.
    *    inlen = Length of this input part.
    *    input = This input part.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow output buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztSign (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /*
    * Verify an attached signature.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of verification.
    *    intdulen = TDU length.
    *    intdu = TDU.
    *    output = Extracted message.
    *    verified = TRUE if signature verified.
    *    validated = TRUE if signing identity validated.
    *    identity = Identity of signing party.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow outptu buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztVerify (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 intdulen, ub1* intdu, nzttBufferBlock* output, boolean* verified, boolean* validated, nzttIdentity** identity);

    /**
    * Validate an identity.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    identity = Identity.
    *    validated = TRUE if identity was validated.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztValidate (nzctx* osscntxt, nzttPersona* persona, nzttIdentity* identity, boolean* validated);

    /**
    * Generate a detached signature.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of signature.
    *    inlen = Length of this input part.
    *    input = The input.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow output buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztsd_SignDetached (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /**
    * Verify a detached signature.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of verification.
    *    inlen = Length of data.
    *    input = Data.
    *    intdulen = Input TDU length.
    *    tdu = Input TDU.
    *    verified = TRUE if signature verified.
    *    validated = TRUE if signing identity validated.
    *    identity = Identity of signing party.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztved_VerifyDetached (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, ub4 intdulen, ub1* tdu, boolean* verified, boolean* validated, nzttIdentity** identity);

    /**
    * Encrypt data symmetrically, encrypt key asymmetrically
    *
    * There is a limitation of 1 recipient (nrecipients = 1) at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    nrecipients = Number of recipients for this encryption.
    *    recipients = List of recipients.
    *    state = State of encryption.
    *    inlen = Length of this input part.
    *    input = The input.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow output buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztkec_PKEncrypt (nzctx* osscntxt, nzttPersona* persona, ub4 nrecipients, nzttIdentity* recipients, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /**
    * Determine the buffer size needed for PKEncrypt.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    nrecipients = Number of recipients.
    *    inlen = Length of input.
    *    tdulen = Length of buffer need.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxkec_PKEncryptExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 nrecipients, ub4 inlen, ub4* tdulen);

    /**
    * Decrypt a PKEncrypted message.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of encryption.
    *    inlen = Length of this input part.
    *    input = The input.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow output buffer but couldn't.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztkdc_PKDecrypt (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /**
    * Generate a hash.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of hash.
    *    inlen = Length of this input.
    *    input = The input.
    *    tdu = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztHash (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdu);

    /**
    * Seed the random function.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    seedlen = Length of seed.
    *    seed = Seed.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztSeedRandom (nzctx* osscntxt, nzttPersona* persona, ub4 seedlen, ub1* seed);

    /**
    * Generate a buffer of random bytes.
    *
    * Params:
    *        osscntxt = OSS context.
    *        persona = Persona.
    *        nbytes = Number of bytes desired.
    *        output = Buffer block for bytes.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztrb_RandomBytes (nzctx* osscntxt, nzttPersona* persona, ub4 nbytes, nzttBufferBlock* output);

    /**
    * Generate a random number.
    *
    * Params:
    *        osscntxt = OSS context.
    *        persona = Persona.
    *        num = Number.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztrn_RandomNumber (nzctx* osscntxt, nzttPersona* persona, uword* num);

    /**
    * Initialize a buffer block.
    *
    * The buffer block is initialized to be empty (all members are set
    * to 0/null).    Such a block will be allocated memory as needed.
    *
    * Params:
    *    osscntxt = OSS context.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbInitBlock (nzctx* osscntxt, nzttBufferBlock* block);

    /**
    * Reuse an already initialized and possibly used block.
    *
    * This function simply sets the used length member of the buffer
    * block to 0.    If the block already has memory allocated to it,
    * this will cause it to be reused.
    *
    * Params:
    *    osscntxt = OSS context.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbReuseBlock (nzctx* osscntxt, nzttBufferBlock* block);

    /**
    * Resize an initialized block to a particular size.
    *
    * Params:
    *    osscntxt = OSS context.
    *    len = Minimum number of unused bytes desired.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbSizeBlock (nzctx* osscntxt, ub4 len, nzttBufferBlock* block);

    /**
    * Increase the size of a buffer block.
    *
    * Params:
    *    osscntxt = OSS context.
    *    inc = Number of bytes to increase.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbGrowBlock (nzctx* osscntxt, ub4 inc, nzttBufferBlock* block);

    /**
    * Purge a buffer block of its memory.
    *
    * The memory used by the buffer block as the buffer is released.
    * The buffer block itself is not affected.
    *
    * Params:
    *    osscntxt = OSS context.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbPurgeBlock (nzctx* osscntxt, nzttBufferBlock* block);

    /**
    * Set a buffer block to a known state.
    *
    * If buflen > 0, objlen == 0, and obj == null, then buflen bytes
    * of memory is allocated and a pointer is stored in the buffer
    * block.
    *
    * The buffer parameter remains unchanged.
    *
    * Params:
    *    osscntxt = OSS context.
    *    flags = Flags to set.
    *    buflen = Length of buffer.
    *    usedlen = Used length.
    *    buffer = Buffer.
    *    block = Buffer block.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztbbSetBlock (nzctx* osscntxt, uword flags, ub4 buflen, ub4 usedlen, ub1* buffer, nzttBufferBlock* block);

    /**
    * Get some security information for SSL.
    *
    * This function allocate memories for issuername, certhash, and dname.
    * To deallocate memory for those params, you should call nztdbuf_DestroyBuf.
    *
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    dname = Distinguished name of the certificate.
    *    dnamelen = Length of the distinguished name.
    *    issuername = Issuer name of the certificate.
    *    certhash = SHA1 hash of the certificate.
    *    certhashlen = Length of the hash.
    *
    * Returns:
    *
    */
    extern (C) nzerror nztiGetSecInfo (nzctx* osscntxt, nzttPersona* persona, text** dname, ub4* dnamelen, text** issuername, ub4*, ub1**, ub4*);

    /**
    * Get the distinguished name for the given identity.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity to get dname from.
    *    dn = Distinguished name.
    *    dnlen = Length of the dname.
    *
    * Returns:
    *
    */
    extern (C) nzerror nztiGetDName (nzctx* osscntxt, nzttIdentity* identity, text** dn, ub4* dnlen);

    /**
    * Get the IssuerName of an identity.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity need to get issuername from
    *    issuername = Issuer's name
    *    issuernamelen = Length of the issuer's name
    *
    * Returns:
    *
    */
    extern (C) nzerror nztiGetIssuerName (nzctx* osscntxt, nzttIdentity* identity, text** issuername, ub4* issuernamelen);

    /**
    * Get the SHA1 hash for the certificate of an identity.
    *
    * Need to call nztdbuf_DestroyBuf to deallocate memory for certHash.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity need to get issuername from.
    *    certHash = SHA1 hash buffer.
    *    hashLen = Length of the certHash.
    *
    * Returns:
    *
    */
    extern (C) nzerror nztgch_GetCertHash (nzctx* osscntxt, nzttIdentity* identity, ub1** certHash, ub4* hashLen);

    /**
    * Deallocate a ub1 or text buffer.
    *
    * Params:
    *    osscntxt = OSS context.
    *    buf = Allocated buffer to be destroyed.
    *
    * Returns:
    *
    */
    extern (C) nzerror nztdbuf_DestroyBuf (nzctx* osscntxt, dvoid** buf);

    /**
    *
    *
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    *
    * Params:
    *    osscntxt = OSS context.
    *
    * Returns:
    *
    */
    extern (C) nzerror nztGetCertChain (nzctx* osscntxt, nzttWallet* );

    /**
    *
    *
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    *
    * Params:
    *    osscntxt = OSS context.
    *    dn1 = Distinguished name 1.
    *    dn2 = Distinguished name 2.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztCompareDN (nzctx* osscntxt, ub1*, ub4,    ub1 *, ub4, boolean*);

    version (NZ_OLD_TOOLS) {

    /**
    * Allocate memory for nzttIdentity context.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = nzttIdentity context
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztIdentityAlloc (nzctx* osscntxt, nzttIdentity** identity);

    /**
    * Allocate memory for nzttIdentityPrivate.
    *
    * Params:
    *    osscntxt = OSS context.
    *    ipriv = identityPrivate structure.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztIPrivateAlloc (nzctx* osscntxt, nzttIdentityPrivate** ipriv);

    /**
    *
    *
    * Params:
    *    osscntxt = OSS context.
    *    targetIdentity = Target identity.
    *    sourceIdentity = Source identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztIDupContent (nzctx* osscntxt, nzttIdentity* targetIdentity, nzttIdentity* sourceIdentity);

    /**
    *
    *
    * Params:
    *    osscntxt = OSS context.
    *    target_ipriv = Target identityPrivate.
    *    source_ipriv = Source identityPrivate.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztIPDuplicate (nzctx* osscntxt, nzttIdentityPrivate** target_ipriv, nzttIdentityPrivate* source_ipriv);

    /**
    *
    *
    * Params:
    *    osscntxt = OSS context.
    *    source_identities = Source identity list.
    *    numIdent = Number of identity in the list.
    *    ppidentity = Target of identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztiDupIdentList (nzctx* osscntxt, nzttIdentity* source_identities, ub4* numIdent, nzttIdentity** ppidentity);

    /**
    * Free memory for a list of Identities.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = identity context
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztFreeIdentList (nzctx* osscntxt, nzttIdentity** identity);

    }

    /**
    * Check the validity of a certificate.
    *
    * Params:
    *    osscntxt = OSS context.
    *    start_time = Start time of the certificate.
    *    end_time = End time of the certificate.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    others            Failure.
    */
    extern (C) nzerror nztCheckValidity (nzctx* osscntxt, ub4 start_time, ub4 end_time);

    /**
    * Create a new wallet.
    *
    * It is an error to try to create a wallet that already exists.    The
    * existing wallet must be destroyed first.
    *
    * The wallet itself is not encrypted.    Rather, all the personas in the
    * wallet are encrypted under the same password.    A hash of the password
    * is stored in the wallet.
    *
    * Upon success, an empty open wallet is stored in the wallet parameter.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wrllen = Length of wallet resource locator.
    *    wrl = WRL.
    *    pwdlen = Length of password (see notes below).
    *    pwd = Password.
    *    wallet = Wallet.
    *
    * Returns:
    *    NZERROR_OK            Success.
    *    NZERROR_TK_WALLET_EXISTS    Wallet already exists.
    *    NZERROR_RIO_OPEN        RIO could not create wallet (see trace file).
    */
    extern (C) nzerror nztwCreateWallet (nzctx* osscntxt, ub4 wrllen, text* wrl, ub4 pwdlen, text* pwd, nzttWallet* wallet);

    /**
    * Destroy an existing wallet.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    wrllen = Length of wallet resource locator.
    *    wrl = WRL.
    *    pwdlen = Length of password.
    *    pwd = Password.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_PASSWORD    Password verification failed.
    *    NZERROR_RIO_OPEN    RIO could not open wallet (see trace file).
    *    NZERROR_RIO_DELETE    Delete failed (see trace file).
    */
    extern (C) nzerror nztwDestroyWallet (nzctx* osscntxt, ub4 wrllen, text* wrl, ub4 pwdlen, text* pwd);

    /**
    * Store an open persona in a wallet.
    *
    * If the open persona is not associated with any wallet (it was
    * created via the nzteClosePersona function), then storing the
    * persona creates that association.    The wallet will also have an
    * updated persona list that reflects this association.
    *
    * If the open persona was associated with wallet 'A' (it was
    * opened via the nztwOpenWallet function), and is stored back into
    * wallet 'A', then then the old persona is overwritten by the new
    * persona if the password can be verified.    Recall that all
    * personas have a unique identity id.    If that id changes then
    * storing the persona will put a new persona in the wallet.
    *
    * If the open persona was associated with wallet 'A' and is stored
    * into wallet 'B', and if wallet 'B' does not contain a persona
    * with that unique identity id, then the persona will be copied
    * into wallet 'B', wallet 'B''s persona list will be updated, and
    * the persona structure will be updated to be associated with
    * wallet 'B'.    If wallet 'B' already contained the persona, it
    * would be overwritten by the new persona.
    *
    * The persona parameter is doubly indirect so that at the
    * conclusion of the function call, the pointer can be directed to
    * the persona in the wallet.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    wallet = Wallet.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_PASSWORD    Password verification failed.
    *    NZERROR_RIO_STORE    Store failed (see network trace file).
    */
    extern (C) nzerror nzteStorePersona (nzctx* osscntxt, nzttPersona** persona, nzttWallet* wallet);

    /**
    * Remove a persona from the wallet.
    *
    * The password is verified before trying to remove the persona.
    *
    * If the persona is open, it is closed.    The persona is removed
    * from the wallet list and the persona pointer is set to null.
    *
    * A double indirect pointer to the persona is required so that the
    * persona pointer can be set to null upon completion.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_PASSWORD    Password verification failed.
    *    NZERROR_RIO_DELETE    Delete failed.
    */
    extern (C) nzerror nzteRemovePersona (nzctx* osscntxt, nzttPersona** persona);

    /**
    * Create a persona.
    *
    * The resulting persona is created in the open state, but it will
    * not be associated with a wallet.
    *
    * The memory for the persona is allocated by the function.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    itype = Identity type.
    *    ctype = Cipher type.
    *    desc = Persona description.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_TYPE        Unsupported itype/ctype combination.
    *    NZERROR_TK_PARMS    Error in persona description.
    */
    extern (C) nzerror nzteCreatePersona (nzctx* osscntxt, nzttVersion itype, nzttCipherType ctype, nzttPersonaDesc* desc, nzttPersona** persona);

    /**
    * Store an identity into a persona.
    *
    * The identity is not saved with the persona in the wallet until
    * the persona is stored.
    *
    * The identity parameter is double indirect so that it can point
    * into the persona at the conclusion of the call.
    *
    * Params:
    *    osscntxt = Success.
    *    identity = Trusted Identity.
    *    persona = Persona.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztiStoreTrustedIdentity (nzctx* osscntxt, nzttIdentity** identity, nzttPersona* persona);

    /**
    * Set the protection type for a CE function.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona    = Persona.
    *    func = CE function.
    *    tdufmt = TDU Format.
    *    protinfo = Protection information specific to this format.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_PROTECTION    Unsupported protection.
    *    NZERROR_TK_PARMS    Error in protection info.
    */
    extern (C) nzerror nzteSetProtection (nzctx* osscntxt, nzttPersona* persona, nzttcef func, nztttdufmt tdufmt, nzttProtInfo* protinfo);

    /**
    * Get the protection type for a CE function.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    func = CE function.
    *    tdufmt = TDU format.
    *    protinfo = Protection information.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nzteGetProtection (nzctx* osscntxt, nzttPersona* persona, nzttcef func, nztttdufmt* tdufmt, nzttProtInfo* protinfo);

    /**
    * Remove an identity from an open persona.
    *
    * If the persona is not stored, this identity will still be in the
    * persona stored in the wallet.
    *
    * The identity parameter is doubly indirect so that at the
    * conclusion of the function, the pointer can be set to null.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    identity = Identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTFOUND    Identity not found.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    */
    extern (C) nzerror nztiRemoveIdentity (nzctx* osscntxt, nzttIdentity** identity);

    /**
    * Create an Identity From a Distinguished Name.
    *
    * PARAMETERS
    *        osscntxt = OSS context.
    *        length = Length of distinguished_name.
    *        distinguished_name = Distinguished Name string.
    *        ppidentity = Created identity.
    *
    * Returns:
    *    NZERROR_OK        Success.
    */
    extern (C) nzerror nztifdn (nzctx* ossctx, ub4 length, text* distinguished_name, nzttIdentity** ppidentity);

    /**
    * Determine the size of the attached signature buffer.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Parameters:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    inlen = Length of input.
    *    tdulen = Buffer needed for signature.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxSignExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 inlen, ub4* tdulen);

    /**
    * Determine the size of buffer needed.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    inlen = Length of input.
    *    tdulen = Buffer needed for signature.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxsd_SignDetachedExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 inlen, ub4* tdulen);

    /**
    * Symmetrically encrypt.
    *
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = ?    Is this even state    ?
    *    inlen = Length of this input part.
    *    input = This input part.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztEncrypt (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /**
    * Determine the size of the TDU to encrypt.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    inlen = Length of this input part.
    *    tdulen = Length of TDU.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxEncryptExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 inlen, ub4* tdulen);

    /**
    * Decrypt an encrypted message.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of decryption.
    *    inlen = Length of this input part.
    *    input = This input part.
    *    output = Decrypted message.
    *
    * Returns:
    *    NZERROR_OK                        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN        Persona is not open.
    *    NZERROR_TK_NOTSUPP        Function not supported with persona.
    */
    extern (C) nzerror nztDecrypt (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* output);

    /**
    * Sign and PKEncrypt a message.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    nrecipients = Number of recipients for this encryption.
    *    recipients = List of recipients.
    *    state = State of encryption.
    *    inlen = Length of this input part.
    *    input = This input part.
    *    tdubuf = TDU buffer.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow output buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztEnvelope (nzctx* osscntxt, nzttPersona* persona, ub4 nrecipients, nzttIdentity* recipients, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdubuf);

    /**
    * PKDecrypt and verify a message.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of encryption.
    *    inlen = Length of this input part.
    *    input = This input part.
    *    output = Message from TDU.
    *    verified = TRUE if verified.
    *    validated = TRUE if validated.
    *    sender = Identity of sender.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztDeEnvelope (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* output, boolean* verified, boolean* validated, nzttIdentity** sender);

    /**
    * Generate a keyed hash.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    state = State of hash.
    *    inlen = Length of this input.
    *    input = This input.
    *    tdu = Output tdu.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_CANTGROW    Needed to grow TDU buffer but could not.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztKeyedHash (nzctx* osscntxt, nzttPersona* persona, nzttces state, ub4 inlen, ub1* input, nzttBufferBlock* tdu);

    /**
    * Determine the space needed for a keyed hash.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    inlen = Length of this input.
    *    tdulen = TDU length.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxKeyedHashExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 inlen, ub4* tdulen);

    /**
    * Determine the size of the TDU for a hash.
    *
    * Bugs:
    *    This function is unsupported at this time.
    *
    * Params:
    *    osscntxt = OSS context.
    *    persona = Persona.
    *    inlen = Length of this input.
    *    tdulen = TDU length.
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_NOTOPEN    Persona is not open.
    *    NZERROR_TK_NOTSUPP    Function not supported with persona.
    */
    extern (C) nzerror nztxHashExpansion (nzctx* osscntxt, nzttPersona* persona, ub4 inlen, ub4* tdulen);

    /**
    * Check to see if authentication is enabled in the current Cipher Spec.
    *
    * Params:
    *    ctx = Oracle SSL context.
    *    ncipher = CipherSuite.
    *    authEnabled = Boolean for is Auth Enabled?
    *
    * Returns:
    *            NZERROR_OK        Success.
    *            NZERROR_TK_INV_CIPHR_TYPE Cipher Spec is not recognized.
    */
    extern (C) nzerror nztiae_IsAuthEnabled (nzctx* ctx, ub2 ncipher, boolean* authEnabled);

    /**
    * Check to see if encryption is enabled in the current Cipher Spec.
    *
    * Params:
    *    ctx = Oracle SSL context.
    *    ncipher = CipherSuite.
    *    encrEnabled = Boolean for is Auth Enabled?
    *
    * Returns:
    *            NZERROR_OK        Success.
    *            NZERROR_TK_INV_CIPHR_TYPE Cipher Spec is not recognized.
    */
    extern (C) nzerror nztiee_IsEncrEnabled (nzctx* ctx, ub2 ncipher, boolean* encrEnabled);

    /**
    * Check to see if hashing is enabled in the current Cipher Spec.
    *
    * Params:
    *    ctx = Oracle SSL context.
    *    ncipher = CipherSuite.
    *    hashEnabled = Boolean for is Auth Enabled?
    *
    * Returns:
    *    NZERROR_OK        Success.
    *    NZERROR_TK_INV_CIPHR_TYPE Cipher Spec is not recognized.
    */
    extern (C) nzerror nztihe_IsHashEnabled (nzctx* ctx, ub2 ncipher, boolean* hashEnabled);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetIssuerName (nzctx*, nzttIdentity*, ub1**, ub4*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetSubjectName (nzctx*, nzttIdentity*, ub1**, ub4*);


    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetBase64Cert (nzctx*, nzttIdentity*, ub1**, ub4*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetSerialNumber (nzctx*, nzttIdentity*, ub1**, ub4*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetValidDate (nzctx*, nzttIdentity*, ub4*, ub4*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetVersion (nzctx*, nzttIdentity*, nzstrc*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGetPublicKey (nzctx*, nzttIdentity*, ub1**, ub4*);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztGenericDestroy (nzctx*, ub1**);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztSetAppDefaultLocation (nzctx*, text*, size_t);

    /**
    * Bugs:
    *    An unknown parameter is missing from the documentation.
    */
    extern (C) nzerror nztSearchNZDefault (nzctx*, boolean*);


    /**
    * Macro to convert SSL errors to Oracle errors. As SSL errors are negative
    * and Oracle numbers are positive, the following needs to be done.
    * 1. The base error number, which is the highest, is added to the
    *        SSL error to get the index into the number range.
    * 2. The result is added to the base Oracle number to get the Oracle error.
    *
    * Bugs:
    *    This cannot work until we have SSL in D.
    */
    nzerror NZERROR_SSL_TO_ORACLE (int ssl_error) {
        return nzerror.NZERROR_SSLUnknownErr;
    //    return ssl_error == SSLNoErr ? nzerror.NZERROR_OK : cast(nzerror)(ssl_error - SSLMemoryErr + cast(size_t)nzerror.NZERROR_SSLMemoryErr);
    }


    /**
    * Abort a direct path operation.
    *
    * Upon successful completion the direct path context is no longer valid.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathAbort (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Execute a data save point.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *    action =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathDataSave (OCIDirPathCtx* dpctx, OCIError* errhp, ub4 action);

    /**
    * Finish a direct path operation.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathFinish (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Flush a partial row from the server.
    *
    * Params:
    *    dpctx =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathFlushRow (OCIDirPathCtx* dpctx, OCIError* errhp);

    /**
    * Prepare a direct path operation.
    *
    * Params:
    *    dpctx =
    *    svchp =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathPrepare (OCIDirPathCtx* dpctx, OCISvcCtx* svchp, OCIError* errhp);

    /**
    * Load a direct path stream.
    *
    * Params:
    *    dpctx =
    *    dpstr =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathLoadStream (OCIDirPathCtx* dpctx, OCIDirPathStream* dpstr, OCIError* errhp);

    /**
    * Get column array entry.
    *
    * Deprecated:
    *    Use OCIDirPathColArrayRowGet instead.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    colIdx =
    *    cvalpp =
    *    clenp =
    *    cflgp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayEntryGet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub2 colIdx, ub1** cvalpp, ub4* clenp, ub1* cflgp);

    /**
    * Set column array entry.
    *
    * Deprecated:
    *    Use OCIDirPathColArrayRowGet instead.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    colIdx =
    *    cvalp =
    *    clenp =
    *    clen =
    *    cflgp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayEntrySet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub2 colIdx, ub1* cvalp, ub4 clen, ub1 cflg);

    /**
    * Get column array row pointers.
    *
    * Params:
    *    dpca =
    *    errhp =
    *    rownum =
    *    cvalppp =
    *    clenpp =
    *    cflgpp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayRowGet (OCIDirPathColArray* dpca, OCIError* errhp, ub4 rownum, ub1*** cvalppp, ub4** clenpp, ub1** cflgpp);

    /**
    * Reset column array state.
    *
    * Resetting the column array state is necessary when piecing in a large
    * column and an error occurs in the middle of loading the column.
    *
    * Params:
    *    dpca =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayReset (OCIDirPathColArray* dpca, OCIError* errhp);

    /**
    * Convert column array to stream format.
    *
    * Params:
    *    dpca =
    *    dpctx =
    *    dpstr =
    *    errhp =
    *    rowcnt =
    *    rowoff =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathColArrayToStream (OCIDirPathColArray* dpca, OCIDirPathCtx* dpctx, OCIDirPathStream* dpstr, OCIError* errhp, ub4 rowcnt, ub4 rowoff);

    /**
    *
    *
    * Params:
    *    dpstr =
    *    errhp =
    *
    * Returns:
    *    An OCI error code.
    */
    extern (C) sword OCIDirPathStreamReset (OCIDirPathStream* dpstr, OCIError* errhp);


    /*****************************************************************************
                            DESCRIPTION
    ******************************************************************************
    Note: the descriptions of the functions are alphabetically arranged. Please
    maintain the arrangement when adding a new function description. The actual
    prototypes are below this comment section and do not follow any alphabetical
    ordering.


    --------------------------------OCIAttrGet------------------------------------

    OCIAttrGet()
    Name
    OCI Attribute Get
    Purpose
    This call is used to get a particular attribute of a handle.
    Syntax
    sword OCIAttrGet ( CONST dvoid        *trgthndlp,
            ub4                        trghndltyp,
            dvoid                    *attributep,
            ub4                        *sizep,
            ub4                        attrtype,
            OCIError                *errhp );
    Comments
    This call is used to get a particular attribute of a handle.
    See Appendix B,    "Handle Attributes",    for a list of handle types and their
    readable attributes.
    Parameters
    trgthndlp (IN) - is the pointer to a handle type.
    trghndltyp (IN) - is the handle type.
    attributep (OUT) - is a pointer to the storage for an attribute value. The
    attribute value is filled in.
    sizep (OUT) - is the size of the attribute value.
    This can be passed in as NULL for most parameters as the size is well known.
    For text* parameters, a pointer to a ub4 must be passed in to get the length
    of the string.
    attrtype (IN) - is the type of attribute.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    Related Functions
    OCIAttrSet()

    --------------------------------OCIAttrSet------------------------------------


    OCIAttrSet()
    Name
    OCI Attribute Set
    Purpose
    This call is used to set a particular attribute of a handle or a descriptor.
    Syntax
    sword OCIAttrSet ( dvoid                *trgthndlp,
            ub4                    trghndltyp,
            dvoid                *attributep,
            ub4                    size,
            ub4                    attrtype,
            OCIError        *errhp );
    Comments
    This call is used to set a particular attribute of a handle or a descriptor.
    See Appendix B for a list of handle types and their writeable attributes.
    Parameters
    trghndlp (IN/OUT) - the pointer to a handle type whose attribute gets
    modified.
    trghndltyp (IN/OUT) - is the handle type.
    attributep (IN) - a pointer to an attribute value.
    The attribute value is copied into the target handle. If the attribute value
    is a pointer, then only the pointer is copied, not the contents of the pointer.
    size (IN) - is the size of an attribute value. This can be passed in as 0 for
    most attributes as the size is already known by the OCI library. For text*
    attributes, a ub4 must be passed in set to the length of the string.
    attrtype (IN) - the type of attribute being set.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    Related Functions
    OCIAttrGet()



    --------------------------------OCIBindArrayOfStruct--------------------------



    OCIBindArrayOfStruct()
    Name
    OCI Bind for Array of Structures
    Purpose
    This call sets up the skip parameters for a static array bind.
    Syntax
    sword OCIBindArrayOfStruct ( OCIBind            *bindp,
                    OCIError        *errhp,
                    ub4                    pvskip,
                    ub4                    indskip,
                    ub4                    alskip,
                    ub4                    rcskip );
    Comments
    This call sets up the skip parameters necessary for a static array bind.
    This call follows a call to OCIBindByName() or OCIBindByPos(). The bind
    handle returned by that initial bind call is used as a parameter for the
    OCIBindArrayOfStruct() call.
    For information about skip parameters, see the section "Arrays of Structures"
    on page 4-16.
    Parameters
    bindp (IN) - the handle to a bind structure.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    pvskip (IN) - skip parameter for the next data value.
    indskip (IN) - skip parameter for the next indicator value or structure.
    alskip (IN) - skip parameter for the next actual length value.
    rcskip (IN) - skip parameter for the next column-level return code value.
    Related Functions
    OCIAttrGet()


    --------------------------------OCIBindByName---------------------------------

    OCIBindByName()
    Name
    OCI Bind by Name
    Purpose
    Creates an association between a program variable and a placeholder in a SQL
    statement or PL/SQL block.
    Syntax
    sword OCIBindByName (
                    OCIStmt                *stmtp,
                    OCIBind                **bindp,
                    OCIError            *errhp,
                    CONST OraText        *placeholder,
                    sb4                        placeh_len,
                    dvoid                    *valuep,
                    sb4                        value_sz,
                    ub2                        dty,
                    dvoid                    *indp,
                    ub2                        *alenp,
                    ub2                        *rcodep,
                    ub4                        maxarr_len,
                    ub4                        *curelep,
                    ub4                        mode );





    Description
    This call is used to perform a basic bind operation. The bind creates an
    association between the address of a program variable and a placeholder in a
    SQL statement or PL/SQL block. The bind call also specifies the type of data
    which is being bound, and may also indicate the method by which data will be
    provided at runtime.
    This function also implicitly allocates the bind handle indicated by the bindp
    parameter.
    Data in an OCI application can be bound to placeholders statically or
    dynamically. Binding is static when all the IN bind data and the OUT bind
    buffers are well-defined just before the execute. Binding is dynamic when the
    IN bind data and the OUT bind buffers are provided by the application on
    demand at execute time to the client library. Dynamic binding is indicated by
    setting the mode parameter of this call to OCI_DATA_AT_EXEC.
    Related Functions: For more information about dynamic binding, see
    the section "Runtime Data Allocation and Piecewise Operations" on
    page 5-16.
    Both OCIBindByName() and OCIBindByPos() take as a parameter a bind handle,
    which is implicitly allocated by the bind call A separate bind handle is
    allocated for each placeholder the application is binding.
    Additional bind calls may be required to specify particular attributes
    necessary when binding certain data types or handling input data in certain
    ways:
    If arrays of structures are being utilized, OCIBindArrayOfStruct() must
    be called to set up the necessary skip parameters.
    If data is being provided dynamically at runtime, and the application
    will be using user-defined callback functions, OCIBindDynamic() must
    be called to register the callbacks.
    If a named data type is being bound, OCIBindObject() must be called to
    specify additional necessary information.
    Parameters
    stmth (IN/OUT) - the statement handle to the SQL or PL/SQL statement
    being processed.
    bindp (IN/OUT) - a pointer to a pointer to a bind handle which is implicitly
    allocated by this call.    The bind handle    maintains all the bind information
    for this particular input value. The handle is feed implicitly when the
    statement handle is deallocated.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    placeholder (IN) - the placeholder attributes are specified by name if
    ocibindn() is being called.
    placeh_len (IN) - the length of the placeholder name specified in placeholder.
    valuep (IN/OUT) - a pointer to a data value or an array of data values of the
    type specified in the dty parameter. An array of data values can be specified
    for mapping into a PL/SQL table or for providing data for SQL multiple-row
    operations. When an array of bind values is provided, this is called an array
    bind in OCI terms. Additional attributes of the array bind (not bind to a
    column of ARRAY type) are set up in OCIBindArrayOfStruct() call.
    For a REF, named data type    bind, the valuep parameter is used only for IN
    bind data. The pointers to OUT buffers are set in the pgvpp parameter
    initialized by OCIBindObject(). For named data type and REF binds, the bind
    values are unpickled into the Object Cache. The OCI object navigational calls
    can then be used to navigate the objects and the refs in the Object Cache.
    If the OCI_DATA_AT_EXEC mode is specified in the mode parameter, valuep
    is ignored for all data types. OCIBindArrayOfStruct() cannot be used and
    OCIBindDynamic() must be invoked to provide callback functions if desired.
    value_sz (IN) - the size of a data value. In the case of an array bind, this is
    the maximum size of any element possible with the actual sizes being specified
    in the alenp parameter.
    If the OCI_DATA_AT_EXEC mode is specified, valuesz defines the maximum
    size of the data that can be ever provided at runtime for data types other than
    named data types or REFs.
    dty (IN) - the data type of the value(s) being bound. Named data types
    (SQLT_NTY) and REFs (SQLT_REF) are valid only if the application has been
    initialized in object mode. For named data types, or REFs, additional calls
    must be made with the bind handle to set up the datatype-specific attributes.
    indp (IN/OUT) - pointer to an indicator variable or array. For scalar data
    types, this is a pointer to sb2 or an array of sb2s. For named data types,
    this pointer is ignored and the actual pointer to the indicator structure or
    an array of indicator structures is initialized by OCIBindObject().
    Ignored for dynamic binds.
    See the section "Indicator Variables" on page 2-43 for more information about
    indicator variables.
    alenp (IN/OUT) - pointer to array of actual lengths of array elements. Each
    element in alenp is the length of the data in the corresponding element in the
    bind value array before and after the execute. This parameter is ignored for
    dynamic binds.
    rcodep (OUT) - pointer to array of column level return codes. This parameter
    is ignored for dynamic binds.
    maxarr_len (IN) - the maximum possible number of elements of type dty in a
    PL/SQL binds. This parameter is not required for non-PL/SQL binds. If
    maxarr_len is non-zero, then either OCIBindDynamic() or
    OCIBindArrayOfStruct() can be invoked to set up additional bind attributes.
    curelep(IN/OUT) - a pointer to the actual number of elements. This parameter
    is only required for PL/SQL binds.
    mode (IN) - the valid modes for this parameter are:
    OCI_DEFAULT. This is default mode.
    OCI_DATA_AT_EXEC. When this mode is selected, the value_sz
    parameter defines the maximum size of the data that can be ever
    provided at runtime. The application must be ready to provide the OCI
    library runtime IN data buffers at any time and any number of times.
    Runtime data is provided in one of the two ways:
    callbacks using a user-defined function which must be registered
    with a subsequent call to OCIBindDynamic().
    a polling mechanism using calls supplied by the OCI. This mode
    is assumed if no callbacks are defined.
    For more information about using the OCI_DATA_AT_EXEC mode, see
    the section "Runtime Data Allocation and Piecewise Operations" on
    page 5-16.
    When the allocated buffers are not required any more, they should be
    freed by the client.
    Related Functions
    OCIBindDynamic(), OCIBindObject(), OCIBindArrayOfStruct(), OCIAttrGet()



    -------------------------------OCIBindByPos-----------------------------------


    OCIBindByPos()
    Name
    OCI Bind by Position
    Purpose
    Creates an association between a program variable and a placeholder in a SQL
    statement or PL/SQL block.
    Syntax
    sword OCIBindByPos (
                    OCIStmt            *stmtp,
                    OCIBind            **bindp,
                    OCIError            *errhp,
                    ub4                    position,
                    dvoid                *valuep,
                    sb4                    value_sz,
                    ub2                    dty,
                    dvoid                *indp,
                    ub2                    *alenp,
                    ub2                    *rcodep,
                    ub4                    maxarr_len,
                    ub4                    *curelep,
                    ub4                    mode);

    Description
    This call is used to perform a basic bind operation. The bind creates an
    association between the address of a program variable and a placeholder in a
    SQL statement or PL/SQL block. The bind call also specifies the type of data
    which is being bound, and may also indicate the method by which data will be
    provided at runtime.
    This function also implicitly allocates the bind handle indicated by the bindp
    parameter.
    Data in an OCI application can be bound to placeholders statically or
    dynamically. Binding is static when all the IN bind data and the OUT bind
    buffers are well-defined just before the execute. Binding is dynamic when the
    IN bind data and the OUT bind buffers are provided by the application on
    demand at execute time to the client library. Dynamic binding is indicated by
    setting the mode parameter of this call to OCI_DATA_AT_EXEC.
    Related Functions: For more information about dynamic binding, see
    the section "Runtime Data Allocation and Piecewise Operations" on
    page 5-16
    Both OCIBindByName() and OCIBindByPos() take as a parameter a bind handle,
    which is implicitly allocated by the bind call A separate bind handle is
    allocated for each placeholder the application is binding.
    Additional bind calls may be required to specify particular attributes
    necessary when binding certain data types or handling input data in certain
    ways:
    If arrays of structures are being utilized, OCIBindArrayOfStruct() must
    be called to set up the necessary skip parameters.
    If data is being provided dynamically at runtime, and the application
    will be using user-defined callback functions, OCIBindDynamic() must
    be called to register the callbacks.
    If a named data type is being bound, OCIBindObject() must be called to
    specify additional necessary information.
    Parameters
    stmth (IN/OUT) - the statement handle to the SQL or PL/SQL statement
    being processed.
    bindp (IN/OUT) - a pointer to a pointer to a bind handle which is implicitly
    allocated by this call.    The bind handle    maintains all the bind information
    for this particular input value. The handle is feed implicitly when the
    statement handle is deallocated.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    position (IN) - the placeholder attributes are specified by position if
    ocibindp() is being called.
    valuep (IN/OUT) - a pointer to a data value or an array of data values of the
    type specified in the dty parameter. An array of data values can be specified
    for mapping into a PL/SQL table or for providing data for SQL multiple-row
    operations. When an array of bind values is provided, this is called an array
    bind in OCI terms. Additional attributes of the array bind (not bind to a
    column of ARRAY type) are set up in OCIBindArrayOfStruct() call.
    For a REF, named data type    bind, the valuep parameter is used only for IN
    bind data. The pointers to OUT buffers are set in the pgvpp parameter
    initialized by OCIBindObject(). For named data type and REF binds, the bind
    values are unpickled into the Object Cache. The OCI object navigational calls
    can then be used to navigate the objects and the refs in the Object Cache.
    If the OCI_DATA_AT_EXEC mode is specified in the mode parameter, valuep
    is ignored for all data types. OCIBindArrayOfStruct() cannot be used and
    OCIBindDynamic() must be invoked to provide callback functions if desired.
    value_sz (IN) - the size of a data value. In the case of an array bind, this is
    the maximum size of any element possible with the actual sizes being specified
    in the alenp parameter.
    If the OCI_DATA_AT_EXEC mode is specified, valuesz defines the maximum
    size of the data that can be ever provided at runtime for data types other than
    named data types or REFs.
    dty (IN) - the data type of the value(s) being bound. Named data types
    (SQLT_NTY) and REFs (SQLT_REF) are valid only if the application has been
    initialized in object mode. For named data types, or REFs, additional calls
    must be made with the bind handle to set up the datatype-specific attributes.
    indp (IN/OUT) - pointer to an indicator variable or array. For scalar data
    types, this is a pointer to sb2 or an array of sb2s. For named data types,
    this pointer is ignored and the actual pointer to the indicator structure or
    an array of indicator structures is initialized by OCIBindObject(). Ignored
    for dynamic binds.
    See the section "Indicator Variables" on page 2-43 for more information about
    indicator variables.
    alenp (IN/OUT) - pointer to array of actual lengths of array elements. Each
    element in alenp is the length of the data in the corresponding element in the
    bind value array before and after the execute. This parameter is ignored for
    dynamic binds.
    rcodep (OUT) - pointer to array of column level return codes. This parameter
    is ignored for dynamic binds.
    maxarr_len (IN) - the maximum possible number of elements of type dty in a
    PL/SQL binds. This parameter is not required for non-PL/SQL binds. If
    maxarr_len is non-zero, then either OCIBindDynamic() or
    OCIBindArrayOfStruct() can be invoked to set up additional bind attributes.
    curelep(IN/OUT) - a pointer to the actual number of elements. This parameter
    is only required for PL/SQL binds.
    mode (IN) - the valid modes for this parameter are:
    OCI_DEFAULT. This is default mode.
    OCI_DATA_AT_EXEC. When this mode is selected, the value_sz
    parameter defines the maximum size of the data that can be ever
    provided at runtime. The application must be ready to provide the OCI
    library runtime IN data buffers at any time and any number of times.
    Runtime data is provided in one of the two ways:
    callbacks using a user-defined function which must be registered
    with a subsequent call to OCIBindDynamic() .
    a polling mechanism using calls supplied by the OCI. This mode
    is assumed if no callbacks are defined.
    For more information about using the OCI_DATA_AT_EXEC mode, see
    the section "Runtime Data Allocation and Piecewise Operations" on
    page 5-16.
    When the allocated buffers are not required any more, they should be
    freed by the client.
    Related Functions
    OCIBindDynamic(), OCIBindObject(), OCIBindArrayOfStruct(), OCIAttrGet()



    -------------------------------OCIBindDynamic---------------------------------

    OCIBindDynamic()
    Name
    OCI Bind Dynamic Attributes
    Purpose
    This call is used to register user callbacks for dynamic data allocation.
    Syntax
    sword OCIBindDynamic( OCIBind            *bindp,
                    OCIError        *errhp,
                    dvoid                *ictxp,
                    OCICallbackInBind                    (icbfp)(
                    dvoid                        *ictxp,
                    OCIBind                    *bindp,
                    ub4                            iter,
                    ub4                            index,
                    dvoid                        **bufpp,
                    ub4                            *alenp,
                    ub1                            *piecep,
                    dvoid                        **indp ),
                    dvoid                *octxp,
                    OCICallbackOutBind                    (ocbfp)(
                    dvoid                        *octxp,
                    OCIBind                    *bindp,
                    ub4                            iter,
                    ub4                            index,
                    dvoid                        **bufp,
                    ub4                            **alenpp,
                    ub1                            *piecep,
                    dvoid                        **indpp,
                    ub2                            **rcodepp)        );
    Comments
    This call is used to register user-defined callback functions for providing
    data for an UPDATE or INSERT if OCI_DATA_AT_EXEC mode was specified in a
    previous call to OCIBindByName() or OCIBindByPos().
    The callback function pointers must return OCI_CONTINUE if it the call is
    successful. Any return code other than OCI_CONTINUE signals that the client
    wishes to abort processing immediately.
    For more information about the OCI_DATA_AT_EXEC mode, see the section
    "Runtime Data Allocation and Piecewise Operations" on page 5-16.
    Parameters
    bindp (IN/OUT) - a bind handle returned by a call to OCIBindByName() or
    OCIBindByPos().
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    ictxp (IN) - the context pointer required by the call back function icbfp.
    icbfp (IN) - the callback function which returns a pointer to the IN bind
    value or piece at run time. The callback takes in the following parameters.
    ictxp (IN/OUT) - the context pointer for this callback function.
    bindp (IN) - the bind handle passed in to uniquely identify this bind
    variable.
    iter (IN) - 1-based execute iteration value.
    index (IN) - index of the current array, for an array bind. 1 based not
    greater than curele parameter of the bind call.
    index (IN) - index of the current array, for an array bind. This parameter
    is 1-based, and may not be greater than curele parameter of the bind call.
    bufpp (OUT) - the pointer to the buffer.
    piecep (OUT) - which piece of the bind value. This can be one of the
    following values - OCI_ONE_PIECE, OCI_FIRST_PIECE,
    OCI_NEXT_PIECE and OCI_LAST_PIECE.
    indp (OUT) - contains the indicator value. This is apointer to either an
    sb2 value or a pointer to an indicator structure for binding named data
    types.
    indszp (OUT) - contains the indicator value size. A pointer containing
    the size of either an sb2 or an indicator structure pointer.
    octxp (IN) - the context pointer required by the callback function ocbfp.
    ocbfp (IN) - the callback function which returns a pointer to the OUT bind
    value or piece at run time. The callback takes in the following parameters.
    octxp (IN/OUT) - the context pointer for this call back function.
    bindp (IN) - the bind handle passed in to uniquely identify this bind
    variable.
    iter (IN) - 1-based execute iteration value.
    index (IN) - index of the current array, for an array bind. This parameter
    is 1-based, and must not be greater than curele parameter of the bind call.
    bufpp (OUT) - a pointer to a buffer to write the bind value/piece.
    buflp (OUT) - returns the buffer size.
    alenpp (OUT) - a pointer to a storage for OCI to fill in the size of the bind
    value/piece after it has been read.
    piecep (IN/OUT) - which piece of the bind value. It will be set by the
    library to be one of the following values - OCI_ONE_PIECE or
    OCI_NEXT_PIECE. The callback function can leave it unchanged or set
    it to OCI_FIRST_PIECE or OCI_LAST_PIECE. By default -
    OCI_ONE_PIECE.
    indpp (OUT) - returns a pointer to contain the indicator value which
    either an sb2 value or a pointer to an indicator structure for named data
    types.
    indszpp (OUT) - returns a pointer to return the size of the indicator
    value which is either size of an sb2 or size of an indicator structure.
    rcodepp (OUT) - returns a pointer to contains the return code.
    Related Functions
    OCIAttrGet()


    ---------------------------------OCIBindObject--------------------------------


    OCIBindObject()
    Name
    OCI Bind Object
    Purpose
    This function sets up additional attributes which are required for a named
    data type (object)    bind.
    Syntax
    sword OCIBindObject ( OCIBind                    *bindp,
                    OCIError                    *errhp,
                    CONST OCIType        *type,
                    dvoid                        **pgvpp,
                    ub4                            *pvszsp,
                    dvoid                        **indpp,
                    ub4                            *indszp, );
    Comments
    This function sets up additional attributes which binding a named data type
    or a REF. An error will be returned if this function is called when the OCI
    environment has been initialized in non-object mode.
    This call takes as a paramter a type descriptor object (TDO) of datatype
    OCIType for the named data type being defined.    The TDO can be retrieved
    with a call to OCITypeByName().
    If the OCI_DATA_AT_EXEC mode was specified in ocibindn() or ocibindp(), the
    pointers to the IN buffers are obtained either using the callback icbfp
    registered in the OCIBindDynamic() call or by the OCIStmtSetPieceInfo() call.
    The buffers are dynamically allocated for the OUT data and the pointers to
    these buffers are returned either by calling ocbfp() registered by the
    OCIBindDynamic() or by setting the pointer to the buffer in the buffer passed
    in by OCIStmtSetPieceInfo() called when OCIStmtExecute() returned
    OCI_NEED_DATA. The memory of these client library- allocated buffers must be
    freed when not in use anymore by using the OCIObjectFreee() call.
    Parameters
    bindp ( IN/OUT) - the bind handle returned by the call to OCIBindByName()
    or OCIBindByPos().
    errhp ( IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    type ( IN) - points to the TDO which describes the type of the program
    variable being bound. Retrieved by calling OCITypeByName().
    pgvpp ( IN/OUT) - points to a pointer to the program variable buffer. For an
    array, pgvpp points to an array of pointers. When the bind variable is also an
    OUT variable, the OUT Named Data Type value or REF is allocated
    (unpickled) in the Object Cache, and a pointer to the value or REF is returned,
    At the end of execute, when all OUT values have been received, pgvpp points
    to an array of pointer(s) to these newly allocated named data types in the
    object cache.
    pgvpp is ignored if the OCI_DATA_AT_EXEC mode is set. Then the Named
    Data Type buffers are requested at runtime. For static array binds, skip
    factors may be specified using the OCIBindArrayOfStruct() call. The skip
    factors are used to compute the address of the next pointer to the value, the
    indicator structure and their sizes.
    pvszsp ( IN/OUT) - points to the size of the program variable. The size of the
    named data type is not required on input. For an array, pvszsp is an array of
    ub4s. On return, for OUT bind variables, this points to size(s) of the Named
    Data Types and REFs received. pvszsp is ignored if the OCI_DATA_AT_EXEC
    mode is set. Then the size of the buffer is taken at runtime.
    indpp ( IN/OUT) - points to a pointer to the program variable buffer
    containing the parallel indicator structure. For an array, points to an array
    of pointers. When the bind variable is also an OUT bind variable, memory is
    allocated in the object cache, to store the unpickled OUT indicator values. At
    the end of the execute when all OUT values have been received, indpp points
    to the pointer(s) to these newly allocated indicator structure(s).
    indpp is ignored if the OCI_DATA_AT_EXEC mode is set. Then the indicator
    is requested at runtime.
    indszp ( IN/OUT) - points to the size of the IN indicator structure program
    variable. For an array, it is an array of sb2s. On return for OUT bind
    variables, this points to size(s) of the received OUT indicator structures.
    indszp is ignored if the OCI_DATA_AT_EXEC mode is set. Then the indicator
    size is requested at runtime.
    Related Functions
    OCIAttrGet()



    ----------------------------------OCIBreak------------------------------------


    OCIBreak()
    Name
    OCI Break
    Purpose
    This call performs an immediate (asynchronous) abort of any currently
    executing OCI function that is associated with a server .
    Syntax
    sword OCIBreak ( dvoid            *hndlp,
            OCIError        *errhp);
    Comments
    This call performs an immediate (asynchronous) abort of any currently
    executing OCI function that is associated with a server. It is normally used
    to stop a long-running OCI call being processed on the server.
    This call can take either the service context handle or the server context
    handle as a parameter to identify the function to be aborted.
    Parameters
    hndlp (IN) - the service context handle or the server context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    Related Functions

    -----------------------------OCIConnectionPoolCreate --------------------------
    Name:
    OCIConnectionPoolCreate

    Purpose:
    Creates the connections in the pool

    Syntax:
    OCIConnectionPoolCreate (OCIEnv *envhp, OCIError *errhp, OCICPool *poolhp,
                OraText **poolName, sb4 *poolNameLen,
                CONST Oratext *dblink, sb4 dblinkLen,
                ub4 connMin, ub4 connMax, ub4 connIncr,
                CONST OraText *poolUsername, sb4 poolUserLen,
                CONST OraText *poolPassword, sb4 poolPassLen,
                ub4 mode)
    Comments:
    This call is used to create a connection pool. conn_min connections
    to the database are started on calling OCIConnectionPoolCreate.

    Parameters:
    envhp (IN/OUT)    - A pointer to the environment where the Conencton Pool
                is to be created
    errhp (IN/OUT)    - An error handle which can be passed to OCIErrorGet().
    poolhp (IN/OUT) - An uninitialiazed pool handle.
    poolName (OUT) - The connection pool name.
    poolNameLen (OUT) - The length of the connection pool name
    dblink (IN/OUT) - Specifies the database(server) to connect. This will also
                be used as the default pool name.
    dblinkLen (IN)    - The length of the string pointed to by dblink.
    connMin (IN)        - Specifies the minimum number of connections in the
                Connection Pool at any instant.
                connMin number of connections are started when
                OCIConnectionPoolCreate() is called.
    connMax (IN)        - Specifies the maximum number of connections that can be
                opened to the database. Once this value is reached, no
                more connections are opened.
    connIncr (IN)        - Allows application to set the next increment for
                connections to be opened to the database if the current
                number of connections are less than conn_max.
    poolUsername (IN/OUT) - Connection pooling requires an implicit proxy
                session and this attribute provides a username
                for that session.
    poolUserLen (IN) - This represents the length of pool_username.
    poolPassword (IN/OUT) - The password for the parameter pool_username passed
                above.
    poolPassLen (IN) - This represents the length of pool_password.

    mode (IN) - The modes supported are OCI_DEFAULT and
    OCI_CPOOL_REINITIALIZE

    Related Functions
    OCIConnectionPoolDestroy()

    ---------------------------------------------------------------------------

    ----------------------------OCIConnectionPoolDestroy-------------------------
    Name:
    OCIConnectionPoolDestroy

    Purpose:
    Terminates the connections in the pool

    Syntax:
    OCIConnectionPoolDestroy (OCICPool *poolhp, OCIError *errhp, ub4 mode)

    Comments:
    On calling OCIConnectionPoolDestroy, all the open connections in the pool
    are closed and the pool is destroyed.

    Parameters:
    poolhp (IN/OUT) - An initialiazed pool handle.
    errhp (IN/OUT)    - An error handle which can be passed to OCIErrorGet().
    mode (IN)                - Currently, OCIConnectionPoolDestroy() will support only
                the OCI_DEFAULT mode.

    Related Functions:
    OCIConnectionPoolCreate()

    -----------------------------------------------------------------------------
    ----------------------------OCISessionPoolCreate-----------------------------
    Name:
    OCISessionPoolCreate

    Purpose:
    Creates the sessions in the session pool.

    Syntax:
    sword OCISessionPoolCreate (OCIEnv *envhp, OCIError *errhp, OCISpool *spoolhp,
                        OraText **poolName, ub4 *poolNameLen,
                        CONST OraText *connStr, ub4 connStrLen,
                        ub4 sessMin, ub4 sessMax, ub4 sessIncr,
                        OraText *userid,    ub4 useridLen,
                        OraText *password, ub4 passwordLen,
                        ub4 mode)

    Comments:
    When OCISessionPoolCreate is called, a session pool is initialized for
    the associated environment and the database specified by the
    connStr parameter. This pool is named uniquely and the name
    is returned to the user in the poolname parameter.

    Parameters:
    envhp (IN/OUT) - A pointer to the environment handle in which the session
            pool needs to be created.
    errhp (IN/OUT) - An error handle which can be passed to OCIErrorGet().
    spoolhp (IN/OUT) - A pointer to the session pool handle that is created.
    poolName (OUT) - Session pool name returned to the user.
    poolNameLen (OUT) - Length of the PoolName
    connStr (IN) - The TNS alias of the database to connect to.
    connStrLen (IN) - Length of the connStr.
    sessMin (IN) - Specifies the minimum number of sessions in the Session Pool.
                    These are the number of sessions opened in the beginning, if
                    in Homogeneous mode. Else, the parameter is ignored.
    sessMax (IN) - Specifies the maximum number of sessions in the Session Pool.
                    Once this value is reached, no more sessions are opened,
                    unless the OCI_ATTR_SPOOL_FORCEGET is set.
    userid (IN) - Specifies the userid with which to start up the sessions.
    useridLen (IN) - Length of userid.
    password (IN) - Specifies the password for the corresponding userid.
    passwordLen (IN) - Specifies the length of the password
    mode(IN) - May be OCI_DEFAULT, OCI_SPC_SPOOL_REINITIALIZE, or
            OCI_SPC_SPOOL_HOMOGENEOUS.

    Returns:
    SUCCESS - If pool could be allocated and created successfully.
    ERROR - If above conditions could not be met.

    Related Functions:
    OCISessionPoolDestroy()
    -----------------------------------------------------------------------------
    -----------------------------OCISessionPoolDestroy---------------------------
    Name:
    OCISessionPoolDestroy

    Purpose:
    Terminates all the sessions in the session pool.

    Syntax:
    sword OCISessionPoolDestroy (OCISPool *spoolhp, OCIError *errhp, ub4 mode)

    Comments:
    spoolhp (IN/OUT) - The pool handle of the session pool to be destroyed.
    errhp (IN/OUT) - An error handle which can be passed to OCIErrorGet().
    mode (IN) - Currently only OCI_DEFAULT mode is supported.

    Returns:
    SUCCESS - All the sessions could be closed.
    ERROR - If the above condition is not met.

    Related Functions:
    OCISessionPoolCreate()
    -----------------------------------------------------------------------------
    -------------------------------OCISessionGet---------------------------------
    Name:
    OCISessionGet

    Purpose:
    Get a session. This could be from a session pool, connection pool or
    a new standalone session.

    Syntax:
    sword OCISessionGet(OCIenv *envhp, OCIError *errhp, OCISvcCtx **svchp,
                    OCIAuthInfo *authhp,
                    OraText *poolName, ub4 poolName_len,
                    CONST OraText *tagInfo, ub4 tagInfo_len,
                    OraText **retTagInfo, ub4 *retTagInfo_len,
                    boolean *found,
                    ub4 mode)

    Comments:
    envhp (IN/OUT) - OCI environment handle.
    errhp (IN/OUT) - OCI error handle to be passed to OCIErrorGet().
    svchp (IN/OUT) - Address of an OCI service context pointer. This will be
            filled with a server and session handle, attached to the
            pool.
    authhp (IN/OUT) - OCI Authentication Information handle.
    poolName (IN) - This indicates the session/connection pool to get the
            session/connection from in the OCI_SPOOL/OCI_CPOOL mode.
            In the OCI_DEFAULT mode it refers to the connect string.
    poolName_len (IN) - length of poolName.
    tagInfo (IN) - indicates the tag of the session that the user wants. If the
                user wants a default session, he must specify a NULL here.
                Only used for Session Pooling.
    tagInfo_len (IN) - the length of tagInfo.
    retTagInfo (OUT) - This indicates the type of session that is returned to
                the user. Only used for Session Pooling.
    retTagInfo_len (OUT) - the length of retTagInfo.
    found (OUT) - set to true if the user gets a session he had requested, else
                    set to false. Only used for Session Pooling.
    mode (IN) - The supported modes are OCI_DEFAULT, OCI_CRED_PROXY and
                OCI_GET_SPOOL_MATCHANY, OCI_SPOOL and OCI_CPOOL. OCI_SPOOL and
                OCI_CPOOL are mutually exclusive.

    Returns:
    SUCCESS -    if a session was successfully returned into svchp.
    SUCCESS_WITH_INFO - if a session was successfully returned into svchp and the
                    total number of sessions > maxsessions. Only valid for
                    Session Pooling.
    ERROR - If a session could not be retrieved.

    Related Functions:
    OCISessionRelease()
    -----------------------------------------------------------------------------
    ---------------------------OCISessionRelease---------------------------------
    Name:
    OCISessionRelease

    Purpose:
    Release the session.

    Syntax:
    sword OCISessionRelease ( OCISvcCtx *svchp, OCIError *errhp,
                    OraText *tag, ub4 tag_len,
                    ub4 mode);

    Comments:
    svchp (IN/OUT) - The service context associated with the session/connection.
    errhp (IN/OUT) - OCI error handle to be passed to OCIErrorGet().
    tag (IN) - Only used for Session Pooling.
            This parameter will be ignored unless mode OCI_RLS_SPOOL_RETAG is
            specified. In this case, the session is labelled with this tag and
            returned to the pool. If this is NULL, then the session is untagged.
    tag_len (IN) - Length of the tag. This is ignored unless mode
                    OCI_RLS_SPOOL_RETAG is set.
    mode (IN) - The supported modes are OCI_DEFAULT, OCI_RLS_SPOOL_DROPSESS,
                OCI_RLS_SPOOL_RETAG. The last 2 are only valid for Session Pooling.
                When OCI_RLS_SPOOL_DROPSESS is specified, the session
                will be removed from the session pool. If OCI_RLS_SPOOL_RETAG
                is set, the tag on the session will be altered. If this mode is
                not set, the tag and tag_len parameters will be ignored.

    Returns:
    ERROR - If the session could not be released successfully.
    SUCCESS - In all other cases.

    Related Functions:
    OCISessionGet().
    -----------------------------------------------------------------------------
    ------------------------------OCIDateTimeAssign --------------------------
    sword OCIDateTimeAssign(dvoid *hndl, OCIError *err, CONST OCIDateTime *from,
                OCIDateTime *to);
    NAME: OCIDateTimeAssign - OCIDateTime Assignment
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    from (IN) - datetime to be assigned
    to (OUT) - lhs of assignment
    DESCRIPTION:
        Performs date assignment. The type of the output will be same as that
        of input

    ------------------------------OCIDateTimeCheck----------------------------
    sword OCIDateTimeCheck(dvoid *hndl, OCIError *err, CONST OCIDateTime *date,
            ub4 *valid );
    NAME: OCIDateTimeCheck - OCIDateTime CHecK if the given date is valid
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    date (IN) - date to be checked
    valid (OUT) -    returns zero for a valid date, otherwise
            the ORed combination of all error bits specified below:
        Macro name                                        Bit number            Error
        ----------                                        ----------            -----
        OCI_DATE_INVALID_DAY                    0x1                            Bad day
        OCI_DATE_DAY_BELOW_VALID            0x2                            Bad DAy Low/high bit (1=low)
        OCI_DATE_INVALID_MONTH                0x4                            Bad MOnth
        OCI_DATE_MONTH_BELOW_VALID        0x8                            Bad MOnth Low/high bit (1=low)
        OCI_DATE_INVALID_YEAR                0x10                        Bad YeaR
        OCI_DATE_YEAR_BELOW_VALID        0x20                        Bad YeaR Low/high bit (1=low)
        OCI_DATE_INVALID_HOUR                0x40                        Bad HouR
        OCI_DATE_HOUR_BELOW_VALID        0x80                        Bad HouR Low/high bit (1=low)
        OCI_DATE_INVALID_MINUTE            0x100                        Bad MiNute
        OCI_DATE_MINUTE_BELOW_VALID    0x200                        Bad MiNute Low/high bit (1=low)
        OCI_DATE_INVALID_SECOND            0x400                        Bad SeCond
        OCI_DATE_SECOND_BELOW_VALID    0x800                        bad second Low/high bit (1=low)
        OCI_DATE_DAY_MISSING_FROM_1582 0x1000                Day is one of those "missing"
                            from 1582
        OCI_DATE_YEAR_ZERO                        0x2000                    Year may not equal zero
        OCI_DATE_INVALID_TIMEZONE        0x4000                    Bad Timezone
        OCI_DATE_INVALID_FORMAT            0x8000                    Bad date format input

        So, for example, if the date passed in was 2/0/1990 25:61:10 in
        (month/day/year hours:minutes:seconds format), the error returned
        would be OCI_DATE_INVALID_DAY | OCI_DATE_DAY_BELOW_VALID |
        OCI_DATE_INVALID_HOUR | OCI_DATE_INVALID_MINUTE

    DESCRIPTION:
        Check if the given date is valid.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
            'date' and 'valid' pointers are NULL pointers

    ------------------------------- OCIDateTimeCompare----------------------------
    sword OCIDateTimeCompare(dvoid *hndl, OCIError *err, CONST OCIDateTime *date1,
                    CONST OCIDateTime *date2,    sword *result );
    NAME: OCIDateTimeCompare - OCIDateTime CoMPare dates
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    date1, date2 (IN) - dates to be compared
    result (OUT) - comparison result, 0 if equal, -1 if date1 < date2,
            1 if date1 > date2
    DESCRIPTION:
    The function OCIDateCompare compares two dates. It returns -1 if
    date1 is smaller than date2, 0 if they are equal, and 1 if date1 is
    greater than date2.
    RETURNS:
                OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
            invalid date
            input dates are not mutually comparable

    ------------------------------OCIDateTimeConvert----------------------
    sword OCIDateTimeConvert(dvoid *hndl, OCIError *err, OCIDateTime *indate,
                    OCIDateTime *outdate);
    NAME: OCIDateTimeConvert - Conversion between different DATETIME types
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    indate (IN) - pointer to input date
    outdate (OUT) - pointer to output datetime
    DESCRIPTION: Converts one datetime type to another. The result type is
                the type of the 'outdate' descriptor.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
                conversion not possible.

    ---------------------------- OCIDateTimeFromText-----------------------
    sword OCIDateTimeFromText(dvoid *hndl, OCIError *err, CONST OraText *date_str,
                size_t d_str_length, CONST OraText *fmt, ub1 fmt_length,
                CONST OraText *lang_name, size_t lang_length, OCIDateTime *date );
    NAME: OCIDateTimeFromText - OCIDateTime convert String FROM Date
    PARAMETERS:
    hndl (IN) - Session/Env handle. If Session Handle is passed, the
                    conversion takes place in session NLS_LANGUAGE and
                    session NLS_CALENDAR, otherwise the default is used.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    date_str (IN) - input string to be converted to Oracle date
    d_str_length (IN) - size of the input string, if the length is -1
            then 'date_str' is treated as a null terminated    string
    fmt (IN) - conversion format; if 'fmt' is a null pointer, then
            the string is expected to be in the default format for
            the datetime type.
    fmt_length (IN) - length of the 'fmt' parameter
    lang_name (IN) - language in which the names and abbreviations of
            days and months are specified, if null i.e. (OraText *)0,
            the default language of session is used,
    lang_length (IN) - length of the 'lang_name' parameter
    date (OUT) - given string converted to date
    DESCRIPTION:
        Converts the given string to Oracle datetime type set in the
        OCIDateTime descriptor according to the specified format. Refer to
        "TO_DATE" conversion function described in "Oracle SQL Language
        Reference Manual" for a description of format.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
            invalid format
            unknown language
            invalid input string

    --------------------------- OCIDateTimeGetDate-------------------------
    sword OCIDateTimeGetDate(dvoid *hndl, OCIError *err,    CONST OCIDateTime *date,
                    sb2 *year, ub1 *month, ub1 *day );
    NAME: OCIDateTimeGetDate - OCIDateTime Get Date (year, month, day)
                    portion of DATETIME.
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN) - Pointer to OCIDateTime
    year            (OUT) - year value
    month            (OUT) - month value
    day                (OUT) - day value

    --------------------------- OCIDateTimeGetTime ------------------------
    sword OCIDateTimeGetTime(dvoid *hndl, OCIError *err, OCIDateTime *datetime,
            ub1 *hour, ub1 *minute, ub1 *sec, ub4 *fsec);
    NAME: OCIDateTimeGetTime - OCIDateTime Get Time (hour, min, second,
                fractional second)    of DATETIME.
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN) - Pointer to OCIDateTime
    hour            (OUT) - hour value
    minute                (OUT) - minute value
    sec                (OUT) - second value
    fsec            (OUT) - Fractional Second value

    --------------------------- OCIDateTimeGetTimeZoneOffset ----------------------
    sword OCIDateTimeGetTimeZoneOffset(dvoid *hndl,OCIError *err,CONST
                    OCIDateTime *datetime,sb1 *hour,sb1    *minute);

    NAME: OCIDateTimeGetTimeZoneOffset - OCIDateTime Get TimeZone (hour, minute)
                portion of DATETIME.
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN) - Pointer to OCIDateTime
    hour            (OUT) - TimeZone Hour value
    minute            (OUT) - TimeZone Minute value

    --------------------------- OCIDateTimeSysTimeStamp---------------------
    sword OCIDateTimeSysTimeStamp(dvoid *hndl, OCIError *err,
                    OCIDateTime *sys_date );

    NAME: OCIDateTimeSysTimeStamp - Returns system date/time as a TimeStamp with
                        timezone
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    sys_date (OUT) - Pointer to output timestamp

    DESCRIPTION:
        Gets the system current date and time as a timestamp with timezone
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.


    ------------------------------OCIDateTimeIntervalAdd----------------------
    sword OCIDateTimeIntervalAdd(dvoid *hndl, OCIError *err, OCIDateTime *datetime,
        OCIInterval *inter, OCIDateTime *outdatetime);
    NAME: OCIDateTimeIntervalAdd - Adds an interval to datetime
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN) - pointer to input datetime
    inter        (IN) - pointer to interval
    outdatetime (IN) - pointer to output datetime. The output datetime
                    will be of same type as input datetime
    DESCRIPTION:
        Adds an interval to a datetime to produce a resulting datetime
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if:
            resulting date is before Jan 1, -4713
            resulting date is after Dec 31, 9999

    ------------------------------OCIDateTimeIntervalSub----------------------
    sword OCIDateTimeIntervalSub(dvoid *hndl, OCIError *err, OCIDateTime *datetime,
                    OCIInterval *inter, OCIDateTime *outdatetime);
    NAME: OCIDateTimeIntervalSub - Subtracts an interval from a datetime
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN) - pointer to input datetime
    inter        (IN) - pointer to interval
    outdatetime (IN) - pointer to output datetime. The output datetime
                    will be of same type as input datetime
    DESCRIPTION:
        Subtracts an interval from a datetime and stores the result in a
        datetime
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if:
            resulting date is before Jan 1, -4713
            resulting date is after Dec 31, 9999

    --------------------------- OCIDateTimeConstruct-------------------------
    sword OCIDateTimeConstruct(dvoid    *hndl,OCIError *err,OCIDateTime *datetime,
                    sb2 year,ub1 month,ub1 day,ub1 hour,ub1 min,ub1 sec,ub4 fsec,
                    OraText    *timezone,size_t timezone_length);

    NAME: OCIDateTimeConstruct - Construct an OCIDateTime. Only the relevant
                fields for the OCIDateTime descriptor types are used.
    PARAMETERS:
        hndl (IN) - Session/Env handle.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        datetime (IN) - Pointer to OCIDateTime
        year            (IN) - year value
        month            (IN) - month value
        day                (IN) - day value
        hour            (IN) - hour value
        min                (IN) - minute value
        sec                (IN) - second value
        fsec            (IN) - Fractional Second value
        timezone    (IN) - Timezone string
        timezone_length(IN) - Length of timezone string

    DESCRIPTION:
                Constructs a DateTime descriptor. The type of the datetime is the
                type of the OCIDateTime descriptor. Only the relevant fields based
                on the type are used. For Types with timezone, the date and time
                fields are assumed to be in the local time of the specified timezone.
                If timezone is not specified, then session default timezone is
                assumed.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR if datetime is not valid.

    ------------------------------OCIDateTimeSubtract-----------------------
    sword OCIDateTimeSubtract(dvoid *hndl, OCIError *err, OCIDateTime *indate1,
            OCIDateTime *indate2, OCIInterval *inter);
    NAME: OCIDateTimeSubtract - subtracts two datetimes to return an interval
    PARAMETERS:
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    indate1(IN) - pointer to subtrahend
    indate2(IN) - pointer to minuend
    inter    (OUT) - pointer to output interval
    DESCRIPTION:
        Takes two datetimes as input and stores their difference in an
        interval. The type of the interval is the type of the 'inter'
        descriptor.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
            datetimes are not comparable.

    --------------------------- OCIDateTimeToText--------------------------
    sword OCIDateTimeToText(dvoid *hndl, OCIError *err, CONST OCIDateTime *date,
                CONST OraText *fmt, ub1 fmt_length, ub1 fsprec,
                CONST OraText *lang_name, size_t lang_length,
                ub4 *buf_size, OraText *buf );
    NAME: OCIDateTimeToText - OCIDateTime convert date TO String
    PARAMETERS:
    hndl (IN) - Session/Env handle. If Session Handle is passed, the
                    conversion takes place in session NLS_LANGUAGE and
                    session NLS_CALENDAR, otherwise the default is used.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    date (IN) - Oracle datetime to be converted
    fmt (IN) - conversion format, if null string pointer (OraText*)0, then
            the date is converted to a character string in the
            default format for that type.
    fmt_length (IN) - length of the 'fmt' parameter
    fsprec (IN) - specifies the fractional second precision in which the
                    fractional seconds is returned.
    lang_name (IN) - specifies the language in which the names and
            abbreviations of months and days are returned;
            default language of session is used if 'lang_name'
            is null i.e. (OraText *)0
    lang_length (IN) - length of the 'nls_params' parameter
    buf_size (IN/OUT) - size of the buffer; size of the resulting string
            is returned via this parameter
    buf (OUT) - buffer into which the converted string is placed
    DESCRIPTION:
        Converts the given date to a string according to the specified format.
        Refer to "TO_DATE" conversion function described in
        "Oracle SQL Language Reference Manual" for a description of format
        and NLS arguments. The converted null-terminated date string is
        stored in the buffer 'buf'.
    RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if
            buffer too small
            invalid format
            unknown language
            overflow error

    ----------------------------OCIDateTimeGetTimeZoneName------------------------
    sword OCIDateTimeGetTimeZoneName(dvoid *hndl,
                    OCIError *err,
                    CONST OCIDateTime *datetime,
                    ub1 *buf,
                    ub4 *buflen);
    NAME OCIDateTimeGetTimeZoneName - OCI DateTime Get the Time Zone Name
    PARAMETERS:
    hndl (IN)            - Session/Env handle.
    err (IN/OUT)        - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN)        - Pointer to an OCIDateTime.
    buf (OUT)                - User allocated storage for name string.
    buflen (IN/OUT) - length of buf on input, length of name on out
    DESCRIPTION:
        Returns either the timezone region name or the absolute hour and minute
        offset. If the DateTime was created with a region id then the region
        name will be returned in the buf.    If the region id is zero, then the
        hour and minute offset is returned as "[-]HH:MM".
    RETURNS:
                OCI_SUCCESS if the function completes successfully.
                OCI_INVALID_HANDLE if 'err' is NULL.
                OCI_ERROR if
        buffer too small
        error retrieving timezone data
        invalid region
        invalid LdiDateTime type

    ---------------------------------OCIDateTimeToArray----------------------------
    sword OCIDateTimeToArray(dvoid *hndl,
                OCIError *err,
                CONST OCIDateTime *datetime,
                CONST OCIInterval *reftz,
                ub1 *outarray,
                ub4 *len
                ub1 *fsprec);
    NAME OCIDateTimeToArray - OCI DateTime convert To Array format
    PARAMETERS:
    hndl (IN)            - Session/Env handle.
    err (IN/OUT)        - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    datetime (IN)        - Pointer to OCIDateTime to be converted.
    outarray (OUT)    - Result array storage
    len (OUT)                - pointer to    length of outarray.
    fsprec (IN)            - Number of fractional seconds digits.
    DESCRIPTION:
        Returns an array representing the input DateTime descriptor.
    RETURNS:
                OCI_SUCCESS if the function completes successfully.
                OCI_INVALID_HANDLE if 'err' is NULL.
                OCI_ERROR if
        buffer too small
        error retrieving timezone data
        invalid region
        invalid LdiDateTime type

    --------------------------------OCIDateTimeFromArray---------------------------
    sword OCIDateTimeFromArray(dvoid *hndl,
                OCIError *err,
                ub1 *inarray,
                ub4 len
                ub1 type
                OCIDateTime *datetime,
                OCIInterval *reftz,
                ub1 fsprec);
    NAME OCIDateTimeFromArray - OCI DateTime convert From Array format
    PARAMETERS:
    hndl (IN)            - Session/Env handle.
    err (IN/OUT)        - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    inarray (IN)        - Pointer to input array representtion of DateTime
    len (IN)                - len of inarray.
    type (IN)            - One of SQLT_DATE, SQLT_TIME, SQLT_TIME_TZ, SQLT_TIMESTAMP,
            SQLT_TIMESTAMP_TZ, or SQLT_TIMESTAMP_LTZ.
    datetime (OUT) - Pointer to the result OCIDateTime.
    reftz (IN)            - timezone interval used with SQLT_TIMESTAMP_LTZ.
    fsprec (IN)        - fractionl seconds digits of precision (0-9).
    DESCRIPTION:
        Returns a pointer to an OCIDateTime of type type converted from
        the inarray.
    RETURNS:
                OCI_SUCCESS if the function completes successfully.
                OCI_INVALID_HANDLE if 'err' is NULL.
                OCI_ERROR if
        buffer too small
        error retrieving timezone data
        invalid region
        invalid LdiDateTime type

    ----------------------------------OCIRowidToChar-----------------------------
    Name
    OCIRowidToChar

    Purpose
    Converts physical/logical (universal) ROWID to chracter extended (Base 64)
    representation into user provided buffer outbfp of length outbflp. After
    execution outbflp contains amount of bytes converted.In case of truncation
    error, outbflp contains required size to make this conversion successful
    and returns ORA-1405.

    Syntax
    sword OCIRowidToChar( OCIRowid *rowidDesc,
                        OraText *outbfp,
                        ub2 *outbflp,
                        OCIError *errhp)

    Comments
    After this conversion, ROWID in character format can be bound using
    OCIBindByPos or OCIBindByName call and used to query a row at a
    desired ROWID.

    Parameters
    rowidDesc (IN)        - rowid DESCriptor which is allocated from OCIDescritorAlloc
                and populated by a prior SQL statement execution
    outbfp (OUT)            - pointer to the buffer where converted rowid in character
                representation is stored after successful execution.
    outbflp (IN/OUT) - pointer to output buffer length variable.
                Before execution (IN mode) *outbflp contains the size of
                outbfp, after execution (OUT mode) *outbflp contains amount
                of bytes converted. In an event of truncation during
                conversion *outbflp contains the required length to make
                conversion successful.
    errhp (IN/OUT)        - an error handle which can be passed to OCIErrorGet() for
                diagnostic information in the event of an error.

    ------------------------------OCIDefineArrayOfStruct--------------------------


    OCIDefineArrayOfStruct()
    Name
    OCI Define for Array of Structures
    Purpose
    This call specifies additional attributes necessary for a static array define.
    Syntax
    sword OCIDefineArrayOfStruct ( OCIDefine        *defnp,
                        OCIError        *errhp,
                        ub4                    pvskip,
                        ub4                    indskip,
                        ub4                    rlskip,
                        ub4                    rcskip );
    Comments
    This call specifies additional attributes necessary for an array define,
    used in an array of structures (multi-row, multi-column) fetch.
    For more information about skip parameters, see the section "Skip Parameters"
    on page 4-17.
    Parameters
    defnp (IN) - the handle to the define structure which was returned by a call
    to OCIDefineByPos().
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    pvskip (IN) - skip parameter for the next data value.
    indskip (IN) - skip parameter for the next indicator location.
    rlskip (IN) - skip parameter for the next return length value.
    rcskip (IN) - skip parameter for the next return code.
    Related Functions
    OCIAttrGet()





    OCIDefineByPos()
    Name
    OCI Define By Position
    Purpose
    Associates an item in a select-list with the type and output data buffer.
    Syntax
    sb4 OCIDefineByPos (
                    OCIStmt            *stmtp,
                    OCIDefine        **defnp,
                    OCIError        *errhp,
                    ub4                    position,
                    dvoid                *valuep,
                    sb4                    value_sz,
                    ub2                    dty,
                    dvoid                *indp,
                    ub2                    *rlenp,
                    ub2                    *rcodep,
                    ub4                    mode );
    Comments
    This call defines an output buffer which will receive data retreived from
    Oracle. The define is a local step which is necessary when a SELECT statement
    returns data to your OCI application.
    This call also implicitly allocates the define handle for the select-list item.
    Defining attributes of a column for a fetch is done in one or more calls. The
    first call is to OCIDefineByPos(), which defines the minimal attributes
    required to specify the fetch.
    This call takes as a parameter a define handle, which must have been
    previously allocated with a call to OCIHandleAlloc().
    Following the call to OCIDefineByPos() additional define calls may be
    necessary for certain data types or fetch modes:
    A call to OCIDefineArrayOfStruct() is necessary to set up skip parameters
    for an array fetch of multiple columns.
    A call to OCIDefineObject() is necessary to set up the appropriate
    attributes of a named data type fetch. In this case the data buffer pointer
    in ocidefn() is ignored.
    Both OCIDefineArrayOfStruct() and OCIDefineObject() must be called
    after ocidefn() in order to fetch multiple rows with a column of named
    data types.
    For a LOB define, the buffer pointer must be a lob locator of type
    OCILobLocator , allocated by the OCIDescAlloc() call. LOB locators, and not
    LOB values, are always returned for a LOB column. LOB values can then be
    fetched using OCI LOB calls on the fetched locator.
    For NCHAR (fixed and varying length), the buffer pointer must point to an
    array of bytes sufficient for holding the required NCHAR characters.
    Nested table columns are defined and fetched like any other named data type.
    If the mode parameter is this call is set to OCI_DYNAMIC_FETCH, the client
    application can fetch data dynamically at runtime.
    Runtime data can be provided in one of two ways:
    callbacks using a user-defined function which must be registered with a
    subsequent call to OCIDefineDynamic(). When the client library needs a
    buffer to return the fetched data, the callback will be invoked and the
    runtime buffers provided will return a piece or the whole data.
    a polling mechanism using calls supplied by the OCI. This mode is
    assumed if no callbacks are defined. In this case, the fetch call returns the
    OCI_NEED_DATA error code, and a piecewise polling method is used
    to provide the data.
    Related Functions: For more information about using the
    OCI_DYNAMIC_FETCH mode, see the section "Runtime Data
    Allocation and Piecewise Operations" on page 5-16 of Volume 1..
    For more information about the define step, see the section "Defining"
    on page 2-30.
    Parameters
    stmtp (IN) - a handle to the requested SQL query operation.
    defnp (IN/OUT) - a pointer to a pointer to a define handle which is implicitly
    allocated by this call.    This handle is used to    store the define information
    for this column.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    position (IN) - the position of this value in the select list. Positions are
    1-based and are numbered from left to right. For example, in the SELECT
    statement
    SELECT empno, ssn, mgrno FROM employees;
    empno is at position 1, ssn is at position 2, and mgrno is at position 3.
    valuep (IN/OUT) - a pointer to a buffer or an array of buffers of the type
    specified in the dty parameter. A number of buffers can be specified when
    results for more than one row are desired in a single fetch call.
    value_sz (IN) - the size of each valuep buffer in bytes. If the data is stored
    internally in VARCHAR2 format, the number of characters desired, if different
    from the buffer size in bytes, may be additionally specified by the using
    OCIAttrSet().
    In an NLS conversion environment, a truncation error will be generated if the
    number of bytes specified is insufficient to handle the number of characters
    desired.
    dty (IN) - the data type. Named data type (SQLT_NTY) and REF (SQLT_REF)
    are valid only if the environment has been intialized with in object mode.
    indp - pointer to an indicator variable or array. For scalar data types,
    pointer to sb2 or an array of sb2s. Ignored for named data types. For named
    data types, a pointer to a named data type indicator structure or an array of
    named data type indicator structures is associated by a subsequent
    OCIDefineObject() call.
    See the section "Indicator Variables" on page 2-43 for more information about
    indicator variables.
    rlenp (IN/OUT) - pointer to array of length of data fetched. Each element in
    rlenp is the length of the data in the corresponding element in the row after
    the fetch.
    rcodep (OUT) - pointer to array of column-level return codes
    mode (IN) - the valid modes are:
    OCI_DEFAULT. This is the default mode.
    OCI_DYNAMIC_FETCH. For applications requiring dynamically
    allocated data at the time of fetch, this mode must be used. The user may
    additionally call OCIDefineDynamic() to set up a callback function that
    will be invoked to receive the dynamically allocated buffers and to set
    up the memory allocate/free callbacks and the context for the callbacks.
    valuep and value_sz are ignored in this mode.
    Related Functions
    OCIDefineArrayOfStruct(), OCIDefineDynamic(), OCIDefineObject()




    OCIDefineDynamic()
    Name
    OCI Define Dynamic Fetch Attributes
    Purpose
    This call is used to set the additional attributes required if the
    OCI_DYNAMIC_FETCH mode was selected in OCIDefineByPos().
    Syntax
    sword OCIDefineDynamic( OCIDefine        *defnp,
                        OCIError        *errhp,
                        dvoid                *octxp,
                        OCICallbackDefine (ocbfp)(
                        dvoid                            *octxp,
                        OCIDefine                    *defnp,
                        ub4                                iter,
                        dvoid                            **bufpp,
                        ub4                                **alenpp,
                        ub1                                *piecep,
                        dvoid                            **indpp,
                        ub2                                **rcodep)    );
    Comments
    This call is used to set the additional attributes required if the
    OCI_DYNAMIC_FETCH mode has been selected in a call to
    OCIDefineByPos().
    When the OCI_DYNAMIC_FETCH mode is selected, buffers will be
    dynamically allocated for REF, and named data type, values to receive the
    data. The pointers to these buffers will be returned.
    If OCI_DYNAMIC_FETCH mode was selected, and the call to
    OCIDefineDynamic() is skipped, then the application can fetch data piecewise
    using OCI calls.
    For more information about OCI_DYNAMIC_FETCH mode, see the section
    "Runtime Data Allocation and Piecewise Operations" on page 5-16.
    Parameters
    defnp (IN/OUT) - the handle to a define structure returned by a call to
    OCIDefineByPos().
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    octxp (IN) - points to a context for the callback function.
    ocbfp (IN) - points to a callback function. This is invoked at runtime to get
    a pointer to the buffer into which the fetched data or a piece of it will be
    retreived. The callback also specifies the indicator, the return code and the
    lengths of the data piece and indicator. The callback has the following
    parameters:
    octxp (IN) - a context pointer passed as an argument to all the callback
    functions.
    defnp (IN) - the define handle.
    iter (IN) - which row of this current fetch.
    bufpp (OUT) - returns a pointer to a buffer to store the column value, ie.
    *bufp points to some appropriate storage for the column value.
    alenpp (OUT) - returns a pointer to the length of the buffer. *alenpp
    contains the size of the buffer after return from callback. Gets set to
    actual data size after fetch.
    piecep (IN/OUT) - returns a piece value, as follows:
    The IN value can be OCI_ONE_PIECE, OCI_FIRST_PIECE or
    OCI_NEXT_PIECE.
    The OUT value can be OCI_ONE_PIECE if the IN value was
    OCI_ONE_PIECE.
    The OUT value can be OCI_ONE_PIECE or OCI_FIRST_PIECE if
    the IN value was OCI_FIRST_PIECE.
    The OUT value can only be OCI_NEXT_PIECE or
    OCI_LAST_PIECE if the IN value was OCI_NEXT_PIECE.
    indpp (IN) - indicator variable pointer
    rcodep (IN) - return code variable pointer
    Related Functions
    OCIAttrGet()
    OCIDefineObject()




    OCIDefineObject()
    Name
    OCI Define Named Data Type attributes
    Purpose
    Sets up additional attributes necessary for a Named Data Type define.
    Syntax
    sword OCIDefineObject ( OCIDefine                *defnp,
                        OCIError                *errhp,
                        CONST OCIType        *type,
                        dvoid                        **pgvpp,
                        ub4                            *pvszsp,
                        dvoid                        **indpp,
                        ub4                            *indszp );
    Comments
    This call sets up additional attributes necessary for a Named Data Type define.
    An error will be returned if this function is called when the OCI environment
    has been initialized in non-Object mode.
    This call takes as a paramter a type descriptor object (TDO) of datatype
    OCIType for the named data type being defined.    The TDO can be retrieved
    with a call to OCITypeByName().
    See the description of OCIInitialize() on page 13 - 43 for more information
    about initializing the OCI process environment.
    Parameters
    defnp (IN/OUT) - a define handle previously allocated in a call to
    OCIDefineByPos().
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    type (IN, optional) - points to the Type Descriptor Object (TDO) which
    describes the type of the program variable. Only used for program variables
    of type SQLT_NTY. This parameter is optional, and may be passed as NULL
    if it is not being used.
    pgvpp (IN/OUT) - points to a pointer to a program variable buffer. For an
    array, pgvpp points to an array of pointers. Memory for the fetched named data
    type instance(s) is dynamically allocated in the object cache. At the end of
    the fetch when all the values have been received, pgvpp points to the
    pointer(s) to these newly allocated named data type instance(s). The
    application must call OCIObjectMarkDel() to deallocate the named data type
    instance(s) when they are no longer needed.
    pvszsp (IN/OUT) - points to the size of the program variable. For an array, it
    is an array of ub4s. On return points to the size(s) of unpickled fetched
    values.
    indpp (IN/OUT) - points to a pointer to the program variable buffer
    containing the parallel indicator structure. For an array, points to an array
    of pointers. Memory is allocated to store the indicator structures in the
    object cache. At the end of the fetch when all values have been received,
    indpp points to the pointer(s) to these newly allocated indicator structure(s).
    indszp (IN/OUT) - points to the size(s) of the indicator structure program
    variable. For an array, it is an array of ub4s. On return points to the size(s)
    of the unpickled fetched indicator values.
    Related Functions
    OCIAttrGet()



    OCIDescAlloc()
    Name
    OCI Get DESCriptor or lob locator
    Purpose
    Allocates storage to hold certain data types. The descriptors can be used as
    bind or define variables.
    Syntax
    sword OCIDescAlloc ( CONST dvoid        *parenth,
                dvoid                    **descpp,
                ub4                        type,
                size_t                xtramem_sz,
                dvoid                    **usrmempp);
    Comments
    Returns a pointer to an allocated and initialized structure, corresponding to
    the type specified in type. A non-NULL descriptor or LOB locator is returned
    on success. No diagnostics are available on error.
    This call returns OCI_SUCCESS if successful, or OCI_INVALID_HANDLE if
    an out-of-memory error occurs.
    Parameters
    parenth (IN) - an environment handle.
    descpp (OUT) - returns a descriptor or LOB locator of desired type.
    type (IN) - specifies the type of descriptor or LOB locator to be allocated.
    The specific types are:
    OCI_DTYPE_SNAP - specifies generation of snapshot descriptor of C
    type - OCISnapshot
    OCI_DTYPE_LOB - specifies generation of a LOB data type locator of C
    type - OCILobLocator
    OCI_DTYPE_RSET - specifies generation of a descriptor of C type
    OCIResult that references a result set (a number of rows as a result of a
    query). This descriptor is bound to a bind variable of data type
    SQLT_RSET (result set). The descriptor has to be converted into a
    statement handle using a function - OCIResultSetToStmt() - which can
    then be passed to OCIDefineByPos() and OCIStmtFetch() to retrieve the
    rows of the result set.
    OCI_DTYPE_ROWID - specifies generation of a ROWID descriptor of C
    type OCIRowid.
    OCI_DTYPE_COMPLEXOBJECTCOMP - specifies generation of a
    complex object retrieval descriptor of C type
    OCIComplexObjectComp.
    xtramemsz (IN) - specifies an amount of user memory to be allocated for use
    by the application.
    usrmempp (OUT) - returns a pointer to the user memory of size xtramemsz
    allocated by the call for the user.
    Related Functions
    OCIDescFree()




    OCIDescFree()
    Name
    OCI Free DESCriptor
    Purpose
    Deallocates a previously allocated descriptor.
    Syntax
    sword OCIDescFree ( dvoid        *descp,
                ub4            type);
    Comments
    This call frees up storage associated with the descriptor, corresponding to the
    type specified in type. Returns OCI_SUCCESS or OCI_INVALID_HANDLE.
    All descriptors must be explicitly deallocated. OCI will not deallocate a
    descriptor if the environment handle is deallocated.
    Parameters
    descp (IN) - an allocated descriptor.
    type (IN) - specifies the type of storage to be freed. The specific types are:
    OCI_DTYPE_SNAP - snapshot descriptor
    OCI_DTYPE_LOB - a LOB data type descriptor
    OCI_DTYPE_RSET - a descriptor that references a result set (a number
    of rows as a result of a query).
    OCI_DTYPE_ROWID - a ROWID descriptor
    OCI_DTYPE_COMPLEXOBJECTCOMP - a complex object retrieval
    descriptor
    Related Functions
    OCIDescAlloc()



    OCIDescribeAny()
    Name
    OCI DeSCribe Any
    Purpose
    Describes existing schema objects.
    Syntax
    sword OCIDescribeAny ( OCISvcCtx            *svchp,
                    OCIError            *errhp,
                    dvoid                    *objptr,
                    ub4                        objnm_len,
                    ub1                        objptr_typ,
                    ub1                        info_level,
                    ub1                        objtype,
                    OCIDesc                *dschp );
    Comments
    This is a generic describe call that describes existing schema objects: tables,
    views, synonyms, procedures, functions, packages, sequences, and types. As a
    result of this call, the describe handle is populated with the object-specific
    attributes which can be obtained through an OCIAttrGet() call.
    An OCIParamGet() on the describe handle returns a parameter descriptor for a
    specified position. Parameter positions begin with 1. Calling OCIAttrGet() on
    the parameter descriptor returns the specific attributes of a stored procedure
    or function parameter or a table column descriptor as the case may be.
    These subsequent calls do not need an extra round trip to the server because
    the entire schema object description cached on the client side by
    OCIDescribeAny(). Calling OCIAttrGet() on the describe handle can also return
    the total number of positions.
    See the section "Describing" on page 2-33 for more information about describe
    operations.
    Parameters
    TO BE UPDATED
    svchp (IN/OUT) - a service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    objptr (IN) - the name of the object (a null-terminated string) to be
    described. Only procedure or function names are valid when connected to an
    Oracle7 Server.
    objptr_len (IN) - the length of the string. Must be non-zero.
    objptr_typ (IN) - Must be OCI_OTYPE_NAME, OCI_OTYPE_REF, or OCI_OTYPE_PTR.
    info_level (IN) - reserved for future extensions. Pass OCI_DEFAULT.
    objtype (IN/OUT) - object type.
    dschp (IN/OUT) - a describe handle that is populated with describe
    information about the object after the call.
    Related Functions
    OCIAttrGet()



    OCIEnvCreate()
    Name
    OCI ENVironment CREATE
    Purpose
    This function creates and initializes an environment for the rest of
    the OCI functions to work under.    This call is a replacement for both
    the OCIInitialize and OCIEnvInit calls.
    Syntax
    sword OCIEnvCreate    ( OCIEnv                **envhpp,
                        ub4                        mode,
                        CONST dvoid        *ctxp,
                        CONST dvoid        *(*malocfp)
                            (dvoid *ctxp,
                        size_t size),
                        CONST dvoid        *(*ralocfp)
                            (dvoid *ctxp,
                                dvoid *memptr,
                                size_t newsize),
                        CONST void        (*mfreefp)
                            ( dvoid *ctxp,
                                dvoid *memptr))
                        size_t        xtramemsz,
                        dvoid            **usrmempp );

    Comments
    This call creates an environment for all the OCI calls using the modes
    specified by the user. This call can be used instead of the two calls
    OCIInitialize and OCIEnvInit. This function returns an environment handle
    which is then used by the remaining OCI functions. There can be multiple
    environments in OCI each with its own environment modes.    This function
    also performs any process level initialization if required by any mode.
    For example if the user wants to initialize an environment as OCI_THREADED,
    then all libraries that are used by OCI are also initialized in the
    threaded mode.

    This call should be invoked before anny other OCI call and should be used
    instead of the OCIInitialize and OCIEnvInit calls. This is the recommended
    call, although OCIInitialize and OCIEnvInit calls will still be supported
    for backward compatibility.

    envpp (OUT) - a pointer to a handle to the environment.
    mode (IN) - specifies initialization of the mode. The valid modes are:
    OCI_DEFAULT - default mode.
    OCI_THREADED - threaded environment. In this mode, internal data
    structures are protected from concurrent accesses by multiple threads.
    OCI_OBJECT - will use navigational object interface.
    ctxp (IN) - user defined context for the memory call back routines.
    malocfp (IN) - user-defined memory allocation function. If mode is
    OCI_THREADED, this memory allocation routine must be thread safe.
    ctxp - context pointer for the user-defined memory allocation function.
    size - size of memory to be allocated by the user-defined memory
    allocation function
    ralocfp (IN) - user-defined memory re-allocation function. If mode is
    OCI_THREADED, this memory allocation routine must be thread safe.
    ctxp - context pointer for the user-defined memory reallocation
    function.
    memp - pointer to memory block
    newsize - new size of memory to be allocated
    mfreefp (IN) - user-defined memory free function. If mode is
    OCI_THREADED, this memory free routine must be thread safe.
    ctxp - context pointer for the user-defined memory free function.
    memptr - pointer to memory to be freed
    xtramemsz (IN) - specifies the amount of user memory to be allocated.
    usrmempp (OUT) - returns a pointer to the user memory of size xtramemsz
    allocated by the call for the user.

    Example

    Related Functions
    OCIInitialize, OCIEnvInit

    OCIEnvNlsCreate()
    Name
    OCI ENVironment CREATE with NLS info
    Purpose
    This function does almost everything OCIEnvCreate does, plus enabling setting
    of charset and ncharset programmatically, except OCI_UTF16 mode.
    Syntax
    sword OCIEnvNlsCreate(OCIEnv                **envhpp,
                        ub4                        mode,
                        dvoid                    *ctxp,
                        dvoid                    *(*malocfp)
                            (dvoid *ctxp,
                        size_t size),
                        dvoid                    *(*ralocfp)
                            (dvoid *ctxp,
                                dvoid *memptr,
                                size_t newsize),
                        void                    (*mfreefp)
                            (dvoid *ctxp,
                                dvoid *memptr),
                        size_t                xtramemsz,
                        dvoid                    **usrmempp,
                        ub2                        charset,
                        ub2                        ncharset)
    Comments
    The charset and ncharset must be both zero or non-zero.
    The parameters have the same meaning as the ones in OCIEnvCreate().
    When charset or ncharset is non-zero, the corresponding character set will
    be used to replace the ones specified in NLS_LANG or NLS_NCHAR. Moreover,
    OCI_UTF16ID is allowed to be set as charset and ncharset.
    On the other hand, OCI_UTF16 mode is deprecated with this function.
    Applications can achieve the same effects by setting
    both charset and ncharset as OCI_UTF16ID.


    OCIEnvInit()
    Name
    OCI INITialize environment
    Purpose
    This call initializes the OCI environment handle.
    Syntax
    sword OCIEnvInit ( OCIEnv        **envp,
            ub4                mode,
            size_t        xtramemsz,
            dvoid            **usrmempp );
    Comments
    Initializes the OCI environment handle. No changes are done on an initialized
    handle. If OCI_ERROR or OCI_SUCCESS_WITH_INFO is returned, the
    environment handle can be used to obtain ORACLE specific errors and
    diagnostics.
    This call is processed locally, without a server round-trip.
    Parameters
    envpp (OUT) - a pointer to a handle to the environment.
    mode (IN) - specifies initialization of an environment mode. The only valid
    mode is OCI_DEFAULT for default mode
    xtramemsz (IN) - specifies the amount of user memory to be allocated.
    usrmempp (OUT) - returns a pointer to the user memory of size xtramemsz
    allocated by the call for the user.
    Example
    See the description of OCISessionBegin() on page 13-84 for an example showing
    the use of OCIEnvInit().
    Related Functions




    OCIErrorGet()
    Name
    OCI Get Diagnostic Record
    Purpose
    Returns an error message in the buffer provided and an ORACLE error.
    Syntax
    sword OCIErrorGet ( dvoid            *hndlp,
                ub4                recordno,
                OraText                *sqlstate,
                ub4                *errcodep,
                OraText                *bufp,
                ub4                bufsiz,
                ub4                type );
    Comments
    Returns an error message in the buffer provided and an ORACLE error.
    Currently does not support SQL state. This call can be called a multiple
    number of times if there are more than one diagnostic record for an error.
    The error handle is originally allocated with a call to OCIHandleAlloc().
    Parameters
    hndlp (IN) - the error handle, in most cases, or the environment handle (for
    errors on OCIEnvInit(), OCIHandleAlloc()).
    recordno (IN) - indicates the status record from which the application seeks
    info. Starts from 1.
    sqlstate (OUT) - Not supported in Version 8.0.
    errcodep (OUT) - an ORACLE Error is returned.
    bufp (OUT) - the error message text is returned.
    bufsiz (IN) - the size of the buffer provide to get the error message.
    type (IN) - the type of the handle.
    Related Functions
    OCIHandleAlloc()

    OCIExtractInit
    Name
    OCI Extract Initialize
    Purpose
    This function initializes the parameter manager.
    Syntax
    sword OCIExtractInit(dvoid *hndl, OCIError *err);
    Comments
    It must be called before calling any other parameter manager routine. The NLS
    information is stored inside the parameter manager context and used in
    subsequent calls to OCIExtract routines.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    Related Functions
    OCIExtractTerm()

    OCIExtractTerm
    Name
    OCI Extract Terminate
    Purpose
    This function releases all dynamically allocated storage and may perform
    other internal bookkeeping functions.
    Syntax
    sword OCIExtractTerm(dvoid *hndl, OCIError *err);
    Comments
    It must be called when the parameter manager is no longer being used.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    Related Functions
    OCIExtractInit()

    OCIExtractReset
    Name
    OCI Extract Reset
    Purpose
    The memory currently used for parameter storage, key definition storage, and
    parameter value lists is freed and the structure is reinitialized.
    Syntax
    sword OCIExtractReset(dvoid *hndl, OCIError *err);
    Comments
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    Related Functions

    OCIExtractSetNumKeys
    Name
    OCI Extract Set Number of Keys
    Purpose
    Informs the parameter manager of the number of keys that will be registered.
    Syntax
    sword OCIExtractSetNumKeys(dvoid *hndl, OCIError *err, uword numkeys);
    Comments
    This routine must be called prior to the first call of OCIExtractSetKey().
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    numkeys (IN) - The number of keys that will be registered with
                    OCIExtractSetKey().
    Related Functions
    OCIExtractSetKey()

    OCIExtractSetKey
    Name
    OCI Extract Set Key definition
    Purpose
    Registers information about a key with the parameter manager.
    Syntax
    sword OCIExtractSetKey(dvoid *hndl, OCIError *err, CONST OraText *name,
                        ub1 type, ub4 flag, CONST dvoid *defval,
                        CONST sb4 *intrange, CONST OraText *CONST *strlist);
    Comments
    This routine must be called after calling OCIExtractSetKey() and before
    calling OCIExtractFromFile() or OCIExtractFromStr().
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    name (IN) - The name of the key.
    type (IN) - The type of the key (OCI_EXTRACT_TYPE_INTEGER,
                OCI_EXTRACT_TYPE_OCINUM, OCI_EXTRACT_TYPE_STRING, or
                OCI_EXTRACT_TYPE_BOOLEAN).
    flag (IN) - Set to OCI_EXTRACT_MULTIPLE if the key can take multiple values
                or 0 otherwise.
    defval (IN) - Set to the default value for the key.    May be NULL if there is
                    no default.    A string default must be a (text*) type, an
                    integer default must be an (sb4*) type, and a boolean default
                    must be a (ub1*) type.
    intrange (IN) - Starting and ending values for the allowable range of integer
            values.    May be NULL if the key is not an integer type or if
            all integer values are acceptable.
    strlist (IN) - List of all acceptable text strings for the key.    May be NULL
                    if the key is not a string type or if all text values are
                    acceptable.
    Related Functions
    OCIExtractSetNumKeys()

    OCIExtractFromFile
    Name
    OCI Extract parameters From File
    Purpose
    The keys and their values in the given file are processed.
    Syntax
    sword OCIExtractFromFile(dvoid *hndl, OCIError *err, ub4 flag,
                OraText *filename);
    Comments
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    flag (IN) - Zero or has one or more of the following bits set:
            OCI_EXTRACT_CASE_SENSITIVE, OCI_EXTRACT_UNIQUE_ABBREVS, or
            OCI_EXTRACT_APPEND_VALUES.
    filename (IN) - Null-terminated filename string.
    Related Functions

    OCIExtractFromStr
    Name
    OCI Extract parameters From String
    Purpose
    The keys and their values in the given string are processed.
    Syntax
    sword OCIExtractFromStr(dvoid *hndl, OCIError *err, ub4 flag, OraText *input);
    Comments
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    flag (IN) - Zero or has one or more of the following bits set:
            OCI_EXTRACT_CASE_SENSITIVE, OCI_EXTRACT_UNIQUE_ABBREVS, or
            OCI_EXTRACT_APPEND_VALUES.
    input (IN) - Null-terminated input string.
    Related Functions

    OCIExtractToInt
    Name
    OCI Extract To Integer
    Purpose
    Gets the integer value for the specified key.
    Syntax
    sword OCIExtractToInt(dvoid *hndl, OCIError *err, OraText *keyname,
                        uword valno, sb4 *retval);
    Comments
    The valno'th value (starting with 0) is returned.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, OCI_NO_DATA, or OCI_ERROR.
    OCI_NO_DATA means that there is no valno'th value for this key.
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    keyname (IN) - Key name.
    valno (IN) - Which value to get for this key.
    retval (OUT) - The actual integer value.
    Related Functions

    OCIExtractToBool
    Name
    OCI Extract To Boolean
    Purpose
    Gets the boolean value for the specified key.
    Syntax
    sword OCIExtractToBool(dvoid *hndl, OCIError *err, OraText *keyname,
                        uword valno, ub1 *retval);
    Comments
    The valno'th value (starting with 0) is returned.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, OCI_NO_DATA, or OCI_ERROR.
    OCI_NO_DATA means that there is no valno'th value for this key.
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    keyname (IN) - Key name.
    valno (IN) - Which value to get for this key.
    retval (OUT) - The actual boolean value.
    Related Functions

    OCIExtractToStr
    Name
    OCI Extract To String
    Purpose
    Gets the string value for the specified key.
    Syntax
    sword OCIExtractToStr(dvoid *hndl, OCIError *err, OraText *keyname,
                        uword valno, OraText *retval, uword buflen);
    Comments
    The valno'th value (starting with 0) is returned.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, OCI_NO_DATA, or OCI_ERROR.
    OCI_NO_DATA means that there is no valno'th value for this key.
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    keyname (IN) - Key name.
    valno (IN) - Which value to get for this key.
    retval (OUT) - The actual null-terminated string value.
    buflen (IN) - The length of the buffer for retval.
    Related Functions

    Note: The following OCIExtract functions are unavailable in this release

    OCIExtractToOCINum
    Name
    OCI Extract To OCI Number
    Purpose
    Gets the OCINumber value for the specified key.
    Syntax
    sword OCIExtractToOCINum(dvoid *hndl, OCIError *err, OraText *keyname,
                uword valno, OCINumber *retval);
    Comments
    The valno'th value (starting with 0) is returned.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, OCI_NO_DATA, or OCI_ERROR.
    OCI_NO_DATA means that there is no valno'th value for this key.
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    keyname (IN) - Key name.
    valno (IN) - Which value to get for this key.
    retval (OUT) - The actual OCINumber value.
    Related Functions

    OCIExtractToList
    Name
    OCI Extract To parameter List
    Purpose
    Generates a list of parameters from the parameter structures that are stored
    in memory.
    Syntax
    sword OCIExtractToList(dvoid *hndl, OCIError *err, uword *numkeys);
    Comments
    Must be called before OCIExtractValues() is called.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    numkeys (OUT) - Number of distinct keys stored in memory.
    Related Functions
    OCIExtractFromList()

    OCIExtractFromList
    Name
    OCI Extract From parameter List
    Purpose
    Generates a list of values for the a parameter in the parameter list.
    Syntax
    sword OCIExtractFromList(dvoid *hndl, OCIError *err, uword index,
                OraText *name, ub1 *type, uword *numvals,
                dvoid*** values);
    Comments
    Parameters are specified by an index. OCIExtractToList() must be called prior
    to calling this routine to generate the parameter list from the parameter
    structures that are stored in memory.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN) - The OCI environment or session handle.
    err (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
                    err and this function returns OCI_ERROR. Diagnostic information
                    can be obtained by calling OCIErrorGet().
    name (OUT) - Name of the key for the current parameter.
    type (OUT) - Type of the current parameter (OCI_EXTRACT_TYPE_STRING,
                OCI_EXTRACT_TYPE_INTEGER, OCI_EXTRACT_TYPE_OCINUM, or
                OCI_EXTRACT_TYPE_BOOLEAN)
    numvals (OUT) - Number of values for this parameter.
    values (OUT) - The values for this parameter.
    Related Functions
    OCIExtractToList()


    ************************    OCIFileClose() ***********************************

    Name
    OCIFileClose - Oracle Call Interface FILE i/o CLOSE

    Purpose
    Close a previously opened file.

    Syntax
    sword OCIFileClose ( dvoid                            *hndl,
                        OCIError                    *err,
                        OCIFileObject            *filep )

    Comments
    This function will close a previously opened file. If the function succeeds
    then OCI_SUCCESS will be returned, else OCI_ERROR.

    Parameters
    hndl    (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle
    filep (IN) - the OCIFile file object

    Related Functions
    OCIFileOpen.



    ********************* OCIFileExists() **************************************

    Name
    OCIFileExists - Oracle Call Interface FILE i/o EXIST

    Purpose
    Check to see if the file exists.

    Syntax
    sword OCIFileExists ( dvoid                        *hndl,
                        OCIError                    *err,
                        OraText                    *filename,
                        OraText                    *path,
                        ub1                            *flag )

    Comments
    This function will set the flag to TRUE if the file exists else it will
    be set to FALSE.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl(IN) - OCI environment or session handle
    err(OUT) - OCI error handle
    filename(IN) - filename
    path(IN) - path of the file
    flag(OUT) - whether the file exists or not

    Related Functions.
    None.


    **************************** OCIFileFlush() ******************************


    Name
    OCIFileFlush - Oracle Call Interface File i/o FLUSH

    Purpose
    Flush the buffers associated with the file to the disk.

    Syntax
    sword OCIFileFlush ( dvoid                            *hndl,
                        OCIError                    *err,
                        OCIFileObject            *filep )

    Comments
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle
    filep (IN) - the OCIFile file object

    Related Functions
    OCIFileOpen, OCIFileWrite



    *************************** OCIFileGetLength() ****************************

    Name
    OCIFileGetLength - Oracle Call Interface FILE i/o GET file LENGTH

    Purpose
    Get the length of a file.

    Syntax
    OCIFileGetLength(dvoid                        *hndl,
                OCIError                *err,
                OraText                    *filename,
                OraText                    *path,
                ubig_ora                *lenp )

    Comments
    The length of the file will be returned in lenp.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle.    If    there is an error, it is recorded
    in err and this function returns OCI_ERROR.    Diagnostic information can be
    obtained by calling OCIErrorGet().
    filename (IN) - file name.
    path (IN) - path of the file.
    lenp (OUT) - On output, it is the length of the file in bytes.
    is the number of bytes in the file.

    Related Functions
    None.



    ******************************** OCIFileInit() *****************************

    Name
    OCIFileInit - Oracle Call Interface FILE i/o INITialize

    Purpose
    Initialize the OCI File I/O package and create the OCIFile context.

    Syntax
    sword OCIFileInit ( dvoid *hndl,
                    OCIError *err)

    Comments
    This function should be called before any of the OCIFile functions are
    used.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl(IN) - OCI environment or session handle.
    err(OUT) - OCI error structure.

    Related Functions
    OCIFileTerm



    ********************************* OCIFileOpen() *****************************

    Name
    OCIFileOpen - Oracle Call Interface File i/o OPEN

    Purpose
            Open a file.

    Syntax
    sword OCIFileOpen ( dvoid                                *hndl,
                    OCIError                        *err,
                    OCIFileObject            **filep,
                    OraText                            *filename,
                    OraText                            *path,
                    ub4                                    mode,
                    ub4                                    create,
                    ub4                                    type )

    Comments
    OCIFileOpen returns a handle to the open file in filep if the file is
    successfully opened.
    If one wants to use the standard file objects (stdin, stdout & stderr)
    then OCIFileOpen whould be called with the type filed containing the
    appropriate type (see the parameter type). If any of the standard files
    are specified then filename, path, mode and create are ignored.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (OUT) - the OCI environment or session handle.
    err (OUT) - the OCI error handle.    If    there is an error, it is recorded
    in err and this function returns OCI_ERROR.    Diagnostic information can be
    obtained by calling OCIErrorGet().
    filep (OUT) - the file object to be returned.
    filename (IN) - file name (NULL terminated string).
    path (IN) - path of the file (NULL terminated string).
    mode - mode in which to open the file (valid modes are OCI_FILE_READONLY,
    OCI_FILE_WRITEONLY, OCI_FILE_READ_WRITE).
    create - should the file be created if it does not exist. Valid values
    are:
            OCI_FILE_TRUNCATE - create a file regardless of whether or not it exists.
                If the file already exists overwrite it.
            OCI_FILE_EXIST - open it if it exists, else fail.
            OCI_FILE_EXCL - fail if the file exists, else create.
            OCI_FILE_CREATE - open the file if it exists, and create it if it doesn't.
            OCI_FILE_APPEND - set the file pointer to the end of the file prior to
                        writing(this flag can be OR'ed with OCI_FILE_EXIST or
                        OCI_FILE_CREATE).
    type - file type. Valid values are OCI_FILE_TEXT, OCI_FILE_BIN,
                OCI_FILE_STDIN, OCI_FILE_STDOUT and OCI_FILE_STDERR.
                If any of the standard files are specified then filename, path, mode
                and create are ignored.

    Related Functions.
    OCIFileClose



    ************************** OCIFileRead() ************************************

    Name
    OCIFileRead - Oracle Call Interface FILE i/o READ

    Purpose
    Read from a file into a buffer.

    Syntax
    sword OCIFileRead ( dvoid                        *hndl,
                    OCIError                    *err,
                    OCIFileObject        *filep,
                    dvoid                        *bufp,
                    ub4                                bufl,
                    ub4                            *bytesread )

    Comments
    Upto bufl bytes from the file will be read into bufp. The user should
    allocate memory for the buffer.
    The number of bytes read would be in bytesread.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle.    If    there is an error, it is recorded
    in err and this function returns OCI_ERROR.    Diagnostic information can be
    obtained by calling OCIErrorGet().
    filep (IN/OUT) - a File Object that uniquely references the file.
    bufp (IN) - the pointer to a buffer into which the data will be read. The
    length of the allocated memory is assumed to be bufl.
    bufl - the length of the buffer in bytes.
    bytesread (OUT) - the number of bytes read.

    Related Functions
    OCIFileOpen, OCIFileSeek, OCIFileWrite



    ****************************** OCIFileSeek() ******************************

    Name
    OCIFileSeek - Oracle Call Interface FILE i/o SEEK

    Purpose
    Perfom a seek to a byte position.

    Syntax
    sword OCIFileSeek ( dvoid                        *hndl,
                    OCIError                *err,
                    OCIFileObject        *filep,
                    uword                        origin,
                    ubig_ora                    offset,
                    sb1                            dir)

    Comments
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle.    If    there is an error, it is recorded
    in err and this function returns OCI_ERROR.    Diagnostic information can be
    obtained by calling OCIErrorGet().
    filep (IN/OUT) - a file handle that uniquely references the file.
    origin - The starting point we want to seek from. NOTE: The starting
    point may be OCI_FILE_SEEK_BEGINNING (beginning), OCI_FILE_SEEK_CURRENT
    (current position), or OCI_FILE_SEEK_END (end of file).
    offset - The number of bytes from the origin we want to start reading from.
    dir - The direction we want to go from the origin. NOTE: The direction
    can be either OCI_FILE_FORWARD or OCI_FILE_BACKWARD.

    Related Function
    OCIFileOpen, OCIFileRead, OCIFileWrite



    *************************** OCIFileTerm() **********************************

    Name
    OCIFileTerm - Oracle Call Interface FILE i/o TERMinate

    Purpose
    Terminate the OCI File I/O package and destroy the OCI File context.

    Syntax
    sword OCIFileTerm ( dvoid *hndl,
                    OCIError *err )

    Comments
    After this function has been called no OCIFile function should be used.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl(IN) - OCI environment or session handle.
    err(OUT) - OCI error structure.

    Related Functions
    OCIFileInit


    ********************************* OCIFileWrite() ****************************

    Name
    OCIFileWrite - Oracle Call Interface FILE i/o WRITE

    Purpose
        Write data from buffer into a file.

    Syntax
    sword OCIFileWrite ( dvoid                        *hndl,
                        OCIError                    *err,
                        OCIFileObject        *filep,
                        dvoid                        *bufp,
                        ub4                                buflen
                        ub4                            *byteswritten )

    Comments
    The number of bytes written will be in *byteswritten.
    The function will return OCI_ERROR if any error is encountered, else
    it will return OCI_ERROR.

    Parameters
    hndl (IN) - the OCI environment or session handle.
    err (OUT) - the OCI error handle.    If    there is an error, it is recorded
    in err and this function returns OCI_ERROR.    Diagnostic information can be
    obtained by calling OCIErrorGet().
    filep (IN/OUT) - a file handle that uniquely references the file.
    bufp (IN) - the pointer to a buffer from which the data will be written.
    The length of the allocated memory is assumed to be the value passed
    in bufl.
    bufl - the length of the buffer in bytes.
    byteswritten (OUT) - the number of bytes written.

    Related Functions
    OCIFileOpen, OCIFileSeek, OCIFileRead





    OCIHandleAlloc()
    Name
    OCI Get HaNDLe
    Purpose
    This call returns a pointer to an allocated and initialized handle.
    Syntax
    sword OCIHandleAlloc ( CONST dvoid        *parenth,
                    dvoid                    **hndlpp,
                    ub4                        type,
                    size_t                xtramem_sz,
                    dvoid                    **usrmempp);
    Comments
    Returns a pointer to an allocated and initialized structure, corresponding to
    the type specified in type. A non-NULL handle is returned on success. Bind
    handle and define handles are allocated with respect to a statement handle. All
    other handles are allocated with respect to an environment handle which is
    passed in as a parent handle.
    No diagnostics are available on error. This call returns OCI_SUCCESS if
    successful, or OCI_INVALID_HANDLE if an out-of-memory error occurs.
    Handles must be allocated using OCIHandleAlloc() before they can be passed
    into an OCI call.
    Parameters
    parenth (IN) - an environment or a statement handle.
    hndlpp (OUT) - returns a handle to a handle type.
    type (IN) - specifies the type of handle to be allocated. The specific types
    are:
    OCI_HTYPE_ERROR - specifies generation of an error report handle of
    C type OCIError
    OCI_HTYPE_SVCCTX - specifies generation of a service context handle
    of C type OCISvcCtx
    OCI_HTYPE_STMT - specifies generation of a statement (application
    request) handle of C type OCIStmt
    OCI_HTYPE_BIND - specifies generation of a bind information handle
    of C type OCIBind
    OCI_HTYPE_DEFINE - specifies generation of a column definition
    handle of C type OCIDefine
    OCI_HTYPE_DESCRIBE    - specifies generation of a select list
    description handle of C type OCIDesc
    OCI_HTYPE_SERVER - specifies generation of a server context handle
    of C type OCIServer
    OCI_HTYPE_SESSION - specifies generation of an authentication
    context handle of C type OCISession
    OCI_HTYPE_TRANS - specifies generation of a transaction context
    handle of C type OCITrans
    OCI_HTYPE_COMPLEXOBJECT - specifies generation of a complex
    object retrieval handle of C type OCIComplexObject
    OCI_HTYPE_SECURITY - specifies generation of a security handle of C
    type OCISecurity
    xtramem_sz (IN) - specifies an amount of user memory to be allocated.
    usrmempp (OUT) - returns a pointer to the user memory of size xtramemsz
    allocated by the call for the user.
    Related Functions
    OCIHandleFree()



    OCIHandleFree()
    Name
    OCI Free HaNDLe
    Purpose
    This call explicitly deallocates a handle.
    Syntax
    sword OCIHandleFree ( dvoid            *hndlp,
                    ub4                type);
    Comments
    This call frees up storage associated with a handle, corresponding to the type
    specified in the type parameter.
    This call returns either OCI_SUCCESS or OCI_INVALID_HANDLE.
    All handles must be explicitly deallocated. OCI will not deallocate a child
    handle if the parent is deallocated.
    Parameters
    hndlp (IN) - an opaque pointer to some storage.
    type (IN) - specifies the type of storage to be allocated. The specific types
    are:
    OCI_HTYPE_ENV - an environment handle
    OCI_HTYPE_ERROR - an error report handle
    OCI_HTYPE_SVCCTX - a service context handle
    OCI_HTYPE_STMT - a statement (application request) handle
    OCI_HTYPE_BIND - a bind information handle
    OCI_HTYPE_DEFINE - a column definition handle
    OCI_HTYPE_DESCRIBE    - a select list description handle
    OCI_HTYPE_SERVER - a server handle
    OCI_HTYPE_SESSION - a user authentication handle
    OCI_HTYPE_TRANS - a transaction handle
    OCI_HTYPE_COMPLEXOBJECT - a complex object retrieval handle
    OCI_HTYPE_SECURITY - a security handle
    Related Functions
    OCIHandleAlloc()




    OCIInitialize()
    Name
    OCI Process Initialize
    Purpose
    Initializes the OCI process environment.
    Syntax
    sword OCIInitialize ( ub4                        mode,
                    CONST dvoid        *ctxp,
                    CONST dvoid        *(*malocfp)
                        ( dvoid *ctxp,
                            size_t size ),
                    CONST dvoid        *(*ralocfp)
                        ( dvoid *ctxp,
                            dvoid *memp,
                            size_t newsize ),
                    CONST void        (*mfreefp)
                        ( dvoid *ctxp,
                            dvoid *memptr ));
    Comments
    This call initializes the OCI process environment.
    OCIInitialize() must be invoked before any other OCI call.
    Parameters
    mode (IN) - specifies initialization of the mode. The valid modes are:
    OCI_DEFAULT - default mode.
    OCI_THREADED - threaded environment. In this mode, internal data
    structures are protected from concurrent accesses by multiple threads.
    OCI_OBJECT - will use navigational object interface.
    ctxp (IN) - user defined context for the memory call back routines.
    malocfp (IN) - user-defined memory allocation function. If mode is
    OCI_THREADED, this memory allocation routine must be thread safe.
    ctxp - context pointer for the user-defined memory allocation function.
    size - size of memory to be allocated by the user-defined memory
    allocation function
    ralocfp (IN) - user-defined memory re-allocation function. If mode is
    OCI_THREADED, this memory allocation routine must be thread safe.
    ctxp - context pointer for the user-defined memory reallocation
    function.
    memp - pointer to memory block
    newsize - new size of memory to be allocated
    mfreefp (IN) - user-defined memory free function. If mode is
    OCI_THREADED, this memory free routine must be thread safe.
    ctxp - context pointer for the user-defined memory free function.
    memptr - pointer to memory to be freed
    Example
    See the description of OCIStmtPrepare() on page 13-96 for an example showing
    the use of OCIInitialize().
    Related Functions

    -------------------------------OCITerminate------------------------------------

    OCITerminate()
    Name
    OCI process Terminate
    Purpose
    Do cleanup before process termination
    Syntax
    sword OCITerminate (ub4 mode);

    Comments
    This call performs    OCI related clean up before the OCI process terminates.
    If the process is running in shared mode then the OCI process is disconnected
    from the shared memory subsystem.

    OCITerminate() should be the last OCI call in any process.

    Parameters
    mode (IN) - specifies different termination modes.

    OCI_DEFAULT - default mode.

    Example

    Related Functions
    OCIInitialize()

    ------------------------ OCIAppCtxSet--------------------------------------
    Name
    OCI Application context Set
    Purpose
    Set an attribute and its value for a particular application context
            namespace
    Syntax
    (sword) OCIAppCtxSet((void *) sesshndl, (dvoid *)nsptr,(ub4) nsptrlen,
                    (dvoid *)attrptr, (ub4) attrptrlen, (dvoid *)valueptr,
                    (ub4) valueptrlen,    errhp, (ub4)mode);

    Comments
    Please note that the information set on the session handle is sent to the server during the next OCIStatementExecute or OCISessionBegin.

    This information is cleared from the session handle, once the information
    has been sent over to the server,and should be setup again if needed.

    Parameters
    sesshndl        (IN/OUT) - Pointer to a session handle
    nsptr            (IN)            - Pointer to namespace string
    nsptrlen        (IN)            - length of the nsptr
    attrptr        (IN)            - Pointer to attribute string
    attrptrlen (IN)            - length of the attrptr
    valueptr        (IN)            - Pointer to value string
    valueptrlen(IN)            - length of the valueptr
    errhp            (OUT)        - Error from the API
    mode                (IN)            - mode of operation (OCI_DEFAULT)

    Returns
    error if any
    Example

    Related Functions
        OCIAppCtxClearAll


    ------------------------ OCIAppCtxClearAll---------------------------------
    Name
    OCI Application Context Clear all attributes in a namespace
    Purpose
    To clear the    values all attributes in a namespace
    Syntax
    (sword) OCIAppCtxClearAll((void *) sesshndl, (dvoid *)nsptr, (ub4) nsptrlen,
                    (OCIError *)errhp, (ub4)mode);

    Comments
    This will clean up the context information on the server side during the next piggy-back to the server.

    Parameters
    sesshndl (IN/OUT) - Pointer to a session handle
    nsptr        (IN)            - Pointer to namespace string where the values of all
                    attributes are cleared
    nsptrlen (IN)            - length of the nsptr
    errhp        (OUT)        - Error from the API
    mode            (IN)            - mode of operation (OCI_DEFAULT)
    Example

    Returns
    error if any

    Related Functions
    OCIAppCtxSet
    ---------------------- OCIIntervalAssign ---------------------------------
    sword OCIIntervalAssign(dvoid *hndl, OCIError *err,
                    CONST OCIInterval *inpinter, OCIInterval *outinter );

        DESCRIPTION
            Copies one interval to another to create a replica
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (IN)    inpinter - Input Interval
            (OUT) outinter - Output Interval
        RETURNS
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_SUCCESS otherwise

    ---------------------- OCIIntervalCheck ------------------------------------
    sword OCIIntervalCheck(dvoid *hndl, OCIError *err, CONST OCIInterval *interval,
                ub4 *valid );

        DESCRIPTION
            Checks the validity of an interval
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (IN)    interval - Interval to be checked
            (OUT) valid            - Zero if the interval is valid, else returns an Ored
        combination of the following codes.

        Macro name                                        Bit number            Error
        ----------                                        ----------            -----
        OCI_INTER_INVALID_DAY                    0x1                        Bad day
        OCI_INTER_DAY_BELOW_VALID            0x2                        Bad DAy Low/high bit (1=low)
        OCI_INTER_INVALID_MONTH                0x4                        Bad MOnth
        OCI_INTER_MONTH_BELOW_VALID        0x8                        Bad MOnth Low/high bit (1=low)
        OCI_INTER_INVALID_YEAR                0x10                    Bad YeaR
        OCI_INTER_YEAR_BELOW_VALID        0x20                    Bad YeaR Low/high bit (1=low)
        OCI_INTER_INVALID_HOUR                0x40                    Bad HouR
        OCI_INTER_HOUR_BELOW_VALID        0x80                    Bad HouR Low/high bit (1=low)
        OCI_INTER_INVALID_MINUTE            0x100                    Bad MiNute
        OCI_INTER_MINUTE_BELOW_VALID    0x200                    Bad MiNute Low/high bit(1=low)
        OCI_INTER_INVALID_SECOND            0x400                    Bad SeCond
        OCI_INTER_SECOND_BELOW_VALID    0x800                    bad second Low/high bit(1=low)
        OCI_INTER_INVALID_FRACSEC            0x1000                Bad Fractional second
        OCI_INTER_FRACSEC_BELOW_VALID 0x2000                Bad fractional second Low/High


        RETURNS
            OCI_SUCCESS if interval is okay
            OCI_INVALID_HANDLE if 'err' is NULL.

    ---------------------- OCIIntervalCompare -----------------------------------
    sword OCIIntervalCompare(dvoid *hndl, OCIError *err, OCIInterval *inter1,
                OCIInterval *inter2, sword *result );

        DESCRIPTION
        Compares two intervals, returns 0 if equal, -1 if inter1 < inter2,
        1 if inter1 > inter2
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            inter1    (IN)        - Interval to be compared
            inter2    (IN)        - Interval to be compared
            result    (OUT)    -        comparison result, 0 if equal, -1 if inter1 < inter2,
                1 if inter1 > inter2

        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR if
        the two input datetimes are not mutually comparable.

    ---------------------- OCIIntervalDivide ------------------------------------
    sword OCIIntervalDivide(dvoid *hndl, OCIError *err, OCIInterval *dividend,
            OCINumber *divisor, OCIInterval *result );

        DESCRIPTION
            Divides an interval by an Oracle Number to produce an interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            dividend    (IN)        - Interval to be divided
            divisor        (IN)        - Oracle Number dividing `dividend'
            result        (OUT)    - resulting interval (dividend / divisor)
        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.

    ---------------------- OCIIntervalFromNumber --------------------
    sword OCIIntervalFromNumber(dvoid *hndl, OCIError *err,
                    OCIInterval *inter, OCINumber *number);
        DESCRIPTION
            Converts an interval to an Oracle Number
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (OUT)    interval - Interval to be converted
            (IN) number - Oracle number result    (in years for YEARMONTH interval
                    and in days for DAYSECOND)
        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR on error.
        NOTES
            Fractional portions of the date (for instance, minutes and seconds if
            the unit chosen is hours) will be included in the Oracle number produced.
            Excess precision will be truncated.

    ---------------------- OCIIntervalFromText ---------------------------------
    sword OCIIntervalFromText( dvoid *hndl, OCIError *err, CONST OraText *inpstr,
            size_t str_len, OCIInterval *result );

        DESCRIPTION
            Given an interval string produce the interval represented by the string.
            The type of the interval is the type of the 'result' descriptor.
        PARAMETERS

            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (IN)    inpstr - Input string
            (IN)    str_len - Length of input string
            (OUT) result - Resultant interval
        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR if
        there are too many fields in the literal string
        the year is out of range (-4713 to 9999)
        if the month is out of range (1 to 12)
        if the day of month is out of range (1 to 28...31)
        if hour is not in range (0 to 23)
        if hour is not in range (0 to 11)
        if minute is not in range (0 to 59)
        if seconds in minute not in range (0 to 59)
        if seconds in day not in range (0 to 86399)
        if the interval is invalid


    ---------------------- OCIIntervalGetDaySecond --------------------

        DESCRIPTION
            Gets values of day second interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        day            (OUT) - number of days
        hour        (OUT) - number of hours
        min            (OUT) - number of mins
        sec            (OUT) - number of secs
        fsec        (OUT) - number of fractional seconds
        result            (IN)    - resulting interval
        RETURNS
        OCI_SUCCESS on success
        OCI_INVALID_HANDLE if 'err' is NULL.


    ---------------------- OCIIntervalGetYearMonth --------------------

        DESCRIPTION
            Gets year month from an interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        year        (OUT)        - year value
        month        (OUT)        - month value
        result            (IN)    - resulting interval
        RETURNS
        OCI_SUCCESS on success
        OCI_INVALID_HANDLE if 'err' is NULL.



    -------------------------- OCIIntervalAdd ------------------------------
    sword OCIIntervalAdd(dvoid *hndl, OCIError *err, OCIInterval *addend1,
                OCIInterval *addend2, OCIInterval *result );
    NAME OCIIntervalAdd - Adds two intervals
    PARAMETERS
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    addend1    (IN)        - Interval to be added
    addend2    (IN)        - Interval to be added
    result        (OUT)    - resulting interval (addend1 + addend2)
    DESCRIPTION
            Adds two intervals to produce a resulting interval
    RETURNS
            OCI_SUCCESS on success
            OCI_ERROR if:
        the two input intervals are not mutually comparable.
        the resulting year would go above SB4MAXVAL
        the resulting year would go below SB4MINVAL
            OCI_INVALID_HANDLE if 'err' is NULL.
    NOTES
            The two input intervals must be mutually comparable

    ---------------------- OCIIntervalSubtract -------------------------------
    sword OCIIntervalSubtract(dvoid *hndl, OCIError *err, OCIInterval *minuend,
                        OCIInterval *subtrahend, OCIInterval *result );
    NAME - OCIIntervalSubtract - subtracts two intervals
    PARAMETERS
    hndl (IN) - Session/Env handle.
    err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
    minuend        (IN)        - interval to be subtracted from
    subtrahend (IN)        - interval subtracted from minuend
    result            (OUT)    - resulting interval (minuend - subtrahend)
    DESCRIPTION
            Subtracts two intervals and stores the result in an interval
    RETURNS
        OCI_SUCCESS on success
        OCI_INVALID_HANDLE if 'err' is NULL.
        OCI_ERROR if:
            the two input intervals are not mutually comparable.
            the resulting leading field would go below SB4MINVAL
            the resulting leading field would go above SB4MAXVAL

    ---------------------- OCIIntervalMultiply ---------------------------------
    sword OCIIntervalMultiply(dvoid *hndl, OCIError *err, CONST OCIInterval *inter,
                OCINumber *nfactor, OCIInterval *result );

        DESCRIPTION
            Multiplies an interval by an Oracle Number to produce an interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            inter    (IN)        - Interval to be multiplied
            nfactor    (IN)        - Oracle Number to be multiplied
            result        (OUT)    - resulting interval (ifactor * nfactor)
        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR if:
        the resulting year would go above SB4MAXVAL
        the resulting year would go below SB4MINVAL


    ---------------------- OCIIntervalSetDaySecond --------------------

        DESCRIPTION
            Sets day second interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        day            (IN) - number of days
        hour        (IN) - number of hours
        min            (IN) - number of mins
        sec            (IN) - number of secs
        fsec        (IN) - number of fractional seconds
        result            (OUT)    - resulting interval
        RETURNS
        OCI_SUCCESS on success
        OCI_INVALID_HANDLE if 'err' is NULL.


    ---------------------- OCIIntervalSetYearMonth --------------------

        DESCRIPTION
            Sets year month interval
        PARAMETERS
        hndl (IN) - Session/Env handle.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        year        (IN)        - year value
        month        (IN)        - month value
        result            (OUT)    - resulting interval
        RETURNS
        OCI_SUCCESS on success
        OCI_INVALID_HANDLE if 'err' is NULL.


    ----------------------- OCIIntervalToNumber ---------------------------------
    sword OCIIntervalToNumber(dvoid *hndl, OCIError *err, CONST OCIInterval *inter,
                    OCINumber *number);

        DESCRIPTION
            Converts an interval to an Oracle Number
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (IN)    inter - Interval to be converted
            (OUT) number - Oracle number result    (in years for YEARMONTH interval
                    and in days for DAYSECOND)
        RETURNS
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_SUCCESS on success
        NOTES
            Fractional portions of the date (for instance, minutes and seconds if
            the unit chosen is hours) will be included in the Oracle number produced.
            Excess precision will be truncated.

    ------------------------------- OCIIntervalToText -------------------------
    sword OCIIntervalToText( dvoid *hndl, OCIError *err, CONST OCIInterval *inter,
                ub1 lfprec, ub1 fsprec, OraText *buffer,
                size_t buflen, size_t *resultlen );

        DESCRIPTION
            Given an interval, produces a string representing the interval.
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            (IN)    inter - Interval to be converted
            (IN)    lfprec    - Leading field precision. Number of digits used to
            represent the leading field.
            (IN)    fsprec    - Fractional second precision of the interval. Number of
            digits used to represent the fractional seconds.
            (OUT) buffer - buffer to hold result
            (IN)    buflen - length of above buffer
            (OUT) resultlen - length of result placed into buffer

        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR
        if the buffer is not large enough to hold the result
        NOTES
            The interval literal will be output as `year' or `[year-]month' for
            YEAR-MONTH intervals and as `seconds' or `minutes[:seconds]' or
            `hours[:minutes[:seconds]]' or `days[ hours[:minutes[:seconds]]]' for
            DAY-TIME intervals (where optional fields are surrounded by brackets).

    ---------------------- OCIIntervalFromTZ --------------------
    sword OCIIntervalFromTZ(dvoid *hndl, OCIError *err, CONST oratext *inpstring,
                size_t str_len, OCIInterval *result);

        DESCRIPTION
            Retuns an OCI_DTYPE_INTERVAL_DS OCIInterval with the region id (if
            the region is specified in the input string) set and the current
            absolute offset or an absolut offset with the region id set to 0.
        PARAMETERS
            hndl (IN) - Session/Env handle.
            err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
            inpstring (IN) - pointer to the input string
            str_len (IN) - inpstring length
            result - Output Interval
        RETURNS
            OCI_SUCCESS on success
            OCI_INVALID_HANDLE if 'err' is NULL.
            OCI_ERROR on error
        Bad interval type
        Timezone errors
        NOTES
            The input string must be of the form [+/-]TZH:TZM or 'TZR [TZD]'

    ----------------------- OCIKerbAttrSet ---------------------
    sword OCIKerbAttrSet(OCISession *trgthndlp, ub4 auth_mode,
                    ub1 *ftgt_ticket, ub4 ftgt_ticket_len,
                    ub1 *ftgt_sesskey, ub4 ftgt_sesskey_len,
                    ub2 ftgt_keytype, ub4 ftgt_ticket_flags,
                    sb4 ftgt_auth_time, sb4 ftgt_start_time,
                    sb4 ftgt_end_time, sb4 ftgt_renew_time,
                    text *ftgt_principal, ub4 ftgt_principal_len,
                    text *ftgt_realm, ub4 ftgt_realm_len,
                    OCIError *errhp);

        DESCRIPTION
            This call sets the attributes required for Kerberos authentication
            on the user handle.

        PARAMETERS
            trgthndlp (IN) - The pointer to a user handle.
            auth_mode (IN) - Indicates what type of Kerberos credentials should
                    be set. Options are:

                    OCI_KERBCRED_PROXY
                        - Set Kerberos credentials for use with
                            proxy authentication.
                    OCI_KERBCRED_CLIENT_IDENTIFIER
                        - Set Kerberos credentials for use
                            with secure client identifier.

            ftgt_ticket (IN) - Forwardable Ticket Granting Ticket (FTGT).
            ftgt_ticket_len (IN) - Length of FTGT.
            ftgt_sesskey(IN) - Session Key associated with FTGT.
            ftgt_sesskey_len (IN) - Length of session key.
            ftgt_keytype (IN) -    Type of encryption key used to encrypt FTGT.
            ftgt_ticket_flags (IN) - Flags associated with    encryption of FTGT.
            ftgt_auth_time (IN) - Authentication time compatible with that in FTGT.
            ftgt_start_time (IN) - Start time compatible with that indicated in FTGT.
            ftgt_end_time (IN) - End time compatible with that indicated in FTGT.
            ftgt_renew_time (IN) - Renew time compatible with that indicated in FTGT.
            ftgt_principal (IN) - Client principal name from FTGT.
            ftgt_principal_len (IN) - Length of client principal name.
            ftgt_realm (IN) - Client realm name from FTGT.
            ftgt_realm_len (IN) - Client realm name length.
            errhp (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        RETURNS
            OCI_SUCCESS on success
            OCI_ERROR on error
        NOTES

    OCILdaToSvcCtx()
    Name
    OCI toggle version 7 Lda_Def to SerVice context handle
    Purpose
    Converts a V7 Lda_Def to a V8 service context handle.
    Syntax
    sword OCILdaToSvcCtx ( OCISvcCtx    **svchpp,
                    OCIError        *errhp,
                    Lda_Def        *ldap );
    Comments
    Converts a V7 Lda_Def to a V8 service context handle. The action of this call
    can be reversed by passing the resulting service context handle to the
    OCISvcCtxToLda() function.
    Parameters
    svchpp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    ldap (IN/OUT) - the V7 logon data area returned by OCISvcCtxToLda() from
    this service context.
    Related Functions
    OCISvcCtxToLda()




    OCILobAppend()

    Name
    OCI Lob APpend

    Purpose
    Appends a LOB value at the end of another LOB.

    Syntax
    sword OCILobAppend ( OCISvcCtx                *svchp,
                OCIError                    *errhp,
                OCILobLocator        *dst_locp,
                OCILobLocator        *src_locp );
    Comments
    Appends a LOB value at the end of LOB. The data is
    copied from the source to the destination at the end of the destination. The
    source and the destination must already exist. The destination LOB is
    extended to accommodate the newly written data.

    It is an error to extend the destination LOB beyond the maximum length
    allowed or to try to copy from a NULL LOB.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    dst_locp (IN/OUT) - a locator uniquely referencing the destination LOB.
    src_locp (IN/OUT) - a locator uniquely referencing the source LOB.

    Related Functions
    OCILobTrim()
    OCIErrorGet()
    OCILobWrite()
    OCILobCopy()



    OCILobAssign()

    Name
    OCI Lob ASsiGn

    Purpose
    Assigns one LOB/FILE locator to another.

    Syntax
    sword OCILobAssign ( OCIEnv                                *envhp,
                    OCIError                            *errhp,
                    CONST OCILobLocator        *src_locp,
                    OCILobLocator                    **dst_locpp );

    Comments
    Assign source locator to destination locator.    After the assignment, both
    locators refer to the same LOB data.    For internal LOBs, the source locator's
    LOB data gets copied to the destination locator's LOB data only when the
    destination locator gets stored in the table.    Therefore, issuing a flush of
    the object containing the destination locator will copy the LOB data. For
    FILEs only the locator that refers to the OS file is copied to the table. The
    OS file is not copied.
    Note: The only difference between this and OCILobLocatorAssign is that this
    takes an environment handle whereas OCILobLocatorAssign takes an OCI service
    handle

    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) - The OCI error handle. If there is an error, it is recorded
    in errhp and this function returns OCI_ERROR. Diagnostic information can be
    obtained by calling OCIErrorGet().
    src_locp (IN) - LOB locator to copy from.
    dst_locpp (IN/OUT) - LOB locator to copy to.    The caller must allocate space
    for the OCILobLocator by calling OCIDescriptorAlloc().

    See also
    OCIErrorGet()
    OCILobIsEqual()
    OCILobLocatorIsInit()
    OCILobLocatorAssign()


    OCILobCharSetForm()

    Name
    OCI Lob Get Character Set Form

    Purpose
    Gets the LOB locator's character set fpr,, if any.

    Syntax
    sword OCILobCharSetForm ( OCIEnv                                        *envhp,
                    OCIError                                    *errhp,
                    CONST OCILobLocator                *locp,
                    ub1                                                *csfrm );

    Comments
    Returns the character set form of the input LOB locator in the csfrm output
    parameter.

    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) - error handle. The OCI error handle. If there is an error, it
    is recorded in err and this function returns OCI_ERROR. Diagnostic
    information can be obtained by calling OCIErrorGet().
    locp (IN) - LOB locator for which to get the character set form.
    csfrm(OUT) - character set form of the input LOB locator.    If the input
    locator is for a BLOB or a BFILE, csfrm is set to 0 since there is no concept
    of a character set for binary LOBs/FILEs.    The caller must allocate space for
    the csfrm (ub1) and not write into the space.
    See also
    OCIErrorGet(), OCILobCharSetId(), OCILobLocatorIsInit



    OCILobCharSetId()

    Name
    OCI Lob get Character Set IDentifier

    Purpose
    Gets the LOB locator's character set ID, if any.

    Syntax
    sword OCILobCharSetId ( OCIEnv                                        *envhp,
                OCIError                                    *errhp,
                CONST OCILobLocator                *locp,
                ub2                                                *csid );

    Comments
    Returns the character set ID of the input LOB locator in the cid output
    parameter.

    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) - error handle. The OCI error handle. If there is an error, it
    is recorded in err and this function returns OCI_ERROR. Diagnostic
    information can be obtained by calling OCIErrorGet().
    locp (IN) - LOB locator for which to get the character set ID.
    csid (OUT) - character set ID of the input LOB locator.    If the input locator
    is for a BLOB or a BFILE, csid is set to 0 since there is no concept of a
    character set for binary LOBs/FILEs.    The caller must allocate space for the
    character set id of type ub2 and not write into the space.

    See also
    OCIErrorGet(), OCILobCharSetForm(), OCILobLocatorIsInit()



    OCILobCopy()

    Name
    OCI Lob Copy

    Purpose
    Copies a portion of a LOB value into another LOB value.

    Syntax
    sword OCILobCopy ( OCISvcCtx                *svchp,
                OCIError                    *errhp,
                OCILobLocator        *dst_locp,
                OCILobLocator        *src_locp,
                ub4                            amount,
                ub4                            dst_offset,
                ub4                            src_offset );

    Comments
    Copies a portion of a LOB value into another LOB as specified. The data
    is copied from the source to the destination. The source (src_locp) and the
    destination (dlopb) LOBs must already exist.
    If the data already exists at the destination's start position, it is
    overwritten with the source data. If the destination's start position is
    beyond the end of the current data, a hole is created from the end of the data
    to the beginning of the newly written data from the source. The destination
    LOB is extended to accommodate the newly written data if it extends
    beyond the current length of the destination LOB.
    It is an error to extend the destination LOB beyond the maximum length
    allowed or to try to copy from a NULL LOB.
    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    dst_locp (IN/OUT) - a locator uniquely referencing the destination LOB.
    src_locp (IN/OUT) - a locator uniquely referencing the source LOB.
    amount (IN) - the number of character or bytes, as appropriate, to be copied.
    dst_offset (IN) - this is the absolute offset for the destination LOB.
    For character LOBs it is the number of characters from the beginning of the
    LOB at which to begin writing. For binary LOBs it is the number of bytes from
    the beginning of the lob from which to begin reading. The offset starts at 1.
    src_offset (IN) - this is the absolute offset for the source LOB.
    For character LOBs it is the number of characters from the beginning of the
    LOB, for binary LOBs it is the number of bytes. Starts at 1.

    See Also
    OCIErrorGet(), OCILobAppend(), OCILobWrite(), OCILobTrim()

    OCILobCreateTemporary()

    Name
    OCI Lob Create Temporary

    Purpose
    Create a Temporary Lob

    Syntax
    sword OCILobCreateTemporary(OCISvcCtx                    *svchp,
                        OCIError                        *errhp,
                        OCILobLocator            *locp,
                        ub2                                    csid,
                        ub1                                    csfrm,
                        ub1                                    lobtype,
                        boolean                            cache,
                        OCIDuration                    duration);


    Comments
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a locator which points to the temporary Lob
    csid (IN) - the character set id
    csfrm(IN) - the character set form
    lobtype (IN) - the lob type - one of the three enumants OCI_TEMP_BLOB,
                    OCI_TEMP_CLOB and OCI_TEMP_NCLOB
    cache(IN)-    TRUE if the temporary LOB goes through the cache; FALSE, if not.
    duration(IN)- duration of the temporary LOB; Can be a valid duration id or one
                    of the values: OCI_DURATION_SESSION, OCI_DURATION_CALL
                    Note: OCI_DURATION_TRANSACTION is NOT supported in 8.1
    Related functions
    OCILobFreeTemporary()
    OCILobIsTemporary()

    OCILobDisableBuffering()

    Name
    OCI Lob Disable Buffering

    Purpose
    Disable lob buffering for the input locator.


    Syntax
    sword OCILobDisableBuffering ( OCISvcCtx            *svchp,
                            OCIError                *errhp,
                            OCILobLocator    *locp);

    Comments

    Disable lob buffering for the input locator.    The next time data is
    read/written from/to the lob through the input locator, the lob
    buffering subsystem is *not* used.    Note that this call does *not*
    implicitly flush the changes made in the buffering subsystem.    The
    user must explicitly call OCILobFlushBuffer() to do this.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a locator uniquely referencing the LOB.

    Related Functions
    OCILobEnableBuffering()
    OCIErrorGet()
    OCILobFlushBuffer()




    OCILobEnableBuffering()

    Name
    OCI Lob Enable Buffering

    Purpose
    Enable lob buffering for the input locator.


    Syntax
    sword OCILobEnableBuffering ( OCISvcCtx            *svchp,
                            OCIError                *errhp,
                            OCILobLocator    *locp);

    Comments

    Enable lob buffering for the input locator.    The next time data is
    read/written from/to the lob through the input locator, the lob
    buffering subsystem is used.

    Once lob buffering is enabled for a locator, if that locator is passed to
    one of the following routines, an error is returned:
        OCILobCopy, OCILobAppend, OCILobErase, OCILobGetLength, OCILobTrim

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a locator uniquely referencing the LOB.

    Related Functions
    OCILobDisableBuffering()
    OCIErrorGet()
    OCILobWrite()
    OCILobRead()
    OCILobFlushBuffer()




    OCILobErase()

    Name
    OCI Lob ERase

    Purpose
    Erases a specified portion of the LOB data starting at a specified offset.

    Syntax
    sword OCILobErase ( OCISvcCtx                *svchp,
                OCIError                *errhp,
                OCILobLocator        *locp,
                ub4                            *amount,
                ub4                            offset );

    Comments
    Erases a specified portion of the LOB data starting at a specified offset.
    The actual number of characters/bytes erased is returned. The actual number
    of characters/bytes and the requested number of characters/bytes will differ
    if the end of the LOB data is reached before erasing the requested number of
    characters/bytes.
    If a section of data from the middle of the LOB data is erased, a hole is
    created. When data from that hole is read, 0's are returned. If the LOB is
    NULL, this routine will indicate that 0 characters/bytes were erased.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - the LOB for which to erase a section of data.
    amount (IN/OUT) - On IN, the number of characters/bytes to erase. On OUT,
    the actual number of characters/bytes erased.
    offset (IN) - absolute offset from the beginning of the LOB data from which
    to start erasing data. Starts at 1.

    See Also
    OCIErrorGet(), OCILobRead(), OCILobWrite()

    OCILobOpen()

    Name
    OCI Lob Open

    Purpose
    Opens an internal or external Lob.

    Syntax
    sword OCILobOpen( OCISvcCtx                *svchp,
                OCIError                    *errhp,
                OCILobLocator        *locp,
                ub1                                mode );

    Comments
    It is an error if the same lob is opened more than once in
    the same transaction. Lobs are opened implicitly if they are
    not opened before using them. A LOB has to be closed before
    the transaction commits else the transaction is rolled back.
    Open locators are closed if the transaction aborts. Multiple
    users can open the same lob on different locators.
    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - locator points to the LOB to be opened
    mode (IN) - mode in which to open the lob. The valid modes are
    read-only - OCI_FILE_READONLY, read-write - OCI_FILE_READWRITE

    OCILobClose()

    Name
    OCI Lob Close

    Purpose
    Closes an open internal or external Lob.

    Syntax
    sword OCILobClose( OCISvcCtx                *svchp,
                OCIError                    *errhp,
                OCILobLocator        *locp );


    Comments
    It is an error if the lob is not open at this time. All LOBs
    that have been opened in a transaction have to be closed
    before the transaction commits, else the transaction gets
    rolled back.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp    (IN)    - A locator that was opened using OCILobOpen()


    OCILobFileClose()

    Name
    OCI Lob File CLoSe

    Purpose
    Closes a previously opened FILE.

    Syntax
    sword OCILobFileClose ( OCISvcCtx                        *svchp,
                OCIError                            *errhp,
                OCILobLocator                *filep );

    Comments
    Closes a previously opened FILE. It is an error if this function is called for
    an internal LOB. No error is returned if the FILE exists but is not opened.
    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    filep (IN/OUT) - a pointer to a FILE locator to be closed.

    See Also
    OCIErrorGet(), OCILobFileOpen(), OCILobFileCloseAll(), OCILobFileIsOpen(),
    OCILobFileExists(), CREATE DIRECTORY DDL




    OCILobFileCloseAll()

    Name
    OCI LOB FILE Close All

    Purpose
    Closes all open FILEs on a given service context.

    Syntax
    sword OCILobFileCLoseAll ( OCISvcCtx *svchp,
                    OCIError    *errhp );

    Comments
    Closes all open FILEs on a given service context.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.

    See also
    OCILobFileClose(),
    OCIErrorGet(), OCILobFileOpen(), OCILobFileIsOpen(),
    OCILobFileExists(), CREATE DIRECTORY DDL




    OCILobFileExists()

    Name
    OCI LOB FILE exists

    Purpose
    Tests to see if the FILE exists on the server

    Syntax
    sword OCILobFileExists ( OCISvcCtx            *svchp,
                OCIError            *errhp,
                OCILobLocator *filep,
                boolean                *flag );

    Comments
    Checks to see if a FILE exists for on the server.

    Parameters
    svchp (IN) - the OCI service context handle.
    errhp (IN/OUT) - error handle. The OCI error handle. If there is an error,
    it is recorded in err and this function returns OCI_ERROR. Diagnostic
    information can be obtained by calling OCIErrorGet().
    filep (IN) - pointer to the FILE locator that refers to the file.
    flag (OUT) - returns TRUE if the FILE exists; FALSE if it does not.

    See also
    OCIErrorGet, CREATE DIRECTORY (DDL)




    OCILobFileGetName()

    Name
    OCI LOB FILE Get file Name

    Purpose
    Gets the FILE locator's directory alias and file name.

    Syntax
    sword OCILobFileGetName ( OCIEnv                                        *envhp,
                    OCIError                                    *errhp,
                    CONST OCILobLocator            *filep,
                    OraText                                            *dir_alias,
                    ub2                                            *d_length,
                    OraText                                            *filename,
                    ub2                                            *f_length );

    Comments
    Returns the directory alias and file name associated with this file locator.

    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) -The OCI error handle. If there is an error, it is recorded in
    errhp and this function returns OCI_ERROR. Diagnostic information can be
    obtained by calling OCIErrorGet().
    filep (IN) - FILE locator for which to get the directory alias and file name.
    dir_alias (OUT) - buffer into which the directory alias name is placed. The
    caller must allocate enough space for the directory alias name and must not
    write into the space.
    d_length (IN/OUT)
        - IN: length of the input dir_alias string;
        - OUT: length of the returned dir_alias string.
    filename (OUT) - buffer into which the file name is placed. The caller must
    allocate enough space for the file name and must not write into the space.
    f_length (IN/OUT)
        - IN: length of the input filename string;
        - OUT: lenght of the returned filename string.

    See also
    OCILobFileSetName(), OCIErrorGet()




    OCILobFileIsOpen()

    Name
    OCI LOB FILE Is Open?

    Purpose
    Tests to see if the FILE is open

    Syntax
    sword OCILobFileIsOpen ( OCISvcCtx *svchp,
                OCIError    *errhp,
                OCILobLocator *filep,
                boolean                *flag );

    Comments
    Checks to see if the FILE on the server is open for a given LobLocator.

    Parameters
    svchp (IN) - the OCI service context handle.
    errhp (IN/OUT) - error handle. The OCI error handle. If there is an error, it
    is recorded in err and this function returns OCI_ERROR. Diagnostic
    information can be obtained by calling OCIErrorGet().
    filep (IN) - pointer to the FILE locator being examined. If the input file
    locator was never passed to OCILobFileOpen(), the file is considered not to
    be opened by this locator. However, a different locator may have opened the
    file. More than one file opens can be performed on the same file using
    different locators.
    flag (OUT) - returns TRUE if the FILE is opened using this locator; FALSE if
    it is not.

    See also
    OCIErrorGet, OCILobFileOpen, OCILobFileClose, OCILobFileCloseAll, CREATE
    DIRECTORY SQL command


    OCILobFileOpen()

    Name
    OCI LOB FILE open

    Purpose
    Opens a FILE for read-only access

    Syntax
    sword OCILobFileOpen ( OCISvcCtx                        *svchp,
                    OCIError                            *errhp,
                    OCILobLocator                *filep,
                    ub1                                    mode );

    Comments
    Opens a FILE. The FILE can be opened for read-only access only. FILEs may not
    be written to throough ORACLE.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    filep (IN/OUT) - the FILE to open. Error if the locator does not refer to a
    FILE.
    mode (IN) - mode in which to open the file. The only valid mode is
    read-only - OCI_FILE_READONLY.

    See Also
    OCILobFileClose, OCIErrorGet, OCILobFileCloseAll, OCILobFileIsOpen,
    OCILobFileSetName, CREATE DIRECTORY




    OCILobFileSetName()

    Name
    OCI Lob File Set NaMe

    Purpose
    Sets directory alias and file name in the FILE locator.

    Syntax
    sword OCILobFileSetName ( OCIEnv                            *envhp,
                    OCIError                        *errhp,
                    OCILobLocator            **filepp,
                    OraText                                *dir_alias,
                    ub2                                d_length,
                    OraText                                *filename,
                    ub2                                f_length );
    Comments
    Sets the directory alias and file name in the LOB file locator.
    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) - The OCI error handle. If there is an error, it is recorded
    in errhp and this function returns OCI_ERROR. Diagnostic information can be
    obtained by calling OCIErrorGet().
    filepp (IN/OUT) - FILE locator for which to set the directory alias name.
    The caller must have already allocated space for the locator by calling
    OCIDescriptorAlloc().
    dir_alias (IN) - buffer that contains the directory alias name to set in the
    locator.
    d_length (IN) - length of the input dir_alias parameter.
    filename (IN) - buffer that contains the file name is placed.
    f_length (IN) - length of the input filename parameter.
    See also
    OCILobFileGetName, OCIErrorGet, CREATE DIRECTORY




    OCILobFlushBuffer()

    Name
    OCI Lob Flush all Buffers for this lob.

    Purpose
    Flush/write all buffers for this lob to the server.


    Syntax
    sword OCILobFlushBuffer ( OCISvcCtx                *svchp,
                    OCIError                *errhp,
                    OCILobLocator        *locp,
                    ub4                            flag);

    Comments

    Flushes to the server, changes made to the buffering subsystem that
    are associated with the lob referenced by the input locator.    This
    routine will actually write the data in the buffer to the lob in
    the database.    Lob buffering must have already been enabled for the
    input lob locator.

    This routine, by default, does not free the buffer resources for
    reallocation to another buffered LOB operation. However, if you
    want to free the buffer explicitly, you can set the flag parameter
    to OCI_LOB_BUFFER_FREE.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a locator uniquely referencing the LOB.
    flag        (IN)            - to indicate if the buffer resources need to be freed
                after a flush. Default value is OCI_LOB_BUFFER_NOFREE.
                Set it to OCI_LOB_BUFFER_FREE if you want the buffer
                resources to be freed.
    Related Functions
    OCILobEnableBuffering()
    OCILobDisableBuffering()
    OCIErrorGet()
    OCILobWrite()
    OCILobRead()


    OCILobFreeTemporary()

    Name
    OCI Lob Free Temporary

    Purpose
    Free a temporary LOB

    Syntax
    sword OCILobFreeTemporary(OCISvcCtx                    *svchp,
                    OCIError                        *errhp,
                    OCILobLocator            *locp);

    Comments
        Frees the contents of the temporary Lob this locator is pointing to. Note
        that the locator itself is not freed until a OCIDescriptorFree is done.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a locator uniquely referencing the LOB

    Related functions
    OCILobCreateTemporary()
    OCILobIsTemporary()


    Name
    OCI Lob/File Get Chunk Size

    Purpose
    When creating the table, the user can specify the chunking factor, which can
    be a multiple of Oracle blocks. This corresponds to the chunk size used by the
    LOB data layer when accessing/modifying the LOB value. Part of the chunk is
    used to store system-related information and the rest stores the LOB value.
    This function returns the amount of space used in the LOB chunk to store
    the LOB value.

    Syntax
    sword OCILobGetChunkSize ( OCISvcCtx            *svchp,
                    OCIError                *errhp,
                    OCILobLocator    *locp,
                    ub4                        *chunksizep );

    Comments
    Performance will be improved if the user issues read/write
    requests using a multiple of this chunk size. For writes, there is an added
    benefit since LOB chunks are versioned and, if all writes are done on chunk
    basis, no extra/excess versioning is done nor duplicated. Users could batch
    up the write until they have enough for a chunk instead of issuing several
    write calls for the same chunk.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references the LOB. For internal
    LOBs, this locator must be a locator that was obtained from the server
    specified by svchp. For FILEs, this locator can be initialized by a Select or
    OCILobFileSetName.
    chunksizep (OUT) - On output, it is the length of the LOB if not NULL - for
    character LOBs it is the number of characters, for binary LOBs it is the
    number of bytes in the LOB.

    Related Functions

    OCILobGetLength()

    Name
    OCI Lob/File Length

    Purpose
    Gets the length of a LOB/FILE.

    Syntax
    sword OCILobGetLength ( OCISvcCtx            *svchp,
                OCIError                *errhp,
                OCILobLocator    *locp,
                ub4                        *lenp );

    Comments
    Gets the length of a LOB/FILE. If the LOB/FILE is NULL, the length is
    undefined.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references the LOB. For internal
    LOBs, this locator must be a locator that was obtained from the server
    specified by svchp. For FILEs, this locator can be initialized by a Select or
    OCILobFileSetName.
    lenp (OUT) - On output, it is the length of the LOB if not NULL - for
    character LOBs it is the number of characters, for binary LOBs it is the
    number of bytes in the LOB.

    Related Functions
    OCIErrorGet, OCIFileSetName



    OCILobIsEqual()

    Name

    OCI Lob Is Equal

    Purpose
    Compares two LOB locators for equality.

    Syntax
    sword OCILobIsEqual ( OCIEnv                                    *envhp,
                        CONST OCILobLocator            *x,
                        CONST OCILobLocator            *y,
                        boolean                                    *is_equal );

    Comments
    Compares the given LOB locators for equality.    Two LOB locators are equal if
    and only if they both refer to the same LOB data.
    Two NULL locators are considered not equal by this function.
    Parameters
    envhp (IN) - the OCI environment handle.
    x (IN) - LOB locator to compare.
    y (IN) - LOB locator to compare.
    is_equal (OUT) - TRUE, if the LOB locators are equal; FALSE if they are not.

    See also
    OCILobAssign, OCILobLocatorIsInit
    OCILobLocatorAssign,
    OCILobIsOpen()

    Name

    OCI Lob Is Open
    sword OCILobIsOpen(svchp, errhp, locp, flag)
    OCISvcCtx            *svchp;
    OCIError            *errhp;
    OCILobLocator *locp;
    boolean                *flag;

    Comments
        Checks if the LOB locator was opened before. flag is set to TRUE
        if opened; FALSE otherwise


    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN) - the locator to test for temporary LOB
    flag(OUT) - TRUE, if the LOB locator points to is open
                    FALSE, if not.

    OCILobIsTemporary()

    Name

    OCI Lob Is Temporary

    Purpose
        Tests if this locator points to a temporary LOB

    Syntax
    sword OCILobIsTemporary(OCIEnv                        *envhp,
                OCIError                    *errhp,
                OCILobLocator            *locp,
                boolean                        *is_temporary);

    Comments
    Tests the locator to determine if it points to a temporary LOB.
    If so, is_temporary is set to TRUE. If not, is_temporary is set
    to FALSE.

    Parameters
    envhp (IN) - the environment handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN) - the locator to test for temporary LOB
    is_temporary(OUT) - TRUE, if the LOB locator points to a temporary LOB;
                    FALSE, if not.

    See Also
    OCILobCreateTemporary, OCILobFreeTemporary


    OCILobLoadFromFile()

    Name
    OCI Lob Load From File

    Purpose
    Load/copy all or a portion of the file into an internal LOB.

    Syntax
    sword OCILobLoadFromFile ( OCISvcCtx                *svchp,
                    OCIError                    *errhp,
                    OCILobLocator        *dst_locp,
                    OCILobLocator        *src_filep,
                    ub4                            amount,
                    ub4                            dst_offset,
                    ub4                            src_offset );

    Comments
    Loads/copies a portion or all of a file value into an internal LOB as
    specified.    The data is copied from the source file to the destination
    internal LOB (BLOB/CLOB).    No character set conversions are performed
    when copying the bfile data to a clob/nclob.    The bfile data must already
    be in the same character set as the clob/nclob in the database.    No
    error checking is performed to verify this.
    The source (src_filep) and the destination (dst_locp) LOBs must already exist.
    If the data already exists at the destination's start position, it is
    overwritten with the source data. If the destination's start position is
    beyond the end of the current data, a hole is created from the end of the data
    to the beginning of the newly written data from the source. The destination
    LOB is extended to accommodate the newly written data if it extends
    beyond the current length of the destination LOB.
    It is an error to extend the destination LOB beyond the maximum length
    allowed or to try to copy from a NULL LOB.
    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    dst_locp (IN/OUT) - a locator uniquely referencing the destination internal
    LOB which may be of type blob, clob, or nclob.
    src_filep (IN/OUT) - a locator uniquely referencing the source BFILE.
    amount (IN) - the number of bytes to be copied.
    dst_offset (IN) - this is the absolute offset for the destination LOB.
    For character LOBs it is the number of characters from the beginning of the
    LOB at which to begin writing. For binary LOBs it is the number of bytes from
    the beginning of the lob from which to begin reading. The offset starts at 1.
    src_offset (IN) - this is the absolute offset for the source BFILE.    It is
    the number of bytes from the beginning of the LOB.    The offset starts at 1.

    See Also
    OCIErrorGet(), OCILobAppend(), OCILobWrite(), OCILobTrim(), OCILobCopy()

    OCILobLocatorAssign()

    Name
    OCI Lob LOCATOR ASsiGn

    Purpose
    Assigns one LOB/FILE locator to another.

    Syntax
    sword OCILobLocatorAssign ( OCISvcCtx                            *svchp,
                        OCIError                            *errhp,
                        CONST OCILobLocator        *src_locp,
                        OCILobLocator                    **dst_locpp );

    Comments
    Assign source locator to destination locator.    After the assignment, both
    locators refer to the same LOB data.    For internal LOBs, the source locator's
    LOB data gets copied to the destination locator's LOB data only when the
    destination locator gets stored in the table.    Therefore, issuing a flush of
    the object containing the destination locator will copy the LOB data. For
    FILEs only the locator that refers to the OS file is copied to the table. The
    OS file is not copied.
    Note : the only difference between this and OCILobAssign is that this takes
    a OCI service handle pointer instead of a OCI environment handle pointer

    Parameters
    svchp (IN/OUT) - OCI service handle initialized in object mode.
    errhp (IN/OUT) - The OCI error handle. If there is an error, it is recorded
    in errhp and this function returns OCI_ERROR. Diagnostic information can be
    obtained by calling OCIErrorGet().
    src_locp (IN) - LOB locator to copy from.
    dst_locpp (IN/OUT) - LOB locator to copy to.    The caller must allocate space
    for the OCILobLocator by calling OCIDescriptorAlloc().

    See also
    OCIErrorGet()
    OCILobIsEqual()
    OCILobLocatorIsInit()
    OCILobAssign()




    OCILobLocatorIsInit()

    Name
    OCI LOB locator is initialized?

    Purpose
    Tests to see if a given LOB locator is initialized.

    Syntax
    sword OCILobLocatorIsInit ( OCIEnv        *envhp,
                        OCIError *errhp,
                        CONST OCILobLocator *locp,
                        boolean *is_initialized );

    Comments
    Tests to see if a given LOB locator is initialized.

    Parameters
    envhp (IN/OUT) - OCI environment handle initialized in object mode.
    errhp (IN/OUT) - error handle. The OCI error handle. If there is an error, it
    is recorded in err and this function returns OCI_ERROR. Diagnostic
    information can be obtained by calling OCIErrorGet().
    locp (IN) - the LOB locator being tested
    is_initialized (OUT) - returns TRUE if the given LOB locator is initialized;
    FALSE if it is not.

    See also
    OCIErrorGet, OCILobIsEqual




    OCILobRead()

    Name
    OCI Lob/File ReaD

    Purpose
    Reads a portion of a LOB/FILE as specified by the call into a buffer.

    Syntax
    sword OCILobRead ( OCISvcCtx                *svchp,
                OCIError                *errhp,
                OCILobLocator        *locp,
                ub4                            offset,
                ub4                            *amtp,
                dvoid                        *bufp,
                ub4                            bufl,
                dvoid                        *ctxp,
                OCICallbackLobRead cbfp,
                ub2                            csid,
                ub1                            csfrm );

    Comments
    Reads a portion of a LOB/FILE as specified by the call into a buffer. Data
    read from a hole is returned as 0s. It is an error to try to read from a NULL
    LOB/FILE. The OS FILE must already exist on the server and must have been
    opened using the input locator. Oracle must hav epermission to read the OS
    file and user must have read permission on the directory object.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references a LOB.
    offset (IN) - On input, it is the absolute offset, for character LOBs in the
    number of characters from the beginning of the LOB, for binary LOBs it is the
    number of bytes. Starts from 1.
    amtp (IN/OUT) - On input, the number of character or bytes to be read. On
    output, the actual number of bytes or characters read.
    If the amount of bytes to be read is larger than the buffer length it is
    assumed that the LOB is being read in a streamed mode. On input if this value
    is 0, then the data shall be read in streamed mode from the LOB until the end
    of LOB. If the data is read in pieces, *amtp always contains the length of
    the last piece read.    If a callback function is defined, then this callback
    function will be invoked each time bufl bytes are read off the pipe. Each
    piece will be written into bufp.
    If the callback function is not defined, then OCI_NEED_DATA error code will
    be returned. The application must invoke the LOB read over and over again to
    read more pieces of the LOB until the OCI_NEED_DATA error code is not
    returned. The buffer pointer and the length can be different in each call
    if the pieces are being read into different sizes and location.
    bufp (IN) - the pointer to a buffer into which the piece will be read. The
    length of the allocated memory is assumed to be bufl.
    bufl (IN) - the length of the buffer in octets.
    ctxp (IN) - the context for the call back function. Can be NULL.
    cbfp (IN) - a callback that may be registered to be called for each piece. If
    this is NULL, then OCI_NEED_DATA will be returned for each piece.
    The callback function must return OCI_CONTINUE for the read to continue.
    If any other error code is returned, the LOB read is aborted.
        ctxp (IN) - the context for the call back function. Can be NULL.
        bufp (IN) - a buffer pointer for the piece.
        len (IN) - the length of length of current piece in bufp.
        piece (IN) - which piece - OCI_FIRST_PIECE, OCI_NEXT_PIECE or
        OCI_LAST_PIECE.
    csid - the character set ID of the buffer data
    csfrm - the character set form of the buffer data

    Related Functions
    OCIErrorGet, OCILobWrite, OCILobFileOpen, OCILobFileSetName, CREATE DIRECTORY




    OCILobTrim()

    Name

    OCI Lob    Trim

    Purpose
    Trims the lob value to a shorter length

    Syntax
    sword OCILobTrim ( OCISvcCtx                *svchp,
            OCIError                *errhp,
            OCILobLocator        *locp,
            ub4                            newlen );

    Comments
    Truncates LOB data to a specified shorter length.

    Parameters
    svchp (IN) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references the LOB. This locator
    must be a locator that was obtained from the server specified by svchp.
    newlen (IN) - the new length of the LOB data, which must be less than or equal
    to the current length.

    Related Functions
    OCIErrorGet, OCILobWrite, OCiLobErase, OCILobAppend, OCILobCopy





    OCILobWrite()

    Name
    OCI Lob Write

    Purpose
    Writes a buffer into a LOB

    Syntax
    sword OCILobWrite ( OCISvcCtx                *svchp,
                    OCIError                *errhp,
                    OCILobLocator        *locp,
                    ub4                            offset,
                    ub4                            *amtp,
                    dvoid                        *bufp,
                    ub4                            buflen,
                    ub1                            piece,
                    dvoid                        *ctxp,
                    OCICallbackLobWrite        (cbfp)
                            (
                            dvoid        *ctxp,
                            dvoid        *bufp,
                            ub4            *lenp,
                            ub1            *piecep )
                    ub2                            csid
                    ub1                            csfrm );


    Comments
    Writes a buffer into a LOB as specified. If LOB data already exists
    it is overwritten with the data stored in the buffer.
    The buffer can be written to the LOB in a single piece with this call, or
    it can be provided piecewise using callbacks or a standard polling method.
    If this value of the piece parameter is OCI_FIRST_PIECE, data must be
    provided through callbacks or polling.
    If a callback function is defined in the cbfp parameter, then this callback
    function will be invoked to get the next piece after a piece is written to
    the pipe. Each piece will be written from bufp.
    If no callback function is defined, then OCILobWrite() returns the
    OCI_NEED_DATA error code. The application must all OCILobWrite() again
    to write more pieces of the LOB. In this mode, the buffer pointer and the
    length can be different in each call if the pieces are of different sizes and
    from different locations. A piece value of OCI_LAST_PIECE terminates the
    piecewise write.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references a LOB.
    offset (IN) - On input, it is the absolute offset, for character LOBs in
    the number of characters from the beginning of the LOB, for binary LOBs it
    is the number of bytes. Starts at 1.
    bufp (IN) - the pointer to a buffer from which the piece will be written. The
    length of the allocated memory is assumed to be the value passed in bufl.
    Even if the data is being written in pieces, bufp must contain the first
    piece of the LOB when this call is invoked.
    bufl (IN) - the length of the buffer in bytes.
    Note: This parameter assumes an 8-bit byte. If your platform uses a
    longer byte, the value of bufl must be adjusted accordingly.
    piece (IN) - which piece of the buffer is being written. The default value for
    this parameter is OCI_ONE_PIECE, indicating the buffer will be written in a
    single piece.
    The following other values are also possible for piecewise or callback mode:
    OCI_FIRST_PIECE, OCI_NEXT_PIECE and OCI_LAST_PIECE.
    amtp (IN/OUT) - On input, takes the number of character or bytes to be
    written. On output, returns the actual number of bytes or characters written.
    If the data is written in pieces, *amtp will contain the total length of the
    pieces written at the end of the call (last piece written) and is undefined in
    between.
    (Note it is different from the piecewise read case)
    ctxp (IN) - the context for the call back function. Can be NULL.
    cbfp (IN) - a callback that may be registered to be called for each piece in
    a piecewise write. If this is NULL, the standard polling method will be used.
    The callback function must return OCI_CONTINUE for the write to continue.
    If any other error code is returned, the LOB write is aborted. The
    callback takes the following parameters:
        ctxp (IN) - the context for the call back function. Can be NULL.
        bufp (IN/OUT) - a buffer pointer for the piece.
        lenp (IN/OUT) - the length of the buffer (in octets) and the length of
        current piece in bufp (out octets).
        piecep (OUT) - which piece - OCI_NEXT_PIECE or OCI_LAST_PIECE.
    csid - the character set ID of the buffer data
    csfrm - the character set form of the buffer data
    Related Functions

    OCILobWriteAppend()

    Name
    OCI Lob Write Append

    Purpose
    Writes data to the end of a LOB value. This call provides the ability
    to get the length of the data and append it to the end of the LOB in
    a single round trip to the server.

    Syntax
    sword OCILobWriteAppend ( OCISvcCtx                *svchp,
                    OCIError                *errhp,
                    OCILobLocator        *locp,
                    ub4                            *amtp,
                    dvoid                        *bufp,
                    ub4                            buflen,
                    ub1                            piece,
                    dvoid                        *ctxp,
                    OCICallbackLobWrite        (cbfp)
                            (
                            dvoid        *ctxp,
                            dvoid        *bufp,
                            ub4            *lenp,
                            ub1            *piecep )
                    ub2                            csid
                    ub1                            csfrm );


    Comments
    Writes a buffer to the end of a LOB as specified. If LOB data already exists
    it is overwritten with the data stored in the buffer.
    The buffer can be written to the LOB in a single piece with this call, or
    it can be provided piecewise using callbacks or a standard polling method.
    If this value of the piece parameter is OCI_FIRST_PIECE, data must be
    provided through callbacks or polling.
    If a callback function is defined in the cbfp parameter, then this callback
    function will be invoked to get the next piece after a piece is written to the
    pipe. Each piece will be written from bufp.
    If no callback function is defined, then OCILobWriteAppend() returns the
    OCI_NEED_DATA error code. The application must all OCILobWriteAppend() again
    to write more pieces of the LOB. In this mode, the buffer pointer and the
    length can be different in each call if the pieces are of different sizes and
    from different locations. A piece value of OCI_LAST_PIECE terminates the
    piecewise write.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references a LOB.
    bufp (IN) - the pointer to a buffer from which the piece will be written. The
    length of the allocated memory is assumed to be the value passed in bufl. Even
    if the data is being written in pieces, bufp must contain the first piece of
    the LOB when this call is invoked.
    bufl (IN) - the length of the buffer in bytes.
    Note: This parameter assumes an 8-bit byte. If your platform uses a
    longer byte, the value of bufl must be adjusted accordingly.
    piece (IN) - which piece of the buffer is being written. The default value for
    this parameter is OCI_ONE_PIECE, indicating the buffer will be written in a
    single piece.
    The following other values are also possible for piecewise or callback mode:
    OCI_FIRST_PIECE, OCI_NEXT_PIECE and OCI_LAST_PIECE.
    amtp (IN/OUT) - On input, takes the number of character or bytes to be
    written. On output, returns the actual number of bytes or characters written.
    If the data is written in pieces, *amtp will contain the total length of the
    pieces written at the end of the call (last piece written) and is undefined in
    between.
    (Note it is different from the piecewise read case)
    ctxp (IN) - the context for the call back function. Can be NULL.
    cbfp (IN) - a callback that may be registered to be called for each piece in a
    piecewise write. If this is NULL, the standard polling method will be used.
    The callback function must return OCI_CONTINUE for the write to continue.
    If any other error code is returned, the LOB write is aborted. The
    callback takes the following parameters:
        ctxp (IN) - the context for the call back function. Can be NULL.
        bufp (IN/OUT) - a buffer pointer for the piece.
        lenp (IN/OUT) - the length of the buffer (in octets) and the length of
        current piece in bufp (out octets).
        piecep (OUT) - which piece - OCI_NEXT_PIECE or OCI_LAST_PIECE.
    csid - the character set ID of the buffer data
    csfrm - the character set form of the buffer data
    Related Functions




    OCILobGetStorageLimit()

    Name
    OCI Lob Get Storage Limit

    Purpose
    To get the maximum Length of a LOB in bytes that can be stored in the database.

    Syntax
    sword OCILobGetStorageLimit ( OCISvcCtx                *svchp,
                    OCIError                *errhp,
                    OCILobLocator        *locp,
                    oraub8                    *limitp);


    Comments
    With unlimited size LOB support the limit for a LOB is no longer restricted to 4GB.
    This interface should be used to get the actual limit for storing data for a specific
    LOB locator. Note that if the compatibality is set to 9.2 or older the limit would still
    be 4GB.

    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    locp (IN/OUT) - a LOB locator that uniquely references a LOB.
    limitp (OUT)    - The storage limit for a LOB in bytes.
    Related Functions




    OCILogoff()
    Name
    OCI simplified Logoff
    Purpose
    This function is used to terminate a session created with OCILogon() or
    OCILogon2().
    Syntax
    sword OCILogoff ( OCISvcCtx            *svchp
                OCIError                *errhp );
    Comments
    This call is used to terminate a session which was created with OCILogon() or
    OCILogon2().
    This call implicitly deallocates the server, authentication, and service
    context handles.
    Note: For more information on logging on and off in an application,
    refer to the section "Application Initialization, Connection, and
    Authorization" on page 2-16.
    Parameters
    svchp (IN) - the service context handle which was used in the call to
    OCILogon() or OCILogon2().
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    See Also
    OCILogon(), OCILogon2().






    OCILogon()
    Name
    OCI Service Context Logon
    Purpose
    This function is used to create a simple logon session.
    Syntax
    sword OCILogon ( OCIEnv                    *envhp,
                        OCIError                *errhp,
                        OCISvcCtx                *svchp,
                        CONST OraText            *username,
                        ub4                            uname_len,
                        CONST OraText            *password,
                        ub4                            passwd_len,
                        CONST OraText            *dbname,
                        ub4                            dbname_len );
    Comments
    This function is used to create a simple logon session for an application.
    Note: Users requiring more complex session (e.g., TP monitor
    applications) should refer to the section "Application Initialization,
    Connection, and Authorization" on page 2-16.
    This call allocates the error and service context handles which are passed to
    it. This call also implicitly allocates server and authentication handles
    associated with the session.    These handles can be retrieved by calling
    OCIAttrGet() on the service context handle.
    Parameters
    envhp (IN) - the OCI environment handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    svchp (OUT) - the service context pointer.
    username (IN) - the username.
    uname_len (IN) - the length of username.
    password (IN) - the user's password.
    passwd_len (IN) - the length of password.
    dbname (IN) - the name of the database to connect to.
    dbname_len (IN) - the length of dbname.
    See Also
    OCILogoff()





    OCILogon2()
    Name
    OCI Service Context Logon
    Purpose
    This function is used to create a logon session in connection pooling mode.
    Syntax
    sword OCILogon2 ( OCIEnv                    *envhp,
                        OCIError                *errhp,
                        OCISvcCtx                **svchp,
                        CONST OraText            *username,
                        ub4                            uname_len,
                        CONST OraText            *password,
                        ub4                            passwd_len,
                        CONST OraText            *dbname,
                        ub4                            dbname_len,
                        ub4                            mode);
    Comments
    This function is used to create a simple logon session for an application in
    Connection Pooling mode. The valid values for mode are currently OCI_POOL and
    OCI_DEFAULT. Call to this function with OCI_DEFAULT mode is equivalent to
    OCILogon() call.
    This call allocates the error and service context handles which are passed to
    it. This call also implicitly allocates server and authentication handles
    associated with the session.    These handles can be retrieved by calling
    OCIAttrGet() on the service context handle. This call assumes that
    OCIConnectionPoolCreate() has already been called for the same dbname.
    Parameters
    envhp (IN) - the OCI environment handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    svchp (OUT) - the service context pointer.
    username (IN) - the username.
    uname_len (IN) - the length of username.
    password (IN) - the user's password. If this is null, it is assumed that a
            proxy session has to be created and the required grants on
            the database are already done.
    passwd_len (IN) - the length of password.
    dbname (IN) - the name of the database to connect to.
    dbname_len (IN) - the length of dbname.
    mode (IN) - the mode for doing the server attach. Should be OCI_POOL for
                using Connection Pooling.


    See Also
    OCILogoff()





    OCIMemoryFree()
    Name
    OCI FREE Memory
    Purpose
    Frees up storage associated with the pointer.
    Syntax
    void OCIMemoryFree ( CONST OCIStmt        *stmhp,
                    dvoid                        *memptr);
    Comments
    Frees up dynamically allocated data pointers associated with the pointer using
    either the default memory free function or the registered memory free
    function, as the case may be.
    A user-defined memory free function can be registered during the initial call
    to OCIInitialize().
    This call is always successful.
    Parameters
    stmhp (IN) - statement handle which returned this data buffer.
    memptr (IN) - pointer to data allocated by the client library.
    Related Functions
    OCIInitialize()





    OCIParamGet()
    Name
    OCI Get PARaMeter
    Purpose
    Returns a descriptor of a parameter specified by position in the describe
    handle or statement handle.
    Syntax
    sword OCIParamGet ( CONST dvoid                *hndlp,
                ub4                    htype,
                OCIError        *errhp,
                dvoid        **parmdpp,
                ub4                    pos );
    Comments
    This call returns a descriptor of a parameter specified by position in the
    describe handle or statement handle. Parameter descriptors are always
    allocated internally by the OCI library. They are read-only.
    OCI_NO_DATA may be returned if there are no parameter descriptors for this
    position.
    See Appendix B for more detailed information about parameter descriptor
    attributes.
    Parameters
    hndlp (IN) - a statement handle or describe handle. The OCIParamGet()
    function will return a parameter descriptor for this handle.
    htype (IN) - the type of the handle passed in the handle parameter. Valid
    types are OCI_HTYPE_DESCRIBE, for a describe handle OCI_HTYPE_STMT, for a
    statement handle
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    parmdpp (OUT) - a descriptor of the parameter at the position given in the pos
    parameter.
    pos (IN) - position number in the statement handle or describe handle. A
    parameter descriptor will be returned for this position.
    Note: OCI_NO_DATA may be returned if there are no parameter
    descriptors for this position.
    Related Functions
    OCIAttrGet(), OCIAttrSet()





    OCIParamSet()
    Name
    OCI Parameter Set in handle
    Purpose
    Used to set a complex object retrieval descriptor into a complex object
    retrieval handle.
    Syntax
    sword OCIParamGet ( dvoid *hndlp,
                        ub4 htyp,
                        OCIError *errhp,
                        CONST dvoid *dscp,
                        ub4 dtyp,
                        ub4 pos );
    Comments
    This call sets a given complex object retrieval descriptor into a complex
    object retrieval handle.
    The handle must have been previously allocated using OCIHandleAlloc(), and
    the descriptor must have been previously allocated using OCIDescAlloc().
    Attributes of the descriptor are set using OCIAttrSet().
    Parameters
    hndlp (IN/OUT) - handle pointer.
    htype (IN) - handle type.
    errhp (IN/OUT) - error handle.
    dscp (IN) - complex object retrieval descriptor pointer.
    dtyp (IN) -
    pos (IN) - position number.
    See Also





    OCIPasswordChange()
    Name
    OCI Change PassWord
    Purpose
    This call allows the password of an account to be changed.
    Syntax
    sword OCIPasswordChange ( OCISvcCtx            *svchp,
                OCIError            *errhp,
                CONST OraText        *user_name,
                ub4                        usernm_len,
                CONST OraText        *opasswd,
                ub4                        opasswd_len,
                CONST OraText        *npasswd,
                sb4                        npasswd_len,
                ub4                        mode);
    Comments
    This call allows the password of an account to be changed. This call is
    similar to OCISessionBegin() with the following differences:
    If the user authentication is already established, it authenticates
    the account using the old password and then changes the
    password to the new password
    If the user authentication is not established, it establishes a user
    authentication and authenticates the account using the old
    password, then changes the password to the new password.
    This call is useful when the password of an account is expired and
    OCISessionBegin() returns an error or warning which indicates that the
    password has expired.
    Parameters
    svchp (IN/OUT) - a handle to a service context. The service context handle
    must be initialized and have a server context handle associated with it.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    user_name (IN) - specifies the user name. It points to a character string,
    whose length is specified in usernm_len. This parameter must be NULL if the
    service context has been initialized with an authentication handle.
    usernm_len (IN) - the length of the user name string specified in user_name.
    For a valid user name string, usernm_len must be non-zero.
    opasswd (IN) - specifies the user's old password. It points to a character
    string, whose length is specified in opasswd_len .
    opasswd_len (IN) - the length of the old password string specified in opasswd.
    For a valid password string, opasswd_len must be non-zero.
    npasswd (IN) - specifies the user's new password. It points to a character
    string, whose length is specified in npasswd_len which must be non-zero for a
    valid password string. If the password complexity verification routine is
    specified in the user's profile to verify the new password's complexity, the
    new password must meet the complexity requirements of the verification
    function.
    npasswd_len (IN)    - then length of the new password string specified in
    npasswd. For a valid password string, npasswd_len must be non-zero.
    mode - pass as OCI_DEFAULT.
    Related Functions
    OCISessionBegin()


    OCIReset()
    Name
    OCI Reset
    Purpose
    Resets the interrupted asynchronous operation and protocol. Must be called
    if a OCIBreak call had been issued while a non-blocking operation was in
    progress.
    Syntax
    sword OCIReset ( dvoid            *hndlp,
            OCIError        *errhp);
    Comments
    This call is called in non-blocking mode ONLY. Resets the interrupted
    asynchronous operation and protocol. Must be called if a OCIBreak call
    had been issued while a non-blocking operation was in progress.
    Parameters
    hndlp (IN) - the service context handle or the server context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    Related Functions


    OCIResultSetToStmt()
    Name
    OCI convert Result Set to Statement Handle
    Purpose
    Converts a descriptor to statement handle for fetching rows.
    Syntax
    sword OCIResultSetToStmt ( OCIResult            *rsetdp,
                OCIError            *errhp );
    Comments
    Converts a descriptor to statement handle for fetching rows.
    A result set descriptor can be allocated with a call to OCIDescAlloc().
    Parameters
    rsetdp (IN/OUT) - a result set descriptor pointer.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    Related Functions
    OCIDescAlloc()




    OCIServerAttach()
    Name
    OCI ATtaCH to server
    Purpose
    Creates an access path to a data source for OCI operations.
    Syntax
    sword OCIServerAttach ( OCIServer        *srvhp,
                        OCIError            *errhp,
                        CONST OraText        *dblink,
                        sb4                    dblink_len,
                        ub4                    mode);
    Comments
    This call is used to create an association between an OCI application and a
    particular server.
    This call initializes a server context handle, which must have been previously
    allocated with a call to OCIHandleAlloc().
    The server context handle initialized by this call can be associated with a
    service context through a call to OCIAttrSet(). Once that association has been
    made, OCI operations can be performed against the server.
    If an application is operating against multiple servers, multiple server
    context handles can be maintained. OCI operations are performed against
    whichever server context is currently associated with the service context.
    Parameters
    srvhp (IN/OUT) - an uninitialized server context handle, which gets
    initialized by this call. Passing in an initialized server handle causes an
    error.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    dblink (IN) - specifies the database (server) to use. This parameter points to
    a character string which specifies a connect string or a service point. If the
    connect string is NULL, then this call attaches to the default host. The length
    of connstr is specified in connstr_len. The connstr pointer may be freed by the
    caller on return.
    dblink_len (IN) - the length of the string pointed to by connstr. For a valid
    connect string name or alias, connstr_len must be non-zero.
    mode (IN) - specifies the various modes of operation.    For release 8.0, pass as
    OCI_DEFAULT - in this mode, calls made to the server on this server context
    are made in blocking mode.
    Example
    See the description of OCIStmtPrepare() on page 13-96 for an example showing
    the use of OCIServerAttach().
    Related Functions
    OCIServerDetach()



    OCIServerDetach()
    Name
    OCI DeTaCH server
    Purpose
    Deletes an access to a data source for OCI operations.
    Syntax
    sword OCIServerDetach ( OCIServer        *svrhp,
                        OCIError        *errhp,
                        ub4                    mode);
    Comments
    This call deletes an access to data source for OCI operations, which was
    established by a call to OCIServerAttach().
    Parameters
    srvhp (IN) - a handle to an initialized server context, which gets reset to
    uninitialized state. The handle is not de-allocated.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    mode (IN) - specifies the various modes of operation. The only valid mode is
    OCI_DEFAULT for the default mode.
    Related Functions
    OCIServerAttach()



    OCIServerVersion()
    Name
    OCI VERSion
    Purpose
    Returns the version string of the Oracle server.
    Syntax
    sword OCIServerVersion ( dvoid                *hndlp,
                        OCIError            *errhp,
                        OraText                    *bufp,
                        ub4                    bufsz
                        ub1                    hndltype );
    Comments
    This call returns the version string of the Oracle server.
    For example, the following might be returned as the version string if your
    application is running against a 7.3.2 server:
    Oracle7 Server Release 7.3.2.0.0 - Production Release
    PL/SQL Release 2.3.2.0.0 - Production
    CORE Version 3.5.2.0.0 - Production
    TNS for SEQUENT DYNIX/ptx: Version 2.3.2.0.0 - Production
    NLSRTL Version 3.2.2.0.0 - Production

    Parameters
    hndlp (IN) - the service context handle or the server context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    bufp (IN) - the buffer in which the version information is returned.
    bufsz (IN) - the length of the buffer.
    hndltype (IN) - the type of handle passed to the function.
    Related Functions





    OCISessionBegin()
    Name
    OCI Session Begin and authenticate user
    Purpose
    Creates a user authentication and begins a user session for a given server.
    Syntax
    sword OCISessionBegin ( OCISvcCtx            *svchp,
                        OCIError            *errhp,
                        OCISession        *usrhp,
                        ub4                        credt,
                        ub4                        mode);

    Comments
    For Oracle8, OCISessionBegin() must be called for any given server handle
    before requests can be made against it. Also, OCISessionBegin() only supports
    authenticating the user for access to the Oracle server specified by the
    server handle in the service context. In other words, after OCIServerAttach()
    is called to initialize a server handle, OCISessionBegin() must be called to
    authenticate the user for that given server.
    When OCISessionBegin() is called for the first time for the given server
    handle, the initialized authentication handle is called a primary
    authentication context. A primary authentication context may not be created
    with the OCI_MIGRATE mode. Also, only one primary authentication context can
    be created for a given server handle and the primary authentication context c
    an only ever be used with that server handle. If the primary authentication
    context is set in a service handle with a different server handle, then an
    error will result.
    After OCISessionBegin() has been called for the server handle, and the primary
    authentication context is set in the service handle, OCISessionBegin() may be
    called again to initialize another authentication handle with different (or
    the same) credentials. When OCISessionBegin() is called with a service handle
    set with a primary authentication context, the returned authentication context
    in authp is called a user authentication context. As many user authentication
    contexts may be initialized as desired.
    User authentication contexts may be created with the OCI_MIGRATE mode.
    If the OCI_MIGRATE mode is not specified, then the user authentication
    context can only ever be used with the same server handle set in svchp. If
    OCI_MIGRATE mode is specified, then the user authentication may be set
    with different server handles. However, the user authentication context is
    restricted to use with only server handles which resolve to the same database
    instance and that have equivalent primary authentication contexts. Equivalent
    authentication contexts are those which were authenticated as the same
    database user.
    OCI_SYSDBA, OCI_SYSOPER, and OCI_PRELIM_AUTH may only be used
    with a primary authentication context.
    To provide credentials for a call to OCISessionBegin(), one of two methods are
    supported. The first is to provide a valid username and password pair for
    database authentication in the user authentication handle passed to
    OCISessionBegin(). This involves using OCIAttrSet() to set the
    OCI_ATTR_USERNAME and OCI_ATTR_PASSWORD attributes on the
    authentication handle. Then OCISessionBegin() is called with
    OCI_CRED_RDBMS.
    Note: When the authentication handle is terminated using
    OCISessionEnd(), the username and password attributes remain
    unchanged and thus can be re-used in a future call to OCISessionBegin().
    Otherwise, they must be reset to new values before the next
    OCISessionBegin() call.
    The second type of credentials supported are external credentials. No
    attributes need to be set on the authentication handle before calling
    OCISessionBegin(). The credential type is OCI_CRED_EXT. This is equivalent
    to the Oracle7 `connect /' syntax. If values have been set for
    OCI_ATTR_USERNAME and OCI_ATTR_PASSWORD, then these are
    ignored if OCI_CRED_EXT is used.
    Parameters
    svchp (IN) - a handle to a service context. There must be a valid server
    handle set in svchp.
    errhp (IN) - an error handle to the retrieve diagnostic information.
    usrhp (IN/OUT) - a handle to an authentication context, which is initialized
    by this call.
    credt (IN) - specifies the type of credentials to use for authentication.
    Valid values for credt are:
    OCI_CRED_RDBMS - authenticate using a database username and
    password pair as credentials. The attributes OCI_ATTR_USERNAME
    and OCI_ATTR_PASSWORD should be set on the authentication
    context before this call.
    OCI_CRED_EXT - authenticate using external credentials. No username
    or password is provided.
    mode (IN) - specifies the various modes of operation. Valid modes are:
    OCI_DEFAULT - in this mode, the authentication context returned may
    only ever be set with the same server context specified in svchp. This
    establishes the primary authentication context.
    OCI_MIGRATE - in this mode, the new authentication context may be
    set in a service handle with a different server handle. This mode
    establishes the user authentication context.
    OCI_SYSDBA - in this mode, the user is authenticated for SYSDBA
    access.
    OCI_SYSOPER - in this mode, the user is authenticated for SYSOPER
    access.
    OCI_PRELIM_AUTH - this mode may only be used with OCI_SYSDBA
    or OCI_SYSOPER to authenticate for certain administration tasks.
    Related Functions
    OCISessionEnd()






    OCISessionEnd()
    Name
    OCI Terminate user Authentication Context
    Purpose
    Terminates a user authentication context created by OCISessionBegin()
    Syntax
    sword OCISessionEnd ( OCISvcCtx                *svchp,
                    OCIError                *errhp,
                    OCISession            *usrhp,
                    ub4                            mode);

    Comments
    The user security context associated with the service context is invalidated
    by this call. Storage for the authentication context is not freed. The
    transaction specified by the service context is implicitly committed. The
    transaction handle, if explicitly allocated, may be freed if not being used.
    Resources allocated on the server for this user are freed.
    The authentication handle may be reused in a new call to OCISessionBegin().
    Parameters
    svchp (IN/OUT) - the service context handle. There must be a valid server
    handle and user authentication handle associated with svchp.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    usrhp (IN) - de-authenticate this user. If this parameter is passed as NULL,
    the user in the service context handle is de-authenticated.
    mode (IN) - the only valid mode is OCI_DEFAULT.
    Example
    In this example, an authentication context is destroyed.
    Related Functions
    OCISessionBegin()




    OCIStmtExecute()
    Name
    OCI EXECute
    Purpose
    This call associates an application request with a server.
    Syntax
    sword OCIStmtExecute ( OCISvcCtx                        *svchp,
                    OCIStmt                            *stmtp,
                    OCIError                        *errhp,
                    ub4                                    iters,
                    ub4                                    rowoff,
                    CONST OCISnapshot        *snap_in,
                    OCISnapshot                    *snap_out,
                    ub4                                    mode );
    Comments
    This function    is used to execute a prepared SQL statement.
    Using an execute call, the application associates a request with a server. On
    success, OCI_SUCCESS is returned.
    If a SELECT statement is executed, the description of the select list follows
    implicitly as a response. This description is buffered on the client side for
    describes, fetches and define type conversions. Hence it is optimal to
    describe a select list only after an execute.
    Also for SELECT statements, some results are available implicitly. Rows will
    be received and buffered at the end of the execute. For queries with small row
    count, a prefetch causes memory to be released in the server if the end of
    fetch is reached, an optimization that may result in memory usage reduction.
    Set attribute call has been defined to set the number of rows to be prefetched
    per result set.
    For SELECT statements, at the end of the execute, the statement handle
    implicitly maintains a reference to the service context on which it is
    executed. It is the user's responsibility to maintain the integrity of the
    service context. If the attributes of a service context is changed for
    executing some operations on this service context, the service context must
    be restored to have the same attributes, that a statement was executed with,
    prior to a fetch on the statement handle. The implicit reference is maintained
    until the statement handle is freed or the fetch is cancelled or an end of
    fetch condition is reached.
    Note: If output variables are defined for a SELECT statement before a
    call to OCIStmtExecute(), the number of rows specified by iters will be
    fetched directly into the defined output buffers and additional rows
    equivalent to the prefetch count will be prefetched. If there are no
    additional rows, then the fetch is complete without calling
    OCIStmtFetch().
    The execute call will return errors if the statement has bind data types that
    are not supported in an Oracle7 server.
    Parameters
    svchp (IN/OUT) - service context handle.
    stmtp (IN/OUT) - an statement handle - defines the statement and the
    associated data to be executed at the server. It is invalid to pass in a
    statement handle that has bind of data types only supported in release 8.0
    when srvchp points to an Oracle7 server.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error. If the statement is being
    batched and it is successful, then this handle will contain this particular
    statement execution specific errors returned from the server when the batch is
    flushed.
    iters (IN) - the number of times this statement is executed for non-Select
    statements. For Select statements, if iters is non-zero, then defines must
    have been done for the statement handle. The execution fetches iters rows into
    these predefined buffers and prefetches more rows depending upon the prefetch
    row count. This function returns an error if iters=0 for non-SELECT
    statements.
    rowoff (IN) - the index from which the data in an array bind is relevant for
    this multiple row execution.
    snap_in (IN) - this parameter is optional. if supplied, must point to a
    snapshot descriptor of type OCI_DTYPE_SNAP.    The contents of this descriptor
    must be obtained from the snap_out parameter of a previous call.    The
    descriptor is ignored if the SQL is not a SELECT.    This facility allows
    multiple service contexts to ORACLE to see the same consistent snapshot of the
    database's committed data.    However, uncommitted data in one context is not
    visible to another context even using the same snapshot.
    snap_out (OUT) - this parameter optional. if supplied, must point to a
    descriptor of type OCI_DTYPE_SNAP. This descriptor is filled in with an
    opaque representation which is the current ORACLE "system change
    number" suitable as a snap_in input to a subsequent call to OCIStmtExecute().
    This descriptor should not be used any longer than necessary in order to avoid
    "snapshot too old" errors.
    mode (IN) - The modes are:
    If OCI_DEFAULT_MODE, the default mode, is selected, the request is
    immediately executed. Error handle contains diagnostics on error if any.
    OCI_EXACT_FETCH - if the statement is a SQL SELECT, this mode is
    only valid if the application has set the prefetch row count prior to this
    call. In this mode, the OCI library will get up to the number of rows
    specified (i.e., prefetch row count plus iters). If the number of rows
    returned by the query is greater than this value, OCI_ERROR will be
    returned with ORA-01422 as the implementation specific error in a
    diagnostic record. If the number of rows returned by the query is
    smaller than the prefetch row count, OCI_SUCCESS_WITH_INFO will
    be returned with ORA-01403 as the implementation specific error. The
    prefetch buffer size is ignored and the OCI library tries to allocate all the
    space required to contain the prefetched rows. The exact fetch semantics
    apply to only the top level rows. No more rows can be fetched for this
    query at the end of the call.
    OCI_KEEP_FETCH_STATE - the result set rows (not yet fetched) of this
    statement executed in this transaction will be maintained when the
    transaction is detached for migration. By default, a query is cancelled
    when a transaction is detached for migration. This mode is the default
    mode when connected to a V7 server.
    Related Functions
    OCIStmtPrepare()





    OCIStmtFetch()
    Name
    OCI FetCH
    Purpose
    Fetches rows from a query.
    Syntax
    sword OCIStmtFetch ( OCIStmt            *stmtp,
                OCIError        *errhp,
                ub4                    nrows,
                ub2                    orientation,
                ub4                    mode);
    Comments
    The fetch call is a local call, if prefetched rows suffice. However, this is
    transparent to the application. If LOB columns are being read, LOB locators
    are fetched for subsequent LOB operations to be performed on these locators.
    Prefetching is turned off if LONG columns are involved.
    A fetch with nrows set to 0 rows effectively cancels the fetch for this
    statement.
    Parameters
    stmtp (IN) - a statement (application request) handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    nrows (IN) - number of rows to be fetched from the current position.
    orientation (IN) - for release 8.0, the only acceptable value is
    OCI_FETCH_NEXT, which is also the default value.
    mode (IN) - for release 8.0, beta-1, the following mode is defined.
    OCI_DEFAULT - default mode
    OCI_EOF_FETCH - indicates that it is the last fetch from the result set.
    If nrows is non-zero, setting this mode effectively cancels fetching after
    retrieving nrows, otherwise it cancels fetching immediately.
    Related Functions
    OCIAttrGet()

    OCIStmtFetch2()
    Name
    OCI FetCH2
    Purpose
    Fetches rows from a query.
    Syntax
    sword OCIStmtFetch2 ( OCIStmt            *stmtp,
                OCIError        *errhp,
                ub4                    nrows,
                ub2                    orientation,
                ub4                    scrollOffset,
                ub4                    mode);
    Comments
    The fetch call works similar to the OCIStmtFetch call with the
    addition of the fetchOffset parameter. It can be used on any
    statement handle, whether it is scrollable or not. For a
    non-scrollable statement handle, the only acceptable value
    will be OCI_FETCH_NEXT, and the fetchOffset parameter will be
    ignored. Applications are encouraged to use this new call.

    A fetchOffset with OCI_FETCH_RELATIVE is equivalent to
    OCI_FETCH_CURRENT with a value of 0, is equivalent to
    OCI_FETCH_NEXT with a value of 1, and equivalent to
    OCI_FETCH_PRIOR with a value of -1. Note that the range of
    accessible rows is [1,OCI_ATTR_ROW_COUNT] beyond which an
    error could be raised if sufficient rows do not exist in

    The fetch call is a local call, if prefetched rows suffice. However, this is
    transparent to the application. If LOB columns are being read, LOB locators
    are fetched for subsequent LOB operations to be performed on these locators.
    Prefetching is turned off if LONG columns are involved.
    A fetch with nrows set to 0 rows effectively cancels the fetch for this
    statement.
    Parameters
    stmtp (IN) - a statement (application request) handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    nrows (IN) - number of rows to be fetched from the current position.
    It defaults to 1 for orientation OCI_FETCH_LAST.
    orientation (IN) -    The acceptable values are as follows, with
    OCI_FETCH_NEXT being the default value.
    OCI_FETCH_CURRENT gets the current row,
    OCI_FETCH_NEXT gets the next row from the current position,
    OCI_FETCH_FIRST gets the first row in the result set,
    OCI_FETCH_LAST gets the last row in the result set,
    OCI_FETCH_PRIOR gets the previous row from the current row in the result set,
    OCI_FETCH_ABSOLUTE will fetch the row number (specified by fetchOffset
    parameter) in the result set using absolute positioning,
    OCI_FETCH_RELATIVE will fetch the row number (specified by fetchOffset
    parameter) in the result set using relative positioning.
    scrollOffset(IN) - offset used with the OCI_FETCH_ABSOLUTE and
    OCI_FETCH_RELATIVE orientation parameters only. It specify
    the new current position for scrollable result set. It is
    ignored for non-scrollable result sets.
    mode (IN) - for release 8.0, beta-1, the following mode is defined.
    OCI_DEFAULT - default mode
    OCI_EOF_FETCH - indicates that it is the last fetch from the result set.
    If nrows is non-zero, setting this mode effectively cancels fetching after
    retrieving nrows, otherwise it cancels fetching immediately.
    Related Functions
    OCIAttrGet()



    OCIStmtGetPieceInfo()
    Name
    OCI Get Piece Information
    Purpose
    Returns piece information for a piecewise operation.
    Syntax
    sword OCIStmtGetPieceInfo( CONST OCIStmt    *stmtp,
                OCIError                *errhp,
                dvoid                    **hndlpp,
                ub4                        *typep,
                ub1                        *in_outp,
                ub4                        *iterp,
                ub4                        *idxp,
                ub1                        *piecep );

    Comments
    When an execute/fetch call returns OCI_NEED_DATA to get/return a
    dynamic bind/define value or piece, OCIStmtGetPieceInfo() returns the
    relevant information: bind/define handle, iteration or index number and
    which piece.
    See the section "Runtime Data Allocation and Piecewise Operations" on page
    5-16 for more information about using OCIStmtGetPieceInfo().
    Parameters
    stmtp (IN) - the statement when executed returned OCI_NEED_DATA.
    errhp (OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    hndlpp (OUT) - returns a pointer to the bind or define handle of the bind or
    define whose runtime data is required or is being provided.
    typep (OUT) - the type of the handle pointed to by hndlpp: OCI_HTYPE_BIND
    (for a bind handle) or OCI_HTYPE_DEFINE (for a define handle).
    in_outp (OUT) - returns OCI_PARAM_IN if the data is required for an IN bind
    value. Returns OCI_PARAM_OUT if the data is available as an OUT bind
    variable or a define position value.
    iterp (OUT) - returns the row number of a multiple row operation.
    idxp (OUT) - the index of an array element of a PL/SQL array bind operation.
    piecep (OUT) - returns one of the following defined values -
    OCI_ONE_PIECE, OCI_FIRST_PIECE, OCI_NEXT_PIECE and
    OCI_LAST_PIECE. The default value is always OCI_ONE_PIECE.
    Related Functions
    OCIAttrGet(), OCIAttrGet(), OCIStmtExecute(), OCIStmtFetch(),
    OCIStmtSetPieceInfo()




    OCIStmtPrepare()
    Name
    OCI Statement REQuest
    Purpose
    This call defines the SQL/PLSQL statement to be executed.
    Syntax
    sword OCIStmtPrepare ( OCIStmt            *stmtp,
                    OCIError            *errhp,
                    CONST OraText        *stmt,
                    ub4                    stmt_len,
                    ub4                    language,
                    ub4                    mode);
    Comments
    This call is used to prepare a SQL or PL/SQL statement for execution. The
    OCIStmtPrepare() call defines an application request.
    This is a purely local call. Data values for this statement initialized in
    subsequent bind calls will be stored in a bind handle which will hang off this
    statement handle.
    This call does not create an association between this statement handle and any
    particular server.
    See the section "Preparing Statements" on page 2-21 for more information
    about using this call.
    Parameters
    stmtp (IN) - a statement handle.
    errhp (IN) - an error handle to retrieve diagnostic information.
    stmt (IN) - SQL or PL/SQL statement to be executed. Must be a null-terminated
    string. The pointer to the OraText of the statement must be available as long
    as the statement is executed.
    stmt_len (IN) - length of the statement. Must not be zero.
    language (IN) - V7, V8, or native syntax. Possible values are:
    OCI_V7_SYNTAX - V7 ORACLE parsing syntax
    OCI_V8_SYNTAX - V8 ORACLE parsing syntax
    OCI_NTV_SYNTAX - syntax depending upon the version of the server.
    mode (IN) - the only defined mode is OCI_DEFAULT for default mode.
    Example
    This example demonstrates the use of OCIStmtPrepare(), as well as the OCI
    application initialization calls.
    Related Functions
    OCIAttrGet(), OCIStmtExecute()


    OCIStmtPrepare2()
    Name
    OCI Statement REQuest with (a) early binding to svchp and/or
    (b) stmt caching
    Purpose
    This call defines the SQL/PLSQL statement to be executed.
    Syntax
    sword OCIStmtPrepare2 ( OCISvcCtx *svchp,
                    OCIStmt            **stmtp,
                    OCIError            *errhp,
                    CONST OraText        *stmt,
                    ub4                    stmt_len,
                    CONST OraText *key,
                    ub4                    key_len,
                    ub4                    language,
                    ub4                    mode);
    Comments
    This call is used to prepare a SQL or PL/SQL statement for execution. The
    OCIStmtPrepare() call defines an application request.
    This is a purely local call. Data values for this statement initialized in
    subsequent bind calls will be stored in a bind handle which will hang off this
    statement handle.
    This call creates an association between the statement handle and a service
    context. It differs from OCIStmtPrepare in that respect.It also supports
    stmt caching. The stmt will automatically be cached if the authp of the stmt
    has enabled stmt caching.
    Parameters
    svchp (IN) - the service context handle that contains the session that
                this stmt handle belongs to.
    stmtp (OUT) - an unallocated stmt handle must be pased in. An allocated
                    and prepared    statement handle will be returned.
    errhp (IN) - an error handle to retrieve diagnostic information.
    stmt (IN) - SQL or PL/SQL statement to be executed. Must be a null-
                terminated string. The pointer to the OraText of the statement
                must be available as long as the statement is executed.
    stmt_len (IN) - length of the statement. Must not be zero.
    key (IN) - This is only Valid for OCI Stmt Caching. It indicates the
            key to search with. It thus optimizes the search in the cache.
    key_len (IN) - the length of the key. This, too, is onlly valid for stmt
                    caching.
    language (IN) - V7, V8, or native syntax. Possible values are:
    OCI_V7_SYNTAX - V7 ORACLE parsing syntax
    OCI_V8_SYNTAX - V8 ORACLE parsing syntax
    OCI_NTV_SYNTAX - syntax depending upon the version of the server.
    mode (IN) - the defined modes are OCI_DEFAULT and OCI_PREP2_CACHE_SEARCHONLY.
    Example
    Related Functions
    OCIStmtExecute(), OCIStmtRelease()


    OCIStmtRelease()
    Name
    OCI Statement Release. This call is used to relesae the stmt that
    was retreived using OCIStmtPrepare2(). If the stmt is release
    using this call, OCIHandleFree() must not be called on the stmt
    handle.
    Purpose
    This call releases the statement obtained by OCIStmtPrepare2
    Syntax
    sword OCIStmtRelease ( OCIStmt            *stmtp,
                    OCIError            *errhp,
                    cONST OraText *key,
                    ub4                    key_len,
                    ub4                    mode);
    Comments
    This call is used to release a handle obtained via OCIStmtPrepare2().
    It also frees the memory associated with the handle.
    This is a purely local call.
    Parameters
    stmtp (IN/OUT) - The statement handle to be released/freed.
    errhp (IN) - an error handle to retrieve diagnostic information.
    key (IN) - This is only Valid for OCI Stmt Caching. It indicates the
            key to tag the stmt with.
    key_len (IN) - the length of the key. This, too, is only valid for stmt
                    caching.
    mode (IN) - the defined modes are OCI_DEFAULT for default mode and
                OCI_STRLS_CACHE_DELETE (only used for Stmt Caching).
    Example
    Related Functions
    OCIStmtExecute(), OCIStmtPrepare2()


    OCIStmtSetPieceInfo()
    Name
    OCI Set Piece Information
    Purpose
    Sets piece information for a piecewise operation.
    Syntax
    sword OCIStmtSetPieceInfo ( dvoid                            *hndlp,
                    ub4                                type,
                    OCIError                    *errhp,
                    CONST dvoid                *bufp,
                    ub4                                *alenp,
                    ub1                                piece,
                    CONST dvoid                *indp,
                    ub2                                *rcodep );
    Comments
    When an execute call returns OCI_NEED_DATA to get a dynamic IN/OUT
    bind value or piece, OCIStmtSetPieceInfo() sets the piece information: the
    buffer, the length, the indicator and which piece is currently being processed.
    For more information about using OCIStmtSetPieceInfo() see the section
    "Runtime Data Allocation and Piecewise Operations" on page 5-16.
    Parameters
    hndlp (IN/OUT) - the bind/define handle.
    type (IN) - type of the handle.
    errhp (OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    bufp (IN/OUT) - bufp is a pointer to a storage containing the data value or
    the piece when it is an IN bind variable, otherwise bufp is a pointer to
    storage for getting a piece or a value for OUT binds and define variables. For
    named data types or REFs, a pointer to the object or REF is returned.
    alenp (IN/OUT) - the length of the piece or the value.
    piece (IN) - the piece parameter. The following are valid values:
    OCI_ONE_PIECE, OCI_FIRST_PIECE, OCI_NEXT_PIECE, or
    OCI_LAST_PIECE.
    The default value is OCI_ONE_PIECE. This parameter is used for IN bind
    variables only.
    indp (IN/OUT) - indicator. A pointer to a sb2 value or pointer to an indicator
    structure for named data types (SQLT_NTY) and REFs (SQLT_REF), i.e., *indp
    is either an sb2 or a dvoid * depending upon the data type.
    rcodep (IN/OUT) - return code.
    Related Functions
    OCIAttrGet(), OCIAttrGet(), OCIStmtExecute(), OCIStmtFetch(),
    OCIStmtGetPieceInfo()


    OCIFormatInit
    Name
    OCIFormat Package Initialize
    Purpose
    Initializes the OCIFormat package.
    Syntax
    sword OCIFormatInit(dvoid *hndl, OCIError *err);
    Comments
    This routine must be called before calling any other OCIFormat routine.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - OCI environment or session handle
    err (IN/OUT) - OCI error handle
    Related Functions
    OCIFormatTerm()


    OCIFormatString
    Name
    OCIFormat Package Format String
    Purpose
    Writes a text string into the supplied text buffer using the argument
    list submitted to it and in accordance with the format string given.
    Syntax
    sword OCIFormatString(dvoid *hndl, OCIError *err, OraText *buffer,
                        sbig_ora bufferLength, sbig_ora *returnLength,
                        CONST OraText *formatString, ...);
    Comments
    The first call to this routine must be preceded by a call to the
    OCIFormatInit routine that initializes the OCIFormat package
    for use.    When this routine is no longer needed then terminate
    the OCIFormat package by a call to the OCIFormatTerm routine.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl                    (IN/OUT) - OCI environment or session handle
    err                    (IN/OUT) - OCI error handle
    buffer                (OUT)        - text buffer for the string
    bufferLength (IN)            - length of the text buffer
    returnLength (OUT)        - length of the formatted string
    formatString (IN)            - format specification string
    ...                    (IN)            - variable argument list
    Related Functions


    OCIFormatTerm
    Name
    OCIFormat Package Terminate
    Purpose
    Terminates the OCIFormat package.
    Syntax
    sword OCIFormatTerm(dvoid *hndl, OCIError *err);
    Comments
    It must be called after the OCIFormat package is no longer being used.
    Returns OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
    Parameters
    hndl (IN/OUT) - OCI environment or session handle
    err (IN/OUT) - OCI error handle
    Related Functions
    OCIFormatInit()


    OCIFormatTUb1
    Name
    OCIFormat Package ub1 Type
    Purpose
    Return the type value for the ub1 type.
    Syntax
    sword OCIFormatTUb1(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTUb2
    Name
    OCIFormat Package ub2 Type
    Purpose
    Return the type value for the ub2 type.
    Syntax
    sword OCIFormatTUb2(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTUb4
    Name
    OCIFormat Package ub4 Type
    Purpose
    Return the type value for the ub4 type.
    Syntax
    sword OCIFormatTUb4(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTUword
    Name
    OCIFormat Package uword Type
    Purpose
    Return the type value for the uword type.
    Syntax
    sword OCIFormatTUword(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTUbig_ora
    Name
    OCIFormat Package ubig_ora Type
    Purpose
    Return the type value for the ubig_ora type.
    Syntax
    sword OCIFormatTUbig_ora(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTSb1
    Name
    OCIFormat Package sb1 Type
    Purpose
    Return the type value for the sb1 type.
    Syntax
    sword OCIFormatTSb1(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTSb2
    Name
    OCIFormat Package sb2 Type
    Purpose
    Return the type value for the sb2 type.
    Syntax
    sword OCIFormatTSb2(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTSb4
    Name
    OCIFormat Package sb4 Type
    Purpose
    Return the type value for the sb4 type.
    Syntax
    sword OCIFormatTSb4(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTSword
    Name
    OCIFormat Package sword Type
    Purpose
    Return the type value for the sword type.
    Syntax
    sword OCIFormatTSword(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTSbig_ora
    Name
    OCIFormat Package sbig_ora Type
    Purpose
    Return the type value for the sbig_ora type.
    Syntax
    sword OCIFormatTSbig_ora(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTEb1
    Name
    OCIFormat Package eb1 Type
    Purpose
    Return the type value for the eb1 type.
    Syntax
    sword OCIFormatTEb1(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTEb2
    Name
    OCIFormat Package eb2 Type
    Purpose
    Return the type value for the eb2 type.
    Syntax
    sword OCIFormatTEb2(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTEb4
    Name
    OCIFormat Package eb4 Type
    Purpose
    Return the type value for the eb4 type.
    Syntax
    sword OCIFormatTEb4(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTEword
    Name
    OCIFormat Package eword Type
    Purpose
    Return the type value for the eword type.
    Syntax
    sword OCIFormatTEword(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTChar
    Name
    OCIFormat Package text Type
    Purpose
    Return the type value for the text type.
    Syntax
    sword OCIFormatTChar(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTText
    Name
    OCIFormat Package *text Type
    Purpose
    Return the type value for the *text type.
    Syntax
    sword OCIFormatTText(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTDouble
    Name
    OCIFormat Package double Type
    Purpose
    Return the type value for the double type.
    Syntax
    sword OCIFormatTDouble(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatDvoid
    Name
    OCIFormat Package dvoid Type
    Purpose
    Return the type value for the dvoid type.
    Syntax
    sword OCIFormatTDvoid(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCIFormatTEnd
    Name
    OCIFormat Package end Type
    Purpose
    Return the list terminator's "type".
    Syntax
    sword OCIFormatTEnd(void);
    Comments
    None
    Parameters
    None
    Related Functions
    None


    OCISvcCtxToLda()
    Name
    OCI toggle SerVice context handle to Version 7 Lda_Def
    Purpose
    Toggles between a V8 service context handle and a V7 Lda_Def.
    Syntax
    sword OCISvcCtxToLda ( OCISvcCtx        *srvhp,
                    OCIError            *errhp,
                    Lda_Def            *ldap );
    Comments
    Toggles between an Oracle8 service context handle and an Oracle7 Lda_Def.
    This function can only be called after a service context has been properly
    initialized.
    Once the service context has been translated to an Lda_Def, it can be used in
    release 7.x OCI calls (e.g., obindps(), ofen()).
    Note: If there are multiple service contexts which share the same server
    handle, only one can be in V7 mode at any time.
    The action of this call can be reversed by passing the resulting Lda_Def to
    the OCILdaToSvcCtx() function.
    Parameters
    svchp (IN/OUT) - the service context handle.
    errhp (IN/OUT) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    ldap (IN/OUT) - a Logon Data Area for V7-style OCI calls which is initialized
    by this call.
    Related Functions
    OCILdaToSvcCtx()




    OCITransCommit()
    Name
    OCI TX (transaction) CoMmit
    Purpose
    Commits the transaction associated with a specified service context.
    Syntax
    sword OCITransCommit ( OCISvcCtx        *srvcp,
                    OCIError            *errhp,
                    ub4                    flags );
    Comments
    The transaction currently associated with the service context is committed. If
    it is a distributed transaction that the server cannot commit, this call
    additionally retrieves the state of the transaction from the database to be
    returned to the user in the error handle.
    If the application has defined multiple transactions, this function operates
    on the transaction currently associated with the service context. If the
    application is working with only the implicit local transaction created when
    database changes are made, that implicit transaction is committed.
    If the application is running in the object mode, then the modified or updated
    objects in the object cache for this transaction are also committed.
    The flags parameter is used for one-phase commit optimization in distributed
    transactions. If the transaction is non-distributed, the flags parameter is
    ignored, and OCI_DEFAULT can be passed as its value. OCI applications
    managing global transactions should pass a value of
    OCI_TRANS_TWOPHASE to the flags parameter for a two-phase commit. The
    default is one-phase commit.
    Under normal circumstances, OCITransCommit() returns with a status
    indicating that the transaction has either been committed or rolled back. With
    distributed transactions, it is possible that the transaction is now in-doubt
    (i.e., neither committed nor aborted). In this case, OCITransCommit()
    attempts to retrieve the status of the transaction from the server.
    The status is returned.
    Parameters
    srvcp (IN) - the service context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    flags -see the "Comments" section above.
    Related Functions
    OCITransRollback()




    OCITransDetach()
    Name
    OCI TX (transaction) DeTach
    Purpose
    Detaches a transaction.
    Syntax
    sword OCITransDetach ( OCISvcCtx        *srvcp,
                    OCIError            *errhp,
                    ub4                    flags);
    Comments
    Detaches a global transaction from the service context handle. The transaction
    currently attached to the service context handle becomes inactive at the end
    of this call. The transaction may be resumed later by calling OCITransStart(),
    specifying    a flags value of OCI_TRANS_RESUME.
    When a transaction is detached, the value which was specified in the timeout
    parameter of OCITransStart() when the transaction was started is used to
    determine the amount of time the branch can remain inactive before being
    deleted by the server's PMON process.
    Note: The transaction can be resumed by a different process than the one
    that detached it, provided that the transaction has the same
    authorization.
    Parameters
    srvcp (IN) - the service context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    flags (IN) - you must pass a value of OCI_DEFAULT for this parameter.
    Related Functions
    OCITransStart()



    OCITransForget()
    Name
    OCI TX (transaction) ForGeT
    Purpose
    Causes the server to forget a heuristically completed global transaction.
    Syntax
    sword OCITransForget ( OCISvcCtx            *svchp,
                    OCIError            *errhp,
                    ub4                        flags);

    Comments

    Forgets a heuristically completed global transaction. The server deletes the
    status of the transaction from the system's pending transaction table.
    The XID of the transaction to be forgotten is set as an attribute of the
    transaction handle (OCI_ATTR_XID).
    Parameters
    srvcp (IN) - the service context handle - the transaction is rolled back.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    flags (IN) - you must pass OCI_DEFAULT for this parameter.
    Related Functions
    OCITransCommit(), OCITransRollback()


    OCITransMultiPrepare()
    Name
    OCI Trans(action) Multi-Branch Prepare
    Purpose
    Prepares a transaction with multiple branches in a single call.
    Syntax
    sword OCITransMultiPrepare ( OCISvcCtx        *svchp,
                        ub4                        numBranches,
                        OCITrans            **txns,
                        OCIError            **errhp);

    Comments

    Prepares the specified global transaction for commit.
    This call is valid only for distributed transactions.
    This call is an advanced performance feature intended for use only in
    situations where the caller is responsible for preparing all the branches
    in a transaction.
    Parameters
    srvcp (IN) - the service context handle.
    numBranches (IN) - This is the number of branches expected. It is also the
    array size for the next two parameters.
    txns (IN) - This is the array of transaction handles for the branches to
    prepare. They should all have the OCI_ATTR_XID set. The global transaction
    ID should be the same.
    errhp (IN) - This is the array of error handles. If OCI_SUCCESS is not
    returned, then these will indicate which branches received which errors.
    Related Functions
    OCITransPrepare()


    OCITransPrepare()
    Name
    OCI TX (transaction) PREpare
    Purpose
    Prepares a transaction for commit.
    Syntax
    sword OCITransPrepare ( OCISvcCtx        *svchp,
                        OCIError            *errhp,
                        ub4                    flags);

    Comments

    Prepares the specified global transaction for commit.
    This call is valid only for distributed transactions.
    The call returns OCI_SUCCESS_WITH_INFO if the transaction has not made
    any changes. The error handle will indicate that the transaction is read-only.
    The flag parameter is not currently used.
    Parameters
    srvcp (IN) - the service context handle.
    errhp (IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    flags (IN) - you must pass OCI_DEFAULT for this parameter.
    Related Functions
    OCITransCommit(), OCITransForget()




    OCITransRollback()
    Name
    OCI TX (transaction) RoLlback
    Purpose
    Rolls back the current transaction.
    Syntax
    sword OCITransRollback ( dvoid                *svchp,
                        OCIError            *errhp,
                        ub4                    flags );
    Comments
    The current transaction- defined as the set of statements executed since the
    last OCITransCommit() or since OCISessionBegin()-is rolled back.
    If the application is running under object mode then the modified or updated
    objects in the object cache for this transaction are also rolled back.
    An error is returned if an attempt is made to roll back a global transaction
    that is not currently active.
    Parameters
    svchp (IN) - a service context handle. The transaction currently set in the
    service context handle is rolled back.
    errhp -(IN) - an error handle which can be passed to OCIErrorGet() for
    diagnostic information in the event of an error.
    flags - you must pass a value of OCI_DEFAULT for this parameter.
    Related Functions
    OCITransCommit()




    OCITransStart()
    Name
    OCI TX (transaction) STart
    Purpose
    Sets the beginning of a transaction.
    Syntax
    sword OCITransStart ( OCISvcCtx        *svchp,
                    OCIError            *errhp,
                    uword                timeout,
                    ub4                    flags);

    Comments
    This function sets the beginning of a global or serializable transaction. The
    transaction context currently associated with the service context handle is
    initialized at the end of the call if the flags parameter specifies that a new
    transaction should be started.
    The XID of the transaction is set as an attribute of the transaction handle
    (OCI_ATTR_XID)
    Parameters
    svchp (IN/OUT) - the service context handle. The transaction context in the
    service context handle is initialized at the end of the call if the flag
    specified a new transaction to be started.
    errhp (IN/OUT) - The OCI error handle. If there is an error, it is recorded in
    err and this function returns OCI_ERROR. Diagnostic information can be
    obtained by calling OCIErrorGet().
    timeout (IN) - the time, in seconds, to wait for a transaction to become
    available for resumption when OCI_TRANS_RESUME is specified. When
    OCI_TRANS_NEW is specified, this value is stored and may be used later by
    OCITransDetach().
    flags (IN) - specifies whether a new transaction is being started or an
    existing transaction is being resumed. Also specifies serializiability or
    read-only status. More than a single value can be specified. By default,
    a read/write transaction is started. The flag values are:
    OCI_TRANS_NEW - starts a new transaction branch. By default starts a
    tightly coupled and migratable branch.
    OCI_TRANS_TIGHT - explicitly specifies a tightly coupled branch
    OCI_TRANS_LOOSE - specifies a loosely coupled branch
    OCI_TRANS_RESUME - resumes an existing transaction branch.
    OCI_TRANS_READONLY - start a readonly transaction
    OCI_TRANS_SERIALIZABLE - start a serializable transaction
    Related Functions
    OCITransDetach()
    */

    /**
    *
    */
    alias sb4 function(dvoid* ictxp, OCIBind* bindp, ub4 iter, ub4 index, dvoid** bufpp, ub4* alenp, ub1* piecep, dvoid** indp) OCICallbackInBind;

    /**
    *
    */
    alias sb4 function(dvoid* octxp, OCIBind* bindp, ub4 iter, ub4 index, dvoid** bufpp, ub4** alenp, ub1* piecep, dvoid** indp, ub2** rcodep) OCICallbackOutBind;

    /**
    *
    */
    alias sb4 function(dvoid* octxp, OCIDefine* defnp, ub4 iter, dvoid** bufpp, ub4** alenp, ub1* piecep, dvoid** indp, ub2** rcodep) OCICallbackDefine;

    /**
    *
    */
    alias sword function(dvoid* ctxp, dvoid* hndlp, ub4 type, ub4 fcode, ub4 when, sword returnCode, sb4* errnop, va_list arglist) OCIUserCallback;

    /**
    *
    */
    alias sword function(OCIEnv* env, ub4 mode, size_t xtramem_sz, dvoid* usrmemp, OCIUcb* ucbDesc) OCIEnvCallbackType;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid* bufp, ub4 len, ub1 piece) OCICallbackLobRead;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid* bufp, ub4* lenp, ub1* piece) OCICallbackLobWrite;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid* bufp, oraub8 len, ub1 piece, dvoid** changed_bufpp, oraub8* changed_lenp) OCICallbackLobRead2;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid* bufp, oraub8* lenp, ub1* piece, dvoid** changed_bufpp, oraub8* changed_lenp) OCICallbackLobWrite2;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, ub4 array_iter, dvoid* bufp, oraub8 len, ub1 piece, dvoid** changed_bufpp, oraub8* changed_lenp) OCICallbackLobArrayRead;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, ub4 array_iter, dvoid* bufp, oraub8* lenp, ub1* piece, dvoid** changed_bufpp, oraub8* changed_lenp) OCICallbackLobArrayWrite;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid** payload, dvoid** payload_ind) OCICallbackAQEnq;

    /**
    *
    */
    alias sb4 function(dvoid* ctxp, dvoid** payload, dvoid** payload_ind) OCICallbackAQDeq;

    /**
    * Failover callback structure.
    */
    alias sb4 function(dvoid* svcctx, dvoid* envctx, dvoid* fo_ctx, ub4 fo_type, ub4 fo_event) OCICallbackFailover;

    /**
    *
    */
    struct OCIFocbkStruct {
        OCICallbackFailover callback_function;
        dvoid* fo_ctx;
    }

    /**
    * HA callback structure.
    */
    alias void function(dvoid* evtctx, OCIEvent* eventhp) OCIEventCallback;

    /**
    *
    */
    extern (C) sword OCIInitialize (ub4 mode, dvoid* ctxp, dvoid* function(dvoid* ctxp, size_t size) malocfp, dvoid* function(dvoid* ctxp, dvoid* memptr, size_t newsize) ralocfp, void function(dvoid* ctxp, dvoid* memptr) mfreefp);

    /**
    *
    */
    extern (C) sword OCITerminate (ub4 mode);

    /**
    *
    */
    extern (C) sword OCIEnvCreate (OCIEnv** envp, ub4 mode, dvoid* ctxp, dvoid* function(dvoid* ctxp, size_t size)malocfp, dvoid* function(dvoid* ctxp, dvoid* memptr, size_t newsize)ralocfp, void function(dvoid* ctxp, dvoid* memptr)mfreefp, size_t xtramem_sz, dvoid** usrmempp);

    /**
    *
    */
    extern (C) sword OCIEnvNlsCreate (OCIEnv** envp, ub4 mode, dvoid* ctxp, dvoid* function(dvoid* ctxp, size_t size) malocfp, dvoid* function(dvoid* ctxp, dvoid* memptr, size_t newsize) ralocfp, void function(dvoid* ctxp, dvoid* memptr) mfreefp, size_t xtramem_sz, dvoid** usrmempp, ub2 charset, ub2 ncharset);

    /**
    *
    */
    extern (C) sword OCIFEnvCreate (OCIEnv** envp, ub4 mode, dvoid* ctxp, dvoid* function(dvoid* ctxp, size_t size) malocfp, dvoid* function(dvoid* ctxp, dvoid* memptr, size_t newsize) ralocfp, void function(dvoid* ctxp, dvoid* memptr) mfreefp, size_t xtramem_sz, dvoid** usrmempp, dvoid* fupg);

    /**
    *
    */
    extern (C) sword OCIHandleAlloc (dvoid* parenth, dvoid** hndlpp, ub4 type, size_t xtramem_sz, dvoid** usrmempp);

    /**
    *
    */
    extern (C) sword OCIHandleFree (dvoid* hndlp, ub4 type);

    /**
    *
    */
    extern (C) sword OCIDescriptorAlloc (dvoid* parenth, dvoid** descpp, ub4 type, size_t xtramem_sz, dvoid** usrmempp);

    /**
    *
    */
    extern (C) sword OCIDescriptorFree(dvoid *descp, ub4 type);

    /**
    *
    */
    extern (C) sword OCIEnvInit (OCIEnv** envp, ub4 mode, size_t xtramem_sz, dvoid** usrmempp);

    /**
    *
    */
    extern (C) sword OCIServerAttach (OCIServer* srvhp, OCIError* errhp, OraText* dblink, sb4 dblink_len, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIServerDetach (OCIServer* srvhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionBegin (OCISvcCtx* svchp, OCIError* errhp, OCISession* usrhp, ub4 credt, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionEnd (OCISvcCtx* svchp, OCIError* errhp, OCISession* usrhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCILogon (OCIEnv* envhp, OCIError* errhp, OCISvcCtx** svchp, OraText* username, ub4 uname_len, OraText* password, ub4 passwd_len, OraText* dbname, ub4 dbname_len);

    /**
    *
    */
    extern (C) sword OCILogon2 (OCIEnv* envhp, OCIError* errhp, OCISvcCtx** svchp, OraText* username, ub4 uname_len, OraText* password, ub4 passwd_len, OraText* dbname, ub4 dbname_len, ub4 mode);

    /**
    *
    */
    extern (C) sword OCILogoff (OCISvcCtx* svchp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIPasswordChange (OCISvcCtx* svchp, OCIError* errhp, OraText* user_name, ub4 usernm_len, OraText* opasswd, ub4 opasswd_len, OraText* npasswd, ub4 npasswd_len, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIStmtPrepare (OCIStmt* stmtp, OCIError* errhp, OraText* stmt, ub4 stmt_len, ub4 language, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIStmtPrepare2 (OCISvcCtx* svchp, OCIStmt** stmtp, OCIError* errhp, OraText* stmt, ub4 stmt_len, OraText* key, ub4 key_len, ub4 language, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIStmtRelease (OCIStmt* stmtp, OCIError* errhp, OraText* key, ub4 key_len, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIBindByPos (OCIStmt* stmtp, OCIBind** bindp, OCIError* errhp, ub4 position, dvoid* valuep, sb4 value_sz, ub2 dty, dvoid* indp, ub2* alenp, ub2* rcodep, ub4 maxarr_len, ub4* curelep, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIBindByName (OCIStmt* stmtp, OCIBind** bindp, OCIError* errhp, OraText* placeholder, sb4 placeh_len, dvoid* valuep, sb4 value_sz, ub2 dty, dvoid* indp, ub2* alenp, ub2* rcodep, ub4 maxarr_len, ub4* curelep, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIBindObject (OCIBind* bindp, OCIError* errhp, OCIType* type, dvoid** pgvpp, ub4* pvszsp, dvoid** indpp, ub4* indszp);

    /**
    *
    */
    extern (C) sword OCIBindDynamic (OCIBind* bindp, OCIError* errhp, dvoid* ictxp, OCICallbackInBind icbfp, dvoid* octxp, OCICallbackOutBind ocbfp);

    /**
    *
    */
    extern (C) sword OCIBindArrayOfStruct (OCIBind* bindp, OCIError* errhp, ub4 pvskip, ub4 indskip, ub4 alskip, ub4 rcskip);

    /**
    *
    */
    extern (C) sword OCIStmtGetPieceInfo (OCIStmt* stmtp, OCIError* errhp, dvoid** hndlpp, ub4* typep, ub1* in_outp, ub4* iterp, ub4* idxp, ub1* piecep);

    /**
    *
    */
    extern (C) sword OCIStmtSetPieceInfo (dvoid* hndlp, ub4 type, OCIError* errhp, dvoid* bufp, ub4* alenp, ub1 piece, dvoid* indp, ub2* rcodep);

    /**
    *
    */
    extern (C) sword OCIStmtExecute (OCISvcCtx* svchp, OCIStmt* stmtp, OCIError* errhp, ub4 iters, ub4 rowoff, OCISnapshot* snap_in, OCISnapshot* snap_out, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIDefineByPos (OCIStmt* stmtp, OCIDefine** defnp, OCIError* errhp, ub4 position, dvoid* valuep, sb4 value_sz, ub2 dty, dvoid* indp, ub2* rlenp, ub2* rcodep, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIDefineObject (OCIDefine* defnp, OCIError* errhp, OCIType* type, dvoid** pgvpp, ub4* pvszsp, dvoid** indpp, ub4* indszp);

    /**
    *
    */
    extern (C) sword OCIDefineDynamic (OCIDefine* defnp, OCIError* errhp, dvoid* octxp, OCICallbackDefine ocbfp);

    /**
    *
    */
    extern (C) sword OCIRowidToChar (OCIRowid* rowidDesc, OraText* outbfp, ub2* outbflp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIDefineArrayOfStruct (OCIDefine* defnp, OCIError* errhp, ub4 pvskip, ub4 indskip, ub4 rlskip, ub4 rcskip);

    /**
    *
    */
    extern (C) sword OCIStmtFetch (OCIStmt* stmtp, OCIError* errhp, ub4 nrows, ub2 orientation, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIStmtFetch2 (OCIStmt* stmtp, OCIError* errhp, ub4 nrows, ub2 orientation, sb4 scrollOffset, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIStmtGetBindInfo (OCIStmt* stmtp, OCIError* errhp, ub4 size, ub4 startloc, sb4* found, OraText** bvnp, ub1* bvnl, OraText** invp, ub1* inpl, ub1* dupl, OCIBind** hndl);

    /**
    *
    */
    extern (C) sword OCIDescribeAny (OCISvcCtx* svchp, OCIError* errhp, dvoid* objptr, ub4 objnm_len, ub1 objptr_typ, ub1 info_level, ub1 objtyp, OCIDescribe* dschp);

    /**
    *
    */
    extern (C) sword OCIParamGet (dvoid* hndlp, ub4 htype, OCIError* errhp, dvoid** parmdpp, ub4 pos);

    /**
    *
    */
    extern (C) sword OCIParamSet (dvoid* hdlp, ub4 htyp, OCIError* errhp, dvoid* dscp, ub4 dtyp, ub4 pos);

    /**
    *
    */
    extern (C) sword OCITransStart (OCISvcCtx* svchp, OCIError* errhp, uword timeout, ub4 flags);

    /**
    *
    */
    extern (C) sword OCITransDetach (OCISvcCtx* svchp, OCIError* errhp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCITransCommit (OCISvcCtx* svchp, OCIError* errhp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCITransRollback (OCISvcCtx* svchp, OCIError* errhp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCITransPrepare (OCISvcCtx* svchp, OCIError* errhp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCITransMultiPrepare (OCISvcCtx* svchp, ub4 numBranches, OCITrans** txns, OCIError** errhp);

    /**
    *
    */
    extern (C) sword OCITransForget (OCISvcCtx* svchp, OCIError* errhp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIErrorGet (dvoid* hndlp, ub4 recordno, OraText* sqlstate, sb4* errcodep, OraText* bufp, ub4 bufsiz, ub4 type);

    /**
    *
    */
    extern (C) sword OCILobAppend (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* dst_locp, OCILobLocator* src_locp);

    /**
    *
    */
    extern (C) sword OCILobAssign (OCIEnv* envhp, OCIError* errhp, OCILobLocator* src_locp, OCILobLocator** dst_locpp);

    /**
    *
    */
    extern (C) sword OCILobCharSetForm (OCIEnv* envhp, OCIError* errhp, OCILobLocator* locp, ub1* csfrm);

    /**
    *
    */
    extern (C) sword OCILobCharSetId (OCIEnv* envhp, OCIError* errhp, OCILobLocator* locp, ub2* csid);

    /**
    *
    */
    extern (C) sword OCILobCopy (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* dst_locp, OCILobLocator* src_locp, ub4 amount, ub4 dst_offset, ub4 src_offset);

    /**
    *
    */
    extern (C) sword OCILobCreateTemporary (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub2 csid, ub1 csfrm, ub1 lobtype, boolean cache, OCIDuration duration);

    /**
    *
    */
    extern (C) sword OCILobClose (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp);

    /**
    *
    */
    extern (C) sword OCILobDisableBuffering (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp);

    /**
    *
    */
    extern (C) sword OCILobEnableBuffering (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp);

    /**
    *
    */
    extern (C) sword OCILobErase (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4* amount, ub4 offset);

    /**
    *
    */
    extern (C) sword OCILobFileClose (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* filep);

    /**
    *
    */
    extern (C) sword OCILobFileCloseAll (OCISvcCtx* svchp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCILobFileExists (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* filep, boolean* flag);

    /**
    *
    */
    extern (C) sword OCILobFileGetName (OCIEnv* envhp, OCIError* errhp, OCILobLocator* filep, OraText* dir_alias, ub2* d_length, OraText* filename, ub2* f_length);

    /**
    *
    */
    extern (C) sword OCILobFileIsOpen (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* filep, boolean* flag);

    /**
    *
    */
    extern (C) sword OCILobFileOpen (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* filep, ub1 mode);

    /**
    *
    */
    extern (C) sword OCILobFileSetName (OCIEnv* envhp, OCIError* errhp, OCILobLocator** filepp, OraText* dir_alias, ub2 d_length, OraText* filename, ub2 f_length);

    /**
    *
    */
    extern (C) sword OCILobFlushBuffer (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4 flag);

    /**
    *
    */
    extern (C) sword OCILobFreeTemporary (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp);

    /**
    *
    */
    extern (C) sword OCILobGetChunkSize (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4* chunksizep);

    /**
    *
    */
    extern (C) sword OCILobGetLength (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4* lenp);

    /**
    *
    */
    extern (C) sword OCILobIsEqual (OCIEnv* envhp, OCILobLocator* x, OCILobLocator* y, boolean* is_equal);

    /**
    *
    */
    extern (C) sword OCILobIsOpen (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, boolean* flag);

    /**
    *
    */
    extern (C) sword OCILobIsTemporary (OCIEnv* envp, OCIError* errhp, OCILobLocator* locp, boolean* is_temporary);

    /**
    *
    */
    extern (C) sword OCILobLoadFromFile (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* dst_locp, OCILobLocator* src_filep, ub4 amount, ub4 dst_offset, ub4 src_offset);

    /**
    *
    */
    extern (C) sword OCILobLocatorAssign (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* src_locp, OCILobLocator** dst_locpp);

    /**
    *
    */
    extern (C) sword OCILobLocatorIsInit (OCIEnv* envhp, OCIError* errhp, OCILobLocator* locp, boolean* is_initialized);

    /**
    *
    */
    extern (C) sword OCILobOpen (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub1 mode);

    /**
    *
    */
    extern (C) sword OCILobRead (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4* amtp, ub4 offset, dvoid* bufp, ub4 bufl, dvoid* ctxp, OCICallbackLobRead cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobTrim (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4 newlen);

    /**
    *
    */
    extern (C) sword OCILobWrite (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, ub4* amtp, ub4 offset, dvoid* bufp, ub4 buflen, ub1 piece, dvoid* ctxp, OCICallbackLobWrite cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobWriteAppend (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* lobp, ub4* amtp, dvoid* bufp, ub4 bufl, ub1 piece, dvoid* ctxp, OCICallbackLobWrite cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCIBreak (dvoid* hndlp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIReset (dvoid* hndlp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIServerVersion (dvoid* hndlp, OCIError* errhp, OraText* bufp, ub4 bufsz, ub1 hndltype);

    /**
    *
    */
    extern (C) sword OCIServerRelease (dvoid* hndlp, OCIError* errhp, OraText* bufp, ub4 bufsz, ub1 hndltype, ub4* s_version);

    /**
    *
    */
    extern (C) sword OCIAttrGet (dvoid* trgthndlp, ub4 trghndltyp, dvoid* attributep, ub4* sizep, ub4 attrtype, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIAttrSet (dvoid* trgthndlp, ub4 trghndltyp, dvoid* attributep, ub4 size, ub4 attrtype, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCISvcCtxToLda (OCISvcCtx* svchp, OCIError* errhp, Lda_Def* ldap);

    /**
    *
    */
    extern (C) sword OCILdaToSvcCtx (OCISvcCtx** svchpp, OCIError* errhp, Lda_Def* ldap);

    /**
    *
    */
    extern (C) sword OCIResultSetToStmt (OCIResult* rsetdp, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIFileClose (dvoid* hndl, OCIError* err, OCIFileObject* filep);

    /**
    *
    */
    extern (C) sword OCIUserCallbackRegister (dvoid* hndlp, ub4 type, dvoid* ehndlp, OCIUserCallback callback, dvoid* ctxp, ub4 fcode, ub4 when, OCIUcb* ucbDesc);

    /**
    *
    */
    extern (C) sword OCIUserCallbackGet (dvoid* hndlp, ub4 type, dvoid* ehndlp, ub4 fcode, ub4 when, OCIUserCallback* callbackp, dvoid** ctxpp, OCIUcb* ucbDesc);

    /**
    *
    */
    extern (C) sword OCISharedLibInit (dvoid* metaCtx, dvoid* libCtx, ub4 argfmt, sword argc, dvoid** argv, OCIEnvCallbackType envCallback);

    /**
    *
    */
    extern (C) sword OCIFileExists (dvoid* hndl, OCIError* err, OraText* filename, OraText* path, ub1* flag);

    /**
    *
    */
    extern (C) sword OCIFileFlush (dvoid* hndl, OCIError* err, OCIFileObject* filep);

    /**
    *
    */
    extern (C) sword OCIFileGetLength (dvoid* hndl, OCIError* err, OraText* filename, OraText* path, ubig_ora* lenp);

    /**
    *
    */
    extern (C) sword OCIFileInit (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIFileOpen (dvoid* hndl, OCIError* err, OCIFileObject** filep, OraText* filename, OraText* path, ub4 mode, ub4 create, ub4 type);

    /**
    *
    */
    extern (C) sword OCIFileRead (dvoid* hndl, OCIError* err, OCIFileObject* filep, dvoid* bufp, ub4 bufl, ub4* bytesread);

    /**
    *
    */
    extern (C) sword OCIFileSeek (dvoid* hndl, OCIError* err, OCIFileObject* filep, uword origin, ubig_ora offset, sb1 dir);

    /**
    *
    */
    extern (C) sword OCIFileTerm (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIFileWrite (dvoid* hndl, OCIError* err, OCIFileObject* filep, dvoid* bufp, ub4 buflen, ub4* byteswritten);

    /**
    *
    */
    extern (C) sword OCILobCopy2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* dst_locp, OCILobLocator* src_locp, oraub8 amount, oraub8 dst_offset, oraub8 src_offset);

    /**
    *
    */
    extern (C) sword OCILobErase2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, oraub8* amount, oraub8 offset);

    /**
    *
    */
    extern (C) sword OCILobGetLength2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, oraub8* lenp);

    /**
    *
    */
    extern (C) sword OCILobLoadFromFile2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* dst_locp, OCILobLocator* src_filep, oraub8 amount, oraub8 dst_offset, oraub8 src_offset);

    /**
    *
    */
    extern (C) sword OCILobRead2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, oraub8* byte_amtp, oraub8* char_amtp, oraub8 offset, dvoid* bufp, oraub8 bufl, ub1 piece, dvoid* ctxp, OCICallbackLobRead2 cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobArrayRead (OCISvcCtx* svchp, OCIError* errhp, ub4* array_iter, OCILobLocator** lobp_arr, oraub8* byte_amt_arr, oraub8* char_amt_arr, oraub8* offset_arr, dvoid** bufp_arr, oraub8* bufl_arr, ub1 piece, dvoid* ctxp, OCICallbackLobArrayRead cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobTrim2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp,    oraub8 newlen);

    /**
    *
    */
    extern (C) sword OCILobWrite2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* locp, oraub8* byte_amtp, oraub8* char_amtp, oraub8 offset, dvoid* bufp, oraub8 buflen, ub1 piece, dvoid* ctxp, OCICallbackLobWrite2 cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobArrayWrite (OCISvcCtx* svchp, OCIError* errhp, ub4* array_iter, OCILobLocator** lobp_arr, oraub8* byte_amt_arr, oraub8* char_amt_arr, oraub8* offset_arr, dvoid** bufp_arr, oraub8* bufl_arr, ub1 piece, dvoid* ctxp, OCICallbackLobArrayWrite cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobWriteAppend2 (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* lobp, oraub8* byte_amtp, oraub8* char_amtp, dvoid* bufp, oraub8 bufl, ub1 piece, dvoid* ctxp, OCICallbackLobWrite2 cbfp, ub2 csid, ub1 csfrm);

    /**
    *
    */
    extern (C) sword OCILobGetStorageLimit (OCISvcCtx* svchp, OCIError* errhp, OCILobLocator* lobp, oraub8* limitp);

    /**
    *
    */
    extern (C) sword OCISecurityInitialize (OCISecurity* sechandle, OCIError* error_handle);

    /**
    *
    */
    extern (C) sword OCISecurityTerminate (OCISecurity* sechandle, OCIError* error_handle);

    /**
    *
    */
    extern (C) sword OCISecurityOpenWallet (OCISecurity* osshandle, OCIError* error_handle, size_t wrllen, OraText* wallet_resource_locator, size_t pwdlen, OraText* password, nzttWallet* wallet);

    /**
    *
    */
    extern (C) sword OCISecurityCloseWallet (OCISecurity* osshandle, OCIError* error_handle, nzttWallet* wallet);

    /**
    *
    */
    extern (C) sword OCISecurityCreateWallet (OCISecurity* osshandle, OCIError* error_handle, size_t wrllen, OraText* wallet_resource_locator, size_t pwdlen, OraText* password, nzttWallet* wallet);

    /**
    *
    */
    extern (C) sword OCISecurityDestroyWallet (OCISecurity* osshandle, OCIError* error_handle, size_t wrllen, OraText* wallet_resource_locator, size_t pwdlen, OraText* password);

    /**
    *
    */
    extern (C) sword OCISecurityStorePersona (OCISecurity* osshandle, OCIError* error_handle, nzttPersona** persona, nzttWallet* wallet);

    /**
    *
    */
    extern (C) sword OCISecurityOpenPersona (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona);

    /**
    *
    */
    extern (C) sword OCISecurityClosePersona (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona);

    /**
    *
    */
    extern (C) sword OCISecurityRemovePersona (OCISecurity* osshandle, OCIError* error_handle, nzttPersona** persona);

    /**
    *
    */
    extern (C) sword OCISecurityCreatePersona (OCISecurity* osshandle, OCIError* error_handle, nzttIdentType identity_type, nzttCipherType cipher_type, nzttPersonaDesc* desc, nzttPersona** persona);

    /**
    *
    */
    extern (C) sword OCISecuritySetProtection (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttcef crypto_engine_function, nztttdufmt data_unit_format, nzttProtInfo* protection_info);

    /**
    *
    */
    extern (C) sword OCISecurityGetProtection (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttcef crypto_engine_function, nztttdufmt*    data_unit_format_ptr, nzttProtInfo* protection_info);

    /**
    *
    */
    extern (C) sword OCISecurityRemoveIdentity (OCISecurity* osshandle, OCIError* error_handle, nzttIdentity** identity_ptr);

    /**
    *
    */
    extern (C) sword OCISecurityCreateIdentity (OCISecurity* osshandle, OCIError* error_handle, nzttIdentType type, nzttIdentityDesc* desc, nzttIdentity** identity_ptr);

    /**
    *
    */
    extern (C) sword OCISecurityAbortIdentity (OCISecurity* osshandle, OCIError* error_handle, nzttIdentity** identity_ptr);

    /**
    *
    */
    extern (C) sword OCISecurityFreeIdentity (OCISecurity* osshandle, OCIError* error_handle, nzttIdentity** identity_ptr);

    /**
    *
    */
    extern (C) sword OCISecurityStoreTrustedIdentity (OCISecurity* osshandle, OCIError* error_handle, nzttIdentity** identity_ptr, nzttPersona* persona);

    /**
    *
    */
    extern (C) sword OCISecuritySign (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces signature_state, size_t input_length, ub1* input, nzttBufferBlock* buffer_block);

    /**
    *
    */
    extern (C) sword OCISecuritySignExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t inputlen, size_t* signature_length);

    /**
    *
    */
    extern (C) sword OCISecurityVerify (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces signature_state, size_t siglen, ub1* signature, nzttBufferBlock* extracted_message, boolean* verified, boolean* validated, nzttIdentity** signing_party_identity);

    /**
    *
    */
    extern (C) sword OCISecurityValidate (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttIdentity* identity, boolean* validated);

    /**
    *
    */
    extern (C) sword OCISecuritySignDetached (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces signature_state, size_t input_length, ub1* input, nzttBufferBlock* signature);

    /**
    *
    */
    extern (C) sword OCISecuritySignDetExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t input_length, size_t* required_buffer_length);

    /**
    *
    */
    extern (C) sword OCISecurityVerifyDetached (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces signature_state, size_t data_length, ub1* data, size_t siglen, ub1* signature, boolean* verified, boolean* validated, nzttIdentity** signing_party_identity);

    /**
    *
    */
    extern (C) sword OCISecurity_PKEncrypt (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t number_of_recipients, nzttIdentity* recipient_list, nzttces encryption_state, size_t input_length, ub1* input, nzttBufferBlock* encrypted_data);

    /**
    *
    */
    extern (C) sword OCISecurityPKEncryptExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t number_recipients, size_t input_length, size_t* buffer_length_required);

    /**
    *
    */
    extern (C) sword OCISecurityPKDecrypt (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces encryption_state, size_t input_length, ub1* input, nzttBufferBlock* encrypted_data);

    /**
    *
    */
    extern (C) sword OCISecurityEncrypt (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces encryption_state, size_t input_length, ub1* input, nzttBufferBlock* encrypted_data);

    /**
    *
    */
    extern (C) sword OCISecurityEncryptExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t input_length, size_t* encrypted_data_length);

    /**
    *
    */
    extern (C) sword OCISecurityDecrypt (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces decryption_state, size_t input_length, ub1* input, nzttBufferBlock* decrypted_data);

    /**
    *
    */
    extern (C) sword OCISecurityEnvelope (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t number_of_recipients, nzttIdentity* identity, nzttces encryption_state, size_t input_length, ub1* input, nzttBufferBlock* enveloped_data);

    /**
    *
    */
    extern (C) sword OCISecurityDeEnvelope (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces decryption_state, size_t input_length, ub1* input, nzttBufferBlock* output_message, boolean* verified, boolean* validated, nzttIdentity** sender_identity);

    /**
    *
    */
    extern (C) sword OCISecurityKeyedHash (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces hash_state, size_t input_length, ub1* input, nzttBufferBlock* keyed_hash);

    /**
    *
    */
    extern (C) sword OCISecurityKeyedHashExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t input_length, size_t* required_buffer_length);

    /**
    *
    */
    extern (C) sword OCISecurityHash (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, nzttces hash_state, size_t input, ub1* input_length, nzttBufferBlock* hash);

    /**
    *
    */
    extern (C) sword OCISecurityHashExpansion (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t input_length, size_t* required_buffer_length);

    /**
    *
    */
    extern (C) sword OCISecuritySeedRandom (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t seed_length, ub1* seed);

    /**
    *
    */
    extern (C) sword OCISecurityRandomBytes (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, size_t number_of_bytes_desired, nzttBufferBlock* random_bytes);

    /**
    *
    */
    extern (C) sword OCISecurityRandomNumber (OCISecurity* osshandle, OCIError* error_handle, nzttPersona* persona, uword* random_number_ptr);

    /**
    *
    */
    extern (C) sword OCISecurityInitBlock (OCISecurity* osshandle, OCIError* error_handle, nzttBufferBlock* buffer_block);

    /**
    *
    */
    extern (C) sword OCISecurityReuseBlock (OCISecurity* osshandle, OCIError* error_handle, nzttBufferBlock* buffer_block);

    /**
    *
    */
    extern (C) sword OCISecurityPurgeBlock (OCISecurity* osshandle, OCIError* error_handle, nzttBufferBlock* buffer_block);

    /**
    *
    */
    extern (C) sword OCISecuritySetBlock (OCISecurity* osshandle, OCIError* error_handle, uword flags_to_set, size_t buffer_length, size_t used_buffer_length, ub1* buffer, nzttBufferBlock* buffer_block);

    /**
    *
    */
    extern (C) sword OCISecurityGetIdentity (OCISecurity* osshandle, OCIError* error_handle, size_t namelen, OraText* distinguished_name, nzttIdentity** identity);

    /**
    *
    */
    extern (C) sword OCIAQEnq (OCISvcCtx* svchp, OCIError* errhp, OraText* queue_name, OCIAQEnqOptions* enqopt, OCIAQMsgProperties* msgprop, OCIType* payload_tdo, dvoid** payload, dvoid** payload_ind, OCIRaw** msgid, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIAQDeq (OCISvcCtx* svchp, OCIError* errhp, OraText* queue_name, OCIAQDeqOptions* deqopt, OCIAQMsgProperties* msgprop, OCIType* payload_tdo, dvoid** payload, dvoid** payload_ind, OCIRaw** msgid, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIAQEnqArray (OCISvcCtx* svchp, OCIError* errhp, OraText* queue_name, OCIAQEnqOptions* enqopt, ub4* iters, OCIAQMsgProperties** msgprop, OCIType* payload_tdo, dvoid** payload, dvoid** payload_ind, OCIRaw** msgid, dvoid* ctxp, OCICallbackAQEnq enqcbfp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIAQDeqArray (OCISvcCtx* svchp, OCIError* errhp, OraText* queue_name, OCIAQDeqOptions* deqopt, ub4* iters, OCIAQMsgProperties** msgprop, OCIType* payload_tdo, dvoid** payload, dvoid** payload_ind, OCIRaw** msgid, dvoid* ctxp, OCICallbackAQDeq deqcbfp, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIAQListen (OCISvcCtx* svchp, OCIError* errhp,    OCIAQAgent** agent_list, ub4 num_agents, sb4 wait, OCIAQAgent** agent, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIAQListen2 (OCISvcCtx* svchp, OCIError* errhp, OCIAQAgent** agent_list, ub4 num_agents, OCIAQListenOpts * lopts, OCIAQAgent** agent, OCIAQLisMsgProps* lmops, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIExtractInit (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIExtractTerm (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIExtractReset (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIExtractSetNumKeys (dvoid* hndl, OCIError* err, uword numkeys);

    /**
    *
    */
    extern (C) sword OCIExtractSetKey (dvoid* hndl, OCIError* err, OraText* name, ub1 type, ub4 flag, dvoid* defval, sb4* intrange, OraText** strlist);

    /**
    *
    */
    extern (C) sword OCIExtractFromFile (dvoid* hndl, OCIError* err, ub4 flag, OraText* filename);

    /**
    *
    */
    extern (C) sword OCIExtractFromStr (dvoid* hndl, OCIError* err, ub4 flag, OraText* input);

    /**
    *
    */
    extern (C) sword OCIExtractToInt (dvoid* hndl, OCIError* err, OraText* keyname, uword valno, sb4* retval);

    /**
    *
    */
    extern (C) sword OCIExtractToBool (dvoid* hndl, OCIError* err, OraText* keyname, uword valno, ub1* retval);

    /**
    *
    */
    extern (C) sword OCIExtractToStr (dvoid* hndl, OCIError* err, OraText* keyname, uword valno, OraText* retval, uword buflen);

    /**
    *
    */
    extern (C) sword OCIExtractToOCINum (dvoid* hndl, OCIError* err, OraText* keyname, uword valno, OCINumber* retval);

    /**
    *
    */
    extern (C) sword OCIExtractToList (dvoid* hndl, OCIError* err, uword* numkeys);

    /**
    *
    */
    extern (C) sword OCIExtractFromList (dvoid* hndl, OCIError* err, uword index, OraText** name, ub1* type, uword* numvals, dvoid*** values);

    /**
    *
    */
    extern (C) sword OCIMemoryAlloc (dvoid* hdl, OCIError* err, dvoid** mem, OCIDuration dur, ub4 size, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIMemoryResize (dvoid* hdl, OCIError* err, dvoid** mem, ub4 newsize, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIMemoryFree (dvoid* hdl, OCIError* err, dvoid* mem);

    /**
    *
    */
    extern (C) sword OCIContextSetValue (dvoid* hdl, OCIError* err, OCIDuration duration, ub1* key, ub1 keylen, dvoid* ctx_value);

    /**
    *
    */
    extern (C) sword OCIContextGetValue (dvoid* hdl, OCIError* err, ub1* key, ub1 keylen, dvoid** ctx_value);

    /**
    *
    */
    extern (C) sword OCIContextClearValue (dvoid* hdl, OCIError* err, ub1* key, ub1 keylen);

    /**
    *
    */
    extern (C) sword OCIContextGenerateKey (dvoid* hdl, OCIError* err, ub4* key);

    /**
    *
    */
    extern (C) sword OCIMemorySetCurrentIDs (dvoid* hdl, OCIError* err, ub4 curr_session_id, ub4 curr_trans_id, ub4 curr_stmt_id);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCtxInit (OCIEnv* env, OCIError* err, OCIPicklerTdsCtx** tdsc);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCtxFree (OCIEnv* env, OCIError* err, OCIPicklerTdsCtx* tdsc);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsInit (OCIEnv* env, OCIError* err, OCIPicklerTdsCtx* tdsc, OCIPicklerTds** tdsh);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsFree (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCreateElementNumber (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, ub1 prec, sb1 scale, OCIPicklerTdsElement* elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCreateElementChar (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, ub2 len, OCIPicklerTdsElement* elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCreateElementVarchar (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, ub2 len, OCIPicklerTdsElement* elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCreateElementRaw (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, ub2 len, OCIPicklerTdsElement* elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsCreateElement (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, OCITypeCode dty, OCIPicklerTdsElement* elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsAddAttr (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, OCIPicklerTdsElement elt);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsGenerate (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh);

    /**
    *
    */
    extern (C) sword OCIPicklerTdsGetAttr (OCIEnv* env, OCIError* err, OCIPicklerTds* tdsh, ub1 attrno, OCITypeCode* typ, ub2* len);

    /**
    *
    */
    extern (C) sword OCIPicklerFdoInit (OCIEnv* env, OCIError* err, OCIPicklerFdo** fdoh);

    /**
    *
    */
    extern (C) sword OCIPicklerFdoFree (OCIEnv* env, OCIError* err, OCIPicklerFdo* fdoh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageInit (OCIEnv* env, OCIError* err, OCIPicklerFdo* fdoh, OCIPicklerTds* tdsh, OCIPicklerImage** imgh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageFree (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageAddScalar (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, dvoid* scalar, ub4 len);

    /**
    *
    */
    extern (C) sword OCIPicklerImageAddNullScalar (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageGenerate (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageGetScalarSize (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, ub4 attrno, ub4* size);

    /**
    *
    */
    extern (C) sword OCIPicklerImageGetScalar (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, ub4 attrno, dvoid* buf, ub4* len, OCIInd* ind);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollBegin (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, OCIPicklerTds* colltdsh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollAddScalar (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, dvoid* scalar, ub4 buflen, OCIInd ind);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollEnd (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollBeginScan (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, OCIPicklerTds* coll_tdsh, ub4 attrnum, ub4 startidx, OCIInd* ind);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollGetScalarSize (OCIEnv* env, OCIError* err, OCIPicklerTds* coll_tdsh, ub4* size);

    /**
    *
    */
    extern (C) sword OCIPicklerImageCollGetScalar (OCIEnv* env, OCIError* err, OCIPicklerImage* imgh, dvoid* buf, ub4* buflen, OCIInd* ind);

    /**
    *
    */
    extern (C) sword OCIAnyDataGetType (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode* tc, OCIType** type);

    /**
    *
    */
    extern (C) sword OCIAnyDataIsNull (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, boolean* isnull);

    /**
    *
    */
    extern (C) sword OCIAnyDataConvert (OCISvcCtx* svchp, OCIError* errhp, OCITypeCode tc, OCIType* type, OCIDuration dur, dvoid* ind, dvoid* data_val, ub4 len, OCIAnyData** sdata);

    /**
    *
    */
    extern (C) sword OCIAnyDataBeginCreate (OCISvcCtx* svchp, OCIError* errhp, OCITypeCode tc, OCIType* type, OCIDuration dur, OCIAnyData** sdata);

    /**
    *
    */
    extern (C) sword OCIAnyDataDestroy (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata);

    /**
    *
    */
    extern (C) sword OCIAnyDataAttrSet (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode tc, OCIType* type, dvoid* ind, dvoid* attr_val, ub4 length, boolean is_any);

    /**
    *
    */
    extern (C) sword OCIAnyDataCollAddElem (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode tc, OCIType* type, dvoid* ind, dvoid* attr_val, ub4 length, boolean is_any, boolean last_elem);

    /**
    *
    */
    extern (C) sword OCIAnyDataEndCreate (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata);

    /**
    *
    */
    extern (C) sword OCIAnyDataAccess (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode tc, OCIType* type, dvoid* ind, dvoid* attr_val, ub4* length);

    /**
    *
    */
    extern (C) sword OCIAnyDataGetCurrAttrNum(OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, ub4* attrnum);

    /**
    *
    */
    extern (C) sword OCIAnyDataAttrGet (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode tc, OCIType* type, dvoid* ind, dvoid* attr_val, ub4* length, boolean is_any);

    /**
    *
    */
    extern (C) sword OCIAnyDataCollGetElem (OCISvcCtx* svchp, OCIError* errhp, OCIAnyData* sdata, OCITypeCode tc, OCIType* type, dvoid* ind, dvoid* celem_val, ub4* length, boolean is_any);

    /*
        NAME
            OCIAnyDataSetBeginCreate - OCIAnyDataSet Begin Creation
        PARAMETERS
            svchp (IN/OUT) - The OCI service context.
            errhp (IN/OUT) - The OCI error handle. If there is an error, it is
                        recorded in errhp and this function returns OCI_ERROR.
                        Diagnostic information can be obtained by calling
                        OCIErrorGet().
            typecode                - typecode corresponding to the OCIAnyDataSet.
            type (IN)            - type corresponding to the OCIAnyDataSet. If the typecode
                        corresponds to a built-in type (OCI_TYPECODE_NUMBER etc.)
                        , this parameter can be NULL. It should be non NULL for
                        user defined types (OCI_TYPECODE_OBJECT,
                        OCI_TYPECODE_REF, collection types etc.)
            dur (IN)                - duration for which OCIAnyDataSet is allocated.
            data_set (OUT) - Initialized OCIAnyDataSet.
            RETURNS                - error code
        NOTES
            This call allocates an OCIAnyDataSet for the duration of dur and
            initializes it with the type information. The OCIAnyDataSet can hold
            multiple instances of the given type. For performance reasons, the
            OCIAnyDataSet will end up pointing to the passed in OCIType parameter.
            It is the responsibility of the caller to ensure that the OCIType is
            longer lived (has allocation duration >= the duration of the OCIAnyData
            if the OCIType is a transient one, allocation/pin duration >= duration of
            the OCIAnyData if the OCIType is a persistent one).

    */
    extern (C) sword OCIAnyDataSetBeginCreate (OCISvcCtx* svchp, OCIError* errhp, OCITypeCode typecode, OCIType* type, OCIDuration dur, OCIAnyDataSet**    data_set);

    /*
        NAME
            OCIAnyDataSetDestroy    - OCIAnyDataSet Destroy
        DESCRIPTION
            This call frees the OCIAnyDataSet allocated using
            OCIAnyDataSetBeginCreate().
        RETURNS
            error code.
        PARAMETERS
            svchp (IN/OUT)        - The OCI service context.
            errhp (IN/OUT)        - The OCI Error handle.
            data_set (IN/OUT) - OCIAnyDataSet to be freed.
    */
    extern (C) sword OCIAnyDataSetDestroy (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set);

    /*
        NAME
            OCIAnyDataSetAddInstance - OCIAnyDataSet Add an instance
        DESCRIPTION
            This call adds a new skeleton instance to the OCIAnyDataSet and all the
            attributes of the instance are set to NULL. It returns this skeleton
            instance through the OCIAnyData parameter which can be enumructed
            subsequently by invoking the OCIAnyData API.
        RETURNS
            error code.
        PARAMETERS
            svchp (IN/OUT)            - The OCI service context.
            errhp (IN/OUT)            - The OCI Error handle.
            data_set (IN/OUT)        - OCIAnyDataSet to which a new instance is added.
            data (IN/OUT)                - OCIAnyData corresponding to the newly added
                    instance. If (*data) is NULL, a new OCIAnyData will
                    be allocated for same duration as the OCIAnyDataSet.
                    If (*data) is not NULL, it will get reused. This
                    OCIAnyData can be subseqently enumructed using the
                    OCIAnyDataConvert() call or it can be enumructed
                    piece-wise using the OCIAnyDataAttrSet and
                    OCIAnyDataCollAddElem calls.
        NOTES
            No Destruction of the old value is done here. It is the responsibility of
            the caller to destroy the old value pointed to by (*data) and set (*data)
            to a null pointer before beginning to make a sequence of this call. No
            deep copying (of OCIType information nor the data part.) is done in the
            returned OCIAnyData. This OCIAnyData cannot be used beyond the allocation
            duration of the OCIAnyDataSet (it is like a reference into the
            OCIAnyDataSet). The returned OCIAnyData can be reused on subsequent calls
            to this function, to sequentially add new data instances to the
            OCIAnyDataSet.
    */
    extern (C) sword OCIAnyDataSetAddInstance (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set, OCIAnyData** data);

    /*
        NAME
            OCIAnyDataSetEndCreate - OCIAnyDataSet End Creation process.
        DESCRIPTION
            This call marks the end of OCIAnyDataSet creation. It should be called
            after enumructing all of its instance(s).
        RETURNS
            error code.
        PARAMETERS
            svchp (IN/OUT)                - The OCI service context.
            errhp (IN/OUT)                - The OCI error handle. If there is an error, it is
                        recorded in errhp and this function returns
                        OCI_ERROR. Diagnostic information can be obtained
                        by calling OCIErrorGet().
            data_set (IN/OUT)            - OCIAnyDataSet that has been fully enumructed.
    */
    extern (C) sword OCIAnyDataSetEndCreate (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set);

    /*
        NAME
            OCIAnyDataSetGetType - OCIAnyDataSet Get Type of an OCIAnyDataSet
        DESCRIPTION
            Gets the Type corresponding to an OCIAnyDataSet. It returns the actual
            pointer to the type maintained inside an OCIAnyDataSet. No copying is
            done for performance reasons. The client is responsible for not using
            this type once the OCIAnyDataSet is freed (or its duration ends).
        RETURNS
            error code.
        PARAMETERS
            svchp (IN/OUT)            - The OCI service context.
            errhp (IN/OUT)            - The OCI Error handle.
            data_set (IN)                - Initialized OCIAnyDataSet.
            tc (OUT)                        - The typecode of the type.
            type (OUT)                    - The type corresponding to the OCIAnyDataSet. This
                    could be null if the OCIAnyData corresponds to a
                    built-in type.
    */
    extern (C) sword OCIAnyDataSetGetType (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set, OCITypeCode* tc, OCIType** type);

    /*
        NAME
            OCIAnyDataSetGetCount - OCIAnyDataSet Get Count of instances.
        DESCRIPTION
            This call gets the number of instances in the OCIAnyDataSet.
        RETURNS
            error code.
        PARAMETERS
            svchp (IN/OUT)            - OCI Service Context
            errhp (IN/OUT)            - OCI Error handle
            data_set (IN)                - Well formed OCIAnyDataSet.
            count (OUT)                    - number of instances in OCIAnyDataSet
    */
    extern (C) sword OCIAnyDataSetGetCount (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set, ub4* count);

    /*
        NAME
            OCIAnyDataSetGetInstance - OCIAnyDataSet Get next instance.
        DESCRIPTION
            Only sequential access to the instances in an OCIAnyDataSet is allowed.
            This call returns the OCIAnyData corresponding to an instance at the
            current position and updates the current position. Subsequently, the
            OCIAnyData access routines may be used to access the instance.
        RETURNS
            error code. Returns OCI_NO_DATA if the current position is at the end of
            the set, OCI_SUCCESS otherwise.
        PARAMETERS
            svchp (IN/OUT)            - OCI Service Context
            errhp (IN/OUT)            - OCI Error handle
            data_set (IN)                - Well formed OCIAnyDataSet
            data (IN/OUT)                - OCIAnyData corresponding to the instance. If (*data)
                    is NULL, a new OCIAnyData will be allocated for same
                    duration as the OCIAnyDataSet. If (*data) is not NULL
                    , it will get reused. This OCIAnyData can be
                    subsequently accessed using the OCIAnyDataAccess()
                    call or piece-wise by using the OCIAnyDataAttrGet()
                    call.
        NOTE
            No Destruction of the old value is done here. It is the responsibility of
            the caller to destroy the old value pointed to by (*data) and set (*data)
            to a null pointer before beginning to make a sequence of this call. No deep
            copying (of OCIType information nor the data part.) is done in the returned
            OCIAnyData. This OCIAnyData cannot be used beyond the allocation duration
            of the OCIAnyDataSet (it is like a reference into the OCIAnyDataSet). The
            returned OCIAnyData can be reused on subsequent calls to this function to
            sequentially access the OCIAnyDataSet.
    */
    extern (C) sword OCIAnyDataSetGetInstance (OCISvcCtx* svchp, OCIError* errhp, OCIAnyDataSet* data_set, OCIAnyData** data);

    /**
    *
    */
    extern (C) sword OCIFormatInit (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIFormatString (dvoid* hndl, OCIError* err, OraText* buffer, sbig_ora bufferLength, sbig_ora* returnLength, OraText* formatString, ...);

    /**
    *
    */
    extern (C) sword OCIFormatTerm (dvoid* hndl, OCIError* err);


    /**
    *
    */
    extern (C) sword OCIFormatTUb1 ();

    /**
    *
    */
    extern (C) sword OCIFormatTUb2 ();

    /**
    *
    */
    extern (C) sword OCIFormatTUb4 ();

    /**
    *
    */
    extern (C) sword OCIFormatTUword ();

    /**
    *
    */
    extern (C) sword OCIFormatTUbig_ora ();

    /**
    *
    */
    extern (C) sword OCIFormatTSb1 ();

    /**
    *
    */
    extern (C) sword OCIFormatTSb2 ();

    /**
    *
    */
    extern (C) sword OCIFormatTSb4 ();

    /**
    *
    */
    extern (C) sword OCIFormatTSword ();

    /**
    *
    */
    extern (C) sword OCIFormatTSbig_ora ();

    /**
    *
    */
    extern (C) sword OCIFormatTEb1 ();

    /**
    *
    */
    extern (C) sword OCIFormatTEb2 ();

    /**
    *
    */
    extern (C) sword OCIFormatTEb4 ();

    /**
    *
    */
    extern (C) sword OCIFormatTEword ();

    /**
    *
    */
    extern (C) sword OCIFormatTChar ();

    /**
    *
    */
    extern (C) sword OCIFormatTText ();

    /**
    *
    */
    extern (C) sword OCIFormatTDouble ();

    /**
    *
    */
    extern (C) sword OCIFormatTDvoid ();

    /**
    *
    */
    extern (C) sword OCIFormatTEnd ();

    /*
        NAME
            xaosvch    -    XA Oracle get SerViCe Handle
        DESCRIPTION
            Given a database name return the service handle that is used by the
            XA library
        NOTE
            This macro has been provided for backward compatibilty with 8.0.2
    */
    extern (C) OCISvcCtx* xaosvch (OraText* dbname);

    /*
        NAME
            xaoSvcCtx    -    XA Oracle get SerViCe ConTeXt
        DESCRIPTION
            Given a database name return the service handle that is used by the
            XA library
        NOTE
            This routine has been provided for APs to get access to the service
            handle that XA library uses. Without this routine APs must use SQLLIB
            routine sqlld2 to get access to the Logon data area registered by the
            XA library
    */
    extern (C) OCISvcCtx* xaoSvcCtx (OraText* dbname);

    /*
        NAME
            xaoEnv    -    XA Oracle get ENvironment Handle
        DESCRIPTION
            Given a database name return the environment handle that is used by the
            XA library
        NOTE
            This routine has been provided for APs to get access to the environment
            handle that XA library uses. Without this routine APs must use SQLLIB
            routine sqlld2 to get access to the Logon data area registered by the
            XA library
    */
    extern (C) OCIEnv* xaoEnv (OraText* dbname);

    /*
        NAME
            xaosterr    -    XA Oracle get xa STart ERRor code
        DESCRIPTION
            Given an oracle error code return the XA error code
    */
    extern (C) int xaosterr (OCISvcCtx* svch, sb4 error);

    /*
        NAME
            OCINlsGetInfo - Get NLS info from OCI environment handle
        REMARKS
            This function generates language information specified by item from OCI
            environment handle envhp into an array pointed to by buf within size
            limitation as buflen.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR on wrong item.
        envhp(IN/OUT)
            OCI environment handle.
        errhp(IN/OUT)
            The OCI error handle. If there is an error, it is record in errhp and
            this function returns a NULL pointer. Diagnostic information can be
            obtained by calling OCIErrorGet().
        buf(OUT)
            Pointer to the destination buffer.
        buflen(IN)
            The size of destination buffer. The maximum length for each information
            is 32 bytes.
        item(IN)
            It specifies to get which item in OCI environment handle and can be one
            of following values:
                OCI_NLS_DAYNAME1 : Native name for Monday.
                OCI_NLS_DAYNAME2 : Native name for Tuesday.
                OCI_NLS_DAYNAME3 : Native name for Wednesday.
                OCI_NLS_DAYNAME4 : Native name for Thursday.
                OCI_NLS_DAYNAME5 : Native name for Friday.
                OCI_NLS_DAYNAME6 : Native name for for Saturday.
                OCI_NLS_DAYNAME7 : Native name for for Sunday.
                OCI_NLS_ABDAYNAME1 : Native abbreviated name for Monday.
                OCI_NLS_ABDAYNAME2 : Native abbreviated name for Tuesday.
                OCI_NLS_ABDAYNAME3 : Native abbreviated name for Wednesday.
                OCI_NLS_ABDAYNAME4 : Native abbreviated name for Thursday.
                OCI_NLS_ABDAYNAME5 : Native abbreviated name for Friday.
                OCI_NLS_ABDAYNAME6 : Native abbreviated name for for Saturday.
                OCI_NLS_ABDAYNAME7 : Native abbreviated name for for Sunday.
                OCI_NLS_MONTHNAME1 : Native name for January.
                OCI_NLS_MONTHNAME2 : Native name for February.
                OCI_NLS_MONTHNAME3 : Native name for March.
                OCI_NLS_MONTHNAME4 : Native name for April.
                OCI_NLS_MONTHNAME5 : Native name for May.
                OCI_NLS_MONTHNAME6 : Native name for June.
                OCI_NLS_MONTHNAME7 : Native name for July.
                OCI_NLS_MONTHNAME8 : Native name for August.
                OCI_NLS_MONTHNAME9 : Native name for September.
                OCI_NLS_MONTHNAME10 : Native name for October.
                OCI_NLS_MONTHNAME11 : Native name for November.
                OCI_NLS_MONTHNAME12 : Native name for December.
                OCI_NLS_ABMONTHNAME1 : Native abbreviated name for January.
                OCI_NLS_ABMONTHNAME2 : Native abbreviated name for February.
                OCI_NLS_ABMONTHNAME3 : Native abbreviated name for March.
                OCI_NLS_ABMONTHNAME4 : Native abbreviated name for April.
                OCI_NLS_ABMONTHNAME5 : Native abbreviated name for May.
                OCI_NLS_ABMONTHNAME6 : Native abbreviated name for June.
                OCI_NLS_ABMONTHNAME7 : Native abbreviated name for July.
                OCI_NLS_ABMONTHNAME8 : Native abbreviated name for August.
                OCI_NLS_ABMONTHNAME9 : Native abbreviated name for September.
                OCI_NLS_ABMONTHNAME10 : Native abbreviated name for October.
                OCI_NLS_ABMONTHNAME11 : Native abbreviated name for November.
                OCI_NLS_ABMONTHNAME12 : Native abbreviated name for December.
                OCI_NLS_YES : Native string for affirmative response.
                OCI_NLS_NO : Native negative response.
                OCI_NLS_AM : Native equivalent string of AM.
                OCI_NLS_PM : Native equivalent string of PM.
                OCI_NLS_AD : Native equivalent string of AD.
                OCI_NLS_BC : Native equivalent string of BC.
                OCI_NLS_DECIMAL : decimal character.
                OCI_NLS_GROUP : group separator.
                OCI_NLS_DEBIT : Native symbol of debit.
                OCI_NLS_CREDIT : Native sumbol of credit.
                OCI_NLS_DATEFORMAT : Oracle date format.
                OCI_NLS_INT_CURRENCY: International currency symbol.
                OCI_NLS_LOC_CURRENCY : Locale currency symbol.
                OCI_NLS_LANGUAGE : Language name.
                OCI_NLS_ABLANGUAGE : Abbreviation for language name.
                OCI_NLS_TERRITORY : Territory name.
                OCI_NLS_CHARACTER_SET : Character set name.
                OCI_NLS_LINGUISTIC : Linguistic name.
                OCI_NLS_CALENDAR : Calendar name.
                OCI_NLS_DUAL_CURRENCY : Dual currency symbol.
    */
    extern (C) sword OCINlsGetInfo (dvoid* envhp, OCIError* errhp, OraText* buf, size_t buflen, ub2 item);

    /*
        NAME
            OCINlsNumericInfoGet - Get NLS numeric info from OCI environment handle
        REMARKS
            This function generates numeric language information specified by item
            from OCI environment handle envhp into an output number variable.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR on wrong item.
        envhp(IN/OUT)
            OCI environment handle. If handle invalid, returns OCI_INVALID_HANDLE.
        errhp(IN/OUT)
            The OCI error handle. If there is an error, it is record in errhp and
            this function returns a NULL pointer. Diagnostic information can be
            obtained by calling OCIErrorGet().
        val(OUT)
            Pointer to the output number variable. On OCI_SUCCESS return, it will
            contain the requested NLS numeric info.
        item(IN)
            It specifies to get which item in OCI environment handle and can be one
            of following values:
                OCI_NLS_CHARSET_MAXBYTESZ : Maximum character byte size for OCI
                        environment or session handle charset
                OCI_NLS_CHARSET_FIXEDWIDTH: Character byte size for fixed-width charset;
                        0 for variable-width charset
    */
    extern (C) sword OCINlsNumericInfoGet (dvoid* envhp, OCIError* errhp, sb4* val, ub2 item);

    /*
        NAME
            OCINlsCharSetNameToId - Get Oracle charset id given Oracle charset name
        REMARKS
            This function will get the Oracle character set id corresponding to
            the given Oracle character set name.
        RETURNS
            Oracle character set id for the given Oracle character set name if
            character set name and OCI handle are valid; otherwise returns 0.
        envhp(IN/OUT)
            OCI environment handle.
        name(IN)
            Pointer to a null-terminated Oracle character set name whose id
            will be returned.
    */
    extern (C) ub2 OCINlsCharSetNameToId (dvoid* envhp, oratext* name);

    /*
        NAME
            OCINlsCharSetIdToName - Get Oracle charset name given Oracle charset id
        REMARKS
            This function will get the Oracle character set name corresponding to
            the given Oracle character set id.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle. If handle invalid, returns OCI_INVALID_HANDLE.
        buf(OUT)
            Pointer to the destination buffer. On OCI_SUCCESS return, it will contain
            the null-terminated string for character set name.
        buflen(IN)
            Size of destination buffer. Recommended size is OCI_NLS_MAXBUFSZ for
            guarantee to store an Oracle character set name. If it's smaller than
            the length of the character set name, the function will return OCI_ERROR.
        id(IN)
            Oracle character set id.
    */
    extern (C) sword OCINlsCharSetIdToName (dvoid* envhp, oratext* buf, size_t buflen, ub2 id);

    /*
        NAME
            OCINlsNameMap - Map NLS naming from Oracle to other standards and vice
                    versa
        REMARKS
            This function will map NLS naming from Oracle to other standards (such
            as ISO, IANA) and vice versa.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE, or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle. If handle invalid, returns OCI_INVALID_HANDLE.
        buf(OUT)
            Pointer to the destination buffer. On OCI_SUCCESS return, it will
            contain null-terminated string for requested mapped name.
        buflen(IN)
            The size of destination buffer. Recommended size is OCI_NLS_MAXBUFSZ
            for guarantee to store an NLS name. If it is smaller than the length
            of the name, the function will return OCI_ERROR.
        srcbuf(IN)
            Pointer to null-terminated NLS name. If it is not a valid name in its
            define scope, the function will return OCI_ERROR.
        flag(IN)
            It specifies name mapping direction and can take the following values:
                OCI_NLS_CS_IANA_TO_ORA : Map character set name from IANA to Oracle
                OCI_NLS_CS_ORA_TO_IANA : Map character set name from Oracle to IANA
                OCI_NLS_LANG_ISO_TO_ORA : Map language name from ISO to Oracle
                OCI_NLS_LANG_ORA_TO_ISO : Map language name from Oracle to ISO
                OCI_NLS_TERR_ISO_TO_ORA : Map territory name from ISO to Oracle
                OCI_NLS_TERR_ORA_TO_ISO : Map territory name from Oracle to ISO
                OCI_NLS_TERR_ISO3_TO_ORA : Map territory name from 3-letter ISO
                        abbreviation to Oracle
                OCI_NLS_TERR_ORA_TO_ISO3 : Map territory name from Oracle to 3-letter
                        ISO abbreviation
    */
    extern (C) sword OCINlsNameMap (dvoid* envhp, oratext* buf, size_t buflen, oratext* srcbuf, ub4 flag);

    /*
        NAME
            OCIMultiByteToWideChar - Convert a null terminated multibyte string into
                            wchar
        REMARKS
            This routine converts an entire null-terminated string into the wchar
            format. The wchar output buffer will be null-terminated.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle to determine the character set of string.
        dst (OUT)
            Destination buffer for wchar.
        src (IN)
            Source string to be converted.
        rsize (OUT)
            Number of characters converted including null-terminator.
            If it is a NULL pointer, no number return
    */
    extern (C) sword OCIMultiByteToWideChar (dvoid* envhp, OCIWchar* dst, OraText* src, size_t* rsize);

    /*
        NAME
            OCIMultiByteInSizeToWideChar - Convert a mulitbyte string in length into
                            wchar
        REMARKS
            This routine converts part of string into the wchar format. It will
            convert as many complete characters as it can until it reaches output
            buffer size or input buffer size or it reaches a null-terminator in
            source string. The output buffer will be null-terminated if space permits.
            If dstsz is zero, this function will only return number of characters not
            including ending null terminator for converted string.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle to determine the character set of string.
        dst (OUT)
            Pointer to a destination buffer for wchar. It can be NULL pointer when
            dstsz is zero.
        dstsz(IN)
            Destination buffer size in character. If it is zero, this function just
            returns number of characters will be need for the conversion.
        src (IN)
            Source string to be converted.
        srcsz(IN)
            Length of source string in byte.
        rsize(OUT)
            Number of characters written into destination buffer, or number of
            characters for converted string is dstsz is zero.
            If it is NULL pointer, nothing to return.
    */
    extern (C) sword OCIMultiByteInSizeToWideChar (dvoid* envhp, OCIWchar* dst, size_t dstsz, OraText* src, size_t srcsz, size_t* rsize);


    /*
        NAME
            OCIWideCharToMultiByte - Convert a null terminated wchar string into
                            multibyte
        REMARKS
            This routine converts an entire null-terminated wide character string into
            multi-byte string. The output buffer will be null-terminated.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle to determine the character set of string.
        dst (OUT)
            Destination buffer for multi-byte string.
        src (IN)
            Source wchar string to be converted.
        rsize (OUT)
            Number of bytes written into the destination buffer.
            If it is NULL pointer, nothing to return.
    */
    extern (C) sword OCIWideCharToMultiByte (dvoid* envhp, OraText* dst, OCIWchar* src, size_t* rsize);

    /*
        NAME
            OCIWideCharInSizeToMultiByte - Convert a wchar string in length into
                            mulitbyte
        REMARKS
            This routine converts part of wchar string into the multi-byte format.
            It will convert as many complete characters as it can until it reaches
            output buffer size or input buffer size or it reaches a null-terminator
            in source string. The output buffer will be null-terminated if space
            permits. If dstsz is zero, the function just returns the size of byte not
            including ending null-terminator need to store the converted string.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            OCI environment handle to determine the character set of string.
        dst (OUT)
            Destination buffer for multi-byte. It can be NULL pointer if dstsz is
            zero.
        dstsz(IN)
            Destination buffer size in byte. If it is zero, it just returns the size
            of bytes need for converted string.
        src (IN)
            Source wchar string to be converted.
        srcsz(IN)
            Length of source string in character.
        rsize(OUT)
            Number of bytes written into destination buffer, or number of bytes need
            to store the converted string if dstsz is zero.
            If it is NULL pointer, nothing to return.
    */
    extern (C) sword OCIWideCharInSizeToMultiByte (dvoid* envhp, OraText* dst, size_t dstsz, OCIWchar* src, size_t srcsz, size_t* rsize);

    /*
        NAME
            OCIWideCharIsAlnum - test whether wc is a letter or decimal digit
        REMARKS
            It tests whether wc is a letter or decimal digit.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsAlnum (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsAlpha - test whether wc is an alphabetic letter
        REMARKS
            It tests whether wc is an alphabetic letter
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsAlpha (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsCntrl - test whether wc is a control character
        REMARKS
            It tests whether wc is a control character.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsCntrl (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsDigit - test whether wc is a decimal digit character
        REMARKS
            It tests whether wc is a decimal digit character.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsDigit (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsGraph - test whether wc is a graph character
        REMARKS
            It tests whether wc is a graph character. A graph character is character
            with a visible representation and normally includes alphabetic letter,
            decimal digit, and punctuation.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsGraph (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsLower - test whether wc is a lowercase letter
        REMARKS
            It tests whether wc is a lowercase letter.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsLower (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsPrint - test whether wc is a printable character
        REMARKS
            It tests whether wc is a printable character.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsPrint (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsPunct - test whether wc is a punctuation character
        REMARKS
            It tests whether wc is a punctuation character.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsPunct (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsSpace - test whether wc is a space character
        REMARKS
            It tests whether wc is a space character. A space character only causes
            white space in displayed text(for example, space, tab, carriage return,
            newline, vertical tab or form feed).
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsSpace (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsUpper - test whether wc is a uppercase letter
        REMARKS
            It tests whether wc is a uppercase letter.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsUpper (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsXdigit - test whether wc is a hexadecimal digit
        REMARKS
            It tests whether wc is a hexadecimal digit ( 0-9, A-F, a-f ).
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsXdigit (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharIsSingleByte - test whether wc is a single-byte character
        REMARKS
            It tests whether wc is a single-byte character when converted into
            multi-byte.
        RETURNS
            TRUE or FLASE.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for testing.
    */
    extern (C) boolean OCIWideCharIsSingleByte (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharToLower - Convert a wchar into the lowercase
        REMARKS
            If there is a lower-case character mapping for wc in the specified locale,
            it will return the lower-case in wchar, else return wc itself.
        RETURNS
            A wchar
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for lowercase mapping.
    */
    extern (C) OCIWchar OCIWideCharToLower (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharToUpper - Convert a wchar into the uppercase
        REMARKS
            If there is a upper-case character mapping for wc in the specified locale,
            it will return the upper-case in wchar, else return wc itself.
        RETURNS
            A wchar
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar for uppercase mapping.
    */
    extern (C) OCIWchar OCIWideCharToUpper (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharStrcmp - compare two null terminated wchar string
        REMARKS
            It compares two wchar string in binary ( based on wchar encoding value ),
            linguistic, or case-insensitive.
        RETURNS
            0, if wstr1 == wstr2.
            Positive, if wstr1 > wstr2.
            Negative, if wstr1 < wstr2.
        envhp(IN/OUT)
            OCI environment handle to determine the character set.
        wstr1(IN)
            Pointer to a null-terminated wchar string.
        wstr2(IN)
            Pointer to a null-terminated wchar string.
        flag(IN)
            It is used to decide the comparison method. It can be taken one of the
            following values:
                OCI_NLS_BINARY : for the binary comparison, this is default value.
                OCI_NLS_LINGUISTIC : for linguistic comparison specified in the locale.
            This flag can be ORed with OCI_NLS_CASE_INSENSITIVE for case-insensitive
            comparison.
    */
    extern (C) int OCIWideCharStrcmp (dvoid* envhp, OCIWchar* wstr1, OCIWchar* wstr2, int flag);

    /*
        NAME
            OCIWideCharStrncmp - compare twe wchar string in length
        REMARKS
            This function is similar to OCIWideCharStrcmp(), except that at most len1
            characters from wstr1 and len2 characters from wstr1 are compared. The
            null-terminator will be taken into the comparison.
        RETURNS
            0, if wstr1 = wstr2
            Positive, if wstr1 > wstr2
            Negative, if wstr1 < wstr2
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wstr1(IN)
            Pointer to the first wchar string
        len1(IN)
            The length for the first string for comparison
        wstr2(IN)
            Pointer to the second wchar string
        len2(IN)
            The length for the second string for comparison.
        flag(IN)
            It is used to decide the comparison method. It can be taken one of the
            following values:
                OCI_NLS_BINARY : for the binary comparison, this is default value.
                OCI_NLS_LINGUISTIC : for linguistic comparison specified in the locale.
            This flag can be ORed with OCI_NLS_CASE_INSENSITIVE for case-insensitive
            comparison.
    */
    extern (C) int OCIWideCharStrncmp (dvoid* envhp, OCIWchar* wstr1, size_t len1, OCIWchar* wstr2, size_t len2, int flag);

    /*
        NAME
            OCIWideCharStrcat - concatenate two wchar strings
        REMARKS
            This function appends a copy of the wchar string pointed to by wsrcstr,
            including the null-terminator to the end of wchar string pointed to by
            wdststr. It returns the number of character in the result string not
            including the ending null-terminator.
        RETURNS
            number of characters in the result string not including the ending
            null-terminator.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wdststr(IN/OUT)
            Pointer to the destination wchar string for appending.
        wsrcstr(IN)
            Pointer to the source wchar string to append.
    */
    extern (C) size_t OCIWideCharStrcat (dvoid* envhp, OCIWchar* wdststr, OCIWchar* wsrcstr);

    /*
        NAME
            OCIWideCharStrchr - Search the first occurrence of wchar in a wchar string
        REMARKS
            This function searchs for the first occurrence of wc in the wchar string
            pointed to by wstr. It returns a pointer to the whcar if successful, or
            a null pointer.
        RETURNS
            wchar pointer if successful, otherwise a null pointer.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wstr(IN)
            Pointer to the wchar string to search
        wc(IN)
            Wchar to search for.
    */
    extern (C) OCIWchar* OCIWideCharStrchr (dvoid* envhp, OCIWchar* wstr, OCIWchar wc);

    /*
        NAME
            OCIWideCharStrcpy - copy a wchar string
        REMARKS
            This function copies the wchar string pointed to by wsrcstr, including the
            null-terminator, into the array pointed to by wdststr. It returns the
            number of character copied not including the ending null-terminator.
        RETURNS
            number of characters copied not including the ending null-terminator.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wdststr(OUT)
            Pointer to the destination wchar buffer.
        wsrcstr(IN)
            Pointer to the source wchar string.
    */
    extern (C) size_t OCIWideCharStrcpy (dvoid* envhp, OCIWchar* wdststr, OCIWchar* wsrcstr);

    /*
        NAME
            OCIWideCharStrlen - Return number of character in a wchar string
        REMARKS
            This function computes the number of characters in the wchar string
            pointed to by wstr, not including the null-terminator, and returns
            this number.
        RETURNS
            number of characters not including ending null-terminator.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wstr(IN)
            Pointer to the source wchar string.
    */
    extern (C) size_t OCIWideCharStrlen (dvoid* envhp, OCIWchar* wstr);

    /*
        NAME
            OCIWideCharStrncat - Concatenate wchar string in length
        REMARKS
            This function is similar to OCIWideCharStrcat(), except that at most n
            characters from wsrcstr are appended to wdststr. Note that the
            null-terminator in wsrcstr will stop appending. wdststr will be
            null-terminated..
        RETURNS
            Number of characters in the result string not including the ending
            null-terminator.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wdststr(IN/OUT)
            Pointer to the destination wchar string for appending.
        wsrcstr(IN)
            Pointer to the source wchar string to append.
        n(IN)
            Number of characters from wsrcstr to append.
    */
    extern (C) size_t OCIWideCharStrncat (dvoid* envhp, OCIWchar* wdststr, OCIWchar* wsrcstr, size_t n);

    /*
        NAME
            OCIWideCharStrncpy - Copy wchar string in length
        REMARKS
            This function is similar to OCIWideCharStrcpy(), except that at most n
            characters are copied from the array pointed to by wsrcstr to the array
            pointed to by wdststr. Note that the null-terminator in wdststr will
            stop coping and result string will be null-terminated.
        RETURNS
            number of characters copied not including the ending null-terminator.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wdststr(OUT)
            Pointer to the destination wchar buffer.
        wsrcstr(IN)
            Pointer to the source wchar string.
        n(IN)
            Number of characters from wsrcstr to copy.
    */
    extern (C) size_t OCIWideCharStrncpy (dvoid* envhp, OCIWchar* wdststr, OCIWchar* wsrcstr, size_t n);

    /*
        NAME
            OCIWideCharStrrchr - search the last occurrence of a wchar in wchar string
        REMARKS
            This function searchs for the last occurrence of wc in the wchar string
            pointed to by wstr. It returns a pointer to the whcar if successful, or
            a null pointer.
        RETURNS
            wchar pointer if successful, otherwise a null pointer.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wstr(IN)
            Pointer to the wchar string to search
        wc(IN)
            Wchar to search for.
    */
    extern (C) OCIWchar* OCIWideCharStrrchr (dvoid* envhp, OCIWchar* wstr, OCIWchar wc);

    /*
        NAME
            OCIWideCharStrCaseConversion - convert a wchar string into lowercase or
                            uppercase
        REMARKS
            This function convert the wide char string pointed to by wsrcstr into the
            uppercase or lowercase specified by flag and copies the result into the
            array pointed to by wdststr. The result string will be null-terminated.
        RETURNS
            number of characters for result string not including null-terminator.
        envhp(IN/OUT)
            OCI environment handle.
        wdststr(OUT)
            Pointer to destination array.
        wsrcstr(IN)
            Pointer to source string.
        flag(IN)
            Specify the case to convert:
                OCI_NLS_UPPERCASE : convert to uppercase.
                OCI_NLS_LOWERCASE: convert to lowercase.
            This flag can be ORed with OCI_NLS_LINGUISTIC to specify that the
            linguistic setting in the locale will be used for case conversion.
    */
    extern (C) size_t OCIWideCharStrCaseConversion (dvoid* envhp, OCIWchar* wdststr, OCIWchar* wsrcstr, ub4 flag);

    /*
        NAME
            OCIWideCharDisplayLength - Calculate the display length for a wchar
        REMARKS
            This function determines the number of column positions required for wc
            in display. It returns number of column positions, or 0 if wc is
            null-terminator.
        RETURNS
            Number of display positions.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar character.
    */
    extern (C) size_t OCIWideCharDisplayLength (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIWideCharMultiByteLength - Determine byte size in multi-byte encoding
        REMARKS
            This function determines the number of byte required for wc in multi-byte
            encoding. It returns number of bytes in multi-byte for wc.
        RETURNS
            Number of bytes.
        envhp(IN/OUT)
            OCI environment handle to determine the character set .
        wc(IN)
            Wchar character.
    */
    extern (C) size_t OCIWideCharMultiByteLength (dvoid* envhp, OCIWchar wc);

    /*
        NAME
            OCIMultiByteStrcmp - Compare two multi-byte strings
        REMARKS
            It compares two multi-byte strings in binary ( based on encoding value ),
            linguistic, or case-insensitive.
        RETURNS
            0, if str1 == str2.
            Positive, if str1 > str2.
            Negative, if str1 < str2.
        envhp(IN/OUT)
            OCI environment handle to determine the character set.
        str1(IN)
            Pointer to a null-terminated string.
        str2(IN)
            Pointer to a null-terminated string.
        flag(IN)
            It is used to decide the comparison method. It can be taken one of the
            following values:
                OCI_NLS_BINARY: for the binary comparison, this is default value.
                OCI_NLS_LINGUISTIC: for linguistic comparison specified in the locale.
            This flag can be ORed with OCI_NLS_CASE_INSENSITIVE for case-insensitive
            comparison.
    */
    extern (C) int OCIMultiByteStrcmp (dvoid* envhp, OraText* str1, OraText* str2, int flag);

    /*
        NAME
            OCIMultiByteStrncmp - compare two strings in length
        REMARKS
            This function is similar to OCIMultiBytestrcmp(), except that at most
            len1 bytes from str1 and len2 bytes from str2 are compared. The
            null-terminator will be taken into the comparison.
        RETURNS
            0, if str1 = str2
            Positive, if str1 > str2
            Negative, if str1 < str2
        envhp(IN/OUT)
            OCI environment handle to determine the character set.
        str1(IN)
            Pointer to the first string
        len1(IN)
            The length for the first string for comparison
        str2(IN)
            Pointer to the second string
        len2(IN)
            The length for the second string for comparison.
        flag(IN)
            It is used to decide the comparison method. It can be taken one of the
            following values:
                OCI_NLS_BINARY: for the binary comparison, this is default value.
                OCI_NLS_LINGUISTIC: for linguistic comparison specified in the locale.
            This flag can be ORed with OCI_NLS_CASE_INSENSITIVE for case-insensitive
            comparison.
    */
    extern (C) int OCIMultiByteStrncmp (dvoid* envhp, OraText* str1, size_t len1, OraText* str2, size_t len2, int flag);

    /*
        NAME
            OCIMultiByteStrcat - concatenate multibyte strings
        REMARKS
            This function appends a copy of the multi-byte string pointed to by
            srcstr, including the null-terminator to the end of string pointed to by
            dststr. It returns the number of bytes in the result string not including
            the ending null-terminator.
        RETURNS
            number of bytes in the result string not including the ending
            null-terminator.
        envhp(IN/OUT)
            Pointer to OCI environment handle
        dststr(IN/OUT)
            Pointer to the destination multi-byte string for appending.
        srcstr(IN)
            Pointer to the source string to append.
    */
    extern (C) size_t OCIMultiByteStrcat (dvoid* envhp, OraText* dststr, OraText* srcstr);

    /*
        NAME
            OCIMultiByteStrcpy - copy multibyte string
        REMARKS
            This function copies the multi-byte string pointed to by srcstr,
            including the null-terminator, into the array pointed to by dststr. It
            returns the number of bytes copied not including the ending
            null-terminator.
        RETURNS
            number of bytes copied not including the ending null-terminator.
        envhp(IN/OUT)
            Pointer to the OCI environment handle.
        srcstr(OUT)
            Pointer to the destination buffer.
        dststr(IN)
            Pointer to the source multi-byte string.
    */
    extern (C) size_t OCIMultiByteStrcpy (dvoid* envhp, OraText* dststr, OraText* srcstr);

    /*
        NAME
            OCIMultiByteStrlen - Calculate multibyte string length
        REMARKS
            This function computes the number of bytes in the multi-byte string
            pointed to by str, not including the null-terminator, and returns this
            number.
        RETURNS
            number of bytes not including ending null-terminator.
        str(IN)
            Pointer to the source multi-byte string.
    */
    extern (C) size_t OCIMultiByteStrlen (dvoid* envhp, OraText* str);

    /*
        NAME
            OCIMultiByteStrncat - concatenate string in length
        REMARKS
            This function is similar to OCIMultiBytestrcat(), except that at most n
            bytes from srcstr are appended to dststr. Note that the null-terminator in
            srcstr will stop appending and the function will append as many character
            as possible within n bytes. dststr will be null-terminated.
        RETURNS
            Number of bytes in the result string not including the ending
            null-terminator.
        envhp(IN/OUT)
            Pointer to OCI environment handle.
        srcstr(IN/OUT)
            Pointer to the destination multi-byte string for appending.
        dststr(IN)
            Pointer to the source multi-byte string to append.
        n(IN)
            Number of bytes from srcstr to append.
    */
    extern (C) size_t OCIMultiByteStrncat (dvoid* envhp, OraText* dststr, OraText* srcstr, size_t n);

    /*
        NAME
            OCIMultiByteStrncpy - copy multibyte string in length
        REMARKS
            This function is similar to OCIMultiBytestrcpy(), except that at most n
            bytes are copied from the array pointed to by srcstr to the array pointed
            to by dststr. Note that the null-terminator in srcstr will stop coping and
            the function will copy as many character as possible within n bytes. The
            result string will be null-terminated.
        RETURNS
            number of bytes copied not including the ending null-terminator.
        envhp(IN/OUT)
            Pointer to a OCI environment handle.
        dststr(IN)
            Pointer to the source multi-byte string.
        srcstr(OUT)
            Pointer to the destination buffer.
        n(IN)
            Number of bytes from srcstr to copy.
    */
    extern (C) size_t OCIMultiByteStrncpy (dvoid* envhp, OraText* dststr, OraText* srcstr, size_t n);

    /*
        NAME
            OCIMultiByteStrnDisplayLength - calculate the display length for a
                            multibyt string
        REMARKS
            This function returns the number of display positions occupied by the
            complete characters within the range of n bytes.
        RETURNS
            number of display positions.
        envhp(IN/OUT)
            OCI environment handle.
        str(IN)
            Pointer to a multi-byte string.
        n(IN)
            Number of bytes to examine.
    */
    extern (C) size_t OCIMultiByteStrnDisplayLength(dvoid* envhp, OraText* str1, size_t n);

    /*
        NAME
            OCIMultiByteStrCaseConversion
        REMARKS
            This function convert the multi-byte string pointed to by srcstr into the
            uppercase or lowercase specified by flag and copies the result into the
            array pointed to by dststr. The result string will be null-terminated.
        RETURNS
            number of bytes for result string not including null-terminator.
        envhp(IN/OUT)
            OCI environment handle.
        dststr(OUT)
            Pointer to destination array.
        srcstr(IN)
            Pointer to source string.
        flag(IN)
            Specify the case to convert:
                OCI_NLS_UPPERCASE: convert to uppercase.
                OCI_NLS_LOWERCASE: convert to lowercase.
            This flag can be ORed with OCI_NLS_LINGUISTIC to specify that the
            linguistic setting in the locale will be used for case conversion.
    */
    extern (C) size_t OCIMultiByteStrCaseConversion (dvoid* envhp, OraText* dststr, OraText* srcstr, ub4 flag);

    /*
        NAME
            OCICharSetToUnicode - convert multibyte string into Unicode as UCS2
        REMARKS
            This function converts a multi-byte string pointed to by src to Unicode
            into the array pointed to by dst. The conversion will stop when it reach
            to the source limitation or destination limitation.
            The function will return number of characters converted into Unicode.
            If dstlen is zero, it will just return the number of characters for the
            result without real conversion.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            Pointer to an OCI environment handle
        dst(OUT)
            Pointer to a destination buffer
        dstlen(IN)
            Size of destination buffer in character
        src(IN)
            Pointer to multi-byte source string.
        srclen(IN)
            Size of source string in bytes.
        rsize(OUT)
            Number of characters converted.
            If it is a NULL pointer, nothing to return.
    */
    extern (C) sword OCICharSetToUnicode (dvoid* envhp, ub2* dst, size_t dstlen, OraText* src, size_t    srclen, size_t* rsize);

    /*
        NAME
            OCIUnicodeToCharSet - convert Unicode into multibyte
        REMARKS
            This function converts a Unicode string pointed to by src to multi-byte
            into the array pointed to by dst. The conversion will stop when it reach
            to the source limitation or destination limitation. The function will
            return number of bytes converted into multi-byte. If dstlen is zero, it
            will just return the number of bytes for the result without real
            conversion. If a Unicode character is not convertible for the character
            set specified in OCI environment handle, a replacement character will be
            used for it. In this case, OCICharSetConversionIsReplacementUsed() will
            return ture.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            Pointer to an OCI environment handle.
        dst(OUT)
            Pointer to a destination buffer.
        dstlen(IN)
            Size of destination buffer in byte.
        src(IN)
            Pointer to a Unicode string.
        srclen(IN)
            Size of source string in characters.
        rsize(OUT)
            Number of bytes converted.
            If it is a NULL pointer, nothing to return.
    */
    extern (C) sword OCIUnicodeToCharSet (dvoid* envhp, OraText* dst, size_t dstlen,    ub2* src, size_t srclen, size_t* rsize);

    /*
        NAME
            OCINlsCharSetConvert - convert between any two character set.
        REMARKS
            This function converts a string pointed to by src in the character set
            specified with srcid to the array pointed to by dst in the character set
            specified with dstid. The conversion will stop when it reaches the source
            limitation or destination limitation. The function will return the number
            of bytes converted into the destination buffer. Even though either source
            or destination character set id is OCI_UTF16ID, given and return data
            length will be represented with the byte length as this function is
            intended for generic purpose. Note the conversion will not stop at null
            data.
            To get character set id from name, OCINlsCharSetNameToId can be used.
            To check if derived data in the destination buffer contains any
            replacement character resulting from conversion failure,
            OCICharSetConversionIsReplacementUsed can be used to get the status.
            Data alignment should be guaranteed by a caller. For example, UTF-16 data
            should be aligned to ub2 type.

        RETURNS
            OCI_SUCCESS or OCI_ERROR.
        errhp(IN/OUT)
            OCI error handle. If there is an error, it is recorded in errhp and this
            function returns a NULL pointer. Diagnostic information can be obtained
            by calling OCIErrorGet().
        dstid(IN)
            Character set id for the destination buffer.
        dstp(OUT)
            Pointer to the destination buffer.
        dstlen(IN)
            The maximum byte size of destination buffer.
        srcid(IN)
            Character set id for the source buffer.
        srcp(IN)
            Pointer to the source buffer.
        srclen(IN)
            The length byte size of source buffer.
        rsize(OUT)
            The number of characters converted. If it is a NULL pointer, nothing to
            return.
    */
    extern (C) sword OCINlsCharSetConvert (dvoid* envhp, OCIError* errhp, ub2 dstid, dvoid* dstp, size_t dstlen, ub2 srcid, dvoid* srcp, size_t srclen, size_t* rsize);

    /*
        NAME
            OCICharsetConversionIsReplacementUsed - chech if replacement is used in
                                conversion
        REMARKS
            This function indicates whether or not the replacement character was used
            for nonconvertible characters in character set conversion in last invoke
            of OCICharsetUcs2ToMb().
        RETURNS
            TRUE is the replacement character was used in last OCICharsetUcs2ToMb()
            invoking, else FALSE.
        envhp(IN/OUT)
            OCI environment handle. This should be the first handle passed to
            OCICharsetUcs2ToMb().
    */
    extern (C) boolean OCICharSetConversionIsReplacementUsed (dvoid* envhp);

    /*
        NAME
            OCINlsEnvironmentVariableGet - get a value of NLS environment variable.

        DESCRIPTION
            This function retrieves a value of NLS environment variable to the buffer
            pointed to by val. Data type is determined by the parameter specified by
            item. Either numeric data or string data can be retrieved.

        RETURNS
            OCI_SUCCESS or OCI_ERROR.

        PARAMETERS
        valp(OUT) -
            Pointer to the buffer.
        size(IN) -
            Size of the buffer. This argument is only applicable to string data type,
            but not to numerical data, in such case, it is ignored.
        item(IN) -
            NLS item value, which can be one of following values:
                OCI_NLS_CHARSET_ID    - NLS_LANG character set id in ub2 data type.
                OCI_NLS_NCHARSET_ID - NLS_NCHAR character set id in ub2 data type.
        charset(IN) -
            Character set id for retrieved string data. If it is 0, NLS_LANG will be
            used. OCI_UTF16ID is a valid id. In case of numeric data, this argument
            is ignored.
        rsize(OUT) -
            Size of return value.

        NOTE
            This functions is mainly used for retrieving character set id from either
            NLS_LANG or NLS_NCHAR environment variables. If NLS_LANG is not set,
            the default character set id is returned.
            For future extension, the buffer is capable for storing other data types.
    */
    extern (C) sword OCINlsEnvironmentVariableGet (dvoid* valp, size_t size, ub2 item, ub2 charset, size_t* rsize);

    /*
        NAME
            OCIMessageOpen - open a locale message file
        REMARKS
            This function opens a message handle for facility of product in a language
            pointed to by envhp. It first try to open the message file corresponding
            to envhp for the facility. If it successes, it will use that file to
            initialize a message handle, else it will use the default message file
            which is for American language for the facility. The function return a
            pointer pointed to a message handle into msghp parameter.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            A pointer to OCI environment handle for message language.
        errhp(IN/OUT)
            The OCI error handle. If there is an error, it is record in errhp and this
            function returns a NULL pointer. Diagnostic information can be obtained by
            calling OCIErrorGet().
        msghp(OUT)
            a message handle for return
        product(IN)
            A pointer to a product name. Product name is used to locate the directory
            for message in a system dependent way. For example, in Solaris, the
            directory of message files for the product `rdbms' is
            `${ORACLE_HOME}/rdbms'.
        facility(IN)
            A pointer to a facility name in the product. It is used to enumruct a
            message file name. A message file name follows the conversion with
            facility as prefix. For example, the message file name for facility
            `img' in American language will be `imgus.msb' where `us' is the
            abbreviation of American language and `msb' as message binary file
            extension.
        dur(IN)
            Duration for memory allocation for the return message handle. It can be
            the following values:
        OCI_DURATION_CALL
        OCI_DURATION_STATEMENT
        OCI_DURATION_SESSION
        OCI_DURATION_TRANSACTION
            For the detail description, please refer to Memory Related Service
            Interfaces section.
    */
    extern (C) sword OCIMessageOpen (dvoid* envhp, OCIError* errhp, OCIMsg** msghp, OraText* product, OraText* facility, OCIDuration dur);

    /*
        NAME
            OCIMessageGet - get a locale message from a message handle
        REMARKS
            This function will get message with message number identified by msgno and
            if buflen is not zero, the function will copy the message into the buffer
            pointed to by msgbuf. If buflen is zero, the message will be copied into
            a message buffer inside the message handle pointed to by msgh. For both
            cases. it will return the pointer to the null-terminated message string.
            If it cannot get the message required, it will return a NULL pointer.
        RETURNS
            A pointer to a null-terminated message string on success, otherwise a NULL
            pointer.
        msgh(IN/OUT)
            Pointer to a message handle which was previously opened by
            OCIMessageOpen().
        msgno(IN)
            The message number for getting message.
        msgbuf(OUT)
            Pointer to a destination buffer to the message retrieved. If buflen is
            zero, it can be NULL pointer.
        buflen(IN)
            The size of the above destination buffer.
    */
    extern (C) OraText* OCIMessageGet (OCIMsg* msgh, ub4 msgno, OraText* msgbuf, size_t buflen);

    /*
        NAME
            OCIMessageClose - close a message handle
        REMARKS
            This function closes a message handle pointed to by msgh and frees any
            memory associated with this handle.
        RETURNS
            OCI_SUCCESS, OCI_INVALID_HANDLE or OCI_ERROR
        envhp(IN/OUT)
            A pointer to OCI environment handle for message language.
        errhp(IN/OUT)
            The OCI error handle. If there is an error, it is record in errhp and this
            function returns a NULL pointer. Diagnostic information can be obtained by
            calling OCIErrorGet().
        msghp(IN/OUT)
            A pointer to a message handle which was previously opened by
            OCIMessageOpen().
    */
    extern (C) sword OCIMessageClose (dvoid* envhp, OCIError* errhp, OCIMsg* msghp);

    /*****************************************************************************
                            DESCRIPTION
    ******************************************************************************
    1 Threads Interface

    The OCIThread package provides a number of commonly used threading
    primitives for use by Oracle customers.    It offers a portable interface to
    threading capabilities native to various platforms.    It does not implement
    threading on platforms which do not have native threading capability.

    OCIThread does not provide a portable implementation of multithreaded
    facilities.    It only serves as a set of portable covers for native
    multithreaded facilities.    Therefore, platforms that do not have native
    support for multi-threading will only be able to support a limited
    implementation of OCIThread.    As a result, products that rely on all of
    OCIThread's functionality will not port to all platforms.    Products that must
    port to all platforms must use only a subset of OCIThread's functionality.
    This issue is discussed further in later sections of this document.

    The OCIThread API is split into four main parts.    Each part is described
    briefly here.    The following subsections describe each in greater detail.

    1. Initialization and Termination Calls

            These calls deal with the initialization and termination of OCIThread.
            Initialization of OCIThread initializes the OCIThread context which is
            a member of the OCI environment or session handle.    This context is
            required for other OCIThread calls.

    2. Passive Threading Primitives

            The passive threading primitives include primitives to manipulate mutual
            exclusion (mutex) locks, thread ID's, and thread-specific data keys.

            The reason that these primitives are described as 'passive' is that while
            their specifications allow for the existence of multiple threads, they do
            not require it.    This means that it is possible for these primitives to
            be implemented according to specification in both single-threaded and
            multi-threaded environments.

            As a result, OCIThread clients that use only these primitives will not
            require the existence of multiple threads in order to work correctly,
            i.e., they will be able to work in single-threaded environments without
            branching code.

    3. Active Threading Primitives

            Active threading primitives include primitives dealing with the creation,
            termination, and other manipulation of threads.

            The reason that these primitives are described as 'active' is that they
            can only be used in true multi-threaded environments.    Their
            specifications explicitly require that it be possible to have multiple
            threads.    If you need to determine at runtime whether or not you are in a
            multi-threaded environment, call OCIThreadIsMulti() before calling an
            OCIThread active primitive.


    1.1 Initialization & Termination
    ==================================

    The types and functions described in this section are associated with the
    initialization and termination of the OCIThread package.    OCIThread must
    be properly initialized before any of its functionality can be used.
    OCIThread's process initialization function, 'OCIThreadProcessInit()',
    must be called with care; see below.

    The observed behavior of the initialization and termination functions is the
    same regardless of whether OCIThread is in single-threaded or multi-threaded
    environment.    It is OK to call the initialization functions from both generic
    and operating system specific (OSD) code.

    1.1.1 Types

        OCIThreadContext - OCIThread Context
        -------------------------------------

            Most calls to OCIThread functions take the OCI environment or session
            handle as a parameter.    The OCIThread context is part of the OCI
            environment or session handle and it must be initialized by calling
            'OCIThreadInit()'.    Termination of the OCIThread context occurs by calling
            'OCIThreadTerm()'.

            The OCIThread context is a private data structure.    Clients must NEVER
            attempt to examine the contents of the context.

    1.1.2    OCIThreadProcessInit

        OCIThreadProcessInit - OCIThread Process INITialization
        --------------------------------------------------------

            Description

                This function should be called to perform OCIThread process
                initialization.

            Prototype

                void OCIThreadProcessInit();

            Returns

                Nothing.

            Notes

                Whether or not this function needs to be called depends on how OCI
                Thread is going to be used.

        * In a single-threaded application, calling this function is optional.
            If it is called at all, the first call to it must occur before calls
            to any other OCIThread functions.    Subsequent calls can be made
            without restriction; they will not have any effect.

        * In a multi-threaded application, this function MUST be called.    The
            first call to it MUST occur 'strictly before' any other OCIThread
            calls; i.e., no other calls to OCIThread functions (including other
            calls to this one) can be concurrent with the first call.
            Subsequent calls to this function can be made without restriction;
            they will not have any effect.


    1.1.3 OCIThreadInit

        OCIThreadInit - OCIThread INITialize
        -------------------------------------

            Description

                This initializes OCIThread context.

            Prototype

                sword OCIThreadInit(dvoid* hndl, OCIError* err);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is illegal for OCIThread clients to try an examine the memory
                pointed to by the returned pointer.

                It is safe to make concurrent calls to 'OCIThreadInit()'.    Unlike
                'OCIThreadProcessInit()',    there is no need to have a first call
                that occurs before all the others.

                The first time 'OCIThreadInit()' is called, it initilaizes the OCI
                Thread context.    It also saves a pointer to the context in some system
                dependent manner.    Subsequent calls to 'OCIThreadInit()' will return
                the same context.

                Each call to 'OCIThreadInit()' must eventually be matched by a call to
                'OCIThreadTerm()'.

        OCIThreadTerm - OCIThread TERMinate
        ------------------------------------

            Description

                This should be called to release the OCIThread context.    It should be
                called exactly once for each call made to 'OCIThreadInit()'.

            Prototype

                sword OCIThreadTerm(dvoid* hndl, OCIError* err);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is safe to make concurrent calls to 'OCIThreadTerm()'.

                'OCIThreadTerm()' will not do anything until it has been called as
                many times as 'OCIThreadInit()' has been called.    When that happens,
                it terminates the OCIThread layer and frees the memory allocated for
                the context.    Once this happens, the context should not be re-used.
                It will be necessary to obtain a new one by calling 'OCIThreadInit()'.


        OCIThreadIsMulti - OCIThread Is Multi-Threaded?
        ------------------------------------------------

            Description

                This tells the caller whether the application is running in a
                multi-threaded environment or a single-threaded environment.

            Prototype
                boolean OCIThreadIsMulti(void);

            Returns

                TRUE if the environment is multi-threaded;
                FALSE if the environment is single-threaded.


    1.2 Passive Threading Primitives
    ==================================

    1.2.1 Types

    The passive threading primitives deal with the manipulation of mutex,
    thread ID's, and thread-specific data.    Since the specifications of these
    primitives do not require the existence of multiple threads, they can be
    used both on multithreaded and single-threaded platforms.

    1.2.1.1    OCIThreadMutex - OCIThread Mutual Exclusion Lock
    -----------------------------------------------------------

        The type 'OCIThreadMutex' is used to represent a mutual exclusion lock
        (mutex).    A mutex is typically used for one of two purposes: (i) to
        ensure that only one thread accesses a given set of data at a time, or
        (ii) to ensure that only one thread executes a given critical section of
        code at a time.

        Mutexes pointer can be declared as parts of client structures or as
        stand-alone variables.    Before they can be used, they must be initialized
        using 'OCIThreadMutexInit()'.    Once they are no longer needed, they must be
        destroyed using 'OCIThreadMutexDestroy()'.    A mutex pointer must NOT be
        used after it is destroyed.

        A thread can acquire a mutex by using either 'OCIThreadMutexAcquire()' or
        'OCIThreadMutexTry()'.    They both ensure that only one thread at a time is
        allowed to hold a given mutex.    A thread that holds a mutex can release it
        by calling 'OCIThreadMutexRelease()'.


    1.2.1.2    OCIThreadKey - OCIThread Key for Thread-Specific Data
    ----------------------------------------------------------------

        A key can be thought of as a process-wide variable that has a
        thread-specific value.    What this means is that all the threads in a
        process can use any given key.    However, each thread can examine or modify
        that key independently of the other threads.    The value that a thread sees
        when it examines the key will always be the same as the value that it last
        set for the key.    It will not see any values set for the key by the other
        threads.

        The type of the value held by a key is a 'dvoid* ' generic pointer.

        Keys can be created using 'OCIThreadKeyInit()'.    When a key is created, its
        value is initialized to 'NULL' for all threads.

        A thread can set a key's value using 'OCIThreadKeySet()'.    A thread can
        get a key's value using 'OCIThreadKeyGet()'.

        The OCIThread key functions will save and retrieve data SPECIFIC TO THE
        THREAD.    When clients maintain a pool of threads and assign the threads to
        different tasks, it *may not* be appropriate for a task to use OCIThread
        key functions to save data associated with it.    Here is a scenario of how
        things can fail: A thread is assigned to execute the initialization of a
        task.    During the initialization, the task stored some data related to it
        in the thread using OCIThread key functions.    After the initialization,
        the thread is returned back to the threads pool.    Later, the threads pool
        manager assigned another thread to perform some operations on the task,
        and the task needs to retrieve those data it stored earlier in
        initialization.    Since the task is running in another thread, it will not
        be able to retrieve the same data back!    Applications that use thread
        pools should be aware of this and be cautious when using OCIThread key
        functions.


    1.2.1.3    OCIThreadKeyDestFunc - OCIThread Key Destructor Function Type
    ------------------------------------------------------------------------

        This is the type of a pointer to a key's destructor routine.    Keys can be
        associated with a destructor routine when they are created (see
        'OCIThreadKeyInit()').

        A key's destructor routine will be called whenever a thread that has a
        non-NULL value for the key terminates.

        The destructor routine returns nothing and takes one parameter.    The
        parameter will be the value that was set for key when the thread
        terminated.

        The destructor routine is guaranteed to be called on a thread's value
        in the key after the termination of the thread and before process
        termination.    No more precise guarantee can be made about the timing
        of the destructor routine call; thus no code in the process may assume
        any post-condition of the destructor routine.    In particular, the
        destructor is not guaranteed to execute before a join call on the
        terminated thread returns.


    1.2.1.4    OCIThreadId - OCIThread Thread ID
    --------------------------------------------

        Type 'OCIThreadId' is the type that will be used to identify a thread.
        At any given time, no two threads will ever have the same 'OCIThreadId'.
        However, 'OCIThreadId' values can be recycled; i.e., once a thread dies,
        a new thread may be created that has the same 'OCIThreadId' as the one
        that died.    In particular, the thread ID must uniquely identify a thread
        T within a process, and it must be consistent and valid in all threads U
        of the process for which it can be guaranteed that T is running
        concurrently with U.    The thread ID for a thread T must be retrievable
        within thread T.    This will be done via OCIThreadIdGet().

        The 'OCIThreadId' type supports the concept of a NULL thread ID: the NULL
        thread ID will never be the same as the ID of an actual thread.



    1.2.2 Function prototypes for passive primitives
    --------------------------------------------------

    1.2.2.1 Mutex functions
    -------------------------

        OCIThreadMutexInit - OCIThread MuteX Initialize
        -----------------------------------------------

            Description

                This allocate and initializes a mutex.    All mutexes must be
                initialized prior to use.

            Prototype

                sword OCIThreadMutexInit(dvoid* hndl, OCIError* err,
                            OCIThreadMutex** mutex);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        mutex(OUT):    The mutex to initialize.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                Multiple threads must not initialize the same mutex simultaneously.
                Also, a mutex must not be reinitialized until it has been destroyed (see
                'OCIThreadMutexDestroy()').

        OCIThreadMutexDestroy - OCIThread MuteX Destroy
        -----------------------------------------------

            Description

                This destroys and deallocate a mutex.    Each mutex must be destroyed
                once it is no longer needed.

            Prototype

                sword OCIThreadMutexDestroy(dvoid* hndl, OCIError* err,
                        OCIThreadMutex** mutex);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        mutex(IN/OUT):        The mutex to destroy.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is not legal to destroy a mutex that is uninitialized or is currently
                held by a thread.    The destruction of a mutex must not occur concurrently
                with any other operations on the mutex.    A mutex must not be used after
                it has been destroyed.


        OCIThreadMutexAcquire - OCIThread MuteX Acquire
        -----------------------------------------------

            Description

                This acquires a mutex for the thread in which it is called.    If the mutex
                is held by another thread, the calling thread is blocked until it can
                acquire the mutex.

            Prototype

            sword OCIThreadMutexAcquire(dvoid *hndl, OCIError *err,
                    OCIThreadMutex *mutex);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error, it is
                    recorded in err and this function returns OCI_ERROR.
                    Diagnostic information can be obtained by calling
                    OCIErrorGet().

        mutex(IN/OUT):        The mutex to acquire.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is illegal to attempt to acquire an uninitialized mutex.

                This function's behavior is undefined if it is used by a thread to
                acquire a mutex that is already held by that thread.



        OCIThreadMutexRelease - OCIThread MuteX Release
        -----------------------------------------------

            Description

                This releases a mutex.    If there are any threads blocked on the mutex,
                one of them will acquire it and become unblocked.

            Prototype

                sword OCIThreadMutexRelease(dvoid *hndl, OCIError *err,
                        OCIThreadMutex *mutex);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        mutex(IN/OUT):        The mutex to release.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is illegal to attempt to release an uninitialized mutex.    It is also
                illegal for a thread to release a mutex that it does not hold.


        OCIThreadKeyInit - OCIThread KeY Initialize
        -------------------------------------------

            Description

                This creates a key.    Each call to this routine allocate and generates
                a new key that is distinct from all other keys.

            Prototype

                sword OCIThreadKeyInit(dvoid *hndl, OCIError *err, OCIThreadKey** key,
                        OCIThreadKeyDestFunc destFn);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        key(OUT):        The 'OCIThreadKey' in which to create the new key.

        destFn(IN):    The destructor for the key.    NULL is permitted.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                Once this function executes successfully, a pointer to an allocated and
                initialized key is return.    That key can be used with 'OCIThreadKeyGet()'
                and 'OCIThreadKeySet()'.    The initial value of the key will be 'NULL' for
                all threads.

                It is illegal for this function to be called more than once to create the
                same key (i.e., to be called more than once with the same value for the
                'key' parameter).

                If the 'destFn' parameter is not NULL, the routine pointed to by 'destFn'
                will be called whenever a thread that has a non-NULL value for the key
                terminates.    The routine will be called with one parameter.    The
                parameter will be the key's value for the thread at the time at which the
                thread terminated.
                If the key does not need a destructor function, pass NULL for 'destFn'.


        OCIThreadKeyDestroy - OCIThread KeY DESTROY
        -------------------------------------------

        Description

            Destroy and deallocate the key pointed to by 'key'.

            Prototype

                sword OCIThreadKeyDestroy(dvoid *hndl, OCIError *err,
                    OCIThreadKey** key);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        key(IN/OUT):    The 'OCIThreadKey' in which to destroy the key.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                This is different from the destructor function callback passed to the
                key create routine.    This new destroy function 'OCIThreadKeyDestroy' is
                used to terminate any resources OCI THREAD acquired when it created
                'key'.    [The 'OCIThreadKeyDestFunc' callback type is a key VALUE
                destructor; it does in no way operate on the key itself.]

                This must be called once the user has finished using the key.    Not
                calling the key destroy function may result in memory leaks.




    1.2.2.2 Thread Key operations
    -------------------------------

        OCIThreadKeyGet - OCIThread KeY Get value
        -----------------------------------------

            Description

                This gets the calling thread's current value for a key.

            Prototype

                sword OCIThreadKeyGet(dvoid *hndl, OCIError *err, OCIThreadKey *key,
                        dvoid** pValue);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        key(IN):                    The key.

        pValue(IN/OUT):        The location in which to place the thread-specific
                    key value.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is illegal to use this function on a key that has not been created
                using 'OCIThreadKeyInit()'.

                If the calling thread has not yet assigned a value to the key, 'NULL' is
                placed in the location pointed to by 'pValue'.


        OCIThreadKeySet - OCIThread KeY Set value
        -----------------------------------------

            Description

                This sets the calling thread's value for a key.

            Prototype

                sword OCIThreadKeySet(dvoid *hndl, OCIError *err, OCIThreadKey *key,
                        dvoid *value);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        key(IN/OUT): The key.

        value(IN):        The thread-specific value to set in the key.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                It is illegal to use this function on a key that has not been created
                using 'OCIThreadKeyInit()'.

    1.2.2.3    Thread Id
    --------------------

        OCIThreadIdInit - OCIThread Thread Id INITialize
        --------------------------------------------------

            Description

                Allocate and initialize the thread id 'tid'.

            Prototype

                sword OCIThreadIdInit(dvoid *hndl, OCIError *err, OCIThreadId** tid);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tid (OUT):        Pointer to the thread ID to initialize.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.


        OCIThreadIdDestroy - OCIThread Thread Id DESTROY
        --------------------------------------------------

            Description

                Destroy and deallocate the thread id 'tid'.

            Prototype

                sword OCIThreadIdDestroy(dvoid *hndl, OCIError *err, OCIThreadId** tid);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tid(IN/OUT):                Pointer to the thread ID to destroy.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Note

                'tid' should be initialized by OCIThreadIdInit().


        OCIThreadIdSet - OCIThread Thread Id Set
        -----------------------------------------

            Description

                This sets one 'OCIThreadId' to another.

            Prototype

                sword OCIThreadIdSet(dvoid *hndl, OCIError *err,
                    OCIThreadId *tidDest,
                    OCIThreadId *tidSrc);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tidDest(OUT):        This should point to the location of the 'OCIThreadId'
                to be set to.

        tidSrc(IN):            This should point to the 'OCIThreadId' to set from.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'tid' should be initialized by OCIThreadIdInit().


        OCIThreadIdSetNull - OCIThread Thread Id Set Null
        ---------------------------------------------------------

            Description

                This sets the NULL thread ID to a given 'OCIThreadId'.

            Prototype

                sword OCIThreadIdSetNull(dvoid *hndl, OCIError *err,
                            OCIThreadId *tid);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error, it is
                    recorded in err and this function returns OCI_ERROR.
                    Diagnostic information can be obtained by calling
                    OCIErrorGet().

        tid(OUT):        This should point to the 'OCIThreadId' in which to put
                    the NULL thread ID.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'tid' should be initialized by OCIThreadIdInit().


        OCIThreadIdGet - OCIThread Thread Id Get
        ------------------------------------------

            Description

                This retrieves the 'OCIThreadId' of the thread in which it is called.

            Prototype

                sword OCIThreadIdGet(dvoid *hndl, OCIError *err,
                    OCIThreadId *tid);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tid(OUT):        This should point to the location in which to place the
                    ID of the calling thread.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'tid' should be initialized by OCIThreadIdInit().

                When OCIThread is used in a single-threaded environment,
                OCIThreadIdGet() will always place the same value in the location
                pointed to by 'tid'.    The exact value itself is not important.    The
                important thing is that it is not the same as the NULL thread ID and
                that it is always the same value.


        OCIThreadIdSame - OCIThread Thread Ids Same?
        ----------------------------------------------

            Description

                This determines whether or not two 'OCIThreadId's represent the same
                thread.

            Prototype

                sword OCIThreadIdSame(dvoid *hndl, OCIError *err,
                        OCIThreadId *tid1, OCIThreadId *tid2,
                        boolean *result);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tid1(IN):        Pointer to the first 'OCIThreadId'.

        tid2(IN):        Pointer to the second 'OCIThreadId'.

        result(IN/OUT): Pointer to the result.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                If 'tid1' and 'tid2' represent the same thread, 'result' is set to TRUE.
                Otherwise, 'result' is set to FALSE.

                'result' is set to TRUE if both 'tid1' and 'tid2' are the NULL thread ID.

                'ti1d' and 'tid2' should be initialized by OCIThreadIdInit().


        OCIThreadIdNull - OCIThread Thread Id NULL?
        ---------------------------------------------

            Description

                This determines whether or not a given 'OCIThreadId' is the NULL thread
                ID.

            Prototype

                sword OCIThreadIdNull(dvoid *hndl, OCIError *err,
                        OCIThreadId *tid,
                        boolean *result);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tid(IN):        Pointer to the 'OCIThreadId' to check.

        result(IN/OUT): Pointer to the result.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                If 'tid' is the NULL thread ID, 'result' is set to TRUE.    Otherwise,
                'result' is set to FALSE.

                'tid' should be initialized by OCIThreadIdInit().


    1.3 Active Threading Primitives
    =================================

    The active threading primitives deal with the manipulation of actual
    threads.    Because the specifications of most of these primitives require
    that it be possible to have multiple threads, they work correctly only in
    the enabled OCIThread; In the disabled OCIThread, they always return
    failure.    The exception is OCIThreadHandleGet(); it may be called in a
    single-threaded environment, in which case it will have no effect.

    Active primitives should only be called by code running in a multi-threaded
    environment.    You can call OCIThreadIsMulti() to determine whether the
    environment is multi-threaded or single-threaded.


    1.3.1    Types
    --------------

    1.3.1.1        OCIThreadHandle - OCIThread Thread Handle
    ------------------------------------------------------

        Type 'OCIThreadHandle' is used to manipulate a thread in the active
        primitives:    OCIThreadJoin()and OCIThreadClose().    A thread handle opened by
        OCIThreadCreate() must be closed in a matching call to
        OCIThreadClose().    A thread handle is invalid after the call to
        OCIThreadClose().

        The distinction between a thread ID and a thread handle in OCIThread usage
        follows the distinction between the thread ID and the thread handle on
        Windows NT.    On many platforms, the underlying native types are the same.


    1.3.2    Functions
    ------------------

        OCIThreadHndInit - OCIThread HaNDle Initialize
        ----------------------------------------------

            Description

                Allocate and initialize the thread handle.

            Prototype

                sword OCIThreadHndInit(dvoid *hndl, OCIError *err,
                        OCIThreadHandle** thnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        thnd(OUT):        The address of pointer to the thread handle to initialize.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.


        OCIThreadHndDestroy - OCIThread HaNDle Destroy
        ----------------------------------------------

            Description

                Destroy and deallocate the thread handle.

            Prototype

                sword OCIThreadHndDestroy(dvoid *hndl, OCIError *err,
                    OCIThreadHandle** thnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        thnd(IN/OUT):    The address of pointer to the thread handle to destroy.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'thnd' should be initialized by OCIThreadHndInit().


        OCIThreadCreate - OCIThread Thread Create
        -----------------------------------------

            Description

                This creates a new thread.

            Prototype

                sword OCIThreadCreate(dvoid *hndl, OCIError *err,
                        void (*start)(dvoid *), dvoid *arg,
                        OCIThreadId *tid, OCIThreadHandle *tHnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        start(IN):        The function in which the new thread should begin
                        execution.

        arg(IN):            The argument to give the function pointed to by 'start'.

        tid(IN/OUT):    If not NULL, gets the ID for the new thread.

        tHnd(IN/OUT): If not NULL, gets the handle for the new thread.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                The new thread will start by executing a call to the function pointed
                to by 'start' with the argument given by 'arg'.    When that function
                returns, the new thread will terminate.    The function should not
                return a value and should accept one parameter, a 'dvoid *'.

                The call to OCIThreadCreate() must be matched by a call to
                OCIThreadClose() if and only if tHnd is non-NULL.

                If tHnd is NULL, a thread ID placed in *tid will not be valid in the
                calling thread because the timing of the spawned thread's termination
                is unknown.

                'tid' should be initialized by OCIThreadIdInit().

                'thnd' should be initialized by OCIThreadHndInit().



        OCIThreadJoin - OCIThread Thread Join
        -------------------------------------

            Description

                This function allows the calling thread to 'join' with another thread.
                It blocks the caller until the specified thread terminates.

            Prototype

                sword OCIThreadJoin(dvoid *hndl, OCIError *err, OCIThreadHandle *tHnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tHnd(IN):        The 'OCIThreadHandle' of the thread to join with.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'thnd' should be initialized by OCIThreadHndInit().

                The result of multiple threads all trying to join with the same thread is
                undefined.


        OCIThreadClose - OCIThread Thread Close
        ---------------------------------------

        Description

            This function should be called to close a thread handle.

        Prototype

            sword OCIThreadClose(dvoid *hndl, OCIError *err, OCIThreadHandle *tHnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tHnd(IN/OUT):        The OCIThread thread handle to close.

        Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

        Notes

                'thnd' should be initialized by OCIThreadHndInit().

                Both thread handle and the thread ID that was returned by the same call
                to OCIThreadCreate() are invalid after the call to OCIThreadClose().



        OCIThreadHandleGet - OCIThread Thread Get Handle
        ------------------------------------------------

            Description

                Retrieve the 'OCIThreadHandle' of the thread in which it is called.

            Prototype

                sword OCIThreadHandleGet(dvoid *hndl, OCIError *err,
                            OCIThreadHandle *tHnd);

        hndl(IN/OUT): The OCI environment or session handle.

        err(IN/OUT): The OCI error handle.    If there is an error and OCI_ERROR
                    is returned, the error is recorded in err and diagnostic
                    information can be obtained by calling OCIErrorGet().

        tHnd(IN/OUT):            If not NULL, the location to place the thread
                    handle for the thread.

            Returns

                OCI_SUCCESS, OCI_ERROR or OCI_INVALID_HANDLE.

            Notes

                'thnd' should be initialized by OCIThreadHndInit().

                The thread handle 'tHnd' retrieved by this function must be closed
                with OCIThreadClose() and destroyed by OCIThreadHndDestroy() after it
                is used.




    1.4 Using OCIThread
    =====================

    This section summarizes some of the more important details relating to the use
    of OCIThread.

        * Process initialization

            OCIThread only requires that the process initialization function
            ('OCIThreadProcessInit()') be called when OCIThread is being used in a
            multi-threaded application.    Failing to call 'OCIThreadProcessInit()' in
            a single-threaded application is not an error.

        * OCIThread initialization

            Separate calls to 'OCIThreadInit()' will all return the same OCIThread
            context.

            Also, remember that each call to 'OCIThreadInit()' must eventually be
            matched by a call to 'OCIThreadTerm()'.

        * Active vs. Passive Threading primitives

            OCIThread client code written without using any active primitives can be
            compiled and used without change on both single-threaded and
            multi-threaded platforms.

            OCIThread client code written using active primitives will only work
            correctly on multi-threaded platforms.    In order to write a version of the
            same application to run on single-threaded platform, it is necessary to
            branch the your code, whether by branching versions of the source file or
            by branching at runtime with the OCIThreadIsMulti() call.

    ******************************************************************************/

    /**
    *
    */
    extern (C) void OCIThreadProcessInit ();

    /**
    *
    */
    extern (C) sword OCIThreadInit (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) sword OCIThreadTerm (dvoid* hndl, OCIError* err);

    /**
    *
    */
    extern (C) boolean OCIThreadIsMulti ();

    /**
    *
    */
    extern (C) sword OCIThreadMutexInit (dvoid* hndl, OCIError* err, OCIThreadMutex** mutex);

    /**
    *
    */
    extern (C) sword OCIThreadMutexDestroy (dvoid* hndl, OCIError* err, OCIThreadMutex** mutex);

    /**
    *
    */
    extern (C) sword OCIThreadMutexAcquire (dvoid* hndl, OCIError* err, OCIThreadMutex* mutex);

    /**
    *
    */
    extern (C) sword OCIThreadMutexRelease (dvoid* hndl, OCIError* err, OCIThreadMutex* mutex);

    /**
    *
    */
    extern (C) sword OCIThreadKeyInit (dvoid* hndl, OCIError* err, OCIThreadKey** key, OCIThreadKeyDestFunc destFn);

    /**
    *
    */
    extern (C) sword OCIThreadKeyDestroy (dvoid* hndl, OCIError* err, OCIThreadKey** key);

    /**
    *
    */
    extern (C) sword OCIThreadKeyGet (dvoid* hndl, OCIError* err, OCIThreadKey* key, dvoid** pValue);

    /**
    *
    */
    extern (C) sword OCIThreadKeySet (dvoid* hndl, OCIError* err, OCIThreadKey* key, dvoid* value);

    /**
    *
    */
    extern (C) sword OCIThreadIdInit (dvoid* hndl, OCIError* err, OCIThreadId** tid);

    /**
    *
    */
    extern (C) sword OCIThreadIdDestroy (dvoid* hndl, OCIError* err, OCIThreadId** tid);

    /**
    *
    */
    extern (C) sword OCIThreadIdSet (dvoid* hndl, OCIError* err, OCIThreadId* tidDest, OCIThreadId* tidSrc);

    /**
    *
    */
    extern (C) sword OCIThreadIdSetNull (dvoid* hndl, OCIError* err, OCIThreadId* tid);

    /**
    *
    */
    extern (C) sword OCIThreadIdGet (dvoid* hndl, OCIError* err, OCIThreadId* tid);

    /**
    *
    */
    extern (C) sword OCIThreadIdSame (dvoid* hndl, OCIError* err, OCIThreadId* tid1, OCIThreadId* tid2, boolean* result);

    /**
    *
    */
    extern (C) sword OCIThreadIdNull (dvoid* hndl, OCIError* err, OCIThreadId* tid, boolean* result);

    /**
    *
    */
    extern (C) sword OCIThreadHndInit (dvoid* hndl, OCIError* err, OCIThreadHandle** thnd);

    /**
    *
    */
    extern (C) sword OCIThreadHndDestroy (dvoid* hndl, OCIError* err, OCIThreadHandle** thnd);

    /**
    *
    */
    extern (C) sword OCIThreadCreate (dvoid* hndl, OCIError* err, void function(dvoid*) start, dvoid* arg, OCIThreadId* tid, OCIThreadHandle* tHnd);

    /**
    *
    */
    extern (C) sword OCIThreadJoin (dvoid* hndl, OCIError* err, OCIThreadHandle* tHnd);

    /**
    *
    */
    extern (C) sword OCIThreadClose (dvoid* hndl, OCIError* err, OCIThreadHandle* tHnd);

    /**
    *
    */
    extern (C) sword OCIThreadHandleGet (dvoid* hndl, OCIError* err, OCIThreadHandle* tHnd);

    /**
    *
    */
    alias sword function(dvoid* ctx) OCIBindRowCallback;

    /**
    *
    */
    alias sword function(dvoid* ctx) OCIFetchRowCallback;

    /**
    *
    */
    alias ub4 function(dvoid* ctx, OCISubscription* subscrhp, dvoid* pay, ub4 payl, dvoid* desc, ub4 mode) OCISubscriptionNotify;

    /**
    *
    */
    extern (C) sword OCISubscriptionRegister (OCISvcCtx* svchp, OCISubscription** subscrhpp, ub2 count, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISubscriptionPost (OCISvcCtx* svchp, OCISubscription** subscrhpp, ub2 count, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISubscriptionUnRegister (OCISvcCtx* svchp, OCISubscription* subscrhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISubscriptionDisable (OCISubscription* subscrhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISubscriptionEnable (OCISubscription* subscrhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIDateTimeGetTime (dvoid* hndl, OCIError* err, OCIDateTime* datetime, ub1* hr, ub1* mm, ub1* ss, ub4* fsec);

    /**
    *
    */
    extern (C) sword OCIDateTimeGetDate (dvoid* hndl, OCIError* err, OCIDateTime* date, sb2* yr, ub1* mnth, ub1* dy);

    /**
    *
    */
    extern (C) sword OCIDateTimeGetTimeZoneOffset (dvoid* hndl, OCIError* err, OCIDateTime* datetime, sb1* hr, sb1* mm);

    /**
    *
    */
    extern (C) sword OCIDateTimeConstruct (dvoid* hndl,OCIError* err, OCIDateTime* datetime, sb2 yr, ub1 mnth, ub1 dy, ub1 hr, ub1 mm, ub1 ss, ub4 fsec, OraText* timezone, size_t timezone_length);

    /**
    *
    */
    extern (C) sword OCIDateTimeSysTimeStamp (dvoid* hndl, OCIError* err, OCIDateTime* sys_date);

    /**
    *
    */
    extern (C) sword OCIDateTimeAssign (dvoid* hndl, OCIError* err, OCIDateTime* from, OCIDateTime* to);

    /**
    *
    */
    extern (C) sword OCIDateTimeToText (dvoid* hndl, OCIError* err, OCIDateTime* date, OraText* fmt, ub1 fmt_length, ub1 fsprec, OraText* lang_name, size_t lang_length, ub4* buf_size, OraText* buf);

    /**
    *
    */
    extern (C) sword OCIDateTimeFromText (dvoid* hndl, OCIError* err, OraText* date_str, size_t dstr_length, OraText* fmt, ub1 fmt_length, OraText* lang_name, size_t lang_length, OCIDateTime* date);

    /**
    *
    */
    extern (C) sword OCIDateTimeCompare (dvoid* hndl, OCIError* err, OCIDateTime* date1, OCIDateTime* date2, sword* result);

    /**
    *
    */
    extern (C) sword OCIDateTimeCheck (dvoid* hndl, OCIError* err, OCIDateTime* date, ub4* valid);

    /**
    *
    */
    extern (C) sword OCIDateTimeConvert (dvoid* hndl, OCIError* err, OCIDateTime* indate, OCIDateTime* outdate);

    /**
    *
    */
    extern (C) sword OCIDateTimeSubtract (dvoid* hndl, OCIError* err, OCIDateTime* indate1, OCIDateTime* indate2, OCIInterval* inter);

    /**
    *
    */
    extern (C) sword OCIDateTimeIntervalAdd (dvoid* hndl, OCIError* err, OCIDateTime* datetime, OCIInterval* inter, OCIDateTime* outdatetime);

    /**
    *
    */
    extern (C) sword OCIDateTimeIntervalSub (dvoid* hndl, OCIError* err, OCIDateTime* datetime, OCIInterval* inter, OCIDateTime* outdatetime);

    /**
    *
    */
    extern (C) sword OCIIntervalSubtract (dvoid* hndl, OCIError* err, OCIInterval* minuend, OCIInterval* subtrahend, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalAdd (dvoid* hndl, OCIError* err, OCIInterval* addend1, OCIInterval* addend2, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalMultiply (dvoid* hndl, OCIError* err, OCIInterval* inter, OCINumber* nfactor, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalDivide (dvoid* hndl, OCIError* err, OCIInterval* dividend, OCINumber* divisor, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalCompare (dvoid* hndl, OCIError* err, OCIInterval* inter1, OCIInterval* inter2, sword* result);

    /**
    *
    */
    extern (C) sword OCIIntervalFromNumber (dvoid* hndl, OCIError* err, OCIInterval* inter, OCINumber* number);

    /**
    *
    */
    extern (C) sword OCIIntervalFromText (dvoid* hndl, OCIError* err, OraText* inpstr, size_t str_len, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalToText (dvoid* hndl, OCIError* err, OCIInterval* inter, ub1 lfprec, ub1 fsprec, OraText* buffer, size_t buflen, size_t* resultlen);

    /**
    *
    */
    extern (C) sword OCIIntervalToNumber (dvoid* hndl, OCIError* err, OCIInterval* inter, OCINumber* number);

    /**
    *
    */
    extern (C) sword OCIIntervalCheck (dvoid* hndl, OCIError* err, OCIInterval* interval, ub4* valid);

    /**
    *
    */
    extern (C) sword OCIIntervalAssign (dvoid* hndl, OCIError* err, OCIInterval* ininter, OCIInterval* outinter);

    /**
    *
    */
    extern (C) sword OCIIntervalSetYearMonth (dvoid* hndl, OCIError* err, sb4 yr, sb4 mnth, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalGetYearMonth (dvoid* hndl, OCIError* err, sb4* yr, sb4* mnth, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalSetDaySecond (dvoid* hndl, OCIError* err, sb4 dy, sb4 hr, sb4 mm, sb4 ss, sb4 fsec, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIIntervalGetDaySecond (dvoid* hndl, OCIError* err, sb4* dy, sb4* hr, sb4* mm, sb4* ss, sb4* fsec, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIDateTimeToArray (dvoid* hndl, OCIError* err, OCIDateTime* datetime, OCIInterval* reftz, ub1* outarray, ub4* len, ub1 fsprec);

    /**
    *
    */
    extern (C) sword OCIDateTimeFromArray (dvoid* hndl, OCIError* err, ub1* inarray, ub4 len, ub1 type, OCIDateTime* datetime, OCIInterval* reftz, ub1 fsprec);

    /**
    *
    */
    extern (C) sword OCIDateTimeGetTimeZoneName (dvoid* hndl, OCIError* err, OCIDateTime* datetime, ub1* buf, ub4* buflen);

    /**
    *
    */
    extern (C) sword OCIIntervalFromTZ (dvoid* hndl, OCIError* err, oratext* inpstring, size_t str_len, OCIInterval* result);

    /**
    *
    */
    extern (C) sword OCIConnectionPoolCreate (OCIEnv* envhp, OCIError* errhp, OCICPool* poolhp, OraText** poolName, sb4* poolNameLen, OraText* dblink, sb4 dblinkLen, ub4 connMin, ub4 connMax, ub4 connIncr, OraText* poolUserName, sb4 poolUserLen, OraText* poolPassword, sb4 poolPassLen, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIConnectionPoolDestroy (OCICPool* poolhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionPoolCreate (OCIEnv* envhp, OCIError* errhp, OCISPool* spoolhp, OraText** poolName, ub4* poolNameLen, OraText* connStr, ub4 connStrLen, ub4 sessMin, ub4 sessMax, ub4 sessIncr, OraText* userid, ub4 useridLen, OraText* password, ub4 passwordLen, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionPoolDestroy (OCISPool* spoolhp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionGet (OCIEnv* envhp, OCIError* errhp, OCISvcCtx** svchp, OCIAuthInfo* authhp, OraText* poolName, ub4 poolName_len, OraText* tagInfo, ub4 tagInfo_len, OraText** retTagInfo, ub4* retTagInfo_len, boolean* found, ub4 mode);

    /**
    *
    */
    extern (C) sword OCISessionRelease (OCISvcCtx* svchp, OCIError* errhp, OraText* tag, ub4 tag_len, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIAppCtxSet (void*    sesshndl, dvoid* nsptr, ub4 nsptrlen, dvoid* attrptr, ub4 attrptrlen, dvoid* valueptr, ub4 valueptrlen, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIAppCtxClearAll (void* sesshndl, dvoid* nsptr, ub4 nsptrlen, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIPing (OCISvcCtx* svchp, OCIError* errhp, ub4 mode);

    /**
    *
    */
    extern (C) sword OCIKerbAttrSet (OCISession* trgthndlp, ub4 cred_use, ub1* ftgt_ticket, ub4 ticket_len, ub1* session_key, ub4 skey_len, ub2 ftgt_keytype, ub4 ftgt_ticket_flags, sb4 ftgt_auth_time, sb4 ftgt_start_time, sb4 ftgt_end_time, sb4 ftgt_renew_time,    text* ftgt_client_principal, ub4 ftgt_client_principal_len, text* ftgt_client_realm, ub4 ftgt_client_realm_len, OCIError* errhp);

    /**
    *
    */
    extern (C) sword OCIDBStartup (OCISvcCtx* svchp, OCIError* errhp, OCIAdmin* admhp, ub4 mode, ub4 flags);

    /**
    *
    */
    extern (C) sword OCIDBShutdown (OCISvcCtx* svchp, OCIError* errhp, OCIAdmin* admhp, ub4 mode);

    /**
    *
    */
    extern (C) void OCIClientVersion (sword* major_version, sword* minor_version, sword* update_num, sword* patch_num, sword* port_update_num);

    /**
    *
    */
    extern (C) sword OCIInitEventHandle (OCIError* errhp,    OCIEvent* event, text* str, ub4 size);

    /**
    *
    */


    /**
    *
    */


    /**
    *
    */









    /**
    *
    *
    * Params:
    *    cursor =
    *    opcode =
    *    sqlvar =
    *    sqlvl =
    *    pvctx =
    *    progvl =
    *    ftype =
    *    scale =
    *    indp =
    *    alen =
    *    arcode =
    *    pv_skip =
    *    ind_skip =
    *    alen_skip =
    *    rc_skip =
    *    maxsiz =
    *    cursiz =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *
    * Returns:
    *
    */
    extern (C) sword obindps (cda_def* cursor, ub1 opcode, OraText* sqlvar, sb4 sqlvl, ub1* pvctx, sb4 progvl, sword ftype, sword scale, sb2* indp, ub2* alen, ub2* arcode, sb4 pv_skip, sb4 ind_skip, sb4 alen_skip, sb4 rc_skip, ub4 maxsiz, ub4* cursiz, OraText* fmt, sb4 fmtl, sword fmtt);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword obreak (cda_def* lda);

    /**
    *
    *
    * Params:
    *    cursor =
    *
    * Returns:
    *
    */
    extern (C) sword ocan (cda_def* cursor);

    /**
    *
    *
    * Params:
    *    cursor =
    *
    * Returns:
    *
    */
    extern (C) sword oclose (cda_def* cursor);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword ocof (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword ocom (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword ocon (cda_def* lda);

    /**
    *
    *
    * Params:
    *    cursor =
    *    opcode =
    *    pos =
    *    bufctx =
    *    buf1 =
    *    ftype =
    *    scale =
    *    indp =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *    rlen =
    *    rcode =
    *    pv_skip =
    *    ind_skip =
    *    alen_skip =
    *    rc_skip =
    *
    * Returns:
    *
    */
    extern (C) sword odefinps (cda_def* cursor, ub1 opcode, sword pos, ub1* bufctx, sb4 bufl, sword ftype, sword scale, sb2* indp, OraText* fmt, sb4 fmtl, sword fmtt, ub2* rlen, ub2* rcode, sb4 pv_skip, sb4 ind_skip, sb4 alen_skip, sb4 rc_skip);

    /**
    *
    *
    * Params:
    *    cursor =
    *    objnam =
    *    onlen =
    *    rsv1 =
    *    rsv1ln =
    *    rsv2 =
    *    rsv2ln =
    *    ovrld =
    *    pos =
    *    level =
    *    argnam =
    *    arnlen =
    *    dtype =
    *    defsup =
    *    mode =
    *    dtsiz =
    *    prec =
    *    scale =
    *    radix =
    *    spare =
    *    arrsiz =
    *
    * Returns:
    *
    */
    extern (C) sword odessp (cda_def* cursor, OraText* objnam, size_t onlen, ub1* rsv1, size_t rsv1ln, ub1* rsv2, size_t rsv2ln, ub2* ovrld, ub2* pos, ub2* level, OraText** argnam, ub2* arnlen, ub2* dtype, ub1* defsup, ub1* mode, ub4* dtsiz, sb2* prec, sb2* scale, ub1* radix, ub4* spare, ub4* arrsiz);

    /**
    *
    *
    * Params:
    *    cursor =
    *    pos =
    *    dbsize =
    *    dbtype =
    *    cbuf =
    *    cbufl =
    *    dsize =
    *    prec =
    *    scale =
    *    nullok =
    *
    * Returns:
    *
    */
    extern (C) sword odescr (cda_def* cursor, sword pos, sb4* dbsize, sb2* dbtype, sb1* cbuf, sb4* cbufl, sb4* dsize, sb2* prec, sb2* scale, sb2* nullok);

    /**
    *
    *
    * Params:
    *    lda =
    *    rcode =
    *    buf =
    *    bufsiz =
    *
    * Returns:
    *
    */
    extern (C) sword oerhms (cda_def* lda, sb2 rcode, OraText* buf, sword bufsiz);

    /**
    *
    *
    * Params:
    *    rcode =
    *    buf =
    *
    * Returns:
    *
    */
    extern (C) sword oermsg (sb2 rcode, OraText* buf);

    /**
    *
    *
    * Params:
    *    cursor =
    *
    * Returns:
    *
    */
    extern (C) sword oexec (cda_def* cursor);

    /**
    *
    *
    * Params:
    *    cursor =
    *    nrows =
    *    cancel =
    *    exact =
    *
    * Returns:
    *
    */
    extern (C) sword oexfet (cda_def* cursor, ub4 nrows, sword cancel, sword exact);

    /**
    *
    *
    * Params:
    *    cursor =
    *    iters =
    *    rowoff =
    *
    * Returns:
    *
    */
    extern (C) sword oexn (cda_def* cursor, sword iters, sword rowoff);

    /**
    *
    *
    * Params:
    *    cursor =
    *    nrows =
    *
    * Returns:
    *
    */
    extern (C) sword ofen (cda_def* cursor, sword nrows);

    /**
    *
    *
    * Params:
    *    cursor =
    *
    * Returns:
    *
    */
    extern (C) sword ofetch (cda_def* cursor);

    /**
    *
    *
    * Params:
    *    cursor =
    *    pos =
    *    buf =
    *    bufl =
    *    dtype =
    *    retl =
    *    offset =
    *
    * Returns:
    *
    */
    extern (C) sword oflng (cda_def* cursor, sword pos, ub1* buf, sb4 bufl, sword dtype, ub4* retl, sb4 offset);

    /**
    *
    *
    * Params:
    *    cursor =
    *    piecep =
    *    ctxpp =
    *    iterp =
    *    indexp =
    *
    * Returns:
    *
    */
    extern (C) sword ogetpi (cda_def* cursor, ub1* piecep, dvoid** ctxpp, ub4* iterp, ub4* indexp);

    /**
    *
    *
    * Params:
    *    cursor =
    *    rbopt =
    *    waitopt =
    *
    * Returns:
    *
    */
    extern (C) sword oopt (cda_def* cursor, sword rbopt, sword waitopt);

    /**
    *
    *
    * Params:
    *    mode =
    *
    * Returns:
    *
    */
    extern (C) sword opinit (ub4 mode);

    /**
    *
    *
    * Params:
    *    lda =
    *    hda =
    *    uid =
    *    uidl =
    *    pswd =
    *    pswdl =
    *    conn =
    *    connl =
    *    mode =
    *
    * Returns:
    *
    */
    extern (C) sword olog (cda_def* lda, ub1* hda, OraText* uid, sword uidl, OraText* pswd, sword pswdl, OraText* conn, sword connl, ub4 mode);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword ologof (cda_def* lda);

    /**
    *
    *
    * Params:
    *    cursor =
    *    lda =
    *    dbn =
    *    dbnl =
    *    arsize =
    *    uid =
    *    uidl =
    *
    * Returns:
    *
    */
    extern (C) sword oopen (cda_def* cursor, cda_def* lda, OraText* dbn, sword dbnl, sword arsize, OraText* uid, sword uidl);

    /**
    *
    *
    * Params:
    *    cursor =
    *    sqlstm =
    *    sqllen =
    *    defflg =
    *    lngflg =
    *
    * Returns:
    *
    */
    extern (C) sword oparse (cda_def* cursor, OraText* sqlstm, sb4 sqllen, sword defflg, ub4 lngflg);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword orol (cda_def* lda);

    /**
    *
    *
    * Params:
    *    cursor =
    *    piece =
    *    bufp =
    *    lenp =
    *
    * Returns:
    *
    */
    extern (C) sword osetpi (cda_def* cursor, ub1 piece, dvoid* bufp, ub4* lenp);

    /**
    *
    *
    * Params:
    *    lda =
    *    cname =
    *    cnlen =
    *
    * Returns:
    *
    */
    extern (C) void sqlld2 (cda_def* lda, OraText* cname, sb4* cnlen);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) void sqllda (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword onbset (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword onbtst (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *
    * Returns:
    *
    */
    extern (C) sword onbclr (cda_def* lda);

    /**
    *
    *
    * Params:
    *    lda =
    *    fdp =
    *
    * Returns:
    *
    */
    extern (C) sword ognfd (cda_def* lda, dvoid* fdp);

    /**
    *
    *
    * Params:
    *    cursor =
    *    sqlvar =
    *    sqlvl =
    *    progv =
    *    progvl =
    *    ftype =
    *    scale =
    *    indp =
    *    alen =
    *    arcode =
    *    maxsize =
    *    cursiz =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cursor =
    *    sqlvn =
    *    progv =
    *    progvl =
    *    ftype =
    *    scale =
    *    indp =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cursor =
    *    sqlvar =
    *    sqlvl =
    *    progv =
    *    progvl =
    *    ftype =
    *    scale =
    *    indp =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cursor =
    *    pos =
    *    buf =
    *    bufl =
    *    ftype =
    *    scale =
    *    indp =
    *    fmt =
    *    fmtl =
    *    fmtt =
    *    rlen =
    *    rcode =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cursor =
    *    pos =
    *    tbuf =
    *    tbufl =
    *    buf =
    *    bufl =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    lda =
    *    hda =
    *    uid =
    *    uidl =
    *    pswd =
    *    pswdl =
    *    audit =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    lda =
    *    uid =
    *    uidl =
    *    pswd =
    *    pswdl =
    *    audit =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cda =
    *    sqlstm =
    *    sqllen =
    *
    * Returns:
    *
    */


    /**
    *
    *
    * Params:
    *    cursor =
    *    pos =
    *    dbsize =
    *    fsize =
    *    rcode =
    *    dtype =
    *    buf =
    *    bufl =
    *    dsize =
    *
    * Returns:
    *
    */









    struct riddef {
        ub4 ridobjnum;                    ///
        ub2 ridfilenum;                    ///
        ub1 filler;                    ///
        ub4 ridblocknum;                ///
        ub2 ridslotnum;                    ///
    }

    enum uint CSRCHECK            = 172;        /// csrdef is a cursor.
    enum uint LDACHECK            = 202;        /// csrdef is a login data area.

    /**
    *
    */
    struct csrdef {
        b2 csrrc;                    /// Return code: v2 codes, v4 codes negative.
        ub2 csrft;                    /// Function type.
        ub4 csrrpc;                    /// Rows processed count.
        ub2 csrpeo;                    /// Parse error offset.
        ub1 csrfc;                    /// Function code.
        ub1 csrlfl;                    /// Lda flag to indicate type of login.
        ub2 csrarc;                    /// Actual untranslated return code.
        ub1 csrwrn;                    /// Warning flags.
        ub1 csrflg;                    /// Error action.
        eword csrcn;                    /// Cursor number.
        riddef csrrid;                    /// Rowid structure.
        eword csrose;                    /// OS dependent error code.
        ub1 csrchk;                    /// Check byte = CSRCHECK - in cursor.
    //    hstdef* csrhst;                    /// Pointer to the hst.
    }
    alias csrdef ldadef;

    enum uint LDAFLG            = 1;        /// ...Via ologon.
    enum uint LDAFLO            = 2;        /// ...Via olon or orlon.
    enum uint LDANBL            = 3;        /// ...Nonblocking logon in progress.
    enum uint csrfpa            = 2;        /// ...OSQL.
    enum uint csrfex            = 4;        /// ...OEXEC.
    enum uint csrfbi            = 6;        /// ...OBIND.
    enum uint csrfdb            = 8;        /// ...ODFINN.
    enum uint csrfdi            = 10;        /// ...ODSRBN.
    enum uint csrffe            = 12;        /// ...OFETCH.
    enum uint csrfop            = 14;        /// ...OOPEN.
    enum uint csrfcl            = 16;        /// ...OCLOSE.
    enum uint csrfds            = 22;        /// ...ODSC.
    enum uint csrfnm            = 24;        /// ...ONAME.
    enum uint csrfp3            = 26;        /// ...OSQL3.
    enum uint csrfbr            = 28;        /// ...OBNDRV.
    enum uint csrfbx            = 30;        /// ...OBNDRN.
    enum uint csrfso            = 34;        /// ...OOPT.
    enum uint csrfre            = 36;        /// ...ORESUM.
    enum uint csrfbn            = 50;        /// ...OBINDN.
    enum uint csrfca            = 52;        /// ...OCANCEL.
    enum uint csrfsd            = 54;        /// ...OSQLD.
    enum uint csrfef            = 56;        /// ...OEXFEN.
    enum uint csrfln            = 58;        /// ...OFLNG.
    enum uint csrfdp            = 60;        /// ...ODSCSP.
    enum uint csrfba            = 62;        /// ...OBNDRA.
    enum uint csrfbps            = 63;        /// ...OBINDPS.
    enum uint csrfdps            = 64;        /// ...ODEFINPS.
    enum uint csrfgpi            = 65;        /// ...OGETPI.
    enum uint csrfspi            = 66;        /// ...OSETPI.

    enum uint CSRWANY            = 0x01;        /// There is a warning flag set.
    enum uint CSRWTRUN            = 0x02;        /// A data item was truncated.
    enum uint CSRWNVIC            = 0x04;        /// Null values were used in an aggregate function.
    enum uint CSRWITCE            = 0x08;        /// Column count not equal to into list count.
    enum uint CSRWUDNW            = 0x10;        /// Update or delete without where clause.
    enum uint CSRWRSV0            = 0x20;        ///
    enum uint CSRWROLL            = 0x40;        /// Rollback required.
    enum uint CSRWRCHG            = 0x80;        /// Change after query start on select for update.

    enum uint CSRFSPND            = 0x01;        /// Current operation suspended.
    enum uint CSRFATAL            = 0x02;        /// Fatal operation: transaction rolled back.
    enum uint CSRFBROW            = 0x04;        /// Current row backed out.
    enum uint CSRFREFC            = 0x08;        /// Ref cursor type CRSCHK disabled for this cursor.
    enum uint CSRFNOAR            = 0x10;        /// Ref cursor type binds, so no array bind/execute.

    enum uint OTYCTB            = 1;        /// Create table.
    enum uint OTYSER            = 2;        /// Set role.
    enum uint OTYINS            = 3;        /// Insert.
    enum uint OTYSEL            = 4;        /// Select.
    enum uint OTYUPD            = 5;        /// Update.
    enum uint OTYDRO            = 6;        /// Drop role.
    enum uint OTYDVW            = 7;        /// Drop view.
    enum uint OTYDTB            = 8;        /// Drop table.
    enum uint OTYDEL            = 9;        /// Delete.
    enum uint OTYCVW            = 10;        /// Create view.
    enum uint OTYDUS            = 11;        /// Drop user.
    enum uint OTYCRO            = 12;        /// Create role.
    enum uint OTYCSQ            = 13;        /// Create sequence.
    enum uint OTYASQ            = 14;        /// Alter sequence.
    enum uint OTYACL            = 15;        /// Alter cluster.
    enum uint OTYDSQ            = 16;        /// Drop sequence.
    enum uint OTYCSC            = 17;        /// Create schema.
    enum uint OTYCCL            = 18;        /// Create cluster.
    enum uint OTYCUS            = 19;        /// Create user.
    enum uint OTYCIX            = 20;        /// Create index.
    enum uint OTYDIX            = 21;        /// Drop index.
    enum uint OTYDCL            = 22;        /// Drop cluster.
    enum uint OTYVIX            = 23;        /// Validate index.
    enum uint OTYCPR            = 24;        /// Create procedure.
    enum uint OTYAPR            = 25;        /// Alter procedure.
    enum uint OTYATB            = 26;        /// Alter table.
    enum uint OTYXPL            = 27;        /// Explain.
    enum uint OTYGRA            = 28;        /// Grant.
    enum uint OTYREV            = 29;        /// Revoke.
    enum uint OTYCSY            = 30;        /// Create synonym.
    enum uint OTYDSY            = 31;        /// Drop synonym.
    enum uint OTYASY            = 32;        /// Alter system switch log.
    enum uint OTYSET            = 33;        /// Set transaction.
    enum uint OTYPLS            = 34;        /// PL/SQL execute.
    enum uint OTYLTB            = 35;        /// Lock.
    enum uint OTYNOP            = 36;        /// Noop.
    enum uint OTYRNM            = 37;        /// Rename.
    enum uint OTYCMT            = 38;        /// Comment.
    enum uint OTYAUD            = 39;        /// Audit.
    enum uint OTYNOA            = 40;        /// No audit.
    enum uint OTYAIX            = 41;        /// Alter index.
    enum uint OTYCED            = 42;        /// Create external database.
    enum uint OTYDED            = 43;        /// Drop external database.
    enum uint OTYCDB            = 44;        /// Create database.
    enum uint OTYADB            = 45;        /// Alter database.
    enum uint OTYCRS            = 46;        /// Create rollback segment.
    enum uint OTYARS            = 47;        /// Alter rollback segment.
    enum uint OTYDRS            = 48;        /// Drop rollback segment.
    enum uint OTYCTS            = 49;        /// Create tablespace.
    enum uint OTYATS            = 50;        /// Alter tablespace.
    enum uint OTYDTS            = 51;        /// Drop tablespace.
    enum uint OTYASE            = 52;        /// Alter session.
    enum uint OTYAUR            = 53;        /// Alter user.
    enum uint OTYCWK            = 54;        /// Commit (work).
    enum uint OTYROL            = 55;        /// Rollback.
    enum uint OTYSPT            = 56;        /// Savepoint.

    enum uint OTYDEV            = 10;        /// Old DEFINE VIEW = create view.

    enum uint OCLFPA            = 2;        /// Parse - OSQL.
    enum uint OCLFEX            = 4;        /// Execute - OEXEC.
    enum uint OCLFBI            = 6;        /// Bind by name - OBIND.
    enum uint OCLFDB            = 8;        /// Define buffer -    ODEFIN.
    enum uint OCLFDI            = 10;        /// Describe item - ODSC.
    enum uint OCLFFE            = 12;        /// Fetch - OFETCH.
    enum uint OCLFOC            = 14;        /// Open cursor - OOPEN.
    enum uint OCLFLI            = 14;        /// Old name for open cursor - OOPEN.
    enum uint OCLFCC            = 16;        /// Close cursor - OCLOSE.
    enum uint OCLFLO            = 16;        /// Old name for close cursor - OCLOSE.
    enum uint OCLFDS            = 22;        /// Describe - ODSC.
    enum uint OCLFON            = 24;        /// Get table and column names - ONAME.
    enum uint OCLFP3             = 26;        /// Parse - OSQL3.
    enum uint OCLFBR            = 28;        /// Bind reference by name - OBNDRV.
    enum uint OCLFBX            = 30;        /// Bind reference numeric - OBNDRN.
    enum uint OCLFSO            = 34;        /// Special function - OOPT.
    enum uint OCLFRE            = 36;        /// Resume - ORESUM.
    enum uint OCLFBN            = 50;        /// Bindn.
    enum uint OCLFMX            = 52;        /// Maximum function number.








    /+
    enum uint OCIEVDEF            = UPIEVDEF;    /// Default : non-thread safe enivronment.
    enum uint OCIEVTSF            = UPIEVTSF;    /// Thread-safe environment.

    enum uint OCILMDEF            = UPILMDEF;    /// Default, regular login.
    enum uint OCILMNBL            = UPILMNBL;    /// Non-blocking logon.
    enum uint OCILMESY            = UPILMESY;    /// Thread safe but external sync.
    enum uint OCILMISY            = UPILMISY;    /// Internal sync, we do it.
    enum uint OCILMTRY            = UPILMTRY;    /// Try to, but do not block on mutex.
    +/
    /**
    * Define return code pairs for version 2 to 3 conversions.
    */
    struct ocitab {
        b2 ocitv3;                    /// Version 3/4 return code.
        b2 ocitv2;                    /// Version 2 equivalent return code.
    }

//    extern (C) ocitab* ocitbl;                ///
    /+
    /**
    *
    */
    sword CRSCHK (csrdef c) {
        if (c.csrchk != CSRCHECK && !(c.csrflg && CSRFREFC)) {
            return ocir32(c, CSRFREFC);
        } else {
            return 0;
        }
    }

    /**
    *
    */
    b2 ldaerr (csrdef l, ub2 e) {
        l.csrarc = e;
        l.csrrc = -e;
        return l.csrrc;
    }

    /**
    *
    */
    b2 LDACHK (csrdef l) {
        if (l.csrchk != LDACHECK) {
            return ldaerr(1, OER(1001));
        } else {
            return 0;
        }
    }
    +/

    //extern (C) sword ocilog (ldadef* lda, hstdef* hst, oratext* uid, sword uidl, oratext* psw, sword pswl, oratext* conn, sword connl, ub4 mode);

    extern (C) sword ocilon (ldadef* lda, oratext* uid, sword uidl, oratext* psw, sword pswl, sword audit);

    extern (C) sword ocilgi (ldadef* lda, b2 areacount);

    //extern (C) sword ocirlo (ldadef* lda, hstdef* hst, oratext* uid, sword uidl, oratext* psw, sword pswl, sword audit);
            /* ocilon - logon to oracle
            ** ocilgi - version 2 compatible ORACLE logon call.
            **                    no login to ORACLE is performed: the LDA is initialized
            ** ocirlo - version 5 compatible ORACLE Remote Login call,
            **                    oracle login is executed.
            **        lda            - pointer to ldadef
            **        uid            - user id [USER[/PASSWORD]]
            **        uidl        - length of uid, if -1 strlen(uid) is used
            **        psw            - password string; ignored if specified in uid
            **        pswl        - length of psw, if -1 strlen(psw) is used
            **        audit        - is not supported; the only permissible value is 0
            **        areacount - unused
            */

    extern (C) sword ocilof (ldadef* lda);
            /*
            ** ocilof - disconnect from ORACLE
            **        lda            - pointer to ldadef
            */

    extern (C) sword ocierr (ldadef* lda, b2 rcode, oratext* buffer, sword bufl);
    extern (C) sword ocidhe (b2 rcode, oratext* buffer);
            /*
            ** Move the text explanation for an ORACLE error to a user defined buffer
            **    ocierr - will return the message associated with the hstdef stored
            **                        in the lda.
            **    ocidhe - will return the message associated with the default host.
            **        lda        - lda associated with the login session
            **        rcode    - error code as returned by V3 call interface
            **        buffer - address of a user buffer of at least 132 characters
            */

    extern (C) sword ociope (csrdef* cursor, ldadef* lda, oratext* dbn, sword dbnl, sword areasize, oratext* uid, sword uidl);

    extern (C) sword ociclo (csrdef* cursor);
        /*
        ** open or close a cursor.
        **        cursor - pointer to csrdef
        **        ldadef - pointer to ldadef
        **        dbn        - unused
        **        dbnl        - unused
        **        areasize - if (areasize == -1)    areasize <- system default initial size
        **                            else if (areasize IN [1..256]) areasize <- areasize * 1024;
        **                            most applications should use the default size since context
        **                            areas are extended as needed until memory is exhausted.
        **        uid        - user id
        **        uidl        - userid length
        */

    extern (C) sword ocibre (ldadef* lda);
        /*
        **    ocibrk - Oracle Call Interface send BReaK Sends a break to
        **    oracle.    If oracle is    active,    the    current    operation    is
        **    cancelled.    May be called    asynchronously.        DOES    NOT    SET
        **    OERRCD in the hst.    This is because ocibrk    may    be    called
        **    asynchronously.    Callers must test the return code.
        **        lda    - pointer to a ldadef
        */

    extern (C) sword ocican (csrdef* cursor);
        /*
        **    cancel the operation on the cursor, no additional OFETCH calls
        **    will be issued for the existing cursor without an intervening
        **    OEXEC call.
        **        cursor    - pointer to csrdef
        */

    extern (C) sword ocisfe (csrdef* cursor, sword erropt, sword waitopt);
        /*
        ** ocisfe - user interface set error options
        ** set the error and cursor options.
        ** allows user to set the options for dealing with fatal dml errors
        ** and other cursor related options
        ** see oerdef for valid settings
        **        cursor    - pointer to csrdef
        **        erropt    - error optionsn
        **        waitopr - wait options
        */

    extern (C) sword ocicom (ldadef* lda);
    extern (C) sword ocirol (ldadef* lda);
        /*
        ** ocicom - commit the current transaction
        ** ocirol - roll back the current transaction
        */

    extern (C) sword ocicon (ldadef* lda);
    extern (C) sword ocicof (ldadef* lda);
        /*
        ** ocicon - auto Commit ON
        ** ocicof - auto Commit OFf
        */

    extern (C) sword ocisq3 (csrdef* cursor, oratext* sqlstm, sword sqllen);
        /*
        ** ocisq3 - user interface parse sql statement
        **        cursor - pointer to csrdef
        **        sqlstm - pointer to SQL statement
        **        sqllen - length of SQL statement.    if -1, strlen(sqlstm) is used
        */

    enum uint OCI_PCWS            = 0;        /// For ocibndps and ocidfnps.
    enum uint OCI_SKIP            = 1;        /// ditto

    extern (C) sword ocibin (csrdef* cursor, oratext* sqlvar, sword sqlvl, ub1* progv, sword progvl, sword ftype, sword scale, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword ocibrv (csrdef* cursor, oratext* sqlvar, sword sqlvl, ub1* progv, sword progvl, sword ftype, sword scale, b2* indp, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword ocibra (csrdef* cursor, oratext* sqlvar, sword sqlvl, ub1* progv, sword progvl, sword ftype, sword scale, b2* indp, ub2* aln, ub2* rcp, ub4 mal, ub4* cal, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword ocibndps (csrdef* cursor, ub1 opcode, oratext* sqlvar, sb4 sqlvl, ub1* progv, sb4 progvl, sword ftype, sword scale, b2* indp, ub2* aln, ub2* rcp, sb4 pv_skip, sb4 ind_skip, sb4 len_skip, sb4 rc_skip, ub4 mal, ub4* cal, oratext* fmt, sb4 fmtl, sword fmtt);

    extern (C) sword ocibnn (csrdef* cursor, ub2 sqlvn, ub1* progv, sword progvl, sword ftype, sword scale, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword ocibrn (csrdef* cursor, sword sqlvn, ub1* progv, sword progvl, sword ftype, sword scale, b2* indp, oratext* fmt, sword fmtl, sword fmtt);
            /*
            ** ocibin - bind by value by name
            ** ocibrv - bind by reference by name
            ** ocibra - bind by reference by name (array)
            ** ocibndps - bind by reference by name (array) piecewise or with skips
            ** ocibnn - bind by value numeric
            ** ocibrn - bind by reference numeric
            **
            ** the contents of storage specified in bind-by-value calls are
            ** evaluated immediately.
            ** the addresses of storage specified in bind-by-reference calls are
            ** remembered, and the contents are examined at every execute.
            **
            **    cursor    - pointer to csrdef
            **    sqlvn        - the number represented by the name of the bind variables
            **                        for variables of the form :n or &n for n in [1..256)
            **                        (i.e. &1, :234).    unnecessarily using larger numbers
            **                        in the range wastes space.
            **    sqlvar    - the name of the bind variable (:name or &name)
            **    sqlval    - the length of the name;
            **                        in bindif -1, strlen(bvname) is used
            **    progv        - pointer to the object to bind.
            **    progvl    - length of object to bind.
            **                        in bind-by-value if specified as -1 then strlen(bfa) is
            **                            used (really only makes sends with character types)
            **                        in bind-by-value, if specified as -1 then UB2MAXVAL
            **                            is used.    Again this really makes sense only with
            **                            SQLT_STR.
            **    ftype        - datatype of object
            **    indp        - pointer to indicator variable.
            **                            -1            means to ignore bfa/bfl and bind NULL;
            **                            not -1 means to bind the contents of bfa/bfl
            **                            bind the contents pointed to by bfa
            **    aln            - Alternate length pointer
            **    rcp            - Return code pointer
            **    mal            - Maximum array length
            **    cal            - Current array length pointer
            **    fmt            - format string
            **    fmtl        - length of format string; if -1, strlen(fmt) is used
            **    fmtt        - desired output type after applying forat mask. Not
            **                        really yet implemented
            **    scale        - number of decimal digits in a cobol packed decimal (type 7)
            **
            ** Note that the length of bfa when bound as SQLT_STR is reduced
            ** to strlen(bfa).
            ** Note that trailing blanks are stripped of storage of SQLT_STR.
            */

    extern (C) sword ocidsc (csrdef* cursor, sword pos, b2* dbsize, b2* fsize, b2* rcode, b2* dtype, b1* buf, b2* bufl, b2* dsize);

    extern (C) sword ocidsr (csrdef* cursor, sword pos, b2* dbsize, b2* dtype, b2* fsize);

    extern (C) sword ocinam (csrdef* cursor, sword pos, b1* tbuf, b2* tbufl, b1* buf, b2* bufl);
            /*
            **    ocidsc, ocidsr: Obtain information about a column
            **    ocinam : get the name of a column
            **        cursor    - pointer to csrdef
            **        pos            - position in select list from [1..N]
            **        dbsize    - place to store the database size
            **        fsize        - place to store the fetched size
            **        rcode        - place to store the fetched column returned code
            **        dtype        - place to store the data type
            **        buf            - array to store the column name
            **        bufl        - place to store the column name length
            **        dsize        - maximum display size
            **        tbuf        - place to store the table name
            **        tbufl        - place to store the table name length
            */

    extern (C) sword ocidsp (csrdef* cursor, sword pos, sb4* dbsize, sb2* dbtype, sb1* cbuf, sb4* cbufl, sb4* dsize, sb2* pre, sb2* scl, sb2* nul);

    extern (C) sword ocidpr (ldadef* lda, oratext* object_name, size_t object_length, ptrdiff_t reserved1, size_t reserved1_length, ptrdiff_t reserved2, size_t reserved2_length, ub2* overload, ub2* position, ub2* level, oratext** argument_name, ub2* argument_length, ub2* datatype, ub1* default_supplied, ub1* in_out, ub4* length, sb2* precision, sb2* scale, ub1* radix, ub4* spare, ub4* total_elements);
        /*
        ** OCIDPR - User Program Interface: Describe Stored Procedure
        **
        ** This routine is used to obtain information about the calling
        ** arguments of a stored procedure.    The client provides the
        ** name of the procedure using "object_name" and "database_name"
        ** (database name is optional).    The client also supplies the
        ** arrays for OCIDPR to return the values and indicates the
        ** length of array via the "total_elements" parameter.    Upon return
        ** the number of elements used in the arrays is returned in the
        ** "total_elements" parameter.    If the array is too small then
        ** an error will be returned and the contents of the return arrays
        ** are invalid.
        **
        **
        **        EXAMPLE :
        **
        **        Client provides -
        **
        **        object_name        - SCOTT.ACCOUNT_UPDATE@BOSTON
        **        total_elements - 100
        **
        **
        **        ACCOUNT_UPDATE is an overloaded function with specification :
        **
        **            type number_table is table of number index by binary_integer;
        **            table account (account_no number, person_id number,
        **                                        balance number(7,2))
        **            table person    (person_id number(4), person_nm varchar2(10))
        **
        **            function ACCOUNT_UPDATE (account number,
        **                    person person%rowtype, amounts number_table,
        **                    trans_date date) return accounts.balance%type;
        **
        **            function ACCOUNT_UPDATE (account number,
        **                    person person%rowtype, amounts number_table,
        **                    trans_no number) return accounts.balance%type;
        **
        **
        **        Values returned -
        **
        **        overload position        argument    level    datatype length prec scale rad
        **        -------------------------------------------------------------------
        **                    0                0                                0        NUMBER            22        7            2        10
        **                    0                1        ACCOUNT            0        NUMBER            22        0            0        0
        **                    0                2        PERSON                0        RECORD            0        0            0        0
        **                    0                2            PERSON_ID    1        NUMBER            22        4            0        10
        **                    0                2            PERSON_NM    1        VARCHAR2        10        0            0        0
        **                    0                3        AMOUNTS            0        TABLE                0        0            0        0
        **                    0                3                                1        NUMBER            22        0            0        0
        **                    0                4        TRANS_NO            0        NUMBER            22        0            0        0
        **
        **                    1                0                                0        NUMBER            22        7            2        10
        **                    1                1        ACCOUNT            0        NUMBER            22        0            0        0
        **                    1                2        PERSON                0        RECORD            0        0            0        0
        **                    1                2        PERSON_ID        1        NUMBER            22        4            0        10
        **                    1                2        PERSON_NM        1        VARCHAR2        10        0            0        0
        **                    1                3        AMOUNTS            0        TABLE                0        0            0        0
        **                    1                3                                1        NUMBER            22        0            0        0
        **                    1                4        TRANS_DATE        0        NUMBER            22        0            0        0
        **
        **
        **    OCIDPR Argument Descriptions -
        **
        **    ldadef                        - pointer to ldadef
        **    object_name            - object name, synonyms are also accepted and will
        **                                            be translate, currently only procedure and function
        **                                            names are accepted, also NLS names are accepted.
        **                                            Currently, the accepted format of a name is
        **                                            [[part1.]part2.]part3[@dblink] (required)
        **    object_length        - object name length (required)
        **    reserved1                - reserved for future use
        **    reserved1_length - reserved for future use
        **    reserved2                - reserved for future use
        **    reserved2_length - reserved for future use
        **    overload                    - array indicating overloaded procedure # (returned)
        **    position                    - array of argument positions, position 0 is a
        **                                            function return argument (returned)
        **    level                        - array of argument type levels, used to describe
        **                                            sub-datatypes of data structures like records
        **                                            and arrays (returned)
        **    argument_name        - array of argument names, only returns first
        **                                            30 characters of argument names, note storage
        **                                            for 30 characters is allocated by client (returned)
        **    argument_length    - array of argument name lengths (returned)
        **    datatype                    - array of oracle datatypes (returned)
        **    default_supplied - array indicating parameter has default (returned)
        **                                            0 = no default, 1 = default supplied
        **    in_out                        - array indicating if argument is IN or OUT (returned
        **                                            0 = IN param, 1 = OUT param, 2 = IN/OUT param
        **    length                        - array of argument lengths (returned)
        **    precision                - array of precisions (if number type)(returned)
        **    scale                        - array of scales (if number type)(returned)
        **    radix                        - array of radix (if number type)(returned)
        **    spare                        - array of spares.
        **    total_elements        - size of arrays supplied by client (required),
        **                                            total number of elements filled (returned)
        */

    extern (C) sword ocidfi (csrdef* cursor, sword pos, ub1* buf, sword bufl, sword ftype, b2* rc, sword scale);

    extern (C) sword ocidfn (csrdef* cursor, sword pos, ub1* buf, sword bufl, sword ftype, sword scale, b2* indp, oratext* fmt, sword fmtl, sword fmtt, ub2* rl, ub2* rc);

    extern (C) sword ocidfnps (csrdef* cursor, ub1 opcode, sword pos, ub1* buf, sb4 bufl, sword ftype, sword scale, b2* indp, oratext* fmt, sb4 fmtl, sword fmtt, ub2* rl, ub2* rc, sb4 pv_skip, sb4 ind_skip, sb4 len_skip, sb4 rc_skip);


        /*    Define a user data buffer using upidfn
        **        cursor    - pointer to csrdef
        **        pos            - position of a field or exp in the select list of a query
        **        bfa/bfl - address and length of client-supplied storage
                to receive data
        **        ftype        - user datatype
        **        scale        - number of fractional digits for cobol packed decimals
        **        indp        - place to store the length of the returned value. If returned
        **                            value is:
        **                            negative, the field fetched was NULL
        **                            zero        , the field fetched was same length or shorter than
        **                                the buffer provided
        **                            positive, the field fetched was truncated
        **        fmt        - format string
        **        fmtl        - length of format string, if -1 strlent(fmt) used
        **        rl            - place to store column length after each fetch
        **        rc            - place to store column error code after each fetch
        **        fmtt        - fomat type
        */

    extern (C) sword ocigetpi (csrdef* cursor, ub1* piecep, dvoid** ctxpp, ub4* iterp, ub4* indexp);
    extern (C) sword ocisetpi (csrdef* cursor, ub1 piece, dvoid* bufp, ub4* lenp);


    extern (C) sword ociexe (csrdef* cursor);
    extern (C) sword ociexn (csrdef* cursor, sword iters, sword roff);
    extern (C) sword ociefn (csrdef* cursor, ub4 nrows, sword can, sword exact);
            /*
            ** ociexe    - execute a cursor
            ** ociexn    - execute a cursosr N times
            **    cursor        - pointer to a csrdef
            **    iters        - number of times to execute cursor
            **    roff            - offset within the bind variable array at which to begin
            **                            operations.
            */

    extern (C) sword ocifet (csrdef* cursor);
    extern (C) sword ocifen (csrdef* cursor, sword nrows);
            /* ocifet - fetch the next row
            ** ocifen - fetch n rows
            ** cursor        - pointer to csrdef
            ** nrows        - number of rows to be fetched
            */

    extern (C) sword ocilng (csrdef* cursor, sword posit, ub1* bfa, sb4 bfl, sword dty, ub4* rln, sb4 off);

    extern (C) sword ocic32 (csrdef* cursor);
            /*
            **        Convert selected version 3 return codes to the equivalent
            **        version 2 code.
            **        csrdef->csrrc is set to the converted code
            **        csrdef->csrft is set to v2 oracle statment type
            **        csrdef->csrrpc is set to the rows processed count
            **        csrdef->csrpeo is set to error postion
            **
            **            cursor - pointer to csrdef
            */


    extern (C) sword ocir32 (csrdef* cursor, sword retcode);
        /*
        ** Convert selected version 3 return codes to the equivalent version 2
        ** code.
        **
        **        cursor - pointer to csrdef
        **        retcode - place to store the return code
        */


    extern (C) dvoid ociscn (sword** arglst, char* mask_addr, sword** newlst);
        /*
        ** Convert call-by-ref to call-by-value:
        ** takes an arg list and a mask address, determines which args need
        ** conversion to a value, and creates a new list begging at the address
        ** of newlst.
        **
        **        arglst        - list of arguments
        **        mast_addr _ mask address determines args needing conversion
        **        newlst        - new list of args
        */

    extern (C) eword ocistf (eword typ, eword bufl, eword rdig, oratext* fmt, csrdef* cursor, sword* err);
    /*    Convert a packed    decimal buffer    length    (bytes) and scale to a format
    **    string of the form mm.+/-nn, where    mm is the number of packed
    **    decimal digits, and nn is the scaling factor.        A positive scale name
    **    nn digits to the rights of the decimal; a negative scale means nn zeros
    **    should be supplied to the left of the decimal.
    **            bufl        - length of the packed decimal buffer
    **            rdig        - number of fractional digits
    **            fmt        - pointer to a string holding the conversion format
    **            cursor - pointer to csrdef
    **            err        - pointer to word storing error code
    */

    extern (C) sword ocinbs (ldadef* lda);    /* set a connection to non-blocking        */
    extern (C) sword ocinbt (ldadef* lda);    /* test if connection is non-blocking */
    extern (C) sword ocinbc (ldadef* lda);    /* clear a connection to blocking            */
    //extern (C) sword ocinlo (ldadef* lda, hstdef* hst, oratext* conn, sword connl, oratext* uid, sword uidl, oratext* psw, sword pswl, sword audit);    /* logon in non-blocking fashion */
    /* ocinlo allows an application to logon in non-blocking fashion.
    **        lda            - pointer to ldadef
    **        hst            - pointer to a 256 byte area, must be cleared to zero before call
    **        conn        - the database link (if specified @LINK in uid will be ignored)
    **        connl        - length of conn; if -1 strlen(conn) is used
    **        uid            - user id [USER[/PASSWORD][@LINK]]
    **        uidl        - length of uid, if -1 strlen(uid) is used
    **        psw            - password string; ignored if specified in uid
    **        pswl        - length of psw, if -1 strlen(psw) is used
    **        audit        - is not supported; the only permissible value is 0
    */

    /* Note: The following routines are used in Pro*C and have the
        same interface as their couterpart in OCI.
        Althought the interface follows for more details please refer
        to the above routines */
    extern (C) sword ocipin (ub4 mode);

    extern (C) sword ologin (ldadef* lda, b2 areacount);
    extern (C) sword ologon (ldadef* lda, b2 areacount);

    /*
    ** ocisqd - oci delayed parse (Should be used only with deferred upi/oci)
    ** FUNCTION: Call upidpr to delay the parse of the sql statement till the
    **                        time that a call needs to be made to the kernel (execution or
    **                        describe time )
    ** RETURNS: Oracle return code.
    */
    extern (C) sword ocisq7 (csrdef* cursor, oratext* sqlstm, sb4 sqllen, sword defflg, ub4 sqlt);

    extern (C) sword obind (csrdef* cursor, oratext* sqlvar, sword sqlvl, ub1* progv, sword progvl, sword ftype, sword scale, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword obindn (csrdef* cursor, ub2 sqlvn, ub1* progv, sword progvl, sword ftype, sword scale, oratext* fmt, sword fmtl, sword fmtt);

    extern (C) sword odfinn (csrdef* cursor, sword pos, ub1* buf, sword bufl, sword ftype, b2* rc, sword scale);

    extern (C) sword odsrbn (csrdef* cursor, sword pos, b2* dbsize, b2* dtype, b2* fsize);

    //extern (C) sword onblon (ldadef* lda, hstdef* hst, oratext* conn, sword connl, oratext* uid, sword uidl, oratext* psw, sword pswl, sword audit); /* logon in non-blocking fashion */

    extern (C) sword ocignfd (ldadef* lda, dvoid* nfdp);                        /* get native fd */

    extern (C) ub2 ocigft_getFcnType (ub2 oertyp);            /* get sql function code */







    enum uint VARCHAR2_TYPE        = 1;        ///
    enum uint NUMBER_TYPE            = 2;        ///
    enum uint INT_TYPE            = 3;        ///
    enum uint FLOAT_TYPE            = 4;        ///
    enum uint STRING_TYPE            = 5;        ///
    enum uint ROWID_TYPE            = 11;        ///
    enum uint DATE_TYPE            = 12;        ///

    enum uint VAR_NOT_IN_LIST        = 1007;        ///
    enum uint NO_DATA_FOUND        = 1403;        ///
    enum uint NULL_VALUE_RETURNED        = 1405;        ///

    enum uint FT_INSERT            = 3;        ///
    enum uint FT_SELECT            = 4;        ///
    enum uint FT_UPDATE            = 5;        ///
    enum uint FT_DELETE            = 9;        ///

    enum uint FC_OOPEN            = 14;        ///

    /**
    * OCI function code labels, corresponding to the fc numbers in the cursor data area.
    */
    text** oci_func_tab = [
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"OSQL",                ///
        cast(text*)"not used",                ///
        cast(text*)"OEXEC, OEXN",            ///
        cast(text*)"not used",                ///
        cast(text*)"OBIND",                ///
        cast(text*)"not used",                ///
        cast(text*)"ODEFIN",                ///
        cast(text*)"not used",                ///
        cast(text*)"ODSRBN",                ///
        cast(text*)"not used",                ///
        cast(text*)"OFETCH, OFEN",            ///
        cast(text*)"not used",                ///
        cast(text*)"OOPEN",                ///
        cast(text*)"not used",                ///
        cast(text*)"OCLOSE",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"ODSC",                ///
        cast(text*)"not used",                ///
        cast(text*)"ONAME",                ///
        cast(text*)"not used",                ///
        cast(text*)"OSQL3",                ///
        cast(text*)"not used",                ///
        cast(text*)"OBNDRV",                ///
        cast(text*)"not used",                ///
        cast(text*)"OBNDRN",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"OOPT",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"not used",                ///
        cast(text*)"OCAN",                ///
        cast(text*)"not used",                ///
        cast(text*)"OPARSE",                ///
        cast(text*)"not used",                ///
        cast(text*)"OEXFET",                ///
        cast(text*)"not used",                ///
        cast(text*)"OFLNG",                ///
        cast(text*)"not used",                ///
        cast(text*)"ODESCR",                ///
        cast(text*)"not used",                ///
        cast(text*)"OBNDRA",                ///
        cast(text*)"OBINDPS",                ///
        cast(text*)"ODEFINPS",                ///
        cast(text*)"OGETPI",                ///
        cast(text*)"OSETPI"                ///
    ];







    /**
    * The cda_head struct is strictly PRIVATE.    It is used internally only.
    * Do not use this struct in OCI programs!
    */
    package struct cda_head {
        sb2 v2_rc;                    /// V2 return code.
        ub2 ft;                        /// SQL function type.
        ub4 rpc;                    /// Rows processed count.
        ub2 peo;                    /// Parse error offset.
        ub1 fc;                        /// OCI function code.
        ub1 rcs1;                    /// Filler area.
        ub2 rc;                        /// V7 return code.
        ub1 wrn;                    /// Warning flags.
        ub1 rcs2;                    /// Reserved.
        sword rcs3;                    /// Reserved.
        struct rid {                    /// Rowid structure.
            struct rd {                ///
                ub4 rcs4;            ///
                ub2 rcs5;            ///
                ub1 rcs6;            ///
            }
            ub4 rcs7;                ///
            ub2 rcs8;                ///
        }
        sword ose;                    /// OSD dependent error.
        ub1 chk;                    ///
        dvoid* rcsp;                    /// Pointer to reserved area.
    }

    /**
    * Size of HDA area:
    *
    * 512 for 64 bit architectures
    * 256 for 32 bit architectures
    */
    version (X86) {
        enum auto HDA_SIZE = 256;
        enum auto CDA_SIZE = 64;
    } else version (X86_64) {
        enum auto HDA_SIZE = 512;
        enum auto CDA_SIZE = 88;
    } else {
        static assert (0);
    }

    /**
    * The real CDA, padded to CDA_SIZE bytes in size.
    */
    struct cda_def {
        sb2 v2_rc;                    /// V2 return code.
        ub2 ft;                        /// SQL function type.
        ub4 rpc;                    /// Rows processed count.
        ub2 peo;                    /// Parse error offset.
        ub1 fc;                        /// OCI function code.
        ub1 rcs1;                    /// Filler area.
        ub2 rc;                        /// V7 return code.
        ub1 wrn;                    /// Warning flags.
        ub1 rcs2;                    /// Reserved.
        sword rcs3;                    /// Reserved.
        struct rid {                    /// Rowid structure.
            struct rd {                ///
                ub4 rcs4;            ///
                ub2 rcs5;            ///
                ub1 rcs6;            ///
            }
            ub4 rcs7;                ///
            ub2 rcs8;                ///
        }
        sword ose;                    /// OSD dependent error.
        ub1 chk;                    ///
        dvoid* rcsp;                    /// Pointer to reserved area.
        ub1[CDA_SIZE - cda_head.sizeof] rcs9;        /// Filler.
    }
    alias cda_def Cda_Def;
    alias cda_def Lda_Def;

    enum uint OCI_EV_DEF            = 0;        /// Default single-threaded environment.
    enum uint OCI_EV_TSF            = 1;        /// Thread-safe environment.

    enum uint OCI_LM_DEF            = 0;        /// Default login.
    enum uint OCI_LM_NBL            = 1;        /// Non-blocking logon.

    enum uint OCI_ONE_PIECE        = 0;        /// There or this is the only piece.
    enum uint OCI_FIRST_PIECE        = 1;        /// The first of many pieces.
    enum uint OCI_NEXT_PIECE        = 2;        /// The next of many pieces.
    enum uint OCI_LAST_PIECE        = 3;        /// The last piece of this column.

    enum uint SQLT_CHR            = 1;        /// (ORANET TYPE) character string.
    enum uint SQLT_NUM            = 2;        /// (ORANET TYPE) oracle numeric.
    enum uint SQLT_INT            = 3;        /// (ORANET TYPE) integer.
    enum uint SQLT_FLT            = 4;        /// (ORANET TYPE) Floating point number.
    enum uint SQLT_STR            = 5;        /// Zero terminated string.
    enum uint SQLT_VNU            = 6;        /// NUM with preceding length byte.
    enum uint SQLT_PDN            = 7;        /// (ORANET TYPE) Packed Decimal Numeric.
    enum uint SQLT_LNG            = 8;        /// Long.
    enum uint SQLT_VCS            = 9;        /// Variable character string.
    enum uint SQLT_NON            = 10;        /// Null/empty PCC Descriptor entry.
    enum uint SQLT_RID            = 11;        /// Rowid.
    enum uint SQLT_DAT            = 12;        /// Date in oracle format.
    enum uint SQLT_VBI            = 15;        /// Binary in VCS format.
    enum uint SQLT_BFLOAT            = 21;        /// Native binary float.
    enum uint SQLT_BDOUBLE            = 22;        /// Native binary double.
    enum uint SQLT_BIN            = 23;        /// Binary data(DTYBIN).
    enum uint SQLT_LBI            = 24;        /// Long binary.
    enum uint SQLT_UIN            = 68;        /// Unsigned integer.
    enum uint SQLT_SLS            = 91;        /// Display sign leading separate.
    enum uint SQLT_LVC            = 94;        /// Longer longs (char).
    enum uint SQLT_LVB            = 95;        /// Longer long binary.
    enum uint SQLT_AFC            = 96;        /// Ansi fixed char.
    enum uint SQLT_AVC            = 97;        /// Ansi Var char.
    enum uint SQLT_IBFLOAT            = 100;        /// Binary float canonical.
    enum uint SQLT_IBDOUBLE        = 101;        /// Binary double canonical.
    enum uint SQLT_CUR            = 102;        /// Cursor    type.
    enum uint SQLT_RDD            = 104;        /// Rowid descriptor.
    enum uint SQLT_LAB            = 105;        /// Label type.
    enum uint SQLT_OSL            = 106;        /// Oslabel type.

    enum uint SQLT_NTY            = 108;        /// Named object type.
    enum uint SQLT_REF            = 110;        /// Ref type.
    enum uint SQLT_CLOB            = 112;        /// Character lob.
    enum uint SQLT_BLOB            = 113;        /// Binary lob.
    enum uint SQLT_BFILEE            = 114;        /// Binary file lob.
    enum uint SQLT_CFILEE            = 115;        /// Character file lob.
    enum uint SQLT_RSET            = 116;        /// Result set type.
    enum uint SQLT_NCO            = 122;        /// Named collection type (varray or nested table).
    enum uint SQLT_VST            = 155;        /// OCIString type.
    enum uint SQLT_ODT            = 156;        /// OCIDate type.

    enum uint SQLT_DATE            = 184;        /// ANSI Date.
    enum uint SQLT_TIME            = 185;        /// TIME.
    enum uint SQLT_TIME_TZ            = 186;        /// TIME WITH TIME ZONE.
    enum uint SQLT_TIMESTAMP        = 187;        /// TIMESTAMP.
    enum uint SQLT_TIMESTAMP_TZ        = 188;        /// TIMESTAMP WITH TIME ZONE.
    enum uint SQLT_INTERVAL_YM        = 189;        /// INTERVAL YEAR TO MONTH.
    enum uint SQLT_INTERVAL_DS        = 190;        /// INTERVAL DAY TO SECOND.
    enum uint SQLT_TIMESTAMP_LTZ        = 232;        /// TIMESTAMP WITH LOCAL TZ.

    enum uint SQLT_PNTY            = 241;        /// pl/sql representation of named types.

    enum uint SQLCS_IMPLICIT        = 1;        /// For CHAR, VARCHAR2, CLOB w/o a specified set.
    enum uint SQLCS_NCHAR            = 2;        /// For NCHAR, NCHAR VARYING, NCLOB.
    enum uint SQLCS_EXPLICIT        = 3;        /// For CHAR, etc, with "CHARACTER SET ..." syntax.
    enum uint SQLCS_FLEXIBLE        = 4;        /// For PL/SQL "flexible" parameters.
    enum uint SQLCS_LIT_NULL        = 5;        /// F4/29/2006or typecheck of null and empty_clob() lits.




    enum uint OCIEXTPROC_SUCCESS        = 0;        /// The external procedure failed.
    enum uint OCIEXTPROC_ERROR        = 1;        /// The external procedure succeeded.

    /**
    * The C callable interface to PL/SQL External Procedures require the
    * With-Context parameter to be passed. The type of this structure is
    * OCIExtProcContext is is opaque to the user.
    *
    * The user can declare the With-Context parameter in the application as
    *
    * OCIExtProcContext* with_context;
    */
    struct OCIExtProcContext {
    }

    /**
    * Allocate memory for the duration of the External Procedure.
    *
    * Memory thus allocated will be freed by PL/SQL upon return from the
    * External Procedure. You must not use any kind of 'free' function on
    * memory allocated by OCIExtProcAllocCallMemory.
    *
    * Params:
    *    with_context = The OCI context.
    *    amount = The number of bytes to allocate.
    *
    * Returns:
    *    A pointer to the allocated memory on success and 0 on failure.
    */
    extern (C) dvoid* ociepacm (OCIExtProcContext* with_context, size_t amount);
    alias ociepacm OCIExtProcAllocCallMemory;

    /**
    * Raise an Exception to PL/SQL.
    *
    * Calling this function signals an exception back to PL/SQL. After a
    * successful return from this function, the External Procedure must start
    * its exit handling and return back to PL/SQL. Once an exception is
    * signalled to PL/SQL, INOUT and OUT arguments, if any, are not processed
    * at all.
    *
    * Params:
    *    with_context = The OCI context.
    *    errnum = The Oracle error number to signal to PL/SQL. errnum must be in the range 1 to MAX_OEN/
    * Return :
    *    OCI_SUCCESS on success and OCI_ERROR on failure.
    */
    extern (C) size_t ocieperr (OCIExtProcContext* with_context, int error_number);
    alias ocieperr OCIExtProcRaiseExcp;

    /**
    * Raise an exception to PL/SQL. In addition, substitute the
    * following error message string within the standard Oracle error
    * message string. See note for OCIExtProcRaiseExcp
    *
    * Params:
    *    with_context = The OCI context.
    *    errnum = The Oracle error number to signal to PL/SQL. errnum must be in the range 1 to MAX_OEN.
    *    errmsg = The error message associated with the errnum.
    *    len = The length of the error message 0 for anull terminated string.
    *
    * Returns:
    *    OCI_SUCCESS on success and OCI_ERROR on failure.
    *
    */
    extern (C) size_t ociepmsg (OCIExtProcContext* with_context, int error_number, oratext* error_message, size_t len);
    alias ociepmsg OCIExtProcRaiseExcpWithMsg;

    /**
    * Get the OCI environment.
    *
    * Params:
    *    with_context = The OCI context.
    *    envh = The OCI environment handle.
    *    svch = The OCI service handle.
    *    errh = The OCI error handle.
    *
    * Returns:
    *    OCI_SUCCESS on success and OCI_ERROR on failure.
    */
    extern (C) sword ociepgoe (OCIExtProcContext* with_context, OCIEnv** envh, OCISvcCtx** svch, OCIError** errh);
    alias ociepgoe OCIExtProcGetEnv;

    /**
    * Initialize a statement handle.
    *
    * Params:
    *    with_context = The OCI context.
    *    cursorno = The cursor number for which we need to initialize the statement handle.
    *    svch = The OCI service handle.
    *    stmthp = The OCI statement handle.
    *    errh = The OCI error handle.
    *
    * Returns:
    *    OCI_SUCCESS on success and OCI_ERROR on failure.
    *
    * Bugs:
    *    The parameter types were guessed.    This should be fixed in future releases.
    */
    extern (C) sword ociepish (OCIExtProcContext* with_context, int cursorno, OCISvcCtx** svch, OCIStmt** stmthp, OCIError** errh);
    alias ociepish OCIInitializeStatementHandle;




    /**
    *
    */
    struct xmlctx {
    }

    /**
    *
    */
    enum ocixmldbpname {
        XCTXINIT_OCIDUR    = 1,                ///
        XCTXINIT_ERRHDL    = 2                ///
    }

    /**
    *
    */
    struct ocixmldbparam {
        ocixmldbpname name_ocixmldbparam;        ///
        void* value_ocixmldbparam;            ///
    }

    enum uint NUM_OCIXMLDBPARAMS        = 2;        ///

    /**
    * Get a xmlctx structure initialized with error-handler and XDB callbacks.
    *
    * Params:
    *    envhp = The OCI environment handle.
    *    svchp = The OCI service handle.
    *    errhp = The OCI error handle.
    *    params = Contains the following optional parameters :
    *        (a) OCIDuration dur
    *            The OCI Duration.    Defaults to OCI_DURATION_SESSION.
    *        (b) void function(sword, oratext*) err_handler
    *            Pointer to the error handling function.    Defaults to null.
    *
    * Returns:
    *    A pointer to an xmlctx structure, with xdb context, error handler and callbacks
    *    populated with appropriate values. This is later used for all API calls.    null
    *    if no database connection is available.
    */
    extern (C) xmlctx* OCIXmlDbInitXmlCtx (OCIEnv* envhp, OCISvcCtx* svchp, OCIError* err, ocixmldbparam* params, int num_params);

    /**
    * Free any allocations done during OCIXmlDbInitXmlCtx.
    *
    * Params:
    *    xctx = The xmlctx to terminate.
    */
    extern (C) void OCIXmlDbFreeXmlCtx (xmlctx* xctx);



    enum uint ODCI_SUCCESS            = 0;        ///
    enum uint ODCI_ERROR            = 1;        ///
    enum uint ODCI_WARNING            = 2;        ///
    enum uint ODCI_ERROR_CONTINUE        = 3;        ///
    enum uint ODCI_FATAL            = 4;        ///

    enum uint ODCI_PRED_EXACT_MATCH    = 0x0001;    ///
    enum uint ODCI_PRED_PREFIX_MATCH    = 0x0002;    ///
    enum uint ODCI_PRED_INCLUDE_START    = 0x0004;    ///
    enum uint ODCI_PRED_INCLUDE_STOP    = 0x0008;    ///
    enum uint ODCI_PRED_OBJECT_FUNC    = 0x0010;    ///
    enum uint ODCI_PRED_OBJECT_PKG        = 0x0020;    ///
    enum uint ODCI_PRED_OBJECT_TYPE    = 0x0040;    ///
    enum uint ODCI_PRED_MULTI_TABLE    = 0x0080;    ///

    enum uint ODCI_QUERY_FIRST_ROWS    = 0x01;        ///
    enum uint ODCI_QUERY_ALL_ROWS        = 0x02;        ///
    enum uint ODCI_QUERY_SORT_ASC        = 0x04;        ///
    enum uint ODCI_QUERY_SORT_DESC        = 0x08;        ///
    enum uint ODCI_QUERY_BLOCKING        = 0x10;        ///

    enum uint ODCI_CLEANUP_CALL        = 1;        ///
    enum uint ODCI_REGULAR_CALL        = 2;        ///

    enum uint ODCI_OBJECT_FUNC        = 0x01;        ///
    enum uint ODCI_OBJECT_PKG        = 0x02;        ///
    enum uint ODCI_OBJECT_TYPE        = 0x04;        ///

    enum uint ODCI_ARG_OTHER        = 1;        ///
    enum uint ODCI_ARG_COL            = 2;        /// Column.
    enum uint ODCI_ARG_LIT            = 3;        /// Literal.
    enum uint ODCI_ARG_ATTR        = 4;        /// Object attribute.
    enum uint ODCI_ARG_NULL        = 5;        ///
    enum uint ODCI_ARG_CURSOR        = 6;        ///

    enum uint ODCI_ARG_DESC_LIST_MAXSIZE    = 32767;    /// Maximum size of ODCIArgDescList array.

    enum uint ODCI_PERCENT_OPTION        = 1;        ///
    enum uint ODCI_ROW_OPTION        = 2;        ///

    enum uint ODCI_ESTIMATE_STATS        = 0x01;        ///
    enum uint ODCI_COMPUTE_STATS        = 0x02;        ///
    enum uint ODCI_VALIDATE        = 0x04;        ///

    enum uint ODCI_ALTIDX_NONE        = 0;        ///
    enum uint ODCI_ALTIDX_RENAME        = 1;        ///
    enum uint ODCI_ALTIDX_REBUILD        = 2;        ///
    enum uint ODCI_ALTIDX_REBUILD_ONL    = 3;        ///
    enum uint ODCI_ALTIDX_MODIFY_COL    = 4;        ///
    enum uint ODCI_ALTIDX_UPDATE_BLOCK_REFS= 5;        ///

    enum uint ODCI_INDEX_LOCAL        = 0x0001;    ///
    enum uint ODCI_INDEX_RANGE_PARTN    = 0x0002;    ///
    enum uint ODCI_INDEX_HASH_PARTN    = 0x0004;    ///
    enum uint ODCI_INDEX_ONLINE        = 0x0008;    ///
    enum uint ODCI_INDEX_PARALLEL        = 0x0010;    ///
    enum uint ODCI_INDEX_UNUSABLE        = 0x0020;    ///
    enum uint ODCI_INDEX_ONIOT        = 0x0040;    ///
    enum uint ODCI_INDEX_TRANS_TBLSPC    = 0x0080;    ///
    enum uint ODCI_INDEX_FUNCTION_IDX    = 0x0100;    ///

    enum uint ODCI_INDEX_DEFAULT_DEGREE    = 32767;    ///

    enum uint ODCI_DEBUGGING_ON        = 0x01;        ///

    enum uint ODCI_CALL_NONE        = 0;        ///
    enum uint ODCI_CALL_FIRST        = 1;        ///
    enum uint ODCI_CALL_INTERMEDIATE    = 2;        ///
    enum uint ODCI_CALL_FINAL        = 3;        ///

    enum uint ODCI_EXTTABLE_INFO_OPCODE_FETCH = 1;        ///
    enum uint ODCI_EXTTABLE_INFO_OPCODE_POPULATE = 2;    ///

    enum uint ODCI_EXTTABLE_INFO_FLAG_SAMPLE = 0x00000001;    ///
    enum uint ODCI_EXTTABLE_INFO_FLAG_SAMPLE_BLOCK = 0x00000002; ///
    enum uint ODCI_EXTTABLE_INFO_FLAG_ACCESS_PARM_CLOB = 0x00000004; ///
    enum uint ODCI_EXTTABLE_INFO_FLAG_ACCESS_PARM_BLOB = 0x00000008; ///

    enum uint ODCI_TRUE            = 1;        ///
    enum uint ODCI_FALSE            = 0;        ///

    enum uint ODCI_EXTTABLE_OPEN_FLAGS_QC    = 0x00000001;    /// Caller is Query Coord.
    enum uint ODCI_EXTTABLE_OPEN_FLAGS_SHADOW = 0x00000002;/// Caller is shadow proc.
    enum uint ODCI_EXTTABLE_OPEN_FLAGS_SLAVE = 0x00000004;    /// Caller is slave proc.

    enum uint ODCI_EXTTABLE_FETCH_FLAGS_EOS= 0x00000001;    /// End-of-stream on fetch.

    enum uint ODCI_AGGREGATE_REUSE_CTX    = 1;        /// Constants for Flags argument to ODCIAggregateTerminate.


    struct ODCIColInfo {
        OCIString* TableSchema;                ///
        OCIString* TableName;                ///
        OCIString* ColName;                ///
        OCIString* ColTypName;                ///
        OCIString* ColTypSchema;            ///
        OCIString* TablePartition;            ///
    }

    /**
    *
    */
    struct ODCIColInfo_ind {
        OCIInd atomic;                    ///
        OCIInd TableSchema;                ///
        OCIInd TableName;                ///
        OCIInd ColName;                    ///
        OCIInd ColTypName;                ///
        OCIInd ColTypSchema;                ///
        OCIInd TablePartition;                ///
    }

    /**
    *
    */
    struct ODCIFuncCallInfo {
        ODCIColInfo ColInfo;                ///
    }

    /**
    *
    */
    struct ODCIFuncCallInfo_ind {
        ODCIColInfo_ind ColInfo;            ///
    }

    /**
    *
    */
    struct ODCIIndexInfo {
        OCIString* IndexSchema;                ///
        OCIString* IndexName;                ///
        ODCIColInfoList* IndexCols;            ///
        OCIString* IndexPartition;            ///
        OCINumber IndexInfoFlags;            ///
        OCINumber IndexParaDegree;            ///
    }

    /**
    *
    */
    struct ODCIIndexInfo_ind {
        OCIInd atomic;                    ///
        OCIInd IndexSchema;                ///
        OCIInd IndexName;                ///
        OCIInd IndexCols;                ///
        OCIInd IndexPartition;                ///
        OCIInd IndexInfoFlags;                ///
        OCIInd IndexParaDegree;                ///
    }

    /**
    *
    */
    struct ODCIPredInfo {
        OCIString* ObjectSchema;            ///
        OCIString* ObjectName;                ///
        OCIString* MethodName;                ///
        OCINumber Flags;                ///
    }

    /**
    *
    */
    struct ODCIPredInfo_ind {
        OCIInd atomic;                    ///
        OCIInd ObjectSchema;                ///
        OCIInd ObjectName;                ///
        OCIInd MethodName;                ///
        OCIInd Flags;                    ///
    }

    /**
    *
    */
    struct ODCIObject {
        OCIString* ObjectSchema;            ///
        OCIString* ObjectName;                ///
    }

    /**
    *
    */
    struct ODCIObject_ind {
        OCIInd atomic;                    ///
        OCIInd ObjectSchema;                ///
        OCIInd ObjectName;                ///
    }

    /**
    *
    */
    struct ODCIQueryInfo {
        OCINumber Flags;                ///
        ODCIObjectList* AncOps;                ///
    }

    /**
    *
    */
    struct ODCIQueryInfo_ind {
        OCIInd atomic;                    ///
        OCIInd Flags;                    ///
        OCIInd AncOps;                    ///
    }

    /**
    *
    */
    struct ODCIIndexCtx {
        ODCIIndexInfo IndexInfo;            ///
        OCIString* Rid;                    ///
        ODCIQueryInfo QueryInfo;            ///
    }

    /**
    *
    */
    struct ODCIIndexCtx_ind {
        OCIInd atomic;                    ///
        ODCIIndexInfo_ind IndexInfo;            ///
        OCIInd Rid;                    ///
        ODCIQueryInfo_ind QueryInfo;            ///
    }

    /**
    *
    */
    struct ODCIFuncInfo {
        OCIString* ObjectSchema;            ///
        OCIString* ObjectName;                ///
        OCIString* MethodName;                ///
        OCINumber Flags;                ///
    }

    /**
    *
    */
    struct ODCIFuncInfo_ind {
        OCIInd atomic;                    ///
        OCIInd ObjectSchema;                ///
        OCIInd ObjectName;                ///
        OCIInd MethodName;                ///
        OCIInd Flags;                    ///
    }

    /**
    *
    */
    struct ODCICost {
        OCINumber CPUcost;                ///
        OCINumber IOcost;                ///
        OCINumber NetworkCost;                ///
        OCIString* IndexCostInfo;            ///
    }

    /**
    *
    */
    struct ODCICost_ind {
        OCIInd atomic;                    ///
        OCIInd CPUcost;                    ///
        OCIInd IOcost;                    ///
        OCIInd NetworkCost;                ///
        OCIInd IndexCostInfo;                ///
    }

    /**
    *
    */
    struct ODCIArgDesc {
        OCINumber    ArgType;                    ///
        OCIString* TableName;                ///
        OCIString* TableSchema;                ///
        OCIString* ColName;                    ///
        OCIString* TablePartitionLower;            ///
        OCIString* TablePartitionUpper;            ///
        OCINumber    Cardinality;                ///
    }

    /**
    *
    */
    struct ODCIArgDesc_ind {
        OCIInd atomic;                    ///
        OCIInd ArgType;                    ///
        OCIInd TableName;                ///
        OCIInd TableSchema;                ///
        OCIInd ColName;                    ///
        OCIInd TablePartitionLower;            ///
        OCIInd TablePartitionUpper;            ///
        OCIInd Cardinality;                ///
    }

    /**
    *
    */
    struct ODCIStatsOptions {
        OCINumber Sample;                ///
        OCINumber Options;                ///
        OCINumber Flags;                ///
    }

    /**
    *
    */
    struct ODCIStatsOptions_ind {
        OCIInd atomic;                    ///
        OCIInd Sample;                    ///
        OCIInd Options;                    ///
        OCIInd Flags;                    ///
    }

    /**
    *
    */
    struct ODCIEnv {
        OCINumber EnvFlags;                ///
        OCINumber CallProperty;                ///
        OCINumber DebugLevel;                ///
        OCINumber CursorNum;                ///
    }

    /**
    *
    */
    struct ODCIEnv_ind {
        OCIInd _atomic;                    ///
        OCIInd EnvFlags;                ///
        OCIInd CallProperty;                ///
        OCIInd DebugLevel;                ///
        OCIInd CursorNum;                ///
    }

    /**
    *
    */
    struct ODCIPartInfo {
        OCIString* TablePartition;            ///
        OCIString* IndexPartition;            ///
    }

    /**
    *
    */
    struct ODCIPartInfo_ind {
        OCIInd atomic;                    ///
        OCIInd TablePartition;                ///
        OCIInd IndexPartition;                ///
    }

    /**
    * External Tables.
    */
    struct ODCIExtTableInfo {
        OCIString* TableSchema;                ///
        OCIString* TableName;                ///
        ODCIColInfoList* RefCols;            ///
        OCIClobLocator* AccessParmClob;            ///
        OCIBlobLocator* AccessParmBlob;            ///
        ODCIArgDescList* Locations;            ///
        ODCIArgDescList* Directories;            ///
        OCIString* DefaultDirectory;            ///
        OCIString* DriverType;                ///
        OCINumber OpCode;                ///
        OCINumber AgentNum;                ///
        OCINumber GranuleSize;                ///
        OCINumber Flag;                    ///
        OCINumber SamplePercent;            ///
        OCINumber MaxDoP;                ///
        OCIRaw* SharedBuf;                ///
        OCIString* MTableName;                ///
        OCIString* MTableSchema;            ///
        OCINumber TableObjNo;                ///
    }

    /**
    * ditto
    */
    struct ODCIExtTableInfo_ind {
        OCIInd _atomic;                    ///
        OCIInd TableSchema;                ///
        OCIInd TableName;                ///
        OCIInd RefCols;                    ///
        OCIInd AccessParmClob;                ///
        OCIInd AccessParmBlob;                ///
        OCIInd Locations;                ///
        OCIInd Directories;                ///
        OCIInd DefaultDirectory;            ///
        OCIInd DriverType;                ///
        OCIInd OpCode;                    ///
        OCIInd AgentNum;                ///
        OCIInd GranuleSize;                ///
        OCIInd Flag;                    ///
        OCIInd SamplePercent;                ///
        OCIInd MaxDoP;                    ///
        OCIInd SharedBuf;                ///
        OCIInd MTableName;                ///
        OCIInd MTableSchema;                ///
        OCIInd TableObjNo;                ///
    }

    /**
    * ditto
    */
    struct ODCIExtTableQCInfo {
        OCINumber NumGranules;                ///
        OCINumber NumLocations;                ///
        ODCIGranuleList* GranuleInfo;            ///
        OCINumber IntraSourceConcurrency;        ///
        OCINumber MaxDoP;                ///
        OCIRaw* SharedBuf;                ///
    }

    /**
    * ditto
    */
    struct ODCIExtTableQCInfo_ind {
        OCIInd _atomic;                    ///
        OCIInd NumGranules;                ///
        OCIInd NumLocations;                ///
        OCIInd GranuleInfo;                ///
        OCIInd IntraSourceConcurrency;            ///
        OCIInd MaxDoP;                    ///
        OCIInd SharedBuf;                ///
    }

    /**
    * Table Function Info types (used by ODCITablePrepare).
    */
    struct ODCITabFuncInfo {
        ODCINumberList* Attrs;                ///
        OCIType* RetType;                ///
    }

    /**
    * ditto
    */
    struct ODCITabFuncInfo_ind {
        OCIInd _atomic;                    ///
        OCIInd Attrs;                    ///
        OCIInd RetType;                    ///
    }

    /**
    * Table Function Statistics types (used by ODCIStatsTableFunction).
    */
    struct ODCITabFuncStats {
        OCINumber num_rows;                ///
    }

    /**
    * ditto
    */
    struct ODCITabFuncStats_ind {
        OCIInd _atomic;                    ///
        OCIInd num_rows;                ///
    }






    /**
    * Create an instance of an object.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    svc = OCI service handle.
    *    typecode =
    *    tdo =
    *    table =
    *    duration =
    *    value = Use TRUE for a value or. FALSE for an object.    Ignored if the instance isn't an object.
    *    instance = A pointer to the pointer to the new object.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIObjectNew (OCIEnv* env, OCIError* err, OCISvcCtx* svc, OCITypeCode typecode, OCIType* tdo, dvoid* table, OCIDuration duration, boolean value, dvoid** instance);
    /*
        typecode (IN) - the typecode of the type of the instance.
        tdo            (IN, optional) - pointer to the type descriptor object. The
                TDO describes the type of the instance that is to be
                created. Refer to OCITypeByName() for obtaining a TDO.
                The TDO is required for creating a named type (e.g. an
                object or a collection).
        table (IN, optional) - pointer to a table object which specifies a
                table in the server.    This parameter can be set to NULL
                if no table is given. See the description below to find
                out how the table object and the TDO are used together
                to determine the kind of instances (persistent,
                transient, value) to be created. Also see
                OCIObjectPinTable() for retrieving a table object.
        duration (IN) - this is an overloaded parameter. The use of this
                parameter is based on the kind of the instance that is
                to be created.
                a) persistent object. This parameter specifies the
                    pin duration.
                b) transient object. This parameter specififes the
                    allocation duration and pin duration.
                c) value. This parameter specifies the allocation
                    duration.

        DESCRIPTION:
        This function creates a new instance of the type specified by the
        typecode or the TDO. Based on the parameters 'typecode' (or 'tdo'),
        'value' and 'table', different kinds of instances can be created:

                            The parameter 'table' is not NULL?

                                    yes                            no
                ----------------------------------------------------------------
                | object type (value=TRUE)        |        value                    |        value                |
                ----------------------------------------------------------------
                | object type (value=FALSE)    | persistent obj    | transient obj |
                type    ----------------------------------------------------------------
                | built-in type                            |        value                    |        value                |
                ----------------------------------------------------------------
                | collection type                        |        value                    |        value                |
                ----------------------------------------------------------------

        This function allocates the top level memory chunk of an OTS instance.
        The attributes in the top level memory are initialized (e.g. an
        attribute of varchar2 is initialized to a vstring of 0 length).

        If the instance is an object, the object is marked existed but is
        atomically null.

        FOR PERSISTENT OBJECTS:
        The object is marked dirty and existed.    The allocation duration for
        the object is session. The object is pinned and the pin duration is
        specified by the given parameter 'duration'.

        FOR TRANSIENT OBJECTS:
        The object is pinned. The allocation duration and the pin duration are
        specified by the given parameter 'duration'.

        FOR VALUES:
        The allocation duration is specified by the given parameter 'duration'.
    */

    extern (C) sword OCIObjectPin (OCIEnv* env, OCIError* err, OCIRef* object_ref, OCIComplexObject* corhdl, OCIPinOpt pin_option, OCIDuration pin_duration, OCILockOpt lock_option, dvoid** object);
    /*
        NAME: OCIObjectPin - OCI pin a referenceable object
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                            recorded in 'err' and this function returns
                            OCI_ERROR. The error recorded in 'err' can be
                            retrieved by calling OCIErrorGet().
        object_ref            (IN) - the reference to the object.
        corhdl                    (IN) - handle for complex object retrieval.
        pin_option            (IN) - See description below.
        pin_duration        (IN) - The duration of which the object is being accesed
                            by a client. The object is implicitly unpinned at
                            the end of the pin duration.
                            If OCI_DURATION_NULL is passed, there is no pin
                            promotion if the object is already loaded into
                            the cache. If the object is not yet loaded, then
                            the pin duration is set to OCI_DURATION_DEFAULT.
        lock_option        (IN) - lock option (e.g., exclusive). If a lock option
                            is specified, the object is locked in the server.
                            See 'oro.h' for description about lock option.
        object                (OUT) - the pointer to the pinned object.

        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:

        This function pins a referenceable object instance given the object
        reference. The process of pinning serves three purposes:

        1) locate an object given its reference. This is done by the object
            cache which keeps track of the objects in the object heap.

        2) notify the object cache that an object is being in use. An object
            can be pinned many times. A pinned object will remain in memory
            until it is completely unpinned (see OCIObjectUnpin()).

        3) notify the object cache that a persistent object is being in use
            such that the persistent object cannot be aged out.    Since a
            persistent object can be loaded from the server whenever is needed,
            the memory utilization can be increased if a completely unpinned
            persistent object can be freed (aged out), even before the
            allocation duration is expired.

        Also see OCIObjectUnpin() for more information about unpinning.

        FOR PERSISTENT OBJECTS:

        When pinning a persistent object, if it is not in the cache, the object
        will be fetched from the persistent store. The allocation duration of
        the object is session. If the object is already in the cache, it is
        returned to the client.    The object will be locked in the server if a
        lock option is specified.

        This function will return an error for a non-existent object.

        A pin option is used to specify the copy of the object that is to be
        retrieved:

        1) If option is OCI_PIN_ANY (pin any), if the object is already
            in the environment heap, return this object. Otherwise, the object
            is retrieved from the database.    This option is useful when the
            client knows that he has the exclusive access to the data in a
            session.

        2) If option is OCI_PIN_LATEST (pin latest), if the object is
            not cached, it is retrieved from the database.    If the object is
            cached, it is refreshed with the latest version. See
            OCIObjectRefresh() for more information about refreshing.

        3) If option is OCI_PIN_RECENT (pin recent), if the object is loaded
            into the cache in the current transaction, the object is returned.
            If the object is not loaded in the current transaction, the object
            is refreshed from the server.

        FOR TRANSIENT OBJECTS:

        This function will return an error if the transient object has already
        been freed. This function does not return an error if an exclusive
        lock is specified in the lock option.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectUnpin (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectUnpin - OCI unpin a referenceable object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to an object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function unpins an object.    An object is completely unpinned when
            1) the object was unpinned N times after it has been pinned N times
                (by calling OCIObjectPin()).
            2) it is the end of the pin duration
            3) the function OCIObjectPinCountReset() is called

        There is a pin count associated with each object which is incremented
        whenever an object is pinned. When the pin count of the object is zero,
        the object is said to be completely unpinned. An unpinned object can
        be freed without error.

        FOR PERSISTENT OBJECTS:
        When a persistent object is completely unpinned, it becomes a candidate
        for aging. The memory of an object is freed when it is aged out. Aging
        is used to maximize the utilization of memory.    An dirty object cannot
        be aged out unless it is flushed.

        FOR TRANSIENT OBJECTS:
        The pin count of the object is decremented. A transient can be freed
        only at the end of its allocation duration or when it is explicitly
        deleted by calling OCIObjectFree().

        FOR VALUE:
        This function will return an error for value.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectPinCountReset (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectPinCountReset - OCI resets the pin count of a referenceable
                        object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to an object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function completely unpins an object.    When an object is
        completely unpinned, it can be freed without error.

        FOR PERSISTENT OBJECTS:
        When a persistent object is completely unpinned, it becomes a candidate
        for aging. The memory of an object is freed when it is aged out. Aging
        is used to maximize the utilization of memory.    An dirty object cannot
        be aged out unless it is flushed.

        FOR TRANSIENT OBJECTS:
        The pin count of the object is decremented. A transient can be freed
        only at the end of its allocation duration or when it is explicitly
        freed by calling OCIObjectFree().

        FOR VALUE:
        This function will return an error for value.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectLock (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectLock - OCI lock a persistent object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function locks a persistent object at the server. Unlike
        OCIObjectLockNoWait() this function waits if another user currently
        holds a lock on the desired object. This function
        returns an error if:
            1) the object is non-existent.

        This function will return an error for transient objects and values.
        The lock of an object is released at the end of a transaction.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectLockNoWait (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectLockNoWait - OCI lock a persistent object, do not wait for
                            the lock, return error if lock not available
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function locks a persistent object at the server. Unlike
        OCIObjectLock() this function will not wait if another user holds
        the lock on the desired object. This function returns an error if:
            1) the object is non-existent.
            2) the object is currently locked by another user in which
                case this function returns with an error.

        This function will return an error for transient objects and values.
        The lock of an object is released at the end of a transaction.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectMarkUpdate (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectMarkUpdate - OCI marks an object as updated
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        FOR PERSISTENT OBJECTS:
        This function marks the specified persistent object as updated. The
        persistent objects will be written to the server when the object cache
        is flushed.    The object is not locked or flushed by this function. It
        is an error to update a deleted object.

        After an object is marked updated and flushed, this function must be
        called again to mark the object as updated if it has been dirtied
        after it is being flushed.

        FOR TRANSIENT OBJECTS:
        This function marks the specified transient object as updated. The
        transient objects will NOT be written to the server. It is an error
        to update a deleted object.

        FOR VALUES:
        It is an no-op for values.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectUnmark (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectUnmark - OCI unmarks an object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        object        (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        FOR PERSISTENT OBJECTS AND TRANSIENT OBJECTS:
        This function unmarks the specified persistent object as dirty. Changes
        that are made to the object will not be written to the server. If the
        object is marked locked, it remains marked locked.    The changes that
        have already made to the object will not be undone implicitly.

        FOR VALUES:
        It is an no-op for values.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectUnmarkByRef (OCIEnv* env, OCIError* err, OCIRef*);
    /*
        NAME: OCIObjectUnmarkByRef - OCI unmarks an object by Ref
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by
                calling OCIErrorGet().
        ref        (IN) - reference of the object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        FOR PERSISTENT OBJECTS AND TRANSIENT OBJECTS:
        This function unmarks the specified persistent object as dirty. Changes
        that are made to the object will not be written to the server. If the
        object is marked locked, it remains marked locked.    The changes that
        have already made to the object will not be undone implicitly.

        FOR VALUES:
        It is an no-op for values.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectFree (OCIEnv* env, OCIError* err, dvoid* instance, ub2 flags);
    /*
        NAME: OCIObjectFree - OCI free (and unpin) an standalone instance
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        instance        (IN) - pointer to a standalone instance.
        flags            (IN) - If OCI_OBJECT_FREE_FORCE is set, free the object
                    even if it is pinned or dirty.
                    If OCI_OBJECT_FREE_NONULL is set, the null
                    structure will not be freed.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The instance to be freed must be standalone.
        - If the instance is a referenceable object, the object must be pinned.
        DESCRIPTION:
        This function deallocates all the memory allocated for an OTS instance,
        including the null structure.

        FOR PERSISTENT OBJECTS:
        This function will return an error if the client is attempting to free
        a dirty persistent object that has not been flushed. The client should
        either flush the persistent object or set the parameter 'flag' to
        OCI_OBJECT_FREE_FORCE.

        This function will call OCIObjectUnpin() once to check if the object
        can be completely unpin. If it succeeds, the rest of the function will
        proceed to free the object.    If it fails, then an error is returned
        unless the parameter 'flag' is set to OCI_OBJECT_FREE_FORCE.

        Freeing a persistent object in memory will not change the persistent
        state of that object at the server.    For example, the object will
        remain locked after the object is freed.

        FOR TRANSIENT OBJECTS:

        This function will call OCIObjectUnpin() once to check if the object
        can be completely unpin. If it succeeds, the rest of the function will
        proceed to free the object.    If it fails, then an error is returned
        unless the parameter 'flag' is set to OCI_OBJECT_FREE_FORCE.

        FOR VALUES:
        The memory of the object is freed immediately.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectMarkDeleteByRef (OCIEnv* env, OCIError* err, OCIRef* object_ref);
    /*
        NAME: OCIObjectMarkDeleteByRef - OCI "delete" (and unpin) an object given
                            a reference
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        object_ref    (IN) - ref of the object to be deleted

        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        This function marks the object designated by 'object_ref' as deleted.

        FOR PERSISTENT OBJECTS:
        If the object is not loaded, then a temporary object is created and is
        marked deleted. Otherwise, the object is marked deleted.

        The object is deleted in the server when the object is flushed.

        FOR TRANSIENT OBJECTS:
        The object is marked deleted.    The object is not freed until it is
        unpinned.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectMarkDelete (OCIEnv* env, OCIError* err, dvoid* instance);
    /*
        NAME: OCIObjectMarkDelete - OCI "delete" an instance given a Pointer
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        instance        (IN) - pointer to the instance
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The instance must be standalone.
        - If the instance is a referenceable object, then it must be pinned.
        DESCRIPTION:

        FOR PERSISTENT OBJECTS:
        The object is marked deleted.    The memory of the object is not freed.
        The object is deleted in the server when the object is flushed.

        FOR TRANSIENT OBJECTS:
        The object is marked deleted.    The memory of the object is not freed.

        FOR VALUES:
        This function frees a value immediately.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectFlush (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectFlush - OCI flush a persistent object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        object            (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function flushes a modified persistent object to the server.
        An exclusive lock is obtained implicitly for the object when flushed.

        When the object is written to the server, triggers may be fired.
        Objects can be modified by the triggers at the server.    To keep the
        objects in the object cache being coherent with the database, the
        clients can free or refresh the objects in the cache.

        This function will return an error for transient objects and values.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectRefresh (OCIEnv* env, OCIError* err, dvoid* object);
    /*
        NAME: OCIObjectRefresh - OCI refresh a persistent object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        object            (IN) - pointer to the persistent object
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        DESCRIPTION:
        This function refreshes an unmarked object with data retrieved from the
        latest snapshot in the server. An object should be refreshed when the
        objects in the cache are inconsistent with the objects at
        the server:
        1) When an object is flushed to the server, triggers can be fired to
            modify more objects in the server.    The same objects (modified by
            the triggers) in the object cache become obsolete.
        2) When the user issues a SQL or executes a PL/SQL procedure to modify
            any object in the server, the same object in the cache becomes
            obsolete.

        The object that is refreshed will be 'replaced-in-place'. When an
        object is 'replaced-in-place', the top level memory of the object will
        be reused so that new data can be loaded into the same memory address.
        The top level memory of the null structre is also reused. Unlike the
        top level memory chunk, the secondary memory chunks may be resized and
        reallocated.    The client should be careful when holding onto a pointer
        to the secondary memory chunk (e.g. assigning the address of a
        secondary memory to a local variable), since this pointer can become
        invalid after the object is refreshed.

        The object state will be modified as followed after being refreshed:
            - existent : set to appropriate value
            - pinned        : unchanged
            - allocation duration : unchanged
            - pin duration : unchanged

        This function is an no-op for transient objects or values.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectCopy (OCIEnv* env, OCIError* err, OCISvcCtx* svc, dvoid* source, dvoid* null_source, dvoid* target, dvoid* null_target, OCIType* tdo, OCIDuration duration, ub1 option);
    /*
        NAME: OCIObjectCopy - OCI copy one instance to another
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        svc                    (IN) - OCI service context handle
        source            (IN) - pointer to the source instance
        null_source (IN) - pointer to the null structure of the source
        target            (IN) - pointer to the target instance
        null_target (IN) - pointer to the null structure of the target
        tdo                    (IN) - the TDO for both source and target
        duration        (IN) - allocation duration of the target memory
        option            (IN) - specify the copy option:
                OROOCOSFN - Set Reference to Null. All references
                in the source will not be copied to the target. The
                references in the target are set to null.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - If source or target is referenceable, it must be pinned.
        - The target or the containing instance of the target must be already
            be instantiated (e.g. created by OCIObjectNew()).
        - The source and target instances must be of the same type. If the
            source and target are located in a different databases, then the
            same type must exist in both databases.
        DESCRIPTION:
        This function copies the contents of the 'source' instance to the
        'target' instance. This function performs a deep-copy such that the
        data that is copied/duplicated include:
        a) all the top level attributes (see the exceptions below)
        b) all the secondary memory (of the source) that is reachable from the
            top level attributes.
        c) the null structure of the instance

        Memory is allocated with the specified allocation duration.

        Certain data items are not copied:
        a) If the option OCI_OBJECTCOPY_NOREF is specified, then all references
            in the source are not copied. Instead, the references in the target
            are set to null.
        b) If the attribute is a LOB, then it is set to null.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectGetTypeRef (OCIEnv* env, OCIError* err, dvoid* instance, OCIRef* type_ref);
    /*
        NAME: OCIObjectGetTypeRef - get the type reference of a standalone object
        PARAMETERS:
        env        (IN/OUT) - OCI environment handle initialized in object mode
        err        (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns
                OCI_ERROR.    The error recorded in 'err' can be
                retrieved by calling OCIErrorGet().
        instance    (IN) - pointer to an standalone instance
        type_ref (OUT) - reference to the type of the object.    The reference
                must already be allocated.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The instance must be standalone.
        - If the object is referenceable, the specified object must be pinned.
        - The reference must already be allocated.
        DESCRIPTION:
        This function returns a reference to the TDO of a standalone instance.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectGetObjectRef (OCIEnv* env, OCIError* err, dvoid* object, OCIRef* object_ref);
    /*
        NAME: OCIObjectGetObjectRef - OCI get the object reference of an
                    referenceable object
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        object            (IN) - pointer to a persistent object
        object_ref (OUT) - reference of the given object. The reference must
                    already be allocated.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified object must be pinned.
        - The reference must already be allocated.
        DESCRIPTION:
        This function returns a reference to the given object.    It returns an
        error for values.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectMakeObjectRef (OCIEnv* env, OCIError* err, OCISvcCtx* svc, dvoid* table, dvoid** values, ub4 array_len, OCIRef* object_ref);
    /*
        NAME: OCIObjectMakeObjectRef - OCI Create an object reference to a
                    referenceable object.
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        svc                    (IN) - the service context
        table                (IN) - A pointer to the table object (must be pinned)
        attrlist        (IN) - A list of values (OCI type values) from which
                    the ref is to be created.
        attrcnt            (IN)    - The length of the attrlist array.
        object_ref (OUT) - reference of the given object. The reference must
                    already be allocated.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified table object must be pinned.
        - The reference must already be allocated.
        DESCRIPTION:
        This function creates a reference given the values that make up the
        reference and also a pointer to the table object.
        Based on the table's OID property, whether it is a pk based OID or
        a system generated OID, the function creates a sys-generated REF or
        a pk based REF.
        In case of system generated REFs pass in a OCIRaw which is 16 bytes
        long contatining the sys generated OID.
        In case of PK refs pass in the OCI equivalent for numbers, chars etc..
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectGetPrimaryKeyTypeRef (OCIEnv* env, OCIError* err, OCISvcCtx* svc, dvoid* table, OCIRef* type_ref );
    /*
        NAME: OCIObjectGetPrimaryKeyTypeRef - OCI get the REF to the pk OID type
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        svc            (IN)            - the service context
        table        (IN)            - pointer to the table object
        type_ref        (OUT) - reference of the pk type. The reference must
                    already be allocated.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The specified table object must be pinned.
        - The reference must already be allocated.
        DESCRIPTION:
        This function returns a reference to the pk type.    It returns an
        error for values.    If the table is not a Pk oid table/view, then
        it returns error.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectGetInd (OCIEnv* env, OCIError* err, dvoid* instance, dvoid** null_struct);
    /*
        NAME: OCIObjectGetInd - OCI get the null structure of a standalone object
        PARAMETERS:
        env            (IN/OUT) - OCI environment handle initialized in object mode
        err            (IN/OUT) - error handle. If there is an error, it is
                    recorded in 'err' and this function returns
                    OCI_ERROR.    The error recorded in 'err' can be
                    retrieved by calling OCIErrorGet().
        instance            (IN) - pointer to the instance
        null_struct (OUT) - null structure
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The object must be standalone.
        - If the object is referenceable, the specified object must be pinned.
        DESCRIPTION:
        This function returns the null structure of an instance. This function
        will allocate the top level memory of the null structure if it is not
        already allocated. If an null structure cannot be allocated for the
        instance, then an error is returned. This function only works for
        ADT or row type instance.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectExists (OCIEnv* env, OCIError* err, dvoid* ins, boolean* exist);
    /*
        NAME: OCIObjectExist - OCI checks if the object exists
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        ins                        (IN) - pointer to an instance
        exist                (OUT) - return TRUE if the object exists
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The object must be standalone.
        - if object is a referenceable, it must be pinned.
        DESCRIPTION:
        This function returns the existence of an instance. If the instance
        is a value, this function always returns TRUE.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectGetProperty (OCIEnv* envh, OCIError* errh, dvoid* obj, OCIObjectPropId propertyId, dvoid *property, ub4* size );
    /*
        NAME: OCIObjectGetProperty - OCIObject Get Property of given object
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        obj                        (IN) - object whose property is returned
        propertyId        (IN) - id which identifies the desired property
        property            (OUT) - buffer into which the desired property is
                        copied
        size            (IN/OUT) - on input specifies the size of the property buffer
                        passed by caller, on output will contain the
                        size in bytes of the property returned.
                        This parameter is required for string type
                        properties only (e.g OCI_OBJECTPROP_SCHEMA,
                        OCI_OBJECTPROP_TABLE). For non-string
                        properties this parameter is ignored since
                        the size is fixed.
        DESCRIPTION:
        This function returns the specified property of the object.
        The desired property is identified by 'propertyId'. The property
        value is copied into 'property' and for string typed properties
        the string size is returned via 'size'.

        Objects are classified as persistent, transient and value
        depending upon the lifetime and referenceability of the object.
        Some of the properties are applicable only to persistent
        objects and some others only apply to persistent and
        transient objects. An error is returned if the user tries to
        get a property which in not applicable to the given object.
        To avoid such an error, the user should first check whether
        the object is persistent or transient or value
        (OCI_OBJECTPROP_LIFETIME property) and then appropriately
        query for other properties.

        The different property ids and the corresponding type of
        'property' argument is given below.

            OCI_OBJECTPROP_LIFETIME
                This identifies whether the given object is a persistent
                object (OCI_OBJECT_PERSISTENT) or a
                transient object (OCI_OBJECT_TRANSIENT) or a
                value instance (OCI_OBJECT_VALUE).
                'property' argument must be a pointer to a variable of
                type OCIObjectLifetime.

            OCI_OBJECTPROP_SCHEMA
                This returns the schema name of the table in which the
                object exists. An error is returned if the given object
                points to a transient instance or a value. If the input
                buffer is not big enough to hold the schema name an error
                is returned, the error message will communicate the
                required size. Upon success, the size of the returned
                schema name in bytes is returned via 'size'.
                'property' argument must be an array of type text and 'size'
                should be set to size of array in bytes by the caller.

            OCI_OBJECTPROP_TABLE
                This returns the table name in which the object exists. An
                error is returned if the given object points to a
                transient instance or a value. If the input buffer is not
                big enough to hold the table name an error is returned,
                the error message will communicate the required size. Upon
                success, the size of the returned table name in bytes is
                returned via 'size'. 'property' argument must be an array
                of type text and 'size' should be set to size of array in
                bytes by the caller.

            OCI_OBJECTPROP_PIN_DURATION
                This returns the pin duration of the object.
                An error is returned if the given object points to a value
                instance. Valid pin durations are: OCI_DURATION_SESSION and
                OCI_DURATION_TRANS.
                'property' argument must be a pointer to a variable of type
                OCIDuration.

            OCI_OBJECTPROP_ALLOC_DURATION
                This returns the allocation duration of the object.
                Valid allocation durations are: OCI_DURATION_SESSION and
                OCI_DURATION_TRANS.
                'property' argument must be a pointer to a variable of type
                OCIDuration.

            OCI_OBJECTPROP_LOCK
                This returns the lock status of the
                object. The possible lock status is enumerated by OCILockOpt.
                An error is returned if the given object points to a transient
                or value instance.
                'property' argument must be a pointer to a variable of
                type OCILockOpt.
                Note, the lock status of an object can also be retrieved by
                calling OCIObjectIsLocked().

            OCI_OBJECTPROP_MARKSTATUS
                This returns the status flag which indicates whether the
                object is a new object, updated object and/or deleted object.
                The following macros can be used to test the mark status
                flag:

                    OCI_OBJECT_IS_UPDATED(flag)
                    OCI_OBJECT_IS_DELETED(flag)
                    OCI_OBJECT_IS_NEW(flag)
                    OCI_OBJECT_IS_DIRTY(flag)

                An object is dirty if it is a new object or marked deleted or
                marked updated.
                An error is returned if the given object points to a transient
                or value instance. 'property' argument must be of type
                OCIObjectMarkStatus.

            OCI_OBJECTPROP_VIEW
                This identifies whether the specified object is a view object
                or not. If property value returned is TRUE, it indicates the
                object is a view otherwise it is not.
                'property' argument must be of type boolean.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR. Possible errors are TBD
    */

    extern (C) sword OCIObjectIsLocked (OCIEnv* env, OCIError* err, dvoid* ins, boolean* lock);
    /*
        NAME: OCIObjectIsLocked - OCI get the lock status of a standalone object
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        ins                        (IN) - pointer to an instance
        lock                    (OUT) - return value for the lock status.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The instance must be standalone.
        - If the object is referenceable, the specified object must be pinned.
        DESCRIPTION:
        This function returns the lock status of an instance. If the instance
        is a value, this function always returns FALSE.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectIsDirty (OCIEnv* env, OCIError* err, dvoid* ins, boolean* dirty);
    /*
        NAME: OCIObjectIsDirty - OCI get the dirty status of a standalone object
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        ins                        (IN) - pointer to an instance
        dirty                (OUT) - return value for the dirty status.
        REQUIRES:
        - a valid OCI environment handle must be given.
        - The instance must be standalone.
        - if instance is an object, the instance must be pinned.
        DESCRIPTION:
        This function returns the dirty status of an instance. If the instance
        is a value, this function always returns FALSE.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectPinTable (OCIEnv* env, OCIError* err, OCISvcCtx* svc, oratext* schema_name, ub4 s_n_length, oratext* object_name, ub4 o_n_length, OCIRef* scope_obj_ref, OCIDuration pin_duration, dvoid** object);
    /*
        NAME: OCIObjectPinTable - OCI get table object
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc                                            (IN) - OCI service context handle
        schema_name        (IN, optional) - schema name of the table
        s_n_length        (IN, optional) - length of the schema name
        object_name        (IN) - name of the table
        o_n_length        (IN) - length of the table name
        scope_obj_ref (IN, optional) - reference of the scoping object
        pin_duration    (IN) - pin duration. See description in OCIObjectPin().
        object                (OUT) - the pinned table object
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        This function pin a table object with the specified pin duration.
        The client can unpin the object by calling OCIObjectUnpin(). See
        OCIObjectPin() and OCIObjectUnpin() for more information about pinning
        and unpinning.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIObjectArrayPin (OCIEnv* env, OCIError* err, OCIRef** ref_array, ub4 array_size, OCIComplexObject** cor_array, ub4 cor_array_size, OCIPinOpt pin_option, OCIDuration pin_duration, OCILockOpt lock, dvoid** obj_array, ub4* pos);
    /*
        NAME: OCIObjectArrayPin - ORIO array pin
        PARAMETERS:
        env                (IN/OUT) - OCI environment handle initialized in object mode
        err                (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        ref_array            (IN) - array of references to be pinned
        array_size        (IN) - number of elements in the array of references
        pin_option        (IN) - pin option. See OCIObjectPin().
        pin_duration    (IN) - pin duration. See OCIObjectPin().
        lock_option        (IN) - lock option. See OCIObjectPin().
        obj_array        (OUT) - If this argument is not NULL, the pinned objects
                        will be returned in the array. The user must
                        allocate this array with element type being
                        'dvoid *'. The size of this array is identical to
                        'array'.
        pos                    (OUT) - If there is an error, this argument will contain
                        the element that is causing the error.    Note that
                        this argument is set to 1 for the first element in
                        the ref_array.
        REQUIRE:
        - a valid OCI environment handle must be given.
        - If 'obj_array' is not NULL, then it must already be allocated and
                the size of 'obj_array' is 'array_size'.
        DESCRIPTION:
        This function pin an array of references.    All the pinned objects are
        retrieved from the database in one network roundtrip.    If the user
        specifies an output array ('obj_array'), then the address of the
        pinned objects will be assigned to the elements in the array. See
        OCIObjectPin() for more information about pinning.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCICacheFlush (OCIEnv* env, OCIError* err, OCISvcCtx* svc, dvoid* context, OCIRef* function(dvoid* context, ub1* last) get, OCIRef**);
    /*
        NAME: OCICacheFlush - OCI flush persistent objects
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc            (IN) [optional] - OCI service context.    If null pointer is
                        specified, then the dirty objects in all connections
                        will be flushed.
        context    (IN) [optional] - specifies an user context that is an
                        argument to the client callback function 'get'. This
                        parameter is set to NULL if there is no user context.
        get            (IN) [optional] - an client-defined function which acts an
                        iterator to retrieve a batch of dirty objects that need
                        to be flushed. If the function is not NULL, this function
                        will be called to get a reference of a dirty object.
                        This is repeated until a null reference is returned by
                        the client function or the parameter 'last' is set to
                        TRUE. The parameter 'context' is passed to get()
                        for each invocation of the client function.    This
                        parameter should be NULL if user callback is not given.
                        If the object that is returned by the client function is
                        not a dirtied persistent object, the object is ignored.
                        All the objects that are returned from the client
                        function must be from newed or pinned the same service
                        context, otherwise, an error is signalled. Note that the
                        returned objects are flushed in the order in which they
                        are marked dirty.
        ref            (OUT) [optional] - if there is an error in flushing the
                        objects, (*ref) will point to the object that
                        is causing the error.    If 'ref' is NULL, then the object
                        will not be returned.    If '*ref' is NULL, then a
                        reference will be allocated and set to point to the
                        object.    If '*ref' is not NULL, then the reference of
                        the object is copied into the given space. If the
                        error is not caused by any of the dirtied object,
                        the given ref is initalized to be a NULL reference
                        (OCIRefIsNull(*ref) is TRUE).
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        This function flushes the modified persistent objects from the
        environment heap to the server. The objects are flushed in the order
        that they are marked updated or deleted.

        See OCIObjectFlush() for more information about flushing.

        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCICacheresh (OCIEnv* env, OCIError* err, OCISvcCtx* svc, OCIRefreshOpt option, dvoid* context, OCIRef* function(dvoid* context) get, OCIRef** );
    /*
        NAME: OCICacheRefresh - OCI ReFreSh persistent objects
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc            (IN) [optional] - OCI service context.    If null pointer is
                        specified, then the persistent objects in all connections
                        will be refreshed.
        option        (IN) [optional] - if OCI_REFRESH_LOAD is specified, all
                        objects that is loaded within the transaction are
                        refreshed. If the option is OCI_REFERSH_LOAD and the
                        parameter 'get' is not NULL, this function will ignore
                        the parameter.
        context    (IN) [optional] - specifies an user context that is an
                        argument to the client callback function 'get'. This
                        parameter is set to NULL if there is no user context.
        get            (IN) [optional] - an client-defined function which acts an
                        iterator to retrieve a batch of objects that need to be
                        refreshed. If the function is not NULL, this function
                        will be called to get a reference of an object.    If
                        the reference is not NULL, then the object will be
                        refreshed.    These steps are repeated until a null
                        reference is returned by this function.    The parameter
                        'context' is passed to get() for each invocation of the
                        client function.    This parameter should be NULL if user
                        callback is not given.
        ref            (OUT) [optional] - if there is an error in refreshing the
                        objects, (*ref) will point to the object that
                        is causing the error.    If 'ref' is NULL, then the object
                        will not be returned.    If '*ref' is NULL, then a
                        reference will be allocated and set to point to the
                        object.    If '*ref' is not NULL, then the reference of
                        the object is copied into the given space. If the
                        error is not caused by any of the object,
                        the given ref is initalized to be a NULL reference
                        (OCIRefIsNull(*ref) is TRUE).
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        This function refreshes all pinned persistent objects. All unpinned
        persistent objects are freed.    See OCIObjectRefresh() for more
        information about refreshing.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCICacheUnpin (OCIEnv* env, OCIError* err, OCISvcCtx* svc);
    /*
        NAME: OCICacheUnpin - OCI UNPin objects
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc            (IN) [optional] - OCI service context. If null pointer is
                        specified, then the objects in all connections
                        will be unpinned.
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        If a connection is specified, this function completely unpins the
        persistent objects in that connection. Otherwise, all persistent
        objects in the heap are completely unpinned. All transient objects in
        the heap are also completely unpinned. See OCIObjectUnpin() for more
        information about unpinning.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCICacheFree (OCIEnv* env, OCIError* err, OCISvcCtx* svc);
    /*
        NAME: OCICacheFree - OCI FREe instances
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc            (IN) [optional] - OCI service context. If null pointer is
                        specified, then the objects in all connections
                        will be freed.
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        If a connection is specified, this function frees the persistent
        objects, transient objects and values allocated for that connection.
        Otherwise, all persistent objects, transient objects and values in the
        heap are freed. Objects are freed regardless of their pin count.    See
        OCIObjectFree() for more information about freeing an instance.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCICacheUnmark (OCIEnv* env, OCIError* err, OCISvcCtx* svc);
    /*
        NAME: OCICacheUnmark - OCI Unmark all dirty objects
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
                        recorded in 'err' and this function returns
                        OCI_ERROR.    The error recorded in 'err' can be
                        retrieved by calling OCIErrorGet().
        svc            (IN) [optional] - OCI service context. If null pointer is
                        specified, then the objects in all connections
                        will be unmarked.
        REQUIRES:
        - a valid OCI environment handle must be given.
        DESCRIPTION:
        If a connection is specified, this function unmarks all dirty objects
        in that connection.    Otherwise, all dirty objects in the cache are
        unmarked. See OCIObjectUnmark() for more information about unmarking
        an object.
        RETURNS:
        if environment handle or error handle is null, return
        OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIDurationBegin (OCIEnv* env, OCIError* err, OCISvcCtx* svc, OCIDuration parent, OCIDuration* dur);
    /*
        NAME: OCIDurationBegin - OCI DURATION BEGIN
        PARAMETERS:
        env    (IN/OUT) - OCI environment handle initialized in object mode
                This should be passed NULL, when cartridge services
                are to be used.
        err    (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by calling
                        OCIErrorGet().
        svc    (IN/OUT) - OCI service handle.
        parent        (IN) - parent for the duration to be started.
        dur            (OUT) - newly created user duration
        REQUIRES:
        - a valid OCI environment handle must be given for non-cartridge
            services.
        - For cartridge services, NULL should be given for environment handle
        - A valid service handle must be given in all cases.
        DESCRIPTION:
        This function starts a new user duration.    A user can have multiple
        active user durations simultaneously. The user durations do not have
        to be nested.

        The object subsystem predefines 3 durations :
            1) session            - memory allocated with session duration comes from
                    the UGA heap (OCI_DURATION_SESSION). A session
                    duration terminates at the end of the user session.
            2) transaction - memory allocated with transaction duration comes
                    from the UGA heap (OCI_DURATION_TRANS). A trans-
                    action duration terminates at the end of the user
                    transaction.
            3) call                - memory allocated with call duration comes from PGA
                    heap (OCI_DURATION_CALL). A call duration terminates
                    at the end of the user call.

        Each user duration has a parent duration.    A parent duration can be a
        predefined duration or another user duration.    The relationship between
        a user duration and its parent duration (child duration) are:

        1) An user duration is nested within the parent duration. When its
                parent duration terminates, the user duration will also terminate.
        2) The memory allocated with an user duration comes from the heap of
                its parent duration. For example, if the parent duration of an
                user duration is call, then the memory allocated with the user
                duration will also come from the PGA heap.

        This function can be used as both part of cartridge services as well
        as without cartridge services.
        The difference in the function in the case of cartridge and
        non-cartridge services is:
            In case of cartridge services, as descibed above a new user
        duration is created as a child of the "parent" duration.
            But when used for non-cartridge purposes, when a pre-defined
        duration is passed in as parent, it is mapped to the cache duration
        for that connection (which is created if not already present) and
        the new user duration will be child of the cache duration.

        RETURNS:
        if environment handle and service handle is null or if error
        handle is null return OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    extern (C) sword OCIDurationEnd (OCIEnv* env, OCIError* err, OCISvcCtx* svc, OCIDuration duration);
    /*
        NAME: OCIDurationEnd - OCI DURATION END
        PARAMETERS:
        env    (IN/OUT) - OCI environment handle initialized in object mode
                This should be passed NULL, when cartridge services
                are to be used.
        err    (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by calling
                        OCIErrorGet().
        svc    (IN/OUT) - OCI service handle.
        dur            (OUT) - a previously created user duration using
                OCIDurationBegin()
        REQUIRES:
        - a valid OCI environment handle must be given for non-cartridge
            services.
        - For cartridge services, NULL should be given for environment handle
        - A valid service handle must be given in all cases.
        DESCRIPTION:
        This function terminates a user duration.    All memory allocated for
        this duration is freed.

        This function can be used as both part of cartridge services as well
        as without cartridge services.    In both cased, the heap duration
        is freed and all the allocated memory for that duration is freed.
        The difference in the function in the case of cartridge and
        non-cartridge services is:
            In case of non-cartridge services, if the duration is pre-
        defined, the associated cache duration (see OCIDurationBegin())
        is also terminated and the following is done.
            1) The child durations are terminated.
            2) All objects pinned for this duration are unpinned.
            3) All instances allocated for this duration are freed.

            In case of cartridge services, only the heap duration is
        freed.    All the context entries allocated for that duration are
        freed from the context hash table..

        RETURNS:
        if environment handle and service handle is null or if error
        handle is null return OCI_INVALID_HANDLE.
        if operation suceeds, return OCI_SUCCESS.
        if operation fails, return OCI_ERROR.
    */

    /**
    * Set an attribute of an object.
    *
    * Params:
    *    env = The OCI enviroment handle initialized in object mode.
    *    err = The error handle.
    *    instance = An _instance of an ADT structure.
    *    null_struct = The null structure of instance.
    *    tdo = The TDO of the object.
    *    names = An array of attribute names specifying the names of the attributes in a path expression.
    *    lengths = The lengths of the elements in names.
    *    name_count = The number of elements in names.
    *    indexes = Not currently used.    Pass 0.
    *    index_count = Not currently used.    Pass 0.
    *    attr_null_status = The null status of the attribute if it is a primitive.
    *    attr_null_struct = The null structure of an ADT structure of collection attribute.
    *    attr_value = The attribute value.
    *
    * Returns:
    *    An OROSTA structure.
    */
    extern (C) sword OCIObjectSetAttr (OCIEnv* env, OCIError* err, dvoid* instance, dvoid* null_struct, OCIType* tdo, oratext** names, ub4* lengths, ub4 name_count, ub4* indexes, ub4 index_count, OCIInd null_status, dvoid* attr_null_struct, dvoid* attr_value);

    /**
    * Get an attribute of an object.
    *
    * Params:
    *    env = The OCI enviroment handle initialized in object mode.
    *    err = The error handle.
    *    instance = An _instance of an ADT structure.
    *    null_struct = The null structure of instance.
    *    tdo = The TDO of the object.
    *    names = An array of attribute names specifying the names of the attributes in a path expression.
    *    lengths = The lengths of the elements in names.
    *    name_count = The number of elements in names.
    *    indexes = Not currently used.    Pass 0.
    *    index_count = Not currently used.    Pass 0.
    *    attr_null_status = The null status of the attribute if it is a primitive.
    *    attr_null_struct = The null structure of an ADT structure of collection attribute.
    *    attr_value = The attribute value.
    *    attr_tdo = The TDO of the attribute.
    *
    * Returns:
    *    An OROSTA structure.
    */
    extern (C) sword OCIObjectGetAttr (OCIEnv* env, OCIError* err, dvoid* instance, dvoid* null_struct, OCIType* tdo, oratext** names, ub4* lengths, ub4 name_count,    ub4* indexes, ub4 index_count, OCIInd* attr_null_status, dvoid** attr_null_struct, dvoid** attr_value, OCIType** attr_tdo);


    enum uint OCI_NUMBER_SIZE        = 22;        /// The number of bytes in an OCINumber.

    /**
    * OCI Number mapping in C.
    *
    * The OTS types: NUMBER, NUMERIC, INT, SHORTINT, REAL, DOUBLE PRECISION,
    * FLOAT and DECIMAL are represented by OCINumber.
    *
    * The contents of OCINumber is opaque to clients.
    *
    * For binding variables of type OCINumber in OCI calls (OCIBindByName(),
    * OCIBindByPos(), and OCIDefineByPos()) use the type code SQLT_VNU.
    */
    struct OCINumber {
        ub1[OCI_NUMBER_SIZE] OCINumberPart;
    }

    /**
    * Increment a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the positive OCI _number to increment.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberInc (OCIError* err, OCINumber* number);

    /**
    * Decrement a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the positive OCI _number to decrement.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberDec (OCIError* err, OCINumber* number);

    /**
    * Set a _number to 0.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to set to 0.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) void OCINumberSetZero (OCIError* err, OCINumber* num);

    /**
    * Set a _number to pi.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to set to pi.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) void OCINumberSetPi (OCIError *err, OCINumber *num);

    /**
    * Add one number to another.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the first operand.
    *    number2 = A pointer to the OCI number of the second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberAdd (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * Subtract one number from another.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the first operand.
    *    number2 = A pointer to the OCI number of the second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberSub (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * Multiply one number by another.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the first operand.
    *    number2 = A pointer to the OCI number of the second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberMul (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * Divide one number by another.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the first operand.
    *    number2 = A pointer to the OCI number of the second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberDiv (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * The remainder when one number is divided by another.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the first operand.
    *    number2 = A pointer to the OCI number of the second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberMod (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * Raise a number to an integral power.
    *
    * Params:
    *    err = OCI error handle.
    *    base = A pointer to the OCI number of the first operand.
    *    exp = The second operand.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberIntPower (OCIError* err, OCINumber* base, sword exp, OCINumber* result);

    /**
    * Multiply a _number by a power of 10.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number of the first operand.
    *    nDig = The number of repetitions.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberShift (OCIError* err, OCINumber* number, sword nDig, OCINumber* result);

    /**
    * Negate a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to negate.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberNeg (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Convert a _number to a string.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to convert.
    *    fmt = The conversion format.
    *    fmt_length = The length of fmt.
    *    nls_params = The NLS format specification.    Use 0 for default.
    *    nls_p_length = The length of nls_params.
    *    buf_size = The size of the buffer, used as both input and output.
    *    buf = A buffer to place the result of the conversion in.
    *
    * See_Also:
    *    Refer to the Oracle SQL Language Reference Manual for more details on fmt and nls_params.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberToText (OCIError* err, OCINumber* number, oratext* fmt, ub4 fmt_length, oratext* nls_params, ub4 nls_p_length, ub4* buf_size, oratext* buf);

    /**
    * Convert a string to a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    str = The string to convert.
    *    str_length = The length of str.
    *    fmt = The conversion format.
    *    fmt_length = The length of fmt.
    *    nls_params = The NLS format specification.    Use 0 for default.
    *    nls_p_length = The length of nls_params.
    *    number = A pointer to the OCI _number to put the _result in.
    *
    * See_Also:
    *    Refer to the Oracle SQL Language Reference Manual for more details on fmt and nls_params.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberFromText (OCIError* err, oratext* str, ub4 str_length, oratext* fmt, ub4 fmt_length, oratext* nls_params, ub4 nls_p_length, OCINumber* number);

    enum uint OCI_NUMBER_UNSIGNED        = 0;        /// Unsigned type -- ubX.
    enum uint OCI_NUMBER_SIGNED        = 2;        /// Signed type -- sbX.

    /**
    * Convert a _number to an integer.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to convert.
    *    rsl_length = The number of bytes in rsl.
    *    rsl_s_flag = Either OCI_NUMBER_UNSIGNED or OCI_NUMBER_SIGNED.
    *    rsl = A pointer to space for the result.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberToInt (OCIError* err, OCINumber* number, uword rsl_length, uword rsl_flag, dvoid* rsl);

    /**
    * Convert an integer to a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    inum = A pointer to the integer to convert.
    *    inum_length = The number of bytes in inum.
    *    inum_s_flag = Either OCI_NUMBER_UNSIGNED or OCI_NUMBER_SIGNED.
    *    number = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberFromInt (OCIError* err, dvoid* inum, uword inum_length, uword inum_s_flag, OCINumber* number);

    /**
    * Convert a _number to a real.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to convert.
    *    rsl_length = The number of bytes in the result.
    *    rsl = A pointer to space for the result.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberToReal (OCIError* err, OCINumber* number, uword rsl_length, dvoid* rsl);

    /**
    * Convert an array of _number to an array of reals.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the array of OCI numbers to convert.
    *    elems = The number of OCI numbers to convert.
    *    rsl_length = The number of bytes in the result.
    *    rsl = A pointer to space for the result.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberToRealArray (OCIError* err, OCINumber** number, uword elems, uword rsl_length, dvoid* rsl);

    /**
    * Convert a real to a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    rnum = A pointer to the real to convert.
    *    rnum_length = The number of bytes in the rnum.
    *    number = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberFromReal (OCIError* err, dvoid* rnum, uword rnum_length, OCINumber* number);

    /**
    * Compare two numbers.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the first OCI number.
    *    number2 = A pointer to the second OCI number.
    *    result = The _result.    0 if equal, negative if less than, or positive if greater than.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberCmp (OCIError* err, OCINumber* number1, OCINumber* number2, sword* result);

    /**
    * Get the sign of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to check.
    *    result = The _result.    0 if 0, -1 if negative, or 1 if positive.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberSign (OCIError* err, OCINumber* number, sword* result);

    /**
    * Check if a _number is 0.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to check.
    *    result = TRUE if it is or FALSE otherwise.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberIsZero (OCIError* err, OCINumber* number, boolean* result);

    /**
    * Check if a _number is an integer.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to check.
    *    result = TRUE if it is or FALSE otherwise.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberIsInt (OCIError* err, OCINumber* number, boolean* result);

    /**
    * Copy a number.
    *
    * Params:
    *    err = OCI error handle.
    *    from = A pointer _to the source OCI number.
    *    to = A pointer _to the target OCI number.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberAssign (OCIError* err, OCINumber* from, OCINumber* to);

    /**
    * Get the absolute value of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the absolute value of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberAbs (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Round a _number up.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to round.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    //extern (C) sword OCINumberCeil(OCIError* err, OCINumber* number, OCINumber*);

    /**
    * Round a _number down.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to round.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberFloor (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the square root of a _number..
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to square root.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberSqrt (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Truncate a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to truncate
    *    decplace = The _number of digits to the right of the decimal to keep.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberTrunc (OCIError* err, OCINumber* number, sword decplace, OCINumber* result);

    /**
    * Raise a _number to a power.
    *
    * Params:
    *    err = OCI error handle.
    *    base = A pointer to the OCI _number to raise to number.
    *    number = A pointer to the OCI _number of the exponent.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberPower (OCIError* err, OCINumber* base, OCINumber* number, OCINumber* result);

    /**
    * Round a _number to a specified decimal place.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to round.
    *    decplace = The _number of digits to the right of the decimal to keep.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberRound (OCIError* err, OCINumber* number, sword decplace, OCINumber* result);

    /**
    * Round a _number to a specified decimal place.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to round.
    *    decplace = The _number of digits to keep.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberPrec (OCIError* err, OCINumber* number, eword nDigs, OCINumber* result);

    /**
    * Take the sine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the sine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberSin (OCIError *err, OCINumber* number, OCINumber* result);

    /**
    * Take the inverse sine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the inverse sine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberArcSin (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the hyperbolic sine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the hyperbolic sine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberHypSin (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the cosine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the cosine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberCos (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the inverse cosine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the inverse cosine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberArcCos (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the hyperbolic cosine of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the hyperbolic cosine of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberHypCos (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the tangent of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the tangent of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberTan (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the inverse tangent of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the inverse tangent of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberArcTan (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the inverse tangent of a number.
    *
    * Params:
    *    err = OCI error handle.
    *    number1 = A pointer to the OCI number of the numerator.
    *    number2 = A pointer to the OCI number of the denominator.
    *    result = A pointer to the OCI number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberArcTan2 (OCIError* err, OCINumber* number1, OCINumber* number2, OCINumber* result);

    /**
    * Take the hyperbolic tangent of a _number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the hyperbolic tangent of.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberHypTan (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Raise e to a power.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number of the exponent.
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberExp (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the natural logarithm of a number.
    *
    * Params:
    *    err = OCI error handle.
    *    number = A pointer to the OCI _number to take the natural logarithm of..
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberLn (OCIError* err, OCINumber* number, OCINumber* result);

    /**
    * Take the logarithm of a number in any base.
    *
    * Params:
    *    err = OCI error handle.
    *    base = A pointer to the OCI _number representing the base.
    *    number = A pointer to the OCI _number to take the logarithm of..
    *    result = A pointer to the OCI _number to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCINumberLog (OCIError* err, OCINumber* base, OCINumber* number, OCINumber* result);

    /**
    * OCI time portion of date.
    *
    * This structure should be treated as an opaque structure as the format
    * of this structure may change. Use OCIDateGetTime/OCIDateSetTime
    * to manipulate time portion of OCIDate.
    */
    struct OCITime {
        ub1 OCITimeHH;                    /// Hours; range is 0 <= hours <= 23.
        ub1 OCITimeMI;                    /// Minutes; range is 0 <= minutes <= 59.
        ub1 OCITimeSS;                    /// Seconds; range is 0 <= seconds <= 59.
    }

    /**
    * OCI date representation.
    *
    * This structure should be treated as an opaque structure as the format
    * of this structure may change. Use OCIDateGetDate/OCIDateSetDate
    * to access/initialize OCIDate.
    *
    * For binding variables of type OCIDate in OCI calls (OCIBindByName(),
    * OCIBindByPos(), and OCIDefineByPos()) use the type code SQLT_ODT.
    */
    struct OCIDate {
        sb2 OCIDateYYYY;                /// Gregorian year; range is -4712 <= year <= 9999.
        ub1 OCIDateMM;                    /// Month; range is 1 <= month <= 12.
        ub1 OCIDateDD;                    /// Day; range is 1 <= day <= 31.
        OCITime OCIDateTime;                /// Time.
    }

    /**
    * Get the time portion of a _date.
    *
    * Params:
    *    date = A pointer to the OCI _date to get the time from.
    *    hour = The _hour portion of date.
    *    min = The minute portion of date.
    *    sec = The second portion of date.
    */
    void OCIDateGetTime (OCIDate* date, ub1* hour, ub1* min, ub1* sec) {
        *hour = date.OCIDateTime.OCITimeHH;
        *min = date.OCIDateTime.OCITimeMI;
        *sec = date.OCIDateTime.OCITimeSS;
    }

    /**
    * Get the _date portion of a _date.
    *
    * Params:
    *    date = A pointer to the OCI _date to get the time from.
    *    year = The _year portion of date.
    *    month = The _month portion of date.
    *    day = The _day portion of date.
    */
    void OCIDateGetDate (OCIDate* date, sb2* year, ub1* month, ub1* day) {
        *year = date.OCIDateYYYY;
        *month = date.OCIDateMM;
        *day = date.OCIDateDD;
    }

    /**
    * Set the time portion of a _date.
    *
    * Params:
    *    date = A pointer to the OCI _date to set the time of.
    *    hour = The _hour portion of date.
    *    min = The minute portion of date.
    *    sec = The second portion of date.
    */
    void OCIDateSetTime (OCIDate* date, ub1 hour, ub1 min, ub1 sec) {
        date.OCIDateTime.OCITimeHH = hour;
        date.OCIDateTime.OCITimeMI = min;
        date.OCIDateTime.OCITimeSS = sec;
    }

    /**
    * Set the _date portion of a _date.
    *
    * Params:
    *    date = A pointer to the OCI _date to set the time of.
    *    year = The _year portion of date.
    *    month = The _month portion of date.
    *    day = The _day portion of date.
    */
    void OCIDateSetDate (OCIDate* date, sb2 year, ub1 month, ub1 day) {
        date.OCIDateYYYY = year;
        date.OCIDateMM = month;
        date.OCIDateDD = day;
    }

    /**
    * Copy a date.
    *
    * Params:
    *    err = OCI error handle.
    *    from = A pointer _to the source OCI date.
    *    to = A pointer _to the target OCI date.
    *
    * Returns:
    *    OCI_SUCCESS.
    */
    extern (C) sword OCIDateAssign (OCIError* err, OCIDate* from, OCIDate* to);

    /**
    * Convert a _date to a string.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI _date to convert.
    *    fmt = The conversion format.    Defaults to "DD-Mon-YY."
    *    fmt_length = The length of fmt.
    *    lang_name = The language to use for names.    Defaults to the session language.
    *    lang_length = The length of lang_name
    *    buf_size = The size of the buffer, used as both input and output.
    *    buf = A buffer to place the result of the conversion in.
    *
    * See_Also:
    *    Refer to the Oracle SQL Language Reference Manual for more details on fmt and nls_params.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateToText (OCIError* err, OCIDate* date, oratext* fmt, ub1 fmt_length, oratext* lang_name, ub4 lang_length, ub4* buf_size, oratext* buf);

    /**
    * Convert a string to a _date.
    *
    * Params:
    *    err = OCI error handle.
    *    date_str = The string to convert.
    *    d_str_length = The length of str.
    *    fmt = The conversion format.    Defaults to "DD-Mon-YY."
    *    fmt_length = The length of fmt.
    *    lang_name = The language to use for names.    Defaults to the session language.
    *    lang_length = The length of lang_name
    *    date = A pointer to the OCI _date to place the result of the conversion in.
    *
    * See_Also:
    *    Refer to the Oracle SQL Language Reference Manual for more details on fmt and nls_params.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateFromText (OCIError* err, oratext* date_str, ub4 d_str_length, oratext* fmt, ub1 fmt_length, oratext* lang_name, ub4 lang_length, OCIDate* date);

    /**
    * Compare two dates.
    *
    * Params:
    *    err = OCI error handle.
    *    date1 = A pointer to the first OCI date.
    *    date2 = A pointer to the second OCI date.
    *    result = The _result.    0 if equal, -1 if less than, or 1 if greater than.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateCompare (OCIError* err, OCIDate* date1, OCIDate* date2, sword* result);

    /**
    * Add months to a _date.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI date to add to.
    *    num_months = The number of months to move.
    *    result = A pointer to the OCI _date to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateAddMonths (OCIError* err, OCIDate* date, sb4 num_months, OCIDate* result);

    /**
    * Add days to a _date.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI date to add to.
    *    num_days = The number of days to move.
    *    result = A pointer to the OCI _date to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateAddDays (OCIError* err, OCIDate* date, sb4 num_days, OCIDate* result);

    /**
    * Get the last day of the current month of a _date.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI date to use.
    *    last_day = A pointer to the OCI _date to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateLastDay (OCIError* err, OCIDate* date, OCIDate* last_day);

    /**
    * Get the number of days between two dates.
    *
    * Params:
    *    err = OCI error handle.
    *    date1 = A pointer to the first OCI date.
    *    date2 = A pointer to the second OCI date.
    *    num_days = The number of days between date1 and date2.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateDaysBetween (OCIError* err, OCIDate* date1, OCIDate* date2, sb4* num_days);

    /**
    * Change a date from one time zone to another.
    *
    * Params:
    *    err = OCI error handle.
    *    date1 = A pointer to the OCI date in time zone zon1.
    *    zon1 = The time zone of date1.
    *    zon1_length = The length of zon1.
    *    zon2 = The time zone of date2.
    *    zon2_length = The length of zon2.
    *    date2 = A pointer to the OCI _date to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateZoneToZone (OCIError* err, OCIDate* date1, oratext* zon1, ub4 zon1_length, oratext* zon2, ub4 zon2_length, OCIDate* date2);

    /**
    * Find the next occurance of a _day after a certain _date.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI _date to start at.
    *    day_p = The day to go to.
    *    day_length = The length of day_p.
    *    next_day = A pointer to the OCI _date to put the _result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateNextDay (OCIError* err, OCIDate* date, oratext* day_p, ub4 day_length, OCIDate* next_day);

    enum uint OCI_DATE_INVALID_DAY        = 0x1;        /// Bad day.
    enum uint OCI_DATE_DAY_BELOW_VALID    = 0x2;        /// Bad day low/high bit (1=low).
    enum uint OCI_DATE_INVALID_MONTH    = 0x4;        /// Bad month.
    enum uint OCI_DATE_MONTH_BELOW_VALID    = 0x8;        /// Bad month low/high bit (1=low).
    enum uint OCI_DATE_INVALID_YEAR    = 0x10;        /// Bad year.
    enum uint OCI_DATE_YEAR_BELOW_VALID    = 0x20;        /// Bad year low/high bit (1=low).
    enum uint OCI_DATE_INVALID_HOUR    = 0x40;        /// Bad hour.
    enum uint OCI_DATE_HOUR_BELOW_VALID    = 0x80;        /// Bad hour low/high bit (1=low).
    enum uint OCI_DATE_INVALID_MINUTE    = 0x100;    /// Bad minute.
    enum uint OCI_DATE_MINUTE_BELOW_VALID    = 0x200;    /// Bad minute low/high bit (1=low).
    enum uint OCI_DATE_INVALID_SECOND    = 0x400;    /// Bad second.
    enum uint OCI_DATE_SECOND_BELOW_VALID    = 0x800;    /// Bad second low/high bit (1=low).
    enum uint OCI_DATE_DAY_MISSING_FROM_1582 = 0x1000;    /// Day is one of those "missing" from 1582.
    enum uint OCI_DATE_YEAR_ZERO        = 0x2000;    /// Year may not equal zero.
    enum uint OCI_DATE_INVALID_FORMAT    = 0x8000;    /// Bad date format input.

    /**
    * Check if a _date is _valid.
    *
    * Params:
    *    err = OCI error handle.
    *    date = A pointer to the OCI _date to check.
    *    valid = An ORed combination of error bits.    The names start with OCI_DATE_.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateCheck (OCIError* err, OCIDate* date, uword* valid);

    /**
    * Get the current system _date.
    *
    * Params:
    *    err = OCI error handle.
    *    sys_date = A pointer to the OCI _date to put the result in.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIDateSysDate (OCIError* err, OCIDate* sys_date);

    /**
    * The variable-length string is represented in C as a pointer to OCIString
    * structure. The OCIString structure is opaque to the user. Functions are
    * provided to allow the user to manipulate a variable-length string.
    *
    * A variable-length string can be declared as:
    *
    * OCIString* vstr;
    *
    * For binding variables of type OCIString* in OCI calls (OCIBindByName(),
    * OCIBindByPos() and OCIDefineByPos()) use the external type code SQLT_VST.
    *
    * Warning:
    *    OCIString is implicitly null terminated.
    */
    struct OCIString {
    }

    /**
    * Copy a string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    rhs = A pointer to the source OCI string.
    *    lhs = A pointer to a pointer to the target OCI string.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIStringAssign (OCIEnv* env, OCIError* err, OCIString* rhs, OCIString** lhs);

    /**
    * Assign a C string to a string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    rhs = A pointer to the source string.
    *    rhs_length = The length of rhs.
    *    lhs = A pointer to a pointer to the target OCI string.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIStringAssignText (OCIEnv* env, OCIError* err, oratext* rhs, ub4 rhs_len, OCIString** lhs);

    /**
    * Resize a string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    new_size = The length to make str.
    *    str = A pointer to a pointer to the OCI string.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIStringResize (OCIEnv* env, OCIError* err, ub4 new_size, OCIString** str);

    /**
    * Get the size of a string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    vs = A pointer to the OCI string to check.
    *
    * Returns:
    *    The length of vs in bytes.
    */
    extern (C) ub4 OCIStringSize (OCIEnv* env, OCIString* vs);

    /**
    * Get a string in C string format.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    vs = A pointer to the OCI string to convert.
    *
    * Returns:
    *    vs as a C string.
    */
    extern (C) oratext* OCIStringPtr (OCIEnv* env, OCIString* vs);

    /**
    * Get the allocated size of a string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    vs = A pointer to the OCI string to check.
    *    allocsize = The allocated size of vs.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIStringAllocSize (OCIEnv* env, OCIError* err, OCIString* vs, ub4* allocsize);

    /**
    * The variable-length raw is represented in C as a pointer to OCIRaw
    * structure. The OCIRaw structure is opaque to the user. Functions are
    * provided to allow the user to manipulate a variable-length raw.
    *
    * A variable-length raw can be declared as:
    *
    * OCIRaw* raw;
    *
    * For binding variables of type OCIRaw* in OCI calls (OCIBindByName(),
    * OCIBindByPos() and OCIDefineByPos()) use the external type code SQLT_LVB.
    */
    struct OCIRaw {
    }

    /**
    * Copy a variable-length raw.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    rhs = A pointer to the source OCI variable-length raw.
    *    lhs = A pointer to a pointer to the target OCI variable-length raw.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRawAssignRaw (OCIEnv* env, OCIError* err, OCIRaw* rhs, OCIRaw** lhs);

    /**
    * Assign bytes to a variable-length raw.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    rhs = A pointer to the source bytes.
    *    rhs_len = The length of rhs.
    *    lhs = A pointer to a pointer to the target OCI variable-length raw.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRawAssignBytes (OCIEnv* env, OCIError* err, ub1* rhs, ub4 rhs_len, OCIRaw** lhs);

    /**
    * Resize a variable-length _raw.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    new_size = The size to make raw.
    *    raw = A pointer to a pointer to the OCI variable-length _raw to resize.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    //extern (C) sword OCIRawResize (OCIEnv *env, OCIError* err, ub4 new_size, OCIRaw** raw);

    /**
    * Get the size of a variable-length _raw.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    raw = A pointer to the OCI variable-length _raw to check.
    *
    * Returns:
    *    The number of bytes in raw.
    */
    extern (C) ub4 OCIRawSize (OCIEnv* env, OCIRaw* raw);

    /**
    * Return a variable-length _raw as an array of bytes.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    raw = A pointer to the OCI variable-length _raw to return.
    *
    * Returns:
    *    raw as an array of bytes.
    */
    extern (C) ub1* OCIRawPtr (OCIEnv* env, OCIRaw* raw);

    /**
    * Get the allocated size of a variable-length _raw.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    raw = A pointer to the OCI variable-length _raw to check.
    *    allocsize = The allocated size of raw
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRawAllocSize (OCIEnv* env, OCIError* err, OCIRaw* raw, ub4* allocsize);

    /**
    * Clear an object reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    ref = A pointer to the OCI object reference to clear.
    */
    extern (C) void OCIRefClear (OCIEnv* env, OCIRef*);

    /**
    * Copy an object reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    source = A pointer to the _source OCI object reference.
    *    target = A pointer to a pointer to the _target OCI object reference.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRefAssign (OCIEnv* env, OCIError* err, OCIRef* source, OCIRef** target);

    /**
    * Test two object references for equality.
    *
    * Two null object references are not considered equal.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    x = A pointer to the first OCI object reference to test.
    *    y = A pointer to the second OCI object reference to test.
    *
    * Returns:
    *    TRUE if they are equal or FALSE otherwise.
    */
    extern (C) boolean OCIRefIsEqual (OCIEnv* env, OCIRef* x, OCIRef* y);

    /**
    * Test if an object reference is null.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    ref = A pointer to the OCI object reference to test.
    *
    * Returns:
    *    TRUE if it is null or false otherwise.
    */
    extern (C) boolean OCIRefIsNull (OCIEnv* env, OCIRef*);

    /**
    * Get the size of an object reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    ref = A pointer to the OCI object reference to test.
    *
    * Returns:
    *    The size of ref.
    */
    extern (C) ub4 OCIRefHexSize (OCIEnv* env, OCIRef*);

    /**
    * Convert a hexadecimal string to an object reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    svc = OCI service context handle.
    *    hex = The source hexadecimal string.
    *    hex_length = The length of hex.
    *    ref = A pointer to a pointer to the resulting OCI object reference.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRefFromHex (OCIEnv* env, OCIError* err, OCISvcCtx* svc, oratext* hex, ub4 length, OCIRef**);

    /**
    * Convert an object reference into a hexadecimal string.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    ref = A pointer to the source OCI object reference.
    *    hex = A pointer to the resulting hexadecimal string.
    *    hex_length = The length of hex.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCIRefToHex (OCIEnv* env, OCIError* err, OCIRef* , oratext* hex, ub4* hex_length);

    /**
    * Generic collection type.
    */
    struct OCIColl {
    }

    /**
    * Varray collection type.
    */
    alias OCIColl OCIArray;

    /**
    * Nested table collection type.
    */
    alias OCIColl OCITable;

    /**
    * Collection iterator.
    */
    struct OCIIter {
    }

    /**
    * Get the size of a collection.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    coll = A pointer to the OCI collection to check.
    *    size = The current number of elements in coll.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollSize (OCIEnv* env, OCIError* err, OCIColl* coll, sb4* size);

    /**
    * Get the maximum size of a collection.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    coll = A pointer to the OCI collection to check.
    *
    * Returns:
    *    The maximum size of coll if there is one or 0 if there isn't.
    */
    extern (C) sb4 OCICollMax (OCIEnv* env, OCIColl* coll);

    /**
    * Get the pointer to an element of a collection by _index.
    *
    * Optionally, you can get the address of the element's null indictator.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    coll = A pointer to the OCI collection to retrieve the pointer from.
    *    index = The _index of the element to return the pointer of.
    *    exists = FALSE if there is nothing at index or TRUE if there is.
    *    elem = The pointer to the element at index.    The type is a pointer to the desired type.
    *    elemind = The address of the null indicator for elem unless null is passed.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollGetElem (OCIEnv* env, OCIError* err, OCIColl* coll, sb4 index, boolean* exists, dvoid** elem, dvoid** elemind);

    /**
    * Get the pointer to an array of elements of a collection by _index.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    coll = A pointer to the OCI collection to retrieve the pointer from.
    *    index = The _index of the first element to return the pointer of.
    *    exists = FALSE if there is nothing at index or TRUE if there is.
    *    elem = The pointer to the element at index.    The type is a pointer to the desired type.
    *    elemind = The address of the null indicator for elem unless null is passed.
    *    nelems = The number of elements to retrieve.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollGetElemArray (OCIEnv* env, OCIError* err, OCIColl* coll, sb4 index, boolean* exists, dvoid** elem, dvoid** elemind, uword* nelems);

    /**
    * Assign an element to a collection.
    *
    * elem is assigned to coll[index] with a null indictator of elemind.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    index = The _index of the element to to change.
    *    elem = A pointer to the source OCI element.
    *    elemind = The null indicator for elem unless null is passed.
    *    coll = A pointer to the target OCI collection.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollAssignElem (OCIEnv* env, OCIError* err, sb4 index, dvoid* elem, dvoid* elemind, OCIColl* coll);

    /**
    * Copy a collection.
    *
    * lhs and rhs must be the same type of collection.    rhs must have at least as many
    * elements as rhs.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    rhs = A pointer to the source OCI collection.
    *    lhs = A pointer to the target OCI collection.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollAssign (OCIEnv* env, OCIError* err, OCIColl* rhs, OCIColl* lhs);

    /**
    * Append an element to a collection.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    elem = A pointer to the source OCI element.
    *    elemind = The null indicator for elem unless null is passed.
    *    coll = A pointer to the target OCI collection.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollAppend (OCIEnv* env, OCIError* err, dvoid* elem, dvoid* elemind, OCIColl* coll);

    /**
    * Remove elements from the end of a collection.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    trim_num = The number of OCI elemenets to remove.
    *    coll = A pointer to the target OCI collection.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCICollTrim (OCIEnv* env, OCIError* err, sb4 trim_num, OCIColl* coll);

    /**
    * Test if a collection is a locator.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    coll = A pointer to the target OCI collection.
    *    result = TRUE is coll is a locator and FALSE if it isn't.
    *
    * Returns:
    *    OCI_SUCCESS on success or OCI_INVALID_HANDLE on invalid parameters.
    */
    extern (C) sword OCICollIsLocator (OCIEnv* env, OCIError* err, OCIColl* coll, boolean* result);


    extern (C) sword OCIIterCreate (OCIEnv* env, OCIError* err, OCIColl* coll, OCIIter** itr);
    /*
        NAME: OCIIterCreate - OCIColl Create an ITerator to scan the collection
                        elements
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        coll (IN) - collection which will be scanned; the different
            collection types are varray and nested table
        itr (OUT) - address to the allocated collection iterator is
            returned by this function
        DESCRIPTION:
        Create an iterator to scan the elements of the collection. The
        iterator is created in the object cache. The iterator is initialized
        to point to the beginning of the collection.

        If the next function (OCIIterNext) is called immediately
        after creating the iterator then the first element of the collection
        is returned.
        If the previous function (OCIIterPrev) is called immediately after
        creating the iterator then "at beginning of collection" error is
        returned.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
            out of memory error
    */

    extern (C) sword OCIIterDelete (OCIEnv* env, OCIError* err, OCIIter** itr);
    /*
        NAME: OCIIterDelete - OCIColl Delete ITerator
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        itr (IN/OUT) - the allocated collection iterator is destroyed and
            the 'itr' is set to NULL prior to returning
        DESCRIPTION:
        Delete the iterator which was previously created by a call to
        OCIIterCreate.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
            to be discovered
    */

    extern (C) sword OCIIterInit (OCIEnv* env, OCIError* err, OCIColl* coll, OCIIter* itr);
    /*
        NAME: OCIIterInit - OCIColl Initialize ITerator to scan the given
                collection
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        coll (IN) - collection which will be scanned; the different
            collection types are varray and nested table
        itr (IN/OUT) - pointer to an allocated    collection iterator
        DESCRIPTION:
        Initializes the given iterator to point to the beginning of the
        given collection. This function can be used to:

        a. reset an iterator to point back to the beginning of the collection
        b. reuse an allocated iterator to scan a different collection
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
    */

    extern (C) sword OCIIterGetCurrent (OCIEnv* env, OCIError* err, OCIIter* itr, dvoid** elem, dvoid** elemind);
    /*
        NAME: OCIIterGetCurrent - OCIColl Iterator based, get CURrent collection
                    element
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        itr (IN) - iterator which points to the current element
        elem (OUT) - address of the element pointed by the iterator is returned
        elemind (OUT) [optional] - address of the element's null indicator
            information is returned; if (elemind == NULL) then the null
            indicator information will NOT be returned
        DESCRIPTION:
        Returns pointer to the current element and its corresponding null
        information.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
    */

    extern (C) sword OCIIterNext (OCIEnv* env, OCIError* err, OCIIter* itr, dvoid** elem, dvoid** elemind, boolean* eoc);
    /*
        NAME: OCIIterNext - OCIColl Iterator based, get NeXT collection element
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        itr (IN/OUT) - iterator is updated to point to the next element
        elem (OUT) - after updating the iterator to point to the next element,
            address of the element is returned
        elemind (OUT) [optional] - address of the element's null indicator
            information is returned; if (elemind == NULL) then the null
            indicator information will NOT be returned
        eoc (OUT) - TRUE if iterator is at End Of Collection (i.e. next
            element does not exist) else FALSE
        DESCRIPTION:
        Returns pointer to the next element and its corresponding null
        information. The iterator is updated to point to the next element.

        If the iterator is pointing to the last element of the collection
        prior to executing this function, then calling this function will
        set eoc flag to TRUE. The iterator will be left unchanged in this
        situation.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
    */

    extern (C) sword OCIIterPrev (OCIEnv* env, OCIError* err, OCIIter* itr, dvoid** elem, dvoid** elemind, boolean* boc);
    /*
        NAME: OCIIterPrev - OCIColl Iterator based, get PReVious collection element
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        itr (IN/OUT) - iterator is updated to point to the previous
            element
        elem (OUT) - after updating the iterator to point to the previous
            element, address of the element is returned
        elemind (OUT) [optional] - address of the element's null indicator
            information is returned; if (elemind == NULL) then the null
            indicator information will NOT be returned
        boc (OUT) - TRUE if iterator is at Beginning Of Collection (i.e.
            previous element does not exist) else FALSE.
        DESCRIPTION:
        Returns pointer to the previous element and its corresponding null
        information. The iterator is updated to point to the previous element.

        If the iterator is pointing to the first element of the collection
        prior to executing this function, then calling this function will
        set 'boc' to TRUE. The iterator will be left unchanged in this
        situation.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
    */

    extern (C) sword OCITableSize (OCIEnv* env, OCIError* err, OCITable* tbl, sb4* size);
    /*
        NAME: OCITableSize - OCITable return current SIZe of the given
                nested table (not including deleted elements)
        PARAMETERS:
        env(IN) - pointer to OCI environment handle
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tbl (IN) - nested table whose number of elements is returned
        size (OUT) - current number of elements in the nested table. The count
            does not include deleted elements.
        DESCRIPTION:
        Returns the count of elements in the given nested table.

        The count returned by OCITableSize() will be decremented upon
        deleting elements from the nested table. So, this count DOES NOT
        includes any "holes" created by deleting elements.
        For example:

                OCITableSize(...);
                // assume 'size' returned is equal to 5
                OCITableDelete(...); // delete one element
                OCITableSize(...);
                // 'size' returned will be equal to 4

        To get the count plus the count of deleted elements use
        OCICollSize(). Continuing the above example,

                OCICollSize(...)
                // 'size' returned will still be equal to 5
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            error during loading of nested table into object cache
            any of the input parameters is null
    */

    extern (C) sword OCITableExists (OCIEnv* env, OCIError* err, OCITable* tbl, sb4 index, boolean* exists);
    /*
        NAME: OCITableExists - OCITable test whether element at the given index
                    EXIsts
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tbl (IN) - table in which the given index is checked
        index (IN) - index of the element which is checked for existence
        exists (OUT) - set to TRUE if element at given 'index' exists
            else set to FALSE
        DESCRIPTION:
        Test whether an element exists at the given 'index'.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
    */

    extern (C) sword OCITableDelete (OCIEnv* env, OCIError* err, sb4 index, OCITable* tbl);
    /*
        NAME: OCITableDelete - OCITable DELete element at the specified index
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        index (IN) - index of the element which must be deleted
        tbl (IN) - table whose element is deleted
        DESCRIPTION:
        Delete the element at the given 'index'. Note that the position
        ordinals of the remaining elements of the table is not changed by the
        delete operation. So delete creates "holes" in the table.

        An error is returned if the element at the specified 'index' has
        been previously deleted.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            any of the input parameters is null
            given index is not valid
    */

    extern (C) sword OCITableFirst (OCIEnv* env, OCIError* err, OCITable* tbl, sb4* index);
    /*
        NAME: OCITableFirst - OCITable return FirST index of table
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tbl (IN) - table which is scanned
        index (OUT) - first index of the element which exists in the given
            table is returned
        DESCRIPTION:
        Return the first index of the element which exists in the given
        table.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            table is empty
    */

    extern (C) sword OCITableLast (OCIEnv* env, OCIError* err, OCITable* tbl, sb4* index);
    /*
        NAME: OCITableFirst - OCITable return LaST index of table
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tbl (IN) - table which is scanned
        index (OUT) - last index of the element which exists in the given
            table is returned
        DESCRIPTION:
        Return the last index of the element which exists in the given
        table.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            table is empty
    */

    extern (C) sword OCITableNext (OCIEnv* env, OCIError* err, sb4 index, OCITable* tbl, sb4* next_index, boolean* exists);
    /*
        NAME: OCITableNext - OCITable return NeXT available index of table
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        index (IN) - starting at 'index' the index of the next element
            which exists is returned
        tbl (IN) - table which is scanned
        next_index (OUT) - index of the next element which exists
            is returned
        exists (OUT) - FALSE if no next index available else TRUE
        DESCRIPTION:
        Return the smallest position j, greater than 'index', such that
        exists(j) is TRUE.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            no next index available
    */

    extern (C) sword OCITablePrev (OCIEnv* env, OCIError* err, sb4 index, OCITable* tbl, sb4* prev_index, boolean* exists);
    /*
        NAME: OCITablePrev - OCITable return PReVious available index of table
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode.
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        index (IN) - starting at 'index' the index of the previous element
            which exists is returned
        tbl (IN) - table which is scanned
        prev_index (OUT) - index of the previous element which exists
            is returned
        exists (OUT) - FALSE if no next index available else TRUE
        DESCRIPTION:
        Return the largest position j, less than 'index', such that
        exists(j) is TRUE.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is NULL.
        OCI_ERROR if
            no previous index available
    */
    /+
    deprecated lnxnum_t* OCINumberToLnx (OCINumber* num) {
        return cast(lnxnum_t*)num;
    }
    /*
        NAME:        OCINumberToLnx
        PARAMETERS:
            num (IN) - OCINumber to convert ;
        DESCRIPTION:
            Converts OCINumber to its internal lnx format
            This is not to be used in Public interfaces , but
            has been provided due to special requirements from
            SQLPLUS development group as they require to call
            Core funtions directly .
    */
    +/

    /**
    * The OCITypeCode type is interchangeable with the existing SQLT type, which is a ub2.
    */
    alias ub2 OCITypeCode;

    enum OCITypeCode OCI_TYPECODE_REF    = SQLT_REF;    /// SQL/OTS OBJECT REFERENCE.
    enum OCITypeCode OCI_TYPECODE_DATE    = SQLT_DAT;    /// SQL DATE    OTS DATE.
    enum OCITypeCode OCI_TYPECODE_SIGNED8    = 27;        /// SQL SIGNED INTEGER(8)    OTS SINT8.
    enum OCITypeCode OCI_TYPECODE_SIGNED16    = 28;        /// SQL SIGNED INTEGER(16)    OTS SINT16.
    enum OCITypeCode OCI_TYPECODE_SIGNED32    = 29;        /// SQL SIGNED INTEGER(32)    OTS SINT32.
    enum OCITypeCode OCI_TYPECODE_REAL    = 21;        /// SQL REAL    OTS SQL_REAL.
    enum OCITypeCode OCI_TYPECODE_DOUBLE    = 22;        /// SQL DOUBLE PRECISION    OTS SQL_DOUBLE.
    enum OCITypeCode OCI_TYPECODE_BFLOAT    = SQLT_IBFLOAT;    /// Binary float.
    enum OCITypeCode OCI_TYPECODE_BDOUBLE    = SQLT_IBDOUBLE;/// Binary double.
    enum OCITypeCode OCI_TYPECODE_FLOAT    = SQLT_FLT;    /// SQL FLOAT(P)    OTS FLOAT(P).
    enum OCITypeCode OCI_TYPECODE_NUMBER    = SQLT_NUM;    /// SQL NUMBER(P S)    OTS NUMBER(P S).
    enum OCITypeCode OCI_TYPECODE_DECIMAL    = SQLT_PDN;    /// SQL DECIMAL(P S)    OTS DECIMAL(P S).
    enum OCITypeCode OCI_TYPECODE_UNSIGNED8= SQLT_BIN;    /// SQL UNSIGNED INTEGER(8)    OTS OCITypeCode8.
    enum OCITypeCode OCI_TYPECODE_UNSIGNED16 = 25;        /// SQL UNSIGNED INTEGER(16)    OTS OCITypeCode16.
    enum OCITypeCode OCI_TYPECODE_UNSIGNED32 = 26;        /// SQL UNSIGNED INTEGER(32)    OTS OCITypeCode32.
    enum OCITypeCode OCI_TYPECODE_OCTET    = 245;        /// SQL ???    OTS OCTET.
    enum OCITypeCode OCI_TYPECODE_SMALLINT    = 246;        /// SQL SMALLINT    OTS SMALLINT.
    enum OCITypeCode OCI_TYPECODE_INTEGER    = SQLT_INT;    /// SQL INTEGER    OTS INTEGER.
    enum OCITypeCode OCI_TYPECODE_RAW    = SQLT_LVB;    /// SQL RAW(N)    OTS RAW(N).
    enum OCITypeCode OCI_TYPECODE_PTR    = 32;        /// SQL POINTER    OTS POINTER.
    enum OCITypeCode OCI_TYPECODE_VARCHAR2    = SQLT_VCS;    /// SQL VARCHAR2(N)    OTS SQL_VARCHAR2(N).
    enum OCITypeCode OCI_TYPECODE_CHAR    = SQLT_AFC;    /// SQL CHAR(N)    OTS SQL_CHAR(N).
    enum OCITypeCode OCI_TYPECODE_VARCHAR    = SQLT_CHR;    /// SQL VARCHAR(N)    OTS SQL_VARCHAR(N).
    enum OCITypeCode OCI_TYPECODE_MLSLABEL    = SQLT_LAB;    /// OTS MLSLABEL.
    enum OCITypeCode OCI_TYPECODE_VARRAY    = 247;        /// SQL VARRAY    OTS PAGED VARRAY.
    enum OCITypeCode OCI_TYPECODE_TABLE    = 248;        /// SQL TABLE    OTS MULTISET.
    enum OCITypeCode OCI_TYPECODE_OBJECT    = SQLT_NTY;    /// SQL/OTS NAMED OBJECT TYPE.
    enum OCITypeCode OCI_TYPECODE_OPAQUE    = 58;        /// SQL/OTS Opaque Types.
    enum OCITypeCode OCI_TYPECODE_NAMEDCOLLECTION = SQLT_NCO; /// SQL/OTS NAMED COLLECTION TYPE.
    enum OCITypeCode OCI_TYPECODE_BLOB    = SQLT_BLOB;    /// SQL/OTS BINARY LARGE OBJECT.
    enum OCITypeCode OCI_TYPECODE_BFILE    = SQLT_BFILEE;    /// SQL/OTS BINARY FILE OBJECT.
    enum OCITypeCode OCI_TYPECODE_CLOB    = SQLT_CLOB;    /// SQL/OTS CHARACTER LARGE OBJECT.
    enum OCITypeCode OCI_TYPECODE_CFILE    = SQLT_CFILEE;    /// SQL/OTS CHARACTER FILE OBJECT.

    enum OCITypeCode OCI_TYPECODE_TIME    = SQLT_TIME;    /// SQL/OTS TIME.
    enum OCITypeCode OCI_TYPECODE_TIME_TZ    = SQLT_TIME_TZ;    /// SQL/OTS TIME_TZ.
    enum OCITypeCode OCI_TYPECODE_TIMESTAMP= SQLT_TIMESTAMP; /// SQL/OTS TIMESTAMP.
    enum OCITypeCode OCI_TYPECODE_TIMESTAMP_TZ = SQLT_TIMESTAMP_TZ; /// SQL/OTS TIMESTAMP_TZ.

    enum OCITypeCode OCI_TYPECODE_TIMESTAMP_LTZ = SQLT_TIMESTAMP_LTZ; /// TIMESTAMP_LTZ.

    enum OCITypeCode OCI_TYPECODE_INTERVAL_YM = SQLT_INTERVAL_YM; /// SQL/OTS INTRVL YR-MON.
    enum OCITypeCode OCI_TYPECODE_INTERVAL_DS = SQLT_INTERVAL_DS; /// SQL/OTS INTRVL DAY-SEC.
    enum OCITypeCode OCI_TYPECODE_UROWID    = SQLT_RDD;    /// Urowid type.


    enum OCITypeCode OCI_TYPECODE_OTMFIRST    = 228;        /// first Open Type Manager typecode.
    enum OCITypeCode OCI_TYPECODE_OTMLAST    = 320;        /// last OTM typecode.
    enum OCITypeCode OCI_TYPECODE_SYSFIRST    = 228;        /// first OTM system type (internal).
    enum OCITypeCode OCI_TYPECODE_SYSLAST    = 235;        /// last OTM system type (internal).
    enum OCITypeCode OCI_TYPECODE_PLS_INTEGER = 266;    /// type code for PLS_INTEGER.

    //enum OCITypeCode OCI_TYPECODE_ITABLE    = SQLT_TAB;    /// PLSQL indexed table.    Do not use.
    //enum OCITypeCode OCI_TYPECODE_RECORD    = SQLT_REC;    /// PLSQL record.    Do not use.
    //enum OCITypeCode OCI_TYPECODE_BOOLEAN    = SQLT_BOL;    /// PLSQL boolean.    Do not use.

    enum OCITypeCode OCI_TYPECODE_NCHAR    = 286;        /// Intended for use in the OCIAnyData API only.
    enum OCITypeCode OCI_TYPECODE_NVARCHAR2= 287;        /// Intended for use in the OCIAnyData API only.
    enum OCITypeCode OCI_TYPECODE_NCLOB    = 288;        /// Intended for use in the OCIAnyData API only.

    enum OCITypeCode OCI_TYPECODE_NONE    = 0;        /// To indicate absence of typecode being specified.
    enum OCITypeCode OCI_TYPECODE_ERRHP    = 283;        /// To indicate error has to be taken from error handle - reserved for sqlplus use.

    
//69 //BINARY ROWID
//250 //PL/SQL RECORD
//251 //PL/SQL COLLECTION
//252 //PL/SQL BOOLEAN
//256 //OID
//257 //CONTIGUOUS ARRAY
//258 //CANONICAL
//259 //LOB POINTER
//260 //PL/SQL POSITIVE
//261 //PL/SQL POSITIVEN
//262 //PL/SQL ROWID
//263 //PL/SQL LONG
//264 //PL/SQL LONG RAW
//265 //PL/SQL BINARY INTEGER
//267 //PL/SQL NATURAL
//268 //PL/SQL NATURALN
//269 //PL/SQL STRING


    /**
    * This is the flag passed to OCIGetTypeArray() to indicate how the TDO is
    * going to be loaded into the object cache.
    * OCI_TYPEGET_HEADER implies that only the header portion is to be loaded
    * initially, with the rest loaded in on a 'lazy' basis. Only the header is
    * needed for PL/SQL and OCI operations. OCI_TYPEGET_ALL implies that ALL
    * the attributes and methods belonging to a TDO will be loaded into the
    * object cache in one round trip. Hence it will take much longer to execute,
    * but will ensure that no more loading needs to be done when pinning ADOs
    * etc. This is only needed if your code needs to examine and manipulate
    * attribute and method information.
    *
    * The default is OCI_TYPEGET_HEADER.
    */
    enum OCITypeGetOpt {
        OCI_TYPEGET_HEADER,                /// Load only the header portion of the TDO when getting the type.
        OCI_TYPEGET_ALL                    /// Load all attribute and method descriptors as well.
    }

    /**
    * OCI Encapsulation Level
    */
    enum OCITypeEncap {
        OCI_TYPEENCAP_PRIVATE,                /// Private: only visible internally.
        OCI_TYPEENCAP_PUBLIC                /// Public: visible both internally and externally.
    }

    /**
    *
    */
    enum OCITypeMethodFlag : size_t {
        OCI_TYPEMETHOD_INLINE = 0x0001,            /// Inline.
        OCI_TYPEMETHOD_CONSTANT = 0x0002,        /// Constant.
        OCI_TYPEMETHOD_VIRTUAL = 0x0004,        /// Virtual.
        OCI_TYPEMETHOD_CONSTRUCTOR = 0x0008,        /// Constructor.
        OCI_TYPEMETHOD_DESTRUCTOR = 0x0010,        /// Destructor.
        OCI_TYPEMETHOD_OPERATOR    = 0x0020,        /// Operator.
        OCI_TYPEMETHOD_SELFISH = 0x0040,        /// Selfish method (generic otherwise).
        OCI_TYPEMETHOD_MAP = 0x0080,            /// Map (relative ordering).
        OCI_TYPEMETHOD_ORDER    = 0x0100,            /// Order (relative ordering).
        OCI_TYPEMETHOD_RNDS= 0x0200,            /// Read no Data State (default).
        OCI_TYPEMETHOD_WNDS= 0x0400,            /// Write no Data State.
        OCI_TYPEMETHOD_RNPS= 0x0800,            /// Read no Process State.
        OCI_TYPEMETHOD_WNPS= 0x1000,            /// Write no Process State.
        OCI_TYPEMETHOD_ABSTRACT = 0x2000,        /// Abstract (not instantiable) method.
        OCI_TYPEMETHOD_OVERRIDING = 0x4000,        /// Overriding method.
        OCI_TYPEMETHOD_PIPELINED = 0x8000        /// Method is pipelined.
    }

    bool OCI_METHOD_IS_NEW (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_INLINE;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_CONSTANT (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTANT;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_VIRTUAL (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_VIRTUAL;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_CONSTRUCTOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTRUCTOR;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_DESTRUCTOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_DESTRUCTOR;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_OPERATOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_OPERATOR;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_SELFISH (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_SELFISH;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_MAP (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_MAP;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_ORDER (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_ORDER;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_RNDS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_RNDS;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_WNDS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_WNDS;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_RNPS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_RNPS;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_WNPS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_WNPS;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_ABSTRACT (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_ABSTRACT;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_OVERRIDING (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_OVERRIDING;
    }

    /**
    *
    */
    bool OCI_METHOD_IS_PIPELINED (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_PIPELINED;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_INLINE (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_INLINE;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_CONSTANT (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTANT;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_VIRTUAL (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_VIRTUAL;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_CONSTRUCTOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTRUCTOR;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_DESTRUCTOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_DESTRUCTOR;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_OPERATOR (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_OPERATOR;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_SELFISH (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_SELFISH;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_MAP (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_MAP;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_ORDER (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_ORDER;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_RNDS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_RNDS;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_WNDS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_WNDS;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_RNPS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_RNPS;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_WNPS (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_WNPS;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_ABSTRACT (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_ABSTRACT;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_OVERRIDING (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_OVERRIDING;
    }

    /**
    *
    */
    bool OCI_TYPEMETHOD_IS_PIPELINED (OCITypeMethodFlag flag) {
        return flag && OCITypeMethodFlag.OCI_TYPEMETHOD_PIPELINED;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_INLINE (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_INLINE;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_CONSTANT (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTANT;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_VIRTUAL (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_VIRTUAL;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_CONSTRUCTOR (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTRUCTOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_DESTRUCTOR (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_DESTRUCTOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_OPERATOR (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_OPERATOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_SELFISH (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_SELFISH;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_MAP (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_MAP;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_ORDER (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_ORDER;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_RNDS (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_RNDS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_WNDS (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_WNDS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_RNPS (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_RNPS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_SET_WNPS (OCITypeMethodFlag flag) {
        return flag &= OCITypeMethodFlag.OCI_TYPEMETHOD_WNPS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_INLINE (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_INLINE;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_CONSTANT (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTANT;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_VIRTUAL (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_VIRTUAL;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_CONSTRUCTOR (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_CONSTRUCTOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_DESTRUCTOR (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_DESTRUCTOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_OPERATOR (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_OPERATOR;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_SELFISH (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_SELFISH;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_MAP (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_MAP;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_ORDER (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_ORDER;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_RNDS (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_RNDS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_WNDS (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_WNDS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_RNPS (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_RNPS;
    }

    /**
    *
    */
    auto OCI_TYPEMETHOD_CLEAR_WNPS (OCITypeMethodFlag flag) {
        return flag ^= OCITypeMethodFlag.OCI_TYPEMETHOD_WNPS;
    }

    enum ub1 OCI_NUMBER_DEFAULTPREC    = 0;        /// No precision specified.

    enum uint OCI_VARRAY_MAXSIZE        = 4000;        /// Default maximum number of elements for a varray.
    enum uint OCI_STRING_MAXLEN        = 4000;        /// Default maximum length of a vstring.





    /**
    * OCI Type Description
    *
    * The contents of an 'OCIType' is private/opaque to clients.    Clients just
    * need to declare and pass 'OCIType' pointers in to the type manage
    * functions.
    *
    * The pointer points to the type in the object cache.    Thus, clients don't
    * need to allocate space for this type and must never free the pointer to the
    * 'OCIType.'
    */
    struct OCIType {
    }

    /**
    * OCI Type Element
    *
    * The contents of an 'OCITypeElem' is private/opaque to clients. Clients just
    * need to declare and pass 'OCITypeElem' pointers in to the type manager
    * functions.
    *
    * 'OCITypeElem' objects contains type element information such as the numeric
    * precision, for number objects, and the number of elements for arrays.
    *
    * These are used to describe type attributes, collection elements,
    * method parameters, and method results. Hence these are pass in or returned
    * by attribute, collection, and method parameter/result accessors.
    */
    struct OCITypeElem {
    }

    /**
    * OCI Method Description
    *
    * The contents of an 'OCITypeMethod' is private/opaque to clients.    Clients
    * just need to declare and pass 'OCITypeMethod' pointers in to the type
    * manager functions.
    *
    * The pointer points to the method in the object cache.    Thus, clients don't
    * need to allocate space for this type and must never free the pointer to
    * the 'OCITypeMethod.'
    */
    struct OCITypeMethod {
    }

    /**
    * OCI Type Iterator
    *
    * The contents of an 'OCITypeIter' is private/opaque to clients.    Clients
    * just need to declare and pass 'OCITypeIter' pointers in to the type
    * manager functions.
    *
    * The iterator is used to retreive MDO's and ADO's that belong to the TDO
    * one at a time.    It needs to be allocated by the 'OCITypeIterNew()' function
    * call and deallocated with the 'OCITypeIterFree()' function call.
    */
    struct OCITypeIter {
    }

    /**
    * Create a new OCITypeIter.
    *
    * Deprecated:
    *    Unknown reason, but Oracle says so!
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    tdo = Pointer to the pinned type in the object cache to initialize the iterator with.
    *    iterator_ort = Pointer to the pointer to the new iterator.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */

    /**
    * Initialize a OCITypeIter.
    *
    * Deprecated:
    *    Unknown reason, but Oracle says so!
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    tdo = Pointer to the pinned type in the object cache to initialize the iterator with.
    *    iterator_ort = Pointer to the new iterator.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */

    /**
    * Free the space used by a OCITypeIter.
    *
    * Deprecated:
    *    Unknown reason, but Oracle says so!
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    iterator_ort = Pointer to the iterator.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */

    /**
    * Get a type by name.
    *
    * The schema and type name are case sensitive.    If you made them with SQL, use uppercase letters.
    *
    * Deprecated:
    *    Unknown reason, but Oracle says so!
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    svc = OCI service handle.
    *    schema_name = Name of the schema associated with the type.    Defaults to the user's schema name.
    *    s_length = Length of schema_name.
    *    type_name = Name of the type to get.
    *    t_length = Length of type_name.
    *    version_name = User readable name of the version.    Use null for the most current version.
    *    v_length = Length of version_name.    Use 0 for the most current version.
    *    pin_duration = The pin duration.
    *    get_option = Options for loading the type.    See OCITypeGetOpt for details.
    *    tdo = Pointer to the pinned type in the object cache.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */

    /**
    * Get an array of types by name.
    *
    * The schema and type names are case sensitive.    If you made them with SQL, use uppercase letters.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    svc = OCI service handle.
    *    array_len = Number of entries to retrieve.
    *    schema_name = Names of the schemas associated with the type.    Must be null or of length array_len.    Defaults to the user's schema name.
    *    s_length = Length of each element of schema_name.    Must be null or of length array_len.    Use 0 for null values.
    *    type_name = Names of the types to get.    Must be of length array_len.
    *    t_length = Length of each element of type_name.    Must be of length array_len.
    *    version_name = User readable names of the versions.    Must be null or of length array_len.    Use null for the most current version.
    *    v_length = Length of each element of version_name.    Use 0 for null values.
    *    pin_duration = The pin duration.
    *    get_option = Options for loading the type.    See OCITypeGetOpt for details.
    *    tdo = Pointer to memory allocated for the pinned type in the object cache.    It must have space for array_len pointers.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCITypeArrayByName (OCIEnv* env, OCIError* err, OCISvcCtx* svc, ub4 array_len, oratext** schema_name, ub4* s_length, oratext** type_name, ub4* t_length, oratext** version_name, ub4* v_length, OCIDuration pin_duration, OCITypeGetOpt get_option, OCIType** tdo);

    /**
    * Get a type by reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    type_ref = Reference to the type.
    *    pin_duration = The pin duration.
    *    get_option = Options for loading the type.    See OCITypeGetOpt for details.
    *    tdo = Pointer to the pinned type in the object cache.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCITypeByRef (OCIEnv* env, OCIError* err, OCIRef* type_ref, OCIDuration pin_duration, OCITypeGetOpt get_option, OCIType** tdo);

    /**
    * Get an array of types by reference.
    *
    * Params:
    *    env = OCI environment handle initialized in object mode.
    *    err = OCI error handle.
    *    array_len = Number of entries to retrieve.
    *    type_ref = References to the types to get.    Must be of length array_len.
    *    pin_duration = The pin duration.
    *    get_option = Options for loading the type.    See OCITypeGetOpt for details.
    *    tdo = Pointer to memory allocated for the pinned type in the object cache.    It must have space for array_len pointers.
    *
    * Returns:
    *    OCI_SUCCESS on success, OCI_INVALID_HANDLE on invalid parameters, or OCI_ERROR on error.
    */
    extern (C) sword OCITypeArrayByRef (OCIEnv* env, OCIError* err, ub4 array_len, OCIRef** type_ref, OCIDuration pin_duration, OCITypeGetOpt get_option, OCIType** tdo);






























    /*
        NAME: OCITypeName -    ORT Get a Type's naME.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        n_length (OUT) - length (in bytes) of the returned type name.    The
                    caller must allocate space for the ub4 before calling this
                    routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        3) 'n_length' must point to an allocated ub4.
        DESCRIPTION:
        Get the name of the type.
        RETURNS:
        the name of the type
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeSchema -    ORT Get a Type's SCHema name.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        n_length (OUT) - length (in bytes) of the returned schema name.    The
                    caller must allocate space for the ub4 before calling this
                    routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        3) 'n_length' must point to an allocated ub4.
        DESCRIPTION:
        Get the schema name of the type.
        RETURNS:
        the schema name of the type
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeTypeCode - OCI Get a Type's Type Code.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the type code of the type.
        RETURNS:
        The type code of the type.
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeCollTypeCode - OCI Get a Domain Type's Type Code.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        3) 'tdo' MUST point to a named collection type.
        DESCRIPTION:
        Get the type code of the named collection type. For V8.0, named
        collection types can only be variable length arrays and nested tables.
        RETURNS:
        OCI_TYPECODE_VARRAY for variable length array, and
        OCI_TYPECODE_TABLE for nested tables.
        NOTES:
        The type descriptor, 'tdo', should be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeVersion - OCI Get a Type's user-readable VersioN.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        v_length (OUT) - length (in bytes) of the returned user-readable
                    version.    The caller must allocate space for the ub4 before
                    calling this routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        3) 'v_length' must point to an allocated ub4.
        DESCRIPTION:
        Get the user-readable version of the type.
        RETURNS:
        The user-readable version of the type
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeAttrs - OCI Get a Type's Number of Attributes.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the number of attributes in the type.
        RETURNS:
        The number of attributes in the type. 0 for ALL non-ADTs.
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeMethods - OCI Get a Type's Number of Methods.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the number of methods in a type.
        RETURNS:
        The number of methods in the type
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
    */


    /*
        NAME: OCITypeElemName - OCI Get an Attribute's NaMe.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        n_length (OUT) - length (in bytes) of the returned attribute name.
                    The caller must allocate space for the ub4 before calling this
                    routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        3) 'n_length' must point to an allocated ub4.
        DESCRIPTION:
        Get the name of the attribute.
        RETURNS:
        the name of the attribute and the length in n_length
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeElemTypeCode - OCI Get an Attribute's TypeCode.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the typecode of an attribute's type.
        RETURNS:
        the typecode of the attribute's type.    If this is a scalar type, the
        typecode sufficiently describes the scalar type and no further calls
        need to be made.    Valid scalar types include: OCI_TYPECODE_SIGNED8,
        OCI_TYPECODE_UNSIGNED8, OCI_TYPECODE_SIGNED16, OCI_TYPECODE_UNSIGNED16,
        OCI_TYPECODE_SIGNED32, OCI_TYPECODE_UNSIGNED32, OCI_TYPECODE_REAL,
        OCI_TYPECODE_DOUBLE, OCI_TYPECODE_DATE,
        OCI_TYPECODE_MLSLABEL, OROTCOID, OCI_TYPECODE_OCTET, or OROTCLOB.
        This function converts the CREF (stored in the attribute) into a
        typecode.
        NOTES:
                The type must be unpinned when the accessed information is no
                longer needed.
    */


    /*
        PARAMETERS
            env (IN/OUT) - OCI environment handle initialized in object mode
            err (IN/OUT) - error handle. If there is an error, it is
                recorded in 'err' and this function returns OCI_ERROR.
                The error recorded in 'err' can be retrieved by calling
                OCIErrorGet().
            elem (IN) - pointer to the type element descriptor in the object cache
            elem_tdo (OUT) - If the function completes successfully, 'elem_tdo'
                points to the type descriptor (in the object cache) of the type of
                the element.

        REQUIRES
            1) All type accessors require that the type be pinned before calling
        any accessor.    This can be done by calling 'OCITypeByName()'.
            2) if 'elem' is not null, it must point to a valid type element descriptor
        in the object cache.

        DESCRIPTION
            Get the type tdo of the type of this element.
        RETURNS
            OCI_SUCCESS if the function completes successfully.
            OCI_INVALID_HANDLE if 'env' or 'err' is null.
            OCI_ERROR if
        1) any of the parameters is null.

        NOTES
            The type must be unpinned when the accessed information is no
            longer needed.    This can be done by calling 'OCIObjectUnpin()'.
    */


    /*
        NAME: OCITypeElemFlags - OCI Get a Elem's FLags
                            (inline, enumant, virtual, enumructor,
                            destructor).
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the flags of a type element (attribute, parameter).
        RETURNS:
        The flags of the type element.
        NOTES:
        The flag bits are not externally documented. Use only the macros
        in the last section (ie. OCI_TYPEPARAM_IS_REQUIRED, and
        OCI_TYPEELEM_IS_REF) to test for them only. The type must be unpinned
        when the accessed information is no longer needed.
    */


    /*
        NAME: OCITypeElemNumPrec - Get a Number's Precision.    This includes float,
                            decimal, real, double, and oracle number.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the precision of a float, decimal, long, unsigned long, real,
        double, or Oracle number type.
        RETURNS:
        the precision of the float, decimal, long, unsigned long, real, double,
        or Oracle number
    */


    /*
        NAME: OCITypeElemNumScale - Get a decimal or oracle Number's Scale
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the scale of a decimal, or Oracle number type.
        RETURNS:
        the scale of the decimal, or Oracle number
    */


    /*
        NAME: OCITypeElemLength - Get a raw, fixed or variable length String's
                        length in bytes.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the length of a raw, fixed or variable length string type.
        RETURNS:
        length of the raw, fixed or variable length string
    */


    /*
        NAME: OCITypeElemCharSetID - Get a fixed or variable length String's
                    character set ID
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the character set ID of a fixed or variable length string type.
        RETURNS:
        character set ID of the fixed or variable length string
    */


    /*
        NAME: OCITypeElemCharSetForm - Get a fixed or variable length String's
                        character set specification form.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the attribute information in the object cache
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the character form of a fixed or variable length string type.
        The character form is an enumerated value that can be one of the
        4 values below:
                    SQLCS_IMPLICIT for CHAR, VARCHAR2, CLOB w/o a specified set
                    SQLCS_NCHAR        for NCHAR, NCHAR VARYING, NCLOB
                    SQLCS_EXPLICIT for CHAR, etc, with "CHARACTER SET ..." syntax
                    SQLCS_FLEXIBLE for PL/SQL "flexible" parameters
        RETURNS:
        character form of the fixed or variable string
    */


    /*
        NAME: OCITypeElemParameterizedType
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        type_stored (OUT) - If the function completes successfully,
                    and the parameterized type is complex, 'type_stored' is NULL.
                    Otherwise, 'type_stored' points to the type descriptor (in the
                    object cache) of the type that is stored in the parameterized
                    type.    The caller must allocate space for the OCIType*
                    before calling this routine and must not write into the space.
        REQUIRES:
        All input parameters must be valid.
        DESCRIPTION:
        Get a descriptor to the parameter type of a parameterized type.
        Parameterized types are types of the form:
            REF T
            VARRAY (n) OF T
        etc, where T is the parameter in the parameterized type.
        Additionally is_ref is set if the parameter is a PTR or REF.
        For example, it is set for REF T or VARRAY(n) OF REF T.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is null.
                2) 'type_stored' is not NULL but points to NULL data.
        NOTES:
        Complex parameterized types will be in a future release (once
        typedefs are supported.    When setting the parameterized type
        information, the user must typedef the contents if it's a
        complex parameterized type.    Ex. for varray<varray<car>>, use
        'typedef varray<car> varcar' and then use varray<varcar>.
    */


    /*
        NAME: OCITypeElemExtTypeCode - OCI Get an element's SQLT enumant.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the type element descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the internal Oracle typecode associated with an attribute's type.
        This is the actual typecode for the attribute when it gets mapped
        to a column in the Oracle database.
        RETURNS:
        The Oracle typecode associated with the attribute's type.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeAttrByName - OCI Get an Attribute By Name.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        name (IN) - the attribute's name
        n_length (IN) - length (in bytes) of the 'name' parameter
        elem (OUT) - If this function completes successfully, 'elem' points to
                    the selected type element descriptor pertaining to the
                    attributein the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) if 'tdo' is not null, it must point to a valid type descriptor
            in the object cache.
        DESCRIPTION:
        Get an attribute given its name.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) the type does not contain an attribute with the input 'name'.
                3) 'name' is NULL.
        NOTES:
        The type descriptor, 'tdo', must be unpinned when the accessed
        information is no longer needed.
        Schema and type names are CASE-SENSITIVE. If they have been created
        via SQL, you need to use uppercase names.
    */


    /*
        NAME: OCITypeAttrNext - OCI Get an Attribute By Iteration.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        iterator_ort (IN/OUT) - iterator for retrieving the next attribute;
                    see OCITypeIterNew() to initialize iterator.
        elem (OUT) - If this function completes successfully, 'elem' points to
                    the selected type element descriptor pertaining to the
                    attributein the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
                any accessor.
        2) if 'tdo' is not null, it must point to a valid type descriptor
            in the object cache.
        DESCRIPTION:
        Iterate to the next attribute to retrieve.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_NO_DATA if there are no more attributes to iterate on; use
                OCITypeIterSet() to reset the iterator if necessary.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeCollElem
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to the type descriptor in the object cache
        element (IN/OUT) - If the function completes successfully, this
                    points to the descriptor for the collection's element.
                    It is stored in the same format as an ADT attribute's
                    descriptor.
                    If *element is NULL, OCITypeCollElem() implicitly allocates a
                    new instance of OCITypeElem in the object cache. This instance
                    will be
                    automatically freed at the end of the session, and does not have
                    to be freed explicitly.
                    If *element is not NULL, OCITypeCollElem() assumes that it
                    points to a valid OCITypeElem descriptor and will copy the
                    results into it.
        REQUIRES:
        All input parameters must be valid.
        DESCRIPTION:
        Get a pointer to the descriptor (OCITypeElem) of the element of an
        array or the rowtype of a nested table.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is null.
                2) the type TDO does not point to a valid collection's type.
        NOTES:
        Complex parameterized types will be in a future release (once
        typedefs are supported.    When setting the parameterized type
        information, the user must typedef the contents if it's a
        complex parameterized type.    Ex. for varray<varray<car>>, use
        'typedef varray<car> varcar' and then use varray<varcar>.
    */


    /*
        NAME: OCITypeCollSize - OCI Get a Collection's Number of Elements.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to the type descriptor in the object cache
        num_elems (OUT) - number of elements in collection
        REQUIRES:
        All input parameters must be valid. tdo points to an array type
        defined as a domain.
        DESCRIPTION:
        Get the number of elements stored in a fixed array or the maximum
        number of elements in a variable array.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is null.
                2) 'tdo' does not point to a domain with a collection type.
        NOTES:
        Complex parameterized types will be in a future release (once
        typedefs are supported.    When setting the parameterized type
        information, the user must typedef the contents if it's a
        complex parameterized type.    Ex. for varray<varray<car>>, use
        'typedef varray<car> varcar' and then use varray<varcar>.
    */


    extern (C) sword OCITypeCollExtTypeCode (OCIEnv* env, OCIError* err, OCIType* tdo, OCITypeCode* sqt_code);
    /*
        NAME: ortcsqt - OCI Get a Collection element's DTY enumant.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to the type descriptor in the object cache
        sqt_code (OUT) - SQLT code of type element.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the SQLT enumant associated with an domain's element type.
        The SQLT codes are defined in <sqldef.h> and are needed for OCI/OOCI
        use.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is null.
                2) 'tdo' does not point to a domain with a collection type.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodOverload - OCI Get type's Number of Overloaded names
                    for the given method name.
        PARAMETERS:
        gp (IN/OUT) - pga environment handle.    Any errors are recorded here.
        tdo (IN) - pointer to to the type descriptor in the object cache
        method_name (IN) - the method's name
        m_length (IN) - length (in bytes) of the 'method_name' parameter
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) if 'tdo' is not null, it must point to a valid type descriptor
            in the object cache.
        DESCRIPTION:
        Overloading of methods implies that more than one method may have the
        same method name.    This routine returns the number of methods that
        have the given method name.    If there are no methods with the input
        method name, 'num_methods' is 0.    The caller uses this information when
        allocating space for the array of mdo and/or position pointers before
        calling 'OCITypeMethodByName()' or 'ortgmps()'.
        RETURNS:
        The number of methods with the given name. 0 if none contains the
        name.
        NOTES:
        Schema and type names are CASE-SENSITIVE. If they have been created
        via SQL, you need to use uppercase names.
    */


    /*
        NAME: OCITypeMethodByName - OCI Get one or more Methods with Name.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        method_name (IN) - the methods' name
        m_length (IN) - length (in bytes) of the 'name' parameter
        mdos (OUT) - If this function completes successfully, 'mdos' points to
            the selected methods in the object cache.    The caller must
            allocate space for the array of OCITypeMethod pointers before
            calling this routine and must not write into the space.
            The number of OCITypeMethod pointers that will be returned can
            be obtained by calling 'OCITypeMethodOverload()'.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) if 'tdo' is not null, it must point to a valid type descriptor
            in the object cache.
        DESCRIPTION:
        Get one or more methods given the name.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) No methods in type has name 'name'.
                3) 'mdos' is not NULL but points to NULL data.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
        Schema and type names are CASE-SENSITIVE. If they have been created
        via SQL, you need to use uppercase names.
    */


    /*
        NAME: OCITypeMethodNext - OCI Get a Method By Iteration.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        iterator_ort (IN/OUT) - iterator for retrieving the next method;
                    see OCITypeIterNew() to set iterator.
        mdo (OUT) - If this function completes successfully, 'mdo' points to
                    the selected method descriptor in the object cache.    Positions
                    start at 1.    The caller must allocate space for the
                    OCITypeMethod* before calling this routine and must not write
                    nto the space.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
                any accessor.
        2) if 'tdo' is not null, it must point to a valid type descriptor
            in the object cache.
        DESCRIPTION:
        Iterate to the next method to retrieve.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_NO_DATA if there are no more attributes to iterate on; use
                OCITypeIterSet() to reset the iterator if necessary.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) 'mdo' is not NULL but points to NULL data.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodName - OCI Get a Method's NaMe.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        n_length (OUT) - length (in bytes) of the 'name' parameter.    The caller
                    must allocate space for the ub4 before calling this routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the (non-unique) real name of the method.
        RETURNS:
        the non-unique name of the method or NULL if there is an error.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodEncap - Get a Method's ENcapsulation (private/public).
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the encapsulation (private, or public) of a method.
        RETURNS:
        the encapsulation (private, or public) of the method
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodFlags - OCI Get a Method's FLags
                            (inline, enumant, virtual, enumructor,
                            destructor).
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the flags (inline, enumant, virutal, enumructor, destructor) of
        a method.
        RETURNS:
        the flags (inline, enumant, virutal, enumructor, destructor) of
        the method
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodMap - OCI Get the Method's MAP function.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        mdo (OUT) - If this function completes successfully, and there is a
                    map function for this type, 'mdo' points to the selected method
                    descriptor in the object cache.    Otherwise, 'mdo' is null.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All required input parameters must not be NULL and must be valid.
        DESCRIPTION:
        A type may have only one map function.    'OCITypeMethodMap()' finds
        this function, if it exists, and returns a reference and a pointer to
        the method descriptor in the object cache.    If the type does not have a
        map (relative ordering) function, then 'mdo_ref' and 'mdo' are set
        to null and an error is returned.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                the type does not contain a map function.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodOrder - OCI Get the Method's ORder function.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        tdo (IN) - pointer to to the type descriptor in the object cache
        mdo (OUT) - If this function completes successfully, and there is a
                    map function for this type, 'mdo' points to the selected method
                    descriptor in the object cache.    Otherwise, 'mdo' is null.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All required input parameters must not be NULL and must be valid.
        DESCRIPTION:
        A type may have only one ORder or MAP function. 'OCITypeMethodOrder()'
        finds this function, if it exists, and returns a ref and a pointer
        to the method descriptor in the object cache.    If the type does not
        have a map (relative ordering) function, then 'mdo_ref' and 'mdo' are
        set to null and an error is returned.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                the type does not contain a map function.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeMethodParams - OCI Get a Method's Number of Parameters.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the number of parameters in a method.
        RETURNS:
        the number of parameters in the method
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeResult - OCI Get a method's result type descriptor.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        elem (OUT) - If this function completes successfully, 'rdo' points to
                    the selected result (parameter) descriptor in the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) 'elem' MUST be the address of an OCITypeElem pointer.
        DESCRIPTION:
        Get the result of a method.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) method returns no results.
        NOTES:
        The method must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeParamByPos - OCI Get a Parameter in a method By Position.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        position (IN) - the parameter's position.    Positions start at 1.
        elem (OUT) - If this function completes successfully, 'elem' points to
                    the selected parameter descriptor in the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        DESCRIPTION:
        Get a parameter given its position in the method.    Positions start
        at 1.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) 'position' is not >= 1 and <= the number of parameters in the
                    method.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeParamByName - OCI Get a Parameter in a method By Name.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        name (IN) - the parameter's name
        n_length (IN) - length (in bytes) of the 'name' parameter
        elem (OUT) - If this function completes successfully, 'elem' points to
                    the selected parameter descriptor in the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) if 'mdo' is not null, it must point to a valid method descriptor
            in the object cache.
        DESCRIPTION:
        Get a parameter given its name.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the required parameters is null.
                2) the method does not contain a parameter with the input 'name'.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeParamPos - OCI Get a parameter's position in a method
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        mdo (IN) - pointer to the method descriptor in the object cache
        name (IN) - the parameter's name
        n_length (IN) - length (in bytes) of the 'name' parameter
        position (OUT) - If this function completes successfully, 'position'
                    points to the position of the parameter in the method starting
                    at position 1. position MUST point to space for a ub4.
        elem (OUT) - If this function completes successfully, and
                    the input 'elem' is not NULL, 'elem' points to the selected
                    parameter descriptor in the object cache.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) if 'mdo' is not null, it must point to a valid method descriptor
            in the object cache.
        DESCRIPTION:
        Get the position of a parameter in a method.    Positions start at 1.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is null.
                2) the method does not contain a parameter with the input 'name'.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeElemParamMode - OCI Get a parameter's mode
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the parameter descriptor in the object cache
            (represented by an OCITypeElem)
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the mode (in, out, or in/out) of the parameter.
        RETURNS:
        the mode (in, out, or in/out) of the parameter
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeElemDefaultValue - OCI Get the element's Default Value.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        elem (IN) - pointer to the parameter descriptor in the object cache
            (represented by an OCITypeElem)
        d_v_length (OUT) - length (in bytes) of the returned default value.
                    The caller must allocate space for the ub4 before calling this
                    routine.
        REQUIRES:
        1) All type accessors require that the type be pinned before calling
            any accessor.
        2) All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Get the default value in text form (PL/SQL) of an element. For V8.0,
        this only makes sense for a method parameter.
        RETURNS:
        The default value (text) of the parameter.
        NOTES:
        The type must be unpinned when the accessed information is no
        longer needed.
    */


    /*
        NAME: OCITypeVTInit - OCI type Version table INItialize
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        REQUIRES:
        none
        DESCRIPTION:
        Allocate space for and initialize the type version table and the type
        version table's index.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if internal errors occurrs during initialization.
    */


    /*
        NAME: OCITypeVTInsert - OCI type Version table INSert entry.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        schema_name (IN, optional) - name of schema associated with the
                type.    By default, the user's schema name is used.
        s_n_length (IN) - length of the 'schema_name' parameter
        type_name (IN) - type name to insert
        t_n_length (IN) - length (in bytes) of the 'type_name' parameter
        user_version (IN) - user readable version of the type
        u_v_length (IN) - length (in bytes) of the 'user_version' parameter
        REQUIRES:
        none
        DESCRIPTION:
        Insert an entry into the type version table and the type version
        table's index.    The entry's type name and user readable version
        fields are updated with the input values.    All other fields are
        initialized to null.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is invalid.
                2) an entry for 'type_name' has already been registered in the
                    type version table.
    */


    /*
        NAME: OCITypeVTSelect - OCI type Version table SELect entry.
        PARAMETERS:
        env (IN/OUT) - OCI environment handle initialized in object mode
        err (IN/OUT) - error handle. If there is an error, it is
            recorded in 'err' and this function returns OCI_ERROR.
            The error recorded in 'err' can be retrieved by calling
            OCIErrorGet().
        schema_name (IN, optional) - name of schema associated with the
                type.    By default, the user's schema name is used.
        s_n_length (IN) - length of the 'schema_name' parameter
        type_name (IN) - type name to select
        t_n_length (IN) - length (in bytes) of the 'type_name' parameter
        user_version (OUT, optional) - pointer to user readable version of the
            type
        u_v_length (OUT, optional) - length (in bytes) of the 'user_version'
            parameter
        version (OUT, optional) - internal type version
        REQUIRES:
        All input parameters must not be NULL and must be valid.
        DESCRIPTION:
        Select an entry in the type version table by name.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_INVALID_HANDLE if 'env' or 'err' is null.
        OCI_ERROR if
                1) any of the parameters is invalid.
                2) an entry with 'type_name' does not exist.
    */




    extern (C) sword OCITypeBeginCreate (OCISvcCtx* svchp, OCIError* errhp, OCITypeCode tc, OCIDuration dur, OCIType** type);
    /*
        NAME: OCITypeBeginCreate - OCI Type Begin Creation of a transient type.
        REMARKS
                Begins the enumruction process for a transient type. The type will be
                anonymous (no name). To create a persistent named type, the CREATE TYPE
                statement should be used from SQL. Transient types have no identity.
                They are pure values.
        PARAMETERS:
                svchp (IN)                - The OCI Service Context.
                errhp (IN/OUT)        - The OCI error handle. If there is an error, it is
                    recorded in errhp and this function returns
                    OCI_ERROR. Diagnostic information can be obtained by
                    calling OCIErrorGet().
                tc                                - The TypeCode for the type. The Typecode could
                    correspond to a User Defined Type or a Built-in type.
                    Currently, the permissible values for User Defined
                    Types are OCI_TYPECODE_OBJECT for an Object Type
                    (structured), OCI_TYPECODE_VARRAY for a VARRAY
                    collection type or OCI_TYPECODE_TABLE for a nested
                    table collection type. For Object types,
                    OCITypeAddAttr() needs to be called to add each of
                    the attribute types. For Collection types,
                    OCITypeSetCollection() needs to be called.
                    Subsequently, OCITypeEndCreate() needs to be called
                    to finish the creation process.
                    The permissible values for Built-in type codes are
                    specified in the user manual. Additional information
                    on built-ins if any (like precision, scale for
                    numbers, character set info for VARCHAR2s etc.) must
                    be set with a subsequent call to OCITypeSetBuiltin().
                    Subsequently OCITypeEndCreate() needs to be called
                    to finish the creation process.
                dur                            - The allocation duration for the Type. Could be a
                    predefined or a user defined duration.
                type(OUT)                - The OCIType (Type Descriptor) that is being
                    enumructed.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR on error.
    */


    extern (C) sword OCITypeSetCollection (OCISvcCtx* svchp, OCIError* errhp, OCIType* type, OCIParam* collelem_info, ub4 coll_count);
    /*
        NAME: OCITypeSetCollection - OCI Type Set Collection information
        REMARKS :
                Set Collection type information. This call can be called only if the
                OCIType has been enumructed with a collection typecode.
        PARAMETERS:
                svchp (IN)            -    The OCI Service Context.
                errhp (IN/OUT)    -    The OCI error handle. If there is an error, it is
                    recorded in errhp and this function returns
                    OCI_ERROR. Diagnostic information can be obtained by
                    calling OCIErrorGet().
                type(IN OUT)        -    The OCIType (Type Descriptor) that is being
                    enumructed.
                collelem_info        -    collelem_info provides information on the collection
                    element. It is obtained by allocating an OCIParam
                    (parameter handle) and setting type information in
                    the OCIParam using OCIAttrSet() calls.
                coll_count            -    The count of elements in the collection. Pass 0 for
                    a nested table (unbounded).
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR on error.
    */


    extern (C) sword OCITypeSetBuiltin (OCISvcCtx* svchp, OCIError* errhp, OCIType* type, OCIParam* builtin_info);
    /*
        NAME: OCITypeSetBuiltin - OCI Type Set Builtin information.
        REMARKS:
                Set Built-in type information. This call can be called only if the
                OCIType has been enumructed with a built-in typecode
                (OCI_TYPECODE_NUMBER etc.).
        PARAMETERS:
                svchp (IN)                - The OCI Service Context.
                errhp (IN/OUT)        - The OCI error handle. If there is an error, it is
                    recorded in errhp and this function returns
                    OCI_ERROR. Diagnostic information can be obtained by
                    calling OCIErrorGet().
                type(IN OUT)            - The OCIType (Type Descriptor) that is being
                    enumructed.
                builtin_info            - builtin_info provides information on the built-in
                    (like precision, scale, charater set etc.). It is
                    obtained by allocating an OCIParam (parameter handle)
                    and setting type information in the OCIParam using
                    OCIAttrSet() calls.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR on error.
    */


    extern (C) sword OCITypeAddAttr (OCISvcCtx* svchp, OCIError* errhp, OCIType* type, oratext* a_name, ub4 a_length, OCIParam* attr_info);
    /*
        NAME: OCITypeAddAttr - OCI Type Add Attribute to an Object Type.
        REMARKS:
                Adds an attribute to an Object type (that was enumructed earlier with
                typecode OCI_TYPECODE_OBJECT).
        PARAMETERS:
                svchp (IN)                - The OCI Service Context
                errhp (IN/OUT)        - The OCI error handle. If there is an error, it is
                    recorded in errhp and this function returns
                    OCI_ERROR. Diagnostic information can be obtained by
                    calling OCIErrorGet().
                type (IN/OUT)        - The Type description that is being enumructed.
                a_name(IN)                - Optional. gives the name of the attribute.
                a_length                    - Optional. gives length of attribute name.
                attr_info                - Information on the attribute. It is obtained by
                    allocating an OCIParam (parameter handle) and setting
                    type information in the OCIParam using OCIAttrSet()
                    calls.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR on error.
    */


    extern (C) sword OCITypeEndCreate (OCISvcCtx* svchp, OCIError* errhp, OCIType* type);
    /*
        NAME: OCITypeEndCreate - OCI Type End Creation
        REMARKS:
                Finishes enumruction of a type description.Subsequently, only access
                will be allowed.
        PARAMETERS:
                svchp (IN)                - The OCI Service Context
                errhp (IN/OUT)        - The OCI error handle. If there is an error, it is
                    recorded in errhp and this function returns
                    OCI_ERROR. Diagnostic information can be obtained by
                    calling OCIErrorGet().
                type (IN/OUT)        - The Type description that is being enumructed.
        RETURNS:
        OCI_SUCCESS if the function completes successfully.
        OCI_ERROR on error.
    */

    enum uint OCI_TYPEELEM_REF        = 0x8000;    /// Element is a reference.
    enum uint OCI_TYPEPARAM_REQUIRED    = 0x0800;    /// Parameter is required.

    /**
    *
    */
    bool OCI_TYPEELEM_IS_REF (uint elem_flag) {
        return elem_flag && OCI_TYPEELEM_REF;
    }

    /**
    *
    */
    bool OCI_TYPEPARAM_IS_REQUIRED (uint param_flag) {
        return param_flag && OCI_TYPEPARAM_REQUIRED;
    }





    enum uint XIDDATASIZE            = 128;        /// Size in bytes.
    enum uint MAXGTRIDSIZE            = 64;        /// Maximum size in bytes of gtrid.
    enum uint MAXBQUALSIZE            = 64;        /// Maximum size in bytes of bqual.

    /**
    * Transaction branch identification: XID and NULLXID:
    *
    * A value of -1 in formatID means that the XID is null.
    */
    struct xid_t {
        int formatID;                    /// Format identifier.
        int gtrid_length;                /// Value from 1 through 64.
        int bqual_length;                /// Value from 1 through 64.
        char[XIDDATASIZE] data;                /// Transaction data.
    }
    alias xid_t XID;

    /**
    * Declarations of routines by which RMs call TMs:
    */
    extern (C) int ax_reg (int, XID*, int);

    /**
    * ditto
    */
    extern (C) int ax_unreg (int, int);

    enum uint RMNAMESZ            = 32;        /// Length of resource manager name,    including the null terminator.
    enum uint MAXINFOSIZE            = 256;        /// Maximum size in bytes of xa_info strings, including the null terminator.

    /*
    * XA Switch Data Structure.
    */
    struct xa_switch_t {
        char[RMNAMESZ] name;                /// Name of resource manager.
        int flags;                    /// Resource manager specific options.
        int xaversion;                    /// Must be 0.
        extern (C) int function(char*, int, int) xa_open_entry; ///
        extern (C) int function(char*, int, int) xa_close_entry; ///
        extern (C) int function(XID*, int, int) xa_start_entry; ///
        extern (C) int function(XID*, int, int) xa_end_entry; ///
        extern (C) int function(XID*, int, int) xa_rollback_entry; ///
        extern (C) int function(XID*, int, int) xa_prepare_entry; ///
        extern (C) int function(XID*, int, int) xa_commit_entry; ///
        extern (C) int function(XID*, int, int, int) xa_recover_entry; ///
        extern (C) int function(XID*, int, int) xa_forget_entry; ///
        extern (C) int function(int*, int*, int, int) xa_complete_entry; ///
    }

    enum ulong TMNOFLAGS            = 0x00000000;    /// No resource manager features selected.
    enum ulong TMREGISTER            = 0x00000001;    /// Resource manager dynamically registers.
    enum ulong TMNOMIGRATE            = 0x00000002;    /// Resource manager does not support association migration.
    enum ulong TMUSEASYNC            = 0x00000004;    /// Resource manager supports asynchronous operations.
    enum ulong TMASYNC            = 0x80000000;    /// Perform routine asynchronously.
    enum ulong TMONEPHASE            = 0x40000000;    /// Caller is using one-phase commit optimization.
    enum ulong TMFAIL            = 0x20000000;    /// Dissociates caller and marks transaction branch rollback-only.
    enum ulong TMNOWAIT            = 0x10000000;    /// Return if blocking condition exists.
    enum ulong TMRESUME            = 0x08000000;    /// Caller is resuming association with suspended transaction branch.
    enum ulong TMSUCCESS            = 0x04000000;    /// Dissociate caller from transaction branch.
    enum ulong TMSUSPEND            = 0x02000000;    /// Caller is suspending, not ending, association.
    enum ulong TMSTARTRSCAN        = 0x01000000;    /// Start a recovery scan.
    enum ulong TMENDRSCAN            = 0x00800000;    /// End a recovery scan.
    enum ulong TMMULTIPLE            = 0x00400000;    /// Wait for any asynchronous operation.
    enum ulong TMJOIN            = 0x00200000;    /// Caller is joining existing transaction branch.
    enum ulong TMMIGRATE            = 0x00100000;    /// Caller intends to perform migration.

    enum ulong TM_JOIN            = 2;        /// Caller is joining existing transaction branch .
    enum ulong TM_RESUME            = 1;        /// Caller is resuming association with suspended transaction branch.
    enum ulong TM_OK            = 0;        /// Normal execution.
    enum long TMER_TMERR            = -1;        /// An error occurred in the transaction manager.
    enum long TMER_INVAL            = -2;        /// Invalid arguments were given.
    enum long TMER_PROTO            = -3;        /// Routine invoked in an improper context.

    enum ulong XA_RBBASE            = 100;        /// The inclusive lower bound of the rollback codes.
    enum ulong XA_RBROLLBACK        = XA_RBBASE;    /// The rollback was caused by an unspecified reason.
    enum ulong XA_RBCOMMFAIL        = XA_RBBASE + 1;/// The rollback was caused by a communication failure.
    enum ulong XA_RBDEADLOCK        = XA_RBBASE + 2;/// A deadlock was detected.
    enum ulong XA_RBINTEGRITY        = XA_RBBASE + 3;/// A condition that violates the integrity of the resources was detected.
    enum ulong XA_RBOTHER            = XA_RBBASE + 4;/// The resource manager rolled back the transaction for a reason not on this list.
    enum ulong XA_RBPROTO            = XA_RBBASE + 5;/// A protocal error occurred in the resource manager.
    enum ulong XA_RBTIMEOUT        = XA_RBBASE + 6;/// A transaction branch took too long.
    enum ulong XA_RBTRANSIENT        = XA_RBBASE + 7;/// May retry the transaction branch.
    enum ulong XA_RBEND            = XA_RBTRANSIENT; /// The inclusive upper bound of the rollback codes.

    enum ulong XA_NOMIGRATE        = 9;        /// Resumption must occur where suspension occurred.
    enum ulong XA_HEURHAZ            = 8;        /// The transaction branch may have been heuristically completed.
    enum ulong XA_HEURCOM            = 7;        /// The transaction branch has been heuristically comitted.
    enum ulong XA_HEURRB            = 6;        /// The transaction branch has been heuristically rolled back.
    enum ulong XA_HEURMIX            = 5;        /// The transaction branch has been heuristically committed and rolled back.
    enum ulong XA_RETRY            = 4;        /// Routine returned with no effect and may be re-issued.
    enum ulong XA_RDONLY            = 3;        /// The transaction was read-only and has been committed.
    enum ulong XA_OK            = 0;        /// Normal execution.
    enum long XAER_ASYNC            = -2;        /// Asynchronous operation already outstanding.
    enum long XAER_RMERR            = -3;        /// A resource manager error occurred in the transaction branch.
    enum long XAER_NOTA            = -4;        /// The XID is not valid.
    enum long XAER_INVAL            = -5;        /// Invalid arguments were given.
    enum long XAER_PROTO            = -6;        /// Routine invoked in an improper context.
    enum long XAER_RMFAIL            = -7;        /// Resource manager unavailable.
    enum long XAER_DUPID            = -8;        /// The XID already exists.
    enum long XAER_OUTSIDE            = -9;        /// Resource manager doing work outside global transaction.
}
