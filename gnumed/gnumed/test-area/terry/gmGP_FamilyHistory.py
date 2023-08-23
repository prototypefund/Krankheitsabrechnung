# -*- coding: utf-8 -*-
#!/usr/bin/python
#############################################################################
#
# gmGP_FamilyHistory.py
# ----------------------------------
#
# This panel will hold all the family history details
#
# If you don't like it - change this code see @TODO!
#
# @author: Dr. Richard Terry
# @copyright: author
# @license: GPL v2 or later (details at http://www.gnu.org)
# @dependencies: wxPython (>= version 2.3.1)

# @TODO:
#	almost everything
#      
############################################################################
__author__  = "R.Terry <rterry@gnumed.net>, H.Herb <hherb@gnumed.net>, S.Tan"


import wx

import gmEditArea, gmPlugin_Patient
import gmGuiElement_HeadingCaptionPanel		#panel class to display top headings
import gmGuiElement_DividerCaptionPanel		#panel class to display sub-headings or divider headings 
import gmGuiElement_AlertCaptionPanel		#panel to hold flashing alert messages
from gmPatientHolder import PatientHolder


ID_MEMBERCONDITIONSLIST = wxNewId()
ID_FAMILYMEMBERSLIST = wxNewId()
ID_IMMUNISATIONS = wxNewId()
ID_ALL_MENU  = wxNewId()
gmSECTION_FAMILYHISTORY = 4
#------------------------------------
#Dummy data to simulate allergy items
#------------------------------------
familymemberdata = {
1 : ("Mother",""),
2 : ("General Family History",""),
3 : ("Freda -Aunt",""),
}
membersconditionsdata = {
1 : ("Acute myocardial infarction aged 73, caused death 73",""),
2 : ("Hypertension age onset 40",""),
}

#----------------------------------------------------------------------
class FamilyHistoryPanel(wxPanel, PatientHolder):

	def __init__(self, parent,id):
		wxPanel.__init__(self, parent, id,wxDefaultPosition,wxDefaultSize,wxRAISED_BORDER)
		PatientHolder.__init__(self)
		# main heading
		self.FamilyHistoryPanelheading = gmGuiElement_HeadingCaptionPanel.HeadingCaptionPanel(self,-1,"  FAMILY AND SOCIAL HISTORY  ")
		# editarea
		self.editarea = gmEditArea.gmFamilyHxEditArea(self, -1)
		#self.editarea = gmFamilyHxEditArea(self, -1)
		#-----------------------------------------------
		#add the divider headings below the editing area
		#-----------------------------------------------
		self.family_members_heading = gmGuiElement_DividerCaptionPanel.DividerCaptionPanel(self,-1,"Family Members")
		self.members_disease_conditions = gmGuiElement_DividerCaptionPanel.DividerCaptionPanel(self,-1,"Condition")
		self.sizer_divider_members_condition = wxBoxSizer(wxHORIZONTAL) 
		self.sizer_divider_members_condition.Add(self.family_members_heading,1, wxEXPAND)
		self.sizer_divider_members_condition.Add( self.members_disease_conditions,1, wxEXPAND)
		#--------------------------------------------------------------------------------------
		#add the list to contain the family members
		#
		# c++ Default Constructor:
		# wxListCtrl(wxWindow* parent, wxWindowID id, const wxPoint& pos = wxDefaultPosition,
		# const wxSize& size = wxDefaultSize, long style = wxLC_ICON, 
		# const wxValidator& validator = wxDefaultValidator, const wxString& name = "listCtrl")
		#
		#--------------------------------------------------------------------------------------
		self.family_members_list = wxListCtrl(self, ID_FAMILYMEMBERSLIST,  wxDefaultPosition, wxDefaultSize,wxLC_REPORT|wxLC_NO_HEADER|wxSUNKEN_BORDER)
		self.family_members_list.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, ''))
		self.member_conditions_list = wxListCtrl(self,ID_MEMBERCONDITIONSLIST,  wxDefaultPosition, wxDefaultSize,wxLC_REPORT|wxLC_NO_HEADER|wxSUNKEN_BORDER)
		self.member_conditions_list.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, ''))
		self.sizer_members_conditions = wxBoxSizer(wxHORIZONTAL)
		self.sizer_members_conditions.Add(self.family_members_list,4,wxEXPAND)
		self.sizer_members_conditions.Add(self.member_conditions_list,6, wxEXPAND)
		#----------------------------------------
		# add some dummy data to the Members list
		#-----------------------------------------
		self.family_members_list.InsertColumn(0, "Member")
		self.family_members_list.InsertColumn(1, "null")
		#-------------------------------------------------------------
		#loop through the familymemberdata array and add to the list control
		#note the different syntax for the first column of each row
		#i.e. here > self.family_members_list.InsertItem(x, data[0])!!
		#-------------------------------------------------------------
		items = familymemberdata.items()
		for x in range(len(items)):
			key, data = items[x]
			#gmLog.gmDefLog.Log (gmLog.lData, items[x])
			self.family_members_list.InsertItem(x, data[0])
			self.family_members_list.SetItem(x, 1, data[1])
			self.family_members_list.SetItemData(x, key)
		self.family_members_list.SetColumnWidth(0, wxLIST_AUTOSIZE)
		#-------------------------------------------	  
		# add some dummy data to the conditions list
		#-------------------------------------------
		self.member_conditions_list.InsertColumn(0, "Condition")
		self.member_conditions_list.InsertColumn(1, "null")
		#-------------------------------------------------------------
		#loop through the familymemberdata array and add to the list control
		#note the different syntax for the first column of each row
		#i.e. here > self.family_members_list.InsertItem(x, data[0])!!
		#-------------------------------------------------------------
		items = membersconditionsdata.items()
		for x in range(len(items)):
			key, data = items[x]
			#gmLog.gmDefLog.Log (gmLog.lData, items[x])
			self.member_conditions_list.InsertItem(x, data[0])
			self.member_conditions_list.SetItem(x, 1, data[1])
			self.member_conditions_list.SetItemData(x, key)

		self.member_conditions_list.SetColumnWidth(0, wxLIST_AUTOSIZE)
		self.member_conditions_list.SetColumnWidth(1, wxLIST_AUTOSIZE)
		#------------------------------------------------------------------------------------------
		#add a richtext control or a wxTextCtrl multiline to allow user to enter the social history
		#------------------------------------------------------------------------------------------
		self.social_history_subheading = gmGuiElement_DividerCaptionPanel.DividerCaptionPanel(self,-1,"Social History")
		self.txt_social_history = wxTextCtrl(self, 30,
					"Born in QLD, son of an itinerant drover. Mother worked as a bush nurse. "
					"Two brothers, Fred and Peter. Left school aged 15yrs, apprentice fitter "
					"then worked in industry for 10ys. At 22yrs age married Joan, two children"
					"Peter b1980 and Rachaelb1981. Retired in 1990 due to receiving a fortune.",
					wxDefaultPosition,wxDefaultSize, style=wxTE_MULTILINE|wxNO_3D|wxSIMPLE_BORDER)
		self.txt_social_history.SetInsertionPoint(0)
		self.txt_social_history.SetFont(wxFont(12,wxSWISS, wxNORMAL, wxNORMAL, False, ''))		
		#----------------------------------------
		#add an alert caption panel to the bottom
		#----------------------------------------
		self.alertpanel = gmGuiElement_AlertCaptionPanel.AlertCaptionPanel(self,-1,"  Alerts  ")
		#---------------------------------------------
		#add all elements to the main background sizer
		#---------------------------------------------
		self.mainsizer = wxBoxSizer(wxVERTICAL)
		self.mainsizer.Add(self.FamilyHistoryPanelheading,0,wxEXPAND)
