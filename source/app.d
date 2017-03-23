import core.exception;
import std.stdio;
import std.file:dirEntries,SpanMode,readText;
import std.algorithm:sort;


import tokenizer;
import ast_check;

void main(string[] args){
	foreach(arg;args[1..$]){
		if(arg=="--help"){
			printHelp();
		}else if(arg=="--test"){
			test();
		}else{
			checkFile(arg);
		}
	}
	debug{
		test();
	}

}

void checkFile(string filePath){
	string content = readText(filePath);
	AstCheck ast=new AstCheck(content);
	try{
		ast.check();
		writeln("Syntax is OK.");
	}catch(Exception e){
		ast.tokenizer.printError(e.msg);
		debug writeln(e);
	}catch(RangeError e){
		ast.tokenizer.printError("Range violation near line.");
	}
}

void printHelp(){
	writeln(
"less_check - program to check less scripts syntax
Usage:
less_check [--help] [--test] [file_list]
--help - displays this help
--test - run internal tests
file_list - files to check syntax, separated by space
");
}
void test(){
	string[] tests=[
		"
@base:#f04615;

@width:0.5; .class { width: percentage(@width); // returns `50%`color: saturate(@base, 5%); background-color: spin(lighten(@base, 25%), 8);

}

@xx:20px;
/* dfsgdfgdfg sdfgsdf gsdfgsdf gsdf gsdf gsdgsdfgsdfgsd */

/* One hell of a block style comment! */@var: red; // Get in line!

@var: white;﻿


",
		"
@base:#f04615;
@width:0.5; 

.class { 
width: percentage(@width); 
ala:asda;
}

@var: red; 

@var: white;﻿

"
	];
	if(0){
		Tokenizer tokenizer=new Tokenizer(tests[0]);	
		tokenizer.printAllTokens();
	}else{
		foreach(i,test;tests){
			AstCheck ast=new AstCheck(test);
			try{
				writeln("----------- ",i," -----------");
				ast.check();
			}catch(Exception e){
				ast.tokenizer.printError(e.msg);
				writeln(e);
			}catch(RangeError e){
				ast.tokenizer.printError("Range violation near line.");
			}
		}
		
		
		string[] files;
		foreach (string testFileName;dirEntries("less_tests", SpanMode.shallow))
		{
			files~=testFileName;
		}
		foreach (i,string testFileName;files.sort)
		{
			writeln(testFileName,": ----------- ",i+1," -----------");
			checkFile(testFileName);
		}
	}
}