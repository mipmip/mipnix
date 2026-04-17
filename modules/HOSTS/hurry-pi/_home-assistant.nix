{config, pkgs, ...}:{


  services.home-assistant = {
    # opt-out from declarative configuration management
    enable = true;
    package = (pkgs.home-assistant.override { extraPackages = ps: [
      ps.numpy
      ps.aiohomekit
      #      #ps.pyhap
      ps.pyatv
      ps.aiohue
      ps.gtts
      #ps.pytado
      ps.tuyaha
      ps.python-otbr-api
      ps.tinytuya
      ps.tuya-iot-py-sdk
      ps.tuya-device-sharing-sdk
      ps.pynacl
      ps.pytile
      ps.av
      ps.hap-python
      ps.async-upnp-client
      ps.aiodhcpwatcher
      ps.go2rtc-client
      ps.python-matter-server
      ps.universal-silabs-flasher
      ps.zha
      ps.aiodiscover
      ps.pyturbojpeg
      ps.base36
    ]; });
    config = null;
    lovelaceConfig = null;
    # configure the path to your config directory
    configDir = "/etc/home-assistant";
    # specify list of components required by your configuration
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
    ];
  };
}

