use std::path::Path;
use std::{env, fs};
use xdgen::{App, Context, FluentString};

fn main() {
    let ctx = Context::new("i18n", dbg!(env::args().nth(1)).unwrap()).unwrap();
    let app = App::new(FluentString("cosmic-app-library"))
        .comment(FluentString("app-comment"))
        .keywords(FluentString("app-keywords"));

    let desktop_entry = app
        .expand_desktop("data/com.system76.CosmicAppLibrary.desktop", &ctx)
        .unwrap();
    let metainfo = app
        .expand_metainfo("data/com.system76.CosmicAppLibrary.metainfo.xml", &ctx)
        .unwrap();

    let output = Path::new("target/xdgen/");
    fs::create_dir_all(output).unwrap();
    fs::write(
        output.join("com.system76.CosmicAppLibrary.desktop"),
        desktop_entry,
    )
    .unwrap();
    fs::write(
        output.join("com.system76.CosmicAppLibrary.metainfo.xml"),
        metainfo,
    )
    .unwrap();
}
