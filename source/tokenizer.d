module tokenizer;
import std.exception;
import std.stdio;
import std.string;

immutable char[] endChars=['{','}','['];
immutable char[] whiteChars=['\n',' ','\t'];

enum Token{
    none,
    ch,//cahracter
    str,
    white,
    num,
}

struct TokenData{
    Token token;
    union{
        char ch;
        string str;
        double num;
    }


    string getString(){
        enforce(token==token.str,"Expected string");
        return str;
    }

    char getChar(){
        enforce(token==token.ch,"Expected string");
        return ch;
    }
}

class Tokenizer{
    string orginalData;
    string slice;
    uint line=1;

    TokenData currentTokenData;

    this(string data){
        orginalData=data;
        slice=data;
    }
    Token currentToken(){
        return currentTokenData.token;
    }
    void popToken(){
	Token lastToken=Token.none;
    	while(1){
    		ignoreComments(slice);
    		bool wasWhite=checkWhite(slice);
    		if(wasWhite){
    		
    			lastToken=Token.white;
    			continue;
    		}else if( lastToken==Token.white){
    			currentTokenData.token=Token.white;
    			return;
    		}
    		
    		if(slice.length==0){
    			break;
    		}
    		char ch=slice[0];
	    	slice=slice[1..$];
	    	if(ch>127){
	    		continue;//ignore utf8
	    	}else{
    		currentTokenData.token=Token.ch;
		currentTokenData.ch=ch;
	    		return;
	    	}
    	}
	currentTokenData.token=lastToken;
    }
    
    void ignoreComments(ref string str){
    	ptrdiff_t charsNumToIgnore;
    	if(str.length<2 ){
    		return;
    	}
    	if(str[0..2]=="//"){
		charsNumToIgnore=str.indexOf('\n');    		 
    	}else if(str[0..2]=="/*"){
		charsNumToIgnore=str.indexOf("*/");
		if(charsNumToIgnore!=-1){
			foreach(i,char ch;slice[0..charsNumToIgnore]){
		    		if(ch=='\n'){
		    			line++;
		    		}
	    		}
		}
    	}
    	
    	if(charsNumToIgnore==-1){
		charsNumToIgnore=cast(int)str.length;
	}  
	str=str[charsNumToIgnore..$];    	
    }
    
    bool checkWhite(ref string slice){
    	bool wasWhite=false;
    	foreach(i,char ch;slice){
    		if(ch=='\n'){
    			line++;
    		}
    		if(whiteChars.indexOf(ch)==-1){
    			slice=slice[i..$];
    			return wasWhite;
    		}else{
    			wasWhite=true;
    		}
    	}
    	slice=null;
    	return wasWhite;
    }
    
    bool checkNumber(ref string slice){
    	bool wasWhite=false;
    	foreach(i,char ch;slice){
    		if(ch=='\n'){
    			line++;
    		}
    		if(whiteChars.indexOf(ch)==-1){
    			slice=slice[i..$];
    			return wasWhite;
    		}else{
    			wasWhite=true;
    		}
    	}
    	slice=null;
    	return wasWhite;
    }
     
    void getLineAndCol(ref uint line,ref uint col){
	line=col=0;
	size_t currentCharNum=orginalData.length-slice.length;
	foreach(char ch;orginalData[0..currentCharNum]){
		col++;
		if(ch=='\n'){
			line++;
			col=0;
		}
	}
    }
    string getLine(uint lineSearch){
	uint lineStart,lineEnd,line;
	bool foundStart=false;

	foreach(uint i,char ch;orginalData){
		if(line==lineSearch && foundStart==false){
			foundStart=true;
			lineStart=i;
		}
		if(ch=='\n'){
			line++;
		
			if(foundStart){
				lineEnd=i;
				break;
			}
		}
	}
	return orginalData[lineStart..lineEnd];
    }
    void printError(string msg){
		uint line,col;
		getLineAndCol(line,col);
		string lineString=getLine(line);
		writefln("Error: %s",msg);
		writefln("Line number: %2s, column: %2s. Line:",line,col);
		writeln(lineString );
		foreach(i;0..col){
			write(" ");
		}
		writeln("^");
    }

}
