<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>

<%
    HttpSession httpSession = request.getSession();
    if (httpSession == null || httpSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userEmail = (String) httpSession.getAttribute("user");

    // JDBC driver name and database URL
    String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    String DB_URL = "jdbc:mysql://localhost:3306/ultras";

    // Database credentials
    String USER = "root";
    String PASS = "";

    Connection con = null;
    PreparedStatement pstmt = null;
    int userId = -1;

    try {
        // Register JDBC driver
        Class.forName(JDBC_DRIVER);

        // Open a connection
        con = DriverManager.getConnection(DB_URL, USER, PASS);

        // Get the user ID from the user email
        String userSql = "SELECT id FROM ultras_user WHERE email = ?";
        pstmt = con.prepareStatement(userSql);
        pstmt.setString(1, userEmail);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            userId = rs.getInt("id");
        }

        // Handle removal of items
        String removeId = request.getParameter("removeId");
        if (removeId != null && !removeId.isEmpty()) {
            String deleteSql = "DELETE FROM cart WHERE user_id = ? AND id = ?";
            pstmt = con.prepareStatement(deleteSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, Integer.parseInt(removeId));
            pstmt.executeUpdate();
        }

        // Handle updating the cart quantities and sizes
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (paramName.startsWith("quantity_")) {
                int cartId = Integer.parseInt(paramName.split("_")[1]);
                int quantity = Integer.parseInt(request.getParameter(paramName));
                String updateSql = "UPDATE cart SET quantity = ? WHERE id = ?";
                pstmt = con.prepareStatement(updateSql);
                pstmt.setInt(1, quantity);
                pstmt.setInt(2, cartId);
                pstmt.executeUpdate();
            } else if (paramName.startsWith("size_")) {
                int cartId = Integer.parseInt(paramName.split("_")[1]);
                String size = request.getParameter(paramName);
                String updateSql = "UPDATE cart SET size = ? WHERE id = ?";
                pstmt = con.prepareStatement(updateSql);
                pstmt.setString(1, size);
                pstmt.setInt(2, cartId);
                pstmt.executeUpdate();
            }
        }

        // Redirect back to the cart page
        response.sendRedirect("viewcart.jsp");
    } catch (SQLException se) {
        se.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }
%>
