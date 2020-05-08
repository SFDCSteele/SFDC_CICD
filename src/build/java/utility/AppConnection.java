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
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONTokener;
import org.json.JSONException;


public class AppConnection {

    List<String> LOGIN_VARS = new ArrayList<String>();
    List<String> LOGIN_VALS = new ArrayList<String>();
    List<String> BUILDSTATUS_VARS = new ArrayList<String>();
    List<String> BUILDSTATUS_MSG  = new ArrayList<String>();
    List<String> BUILDSTATUS_VALS = new ArrayList<String>();

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
    private String API_VERSION = "/v47.0";
    private String baseUri;
    private Header oauthHeader;
    private Header prettyPrintHeader = new BasicHeader("X-PrettyPrint", "1");
    private final boolean DEBUG_ON = true;//false;//


    private HttpPost httpPost = new HttpPost();
    private HttpGet httpGet = new HttpGet();
    private String connectionName = "";

    public AppConnection() {

    }

    /*
    web page:
    https://dzone.com/articles/how-to-build-a-basic-salesforce-rest-api-integrati-1
    
    send data:
    curl https://INSTANCE.salesforce.com/services/data/v42.0/sobjects/Contact -H "Authorization: Bearer YOUR_ACCESS_TOKEN" -H "Content-Type: application/json" -d '{"FirstName" : "Johnny", "LastName" : "Appleseed"}'

    query data:
    curl https://INstance.salesforce.com/services/data/v42.0/query/?q=SELECT+id,name,email,phone+from+Contact -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'

    */
    public void createPostConnection(String connName, List<String> passedLoginVals) {

        //AppConnection con = new AppConnection();
        connectionName = connName; 
        LOGIN_VALS = passedLoginVals;

        System.out.println("==========================================\nAppConnection.createPostConnection version: " + RUN_VERSION +
                " connection: " + connectionName + "\n==========================================");
        HttpClient httpclient = HttpClientBuilder.create().build();
        
        // Assemble the login request URL
        String loginURL = LOGIN_VALS.get(LOGINURL_LOC) +
                          LOGIN_VALS.get(GRANTSERVICE_LOC) +
                          "&client_id=" + LOGIN_VALS.get(CLIENTID_LOC) +
                          "&client_secret=" + LOGIN_VALS.get(CLIENTSECRET_LOC) +
                          "&username=" + LOGIN_VALS.get(USERNAME_LOC) +
                          "&password=" + LOGIN_VALS.get(PASSWORD_LOC);
 
        System.out.println("Login URL: "+loginURL);
        // Login requests must be POSTs
        httpPost = new HttpPost(loginURL);
        HttpResponse response = null;
 
        try {
            // Execute the login POST request
            response = httpclient.execute(httpPost);
        } catch (ClientProtocolException cpException) {
            cpException.printStackTrace();
        } catch (IOException ioException) {
            ioException.printStackTrace();
        }
 
        // verify response is HTTP OK
        final int statusCode = response.getStatusLine().getStatusCode();
        if (statusCode != HttpStatus.SC_OK) {
            System.out.println("Error authenticating to Force.com: "+statusCode);
            // Error is in EntityUtils.toString(response.getEntity())
            return;
        }
 
        String getResult = null;
        try {
            getResult = EntityUtils.toString(response.getEntity());
        } catch (IOException ioException) {
            ioException.printStackTrace();
        }
 
        JSONObject jsonObject = null;
        String loginAccessToken = null;
        String loginInstanceUrl = null;
 
        try {
            jsonObject = (JSONObject) new JSONTokener(getResult).nextValue();
            loginAccessToken = jsonObject.getString("access_token");
            loginInstanceUrl = jsonObject.getString("instance_url");
        } catch (JSONException jsonException) {
            jsonException.printStackTrace();
        }
 
        baseUri = loginInstanceUrl;// + REST_ENDPOINT + API_VERSION ;
        oauthHeader = new BasicHeader("Authorization", "OAuth " + loginAccessToken) ;
        if (DEBUG_ON) System.out.println("oauthHeader1: " + oauthHeader);
        if (DEBUG_ON) System.out.println("\n" + response.getStatusLine());
        if (DEBUG_ON) System.out.println("Successful login");
        if (DEBUG_ON) System.out.println("instance URL: "+loginInstanceUrl);
        if (DEBUG_ON) System.out.println("access token/session ID: "+loginAccessToken);
        if (DEBUG_ON) System.out.println("baseUri: "+ baseUri);        
 
    }

    public void releasePostConnection () {

        // release connection
        System.out.println("Releasing connection: "+connectionName);
        httpPost.releaseConnection();

    }

    public void releaseGetConnection () {

        // release connection
        System.out.println("Releasing connection: "+connectionName);
        httpGet.releaseConnection();

    }

    public String getBaseURI () {
        return baseUri;
    }

    public Header getOauthHeader() {
        return oauthHeader;
    }


