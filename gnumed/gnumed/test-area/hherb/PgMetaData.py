#############################################################################
#
# gmPgMetaData - PostgreSQL metadata analysis functions
# ---------------------------------------------------------------------------
#
# @license: GPL v2 or later (details at http://www.gnu.org)
# @dependencies: DB-API 2.0 compliant PostgreSQL adapter
#
# @TODO: quick hack only, needs a lot of work
############################################################################
# $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/test-area/hherb/PgMetaData.py,v $      
__version__ = "$Revision: 1.2 $"                                               
__author__ = "Horst Herb <hherb@gnumed.net>"
import sys, string

#==============================================================

QDescribe = """
SELECT DISTINCT tt.nspname AS "Schema", tt.name AS "Name", tt.object AS "Object", d.description AS "Description"
FROM (
  SELECT p.oid as oid, p.tableoid as tableoid,
  n.nspname as nspname,
  CAST(p.proname AS pg_catalog.text) as name,  CAST('aggregate' AS pg_catalog.text) as object
  FROM pg_catalog.pg_proc p
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
  WHERE p.proisagg
      AND pg_catalog.pg_function_is_visible(p.oid)
      AND p.proname ~ '^%(object)s$'
UNION ALL
  SELECT p.oid as oid, p.tableoid as tableoid,
  n.nspname as nspname,
  CAST(p.proname AS pg_catalog.text) as name,  CAST('function' AS pg_catalog.text) as object
  FROM pg_catalog.pg_proc p
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
  WHERE p.prorettype <> 'pg_catalog.cstring'::pg_catalog.regtype
      AND p.proargtypes[0] <> 'pg_catalog.cstring'::pg_catalog.regtype
      AND NOT p.proisagg
      AND pg_catalog.pg_function_is_visible(p.oid)
      AND p.proname ~ '^%(object)s$'
UNION ALL
  SELECT o.oid as oid, o.tableoid as tableoid,
  n.nspname as nspname,
  CAST(o.oprname AS pg_catalog.text) as name,  CAST('operator' AS pg_catalog.text) as object
  FROM pg_catalog.pg_operator o
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = o.oprnamespace
WHERE pg_catalog.pg_operator_is_visible(o.oid)
      AND o.oprname ~ '^%(object)s$'
UNION ALL
  SELECT t.oid as oid, t.tableoid as tableoid,
  n.nspname as nspname,
  pg_catalog.format_type(t.oid, NULL) as name,  CAST('data type' AS pg_catalog.text) as object
  FROM pg_catalog.pg_type t
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE pg_catalog.pg_type_is_visible(t.oid)
      AND pg_catalog.format_type(t.oid, NULL) ~ '^%(object)s$'
UNION ALL
  SELECT c.oid as oid, c.tableoid as tableoid,
  n.nspname as nspname,
  CAST(c.relname AS pg_catalog.text) as name,
  CAST(
    CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' END  AS pg_catalog.text) as object
  FROM pg_catalog.pg_class c
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind IN ('r', 'v', 'i', 'S')
      AND pg_catalog.pg_table_is_visible(c.oid)
      AND c.relname ~ '^%(object)s$'
UNION ALL
  SELECT r.oid as oid, r.tableoid as tableoid,
  n.nspname as nspname,
  CAST(r.rulename AS pg_catalog.text) as name,  CAST('rule' AS pg_catalog.text) as object
  FROM pg_catalog.pg_rewrite r
       JOIN pg_catalog.pg_class c ON c.oid = r.ev_class
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE r.rulename != '_RETURN'
      AND pg_catalog.pg_table_is_visible(c.oid)
      AND r.rulename ~ '^%(object)s$'
UNION ALL
  SELECT t.oid as oid, t.tableoid as tableoid,
  n.nspname as nspname,
  CAST(t.tgname AS pg_catalog.text) as name,  CAST('trigger' AS pg_catalog.text) as object
  FROM pg_catalog.pg_trigger t
       JOIN pg_catalog.pg_class c ON c.oid = t.tgrelid
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE pg_catalog.pg_table_is_visible(c.oid)
      AND t.tgname ~ '^%(object)s$'
) AS tt
  JOIN pg_catalog.pg_description d ON (tt.oid = d.objoid and tt.tableoid = d.classoid and d.objsubid = 0)
ORDER BY 1, 2, 3
""" #needs tablename as param 'object'

