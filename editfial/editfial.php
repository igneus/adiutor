<?php
/**
 * HTTP interface to editfial.rb.
 *
 * Must run outside of Docker, under the user running frescobaldi,
 * not served by Apache or another webserver running as system service with its own UID.
 */

function is_valid_fial($fial) {
    return 1 === preg_match('/^[\w\d_\/]+\.ly#[\w\d-]+$/', $fial);
}

if (isset($argv) && 'test' === $argv[1]) {
    $examples = [
        [false, ''],
        [false, 'a'],
        [false, 'kompletar.ly'],
        [false, 'kompletar.ly#'],
        [true, 'kompletar.ly#id'],
        [true, 'antifony/mezidobi_nedeleA_02_10.ly#ne10a-2ne-amag'],
        [true, 'kompletar.ly#id2'],
        [false, 'kompletar.ly#id '],
        // make sure the code is not vulnerable to shell injection
        [false, 'kompletar.ly#id ; rm -rf /'],
        [false, 'kompletar.ly#id;ls'],
    ];

    $failures = 0;
    foreach ($examples as $i => $data) {
        [$expected, $given] = $data;
        $result = is_valid_fial($given);
        if ($result === $expected) {
            echo '.';
        } else {
            echo "\nExample #$i: expected $expected, got $result\n";
            ++$failures;
        }
    }

    $total = count($examples);
    echo "\n\n$total examples, $failures failures\n";
    exit($failures > 0 ? 1 : 0);
}



$iaSources = getenv('IN_ADIUTORIUM_SOURCES_PATH');
if (!$iaSources) {
    die('The environment variable with In adiutorium sources path must be provided');
}

$secret = getenv('EDIT_FIAL_SECRET');

// environment setup
chdir($iaSources); // editfial.rb expects this



$apiKey = $_GET['apiKey'] ?? null;
$fial = $_GET['fial'] ?? null;
$line = $_GET['line'] ?? null;
$redirectBack = $_GET['redirectBack'] ?? null;
$variationes = $_GET['variationes'] ?? null;
$debug = $_GET['debug'] ?? null;



// input validation
if ($secret && $apiKey !== $secret) {
    die('apiKey invalid');
}
if (!$fial) {
    die("Please specify the fial parameter");
}
if (!is_valid_fial($fial)) {
    die("Invalid fial $line");
}
if ($line && !is_numeric($line)) {
    die("Invalid line $line");
}

if ($line) {
    $fial .= ":$line";
}



$options = $variationes ? '--variationes' : '';

// exec() only captures stdout, redirect stderr there
$command = "ruby nastroje/editfial.rb $options $fial 2>&1";
exec($command, $output, $status);

if ($debug) {
    echo $command . "\n";
    echo var_dump($output);
    echo "\n";
    echo "Exit status: $status";
    exit;
}

if ($status !== 0) {
    $arg = 'editfialError=' . urlencode(implode("\n", $output));
    $redirectBack .= (false !== strpos($redirectBack, '?') ? '&' : '?') . $arg;
}

if ($redirectBack) {
    header("Location: $redirectBack", TRUE, 302);
} else {
    die("Please specify the redirectBack parameter");
}
