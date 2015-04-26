/**
 * DDBC - D DataBase Connector - abstraction layer for RDBMS access, with interface similar to JDBC. 
 * 
 * Source file ddbc/drivers/oracleddbc.d.
 *
 * DDBC library attempts to provide implementation independent interface to different databases.
 * 
 * Set of supported RDBMSs can be extended by writing Drivers for particular DBs.
 * 
 * JDBC documentation can be found here:
 * $(LINK http://docs.oracle.com/javase/1.5.0/docs/api/java/sql/package-summary.html)$(BR)
 *
 * This module contains implementation of Oracle DB Driver
 * 
 *
 * You can find usage examples in unittest{} sections.
 *
 * Copyright: Copyright 2015
 * License:   $(LINK www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Author:   Igor Stepanov
 */
module ddbc.drivers.oracleddbc;

version(USE_ORACLE) 
{
import std.algorithm;
import std.conv;
import std.datetime;
import std.exception;
import std.stdio;
import std.string;
import std.variant;
import core.sync.mutex;

import ddbc.common;
import ddbc.core;
import ddbc.drivers.utils;
import ddbc.drivers.oracle;


SqlType fromOracleType(ushort t) 
{
    switch(t)
    {
        case SQLT_CHR:
        case SQLT_STR:
        case SQLT_LNG:
        case SQLT_VCS:
        case SQLT_VBI:
        case SQLT_BIN:
        case SQLT_LBI:
        case SQLT_LVC:
        case SQLT_LVB:
        case SQLT_AFC:
        case SQLT_AVC:
        case SQLT_VST:
            return SqlType.VARCHAR;
        case SQLT_INT:
        case SQLT_UIN:
            return SqlType.INTEGER;
        case SQLT_NUM:
        case SQLT_FLT:
        case SQLT_VNU:
        case SQLT_BFLOAT:
        case SQLT_BDOUBLE:
            return SqlType.NUMERIC;
        case SQLT_DAT:
        case SQLT_ODT:
        case SQLT_DATE:
        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_TZ:
        case SQLT_TIMESTAMP_LTZ:
            return SqlType.DATETIME;
        case SQLT_CLOB:
            return SqlType.CLOB;
        case SQLT_BLOB:
            return SqlType.BLOB;
        /*
        case SQLT_RDD:
        case SQLT_NTY:
        case SQLT_REF:
        case SQLT_INTERVAL_YM:
        case SQLT_INTERVAL_DS:
        */
        default:
            return SqlType.OTHER;
    }
}

ushort oracleTypeToSupported(ushort t) 
{
    switch(t)
    {
        case SQLT_CHR:
        case SQLT_STR:
        case SQLT_LNG:
        case SQLT_VCS:
        case SQLT_VBI:
        case SQLT_BIN:
        case SQLT_LBI:
        case SQLT_LVC:
        case SQLT_LVB:
        case SQLT_AFC:
        case SQLT_AVC:
        case SQLT_VST:
            return SQLT_CHR;
        case SQLT_INT:
            return SQLT_INT;
        case SQLT_UIN:
            return SQLT_UIN;
        case SQLT_NUM:
        case SQLT_FLT:
        case SQLT_VNU:
            return SQLT_CHR; //D std lib doesn't have a BigDecimal type. Thus we may return numeric field as string;
        case SQLT_BFLOAT:
        case SQLT_IBFLOAT:
        case SQLT_BDOUBLE:
        case SQLT_IBDOUBLE:
            return SQLT_BDOUBLE;
        case SQLT_DAT:
        case SQLT_ODT:
        case SQLT_DATE:
        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_TZ:
        case SQLT_TIMESTAMP_LTZ:
            return SQLT_TIMESTAMP;
        case SQLT_CLOB:
            return SQLT_CLOB;
        case SQLT_BLOB:
            return SQLT_BLOB;
        default:
            return cast(ushort)-1;
    }
}

ushort toOracleType(SqlType t) 
{
    switch(t)
    {
        case SqlType.VARCHAR:
            return SQLT_CHR;
        case SqlType.INTEGER:
            return SQLT_INT;
        case SqlType.NUMERIC:
            return SQLT_BDOUBLE; 
        case SqlType.DATE:    
        case SqlType.DATETIME:
            return SQLT_TIMESTAMP;   
        case SqlType.CLOB:
            return SQLT_CLOB;  
        case SqlType.BLOB:
            return SQLT_BLOB;
        default:            
            return cast(ushort)-1;
    }
}


shared static this()
{
    OCIInitialize(OCI_DEFAULT, null, null, null, null);
}

shared static ~this()
{
    OCITerminate(OCI_DEFAULT);
}

class OracleConnection : ddbc.core.Connection 
{
private:
    enum transaction_time = 60;
    uint autocommitflag = OCI_COMMIT_ON_SUCCESS;
    bool closed;
    Mutex mutex;
    
    OCIEnv*       env;
    OCIError*     err;
    OCIServer*    srv;
    OCISvcCtx*    svc;
    OCISession*   ses;

    OracleStatement[] activeStatements;

	void closeUnclosedStatements() 
    {
		foreach(stmt; activeStatements)
        {
			stmt.close();
		}
	}

    void checkClosed() 
    {
		if (closed)
			throw new SQLException("Connection is already closed");
	}
    
    void checkerr(sword status)
    {
        char[] errbuf = new char[512];
        ub4 buflen;
        sb4 errcode;
        string err_msg;
        switch (status) 
        {
            case OCI_ERROR:
              OCIErrorGet (err, 1, null, &errcode, errbuf.ptr, cast(uint)errbuf.length, OCI_HTYPE_ERROR);
              err_msg = cast(string)fromStringz(errbuf.ptr);
              break;
            case OCI_INVALID_HANDLE:
                err_msg = "Error: OCI_INVALID_HANDLE";
                break;
            default:
                break;
        }
        if (err_msg.length)
            throw new SQLException(err_msg);
    }
public:
    this(string url, string[string] params) 
    {
        mutex = new Mutex();
        string username = params.get("user", "");
        string password = params.get("password", "");
        enforceEx!SQLException(OCIEnvNlsCreate(&env, 0, null, null, null, null, 0, null, 0, 0) == OCI_SUCCESS,
            "OCIEnvNlsCreate error");
        OCIHandleAlloc(env, cast(void**)&err, OCI_HTYPE_ERROR,   0, null);
        OCIHandleAlloc(env, cast(void**)&srv, OCI_HTYPE_SERVER,  0, null);
        OCIHandleAlloc(env, cast(void**)&svc, OCI_HTYPE_SVCCTX,  0, null);
        OCIHandleAlloc(env, cast(void**)&ses, OCI_HTYPE_SESSION, 0, null);
        checkerr(OCIServerAttach(srv, err,  cast(char*)url.ptr, cast(uint)url.length, OCI_DEFAULT));
        
        checkerr(OCIAttrSet(svc, OCI_HTYPE_SVCCTX, srv, 0, OCI_ATTR_SERVER, err));

        OCIHandleAlloc(env, cast(void**)&ses, OCI_HTYPE_SESSION,0, null);

        checkerr(OCIAttrSet(ses, OCI_HTYPE_SESSION, cast(void*)username.ptr, cast(uint)username.length, OCI_ATTR_USERNAME, err));
        checkerr(OCIAttrSet(ses, OCI_HTYPE_SESSION, cast(void*)password.ptr, cast(uint)password.length, OCI_ATTR_PASSWORD, err));
        checkerr(OCISessionBegin (svc, err, ses, OCI_CRED_RDBMS, OCI_DEFAULT));
 
        checkerr(OCIAttrSet(svc, OCI_HTYPE_SVCCTX, ses, 0, OCI_ATTR_SESSION, err));

        closed = false;
    }


    void lock() 
    {
        mutex.lock();
    }

    void unlock() 
    {
        mutex.unlock();
    }

    
    override void close() 
    {
        lock();
        scope(exit) unlock();
        if (closed)
            return;
        closeUnclosedStatements();
        if (ses) OCIHandleFree(err, OCI_HTYPE_SESSION);
        if (svc) OCIHandleFree(svc, OCI_HTYPE_SVCCTX);
        if (srv) OCIHandleFree(srv, OCI_HTYPE_SERVER);
        if (err) OCIHandleFree(err, OCI_HTYPE_ERROR);
        if (env) OCIHandleFree(env, OCI_HTYPE_ENV);
              
        closed = true;
    }
    
    override void commit() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        checkerr(OCITransCommit(svc, err, 0));
    }
    
    override void rollback() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        checkerr(OCITransRollback(svc, err, 0));
    }
    override bool getAutoCommit() 
    {
        return autocommitflag == OCI_COMMIT_ON_SUCCESS;
    }
    override void setAutoCommit(bool autoCommit) 
    {
        checkClosed();
        if (getAutoCommit() == autoCommit)
            return;
        lock();
        scope(exit) unlock();

        if (!autoCommit)
        {
            autocommitflag = OCI_DEFAULT;
        }
        else
        {
            checkerr(OCITransCommit(svc, err, 0));
            autocommitflag = OCI_COMMIT_ON_SUCCESS;
        }
    }
    
    override OracleStatement createStatement() 
    {
        checkClosed();

        lock();
        scope(exit) unlock();
        auto stmt = new OracleStatement(this);
        activeStatements ~= stmt;
        return stmt;
    }

    OraclePreparedStatement prepareStatement(string sql) 
    {
        checkClosed();

        lock();
        scope(exit) unlock();

        auto stmt = new OraclePreparedStatement(this, sql);
        activeStatements ~= stmt;
        return stmt;
    }

    override string getCatalog() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        char* ptr = null;
        uint len = 0;
        
        checkerr(OCIAttrGet(srv, OCI_HTYPE_SERVER, &ptr, &len, OCI_ATTR_INTERNAL_NAME, err)); 
        return cast(string)ptr[0 .. len];
    }

    /// Sets the given catalog name in order to select a subspace of this Connection object's database in which to work.
    override void setCatalog(string catalog) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        char* ptr = cast(char*)catalog.ptr;
        checkerr(OCIAttrSet(srv, OCI_HTYPE_SERVER, ptr, cast(uint)catalog.length, OCI_ATTR_INTERNAL_NAME, err));
    }

    override bool isClosed() 
    {
        return closed;
    }
}