#		self.mainsizer.Add(self.dummypanel1,1,wxEXPAND)
		self.mainsizer.Add(self.editarea,6,wxEXPAND)
		self.mainsizer.Add(self.sizer_divider_members_condition,0,wxEXPAND)
		self.mainsizer.Add(self.sizer_members_conditions,4,wxEXPAND)
		self.mainsizer.Add(self.social_history_subheading,0,wxEXPAND)
		self.mainsizer.Add(self.txt_social_history,4,wxEXPAND)
		self.mainsizer.Add(self.alertpanel,0,wxEXPAND)
		self.SetSizer(self.mainsizer)
		self.mainsizer.Fit (self)
		self.SetAutoLayout(True)
		EVT_SIZE (self, self.OnSize)

	def OnSize (self, event):
		w, h = event.GetSize ()
		self.mainsizer.SetDimension (0, 0, w, h)
#----------------------------------------------------------------------
class gmGP_FamilyHistory(gmPlugin_Patient.wxPatientPlugin):
	"""Plugin to encapsulate the family history window."""

	__icons = {
"""icon_two_people""": 'x\xda\x9d\x90\xb1\x0e\x83 \x10\x86w\x9f\xe2\x12@\x9b\x98\x10X\xaa#\x81\xc4\
\xb1\x0c.\xae\xc6t\xaa)}\xff\xa9w\x07\xd8\xb4n\x05\xf5\xf2}w?$^\xf6\x97m\xe6\
\xce^\x81\x1e\x0b\xb6k\xd6\xb9\x93\xb0\x81\xdf\xd7\xed\xc1\xd4"\x89a\x1c\x82\
1\xcc\x82x\x1a\x8d\x99F\xe6\x85\xd8\xe0\n\xb9\x1f+\x97\xbe\xcey2\xcc)\xe7C\
\xed\x03\xf2-=\xef\x0c.\x87\xa7P\x9a\xaa^V\xc2=\xb1\x1f}\xf05\xfc\xbd\x8a\
\xd4Z3\xe6\x9a\xa5^p\x93[\x12\xd52\x99R\xe2A\xac\x1f\t\xa9\x1c\x97\x8e3c\x8c\
=\xbe\xe0\x9c\x13\xc2\xb9C\xba\x08(A:\tU\x82\x94\x92%H\xa8R\xb0\x14\xb8\x95R\
\xf8-\x17I\x1a\x01rh\x7f$\'N\xb2\xc5}\xc8\x0c\x7f\xcb\xd3\xaf\xd3o\x85>c\\'
}

	def name (self):
		return 'Family History Window'

	#FIXME - put ampersand in correct position
	def MenuInfo (self):
		return ('view', '&Family History')

	def GetIconData(self, anIconID = None):
		if anIconID == None:
			return self.__icons[_("""icon_two_people""")]
		else:
			if anIconID in self.__icons:
				return self.__icons[anIconID]
			else:
				return self.__icons[_("""icon_two_people""")]

	def GetWidget (self, parent):
		return FamilyHistoryPanel (parent, -1)
#======================================================================
# main
#----------------------------------------------------------------------
if __name__ == "__main__":
	app = wxPyWidgetTester(size = (600, 600))
	app.SetWidget(FamilyHistoryPanel, -1)
	app.MainLoop()

#======================================================================# 
