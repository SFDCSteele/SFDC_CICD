package utility;


import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.File;
import java.util.*;

import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicHeader;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.HttpStatus;
import org.apache.http.util.EntityUtils;
import org.apache.http.client.ClientProtocolException;
import org.apache.commons.lang.*;
//import org.json.JSONObject;
//import org.json.JSONArray;
import org.json.JSONTokener;
import org.json.JSONException;

import org.json.simple.JSONArray; 
import org.json.simple.JSONObject; 
import org.json.simple.parser.*; 


public class DataUtil {

    List<String> LOGIN_1_VARS = new ArrayList<String>();
    List<String> LOGIN_1_VALS = new ArrayList<String>();
    List<String> LOGIN_2_VARS = new ArrayList<String>();
    List<String> LOGIN_2_VALS = new ArrayList<String>();
    Map<String,String> ENHANCMENT_PAIRS = new HashMap<String, String>();
    List<String> ENHANCEMENT_VARS = new ArrayList<String>();
    List<String> ENHANCEMENT_VALS = new ArrayList<String>();

    private final String RUN_VERSION       = "1.00";
    private final int USERNAME_LOC = 0;
    private final int PASSWORD_LOC = 1;
    private final int LOGINURL_LOC = 2;
    private final int GRANTSERVICE_LOC = 3;
    private final int CLIENTID_LOC = 4;
    private final int CLIENTSECRET_LOC = 5;
    private final String USERNAME = "";
    private final String PASSWORD = "";
    private final String LOGINURL = "";
    private final String GRANTSERVICE = "";
    private final String CLIENTID = "";
    private final String CLIENTSECRET = "";
    private String REST_ENDPOINT = "/services/data/v47.0/query/";
    private String API_VERSION = "/v45.0";
    private String baseUri;
    private Header oauthHeader;
    private Header prettyPrintHeader = new BasicHeader("X-PrettyPrint", "1");
    private final boolean DEBUG_ON = true;//false;//true;//

    private String processFileName = "";
    private String processEnhancement = "";
    private String processModule = "";


    private AppConnection con1 = new AppConnection();
    private AppConnection con2 = new AppConnection();

    public DataUtil () {

        System.out.println("==========================================\nDataUtil version: " + RUN_VERSION +
                " run option: default constructor\n==========================================");

    }

    public DataUtil (String[] args) {

        System.out.println("==========================================\nDataUtil version: " + RUN_VERSION +
                " run option: " + args[0] + "\n==========================================");

    }
    /*
    web page:
    https://dzone.com/articles/how-to-build-a-basic-salesforce-rest-api-integrati-1
    
    send data:
    curl https://INSTANCE.salesforce.com/services/data/v42.0/sobjects/Contact -H "Authorization: Bearer YOUR_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"FirstName" : "Johnny", "LastName" : "Appleseed"}'

    query data:
    curl https://INstance.salesforce.com/services/data/v42.0/query/?q=SELECT+id,name,email,phone+from+Contact -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'

    */

    private void processDataUtility(String[] args) {
        System.out.println("==========================================\nDataUtil **processDataUtility** version: " + RUN_VERSION +
                " run option: " + args[0] + "\n==========================================");

        loadEnvironmentVars("LOGIN","");
    
        if ( args[0].equals("loadDeployedComponents")) {
            REST_ENDPOINT = "/services/apexrest/buildUpdate" ;
        } else if (args[0].equals("submitPackage")) {
            REST_ENDPOINT = "/services/apexrest/packageUpdate" ;    
        } else if (args[0].equals("getEnvironmentDetails")) {
            REST_ENDPOINT = "/services/apexrest/buildUpdate" ;
        } else if (args[0].equals("getSandboxName")) {
            REST_ENDPOINT = "/services/apexrest/getSandbox" ;
        }
        
        con1.createGetConnection("VAPROD",LOGIN_1_VALS);
        con2.createPostConnection("CTALBOTVA",LOGIN_2_VALS);

        if (args[0].equals("executeBuild")) {
            executeBuild(args);
        //} else if (args[0].equals("fullload")) {
        //    loadPackageXMLs(args);
        } else if (args[0].equals("getSandboxName")) {
            retrieveSandoxName(args[1]);
        }
    
        // release connection
        con1.releaseGetConnection();
        con2.releasePostConnection();
        
    }