QForeignKeyDescription = """SELECT conname,
  pg_catalog.pg_get_constraintdef(oid) as condef
FROM pg_catalog.pg_constraint r
WHERE r.conrelid = %s AND r.contype = 'f'""" #needs OID as param

QIndexDefinition="""SELECT c2.relname, i.indisprimary, i.indisunique, pg_catalog.pg_get_indexdef(i.indexrelid)
FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i
WHERE c.oid = '%s' AND c.oid = i.indrelid AND i.indexrelid = c2.oid
ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname""" #needs OID as param

QOidAndNAmespace = """SELECT c.oid,
  n.nspname,
  c.relname
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE pg_catalog.pg_table_is_visible(c.oid)
      AND c.relname ~ '^%s$'
ORDER BY 2, 3;""" #needs table name as param




#this query returns the primary key of a table (only parameter is table name)
QTablePrimaryKey = """ 
SELECT
	indkey
FROM
	pg_index
WHERE
	indrelid =
	(SELECT oid FROM pg_class WHERE relname = '%s')"""


#This query returns all foreign keys of a table (only parameter is table name)
QTableForeignKeys = """
SELECT
	pg_trigger.tgargs
FROM
	pg_proc
		INNER JOIN pg_trigger ON pg_proc.oid = pg_trigger.tgfoid 
		INNER JOIN pg_class ON pg_trigger.tgrelid = pg_class.oid 
		INNER JOIN pg_type ON pg_trigger.tgtype = pg_type.oid 
WHERE
	pg_class.relname = '%s'"""


#This query returns a list of all tables except for the system tables (no parameters)
QTables = """
SELECT tablename FROM pg_tables"""
#SELECT tablename FROM pg_tables WHERE tablename NOT LIKE 'pg_%'"""

#this query returns the comment of a column of a table.
#First argument is the table name, second argument is the numeric
#index of the column starting with 1 for the first column
QColumnComment = """
SELECT description FROM pg_description
WHERE (objoid=(SELECT oid FROM pg_class WHERE relname='%s') 
AND  objsubid=%d)"""
 
#this query returns the comment of a table. Only parameter is the table name
QTableComment = """
SELECT description FROM pg_description 
WHERE objoid=(SELECT oid FROM pg_class WHERE relname='%s')"""


_cached_tables = []		
_table_metadata = {}
_column_indices = {}
_primarykeys = {}
_foreignkeys = {}
_referenced_tables = {}
_referenced_tables_cached = 0
_references = {}
_tables = []
#==============================================================

def list_all_tables(con, refresh=0):
	"""returns a list of all table names except fr system tables.
	If refresh is 0, results are read from cache, else directly from the backend"""
	global QTables, _tables
	if (not refresh) and (len(_tables) > 0):
		return _tables
	cur = con.cursor()
	cur.execute(QTables);
	_tables = []
	tables = cur.fetchall()
	for t in tables:
		_tables.append(t[0])
	return _tables

	
def get_foreign_keys(con, table):
	"""return a dictionary of foreign keys for the 'table':
	dict key is the column, dict value is a tuple of (referenced_table, referenced_column)"""
	cursor = con.cursor()
	query = QTableForeignKeys % (table)
	try:
		cursor.execute(query)
	except ValueError:
		return {}
	references = {}
	fkresult  = cursor.fetchall()
	if len(fkresult) <=0:
		return {}
	for fk in fkresult:
		#ugly hack to cope with the NULL characters in the array
		fkarray = repr(fk[0])
		print repr(fk[0])
		print string.split(fkarray, '\\x00')
		fkname, referencing_table, referenced_table, dummy, referencing_column, referenced_column, dummy2  = string.split(fkarray, '\\x00')
		if referenced_table != table:
			references[referencing_column] = (referenced_table, referenced_column)
	return references
	
	
