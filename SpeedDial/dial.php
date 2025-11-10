<?php
// Set the content type header to image/png

$outputFile = 'output.json';
$jsonString = file_get_contents($outputFile);
$data = json_decode($jsonString, true);

// Define font path (ensure this file exists in the same directory)
putenv('GDFONTPATH=' . realpath('.'));
$font = 'brush_script'; 

// === Customizable Variables from URL Parameters ===
// Download Speed
$acceptable_dl = 100; // Acceptable download speed (High)
$actual_dl = isset($data['download_speed_mbps']) ? (int)$data['download_speed_mbps'] : 0; // Actual download speed
$low_dl = 0; // Low speed is always 0

// Upload Speed
$acceptable_up = 50; // Acceptable upload speed (High)
$actual_up = isset($data['upload_speed_mbps']) ? (int)$data['upload_speed_mbps'] : 0; // Actual upload speed
$low_up = 0; // Low speed is always 0

$acceptable_ping = 50; // Acceptable upload speed (High)
$actual_ping = isset($data['ping_ms']) ? (int)$data['ping_ms'] : 0; // Actual upload speed
$low_ping = 0;

// === Image Constants ===d
$image_width = 500;
$image_height = 150;
$dial_radius = 50;
$center_y = 100;
$font_size = 28;
$font_color = '#ffffff';
$dial_spacing = 20;

$font_size_label = $font_size;
$font_size_numbers = $font_size / 2;

// === GD Image Creation ===
$image = imagecreatetruecolor($image_width, $image_height);

// Set up a transparent background
imagesavealpha($image, true);
$trans_colour = imagecolorallocatealpha($image, 0, 0, 0, 127);
imagefill($image, 0, 0, $trans_colour);

// Allocate colors for the elements
$font_color = hexToRgb( $font_color ) ?? [ r => 255, g => 255, b => 255 ];
$white = imagecolorallocate($image, $font_color['r'], $font_color['g'], $font_color['b']);

// === Draw the dials and text ===
drawDial($image, 80, $center_y, $dial_radius, 'Down', $white, $font, $acceptable_dl, $low_dl, $actual_dl, $font_size_label, $font_size_numbers, 'MBPS');
drawDial($image, 240 + $dial_spacing, $center_y, $dial_radius, 'Up', $white, $font, $acceptable_up, $low_up, $actual_up, $font_size_label, $font_size_numbers, 'MBPS');
drawDial($image, 400 + $dial_spacing, $center_y, $dial_radius, 'Ping', $white, $font, $acceptable_ping, $low_ping, $actual_ping, $font_size_label, $font_size_numbers, 'Milli');

// === Output the final image ===
imagepng($image,'dial.png');
imagedestroy($image);
print 'Image saved to dial.png';

function hexToRgb($hexColor) {
    // Remove '#' if present
    $hexColor = ltrim($hexColor, '#');

    // Handle 3-character shorthand hex codes (e.g., #F00 becomes #FF0000)
    if (strlen($hexColor) == 3) {
        $r = hexdec(substr($hexColor, 0, 1) . substr($hexColor, 0, 1));
        $g = hexdec(substr($hexColor, 1, 1) . substr($hexColor, 1, 1));
        $b = hexdec(substr($hexColor, 2, 1) . substr($hexColor, 2, 1));
    } 
    // Handle 6-character hex codes (e.g., #FF0000)
    elseif (strlen($hexColor) == 6) {
        $r = hexdec(substr($hexColor, 0, 2));
        $g = hexdec(substr($hexColor, 2, 2));
        $b = hexdec(substr($hexColor, 4, 2));
    } 
    // Return false or handle invalid input
    else {
        return false; 
    }

    return ['r' => $r, 'g' => $g, 'b' => $b];
}

// === Helper function to draw a single dial ===
function drawDial($image, $center_x, $center_y, $radius, $label, $color, $font, $high_val, $low_val, $actual_val, $font_size_label, $font_size_numbers, $measurement='mbps') {
    // Draw the dial arc (semi-circle from 180 to 0 degrees)
    imagearc($image, $center_x, $center_y, $radius * 2, $radius * 2, 180, 0, $color);
    
    // Draw the top label
    $label_bbox = imagettfbbox($font_size_label, 0, $font, $label);
    $label_width = $label_bbox[2] - $label_bbox[0];
    @imagettftext($image, $font_size_label, 0, $center_x - $label_width / 2, $center_y - $radius - 10, $color, $font, $label);

    // Calculate angle for the pointer
    $max_val = max($high_val, $actual_val);
    $normalized_val = min($actual_val, $max_val);
    $angle = 180 - ($normalized_val / $max_val) * 180;
    $angle_radians = deg2rad($angle);

    // Calculate pointer endpoints
    $pointer_x = $center_x + $radius * cos($angle_radians);
    $pointer_y = $center_y - $radius * sin($angle_radians);
    
    // Draw the pointer line
    imageline($image, $center_x, $center_y, (int)$pointer_x, (int)$pointer_y, $color);

    // Draw the pointer origin circle
    imagefilledellipse($image, $center_x, $center_y, 8, 8, $color);

    // Draw dial numbers
    imagettftext($image, $font_size_numbers, 0, $center_x - $radius - 20, $center_y + 5, $color, $font, $low_val);
    imagettftext($image, $font_size_numbers, 0, $center_x + $radius + 5, $center_y + 5, $color, $font, $high_val);

    // Draw actual speed text
    $speed_text = $actual_val . " $measurement";
    $speed_bbox = imagettfbbox($font_size_numbers, 0, $font, $speed_text);
    $speed_width = $speed_bbox[2] - $speed_bbox[0];
    @imagettftext($image, $font_size_numbers, 0, $center_x - $speed_width / 2, $center_y + 20, $color, $font, $speed_text);
}