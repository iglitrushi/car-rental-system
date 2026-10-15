<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel</title>
</head>
<body>
    <h2>Admin Panel</h2>

    <!-- View Reservations -->
    <form action="AdminServlet" method="post">
        <input type="hidden" name="action" value="viewReservations"> 
        <button type="submit">View Reservations</button>
    </form>

    <br>

    
    <h3>Add New Car</h3>
    <form action="AdminServlet" method="post">
        <input type="hidden" name="action" value="addCar">
        Brand: <input type="text" name="brand" required><br>
        Model: <input type="text" name="model" required><br>
        Year: <input type="number" name="year" required><br>
        Price: <input type="text" name="price" required><br>
        <button type="submit">Add Car</button>
    </form>
</body>
</html>
