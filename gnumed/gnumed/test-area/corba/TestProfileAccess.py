import PersonIdService
import ResolveIdComponent
import CORBA
import sys, string, random, traceback
from PersonIdTestUtils import *
import PersonIdTestUtils

N_PROFILES_TO_CHANGE = 10
debug = 0
last_id = 0
import HL7Version2_3
global hl7
hl7 = HL7Version2_3

def test():
	global debug
	debug = '-debug' in sys.argv

	resolver = ResolveIdComponent.IDComponentResolver()
	if "-gnumed" in sys.argv:
		ic = resolver.getIdentificationComponent("gnumed")
	else: ic = resolver.getIdentificationComponent()
	profAccess = ic._get_profile_access()

	print type(profAccess)
	print PersonIdService._tc_ProfileAccess.__methods__

	if not '-local' in sys.argv and  not profAccess._is_a(PersonIdService._tc_ProfileAccess.id()):
		print "FAILED to get EXPECTED profile access"
	else:
		print" PASS: profAccess type "
	init_trait_spec(profAccess)
 	_test_get_traits_known(profAccess)
	_test_get_profile(profAccess)
	_test_get_profile_list(profAccess)
	_test_update_and_clear_traits(profAccess)
	if '-local' in sys.argv:
		profAccess.report()

def _test_get_traits_known(pxs):
	traits_known = []
	ids  = __get_test_ids(pxs)
	print "ids are ", ids
	for id in ids:
		try:
			result = pxs.get_traits_known(id)
			if result not in traits_known:
				traits_known.append(result)
		except:
			print sys.exc_info()[0], sys.exc_info()[1]
	global debug
	if debug:
		print "The variations of traits known are :-"
		for x in traits_known:
			print x

	if len (traits_known) > 0:
		print "PASS: traits_known() returned ", len(traits_known), "sets of known traits in ", len(ids) , "identitities"
	else:
		print "FAIL: get_traits_known() returned no sets for various ids"


def _test_get_profile(pxs):
	tprofiles = __get_test_tagged_profiles(pxs)
	unmatched = 0
	for  tp in tprofiles :
		p = pxs.get_profile(str(tp.id),  get_specified_traits("ALL_TRAITS") )
		if not same_profile(p, tp.profile):
			unmatched += 1
	if debug:
		print "Unmatched profiles = ", unmatched
	if unmatched == 0:
		print "PASS: get_profile() returns the same profiles as sequential access get_first_ids, for ", len(tprofiles), " identities"



def _test_get_profile_list(pxs):
	tprofiles = __get_test_tagged_profiles(pxs)
	ids = [tp.id for tp in tprofiles]
	list = pxs.get_profile_list(ids, get_specified_traits("ALL_TRAITS") )
	matched = 0
	for i in xrange(0, len(tprofiles)):
		if tprofiles[i].id == list[i].id and same_profile(tprofiles[i].profile, list[i].profile ):
			matched += 1

	if matched == len(tprofiles):
		print "PASS: get_profile_list returns all matching tagged_profiles"
	print "matched = ", matched

def _test_update_and_clear_traits(pxs):
	init_trait_spec(pxs)
	tprofiles = __get_test_tagged_profiles(pxs)

	oldNames = [ find_trait_in_profile(hl7.PATIENT_NAME, tp.profile).value.value() for tp in tprofiles]
	if debug:
		print "old names = ", oldNames

	surnames, firstnames = ['Aardvarrk', 'Echidna', 'Platypus', 'Kookaburra', 'Koala', 'Wallaby', 'Bunyip'], ['Dave', 'Dougie', 'Sheila', 'Kylie', 'Darryl', 'Baza', "Sophie", "Cheryl", "Marlene"]
	import random
	r = random.Random()
	for tp in tprofiles:
		trait = find_trait_in_profile(hl7.PATIENT_NAME, tp.profile)

		trait.value = CORBA.Any(CORBA._tc_string, "^".join([r.choice(surnames), r.choice(firstnames)])+"^^^^")

	newNames = [ find_trait_in_profile(hl7.PATIENT_NAME, tp.profile).value.value() for tp in tprofiles]
	if debug:
		print "new names = ", newNames

	profileUpdateSeq = [ PersonIdService.ProfileUpdate(tp.id, [],  tp.profile)   for tp in tprofiles ]
	if debug:
		print "** THE profileUpdateSeq contents are"
		for pu in profileUpdateSeq:
			print "update with id=", pu.id
			for t in pu.modify_list:
				print "  ",t.name, "=", t.value.value()

	pxs.update_and_clear_traits(profileUpdateSeq)

	tprofiles2 =  __get_test_tagged_profiles(pxs)
	testNames  = [ find_trait_in_profile(hl7.PATIENT_NAME, tp.profile).value.value() for tp in tprofiles2]
	if debug:
		print
		print	"oldNames were", oldNames
		print
		print "retrieved post-op test names = ", testNames
		print
		print "expected newNames were", newNames
		print
	if testNames == newNames and testNames <> oldNames:
		print "PASS:", len(testNames), " test profiles had their PatientName trait changed"
	else:
		print "FAIL: update_or_clear_traits() , patient name change failed"
		if oldNames == testNames:
			print "old Names and testNames were the same"
		if testNames <> newNames:
			print "newNames were not the same as testNames"
	for i in xrange (0, len(tprofiles)):
		trait = find_trait_in_profile(hl7.PATIENT_NAME, tprofiles[i].profile)
		trait.value =CORBA.Any(CORBA._tc_string, oldNames[i])

	profileRestoreSeq = [ PersonIdService.ProfileUpdate(tp.id,[], tp.profile) for tp in tprofiles]

	pxs.update_and_clear_traits(profileUpdateSeq)

	tprofiles3 =  __get_test_tagged_profiles(pxs)
	restored_names =[ find_trait_in_profile(hl7.PATIENT_NAME, tp.profile).value.value() for tp in tprofiles3]

	if debug:
		print "restored names ",restored_names
	if restored_names == oldNames and restored_names <> testNames:
		print"PASS: old names were restored."

	_test_update_and_clear_address_traits(pxs)

