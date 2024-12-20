<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "doctor";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the posted data
$data = json_decode(file_get_contents("php://input"), true);

// Set response header to JSON
header('Content-Type: application/json');

// Validate the input data
if (isset($data['doc_id']) && isset($data['password'])) {
    $doc_id = $data['doc_id'];
    $password = $data['password'];

    // Prepare the SQL statement to prevent SQL injection
    $stmt = $conn->prepare("SELECT * FROM users WHERE doc_id = ? AND password = ?");
    $stmt->bind_param("ss", $doc_id, $password);

    // Execute the statement
    $stmt->execute();

    // Get the result
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Credentials are correct
        echo json_encode(["success" => true, "message" => "Login successful"]);
    } else {
        // Credentials are incorrect
        echo json_encode(["success" => false, "message" => "Invalid doctor ID or password"]);
    }

    // Close the statement and connection
    $stmt->close();
} else {
    // Invalid input data
    echo json_encode(["success" => false, "message" => "Doctor ID or password missing"]);
}

$conn->close();
?>
