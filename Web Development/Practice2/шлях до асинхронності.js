"use strict";

async function foo(x) {
    return x * 2;
}

foo(5).then(r => console.log(r));

// async function main() {
//     let r = await foo(5);
//     console.log(r);
// }
// main();