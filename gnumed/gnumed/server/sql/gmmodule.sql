-- project: GNUMed
-- database: module
-- purpose: module information and implementation 
-- author: hherb
-- copyright: Dr. Horst Herb, horst@hherb.com
-- license: GPL v2 or later (details at http://gnu.org)
-- version: 0.4
-- changelog:
-- 15.5.02:  (ihaywood) first version

-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- =============================================

-- different clients
CREATE TABLE client (
       id SERIAL,
       name text
);


-- modules of the client, including reference source and object code
CREATE TABLE modules (
       id SERIAL,
       client INTEGER REFERENCES client (id),
       filename text NOT NULL,
       modulename text,
       -- name of the module for internal loading, so the file
       -- plugin/Foo.py would be plugin.Foo. Only an issue for 
       -- Python and Java languages.
       version text NOT NULL,
       date DATE DEFAULT now (),
       source TEXT,
       object TEXT
       -- code to be downloaded and executed
       -- NULL here means delete the file
);

-- configuration table for the plugins
CREATE plugin (
       id SERIAL,
       profile CHAR(25) DEFAULT 'default',
       username CHAR(25) DEFAULT CURRENT_USER,
       file INTEGER REFERENCES modules (id),
       loadorder INTEGER NOT NULL, -- set by configuration module, 
				   -- required modules MUST precede
				   -- this module, configs job to check this
       param TEXT -- parameters in the URL format: foo=bar&a=b
);

-- SELECT modules.modulename, plugin.param FROM modules, plugin WHERE modules.id =
--       plugin.file AND username = CURRENT_USER ORDER BY plugin.loadorder
       