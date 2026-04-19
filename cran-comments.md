# matchpointR 0.1.0

## Test environments

- local Windows 11, R 4.5.1
- GitHub Actions: ubuntu-latest / windows-latest / macos-latest, R release + devel

## R CMD check results

0 errors, 0 warnings, 1 note.

The single note is the standard "New submission" notice with the maintainer
email on file.

## Notes

- This is a new release (first submission).
- All examples that hit the network are wrapped in `@examplesIf interactive()`.
- Tests run against local HTML fixtures in `tests/testthat/fixtures/` and do
  not require network or a working `chromote` session.
- `chromote` is listed in `Imports` because the scraper entry points
  require a headless Chrome session. Parsing helpers (the internal
  `.parse_*` family) operate purely on `xml_document` objects and can be
  exercised without a browser.

## Author

Alejandro Navas González (Angnar).
