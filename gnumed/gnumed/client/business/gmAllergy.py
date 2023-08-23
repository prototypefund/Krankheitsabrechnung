# -*- coding: utf-8 -*-
"""GNUmed allergy related business object."""
#============================================================
__author__ = "Carlos Moro <cfmoro1976@yahoo.es>"
__license__ = "GPL v2 or later"

import types, sys, logging, datetime as pyDT


if __name__ == '__main__':
	sys.path.insert(0, '../../')
from Gnumed.pycommon import gmPG2
from Gnumed.pycommon import gmI18N
from Gnumed.pycommon import gmBusinessDBObject
from Gnumed.pycommon import gmDateTime
from Gnumed.pycommon import gmTools


_log = logging.getLogger('gm.domain')
#============================================================
# allergy state related code
#============================================================
allergy_states = [
	None,		# unknown
	0,			# no allergies
	1			# some allergies
]
#------------------------------------------------------------
def ensure_has_allergy_state(encounter=None):

	_log.debug('checking allergy state for identity of encounter [%s]', encounter)

	args = {'enc': encounter}
	cmd_create = """
		INSERT INTO clin.allergy_state (
			fk_encounter,
			has_allergy
		)	SELECT
				%(enc)s,
				NULL
			WHERE NOT EXISTS (
				SELECT 1 FROM clin.v_pat_allergy_state
				WHERE pk_patient = (
					SELECT fk_patient FROM clin.encounter WHERE pk = %(enc)s
				)
			)
	"""
	cmd_search = """
		SELECT pk_allergy_state FROM clin.v_pat_allergy_state
		WHERE pk_patient = (
			SELECT fk_patient FROM clin.encounter WHERE pk = %(enc)s
		)
	"""
	rows, idx = gmPG2.run_rw_queries (
		queries = [
			{'cmd': cmd_create, 'args': args},
			{'cmd': cmd_search, 'args': args}
		],
		return_data = True
	)

	return cAllergyState(aPK_obj = rows[0][0])

