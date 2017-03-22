import std.stdio;


import tokenizer;
void main()
{

string test1="
@base:#f04615;

@width:0.5; .class { width: percentage(@width); // returns `50%`color: saturate(@base, 5%); background-color: spin(lighten(@base, 25%), 8);

}



/* One hell of a block style comment! */@var: red; // Get in line!

@var: white;﻿


";

    Tokenizer tokenizer=new Tokenizer(test1);

    while(1){
        tokenizer.popToken();
        auto tok=tokenizer.currentToken();
        if(tok==Token.ch){
        	writeln(tokenizer.currentTokenData.getChar());
        }else{
        	writeln(tok);
        }
        if(tok==Token.none)break;
    }

	//writeln("Edit source/app.d to start your project.");
}
