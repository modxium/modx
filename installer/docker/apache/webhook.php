<?php

declare(strict_types=1);

$enabled = getenv('APP_WEBHOOK_ENABLED') ?: 'false';
$secret = getenv('APP_WEBHOOK_SECRET') ?: '';
$branch = getenv('APP_GIT_BRANCH') ?: 'main';

header('Content-Type: text/plain; charset=utf-8');

if ($enabled !== 'true') {
    http_response_code(404);
    echo "Webhook disabled.\n";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo "Method not allowed.\n";
    exit;
}

if ($secret === '') {
    http_response_code(500);
    echo "APP_WEBHOOK_SECRET is not configured.\n";
    exit;
}

$payload = file_get_contents('php://input') ?: '';
$signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';
$expected = 'sha256=' . hash_hmac('sha256', $payload, $secret);

if (!hash_equals($expected, $signature)) {
    http_response_code(401);
    echo "Invalid signature.\n";
    exit;
}

$event = $_SERVER['HTTP_X_GITHUB_EVENT'] ?? '';

if ($event === 'ping') {
    echo "pong\n";
    exit;
}

$data = json_decode($payload, true);

if (!is_array($data)) {
    http_response_code(400);
    echo "Invalid JSON payload.\n";
    exit;
}

$ref = $data['ref'] ?? '';
$expectedRef = 'refs/heads/' . $branch;

if ($ref !== $expectedRef) {
    echo "Ignoring ref {$ref}; expected {$expectedRef}.\n";
    exit;
}

$command = '/opt/modxium/git-sync.sh 2>&1';
$output = [];
$exitCode = 0;

exec($command, $output, $exitCode);

echo implode("\n", $output) . "\n";

if ($exitCode !== 0) {
    http_response_code(500);
    echo "Deploy failed with exit code {$exitCode}.\n";
    exit;
}

echo "Deploy complete.\n";
