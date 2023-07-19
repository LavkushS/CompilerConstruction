%define api.value.type { ParserValue }
 
%code requires {
#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include <stdio.h>
#include <string.h>
#include <bits/stdc++.h>
 
#include "parser_util.hh"
#include "symbol.hh"
using namespace std;
}
 
%code {
 
#include <cstdlib>
#include <bits/stdc++.h>
using namespace std;
extern int yylex();
extern int yyparse();
int level=0,d=0;
extern NodeStmts* final_values;
 
SymbolTable symbol_table;
SymbolTable1 symbol_table1; 
SymbolTable2 symbol_table2; 
 
int flag=0;
int yyerror(std::string msg);
 
int check(std::string s)
{
    std::string t="";
    for(auto it:s)
    {
        if(it>='a' && it<='z' )
            return 0;
        else if(it>='A' && it<='Z')return 0;
        
    }
    return 1;
}
long long solver(string str)
{
    vector<string> vec;
    for(int i=0;i<str.length();i++){
        string temp="";
        while(i<str.length() && str[i]!=' '){
            temp+=str[i];
            i++;
        }
        vec.push_back(temp);
    }
    
    stack<string> st;

    long long  ind=0;

    while(ind<vec.size()){

        if(vec[ind]==")"){


            long long int a,b;
            a=stoll(st.top()); 
             st.pop();
            b=stoll(st.top());  
            st.pop();
            if(st.top()=="+"){
                st.pop();  
                 st.pop();
                st.push(to_string(a+b));
            }
            else if(st.top()=="*"){
                st.pop(); 
                  st.pop();
                st.push(to_string(a*b));
            }
            else if(st.top()=="-"){
                st.pop(); 
                  st.pop();
                st.push(to_string(b-a));
            }
            else if(st.top()=="/"){
                st.pop(); 
                  st.pop();
                st.push(to_string(b/a));
            }           
        }
        else{
            st.push(vec[ind]);
        }
        ind++;
    }
    return stoll(st.top());   
}
long long ValueSolverlong(string s){   // value of whole expression
    string str="";
    for(int i=0;i<s.length();i++){
        string temp="";
        while(i<s.length() && ((s[i]>='a' && s[i]<='z') || (s[i]>='A' && s[i]<='Z'))){
            temp+=s[i];
            i++;
        }
        if(temp.length()!=0){
            std::cout<<"<----------------------------------------------------> "<<temp<<" "<<symbol_table2.get(temp)<<std::endl;
            int p=symbol_table2.get(temp);
            str+=to_string(p);
            i--;
            continue;
        }
        str+=s[i];
 
    }
    return solver(str);
} 
  
long long calculate(string s) {
   
    int fin=solver(s);
    return fin;
}

string ValueSolverstring(string str){     /// constant folding result
    // vector<string> vec;
    // for(int i=0;i<str.length();i++){
    //     string temp="";
    //     while(i<str.length() && str[i]!=' '){
    //         temp+=str[i];
    //         i++;
    //     }
    //     vec.push_back(temp);
    // }
    // for(auto x:vec) cout<<x<<endl;
    
    for (int i=0; i<str.length(); i++)
    {
        if (str[i]!=')')
            continue;
        
        int j = i-1;
        int variable = 1;
        while (str[j]!='(' && variable)
        {
            if (str[j]!=' ' && str[j]!='+' && str[j]!='-' && str[j]!='*' && str[j]!='/' && !(str[j]>='0' && str[j]<='9'))
                variable = 0;
            j--;
        }
 
        if (!variable)
            continue;
 
        vector <int> calc;
        int temp1 = 0;
        int op1 = -1;
        for (int z=j+1; z<i; z++)
        {
            if (str[z]=='+')
                op1 = 0;
            else if (str[z]=='-')
                op1 = 1;
            else if (str[z]=='*')
                op1 = 2;
            else if (str[z]=='/')
                op1 = 3;
            else if (str[z]==' ')
            {
                calc.push_back(temp1);
                temp1 = 0;
            }
            else
                temp1 = temp1*10 + (str[z]-'0');
        }
 
        int b = calc.back();
        calc.pop_back();
        int a = calc.back();
 
        int fin;
        if (op1==0)
            fin = a+b;
        else if (op1==1)
            fin = a-b;
        else if (op1==2)
            fin = a*b;
        else 
            fin = a/b;
 
        str.erase(j, i-j+1);
        str.insert(j, std::to_string(fin));
        i = j;
    }
 
    cout << str << endl;
    
    return str;
 
}

long long FindAns(string s,int d)
{
    for(int i=0;i<s.length();i++)
    {
        string temp="";
        while(i<s.length() &&
         ((s[i]>='a' && s[i]<='z') || 
         (s[i]>='A' && s[i]<='Z')))
        {
            temp+=s[i];
            i++;
        }
        if(temp.length()!=0)
        {
            std::pair<int,int>p=symbol_table1.value(temp);
            int k=p.second;
            if(k==d)
                continue;
            if(k>d)
            {
                return 0;
            }

        }
    }
    return 1;
}
}
 
