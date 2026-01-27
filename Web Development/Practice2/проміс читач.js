"use strict";

const fs = require("fs");

function readFilePromise(filename) {
    return new Promise((resolve, reject) => {
        fs.readFile(filename, "utf8", (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
}

const filename = "test.txt";

readFilePromise(filename)
    .then(content => {
        console.log("Вміст");
        console.log(content);
    })
    .catch(err => {
        console.log(`Помилка "${filename}"`);
    });