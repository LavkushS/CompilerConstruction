%option noyywrap
%option prefix="ttemp"
 
%x COMMENT
%x COMMENT2
%x DEF
%x DEF2
%x UNDEF
%x IFDEF
%x ELIF
%x ELSE
%x ENDIF
%x SKIPPER
 
%{
#include <string>
#include <unordered_map>
#include<unordered_set>
#include<iostream>
using namespace std;
 
unordered_map <string, string> mp;
string key;
int checker=0;
unordered_set<int>tem_st;
int value=0;
%}
%%
 




"#undef " {//
//checking #undef statements
    BEGIN(UNDEF); return 2;}
<UNDEF>[a-zA-Z][a-zA-Z0-9]* {mp.erase(yytext); return 2;}
<UNDEF>[ \n]+ {BEGIN(INITIAL); return 2;
//finishedcheck
//
}
 



"#def " {
    //
    //checking #def statements
    BEGIN(DEF); return 1;int z=55;cout<<z;}
<DEF>[a-zA-Z][a-zA-Z0-9]* { 

    //adding to map for future access
    mp[yytext]="1"; 
    //adding default 1


    key = yytext;return 1;int z=44;cout<<z;}
<DEF>[\n]+ {
    //skipping unwanted code


    BEGIN(INITIAL); return 1;int z=33;cout<<z;}
<DEF>" " {
    
    //skippp
    BEGIN(DEF2); return 1;}
<DEF2>"\\\n" {return 1;}
<DEF2>[^\\\n]+ {
    
    ///check if existing in map already
    if(mp[key] == "1") mp[key] = ""; mp[key] += yytext; return 5;}
<DEF2>[\n]+ {BEGIN(INITIAL); return 1;
//
//
}
 


 
"#ifdef " {
    //
    //checking #ifdef statements

    BEGIN(IFDEF); return 6;}
<IFDEF>[a-zA-Z][a-zA-Z0-9]* {
value=1;key=yytext;
if(mp.find(key) != mp.end()) {
    //find in map
    checker=1;///updating value
}
else {
    //else block in it
    BEGIN(SKIPPER);}
return 6;
}
<IFDEF>[ \n]+ {BEGIN(INITIAL); return 6;

    //if end
    //
}
 
 


 
"#else" {
    
    //checking else
    
    BEGIN(ELSE); return 6;}
<ELSE>[ \n]+ {
if(value==0 || value==1){return 11;
//return val;
}
value=3; 
///updating value
if(checker==0) {checker=1;BEGIN(INITIAL);} else {BEGIN(SKIPPER);
///updating value
}
return 6;

//else end 
//
}







"#elif " {
    
    //checking elif
    
    BEGIN(ELIF); return 6;}
<ELIF>[a-zA-Z][a-zA-Z0-9]* {
if(value==0){return 8;}
key=yytext;value=2;
if(mp.find(key) != mp.end() && checker==0) {checker=1;}else {BEGIN(SKIPPER);}
return 6;
//end check 

//
}
<ELIF>[ \n]+ {BEGIN(INITIAL); return 6;}
 
 




<SKIPPER>[^(?!.*(#elif|#else|#endif)).*$] {
    
    ///skipping elif and else
    return 6;}
<SKIPPER>"#elif " {BEGIN(ELIF); return 6;}
<SKIPPER>"#else" {BEGIN(ELSE); return 6;}
<SKIPPER>"#endif" {BEGIN(ENDIF); return 6;}
 



"#endif" {BEGIN(ENDIF); return 6;}
<ENDIF>[ \n]+ {if(value==0){return 9;} checker=0; BEGIN(INITIAL); return 6;}
 

"/*"   {
    
    //checking for comment 


    BEGIN(COMMENT);}
<COMMENT>"*"+[^*/]*   
<COMMENT>[^*]*        
<COMMENT>"*"+"/"  {BEGIN(INITIAL);}
 
"//"    BEGIN(COMMENT2);
<COMMENT2>[ \n]+ {
    
    //checking for comment 

    BEGIN(INITIAL);}
<COMMENT2>.
[\n ] {return 4;}
[a-zA-Z][a-zA-Z0-9]* {return 3;}
. {return 4;}
%%