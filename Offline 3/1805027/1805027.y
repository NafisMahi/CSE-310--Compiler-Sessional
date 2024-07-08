%{
#include <bits/stdc++.h>
using namespace std;

#include"1805027.h"

SymbolTable *symtab=new SymbolTable(30);
FILE *inputFile,*logFile,*errorFile;

extern FILE* yyin;

int line_count=1;
int error_count=0;
vector<pair<string,string>> declared_vars;
vector<pair<string,string>> param_list;
vector<string> taken_arg;
string returnType="null";

int yyparse(void);
int yylex(void);


void yyerror(char *s){
        error_count++;
	fprintf(errorFile,"Syntax error at Line no %d: %s\n",line_count,s);
}



%}

%union{
 SymbolInfo* info;
}

%token BREAK CASE CONTINUE DEFAULT RETURN SWITCH VOID CHAR DOUBLE FLOAT INT DO WHILE FOR IF ELSE
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token COMMA SEMICOLON PRINTLN


%token <info> ID
%token <info> CONST_INT
%token <info> CONST_FLOAT
%token <info> CONST_CHAR

%token <info> ADDOP MULOP RELOP LOGICOP

%type <info> start program unit var_declaration variable type_specifier declaration_list
%type <info> expression_statement func_declaration parameter_list func_definition
%type <info> compound_statement statements unary_expression factor statement arguments
%type <info> expression logic_expression simple_expression rel_expression term argument_list

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program 
      {
       $$=$1;
       fprintf(logFile,"Line %d: start : program\n\n",line_count);
       string token=$$->getName();
       fprintf(logFile,"%s\n\n",token.c_str());
      }
      ;
                
program : program unit 
        {
         string si_name=$1->getName()+"\n"+$2->getName();
         string si_type="";
         SymbolInfo *obj=new SymbolInfo(si_name,si_type);
         $$=obj;
         fprintf(logFile,"Line %d: program: program unit \n\n",line_count);
         string token=$$->getName();
         fprintf(logFile,"%s\n\n",token.c_str());
        }
        
        |unit
        {
         $$=$1;
         fprintf(logFile,"Line %d: program: unit \n\n",line_count);
         string token=$$->getName();
         fprintf(logFile,"%s\n\n",token.c_str());
        }
        ;
        
