%option noyywrap yylineno
%x STRING
%x MULCOMMENT
%x SINCOMMENT

%{
#include<bits/stdc++.h>
using namespace std;
#include"1805027.h"

int stringStart;
int line_count=1;
int error_count=0;
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
      fprintf(tokenout,"<IF>");
      fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n\n",line_count,yytext);
     }

"else" {
        fprintf(tokenout,"<ELSE>");
        fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n\n",line_count,yytext);
       }

"for" {
       fprintf(tokenout,"<FOR>");
       fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n\n",line_count,yytext);
      }

while {
       fprintf(tokenout,"<WHILE>");
       fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n\n",line_count,yytext);
      }

do {
    fprintf(tokenout,"<DO>");
    fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n\n",line_count,yytext);
   }

break {
       fprintf(tokenout,"<BREAK>");
       fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n\n",line_count,yytext);
      }

int {
     fprintf(tokenout,"<INT>");
     fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n\n",line_count,yytext);
    }

char {
      fprintf(tokenout,"<CHAR>");
      fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n\n",line_count,yytext);
     }
     
float {
       fprintf(tokenout,"<FLOAT>");
       fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n\n",line_count,yytext);
      }

double {
        fprintf(tokenout,"<DOUBLE>");
        fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n\n",line_count,yytext);
       }

void {
      fprintf(tokenout,"<VOID>");
      fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n\n",line_count,yytext);
     }

return {
        fprintf(tokenout,"<RETURN>");
        fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n\n",line_count,yytext);
       }

switch {
        fprintf(tokenout,"<SWITCH>");
        fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n\n",line_count,yytext);
       }

case {
      fprintf(tokenout,"<CASE>");
      fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n\n",line_count,yytext);
     }

default {
         fprintf(tokenout,"<DEFAULT>");
         fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
        }

continue {
          fprintf(tokenout,"<CONTINUE>");
          fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
         }

{DIGIT}+ {
          fprintf(tokenout,"<CONST_INT,%s>",yytext);
	  fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
	  bool found=symbolTable.Insert(yytext,"CONST_INT");
	  if(!found)
	  {
	    fprintf(logout,"%s already exists in the current scopetable\n\n",yytext);
	  }
	  else
	  {
	    symbolTable.PrintAllTable(logout);
	  }
	 }

[0-9]*(\.[0-9]+)?(E[+-]?[0-9]+)? {
                                  fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
			          fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
			          bool found=symbolTable.Insert(yytext,"CONST_FLOAT");
			          if(!found)
	                          {
	                           fprintf(logout,"%s already exists in the current scopetable\n\n",yytext);
	                          }
	                          else
	                          {
	                            symbolTable.PrintAllTable(logout);
	                          }
			         }
			   
[0-9]+(\.)*(\.[0-9]+)*(E(\.)*[+-]*(\.)*[0-9]*(\.)*)+[0-9]* {
                                                             error_count++;
                                                             fprintf(logout,"Error at Line no %d: Ill formed number\n\n",line_count);
                              
                                                           }
			          
(\.)*[0-9]+(\.)+([0-9]+(\.)+)+[0-9]* {
                                 error_count++;
                                 fprintf(logout,"Error at Line no %d: Too many decimal points %s\n\n",line_count,yytext);
                                }
                        

			      
