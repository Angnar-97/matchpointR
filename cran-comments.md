# matchpointR 0.1.0 (resubmission #2)

## Response to the second CRAN review

Thank you for the second pass. The reviewer flagged a dangling
`file://LICENSE` reference in `README.md` left behind after the first
resubmission removed the `LICENSE` file (per the previous round's
guidance). Fix in this resubmission:

- Replaced `See [LICENSE](LICENSE)` with a link to the canonical
  upstream license page,
  <https://www.apache.org/licenses/LICENSE-2.0>, in both `README.md`
  and `README.Rmd`. No file URI remains.

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
