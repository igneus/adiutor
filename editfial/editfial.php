<?php
/**
 * HTTP interface to editfial.rb.
 *
 * Must run outside of Docker, under the user running frescobaldi,
 * not served by Apache or another webserver running as system service with its own UID.
 */


$iaSources = getenv('IN_ADIUTORIUM_SOURCES_PATH');
if (!$iaSources) {
    die('The environment variable with In adiutorium sources path must be provided');
}

// environment setup
chdir($iaSources); // editfial.rb expects this



$fial = $_GET['fial'];
$line = $_GET['line'];
$redirectBack = $_GET['redirectBack'];
$debug = $_GET['debug'];



// input validation
if (!$fial) {
    die("Please specify the fial parameter");
}
if (1 !== preg_match('/^[\w\d_\/]+\.ly#[\w\d-]+/', $fial)) {
    die("Invalid fial $line");
}
if ($line && !is_numeric($line)) {
    die("Invalid line $line");
}

if ($line) {
    $fial .= ":$line";
}



// exec() only captures stdout, redirect stderr there
$command = "ruby nastroje/editfial.rb $fial 2>&1";
exec($command, $output, $status);

if ($debug) {
    echo $command . "\n";
    echo var_dump($output);
    echo "\n";
    echo "Exit status: $status";
    exit;
}

if ($redirectBack) {
    header("Location: $redirectBack", TRUE, 302);
} else {
    die("Please specify the redirectBack parameter");
}
