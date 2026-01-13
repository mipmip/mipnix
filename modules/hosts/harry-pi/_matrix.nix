{
  # See https://search.nixos.org/options?channel=unstable&query=services.matrix-conduit.
  # and https://docs.conduit.rs/configuration.html
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      allow_registration = false;
      # You will need this token when creating your first account.
      registration_token = "A S3CR3T TOKEN";
      server_name = "matrix.notnix.com";
      port = 8066;
      address = "::1";
      database_backend = "rocksdb";

      # See https://docs.conduit.rs/turn.html, and https://github.com/element-hq/synapse/blob/develop/docs/turn-howto.md for more details
      # turn_uris = [
      #  "turn:your.turn.url?transport=udp"
      #  "turn:your.turn.url?transport=tcp"
      # ];
      # turn_secret = "your secret";
    };
  };
}
