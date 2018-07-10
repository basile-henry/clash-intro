% Introduction to CλaSH
% Basile Henry
% July 9th, 2018

# CλaSH

## Compile Haskell

From Haskell to Hardware

![](lambda-chip.svg){ width=30% border=0 }

## Generate `HDL`

- `VHDL`
- `Verilog`
- `SystemVerilog`

::: notes
  - Hardware Description Language
:::

## Command line interface

- Similar to `ghc`
  ```sh
  $ clash --vhdl -isrc src/Top.hs
  ```

- REPL like `ghci`
  ```sh
  $ clashi -isrc src/Top.hs
  # Or clash --interactive ...
  ```

- Haskell packages from `ghc-pkg`

# Signals

## Signal Type

```haskell
data Signal a = a :- Signal a

data List a
  = a : List a
  | []
```

*Pseudocode definitions*

::: notes
  - Signal is like a Stream of values with one value per clock cycle

  - Difference with List is that it doesn't terminate

  - `domain` is there to ensure we don't mix Signals from multiple domain

  - We often see constraints over the domain (`clk`, `reset`)
:::

## Applicative Signals

Functor
```haskell
fmap :: (a -> b) -> Signal domain a -> Signal domain b
```

Applicative
```haskell
pure :: a -> Signal domain a

<*>
  :: Signal domain (a -> b)
  -> Signal domain a
  -> Signal domain b
```

::: notes
  - Combinational logic / combinatorial circuit

  - Happens in 1 clock cycles and cannot depend on previous values of the Signal
:::

## Registers

```haskell
register
  :: (...)
  => a
  -> Signal domain a
  -> Signal domain a
```

::: notes
  - Sequential logic / synchronous circuit

  - Used with a feedback loop to store a value or as a delay function
:::

## Registers

Example

```haskell
counter = x
  where
    x = register 0 (x + 1)
```

```haskell
> sampleN 5 counter
[0,1,2,3,4]
```

::: notes
  - Using recursion to encode feedback
:::

## Mealy machines

```haskell
mealy
  :: (...)
  => (state -> input -> (state, output))
  -> state
  -> Signal domain input
  -> Signal domain output
```

::: notes
  - Finite State machines

  - Can be created from a register, it's mainly a helper function

  - Mention Moore and Medvedev
:::

## Mealy machines

Example
```haskell
accumulate = mealy accumulate' 0
  where
    accumulate' acc x = (acc + x, acc)
```

```haskell
> Prelude.take 6 $ simulate accumulate [0, 1, 2, 3, 4]
[0,0,1,3,6,10]
```

## Multiple Signals

For pairs
```haskell
bundle
  :: (Signal domain a, Signal domain b)
  -> Signal domain (a, b)

unbundle
  :: Signal domain (a, b)
  -> (Signal domain a, Signal domain b)
```

::: notes
  - Free in terms of hardware since they are equivalent
  - Works for any tuple sizes (within GHC tuple limits) and Vec
    (among other types)
:::

## Clocks and Resets

```haskell
f :: Clock domain gated
  -> Reset domain synchronous
  -> ...
```

```haskell
f :: ( HiddenClock domain gated
     , HiddenReset domain synchronous
     )
  => ...

...
  withClockReset clk rst f
```

::: notes
  - Explicit / Implicit
  - Implicit routing makes it easier to connect circuits but doesn't allow
    clocks and resets from multiple domains to be in scope
:::

## Clocks and Resets

With the default `System` domain
```haskell
f :: HiddenClockReset System 'Source 'Asynchronous
  => ...
```

```haskell
f :: SystemClockReset
  => ...
```

# Interacting with the outside

## Top Entity

```haskell
main :: IO ()
```

```haskell
topEntity
  :: SystemClockReset
  => Signal System Bool
  -> Signal System Int
```

- Monomorphic
- `HDL` inputs/outputs can be controlled via `ANN` *pragmas*

::: notes
  - `topEntity` is the main entry point.
  - There can be several top entities (pragma required)
  - Clock and Reset not necessary (for combinational circuits)
:::

## Test Benches

- Unit test for hardware
- Hardware accurate simulation

```haskell
testBench :: Signal System Bool
testBench = ...
  where
    -- input generator
    stimuliGenerator

    -- output checker
    outputVerifier
```

::: notes
  - Use special clocks and resets
:::

## Primitives

Use `HDL` to implement the hardware
```haskell
{-# LANGUAGE MagicHash #-}

{-# NOINLINE myPrimitive# #-}
myPrimitive#
  :: Clock domain gated
  -> Reset domain synchronous
  -> ...
myPrimitive# =
  ... -- Implementation to run circuit in Haskell
```

The actual `HDL` implementation is described in a `JSON` file to easily swap
the hardware language used.

# Number Representation

##

Usual Haskell number types

```haskell
data Int

data Float
```

Hardware types with bit-width specified

```haskell
data BitVector n

data Unsigned n

data Signed n

data Index n

data Fixed rep int frac
```

::: notes
  - More Haskell types (`Word8`, `Word16`)
  - `Int` is `64` bits, `Integer` also supported-ish
  - `Float` is behind a floag

  - Number of bits for the hardware representation.
  - `Integer` under the hood, so not fast on CPU
  - Two's complement
:::

## `Num` instance for `Signal`

```haskell
add
  :: Signal domain Int
  -> Signal domain Int
  -> Signal domain Int
add x y = x + y
```

*Please don't use it!*

```haskell
add = liftA2 (+)
```

# Vector Type

##

```haskell
data Vec n a
```

::: notes
  - Size is encoded in the type
:::

# Questions?
