package Example;

import java_cup.runtime.SymbolFactory;
%%
%cup
%line
%class Scanner
%{
	private SymbolFactory sf;
	private StringBuffer string;
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
		string = new StringBuffer();
	}
%}
%eofval{
    return sf.newSymbol("EOF",sym.EOF);
%eofval}

Whitespace = \ | \s | \n | \t | \r | \f | \b
Char = [^\"\\] | \\u {Unicode}
Unicode = {Hex}{4}
Hex = {Zero} | {NonZeroDigit} | A | B | C | D | E | F | a | b | c | d | e | f
LeftBracket = \[
RightBracket = \]

Number = {Zero} | {Integer} | {Fraction} | {Exponent}
Exponent = ({Integer} | {Fraction}) {Exp} ({Integer} | {Fraction})
Fraction = ({Zero} | {Integer}) {Point} ({Zero} | {NonZeroDigit})+
Integer = {Negative}{0,1} {NonZeroDigit} ({Zero} | {NonZeroDigit})*
NonZeroDigit = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
Zero = 0
Negative = \-
Exp = e | E
Point = .

%state STRING

%%

<YYINITIAL> {
	\"				{ string.setLength(0); yybegin(STRING); }
	{Number}		{ System.out.println("Reading NUMBER"); 
					  new Double(yytext()); return sf.newSymbol("Number", sym.NUMBER); }
	"true" 			{ return sf.newSymbol("True", sym.TRUE); }
	"false" 		{ return sf.newSymbol("False", sym.FALSE); }
	"null" 			{ return sf.newSymbol("Null", sym.NULL); }
	"{"				{ System.out.println("Reading LBRACE"); 
					  return sf.newSymbol("Left Brace", sym.LBRACE); }
	"}"				{ System.out.println("Reading RBRACE"); 
					  return sf.newSymbol("Right Brace", sym.RBRACE); }
	{LeftBracket}	{ System.out.println("Reading LBRACKET"); return sf.newSymbol("Left Bracket", sym.LBRACKET); }
	{RightBracket}	{ System.out.println("Reading RBRACKET"); return sf.newSymbol("Right Bracket", sym.RBRACKET); }
	","				{ System.out.println("Reading COMMA"); return sf.newSymbol("Comma", sym.COMMA); }
	":"				{ System.out.println("Reading COLON"); 
					  return sf.newSymbol("Colon", sym.COLON); }
	{Whitespace} 	{ /* Ignore whitespace */ }
}

<STRING> {
	\"				{ System.out.println("Reading STRING" + yyline); 
					  yybegin(YYINITIAL); return sf.newSymbol("String", sym.STRING, string.toString()); }
	{Char}*			{ string.append(yytext()); }
	\\t 			{ string.append('\t'); }
	\\n 			{ string.append('\n'); }
	\\r 			{ string.append('\r'); }
	\\\"			{ string.append('\"'); }
}

/* Error fallback */
.					{ System.err.println("Illegal character: " + yytext()); }