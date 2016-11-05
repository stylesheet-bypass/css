<?php

namespace abpcss;

use GuzzleHttp\Client;
use Psr\Http\Message\ResponseInterface;

class AdMediaEncoder {
    /** @var Client */
    private $httpClient;
    /** @var Config */
    private $apiUri;

    public function __construct(Client $httpClient, $apiUri)
    {
        $this->httpClient = $httpClient;
        $this->apiUri = $apiUri;
    }

    public function execute($adZoneId, $ip)
    {
        // Example: {"width":300,"type":"video","ad_zone":3,"height":250,"video_url":"http:\/\/127.0.0.1\/300x250.mp4"}
        $jsonEncodedAd = $this->fetchAdFromApi($adZoneId, $ip);

        $ad = json_decode($jsonEncodedAd);

        if (!$this->isValidAd($ad)) {
            throw new \Exception("Unable to decode response from ads API.");
        }

        $assetHttpResponse = $this->fetchAdAssetHttpResponse($this->getAssetUrl($ad));

        return json_encode(
            $this->buildCssResponse(
                $ad,
                $this->extractAdMediaContentType($assetHttpResponse),
                $this->extractAdMediaContent($assetHttpResponse)
            )
        );
    }

    /** @return string JSON */
    private function fetchAdFromApi($zoneId, $ip)
    {
        $adUrl = sprintf($this->apiUri, $zoneId, $ip);
        return $this->httpClient->get($adUrl)->getBody()->getContents();
    }

    /** @return ResponseInterface */
    private function fetchAdAssetHttpResponse($assetUrl)
    {
        return $this->httpClient->get($assetUrl);
    }

    /** @return array */
    private function buildCssResponse($ad, $adMediaContentType, $adMediaContent)
    {
        $adCss = [
            'media_encoding' => 1
        ];

        foreach ($ad as $key => $value) {
            switch ($key) {
                case 'ad_zone':
                    continue;
                case 'img_url':
                    $adCss['img_type'] = $adMediaContentType;
                    $adCss['img_data'] = base64_encode($adMediaContent);
                    break;
                case 'video_url':
                    $adCss['video_type'] = $adMediaContentType;
                    $adCss['video_data'] = base64_encode($adMediaContent);
                    break;
                default:
                    $adCss[$key] = $value;
            }
        }

        return $adCss;
    }

    private function getAssetUrl($adsObj)
    {
        if ($this->isImageTypeAd($adsObj)) {
            return $adsObj->img_url;
        }
        return $adsObj->video_url;
    }

    private function isImageTypeAd($adsObj)
    {
        return $adsObj->type == 'image';
    }

    private function extractAdMediaContent(ResponseInterface $assetHttpRequest)
    {
        return $assetHttpRequest->getBody()->getContents();
    }

    private function extractAdMediaContentType(ResponseInterface $assetHttpRequest)
    {
        return $assetHttpRequest->getHeader('Content-Type')[0];
    }

    private function isValidAd($ad)
    {
        if (empty($ad) || !is_object($ad)) {
            return false;
        }

        if (!property_exists($ad, 'type')) {
            return false;
        }

        if (!property_exists($ad, 'img_url') && !property_exists($ad, 'video_url')) {
            return false;
        }

        return true;
    }

}