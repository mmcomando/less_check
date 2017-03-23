module tokenizer;
import std.exception;
import std.stdio;
import std.string;
import std.conv;
import std.ascii;

immutable char[] endChars="(){}[];";
immutable char[] whiteChars=['\n',' ','\t'];

enum Token{
	none,
	ch,//cahracter
	str,
	white,
	num,
	var,
	pixels,
	id_or_color,
	class_,
	import_,
}

void pop(ref string slice){
	slice=slice[1..$];
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
	bool isChar(char character){
		return token==token.ch && ch==character;
	}

	string toString(){
		string tokenName=token.to!string;
		string dataStr;
		switch(token){
			case Token.ch:
				dataStr=ch.to!string;
				break;
			case Token.num:
				dataStr=num.to!string;
				break;
			case Token.id_or_color: goto case Token.str;
			case Token.class_: goto case Token.str;
			case Token.var: goto case Token.str;
			case Token.str:
				dataStr=str;
				break;
			default:
				break;
		}
		import std.format;
		return format("%-20s: %s",tokenName, dataStr);
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
				continue;
			}
			
			if(slice.length==0){
				break;
			}

			if(checkPixels(slice)){    		
				return;
			}

			if(checkNumber(slice)){    		
				return;
			}
			if(checkImport(slice)){    		
				return;
			}
			if(checkVar(slice)){    		
				return;
			}
			if(checkClass(slice)){    		
				return;
			}
			if(checkIDorColor(slice)){    		
				return;
			}
			if(checkString(slice)){    		
				return;
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
				charsNumToIgnore+=2;
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
		if(slice[0]>='0' && slice[0]<='0'){
			currentTokenData.num=parse!double(slice);
			currentTokenData.token=Token.num;
			if(slice[0]=='f'){
				slice.pop();
			}
			return true;
		}
		return false;
	}

	bool checkClass(ref string slice){
		if(slice.length>1 && slice[0]=='.' ){
			string tmpSlice=slice[1..$];
			enforce(checkString(tmpSlice),"After . there should be string");
			currentTokenData.token=Token.class_;
			slice=tmpSlice;
			return true;
		}
		return false;
	}

	bool checkIDorColor(ref string slice){
		if(slice.length>1 && slice[0]=='#' ){
			string tmpSlice=slice[1..$];
			enforce(checkString(tmpSlice),"After # there should be string");
			currentTokenData.token=Token.id_or_color;
			slice=tmpSlice;
			return true;
		}
		return false;
	}
	bool checkImport(ref string slice){
		if(slice.length>=7 && slice[0..7]=="@import" ){
			currentTokenData.token=Token.import_;
			slice=slice[7..$];
			return true;
		}
		return false;
	}
	bool checkVar(ref string slice){
		if(slice.length>1 && slice[0]=='@' ){
			string tmpSlice=slice[1..$];
			enforce(checkString(tmpSlice),"After @ there should be string");
			currentTokenData.token=Token.var;
			slice=tmpSlice;
			return true;
		}
		return false;
	}
	bool checkPixels(ref string slice){
		if(slice.length>2 ){
			string tmpSlice=slice;
			bool ok=checkNumber(tmpSlice);
			if(ok && tmpSlice.length>=2 && tmpSlice[0..2]=="px"){
				currentTokenData.token=Token.pixels;
				slice=tmpSlice[2..$];
				return true;
			}
		}
		return false;
	}

	bool checkString(ref string slice){
		if(isAlpha(slice[0]) || slice[0]=='_'){
			uint charNum=1;
			foreach(uint i,char ch;slice[1..$]){
				if(!isAlphaNum(ch) && ch!='_' && ch!='-'	){
					break;
				}
				charNum++;
			}
			currentTokenData.str=slice[0..charNum];
			currentTokenData.token=Token.str;
			slice=slice[charNum..$];
			return true;
		}
		return false;
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
