use crate::read_input;

pub fn main() {
    let data = read_input("day01.txt");

    let mut part01 = 0;
    let mut found_basement = false;
    let mut part02 = 1;
    data.chars().for_each(|c| {
        if c == '(' {
            part01 += 1;
        }
        if c == ')' {
            part01 -= 1;
        }

        if !found_basement && part01 != -1 {
            part02 += 1
        } else if !found_basement {
            found_basement = true;
        }
    });

    println!("***DAY 01***\nPart 01: {}\nPart 02: {}", part01, part02);
}