    public static void main(final String[] args) {
        // TODO Auto-generated method stub

        DataUtil du = new DataUtil();
        du.processDataUtility(args);
        
    }

    private void loadEnvironmentVars(final String opt, String inputParms) {

        if (opt.equals("LOGIN")) {
            LOGIN_1_VARS.add("CICD_1_USERNAME");
            LOGIN_1_VARS.add("CICD_1_PASSWORD");
            LOGIN_1_VARS.add("CICD_1_LOGINURL");
            LOGIN_1_VARS.add("CICD_1_GRANTSERVICE");
            LOGIN_1_VARS.add("CICD_1_CLIENTID");
            LOGIN_1_VARS.add("CICD_1_CLIENTSECRET");
            for (int i=0;i<LOGIN_1_VARS.size();i++ ) {
                LOGIN_1_VALS.add((String)System.getenv(LOGIN_1_VARS.get(i)));
            }
            LOGIN_2_VARS.add("CICD_2_USERNAME");
            LOGIN_2_VARS.add("CICD_2_PASSWORD");
            LOGIN_2_VARS.add("CICD_2_LOGINURL");
            LOGIN_2_VARS.add("CICD_2_GRANTSERVICE");
            LOGIN_2_VARS.add("CICD_2_CLIENTID");
            LOGIN_2_VARS.add("CICD_2_CLIENTSECRET");
            for (int i=0;i<LOGIN_2_VARS.size();i++ ) {
                LOGIN_2_VALS.add((String)System.getenv(LOGIN_2_VARS.get(i)));
            }
        } else if (opt.equals("ENHANCEMENT")) {
            String[] inputParmsArr = inputParms.split("\\,");
            System.out.println("loadEnvironmentVars: input parms: "+inputParms+" # of fields: "+inputParmsArr.length);
            for (int i=0;i<inputParmsArr.length;i++ ) {
                System.out.println("loadEnvironmentVars: loading fields: "+inputParmsArr[i]);
                ENHANCMENT_PAIRS.put(inputParmsArr[i],"empty");
            }

        }

    }

    // Submit package contents using REST HttpPost
    public void executeBuild(final String[] args) {
        System.out.println("\n_______________ package contents _______________");
 
        final String uri = con2.getBaseURI() + "/services/apexrest/dictionaryBuilder/executeBuild";
        List<String> packageXMLs = new List<String>();

        try {
 
            if ( args[1].equals("FULL")) {
                packageXMLs = loadPackageXMLs(args);
            } else {
                packageXMLs.add(loadPackageXML (args[2]));
            }
 
            if (DEBUG_ON) System.out.println("package.xml to be saved(file: "+processFileName+"--enhancemnent: "+processEnhancement+"):\n" + packageXML);
            System.out.println("==========================================\nDataUtil **loadPackageXML** enhancement: " + processEnhancement +
            " values: " + packageXML + "\n==========================================");

 
            
            //Construct the objects needed for the request
            final HttpClient httpClient = HttpClientBuilder.create().build();
 
            if (DEBUG_ON) System.out.println("200-retrieveEnhancement URL: " + uri);
            final HttpPost httpPost = new HttpPost(uri);
            if (DEBUG_ON) System.out.println("POST: oauthHeader2: " + con2.getOauthHeader());
            httpPost.addHeader(con2.getOauthHeader());
            httpPost.addHeader(prettyPrintHeader);
            // The message we are going to post
            final StringEntity body = new StringEntity(packageXML);
            body.setContentType("application/json");
            httpPost.setEntity(body);
 
            //Make the request
            final HttpResponse response = httpClient.execute(httpPost);
 
            //Process the results
            final int statusCode = response.getStatusLine().getStatusCode();
            if (statusCode == 200 || statusCode == 201) {
                final String response_string = EntityUtils.toString(response.getEntity());
                if (DEBUG_ON) System.out.println("New package submission from response: " + response_string);
            } else {
                System.out.println("Insertion unsuccessful. Status code returned is " + statusCode);
            }
            
                
        //} catch (final UnsupportedEncodingException uee) {
        //    uee.printStackTrace();
        } catch (final IOException ioe) {
            ioe.printStackTrace();
        } catch (final NullPointerException npe) {
            npe.printStackTrace();
        }
    }

