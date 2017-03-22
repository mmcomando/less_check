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

	/*import std.conv;
	string ss="123.312f";
	double d =parse!double(ss);
	writeln(ss);*/

    Tokenizer tokenizer=new Tokenizer(test1);

    while(1){
        tokenizer.popToken();
        auto tok=tokenizer.currentTokenData;
      
        	writeln(tok);
        
        if(tok.token==Token.none)break;
    }

	//writeln("Edit source/app.d to start your project.");
}