class OracleStatement : Statement 
{
private:
    OracleConnection conn;
	OracleResultSet resultSet;
    bool closed;
    OCIStmt *stmt;

    void checkClosed() 
    {
        enforceEx!SQLException(!closed, "Statement is already closed");
    }
    
    ub2 getState()
    {
        ub2 state;
        conn.checkerr(OCIAttrGet(stmt, OCI_HTYPE_STMT, &state, null, OCI_ATTR_STMT_STATE, conn.err)); 
        return state;
    }
    void checkReady() 
    {
        enforceEx!SQLException(getState() == OCI_STMT_STATE_INITIALIZED, "Statement is already executed");
    }
    

    void lock() 
    {
        conn.lock();
    }
    
    void unlock() 
    {
        conn.unlock();
    }

    this(OracleConnection conn) 
    {
        this.conn = conn;
        conn.checkerr(OCIHandleAlloc(conn.env, cast(void**)&stmt, OCI_HTYPE_STMT, 0, null));
    }
public:
    OracleConnection getConnection() 
    {
        checkClosed();
        return conn;
    }
    override OracleResultSet executeQuery(string query) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        checkReady();
        conn.checkerr(OCIStmtPrepare(stmt, conn.err, cast(char*)query.ptr, cast(uint)query.length, OCI_NTV_SYNTAX, OCI_DEFAULT));
        conn.checkerr(OCIStmtExecute(conn.svc, stmt, conn.err, 1, 0, null, null, OCI_DESCRIBE_ONLY));
		resultSet = new OracleResultSet(this);
        return resultSet;
	}
    override int executeUpdate(string query) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        checkReady();
        conn.checkerr(OCIStmtPrepare(stmt, conn.err, cast(char*)query.ptr, cast(uint)query.length, OCI_NTV_SYNTAX, OCI_DEFAULT));
        conn.checkerr(OCIStmtExecute(conn.svc, stmt, conn.err, 1, 0, null, null, conn.autocommitflag));
        ub4 row_count;
        conn.checkerr(OCIAttrGet(stmt, OCI_HTYPE_STMT, &row_count, null, OCI_ATTR_ROW_COUNT, conn.err));
        return cast(int)row_count;
    }
	override int executeUpdate(string query, out Variant insertId) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
        
        throw new SQLException("executeUpdate(query, insertId) is not implemented for the Oracle driver");
	}
	override void close() 
    {
        lock();
        scope(exit) unlock();
        if (closed)
            return;
        if (resultSet)
            resultSet.close();
        conn.checkerr(OCIHandleFree(stmt, OCI_HTYPE_STMT));
        closed = true;
    }
}

