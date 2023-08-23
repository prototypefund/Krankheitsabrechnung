<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib uri="http://struts.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
 <html:base />

<html>
<head><title>Clinical Entry</title>

    <LINK   TYPE="text/css" REL="stylesheet" href="../style.css" title="Style"/>    
 
</head> 
<body>

    <jsp:include page="./topMenu.jsp"/>
    <hr/>
    <jsp:include page="./intraLinksClinicalEdit.jsp"/> 
    
    <table>
    <tr>
    <td>	  
        <input type="button" value='entry'
        onclick='
        var e = document.getElementById("clinicalEntry");
        var p = document.getElementById("pastNotes");
        e.style.display="block";
        p.style.display="block";
        '/>
        |
        <input type="button" value='past notes'
        onclick='
        var e = document.getElementById("clinicalEntry");
        var p = document.getElementById("pastNotes");
        e.style.display="none";
        p.style.display="block";
        '/>        
        |
        <bean:define id="printToken" value="1"/>
        <html:link
            page="/pages/clinicalStatus/printableHistory.jsp"   
            paramId="print"
            paramName="printToken"
            >show printable notes
	    >
            <%-- 
	    	<bean:message key="show.printable.summary.notes"/> 
	    --%>
        </html:link>
        
        <html:link page="/pages/clinicalUpdate/encounterEpisodeBased.jsp">test 2</html:link>
        
    | <b> zoom with ctrl- / ctrl= in mozilla  </b>
        
    </td>
    </tr> 
    </table>
        <hr>
    <table width='100%'>
        <tr >
         <td width='60%'>
            <table >
            <tr >
            <td   > 
               
                <div id="clinicalEntry">
                     <a name="encounterTop"/>
                    <tiles:insert name="leftTop"/>
                </div>  
           
             
                        <div id="pastNotes" style='display:block'>
                            <tiles:insert name="leftBottom"/>
                        </div>
                    </td>
            </tr>
            
            </table>
        </td>

        <td valign='top'> 
            <table>
                <tr  >
                    <td valign='top'>
                        <tiles:insert name="rightTop"/>
                  
                        <tiles:insert name="rightBottom"/>
                    </td>
                </tr>
                
            </table>
        </td>
        
        </tr>
    </table> 
     
      
       
</body>
 
</html>
