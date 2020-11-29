package util;

import java.util.ArrayList;
import java.util.List;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class Position {
	public static List<String> accumulatedCharacterCounts = new ArrayList<String>();
	
	public static void setup(String inputFile) {
		BufferedReader inFile = null;
		try {
			inFile = new BufferedReader(new FileReader(inputFile));
			
			int lines = 0;
			String str;
			while((str = inFile.readLine()) != null) {
				
				try {
					
					if(accumulatedCharacterCounts.isEmpty()) {
						accumulatedCharacterCounts.add(Integer.toString(str.length() + 2));
					}
					else {
						int preCounts = Integer.parseInt(accumulatedCharacterCounts.get(lines-1));
						int temp = preCounts + str.length();
						accumulatedCharacterCounts.add(Integer.toString(temp + 2));
					}
					lines++;
				} catch (NumberFormatException e) {
//					 e.printStackTrace();
				} catch (IndexOutOfBoundsException e) {
//					 e.printStackTrace();
				}
			}
			inFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public int getLineNumber(String CharacterCounts) {
		for(int i=0; i<accumulatedCharacterCounts.size(); i++) {
			try {
				if(Integer.parseInt(accumulatedCharacterCounts.get(i)) > Integer.parseInt(CharacterCounts)) {
					return i+1;
				}
			} catch (NumberFormatException e) {
//				 e.printStackTrace();
			}
		}
		// error
		return -1;
	}
}