#------------------------------------------------------------
class cAllergyState(gmBusinessDBObject.cBusinessDBObject):
	"""Represents the allergy state of one patient."""

	_cmd_fetch_payload = "select * from clin.v_pat_allergy_state where pk_allergy_state = %s"
	_cmds_store_payload = [
		"""update clin.allergy_state set
				last_confirmed = %(last_confirmed)s,
				has_allergy = %(has_allergy)s,
				comment = gm.nullify_empty_string(%(comment)s)
			where
				pk = %(pk_allergy_state)s and
				xmin = %(xmin_allergy_state)s""",
		"""select xmin_allergy_state from clin.v_pat_allergy_state where pk_allergy_state = %(pk_allergy_state)s"""
	]
	_updatable_fields = [
		'last_confirmed',		# special value u'now' will set to datetime.datetime.now() in the local time zone
		'has_allergy',			# verified against allergy_states (see above)
		'comment'				# u'' maps to None / NULL
	]

	#--------------------------------------------------------
	def format_maximum_information(self, patient=None):
		lines = []
		lines.append('%s (%s)' % (
			self.state_string,
			gmDateTime.pydt_strftime(self['last_confirmed'], '%Y %b %d', none_str = '?')
		))
		if self._payload[self._idx['comment']] is not None:
			lines.append(' %s' % self._payload[self._idx['comment']])
		return lines

	#--------------------------------------------------------
	# properties
	#--------------------------------------------------------
	def _get_as_string(self):
		if self._payload[self._idx['has_allergy']] is None:
			return _('unknown allergy state')
		if self._payload[self._idx['has_allergy']] == 0:
			return _('no known allergies')
		if self._payload[self._idx['has_allergy']] == 1:
			return _('*does* have allergies')
		_log.error('unknown allergy state [%s]', self._payload[self._idx['has_allergy']])
		return _('ERROR: unknown allergy state [%s]') % self._payload[self._idx['has_allergy']]

	def _set_string(self, value):
		raise AttributeError('invalid to set allergy state string')

	state_string = property(_get_as_string, _set_string)

	#--------------------------------------------------------
	def _get_as_symbol(self):
		if self._payload[self._idx['has_allergy']] is None:
			if self._payload[self._idx['comment']] is None:
				return '?'
			else:
				return '?!'
		if self._payload[self._idx['has_allergy']] == 0:
			if self._payload[self._idx['comment']] is None:
				return '\u2300'
			else:
				return '\u2300!'
		if self._payload[self._idx['has_allergy']] == 1:
			return '!'
		_log.error('unknown allergy state [%s]', self._payload[self._idx['has_allergy']])
		return _('ERROR: unknown allergy state [%s]') % self._payload[self._idx['has_allergy']]

	state_symbol = property(_get_as_symbol, lambda x:x)

	#--------------------------------------------------------
	def _get_as_amts_latex(self, strict=True):
		table_rows = []
		# Trennzeile als leere Zeile für bessere Lesbarkeit
		table_rows.append('\\multicolumn{11}{l}{}\\tabularnewline')
		# Zwischenüberschrift: 31 Zeichen, $..., 14pt, no frame, \textwidth
		state = '%s (%s)' % (
			self.state_string,
			gmDateTime.pydt_strftime(self['last_confirmed'], '%b %Y', none_str = '?')
		)
		if strict:
			state = state[:31]
		table_rows.append('\\multicolumn{11}{>{\\RaggedRight}p{27.9cm}}{\\rule{0pt}{4.5mm} \\fontsize{14pt}{16pt}\selectfont %s\label{AnchorAllergieDetails}}\\tabularnewline' % gmTools.tex_escape_string(state))
		# Freitextzeile: 200 Zeichen, @..., \textwidth
		if self['comment'] is not None:
			if strict:
				cmt = self['comment'].strip()[:200]
			else:
				cmt = self['comment'].strip()
			table_rows.append('\\multicolumn{11}{>{\\RaggedRight}p{27.9cm}}{%s}\\tabularnewline') % gmTools.tex_escape_string(cmt)
		return table_rows

	as_amts_latex = property(_get_as_amts_latex, lambda x:x)

	#--------------------------------------------------------
	def _get_as_amts_data_v_2_0(self, strict=True):
		lines = []
		# Trennzeile für bessere Lesbarkeit als leere Zwischenüberschrift
		lines.append('$ ')
		# Zwischenüberschrift: 31 Zeichen, $..., \textwidth
		txt = '$%s (%s)' % (
			self.state_string,
			gmDateTime.pydt_strftime(self['last_confirmed'], '%b %Y', none_str = '?')
		)
		if strict:
			lines.append(txt[:32])
		else:
			lines.append(txt)
		# Freitextzeile: 200 Zeichen, @..., \textwidth
		if self['comment'] is not None:
			if strict:
				lines.append('@%s' % self['comment'][:200])
			else:
				lines.append('@%s' % self['comment'])
		return lines

	#--------------------------------------------------------
	def _get_as_amts_data(self, strict=True):
		# Zwischenüberschrift
		state = '%s (%s)' % (self.state_string, gmDateTime.pydt_strftime(self['last_confirmed'], '%b %Y', none_str = '?'))
		if strict:
			state = state[:32]
		# Freitextzeile
		if self['comment'] is None:
			comment = ''
		else:
			comment = '<X t="%s"/>' % self['comment']
			if strict:
				comment = '<X t="%s"/>' % self['comment'][:200]
		return '<S t="%s">%s%%s</S>' % (state, comment)

	as_amts_data = property(_get_as_amts_data, lambda x:x)

	#--------------------------------------------------------
	def __setitem__(self, attribute, value):
		if attribute == 'comment':
			if value is not None:
				if value.strip() == '':
					value = None

		elif attribute == 'last_confirmed':
			if value == 'now':
				value = pyDT.datetime.now(tz = gmDateTime.gmCurrentLocalTimezone)

		elif attribute == 'has_allergy':
			if value not in allergy_states:
				raise ValueError('invalid allergy state [%s]' % value)

		gmBusinessDBObject.cBusinessDBObject.__setitem__(self, attribute, value)

