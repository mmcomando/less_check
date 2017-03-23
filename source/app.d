import core.exception;
import std.stdio;
import std.file:dirEntries,SpanMode,readText;
import std.algorithm:sort;


import tokenizer;
import ast_check;

void main()
{

	string[] tests=[
		"
@base:#f04615;

@width:0.5; .class { width: percentage(@width); // returns `50%`color: saturate(@base, 5%); background-color: spin(lighten(@base, 25%), 8);

}

@xx:20px;


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
			}catch(RangeError e){
				ast.tokenizer.printError("Range violation near line.");
			}
		}

		
		string[] files;
		foreach (string testFileName;dirEntries("less_tests", SpanMode.shallow))
		{
			files~=testFileName;
		}
		foreach (i,string testFileName;files.sort[0..4])
		{
			string content = readText(testFileName);
			AstCheck ast=new AstCheck(content);
			try{
				writeln(testFileName,": ----------- ",i+1," -----------");
				ast.check();
			}catch(Exception e){
				ast.tokenizer.printError(e.msg);
				//writeln(e);
			}catch(RangeError e){
				ast.tokenizer.printError("Range violation near line.");
			}
		}
	}
}

