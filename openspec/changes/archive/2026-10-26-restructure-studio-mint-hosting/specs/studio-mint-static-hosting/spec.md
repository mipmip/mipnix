# studio-mint-static-hosting Specification

## Purpose
The static Studio MINT sites on durer: how a private repository holding plain
HTML becomes a served directory without a flake of its own, which names answer
for which content, and how a content change reaches production.

## ADDED Requirements

### Requirement: Static sites arrive as flake inputs without their own flake
Each static Studio MINT site SHALL be declared as a private git input with
`flake = false`, and SHALL be turned into a served directory by a `runCommand`
package in this repository rather than by a flake in the site's repository.

#### Scenario: The inputs are declared
- **WHEN** `flake.nix` is evaluated
- **THEN** `studio-mint-apex` SHALL resolve to
  `mintglasinlood/studio-mint.shop` over SSH with `flake = false`
- **AND** `studio-mint-v2` SHALL resolve to
  `mintglasinlood/v2.studio-mint.shop` over SSH with `flake = false`

#### Scenario: A repository becomes a served directory
- **WHEN** the package for a static site is built
- **THEN** it SHALL contain the site's files at its root, so `index.html` is
  served at `/`
- **AND** `README.md` SHALL NOT be present, because with `flake = false` the
  whole repository becomes the store path and would otherwise be served

#### Scenario: Assets referenced by absolute path
- **WHEN** the apex page requests `/site.webmanifest` or one of its icon files
- **THEN** the file SHALL be served from the same package, because the whole
  repository is the document root

### Requirement: Each static site has its own vhost
durer SHALL serve the apex site on `studio-mint.shop` and the v2 site on
`v2.studio-mint.shop`, each from its own nginx vhost with its own certificate.

#### Scenario: The apex serves the apex repository
- **WHEN** the durer configuration is evaluated
- **THEN** a vhost for `studio-mint.shop` SHALL exist with `enableACME = true`
  and `forceSSL = true`
- **AND** its `root` SHALL be the apex package, not a proxy to the shop

#### Scenario: v2 serves the v2 repository
- **WHEN** the durer configuration is evaluated
- **THEN** a vhost for `v2.studio-mint.shop` SHALL exist with `enableACME = true`
  and `forceSSL = true`
- **AND** its `root` SHALL be the v2 package

#### Scenario: The existing vhosts are untouched
- **WHEN** the durer configuration is evaluated
- **THEN** `nuremberg.pimsnel.com`, `pimsnel.com`, `secondbrain.pimsnel.com`,
  `taste.pimsnel.com` and `umami.pimsnel.com` SHALL be unchanged

### Requirement: www redirects to the apex
`www.studio-mint.shop` SHALL answer with a permanent redirect to
`studio-mint.shop` rather than serving a second copy of the page, so there is
one canonical name and one page to maintain.

#### Scenario: A request to www
- **WHEN** `https://www.studio-mint.shop/` is requested
- **THEN** the response SHALL be a 301 to `https://studio-mint.shop/`

#### Scenario: www needs its own certificate
- **WHEN** the vhost is evaluated
- **THEN** it SHALL set `enableACME = true` and `forceSSL = true`, because a
  redirect served over HTTPS needs a certificate for the name redirected from

#### Scenario: Before this change
- **WHEN** the previous generation is considered
- **THEN** `www.studio-mint.shop` SHALL be understood to have had a DNS record
  but no vhost, answering on the default server with a certificate that does
  not match, which is the defect this requirement closes

### Requirement: A content change reaches production through the lock
Updating a static site SHALL be a flake input update followed by a deploy. The
absence of a flake in the site's repository SHALL NOT change this, because the
lock records a revision either way.

#### Scenario: Publishing a content change
- **WHEN** a commit lands on the site repository's default branch
- **THEN** `nix flake update <input>` SHALL be run in mipnix to record the new
  revision in `flake.lock`
- **AND** `rme deploy_remote durer` SHALL then build locally and activate on
  durer
- **AND** the content SHALL NOT appear in production from the commit alone

#### Scenario: Where the repository key is needed
- **WHEN** the input is fetched
- **THEN** SSH access to the private repository SHALL be required on the
  machine running the update and the deploy
- **AND** SHALL NOT be required on durer, because deploy-rs builds locally and
  pushes the realised closure