unit : var_declaration
     {
      $$=$1;
      fprintf(logFile,"Line %d: unit : var_declaration \n\n",line_count);
      string token=$$->getName();
      fprintf(logFile,"%s\n\n",token.c_str());
     }
     
     | func_declaration
     {
       $$=$1;
       fprintf(logFile,"Line %d: unit : func_declaration \n\n",line_count);
       string token=$$->getName();
       fprintf(logFile,"%s\n\n",token.c_str());
     }
     
     | func_definition
     {
       $$=$1;
       fprintf(logFile,"Line %d: unit : func_definition \n\n",line_count);
       string token=$$->getName();
       fprintf(logFile,"%s\n\n",token.c_str());
     }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
                 {
                  string toBeReturned=$1->getName();
                  SymbolInfo *ptr=symtab->Lookup($2->getName());
               
                  if(ptr!=nullptr)
                  {
                   if(!ptr->isFunc())
                   {
                    error_count++;
                    string err_msg="Identifier "+$2->getName()+" is not a function";
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                   
                   else
                   {
                    //error,already declared
                   error_count++;
                   string err_msg="Multiple declaration of function "+$2->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                  }
                  else
                  {
                   symtab->Insert($2->getName(),$1->getName());
                   SymbolInfo* func=symtab->Lookup($2->getName());
                   func->setFunction();
                   func->setReturnType(toBeReturned);
      
                   for(auto u:param_list)
                   {
                    string param_name=u.first;
                    string param_type=u.second;
                    func->addParam(param_name,param_type);
                   }
                   //symtab->Insert(func);
                   param_list.clear();
                  }
                  string si_name=$1->getName()+" "+$2->getName()+"("+$4->getName()+");";
                  string si_type="";
                  $$=new SymbolInfo(si_name,si_type);
                  fprintf(logFile,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                 }
                 
                |  type_specifier ID LPAREN RPAREN SEMICOLON
                {
                  string toBeReturned=$1->getName();
                  SymbolInfo *ptr=symtab->Lookup($2->getName());
                 // SymbolInfo *func=new SymbolInfo($2->getName(),$1->getName());
                  if(ptr!=nullptr)
                  {
                   //error,already declared
                   error_count++;
                   string err_msg="Multiple declaration of function "+$2->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  }
                  else
                  {
                   symtab->Insert($2->getName(),$1->getName());
                   SymbolInfo *func=symtab->Lookup($2->getName());
                   func->setFunction();
                   func->setReturnType(toBeReturned);
                   for(auto u:param_list)
                   {
                    string param_name=u.first;
                    string param_type=u.second;
                    func->addParam(param_name,param_type);
                   }
                   //symtab->Insert(func);
                   param_list.clear();
                  }
                  string si_name=$1->getName()+" "+$2->getName()+"("+");";
                  string si_type="";
                  $$=new SymbolInfo(si_name,si_type);
                  fprintf(logFile,"Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                }
                ;
                
func_definition :  type_specifier ID LPAREN parameter_list RPAREN
                {
                 string funcReturnType=$1->getName();
                 returnType=$1->getName();
                 SymbolInfo *func=symtab->Lookup($2->getName());
                 if(func==nullptr)// func isn't declared
                 {
                  //SymbolInfo *newFunc=new SymbolInfo($2->getName(),$1->getName());
                  symtab->Insert($2->getName(),$1->getName());
                  SymbolInfo *newFunc=symtab->Lookup($2->getName());
                  newFunc->setFunction();
                  newFunc->setReturnType(funcReturnType);
                  for(auto u:param_list)
                   {
                    string param_name=u.first;
                    string param_type=u.second;
                    newFunc->addParam(param_name,param_type);
                   }
                   
                   newFunc->setDefined();
                  
                  symtab->EnterScope();
                  bool insert=false;
                  for(auto u:param_list)
                  {
                   string param_name=u.first;
                   string param_type=u.second;
                   insert=symtab->Insert(param_name,param_type);
                   if(!insert)
                   {
                    //multiple declaration of variable in parameter
                    error_count++;
                    string err_msg="Multiple declaration of variable in parameter";
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                  }
                  
                  param_list.clear();
                 }
                 
                 else 
                 {
                  
                   string storedReturnType=func->getType();
                   if(func->isFunc())
                   {
                    if(!func->isDefined())
                    {
                     if(storedReturnType!=funcReturnType)
                     {
                      //error,return type doesn't match
                      error_count++;
                      string err_msg="Return type mismatch with function declaration in function "+func->getName() ;
                      fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                     }
                     
                     if(func->getParamNum()!=param_list.size())
                     {
                      //error,no of parameters don't match
                      error_count++;
                      string err_msg="Total number of arguments mismatch with declaration in func "+func->getName();
                      fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                     }
                     
                     vector<pair<string,string>> funcParam=func->getParam();
                     if(func->getParamNum()!=0 && func->getParamNum()==param_list.size())
                     {
                      for(int i=0;i<param_list.size();i++)
                      {
                       string par_name=param_list[i].first;
                       string par_type=param_list[i].second;
                     
                       if(par_type!=funcParam[i].second)
                       {
                        //error,type mismatch
                        error_count++;
                        string err_msg="Type mismatch of variable "+par_name;
                        fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       }
                      }
                     }
                     
                     func->setDefined();
                     
                     symtab->EnterScope();
                    }
                    
                    else
                    {
                     //multiple definition of same function
                     symtab->EnterScope();
                     error_count++;
                     string err_msg="Re-definition of function "+$2->getName();
                     fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                    }
                   }
                   
                   else
                   {
                    //identifier not a function
                    symtab->EnterScope();
                    error_count++;
                    string err_msg="Multiple declaration of "+$2->getName();
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                   
                     bool insert=false;
                     
                     for(int i=0;i<param_list.size();i++)
                     {
                      string name=param_list[i].first;
                      string type=param_list[i].second;
                      if(name.size()==0)
                      {
                       //error,(i+1)th parameter's name not given
                       error_count++;
                       string err_msg="Parameter name not given";
                       fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                      }
                      else
                      {
                       insert=symtab->Insert(name,type);
                       if(!insert)
                       {
                        //error,multiple declaration of variable in parameter
                        error_count++;
                        string err_msg="Multiple declaration of variable "+name+ " in parameter";
                        fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       }
                      }
                     } 
                 }
                 
                 param_list.clear();
                } compound_statement
                
                  {
                   //string si_name=$1.first+" "+$2.first+$3.first+$4.first+$5.first+$7.first;
                   string si_name=$1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName()+"\n";
                   string si_type="";
                   $$=new SymbolInfo(si_name,si_type);
                   fprintf(logFile,"Line %d: func_definition :  type_specifier ID LPAREN parameter_list RPAREN\n\n",line_count);
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());
                  }
                  
                | type_specifier ID LPAREN RPAREN
                {
                 //symtab->EnterScope();
                 string funcReturnType=$1->getName();
                 SymbolInfo *func=symtab->Lookup($2->getName());
                 
                 if(func==nullptr)// func isn't declared
                 {
                  //SymbolInfo *newFunc=new SymbolInfo($2->getName(),$1->getName());
                  symtab->Insert($2->getName(),$1->getName());
                  SymbolInfo *newFunc=symtab->Lookup($2->getName());
                  newFunc->setFunction();
                  newFunc->setReturnType(funcReturnType);
                  for(auto u:param_list)
                   {
                    string param_name=u.first;
                    string param_type=u.second;
                    newFunc->addParam(param_name,param_type);
                   }
                  
                  newFunc->setDefined();
                  symtab->EnterScope();
                  bool insert=false;
                  for(auto u:param_list)
                  {
                   string param_name=u.first;
                   string param_type=u.second;
                   insert=symtab->Insert(param_name,param_type);
                   if(!insert)
                   {
                    //multiple declaration of variable in parameter
                    error_count++;
                    string err_msg="Multiple declaration of variable in parameter";
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                  }
                  
                  param_list.clear();
                 }
                 
                 else 
                 {
                   string storedReturnType=func->getType();
                   if(func->isFunc())
                   {
                    if(!func->isDefined())
                    {
                     if(storedReturnType!=funcReturnType)
                     {
                      //error,return type doesn't match
                      error_count++;
                      string err_msg="Return type mismatch with function declaration in function "+func->getName() ;
                      fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                     }
                     
                     if(func->getParamNum()!=param_list.size())
                     {
                      //error,no of parameters don't match
                      error_count++;
                      string err_msg="Number of parameters don't match";
                      fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                     }
                     
                     vector<pair<string,string>> funcParam=func->getParam();
                     if(func->getParamNum()!=0 && func->getParamNum()==param_list.size())
                     {
                      for(int i=0;i<param_list.size();i++)
                      {
                       string par_name=param_list[i].first;
                       string par_type=param_list[i].second;
                       if(par_type!=funcParam[i].second)
                       {
                        //error,type mismatch
                        error_count++;
                        string err_msg="Type mismatch of variable "+par_name;
                        fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       }
                      }
                     }
                     
                     func->setDefined();
                     
                     symtab->EnterScope();
                     bool insert=false;
                     
                     for(int i=0;i<param_list.size();i++)
                     {
                      string name=param_list[i].first;
                      string type=param_list[i].second;
                      if(name.size()==0)
                      {
                       //error,(i+1)th parameter's name not given
                      }
                      else
                      {
                       insert=symtab->Insert(name,type);
                       if(!insert)
                       {
                        //error,multiple declaration of variable in parameter
                        error_count++;
                        string err_msg="Multiple declaration of variable "+name+" in parameter";
                        fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       }
                      }
                     } 
                    
                    }
                    
                    else
                    {
                     //multiple definition of same function
                      error_count++;
                     string err_msg="Re-definition of function "+$2->getName();
                     fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                    }
                   }
                   
                   else
                   {
                    //identifier not a function
                    symtab->EnterScope();
                    error_count++;
                    string err_msg="Multiple declaration of "+$2->getName();
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   }
                 }
                 
                 param_list.clear();
                } compound_statement
                
                  {
                   string si_name=$1->getName()+" "+$2->getName()+"("+")"+$6->getName()+"\n";
                   string si_type="";
                   $$=new SymbolInfo(si_name,si_type);
                   fprintf(logFile,"Line %d: func_definition :  type_specifier ID LPAREN parameter_list RPAREN\n\n",line_count);
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());
                  }
                  ;

parameter_list  : parameter_list COMMA type_specifier ID
                {
                 string si_name=$1->getName()+","+$3->getName()+" "+$4->getName();
                 string si_type="";
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d: parameter_list  : parameter_list COMMA type_specifier ID \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                 
                 param_list.push_back({$4->getName(),$3->getName()});
                }     
                
                | parameter_list COMMA type_specifier
                {
                 string si_name=$1->getName()+","+$3->getName();
                 string si_type="";
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d: parameter_list  : parameter_list COMMA type_specifier \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                 
                 param_list.push_back({"",$3->getName()});
                }                
                
                | type_specifier ID
                {
                 string si_name=$1->getName()+" "+$2->getName();
                 string si_type="";
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d: parameter_list  : type_specifier ID \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                 
                 param_list.push_back({$2->getName(),$1->getName()});
                }
                
                | type_specifier
                {
                 $$=$1;
                 fprintf(logFile,"Line %d: parameter_list  : type_specifier \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                 
                 param_list.push_back({"",$1->getName()});
                }
                ;
                    
compound_statement : LCURL statements RCURL
                   {
                    string si_name="{\n"+$2->getName()+"\n}";
                    string si_type="";
                    $$=new SymbolInfo(si_name,si_type);
                    fprintf(logFile,"Line %d: compound statement : LCURL statements RCURL \n\n",line_count);
                    string token=$$->getName();
                    fprintf(logFile,"%s\n\n",token.c_str());
                 
                    symtab->PrintAllTable(logFile);
                    symtab->ExitScope();
                   }
                   
                   | LCURL RCURL
                   {
                    string si_name="{\n}";
                    string si_type="";
                    $$=new SymbolInfo(si_name,si_type);
                    fprintf(logFile,"Line %d: compound statement : LCURL RCURL \n\n",line_count);
                    string token=$$->getName();
                    fprintf(logFile,"%s\n\n",token.c_str());
                   }
                   ;
                  
var_declaration : type_specifier declaration_list SEMICOLON 
                {
                   string si_name=$1->getName()+" "+$2->getName()+";";
                   string si_type="";
                   string type=$1->getName();
                   $$=new SymbolInfo(si_name,si_type);
                   fprintf(logFile,"Line %d: var_declaration : type_specifier declaration_list SEMICOLON  \n\n",line_count);
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());
                   
                   for(auto u:declared_vars)
                   {
                    string name=u.first;
                    string length=u.second;
                    if(symtab->LookupCurrent(name)==nullptr)
                    {
                     if(length.size()==0)
                     {
                      if(type=="void")
                      {
                       type="float";
                       //error++
                       error_count++;
                       string err_msg="Variable type can't be void";
                       fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       
                      }
                     symtab->Insert(name,type);
                     }
                     else
                     {
                      if(type=="void")
                      {
                       type="float";
                       //error++
                       error_count++;
                       string err_msg="Variable type can't be void";
                       fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                       
                      }
                     symtab->Insert(name,type);
                     SymbolInfo *obj=symtab->Lookup(name);
                     obj->setArray(length);
                     }
                    }                     
                    else
                     {
                    error_count++;
                    string err_msg="Multiple declaration of variable "+name;
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                    
                     }    
                    } 
                    
                    declared_vars.clear(); 
                }
                ;

type_specifier : INT 
               {
                string si_name="int";
                string si_type="";
                $$=new SymbolInfo(si_name,si_type);
                fprintf(logFile,"Line %d: type_specifier : INT \n\n",line_count);
                string token=$$->getName();
                fprintf(logFile,"%s\n\n",token.c_str());
               }
               
               | FLOAT 
               {
                string si_name="float";
                string si_type="";
                $$=new SymbolInfo(si_name,si_type);
                fprintf(logFile,"Line %d: type_specifier : FLOAT \n\n",line_count);
                string token=$$->getName();
                fprintf(logFile,"%s\n\n",token.c_str());
               }
 
               | VOID
               {
                string si_name="void";
                string si_type="";
                $$=new SymbolInfo(si_name,si_type);
                fprintf(logFile,"Line %d: type_specifier : VOID \n\n",line_count);
                string token=$$->getName();
                fprintf(logFile,"%s\n\n",token.c_str());
               }
               ;
         

declaration_list : declaration_list COMMA ID
                 {
                  string si_name=$1->getName()+","+$3->getName();
                  string si_type="";
                  $$=new SymbolInfo(si_name,si_type);
                  fprintf(logFile,"Line %d: declaration_list : declaration_list COMMA ID \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                  
                  if(symtab->LookupCurrent($3->getName())==nullptr)
                  {
                   declared_vars.push_back({$3->getName(),""});
                  }
                  else
                  {
                   //multiple declaration error
                   error_count++;
                   string err_msg="Multiple declaration of "+$3->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   
                  }
                                    
                 }
                 
                 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
                 {
                  string si_name=$1->getName()+","+$3->getName()+"["+$5->getName()+"]";
                  string si_type="";
                  $$=new SymbolInfo(si_name,si_type);
                  fprintf(logFile,"Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                  
                  if(symtab->LookupCurrent($3->getName())==nullptr)
                  {
                   declared_vars.push_back({$3->getName(),$5->getName()});
                  }
                  else
                  { 
                   //multiple declaration error	
                   error_count++;
                   string err_msg="Multiple declaration of "+$3->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  }
                 }
                 
                 | ID
                 {
                  $$=$1;
                  fprintf(logFile,"Line %d: declaration_list : ID \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                  //symtab->currentId();
                  
                  if(symtab->LookupCurrent($1->getName())==nullptr)
                  {
                  symtab->currentId();
                   declared_vars.push_back({$1->getName(),""});
                  }
                  else
                  { 
                   //multiple declaration error	
                   error_count++;
                   string err_msg="Multiple declaration of "+$1->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   
                  }
                  
                 }
                 
                 | ID LTHIRD CONST_INT RTHIRD
                 {
                   string si_name=$1->getName()+"["+$3->getName()+"]";
                   string si_type="";
                   $$=new SymbolInfo(si_name,si_type);
                   fprintf(logFile,"Line %d: ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());
                   
                   symtab->currentId();
                   
                  if(symtab->LookupCurrent($1->getName())==nullptr)
                  {
                   declared_vars.push_back({$1->getName(),$3->getName()});
                  }
                  else
                  { 
                   //multiple declaration error	
                   error_count++;
                   string err_msg="Multiple declaration of "+$1->getName();
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  }
                 }
                 ;

statements : statement
           {
            $$=$1;
            fprintf(logFile,"Line %d: statements : statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
           }
           
           | statements statement
           {
            string si_name=$1->getName()+"\n"+$2->getName();
            string si_type="";
            $$=new SymbolInfo(si_name,si_type);
            fprintf(logFile,"Line %d: statements: statements statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
           }
           ;
           
statement : var_declaration
          {
            $$=$1;
            fprintf(logFile,"Line %d: statement : var_declaration \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | expression_statement
          {
            $$=$1;
            fprintf(logFile,"Line %d: statement : expression_statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | {symtab->EnterScope();} compound_statement
           {
            $$=$2;
            fprintf(logFile,"Line %d: statements : compound_statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
           }
           
          | FOR LPAREN expression_statement expression_statement expression RPAREN statement
          {
            string si_name="for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName();
            string si_type="";
            $$=new SymbolInfo(si_name,si_type);
            fprintf(logFile,"Line %d: statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
          {
            string si_name="if("+$3->getName()+")"+$5->getName();
            string si_type="";
            $$=new SymbolInfo(si_name,si_type);
            fprintf(logFile,"Line %d: statement: IF LPAREN expression RPAREN statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | IF LPAREN expression RPAREN statement ELSE statement
          {
            string si_name="if("+$3->getName()+")"+$5->getName()+"\nelse"+"\n"+$7->getName();
            string si_type="";
            $$=new SymbolInfo(si_name,si_type);
            fprintf(logFile,"Line %d: statement: IF LPAREN expression RPAREN statement ELSE statement \n\n",line_count);
            string token=$$->getName();
            fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | WHILE LPAREN expression RPAREN statement
          {
             string si_name="while("+$3->getName()+")"+$5->getName();
             string si_type="";
             $$=new SymbolInfo(si_name,si_type);
             fprintf(logFile,"Line %d: statement: WHILE LPAREN expression RPAREN statement \n\n",line_count);
             string token=$$->getName();
             fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | PRINTLN LPAREN ID RPAREN SEMICOLON
          {
           if(symtab->Lookup($3->getName())==nullptr)
           {
            //Undeclared variable error
            error_count++;
            string err_msg="Undeclared variable "+$3->getName()+" referred";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
           }
           else
           {
            if(!$3->isVar())
            {
            //function inside println error
             error_count++;
             string err_msg="Invalid identifier inside printf";
             fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            }
           }
           
           string si_name="printf("+$3->getName()+");";
           string si_type="";
           $$=new SymbolInfo(si_name,si_type);
           fprintf(logFile,"Line %d: statement: PRINTLN LPAREN ID RPAREN SEMICOLON \n\n",line_count);
           string token=$$->getName();
           fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | RETURN expression SEMICOLON
          {
           if(returnType=="void")
           {
            //error void no return
            error_count++;
            string err_msg="Void function can't have return statement";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            returnType="null";
           }
           
           string si_name="return "+$2->getName()+";";
           string si_type="";
           $$=new SymbolInfo(si_name,si_type);
           fprintf(logFile,"Line %d: statement:  RETURN expression SEMICOLON \n\n",line_count);
           string token=$$->getName();
           fprintf(logFile,"%s\n\n",token.c_str());
          }
          ;
          
expression_statement : SEMICOLON
                     {
                      string si_name=";";
                      string si_type="";
                      $$=new SymbolInfo(si_name,si_type);
                      fprintf(logFile,"Line %d: expression_statement : SEMICOLON \n\n",line_count);
                      string token=$$->getName();
                      fprintf(logFile,"%s\n\n",token.c_str());
                     }
                     
                     | expression SEMICOLON
                     {
                       string si_name=$1->getName()+";";
                       string si_type="";
                       $$=new SymbolInfo(si_name,si_type);
                       fprintf(logFile,"Line %d: expression_statement : expression SEMICOLON \n\n",line_count);
                       string token=$$->getName();
                       fprintf(logFile,"%s\n\n",token.c_str());
                     }
                     ;
                     
variable : ID 
         {
          string si_name=$1->getName();
          SymbolInfo *ptr=symtab->Lookup(si_name);
          if(symtab->Lookup(si_name)==nullptr)
          {
           //undeclared variable error
           error_count++;
           string err_msg="Undeclared variable "+si_name;
           fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
           $$=new SymbolInfo($1->getName(),"error");
          }
          else
          {
           if(ptr->isFunc())
           {
            //type mismatch error
            error_count++;
            string err_msg=$1->getName()+" is a function";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            $$=new SymbolInfo($1->getName(),"error");
            $$->setFunction();
           }
           else if(ptr->isArr())
           {
            //type mismatch error 
            error_count++;
            string err_msg="Type mismatch "+$1->getName()+" is an array";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            $$=new SymbolInfo($1->getName(),"error");
            $$->setArray("");
           }
           else
           {
            $$=new SymbolInfo(ptr->getName(),ptr->getType());
           }
          }
          
          fprintf(logFile,"Line %d: variable : ID %s\n\n",line_count,$1->getType().c_str());
          string token=$$->getName();
          fprintf(logFile,"%s\n\n",token.c_str());
         }
         
         | ID LTHIRD expression RTHIRD 
         {
          string si_name=$1->getName();
          SymbolInfo *ptr=symtab->Lookup(si_name);
          if(ptr==nullptr)
          {
           //undeclared variable error
           error_count++;
           string err_msg="Undeclared variable "+$1->getName()+" referred";
           fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
           $$=new SymbolInfo($1->getName()+"["+$3->getName()+"]","error");
          }
          else
          {
           string toBeReturned;
           if(ptr->isArr())
           {
            toBeReturned=ptr->getType();
            if($3->getType()=="int")
            {
             string name=$1->getName()+"["+$3->getName()+"]";
             string type=toBeReturned;
             //$$=new SymbolInfo(name,type);
            }
           
            else
            {
             //expression not int error
             error_count++;
             string err_msg="Expression inside third brackets is not an integer";
             fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
             toBeReturned="error"; //confusion
            }
           }
           else
           {
            //type mismatch error
            error_count++;
            string err_msg=$1->getName()+" is not an array";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            toBeReturned="error";
           }
           $$=new SymbolInfo($1->getName()+"["+$3->getName()+"]",toBeReturned);
          }
         
          fprintf(logFile,"Line %d : variable : ID LTHIRD expression RTHIRD  %s\n\n",line_count,$1->getType().c_str()); //need to change
          string token=$$->getName();
          fprintf(logFile,"%s\n\n",token.c_str());
         }
         ;
         

expression: logic_expression
          {
           $$=$1;
           fprintf(logFile,"Line %d : expression: logic_expression \n\n",line_count);
           string token=$$->getName();
           fprintf(logFile,"%s\n\n",token.c_str());
          }
          
          | variable ASSIGNOP logic_expression //need to edit
          {
         
           if(!($1->getType()==$3->getType()))
           {
            if($1->getType()=="error" || $3->getType()=="error")
            {
              if($1->isArr())
             {
             //leftVar is an array
             //error_count++;
             string err_msg="Left operand is an array type variable";
            // fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
             }
              else if($3->isArr())
             {
             //rightvar is an array
             //error_count++;
             string err_msg="Right operand is an array type variable";
             //fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
             }
            }
           
            else if($1->getType()=="float" && $3->getType()=="int")
            {
             //assignment okay 
            }
            
            else
            {
             //wrong assignment error
             if($3->getType()=="void")
             {
              error_count++;
              string err_msg="Void function used in expression";
              fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
              $3->setType("float");
             }
             
             else if($3->getType()=="undeclared")
             {
              ;
             }
             
             else
             {
              error_count++;
              string err_msg="Type mismatch";
              fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
             }
            }
           }
           
           else
           {
            //assignment okay
           }
          
          string si_name=$1->getName()+"="+$3->getName();
          string si_type="";
          $$=new SymbolInfo(si_name,si_type);
          fprintf(logFile,"Line %d : expression : variable ASSIGNOP logic_expression \n\n",line_count);
          string token=$$->getName();
          fprintf(logFile,"%s\n\n",token.c_str());
          }
          ;
         
logic_expression : rel_expression
                 {
                  $$=$1;
                  fprintf(logFile,"Line %d : logic_expression : rel_expression \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                 }
                 
                 | rel_expression LOGICOP rel_expression
                 {
                  string toBeReturned="int";
                  
                  if($1->getType()=="void")
                 {
                  error_count++;
                  string err_msg="Void function used in expression";
                  fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  //$1-setType("float");
                 }
                   
                  
                 if($3->getType()=="void")
                 {
                  error_count++;
                  string err_msg="Void function call used in expression";
                  fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                 // $3-setType("float");
                 }
                 
                  if(!($1->getType()=="int" && $3->getType()=="int"))
                  {
                   //should be int,give error
                   
                   error_count++;
                   string err_msg="Both operands of "+$2->getName()+" should by int type";
                   toBeReturned="error";
                   fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  }
                  string si_name=$1->getName()+$2->getName()+$3->getName();
                  string si_type=toBeReturned;
                  $$=new SymbolInfo(si_name,si_type);
                  fprintf(logFile,"Line %d : logic_expression : rel_expression LOGICOP rel_expression \n\n",line_count);
                  string token=$$->getName();
                  fprintf(logFile,"%s\n\n",token.c_str());
                 }
                 ;
 
rel_expression	: simple_expression
                {
                 $$=$1;
                 fprintf(logFile,"Line %d : rel_expression : simple_expression \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                }
                
                | simple_expression RELOP simple_expression
                {
                   
                 if($1->getType()=="void")
                 {
                  error_count++;
                  string err_msg="Void function used in expression";
                  fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                  //$1->setType("float");
                 }
                   
                  
                 if($3->getType()=="void")
                 {
                  error_count++;
                  string err_msg="Void function used in expression";
                  fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                 // $3->setType("float");
                 }
                   
                 string si_name=$1->getName()+$2->getName()+$3->getName();
                 string si_type="int";
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d : rel_expression : simple_expression RELOP simple_expression \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                } 
                ;
        
simple_expression : term
                  {
                   $$=$1;
                   fprintf(logFile,"Line %d : simple_expression : term \n\n",line_count); 
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());          
                  }  
                  
                  | simple_expression ADDOP term
                  {
                   string toBeReturned;
                   
                   if($1->getType()=="void")
                   {
                    error_count++;
                    string err_msg="Void function used in expression";
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   // $1->setType("float");
                   }
                   
                   if($3->getType()=="void")
                   {
                    error_count++;
                    string err_msg="Void function used in expression";
                    fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
                   // $3->setType("float");
                   }
                   
                   if($1->getType()=="float" || $3->getType()=="float")
                   {
                    toBeReturned="float";
                   }
                   
                   else
                   {
                    toBeReturned="int"; 
                   }
                   
                   string si_name=$1->getName()+$2->getName()+$3->getName();
                   string si_type=toBeReturned;
                   $$=new SymbolInfo(si_name,si_type);
                   fprintf(logFile,"Line %d : simple_expression : simple_expression ADDOP term \n\n",line_count);
                   string token=$$->getName();
                   fprintf(logFile,"%s\n\n",token.c_str());
                  } 
                  ;      
         
term :	unary_expression
     {
      $$=$1;
      fprintf(logFile,"Line %d : term :	unary_expression \n\n",line_count);
      string token=$$->getName();
      fprintf(logFile,"%s\n\n",token.c_str());
     }
     
     | term MULOP unary_expression
     {
      string toBeReturned="error";
      if($1->getType()=="void")
      {
       error_count++;
       string err_msg="Void function call within expression";
       fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
      // $1->setType("float");
      }
      
      if($3->getType()=="void")
      {
       error_count++;
       string err_msg="Void function call within expression";
       fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
    //   $3->setType("float");
      }
      
      if($2->getName()=="%")
      {
       if($1->getType()=="int" && $3->getType()=="int")
       {
        if($3->getName()=="0")
        {
         //mod by 0 error
         
         error_count++;
         string err_msg="Modulus by 0";
         fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
         
        }
        else
        {
         toBeReturned="int";
        }
       }
       else
       {
        //type mismatch error
        
        error_count++;
        string err_msg="Non integer operand in modulus operation";
        fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
        
       }
      }
      else if($2->getName()=="*" || $2->getName()=="/")
      {
       if($1->getType()=="float" || $3->getType()=="float")
       {
        toBeReturned="float";
       }
       else
       {
        toBeReturned="int";
       }
       if($2->getName()=="/")
       {
        if($3->getName()=="0")
        {
         //Divide by 0 error
         
         error_count++;
         string err_msg="Division by 0";
         fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
         
        }
       }
      }
      string si_name=$1->getName()+$2->getName()+$3->getName();
      string si_type=toBeReturned;
      $$=new SymbolInfo(si_name,si_type);
      fprintf(logFile,"Line %d : term : term MULOP unary_expression \n\n",line_count);
      string token=$$->getName();
      fprintf(logFile,"%s\n\n",token.c_str());
     }
     ;
         
unary_expression: ADDOP unary_expression
                {
                 string si_name=$1->getName()+$2->getName();
                 string si_type=$2->getType();
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d : unary_expression: ADDOP unary_expression \n\n",line_count);    
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());             
                }
                
                | NOT unary_expression
                {
                 string si_name="!"+$2->getName();
                 string si_type=$2->getType();
                 $$=new SymbolInfo(si_name,si_type);
                 fprintf(logFile,"Line %d : unary_expression: NOT unary_expression \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str()); 
                }
                
                | factor
                {
                 $$=$1;
                 fprintf(logFile,"Line %d : unary_expression: factor \n\n",line_count);
                 string token=$$->getName();
                 fprintf(logFile,"%s\n\n",token.c_str());
                }
                ;
                
factor : variable
       {
        $$=$1;
        fprintf(logFile,"Line %d : factor : variable \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       
       | ID LPAREN argument_list RPAREN
       {
        string idr_name=$1->getName();
        SymbolInfo *ptr=symtab->Lookup(idr_name);
        if(ptr==nullptr)
        {
         //undeclared identifier referred
         
         error_count++;
         string err_msg="Undeclared function "+$1->getName();
         fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
        // cout<<"In func argument"<<endl;
         
        }
        else
        {
         if(!(ptr->isFunc()))
         {
          //error,identifier not function type
          
          error_count++;
          string err_msg="Non function identifer "+$1->getName()+" referred";
          fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
          
         }
         else
         {
         SymbolInfo *func=symtab->Lookup($1->getName());
         if(func==nullptr)
         {
          error_count++;
          string err_msg="Undeclared function referrred";
          fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
         }
         
         else 
         {
          if(!func->isFunc())
          {
           error_count++;
           string err_msg="Identifier "+$1->getName()+" is not a function";
           fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
          }
          
          else
          {
           if(!func->isDefined())
           {
            error_count++;
            string err_msg="Function "+$1->getName()+" is not defined";
            fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
           }
           
           else
           {
            if(func->getType()=="void")
            {
             //error_count++;
             string err_msg="Void function can't be used as a variable";
           //  fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            }
            
            int taken_argSize=taken_arg.size();
            int param_size=func->getParamNum();
            if(taken_argSize!=param_size)
            {
             error_count++;
             string err_msg="Total number of arguments mismatch in function definition of "+func->getName();
             fprintf(errorFile,"Error at line %d : %s\n\n",line_count,err_msg.c_str());
            }
            
            else
            {
             vector<pair<string,string>> param_list=func->getParam();
             for(int i=0;i<taken_argSize;i++)
             {
              if(param_list[i].second!=taken_arg[i] and taken_arg[i]!="error")
              {
               error_count++;
               string err_msg="Type of argument doesn't match";
               fprintf(errorFile,"Error at line %d : %d th argument mismatch in function %s\n\n",line_count,i+1,func->getName().c_str());
              }
             }
            }
           }
          }
         }
        }
       }
        
        string si_name=$1->getName()+"("+$3->getName()+")";
        string si_type;
        if(ptr==nullptr)
        {
         si_type="undeclared";
        }
        
        else
        {
         si_type=ptr->getType();
        }
        
        $$=new SymbolInfo(si_name,si_type);
        fprintf(logFile,"Line %d : factor : ID LPAREN argument_list RPAREN \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
        taken_arg.clear();
      }
       
       |  LPAREN expression RPAREN
       {
        string si_name="("+$2->getName()+")";
        string si_type=$2->getType();
        $$=new SymbolInfo(si_name,si_type);
        fprintf(logFile,"Line %d : factor : LPAREN expression RPAREN \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       
       | CONST_INT
       {
        $$=$1;
        fprintf(logFile,"Line %d : factor : CONST_INT \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       
       | CONST_FLOAT
       {
        $$=$1;
        fprintf(logFile,"Line %d : factor : CONST_FLOAT \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       
       | variable INCOP
       {
        string si_name=$1->getName()+"++";
        string si_type=$1->getType();
        $$=new SymbolInfo(si_name,si_type);
        fprintf(logFile,"Line %d : factor : variable INCOP \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       
       | variable DECOP //need to edit .l file
       {
        string si_name=$1->getName()+"--";
        string si_type=$1->getType();
        $$=new SymbolInfo(si_name,si_type);
        fprintf(logFile,"Line %d : factor : variable DECOP \n\n",line_count);
        string token=$$->getName();
        fprintf(logFile,"%s\n\n",token.c_str());
       }
       ;
 
argument_list : arguments
              {
               $$=$1;
               fprintf(logFile,"Line %d : argument_list : arguments \n\n",line_count);
               string token=$$->getName();
               fprintf(logFile,"%s\n\n",token.c_str());
              }          
              
              | 
              {
               string si_name="";
               string si_type="void";
               $$=new SymbolInfo(si_name,si_type);
               fprintf(logFile,"Line %d : argument_list : \n\n",line_count);
               string token=$$->getName();
               fprintf(logFile,"%s\n\n",token.c_str());
              } 
              ;    

arguments : arguments COMMA logic_expression
          {
           string si_name=$1->getName()+","+$3->getName();
           string si_type=$1->getType()+","+$3->getType();
           $$=new SymbolInfo(si_name,si_type);
           fprintf(logFile,"Line %d : arguments : arguments COMMA logic_expression \n\n",line_count);
           taken_arg.push_back($3->getType());
          }
          
          | logic_expression
          {
           $$=$1;
           fprintf(logFile,"Line %d : arguments : logic_expression \n\n",line_count);
           taken_arg.push_back($1->getType());
          }
          ;
          
%%

int main(int argc,char *argv[])
{
    inputFile = fopen(argv[1], "r");

	if(inputFile == nullptr) {
		printf("Cannot Open Input File.\n");
		exit(1);
	}

    logFile = fopen("log.txt", "w");
    errorFile = fopen("error.txt", "w");

	yyin = inputFile;
	yyparse();

	// Logfile print
	symtab->PrintAllTable(logFile);
	fprintf(logFile, "Total lines: %d\n", line_count);
	fprintf(logFile, "Total errors: %d\n", error_count);

	// // Console Print
	cout << "\nTotal Lines: "  << line_count << endl;
	 cout << "Total Errors: " << error_count << endl;

	fclose(logFile);
	fclose(errorFile);

	return 0;
}
