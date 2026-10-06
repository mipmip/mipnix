# Tasks

Schema source: https://github.com/speclib/openspec-tinychange-schema

## 1. Implementation

- [x] 1.1 Add `(google-fonts.override { fonts = [ "Hind" ]; })` to `fontsList` in `modules/programs/desktop/utils/fonts.nix`

## 2. Verification

- [x] 2.1 Built `/nix/store/9574mhnd7iz546h9jmzzz68007ljsm73-google-fonts-...`: 1.4M holding exactly Hind-Light, Hind-Regular, Hind-Medium, Hind-SemiBold and Hind-Bold, with no Siliguri, Madurai, Guntur, Vadodara, Jalandhar, Kochi, Colombo or Mysuru sibling. The same store path appears in `config.fonts.packages`
- [x] 2.2 `fc-query` reports family `Hind` across all five files, with styles Light, Regular, Medium, SemiBold and Bold
- [x] 2.3 `system.build.toplevel.drvPath` evaluates for cichorei, doornappel and peterspav; `defaultFonts.sansSerif` is still `[ "Ubuntu" "Vazirmatn" ]`
