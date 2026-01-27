function sortDescending(arr) {
    const copy = [...arr];

    copy.sort((a, b) => b - a);

    return copy;
}

const numbers = [5, 2, 9, 1, 7];
const sortedNumbers = sortDescending(numbers);

console.log("Відсортований масив:", sortedNumbers);
