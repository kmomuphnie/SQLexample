import java.sql.*;
import java.util.List;
import java.util.ArrayList;
// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            return true;
        } 
        catch(SQLException e){
            // System.out.println("Connection Failed");
            System.err.println("SQL Exception." + "<Message>: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if(connection != null) {
            try {
                connection.close();
                return true;
            } 
            catch (SQLException se) {
                System.err.println("SQL Exception." + "<Message>:" + se.getMessage());
                return false;
            }
        }
        return false;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        ResultSet rs;
        PreparedStatement stmt;
        String sql;
        //build the report list
        List<Integer> electionId = new ArrayList<Integer>();
        List<Integer> cabinetId = new ArrayList<Integer>();
        ElectionCabinetResult result;

        try{
            sql = "SELECT e.id AS electionId, cabinet.id AS cabinetId " +
                  "FROM country, election e, cabinet " + "WHERE country.name = ? AND " + 
                  "e.country_id = country.id AND cabinet.country_id = country.id AND " +
                  "cabinet.election_id = e.id " + "ORDER BY e.e_date DESC;";

            stmt = connection.prepareStatement(sql);
            stmt.setString(1, countryName);
            //execute the SQL query
            rs = stmt.executeQuery();

            //insert the results into the lists
            while(rs.next()){
                electionId.add(rs.getInt("electionId"));
                cabinetId.add(rs.getInt("cabinetId"));
            }
            rs.close();
            result = new ElectionCabinetResult(electionId, cabinetId);
            return result;
        }
        catch(SQLException se){
            return null;
        }
    }


    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!

        List<Integer> result = new ArrayList<Integer>();

        String givenPresidentQ;
        String allPresidentQ;
        
        PreparedStatement psGiven;
        PreparedStatement psAll;

        ResultSet infoResult1;
        ResultSet infoResult2;

        try{
            //first find the info of given president
            givenPresidentQ = "SELECT id, description, comment " +
                                "FROM politician_president " + 
                                "WHERE id = ?";
            psGiven = connection.prepareStatement(givenPresidentQ);
            psGiven.setInt(1, politicianName);
            infoResult1 = psGiven.executeQuery();

            //put the given president info into the string
            String givenPInfoD = new String("");   
            String givenPInfoC = new String("");
            String givenPInfoDC = new String("");
            String givenPInfoCD = new String("");
            while(infoResult1.next()) {
                givenPInfoD = infoResult1.getString("description");
                givenPInfoC = infoResult1.getString("comment");
                givenPInfoDC = infoResult1.getString("description") + " " + infoResult1.getString("comment");
                givenPInfoCD = infoResult1.getString("comment") + " " + infoResult1.getString("description");

            }
            


            //then select other president except the given one
            allPresidentQ = "SELECT id, description, comment " +
                    "FROM politician_president " + 
                    "WHERE id != " + Integer.toString(politicianName);
            
            psAll = connection.prepareStatement(allPresidentQ);
            infoResult2 = psAll.executeQuery();

            while(infoResult2.next()){
                //String tempPInfo = infoResult2.getString("description") + " " + infoResult2.getString("comment");
                String tempPInfoD = infoResult2.getString("description");
                String tempPInfoDC = infoResult2.getString("description") + " " + infoResult2.getString("comment");
                String tempPInfoCD = infoResult2.getString("comment") + " " + infoResult2.getString("description");

                //compare everyone with the given one
                double JSimilarityD = similarity(tempPInfoD, givenPInfoD);
                double JSimilarityDC = similarity(tempPInfoDC, givenPInfoDC);
                double JSimilarityCD = similarity(tempPInfoCD, givenPInfoCD);
                //have the id ready
                int validID = infoResult2.getInt("id");
                if ( (JSimilarityDC >= threshold) || (JSimilarityCD >= threshold) ){
                    result.add(validID);
                }
            }
        }
        catch (SQLException se) {
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
            return null;
        }
        return result;
    }



    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        //System.out.println("Hello");
          // You can put testing code in here. It will not affect our autotester.
        //  try {
        //     Assignment2 testcase = new Assignment2();
        //     testcase.connectDB("jdbc:postgresql://localhost:5432/csc343h-cuidongf?currentSchema=parlgov", "cuidongf", "");
        //     ElectionCabinetResult a = testcase.electionSequence("Japan");

        //     System.out.println("election id | cabinet id");

        //     for(int i = 0; i < a.elections.size(); ++i) {
        //         System.out.println(a.elections.get(i) + " | " + a.cabinets.get(i));
        //     }
            
        //     // Test findSimilarPoliticians
        //     List<Integer> b = testcase.findSimilarPoliticians(9, (float)0.0);
        //     System.out.println("Test 2:");
        //     for(int i : b) {
        //          System.out.println(i);
        //     }

        //     testcase.disconnectDB();
        // }

        // catch (ClassNotFoundException e) {
        //     System.out.println("Failed to find JDBC driver");
        // }
        
    }

}









