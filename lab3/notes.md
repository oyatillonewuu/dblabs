### Decimal vs. Float (and Double)

- Decimal data type stores values exactly with each bit.
- Float/Double store values that approximate the original values (computer architecture thing).

### Why some data types (like CHAR) are padded?

Padding is a technique that trades memory off for performance. 
By padding, we can speed up processor by allowing to read in chunks.

Again, Computer Architecture thing.

### LENGTH() vs CHAR_LENGTH()

The first returns byte-by-byte count. The second returns character count.

Ex.: one unicode character may take up several bytes. When we need to count characters, 
using `CHAR_LENGTH` returns what we want. 
However, when we want a byte count, we must use `LENGTH`.