\'\\{ESCAPECHAR}\' {
                     char c=yytext[2];
                     string ch="";
                     if(yytext[2]=='n')
                     {
                      ch+="\n";
                     }
                     else if(yytext[2]=='t')
                     {
                      ch+="        "; 
                     }
                     else if(yytext[2]=='b')
                     {
                      ch+="\b"; //backspace not working
                     }
                     else if(yytext[2]=='a')
                     {
                      ch+="\a";
                     }
                     else if(yytext[2]=='f')
                     {
                      ch+="\f";
                     }
                     else if(yytext[2]=='\\')
                     {
                      ch+="\\";
                     }
                     else if(yytext[2]=='\'')
                     {
                      ch+="\'";
                     }
                     else if(yytext[2]=='v')
                     {
                      ch+="\v";
                     }
                     else if(yytext[2]=='0')
                     {
                      ch+="\0";
                     }
                     else
                     {
                      ch+=yytext[2];
                     }
                     
                     fprintf(tokenout,"<CONST_CHAR,%s>",ch.c_str());
                     fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found --><CHAR_CONST,%s>\n\n",line_count,yytext,ch.c_str());
                     bool found=symbolTable.Insert(yytext,"CONST_CHAR");
                     if(!found)
                     {
                      fprintf(logout,"%s already exists in the current scopetable\n\n",yytext);
                     }
                     else
                     {
                       symbolTable.PrintAllTable(logout);
                     }
                  }
                  
\'{NOTQUOTE}\' {
        if(yytext[1]!='\\')
        {
         char c=yytext[1];
         fprintf(tokenout,"<CONST_CHAR,%c>",c);
         fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found --><CHAR_CONST,%c>\n\n",line_count,yytext,c);
         bool found=symbolTable.Insert(yytext,"CONST_CHAR");
         if(!found)
         {
          fprintf(logout,"%s already exists in the current scopetable\n\n",yytext);
         }
         else
         {
           symbolTable.PrintAllTable(logout);
         }
        }
        else
        {
         error_count++;
         fprintf(logout,"Error at Line no %d:Unfinished character %s\n\n",line_count,yytext);
        }
      }
      
\'{NOTQUOTE}{NOTQUOTE}+\' {
            error_count++;
            fprintf(logout,"Error at Line no %d,Multicharacter constant %s\n\n",line_count,yytext);
          }
          

\'\' {
       error_count++;
       fprintf(logout,"Error at Line no %d: Empty character constant %s\n\n",line_count,yytext);
     }
     
\'{NOTQUOTE}* {
      error_count++;
      fprintf(logout,"Error at Line no %d: Unfinished character %s\n\n",line_count,yytext);
    }

[+-] {
      fprintf(tokenout,"<ADDOP,%s>",yytext);
      fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
     }			   
	
[*/%] {
       fprintf(tokenout,"<MULOP,%s>",yytext);
       fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
      }

"++"|"--" {
            fprintf(tokenout,"<INCOP,%s>",yytext);
	    fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
	  }

"<"|"<="|">"|">="|"=="|"!=" {
                             fprintf(tokenout,"<RELOP,%s>",yytext);
			     fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			    }

[=] {
     fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
    }

"&&"|"||" {
            fprintf(tokenout,"<LOGICOP,%s>",yytext);
	    fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
	  }

"(" {
     fprintf(tokenout,"<LPAREN,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n\n",line_count,yytext);
    }

")" {
     fprintf(tokenout,"<RPAREN,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n\n",line_count,yytext);
    }

