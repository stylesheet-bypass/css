<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;
use GuzzleHttp\Client;

$loader = require __DIR__ . '/vendor/autoload.php';

$app = new \Slim\App;
$app->add(new RKA\Middleware\IpAddress());

/*
 * Route for CSS output from Ads API
 *  http://127.0.0.1/css_php/1/myCssCallbackForZone1
 *  http://127.0.0.1/css_php/2/myCssCallbackForZone2
 *  http://127.0.0.1/css_php/3/myCssCallbackForVideoZone3
 */
$app->get('/css_php/{adZoneId:[0-9]+}/{cssCallback}', function (Request $request, Response $response) {

    $adZoneId = $request->getAttribute('adZoneId');
    $cssCallback = $request->getAttribute('cssCallback');

    $adMediaEncoder = new abpcss\AdMediaEncoder(new Client(), 'http://127.0.0.1/ads/%u?format=json&clientip=%s');

    try {
        $encodedMediaAd = $adMediaEncoder->execute($adZoneId, $request->getAttribute('ip_address'));
    } catch (\Exception $e) {
        return $response->withStatus(500, $e->getMessage());
    }

    if (empty($encodedMediaAd)) {
        return $response->withStatus(500, "Encoded media ad response is empty");
    }

    // Construct CSS template with base64_encoded media ad
    $template = sprintf('#%s{content:"%s"}', $cssCallback, base64_encode($encodedMediaAd));

    return $response->withStatus(200)
        ->withHeader('Content-Type', 'text/css')
        ->write($template);

});

$app->run();