%token TPLUS TDASH TSTAR TSLASH
%token <lexeme> TINT_LIT TIDENT TTYPEI TTYPES TTYPEL 
%token INT TLET TDBG
%token TSCOL TLPAREN TRPAREN TEQUAL TCOLON
%token TIF TELSE TLCURL TRCURL TFUN TMAIN
 
 
%type <node> Expri Exprs Exprl Expr Stmt IF TTYPE NN MM
%type <stmts> Program StmtList FuncMain X B Func
 
%left TPLUS TDASH
%left TSTAR TSLASH
 
%%

 
Program :                
        { final_values = nullptr; }
        | StmtList TSCOL 
        {   
             final_values = $1; }
       
        
         | StmtList TSCOL IF
         {
            $$=new NodeStmts();
            $$->push_back($1);
            $$->push_back($3);
            final_values=$$;
         }
          | IF {
            $$=new NodeStmts();
            $$->push_back($1);
            final_values=$$;
         }
         | StmtList TSCOL TFUN TMAIN TLPAREN TRPAREN  TCOLON TTYPE TLCURL StmtList TRCURL StmtList TSCOL
         {
            $$=new NodeStmts();
            $$->push_back($1);
            $$->push_back($10);
            $$->push_back($12);
            final_values=$$;
         }
         | StmtList TSCOL TFUN TMAIN TLPAREN TRPAREN  TCOLON TTYPE TLCURL StmtList  TSCOL TRCURL StmtList TSCOL
         {
            $$=new NodeStmts();
            $$->push_back($1);
            $$->push_back($10);
            $$->push_back($13);
            final_values=$$;
         }
         | StmtList TSCOL TFUN TMAIN TLPAREN TRPAREN  TCOLON TTYPE TLCURL StmtList TRCURL StmtList 
         {
            $$=new NodeStmts();
            $$->push_back($1);
            $$->push_back($10);
            $$->push_back($12);
            final_values=$$;
         }
         | StmtList TSCOL TFUN TMAIN TLPAREN TRPAREN  TCOLON TTYPE TLCURL StmtList  TSCOL TRCURL StmtList 
         {
            $$=new NodeStmts();
            $$->push_back($1);
            $$->push_back($10);
            $$->push_back($13);
            final_values=$$;
         }
         
         
	    ;
 
StmtList :
         
         Stmt                
         { 
            $$ = new NodeStmts(); $$->push_back($1); 
        }
	     | StmtList TSCOL Stmt 
         { 
            $$->push_back($3); 
        }
        
         | StmtList Stmt
         {
            $$->push_back($2);
         }
         | StmtList TSCOL IF
         {
            $$->push_back($3);
         }
         
         
	     ;
X:        B FuncMain{
        }
        | FuncMain;
FuncMain: TFUN TMAIN TLPAREN TRPAREN TCOLON TTYPE TLCURL StmtList TSCOL TRCURL
          {};

