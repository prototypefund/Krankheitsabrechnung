/*
 * HealthSummaryQuickAndDirty01.java
 *
 * Created on September 18, 2004, 1:07 PM
 */

package org.gnumed.testweb1.data;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.logging.Logger;

import org.apache.commons.beanutils.BasicDynaBean;
import org.apache.commons.beanutils.BasicDynaClass;
import org.apache.commons.beanutils.DynaBean;
import org.apache.commons.beanutils.DynaProperty;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.beanutils.ResultSetDynaClass;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.gnumed.testweb1.persist.scripted.gnumed.MedicationReadScript;
import org.gnumed.testweb1.persist.scripted.gnumed.medication.MedicationReadScriptV02;


/**
 * 
 * @author sjtan
 */
public class HealthSummaryQuickAndDirty01 implements HealthSummary01 {
    static Log log = LogFactory.getLog(HealthSummaryQuickAndDirty01.class);

    MedicationReadScript medReadScript 
    					= new MedicationReadScriptV02();

    Long identityId;

    List healthIssues, episodeDynaBeans, episodes, encounters, vaccinations,
            medications, allergys, narratives, lab_requests, test_results,
            referrals;

    Map   encounterMap, vaccines;

    DataObjectFactory dof;

    List encounterTypes;

    private TreeMap episodeMap;

    private TreeMap narrativeMap;

    private List narrativeDynaBeans;

    private HashMap healthIssueMap;

