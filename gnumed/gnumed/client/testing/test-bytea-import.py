import locale
# this is what makes the difference:
# likely because it somehow changes which encoding
# Python thinks comes back from file.read()
locale.setlocale(locale.LC_ALL, '')

import sys, os.path, io

import pyPgSQL.PgSQL as dbapi

__license__ = "GPL"
dsn = "::gnumed_v9:any-doc:any-doc"
#dsn = "publicdb.gnumed.de:5432:gnumed_v2:any-doc:any-doc"
fname = sys.argv[1]
encodings = 'win1250 win1252 latin1 iso-8859-15 sql_ascii latin9'.split()

log = io.open('test-bytea-import.log', mode = 'wb', encoding = 'utf8')

log.write('running on:\n')
log.write(sys.version + '\n')
log.write(sys.platform + '\n')
conn = dbapi.connect(dsn=dsn)
log.write(str(conn.version) + '\n')
conn.close()
del conn

log.write('importing: [%s]' % fname + '\n')

for encoding in encodings:

	print "encoding:", encoding

	log.write("----------------------------------------------" + '\n')
	log.write("testing encoding: [%s]" % encoding + '\n')

	log.write("Python string encoding [%s]" % sys.getdefaultencoding() + '\n')

	# reading file
	log.write("os.path.getsize(%s): [%s]" % (fname, os.path.getsize(fname)) + '\n')
	f = open(fname, "rb")
	img_data = f.read()
	f.close()
	log.write("type(img_data): [%s]" % type(img_data) + '\n')
	log.write("len(img_data) : [%s]" % len(img_data) + '\n')
	img_obj = dbapi.PgBytea(img_data)
	del(img_data)
	log.write("len(img_obj) : [%s]" % len(str(img_obj)) + '\n')
	log.write("type(img_obj): [%s]" % type(img_obj) + '\n')

	# setting connection level client encoding
	try:
		if encoding == 'sql_ascii':
			conn = dbapi.connect(dsn=dsn, unicode_results=0)
		else:
			conn = dbapi.connect(dsn=dsn, client_encoding = (encoding, 'strict'), unicode_results=0)
		curs = conn.cursor()
		cmd = "set client_encoding to '%s'" % encoding
		curs.execute(cmd)
		curs.close()
	except Exception:
		log.write("cannot set encoding [%s] in dbapi.connect()" % encoding + '\n')
		conn = dbapi.connect(dsn=dsn)

	curs = conn.cursor()

	try:
		# import data
		cmd = "create table test (data bytea)"
		curs.execute(cmd)
		cmd = "insert into test (data) values (%s)"
		curs.execute(cmd, img_obj)
		cmd = "select octet_length(data) from test"
		curs.execute(cmd)
		log.write("INSERTed octet_length(test.data): [%s]" % curs.fetchall()[0][0] + '\n')
		cmd = "update test set data=%s"
		curs.execute(cmd, img_obj)
		cmd = "select octet_length(data) from test"
		curs.execute(cmd)
		log.write("UPDATEd octet_length(test.data): [%s]" % curs.fetchall()[0][0] + '\n')
		cmd = "select data from test"
		curs.execute(cmd)
		rows = curs.fetchone()
		log.write("len(SELECT)  : [%s]" % len(str(rows[0])) + '\n')
	except Exception:
		log.write('cannot test encoding [%s]' % encoding + '\n')
		t, v, tb = sys.exc_info()
		log.write(str(t) + '\n')
		log.write(str(v) + '\n')

	# finish
	conn.rollback()
	curs.close()
	conn.close()

log.close()

#=======================================================================
