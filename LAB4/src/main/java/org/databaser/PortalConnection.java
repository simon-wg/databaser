package org.databaser;

import java.sql.*; // JDBC stuff.
import java.util.Properties;
import org.json.*;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    /*
    static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    static final String USERNAME = "tda357_nnn";
    static final String PASSWORD = "yourPasswordGoesHere";
    */


    // This is the JDBC connection object you will be using in your methods.
    private final Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
        // insert student into course
        try(PreparedStatement st = conn.prepareStatement(
            "INSERT INTO Registrations VALUES (?,?)"
            )){

            st.setString(1, student);
            st.setString(2, courseCode);

            st.executeUpdate();

            return "{\"success\":true}";

        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String course){
        // delete student from course
        try(PreparedStatement st = conn.prepareStatement(
            "DELETE FROM Registrations WHERE student=? AND course=?"
            )){

            st.setString(1, student);
            st.setString(2, course);

            st.executeUpdate();

            return "{\"success\":true}";

        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        // Get the json from the schema in resources, throw an exception if it gets null
        String pathToSchema;
        try {
            pathToSchema = PortalConnection.class.getResource("/information_schema.json").toString();
        }
        catch (NullPointerException e) {
            throw new SQLException("Could not find schema in resources");
        }
        // Remove the "file:" part of the path
        pathToSchema = pathToSchema.substring(5);
        // Read the schema from the file
        String schema;
        try{
            schema = new String(java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(pathToSchema)));
        } catch (Exception e){
            throw new SQLException("Could not read schema from resources");
        }
        JSONObject schemaJson = new JSONObject(schema);

        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
            )){
            
            st.setString(1, student);

            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}