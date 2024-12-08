pub mod day01;

pub fn read_input(file_name: &str) -> String {
    let file_path = format!("data/{file_name}");
    std::fs::read_to_string(file_path).expect("Problem reading from file")
}
