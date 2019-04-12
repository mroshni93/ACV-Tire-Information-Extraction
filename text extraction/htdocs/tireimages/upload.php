<?php
$firstName = $_POST["firstName"];
$wer=$_POST["status"];
echo $firstName;
echo $wer;
$target_dir = "uploads";
if(!file_exists($target_dir))
{
mkdir($target_dir, 0777, true);
echo "created directory";
}
$target_dir = $target_dir . "/" . basename($_FILES["file"]["name"]);

//overwrites to test.jpg
//$target_dir = $target_dir . "/" . "test.jpg";

echo $target_dir;
echo basename($_FILES["file"]["name"]);


if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir)) {
/*echo json_encode([
"Message" => "The file ". basename( $_FILES["file"]["name"]). " has been uploaded.",
"Status" => "OK"
]); */
} else {
/*echo json_encode([
"Message" => "Sorry, there was an error uploading your file.",
"Status" => "Error"
]); */
}  

?>