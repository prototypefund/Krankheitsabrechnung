"""some work for a exporter importer"""


import pyPgSQL.PgSQL as dbapi 
import re
import sys
import traceback as tb
import base64
import binascii

""" uncomment the credentials below for local testing.
"""
#credentials = "hherb.com:gnumed:any-doc:any-doc"
#credentials = "127.0.0.1::gnumedtest:gm-dbo:pass"
#credentials = "publicdb.gnumed.de::gnumed:any-doc:any-doc"
credentials = "127.0.0.1::gnumed:gm-dbo:pass"

class SchemaScan:

	def __init__(self, config = None):
		global credentials
		print "running from credentials = ", credentials
		answ = raw_input("continue (hit enter), or enter new credentials:")
		if answ <> "" and len( answ.split(":")) >= 5:
			credentials = answ

		self.conn = dbapi.connect(credentials)
		print
		print "inherits"
		for x in  self.get_inherits():
			print x
		print
		print "fk list"
		for x in  self.get_fk_list():
			print x
		print
		print "fk details"

		#		map of tablename : primary key
		
		self._pks = dict([ (x[0],x[1]) for x in self.get_pk_attr() ])

		print "pks ", self._pks

		m = {}	
		for child, parent in self.get_inherits() :
			l = m.get(parent, [])
			l.append(child)
			m[parent] = l
		
		#  map of parent: list of children		
		self._inherits = m
		
		# map of child ; list of parents

		m = {}
		for child, parent in self.get_inherits():
			l = m.get(child, [])
			l.append(parent)
			m[child ] = l
		
		self._parents = m


		# map of referring table, referring foreign key field: tuple of (referred table, referred field)
		many_to_one = {}
		
		#map of referred to table : referring table and foreign key as 'table.fk' : and tuple ( of referred to table, foreign key, referred to key)
		
		one_to_many = {}



		for t1, fk, t2, pk in self.get_fk_details():
			print t1,".", fk ,"->" ,t2,".", pk
			#if t1 == 'clin_narrative':
			#	raw_input("continue")

		for t1, fk, t2, pk in self.get_fk_details():
			if not many_to_one.has_key(t1):
				many_to_one[t1] = {}
			
			many_to_one[t1][fk]= (t2, pk)
	

			if not one_to_many.has_key(t2):
				one_to_many[t2] =  {}

			one_to_many[t2][t1+"."+fk] = ( t1, fk, pk)

		self._many_to_one = many_to_one

		self._one_to_many = one_to_many
		
		id = int(raw_input("id of identity:"))
		pat_id = id

		q = [("identity", self._pks['identity'], id), ("xlnk_identity", "xfk_identity", id) ]

		# must account for xfk_identity as well


		# the map to store the instance data: map is of form map  key=tablename: value = map of id: data
		# e.g     table1
		#            id1      
		#                   field1:data1 , field2:data2
		#	     id2
		#                   ....
		#        table2
		#	     id4   
		#                  .....
		vals = {}	
		
		# not used, for debugging
		step_through = 0

		# skip all tables appearing in constants, as they should already be loaded in the target database
		constants = ['test_type_unified', 'encounter_type', 'vacc_indication', 'lnk_vacc_ind2code', 
				'_enum_allergy_type',
				'vacc_regime', 'vacc_def',
				'vacc_route', 'vaccine', 'lnk_vaccine2inds',
				'doc_type'
				
				]

		# q = a queue, initially loaded with the instance of identity and instance of xlnk_identity
		# each item in q is   
		#  (tablename, keyfield, keyvalue) passed to select * from tablename where keyfield=keyvalue
		#  to select the rows and description that match. More than one row may be returned,
		# if the table is the many end of a one_to_many link.

		# each pass in q, searches the current tablename in the many_to_one and one_to_many 
		# table, and gets any tables associated and puts the a set of tablename, keyfield,keyvalue
		# into the queue, for each association

		# when the q is empty, the search is exhausted, and vals should contain a mapping
		# of tablename :  map of rows by id to row contents.  
		# the key values in id and key fields are the original id values of the original schema instance,
		# and will be remapped later by selecting from an id_remap table.
		
		while q <> []:
			t, key , kval  = q.pop(0)
			if t in constants:
				continue
			stmt = "select * from %s where %s = %d" % (t, key, kval )
			print "trying to execute", stmt
			try:
				r, desc = self.execute(stmt)
			except:
				tb.print_tb(sys.exc_info()[2])
				continue
			#print r
			#print desc
			if r == []:
				continue
			if not vals.has_key(t) :
				vals[t]  = {}
			for row in r:
			# v[id] is a map =  { field0 : val, type  , field1: val1, type1 ....  }
				#print "row is ", row

				# entry is a map of field: value, type

				entry  = dict( [ (x,y) for x,y in zip( [d[0] for  d in desc] , [ (a,b) for a,b in zip( row, [d2[1] for d2 in desc] )] ) ] )
				#print "entry", entry

				#print "self._pks[t]", self._pks[t]
				try :
					id = int(entry[self._pks[t]][0])
				except:
					print "Error find self._pks[t][0]"
					print "t = ", t
					print "pk = ", pk
					print "self._pks"  , self._pks
					continue
				

				if vals[t].has_key(id):
					continue

				vals[t][id] = entry # key according to primary key

				
				#print "v of id=", id , " is ", vals[t][id]

				

				m = many_to_one.get(t, {})
				for fk in m.keys():
					try:
						attr_val = entry[fk][0]
						q.append( ( m[fk][0], m[fk][1], int(attr_val)  ) )
					except:
						print "t=", t, " many to one for t is ", m
						print "fk=", fk
						print "error", "m[fk][0]",m[fk][0]
						print "m[fk][1]", m[fk][1]
						print " entry[fk]", entry.get(fk, None)
						#raw_input("continue ?")

				
				# one to many tables use the current entry's pk as the foreign key val
				# for the child table's foreign key field
				
				m = one_to_many.get(t, {})
				#print "one_to_many for t is ", m
				for t_fk in m.keys():
					try:
						fkval =  int(entry[m[t_fk][2]][0])
						table= m[t_fk][0]
						fk = m[t_fk][1]
						if table == 'xlnk_identity':
							print "appending ", table, fk, fkval
							raw_input("Continue?")
						q.append( (table, fk, fkval) )
						for t in self._inherits.get(table, []):
							q.append( (t, fk, fkval) )
					except:
						print "error for ", t_fk , " of ", m
						#raw_input("continue ?")

					
			
				print

		a = raw_input("export to file?")

		if a <> "" and a[0] == 'y':
			f = raw_input("file_name to export to:")
			o = file(f, "w")
			sys.stdout = o
		
		# "abstract" tables such as clin_root_item, which should not have any rows not inherited
		# in a child table, need to be excluded.
		
		abstract = ['clin_root_item']
		for t in abstract:
			if vals.has_key(t):
				del vals[t]

		# prints out the vals table: id : row  map , possibly as a file for transfer.
		# file import not implemented yet though. sql export is the default. (next section)
		print
		for k,v in vals.items():
			print k
			for id,v2 in v.items():
				print "\t",id
				for field, v2 in v2.items():
					if str(v2[1]) == 'bytea':
						val = base64.encodestring(str(v2[0]))
					else:
						val = v2[0]
					print "\t\t", field, ": ",val ,"," , v2[1]


					
			print

		skip_fields= ["pk_audit"]
		sys.stdout = sys.__stdout__

		f = raw_input("sql file to export (default emr-dump-#%s.sql):" % pat_id)
		if f == "":
			f = "emr-dump-#%s.sql" % pat_id

		output = file(f, "w")
		sys.stdout = output

		print "\unset ON_ERROR_STOP"

		#this section creates static types that should exist in target schema, but are inserted
		# outside of the main transaction to ensure they are there.
		
		types = ['test_type_unified', 'vacc_route', 'vaccine', 'vacc_regime' ]
		for table in types:
			try:
				r,desc = self.execute("select * from %s" % table)
			except: # ? permission denied
				continue
			for row in r:
				id = row[[x[0] for x in desc].index(self._pks[table])]
				fields, values = [], []
				for (f,type ), v in zip ( [ (d[0],d[1]) for d in desc], row):
					if f in skip_fields:
						continue
					nv = self.convert_to_pg_val( table, f, v, type)
					if nv == None:
						continue
					fields.append(f)
					values.append(nv)
				print "insert into %s ( %s) values ( %s);" % ( table, ", ".join(fields), ", ".join(values))
				
			
			
		print "drop table id_remap;"
		print "create temp table id_remap ( relname text, old_id integer, new_id integer);"
	
		sys.stdout = sys.__stdout__

		# generate a remap id temporary table on the target schema, using update and nextval and block update
		# by selecting by tablename ( multiple rows updated with sequential calls on nextval).
		
		sql = {}
		for t, v in vals.items():
			sql[t] = []
			for id, v2 in v.items():
				sql[t].append( "insert into id_remap values ('%s', %d, %d);" % ( t, id, id) )
			
			sql[t].append( "update id_remap set new_id = nextval('%s_%s_seq') where relname='%s';" % ( t, self._pks[t], t))

	
		# remove static application inserts
		for x in constants:
			if vals.has_key(x):
				del vals[x]

		# create the insert statements, and select from id_remap temp table ( tablename, old_id, new_id)
		#   which has new_id= nextval( 'table_id_seq') filled in by the first part of the script 
		#   run on the target database.
		#comments:
		# stmts is a map of "tablename" : list of insert statements for the table
		# find_id ,  is the id_remap select which remaps and ok pk value to a new pk value
		# coalesce used in case of null select
		# skip_fields, let pk_audit be autogenerated on insert
		# integer fields, if a none value stored in val of vals[table][id]= (val,type) , then skip as well
		# if a field is xfk_identity, then instead of mapping to xlnk_identity.pk , map to xlnk_identity.xfk_identity ( which is same as identity.pk) 
		# a bytea type field is encoded by python base64.encodestring , and is transferred by postgres decode(x, 'base64') function
		# the str result of interval values returned by pyPgSQL.PgSQL cursor has the form "xx:xx:xx:xx.xx" 
		#    change this to "xx xx:xx:xx" by inserting a space between the 1st and second xx, and deleting the .xx part
		#    this form is parseable by postgres sql lexer.

		# escape for ' is done for 'text' type fields. 
		
		stmts = {}
		for t, v in vals.items():
			stmts[t]= []
			for id , v2 in v.items():

				m = {}

				fields = []
				values = []

				for field, (val, type) in v2.items():
					if field in skip_fields:
						continue

					new_val = self.convert_to_pg_val( t, field, val, type)
					if new_val is None:
						continue
					if str(type) == 'integer':
						new_val = self.remap_integer_val( t, field, val, type, id, constants)

					
					
					fields.append(field)
					values.append(str(new_val))

				stmt = "insert into "+t+"  ("+ ', '.join(fields)+ ") values("+', '.join(values)+")" + ";" 
				stmts[t].append(stmt)		


		# reorder the statements for dependencies
		depends = {}
		for t1, fk, t2, pk in self.get_fk_details():
			if not depends.has_key(t1):
				depends[t1] = {} 
			depends[t1][t2] = 1
		
		separate_transactions = {'org':[],'test_org':[] }
		
		ordered = []

		while len(stmts) > 0:
			for t, statements in stmts.items():
				found_dependency = 0
				for t2 in stmts.keys():
					# also need to check parent dependencies
					for tt in [t] + self._parents.get(t,[]):
						if tt <> t2 and depends.get(tt,{}).has_key(t2):
							found_dependency = 1
							break	
				if not found_dependency:
					if t in separate_transactions.keys():
						separate_transactions[t].extend(statements)
					else:	
						ordered.extend(statements)
					del stmts[t]

		sys.stdout = output

		# this is to cater for "test_org" where some default orgs exist, but some new ones might be
		# added for an import
		print
		print
		for t in separate_transactions.keys():
			if not sql.has_key(t):
				continue
			for x in sql[t][:-1]:
				print x
			
			print "begin;"
			print  sql[t][-1]
			del sql[t]
			for x in separate_transactions[t]:
				print x
			print "commit;"

		print 
		print
		print "\set ON_ERROR_STOP 1"
		print "begin;"
		print "set constraints all deferred;"
		for t,l in sql.items():
			print
			for x in l:
				print x

		for x in ordered:
			print x

		
		print "now_fails; -- REMOVE ME"
		print "commit;"

		print "drop table id_remap;"

	def _convert_interval_str(self, val):
		s = str(val).split(':')

		if s[-1].find('.') >= 0:
			s[-1] = s[-1].split('.')[0]
		return s[0] + " " + ":".join(s[1:])


	def convert_to_pg_val(self, t, field,  val, type ): 
		if str(type) == 'integer' :
			new_val = str(val)
			if str(val) in ["", "None"]:
				return None

		elif str(type) == 'bytea':
			new_val = "decode('" + base64.encodestring(str(val)) +"','base64')"
		else:
			if str(val) == 'None':
				new_val = 'null'
			elif str(type) == 'interval':
				new_val = "'" + self._convert_interval_str(val) + "'"
			elif str(type) == 'text':
				new_val ="'"+ str(val).replace("'","\\\'")+"'" 
			else:
				new_val = "'" + str(val) + "'"
		return new_val

	def remap_integer_val( self, t, field, val ,type,  id, excludetables = [] ):
			new_val = val
			if self._pks[t] == field:
				new_val = "(select new_id from id_remap where relname='%s' and old_id = %s)" % (t, str(id))
			elif field == "xfk_identity":
				new_val = "( select new_id from id_remap where relname='identity' and old_id = %d)" % int(val) 	
			
			# cope with inherited foreign keys
			else: 
				for tt in self._parents.get(t,[]) + [t]:
					#if t == 'clin_narrative':
					#	print "t", tt, "field", field
					#	print "Is a many to one ", self._many_to_one.get(tt, {}).has_key(field)
					#	raw_input("continue?")

					if self._many_to_one.get(tt,{}).has_key(field):
						t2,pk = self._many_to_one[tt][field]
						if not t2 in excludetables:
							t3 = t2
							if t2 == 'xlnk_identity':
								t3 = 'identity'
								pk = 'pk'
							new_val = "coalesce((select %s from %s where %s = ( select new_id from id_remap where relname='%s' and old_id = %d)))" % ( pk, t3, pk ,t3, int(val))
						break
			return new_val
			

	def get_inherits(self):

		cu = self.conn.cursor()
		cu.execute("""
		select c1.relname, c2.relname from pg_class c1, pg_class c2, pg_inherits c3
		where c3.inhrelid = c1.relfilenode and c3.inhparent = c2.relfilenode""")
		return cu.fetchall()

	def get_fk_list(self):
		"""get a foreign key list from pg_constraint"""
		cu = self.conn.cursor()
		cu.execute("""
		select c1.relname, c2.relname from pg_class c1, pg_class c2, pg_constraint c3 where c1.relfilenode = c3.conrelid and c2.relfilenode = c3.confrelid and c3.contype='f'""")
		r = cu.fetchall()
		return r


	def get_fk_details(self):
		"""gets table, keying attribute, foreign table, foreign key attr"""

		cu = self.conn.cursor()
		cu.execute( """
		select c1.relname,a1.attname, c2.relname, a2.attname from pg_class c1, pg_class c2, pg_constraint c3 , pg_attribute a1, pg_attribute a2 where c1.relfilenode = c3.conrelid and c2.relfilenode = c3.confrelid and c3.contype='f' and c3.conrelid = a1.attrelid and c3.conkey[1] = a1.attnum and c3.confkey[1] = a2.attnum and c3.confrelid = a2.attrelid
			""")
		r = cu.fetchall()
		return r
		

	def get_attributes(self, table, foreign_keys = 0):
		if foreign_keys:
			fk_cmp = ''
		else:
			fk_cmp = 'not'

		cu = self.conn.cursor()
		tables_checked_for_fk = [table] + self.get_ancestors(table)
		clause = """select attname from pg_attribute , pg_class, pg_constraint   where relfilenode = attrelid and relname = '%s' and pg_constraint.conrelid = relfilenode and pg_constraint.contype ='f' and conkey[1] = attnum"""
		l_fk = []
		for x in tables_checked_for_fk:
			l_fk.extend([ x[0] for x in self.execute(clause % x)] )
			

		l = self.global_implied_attrs + l_fk
		excludes = ', '.join ( [ ''.join(["'",x,"'"]) for x in l ] ) 
		r = self.execute("""
		select attname from pg_attribute a, pg_class c where c.relfilenode = a.attrelid and
		c.relname = '%s' and attnum > 0 and a.attname %s in ( %s ) """ % ( table, fk_cmp, excludes) ) 
		l = [ x[0] for x in r]
		return l

	def get_attribute_type(self, table, attr):
		if not self.attr_types.has_key(table):
			r = self.execute("""
		select attname, typname from pg_type t, pg_attribute a, pg_class c where c.relfilenode = a.attrelid and c.relname = '%s'  and a.atttypid = t.oid
			""" % ( table) )
			self.attr_types[table]  = dict([ (x[0],x[1]) for x in r] )

		return self.attr_types[table].get(attr,'text') 
		

	def execute(self,stmt):
		cu = self.conn.cursor()
		try:
			cu.execute(stmt)
		except:
			raise
		r = cu.fetchall()
		return r , cu.description
		
	
	def get_pk_attr( self):
		stmt = """
		select  c.relname, a.attname from pg_attribute a, pg_class c, pg_constraint pc where  a.attrelid = c.relfilenode and pc.contype= 'p' and pc.conrelid = a.attrelid and pc.conkey[1] = a.attnum

		""" 
		cu = self.conn.cursor()
		cu.execute(stmt)
		return cu.fetchall()

if __name__=="__main__":
	s = SchemaScan()