    /** Creates a new instance of HealthSummaryQuickAndDirty01 */
    public HealthSummaryQuickAndDirty01(DataObjectFactory dof, Long patientId,
            Map vaccines, ResultSet healthIssuesRS, ResultSet episodesRS,
            ResultSet encountersRS, ResultSet vaccinationsRS,
            ResultSet medicationsRS, ResultSet allergyRS,
            ResultSet narrativeRS, ResultSet lab_requestRS,
            ResultSet test_resultRS, ResultSet referralRS,
            ResultSet encounterTypeRS) {
        this.dof = dof;
        identityId = patientId;
        try {

            allergys = getListOfDynaBeansFromResultSet(allergyRS);

            healthIssues = getListOfDynaBeansFromResultSet(healthIssuesRS);

            episodeDynaBeans = getListOfDynaBeansFromResultSet(episodesRS);
            if (medReadScript == null) {
                medications = getListOfDynaBeansFromResultSet(medicationsRS);
            }
            medications = getMedicationFromResultSet(medicationsRS);
            //medications = new ArrayList();
            narrativeDynaBeans = getListOfDynaBeansFromResultSet(narrativeRS);

            lab_requests = getListOfDynaBeansFromResultSet(lab_requestRS);

            test_results = getListOfDynaBeansFromResultSet(test_resultRS);

            referrals = getListOfDynaBeansFromResultSet(referralRS);

            vaccinations = getVaccinations(vaccinationsRS, vaccines);

            encounters = getListOfDynaBeansFromResultSet(encountersRS);

            encounterTypes = getListOfDynaBeansFromResultSet(encounterTypeRS);

            constructHealthIssues();
            mapHealthIssues();

            constructEncounters();

            mapEncounters();

            constructEpisodes();
            mapEpisodes();
            linkEpisodesToHealthIssues();

            constructNarratives();
            mapNarratives();
            linkNarrativesToEpisodes();
            linkNarrativesToEncounters();

            debugNarratives();
            sortEncounterRootItems();
            log.info("AFTER SORT");
            debugNarratives();

            this.vaccines = mapByTradeName(vaccines);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * 
     */
    private void linkNarrativesToEncounters() {
        Iterator i = narrativeDynaBeans.iterator();
        while (i.hasNext()) {
            DynaBean beanNarrative = (DynaBean)i.next();
            Long id = getIdField(beanNarrative, "pk");
            ClinNarrative narrative = (ClinNarrative) narrativeMap
                .get( id) ;
            Long fk_encounter = getIdField(beanNarrative,"fk_encounter");
            ClinicalEncounter encounter  = (ClinicalEncounter)encounterMap.get(fk_encounter);
             
            log.info("** Looking for encounter "+fk_encounter + " found encounter "
                   + ((encounter != null) ? encounter.toString(): " none") );
                    
           
            narrative.setEncounter(encounter);
        }
         
        
    }

    /**
     * 
     */
    private void mapNarratives() {
        // TODO Auto-generated method stub
        Iterator i = narratives.iterator();
        narrativeMap = new TreeMap();
        while (i.hasNext()) {
            ClinNarrative n = (ClinNarrative)i.next();
            narrativeMap.put(n.getId(), n);
        }
    }

    /**
     * 
     */
    private void linkNarrativesToEpisodes() {
        // TODO Auto-generated method stub
       Iterator i = narrativeDynaBeans.iterator();
       while (i.hasNext()) {
           DynaBean beanNarrative = (DynaBean)i.next();
           Long id = getIdField(beanNarrative, "pk");
           ClinNarrative narrative = (ClinNarrative) narrativeMap
               .get( id) ;
           Long fk_episode = getIdField(beanNarrative,"fk_episode");
           ClinicalEpisode episode = (ClinicalEpisode)episodeMap.get(fk_episode);
           
           log.info("Looking for fk_episode=" + fk_episode + " found " + episode);
           narrative.setEpisode(episode);
           log.info("For "+episode+" episode.getRootItemCount()="+episode.getRootItemCount());
       }
        
    }

    /**
     *  
     */
    private void linkEpisodesToHealthIssues() {
        HealthIssue nullHealthIssue = dof.createHealthIssue();
        nullHealthIssue.setDescription("Unlinked episodes");
        
        Iterator i = episodeDynaBeans.iterator();
        while (i.hasNext()) {
            DynaBean b = (DynaBean) i.next();
            DynaProperty[] dynaProperties;
            ArrayList names;
            log.info("episode dynabean is " + getDynaProperties(b));
            //  Long id = new Long(((Integer) b.get("pk")).longValue());
            
            Long id = getIdField(b, "pk");
            
            Long fk_health_issue = getIdField(b, "fk_health_issue");
            
            
            HealthIssue issue = (HealthIssue) healthIssueMap.get(fk_health_issue);
            ClinicalEpisode episode = (ClinicalEpisode) episodeMap.get(id);
            
            if (episode == null) {
                log.info("*** dynabean " + b + " with id " + id + " exists "+
                "not found in keys of " + episodeMap.keySet().toString());
                
            } else {
                if (issue != null) {
                    log.info("*** Found "+episode  + " with id" + id +
                    " setting with issue " +issue +
                    " :description= " +
                    (issue != null? issue.getDescription() : "no description"));
                    episode.setHealthIssue(issue);
                    
                } else {
                    log.info("no health issue for for episode" + episode.getId());
                    episode.setHealthIssue(nullHealthIssue);
                    
                }
            }
            log.info(issue+ " "+issue.getDescription() + " has " + (issue.getClinicalEpisodes()!=null? issue.getClinicalEpisodes().length : 0) + " episodes.");
        }
    }

    /**
     * @param b
     */
    private String  getDynaProperties(DynaBean b) {
        DynaProperty[] dynaProperties = b.getDynaClass().getDynaProperties();
        ArrayList names=new ArrayList();
        for(int j = 0; j < dynaProperties.length; ++j) {
            
            names.add(dynaProperties[j].getName());
        }
        StringBuffer sb = new StringBuffer();
        
        String[] ss =  (String[]) names.toArray(new String[1]);
        for (int i = 0; i < ss.length;++i) {
            sb.append(ss[i]).append(" ");
        }
        return sb.toString();
    }

    /**
     * @param b
     * @param field
     * @return
     */
    private Long getIdField(DynaBean b, String field) {
        Long id = null;
        try {    
            id = new Long(((Integer) b.get(field)).longValue());
            
        } catch(NullPointerException e) {
            log.info("caught " + e );
            id = new Long(0);
        }
        return id;
    }

    /**
     *  
     */
    private void mapEpisodes() {
        Iterator i = episodes.iterator();
        episodeMap = new TreeMap();
        while (i.hasNext()) {
            ClinicalEpisode episode = (ClinicalEpisode) i.next();
            episodeMap.put(episode.getId(), episode);
            log.info( "episodeMap[" + episode.getId() + "] has an episode with episode ");
            log.info(" id = " +
                    episodeMap.get(episode.getId()) + " = "+
                    ((ClinicalEpisode)episodeMap.get(episode.getId())).getId() );
            
        }
    }

    /**
     *  
     */
    private void mapEncounters() {
        // TODO Auto-generated method stub
        encounterMap = new HashMap();
        Iterator i = encounters.iterator();
        while (i.hasNext()) {
            ClinicalEncounter encounter = (ClinicalEncounter) i.next();
            encounterMap.put(encounter.getId(), encounter);
            log.info("MAPPED encounter "+encounter.getId() );
        }
    }

    /**
     *  
     */
    private void mapHealthIssues() {
        Iterator j = healthIssues.iterator();

        healthIssueMap = new HashMap();
        while (j.hasNext()) {
            HealthIssue hi = (HealthIssue) j.next();

            healthIssueMap.put(hi.getId(), hi);
        }
    }

    private void debugNarratives() {
        Iterator i = narratives.iterator();
        while (i.hasNext()) {
            ClinNarrative n = (ClinNarrative) i.next();
            log.info("DEBUG NARRATIVE:" + n.getNarrative());
        }
    }

    /**
     * @param medicationsRS
     * @return
     * @throws SQLException
     */
    private List getMedicationFromResultSet(ResultSet medicationsRS)
            throws SQLException {
        List l = new ArrayList();
        while (medicationsRS.next()) {
            l.add(getMedication(medicationsRS));
        }
        return l;
    }

    Medication getMedication(ResultSet row) throws SQLException {
        return medReadScript.read(row);
    }

    /**
     * @param vaccines2
     * @return
     */
    private Map mapByTradeName(Map vaccines2) {
        // TODO Auto-generated method stub
        Map m = new HashMap();
        Iterator i = (Iterator) vaccines2.values().iterator();
        while (i.hasNext()) {
            Vaccine v = (Vaccine) i.next();
            m.put(v.getTradeName(), v);
        }

        return m;
    }

    void sortEncounterRootItems() {
        Iterator i = encounters.iterator();
        while (i.hasNext()) {
            ClinicalEncounter ce = (ClinicalEncounter) i.next();
            ce
                    .sortRootItems(new HealthSummaryQuickAndDirty01.RootItemClinWhenComparator());

        }
    }

    void constructHealthIssues() {
        Iterator j = healthIssues.iterator();
        List newIssues = new ArrayList();

        while (j.hasNext()) {
            DynaBean b = (DynaBean) j.next();
            HealthIssue hi = dof.createHealthIssue();
            hi.setDescription((String) b.get("description"));
            hi.setId(getIdField(b, "id"));
            newIssues.add(hi);

        }
        healthIssues = newIssues;
    }

    void constructEpisodes() {
        HealthIssue nullHealthIssue = dof.createHealthIssue();
        nullHealthIssue.setDescription("Unlinked episodes");

        Iterator i = episodeDynaBeans.iterator();
        List newEpisodes = new ArrayList();
        episodeMap = new TreeMap();
        while (i.hasNext()) {
            DynaBean b = (DynaBean) i.next();
            
            ClinicalEpisode ep = dof.createClinicalEpisode();
            //     version 0.1
            //            ep.setDescription((String)b.get("description"));

            ep.setId(new Long(((Integer) b.get("pk")).longValue()));

            ep.setModified_when(new java.util.Date(
                    (long) ((java.sql.Timestamp) b.get("modified_when"))
                            .getTime()));
            log.info("SET episode " + ep + " with id="+ep.getId() +
                    " from bean "+b+ " with pk=" + b.get("pk"));
            newEpisodes.add(ep);

            Number n = (Number) b.get("fk_health_issue");
            //              
            //            HealthIssue hi = (n != null ) ? (HealthIssue) mapHI.get(new
            // Long(n.longValue())): null;
            //            if (hi == null) {
            //                hi = nullHealthIssue;
            //            }
            //                ep.setHealthIssue(hi);
            //                
            //                log.info("hi has clinicalEpisodes" + hi.getClinicalEpisodes());
            //                
            //                hi.setClinicalEpisode(hi.getClinicalEpisodes().length,ep); //add
            //            
            //            newEpisodes.add(ep);
            //            mapEpisodes.put(ep.getId(), ep);
        }
        episodes = newEpisodes;

    }

    void constructEncounters() {

        List newList = new ArrayList();
        for (int i = 0; i < encounters.size(); ++i) {

            DynaBean b = (DynaBean) encounters.get(i);
            ClinicalEncounter encounter = dof.createClinicalEncounter();
            try {
                encounter.setId(new Long(((Number) b.get("id")).longValue()));
                encounter.setDescription((String) b.get("description"));
                encounter.setStarted((java.util.Date) b.get("started"));
                encounter.setLastAffirmed((java.util.Date) b
                        .get("last_affirmed"));

                newList.add(encounter);
            } catch (Exception e) {
                e.printStackTrace();
                log.error(e);
            }
        }

        Collections.sort(newList,
                new HealthSummaryQuickAndDirty01.EncounterStartedComparator());
        encounters = newList;
    }

    void constructNarratives() {
        java.util.List newNarratives = new ArrayList();
        Iterator j = narrativeDynaBeans.iterator();
        int i2 = 0;
        while (j.hasNext()) {
            DynaBean nb = (DynaBean) j.next();

            ClinNarrative narrative = dof.createEntryClinNarrative();

            try {
                narrative.setAoe(((Boolean) nb.get("is_aoe")).booleanValue());
                narrative.setRfe(((Boolean) nb.get("is_rfe")).booleanValue());
                setCommonRootItemAttributes(narrative, nb);
                newNarratives.add(narrative);
               
            } catch (Exception e) {
                e.printStackTrace();
                log.info(" Failed to process narrative", e);
            }

        }

        narratives = newNarratives;

    }

    void setCommonRootItemAttributes(ClinRootItem rootItem, DynaBean nb) {
        rootItem.setNarrative((String) nb.get("narrative"));
        rootItem.setId(new Long(((Integer) nb.get("pk")).longValue()));
        rootItem.setSoapCat(((String) nb.get("soap_cat")));
        rootItem.setClin_when((java.util.Date) nb.get("clin_when"));
    }

    void linkRootItem(ClinRootItem rootItem, DynaBean dynaRootItem, int index,
            String childName) throws NoSuchMethodException,
            IllegalAccessException, java.lang.reflect.InvocationTargetException {
        Long id_e = getIdField( dynaRootItem,"fk_encounter");
               
        Long id_episode = getIdField( dynaRootItem,"fk_episode");

        rootItem.setEncounter((ClinicalEncounter) encounterMap.get(id_e));
        rootItem.setEpisode((ClinicalEpisode) episodeMap.get(id_episode));
        // set the clinical encounter object to contain the specific type of
        // root item
        PropertyUtils.setIndexedProperty(rootItem.getEncounter(), childName,
                index, rootItem);

    }

    class RootItemClinWhenComparator implements Comparator {

        public int compare(Object obj, Object obj1) {
            ClinRootItem c1, c2;
            c1 = (ClinRootItem) obj;
            c2 = (ClinRootItem) obj1;
            if (c1 == null)
                return -1;
            if (c2 == null)
                return 1;
            
            return(int) (c1.getClin_when().getTime() - c2.getClin_when().getTime());
        }
    }

    class EncounterStartedComparator implements Comparator {

        public int compare(Object obj, Object obj1) {
            ClinicalEncounter ce1, ce2;
            ce1 = (ClinicalEncounter) obj;
            ce2 = (ClinicalEncounter) obj1;
            if (ce1 == null)
                return -1;
            if (ce2 == null)
                return 1;
            return ce1.getStarted().compareTo(ce2.getStarted());
        }

    }

    public List getHealthIssues() {
        return healthIssues;
    }

    private List getHealthIssues(ResultSet rs) throws java.sql.SQLException {
        List l = new ArrayList();
        while (rs.next()) {
            HealthIssue issue = dof.createHealthIssue();
            issue.setId(new Long((long) rs.getInt("id")));
            issue.setDescription(rs.getString("description"));
            l.add(issue);
        }
        return l;
    }

    private List getVaccinations(ResultSet rs, Map vaccines)
            throws java.sql.SQLException {
        List l = new ArrayList();
        while (rs.next()) {
            Vaccination vaccination = dof.createVaccination(new Long(rs
                    .getInt("pk_item")), new Integer(rs.getInt("fk_vaccine")),
                    rs.getString("site"), rs.getString("batch_no"), rs
                            .getTimestamp("clin_when"), vaccines);
            l.add(vaccination);

        }
        return l;

    }

    /**
     * gets a List of Dynabeans from a result set. this is from the example in
     * the Apache documentation
     */
    private List getListOfDynaBeansFromResultSet(ResultSet rs)
            throws IllegalAccessException, java.sql.SQLException,
            InstantiationException,
            java.lang.reflect.InvocationTargetException,
            java.lang.NoSuchMethodException {
        ArrayList results = new ArrayList(); // To hold copied list
        Map map = rs.getStatement().getConnection().getTypeMap();
        HashMap map2 = new HashMap();
        if (map != null)
            map2.putAll(map);
        map2.put("interval", StringBuffer.class);

        rs.getStatement().getConnection().setTypeMap(map2);

        ResultSetDynaClass rsdc = new ResultSetDynaClass(rs);
        DynaProperty properties[] = rsdc.getDynaProperties();
        BasicDynaClass bdc = new BasicDynaClass("foo", BasicDynaBean.class,
                rsdc.getDynaProperties());

        rs.beforeFirst();
        Iterator rows = rsdc.iterator();
        while (rows.hasNext()) {
            DynaBean oldRow = (DynaBean) rows.next();
            System.out.println("got oldRow" + oldRow);
            //      PropertyUtils.setDebug(4);
            DynaBean newRow = bdc.newInstance();
            PropertyUtils.copyProperties(newRow, oldRow);
            results.add(newRow);
        }
        return results;
    }

    /*
     * private void loadAllergies() { allergyRS.beforeFirst(); allergys =
     * getListOfDynaBeansFromResultSet(allergyRS); }
     * 
     * private Allergy loadAllergy() { Allergy a = dof.createAllergy();
     * a.setDefinite(allergyRS.getBoolean("definite"));
     * a.setGenerics(allergyRS.getString("generics"));
     * a.setSubstance(allergyRS.getString("substance"));
     * a.setSoapCat(allergyRS.getString("soap_cat").charAt(0)); return a; }
     * 
     *  
     */
    public List getAllergys() {

        return allergys;
    }

    public Long getIdentityId() {
        return identityId;
    }

    public List getMedications() {

        return medications;
    }

    public List getVaccinations() {

        return vaccinations;
    }

    public List getClinEpisodes() {
        return episodes;
    }

    public List getEncounters() {
      
        return encounters;
    }

    public void setEncounters(List encounters) {
        this.encounters = encounters;
    }

    public boolean hasHealthIssue(HealthIssue issue) {
        Iterator j = healthIssues.iterator();
        while (j.hasNext()) {
            HealthIssue issue2 = (HealthIssue) j.next();
            if (issue2.getId().equals(issue.getId())) {
                return true;
            }
        }
        return false;
    }

    public boolean addHealthIssue(HealthIssue issue) {

        addEpisodes(issue.getClinicalEpisodes());
        healthIssueMap.put(issue.getDescription(), issue);
        return healthIssues.add(issue);

    }

    public void addEpisodes(ClinicalEpisode[] es) {
        for (int i = 0; i < es.length; ++i) {
            getClinEpisodes().add(es[i]);

        }
    }

    public List getEncounterTypes() {
        return encounterTypes;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.gnumed.testweb1.data.HealthSummary01#findVaccine(java.lang.String)
     */
    public Vaccine findVaccine(String tradeName) {
        // TODO Auto-generated method stub

        Vaccine v = (Vaccine) vaccines.get(tradeName);
        log.info(" RETURNING VACCINE=" + v);
        if (v == null) {
            v = findVaccineAsciiSeq(tradeName, vaccines);
        }
        return v;
    }

    /**
     * @param vaccines2
     * @return
     */
    private Vaccine findVaccineAsciiSeq(String name, Map vaccines2) {
        Iterator i = vaccines2.values().iterator();
        while (i.hasNext()) {
            Vaccine v2 = (Vaccine) i.next();
            if (constonantsMatch(name.substring(0, v2.getShortName().length()),
                    v2.getShortName())
                    || constonantsMatch(name, v2.getDescriptiveName())
                    || constonantsMatch(name, v2.getTradeName())) {
                return v2;
            }

        }
        return null;
    }

    /**
     * @param name
     * @param shortName
     * @return
     */
    final static String consonants = "bcdfghjklmnpqrstvwxz";

    static HashSet consonantSet;
    static {

        consonantSet = new HashSet();
        for (int i = 0; i < consonants.length(); ++i) {
            consonantSet.add(new Character(consonants.charAt(i)));

        }
    }

    private boolean constonantsMatch(String name, String shortName) {
        if (name == null || shortName == null || shortName.length() == 0) {
            return false;
        }
        int m = 0;
        for (int i = 0, j = 0; i < name.length(); ++i) {
            if (consonantSet.contains(new Character(name.charAt(i)))) {
                while (j < shortName.length() - 1
                        && !consonantSet.contains(new Character(shortName
                                .charAt(j)))) {
                    ++j;
                }
                if (name.charAt(i) == shortName.charAt(j)) {
                    ++m;
                }
            }
        }
        if (m * 2 >= shortName.length()) {
            return true;
        }

        return false;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.gnumed.testweb1.data.HealthSummary01#setVaccines(org.gnumed.testweb1.data.Vaccine[])
     */
    public void setVaccines(Vaccine[] vaccines) {
        // TODO Auto-generated method stub

    }

    /*
     * (non-Javadoc)
     * 
     * @see org.gnumed.testweb1.data.HealthSummary01#findHealthIssue(java.lang.String)
     */
    public HealthIssue findHealthIssue(String description) {

        // TODO Auto-generated method stub
        return (HealthIssue) healthIssueMap.get(description);
    }

}