# Changelog
All notable changes to `iac-pkr-aws-cloudtrain-harbor` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - YYYY-MM-DD
### Added
### Changed
### Fixed

## [3.1.0] - 2023-12-27
### Added
- Added reference to CodeBuild Build ID to AMI tags
### Changed
- Changed versioning schema to allow multiple builds on the same git commit by adding the build number to the fully qualified version
- Updated AMI tags referring to AMI maintainer
- Consolidated CodeBuild build specification

## [3.0.2] - 2023-12-21
### Fixed
- Moved templates for Harbor configuration files to /opt/harbor/tpl since /tmp folder does not survive reboots

## [3.0.1] - 2023-12-20
### Fixed
- Pull of Harbor images is running in quiet mode node now to avoid log spamming

## [3.0.0] - 2023-12-20
### Changed
- Upgraded OS to Amazon Linux 2023
- Replaced package manager yum with new default dnf
- Upgraded Docker Compose to version v2.23.3
- Upgraded Harbor to version v2.10.0 

## [2.1.1] - 2023-10-12
### Changed
- Prepare step of harbor installation works now after the harbor configuration was updated to version 2.9.0

## [2.1.0] - 2023-10-11
### Changed
- Upgraded Harbor version to v2.9.0

## [2.0.0] - 2023-10-11
### Changed
- Added CodeBuild build
