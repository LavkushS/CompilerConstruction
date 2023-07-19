#ifndef AST_HH
#define AST_HH

#include <llvm/IR/Value.h>
#include <string>
#include <vector>

#include <iostream>
#include <string>
#include <vector>
#include <cstdio>
#include <cstring>
#include <fstream>

struct LLVMCompiler;

/**
Base node class. Defined as `abstract`.
*/
struct Node
{
    enum NodeType
    {
        BIN_OP,
        INT_LIT,
        STMTS,
        ASSN,
        DBG,
        IDENT
    } type;

    virtual std::string to_string() = 0;
    virtual llvm::Value *llvm_codegen(LLVMCompiler *compiler) = 0;
};

/**
    Node for list of statements
*/
struct NodeStmts : public Node
{
    std::vector<Node *> list;

    NodeStmts();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for binary operations
*/
struct NodeBinOp : public Node
{
    enum Op
    {
        PLUS,
        MINUS,
        MULT,
        DIV
    } op;

    Node *left, *right;
    int test;

    NodeBinOp(Op op, Node *leftptr, Node *rightptr, int val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for integer literals
*/
struct NodeInt : public Node
{
    int value;
    NodeInt(int val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for short literals
*/
struct NodeShort : public Node
{
    short value;

    NodeShort(short val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for long literals
*/
struct NodeLong : public Node
{
    long long int value;
    NodeLong(long long int val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
 * node for folded expression
 *
 */
// struct NodeFolded : public Node {
//     std::string value;
//     NodeFolded(std::string val);
//     std::string to_string();
//     llvm::Value *llvm_codegen(LLVMCompiler *compiler);

// };

/**
    Node for variable assignments
*/
struct NodeDecl : public Node
{
    std::string identifier;
    Node *expression;
    Node *st1;
    NodeDecl(std::string id, Node *expr, Node *abc);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeTest : public Node
{
    std::string st;

    NodeTest(std::string abc);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for `dbg` statements
*/
struct NodeDebug : public Node
{
    Node *expression;

    NodeDebug(Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for idnetifiers
*/
struct NodeIdent : public Node
{
    std::string identifier;

    NodeIdent(std::string ident);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeIfElse : public Node
{
    Node *condition;
    Node *ifBody;
    Node *elseBody;

    NodeIfElse(Node *condition, Node *ifBody, Node *elseBody);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

#endif