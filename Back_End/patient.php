<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require "dbh.php"; // Adjust this according to your actual file path

$response = array();

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if all required form fields are present
    if (isset($_POST['name']) && isset($_POST['age']) && isset($_POST['gender']) && isset($_FILES['image'])) {
        // Get the form data
        $name = $_POST['name'];
        $age = $_POST['age'];
        $gender = $_POST['gender'];
        
        // Image data
        $image_name = $_FILES['image']['name'];
        $image_tmp_name = $_FILES['image']['tmp_name'];
        $image_path = 'uploads/' . $image_name; // Path where the image will be stored
        
        // Move the uploaded image to the specified path
        if (move_uploaded_file($image_tmp_name, $image_path)) {
            try {
                // Prepare SQL statement
                $sql = "INSERT INTO patient_data (name, age, gender, image) VALUES (:name, :age, :gender, :image)";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':name', $name, PDO::PARAM_STR);
                $stmt->bindParam(':age', $age, PDO::PARAM_INT);
                $stmt->bindParam(':gender', $gender, PDO::PARAM_STR);
                $stmt->bindParam(':image', $image_path, PDO::PARAM_STR);

                // Execute SQL statement
                if ($stmt->execute()) {
                    $response['status'] = "success";
                    $response['message'] = "Data inserted successfully!";
                } else {
                    $response['status'] = "error";
                    $response['message'] = "Failed to insert data";
                }
            } catch (PDOException $e) {
                $response['status'] = "error";
                $response['message'] = "Database error: " . $e->getMessage();
            }
        } else {
            $response['status'] = "error";
            $response['message'] = "Failed to move uploaded image";
        }
    } else {
        // Handle the case where required form fields are missing or not properly named
        $response['status'] = "error";
        $response['message'] = "Invalid request data. Required form fields are missing.";
    }
} else {
    // Handle the case where request method is not POST
    $response['status'] = "error";
    $response['message'] = "Invalid request method";
}

// Close the database connection
$conn = null;

// Respond with JSON
echo json_encode($response);
?>
