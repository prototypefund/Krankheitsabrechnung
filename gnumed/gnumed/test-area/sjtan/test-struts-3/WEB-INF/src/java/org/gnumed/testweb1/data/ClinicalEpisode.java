/*
 * ClinicalEpisode.java
 *
 * Created on July 6, 2004, 5:45 AM
 */

package org.gnumed.testweb1.data;

import java.util.List;

/**
 * As Per Gnumed Cllnical Schema: 
 * this interpretation: a clinical episode is a problem
 * with a name, which might span several encounters :
 *e.g. laceration, repair, review, ros, review. 
 *     epigastric discomfort, gastroscopy, report, referral,
 *     report, 
 *
 *A clinical episode can be the first of an evolving health issue,
 *and a new health issue can be created from a clinical episode.
 * 
 * @author  sjtan
 */
public interface ClinicalEpisode {
    
    /**
     * Getter for property description.
     * @return Value of property description.
     */
    public String getDescription();
    
    /**
     * Setter for property description.
     * @param description New value of property description.
     */
    public void setDescription(String description);
    
    /**
     * Getter for property id.
     * @return Value of property id.
     */
    public Long getId();
    
    /**
     * Setter for property id.
     * @param id New value of property id.
     */
    public void setId(Long id);
    
    /**
     * Getter for property healthIssue.
     * @return Value of property healthIssue.
     */
    public HealthIssue getHealthIssue();
    
    /**
     * Setter for property healthIssue.
     * @param healthIssue New value of property healthIssue.
     */
    public void setHealthIssue(HealthIssue object);
    
    /**
     * Getter for property modified_when.
     * @return Value of property modified_when.
     */
    public java.util.Date getModified_when();
    
    /**
     * Setter for property modified_when.
     * @param modified_when New value of property modified_when.
     */
    public void setModified_when(java.util.Date modified_when);
    
    /**
     * Indexed getter for property rootItem.
     * @param index Index of the property.
     * @return Value of the property at <CODE>index</CODE>.
     */
    public ClinRootItem getRootItem(int index);
    
    /**
     * Indexed setter for property rootItem.
     * @param index Index of the property.
     * @param rootItem New value of the property at <CODE>index</CODE>.
     */
    public void setRootItem(int index, ClinRootItem rootItem);
    
    public int getRootItemCount();
    
    /**
     * Getter for property rootItems.
     * @return Value of property rootItems.
     */
    public java.util.List getRootItems();
    
    public List getRootItemsByType( Class type );
    
    public ClinRootItem getEarliestRootItem();
    
    public boolean isClosed();
    public void setClosed(boolean closed);
}
