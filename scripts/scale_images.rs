---cargo
[package]
name = "scale_images"
version = "0.1.0"
edition = "2024"
[dependencies]
image = "0.25"
rayon = "1.10"
---

use image::imageops;
use rayon::prelude::*;

fn main() {
    let args = std::env::args().collect::<Vec<_>>();

    if args.len() != 3 {
        panic!(
            "Incorrect number of arguments. Arguments are: input_directory output_directory"
        );
    }
    let input_path = &args[1];
    let output_path = &args[2];

    if !std::fs::exists(output_path).unwrap() {
        std::fs::create_dir_all(output_path).unwrap();
    }

    std::fs::read_dir(input_path).unwrap().par_iter().for_each(|file| {
        let path = file.unwrap().path();
        let out_path = format!("{}/{}", output_path, path.file_name().unwrap().to_string_lossy());

        if !std::fs::exists(&out_path).unwrap() {
            let image = image::ImageReader::open(&path).unwrap().decode().unwrap().into_rgb8();
            let (width, height) = if image.width() > image.height() { (325, 227) } else { (245, 350) };
            println!("{} ({}, {}) -> ({}, {})", path.to_string_lossy(), image.width(), image.height(), width, height);
            let resized = imageops::resize(&image, width, height, imageops::FilterType::CatmullRom);
            
            resized.save_with_format(out_path, image::ImageFormat::Jpeg).unwrap();
        }
    });
}
