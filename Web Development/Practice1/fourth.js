function countCharacters(str) {
    const counts = {};

    for (let char of str) {
        if (counts[char]) {
            counts[char] += 1;
        } else {
            counts[char] = 1;
        }
    }

    return counts;
}

const input = "web development awawawawawawawaw";
const result = countCharacters(input);

console.log(result);