#============================================================
class cAllergy(gmBusinessDBObject.cBusinessDBObject):
	"""Represents one allergy item.

	Actually, those things are really things to "avoid".
	Allergy is just one of several reasons for that.
	See Adrian's post on gm-dev.

	Another word might be Therapeutic Precautions.
	"""
	_cmd_fetch_payload = "SELECT * FROM clin.v_pat_allergies WHERE pk_allergy = %s"
	_cmds_store_payload = [
		"""UPDATE clin.allergy SET
				clin_when = %(date)s,
				substance = %(substance)s,
				substance_code = %(substance_code)s,
				generics = %(generics)s,
				allergene = %(allergene)s,
				atc_code = %(atc_code)s,
				fk_type = %(pk_type)s,
				generic_specific = %(generic_specific)s::boolean,
				definite = %(definite)s::boolean,
				narrative = %(reaction)s
			WHERE
				pk = %(pk_allergy)s AND
				xmin = %(xmin_allergy)s""",
		"""SELECT xmin_allergy FROM clin.v_pat_allergies WHERE pk_allergy=%(pk_allergy)s"""
	]
	_updatable_fields = [
		'date',
		'substance',
		'substance_code',
		'generics',
		'allergene',
		'atc_code',
		'pk_type',
		'generic_specific',
		'definite',
		'reaction'
	]
	#--------------------------------------------------------
	def format_maximum_information(self, patient=None):
		lines = []
		lines.append('%s%s: %s     [#%s]' % (
			self._payload[self._idx['l10n_type']],
			gmTools.bool2subst (
				self._payload[self._idx['definite']],
				' (%s)' % _('definite'),
				' (%s)' % _('indefinite'),
				''
			),
			self._payload[self._idx['descriptor']],
			self._payload[self._idx['pk_allergy']]
		))
		if self._payload[self._idx['reaction']] is not None:
			lines.append(' ' + _('Reaction:') + ' ' + self._payload[self._idx['reaction']])
		if self._payload[self._idx['date']] is not None:
			lines.append(' ' + _('Noted:') + ' ' + gmDateTime.pydt_strftime(self._payload[self._idx['date']], '%Y %b %d'))
		if self._payload[self._idx['allergene']] is not None:
			lines.append(' ' + _('Allergene:') + ' ' + self._payload[self._idx['allergene']])
		if self._payload[self._idx['substance']] is not None:
			lines.append(' ' + _('Substance:') + ' ' + self._payload[self._idx['substance']])
		if self._payload[self._idx['substance_code']] is not None:
			lines.append(' ' + _('Code:') + ' ' + self._payload[self._idx['substance_code']])
		if self._payload[self._idx['atc_code']] is not None:
			lines.append(' ' + _('ATC:') + ' ' + self._payload[self._idx['atc_code']])
		lines.append(' ' + _('Specific to:') + ' ' + gmTools.bool2subst (
			self._payload[self._idx['generic_specific']],
			_('this substance only'),
			_('drug class'),
			_('unknown')
		))
		if self._payload[self._idx['generics']] is not None:
			lines.append(' ' + _('Generics:') + ' ' + self._payload[self._idx['generics']])

		return lines

	#--------------------------------------------------------
	def __setitem__(self, attribute, value):
		if attribute == 'pk_type':
			if value in ['allergy', 'sensitivity']:
				cmd = 'select pk from clin._enum_allergy_type where value=%s'
				rows, idx = gmPG2.run_ro_queries(queries = [{'cmd': cmd, 'args': [value]}])
				value = rows[0][0]

		gmBusinessDBObject.cBusinessDBObject.__setitem__(self, attribute, value)

	#--------------------------------------------------------
	def _get_as_amts_latex(self, strict=True):
		# Freitextzeile: 200 Zeichen, @...
		cells = ['\\multicolumn{1}{>{\\RaggedRight}p{4cm}}{%s}' % gmTools.tex_escape_string(self['descriptor'])]
		txt = '%s%s' % (
			self['l10n_type'],
			gmTools.coalesce(self['reaction'], '', ': %s')
		)
		if strict:
			txt = txt[:(200-len(self['descriptor']))]
		cells.append('\\multicolumn{10}{>{\\RaggedRight}p{23.9cm}}{%s}' % gmTools.tex_escape_string(txt))
		table_row = ' & '.join(cells)
		table_row += '\\tabularnewline'
		return table_row

	as_amts_latex = property(_get_as_amts_latex, lambda x:x)

	#--------------------------------------------------------
	def _get_as_amts_data_v_2_0(self, strict=True):
		# Freitextzeile: 200 Zeichen, @..., \textwidth
		txt = '@%s %s%s' % (
			self['descriptor'],
			self['l10n_type'],
			gmTools.coalesce(self['reaction'], '', ': %s')
		)
		if strict:
			return txt[:200]
		return txt

	#--------------------------------------------------------
	def _get_as_amts_data(self, strict=True):
		txt = '%s %s%s' % (
			self['descriptor'],
			self['l10n_type'],
			gmTools.coalesce(self['reaction'], '', ': %s')
		)
		if strict:
			txt = txt[:200]
		# Freitextzeile: 200 Zeichen
		return '<X t="%s"/>' % txt

	as_amts_data = property(_get_as_amts_data, lambda x:x)