B:      B Func
        | Func;
        
Func: TFUN TIDENT TLPAREN TRPAREN TCOLON TTYPE TLCURL StmtList TSCOL TRCURL;
TTYPE: TTYPEI{

} 
|
 TTYPEL{

 } 
|
 TTYPES{

 };
Stmt : 
        
TLET TIDENT TCOLON TTYPEI TEQUAL Expri
     {
        if(symbol_table2.contains($2)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else
         {
            std::string s=$6->to_string();

            long long ans_i=FindAns(s,1);

            if(ans_i==0)
            {
                yyerror("TypeCasting error.\n");
            }
            else
            {
            if(check(s))
            {
                long long ans=solver(s);

                if(ans>2147483647 || ans<-2147483648)
                {
                    yyerror("Integer Overflow.\n");
                }
                
                symbol_table2.insert($2,ans);
                symbol_table.insert($2);

                symbol_table1.insert($2,{ans,1});

                Node* Node= new NodeLong(ans);
                
                $$ = new NodeDecl($2,Node,Node);
               // continue;
            }
            else
            {
                symbol_table.insert($2);
                
                long long ans=ValueSolverlong(s);
                std::string folded=ValueSolverstring(s);

                symbol_table1.insert($2,{ans,1});

                symbol_table2.insert($2,ans);
                if(ans>2147483647)
                {
                    yyerror("Integer Overflow.\n");
                }
                Node* node=new NodeTest(folded);
                $$ = new NodeDecl($2, $6, node);
            }
            }
        }
       
     }
     |
     TLET TIDENT TCOLON TTYPES TEQUAL Exprs
     {
        if(symbol_table2.contains($2)) {
            // tried to redeclare variable, so error


            yyerror("tried to redeclare variable.\n");
        } else {
            std::string s=$6->to_string();

            long long ans_i=FindAns(s,0);
            if(ans_i==0)
            {
                yyerror("TypeCasting error.\n");
            }
            else{
            if(check(s))
            {
                long long ans=solver(s);

                if(ans>32767)
                {
                    yyerror("Short Overflow.\n");
                }
                symbol_table2.insert($2,ans);
                symbol_table.insert($2);

                symbol_table1.insert($2,{ans,0});
                Node* Node= new NodeLong(ans);
                // Node->value=ans;
                $$ = new NodeDecl($2,Node,Node);
               // continue;
            }
            else
            {
                symbol_table.insert($2);
                
                long long ans=ValueSolverlong(s);
                std::string folded=ValueSolverstring(s);

                symbol_table1.insert($2,{ans,0});

                symbol_table2.insert($2,ans);
                if(ans>32767 || ans<-32768)
                {
                    yyerror("Integer Overflow.\n");
                }
                Node* node=new NodeTest(folded);
                $$ = new NodeDecl($2, $6, node);            }
            }
        }
        
     }
     |
     TLET TIDENT TCOLON TTYPEL TEQUAL Exprl
     {
        
        if(symbol_table2.contains($2)) 
        {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else 
        {
            std::string s=$6->to_string();

            long long ans_i=FindAns(s,2);

            if(ans_i==0)
            {
                yyerror("TypeCasting error.\n");
            }
            else{
            if(check(s))
            {
                long long ans=solver(s);

                symbol_table2.insert($2,ans);

                symbol_table.insert($2);


                symbol_table1.insert($2,{ans,2});


                Node* Node= new NodeLong(ans);
                // Node->value=ans;
                $$ = new NodeDecl($2,Node,Node);
               // continue;
            }
            else
            {
                symbol_table.insert($2);
                
                long long ans=ValueSolverlong(s);
                std::string folded=ValueSolverstring(s);

                symbol_table1.insert($2,{ans,2});

                symbol_table2.insert($2,ans);
                
                Node* node=new NodeTest(folded);
                $$ = new NodeDecl($2, $6, node);
            }
            }
        }   
     }
     | TDBG Expr
     { 
        std::string s=$2->to_string();


        long long ans=ValueSolverlong(s);


        Node* Node= new NodeLong(ans);
                // Node->value=ans;
        $$ = new NodeDebug(Node);
     }
     |TIDENT TEQUAL Expr
     {
        if(symbol_table1.contains($1))
        {
            std::pair<int,int> p=symbol_table1.value($1);

            long long D=FindAns($3->to_string(),p.second);
            if(D==0){
                yyerror("TypeCasting Error\n");
            }
        }
            std::string s=$3->to_string();
            if(check(s))
            {
                long long ans=solver(s);
                
                symbol_table.insert($1);


                symbol_table1.insert($1,{ans,2});


                symbol_table1.insert($1,{ans,symbol_table1.value($1).second});


                symbol_table2.update($1,ans);
                Node* Node= new NodeLong(ans);
                // Node->value=ans;
                $$ = new NodeDecl($1,Node,Node);
               // continue;
            }
        else{
            long long ans = ValueSolverlong(s);
            std::string folded=ValueSolverstring(s);

            symbol_table1.insert($1,{ans,2});

            symbol_table2.insert($1,ans); 
            Node* node=new NodeTest(folded);
            $$=new NodeDecl($1, $3,node);
        }
        d=0;
     }
     | IF
     | //empty
     {}
     ;
 
IF: TIF Expri NN StmtList MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=ValueSolverlong(a);

            Node* Node= new NodeInt(ans);


            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
        
            $$ = new NodeIfElse($2,$4,$8);
    } 
    |
    TIF Expri NN StmtList MM TELSE NN StmtList  MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeInt(ans);

            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$8);
    }
    |TIF Expri NN StmtList TSCOL MM TELSE NN StmtList MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {

            long long ans=solver(a);

            Node* Node= new NodeInt(ans);

            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    |TIF Expri NN StmtList TSCOL MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeInt(ans);


            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    |
    TIF Exprl NN StmtList MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);


            Node* Node= new NodeLong(ans);


            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$8);
    } 
    |
    TIF Exprl NN StmtList MM TELSE NN StmtList MM
    {   
        std::string a=$2->to_string();

        if(check(a))
        {
            long long ans=solver(a);



            Node* Node= new NodeLong(ans);

            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$8);
    }
    |TIF Exprl NN StmtList TSCOL MM TELSE NN StmtList MM
    {   
        std::string a=$2->to_string();

        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeLong(ans);


            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    |TIF Exprl NN StmtList TSCOL MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);


            Node* Node= new NodeLong(ans);


            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    
    |
    TIF Exprs NN StmtList MM TELSE NN StmtList  MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeShort(ans);

            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$8);
    }
    |TIF Exprs NN StmtList TSCOL MM TELSE NN StmtList MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeShort(ans);


            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    | TIF Exprs NN StmtList MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);
            
            Node* Node= new NodeShort(ans);
            $$ = new NodeIfElse(Node,$4,$8);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$8);
    }
    |TIF Exprs NN StmtList TSCOL MM TELSE NN StmtList TSCOL MM
    {   
        std::string a=$2->to_string();
        if(check(a))
        {
            long long ans=solver(a);

            Node* Node= new NodeShort(ans);


            $$ = new NodeIfElse(Node,$4,$9);
            
        }
        else
            $$ = new NodeIfElse($2,$4,$9);
    }
    
    ;
 
