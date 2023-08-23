# -*- coding: utf-8 -*-
#############################################################################
# gmDemographics
# ----------------------------------
#
# This panel will hold all the patients details
#
# If you don't like it - change this code see @TODO!
#
# @copyright: authorcd
# @license: GPL v2 or later (details at http://www.gnu.org)
# @dependencies: wxPython (>= version 2.3.1)
# @change log:
#	    10.06.2002 rterry initial implementation, untested
#           30.07.2002 rterry images put in file
# @TODO:
############################################################################
# $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/client/wxpython/patient/gmDemographics.py,v $
# $Id: gmDemographics.py,v 1.40 2008-04-13 14:39:49 ncq Exp $
__version__ = "$Revision: 1.40 $"
__author__ = "R.Terry, SJ Tan"


import wx

from mx import DateTime

from Gnumed.pycommon import gmGuiBroker, gmDispatcher

import gmPlugin
import gmSQLListControl
from string import *
#import gmGP_PatientPicture

ID_PATIENT = wxNewId()
ID_PATIENTSLIST = wxNewId()
ID_ALL_MENU  = wxNewId()
ID_ADDRESSLIST = wxNewId()
ID_NAMESLIST = wxNewId()
ID_CURRENTADDRESS = wxNewId()
gmSECTION_PATIENT = 5
ID_COMBOTITLE = wxNewId()
ID_COMBOSEX = wxNewId()
ID_COMBOMARITALSTATUS = wxNewId()
ID_COMBONOKRELATIONSHIP = wxNewId()
ID_TXTSURNAME = wxNewId()
ID_TXTFIRSTNAME = wxNewId()
ID_TXTSALUTATION = wxNewId()
ID_TXTSTREET = wxNewId()
ID_TXTSUBURB = wxNewId()
ID_TXTSTATE = wxNewId()
ID_TXTPOSTCODE = wxNewId()
ID_TXTBIRTHDATE = wxNewId()
ID_TXTCOUNTRYOFBIRTH = wxNewId()
ID_TXTOCCUPATION = wxNewId()
ID_TXTNOKADDRESS = wxNewId()
ID_TXTHOMEPHONE = wxNewId()
ID_TXTWORKPHONE = wxNewId()
ID_TXTFAX = wxNewId()
ID_TXTEMAIL = wxNewId()
ID_TXTINTERNET = wxNewId()
ID_TXTMOBILE = wxNewId()
ID_TXTMEMO = wxNewId()
ID_LISTADDRESSES = wxNewId()
ID_BUTTONBROWSENOK = wxNewId()
ID_BUTTONPHOTOAQUIRE = wxNewId()
ID_BUTTONPHOTOEXPORT = wxNewId()
ID_BUTTONPHOTOIMPORT = wxNewId()
ID_CHKBOXRESIDENCE = wxNewId()
ID_CHKBOXPOSTAL = wxNewId()
ID_CHKBOXPREFERREDALIAS = wxNewId()
ID_BUTTONFINDPATIENT = wxNewId()
ID_TXTPATIENTFIND = wxNewId()
ID_TXTPATIENTAGE = wxNewId()
ID_TXTPATIENTALLERGIES  = wxNewId()

#------------------------------------
#Dummy data to simulate allergy items
#------------------------------------
aliasdata = {
1 : ("Peter Patient"),
2 : ("Bruce Dag"),
}
namelistdata = [
	'Smith Adan 129 Box Hill Road BOX HILL etc....',
	'Smith Jean 52 WhereEver Street CANBERRA etc.....',
	'Smith Michael 99 Longbeach Rd MANLYVALE  etc........'
]

addressdata = ['129 Afred Street WARNERS BAY 2280', '99 Wolfe Street NEWCASTLE 2301']

#--------------------------------------------------
#Class which shows a blue bold label left justified
#--------------------------------------------------
class BlueLabel(wxStaticText):
	def __init__(self, parent, id, prompt):
		wxStaticText.__init__(self,parent, id,prompt,wxDefaultPosition,wxDefaultSize,wxALIGN_LEFT)
		self.SetFont(wxFont(12,wxSWISS,wxNORMAL,wxBOLD,False,''))
		self.SetForegroundColour(wxColour(0,0,131))
