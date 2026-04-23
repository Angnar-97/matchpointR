# matchpointR 0.1.0 (resubmission)

## Response to Konstanze Lauseker's review (2026-04-23)

Thank you for the review. Two changes in this resubmission:

1. Wrapped software names ('Chrome', 'JavaScript') in single quotes in
   the `Description` field, per
   <https://contributor.r-project.org/cran-cookbook/description_issues.html#formatting-software-names>.
2. Removed the `LICENSE` file and the `| file LICENSE` clause from the
   `License` field, since the package is released under a plain
   "Apache License (>= 2)" with no additional restrictions, per
   <https://contributor.r-project.org/cran-cookbook/description_issues.html#license-files>.

No other changes.

## Test environments

- local Windows 11, R 4.5.1
- GitHub Actions: ubuntu-latest / windows-latest / macos-latest,
  R release + devel

## R CMD check results

0 errors, 0 warnings, 1 note.

The single note is the standard "New submission" notice with the
maintainer email on file.

## Notes

- This is a first release.
- All examples that touch the network are wrapped in
  `@examplesIf interactive()` and therefore do not run during CRAN
  checks.
- Tests run against local HTML fixtures in `tests/testthat/fixtures/`
  and do not require network access or a working headless browser.
- `chromote` is listed in `Imports` because the user-facing scraper
  entry points need it. Parsing helpers (the internal `.parse_*`
  family) operate purely on `xml_document` objects and are exercised
  without a browser.

## Author

Alejandro Navas González (Angnar).
