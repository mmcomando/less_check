import std.stdio;


import tokenizer;
import ast_check;
void main()
{

string test1="
@base:#f04615;

@width:0.5; .class { width: percentage(@width); // returns `50%`color: saturate(@base, 5%); background-color: spin(lighten(@base, 25%), 8);

}



/* One hell of a block style comment! */@var: red; // Get in line!

@var: white;﻿


";


    /*Tokenizer tokenizer=new Tokenizer(test1);

    while(1){
        tokenizer.popToken();
        auto tok=tokenizer.currentTokenData;
      
        	writeln(tok);
        
        if(tok.token==Token.none)break;
    }*/

	AstCheck ast=new AstCheck(test1);
	try{
		ast.check();
	}catch(Exception e){
		writeln(e);
	}
}