    private String loadPackageXML (final String packageName) {
        //load the contents of an individual package.xml

        final BufferedReader reader;
        
        List<String> members = new ArrayList<String>();
        boolean nameFound = false;
        boolean memberFound = false;
        boolean firstName = true;
        List<String> existingMembers = new ArrayList<String>();
        final Map<String,List<String>> nameMap = new TreeMap<String,List<String>>();
        String mapName      = "";
        String returnMessage = "{";
        int nameCount = 0;

        try {
            final File inpuFile = new File(packageName);
            final FileReader fileReader = new FileReader(packageName);
            final BufferedReader bufferedReader = new BufferedReader(fileReader);
            final List<String> lines = new ArrayList<String>();
            String line = null;


            processFileName = inpuFile.getName();
            //Package_VAHRS-ENH-000880.xml
            processEnhancement = "";
            boolean nameStarted = false;
            boolean nameEnded   = false;
            for ( int i=0;i<processFileName.length();i++ ) {

                if ( !nameEnded && processFileName.charAt(i) == '.' ) {
                    nameEnded = true;
                }
                if ( nameStarted && !nameEnded ) {
                    processEnhancement += processFileName.charAt(i);
                }
                if ( !nameStarted && processFileName.charAt(i) == '_') {
                    nameStarted = true;
                }

            }

            line = retrieveEnhancement(con1, processEnhancement);
            returnMessage += line + 
            "                \"packageName\" : \""+inpuFile.getName()+"\","+
            "                \"packageTypes\" : [";
            line = "";

            while ((line = bufferedReader.readLine()) != null) {
                //System.out.println("reading line: "+line);
                if ( line.contains("<members>")) {
                    members.add(line.split("<members>")[1].split("</members>")[0]);
                } else if ( line.contains("<name>")) {
                    nameFound   = false;
                    mapName     = line.split("<name>")[1].split("</name>")[0];
                    if ( !firstName ) {
                        returnMessage += ",";
                        firstName = false;
                    }
                    if(nameMap.containsKey(mapName)) {
                        nameFound = true;
                        memberFound = false;
                        existingMembers = nameMap.get(mapName);
                        for (int k=0;k<existingMembers.size(); k++ ) {
                            for ( int l=0;l<members.size();l++ ) {
                                if ( existingMembers.get(k) == members.get(l) ) {
                                    memberFound = true;
                                    break;
                                }
                            }
                            if ( !memberFound ) {
                                /*if ( nameMap[j].name == "Flow" && flowExists('getFileContents',nameMap[j].name,existingMembers[k]+".flow") ) {
                                    java.lang.System.out.println("skipping flow member from nameMap: name: "+nameMap[j].name+
                                                " existing member: "+existingMembers[k]);
                                } else {
                                    members.push(existingMembers[k]);
                                }*/
                                members.add(existingMembers.get(k));
                            } else {
                            }
                            memberFound = false;
                        }//for
                        nameMap.put(mapName,members);
                        members = new ArrayList<String>();
                        break;
                    }
                    if ( !nameFound) {
                        nameMap.put(mapName,members);
                        if ((nameCount++) > 0 ) {
                            returnMessage += ",";
                        }
                        returnMessage += 
                        "                    {\"packageType\" : \""+mapName+"\", \"packageMembers\" : [";
                        for ( int i=0;i<members.size();i++ ) {
                            if ( i > 0 ) {
                                returnMessage += ",";
                            }
                            returnMessage += "\""+members.get(i)+"\"";
                        }
                        returnMessage += "] }";
                    }
                    members = new ArrayList<String>();
                }//if
                        
            }//while
            lines.add(line);
            bufferedReader.close();

            //finish building the JSON
            returnMessage += "] }";
    
        } catch (final IOException ioe) {
            System.out.println("Could not Read file: "+ioe.getMessage());
        }
        return returnMessage;
    }

