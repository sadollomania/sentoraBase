import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sentora_base/remotedb/DBColTypes.dart';
import 'package:tuple/tuple.dart';

class DBPool {
  HashMap<String, String> sessionIds = HashMap<String, String>();
  HashMap<String, String> connectionIds = HashMap<String, String>();

  late String _host;
  late String _port;
  late String _activeDatabase;
  late String _activeUserName;
  late String _activePassword;

  void setActiveConnectionConfiguration(String host, String port, String database, String userName, String password) {
    _host = host;
    _port = port;
    _activeDatabase = database;
    _activeUserName = userName;
    _activePassword = password;
  }

  String getActiveConnectionStr() {
    return _activeDatabase + "@@@" + _activeUserName + "@@@" + _activePassword;
  }

  Future<bool> connect() async {
    final uri = Uri.http(_host + ":" + _port, "/aceql/database/" + _activeDatabase + "/username/" + _activeUserName + "/connect", {
      'password' : _activePassword
    });
    final http.Response resp = await http.get(uri);
    if(resp.statusCode == 200) {
      String responseBody = resp.body;
      final responseJson = json.decode(responseBody);
      if(responseJson['status'] == 'OK') {
        String activeConnectionStr = getActiveConnectionStr();
        sessionIds[activeConnectionStr] = responseJson['session_id'];
        connectionIds[activeConnectionStr] = responseJson['connection_id'];
        return true;
      }
    }
    return false;
  }

  /*void setAppUser(String appUser) {
	}

  ResultSet executeQuery(String sql) {
		prepareStatement(sql);
		rs = executeQuery();
		return rs;
	}

  PreparedStatement prepareStatement(String sql,bool returnValues) {
		if (returnValues){
			prepareReturningStatement(sql);
		}else{
			prepareStatement(sql);
		}
		return getPStmt();
	}

	PreparedStatement prepareStatement(String sql) {
		closePstmt();
		this.pStmt = conn.prepareStatement(sql);
		return getPStmt();
	}
  
  PreparedStatement prepareReturningStatement(String sql) {
		closePstmt();
		switch(dbType) {
        case ORACLE:
            this.pStmt = conn.prepareStatement(sql, new int[] { 1 });
            break;
        case MSSQL:
        	/*this.pStmt = conn.prepareStatement(sql, new String[] { "ID" });
          break;*/
        case POSTGRESQL:
        default:
          this.pStmt = conn.prepareStatement(sql,PreparedStatement.RETURN_GENERATED_KEYS);
          break;
		}
		return getPStmt();
	}

  void setAutoCommit(bool bln) {
		this.conn.setAutoCommit(bln);
	}

	void commit() {
		if(null!= conn) {
			try {
				this.conn.commit();
			} catch (SQLException e) {
				Log.warn("DBPool commit : ",e);
			}
		}
	}

	void rollBack() {
		if(null != conn) {
			try {
				conn.rollback();
			} catch (SQLException sqle1){
				Log.warn("DBPool rollBack : ",sqle1);
			};
		}
	}
  */

  Map<String, dynamic> constructExecuteUpdateParams(String sql, List<Tuple2<dynamic, DBColTypes>> params) {
    Map<String, dynamic> retMap = {};
    retMap["prepared_statement"] = "true";
    retMap["sql"] = sql;
    int i = 1;
    params.forEach((val) {
      switch(val.item2) {
        case DBColTypes.BIGINT:
        case DBColTypes.INTEGER:
        case DBColTypes.SMALLINT:
        case DBColTypes.TINYINT:
          retMap["param_type_" + i.toString()] = "INTEGER";
          retMap["param_value_" + i.toString()] = val.item1.toString();
          break;
        case DBColTypes.BINARY:
          break;
        case DBColTypes.BLOB:
          break;
        case DBColTypes.CHAR:
        case DBColTypes.CHARACTER:
        case DBColTypes.LONGVARCHAR:
        case DBColTypes.CLOB:
        case DBColTypes.VARCHAR:
          retMap["param_type_" + i.toString()] = "VARCHAR";
          retMap["param_value_" + i.toString()] = val.item1 as String;
          break;
        case DBColTypes.DATE:
        case DBColTypes.TIME:
        case DBColTypes.TIMESTAMP:
          retMap["param_type_" + i.toString()] = "DATE";
          retMap["param_value_" + i.toString()] = (val.item1 as DateTime).millisecondsSinceEpoch;
          break;
        case DBColTypes.DECIMAL:
        case DBColTypes.DOUBLE_PRECISION:
        case DBColTypes.FLOAT:
        case DBColTypes.NUMERIC:
        case DBColTypes.REAL:
          retMap["param_type_" + i.toString()] = "DOUBLE_PRECISION";
          retMap["param_value_" + i.toString()] = (val.item1 as double).toStringAsFixed(6);
          break;
        case DBColTypes.LONGVARBINARY:
          break;
        case DBColTypes.URL:
          break;
        case DBColTypes.VARBINARY:
          break;
      }
      ++i;
    });
    return retMap;
  }

  Future<dynamic> executeUpdate(String sql, List<Tuple2<dynamic, DBColTypes>> params) async {
    String activeConnectionStr = getActiveConnectionStr();
    String sessionId = sessionIds[activeConnectionStr]!;
    Map<String, dynamic> retMap = constructExecuteUpdateParams(sql, params);
    final uri = Uri.http(_host + ":" + _port, "/aceql/session/" + sessionId + "/execute_update", retMap);
    final http.Response resp = await http.get(uri);
    if(resp.statusCode == 200) {
      String responseBody = resp.body;
      final responseJson = json.decode(responseBody);
      if(responseJson['status'] == 'OK') {
        return responseJson;
      }
    }
    return null;
  }

  Future<dynamic> executeQuery(String sql) async {
    String activeConnectionStr = getActiveConnectionStr();
    String sessionId = sessionIds[activeConnectionStr]!;
    final uri = Uri.http(_host + ":" + _port, "/aceql/session/" + sessionId + "/execute_query", {
      'sql' : sql,
      "column_types" : "true"
    });
    final http.Response resp = await http.get(uri);
    if(resp.statusCode == 200) {
      String responseBody = resp.body;
      final responseJson = json.decode(responseBody);
      if(responseJson['status'] == 'OK') {
        return responseJson;
      }
    }
    return null;
  }

  Future<bool> close() async {
    String activeConnectionStr = getActiveConnectionStr();
    String sessionId = sessionIds[activeConnectionStr]!;
    String connectionId = sessionIds[activeConnectionStr]!;
    final uri = Uri.http(_host + ":" + _port, "/aceql/session/" + sessionId + "/connection/" + connectionId + "/close");
    final http.Response resp = await http.get(uri);
    if(resp.statusCode == 200) {
      String responseBody = resp.body;
      final responseJson = json.decode(responseBody);
      if(responseJson['status'] == 'OK') {
        sessionIds.remove(activeConnectionStr);
        connectionIds.remove(activeConnectionStr);
        return true;
      }
    }
    return false;
  }

  Future<bool> logout() async {
    String activeConnectionStr = getActiveConnectionStr();
    String sessionId = sessionIds[activeConnectionStr]!;
    final uri = Uri.http(_host + ":" + _port, "/aceql/session/" + sessionId + "/logout");
    final http.Response resp = await http.get(uri);
    if(resp.statusCode == 200) {
      String responseBody = resp.body;
      final responseJson = json.decode(responseBody);
      if(responseJson['status'] == 'OK') {
        sessionIds.remove(activeConnectionStr);
        connectionIds.remove(activeConnectionStr);
        return true;
      }
    }
    return false;
  }
}