#------------------------------------------------------------
#text control class to be later replaced by the gmPhraseWheel
#------------------------------------------------------------
class TextBox_RedBold(wxTextCtrl):
	def __init__ (self, parent, id): #, wxDefaultPostion, wxDefaultSize):
		wxTextCtrl.__init__(self,parent,id,"",wxDefaultPosition, wxDefaultSize,wxSIMPLE_BORDER)
		self.SetForegroundColour(wxColor(255,0,0))
		self.SetFont(wxFont(12,wxSWISS,wxNORMAL, wxBOLD,False,''))
class TextBox_BlackNormal(wxTextCtrl):
	def __init__ (self, parent, id): #, wxDefaultPostion, wxDefaultSize):
		wxTextCtrl.__init__(self,parent,id,"",wxDefaultPosition, wxDefaultSize,wxSIMPLE_BORDER)
		self.SetForegroundColour(wxColor(0,0,0))
		self.SetFont(wxFont(12,wxSWISS,wxNORMAL, wxBOLD,False,''))
#------------------------------------------------------------
class PatientsPanel(wxPanel, gmDataPanelMixin.DataPanelMixin):
	def __init__(self, parent, plugin, id=wxNewId ()):
		wxPanel.__init__(self, parent, id ,wxDefaultPosition,wxDefaultSize,wxRAISED_BORDER|wxTAB_TRAVERSAL)
		gmDataPanelMixin.DataPanelMixin.__init__(self)
		self.gb = gmGuiBroker.GuiBroker ()
		self.mwm = self.gb['clinical.manager']
		self.plugin = plugin
		# controls on the top toolbar are available via plugin.foo
		self.addresslist = wxListBox(self,ID_NAMESLIST,wxDefaultPosition,wxDefaultSize,addressdata,wxLB_SINGLE)
		self.addresslist.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, '')) #first list with patient names
		self.addresslist.SetForegroundColour(wxColor(180,182,180))
		# code to link up SQLListControl
		self.patientslist = gmSQLListControl.SQLListControl (self, ID_PATIENTSLIST, hideid=True, style= wxLC_REPORT|wxLC_NO_HEADER|wxSUNKEN_BORDER)
		self.patientslist.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, '')) #first list with patient names
		EVT_LIST_ITEM_SELECTED (self.patientslist, ID_PATIENTSLIST, self.OnPatient)
		self.lbl_surname = BlueLabel(self,-1,"Surname")
		self.lbl_firstname = BlueLabel(self,-1,"Firstname")
		self.lbl_preferredname = BlueLabel(self,-1,"Salutation")
		self.lbl_title = BlueLabel(self,-1,"Title")
		self.lbl_sex = BlueLabel(self,-1,"Sex ")
		self.lbl_street = BlueLabel(self,-1,"Street")
		self.lbl_suburb = BlueLabel(self,-1,"Suburb")
		self.lbl_zip = BlueLabel(self,-1,"Postcode")
		self.lbl_address_s = BlueLabel(self,-1,"Address(s)")
		self.lbl_birthdate = BlueLabel(self,-1,"Birthdate")
		self.lbl_maritalstatus = BlueLabel(self,-1,"  Marital Status")
		self.lbl_occupation = BlueLabel(self,-1,"Occupation")
		self.lbl_birthplace = BlueLabel(self,-1,"Born In")
		self.lbl_nextofkin = BlueLabel(self,-1,"")
		self.lbl_addressNOK = BlueLabel(self,-1,"Next of Kin")
		self.lbl_relationship = BlueLabel(self,-1,"  Relationship  ")
		self.lbl_homephone = BlueLabel(self,-1,"Home Phone")
		self.lbl_workphone = BlueLabel(self,-1,"Work Phone")
		self.lbl_fax = BlueLabel(self,-1,"Fax")
		self.lbl_mobile = BlueLabel(self,-1,"Mobile")
		self.lbl_email = BlueLabel(self,-1,"Email")
		self.lbl_web = BlueLabel(self,-1,"Web")
		self.lbl_mobile = BlueLabel(self,-1,"Mobile")
		self.lbl_line6gap = BlueLabel(self,-1,"")
		self.titlelist = ['Mr', 'Mrs', 'Miss', 'Mst', 'Ms', 'Dr', 'Prof']
          	self.combo_relationship = wxComboBox(self, 500, "", wxDefaultPosition,wxDefaultSize, ['Father','Mother'], wxCB_DROPDOWN)
		self.txt_surname = TextBox_RedBold(self,-1)
		self.combo_title = wxComboBox(self, 500, "", wxDefaultPosition,wxDefaultSize,self.titlelist, wxCB_DROPDOWN)
		self.txt_firstname = TextBox_RedBold(self,-1)
		self.combo_sex = wxComboBox(self, 500, "", wxDefaultPosition,wxDefaultSize, ['M','F'], wxCB_DROPDOWN)
		self.cb_preferredname = wxCheckBox(self, -1, _("Preferred Name"), wxDefaultPosition,wxDefaultSize, wxNO_BORDER)
		self.txt_preferred = TextBox_RedBold(self,-1)
		self.txt_address = wxTextCtrl(self, 30, "",
					      wxDefaultPosition,wxDefaultSize, style=wxTE_MULTILINE|wxNO_3D|wxSIMPLE_BORDER)
		self.txt_address.SetInsertionPoint(0)
		self.txt_address.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, ''))
		self.txt_suburb = TextBox_BlackNormal(self,-1)
		self.txt_zip = TextBox_BlackNormal(self,-1)
		self.txt_birthdate = TextBox_BlackNormal(self,-1)
		self.combo_maritalstatus = wxComboBox(self, 500, "", wxDefaultPosition,wxDefaultSize,
						      ['single','married'], wxCB_DROPDOWN)
		self.txt_occupation = TextBox_BlackNormal(self,-1)
		self.txt_countryofbirth = TextBox_BlackNormal(self,-1)
		self.btn_browseNOK = wxButton(self,-1,"Browse NOK") #browse database to pick next of Kin
		self.txt_nameNOK = wxTextCtrl(self, 30,
					      "Peter Smith \n"
					      "22 Lakes Way \n"
					      "Valentine 2280",
					      wxDefaultPosition,wxDefaultSize, style=wxTE_MULTILINE|wxNO_3D|wxSIMPLE_BORDER)
		self.txt_nameNOK.SetInsertionPoint(0)
		self.txt_nameNOK.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, ''))
		self.txt_homephone = TextBox_BlackNormal(self,-1)
		self.txt_workphone = TextBox_BlackNormal(self,-1)
		self.txt_fax = TextBox_BlackNormal(self,-1)

		self.txt_email = TextBox_BlackNormal(self,-1)
		self.txt_web = TextBox_BlackNormal(self,-1)
		self.txt_mobile = TextBox_BlackNormal(self,-1)
                #----------------------
		#create the check boxes
		#----------------------
		self.cb_addressresidence = wxCheckBox(self, -1, " Residence ", wxDefaultPosition,wxDefaultSize, wxNO_BORDER)
		self.cb_addresspostal = wxCheckBox(self, -1, " Postal ", wxDefaultPosition,wxDefaultSize, wxNO_BORDER)
		#--------------------
		# create the buttons
		#--------------------
		self.btn_photo_import= wxButton(self,-1,"Import")
		self.btn_photo_export = wxButton(self,-1,"Export")
		self.btn_photo_aquire = wxButton(self,-1,"Acquire")
		#-------------------------------------------------------
		#Add the each line of controls to a horizontal box sizer
		#-------------------------------------------------------
		self.sizer_line0_left = wxBoxSizer(wxHORIZONTAL)
		#line one:surname, title
		self.sizer_line1_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line1_left.Add(self.lbl_surname,3, wxGROW|wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line1_left.Add(self.txt_surname,7,wxEXPAND)
		self.sizer_line1_left.Add(0,0,1)
		self.sizer_line1_left.Add(self.lbl_title,2,wxALIGN_CENTER_VERTICAL, 5)
		self.sizer_line1_left.Add(self.combo_title,4,wxEXPAND)
		#line two:firstname, sex
		self.sizer_line2_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line2_left.Add(self.lbl_firstname,3,wxGROW|wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line2_left.Add(self.txt_firstname,7,wxEXPAND)
		self.sizer_line2_left.Add(0,0,1)
		self.sizer_line2_left.Add(self.lbl_sex,2,wxGROW|wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line2_left.Add(self.combo_sex,4,wxEXPAND)
		#line three:preferred salutation
		self.sizer_line3_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line3_left.Add(self.lbl_preferredname,3,wxGROW|wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line3_left.Add(self.txt_preferred,7,wxEXPAND)
		self.sizer_line3_left.Add(1,0,7)
		#line four: preferred alias
		self.sizer_line4_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line4_left.Add(1,0,3)
		self.sizer_line4_left.Add(self.cb_preferredname,7,wxEXPAND)
		self.sizer_line4_left.Add(1,0,7)
		#line6 on this left side is blank
		self.sizer_line6_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line6_left.Add(self.lbl_line6gap,1,wxEXPAND)
		#----------------
		#3:street details
		#a) the label
		sizer_lblstreet = wxBoxSizer(wxVERTICAL)
		sizer_lblstreet.Add(self.lbl_street,1, wxEXPAND)
		#--------------------
		#3:street details
		#b) multiline textbox
		#-------------------
		self.sizer_line7_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line7_left.Add(0,0,1)
		#------------------------------
		#3:street details
		#c) residence or postal address
		#------------------------------
		sizer_respostal = wxBoxSizer(wxVERTICAL)
		sizer_respostal.Add(self.cb_addressresidence,1,wxEXPAND)
		sizer_respostal.Add(self.cb_addresspostal,1,wxEXPAND)
		#sizer_respostal.Add(1,0,1)
		self.sizer_line7_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line7_left.Add(sizer_lblstreet,3,wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line7_left.Add(self.txt_address,7,wxEXPAND)
		self.sizer_line7_left.Add(0,0,1)
		self.sizer_line7_left.Add(sizer_respostal,6,wxEXPAND)
		#--------------------------
		# create the suburb details
		#--------------------------
		self.sizer_line8_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line8_left.Add(self.lbl_suburb,3,wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line8_left.Add(self.txt_suburb,7,wxEXPAND)
		self.sizer_line8_left.Add(0,0,1)
		self.sizer_line8_left.Add(self.lbl_zip,3,wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line8_left.Add(self.txt_zip,3,wxEXPAND)
		#--------------------------------
		# create the multiple address box
		#--------------------------------
		self.sizer_line9_left = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line9_left.Add(self.lbl_address_s,3,wxALIGN_CENTER_VERTICAL,5)
		self.sizer_line9_left.Add(self.addresslist,14,wxEXPAND)
		#-------------------------------------------------------------------------
		#now add all the left hand line sizers to the one left hand vertical sizer
		#-------------------------------------------------------------------------
		self.leftside = wxBoxSizer(wxVERTICAL)
		self.leftside.Add(self.sizer_line1_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line2_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line3_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line4_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line6_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line7_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line8_left,0,wxEXPAND|wxALL,1)
		self.leftside.Add(self.sizer_line9_left,0,wxEXPAND|wxALL,1)
		#---------------------------------------------------
		#now add textboxes etc to the right hand line sizers
		#---------------------------------------------------
		self.sizer_line0_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line1_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line2_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line3_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line4_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line5_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line6_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line7_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line8_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line9_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line10_right = wxBoxSizer(wxHORIZONTAL)
		self.sizer_line11_right = wxBoxSizer(wxHORIZONTAL)
		#line1 _ birthdate, maritial status
		self.sizer_line1_right.Add(self.lbl_birthdate,2,wxALIGN_CENTER_VERTICAL,0)
		self.sizer_line1_right.Add(self.txt_birthdate,2,wxALIGN_LEFT)
		self.sizer_line1_right.Add(self.lbl_maritalstatus,2,wxALIGN_CENTRE,0)
		self.sizer_line1_right.Add(self.combo_maritalstatus, 2, wxALIGN_CENTER_VERTICAL,0)
		#line2 - occupation (use word wheel later in place of text box)
		self.sizer_line2_right.Add(self.lbl_occupation,2,wxALIGN_CENTER_VERTICAL,0)
		self.sizer_line2_right.Add(self.txt_occupation,6,wxEXPAND)
		#line3 - country of birth (use word wheel later)
		self.sizer_line3_right.Add(self.lbl_birthplace,2,wxALIGN_CENTER_VERTICAL,0)
		self.sizer_line3_right.Add(self.txt_countryofbirth,6,wxEXPAND)
		#line 4 - next of kin + browse for next of kin
		self.sizer_line4_right.Add(self.lbl_nextofkin, 2,wxALIGN_CENTER_VERTICAL,0)
		self.sizer_line4_right.Add(self.btn_browseNOK,2, wxALIGN_CENTER_VERTICAL)
		#self.sizer_line4_right.Add(0,0,1)
		self.sizer_line4_right.Add(self.lbl_relationship,2, wxALIGN_CENTER_VERTICAL,0)
		self.sizer_line4_right.Add(self.combo_relationship,2,wxEXPAND)
		#name of next of kin
		self.sizer_gap_vertical =wxBoxSizer(wxVERTICAL)
		self.sizer_gap_vertical.Add(1,47,1)
		self.sizer_line5_right.Add(self.lbl_addressNOK,2,wxEXPAND)
		self.sizer_line5_right.Add(self.txt_nameNOK, 6,wxEXPAND)
		self.sizer_line5_right.AddSizer(self.sizer_gap_vertical)
		#----------------------------------------------------------------------------
		# Contact numbers are on their own separate vertical sizer as the photo sits
		# next to this
		#----------------------------------------------------------------------------
		self.sizer_contacts = wxBoxSizer(wxVERTICAL)
		self.sizer_line6_right.Add(self.lbl_homephone, 3,wxALIGN_CENTRE,0)
		self.sizer_line6_right.Add(self.txt_homephone, 5,wxEXPAND)
		self.sizer_line6_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line6_right,0,wxEXPAND)
		self.sizer_line7_right.Add(self.lbl_workphone,3,wxALIGN_CENTRE,0)
		self.sizer_line7_right.Add(self.txt_workphone, 5,wxEXPAND)
		self.sizer_line7_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line7_right,0,wxEXPAND)
		self.sizer_line8_right.Add(self.lbl_fax,3,wxALIGN_CENTRE,0)
		self.sizer_line8_right.Add(self.txt_fax, 5,wxEXPAND)
		self.sizer_line8_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line8_right,0,wxEXPAND)
		self.sizer_line9_right.Add(self.lbl_email,3,wxALIGN_CENTRE,0)
		self.sizer_line9_right.Add(self.txt_email, 5,wxEXPAND)
		self.sizer_line9_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line9_right,0,wxEXPAND)
		self.sizer_line10_right.Add(self.lbl_web,3,wxALIGN_CENTRE,0)
		self.sizer_line10_right.Add(self.txt_web, 5,wxEXPAND)
		self.sizer_line10_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line10_right,0,wxEXPAND)
		self.sizer_line11_right.Add(self.lbl_mobile,3,wxALIGN_CENTRE,0)
		self.sizer_line11_right.Add(self.txt_mobile, 5,wxEXPAND)
		self.sizer_line11_right.Add(0,0,1)
		self.sizer_contacts.Add(self.sizer_line11_right,0,wxEXPAND)
		self.sizer_photo = wxBoxSizer(wxVERTICAL)
#		self.patientpicture = gmGP_PatientPicture.cPatientPicture(self, -1)
		self.sizer_photo.Add(self.patientpicture,3,wxALIGN_CENTER_HORIZONTAL,0)
		self.sizer_photo.Add(self.btn_photo_aquire,1,wxALIGN_CENTER_HORIZONTAL,0)
		self.sizer_photo.Add(self.btn_photo_export,1,wxALIGN_CENTER_HORIZONTAL,0)
		self.sizer_photo.Add(self.btn_photo_import,1,wxALIGN_CENTER_HORIZONTAL,0)
		self.sizer_contactsandphoto  = wxBoxSizer(wxHORIZONTAL)
		self.sizer_contactsandphoto.AddSizer(self.sizer_contacts,6,wxALIGN_CENTER_VERTICAL,0)
		self.sizer_contactsandphoto.AddSizer(self.sizer_photo,2,wxALIGN_CENTER_VERTICAL,0)
		self.rightside = wxBoxSizer(wxVERTICAL)
		self.rightside.Add(self.sizer_line1_right,0,wxEXPAND|wxALL,1)
		self.rightside.Add(self.sizer_line2_right,0,wxEXPAND|wxALL,1)
		self.rightside.Add(self.sizer_line3_right,0,wxEXPAND|wxALL,1)
		self.rightside.Add(self.sizer_line4_right,0,wxEXPAND|wxALL,1)
		self.rightside.Add(self.sizer_line5_right,0,wxEXPAND|wxALL,1)
		self.rightside.Add(self.sizer_contactsandphoto,0,wxEXPAND|wxALL,1)
		self.mainsizer = wxBoxSizer(wxVERTICAL)
		self.topsizer = wxBoxSizer(wxHORIZONTAL)
		self.sizerunder = wxBoxSizer(wxHORIZONTAL)
		self.sizerunder.AddSizer(self.leftside,10,wxEXPAND|wxALL,5)
		self.sizerunder.Add(1,0,1)
		self.sizerunder.AddSizer(self.rightside,10,wxEXPAND|wxALL,5)
		self.mainsizer.Add(self.patientslist,3,wxEXPAND)
		self.mainsizer.Add(self.sizerunder,0,wxEXPAND|wxALL,10)
		self.SetSizer(self.mainsizer)
		self.SetAutoLayout(True)
		self.Show(False)


	def OnPatient (self, event):
		pat_id = event.GetData ()
		index = event.GetIndex ()
		gmLog.gmDefLog.Log (gmLog.lInfo, "selected patient ID %s" % pat_id)
		pat_title = self.patientslist.GetItem (index, 0).GetText ()
		pat_fname = self.patientslist.GetItem (index, 1).GetText ()
		pat_lname = self.patientslist.GetItem (index, 2).GetText ()
		pat_dob = self.patientslist.GetItem (index, 3).GetText ()
		# load the demographic text controls
		# send a signal to other objects
		kwds = {'title':pat_title, 'firstnames':pat_fname, 'lastnames':pat_lname, 'dob':pat_dob, 'ID':pat_id}
		gmDispatcher.send ('post_patient_selection', sender='Terry Patient Selector', kwds=kwds )

	def FindPatient (self, name):
		self.patientslist.SetQueryStr (gmPatientNameQuery.MakeQuery (name), service='personalia')
		self.patientslist.RunQuery ()

#============================================================
#class gmDemographics(gmPlugin.wxBasePlugin):
#	"""A plugin for searching the patient database by name.
#
#	Required the gmPatientWindowPlugin to be loaded.
#	CANNOT BE UNLOADED
#	"""
#	def name (self):
#		return 'Patient Search'
#	#--------------------------------------------------------
#	def register (self):
#		# first, set up the widgets on the top line of the toolbar
#		top_panel = self.gb['main.top_panel']
#
#		# and register ourselves as a widget
#		self.gb['modules.patient'][self.__class__.__name__] = self		# split/renamed 'horstspace.notebook.%s'
#		self.mwm = self.gb['clinical.manager']
#		self.widget = PatientsPanel (self.mwm, self)
#		self.mwm.RegisterWholeScreen(self.__class__.__name__, self.widget)
#		self.RegisterInterests()
#	#--------------------------------------------------------
#	def OnTool (self, event):
#		pass
#		self.mwm.Display (self.__class__.__name__)
#		print "OnTool"
#		self.gb['modules.gui']['Patient'].Raise()		# split/renamed 'horstspace.notebook.%s'
#
#	def RegisterInterests(self):
#		pass
#		gmDispatcher.connect(self.OnSelected, gmSignals.post_patient_selection())
#
#	def OnSelected (self, **kwargs):
#		pass
#----------------------------------------------------------------------
if __name__ == "__main__":
	import gmGuiBroker
	app = wxPyWidgetTester(size = (800, 600))
	app.SetWidget(PatientsPanel, -1)
	app.MainLoop()
#----------------------------------------------------------------------