NN: TLCURL 
    {   
        symbol_table2.inc();
    }
 
MM: TRCURL
    {   
        symbol_table2.dec();
    }
Expri:TINT_LIT               
     { 
        if($1[0]!='-')
        {
            if($1.length()>=11)
            {
                yyerror("Int Range Overflow\n");
            }
            else if($1.length()==10)
            {
                if($1>"2147483647")
                {

                   yyerror("Int Range Overflow\n");
                }
            }
        }
        $$ = new NodeInt(stoi($1));    
    }
    | TIDENT
     { 
        if(symbol_table.contains($1))
            {$$ = new NodeIdent($1);
           } 
        else
            yyerror("using undeclared variable.\n");
     }
     | Expri TPLUS Expri
     { 
        $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3,2);
        
        std:: string s=$$->to_string();
        if(s=="Integer Overflow")
        {

            yyerror("Int Range Overflow\n");
        }
     }
     | Expri TDASH Expri
     { 
        $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3,2); 
        std:: string s=$$->to_string();
        if(s=="Integer Overflow")
        {

            yyerror("Int Range Overflow\n");
        }
    }
     | Expri TSTAR Expri
     { 
        $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3,2);
        std:: string s=$$->to_string();
        if(s=="Integer Overflow")
        {

            yyerror("Int Range Overflow\n");
        }
    }
     | Expri TSLASH Expri
     { 
        $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3,2);


     std:: string s=$$->to_string();
        if(s=="Integer Overflow")
        {
            yyerror("Int Range Overflow\n");
        } 
    }
     | TLPAREN Expri TRPAREN { $$ = $2; }
     ;
 
