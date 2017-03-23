module ast_check;

import tokenizer;
import std.stdio;
import std.exception;

class AstCheck{
	Tokenizer tokenizer;
	this(string data){
		tokenizer= new Tokenizer(data);
	}

	void check(){
		tokenizer.popToken();
		while(tokenizer.currentToken!=Token.none){
			checkDeklaracja();
		}
	}

	void checkDeklaracja(){
		switch(tokenizer.currentToken){
			case Token.import_:
				checkDekImport();
				break;
			case Token.var:
				checkDekZmiennej();
				break;
			case Token.str:
			case Token.class_:
			case Token.id_or_color:
				checkDekGrupy();
				break;
			default:
				throw new Exception("Expected new declaration");
		}
	}
	void checkDekImport(){
		tokenizer.popToken();
	}

	void checkDekZmiennej(){
		tokenizer.popToken();//@xxx
		enforce(tokenizer.currentTokenData.isChar(':'),"Colon expected");
		tokenizer.popToken();//:
		checkWartosc();
		enforce(tokenizer.currentTokenData.isChar(';'),"Semicolon expected");
		tokenizer.popToken();//;
	}
	void checkDekGrupy(){
		checkListaElementow();
		
		checkMixin();
		
		enforce(tokenizer.currentTokenData.isChar('{')," '{' expected");
		tokenizer.popToken();//{
		checkListaStyli();
		//writeln(tokenizer.currentTokenData);
		enforce(tokenizer.currentTokenData.isChar('}')," '}' expected");
		tokenizer.popToken();//}
	}
	void checkListaStyli(){
		while(tokenizer.currentToken==Token.str){
			tokenizer.popToken();//str
			enforce(tokenizer.currentTokenData.isChar(':'),"Colon expected");
			tokenizer.popToken();//:
			checkWartosc();

			if(tokenizer.currentTokenData.isChar(';')){
				tokenizer.popToken();//;
			}else if(!tokenizer.currentTokenData.isChar('}')){
				enforce(0," '}' expected");
			}
			if(tokenizer.currentTokenData.isChar('}')){
				break;
			}
		}

		//<lista styli>      := <nazwa> : <wartosc> ";" | <>
	}
	void checkMixin(){
		if(tokenizer.currentTokenData.isChar('(')){
			tokenizer.popToken();//(
			checkListaParametrow();	
			writeln(tokenizer.currentTokenData);	
			enforce(tokenizer.currentTokenData.isChar(')'),"')' expected");
			tokenizer.popToken();//)
		}
	}
	
	void checkListaParametrow(){
		while(tokenizer.currentToken==Token.var){
			tokenizer.popToken();//var
			//default value
			if(tokenizer.currentTokenData.isChar(':')){
				tokenizer.popToken();//:
				checkWartosc();
			}		
			

			if(!tokenizer.currentTokenData.isChar(',')){
				break;
			}else{
				tokenizer.popToken();//,
			}
		}
	}
	void checkListaElementow(){
		while(
			tokenizer.currentToken==Token.class_ ||
			tokenizer.currentToken==Token.id_or_color ||
			tokenizer.currentToken==Token.str 
			){

			checkElement();
			if(!tokenizer.currentTokenData.isChar(',')){
				break;
			}else{
				tokenizer.popToken();
			}
		}
	}
	void checkElement(){
		tokenizer.popToken();
	}

	void checkWartosc(){
			writeln(tokenizer.currentTokenData);
		switch(tokenizer.currentToken){
			//case Token.percentage:
			case Token.id_or_color:
			case Token.num:
			case Token.pixels:
			case Token.var:
				tokenizer.popToken();
				break;
			case Token.str:
				tokenizer.popToken();
				checkWykonanie();
				break;
			//wyrazenie
			default:
				throw new Exception("Expected some value");
		}
	//<wartosc>          := <kolor hex> | <liczba> |  <procent> | <wykonanie> | <nazwa> | "@" <nazwa> | wyrazenie
	}
	void checkWykonanie(){
		if(tokenizer.currentTokenData.isChar('(')){
			tokenizer.popToken();
			checkListaWartosci();
			enforce(tokenizer.currentTokenData.isChar(')')," ')' expected");
			tokenizer.popToken();
		}
	}
	void checkListaWartosci(){
		while(!tokenizer.currentTokenData.isChar(')')){			
			checkElement();
		}
	}

	/*
	 <lista elementow>  := <element> | <element>  <element> | <element>   "," <element>
<element>          := <element klasa> | <element id> | <nazwa> <element klasa> | <nazwa> <element id> | <nazwa> <element dwukropek>
<element klasa>    := "." <nazwa> 
<element dwukropek>:= ":" <nazwa> 
<element id>       :=  "#" <nazwa> 
	 */
}