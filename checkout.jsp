<%@ page import="javax.servlet.*, javax.servlet.http.*" %>
<%@ page import="java.sql.*, java.util.*" %>

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
    ResultSet rs = null;
    int userId = -1;
    double totalPrice = 0.0;

    try {
        // Register JDBC driver
        Class.forName(JDBC_DRIVER);

        // Open a connection
        con = DriverManager.getConnection(DB_URL, USER, PASS);

        // Get the user ID from the user email
        String userSql = "SELECT id FROM ultras_user WHERE email = ?";
        pstmt = con.prepareStatement(userSql);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            userId = rs.getInt("id");
        }

        // Query to get cart details with product information
        String sql = "SELECT c.*, p.name, p.price " +
                     "FROM cart c " +
                     "JOIN products p ON c.product_id = p.id " +
                     "WHERE c.user_id = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            totalPrice += rs.getDouble("price") * rs.getInt("quantity");
        }
    } catch (SQLException se) {
        se.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Checkout</title>
<!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<div class="container">
    <h2 class="mt-4 mb-4">Checkout</h2>
    <form action="payment.jsp" method="post">
        <div class="form-group">
            <label for="name">Full Name</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>
        <div class="form-group">
            <label for="address">Address</label>
            <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
        </div>
        <div class="form-group">
            <label for="city">City</label>
            <input type="text" class="form-control" id="city" name="city" required>
        </div>
        <div class="form-group">
            <label for="state">State</label>
            <input type="text" class="form-control" id="state" name="state" required>
        </div>
        <div class="form-group">
            <label for="zip">Zip Code</label>
            <input type="text" class="form-control" id="zip" name="zip" required>
        </div>
        <input type="hidden" name="totalPrice" value="<%= totalPrice %>">
        <button type="submit" class="btn btn-danger">Proceed to Payment</button>
    </form>
</div>
<!-- Bootstrap JavaScript -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
