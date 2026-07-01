# Practice 1 — Employee Payroll Calculator

## Context

You are building a set of utility functions for an HR payroll system. Each function handles one specific calculation or report that a real payroll department performs every week: computing gross pay, determining tax brackets, calculating net pay, formatting pay slips, and analysing payroll data across a team.

All the logic lives in a single file. Your job is to replace every `TODO()` with a working implementation.

## Getting started

**Prerequisites:** JDK 21 and an internet connection (Gradle downloads dependencies automatically).

Clone the repository and open it in IntelliJ IDEA. The IDE will import the Gradle project automatically. Alternatively, build from the terminal:

```bash
./gradlew build
```

## Your task

Open `src/main/kotlin/ukma/kotlin/practice1/PayrollCalculator.kt`. You will find:

- A block of **constants** at the top — use them in your implementations, never hard-code the raw values.
- **9 function stubs**, each with a doc comment that describes the exact expected behaviour.

Replace each `= TODO()` with a correct implementation. Do not change function signatures, constant names, or the package declaration.

## Functions to implement

| # | Function | What it does |
|---|---|---|
| 1 | `calculateGrossPay` | Weekly gross pay with overtime rule |
| 2 | `getTaxBracket` | Classifies gross pay as `"LOW"`, `"MID"`, or `"HIGH"` |
| 3 | `calculateNetPay` | Gross minus tax minus a list of deductions |
| 4 | `formatPaySlip` | Formats a multi-line pay slip string |
| 5 | `isEligibleForBonus` | Checks three bonus eligibility conditions |
| 6 | `findTopEarners` | Returns the set of IDs with the highest pay (handles ties) |
| 7 | `countAboveThreshold` | Counts employees earning strictly above a threshold |
| 8 | `getTotalPayroll` | Sums all gross pays in the payroll map |
| 9 | `groupByTaxBracket` | Groups employee IDs by their bracket |

### Constants

```kotlin
const val OVERTIME_THRESHOLD  = 40.0   // hours
const val OVERTIME_MULTIPLIER = 1.5

const val LOW_BRACKET_LIMIT   = 500.0  // gross pay boundaries
const val HIGH_BRACKET_LIMIT  = 2000.0

const val LOW_TAX_RATE        = 0.10   // 10 %
const val MID_TAX_RATE        = 0.20   // 20 %
const val HIGH_TAX_RATE       = 0.30   // 30 %

const val BONUS_MIN_HOURS     = 35.0
const val BONUS_MIN_SCORE     = 8
const val BONUS_MIN_GROSS     = 500.0
```

### Function details

#### 1. `calculateGrossPay(hoursWorked: Double, hourlyRate: Double): Double`

Hours up to and including `OVERTIME_THRESHOLD` are paid at the regular rate. Hours beyond the threshold are paid at `hourlyRate × OVERTIME_MULTIPLIER`.

```
calculateGrossPay(40.0, 20.0) → 800.0   // no overtime
calculateGrossPay(45.0, 20.0) → 950.0   // 40×20 + 5×20×1.5
```

#### 2. `getTaxBracket(grossPay: Double): String`

Returns one of three string literals based on gross pay. Boundaries are **inclusive** on the upper end of each bracket.

```
grossPay ≤ 500.0          → "LOW"
500.0 < grossPay ≤ 2000.0 → "MID"
grossPay > 2000.0          → "HIGH"
```

Hint: use a `when` expression.

#### 3. `calculateNetPay(grossPay: Double, deductions: List<Double>): Double`

```
net = grossPay − (grossPay × taxRate) − sum(deductions)
```

The tax rate comes from `getTaxBracket`. If `deductions` is empty, treat the sum as `0.0`. The result can be negative.

```
calculateNetPay(1000.0, listOf(50.0, 25.0)) → 725.0   // 1000 − 200 − 75
calculateNetPay(3000.0, listOf(100.0))      → 2000.0  // 3000 − 900 − 100
```

#### 4. `formatPaySlip(employeeId: String, employeeName: String?, grossPay: Double, netPay: Double): String`

Returns a 6-line string with no leading or trailing blank lines. If `employeeName` is `null`, display `"N/A"`. Amounts must be formatted to exactly 2 decimal places.

```
=== Pay Slip ===
Employee ID: E001
Employee Name: Alice Smith
Gross Pay: $950.00
Net Pay: $760.00
================
```

#### 5. `isEligibleForBonus(grossPay: Double, hoursWorked: Double, performanceScore: Int): Boolean`

Returns `true` only when **all three** conditions hold (every comparison is inclusive `≥`):

- `grossPay >= BONUS_MIN_GROSS`
- `hoursWorked >= BONUS_MIN_HOURS`
- `performanceScore >= BONUS_MIN_SCORE`

#### 6. `findTopEarners(payroll: Map<String, Double>): Set<String>`

The keys in `payroll` are employee IDs; the values are gross pays. Returns the set of all IDs whose gross pay equals the maximum. Returns an empty set for an empty map.

```
findTopEarners(mapOf("E1" to 2000.0, "E2" to 2000.0, "E3" to 1000.0))
    → setOf("E1", "E2")   // tie — both included
```

#### 7. `countAboveThreshold(payroll: Map<String, Double>, threshold: Double): Int`

Counts entries whose value is **strictly greater than** `threshold`. Equality does not count. Returns `0` for an empty map.

#### 8. `getTotalPayroll(payroll: Map<String, Double>): Double`

Returns the sum of all values in `payroll`. Returns `0.0` for an empty map.

#### 9. `groupByTaxBracket(payroll: Map<String, Double>): Map<String, List<String>>`

Groups employee IDs (keys) by the tax bracket of their gross pay (value). Brackets with no employees must be **absent** from the result — do not include them as empty lists.

```
groupByTaxBracket(mapOf("E1" to 400.0, "E2" to 1000.0, "E3" to 3000.0))
    → mapOf("LOW" to listOf("E1"), "MID" to listOf("E2"), "HIGH" to listOf("E3"))

groupByTaxBracket(mapOf("E1" to 200.0, "E2" to 300.0))
    → mapOf("LOW" to listOf("E1", "E2"))   // "MID" and "HIGH" are absent
```

## Running the tests

```bash
./gradlew test
```

Before you implement anything, every test fails with `NotImplementedError` — that is expected. Your goal is to make **all tests pass**.

```
> Task :test FAILED
68 tests completed, 68 failed   ← expected starting state
```

```
> Task :test
BUILD SUCCESSFUL                ← target state
```

You can also run tests from inside IntelliJ IDEA by clicking the green arrow next to the test class or individual test method.

## Rules

- Implement your solutions only inside `PayrollCalculator.kt`.
- Do not modify the test file or any build configuration.
- Use the provided constants — do not hard-code `40.0`, `0.10`, `500.0`, etc.
- Only language features from Lecture 1 are needed: variables, basic types, functions, `if`/`when`/loops, null safety, string templates, and collections.
