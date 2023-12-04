use std::fs::File;
use std::io::{self, BufRead, BufReader};

fn main() -> io::Result<()> {
    let reader = read_file().unwrap();

    let data = reader.lines()
        .map(|line| line.unwrap())
        .filter(|line| !line.trim().is_empty())
        .map(|line| process_line(line));

    let first_sol: u64 = data
        .map(|data| data.get_points())
        .sum();

    println!("First part: {}", first_sol);

    Ok(())
}

// You might not need a separate function now, but if you want to keep it:
fn read_file() -> io::Result<BufReader<File>> {
    let file = File::open("inputs/input")?;
    Ok(BufReader::new(file))
}

#[derive(Debug)]
struct Linedata {
    id: u64,
    winning: Vec<u64>,
    nums: Vec<u64>,
}

fn process_line(line: String) -> Linedata {
    let parts: Vec<String> = line
        .split(": ")
        .map(|part| String::from(part))
        .collect();

    let id = parts[0]
        .replace("Card ", "")
        .replace(" ", "")
        .parse::<u64>()
        .unwrap();

    let rest_parts: Vec<String> = parts[1]
        .split(" | ")
        .map(|part| String::from(part))
        .collect();
    let winning: Vec<u64> = parse_num_list(&rest_parts[0]);
    let nums: Vec<u64> = parse_num_list(&rest_parts[1]);

    Linedata { id, winning, nums }
}

fn parse_num_list(list_str: &String) -> Vec<u64> {
    return list_str
        .split(" ")
        .filter(|num_str| !num_str.trim().is_empty())
        .map(|num| num.parse::<u64>())
        .map(|num| num.unwrap())
        .collect()
}

impl Linedata {
    fn get_winning_nums(&self) -> Vec<u64> {
        self.nums.iter()
            .filter(|&num| self.winning.contains(num))
            .map(|&num| num)
            .collect()
    }

    fn get_points(&self) -> u64 {
        let wins = self.get_winning_nums().len();
        if wins == 0 {
            0
        } else {
            2_u64.pow((wins - 1) as u32)
        }
    }
}