class OraclePreparedStatement : OracleStatement, PreparedStatement 
{
private:
    string query;
    int paramCount;
    ParameterMetaData paramMetadata;
    void*[] ptrs;
    ub2[] types;
    this(OracleConnection conn, string query) 
    {
        super(conn);
        this.query = query;
        conn.checkerr(OCIStmtPrepare(stmt, conn.err, cast(char*)query.ptr, cast(uint)query.length, OCI_NTV_SYNTAX, OCI_DEFAULT));
        
        sb4	found;
        char* name;
        ub1	nlength;
        char* indicator;
        ub1	ilength;
        ub1	dupl;
        OCIBind* hndl;
        conn.checkerr(OCIStmtGetBindInfo(stmt, conn.err, 1, 1, &found, &name, &nlength, &indicator, &ilength, &dupl, cast()&hndl));
        paramCount = found < 0 ? -found : found;
        ptrs.length = paramCount * 3;
        types.length = paramCount;
    }
public:
    override void close()
    {
        foreach(i, v; types)
        {
            if (v == SQLT_TIMESTAMP)
            {
                conn.checkerr(OCIDescriptorFree(*cast(void**)ptrs[i * 3], OCI_DTYPE_TIMESTAMP));
            }
        }
        super.close();
    }
    /// Retrieves a ResultSetMetaData object that contains information about the columns of the ResultSet object that will be returned when this PreparedStatement object is executed.
    override ResultSetMetaData getMetaData() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        if (resultSet)
            return resultSet.metadata;
        else
            return null;
    }

    /// Retrieves the number, types and properties of this PreparedStatement object's parameters.
    override ParameterMetaData getParameterMetaData() 
    {
        checkClosed();
        lock();
        throw new SQLException("getParameterMetaData() is not implemented for the Oracle driver");
    }

    override int executeUpdate() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        conn.checkerr(OCIStmtExecute(conn.svc, stmt, conn.err, 1, 0, null, null, conn.autocommitflag));
        ub4 row_count;
        conn.checkerr(OCIAttrGet(stmt, OCI_HTYPE_STMT, &row_count, null, OCI_ATTR_ROW_COUNT, conn.err));
        return cast(int)row_count;
    }

	override int executeUpdate(out Variant insertId) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
        
        throw new SQLException("executeUpdate(query, insertId) is not implemented for the Oracle driver");
	}

    override ddbc.core.ResultSet executeQuery() 
    {
        checkClosed();
        lock();
        conn.checkerr(OCIStmtExecute(conn.svc, stmt, conn.err, 1, 0, null, null, OCI_DESCRIBE_ONLY));
		resultSet = new OracleResultSet(this);
        return resultSet;
    }
    
    override void clearParameters() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        for (int i = 1; i <= paramCount; i++)
            setNull(i);
    }
    
	override void setFloat(int parameterIndex, float x) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
        setDouble(parameterIndex, x);
	}
	override void setDouble(int parameterIndex, double x)
    {
		checkClosed();
		lock();
		scope(exit) unlock();
        enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto data = new double(x);
        auto ind = new sb2(0);
        ptrs[(parameterIndex - 1) * 3] = data; /    o avoid unexpected GC clean
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        types[parameterIndex - 1] = SQLT_BDOUBLE;
        conn.checkerr(OCIBindByPos(stmt, &bindpp, conn.err,
                     parameterIndex,
                     data,
                     x.sizeof,
                     SQLT_BDOUBLE,
                     ind,
                     null,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
	}
	override void setBoolean(int parameterIndex, bool x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setLong(parameterIndex, x ? 1 : 0);
    }
    override void setLong(int parameterIndex, long x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto data = new long(x);
        auto ind = new sb2(0);
        ptrs[(parameterIndex - 1) * 3] = data;
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        types[parameterIndex - 1] = SQLT_INT;
        conn.checkerr(OCIBindByPos(stmt, &bindpp, conn.err,
                     parameterIndex,
                     data,
                     x.sizeof,
                     SQLT_INT,
                     ind,
                     null,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
    }
    override void setUlong(int parameterIndex, ulong x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto data = new ulong(x);
        auto ind = new sb2(0);
        ptrs[(parameterIndex - 1) * 3] = data;
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        types[parameterIndex - 1] = SQLT_UIN;
        conn.checkerr(OCIBindByPos (stmt, &bindpp, conn.err,
                     parameterIndex,
                     data,
                     x.sizeof,
                     SQLT_UIN,
                     ind,
                     null,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
    }
    override void setInt(int parameterIndex, int x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setLong(parameterIndex, x);
    }
    override void setUint(int parameterIndex, uint x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setUlong(parameterIndex, x);
    }
    override void setShort(int parameterIndex, short x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setLong(parameterIndex, x);
    }
    override void setUshort(int parameterIndex, ushort x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setUlong(parameterIndex, x);
    }
    override void setByte(int parameterIndex, byte x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setLong(parameterIndex, x);
    }
    override void setUbyte(int parameterIndex, ubyte x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setUlong(parameterIndex, x);
    }
    override void setBytes(int parameterIndex, byte[] x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setUbytes(parameterIndex, *cast(ubyte[]*)&x);
    }
    override void setUbytes(int parameterIndex, ubyte[] x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto ind = new sb2(0);
        auto len = new ushort(cast(ushort)x.length);
        ptrs[(parameterIndex - 1) * 3] = cast(void*)x.ptr;
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        ptrs[(parameterIndex - 1) * 3 + 2] = len;
        types[parameterIndex - 1] = SQLT_BIN;
        conn.checkerr(OCIBindByPos (stmt, &bindpp, conn.err,
                     parameterIndex,
                     x.ptr,
                     cast(uint)x.length,
                     SQLT_BIN,
                     ind,
                     len,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
    }
    override void setString(int parameterIndex, string x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto ind = new sb2(0);
        auto len = new ushort(cast(ushort)x.length);
        ptrs[(parameterIndex - 1) * 3] = cast(void*)x.ptr;
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        ptrs[(parameterIndex - 1) * 3 + 2] = len;
        types[parameterIndex - 1] = SQLT_CHR;
        conn.checkerr(OCIBindByPos (stmt, &bindpp, conn.err,
                     parameterIndex,
                     cast(void*)x.ptr,
                     cast(uint)x.length,
                     SQLT_CHR,
                     ind,
                     len,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
    }
	override void setDateTime(int parameterIndex, DateTime x) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		enforceEx!SQLException(parameterIndex <= paramCount, "parameter index "~parameterIndex.to!string~" is out of bounds");
        OCIBind* bindpp;
        auto ind = new sb2(0);
        OCIDateTime** ptstmpltz = new OCIDateTime*;
        conn.checkerr(OCIDescriptorAlloc(conn.env, cast(void**)ptstmpltz, OCI_DTYPE_TIMESTAMP, 0, null));
        auto tz = LocalTime().stdName();
        conn.checkerr(OCIDateTimeConstruct(conn.env, conn.err, *ptstmpltz,
					cast(short)x.date.year, 
                    cast(ubyte)x.date.month,
                    cast(ubyte)x.date.day,
                    cast(ubyte)x.timeOfDay.hour,
                    cast(ubyte)x.timeOfDay.minute,
                    cast(ubyte)x.timeOfDay.second,
                    0,
					cast(char*)tz.ptr, 
                    cast(uint)tz.length));
        
        
        
        ptrs[(parameterIndex - 1) * 3] = cast(void*)ptstmpltz;
        ptrs[(parameterIndex - 1) * 3 + 1] = ind;
        ptrs[(parameterIndex - 1) * 3 + 2] = cast(void*)tz.ptr;
        
        types[parameterIndex - 1] = SQLT_TIMESTAMP;
        conn.checkerr(OCIBindByPos (stmt, &bindpp, conn.err,
                     parameterIndex,
                     ptstmpltz,
                     (OCIDateTime*).sizeof,
                     SQLT_TIMESTAMP,
                     ind,
                     null,
                     null,
                     0,
                     null, 
                     OCI_DEFAULT));
	}
	override void setDate(int parameterIndex, Date x) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		setDateTime(parameterIndex, DateTime(x));
	}
	override void setTime(int parameterIndex, TimeOfDay x) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		setDateTime(parameterIndex, DateTime(Date.init, x));
	}
	override void setVariant(int parameterIndex, Variant x) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        if (x == Variant.init)
            setNull(parameterIndex);
        else if (x.convertsTo!(bool))
            setBoolean(parameterIndex, x.get!(bool));
        else if (x.convertsTo!(long))
            setLong(parameterIndex, x.get!(long));
        else if (x.convertsTo!(ulong))
            setUlong(parameterIndex, x.get!(ulong));
        else if (x.convertsTo!(double))
            setDouble(parameterIndex, x.get!(double));
        else if (x.convertsTo!(byte[]))
            setBytes(parameterIndex, x.get!(byte[]));
        else if (x.convertsTo!(ubyte[]))
            setUbytes(parameterIndex, x.get!(ubyte[]));
        else if (x.convertsTo!(string))
            setString(parameterIndex, x.get!(string));
        else if (x.convertsTo!(DateTime))
            setDateTime(parameterIndex, x.get!(DateTime));
        else if (x.convertsTo!(Date))
            setDate(parameterIndex, x.get!(Date));
        else if (x.convertsTo!(TimeOfDay))
            setTime(parameterIndex, x.get!(TimeOfDay));
    }
    override void setNull(int parameterIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        setNull(parameterIndex, SqlType.VARCHAR);
    }
    override void setNull(int parameterIndex, int sqlType) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        assert(0);
    }
}

class OracleResultSet : ResultSetImpl 
{
private:
    enum MAX_DIGIT_COUNT = 64;
    OracleStatement stmt;
    ResultSetMetaData metadata;
    bool closed;
    int currentRowIndex;
    uint rowCount;
    bool nodata;
    int[string] columnMap;
    bool lastIsNull;
    int columnCount;
    short[] indicators;
    void*[] pointers;
    ushort[] lengthes;
    ub2[] dtypes;

	void checkClosed() 
    {
		if (closed)
			throw new SQLException("Result set is already closed");
	}

    Variant getValue(int i) 
    {
		checkClosed();
        enforceEx!SQLException(i >= 1 && i <= columnCount, "Column index out of bounds: " ~ to!string(i));
        enforceEx!SQLException(!nodata, "No current row in result set");
        
        lastIsNull = !!indicators[i - 1];
		Variant res;
		if (!lastIsNull)
        {
		    switch (dtypes[i - 1])
            {
                case SQLT_CHR:
                    res = (cast(immutable(char*))pointers[i - 1])[0 .. lengthes[i - 1]];
                    break;
                case SQLT_INT:
                    res = *cast(long*)pointers[i - 1];
                    break;
                case SQLT_UIN:
                    res = *cast(ulong*)pointers[i - 1];
                    break;
                case SQLT_BDOUBLE:
                    res = *cast(double*)pointers[i - 1];
                    break;
                case SQLT_TIMESTAMP:
                    OCIDateTime* datetime = *cast(OCIDateTime**)pointers[i - 1];
                    sb2 yr;
                    ub1 mnth;
                    ub1 dy;
                    stmt.conn.checkerr(OCIDateTimeGetDate(stmt.conn.ses, stmt.conn.err, datetime, &yr, &mnth, &dy));
                    ub1 hr;
                    ub1 mm;
                    ub1 ss;
                    ub4 fsec;
                    stmt.conn.checkerr(OCIDateTimeGetTime (stmt.conn.ses, stmt.conn.err, datetime, &hr, &mm, &ss, &fsec));
                    res = DateTime(yr, mnth, dy, hr, mm, ss);
                    break;
                default:
                    assert(0);
            }
        }
        return res;
    }
public:

    void lock() 
    {
        stmt.lock();
    }

    void unlock() 
    {
        stmt.unlock();
    }

    this(OracleStatement stmt) 
    {
        this.stmt = stmt;
        
        stmt.conn.checkerr(OCIAttrGet(stmt.stmt, OCI_HTYPE_STMT, &columnCount, null, OCI_ATTR_PARAM_COUNT, stmt.conn.err));
        indicators.length = columnCount;
        pointers.reserve(columnCount);
        lengthes.length = columnCount;
        for (uint i = 1; i <= columnCount; i++)
        {
            OCIParam* param;
            
            stmt.conn.checkerr(OCIParamGet(stmt.stmt, OCI_HTYPE_STMT, stmt.conn.err, cast(void**)&param, i));
            
            ub2 dtype;
            stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &dtype, null, OCI_ATTR_DATA_TYPE, stmt.conn.err));
            ub2 def_type = oracleTypeToSupported(dtype);
            dtypes ~= def_type;

            char* name;
            ub4 name_sz;
            stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &name, &name_sz, OCI_ATTR_NAME, stmt.conn.err));
            string field_name = name[0 .. name_sz].idup;
            columnMap[field_name] = i;
            OCIDefine *defn;
            switch (def_type)
            {
                case SQLT_CHR:
                    uint field_size;
                    if (dtype == SQLT_NUM || dtype == SQLT_FLT || dtype == SQLT_VNU)
                    {
                        field_size = MAX_DIGIT_COUNT;
                    }
                    else
                    {
                        ushort size;
                        stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &size, null, OCI_ATTR_DATA_SIZE, stmt.conn.err));
                        field_size = size;
                    }
                    char[] buff = new char[field_size];
                    
                    stmt.conn.checkerr(OCIDefineByPos(stmt.stmt, &defn, stmt.conn.err, i,
												  buff.ptr, cast(ushort)buff.length, SQLT_STR,
												   &indicators[i - 1], &lengthes[i - 1],
                                                   null, OCI_DEFAULT));
                    pointers ~= buff.ptr;
                    break;
                case SQLT_INT:
                    long* intp = new long;
                    stmt.conn.checkerr(OCIDefineByPos(stmt.stmt, &defn, stmt.conn.err, i,
												  intp, cast(ushort)long.sizeof, SQLT_INT,
												   &indicators[i - 1], null,
                                                   null, OCI_DEFAULT));
                    pointers ~= intp;
                    break;
                case SQLT_UIN:
                    ulong* intp = new ulong;
                    stmt.conn.checkerr(OCIDefineByPos(stmt.stmt, &defn, stmt.conn.err, i,
												  intp, cast(ushort)ulong.sizeof, SQLT_UIN,
												   &indicators[i - 1], null,
                                                   null, OCI_DEFAULT));
                    pointers ~= intp;
                    break;
                case SQLT_BDOUBLE:
                    double* floatp = new double;
                    stmt.conn.checkerr(OCIDefineByPos(stmt.stmt, &defn, stmt.conn.err, i,
												  floatp, cast(ushort)double.sizeof, SQLT_BDOUBLE,
												   &indicators[i - 1], null,
                                                   null, OCI_DEFAULT));
                    pointers ~= floatp;
                    break;
                case SQLT_TIMESTAMP:
                    OCIDateTime** ptstmpltz = new OCIDateTime*;
                    stmt.conn.checkerr(OCIDescriptorAlloc(stmt.conn.env, cast(void**)ptstmpltz, OCI_DTYPE_TIMESTAMP, 0, null));
                    stmt.conn.checkerr(OCIDefineByPos(stmt.stmt, &defn, stmt.conn.err, i,
												  ptstmpltz, (OCIDateTime*).sizeof, SQLT_TIMESTAMP,
												   &indicators[i - 1], null,
                                                   null, OCI_DEFAULT));
                    pointers ~= ptstmpltz;
                    break;
                default:
                    //char* type_name;
                    //ub4 type_name_sz;
                    //stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &type_name, &type_name_sz, OCI_ATTR_TYPE_NAME, stmt.conn.err));
                    //string type_name_s = type_name[0 .. type_name_sz].idup;
                    throw new SQLException("Unable to fetch "~dtype.to!string()~" type");
            }
        }
        stmt.conn.checkerr(OCIStmtExecute(stmt.conn.svc, stmt.stmt, stmt.conn.err, 0, 0, null, null, OCI_STMT_SCROLLABLE_READONLY));
        //hack for the determining the total row count
        stmt.conn.checkerr(OCIStmtFetch(stmt.stmt, stmt.conn.err, 1, OCI_FETCH_LAST, OCI_DEFAULT));
        auto status = OCIStmtFetch(stmt.stmt, stmt.conn.err, 1, OCI_FETCH_FIRST, OCI_DEFAULT);
        stmt.conn.checkerr(status);
        if (status == OCI_NO_DATA)
            nodata = true;
        stmt.conn.checkerr(OCIAttrGet(stmt.stmt, OCI_HTYPE_STMT, &rowCount, null, OCI_ATTR_ROW_COUNT, stmt.conn.err));
    }

    // ResultSet interface implementation

    //Retrieves the number, types and properties of this ResultSet object's columns
    override ResultSetMetaData getMetaData() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        if (!metadata)
        {
            ColumnMetadataItem[] cols;
            for (uint i = 1; i <= columnCount; i++)
            {
                auto col_data = new ColumnMetadataItem();
                cols ~= col_data;
                OCIParam* param;
                
                stmt.conn.checkerr(OCIParamGet(stmt.stmt, OCI_HTYPE_STMT, stmt.conn.err, cast(void**)&param, i));
                
                ub2 dtype;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &dtype, null, OCI_ATTR_DATA_TYPE, stmt.conn.err));
                col_data.type = fromOracleType(dtype);
                
                char* name;
                ub4 name_sz;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &name, &name_sz, OCI_ATTR_NAME, stmt.conn.err));
                col_data.name = name[0 .. name_sz].idup;
                columnMap[col_data.name] = i;
                
                ushort size;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &size, null, OCI_ATTR_DATA_SIZE, stmt.conn.err));
                col_data.displaySize = size;
                
                byte precision;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &precision, null, OCI_ATTR_PRECISION, stmt.conn.err));
                col_data.precision = precision;

                byte scale;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &scale, null, OCI_ATTR_SCALE, stmt.conn.err));
                col_data.scale = scale;
                
                char* type_name;
                ub4 type_name_sz;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &type_name, &type_name_sz, OCI_ATTR_TYPE_NAME, stmt.conn.err));
                col_data.typeName = type_name[0 .. type_name_sz].idup;

                char* schema_name;
                ub4 schema_name_sz;
                stmt.conn.checkerr(OCIAttrGet(param, OCI_DTYPE_PARAM, &schema_name, &schema_name_sz, OCI_ATTR_SCHEMA_NAME, stmt.conn.err));
                col_data.schemaName = schema_name[0 .. schema_name_sz].idup;
            }
            metadata = new ResultSetMetaDataImpl(cols);
        }
        return metadata;
    }

    override void close() 
    {
        lock();
        scope(exit) unlock();
        if (closed)
            return;

        foreach(key, cur; dtypes)
        {
            if (cur == SQLT_TIMESTAMP)
            {
                stmt.conn.checkerr(OCIDescriptorFree(*cast(void**)pointers[key], OCI_DTYPE_TIMESTAMP));
            }
        }
       	closed = true;
    }
    override bool first() 
    {
		checkClosed();
        lock();
        scope(exit) unlock();
        currentRowIndex = 0;
        auto status = OCIStmtFetch(stmt.stmt, stmt.conn.err, 1, OCI_FETCH_FIRST, OCI_DEFAULT);
        if (status == OCI_NO_DATA)
            nodata = true;
        else
            nodata = false;
        stmt.conn.checkerr(status);
        return !nodata;
    }

    override bool isFirst() 
    {
		checkClosed();
        lock();
        scope(exit) unlock();
        return !nodata && currentRowIndex == 0;
    }
    override bool isLast() 
    {
		checkClosed();
        lock();
        scope(exit) unlock();
        return !nodata && rowCount == currentRowIndex - 1;
    }
    override bool next() 
    {
		checkClosed();
        lock();
        scope(exit) unlock();
        auto status = OCIStmtFetch(stmt.stmt, stmt.conn.err, 1, OCI_FETCH_NEXT, OCI_DEFAULT);
        if (status == OCI_NO_DATA)
            nodata = true;
        else
            nodata = false;
        stmt.conn.checkerr(status);
        if (nodata || currentRowIndex + 1 >= rowCount)
            return false;
        currentRowIndex++;
        return true;
    }
    
    override int findColumn(string columnName) 
    {
		checkClosed();
        lock();
        scope(exit) unlock();
        int * p = (columnName in columnMap);
        if (!p)
            throw new SQLException("Column " ~ columnName ~ " not found");
        return *p + 1;
    }

    override bool getBoolean(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return false;
        if (v.convertsTo!(bool))
            return v.get!(bool);
        if (v.convertsTo!(int))
            return v.get!(int) != 0;
        if (v.convertsTo!(long))
            return v.get!(long) != 0;
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to boolean");
    }
    override ubyte getUbyte(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(ubyte))
            return v.get!(ubyte);
        if (v.convertsTo!(long))
            return to!ubyte(v.get!(long));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to ubyte");
    }
    override byte getByte(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(byte))
            return v.get!(byte);
        if (v.convertsTo!(long))
            return to!byte(v.get!(long));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to byte");
    }
    override short getShort(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(short))
            return v.get!(short);
        if (v.convertsTo!(long))
            return to!short(v.get!(long));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to short");
    }
    override ushort getUshort(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(ushort))
            return v.get!(ushort);
        if (v.convertsTo!(long))
            return to!ushort(v.get!(long));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to ushort");
    }
    override int getInt(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(int))
            return v.get!(int);
        if (v.convertsTo!(long))
            return to!int(v.get!(long));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to int");
    }
    override uint getUint(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(uint))
            return v.get!(uint);
        if (v.convertsTo!(ulong))
            return to!int(v.get!(ulong));
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to uint");
    }
    override long getLong(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(long))
            return v.get!(long);
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to long");
    }
    override ulong getUlong(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(ulong))
            return v.get!(ulong);
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to ulong");
    }
    override double getDouble(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(double))
            return v.get!(double);
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to double");
    }
    override float getFloat(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return 0;
        if (v.convertsTo!(float))
            return v.get!(float);
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to float");
    }
    override byte[] getBytes(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return null;
        if (v.convertsTo!(string)) 
        {
            return cast(byte[])v.get!(string).dup;
        }
        throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to byte[]");
    }
	override ubyte[] getUbytes(int columnIndex) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		Variant v = getValue(columnIndex);
		if (lastIsNull)
			return null;
		if (v.convertsTo!(string)) {
			return cast(ubyte[])v.get!(string).dup;
		}
		throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to ubyte[]");
	}
	override string getString(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull)
            return null;
		if (v.convertsTo!(string)) 
        {
            return v.get!(string);
		}
        return v.toString();
    }
	override std.datetime.DateTime getDateTime(int columnIndex) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		Variant v = getValue(columnIndex);
		if (lastIsNull)
			return DateTime();
		if (v.convertsTo!(DateTime)) 
        {
			return v.get!DateTime();
		}
		throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to DateTime");
	}
	override std.datetime.Date getDate(int columnIndex) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		Variant v = getValue(columnIndex);
		if (lastIsNull)
			return Date();
		if (v.convertsTo!(DateTime)) 
        {
			return v.get!DateTime().date;
		}
		throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to Date");
	}
	override std.datetime.TimeOfDay getTime(int columnIndex) 
    {
		checkClosed();
		lock();
		scope(exit) unlock();
		Variant v = getValue(columnIndex);
		if (lastIsNull)
			return TimeOfDay();
		if (v.convertsTo!(DateTime)) 
        {
			return v.get!DateTime().timeOfDay;
		}
		throw new SQLException("Cannot convert field " ~ to!string(columnIndex) ~ " to TimeOfDay");
	}

    override Variant getVariant(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        Variant v = getValue(columnIndex);
        if (lastIsNull) 
        {
            Variant vnull = null;
            return vnull;
        }
        return v;
    }
    override bool wasNull() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        return lastIsNull;
    }
    override bool isNull(int columnIndex) 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        enforceEx!SQLException(columnIndex >= 1 && columnIndex <= columnCount, "Column index out of bounds: " ~ to!string(columnIndex));
        enforceEx!SQLException(!nodata, "No current row in result set");
        return !!indicators[columnIndex - 1];
    }

    //Retrieves the Statement object that produced this ResultSet object.
    override Statement getStatement() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        return stmt;
    }

    //Retrieves the current row number
    override int getRow() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        if (currentRowIndex < 0 || nodata)
            return 0;
        return currentRowIndex + 1;
    }

    //Retrieves the fetch size for this ResultSet object.
    override int getFetchSize() 
    {
        checkClosed();
        lock();
        scope(exit) unlock();
        return rowCount;
    }
}





}