Exprs:TINT_LIT               
     { 
        if($1[0]!='-'){
            if($1.length()>=6)
            {
                yyerror("Short Range Overflow\n");
            }
            else if($1.length()==5)
            {
                if($1>"32767")
                {
                   yyerror("Short Range Overflow\n");
                }
            }
        }
        $$ = new NodeShort(stoi($1)); 
        
    }
    | TIDENT
     { 
        if(symbol_table.contains($1))
            $$ = new NodeIdent($1); 
        else
            yyerror("using undeclared variable.\n");
     }
     | Exprs TPLUS Exprs
     { 
        $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3,1);
         std:: string s=$$->to_string();
        if(s=="Short Overflow")
        {
            yyerror("Short Range Overflow\n");
        }  
    }
     | Exprs TDASH Exprs
     { 
        $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3,1); 


        std:: string s=$$->to_string();
        if(s=="Short Overflow")
        {
            yyerror("Short Range Overflow\n");
        }  
    }
     | Exprs TSTAR Exprs
     { 
        $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3,1); 


        std:: string s=$$->to_string();
        if(s=="Short Overflow")
        {
            yyerror("Short Range Overflow\n");
        }  
    }
     | Exprs TSLASH Exprs
     { 
        $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3,1);


        std:: string s=$$->to_string();
        if(s=="Short Overflow")
        {
            yyerror("Short Range Overflow\n");
        }  
     }
     | TLPAREN Exprs TRPAREN { $$ = $2; }
     ;
 
Exprl:TINT_LIT               
     { 
        if($1[0]!='-'){
            if($1.length()>=20)
            {
                yyerror("Long Range Overflow\n");
            }
            else if($1.length()==19)
            {
                if($1>"2147483647")
                {
                   yyerror("Long Range Overflow\n");
                }
            }
        }
        $$ = new NodeLong(stoll($1));     
    }
    | TIDENT
     { 
        if(symbol_table.contains($1))
            $$ = new NodeIdent($1); 
        else
            yyerror("using undeclared variable.\n");
     }
     | Exprl TPLUS Exprl
     { $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3,3); }
     | Exprl TDASH Exprl
     { $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3,3); }
     | Exprl TSTAR Exprl
     { $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3,3); }
     | Exprl TSLASH Exprl
     { $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3,3); }
     | TLPAREN Exprl TRPAREN { $$ = $2; }
     ;
Expr : TINT_LIT               
     { $$ = new NodeLong(stoll($1)); }
     | TIDENT
     { 
        if(symbol_table.contains($1))
        {
            $$ = new NodeIdent($1);
            
        }
 
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr TPLUS Expr
     { $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3,0); }
     | Expr TDASH Expr
     { $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3,0); }
     | Expr TSTAR Expr
     { $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3,0); }
     | Expr TSLASH Expr
     { $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3,0); }
     | TLPAREN Expr TRPAREN { $$ = $2; }
     ;
 
%%
 
int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}