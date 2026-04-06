`bus memo add` creates accountant memorandum postings as ordinary journal rows with visible `MU-*` numbering. The command is meant for manual bookkeeping adjustments and other memorandum-style entries where the operator wants a first-class workflow instead of building low-level `bus journal add` calls and voucher numbering rules manually.

The command prints the allocated memorandum voucher number on success. The posting itself still lands in the ordinary journal. That means the result participates in balances, reports, and audit traces exactly like any other journal posting.
For the exact add syntax and flag list, run `bus memo add --help`.

Typical usage looks like this:

```bash
bus memo add \
  --date 2025-01-10 \
  --desc "Year-end adjustment" \
  --debit 1000=125.00 \
  --credit 3000=125.00
```

If one memorandum row needs its own explanation, add it directly on the posting token as `ACCOUNT=AMOUNT=ROW_DESCRIPTION`. When the row description contains spaces or punctuation-like text, quote the whole token:

```bash
bus memo add \
  --date 2025-01-10 \
  --desc "Opening balance correction" \
  --debit '2200=3.90=Counter-entry for verified bank-opening corrections' \
  --credit '1910=3.90=Correct OP Päätili / ...846 opening'
```

The first memorandum in the workspace prints `MU-1`, the next `MU-2`, and so on. The numbering is global across existing journal rows that already use the `MU-*` visible voucher series.

`bus memo add` also forwards optional source metadata into the journal posting. You can use the same shorthand style that other Bus bookkeeping commands support:

```bash
bus memo add \
  --date 2025-01-10 \
  --desc "Invoice correction" \
  --debit 1700=24.00 \
  --credit 3000=24.00 \
  --source-object s6203 \
  --source-entry 1 \
  --source-link b24889
```

That shorthand is normalized into canonical stored source references in the journal. The memorandum workflow also stores `source_voucher` metadata with `context=memo` and `number=MU-*`.

Supported add flags are `--date`, `--desc` / `--description`, repeatable `--debit ACCOUNT=AMOUNT` or `ACCOUNT=AMOUNT=ROW_DESCRIPTION`, repeatable `--credit ACCOUNT=AMOUNT` or `ACCOUNT=AMOUNT=ROW_DESCRIPTION`, `--dry-run`, `--source-id`, `--source-object`, `--source-kind`, `--source-entry`, `--source-system`, repeatable `--source-link`, `--external-source-ref`, repeatable `--dim`, and `--allow-create`.

For the exact command-local syntax, `bus memo add --help` and `bus memo add -h` both print the add-specific help text.
