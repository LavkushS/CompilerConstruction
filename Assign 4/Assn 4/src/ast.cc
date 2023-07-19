#include "ast.hh"

#include <string>
#include <vector>

NodeBinOp::NodeBinOp(NodeBinOp::Op ope, Node *leftptr, Node *rightptr,int val) {
    type = BIN_OP;
    op = ope;
    left = leftptr;
    right = rightptr;
    test=val;
}

std::string NodeBinOp::to_string() {
    std::string overflow="";

    std::string out = "(";


    long long l=1,r=1;

    if(left->to_string()[0]>='0' && left->to_string()[0]<='9')
        l=stoll(left->to_string());


    if(right->to_string()[0]>='0' && right->to_string()[0]<='9')
        r=stoll(right->to_string());


    switch(op) {

        case PLUS:
         {


            out+=' ';
            out += '+';
            
            
            if(test==1 && l+r-32767>0)
            {

                overflow+="Short Overflow";
            }
            if(test==2 && l+r-2147483647>0)
            {

                overflow+="Integer Overflow";
            }

            break;
        }
        case MINUS:{



            out += ' ';
             out += '-';
            
             
            if (test == 1 && l - r - 32767 > 0)
             {
                overflow+="Short Overflow";
            }
            if(test==2 && l-r-2147483647>0)
            {
                overflow+="Integer Overflow";
            }
            break;
        }
        case MULT:{

            out += ' ';
            out += '*';
           
             
            if (test == 1 && l * r - 32767 > 0)
            {
                overflow+="Short Overflow";
            }



             if(test==2 && l*r-2147483647>0)
             {

                overflow+="Integer Overflow";
            }
            break;
        }
        case DIV:{

            out += ' ';
             out += '/';
            
              
             if (test == 1 && l / r - 32767 > 0)
             {
                overflow+="Short Overflow";
            }


             if(test==2 && l/r-2147483647>0)
             {
                overflow+="Integer Overflow";
            }
            break;
        }
    }


    out += ' ' + left->to_string() + ' ' + right->to_string() +' ' +')';

    if(overflow.length()>0)
    {

        return overflow;
    }
    return out;
}

NodeInt::NodeInt(int val) {
    type = INT_LIT;
    value = val;
}

std::string NodeInt::to_string() {
    return std::to_string(value);
}

NodeShort::NodeShort(short val) {
    type = INT_LIT;
    value = val;
}

std::string NodeShort::to_string() {
    return std::to_string(value);
}

NodeLong::NodeLong(long long val) {
    type = INT_LIT;
    value = val;
}

std::string NodeLong::to_string() {
    return std::to_string(value);
}

NodeStmts::NodeStmts() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts::to_string() {
    std::string out = "(begin";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}

NodeDecl::NodeDecl(std::string id, Node *expr, Node *abc)
{
    type = ASSN;
    identifier = id;
    expression = expr;
    st1 = abc;
}

std::string NodeDecl::to_string()
{
    return "(let " + identifier + " " + st1->to_string() + ")";
}
NodeTest::NodeTest(std::string abc)
{
    type = ASSN;
    st = abc;
}

std::string NodeTest::to_string()
{
    return st;
}

NodeDebug::NodeDebug(Node *expr) {
    type = DBG;
    expression = expr;
}

std::string NodeDebug::to_string() {
    return "(dbg " + expression->to_string() + ")";
}

NodeIdent::NodeIdent(std::string ident) {
    identifier = ident;
}
std::string NodeIdent::to_string() {
    return identifier;
}
NodeIfElse::NodeIfElse(Node* cond, Node *tBody, Node *fBody)
{
    condition = cond;
    ifBody = tBody;
    elseBody = fBody;
}

std::string NodeIfElse::to_string()
{   
    
    std::string s=condition->to_string();
    int c=0;
    for(auto i:s)
    {

        if(i>='a' && i<='z' )
            c=1;
        else if(i>='A' && i<='Z')
            c=1;
    }

    std::string out="\n";

    if( c==0 && s!="0")
    {
        out+= "(if-else " + condition->to_string() + " \n";
        out += ifBody->to_string() +"\n";
    }
    else if(c==1)
    {
        out += "(if-else " + condition->to_string() + " \n";
        out += ifBody->to_string() + "\n";
    }
    

    out += elseBody->to_string() + "\n)";


    return out;
}