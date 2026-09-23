## MODIFIED Requirements

### Requirement: Complete host list from the registry

The picker's host list SHALL be baked at build time from `self.lib.nebulaHosts`
(derived from `flake.nebulaNodes`) and SHALL include every active nebula node —
both servers and laptops — with no runtime certificate decryption.

#### Scenario: Servers and laptops both listed

- **WHEN** the picker is opened
- **THEN** the list SHALL include the server nodes (`durer`, `dapperehaan`, `hurry`,
  `harry`) and the laptop nodes (`lavendel`, `cichorei`, `zonnehoed`, `doornappel`)

#### Scenario: Picking doornappel from another laptop

- **WHEN** the user opens the picker on `cichorei` and selects `doornappel`
- **THEN** a `doornappel` window SHALL be opened in the `nebula-prive` session
  running `ssh pim@192.168.100.15`

#### Scenario: Non-mesh hosts excluded

- **WHEN** the picker is opened
- **THEN** the list SHALL NOT include hosts absent from `flake.nebulaNodes`
  (e.g. `peterspav`, whose nebula role is disabled, or `_lego2`, excluded from the
  module tree)
