function findMaxProcedural(arr) {
    if (arr.length === 0) {
        return undefined;
    }

    let max = arr[0];
    for (let i = 1; i < arr.length; i++) {
        if (arr[i] > max) {
            max = arr[i];
        }
    }
    return max;
}

function findMaxFunctional(arr) {
    if (arr.length === 0) {
        return undefined;
    }

    return arr.reduce((max, current) => (current > max ? current : max), arr[0]);
}

const numbers1 = [4, 3, 2, 1];
console.log(findMaxProcedural(numbers1));


const numbers2 = [4, 3, 2, 1];
console.log(findMaxFunctional(numbers2));