    private List<String> loadPackageXMLs (final String[] args) {
        //load a list of package.xmls in a directory

        final String directory  = args[1];
        final List<String> packageXMLs = new ArrayList<String>();

        final File folder = new File(directory);

        for (final File fileEntry : folder.listFiles()) {
            if (fileEntry.isDirectory()) {
                continue; //listFilesForFolder(fileEntry);
            } else {
                packageXMLs.add(fileEntry.getName());
                if(DEBUG_ON) System.out.println("1-DataUtil: loadPackageXMLs: package.xml: "+fileEntry.getName());
            }
        }
        return packageXMLs;
    }
     
    /*
        SELECT Id, Name, New_Application_Name__c, RecordType.Name, Business_Sponsor_CCB__c, Business_Sponsor__c, Status__c, Release_Date__c, App_Enhancement_Description__c, Contract__c, 
        Integration_Needed__c, Business_Objective__c, Name_of_Dev_Sandbox__c, Is_there_a_change_in_PII_PHI__c, Existing_Application__r.Name,  Existing_Application__r.UI_Format__c, 
        Existing_Application__r.Profile_ID__c, Existing_Application__r.Product_Owner__c, Org__c 
        FROM Application_Request__c    

        query data:
        curl https://INstance.salesforce.com/services/data/v42.0/query/?q=SELECT+id,name,email,phone+from+Contact -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'

    */
    // Query environment data using REST HttpGet
    public String retrieveEnhancement(AppConnection con, final String enhName) {
        System.out.println("\n_______________ Retrieve Enhancement _______________");

        String SOQL_fields = "Id,Name,New_Application_Name__c,RecordType.Name,Business_Sponsor_CCB__c,Business_Sponsor__c,Status__c,Release_Date__c,"+
            "App_Enhancement_Description__c,Contract__c,Integration_Needed__c,Business_Objective__c,Name_of_Dev_Sandbox__c,Is_there_a_change_in_PII_PHI__c,Existing_Application__r.Name,"+
            "Deploy_Branch__c,Deploy_Status__c,Existing_Application__r.Application_Description__c,Existing_Application__r.ContractIntegrator__c,"+
            "Existing_Application__r.Deploy_Merge_Branch__c,Existing_Application__r.Deploy_Symbol__c,"+
            "Existing_Application__r.Go_Live_Date__c,Existing_Application__r.Go_Live_Date_Projected__c,Existing_Application__r.Implementation_Start_Date__c,"+
            "Existing_Application__r.UI_Format__c,Existing_Application__r.CF_Profile__c,Existing_Application__r.Product_Owner__c,Org__c";
        //SOQL_fields = "Id,Name";
        loadEnvironmentVars("ENHANCEMENT",SOQL_fields);
        //https://va.my.salesforce.com/services/data/v47.0/query//v47.0?
        final String uri = con.getBaseURI() + "?q=SELECT+"+SOQL_fields+"+FROM+Application_Request__c+where+Deploy_Branch__c='"+enhName+"'";
        //final String uri = con.getBaseURI() + "?q=SELECT+"+SOQL_fields+"+FROM+Application_Request__c";

        String returnMessage = " \"enhancement\" : [ {";

        //final String uri = baseUri + "/getEnvironmentDetails?envName="+envName;
        if (DEBUG_ON) System.out.println("100-retrieveEnhancement URL: " + uri);

        try {
 
            //Set up the HTTP objects needed to make the request.
            final HttpClient httpClient = HttpClientBuilder.create().build();
 
            final HttpGet httpGet = new HttpGet(uri);
            if (DEBUG_ON) System.out.println("101-GET: oauthHeader2: " + con.getOauthHeader());
            httpGet.addHeader(con.getOauthHeader());
            httpGet.addHeader(prettyPrintHeader);
 
            // Make the request.
            final HttpResponse response = httpClient.execute(httpGet);
 
            // Process the result
            final int statusCode = response.getStatusLine().getStatusCode();
            if ( DEBUG_ON ) System.out.println("101-getEnhancement statusCode: " + statusCode+" response: "+response);
            if (statusCode == 200) {
                try {
                    final String response_string = EntityUtils.toString(response.getEntity());
                    if ( DEBUG_ON ) System.out.println("103.1-getEnhancement response_string: " + response_string);
                    //final String escapedString = StringEscapeUtils.unescapeJava(response_string.substring(response_string.indexOf('{'),response_string.length()-1));
                    //final JSONObject obj = new JSONObject(escapedString);
                    //JSONParser parser = new JSONParser(); 
                    //JSONObject json = (JSONObject) parser.parse(response_string);
                    Object obj = new JSONParser().parse(response_string); 
          
                    // typecasting obj to JSONObject 
                    JSONObject jo = (JSONObject) obj; 
                    if ( DEBUG_ON ) System.out.println("103.2-getEnhancement JSONObject: " + jo);

                    
                    JSONArray ja = (JSONArray) jo.get("records"); 
          
                    // iterating records 
                    Iterator itr2 = ja.iterator(); 
                    String workStr1;
                    String workStr2;
                    int cnt =0;
                      
                    while (itr2.hasNext())  
                    { 
                        Iterator<Map.Entry> itr1 = ((Map) itr2.next()).entrySet().iterator(); 
                        while (itr1.hasNext()) { 
                            Map.Entry pair = itr1.next();
                            workStr1 = (String) pair.getKey(); 
                            if ( workStr1.equals("Existing_Application__r")) {
                                //System.out.println("###found existing app: "+workStr);
                                //JSONArray ja2 = (JSONArray) pair.getValue(); 
                                // getting address 
                                Map existingApplication = ((Map)pair.getValue()); 
                                //System.out.println("existing app: map: "+existingApplication);
                                    
                                // iterating address Map 
                                Iterator<Map.Entry> itr3 = existingApplication.entrySet().iterator(); 
                                while (itr3.hasNext()) { 
                                    Map.Entry pair2 = itr3.next(); 
                                    workStr2 = (String) pair2.getKey(); 
                                    try {
                                        ENHANCMENT_PAIRS.put(workStr1+"."+(String)pair2.getKey(),(String)pair2.getValue());
                                        System.out.println(""+((cnt++)+1)+"------"+pair2.getKey() + " : " + pair2.getValue()); 
                                    } catch (ClassCastException cce) {
                                        System.out.println("1-Cant cast the value for key: "+workStr2+"\nError: "+cce.getMessage());
                                    }
                                } 
                            } else {
                                try {
                                    ENHANCMENT_PAIRS.put((String)pair.getKey(),(String)pair.getValue());
                                    System.out.println(""+((cnt++)+1)+"-"+pair.getKey() + " : " + pair.getValue()); 
                                } catch (ClassCastException cce) {
                                    System.out.println("2-Cant cast the value for key: "+workStr1+"\nError: "+cce.getMessage());
                                }
                            }
                        } 
                    }     
                    // using for-each loop for iteration over Map.entrySet() 
                    cnt = 0;
                    String workString = "";
                    for (Map.Entry<String,String> ENHANCMENT_PAIR : ENHANCMENT_PAIRS.entrySet())  {
                        System.out.println("Key = " + ENHANCMENT_PAIR.getKey() + 
                        ", Value = " + ENHANCMENT_PAIR.getValue()); 
                        if ( ENHANCMENT_PAIR.getValue() != null ) {
                            if ( cnt++ > 0 ) returnMessage += ",";
                            workString = ((String)ENHANCMENT_PAIR.getValue()).replace("\n", " ");
                            workString = workString.replace(":","#");
                            workString = workString.replace("\r"," ");
                            returnMessage += " \""+ENHANCMENT_PAIR.getKey()+"\" : \""+workString+"\" ";
                        }
                    }
                } catch (final ParseException je) {
                    je.printStackTrace();
               }
            } else {
                System.exit(-1);
            }
        } catch (final IOException ioe) {
            ioe.printStackTrace();
        } catch (final NullPointerException npe) {
            npe.printStackTrace();
        }
        return returnMessage+"} ],";
    }

     
    // Query environment data using REST HttpGet
    public void retrieveSandoxName(final String branchName) {
        System.out.println("\n_______________ Retrieve SandboxName _______________");

        final List<String> envVars = Arrays.asList("deployToSIT","sitEnvName");
        loadEnvironmentVars("GETSANDBOX","");
        try {
 
            //Set up the HTTP objects needed to make the request.
            final HttpClient httpClient = HttpClientBuilder.create().build();
 
            final String uri = baseUri + "/getSandoxName?branchName="+branchName;
            if (DEBUG_ON) System.out.println("100-getSandoxName URL: " + uri);
            final HttpGet httpGet = new HttpGet(uri);
            if (DEBUG_ON) System.out.println("oauthHeader2: " + oauthHeader);
            httpGet.addHeader(oauthHeader);
            httpGet.addHeader(prettyPrintHeader);
 
            // Make the request.
            final HttpResponse response = httpClient.execute(httpGet);
 
            // Process the result
            final int statusCode = response.getStatusLine().getStatusCode();
            if ( DEBUG_ON ) System.out.println("101-getSandoxName statusCode: " + statusCode+" response: "+response);
            /*if (statusCode == 200) {
                try {
                    final String response_string = EntityUtils.toString(response.getEntity());
                    if ( DEBUG_ON ) System.out.println("103.1-getSandoxName response_string: " + response_string);
                    final String escapedString = StringEscapeUtils.unescapeJava(response_string.substring(response_string.indexOf('{'),response_string.length()-1));
                    final JSONObject obj = new JSONObject(escapedString);

                    final BufferedWriter writer = new BufferedWriter(new FileWriter("setSystem"));
                    for (int i=0;i<BUILDSTATUS_VARS.size();i++ ) {
                        if ( DEBUG_ON ) System.out.print(""+i+"-export "+BUILDSTATUS_VARS.get(i)+"="+obj.getString(envVars.get(i))+"\n");
                        if ( i>=0) { //make sure this lines up to the message attribute
                            writer.write("export "+BUILDSTATUS_VARS.get(i)+"="+obj.getString(envVars.get(i))+"\n");
                        }
                    }
                    writer.close();
                } catch (final JSONException je) {
                    je.printStackTrace();
               }
            } else {
                System.exit(-1);
            }*/
        } catch (final IOException ioe) {
            ioe.printStackTrace();
        } catch (final NullPointerException npe) {
            npe.printStackTrace();
        }
    }

 
    private String getBody(final InputStream inputStream) {
        String result = "";
        try {
            final BufferedReader in = new BufferedReader(
                    new InputStreamReader(inputStream)
            );
            String inputLine;
            while ( (inputLine = in.readLine() ) != null ) {
                result += inputLine;
                result += "\n";
            }
            in.close();
        } catch (final IOException ioe) {
            ioe.printStackTrace();
        }
        return result;
    }



}
