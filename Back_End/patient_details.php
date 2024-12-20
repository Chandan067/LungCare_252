<?php
// Database configuration
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

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate required fields
    $requiredFields = ['name', 'age', 'gender', 'phone', 'prediction', 'confidence'];
    foreach ($requiredFields as $field) {
        if (empty($_POST[$field])) {
            http_response_code(400);
            echo json_encode(["error" => "$field is required"]);
            exit;
        }
    }

    // Handle the uploaded image
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(["error" => "Image upload failed"]);
        exit;
    }

    // Prepare the data
    $name = htmlspecialchars($_POST['name']);
    $age = intval($_POST['age']);
    $gender = htmlspecialchars($_POST['gender']);
    $phone = htmlspecialchars($_POST['phone']);
    $prediction = htmlspecialchars($_POST['prediction']);
    $confidence = floatval($_POST['confidence']);
    $uploadsDir = 'uploads/';
    $imageName = time() . '_' . basename($_FILES['image']['name']);
    $imagePath = $uploadsDir . $imageName;

    // Move uploaded image
    if (!move_uploaded_file($_FILES['image']['tmp_name'], $imagePath)) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to save the image"]);
        exit;
    }

    // Insert data into the database
    try {
        $stmt = $conn->prepare("INSERT INTO patients (name, age, gender, phone, image_path, prediction, confidence) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sissssd", $name, $age, $gender, $phone, $imagePath, $prediction, $confidence);
        $stmt->execute();

        echo json_encode(["success" => true, "message" => "Patient data saved successfully"]);
    } catch (mysqli_sql_exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to save data: " . $e->getMessage()]);
    } finally {
        $stmt->close();
    }
} else {
    http_response_code(405);
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>
