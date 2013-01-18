<?php

if ($_GET) {
	$directory = $_GET['directory'];
	$package = $_GET['package'];
	$version = $_GET['package'];
}
else {
	$directory = $argv[1];
	$package = $argv[2];
	$version = $argv[3];
}

$jsonData = json_decode(file_get_contents($directory.'/composer.json'), true);

$jsonData['require'][$package] = $version;

file_put_contents($directory.'/composer.json', json_encode($jsonData));
