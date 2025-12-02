let
  pim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";

  ojs = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINNnavv0c8Htl2OSN9sFM/aFm6FbxvHwTLZDjgb5g1zh";
  lego1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/5cm8VDfCN5y05tcX16tZl3rR+kEgznsrEw1FAaoez";
  lego2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEk9rmZ6i/iCukbQBKf28MVz994Ed3GtdK6K37r8QOH";
  rodin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITKQnVAoVLw3gGL4c2pWW4uA6CySG6Rd/r4NIEAk6KU";

  hurry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyh9gDCDN2rzAExllvavzVVr4XkKea63Wa+B7JO8+Qz";
  harry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmY6Jv/y1CSyVe0t1L+65NQjocDoDUShhriPp5yg6eh";

  users = [ pim ];
  systems = [
    ojs
    lego1
    rodin
    hurry
    harry
    lego2
  ];

in
{

  "openai-api-key.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];
  "openai-api-key-plain.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];
  "kagi-api-key-plain.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];
  "tavily-api-key-plain.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];

  "bedrockpim-api-keys-env.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];
  "bedrock-keys-for-avante-env.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];

  "aws-credentials-copy.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];
  "aws-config-copy-first-time-only.age".publicKeys = [ pim ];
  "aws-accounts.json.age".publicKeys = [
    pim
    ojs
    lego1
    rodin
    lego2
  ];

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

}
