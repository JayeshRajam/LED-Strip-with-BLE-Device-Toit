import ble
import bitmap show bytemap_zap
import pixel_strip show UartPixelStrip

PIXELS ::= 30  // Number of pixels on the strip.
UL::= -40      // Upper limit of rssi.
LL::= -100     // Lower limit of rssi.

BLE_DEVICE ::= "d3:3e:e3:cd:6b:10"  // Device to watch.

main:
  pixels := UartPixelStrip PIXELS
      --pin=17  // Output pin for UART 2.
  r := ByteArray PIXELS
  g := ByteArray PIXELS
  b := ByteArray PIXELS

  device := ble.Device.default
  device.scan: | remote_device/ble.RemoteDevice |   // Start scanning for devices.
    // print "$remote_device  $remote_device.data.name"
    address := "$remote_device.address"
    if address == BLE_DEVICE:
      rssi := remote_device.rssi
      print "$rssi dBm"

      step:= 255 / PIXELS // Step size for colour pattern, 8 in this case.
      r[0] = 0xff // Colormax hexcode.
      g[0] = 0x00 // Colormin hexcode.
      b.fill 0x00
      for i := 1; i < PIXELS; i++: // Initialize led strip’s colour pattern.
        r[i] = r[i-1] - step
        g[i] = g[i-1] + step

      // Linear conversion to find number of Pixels to glow as per rssi value
      // range 0 to (PIXELS-1)
      PIX := ((((rssi - LL) * (0 - (PIXELS - 1))) / (LL - UL)) + 0).to_int
      // print PIX
      for j := PIX; j < PIXELS; j++:
        r[j] = 0x00
        g[j] = 0x00

      pixels.output r g b
      sleep --ms=1
