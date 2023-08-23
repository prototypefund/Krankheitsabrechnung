import PersonIdService__POA
import sys
global supported_traits
import SqlTraits

from PersonIdTestUtils import init_trait_spec
global debug
debug = '-debug' in sys.argv



class StartIdentificationComponent(PersonIdService__POA.IdentificationComponent):
	def __init__(self, profileAccess, sequentialAccess, identifyPerson, idMgr):

		self.root = self
		self.components = {}
		self.components_this = {}

		self.addComponent('profile_access', profileAccess)
		self.addComponent( 'sequential_access', sequentialAccess)
		self.addComponent('identify_person', identifyPerson)
		self.addComponent('id_mgr', idMgr)

	def addComponent(self, name, component):
		self.components[name] = component
		self.components_this[name] = component._this()
		component.root = self



	def _get_profile_access(self):
		return self.get_component('profile_access')

	def _get_sequential_access(self):
		return self.get_component('sequential_access')

	def _get_identify_person(self):
		return self.get_component('identify_person')

	def _get_id_mgr(self):
		return self.get_component('id_mgr')

	def get_component(self,name):
		if debug:
			print "returning a ", name

		if '-local' in sys.argv:
			return self.root.components[name]

 		return self.root.components_this[name]


	def _get_supported_traits(self):
		return SqlTraits.supported_traits


if __name__ == "__main__":
	import ResolveIdComponent, CosNaming
	resolver = ResolveIdComponent.IDComponentResolver()

	poa = resolver.getORB().resolve_initial_references("RootPOA")

	pi = ResolveIdComponent.getStartIdentificationComponent()
	po = pi._this()
	name = [CosNaming.NameComponent("gnumed","")]
	context = resolver.getInitialContext()
	try:
		context.bind(name, po)
	except CosNaming.NamingContext.AlreadyBound:
		context.rebind(name, po)

	poaManager = poa._get_the_POAManager()
	poaManager.activate()
	if '-profile' in sys.argv:
		import profile
		profile.run('resolver.getORB().run()', 'profileAccess.prof')
	else:
		resolver.getORB().run()

