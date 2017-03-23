module ast_check;

import tokenizer;

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
				throw new Exception("Bad");
		}
	}
	void checkDekImport(){
		tokenizer.popToken();
	}

	void checkDekZmiennej(){
		tokenizer.popToken();
	}
	void checkDekGrupy(){
		tokenizer.popToken();
	}
	void checkDekMixin(){
		tokenizer.popToken();
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
			}
		}
	}
	void checkElement(){
		tokenizer.popToken();
	}

	/*
	 <lista elementow>  := <element> | <element>  <element> | <element>   "," <element>
<element>          := <element klasa> | <element id> | <nazwa> <element klasa> | <nazwa> <element id> | <nazwa> <element dwukropek>
<element klasa>    := "." <nazwa> 
<element dwukropek>:= ":" <nazwa> 
<element id>       :=  "#" <nazwa> 
	 */
}