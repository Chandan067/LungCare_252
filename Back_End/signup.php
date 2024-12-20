<?php
// Enable CORS to allow requests from the Flutter app
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection parameters
$servername = "localhost";
$username = "root";
$password = "";
$database = "doctor";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve raw POST data
$data = file_get_contents("php://input");

// Debug: Log the raw input data (optional)
file_put_contents('php_log.txt', "Raw input: " . $data . PHP_EOL, FILE_APPEND);

// Check if any data is received
if (!$data) {
    $response = array("success" => false, "message" => "No data received.");
    echo json_encode($response);
    exit;
}

// Try decoding JSON
$json_data = json_decode($data);

// Check if JSON decoding was successful
if (json_last_error() !== JSON_ERROR_NONE) {
    $response = array("success" => false, "message" => "JSON decode error: " . json_last_error_msg());
    echo json_encode($response);
    exit;
}

// Check if required fields are not null
if (!isset($json_data->doc_id) || !isset($json_data->username) || !isset($json_data->email) || !isset($json_data->phno) || !isset($json_data->password)) {
    $response = array("success" => false, "message" => "Missing required fields.");
    echo json_encode($response);
    exit;
}

// Extract data from JSON
$doc_id = $json_data->doc_id;
$username = $json_data->username;
$email = $json_data->email;
$phno = $json_data->phno;
$password = $json_data->password;


// Check if the doc_id already exists
$check_query = $conn->prepare("SELECT doc_id FROM users WHERE doc_id = ?");
$check_query->bind_param("s", $doc_id);
$check_query->execute();
$check_query->store_result();

if ($check_query->num_rows > 0) {
    $response = array("success" => false, "message" => "User with this doc_id already exists.");
    echo json_encode($response);
    $check_query->close();
    $conn->close();
    exit;
}

// Close the check query
$check_query->close();

// Prepare SQL statement to insert user data
$stmt = $conn->prepare("INSERT INTO users (doc_id, username, email, phno, password) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("sssss", $doc_id, $username, $email, $phno, $password);

// Execute the statement
if ($stmt->execute()) {
    $response = array("success" => true, "message" => "User data inserted successfully.");
    echo json_encode($response);
} else {
    $response = array("success" => false, "message" => "Error: " . $stmt->error);
    echo json_encode($response);
}

// Close statement and connection
$stmt->close();
$conn->close();
?>
