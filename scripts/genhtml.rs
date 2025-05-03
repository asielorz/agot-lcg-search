---cargo
[package]
name = "genhtml"
version = "0.1.0"
edition = "2024"
[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
---

use serde::Deserialize;

#[derive(Deserialize)]
struct Card {
    id: String,
    preview_image_url: String,
    name: String,
    card_type: String,
    set: String,
    number: i32,
    traits: Vec<String>,
    rules_text: Option<String>,
}

fn main() {
    let args = std::env::args().collect::<Vec<_>>();

    if args.len() != 4 {
        panic!(
            "Incorrect number of arguments. Arguments are: template cards.json output_directory"
        );
    }
    let template_path = &args[1];
    let cards_json_path = &args[2];
    let output_path = &args[3];

    let template = std::fs::read_to_string(template_path).unwrap();
    let cards_json = std::fs::read_to_string(cards_json_path).unwrap();

    if !std::fs::exists(output_path).unwrap() {
        std::fs::create_dir_all(output_path).unwrap();
    }

    let cards: Vec<Card> = serde_json::from_str(&cards_json).unwrap();

    for card in &cards {
        let title = &card.name;
        let mut description = format!("{} #{}\n{}", card.set, card.number, card.card_type);
        if !card.traits.is_empty() {
            description += " — ";
            description += &card.traits.join(", ");
        }
        if let Some(text) = &card.rules_text {
            description += "\n";
            description += text;
            description = description.replace("\n", " • ");
        }

        let patched = template
            .replace("[[image]]", &card.preview_image_url)
            .replace("[[title]]", title)
            .replace("[[description]]", &description)
            .replace("[[id]]", &card.id);

        let path = format!("{}/{}.html", output_path, card.id);
        std::fs::write(&path, patched).unwrap();
        println!("{}", &path);
    }

    println!("{} cards", cards.len());
}
