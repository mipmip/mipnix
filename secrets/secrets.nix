let
  cichorei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZU9DZpGs+Ib/aN3n7u46wY8v9V4qHLcNzs/U+9iTgc";
  pim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";

  annemarie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvyHG+v+V+LQcbxw1H0ZCnrPkHy90lGu/08avLFa48S";
  lego2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEk9rmZ6i/iCukbQBKf28MVz994Ed3GtdK6K37r8QOH";
  lavendel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7SSE52Oaftqy7uqCXSIr5lQTrs7wqR7lUdf7IiVHvo";
  rodin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITKQnVAoVLw3gGL4c2pWW4uA6CySG6Rd/r4NIEAk6KU";
  dapperehaan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjWlnTNc6cEhpI2SHofjwWZW7HZU0OBD6pY7QI4gpki";
  clawone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMhCHXAfIfZRYct5eTrUu/MPXJ5IE+j6QYWSkDv3PbFU";
  durer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+jRQYvOX+EI+QeB31JT994sYo+B1j18AxTjzuprQ2F";
  hurry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyh9gDCDN2rzAExllvavzVVr4XkKea63Wa+B7JO8+Qz";
  harry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmY6Jv/y1CSyVe0t1L+65NQjocDoDUShhriPp5yg6eh";
  peterspav = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJ7MltNQkkv0gvF+qkSnbvzpfX6eOmWtTKgb3e6rWlq";

  users = [ pim annemarie ];
  systems = [
    cichorei
    hurry
    harry
    lego2
    lavendel
    dapperehaan
    durer
    peterspav
  ];

  trusted_systems = [
    lego2
    dapperehaan
    peterspav
  ];

in
{

  "openai-api-key.age".publicKeys = [ pim ] ++ trusted_systems;
  "openai-api-key-plain.age".publicKeys = [ pim ] ++ trusted_systems;
  "kagi-api-key-plain.age".publicKeys = users ++ systems;
  "tavily-api-key-plain.age".publicKeys = [ pim ] ++ trusted_systems;

  "bedrock-annemarie-api-keys-env.age".publicKeys = [
    pim
    lego2
    lavendel
    annemarie
  ];

  "bedrockpim-api-keys-env.age".publicKeys = [ pim ] ++ trusted_systems;

  "env-for-litellm.age".publicKeys = [ pim ] ++ trusted_systems;


  "bedrock-keys-for-avante-env.age".publicKeys = [ pim ] ++ trusted_systems;

  "aws-credentials-copy.age".publicKeys = [ pim ] ++ trusted_systems;
  "aws-config-copy-first-time-only.age".publicKeys = [ pim ];
  "aws-accounts.json.age".publicKeys = [ pim ] ++ trusted_systems;

  "wifi.age".publicKeys = [
    pim
    hurry
    harry
  ];
  "vaultwarden.env.age".publicKeys = [
    pim
    hurry
    rodin
  ];

  "hurry-smtp.age".publicKeys = [
    pim
    hurry
  ];
  "hurry-cloudflared.pem.age".publicKeys = [
    pim
    hurry
    harry
  ];
  "hurry-cloudflared-tunnel.json.age".publicKeys = [
    pim
    hurry
  ];
  "harry-cloudflared-tunnel.json.age".publicKeys = [
    pim
    harry
  ];

  "nextcloud-admin-pw.age".publicKeys = [
    pim
    harry
  ];
  "piethein-samba-secrets.age".publicKeys = [
    pim
    harry
  ];

  "umami-env.age".publicKeys = [ pim durer ];

  "pimprived.age".publicKeys = [ pim ];

  "id_ed25519_remotebuild.age".publicKeys = [ pim ] ++ systems;

  "nebula-lighthouse1.crt.age".publicKeys = users ++ systems;
  "nebula-lighthouse1.key.age".publicKeys = users ++ systems;
  "nebula-ca.crt.age".publicKeys = users ++ systems;
  "nebula-ca.key.age".publicKeys = users ++ systems;
  "nebula-lego2.crt.age".publicKeys = users ++ systems;
  "nebula-lego2.key.age".publicKeys = users ++ systems;
  "nebula-hurry.crt.age".publicKeys = users ++ systems;
  "nebula-hurry.key.age".publicKeys = users ++ systems;
  "nebula-sshd-hostkey.age".publicKeys = users ++ systems;
  "nebula-harry.crt.age".publicKeys = users ++ systems;
  "nebula-harry.key.age".publicKeys = users ++ systems;
  "nebula-passieflora.crt.age".publicKeys = users ++ systems;
  "nebula-passieflora.key.age".publicKeys = users ++ systems;


  "nebula-fairphonepim.crt.age".publicKeys = users ++ systems;
  "nebula-fairphonepim.key.age".publicKeys = users ++ systems;

  "nebula-lavendel.crt.age".publicKeys = users ++ systems;
  "nebula-lavendel.key.age".publicKeys = users ++ systems;

  "openai-api-key-plain-mama.key.age".publicKeys = users ++ systems;

  "ghi-token.age".publicKeys = users; ## should configure ghi in home manager

  "nebula-dapperehaan.crt.age".publicKeys = users ++ systems;
  "nebula-dapperehaan.key.age".publicKeys = users ++ systems;

  "nebula-durer.crt.age".publicKeys = users ++ systems;
  "nebula-durer.key.age".publicKeys = users ++ systems;

  "matrix-openclaw-password.age".publicKeys = [pim clawone];
  "voorzetramenshop-env.age".publicKeys = [ pim durer ];
  "nebula-cichorei.crt.age".publicKeys = users ++ systems;
  "nebula-cichorei.key.age".publicKeys = users ++ systems;
  "ssh-password-resticbackup.age".publicKeys = users ++ systems;

}
