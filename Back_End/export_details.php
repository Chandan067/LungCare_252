<?php
// Include the database connection file
require_once('dbh.php');

try {
    // Set headers to force download of the file
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="patients_export.csv"');

    // Open a writable stream for output
    $output = fopen('php://output', 'w');

    // SQL query to fetch all rows from the patients table
    $query = "SELECT name, age, gender, phone, image_path, created_at, prediction, confidence FROM patients";
    $stmt = $conn->query($query);

    // Write the column headers to the CSV file
    $headers = ['Name', 'Age', 'Gender', 'Phone Number', 'Image Path', 'Created At', 'Prediction', 'Confidence'];
    fputcsv($output, $headers);

    // Fetch and write the data rows
    $dataFound = false; // Flag to track if data exists
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        fputcsv($output, $row);
        $dataFound = true;
    }

    // If no data was found, add a message to the CSV
    if (!$dataFound) {
        fputcsv($output, ['No data available in the table.']);
    }

    // Close the writable stream
    fclose($output);

} catch (PDOException $e) {
    // Handle database errors
    echo 'Error: ' . $e->getMessage();
}

// Set the connection to null to close it
$conn = null;
?>
