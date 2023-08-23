


__doc__ = """GNUmed GUI element brokerage

This module provides wrappers for the equivalent of global
variables needed for a gnumed GUI client interface

@author: Dr. Horst Herb
@version: 0.2
@copyright: GPL v2 or later
"""

__author__ = "H.Herb <hherb@gnumed.net>, H.Berger <Hilmar.Berger@gmx.de>"
#===========================================================
# FIXME !!! hack moved here from gmConf. This definitely must be replaced by some 
# structure getting data from the backend
# FIXME: hardcoded color/width !?! move to DB (?)
config = {'main.use_notebook':1, 'main.shadow.colour':(131, 129, 131), 'main.shadow.width':10}

#===========================================================
class GuiBroker:
	"Wrapper for global objects needed by GNUMmed GUI clients"

	#This class wraps all global gui objects (variables)for a gnumed
	#application. The static (at application level)dictionary
	#__objects can be accessed through the method addobject
	#and getobject.
	#So, if you need to access the main window frame, you would
	#query an instance of GuiBroker for it.

	__objects = {}
	__keycounter=0


	def __init__(self):
		pass


	def addobject(self, widget, key=None):
		"Add an object to the gnumed gui object dictionary"

		#An object can be anything (class, variable, widget)
		#The "key" is a key expression (number, text) that
		#allows you to retrieve the object.
		#Convention for keys is the widget or variable name
		#as a text string
		#If key is not passed as parameter, a unique serial
		#number is allocated as key and returned

		if not key:
		# create a new sequential key that doesn't exist yet
			key = GuiBroker.__keycounter + 1
			while key in GuiBroker.__objects:
				key +=1
		GuiBroker.__keycounter = key
		GuiBroker.__objects[key]=widget
		return key



	def getobject(self, key):
		"allows to retrieve a gnumed gui element; see addobject() regarding the key parameter"
		return GuiBroker.__objects[key]

	def has_key( self, key):
		return key in GuiBroker.__objects



	def keylist(self):
		" returns a list of all keys; see documentation for the dictionary data type"
		return list(GuiBroker.__objects)



	def valuelist(self):
		"returns a list of all values; see documentation for the dictionary data type"
		return GuiBroker.__objects.values()



	def itemlist(self):
		"returns a list of all key:value pairs; see documentation for the dictionary data type"
		return GuiBroker.__objects.items()



	def __getitem__(self, key):
		"Allows retrieving the value via value = instance[key]"
		return self.getobject(key)



	def __setitem__(self, key, object):
		"Allows access in the style of instance[key]=value"
		return self.addobject(object, key)

#===========================================================
if __name__ == "__main__":

	import sys

	if len(sys.argv) < 2:
		sys.exit()

	if sys.argv[1] != 'test':
		sys.exit()

	# you can test this module by invoking it as main program
	print('>>> gmGuiBroker.GuiBroker test')
	test = GuiBroker()

	print('>>> test.addobject("something", 3)')
	var = test.addobject("something", 3)
	print(var, "\n")

	print('>>> test.addobject("something else without a specified key")')
	var = test.addobject("something else without a specified key")
	print(var, "\n")

	print('>>> test.addobject(test)')
	testreference = test.addobject(test)
	print(testreference, "\n")

	print('>>> test.addobject(100, "hundred)')
	var = test.addobject(100, "hundred")
	print(var, "\n")

	print(">>> test.keylist()")
	var = test.keylist()
	print(var, "\n")

	print(">>> test.valuelist()")
	var = test.valuelist()
	print(var, "\n")

	print(">>> test.itemlist()")
	var = test.itemlist()
	print(var, "\n")

	print(">>> test[3]")
	var = test[3]
	print(var, "\n")

	print(">>> test[testreference].getobject('hundred')")
	var = test[testreference].getobject('hundred')
	print(var, "\n")

	print(">>> var = test[testreference]")
	var = test[testreference]
	print(var, "\n")

	print(">>> var = var['hundred']")
	var = var['hundred']
	print(var, "\n")

	print('>>> try: test.addobject["duplicate key", 3]')
	print('>>> except KeyError: print("Duplicate keys not allowed!"')
	try: test["duplicate key", 3]
	except KeyError: print("Duplicate keys not allowed!")

	print(">>> test['key']='value'")
	test['key']='value'
	print(test['key'])
