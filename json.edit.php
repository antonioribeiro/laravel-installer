<?php

if ($_GET) {
	$directory = $_GET['directory'];
	$package = $_GET['package'];
	$version = $_GET['package'];
}
else {
	$directory = $argv[0];
	$package = $argv[1];
	$version = $argv[2];
}

$json_data = json_decode(file_get_contents($directory.'/composer.json'), true);

$json_data['require'][$package] = $_GET[$version];

file_put_contents('composer.json.new', json_encode($json_data));