def get_dependencies(con):
	"""get a dictionary containing all tables that are referenced by foreign keys with the 
	tablename as dict key and the referencing tables as dict values"""
	deps = {}
	for table in list_all_tables(con):	
		refs = get_foreign_keys(con, table)
		for fk in refs.keys():
			reftable = refs[fk][0]
			if reftable in deps.keys():
				deps[reftable].append(table)
			else:
				deps[reftable] = [table]
	return deps
			
	
def list_foreign_keys(con, table, refresh=0):
	"""returns a dictionary of referenced foreign keys:
	key = column name of this table
	value = (referenced table name, referenced column name) tuple
	con = open database connection (DBAPI 2.0)
	if refresh !=0, the cache will be refreshed from the backend"""
	
	#try to return cached values if existing
	global _referenced_tables_cached, _references, _referenced_tables, QTableForeignKeys
	
	if not refresh:
		try:
			return _references[table]
		except KeyError:
			pass
	
	references = get_foreign_keys(con, table)
	_references[table] = references
	return references
	
	
def list_dependencies(con, table, refresh=0):
	"""returns the names of all tables referencing 'table'"""
	global _referenced_tables_cached, _referenced_tables
	
	if (refresh) or (not _referenced_tables_cached):
		_referenced_tables = get_dependencies(con)
		_referenced_tables_cached = 1
	try:
		return _referenced_tables[table]
	except:
		return []
	
		

def list_primary_key(con, table):
	"""return the column index of the primary key of the stated table
	con = open database connection (DBAPI 2.0)"""
	global QTablePrimaryKey
	cursor = con.cursor()
	cursor.execute(QTablePrimaryKey % table)
	pk = cursor.fetchone()
	if pk is not None:
		try:
			primkey=int(pk[0])
		except:
			primkey=tuple(string.split(pk[0], ' '))
		return primkey
	else:
		return None
		
		
def columnlabel_from_index(con, table, idx):
	if idx is None:
		return ''
	cursor = con.cursor()
	cursor.execute("select * from %s limit 1" % table);
	return cursor.description[idx][0]
	
	
def list_table_attributes(con, table):
	cursor = con.cursor()
	cursor.execute("select * from %s limit 1" % table);
	return cursor.description
	
def list_comment(con, table, idx=0):
	"""list comment on table 'table' if idx is zero, else list comment for
	column[idx] (starting with 1 ffor the first column) of that table"""
	global QTableComment, QColumnComment
	if idx==0:
		query = QTableComment % table
	else:
		query = QColumnComment % (table, idx)	
	cur=con.cursor()
	cur.execute(query)
	result = cur.fetchone()
	if result is not None:
		return result[0]
	else:
		return ''
	
	

def cache_table_info(con, table, cursor=None):
	"""cache all relevant metatdata of the stated table
	if cursor is stated, use it otherwise a dummy query is executed
	con = open database connection (DBAPI 2.0)"""
	global _table_metadata
	global _column_indices
	global _primarykey
	global _foreignkeys
	global _cached_tables
	
	if table in _cached_tables:
		return
		
	if cursor is None:
		cursor = con.cursor()
		cursor.execute("select * from %s limit 1" % table)
		
	_table_metadata[table] = cursor.description
	_foreignkeys[table] = listForeignKeys(con, table)
	_primarykeys[table] = listPrimaryKey(con, table)
	index = {}
	for i in range(len (cursor.description)):
		index[cursor.description[i][0]] = i
	_column_indices[table] = index
	_cached_tables.append(table)
	
	

