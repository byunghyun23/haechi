package util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Scanner {
	String json;

	public String createJson(String inputFile) {
		String astFile = inputFile + ".ast";	// Windows
		
		Path path = null;
		byte[] byteData;
		
		try {
			path = Paths.get(astFile);
			byteData = Files.readAllBytes(path);
			
			json = new String(byteData);
			json = json.substring(json.indexOf("{"));
		} catch (IOException e) {
			System.out.println("Processing in Linux..");
			
			astFile = inputFile + "_json.ast";	// Linux
			
			try {
				path = Paths.get(astFile);
				byteData = Files.readAllBytes(path);
				
				json = new String(byteData);
			} catch (IOException ie) {
				ie.printStackTrace();
			}
		}
        
		return json;
	}
}

