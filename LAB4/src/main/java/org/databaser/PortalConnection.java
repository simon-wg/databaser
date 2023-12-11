package org.databaser;

import java.io.IOException;
import java.sql.*; // JDBC stuff.
import java.util.Objects;
import java.util.Properties;

import com.fasterxml.jackson.databind.JsonNode;
import com.github.fge.jackson.JsonLoader;
import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import com.github.fge.jsonschema.main.JsonSchemaFactory;
import com.github.fge.jsonschema.main.JsonValidator;
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
        JSONObject jsonObject = new JSONObject();
        ResultSet rs;

        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT idnr AS student, name, login, program, branch FROM BasicInformation WHERE idnr=?"
            )){
            
            st.setString(1, student);

            rs = st.executeQuery();

            if(rs.next()) {
                jsonObject.put("student", rs.getString("student"));
                jsonObject.put("name", rs.getString("name"));
                jsonObject.put("login", rs.getString("login"));
                jsonObject.put("program", rs.getString("program"));
                jsonObject.put("branch", rs.getString("branch"));
            }
            else{
                return "{\"student\":\"does not exist :(\"}";
            }
        }
        try(PreparedStatement st = conn.prepareStatement(
            "SELECT coursename, course, credits, grade FROM FinishedCourses WHERE student=?"
            )){

            st.setString(1, student);

            rs = st.executeQuery();

            while(rs.next()) {
                JSONObject course = new JSONObject();
                course.put("course", rs.getString("coursename"));
                course.put("code", rs.getString("course"));
                course.put("credits", rs.getFloat("credits"));
                course.put("grade", rs.getString("grade"));
                jsonObject.accumulate("finished", course);
            }
        }
        try(PreparedStatement st = conn.prepareStatement(
            "SELECT Courses.name, Registrations.course, status FROM Registrations LEFT JOIN Courses ON (Courses.code = Registrations.course) WHERE student=?"
            )){

            st.setString(1, student);

            rs = st.executeQuery();

            while(rs.next()) {
                JSONObject course = new JSONObject();
                course.put("course", rs.getString("name"));
                course.put("code", rs.getString("course"));
                course.put("status", rs.getString("status"));
                jsonObject.append("registered", course);
            }
        }
        try (PreparedStatement st = conn.prepareStatement(
                "SELECT seminarcourses, mathcredits, totalcredits, qualified From PathToGraduation WHERE student=?"
            )){

            st.setString(1, student);

            rs = st.executeQuery();

            if (rs.next()) {
                jsonObject.put("seminarCourses", rs.getInt("seminarcourses"));
                jsonObject.put("mathCredits", rs.getFloat("mathcredits"));
                jsonObject.put("totalCredits", rs.getFloat("totalcredits"));
                jsonObject.put("canGraduate", rs.getBoolean("qualified"));
            }
            else {
                jsonObject.put("seminarCourses", 0);
                jsonObject.put("mathCredits", 0);
                jsonObject.put("totalCredits", 0);
                jsonObject.put("canGraduate", false);
            }
        }
        try {
            // Validate the json against the schema
            // If it fails, it will throw a JSONException
            // If it succeeds, it will return the json string

            JsonValidator validator = JsonSchemaFactory.byDefault().getValidator();
            JsonNode schema;
            try {
                schema = JsonLoader.fromPath("src/main/resources/information_schema.json");
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            JsonNode validation;
            try {
                validation = JsonLoader.fromString(jsonObject.toString());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            validator.validate(schema, validation);
        } catch (ProcessingException e) {
            throw new RuntimeException(e);
        }
        return jsonObject.toString();
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