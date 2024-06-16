<?php

echo '<html><head><title>Mega downloader</title></head><body><h2>Enter Url</h2><form action="mega.php" method="POST"> <br> URL: <input type="text" name="URL"> <br><input type="submit" value="Submit"></form>';


if ($_POST) {

error_reporting(0);
$url = $_POST['URL'];
preg_match("/file/(.+?)#/", $url, $output_array);
$fileID = $output_array[1];
$domain = "meganz";
$lang = "en";
$apiURL = "https://eu.api.mega.co.nz/cs?domain=$domain&lang=$lang";
 
$value = array(
  array(
    'a' => 'g',
    'g' => 1,
    'ssl' => 0, //0, 1, 2 (default is 2)
    'p' => $fileID) // File id here
  );
 
  $rawPOST = json_encode($value);
 
  $ch = curl_init();
 
  curl_setopt($ch, CURLOPT_URL,            $apiURL );
  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true );
  curl_setopt($ch, CURLOPT_POST,           true );
  curl_setopt($ch, CURLOPT_POSTFIELDS,     $rawPOST );
  curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36');
  curl_setopt($ch, CURLOPT_HTTPHEADER,     array('Content-Type: text/plain;charset=UTF-8'));
 
  $result=curl_exec($ch);
 
  $jsonResult = json_decode($result);
  $directLink = $jsonResult[0]->g;
  $fileSize = $jsonResult[0]->s;
 
  echo "URL: $directLink";
  echo '<br>';
  echo "File Size: $fileSize bytes";
  echo '<br>';
}
  echo '</body>
  </html>';
  ?>