def _test_update_and_clear_address_traits(pxs):
	tprofiles = __get_test_tagged_profiles(pxs)
	old_addresses = {}
	profileUpdateSeq = []
	import random, time

	for tp in tprofiles:
		location = PersonIdTestUtils.get_random_location(seed= time.time())
		street = PersonIdTestUtils.get_random_street(time.time())
		number = str ( random.randint(1,200) )
		l = filter( lambda(t): t.name == hl7.PATIENT_ADDRESS , tp.profile )
		if len(l) == 0:
			print "NO ADDRESS TRAIT FOUND"
		elif len(l) == 1:
			trait = l[0]
			if debug:
				print "old address trait for ", tp.id, " was ", trait.value.value()
			old_addresses[tp.id] = trait
		else:
			print "SHOULDN'T HAPPEN. more than one address trait ",tp.id

		new_trait = PersonIdService.Trait(hl7.PATIENT_ADDRESS, CORBA.Any(CORBA._tc_string,  '^'.join( [str(number)]+[street]+list(map( lambda(v): str(v), location)))) )
		profileUpdateSeq.append( PersonIdService.ProfileUpdate( tp.id, [], [new_trait] ))
	pxs.update_and_clear_traits( profileUpdateSeq)
	updateMap = dict( [(pu.id, pu.modify_list) for pu in profileUpdateSeq])

	tprofs2 = __get_test_tagged_profiles(pxs)
	for tp in tprofs2:

		if not updateMap.has_key(tp.id):
			print "FAIL: , updateMap doesnt record update for ", tp.id
			continue
		traits =  updateMap[tp.id]
		if len(traits) == 0:
			print "FAIL: update map has profile id but no update traits"
			continue
		trait = find_trait_in_profile(hl7.PATIENT_ADDRESS, tp.profile)
		if trait == None:
			print "FAIL: retrieved profile doesn't have the updated address"
			continue
		if trait.value.value() == traits[0].value.value():
			print "PASS: found updated address on retrieval of ",tp.id
		else:
			print "FAIL?: found different trait values : inserted=", traits[0].value.value() , " retrieved after modify = ", trait.value.value()

	restoreSeq = []
	for id, trait in old_addresses.items():
		restoreSeq.append( PersonIdService.ProfileUpdate( id, [] , [trait]))
	pxs.update_and_clear_traits( restoreSeq)
	tprof3 = __get_test_tagged_profiles(pxs)
	restored = filter( lambda(tp): tp.id in old_addresses.keys() , tprof3)
	orig_profile_map = dict( [ (tp.id, tp.profile) for tp in tprofiles])

	for tp in restored:
		p = orig_profile_map.get(tp.id, None)
		if p == None:
			print "FAIL, profile not found in original profiles ,id=",tp.id
			continue
		is_same , reason, errors = same_profile(p, tp.profile)
		if is_same:
			print "PASS: old profile was restored for ", tp.id

		else:
			print "PROFILES SEEM TO DIFFER :",reason,  errors




def same_profile(p, other):
	m = dict ( [ (t.name, t.value) for t in p ])
	m2 = dict( [ (t.name, t.value) for t in other] )
	k = m.keys()
	k.sort()
	k2 = m2.keys()
	k2.sort()
	if k <> k2:
		return 0 , "different keys", (k, k2)

	for k in k2:
		if m[k].value() <> m2[k].value():
			if debug:
				print "same_profile(p,other): FOUND  A different value", k, " value1 = ", m[k].value(), " value2 = ", m2[k].value()
			return 0, "a different value", (k, m[k].value(), m2[k].value() )
	return 1, None, None

def __get_test_tagged_profiles(pxs):
	"""gets them from sequential_access.get_first_ids( 100, [PERMANENT], [ALL_TRAITS] )"""
	sxs = pxs._get_sequential_access()
	states, specTraits = [find_id_state_like("PERM")], get_specified_traits("ALL_TRAITS")
	return  sxs.get_first_ids(N_PROFILES_TO_CHANGE,  states, specTraits)

def __get_test_ids(pxs):
	"""gets the ids only from the test tagged profiles"""
	tagged_profiles = __get_test_tagged_profiles(pxs)
	global debug
	if debug:
		output_tagged_profile_sequence(tagged_profiles)

	return [ tp.id for tp in tagged_profiles]

if __name__ == "__main__":
	if '-?' in sys.argv or '-h' in sys.argv:
		import help
		help.help()
		sys.exit(0)

	if '-profile' in sys.argv:
		import profile
		profile.run( 'test()')
		sys.exit(0)
	if '-profile2' in sys.argv:
		import profile
		profile.run('test()', 'test_profile.prof')
		sys.exit(0)
	test()
