import fs from 'fs/promises';

async function readFile(): Promise<string[][]> {
    const data = await fs.readFile('inputs/input', 'utf-8')
    return data
        .split('\n\n')
        .map((lines) => lines.split('\n'))
        .map((lines) => lines.filter((line) => line.length > 0))
        .filter((lines) => lines.length > 0);
}

function lineMirrorErrors(line: string, mirrorPoint: number): number {
    const leftPart = line.slice(0, mirrorPoint);
    const rightPart = line.slice(mirrorPoint);
    const rightReversed = rightPart.split('').reverse().join('');
    const minLineLength = Math.min(leftPart.length, rightPart.length);

    const leftCut = leftPart.slice(-minLineLength);
    const rightCut = rightReversed.slice(-minLineLength);

    let diff = 0;
    for (let i = 0; i < minLineLength; i++) {
        if (leftCut[i] != rightCut[i]) {
            diff++;
        }
    }
    return diff;
}

function findVerticalMirrorColumnWithError(block: string[], error = 0): number {
    const lineLength = block[0].length;
    for (let mirrorColumn = 1; mirrorColumn < lineLength; mirrorColumn++) {
        let sumErrors = block.reduce((sum, line) => sum + lineMirrorErrors(line, mirrorColumn), 0);

        if (sumErrors == error) {
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

function getScoreSumWithErrorCount(blocks: string[][], errors = 0): number {
    let sum = 0;
    blocks.forEach((block) => {
        const vertical = findVerticalMirrorColumnWithError(block, errors);
        if (vertical != -1) {
            sum += vertical;
        }

        const horizontal = findVerticalMirrorColumnWithError(transpose(block), errors);
        if (horizontal != -1) {
            sum += horizontal*100;
        }
    });
    return sum;
}

const blocks = await readFile()

const firstPart = getScoreSumWithErrorCount(blocks);

console.log(`First part: ${firstPart}`);

const secondPart = getScoreSumWithErrorCount(blocks, 1);

console.log(`Second part: ${secondPart}`);
