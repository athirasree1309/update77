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
        String sql = "SELECT c.*, p.name, p.price, p.image, p.specification " +
                     "FROM cart c " +
                     "JOIN products p ON c.product_id = p.id " +
                     "WHERE c.user_id = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
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
<title>Your Cart</title>
<!-- Bootstrap CSS -->
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<!-- Custom CSS -->
<style>
    .cart-table img {
        width: 100px;
        height: auto;
    }
    .cart-item {
        border-bottom: 1px solid #ddd;
        padding: 10px 0;
    }
    .cart-item:last-child {
        border-bottom: none;
    }
    .btn-group {
        display: flex;
        align-items: center;
    }
    .btn-group .btn {
        margin: 0 5px;
    }
    .total-price {
        font-size: 1.2em;
        font-weight: bold;
        text-align: right;
        margin-top: 20px;
    }
</style>
</head>
<body>
<div class="container">
    <h2 class="mt-4 mb-4">Your Cart</h2>
<form id="cartForm" action="updateCart.jsp" method="post">
    <table class="table cart-table">
        <thead>
            <tr>
                <th>Product Image</th>
                <th>Product Name</th>
                <th>Size</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Total</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% 
                while (rs.next()) { 
                    double itemTotal = rs.getDouble("price") * rs.getInt("quantity");
                    totalPrice += itemTotal;
            %>
                <tr class="cart-item">
                    <td><img src="<%= rs.getString("image") %>" alt="<%= rs.getString("name") %>"></td>
                    <td><%= rs.getString("name") %></td>
                    <td>
                        <!-- Size dropdown -->
                        <select name="size_<%= rs.getInt("id") %>" class="form-control">
                            <option value="<%= rs.getString("size") %>"><%= rs.getString("size") %></option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XXL">XXL</option>
                        </select>
                    </td>
                    <td>&#8360; <%= rs.getDouble("price") %></td>
                    <td>
                        <!-- Quantity controls -->
                        <div class="btn-group">
                            <button type="button" class="btn btn-secondary" onclick="decrementQuantity(<%= rs.getInt("id") %>)">-</button>
                            <input type="number" name="quantity_<%= rs.getInt("id") %>" value="<%= rs.getInt("quantity") %>" min="1" class="form-control w-50" id="quantity_<%= rs.getInt("id") %>">
                            <button type="button" class="btn btn-secondary" onclick="incrementQuantity(<%= rs.getInt("id") %>)">+</button>
                        </div>
                    </td>
                    <td>&#8360; <%= itemTotal %></td>
                    <td>
                        <!-- Action buttons -->
                        <button type="button" class="btn btn-danger" onclick="removeItem(<%= rs.getInt("id") %>)">Remove</button>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
    <!-- Display the total price -->
    <div class="total-price">
        Total Price: &#8360; <%= totalPrice %>
    </div>
    <!-- Hidden input to handle removal -->
    <input type="hidden" name="removeId" id="removeId" value="">
    <!-- Update Cart Button -->
    <button type="submit" class="btn btn-dark mt-4">Update Cart</button>
</form>
<a href="checkout.jsp" class="btn btn-danger mt-4">Proceed to Checkout</a>

</div>

<!-- Bootstrap and custom JavaScript -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
function incrementQuantity(cartId) {
    let quantityInput = document.getElementById('quantity_' + cartId);
    quantityInput.value = parseInt(quantityInput.value) + 1;
}

function decrementQuantity(cartId) {
    let quantityInput = document.getElementById('quantity_' + cartId);
    let currentValue = parseInt(quantityInput.value);
    if (currentValue > 1) {
        quantityInput.value = currentValue - 1;
    }
}

function removeItem(itemId) {
    document.getElementById('removeId').value = itemId;
    document.getElementById('cartForm').submit();
}

</script>
</body>
</html>
