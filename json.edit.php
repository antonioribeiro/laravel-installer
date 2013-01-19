<?php

if ($_GET) {
	$directory = $_GET['directory'];
	$package = $_GET['package'];
	$version = $_GET['version'];
} else {
	$directory = $argv[1];
	$package = $argv[2];
	$version = $argv[3];
}

$jsonData = json_decode(file_get_contents($directory.'/composer.json'), true);

$jsonData['require'][$package] = $version;

file_put_contents($directory.'/composer.json', jsonPretty(unescape(json_encode($jsonData))));

function unescape($json) {
	return str_replace('\/','/',$json);
}

function jsonPretty($json, $html = false) {
    $out = ''; $nl = "\n"; $cnt = 0; $tab = 4; $len = strlen($json); $space = ' ';
	if($html) {
		$space = '&nbsp;';
		$nl = '<br/>';
	}
	$k = strlen($space)?strlen($space):1;
	for ($i=0; $i<=$len; $i++) {
		$char = substr($json, $i, 1);
		if($char == '}' || $char == ']') {
			$cnt --;
			$out .= $nl . str_pad('', ($tab * $cnt * $k), $space);
		} else if($char == '{' || $char == '[') {
			$cnt ++;
		}
		$out .= $char;
		if($char == ',' || $char == '{' || $char == '[') {
			$out .= $nl . str_pad('', ($tab * $cnt * $k), $space);
		}
		if($char == ':') {
			$out .= ' ';
		}
	}
	return $out;
}