if __name__ == "__main__":

	html_header = """<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN "http://www.w3.org/TR/html4/loose.dtd"">
<html>
<head>
  <title>Database</title>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <meta name="GENERATOR" content="PyPgMetaData">
</head>
<body>"""
	html_footer = """</body></html>"""
	
	html_table_begin = """<table width="100%%" border=1 cellpadding=5> 
<th colspan=5 align="center" bgcolor="#bdd500"><a name="%s"> %s : %s </th>
</tr> """

	import sys
	import pyPgSQL.PgSQL as DB
	
	dbname=sys.argv[1]
	#dsn = "%s:%s:%s:%s:%s" % (host, str(port), dbname, user, pwd)
	con = DB.connect(database=dbname)
	all_tables = list_all_tables(con)
		
	print html_header
	
	print "<h1>Overview of database %s</h1>" % dbname
	print "<h2>Index</h2>"
	print "<ol>"
	for table in all_tables:
		print '<li><a href="#%s">%s</a></li>' % (table, table)
	print "</ol>"
	print "<br><hr><br>"
	
	for table in all_tables:

		print html_table_begin % (table, table, list_comment(con, table))
		pk = list_primary_key(con, table)
		if type(pk) is tuple:
			print '<tr>\n\t<td bgcolor="#bdd5ff">primary key:</td>\n\t<td colspan=4>compound primary key (%s)</td>\n</tr>' % str(pk)
		elif pk is not None:
			print '<tr>\n\t<td bgcolor="#bdd5ff">primary key:</td>\n\t<td colspan=4>%s</td>\n</tr>' % columnlabel_from_index(con, table, int(pk)-1)

		fks =''
		fkdict = list_foreign_keys(con, table)
		nrows = len(fkdict.keys())
		if nrows>0:
			print '<tr><td rowspan=%d bgcolor="#bdd5ff"> foreign keys:</td><td bgcolor="lightGray">column</td><td bgcolor="lightGray"f>ref. table</td><td bgcolor="lightGray">ref. column</td><td bgcolor="lightGray">comment</td></tr>' % (nrows+1)
			for fk in fkdict.keys():
				print "<tr>"
				print "\t<td>%s</td>" % fk
				print '\t<td><a href="#%s">%s</a></td>' % (fkdict[fk][0], fkdict[fk][0])
				print "\t<td>%s</td>" % fkdict[fk][1]
				print "<td></td>"
				print "</tr>"
				
		#show table attributes
		attrs = list_table_attributes(con, table)
		print '<tr><td rowspan=%d bgcolor="#bdd5ff">attributes:</td><td bgcolor="lightGray">name</td><td bgcolor="lightGray">type</td><td bgcolor="lightGray">len</td><td bgcolor="lightGray">comment</td></tr> ' % (len(attrs)+1)
		idx=0
		for attr in attrs:
			idx+=1
			print "<tr>"
			print "\t<td>%s</td>" % attr[0] 
			print "\t<td>%s</td>" % attr[1]
			print "\t<td>%s</td>" % attr[2]
			print "<td>%s</td>" % list_comment(con, table, idx)
			print "</tr>"
			
		#show table dependencies
		dependencies = list_dependencies(con, table)
		#print "deps for %s" % table, dependencies
		#test=raw_input()
		if len(dependencies) > 0:
			print '<tr><td rowspan=%d bgcolor="#bdd5ff">dependencies:</td></tr>' % (len(dependencies)+1)
			for dep in dependencies:
				print '<tr><td colspan=4><a href="#%s">%s</a></d></tr>' % (dep, dep)
					
		print "</table> <br> <hr> <br>"
			
	print html_footer
	
#==============================================================
# $Log: PgMetaData.py,v $
# Revision 1.2  2003-04-02 11:53:47  hherb
# API draft
#
# Revision 1.1  2003/03/04 04:18:27  hherb
# quick hack demonstrating how to make use of Postgres meta data
#
