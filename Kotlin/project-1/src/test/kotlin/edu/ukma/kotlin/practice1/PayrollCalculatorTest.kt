package edu.ukma.kotlin.practice1

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PayrollCalculatorTest {

    // --- calculateGrossPay ---

    @Test
    fun `should return regular pay when hours do not exceed threshold`() {
        assertEquals(600.0, calculateGrossPay(30.0, 20.0))
    }

    @Test
    fun `should return regular pay when hours equal threshold exactly`() {
        assertEquals(800.0, calculateGrossPay(40.0, 20.0))
    }

    @Test
    fun `should apply overtime multiplier for hours beyond threshold`() {
        // 40 × 20 + 5 × 20 × 1.5 = 800 + 150 = 950
        assertEquals(950.0, calculateGrossPay(45.0, 20.0))
    }

    @Test
    fun `should apply overtime for one hour beyond threshold`() {
        // 40 × 10 + 1 × 10 × 1.5 = 400 + 15 = 415
        assertEquals(415.0, calculateGrossPay(41.0, 10.0))
    }

    @Test
    fun `should handle fractional overtime hours`() {
        // 40 × 8 + 2.5 × 8 × 1.5 = 320 + 30 = 350
        assertEquals(350.0, calculateGrossPay(42.5, 8.0))
    }

    @Test
    fun `should return zero gross pay when no hours worked`() {
        assertEquals(0.0, calculateGrossPay(0.0, 25.0))
    }

    @Test
    fun `should return zero gross pay when hourly rate is zero`() {
        assertEquals(0.0, calculateGrossPay(50.0, 0.0))
    }

    @Test
    fun `should apply overtime multiplier for heavy overtime`() {
        // 40 × 25 + 40 × 25 × 1.5 = 1000 + 1500 = 2500
        assertEquals(2500.0, calculateGrossPay(80.0, 25.0))
    }

    @Test
    fun `should calculate gross pay correctly with named arguments`() {
        assertEquals(950.0, calculateGrossPay(hoursWorked = 45.0, hourlyRate = 20.0))
    }

    // --- getTaxBracket ---

    @Test
    fun `should return LOW for gross pay below low limit`() {
        assertEquals("LOW", getTaxBracket(300.0))
    }

    @Test
    fun `should return LOW when gross pay equals low bracket limit`() {
        assertEquals("LOW", getTaxBracket(500.0))
    }

    @Test
    fun `should return MID when gross pay is just above low limit`() {
        assertEquals("MID", getTaxBracket(500.01))
    }

    @Test
    fun `should return MID for gross pay in mid range`() {
        assertEquals("MID", getTaxBracket(1000.0))
    }

    @Test
    fun `should return MID when gross pay equals high bracket limit`() {
        assertEquals("MID", getTaxBracket(2000.0))
    }

    @Test
    fun `should return HIGH for gross pay above high limit`() {
        assertEquals("HIGH", getTaxBracket(3000.0))
    }

    @Test
    fun `should return HIGH when gross pay is just above high limit`() {
        assertEquals("HIGH", getTaxBracket(2000.01))
    }

    @Test
    fun `should return LOW for zero gross pay`() {
        assertEquals("LOW", getTaxBracket(0.0))
    }

    // --- calculateNetPay ---

    @Test
    fun `should apply low tax rate when no deductions`() {
        // 400 → LOW: 400 - 40 - 0 = 360
        assertEquals(360.0, calculateNetPay(400.0, listOf()))
    }

    @Test
    fun `should apply low tax at exact low bracket boundary`() {
        // 500 is LOW: 500 - 50 - 0 = 450
        assertEquals(450.0, calculateNetPay(500.0, listOf()))
    }

    @Test
    fun `should apply mid tax rate and subtract all deductions`() {
        // 1000 → MID: 1000 - 200 - 75 = 725
        assertEquals(725.0, calculateNetPay(1000.0, listOf(50.0, 25.0)))
    }

    @Test
    fun `should apply mid tax at exact high bracket boundary`() {
        // 2000 is MID: 2000 - 400 - 0 = 1600
        assertEquals(1600.0, calculateNetPay(2000.0, listOf()))
    }

    @Test
    fun `should apply high tax rate and subtract single deduction`() {
        // 3000 → HIGH: 3000 - 900 - 100 = 2000
        assertEquals(2000.0, calculateNetPay(3000.0, listOf(100.0)))
    }

    @Test
    fun `should subtract multiple deductions from net pay`() {
        // 500 → LOW: 500 - 50 - 30 = 420
        assertEquals(420.0, calculateNetPay(500.0, listOf(10.0, 20.0)))
    }

    @Test
    fun `should allow negative net pay when deductions exceed after tax amount`() {
        // 400 LOW: 400 - 40 - 500 = -140
        assertEquals(-140.0, calculateNetPay(400.0, listOf(500.0)))
    }

    @Test
    fun `should treat empty deductions list as zero`() {
        // 1000 MID: 1000 - 200 - 0 = 800
        assertEquals(800.0, calculateNetPay(1000.0, listOf()))
    }

    @Test
    fun `should calculate net pay correctly with named arguments`() {
        // 1000 MID: 1000 - 200 - 50 = 750
        assertEquals(750.0, calculateNetPay(grossPay = 1000.0, deductions = listOf(50.0)))
    }

    // --- formatPaySlip ---

    @Test
    fun `should include employee ID in pay slip`() {
        val result = formatPaySlip("E001", "Alice Smith", 950.0, 760.0)
        assertTrue(result.contains("Employee ID: E001"))
    }

    @Test
    fun `should include employee name and formatted amounts in pay slip`() {
        val result = formatPaySlip("E001", "Alice Smith", 950.0, 760.0)
        assertTrue(result.contains("Alice Smith"))
        assertTrue(result.contains("950.00"))
        assertTrue(result.contains("760.00"))
    }

    @Test
    fun `should show NA when employee name is null`() {
        val result = formatPaySlip("E002", null, 800.0, 640.0)
        assertTrue(result.contains("Employee Name: N/A"))
    }

    @Test
    fun `should include header and footer lines in pay slip`() {
        val result = formatPaySlip("E003", "Bob", 400.0, 360.0)
        assertTrue(result.contains("=== Pay Slip ==="))
        assertTrue(result.contains("================"))
    }

    @Test
    fun `should display employee name when it is not null`() {
        val result = formatPaySlip("X2", "John", 100.0, 90.0)
        assertTrue(result.contains("Employee Name: John"))
        assertFalse(result.contains("N/A"))
    }

    @Test
    fun `should format amounts to two decimal places`() {
        val result = formatPaySlip("X3", "Jane", 1000.5, 800.5)
        assertTrue(result.contains("1000.50"))
        assertTrue(result.contains("800.50"))
    }

    @Test
    fun `should include dollar sign before amounts`() {
        val result = formatPaySlip("X4", "Test", 500.0, 450.0)
        assertTrue(result.contains("$500.00"))
        assertTrue(result.contains("$450.00"))
    }

    @Test
    fun `should include all six required lines in pay slip`() {
        val result = formatPaySlip("X5", "Test", 500.0, 450.0)
        assertTrue(result.contains("=== Pay Slip ==="))
        assertTrue(result.contains("Employee ID:"))
        assertTrue(result.contains("Employee Name:"))
        assertTrue(result.contains("Gross Pay:"))
        assertTrue(result.contains("Net Pay:"))
        assertTrue(result.contains("================"))
    }

    // --- isEligibleForBonus ---

    @Test
    fun `should return true when all bonus conditions are met`() {
        assertTrue(isEligibleForBonus(600.0, 38.0, 9))
    }

    @Test
    fun `should return true when all bonus conditions are met exactly at boundary`() {
        assertTrue(isEligibleForBonus(500.0, 35.0, 8))
    }

    @Test
    fun `should return false when performance score is too low`() {
        assertFalse(isEligibleForBonus(600.0, 38.0, 7))
    }

    @Test
    fun `should return false when hours worked are insufficient`() {
        assertFalse(isEligibleForBonus(600.0, 34.0, 9))
    }

    @Test
    fun `should return false when gross pay is too low for bonus`() {
        assertFalse(isEligibleForBonus(400.0, 38.0, 9))
    }

    @Test
    fun `should return false when gross pay is just below minimum`() {
        assertFalse(isEligibleForBonus(499.9, 35.0, 8))
    }

    @Test
    fun `should return false when hours worked are just below minimum`() {
        assertFalse(isEligibleForBonus(500.0, 34.9, 8))
    }

    @Test
    fun `should determine bonus eligibility correctly with named arguments`() {
        assertTrue(isEligibleForBonus(grossPay = 600.0, hoursWorked = 40.0, performanceScore = 10))
    }

    // --- findTopEarners ---

    @Test
    fun `should return set with single top earner`() {
        assertEquals(
            setOf("E2"),
            findTopEarners(mapOf("E1" to 1000.0, "E2" to 2000.0, "E3" to 1500.0))
        )
    }

    @Test
    fun `should return empty set for empty payroll`() {
        assertEquals(emptySet(), findTopEarners(emptyMap()))
    }

    @Test
    fun `should return all employees when all gross pays are tied`() {
        assertEquals(
            setOf("A", "B", "C"),
            findTopEarners(mapOf("A" to 100.0, "B" to 100.0, "C" to 100.0))
        )
    }

    @Test
    fun `should return all tied top earners`() {
        assertEquals(
            setOf("E1", "E2"),
            findTopEarners(mapOf("E1" to 2000.0, "E2" to 2000.0, "E3" to 1000.0))
        )
    }

    @Test
    fun `should return the single employee for a one entry payroll`() {
        assertEquals(setOf("E1"), findTopEarners(mapOf("E1" to 500.0)))
    }

    @Test
    fun `should return both employees in a two way tie`() {
        assertEquals(
            setOf("A", "C"),
            findTopEarners(mapOf("A" to 3000.0, "B" to 1000.0, "C" to 3000.0, "D" to 500.0))
        )
    }

    // --- countAboveThreshold ---

    @Test
    fun `should count employees strictly above threshold`() {
        assertEquals(2, countAboveThreshold(mapOf("E1" to 500.0, "E2" to 1500.0, "E3" to 2500.0), 1000.0))
    }

    @Test
    fun `should not count employees equal to threshold`() {
        assertEquals(0, countAboveThreshold(mapOf("E1" to 1000.0, "E2" to 1000.0), 1000.0))
    }

    @Test
    fun `should return zero for empty payroll map`() {
        assertEquals(0, countAboveThreshold(emptyMap(), 1000.0))
    }

    @Test
    fun `should return zero when no employees are above threshold`() {
        assertEquals(0, countAboveThreshold(mapOf("E1" to 300.0, "E2" to 400.0), 500.0))
    }

    @Test
    fun `should count all employees when all are above threshold`() {
        assertEquals(2, countAboveThreshold(mapOf("E1" to 2000.0, "E2" to 3000.0), 1000.0))
    }

    @Test
    fun `should count employees above a negative threshold`() {
        assertEquals(2, countAboveThreshold(mapOf("E1" to 0.0, "E2" to 100.0), -1.0))
    }

    @Test
    fun `should return zero when threshold exceeds all gross pays`() {
        assertEquals(0, countAboveThreshold(mapOf("E1" to 500.0), 10000.0))
    }

    // --- getTotalPayroll ---

    @Test
    fun `should sum all gross pays in payroll`() {
        assertEquals(3500.0, getTotalPayroll(mapOf("E1" to 1000.0, "E2" to 2000.0, "E3" to 500.0)))
    }

    @Test
    fun `should return zero for empty payroll`() {
        assertEquals(0.0, getTotalPayroll(emptyMap()))
    }

    @Test
    fun `should return zero when all gross pays are zero`() {
        assertEquals(0.0, getTotalPayroll(mapOf("E1" to 0.0, "E2" to 0.0)))
    }

    @Test
    fun `should return the single entry value`() {
        assertEquals(999.99, getTotalPayroll(mapOf("E1" to 999.99)))
    }

    @Test
    fun `should handle a single large gross pay value`() {
        assertEquals(99999.99, getTotalPayroll(mapOf("E1" to 99999.99)))
    }

    @Test
    fun `should sum two entries correctly`() {
        assertEquals(3000.0, getTotalPayroll(mapOf("E1" to 1000.0, "E2" to 2000.0)))
    }

    // --- groupByTaxBracket ---

    @Test
    fun `should group employees into all three brackets`() {
        assertEquals(
            mapOf("LOW" to listOf("E1"), "MID" to listOf("E2"), "HIGH" to listOf("E3")),
            groupByTaxBracket(mapOf("E1" to 400.0, "E2" to 1000.0, "E3" to 3000.0))
        )
    }

    @Test
    fun `should return empty map for empty payroll map`() {
        assertEquals(emptyMap(), groupByTaxBracket(emptyMap()))
    }

    @Test
    fun `should group all employees into single bracket when applicable`() {
        val result = groupByTaxBracket(mapOf("E1" to 200.0, "E2" to 300.0))
        assertEquals(mapOf("LOW" to listOf("E1", "E2")), result)
    }

    @Test
    fun `should only include HIGH bracket when all employees are high earners`() {
        val result = groupByTaxBracket(mapOf("E1" to 2001.0, "E2" to 5000.0))
        assertEquals(mapOf("HIGH" to listOf("E1", "E2")), result)
        assertFalse(result.containsKey("LOW"))
        assertFalse(result.containsKey("MID"))
    }

    @Test
    fun `should group boundary values into correct brackets`() {
        assertEquals(
            mapOf("LOW" to listOf("E1"), "MID" to listOf("E2")),
            groupByTaxBracket(mapOf("E1" to 500.0, "E2" to 2000.0))
        )
    }

    @Test
    fun `should group multiple employees into the same bracket`() {
        assertEquals(
            mapOf("LOW" to listOf("E1", "E2", "E3")),
            groupByTaxBracket(mapOf("E1" to 100.0, "E2" to 200.0, "E3" to 300.0))
        )
    }

    @Test
    fun `should omit brackets that have no employees`() {
        val result = groupByTaxBracket(mapOf("E1" to 400.0))
        assertTrue(result.containsKey("LOW"))
        assertFalse(result.containsKey("MID"))
        assertFalse(result.containsKey("HIGH"))
    }
}
