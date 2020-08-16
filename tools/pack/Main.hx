package ;

import haxe.Template;
import sys.FileSystem;
import sys.io.File;

class Main{
	private static inline var indexSrc:String = "res/index.html";
	private static inline var scriptSrc:String = "build/404.js";

	private static inline var finalDir:String = "build/final/";
	private static inline var finalUncompressedDir:String = finalDir + "uncompressed/";
	private static inline var finalMinifiedDir:String = finalDir + "min/";
	private static inline var packageFile:String = finalDir + "404.zip";

	public static function main(){
		clean();
		build();
		minify();
		pack();
	} 

	public static function clean(){
		FileSystem.createDirectory(finalUncompressedDir);
		FileSystem.createDirectory(finalMinifiedDir);
		
		function cleanDir(dir){
			
			for (f in FileSystem.readDirectory(dir)) {
				if(!FileSystem.isDirectory(dir + f)) {
					FileSystem.deleteFile(dir + f);
				}
			}
		}
		
		cleanDir(finalMinifiedDir);
		cleanDir(finalUncompressedDir);
		cleanDir(finalDir);
	}

	public static function build(){
		var pageTemplate:String = File.getContent(indexSrc);
		var script:String = File.getContent(scriptSrc);

		var tpl:Template = new Template(pageTemplate);
		var out:String = tpl.execute({src: script});

		File.saveContent(finalUncompressedDir + "index.html", out);
	}

	public static function minify(){
		Sys.command("html-minifier", [
			"--collaspse-boolean-attributes",
			"--collapse-inline-tag-whitespace",
			"--collapse-whitespace",
			"--decode-entities",
			"--html5",
			"--minify-css",
			"--minify-js",
			"--remove-attribute-quotes",
			"--remove-comments",
			"--remove-empty-attributes",
			"--remove-optional-tags",
			"--remove-redundant-attributes",
			"--use-short-doctype",
			"-o", finalMinifiedDir + "index.html",
			finalUncompressedDir + "index.html"]);
	}

	public static function pack(){
		Sys.command("7z", ["a", packageFile, "./" + finalMinifiedDir + "*", "-mx9"]);
		
		var bytes:Int = FileSystem.stat(packageFile).size;
		trace(Std.string(bytes / 1024) + " / 13kb bytes used!");
		trace(Std.string((bytes / 1024) / 0.13) + "%");
	}
}