#============================================================
# convenience functions
#------------------------------------------------------------
def create_allergy(allergene=None, allg_type=None, episode_id=None, encounter_id=None):
	"""Creates a new allergy clinical item.

	allergene - allergic substance
	allg_type - allergy or sensitivity, pk or string
	encounter_id - encounter's primary key
	episode_id - episode's primary key
	"""
	cmd = """
		SELECT pk_allergy
		FROM clin.v_pat_allergies
		WHERE
			pk_patient = (SELECT fk_patient FROM clin.encounter WHERE pk = %(enc)s)
				AND
			allergene = %(allergene)s
	"""
	#args = {'enc': encounter_id, 'substance': substance}
	args = {'enc': encounter_id, 'allergene': allergene}
	rows, idx = gmPG2.run_ro_queries(queries = [{'cmd': cmd, 'args': args}])
	if len(rows) > 0:
		# don't implicitely change existing data
		return cAllergy(aPK_obj = rows[0][0])

	# insert new allergy
	queries = []

	if type(allg_type) == int:
		cmd = """
			insert into clin.allergy (fk_type, fk_encounter, fk_episode, allergene, substance)
			values (%s, %s, %s, %s, %s)"""
	else:
		cmd = """
			insert into clin.allergy (fk_type, fk_encounter, fk_episode,  allergene, substance)
			values ((select pk from clin._enum_allergy_type where value = %s), %s, %s, %s, %s)"""
	queries.append({'cmd': cmd, 'args': [allg_type, encounter_id, episode_id, allergene, allergene]})

	cmd = "select currval('clin.allergy_id_seq')"
	queries.append({'cmd': cmd})

	rows, idx = gmPG2.run_rw_queries(queries=queries, return_data=True)
	allergy = cAllergy(aPK_obj = rows[0][0])

	return allergy

#============================================================
# main - unit testing
#------------------------------------------------------------
if __name__ == '__main__':

	allg = cAllergy(aPK_obj=1)
	print(allg)
	fields = allg.get_fields()
	for field in fields:
		print(field, ':', allg[field])
	print("updatable:", allg.get_updatable_fields())
	enc_id = allg['pk_encounter']
	epi_id = allg['pk_episode']
	status, allg = create_allergy (
		allergene = 'test substance',
		allg_type = 1,
		episode_id = epi_id,
		encounter_id = enc_id
	)
	print(allg)
	allg['reaction'] = 'hehehe'
	status, data = allg.save_payload()
	print('status:', status)
	print('data:', data)
	print(allg)
