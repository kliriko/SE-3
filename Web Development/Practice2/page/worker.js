"use strict";

let k = 0;

function work() {
    for (let i = 0; i < 5_000_000; i++) {
        k++;
    }

    postMessage(k);
    setTimeout(work, 200);
}

work();
