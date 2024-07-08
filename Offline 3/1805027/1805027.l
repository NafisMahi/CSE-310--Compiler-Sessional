%option noyywrap yylineno
%x STRING
%x MULCOMMENT
%x SINCOMMENT

%{
#include<bits/stdc++.h>
using namespace std;

#include "1805027.h"
#include "y.tab.h"


#define YYSTYPE SymbolInfo*

void yyerror(char*);

int stringStart;
extern int line_count;
extern int error_count;
extern SymbolTable symtab;
int commStart;
string str="";
string token="";
string cmmnt="";

SymbolTable symbolTable(7);

FILE *logout;
FILE *tokenout;

void IncLineCount()
{
  line_count++;
}

void IncError()
{
  error_count++;
}


%}

SPACE [ ]
WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
LETTER_ LETTER|"_"
DIGIT [0-9]
ALPHANUMERIC_ LETTER_|DIGIT 
ESCAPECHAR [\\\'abtvnr0]
CR "\r"
NEWLINE "\n"
NOTNL [^\r\n]
NOTQUOTE [^\'\r\n]
IDENTIFIER {DIGIT}{DIGIT|LETTER_}*

%%


"if" {
      return IF;
     }

"else" {
        return ELSE;
       }

"for" {
       return FOR;
      }

while {
       return WHILE;
      }

do {
    return DO;
   }

break {
       return BREAK;
      }

int {
     return INT;
    }

char {
      return CHAR;
     }
     
float {
       return FLOAT;
      }

double {
        return DOUBLE;
       }

void {
      return VOID;
     }

return {
        return RETURN;
       }

switch {
        return SWITCH;
       }

case {
      return CASE;
     }

default {
         return DEFAULT;
        }

continue {
          return CONTINUE;
         }
         
printf {
        return PRINTLN;
       }

{DIGIT}+ {
          SymbolInfo *si=new SymbolInfo();
          si->setName(yytext);
          si->setType("int");
          yylval.info=si;
          return CONST_INT;
	 }

[0-9]*(\.[0-9]+)?(E[+-]?[0-9]+)? {
                                   SymbolInfo *si=new SymbolInfo();
                                   si->setName(yytext);
                                   si->setType("float");
                                   yylval.info=si;
                                   return CONST_FLOAT;                              
			         }
			   
[0-9]+(\.)*(\.[0-9]+)*(E(\.)*[+-]*(\.)*[0-9]*(\.)*)+[0-9]* {
                                                             /*error_count++;
                                                             fprintf(logout,"Error at Line no %d: Ill formed number\n\n",line_count);*/
                              
                                                           }
			          
(\.)*[0-9]+(\.)+([0-9]+(\.)+)+[0-9]* {
                                 /*error_count++;
                                 fprintf(logout,"Error at Line no %d: Too many decimal points %s\n\n",line_count,yytext);*/
                                }
                        

			      
\'\\{ESCAPECHAR}\' {
                     return CONST_CHAR;
                  }
                  
\'{NOTQUOTE}\' {
                 return CONST_CHAR;
              }
      
\'{NOTQUOTE}{NOTQUOTE}+\' {
          /*  error_count++;
            fprintf(logout,"Error at Line no %d,Multicharacter constant %s\n\n",line_count,yytext);*/
          }
          

\'\' {
       /*error_count++;
       fprintf(logout,"Error at Line no %d: Empty character constant %s\n\n",line_count,yytext);*/
     }
     
\'{NOTQUOTE}* {
      /*error_count++;
      fprintf(logout,"Error at Line no %d: Unfinished character %s\n\n",line_count,yytext);*/
    }

[+-] {
      SymbolInfo *si=new SymbolInfo();
      si->setName(yytext);
      si->setType("ADDOP");
      yylval.info=si;
      return ADDOP;
     }			   
	
[*/%] {
          SymbolInfo *si=new SymbolInfo();
          si->setName(yytext);
          si->setType("MULOP");
          yylval.info=si;
          return MULOP;
      }

"++" {
            SymbolInfo *si=new SymbolInfo();
            si->setName(yytext);
            si->setType("INCOP");
            yylval.info=si;
            return INCOP;
      }
	  
"--" {
       SymbolInfo *si=new SymbolInfo();
       si->setName(yytext);
       si->setType("INCOP");
       yylval.info=si;
       return DECOP;
     }

"<"|"<="|">"|">="|"=="|"!=" {
                             SymbolInfo *si=new SymbolInfo();
                             si->setName(yytext);
                             si->setType("RELOP");
                             yylval.info=si;
                             return RELOP;
			    }

[=] {
          SymbolInfo *si=new SymbolInfo();
          si->setName(yytext);
          si->setType("ASSIGNOP");
          yylval.info=si;
          return ASSIGNOP;
    }

"&&"|"||" {
            SymbolInfo *si=new SymbolInfo();
            si->setName(yytext);
            si->setType("LOGICOP");
            yylval.info=si;
            return LOGICOP;
	  }

"(" {
      return LPAREN;
    }

")" {
     return RPAREN;
    }

"{" {
     return LCURL;
    }

"}" {
     return RCURL;
    }

"[" {
     return LTHIRD;
    }

"]" {
     return RTHIRD;
    }

