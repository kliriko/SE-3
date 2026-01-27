const fs = require('fs');

const people = [
    { surname: "Багрянцев", age: 20},
    { surname: "Бублик", age: 20},
    { surname: "Малиновський", age: 69}
];

const json = JSON.stringify(people, null, 2);
fs.writeFileSync("test.json", json, "utf-8");
const fileData = fs.readFileSync("test.json", "utf-8");
const peopleCopy = JSON.parse(fileData);

for (const person of peopleCopy) {
    for (const [key, value] of Object.entries(person)) {
        console.log(`${key}: ${value}`);
    }
}