package edu.ukma.kotlin.practice1

// Payroll constants — use these in your implementations, do not hard-code the values.
const val OVERTIME_THRESHOLD = 40.0
const val OVERTIME_MULTIPLIER = 1.5
const val LOW_BRACKET_LIMIT = 500.0
const val HIGH_BRACKET_LIMIT = 2000.0
const val LOW_TAX_RATE = 0.10
const val MID_TAX_RATE = 0.20
const val HIGH_TAX_RATE = 0.30
const val BONUS_MIN_HOURS = 35.0
const val BONUS_MIN_SCORE = 8
const val BONUS_MIN_GROSS = 500.0

/**
 * Calculates an employee's gross pay for the week.
 *
 * - Hours up to and including [OVERTIME_THRESHOLD] are paid at [hourlyRate].
 * - Hours beyond [OVERTIME_THRESHOLD] are paid at [hourlyRate] × [OVERTIME_MULTIPLIER].
 *
 * Example: calculateGrossPay(45.0, 20.0) = 40 × 20 + 5 × 20 × 1.5 = 950.0
 */
fun calculateGrossPay(hoursWorked: Double, hourlyRate: Double): Double {
    return if (hoursWorked <= OVERTIME_THRESHOLD) {
        hoursWorked * hourlyRate
    } else {
        OVERTIME_THRESHOLD * hourlyRate + (hoursWorked - OVERTIME_THRESHOLD) * hourlyRate * OVERTIME_MULTIPLIER
    }
}

/**
 * Returns the tax bracket for the given gross pay.
 *
 * - grossPay <= [LOW_BRACKET_LIMIT]  → "LOW"
 * - [LOW_BRACKET_LIMIT] < grossPay <= [HIGH_BRACKET_LIMIT]  → "MID"
 * - grossPay > [HIGH_BRACKET_LIMIT]  → "HIGH"
 *
 * Hint: use a `when` expression.
 */
fun getTaxBracket(grossPay: Double): String {
    when (grossPay) {
        in Double.NEGATIVE_INFINITY..LOW_BRACKET_LIMIT -> return "LOW"
        in (LOW_BRACKET_LIMIT + 0.01)..HIGH_BRACKET_LIMIT -> return "MID"
        else -> return "HIGH"
    }
}

/**
 * Calculates net pay after deducting tax and additional deductions.
 *
 * Tax rates: LOW → [LOW_TAX_RATE], MID → [MID_TAX_RATE], HIGH → [HIGH_TAX_RATE].
 * Formula: grossPay − (grossPay × taxRate) − sum(deductions)
 *
 * Example: calculateNetPay(1000.0, listOf(50.0, 25.0)) = 1000 − 200 − 75 = 725.0
 */
fun calculateNetPay(grossPay: Double, deductions: List<Double>): Double {
    when (getTaxBracket(grossPay)) {
        "LOW" -> return grossPay - (grossPay * LOW_TAX_RATE) - deductions.sum()
        "MID" -> return grossPay - (grossPay * MID_TAX_RATE) - deductions.sum()
        "HIGH" -> return grossPay - (grossPay * HIGH_TAX_RATE) - deductions.sum()
        else -> throw IllegalStateException("Invalid tax bracket")
    }
}

/**
 * Formats a pay slip as a multi-line string.
 *
 * - If [employeeName] is null, display "N/A".
 * - [grossPay] and [netPay] must be formatted to 2 decimal places.
 *
 * Expected output format (6 lines, no leading/trailing blank lines):
 * ```
 * === Pay Slip ===
 * Employee ID: <id>
 * Employee Name: <name or N/A>
 * Gross Pay: $<gross formatted to 2 dp>
 * Net Pay: $<net formatted to 2 dp>
 * ================
 * ```
 */
fun formatPaySlip(employeeId: String, employeeName: String?, grossPay: Double, netPay: Double): String {
    // Display "N/A" when name is null or empty, otherwise show the provided name
    val displayName = if (employeeName.isNullOrEmpty()) "N/A" else employeeName

    var finalString = ""
    finalString += "=== Pay Slip ===\n" +
                    "Employee ID: $employeeId\n" +
                    "Employee Name: $displayName\n" +
                    "Gross Pay: $${"%.2f".format(grossPay)}\n" +
                    "Net Pay: $${"%.2f".format(netPay)}\n" +
                    "================"

    return finalString
}

/**
 * Returns true if the employee meets all bonus eligibility criteria (all conditions inclusive):
 * - grossPay >= [BONUS_MIN_GROSS]
 * - hoursWorked >= [BONUS_MIN_HOURS]
 * - performanceScore >= [BONUS_MIN_SCORE]
 */
fun isEligibleForBonus(grossPay: Double, hoursWorked: Double, performanceScore: Int): Boolean {
    return grossPay >= BONUS_MIN_GROSS && hoursWorked >= BONUS_MIN_HOURS && performanceScore >= BONUS_MIN_SCORE
}

/**
 * Returns the set of employee IDs with the highest gross pay in [payroll].
 *
 * - Returns an empty set if [payroll] is empty.
 * - All employees tied for the maximum are included.
 *
 * Example: findTopEarners(mapOf("E1" to 2000.0, "E2" to 2000.0, "E3" to 1000.0)) = setOf("E1", "E2")
 */
fun findTopEarners(payroll: Map<String, Double>): Set<String> {
    if (payroll.isEmpty()) return emptySet()

    val maxGrossPay = payroll.values.maxOrNull() ?: return emptySet()
    return payroll.filter { it.value == maxGrossPay }.keys.toSet()
}

/**
 * Counts the number of employees with gross pay strictly greater than [threshold].
 *
 * - Equality does NOT count (strictly greater than).
 * - Returns 0 for an empty map.
 */
fun countAboveThreshold(payroll: Map<String, Double>, threshold: Double): Int {
    if (payroll.isEmpty()) return 0

    return payroll.filter(predicate = { it.value > threshold }).count()
}

/**
 * Returns the total payroll cost (sum of all gross pays in [payroll]).
 *
 * Returns 0.0 for an empty map.
 */
fun getTotalPayroll(payroll: Map<String, Double>): Double {
    if (payroll.isEmpty()) return 0.0

    return payroll.values.reduce(Double::plus)
}

/**
 * Groups employee IDs by their tax bracket.
 *
 * - Keys are bracket names: "LOW", "MID", "HIGH".
 * - Brackets with no employees are absent from the result (not present as empty lists).
 * - Employee IDs appear in the same order as their map iteration order.
 *
 * Example: groupByTaxBracket(mapOf("E1" to 400.0, "E2" to 1000.0))
 *          = mapOf("LOW" to listOf("E1"), "MID" to listOf("E2"))
 */
fun groupByTaxBracket(payroll: Map<String, Double>): Map<String, List<String>> {
    return payroll.entries.groupBy(
        keySelector = { getTaxBracket(it.value) },
        valueTransform = { it.key }
    )
}
