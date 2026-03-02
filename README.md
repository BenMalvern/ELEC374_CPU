## Design Decisions

### Phase 1
- Used a **priority encoder (32-to-5)** feeding into a **32-to-1 multiplexer** for the main bus selection.
- Implemented multiplication using **Booth bit-pair recoding**, producing a 64-bit product with:
  - **LO register** holding the lower 32 bits (quotient for division, product lower half for multiplication)
  - **HI register** holding the upper 32 bits (remainder for division, product upper half for multiplication)
- Implemented division using **non-restoring division**, with:
  - **LO register** storing the quotient
  - **HI register** storing the remainder