    // Query environment data using REST HttpGet
    public void createGetConnection(String connName, List<String> passedLoginVals) {

        connectionName = connName; 
        LOGIN_VALS = passedLoginVals;

        System.out.println("==========================================\nAppConnection.createGetConnection version: " + RUN_VERSION +
                " connection: " + connectionName + "\n==========================================x");
        HttpClient httpclient = HttpClientBuilder.create().build();
        HttpClient httpClient = HttpClientBuilder.create().build();

        // Assemble the login request URL
        String loginURL = LOGIN_VALS.get(LOGINURL_LOC) +
                          LOGIN_VALS.get(GRANTSERVICE_LOC) +
                          "&client_id=" + LOGIN_VALS.get(CLIENTID_LOC) +
                          "&client_secret=" + LOGIN_VALS.get(CLIENTSECRET_LOC) +
                          "&username=" + LOGIN_VALS.get(USERNAME_LOC) +
                          "&password=" + LOGIN_VALS.get(PASSWORD_LOC);

        System.out.println("Login URL: "+loginURL);
 
        // Login requests must be POSTs
        HttpPost httpPost = new HttpPost(loginURL);
        HttpResponse response = null;
 
        try {
            // Execute the login POST request
            response = httpclient.execute(httpPost);
        } catch (ClientProtocolException cpException) {
            cpException.printStackTrace();
        } catch (IOException ioException) {
            ioException.printStackTrace();
        }
 
        // verify response is HTTP OK
        final int statusCode = response.getStatusLine().getStatusCode();
        if (statusCode != HttpStatus.SC_OK) {
            System.out.println("Error authenticating to Force.com: "+statusCode);
            // Error is in EntityUtils.toString(response.getEntity())
            return;
        }
 
        String getResult = null;
        try {
            getResult = EntityUtils.toString(response.getEntity());
        } catch (IOException ioException) {
            ioException.printStackTrace();
        }
 
        JSONObject jsonObject = null;
        String loginAccessToken = null;
        String loginInstanceUrl = null;
 
        try {
            jsonObject = (JSONObject) new JSONTokener(getResult).nextValue();
            loginAccessToken = jsonObject.getString("access_token");
            loginInstanceUrl = jsonObject.getString("instance_url");
        } catch (JSONException jsonException) {
            jsonException.printStackTrace();
        }
 
        baseUri = loginInstanceUrl + REST_ENDPOINT;// + API_VERSION ;
        oauthHeader = new BasicHeader("Authorization", "OAuth " + loginAccessToken) ;
        if (DEBUG_ON) System.out.println("oauthHeader1: " + oauthHeader);
        if (DEBUG_ON) System.out.println("\n" + response.getStatusLine());
        if (DEBUG_ON) System.out.println("Successful login");
        if (DEBUG_ON) System.out.println("instance URL: "+loginInstanceUrl);
        if (DEBUG_ON) System.out.println("access token/session ID: "+loginAccessToken);
        if (DEBUG_ON) System.out.println("baseUri: "+ baseUri);        
        /*
        try {
 
            //Set up the HTTP objects needed to make the request.
            HttpClient httpClient = HttpClientBuilder.create().build();
 
            String uri = baseUri + "/getEnvironmentDetails?envName="+envName;
            if (DEBUG_ON) System.out.println("100-getEnvironmentDetails URL: " + uri);
            httpGet = new HttpGet(uri);
            if (DEBUG_ON) System.out.println("oauthHeader2: " + oauthHeader);
            httpGet.addHeader(oauthHeader);
            httpGet.addHeader(prettyPrintHeader);
 
            // Make the request.
            HttpResponse response = httpClient.execute(httpGet);
 
            // Process the result
            int statusCode = response.getStatusLine().getStatusCode();
            if ( DEBUG_ON ) System.out.println("101-getEnvironmentDetails statusCode: " + statusCode+" response: "+response);
            if (statusCode == 200) {
                try {
                    String response_string = EntityUtils.toString(response.getEntity());
                    if ( DEBUG_ON ) System.out.println("103.1-getEnvironmentDetails response_string: " + response_string);
                    String escapedString = StringEscapeUtils.unescapeJava(response_string.substring(response_string.indexOf('{'),response_string.length()-1));
                    JSONObject obj = new JSONObject(escapedString);

                    BufferedWriter writer = new BufferedWriter(new FileWriter("setSystem"));
                    for (int i=0;i<BUILDSTATUS_VARS.size();i++ ) {
                        if ( DEBUG_ON ) System.out.print(""+i+"-export "+BUILDSTATUS_VARS.get(i)+"="+obj.getString(envVars.get(i))+"\n");
                        if ( i==3) { //make sure this lines up to the message attribute
                            writer.write("export "+BUILDSTATUS_VARS.get(i)+"="+obj.getString(envVars.get(i))+obj.getString(envVars.get(i+1))+"\n");
                        } else if ( i==4) { //dont do anything
                        } else {
                            writer.write("export "+BUILDSTATUS_VARS.get(i)+"="+obj.getString(envVars.get(i))+"\n");
                        }
                    }
                    writer.close();
                } catch (JSONException je) {
                    je.printStackTrace();
               }
            } else {
                System.exit(-1);
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } catch (NullPointerException npe) {
            npe.printStackTrace();
        }
        */
    }

}
