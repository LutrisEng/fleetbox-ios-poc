# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Created Fleetbox.
- Added lifetime meters for many part odometers, with somewhat arbitrary
  defaults.

### Changed

- Odometers will now be exact if there has been a reading in the past day.
- Shops and tire sets can now be added from the picker.

### Fixed

- The "Part Odometers" now only appears if there are part odometers to show.
- The "Capture Image" button now no longer appears if a camera is not available.
  Previously, this button would crash the app if pressed with no camera
  available.
- Sorting of line items should now work consistently.
