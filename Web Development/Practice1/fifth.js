function sortString(str) {
    return str.split('').sort((a, b) => a.localeCompare(b)).join('');
}

function findAnagrams(words) {
    const anagramMap = {};

    for (const word of words) {
        const key = sortString(word);
        if (anagramMap[key]) {
            anagramMap[key].push(word);
        } else {
            anagramMap[key] = [word];
        }
    }

    for (const key in anagramMap) {
        if (anagramMap[key].length >= 2) {
            console.log(anagramMap[key].join(' – '));
        }
    }
}

const dictionary = [
    'автор', 'товар', 'тавро',
    'літо', 'тіло',
    'кума', 'мука', 'умка',
    'яблуко', 'банан'
];

findAnagrams(dictionary);