"," {
     return COMMA;
    }

";" {
     return SEMICOLON;
    }
     
("_"|[a-zA-Z])([a-zA-Z0-9_])* {
                               string text(yytext);
                               SymbolInfo *si=new SymbolInfo(text,"ID");
                               yylval.info=(YYSTYPE) si;
                               return ID;
                              /* SymbolInfo *si=new SymbolInfo();
                               si->setName(yytext);
                               si->setType("ID"); 
                               yylval.info=si;
                               return ID; */                      
                              }
                              
[0-9]+("_"|[a-zA-Z])([a-zA-Z0-9_])* {
                                      /*error_count++;
                                      fprintf(logout,"Error at Line no %d: Invalid identifier\n\n",line_count);*/
                                    }
                               
"//" {
      /*BEGIN SINCOMMENT;
      commStart=line_count;
      cmmnt+=yytext;*/
     }	
     
<SINCOMMENT>\\({NEWLINE}|{CR}{NEWLINE}) {
                                          /* line_count+=1;
                                           cmmnt+=yytext;*/
                                          
                                         }
                                         
<SINCOMMENT>\\{NOTNL} {
                        //cmmnt+=yytext;
                      }
      
<SINCOMMENT>{NEWLINE}|{CR}{NEWLINE} {
                                      /*BEGIN INITIAL;
                                      line_count+=1;
                                      fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",commStart,cmmnt.c_str());
                                      cmmnt="";*/
                                    }
<SINCOMMENT>[^\\\n\r] {
                      // cmmnt+=yytext;
                      }


"/*" {
     /* BEGIN MULCOMMENT;
      commStart=line_count;
      cmmnt+=yytext;*/
    }
    
<MULCOMMENT>. {
     //cmmnt+=yytext;
   }
   
<MULCOMMENT>{NEWLINE}|{CR}{NEWLINE}  {
                     /* cmmnt+=yytext;
                      line_count++;*/
                    }

<MULCOMMENT>"*/" {
                    /* BEGIN INITIAL;
                     cmmnt+=yytext;
                     fprintf(logout,"Line no %d: TOKEN <COMMMENT> Lexeme %s found\n\n",commStart,cmmnt.c_str());
                     cmmnt=""; */               
                 }
                 
<MULCOMMENT><<EOF>> {
                         /*error_count++;
                         fprintf(logout,"Line no %d: Unfinished comment %s\n\n",commStart,cmmnt.c_str());  
                         fprintf(logout,"Total lines : %d\n",yylineno-1);
                         fprintf(logout,"Total errors : %d\n",error_count);
                         return 0;  */          
                    }
                 
\" {
    /*BEGIN STRING;
    str+=yytext;
    stringStart=line_count; */
   }
    
<STRING>[^\"\\\r\n] {
                     //str+=yytext; 
                     //token+=yytext; 
                    }
    
<STRING>\\({NEWLINE}|{CR}{NEWLINE}) {
                                     /*str+=yytext;
                                     line_count++;*/
                                    }  
                                     
<STRING>{NEWLINE}|{CR}{NEWLINE} {
                                  /*BEGIN INITIAL;
                                  line_count++;
                                  error_count++;
                                  fprintf(logout,"Error at line no %d: Unterminated string %s\n\n",stringStart,str.c_str());
                                  str="";*/
                                }

<STRING>\\. { 
              /*str+=yytext;
              if(yytext[1]=='n')
                {
               token+="\n";
                }
              else if(yytext[1]=='t')
                {
              token+="\t"; 
                }
              else if(yytext[1]=='b')
              {
               token+=int('\b'); //backspace not working
              }
              else if(yytext[1]=='a')
              {
               token+="\a";
              }
              else if(yytext[1]=='f')
              {
                token+="\f";
              }
              else if(yytext[1]=='\\')
              {
                token+="\\";
              }
              else if(yytext[1]=='\'')
              {
                token+="\'";
              }
              else if(yytext[1]=='v')
              {
                token+="\v";
              }
              else if(yytext[1]=='0')
              {
                token+="\0";
              }
              else
              {
              token+=yytext[1];
              }*/
            }

<STRING>\" {
              /*BEGIN INITIAL;
              str+=yytext;
              fprintf(tokenout,"<STRING,\"%s\">",token.c_str());
              fprintf(logout,"Line no %d: TOKEN<STRING> Lexeme %s found --><STRING,\"%s\">\n\n",stringStart,str.c_str(),token.c_str());
              str="";
              token="";*/
           }   
           
<STRING><<EOF>> {
                /* error_count++;
                 fprintf(logout,"Line no %d: Unterminated string %s\n\n",stringStart,yytext);  
                 fprintf(logout,"Total lines : %d\n",yylineno);
                 fprintf(logout,"Total errors : %d\n",error_count);
                 return 0;*/
                }

<STRING>. {}



     
{WHITESPACE} {}

{NEWLINE} {
            line_count++;

          }
          
. {
    /*error_count++;
    fprintf(logout,"Error at Line no %d: Unrecognized character\n",line_count);*/
  }
          

		

%%

/*int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("<1805027>_log.txt","w");
	tokenout= fopen("<1805027>_token.txt","w");

	yyin= fin;
	yylineno=1;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}*/
