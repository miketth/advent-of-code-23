import fs from 'fs/promises';

async function readFile(): Promise<string[][]> {
    const data = await fs.readFile('inputs/input', 'utf-8')
    return data
        .split('\n\n')
        .map((lines) => lines.split('\n'))
        .map((lines) => lines.filter((line) => line.length > 0))
        .filter((lines) => lines.length > 0);
}

function isLineMirrored(line: string, mirrorPoint: number): boolean {
    const leftPart = line.slice(0, mirrorPoint);
    const rightPart = line.slice(mirrorPoint);
    const rightReversed = rightPart.split('').reverse().join('');
    const minLineLength = Math.min(leftPart.length, rightPart.length);
    return leftPart.slice(-minLineLength) === rightReversed.slice(-minLineLength);
}

function findVerticalMirrorColumn(block: string[]): number {
    const lineLength = block[0].length;
    for (let mirrorColumn = 1; mirrorColumn < lineLength; mirrorColumn++) {
        if (block.every((line) => isLineMirrored(line, mirrorColumn))) {
            return mirrorColumn;
        }
    }
    return -1;
}

function transpose(block: string[]): string[] {
    const lineLength = block[0].length;
    const newBlock = [];
    for (let i = 0; i < lineLength; i++) {
        newBlock.push(block.map((line) => line[i]).join(''));
    }
    return newBlock;
}

const blocks = await readFile()

let sum = 0;

blocks.forEach((block) => {
    const vertical = findVerticalMirrorColumn(block);
    if (vertical != -1) {
        sum += vertical;
    }

    const horizontal = findVerticalMirrorColumn(transpose(block));
    if (horizontal != -1) {
        sum += horizontal*100;
    }
});

console.log(`First part: ${sum}`);