"{" {
     fprintf(tokenout,"<LCURL,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
     symbolTable.EnterScope();
    }

"}" {
     fprintf(tokenout,"<RCURL,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
     symbolTable.ExitScope();
    }

"[" {
     fprintf(tokenout,"<LTHIRD,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n\n",line_count,yytext);
    }

"]" {
     fprintf(tokenout,"<RTHIRD,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n\n",line_count,yytext);
    }

"," {
     fprintf(tokenout,"<COMMA,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
    }

";" {
     fprintf(tokenout,"<SEMICOLON,%s>",yytext);
     fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
    }
     
("_"|[a-zA-Z])([a-zA-Z0-9_])* {
                                 fprintf(tokenout,"<ID,%s>",yytext);
                                 fprintf(logout,"Line no %d: TOKEN <IDENTIFIER> Lexeme %s found\n\n",line_count,yytext);  
                                 bool found=symbolTable.Insert(yytext,"ID");
                                 if(!found)
                                 {
                                  fprintf(logout,"%s already exists in the current scope\n\n",yytext);
                                 }  
                                 else
                                 {
                                  symbolTable.PrintAllTable(logout);
                                 }                           
                               }
                              
[0-9]+("_"|[a-zA-Z])([a-zA-Z0-9_])* {
                                      error_count++;
                                      fprintf(logout,"Error at Line no %d: Invalid identifier\n\n",line_count);
                                    }
                               
"//" {
      BEGIN SINCOMMENT;
      commStart=line_count;
      cmmnt+=yytext;
     }	
     
<SINCOMMENT>\\({NEWLINE}|{CR}{NEWLINE}) {
                                           line_count+=1;
                                           cmmnt+=yytext;
                                          
                                         }
                                         
<SINCOMMENT>\\{NOTNL} {
                        cmmnt+=yytext;
                      }
      
<SINCOMMENT>{NEWLINE}|{CR}{NEWLINE} {
                                      BEGIN INITIAL;
                                      line_count+=1;
                                      fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",commStart,cmmnt.c_str());
                                      cmmnt="";
                                    }
<SINCOMMENT>[^\\\n\r] {
                       cmmnt+=yytext;
                      }


"/*" {
      BEGIN MULCOMMENT;
      commStart=line_count;
      cmmnt+=yytext;
    }
    
<MULCOMMENT>. {
     cmmnt+=yytext;
   }
   
<MULCOMMENT>{NEWLINE}|{CR}{NEWLINE}  {
                      cmmnt+=yytext;
                      line_count++;
                    }

<MULCOMMENT>"*/" {
                     BEGIN INITIAL;
                     cmmnt+=yytext;
                     fprintf(logout,"Line no %d: TOKEN <COMMMENT> Lexeme %s found\n\n",commStart,cmmnt.c_str());
                     cmmnt="";                
                 }
                 
<MULCOMMENT><<EOF>> {
                         error_count++;
                         fprintf(logout,"Line no %d: Unfinished comment %s\n\n",commStart,cmmnt.c_str());  
                         fprintf(logout,"Total lines : %d\n",yylineno-1);
                         fprintf(logout,"Total errors : %d\n",error_count);
                         return 0;            
                    }
                 
\" {
    BEGIN STRING;
    str+=yytext;
    stringStart=line_count; 
   }
    
<STRING>[^\"\\\r\n] {
                     str+=yytext; 
                     token+=yytext; 
                    }
    
<STRING>\\({NEWLINE}|{CR}{NEWLINE}) {
                                     str+=yytext;
                                     line_count++;
                                    }  
                                     
<STRING>{NEWLINE}|{CR}{NEWLINE} {
                                  BEGIN INITIAL;
                                  line_count++;
                                  error_count++;
                                  fprintf(logout,"Error at line no %d: Unterminated string %s\n\n",stringStart,str.c_str());
                                  str="";
                                }

<STRING>\\. { 
              str+=yytext;
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
              }
            }

<STRING>\" {
              BEGIN INITIAL;
              str+=yytext;
              fprintf(tokenout,"<STRING,\"%s\">",token.c_str());
              fprintf(logout,"Line no %d: TOKEN<STRING> Lexeme %s found --><STRING,\"%s\">\n\n",stringStart,str.c_str(),token.c_str());
              str="";
              token="";
           }   
           
<STRING><<EOF>> {
                 error_count++;
                 fprintf(logout,"Line no %d: Unterminated string %s\n\n",stringStart,yytext);  
                 fprintf(logout,"Total lines : %d\n",yylineno);
                 fprintf(logout,"Total errors : %d\n",error_count);
                 return 0;
                }

<STRING>. {}



     
{WHITESPACE} {}

{NEWLINE} {
            line_count++;

          }
          
<<EOF>> {
          symbolTable.PrintAllTable(logout);
          fprintf(logout,"Total lines : %d\n",yylineno-1);
          fprintf(logout,"Total errors : %d\n",error_count);
          return 0;
          
        }
        
. {
    error_count++;
    fprintf(logout,"Error at Line no %d: Unrecognized character\n",line_count);
  }
          

		

%%

int main(int argc,char *argv[]){
	
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
}
